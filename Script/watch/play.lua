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
local makeActor, drawFigure, rayInterval, hitBox, drawCartShape, CHILD_W, CHILD_H, SOLDIER_W, SOLDIER_H, INK, CART_FILL, CLOTH -- 6105
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
function makeActor(room, index) -- 6105
	local sp = room.spawns -- 6106
	if index < 0 or index >= #sp then -- 6107
		return { -- 6108
			x = 0, -- 6108
			y = 0, -- 6108
			depth = 0, -- 6108
			depthSpeed = 0, -- 6108
			vx = 0, -- 6108
			vy = 0, -- 6108
			w = CHILD_W, -- 6108
			h = CHILD_H, -- 6108
			onGround = true, -- 6108
			facing = 1, -- 6108
			crouch = false, -- 6108
			rollT = 0, -- 6108
			covered = false, -- 6108
			alive = false -- 6108
		} -- 6108
	end -- 6108
	local s = sp[index + 1] -- 6110
	local child = s.h < SOLDIER_H -- 6111
	local ground = room.depth -- 6112
	local depth = ground == nil and 0 or math.max( -- 6113
		ground.min, -- 6113
		math.min(ground.max, s.depth or 0) -- 6113
	) -- 6113
	return { -- 6114
		x = s.x, -- 6115
		y = s.y, -- 6115
		depth = depth, -- 6115
		depthSpeed = 0, -- 6115
		vx = 0, -- 6115
		vy = 0, -- 6115
		w = child and CHILD_W or SOLDIER_W, -- 6116
		h = child and CHILD_H or SOLDIER_H, -- 6117
		onGround = true, -- 6118
		facing = 1, -- 6118
		crouch = false, -- 6118
		rollT = 0, -- 6118
		covered = false, -- 6118
		alive = true -- 6118
	} -- 6118
end -- 6118
function drawFigure(draw, play, w, h, a, body, head) -- 6122
	if not a.alive then -- 6123
		return -- 6124
	end -- 6124
	local x0 = a.x - a.w / 2 -- 6126
	local x1 = a.x + a.w / 2 -- 6127
	local y0 = a.y + a.depth * DEPTH_Y_SCALE -- 6128
	local y1 = y0 + a.h -- 6129
	play:drawBox( -- 6130
		draw, -- 6130
		w, -- 6130
		h, -- 6130
		x0, -- 6130
		x1, -- 6130
		y0, -- 6130
		y1 - a.h * 0.26, -- 6130
		body -- 6130
	) -- 6130
	play:drawBox( -- 6131
		draw, -- 6131
		w, -- 6131
		h, -- 6131
		x0 + 2, -- 6131
		x1 - 2, -- 6131
		y1 - a.h * 0.26, -- 6131
		y1, -- 6131
		head -- 6131
	) -- 6131
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 6133
	play:drawBox( -- 6134
		draw, -- 6134
		w, -- 6134
		h, -- 6134
		eyeX, -- 6134
		eyeX + 4, -- 6134
		y1 - a.h * 0.14, -- 6134
		y1 - a.h * 0.08, -- 6134
		INK -- 6134
	) -- 6134
end -- 6134
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 6138
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 6139
end -- 6138
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 6146
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 6147
end -- 6146
function rayInterval(origin, direction, min, max) -- 6154
	if direction == 0 then -- 6155
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 6156
	end -- 6156
	local a = (min - origin) / direction -- 6158
	local b = (max - origin) / direction -- 6159
	return { -- 6160
		min = math.min(a, b), -- 6160
		max = math.max(a, b) -- 6160
	} -- 6160
end -- 6160
function hitBox(ray, box) -- 6164
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 6165
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 6166
	local enter = math.max(0, x.min, y.min) -- 6167
	local leave = math.min(99999, x.max, y.max) -- 6168
	if box.depth ~= nil then -- 6169
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 6170
		enter = math.max(enter, depth.min) -- 6171
		leave = math.min(leave, depth.max) -- 6172
	end -- 6172
	return leave >= enter and enter or -1 -- 6174
end -- 6174
function drawCartShape(draw, play, w, h, c, axleX) -- 6177
	local half = c.bodyW / 2 -- 6178
	local x0 = axleX - half -- 6179
	local x1 = axleX + half -- 6180
	local axleY = c.baseY + (c.depth or 0) * DEPTH_Y_SCALE + c.wheelR -- 6181
	play:drawBox( -- 6182
		draw, -- 6182
		w, -- 6182
		h, -- 6182
		x0, -- 6182
		x1, -- 6182
		axleY, -- 6182
		axleY + c.bodyH, -- 6182
		CART_FILL -- 6182
	) -- 6182
	draw:drawCircle( -- 6183
		Vec2( -- 6183
			play:sx(x0 + c.bodyW * 0.28, w), -- 6183
			play:sy(axleY, h) -- 6183
		), -- 6183
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6183
		Color(52, 50, 48, 255) -- 6183
	) -- 6183
	draw:drawCircle( -- 6184
		Vec2( -- 6184
			play:sx(x1 - c.bodyW * 0.28, w), -- 6184
			play:sy(axleY, h) -- 6184
		), -- 6184
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6184
		Color(52, 50, 48, 255) -- 6184
	) -- 6184
	local cx = c.clothSide < 0 and x0 or x1 -- 6185
	play:drawBox( -- 6186
		draw, -- 6186
		w, -- 6186
		h, -- 6186
		cx - 10, -- 6186
		cx + 10, -- 6186
		axleY + c.bodyH, -- 6186
		axleY + c.bodyH + 18, -- 6186
		CLOTH -- 6186
	) -- 6186
end -- 6186
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
	self.reloadT = 0 -- 1695
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1696
	self:flashSet( -- 1699
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1699
		1.4 -- 1699
	) -- 1699
end -- 1672
function Play.prototype.consumeReloadEffect(self) -- 1703
	local e = self.reloadPendingEffect -- 1704
	if e ~= "" then -- 1705
		self.reloadPendingEffect = "" -- 1706
	end -- 1706
	return e -- 1708
end -- 1703
function Play.prototype.echoToSource(self, from, count) -- 1715
	if count == nil then -- 1715
		count = 1 -- 1715
	end -- 1715
	local best = -1 -- 1716
	local bestD = 1000000000 -- 1717
	local i = 0 -- 1718
	local woken = {} -- 1719
	local n = 0 -- 1720
	while n < count do -- 1721
		best = -1 -- 1722
		bestD = 1000000000 -- 1723
		do -- 1723
			i = 0 -- 1724
			while i < #self.enemies do -- 1724
				do -- 1724
					if woken[i] == true then -- 1725
						goto __continue199 -- 1726
					end -- 1726
					local e = self.enemies[i + 1] -- 1728
					if not e.alive then -- 1729
						goto __continue199 -- 1730
					end -- 1730
					local d = math.abs(e.x - from.x) -- 1732
					if d < bestD then -- 1733
						bestD = d -- 1734
						best = i -- 1735
					end -- 1735
				end -- 1735
				::__continue199:: -- 1735
				i = i + 1 -- 1724
			end -- 1724
		end -- 1724
		if best < 0 then -- 1738
			break -- 1739
		end -- 1739
		woken[best] = true -- 1741
		local e = self.enemies[best + 1] -- 1742
		e.awake = true -- 1743
		e.warnT = 0 -- 1744
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1745
		n = n + 1 -- 1746
	end -- 1746
	if n == 0 then -- 1748
		return -- 1749
	end -- 1749
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1751
end -- 1715
function Play.prototype.reloadTicks(self) -- 1754
	return math.max( -- 1755
		6, -- 1755
		(self.run.inventory.quickbelt > 0 and 36 or 54) - 6 * self:talentRank("reload") - 3 * self:talentRank("craft") -- 1755
	) -- 1755
end -- 1754
function Play.prototype.update(self, dt, input) -- 1758
	self:syncCraftBench() -- 1759
	local trial = self.run.trial -- 1760
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1761
		return -- 1761
	end -- 1761
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1762
		self:closeCraftBench() -- 1763
		return -- 1764
	end -- 1764
	if input.pause.pressed then -- 1766
		self.paused = not self.paused -- 1767
	end -- 1767
	if self.flashT > 0 then -- 1769
		self.flashT = self.flashT - dt -- 1770
		if self.flashT <= 0 then -- 1771
			self.flash = "" -- 1772
		end -- 1772
	end -- 1772
	if self.traceT > 0 then -- 1775
		self.traceT = self.traceT - dt -- 1776
		if self.traceT <= 0 then -- 1777
			self.trace = nil -- 1778
		end -- 1778
	end -- 1778
	if self.paused then -- 1781
		self:updateCamera(dt) -- 1782
		return -- 1783
	end -- 1783
	if self.craftBench.active then -- 1787
		self:updateCamera(dt) -- 1788
		return -- 1789
	end -- 1789
	if self.reloadOpen then -- 1794
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1795
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1796
			self.reloadOpen = false -- 1797
			self.reloadPendingEffect = "" -- 1798
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1799
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1800
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1801
			self:updateCamera(dt) -- 1802
			return -- 1803
		else -- 1803
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1805
		end -- 1805
	end -- 1805
	self.ticks = self.ticks + 1 -- 1809
	if self.invulnT > 0 then -- 1812
		self.invulnT = self.invulnT - 1 -- 1813
	end -- 1813
	if self.isCampaign then -- 1815
		local ____self_run_35, ____ticks_36 = self.run, "ticks" -- 1816
		____self_run_35[____ticks_36] = ____self_run_35[____ticks_36] + 1 -- 1816
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1817
	end -- 1817
	local p = self.player -- 1819
	self:stepPlayer(p, dt, input) -- 1820
	self:refreshCover(p, input) -- 1822
	if self.carryOn then -- 1823
		self:carryPose() -- 1824
	end -- 1824
	if self.isCampaign then -- 1826
		self:stepCampaign(dt, input) -- 1827
		if not self.carryOn then -- 1828
			self:stepCampaignPartner(dt) -- 1829
		end -- 1829
	end -- 1829
	if trial == nil or not self.run.finished then -- 1836
		self:stepEnemies(dt, input) -- 1837
	end -- 1837
	if trial ~= nil then -- 1839
		trial.hp = self.hp -- 1839
	end -- 1839
	if not self.isCampaign then -- 1840
		self:stepStory(dt, input) -- 1841
		self:stepEscort(dt, input) -- 1842
		self:stepVillage(dt, input) -- 1843
		self:stepChase(dt, input) -- 1844
		self:stepInteract(dt, input) -- 1845
	end -- 1845
	self:updateGate() -- 1847
	self:updateCamera(dt) -- 1848
	self:syncStory() -- 1850
end -- 1758
function Play.prototype.underLowArch(self, a) -- 1857
	local arch = self.room.arch -- 1858
	if arch.h <= 0 then -- 1859
		return false -- 1860
	end -- 1860
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1862
		return false -- 1863
	end -- 1863
	local top = arch.y + arch.h -- 1865
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1866
end -- 1857
function Play.prototype.coverAt(self, a) -- 1873
	local best = nil -- 1874
	local bestGap = 24 -- 1875
	local half = a.w / 2 -- 1876
	local i = 0 -- 1877
	do -- 1877
		i = 0 -- 1878
		while i < #self.boxes do -- 1878
			do -- 1878
				local b = self.boxes[i + 1] -- 1879
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1880
					goto __continue233 -- 1881
				end -- 1881
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1883
					goto __continue233 -- 1884
				end -- 1884
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1886
				if gap < bestGap then -- 1887
					bestGap = gap -- 1888
					best = b -- 1889
				end -- 1889
			end -- 1889
			::__continue233:: -- 1889
			i = i + 1 -- 1878
		end -- 1878
	end -- 1878
	return best -- 1892
end -- 1873
function Play.prototype.nearCover(self, a) -- 1895
	return self:coverAt(a) ~= nil -- 1896
end -- 1895
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1900
	if enemy == nil then -- 1901
		return false -- 1902
	end -- 1902
	local fromRight = enemy.x >= a.x -- 1904
	local edge = fromRight and b.x0 or b.x1 -- 1905
	local ____fromRight_37 -- 1906
	if fromRight then -- 1906
		____fromRight_37 = edge >= a.x - 0.001 and edge <= enemy.x -- 1906
	else -- 1906
		____fromRight_37 = edge <= a.x + 0.001 and edge >= enemy.x -- 1907
	end -- 1907
	local between = ____fromRight_37 -- 1906
	local separation = enemy.x - a.x -- 1908
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1909
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1910
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1911
end -- 1900
function Play.prototype.nearestEnemy(self, a) -- 1914
	local best -- 1915
	local bestD = 1000000000 -- 1916
	local i = 0 -- 1917
	do -- 1917
		i = 0 -- 1918
		while i < #self.enemies do -- 1918
			do -- 1918
				local e = self.enemies[i + 1] -- 1919
				if not e.alive then -- 1920
					goto __continue242 -- 1921
				end -- 1921
				local d = math.abs(e.x - a.x) -- 1923
				if d < bestD then -- 1924
					bestD = d -- 1925
					best = e -- 1926
				end -- 1926
			end -- 1926
			::__continue242:: -- 1926
			i = i + 1 -- 1918
		end -- 1918
	end -- 1918
	return best -- 1929
end -- 1914
function Play.prototype.refreshCover(self, a, input) -- 1933
	if self.childMode then -- 1934
		self.coverNear = false -- 1935
		self.coverHug = false -- 1936
		self.coverEntity = "" -- 1937
		self.coverBlocking = false -- 1938
		a.covered = false -- 1939
		return -- 1940
	end -- 1940
	local b = self:coverAt(a) -- 1942
	self.coverNear = b ~= nil -- 1943
	a.covered = self.coverNear and input.cover.held -- 1944
	self.coverHug = a.covered -- 1945
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1946
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1947
		b, -- 1947
		a, -- 1947
		self:nearestEnemy(a) -- 1947
	) -- 1947
end -- 1933
function Play.prototype.cartHandleInReach(self, a) -- 1951
	if a == nil then -- 1951
		a = self.player -- 1951
	end -- 1951
	local c = self.room.cart -- 1952
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1953
		return false -- 1954
	end -- 1954
	local handleX = self.cartAxle + c.handleOffset -- 1956
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1957
end -- 1951
function Play.prototype.nearLowLedge(self, a) -- 1962
	local reach = 26 -- 1963
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1964
	local x1 = x0 + reach -- 1965
	local i = 0 -- 1966
	do -- 1966
		i = 0 -- 1967
		while i < #self.boxes do -- 1967
			do -- 1967
				local b = self.boxes[i + 1] -- 1968
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1969
					goto __continue251 -- 1970
				end -- 1970
				local rise = b.y1 - a.y -- 1972
				if rise > 0 and rise <= LEDGE_RISE then -- 1973
					return true -- 1974
				end -- 1974
			end -- 1974
			::__continue251:: -- 1974
			i = i + 1 -- 1967
		end -- 1967
	end -- 1967
	return false -- 1977
end -- 1962
function Play.prototype.stepPlayer(self, a, dt, input) -- 1980
	a.depthSpeed = 0 -- 1981
	if not a.alive then -- 1982
		return -- 1983
	end -- 1983
	local isChild = self.childMode -- 1985
	local lowArch = isChild and self:underLowArch(a) -- 1987
	if self:storyLocked() then -- 1989
		a.vx = 0 -- 1990
		a.crouch = isChild and lowArch -- 1991
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1992
		self:fallY(a, dt) -- 1993
		return -- 1994
	end -- 1994
	if not isChild and self.escort.state == "calming" then -- 1997
		a.crouch = false -- 1998
		a.h = SOLDIER_H -- 1999
		a.vx = 0 -- 2000
		self:fallY(a, dt) -- 2001
		return -- 2002
	end -- 2002
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 2004
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 2005
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2006
	local nearCover = not isChild and self:nearCover(a) -- 2007
	a.covered = nearCover and input.cover.held -- 2008
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 2010
	if a.rollT > 0 then -- 2013
		a.rollT = a.rollT - dt -- 2014
		a.vx = a.facing * ROLL_SPEED -- 2015
		self:slideX(a, a.vx * dt) -- 2016
		self:fallY(a, dt) -- 2017
		if a.rollT <= 0 then -- 2018
			self:flashSet("翻滚结束", 0.5) -- 2019
		end -- 2019
		return -- 2021
	end -- 2021
	local peacefulRoom = self.room.key == "museum" or self.room.key == "tower" -- 2024
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 2025
		if input.moveX ~= 0 then -- 2026
			a.facing = input.moveX > 0 and 1 or -1 -- 2027
		end -- 2027
		if self:nearLowLedge(a) then -- 2030
			a.vy = SOLDIER_JUMP -- 2031
			a.onGround = false -- 2032
			self:flashSet("翻上去", 0.3) -- 2033
			return -- 2034
		end -- 2034
		a.rollT = ROLL_TIME -- 2036
		self:flashSet("翻滚", 0.3) -- 2037
		return -- 2038
	end -- 2038
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 2041
	if isChild then -- 2042
		if input.cover.held then -- 2043
			speed = CHILD_SLOW -- 2044
		end -- 2044
		if a.crouch then -- 2046
			speed = CHILD_SLOW -- 2047
		elseif self.room.key == "forest" and self.forestPath == "ditch" and a.x >= self.ox + 700 and a.x <= self.ox + 1140 then -- 2048
			speed = CHILD_SPEED * 1.22 -- 2051
		end -- 2051
	elseif a.covered then -- 2053
		speed = SOLDIER_SPEED * 0.45 -- 2054
	end -- 2054
	local handsBusy = self.gripping or gripIntent or self.reloadOpen -- 2058
	local dir = (self.gripping or self.reloadOpen) and 0 or input.moveX -- 2059
	local depthDir = self.room.depth ~= nil and not handsBusy and (not isChild or self.phase == "prologue-escape") and -input.moveY or 0 -- 2061
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 2063
	if dir ~= 0 then -- 2064
		a.facing = dir > 0 and 1 or -1 -- 2065
	end -- 2065
	a.vx = dir * speed * diagonal -- 2067
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 2070
		a.vy = CHILD_JUMP -- 2071
		a.onGround = false -- 2072
		self:flashSet("跳", 0.25) -- 2073
	end -- 2073
	local previousDepth = a.depth -- 2077
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 2078
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2079
	self:slideX(a, a.vx * dt) -- 2080
	self:fallY(a, dt) -- 2081
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and not self.reloadOpen and input.fire.pressed then -- 2084
		self:shoot(a) -- 2085
	end -- 2085
	local ____temp_40 = not isChild and not peacefulRoom and not self.gripping and not self.reloadOpen and self.reloadPendingEffect == "" and self.run.trial == nil -- 2088
	if ____temp_40 then -- 2088
		local ____opt_38 = self.room.campaign -- 2089
		____temp_40 = (____opt_38 and ____opt_38.reloadPuzzle) == true -- 2088
	end -- 2088
	if ____temp_40 and input.flare.pressed then -- 2088
		self:beginReload() -- 2090
	end -- 2090
end -- 1980
function Play.prototype.stepPartner(self, p, dt) -- 2095
	local a = self.partner -- 2096
	if not a.alive then -- 2097
		return -- 2098
	end -- 2098
	a.crouch = false -- 2100
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 2101
	a.vx = 0 -- 2102
	a.depthSpeed = 0 -- 2103
	self:fallY(a, dt) -- 2104
end -- 2095
function Play.prototype.stepEscort(self, dt, input) -- 2111
	local a = self.partner -- 2112
	a.depthSpeed = 0 -- 2113
	if not a.alive then -- 2114
		return -- 2115
	end -- 2115
	if self.room.key == "gatepath" then -- 2117
		if self.carryOn then -- 2119
			return -- 2120
		end -- 2120
		local p = self.player -- 2123
		a.depth = p.depth -- 2124
		a.facing = p.facing -- 2125
		a.crouch = false -- 2126
		a.h = CHILD_H -- 2127
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 2128
		a.y = p.y -- 2129
		a.vy = 0 -- 2130
		a.vx = p.vx -- 2131
		a.onGround = p.onGround -- 2132
		return -- 2133
	end -- 2133
	if not self:escortOn() then -- 2135
		a.vx = 0 -- 2136
		self:fallY(a, dt) -- 2137
		return -- 2138
	end -- 2138
	local p = self.player -- 2140
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 2141
	local hadKnock1 = self.escort.knock1 -- 2142
	local hadKnock2 = self.escort.knock2 -- 2143
	self.calmConsumed = self.escort:update( -- 2144
		input, -- 2144
		p.x, -- 2144
		p.facing, -- 2144
		a.x, -- 2144
		dist -- 2144
	) -- 2144
	if not hadKnock1 and self.escort.knock1 then -- 2146
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 2147
	end -- 2147
	if not hadKnock2 and self.escort.knock2 then -- 2149
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 2150
	end -- 2150
	a.crouch = self.escort.crouchPose -- 2152
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 2153
	if not self.escort.stopped then -- 2154
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 2155
		local previousDepth = a.depth -- 2156
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 2157
		local distance = math.max( -- 2158
			-travel, -- 2158
			math.min(travel, targetDepth - previousDepth) -- 2158
		) -- 2158
		self:slideDepth(a, distance) -- 2159
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2160
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 2161
			a.vy = CHILD_JUMP -- 2162
			a.onGround = false -- 2163
		end -- 2163
	end -- 2163
	local dir = self.escort:moveDir(a.x) -- 2166
	a.vx = dir * CHILD_SPEED -- 2167
	if dir ~= 0 then -- 2168
		a.facing = dir -- 2169
		local before = a.x -- 2170
		self:slideX(a, dir * CHILD_SPEED * dt) -- 2171
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 2173
			a.vy = CHILD_JUMP -- 2174
			a.onGround = false -- 2175
		end -- 2175
	end -- 2175
	self:fallY(a, dt) -- 2178
end -- 2111
function Play.prototype.escortOn(self) -- 2182
	if self.room.key == "checkpoint" then -- 2183
		return true -- 2184
	end -- 2184
	if self.room.key == "gatepath" then -- 2186
		return true -- 2187
	end -- 2187
	if self.room.key == "prologue" then -- 2189
		return self.phase == "prologue-follow" -- 2190
	end -- 2190
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 2192
		return true -- 2194
	end -- 2194
	return self.room.key == "street" -- 2196
end -- 2182
function Play.prototype.storyLocked(self) -- 2200
	if self.caughtT > 0 then -- 2201
		return true -- 2202
	end -- 2202
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 2204
		return true -- 2206
	end -- 2206
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 2208
		return true -- 2209
	end -- 2209
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 2211
		return true -- 2212
	end -- 2212
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2214
		return true -- 2215
	end -- 2215
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2217
		return true -- 2218
	end -- 2218
	if self.craftBench.active then -- 2221
		return true -- 2222
	end -- 2222
	return false -- 2224
