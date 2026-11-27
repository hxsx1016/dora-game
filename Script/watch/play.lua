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
local makeActor, drawFigure, rayInterval, hitBox, drawCartShape, CHILD_W, CHILD_H, SOLDIER_W, SOLDIER_H, INK, CART_FILL, CLOTH -- 6362
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
function makeActor(room, index) -- 6362
	local sp = room.spawns -- 6363
	if index < 0 or index >= #sp then -- 6364
		return { -- 6365
			x = 0, -- 6365
			y = 0, -- 6365
			depth = 0, -- 6365
			depthSpeed = 0, -- 6365
			vx = 0, -- 6365
			vy = 0, -- 6365
			w = CHILD_W, -- 6365
			h = CHILD_H, -- 6365
			onGround = true, -- 6365
			facing = 1, -- 6365
			crouch = false, -- 6365
			rollT = 0, -- 6365
			covered = false, -- 6365
			alive = false -- 6365
		} -- 6365
	end -- 6365
	local s = sp[index + 1] -- 6367
	local child = s.h < SOLDIER_H -- 6368
	local ground = room.depth -- 6369
	local depth = ground == nil and 0 or math.max( -- 6370
		ground.min, -- 6370
		math.min(ground.max, s.depth or 0) -- 6370
	) -- 6370
	return { -- 6371
		x = s.x, -- 6372
		y = s.y, -- 6372
		depth = depth, -- 6372
		depthSpeed = 0, -- 6372
		vx = 0, -- 6372
		vy = 0, -- 6372
		w = child and CHILD_W or SOLDIER_W, -- 6373
		h = child and CHILD_H or SOLDIER_H, -- 6374
		onGround = true, -- 6375
		facing = 1, -- 6375
		crouch = false, -- 6375
		rollT = 0, -- 6375
		covered = false, -- 6375
		alive = true -- 6375
	} -- 6375
end -- 6375
function drawFigure(draw, play, w, h, a, body, head) -- 6379
	if not a.alive then -- 6380
		return -- 6381
	end -- 6381
	local x0 = a.x - a.w / 2 -- 6383
	local x1 = a.x + a.w / 2 -- 6384
	local y0 = a.y + a.depth * DEPTH_Y_SCALE -- 6385
	local y1 = y0 + a.h -- 6386
	play:drawBox( -- 6387
		draw, -- 6387
		w, -- 6387
		h, -- 6387
		x0, -- 6387
		x1, -- 6387
		y0, -- 6387
		y1 - a.h * 0.26, -- 6387
		body -- 6387
	) -- 6387
	play:drawBox( -- 6388
		draw, -- 6388
		w, -- 6388
		h, -- 6388
		x0 + 2, -- 6388
		x1 - 2, -- 6388
		y1 - a.h * 0.26, -- 6388
		y1, -- 6388
		head -- 6388
	) -- 6388
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 6390
	play:drawBox( -- 6391
		draw, -- 6391
		w, -- 6391
		h, -- 6391
		eyeX, -- 6391
		eyeX + 4, -- 6391
		y1 - a.h * 0.14, -- 6391
		y1 - a.h * 0.08, -- 6391
		INK -- 6391
	) -- 6391
end -- 6391
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 6395
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 6396
end -- 6395
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 6403
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 6404
end -- 6403
function rayInterval(origin, direction, min, max) -- 6411
	if direction == 0 then -- 6412
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 6413
	end -- 6413
	local a = (min - origin) / direction -- 6415
	local b = (max - origin) / direction -- 6416
	return { -- 6417
		min = math.min(a, b), -- 6417
		max = math.max(a, b) -- 6417
	} -- 6417
end -- 6417
function hitBox(ray, box) -- 6421
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 6422
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 6423
	local enter = math.max(0, x.min, y.min) -- 6424
	local leave = math.min(99999, x.max, y.max) -- 6425
	if box.depth ~= nil then -- 6426
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 6427
		enter = math.max(enter, depth.min) -- 6428
		leave = math.min(leave, depth.max) -- 6429
	end -- 6429
	return leave >= enter and enter or -1 -- 6431
end -- 6431
function drawCartShape(draw, play, w, h, c, axleX) -- 6434
	local half = c.bodyW / 2 -- 6435
	local x0 = axleX - half -- 6436
	local x1 = axleX + half -- 6437
	local axleY = c.baseY + (c.depth or 0) * DEPTH_Y_SCALE + c.wheelR -- 6438
	play:drawBox( -- 6439
		draw, -- 6439
		w, -- 6439
		h, -- 6439
		x0, -- 6439
		x1, -- 6439
		axleY, -- 6439
		axleY + c.bodyH, -- 6439
		CART_FILL -- 6439
	) -- 6439
	draw:drawCircle( -- 6440
		Vec2( -- 6440
			play:sx(x0 + c.bodyW * 0.28, w), -- 6440
			play:sy(axleY, h) -- 6440
		), -- 6440
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6440
		Color(52, 50, 48, 255) -- 6440
	) -- 6440
	draw:drawCircle( -- 6441
		Vec2( -- 6441
			play:sx(x1 - c.bodyW * 0.28, w), -- 6441
			play:sy(axleY, h) -- 6441
		), -- 6441
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6441
		Color(52, 50, 48, 255) -- 6441
	) -- 6441
	local cx = c.clothSide < 0 and x0 or x1 -- 6442
	play:drawBox( -- 6443
		draw, -- 6443
		w, -- 6443
		h, -- 6443
		cx - 10, -- 6443
		cx + 10, -- 6443
		axleY + c.bodyH, -- 6443
		axleY + c.bodyH + 18, -- 6443
		CLOTH -- 6443
	) -- 6443
end -- 6443
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
	if tick >= ____exports.GATE_COUNT_END then -- 66
		return 20 -- 66
	end -- 66
	if tick >= 1260 then -- 67
		return 19 -- 67
	end -- 67
	if tick >= 1080 then -- 68
		return 18 -- 68
	end -- 68
	if tick >= 480 then -- 69
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
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 179
local CART_CLEAR = 44 -- 180
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 182
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 184
local CONSUMABLE_CAP = 1 -- 185
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 187
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 189
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 191
local FIRE_COOLDOWN = 150 -- 192
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 194
local ENEMY_RANGE = 760 -- 195
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 197
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 199
local DEPTH_SPEED_RATIO = 0.55 -- 200
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 201
INK = Color(232, 232, 228, 255) -- 203
local INK_DIM = Color(150, 152, 150, 255) -- 204
local BG_VOID = Color(8, 9, 10, 255) -- 205
local BG_FAR = Color(24, 26, 28, 255) -- 206
local BG_MID = Color(31, 34, 37, 255) -- 207
local GROUND = Color(112, 114, 112, 255) -- 208
local FLOOR_DECK = Color(66, 70, 72, 255) -- 209
local SOLID_FILL = Color(84, 86, 84, 255) -- 210
local SOLID_EDGE = Color(126, 130, 126, 255) -- 211
CART_FILL = Color(122, 78, 56, 255) -- 212
CLOTH = Color(178, 52, 46, 255) -- 213
local DANGER = Color(150, 54, 48, 46) -- 214
local DANGER_LINE = Color(178, 78, 64, 200) -- 215
local HOLE_FILL = Color(10, 11, 12, 255) -- 216
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 217
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 218
local CHILD_BODY = Color(214, 168, 96, 255) -- 219
local CHILD_HEAD = Color(232, 214, 186, 255) -- 220
local ENEMY_BODY = Color(176, 92, 84, 255) -- 221
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 222
local CHECK = Color(96, 186, 122, 255) -- 223
local STAND = Color(226, 186, 84, 255) -- 224
local AIM = Color(236, 236, 232, 230) -- 225
local AIM_HIT = Color(236, 96, 84, 255) -- 226
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 228
local SOFT_LINE = Color(140, 112, 80, 190) -- 229
local BRICK = Color(126, 118, 110, 70) -- 230
local BRICK_LINE = Color(160, 152, 142, 200) -- 231
local PASS = Color(96, 186, 122, 40) -- 232
local PASS_LINE = Color(96, 186, 122, 200) -- 233
local BOTTLE = Color(120, 186, 160, 255) -- 234
local SCAV_BODY = Color(128, 118, 96, 255) -- 235
local SCAV_HEAD = Color(196, 182, 158, 255) -- 236
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 323
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 324
	if zoom < 1 then -- 325
		zoom = 1 -- 326
	end -- 326
	return { -- 328
		zoom = zoom, -- 329
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 330
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 331
	} -- 331
end -- 323
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 354
	if key == "prologue" then -- 355
		return "prologue-wait" -- 358
	end -- 358
	if key == "street" then -- 360
		return "street-run" -- 361
	end -- 361
	if key == "gate" then -- 363
		return "gate-idle" -- 364
	end -- 364
	if key == "gatepath" then -- 366
		return "gatepath-start" -- 367
	end -- 367
	if key == "forest" then -- 369
		return "forest-run" -- 370
	end -- 370
	if key == "tower" then -- 372
		return "tower-wait" -- 373
	end -- 373
	if key == "museum" then -- 375
		return "museum-cabinet" -- 376
	end -- 376
	return "run" -- 378
end -- 354
____exports.Play = __TS__Class() -- 381
local Play = ____exports.Play -- 381
Play.name = "Play" -- 381
function Play.prototype.____constructor(self, room, resume, run) -- 691
	self.enemies = {} -- 386
	self.boxes = {} -- 387
	self.floors = {} -- 388
	self.checkpoint = -1 -- 390
	self.flash = "" -- 392
	self.flashT = 0 -- 393
	self.traceT = 0 -- 396
	self.focusCart = false -- 398
	self.knocks = 0 -- 400
	self.knockT = 0 -- 401
	self.cartAxle = 0 -- 405
	self.cartDocked = false -- 407
	self.gripping = false -- 409
	self.gateOpen = false -- 411
	self.calmConsumed = false -- 413
	self.craftT = 0 -- 415
	self.nextDangerId = 1 -- 417
	self.wantRoom = "" -- 419
	self.carryCartAxle = -1 -- 421
	self.carryCartDocked = false -- 422
	self.checkpointCartAxle = -1 -- 424
	self.hasBottle = false -- 428
	self.bottleLandX = -1 -- 432
	self.bottleTargetX = -1 -- 433
	self.bottleTargetY = 0 -- 434
	self.bottleLandT = 0 -- 435
	self.aimHold = 0 -- 437
	self.redCartPulled = false -- 439
	self.redCartMemoryT = 0 -- 441
	self.footHintT = 0 -- 443
	self.ditchHinted = false -- 445
	self.forestPath = "" -- 447
	self.waterSeen = false -- 449
	self.scavStallBonus = 0 -- 451
	self.intentGateReunionHold = false -- 453
	self.pendingMuseumIntentTarget = "" -- 455
	self.scavX = 0 -- 457
	self.scavDir = 1 -- 458
	self.scavState = "patrol" -- 459
	self.scavT = 0 -- 460
	self.scavTargetX = 0 -- 461
	self.passed = false -- 463
	self.childMode = false -- 467
	self.phase = "" -- 469
	self.phaseTick = 0 -- 471
	self.gateTick = 0 -- 473
	self.countTick = 0 -- 475
	self.countArmed = false -- 477
	self.countPrevMove = 0 -- 479
	self.caughtT = 0 -- 481
	self.hp = 3 -- 483
	self.maxHp = 3 -- 484
	self.invulnT = 0 -- 490
	self.partnerStuck = 0 -- 492
	self.partnerLaneIdx = 0 -- 494
	self.partnerLaneHold = 0 -- 495
	self.coveredFlash = 0 -- 497
	self.coverHug = false -- 499
	self.coverNear = false -- 501
	self.coverEntity = "" -- 503
	self.coverBlocking = false -- 505
	self.gateNeedConfirm = false -- 507
	self.gateRestartArmed = true -- 509
	self.bottleAimX = -1 -- 511
	self.bottleAimY = 0 -- 512
	self.bottleSurfaceY = -1 -- 514
	self.bottleLandY = 0 -- 516
	self.events = {} -- 518
	self.eventSeq = 0 -- 520
	self.dogX = 0 -- 522
	self.dogDir = 1 -- 523
	self.dogState = "patrol" -- 524
	self.dogT = 0 -- 525
	self.dogTargetX = 0 -- 526
	self.scavSee = 0 -- 528
	self.scavChase = false -- 529
	self.gateSpawned = 0 -- 531
	self.gateFailCount = 0 -- 533
	self.isCampaign = false -- 537
	self.archiveDirty = false -- 545
	self.sessionDirty = false -- 547
	self.restartStory = false -- 549
	self.wellOpen = false -- 551
	self.wellX = 430 -- 553
	self.wellTaken = false -- 555
	self.museumReturn = false -- 557
	self.endingLines = {"", ""} -- 559
	self.towerDoorOpen = false -- 561
	self.towerHanded = false -- 562
	self.deskHold = 0 -- 563
	self.towerEndMustRelease = false -- 565
	self.equippedWeapon = "standard_gun" -- 578
	self.craftBench = { -- 580
		active = false, -- 581
		firstCraftDone = false, -- 582
		justCraftedTimer = 0, -- 583
		inventory = {}, -- 584
		recipes = {}, -- 585
		equippedWeapon = "standard_gun" -- 586
	} -- 586
	self.handledCraftRequests = {} -- 589
	self.benchReach = 48 -- 591
	self.pickups = {} -- 595
	self.reloadT = 0 -- 597
	self.objectiveDone = false -- 601
	self.hint = "" -- 603
	self.roomStartTick = 0 -- 605
	self.cartHitT = 0 -- 607
	self.cartExposed = false -- 608
	self.storyRoute = "" -- 612
	self.storySettled = false -- 614
	self.hpAtGate = -1 -- 616
	self.maxHpAtGate = -1 -- 617
	self.handTicks = 0 -- 619
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 621
	self.handArmed = false -- 623
	self.handDone = false -- 625
	self.lineSaid = false -- 626
	self.tied = false -- 628
	self.pathDone = false -- 630
	self.carryOn = false -- 632
	self.escortDone = false -- 634
	self.escapeDuration = ____exports.PROLOGUE_ESCAPE_TICKS / 60 -- 638
	self.escapeRemaining = 0 -- 640
	self.escapeRetryCount = 0 -- 642
	self.introTick = 0 -- 644
	self.reloadOpen = false -- 648
	self.reloadAnswerTicks = 0 -- 650
	self.reloadWorldTicks = 0 -- 652
	self.reloadPath = {RELOAD_START} -- 654
	self.reloadPendingEffect = "" -- 656
	self.reloadTryCount = 0 -- 658
	self.talentModalActive = false -- 661
	self.useEscortDeathSummary = false -- 662
	self.escortFailed = false -- 663
	self.escortFailedTicks = 0 -- 664
	self.escortSummary = nil -- 665
	self.fieldWedgeSeq = 0 -- 673
	self.paused = false -- 675
	self.ticks = 0 -- 677
	self.view = {zoom = 1, ox = 0, oy = 0} -- 679
	self.ox = 0 -- 681
	self.aimX = 0 -- 683
	self.aimY = 0 -- 684
	self.viewW = 0 -- 686
	self.viewH = 0 -- 687
	self.ox = room.originX -- 693
	self.room = withOrigin(room) -- 694
	local wr = self.room -- 695
	self.run = run or createRun() -- 696
	self.inventory = self.run.inventory -- 697
	self.archive = self.run.archive -- 698
	local story = self.run.story -- 699
	local savedEq = story.equippedWeapon -- 700
	if savedEq == ARTIFACT_WEAPON_ID and self.archive.artifactOwned then -- 701
		self.equippedWeapon = ARTIFACT_WEAPON_ID -- 702
	elseif savedEq == "standard_gun" or savedEq ~= "" and savedEq == story.craftedWeapon then -- 703
		self.equippedWeapon = savedEq -- 704
	else -- 704
		self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 706
	end -- 706
	self.isCampaign = wr.campaign ~= nil -- 708
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 709
	self:buildWorld() -- 710
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 713
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 715
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 716
	local soloRoom = wr.key == "museum" -- 718
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 719
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 720
	self.player = makeActor(wr, playerIdx) -- 721
	self.partner = makeActor(wr, partnerIdx) -- 722
	self.phase = phaseOf(wr.key) -- 723
	if soloRoom then -- 724
		local mp = self.archive.museumPhase -- 726
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 727
	end -- 727
	if wr.story ~= nil then -- 732
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 733
	end -- 733
	self.cam.x = self.player.x -- 735
	self.cam.y = self.player.y + CAM_LOOK_UP -- 736
	self.cartAxle = wr.cart.startX -- 737
	self.escort = __TS__New( -- 738
		Escort, -- 738
		safeAnchorX(wr.marks) -- 738
	) -- 738
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 739
	if self.isCampaign then -- 740
		self:setupCampaign() -- 741
	else -- 741
		self:buildEnemies() -- 743
	end -- 743
	if resume ~= nil and resume.checkpoint > 0 then -- 746
		self.checkpoint = resume.checkpoint -- 747
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 748
			self.cartAxle = self.room.cart.endX -- 749
			self.cartDocked = true -- 750
			self.player.x = self.ox + 380 -- 753
			self.player.y = 0 -- 754
			self.player.vy = 0 -- 755
			self.player.onGround = true -- 756
			self.cam.x = self.player.x -- 757
			self.cam.y = self.player.y + CAM_LOOK_UP -- 758
		end -- 758
	end -- 758
	self:restoreStory() -- 761
end -- 691
function Play.prototype.towerEndReady(self) -- 568
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 569
	return self.room.key == "tower" and self.phase == "tower-end" and self.phaseTick >= waitTicks and not self.towerEndMustRelease -- 570
end -- 568
function Play.prototype.recipeViews(self) -- 774
	local out = {} -- 775
	local i = 0 -- 776
	do -- 776
		i = 0 -- 777
		while i < #CRAFT_RECIPES do -- 777
			local r = CRAFT_RECIPES[i + 1] -- 778
			local cost = {} -- 779
			if r.cost.wood ~= nil then -- 780
				cost.wood = r.cost.wood -- 781
			end -- 781
			if r.cost.bell ~= nil then -- 783
				cost.bell = r.cost.bell -- 784
			end -- 784
			out[#out + 1] = { -- 786
				id = r.id, -- 787
				name = r.name, -- 788
				desc = r.desc, -- 789
				enhancedEffect = r.enhancedEffect, -- 790
				cost = cost, -- 791
				crafted = self.run.story.craftedWeapon == r.id -- 792
			} -- 792
			i = i + 1 -- 777
		end -- 777
	end -- 777
	if self.archive.artifactOwned then -- 796
		out[#out + 1] = { -- 797
			id = ARTIFACT_WEAPON_ID, -- 798
			name = weaponNameOf(ARTIFACT_WEAPON_ID), -- 799
			desc = "井底拾取彩蛋 · 男主线移动留下冷白微金轨迹残影", -- 800
			enhancedEffect = "light", -- 801
			cost = {}, -- 802
			crafted = true -- 803
		} -- 803
	end -- 803
	return out -- 806
end -- 774
function Play.prototype.syncCraftBench(self) -- 810
	local view = self.craftBench -- 811
	local inv = self.run.inventory -- 812
	view.inventory = { -- 813
		wood = inv.wood, -- 813
		bell = inv.bell, -- 813
		scrap = inv.scrap, -- 813
		wedge = inv.wedge, -- 813
		ammo = inv.ammo -- 813
	} -- 813
	view.recipes = self:recipeViews() -- 814
	view.equippedWeapon = self.equippedWeapon -- 815
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 816
	if view.justCraftedTimer > 0 then -- 817
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 818
	end -- 818
end -- 810
function Play.prototype.openCraftBench(self) -- 823
	if self.room.key ~= "escort3" or self.craftBench.active then -- 824
		return -- 825
	end -- 825
	self.craftBench.active = true -- 827
	self.carryOn = false -- 828
	self.run.story.carry = false -- 829
	self.player.vx = 0 -- 830
	self.player.vy = 0 -- 831
	self.craftBench.justCraftedTimer = 0 -- 832
	self:syncCraftBench() -- 833
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 834
	self:log("开工台") -- 835
	self:emit( -- 836
		"benchOpen", -- 836
		{ -- 836
			recipes = __TS__ArrayMap( -- 837
				self.craftBench.recipes, -- 837
				function(____, r) return r.id end -- 837
			), -- 837
			inventory = self.craftBench.inventory, -- 838
			carry = self.carryOn -- 839
		} -- 839
	) -- 839
end -- 823
function Play.prototype.closeCraftBench(self) -- 844
	if not self.craftBench.active then -- 845
		return -- 846
	end -- 846
	self.craftBench.active = false -- 848
	self.craftBench.justCraftedTimer = 0 -- 849
	self.carryOn = true -- 850
	self.run.story.carry = true -- 851
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 852
	self:log("离站背起") -- 853
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 854
	if self.room.key == "escort3" and self.storyRoute == "soldier" then -- 855
		self:triggerDeferredEscort3Draft() -- 856
	end -- 856
end -- 844
function Play.prototype.triggerDeferredEscort3Draft(self) -- 861
	if self.room.key ~= "escort3" or self.storyRoute ~= "soldier" or self.run.finished then -- 862
		return false -- 863
	end -- 863
	if self.run.story.talents == nil then -- 865
		self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 866
	end -- 866
	local st = self.run.story.talents -- 868
	if not st.deferred and st.room == "escort3" then -- 869
		return false -- 870
	end -- 870
	draftTalentOffers(st, "escort3", self.equippedWeapon) -- 872
	if self.useEscortDeathSummary and #st.offers > 0 then -- 873
		self.talentModalActive = true -- 874
	end -- 874
	self.sessionDirty = true -- 876
	return #st.offers > 0 -- 877
end -- 861
function Play.prototype.openTalentDraft(self) -- 881
	if #self:getStoryTalentOffers() > 0 and not self.craftBench.active and not self.escortFailed then -- 882
		self.talentModalActive = true -- 883
	end -- 883
end -- 881
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 891
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 892
		return false -- 893
	end -- 893
	local recipe = findRecipe(recipeId) -- 895
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 896
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 897
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 898
		return false -- 899
	end -- 899
	local missing = missingMaterials(self.run.inventory, recipe) -- 901
	if #missing > 0 then -- 902
		self:flashSet( -- 903
			"缺料 · " .. table.concat(missing, " / "), -- 903
			1.6 -- 903
		) -- 903
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 904
		return false -- 905
	end -- 905
	payMaterials(self.run.inventory, recipe) -- 907
	self.handledCraftRequests[requestId] = true -- 908
	self.run.story.craftedWeapon = recipe.id -- 909
	self.run.story.equippedWeapon = recipe.id -- 910
	self.equippedWeapon = recipe.id -- 911
	self.sessionDirty = true -- 912
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 913
	self.craftBench.firstCraftDone = true -- 914
	self:syncCraftBench() -- 915
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 916
	self:log("改制 " .. recipe.id) -- 917
	self:emit("benchCraft", { -- 918
		recipeId = recipe.id, -- 919
		weapon = recipe.id, -- 920
		effect = recipe.enhancedEffect, -- 921
		wood = self.run.inventory.wood, -- 922
		bell = self.run.inventory.bell -- 923
	}) -- 923
	return true -- 925
end -- 891
function Play.prototype.equipWeapon(self, weaponId) -- 929
	local artifactOk = weaponId == ARTIFACT_WEAPON_ID and self.archive.artifactOwned -- 930
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId and not artifactOk then -- 931
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 932
		return false -- 933
	end -- 933
	self.equippedWeapon = weaponId -- 935
	self.run.story.equippedWeapon = weaponId -- 936
	self.sessionDirty = true -- 937
	self:syncCraftBench() -- 938
	self:flashSet( -- 939
		"已装备 " .. weaponNameOf(weaponId), -- 939
		1 -- 939
	) -- 939
	self:emit("benchEquip", {weapon = weaponId}) -- 940
	return true -- 941
end -- 929
function Play.prototype.toggleArtifactWeapon(self) -- 945
	if not self.archive.artifactOwned or self.childMode then -- 946
		return false -- 947
	end -- 947
	if self.equippedWeapon == ARTIFACT_WEAPON_ID then -- 949
		local fallback = self.run.story.craftedWeapon ~= "" and self.run.story.craftedWeapon or "standard_gun" -- 950
		return self:equipWeapon(fallback) -- 951
	end -- 951
	return self:equipWeapon(ARTIFACT_WEAPON_ID) -- 953
