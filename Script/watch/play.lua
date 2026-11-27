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
local makeActor, drawFigure, rayInterval, hitBox, drawCartShape, CHILD_W, CHILD_H, SOLDIER_W, SOLDIER_H, INK, CART_FILL, CLOTH -- 6058
local ____Dora = require("Dora") -- 12
local Color = ____Dora.Color -- 12
local Rect = ____Dora.Rect -- 12
local Vec2 = ____Dora.Vec2 -- 12
local ____rooms = require("Script.watch.rooms") -- 13
local withOrigin = ____rooms.withOrigin -- 15
local ____run = require("Script.watch.run") -- 17
local createRun = ____run.createRun -- 18
local createStoryTalents = ____run.createStoryTalents -- 18
local draftRoom = ____run.draftRoom -- 18
local draftTalentOffers = ____run.draftTalentOffers -- 18
local mmss = ____run.mmss -- 19
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
function makeActor(room, index) -- 6058
	local sp = room.spawns -- 6059
	if index < 0 or index >= #sp then -- 6060
		return { -- 6061
			x = 0, -- 6061
			y = 0, -- 6061
			depth = 0, -- 6061
			depthSpeed = 0, -- 6061
			vx = 0, -- 6061
			vy = 0, -- 6061
			w = CHILD_W, -- 6061
			h = CHILD_H, -- 6061
			onGround = true, -- 6061
			facing = 1, -- 6061
			crouch = false, -- 6061
			rollT = 0, -- 6061
			covered = false, -- 6061
			alive = false -- 6061
		} -- 6061
	end -- 6061
	local s = sp[index + 1] -- 6063
	local child = s.h < SOLDIER_H -- 6064
	local ground = room.depth -- 6065
	local depth = ground == nil and 0 or math.max( -- 6066
		ground.min, -- 6066
		math.min(ground.max, s.depth or 0) -- 6066
	) -- 6066
	return { -- 6067
		x = s.x, -- 6068
		y = s.y, -- 6068
		depth = depth, -- 6068
		depthSpeed = 0, -- 6068
		vx = 0, -- 6068
		vy = 0, -- 6068
		w = child and CHILD_W or SOLDIER_W, -- 6069
		h = child and CHILD_H or SOLDIER_H, -- 6070
		onGround = true, -- 6071
		facing = 1, -- 6071
		crouch = false, -- 6071
		rollT = 0, -- 6071
		covered = false, -- 6071
		alive = true -- 6071
	} -- 6071
end -- 6071
function drawFigure(draw, play, w, h, a, body, head) -- 6075
	if not a.alive then -- 6076
		return -- 6077
	end -- 6077
	local x0 = a.x - a.w / 2 -- 6079
	local x1 = a.x + a.w / 2 -- 6080
	local y0 = a.y + a.depth * DEPTH_Y_SCALE -- 6081
	local y1 = y0 + a.h -- 6082
	play:drawBox( -- 6083
		draw, -- 6083
		w, -- 6083
		h, -- 6083
		x0, -- 6083
		x1, -- 6083
		y0, -- 6083
		y1 - a.h * 0.26, -- 6083
		body -- 6083
	) -- 6083
	play:drawBox( -- 6084
		draw, -- 6084
		w, -- 6084
		h, -- 6084
		x0 + 2, -- 6084
		x1 - 2, -- 6084
		y1 - a.h * 0.26, -- 6084
		y1, -- 6084
		head -- 6084
	) -- 6084
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 6086
	play:drawBox( -- 6087
		draw, -- 6087
		w, -- 6087
		h, -- 6087
		eyeX, -- 6087
		eyeX + 4, -- 6087
		y1 - a.h * 0.14, -- 6087
		y1 - a.h * 0.08, -- 6087
		INK -- 6087
	) -- 6087
end -- 6087
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 6091
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 6092
end -- 6091
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 6099
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 6100
end -- 6099
function rayInterval(origin, direction, min, max) -- 6107
	if direction == 0 then -- 6108
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 6109
	end -- 6109
	local a = (min - origin) / direction -- 6111
	local b = (max - origin) / direction -- 6112
	return { -- 6113
		min = math.min(a, b), -- 6113
		max = math.max(a, b) -- 6113
	} -- 6113
end -- 6113
function hitBox(ray, box) -- 6117
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 6118
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 6119
	local enter = math.max(0, x.min, y.min) -- 6120
	local leave = math.min(99999, x.max, y.max) -- 6121
	if box.depth ~= nil then -- 6122
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 6123
		enter = math.max(enter, depth.min) -- 6124
		leave = math.min(leave, depth.max) -- 6125
	end -- 6125
	return leave >= enter and enter or -1 -- 6127
end -- 6127
function drawCartShape(draw, play, w, h, c, axleX) -- 6130
	local half = c.bodyW / 2 -- 6131
	local x0 = axleX - half -- 6132
	local x1 = axleX + half -- 6133
	local axleY = c.baseY + (c.depth or 0) * DEPTH_Y_SCALE + c.wheelR -- 6134
	play:drawBox( -- 6135
		draw, -- 6135
		w, -- 6135
		h, -- 6135
		x0, -- 6135
		x1, -- 6135
		axleY, -- 6135
		axleY + c.bodyH, -- 6135
		CART_FILL -- 6135
	) -- 6135
	draw:drawCircle( -- 6136
		Vec2( -- 6136
			play:sx(x0 + c.bodyW * 0.28, w), -- 6136
			play:sy(axleY, h) -- 6136
		), -- 6136
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6136
		Color(52, 50, 48, 255) -- 6136
	) -- 6136
	draw:drawCircle( -- 6137
		Vec2( -- 6137
			play:sx(x1 - c.bodyW * 0.28, w), -- 6137
			play:sy(axleY, h) -- 6137
		), -- 6137
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6137
		Color(52, 50, 48, 255) -- 6137
	) -- 6137
	local cx = c.clothSide < 0 and x0 or x1 -- 6138
	play:drawBox( -- 6139
		draw, -- 6139
		w, -- 6139
		h, -- 6139
		cx - 10, -- 6139
		cx + 10, -- 6139
		axleY + c.bodyH, -- 6139
		axleY + c.bodyH + 18, -- 6139
		CLOTH -- 6139
	) -- 6139
end -- 6139
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
function Play.prototype.____constructor(self, room, resume, run) -- 672
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
	self.paused = false -- 656
	self.ticks = 0 -- 658
	self.view = {zoom = 1, ox = 0, oy = 0} -- 660
	self.ox = 0 -- 662
	self.aimX = 0 -- 664
	self.aimY = 0 -- 665
	self.viewW = 0 -- 667
	self.viewH = 0 -- 668
	self.ox = room.originX -- 674
	self.room = withOrigin(room) -- 675
	local wr = self.room -- 676
	self.run = run or createRun() -- 677
	self.inventory = self.run.inventory -- 678
	self.archive = self.run.archive -- 679
	self.equippedWeapon = self.run.story.craftedWeapon == "" and "standard_gun" or self.run.story.craftedWeapon -- 680
	self.isCampaign = wr.campaign ~= nil -- 681
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 682
	self:buildWorld() -- 683
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 686
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 688
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 689
	local soloRoom = wr.key == "museum" -- 691
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 692
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 693
	self.player = makeActor(wr, playerIdx) -- 694
	self.partner = makeActor(wr, partnerIdx) -- 695
	self.phase = phaseOf(wr.key) -- 696
	if soloRoom then -- 697
		local mp = self.archive.museumPhase -- 699
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 700
	end -- 700
	if wr.story ~= nil then -- 705
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 706
	end -- 706
	self.cam.x = self.player.x -- 708
	self.cam.y = self.player.y + CAM_LOOK_UP -- 709
	self.cartAxle = wr.cart.startX -- 710
	self.escort = __TS__New( -- 711
		Escort, -- 711
		safeAnchorX(wr.marks) -- 711
	) -- 711
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 712
	if self.isCampaign then -- 713
		self:setupCampaign() -- 714
	else -- 714
		self:buildEnemies() -- 716
	end -- 716
	if resume ~= nil and resume.checkpoint > 0 then -- 719
		self.checkpoint = resume.checkpoint -- 720
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 721
			self.cartAxle = self.room.cart.endX -- 722
			self.cartDocked = true -- 723
			self.player.x = self.ox + 380 -- 726
			self.player.y = 0 -- 727
			self.player.vy = 0 -- 728
			self.player.onGround = true -- 729
			self.cam.x = self.player.x -- 730
			self.cam.y = self.player.y + CAM_LOOK_UP -- 731
		end -- 731
	end -- 731
	self:restoreStory() -- 734
end -- 672
function Play.prototype.towerEndReady(self) -- 564
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 565
	return self.room.key == "tower" and self.phase == "tower-end" and self.phaseTick >= waitTicks and not self.towerEndMustRelease -- 566
end -- 564
function Play.prototype.recipeViews(self) -- 747
	local out = {} -- 748
	local i = 0 -- 749
	do -- 749
		i = 0 -- 750
		while i < #CRAFT_RECIPES do -- 750
			local r = CRAFT_RECIPES[i + 1] -- 751
			local cost = {} -- 752
			if r.cost.wood ~= nil then -- 753
				cost.wood = r.cost.wood -- 754
			end -- 754
			if r.cost.bell ~= nil then -- 756
				cost.bell = r.cost.bell -- 757
			end -- 757
			out[#out + 1] = { -- 759
				id = r.id, -- 760
				name = r.name, -- 761
				desc = r.desc, -- 762
				enhancedEffect = r.enhancedEffect, -- 763
				cost = cost, -- 764
				crafted = self.run.story.craftedWeapon == r.id -- 765
			} -- 765
			i = i + 1 -- 750
		end -- 750
	end -- 750
	if self.archive.artifactOwned then -- 769
		out[#out + 1] = { -- 770
			id = ARTIFACT_WEAPON_ID, -- 771
			name = weaponNameOf(ARTIFACT_WEAPON_ID), -- 772
			desc = "井底拾取彩蛋 · 男主线移动留下冷白微金轨迹残影", -- 773
			enhancedEffect = "light", -- 774
			cost = {}, -- 775
			crafted = true -- 776
		} -- 776
	end -- 776
	return out -- 779
end -- 747
function Play.prototype.syncCraftBench(self) -- 783
	local view = self.craftBench -- 784
	local inv = self.run.inventory -- 785
	view.inventory = { -- 786
		wood = inv.wood, -- 786
		bell = inv.bell, -- 786
		scrap = inv.scrap, -- 786
		wedge = inv.wedge, -- 786
		ammo = inv.ammo -- 786
	} -- 786
	view.recipes = self:recipeViews() -- 787
	view.equippedWeapon = self.equippedWeapon -- 788
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 789
	if view.justCraftedTimer > 0 then -- 790
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 791
	end -- 791
end -- 783
function Play.prototype.openCraftBench(self) -- 796
	if self.room.key ~= "escort3" or self.craftBench.active then -- 797
		return -- 798
	end -- 798
	self.craftBench.active = true -- 800
	self.carryOn = false -- 801
	self.run.story.carry = false -- 802
	self.player.vx = 0 -- 803
	self.player.vy = 0 -- 804
	self.craftBench.justCraftedTimer = 0 -- 805
	self:syncCraftBench() -- 806
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 807
	self:log("开工台") -- 808
	self:emit( -- 809
		"benchOpen", -- 809
		{ -- 809
			recipes = __TS__ArrayMap( -- 810
				self.craftBench.recipes, -- 810
				function(____, r) return r.id end -- 810
			), -- 810
			inventory = self.craftBench.inventory, -- 811
			carry = self.carryOn -- 812
		} -- 812
	) -- 812
end -- 796
function Play.prototype.closeCraftBench(self) -- 817
	if not self.craftBench.active then -- 818
		return -- 819
	end -- 819
	self.craftBench.active = false -- 821
	self.craftBench.justCraftedTimer = 0 -- 822
	self.carryOn = true -- 823
	self.run.story.carry = true -- 824
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 825
	self:log("离站背起") -- 826
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 827
end -- 817
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 834
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 835
		return false -- 836
	end -- 836
	local recipe = findRecipe(recipeId) -- 838
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 839
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 840
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 841
		return false -- 842
	end -- 842
	local missing = missingMaterials(self.run.inventory, recipe) -- 844
	if #missing > 0 then -- 845
		self:flashSet( -- 846
			"缺料 · " .. table.concat(missing, " / "), -- 846
			1.6 -- 846
		) -- 846
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 847
		return false -- 848
	end -- 848
	payMaterials(self.run.inventory, recipe) -- 850
	self.handledCraftRequests[requestId] = true -- 851
	self.run.story.craftedWeapon = recipe.id -- 852
	self.run.story.equippedWeapon = recipe.id -- 853
	self.equippedWeapon = recipe.id -- 854
	self.sessionDirty = true -- 855
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 856
	self.craftBench.firstCraftDone = true -- 857
	self:syncCraftBench() -- 858
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 859
	self:log("改制 " .. recipe.id) -- 860
	self:emit("benchCraft", { -- 861
		recipeId = recipe.id, -- 862
		weapon = recipe.id, -- 863
		effect = recipe.enhancedEffect, -- 864
		wood = self.run.inventory.wood, -- 865
		bell = self.run.inventory.bell -- 866
	}) -- 866
	return true -- 868
end -- 834
function Play.prototype.equipWeapon(self, weaponId) -- 872
	local artifactOk = weaponId == ARTIFACT_WEAPON_ID and self.archive.artifactOwned -- 873
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId and not artifactOk then -- 874
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 875
		return false -- 876
	end -- 876
	self.equippedWeapon = weaponId -- 878
	self.run.story.equippedWeapon = weaponId -- 879
	self.sessionDirty = true -- 880
	self:syncCraftBench() -- 881
	self:flashSet( -- 882
		"已装备 " .. weaponNameOf(weaponId), -- 882
		1 -- 882
	) -- 882
	self:emit("benchEquip", {weapon = weaponId}) -- 883
	return true -- 884
end -- 872
function Play.prototype.toggleArtifactWeapon(self) -- 888
	if not self.archive.artifactOwned or self.childMode then -- 889
		return false -- 890
	end -- 890
	if self.equippedWeapon == ARTIFACT_WEAPON_ID then -- 892
		local fallback = self.run.story.craftedWeapon ~= "" and self.run.story.craftedWeapon or "standard_gun" -- 893
		return self:equipWeapon(fallback) -- 894
	end -- 894
	return self:equipWeapon(ARTIFACT_WEAPON_ID) -- 896