end -- 2200
function Play.prototype.swapToChild(self, x) -- 2228
	local tmp = self.player -- 2229
	self.player = self.partner -- 2230
	self.partner = tmp -- 2231
	self.childMode = true -- 2232
	self.player.alive = true -- 2233
	self.player.x = self.ox + x -- 2234
	self.player.y = 0 -- 2235
	self.player.depth = 0 -- 2236
	self.player.depthSpeed = 0 -- 2237
	self.player.vy = 0 -- 2238
	self.player.vx = 0 -- 2239
	self.player.onGround = true -- 2240
	self.player.crouch = false -- 2241
	self.player.h = CHILD_H -- 2242
	self.player.facing = 1 -- 2243
	self.partner.alive = true -- 2244
	self.cam.x = self.player.x -- 2245
end -- 2228
function Play.prototype.swapToSoldier(self, x, childX) -- 2249
	local tmp = self.player -- 2250
	self.player = self.partner -- 2251
	self.partner = tmp -- 2252
	self.childMode = false -- 2253
	self.player.alive = true -- 2254
	self.player.x = self.ox + x -- 2255
	self.player.y = 0 -- 2256
	self.player.depth = 0 -- 2257
	self.player.depthSpeed = 0 -- 2258
	self.player.vy = 0 -- 2259
	self.player.vx = 0 -- 2260
	self.player.onGround = true -- 2261
	self.player.crouch = false -- 2262
	self.player.h = SOLDIER_H -- 2263
	self.player.facing = 1 -- 2264
	self.partner.alive = true -- 2265
	self.partner.x = self.ox + childX -- 2266
	self.partner.y = 0 -- 2267
	self.partner.depth = 0 -- 2268
	self.partner.depthSpeed = 0 -- 2269
	self.partner.vx = 0 -- 2270
	self.partner.vy = 0 -- 2271
	self.partner.onGround = true -- 2272
	self.partner.crouch = true -- 2273
	self.partner.h = CHILD_CROUCH_H -- 2274
	self.cam.x = self.player.x -- 2275
end -- 2249
function Play.prototype.stepStory(self, dt, input) -- 2279
	if self.room.key == "prologue" then -- 2280
		self:stepPrologue(dt, input) -- 2281
	elseif self.room.key == "street" then -- 2282
		self:stepStreet(dt, input) -- 2283
	elseif self.room.key == "gate" then -- 2284
		self:stepGate(dt, input) -- 2285
	elseif self.room.key == "gatepath" then -- 2286
		self:stepGatePath() -- 2287
	elseif self.room.key == "tower" then -- 2288
		self:stepTower(dt, input) -- 2289
	elseif self.room.key == "museum" then -- 2290
		self:stepMuseum(dt, input) -- 2291
	end -- 2291
end -- 2279
function Play.prototype.canPersistProgress(self) -- 2297
	return not self.isCampaign and self.run.source == "official" -- 2298
end -- 2297
function Play.prototype.wellWindow(self) -- 2302
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 2303
end -- 2302
function Play.prototype.nearWell(self) -- 2308
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 2309
end -- 2308
function Play.prototype.pickWell(self) -- 2317
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2318
		return false -- 2319
	end -- 2319
	self.phase = "prologue-well" -- 2321
	self.phaseTick = 0 -- 2322
	self.wellOpen = false -- 2323
	self:flashSet("井沿 · 伸手下去", 1.4) -- 2324
	self:log("旧井拾取") -- 2325
	return true -- 2326
end -- 2317
function Play.prototype.stepPrologue(self, dt, input) -- 2329
	local child = self.partner -- 2330
	if self.museumReturn then -- 2331
		self.museumReturn = false -- 2333
		self.phase = "prologue-wait" -- 2334
		self.phaseTick = 0 -- 2335
		self.player.x = self.ox + 260 -- 2336
		self.player.y = 0 -- 2337
		self.player.depth = 0 -- 2338
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2339
	end -- 2339
	if self.phase == "prologue-wake" then -- 2342
		self.introTick = self.introTick + 1 -- 2343
		if self.introTick == 60 then -- 2344
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2345
		end -- 2345
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2347
			self.phase = "prologue-shadow" -- 2348
			self.introTick = 0 -- 2349
			self:flashSet("门缝里两道影子", 1.2) -- 2350
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2351
		end -- 2351
		return -- 2353
	end -- 2353
	if self.phase == "prologue-shadow" then -- 2355
		self.introTick = self.introTick + 1 -- 2356
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2357
			self.phase = "prologue-escape" -- 2359
			self.introTick = 0 -- 2360
			self.escapeRemaining = self.escapeDuration -- 2361
			self.escapeRetryCount = 0 -- 2362
			self:swapToChild(100) -- 2363
			self:flashSet( -- 2364
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2364
				1.6 -- 2364
			) -- 2364
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2365
		end -- 2365
		return -- 2369
	end -- 2369
	if self.phase == "prologue-escape" then -- 2371
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2372
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2373
			self.phase = "prologue-hide" -- 2375
			self.introTick = 0 -- 2376
			self.player.vx = 0 -- 2377
			self.player.crouch = true -- 2378
			self.player.h = CHILD_CROUCH_H -- 2379
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2380
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2381
			return -- 2385
		end -- 2385
		if self.escapeRemaining <= 0 then -- 2387
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2389
			self.player.x = self.ox + 100 -- 2390
			self.player.y = 0 -- 2391
			self.player.depth = 0 -- 2392
			self.player.vx = 0 -- 2393
			self.player.vy = 0 -- 2394
			self.escapeRemaining = self.escapeDuration -- 2395
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2396
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2397
			return -- 2398
		end -- 2398
		return -- 2400
	end -- 2400
	if self.phase == "prologue-hide" then -- 2402
		self.introTick = self.introTick + 1 -- 2403
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2404
			self.phase = "prologue-wait" -- 2406
			self.phaseTick = 0 -- 2407
			self.introTick = 0 -- 2408
			self:swapToSoldier(260, 300) -- 2409
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2410
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2411
		end -- 2411
		return -- 2413
	end -- 2413
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2416
	if self.phase == "prologue-wait" then -- 2417
		child.crouch = true -- 2418
		child.h = CHILD_CROUCH_H -- 2419
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2420
			self:pickWell() -- 2421
			return -- 2422
		end -- 2422
		if not self.wellOpen and self:canPersistProgress() and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2425
			self.archive.museumPhase = "well_reflect" -- 2427
			self.archiveDirty = true -- 2428
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2429
			return -- 2430
		end -- 2430
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2432
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2434
		if near and input.interact.pressed then -- 2435
			self.phase = "prologue-give" -- 2436
			self.phaseTick = 0 -- 2437
			self:flashSet("递出针套", 1) -- 2438
		end -- 2438
		return -- 2440
	end -- 2440
	if self.phase == "prologue-well" then -- 2442
		self.phaseTick = self.phaseTick + 1 -- 2444
		if self.phaseTick == 12 then -- 2445
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2446
		elseif self.phaseTick >= 30 then -- 2447
			self.phase = "prologue-wait" -- 2448
			self.phaseTick = 0 -- 2449
			self.wellTaken = true -- 2450
			self.wellOpen = false -- 2451
			self.run.archive.artifactOwned = true -- 2452
			self.archiveDirty = true -- 2453
			self:emit("artifactFound", { -- 2454
				x = self.ox + self.wellX, -- 2455
				y = 0, -- 2455
				room = "prologue", -- 2455
				once = true, -- 2455
				source = self.run.source -- 2456
			}) -- 2456
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2458
			self:log("井底取到时间穿梭器") -- 2459
		end -- 2459
		return -- 2461
	end -- 2461
	if self.phase == "prologue-give" then -- 2463
		self.phaseTick = self.phaseTick + 1 -- 2464
		if self.phaseTick == 12 then -- 2465
			self:flashSet("针套递过去", 0.7) -- 2466
		elseif self.phaseTick == 36 then -- 2467
			self:flashSet("纸条塞进针套", 0.9) -- 2468
		elseif self.phaseTick >= 60 then -- 2469
			self.phase = "prologue-follow" -- 2470
			self.phaseTick = 0 -- 2471
			child.crouch = false -- 2472
			child.h = CHILD_H -- 2473
			self:flashSet("她跟上了", 1.2) -- 2474
		end -- 2474
		return -- 2476
	end -- 2476
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2479
		local next = self.run.source == "debug" and "street" or "s1-crossroad" -- 2480
		self:requestRoom(next, "序章跟到门口") -- 2481
		self:flashSet(next == "s1-crossroad" and "进十字街" or "进街道", 1.2) -- 2482
	end -- 2482
end -- 2329
function Play.prototype.stepStreet(self, dt, input) -- 2487
	local p = self.player -- 2488
	local c = self.partner -- 2489
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2490
		local next = self.run.source == "debug" and "checkpoint" or "s1-crossroad" -- 2491
		self:requestRoom(next, "两人都到街尾") -- 2492
		self:flashSet(next == "s1-crossroad" and "进十字街" or "到检查站", 1.2) -- 2493
	end -- 2493
end -- 2487
function Play.prototype.stepGate(self, dt, input) -- 2498
	local ____temp_41 -- 2499
	if self.room.story == nil then -- 2499
		____temp_41 = nil -- 2499
	else -- 2499
		____temp_41 = self.room.story.gate -- 2499
	end -- 2499
	local g = ____temp_41 -- 2499
	if g == nil then -- 2500
		return -- 2501
	end -- 2501
	local p = self.player -- 2503
	if self.phase == "gate-idle" then -- 2504
		local a = self.partner -- 2506
		local gap = g.waitX - a.x -- 2507
		if math.abs(gap) > 3 then -- 2508
			a.facing = gap > 0 and 1 or -1 -- 2509
			a.vx = a.facing * CHILD_SPEED -- 2510
			local beforeX = a.x -- 2511
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2512
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2513
				a.vy = CHILD_JUMP -- 2514
				a.onGround = false -- 2515
			end -- 2515
			self:fallY(a, dt) -- 2517
		else -- 2517
			a.vx = 0 -- 2519
			a.x = g.waitX -- 2520
		end -- 2520
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2523
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2524
		if self.gateNeedConfirm then -- 2525
			if not input.interact.held then -- 2528
				self.gateRestartArmed = true -- 2529
			end -- 2529
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2531
				self.gateNeedConfirm = false -- 2532
				self.gateRestartArmed = true -- 2533
				self.phase = "gate-hold" -- 2534
				self.gateTick = 0 -- 2535
				self.gateSpawned = 0 -- 2536
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2537
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2538
			end -- 2538
			return -- 2540
		end -- 2540
		if atWinch and atWait then -- 2542
			self.phase = "gate-hold" -- 2543
			self.gateTick = 0 -- 2544
			self.gateSpawned = 0 -- 2545
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2546
		end -- 2546
		return -- 2548
	end -- 2548
	if self.phase == "gate-hold" then -- 2550
		self.gateTick = self.gateTick + 1 -- 2551
		local marks = {0, 540, 900, 1500} -- 2553
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2554
			local idx = self.gateSpawned -- 2555
			local ____self_enemies_42 = self.enemies -- 2556
			____self_enemies_42[#____self_enemies_42 + 1] = { -- 2556
				x = self.ox + 620 + idx * 62, -- 2557
				y = 0, -- 2557
				w = 26, -- 2557
				h = 84, -- 2557
				alive = true, -- 2558
				hitT = 0, -- 2558
				warnT = 0, -- 2558
				fireCd = 90 + idx * 45 -- 2558
			} -- 2558
			self.gateSpawned = self.gateSpawned + 1 -- 2560
			self:flashSet( -- 2561
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2561
				0.9 -- 2561
			) -- 2561
		end -- 2561
		if self.gateTick == 900 then -- 2563
			self:flashSet("棚布落下", 1) -- 2564
		elseif self.gateTick == 2100 then -- 2565
			self:flashSet("门底透进冷光了", 1) -- 2566
		end -- 2566
		if self.gateTick >= g.holdTicks then -- 2568
			self:captureGateBlood() -- 2571
			self.phase = "gate-send" -- 2572
			self.phaseTick = 0 -- 2573
			self.enemies = {} -- 2575
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2576
		end -- 2576
		return -- 2578
	end -- 2578
	if self.phase == "gate-send" then -- 2580
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2581
		if near and input.interact.pressed then -- 2582
			self:commitRoute() -- 2584
			self:swapToChild(g.doorX + 30) -- 2585
			self.phase = "gate-count" -- 2586
			self.countTick = 0 -- 2587
			self.countArmed = false -- 2589
			self.countPrevMove = input.moveX -- 2590
			self:flashSet("门开了 · 送她出去", 1.8) -- 2591
		end -- 2591
		return -- 2593
	end -- 2593
	if self.phase == "gate-count" then -- 2595
		self.countTick = self.countTick + 1 -- 2596
		if self.countTick == 360 then -- 2597
			self:flashSet("门关上", 0.9) -- 2598
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2599
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2600
			if self.storyRoute == "soldier" then -- 2604
				self.phase = "gate-wait" -- 2606
				self.phaseTick = 0 -- 2607
				self.knocks = 1 -- 2608
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2609
				self.handArmed = not input.interact.held and not self.intentGateReunionHold -- 2611
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2612
			else -- 2612
				self:flashSet("数到二十", 2.2) -- 2614
			end -- 2614
		end -- 2614
		local prevMove = self.countPrevMove -- 2619
		self.countPrevMove = input.moveX -- 2620
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2621
			if prevMove <= 0 and input.moveX > 0 then -- 2622
				self.countArmed = true -- 2623
			end -- 2623
			if self.countArmed and input.moveX > 0 then -- 2625
				self.phase = "gate-walk" -- 2626
				self.phaseTick = 0 -- 2627
				self:flashSet("她迈出第一步", 1.4) -- 2628
				self:emit("storyExit", { -- 2629
					route = "child", -- 2629
					via = "walk", -- 2629
					countTick = self.countTick, -- 2629
					hp = self.hp, -- 2629
					maxHp = self.maxHp -- 2629
				}) -- 2629
			end -- 2629
		end -- 2629
		return -- 2632
	end -- 2632
	if self.phase == "gate-wait" then -- 2634
		self.phaseTick = self.phaseTick + 1 -- 2636
		if self.phaseTick == 12 then -- 2637
			self.knocks = 2 -- 2638
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2639
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2640
		end -- 2640
		local held = input.interact.held or self.intentGateReunionHold -- 2642
		if not held then -- 2643
			if self.handTicks > 0 then -- 2644
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2645
			end -- 2645
			self.handTicks = 0 -- 2647
			self.handArmed = true -- 2648
			return -- 2649
		end -- 2649
		if self.handArmed then -- 2651
			self.handTicks = self.handTicks + 1 -- 2652
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2653
				self.intentGateReunionHold = false -- 2654
				self.phase = "gate-hand" -- 2655
				self.phaseTick = 0 -- 2656
				self.handDone = true -- 2657
				self.tied = true -- 2658
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2659
				if not self.lineSaid then -- 2660
					self.lineSaid = true -- 2661
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2662
				end -- 2662
				self:flashSet("我们走吧。", 3) -- 2664
			end -- 2664
		end -- 2664
		return -- 2667
	end -- 2667
	if self.phase == "gate-hand" then -- 2669
		self.phaseTick = self.phaseTick + 1 -- 2671
		if self.phaseTick == 30 then -- 2672
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2673
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2674
			self:emit("storyExit", { -- 2675
				route = "soldier", -- 2675
				via = "hand", -- 2675
				handTicks = self.handTicks, -- 2675
				hp = self.hp, -- 2675
				maxHp = self.maxHp -- 2675
			}) -- 2675
			self:requestRoom("gatepath", "牵手同行") -- 2676
		end -- 2676
		return -- 2678
	end -- 2678
	if self.phase == "gate-walk" then -- 2681
		if self.player.x >= g.exitX then -- 2682
			self:requestRoom("outside", "走出城门") -- 2683
			self:flashSet("出城门 · 城外", 1.4) -- 2684
		end -- 2684
	end -- 2684
end -- 2498
function Play.prototype.captureGateBlood(self) -- 2693
	self.hpAtGate = self.hp -- 2694
	self.maxHpAtGate = self.maxHp -- 2695
end -- 2693
function Play.prototype.commitRoute(self) -- 2702
	if self.storySettled then -- 2703
		return -- 2704
	end -- 2704
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2706
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2707
	self.hpAtGate = hp -- 2708
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2709
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2710
	self.storySettled = true -- 2711
	self.sessionDirty = true -- 2712
	self:emit("storyRouteLocked", { -- 2713
		route = self.storyRoute, -- 2714
		hp = self.hp, -- 2714
		maxHp = self.maxHp, -- 2714
		hpAtGate = self.hpAtGate, -- 2715
		maxHpAtGate = self.maxHpAtGate -- 2715
	}) -- 2715
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2717
end -- 2702
function Play.prototype.syncStory(self) -- 2721
	if self.isCampaign and self.run.trial ~= nil then -- 2722
		return -- 2723
	end -- 2723
	local s = self.run.story -- 2725
	if s == nil then -- 2726
		return -- 2727
	end -- 2727
	s.hp = self.hp -- 2729
	s.maxHp = self.maxHp -- 2730
	s.route = self.storyRoute -- 2731
	s.settled = self.storySettled -- 2732
	s.hpAtGate = self.hpAtGate -- 2733
	s.maxHpAtGate = self.maxHpAtGate -- 2734
	s.handDone = self.handDone -- 2735
	s.lineSaid = self.lineSaid -- 2736
	s.tied = self.tied -- 2737
	s.carry = self.carryOn -- 2738
	s.museumReturn = self.museumReturn -- 2739
	s.escortDone = self.escortDone -- 2740
	s.craftedWeapon = self.run.story.craftedWeapon -- 2741
	s.equippedWeapon = self.equippedWeapon -- 2742
	s.ending = self.run.story.ending -- 2743
	if self.room.key == "gate" then -- 2744
		s.phase = self.phase -- 2745
		s.countTick = self.countTick -- 2746
		s.phaseTick = self.phaseTick -- 2747
		s.handTicks = self.handTicks -- 2748
	end -- 2748
	if self.room.key == "prologue" then -- 2750
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2752
			s.phase = self.phase -- 2753
			s.phaseTick = self.phaseTick -- 2754
		end -- 2754
	end -- 2754
	if self.room.key == "tower" then -- 2757
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2759
			s.phase = self.phase -- 2760
			s.phaseTick = self.phaseTick -- 2761
		end -- 2761
	end -- 2761
end -- 2721
function Play.prototype.stepGatePath(self) -- 2767
	local ____temp_43 -- 2768
	if self.room.story == nil then -- 2768
		____temp_43 = nil -- 2768
	else -- 2768
		____temp_43 = self.room.story.gatepath -- 2768
	end -- 2768
	local gp = ____temp_43 -- 2768
	if self.phase == "gatepath-start" then -- 2769
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2770
			self.carryOn = true -- 2771
			self.phase = "gatepath-carry" -- 2772
			self.phaseTick = 0 -- 2773
			self.pathDone = true -- 2774
			self.escortDone = false -- 2775
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2776
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2777
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2778
		end -- 2778
		return -- 2780
	end -- 2780
	if self.phase == "gatepath-carry" then -- 2782
		self.phaseTick = self.phaseTick + 1 -- 2783
		if self.phaseTick == 20 then -- 2784
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2785
		end -- 2785
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2787
			self:requestRoom(gp.next, "背负进首战") -- 2788
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2789
		end -- 2789
	end -- 2789
end -- 2767
function Play.prototype.carryPose(self) -- 2798
	local p = self.player -- 2799
	local a = self.partner -- 2800
	a.alive = true -- 2801
	a.x = p.x - p.facing * 12 -- 2802
	a.y = p.y + 26 -- 2803
	a.depth = p.depth -- 2804
	a.vx = p.vx -- 2805
	a.vy = 0 -- 2806
	a.onGround = true -- 2807
	a.crouch = false -- 2808
	a.h = CHILD_CROUCH_H -- 2809
	a.facing = p.facing -- 2810