end -- 945
function Play.prototype.exportSession(self) -- 957
	self:syncStory() -- 958
	local story = self.run.story -- 959
	local inv = self.run.inventory -- 960
	local taken = {} -- 961
	for k in pairs(self.run.taken) do -- 962
		if self.run.taken[k] == true then -- 963
			taken[#taken + 1] = k -- 964
		end -- 964
	end -- 964
	local segments = {} -- 967
	for k in pairs(story.segments) do -- 968
		if story.segments[k] == true then -- 969
			segments[#segments + 1] = k -- 970
		end -- 970
	end -- 970
	local props = {} -- 973
	for k in pairs(self.run.props) do -- 974
		local st = self.run.props[k] -- 975
		if st ~= nil then -- 976
			props[#props + 1] = (((((((k .. ":") .. (st.broken and "1" or "0")) .. ":") .. tostring(math.floor(st.hp + 0.5))) .. ":") .. (st.wedge and "1" or "0")) .. ":") .. (st.revealed == true and "1" or "0") -- 977
		end -- 977
	end -- 977
	local talentRanks = {} -- 986
	if story.talents ~= nil then -- 987
		local ti = 0 -- 988
		do -- 988
			ti = 0 -- 989
			while ti < #ALL_TALENTS do -- 989
				local tid = ALL_TALENTS[ti + 1] -- 990
				local rk = story.talents.ranks[tid] or 0 -- 991
				if rk > 0 then -- 992
					talentRanks[#talentRanks + 1] = (tid .. ":") .. tostring(rk) -- 993
				end -- 993
				ti = ti + 1 -- 989
			end -- 989
		end -- 989
	end -- 989
	local ____temp_4 = self.escortFailed and "escort1" or self.room.key -- 999
	local ____temp_5 = self.escortFailed and 0 or self.checkpoint -- 1000
	local ____self_run_seed_6 = self.run.seed -- 1001
	local ____story_route_7 = story.route -- 1002
	local ____story_hp_8 = story.hp -- 1003
	local ____story_maxHp_9 = story.maxHp -- 1004
	local ____story_hpAtGate_10 = story.hpAtGate -- 1005
	local ____story_maxHpAtGate_11 = story.maxHpAtGate -- 1006
	local ____story_settled_12 = story.settled -- 1007
	local ____self_phase_13 = self.phase -- 1008
	local ____story_countTick_14 = story.countTick -- 1009
	local ____story_phaseTick_15 = story.phaseTick -- 1010
	local ____story_handTicks_16 = story.handTicks -- 1011
	local ____story_handDone_17 = story.handDone -- 1012
	local ____story_lineSaid_18 = story.lineSaid -- 1013
	local ____story_tied_19 = story.tied -- 1014
	local ____story_carry_20 = story.carry -- 1015
	local ____story_escortDone_21 = story.escortDone -- 1016
	local ____story_craftedWeapon_22 = story.craftedWeapon -- 1017
	local ____self_equippedWeapon_23 = self.equippedWeapon -- 1018
	local ____inv_wood_24 = inv.wood -- 1019
	local ____inv_bell_25 = inv.bell -- 1020
	local ____inv_scrap_26 = inv.scrap -- 1021
	local ____inv_wedge_27 = inv.wedge -- 1022
	local ____inv_ammo_28 = inv.ammo -- 1023
	local ____inv_shield_29 = inv.shield -- 1024
	local ____inv_pass_30 = inv.pass -- 1025
	local ____inv_quickbelt_31 = inv.quickbelt -- 1026
	local ____taken_32 = taken -- 1027
	local ____segments_33 = segments -- 1028
	local ____self_cartAxle_34 = self.cartAxle -- 1029
	local ____self_cartDocked_35 = self.cartDocked -- 1030
	local ____self_run_route_36 = self.run.route -- 1031
	local ____self_run_joined_37 = self.run.joined -- 1032
	local ____self_run_c1Latch_38 = self.run.c1Latch -- 1033
	local ____self_run_c2Latch_39 = self.run.c2Latch -- 1034
	local ____temp_40 = story.talents ~= nil and story.talents.randomState or 0 -- 1035
	local ____temp_41 = story.talents ~= nil and story.talents.room or "" -- 1036
	local ____temp_42 = story.talents ~= nil and __TS__ArraySlice(story.talents.offers) or ({}) -- 1037
	local ____talentRanks_43 = talentRanks -- 1038
	local ____temp_44 = story.talents ~= nil and story.talents.attempt or 1 -- 1039
	local ____temp_45 = story.talents ~= nil and story.talents.variant or 0 -- 1040
	local ____temp_0 -- 1041
	if story.talents ~= nil then -- 1041
		____temp_0 = story.talents.deferred -- 1041
	else -- 1041
		____temp_0 = false -- 1041
	end -- 1041
	local ____temp_46 = story.talents ~= nil and story.talents.ranks.vitality or 0 -- 1042
	local ____temp_47 = story.talents ~= nil and story.talents.ranks.focus or 0 -- 1043
	local ____temp_48 = story.talents ~= nil and story.talents.ranks.guard or 0 -- 1044
	local ____temp_49 = story.talents ~= nil and story.talents.ranks.salvage or 0 -- 1045
	local ____props_50 = props -- 1046
	local ____table_escortFailed_1 -- 1047
	if self.escortFailed then -- 1047
		____table_escortFailed_1 = nil -- 1047
	else -- 1047
		____table_escortFailed_1 = self.player.x -- 1047
	end -- 1047
	local ____table_escortFailed_2 -- 1048
	if self.escortFailed then -- 1048
		____table_escortFailed_2 = nil -- 1048
	else -- 1048
		____table_escortFailed_2 = self.player.y -- 1048
	end -- 1048
	local ____table_escortFailed_3 -- 1049
	if self.escortFailed then -- 1049
		____table_escortFailed_3 = nil -- 1049
	else -- 1049
		____table_escortFailed_3 = self.player.depth -- 1049
	end -- 1049
	return { -- 997
		roomKey = ____temp_4, -- 999
		checkpoint = ____temp_5, -- 1000
		seed = ____self_run_seed_6, -- 1001
		route = ____story_route_7, -- 1002
		hp = ____story_hp_8, -- 1003
		maxHp = ____story_maxHp_9, -- 1004
		hpAtGate = ____story_hpAtGate_10, -- 1005
		maxHpAtGate = ____story_maxHpAtGate_11, -- 1006
		settled = ____story_settled_12, -- 1007
		phase = ____self_phase_13, -- 1008
		countTick = ____story_countTick_14, -- 1009
		phaseTick = ____story_phaseTick_15, -- 1010
		handTicks = ____story_handTicks_16, -- 1011
		handDone = ____story_handDone_17, -- 1012
		lineSaid = ____story_lineSaid_18, -- 1013
		tied = ____story_tied_19, -- 1014
		carry = ____story_carry_20, -- 1015
		escortDone = ____story_escortDone_21, -- 1016
		craftedWeapon = ____story_craftedWeapon_22, -- 1017
		equippedWeapon = ____self_equippedWeapon_23, -- 1018
		wood = ____inv_wood_24, -- 1019
		bell = ____inv_bell_25, -- 1020
		scrap = ____inv_scrap_26, -- 1021
		wedge = ____inv_wedge_27, -- 1022
		ammo = ____inv_ammo_28, -- 1023
		shield = ____inv_shield_29, -- 1024
		pass = ____inv_pass_30, -- 1025
		quickbelt = ____inv_quickbelt_31, -- 1026
		taken = ____taken_32, -- 1027
		segments = ____segments_33, -- 1028
		cartAxle = ____self_cartAxle_34, -- 1029
		cartDocked = ____self_cartDocked_35, -- 1030
		campaignRoute = ____self_run_route_36, -- 1031
		joined = ____self_run_joined_37, -- 1032
		c1Latch = ____self_run_c1Latch_38, -- 1033
		c2Latch = ____self_run_c2Latch_39, -- 1034
		talentSeed = ____temp_40, -- 1035
		talentRoom = ____temp_41, -- 1036
		talentOffers = ____temp_42, -- 1037
		talentRanks = ____talentRanks_43, -- 1038
		escortAttempt = ____temp_44, -- 1039
		escortVariant = ____temp_45, -- 1040
		talentDeferred = ____temp_0, -- 1041
		talentVitality = ____temp_46, -- 1042
		talentReload = ____temp_47, -- 1043
		talentGuard = ____temp_48, -- 1044
		talentCraft = ____temp_49, -- 1045
		props = ____props_50, -- 1046
		playerX = ____table_escortFailed_1, -- 1047
		playerY = ____table_escortFailed_2, -- 1048
		playerDepth = ____table_escortFailed_3, -- 1049
		gateTick = self.gateTick, -- 1050
		hasBottle = self.hasBottle, -- 1051
		villagePassed = self.passed -- 1052
	} -- 1052
end -- 957
function Play.prototype.submitFeIntent(self, intent) -- 1060
	local kind = intent == nil and "" or intent.kind -- 1061
	if kind == "gateReunionHold" then -- 1062
		if self.room.key ~= "gate" or self.phase ~= "gate-wait" and self.phase ~= "gate-count" then -- 1063
			return false -- 1064
		end -- 1064
		local holding = intent.holding == true -- 1066
		self.intentGateReunionHold = holding -- 1067
		if not holding and self.phase == "gate-wait" then -- 1068
			if self.handTicks > 0 then -- 1069
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1070
			end -- 1070
			self.handTicks = 0 -- 1072
			self.handArmed = true -- 1073
		end -- 1073
		return true -- 1075
	end -- 1075
	if kind == "reloadOpen" then -- 1077
		local camp = self.room.campaign -- 1078
		if camp == nil or camp.reloadPuzzle ~= true or self.reloadOpen then -- 1079
			return false -- 1080
		end -- 1080
		self:beginReload() -- 1082
		return self.reloadOpen -- 1083
	end -- 1083
	if kind == "reloadPathPreview" then -- 1085
		local path = intent.path -- 1086
		return type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) -- 1087
	end -- 1087
	if kind == "reloadTapNode" then -- 1089
		local node = intent.node -- 1090
		if type(node) == "number" then -- 1091
			self:reloadTapNode(node) -- 1092
			return true -- 1093
		end -- 1093
		return false -- 1095
	end -- 1095
	if kind == "reloadPathCommit" then -- 1097
		local path = intent.path -- 1098
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 1099
			local list = path -- 1100
			local i = 0 -- 1101
			do -- 1101
				i = 0 -- 1102
				while i < #list do -- 1102
					do -- 1102
						if i == 0 and list[i + 1] == RELOAD_START then -- 1103
							goto __continue85 -- 1104
						end -- 1104
						self:reloadTapNode(list[i + 1]) -- 1106
					end -- 1106
					::__continue85:: -- 1106
					i = i + 1 -- 1102
				end -- 1102
			end -- 1102
			return true -- 1108
		end -- 1108
		return false -- 1110
	end -- 1110
	if kind == "reloadCancel" then -- 1112
		self:closeReloadPuzzle() -- 1113
		return true -- 1114
	end -- 1114
	if kind == "craftSubmit" then -- 1116
		local recipeId = intent.recipeId -- 1117
		local requestId = intent.requestId -- 1118
		if type(recipeId) == "string" and type(requestId) == "string" then -- 1119
			return self:craftAtBench(recipeId, requestId) -- 1120
		end -- 1120
		return false -- 1122
	end -- 1122
	if kind == "craftEquip" then -- 1124
		local weaponId = intent.weaponId -- 1125
		if type(weaponId) == "string" then -- 1126
			return self:equipWeapon(weaponId) -- 1127
		end -- 1127
		return false -- 1129
	end -- 1129
	if kind == "craftClose" then -- 1131
		self:closeCraftBench() -- 1132
		return true -- 1133
	end -- 1133
	if kind == "chooseTalent" then -- 1135
		local slot = intent.slot -- 1136
		if type(slot) == "number" then -- 1137
			return self:chooseTalent(slot) -- 1138
		end -- 1138
		return false -- 1140
	end -- 1140
	if kind == "wellPick" then -- 1142
		return self:pickWell() -- 1143
	end -- 1143
	if kind == "museumInteract" then -- 1145
		local target = type(intent.target) == "string" and intent.target or "" -- 1146
		if target == "well_pickup" or target == "well" then -- 1147
			return self:pickWell() -- 1148
		end -- 1148
		if self.room.key ~= "museum" then -- 1150
			return false -- 1151
		end -- 1151
		return self:triggerMuseumIntent(target) -- 1153
	end -- 1153
	return false -- 1155
end -- 1060
function Play.prototype.triggerMuseumIntent(self, target) -- 1159
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 1160
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 1163
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 1164
	if self.phase == "museum-cabinet" then -- 1165
		if target == "enter_hall" or (target == "" or target == "cabinet" or target == "weapon_case") and atCase then -- 1166
			self.pendingMuseumIntentTarget = "cabinet" -- 1167
			return true -- 1168
		end -- 1168
	end -- 1168
	if self.phase == "museum-hall" then -- 1171
		if (target == "lamp_turn" or target == "lamp" or target == "west_lamp") and nearLamp then -- 1172
			self.pendingMuseumIntentTarget = "lamp_direct" -- 1173
			return true -- 1174
		end -- 1174
		if (target == "" or target == "hall" or target == "corridor") and self.player.x >= self.ox + mu.hallX then -- 1176
			self.pendingMuseumIntentTarget = "hall" -- 1177
			return true -- 1178
		end -- 1178
	end -- 1178
	if self.phase == "museum-lamp" and (target == "" or target == "lamp" or target == "west_lamp" or target == "lamp_turn") and nearLamp then -- 1181
		self.pendingMuseumIntentTarget = "lamp" -- 1184
		return true -- 1185
	end -- 1185
	if self.phase == "museum-return" then -- 1187
		if target == "begin_return_cabinet" or (target == "" or target == "return_cabinet" or target == "cabinet" or target == "return") and atCase then -- 1188
			self.pendingMuseumIntentTarget = "return_cabinet" -- 1190
			return true -- 1191
		end -- 1191
	end -- 1191
	if self.phase == "museum-done" and (target == "" or target == "return_cabinet" or target == "return") then -- 1194
		self.pendingMuseumIntentTarget = "done" -- 1195
		return true -- 1196
	end -- 1196
	return false -- 1198
end -- 1159
function Play.prototype.captureCheckpoint(self, id) -- 1202
	local inv = self.run.inventory -- 1203
	self.checkpointSnap = { -- 1204
		id = id, -- 1205
		wood = inv.wood, -- 1206
		bell = inv.bell, -- 1207
		scrap = inv.scrap, -- 1208
		wedge = inv.wedge, -- 1209
		ammo = inv.ammo, -- 1210
		shield = inv.shield, -- 1211
		pass = inv.pass, -- 1212
		quickbelt = inv.quickbelt, -- 1213
		crafted = self.run.story.craftedWeapon, -- 1214
		equipped = self.equippedWeapon, -- 1215
		carry = self.carryOn -- 1216
	} -- 1216
	self.run.story.cp = self.checkpointSnap -- 1218
end -- 1202
function Play.prototype.applyCheckpointSnap(self, id) -- 1222
	local snap = self.run.story.cp -- 1223
	if snap == nil or snap.id ~= id then -- 1224
		return false -- 1225
	end -- 1225
	self.checkpointSnap = snap -- 1227
	local inv = self.run.inventory -- 1228
	inv.wood = snap.wood -- 1229
	inv.bell = snap.bell -- 1230
	inv.scrap = snap.scrap -- 1231
	inv.wedge = snap.wedge -- 1232
	inv.ammo = snap.ammo -- 1233
	inv.shield = snap.shield -- 1234
	inv.pass = snap.pass -- 1235
	inv.quickbelt = snap.quickbelt -- 1236
	self.run.story.craftedWeapon = snap.crafted -- 1237
	self.equippedWeapon = snap.equipped -- 1238
	self.run.story.equippedWeapon = snap.equipped -- 1239
	self.carryOn = snap.carry -- 1240
	self.run.story.carry = snap.carry -- 1241
	self.craftBench.active = false -- 1242
	self:syncCraftBench() -- 1243
	return true -- 1244
end -- 1222
function Play.prototype.restoreStory(self) -- 1247
	local story = self.run.story -- 1248
	if story == nil then -- 1249
		return -- 1250
	end -- 1250
	if story.maxHp > 0 then -- 1252
		self.maxHp = story.maxHp -- 1253
		self.hp = math.max( -- 1254
			1, -- 1254
			math.min(story.hp, story.maxHp) -- 1254
		) -- 1254
	end -- 1254
	self.storyRoute = story.route -- 1256
	self.storySettled = story.settled -- 1257
	self.hpAtGate = story.hpAtGate -- 1258
	self.maxHpAtGate = story.maxHpAtGate -- 1259
	self.handDone = story.handDone -- 1260
	self.lineSaid = story.lineSaid -- 1261
	self.tied = story.handDone -- 1262
	self.carryOn = story.carry or story.route == "soldier" and (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 1263
	self.museumReturn = story.museumReturn -- 1264
	story.museumReturn = false -- 1265
	self.escortDone = story.escortDone -- 1266
	self:syncCraftBench() -- 1267
	if story.segments.outside_cart == true then -- 1269
		self.redCartPulled = true -- 1270
		local redBox = __TS__ArrayFind( -- 1271
			self.boxes, -- 1271
			function(____, b) return b.id == "outside_red_cart" end -- 1271
		) -- 1271
		if redBox ~= nil then -- 1272
			redBox.x0 = 430 -- 1273
			redBox.x1 = 474 -- 1274
		end -- 1274
		if self.room.key == "outside" and self.room.cart.bodyW > 0 then -- 1276
			self.cartAxle = self.room.cart.endX -- 1277
			self.cartDocked = true -- 1278
		end -- 1278
	end -- 1278
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 1281
	self.waterSeen = story.segments.water_lantern == true -- 1283
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 1285
		self:applyCheckpointSnap(self.checkpoint) -- 1286
	end -- 1286
	if self.room.key == "tower" and story.route == "soldier" then -- 1289
		self.carryOn = false -- 1290
		self.run.story.carry = false -- 1291
		self.player.w = SOLDIER_W -- 1292
		self.player.h = SOLDIER_H -- 1293
		self.player.x = math.max(self.ox + 422, self.player.x) -- 1294
		self.partner = { -- 1295
			x = math.max(self.ox + 408, self.player.x - 24), -- 1296
			y = 0, -- 1297
			depth = 0, -- 1298
			depthSpeed = 0, -- 1299
			vx = 0, -- 1300
			vy = 0, -- 1301
			w = CHILD_W, -- 1302
			h = CHILD_H, -- 1303
			onGround = true, -- 1304
			facing = 1, -- 1305
			crouch = false, -- 1306
			rollT = 0, -- 1307
			covered = false, -- 1308
			alive = true -- 1309
		} -- 1309
	end -- 1309
	if self.room.key == "tower" then -- 1313
		if story.segments.tower_door == true then -- 1314
			self:openTowerDoor() -- 1315
		end -- 1315
		self.towerHanded = story.segments.tower_handover == true -- 1317
		self.deskHold = 0 -- 1318
		if story.phase == "tower-enter" or story.phase == "tower-desk" or story.phase == "tower-given" then -- 1319
			self.phase = story.phase -- 1320
			self.phaseTick = 0 -- 1321
			if story.phase == "tower-desk" or story.phase == "tower-given" then -- 1322
				self.player.x = self.ox + 605 -- 1323
				self.player.y = 0 -- 1324
				if story.route == "soldier" and self.partner.alive then -- 1325
					self.partner.x = self.ox + 568 -- 1326
					self.partner.y = 0 -- 1327
					self.partner.facing = 1 -- 1328
				end -- 1328
			end -- 1328
		end -- 1328
	end -- 1328
	if self.room.key == "prologue" then -- 1334
		local ph = story.phase -- 1335
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 1336
			self.phase = ph -- 1337
			self.phaseTick = story.phaseTick -- 1338
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 1339
			self.player.y = 0 -- 1340
			self.player.depth = 0 -- 1341
			self.player.vx = 0 -- 1342
			self.partner.x = self.ox + 300 -- 1343
			self.partner.y = 0 -- 1344
			self.partner.depth = 0 -- 1345
			self.partner.vx = 0 -- 1346
			self.partner.alive = true -- 1347
			if ph == "prologue-follow" then -- 1348
				self.partner.crouch = false -- 1349
				self.partner.h = CHILD_H -- 1350
			else -- 1350
				self.partner.crouch = true -- 1352
				self.partner.h = CHILD_CROUCH_H -- 1353
			end -- 1353
			self.cam.x = self.player.x -- 1355
		end -- 1355
		return -- 1357
	end -- 1357
	if self.room.key ~= "gate" then -- 1359
		return -- 1360
	end -- 1360
	local ____temp_51 -- 1362
	if self.room.story == nil then -- 1362
		____temp_51 = nil -- 1362
	else -- 1362
		____temp_51 = self.room.story.gate -- 1362
	end -- 1362
	local g = ____temp_51 -- 1362
	if g == nil then -- 1363
		return -- 1364
	end -- 1364
	if story.phase == "gate-send" then -- 1367
		self.phase = "gate-send" -- 1368
		self.gateTick = g.holdTicks -- 1369
		self.gateSpawned = 4 -- 1370
		self.enemies = {} -- 1371
		self.player.x = self.ox + g.doorX - 40 -- 1372
		self.player.y = 0 -- 1373
		self.player.depth = 0 -- 1374
		self.player.vx = 0 -- 1375
		self.player.vy = 0 -- 1376
		self.player.onGround = true -- 1377
		self.partner.x = self.ox + g.waitX -- 1378
		self.partner.y = 0 -- 1379
		self.partner.depth = 0 -- 1380
		self.partner.alive = true -- 1381
		self.cam.x = self.player.x -- 1382
		self.handTicks = 0 -- 1383
		self.handArmed = false -- 1384
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1385
		return -- 1386
	end -- 1386
	if not story.settled then -- 1388
		return -- 1389
	end -- 1389
	self.gateTick = g.holdTicks -- 1392
	self.gateSpawned = 4 -- 1393
	self.enemies = {} -- 1394
	if story.phase == "gate-farewell" or story.phase == "gate-count" or story.phase == "gate-walk" then -- 1395
		self.phase = story.phase == "gate-farewell" and "gate-count" or story.phase -- 1396
		self.countTick = story.phase == "gate-farewell" and 0 or math.max(story.countTick, 0) -- 1397
		self:swapToChild(g.doorX + 30) -- 1398
		self.countPrevMove = 0 -- 1399
		self.countArmed = false -- 1400
		return -- 1401
	end -- 1401
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1403
		self.phase = story.phase -- 1404
		self.countTick = ____exports.GATE_COUNT_END -- 1405
		self.phaseTick = story.phaseTick -- 1406
		self:swapToChild(g.doorX + 30) -- 1407
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1408
			0, -- 1408
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1408
		) -- 1408
		self.handArmed = false -- 1409
	end -- 1409
end -- 1247
function Play.prototype.buildWorld(self) -- 1414
	local room = self.room -- 1415
	self.boxes = {} -- 1416
	self.floors = {} -- 1417
	local i = 0 -- 1418
	do -- 1418
		i = 0 -- 1419
		while i < #room.floors do -- 1419
			local f = room.floors[i + 1] -- 1420
			local ____self_floors_52 = self.floors -- 1421
			____self_floors_52[#____self_floors_52 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1421
			i = i + 1 -- 1419
		end -- 1419
	end -- 1419
	do -- 1419
		i = 0 -- 1423
		while i < #room.solids do -- 1423
			local s = room.solids[i + 1] -- 1424
			if not s.decorative then -- 1425
				local ____self_boxes_64 = self.boxes -- 1430
				local ____s_x_55 = s.x -- 1431
				local ____temp_56 = s.x + s.w -- 1431
				local ____s_y_57 = s.y -- 1431
				local ____temp_58 = s.y + s.h -- 1431
				local ____temp_53 -- 1432
				if room.depth == nil then -- 1432
					____temp_53 = nil -- 1432
				else -- 1432
					____temp_53 = s.depth -- 1432
				end -- 1432
				local ____temp_59 = s.passable == true -- 1433
				local ____s_label_60 = s.label -- 1433
				local ____s_id_61 = s.id -- 1434
				local ____temp_62 = s.soft == true -- 1434
				local ____temp_63 = s.hidden == true -- 1434
				local ____temp_54 -- 1435
				if s.breakable == nil then -- 1435
					____temp_54 = nil -- 1435
				else -- 1435
					____temp_54 = __TS__ObjectAssign({}, s.breakable) -- 1435
				end -- 1435
				____self_boxes_64[#____self_boxes_64 + 1] = { -- 1430
					x0 = ____s_x_55, -- 1431
					x1 = ____temp_56, -- 1431
					y0 = ____s_y_57, -- 1431
					y1 = ____temp_58, -- 1431
					depth = ____temp_53, -- 1432
					passable = ____temp_59, -- 1433
					label = ____s_label_60, -- 1433
					id = ____s_id_61, -- 1434
					soft = ____temp_62, -- 1434
					hidden = ____temp_63, -- 1434
					breakable = ____temp_54, -- 1435
					interact = s.interact -- 1436
				} -- 1436
			end -- 1436
			i = i + 1 -- 1423
		end -- 1423
	end -- 1423
	do -- 1423
		i = 0 -- 1440
		while i < #room.stairs do -- 1440
			local st = room.stairs[i + 1] -- 1441
			local n = st.steps + 1 -- 1442
			local stepW = (st.x1 - st.x0) / n -- 1443
			local k = 0 -- 1444
			do -- 1444
				k = 0 -- 1445
				while k < n do -- 1445
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1446
					local x0 = st.x0 + stepW * k -- 1447
					local ____self_boxes_68 = self.boxes -- 1450
					local ____temp_66 = x0 + stepW -- 1451
					local ____temp_67 = -8 -- 1451
					local ____temp_65 -- 1452
					if room.depth == nil then -- 1452
						____temp_65 = nil -- 1452
					else -- 1452
						____temp_65 = st.depth -- 1452
					end -- 1452
					____self_boxes_68[#____self_boxes_68 + 1] = { -- 1450
						x0 = x0, -- 1451
						x1 = ____temp_66, -- 1451
						y0 = ____temp_67, -- 1451
						y1 = y, -- 1451
						depth = ____temp_65, -- 1452
						passable = true -- 1453
					} -- 1453
					k = k + 1 -- 1445
				end -- 1445
			end -- 1445
			i = i + 1 -- 1440
		end -- 1440
	end -- 1440
end -- 1414
function Play.prototype.setupCampaign(self) -- 1463
	local wr = self.room -- 1464
	local c = wr.campaign -- 1465
	if c == nil then -- 1466
		return -- 1467
	end -- 1467
	self.roomStartTick = self.run.ticks -- 1469
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1471
		self.run.joined = true -- 1473
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1474
		local ____self_run_73 = self.run -- 1476
		local ____temp_72 -- 1476
		if wr.key == "s2-drygoods" then -- 1476
			local ____temp_71 = self.run.route ~= "drygoods" -- 1477
			if not ____temp_71 then -- 1477
				local ____opt_69 = self.run.props.s2_board -- 1477
				____temp_71 = (____opt_69 and ____opt_69.broken) == true -- 1477
			end -- 1477
			____temp_72 = ____temp_71 -- 1477
		else -- 1477
			____temp_72 = wr.key == "c1-yard" and self.run.c1Latch -- 1478
		end -- 1478
		____self_run_73.joined = ____temp_72 -- 1476
	end -- 1476
	local x = wr.minX + 60 -- 1480
	local y = 0 -- 1481
	local depth = 0 -- 1482
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1483
		x = wr.minX + 210 -- 1484
		depth = -32 -- 1485
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1486
		x = wr.minX + 40 -- 1487
		y = 32 -- 1488
		depth = 32 -- 1489
	end -- 1489
	self.player = { -- 1491
		x = x, -- 1492
		y = y, -- 1492
		depth = depth, -- 1492
		depthSpeed = 0, -- 1492
		vx = 0, -- 1492
		vy = 0, -- 1492
		w = SOLDIER_W, -- 1493
		h = SOLDIER_H, -- 1493
		onGround = y <= 0, -- 1493
		facing = 1, -- 1493
		crouch = false, -- 1493
		rollT = 0, -- 1493
		covered = false, -- 1493
		alive = true -- 1493
	} -- 1493
	self.partner = { -- 1495
		x = x + 60, -- 1496
		y = y, -- 1496
		depth = depth, -- 1496
		depthSpeed = 0, -- 1496
		vx = 0, -- 1496
		vy = 0, -- 1496
		w = CHILD_W, -- 1497
		h = CHILD_H, -- 1497
		onGround = y <= 0, -- 1497
		facing = 1, -- 1497
		crouch = false, -- 1497
		rollT = 0, -- 1497
		covered = false, -- 1497
		alive = true -- 1497
	} -- 1497
	self.cam.x = x -- 1499
	self.cam.y = y + CAM_LOOK_UP -- 1500
	self.phase = "run" -- 1501
	self.hp = self.maxHp -- 1502
	if self:isEscortRoom() and self.run.story.route == "soldier" then -- 1503
		if self.run.story.talents == nil then -- 1504
			self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 1505
		end -- 1505
		local st = self.run.story.talents -- 1507
		local variants = ESCORT_VARIANTS[wr.key] -- 1508
		if self.run.source ~= "debug" and variants ~= nil and #variants > 0 then -- 1509
			st.variant = pickEscortVariant(self.run.seed, st.attempt, wr.key, #variants) -- 1510
		else -- 1510
			st.variant = 0 -- 1512
		end -- 1512
		if wr.key == "escort3" then -- 1516
			if st.room ~= "escort3" then -- 1517
				st.room = "escort3" -- 1518
				st.deferred = true -- 1519
				st.offers = {} -- 1520
			end -- 1520
		else -- 1520
			draftTalentOffers(st, wr.key, self.equippedWeapon) -- 1523
		end -- 1523
	end -- 1523
	self:buildEnemies() -- 1526
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1527
	local i = 0 -- 1528
	do -- 1528
		i = 0 -- 1529
		while i < #self.boxes do -- 1529
			do -- 1529
				local b = self.boxes[i + 1] -- 1530
				if b.id == nil then -- 1531
					goto __continue160 -- 1532
				end -- 1532
				local st = self.run.props[b.id] -- 1534
				if st ~= nil then -- 1535
					b.broken = st.broken -- 1536
					local ____temp_74 -- 1537
					if b.breakable == nil then -- 1537
						____temp_74 = nil -- 1537
					else -- 1537
						____temp_74 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1537
					end -- 1537
					b.breakable = ____temp_74 -- 1537
					b.hidden = b.hidden == true and st.revealed ~= true -- 1538
					if b.hidden then -- 1539
						b.broken = true -- 1540
					end -- 1540
				elseif b.hidden == true then -- 1542
					b.broken = true -- 1544
				end -- 1544
			end -- 1544
			::__continue160:: -- 1544
			i = i + 1 -- 1529
		end -- 1529
	end -- 1529
	if wr.cart.bodyW > 0 then -- 1547
		self.cartAxle = wr.cart.startX -- 1548
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1549
			self.cartAxle = wr.cart.endX -- 1550
			self.cartDocked = true -- 1551
		end -- 1551
	end -- 1551
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1554
end -- 1463
function Play.prototype.log(self, line) -- 1557
	local ____self_run_log_75 = self.run.log -- 1558
	____self_run_log_75[#____self_run_log_75 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1558
	if #self.run.log > 120 then -- 1559
		table.remove(self.run.log, 1) -- 1560
	end -- 1560
end -- 1557
function Play.prototype.buildEnemies(self) -- 1564
	self.enemies = {} -- 1565
	if self.isCampaign then -- 1566
		local variants = ESCORT_VARIANTS[self.room.key] -- 1567
		local useVariant = self:isEscortRoom() and self.run.story.route == "soldier" and self.run.source ~= "debug" and variants ~= nil and #variants > 0 -- 1568
		local ____useVariant_79 -- 1573
		if useVariant then -- 1573
			local ____temp_78 = #variants - 1 -- 1574
			local ____opt_76 = self.run.story.talents -- 1574
			____useVariant_79 = math.max( -- 1574
				0, -- 1574
				math.min(____temp_78, ____opt_76 and ____opt_76.variant or 0) -- 1574
			) -- 1574
		else -- 1574
			____useVariant_79 = 0 -- 1575
		end -- 1575
		local vIdx = ____useVariant_79 -- 1573
		local spawnList = useVariant and variants[vIdx + 1] or self.room.spawns -- 1576
		local i = 0 -- 1577
		do -- 1577
			i = 0 -- 1578
			while i < #spawnList do -- 1578
				local sp = spawnList[i + 1] -- 1579
				local kind = sp.kind or "gunner" -- 1580
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1581
				local sx = useVariant and self.ox + sp.x or sp.x -- 1582
				local ____self_enemies_80 = self.enemies -- 1583
				____self_enemies_80[#____self_enemies_80 + 1] = { -- 1583
					x = sx, -- 1584
					y = sp.y, -- 1584
					depth = sp.depth, -- 1584
					w = 26, -- 1584
					h = sp.h, -- 1584
					alive = true, -- 1584
					hitT = 0, -- 1584
					warnT = 0, -- 1584
					fireCd = 40, -- 1584
					kind = kind, -- 1585
					shieldHp = hp, -- 1585
					shieldHpMax = hp, -- 1585
					drop = sp.drop or "none", -- 1585
					homeX = sx, -- 1586
					swingT = 0, -- 1586
					awake = false, -- 1586
					squad = i -- 1586
				} -- 1586
				i = i + 1 -- 1578
			end -- 1578
		end -- 1578
		return -- 1589
	end -- 1589
	if self.room.key == "checkpoint" then -- 1591
		local ____self_enemies_81 = self.enemies -- 1592
		____self_enemies_81[#____self_enemies_81 + 1] = { -- 1592
			x = self.ox + 430, -- 1592
			y = 0, -- 1592
			w = 26, -- 1592
			h = 84, -- 1592
			alive = true, -- 1592
			hitT = 0, -- 1592
			warnT = 0, -- 1592
			fireCd = 0 -- 1592
		} -- 1592
		local ____self_enemies_82 = self.enemies -- 1593
		____self_enemies_82[#____self_enemies_82 + 1] = { -- 1593
			x = self.ox + 505, -- 1593
			y = 0, -- 1593
			w = 26, -- 1593
			h = 84, -- 1593
			alive = true, -- 1593
			hitT = 0, -- 1593
			warnT = 0, -- 1593
			fireCd = 0 -- 1593
		} -- 1593
		return -- 1594
	end -- 1594
	if self.room.key == "street" then -- 1596
		local ____self_enemies_83 = self.enemies -- 1598
		____self_enemies_83[#____self_enemies_83 + 1] = { -- 1598
			x = self.ox + 340, -- 1598
			y = 0, -- 1598
			w = 26, -- 1598
			h = 84, -- 1598
			alive = true, -- 1598
			hitT = 0, -- 1598
			warnT = 0, -- 1598
			fireCd = 0 -- 1598
		} -- 1598
		local ____self_enemies_84 = self.enemies -- 1599
		____self_enemies_84[#____self_enemies_84 + 1] = { -- 1599
			x = self.ox + 560, -- 1599
			y = 0, -- 1599
			w = 26, -- 1599
			h = 84, -- 1599
			alive = true, -- 1599
			hitT = 0, -- 1599
			warnT = 0, -- 1599
			fireCd = 0 -- 1599
		} -- 1599
	end -- 1599
end -- 1564
function Play.prototype.emit(self, name, data) -- 1605
	local ____self_events_85 = self.events -- 1606
	____self_events_85[#____self_events_85 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1606
	self.eventSeq = self.eventSeq + 1 -- 1607
	if #self.events > 256 then -- 1608
		table.remove(self.events, 1) -- 1609
	end -- 1609
end -- 1605
function Play.prototype.drainEvents(self) -- 1617
	local out = self.events -- 1618
	self.events = {} -- 1619
	return out -- 1620
end -- 1617
function Play.prototype.adoptEvents(self, events) -- 1629
	if #events == 0 then -- 1630
		return -- 1631
	end -- 1631
	local keep = {} -- 1633
	local i = 0 -- 1634
	do -- 1634
		i = 0 -- 1635
		while i < #events do -- 1635
			do -- 1635
				local e = events[i + 1] -- 1636
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1637
					goto __continue181 -- 1638
				end -- 1638
				keep[#keep + 1] = e -- 1640
			end -- 1640
			::__continue181:: -- 1640
			i = i + 1 -- 1635
		end -- 1635
	end -- 1635
	if #keep == 0 then -- 1642
		return -- 1643
	end -- 1643
	self.events = __TS__ArrayConcat(keep, self.events) -- 1645
	do -- 1645
		i = 0 -- 1646
		while i < #self.events do -- 1646
			self.events[i + 1].seq = i -- 1647
			i = i + 1 -- 1646
		end -- 1646
	end -- 1646
	self.eventSeq = #self.events -- 1649
end -- 1629
function Play.prototype.talentRank(self, talent) -- 1652
	if self.storyRoute == "soldier" and self:isEscortRoom() and self.run.story.talents ~= nil then -- 1653
		return self.run.story.talents.ranks[talent] or 0 -- 1654
	end -- 1654
	return 0 -- 1656
end -- 1652
function Play.prototype.reloadNeedTicks(self) -- 1660
	return RELOAD_ANSWER_TICKS + 60 * self:talentRank("focus") -- 1661
end -- 1660
function Play.prototype.getStoryTalentOffers(self) -- 1665
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1666
		return {} -- 1667
	end -- 1667
	local st = self.run.story.talents -- 1669
	return st ~= nil and st.room == self.room.key and st.offers or ({}) -- 1670
end -- 1665
function Play.prototype.getStoryTalentRanks(self) -- 1674
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() then -- 1675
		return nil -- 1676
	end -- 1676
	return self.run.story.talents ~= nil and self.run.story.talents.ranks or nil -- 1678
end -- 1674
function Play.prototype.getEscortAttempt(self) -- 1682
	return self.run.story.talents ~= nil and math.max(1, self.run.story.talents.attempt) or 1 -- 1683
end -- 1682
function Play.prototype.chooseTalent(self, slot) -- 1686
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1687
		return false -- 1688
	end -- 1688
	local st = self.run.story.talents -- 1690
	local talent = st ~= nil and st.offers[slot + 1] or nil -- 1691
	if st == nil or talent == nil then -- 1692
		return false -- 1693
	end -- 1693
	st.ranks[talent] = (st.ranks[talent] or 0) + 1 -- 1695
	st.offers = {} -- 1696
	self.talentModalActive = false -- 1697
	local extraMsg = "" -- 1698
	if talent == "vitality" then -- 1699
		self.maxHp = self.maxHp + 1 -- 1700
		self.hp = self.hp + 1 -- 1701
		self.run.story.maxHp = self.maxHp -- 1702
		self.run.story.hp = self.hp -- 1703
	elseif talent == "salvage" then -- 1704
		local inv = self.run.inventory -- 1705
		if inv.wood < 2 and inv.wood <= inv.bell or inv.bell >= 1 and st.ranks.salvage % 2 == 1 then -- 1706
			inv.wood = inv.wood + 1 -- 1707
			extraMsg = " · 得木纹筹×1" -- 1708
		else -- 1708
			inv.bell = inv.bell + 1 -- 1710
			extraMsg = " · 得铃纹筹×1" -- 1711
		end -- 1711
		self:syncCraftBench() -- 1713
	end -- 1713
	self.sessionDirty = true -- 1715
	self:flashSet(("本领 · " .. talentNames[talent]) .. extraMsg, 1.5) -- 1716
	self:emit("storyBeat", {beat = "talent_picked", talent = talent, rank = st.ranks[talent], room = self.room.key}) -- 1717
	return true -- 1718
end -- 1686
function Play.prototype.beginReload(self) -- 1725
	self.reloadT = self:reloadTicks() -- 1726
	local camp = self.room.campaign -- 1727
	if camp ~= nil and camp.reloadPuzzle == true then -- 1728
		self:openReloadPuzzle() -- 1729
	end -- 1729
end -- 1725
function Play.prototype.openReloadPuzzle(self) -- 1734
	self.reloadOpen = true -- 1735
	self.reloadAnswerTicks = 0 -- 1736
	self.reloadWorldTicks = 0 -- 1737
	self.reloadPath = {RELOAD_START} -- 1738
	self.reloadPendingEffect = "" -- 1739
	self.reloadTryCount = self.reloadTryCount + 1 -- 1740
	self:emit( -- 1741
		"reloadOpen", -- 1741
		{ -- 1741
			tryCount = self.reloadTryCount, -- 1741
			needTicks = self:reloadNeedTicks() -- 1741
		} -- 1741
	) -- 1741
end -- 1734
function Play.prototype.closeReloadPuzzle(self) -- 1745
	self.reloadOpen = false -- 1746
	self.reloadAnswerTicks = 0 -- 1747
	self.reloadWorldTicks = 0 -- 1748
	self.reloadPath = {RELOAD_START} -- 1749
	self.reloadPendingEffect = "" -- 1750
end -- 1745
function Play.prototype.reloadTapNode(self, node) -- 1757
	if not self.reloadOpen then -- 1758
		return -- 1759
	end -- 1759
	local path = self.reloadPath -- 1761
	local last = path[#path] -- 1762
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1763
		self.reloadPath = {RELOAD_START} -- 1764
		self:emit("reloadInvalid", {node = node, at = last}) -- 1765
		return -- 1766
	end -- 1766
	path[#path + 1] = node -- 1768
	if node ~= RELOAD_TARGET then -- 1769
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1770
		return -- 1771
	end -- 1771
	if not reloadPathValid(path) then -- 1773
		self.reloadPath = {RELOAD_START} -- 1774
		self:emit("reloadInvalid", {node = node, at = last}) -- 1775
		return -- 1776
	end -- 1776
	self.reloadPendingEffect = reloadEffectOf(path) -- 1778
	self.reloadOpen = false -- 1779
	self.reloadT = 0 -- 1780
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1781
	self:flashSet( -- 1784
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1784
		1.4 -- 1784
	) -- 1784
end -- 1757
function Play.prototype.consumeReloadEffect(self) -- 1788
	local e = self.reloadPendingEffect -- 1789
	if e ~= "" then -- 1790
		self.reloadPendingEffect = "" -- 1791
	end -- 1791
	return e -- 1793
end -- 1788
function Play.prototype.echoToSource(self, from, count, delayTicks) -- 1800
	if count == nil then -- 1800
		count = 1 -- 1800
	end -- 1800
	if delayTicks == nil then -- 1800
		delayTicks = 60 -- 1800
	end -- 1800
	local best = -1 -- 1801
	local bestD = 1000000000 -- 1802
	local i = 0 -- 1803
	local woken = {} -- 1804
	local n = 0 -- 1805
	while n < count do -- 1806
		best = -1 -- 1807
		bestD = 1000000000 -- 1808
		do -- 1808
			i = 0 -- 1809
			while i < #self.enemies do -- 1809
				do -- 1809
					if woken[i] == true then -- 1810
						goto __continue215 -- 1811
					end -- 1811
					local e = self.enemies[i + 1] -- 1813
					if not e.alive then -- 1814
						goto __continue215 -- 1815
					end -- 1815
					local d = math.abs(e.x - from.x) -- 1817
					if d < bestD then -- 1818
						bestD = d -- 1819
						best = i -- 1820
					end -- 1820
				end -- 1820
				::__continue215:: -- 1820
				i = i + 1 -- 1809
			end -- 1809
		end -- 1809
		if best < 0 then -- 1823
			break -- 1824
		end -- 1824
		woken[best] = true -- 1826
		local e = self.enemies[best + 1] -- 1827
		e.awake = true -- 1828
		e.warnT = 0 -- 1829
		e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 1830
		n = n + 1 -- 1831
	end -- 1831
	if n == 0 then -- 1833
		return -- 1834
	end -- 1834
	self:flashSet(n > 1 and "回声引到多处声源 · 敌群同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1836
end -- 1800
function Play.prototype.reloadTicks(self) -- 1839
	return math.max(6, self.run.inventory.quickbelt > 0 and 36 or 54) -- 1840
end -- 1839
function Play.prototype.update(self, dt, input) -- 1843
	self:syncCraftBench() -- 1844
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1845
		self:closeCraftBench() -- 1846
		return -- 1847
	end -- 1847
	if input.pause.pressed then -- 1849
		self.paused = not self.paused -- 1850
	end -- 1850
	if self.flashT > 0 then -- 1852
		self.flashT = self.flashT - dt -- 1853
		if self.flashT <= 0 then -- 1854
			self.flash = "" -- 1855
		end -- 1855
	end -- 1855
	if self.traceT > 0 then -- 1858
		self.traceT = self.traceT - dt -- 1859
		if self.traceT <= 0 then -- 1860
			self.trace = nil -- 1861
		end -- 1861
	end -- 1861
	if self.paused then -- 1864
		self:updateCamera(dt) -- 1865
		return -- 1866
	end -- 1866
	if self.escortFailed then -- 1869
		self.escortFailedTicks = self.escortFailedTicks + 1 -- 1870
		self:updateCamera(dt) -- 1871
		return -- 1872
	end -- 1872
	if self.craftBench.active then -- 1876
		self:updateCamera(dt) -- 1877
		return -- 1878
	end -- 1878
	if self.talentModalActive and #self:getStoryTalentOffers() > 0 and not self.reloadOpen then -- 1881
		self:updateCamera(dt) -- 1882
		return -- 1883
	end -- 1883
	if self.reloadOpen then -- 1888
		local needTicks = self:reloadNeedTicks() -- 1889
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1890
		if self.reloadAnswerTicks > needTicks then -- 1891
			self.reloadOpen = false -- 1892
			self.reloadPendingEffect = "" -- 1893
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = needTicks}) -- 1894
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1895
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1896
			self:updateCamera(dt) -- 1897
			return -- 1898
		else -- 1898
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1900
		end -- 1900
	end -- 1900
	self.ticks = self.ticks + 1 -- 1904
	if self.invulnT > 0 then -- 1907
		self.invulnT = self.invulnT - 1 -- 1908
	end -- 1908
	if self.isCampaign then -- 1910
		local ____self_run_86, ____ticks_87 = self.run, "ticks" -- 1911
		____self_run_86[____ticks_87] = ____self_run_86[____ticks_87] + 1 -- 1911
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1912
	end -- 1912
	local p = self.player -- 1914
	self:stepPlayer(p, dt, input) -- 1915
	self:refreshCover(p, input) -- 1917
	if self.carryOn then -- 1918
		self:carryPose() -- 1919
	end -- 1919
	if self.isCampaign then -- 1921
		self:stepCampaign(dt, input) -- 1922
		if not self.carryOn then -- 1923
			self:stepCampaignPartner(dt) -- 1924
		end -- 1924
	end -- 1924
	self:stepEnemies(dt, input) -- 1929
	if not self.isCampaign then -- 1930
		self:stepStory(dt, input) -- 1931
		self:stepEscort(dt, input) -- 1932
		self:stepVillage(dt, input) -- 1933
		self:stepChase(dt, input) -- 1934
		self:stepInteract(dt, input) -- 1935
	end -- 1935
	self:updateGate() -- 1937
	self:updateCamera(dt) -- 1938
	self:syncStory() -- 1940
end -- 1843
function Play.prototype.underLowArch(self, a) -- 1947
	local arch = self.room.arch -- 1948
	if arch.h <= 0 then -- 1949
		return false -- 1950
	end -- 1950
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1952
		return false -- 1953
	end -- 1953
	local top = arch.y + arch.h -- 1955
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1956
end -- 1947
function Play.prototype.coverAt(self, a) -- 1963
	local best = nil -- 1964
	local bestGap = 24 -- 1965
	local half = a.w / 2 -- 1966
	local i = 0 -- 1967
	do -- 1967
		i = 0 -- 1968
		while i < #self.boxes do -- 1968
			do -- 1968
				local b = self.boxes[i + 1] -- 1969
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1970
					goto __continue248 -- 1971
				end -- 1971
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1973
					goto __continue248 -- 1974
				end -- 1974
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1976
				if gap < bestGap then -- 1977
					bestGap = gap -- 1978
					best = b -- 1979
				end -- 1979
			end -- 1979
			::__continue248:: -- 1979
			i = i + 1 -- 1968
		end -- 1968
	end -- 1968
	return best -- 1982
end -- 1963
function Play.prototype.nearCover(self, a) -- 1985
	return self:coverAt(a) ~= nil -- 1986
end -- 1985
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1990
	if enemy == nil then -- 1991
		return false -- 1992
	end -- 1992
	local fromRight = enemy.x >= a.x -- 1994
	local edge = fromRight and b.x0 or b.x1 -- 1995
	local ____fromRight_88 -- 1996
	if fromRight then -- 1996
		____fromRight_88 = edge >= a.x - 0.001 and edge <= enemy.x -- 1996
	else -- 1996
		____fromRight_88 = edge <= a.x + 0.001 and edge >= enemy.x -- 1997
	end -- 1997
	local between = ____fromRight_88 -- 1996
	local separation = enemy.x - a.x -- 1998
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1999
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 2000
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 2001
end -- 1990
function Play.prototype.nearestEnemy(self, a) -- 2004
	local best -- 2005
	local bestD = 1000000000 -- 2006
	local i = 0 -- 2007
	do -- 2007
		i = 0 -- 2008
		while i < #self.enemies do -- 2008
			do -- 2008
				local e = self.enemies[i + 1] -- 2009
				if not e.alive then -- 2010
					goto __continue257 -- 2011
				end -- 2011
				local d = math.abs(e.x - a.x) -- 2013
				if d < bestD then -- 2014
					bestD = d -- 2015
					best = e -- 2016
				end -- 2016
			end -- 2016
			::__continue257:: -- 2016
			i = i + 1 -- 2008
		end -- 2008
	end -- 2008
	return best -- 2019
end -- 2004
function Play.prototype.refreshCover(self, a, input) -- 2023
	if self.childMode then -- 2024
		self.coverNear = false -- 2025
		self.coverHug = false -- 2026
		self.coverEntity = "" -- 2027
		self.coverBlocking = false -- 2028
		a.covered = false -- 2029
		return -- 2030
	end -- 2030
	local b = self:coverAt(a) -- 2032
	self.coverNear = b ~= nil -- 2033
	a.covered = self.coverNear and input.cover.held -- 2034
	self.coverHug = a.covered -- 2035
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 2036
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 2037
		b, -- 2037
		a, -- 2037
		self:nearestEnemy(a) -- 2037
	) -- 2037
end -- 2023
function Play.prototype.cartHandleInReach(self, a) -- 2041
	if a == nil then -- 2041
		a = self.player -- 2041
	end -- 2041
	local c = self.room.cart -- 2042
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 2043
		return false -- 2044
	end -- 2044
	local handleX = self.cartAxle + c.handleOffset -- 2046
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 2047
end -- 2041
function Play.prototype.nearLowLedge(self, a) -- 2052
	local reach = 26 -- 2053
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 2054
	local x1 = x0 + reach -- 2055
	local i = 0 -- 2056
	do -- 2056
		i = 0 -- 2057
		while i < #self.boxes do -- 2057
			do -- 2057
				local b = self.boxes[i + 1] -- 2058
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2059
					goto __continue266 -- 2060
				end -- 2060
				local rise = b.y1 - a.y -- 2062
				if rise > 0 and rise <= LEDGE_RISE then -- 2063
					return true -- 2064
				end -- 2064
			end -- 2064
			::__continue266:: -- 2064
			i = i + 1 -- 2057
		end -- 2057
	end -- 2057
	return false -- 2067
end -- 2052
function Play.prototype.stepPlayer(self, a, dt, input) -- 2070
	a.depthSpeed = 0 -- 2071
	if not a.alive then -- 2072
		return -- 2073
	end -- 2073
	local isChild = self.childMode -- 2075
	local lowArch = isChild and self:underLowArch(a) -- 2077
	if self:storyLocked() then -- 2079
		a.vx = 0 -- 2080
		a.crouch = isChild and lowArch -- 2081
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2082
		self:fallY(a, dt) -- 2083
		return -- 2084
	end -- 2084
	if not isChild and self.escort.state == "calming" then -- 2087
		a.crouch = false -- 2088
		a.h = SOLDIER_H -- 2089
		a.vx = 0 -- 2090
		self:fallY(a, dt) -- 2091
		return -- 2092
	end -- 2092
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 2094
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 2095
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2096
	local nearCover = not isChild and self:nearCover(a) -- 2097
	a.covered = nearCover and input.cover.held -- 2098
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 2100
	if a.rollT > 0 then -- 2103
		a.rollT = a.rollT - dt -- 2104
		local rollSpd = self:isEscortRoom() and ROLL_SPEED * (1 + 0.08 * self:talentRank("stride")) or ROLL_SPEED -- 2105
		a.vx = a.facing * rollSpd -- 2106
		self:slideX(a, a.vx * dt) -- 2107
		self:fallY(a, dt) -- 2108
		if a.rollT <= 0 then -- 2109
			self:flashSet("翻滚结束", 0.5) -- 2110
		end -- 2110
		return -- 2112
	end -- 2112
	local peacefulRoom = self.room.key == "museum" or self.room.key == "tower" -- 2115
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 2116
		if input.moveX ~= 0 then -- 2117
			a.facing = input.moveX > 0 and 1 or -1 -- 2118
		end -- 2118
		if self:nearLowLedge(a) then -- 2121
			a.vy = SOLDIER_JUMP -- 2122
			a.onGround = false -- 2123
			self:flashSet("翻上去", 0.3) -- 2124
			return -- 2125
		end -- 2125
		a.rollT = ROLL_TIME -- 2127
		self:flashSet("翻滚", 0.3) -- 2128
		return -- 2129
	end -- 2129
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 2132
	if isChild then -- 2133
		if input.cover.held then -- 2134
			speed = CHILD_SLOW -- 2135
		end -- 2135
		if a.crouch then -- 2137
			speed = CHILD_SLOW -- 2138
		elseif self.room.key == "forest" and self.forestPath == "ditch" and a.x >= self.ox + 700 and a.x <= self.ox + 1140 then -- 2139
			speed = CHILD_SPEED * 1.22 -- 2142
		end -- 2142
	else -- 2142
		if self:isEscortRoom() then -- 2145
			speed = speed * (1 + 0.1 * self:talentRank("stride")) -- 2146
		end -- 2146
		if a.covered then -- 2148
			speed = speed * 0.45 -- 2149
		end -- 2149
	end -- 2149
	local handsBusy = self.gripping or gripIntent or self.reloadOpen -- 2154
	local dir = (self.gripping or self.reloadOpen) and 0 or input.moveX -- 2155
	local depthDir = self.room.depth ~= nil and not handsBusy and (not isChild or self.phase == "prologue-escape") and -input.moveY or 0 -- 2157
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 2159
	if dir ~= 0 then -- 2160
		a.facing = dir > 0 and 1 or -1 -- 2161
	end -- 2161
	a.vx = dir * speed * diagonal -- 2163
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 2166
		a.vy = CHILD_JUMP -- 2167
		a.onGround = false -- 2168
		self:flashSet("跳", 0.25) -- 2169
	end -- 2169
	local previousDepth = a.depth -- 2173
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 2174
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2175
	self:slideX(a, a.vx * dt) -- 2176
	self:fallY(a, dt) -- 2177
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and not self.reloadOpen and input.fire.pressed then -- 2180
		self:shoot(a) -- 2181
	end -- 2181
	local ____temp_91 = not isChild and not peacefulRoom and not self.gripping and not self.reloadOpen and self.reloadPendingEffect == "" -- 2184
	if ____temp_91 then -- 2184
		local ____opt_89 = self.room.campaign -- 2185
		____temp_91 = (____opt_89 and ____opt_89.reloadPuzzle) == true -- 2184
	end -- 2184
	if ____temp_91 and input.flare.pressed then -- 2184
		self:beginReload() -- 2186
	end -- 2186
end -- 2070
function Play.prototype.stepPartner(self, p, dt) -- 2191
	local a = self.partner -- 2192
	if not a.alive then -- 2193
		return -- 2194
	end -- 2194
	a.crouch = false -- 2196
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 2197
	a.vx = 0 -- 2198
	a.depthSpeed = 0 -- 2199
	self:fallY(a, dt) -- 2200
end -- 2191
function Play.prototype.stepEscort(self, dt, input) -- 2207
	local a = self.partner -- 2208
	a.depthSpeed = 0 -- 2209
	if not a.alive then -- 2210
		return -- 2211
	end -- 2211
	if self.room.key == "gatepath" then -- 2213
		if self.carryOn then -- 2215
			return -- 2216
		end -- 2216
		local p = self.player -- 2219
		a.depth = p.depth -- 2220
		a.facing = p.facing -- 2221
		a.crouch = false -- 2222
		a.h = CHILD_H -- 2223
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 2224
		a.y = p.y -- 2225
		a.vy = 0 -- 2226
		a.vx = p.vx -- 2227
		a.onGround = p.onGround -- 2228
		return -- 2229
	end -- 2229
	if not self:escortOn() then -- 2231
		a.vx = 0 -- 2232
		self:fallY(a, dt) -- 2233
		return -- 2234
	end -- 2234
	local p = self.player -- 2236
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 2237
	local hadKnock1 = self.escort.knock1 -- 2238
	local hadKnock2 = self.escort.knock2 -- 2239
	self.calmConsumed = self.escort:update( -- 2240
		input, -- 2240
		p.x, -- 2240
		p.facing, -- 2240
		a.x, -- 2240
		dist -- 2240
	) -- 2240
	if not hadKnock1 and self.escort.knock1 then -- 2242
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 2243
	end -- 2243
	if not hadKnock2 and self.escort.knock2 then -- 2245
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 2246
	end -- 2246
	a.crouch = self.escort.crouchPose -- 2248
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 2249
	if not self.escort.stopped then -- 2250
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 2251
		local previousDepth = a.depth -- 2252
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 2253
		local distance = math.max( -- 2254
			-travel, -- 2254
			math.min(travel, targetDepth - previousDepth) -- 2254
		) -- 2254
		self:slideDepth(a, distance) -- 2255
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2256
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 2257
			a.vy = CHILD_JUMP -- 2258
			a.onGround = false -- 2259
		end -- 2259
	end -- 2259
	local dir = self.escort:moveDir(a.x) -- 2262
	a.vx = dir * CHILD_SPEED -- 2263
	if dir ~= 0 then -- 2264
		a.facing = dir -- 2265
		local before = a.x -- 2266
		self:slideX(a, dir * CHILD_SPEED * dt) -- 2267
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 2269
			a.vy = CHILD_JUMP -- 2270
			a.onGround = false -- 2271
		end -- 2271
	end -- 2271
	self:fallY(a, dt) -- 2274
end -- 2207
function Play.prototype.escortOn(self) -- 2278
	if self.room.key == "checkpoint" then -- 2279
		return true -- 2280
	end -- 2280
	if self.room.key == "gatepath" then -- 2282
		return true -- 2283
	end -- 2283
	if self.room.key == "prologue" then -- 2285
		return self.phase == "prologue-follow" -- 2286
	end -- 2286
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 2288
		return true -- 2290
	end -- 2290
	return self.room.key == "street" -- 2292
end -- 2278
function Play.prototype.storyLocked(self) -- 2296
	if self.caughtT > 0 then -- 2297
		return true -- 2298
	end -- 2298
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 2300
		return true -- 2302
	end -- 2302
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 2304
		return true -- 2305
	end -- 2305
	if self.room.key == "gate" and (self.phase == "gate-farewell" or self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 2307
		return true -- 2308
	end -- 2308
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2310
		return true -- 2311
	end -- 2311
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2313
		return true -- 2314
	end -- 2314
	if self.craftBench.active then -- 2317
		return true -- 2318
	end -- 2318
	return false -- 2320
end -- 2296
function Play.prototype.swapToChild(self, x) -- 2324
	local tmp = self.player -- 2325
	self.player = self.partner -- 2326
	self.partner = tmp -- 2327
	self.childMode = true -- 2328
	self.player.alive = true -- 2329
	self.player.x = self.ox + x -- 2330
	self.player.y = 0 -- 2331
	self.player.depth = 0 -- 2332
	self.player.depthSpeed = 0 -- 2333
	self.player.vy = 0 -- 2334
	self.player.vx = 0 -- 2335
	self.player.onGround = true -- 2336
	self.player.crouch = false -- 2337
	self.player.h = CHILD_H -- 2338
	self.player.facing = 1 -- 2339
	self.partner.alive = true -- 2340
	self.cam.x = self.player.x -- 2341
end -- 2324
function Play.prototype.swapToSoldier(self, x, childX) -- 2345
	local tmp = self.player -- 2346
	self.player = self.partner -- 2347
	self.partner = tmp -- 2348
	self.childMode = false -- 2349
	self.player.alive = true -- 2350
	self.player.x = self.ox + x -- 2351
	self.player.y = 0 -- 2352
	self.player.depth = 0 -- 2353
	self.player.depthSpeed = 0 -- 2354
	self.player.vy = 0 -- 2355
	self.player.vx = 0 -- 2356
	self.player.onGround = true -- 2357
	self.player.crouch = false -- 2358
	self.player.h = SOLDIER_H -- 2359
	self.player.facing = 1 -- 2360
	self.partner.alive = true -- 2361
	self.partner.x = self.ox + childX -- 2362
	self.partner.y = 0 -- 2363
	self.partner.depth = 0 -- 2364
	self.partner.depthSpeed = 0 -- 2365
	self.partner.vx = 0 -- 2366
	self.partner.vy = 0 -- 2367
	self.partner.onGround = true -- 2368
	self.partner.crouch = true -- 2369
	self.partner.h = CHILD_CROUCH_H -- 2370
	self.cam.x = self.player.x -- 2371
end -- 2345
function Play.prototype.stepStory(self, dt, input) -- 2375
	if self.room.key == "prologue" then -- 2376
		self:stepPrologue(dt, input) -- 2377
	elseif self.room.key == "street" then -- 2378
		self:stepStreet(dt, input) -- 2379
	elseif self.room.key == "gate" then -- 2380
		self:stepGate(dt, input) -- 2381
	elseif self.room.key == "gatepath" then -- 2382
		self:stepGatePath() -- 2383
	elseif self.room.key == "tower" then -- 2384
		self:stepTower(dt, input) -- 2385
	elseif self.room.key == "museum" then -- 2386
		self:stepMuseum(dt, input) -- 2387
	end -- 2387
end -- 2375
function Play.prototype.canPersistProgress(self) -- 2393
	return not self.isCampaign and self.run.source == "official" -- 2394
end -- 2393
function Play.prototype.wellWindow(self) -- 2398
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 2399
end -- 2398
function Play.prototype.nearWell(self) -- 2404
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 2405
end -- 2404
function Play.prototype.pickWell(self) -- 2413
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2414
		return false -- 2415
	end -- 2415
	self.phase = "prologue-well" -- 2417
	self.phaseTick = 0 -- 2418
	self.wellOpen = false -- 2419
	self:flashSet("井沿 · 伸手下去", 1.4) -- 2420
	self:log("旧井拾取") -- 2421
	return true -- 2422
end -- 2413
function Play.prototype.stepPrologue(self, dt, input) -- 2425
	local child = self.partner -- 2426
	if self.museumReturn then -- 2427
		self.museumReturn = false -- 2429
		self.phase = "prologue-wait" -- 2430
		self.phaseTick = 0 -- 2431
		self.player.x = self.ox + 260 -- 2432
		self.player.y = 0 -- 2433
		self.player.depth = 0 -- 2434
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2435
	end -- 2435
	if self.phase == "prologue-wake" then -- 2438
		self.introTick = self.introTick + 1 -- 2439
		if self.introTick == 60 then -- 2440
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2441
		end -- 2441
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2443
			self.phase = "prologue-shadow" -- 2444
			self.introTick = 0 -- 2445
			self:flashSet("门缝里两道影子", 1.2) -- 2446
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2447
		end -- 2447
		return -- 2449
	end -- 2449
	if self.phase == "prologue-shadow" then -- 2451
		self.introTick = self.introTick + 1 -- 2452
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2453
			self.phase = "prologue-escape" -- 2455
			self.introTick = 0 -- 2456
			self.escapeRemaining = self.escapeDuration -- 2457
			self.escapeRetryCount = 0 -- 2458
			self:swapToChild(100) -- 2459
			self:flashSet( -- 2460
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2460
				1.6 -- 2460
			) -- 2460
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2461
		end -- 2461
		return -- 2465
	end -- 2465
	if self.phase == "prologue-escape" then -- 2467
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2468
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2469
			self.phase = "prologue-hide" -- 2471
			self.introTick = 0 -- 2472
			self.player.vx = 0 -- 2473
			self.player.crouch = true -- 2474
			self.player.h = CHILD_CROUCH_H -- 2475
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2476
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2477
			return -- 2481
		end -- 2481
		if self.escapeRemaining <= 0 then -- 2483
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2485
			self.player.x = self.ox + 100 -- 2486
			self.player.y = 0 -- 2487
			self.player.depth = 0 -- 2488
			self.player.vx = 0 -- 2489
			self.player.vy = 0 -- 2490
			self.escapeRemaining = self.escapeDuration -- 2491
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2492
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2493
			return -- 2494
		end -- 2494
		return -- 2496
	end -- 2496
	if self.phase == "prologue-hide" then -- 2498
		self.introTick = self.introTick + 1 -- 2499
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2500
			self.phase = "prologue-wait" -- 2502
			self.phaseTick = 0 -- 2503
			self.introTick = 0 -- 2504
			self:swapToSoldier(260, 300) -- 2505
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2506
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2507
		end -- 2507
		return -- 2509
	end -- 2509
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2512
	if self.phase == "prologue-wait" then -- 2513
		child.crouch = true -- 2514
		child.h = CHILD_CROUCH_H -- 2515
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2516
			self:pickWell() -- 2517
			return -- 2518
		end -- 2518
		if not self.wellOpen and self:canPersistProgress() and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2521
			self.archive.museumPhase = "well_reflect" -- 2523
			self.archiveDirty = true -- 2524
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2525
			return -- 2526
		end -- 2526
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2528
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2530
		if near and input.interact.pressed then -- 2531
			self.phase = "prologue-give" -- 2532
			self.phaseTick = 0 -- 2533
			self:flashSet("递出针套", 1) -- 2534
		end -- 2534
		return -- 2536
	end -- 2536
	if self.phase == "prologue-well" then -- 2538
		self.phaseTick = self.phaseTick + 1 -- 2540
		if self.phaseTick == 12 then -- 2541
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2542
		elseif self.phaseTick >= 30 then -- 2543
			self.phase = "prologue-wait" -- 2544
			self.phaseTick = 0 -- 2545
			self.wellTaken = true -- 2546
			self.wellOpen = false -- 2547
			self.run.archive.artifactOwned = true -- 2548
			self.archiveDirty = true -- 2549
			self:emit("artifactFound", { -- 2550
				x = self.ox + self.wellX, -- 2551
				y = 0, -- 2551
				room = "prologue", -- 2551
				once = true, -- 2551
				source = self.run.source -- 2552
			}) -- 2552
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2554
			self:log("井底取到时间穿梭器") -- 2555
		end -- 2555
		return -- 2557
	end -- 2557
	if self.phase == "prologue-give" then -- 2559
		self.phaseTick = self.phaseTick + 1 -- 2560
		if self.phaseTick == 36 then -- 2561
			self:flashSet("针套递过去", 0.9) -- 2562
		elseif self.phaseTick == 108 then -- 2563
			self:flashSet("纸条塞进针套", 1) -- 2564
		elseif self.phaseTick >= ____exports.PROLOGUE_GIVE_TICKS then -- 2565
			self.phase = "prologue-follow" -- 2566
			self.phaseTick = 0 -- 2567
			child.crouch = false -- 2568
			child.h = CHILD_H -- 2569
			self:flashSet("她跟上了", 1.2) -- 2570
		end -- 2570
		return -- 2572
	end -- 2572
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2575
		local next = self.run.source == "debug" and "street" or "s1-crossroad" -- 2576
		self:requestRoom(next, "序章跟到门口") -- 2577
		self:flashSet(next == "s1-crossroad" and "进十字街" or "进街道", 1.2) -- 2578
	end -- 2578
end -- 2425
function Play.prototype.stepStreet(self, dt, input) -- 2583
	local p = self.player -- 2584
	local c = self.partner -- 2585
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2586
		local next = self.run.source == "debug" and "checkpoint" or "s1-crossroad" -- 2587
		self:requestRoom(next, "两人都到街尾") -- 2588
		self:flashSet(next == "s1-crossroad" and "进十字街" or "到检查站", 1.2) -- 2589
	end -- 2589
end -- 2583
function Play.prototype.stepGate(self, dt, input) -- 2594
	local ____temp_92 -- 2595
	if self.room.story == nil then -- 2595
		____temp_92 = nil -- 2595
	else -- 2595
		____temp_92 = self.room.story.gate -- 2595
	end -- 2595
	local g = ____temp_92 -- 2595
	if g == nil then -- 2596
		return -- 2597
	end -- 2597
	local p = self.player -- 2599
	if self.phase == "gate-idle" then -- 2600
		local a = self.partner -- 2602
		local gap = g.waitX - a.x -- 2603
		if math.abs(gap) > 3 then -- 2604
			a.facing = gap > 0 and 1 or -1 -- 2605
			a.vx = a.facing * CHILD_SPEED -- 2606
			local beforeX = a.x -- 2607
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2608
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2609
				a.vy = CHILD_JUMP -- 2610
				a.onGround = false -- 2611
			end -- 2611
			self:fallY(a, dt) -- 2613
		else -- 2613
			a.vx = 0 -- 2615
			a.x = g.waitX -- 2616
		end -- 2616
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2619
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2620
		if self.gateNeedConfirm then -- 2621
			if not input.interact.held then -- 2624
				self.gateRestartArmed = true -- 2625
			end -- 2625
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2627
				self.gateNeedConfirm = false -- 2628
				self.gateRestartArmed = true -- 2629
				self.phase = "gate-hold" -- 2630
				self.gateTick = 0 -- 2631
				self.gateSpawned = 0 -- 2632
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2633
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2634
			end -- 2634
			return -- 2636
		end -- 2636
		if atWinch and atWait then -- 2638
			self.phase = "gate-hold" -- 2639
			self.gateTick = 0 -- 2640
			self.gateSpawned = 0 -- 2641
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2642
		end -- 2642
		return -- 2644
	end -- 2644
	if self.phase == "gate-hold" then -- 2646
		self.gateTick = self.gateTick + 1 -- 2647
		local marks = {0, 540, 900, 1500} -- 2649
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2650
			local idx = self.gateSpawned -- 2651
			local ____self_enemies_93 = self.enemies -- 2652
			____self_enemies_93[#____self_enemies_93 + 1] = { -- 2652
				x = self.ox + 620 + idx * 62, -- 2653
				y = 0, -- 2653
				w = 26, -- 2653
				h = 84, -- 2653
				alive = true, -- 2654
				hitT = 0, -- 2654
				warnT = 0, -- 2654
				fireCd = 90 + idx * 45 -- 2654
			} -- 2654
			self.gateSpawned = self.gateSpawned + 1 -- 2656
			self:flashSet( -- 2657
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2657
				0.9 -- 2657
			) -- 2657
		end -- 2657
		if self.gateTick == 900 then -- 2659
			self:flashSet("棚布落下", 1) -- 2660
		elseif self.gateTick == 2100 then -- 2661
			self:flashSet("门底透进冷光了", 1) -- 2662
		end -- 2662
		if self.gateTick >= g.holdTicks then -- 2664
			self:captureGateBlood() -- 2667
			self.phase = "gate-send" -- 2668
			self.phaseTick = 0 -- 2669
			self.enemies = {} -- 2671
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2672
		end -- 2672
		return -- 2674
	end -- 2674
	if self.phase == "gate-send" then -- 2676
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2677
		if near and input.interact.pressed then -- 2678
			self:commitRoute() -- 2681
			self:swapToChild(g.doorX + 30) -- 2682
			self.phase = self.run.source == "debug" and "gate-count" or "gate-farewell" -- 2683
			self.phaseTick = 0 -- 2684
			self.countTick = 0 -- 2685
			self.countArmed = false -- 2687
			self.countPrevMove = input.moveX -- 2688
			self:flashSet("门开了 · 送她出去", 1.8) -- 2689
		end -- 2689
		return -- 2691
	end -- 2691
	if self.phase == "gate-farewell" then -- 2693
		self.phaseTick = self.phaseTick + 1 -- 2694
		self.countPrevMove = input.moveX -- 2695
		if self.phaseTick >= ____exports.GATE_FAREWELL_TICKS then -- 2696
			self.phase = "gate-count" -- 2697
			self.phaseTick = 0 -- 2698
			self.countTick = 0 -- 2699
			self.countArmed = false -- 2700
		end -- 2700
		return -- 2702
	end -- 2702
	if self.phase == "gate-count" then -- 2704
		self.countTick = self.countTick + 1 -- 2705
		if self.countTick == 360 then -- 2706
			self:flashSet("门关上", 0.9) -- 2707
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2708
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2709
			if self.storyRoute == "soldier" then -- 2713
				self.phase = "gate-wait" -- 2715
				self.phaseTick = 0 -- 2716
				self.knocks = 1 -- 2717
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2718
				self.handArmed = not input.interact.held and not self.intentGateReunionHold -- 2720
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2721
			else -- 2721
				self:flashSet("数到二十", 2.2) -- 2723
			end -- 2723
		end -- 2723
		local prevMove = self.countPrevMove -- 2728
		self.countPrevMove = input.moveX -- 2729
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2730
			if prevMove <= 0 and input.moveX > 0 then -- 2731
				self.countArmed = true -- 2732
			end -- 2732
			if self.countArmed and input.moveX > 0 then -- 2734
				self.phase = "gate-walk" -- 2735
				self.phaseTick = 0 -- 2736
				self:flashSet("她迈出第一步", 1.4) -- 2737
				self:emit("storyExit", { -- 2738
					route = "child", -- 2738
					via = "walk", -- 2738
					countTick = self.countTick, -- 2738
					hp = self.hp, -- 2738
					maxHp = self.maxHp -- 2738
				}) -- 2738
			end -- 2738
		end -- 2738
		return -- 2741
	end -- 2741
	if self.phase == "gate-wait" then -- 2743
		self.phaseTick = self.phaseTick + 1 -- 2745
		if self.phaseTick == 12 then -- 2746
			self.knocks = 2 -- 2747
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2748
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2749
		end -- 2749
		local held = input.interact.held or self.intentGateReunionHold -- 2751
		if not held then -- 2752
			if self.handTicks > 0 then -- 2753
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2754
			end -- 2754
			self.handTicks = 0 -- 2756
			self.handArmed = true -- 2757
			return -- 2758
		end -- 2758
		if self.handArmed then -- 2760
			self.handTicks = self.handTicks + 1 -- 2761
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2762
				self.intentGateReunionHold = false -- 2763
				self.phase = "gate-hand" -- 2764
				self.phaseTick = 0 -- 2765
				self.handDone = true -- 2766
				self.tied = true -- 2767
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2768
				if not self.lineSaid then -- 2769
					self.lineSaid = true -- 2770
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2771
				end -- 2771
				self:flashSet("我们走吧。", 3) -- 2773
			end -- 2773
		end -- 2773
		return -- 2776
	end -- 2776
	if self.phase == "gate-hand" then -- 2778
		self.phaseTick = self.phaseTick + 1 -- 2780
		if self.phaseTick == 30 then -- 2781
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2782
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2783
			self:emit("storyExit", { -- 2784
				route = "soldier", -- 2784
				via = "hand", -- 2784
				handTicks = self.handTicks, -- 2784
				hp = self.hp, -- 2784
				maxHp = self.maxHp -- 2784
			}) -- 2784
			self:requestRoom("gatepath", "牵手同行") -- 2785
		end -- 2785
		return -- 2787
	end -- 2787
	if self.phase == "gate-walk" then -- 2790
		if self.player.x >= g.exitX then -- 2791
			self:requestRoom("outside", "走出城门") -- 2792
			self:flashSet("出城门 · 城外", 1.4) -- 2793
		end -- 2793
	end -- 2793
end -- 2594
function Play.prototype.captureGateBlood(self) -- 2802
	self.hpAtGate = self.hp -- 2803
	self.maxHpAtGate = self.maxHp -- 2804
end -- 2802
function Play.prototype.commitRoute(self) -- 2811
	if self.storySettled then -- 2812
		return -- 2813
	end -- 2813
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2815
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2816
	self.hpAtGate = hp -- 2817
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2818
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2819
	self.storySettled = true -- 2820
	self.sessionDirty = true -- 2821
	self:emit("storyRouteLocked", { -- 2822
		route = self.storyRoute, -- 2823
		hp = self.hp, -- 2823
		maxHp = self.maxHp, -- 2823
		hpAtGate = self.hpAtGate, -- 2824
		maxHpAtGate = self.maxHpAtGate -- 2824
	}) -- 2824
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2826
end -- 2811
function Play.prototype.syncStory(self) -- 2830
	local s = self.run.story -- 2831
	if s == nil then -- 2832
		return -- 2833
	end -- 2833
	s.hp = self.hp -- 2835
	s.maxHp = self.maxHp -- 2836
	s.route = self.storyRoute -- 2837
	s.settled = self.storySettled -- 2838
	s.hpAtGate = self.hpAtGate -- 2839
	s.maxHpAtGate = self.maxHpAtGate -- 2840
	s.handDone = self.handDone -- 2841
	s.lineSaid = self.lineSaid -- 2842
	s.tied = self.tied -- 2843
	s.carry = self.carryOn -- 2844
	s.museumReturn = self.museumReturn -- 2845
	s.escortDone = self.escortDone -- 2846
	s.craftedWeapon = self.run.story.craftedWeapon -- 2847
	s.equippedWeapon = self.equippedWeapon -- 2848
	s.ending = self.run.story.ending -- 2849
	if self.room.key == "gate" then -- 2850
		s.phase = self.phase -- 2851
		s.countTick = self.countTick -- 2852
		s.phaseTick = self.phaseTick -- 2853
		s.handTicks = self.handTicks -- 2854
	end -- 2854
	if self.room.key == "prologue" then -- 2856
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2858
			s.phase = self.phase -- 2859
			s.phaseTick = self.phaseTick -- 2860
		end -- 2860
	end -- 2860
	if self.room.key == "tower" then -- 2863
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2865
			s.phase = self.phase -- 2866
			s.phaseTick = self.phaseTick -- 2867
		end -- 2867
	end -- 2867
end -- 2830
function Play.prototype.stepGatePath(self) -- 2873
	local ____temp_94 -- 2874
	if self.room.story == nil then -- 2874
		____temp_94 = nil -- 2874
	else -- 2874
		____temp_94 = self.room.story.gatepath -- 2874
	end -- 2874
	local gp = ____temp_94 -- 2874
	if self.phase == "gatepath-start" then -- 2875
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2876
			self.carryOn = true -- 2877
			self.phase = "gatepath-carry" -- 2878
			self.phaseTick = 0 -- 2879
			self.pathDone = true -- 2880
			self.escortDone = false -- 2881
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2882
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2883
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2884
		end -- 2884
		return -- 2886
	end -- 2886
	if self.phase == "gatepath-carry" then -- 2888
		self.phaseTick = self.phaseTick + 1 -- 2889
		if self.phaseTick == 20 then -- 2890
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2891
		end -- 2891
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2893
			self:requestRoom(gp.next, "背负进首战") -- 2894
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2895
		end -- 2895
	end -- 2895
end -- 2873
function Play.prototype.carryPose(self) -- 2904
	local p = self.player -- 2905
	local a = self.partner -- 2906
	a.alive = true -- 2907
	a.x = p.x - p.facing * 12 -- 2908
	a.y = p.y + 26 -- 2909
	a.depth = p.depth -- 2910
	a.vx = p.vx -- 2911
	a.vy = 0 -- 2912
	a.onGround = true -- 2913
	a.crouch = false -- 2914
	a.h = CHILD_CROUCH_H -- 2915
	a.facing = p.facing -- 2916
end -- 2904
function Play.prototype.stepMuseum(self, dt, input) -- 2924
	self.partner.alive = false -- 2925
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2926
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2929
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 2930
	local intentTarget = self.pendingMuseumIntentTarget -- 2931
	self.pendingMuseumIntentTarget = "" -- 2932
	local interactHit = input.interact.pressed or intentTarget ~= "" -- 2933
	if self.phase == "museum-cabinet" then -- 2934
		if atCase and interactHit or intentTarget == "cabinet" then -- 2935
			self.phase = "museum-hall" -- 2936
			self.phaseTick = 0 -- 2937
			if self:canPersistProgress() then -- 2938
				self.archive.museumPhase = "hall_walk" -- 2939
				self.archiveDirty = true -- 2940
			end -- 2940
			self:emit( -- 2942
				"museumStep", -- 2942
				{ -- 2942
					step = "cabinet", -- 2942
					x = self.ox + mu.cabinetX, -- 2942
					persisted = self:canPersistProgress() -- 2942
				} -- 2942
			) -- 2942
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2943
		end -- 2943
		return -- 2945
	end -- 2945
	if self.phase == "museum-hall" then -- 2947
		if intentTarget == "lamp_direct" and nearLamp then -- 2948
			self:emit( -- 2949
				"museumStep", -- 2949
				{ -- 2949
					step = "hall", -- 2949
					x = self.ox + mu.hallX, -- 2949
					persisted = self:canPersistProgress() -- 2949
				} -- 2949
			) -- 2949
			self.phase = "museum-return" -- 2950
			self.phaseTick = 0 -- 2951
			if self:canPersistProgress() then -- 2952
				self.archive.museumPhase = "return_cabinet" -- 2953
				self.archiveDirty = true -- 2954
			end -- 2954
			self:emit( -- 2956
				"museumStep", -- 2956
				{ -- 2956
					step = "lamp", -- 2956
					x = self.ox + mu.lampX, -- 2956
					persisted = self:canPersistProgress() -- 2956
				} -- 2956
			) -- 2956
			self:flashSet("灯 · 转向西窗", 1.8) -- 2957
			return -- 2958
		end -- 2958
		if self.player.x >= self.ox + mu.hallX and interactHit then -- 2960
			self.phase = "museum-lamp" -- 2961
			self.phaseTick = 0 -- 2962
			if self:canPersistProgress() then -- 2963
				self.archive.museumPhase = "lamp_turn" -- 2964
				self.archiveDirty = true -- 2965
			end -- 2965
			self:emit( -- 2967
				"museumStep", -- 2967
				{ -- 2967
					step = "hall", -- 2967
					x = self.ox + mu.hallX, -- 2967
					persisted = self:canPersistProgress() -- 2967
				} -- 2967
			) -- 2967
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2968
		end -- 2968
		return -- 2970
	end -- 2970
	if self.phase == "museum-lamp" then -- 2972
		if nearLamp and interactHit then -- 2973
			self.phase = "museum-return" -- 2974
			self.phaseTick = 0 -- 2975
			if self:canPersistProgress() then -- 2976
				self.archive.museumPhase = "return_cabinet" -- 2977
				self.archiveDirty = true -- 2978
			end -- 2978
			self:emit( -- 2980
				"museumStep", -- 2980
				{ -- 2980
					step = "lamp", -- 2980
					x = self.ox + mu.lampX, -- 2980
					persisted = self:canPersistProgress() -- 2980
				} -- 2980
			) -- 2980
			self:flashSet("灯 · 转向西窗", 1.8) -- 2981
		end -- 2981
		return -- 2983
	end -- 2983
	if self.phase == "museum-return" then -- 2985
		if atCase and interactHit or intentTarget == "return_cabinet" then -- 2986
			self.phase = "museum-knock" -- 2987
			self.phaseTick = 0 -- 2988
			self:emit( -- 2989
				"museumStep", -- 2989
				{ -- 2989
					step = "knock", -- 2989
					count = 1, -- 2989
					x = self.ox + mu.cabinetX, -- 2989
					persisted = self:canPersistProgress() -- 2989
				} -- 2989
			) -- 2989
			self:flashSet("回柜边 · 第一下", 0.8) -- 2990
		end -- 2990
		return -- 2992
	end -- 2992
	if self.phase == "museum-knock" then -- 2994
		self.phaseTick = self.phaseTick + 1 -- 2995
		if self.phaseTick == 8 then -- 2996
			self:emit( -- 2997
				"museumStep", -- 2997
				{ -- 2997
					step = "knock", -- 2997
					count = 2, -- 2997
					x = self.ox + mu.cabinetX, -- 2997
					persisted = self:canPersistProgress() -- 2997
				} -- 2997
			) -- 2997
			self:flashSet("回柜边 · 第二下", 0.8) -- 2998
		elseif self.phaseTick >= 36 then -- 2999
			self.phase = "museum-done" -- 3000
			self.phaseTick = 0 -- 3001
			if self:canPersistProgress() then -- 3002
				self.archive.museumSeen = true -- 3003
				self.archive.museumPhase = "done" -- 3004
				self.archiveDirty = true -- 3005
			end -- 3005
			self:emit( -- 3007
				"museumDone", -- 3007
				{ -- 3007
					steps = 4, -- 3007
					museumSeen = self.archive.museumSeen, -- 3007
					persisted = self:canPersistProgress() -- 3007
				} -- 3007
			) -- 3007
			self:flashSet("回柜边 · 灯还亮着", 2) -- 3008
			self:log("博物馆 · 回柜边") -- 3009
		end -- 3009
		return -- 3011
	end -- 3011
	if interactHit then -- 3013
		self.museumReturn = true -- 3014
		self:requestRoom("prologue", "回柜边") -- 3015
	end -- 3015
end -- 2924
function Play.prototype.openTowerDoor(self) -- 3019
	self.towerDoorOpen = true -- 3020
	do -- 3020
		local i = 0 -- 3021
		while i < #self.boxes do -- 3021
			if self.boxes[i + 1].id == "tower_door" then -- 3022
				self.boxes[i + 1].hidden = true -- 3023
			end -- 3023
			i = i + 1 -- 3021
		end -- 3021
	end -- 3021
	self.run.story.segments.tower_door = true -- 3026
end -- 3019
function Play.prototype.stepTower(self, dt, input) -- 3029
	local ____temp_95 -- 3030
	if self.room.story == nil then -- 3030
		____temp_95 = nil -- 3030
	else -- 3030
		____temp_95 = self.room.story.tower -- 3030
	end -- 3030
	local t = ____temp_95 -- 3030
	if t == nil then -- 3031
		return -- 3032
	end -- 3032
	if self.storyRoute == "soldier" and self.partner.alive then -- 3035
		local targetX = math.max(self.ox + 408, self.player.x - 28) -- 3036
		local gap = targetX - self.partner.x -- 3037
		if math.abs(gap) > 2 then -- 3038
			local dir = gap > 0 and 1 or -1 -- 3039
			local stepDist = math.min( -- 3040
				math.abs(gap), -- 3040
				SOLDIER_SPEED * dt -- 3040
			) -- 3040
			self.partner.facing = dir -- 3041
			self.partner.vx = dir * SOLDIER_SPEED -- 3042
			local ____self_partner_96, ____x_97 = self.partner, "x" -- 3043
			____self_partner_96[____x_97] = ____self_partner_96[____x_97] + dir * stepDist -- 3043
		else -- 3043
			self.partner.vx = 0 -- 3045
			self.partner.facing = 1 -- 3046
		end -- 3046
	end -- 3046
	if self.phase == "tower-wait" then -- 3049
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 3050
		if near and input.interact.pressed then -- 3051
			self.phase = "tower-knock" -- 3052
			self.phaseTick = 0 -- 3053
			self.knocks = 1 -- 3054
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 3055
			self:flashSet("叩两下 · 第一声", 0.6) -- 3056
		end -- 3056
		return -- 3058
	end -- 3058
	if self.phase == "tower-knock" then -- 3060
		self.phaseTick = self.phaseTick + 1 -- 3061
		if self.phaseTick == 12 then -- 3062
			self.knocks = 2 -- 3063
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 3064
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 3065
		elseif self.phaseTick >= t.knockTicks then -- 3066
			self:openTowerDoor() -- 3067
			self.phase = "tower-enter" -- 3068
			self.phaseTick = 0 -- 3069
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 3070
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 3071
		end -- 3071
		return -- 3073
	end -- 3073
	if self.phase == "tower-enter" then -- 3075
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 3076
			self.phase = "tower-desk" -- 3077
			self.phaseTick = 0 -- 3078
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 3079
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 3080
		end -- 3080
		return -- 3082
	end -- 3082
	if self.phase == "tower-desk" then -- 3084
		local deskX = self.ox + 605 -- 3085
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 3086
		if not near or not input.interact.held then -- 3087
			self.deskHold = 0 -- 3088
			return -- 3089
		end -- 3089
		self.deskHold = self.deskHold + 1 -- 3091
		if self.deskHold == 12 then -- 3092
			self:flashSet("针套 · 放在桌上", 1) -- 3093
		elseif self.deskHold == 24 then -- 3094
			self:flashSet("指南针 · 压住纸条", 1) -- 3095
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 3096
			self.towerHanded = true -- 3097
			self.deskHold = 0 -- 3098
			self.run.story.segments.tower_handover = true -- 3099
			self.phase = "tower-given" -- 3100
			self.phaseTick = 0 -- 3101
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 3102
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 3107
		end -- 3107
		return -- 3109
	end -- 3109
	if self.phase == "tower-given" then -- 3111
		local soldier = self.storyRoute == "soldier" -- 3114
		self.phaseTick = self.phaseTick + 1 -- 3115
		if self.phaseTick == 60 then -- 3116
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 3117
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 3118
		elseif self.phaseTick == 120 then -- 3119
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 3120
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 3121
			self.phase = "tower-end" -- 3122
			self.phaseTick = 0 -- 3123
			self.towerEndMustRelease = input.interact.held or input.retry.held -- 3124
			if not self.run.finished then -- 3125
				self.run.finished = true -- 3126
				local ending = soldier and "reunion" or "lamp" -- 3127
				self.run.story.ending = ending -- 3128
				local ____soldier_98 -- 3131
				if soldier then -- 3131
					____soldier_98 = self.run.story.segments.escort5 == true -- 3132
				else -- 3132
					____soldier_98 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 3133
				end -- 3133
				local played = ____soldier_98 -- 3131
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 3134
				if official then -- 3136
					if soldier then -- 3137
						self.run.archive.soldierCleared = true -- 3138
					else -- 3138
						self.run.archive.childCleared = true -- 3140
					end -- 3140
					self.archiveDirty = true -- 3142
				end -- 3142
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 3144
				self:emit("endingReached", { -- 3145
					route = soldier and "soldier" or "child", -- 3146
					ending = ending, -- 3147
					official = official, -- 3148
					source = self.run.source, -- 3149
					lines = {self.endingLines[1], self.endingLines[2]}, -- 3150
					childCleared = self.run.archive.childCleared, -- 3151
					soldierCleared = self.run.archive.soldierCleared, -- 3152
					artifactOwned = self.run.archive.artifactOwned, -- 3153
					equipped = self.equippedWeapon -- 3154
				}) -- 3154
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 3156
			end -- 3156
		end -- 3156
		return -- 3159
	end -- 3159
	self.phaseTick = self.phaseTick + 1 -- 3161
	local held = input.interact.held or input.retry.held -- 3162
	if self.towerEndMustRelease then -- 3163
		if not held then -- 3164
			self.towerEndMustRelease = false -- 3165
		end -- 3165
		return -- 3167
	end -- 3167
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 3169
	if self.phaseTick < waitTicks then -- 3170
		if input.interact.pressed or input.retry.pressed then -- 3171
			self.towerEndMustRelease = held -- 3172
		end -- 3172
		return -- 3174
	end -- 3174
	if input.interact.pressed or input.retry.pressed then -- 3176
		self.restartStory = true -- 3178
		self:requestRoom("prologue", "片尾再玩") -- 3179
		self:flashSet("回到序章", 1.4) -- 3180
	end -- 3180
end -- 3029
function Play.prototype.stepChase(self, dt, input) -- 3185
	if self.caughtT > 0 then -- 3186
		self.caughtT = self.caughtT - dt -- 3187
		if self.caughtT <= 0 then -- 3188
			self:recoverFromCaught() -- 3189
		end -- 3189
		return -- 3191
	end -- 3191
	if self.room.key == "village" then -- 3193
		self:stepScavChase() -- 3194
	elseif self.room.key == "forest" then -- 3195
		self:stepForestRoute() -- 3196
		self:stepDog(dt) -- 3197
		if self.player.x >= self.ox + 1450 then -- 3199
			self:requestRoom("tower", "到林缘北塔") -- 3200
			self:flashSet("林缘 · 北塔", 1.4) -- 3201
		end -- 3201
	end -- 3201
end -- 3185
function Play.prototype.stepScavChase(self) -- 3207
	local s = self.room.scavenger -- 3208
	if s == nil then -- 3209
		return -- 3210
	end -- 3210
	local p = self.player -- 3212
	if self.passed and p.x > self.ox + 440 then -- 3214
		if self.scavChase then -- 3215
			self.scavChase = false -- 3216
			self.scavState = "back" -- 3217
			self.scavT = 0 -- 3218
		end -- 3218
		return -- 3220
	end -- 3220
	local dx = p.x - self.scavX -- 3222
	local dist = math.abs(dx) -- 3223
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 3224
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 3225
	if not self.scavChase then -- 3226
		if visible then -- 3227
			self.scavSee = self.scavSee + 1 -- 3228
			if self.scavSee >= 24 then -- 3229
				self.scavChase = true -- 3230
				self.scavState = "chase" -- 3231
				self.scavTargetX = p.x -- 3232
				self:flashSet("他看见你了", 1.2) -- 3233
			end -- 3233
		else -- 3233
			self.scavSee = 0 -- 3236
		end -- 3236
		return -- 3238
	end -- 3238
	if hidden then -- 3241
		self.scavSee = 0 -- 3242
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 3243
		self.scavT = self.scavT - 1 -- 3244
		if self.scavT <= 0 then -- 3245
			self.scavChase = false -- 3246
			self.scavState = "patrol" -- 3247
			self:flashSet("他失去了目标", 1) -- 3248
		end -- 3248
		return -- 3250
	end -- 3250
	local dir = p.x > self.scavX and 1 or -1 -- 3253
	self.scavX = self.scavX + dir * 96 / 60 -- 3254
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 3255
		self:caught() -- 3256
		return -- 3257
	end -- 3257
end -- 3207
function Play.prototype.stepDog(self, dt) -- 3262
	local ____temp_99 -- 3263
	if self.room.story == nil then -- 3263
		____temp_99 = nil -- 3263
	else -- 3263
		____temp_99 = self.room.story.dog -- 3263
	end -- 3263
	local dog = ____temp_99 -- 3263
	if dog == nil then -- 3264
		return -- 3265
	end -- 3265
	local p = self.player -- 3267
	local ox = self.ox -- 3268
	local dist = math.abs(p.x - self.dogX) -- 3269
	local inBurrowCover = p.crouch and p.x >= ox + 300 and p.x <= ox + 460 -- 3270
	local inBrushCover = p.crouch and (p.x >= ox + 700 and p.x <= ox + 790 or p.x >= ox + 1150 and p.x <= ox + 1240) -- 3271
	local sheltered = inBurrowCover or inBrushCover -- 3275
	local inDitchSprint = not p.crouch and self.forestPath == "ditch" and p.x >= ox + 700 and p.x <= ox + 1140 -- 3276
	local effectiveRange = inDitchSprint and dog.range * 1.25 or dog.range -- 3277
	local earNeedTicks = inDitchSprint and 12 or 18 -- 3278
	if self.dogState == "patrol" then -- 3279
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 3280
		if self.dogX < dog.x0 then -- 3281
			self.dogX = dog.x0 -- 3282
			self.dogDir = 1 -- 3283
		elseif self.dogX > dog.x1 then -- 3284
			self.dogX = dog.x1 -- 3285
			self.dogDir = -1 -- 3286
		end -- 3286
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 3288
		local twigOffsets = {235, 455, 865, 1115} -- 3289
		local nearTwig = false -- 3290
		local ti = 0 -- 3291
		do -- 3291
			ti = 0 -- 3292
			while ti < #twigOffsets do -- 3292
				if math.abs(p.x - (ox + twigOffsets[ti + 1])) <= 18 and p.y <= 8 then -- 3293
					nearTwig = true -- 3294
					break -- 3295
				end -- 3295
				ti = ti + 1 -- 3292
			end -- 3292
		end -- 3292
		local twigRange = nearTwig and math.max(effectiveRange, 400) or effectiveRange -- 3298
		if not sheltered and not p.crouch and moving and dist < twigRange then -- 3299
			self.dogState = "ear" -- 3300
			self.dogT = nearTwig and math.min(earNeedTicks, 12) or earNeedTicks -- 3301
			self.dogTargetX = p.x -- 3302
			self:flashSet(inDitchSprint and "旧渠枯枝响 · 狗立刻转耳" or (nearTwig and "踩断枯枝 · 狗立刻转耳" or "狗转耳朵"), 0.8) -- 3303
		end -- 3303
		return -- 3305
	end -- 3305
	if self.dogState == "ear" then -- 3307
		if sheltered then -- 3308
			self.dogState = "sniff" -- 3309
			self.dogT = 45 -- 3310
			self:flashSet("钻进遮蔽 · 狗顿住了", 0.9) -- 3311
			return -- 3312
		end -- 3312
		self.dogT = self.dogT - 1 -- 3314
		if self.dogT <= 0 then -- 3315
			self.dogState = "chase" -- 3316
			self.dogTargetX = p.x -- 3317
			self:flashSet("狗追来了", 1.4) -- 3318
		end -- 3318
		return -- 3320
	end -- 3320
	if self.dogState == "chase" then -- 3322
		local dir = p.x > self.dogX and 1 or -1 -- 3323
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 3324
		if not sheltered and math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 3325
			self:caught() -- 3326
			self.dogState = "sniff" -- 3327
			self.dogT = 60 -- 3328
		elseif dist > effectiveRange * 1.5 or sheltered then -- 3329
			self.dogState = "sniff" -- 3330
			self.dogT = 60 -- 3331
			self:flashSet(inBurrowCover and "树根窄洞遮住身形 · 狗停下了" or "狗停下了", 0.9) -- 3332
		end -- 3332
		return -- 3334
	end -- 3334
	if self.dogState == "sniff" then -- 3336
		self.dogT = self.dogT - 1 -- 3337
		if self.dogT <= 0 then -- 3338
			self.dogState = "back" -- 3339
		end -- 3339
		return -- 3341
	end -- 3341
	local dir = dog.x0 > self.dogX and 1 or -1 -- 3344
	self.dogX = self.dogX + dir * dog.speed * dt -- 3345
	if math.abs(self.dogX - dog.x0) < 2 then -- 3346
		self.dogX = dog.x0 -- 3347
		self.dogState = "patrol" -- 3348
	end -- 3348
end -- 3262
function Play.prototype.stepForestRoute(self) -- 3353
	local p = self.player -- 3354
	local ox = self.ox -- 3355
	if self.forestPath == "" then -- 3356
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 3357
			self.forestPath = "burrow" -- 3358
			self.run.story.segments.forest_burrow = true -- 3359
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 3360
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 3361
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 3362
			self.forestPath = "ditch" -- 3363
			self.run.story.segments.forest_ditch = true -- 3364
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 3365
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 3366
		end -- 3366
	end -- 3366
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 3369
		self.waterSeen = true -- 3370
		self.run.story.segments.water_lantern = true -- 3371
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 3372
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 3373
	end -- 3373
end -- 3353
function Play.prototype.caught(self) -- 3377
	self.caughtT = 1 -- 3378
	self:flashSet("被抓 · 回到安全点", 1.6) -- 3379
end -- 3377
function Play.prototype.recoverFromCaught(self) -- 3383
	local p = self.player -- 3384
	p.x = self.ox + 140 -- 3385
	p.y = 0 -- 3386
	p.vy = 0 -- 3387
	p.vx = 0 -- 3388
	p.onGround = true -- 3389
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3390
		self.scavX = self.room.scavenger.x0 -- 3391
		self.scavState = "patrol" -- 3392
		self.scavSee = 0 -- 3393
		self.scavChase = false -- 3394
		self.scavT = 0 -- 3395
	end -- 3395
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3397
		self.dogX = self.room.story.dog.x0 -- 3398
		self.dogState = "patrol" -- 3399
		self.dogT = 0 -- 3400
	end -- 3400
	self.cam.x = p.x -- 3402
	self.cam.y = p.y + CAM_LOOK_UP -- 3403
	self:flashSet("回到安全点", 1.2) -- 3404
end -- 3383
function Play.prototype.updateGate(self) -- 3408
	if self.room.key ~= "checkpoint" then -- 3409
		self.gateOpen = false -- 3410
		return -- 3411
	end -- 3411
	local function inZone(x) -- 3413
		return x >= self.ox + 792 and x <= self.ox + 928 -- 3413
	end -- 3413
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 3414
end -- 3408
function Play.prototype.addItem(self, kind) -- 3420
	local inv = self.run.inventory -- 3421
	if kind == "shield" then -- 3422
		if inv.shield >= TOOL_CAP then -- 3423
			return false -- 3424
		end -- 3424
		inv.shield = inv.shield + 1 -- 3426
		return true -- 3427
	end -- 3427
	if kind == "wedge" then -- 3429
		if inv.wedge >= CONSUMABLE_CAP then -- 3430
			return false -- 3431
		end -- 3431
		inv.wedge = inv.wedge + 1 -- 3433
		return true -- 3434
	end -- 3434
	if kind == "ammo" then -- 3436
		if inv.ammo >= CONSUMABLE_CAP then -- 3437
			return false -- 3438
		end -- 3438
		inv.ammo = inv.ammo + 1 -- 3440
		return true -- 3441
	end -- 3441
	if kind == "scrap" then -- 3443
		inv.scrap = inv.scrap + 1 -- 3445
		return true -- 3446
	end -- 3446
	if kind == "wood" then -- 3448
		inv.wood = inv.wood + 1 -- 3449
		return true -- 3450
	end -- 3450
	if kind == "bell" then -- 3452
		inv.bell = inv.bell + 1 -- 3453
		return true -- 3454
	end -- 3454
	if kind == "pass" then -- 3456
		inv.pass = inv.pass + 1 -- 3457
		return true -- 3458
	end -- 3458
	if kind == "quickbelt" then -- 3460
		inv.quickbelt = inv.quickbelt + 1 -- 3461
		return true -- 3462
	end -- 3462
	return false -- 3464
end -- 3420
function Play.prototype.findBox(self, id) -- 3467
	local i = 0 -- 3468
	do -- 3468
		i = 0 -- 3469
		while i < #self.boxes do -- 3469
			if self.boxes[i + 1].id == id then -- 3470
				return self.boxes[i + 1] -- 3471
			end -- 3471
			i = i + 1 -- 3469
		end -- 3469
	end -- 3469
	return nil -- 3474
end -- 3467
function Play.prototype.findWedgeTarget(self) -- 3478
	local best = nil -- 3479
	local bestD = 0 -- 3480
	local i = 0 -- 3481
	do -- 3481
		i = 0 -- 3482
		while i < #self.boxes do -- 3482
			do -- 3482
				local b = self.boxes[i + 1] -- 3483
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3484
					goto __continue529 -- 3485
				end -- 3485
				if not self:nearBox(b, 26) then -- 3487
					goto __continue529 -- 3488
				end -- 3488
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3490
				if best == nil or d < bestD then -- 3491
					best = b -- 3492
					bestD = d -- 3493
				end -- 3493
			end -- 3493
			::__continue529:: -- 3493
			i = i + 1 -- 3482
		end -- 3482
	end -- 3482
	return best -- 3496
end -- 3478
function Play.prototype.stepCraft(self, input) -- 3504
	local inv = self.run.inventory -- 3505
	local required = math.max( -- 3506
		6, -- 3506
		CRAFT_TICKS - 6 * self:talentRank("salvage") -- 3506
	) -- 3506
	if self.craftT > 0 then -- 3507
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3508
			self.craftT = 0 -- 3510
			self:flashSet("制作中断", 0.8) -- 3511
			return true -- 3512
		end -- 3512
		self.craftT = self.craftT + 1 -- 3514
		if self.craftT >= required then -- 3515
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3516
				inv.scrap = inv.scrap - 1 -- 3517
				inv.wedge = inv.wedge + 1 -- 3518
				self:flashSet("制得木楔", 1.2) -- 3519
				self:log("制木楔") -- 3520
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3521
			end -- 3521
			self.craftT = 0 -- 3523
		end -- 3523
		return true -- 3525
	end -- 3525
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3527
		self.craftT = 1 -- 3528
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3529
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3530
		return true -- 3531
	end -- 3531
	return false -- 3533
end -- 3504
function Play.prototype.nearBox(self, b, reach) -- 3536
	local p = self.player -- 3537
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3538
end -- 3536
function Play.prototype.findInteract(self) -- 3544
	local p = self.player -- 3545
	local best = nil -- 3546
	local bestD = 1000000000 -- 3547
	local i = 0 -- 3548
	do -- 3548
		i = 0 -- 3549
		while i < #self.boxes do -- 3549
			do -- 3549
				local b = self.boxes[i + 1] -- 3550
				if b.interact == nil or b.broken == true then -- 3551
					goto __continue542 -- 3552
				end -- 3552
				if not self:nearBox(b, b.interact.reach or 27) then -- 3554
					goto __continue542 -- 3555
				end -- 3555
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3557
				if d < bestD then -- 3558
					bestD = d -- 3559
					best = b -- 3560
				end -- 3560
			end -- 3560
			::__continue542:: -- 3560
			i = i + 1 -- 3549
		end -- 3549
	end -- 3549
	return best -- 3563
end -- 3544
function Play.prototype.stepCampaign(self, dt, input) -- 3567
	local wr = self.room -- 3568
	local p = self.player -- 3569
	if self.reloadT > 0 then -- 3570
		self.reloadT = self.reloadT - 1 -- 3571
	end -- 3571
	if self.bracedShield ~= nil then -- 3574
		self.bracedShield.x = p.x + p.facing * 26 -- 3575
		self.bracedShield.y = p.y -- 3576
		local shBox = __TS__ArrayFind( -- 3577
			self.boxes, -- 3577
			function(____, b) return b.id == "braced_shield" end -- 3577
		) -- 3577
		if shBox ~= nil then -- 3578
			shBox.x0 = self.bracedShield.x - 15 -- 3579
			shBox.x1 = self.bracedShield.x + 15 -- 3580
			shBox.y0 = self.bracedShield.y -- 3581
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3582
		end -- 3582
	end -- 3582
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3586
		self.run.route = "drygoods" -- 3588
		self.run.joined = false -- 3589
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3590
		self:log("转布行线") -- 3591
	end -- 3591
	if wr.key == "escort3" then -- 3595
		local nearBench = p.x >= wr.minX + 472 and p.x <= wr.minX + 710 and p.y < 60 -- 3596
		if nearBench and input.interact.pressed then -- 3597
			self:openCraftBench() -- 3598
			return -- 3599
		end -- 3599
		local ____temp_102 = self.storyRoute == "soldier" -- 3601
		if ____temp_102 then -- 3601
			local ____opt_100 = self.run.story.talents -- 3601
			____temp_102 = (____opt_100 and ____opt_100.deferred) == true -- 3601
		end -- 3601
		if ____temp_102 and p.x >= wr.minX + 940 then -- 3601
			self:triggerDeferredEscort3Draft() -- 3602
		end -- 3602
	end -- 3602
	local i = 0 -- 3606
	do -- 3606
		i = 0 -- 3607
		while i < #self.pickups do -- 3607
			do -- 3607
				local pk = self.pickups[i + 1] -- 3608
				if self.run.taken[pk.id] == true then -- 3609
					goto __continue556 -- 3610
				end -- 3610
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3612
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3613
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3614
					if not self:addItem(pk.kind) then -- 3615
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3617
						self:log("满包拒绝 " .. pk.kind) -- 3618
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3619
						goto __continue556 -- 3620
					end -- 3620
					self.run.taken[pk.id] = true -- 3622
					self:flashSet("拾取 " .. pk.label, 1) -- 3623
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3624
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3625
				end -- 3625
			end -- 3625
			::__continue556:: -- 3625
			i = i + 1 -- 3607
		end -- 3607
	end -- 3607
	self.calmConsumed = false -- 3629
	local ____temp_108 = self.partner.alive and self.run.joined -- 3630
	if ____temp_108 then -- 3630
		local ____opt_103 = self.room.campaign -- 3631
		local ____temp_107 = (____opt_103 and ____opt_103.chapter) == "S" -- 3631
		if not ____temp_107 then -- 3631
			local ____opt_105 = self.room.campaign -- 3631
			____temp_107 = (____opt_105 and ____opt_105.chapter) == "C" -- 3631
		end -- 3631
		____temp_108 = ____temp_107 -- 3630
	end -- 3630
	if ____temp_108 and (self.escort.fear > 0 or self.escort.state == "frozen" or self.escort.state == "calming") then -- 3630
		local dist = inReachDepth(p.depth, self.partner.depth) and math.abs(p.x - self.partner.x) or 1000000000 -- 3633
		local hadK1 = self.escort.knock1 -- 3634
		local hadK2 = self.escort.knock2 -- 3635
		self.calmConsumed = self.escort:update( -- 3636
			input, -- 3636
			p.x, -- 3636
			p.facing, -- 3636
			self.partner.x, -- 3636
			dist -- 3636
		) -- 3636
		if not hadK1 and self.escort.knock1 then -- 3637
			self:emit("knock", {count = 1, x = self.partner.x, room = self.room.key}) -- 3638
		end -- 3638
		if not hadK2 and self.escort.knock2 then -- 3640
			self:emit("knock", {count = 2, x = self.partner.x, room = self.room.key}) -- 3641
		end -- 3641
		self.partner.crouch = self.escort.crouchPose -- 3643
		self.partner.h = self.partner.crouch and CHILD_CROUCH_H or CHILD_H -- 3644
	end -- 3644
	if not self.calmConsumed and not self:stepCraft(input) and input.interact.pressed then -- 3646
		self:campaignInteract() -- 3647
	end -- 3647
	self:stepCampaignCart(dt, input) -- 3649
	self:stepCampaignGoal() -- 3650
	self:campaignCheckpoint() -- 3651
end -- 3567
function Play.prototype.campaignCheckpoint(self) -- 3655
	local i = 0 -- 3656
	do -- 3656
		i = 0 -- 3657
		while i < #self.room.marks do -- 3657
			do -- 3657
				local m = self.room.marks[i + 1] -- 3658
				if m.kind ~= 0 then -- 3659
					goto __continue566 -- 3660
				end -- 3660
				local dx = self.player.x - m.x -- 3662
				local dy = self.player.y - m.y -- 3663
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3664
					self.checkpoint = m.x -- 3665
					self:captureCheckpoint(m.x) -- 3666
					self:flashSet("检查点", 1) -- 3667
				end -- 3667
			end -- 3667
			::__continue566:: -- 3667
			i = i + 1 -- 3657
		end -- 3657
	end -- 3657
end -- 3655
function Play.prototype.campaignInteract(self) -- 3673
	local b = self:findInteract() -- 3674
	if b ~= nil then -- 3675
		self:useInteract(b) -- 3676
		return -- 3677
	end -- 3677
	local inv = self.run.inventory -- 3679
	if inv.wedge > 0 then -- 3680
		local w = self:findWedgeTarget() -- 3681
		if w ~= nil then -- 3682
			local ____opt_109 = w.breakable -- 3683
			local extraHp = (____opt_109 and ____opt_109.wedgeHp or 1) + self:talentRank("salvage") -- 3683
			if w.breakable ~= nil then -- 3684
				local ____w_breakable_111, ____hp_112 = w.breakable, "hp" -- 3685
				____w_breakable_111[____hp_112] = ____w_breakable_111[____hp_112] + extraHp -- 3685
			end -- 3685
			inv.wedge = inv.wedge - 1 -- 3687
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3688
			self:flashSet( -- 3690
				extraHp > 1 and ("钉木楔 · 多承" .. tostring(extraHp)) .. "次" or "钉木楔 · 多承一次", -- 3690
				1.2 -- 3690
			) -- 3690
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3691
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3692
			return -- 3693
		end -- 3693
		if self:isEscortRoom() then -- 3695
			local p = self.player -- 3696
			local wx = math.max( -- 3697
				self.room.minX + 64, -- 3697
				math.min(self.room.maxX - 64, p.x + p.facing * 32) -- 3697
			) -- 3697
			local hp = 1 + self:talentRank("salvage") -- 3698
			self.fieldWedgeSeq = self.fieldWedgeSeq + 1 -- 3699
			local wid = "field_wedge_" .. tostring(self.fieldWedgeSeq) -- 3700
			local ____self_boxes_113 = self.boxes -- 3701
			____self_boxes_113[#____self_boxes_113 + 1] = { -- 3701
				x0 = wx - 12, -- 3702
				x1 = wx + 12, -- 3703
				y0 = p.y, -- 3704
				y1 = p.y + 48, -- 3705
				depth = {min = p.depth - 20, max = p.depth + 20}, -- 3706
				label = "立起的木楔掩体", -- 3707
				id = wid, -- 3708
				breakable = {hp = hp, kind = "thin_wood", wedgeable = true} -- 3709
			} -- 3709
			inv.wedge = inv.wedge - 1 -- 3711
			self:flashSet( -- 3712
				"立木楔 · 临时挡弹" .. (hp > 1 and ("(" .. tostring(hp)) .. "击)" or ""), -- 3712
				1.2 -- 3712
			) -- 3712
			self:log("立木楔掩体") -- 3713
			self:emit("interactUsed", {kind = "wedge", x = wx}) -- 3714
			return -- 3715
		end -- 3715
	end -- 3715
	if inv.ammo > 0 and self.reloadT > 0 then -- 3718
		self.reloadT = 0 -- 3720
		self:closeReloadPuzzle() -- 3721
		inv.ammo = inv.ammo - 1 -- 3722
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3723
		self:log("用备用弹包") -- 3724
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3725
		return -- 3726
	end -- 3726
	local canBraceHere = self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 or self:isEscortRoom() -- 3728
	if inv.shield > 0 and self.bracedShield == nil and canBraceHere then -- 3731
		local p = self.player -- 3732
		local shHp = 1 + self:talentRank("salvage") -- 3733
		self.bracedShield = { -- 3734
			x = p.x + p.facing * 26, -- 3734
			y = p.y, -- 3734
			w = 30, -- 3734
			h = 64, -- 3734
			hp = shHp -- 3734
		} -- 3734
		local ____self_boxes_114 = self.boxes -- 3735
		____self_boxes_114[#____self_boxes_114 + 1] = { -- 3735
			x0 = self.bracedShield.x - 15, -- 3736
			x1 = self.bracedShield.x + 15, -- 3736
			y0 = p.y, -- 3737
			y1 = p.y + 64, -- 3737
			depth = {min = -46, max = 46}, -- 3737
			label = "架起的残盾", -- 3737
			id = "braced_shield", -- 3737
			soft = true -- 3738
		} -- 3738
		inv.shield = inv.shield - 1 -- 3740
		self:flashSet( -- 3741
			shHp > 1 and ("架残盾 · 可挡" .. tostring(shHp)) .. "发" or "架残盾 · 挡一发", -- 3741
			1.2 -- 3741
		) -- 3741
		self:log("架残盾") -- 3742
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3743
		return -- 3744
	end -- 3744
	if inv.pass > 0 and self.run.joined == false then -- 3746
		inv.pass = inv.pass - 1 -- 3747
		self.run.joined = true -- 3748
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3749
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3750
		return -- 3751
	end -- 3751
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3753
end -- 3673
function Play.prototype.useInteract(self, b) -- 3756
	local kind = b.interact == nil and "" or b.interact.kind -- 3757
	local wr = self.room -- 3758
	if kind == "open_board" then -- 3759
		b.broken = true -- 3760
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3761
		for ____, cover in ipairs(self.boxes) do -- 3762
			if cover.id == "s2_board_cover" then -- 3763
				cover.broken = false -- 3764
				cover.hidden = false -- 3765
			end -- 3765
		end -- 3765
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3768
		self.run.joined = true -- 3769
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3770
		self:log("放下窗板") -- 3771
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3772
		return -- 3773
	end -- 3773
	if kind == "lower_curtain" then -- 3775
		for ____, curtain in ipairs(self.boxes) do -- 3776
			if curtain.id == "c2_curtain" then -- 3777
				curtain.broken = false -- 3778
				curtain.hidden = false -- 3779
			end -- 3779
		end -- 3779
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3782
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3783
		self:log("放下木帘") -- 3784
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3785
		return -- 3786
	end -- 3786
	if kind == "raise_latch" then -- 3788
		if wr.key == "c2-granary" and not self.cartDocked then -- 3789
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3790
			return -- 3791
		end -- 3791
		b.broken = true -- 3793
		self.objectiveDone = true -- 3794
		if wr.key == "c1-yard" then -- 3796
			self.run.c1Latch = true -- 3797
			self.run.joined = true -- 3798
			for ____, door in ipairs(self.boxes) do -- 3799
				if door.id == "c1_door" then -- 3800
					door.broken = true -- 3801
				end -- 3801
			end -- 3801
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3804
		else -- 3804
			self.run.c2Latch = true -- 3806
			self.run.joined = true -- 3807
		end -- 3807
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3809
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3810
		self:log("抬闩") -- 3811
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3812
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3813
	end -- 3813
end -- 3756
function Play.prototype.stepCampaignCart(self, dt, input) -- 3818
	local wr = self.room -- 3819
	local c = wr.cart -- 3820
	if c.bodyW <= 0 then -- 3821
		return -- 3822
	end -- 3822
	local p = self.player -- 3824
	local handleX = self.cartAxle + c.handleOffset -- 3825
	if not self.gripping then -- 3826
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3827
			self.gripping = true -- 3829
			self:flashSet("握住车柄 · A/D 推", 1) -- 3830
		end -- 3830
		return -- 3832
	end -- 3832
	if input.interact.pressed then -- 3834
		self.gripping = false -- 3835
		self:flashSet("松手", 0.5) -- 3836
		return -- 3837
	end -- 3837
	if not self.cartDocked then -- 3839
		if input.moveX ~= 0 and not self:stuckCart() then -- 3840
			self.cartAxle = math.max( -- 3841
				c.startX, -- 3841
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3841
			) -- 3841
		end -- 3841
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3845
			self.cartExposed = true -- 3846
			local gun = nil -- 3847
			local gi = 0 -- 3848
			do -- 3848
				gi = 0 -- 3849
				while gi < #self.enemies do -- 3849
					local e = self.enemies[gi + 1] -- 3850
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3851
						gun = e -- 3852
						break -- 3853
					end -- 3853
					gi = gi + 1 -- 3849
				end -- 3849
			end -- 3849
			if gun ~= nil then -- 3856
				self:campaignEnemyFire(gun) -- 3857
			end -- 3857
		end -- 3857
		p.x = self.cartAxle + c.handleOffset -- 3860
		p.y = c.baseY -- 3861
		p.depth = c.depth or 0 -- 3862
		p.vx = 0 -- 3863
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3864
			self.cartAxle = c.endX -- 3865
			self.cartDocked = true -- 3866
			self.gripping = false -- 3867
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3868
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3869
			self:flashSet("车轮入窝", 1.2) -- 3870
			self:log("车轮入窝") -- 3871
		end -- 3871
	end -- 3871
end -- 3818
function Play.prototype.stuckCart(self) -- 3877
	local i = 0 -- 3878
	do -- 3878
		i = 0 -- 3879
		while i < #self.boxes do -- 3879
			do -- 3879
				local b = self.boxes[i + 1] -- 3880
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3881
					goto __continue609 -- 3882
				end -- 3882
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3884
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3885
					return true -- 3886
				end -- 3886
			end -- 3886
			::__continue609:: -- 3886
			i = i + 1 -- 3879
		end -- 3879
	end -- 3879
	return false -- 3889
end -- 3877
function Play.prototype.stepCampaignGoal(self) -- 3893
	local wr = self.room -- 3894
	local c = wr.campaign -- 3895
	if c == nil then -- 3896
		return -- 3897
	end -- 3897
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3899
		self.objectiveDone = true -- 3900
	end -- 3900
	if c.goal == "reach_exit" then -- 3902
		self.objectiveDone = true -- 3903
	end -- 3903
	if not self.objectiveDone then -- 3905
		return -- 3906
	end -- 3906
	local p = self.player -- 3908
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3909
	if p.x < c.exitX or not partnerOk then -- 3910
		return -- 3911
	end -- 3911
	if self.run.story.segments[wr.key] ~= true then -- 3914
		self.run.story.segments[wr.key] = true -- 3915
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3916
	end -- 3916
	if wr.key == "escort5" then -- 3919
		self.escortDone = true -- 3920
		self.run.story.escortDone = true -- 3921
	end -- 3921
	if c.next ~= nil and c.next ~= "" then -- 3923
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3924
		self:flashSet("过关 · " .. c.next, 1.2) -- 3925
	elseif wr.key == "c2-granary" and (self.run.source == "official" or self.run.source == "chapter") then -- 3926
		self:requestRoom("gate", "军粮棚出口") -- 3928
		self:flashSet("出军粮棚 · 城门", 1.4) -- 3929
	elseif not self.run.finished then -- 3930
		self.run.finished = true -- 3931
		self:flashSet( -- 3932
			"军粮棚清完 · 回城门 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3932
			2 -- 3932
		) -- 3932
		self:log("军粮棚清完 · 回城门") -- 3933
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3934
	end -- 3934
end -- 3893
function Play.prototype.stepCampaignPartner(self, dt) -- 3939
	local a = self.partner -- 3940
	local wr = self.room -- 3941
	local cp = wr.companion -- 3942
	if not a.alive then -- 3943
		return -- 3944
	end -- 3944
	local p = self.player -- 3946
	if self.craftBench.active then -- 3948
		a.vx = 0 -- 3949
		return -- 3950
	end -- 3950
	local wait = false -- 3952
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3953
	local targetDepth = p.depth -- 3954
	if self.run.joined == false then -- 3955
		wait = true -- 3956
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3957
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3958
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3959
		wait = true -- 3960
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3961
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3962
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3963
		wait = true -- 3964
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3965
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3966
	end -- 3966
	if self.partnerStuck > 0.3 then -- 3968
		a.x = a.x + a.facing * 44 -- 3970
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3971
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3972
		self.partnerLaneHold = 1.1 -- 3973
		self.partnerStuck = 0 -- 3974
	end -- 3974
	if self.partnerLaneHold > 0 then -- 3976
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3977
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3978
	end -- 3978
	local dx = targetX - a.x -- 3980
	local stopTol = wait and 18 or 74 -- 3981
	if math.abs(dx) > stopTol then -- 3982
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3983
		local before = a.x -- 3984
		a.vx = dx > 0 and speed or -speed -- 3985
		a.facing = dx > 0 and 1 or -1 -- 3986
		self:slideX(a, a.vx * dt) -- 3987
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3989
			a.vy = CHILD_JUMP -- 3990
			a.onGround = false -- 3991
		end -- 3991
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3993
	else -- 3993
		a.vx = 0 -- 3995
		self.partnerStuck = 0 -- 3996
	end -- 3996
	local dz = targetDepth - a.depth -- 3998
	if math.abs(dz) > 6 then -- 3999
		local step = math.max( -- 4000
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 4000
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 4000
		) -- 4000
		a.depth = a.depth + step -- 4001
	end -- 4001
	a.depthSpeed = 0 -- 4003
	a.h = CHILD_H -- 4004
	a.crouch = false -- 4005
	self:fallY(a, dt) -- 4006
end -- 3939
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 4010
	local p = self.player -- 4011
	local i = 0 -- 4012
	do -- 4012
		i = 0 -- 4013
		while i < #self.enemies and not self.escortFailed do -- 4013
			do -- 4013
				local e = self.enemies[i + 1] -- 4014
				if e.kind == "target" then -- 4015
					if not e.alive then -- 4017
						if e.hitT > 0 then -- 4018
							e.hitT = e.hitT - dt -- 4019
						end -- 4019
						if e.hitT <= 0 then -- 4021
							e.alive = true -- 4022
							e.hitT = 0 -- 4023
						end -- 4023
					end -- 4023
					goto __continue637 -- 4026
				end -- 4026
				if not e.alive then -- 4028
					goto __continue637 -- 4029
				end -- 4029
				if e.kind == "breaker" then -- 4031
					self:stepBreaker(e, dt) -- 4032
					goto __continue637 -- 4033
				end -- 4033
				if e.kind == "shield" then -- 4035
					self:stepShield(e, dt, input) -- 4036
					goto __continue637 -- 4037
				end -- 4037
				local dx = e.x - p.x -- 4040
				if not e.awake then -- 4041
					if math.abs(dx) > 520 then -- 4042
						goto __continue637 -- 4043
					end -- 4043
					e.awake = true -- 4045
					e.fireCd = 48 -- 4046
					goto __continue637 -- 4047
				end -- 4047
				if math.abs(dx) > ENEMY_RANGE then -- 4049
					goto __continue637 -- 4050
				end -- 4050
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 4054
					goto __continue637 -- 4055
				end -- 4055
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 4057
					goto __continue637 -- 4058
				end -- 4058
				if self:blockedShot(e, p) then -- 4060
					if e.warnT > 0 then -- 4063
						e.warnT = 0 -- 4064
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4065
					end -- 4065
					goto __continue637 -- 4067
				end -- 4067
				if e.warnT > 0 then -- 4069
					e.warnT = e.warnT - 1 -- 4070
					if e.warnT <= 0 then -- 4071
						self:campaignEnemyFire(e) -- 4072
					end -- 4072
				elseif e.fireCd > 0 then -- 4074
					e.fireCd = e.fireCd - 1 -- 4075
					if e.fireCd <= 0 then -- 4076
						e.warnT = WARN_TICKS -- 4077
					end -- 4077
				else -- 4077
					e.fireCd = 40 -- 4080
				end -- 4080
			end -- 4080
			::__continue637:: -- 4080
			i = i + 1 -- 4013
		end -- 4013
	end -- 4013
end -- 4010
function Play.prototype.blockedShot(self, e, p) -- 4086
	local eDepth = e.depth or 0 -- 4087
	local ex = e.x -- 4088
	local ey = e.y + e.h * 0.62 -- 4090
	local px = p.x -- 4091
	local py = p.y + p.h * 0.55 -- 4092
	local dx = px - ex -- 4093
	local dyScreen = py + p.depth * DEPTH_Y_SCALE - (ey + eDepth * DEPTH_Y_SCALE) -- 4094
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 4095
	if len < 0.01 then -- 4096
		return false -- 4097
	end -- 4097
	local ray = { -- 4101
		x = ex, -- 4102
		y = ey, -- 4102
		dx = dx / len, -- 4103
		dy = (py - ey) / len, -- 4103
		depth = eDepth, -- 4104
		dDepth = (p.depth - eDepth) / len -- 4104
	} -- 4104
	local best = -1 -- 4106
	local j = 0 -- 4107
	do -- 4107
		j = 0 -- 4108
		while j < #self.boxes do -- 4108
			do -- 4108
				local b = self.boxes[j + 1] -- 4109
				if b.broken == true or b.passable == true or b.hidden == true then -- 4110
					goto __continue660 -- 4111
				end -- 4111
				if b.id == "braced_shield" then -- 4115
					goto __continue660 -- 4116
				end -- 4116
				local t = hitBox(ray, b) -- 4118
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 4121
					best = t -- 4122
				end -- 4122
			end -- 4122
			::__continue660:: -- 4122
			j = j + 1 -- 4108
		end -- 4108
	end -- 4108
	return best >= 0 -- 4125
end -- 4086
function Play.prototype.campaignEnemyFire(self, e) -- 4128
	local p = self.player -- 4129
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4130
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 4131
		local ____self_bracedShield_115, ____hp_116 = self.bracedShield, "hp" -- 4132
		____self_bracedShield_115[____hp_116] = ____self_bracedShield_115[____hp_116] - 1 -- 4132
		if self.bracedShield.hp <= 0 then -- 4133
			self.boxes = __TS__ArrayFilter( -- 4134
				self.boxes, -- 4134
				function(____, b) return b.id ~= "braced_shield" end -- 4134
			) -- 4134
			self.bracedShield = nil -- 4135
			self:flashSet("残盾碎 · 挡下一发", 1) -- 4136
		else -- 4136
			self:flashSet( -- 4138
				"残盾挡下一发 · 余" .. tostring(self.bracedShield.hp), -- 4138
				1 -- 4138
			) -- 4138
		end -- 4138
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 4140
		return -- 4141
	end -- 4141
	if self:blockedShot(e, p) then -- 4143
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4144
		return -- 4145
	end -- 4145
	local cover = self:blockedByCover(e, p) -- 4147
	if cover ~= nil and self.coverHug then -- 4148
		self.coveredFlash = 0.5 -- 4149
		self:flashSet("掩体挡下", 0.6) -- 4150
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4151
		return -- 4156
	end -- 4156
	if self.invulnT > 0 then -- 4158
		return -- 4159
	end -- 4159
	self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4161
	self.craftT = 0 -- 4162
	self.hp = self.hp - 1 -- 4163
	self:emit("actorHit", { -- 4164
		target = "player", -- 4164
		amount = 1, -- 4164
		hp = self.hp, -- 4164
		maxHp = self.maxHp, -- 4164
		enemyX = e.x -- 4164
	}) -- 4164
	self:flashSet( -- 4165
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4165
		0.8 -- 4165
	) -- 4165
	if self.hp <= 0 then -- 4166
		self:campaignFailed() -- 4167
	end -- 4167
end -- 4128
function Play.prototype.stepShield(self, e, dt, input) -- 4172
	local p = self.player -- 4173
	local dx = p.x - e.x -- 4174
	local adx = math.abs(dx) -- 4175
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 4178
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 4179
	if adx > 44 then -- 4180
		local before = e.x -- 4181
		local stepX = (dx > 0 and 1 or -1) * 60 * dt -- 4182
		local nextX = math.max( -- 4183
			self.room.minX + 16, -- 4183
			math.min(self.room.maxX - 16, e.x + stepX) -- 4183
		) -- 4183
		if not self:enemyBlockedAtX(e, nextX) then -- 4184
			e.x = nextX -- 4185
		end -- 4185
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 4187
			e.depth = math.max( -- 4189
				-32, -- 4189
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4189
			) -- 4189
		end -- 4189
	elseif adx <= 48 and sameLane and (e.swingT or 0) <= 0 then -- 4191
		local fromFront = (e.x - p.x) * p.facing > 0 -- 4194
		local rollDodges = p.rollT > 0 and (fromFront or self:talentRank("guard") > 0) -- 4195
		if not rollDodges and self.invulnT <= 0 then -- 4196
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4197
			self.craftT = 0 -- 4198
			self.hp = self.hp - 1 -- 4199
			self:emit("actorHit", { -- 4200
				target = "player", -- 4200
				amount = 1, -- 4200
				hp = self.hp, -- 4200
				maxHp = self.maxHp, -- 4200
				enemyX = e.x -- 4200
			}) -- 4200
			self:flashSet( -- 4201
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4201
				0.8 -- 4201
			) -- 4201
			if self.hp <= 0 then -- 4202
				self:campaignFailed() -- 4203
				return -- 4204
			end -- 4204
		end -- 4204
		e.swingT = 70 -- 4207
	end -- 4207
	if (e.swingT or 0) > 0 then -- 4209
		e.swingT = (e.swingT or 0) - 1 -- 4210
	end -- 4210
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 4212
		local dd = p.depth - (e.depth or 0) -- 4213
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 4214
	end -- 4214
end -- 4172
function Play.prototype.stepBreaker(self, e, dt) -- 4219
	local p = self.player -- 4220
	if e.awake ~= true then -- 4221
		if math.abs(p.x - e.x) < 560 then -- 4222
			e.awake = true -- 4223
		else -- 4223
			return -- 4225
		end -- 4225
	end -- 4225
	local target = nil -- 4228
	local bestD = 1000000000 -- 4229
	local i = 0 -- 4230
	do -- 4230
		i = 0 -- 4231
		while i < #self.boxes do -- 4231
			do -- 4231
				local b = self.boxes[i + 1] -- 4232
				if b.breakable == nil or b.broken == true then -- 4233
					goto __continue687 -- 4234
				end -- 4234
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 4236
				if d < bestD then -- 4237
					bestD = d -- 4238
					target = b -- 4239
				end -- 4239
			end -- 4239
			::__continue687:: -- 4239
			i = i + 1 -- 4231
		end -- 4231
	end -- 4231
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 4242
	local dx = tx - e.x -- 4243
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 4244
	if math.abs(dx) > reach then -- 4245
		local before = e.x -- 4246
		local nextX = math.max( -- 4247
			self.room.minX + 16, -- 4247
			math.min(self.room.maxX - 16, e.x + (dx > 0 and 1 or -1) * 48 * dt) -- 4247
		) -- 4247
		if not self:enemyBlockedAtX(e, nextX) then -- 4248
			e.x = nextX -- 4249
		end -- 4249
		if math.abs(e.x - before) < 0.3 then -- 4251
			e.depth = math.max( -- 4252
				-32, -- 4252
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4252
			) -- 4252
		end -- 4252
	elseif (e.swingT or 0) <= 0 then -- 4254
		e.swingT = 64 -- 4255
		if target ~= nil then -- 4256
			self:damageProp(target, 2) -- 4257
		elseif math.abs(p.x - e.x) < 60 and math.abs((e.depth or 0) - p.depth) <= 26 and not (p.rollT > 0 and self:talentRank("guard") > 0) and self.invulnT <= 0 then -- 4258
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4260
			self.craftT = 0 -- 4261
			self.hp = self.hp - 1 -- 4262
			self:emit("actorHit", { -- 4263
				target = "player", -- 4263
				amount = 1, -- 4263
				hp = self.hp, -- 4263
				maxHp = self.maxHp, -- 4263
				enemyX = e.x -- 4263
			}) -- 4263
			self:flashSet("破障手近身", 0.8) -- 4264
			if self.hp <= 0 then -- 4265
				self:campaignFailed() -- 4266
				return -- 4267
			end -- 4267
		end -- 4267
	end -- 4267
	if (e.swingT or 0) > 0 then -- 4271
		e.swingT = (e.swingT or 0) - 1 -- 4272
	end -- 4272
end -- 4219
function Play.prototype.enemyBlockedAtX(self, e, nextX) -- 4277
	local half = e.w * 0.5 -- 4278
	local d = e.depth or 0 -- 4279
	local i = 0 -- 4280
	do -- 4280
		i = 0 -- 4281
		while i < #self.boxes do -- 4281
			do -- 4281
				local b = self.boxes[i + 1] -- 4282
				if b.broken == true or b.passable == true or b.soft == true or b.hidden == true or b.y0 >= e.y + e.h or b.y1 <= e.y + 4 then -- 4283
					goto __continue700 -- 4284
				end -- 4284
				if b.depth ~= nil and (d < b.depth.min - 8 or d > b.depth.max + 8) then -- 4286
					goto __continue700 -- 4287
				end -- 4287
				if nextX + half > b.x0 and nextX - half < b.x1 then -- 4289
					return true -- 4290
				end -- 4290
			end -- 4290
			::__continue700:: -- 4290
			i = i + 1 -- 4281
		end -- 4281
	end -- 4281
	return false -- 4293
end -- 4277
function Play.prototype.campaignFailed(self) -- 4296
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 4300
		if self.escortFailed then -- 4301
			return -- 4301
		end -- 4301
		if self.useEscortDeathSummary then -- 4302
			local story = self.run.story -- 4303
			local st = story.talents -- 4304
			local ranksCopy = { -- 4305
				vitality = st and st.ranks.vitality or 0, -- 4306
				guard = st and st.ranks.guard or 0, -- 4307
				stride = st and st.ranks.stride or 0, -- 4308
				focus = st and st.ranks.focus or 0, -- 4309
				push_force = st and st.ranks.push_force or 0, -- 4310
				echo_wide = st and st.ranks.echo_wide or 0, -- 4311
				lantern_pierce = st and st.ranks.lantern_pierce or 0, -- 4312
				salvage = st and st.ranks.salvage or 0 -- 4313
			} -- 4313
			local cleared = 0 -- 4315
			local segKeys = { -- 4316
				"escort1", -- 4316
				"escort2", -- 4316
				"escort3", -- 4316
				"escort4", -- 4316
				"escort5" -- 4316
			} -- 4316
			local si = 0 -- 4317
			do -- 4317
				si = 0 -- 4318
				while si < #segKeys do -- 4318
					if story.segments[segKeys[si + 1]] == true then -- 4319
						cleared = cleared + 1 -- 4320
					end -- 4320
					si = si + 1 -- 4318
				end -- 4318
			end -- 4318
			self.escortFailed = true -- 4323
			self.escortFailedTicks = 0 -- 4324
			self.talentModalActive = false -- 4325
			self.craftBench.active = false -- 4326
			self.reloadT = 0 -- 4327
			self:closeReloadPuzzle() -- 4328
			self.gripping = false -- 4329
			local fallenBuild = { -- 4330
				ranks = __TS__ObjectAssign({}, st and st.ranks or ({})), -- 4331
				weaponId = self.equippedWeapon, -- 4332
				seed = self.run.seed -- 4333
			} -- 4333
			self.escortSummary = { -- 4335
				roomKey = self.room.key, -- 4336
				attempt = st ~= nil and math.max(1, st.attempt) or 1, -- 4337
				seed = st ~= nil and st.randomState or self.run.seed, -- 4338
				equippedWeapon = self.equippedWeapon, -- 4339
				segmentsCleared = cleared, -- 4340
				ranks = ranksCopy -- 4341
			} -- 4341
			self:resetEscortAttempt() -- 4343
			self:flashSet("折返山道 · 重整再赴", 2) -- 4344
			self:log("男主线折返 · 展示小结") -- 4345
			self:emit("campaignFailed", { -- 4346
				room = self.room.key, -- 4347
				hp = 0, -- 4347
				maxHp = self.maxHp, -- 4347
				reset = true, -- 4348
				to = "escort1", -- 4348
				route = self.storyRoute, -- 4348
				summary = true, -- 4348
				fallenBuild = fallenBuild -- 4348
			}) -- 4348
			return -- 4350
		end -- 4350
		self:restartEscortRun() -- 4352
		return -- 4353
	end -- 4353
	local p = self.player -- 4355
	self.hp = self.maxHp -- 4356
	self.invulnT = INVULN_RESPAWN_TICKS -- 4357
	self.reloadT = 0 -- 4358
	self:closeReloadPuzzle() -- 4359
	self.gripping = false -- 4360
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 4361
	self:log("被击倒") -- 4362
	p.x = self.room.minX + 90 -- 4363
	p.y = 0 -- 4364
	p.depth = 0 -- 4365
	p.vx = 0 -- 4366
	p.vy = 0 -- 4367
	p.onGround = true -- 4368
	p.rollT = 0 -- 4369
	self.partner.x = p.x - 50 -- 4370
	self.partner.y = 0 -- 4371
	self.partner.depth = 0 -- 4372
	self.cam.x = p.x -- 4373
	local i = 0 -- 4374
	do -- 4374
		i = 0 -- 4375
		while i < #self.enemies do -- 4375
			do -- 4375
				local e = self.enemies[i + 1] -- 4376
				if not e.alive then -- 4377
					goto __continue712 -- 4378
				end -- 4378
				e.x = e.homeX == nil and e.x or e.homeX -- 4380
				e.warnT = 0 -- 4381
				e.fireCd = 40 -- 4382
				e.swingT = 0 -- 4383
				e.awake = false -- 4384
			end -- 4384
			::__continue712:: -- 4384
			i = i + 1 -- 4375
		end -- 4375
	end -- 4375
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4386
end -- 4296
function Play.prototype.isEscortRoom(self) -- 4390
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 4391
end -- 4390
function Play.prototype.confirmEscortRestart(self) -- 4395
	if not self.escortFailed then -- 4396
		return false -- 4397
	end -- 4397
	self:requestRoom("escort1", "男主线失败重开") -- 4399
	return true -- 4400
end -- 4395
function Play.prototype.restartEscortRun(self) -- 4404
	self:resetEscortAttempt() -- 4405
	self:requestRoom("escort1", "男主线失败重开") -- 4406
end -- 4404
function Play.prototype.resetEscortAttempt(self) -- 4414
	local story = self.run.story -- 4415
	local inv = self.run.inventory -- 4416
	local ____opt_135 = story.talents -- 4418
	local fallenBuild = { -- 4417
		ranks = __TS__ObjectAssign({}, ____opt_135 and ____opt_135.ranks or ({})), -- 4418
		weaponId = self.equippedWeapon, -- 4419
		seed = self.run.seed -- 4420
	} -- 4420
	local prevAttempt = story.talents ~= nil and math.max(1, story.talents.attempt) or 1 -- 4422
	local nextAttempt = prevAttempt + 1 -- 4423
	local vitBonus = story.talents ~= nil and (story.talents.ranks.vitality or 0) or 0 -- 4424
	if vitBonus > 0 then -- 4425
		self.maxHp = math.max(3, self.maxHp - vitBonus) -- 4426
		story.maxHp = self.maxHp -- 4427
	end -- 4427
	story.talents = createStoryTalents(self.run.seed, nextAttempt) -- 4429
	self.hp = self.maxHp -- 4430
	story.hp = self.maxHp -- 4431
	story.cp = nil -- 4432
	self.checkpointSnap = nil -- 4433
	story.carry = false -- 4434
	self.carryOn = false -- 4435
	story.craftedWeapon = "" -- 4436
	self.equippedWeapon = "standard_gun" -- 4437
	story.equippedWeapon = "standard_gun" -- 4438
	story.escortDone = false -- 4439
	self.escortDone = false -- 4440
	story.segments = {} -- 4441
	inv.wood = 0 -- 4442
	inv.bell = 0 -- 4443
	inv.scrap = 0 -- 4444
	inv.wedge = 0 -- 4445
	inv.ammo = 0 -- 4446
	inv.quickbelt = 0 -- 4447
	inv.shield = 0 -- 4448
	inv.pass = 0 -- 4449
	local taken = self.run.taken -- 4450
	local keys = __TS__ObjectKeys(taken) -- 4451
	local i = 0 -- 4452
	do -- 4452
		i = 0 -- 4453
		while i < #keys do -- 4453
			local k = keys[i + 1] -- 4454
			if (string.find(k, "e2_", nil, true) or 0) - 1 == 0 or (string.find(k, "e3_", nil, true) or 0) - 1 == 0 or (string.find(k, "escort", nil, true) or 0) - 1 == 0 then -- 4455
				__TS__Delete(taken, k) -- 4456
			end -- 4456
			i = i + 1 -- 4453
		end -- 4453
	end -- 4453
	local propKeys = __TS__ObjectKeys(self.run.props) -- 4459
	do -- 4459
		i = 0 -- 4460
		while i < #propKeys do -- 4460
			local pk = propKeys[i + 1] -- 4461
			if (string.find(pk, "e1_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e2_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e3_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e4_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e5_", nil, true) or 0) - 1 == 0 or (string.find(pk, "field_wedge_", nil, true) or 0) - 1 == 0 then -- 4462
				__TS__Delete(self.run.props, pk) -- 4464
			end -- 4464
			i = i + 1 -- 4460
		end -- 4460
	end -- 4460
	self.bracedShield = nil -- 4467
	self.talentModalActive = false -- 4468
	self.run.joined = true -- 4469
	self.reloadT = 0 -- 4470
	self:closeReloadPuzzle() -- 4471
	self.gripping = false -- 4472
	self.sessionDirty = true -- 4473
	self:flashSet( -- 4474
		("重整启程 · 第" .. tostring(nextAttempt)) .. "轮护送", -- 4474
		2 -- 4474
	) -- 4474
	self:log(("男主线重开 · 第" .. tostring(nextAttempt)) .. "轮回 escort1") -- 4475
	if not self.useEscortDeathSummary then -- 4476
		self:emit("campaignFailed", { -- 4477
			room = self.room.key, -- 4478
			hp = 0, -- 4478
			maxHp = self.maxHp, -- 4478
			reset = true, -- 4479
			to = "escort1", -- 4479
			route = self.storyRoute, -- 4479
			attempt = nextAttempt, -- 4479
			fallenBuild = fallenBuild -- 4479
		}) -- 4479
	end -- 4479
end -- 4414
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 4485
	local i = 0 -- 4486
	do -- 4486
		i = 0 -- 4487
		while i < #self.enemies do -- 4487
			do -- 4487
				if i == skipIndex then -- 4488
					goto __continue729 -- 4489
				end -- 4489
				local e = self.enemies[i + 1] -- 4491
				if not e.alive or math.abs(e.x - center.x) > radius then -- 4492
					goto __continue729 -- 4493
				end -- 4493
				e.awake = true -- 4495
				e.fireCd = math.max(e.fireCd or 0, 150) -- 4496
				e.warnT = 0 -- 4497
			end -- 4497
			::__continue729:: -- 4497
			i = i + 1 -- 4487
		end -- 4487
	end -- 4487
end -- 4485
function Play.prototype.stepEnemies(self, dt, input) -- 4501
	local i = 0 -- 4502
	do -- 4502
		i = 0 -- 4503
		while i < #self.enemies do -- 4503
			local e = self.enemies[i + 1] -- 4504
			if e.hitT > 0 then -- 4505
				e.hitT = e.hitT - dt -- 4506
			end -- 4506
			i = i + 1 -- 4503
		end -- 4503
	end -- 4503
	if self.coveredFlash > 0 then -- 4509
		self.coveredFlash = self.coveredFlash - dt -- 4510
	end -- 4510
	if self.isCampaign then -- 4512
		self:stepCampaignEnemies(dt, input) -- 4513
		return -- 4514
	end -- 4514
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 4517
		return -- 4518
	end -- 4518
	do -- 4518
		i = 0 -- 4520
		while i < #self.enemies do -- 4520
			do -- 4520
				local e = self.enemies[i + 1] -- 4521
				if not e.alive then -- 4522
					goto __continue740 -- 4523
				end -- 4523
				if e.warnT > 0 then -- 4525
					e.warnT = e.warnT - 1 -- 4526
					if e.warnT <= 0 then -- 4527
						self:enemyFire(e, input) -- 4528
					end -- 4528
					goto __continue740 -- 4530
				end -- 4530
				if e.fireCd > 0 then -- 4532
					e.fireCd = e.fireCd - 1 -- 4533
					if e.fireCd <= 0 then -- 4534
						e.warnT = WARN_TICKS -- 4535
					end -- 4535
				else -- 4535
					e.warnT = WARN_TICKS -- 4539
				end -- 4539
			end -- 4539
			::__continue740:: -- 4539
			i = i + 1 -- 4520
		end -- 4520
	end -- 4520
end -- 4501
function Play.prototype.enemyFire(self, e, input) -- 4545
	local p = self.player -- 4546
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 4547
		self:flashSet("枪声响在远处", 0.4) -- 4548
		e.fireCd = FIRE_COOLDOWN -- 4549
		return -- 4550
	end -- 4550
	if self:blockedShot(e, p) then -- 4552
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4553
		e.fireCd = FIRE_COOLDOWN -- 4554
		return -- 4555
	end -- 4555
	local cover = self:blockedByCover(e, p) -- 4558
	local hugging = cover ~= nil -- 4559
	self.coverBlocking = hugging -- 4560
	local covered = hugging and input.cover.held -- 4561
	if covered then -- 4562
		self.coveredFlash = 0.5 -- 4563
		self:flashSet("掩体挡下", 0.5) -- 4564
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4565
		e.fireCd = FIRE_COOLDOWN -- 4570
		return -- 4571
	end -- 4571
	if self.invulnT > 0 then -- 4573
		e.fireCd = FIRE_COOLDOWN -- 4574
		return -- 4575
	end -- 4575
	self.invulnT = INVULN_HIT_TICKS -- 4577
	self.hp = self.hp - 1 -- 4578
	self:emit("actorHit", { -- 4579
		target = "player", -- 4579
		amount = 1, -- 4579
		hp = self.hp, -- 4579
		maxHp = self.maxHp, -- 4579
		enemyX = e.x -- 4579
	}) -- 4579
	self:flashSet( -- 4580
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4580
		0.7 -- 4580
	) -- 4580
	e.fireCd = FIRE_COOLDOWN -- 4581
	if self.hp <= 0 then -- 4582
		self:gateFailed() -- 4583
	end -- 4583
end -- 4545
function Play.prototype.blockedByCover(self, enemy, p) -- 4588
	local b = self:coverAt(p) -- 4589
	if b == nil then -- 4590
		return nil -- 4591
	end -- 4591
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4593
end -- 4588
function Play.prototype.gateFailed(self) -- 4597
	local ____temp_137 -- 4598
	if self.room.story == nil then -- 4598
		____temp_137 = nil -- 4598
	else -- 4598
		____temp_137 = self.room.story.gate -- 4598
	end -- 4598
	local g = ____temp_137 -- 4598
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 4599
	self.hp = self.maxHp -- 4600
	self.gateTick = 0 -- 4601
	self.gateSpawned = 0 -- 4602
	self.enemies = {} -- 4603
	self.gateFailCount = self.gateFailCount + 1 -- 4604
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 4606
	self.player.y = 0 -- 4607
	self.player.vy = 0 -- 4608
	self.player.depth = 0 -- 4609
	self.player.depthSpeed = 0 -- 4610
	self.player.onGround = true -- 4611
	self.player.crouch = false -- 4612
	self.player.h = SOLDIER_H -- 4613
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 4614
	self.partner.y = 0 -- 4615
	self.partner.vy = 0 -- 4616
	self.partner.depth = 0 -- 4617
	self.partner.depthSpeed = 0 -- 4618
	self.partner.onGround = true -- 4619
	self.cam.x = self.player.x -- 4620
	self.phase = "gate-idle" -- 4621
	self.phaseTick = 0 -- 4622
	self.coverHug = false -- 4623
	self.coverBlocking = false -- 4624
	self.coverEntity = "" -- 4625
	self.gateNeedConfirm = true -- 4626
	self.gateRestartArmed = false -- 4627
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 4628
end -- 4597
function Play.prototype.stepRedCart(self, input) -- 4632
	if self.redCartMemoryT > 0 then -- 4633
		self.redCartMemoryT = self.redCartMemoryT - 1 -- 4634
	end -- 4634
	if self.room.key ~= "outside" or self.redCartPulled then -- 4636
		return -- 4637
	end -- 4637
	local box = __TS__ArrayFind( -- 4639
		self.boxes, -- 4639
		function(____, b) return b.id == "outside_red_cart" end -- 4639
	) -- 4639
	if box == nil then -- 4640
		self.redCartPulled = true -- 4641
		return -- 4642
	end -- 4642
	local cx = (box.x0 + box.x1) * 0.5 -- 4644
	local p = self.player -- 4645
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 4646
		return -- 4647
	end -- 4647
	if not input.interact.pressed then -- 4649
		return -- 4650
	end -- 4650
	box.x0 = 430 -- 4652
	box.x1 = 474 -- 4653
	self.cartAxle = self.room.cart.endX -- 4655
	self.cartDocked = true -- 4656
	self.redCartPulled = true -- 4657
	self.redCartMemoryT = 30 -- 4658
	if self.run.story ~= nil then -- 4659
		self.run.story.segments.outside_cart = true -- 4660
		self.run.story.segments.outside_memory = true -- 4661
	end -- 4661
	self.sessionDirty = true -- 4663
	self:flashSet("红布补丁 · 想起家里那一针 · 石阶口露出来", 1.8) -- 4664
	self:emit("storyBeat", {beat = "red_cart", x = p.x, room = "outside"}) -- 4665
	self:emit("storyBeat", {beat = "red_cart_memory", x = p.x, room = "outside", durationTicks = 30}) -- 4666
end -- 4632
function Play.prototype.stepInteract(self, dt, input) -- 4669
	local p = self.player -- 4670
	self:stepRedCart(input) -- 4671
	local calmUsed = self.calmConsumed -- 4672
	self.calmConsumed = false -- 4673
	local calming = self.escort.state == "calming" -- 4675
	self.focusCart = false -- 4676
	if self.room.key == "outside" then -- 4677
		local c = self.room.cart -- 4678
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 4679
		local dy = p.y - c.baseY -- 4680
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 4681
	end -- 4681
	if not calmUsed and not calming then -- 4684
		self:stepCart(dt, input) -- 4685
	end -- 4685
	if calmUsed then -- 4689
		self:flashSet("安抚 · 敲两下", 0.8) -- 4690
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4691
		if self.knockT > 0 then -- 4693
			self.knocks = self.knocks + 1 -- 4694
		else -- 4694
			self.knocks = 1 -- 4696
		end -- 4696
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4698
		self.knockT = 1.2 -- 4699
		if self.knocks >= 2 then -- 4700
			self:flashSet("敲两下", 0.8) -- 4701
			self.knocks = 0 -- 4702
		else -- 4702
			self:flashSet("敲一下", 0.5) -- 4704
		end -- 4704
	elseif self.knockT > 0 then -- 4706
		self.knockT = self.knockT - dt -- 4707
		if self.knockT <= 0 then -- 4708
			self.knocks = 0 -- 4709
		end -- 4709
	end -- 4709
	local i = 0 -- 4714
	do -- 4714
		i = 0 -- 4715
		while i < #self.room.marks do -- 4715
			do -- 4715
				local m = self.room.marks[i + 1] -- 4716
				if m.kind ~= 0 then -- 4717
					goto __continue776 -- 4718
				end -- 4718
				local subjects = {self.partner, self.player} -- 4720
				local k = 0 -- 4721
				do -- 4721
					k = 0 -- 4722
					while k < #subjects do -- 4722
						do -- 4722
							local s = subjects[k + 1] -- 4723
							if not s.alive then -- 4724
								goto __continue779 -- 4725
							end -- 4725
							local dx = s.x - m.x -- 4727
							local dy = s.y - m.y -- 4728
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4729
								self.checkpoint = m.x -- 4730
								self.checkpointCartAxle = self.cartAxle -- 4731
								if self.isCampaign then -- 4733
									self:captureCheckpoint(m.x) -- 4734
								end -- 4734
								if self.cartDocked then -- 4736
									self:flashSet("检查点 · 车已落窝", 1) -- 4737
								else -- 4737
									self:flashSet("检查点 · 车还没到位", 1) -- 4739
								end -- 4739
							end -- 4739
						end -- 4739
						::__continue779:: -- 4739
						k = k + 1 -- 4722
					end -- 4722
				end -- 4722
			end -- 4722
			::__continue776:: -- 4722
			i = i + 1 -- 4715
		end -- 4715
	end -- 4715
	self:checkCarryGate() -- 4745
end -- 4669
function Play.prototype.stepVillage(self, dt, input) -- 4749
	if self.room.key ~= "village" then -- 4750
		return -- 4751
	end -- 4751
	local p = self.player -- 4753
	local bottle = self.room.bottle -- 4754
	local scav = self.room.scavenger -- 4755
	if not self.hasBottle and bottle ~= nil then -- 4758
		local dx = p.x - bottle.x -- 4759
		local dy = p.y + p.h * 0.5 - bottle.y -- 4760
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4761
			self.hasBottle = true -- 4762
			self:flashSet("拾起瓶子", 0.8) -- 4763
		end -- 4763
	end -- 4763
	if self.hasBottle then -- 4768
		if input.bottleCanceled then -- 4769
			self.aimHold = 0 -- 4770
			self.bottleAimX = -1 -- 4771
		elseif input.aim.held then -- 4772
			self.aimHold = self.aimHold + dt -- 4773
			if self.aimHold > 1.2 then -- 4774
				self.aimHold = 1.2 -- 4775
			end -- 4775
			local cached = self:bottleEnd() -- 4778
			self.bottleAimX = cached.x -- 4779
			self.bottleAimY = cached.y -- 4780
		elseif input.aim.released then -- 4781
			if self.aimHold < 0.12 then -- 4782
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 4784
				self.aimHold = 0 -- 4785
			else -- 4785
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4787
				self:throwBottle(____end.x, ____end.y) -- 4788
				self.aimHold = 0 -- 4789
			end -- 4789
		end -- 4789
	else -- 4789
		self.aimHold = 0 -- 4793
		self.bottleAimX = -1 -- 4794
	end -- 4794
	local fly = self.bottleFly -- 4799
	if fly ~= nil then -- 4800
		fly.t = fly.t + dt -- 4801
		fly.x = fly.x0 + fly.vx * fly.t -- 4802
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4803
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4804
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4805
			self:landBottle(fly) -- 4806
		end -- 4806
	end -- 4806
	if self.bottleLandT > 0 then -- 4809
		self.bottleLandT = self.bottleLandT - dt -- 4810
	end -- 4810
	if scav ~= nil then -- 4813
		self:stepScav(dt, scav) -- 4814
	end -- 4814
	local line = self.room.passLine -- 4817
	if line ~= nil and not self.passed and p.x >= line then -- 4818
		self.passed = true -- 4819
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4820
	end -- 4820
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4823
	if underTable then -- 4824
		self.footHintT = self.footHintT - 1 -- 4825
		if self.footHintT <= 0 then -- 4826
			self.footHintT = 90 -- 4827
			local scavX = self.scavX -- 4828
			local near = math.abs(scavX - p.x) < 120 -- 4829
			local walkingAway = self.scavState == "walk" and math.abs(self.scavTargetX - p.x) >= 120 -- 4830
			local heard = self.scavState == "chase" or near and not walkingAway -- 4831
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4832
			self:emit("storyBeat", {beat = heard and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4833
		end -- 4833
	else -- 4833
		self.footHintT = 0 -- 4836
	end -- 4836
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4839
		self.ditchHinted = true -- 4840
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4841
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4842
	end -- 4842
	if self.passed and p.x >= self.ox + 640 then -- 4845
		self:requestRoom("forest", "过第一院出院") -- 4846
		self:flashSet("钻出暗渠 · 北塔森林", 1.4) -- 4847
	end -- 4847
end -- 4749
function Play.prototype.bottleEnd(self) -- 4852
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4853
	local clampedX = math.max( -- 4856
		self.room.minX + 12, -- 4856
		math.min(self.room.maxX - 12, aim.x) -- 4856
	) -- 4856
	local g = self:groundAt(clampedX, aim.y + 240, 3) -- 4857
	return {x = clampedX, y = g} -- 4858
end -- 4852
function Play.prototype.throwBottle(self, tx, ty) -- 4862
	local p = self.player -- 4863
	local dir = tx >= p.x and 1 or -1 -- 4865
	p.facing = dir -- 4866
	local x0 = p.x + dir * 10 -- 4867
	local y0 = p.y + p.h * 0.7 -- 4868
	self.bottleTargetX = tx -- 4869
	self.bottleTargetY = ty -- 4870
	self.bottleSurfaceY = ty -- 4871
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4872
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4873
	self.bottleFly = { -- 4874
		x = x0, -- 4874
		y = y0, -- 4874
		x0 = x0, -- 4874
		y0 = y0, -- 4874
		vx = vx, -- 4874
		vy = vy, -- 4874
		t = 0 -- 4874
	} -- 4874
	self.hasBottle = false -- 4875
	self:flashSet("投出", 0.4) -- 4876
	self:emit( -- 4877
		"bottleThrown", -- 4877
		{ -- 4877
			fromX = x0, -- 4878
			fromY = y0, -- 4879
			targetX = tx, -- 4880
			targetY = ty, -- 4881
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4882
		} -- 4882
	) -- 4882
end -- 4862
function Play.prototype.bottleSurfaceAt(self, x) -- 4887
	if self.room.softX ~= nil and math.abs(x - self.room.softX) <= 34 then -- 4888
		return "soft" -- 4889
	end -- 4889
	if self.room.basinX ~= nil and math.abs(x - self.room.basinX) <= 24 then -- 4891
		return "iron" -- 4892
	end -- 4892
	return "brick" -- 4894
end -- 4887
function Play.prototype.landBottle(self, fly) -- 4898
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4899
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4900
	local s = self.room.scavenger -- 4901
	local surface = self:bottleSurfaceAt(x) -- 4902
	local effRange = s == nil and 0 or (surface == "iron" and s.range * 1.25 or s.range) -- 4903
	local heard = surface ~= "soft" and s ~= nil and math.abs(x - self.scavX) <= effRange -- 4904
	local stallTicks = s == nil and 0 or (surface == "iron" and s.stallTicks + 90 or s.stallTicks) -- 4905
	self.bottleFly = nil -- 4906
	self.bottleTargetX = -1 -- 4907
	self.bottleTargetY = 0 -- 4908
	self.bottleSurfaceY = -1 -- 4909
	self.bottleLandX = x -- 4910
	self.bottleLandY = y -- 4911
	self.bottleLandT = 0.9 -- 4912
	self:emit("bottleLanded", { -- 4913
		x = x, -- 4914
		y = y, -- 4915
		surface = surface, -- 4916
		heard = heard, -- 4917
		resonance = surface == "iron", -- 4918
		stallTicks = heard and stallTicks or 0, -- 4919
		scavState = self.scavState -- 4920
	}) -- 4920
	self:hearBottle(x, surface) -- 4922
end -- 4898
function Play.prototype.hearBottle(self, x, surface) -- 4926
	if surface == nil then -- 4926
		surface = "brick" -- 4926
	end -- 4926
	local s = self.room.scavenger -- 4927
	if s == nil then -- 4928
		return -- 4929
	end -- 4929
	if surface == "soft" then -- 4931
		self:flashSet("落在软土 · 没出声", 0.8) -- 4932
		return -- 4933
	end -- 4933
	local effRange = surface == "iron" and s.range * 1.25 or s.range -- 4935
	if math.abs(x - self.scavX) > effRange then -- 4936
		self:flashSet("落地 · 他没听见", 0.6) -- 4937
		return -- 4938
	end -- 4938
	self.scavState = "turn" -- 4940
	self.scavT = s.hearTicks -- 4941
	self.scavTargetX = surface == "iron" and self.room.basinX ~= nil and self.room.basinX or x -- 4942
	self.scavStallBonus = surface == "iron" and 90 or 0 -- 4943
	self:flashSet(surface == "iron" and "铁盆余振两响 · 他停下来细听" or "砖地一响 · 他转头", 1.1) -- 4944
end -- 4926
function Play.prototype.stepScav(self, dt, s) -- 4948
	if self.scavState == "chase" then -- 4950
		return -- 4951
	end -- 4951
	if self.scavState == "turn" then -- 4953
		self.scavT = self.scavT - 1 -- 4954
		if self.scavT <= 0 then -- 4955
			self.scavState = "walk" -- 4956
		end -- 4956
		return -- 4958
	end -- 4958
	if self.scavState == "walk" then -- 4960
		local d = self.scavTargetX - self.scavX -- 4961
		if math.abs(d) < 4 then -- 4962
			self.scavState = "stall" -- 4963
			self.scavT = s.stallTicks + self.scavStallBonus -- 4964
			self.scavStallBonus = 0 -- 4965
			return -- 4966
		end -- 4966
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4968
		return -- 4969
	end -- 4969
	if self.scavState == "stall" then -- 4971
		self.scavT = self.scavT - 1 -- 4972
		if self.scavT <= 0 then -- 4973
			self.scavState = "back" -- 4974
		end -- 4974
		return -- 4976
	end -- 4976
	if self.scavState == "back" then -- 4978
		local home = math.max( -- 4979
			s.x0, -- 4979
			math.min(s.x1, self.scavX) -- 4979
		) -- 4979
		if math.abs(home - self.scavX) < 2 then -- 4980
			self.scavState = "patrol" -- 4981
			return -- 4982
		end -- 4982
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4984
		return -- 4985
	end -- 4985
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4987
	if self.scavX >= s.x1 then -- 4988
		self.scavX = s.x1 -- 4989
		self.scavDir = -1 -- 4990
	elseif self.scavX <= s.x0 then -- 4991
		self.scavX = s.x0 -- 4992
		self.scavDir = 1 -- 4993
	end -- 4993
end -- 4948
function Play.prototype.stepCart(self, dt, input) -- 5001
	local p = self.player -- 5002
	local c = self.room.cart -- 5003
	if self.gripping then -- 5005
		if not input.interact.held then -- 5006
			self.gripping = false -- 5007
			self:flashSet("松开车把", 0.4) -- 5008
			return -- 5009
		end -- 5009
	else -- 5009
		if not input.interact.pressed then -- 5012
			return -- 5013
		end -- 5013
		if not self:cartHandleInReach(p) then -- 5015
			return -- 5016
		end -- 5016
		local track = c.depth or 0 -- 5018
		if self:limitDepth(p, track) ~= track then -- 5019
			return -- 5020
		end -- 5020
		p.depth = track -- 5022
		p.depthSpeed = 0 -- 5023
		self.gripping = true -- 5024
		self:flashSet("握住车把", 0.4) -- 5025
		return -- 5026
	end -- 5026
	if self.cartDocked then -- 5029
		return -- 5030
	end -- 5030
	local dir = input.moveX -- 5032
	if dir == 0 then -- 5033
		return -- 5034
	end -- 5034
	local lo = math.min(c.startX, c.endX) -- 5036
	local hi = math.max(c.startX, c.endX) -- 5037
	local next = self.cartAxle + dir * CART_SPEED * dt -- 5038
	if next < lo then -- 5039
		next = lo -- 5040
	end -- 5040
	if next > hi then -- 5042
		next = hi -- 5043
	end -- 5043
	local delta = next - self.cartAxle -- 5045
	if delta == 0 then -- 5046
		return -- 5047
	end -- 5047
	self.cartAxle = next -- 5049
	p.x = p.x + delta -- 5050
	p.facing = dir > 0 and 1 or -1 -- 5051
	self:slideX(p, 0) -- 5052
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 5053
		self.gripping = false -- 5054
		self:flashSet("跟不上了，脱手", 0.6) -- 5055
		return -- 5056
	end -- 5056
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 5058
		self.cartDocked = true -- 5059
		self.gripping = false -- 5060
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 5061
		self:flashSet("车轮落窝", 1.2) -- 5062
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 5063
		self:flashSet("车轮回到起点", 0.5) -- 5064
	end -- 5064
end -- 5001
function Play.prototype.requestRoom(self, key, reason) -- 5072
	if self.wantRoom ~= "" then -- 5075
		return -- 5076
	end -- 5076
	self.wantRoom = key -- 5078
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 5079
end -- 5072
function Play.prototype.checkCarryGate(self) -- 5086
	if self.room.key == "checkpoint" then -- 5087
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 5088
			self.carryCartAxle = self.cartAxle -- 5089
			self.carryCartDocked = self.cartDocked -- 5090
			self:requestRoom("gate", "检查站出口") -- 5091
			self:flashSet("出检查站 · 城门", 1.2) -- 5092
		end -- 5092
		return -- 5094
	end -- 5094
	if self.room.key == "outside" then -- 5096
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 5099
			self.carryCartAxle = self.cartAxle -- 5100
			self.carryCartDocked = self.cartDocked -- 5101
			self:requestRoom("village", "墙根走完") -- 5102
			self:flashSet("墙根走完 · 进村口", 1.2) -- 5103
		end -- 5103
	end -- 5103
end -- 5086
function Play.prototype.aimAt(self, wx, wy) -- 5110
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 5111
	self.aimX = s.x -- 5112
	self.aimY = s.y -- 5113
end -- 5110
function Play.prototype.shoot(self, a) -- 5116
	if self.isCampaign and self.reloadT > 0 then -- 5117
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 5118
		return -- 5119
	end -- 5119
	local ox = a.x + a.facing * 8 -- 5121
	local muzzleY = a.y + a.h * 0.72 -- 5122
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 5123
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 5125
	local dx = aim.x - ox -- 5128
	local dy = aim.y - oy -- 5129
	local len = math.sqrt(dx * dx + dy * dy) -- 5130
	if len < 0.001 then -- 5131
		dx = a.facing -- 5132
		dy = 0 -- 5133
	else -- 5133
		dx = dx / len -- 5135
		dy = dy / len -- 5136
	end -- 5136
	if dx ~= 0 then -- 5138
		a.facing = dx > 0 and 1 or -1 -- 5139
	end -- 5139
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 5142
	local hitEnemy = self:raycastEnemies(ray) -- 5143
	local tEnemy = hitEnemy.t -- 5144
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 5145
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 5146
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 5147
	local tWall = solid.t -- 5148
	local rawEffect = self:consumeReloadEffect() -- 5150
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 5151
	local reloadEffect = rawEffect -- 5152
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 5154
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 5155
	self.trace = { -- 5157
		x0 = ox, -- 5157
		y0 = oy, -- 5157
		x1 = ox + dx * t, -- 5157
		y1 = oy + dy * t, -- 5157
		hit = hit -- 5157
	} -- 5157
	self.traceT = 0.12 -- 5158
	self:applyFireDanger(ox) -- 5159
	local killed = false -- 5160
	if hit then -- 5161
		local i = hitEnemy.index -- 5162
		local e = self.enemies[i + 1] -- 5163
		local impactY = oy + dy * tEnemy -- 5164
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 5165
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 5166
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 5167
			local pushRank = self:talentRank("push_force") -- 5168
			local dmg = reloadEffect == "push" and 2 + pushRank or 1 -- 5169
			e.shieldHp = math.max(0, (e.shieldHp or 0) - dmg) -- 5170
			e.hitT = 0.3 -- 5171
			if reloadEffect == "push" then -- 5172
				local kb = 46 + 24 * pushRank -- 5173
				e.x = math.max( -- 5174
					self.room.minX + 20, -- 5174
					math.min(self.room.maxX - 20, e.x + a.facing * kb) -- 5174
				) -- 5174
				if pushRank > 0 then -- 5175
					self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5176
				end -- 5176
				self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5178
				self:flashSet(e.shieldHp <= 0 and "推退破盾！" or "推退震退持盾手", 0.9) -- 5179
			else -- 5179
				self:flashSet( -- 5181
					(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 5181
					0.8 -- 5181
				) -- 5181
			end -- 5181
			self:emit("shotResolved", { -- 5183
				hit = true, -- 5184
				enemyIndex = i, -- 5184
				enemyX = e.x, -- 5184
				aimX = aim.x, -- 5184
				aimY = aim.y, -- 5184
				impactX = ox + dx * t, -- 5185
				impactY = oy + dy * t, -- 5185
				shield = true -- 5185
			}) -- 5185
			self:beginReload() -- 5187
			return -- 5188
		end -- 5188
		e.alive = false -- 5190
		e.hitT = 0.4 -- 5191
		killed = true -- 5192
		self:flashSet("命中", 0.6) -- 5193
		self:dropFor(e) -- 5194
		local lpRank = self:talentRank("lantern_pierce") -- 5195
		if reloadEffect == "light" and (weaponFx == "light" or lpRank > 0) then -- 5196
			local blindRadius = (weaponFx == "light" and 160 or 110) + 50 * lpRank -- 5197
			self:blindNearby(e, blindRadius, i) -- 5198
		end -- 5198
		if reloadEffect == "push" then -- 5200
			local pushRank = self:talentRank("push_force") -- 5201
			e.x = e.x + a.facing * (46 + 24 * pushRank) -- 5202
			if pushRank > 0 then -- 5203
				self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5204
			end -- 5204
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5206
		elseif reloadEffect == "echo" then -- 5207
			local echoRank = self:talentRank("echo_wide") -- 5208
			self:echoToSource(a, (weaponFx == "echo" and 2 or 1) + echoRank, 60 + 30 * echoRank) -- 5209
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 5210
		elseif reloadEffect == "light" then -- 5211
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 5212
		end -- 5212
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 5214
		self:damageProp(solid.box, 1) -- 5215
	else -- 5215
		self:flashSet("打空", 0.35) -- 5217
	end -- 5217
	if self.isCampaign then -- 5219
		self:beginReload() -- 5220
	end -- 5220
	self:emit("shotResolved", { -- 5222
		hit = hit, -- 5223
		enemyIndex = hit and hitEnemy.index or -1, -- 5224
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 5225
		aimX = aim.x, -- 5226
		aimY = aim.y, -- 5227
		impactX = ox + dx * t, -- 5228
		impactY = oy + dy * t -- 5229
	}) -- 5229
end -- 5116
function Play.prototype.staggerNearby(self, center, radius, delayTicks, skipIndex) -- 5234
	local i = 0 -- 5235
	do -- 5235
		i = 0 -- 5236
		while i < #self.enemies do -- 5236
			do -- 5236
				if i == skipIndex then -- 5237
					goto __continue872 -- 5238
				end -- 5238
				local e = self.enemies[i + 1] -- 5240
				if not e.alive or math.abs(e.x - center.x) > radius then -- 5241
					goto __continue872 -- 5242
				end -- 5242
				e.warnT = 0 -- 5244
				e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 5245
				local pushDir = e.x >= center.x and 1 or -1 -- 5246
				e.x = math.max( -- 5247
					self.room.minX + 20, -- 5247
					math.min(self.room.maxX - 20, e.x + pushDir * 22) -- 5247
				) -- 5247
			end -- 5247
			::__continue872:: -- 5247
			i = i + 1 -- 5236
		end -- 5236
	end -- 5236
end -- 5234
function Play.prototype.applyFireDanger(self, shotX) -- 5252
	local ____temp_143 = self.isCampaign and self.run.joined -- 5253
	if ____temp_143 then -- 5253
		local ____opt_138 = self.room.campaign -- 5254
		local ____temp_142 = (____opt_138 and ____opt_138.chapter) == "S" -- 5254
		if not ____temp_142 then -- 5254
			local ____opt_140 = self.room.campaign -- 5254
			____temp_142 = (____opt_140 and ____opt_140.chapter) == "C" -- 5254
		end -- 5254
		____temp_143 = ____temp_142 -- 5253
	end -- 5253
	local isStorySc = ____temp_143 -- 5253
	if self.room.key ~= "checkpoint" and not isStorySc or not self.partner.alive then -- 5255
		return -- 5256
	end -- 5256
	local dangerX = shotX -- 5258
	local best = -1 -- 5259
	local bestD = 1000000000 -- 5260
	local i = 0 -- 5261
	do -- 5261
		i = 0 -- 5262
		while i < #self.enemies do -- 5262
			do -- 5262
				local e = self.enemies[i + 1] -- 5263
				if not e.alive then -- 5264
					goto __continue878 -- 5265
				end -- 5265
				local d = math.abs(e.x - self.partner.x) -- 5267
				if d < bestD then -- 5268
					bestD = d -- 5269
					best = i -- 5270
				end -- 5270
			end -- 5270
			::__continue878:: -- 5270
			i = i + 1 -- 5262
		end -- 5262
	end -- 5262
	if best >= 0 then -- 5273
		dangerX = self.enemies[best + 1].x -- 5274
	end -- 5274
	if isStorySc and math.abs(dangerX - self.partner.x) > 260 then -- 5277
		return -- 5278
	end -- 5278
	local exposed = self:childExposed(dangerX) -- 5280
	local before = self.escort.fear -- 5281
	local dangerId = self.nextDangerId -- 5282
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 5283
	self.nextDangerId = self.nextDangerId + 1 -- 5284
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 5285
	if after > before then -- 5286
		self:flashSet( -- 5287
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 5287
			1 -- 5287
		) -- 5287
	elseif not exposed then -- 5288
		self:flashSet("枪声没够到她", 0.5) -- 5289
	end -- 5289
end -- 5252
function Play.prototype.childExposed(self, dangerX) -- 5294
	local c = self.partner -- 5295
	if not c.alive then -- 5296
		return false -- 5297
	end -- 5297
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 5299
		self.boxes, -- 5300
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 5300
	) then -- 5300
		return false -- 5301
	end -- 5301
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 5303
		return false -- 5304
	end -- 5304
	local toDanger = dangerX - c.x -- 5306
	local toPlayer = self.player.x - c.x -- 5307
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 5308
		return false -- 5310
	end -- 5310
	return true -- 5312
end -- 5294
function Play.prototype.raycastEnemies(self, ray) -- 5316
	local best = -1 -- 5317
	local bestI = -1 -- 5318
	do -- 5318
		local i = 0 -- 5319
		while i < #self.enemies do -- 5319
			do -- 5319
				local e = self.enemies[i + 1] -- 5320
				if not e.alive then -- 5321
					goto __continue893 -- 5322
				end -- 5322
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 5324
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 5325
				if t >= 0 and (best < 0 or t < best) then -- 5326
					best = t -- 5327
					bestI = i -- 5328
				end -- 5328
			end -- 5328
			::__continue893:: -- 5328
			i = i + 1 -- 5319
		end -- 5319
	end -- 5319
	return {t = best, index = bestI} -- 5331
end -- 5316
function Play.prototype.raycastWorld(self, ray) -- 5334
	return self:raycastSolid(ray).t -- 5335
end -- 5334
function Play.prototype.raycastSolid(self, ray) -- 5339
	local best = -1 -- 5340
	local bestBox = nil -- 5341
	for ____, box in ipairs(self.boxes) do -- 5342
		do -- 5342
			if box.broken == true or box.hidden == true then -- 5343
				goto __continue898 -- 5344
			end -- 5344
			local t = hitBox(ray, box) -- 5349
			if t > 2 and (best < 0 or t < best) then -- 5351
				best = t -- 5352
				bestBox = box -- 5353
			end -- 5353
		end -- 5353
		::__continue898:: -- 5353
	end -- 5353
	if ray.dy < 0 then -- 5356
		local t = -ray.y / ray.dy -- 5357
		if t >= 0 and (best < 0 or t < best) then -- 5358
			best = t -- 5359
			bestBox = nil -- 5360
		end -- 5360
	end -- 5360
	return {t = best, box = bestBox} -- 5363
end -- 5339
function Play.prototype.dropFor(self, e) -- 5367
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 5368
		return -- 5369
	end -- 5369
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 5371
		return -- 5372
	end -- 5372
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 5374
	local ____self_pickups_144 = self.pickups -- 5375
	____self_pickups_144[#____self_pickups_144 + 1] = { -- 5375
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 5376
		kind = e.drop, -- 5376
		x = e.x, -- 5376
		y = e.y, -- 5376
		depth = e.depth, -- 5377
		label = label .. " ×1" -- 5377
	} -- 5377
	self:log("掉落 " .. label) -- 5379
end -- 5367
function Play.prototype.damageProp(self, b, amount) -- 5383
	if b.breakable == nil or b.broken == true then -- 5384
		return -- 5385
	end -- 5385
	local ____b_breakable_145, ____hp_146 = b.breakable, "hp" -- 5387
	____b_breakable_145[____hp_146] = ____b_breakable_145[____hp_146] - amount -- 5387
	if b.breakable.hp > 0 then -- 5388
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 5389
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 5390
		return -- 5391
	end -- 5391
	b.broken = true -- 5393
	for ____, other in ipairs(self.boxes) do -- 5394
		if other.id ~= nil and other.id == b.id then -- 5395
			other.broken = true -- 5396
		end -- 5396
	end -- 5396
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 5399
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 5400
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 5401
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 5402
end -- 5383
function Play.prototype.slideDepth(self, a, distance) -- 5406
	a.depth = self:limitDepth(a, a.depth + distance) -- 5407
end -- 5406
function Play.prototype.limitDepth(self, a, target) -- 5410
	local road = self.room.depth -- 5411
	if road == nil or target == a.depth then -- 5412
		return a.depth -- 5413
	end -- 5413
	local next = math.max( -- 5415
		road.min, -- 5415
		math.min(road.max, target) -- 5415
	) -- 5415
	local half = a.w / 2 -- 5416
	for ____, b in ipairs(self.boxes) do -- 5417
		do -- 5417
			local footprint = b.depth -- 5418
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5419
				goto __continue916 -- 5423
			end -- 5423
			local front = footprint.min - ACTOR_DEPTH_HALF -- 5425
			local back = footprint.max + ACTOR_DEPTH_HALF -- 5426
			if a.depth <= front and next > front then -- 5427
				next = front -- 5428
			elseif a.depth >= back and next < back then -- 5429
				next = back -- 5430
			end -- 5430
		end -- 5430
		::__continue916:: -- 5430
	end -- 5430
	return next -- 5433
end -- 5410
function Play.prototype.slideX(self, a, dx) -- 5437
	local nx = a.x + dx -- 5438
	local half = a.w / 2 -- 5439
	local room = self.room -- 5440
	nx = math.max( -- 5441
		room.minX + half, -- 5441
		math.min(room.maxX - half, nx) -- 5441
	) -- 5441
	local i = 0 -- 5442
	do -- 5442
		i = 0 -- 5443
		while i < #self.boxes do -- 5443
			do -- 5443
				local b = self.boxes[i + 1] -- 5444
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5445
					goto __continue923 -- 5446
				end -- 5446
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5448
					goto __continue923 -- 5449
				end -- 5449
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5451
					goto __continue923 -- 5452
				end -- 5452
				if nx + half > b.x0 and nx - half < b.x1 then -- 5454
					if a.x <= b.x0 then -- 5455
						nx = b.x0 - half -- 5456
					elseif a.x >= b.x1 then -- 5457
						nx = b.x1 + half -- 5458
					else -- 5458
						nx = a.x -- 5460
					end -- 5460
				end -- 5460
			end -- 5460
			::__continue923:: -- 5460
			i = i + 1 -- 5443
		end -- 5443
	end -- 5443
	if self.room.key == "outside" and not self.cartDocked and a.y < CART_CLEAR - 0.001 then -- 5466
		local bx0 = math.max(room.arch.x0, self.cartAxle - CART_HALF) -- 5467
		local bx1 = math.min(room.arch.x1, self.cartAxle + CART_HALF) -- 5468
		if bx1 > bx0 and nx + half > bx0 and nx - half < bx1 then -- 5469
			if a.x <= bx0 then -- 5470
				nx = bx0 - half -- 5471
			elseif a.x >= bx1 then -- 5472
				nx = bx1 + half -- 5473
			else -- 5473
				nx = a.x -- 5475
			end -- 5475
		end -- 5475
	end -- 5475
	local arch = room.arch -- 5483
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 5484
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 5485
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 5486
			if a.x <= arch.x0 then -- 5487
				nx = arch.x0 - half -- 5488
			elseif a.x >= arch.x1 then -- 5489
				nx = arch.x1 + half -- 5490
			end -- 5490
		end -- 5490
	end -- 5490
	a.x = nx -- 5494
end -- 5437
function Play.prototype.fallY(self, a, dt) -- 5498
	a.vy = a.vy - ____exports.GRAVITY * dt -- 5499
	if a.vy < -900 then -- 5500
		a.vy = -900 -- 5501
	end -- 5501
	local ny = a.y + a.vy * dt -- 5503
	local half = a.w / 2 -- 5504
	if a.vy <= 0 then -- 5505
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 5507
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 5508
		if ny <= ground then -- 5509
			ny = ground -- 5510
			a.vy = 0 -- 5511
			a.onGround = true -- 5512
		else -- 5512
			a.onGround = false -- 5514
		end -- 5514
	else -- 5514
		a.onGround = false -- 5517
		local i = 0 -- 5518
		do -- 5518
			i = 0 -- 5519
			while i < #self.boxes do -- 5519
				do -- 5519
					local b = self.boxes[i + 1] -- 5520
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5521
						goto __continue947 -- 5522
					end -- 5522
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5524
						goto __continue947 -- 5525
					end -- 5525
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 5527
						goto __continue947 -- 5528
					end -- 5528
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 5530
						ny = b.y0 - a.h -- 5531
						a.vy = 0 -- 5532
					end -- 5532
				end -- 5532
				::__continue947:: -- 5532
				i = i + 1 -- 5519
			end -- 5519
		end -- 5519
	end -- 5519
	a.y = ny -- 5536
end -- 5498
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 5540
	if depth == nil then -- 5540
		depth = 0 -- 5540
	end -- 5540
	local g = -9999 -- 5541
	local i = 0 -- 5542
	do -- 5542
		i = 0 -- 5543
		while i < #self.floors do -- 5543
			local f = self.floors[i + 1] -- 5544
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 5545
				g = f.y1 -- 5546
			end -- 5546
			i = i + 1 -- 5543
		end -- 5543
	end -- 5543
	do -- 5543
		i = 0 -- 5549
		while i < #self.boxes do -- 5549
			do -- 5549
				local b = self.boxes[i + 1] -- 5550
				if b.broken == true or b.hidden == true or b.soft == true then -- 5551
					goto __continue957 -- 5552
				end -- 5552
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 5554
					g = b.y1 -- 5556
				end -- 5556
			end -- 5556
			::__continue957:: -- 5556
			i = i + 1 -- 5549
		end -- 5549
	end -- 5549
	return g -- 5559
end -- 5540
function Play.prototype.updateCamera(self, dt) -- 5562
	local p = self.player -- 5563
	local tx = p.x + p.facing * 30 -- 5564
	local ty = p.y + CAM_LOOK_UP -- 5565
	local k = math.min(1, CAM_FOLLOW * dt) -- 5566
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 5567
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 5568
end -- 5562
function Play.prototype.clampCamera(self, w, h) -- 5572
	local room = self.room -- 5573
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 5574
	local spanX = room.maxX - room.minX -- 5575
	if spanX <= halfW * 2 then -- 5576
		self.cam.x = (room.minX + room.maxX) / 2 -- 5577
	else -- 5577
		self.cam.x = math.max( -- 5579
			room.minX + halfW, -- 5579
			math.min(room.maxX - halfW, self.cam.x) -- 5579
		) -- 5579
	end -- 5579
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 5582
	local spanY = room.height -- 5583
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 5584
	if spanY <= halfH * 2 then -- 5585
		self.cam.y = camY -- 5586
	else -- 5586
		self.cam.y = math.max( -- 5588
			camY, -- 5588
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 5588
		) -- 5588
	end -- 5588
end -- 5572
function Play.prototype.flashSet(self, text, t) -- 5592
	self.flash = text -- 5593
	self.flashT = t -- 5594
end -- 5592
function Play.prototype.statusText(self) -- 5598
	local p = self.player -- 5599
	local parts = {} -- 5600
	local who = self.childMode and "小满" or "周戍" -- 5601
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 5602
	if self.room.key == "prologue" then -- 5604
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5605
		if self.phase == "prologue-wake" then -- 5606
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 5607
		elseif self.phase == "prologue-shadow" then -- 5608
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 5609
		elseif self.phase == "prologue-escape" then -- 5610
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 5611
		elseif self.phase == "prologue-hide" then -- 5612
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 5613
		elseif self.phase == "prologue-wait" then -- 5614
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 5615
		elseif self.phase == "prologue-give" then -- 5616
			parts[#parts + 1] = (("递物 " .. tostring(self.phaseTick)) .. "/") .. tostring(____exports.PROLOGUE_GIVE_TICKS) -- 5617
		else -- 5617
			parts[#parts + 1] = "跟随" -- 5619
		end -- 5619
		if self.paused then -- 5621
			parts[#parts + 1] = "已暂停" -- 5622
		end -- 5622
		return table.concat(parts, " · ") -- 5624
	end -- 5624
	if self.room.key == "street" then -- 5626
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5627
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5628
		if self.paused then -- 5629
			parts[#parts + 1] = "已暂停" -- 5630
		end -- 5630
		return table.concat(parts, " · ") -- 5632
	end -- 5632
	if self.room.key == "gate" then -- 5634
		local ____temp_147 -- 5635
		if self.room.story == nil then -- 5635
			____temp_147 = nil -- 5635
		else -- 5635
			____temp_147 = self.room.story.gate -- 5635
		end -- 5635
		local g = ____temp_147 -- 5635
		if g ~= nil then -- 5636
			parts[#parts + 1] = self:gateLabel() -- 5637
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 5638
				0, -- 5639
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 5639
			))) .. " 秒" -- 5639
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5640
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5641
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 5642
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 5643
			if self.gateFailCount > 0 then -- 5644
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 5645
			end -- 5645
			if self.flash ~= "" then -- 5647
				parts[#parts + 1] = self.flash -- 5648
			end -- 5648
		end -- 5648
		if self.paused then -- 5651
			parts[#parts + 1] = "已暂停" -- 5652
		end -- 5652
		return table.concat(parts, " · ") -- 5654
	end -- 5654
	if self.room.key == "forest" then -- 5656
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5657
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5658
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5659
		if self.caughtT > 0 then -- 5660
			parts[#parts + 1] = "复位中" -- 5661
		end -- 5661
		if self.paused then -- 5663
			parts[#parts + 1] = "已暂停" -- 5664
		end -- 5664
		return table.concat(parts, " · ") -- 5666
	end -- 5666
	if self.room.key == "tower" then -- 5668
		if self.phase == "tower-wait" then -- 5669
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5670
		elseif self.phase == "tower-knock" then -- 5671
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5672
		elseif self.phase == "tower-enter" then -- 5673
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5674
		elseif self.phase == "tower-desk" then -- 5675
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5676
		elseif self.phase == "tower-given" then -- 5677
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5678
		else -- 5678
			parts[#parts + 1] = "片尾" -- 5680
		end -- 5680
		if self.paused then -- 5682
			parts[#parts + 1] = "已暂停" -- 5683
		end -- 5683
		return table.concat(parts, " · ") -- 5685
	end -- 5685
	if self.room.key == "village" then -- 5687
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5688
		if self.hasBottle then -- 5689
			parts[#parts + 1] = "有瓶" -- 5690
		elseif self.bottleFly ~= nil then -- 5691
			parts[#parts + 1] = "瓶在飞" -- 5692
		else -- 5692
			parts[#parts + 1] = "空手" -- 5694
		end -- 5694
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5696
		if self.scavChase then -- 5697
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5698
		end -- 5698
		if self.passed then -- 5700
			parts[#parts + 1] = "已过通行线" -- 5701
		end -- 5701
		if self.paused then -- 5703
			parts[#parts + 1] = "已暂停" -- 5704
		end -- 5704
		return table.concat(parts, " · ") -- 5706
	end -- 5706
	local isChild = self.childMode -- 5709
	if isChild then -- 5710
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5711
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5712
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5713
	else -- 5713
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5715
		if p.rollT > 0 then -- 5716
			parts[#parts + 1] = "翻滚中" -- 5717
		end -- 5717
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5719
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5720
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5721
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5722
	end -- 5722
	if self.checkpoint >= 0 then -- 5724
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5725
	end -- 5725
	if self.paused then -- 5727
		parts[#parts + 1] = "已暂停" -- 5728
	end -- 5728
	return table.concat(parts, " · ") -- 5730
end -- 5598
function Play.prototype.aliveEnemies(self) -- 5734
	local n = 0 -- 5735
	local i = 0 -- 5736
	do -- 5736
		i = 0 -- 5737
		while i < #self.enemies do -- 5737
			if self.enemies[i + 1].alive then -- 5738
				n = n + 1 -- 5739
			end -- 5739
			i = i + 1 -- 5737
		end -- 5737
	end -- 5737
	return n -- 5742
end -- 5734
function Play.prototype.threatened(self) -- 5747
	do -- 5747
		local i = 0 -- 5748
		while i < #self.enemies do -- 5748
			local e = self.enemies[i + 1] -- 5749
			if e.alive and e.warnT > 0 then -- 5750
				return true -- 5751
			end -- 5751
			i = i + 1 -- 5748
		end -- 5748
	end -- 5748
	return false -- 5754
end -- 5747
function Play.prototype.gateSecondsLeft(self) -- 5757
	local ____temp_148 -- 5758
	if self.room.story == nil then -- 5758
		____temp_148 = nil -- 5758
	else -- 5758
		____temp_148 = self.room.story.gate -- 5758
	end -- 5758
	local g = ____temp_148 -- 5758
	if g == nil then -- 5759
		return 0 -- 5760
	end -- 5760
	return math.max( -- 5762
		0, -- 5762
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5762
	) -- 5762
end -- 5757
function Play.prototype.gateLabel(self) -- 5765
	if self.phase == "gate-idle" then -- 5766
		return "待就位" -- 5767
	end -- 5767
	if self.phase == "gate-hold" then -- 5769
		return "守点中" -- 5770
	end -- 5770
	if self.phase == "gate-send" then -- 5772
		return "送别" -- 5773
	end -- 5773
	if self.phase == "gate-farewell" then -- 5775
		return "嘱咐 " .. tostring(self.phaseTick) -- 5776
	end -- 5776
	if self.phase == "gate-count" then -- 5778
		return "数数 " .. tostring(self.countTick) -- 5779
	end -- 5779
	return "她走" -- 5781
end -- 5765
function Play.prototype.dogLabel(self) -- 5785
	if self.dogState == "ear" then -- 5786
		return "转耳" -- 5787
	end -- 5787
	if self.dogState == "chase" then -- 5789
		return "追" -- 5790
	end -- 5790
	if self.dogState == "sniff" then -- 5792
		return "停" -- 5793
	end -- 5793
	if self.dogState == "back" then -- 5795
		return "回线" -- 5796
	end -- 5796
	return "巡逻" -- 5798
end -- 5785
function Play.prototype.doorXOf(self) -- 5801
	local ____temp_149 -- 5802
	if self.room.story == nil then -- 5802
		____temp_149 = nil -- 5802
	else -- 5802
		____temp_149 = self.room.story.tower -- 5802
	end -- 5802
	local t = ____temp_149 -- 5802
	return t == nil and 0 or t.doorX -- 5803
end -- 5801
function Play.prototype.scavLabel(self) -- 5807
	if self.scavState == "chase" then -- 5808
		return "追" -- 5809
	end -- 5809
	if self.scavState == "turn" then -- 5811
		return "转头" -- 5812
	end -- 5812
	if self.scavState == "walk" then -- 5814
		return "赶来" -- 5815
	end -- 5815
	if self.scavState == "stall" then -- 5817
		return "停住" -- 5818
	end -- 5818
	if self.scavState == "back" then -- 5820
		return "回位" -- 5821
	end -- 5821
	return "巡逻" -- 5823
end -- 5807
function Play.prototype.hintText(self) -- 5827
	if self.paused then -- 5828
		return "Esc 继续 · R 重置" -- 5829
	end -- 5829
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5833
		if self:threatened() then -- 5834
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5835
		end -- 5835
		if self.coverHug then -- 5837
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5838
		end -- 5838
		if self.coverNear then -- 5840
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5841
		end -- 5841
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5843
	end -- 5843
	if self.flash ~= "" then -- 5845
		return self.flash -- 5846
	end -- 5846
	if self.room.key == "prologue" then -- 5848
		if self.phase == "prologue-wake" then -- 5849
			return "父亲在门外唤 · 小满睁眼" -- 5850
		end -- 5850
		if self.phase == "prologue-shadow" then -- 5852
			return "墙上两道人影 · 碗滚到脚边" -- 5853
		end -- 5853
		if self.phase == "prologue-escape" then -- 5855
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5856
		end -- 5856
		if self.phase == "prologue-hide" then -- 5858
			return "柜门合上 · 屏住呼吸" -- 5859
		end -- 5859
		if self.phase == "prologue-wait" then -- 5861
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5862
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5863
		end -- 5863
		if self.phase == "prologue-give" then -- 5865
			return ((("递物 " .. tostring(self.phaseTick)) .. " / ") .. tostring(____exports.PROLOGUE_GIVE_TICKS)) .. " 拍 · 站着别动" -- 5866
		end -- 5866
		return "她跟着你了 · 两人一起走到门口 680" -- 5868
	end -- 5868
	if self.room.key == "street" then -- 5870
		if self:aliveEnemies() > 0 then -- 5871
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5872
		end -- 5872
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5874
	end -- 5874
	if self.room.key == "gate" then -- 5876
		local ____temp_150 -- 5877
		if self.room.story == nil then -- 5877
			____temp_150 = nil -- 5877
		else -- 5877
			____temp_150 = self.room.story.gate -- 5877
		end -- 5877
		local g = ____temp_150 -- 5877
		if g ~= nil then -- 5878
			if self.phase == "gate-idle" then -- 5879
				if self.gateNeedConfirm then -- 5880
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5881
				end -- 5881
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5883
			end -- 5883
			if self.phase == "gate-hold" then -- 5885
				if self.coveredFlash > 0 then -- 5886
					return "掩体挡下了这一枪 · 别露头" -- 5887
				end -- 5887
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5889
			end -- 5889
			if self.phase == "gate-send" then -- 5891
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5892
			end -- 5892
			if self.phase == "gate-farewell" then -- 5894
				return "城门送别 · 嘱咐她慢慢数到二十" -- 5895
			end -- 5895
			if self.phase == "gate-count" then -- 5897
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5898
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5899
				end -- 5899
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5901
			end -- 5901
			return "她自己走 · 跟着出城门 1120" -- 5903
		end -- 5903
	end -- 5903
	if self.room.key == "forest" then -- 5906
		if self.dogState == "chase" then -- 5907
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5908
		end -- 5908
		if self.dogState == "ear" then -- 5910
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5911
		end -- 5911
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5913
	end -- 5913
	if self.room.key == "tower" then -- 5915
		if self.phase == "tower-wait" then -- 5916
			return "走到门前 445 点一次 E 敲两下" -- 5917
		end -- 5917
		if self.phase == "tower-knock" then -- 5919
			return "敲两下 · 等门开" -- 5920
		end -- 5920
		if self.phase == "tower-given" then -- 5922
			return "递交针套和纸条 · 看登记簿最后一行" -- 5923
		end -- 5923
		return "片尾 · 点 E 再玩一次，回到序章" -- 5925
	end -- 5925
	if self.room.key == "village" then -- 5927
		if self.bottleFly ~= nil then -- 5928
			return "等瓶子落地 · 触地才发声" -- 5929
		end -- 5929
		if self.hasBottle then -- 5931
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5932
		end -- 5932
		if self.passed then -- 5934
			return "已过第一院 · R 重置可再来一遍" -- 5935
		end -- 5935
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5937
	end -- 5937
	if self.room.key == "outside" then -- 5939
		if self.focusCart then -- 5940
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5941
		end -- 5941
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5943
	end -- 5943
	if self.escort.state == "frozen" then -- 5945
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5946
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5947
		end -- 5947
		return "小满吓住了 · 走过去，靠近再点 E" -- 5949
	end -- 5949
	if self.escort.state == "calming" then -- 5951
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5952
	end -- 5952
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5954
end -- 5827
function Play.prototype.draw(self, draw, w, h) -- 5959
	self.viewW = w -- 5960
	self.viewH = h -- 5961
	self.view = ____exports.computeViewport(w, h) -- 5962
	self:clampCamera(w, h) -- 5963
	draw:clear() -- 5964
	draw:drawRect( -- 5966
		Rect(0, 0, w, h), -- 5966
		BG_VOID -- 5966
	) -- 5966
	local box = self:canvasRect(w, h) -- 5967
	draw:drawRect(box, BG_FAR) -- 5968
	draw:drawRect( -- 5969
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 5969
		BG_MID -- 5969
	) -- 5969
	self:drawFloors(draw, w, h) -- 5971
	self:drawSolids(draw, w, h) -- 5972
	self:drawZones(draw, w, h) -- 5973
	self:drawArch(draw, w, h) -- 5974
	self:drawCart(draw, w, h) -- 5975
	self:drawCampaignProps(draw, w, h) -- 5976
	self:drawActors(draw, w, h) -- 5977
	self:drawTrace(draw, w, h) -- 5978
	self:drawAim(draw, w, h) -- 5979
end -- 5959
function Play.prototype.canvasRect(self, w, h) -- 5983
	local v = self.view -- 5984
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 5985
end -- 5983
function Play.prototype.px(self, n) -- 5989
	return n * self.view.zoom -- 5990
end -- 5989
function Play.prototype.sx(self, wx, w) -- 5994
	local v = self.view -- 5995
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 5996
	return v.ox + lx * v.zoom -- 5997
end -- 5994
function Play.prototype.sy(self, wy, h) -- 6001
	local v = self.view -- 6002
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 6003
	return v.oy + ly * v.zoom -- 6004
end -- 6001
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 6007
	local px0 = self:sx(x0, w) -- 6008
	local px1 = self:sx(x1, w) -- 6009
	local py0 = self:sy(y0, h) -- 6010
	local py1 = self:sy(y1, h) -- 6011
	if px1 <= px0 or py1 <= py0 then -- 6012
		return -- 6013
	end -- 6013
	draw:drawRect( -- 6015
		Rect(px0, py0, px1 - px0, py1 - py0), -- 6015
		color -- 6015
	) -- 6015
end -- 6007
function Play.prototype.drawFloors(self, draw, w, h) -- 6018
	local i = 0 -- 6019
	do -- 6019
		i = 0 -- 6020
		while i < #self.room.floors do -- 6020
			local f = self.room.floors[i + 1] -- 6021
			local ____temp_151 -- 6022
			if f.y == 0 then -- 6022
				____temp_151 = self.room.depth -- 6022
			else -- 6022
				____temp_151 = nil -- 6022
			end -- 6022
			local road = ____temp_151 -- 6022
			local y = self:sy(f.y + (road and road.min or 0), h) -- 6023
			local x0 = self:sx(f.x0, w) -- 6024
			local x1 = self:sx(f.x1, w) -- 6025
			local deck = self:px(5) -- 6026
			if road ~= nil then -- 6027
				local back = self:sy(f.y + road.max, h) -- 6028
				draw:drawRect( -- 6029
					Rect(x0, y, x1 - x0, back - y), -- 6029
					FLOOR_DECK, -- 6029
					self:px(1), -- 6029
					SOLID_EDGE -- 6029
				) -- 6029
			end -- 6029
			draw:drawRect( -- 6031
				Rect(x0, y - deck, x1 - x0, deck), -- 6031
				FLOOR_DECK -- 6031
			) -- 6031
			draw:drawSegment( -- 6032
				Vec2(x0, y), -- 6032
				Vec2(x1, y), -- 6032
				self:px(1), -- 6032
				GROUND -- 6032
			) -- 6032
			i = i + 1 -- 6020
		end -- 6020
	end -- 6020
end -- 6018
function Play.prototype.drawSolids(self, draw, w, h) -- 6036
	local i = 0 -- 6037
	do -- 6037
		i = 0 -- 6038
		while i < #self.boxes do -- 6038
			do -- 6038
				local b = self.boxes[i + 1] -- 6039
				if b.id == "braced_shield" or b.hidden == true then -- 6040
					goto __continue1090 -- 6041
				end -- 6041
				if b.broken == true then -- 6043
					if b.breakable ~= nil then -- 6045
						local gy = self:sy(b.y0, h) -- 6046
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 6047
						local k = 0 -- 6048
						do -- 6048
							k = 0 -- 6049
							while k < 3 do -- 6049
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 6050
								draw:drawSegment( -- 6051
									Vec2( -- 6051
										gx - self:px(4), -- 6051
										gy + self:px(k % 2) -- 6051
									), -- 6051
									Vec2( -- 6051
										gx + self:px(5), -- 6051
										gy + self:px(k % 2) -- 6051
									), -- 6051
									self:px(1), -- 6051
									rgb -- 6051
								) -- 6051
								k = k + 1 -- 6049
							end -- 6049
						end -- 6049
					end -- 6049
					goto __continue1090 -- 6054
				end -- 6054
				local ____opt_154 = b.depth -- 6056
				local front = ____opt_154 and ____opt_154.min or 0 -- 6056
				local ____opt_156 = b.depth -- 6057
				local back = ____opt_156 and ____opt_156.max or 0 -- 6057
				local fill = SOLID_FILL -- 6058
				local line = SOLID_EDGE -- 6059
				if b.soft == true then -- 6060
					fill = SOFT -- 6061
					line = SOFT_LINE -- 6062
				elseif b.breakable ~= nil then -- 6063
					line = DANGER_LINE -- 6064
					fill = Color(0.3, 0.24, 0.16, 1) -- 6065
				elseif b.interact ~= nil then -- 6066
					line = PASS_LINE -- 6067
				end -- 6067
				self:drawBox( -- 6069
					draw, -- 6069
					w, -- 6069
					h, -- 6069
					b.x0, -- 6069
					b.x1, -- 6069
					b.y0 + front, -- 6069
					b.y1 + back, -- 6069
					fill -- 6069
				) -- 6069
				draw:drawSegment( -- 6070
					Vec2( -- 6070
						self:sx(b.x0, w), -- 6070
						self:sy(b.y1 + front, h) -- 6070
					), -- 6070
					Vec2( -- 6071
						self:sx(b.x1, w), -- 6071
						self:sy(b.y1 + front, h) -- 6071
					), -- 6071
					self:px(1), -- 6071
					line -- 6071
				) -- 6071
				if b.breakable ~= nil then -- 6073
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 6074
					local cyp = self:sy(b.y1 + front, h) -- 6075
					draw:drawSegment( -- 6076
						Vec2( -- 6076
							cxp - self:px(4), -- 6076
							cyp + self:px(1) -- 6076
						), -- 6076
						Vec2( -- 6076
							cxp + self:px(3), -- 6076
							cyp + self:px(5) -- 6076
						), -- 6076
						self:px(1), -- 6076
						line -- 6076
					) -- 6076
				end -- 6076
			end -- 6076
			::__continue1090:: -- 6076
			i = i + 1 -- 6038
		end -- 6038
	end -- 6038
end -- 6036
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 6082
	local i = 0 -- 6083
	do -- 6083
		i = 0 -- 6084
		while i < #self.pickups do -- 6084
			do -- 6084
				local pk = self.pickups[i + 1] -- 6085
				if self.run.taken[pk.id] == true then -- 6086
					goto __continue1102 -- 6087
				end -- 6087
				local gy = pk.y + (pk.depth or 0) -- 6089
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 6090
				draw:drawRect( -- 6091
					Rect( -- 6091
						self:sx(pk.x - 5, w), -- 6091
						self:sy(gy + 12 + bob, h), -- 6091
						self:px(10), -- 6091
						self:px(10) -- 6091
					), -- 6091
					Color(0.84, 0.7, 0.3, 1) -- 6092
				) -- 6092
				draw:drawSegment( -- 6093
					Vec2( -- 6093
						self:sx(pk.x - 5, w), -- 6093
						self:sy(gy + 12 + bob, h) -- 6093
					), -- 6093
					Vec2( -- 6094
						self:sx(pk.x + 5, w), -- 6094
						self:sy(gy + 12 + bob, h) -- 6094
					), -- 6094
					self:px(1), -- 6094
					Color(0.95, 0.86, 0.52, 1) -- 6094
				) -- 6094
			end -- 6094
			::__continue1102:: -- 6094
			i = i + 1 -- 6084
		end -- 6084
	end -- 6084
	if self.bracedShield ~= nil then -- 6096
		local sh = self.bracedShield -- 6097
		draw:drawRect( -- 6098
			Rect( -- 6098
				self:sx(sh.x - sh.w / 2, w), -- 6098
				self:sy(sh.y, h), -- 6098
				self:px(sh.w), -- 6098
				self:px(sh.h) -- 6098
			), -- 6098
			Color(0.42, 0.4, 0.34, 1) -- 6099
		) -- 6099
		draw:drawSegment( -- 6100
			Vec2( -- 6100
				self:sx(sh.x - sh.w / 2, w), -- 6100
				self:sy(sh.y + sh.h, h) -- 6100
			), -- 6100
			Vec2( -- 6101
				self:sx(sh.x + sh.w / 2, w), -- 6101
				self:sy(sh.y + sh.h, h) -- 6101
			), -- 6101
			self:px(1), -- 6101
			Color(0.74, 0.72, 0.62, 1) -- 6101
		) -- 6101
	end -- 6101
end -- 6082
function Play.prototype.drawZones(self, draw, w, h) -- 6105
	local i = 0 -- 6106
	do -- 6106
		i = 0 -- 6107
		while i < #self.room.zones do -- 6107
			local z = self.room.zones[i + 1] -- 6108
			local fill = DANGER -- 6109
			local line = DANGER_LINE -- 6110
			if z.tint == 2 then -- 6111
				fill = SOFT -- 6112
				line = SOFT_LINE -- 6113
			elseif z.tint == 3 then -- 6114
				fill = BRICK -- 6115
				line = BRICK_LINE -- 6116
			elseif z.tint == 4 then -- 6117
				fill = PASS -- 6118
				line = PASS_LINE -- 6119
			end -- 6119
			self:drawBox( -- 6121
				draw, -- 6121
				w, -- 6121
				h, -- 6121
				z.x0, -- 6121
				z.x1, -- 6121
				z.y, -- 6121
				z.y + z.h, -- 6121
				fill -- 6121
			) -- 6121
			draw:drawSegment( -- 6122
				Vec2( -- 6122
					self:sx(z.x0, w), -- 6122
					self:sy(z.y, h) -- 6122
				), -- 6122
				Vec2( -- 6122
					self:sx(z.x0, w), -- 6122
					self:sy(z.y + z.h, h) -- 6122
				), -- 6122
				self:px(1), -- 6122
				line -- 6122
			) -- 6122
			draw:drawSegment( -- 6123
				Vec2( -- 6123
					self:sx(z.x1, w), -- 6123
					self:sy(z.y, h) -- 6123
				), -- 6123
				Vec2( -- 6123
					self:sx(z.x1, w), -- 6123
					self:sy(z.y + z.h, h) -- 6123
				), -- 6123
				self:px(1), -- 6123
				line -- 6123
			) -- 6123
			i = i + 1 -- 6107
		end -- 6107
	end -- 6107
end -- 6105
function Play.prototype.drawArch(self, draw, w, h) -- 6127
	local a = self.room.arch -- 6128
	if a.h <= 0 then -- 6129
		return -- 6130
	end -- 6130
	self:drawBox( -- 6132
		draw, -- 6132
		w, -- 6132
		h, -- 6132
		a.x0, -- 6132
		a.x1, -- 6132
		a.y, -- 6132
		a.y + a.h, -- 6132
		HOLE_FILL -- 6132
	) -- 6132
	draw:drawSegment( -- 6133
		Vec2( -- 6133
			self:sx(a.x0, w), -- 6133
			self:sy(a.y + a.h, h) -- 6133
		), -- 6133
		Vec2( -- 6133
			self:sx(a.x1, w), -- 6133
			self:sy(a.y + a.h, h) -- 6133
		), -- 6133
		self:px(1), -- 6133
		SOLID_EDGE -- 6133
	) -- 6133
	draw:drawSegment( -- 6134
		Vec2( -- 6134
			self:sx(a.x0, w), -- 6134
			self:sy(a.y, h) -- 6134
		), -- 6134
		Vec2( -- 6134
			self:sx(a.x0, w), -- 6134
			self:sy(a.y + a.h, h) -- 6134
		), -- 6134
		self:px(1), -- 6134
		SOLID_EDGE -- 6134
	) -- 6134
	draw:drawSegment( -- 6135
		Vec2( -- 6135
			self:sx(a.x1, w), -- 6135
			self:sy(a.y, h) -- 6135
		), -- 6135
		Vec2( -- 6135
			self:sx(a.x1, w), -- 6135
			self:sy(a.y + a.h, h) -- 6135
		), -- 6135
		self:px(1), -- 6135
		SOLID_EDGE -- 6135
	) -- 6135
end -- 6127
function Play.prototype.drawCart(self, draw, w, h) -- 6138
	local c = self.room.cart -- 6139
	if c.bodyW <= 0 then -- 6140
		return -- 6141
	end -- 6141
	drawCartShape( -- 6143
		draw, -- 6143
		self, -- 6143
		w, -- 6143
		h, -- 6143
		c, -- 6143
		self.cartAxle -- 6143
	) -- 6143
	draw:drawRect( -- 6144
		Rect( -- 6144
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 6144
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 6144
			self:px(2), -- 6144
			self:px(40) -- 6144
		), -- 6144
		STAND -- 6144
	) -- 6144
end -- 6138
function Play.prototype.drawActors(self, draw, w, h) -- 6147
	local p = self.player -- 6148
	local isChild = self.childMode -- 6149
	local footY = p.y + p.depth * DEPTH_Y_SCALE -- 6150
	if p.covered then -- 6152
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 6153
		draw:drawSegment( -- 6154
			Vec2( -- 6154
				self:sx(edge, w), -- 6154
				self:sy(footY + 8, h) -- 6154
			), -- 6154
			Vec2( -- 6154
				self:sx(edge, w), -- 6154
				self:sy(footY + p.h * 0.62, h) -- 6154
			), -- 6154
			self:px(2), -- 6154
			STAND -- 6154
		) -- 6154
		draw:drawSegment( -- 6156
			Vec2( -- 6156
				self:sx(p.x - 8, w), -- 6156
				self:sy(footY + p.h + 3, h) -- 6156
			), -- 6156
			Vec2( -- 6156
				self:sx(p.x + 8, w), -- 6156
				self:sy(footY + p.h + 3, h) -- 6156
			), -- 6156
			self:px(2), -- 6156
			STAND -- 6156
		) -- 6156
	elseif self.coverNear and not isChild then -- 6157
		draw:drawRect( -- 6159
			Rect( -- 6159
				self:sx(p.x - 3, w), -- 6159
				self:sy(footY + 1, h), -- 6159
				self:px(3), -- 6159
				self:px(3) -- 6159
			), -- 6159
			STAND -- 6159
		) -- 6159
	end -- 6159
	drawFigure( -- 6161
		draw, -- 6161
		self, -- 6161
		w, -- 6161
		h, -- 6161
		p, -- 6161
		isChild and CHILD_BODY or SOLDIER_BODY, -- 6161
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 6161
	) -- 6161
	local q = self.partner -- 6162
	if q.alive then -- 6163
		local childPartner = q.w == CHILD_W -- 6164
		drawFigure( -- 6165
			draw, -- 6165
			self, -- 6165
			w, -- 6165
			h, -- 6165
			q, -- 6165
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 6165
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 6165
		) -- 6165
	end -- 6165
	local i = 0 -- 6167
	do -- 6167
		i = 0 -- 6168
		while i < #self.enemies do -- 6168
			local e = self.enemies[i + 1] -- 6169
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 6170
			local enemyY = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 6171
			self:drawBox( -- 6172
				draw, -- 6172
				w, -- 6172
				h, -- 6172
				e.x - e.w / 2, -- 6172
				e.x + e.w / 2, -- 6172
				enemyY, -- 6172
				enemyY + e.h, -- 6172
				col -- 6172
			) -- 6172
			if e.alive then -- 6173
				local ef = p.x >= e.x and 1 or -1 -- 6174
				if e.kind == "shield" then -- 6175
					local sh = (e.shieldHp or 0) > 0 -- 6176
					draw:drawRect( -- 6177
						Rect( -- 6177
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 6177
							self:sy(enemyY, h), -- 6177
							self:px(6), -- 6177
							self:px(64) -- 6177
						), -- 6177
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 6178
					) -- 6178
				elseif e.kind == "breaker" then -- 6179
					draw:drawSegment( -- 6180
						Vec2( -- 6180
							self:sx(e.x + ef * 12, w), -- 6180
							self:sy(enemyY + 8, h) -- 6180
						), -- 6180
						Vec2( -- 6181
							self:sx(e.x + ef * 22, w), -- 6181
							self:sy(enemyY + 46, h) -- 6181
						), -- 6181
						self:px(3), -- 6181
						Color(0.5, 0.36, 0.22, 1) -- 6181
					) -- 6181
				end -- 6181
			end -- 6181
			if e.alive and e.warnT > 0 then -- 6185
				local gunX = self:sx(e.x, w) -- 6186
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 6187
				local aimX = self:sx(p.x, w) -- 6188
				local aimY = self:sy(footY + p.h * 0.55, h) -- 6189
				local seg = 8 -- 6190
				local s = 0 -- 6191
				do -- 6191
					s = 0 -- 6192
					while s < seg do -- 6192
						local t0 = s / seg -- 6193
						local t1 = (s + 1) / seg -- 6194
						draw:drawSegment( -- 6195
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 6196
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 6197
							self:px(1), -- 6198
							DANGER -- 6198
						) -- 6198
						s = s + 2 -- 6192
					end -- 6192
				end -- 6192
			end -- 6192
			i = i + 1 -- 6168
		end -- 6168
	end -- 6168
	local k = 0 -- 6203
	do -- 6203
		k = 0 -- 6204
		while k < #self.room.marks do -- 6204
			do -- 6204
				local m = self.room.marks[k + 1] -- 6205
				if m.kind ~= 0 then -- 6206
					goto __continue1128 -- 6207
				end -- 6207
				local on = self.checkpoint == m.x -- 6209
				local x = self:sx(m.x, w) -- 6210
				local y = self:sy(m.y, h) -- 6211
				draw:drawSegment( -- 6212
					Vec2(x, y), -- 6212
					Vec2( -- 6212
						x, -- 6212
						y + self:px(35) -- 6212
					), -- 6212
					self:px(1), -- 6212
					on and CHECK or INK_DIM -- 6212
				) -- 6212
				draw:drawDot( -- 6213
					Vec2( -- 6213
						x, -- 6213
						y + self:px(35) -- 6213
					), -- 6213
					self:px(2), -- 6213
					on and CHECK or INK_DIM -- 6213
				) -- 6213
			end -- 6213
			::__continue1128:: -- 6213
			k = k + 1 -- 6204
		end -- 6204
	end -- 6204
	local j = 0 -- 6217
	do -- 6217
		j = 0 -- 6218
		while j < #self.room.marks do -- 6218
			do -- 6218
				local m = self.room.marks[j + 1] -- 6219
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 6220
					goto __continue1131 -- 6221
				end -- 6221
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 6223
					goto __continue1131 -- 6225
				end -- 6225
				local col = STAND -- 6227
				if m.kind == 4 then -- 6228
					col = PASS_LINE -- 6229
				elseif m.kind == 5 then -- 6230
					col = BRICK_LINE -- 6231
				end -- 6231
				local mx = self:sx(m.x, w) -- 6233
				local my = self:sy(m.y, h) -- 6234
				draw:drawSegment( -- 6235
					Vec2(mx, my), -- 6235
					Vec2( -- 6235
						mx, -- 6235
						my + self:px(24) -- 6235
					), -- 6235
					self:px(1), -- 6235
					col -- 6235
				) -- 6235
			end -- 6235
			::__continue1131:: -- 6235
			j = j + 1 -- 6218
		end -- 6218
	end -- 6218
	local t = 0 -- 6238
	do -- 6238
		t = 0 -- 6239
		while t < #self.room.marks do -- 6239
			do -- 6239
				local m = self.room.marks[t + 1] -- 6240
				if m.kind ~= 6 then -- 6241
					goto __continue1137 -- 6242
				end -- 6242
				local mx = self:sx(m.x, w) -- 6244
				local my = self:sy(m.y, h) -- 6245
				draw:drawSegment( -- 6246
					Vec2(mx, my), -- 6246
					Vec2( -- 6246
						mx, -- 6246
						my + self:px(30) -- 6246
					), -- 6246
					self:px(1), -- 6246
					INK_DIM -- 6246
				) -- 6246
				self:drawBox( -- 6247
					draw, -- 6247
					w, -- 6247
					h, -- 6247
					m.x - 5, -- 6247
					m.x + 5, -- 6247
					m.y + 30, -- 6247
					m.y + 40, -- 6247
					CHECK -- 6247
				) -- 6247
			end -- 6247
			::__continue1137:: -- 6247
			t = t + 1 -- 6239
		end -- 6239
	end -- 6239
	if self.room.key == "village" then -- 6249
		self:drawVillage(draw, w, h) -- 6250
	end -- 6250
	if self.room.key == "forest" then -- 6252
		self:drawDog(draw, w, h) -- 6253
	end -- 6253
end -- 6147
function Play.prototype.drawDog(self, draw, w, h) -- 6258
	local x = self.dogX -- 6259
	self:drawBox( -- 6260
		draw, -- 6260
		w, -- 6260
		h, -- 6260
		x - 14, -- 6260
		x + 14, -- 6260
		0, -- 6260
		20, -- 6260
		SCAV_BODY -- 6260
	) -- 6260
	self:drawBox( -- 6261
		draw, -- 6261
		w, -- 6261
		h, -- 6261
		x - 10, -- 6261
		x - 2, -- 6261
		20, -- 6261
		30, -- 6261
		SCAV_BODY -- 6261
	) -- 6261
	self:drawBox( -- 6262
		draw, -- 6262
		w, -- 6262
		h, -- 6262
		x + 2, -- 6262
		x + 10, -- 6262
		20, -- 6262
		30, -- 6262
		SCAV_HEAD -- 6262
	) -- 6262
	if self.dogState == "ear" or self.dogState == "chase" then -- 6263
		draw:drawSegment( -- 6264
			Vec2( -- 6264
				self:sx(x, w), -- 6264
				self:sy(30, h) -- 6264
			), -- 6264
			Vec2( -- 6265
				self:sx(x, w), -- 6265
				self:sy(40, h) -- 6265
			), -- 6265
			self:px(1), -- 6265
			DANGER -- 6265
		) -- 6265
	end -- 6265
end -- 6258
function Play.prototype.drawVillage(self, draw, w, h) -- 6270
	local bottle = self.room.bottle -- 6271
	if bottle ~= nil then -- 6272
		self:drawBox( -- 6273
			draw, -- 6273
			w, -- 6273
			h, -- 6273
			bottle.x - 14, -- 6273
			bottle.x + 14, -- 6273
			0, -- 6273
			64, -- 6273
			SOLID_FILL -- 6273
		) -- 6273
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 6274
			self:drawBottle( -- 6275
				draw, -- 6275
				w, -- 6275
				h, -- 6275
				bottle.x, -- 6275
				64 -- 6275
			) -- 6275
		end -- 6275
	end -- 6275
	self:drawBox( -- 6279
		draw, -- 6279
		w, -- 6279
		h, -- 6279
		300, -- 6279
		420, -- 6279
		44, -- 6279
		50, -- 6279
		FLOOR_DECK -- 6279
	) -- 6279
	self:drawBox( -- 6280
		draw, -- 6280
		w, -- 6280
		h, -- 6280
		300, -- 6280
		306, -- 6280
		0, -- 6280
		44, -- 6280
		FLOOR_DECK -- 6280
	) -- 6280
	self:drawBox( -- 6281
		draw, -- 6281
		w, -- 6281
		h, -- 6281
		414, -- 6281
		420, -- 6281
		0, -- 6281
		44, -- 6281
		FLOOR_DECK -- 6281
	) -- 6281
	local s = self.room.scavenger -- 6283
	if s ~= nil then -- 6284
		local sx0 = self.scavX -- 6285
		self:drawBox( -- 6286
			draw, -- 6286
			w, -- 6286
			h, -- 6286
			sx0 - 12, -- 6286
			sx0 + 12, -- 6286
			0, -- 6286
			s.h - 14, -- 6286
			SCAV_BODY -- 6286
		) -- 6286
		self:drawBox( -- 6287
			draw, -- 6287
			w, -- 6287
			h, -- 6287
			sx0 - 7, -- 6287
			sx0 + 7, -- 6287
			s.h - 14, -- 6287
			s.h, -- 6287
			SCAV_HEAD -- 6287
		) -- 6287
		if self.scavState == "turn" then -- 6288
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 6289
			draw:drawSegment( -- 6290
				Vec2( -- 6290
					self:sx(sx0, w), -- 6290
					self:sy(s.h - 6, h) -- 6290
				), -- 6290
				Vec2( -- 6290
					self:sx(fx, w), -- 6290
					self:sy(s.h - 6, h) -- 6290
				), -- 6290
				self:px(1), -- 6290
				INK -- 6290
			) -- 6290
		end -- 6290
	end -- 6290
	if self.hasBottle then -- 6294
		local p = self.player -- 6295
		self:drawBottle( -- 6296
			draw, -- 6296
			w, -- 6296
			h, -- 6296
			p.x + p.facing * 10, -- 6296
			p.y + p.h * 0.62 -- 6296
		) -- 6296
	end -- 6296
	if self.bottleFly ~= nil then -- 6298
		self:drawBottle( -- 6299
			draw, -- 6299
			w, -- 6299
			h, -- 6299
			self.bottleFly.x, -- 6299
			self.bottleFly.y -- 6299
		) -- 6299
	end -- 6299
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 6301
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 6302
		draw:drawCircle( -- 6303
			Vec2( -- 6303
				self:sx(self.bottleLandX, w), -- 6303
				self:sy(0, h) -- 6303
			), -- 6303
			self:px(r / ____exports.UNITS_PER_PX), -- 6303
			BRICK_LINE -- 6303
		) -- 6303
	end -- 6303
end -- 6270
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 6307
	self:drawBox( -- 6308
		draw, -- 6308
		w, -- 6308
		h, -- 6308
		x - 3, -- 6308
		x + 3, -- 6308
		y - 10, -- 6308
		y, -- 6308
		BOTTLE -- 6308
	) -- 6308
end -- 6307
function Play.prototype.drawTrace(self, draw, w, h) -- 6311
	local t = self.trace -- 6312
	if t == nil or self.traceT <= 0 then -- 6313
		return -- 6314
	end -- 6314
	draw:drawSegment( -- 6316
		Vec2( -- 6317
			self:sx(t.x0, w), -- 6317
			self:sy(t.y0, h) -- 6317
		), -- 6317
		Vec2( -- 6318
			self:sx(t.x1, w), -- 6318
			self:sy(t.y1, h) -- 6318
		), -- 6318
		self:px(1), -- 6319
		t.hit and AIM_HIT or INK_DIM -- 6319
	) -- 6319
end -- 6311
function Play.prototype.drawAim(self, draw, w, h) -- 6322
	local v = self.view -- 6324
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 6325
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 6326
	local dot = self:px(1) -- 6327
	local arm = self:px(3) -- 6328
	local gap = self:px(1) -- 6329
	draw:drawSegment( -- 6330
		Vec2(gx - arm - gap, gy), -- 6330
		Vec2(gx - gap, gy), -- 6330
		dot / 2, -- 6330
		AIM -- 6330
	) -- 6330
	draw:drawSegment( -- 6331
		Vec2(gx + gap, gy), -- 6331
		Vec2(gx + arm + gap, gy), -- 6331
		dot / 2, -- 6331
		AIM -- 6331
	) -- 6331
	draw:drawSegment( -- 6332
		Vec2(gx, gy - arm - gap), -- 6332
		Vec2(gx, gy - gap), -- 6332
		dot / 2, -- 6332
		AIM -- 6332
	) -- 6332
	draw:drawSegment( -- 6333
		Vec2(gx, gy + gap), -- 6333
		Vec2(gx, gy + arm + gap), -- 6333
		dot / 2, -- 6333
		AIM -- 6333
	) -- 6333
	if self.room.key == "village" and self.hasBottle then -- 6336
		local p = self.player -- 6337
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 6339
		local dir = ____end.x >= p.x and 1 or -1 -- 6340
		local x0 = p.x + dir * 10 -- 6341
		local y0 = p.y + p.h * 0.7 -- 6342
		local T = BOTTLE_FLY_TIME -- 6343
		local vx = (____end.x - x0) / T -- 6344
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 6345
		local pxr = x0 -- 6346
		local pyr = y0 -- 6347
		local t = 1 -- 6348
		do -- 6348
			t = 1 -- 6349
			while t <= 12 do -- 6349
				local tt = t / 12 * T -- 6350
				local nx = x0 + vx * tt -- 6351
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 6352
				draw:drawSegment( -- 6353
					Vec2( -- 6353
						self:sx(pxr, w), -- 6353
						self:sy(pyr, h) -- 6353
					), -- 6353
					Vec2( -- 6353
						self:sx(nx, w), -- 6353
						self:sy(ny, h) -- 6353
					), -- 6353
					self:px(1) / 2, -- 6353
					BOTTLE -- 6353
				) -- 6353
				pxr = nx -- 6354
				pyr = ny -- 6355
				t = t + 1 -- 6349
			end -- 6349
		end -- 6349
		draw:drawCircle( -- 6357
			Vec2( -- 6357
				self:sx(____end.x, w), -- 6357
				self:sy(____end.y + 2, h) -- 6357
			), -- 6357
			self:px(2), -- 6357
			BOTTLE -- 6357
		) -- 6357
	end -- 6357
end -- 6322
return ____exports -- 6322