end -- 888
function Play.prototype.exportSession(self) -- 900
	self:syncStory() -- 901
	local story = self.run.story -- 902
	local inv = self.run.inventory -- 903
	local taken = {} -- 904
	for k in pairs(self.run.taken) do -- 905
		if self.run.taken[k] == true then -- 906
			taken[#taken + 1] = k -- 907
		end -- 907
	end -- 907
	local segments = {} -- 910
	for k in pairs(story.segments) do -- 911
		if story.segments[k] == true then -- 912
			segments[#segments + 1] = k -- 913
		end -- 913
	end -- 913
	local props = {} -- 916
	for k in pairs(self.run.props) do -- 917
		local st = self.run.props[k] -- 918
		if st ~= nil then -- 919
			props[#props + 1] = (((((((k .. ":") .. (st.broken and "1" or "0")) .. ":") .. tostring(math.floor(st.hp + 0.5))) .. ":") .. (st.wedge and "1" or "0")) .. ":") .. (st.revealed == true and "1" or "0") -- 920
		end -- 920
	end -- 920
	return { -- 929
		roomKey = self.room.key, -- 930
		checkpoint = self.checkpoint, -- 931
		seed = self.run.seed, -- 932
		route = story.route, -- 933
		hp = story.hp, -- 934
		maxHp = story.maxHp, -- 935
		hpAtGate = story.hpAtGate, -- 936
		maxHpAtGate = story.maxHpAtGate, -- 937
		settled = story.settled, -- 938
		phase = self.phase, -- 939
		countTick = story.countTick, -- 940
		phaseTick = story.phaseTick, -- 941
		handTicks = story.handTicks, -- 942
		handDone = story.handDone, -- 943
		lineSaid = story.lineSaid, -- 944
		tied = story.tied, -- 945
		carry = story.carry, -- 946
		escortDone = story.escortDone, -- 947
		craftedWeapon = story.craftedWeapon, -- 948
		equippedWeapon = self.equippedWeapon, -- 949
		wood = inv.wood, -- 950
		bell = inv.bell, -- 951
		scrap = inv.scrap, -- 952
		wedge = inv.wedge, -- 953
		ammo = inv.ammo, -- 954
		shield = inv.shield, -- 955
		pass = inv.pass, -- 956
		quickbelt = inv.quickbelt, -- 957
		taken = taken, -- 958
		segments = segments, -- 959
		cartAxle = self.cartAxle, -- 960
		cartDocked = self.cartDocked, -- 961
		campaignRoute = self.run.route, -- 962
		joined = self.run.joined, -- 963
		c1Latch = self.run.c1Latch, -- 964
		c2Latch = self.run.c2Latch, -- 965
		talentSeed = story.talents ~= nil and story.talents.randomState or 0, -- 966
		talentRoom = story.talents ~= nil and story.talents.room or "", -- 967
		talentOffers = story.talents ~= nil and __TS__ArraySlice(story.talents.offers) or ({}), -- 968
		talentVitality = story.talents ~= nil and story.talents.ranks.vitality or 0, -- 969
		talentReload = story.talents ~= nil and story.talents.ranks.reload or 0, -- 970
		talentGuard = story.talents ~= nil and story.talents.ranks.guard or 0, -- 971
		talentCraft = story.talents ~= nil and story.talents.ranks.craft or 0, -- 972
		props = props, -- 973
		playerX = self.player.x, -- 974
		playerY = self.player.y, -- 975
		playerDepth = self.player.depth, -- 976
		gateTick = self.gateTick, -- 977
		hasBottle = self.hasBottle, -- 978
		villagePassed = self.passed -- 979
	} -- 979
end -- 900
function Play.prototype.submitFeIntent(self, intent) -- 987
	local kind = intent == nil and "" or intent.kind -- 988
	if kind == "gateReunionHold" then -- 989
		if self.room.key ~= "gate" or self.phase ~= "gate-wait" and self.phase ~= "gate-count" then -- 990
			return false -- 991
		end -- 991
		local holding = intent.holding == true -- 993
		self.intentGateReunionHold = holding -- 994
		if not holding and self.phase == "gate-wait" then -- 995
			if self.handTicks > 0 then -- 996
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 997
			end -- 997
			self.handTicks = 0 -- 999
			self.handArmed = true -- 1000
		end -- 1000
		return true -- 1002
	end -- 1002
	if kind == "reloadOpen" then -- 1004
		local camp = self.room.campaign -- 1005
		if self.run.trial ~= nil or camp == nil or camp.reloadPuzzle ~= true or self.reloadOpen then -- 1006
			return false -- 1007
		end -- 1007
		self:beginReload() -- 1009
		return self.reloadOpen -- 1010
	end -- 1010
	if kind == "reloadPathPreview" then -- 1012
		local path = intent.path -- 1013
		return type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) -- 1014
	end -- 1014
	if kind == "reloadTapNode" then -- 1016
		local node = intent.node -- 1017
		if type(node) == "number" then -- 1018
			self:reloadTapNode(node) -- 1019
			return true -- 1020
		end -- 1020
		return false -- 1022
	end -- 1022
	if kind == "reloadPathCommit" then -- 1024
		local path = intent.path -- 1025
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 1026
			local list = path -- 1027
			local i = 0 -- 1028
			do -- 1028
				i = 0 -- 1029
				while i < #list do -- 1029
					do -- 1029
						if i == 0 and list[i + 1] == RELOAD_START then -- 1030
							goto __continue70 -- 1031
						end -- 1031
						self:reloadTapNode(list[i + 1]) -- 1033
					end -- 1033
					::__continue70:: -- 1033
					i = i + 1 -- 1029
				end -- 1029
			end -- 1029
			return true -- 1035
		end -- 1035
		return false -- 1037
	end -- 1037
	if kind == "reloadCancel" then -- 1039
		self:closeReloadPuzzle() -- 1040
		return true -- 1041
	end -- 1041
	if kind == "craftSubmit" then -- 1043
		local recipeId = intent.recipeId -- 1044
		local requestId = intent.requestId -- 1045
		if type(recipeId) == "string" and type(requestId) == "string" then -- 1046
			return self:craftAtBench(recipeId, requestId) -- 1047
		end -- 1047
		return false -- 1049
	end -- 1049
	if kind == "craftEquip" then -- 1051
		local weaponId = intent.weaponId -- 1052
		if type(weaponId) == "string" then -- 1053
			return self:equipWeapon(weaponId) -- 1054
		end -- 1054
		return false -- 1056
	end -- 1056
	if kind == "craftClose" then -- 1058
		self:closeCraftBench() -- 1059
		return true -- 1060
	end -- 1060
	if kind == "chooseTalent" then -- 1062
		local slot = intent.slot -- 1063
		if type(slot) == "number" then -- 1064
			return self:chooseTalent(slot) -- 1065
		end -- 1065
		return false -- 1067
	end -- 1067
	if kind == "wellPick" then -- 1069
		return self:pickWell() -- 1070
	end -- 1070
	if kind == "museumInteract" then -- 1072
		local target = type(intent.target) == "string" and intent.target or "" -- 1073
		if target == "well_pickup" or target == "well" then -- 1074
			return self:pickWell() -- 1075
		end -- 1075
		if self.room.key ~= "museum" then -- 1077
			return false -- 1078
		end -- 1078
		return self:triggerMuseumIntent(target) -- 1080
	end -- 1080
	return false -- 1082
end -- 987
function Play.prototype.triggerMuseumIntent(self, target) -- 1086
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 1087
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 1090
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 1091
	if self.phase == "museum-cabinet" then -- 1092
		if target == "enter_hall" or (target == "" or target == "cabinet" or target == "weapon_case") and atCase then -- 1093
			self.pendingMuseumIntentTarget = "cabinet" -- 1094
			return true -- 1095
		end -- 1095
	end -- 1095
	if self.phase == "museum-hall" then -- 1098
		if (target == "lamp_turn" or target == "lamp" or target == "west_lamp") and nearLamp then -- 1099
			self.pendingMuseumIntentTarget = "lamp_direct" -- 1100
			return true -- 1101
		end -- 1101
		if (target == "" or target == "hall" or target == "corridor") and self.player.x >= self.ox + mu.hallX then -- 1103
			self.pendingMuseumIntentTarget = "hall" -- 1104
			return true -- 1105
		end -- 1105
	end -- 1105
	if self.phase == "museum-lamp" and (target == "" or target == "lamp" or target == "west_lamp" or target == "lamp_turn") and nearLamp then -- 1108
		self.pendingMuseumIntentTarget = "lamp" -- 1111
		return true -- 1112
	end -- 1112
	if self.phase == "museum-return" then -- 1114
		if target == "begin_return_cabinet" or (target == "" or target == "return_cabinet" or target == "cabinet" or target == "return") and atCase then -- 1115
			self.pendingMuseumIntentTarget = "return_cabinet" -- 1117
			return true -- 1118
		end -- 1118
	end -- 1118
	if self.phase == "museum-done" and (target == "" or target == "return_cabinet" or target == "return") then -- 1121
		self.pendingMuseumIntentTarget = "done" -- 1122
		return true -- 1123
	end -- 1123
	return false -- 1125
end -- 1086
function Play.prototype.captureCheckpoint(self, id) -- 1129
	local inv = self.run.inventory -- 1130
	self.checkpointSnap = { -- 1131
		id = id, -- 1132
		wood = inv.wood, -- 1133
		bell = inv.bell, -- 1134
		scrap = inv.scrap, -- 1135
		wedge = inv.wedge, -- 1136
		ammo = inv.ammo, -- 1137
		shield = inv.shield, -- 1138
		pass = inv.pass, -- 1139
		quickbelt = inv.quickbelt, -- 1140
		crafted = self.run.story.craftedWeapon, -- 1141
		equipped = self.equippedWeapon, -- 1142
		carry = self.carryOn -- 1143
	} -- 1143
	self.run.story.cp = self.checkpointSnap -- 1145
end -- 1129
function Play.prototype.applyCheckpointSnap(self, id) -- 1149
	local snap = self.run.story.cp -- 1150
	if snap == nil or snap.id ~= id then -- 1151
		return false -- 1152
	end -- 1152
	self.checkpointSnap = snap -- 1154
	local inv = self.run.inventory -- 1155
	inv.wood = snap.wood -- 1156
	inv.bell = snap.bell -- 1157
	inv.scrap = snap.scrap -- 1158
	inv.wedge = snap.wedge -- 1159
	inv.ammo = snap.ammo -- 1160
	inv.shield = snap.shield -- 1161
	inv.pass = snap.pass -- 1162
	inv.quickbelt = snap.quickbelt -- 1163
	self.run.story.craftedWeapon = snap.crafted -- 1164
	self.equippedWeapon = snap.equipped -- 1165
	self.run.story.equippedWeapon = snap.equipped -- 1166
	self.carryOn = snap.carry -- 1167
	self.run.story.carry = snap.carry -- 1168
	self.craftBench.active = false -- 1169
	self:syncCraftBench() -- 1170
	return true -- 1171
end -- 1149
function Play.prototype.restoreStory(self) -- 1174
	if self.isCampaign and self.run.trial ~= nil then -- 1177
		return -- 1178
	end -- 1178
	local story = self.run.story -- 1180
	if story == nil then -- 1181
		return -- 1182
	end -- 1182
	if story.maxHp > 0 then -- 1184
		self.maxHp = story.maxHp -- 1185
		self.hp = math.max( -- 1186
			1, -- 1186
			math.min(story.hp, story.maxHp) -- 1186
		) -- 1186
	end -- 1186
	self.storyRoute = story.route -- 1188
	self.storySettled = story.settled -- 1189
	self.hpAtGate = story.hpAtGate -- 1190
	self.maxHpAtGate = story.maxHpAtGate -- 1191
	self.handDone = story.handDone -- 1192
	self.lineSaid = story.lineSaid -- 1193
	self.tied = story.handDone -- 1194
	self.carryOn = story.carry or story.route == "soldier" and self.room.key == "escort1" -- 1195
	self.museumReturn = story.museumReturn -- 1196
	story.museumReturn = false -- 1197
	self.escortDone = story.escortDone -- 1198
	local savedEq = story.equippedWeapon -- 1199
	if savedEq == ARTIFACT_WEAPON_ID and self.archive.artifactOwned then -- 1200
		self.equippedWeapon = ARTIFACT_WEAPON_ID -- 1201
	elseif savedEq == "standard_gun" or savedEq ~= "" and savedEq == story.craftedWeapon then -- 1202
		self.equippedWeapon = savedEq -- 1203
	else -- 1203
		self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 1205
	end -- 1205
	self:syncCraftBench() -- 1207
	if story.segments.outside_cart == true then -- 1209
		self.redCartPulled = true -- 1210
		local redBox = __TS__ArrayFind( -- 1211
			self.boxes, -- 1211
			function(____, b) return b.id == "outside_red_cart" end -- 1211
		) -- 1211
		if redBox ~= nil then -- 1212
			redBox.x0 = 430 -- 1213
			redBox.x1 = 474 -- 1214
		end -- 1214
		if self.room.key == "outside" and self.room.cart.bodyW > 0 then -- 1216
			self.cartAxle = self.room.cart.endX -- 1217
			self.cartDocked = true -- 1218
		end -- 1218
	end -- 1218
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 1221
	self.waterSeen = story.segments.water_lantern == true -- 1223
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 1225
		self:applyCheckpointSnap(self.checkpoint) -- 1226
	end -- 1226
	if self.room.key == "tower" and story.route == "soldier" then -- 1229
		self.carryOn = false -- 1230
		self.run.story.carry = false -- 1231
		self.player.w = SOLDIER_W -- 1232
		self.player.h = SOLDIER_H -- 1233
		self.player.x = math.max(self.ox + 422, self.player.x) -- 1234
		self.partner = { -- 1235
			x = math.max(self.ox + 408, self.player.x - 24), -- 1236
			y = 0, -- 1237
			depth = 0, -- 1238
			depthSpeed = 0, -- 1239
			vx = 0, -- 1240
			vy = 0, -- 1241
			w = CHILD_W, -- 1242
			h = CHILD_H, -- 1243
			onGround = true, -- 1244
			facing = 1, -- 1245
			crouch = false, -- 1246
			rollT = 0, -- 1247
			covered = false, -- 1248
			alive = true -- 1249
		} -- 1249
	end -- 1249
	if self.room.key == "tower" then -- 1253
		if story.segments.tower_door == true then -- 1254
			self:openTowerDoor() -- 1255
		end -- 1255
		self.towerHanded = story.segments.tower_handover == true -- 1257
		self.deskHold = 0 -- 1258
		if story.phase == "tower-enter" or story.phase == "tower-desk" or story.phase == "tower-given" then -- 1259
			self.phase = story.phase -- 1260
			self.phaseTick = 0 -- 1261
			if story.phase == "tower-desk" or story.phase == "tower-given" then -- 1262
				self.player.x = self.ox + 605 -- 1263
				self.player.y = 0 -- 1264
				if story.route == "soldier" and self.partner.alive then -- 1265
					self.partner.x = self.ox + 568 -- 1266
					self.partner.y = 0 -- 1267
					self.partner.facing = 1 -- 1268
				end -- 1268
			end -- 1268
		end -- 1268
	end -- 1268
	if self.room.key == "prologue" then -- 1274
		local ph = story.phase -- 1275
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 1276
			self.phase = ph -- 1277
			self.phaseTick = story.phaseTick -- 1278
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 1279
			self.player.y = 0 -- 1280
			self.player.depth = 0 -- 1281
			self.player.vx = 0 -- 1282
			self.partner.x = self.ox + 300 -- 1283
			self.partner.y = 0 -- 1284
			self.partner.depth = 0 -- 1285
			self.partner.vx = 0 -- 1286
			self.partner.alive = true -- 1287
			if ph == "prologue-follow" then -- 1288
				self.partner.crouch = false -- 1289
				self.partner.h = CHILD_H -- 1290
			else -- 1290
				self.partner.crouch = true -- 1292
				self.partner.h = CHILD_CROUCH_H -- 1293
			end -- 1293
			self.cam.x = self.player.x -- 1295
		end -- 1295
		return -- 1297
	end -- 1297
	if self.room.key ~= "gate" then -- 1299
		return -- 1300
	end -- 1300
	local ____temp_0 -- 1302
	if self.room.story == nil then -- 1302
		____temp_0 = nil -- 1302
	else -- 1302
		____temp_0 = self.room.story.gate -- 1302
	end -- 1302
	local g = ____temp_0 -- 1302
	if g == nil then -- 1303
		return -- 1304
	end -- 1304
	if story.phase == "gate-send" then -- 1307
		self.phase = "gate-send" -- 1308
		self.gateTick = g.holdTicks -- 1309
		self.gateSpawned = 4 -- 1310
		self.enemies = {} -- 1311
		self.player.x = self.ox + g.doorX - 40 -- 1312
		self.player.y = 0 -- 1313
		self.player.depth = 0 -- 1314
		self.player.vx = 0 -- 1315
		self.player.vy = 0 -- 1316
		self.player.onGround = true -- 1317
		self.partner.x = self.ox + g.waitX -- 1318
		self.partner.y = 0 -- 1319
		self.partner.depth = 0 -- 1320
		self.partner.alive = true -- 1321
		self.cam.x = self.player.x -- 1322
		self.handTicks = 0 -- 1323
		self.handArmed = false -- 1324
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1325
		return -- 1326
	end -- 1326
	if not story.settled then -- 1328
		return -- 1329
	end -- 1329
	self.gateTick = g.holdTicks -- 1332
	self.gateSpawned = 4 -- 1333
	self.enemies = {} -- 1334
	if story.phase == "gate-count" or story.phase == "gate-walk" then -- 1335
		self.phase = story.phase -- 1336
		self.countTick = math.max(story.countTick, 0) -- 1337
		self:swapToChild(g.doorX + 30) -- 1338
		self.countPrevMove = 0 -- 1339
		self.countArmed = false -- 1340
		return -- 1341
	end -- 1341
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1343
		self.phase = story.phase -- 1344
		self.countTick = ____exports.GATE_COUNT_END -- 1345
		self.phaseTick = story.phaseTick -- 1346
		self:swapToChild(g.doorX + 30) -- 1347
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1348
			0, -- 1348
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1348
		) -- 1348
		self.handArmed = false -- 1349
	end -- 1349
end -- 1174
function Play.prototype.buildWorld(self) -- 1354
	local room = self.room -- 1355
	self.boxes = {} -- 1356
	self.floors = {} -- 1357
	local i = 0 -- 1358
	do -- 1358
		i = 0 -- 1359
		while i < #room.floors do -- 1359
			local f = room.floors[i + 1] -- 1360
			local ____self_floors_1 = self.floors -- 1361
			____self_floors_1[#____self_floors_1 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1361
			i = i + 1 -- 1359
		end -- 1359
	end -- 1359
	do -- 1359
		i = 0 -- 1363
		while i < #room.solids do -- 1363
			local s = room.solids[i + 1] -- 1364
			if not s.decorative then -- 1365
				local ____self_boxes_13 = self.boxes -- 1370
				local ____s_x_4 = s.x -- 1371
				local ____temp_5 = s.x + s.w -- 1371
				local ____s_y_6 = s.y -- 1371
				local ____temp_7 = s.y + s.h -- 1371
				local ____temp_2 -- 1372
				if room.depth == nil then -- 1372
					____temp_2 = nil -- 1372
				else -- 1372
					____temp_2 = s.depth -- 1372
				end -- 1372
				local ____temp_8 = s.passable == true -- 1373
				local ____s_label_9 = s.label -- 1373
				local ____s_id_10 = s.id -- 1374
				local ____temp_11 = s.soft == true -- 1374
				local ____temp_12 = s.hidden == true -- 1374
				local ____temp_3 -- 1375
				if s.breakable == nil then -- 1375
					____temp_3 = nil -- 1375
				else -- 1375
					____temp_3 = __TS__ObjectAssign({}, s.breakable) -- 1375
				end -- 1375
				____self_boxes_13[#____self_boxes_13 + 1] = { -- 1370
					x0 = ____s_x_4, -- 1371
					x1 = ____temp_5, -- 1371
					y0 = ____s_y_6, -- 1371
					y1 = ____temp_7, -- 1371
					depth = ____temp_2, -- 1372
					passable = ____temp_8, -- 1373
					label = ____s_label_9, -- 1373
					id = ____s_id_10, -- 1374
					soft = ____temp_11, -- 1374
					hidden = ____temp_12, -- 1374
					breakable = ____temp_3, -- 1375
					interact = s.interact -- 1376
				} -- 1376
			end -- 1376
			i = i + 1 -- 1363
		end -- 1363
	end -- 1363
	do -- 1363
		i = 0 -- 1380
		while i < #room.stairs do -- 1380
			local st = room.stairs[i + 1] -- 1381
			local n = st.steps + 1 -- 1382
			local stepW = (st.x1 - st.x0) / n -- 1383
			local k = 0 -- 1384
			do -- 1384
				k = 0 -- 1385
				while k < n do -- 1385
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1386
					local x0 = st.x0 + stepW * k -- 1387
					local ____self_boxes_17 = self.boxes -- 1390
					local ____temp_15 = x0 + stepW -- 1391
					local ____temp_16 = -8 -- 1391
					local ____temp_14 -- 1392
					if room.depth == nil then -- 1392
						____temp_14 = nil -- 1392
					else -- 1392
						____temp_14 = st.depth -- 1392
					end -- 1392
					____self_boxes_17[#____self_boxes_17 + 1] = { -- 1390
						x0 = x0, -- 1391
						x1 = ____temp_15, -- 1391
						y0 = ____temp_16, -- 1391
						y1 = y, -- 1391
						depth = ____temp_14, -- 1392
						passable = true -- 1393
					} -- 1393
					k = k + 1 -- 1385
				end -- 1385
			end -- 1385
			i = i + 1 -- 1380
		end -- 1380
	end -- 1380
end -- 1354
function Play.prototype.setupCampaign(self) -- 1403
	local wr = self.room -- 1404
	local c = wr.campaign -- 1405
	if c == nil then -- 1406
		return -- 1407
	end -- 1407
	self.roomStartTick = self.run.ticks -- 1409
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1411
		self.run.joined = true -- 1413
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1414
		local ____self_run_22 = self.run -- 1416
		local ____temp_21 -- 1416
		if wr.key == "s2-drygoods" then -- 1416
			local ____temp_20 = self.run.route ~= "drygoods" -- 1417
			if not ____temp_20 then -- 1417
				local ____opt_18 = self.run.props.s2_board -- 1417
				____temp_20 = (____opt_18 and ____opt_18.broken) == true -- 1417
			end -- 1417
			____temp_21 = ____temp_20 -- 1417
		else -- 1417
			____temp_21 = wr.key == "c1-yard" and self.run.c1Latch -- 1418
		end -- 1418
		____self_run_22.joined = ____temp_21 -- 1416
	end -- 1416
	local x = wr.minX + 60 -- 1420
	local y = 0 -- 1421
	local depth = 0 -- 1422
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1423
		x = wr.minX + 210 -- 1424
		depth = -32 -- 1425
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1426
		x = wr.minX + 40 -- 1427
		y = 32 -- 1428
		depth = 32 -- 1429
	end -- 1429
	self.player = { -- 1431
		x = x, -- 1432
		y = y, -- 1432
		depth = depth, -- 1432
		depthSpeed = 0, -- 1432
		vx = 0, -- 1432
		vy = 0, -- 1432
		w = SOLDIER_W, -- 1433
		h = SOLDIER_H, -- 1433
		onGround = y <= 0, -- 1433
		facing = 1, -- 1433
		crouch = false, -- 1433
		rollT = 0, -- 1433
		covered = false, -- 1433
		alive = true -- 1433
	} -- 1433
	self.partner = { -- 1435
		x = x + 60, -- 1436
		y = y, -- 1436
		depth = depth, -- 1436
		depthSpeed = 0, -- 1436
		vx = 0, -- 1436
		vy = 0, -- 1436
		w = CHILD_W, -- 1437
		h = CHILD_H, -- 1437
		onGround = y <= 0, -- 1437
		facing = 1, -- 1437
		crouch = false, -- 1437
		rollT = 0, -- 1437
		covered = false, -- 1437
		alive = true -- 1437
	} -- 1437
	self.cam.x = x -- 1439
	self.cam.y = y + CAM_LOOK_UP -- 1440
	self.phase = "run" -- 1441
	self.hp = self.maxHp -- 1442
	local trial = self.run.trial -- 1443
	if trial ~= nil then -- 1444
		draftRoom(trial, wr.key) -- 1445
		self.maxHp = self.maxHp + trial.ranks.vitality -- 1446
		self.hp = trial.hp -- 1447
	elseif self:isEscortRoom() and self.run.story.route == "soldier" then -- 1448
		if self.run.story.talents == nil then -- 1450
			self.run.story.talents = createStoryTalents(self.run.seed) -- 1451
		end -- 1451
		draftTalentOffers(self.run.story.talents, wr.key) -- 1453
	end -- 1453
	self:buildEnemies() -- 1455
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1456
	local i = 0 -- 1457
	do -- 1457
		i = 0 -- 1458
		while i < #self.boxes do -- 1458
			do -- 1458
				local b = self.boxes[i + 1] -- 1459
				if b.id == nil then -- 1460
					goto __continue145 -- 1461
				end -- 1461
				local st = self.run.props[b.id] -- 1463
				if st ~= nil then -- 1464
					b.broken = st.broken -- 1465
					local ____temp_23 -- 1466
					if b.breakable == nil then -- 1466
						____temp_23 = nil -- 1466
					else -- 1466
						____temp_23 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1466
					end -- 1466
					b.breakable = ____temp_23 -- 1466
					b.hidden = b.hidden == true and st.revealed ~= true -- 1467
					if b.hidden then -- 1468
						b.broken = true -- 1469
					end -- 1469
				elseif b.hidden == true then -- 1471
					b.broken = true -- 1473
				end -- 1473
			end -- 1473
			::__continue145:: -- 1473
			i = i + 1 -- 1458
		end -- 1458
	end -- 1458
	if wr.cart.bodyW > 0 then -- 1476
		self.cartAxle = wr.cart.startX -- 1477
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1478
			self.cartAxle = wr.cart.endX -- 1479
			self.cartDocked = true -- 1480
		end -- 1480
	end -- 1480
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1483
end -- 1403
function Play.prototype.log(self, line) -- 1486
	local ____self_run_log_24 = self.run.log -- 1487
	____self_run_log_24[#____self_run_log_24 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1487
	if #self.run.log > 120 then -- 1488
		table.remove(self.run.log, 1) -- 1489
	end -- 1489
end -- 1486
function Play.prototype.buildEnemies(self) -- 1493
	self.enemies = {} -- 1494
	if self.isCampaign then -- 1495
		local i = 0 -- 1496
		do -- 1496
			i = 0 -- 1497
			while i < #self.room.spawns do -- 1497
				local sp = self.room.spawns[i + 1] -- 1498
				local kind = sp.kind or "gunner" -- 1499
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1500
				local ____self_enemies_25 = self.enemies -- 1501
				____self_enemies_25[#____self_enemies_25 + 1] = { -- 1501
					x = sp.x, -- 1502
					y = sp.y, -- 1502
					depth = sp.depth, -- 1502
					w = 26, -- 1502
					h = sp.h, -- 1502
					alive = true, -- 1502
					hitT = 0, -- 1502
					warnT = 0, -- 1502
					fireCd = 40, -- 1502
					kind = kind, -- 1503
					shieldHp = hp, -- 1503
					shieldHpMax = hp, -- 1503
					drop = sp.drop or "none", -- 1503
					homeX = sp.x, -- 1504
					swingT = 0, -- 1504
					awake = false, -- 1504
					squad = i -- 1504
				} -- 1504
				i = i + 1 -- 1497
			end -- 1497
		end -- 1497
		return -- 1507
	end -- 1507
	if self.room.key == "checkpoint" then -- 1509
		local ____self_enemies_26 = self.enemies -- 1510
		____self_enemies_26[#____self_enemies_26 + 1] = { -- 1510
			x = self.ox + 430, -- 1510
			y = 0, -- 1510
			w = 26, -- 1510
			h = 84, -- 1510
			alive = true, -- 1510
			hitT = 0, -- 1510
			warnT = 0, -- 1510
			fireCd = 0 -- 1510
		} -- 1510
		local ____self_enemies_27 = self.enemies -- 1511
		____self_enemies_27[#____self_enemies_27 + 1] = { -- 1511
			x = self.ox + 505, -- 1511
			y = 0, -- 1511
			w = 26, -- 1511
			h = 84, -- 1511
			alive = true, -- 1511
			hitT = 0, -- 1511
			warnT = 0, -- 1511
			fireCd = 0 -- 1511
		} -- 1511
		return -- 1512
	end -- 1512
	if self.room.key == "street" then -- 1514
		local ____self_enemies_28 = self.enemies -- 1516
		____self_enemies_28[#____self_enemies_28 + 1] = { -- 1516
			x = self.ox + 340, -- 1516
			y = 0, -- 1516
			w = 26, -- 1516
			h = 84, -- 1516
			alive = true, -- 1516
			hitT = 0, -- 1516
			warnT = 0, -- 1516
			fireCd = 0 -- 1516
		} -- 1516
		local ____self_enemies_29 = self.enemies -- 1517
		____self_enemies_29[#____self_enemies_29 + 1] = { -- 1517
			x = self.ox + 560, -- 1517
			y = 0, -- 1517
			w = 26, -- 1517
			h = 84, -- 1517
			alive = true, -- 1517
			hitT = 0, -- 1517
			warnT = 0, -- 1517
			fireCd = 0 -- 1517
		} -- 1517
	end -- 1517
end -- 1493
function Play.prototype.emit(self, name, data) -- 1523
	local ____self_events_30 = self.events -- 1524
	____self_events_30[#____self_events_30 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1524
	self.eventSeq = self.eventSeq + 1 -- 1525
	if #self.events > 256 then -- 1526
		table.remove(self.events, 1) -- 1527
	end -- 1527
end -- 1523
function Play.prototype.drainEvents(self) -- 1535
	local out = self.events -- 1536
	self.events = {} -- 1537
	return out -- 1538
end -- 1535
function Play.prototype.adoptEvents(self, events) -- 1547
	if #events == 0 then -- 1548
		return -- 1549
	end -- 1549
	local keep = {} -- 1551
	local i = 0 -- 1552
	do -- 1552
		i = 0 -- 1553
		while i < #events do -- 1553
			do -- 1553
				local e = events[i + 1] -- 1554
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1555
					goto __continue166 -- 1556
				end -- 1556
				keep[#keep + 1] = e -- 1558
			end -- 1558
			::__continue166:: -- 1558
			i = i + 1 -- 1553
		end -- 1553
	end -- 1553
	if #keep == 0 then -- 1560
		return -- 1561
	end -- 1561
	self.events = __TS__ArrayConcat(keep, self.events) -- 1563
	do -- 1563
		i = 0 -- 1564
		while i < #self.events do -- 1564
			self.events[i + 1].seq = i -- 1565
			i = i + 1 -- 1564
		end -- 1564
	end -- 1564
	self.eventSeq = #self.events -- 1567
end -- 1547
function Play.prototype.talentRank(self, talent) -- 1570
	if self.run.trial ~= nil then -- 1571
		return self.run.trial.ranks[talent] -- 1572
	end -- 1572
	if self.storyRoute == "soldier" and self:isEscortRoom() and self.run.story.talents ~= nil then -- 1574
		return self.run.story.talents.ranks[talent] -- 1575
	end -- 1575
	return 0 -- 1577
end -- 1570
function Play.prototype.getStoryTalentOffers(self) -- 1581
	if self.run.trial ~= nil or self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1582
		return {} -- 1583
	end -- 1583
	local st = self.run.story.talents -- 1585
	return st ~= nil and st.room == self.room.key and st.offers or ({}) -- 1586
end -- 1581
function Play.prototype.getStoryTalentRanks(self) -- 1590
	if self.run.trial ~= nil or self.storyRoute ~= "soldier" or not self:isEscortRoom() then -- 1591
		return nil -- 1592
	end -- 1592
	return self.run.story.talents ~= nil and self.run.story.talents.ranks or nil -- 1594
end -- 1590
function Play.prototype.chooseTalent(self, slot) -- 1597
	local trial = self.run.trial -- 1598
	if trial ~= nil then -- 1599
		local talent = trial.offers[slot + 1] -- 1600
		if talent == nil or trial.lost or self.run.finished then -- 1601
			return false -- 1601
		end -- 1601
		local ____trial_ranks_31, ____talent_32 = trial.ranks, talent -- 1602
		____trial_ranks_31[____talent_32] = ____trial_ranks_31[____talent_32] + 1 -- 1602
		trial.offers = {} -- 1603
		if talent == "vitality" then -- 1604
			self.maxHp = self.maxHp + 1 -- 1605
			self.hp = self.hp + 1 -- 1606
			trial.hp = self.hp -- 1607
		end -- 1607
		self:flashSet(talentNames[talent], 1.2) -- 1609
		return true -- 1610
	end -- 1610
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1612
		return false -- 1613
	end -- 1613
	local st = self.run.story.talents -- 1615
	local talent = st ~= nil and st.offers[slot + 1] or nil -- 1616
	if st == nil or talent == nil then -- 1617
		return false -- 1618
	end -- 1618
	local ____st_ranks_33, ____talent_34 = st.ranks, talent -- 1620
	____st_ranks_33[____talent_34] = ____st_ranks_33[____talent_34] + 1 -- 1620
	st.offers = {} -- 1621
	if talent == "vitality" then -- 1622
		self.maxHp = self.maxHp + 1 -- 1623
		self.hp = self.hp + 1 -- 1624
		self.run.story.maxHp = self.maxHp -- 1625
		self.run.story.hp = self.hp -- 1626
	end -- 1626
	self.sessionDirty = true -- 1628
	self:flashSet("本领 · " .. talentNames[talent], 1.4) -- 1629
	self:emit("storyBeat", {beat = "talent_picked", talent = talent, rank = st.ranks[talent], room = self.room.key}) -- 1630
	return true -- 1631
end -- 1597
function Play.prototype.beginReload(self) -- 1639
	self.reloadT = self:reloadTicks() -- 1640
	local camp = self.room.campaign -- 1641
	if self.run.trial == nil and camp ~= nil and camp.reloadPuzzle == true then -- 1643
		self:openReloadPuzzle() -- 1644
	end -- 1644
end -- 1639
function Play.prototype.openReloadPuzzle(self) -- 1649
	self.reloadOpen = true -- 1650
	self.reloadAnswerTicks = 0 -- 1651
	self.reloadWorldTicks = 0 -- 1652
	self.reloadPath = {RELOAD_START} -- 1653
	self.reloadPendingEffect = "" -- 1654
	self.reloadTryCount = self.reloadTryCount + 1 -- 1655
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 1656
end -- 1649
function Play.prototype.closeReloadPuzzle(self) -- 1660
	self.reloadOpen = false -- 1661
	self.reloadAnswerTicks = 0 -- 1662
	self.reloadWorldTicks = 0 -- 1663
	self.reloadPath = {RELOAD_START} -- 1664
	self.reloadPendingEffect = "" -- 1665
end -- 1660
function Play.prototype.reloadTapNode(self, node) -- 1672
	if not self.reloadOpen then -- 1673
		return -- 1674
	end -- 1674
	local path = self.reloadPath -- 1676
	local last = path[#path] -- 1677
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1678
		self.reloadPath = {RELOAD_START} -- 1679
		self:emit("reloadInvalid", {node = node, at = last}) -- 1680
		return -- 1681
	end -- 1681
	path[#path + 1] = node -- 1683
	if node ~= RELOAD_TARGET then -- 1684
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1685
		return -- 1686
	end -- 1686
	if not reloadPathValid(path) then -- 1688
		self.reloadPath = {RELOAD_START} -- 1689
		self:emit("reloadInvalid", {node = node, at = last}) -- 1690
		return -- 1691
	end -- 1691
	self.reloadPendingEffect = reloadEffectOf(path) -- 1693
	self.reloadOpen = false -- 1694
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1695
	self:flashSet( -- 1698
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1698
		1.4 -- 1698
	) -- 1698
end -- 1672
function Play.prototype.consumeReloadEffect(self) -- 1702
	local e = self.reloadPendingEffect -- 1703
	if e ~= "" then -- 1704
		self.reloadPendingEffect = "" -- 1705
	end -- 1705
	return e -- 1707
end -- 1702
function Play.prototype.echoToSource(self, from, count) -- 1714
	if count == nil then -- 1714
		count = 1 -- 1714
	end -- 1714
	local best = -1 -- 1715
	local bestD = 1000000000 -- 1716
	local i = 0 -- 1717
	local woken = {} -- 1718
	local n = 0 -- 1719
	while n < count do -- 1720
		best = -1 -- 1721
		bestD = 1000000000 -- 1722
		do -- 1722
			i = 0 -- 1723
			while i < #self.enemies do -- 1723
				do -- 1723
					if woken[i] == true then -- 1724
						goto __continue199 -- 1725
					end -- 1725
					local e = self.enemies[i + 1] -- 1727
					if not e.alive then -- 1728
						goto __continue199 -- 1729
					end -- 1729
					local d = math.abs(e.x - from.x) -- 1731
					if d < bestD then -- 1732
						bestD = d -- 1733
						best = i -- 1734
					end -- 1734
				end -- 1734
				::__continue199:: -- 1734
				i = i + 1 -- 1723
			end -- 1723
		end -- 1723
		if best < 0 then -- 1737
			break -- 1738
		end -- 1738
		woken[best] = true -- 1740
		local e = self.enemies[best + 1] -- 1741
		e.awake = true -- 1742
		e.warnT = 0 -- 1743
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1744
		n = n + 1 -- 1745
	end -- 1745
	if n == 0 then -- 1747
		return -- 1748
	end -- 1748
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1750
end -- 1714
function Play.prototype.reloadTicks(self) -- 1753
	return math.max( -- 1754
		6, -- 1754
		(self.run.inventory.quickbelt > 0 and 36 or 54) - 6 * self:talentRank("reload") -- 1754
	) -- 1754
end -- 1753
function Play.prototype.update(self, dt, input) -- 1757
	self:syncCraftBench() -- 1758
	local trial = self.run.trial -- 1759
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1760
		return -- 1760
	end -- 1760
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1761
		self:closeCraftBench() -- 1762
		return -- 1763
	end -- 1763
	if input.pause.pressed then -- 1765
		self.paused = not self.paused -- 1766
	end -- 1766
	if self.flashT > 0 then -- 1768
		self.flashT = self.flashT - dt -- 1769
		if self.flashT <= 0 then -- 1770
			self.flash = "" -- 1771
		end -- 1771
	end -- 1771
	if self.traceT > 0 then -- 1774
		self.traceT = self.traceT - dt -- 1775
		if self.traceT <= 0 then -- 1776
			self.trace = nil -- 1777
		end -- 1777
	end -- 1777
	if self.paused then -- 1780
		self:updateCamera(dt) -- 1781
		return -- 1782
	end -- 1782
	if self.craftBench.active then -- 1786
		self:updateCamera(dt) -- 1787
		return -- 1788
	end -- 1788
	if self.reloadOpen then -- 1793
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1794
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1795
			self.reloadOpen = false -- 1796
			self.reloadPendingEffect = "" -- 1797
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1798
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1799
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1800
			self:updateCamera(dt) -- 1801
			return -- 1802
		else -- 1802
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1804
		end -- 1804
	end -- 1804
	self.ticks = self.ticks + 1 -- 1808
	if self.invulnT > 0 then -- 1811
		self.invulnT = self.invulnT - 1 -- 1812
	end -- 1812
	if self.isCampaign then -- 1814
		local ____self_run_35, ____ticks_36 = self.run, "ticks" -- 1815
		____self_run_35[____ticks_36] = ____self_run_35[____ticks_36] + 1 -- 1815
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1816
	end -- 1816
	local p = self.player -- 1818
	self:stepPlayer(p, dt, input) -- 1819
	self:refreshCover(p, input) -- 1821
	if self.carryOn then -- 1822
		self:carryPose() -- 1823
	end -- 1823
	if self.isCampaign then -- 1825
		self:stepCampaign(dt, input) -- 1826
		if not self.carryOn then -- 1827
			self:stepCampaignPartner(dt) -- 1828
		end -- 1828
	end -- 1828
	if trial == nil or not self.run.finished then -- 1835
		self:stepEnemies(dt, input) -- 1836
	end -- 1836
	if trial ~= nil then -- 1838
		trial.hp = self.hp -- 1838
	end -- 1838
	if not self.isCampaign then -- 1839
		self:stepStory(dt, input) -- 1840
		self:stepEscort(dt, input) -- 1841
		self:stepVillage(dt, input) -- 1842
		self:stepChase(dt, input) -- 1843
		self:stepInteract(dt, input) -- 1844
	end -- 1844
	self:updateGate() -- 1846
	self:updateCamera(dt) -- 1847
	self:syncStory() -- 1849
end -- 1757
function Play.prototype.underLowArch(self, a) -- 1856
	local arch = self.room.arch -- 1857
	if arch.h <= 0 then -- 1858
		return false -- 1859
	end -- 1859
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1861
		return false -- 1862
	end -- 1862
	local top = arch.y + arch.h -- 1864
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1865
end -- 1856
function Play.prototype.coverAt(self, a) -- 1872
	local best = nil -- 1873
	local bestGap = 24 -- 1874
	local half = a.w / 2 -- 1875
	local i = 0 -- 1876
	do -- 1876
		i = 0 -- 1877
		while i < #self.boxes do -- 1877
			do -- 1877
				local b = self.boxes[i + 1] -- 1878
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1879
					goto __continue233 -- 1880
				end -- 1880
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1882
					goto __continue233 -- 1883
				end -- 1883
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1885
				if gap < bestGap then -- 1886
					bestGap = gap -- 1887
					best = b -- 1888
				end -- 1888
			end -- 1888
			::__continue233:: -- 1888
			i = i + 1 -- 1877
		end -- 1877
	end -- 1877
	return best -- 1891
end -- 1872
function Play.prototype.nearCover(self, a) -- 1894
	return self:coverAt(a) ~= nil -- 1895
end -- 1894
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1899
	if enemy == nil then -- 1900
		return false -- 1901
	end -- 1901
	local fromRight = enemy.x >= a.x -- 1903
	local edge = fromRight and b.x0 or b.x1 -- 1904
	local ____fromRight_37 -- 1905
	if fromRight then -- 1905
		____fromRight_37 = edge >= a.x - 0.001 and edge <= enemy.x -- 1905
	else -- 1905
		____fromRight_37 = edge <= a.x + 0.001 and edge >= enemy.x -- 1906
	end -- 1906
	local between = ____fromRight_37 -- 1905
	local separation = enemy.x - a.x -- 1907
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1908
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1909
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1910
end -- 1899
function Play.prototype.nearestEnemy(self, a) -- 1913
	local best -- 1914
	local bestD = 1000000000 -- 1915
	local i = 0 -- 1916
	do -- 1916
		i = 0 -- 1917
		while i < #self.enemies do -- 1917
			do -- 1917
				local e = self.enemies[i + 1] -- 1918
				if not e.alive then -- 1919
					goto __continue242 -- 1920
				end -- 1920
				local d = math.abs(e.x - a.x) -- 1922
				if d < bestD then -- 1923
					bestD = d -- 1924
					best = e -- 1925
				end -- 1925
			end -- 1925
			::__continue242:: -- 1925
			i = i + 1 -- 1917
		end -- 1917
	end -- 1917
	return best -- 1928
end -- 1913
function Play.prototype.refreshCover(self, a, input) -- 1932
	if self.childMode then -- 1933
		self.coverNear = false -- 1934
		self.coverHug = false -- 1935
		self.coverEntity = "" -- 1936
		self.coverBlocking = false -- 1937
		a.covered = false -- 1938
		return -- 1939
	end -- 1939
	local b = self:coverAt(a) -- 1941
	self.coverNear = b ~= nil -- 1942
	a.covered = self.coverNear and input.cover.held -- 1943
	self.coverHug = a.covered -- 1944
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1945
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1946
		b, -- 1946
		a, -- 1946
		self:nearestEnemy(a) -- 1946
	) -- 1946
end -- 1932
function Play.prototype.cartHandleInReach(self, a) -- 1950
	if a == nil then -- 1950
		a = self.player -- 1950
	end -- 1950
	local c = self.room.cart -- 1951
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1952
		return false -- 1953
	end -- 1953
	local handleX = self.cartAxle + c.handleOffset -- 1955
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1956
end -- 1950
function Play.prototype.nearLowLedge(self, a) -- 1961
	local reach = 26 -- 1962
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1963
	local x1 = x0 + reach -- 1964
	local i = 0 -- 1965
	do -- 1965
		i = 0 -- 1966
		while i < #self.boxes do -- 1966
			do -- 1966
				local b = self.boxes[i + 1] -- 1967
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1968
					goto __continue251 -- 1969
				end -- 1969
				local rise = b.y1 - a.y -- 1971
				if rise > 0 and rise <= LEDGE_RISE then -- 1972
					return true -- 1973
				end -- 1973
			end -- 1973
			::__continue251:: -- 1973
			i = i + 1 -- 1966
		end -- 1966
	end -- 1966
	return false -- 1976
end -- 1961
function Play.prototype.stepPlayer(self, a, dt, input) -- 1979
	a.depthSpeed = 0 -- 1980
	if not a.alive then -- 1981
		return -- 1982
	end -- 1982
	local isChild = self.childMode -- 1984
	local lowArch = isChild and self:underLowArch(a) -- 1986
	if self:storyLocked() then -- 1988
		a.vx = 0 -- 1989
		a.crouch = isChild and lowArch -- 1990
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1991
		self:fallY(a, dt) -- 1992
		return -- 1993
	end -- 1993
	if not isChild and self.escort.state == "calming" then -- 1996
		a.crouch = false -- 1997
		a.h = SOLDIER_H -- 1998
		a.vx = 0 -- 1999
		self:fallY(a, dt) -- 2000
		return -- 2001
	end -- 2001
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 2003
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 2004
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2005
	local nearCover = not isChild and self:nearCover(a) -- 2006
	a.covered = nearCover and input.cover.held -- 2007
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 2009
	if a.rollT > 0 then -- 2012
		a.rollT = a.rollT - dt -- 2013
		a.vx = a.facing * ROLL_SPEED -- 2014
		self:slideX(a, a.vx * dt) -- 2015
		self:fallY(a, dt) -- 2016
		if a.rollT <= 0 then -- 2017
			self:flashSet("翻滚结束", 0.5) -- 2018
		end -- 2018
		return -- 2020
	end -- 2020
	local peacefulRoom = self.room.key == "museum" or self.room.key == "tower" -- 2023
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 2024
		if input.moveX ~= 0 then -- 2025
			a.facing = input.moveX > 0 and 1 or -1 -- 2026
		end -- 2026
		if self:nearLowLedge(a) then -- 2029
			a.vy = SOLDIER_JUMP -- 2030
			a.onGround = false -- 2031
			self:flashSet("翻上去", 0.3) -- 2032
			return -- 2033
		end -- 2033
		a.rollT = ROLL_TIME -- 2035
		self:flashSet("翻滚", 0.3) -- 2036
		return -- 2037
	end -- 2037
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 2040
	if isChild then -- 2041
		if input.cover.held then -- 2042
			speed = CHILD_SLOW -- 2043
		end -- 2043
		if a.crouch then -- 2045
			speed = CHILD_SLOW -- 2046
		elseif self.room.key == "forest" and self.forestPath == "ditch" and a.x >= self.ox + 700 and a.x <= self.ox + 1140 then -- 2047
			speed = CHILD_SPEED * 1.22 -- 2050
		end -- 2050
	elseif a.covered then -- 2052
		speed = SOLDIER_SPEED * 0.45 -- 2053
	end -- 2053
	local handsBusy = self.gripping or gripIntent -- 2057
	local dir = self.gripping and 0 or input.moveX -- 2058
	local depthDir = self.room.depth ~= nil and not handsBusy and (not isChild or self.phase == "prologue-escape") and -input.moveY or 0 -- 2060
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 2062
	if dir ~= 0 then -- 2063
		a.facing = dir > 0 and 1 or -1 -- 2064
	end -- 2064
	a.vx = dir * speed * diagonal -- 2066
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 2069
		a.vy = CHILD_JUMP -- 2070
		a.onGround = false -- 2071
		self:flashSet("跳", 0.25) -- 2072
	end -- 2072
	local previousDepth = a.depth -- 2076
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 2077
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2078
	self:slideX(a, a.vx * dt) -- 2079
	self:fallY(a, dt) -- 2080
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and input.fire.pressed then -- 2083
		self:shoot(a) -- 2084
	end -- 2084
end -- 1979
function Play.prototype.stepPartner(self, p, dt) -- 2089
	local a = self.partner -- 2090
	if not a.alive then -- 2091
		return -- 2092
	end -- 2092
	a.crouch = false -- 2094
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 2095
	a.vx = 0 -- 2096
	a.depthSpeed = 0 -- 2097
	self:fallY(a, dt) -- 2098
end -- 2089
function Play.prototype.stepEscort(self, dt, input) -- 2105
	local a = self.partner -- 2106
	a.depthSpeed = 0 -- 2107
	if not a.alive then -- 2108
		return -- 2109
	end -- 2109
	if self.room.key == "gatepath" then -- 2111
		if self.carryOn then -- 2113
			return -- 2114
		end -- 2114
		local p = self.player -- 2117
		a.depth = p.depth -- 2118
		a.facing = p.facing -- 2119
		a.crouch = false -- 2120
		a.h = CHILD_H -- 2121
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 2122
		a.y = p.y -- 2123
		a.vy = 0 -- 2124
		a.vx = p.vx -- 2125
		a.onGround = p.onGround -- 2126
		return -- 2127
	end -- 2127
	if not self:escortOn() then -- 2129
		a.vx = 0 -- 2130
		self:fallY(a, dt) -- 2131
		return -- 2132
	end -- 2132
	local p = self.player -- 2134
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 2135
	local hadKnock1 = self.escort.knock1 -- 2136
	local hadKnock2 = self.escort.knock2 -- 2137
	self.calmConsumed = self.escort:update( -- 2138
		input, -- 2138
		p.x, -- 2138
		p.facing, -- 2138
		a.x, -- 2138
		dist -- 2138
	) -- 2138
	if not hadKnock1 and self.escort.knock1 then -- 2140
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 2141
	end -- 2141
	if not hadKnock2 and self.escort.knock2 then -- 2143
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 2144
	end -- 2144
	a.crouch = self.escort.crouchPose -- 2146
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 2147
	if not self.escort.stopped then -- 2148
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 2149
		local previousDepth = a.depth -- 2150
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 2151
		local distance = math.max( -- 2152
			-travel, -- 2152
			math.min(travel, targetDepth - previousDepth) -- 2152
		) -- 2152
		self:slideDepth(a, distance) -- 2153
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2154
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 2155
			a.vy = CHILD_JUMP -- 2156
			a.onGround = false -- 2157
		end -- 2157
	end -- 2157
	local dir = self.escort:moveDir(a.x) -- 2160
	a.vx = dir * CHILD_SPEED -- 2161
	if dir ~= 0 then -- 2162
		a.facing = dir -- 2163
		local before = a.x -- 2164
		self:slideX(a, dir * CHILD_SPEED * dt) -- 2165
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 2167
			a.vy = CHILD_JUMP -- 2168
			a.onGround = false -- 2169
		end -- 2169
	end -- 2169
	self:fallY(a, dt) -- 2172
end -- 2105
function Play.prototype.escortOn(self) -- 2176
	if self.room.key == "checkpoint" then -- 2177
		return true -- 2178
	end -- 2178
	if self.room.key == "gatepath" then -- 2180
		return true -- 2181
	end -- 2181
	if self.room.key == "prologue" then -- 2183
		return self.phase == "prologue-follow" -- 2184
	end -- 2184
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 2186
		return true -- 2188
	end -- 2188
	return self.room.key == "street" -- 2190
end -- 2176
function Play.prototype.storyLocked(self) -- 2194
	if self.caughtT > 0 then -- 2195
		return true -- 2196
	end -- 2196
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 2198
		return true -- 2200
	end -- 2200
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 2202
		return true -- 2203
	end -- 2203
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 2205
		return true -- 2206
	end -- 2206
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2208
		return true -- 2209
	end -- 2209
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2211
		return true -- 2212
	end -- 2212
	if self.craftBench.active then -- 2215
		return true -- 2216
	end -- 2216
	return false -- 2218
end -- 2194
function Play.prototype.swapToChild(self, x) -- 2222
	local tmp = self.player -- 2223
	self.player = self.partner -- 2224
	self.partner = tmp -- 2225
	self.childMode = true -- 2226
	self.player.alive = true -- 2227
	self.player.x = self.ox + x -- 2228
	self.player.y = 0 -- 2229
	self.player.depth = 0 -- 2230
	self.player.depthSpeed = 0 -- 2231
	self.player.vy = 0 -- 2232
	self.player.vx = 0 -- 2233
	self.player.onGround = true -- 2234
	self.player.crouch = false -- 2235
	self.player.h = CHILD_H -- 2236
	self.player.facing = 1 -- 2237
	self.partner.alive = true -- 2238
	self.cam.x = self.player.x -- 2239
end -- 2222
function Play.prototype.swapToSoldier(self, x, childX) -- 2243
	local tmp = self.player -- 2244
	self.player = self.partner -- 2245
	self.partner = tmp -- 2246
	self.childMode = false -- 2247
	self.player.alive = true -- 2248
	self.player.x = self.ox + x -- 2249
	self.player.y = 0 -- 2250
	self.player.depth = 0 -- 2251
	self.player.depthSpeed = 0 -- 2252
	self.player.vy = 0 -- 2253
	self.player.vx = 0 -- 2254
	self.player.onGround = true -- 2255
	self.player.crouch = false -- 2256
	self.player.h = SOLDIER_H -- 2257
	self.player.facing = 1 -- 2258
	self.partner.alive = true -- 2259
	self.partner.x = self.ox + childX -- 2260
	self.partner.y = 0 -- 2261
	self.partner.depth = 0 -- 2262
	self.partner.depthSpeed = 0 -- 2263
	self.partner.vx = 0 -- 2264
	self.partner.vy = 0 -- 2265
	self.partner.onGround = true -- 2266
	self.partner.crouch = true -- 2267
	self.partner.h = CHILD_CROUCH_H -- 2268
	self.cam.x = self.player.x -- 2269
end -- 2243
function Play.prototype.stepStory(self, dt, input) -- 2273
	if self.room.key == "prologue" then -- 2274
		self:stepPrologue(dt, input) -- 2275
	elseif self.room.key == "street" then -- 2276
		self:stepStreet(dt, input) -- 2277
	elseif self.room.key == "gate" then -- 2278
		self:stepGate(dt, input) -- 2279
	elseif self.room.key == "gatepath" then -- 2280
		self:stepGatePath() -- 2281
	elseif self.room.key == "tower" then -- 2282
		self:stepTower(dt, input) -- 2283
	elseif self.room.key == "museum" then -- 2284
		self:stepMuseum(dt, input) -- 2285
	end -- 2285
end -- 2273
function Play.prototype.canPersistProgress(self) -- 2291
	return not self.isCampaign and self.run.source == "official" -- 2292
end -- 2291
function Play.prototype.wellWindow(self) -- 2296
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 2297
end -- 2296
function Play.prototype.nearWell(self) -- 2302
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 2303
end -- 2302
function Play.prototype.pickWell(self) -- 2311
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2312
		return false -- 2313
	end -- 2313
	self.phase = "prologue-well" -- 2315
	self.phaseTick = 0 -- 2316
	self.wellOpen = false -- 2317
	self:flashSet("井沿 · 伸手下去", 1.4) -- 2318
	self:log("旧井拾取") -- 2319
	return true -- 2320
end -- 2311
function Play.prototype.stepPrologue(self, dt, input) -- 2323
	local child = self.partner -- 2324
	if self.museumReturn then -- 2325
		self.museumReturn = false -- 2327
		self.phase = "prologue-wait" -- 2328
		self.phaseTick = 0 -- 2329
		self.player.x = self.ox + 260 -- 2330
		self.player.y = 0 -- 2331
		self.player.depth = 0 -- 2332
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2333
	end -- 2333
	if self.phase == "prologue-wake" then -- 2336
		self.introTick = self.introTick + 1 -- 2337
		if self.introTick == 60 then -- 2338
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2339
		end -- 2339
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2341
			self.phase = "prologue-shadow" -- 2342
			self.introTick = 0 -- 2343
			self:flashSet("门缝里两道影子", 1.2) -- 2344
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2345
		end -- 2345
		return -- 2347
	end -- 2347
	if self.phase == "prologue-shadow" then -- 2349
		self.introTick = self.introTick + 1 -- 2350
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2351
			self.phase = "prologue-escape" -- 2353
			self.introTick = 0 -- 2354
			self.escapeRemaining = self.escapeDuration -- 2355
			self.escapeRetryCount = 0 -- 2356
			self:swapToChild(100) -- 2357
			self:flashSet( -- 2358
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2358
				1.6 -- 2358
			) -- 2358
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2359
		end -- 2359
		return -- 2363
	end -- 2363
	if self.phase == "prologue-escape" then -- 2365
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2366
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2367
			self.phase = "prologue-hide" -- 2369
			self.introTick = 0 -- 2370
			self.player.vx = 0 -- 2371
			self.player.crouch = true -- 2372
			self.player.h = CHILD_CROUCH_H -- 2373
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2374
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2375
			return -- 2379
		end -- 2379
		if self.escapeRemaining <= 0 then -- 2381
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2383
			self.player.x = self.ox + 100 -- 2384
			self.player.y = 0 -- 2385
			self.player.depth = 0 -- 2386
			self.player.vx = 0 -- 2387
			self.player.vy = 0 -- 2388
			self.escapeRemaining = self.escapeDuration -- 2389
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2390
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2391
			return -- 2392
		end -- 2392
		return -- 2394
	end -- 2394
	if self.phase == "prologue-hide" then -- 2396
		self.introTick = self.introTick + 1 -- 2397
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2398
			self.phase = "prologue-wait" -- 2400
			self.phaseTick = 0 -- 2401
			self.introTick = 0 -- 2402
			self:swapToSoldier(260, 300) -- 2403
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2404
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2405
		end -- 2405
		return -- 2407
	end -- 2407
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2410
	if self.phase == "prologue-wait" then -- 2411
		child.crouch = true -- 2412
		child.h = CHILD_CROUCH_H -- 2413
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2414
			self:pickWell() -- 2415
			return -- 2416
		end -- 2416
		if not self.wellOpen and self:canPersistProgress() and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2419
			self.archive.museumPhase = "well_reflect" -- 2421
			self.archiveDirty = true -- 2422
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2423
			return -- 2424
		end -- 2424
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2426
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2428
		if near and input.interact.pressed then -- 2429
			self.phase = "prologue-give" -- 2430
			self.phaseTick = 0 -- 2431
			self:flashSet("递出针套", 1) -- 2432
		end -- 2432
		return -- 2434
	end -- 2434
	if self.phase == "prologue-well" then -- 2436
		self.phaseTick = self.phaseTick + 1 -- 2438
		if self.phaseTick == 12 then -- 2439
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2440
		elseif self.phaseTick >= 30 then -- 2441
			self.phase = "prologue-wait" -- 2442
			self.phaseTick = 0 -- 2443
			self.wellTaken = true -- 2444
			self.wellOpen = false -- 2445
			self.run.archive.artifactOwned = true -- 2446
			self.archiveDirty = true -- 2447
			self:emit("artifactFound", { -- 2448
				x = self.ox + self.wellX, -- 2449
				y = 0, -- 2449
				room = "prologue", -- 2449
				once = true, -- 2449
				source = self.run.source -- 2450
			}) -- 2450
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2452
			self:log("井底取到时间穿梭器") -- 2453
		end -- 2453
		return -- 2455
	end -- 2455
	if self.phase == "prologue-give" then -- 2457
		self.phaseTick = self.phaseTick + 1 -- 2458
		if self.phaseTick == 12 then -- 2459
			self:flashSet("针套递过去", 0.7) -- 2460
		elseif self.phaseTick == 36 then -- 2461
			self:flashSet("纸条塞进针套", 0.9) -- 2462
		elseif self.phaseTick >= 60 then -- 2463
			self.phase = "prologue-follow" -- 2464
			self.phaseTick = 0 -- 2465
			child.crouch = false -- 2466
			child.h = CHILD_H -- 2467
			self:flashSet("她跟上了", 1.2) -- 2468
		end -- 2468
		return -- 2470
	end -- 2470
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2473
		local next = self.run.source == "debug" and "street" or "s1-crossroad" -- 2474
		self:requestRoom(next, "序章跟到门口") -- 2475
		self:flashSet(next == "s1-crossroad" and "进十字街" or "进街道", 1.2) -- 2476
	end -- 2476
end -- 2323
function Play.prototype.stepStreet(self, dt, input) -- 2481
	local p = self.player -- 2482
	local c = self.partner -- 2483
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2484
		local next = self.run.source == "debug" and "checkpoint" or "s1-crossroad" -- 2485
		self:requestRoom(next, "两人都到街尾") -- 2486
		self:flashSet(next == "s1-crossroad" and "进十字街" or "到检查站", 1.2) -- 2487
	end -- 2487
end -- 2481
function Play.prototype.stepGate(self, dt, input) -- 2492
	local ____temp_38 -- 2493
	if self.room.story == nil then -- 2493
		____temp_38 = nil -- 2493
	else -- 2493
		____temp_38 = self.room.story.gate -- 2493
	end -- 2493
	local g = ____temp_38 -- 2493
	if g == nil then -- 2494
		return -- 2495
	end -- 2495
	local p = self.player -- 2497
	if self.phase == "gate-idle" then -- 2498
		local a = self.partner -- 2500
		local gap = g.waitX - a.x -- 2501
		if math.abs(gap) > 3 then -- 2502
			a.facing = gap > 0 and 1 or -1 -- 2503
			a.vx = a.facing * CHILD_SPEED -- 2504
			local beforeX = a.x -- 2505
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2506
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2507
				a.vy = CHILD_JUMP -- 2508
				a.onGround = false -- 2509
			end -- 2509
			self:fallY(a, dt) -- 2511
		else -- 2511
			a.vx = 0 -- 2513
			a.x = g.waitX -- 2514
		end -- 2514
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2517
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2518
		if self.gateNeedConfirm then -- 2519
			if not input.interact.held then -- 2522
				self.gateRestartArmed = true -- 2523
			end -- 2523
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2525
				self.gateNeedConfirm = false -- 2526
				self.gateRestartArmed = true -- 2527
				self.phase = "gate-hold" -- 2528
				self.gateTick = 0 -- 2529
				self.gateSpawned = 0 -- 2530
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2531
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2532
			end -- 2532
			return -- 2534
		end -- 2534
		if atWinch and atWait then -- 2536
			self.phase = "gate-hold" -- 2537
			self.gateTick = 0 -- 2538
			self.gateSpawned = 0 -- 2539
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2540
		end -- 2540
		return -- 2542
	end -- 2542
	if self.phase == "gate-hold" then -- 2544
		self.gateTick = self.gateTick + 1 -- 2545
		local marks = {0, 540, 900, 1500} -- 2547
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2548
			local idx = self.gateSpawned -- 2549
			local ____self_enemies_39 = self.enemies -- 2550
			____self_enemies_39[#____self_enemies_39 + 1] = { -- 2550
				x = self.ox + 620 + idx * 62, -- 2551
				y = 0, -- 2551
				w = 26, -- 2551
				h = 84, -- 2551
				alive = true, -- 2552
				hitT = 0, -- 2552
				warnT = 0, -- 2552
				fireCd = 90 + idx * 45 -- 2552
			} -- 2552
			self.gateSpawned = self.gateSpawned + 1 -- 2554
			self:flashSet( -- 2555
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2555
				0.9 -- 2555
			) -- 2555
		end -- 2555
		if self.gateTick == 900 then -- 2557
			self:flashSet("棚布落下", 1) -- 2558
		elseif self.gateTick == 2100 then -- 2559
			self:flashSet("门底透进冷光了", 1) -- 2560
		end -- 2560
		if self.gateTick >= g.holdTicks then -- 2562
			self:captureGateBlood() -- 2565
			self.phase = "gate-send" -- 2566
			self.phaseTick = 0 -- 2567
			self.enemies = {} -- 2569
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2570
		end -- 2570
		return -- 2572
	end -- 2572
	if self.phase == "gate-send" then -- 2574
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2575
		if near and input.interact.pressed then -- 2576
			self:commitRoute() -- 2578
			self:swapToChild(g.doorX + 30) -- 2579
			self.phase = "gate-count" -- 2580
			self.countTick = 0 -- 2581
			self.countArmed = false -- 2583
			self.countPrevMove = input.moveX -- 2584
			self:flashSet("门开了 · 送她出去", 1.8) -- 2585
		end -- 2585
		return -- 2587
	end -- 2587
	if self.phase == "gate-count" then -- 2589
		self.countTick = self.countTick + 1 -- 2590
		if self.countTick == 360 then -- 2591
			self:flashSet("门关上", 0.9) -- 2592
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2593
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2594
			if self.storyRoute == "soldier" then -- 2598
				self.phase = "gate-wait" -- 2600
				self.phaseTick = 0 -- 2601
				self.knocks = 1 -- 2602
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2603
				self.handArmed = not input.interact.held and not self.intentGateReunionHold -- 2605
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2606
			else -- 2606
				self:flashSet("数到二十", 2.2) -- 2608
			end -- 2608
		end -- 2608
		local prevMove = self.countPrevMove -- 2613
		self.countPrevMove = input.moveX -- 2614
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2615
			if prevMove <= 0 and input.moveX > 0 then -- 2616
				self.countArmed = true -- 2617
			end -- 2617
			if self.countArmed and input.moveX > 0 then -- 2619
				self.phase = "gate-walk" -- 2620
				self.phaseTick = 0 -- 2621
				self:flashSet("她迈出第一步", 1.4) -- 2622
				self:emit("storyExit", { -- 2623
					route = "child", -- 2623
					via = "walk", -- 2623
					countTick = self.countTick, -- 2623
					hp = self.hp, -- 2623
					maxHp = self.maxHp -- 2623
				}) -- 2623
			end -- 2623
		end -- 2623
		return -- 2626
	end -- 2626
	if self.phase == "gate-wait" then -- 2628
		self.phaseTick = self.phaseTick + 1 -- 2630
		if self.phaseTick == 12 then -- 2631
			self.knocks = 2 -- 2632
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2633
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2634
		end -- 2634
		local held = input.interact.held or self.intentGateReunionHold -- 2636
		if not held then -- 2637
			if self.handTicks > 0 then -- 2638
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2639
			end -- 2639
			self.handTicks = 0 -- 2641
			self.handArmed = true -- 2642
			return -- 2643
		end -- 2643
		if self.handArmed then -- 2645
			self.handTicks = self.handTicks + 1 -- 2646
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2647
				self.intentGateReunionHold = false -- 2648
				self.phase = "gate-hand" -- 2649
				self.phaseTick = 0 -- 2650
				self.handDone = true -- 2651
				self.tied = true -- 2652
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2653
				if not self.lineSaid then -- 2654
					self.lineSaid = true -- 2655
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2656
				end -- 2656
				self:flashSet("我们走吧。", 3) -- 2658
			end -- 2658
		end -- 2658
		return -- 2661
	end -- 2661
	if self.phase == "gate-hand" then -- 2663
		self.phaseTick = self.phaseTick + 1 -- 2665
		if self.phaseTick == 30 then -- 2666
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2667
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2668
			self:emit("storyExit", { -- 2669
				route = "soldier", -- 2669
				via = "hand", -- 2669
				handTicks = self.handTicks, -- 2669
				hp = self.hp, -- 2669
				maxHp = self.maxHp -- 2669
			}) -- 2669
			self:requestRoom("gatepath", "牵手同行") -- 2670
		end -- 2670
		return -- 2672
	end -- 2672
	if self.phase == "gate-walk" then -- 2675
		if self.player.x >= g.exitX then -- 2676
			self:requestRoom("outside", "走出城门") -- 2677
			self:flashSet("出城门 · 城外", 1.4) -- 2678
		end -- 2678
	end -- 2678
end -- 2492
function Play.prototype.captureGateBlood(self) -- 2687
	self.hpAtGate = self.hp -- 2688
	self.maxHpAtGate = self.maxHp -- 2689
end -- 2687
function Play.prototype.commitRoute(self) -- 2696
	if self.storySettled then -- 2697
		return -- 2698
	end -- 2698
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2700
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2701
	self.hpAtGate = hp -- 2702
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2703
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2704
	self.storySettled = true -- 2705
	self.sessionDirty = true -- 2706
	self:emit("storyRouteLocked", { -- 2707
		route = self.storyRoute, -- 2708
		hp = self.hp, -- 2708
		maxHp = self.maxHp, -- 2708
		hpAtGate = self.hpAtGate, -- 2709
		maxHpAtGate = self.maxHpAtGate -- 2709
	}) -- 2709
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2711
end -- 2696
function Play.prototype.syncStory(self) -- 2715
	if self.isCampaign and self.run.trial ~= nil then -- 2716
		return -- 2717
	end -- 2717
	local s = self.run.story -- 2719
	if s == nil then -- 2720
		return -- 2721
	end -- 2721
	s.hp = self.hp -- 2723
	s.maxHp = self.maxHp -- 2724
	s.route = self.storyRoute -- 2725
	s.settled = self.storySettled -- 2726
	s.hpAtGate = self.hpAtGate -- 2727
	s.maxHpAtGate = self.maxHpAtGate -- 2728
	s.handDone = self.handDone -- 2729
	s.lineSaid = self.lineSaid -- 2730
	s.tied = self.tied -- 2731
	s.carry = self.carryOn -- 2732
	s.museumReturn = self.museumReturn -- 2733
	s.escortDone = self.escortDone -- 2734
	s.craftedWeapon = self.run.story.craftedWeapon -- 2735
	s.equippedWeapon = self.equippedWeapon -- 2736
	s.ending = self.run.story.ending -- 2737
	if self.room.key == "gate" then -- 2738
		s.phase = self.phase -- 2739
		s.countTick = self.countTick -- 2740
		s.phaseTick = self.phaseTick -- 2741
		s.handTicks = self.handTicks -- 2742
	end -- 2742
	if self.room.key == "prologue" then -- 2744
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2746
			s.phase = self.phase -- 2747
			s.phaseTick = self.phaseTick -- 2748
		end -- 2748
	end -- 2748
	if self.room.key == "tower" then -- 2751
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2753
			s.phase = self.phase -- 2754
			s.phaseTick = self.phaseTick -- 2755
		end -- 2755
	end -- 2755
end -- 2715
function Play.prototype.stepGatePath(self) -- 2761
	local ____temp_40 -- 2762
	if self.room.story == nil then -- 2762
		____temp_40 = nil -- 2762
	else -- 2762
		____temp_40 = self.room.story.gatepath -- 2762
	end -- 2762
	local gp = ____temp_40 -- 2762
	if self.phase == "gatepath-start" then -- 2763
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2764
			self.carryOn = true -- 2765
			self.phase = "gatepath-carry" -- 2766
			self.phaseTick = 0 -- 2767
			self.pathDone = true -- 2768
			self.escortDone = false -- 2769
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2770
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2771
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2772
		end -- 2772
		return -- 2774
	end -- 2774
	if self.phase == "gatepath-carry" then -- 2776
		self.phaseTick = self.phaseTick + 1 -- 2777
		if self.phaseTick == 20 then -- 2778
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2779
		end -- 2779
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2781
			self:requestRoom(gp.next, "背负进首战") -- 2782
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2783
		end -- 2783
	end -- 2783
end -- 2761
function Play.prototype.carryPose(self) -- 2792
	local p = self.player -- 2793
	local a = self.partner -- 2794
	a.alive = true -- 2795
	a.x = p.x - p.facing * 12 -- 2796
	a.y = p.y + 26 -- 2797
	a.depth = p.depth -- 2798
	a.vx = p.vx -- 2799
	a.vy = 0 -- 2800
	a.onGround = true -- 2801
	a.crouch = false -- 2802
	a.h = CHILD_CROUCH_H -- 2803
	a.facing = p.facing -- 2804
end -- 2792
function Play.prototype.stepMuseum(self, dt, input) -- 2812
	self.partner.alive = false -- 2813
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2814
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2817
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 2818
	local intentTarget = self.pendingMuseumIntentTarget -- 2819
	self.pendingMuseumIntentTarget = "" -- 2820
	local interactHit = input.interact.pressed or intentTarget ~= "" -- 2821
	if self.phase == "museum-cabinet" then -- 2822
		if atCase and interactHit or intentTarget == "cabinet" then -- 2823
			self.phase = "museum-hall" -- 2824
			self.phaseTick = 0 -- 2825
			if self:canPersistProgress() then -- 2826
				self.archive.museumPhase = "hall_walk" -- 2827
				self.archiveDirty = true -- 2828
			end -- 2828
			self:emit( -- 2830
				"museumStep", -- 2830
				{ -- 2830
					step = "cabinet", -- 2830
					x = self.ox + mu.cabinetX, -- 2830
					persisted = self:canPersistProgress() -- 2830
				} -- 2830
			) -- 2830
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2831
		end -- 2831
		return -- 2833
	end -- 2833
	if self.phase == "museum-hall" then -- 2835
		if intentTarget == "lamp_direct" and nearLamp then -- 2836
			self:emit( -- 2837
				"museumStep", -- 2837
				{ -- 2837
					step = "hall", -- 2837
					x = self.ox + mu.hallX, -- 2837
					persisted = self:canPersistProgress() -- 2837
				} -- 2837
			) -- 2837
			self.phase = "museum-return" -- 2838
			self.phaseTick = 0 -- 2839
			if self:canPersistProgress() then -- 2840
				self.archive.museumPhase = "return_cabinet" -- 2841
				self.archiveDirty = true -- 2842
			end -- 2842
			self:emit( -- 2844
				"museumStep", -- 2844
				{ -- 2844
					step = "lamp", -- 2844
					x = self.ox + mu.lampX, -- 2844
					persisted = self:canPersistProgress() -- 2844
				} -- 2844
			) -- 2844
			self:flashSet("灯 · 转向西窗", 1.8) -- 2845
			return -- 2846
		end -- 2846
		if self.player.x >= self.ox + mu.hallX and interactHit then -- 2848
			self.phase = "museum-lamp" -- 2849
			self.phaseTick = 0 -- 2850
			if self:canPersistProgress() then -- 2851
				self.archive.museumPhase = "lamp_turn" -- 2852
				self.archiveDirty = true -- 2853
			end -- 2853
			self:emit( -- 2855
				"museumStep", -- 2855
				{ -- 2855
					step = "hall", -- 2855
					x = self.ox + mu.hallX, -- 2855
					persisted = self:canPersistProgress() -- 2855
				} -- 2855
			) -- 2855
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2856
		end -- 2856
		return -- 2858
	end -- 2858
	if self.phase == "museum-lamp" then -- 2860
		if nearLamp and interactHit then -- 2861
			self.phase = "museum-return" -- 2862
			self.phaseTick = 0 -- 2863
			if self:canPersistProgress() then -- 2864
				self.archive.museumPhase = "return_cabinet" -- 2865
				self.archiveDirty = true -- 2866
			end -- 2866
			self:emit( -- 2868
				"museumStep", -- 2868
				{ -- 2868
					step = "lamp", -- 2868
					x = self.ox + mu.lampX, -- 2868
					persisted = self:canPersistProgress() -- 2868
				} -- 2868
			) -- 2868
			self:flashSet("灯 · 转向西窗", 1.8) -- 2869
		end -- 2869
		return -- 2871
	end -- 2871
	if self.phase == "museum-return" then -- 2873
		if atCase and interactHit or intentTarget == "return_cabinet" then -- 2874
			self.phase = "museum-knock" -- 2875
			self.phaseTick = 0 -- 2876
			self:emit( -- 2877
				"museumStep", -- 2877
				{ -- 2877
					step = "knock", -- 2877
					count = 1, -- 2877
					x = self.ox + mu.cabinetX, -- 2877
					persisted = self:canPersistProgress() -- 2877
				} -- 2877
			) -- 2877
			self:flashSet("回柜边 · 第一下", 0.8) -- 2878
		end -- 2878
		return -- 2880
	end -- 2880
	if self.phase == "museum-knock" then -- 2882
		self.phaseTick = self.phaseTick + 1 -- 2883
		if self.phaseTick == 8 then -- 2884
			self:emit( -- 2885
				"museumStep", -- 2885
				{ -- 2885
					step = "knock", -- 2885
					count = 2, -- 2885
					x = self.ox + mu.cabinetX, -- 2885
					persisted = self:canPersistProgress() -- 2885
				} -- 2885
			) -- 2885
			self:flashSet("回柜边 · 第二下", 0.8) -- 2886
		elseif self.phaseTick >= 36 then -- 2887
			self.phase = "museum-done" -- 2888
			self.phaseTick = 0 -- 2889
			if self:canPersistProgress() then -- 2890
				self.archive.museumSeen = true -- 2891
				self.archive.museumPhase = "done" -- 2892
				self.archiveDirty = true -- 2893
			end -- 2893
			self:emit( -- 2895
				"museumDone", -- 2895
				{ -- 2895
					steps = 4, -- 2895
					museumSeen = self.archive.museumSeen, -- 2895
					persisted = self:canPersistProgress() -- 2895
				} -- 2895
			) -- 2895
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2896
			self:log("博物馆 · 回柜边") -- 2897
		end -- 2897
		return -- 2899
	end -- 2899
	if interactHit then -- 2901
		self.museumReturn = true -- 2902
		self:requestRoom("prologue", "回柜边") -- 2903
	end -- 2903
end -- 2812
function Play.prototype.openTowerDoor(self) -- 2907
	self.towerDoorOpen = true -- 2908
	do -- 2908
		local i = 0 -- 2909
		while i < #self.boxes do -- 2909
			if self.boxes[i + 1].id == "tower_door" then -- 2910
				self.boxes[i + 1].hidden = true -- 2911
			end -- 2911
			i = i + 1 -- 2909
		end -- 2909
	end -- 2909
	self.run.story.segments.tower_door = true -- 2914
end -- 2907
function Play.prototype.stepTower(self, dt, input) -- 2917
	local ____temp_41 -- 2918
	if self.room.story == nil then -- 2918
		____temp_41 = nil -- 2918
	else -- 2918
		____temp_41 = self.room.story.tower -- 2918
	end -- 2918
	local t = ____temp_41 -- 2918
	if t == nil then -- 2919
		return -- 2920
	end -- 2920
	if self.storyRoute == "soldier" and self.partner.alive then -- 2923
		local targetX = math.max(self.ox + 408, self.player.x - 28) -- 2924
		local gap = targetX - self.partner.x -- 2925
		if math.abs(gap) > 2 then -- 2926
			local dir = gap > 0 and 1 or -1 -- 2927
			local stepDist = math.min( -- 2928
				math.abs(gap), -- 2928
				SOLDIER_SPEED * dt -- 2928
			) -- 2928
			self.partner.facing = dir -- 2929
			self.partner.vx = dir * SOLDIER_SPEED -- 2930
			local ____self_partner_42, ____x_43 = self.partner, "x" -- 2931
			____self_partner_42[____x_43] = ____self_partner_42[____x_43] + dir * stepDist -- 2931
		else -- 2931
			self.partner.vx = 0 -- 2933
			self.partner.facing = 1 -- 2934
		end -- 2934
	end -- 2934
	if self.phase == "tower-wait" then -- 2937
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2938
		if near and input.interact.pressed then -- 2939
			self.phase = "tower-knock" -- 2940
			self.phaseTick = 0 -- 2941
			self.knocks = 1 -- 2942
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2943
			self:flashSet("叩两下 · 第一声", 0.6) -- 2944
		end -- 2944
		return -- 2946
	end -- 2946
	if self.phase == "tower-knock" then -- 2948
		self.phaseTick = self.phaseTick + 1 -- 2949
		if self.phaseTick == 12 then -- 2950
			self.knocks = 2 -- 2951
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2952
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 2953
		elseif self.phaseTick >= t.knockTicks then -- 2954
			self:openTowerDoor() -- 2955
			self.phase = "tower-enter" -- 2956
			self.phaseTick = 0 -- 2957
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 2958
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 2959
		end -- 2959
		return -- 2961
	end -- 2961
	if self.phase == "tower-enter" then -- 2963
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 2964
			self.phase = "tower-desk" -- 2965
			self.phaseTick = 0 -- 2966
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 2967
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 2968
		end -- 2968
		return -- 2970
	end -- 2970
	if self.phase == "tower-desk" then -- 2972
		local deskX = self.ox + 605 -- 2973
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 2974
		if not near or not input.interact.held then -- 2975
			self.deskHold = 0 -- 2976
			return -- 2977
		end -- 2977
		self.deskHold = self.deskHold + 1 -- 2979
		if self.deskHold == 12 then -- 2980
			self:flashSet("针套 · 放在桌上", 1) -- 2981
		elseif self.deskHold == 24 then -- 2982
			self:flashSet("指南针 · 压住纸条", 1) -- 2983
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 2984
			self.towerHanded = true -- 2985
			self.deskHold = 0 -- 2986
			self.run.story.segments.tower_handover = true -- 2987
			self.phase = "tower-given" -- 2988
			self.phaseTick = 0 -- 2989
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 2990
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 2995
		end -- 2995
		return -- 2997
	end -- 2997
	if self.phase == "tower-given" then -- 2999
		local soldier = self.storyRoute == "soldier" -- 3002
		self.phaseTick = self.phaseTick + 1 -- 3003
		if self.phaseTick == 60 then -- 3004
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 3005
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 3006
		elseif self.phaseTick == 120 then -- 3007
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 3008
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 3009
			self.phase = "tower-end" -- 3010
			self.phaseTick = 0 -- 3011
			self.towerEndMustRelease = input.interact.held or input.retry.held -- 3012
			if not self.run.finished then -- 3013
				self.run.finished = true -- 3014
				local ending = soldier and "reunion" or "lamp" -- 3015
				self.run.story.ending = ending -- 3016
				local ____soldier_44 -- 3019
				if soldier then -- 3019
					____soldier_44 = self.run.story.segments.escort5 == true -- 3020
				else -- 3020
					____soldier_44 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 3021
				end -- 3021
				local played = ____soldier_44 -- 3019
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 3022
				if official then -- 3024
					if soldier then -- 3025
						self.run.archive.soldierCleared = true -- 3026
					else -- 3026
						self.run.archive.childCleared = true -- 3028
					end -- 3028
					self.archiveDirty = true -- 3030
				end -- 3030
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 3032
				self:emit("endingReached", { -- 3033
					route = soldier and "soldier" or "child", -- 3034
					ending = ending, -- 3035
					official = official, -- 3036
					source = self.run.source, -- 3037
					lines = {self.endingLines[1], self.endingLines[2]}, -- 3038
					childCleared = self.run.archive.childCleared, -- 3039
					soldierCleared = self.run.archive.soldierCleared, -- 3040
					artifactOwned = self.run.archive.artifactOwned, -- 3041
					equipped = self.equippedWeapon -- 3042
				}) -- 3042
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 3044
			end -- 3044
		end -- 3044
		return -- 3047
	end -- 3047
	self.phaseTick = self.phaseTick + 1 -- 3049
	local held = input.interact.held or input.retry.held -- 3050
	if self.towerEndMustRelease then -- 3051
		if not held then -- 3052
			self.towerEndMustRelease = false -- 3053
		end -- 3053
		return -- 3055
	end -- 3055
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 3057
	if self.phaseTick < waitTicks then -- 3058
		if input.interact.pressed or input.retry.pressed then -- 3059
			self.towerEndMustRelease = held -- 3060
		end -- 3060
		return -- 3062
	end -- 3062
	if input.interact.pressed or input.retry.pressed then -- 3064
		self.restartStory = true -- 3066
		self:requestRoom("prologue", "片尾再玩") -- 3067
		self:flashSet("回到序章", 1.4) -- 3068
	end -- 3068
end -- 2917
function Play.prototype.stepChase(self, dt, input) -- 3073
	if self.caughtT > 0 then -- 3074
		self.caughtT = self.caughtT - dt -- 3075
		if self.caughtT <= 0 then -- 3076
			self:recoverFromCaught() -- 3077
		end -- 3077
		return -- 3079
	end -- 3079
	if self.room.key == "village" then -- 3081
		self:stepScavChase() -- 3082
	elseif self.room.key == "forest" then -- 3083
		self:stepForestRoute() -- 3084
		self:stepDog(dt) -- 3085
		if self.player.x >= self.ox + 1450 then -- 3087
			self:requestRoom("tower", "到林缘北塔") -- 3088
			self:flashSet("林缘 · 北塔", 1.4) -- 3089
		end -- 3089
	end -- 3089
end -- 3073
function Play.prototype.stepScavChase(self) -- 3095
	local s = self.room.scavenger -- 3096
	if s == nil then -- 3097
		return -- 3098
	end -- 3098
	local p = self.player -- 3100
	if self.passed and p.x > self.ox + 440 then -- 3102
		if self.scavChase then -- 3103
			self.scavChase = false -- 3104
			self.scavState = "back" -- 3105
			self.scavT = 0 -- 3106
		end -- 3106
		return -- 3108
	end -- 3108
	local dx = p.x - self.scavX -- 3110
	local dist = math.abs(dx) -- 3111
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 3112
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 3113
	if not self.scavChase then -- 3114
		if visible then -- 3115
			self.scavSee = self.scavSee + 1 -- 3116
			if self.scavSee >= 24 then -- 3117
				self.scavChase = true -- 3118
				self.scavState = "chase" -- 3119
				self.scavTargetX = p.x -- 3120
				self:flashSet("他看见你了", 1.2) -- 3121
			end -- 3121
		else -- 3121
			self.scavSee = 0 -- 3124
		end -- 3124
		return -- 3126
	end -- 3126
	if hidden then -- 3129
		self.scavSee = 0 -- 3130
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 3131
		self.scavT = self.scavT - 1 -- 3132
		if self.scavT <= 0 then -- 3133
			self.scavChase = false -- 3134
			self.scavState = "patrol" -- 3135
			self:flashSet("他失去了目标", 1) -- 3136
		end -- 3136
		return -- 3138
	end -- 3138
	local dir = p.x > self.scavX and 1 or -1 -- 3141
	self.scavX = self.scavX + dir * 96 / 60 -- 3142
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 3143
		self:caught() -- 3144
		return -- 3145
	end -- 3145
end -- 3095
function Play.prototype.stepDog(self, dt) -- 3150
	local ____temp_45 -- 3151
	if self.room.story == nil then -- 3151
		____temp_45 = nil -- 3151
	else -- 3151
		____temp_45 = self.room.story.dog -- 3151
	end -- 3151
	local dog = ____temp_45 -- 3151
	if dog == nil then -- 3152
		return -- 3153
	end -- 3153
	local p = self.player -- 3155
	local ox = self.ox -- 3156
	local dist = math.abs(p.x - self.dogX) -- 3157
	local inBurrowCover = p.crouch and p.x >= ox + 300 and p.x <= ox + 460 -- 3158
	local inBrushCover = p.crouch and (p.x >= ox + 700 and p.x <= ox + 790 or p.x >= ox + 1150 and p.x <= ox + 1240) -- 3159
	local sheltered = inBurrowCover or inBrushCover -- 3163
	local inDitchSprint = not p.crouch and self.forestPath == "ditch" and p.x >= ox + 700 and p.x <= ox + 1140 -- 3164
	local effectiveRange = inDitchSprint and dog.range * 1.25 or dog.range -- 3165
	local earNeedTicks = inDitchSprint and 12 or 18 -- 3166
	if self.dogState == "patrol" then -- 3167
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 3168
		if self.dogX < dog.x0 then -- 3169
			self.dogX = dog.x0 -- 3170
			self.dogDir = 1 -- 3171
		elseif self.dogX > dog.x1 then -- 3172
			self.dogX = dog.x1 -- 3173
			self.dogDir = -1 -- 3174
		end -- 3174
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 3176
		if not sheltered and not p.crouch and moving and dist < effectiveRange then -- 3177
			self.dogState = "ear" -- 3178
			self.dogT = earNeedTicks -- 3179
			self.dogTargetX = p.x -- 3180
			self:flashSet(inDitchSprint and "旧渠枯枝响 · 狗立刻转耳" or "狗转耳朵", 0.8) -- 3181
		end -- 3181
		return -- 3183
	end -- 3183
	if self.dogState == "ear" then -- 3185
		if sheltered then -- 3186
			self.dogState = "sniff" -- 3187
			self.dogT = 45 -- 3188
			self:flashSet("钻进遮蔽 · 狗顿住了", 0.9) -- 3189
			return -- 3190
		end -- 3190
		self.dogT = self.dogT - 1 -- 3192
		if self.dogT <= 0 then -- 3193
			self.dogState = "chase" -- 3194
			self.dogTargetX = p.x -- 3195
			self:flashSet("狗追来了", 1.4) -- 3196
		end -- 3196
		return -- 3198
	end -- 3198
	if self.dogState == "chase" then -- 3200
		local dir = p.x > self.dogX and 1 or -1 -- 3201
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 3202
		if not sheltered and math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 3203
			self:caught() -- 3204
			self.dogState = "sniff" -- 3205
			self.dogT = 60 -- 3206
		elseif dist > effectiveRange * 1.5 or sheltered then -- 3207
			self.dogState = "sniff" -- 3208
			self.dogT = 60 -- 3209
			self:flashSet(inBurrowCover and "树根窄洞遮住身形 · 狗停下了" or "狗停下了", 0.9) -- 3210
		end -- 3210
		return -- 3212
	end -- 3212
	if self.dogState == "sniff" then -- 3214
		self.dogT = self.dogT - 1 -- 3215
		if self.dogT <= 0 then -- 3216
			self.dogState = "back" -- 3217
		end -- 3217
		return -- 3219
	end -- 3219
	local dir = dog.x0 > self.dogX and 1 or -1 -- 3222
	self.dogX = self.dogX + dir * dog.speed * dt -- 3223
	if math.abs(self.dogX - dog.x0) < 2 then -- 3224
		self.dogX = dog.x0 -- 3225
		self.dogState = "patrol" -- 3226
	end -- 3226
end -- 3150
function Play.prototype.stepForestRoute(self) -- 3231
	local p = self.player -- 3232
	local ox = self.ox -- 3233
	if self.forestPath == "" then -- 3234
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 3235
			self.forestPath = "burrow" -- 3236
			self.run.story.segments.forest_burrow = true -- 3237
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 3238
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 3239
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 3240
			self.forestPath = "ditch" -- 3241
			self.run.story.segments.forest_ditch = true -- 3242
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 3243
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 3244
		end -- 3244
	end -- 3244
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 3247
		self.waterSeen = true -- 3248
		self.run.story.segments.water_lantern = true -- 3249
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 3250
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 3251
	end -- 3251
end -- 3231
function Play.prototype.caught(self) -- 3255
	self.caughtT = 1 -- 3256
	self:flashSet("被抓 · 回到安全点", 1.6) -- 3257
end -- 3255
function Play.prototype.recoverFromCaught(self) -- 3261
	local p = self.player -- 3262
	p.x = self.ox + 140 -- 3263
	p.y = 0 -- 3264
	p.vy = 0 -- 3265
	p.vx = 0 -- 3266
	p.onGround = true -- 3267
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3268
		self.scavX = self.room.scavenger.x0 -- 3269
		self.scavState = "patrol" -- 3270
		self.scavSee = 0 -- 3271
		self.scavChase = false -- 3272
		self.scavT = 0 -- 3273
	end -- 3273
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3275
		self.dogX = self.room.story.dog.x0 -- 3276
		self.dogState = "patrol" -- 3277
		self.dogT = 0 -- 3278
	end -- 3278
	self.cam.x = p.x -- 3280
	self.cam.y = p.y + CAM_LOOK_UP -- 3281
	self:flashSet("回到安全点", 1.2) -- 3282
end -- 3261
function Play.prototype.updateGate(self) -- 3286
	if self.room.key ~= "checkpoint" then -- 3287
		self.gateOpen = false -- 3288
		return -- 3289
	end -- 3289
	local function inZone(x) -- 3291
		return x >= self.ox + 792 and x <= self.ox + 928 -- 3291
	end -- 3291
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 3292
end -- 3286
function Play.prototype.addItem(self, kind) -- 3298
	local inv = self.run.inventory -- 3299
	if kind == "shield" then -- 3300
		if inv.shield >= TOOL_CAP then -- 3301
			return false -- 3302
		end -- 3302
		inv.shield = inv.shield + 1 -- 3304
		return true -- 3305
	end -- 3305
	if kind == "wedge" then -- 3307
		if inv.wedge >= CONSUMABLE_CAP then -- 3308
			return false -- 3309
		end -- 3309
		inv.wedge = inv.wedge + 1 -- 3311
		return true -- 3312
	end -- 3312
	if kind == "ammo" then -- 3314
		if inv.ammo >= CONSUMABLE_CAP then -- 3315
			return false -- 3316
		end -- 3316
		inv.ammo = inv.ammo + 1 -- 3318
		return true -- 3319
	end -- 3319
	if kind == "scrap" then -- 3321
		inv.scrap = inv.scrap + 1 -- 3323
		return true -- 3324
	end -- 3324
	if kind == "wood" then -- 3326
		inv.wood = inv.wood + 1 -- 3327
		return true -- 3328
	end -- 3328
	if kind == "bell" then -- 3330
		inv.bell = inv.bell + 1 -- 3331
		return true -- 3332
	end -- 3332
	if kind == "pass" then -- 3334
		inv.pass = inv.pass + 1 -- 3335
		return true -- 3336
	end -- 3336
	if kind == "quickbelt" then -- 3338
		inv.quickbelt = inv.quickbelt + 1 -- 3339
		return true -- 3340
	end -- 3340
	return false -- 3342
end -- 3298
function Play.prototype.findBox(self, id) -- 3345
	local i = 0 -- 3346
	do -- 3346
		i = 0 -- 3347
		while i < #self.boxes do -- 3347
			if self.boxes[i + 1].id == id then -- 3348
				return self.boxes[i + 1] -- 3349
			end -- 3349
			i = i + 1 -- 3347
		end -- 3347
	end -- 3347
	return nil -- 3352
end -- 3345
function Play.prototype.findWedgeTarget(self) -- 3356
	local best = nil -- 3357
	local bestD = 0 -- 3358
	local i = 0 -- 3359
	do -- 3359
		i = 0 -- 3360
		while i < #self.boxes do -- 3360
			do -- 3360
				local b = self.boxes[i + 1] -- 3361
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3362
					goto __continue507 -- 3363
				end -- 3363
				if not self:nearBox(b, 26) then -- 3365
					goto __continue507 -- 3366
				end -- 3366
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3368
				if best == nil or d < bestD then -- 3369
					best = b -- 3370
					bestD = d -- 3371
				end -- 3371
			end -- 3371
			::__continue507:: -- 3371
			i = i + 1 -- 3360
		end -- 3360
	end -- 3360
	return best -- 3374
end -- 3356
function Play.prototype.stepCraft(self, input) -- 3382
	local inv = self.run.inventory -- 3383
	local required = math.max( -- 3384
		6, -- 3384
		CRAFT_TICKS - 6 * self:talentRank("craft") -- 3384
	) -- 3384
	if self.craftT > 0 then -- 3385
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3386
			self.craftT = 0 -- 3388
			self:flashSet("制作中断", 0.8) -- 3389
			return true -- 3390
		end -- 3390
		self.craftT = self.craftT + 1 -- 3392
		if self.craftT >= required then -- 3393
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3394
				inv.scrap = inv.scrap - 1 -- 3395
				inv.wedge = inv.wedge + 1 -- 3396
				self:flashSet("制得木楔", 1.2) -- 3397
				self:log("制木楔") -- 3398
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3399
			end -- 3399
			self.craftT = 0 -- 3401
		end -- 3401
		return true -- 3403
	end -- 3403
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3405
		self.craftT = 1 -- 3406
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3407
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3408
		return true -- 3409
	end -- 3409
	return false -- 3411
end -- 3382
function Play.prototype.nearBox(self, b, reach) -- 3414
	local p = self.player -- 3415
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3416
end -- 3414
function Play.prototype.findInteract(self) -- 3422
	local p = self.player -- 3423
	local best = nil -- 3424
	local bestD = 1000000000 -- 3425
	local i = 0 -- 3426
	do -- 3426
		i = 0 -- 3427
		while i < #self.boxes do -- 3427
			do -- 3427
				local b = self.boxes[i + 1] -- 3428
				if b.interact == nil or b.broken == true then -- 3429
					goto __continue520 -- 3430
				end -- 3430
				if not self:nearBox(b, b.interact.reach or 27) then -- 3432
					goto __continue520 -- 3433
				end -- 3433
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3435
				if d < bestD then -- 3436
					bestD = d -- 3437
					best = b -- 3438
				end -- 3438
			end -- 3438
			::__continue520:: -- 3438
			i = i + 1 -- 3427
		end -- 3427
	end -- 3427
	return best -- 3441
end -- 3422
function Play.prototype.stepCampaign(self, dt, input) -- 3445
	local wr = self.room -- 3446
	local p = self.player -- 3447
	if self.reloadT > 0 then -- 3448
		self.reloadT = self.reloadT - 1 -- 3449
	end -- 3449
	if self.bracedShield ~= nil then -- 3452
		self.bracedShield.x = p.x + p.facing * 26 -- 3453
		self.bracedShield.y = p.y -- 3454
		local shBox = __TS__ArrayFind( -- 3455
			self.boxes, -- 3455
			function(____, b) return b.id == "braced_shield" end -- 3455
		) -- 3455
		if shBox ~= nil then -- 3456
			shBox.x0 = self.bracedShield.x - 15 -- 3457
			shBox.x1 = self.bracedShield.x + 15 -- 3458
			shBox.y0 = self.bracedShield.y -- 3459
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3460
		end -- 3460
	end -- 3460
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3464
		self.run.route = "drygoods" -- 3466
		self.run.joined = false -- 3467
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3468
		self:log("转布行线") -- 3469
	end -- 3469
	if wr.key == "escort3" then -- 3472
		local benchX = wr.minX + 560 -- 3473
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 60 -- 3474
		if nearBench and input.interact.pressed then -- 3475
			self:openCraftBench() -- 3476
		end -- 3476
	end -- 3476
	local i = 0 -- 3480
	do -- 3480
		i = 0 -- 3481
		while i < #self.pickups do -- 3481
			do -- 3481
				local pk = self.pickups[i + 1] -- 3482
				if self.run.taken[pk.id] == true then -- 3483
					goto __continue533 -- 3484
				end -- 3484
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3486
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3487
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3488
					if not self:addItem(pk.kind) then -- 3489
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3491
						self:log("满包拒绝 " .. pk.kind) -- 3492
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3493
						goto __continue533 -- 3494
					end -- 3494
					self.run.taken[pk.id] = true -- 3496
					self:flashSet("拾取 " .. pk.label, 1) -- 3497
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3498
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3499
				end -- 3499
			end -- 3499
			::__continue533:: -- 3499
			i = i + 1 -- 3481
		end -- 3481
	end -- 3481
	if not self:stepCraft(input) and input.interact.pressed then -- 3502
		self:campaignInteract() -- 3503
	end -- 3503
	self:stepCampaignCart(dt, input) -- 3505
	self:stepCampaignGoal() -- 3506
	self:campaignCheckpoint() -- 3507
end -- 3445
function Play.prototype.campaignCheckpoint(self) -- 3511
	local i = 0 -- 3512
	do -- 3512
		i = 0 -- 3513
		while i < #self.room.marks do -- 3513
			do -- 3513
				local m = self.room.marks[i + 1] -- 3514
				if m.kind ~= 0 then -- 3515
					goto __continue540 -- 3516
				end -- 3516
				local dx = self.player.x - m.x -- 3518
				local dy = self.player.y - m.y -- 3519
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3520
					self.checkpoint = m.x -- 3521
					self:captureCheckpoint(m.x) -- 3522
					self:flashSet("检查点", 1) -- 3523
				end -- 3523
			end -- 3523
			::__continue540:: -- 3523
			i = i + 1 -- 3513
		end -- 3513
	end -- 3513
end -- 3511
function Play.prototype.campaignInteract(self) -- 3529
	local b = self:findInteract() -- 3530
	if b ~= nil then -- 3531
		self:useInteract(b) -- 3532
		return -- 3533
	end -- 3533
	local inv = self.run.inventory -- 3535
	if inv.wedge > 0 then -- 3536
		local w = self:findWedgeTarget() -- 3537
		if w ~= nil then -- 3538
			if w.breakable ~= nil then -- 3539
				local ____w_breakable_46, ____hp_47 = w.breakable, "hp" -- 3540
				____w_breakable_46[____hp_47] = ____w_breakable_46[____hp_47] + (w.breakable.wedgeHp or 1) -- 3540
			end -- 3540
			inv.wedge = inv.wedge - 1 -- 3542
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3543
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 3545
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3546
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3547
			return -- 3548
		end -- 3548
	end -- 3548
	if inv.ammo > 0 and self.reloadT > 0 then -- 3551
		self.reloadT = 0 -- 3553
		self:closeReloadPuzzle() -- 3554
		inv.ammo = inv.ammo - 1 -- 3555
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3556
		self:log("用备用弹包") -- 3557
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3558
		return -- 3559
	end -- 3559
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 3561
		local p = self.player -- 3563
		self.bracedShield = { -- 3564
			x = p.x + p.facing * 26, -- 3564
			y = p.y, -- 3564
			w = 30, -- 3564
			h = 64, -- 3564
			hp = 1 -- 3564
		} -- 3564
		local ____self_boxes_48 = self.boxes -- 3565
		____self_boxes_48[#____self_boxes_48 + 1] = { -- 3565
			x0 = self.bracedShield.x - 15, -- 3566
			x1 = self.bracedShield.x + 15, -- 3566
			y0 = p.y, -- 3567
			y1 = p.y + 64, -- 3567
			depth = {min = -46, max = 46}, -- 3567
			label = "架起的残盾", -- 3567
			id = "braced_shield", -- 3567
			soft = true -- 3568
		} -- 3568
		inv.shield = inv.shield - 1 -- 3571
		self:flashSet("架残盾 · 挡一发", 1.2) -- 3572
		self:log("架残盾") -- 3573
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3574
		return -- 3575
	end -- 3575
	if inv.pass > 0 and self.run.joined == false then -- 3577
		inv.pass = inv.pass - 1 -- 3578
		self.run.joined = true -- 3579
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3580
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3581
		return -- 3582
	end -- 3582
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3584
end -- 3529
function Play.prototype.useInteract(self, b) -- 3587
	local kind = b.interact == nil and "" or b.interact.kind -- 3588
	local wr = self.room -- 3589
	if kind == "open_board" then -- 3590
		b.broken = true -- 3591
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3592
		for ____, cover in ipairs(self.boxes) do -- 3593
			if cover.id == "s2_board_cover" then -- 3594
				cover.broken = false -- 3595
				cover.hidden = false -- 3596
			end -- 3596
		end -- 3596
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3599
		self.run.joined = true -- 3600
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3601
		self:log("放下窗板") -- 3602
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3603
		return -- 3604
	end -- 3604
	if kind == "lower_curtain" then -- 3606
		for ____, curtain in ipairs(self.boxes) do -- 3607
			if curtain.id == "c2_curtain" then -- 3608
				curtain.broken = false -- 3609
				curtain.hidden = false -- 3610
			end -- 3610
		end -- 3610
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3613
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3614
		self:log("放下木帘") -- 3615
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3616
		return -- 3617
	end -- 3617
	if kind == "raise_latch" then -- 3619
		if wr.key == "c2-granary" and not self.cartDocked then -- 3620
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3621
			return -- 3622
		end -- 3622
		b.broken = true -- 3624
		self.objectiveDone = true -- 3625
		if wr.key == "c1-yard" then -- 3627
			self.run.c1Latch = true -- 3628
			self.run.joined = true -- 3629
			for ____, door in ipairs(self.boxes) do -- 3630
				if door.id == "c1_door" then -- 3631
					door.broken = true -- 3632
				end -- 3632
			end -- 3632
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3635
		else -- 3635
			self.run.c2Latch = true -- 3637
			self.run.joined = true -- 3638
		end -- 3638
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3640
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3641
		self:log("抬闩") -- 3642
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3643
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3644
	end -- 3644
end -- 3587
function Play.prototype.stepCampaignCart(self, dt, input) -- 3649
	local wr = self.room -- 3650
	local c = wr.cart -- 3651
	if c.bodyW <= 0 then -- 3652
		return -- 3653
	end -- 3653
	local p = self.player -- 3655
	local handleX = self.cartAxle + c.handleOffset -- 3656
	if not self.gripping then -- 3657
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3658
			self.gripping = true -- 3660
			self:flashSet("握住车柄 · A/D 推", 1) -- 3661
		end -- 3661
		return -- 3663
	end -- 3663
	if input.interact.pressed then -- 3665
		self.gripping = false -- 3666
		self:flashSet("松手", 0.5) -- 3667
		return -- 3668
	end -- 3668
	if not self.cartDocked then -- 3670
		if input.moveX ~= 0 and not self:stuckCart() then -- 3671
			self.cartAxle = math.max( -- 3672
				c.startX, -- 3672
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3672
			) -- 3672
		end -- 3672
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3676
			self.cartExposed = true -- 3677
			local gun = nil -- 3678
			local gi = 0 -- 3679
			do -- 3679
				gi = 0 -- 3680
				while gi < #self.enemies do -- 3680
					local e = self.enemies[gi + 1] -- 3681
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3682
						gun = e -- 3683
						break -- 3684
					end -- 3684
					gi = gi + 1 -- 3680
				end -- 3680
			end -- 3680
			if gun ~= nil then -- 3687
				self:campaignEnemyFire(gun) -- 3688
			end -- 3688
		end -- 3688
		p.x = self.cartAxle + c.handleOffset -- 3691
		p.y = c.baseY -- 3692
		p.depth = c.depth or 0 -- 3693
		p.vx = 0 -- 3694
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3695
			self.cartAxle = c.endX -- 3696
			self.cartDocked = true -- 3697
			self.gripping = false -- 3698
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3699
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3700
			self:flashSet("车轮入窝", 1.2) -- 3701
			self:log("车轮入窝") -- 3702
		end -- 3702
	end -- 3702
end -- 3649
function Play.prototype.stuckCart(self) -- 3708
	local i = 0 -- 3709
	do -- 3709
		i = 0 -- 3710
		while i < #self.boxes do -- 3710
			do -- 3710
				local b = self.boxes[i + 1] -- 3711
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3712
					goto __continue582 -- 3713
				end -- 3713
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3715
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3716
					return true -- 3717
				end -- 3717
			end -- 3717
			::__continue582:: -- 3717
			i = i + 1 -- 3710
		end -- 3710
	end -- 3710
	return false -- 3720
end -- 3708
function Play.prototype.stepCampaignGoal(self) -- 3724
	local wr = self.room -- 3725
	local c = wr.campaign -- 3726
	if c == nil then -- 3727
		return -- 3728
	end -- 3728
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3730
		self.objectiveDone = true -- 3731
	end -- 3731
	if c.goal == "reach_exit" then -- 3733
		self.objectiveDone = true -- 3734
	end -- 3734
	if not self.objectiveDone then -- 3736
		return -- 3737
	end -- 3737
	local p = self.player -- 3739
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3740
	if p.x < c.exitX or not partnerOk then -- 3741
		return -- 3742
	end -- 3742
	if self.run.story.segments[wr.key] ~= true then -- 3745
		self.run.story.segments[wr.key] = true -- 3746
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3747
	end -- 3747
	if wr.key == "escort5" then -- 3750
		self.escortDone = true -- 3751
		self.run.story.escortDone = true -- 3752
	end -- 3752
	if c.next ~= nil and c.next ~= "" then -- 3754
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3755
		self:flashSet("过关 · " .. c.next, 1.2) -- 3756
	elseif wr.key == "c2-granary" and self.run.trial == nil and (self.run.source == "official" or self.run.source == "chapter") then -- 3757
		self:requestRoom("gate", "军粮棚出口") -- 3759
		self:flashSet("出军粮棚 · 城门", 1.4) -- 3760
	elseif not self.run.finished then -- 3761
		self.run.finished = true -- 3762
		self:flashSet( -- 3763
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3763
			2 -- 3763
		) -- 3763
		self:log("C2 灰盒完成") -- 3764
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3765
	end -- 3765
end -- 3724
function Play.prototype.stepCampaignPartner(self, dt) -- 3770
	local a = self.partner -- 3771
	local wr = self.room -- 3772
	local cp = wr.companion -- 3773
	if not a.alive then -- 3774
		return -- 3775
	end -- 3775
	local p = self.player -- 3777
	if self.craftBench.active then -- 3779
		a.vx = 0 -- 3780
		return -- 3781
	end -- 3781
	local wait = false -- 3783
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3784
	local targetDepth = p.depth -- 3785
	if self.run.joined == false then -- 3786
		wait = true -- 3787
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3788
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3789
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3790
		wait = true -- 3791
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3792
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3793
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3794
		wait = true -- 3795
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3796
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3797
	end -- 3797
	if self.partnerStuck > 0.3 then -- 3799
		a.x = a.x + a.facing * 44 -- 3801
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3802
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3803
		self.partnerLaneHold = 1.1 -- 3804
		self.partnerStuck = 0 -- 3805
	end -- 3805
	if self.partnerLaneHold > 0 then -- 3807
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3808
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3809
	end -- 3809
	local dx = targetX - a.x -- 3811
	local stopTol = wait and 18 or 74 -- 3812
	if math.abs(dx) > stopTol then -- 3813
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3814
		local before = a.x -- 3815
		a.vx = dx > 0 and speed or -speed -- 3816
		a.facing = dx > 0 and 1 or -1 -- 3817
		self:slideX(a, a.vx * dt) -- 3818
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3820
			a.vy = CHILD_JUMP -- 3821
			a.onGround = false -- 3822
		end -- 3822
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3824
	else -- 3824
		a.vx = 0 -- 3826
		self.partnerStuck = 0 -- 3827
	end -- 3827
	local dz = targetDepth - a.depth -- 3829
	if math.abs(dz) > 6 then -- 3830
		local step = math.max( -- 3831
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3831
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3831
		) -- 3831
		a.depth = a.depth + step -- 3832
	end -- 3832
	a.depthSpeed = 0 -- 3834
	a.h = CHILD_H -- 3835
	a.crouch = false -- 3836
	self:fallY(a, dt) -- 3837
end -- 3770
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3841
	local p = self.player -- 3842
	local i = 0 -- 3843
	do -- 3843
		i = 0 -- 3844
		while i < #self.enemies do -- 3844
			do -- 3844
				local ____opt_49 = self.run.trial -- 3845
				if ____opt_49 and ____opt_49.lost then -- 3845
					return -- 3845
				end -- 3845
				local e = self.enemies[i + 1] -- 3846
				if e.kind == "target" then -- 3847
					if not e.alive then -- 3849
						if e.hitT > 0 then -- 3850
							e.hitT = e.hitT - dt -- 3851
						end -- 3851
						if e.hitT <= 0 then -- 3853
							e.alive = true -- 3854
							e.hitT = 0 -- 3855
						end -- 3855
					end -- 3855
					goto __continue610 -- 3858
				end -- 3858
				if not e.alive then -- 3860
					goto __continue610 -- 3861
				end -- 3861
				if e.hitT > 0 then -- 3863
					e.hitT = e.hitT - dt -- 3864
				end -- 3864
				if e.kind == "breaker" then -- 3866
					self:stepBreaker(e, dt) -- 3867
					goto __continue610 -- 3868
				end -- 3868
				if e.kind == "shield" then -- 3870
					self:stepShield(e, dt, input) -- 3871
					goto __continue610 -- 3872
				end -- 3872
				local dx = e.x - p.x -- 3875
				if not e.awake then -- 3876
					if math.abs(dx) > 520 then -- 3877
						goto __continue610 -- 3878
					end -- 3878
					e.awake = true -- 3880
					e.fireCd = 48 -- 3881
					goto __continue610 -- 3882
				end -- 3882
				if math.abs(dx) > ENEMY_RANGE then -- 3884
					goto __continue610 -- 3885
				end -- 3885
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 3889
					goto __continue610 -- 3890
				end -- 3890
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 3892
					goto __continue610 -- 3893
				end -- 3893
				if self:blockedShot(e, p) then -- 3895
					if e.warnT > 0 then -- 3898
						e.warnT = 0 -- 3899
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3900
					end -- 3900
					goto __continue610 -- 3902
				end -- 3902
				if e.warnT > 0 then -- 3904
					e.warnT = e.warnT - 1 -- 3905
					if e.warnT <= 0 then -- 3906
						self:campaignEnemyFire(e) -- 3907
					end -- 3907
				elseif e.fireCd > 0 then -- 3909
					e.fireCd = e.fireCd - 1 -- 3910
					if e.fireCd <= 0 then -- 3911
						e.warnT = WARN_TICKS -- 3912
					end -- 3912
				else -- 3912
					e.fireCd = 40 -- 3915
				end -- 3915
			end -- 3915
			::__continue610:: -- 3915
			i = i + 1 -- 3844
		end -- 3844
	end -- 3844
end -- 3841
function Play.prototype.blockedShot(self, e, p) -- 3921
	local eDepth = e.depth or 0 -- 3922
	local ex = e.x -- 3923
	local ey = e.y + e.h * 0.62 -- 3925
	local px = p.x -- 3926
	local py = p.y + p.h * 0.55 -- 3927
	local dx = px - ex -- 3928
	local dyScreen = py + p.depth * DEPTH_Y_SCALE - (ey + eDepth * DEPTH_Y_SCALE) -- 3929
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3930
	if len < 0.01 then -- 3931
		return false -- 3932
	end -- 3932
	local ray = { -- 3936
		x = ex, -- 3937
		y = ey, -- 3937
		dx = dx / len, -- 3938
		dy = (py - ey) / len, -- 3938
		depth = eDepth, -- 3939
		dDepth = (p.depth - eDepth) / len -- 3939
	} -- 3939
	local best = -1 -- 3941
	local j = 0 -- 3942
	do -- 3942
		j = 0 -- 3943
		while j < #self.boxes do -- 3943
			do -- 3943
				local b = self.boxes[j + 1] -- 3944
				if b.broken == true or b.passable == true or b.hidden == true then -- 3945
					goto __continue635 -- 3946
				end -- 3946
				if b.id == "braced_shield" then -- 3950
					goto __continue635 -- 3951
				end -- 3951
				local t = hitBox(ray, b) -- 3953
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3956
					best = t -- 3957
				end -- 3957
			end -- 3957
			::__continue635:: -- 3957
			j = j + 1 -- 3943
		end -- 3943
	end -- 3943
	return best >= 0 -- 3960
end -- 3921
function Play.prototype.campaignEnemyFire(self, e) -- 3963
	local p = self.player -- 3964
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3965
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3966
		local ____self_bracedShield_51, ____hp_52 = self.bracedShield, "hp" -- 3967
		____self_bracedShield_51[____hp_52] = ____self_bracedShield_51[____hp_52] - 1 -- 3967
		self.boxes = __TS__ArrayFilter( -- 3968
			self.boxes, -- 3968
			function(____, b) return b.id ~= "braced_shield" end -- 3968
		) -- 3968
		self.bracedShield = nil -- 3969
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3970
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3971
		return -- 3972
	end -- 3972
	if self:blockedShot(e, p) then -- 3974
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3975
		return -- 3976
	end -- 3976
	local cover = self:blockedByCover(e, p) -- 3978
	if cover ~= nil and self.coverHug then -- 3979
		self.coveredFlash = 0.5 -- 3980
		self:flashSet("掩体挡下", 0.6) -- 3981
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3982
		return -- 3987
	end -- 3987
	if self.invulnT > 0 then -- 3989
		return -- 3990
	end -- 3990
	self.invulnT = INVULN_HIT_TICKS + 12 * self:talentRank("guard") -- 3992
	self.craftT = 0 -- 3993
	self.hp = self.hp - 1 -- 3994
	self:emit("actorHit", { -- 3995
		target = "player", -- 3995
		amount = 1, -- 3995
		hp = self.hp, -- 3995
		maxHp = self.maxHp, -- 3995
		enemyX = e.x -- 3995
	}) -- 3995
	self:flashSet( -- 3996
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3996
		0.8 -- 3996
	) -- 3996
	if self.hp <= 0 then -- 3997
		self:campaignFailed() -- 3998
	end -- 3998
end -- 3963
function Play.prototype.stepShield(self, e, dt, input) -- 4003
	local p = self.player -- 4004
	local dx = p.x - e.x -- 4005
	local adx = math.abs(dx) -- 4006
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 4009
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 4010
	if adx > 44 then -- 4011
		local before = e.x -- 4012
		local stepX = (dx > 0 and 1 or -1) * 60 * dt -- 4013
		local nextX = math.max( -- 4014
			self.room.minX + 16, -- 4014
			math.min(self.room.maxX - 16, e.x + stepX) -- 4014
		) -- 4014
		if not self:enemyBlockedAtX(e, nextX) then -- 4015
			e.x = nextX -- 4016
		end -- 4016
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 4018
			e.depth = math.max( -- 4020
				-32, -- 4020
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4020
			) -- 4020
		end -- 4020
	elseif adx <= 48 and sameLane and (e.swingT or 0) <= 0 then -- 4022
		local fromFront = (e.x - p.x) * p.facing > 0 -- 4025
		local rollDodges = p.rollT > 0 and fromFront -- 4026
		if not rollDodges and self.invulnT <= 0 then -- 4027
			self.invulnT = INVULN_HIT_TICKS + 12 * self:talentRank("guard") -- 4028
			self.craftT = 0 -- 4029
			self.hp = self.hp - 1 -- 4030
			self:emit("actorHit", { -- 4031
				target = "player", -- 4031
				amount = 1, -- 4031
				hp = self.hp, -- 4031
				maxHp = self.maxHp, -- 4031
				enemyX = e.x -- 4031
			}) -- 4031
			self:flashSet( -- 4032
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4032
				0.8 -- 4032
			) -- 4032
			if self.hp <= 0 then -- 4033
				self:campaignFailed() -- 4034
				return -- 4035
			end -- 4035
		end -- 4035
		e.swingT = 70 -- 4038
	end -- 4038
	if (e.swingT or 0) > 0 then -- 4040
		e.swingT = (e.swingT or 0) - 1 -- 4041
	end -- 4041
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 4043
		local dd = p.depth - (e.depth or 0) -- 4044
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 4045
	end -- 4045
end -- 4003
function Play.prototype.stepBreaker(self, e, dt) -- 4050
	local p = self.player -- 4051
	if e.awake ~= true then -- 4052
		if math.abs(p.x - e.x) < 560 then -- 4053
			e.awake = true -- 4054
		else -- 4054
			return -- 4056
		end -- 4056
	end -- 4056
	local target = nil -- 4059
	local bestD = 1000000000 -- 4060
	local i = 0 -- 4061
	do -- 4061
		i = 0 -- 4062
		while i < #self.boxes do -- 4062
			do -- 4062
				local b = self.boxes[i + 1] -- 4063
				if b.breakable == nil or b.broken == true then -- 4064
					goto __continue660 -- 4065
				end -- 4065
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 4067
				if d < bestD then -- 4068
					bestD = d -- 4069
					target = b -- 4070
				end -- 4070
			end -- 4070
			::__continue660:: -- 4070
			i = i + 1 -- 4062
		end -- 4062
	end -- 4062
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 4073
	local dx = tx - e.x -- 4074
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 4075
	if math.abs(dx) > reach then -- 4076
		local before = e.x -- 4077
		local nextX = math.max( -- 4078
			self.room.minX + 16, -- 4078
			math.min(self.room.maxX - 16, e.x + (dx > 0 and 1 or -1) * 48 * dt) -- 4078
		) -- 4078
		if not self:enemyBlockedAtX(e, nextX) then -- 4079
			e.x = nextX -- 4080
		end -- 4080
		if math.abs(e.x - before) < 0.3 then -- 4082
			e.depth = math.max( -- 4083
				-32, -- 4083
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4083
			) -- 4083
		end -- 4083
	elseif (e.swingT or 0) <= 0 then -- 4085
		e.swingT = 64 -- 4086
		if target ~= nil then -- 4087
			self:damageProp(target, 2) -- 4088
		elseif math.abs(p.x - e.x) < 60 and math.abs((e.depth or 0) - p.depth) <= 26 and self.invulnT <= 0 then -- 4089
			self.invulnT = INVULN_HIT_TICKS + 12 * self:talentRank("guard") -- 4090
			self.craftT = 0 -- 4091
			self.hp = self.hp - 1 -- 4092
			self:emit("actorHit", { -- 4093
				target = "player", -- 4093
				amount = 1, -- 4093
				hp = self.hp, -- 4093
				maxHp = self.maxHp, -- 4093
				enemyX = e.x -- 4093
			}) -- 4093
			self:flashSet("破障手近身", 0.8) -- 4094
			if self.hp <= 0 then -- 4095
				self:campaignFailed() -- 4096
				return -- 4097
			end -- 4097
		end -- 4097
	end -- 4097
	if (e.swingT or 0) > 0 then -- 4101
		e.swingT = (e.swingT or 0) - 1 -- 4102
	end -- 4102
end -- 4050
function Play.prototype.enemyBlockedAtX(self, e, nextX) -- 4107
	local half = e.w * 0.5 -- 4108
	local d = e.depth or 0 -- 4109
	local i = 0 -- 4110
	do -- 4110
		i = 0 -- 4111
		while i < #self.boxes do -- 4111
			do -- 4111
				local b = self.boxes[i + 1] -- 4112
				if b.broken == true or b.passable == true or b.soft == true or b.hidden == true or b.y0 >= e.y + e.h or b.y1 <= e.y + 4 then -- 4113
					goto __continue673 -- 4114
				end -- 4114
				if b.depth ~= nil and (d < b.depth.min - 8 or d > b.depth.max + 8) then -- 4116
					goto __continue673 -- 4117
				end -- 4117
				if nextX + half > b.x0 and nextX - half < b.x1 then -- 4119
					return true -- 4120
				end -- 4120
			end -- 4120
			::__continue673:: -- 4120
			i = i + 1 -- 4111
		end -- 4111
	end -- 4111
	return false -- 4123
end -- 4107
function Play.prototype.campaignFailed(self) -- 4126
	if self.run.trial ~= nil then -- 4127
		self.run.trial.lost = true -- 4128
		self.wantRoom = "" -- 4129
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4130
		return -- 4131
	end -- 4131
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 4135
		self:restartEscortFromDeath() -- 4136
		return -- 4137
	end -- 4137
	local p = self.player -- 4139
	self.hp = self.maxHp -- 4140
	self.invulnT = INVULN_RESPAWN_TICKS -- 4141
	self.reloadT = 0 -- 4142
	self:closeReloadPuzzle() -- 4143
	self.gripping = false -- 4144
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 4145
	self:log("被击倒") -- 4146
	p.x = self.room.minX + 90 -- 4147
	p.y = 0 -- 4148
	p.depth = 0 -- 4149
	p.vx = 0 -- 4150
	p.vy = 0 -- 4151
	p.onGround = true -- 4152
	p.rollT = 0 -- 4153
	self.partner.x = p.x - 50 -- 4154
	self.partner.y = 0 -- 4155
	self.partner.depth = 0 -- 4156
	self.cam.x = p.x -- 4157
	local i = 0 -- 4158
	do -- 4158
		i = 0 -- 4159
		while i < #self.enemies do -- 4159
			do -- 4159
				local e = self.enemies[i + 1] -- 4160
				if not e.alive then -- 4161
					goto __continue681 -- 4162
				end -- 4162
				e.x = e.homeX == nil and e.x or e.homeX -- 4164
				e.warnT = 0 -- 4165
				e.fireCd = 40 -- 4166
				e.swingT = 0 -- 4167
				e.awake = false -- 4168
			end -- 4168
			::__continue681:: -- 4168
			i = i + 1 -- 4159
		end -- 4159
	end -- 4159
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4170
end -- 4126
function Play.prototype.isEscortRoom(self) -- 4174
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 4175
end -- 4174
function Play.prototype.restartEscortFromDeath(self) -- 4183
	local story = self.run.story -- 4184
	local inv = self.run.inventory -- 4185
	local vitBonus = story.talents ~= nil and story.talents.ranks.vitality or 0 -- 4186
	if vitBonus > 0 then -- 4187
		self.maxHp = math.max(3, self.maxHp - vitBonus) -- 4188
		story.maxHp = self.maxHp -- 4189
	end -- 4189
	story.talents = createStoryTalents(self.run.seed) -- 4191
	self.hp = self.maxHp -- 4192
	story.hp = self.maxHp -- 4193
	story.cp = nil -- 4194
	self.checkpointSnap = nil -- 4195
	story.carry = false -- 4196
	self.carryOn = false -- 4197
	story.craftedWeapon = "" -- 4198
	self.equippedWeapon = "standard_gun" -- 4199
	story.equippedWeapon = "standard_gun" -- 4200
	story.escortDone = false -- 4201
	self.escortDone = false -- 4202
	story.segments = {} -- 4203
	inv.wood = 0 -- 4204
	inv.bell = 0 -- 4205
	inv.scrap = 0 -- 4206
	inv.wedge = 0 -- 4207
	inv.ammo = 0 -- 4208
	inv.quickbelt = 0 -- 4209
	inv.shield = 0 -- 4210
	inv.pass = 0 -- 4211
	local taken = self.run.taken -- 4212
	local keys = __TS__ObjectKeys(taken) -- 4213
	local i = 0 -- 4214
	do -- 4214
		i = 0 -- 4215
		while i < #keys do -- 4215
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 4216
				__TS__Delete(taken, keys[i + 1]) -- 4217
			end -- 4217
			i = i + 1 -- 4215
		end -- 4215
	end -- 4215
	self.run.joined = true -- 4220
	self.reloadT = 0 -- 4221
	self:closeReloadPuzzle() -- 4222
	self.gripping = false -- 4223
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 4224
	self:log("男主线失败 · 回 escort1") -- 4225
	self:emit("campaignFailed", { -- 4226
		room = self.room.key, -- 4227
		hp = 0, -- 4227
		maxHp = self.maxHp, -- 4227
		reset = true, -- 4228
		to = "escort1", -- 4228
		route = self.storyRoute -- 4228
	}) -- 4228
	self:requestRoom("escort1", "男主线失败重开") -- 4230
end -- 4183
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 4234
	local i = 0 -- 4235
	do -- 4235
		i = 0 -- 4236
		while i < #self.enemies do -- 4236
			do -- 4236
				if i == skipIndex then -- 4237
					goto __continue691 -- 4238
				end -- 4238
				local e = self.enemies[i + 1] -- 4240
				if not e.alive or math.abs(e.x - center.x) > radius then -- 4241
					goto __continue691 -- 4242
				end -- 4242
				e.fireCd = 150 -- 4244
				e.warnT = 0 -- 4245
			end -- 4245
			::__continue691:: -- 4245
			i = i + 1 -- 4236
		end -- 4236
	end -- 4236
end -- 4234
function Play.prototype.stepEnemies(self, dt, input) -- 4249
	local i = 0 -- 4250
	do -- 4250
		i = 0 -- 4251
		while i < #self.enemies do -- 4251
			local e = self.enemies[i + 1] -- 4252
			if e.hitT > 0 then -- 4253
				e.hitT = e.hitT - dt -- 4254
			end -- 4254
			i = i + 1 -- 4251
		end -- 4251
	end -- 4251
	if self.coveredFlash > 0 then -- 4257
		self.coveredFlash = self.coveredFlash - dt -- 4258
	end -- 4258
	if self.isCampaign then -- 4260
		self:stepCampaignEnemies(dt, input) -- 4261
		return -- 4262
	end -- 4262
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 4265
		return -- 4266
	end -- 4266
	do -- 4266
		i = 0 -- 4268
		while i < #self.enemies do -- 4268
			do -- 4268
				local e = self.enemies[i + 1] -- 4269
				if not e.alive then -- 4270
					goto __continue702 -- 4271
				end -- 4271
				if e.warnT > 0 then -- 4273
					e.warnT = e.warnT - 1 -- 4274
					if e.warnT <= 0 then -- 4275
						self:enemyFire(e, input) -- 4276
					end -- 4276
					goto __continue702 -- 4278
				end -- 4278
				if e.fireCd > 0 then -- 4280
					e.fireCd = e.fireCd - 1 -- 4281
					if e.fireCd <= 0 then -- 4282
						e.warnT = WARN_TICKS -- 4283
					end -- 4283
				else -- 4283
					e.warnT = WARN_TICKS -- 4287
				end -- 4287
			end -- 4287
			::__continue702:: -- 4287
			i = i + 1 -- 4268
		end -- 4268
	end -- 4268
end -- 4249
function Play.prototype.enemyFire(self, e, input) -- 4293
	local p = self.player -- 4294
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 4295
		self:flashSet("枪声响在远处", 0.4) -- 4296
		e.fireCd = FIRE_COOLDOWN -- 4297
		return -- 4298
	end -- 4298
	if self:blockedShot(e, p) then -- 4300
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4301
		e.fireCd = FIRE_COOLDOWN -- 4302
		return -- 4303
	end -- 4303
	local cover = self:blockedByCover(e, p) -- 4306
	local hugging = cover ~= nil -- 4307
	self.coverBlocking = hugging -- 4308
	local covered = hugging and input.cover.held -- 4309
	if covered then -- 4310
		self.coveredFlash = 0.5 -- 4311
		self:flashSet("掩体挡下", 0.5) -- 4312
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4313
		e.fireCd = FIRE_COOLDOWN -- 4318
		return -- 4319
	end -- 4319
	if self.invulnT > 0 then -- 4321
		e.fireCd = FIRE_COOLDOWN -- 4322
		return -- 4323
	end -- 4323
	self.invulnT = INVULN_HIT_TICKS -- 4325
	self.hp = self.hp - 1 -- 4326
	self:emit("actorHit", { -- 4327
		target = "player", -- 4327
		amount = 1, -- 4327
		hp = self.hp, -- 4327
		maxHp = self.maxHp, -- 4327
		enemyX = e.x -- 4327
	}) -- 4327
	self:flashSet( -- 4328
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4328
		0.7 -- 4328
	) -- 4328
	e.fireCd = FIRE_COOLDOWN -- 4329
	if self.hp <= 0 then -- 4330
		self:gateFailed() -- 4331
	end -- 4331
end -- 4293
function Play.prototype.blockedByCover(self, enemy, p) -- 4336
	local b = self:coverAt(p) -- 4337
	if b == nil then -- 4338
		return nil -- 4339
	end -- 4339
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4341
end -- 4336
function Play.prototype.gateFailed(self) -- 4345
	local ____temp_53 -- 4346
	if self.room.story == nil then -- 4346
		____temp_53 = nil -- 4346
	else -- 4346
		____temp_53 = self.room.story.gate -- 4346
	end -- 4346
	local g = ____temp_53 -- 4346
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 4347
	self.hp = self.maxHp -- 4348
	self.gateTick = 0 -- 4349
	self.gateSpawned = 0 -- 4350
	self.enemies = {} -- 4351
	self.gateFailCount = self.gateFailCount + 1 -- 4352
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 4354
	self.player.y = 0 -- 4355
	self.player.vy = 0 -- 4356
	self.player.depth = 0 -- 4357
	self.player.depthSpeed = 0 -- 4358
	self.player.onGround = true -- 4359
	self.player.crouch = false -- 4360
	self.player.h = SOLDIER_H -- 4361
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 4362
	self.partner.y = 0 -- 4363
	self.partner.vy = 0 -- 4364
	self.partner.depth = 0 -- 4365
	self.partner.depthSpeed = 0 -- 4366
	self.partner.onGround = true -- 4367
	self.cam.x = self.player.x -- 4368
	self.phase = "gate-idle" -- 4369
	self.phaseTick = 0 -- 4370
	self.coverHug = false -- 4371
	self.coverBlocking = false -- 4372
	self.coverEntity = "" -- 4373
	self.gateNeedConfirm = true -- 4374
	self.gateRestartArmed = false -- 4375
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 4376
end -- 4345
function Play.prototype.stepRedCart(self, input) -- 4380
	if self.redCartMemoryT > 0 then -- 4381
		self.redCartMemoryT = self.redCartMemoryT - 1 -- 4382
	end -- 4382
	if self.room.key ~= "outside" or self.redCartPulled then -- 4384
		return -- 4385
	end -- 4385
	local box = __TS__ArrayFind( -- 4387
		self.boxes, -- 4387
		function(____, b) return b.id == "outside_red_cart" end -- 4387
	) -- 4387
	if box == nil then -- 4388
		self.redCartPulled = true -- 4389
		return -- 4390
	end -- 4390
	local cx = (box.x0 + box.x1) * 0.5 -- 4392
	local p = self.player -- 4393
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 4394
		return -- 4395
	end -- 4395
	if not input.interact.pressed then -- 4397
		return -- 4398
	end -- 4398
	box.x0 = 430 -- 4400
	box.x1 = 474 -- 4401
	self.cartAxle = self.room.cart.endX -- 4403
	self.cartDocked = true -- 4404
	self.redCartPulled = true -- 4405
	self.redCartMemoryT = 30 -- 4406
	if self.run.story ~= nil then -- 4407
		self.run.story.segments.outside_cart = true -- 4408
		self.run.story.segments.outside_memory = true -- 4409
	end -- 4409
	self.sessionDirty = true -- 4411
	self:flashSet("红布补丁 · 想起家里那一针 · 石阶口露出来", 1.8) -- 4412
	self:emit("storyBeat", {beat = "red_cart", x = p.x, room = "outside"}) -- 4413
	self:emit("storyBeat", {beat = "red_cart_memory", x = p.x, room = "outside", durationTicks = 30}) -- 4414
end -- 4380
function Play.prototype.stepInteract(self, dt, input) -- 4417
	local p = self.player -- 4418
	self:stepRedCart(input) -- 4419
	local calmUsed = self.calmConsumed -- 4420
	self.calmConsumed = false -- 4421
	local calming = self.escort.state == "calming" -- 4423
	self.focusCart = false -- 4424
	if self.room.key == "outside" then -- 4425
		local c = self.room.cart -- 4426
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 4427
		local dy = p.y - c.baseY -- 4428
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 4429
	end -- 4429
	if not calmUsed and not calming then -- 4432
		self:stepCart(dt, input) -- 4433
	end -- 4433
	if calmUsed then -- 4437
		self:flashSet("安抚 · 敲两下", 0.8) -- 4438
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4439
		if self.knockT > 0 then -- 4441
			self.knocks = self.knocks + 1 -- 4442
		else -- 4442
			self.knocks = 1 -- 4444
		end -- 4444
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4446
		self.knockT = 1.2 -- 4447
		if self.knocks >= 2 then -- 4448
			self:flashSet("敲两下", 0.8) -- 4449
			self.knocks = 0 -- 4450
		else -- 4450
			self:flashSet("敲一下", 0.5) -- 4452
		end -- 4452
	elseif self.knockT > 0 then -- 4454
		self.knockT = self.knockT - dt -- 4455
		if self.knockT <= 0 then -- 4456
			self.knocks = 0 -- 4457
		end -- 4457
	end -- 4457
	local i = 0 -- 4462
	do -- 4462
		i = 0 -- 4463
		while i < #self.room.marks do -- 4463
			do -- 4463
				local m = self.room.marks[i + 1] -- 4464
				if m.kind ~= 0 then -- 4465
					goto __continue738 -- 4466
				end -- 4466
				local subjects = {self.partner, self.player} -- 4468
				local k = 0 -- 4469
				do -- 4469
					k = 0 -- 4470
					while k < #subjects do -- 4470
						do -- 4470
							local s = subjects[k + 1] -- 4471
							if not s.alive then -- 4472
								goto __continue741 -- 4473
							end -- 4473
							local dx = s.x - m.x -- 4475
							local dy = s.y - m.y -- 4476
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4477
								self.checkpoint = m.x -- 4478
								self.checkpointCartAxle = self.cartAxle -- 4479
								if self.isCampaign then -- 4481
									self:captureCheckpoint(m.x) -- 4482
								end -- 4482
								if self.cartDocked then -- 4484
									self:flashSet("检查点 · 车已落窝", 1) -- 4485
								else -- 4485
									self:flashSet("检查点 · 车还没到位", 1) -- 4487
								end -- 4487
							end -- 4487
						end -- 4487
						::__continue741:: -- 4487
						k = k + 1 -- 4470
					end -- 4470
				end -- 4470
			end -- 4470
			::__continue738:: -- 4470
			i = i + 1 -- 4463
		end -- 4463
	end -- 4463
	self:checkCarryGate() -- 4493
end -- 4417
function Play.prototype.stepVillage(self, dt, input) -- 4497
	if self.room.key ~= "village" then -- 4498
		return -- 4499
	end -- 4499
	local p = self.player -- 4501
	local bottle = self.room.bottle -- 4502
	local scav = self.room.scavenger -- 4503
	if not self.hasBottle and bottle ~= nil then -- 4506
		local dx = p.x - bottle.x -- 4507
		local dy = p.y + p.h * 0.5 - bottle.y -- 4508
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4509
			self.hasBottle = true -- 4510
			self:flashSet("拾起瓶子", 0.8) -- 4511
		end -- 4511
	end -- 4511
	if self.hasBottle then -- 4516
		if input.aim.held then -- 4517
			self.aimHold = self.aimHold + dt -- 4518
			if self.aimHold > 1.2 then -- 4519
				self.aimHold = 1.2 -- 4520
			end -- 4520
			local cached = self:bottleEnd() -- 4523
			self.bottleAimX = cached.x -- 4524
			self.bottleAimY = cached.y -- 4525
		elseif input.aim.released then -- 4526
			if self.aimHold < 0.12 then -- 4527
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 4529
				self.aimHold = 0 -- 4530
			else -- 4530
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4532
				self:throwBottle(____end.x, ____end.y) -- 4533
				self.aimHold = 0 -- 4534
			end -- 4534
		end -- 4534
	else -- 4534
		self.aimHold = 0 -- 4538
		self.bottleAimX = -1 -- 4539
	end -- 4539
	local fly = self.bottleFly -- 4544
	if fly ~= nil then -- 4545
		fly.t = fly.t + dt -- 4546
		fly.x = fly.x0 + fly.vx * fly.t -- 4547
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4548
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4549
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4550
			self:landBottle(fly) -- 4551
		end -- 4551
	end -- 4551
	if self.bottleLandT > 0 then -- 4554
		self.bottleLandT = self.bottleLandT - dt -- 4555
	end -- 4555
	if scav ~= nil then -- 4558
		self:stepScav(dt, scav) -- 4559
	end -- 4559
	local line = self.room.passLine -- 4562
	if line ~= nil and not self.passed and p.x >= line then -- 4563
		self.passed = true -- 4564
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4565
	end -- 4565
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4568
	if underTable then -- 4569
		self.footHintT = self.footHintT - 1 -- 4570
		if self.footHintT <= 0 then -- 4571
			self.footHintT = 90 -- 4572
			local scavX = self.scavX -- 4573
			local near = math.abs(scavX - p.x) < 120 -- 4574
			local walkingAway = self.scavState == "walk" and math.abs(self.scavTargetX - p.x) >= 120 -- 4575
			local heard = self.scavState == "chase" or near and not walkingAway -- 4576
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4577
			self:emit("storyBeat", {beat = heard and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4578
		end -- 4578
	else -- 4578
		self.footHintT = 0 -- 4581
	end -- 4581
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4584
		self.ditchHinted = true -- 4585
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4586
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4587
	end -- 4587
	if self.passed and p.x >= self.ox + 640 then -- 4590
		self:requestRoom("forest", "过第一院出院") -- 4591
		self:flashSet("钻出暗渠 · 北塔森林", 1.4) -- 4592
	end -- 4592
end -- 4497
function Play.prototype.bottleEnd(self) -- 4597
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4598
	local clampedX = math.max( -- 4601
		self.room.minX + 12, -- 4601
		math.min(self.room.maxX - 12, aim.x) -- 4601
	) -- 4601
	local g = self:groundAt(clampedX, aim.y + 240, 3) -- 4602
	return {x = clampedX, y = g} -- 4603
end -- 4597
function Play.prototype.throwBottle(self, tx, ty) -- 4607
	local p = self.player -- 4608
	local dir = tx >= p.x and 1 or -1 -- 4610
	p.facing = dir -- 4611
	local x0 = p.x + dir * 10 -- 4612
	local y0 = p.y + p.h * 0.7 -- 4613
	self.bottleTargetX = tx -- 4614
	self.bottleTargetY = ty -- 4615
	self.bottleSurfaceY = ty -- 4616
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4617
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4618
	self.bottleFly = { -- 4619
		x = x0, -- 4619
		y = y0, -- 4619
		x0 = x0, -- 4619
		y0 = y0, -- 4619
		vx = vx, -- 4619
		vy = vy, -- 4619
		t = 0 -- 4619
	} -- 4619
	self.hasBottle = false -- 4620
	self:flashSet("投出", 0.4) -- 4621
	self:emit( -- 4622
		"bottleThrown", -- 4622
		{ -- 4622
			fromX = x0, -- 4623
			fromY = y0, -- 4624
			targetX = tx, -- 4625
			targetY = ty, -- 4626
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4627
		} -- 4627
	) -- 4627
end -- 4607
function Play.prototype.bottleSurfaceAt(self, x) -- 4632
	if self.room.softX ~= nil and math.abs(x - self.room.softX) <= 34 then -- 4633
		return "soft" -- 4634
	end -- 4634
	if self.room.basinX ~= nil and math.abs(x - self.room.basinX) <= 24 then -- 4636
		return "iron" -- 4637
	end -- 4637
	return "brick" -- 4639
end -- 4632
function Play.prototype.landBottle(self, fly) -- 4643
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4644
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4645
	local s = self.room.scavenger -- 4646
	local surface = self:bottleSurfaceAt(x) -- 4647
	local effRange = s == nil and 0 or (surface == "iron" and s.range * 1.25 or s.range) -- 4648
	local heard = surface ~= "soft" and s ~= nil and math.abs(x - self.scavX) <= effRange -- 4649
	local stallTicks = s == nil and 0 or (surface == "iron" and s.stallTicks + 90 or s.stallTicks) -- 4650
	self.bottleFly = nil -- 4651
	self.bottleTargetX = -1 -- 4652
	self.bottleTargetY = 0 -- 4653
	self.bottleSurfaceY = -1 -- 4654
	self.bottleLandX = x -- 4655
	self.bottleLandY = y -- 4656
	self.bottleLandT = 0.9 -- 4657
	self:emit("bottleLanded", { -- 4658
		x = x, -- 4659
		y = y, -- 4660
		surface = surface, -- 4661
		heard = heard, -- 4662
		resonance = surface == "iron", -- 4663
		stallTicks = heard and stallTicks or 0, -- 4664
		scavState = self.scavState -- 4665
	}) -- 4665
	self:hearBottle(x, surface) -- 4667
end -- 4643
function Play.prototype.hearBottle(self, x, surface) -- 4671
	if surface == nil then -- 4671
		surface = "brick" -- 4671
	end -- 4671
	local s = self.room.scavenger -- 4672
	if s == nil then -- 4673
		return -- 4674
	end -- 4674
	if surface == "soft" then -- 4676
		self:flashSet("落在软土 · 没出声", 0.8) -- 4677
		return -- 4678
	end -- 4678
	local effRange = surface == "iron" and s.range * 1.25 or s.range -- 4680
	if math.abs(x - self.scavX) > effRange then -- 4681
		self:flashSet("落地 · 他没听见", 0.6) -- 4682
		return -- 4683
	end -- 4683
	self.scavState = "turn" -- 4685
	self.scavT = s.hearTicks -- 4686
	self.scavTargetX = surface == "iron" and self.room.basinX ~= nil and self.room.basinX or x -- 4687
	self.scavStallBonus = surface == "iron" and 90 or 0 -- 4688
	self:flashSet(surface == "iron" and "铁盆余振两响 · 他停下来细听" or "砖地一响 · 他转头", 1.1) -- 4689
end -- 4671
function Play.prototype.stepScav(self, dt, s) -- 4693
	if self.scavState == "chase" then -- 4695
		return -- 4696
	end -- 4696
	if self.scavState == "turn" then -- 4698
		self.scavT = self.scavT - 1 -- 4699
		if self.scavT <= 0 then -- 4700
			self.scavState = "walk" -- 4701
		end -- 4701
		return -- 4703
	end -- 4703
	if self.scavState == "walk" then -- 4705
		local d = self.scavTargetX - self.scavX -- 4706
		if math.abs(d) < 4 then -- 4707
			self.scavState = "stall" -- 4708
			self.scavT = s.stallTicks + self.scavStallBonus -- 4709
			self.scavStallBonus = 0 -- 4710
			return -- 4711
		end -- 4711
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4713
		return -- 4714
	end -- 4714
	if self.scavState == "stall" then -- 4716
		self.scavT = self.scavT - 1 -- 4717
		if self.scavT <= 0 then -- 4718
			self.scavState = "back" -- 4719
		end -- 4719
		return -- 4721
	end -- 4721
	if self.scavState == "back" then -- 4723
		local home = math.max( -- 4724
			s.x0, -- 4724
			math.min(s.x1, self.scavX) -- 4724
		) -- 4724
		if math.abs(home - self.scavX) < 2 then -- 4725
			self.scavState = "patrol" -- 4726
			return -- 4727
		end -- 4727
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4729
		return -- 4730
	end -- 4730
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4732
	if self.scavX >= s.x1 then -- 4733
		self.scavX = s.x1 -- 4734
		self.scavDir = -1 -- 4735
	elseif self.scavX <= s.x0 then -- 4736
		self.scavX = s.x0 -- 4737
		self.scavDir = 1 -- 4738
	end -- 4738
end -- 4693
function Play.prototype.stepCart(self, dt, input) -- 4746
	local p = self.player -- 4747
	local c = self.room.cart -- 4748
	if self.gripping then -- 4750
		if not input.interact.held then -- 4751
			self.gripping = false -- 4752
			self:flashSet("松开车把", 0.4) -- 4753
			return -- 4754
		end -- 4754
	else -- 4754
		if not input.interact.pressed then -- 4757
			return -- 4758
		end -- 4758
		if not self:cartHandleInReach(p) then -- 4760
			return -- 4761
		end -- 4761
		local track = c.depth or 0 -- 4763
		if self:limitDepth(p, track) ~= track then -- 4764
			return -- 4765
		end -- 4765
		p.depth = track -- 4767
		p.depthSpeed = 0 -- 4768
		self.gripping = true -- 4769
		self:flashSet("握住车把", 0.4) -- 4770
		return -- 4771
	end -- 4771
	if self.cartDocked then -- 4774
		return -- 4775
	end -- 4775
	local dir = input.moveX -- 4777
	if dir == 0 then -- 4778
		return -- 4779
	end -- 4779
	local lo = math.min(c.startX, c.endX) -- 4781
	local hi = math.max(c.startX, c.endX) -- 4782
	local next = self.cartAxle + dir * CART_SPEED * dt -- 4783
	if next < lo then -- 4784
		next = lo -- 4785
	end -- 4785
	if next > hi then -- 4787
		next = hi -- 4788
	end -- 4788
	local delta = next - self.cartAxle -- 4790
	if delta == 0 then -- 4791
		return -- 4792
	end -- 4792
	self.cartAxle = next -- 4794
	p.x = p.x + delta -- 4795
	p.facing = dir > 0 and 1 or -1 -- 4796
	self:slideX(p, 0) -- 4797
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 4798
		self.gripping = false -- 4799
		self:flashSet("跟不上了，脱手", 0.6) -- 4800
		return -- 4801
	end -- 4801
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 4803
		self.cartDocked = true -- 4804
		self.gripping = false -- 4805
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 4806
		self:flashSet("车轮落窝", 1.2) -- 4807
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 4808
		self:flashSet("车轮回到起点", 0.5) -- 4809
	end -- 4809
end -- 4746
function Play.prototype.requestRoom(self, key, reason) -- 4817
	if self.wantRoom ~= "" then -- 4820
		return -- 4821
	end -- 4821
	self.wantRoom = key -- 4823
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 4824
end -- 4817
function Play.prototype.checkCarryGate(self) -- 4831
	if self.room.key == "checkpoint" then -- 4832
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 4833
			self.carryCartAxle = self.cartAxle -- 4834
			self.carryCartDocked = self.cartDocked -- 4835
			self:requestRoom("gate", "检查站出口") -- 4836
			self:flashSet("出检查站 · 城门", 1.2) -- 4837
		end -- 4837
		return -- 4839
	end -- 4839
	if self.room.key == "outside" then -- 4841
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 4844
			self.carryCartAxle = self.cartAxle -- 4845
			self.carryCartDocked = self.cartDocked -- 4846
			self:requestRoom("village", "墙根走完") -- 4847
			self:flashSet("墙根走完 · 进村口", 1.2) -- 4848
		end -- 4848
	end -- 4848
end -- 4831
function Play.prototype.aimAt(self, wx, wy) -- 4855
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 4856
	self.aimX = s.x -- 4857
	self.aimY = s.y -- 4858
end -- 4855
function Play.prototype.shoot(self, a) -- 4861
	if self.isCampaign and self.reloadT > 0 then -- 4862
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 4863
		return -- 4864
	end -- 4864
	local ox = a.x + a.facing * 8 -- 4866
	local muzzleY = a.y + a.h * 0.72 -- 4867
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 4868
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4870
	local dx = aim.x - ox -- 4873
	local dy = aim.y - oy -- 4874
	local len = math.sqrt(dx * dx + dy * dy) -- 4875
	if len < 0.001 then -- 4876
		dx = a.facing -- 4877
		dy = 0 -- 4878
	else -- 4878
		dx = dx / len -- 4880
		dy = dy / len -- 4881
	end -- 4881
	if dx ~= 0 then -- 4883
		a.facing = dx > 0 and 1 or -1 -- 4884
	end -- 4884
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 4887
	local hitEnemy = self:raycastEnemies(ray) -- 4888
	local tEnemy = hitEnemy.t -- 4889
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 4890
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 4891
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 4892
	local tWall = solid.t -- 4893
	local rawEffect = self:consumeReloadEffect() -- 4895
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 4896
	local reloadEffect = rawEffect -- 4897
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 4899
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 4900
	self.trace = { -- 4902
		x0 = ox, -- 4902
		y0 = oy, -- 4902
		x1 = ox + dx * t, -- 4902
		y1 = oy + dy * t, -- 4902
		hit = hit -- 4902
	} -- 4902
	self.traceT = 0.12 -- 4903
	self:applyFireDanger(ox) -- 4904
	local killed = false -- 4905
	if hit then -- 4906
		local i = hitEnemy.index -- 4907
		local e = self.enemies[i + 1] -- 4908
		local impactY = oy + dy * tEnemy -- 4909
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 4910
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 4911
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 4912
			e.shieldHp = (e.shieldHp or 0) - 1 -- 4913
			e.hitT = 0.3 -- 4914
			self:flashSet( -- 4915
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 4915
				0.8 -- 4915
			) -- 4915
			self:emit("shotResolved", { -- 4916
				hit = true, -- 4917
				enemyIndex = i, -- 4917
				enemyX = e.x, -- 4917
				aimX = aim.x, -- 4917
				aimY = aim.y, -- 4917
				impactX = ox + dx * t, -- 4918
				impactY = oy + dy * t, -- 4918
				shield = true -- 4918
			}) -- 4918
			self:beginReload() -- 4920
			return -- 4921
		end -- 4921
		e.alive = false -- 4923
		e.hitT = 0.4 -- 4924
		killed = true -- 4925
		self:flashSet("命中", 0.6) -- 4926
		self:dropFor(e) -- 4927
		if reloadEffect == "light" and weaponFx == "light" then -- 4928
			self:blindNearby(e, 160, i) -- 4929
		end -- 4929
		if reloadEffect == "push" then -- 4931
			e.x = e.x + a.facing * 46 -- 4932
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4933
		elseif reloadEffect == "echo" then -- 4934
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 4935
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 4936
		elseif reloadEffect == "light" then -- 4937
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 4938
		end -- 4938
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 4940
		self:damageProp(solid.box, 1) -- 4941
	else -- 4941
		self:flashSet("打空", 0.35) -- 4943
	end -- 4943
	if self.isCampaign then -- 4945
		self:beginReload() -- 4946
	end -- 4946
	self:emit("shotResolved", { -- 4948
		hit = hit, -- 4949
		enemyIndex = hit and hitEnemy.index or -1, -- 4950
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 4951
		aimX = aim.x, -- 4952
		aimY = aim.y, -- 4953
		impactX = ox + dx * t, -- 4954
		impactY = oy + dy * t -- 4955
	}) -- 4955
end -- 4861
function Play.prototype.applyFireDanger(self, shotX) -- 4960
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 4961
		return -- 4962
	end -- 4962
	local dangerX = shotX -- 4964
	local best = -1 -- 4965
	local bestD = 1000000000 -- 4966
	local i = 0 -- 4967
	do -- 4967
		i = 0 -- 4968
		while i < #self.enemies do -- 4968
			do -- 4968
				local e = self.enemies[i + 1] -- 4969
				if not e.alive then -- 4970
					goto __continue830 -- 4971
				end -- 4971
				local d = math.abs(e.x - self.partner.x) -- 4973
				if d < bestD then -- 4974
					bestD = d -- 4975
					best = i -- 4976
				end -- 4976
			end -- 4976
			::__continue830:: -- 4976
			i = i + 1 -- 4968
		end -- 4968
	end -- 4968
	if best >= 0 then -- 4979
		dangerX = self.enemies[best + 1].x -- 4980
	end -- 4980
	local exposed = self:childExposed(dangerX) -- 4982
	local before = self.escort.fear -- 4983
	local dangerId = self.nextDangerId -- 4984
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 4985
	self.nextDangerId = self.nextDangerId + 1 -- 4986
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 4987
	if after > before then -- 4988
		self:flashSet( -- 4989
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 4989
			1 -- 4989
		) -- 4989
	elseif not exposed then -- 4990
		self:flashSet("枪声没够到她", 0.5) -- 4991
	end -- 4991
end -- 4960
function Play.prototype.childExposed(self, dangerX) -- 4996
	local c = self.partner -- 4997
	if not c.alive then -- 4998
		return false -- 4999
	end -- 4999
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 5001
		self.boxes, -- 5002
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 5002
	) then -- 5002
		return false -- 5003
	end -- 5003
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 5005
		return false -- 5006
	end -- 5006
	local toDanger = dangerX - c.x -- 5008
	local toPlayer = self.player.x - c.x -- 5009
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 5010
		return false -- 5012
	end -- 5012
	return true -- 5014
end -- 4996
function Play.prototype.raycastEnemies(self, ray) -- 5018
	local best = -1 -- 5019
	local bestI = -1 -- 5020
	do -- 5020
		local i = 0 -- 5021
		while i < #self.enemies do -- 5021
			do -- 5021
				local e = self.enemies[i + 1] -- 5022
				if not e.alive then -- 5023
					goto __continue844 -- 5024
				end -- 5024
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 5026
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 5027
				if t >= 0 and (best < 0 or t < best) then -- 5028
					best = t -- 5029
					bestI = i -- 5030
				end -- 5030
			end -- 5030
			::__continue844:: -- 5030
			i = i + 1 -- 5021
		end -- 5021
	end -- 5021
	return {t = best, index = bestI} -- 5033
end -- 5018
function Play.prototype.raycastWorld(self, ray) -- 5036
	return self:raycastSolid(ray).t -- 5037
end -- 5036
function Play.prototype.raycastSolid(self, ray) -- 5041
	local best = -1 -- 5042
	local bestBox = nil -- 5043
	for ____, box in ipairs(self.boxes) do -- 5044
		do -- 5044
			if box.broken == true or box.hidden == true then -- 5045
				goto __continue849 -- 5046
			end -- 5046
			local t = hitBox(ray, box) -- 5051
			if t > 2 and (best < 0 or t < best) then -- 5053
				best = t -- 5054
				bestBox = box -- 5055
			end -- 5055
		end -- 5055
		::__continue849:: -- 5055
	end -- 5055
	if ray.dy < 0 then -- 5058
		local t = -ray.y / ray.dy -- 5059
		if t >= 0 and (best < 0 or t < best) then -- 5060
			best = t -- 5061
			bestBox = nil -- 5062
		end -- 5062
	end -- 5062
	return {t = best, box = bestBox} -- 5065
end -- 5041
function Play.prototype.dropFor(self, e) -- 5069
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 5070
		return -- 5071
	end -- 5071
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 5073
		return -- 5074
	end -- 5074
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 5076
	local ____self_pickups_54 = self.pickups -- 5077
	____self_pickups_54[#____self_pickups_54 + 1] = { -- 5077
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 5078
		kind = e.drop, -- 5078
		x = e.x, -- 5078
		y = e.y, -- 5078
		depth = e.depth, -- 5079
		label = label .. " ×1" -- 5079
	} -- 5079
	self:log("掉落 " .. label) -- 5081
end -- 5069
function Play.prototype.damageProp(self, b, amount) -- 5085
	if b.breakable == nil or b.broken == true then -- 5086
		return -- 5087
	end -- 5087
	local ____b_breakable_55, ____hp_56 = b.breakable, "hp" -- 5089
	____b_breakable_55[____hp_56] = ____b_breakable_55[____hp_56] - amount -- 5089
	if b.breakable.hp > 0 then -- 5090
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 5091
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 5092
		return -- 5093
	end -- 5093
	b.broken = true -- 5095
	for ____, other in ipairs(self.boxes) do -- 5096
		if other.id ~= nil and other.id == b.id then -- 5097
			other.broken = true -- 5098
		end -- 5098
	end -- 5098
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 5101
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 5102
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 5103
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 5104
end -- 5085
function Play.prototype.slideDepth(self, a, distance) -- 5108
	a.depth = self:limitDepth(a, a.depth + distance) -- 5109
end -- 5108
function Play.prototype.limitDepth(self, a, target) -- 5112
	local road = self.room.depth -- 5113
	if road == nil or target == a.depth then -- 5114
		return a.depth -- 5115
	end -- 5115
	local next = math.max( -- 5117
		road.min, -- 5117
		math.min(road.max, target) -- 5117
	) -- 5117
	local half = a.w / 2 -- 5118
	for ____, b in ipairs(self.boxes) do -- 5119
		do -- 5119
			local footprint = b.depth -- 5120
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5121
				goto __continue867 -- 5125
			end -- 5125
			local front = footprint.min - ACTOR_DEPTH_HALF -- 5127
			local back = footprint.max + ACTOR_DEPTH_HALF -- 5128
			if a.depth <= front and next > front then -- 5129
				next = front -- 5130
			elseif a.depth >= back and next < back then -- 5131
				next = back -- 5132
			end -- 5132
		end -- 5132
		::__continue867:: -- 5132
	end -- 5132
	return next -- 5135
end -- 5112
function Play.prototype.slideX(self, a, dx) -- 5139
	local nx = a.x + dx -- 5140
	local half = a.w / 2 -- 5141
	local room = self.room -- 5142
	nx = math.max( -- 5143
		room.minX + half, -- 5143
		math.min(room.maxX - half, nx) -- 5143
	) -- 5143
	local i = 0 -- 5144
	do -- 5144
		i = 0 -- 5145
		while i < #self.boxes do -- 5145
			do -- 5145
				local b = self.boxes[i + 1] -- 5146
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5147
					goto __continue874 -- 5148
				end -- 5148
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5150
					goto __continue874 -- 5151
				end -- 5151
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5153
					goto __continue874 -- 5154
				end -- 5154
				if nx + half > b.x0 and nx - half < b.x1 then -- 5156
					if a.x <= b.x0 then -- 5157
						nx = b.x0 - half -- 5158
					elseif a.x >= b.x1 then -- 5159
						nx = b.x1 + half -- 5160
					else -- 5160
						nx = a.x -- 5162
					end -- 5162
				end -- 5162
			end -- 5162
			::__continue874:: -- 5162
			i = i + 1 -- 5145
		end -- 5145
	end -- 5145
	if self.room.key == "outside" and not self.cartDocked and a.y < CART_CLEAR - 0.001 then -- 5168
		local bx0 = math.max(room.arch.x0, self.cartAxle - CART_HALF) -- 5169
		local bx1 = math.min(room.arch.x1, self.cartAxle + CART_HALF) -- 5170
		if bx1 > bx0 and nx + half > bx0 and nx - half < bx1 then -- 5171
			if a.x <= bx0 then -- 5172
				nx = bx0 - half -- 5173
			elseif a.x >= bx1 then -- 5174
				nx = bx1 + half -- 5175
			else -- 5175
				nx = a.x -- 5177
			end -- 5177
		end -- 5177
	end -- 5177
	local arch = room.arch -- 5185
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 5186
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 5187
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 5188
			if a.x <= arch.x0 then -- 5189
				nx = arch.x0 - half -- 5190
			elseif a.x >= arch.x1 then -- 5191
				nx = arch.x1 + half -- 5192
			end -- 5192
		end -- 5192
	end -- 5192
	a.x = nx -- 5196
end -- 5139
function Play.prototype.fallY(self, a, dt) -- 5200
	a.vy = a.vy - ____exports.GRAVITY * dt -- 5201
	if a.vy < -900 then -- 5202
		a.vy = -900 -- 5203
	end -- 5203
	local ny = a.y + a.vy * dt -- 5205
	local half = a.w / 2 -- 5206
	if a.vy <= 0 then -- 5207
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 5209
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 5210
		if ny <= ground then -- 5211
			ny = ground -- 5212
			a.vy = 0 -- 5213
			a.onGround = true -- 5214
		else -- 5214
			a.onGround = false -- 5216
		end -- 5216
	else -- 5216
		a.onGround = false -- 5219
		local i = 0 -- 5220
		do -- 5220
			i = 0 -- 5221
			while i < #self.boxes do -- 5221
				do -- 5221
					local b = self.boxes[i + 1] -- 5222
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5223
						goto __continue898 -- 5224
					end -- 5224
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5226
						goto __continue898 -- 5227
					end -- 5227
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 5229
						goto __continue898 -- 5230
					end -- 5230
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 5232
						ny = b.y0 - a.h -- 5233
						a.vy = 0 -- 5234
					end -- 5234
				end -- 5234
				::__continue898:: -- 5234
				i = i + 1 -- 5221
			end -- 5221
		end -- 5221
	end -- 5221
	a.y = ny -- 5238
end -- 5200
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 5242
	if depth == nil then -- 5242
		depth = 0 -- 5242
	end -- 5242
	local g = -9999 -- 5243
	local i = 0 -- 5244
	do -- 5244
		i = 0 -- 5245
		while i < #self.floors do -- 5245
			local f = self.floors[i + 1] -- 5246
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 5247
				g = f.y1 -- 5248
			end -- 5248
			i = i + 1 -- 5245
		end -- 5245
	end -- 5245
	do -- 5245
		i = 0 -- 5251
		while i < #self.boxes do -- 5251
			do -- 5251
				local b = self.boxes[i + 1] -- 5252
				if b.broken == true or b.hidden == true or b.soft == true then -- 5253
					goto __continue908 -- 5254
				end -- 5254
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 5256
					g = b.y1 -- 5258
				end -- 5258
			end -- 5258
			::__continue908:: -- 5258
			i = i + 1 -- 5251
		end -- 5251
	end -- 5251
	return g -- 5261
end -- 5242
function Play.prototype.updateCamera(self, dt) -- 5264
	local p = self.player -- 5265
	local tx = p.x + p.facing * 30 -- 5266
	local ty = p.y + CAM_LOOK_UP -- 5267
	local k = math.min(1, CAM_FOLLOW * dt) -- 5268
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 5269
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 5270
end -- 5264
function Play.prototype.clampCamera(self, w, h) -- 5274
	local room = self.room -- 5275
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 5276
	local spanX = room.maxX - room.minX -- 5277
	if spanX <= halfW * 2 then -- 5278
		self.cam.x = (room.minX + room.maxX) / 2 -- 5279
	else -- 5279
		self.cam.x = math.max( -- 5281
			room.minX + halfW, -- 5281
			math.min(room.maxX - halfW, self.cam.x) -- 5281
		) -- 5281
	end -- 5281
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 5284
	local spanY = room.height -- 5285
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 5286
	if spanY <= halfH * 2 then -- 5287
		self.cam.y = camY -- 5288
	else -- 5288
		self.cam.y = math.max( -- 5290
			camY, -- 5290
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 5290
		) -- 5290
	end -- 5290
end -- 5274
function Play.prototype.flashSet(self, text, t) -- 5294
	self.flash = text -- 5295
	self.flashT = t -- 5296
end -- 5294
function Play.prototype.statusText(self) -- 5300
	local p = self.player -- 5301
	local parts = {} -- 5302
	local who = self.childMode and "小满" or "周戍" -- 5303
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 5304
	if self.room.key == "prologue" then -- 5306
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5307
		if self.phase == "prologue-wake" then -- 5308
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 5309
		elseif self.phase == "prologue-shadow" then -- 5310
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 5311
		elseif self.phase == "prologue-escape" then -- 5312
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 5313
		elseif self.phase == "prologue-hide" then -- 5314
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 5315
		elseif self.phase == "prologue-wait" then -- 5316
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 5317
		elseif self.phase == "prologue-give" then -- 5318
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 5319
		else -- 5319
			parts[#parts + 1] = "跟随" -- 5321
		end -- 5321
		if self.paused then -- 5323
			parts[#parts + 1] = "已暂停" -- 5324
		end -- 5324
		return table.concat(parts, " · ") -- 5326
	end -- 5326
	if self.room.key == "street" then -- 5328
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5329
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5330
		if self.paused then -- 5331
			parts[#parts + 1] = "已暂停" -- 5332
		end -- 5332
		return table.concat(parts, " · ") -- 5334
	end -- 5334
	if self.room.key == "gate" then -- 5336
		local ____temp_57 -- 5337
		if self.room.story == nil then -- 5337
			____temp_57 = nil -- 5337
		else -- 5337
			____temp_57 = self.room.story.gate -- 5337
		end -- 5337
		local g = ____temp_57 -- 5337
		if g ~= nil then -- 5338
			parts[#parts + 1] = self:gateLabel() -- 5339
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 5340
				0, -- 5341
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 5341
			))) .. " 秒" -- 5341
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5342
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5343
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 5344
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 5345
			if self.gateFailCount > 0 then -- 5346
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 5347
			end -- 5347
			if self.flash ~= "" then -- 5349
				parts[#parts + 1] = self.flash -- 5350
			end -- 5350
		end -- 5350
		if self.paused then -- 5353
			parts[#parts + 1] = "已暂停" -- 5354
		end -- 5354
		return table.concat(parts, " · ") -- 5356
	end -- 5356
	if self.room.key == "forest" then -- 5358
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5359
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5360
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5361
		if self.caughtT > 0 then -- 5362
			parts[#parts + 1] = "复位中" -- 5363
		end -- 5363
		if self.paused then -- 5365
			parts[#parts + 1] = "已暂停" -- 5366
		end -- 5366
		return table.concat(parts, " · ") -- 5368
	end -- 5368
	if self.room.key == "tower" then -- 5370
		if self.phase == "tower-wait" then -- 5371
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5372
		elseif self.phase == "tower-knock" then -- 5373
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5374
		elseif self.phase == "tower-enter" then -- 5375
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5376
		elseif self.phase == "tower-desk" then -- 5377
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5378
		elseif self.phase == "tower-given" then -- 5379
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5380
		else -- 5380
			parts[#parts + 1] = "片尾" -- 5382
		end -- 5382
		if self.paused then -- 5384
			parts[#parts + 1] = "已暂停" -- 5385
		end -- 5385
		return table.concat(parts, " · ") -- 5387
	end -- 5387
	if self.room.key == "village" then -- 5389
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5390
		if self.hasBottle then -- 5391
			parts[#parts + 1] = "有瓶" -- 5392
		elseif self.bottleFly ~= nil then -- 5393
			parts[#parts + 1] = "瓶在飞" -- 5394
		else -- 5394
			parts[#parts + 1] = "空手" -- 5396
		end -- 5396
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5398
		if self.scavChase then -- 5399
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5400
		end -- 5400
		if self.passed then -- 5402
			parts[#parts + 1] = "已过通行线" -- 5403
		end -- 5403
		if self.paused then -- 5405
			parts[#parts + 1] = "已暂停" -- 5406
		end -- 5406
		return table.concat(parts, " · ") -- 5408
	end -- 5408
	local isChild = self.childMode -- 5411
	if isChild then -- 5412
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5413
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5414
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5415
	else -- 5415
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5417
		if p.rollT > 0 then -- 5418
			parts[#parts + 1] = "翻滚中" -- 5419
		end -- 5419
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5421
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5422
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5423
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5424
	end -- 5424
	if self.checkpoint >= 0 then -- 5426
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5427
	end -- 5427
	if self.paused then -- 5429
		parts[#parts + 1] = "已暂停" -- 5430
	end -- 5430
	return table.concat(parts, " · ") -- 5432
end -- 5300
function Play.prototype.aliveEnemies(self) -- 5436
	local n = 0 -- 5437
	local i = 0 -- 5438
	do -- 5438
		i = 0 -- 5439
		while i < #self.enemies do -- 5439
			if self.enemies[i + 1].alive then -- 5440
				n = n + 1 -- 5441
			end -- 5441
			i = i + 1 -- 5439
		end -- 5439
	end -- 5439
	return n -- 5444
end -- 5436
function Play.prototype.threatened(self) -- 5449
	do -- 5449
		local i = 0 -- 5450
		while i < #self.enemies do -- 5450
			local e = self.enemies[i + 1] -- 5451
			if e.alive and e.warnT > 0 then -- 5452
				return true -- 5453
			end -- 5453
			i = i + 1 -- 5450
		end -- 5450
	end -- 5450
	return false -- 5456
end -- 5449
function Play.prototype.gateSecondsLeft(self) -- 5459
	local ____temp_58 -- 5460
	if self.room.story == nil then -- 5460
		____temp_58 = nil -- 5460
	else -- 5460
		____temp_58 = self.room.story.gate -- 5460
	end -- 5460
	local g = ____temp_58 -- 5460
	if g == nil then -- 5461
		return 0 -- 5462
	end -- 5462
	return math.max( -- 5464
		0, -- 5464
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5464
	) -- 5464
end -- 5459
function Play.prototype.gateLabel(self) -- 5467
	if self.phase == "gate-idle" then -- 5468
		return "待就位" -- 5469
	end -- 5469
	if self.phase == "gate-hold" then -- 5471
		return "守点中" -- 5472
	end -- 5472
	if self.phase == "gate-send" then -- 5474
		return "送别" -- 5475
	end -- 5475
	if self.phase == "gate-count" then -- 5477
		return "数数 " .. tostring(self.countTick) -- 5478
	end -- 5478
	return "她走" -- 5480
end -- 5467
function Play.prototype.dogLabel(self) -- 5484
	if self.dogState == "ear" then -- 5485
		return "转耳" -- 5486
	end -- 5486
	if self.dogState == "chase" then -- 5488
		return "追" -- 5489
	end -- 5489
	if self.dogState == "sniff" then -- 5491
		return "停" -- 5492
	end -- 5492
	if self.dogState == "back" then -- 5494
		return "回线" -- 5495
	end -- 5495
	return "巡逻" -- 5497
end -- 5484
function Play.prototype.doorXOf(self) -- 5500
	local ____temp_59 -- 5501
	if self.room.story == nil then -- 5501
		____temp_59 = nil -- 5501
	else -- 5501
		____temp_59 = self.room.story.tower -- 5501
	end -- 5501
	local t = ____temp_59 -- 5501
	return t == nil and 0 or t.doorX -- 5502
end -- 5500
function Play.prototype.scavLabel(self) -- 5506
	if self.scavState == "chase" then -- 5507
		return "追" -- 5508
	end -- 5508
	if self.scavState == "turn" then -- 5510
		return "转头" -- 5511
	end -- 5511
	if self.scavState == "walk" then -- 5513
		return "赶来" -- 5514
	end -- 5514
	if self.scavState == "stall" then -- 5516
		return "停住" -- 5517
	end -- 5517
	if self.scavState == "back" then -- 5519
		return "回位" -- 5520
	end -- 5520
	return "巡逻" -- 5522
end -- 5506
function Play.prototype.hintText(self) -- 5526
	if self.paused then -- 5527
		return "Esc 继续 · R 重置" -- 5528
	end -- 5528
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5532
		if self:threatened() then -- 5533
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5534
		end -- 5534
		if self.coverHug then -- 5536
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5537
		end -- 5537
		if self.coverNear then -- 5539
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5540
		end -- 5540
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5542
	end -- 5542
	if self.flash ~= "" then -- 5544
		return self.flash -- 5545
	end -- 5545
	if self.room.key == "prologue" then -- 5547
		if self.phase == "prologue-wake" then -- 5548
			return "父亲在门外唤 · 小满睁眼" -- 5549
		end -- 5549
		if self.phase == "prologue-shadow" then -- 5551
			return "墙上两道人影 · 碗滚到脚边" -- 5552
		end -- 5552
		if self.phase == "prologue-escape" then -- 5554
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5555
		end -- 5555
		if self.phase == "prologue-hide" then -- 5557
			return "柜门合上 · 屏住呼吸" -- 5558
		end -- 5558
		if self.phase == "prologue-wait" then -- 5560
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5561
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5562
		end -- 5562
		if self.phase == "prologue-give" then -- 5564
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 5565
		end -- 5565
		return "她跟着你了 · 两人一起走到门口 680" -- 5567
	end -- 5567
	if self.room.key == "street" then -- 5569
		if self:aliveEnemies() > 0 then -- 5570
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5571
		end -- 5571
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5573
	end -- 5573
	if self.room.key == "gate" then -- 5575
		local ____temp_60 -- 5576
		if self.room.story == nil then -- 5576
			____temp_60 = nil -- 5576
		else -- 5576
			____temp_60 = self.room.story.gate -- 5576
		end -- 5576
		local g = ____temp_60 -- 5576
		if g ~= nil then -- 5577
			if self.phase == "gate-idle" then -- 5578
				if self.gateNeedConfirm then -- 5579
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5580
				end -- 5580
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5582
			end -- 5582
			if self.phase == "gate-hold" then -- 5584
				if self.coveredFlash > 0 then -- 5585
					return "掩体挡下了这一枪 · 别露头" -- 5586
				end -- 5586
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5588
			end -- 5588
			if self.phase == "gate-send" then -- 5590
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5591
			end -- 5591
			if self.phase == "gate-count" then -- 5593
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5594
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5595
				end -- 5595
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5597
			end -- 5597
			return "她自己走 · 跟着出城门 1120" -- 5599
		end -- 5599
	end -- 5599
	if self.room.key == "forest" then -- 5602
		if self.dogState == "chase" then -- 5603
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5604
		end -- 5604
		if self.dogState == "ear" then -- 5606
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5607
		end -- 5607
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5609
	end -- 5609
	if self.room.key == "tower" then -- 5611
		if self.phase == "tower-wait" then -- 5612
			return "走到门前 445 点一次 E 敲两下" -- 5613
		end -- 5613
		if self.phase == "tower-knock" then -- 5615
			return "敲两下 · 等门开" -- 5616
		end -- 5616
		if self.phase == "tower-given" then -- 5618
			return "递交针套和纸条 · 看登记簿最后一行" -- 5619
		end -- 5619
		return "片尾 · 点 E 再玩一次，回到序章" -- 5621
	end -- 5621
	if self.room.key == "village" then -- 5623
		if self.bottleFly ~= nil then -- 5624
			return "等瓶子落地 · 触地才发声" -- 5625
		end -- 5625
		if self.hasBottle then -- 5627
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5628
		end -- 5628
		if self.passed then -- 5630
			return "已过第一院 · R 重置可再来一遍" -- 5631
		end -- 5631
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5633
	end -- 5633
	if self.room.key == "outside" then -- 5635
		if self.focusCart then -- 5636
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5637
		end -- 5637
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5639
	end -- 5639
	if self.escort.state == "frozen" then -- 5641
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5642
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5643
		end -- 5643
		return "小满吓住了 · 走过去，靠近再点 E" -- 5645
	end -- 5645
	if self.escort.state == "calming" then -- 5647
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5648
	end -- 5648
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5650
end -- 5526
function Play.prototype.draw(self, draw, w, h) -- 5655
	self.viewW = w -- 5656
	self.viewH = h -- 5657
	self.view = ____exports.computeViewport(w, h) -- 5658
	self:clampCamera(w, h) -- 5659
	draw:clear() -- 5660
	draw:drawRect( -- 5662
		Rect(0, 0, w, h), -- 5662
		BG_VOID -- 5662
	) -- 5662
	local box = self:canvasRect(w, h) -- 5663
	draw:drawRect(box, BG_FAR) -- 5664
	draw:drawRect( -- 5665
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 5665
		BG_MID -- 5665
	) -- 5665
	self:drawFloors(draw, w, h) -- 5667
	self:drawSolids(draw, w, h) -- 5668
	self:drawZones(draw, w, h) -- 5669
	self:drawArch(draw, w, h) -- 5670
	self:drawCart(draw, w, h) -- 5671
	self:drawCampaignProps(draw, w, h) -- 5672
	self:drawActors(draw, w, h) -- 5673
	self:drawTrace(draw, w, h) -- 5674
	self:drawAim(draw, w, h) -- 5675
end -- 5655
function Play.prototype.canvasRect(self, w, h) -- 5679
	local v = self.view -- 5680
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 5681
end -- 5679
function Play.prototype.px(self, n) -- 5685
	return n * self.view.zoom -- 5686
end -- 5685
function Play.prototype.sx(self, wx, w) -- 5690
	local v = self.view -- 5691
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 5692
	return v.ox + lx * v.zoom -- 5693
end -- 5690
function Play.prototype.sy(self, wy, h) -- 5697
	local v = self.view -- 5698
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 5699
	return v.oy + ly * v.zoom -- 5700
end -- 5697
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 5703
	local px0 = self:sx(x0, w) -- 5704
	local px1 = self:sx(x1, w) -- 5705
	local py0 = self:sy(y0, h) -- 5706
	local py1 = self:sy(y1, h) -- 5707
	if px1 <= px0 or py1 <= py0 then -- 5708
		return -- 5709
	end -- 5709
	draw:drawRect( -- 5711
		Rect(px0, py0, px1 - px0, py1 - py0), -- 5711
		color -- 5711
	) -- 5711
end -- 5703
function Play.prototype.drawFloors(self, draw, w, h) -- 5714
	local i = 0 -- 5715
	do -- 5715
		i = 0 -- 5716
		while i < #self.room.floors do -- 5716
			local f = self.room.floors[i + 1] -- 5717
			local ____temp_61 -- 5718
			if f.y == 0 then -- 5718
				____temp_61 = self.room.depth -- 5718
			else -- 5718
				____temp_61 = nil -- 5718
			end -- 5718
			local road = ____temp_61 -- 5718
			local y = self:sy(f.y + (road and road.min or 0), h) -- 5719
			local x0 = self:sx(f.x0, w) -- 5720
			local x1 = self:sx(f.x1, w) -- 5721
			local deck = self:px(5) -- 5722
			if road ~= nil then -- 5723
				local back = self:sy(f.y + road.max, h) -- 5724
				draw:drawRect( -- 5725
					Rect(x0, y, x1 - x0, back - y), -- 5725
					FLOOR_DECK, -- 5725
					self:px(1), -- 5725
					SOLID_EDGE -- 5725
				) -- 5725
			end -- 5725
			draw:drawRect( -- 5727
				Rect(x0, y - deck, x1 - x0, deck), -- 5727
				FLOOR_DECK -- 5727
			) -- 5727
			draw:drawSegment( -- 5728
				Vec2(x0, y), -- 5728
				Vec2(x1, y), -- 5728
				self:px(1), -- 5728
				GROUND -- 5728
			) -- 5728
			i = i + 1 -- 5716
		end -- 5716
	end -- 5716
end -- 5714
function Play.prototype.drawSolids(self, draw, w, h) -- 5732
	local i = 0 -- 5733
	do -- 5733
		i = 0 -- 5734
		while i < #self.boxes do -- 5734
			do -- 5734
				local b = self.boxes[i + 1] -- 5735
				if b.id == "braced_shield" or b.hidden == true then -- 5736
					goto __continue1039 -- 5737
				end -- 5737
				if b.broken == true then -- 5739
					if b.breakable ~= nil then -- 5741
						local gy = self:sy(b.y0, h) -- 5742
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 5743
						local k = 0 -- 5744
						do -- 5744
							k = 0 -- 5745
							while k < 3 do -- 5745
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 5746
								draw:drawSegment( -- 5747
									Vec2( -- 5747
										gx - self:px(4), -- 5747
										gy + self:px(k % 2) -- 5747
									), -- 5747
									Vec2( -- 5747
										gx + self:px(5), -- 5747
										gy + self:px(k % 2) -- 5747
									), -- 5747
									self:px(1), -- 5747
									rgb -- 5747
								) -- 5747
								k = k + 1 -- 5745
							end -- 5745
						end -- 5745
					end -- 5745
					goto __continue1039 -- 5750
				end -- 5750
				local ____opt_64 = b.depth -- 5752
				local front = ____opt_64 and ____opt_64.min or 0 -- 5752
				local ____opt_66 = b.depth -- 5753
				local back = ____opt_66 and ____opt_66.max or 0 -- 5753
				local fill = SOLID_FILL -- 5754
				local line = SOLID_EDGE -- 5755
				if b.soft == true then -- 5756
					fill = SOFT -- 5757
					line = SOFT_LINE -- 5758
				elseif b.breakable ~= nil then -- 5759
					line = DANGER_LINE -- 5760
					fill = Color(0.3, 0.24, 0.16, 1) -- 5761
				elseif b.interact ~= nil then -- 5762
					line = PASS_LINE -- 5763
				end -- 5763
				self:drawBox( -- 5765
					draw, -- 5765
					w, -- 5765
					h, -- 5765
					b.x0, -- 5765
					b.x1, -- 5765
					b.y0 + front, -- 5765
					b.y1 + back, -- 5765
					fill -- 5765
				) -- 5765
				draw:drawSegment( -- 5766
					Vec2( -- 5766
						self:sx(b.x0, w), -- 5766
						self:sy(b.y1 + front, h) -- 5766
					), -- 5766
					Vec2( -- 5767
						self:sx(b.x1, w), -- 5767
						self:sy(b.y1 + front, h) -- 5767
					), -- 5767
					self:px(1), -- 5767
					line -- 5767
				) -- 5767
				if b.breakable ~= nil then -- 5769
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 5770
					local cyp = self:sy(b.y1 + front, h) -- 5771
					draw:drawSegment( -- 5772
						Vec2( -- 5772
							cxp - self:px(4), -- 5772
							cyp + self:px(1) -- 5772
						), -- 5772
						Vec2( -- 5772
							cxp + self:px(3), -- 5772
							cyp + self:px(5) -- 5772
						), -- 5772
						self:px(1), -- 5772
						line -- 5772
					) -- 5772
				end -- 5772
			end -- 5772
			::__continue1039:: -- 5772
			i = i + 1 -- 5734
		end -- 5734
	end -- 5734
end -- 5732
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 5778
	local i = 0 -- 5779
	do -- 5779
		i = 0 -- 5780
		while i < #self.pickups do -- 5780
			do -- 5780
				local pk = self.pickups[i + 1] -- 5781
				if self.run.taken[pk.id] == true then -- 5782
					goto __continue1051 -- 5783
				end -- 5783
				local gy = pk.y + (pk.depth or 0) -- 5785
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 5786
				draw:drawRect( -- 5787
					Rect( -- 5787
						self:sx(pk.x - 5, w), -- 5787
						self:sy(gy + 12 + bob, h), -- 5787
						self:px(10), -- 5787
						self:px(10) -- 5787
					), -- 5787
					Color(0.84, 0.7, 0.3, 1) -- 5788
				) -- 5788
				draw:drawSegment( -- 5789
					Vec2( -- 5789
						self:sx(pk.x - 5, w), -- 5789
						self:sy(gy + 12 + bob, h) -- 5789
					), -- 5789
					Vec2( -- 5790
						self:sx(pk.x + 5, w), -- 5790
						self:sy(gy + 12 + bob, h) -- 5790
					), -- 5790
					self:px(1), -- 5790
					Color(0.95, 0.86, 0.52, 1) -- 5790
				) -- 5790
			end -- 5790
			::__continue1051:: -- 5790
			i = i + 1 -- 5780
		end -- 5780
	end -- 5780
	if self.bracedShield ~= nil then -- 5792
		local sh = self.bracedShield -- 5793
		draw:drawRect( -- 5794
			Rect( -- 5794
				self:sx(sh.x - sh.w / 2, w), -- 5794
				self:sy(sh.y, h), -- 5794
				self:px(sh.w), -- 5794
				self:px(sh.h) -- 5794
			), -- 5794
			Color(0.42, 0.4, 0.34, 1) -- 5795
		) -- 5795
		draw:drawSegment( -- 5796
			Vec2( -- 5796
				self:sx(sh.x - sh.w / 2, w), -- 5796
				self:sy(sh.y + sh.h, h) -- 5796
			), -- 5796
			Vec2( -- 5797
				self:sx(sh.x + sh.w / 2, w), -- 5797
				self:sy(sh.y + sh.h, h) -- 5797
			), -- 5797
			self:px(1), -- 5797
			Color(0.74, 0.72, 0.62, 1) -- 5797
		) -- 5797
	end -- 5797
end -- 5778
function Play.prototype.drawZones(self, draw, w, h) -- 5801
	local i = 0 -- 5802
	do -- 5802
		i = 0 -- 5803
		while i < #self.room.zones do -- 5803
			local z = self.room.zones[i + 1] -- 5804
			local fill = DANGER -- 5805
			local line = DANGER_LINE -- 5806
			if z.tint == 2 then -- 5807
				fill = SOFT -- 5808
				line = SOFT_LINE -- 5809
			elseif z.tint == 3 then -- 5810
				fill = BRICK -- 5811
				line = BRICK_LINE -- 5812
			elseif z.tint == 4 then -- 5813
				fill = PASS -- 5814
				line = PASS_LINE -- 5815
			end -- 5815
			self:drawBox( -- 5817
				draw, -- 5817
				w, -- 5817
				h, -- 5817
				z.x0, -- 5817
				z.x1, -- 5817
				z.y, -- 5817
				z.y + z.h, -- 5817
				fill -- 5817
			) -- 5817
			draw:drawSegment( -- 5818
				Vec2( -- 5818
					self:sx(z.x0, w), -- 5818
					self:sy(z.y, h) -- 5818
				), -- 5818
				Vec2( -- 5818
					self:sx(z.x0, w), -- 5818
					self:sy(z.y + z.h, h) -- 5818
				), -- 5818
				self:px(1), -- 5818
				line -- 5818
			) -- 5818
			draw:drawSegment( -- 5819
				Vec2( -- 5819
					self:sx(z.x1, w), -- 5819
					self:sy(z.y, h) -- 5819
				), -- 5819
				Vec2( -- 5819
					self:sx(z.x1, w), -- 5819
					self:sy(z.y + z.h, h) -- 5819
				), -- 5819
				self:px(1), -- 5819
				line -- 5819
			) -- 5819
			i = i + 1 -- 5803
		end -- 5803
	end -- 5803
end -- 5801
function Play.prototype.drawArch(self, draw, w, h) -- 5823
	local a = self.room.arch -- 5824
	if a.h <= 0 then -- 5825
		return -- 5826
	end -- 5826
	self:drawBox( -- 5828
		draw, -- 5828
		w, -- 5828
		h, -- 5828
		a.x0, -- 5828
		a.x1, -- 5828
		a.y, -- 5828
		a.y + a.h, -- 5828
		HOLE_FILL -- 5828
	) -- 5828
	draw:drawSegment( -- 5829
		Vec2( -- 5829
			self:sx(a.x0, w), -- 5829
			self:sy(a.y + a.h, h) -- 5829
		), -- 5829
		Vec2( -- 5829
			self:sx(a.x1, w), -- 5829
			self:sy(a.y + a.h, h) -- 5829
		), -- 5829
		self:px(1), -- 5829
		SOLID_EDGE -- 5829
	) -- 5829
	draw:drawSegment( -- 5830
		Vec2( -- 5830
			self:sx(a.x0, w), -- 5830
			self:sy(a.y, h) -- 5830
		), -- 5830
		Vec2( -- 5830
			self:sx(a.x0, w), -- 5830
			self:sy(a.y + a.h, h) -- 5830
		), -- 5830
		self:px(1), -- 5830
		SOLID_EDGE -- 5830
	) -- 5830
	draw:drawSegment( -- 5831
		Vec2( -- 5831
			self:sx(a.x1, w), -- 5831
			self:sy(a.y, h) -- 5831
		), -- 5831
		Vec2( -- 5831
			self:sx(a.x1, w), -- 5831
			self:sy(a.y + a.h, h) -- 5831
		), -- 5831
		self:px(1), -- 5831
		SOLID_EDGE -- 5831
	) -- 5831
end -- 5823
function Play.prototype.drawCart(self, draw, w, h) -- 5834
	local c = self.room.cart -- 5835
	if c.bodyW <= 0 then -- 5836
		return -- 5837
	end -- 5837
	drawCartShape( -- 5839
		draw, -- 5839
		self, -- 5839
		w, -- 5839
		h, -- 5839
		c, -- 5839
		self.cartAxle -- 5839
	) -- 5839
	draw:drawRect( -- 5840
		Rect( -- 5840
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 5840
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 5840
			self:px(2), -- 5840
			self:px(40) -- 5840
		), -- 5840
		STAND -- 5840
	) -- 5840
end -- 5834
function Play.prototype.drawActors(self, draw, w, h) -- 5843
	local p = self.player -- 5844
	local isChild = self.childMode -- 5845
	local footY = p.y + p.depth -- 5846
	if p.covered then -- 5848
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 5849
		draw:drawSegment( -- 5850
			Vec2( -- 5850
				self:sx(edge, w), -- 5850
				self:sy(footY + 8, h) -- 5850
			), -- 5850
			Vec2( -- 5850
				self:sx(edge, w), -- 5850
				self:sy(footY + p.h * 0.62, h) -- 5850
			), -- 5850
			self:px(2), -- 5850
			STAND -- 5850
		) -- 5850
		draw:drawSegment( -- 5852
			Vec2( -- 5852
				self:sx(p.x - 8, w), -- 5852
				self:sy(footY + p.h + 3, h) -- 5852
			), -- 5852
			Vec2( -- 5852
				self:sx(p.x + 8, w), -- 5852
				self:sy(footY + p.h + 3, h) -- 5852
			), -- 5852
			self:px(2), -- 5852
			STAND -- 5852
		) -- 5852
	elseif self.coverNear and not isChild then -- 5853
		draw:drawRect( -- 5855
			Rect( -- 5855
				self:sx(p.x - 3, w), -- 5855
				self:sy(footY + 1, h), -- 5855
				self:px(3), -- 5855
				self:px(3) -- 5855
			), -- 5855
			STAND -- 5855
		) -- 5855
	end -- 5855
	drawFigure( -- 5857
		draw, -- 5857
		self, -- 5857
		w, -- 5857
		h, -- 5857
		p, -- 5857
		isChild and CHILD_BODY or SOLDIER_BODY, -- 5857
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 5857
	) -- 5857
	local q = self.partner -- 5858
	if q.alive then -- 5859
		local childPartner = q.w == CHILD_W -- 5860
		drawFigure( -- 5861
			draw, -- 5861
			self, -- 5861
			w, -- 5861
			h, -- 5861
			q, -- 5861
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 5861
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 5861
		) -- 5861
	end -- 5861
	local i = 0 -- 5863
	do -- 5863
		i = 0 -- 5864
		while i < #self.enemies do -- 5864
			local e = self.enemies[i + 1] -- 5865
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 5866
			local enemyY = e.y + (e.depth or 0) -- 5867
			self:drawBox( -- 5868
				draw, -- 5868
				w, -- 5868
				h, -- 5868
				e.x - e.w / 2, -- 5868
				e.x + e.w / 2, -- 5868
				enemyY, -- 5868
				enemyY + e.h, -- 5868
				col -- 5868
			) -- 5868
			if e.alive then -- 5869
				local ef = p.x >= e.x and 1 or -1 -- 5870
				if e.kind == "shield" then -- 5871
					local sh = (e.shieldHp or 0) > 0 -- 5872
					draw:drawRect( -- 5873
						Rect( -- 5873
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 5873
							self:sy(enemyY, h), -- 5873
							self:px(6), -- 5873
							self:px(64) -- 5873
						), -- 5873
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 5874
					) -- 5874
				elseif e.kind == "breaker" then -- 5875
					draw:drawSegment( -- 5876
						Vec2( -- 5876
							self:sx(e.x + ef * 12, w), -- 5876
							self:sy(enemyY + 8, h) -- 5876
						), -- 5876
						Vec2( -- 5877
							self:sx(e.x + ef * 22, w), -- 5877
							self:sy(enemyY + 46, h) -- 5877
						), -- 5877
						self:px(3), -- 5877
						Color(0.5, 0.36, 0.22, 1) -- 5877
					) -- 5877
				end -- 5877
			end -- 5877
			if e.alive and e.warnT > 0 then -- 5881
				local gunX = self:sx(e.x, w) -- 5882
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 5883
				local aimX = self:sx(p.x, w) -- 5884
				local aimY = self:sy(footY + p.h * 0.55, h) -- 5885
				local seg = 8 -- 5886
				local s = 0 -- 5887
				do -- 5887
					s = 0 -- 5888
					while s < seg do -- 5888
						local t0 = s / seg -- 5889
						local t1 = (s + 1) / seg -- 5890
						draw:drawSegment( -- 5891
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 5892
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 5893
							self:px(1), -- 5894
							DANGER -- 5894
						) -- 5894
						s = s + 2 -- 5888
					end -- 5888
				end -- 5888
			end -- 5888
			i = i + 1 -- 5864
		end -- 5864
	end -- 5864
	local k = 0 -- 5899
	do -- 5899
		k = 0 -- 5900
		while k < #self.room.marks do -- 5900
			do -- 5900
				local m = self.room.marks[k + 1] -- 5901
				if m.kind ~= 0 then -- 5902
					goto __continue1077 -- 5903
				end -- 5903
				local on = self.checkpoint == m.x -- 5905
				local x = self:sx(m.x, w) -- 5906
				local y = self:sy(m.y, h) -- 5907
				draw:drawSegment( -- 5908
					Vec2(x, y), -- 5908
					Vec2( -- 5908
						x, -- 5908
						y + self:px(35) -- 5908
					), -- 5908
					self:px(1), -- 5908
					on and CHECK or INK_DIM -- 5908
				) -- 5908
				draw:drawDot( -- 5909
					Vec2( -- 5909
						x, -- 5909
						y + self:px(35) -- 5909
					), -- 5909
					self:px(2), -- 5909
					on and CHECK or INK_DIM -- 5909
				) -- 5909
			end -- 5909
			::__continue1077:: -- 5909
			k = k + 1 -- 5900
		end -- 5900
	end -- 5900
	local j = 0 -- 5913
	do -- 5913
		j = 0 -- 5914
		while j < #self.room.marks do -- 5914
			do -- 5914
				local m = self.room.marks[j + 1] -- 5915
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 5916
					goto __continue1080 -- 5917
				end -- 5917
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 5919
					goto __continue1080 -- 5921
				end -- 5921
				local col = STAND -- 5923
				if m.kind == 4 then -- 5924
					col = PASS_LINE -- 5925
				elseif m.kind == 5 then -- 5926
					col = BRICK_LINE -- 5927
				end -- 5927
				local mx = self:sx(m.x, w) -- 5929
				local my = self:sy(m.y, h) -- 5930
				draw:drawSegment( -- 5931
					Vec2(mx, my), -- 5931
					Vec2( -- 5931
						mx, -- 5931
						my + self:px(24) -- 5931
					), -- 5931
					self:px(1), -- 5931
					col -- 5931
				) -- 5931
			end -- 5931
			::__continue1080:: -- 5931
			j = j + 1 -- 5914
		end -- 5914
	end -- 5914
	local t = 0 -- 5934
	do -- 5934
		t = 0 -- 5935
		while t < #self.room.marks do -- 5935
			do -- 5935
				local m = self.room.marks[t + 1] -- 5936
				if m.kind ~= 6 then -- 5937
					goto __continue1086 -- 5938
				end -- 5938
				local mx = self:sx(m.x, w) -- 5940
				local my = self:sy(m.y, h) -- 5941
				draw:drawSegment( -- 5942
					Vec2(mx, my), -- 5942
					Vec2( -- 5942
						mx, -- 5942
						my + self:px(30) -- 5942
					), -- 5942
					self:px(1), -- 5942
					INK_DIM -- 5942
				) -- 5942
				self:drawBox( -- 5943
					draw, -- 5943
					w, -- 5943
					h, -- 5943
					m.x - 5, -- 5943
					m.x + 5, -- 5943
					m.y + 30, -- 5943
					m.y + 40, -- 5943
					CHECK -- 5943
				) -- 5943
			end -- 5943
			::__continue1086:: -- 5943
			t = t + 1 -- 5935
		end -- 5935
	end -- 5935
	if self.room.key == "village" then -- 5945
		self:drawVillage(draw, w, h) -- 5946
	end -- 5946
	if self.room.key == "forest" then -- 5948
		self:drawDog(draw, w, h) -- 5949
	end -- 5949
end -- 5843
function Play.prototype.drawDog(self, draw, w, h) -- 5954
	local x = self.dogX -- 5955
	self:drawBox( -- 5956
		draw, -- 5956
		w, -- 5956
		h, -- 5956
		x - 14, -- 5956
		x + 14, -- 5956
		0, -- 5956
		20, -- 5956
		SCAV_BODY -- 5956
	) -- 5956
	self:drawBox( -- 5957
		draw, -- 5957
		w, -- 5957
		h, -- 5957
		x - 10, -- 5957
		x - 2, -- 5957
		20, -- 5957
		30, -- 5957
		SCAV_BODY -- 5957
	) -- 5957
	self:drawBox( -- 5958
		draw, -- 5958
		w, -- 5958
		h, -- 5958
		x + 2, -- 5958
		x + 10, -- 5958
		20, -- 5958
		30, -- 5958
		SCAV_HEAD -- 5958
	) -- 5958
	if self.dogState == "ear" or self.dogState == "chase" then -- 5959
		draw:drawSegment( -- 5960
			Vec2( -- 5960
				self:sx(x, w), -- 5960
				self:sy(30, h) -- 5960
			), -- 5960
			Vec2( -- 5961
				self:sx(x, w), -- 5961
				self:sy(40, h) -- 5961
			), -- 5961
			self:px(1), -- 5961
			DANGER -- 5961
		) -- 5961
	end -- 5961
end -- 5954
function Play.prototype.drawVillage(self, draw, w, h) -- 5966
	local bottle = self.room.bottle -- 5967
	if bottle ~= nil then -- 5968
		self:drawBox( -- 5969
			draw, -- 5969
			w, -- 5969
			h, -- 5969
			bottle.x - 14, -- 5969
			bottle.x + 14, -- 5969
			0, -- 5969
			64, -- 5969
			SOLID_FILL -- 5969
		) -- 5969
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 5970
			self:drawBottle( -- 5971
				draw, -- 5971
				w, -- 5971
				h, -- 5971
				bottle.x, -- 5971
				64 -- 5971
			) -- 5971
		end -- 5971
	end -- 5971
	self:drawBox( -- 5975
		draw, -- 5975
		w, -- 5975
		h, -- 5975
		300, -- 5975
		420, -- 5975
		44, -- 5975
		50, -- 5975
		FLOOR_DECK -- 5975
	) -- 5975
	self:drawBox( -- 5976
		draw, -- 5976
		w, -- 5976
		h, -- 5976
		300, -- 5976
		306, -- 5976
		0, -- 5976
		44, -- 5976
		FLOOR_DECK -- 5976
	) -- 5976
	self:drawBox( -- 5977
		draw, -- 5977
		w, -- 5977
		h, -- 5977
		414, -- 5977
		420, -- 5977
		0, -- 5977
		44, -- 5977
		FLOOR_DECK -- 5977
	) -- 5977
	local s = self.room.scavenger -- 5979
	if s ~= nil then -- 5980
		local sx0 = self.scavX -- 5981
		self:drawBox( -- 5982
			draw, -- 5982
			w, -- 5982
			h, -- 5982
			sx0 - 12, -- 5982
			sx0 + 12, -- 5982
			0, -- 5982
			s.h - 14, -- 5982
			SCAV_BODY -- 5982
		) -- 5982
		self:drawBox( -- 5983
			draw, -- 5983
			w, -- 5983
			h, -- 5983
			sx0 - 7, -- 5983
			sx0 + 7, -- 5983
			s.h - 14, -- 5983
			s.h, -- 5983
			SCAV_HEAD -- 5983
		) -- 5983
		if self.scavState == "turn" then -- 5984
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 5985
			draw:drawSegment( -- 5986
				Vec2( -- 5986
					self:sx(sx0, w), -- 5986
					self:sy(s.h - 6, h) -- 5986
				), -- 5986
				Vec2( -- 5986
					self:sx(fx, w), -- 5986
					self:sy(s.h - 6, h) -- 5986
				), -- 5986
				self:px(1), -- 5986
				INK -- 5986
			) -- 5986
		end -- 5986
	end -- 5986
	if self.hasBottle then -- 5990
		local p = self.player -- 5991
		self:drawBottle( -- 5992
			draw, -- 5992
			w, -- 5992
			h, -- 5992
			p.x + p.facing * 10, -- 5992
			p.y + p.h * 0.62 -- 5992
		) -- 5992
	end -- 5992
	if self.bottleFly ~= nil then -- 5994
		self:drawBottle( -- 5995
			draw, -- 5995
			w, -- 5995
			h, -- 5995
			self.bottleFly.x, -- 5995
			self.bottleFly.y -- 5995
		) -- 5995
	end -- 5995
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 5997
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 5998
		draw:drawCircle( -- 5999
			Vec2( -- 5999
				self:sx(self.bottleLandX, w), -- 5999
				self:sy(0, h) -- 5999
			), -- 5999
			self:px(r / ____exports.UNITS_PER_PX), -- 5999
			BRICK_LINE -- 5999
		) -- 5999
	end -- 5999
end -- 5966
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 6003
	self:drawBox( -- 6004
		draw, -- 6004
		w, -- 6004
		h, -- 6004
		x - 3, -- 6004
		x + 3, -- 6004
		y - 10, -- 6004
		y, -- 6004
		BOTTLE -- 6004
	) -- 6004
end -- 6003
function Play.prototype.drawTrace(self, draw, w, h) -- 6007
	local t = self.trace -- 6008
	if t == nil or self.traceT <= 0 then -- 6009
		return -- 6010
	end -- 6010
	draw:drawSegment( -- 6012
		Vec2( -- 6013
			self:sx(t.x0, w), -- 6013
			self:sy(t.y0, h) -- 6013
		), -- 6013
		Vec2( -- 6014
			self:sx(t.x1, w), -- 6014
			self:sy(t.y1, h) -- 6014
		), -- 6014
		self:px(1), -- 6015
		t.hit and AIM_HIT or INK_DIM -- 6015
	) -- 6015
end -- 6007
function Play.prototype.drawAim(self, draw, w, h) -- 6018
	local v = self.view -- 6020
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 6021
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 6022
	local dot = self:px(1) -- 6023
	local arm = self:px(3) -- 6024
	local gap = self:px(1) -- 6025
	draw:drawSegment( -- 6026
		Vec2(gx - arm - gap, gy), -- 6026
		Vec2(gx - gap, gy), -- 6026
		dot / 2, -- 6026
		AIM -- 6026
	) -- 6026
	draw:drawSegment( -- 6027
		Vec2(gx + gap, gy), -- 6027
		Vec2(gx + arm + gap, gy), -- 6027
		dot / 2, -- 6027
		AIM -- 6027
	) -- 6027
	draw:drawSegment( -- 6028
		Vec2(gx, gy - arm - gap), -- 6028
		Vec2(gx, gy - gap), -- 6028
		dot / 2, -- 6028
		AIM -- 6028
	) -- 6028
	draw:drawSegment( -- 6029
		Vec2(gx, gy + gap), -- 6029
		Vec2(gx, gy + arm + gap), -- 6029
		dot / 2, -- 6029
		AIM -- 6029
	) -- 6029
	if self.room.key == "village" and self.hasBottle then -- 6032
		local p = self.player -- 6033
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 6035
		local dir = ____end.x >= p.x and 1 or -1 -- 6036
		local x0 = p.x + dir * 10 -- 6037
		local y0 = p.y + p.h * 0.7 -- 6038
		local T = BOTTLE_FLY_TIME -- 6039
		local vx = (____end.x - x0) / T -- 6040
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 6041
		local pxr = x0 -- 6042
		local pyr = y0 -- 6043
		local t = 1 -- 6044
		do -- 6044
			t = 1 -- 6045
			while t <= 12 do -- 6045
				local tt = t / 12 * T -- 6046
				local nx = x0 + vx * tt -- 6047
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 6048
				draw:drawSegment( -- 6049
					Vec2( -- 6049
						self:sx(pxr, w), -- 6049
						self:sy(pyr, h) -- 6049
					), -- 6049
					Vec2( -- 6049
						self:sx(nx, w), -- 6049
						self:sy(ny, h) -- 6049
					), -- 6049
					self:px(1) / 2, -- 6049
					BOTTLE -- 6049
				) -- 6049
				pxr = nx -- 6050
				pyr = ny -- 6051
				t = t + 1 -- 6045
			end -- 6045
		end -- 6045
		draw:drawCircle( -- 6053
			Vec2( -- 6053
				self:sx(____end.x, w), -- 6053
				self:sy(____end.y + 2, h) -- 6053
			), -- 6053
			self:px(2), -- 6053
			BOTTLE -- 6053
		) -- 6053
	end -- 6053
end -- 6018
return ____exports -- 6018