end -- 2798
function Play.prototype.stepMuseum(self, dt, input) -- 2818
	self.partner.alive = false -- 2819
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2820
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2823
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 2824
	local intentTarget = self.pendingMuseumIntentTarget -- 2825
	self.pendingMuseumIntentTarget = "" -- 2826
	local interactHit = input.interact.pressed or intentTarget ~= "" -- 2827
	if self.phase == "museum-cabinet" then -- 2828
		if atCase and interactHit or intentTarget == "cabinet" then -- 2829
			self.phase = "museum-hall" -- 2830
			self.phaseTick = 0 -- 2831
			if self:canPersistProgress() then -- 2832
				self.archive.museumPhase = "hall_walk" -- 2833
				self.archiveDirty = true -- 2834
			end -- 2834
			self:emit( -- 2836
				"museumStep", -- 2836
				{ -- 2836
					step = "cabinet", -- 2836
					x = self.ox + mu.cabinetX, -- 2836
					persisted = self:canPersistProgress() -- 2836
				} -- 2836
			) -- 2836
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2837
		end -- 2837
		return -- 2839
	end -- 2839
	if self.phase == "museum-hall" then -- 2841
		if intentTarget == "lamp_direct" and nearLamp then -- 2842
			self:emit( -- 2843
				"museumStep", -- 2843
				{ -- 2843
					step = "hall", -- 2843
					x = self.ox + mu.hallX, -- 2843
					persisted = self:canPersistProgress() -- 2843
				} -- 2843
			) -- 2843
			self.phase = "museum-return" -- 2844
			self.phaseTick = 0 -- 2845
			if self:canPersistProgress() then -- 2846
				self.archive.museumPhase = "return_cabinet" -- 2847
				self.archiveDirty = true -- 2848
			end -- 2848
			self:emit( -- 2850
				"museumStep", -- 2850
				{ -- 2850
					step = "lamp", -- 2850
					x = self.ox + mu.lampX, -- 2850
					persisted = self:canPersistProgress() -- 2850
				} -- 2850
			) -- 2850
			self:flashSet("灯 · 转向西窗", 1.8) -- 2851
			return -- 2852
		end -- 2852
		if self.player.x >= self.ox + mu.hallX and interactHit then -- 2854
			self.phase = "museum-lamp" -- 2855
			self.phaseTick = 0 -- 2856
			if self:canPersistProgress() then -- 2857
				self.archive.museumPhase = "lamp_turn" -- 2858
				self.archiveDirty = true -- 2859
			end -- 2859
			self:emit( -- 2861
				"museumStep", -- 2861
				{ -- 2861
					step = "hall", -- 2861
					x = self.ox + mu.hallX, -- 2861
					persisted = self:canPersistProgress() -- 2861
				} -- 2861
			) -- 2861
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2862
		end -- 2862
		return -- 2864
	end -- 2864
	if self.phase == "museum-lamp" then -- 2866
		if nearLamp and interactHit then -- 2867
			self.phase = "museum-return" -- 2868
			self.phaseTick = 0 -- 2869
			if self:canPersistProgress() then -- 2870
				self.archive.museumPhase = "return_cabinet" -- 2871
				self.archiveDirty = true -- 2872
			end -- 2872
			self:emit( -- 2874
				"museumStep", -- 2874
				{ -- 2874
					step = "lamp", -- 2874
					x = self.ox + mu.lampX, -- 2874
					persisted = self:canPersistProgress() -- 2874
				} -- 2874
			) -- 2874
			self:flashSet("灯 · 转向西窗", 1.8) -- 2875
		end -- 2875
		return -- 2877
	end -- 2877
	if self.phase == "museum-return" then -- 2879
		if atCase and interactHit or intentTarget == "return_cabinet" then -- 2880
			self.phase = "museum-knock" -- 2881
			self.phaseTick = 0 -- 2882
			self:emit( -- 2883
				"museumStep", -- 2883
				{ -- 2883
					step = "knock", -- 2883
					count = 1, -- 2883
					x = self.ox + mu.cabinetX, -- 2883
					persisted = self:canPersistProgress() -- 2883
				} -- 2883
			) -- 2883
			self:flashSet("回柜边 · 第一下", 0.8) -- 2884
		end -- 2884
		return -- 2886
	end -- 2886
	if self.phase == "museum-knock" then -- 2888
		self.phaseTick = self.phaseTick + 1 -- 2889
		if self.phaseTick == 8 then -- 2890
			self:emit( -- 2891
				"museumStep", -- 2891
				{ -- 2891
					step = "knock", -- 2891
					count = 2, -- 2891
					x = self.ox + mu.cabinetX, -- 2891
					persisted = self:canPersistProgress() -- 2891
				} -- 2891
			) -- 2891
			self:flashSet("回柜边 · 第二下", 0.8) -- 2892
		elseif self.phaseTick >= 36 then -- 2893
			self.phase = "museum-done" -- 2894
			self.phaseTick = 0 -- 2895
			if self:canPersistProgress() then -- 2896
				self.archive.museumSeen = true -- 2897
				self.archive.museumPhase = "done" -- 2898
				self.archiveDirty = true -- 2899
			end -- 2899
			self:emit( -- 2901
				"museumDone", -- 2901
				{ -- 2901
					steps = 4, -- 2901
					museumSeen = self.archive.museumSeen, -- 2901
					persisted = self:canPersistProgress() -- 2901
				} -- 2901
			) -- 2901
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2902
			self:log("博物馆 · 回柜边") -- 2903
		end -- 2903
		return -- 2905
	end -- 2905
	if interactHit then -- 2907
		self.museumReturn = true -- 2908
		self:requestRoom("prologue", "回柜边") -- 2909
	end -- 2909
end -- 2818
function Play.prototype.openTowerDoor(self) -- 2913
	self.towerDoorOpen = true -- 2914
	do -- 2914
		local i = 0 -- 2915
		while i < #self.boxes do -- 2915
			if self.boxes[i + 1].id == "tower_door" then -- 2916
				self.boxes[i + 1].hidden = true -- 2917
			end -- 2917
			i = i + 1 -- 2915
		end -- 2915
	end -- 2915
	self.run.story.segments.tower_door = true -- 2920
end -- 2913
function Play.prototype.stepTower(self, dt, input) -- 2923
	local ____temp_44 -- 2924
	if self.room.story == nil then -- 2924
		____temp_44 = nil -- 2924
	else -- 2924
		____temp_44 = self.room.story.tower -- 2924
	end -- 2924
	local t = ____temp_44 -- 2924
	if t == nil then -- 2925
		return -- 2926
	end -- 2926
	if self.storyRoute == "soldier" and self.partner.alive then -- 2929
		local targetX = math.max(self.ox + 408, self.player.x - 28) -- 2930
		local gap = targetX - self.partner.x -- 2931
		if math.abs(gap) > 2 then -- 2932
			local dir = gap > 0 and 1 or -1 -- 2933
			local stepDist = math.min( -- 2934
				math.abs(gap), -- 2934
				SOLDIER_SPEED * dt -- 2934
			) -- 2934
			self.partner.facing = dir -- 2935
			self.partner.vx = dir * SOLDIER_SPEED -- 2936
			local ____self_partner_45, ____x_46 = self.partner, "x" -- 2937
			____self_partner_45[____x_46] = ____self_partner_45[____x_46] + dir * stepDist -- 2937
		else -- 2937
			self.partner.vx = 0 -- 2939
			self.partner.facing = 1 -- 2940
		end -- 2940
	end -- 2940
	if self.phase == "tower-wait" then -- 2943
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2944
		if near and input.interact.pressed then -- 2945
			self.phase = "tower-knock" -- 2946
			self.phaseTick = 0 -- 2947
			self.knocks = 1 -- 2948
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2949
			self:flashSet("叩两下 · 第一声", 0.6) -- 2950
		end -- 2950
		return -- 2952
	end -- 2952
	if self.phase == "tower-knock" then -- 2954
		self.phaseTick = self.phaseTick + 1 -- 2955
		if self.phaseTick == 12 then -- 2956
			self.knocks = 2 -- 2957
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2958
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 2959
		elseif self.phaseTick >= t.knockTicks then -- 2960
			self:openTowerDoor() -- 2961
			self.phase = "tower-enter" -- 2962
			self.phaseTick = 0 -- 2963
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 2964
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 2965
		end -- 2965
		return -- 2967
	end -- 2967
	if self.phase == "tower-enter" then -- 2969
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 2970
			self.phase = "tower-desk" -- 2971
			self.phaseTick = 0 -- 2972
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 2973
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 2974
		end -- 2974
		return -- 2976
	end -- 2976
	if self.phase == "tower-desk" then -- 2978
		local deskX = self.ox + 605 -- 2979
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 2980
		if not near or not input.interact.held then -- 2981
			self.deskHold = 0 -- 2982
			return -- 2983
		end -- 2983
		self.deskHold = self.deskHold + 1 -- 2985
		if self.deskHold == 12 then -- 2986
			self:flashSet("针套 · 放在桌上", 1) -- 2987
		elseif self.deskHold == 24 then -- 2988
			self:flashSet("指南针 · 压住纸条", 1) -- 2989
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 2990
			self.towerHanded = true -- 2991
			self.deskHold = 0 -- 2992
			self.run.story.segments.tower_handover = true -- 2993
			self.phase = "tower-given" -- 2994
			self.phaseTick = 0 -- 2995
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 2996
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 3001
		end -- 3001
		return -- 3003
	end -- 3003
	if self.phase == "tower-given" then -- 3005
		local soldier = self.storyRoute == "soldier" -- 3008
		self.phaseTick = self.phaseTick + 1 -- 3009
		if self.phaseTick == 60 then -- 3010
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 3011
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 3012
		elseif self.phaseTick == 120 then -- 3013
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 3014
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 3015
			self.phase = "tower-end" -- 3016
			self.phaseTick = 0 -- 3017
			self.towerEndMustRelease = input.interact.held or input.retry.held -- 3018
			if not self.run.finished then -- 3019
				self.run.finished = true -- 3020
				local ending = soldier and "reunion" or "lamp" -- 3021
				self.run.story.ending = ending -- 3022
				local ____soldier_47 -- 3025
				if soldier then -- 3025
					____soldier_47 = self.run.story.segments.escort5 == true -- 3026
				else -- 3026
					____soldier_47 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 3027
				end -- 3027
				local played = ____soldier_47 -- 3025
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 3028
				if official then -- 3030
					if soldier then -- 3031
						self.run.archive.soldierCleared = true -- 3032
					else -- 3032
						self.run.archive.childCleared = true -- 3034
					end -- 3034
					self.archiveDirty = true -- 3036
				end -- 3036
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 3038
				self:emit("endingReached", { -- 3039
					route = soldier and "soldier" or "child", -- 3040
					ending = ending, -- 3041
					official = official, -- 3042
					source = self.run.source, -- 3043
					lines = {self.endingLines[1], self.endingLines[2]}, -- 3044
					childCleared = self.run.archive.childCleared, -- 3045
					soldierCleared = self.run.archive.soldierCleared, -- 3046
					artifactOwned = self.run.archive.artifactOwned, -- 3047
					equipped = self.equippedWeapon -- 3048
				}) -- 3048
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 3050
			end -- 3050
		end -- 3050
		return -- 3053
	end -- 3053
	self.phaseTick = self.phaseTick + 1 -- 3055
	local held = input.interact.held or input.retry.held -- 3056
	if self.towerEndMustRelease then -- 3057
		if not held then -- 3058
			self.towerEndMustRelease = false -- 3059
		end -- 3059
		return -- 3061
	end -- 3061
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 3063
	if self.phaseTick < waitTicks then -- 3064
		if input.interact.pressed or input.retry.pressed then -- 3065
			self.towerEndMustRelease = held -- 3066
		end -- 3066
		return -- 3068
	end -- 3068
	if input.interact.pressed or input.retry.pressed then -- 3070
		self.restartStory = true -- 3072
		self:requestRoom("prologue", "片尾再玩") -- 3073
		self:flashSet("回到序章", 1.4) -- 3074
	end -- 3074
end -- 2923
function Play.prototype.stepChase(self, dt, input) -- 3079
	if self.caughtT > 0 then -- 3080
		self.caughtT = self.caughtT - dt -- 3081
		if self.caughtT <= 0 then -- 3082
			self:recoverFromCaught() -- 3083
		end -- 3083
		return -- 3085
	end -- 3085
	if self.room.key == "village" then -- 3087
		self:stepScavChase() -- 3088
	elseif self.room.key == "forest" then -- 3089
		self:stepForestRoute() -- 3090
		self:stepDog(dt) -- 3091
		if self.player.x >= self.ox + 1450 then -- 3093
			self:requestRoom("tower", "到林缘北塔") -- 3094
			self:flashSet("林缘 · 北塔", 1.4) -- 3095
		end -- 3095
	end -- 3095
end -- 3079
function Play.prototype.stepScavChase(self) -- 3101
	local s = self.room.scavenger -- 3102
	if s == nil then -- 3103
		return -- 3104
	end -- 3104
	local p = self.player -- 3106
	if self.passed and p.x > self.ox + 440 then -- 3108
		if self.scavChase then -- 3109
			self.scavChase = false -- 3110
			self.scavState = "back" -- 3111
			self.scavT = 0 -- 3112
		end -- 3112
		return -- 3114
	end -- 3114
	local dx = p.x - self.scavX -- 3116
	local dist = math.abs(dx) -- 3117
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 3118
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 3119
	if not self.scavChase then -- 3120
		if visible then -- 3121
			self.scavSee = self.scavSee + 1 -- 3122
			if self.scavSee >= 24 then -- 3123
				self.scavChase = true -- 3124
				self.scavState = "chase" -- 3125
				self.scavTargetX = p.x -- 3126
				self:flashSet("他看见你了", 1.2) -- 3127
			end -- 3127
		else -- 3127
			self.scavSee = 0 -- 3130
		end -- 3130
		return -- 3132
	end -- 3132
	if hidden then -- 3135
		self.scavSee = 0 -- 3136
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 3137
		self.scavT = self.scavT - 1 -- 3138
		if self.scavT <= 0 then -- 3139
			self.scavChase = false -- 3140
			self.scavState = "patrol" -- 3141
			self:flashSet("他失去了目标", 1) -- 3142
		end -- 3142
		return -- 3144
	end -- 3144
	local dir = p.x > self.scavX and 1 or -1 -- 3147
	self.scavX = self.scavX + dir * 96 / 60 -- 3148
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 3149
		self:caught() -- 3150
		return -- 3151
	end -- 3151
end -- 3101
function Play.prototype.stepDog(self, dt) -- 3156
	local ____temp_48 -- 3157
	if self.room.story == nil then -- 3157
		____temp_48 = nil -- 3157
	else -- 3157
		____temp_48 = self.room.story.dog -- 3157
	end -- 3157
	local dog = ____temp_48 -- 3157
	if dog == nil then -- 3158
		return -- 3159
	end -- 3159
	local p = self.player -- 3161
	local ox = self.ox -- 3162
	local dist = math.abs(p.x - self.dogX) -- 3163
	local inBurrowCover = p.crouch and p.x >= ox + 300 and p.x <= ox + 460 -- 3164
	local inBrushCover = p.crouch and (p.x >= ox + 700 and p.x <= ox + 790 or p.x >= ox + 1150 and p.x <= ox + 1240) -- 3165
	local sheltered = inBurrowCover or inBrushCover -- 3169
	local inDitchSprint = not p.crouch and self.forestPath == "ditch" and p.x >= ox + 700 and p.x <= ox + 1140 -- 3170
	local effectiveRange = inDitchSprint and dog.range * 1.25 or dog.range -- 3171
	local earNeedTicks = inDitchSprint and 12 or 18 -- 3172
	if self.dogState == "patrol" then -- 3173
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 3174
		if self.dogX < dog.x0 then -- 3175
			self.dogX = dog.x0 -- 3176
			self.dogDir = 1 -- 3177
		elseif self.dogX > dog.x1 then -- 3178
			self.dogX = dog.x1 -- 3179
			self.dogDir = -1 -- 3180
		end -- 3180
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 3182
		local twigOffsets = {235, 455, 865, 1115} -- 3183
		local nearTwig = false -- 3184
		local ti = 0 -- 3185
		do -- 3185
			ti = 0 -- 3186
			while ti < #twigOffsets do -- 3186
				if math.abs(p.x - (ox + twigOffsets[ti + 1])) <= 18 and p.y <= 8 then -- 3187
					nearTwig = true -- 3188
					break -- 3189
				end -- 3189
				ti = ti + 1 -- 3186
			end -- 3186
		end -- 3186
		local twigRange = nearTwig and math.max(effectiveRange, 400) or effectiveRange -- 3192
		if not sheltered and not p.crouch and moving and dist < twigRange then -- 3193
			self.dogState = "ear" -- 3194
			self.dogT = nearTwig and math.min(earNeedTicks, 12) or earNeedTicks -- 3195
			self.dogTargetX = p.x -- 3196
			self:flashSet(inDitchSprint and "旧渠枯枝响 · 狗立刻转耳" or (nearTwig and "踩断枯枝 · 狗立刻转耳" or "狗转耳朵"), 0.8) -- 3197
		end -- 3197
		return -- 3199
	end -- 3199
	if self.dogState == "ear" then -- 3201
		if sheltered then -- 3202
			self.dogState = "sniff" -- 3203
			self.dogT = 45 -- 3204
			self:flashSet("钻进遮蔽 · 狗顿住了", 0.9) -- 3205
			return -- 3206
		end -- 3206
		self.dogT = self.dogT - 1 -- 3208
		if self.dogT <= 0 then -- 3209
			self.dogState = "chase" -- 3210
			self.dogTargetX = p.x -- 3211
			self:flashSet("狗追来了", 1.4) -- 3212
		end -- 3212
		return -- 3214
	end -- 3214
	if self.dogState == "chase" then -- 3216
		local dir = p.x > self.dogX and 1 or -1 -- 3217
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 3218
		if not sheltered and math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 3219
			self:caught() -- 3220
			self.dogState = "sniff" -- 3221
			self.dogT = 60 -- 3222
		elseif dist > effectiveRange * 1.5 or sheltered then -- 3223
			self.dogState = "sniff" -- 3224
			self.dogT = 60 -- 3225
			self:flashSet(inBurrowCover and "树根窄洞遮住身形 · 狗停下了" or "狗停下了", 0.9) -- 3226
		end -- 3226
		return -- 3228
	end -- 3228
	if self.dogState == "sniff" then -- 3230
		self.dogT = self.dogT - 1 -- 3231
		if self.dogT <= 0 then -- 3232
			self.dogState = "back" -- 3233
		end -- 3233
		return -- 3235
	end -- 3235
	local dir = dog.x0 > self.dogX and 1 or -1 -- 3238
	self.dogX = self.dogX + dir * dog.speed * dt -- 3239
	if math.abs(self.dogX - dog.x0) < 2 then -- 3240
		self.dogX = dog.x0 -- 3241
		self.dogState = "patrol" -- 3242
	end -- 3242
end -- 3156
function Play.prototype.stepForestRoute(self) -- 3247
	local p = self.player -- 3248
	local ox = self.ox -- 3249
	if self.forestPath == "" then -- 3250
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 3251
			self.forestPath = "burrow" -- 3252
			self.run.story.segments.forest_burrow = true -- 3253
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 3254
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 3255
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 3256
			self.forestPath = "ditch" -- 3257
			self.run.story.segments.forest_ditch = true -- 3258
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 3259
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 3260
		end -- 3260
	end -- 3260
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 3263
		self.waterSeen = true -- 3264
		self.run.story.segments.water_lantern = true -- 3265
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 3266
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 3267
	end -- 3267
end -- 3247
function Play.prototype.caught(self) -- 3271
	self.caughtT = 1 -- 3272
	self:flashSet("被抓 · 回到安全点", 1.6) -- 3273
end -- 3271
function Play.prototype.recoverFromCaught(self) -- 3277
	local p = self.player -- 3278
	p.x = self.ox + 140 -- 3279
	p.y = 0 -- 3280
	p.vy = 0 -- 3281
	p.vx = 0 -- 3282
	p.onGround = true -- 3283
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3284
		self.scavX = self.room.scavenger.x0 -- 3285
		self.scavState = "patrol" -- 3286
		self.scavSee = 0 -- 3287
		self.scavChase = false -- 3288
		self.scavT = 0 -- 3289
	end -- 3289
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3291
		self.dogX = self.room.story.dog.x0 -- 3292
		self.dogState = "patrol" -- 3293
		self.dogT = 0 -- 3294
	end -- 3294
	self.cam.x = p.x -- 3296
	self.cam.y = p.y + CAM_LOOK_UP -- 3297
	self:flashSet("回到安全点", 1.2) -- 3298
end -- 3277
function Play.prototype.updateGate(self) -- 3302
	if self.room.key ~= "checkpoint" then -- 3303
		self.gateOpen = false -- 3304
		return -- 3305
	end -- 3305
	local function inZone(x) -- 3307
		return x >= self.ox + 792 and x <= self.ox + 928 -- 3307
	end -- 3307
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 3308
end -- 3302
function Play.prototype.addItem(self, kind) -- 3314
	local inv = self.run.inventory -- 3315
	if kind == "shield" then -- 3316
		if inv.shield >= TOOL_CAP then -- 3317
			return false -- 3318
		end -- 3318
		inv.shield = inv.shield + 1 -- 3320
		return true -- 3321
	end -- 3321
	if kind == "wedge" then -- 3323
		if inv.wedge >= CONSUMABLE_CAP then -- 3324
			return false -- 3325
		end -- 3325
		inv.wedge = inv.wedge + 1 -- 3327
		return true -- 3328
	end -- 3328
	if kind == "ammo" then -- 3330
		if inv.ammo >= CONSUMABLE_CAP then -- 3331
			return false -- 3332
		end -- 3332
		inv.ammo = inv.ammo + 1 -- 3334
		return true -- 3335
	end -- 3335
	if kind == "scrap" then -- 3337
		inv.scrap = inv.scrap + 1 -- 3339
		return true -- 3340
	end -- 3340
	if kind == "wood" then -- 3342
		inv.wood = inv.wood + 1 -- 3343
		return true -- 3344
	end -- 3344
	if kind == "bell" then -- 3346
		inv.bell = inv.bell + 1 -- 3347
		return true -- 3348
	end -- 3348
	if kind == "pass" then -- 3350
		inv.pass = inv.pass + 1 -- 3351
		return true -- 3352
	end -- 3352
	if kind == "quickbelt" then -- 3354
		inv.quickbelt = inv.quickbelt + 1 -- 3355
		return true -- 3356
	end -- 3356
	return false -- 3358
end -- 3314
function Play.prototype.findBox(self, id) -- 3361
	local i = 0 -- 3362
	do -- 3362
		i = 0 -- 3363
		while i < #self.boxes do -- 3363
			if self.boxes[i + 1].id == id then -- 3364
				return self.boxes[i + 1] -- 3365
			end -- 3365
			i = i + 1 -- 3363
		end -- 3363
	end -- 3363
	return nil -- 3368
end -- 3361
function Play.prototype.findWedgeTarget(self) -- 3372
	local best = nil -- 3373
	local bestD = 0 -- 3374
	local i = 0 -- 3375
	do -- 3375
		i = 0 -- 3376
		while i < #self.boxes do -- 3376
			do -- 3376
				local b = self.boxes[i + 1] -- 3377
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3378
					goto __continue511 -- 3379
				end -- 3379
				if not self:nearBox(b, 26) then -- 3381
					goto __continue511 -- 3382
				end -- 3382
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3384
				if best == nil or d < bestD then -- 3385
					best = b -- 3386
					bestD = d -- 3387
				end -- 3387
			end -- 3387
			::__continue511:: -- 3387
			i = i + 1 -- 3376
		end -- 3376
	end -- 3376
	return best -- 3390
end -- 3372
function Play.prototype.stepCraft(self, input) -- 3398
	local inv = self.run.inventory -- 3399
	local required = math.max( -- 3400
		6, -- 3400
		CRAFT_TICKS - 6 * self:talentRank("craft") -- 3400
	) -- 3400
	if self.craftT > 0 then -- 3401
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3402
			self.craftT = 0 -- 3404
			self:flashSet("制作中断", 0.8) -- 3405
			return true -- 3406
		end -- 3406
		self.craftT = self.craftT + 1 -- 3408
		if self.craftT >= required then -- 3409
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3410
				inv.scrap = inv.scrap - 1 -- 3411
				inv.wedge = inv.wedge + 1 -- 3412
				self:flashSet("制得木楔", 1.2) -- 3413
				self:log("制木楔") -- 3414
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3415
			end -- 3415
			self.craftT = 0 -- 3417
		end -- 3417
		return true -- 3419
	end -- 3419
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3421
		self.craftT = 1 -- 3422
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3423
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3424
		return true -- 3425
	end -- 3425
	return false -- 3427
end -- 3398
function Play.prototype.nearBox(self, b, reach) -- 3430
	local p = self.player -- 3431
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3432
end -- 3430
function Play.prototype.findInteract(self) -- 3438
	local p = self.player -- 3439
	local best = nil -- 3440
	local bestD = 1000000000 -- 3441
	local i = 0 -- 3442
	do -- 3442
		i = 0 -- 3443
		while i < #self.boxes do -- 3443
			do -- 3443
				local b = self.boxes[i + 1] -- 3444
				if b.interact == nil or b.broken == true then -- 3445
					goto __continue524 -- 3446
				end -- 3446
				if not self:nearBox(b, b.interact.reach or 27) then -- 3448
					goto __continue524 -- 3449
				end -- 3449
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3451
				if d < bestD then -- 3452
					bestD = d -- 3453
					best = b -- 3454
				end -- 3454
			end -- 3454
			::__continue524:: -- 3454
			i = i + 1 -- 3443
		end -- 3443
	end -- 3443
	return best -- 3457
end -- 3438
function Play.prototype.stepCampaign(self, dt, input) -- 3461
	local wr = self.room -- 3462
	local p = self.player -- 3463
	if self.reloadT > 0 then -- 3464
		self.reloadT = self.reloadT - 1 -- 3465
	end -- 3465
	if self.bracedShield ~= nil then -- 3468
		self.bracedShield.x = p.x + p.facing * 26 -- 3469
		self.bracedShield.y = p.y -- 3470
		local shBox = __TS__ArrayFind( -- 3471
			self.boxes, -- 3471
			function(____, b) return b.id == "braced_shield" end -- 3471
		) -- 3471
		if shBox ~= nil then -- 3472
			shBox.x0 = self.bracedShield.x - 15 -- 3473
			shBox.x1 = self.bracedShield.x + 15 -- 3474
			shBox.y0 = self.bracedShield.y -- 3475
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3476
		end -- 3476
	end -- 3476
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3480
		self.run.route = "drygoods" -- 3482
		self.run.joined = false -- 3483
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3484
		self:log("转布行线") -- 3485
	end -- 3485
	if wr.key == "escort3" then -- 3488
		local nearBench = p.x >= wr.minX + 472 and p.x <= wr.minX + 710 and p.y < 60 -- 3489
		if nearBench and input.interact.pressed then -- 3490
			self:openCraftBench() -- 3491
			return -- 3492
		end -- 3492
	end -- 3492
	local i = 0 -- 3496
	do -- 3496
		i = 0 -- 3497
		while i < #self.pickups do -- 3497
			do -- 3497
				local pk = self.pickups[i + 1] -- 3498
				if self.run.taken[pk.id] == true then -- 3499
					goto __continue537 -- 3500
				end -- 3500
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3502
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3503
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3504
					if not self:addItem(pk.kind) then -- 3505
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3507
						self:log("满包拒绝 " .. pk.kind) -- 3508
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3509
						goto __continue537 -- 3510
					end -- 3510
					self.run.taken[pk.id] = true -- 3512
					self:flashSet("拾取 " .. pk.label, 1) -- 3513
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3514
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3515
				end -- 3515
			end -- 3515
			::__continue537:: -- 3515
			i = i + 1 -- 3497
		end -- 3497
	end -- 3497
	self.calmConsumed = false -- 3519
	local ____temp_54 = self.run.trial == nil and self.partner.alive and self.run.joined -- 3520
	if ____temp_54 then -- 3520
		local ____opt_49 = self.room.campaign -- 3521
		local ____temp_53 = (____opt_49 and ____opt_49.chapter) == "S" -- 3521
		if not ____temp_53 then -- 3521
			local ____opt_51 = self.room.campaign -- 3521
			____temp_53 = (____opt_51 and ____opt_51.chapter) == "C" -- 3521
		end -- 3521
		____temp_54 = ____temp_53 -- 3520
	end -- 3520
	if ____temp_54 and (self.escort.fear > 0 or self.escort.state == "frozen" or self.escort.state == "calming") then -- 3520
		local dist = inReachDepth(p.depth, self.partner.depth) and math.abs(p.x - self.partner.x) or 1000000000 -- 3523
		local hadK1 = self.escort.knock1 -- 3524
		local hadK2 = self.escort.knock2 -- 3525
		self.calmConsumed = self.escort:update( -- 3526
			input, -- 3526
			p.x, -- 3526
			p.facing, -- 3526
			self.partner.x, -- 3526
			dist -- 3526
		) -- 3526
		if not hadK1 and self.escort.knock1 then -- 3527
			self:emit("knock", {count = 1, x = self.partner.x, room = self.room.key}) -- 3528
		end -- 3528
		if not hadK2 and self.escort.knock2 then -- 3530
			self:emit("knock", {count = 2, x = self.partner.x, room = self.room.key}) -- 3531
		end -- 3531
		self.partner.crouch = self.escort.crouchPose -- 3533
		self.partner.h = self.partner.crouch and CHILD_CROUCH_H or CHILD_H -- 3534
	end -- 3534
	if not self.calmConsumed and not self:stepCraft(input) and input.interact.pressed then -- 3536
		self:campaignInteract() -- 3537
	end -- 3537
	self:stepCampaignCart(dt, input) -- 3539
	self:stepCampaignGoal() -- 3540
	self:campaignCheckpoint() -- 3541
end -- 3461
function Play.prototype.campaignCheckpoint(self) -- 3545
	local i = 0 -- 3546
	do -- 3546
		i = 0 -- 3547
		while i < #self.room.marks do -- 3547
			do -- 3547
				local m = self.room.marks[i + 1] -- 3548
				if m.kind ~= 0 then -- 3549
					goto __continue547 -- 3550
				end -- 3550
				local dx = self.player.x - m.x -- 3552
				local dy = self.player.y - m.y -- 3553
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3554
					self.checkpoint = m.x -- 3555
					self:captureCheckpoint(m.x) -- 3556
					self:flashSet("检查点", 1) -- 3557
				end -- 3557
			end -- 3557
			::__continue547:: -- 3557
			i = i + 1 -- 3547
		end -- 3547
	end -- 3547
end -- 3545
function Play.prototype.campaignInteract(self) -- 3563
	local b = self:findInteract() -- 3564
	if b ~= nil then -- 3565
		self:useInteract(b) -- 3566
		return -- 3567
	end -- 3567
	local inv = self.run.inventory -- 3569
	if inv.wedge > 0 then -- 3570
		local w = self:findWedgeTarget() -- 3571
		if w ~= nil then -- 3572
			if w.breakable ~= nil then -- 3573
				local ____w_breakable_55, ____hp_56 = w.breakable, "hp" -- 3574
				____w_breakable_55[____hp_56] = ____w_breakable_55[____hp_56] + (w.breakable.wedgeHp or 1) -- 3574
			end -- 3574
			inv.wedge = inv.wedge - 1 -- 3576
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3577
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 3579
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3580
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3581
			return -- 3582
		end -- 3582
	end -- 3582
	if inv.ammo > 0 and self.reloadT > 0 then -- 3585
		self.reloadT = 0 -- 3587
		self:closeReloadPuzzle() -- 3588
		inv.ammo = inv.ammo - 1 -- 3589
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3590
		self:log("用备用弹包") -- 3591
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3592
		return -- 3593
	end -- 3593
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 3595
		local p = self.player -- 3597
		self.bracedShield = { -- 3598
			x = p.x + p.facing * 26, -- 3598
			y = p.y, -- 3598
			w = 30, -- 3598
			h = 64, -- 3598
			hp = 1 -- 3598
		} -- 3598
		local ____self_boxes_57 = self.boxes -- 3599
		____self_boxes_57[#____self_boxes_57 + 1] = { -- 3599
			x0 = self.bracedShield.x - 15, -- 3600
			x1 = self.bracedShield.x + 15, -- 3600
			y0 = p.y, -- 3601
			y1 = p.y + 64, -- 3601
			depth = {min = -46, max = 46}, -- 3601
			label = "架起的残盾", -- 3601
			id = "braced_shield", -- 3601
			soft = true -- 3602
		} -- 3602
		inv.shield = inv.shield - 1 -- 3605
		self:flashSet("架残盾 · 挡一发", 1.2) -- 3606
		self:log("架残盾") -- 3607
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3608
		return -- 3609
	end -- 3609
	if inv.pass > 0 and self.run.joined == false then -- 3611
		inv.pass = inv.pass - 1 -- 3612
		self.run.joined = true -- 3613
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3614
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3615
		return -- 3616
	end -- 3616
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3618
end -- 3563
function Play.prototype.useInteract(self, b) -- 3621
	local kind = b.interact == nil and "" or b.interact.kind -- 3622
	local wr = self.room -- 3623
	if kind == "open_board" then -- 3624
		b.broken = true -- 3625
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3626
		for ____, cover in ipairs(self.boxes) do -- 3627
			if cover.id == "s2_board_cover" then -- 3628
				cover.broken = false -- 3629
				cover.hidden = false -- 3630
			end -- 3630
		end -- 3630
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3633
		self.run.joined = true -- 3634
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3635
		self:log("放下窗板") -- 3636
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3637
		return -- 3638
	end -- 3638
	if kind == "lower_curtain" then -- 3640
		for ____, curtain in ipairs(self.boxes) do -- 3641
			if curtain.id == "c2_curtain" then -- 3642
				curtain.broken = false -- 3643
				curtain.hidden = false -- 3644
			end -- 3644
		end -- 3644
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3647
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3648
		self:log("放下木帘") -- 3649
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3650
		return -- 3651
	end -- 3651
	if kind == "raise_latch" then -- 3653
		if wr.key == "c2-granary" and not self.cartDocked then -- 3654
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3655
			return -- 3656
		end -- 3656
		b.broken = true -- 3658
		self.objectiveDone = true -- 3659
		if wr.key == "c1-yard" then -- 3661
			self.run.c1Latch = true -- 3662
			self.run.joined = true -- 3663
			for ____, door in ipairs(self.boxes) do -- 3664
				if door.id == "c1_door" then -- 3665
					door.broken = true -- 3666
				end -- 3666
			end -- 3666
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3669
		else -- 3669
			self.run.c2Latch = true -- 3671
			self.run.joined = true -- 3672
		end -- 3672
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3674
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3675
		self:log("抬闩") -- 3676
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3677
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3678
	end -- 3678
end -- 3621
function Play.prototype.stepCampaignCart(self, dt, input) -- 3683
	local wr = self.room -- 3684
	local c = wr.cart -- 3685
	if c.bodyW <= 0 then -- 3686
		return -- 3687
	end -- 3687
	local p = self.player -- 3689
	local handleX = self.cartAxle + c.handleOffset -- 3690
	if not self.gripping then -- 3691
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3692
			self.gripping = true -- 3694
			self:flashSet("握住车柄 · A/D 推", 1) -- 3695
		end -- 3695
		return -- 3697
	end -- 3697
	if input.interact.pressed then -- 3699
		self.gripping = false -- 3700
		self:flashSet("松手", 0.5) -- 3701
		return -- 3702
	end -- 3702
	if not self.cartDocked then -- 3704
		if input.moveX ~= 0 and not self:stuckCart() then -- 3705
			self.cartAxle = math.max( -- 3706
				c.startX, -- 3706
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3706
			) -- 3706
		end -- 3706
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3710
			self.cartExposed = true -- 3711
			local gun = nil -- 3712
			local gi = 0 -- 3713
			do -- 3713
				gi = 0 -- 3714
				while gi < #self.enemies do -- 3714
					local e = self.enemies[gi + 1] -- 3715
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3716
						gun = e -- 3717
						break -- 3718
					end -- 3718
					gi = gi + 1 -- 3714
				end -- 3714
			end -- 3714
			if gun ~= nil then -- 3721
				self:campaignEnemyFire(gun) -- 3722
			end -- 3722
		end -- 3722
		p.x = self.cartAxle + c.handleOffset -- 3725
		p.y = c.baseY -- 3726
		p.depth = c.depth or 0 -- 3727
		p.vx = 0 -- 3728
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3729
			self.cartAxle = c.endX -- 3730
			self.cartDocked = true -- 3731
			self.gripping = false -- 3732
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3733
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3734
			self:flashSet("车轮入窝", 1.2) -- 3735
			self:log("车轮入窝") -- 3736
		end -- 3736
	end -- 3736
end -- 3683
function Play.prototype.stuckCart(self) -- 3742
	local i = 0 -- 3743
	do -- 3743
		i = 0 -- 3744
		while i < #self.boxes do -- 3744
			do -- 3744
				local b = self.boxes[i + 1] -- 3745
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3746
					goto __continue589 -- 3747
				end -- 3747
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3749
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3750
					return true -- 3751
				end -- 3751
			end -- 3751
			::__continue589:: -- 3751
			i = i + 1 -- 3744
		end -- 3744
	end -- 3744
	return false -- 3754
end -- 3742
function Play.prototype.stepCampaignGoal(self) -- 3758
	local wr = self.room -- 3759
	local c = wr.campaign -- 3760
	if c == nil then -- 3761
		return -- 3762
	end -- 3762
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3764
		self.objectiveDone = true -- 3765
	end -- 3765
	if c.goal == "reach_exit" then -- 3767
		self.objectiveDone = true -- 3768
	end -- 3768
	if not self.objectiveDone then -- 3770
		return -- 3771
	end -- 3771
	local p = self.player -- 3773
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3774
	if p.x < c.exitX or not partnerOk then -- 3775
		return -- 3776
	end -- 3776
	if self.run.story.segments[wr.key] ~= true then -- 3779
		self.run.story.segments[wr.key] = true -- 3780
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3781
	end -- 3781
	if wr.key == "escort5" then -- 3784
		self.escortDone = true -- 3785
		self.run.story.escortDone = true -- 3786
	end -- 3786
	if c.next ~= nil and c.next ~= "" then -- 3788
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3789
		self:flashSet("过关 · " .. c.next, 1.2) -- 3790
	elseif wr.key == "c2-granary" and self.run.trial == nil and (self.run.source == "official" or self.run.source == "chapter") then -- 3791
		self:requestRoom("gate", "军粮棚出口") -- 3793
		self:flashSet("出军粮棚 · 城门", 1.4) -- 3794
	elseif not self.run.finished then -- 3795
		self.run.finished = true -- 3796
		self:flashSet( -- 3797
			"军粮棚清完 · 回城门 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3797
			2 -- 3797
		) -- 3797
		self:log("军粮棚清完 · 回城门") -- 3798
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3799
	end -- 3799
end -- 3758
function Play.prototype.stepCampaignPartner(self, dt) -- 3804
	local a = self.partner -- 3805
	local wr = self.room -- 3806
	local cp = wr.companion -- 3807
	if not a.alive then -- 3808
		return -- 3809
	end -- 3809
	local p = self.player -- 3811
	if self.craftBench.active then -- 3813
		a.vx = 0 -- 3814
		return -- 3815
	end -- 3815
	local wait = false -- 3817
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3818
	local targetDepth = p.depth -- 3819
	if self.run.joined == false then -- 3820
		wait = true -- 3821
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3822
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3823
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3824
		wait = true -- 3825
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3826
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3827
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3828
		wait = true -- 3829
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3830
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3831
	end -- 3831
	if self.partnerStuck > 0.3 then -- 3833
		a.x = a.x + a.facing * 44 -- 3835
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3836
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3837
		self.partnerLaneHold = 1.1 -- 3838
		self.partnerStuck = 0 -- 3839
	end -- 3839
	if self.partnerLaneHold > 0 then -- 3841
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3842
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3843
	end -- 3843
	local dx = targetX - a.x -- 3845
	local stopTol = wait and 18 or 74 -- 3846
	if math.abs(dx) > stopTol then -- 3847
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3848
		local before = a.x -- 3849
		a.vx = dx > 0 and speed or -speed -- 3850
		a.facing = dx > 0 and 1 or -1 -- 3851
		self:slideX(a, a.vx * dt) -- 3852
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3854
			a.vy = CHILD_JUMP -- 3855
			a.onGround = false -- 3856
		end -- 3856
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3858
	else -- 3858
		a.vx = 0 -- 3860
		self.partnerStuck = 0 -- 3861
	end -- 3861
	local dz = targetDepth - a.depth -- 3863
	if math.abs(dz) > 6 then -- 3864
		local step = math.max( -- 3865
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3865
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3865
		) -- 3865
		a.depth = a.depth + step -- 3866
	end -- 3866
	a.depthSpeed = 0 -- 3868
	a.h = CHILD_H -- 3869
	a.crouch = false -- 3870
	self:fallY(a, dt) -- 3871
end -- 3804
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3875
	local p = self.player -- 3876
	local i = 0 -- 3877
	do -- 3877
		i = 0 -- 3878
		while i < #self.enemies do -- 3878
			do -- 3878
				local ____opt_58 = self.run.trial -- 3879
				if ____opt_58 and ____opt_58.lost then -- 3879
					return -- 3879
				end -- 3879
				local e = self.enemies[i + 1] -- 3880
				if e.kind == "target" then -- 3881
					if not e.alive then -- 3883
						if e.hitT > 0 then -- 3884
							e.hitT = e.hitT - dt -- 3885
						end -- 3885
						if e.hitT <= 0 then -- 3887
							e.alive = true -- 3888
							e.hitT = 0 -- 3889
						end -- 3889
					end -- 3889
					goto __continue617 -- 3892
				end -- 3892
				if not e.alive then -- 3894
					goto __continue617 -- 3895
				end -- 3895
				if e.kind == "breaker" then -- 3897
					self:stepBreaker(e, dt) -- 3898
					goto __continue617 -- 3899
				end -- 3899
				if e.kind == "shield" then -- 3901
					self:stepShield(e, dt, input) -- 3902
					goto __continue617 -- 3903
				end -- 3903
				local dx = e.x - p.x -- 3906
				if not e.awake then -- 3907
					if math.abs(dx) > 520 then -- 3908
						goto __continue617 -- 3909
					end -- 3909
					e.awake = true -- 3911
					e.fireCd = 48 -- 3912
					goto __continue617 -- 3913
				end -- 3913
				if math.abs(dx) > ENEMY_RANGE then -- 3915
					goto __continue617 -- 3916
				end -- 3916
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 3920
					goto __continue617 -- 3921
				end -- 3921
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 3923
					goto __continue617 -- 3924
				end -- 3924
				if self:blockedShot(e, p) then -- 3926
					if e.warnT > 0 then -- 3929
						e.warnT = 0 -- 3930
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3931
					end -- 3931
					goto __continue617 -- 3933
				end -- 3933
				if e.warnT > 0 then -- 3935
					e.warnT = e.warnT - 1 -- 3936
					if e.warnT <= 0 then -- 3937
						self:campaignEnemyFire(e) -- 3938
					end -- 3938
				elseif e.fireCd > 0 then -- 3940
					e.fireCd = e.fireCd - 1 -- 3941
					if e.fireCd <= 0 then -- 3942
						e.warnT = WARN_TICKS -- 3943
					end -- 3943
				else -- 3943
					e.fireCd = 40 -- 3946
				end -- 3946
			end -- 3946
			::__continue617:: -- 3946
			i = i + 1 -- 3878
		end -- 3878
	end -- 3878
end -- 3875
function Play.prototype.blockedShot(self, e, p) -- 3952
	local eDepth = e.depth or 0 -- 3953
	local ex = e.x -- 3954
	local ey = e.y + e.h * 0.62 -- 3956
	local px = p.x -- 3957
	local py = p.y + p.h * 0.55 -- 3958
	local dx = px - ex -- 3959
	local dyScreen = py + p.depth * DEPTH_Y_SCALE - (ey + eDepth * DEPTH_Y_SCALE) -- 3960
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3961
	if len < 0.01 then -- 3962
		return false -- 3963
	end -- 3963
	local ray = { -- 3967
		x = ex, -- 3968
		y = ey, -- 3968
		dx = dx / len, -- 3969
		dy = (py - ey) / len, -- 3969
		depth = eDepth, -- 3970
		dDepth = (p.depth - eDepth) / len -- 3970
	} -- 3970
	local best = -1 -- 3972
	local j = 0 -- 3973
	do -- 3973
		j = 0 -- 3974
		while j < #self.boxes do -- 3974
			do -- 3974
				local b = self.boxes[j + 1] -- 3975
				if b.broken == true or b.passable == true or b.hidden == true then -- 3976
					goto __continue641 -- 3977
				end -- 3977
				if b.id == "braced_shield" then -- 3981
					goto __continue641 -- 3982
				end -- 3982
				local t = hitBox(ray, b) -- 3984
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3987
					best = t -- 3988
				end -- 3988
			end -- 3988
			::__continue641:: -- 3988
			j = j + 1 -- 3974
		end -- 3974
	end -- 3974
	return best >= 0 -- 3991
end -- 3952
function Play.prototype.campaignEnemyFire(self, e) -- 3994
	local p = self.player -- 3995
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3996
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3997
		local ____self_bracedShield_60, ____hp_61 = self.bracedShield, "hp" -- 3998
		____self_bracedShield_60[____hp_61] = ____self_bracedShield_60[____hp_61] - 1 -- 3998
		self.boxes = __TS__ArrayFilter( -- 3999
			self.boxes, -- 3999
			function(____, b) return b.id ~= "braced_shield" end -- 3999
		) -- 3999
		self.bracedShield = nil -- 4000
		self:flashSet("残盾碎 · 挡下一发", 1) -- 4001
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 4002
		return -- 4003
	end -- 4003
	if self:blockedShot(e, p) then -- 4005
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4006
		return -- 4007
	end -- 4007
	local cover = self:blockedByCover(e, p) -- 4009
	if cover ~= nil and self.coverHug then -- 4010
		self.coveredFlash = 0.5 -- 4011
		self:flashSet("掩体挡下", 0.6) -- 4012
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4013
		return -- 4018
	end -- 4018
	if self.invulnT > 0 then -- 4020
		return -- 4021
	end -- 4021
	self.invulnT = INVULN_HIT_TICKS + 12 * self:talentRank("guard") -- 4023
	self.craftT = 0 -- 4024
	self.hp = self.hp - 1 -- 4025
	self:emit("actorHit", { -- 4026
		target = "player", -- 4026
		amount = 1, -- 4026
		hp = self.hp, -- 4026
		maxHp = self.maxHp, -- 4026
		enemyX = e.x -- 4026
	}) -- 4026
	self:flashSet( -- 4027
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4027
		0.8 -- 4027
	) -- 4027
	if self.hp <= 0 then -- 4028
		self:campaignFailed() -- 4029
	end -- 4029
end -- 3994
function Play.prototype.stepShield(self, e, dt, input) -- 4034
	local p = self.player -- 4035
	local dx = p.x - e.x -- 4036
	local adx = math.abs(dx) -- 4037
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 4040
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 4041
	if adx > 44 then -- 4042
		local before = e.x -- 4043
		local stepX = (dx > 0 and 1 or -1) * 60 * dt -- 4044
		local nextX = math.max( -- 4045
			self.room.minX + 16, -- 4045
			math.min(self.room.maxX - 16, e.x + stepX) -- 4045
		) -- 4045
		if not self:enemyBlockedAtX(e, nextX) then -- 4046
			e.x = nextX -- 4047
		end -- 4047
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 4049
			e.depth = math.max( -- 4051
				-32, -- 4051
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4051
			) -- 4051
		end -- 4051
	elseif adx <= 48 and sameLane and (e.swingT or 0) <= 0 then -- 4053
		local fromFront = (e.x - p.x) * p.facing > 0 -- 4056
		local rollDodges = p.rollT > 0 and fromFront -- 4057
		if not rollDodges and self.invulnT <= 0 then -- 4058
			self.invulnT = INVULN_HIT_TICKS + 12 * self:talentRank("guard") -- 4059
			self.craftT = 0 -- 4060
			self.hp = self.hp - 1 -- 4061
			self:emit("actorHit", { -- 4062
				target = "player", -- 4062
				amount = 1, -- 4062
				hp = self.hp, -- 4062
				maxHp = self.maxHp, -- 4062
				enemyX = e.x -- 4062
			}) -- 4062
			self:flashSet( -- 4063
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4063
				0.8 -- 4063
			) -- 4063
			if self.hp <= 0 then -- 4064
				self:campaignFailed() -- 4065
				return -- 4066
			end -- 4066
		end -- 4066
		e.swingT = 70 -- 4069
	end -- 4069
	if (e.swingT or 0) > 0 then -- 4071
		e.swingT = (e.swingT or 0) - 1 -- 4072
	end -- 4072
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 4074
		local dd = p.depth - (e.depth or 0) -- 4075
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 4076
	end -- 4076
end -- 4034
function Play.prototype.stepBreaker(self, e, dt) -- 4081
	local p = self.player -- 4082
	if e.awake ~= true then -- 4083
		if math.abs(p.x - e.x) < 560 then -- 4084
			e.awake = true -- 4085
		else -- 4085
			return -- 4087
		end -- 4087
	end -- 4087
	local target = nil -- 4090
	local bestD = 1000000000 -- 4091
	local i = 0 -- 4092
	do -- 4092
		i = 0 -- 4093
		while i < #self.boxes do -- 4093
			do -- 4093
				local b = self.boxes[i + 1] -- 4094
				if b.breakable == nil or b.broken == true then -- 4095
					goto __continue666 -- 4096
				end -- 4096
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 4098
				if d < bestD then -- 4099
					bestD = d -- 4100
					target = b -- 4101
				end -- 4101
			end -- 4101
			::__continue666:: -- 4101
			i = i + 1 -- 4093
		end -- 4093
	end -- 4093
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 4104
	local dx = tx - e.x -- 4105
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 4106
	if math.abs(dx) > reach then -- 4107
		local before = e.x -- 4108
		local nextX = math.max( -- 4109
			self.room.minX + 16, -- 4109
			math.min(self.room.maxX - 16, e.x + (dx > 0 and 1 or -1) * 48 * dt) -- 4109
		) -- 4109
		if not self:enemyBlockedAtX(e, nextX) then -- 4110
			e.x = nextX -- 4111
		end -- 4111
		if math.abs(e.x - before) < 0.3 then -- 4113
			e.depth = math.max( -- 4114
				-32, -- 4114
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4114
			) -- 4114
		end -- 4114
	elseif (e.swingT or 0) <= 0 then -- 4116
		e.swingT = 64 -- 4117
		if target ~= nil then -- 4118
			self:damageProp(target, 2) -- 4119
		elseif math.abs(p.x - e.x) < 60 and math.abs((e.depth or 0) - p.depth) <= 26 and self.invulnT <= 0 then -- 4120
			self.invulnT = INVULN_HIT_TICKS + 12 * self:talentRank("guard") -- 4121
			self.craftT = 0 -- 4122
			self.hp = self.hp - 1 -- 4123
			self:emit("actorHit", { -- 4124
				target = "player", -- 4124
				amount = 1, -- 4124
				hp = self.hp, -- 4124
				maxHp = self.maxHp, -- 4124
				enemyX = e.x -- 4124
			}) -- 4124
			self:flashSet("破障手近身", 0.8) -- 4125
			if self.hp <= 0 then -- 4126
				self:campaignFailed() -- 4127
				return -- 4128
			end -- 4128
		end -- 4128
	end -- 4128
	if (e.swingT or 0) > 0 then -- 4132
		e.swingT = (e.swingT or 0) - 1 -- 4133
	end -- 4133
end -- 4081
function Play.prototype.enemyBlockedAtX(self, e, nextX) -- 4138
	local half = e.w * 0.5 -- 4139
	local d = e.depth or 0 -- 4140
	local i = 0 -- 4141
	do -- 4141
		i = 0 -- 4142
		while i < #self.boxes do -- 4142
			do -- 4142
				local b = self.boxes[i + 1] -- 4143
				if b.broken == true or b.passable == true or b.soft == true or b.hidden == true or b.y0 >= e.y + e.h or b.y1 <= e.y + 4 then -- 4144
					goto __continue679 -- 4145
				end -- 4145
				if b.depth ~= nil and (d < b.depth.min - 8 or d > b.depth.max + 8) then -- 4147
					goto __continue679 -- 4148
				end -- 4148
				if nextX + half > b.x0 and nextX - half < b.x1 then -- 4150
					return true -- 4151
				end -- 4151
			end -- 4151
			::__continue679:: -- 4151
			i = i + 1 -- 4142
		end -- 4142
	end -- 4142
	return false -- 4154
end -- 4138
function Play.prototype.campaignFailed(self) -- 4157
	if self.run.trial ~= nil then -- 4158
		self.run.trial.lost = true -- 4159
		self.wantRoom = "" -- 4160
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4161
		return -- 4162
	end -- 4162
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 4166
		self:restartEscortFromDeath() -- 4167
		return -- 4168
	end -- 4168
	local p = self.player -- 4170
	self.hp = self.maxHp -- 4171
	self.invulnT = INVULN_RESPAWN_TICKS -- 4172
	self.reloadT = 0 -- 4173
	self:closeReloadPuzzle() -- 4174
	self.gripping = false -- 4175
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 4176
	self:log("被击倒") -- 4177
	p.x = self.room.minX + 90 -- 4178
	p.y = 0 -- 4179
	p.depth = 0 -- 4180
	p.vx = 0 -- 4181
	p.vy = 0 -- 4182
	p.onGround = true -- 4183
	p.rollT = 0 -- 4184
	self.partner.x = p.x - 50 -- 4185
	self.partner.y = 0 -- 4186
	self.partner.depth = 0 -- 4187
	self.cam.x = p.x -- 4188
	local i = 0 -- 4189
	do -- 4189
		i = 0 -- 4190
		while i < #self.enemies do -- 4190
			do -- 4190
				local e = self.enemies[i + 1] -- 4191
				if not e.alive then -- 4192
					goto __continue687 -- 4193
				end -- 4193
				e.x = e.homeX == nil and e.x or e.homeX -- 4195
				e.warnT = 0 -- 4196
				e.fireCd = 40 -- 4197
				e.swingT = 0 -- 4198
				e.awake = false -- 4199
			end -- 4199
			::__continue687:: -- 4199
			i = i + 1 -- 4190
		end -- 4190
	end -- 4190
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4201
end -- 4157
function Play.prototype.isEscortRoom(self) -- 4205
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 4206
end -- 4205
function Play.prototype.restartEscortFromDeath(self) -- 4214
	local story = self.run.story -- 4215
	local inv = self.run.inventory -- 4216
	local vitBonus = story.talents ~= nil and story.talents.ranks.vitality or 0 -- 4217
	if vitBonus > 0 then -- 4218
		self.maxHp = math.max(3, self.maxHp - vitBonus) -- 4219
		story.maxHp = self.maxHp -- 4220
	end -- 4220
	story.talents = createStoryTalents(self.run.seed) -- 4222
	self.hp = self.maxHp -- 4223
	story.hp = self.maxHp -- 4224
	story.cp = nil -- 4225
	self.checkpointSnap = nil -- 4226
	story.carry = false -- 4227
	self.carryOn = false -- 4228
	story.craftedWeapon = "" -- 4229
	self.equippedWeapon = "standard_gun" -- 4230
	story.equippedWeapon = "standard_gun" -- 4231
	story.escortDone = false -- 4232
	self.escortDone = false -- 4233
	story.segments = {} -- 4234
	inv.wood = 0 -- 4235
	inv.bell = 0 -- 4236
	inv.scrap = 0 -- 4237
	inv.wedge = 0 -- 4238
	inv.ammo = 0 -- 4239
	inv.quickbelt = 0 -- 4240
	inv.shield = 0 -- 4241
	inv.pass = 0 -- 4242
	local taken = self.run.taken -- 4243
	local keys = __TS__ObjectKeys(taken) -- 4244
	local i = 0 -- 4245
	do -- 4245
		i = 0 -- 4246
		while i < #keys do -- 4246
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 4247
				__TS__Delete(taken, keys[i + 1]) -- 4248
			end -- 4248
			i = i + 1 -- 4246
		end -- 4246
	end -- 4246
	self.run.joined = true -- 4251
	self.reloadT = 0 -- 4252
	self:closeReloadPuzzle() -- 4253
	self.gripping = false -- 4254
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 4255
	self:log("男主线失败 · 回 escort1") -- 4256
	self:emit("campaignFailed", { -- 4257
		room = self.room.key, -- 4258
		hp = 0, -- 4258
		maxHp = self.maxHp, -- 4258
		reset = true, -- 4259
		to = "escort1", -- 4259
		route = self.storyRoute -- 4259
	}) -- 4259
	self:requestRoom("escort1", "男主线失败重开") -- 4261
end -- 4214
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 4265
	local i = 0 -- 4266
	do -- 4266
		i = 0 -- 4267
		while i < #self.enemies do -- 4267
			do -- 4267
				if i == skipIndex then -- 4268
					goto __continue697 -- 4269
				end -- 4269
				local e = self.enemies[i + 1] -- 4271
				if not e.alive or math.abs(e.x - center.x) > radius then -- 4272
					goto __continue697 -- 4273
				end -- 4273
				e.fireCd = 150 -- 4275
				e.warnT = 0 -- 4276
			end -- 4276
			::__continue697:: -- 4276
			i = i + 1 -- 4267
		end -- 4267
	end -- 4267
end -- 4265
function Play.prototype.stepEnemies(self, dt, input) -- 4280
	local i = 0 -- 4281
	do -- 4281
		i = 0 -- 4282
		while i < #self.enemies do -- 4282
			local e = self.enemies[i + 1] -- 4283
			if e.hitT > 0 then -- 4284
				e.hitT = e.hitT - dt -- 4285
			end -- 4285
			i = i + 1 -- 4282
		end -- 4282
	end -- 4282
	if self.coveredFlash > 0 then -- 4288
		self.coveredFlash = self.coveredFlash - dt -- 4289
	end -- 4289
	if self.isCampaign then -- 4291
		self:stepCampaignEnemies(dt, input) -- 4292
		return -- 4293
	end -- 4293
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 4296
		return -- 4297
	end -- 4297
	do -- 4297
		i = 0 -- 4299
		while i < #self.enemies do -- 4299
			do -- 4299
				local e = self.enemies[i + 1] -- 4300
				if not e.alive then -- 4301
					goto __continue708 -- 4302
				end -- 4302
				if e.warnT > 0 then -- 4304
					e.warnT = e.warnT - 1 -- 4305
					if e.warnT <= 0 then -- 4306
						self:enemyFire(e, input) -- 4307
					end -- 4307
					goto __continue708 -- 4309
				end -- 4309
				if e.fireCd > 0 then -- 4311
					e.fireCd = e.fireCd - 1 -- 4312
					if e.fireCd <= 0 then -- 4313
						e.warnT = WARN_TICKS -- 4314
					end -- 4314
				else -- 4314
					e.warnT = WARN_TICKS -- 4318
				end -- 4318
			end -- 4318
			::__continue708:: -- 4318
			i = i + 1 -- 4299
		end -- 4299
	end -- 4299
end -- 4280
function Play.prototype.enemyFire(self, e, input) -- 4324
	local p = self.player -- 4325
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 4326
		self:flashSet("枪声响在远处", 0.4) -- 4327
		e.fireCd = FIRE_COOLDOWN -- 4328
		return -- 4329
	end -- 4329
	if self:blockedShot(e, p) then -- 4331
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4332
		e.fireCd = FIRE_COOLDOWN -- 4333
		return -- 4334
	end -- 4334
	local cover = self:blockedByCover(e, p) -- 4337
	local hugging = cover ~= nil -- 4338
	self.coverBlocking = hugging -- 4339
	local covered = hugging and input.cover.held -- 4340
	if covered then -- 4341
		self.coveredFlash = 0.5 -- 4342
		self:flashSet("掩体挡下", 0.5) -- 4343
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4344
		e.fireCd = FIRE_COOLDOWN -- 4349
		return -- 4350
	end -- 4350
	if self.invulnT > 0 then -- 4352
		e.fireCd = FIRE_COOLDOWN -- 4353
		return -- 4354
	end -- 4354
	self.invulnT = INVULN_HIT_TICKS -- 4356
	self.hp = self.hp - 1 -- 4357
	self:emit("actorHit", { -- 4358
		target = "player", -- 4358
		amount = 1, -- 4358
		hp = self.hp, -- 4358
		maxHp = self.maxHp, -- 4358
		enemyX = e.x -- 4358
	}) -- 4358
	self:flashSet( -- 4359
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4359
		0.7 -- 4359
	) -- 4359
	e.fireCd = FIRE_COOLDOWN -- 4360
	if self.hp <= 0 then -- 4361
		self:gateFailed() -- 4362
	end -- 4362
end -- 4324
function Play.prototype.blockedByCover(self, enemy, p) -- 4367
	local b = self:coverAt(p) -- 4368
	if b == nil then -- 4369
		return nil -- 4370
	end -- 4370
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4372
end -- 4367
function Play.prototype.gateFailed(self) -- 4376
	local ____temp_62 -- 4377
	if self.room.story == nil then -- 4377
		____temp_62 = nil -- 4377
	else -- 4377
		____temp_62 = self.room.story.gate -- 4377
	end -- 4377
	local g = ____temp_62 -- 4377
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 4378
	self.hp = self.maxHp -- 4379
	self.gateTick = 0 -- 4380
	self.gateSpawned = 0 -- 4381
	self.enemies = {} -- 4382
	self.gateFailCount = self.gateFailCount + 1 -- 4383
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 4385
	self.player.y = 0 -- 4386
	self.player.vy = 0 -- 4387
	self.player.depth = 0 -- 4388
	self.player.depthSpeed = 0 -- 4389
	self.player.onGround = true -- 4390
	self.player.crouch = false -- 4391
	self.player.h = SOLDIER_H -- 4392
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 4393
	self.partner.y = 0 -- 4394
	self.partner.vy = 0 -- 4395
	self.partner.depth = 0 -- 4396
	self.partner.depthSpeed = 0 -- 4397
	self.partner.onGround = true -- 4398
	self.cam.x = self.player.x -- 4399
	self.phase = "gate-idle" -- 4400
	self.phaseTick = 0 -- 4401
	self.coverHug = false -- 4402
	self.coverBlocking = false -- 4403
	self.coverEntity = "" -- 4404
	self.gateNeedConfirm = true -- 4405
	self.gateRestartArmed = false -- 4406
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 4407
end -- 4376
function Play.prototype.stepRedCart(self, input) -- 4411
	if self.redCartMemoryT > 0 then -- 4412
		self.redCartMemoryT = self.redCartMemoryT - 1 -- 4413
	end -- 4413
	if self.room.key ~= "outside" or self.redCartPulled then -- 4415
		return -- 4416
	end -- 4416
	local box = __TS__ArrayFind( -- 4418
		self.boxes, -- 4418
		function(____, b) return b.id == "outside_red_cart" end -- 4418
	) -- 4418
	if box == nil then -- 4419
		self.redCartPulled = true -- 4420
		return -- 4421
	end -- 4421
	local cx = (box.x0 + box.x1) * 0.5 -- 4423
	local p = self.player -- 4424
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 4425
		return -- 4426
	end -- 4426
	if not input.interact.pressed then -- 4428
		return -- 4429
	end -- 4429
	box.x0 = 430 -- 4431
	box.x1 = 474 -- 4432
	self.cartAxle = self.room.cart.endX -- 4434
	self.cartDocked = true -- 4435
	self.redCartPulled = true -- 4436
	self.redCartMemoryT = 30 -- 4437
	if self.run.story ~= nil then -- 4438
		self.run.story.segments.outside_cart = true -- 4439
		self.run.story.segments.outside_memory = true -- 4440
	end -- 4440
	self.sessionDirty = true -- 4442
	self:flashSet("红布补丁 · 想起家里那一针 · 石阶口露出来", 1.8) -- 4443
	self:emit("storyBeat", {beat = "red_cart", x = p.x, room = "outside"}) -- 4444
	self:emit("storyBeat", {beat = "red_cart_memory", x = p.x, room = "outside", durationTicks = 30}) -- 4445
end -- 4411
function Play.prototype.stepInteract(self, dt, input) -- 4448
	local p = self.player -- 4449
	self:stepRedCart(input) -- 4450
	local calmUsed = self.calmConsumed -- 4451
	self.calmConsumed = false -- 4452
	local calming = self.escort.state == "calming" -- 4454
	self.focusCart = false -- 4455
	if self.room.key == "outside" then -- 4456
		local c = self.room.cart -- 4457
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 4458
		local dy = p.y - c.baseY -- 4459
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 4460
	end -- 4460
	if not calmUsed and not calming then -- 4463
		self:stepCart(dt, input) -- 4464
	end -- 4464
	if calmUsed then -- 4468
		self:flashSet("安抚 · 敲两下", 0.8) -- 4469
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4470
		if self.knockT > 0 then -- 4472
			self.knocks = self.knocks + 1 -- 4473
		else -- 4473
			self.knocks = 1 -- 4475
		end -- 4475
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4477
		self.knockT = 1.2 -- 4478
		if self.knocks >= 2 then -- 4479
			self:flashSet("敲两下", 0.8) -- 4480
			self.knocks = 0 -- 4481
		else -- 4481
			self:flashSet("敲一下", 0.5) -- 4483
		end -- 4483
	elseif self.knockT > 0 then -- 4485
		self.knockT = self.knockT - dt -- 4486
		if self.knockT <= 0 then -- 4487
			self.knocks = 0 -- 4488
		end -- 4488
	end -- 4488
	local i = 0 -- 4493
	do -- 4493
		i = 0 -- 4494
		while i < #self.room.marks do -- 4494
			do -- 4494
				local m = self.room.marks[i + 1] -- 4495
				if m.kind ~= 0 then -- 4496
					goto __continue744 -- 4497
				end -- 4497
				local subjects = {self.partner, self.player} -- 4499
				local k = 0 -- 4500
				do -- 4500
					k = 0 -- 4501
					while k < #subjects do -- 4501
						do -- 4501
							local s = subjects[k + 1] -- 4502
							if not s.alive then -- 4503
								goto __continue747 -- 4504
							end -- 4504
							local dx = s.x - m.x -- 4506
							local dy = s.y - m.y -- 4507
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4508
								self.checkpoint = m.x -- 4509
								self.checkpointCartAxle = self.cartAxle -- 4510
								if self.isCampaign then -- 4512
									self:captureCheckpoint(m.x) -- 4513
								end -- 4513
								if self.cartDocked then -- 4515
									self:flashSet("检查点 · 车已落窝", 1) -- 4516
								else -- 4516
									self:flashSet("检查点 · 车还没到位", 1) -- 4518
								end -- 4518
							end -- 4518
						end -- 4518
						::__continue747:: -- 4518
						k = k + 1 -- 4501
					end -- 4501
				end -- 4501
			end -- 4501
			::__continue744:: -- 4501
			i = i + 1 -- 4494
		end -- 4494
	end -- 4494
	self:checkCarryGate() -- 4524
end -- 4448
function Play.prototype.stepVillage(self, dt, input) -- 4528
	if self.room.key ~= "village" then -- 4529
		return -- 4530
	end -- 4530
	local p = self.player -- 4532
	local bottle = self.room.bottle -- 4533
	local scav = self.room.scavenger -- 4534
	if not self.hasBottle and bottle ~= nil then -- 4537
		local dx = p.x - bottle.x -- 4538
		local dy = p.y + p.h * 0.5 - bottle.y -- 4539
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4540
			self.hasBottle = true -- 4541
			self:flashSet("拾起瓶子", 0.8) -- 4542
		end -- 4542
	end -- 4542
	if self.hasBottle then -- 4547
		if input.bottleCanceled then -- 4548
			self.aimHold = 0 -- 4549
			self.bottleAimX = -1 -- 4550
		elseif input.aim.held then -- 4551
			self.aimHold = self.aimHold + dt -- 4552
			if self.aimHold > 1.2 then -- 4553
				self.aimHold = 1.2 -- 4554
			end -- 4554
			local cached = self:bottleEnd() -- 4557
			self.bottleAimX = cached.x -- 4558
			self.bottleAimY = cached.y -- 4559
		elseif input.aim.released then -- 4560
			if self.aimHold < 0.12 then -- 4561
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 4563
				self.aimHold = 0 -- 4564
			else -- 4564
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4566
				self:throwBottle(____end.x, ____end.y) -- 4567
				self.aimHold = 0 -- 4568
			end -- 4568
		end -- 4568
	else -- 4568
		self.aimHold = 0 -- 4572
		self.bottleAimX = -1 -- 4573
	end -- 4573
	local fly = self.bottleFly -- 4578
	if fly ~= nil then -- 4579
		fly.t = fly.t + dt -- 4580
		fly.x = fly.x0 + fly.vx * fly.t -- 4581
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4582
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4583
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4584
			self:landBottle(fly) -- 4585
		end -- 4585
	end -- 4585
	if self.bottleLandT > 0 then -- 4588
		self.bottleLandT = self.bottleLandT - dt -- 4589
	end -- 4589
	if scav ~= nil then -- 4592
		self:stepScav(dt, scav) -- 4593
	end -- 4593
	local line = self.room.passLine -- 4596
	if line ~= nil and not self.passed and p.x >= line then -- 4597
		self.passed = true -- 4598
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4599
	end -- 4599
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4602
	if underTable then -- 4603
		self.footHintT = self.footHintT - 1 -- 4604
		if self.footHintT <= 0 then -- 4605
			self.footHintT = 90 -- 4606
			local scavX = self.scavX -- 4607
			local near = math.abs(scavX - p.x) < 120 -- 4608
			local walkingAway = self.scavState == "walk" and math.abs(self.scavTargetX - p.x) >= 120 -- 4609
			local heard = self.scavState == "chase" or near and not walkingAway -- 4610
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4611
			self:emit("storyBeat", {beat = heard and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4612
		end -- 4612
	else -- 4612
		self.footHintT = 0 -- 4615
	end -- 4615
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4618
		self.ditchHinted = true -- 4619
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4620
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4621
	end -- 4621
	if self.passed and p.x >= self.ox + 640 then -- 4624
		self:requestRoom("forest", "过第一院出院") -- 4625
		self:flashSet("钻出暗渠 · 北塔森林", 1.4) -- 4626
	end -- 4626
end -- 4528
function Play.prototype.bottleEnd(self) -- 4631
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4632
	local clampedX = math.max( -- 4635
		self.room.minX + 12, -- 4635
		math.min(self.room.maxX - 12, aim.x) -- 4635
	) -- 4635
	local g = self:groundAt(clampedX, aim.y + 240, 3) -- 4636
	return {x = clampedX, y = g} -- 4637
end -- 4631
function Play.prototype.throwBottle(self, tx, ty) -- 4641
	local p = self.player -- 4642
	local dir = tx >= p.x and 1 or -1 -- 4644
	p.facing = dir -- 4645
	local x0 = p.x + dir * 10 -- 4646
	local y0 = p.y + p.h * 0.7 -- 4647
	self.bottleTargetX = tx -- 4648
	self.bottleTargetY = ty -- 4649
	self.bottleSurfaceY = ty -- 4650
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4651
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4652
	self.bottleFly = { -- 4653
		x = x0, -- 4653
		y = y0, -- 4653
		x0 = x0, -- 4653
		y0 = y0, -- 4653
		vx = vx, -- 4653
		vy = vy, -- 4653
		t = 0 -- 4653
	} -- 4653
	self.hasBottle = false -- 4654
	self:flashSet("投出", 0.4) -- 4655
	self:emit( -- 4656
		"bottleThrown", -- 4656
		{ -- 4656
			fromX = x0, -- 4657
			fromY = y0, -- 4658
			targetX = tx, -- 4659
			targetY = ty, -- 4660
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4661
		} -- 4661
	) -- 4661
end -- 4641
function Play.prototype.bottleSurfaceAt(self, x) -- 4666
	if self.room.softX ~= nil and math.abs(x - self.room.softX) <= 34 then -- 4667
		return "soft" -- 4668
	end -- 4668
	if self.room.basinX ~= nil and math.abs(x - self.room.basinX) <= 24 then -- 4670
		return "iron" -- 4671
	end -- 4671
	return "brick" -- 4673
end -- 4666
function Play.prototype.landBottle(self, fly) -- 4677
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4678
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4679
	local s = self.room.scavenger -- 4680
	local surface = self:bottleSurfaceAt(x) -- 4681
	local effRange = s == nil and 0 or (surface == "iron" and s.range * 1.25 or s.range) -- 4682
	local heard = surface ~= "soft" and s ~= nil and math.abs(x - self.scavX) <= effRange -- 4683
	local stallTicks = s == nil and 0 or (surface == "iron" and s.stallTicks + 90 or s.stallTicks) -- 4684
	self.bottleFly = nil -- 4685
	self.bottleTargetX = -1 -- 4686
	self.bottleTargetY = 0 -- 4687
	self.bottleSurfaceY = -1 -- 4688
	self.bottleLandX = x -- 4689
	self.bottleLandY = y -- 4690
	self.bottleLandT = 0.9 -- 4691
	self:emit("bottleLanded", { -- 4692
		x = x, -- 4693
		y = y, -- 4694
		surface = surface, -- 4695
		heard = heard, -- 4696
		resonance = surface == "iron", -- 4697
		stallTicks = heard and stallTicks or 0, -- 4698
		scavState = self.scavState -- 4699
	}) -- 4699
	self:hearBottle(x, surface) -- 4701
end -- 4677
function Play.prototype.hearBottle(self, x, surface) -- 4705
	if surface == nil then -- 4705
		surface = "brick" -- 4705
	end -- 4705
	local s = self.room.scavenger -- 4706
	if s == nil then -- 4707
		return -- 4708
	end -- 4708
	if surface == "soft" then -- 4710
		self:flashSet("落在软土 · 没出声", 0.8) -- 4711
		return -- 4712
	end -- 4712
	local effRange = surface == "iron" and s.range * 1.25 or s.range -- 4714
	if math.abs(x - self.scavX) > effRange then -- 4715
		self:flashSet("落地 · 他没听见", 0.6) -- 4716
		return -- 4717
	end -- 4717
	self.scavState = "turn" -- 4719
	self.scavT = s.hearTicks -- 4720
	self.scavTargetX = surface == "iron" and self.room.basinX ~= nil and self.room.basinX or x -- 4721
	self.scavStallBonus = surface == "iron" and 90 or 0 -- 4722
	self:flashSet(surface == "iron" and "铁盆余振两响 · 他停下来细听" or "砖地一响 · 他转头", 1.1) -- 4723
end -- 4705
function Play.prototype.stepScav(self, dt, s) -- 4727
	if self.scavState == "chase" then -- 4729
		return -- 4730
	end -- 4730
	if self.scavState == "turn" then -- 4732
		self.scavT = self.scavT - 1 -- 4733
		if self.scavT <= 0 then -- 4734
			self.scavState = "walk" -- 4735
		end -- 4735
		return -- 4737
	end -- 4737
	if self.scavState == "walk" then -- 4739
		local d = self.scavTargetX - self.scavX -- 4740
		if math.abs(d) < 4 then -- 4741
			self.scavState = "stall" -- 4742
			self.scavT = s.stallTicks + self.scavStallBonus -- 4743
			self.scavStallBonus = 0 -- 4744
			return -- 4745
		end -- 4745
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4747
		return -- 4748
	end -- 4748
	if self.scavState == "stall" then -- 4750
		self.scavT = self.scavT - 1 -- 4751
		if self.scavT <= 0 then -- 4752
			self.scavState = "back" -- 4753
		end -- 4753
		return -- 4755
	end -- 4755
	if self.scavState == "back" then -- 4757
		local home = math.max( -- 4758
			s.x0, -- 4758
			math.min(s.x1, self.scavX) -- 4758
		) -- 4758
		if math.abs(home - self.scavX) < 2 then -- 4759
			self.scavState = "patrol" -- 4760
			return -- 4761
		end -- 4761
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4763
		return -- 4764
	end -- 4764
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4766
	if self.scavX >= s.x1 then -- 4767
		self.scavX = s.x1 -- 4768
		self.scavDir = -1 -- 4769
	elseif self.scavX <= s.x0 then -- 4770
		self.scavX = s.x0 -- 4771
		self.scavDir = 1 -- 4772
	end -- 4772
end -- 4727
function Play.prototype.stepCart(self, dt, input) -- 4780
	local p = self.player -- 4781
	local c = self.room.cart -- 4782
	if self.gripping then -- 4784
		if not input.interact.held then -- 4785
			self.gripping = false -- 4786
			self:flashSet("松开车把", 0.4) -- 4787
			return -- 4788
		end -- 4788
	else -- 4788
		if not input.interact.pressed then -- 4791
			return -- 4792
		end -- 4792
		if not self:cartHandleInReach(p) then -- 4794
			return -- 4795
		end -- 4795
		local track = c.depth or 0 -- 4797
		if self:limitDepth(p, track) ~= track then -- 4798
			return -- 4799
		end -- 4799
		p.depth = track -- 4801
		p.depthSpeed = 0 -- 4802
		self.gripping = true -- 4803
		self:flashSet("握住车把", 0.4) -- 4804
		return -- 4805
	end -- 4805
	if self.cartDocked then -- 4808
		return -- 4809
	end -- 4809
	local dir = input.moveX -- 4811
	if dir == 0 then -- 4812
		return -- 4813
	end -- 4813
	local lo = math.min(c.startX, c.endX) -- 4815
	local hi = math.max(c.startX, c.endX) -- 4816
	local next = self.cartAxle + dir * CART_SPEED * dt -- 4817
	if next < lo then -- 4818
		next = lo -- 4819
	end -- 4819
	if next > hi then -- 4821
		next = hi -- 4822
	end -- 4822
	local delta = next - self.cartAxle -- 4824
	if delta == 0 then -- 4825
		return -- 4826
	end -- 4826
	self.cartAxle = next -- 4828
	p.x = p.x + delta -- 4829
	p.facing = dir > 0 and 1 or -1 -- 4830
	self:slideX(p, 0) -- 4831
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 4832
		self.gripping = false -- 4833
		self:flashSet("跟不上了，脱手", 0.6) -- 4834
		return -- 4835
	end -- 4835
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 4837
		self.cartDocked = true -- 4838
		self.gripping = false -- 4839
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 4840
		self:flashSet("车轮落窝", 1.2) -- 4841
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 4842
		self:flashSet("车轮回到起点", 0.5) -- 4843
	end -- 4843
end -- 4780
function Play.prototype.requestRoom(self, key, reason) -- 4851
	if self.wantRoom ~= "" then -- 4854
		return -- 4855
	end -- 4855
	self.wantRoom = key -- 4857
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 4858
end -- 4851
function Play.prototype.checkCarryGate(self) -- 4865
	if self.room.key == "checkpoint" then -- 4866
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 4867
			self.carryCartAxle = self.cartAxle -- 4868
			self.carryCartDocked = self.cartDocked -- 4869
			self:requestRoom("gate", "检查站出口") -- 4870
			self:flashSet("出检查站 · 城门", 1.2) -- 4871
		end -- 4871
		return -- 4873
	end -- 4873
	if self.room.key == "outside" then -- 4875
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 4878
			self.carryCartAxle = self.cartAxle -- 4879
			self.carryCartDocked = self.cartDocked -- 4880
			self:requestRoom("village", "墙根走完") -- 4881
			self:flashSet("墙根走完 · 进村口", 1.2) -- 4882
		end -- 4882
	end -- 4882
end -- 4865
function Play.prototype.aimAt(self, wx, wy) -- 4889
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 4890
	self.aimX = s.x -- 4891
	self.aimY = s.y -- 4892
end -- 4889
function Play.prototype.shoot(self, a) -- 4895
	if self.isCampaign and self.reloadT > 0 then -- 4896
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 4897
		return -- 4898
	end -- 4898
	local ox = a.x + a.facing * 8 -- 4900
	local muzzleY = a.y + a.h * 0.72 -- 4901
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 4902
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4904
	local dx = aim.x - ox -- 4907
	local dy = aim.y - oy -- 4908
	local len = math.sqrt(dx * dx + dy * dy) -- 4909
	if len < 0.001 then -- 4910
		dx = a.facing -- 4911
		dy = 0 -- 4912
	else -- 4912
		dx = dx / len -- 4914
		dy = dy / len -- 4915
	end -- 4915
	if dx ~= 0 then -- 4917
		a.facing = dx > 0 and 1 or -1 -- 4918
	end -- 4918
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 4921
	local hitEnemy = self:raycastEnemies(ray) -- 4922
	local tEnemy = hitEnemy.t -- 4923
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 4924
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 4925
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 4926
	local tWall = solid.t -- 4927
	local rawEffect = self:consumeReloadEffect() -- 4929
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 4930
	local reloadEffect = rawEffect -- 4931
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 4933
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 4934
	self.trace = { -- 4936
		x0 = ox, -- 4936
		y0 = oy, -- 4936
		x1 = ox + dx * t, -- 4936
		y1 = oy + dy * t, -- 4936
		hit = hit -- 4936
	} -- 4936
	self.traceT = 0.12 -- 4937
	self:applyFireDanger(ox) -- 4938
	local killed = false -- 4939
	if hit then -- 4940
		local i = hitEnemy.index -- 4941
		local e = self.enemies[i + 1] -- 4942
		local impactY = oy + dy * tEnemy -- 4943
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 4944
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 4945
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 4946
			local dmg = reloadEffect == "push" and 2 or 1 -- 4947
			e.shieldHp = math.max(0, (e.shieldHp or 0) - dmg) -- 4948
			e.hitT = 0.3 -- 4949
			if reloadEffect == "push" then -- 4950
				e.x = math.max( -- 4951
					self.room.minX + 20, -- 4951
					math.min(self.room.maxX - 20, e.x + a.facing * 46) -- 4951
				) -- 4951
				self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4952
				self:flashSet(e.shieldHp <= 0 and "推退破盾！" or "推退震退持盾手", 0.9) -- 4953
			else -- 4953
				self:flashSet( -- 4955
					(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 4955
					0.8 -- 4955
				) -- 4955
			end -- 4955
			self:emit("shotResolved", { -- 4957
				hit = true, -- 4958
				enemyIndex = i, -- 4958
				enemyX = e.x, -- 4958
				aimX = aim.x, -- 4958
				aimY = aim.y, -- 4958
				impactX = ox + dx * t, -- 4959
				impactY = oy + dy * t, -- 4959
				shield = true -- 4959
			}) -- 4959
			self:beginReload() -- 4961
			return -- 4962
		end -- 4962
		e.alive = false -- 4964
		e.hitT = 0.4 -- 4965
		killed = true -- 4966
		self:flashSet("命中", 0.6) -- 4967
		self:dropFor(e) -- 4968
		if reloadEffect == "light" and weaponFx == "light" then -- 4969
			self:blindNearby(e, 160, i) -- 4970
		end -- 4970
		if reloadEffect == "push" then -- 4972
			e.x = e.x + a.facing * 46 -- 4973
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4974
		elseif reloadEffect == "echo" then -- 4975
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 4976
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 4977
		elseif reloadEffect == "light" then -- 4978
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 4979
		end -- 4979
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 4981
		self:damageProp(solid.box, 1) -- 4982
	else -- 4982
		self:flashSet("打空", 0.35) -- 4984
	end -- 4984
	if self.isCampaign then -- 4986
		self:beginReload() -- 4987
	end -- 4987
	self:emit("shotResolved", { -- 4989
		hit = hit, -- 4990
		enemyIndex = hit and hitEnemy.index or -1, -- 4991
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 4992
		aimX = aim.x, -- 4993
		aimY = aim.y, -- 4994
		impactX = ox + dx * t, -- 4995
		impactY = oy + dy * t -- 4996
	}) -- 4996
end -- 4895
function Play.prototype.applyFireDanger(self, shotX) -- 5001
	local ____temp_68 = self.isCampaign and self.run.trial == nil and self.run.joined -- 5002
	if ____temp_68 then -- 5002
		local ____opt_63 = self.room.campaign -- 5003
		local ____temp_67 = (____opt_63 and ____opt_63.chapter) == "S" -- 5003
		if not ____temp_67 then -- 5003
			local ____opt_65 = self.room.campaign -- 5003
			____temp_67 = (____opt_65 and ____opt_65.chapter) == "C" -- 5003
		end -- 5003
		____temp_68 = ____temp_67 -- 5002
	end -- 5002
	local isStorySc = ____temp_68 -- 5002
	if self.room.key ~= "checkpoint" and not isStorySc or not self.partner.alive then -- 5004
		return -- 5005
	end -- 5005
	local dangerX = shotX -- 5007
	local best = -1 -- 5008
	local bestD = 1000000000 -- 5009
	local i = 0 -- 5010
	do -- 5010
		i = 0 -- 5011
		while i < #self.enemies do -- 5011
			do -- 5011
				local e = self.enemies[i + 1] -- 5012
				if not e.alive then -- 5013
					goto __continue839 -- 5014
				end -- 5014
				local d = math.abs(e.x - self.partner.x) -- 5016
				if d < bestD then -- 5017
					bestD = d -- 5018
					best = i -- 5019
				end -- 5019
			end -- 5019
			::__continue839:: -- 5019
			i = i + 1 -- 5011
		end -- 5011
	end -- 5011
	if best >= 0 then -- 5022
		dangerX = self.enemies[best + 1].x -- 5023
	end -- 5023
	if isStorySc and math.abs(dangerX - self.partner.x) > 260 then -- 5026
		return -- 5027
	end -- 5027
	local exposed = self:childExposed(dangerX) -- 5029
	local before = self.escort.fear -- 5030
	local dangerId = self.nextDangerId -- 5031
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 5032
	self.nextDangerId = self.nextDangerId + 1 -- 5033
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 5034
	if after > before then -- 5035
		self:flashSet( -- 5036
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 5036
			1 -- 5036
		) -- 5036
	elseif not exposed then -- 5037
		self:flashSet("枪声没够到她", 0.5) -- 5038
	end -- 5038
end -- 5001
function Play.prototype.childExposed(self, dangerX) -- 5043
	local c = self.partner -- 5044
	if not c.alive then -- 5045
		return false -- 5046
	end -- 5046
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 5048
		self.boxes, -- 5049
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 5049
	) then -- 5049
		return false -- 5050
	end -- 5050
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 5052
		return false -- 5053
	end -- 5053
	local toDanger = dangerX - c.x -- 5055
	local toPlayer = self.player.x - c.x -- 5056
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 5057
		return false -- 5059
	end -- 5059
	return true -- 5061
end -- 5043
function Play.prototype.raycastEnemies(self, ray) -- 5065
	local best = -1 -- 5066
	local bestI = -1 -- 5067
	do -- 5067
		local i = 0 -- 5068
		while i < #self.enemies do -- 5068
			do -- 5068
				local e = self.enemies[i + 1] -- 5069
				if not e.alive then -- 5070
					goto __continue854 -- 5071
				end -- 5071
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 5073
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 5074
				if t >= 0 and (best < 0 or t < best) then -- 5075
					best = t -- 5076
					bestI = i -- 5077
				end -- 5077
			end -- 5077
			::__continue854:: -- 5077
			i = i + 1 -- 5068
		end -- 5068
	end -- 5068
	return {t = best, index = bestI} -- 5080
end -- 5065
function Play.prototype.raycastWorld(self, ray) -- 5083
	return self:raycastSolid(ray).t -- 5084
end -- 5083
function Play.prototype.raycastSolid(self, ray) -- 5088
	local best = -1 -- 5089
	local bestBox = nil -- 5090
	for ____, box in ipairs(self.boxes) do -- 5091
		do -- 5091
			if box.broken == true or box.hidden == true then -- 5092
				goto __continue859 -- 5093
			end -- 5093
			local t = hitBox(ray, box) -- 5098
			if t > 2 and (best < 0 or t < best) then -- 5100
				best = t -- 5101
				bestBox = box -- 5102
			end -- 5102
		end -- 5102
		::__continue859:: -- 5102
	end -- 5102
	if ray.dy < 0 then -- 5105
		local t = -ray.y / ray.dy -- 5106
		if t >= 0 and (best < 0 or t < best) then -- 5107
			best = t -- 5108
			bestBox = nil -- 5109
		end -- 5109
	end -- 5109
	return {t = best, box = bestBox} -- 5112
end -- 5088
function Play.prototype.dropFor(self, e) -- 5116
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 5117
		return -- 5118
	end -- 5118
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 5120
		return -- 5121
	end -- 5121
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 5123
	local ____self_pickups_69 = self.pickups -- 5124
	____self_pickups_69[#____self_pickups_69 + 1] = { -- 5124
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 5125
		kind = e.drop, -- 5125
		x = e.x, -- 5125
		y = e.y, -- 5125
		depth = e.depth, -- 5126
		label = label .. " ×1" -- 5126
	} -- 5126
	self:log("掉落 " .. label) -- 5128
end -- 5116
function Play.prototype.damageProp(self, b, amount) -- 5132
	if b.breakable == nil or b.broken == true then -- 5133
		return -- 5134
	end -- 5134
	local ____b_breakable_70, ____hp_71 = b.breakable, "hp" -- 5136
	____b_breakable_70[____hp_71] = ____b_breakable_70[____hp_71] - amount -- 5136
	if b.breakable.hp > 0 then -- 5137
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 5138
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 5139
		return -- 5140
	end -- 5140
	b.broken = true -- 5142
	for ____, other in ipairs(self.boxes) do -- 5143
		if other.id ~= nil and other.id == b.id then -- 5144
			other.broken = true -- 5145
		end -- 5145
	end -- 5145
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 5148
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 5149
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 5150
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 5151
end -- 5132
function Play.prototype.slideDepth(self, a, distance) -- 5155
	a.depth = self:limitDepth(a, a.depth + distance) -- 5156
end -- 5155
function Play.prototype.limitDepth(self, a, target) -- 5159
	local road = self.room.depth -- 5160
	if road == nil or target == a.depth then -- 5161
		return a.depth -- 5162
	end -- 5162
	local next = math.max( -- 5164
		road.min, -- 5164
		math.min(road.max, target) -- 5164
	) -- 5164
	local half = a.w / 2 -- 5165
	for ____, b in ipairs(self.boxes) do -- 5166
		do -- 5166
			local footprint = b.depth -- 5167
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5168
				goto __continue877 -- 5172
			end -- 5172
			local front = footprint.min - ACTOR_DEPTH_HALF -- 5174
			local back = footprint.max + ACTOR_DEPTH_HALF -- 5175
			if a.depth <= front and next > front then -- 5176
				next = front -- 5177
			elseif a.depth >= back and next < back then -- 5178
				next = back -- 5179
			end -- 5179
		end -- 5179
		::__continue877:: -- 5179
	end -- 5179
	return next -- 5182
end -- 5159
function Play.prototype.slideX(self, a, dx) -- 5186
	local nx = a.x + dx -- 5187
	local half = a.w / 2 -- 5188
	local room = self.room -- 5189
	nx = math.max( -- 5190
		room.minX + half, -- 5190
		math.min(room.maxX - half, nx) -- 5190
	) -- 5190
	local i = 0 -- 5191
	do -- 5191
		i = 0 -- 5192
		while i < #self.boxes do -- 5192
			do -- 5192
				local b = self.boxes[i + 1] -- 5193
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5194
					goto __continue884 -- 5195
				end -- 5195
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5197
					goto __continue884 -- 5198
				end -- 5198
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5200
					goto __continue884 -- 5201
				end -- 5201
				if nx + half > b.x0 and nx - half < b.x1 then -- 5203
					if a.x <= b.x0 then -- 5204
						nx = b.x0 - half -- 5205
					elseif a.x >= b.x1 then -- 5206
						nx = b.x1 + half -- 5207
					else -- 5207
						nx = a.x -- 5209
					end -- 5209
				end -- 5209
			end -- 5209
			::__continue884:: -- 5209
			i = i + 1 -- 5192
		end -- 5192
	end -- 5192
	if self.room.key == "outside" and not self.cartDocked and a.y < CART_CLEAR - 0.001 then -- 5215
		local bx0 = math.max(room.arch.x0, self.cartAxle - CART_HALF) -- 5216
		local bx1 = math.min(room.arch.x1, self.cartAxle + CART_HALF) -- 5217
		if bx1 > bx0 and nx + half > bx0 and nx - half < bx1 then -- 5218
			if a.x <= bx0 then -- 5219
				nx = bx0 - half -- 5220
			elseif a.x >= bx1 then -- 5221
				nx = bx1 + half -- 5222
			else -- 5222
				nx = a.x -- 5224
			end -- 5224
		end -- 5224
	end -- 5224
	local arch = room.arch -- 5232
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 5233
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 5234
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 5235
			if a.x <= arch.x0 then -- 5236
				nx = arch.x0 - half -- 5237
			elseif a.x >= arch.x1 then -- 5238
				nx = arch.x1 + half -- 5239
			end -- 5239
		end -- 5239
	end -- 5239
	a.x = nx -- 5243
end -- 5186
function Play.prototype.fallY(self, a, dt) -- 5247
	a.vy = a.vy - ____exports.GRAVITY * dt -- 5248
	if a.vy < -900 then -- 5249
		a.vy = -900 -- 5250
	end -- 5250
	local ny = a.y + a.vy * dt -- 5252
	local half = a.w / 2 -- 5253
	if a.vy <= 0 then -- 5254
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 5256
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 5257
		if ny <= ground then -- 5258
			ny = ground -- 5259
			a.vy = 0 -- 5260
			a.onGround = true -- 5261
		else -- 5261
			a.onGround = false -- 5263
		end -- 5263
	else -- 5263
		a.onGround = false -- 5266
		local i = 0 -- 5267
		do -- 5267
			i = 0 -- 5268
			while i < #self.boxes do -- 5268
				do -- 5268
					local b = self.boxes[i + 1] -- 5269
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5270
						goto __continue908 -- 5271
					end -- 5271
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5273
						goto __continue908 -- 5274
					end -- 5274
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 5276
						goto __continue908 -- 5277
					end -- 5277
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 5279
						ny = b.y0 - a.h -- 5280
						a.vy = 0 -- 5281
					end -- 5281
				end -- 5281
				::__continue908:: -- 5281
				i = i + 1 -- 5268
			end -- 5268
		end -- 5268
	end -- 5268
	a.y = ny -- 5285
end -- 5247
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 5289
	if depth == nil then -- 5289
		depth = 0 -- 5289
	end -- 5289
	local g = -9999 -- 5290
	local i = 0 -- 5291
	do -- 5291
		i = 0 -- 5292
		while i < #self.floors do -- 5292
			local f = self.floors[i + 1] -- 5293
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 5294
				g = f.y1 -- 5295
			end -- 5295
			i = i + 1 -- 5292
		end -- 5292
	end -- 5292
	do -- 5292
		i = 0 -- 5298
		while i < #self.boxes do -- 5298
			do -- 5298
				local b = self.boxes[i + 1] -- 5299
				if b.broken == true or b.hidden == true or b.soft == true then -- 5300
					goto __continue918 -- 5301
				end -- 5301
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 5303
					g = b.y1 -- 5305
				end -- 5305
			end -- 5305
			::__continue918:: -- 5305
			i = i + 1 -- 5298
		end -- 5298
	end -- 5298
	return g -- 5308
end -- 5289
function Play.prototype.updateCamera(self, dt) -- 5311
	local p = self.player -- 5312
	local tx = p.x + p.facing * 30 -- 5313
	local ty = p.y + CAM_LOOK_UP -- 5314
	local k = math.min(1, CAM_FOLLOW * dt) -- 5315
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 5316
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 5317
end -- 5311
function Play.prototype.clampCamera(self, w, h) -- 5321
	local room = self.room -- 5322
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 5323
	local spanX = room.maxX - room.minX -- 5324
	if spanX <= halfW * 2 then -- 5325
		self.cam.x = (room.minX + room.maxX) / 2 -- 5326
	else -- 5326
		self.cam.x = math.max( -- 5328
			room.minX + halfW, -- 5328
			math.min(room.maxX - halfW, self.cam.x) -- 5328
		) -- 5328
	end -- 5328
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 5331
	local spanY = room.height -- 5332
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 5333
	if spanY <= halfH * 2 then -- 5334
		self.cam.y = camY -- 5335
	else -- 5335
		self.cam.y = math.max( -- 5337
			camY, -- 5337
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 5337
		) -- 5337
	end -- 5337
end -- 5321
function Play.prototype.flashSet(self, text, t) -- 5341
	self.flash = text -- 5342
	self.flashT = t -- 5343
end -- 5341
function Play.prototype.statusText(self) -- 5347
	local p = self.player -- 5348
	local parts = {} -- 5349
	local who = self.childMode and "小满" or "周戍" -- 5350
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 5351
	if self.room.key == "prologue" then -- 5353
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5354
		if self.phase == "prologue-wake" then -- 5355
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 5356
		elseif self.phase == "prologue-shadow" then -- 5357
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 5358
		elseif self.phase == "prologue-escape" then -- 5359
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 5360
		elseif self.phase == "prologue-hide" then -- 5361
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 5362
		elseif self.phase == "prologue-wait" then -- 5363
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 5364
		elseif self.phase == "prologue-give" then -- 5365
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 5366
		else -- 5366
			parts[#parts + 1] = "跟随" -- 5368
		end -- 5368
		if self.paused then -- 5370
			parts[#parts + 1] = "已暂停" -- 5371
		end -- 5371
		return table.concat(parts, " · ") -- 5373
	end -- 5373
	if self.room.key == "street" then -- 5375
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5376
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5377
		if self.paused then -- 5378
			parts[#parts + 1] = "已暂停" -- 5379
		end -- 5379
		return table.concat(parts, " · ") -- 5381
	end -- 5381
	if self.room.key == "gate" then -- 5383
		local ____temp_72 -- 5384
		if self.room.story == nil then -- 5384
			____temp_72 = nil -- 5384
		else -- 5384
			____temp_72 = self.room.story.gate -- 5384
		end -- 5384
		local g = ____temp_72 -- 5384
		if g ~= nil then -- 5385
			parts[#parts + 1] = self:gateLabel() -- 5386
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 5387
				0, -- 5388
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 5388
			))) .. " 秒" -- 5388
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5389
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5390
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 5391
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 5392
			if self.gateFailCount > 0 then -- 5393
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 5394
			end -- 5394
			if self.flash ~= "" then -- 5396
				parts[#parts + 1] = self.flash -- 5397
			end -- 5397
		end -- 5397
		if self.paused then -- 5400
			parts[#parts + 1] = "已暂停" -- 5401
		end -- 5401
		return table.concat(parts, " · ") -- 5403
	end -- 5403
	if self.room.key == "forest" then -- 5405
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5406
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5407
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5408
		if self.caughtT > 0 then -- 5409
			parts[#parts + 1] = "复位中" -- 5410
		end -- 5410
		if self.paused then -- 5412
			parts[#parts + 1] = "已暂停" -- 5413
		end -- 5413
		return table.concat(parts, " · ") -- 5415
	end -- 5415
	if self.room.key == "tower" then -- 5417
		if self.phase == "tower-wait" then -- 5418
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5419
		elseif self.phase == "tower-knock" then -- 5420
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5421
		elseif self.phase == "tower-enter" then -- 5422
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5423
		elseif self.phase == "tower-desk" then -- 5424
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5425
		elseif self.phase == "tower-given" then -- 5426
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5427
		else -- 5427
			parts[#parts + 1] = "片尾" -- 5429
		end -- 5429
		if self.paused then -- 5431
			parts[#parts + 1] = "已暂停" -- 5432
		end -- 5432
		return table.concat(parts, " · ") -- 5434
	end -- 5434
	if self.room.key == "village" then -- 5436
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5437
		if self.hasBottle then -- 5438
			parts[#parts + 1] = "有瓶" -- 5439
		elseif self.bottleFly ~= nil then -- 5440
			parts[#parts + 1] = "瓶在飞" -- 5441
		else -- 5441
			parts[#parts + 1] = "空手" -- 5443
		end -- 5443
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5445
		if self.scavChase then -- 5446
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5447
		end -- 5447
		if self.passed then -- 5449
			parts[#parts + 1] = "已过通行线" -- 5450
		end -- 5450
		if self.paused then -- 5452
			parts[#parts + 1] = "已暂停" -- 5453
		end -- 5453
		return table.concat(parts, " · ") -- 5455
	end -- 5455
	local isChild = self.childMode -- 5458
	if isChild then -- 5459
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5460
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5461
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5462
	else -- 5462
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5464
		if p.rollT > 0 then -- 5465
			parts[#parts + 1] = "翻滚中" -- 5466
		end -- 5466
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5468
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5469
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5470
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5471
	end -- 5471
	if self.checkpoint >= 0 then -- 5473
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5474
	end -- 5474
	if self.paused then -- 5476
		parts[#parts + 1] = "已暂停" -- 5477
	end -- 5477
	return table.concat(parts, " · ") -- 5479
end -- 5347
function Play.prototype.aliveEnemies(self) -- 5483
	local n = 0 -- 5484
	local i = 0 -- 5485
	do -- 5485
		i = 0 -- 5486
		while i < #self.enemies do -- 5486
			if self.enemies[i + 1].alive then -- 5487
				n = n + 1 -- 5488
			end -- 5488
			i = i + 1 -- 5486
		end -- 5486
	end -- 5486
	return n -- 5491
end -- 5483
function Play.prototype.threatened(self) -- 5496
	do -- 5496
		local i = 0 -- 5497
		while i < #self.enemies do -- 5497
			local e = self.enemies[i + 1] -- 5498
			if e.alive and e.warnT > 0 then -- 5499
				return true -- 5500
			end -- 5500
			i = i + 1 -- 5497
		end -- 5497
	end -- 5497
	return false -- 5503
end -- 5496
function Play.prototype.gateSecondsLeft(self) -- 5506
	local ____temp_73 -- 5507
	if self.room.story == nil then -- 5507
		____temp_73 = nil -- 5507
	else -- 5507
		____temp_73 = self.room.story.gate -- 5507
	end -- 5507
	local g = ____temp_73 -- 5507
	if g == nil then -- 5508
		return 0 -- 5509
	end -- 5509
	return math.max( -- 5511
		0, -- 5511
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5511
	) -- 5511
end -- 5506
function Play.prototype.gateLabel(self) -- 5514
	if self.phase == "gate-idle" then -- 5515
		return "待就位" -- 5516
	end -- 5516
	if self.phase == "gate-hold" then -- 5518
		return "守点中" -- 5519
	end -- 5519
	if self.phase == "gate-send" then -- 5521
		return "送别" -- 5522
	end -- 5522
	if self.phase == "gate-count" then -- 5524
		return "数数 " .. tostring(self.countTick) -- 5525
	end -- 5525
	return "她走" -- 5527
end -- 5514
function Play.prototype.dogLabel(self) -- 5531
	if self.dogState == "ear" then -- 5532
		return "转耳" -- 5533
	end -- 5533
	if self.dogState == "chase" then -- 5535
		return "追" -- 5536
	end -- 5536
	if self.dogState == "sniff" then -- 5538
		return "停" -- 5539
	end -- 5539
	if self.dogState == "back" then -- 5541
		return "回线" -- 5542
	end -- 5542
	return "巡逻" -- 5544
end -- 5531
function Play.prototype.doorXOf(self) -- 5547
	local ____temp_74 -- 5548
	if self.room.story == nil then -- 5548
		____temp_74 = nil -- 5548
	else -- 5548
		____temp_74 = self.room.story.tower -- 5548
	end -- 5548
	local t = ____temp_74 -- 5548
	return t == nil and 0 or t.doorX -- 5549
end -- 5547
function Play.prototype.scavLabel(self) -- 5553
	if self.scavState == "chase" then -- 5554
		return "追" -- 5555
	end -- 5555
	if self.scavState == "turn" then -- 5557
		return "转头" -- 5558
	end -- 5558
	if self.scavState == "walk" then -- 5560
		return "赶来" -- 5561
	end -- 5561
	if self.scavState == "stall" then -- 5563
		return "停住" -- 5564
	end -- 5564
	if self.scavState == "back" then -- 5566
		return "回位" -- 5567
	end -- 5567
	return "巡逻" -- 5569
end -- 5553
function Play.prototype.hintText(self) -- 5573
	if self.paused then -- 5574
		return "Esc 继续 · R 重置" -- 5575
	end -- 5575
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5579
		if self:threatened() then -- 5580
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5581
		end -- 5581
		if self.coverHug then -- 5583
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5584
		end -- 5584
		if self.coverNear then -- 5586
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5587
		end -- 5587
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5589
	end -- 5589
	if self.flash ~= "" then -- 5591
		return self.flash -- 5592
	end -- 5592
	if self.room.key == "prologue" then -- 5594
		if self.phase == "prologue-wake" then -- 5595
			return "父亲在门外唤 · 小满睁眼" -- 5596
		end -- 5596
		if self.phase == "prologue-shadow" then -- 5598
			return "墙上两道人影 · 碗滚到脚边" -- 5599
		end -- 5599
		if self.phase == "prologue-escape" then -- 5601
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5602
		end -- 5602
		if self.phase == "prologue-hide" then -- 5604
			return "柜门合上 · 屏住呼吸" -- 5605
		end -- 5605
		if self.phase == "prologue-wait" then -- 5607
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5608
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5609
		end -- 5609
		if self.phase == "prologue-give" then -- 5611
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 5612
		end -- 5612
		return "她跟着你了 · 两人一起走到门口 680" -- 5614
	end -- 5614
	if self.room.key == "street" then -- 5616
		if self:aliveEnemies() > 0 then -- 5617
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5618
		end -- 5618
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5620
	end -- 5620
	if self.room.key == "gate" then -- 5622
		local ____temp_75 -- 5623
		if self.room.story == nil then -- 5623
			____temp_75 = nil -- 5623
		else -- 5623
			____temp_75 = self.room.story.gate -- 5623
		end -- 5623
		local g = ____temp_75 -- 5623
		if g ~= nil then -- 5624
			if self.phase == "gate-idle" then -- 5625
				if self.gateNeedConfirm then -- 5626
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5627
				end -- 5627
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5629
			end -- 5629
			if self.phase == "gate-hold" then -- 5631
				if self.coveredFlash > 0 then -- 5632
					return "掩体挡下了这一枪 · 别露头" -- 5633
				end -- 5633
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5635
			end -- 5635
			if self.phase == "gate-send" then -- 5637
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5638
			end -- 5638
			if self.phase == "gate-count" then -- 5640
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5641
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5642
				end -- 5642
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5644
			end -- 5644
			return "她自己走 · 跟着出城门 1120" -- 5646
		end -- 5646
	end -- 5646
	if self.room.key == "forest" then -- 5649
		if self.dogState == "chase" then -- 5650
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5651
		end -- 5651
		if self.dogState == "ear" then -- 5653
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5654
		end -- 5654
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5656
	end -- 5656
	if self.room.key == "tower" then -- 5658
		if self.phase == "tower-wait" then -- 5659
			return "走到门前 445 点一次 E 敲两下" -- 5660
		end -- 5660
		if self.phase == "tower-knock" then -- 5662
			return "敲两下 · 等门开" -- 5663
		end -- 5663
		if self.phase == "tower-given" then -- 5665
			return "递交针套和纸条 · 看登记簿最后一行" -- 5666
		end -- 5666
		return "片尾 · 点 E 再玩一次，回到序章" -- 5668
	end -- 5668
	if self.room.key == "village" then -- 5670
		if self.bottleFly ~= nil then -- 5671
			return "等瓶子落地 · 触地才发声" -- 5672
		end -- 5672
		if self.hasBottle then -- 5674
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5675
		end -- 5675
		if self.passed then -- 5677
			return "已过第一院 · R 重置可再来一遍" -- 5678
		end -- 5678
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5680
	end -- 5680
	if self.room.key == "outside" then -- 5682
		if self.focusCart then -- 5683
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5684
		end -- 5684
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5686
	end -- 5686
	if self.escort.state == "frozen" then -- 5688
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5689
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5690
		end -- 5690
		return "小满吓住了 · 走过去，靠近再点 E" -- 5692
	end -- 5692
	if self.escort.state == "calming" then -- 5694
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5695
	end -- 5695
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5697
end -- 5573
function Play.prototype.draw(self, draw, w, h) -- 5702
	self.viewW = w -- 5703
	self.viewH = h -- 5704
	self.view = ____exports.computeViewport(w, h) -- 5705
	self:clampCamera(w, h) -- 5706
	draw:clear() -- 5707
	draw:drawRect( -- 5709
		Rect(0, 0, w, h), -- 5709
		BG_VOID -- 5709
	) -- 5709
	local box = self:canvasRect(w, h) -- 5710
	draw:drawRect(box, BG_FAR) -- 5711
	draw:drawRect( -- 5712
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 5712
		BG_MID -- 5712
	) -- 5712
	self:drawFloors(draw, w, h) -- 5714
	self:drawSolids(draw, w, h) -- 5715
	self:drawZones(draw, w, h) -- 5716
	self:drawArch(draw, w, h) -- 5717
	self:drawCart(draw, w, h) -- 5718
	self:drawCampaignProps(draw, w, h) -- 5719
	self:drawActors(draw, w, h) -- 5720
	self:drawTrace(draw, w, h) -- 5721
	self:drawAim(draw, w, h) -- 5722
end -- 5702
function Play.prototype.canvasRect(self, w, h) -- 5726
	local v = self.view -- 5727
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 5728
end -- 5726
function Play.prototype.px(self, n) -- 5732
	return n * self.view.zoom -- 5733
end -- 5732
function Play.prototype.sx(self, wx, w) -- 5737
	local v = self.view -- 5738
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 5739
	return v.ox + lx * v.zoom -- 5740
end -- 5737
function Play.prototype.sy(self, wy, h) -- 5744
	local v = self.view -- 5745
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 5746
	return v.oy + ly * v.zoom -- 5747
end -- 5744
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 5750
	local px0 = self:sx(x0, w) -- 5751
	local px1 = self:sx(x1, w) -- 5752
	local py0 = self:sy(y0, h) -- 5753
	local py1 = self:sy(y1, h) -- 5754
	if px1 <= px0 or py1 <= py0 then -- 5755
		return -- 5756
	end -- 5756
	draw:drawRect( -- 5758
		Rect(px0, py0, px1 - px0, py1 - py0), -- 5758
		color -- 5758
	) -- 5758
end -- 5750
function Play.prototype.drawFloors(self, draw, w, h) -- 5761
	local i = 0 -- 5762
	do -- 5762
		i = 0 -- 5763
		while i < #self.room.floors do -- 5763
			local f = self.room.floors[i + 1] -- 5764
			local ____temp_76 -- 5765
			if f.y == 0 then -- 5765
				____temp_76 = self.room.depth -- 5765
			else -- 5765
				____temp_76 = nil -- 5765
			end -- 5765
			local road = ____temp_76 -- 5765
			local y = self:sy(f.y + (road and road.min or 0), h) -- 5766
			local x0 = self:sx(f.x0, w) -- 5767
			local x1 = self:sx(f.x1, w) -- 5768
			local deck = self:px(5) -- 5769
			if road ~= nil then -- 5770
				local back = self:sy(f.y + road.max, h) -- 5771
				draw:drawRect( -- 5772
					Rect(x0, y, x1 - x0, back - y), -- 5772
					FLOOR_DECK, -- 5772
					self:px(1), -- 5772
					SOLID_EDGE -- 5772
				) -- 5772
			end -- 5772
			draw:drawRect( -- 5774
				Rect(x0, y - deck, x1 - x0, deck), -- 5774
				FLOOR_DECK -- 5774
			) -- 5774
			draw:drawSegment( -- 5775
				Vec2(x0, y), -- 5775
				Vec2(x1, y), -- 5775
				self:px(1), -- 5775
				GROUND -- 5775
			) -- 5775
			i = i + 1 -- 5763
		end -- 5763
	end -- 5763
end -- 5761
function Play.prototype.drawSolids(self, draw, w, h) -- 5779
	local i = 0 -- 5780
	do -- 5780
		i = 0 -- 5781
		while i < #self.boxes do -- 5781
			do -- 5781
				local b = self.boxes[i + 1] -- 5782
				if b.id == "braced_shield" or b.hidden == true then -- 5783
					goto __continue1049 -- 5784
				end -- 5784
				if b.broken == true then -- 5786
					if b.breakable ~= nil then -- 5788
						local gy = self:sy(b.y0, h) -- 5789
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 5790
						local k = 0 -- 5791
						do -- 5791
							k = 0 -- 5792
							while k < 3 do -- 5792
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 5793
								draw:drawSegment( -- 5794
									Vec2( -- 5794
										gx - self:px(4), -- 5794
										gy + self:px(k % 2) -- 5794
									), -- 5794
									Vec2( -- 5794
										gx + self:px(5), -- 5794
										gy + self:px(k % 2) -- 5794
									), -- 5794
									self:px(1), -- 5794
									rgb -- 5794
								) -- 5794
								k = k + 1 -- 5792
							end -- 5792
						end -- 5792
					end -- 5792
					goto __continue1049 -- 5797
				end -- 5797
				local ____opt_79 = b.depth -- 5799
				local front = ____opt_79 and ____opt_79.min or 0 -- 5799
				local ____opt_81 = b.depth -- 5800
				local back = ____opt_81 and ____opt_81.max or 0 -- 5800
				local fill = SOLID_FILL -- 5801
				local line = SOLID_EDGE -- 5802
				if b.soft == true then -- 5803
					fill = SOFT -- 5804
					line = SOFT_LINE -- 5805
				elseif b.breakable ~= nil then -- 5806
					line = DANGER_LINE -- 5807
					fill = Color(0.3, 0.24, 0.16, 1) -- 5808
				elseif b.interact ~= nil then -- 5809
					line = PASS_LINE -- 5810
				end -- 5810
				self:drawBox( -- 5812
					draw, -- 5812
					w, -- 5812
					h, -- 5812
					b.x0, -- 5812
					b.x1, -- 5812
					b.y0 + front, -- 5812
					b.y1 + back, -- 5812
					fill -- 5812
				) -- 5812
				draw:drawSegment( -- 5813
					Vec2( -- 5813
						self:sx(b.x0, w), -- 5813
						self:sy(b.y1 + front, h) -- 5813
					), -- 5813
					Vec2( -- 5814
						self:sx(b.x1, w), -- 5814
						self:sy(b.y1 + front, h) -- 5814
					), -- 5814
					self:px(1), -- 5814
					line -- 5814
				) -- 5814
				if b.breakable ~= nil then -- 5816
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 5817
					local cyp = self:sy(b.y1 + front, h) -- 5818
					draw:drawSegment( -- 5819
						Vec2( -- 5819
							cxp - self:px(4), -- 5819
							cyp + self:px(1) -- 5819
						), -- 5819
						Vec2( -- 5819
							cxp + self:px(3), -- 5819
							cyp + self:px(5) -- 5819
						), -- 5819
						self:px(1), -- 5819
						line -- 5819
					) -- 5819
				end -- 5819
			end -- 5819
			::__continue1049:: -- 5819
			i = i + 1 -- 5781
		end -- 5781
	end -- 5781
end -- 5779
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 5825
	local i = 0 -- 5826
	do -- 5826
		i = 0 -- 5827
		while i < #self.pickups do -- 5827
			do -- 5827
				local pk = self.pickups[i + 1] -- 5828
				if self.run.taken[pk.id] == true then -- 5829
					goto __continue1061 -- 5830
				end -- 5830
				local gy = pk.y + (pk.depth or 0) -- 5832
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 5833
				draw:drawRect( -- 5834
					Rect( -- 5834
						self:sx(pk.x - 5, w), -- 5834
						self:sy(gy + 12 + bob, h), -- 5834
						self:px(10), -- 5834
						self:px(10) -- 5834
					), -- 5834
					Color(0.84, 0.7, 0.3, 1) -- 5835
				) -- 5835
				draw:drawSegment( -- 5836
					Vec2( -- 5836
						self:sx(pk.x - 5, w), -- 5836
						self:sy(gy + 12 + bob, h) -- 5836
					), -- 5836
					Vec2( -- 5837
						self:sx(pk.x + 5, w), -- 5837
						self:sy(gy + 12 + bob, h) -- 5837
					), -- 5837
					self:px(1), -- 5837
					Color(0.95, 0.86, 0.52, 1) -- 5837
				) -- 5837
			end -- 5837
			::__continue1061:: -- 5837
			i = i + 1 -- 5827
		end -- 5827
	end -- 5827
	if self.bracedShield ~= nil then -- 5839
		local sh = self.bracedShield -- 5840
		draw:drawRect( -- 5841
			Rect( -- 5841
				self:sx(sh.x - sh.w / 2, w), -- 5841
				self:sy(sh.y, h), -- 5841
				self:px(sh.w), -- 5841
				self:px(sh.h) -- 5841
			), -- 5841
			Color(0.42, 0.4, 0.34, 1) -- 5842
		) -- 5842
		draw:drawSegment( -- 5843
			Vec2( -- 5843
				self:sx(sh.x - sh.w / 2, w), -- 5843
				self:sy(sh.y + sh.h, h) -- 5843
			), -- 5843
			Vec2( -- 5844
				self:sx(sh.x + sh.w / 2, w), -- 5844
				self:sy(sh.y + sh.h, h) -- 5844
			), -- 5844
			self:px(1), -- 5844
			Color(0.74, 0.72, 0.62, 1) -- 5844
		) -- 5844
	end -- 5844
end -- 5825
function Play.prototype.drawZones(self, draw, w, h) -- 5848
	local i = 0 -- 5849
	do -- 5849
		i = 0 -- 5850
		while i < #self.room.zones do -- 5850
			local z = self.room.zones[i + 1] -- 5851
			local fill = DANGER -- 5852
			local line = DANGER_LINE -- 5853
			if z.tint == 2 then -- 5854
				fill = SOFT -- 5855
				line = SOFT_LINE -- 5856
			elseif z.tint == 3 then -- 5857
				fill = BRICK -- 5858
				line = BRICK_LINE -- 5859
			elseif z.tint == 4 then -- 5860
				fill = PASS -- 5861
				line = PASS_LINE -- 5862
			end -- 5862
			self:drawBox( -- 5864
				draw, -- 5864
				w, -- 5864
				h, -- 5864
				z.x0, -- 5864
				z.x1, -- 5864
				z.y, -- 5864
				z.y + z.h, -- 5864
				fill -- 5864
			) -- 5864
			draw:drawSegment( -- 5865
				Vec2( -- 5865
					self:sx(z.x0, w), -- 5865
					self:sy(z.y, h) -- 5865
				), -- 5865
				Vec2( -- 5865
					self:sx(z.x0, w), -- 5865
					self:sy(z.y + z.h, h) -- 5865
				), -- 5865
				self:px(1), -- 5865
				line -- 5865
			) -- 5865
			draw:drawSegment( -- 5866
				Vec2( -- 5866
					self:sx(z.x1, w), -- 5866
					self:sy(z.y, h) -- 5866
				), -- 5866
				Vec2( -- 5866
					self:sx(z.x1, w), -- 5866
					self:sy(z.y + z.h, h) -- 5866
				), -- 5866
				self:px(1), -- 5866
				line -- 5866
			) -- 5866
			i = i + 1 -- 5850
		end -- 5850
	end -- 5850
end -- 5848
function Play.prototype.drawArch(self, draw, w, h) -- 5870
	local a = self.room.arch -- 5871
	if a.h <= 0 then -- 5872
		return -- 5873
	end -- 5873
	self:drawBox( -- 5875
		draw, -- 5875
		w, -- 5875
		h, -- 5875
		a.x0, -- 5875
		a.x1, -- 5875
		a.y, -- 5875
		a.y + a.h, -- 5875
		HOLE_FILL -- 5875
	) -- 5875
	draw:drawSegment( -- 5876
		Vec2( -- 5876
			self:sx(a.x0, w), -- 5876
			self:sy(a.y + a.h, h) -- 5876
		), -- 5876
		Vec2( -- 5876
			self:sx(a.x1, w), -- 5876
			self:sy(a.y + a.h, h) -- 5876
		), -- 5876
		self:px(1), -- 5876
		SOLID_EDGE -- 5876
	) -- 5876
	draw:drawSegment( -- 5877
		Vec2( -- 5877
			self:sx(a.x0, w), -- 5877
			self:sy(a.y, h) -- 5877
		), -- 5877
		Vec2( -- 5877
			self:sx(a.x0, w), -- 5877
			self:sy(a.y + a.h, h) -- 5877
		), -- 5877
		self:px(1), -- 5877
		SOLID_EDGE -- 5877
	) -- 5877
	draw:drawSegment( -- 5878
		Vec2( -- 5878
			self:sx(a.x1, w), -- 5878
			self:sy(a.y, h) -- 5878
		), -- 5878
		Vec2( -- 5878
			self:sx(a.x1, w), -- 5878
			self:sy(a.y + a.h, h) -- 5878
		), -- 5878
		self:px(1), -- 5878
		SOLID_EDGE -- 5878
	) -- 5878
end -- 5870
function Play.prototype.drawCart(self, draw, w, h) -- 5881
	local c = self.room.cart -- 5882
	if c.bodyW <= 0 then -- 5883
		return -- 5884
	end -- 5884
	drawCartShape( -- 5886
		draw, -- 5886
		self, -- 5886
		w, -- 5886
		h, -- 5886
		c, -- 5886
		self.cartAxle -- 5886
	) -- 5886
	draw:drawRect( -- 5887
		Rect( -- 5887
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 5887
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 5887
			self:px(2), -- 5887
			self:px(40) -- 5887
		), -- 5887
		STAND -- 5887
	) -- 5887
end -- 5881
function Play.prototype.drawActors(self, draw, w, h) -- 5890
	local p = self.player -- 5891
	local isChild = self.childMode -- 5892
	local footY = p.y + p.depth * DEPTH_Y_SCALE -- 5893
	if p.covered then -- 5895
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 5896
		draw:drawSegment( -- 5897
			Vec2( -- 5897
				self:sx(edge, w), -- 5897
				self:sy(footY + 8, h) -- 5897
			), -- 5897
			Vec2( -- 5897
				self:sx(edge, w), -- 5897
				self:sy(footY + p.h * 0.62, h) -- 5897
			), -- 5897
			self:px(2), -- 5897
			STAND -- 5897
		) -- 5897
		draw:drawSegment( -- 5899
			Vec2( -- 5899
				self:sx(p.x - 8, w), -- 5899
				self:sy(footY + p.h + 3, h) -- 5899
			), -- 5899
			Vec2( -- 5899
				self:sx(p.x + 8, w), -- 5899
				self:sy(footY + p.h + 3, h) -- 5899
			), -- 5899
			self:px(2), -- 5899
			STAND -- 5899
		) -- 5899
	elseif self.coverNear and not isChild then -- 5900
		draw:drawRect( -- 5902
			Rect( -- 5902
				self:sx(p.x - 3, w), -- 5902
				self:sy(footY + 1, h), -- 5902
				self:px(3), -- 5902
				self:px(3) -- 5902
			), -- 5902
			STAND -- 5902
		) -- 5902
	end -- 5902
	drawFigure( -- 5904
		draw, -- 5904
		self, -- 5904
		w, -- 5904
		h, -- 5904
		p, -- 5904
		isChild and CHILD_BODY or SOLDIER_BODY, -- 5904
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 5904
	) -- 5904
	local q = self.partner -- 5905
	if q.alive then -- 5906
		local childPartner = q.w == CHILD_W -- 5907
		drawFigure( -- 5908
			draw, -- 5908
			self, -- 5908
			w, -- 5908
			h, -- 5908
			q, -- 5908
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 5908
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 5908
		) -- 5908
	end -- 5908
	local i = 0 -- 5910
	do -- 5910
		i = 0 -- 5911
		while i < #self.enemies do -- 5911
			local e = self.enemies[i + 1] -- 5912
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 5913
			local enemyY = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 5914
			self:drawBox( -- 5915
				draw, -- 5915
				w, -- 5915
				h, -- 5915
				e.x - e.w / 2, -- 5915
				e.x + e.w / 2, -- 5915
				enemyY, -- 5915
				enemyY + e.h, -- 5915
				col -- 5915
			) -- 5915
			if e.alive then -- 5916
				local ef = p.x >= e.x and 1 or -1 -- 5917
				if e.kind == "shield" then -- 5918
					local sh = (e.shieldHp or 0) > 0 -- 5919
					draw:drawRect( -- 5920
						Rect( -- 5920
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 5920
							self:sy(enemyY, h), -- 5920
							self:px(6), -- 5920
							self:px(64) -- 5920
						), -- 5920
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 5921
					) -- 5921
				elseif e.kind == "breaker" then -- 5922
					draw:drawSegment( -- 5923
						Vec2( -- 5923
							self:sx(e.x + ef * 12, w), -- 5923
							self:sy(enemyY + 8, h) -- 5923
						), -- 5923
						Vec2( -- 5924
							self:sx(e.x + ef * 22, w), -- 5924
							self:sy(enemyY + 46, h) -- 5924
						), -- 5924
						self:px(3), -- 5924
						Color(0.5, 0.36, 0.22, 1) -- 5924
					) -- 5924
				end -- 5924
			end -- 5924
			if e.alive and e.warnT > 0 then -- 5928
				local gunX = self:sx(e.x, w) -- 5929
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 5930
				local aimX = self:sx(p.x, w) -- 5931
				local aimY = self:sy(footY + p.h * 0.55, h) -- 5932
				local seg = 8 -- 5933
				local s = 0 -- 5934
				do -- 5934
					s = 0 -- 5935
					while s < seg do -- 5935
						local t0 = s / seg -- 5936
						local t1 = (s + 1) / seg -- 5937
						draw:drawSegment( -- 5938
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 5939
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 5940
							self:px(1), -- 5941
							DANGER -- 5941
						) -- 5941
						s = s + 2 -- 5935
					end -- 5935
				end -- 5935
			end -- 5935
			i = i + 1 -- 5911
		end -- 5911
	end -- 5911
	local k = 0 -- 5946
	do -- 5946
		k = 0 -- 5947
		while k < #self.room.marks do -- 5947
			do -- 5947
				local m = self.room.marks[k + 1] -- 5948
				if m.kind ~= 0 then -- 5949
					goto __continue1087 -- 5950
				end -- 5950
				local on = self.checkpoint == m.x -- 5952
				local x = self:sx(m.x, w) -- 5953
				local y = self:sy(m.y, h) -- 5954
				draw:drawSegment( -- 5955
					Vec2(x, y), -- 5955
					Vec2( -- 5955
						x, -- 5955
						y + self:px(35) -- 5955
					), -- 5955
					self:px(1), -- 5955
					on and CHECK or INK_DIM -- 5955
				) -- 5955
				draw:drawDot( -- 5956
					Vec2( -- 5956
						x, -- 5956
						y + self:px(35) -- 5956
					), -- 5956
					self:px(2), -- 5956
					on and CHECK or INK_DIM -- 5956
				) -- 5956
			end -- 5956
			::__continue1087:: -- 5956
			k = k + 1 -- 5947
		end -- 5947
	end -- 5947
	local j = 0 -- 5960
	do -- 5960
		j = 0 -- 5961
		while j < #self.room.marks do -- 5961
			do -- 5961
				local m = self.room.marks[j + 1] -- 5962
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 5963
					goto __continue1090 -- 5964
				end -- 5964
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 5966
					goto __continue1090 -- 5968
				end -- 5968
				local col = STAND -- 5970
				if m.kind == 4 then -- 5971
					col = PASS_LINE -- 5972
				elseif m.kind == 5 then -- 5973
					col = BRICK_LINE -- 5974
				end -- 5974
				local mx = self:sx(m.x, w) -- 5976
				local my = self:sy(m.y, h) -- 5977
				draw:drawSegment( -- 5978
					Vec2(mx, my), -- 5978
					Vec2( -- 5978
						mx, -- 5978
						my + self:px(24) -- 5978
					), -- 5978
					self:px(1), -- 5978
					col -- 5978
				) -- 5978
			end -- 5978
			::__continue1090:: -- 5978
			j = j + 1 -- 5961
		end -- 5961
	end -- 5961
	local t = 0 -- 5981
	do -- 5981
		t = 0 -- 5982
		while t < #self.room.marks do -- 5982
			do -- 5982
				local m = self.room.marks[t + 1] -- 5983
				if m.kind ~= 6 then -- 5984
					goto __continue1096 -- 5985
				end -- 5985
				local mx = self:sx(m.x, w) -- 5987
				local my = self:sy(m.y, h) -- 5988
				draw:drawSegment( -- 5989
					Vec2(mx, my), -- 5989
					Vec2( -- 5989
						mx, -- 5989
						my + self:px(30) -- 5989
					), -- 5989
					self:px(1), -- 5989
					INK_DIM -- 5989
				) -- 5989
				self:drawBox( -- 5990
					draw, -- 5990
					w, -- 5990
					h, -- 5990
					m.x - 5, -- 5990
					m.x + 5, -- 5990
					m.y + 30, -- 5990
					m.y + 40, -- 5990
					CHECK -- 5990
				) -- 5990
			end -- 5990
			::__continue1096:: -- 5990
			t = t + 1 -- 5982
		end -- 5982
	end -- 5982
	if self.room.key == "village" then -- 5992
		self:drawVillage(draw, w, h) -- 5993
	end -- 5993
	if self.room.key == "forest" then -- 5995
		self:drawDog(draw, w, h) -- 5996
	end -- 5996
end -- 5890
function Play.prototype.drawDog(self, draw, w, h) -- 6001
	local x = self.dogX -- 6002
	self:drawBox( -- 6003
		draw, -- 6003
		w, -- 6003
		h, -- 6003
		x - 14, -- 6003
		x + 14, -- 6003
		0, -- 6003
		20, -- 6003
		SCAV_BODY -- 6003
	) -- 6003
	self:drawBox( -- 6004
		draw, -- 6004
		w, -- 6004
		h, -- 6004
		x - 10, -- 6004
		x - 2, -- 6004
		20, -- 6004
		30, -- 6004
		SCAV_BODY -- 6004
	) -- 6004
	self:drawBox( -- 6005
		draw, -- 6005
		w, -- 6005
		h, -- 6005
		x + 2, -- 6005
		x + 10, -- 6005
		20, -- 6005
		30, -- 6005
		SCAV_HEAD -- 6005
	) -- 6005
	if self.dogState == "ear" or self.dogState == "chase" then -- 6006
		draw:drawSegment( -- 6007
			Vec2( -- 6007
				self:sx(x, w), -- 6007
				self:sy(30, h) -- 6007
			), -- 6007
			Vec2( -- 6008
				self:sx(x, w), -- 6008
				self:sy(40, h) -- 6008
			), -- 6008
			self:px(1), -- 6008
			DANGER -- 6008
		) -- 6008
	end -- 6008
end -- 6001
function Play.prototype.drawVillage(self, draw, w, h) -- 6013
	local bottle = self.room.bottle -- 6014
	if bottle ~= nil then -- 6015
		self:drawBox( -- 6016
			draw, -- 6016
			w, -- 6016
			h, -- 6016
			bottle.x - 14, -- 6016
			bottle.x + 14, -- 6016
			0, -- 6016
			64, -- 6016
			SOLID_FILL -- 6016
		) -- 6016
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 6017
			self:drawBottle( -- 6018
				draw, -- 6018
				w, -- 6018
				h, -- 6018
				bottle.x, -- 6018
				64 -- 6018
			) -- 6018
		end -- 6018
	end -- 6018
	self:drawBox( -- 6022
		draw, -- 6022
		w, -- 6022
		h, -- 6022
		300, -- 6022
		420, -- 6022
		44, -- 6022
		50, -- 6022
		FLOOR_DECK -- 6022
	) -- 6022
	self:drawBox( -- 6023
		draw, -- 6023
		w, -- 6023
		h, -- 6023
		300, -- 6023
		306, -- 6023
		0, -- 6023
		44, -- 6023
		FLOOR_DECK -- 6023
	) -- 6023
	self:drawBox( -- 6024
		draw, -- 6024
		w, -- 6024
		h, -- 6024
		414, -- 6024
		420, -- 6024
		0, -- 6024
		44, -- 6024
		FLOOR_DECK -- 6024
	) -- 6024
	local s = self.room.scavenger -- 6026
	if s ~= nil then -- 6027
		local sx0 = self.scavX -- 6028
		self:drawBox( -- 6029
			draw, -- 6029
			w, -- 6029
			h, -- 6029
			sx0 - 12, -- 6029
			sx0 + 12, -- 6029
			0, -- 6029
			s.h - 14, -- 6029
			SCAV_BODY -- 6029
		) -- 6029
		self:drawBox( -- 6030
			draw, -- 6030
			w, -- 6030
			h, -- 6030
			sx0 - 7, -- 6030
			sx0 + 7, -- 6030
			s.h - 14, -- 6030
			s.h, -- 6030
			SCAV_HEAD -- 6030
		) -- 6030
		if self.scavState == "turn" then -- 6031
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 6032
			draw:drawSegment( -- 6033
				Vec2( -- 6033
					self:sx(sx0, w), -- 6033
					self:sy(s.h - 6, h) -- 6033
				), -- 6033
				Vec2( -- 6033
					self:sx(fx, w), -- 6033
					self:sy(s.h - 6, h) -- 6033
				), -- 6033
				self:px(1), -- 6033
				INK -- 6033
			) -- 6033
		end -- 6033
	end -- 6033
	if self.hasBottle then -- 6037
		local p = self.player -- 6038
		self:drawBottle( -- 6039
			draw, -- 6039
			w, -- 6039
			h, -- 6039
			p.x + p.facing * 10, -- 6039
			p.y + p.h * 0.62 -- 6039
		) -- 6039
	end -- 6039
	if self.bottleFly ~= nil then -- 6041
		self:drawBottle( -- 6042
			draw, -- 6042
			w, -- 6042
			h, -- 6042
			self.bottleFly.x, -- 6042
			self.bottleFly.y -- 6042
		) -- 6042
	end -- 6042
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 6044
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 6045
		draw:drawCircle( -- 6046
			Vec2( -- 6046
				self:sx(self.bottleLandX, w), -- 6046
				self:sy(0, h) -- 6046
			), -- 6046
			self:px(r / ____exports.UNITS_PER_PX), -- 6046
			BRICK_LINE -- 6046
		) -- 6046
	end -- 6046
end -- 6013
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 6050
	self:drawBox( -- 6051
		draw, -- 6051
		w, -- 6051
		h, -- 6051
		x - 3, -- 6051
		x + 3, -- 6051
		y - 10, -- 6051
		y, -- 6051
		BOTTLE -- 6051
	) -- 6051
end -- 6050
function Play.prototype.drawTrace(self, draw, w, h) -- 6054
	local t = self.trace -- 6055
	if t == nil or self.traceT <= 0 then -- 6056
		return -- 6057
	end -- 6057
	draw:drawSegment( -- 6059
		Vec2( -- 6060
			self:sx(t.x0, w), -- 6060
			self:sy(t.y0, h) -- 6060
		), -- 6060
		Vec2( -- 6061
			self:sx(t.x1, w), -- 6061
			self:sy(t.y1, h) -- 6061
		), -- 6061
		self:px(1), -- 6062
		t.hit and AIM_HIT or INK_DIM -- 6062
	) -- 6062
end -- 6054
function Play.prototype.drawAim(self, draw, w, h) -- 6065
	local v = self.view -- 6067
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 6068
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 6069
	local dot = self:px(1) -- 6070
	local arm = self:px(3) -- 6071
	local gap = self:px(1) -- 6072
	draw:drawSegment( -- 6073
		Vec2(gx - arm - gap, gy), -- 6073
		Vec2(gx - gap, gy), -- 6073
		dot / 2, -- 6073
		AIM -- 6073
	) -- 6073
	draw:drawSegment( -- 6074
		Vec2(gx + gap, gy), -- 6074
		Vec2(gx + arm + gap, gy), -- 6074
		dot / 2, -- 6074
		AIM -- 6074
	) -- 6074
	draw:drawSegment( -- 6075
		Vec2(gx, gy - arm - gap), -- 6075
		Vec2(gx, gy - gap), -- 6075
		dot / 2, -- 6075
		AIM -- 6075
	) -- 6075
	draw:drawSegment( -- 6076
		Vec2(gx, gy + gap), -- 6076
		Vec2(gx, gy + arm + gap), -- 6076
		dot / 2, -- 6076
		AIM -- 6076
	) -- 6076
	if self.room.key == "village" and self.hasBottle then -- 6079
		local p = self.player -- 6080
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 6082
		local dir = ____end.x >= p.x and 1 or -1 -- 6083
		local x0 = p.x + dir * 10 -- 6084
		local y0 = p.y + p.h * 0.7 -- 6085
		local T = BOTTLE_FLY_TIME -- 6086
		local vx = (____end.x - x0) / T -- 6087
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 6088
		local pxr = x0 -- 6089
		local pyr = y0 -- 6090
		local t = 1 -- 6091
		do -- 6091
			t = 1 -- 6092
			while t <= 12 do -- 6092
				local tt = t / 12 * T -- 6093
				local nx = x0 + vx * tt -- 6094
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 6095
				draw:drawSegment( -- 6096
					Vec2( -- 6096
						self:sx(pxr, w), -- 6096
						self:sy(pyr, h) -- 6096
					), -- 6096
					Vec2( -- 6096
						self:sx(nx, w), -- 6096
						self:sy(ny, h) -- 6096
					), -- 6096
					self:px(1) / 2, -- 6096
					BOTTLE -- 6096
				) -- 6096
				pxr = nx -- 6097
				pyr = ny -- 6098
				t = t + 1 -- 6092
			end -- 6092
		end -- 6092
		draw:drawCircle( -- 6100
			Vec2( -- 6100
				self:sx(____end.x, w), -- 6100
				self:sy(____end.y + 2, h) -- 6100
			), -- 6100
			self:px(2), -- 6100
			BOTTLE -- 6100
		) -- 6100
	end -- 6100
end -- 6065
return ____exports -- 6065
