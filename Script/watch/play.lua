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
function makeActor(room, index) -- 6363
	local sp = room.spawns -- 6364
	if index < 0 or index >= #sp then -- 6364
		return { -- 6366
			x = 0, -- 6366
			y = 0, -- 6366
			depth = 0, -- 6366
			depthSpeed = 0, -- 6366
			vx = 0, -- 6366
			vy = 0, -- 6366
			w = CHILD_W, -- 6366
			h = CHILD_H, -- 6366
			onGround = true, -- 6366
			facing = 1, -- 6366
			crouch = false, -- 6366
			rollT = 0, -- 6366
			covered = false, -- 6366
			alive = false -- 6366
		} -- 6366
	end -- 6366
	local s = sp[index + 1] -- 6368
	local child = s.h < SOLDIER_H -- 6369
	local ground = room.depth -- 6370
	local depth = ground == nil and 0 or math.max( -- 6371
		ground.min, -- 6371
		math.min(ground.max, s.depth or 0) -- 6371
	) -- 6371
	return { -- 6372
		x = s.x, -- 6373
		y = s.y, -- 6373
		depth = depth, -- 6373
		depthSpeed = 0, -- 6373
		vx = 0, -- 6373
		vy = 0, -- 6373
		w = child and CHILD_W or SOLDIER_W, -- 6374
		h = child and CHILD_H or SOLDIER_H, -- 6375
		onGround = true, -- 6376
		facing = 1, -- 6376
		crouch = false, -- 6376
		rollT = 0, -- 6376
		covered = false, -- 6376
		alive = true -- 6376
	} -- 6376
end -- 6376
function drawFigure(draw, play, w, h, a, body, head) -- 6380
	if not a.alive then -- 6380
		return -- 6382
	end -- 6382
	local x0 = a.x - a.w / 2 -- 6384
	local x1 = a.x + a.w / 2 -- 6385
	local y0 = a.y + a.depth * DEPTH_Y_SCALE -- 6386
	local y1 = y0 + a.h -- 6387
	play:drawBox( -- 6388
		draw, -- 6388
		w, -- 6388
		h, -- 6388
		x0, -- 6388
		x1, -- 6388
		y0, -- 6388
		y1 - a.h * 0.26, -- 6388
		body -- 6388
	) -- 6388
	play:drawBox( -- 6389
		draw, -- 6389
		w, -- 6389
		h, -- 6389
		x0 + 2, -- 6389
		x1 - 2, -- 6389
		y1 - a.h * 0.26, -- 6389
		y1, -- 6389
		head -- 6389
	) -- 6389
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 6391
	play:drawBox( -- 6392
		draw, -- 6392
		w, -- 6392
		h, -- 6392
		eyeX, -- 6392
		eyeX + 4, -- 6392
		y1 - a.h * 0.14, -- 6392
		y1 - a.h * 0.08, -- 6392
		INK -- 6392
	) -- 6392
end -- 6392
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 6396
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 6397
end -- 6396
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 6404
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 6405
end -- 6404
function rayInterval(origin, direction, min, max) -- 6412
	if direction == 0 then -- 6412
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 6414
	end -- 6414
	local a = (min - origin) / direction -- 6416
	local b = (max - origin) / direction -- 6417
	return { -- 6418
		min = math.min(a, b), -- 6418
		max = math.max(a, b) -- 6418
	} -- 6418
end -- 6418
function hitBox(ray, box) -- 6422
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 6423
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 6424
	local enter = math.max(0, x.min, y.min) -- 6425
	local leave = math.min(99999, x.max, y.max) -- 6426
	if box.depth ~= nil then -- 6426
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 6428
		enter = math.max(enter, depth.min) -- 6429
		leave = math.min(leave, depth.max) -- 6430
	end -- 6430
	return leave >= enter and enter or -1 -- 6432
end -- 6432
function drawCartShape(draw, play, w, h, c, axleX) -- 6435
	local half = c.bodyW / 2 -- 6436
	local x0 = axleX - half -- 6437
	local x1 = axleX + half -- 6438
	local axleY = c.baseY + (c.depth or 0) * DEPTH_Y_SCALE + c.wheelR -- 6439
	play:drawBox( -- 6440
		draw, -- 6440
		w, -- 6440
		h, -- 6440
		x0, -- 6440
		x1, -- 6440
		axleY, -- 6440
		axleY + c.bodyH, -- 6440
		CART_FILL -- 6440
	) -- 6440
	draw:drawCircle( -- 6441
		Vec2( -- 6441
			play:sx(x0 + c.bodyW * 0.28, w), -- 6441
			play:sy(axleY, h) -- 6441
		), -- 6441
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6441
		Color(52, 50, 48, 255) -- 6441
	) -- 6441
	draw:drawCircle( -- 6442
		Vec2( -- 6442
			play:sx(x1 - c.bodyW * 0.28, w), -- 6442
			play:sy(axleY, h) -- 6442
		), -- 6442
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6442
		Color(52, 50, 48, 255) -- 6442
	) -- 6442
	local cx = c.clothSide < 0 and x0 or x1 -- 6443
	play:drawBox( -- 6444
		draw, -- 6444
		w, -- 6444
		h, -- 6444
		cx - 10, -- 6444
		cx + 10, -- 6444
		axleY + c.bodyH, -- 6444
		axleY + c.bodyH + 18, -- 6444
		CLOTH -- 6444
	) -- 6444
end -- 6444
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
	local ____table_childMode_89 -- 2045
	if self.childMode then -- 2045
		____table_childMode_89 = math.abs(a.depth - (c.depth or 0)) <= 48 -- 2046
	else -- 2046
		____table_childMode_89 = inReachDepth(a.depth, c.depth or 0) -- 2047
	end -- 2047
	local depthOk = ____table_childMode_89 -- 2045
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and depthOk -- 2048
end -- 2039
function Play.prototype.nearLowLedge(self, a) -- 2053
	local reach = 26 -- 2054
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 2055
	local x1 = x0 + reach -- 2056
	local i = 0 -- 2057
	do -- 2057
		i = 0 -- 2058
		while i < #self.boxes do -- 2058
			do -- 2058
				local b = self.boxes[i + 1] -- 2059
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2059
					goto __continue266 -- 2061
				end -- 2061
				local rise = b.y1 - a.y -- 2063
				if rise > 0 and rise <= LEDGE_RISE then -- 2063
					return true -- 2065
				end -- 2065
			end -- 2065
			::__continue266:: -- 2065
			i = i + 1 -- 2058
		end -- 2058
	end -- 2058
	return false -- 2068
end -- 2053
function Play.prototype.stepPlayer(self, a, dt, input) -- 2071
	a.depthSpeed = 0 -- 2072
	if not a.alive then -- 2072
		return -- 2074
	end -- 2074
	local isChild = self.childMode -- 2076
	local lowArch = isChild and self:underLowArch(a) -- 2078
	if self:storyLocked() then -- 2078
		a.vx = 0 -- 2081
		a.crouch = isChild and lowArch -- 2082
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2083
		self:fallY(a, dt) -- 2084
		return -- 2085
	end -- 2085
	if not isChild and self.escort.state == "calming" then -- 2085
		a.crouch = false -- 2089
		a.h = SOLDIER_H -- 2090
		a.vx = 0 -- 2091
		self:fallY(a, dt) -- 2092
		return -- 2093
	end -- 2093
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 2095
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 2096
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2097
	local nearCover = not isChild and self:nearCover(a) -- 2098
	a.covered = nearCover and input.cover.held -- 2099
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 2101
	if a.rollT > 0 then -- 2101
		a.rollT = a.rollT - dt -- 2105
		local rollSpd = self:isEscortRoom() and ROLL_SPEED * (1 + 0.08 * self:talentRank("stride")) or ROLL_SPEED -- 2106
		a.vx = a.facing * rollSpd -- 2107
		self:slideX(a, a.vx * dt) -- 2108
		self:fallY(a, dt) -- 2109
		if a.rollT <= 0 then -- 2109
			self:flashSet("翻滚结束", 0.5) -- 2111
		end -- 2111
		return -- 2113
	end -- 2113
	local peacefulRoom = self.room.key == "museum" or self.room.key == "tower" -- 2116
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 2116
		if input.moveX ~= 0 then -- 2116
			a.facing = input.moveX > 0 and 1 or -1 -- 2119
		end -- 2119
		if self:nearLowLedge(a) then -- 2119
			a.vy = SOLDIER_JUMP -- 2123
			a.onGround = false -- 2124
			self:flashSet("翻上去", 0.3) -- 2125
			return -- 2126
		end -- 2126
		a.rollT = ROLL_TIME -- 2128
		self:flashSet("翻滚", 0.3) -- 2129
		return -- 2130
	end -- 2130
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 2133
	if isChild then -- 2133
		if input.cover.held then -- 2133
			speed = CHILD_SLOW -- 2136
		end -- 2136
		if a.crouch then -- 2136
			speed = CHILD_SLOW -- 2139
		elseif self.room.key == "forest" and self.forestPath == "ditch" and a.x >= self.ox + 700 and a.x <= self.ox + 1140 then -- 2139
			speed = CHILD_SPEED * 1.22 -- 2143
		end -- 2143
	else -- 2143
		if self:isEscortRoom() then -- 2143
			speed = speed * (1 + 0.1 * self:talentRank("stride")) -- 2147
		end -- 2147
		if a.covered then -- 2147
			speed = speed * 0.45 -- 2150
		end -- 2150
	end -- 2150
	local handsBusy = self.gripping or gripIntent or self.reloadOpen -- 2155
	local dir = (self.gripping or self.reloadOpen) and 0 or input.moveX -- 2156
	local depthDir = self.room.depth ~= nil and not handsBusy and -input.moveY or 0 -- 2158
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 2159
	if dir ~= 0 then -- 2159
		a.facing = dir > 0 and 1 or -1 -- 2161
	end -- 2161
	a.vx = dir * speed * diagonal -- 2163
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 2163
		a.vy = CHILD_JUMP -- 2167
		a.onGround = false -- 2168
		self:flashSet("跳", 0.25) -- 2169
	end -- 2169
	local previousDepth = a.depth -- 2173
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 2174
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2175
	self:slideX(a, a.vx * dt) -- 2176
	self:fallY(a, dt) -- 2177
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and not self.reloadOpen and input.fire.pressed then -- 2177
		self:shoot(a) -- 2181
	end -- 2181
	local ____temp_92 = not isChild and not peacefulRoom and not self.gripping and not self.reloadOpen and self.reloadPendingEffect == "" -- 2184
	if ____temp_92 then -- 2184
		local ____opt_90 = self.room.campaign -- 2184
		____temp_92 = (____opt_90 and ____opt_90.reloadPuzzle) == true -- 2184
	end -- 2184
	if ____temp_92 and input.flare.pressed then -- 2184
		self:beginReload() -- 2186
	end -- 2186
end -- 2071
function Play.prototype.stepPartner(self, p, dt) -- 2191
	local a = self.partner -- 2192
	if not a.alive then -- 2192
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
	if not a.alive then -- 2209
		return -- 2211
	end -- 2211
	if self.room.key == "gatepath" then -- 2211
		if self.carryOn then -- 2211
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
	if not self:escortOn() then -- 2229
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
	if not hadKnock1 and self.escort.knock1 then -- 2240
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 2243
	end -- 2243
	if not hadKnock2 and self.escort.knock2 then -- 2243
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 2246
	end -- 2246
	a.crouch = self.escort.crouchPose -- 2248
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 2249
	if not self.escort.stopped then -- 2249
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 2251
		local previousDepth = a.depth -- 2252
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 2253
		local distance = math.max( -- 2254
			-travel, -- 2254
			math.min(travel, targetDepth - previousDepth) -- 2254
		) -- 2254
		self:slideDepth(a, distance) -- 2255
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2256
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 2256
			a.vy = CHILD_JUMP -- 2258
			a.onGround = false -- 2259
		end -- 2259
	end -- 2259
	local dir = self.escort:moveDir(a.x) -- 2262
	a.vx = dir * CHILD_SPEED -- 2263
	if dir ~= 0 then -- 2263
		a.facing = dir -- 2265
		local before = a.x -- 2266
		self:slideX(a, dir * CHILD_SPEED * dt) -- 2267
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 2267
			a.vy = CHILD_JUMP -- 2270
			a.onGround = false -- 2271
		end -- 2271
	end -- 2271
	self:fallY(a, dt) -- 2274
end -- 2207
function Play.prototype.escortOn(self) -- 2278
	if self.room.key == "checkpoint" then -- 2278
		return true -- 2280
	end -- 2280
	if self.room.key == "gatepath" then -- 2280
		return true -- 2283
	end -- 2283
	if self.room.key == "prologue" then -- 2283
		return self.phase == "prologue-follow" -- 2286
	end -- 2286
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 2286
		return true -- 2290
	end -- 2290
	return self.room.key == "street" -- 2292
end -- 2278
function Play.prototype.storyLocked(self) -- 2296
	if self.caughtT > 0 then -- 2296
		return true -- 2298
	end -- 2298
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 2298
		return true -- 2302
	end -- 2302
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 2302
		return true -- 2305
	end -- 2305
	if self.room.key == "gate" and (self.phase == "gate-farewell" or self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 2305
		return true -- 2308
	end -- 2308
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2308
		return true -- 2311
	end -- 2311
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2311
		return true -- 2314
	end -- 2314
	if self.craftBench.active then -- 2314
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
	if self.room.key == "prologue" then -- 2375
		self:stepPrologue(dt, input) -- 2377
	elseif self.room.key == "street" then -- 2377
		self:stepStreet(dt, input) -- 2379
	elseif self.room.key == "gate" then -- 2379
		self:stepGate(dt, input) -- 2381
	elseif self.room.key == "gatepath" then -- 2381
		self:stepGatePath() -- 2383
	elseif self.room.key == "tower" then -- 2383
		self:stepTower(dt, input) -- 2385
	elseif self.room.key == "museum" then -- 2385
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
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2413
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
	if self.museumReturn then -- 2426
		self.museumReturn = false -- 2429
		self.phase = "prologue-wait" -- 2430
		self.phaseTick = 0 -- 2431
		self.player.x = self.ox + 260 -- 2432
		self.player.y = 0 -- 2433
		self.player.depth = 0 -- 2434
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2435
	end -- 2435
	if self.phase == "prologue-wake" then -- 2435
		self.introTick = self.introTick + 1 -- 2439
		if self.introTick == 60 then -- 2439
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2441
		end -- 2441
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2441
			self.phase = "prologue-shadow" -- 2444
			self.introTick = 0 -- 2445
			self:flashSet("门缝里两道影子", 1.2) -- 2446
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2447
		end -- 2447
		return -- 2449
	end -- 2449
	if self.phase == "prologue-shadow" then -- 2449
		self.introTick = self.introTick + 1 -- 2452
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2452
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
	if self.phase == "prologue-escape" then -- 2465
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2468
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2468
			self.phase = "prologue-hide" -- 2471
			self.introTick = 0 -- 2472
			self.player.vx = 0 -- 2473
			self.player.crouch = true -- 2474
			self.player.h = CHILD_CROUCH_H -- 2475
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2476
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2477
			return -- 2481
		end -- 2481
		if self.escapeRemaining <= 0 then -- 2481
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
	if self.phase == "prologue-hide" then -- 2496
		self.introTick = self.introTick + 1 -- 2499
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2499
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
	if self.phase == "prologue-wait" then -- 2512
		child.crouch = true -- 2514
		child.h = CHILD_CROUCH_H -- 2515
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2515
			self:pickWell() -- 2517
			return -- 2518
		end -- 2518
		if not self.wellOpen and self:canPersistProgress() and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2518
			self.archive.museumPhase = "well_reflect" -- 2523
			self.archiveDirty = true -- 2524
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2525
			return -- 2526
		end -- 2526
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2528
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2530
		if near and input.interact.pressed then -- 2530
			self.phase = "prologue-give" -- 2532
			self.phaseTick = 0 -- 2533
			self:flashSet("递出针套", 1) -- 2534
		end -- 2534
		return -- 2536
	end -- 2536
	if self.phase == "prologue-well" then -- 2536
		self.phaseTick = self.phaseTick + 1 -- 2540
		if self.phaseTick == 12 then -- 2540
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2542
		elseif self.phaseTick >= 30 then -- 2542
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
	if self.phase == "prologue-give" then -- 2557
		self.phaseTick = self.phaseTick + 1 -- 2560
		if self.phaseTick == 36 then -- 2560
			self:flashSet("针套递过去", 0.9) -- 2562
		elseif self.phaseTick == 108 then -- 2562
			self:flashSet("纸条塞进针套", 1) -- 2564
		elseif self.phaseTick >= ____exports.PROLOGUE_GIVE_TICKS then -- 2564
			self.phase = "prologue-follow" -- 2566
			self.phaseTick = 0 -- 2567
			child.crouch = false -- 2568
			child.h = CHILD_H -- 2569
			self:flashSet("她跟上了", 1.2) -- 2570
		end -- 2570
		return -- 2572
	end -- 2572
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2572
		local next = self.run.source == "debug" and "street" or "s1-crossroad" -- 2576
		self:requestRoom(next, "序章跟到门口") -- 2577
		self:flashSet(next == "s1-crossroad" and "进十字街" or "进街道", 1.2) -- 2578
	end -- 2578
end -- 2425
function Play.prototype.stepStreet(self, dt, input) -- 2583
	local p = self.player -- 2584
	local c = self.partner -- 2585
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2585
		local next = self.run.source == "debug" and "checkpoint" or "s1-crossroad" -- 2587
		self:requestRoom(next, "两人都到街尾") -- 2588
		self:flashSet(next == "s1-crossroad" and "进十字街" or "到检查站", 1.2) -- 2589
	end -- 2589
end -- 2583
function Play.prototype.stepGate(self, dt, input) -- 2594
	local ____temp_93 -- 2595
	if self.room.story == nil then -- 2595
		____temp_93 = nil -- 2595
	else -- 2595
		____temp_93 = self.room.story.gate -- 2595
	end -- 2595
	local g = ____temp_93 -- 2595
	if g == nil then -- 2595
		return -- 2597
	end -- 2597
	local p = self.player -- 2599
	if self.phase == "gate-idle" then -- 2599
		local a = self.partner -- 2602
		local gap = g.waitX - a.x -- 2603
		if math.abs(gap) > 3 then -- 2603
			a.facing = gap > 0 and 1 or -1 -- 2605
			a.vx = a.facing * CHILD_SPEED -- 2606
			local beforeX = a.x -- 2607
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2608
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2608
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
		if self.gateNeedConfirm then -- 2620
			if not input.interact.held then -- 2620
				self.gateRestartArmed = true -- 2625
			end -- 2625
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2625
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
		if atWinch and atWait then -- 2636
			self.phase = "gate-hold" -- 2639
			self.gateTick = 0 -- 2640
			self.gateSpawned = 0 -- 2641
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2642
		end -- 2642
		return -- 2644
	end -- 2644
	if self.phase == "gate-hold" then -- 2644
		self.gateTick = self.gateTick + 1 -- 2647
		local marks = {0, 540, 900, 1500} -- 2649
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2649
			local idx = self.gateSpawned -- 2651
			local ____self_enemies_94 = self.enemies -- 2651
			____self_enemies_94[#____self_enemies_94 + 1] = { -- 2652
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
		if self.gateTick == 900 then -- 2657
			self:flashSet("棚布落下", 1) -- 2660
		elseif self.gateTick == 2100 then -- 2660
			self:flashSet("门底透进冷光了", 1) -- 2662
		end -- 2662
		if self.gateTick >= g.holdTicks then -- 2662
			self:captureGateBlood() -- 2667
			self.phase = "gate-send" -- 2668
			self.phaseTick = 0 -- 2669
			self.enemies = {} -- 2671
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2672
		end -- 2672
		return -- 2674
	end -- 2674
	if self.phase == "gate-send" then -- 2674
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2677
		if near and input.interact.pressed then -- 2677
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
	if self.phase == "gate-farewell" then -- 2691
		self.phaseTick = self.phaseTick + 1 -- 2694
		self.countPrevMove = input.moveX -- 2695
		if self.phaseTick >= ____exports.GATE_FAREWELL_TICKS then -- 2695
			self.phase = "gate-count" -- 2697
			self.phaseTick = 0 -- 2698
			self.countTick = 0 -- 2699
			self.countArmed = false -- 2700
		end -- 2700
		return -- 2702
	end -- 2702
	if self.phase == "gate-count" then -- 2702
		self.countTick = self.countTick + 1 -- 2705
		if self.countTick == 360 then -- 2705
			self:flashSet("门关上", 0.9) -- 2707
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2707
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2709
			if self.storyRoute == "soldier" then -- 2709
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
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2729
			if prevMove <= 0 and input.moveX > 0 then -- 2729
				self.countArmed = true -- 2732
			end -- 2732
			if self.countArmed and input.moveX > 0 then -- 2732
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
	if self.phase == "gate-wait" then -- 2741
		self.phaseTick = self.phaseTick + 1 -- 2745
		if self.phaseTick == 12 then -- 2745
			self.knocks = 2 -- 2747
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2748
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2749
		end -- 2749
		local held = input.interact.held or self.intentGateReunionHold -- 2751
		if not held then -- 2751
			if self.handTicks > 0 then -- 2751
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2754
			end -- 2754
			self.handTicks = 0 -- 2756
			self.handArmed = true -- 2757
			return -- 2758
		end -- 2758
		if self.handArmed then -- 2758
			self.handTicks = self.handTicks + 1 -- 2761
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2761
				self.intentGateReunionHold = false -- 2763
				self.phase = "gate-hand" -- 2764
				self.phaseTick = 0 -- 2765
				self.handDone = true -- 2766
				self.tied = true -- 2767
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2768
				if not self.lineSaid then -- 2768
					self.lineSaid = true -- 2770
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2771
				end -- 2771
				self:flashSet("我们走吧。", 3) -- 2773
			end -- 2773
		end -- 2773
		return -- 2776
	end -- 2776
	if self.phase == "gate-hand" then -- 2776
		self.phaseTick = self.phaseTick + 1 -- 2780
		if self.phaseTick == 30 then -- 2780
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2782
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2782
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
	if self.phase == "gate-walk" then -- 2787
		if self.player.x >= g.exitX then -- 2787
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
	if self.storySettled then -- 2811
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
	if s == nil then -- 2831
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
	if self.room.key == "gate" then -- 2849
		s.phase = self.phase -- 2851
		s.countTick = self.countTick -- 2852
		s.phaseTick = self.phaseTick -- 2853
		s.handTicks = self.handTicks -- 2854
	end -- 2854
	if self.room.key == "prologue" then -- 2854
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2854
			s.phase = self.phase -- 2859
			s.phaseTick = self.phaseTick -- 2860
		end -- 2860
	end -- 2860
	if self.room.key == "tower" then -- 2860
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2860
			s.phase = self.phase -- 2866
			s.phaseTick = self.phaseTick -- 2867
		end -- 2867
	end -- 2867
end -- 2830
function Play.prototype.stepGatePath(self) -- 2873
	local ____temp_95 -- 2874
	if self.room.story == nil then -- 2874
		____temp_95 = nil -- 2874
	else -- 2874
		____temp_95 = self.room.story.gatepath -- 2874
	end -- 2874
	local gp = ____temp_95 -- 2874
	if self.phase == "gatepath-start" then -- 2874
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2874
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
	if self.phase == "gatepath-carry" then -- 2886
		self.phaseTick = self.phaseTick + 1 -- 2889
		if self.phaseTick == 20 then -- 2889
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2891
		end -- 2891
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2891
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
	if self.phase == "museum-cabinet" then -- 2933
		if atCase and interactHit or intentTarget == "cabinet" then -- 2933
			self.phase = "museum-hall" -- 2936
			self.phaseTick = 0 -- 2937
			if self:canPersistProgress() then -- 2937
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
	if self.phase == "museum-hall" then -- 2945
		if intentTarget == "lamp_direct" and nearLamp then -- 2945
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
			if self:canPersistProgress() then -- 2951
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
		if self.player.x >= self.ox + mu.hallX and interactHit then -- 2958
			self.phase = "museum-lamp" -- 2961
			self.phaseTick = 0 -- 2962
			if self:canPersistProgress() then -- 2962
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
	if self.phase == "museum-lamp" then -- 2970
		if nearLamp and interactHit then -- 2970
			self.phase = "museum-return" -- 2974
			self.phaseTick = 0 -- 2975
			if self:canPersistProgress() then -- 2975
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
	if self.phase == "museum-return" then -- 2983
		if atCase and interactHit or intentTarget == "return_cabinet" then -- 2983
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
	if self.phase == "museum-knock" then -- 2992
		self.phaseTick = self.phaseTick + 1 -- 2995
		if self.phaseTick == 8 then -- 2995
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
		elseif self.phaseTick >= 36 then -- 2998
			self.phase = "museum-done" -- 3000
			self.phaseTick = 0 -- 3001
			if self:canPersistProgress() then -- 3001
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
	if interactHit then -- 3011
		self.museumReturn = true -- 3014
		self:requestRoom("prologue", "回柜边") -- 3015
	end -- 3015
end -- 2924
function Play.prototype.openTowerDoor(self) -- 3019
	self.towerDoorOpen = true -- 3020
	do -- 3020
		local i = 0 -- 3021
		while i < #self.boxes do -- 3021
			if self.boxes[i + 1].id == "tower_door" then -- 3021
				self.boxes[i + 1].hidden = true -- 3023
			end -- 3023
			i = i + 1 -- 3021
		end -- 3021
	end -- 3021
	self.run.story.segments.tower_door = true -- 3026
end -- 3019
function Play.prototype.stepTower(self, dt, input) -- 3029
	local ____temp_96 -- 3030
	if self.room.story == nil then -- 3030
		____temp_96 = nil -- 3030
	else -- 3030
		____temp_96 = self.room.story.tower -- 3030
	end -- 3030
	local t = ____temp_96 -- 3030
	if t == nil then -- 3030
		return -- 3032
	end -- 3032
	if self.storyRoute == "soldier" and self.partner.alive then -- 3032
		local targetX = math.max(self.ox + 408, self.player.x - 28) -- 3036
		local gap = targetX - self.partner.x -- 3037
		if math.abs(gap) > 2 then -- 3037
			local dir = gap > 0 and 1 or -1 -- 3039
			local stepDist = math.min( -- 3040
				math.abs(gap), -- 3040
				SOLDIER_SPEED * dt -- 3040
			) -- 3040
			self.partner.facing = dir -- 3041
			self.partner.vx = dir * SOLDIER_SPEED -- 3042
			local ____self_partner_97, ____x_98 = self.partner, "x" -- 3042
			____self_partner_97[____x_98] = ____self_partner_97[____x_98] + dir * stepDist -- 3043
		else -- 3043
			self.partner.vx = 0 -- 3045
			self.partner.facing = 1 -- 3046
		end -- 3046
	end -- 3046
	if self.phase == "tower-wait" then -- 3046
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 3050
		if near and input.interact.pressed then -- 3050
			self.phase = "tower-knock" -- 3052
			self.phaseTick = 0 -- 3053
			self.knocks = 1 -- 3054
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 3055
			self:flashSet("叩两下 · 第一声", 0.6) -- 3056
		end -- 3056
		return -- 3058
	end -- 3058
	if self.phase == "tower-knock" then -- 3058
		self.phaseTick = self.phaseTick + 1 -- 3061
		if self.phaseTick == 12 then -- 3061
			self.knocks = 2 -- 3063
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 3064
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 3065
		elseif self.phaseTick >= t.knockTicks then -- 3065
			self:openTowerDoor() -- 3067
			self.phase = "tower-enter" -- 3068
			self.phaseTick = 0 -- 3069
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 3070
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 3071
		end -- 3071
		return -- 3073
	end -- 3073
	if self.phase == "tower-enter" then -- 3073
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 3073
			self.phase = "tower-desk" -- 3077
			self.phaseTick = 0 -- 3078
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 3079
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 3080
		end -- 3080
		return -- 3082
	end -- 3082
	if self.phase == "tower-desk" then -- 3082
		local deskX = self.ox + 605 -- 3085
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 3086
		if not near or not input.interact.held then -- 3086
			self.deskHold = 0 -- 3088
			return -- 3089
		end -- 3089
		self.deskHold = self.deskHold + 1 -- 3091
		if self.deskHold == 12 then -- 3091
			self:flashSet("针套 · 放在桌上", 1) -- 3093
		elseif self.deskHold == 24 then -- 3093
			self:flashSet("指南针 · 压住纸条", 1) -- 3095
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 3095
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
	if self.phase == "tower-given" then -- 3109
		local soldier = self.storyRoute == "soldier" -- 3114
		self.phaseTick = self.phaseTick + 1 -- 3115
		if self.phaseTick == 60 then -- 3115
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 3117
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 3118
		elseif self.phaseTick == 120 then -- 3118
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 3120
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 3120
			self.phase = "tower-end" -- 3122
			self.phaseTick = 0 -- 3123
			self.towerEndMustRelease = input.interact.held or input.retry.held -- 3124
			if not self.run.finished then -- 3124
				self.run.finished = true -- 3126
				local ending = soldier and "reunion" or "lamp" -- 3127
				self.run.story.ending = ending -- 3128
				local ____soldier_99 -- 3131
				if soldier then -- 3131
					____soldier_99 = self.run.story.segments.escort5 == true -- 3132
				else -- 3132
					____soldier_99 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 3133
				end -- 3133
				local played = ____soldier_99 -- 3131
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 3134
				if official then -- 3134
					if soldier then -- 3134
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
	if self.towerEndMustRelease then -- 3162
		if not held then -- 3162
			self.towerEndMustRelease = false -- 3165
		end -- 3165
		return -- 3167
	end -- 3167
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 3169
	if self.phaseTick < waitTicks then -- 3169
		if input.interact.pressed or input.retry.pressed then -- 3169
			self.towerEndMustRelease = held -- 3172
		end -- 3172
		return -- 3174
	end -- 3174
	if input.interact.pressed or input.retry.pressed then -- 3174
		self.restartStory = true -- 3178
		self:requestRoom("prologue", "片尾再玩") -- 3179
		self:flashSet("回到序章", 1.4) -- 3180
	end -- 3180
end -- 3029
function Play.prototype.stepChase(self, dt, input) -- 3185
	if self.caughtT > 0 then -- 3185
		self.caughtT = self.caughtT - dt -- 3187
		if self.caughtT <= 0 then -- 3187
			self:recoverFromCaught() -- 3189
		end -- 3189
		return -- 3191
	end -- 3191
	if self.room.key == "village" then -- 3191
		self:stepScavChase() -- 3194
	elseif self.room.key == "forest" then -- 3194
		self:stepForestRoute() -- 3196
		self:stepDog(dt) -- 3197
		if self.player.x >= self.ox + 1450 then -- 3197
			self:requestRoom("tower", "到林缘北塔") -- 3200
			self:flashSet("林缘 · 北塔", 1.4) -- 3201
		end -- 3201
	end -- 3201
end -- 3185
function Play.prototype.stepScavChase(self) -- 3207
	local s = self.room.scavenger -- 3208
	if s == nil then -- 3208
		return -- 3210
	end -- 3210
	local p = self.player -- 3212
	if self.passed and p.x > self.ox + 440 then -- 3212
		if self.scavChase then -- 3212
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
	if not self.scavChase then -- 3225
		if visible then -- 3225
			self.scavSee = self.scavSee + 1 -- 3228
			if self.scavSee >= 24 then -- 3228
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
	if hidden then -- 3238
		self.scavSee = 0 -- 3242
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 3243
		self.scavT = self.scavT - 1 -- 3244
		if self.scavT <= 0 then -- 3244
			self.scavChase = false -- 3246
			self.scavState = "patrol" -- 3247
			self:flashSet("他失去了目标", 1) -- 3248
		end -- 3248
		return -- 3250
	end -- 3250
	local dir = p.x > self.scavX and 1 or -1 -- 3253
	self.scavX = self.scavX + dir * 96 / 60 -- 3254
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 3254
		self:caught() -- 3256
		return -- 3257
	end -- 3257
end -- 3207
function Play.prototype.stepDog(self, dt) -- 3262
	local ____temp_100 -- 3263
	if self.room.story == nil then -- 3263
		____temp_100 = nil -- 3263
	else -- 3263
		____temp_100 = self.room.story.dog -- 3263
	end -- 3263
	local dog = ____temp_100 -- 3263
	if dog == nil then -- 3263
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
	if self.dogState == "patrol" then -- 3278
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 3280
		if self.dogX < dog.x0 then -- 3280
			self.dogX = dog.x0 -- 3282
			self.dogDir = 1 -- 3283
		elseif self.dogX > dog.x1 then -- 3283
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
				if math.abs(p.x - (ox + twigOffsets[ti + 1])) <= 18 and p.y <= 8 then -- 3292
					nearTwig = true -- 3294
					break -- 3295
				end -- 3295
				ti = ti + 1 -- 3292
			end -- 3292
		end -- 3292
		local twigRange = nearTwig and math.max(effectiveRange, 400) or effectiveRange -- 3298
		if not sheltered and not p.crouch and moving and dist < twigRange then -- 3298
			self.dogState = "ear" -- 3300
			self.dogT = nearTwig and math.min(earNeedTicks, 12) or earNeedTicks -- 3301
			self.dogTargetX = p.x -- 3302
			self:flashSet(inDitchSprint and "旧渠枯枝响 · 狗立刻转耳" or (nearTwig and "踩断枯枝 · 狗立刻转耳" or "狗转耳朵"), 0.8) -- 3303
		end -- 3303
		return -- 3305
	end -- 3305
	if self.dogState == "ear" then -- 3305
		if sheltered then -- 3305
			self.dogState = "sniff" -- 3309
			self.dogT = 45 -- 3310
			self:flashSet("钻进遮蔽 · 狗顿住了", 0.9) -- 3311
			return -- 3312
		end -- 3312
		self.dogT = self.dogT - 1 -- 3314
		if self.dogT <= 0 then -- 3314
			self.dogState = "chase" -- 3316
			self.dogTargetX = p.x -- 3317
			self:flashSet("狗追来了", 1.4) -- 3318
		end -- 3318
		return -- 3320
	end -- 3320
	if self.dogState == "chase" then -- 3320
		local dir = p.x > self.dogX and 1 or -1 -- 3323
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 3324
		if not sheltered and math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 3324
			self:caught() -- 3326
			self.dogState = "sniff" -- 3327
			self.dogT = 60 -- 3328
		elseif dist > effectiveRange * 1.5 or sheltered then -- 3328
			self.dogState = "sniff" -- 3330
			self.dogT = 60 -- 3331
			self:flashSet(inBurrowCover and "树根窄洞遮住身形 · 狗停下了" or "狗停下了", 0.9) -- 3332
		end -- 3332
		return -- 3334
	end -- 3334
	if self.dogState == "sniff" then -- 3334
		self.dogT = self.dogT - 1 -- 3337
		if self.dogT <= 0 then -- 3337
			self.dogState = "back" -- 3339
		end -- 3339
		return -- 3341
	end -- 3341
	local dir = dog.x0 > self.dogX and 1 or -1 -- 3344
	self.dogX = self.dogX + dir * dog.speed * dt -- 3345
	if math.abs(self.dogX - dog.x0) < 2 then -- 3345
		self.dogX = dog.x0 -- 3347
		self.dogState = "patrol" -- 3348
	end -- 3348
end -- 3262
function Play.prototype.stepForestRoute(self) -- 3353
	local p = self.player -- 3354
	local ox = self.ox -- 3355
	if self.forestPath == "" then -- 3355
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 3355
			self.forestPath = "burrow" -- 3358
			self.run.story.segments.forest_burrow = true -- 3359
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 3360
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 3361
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 3361
			self.forestPath = "ditch" -- 3363
			self.run.story.segments.forest_ditch = true -- 3364
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 3365
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 3366
		end -- 3366
	end -- 3366
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 3366
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
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3389
		self.scavX = self.room.scavenger.x0 -- 3391
		self.scavState = "patrol" -- 3392
		self.scavSee = 0 -- 3393
		self.scavChase = false -- 3394
		self.scavT = 0 -- 3395
	end -- 3395
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3395
		self.dogX = self.room.story.dog.x0 -- 3398
		self.dogState = "patrol" -- 3399
		self.dogT = 0 -- 3400
	end -- 3400
	self.cam.x = p.x -- 3402
	self.cam.y = p.y + CAM_LOOK_UP -- 3403
	self:flashSet("回到安全点", 1.2) -- 3404
end -- 3383
function Play.prototype.updateGate(self) -- 3408
	if self.room.key ~= "checkpoint" then -- 3408
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
	if kind == "shield" then -- 3421
		if inv.shield >= TOOL_CAP then -- 3421
			return false -- 3424
		end -- 3424
		inv.shield = inv.shield + 1 -- 3426
		return true -- 3427
	end -- 3427
	if kind == "wedge" then -- 3427
		if inv.wedge >= CONSUMABLE_CAP then -- 3427
			return false -- 3431
		end -- 3431
		inv.wedge = inv.wedge + 1 -- 3433
		return true -- 3434
	end -- 3434
	if kind == "ammo" then -- 3434
		if inv.ammo >= CONSUMABLE_CAP then -- 3434
			return false -- 3438
		end -- 3438
		inv.ammo = inv.ammo + 1 -- 3440
		return true -- 3441
	end -- 3441
	if kind == "scrap" then -- 3441
		inv.scrap = inv.scrap + 1 -- 3445
		return true -- 3446
	end -- 3446
	if kind == "wood" then -- 3446
		inv.wood = inv.wood + 1 -- 3449
		return true -- 3450
	end -- 3450
	if kind == "bell" then -- 3450
		inv.bell = inv.bell + 1 -- 3453
		return true -- 3454
	end -- 3454
	if kind == "pass" then -- 3454
		inv.pass = inv.pass + 1 -- 3457
		return true -- 3458
	end -- 3458
	if kind == "quickbelt" then -- 3458
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
			if self.boxes[i + 1].id == id then -- 3469
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
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3483
					goto __continue529 -- 3485
				end -- 3485
				if not self:nearBox(b, 26) then -- 3485
					goto __continue529 -- 3488
				end -- 3488
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3490
				if best == nil or d < bestD then -- 3490
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
	if self.craftT > 0 then -- 3506
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3506
			self.craftT = 0 -- 3510
			self:flashSet("制作中断", 0.8) -- 3511
			return true -- 3512
		end -- 3512
		self.craftT = self.craftT + 1 -- 3514
		if self.craftT >= required then -- 3514
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3514
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
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3525
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
				if b.interact == nil or b.broken == true then -- 3550
					goto __continue542 -- 3552
				end -- 3552
				if not self:nearBox(b, b.interact.reach or 27) then -- 3552
					goto __continue542 -- 3555
				end -- 3555
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3557
				if d < bestD then -- 3557
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
	if self.reloadT > 0 then -- 3569
		self.reloadT = self.reloadT - 1 -- 3571
	end -- 3571
	if self.bracedShield ~= nil then -- 3571
		self.bracedShield.x = p.x + p.facing * 26 -- 3575
		self.bracedShield.y = p.y -- 3576
		local shBox = __TS__ArrayFind( -- 3577
			self.boxes, -- 3577
			function(____, b) return b.id == "braced_shield" end -- 3577
		) -- 3577
		if shBox ~= nil then -- 3577
			shBox.x0 = self.bracedShield.x - 15 -- 3579
			shBox.x1 = self.bracedShield.x + 15 -- 3580
			shBox.y0 = self.bracedShield.y -- 3581
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3582
		end -- 3582
	end -- 3582
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3582
		self.run.route = "drygoods" -- 3588
		self.run.joined = false -- 3589
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3590
		self:log("转布行线") -- 3591
	end -- 3591
	if wr.key == "escort3" then -- 3591
		local nearBench = p.x >= wr.minX + 472 and p.x <= wr.minX + 710 and p.y < 60 -- 3596
		if nearBench and input.interact.pressed then -- 3596
			self:openCraftBench() -- 3598
			return -- 3599
		end -- 3599
		local ____temp_103 = self.storyRoute == "soldier" -- 3601
		if ____temp_103 then -- 3601
			local ____opt_101 = self.run.story.talents -- 3601
			____temp_103 = (____opt_101 and ____opt_101.deferred) == true -- 3601
		end -- 3601
		if ____temp_103 and p.x >= wr.minX + 940 then -- 3601
			self:triggerDeferredEscort3Draft() -- 3602
		end -- 3602
	end -- 3602
	local i = 0 -- 3606
	do -- 3606
		i = 0 -- 3607
		while i < #self.pickups do -- 3607
			do -- 3607
				local pk = self.pickups[i + 1] -- 3608
				if self.run.taken[pk.id] == true then -- 3608
					goto __continue556 -- 3610
				end -- 3610
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3612
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3613
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3613
					if not self:addItem(pk.kind) then -- 3613
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
	local ____temp_109 = self.partner.alive and self.run.joined -- 3630
	if ____temp_109 then -- 3630
		local ____opt_104 = self.room.campaign -- 3630
		local ____temp_108 = (____opt_104 and ____opt_104.chapter) == "S" -- 3631
		if not ____temp_108 then -- 3631
			local ____opt_106 = self.room.campaign -- 3631
			____temp_108 = (____opt_106 and ____opt_106.chapter) == "C" -- 3631
		end -- 3631
		____temp_109 = ____temp_108 -- 3630
	end -- 3630
	if ____temp_109 and (self.escort.fear > 0 or self.escort.state == "frozen" or self.escort.state == "calming") then -- 3630
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
		if not hadK1 and self.escort.knock1 then -- 3636
			self:emit("knock", {count = 1, x = self.partner.x, room = self.room.key}) -- 3638
		end -- 3638
		if not hadK2 and self.escort.knock2 then -- 3638
			self:emit("knock", {count = 2, x = self.partner.x, room = self.room.key}) -- 3641
		end -- 3641
		self.partner.crouch = self.escort.crouchPose -- 3643
		self.partner.h = self.partner.crouch and CHILD_CROUCH_H or CHILD_H -- 3644
	end -- 3644
	if not self.calmConsumed and not self:stepCraft(input) and input.interact.pressed then -- 3644
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
				if m.kind ~= 0 then -- 3658
					goto __continue566 -- 3660
				end -- 3660
				local dx = self.player.x - m.x -- 3662
				local dy = self.player.y - m.y -- 3663
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3663
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
	if b ~= nil then -- 3674
		self:useInteract(b) -- 3676
		return -- 3677
	end -- 3677
	local inv = self.run.inventory -- 3679
	if inv.wedge > 0 then -- 3679
		local w = self:findWedgeTarget() -- 3681
		if w ~= nil then -- 3681
			local ____opt_110 = w.breakable -- 3681
			local extraHp = (____opt_110 and ____opt_110.wedgeHp or 1) + self:talentRank("salvage") -- 3683
			if w.breakable ~= nil then -- 3683
				local ____w_breakable_112, ____hp_113 = w.breakable, "hp" -- 3683
				____w_breakable_112[____hp_113] = ____w_breakable_112[____hp_113] + extraHp -- 3685
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
		if self:isEscortRoom() then -- 3693
			local p = self.player -- 3696
			local wx = math.max( -- 3697
				self.room.minX + 64, -- 3697
				math.min(self.room.maxX - 64, p.x + p.facing * 32) -- 3697
			) -- 3697
			local hp = 1 + self:talentRank("salvage") -- 3698
			self.fieldWedgeSeq = self.fieldWedgeSeq + 1 -- 3699
			local wid = "field_wedge_" .. tostring(self.fieldWedgeSeq) -- 3700
			local ____self_boxes_114 = self.boxes -- 3700
			____self_boxes_114[#____self_boxes_114 + 1] = { -- 3701
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
	if inv.ammo > 0 and self.reloadT > 0 then -- 3715
		self.reloadT = 0 -- 3720
		self:closeReloadPuzzle() -- 3721
		inv.ammo = inv.ammo - 1 -- 3722
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3723
		self:log("用备用弹包") -- 3724
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3725
		return -- 3726
	end -- 3726
	local canBraceHere = self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 or self:isEscortRoom() -- 3728
	if inv.shield > 0 and self.bracedShield == nil and canBraceHere then -- 3728
		local p = self.player -- 3732
		local shHp = 1 + self:talentRank("salvage") -- 3733
		self.bracedShield = { -- 3734
			x = p.x + p.facing * 26, -- 3734
			y = p.y, -- 3734
			w = 30, -- 3734
			h = 64, -- 3734
			hp = shHp -- 3734
		} -- 3734
		local ____self_boxes_115 = self.boxes -- 3734
		____self_boxes_115[#____self_boxes_115 + 1] = { -- 3735
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
	if inv.pass > 0 and self.run.joined == false then -- 3744
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
	if kind == "open_board" then -- 3758
		b.broken = true -- 3760
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3761
		for ____, cover in ipairs(self.boxes) do -- 3762
			if cover.id == "s2_board_cover" then -- 3762
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
	if kind == "lower_curtain" then -- 3773
		for ____, curtain in ipairs(self.boxes) do -- 3776
			if curtain.id == "c2_curtain" then -- 3776
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
	if kind == "raise_latch" then -- 3786
		if wr.key == "c2-granary" and not self.cartDocked then -- 3786
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3790
			return -- 3791
		end -- 3791
		b.broken = true -- 3793
		self.objectiveDone = true -- 3794
		if wr.key == "c1-yard" then -- 3794
			self.run.c1Latch = true -- 3797
			self.run.joined = true -- 3798
			for ____, door in ipairs(self.boxes) do -- 3799
				if door.id == "c1_door" then -- 3799
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
	if c.bodyW <= 0 then -- 3820
		return -- 3822
	end -- 3822
	local p = self.player -- 3824
	local handleX = self.cartAxle + c.handleOffset -- 3825
	if not self.gripping then -- 3825
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3825
			self.gripping = true -- 3829
			self:flashSet("握住车柄 · A/D 推", 1) -- 3830
		end -- 3830
		return -- 3832
	end -- 3832
	if input.interact.pressed then -- 3832
		self.gripping = false -- 3835
		self:flashSet("松手", 0.5) -- 3836
		return -- 3837
	end -- 3837
	if not self.cartDocked then -- 3837
		if input.moveX ~= 0 and not self:stuckCart() then -- 3837
			self.cartAxle = math.max( -- 3841
				c.startX, -- 3841
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3841
			) -- 3841
		end -- 3841
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3841
			self.cartExposed = true -- 3846
			local gun = nil -- 3847
			local gi = 0 -- 3848
			do -- 3848
				gi = 0 -- 3849
				while gi < #self.enemies do -- 3849
					local e = self.enemies[gi + 1] -- 3850
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3850
						gun = e -- 3852
						break -- 3853
					end -- 3853
					gi = gi + 1 -- 3849
				end -- 3849
			end -- 3849
			if gun ~= nil then -- 3849
				self:campaignEnemyFire(gun) -- 3857
			end -- 3857
		end -- 3857
		p.x = self.cartAxle + c.handleOffset -- 3860
		p.y = c.baseY -- 3861
		p.depth = c.depth or 0 -- 3862
		p.vx = 0 -- 3863
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3863
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
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3880
					goto __continue609 -- 3882
				end -- 3882
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3884
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3884
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
	if c == nil then -- 3895
		return -- 3897
	end -- 3897
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3897
		self.objectiveDone = true -- 3900
	end -- 3900
	if c.goal == "reach_exit" then -- 3900
		self.objectiveDone = true -- 3903
	end -- 3903
	if not self.objectiveDone then -- 3903
		return -- 3906
	end -- 3906
	local p = self.player -- 3908
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3909
	if p.x < c.exitX or not partnerOk then -- 3909
		return -- 3911
	end -- 3911
	if self.run.story.segments[wr.key] ~= true then -- 3911
		self.run.story.segments[wr.key] = true -- 3915
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3916
	end -- 3916
	if wr.key == "escort5" then -- 3916
		self.escortDone = true -- 3920
		self.run.story.escortDone = true -- 3921
	end -- 3921
	if c.next ~= nil and c.next ~= "" then -- 3921
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3924
		self:flashSet("过关 · " .. c.next, 1.2) -- 3925
	elseif wr.key == "c2-granary" and (self.run.source == "official" or self.run.source == "chapter") then -- 3925
		self:requestRoom("gate", "军粮棚出口") -- 3928
		self:flashSet("出军粮棚 · 城门", 1.4) -- 3929
	elseif not self.run.finished then -- 3929
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
	if not a.alive then -- 3942
		return -- 3944
	end -- 3944
	local p = self.player -- 3946
	if self.craftBench.active then -- 3946
		a.vx = 0 -- 3949
		return -- 3950
	end -- 3950
	local wait = false -- 3952
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3953
	local targetDepth = p.depth -- 3954
	if self.run.joined == false then -- 3954
		wait = true -- 3956
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3957
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3958
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3958
		wait = true -- 3960
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3961
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3962
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3962
		wait = true -- 3964
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3965
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3966
	end -- 3966
	if self.partnerStuck > 0.3 then -- 3966
		a.x = a.x + a.facing * 44 -- 3970
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3971
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3972
		self.partnerLaneHold = 1.1 -- 3973
		self.partnerStuck = 0 -- 3974
	end -- 3974
	if self.partnerLaneHold > 0 then -- 3974
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3977
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3978
	end -- 3978
	local dx = targetX - a.x -- 3980
	local stopTol = wait and 18 or 74 -- 3981
	if math.abs(dx) > stopTol then -- 3981
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3983
		local before = a.x -- 3984
		a.vx = dx > 0 and speed or -speed -- 3985
		a.facing = dx > 0 and 1 or -1 -- 3986
		self:slideX(a, a.vx * dt) -- 3987
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3987
			a.vy = CHILD_JUMP -- 3990
			a.onGround = false -- 3991
		end -- 3991
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3993
	else -- 3993
		a.vx = 0 -- 3995
		self.partnerStuck = 0 -- 3996
	end -- 3996
	local dz = targetDepth - a.depth -- 3998
	if math.abs(dz) > 6 then -- 3998
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
				if e.kind == "target" then -- 4014
					if not e.alive then -- 4014
						if e.hitT > 0 then -- 4014
							e.hitT = e.hitT - dt -- 4019
						end -- 4019
						if e.hitT <= 0 then -- 4019
							e.alive = true -- 4022
							e.hitT = 0 -- 4023
						end -- 4023
					end -- 4023
					goto __continue637 -- 4026
				end -- 4026
				if not e.alive then -- 4026
					goto __continue637 -- 4029
				end -- 4029
				if e.kind == "breaker" then -- 4029
					self:stepBreaker(e, dt) -- 4032
					goto __continue637 -- 4033
				end -- 4033
				if e.kind == "shield" then -- 4033
					self:stepShield(e, dt, input) -- 4036
					goto __continue637 -- 4037
				end -- 4037
				local dx = e.x - p.x -- 4040
				if not e.awake then -- 4040
					if math.abs(dx) > 520 then -- 4040
						goto __continue637 -- 4043
					end -- 4043
					e.awake = true -- 4045
					e.fireCd = 48 -- 4046
					goto __continue637 -- 4047
				end -- 4047
				if math.abs(dx) > ENEMY_RANGE then -- 4047
					goto __continue637 -- 4050
				end -- 4050
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 4050
					goto __continue637 -- 4055
				end -- 4055
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 4055
					goto __continue637 -- 4058
				end -- 4058
				if self:blockedShot(e, p) then -- 4058
					if e.warnT > 0 then -- 4058
						e.warnT = 0 -- 4064
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4065
					end -- 4065
					goto __continue637 -- 4067
				end -- 4067
				if e.warnT > 0 then -- 4067
					e.warnT = e.warnT - 1 -- 4070
					if e.warnT <= 0 then -- 4070
						self:campaignEnemyFire(e) -- 4072
					end -- 4072
				elseif e.fireCd > 0 then -- 4072
					e.fireCd = e.fireCd - 1 -- 4075
					if e.fireCd <= 0 then -- 4075
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
	if len < 0.01 then -- 4095
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
				if b.broken == true or b.passable == true or b.hidden == true then -- 4109
					goto __continue660 -- 4111
				end -- 4111
				if b.id == "braced_shield" then -- 4111
					goto __continue660 -- 4116
				end -- 4116
				local t = hitBox(ray, b) -- 4118
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 4118
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
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 4130
		local ____self_bracedShield_116, ____hp_117 = self.bracedShield, "hp" -- 4130
		____self_bracedShield_116[____hp_117] = ____self_bracedShield_116[____hp_117] - 1 -- 4132
		if self.bracedShield.hp <= 0 then -- 4132
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
	if self:blockedShot(e, p) then -- 4141
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4144
		return -- 4145
	end -- 4145
	local cover = self:blockedByCover(e, p) -- 4147
	if cover ~= nil and self.coverHug then -- 4147
		self.coveredFlash = 0.5 -- 4149
		self:flashSet("掩体挡下", 0.6) -- 4150
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4151
		return -- 4156
	end -- 4156
	if self.invulnT > 0 then -- 4156
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
	if self.hp <= 0 then -- 4165
		self:campaignFailed() -- 4167
	end -- 4167
end -- 4128
function Play.prototype.stepShield(self, e, dt, input) -- 4172
	local p = self.player -- 4173
	local dx = p.x - e.x -- 4174
	local adx = math.abs(dx) -- 4175
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 4178
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 4179
	if adx > 44 then -- 4179
		local before = e.x -- 4181
		local stepX = (dx > 0 and 1 or -1) * 60 * dt -- 4182
		local nextX = math.max( -- 4183
			self.room.minX + 16, -- 4183
			math.min(self.room.maxX - 16, e.x + stepX) -- 4183
		) -- 4183
		if not self:enemyBlockedAtX(e, nextX) then -- 4183
			e.x = nextX -- 4185
		end -- 4185
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 4185
			e.depth = math.max( -- 4189
				-32, -- 4189
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4189
			) -- 4189
		end -- 4189
	elseif adx <= 48 and sameLane and (e.swingT or 0) <= 0 then -- 4189
		local fromFront = (e.x - p.x) * p.facing > 0 -- 4194
		local rollDodges = p.rollT > 0 and (fromFront or self:talentRank("guard") > 0) -- 4195
		if not rollDodges and self.invulnT <= 0 then -- 4195
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
			if self.hp <= 0 then -- 4201
				self:campaignFailed() -- 4203
				return -- 4204
			end -- 4204
		end -- 4204
		e.swingT = 70 -- 4207
	end -- 4207
	if (e.swingT or 0) > 0 then -- 4207
		e.swingT = (e.swingT or 0) - 1 -- 4210
	end -- 4210
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 4210
		local dd = p.depth - (e.depth or 0) -- 4213
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 4214
	end -- 4214
end -- 4172
function Play.prototype.stepBreaker(self, e, dt) -- 4219
	local p = self.player -- 4220
	if e.awake ~= true then -- 4220
		if math.abs(p.x - e.x) < 560 then -- 4220
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
				if b.breakable == nil or b.broken == true then -- 4232
					goto __continue687 -- 4234
				end -- 4234
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 4236
				if d < bestD then -- 4236
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
	if math.abs(dx) > reach then -- 4244
		local before = e.x -- 4246
		local nextX = math.max( -- 4247
			self.room.minX + 16, -- 4247
			math.min(self.room.maxX - 16, e.x + (dx > 0 and 1 or -1) * 48 * dt) -- 4247
		) -- 4247
		if not self:enemyBlockedAtX(e, nextX) then -- 4247
			e.x = nextX -- 4249
		end -- 4249
		if math.abs(e.x - before) < 0.3 then -- 4249
			e.depth = math.max( -- 4252
				-32, -- 4252
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4252
			) -- 4252
		end -- 4252
	elseif (e.swingT or 0) <= 0 then -- 4252
		e.swingT = 64 -- 4255
		if target ~= nil then -- 4255
			self:damageProp(target, 2) -- 4257
		elseif math.abs(p.x - e.x) < 60 and math.abs((e.depth or 0) - p.depth) <= 26 and not (p.rollT > 0 and self:talentRank("guard") > 0) and self.invulnT <= 0 then -- 4257
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
			if self.hp <= 0 then -- 4264
				self:campaignFailed() -- 4266
				return -- 4267
			end -- 4267
		end -- 4267
	end -- 4267
	if (e.swingT or 0) > 0 then -- 4267
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
				if b.broken == true or b.passable == true or b.soft == true or b.hidden == true or b.y0 >= e.y + e.h or b.y1 <= e.y + 4 then -- 4282
					goto __continue700 -- 4284
				end -- 4284
				if b.depth ~= nil and (d < b.depth.min - 8 or d > b.depth.max + 8) then -- 4284
					goto __continue700 -- 4287
				end -- 4287
				if nextX + half > b.x0 and nextX - half < b.x1 then -- 4287
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
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 4296
		if self.escortFailed then -- 4296
			return -- 4301
		end -- 4301
		if self.useEscortDeathSummary then -- 4301
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
					if story.segments[segKeys[si + 1]] == true then -- 4318
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
			self.escortSummary = { -- 4330
				roomKey = self.room.key, -- 4331
				attempt = st ~= nil and math.max(1, st.attempt) or 1, -- 4332
				seed = st ~= nil and st.randomState or self.run.seed, -- 4333
				equippedWeapon = self.equippedWeapon, -- 4334
				segmentsCleared = cleared, -- 4335
				ranks = ranksCopy -- 4336
			} -- 4336
			self:resetEscortAttempt() -- 4338
			self:flashSet("折返山道 · 重整再赴", 2) -- 4339
			self:log("男主线折返 · 展示小结") -- 4340
			self:emit("campaignFailed", { -- 4341
				room = self.room.key, -- 4342
				hp = 0, -- 4342
				maxHp = self.maxHp, -- 4342
				reset = true, -- 4343
				to = "escort1", -- 4343
				route = self.storyRoute, -- 4343
				summary = true -- 4343
			}) -- 4343
			return -- 4345
		end -- 4345
		self:restartEscortRun() -- 4347
		return -- 4348
	end -- 4348
	local p = self.player -- 4350
	self.hp = self.maxHp -- 4351
	self.invulnT = INVULN_RESPAWN_TICKS -- 4352
	self.reloadT = 0 -- 4353
	self:closeReloadPuzzle() -- 4354
	self.gripping = false -- 4355
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 4356
	self:log("被击倒") -- 4357
	p.x = self.room.minX + 90 -- 4358
	p.y = 0 -- 4359
	p.depth = 0 -- 4360
	p.vx = 0 -- 4361
	p.vy = 0 -- 4362
	p.onGround = true -- 4363
	p.rollT = 0 -- 4364
	self.partner.x = p.x - 50 -- 4365
	self.partner.y = 0 -- 4366
	self.partner.depth = 0 -- 4367
	self.cam.x = p.x -- 4368
	local i = 0 -- 4369
	do -- 4369
		i = 0 -- 4370
		while i < #self.enemies do -- 4370
			do -- 4370
				local e = self.enemies[i + 1] -- 4371
				if not e.alive then -- 4371
					goto __continue712 -- 4373
				end -- 4373
				e.x = e.homeX == nil and e.x or e.homeX -- 4375
				e.warnT = 0 -- 4376
				e.fireCd = 40 -- 4377
				e.swingT = 0 -- 4378
				e.awake = false -- 4379
			end -- 4379
			::__continue712:: -- 4379
			i = i + 1 -- 4370
		end -- 4370
	end -- 4370
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4381
end -- 4296
function Play.prototype.isEscortRoom(self) -- 4385
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 4386
end -- 4385
function Play.prototype.confirmEscortRestart(self) -- 4390
	if not self.escortFailed then -- 4390
		return false -- 4392
	end -- 4392
	self:requestRoom("escort1", "男主线失败重开") -- 4394
	return true -- 4395
end -- 4390
function Play.prototype.restartEscortRun(self) -- 4399
	self:resetEscortAttempt() -- 4400
	self:requestRoom("escort1", "男主线失败重开") -- 4401
end -- 4399
function Play.prototype.resetEscortAttempt(self) -- 4409
	local story = self.run.story -- 4410
	local inv = self.run.inventory -- 4411
	local prevAttempt = story.talents ~= nil and math.max(1, story.talents.attempt) or 1 -- 4412
	local nextAttempt = prevAttempt + 1 -- 4413
	local vitBonus = story.talents ~= nil and (story.talents.ranks.vitality or 0) or 0 -- 4414
	if vitBonus > 0 then -- 4414
		self.maxHp = math.max(3, self.maxHp - vitBonus) -- 4416
		story.maxHp = self.maxHp -- 4417
	end -- 4417
	story.talents = createStoryTalents(self.run.seed, nextAttempt) -- 4419
	self.hp = self.maxHp -- 4420
	story.hp = self.maxHp -- 4421
	story.cp = nil -- 4422
	self.checkpointSnap = nil -- 4423
	story.carry = false -- 4424
	self.carryOn = false -- 4425
	story.craftedWeapon = "" -- 4426
	self.equippedWeapon = "standard_gun" -- 4427
	story.equippedWeapon = "standard_gun" -- 4428
	story.escortDone = false -- 4429
	self.escortDone = false -- 4430
	story.segments = {} -- 4431
	inv.wood = 0 -- 4432
	inv.bell = 0 -- 4433
	inv.scrap = 0 -- 4434
	inv.wedge = 0 -- 4435
	inv.ammo = 0 -- 4436
	inv.quickbelt = 0 -- 4437
	inv.shield = 0 -- 4438
	inv.pass = 0 -- 4439
	local taken = self.run.taken -- 4440
	local keys = __TS__ObjectKeys(taken) -- 4441
	local i = 0 -- 4442
	do -- 4442
		i = 0 -- 4443
		while i < #keys do -- 4443
			local k = keys[i + 1] -- 4444
			if (string.find(k, "e2_", nil, true) or 0) - 1 == 0 or (string.find(k, "e3_", nil, true) or 0) - 1 == 0 or (string.find(k, "escort", nil, true) or 0) - 1 == 0 then -- 4444
				__TS__Delete(taken, k) -- 4446
			end -- 4446
			i = i + 1 -- 4443
		end -- 4443
	end -- 4443
	local propKeys = __TS__ObjectKeys(self.run.props) -- 4449
	do -- 4449
		i = 0 -- 4450
		while i < #propKeys do -- 4450
			local pk = propKeys[i + 1] -- 4451
			if (string.find(pk, "e1_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e2_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e3_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e4_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e5_", nil, true) or 0) - 1 == 0 or (string.find(pk, "field_wedge_", nil, true) or 0) - 1 == 0 then -- 4451
				__TS__Delete(self.run.props, pk) -- 4454
			end -- 4454
			i = i + 1 -- 4450
		end -- 4450
	end -- 4450
	self.bracedShield = nil -- 4457
	self.talentModalActive = false -- 4458
	self.run.joined = true -- 4459
	self.reloadT = 0 -- 4460
	self:closeReloadPuzzle() -- 4461
	self.gripping = false -- 4462
	self.sessionDirty = true -- 4463
	self:flashSet( -- 4464
		("重整启程 · 第" .. tostring(nextAttempt)) .. "轮护送", -- 4464
		2 -- 4464
	) -- 4464
	self:log(("男主线重开 · 第" .. tostring(nextAttempt)) .. "轮回 escort1") -- 4465
	if not self.useEscortDeathSummary then -- 4465
		self:emit("campaignFailed", { -- 4467
			room = self.room.key, -- 4468
			hp = 0, -- 4468
			maxHp = self.maxHp, -- 4468
			reset = true, -- 4469
			to = "escort1", -- 4469
			route = self.storyRoute, -- 4469
			attempt = nextAttempt -- 4469
		}) -- 4469
	end -- 4469
end -- 4409
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 4475
	local i = 0 -- 4476
	do -- 4476
		i = 0 -- 4477
		while i < #self.enemies do -- 4477
			do -- 4477
				if i == skipIndex then -- 4477
					goto __continue729 -- 4479
				end -- 4479
				local e = self.enemies[i + 1] -- 4481
				if not e.alive or math.abs(e.x - center.x) > radius then -- 4481
					goto __continue729 -- 4483
				end -- 4483
				e.awake = true -- 4485
				e.fireCd = math.max(e.fireCd or 0, 150) -- 4486
				e.warnT = 0 -- 4487
			end -- 4487
			::__continue729:: -- 4487
			i = i + 1 -- 4477
		end -- 4477
	end -- 4477
end -- 4475
function Play.prototype.stepEnemies(self, dt, input) -- 4491
	local i = 0 -- 4492
	do -- 4492
		i = 0 -- 4493
		while i < #self.enemies do -- 4493
			local e = self.enemies[i + 1] -- 4494
			if e.hitT > 0 then -- 4494
				e.hitT = e.hitT - dt -- 4496
			end -- 4496
			i = i + 1 -- 4493
		end -- 4493
	end -- 4493
	if self.coveredFlash > 0 then -- 4493
		self.coveredFlash = self.coveredFlash - dt -- 4500
	end -- 4500
	if self.isCampaign then -- 4500
		self:stepCampaignEnemies(dt, input) -- 4503
		return -- 4504
	end -- 4504
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 4504
		return -- 4508
	end -- 4508
	do -- 4508
		i = 0 -- 4510
		while i < #self.enemies do -- 4510
			do -- 4510
				local e = self.enemies[i + 1] -- 4511
				if not e.alive then -- 4511
					goto __continue740 -- 4513
				end -- 4513
				if e.warnT > 0 then -- 4513
					e.warnT = e.warnT - 1 -- 4516
					if e.warnT <= 0 then -- 4516
						self:enemyFire(e, input) -- 4518
					end -- 4518
					goto __continue740 -- 4520
				end -- 4520
				if e.fireCd > 0 then -- 4520
					e.fireCd = e.fireCd - 1 -- 4523
					if e.fireCd <= 0 then -- 4523
						e.warnT = WARN_TICKS -- 4525
					end -- 4525
				else -- 4525
					e.warnT = WARN_TICKS -- 4529
				end -- 4529
			end -- 4529
			::__continue740:: -- 4529
			i = i + 1 -- 4510
		end -- 4510
	end -- 4510
end -- 4491
function Play.prototype.enemyFire(self, e, input) -- 4535
	local p = self.player -- 4536
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 4536
		self:flashSet("枪声响在远处", 0.4) -- 4538
		e.fireCd = FIRE_COOLDOWN -- 4539
		return -- 4540
	end -- 4540
	if self:blockedShot(e, p) then -- 4540
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4543
		e.fireCd = FIRE_COOLDOWN -- 4544
		return -- 4545
	end -- 4545
	local cover = self:blockedByCover(e, p) -- 4548
	local hugging = cover ~= nil -- 4549
	self.coverBlocking = hugging -- 4550
	local covered = hugging and input.cover.held -- 4551
	if covered then -- 4551
		self.coveredFlash = 0.5 -- 4553
		self:flashSet("掩体挡下", 0.5) -- 4554
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4555
		e.fireCd = FIRE_COOLDOWN -- 4560
		return -- 4561
	end -- 4561
	if self.invulnT > 0 then -- 4561
		e.fireCd = FIRE_COOLDOWN -- 4564
		return -- 4565
	end -- 4565
	self.invulnT = INVULN_HIT_TICKS -- 4567
	self.hp = self.hp - 1 -- 4568
	self:emit("actorHit", { -- 4569
		target = "player", -- 4569
		amount = 1, -- 4569
		hp = self.hp, -- 4569
		maxHp = self.maxHp, -- 4569
		enemyX = e.x -- 4569
	}) -- 4569
	self:flashSet( -- 4570
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4570
		0.7 -- 4570
	) -- 4570
	e.fireCd = FIRE_COOLDOWN -- 4571
	if self.hp <= 0 then -- 4571
		self:gateFailed() -- 4573
	end -- 4573
end -- 4535
function Play.prototype.blockedByCover(self, enemy, p) -- 4578
	local b = self:coverAt(p) -- 4579
	if b == nil then -- 4579
		return nil -- 4581
	end -- 4581
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4583
end -- 4578
function Play.prototype.gateFailed(self) -- 4587
	local ____temp_134 -- 4588
	if self.room.story == nil then -- 4588
		____temp_134 = nil -- 4588
	else -- 4588
		____temp_134 = self.room.story.gate -- 4588
	end -- 4588
	local g = ____temp_134 -- 4588
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 4589
	self.hp = self.maxHp -- 4590
	self.gateTick = 0 -- 4591
	self.gateSpawned = 0 -- 4592
	self.enemies = {} -- 4593
	self.gateFailCount = self.gateFailCount + 1 -- 4594
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 4596
	self.player.y = 0 -- 4597
	self.player.vy = 0 -- 4598
	self.player.depth = 0 -- 4599
	self.player.depthSpeed = 0 -- 4600
	self.player.onGround = true -- 4601
	self.player.crouch = false -- 4602
	self.player.h = SOLDIER_H -- 4603
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 4604
	self.partner.y = 0 -- 4605
	self.partner.vy = 0 -- 4606
	self.partner.depth = 0 -- 4607
	self.partner.depthSpeed = 0 -- 4608
	self.partner.onGround = true -- 4609
	self.cam.x = self.player.x -- 4610
	self.phase = "gate-idle" -- 4611
	self.phaseTick = 0 -- 4612
	self.coverHug = false -- 4613
	self.coverBlocking = false -- 4614
	self.coverEntity = "" -- 4615
	self.gateNeedConfirm = true -- 4616
	self.gateRestartArmed = false -- 4617
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 4618
end -- 4587
function Play.prototype.stepRedCart(self, input) -- 4622
	if self.redCartMemoryT > 0 then -- 4622
		self.redCartMemoryT = self.redCartMemoryT - 1 -- 4624
	end -- 4624
	if self.room.key ~= "outside" or self.redCartPulled then -- 4624
		return -- 4627
	end -- 4627
	local box = __TS__ArrayFind( -- 4629
		self.boxes, -- 4629
		function(____, b) return b.id == "outside_red_cart" end -- 4629
	) -- 4629
	if box == nil then -- 4629
		self.redCartPulled = true -- 4631
		return -- 4632
	end -- 4632
	local cx = (box.x0 + box.x1) * 0.5 -- 4634
	local p = self.player -- 4635
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 4635
		return -- 4637
	end -- 4637
	if not input.interact.pressed then -- 4637
		return -- 4640
	end -- 4640
	box.x0 = 430 -- 4642
	box.x1 = 474 -- 4643
	self.cartAxle = self.room.cart.endX -- 4645
	self.cartDocked = true -- 4646
	self.redCartPulled = true -- 4647
	self.redCartMemoryT = 30 -- 4648
	if self.run.story ~= nil then -- 4648
		self.run.story.segments.outside_cart = true -- 4650
		self.run.story.segments.outside_memory = true -- 4651
	end -- 4651
	self.sessionDirty = true -- 4653
	self:flashSet("红布补丁 · 想起家里那一针 · 石阶口露出来", 1.8) -- 4654
	self:emit("storyBeat", {beat = "red_cart", x = p.x, room = "outside"}) -- 4655
	self:emit("storyBeat", {beat = "red_cart_memory", x = p.x, room = "outside", durationTicks = 30}) -- 4656
end -- 4622
function Play.prototype.stepInteract(self, dt, input) -- 4659
	local p = self.player -- 4660
	self:stepRedCart(input) -- 4661
	local calmUsed = self.calmConsumed -- 4662
	self.calmConsumed = false -- 4663
	local calming = self.escort.state == "calming" -- 4665
	self.focusCart = false -- 4666
	if self.room.key == "outside" then -- 4666
		local c = self.room.cart -- 4668
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 4669
		local dy = p.y - c.baseY -- 4670
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 4671
	end -- 4671
	if not calmUsed and not calming then -- 4671
		self:stepCart(dt, input) -- 4675
	end -- 4675
	if calmUsed then -- 4675
		self:flashSet("安抚 · 敲两下", 0.8) -- 4680
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4680
		if self.knockT > 0 then -- 4680
			self.knocks = self.knocks + 1 -- 4684
		else -- 4684
			self.knocks = 1 -- 4686
		end -- 4686
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4688
		self.knockT = 1.2 -- 4689
		if self.knocks >= 2 then -- 4689
			self:flashSet("敲两下", 0.8) -- 4691
			self.knocks = 0 -- 4692
		else -- 4692
			self:flashSet("敲一下", 0.5) -- 4694
		end -- 4694
	elseif self.knockT > 0 then -- 4694
		self.knockT = self.knockT - dt -- 4697
		if self.knockT <= 0 then -- 4697
			self.knocks = 0 -- 4699
		end -- 4699
	end -- 4699
	local i = 0 -- 4704
	do -- 4704
		i = 0 -- 4705
		while i < #self.room.marks do -- 4705
			do -- 4705
				local m = self.room.marks[i + 1] -- 4706
				if m.kind ~= 0 then -- 4706
					goto __continue776 -- 4708
				end -- 4708
				local subjects = {self.partner, self.player} -- 4710
				local k = 0 -- 4711
				do -- 4711
					k = 0 -- 4712
					while k < #subjects do -- 4712
						do -- 4712
							local s = subjects[k + 1] -- 4713
							if not s.alive then -- 4713
								goto __continue779 -- 4715
							end -- 4715
							local dx = s.x - m.x -- 4717
							local dy = s.y - m.y -- 4718
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4718
								self.checkpoint = m.x -- 4720
								self.checkpointCartAxle = self.cartAxle -- 4721
								if self.isCampaign then -- 4721
									self:captureCheckpoint(m.x) -- 4724
								end -- 4724
								if self.room.cart.bodyW > 0 then -- 4724
									if self.cartDocked then -- 4724
										self:flashSet("检查点 · 车已落窝", 1) -- 4728
									else -- 4728
										self:flashSet("检查点 · 车还没到位", 1) -- 4730
									end -- 4730
								else -- 4730
									self:flashSet("检查点", 1) -- 4733
								end -- 4733
							end -- 4733
						end -- 4733
						::__continue779:: -- 4733
						k = k + 1 -- 4712
					end -- 4712
				end -- 4712
			end -- 4712
			::__continue776:: -- 4712
			i = i + 1 -- 4705
		end -- 4705
	end -- 4705
	self:checkCarryGate() -- 4739
end -- 4659
function Play.prototype.stepVillage(self, dt, input) -- 4743
	if self.room.key ~= "village" then -- 4743
		return -- 4745
	end -- 4745
	local p = self.player -- 4747
	local bottle = self.room.bottle -- 4748
	local scav = self.room.scavenger -- 4749
	if not self.hasBottle and bottle ~= nil then -- 4749
		local dx = p.x - bottle.x -- 4753
		local dy = p.y + p.h * 0.5 - bottle.y -- 4754
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4754
			self.hasBottle = true -- 4756
			self:flashSet("拾起瓶子", 0.8) -- 4757
		end -- 4757
	end -- 4757
	if self.hasBottle then -- 4757
		if input.bottleCanceled then -- 4757
			self.aimHold = 0 -- 4764
			self.bottleAimX = -1 -- 4765
		elseif input.aim.held then -- 4765
			self.aimHold = self.aimHold + dt -- 4767
			if self.aimHold > 1.2 then -- 4767
				self.aimHold = 1.2 -- 4769
			end -- 4769
			local cached = self:bottleEnd() -- 4772
			self.bottleAimX = cached.x -- 4773
			self.bottleAimY = cached.y -- 4774
		elseif input.aim.released then -- 4774
			if self.aimHold < 0.12 then -- 4774
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 4778
				self.aimHold = 0 -- 4779
			else -- 4779
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4781
				self:throwBottle(____end.x, ____end.y) -- 4782
				self.aimHold = 0 -- 4783
			end -- 4783
		end -- 4783
	else -- 4783
		self.aimHold = 0 -- 4787
		self.bottleAimX = -1 -- 4788
	end -- 4788
	local fly = self.bottleFly -- 4793
	if fly ~= nil then -- 4793
		fly.t = fly.t + dt -- 4795
		fly.x = fly.x0 + fly.vx * fly.t -- 4796
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4797
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4798
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4798
			self:landBottle(fly) -- 4800
		end -- 4800
	end -- 4800
	if self.bottleLandT > 0 then -- 4800
		self.bottleLandT = self.bottleLandT - dt -- 4804
	end -- 4804
	if scav ~= nil then -- 4804
		self:stepScav(dt, scav) -- 4808
	end -- 4808
	local line = self.room.passLine -- 4811
	if line ~= nil and not self.passed and p.x >= line then -- 4811
		self.passed = true -- 4813
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4814
	end -- 4814
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4817
	if underTable then -- 4817
		self.footHintT = self.footHintT - 1 -- 4819
		if self.footHintT <= 0 then -- 4819
			self.footHintT = 90 -- 4821
			local scavX = self.scavX -- 4822
			local near = math.abs(scavX - p.x) < 120 -- 4823
			local walkingAway = self.scavState == "walk" and math.abs(self.scavTargetX - p.x) >= 120 -- 4824
			local heard = self.scavState == "chase" or near and not walkingAway -- 4825
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4826
			self:emit("storyBeat", {beat = heard and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4827
		end -- 4827
	else -- 4827
		self.footHintT = 0 -- 4830
	end -- 4830
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4830
		self.ditchHinted = true -- 4834
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4835
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4836
	end -- 4836
	local inCulvert = p.x >= self.ox + 560 and p.x <= self.ox + 640 -- 4839
	if self.passed and inCulvert and p.crouch and self.wantRoom == "" then -- 4839
		self:requestRoom("forest", "蹲下钻过暗渠") -- 4841
		self:flashSet("钻进暗渠 · 北塔森林", 1.4) -- 4842
	end -- 4842
end -- 4743
function Play.prototype.bottleEnd(self) -- 4847
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4848
	local clampedX = math.max( -- 4851
		self.room.minX + 12, -- 4851
		math.min(self.room.maxX - 12, aim.x) -- 4851
	) -- 4851
	local g = self:groundAt(clampedX, aim.y + 240, 3) -- 4852
	return {x = clampedX, y = g} -- 4853
end -- 4847
function Play.prototype.throwBottle(self, tx, ty) -- 4857
	local p = self.player -- 4858
	local dir = tx >= p.x and 1 or -1 -- 4860
	p.facing = dir -- 4861
	local x0 = p.x + dir * 10 -- 4862
	local y0 = p.y + p.h * 0.7 -- 4863
	self.bottleTargetX = tx -- 4864
	self.bottleTargetY = ty -- 4865
	self.bottleSurfaceY = ty -- 4866
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4867
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4868
	self.bottleFly = { -- 4869
		x = x0, -- 4869
		y = y0, -- 4869
		x0 = x0, -- 4869
		y0 = y0, -- 4869
		vx = vx, -- 4869
		vy = vy, -- 4869
		t = 0 -- 4869
	} -- 4869
	self.hasBottle = false -- 4870
	self:flashSet("投出", 0.4) -- 4871
	self:emit( -- 4872
		"bottleThrown", -- 4872
		{ -- 4872
			fromX = x0, -- 4873
			fromY = y0, -- 4874
			targetX = tx, -- 4875
			targetY = ty, -- 4876
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4877
		} -- 4877
	) -- 4877
end -- 4857
function Play.prototype.bottleSurfaceAt(self, x) -- 4882
	if self.room.softX ~= nil and math.abs(x - self.room.softX) <= 34 then -- 4882
		return "soft" -- 4884
	end -- 4884
	if self.room.basinX ~= nil and math.abs(x - self.room.basinX) <= 24 then -- 4884
		return "iron" -- 4887
	end -- 4887
	return "brick" -- 4889
end -- 4882
function Play.prototype.landBottle(self, fly) -- 4893
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4894
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4895
	local s = self.room.scavenger -- 4896
	local surface = self:bottleSurfaceAt(x) -- 4897
	local effRange = s == nil and 0 or (surface == "iron" and s.range * 1.25 or s.range) -- 4898
	local heard = surface ~= "soft" and s ~= nil and math.abs(x - self.scavX) <= effRange -- 4899
	local stallTicks = s == nil and 0 or (surface == "iron" and s.stallTicks + 90 or s.stallTicks) -- 4900
	self.bottleFly = nil -- 4901
	self.bottleTargetX = -1 -- 4902
	self.bottleTargetY = 0 -- 4903
	self.bottleSurfaceY = -1 -- 4904
	self.bottleLandX = x -- 4905
	self.bottleLandY = y -- 4906
	self.bottleLandT = 0.9 -- 4907
	self:emit("bottleLanded", { -- 4908
		x = x, -- 4909
		y = y, -- 4910
		surface = surface, -- 4911
		heard = heard, -- 4912
		resonance = surface == "iron", -- 4913
		stallTicks = heard and stallTicks or 0, -- 4914
		scavState = self.scavState -- 4915
	}) -- 4915
	self:hearBottle(x, surface) -- 4917
end -- 4893
function Play.prototype.hearBottle(self, x, surface) -- 4921
	if surface == nil then -- 4921
		surface = "brick" -- 4921
	end -- 4921
	local s = self.room.scavenger -- 4922
	if s == nil then -- 4922
		return -- 4924
	end -- 4924
	if surface == "soft" then -- 4924
		self:flashSet("落在软土 · 没出声", 0.8) -- 4927
		return -- 4928
	end -- 4928
	local effRange = surface == "iron" and s.range * 1.25 or s.range -- 4930
	if math.abs(x - self.scavX) > effRange then -- 4930
		self:flashSet("落地 · 他没听见", 0.6) -- 4932
		return -- 4933
	end -- 4933
	self.scavState = "turn" -- 4935
	self.scavT = s.hearTicks -- 4936
	self.scavTargetX = surface == "iron" and self.room.basinX ~= nil and self.room.basinX or x -- 4937
	self.scavStallBonus = surface == "iron" and 90 or 0 -- 4938
	self:flashSet(surface == "iron" and "铁盆余振两响 · 他停下来细听" or "砖地一响 · 他转头", 1.1) -- 4939
end -- 4921
function Play.prototype.stepScav(self, dt, s) -- 4943
	if self.scavState == "chase" then -- 4943
		return -- 4946
	end -- 4946
	if self.scavState == "turn" then -- 4946
		self.scavT = self.scavT - 1 -- 4949
		if self.scavT <= 0 then -- 4949
			self.scavState = "walk" -- 4951
		end -- 4951
		return -- 4953
	end -- 4953
	if self.scavState == "walk" then -- 4953
		local d = self.scavTargetX - self.scavX -- 4956
		if math.abs(d) < 4 then -- 4956
			self.scavState = "stall" -- 4958
			self.scavT = s.stallTicks + self.scavStallBonus -- 4959
			self.scavStallBonus = 0 -- 4960
			return -- 4961
		end -- 4961
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4963
		return -- 4964
	end -- 4964
	if self.scavState == "stall" then -- 4964
		self.scavT = self.scavT - 1 -- 4967
		if self.scavT <= 0 then -- 4967
			self.scavState = "back" -- 4969
		end -- 4969
		return -- 4971
	end -- 4971
	if self.scavState == "back" then -- 4971
		local home = math.max( -- 4974
			s.x0, -- 4974
			math.min(s.x1, self.scavX) -- 4974
		) -- 4974
		if math.abs(home - self.scavX) < 2 then -- 4974
			self.scavState = "patrol" -- 4976
			return -- 4977
		end -- 4977
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4979
		return -- 4980
	end -- 4980
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4982
	if self.scavX >= s.x1 then -- 4982
		self.scavX = s.x1 -- 4984
		self.scavDir = -1 -- 4985
	elseif self.scavX <= s.x0 then -- 4985
		self.scavX = s.x0 -- 4987
		self.scavDir = 1 -- 4988
	end -- 4988
end -- 4943
function Play.prototype.stepCart(self, dt, input) -- 4996
	local p = self.player -- 4997
	local c = self.room.cart -- 4998
	if self.gripping then -- 4998
		if not input.interact.held then -- 4998
			self.gripping = false -- 5002
			self:flashSet("松开车把", 0.4) -- 5003
			return -- 5004
		end -- 5004
	else -- 5004
		if not input.interact.pressed then -- 5004
			return -- 5008
		end -- 5008
		if not self:cartHandleInReach(p) then -- 5008
			return -- 5011
		end -- 5011
		local track = c.depth or 0 -- 5013
		if self:limitDepth(p, track) ~= track then -- 5013
			return -- 5015
		end -- 5015
		p.depth = track -- 5017
		p.depthSpeed = 0 -- 5018
		self.gripping = true -- 5019
		self:flashSet("握住车把", 0.4) -- 5020
		return -- 5021
	end -- 5021
	if self.cartDocked then -- 5021
		return -- 5025
	end -- 5025
	local dir = input.moveX -- 5027
	if dir == 0 then -- 5027
		return -- 5029
	end -- 5029
	local lo = math.min(c.startX, c.endX) -- 5031
	local hi = math.max(c.startX, c.endX) -- 5032
	local next = self.cartAxle + dir * CART_SPEED * dt -- 5033
	if next < lo then -- 5033
		next = lo -- 5035
	end -- 5035
	if next > hi then -- 5035
		next = hi -- 5038
	end -- 5038
	local delta = next - self.cartAxle -- 5040
	if delta == 0 then -- 5040
		return -- 5042
	end -- 5042
	self.cartAxle = next -- 5044
	p.x = p.x + delta -- 5045
	p.facing = dir > 0 and 1 or -1 -- 5046
	self:slideX(p, 0) -- 5047
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 5047
		self.gripping = false -- 5049
		self:flashSet("跟不上了，脱手", 0.6) -- 5050
		return -- 5051
	end -- 5051
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 5051
		self.cartDocked = true -- 5054
		self.gripping = false -- 5055
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 5056
		self:flashSet("车轮落窝", 1.2) -- 5057
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 5057
		self:flashSet("车轮回到起点", 0.5) -- 5059
	end -- 5059
end -- 4996
function Play.prototype.requestRoom(self, key, reason) -- 5067
	if self.wantRoom ~= "" then -- 5067
		return -- 5071
	end -- 5071
	self.wantRoom = key -- 5073
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 5074
end -- 5067
function Play.prototype.checkCarryGate(self) -- 5081
	if self.room.key == "checkpoint" then -- 5081
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 5081
			self.carryCartAxle = self.cartAxle -- 5084
			self.carryCartDocked = self.cartDocked -- 5085
			self:requestRoom("gate", "检查站出口") -- 5086
			self:flashSet("出检查站 · 城门", 1.2) -- 5087
		end -- 5087
		return -- 5089
	end -- 5089
	if self.room.key == "outside" then -- 5089
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 5089
			self.carryCartAxle = self.cartAxle -- 5095
			self.carryCartDocked = self.cartDocked -- 5096
			self:requestRoom("village", "墙根走完") -- 5097
			self:flashSet("墙根走完 · 进村口", 1.2) -- 5098
		end -- 5098
	end -- 5098
end -- 5081
function Play.prototype.aimAt(self, wx, wy) -- 5105
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 5106
	self.aimX = s.x -- 5107
	self.aimY = s.y -- 5108
end -- 5105
function Play.prototype.shoot(self, a) -- 5111
	if self.isCampaign and self.reloadT > 0 then -- 5111
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 5113
		return -- 5114
	end -- 5114
	local ox = a.x + a.facing * 8 -- 5116
	local muzzleY = a.y + a.h * 0.72 -- 5117
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 5118
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 5120
	local dx = aim.x - ox -- 5123
	local dy = aim.y - oy -- 5124
	local len = math.sqrt(dx * dx + dy * dy) -- 5125
	if len < 0.001 then -- 5125
		dx = a.facing -- 5127
		dy = 0 -- 5128
	else -- 5128
		dx = dx / len -- 5130
		dy = dy / len -- 5131
	end -- 5131
	if dx ~= 0 then -- 5131
		a.facing = dx > 0 and 1 or -1 -- 5134
	end -- 5134
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 5137
	local hitEnemy = self:raycastEnemies(ray) -- 5138
	local tEnemy = hitEnemy.t -- 5139
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 5140
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 5141
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 5142
	local tWall = solid.t -- 5143
	local rawEffect = self:consumeReloadEffect() -- 5145
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 5146
	local reloadEffect = rawEffect -- 5147
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 5149
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 5150
	self.trace = { -- 5152
		x0 = ox, -- 5152
		y0 = oy, -- 5152
		x1 = ox + dx * t, -- 5152
		y1 = oy + dy * t, -- 5152
		hit = hit -- 5152
	} -- 5152
	self.traceT = 0.12 -- 5153
	self:applyFireDanger(ox) -- 5154
	local killed = false -- 5155
	if hit then -- 5155
		local i = hitEnemy.index -- 5157
		local e = self.enemies[i + 1] -- 5158
		local impactY = oy + dy * tEnemy -- 5159
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 5160
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 5161
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 5161
			local pushRank = self:talentRank("push_force") -- 5163
			local dmg = reloadEffect == "push" and 2 + pushRank or 1 -- 5164
			e.shieldHp = math.max(0, (e.shieldHp or 0) - dmg) -- 5165
			e.hitT = 0.3 -- 5166
			if reloadEffect == "push" then -- 5166
				local kb = 46 + 24 * pushRank -- 5168
				e.x = math.max( -- 5169
					self.room.minX + 20, -- 5169
					math.min(self.room.maxX - 20, e.x + a.facing * kb) -- 5169
				) -- 5169
				if pushRank > 0 then -- 5169
					self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5171
				end -- 5171
				self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5173
				self:flashSet(e.shieldHp <= 0 and "推退破盾！" or "推退震退持盾手", 0.9) -- 5174
			else -- 5174
				self:flashSet( -- 5176
					(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 5176
					0.8 -- 5176
				) -- 5176
			end -- 5176
			self:emit("shotResolved", { -- 5178
				hit = true, -- 5179
				enemyIndex = i, -- 5179
				enemyX = e.x, -- 5179
				aimX = aim.x, -- 5179
				aimY = aim.y, -- 5179
				impactX = ox + dx * t, -- 5180
				impactY = oy + dy * t, -- 5180
				shield = true -- 5180
			}) -- 5180
			self:beginReload() -- 5182
			return -- 5183
		end -- 5183
		e.alive = false -- 5185
		e.hitT = 0.4 -- 5186
		killed = true -- 5187
		self:flashSet("命中", 0.6) -- 5188
		self:dropFor(e) -- 5189
		local lpRank = self:talentRank("lantern_pierce") -- 5190
		if reloadEffect == "light" and (weaponFx == "light" or lpRank > 0) then -- 5190
			local blindRadius = (weaponFx == "light" and 160 or 110) + 50 * lpRank -- 5192
			self:blindNearby(e, blindRadius, i) -- 5193
		end -- 5193
		if reloadEffect == "push" then -- 5193
			local pushRank = self:talentRank("push_force") -- 5196
			e.x = e.x + a.facing * (46 + 24 * pushRank) -- 5197
			if pushRank > 0 then -- 5197
				self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5199
			end -- 5199
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5201
		elseif reloadEffect == "echo" then -- 5201
			local echoRank = self:talentRank("echo_wide") -- 5203
			self:echoToSource(a, (weaponFx == "echo" and 2 or 1) + echoRank, 60 + 30 * echoRank) -- 5204
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 5205
		elseif reloadEffect == "light" then -- 5205
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 5207
		end -- 5207
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 5207
		self:damageProp(solid.box, 1) -- 5210
	else -- 5210
		self:flashSet("打空", 0.35) -- 5212
	end -- 5212
	if self.isCampaign then -- 5212
		self:beginReload() -- 5215
	end -- 5215
	self:emit("shotResolved", { -- 5217
		hit = hit, -- 5218
		enemyIndex = hit and hitEnemy.index or -1, -- 5219
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 5220
		aimX = aim.x, -- 5221
		aimY = aim.y, -- 5222
		impactX = ox + dx * t, -- 5223
		impactY = oy + dy * t -- 5224
	}) -- 5224
end -- 5111
function Play.prototype.staggerNearby(self, center, radius, delayTicks, skipIndex) -- 5229
	local i = 0 -- 5230
	do -- 5230
		i = 0 -- 5231
		while i < #self.enemies do -- 5231
			do -- 5231
				if i == skipIndex then -- 5231
					goto __continue874 -- 5233
				end -- 5233
				local e = self.enemies[i + 1] -- 5235
				if not e.alive or math.abs(e.x - center.x) > radius then -- 5235
					goto __continue874 -- 5237
				end -- 5237
				e.warnT = 0 -- 5239
				e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 5240
				local pushDir = e.x >= center.x and 1 or -1 -- 5241
				e.x = math.max( -- 5242
					self.room.minX + 20, -- 5242
					math.min(self.room.maxX - 20, e.x + pushDir * 22) -- 5242
				) -- 5242
			end -- 5242
			::__continue874:: -- 5242
			i = i + 1 -- 5231
		end -- 5231
	end -- 5231
end -- 5229
function Play.prototype.applyFireDanger(self, shotX) -- 5247
	local ____temp_140 = self.isCampaign and self.run.joined -- 5248
	if ____temp_140 then -- 5248
		local ____opt_135 = self.room.campaign -- 5248
		local ____temp_139 = (____opt_135 and ____opt_135.chapter) == "S" -- 5249
		if not ____temp_139 then -- 5249
			local ____opt_137 = self.room.campaign -- 5249
			____temp_139 = (____opt_137 and ____opt_137.chapter) == "C" -- 5249
		end -- 5249
		____temp_140 = ____temp_139 -- 5248
	end -- 5248
	local isStorySc = ____temp_140 -- 5248
	if self.room.key ~= "checkpoint" and not isStorySc or not self.partner.alive then -- 5248
		return -- 5251
	end -- 5251
	local dangerX = shotX -- 5253
	local best = -1 -- 5254
	local bestD = 1000000000 -- 5255
	local i = 0 -- 5256
	do -- 5256
		i = 0 -- 5257
		while i < #self.enemies do -- 5257
			do -- 5257
				local e = self.enemies[i + 1] -- 5258
				if not e.alive then -- 5258
					goto __continue880 -- 5260
				end -- 5260
				local d = math.abs(e.x - self.partner.x) -- 5262
				if d < bestD then -- 5262
					bestD = d -- 5264
					best = i -- 5265
				end -- 5265
			end -- 5265
			::__continue880:: -- 5265
			i = i + 1 -- 5257
		end -- 5257
	end -- 5257
	if best >= 0 then -- 5257
		dangerX = self.enemies[best + 1].x -- 5269
	end -- 5269
	if isStorySc and math.abs(dangerX - self.partner.x) > 260 then -- 5269
		return -- 5273
	end -- 5273
	local exposed = self:childExposed(dangerX) -- 5275
	local before = self.escort.fear -- 5276
	local dangerId = self.nextDangerId -- 5277
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 5278
	self.nextDangerId = self.nextDangerId + 1 -- 5279
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 5280
	if after > before then -- 5280
		self:flashSet( -- 5282
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 5282
			1 -- 5282
		) -- 5282
	elseif not exposed then -- 5282
		self:flashSet("枪声没够到她", 0.5) -- 5284
	end -- 5284
end -- 5247
function Play.prototype.childExposed(self, dangerX) -- 5289
	local c = self.partner -- 5290
	if not c.alive then -- 5290
		return false -- 5292
	end -- 5292
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 5292
		self.boxes, -- 5295
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 5295
	) then -- 5295
		return false -- 5296
	end -- 5296
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 5296
		return false -- 5299
	end -- 5299
	local toDanger = dangerX - c.x -- 5301
	local toPlayer = self.player.x - c.x -- 5302
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 5302
		return false -- 5305
	end -- 5305
	return true -- 5307
end -- 5289
function Play.prototype.raycastEnemies(self, ray) -- 5311
	local best = -1 -- 5312
	local bestI = -1 -- 5313
	do -- 5313
		local i = 0 -- 5314
		while i < #self.enemies do -- 5314
			do -- 5314
				local e = self.enemies[i + 1] -- 5315
				if not e.alive then -- 5315
					goto __continue895 -- 5317
				end -- 5317
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 5319
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 5320
				if t >= 0 and (best < 0 or t < best) then -- 5320
					best = t -- 5322
					bestI = i -- 5323
				end -- 5323
			end -- 5323
			::__continue895:: -- 5323
			i = i + 1 -- 5314
		end -- 5314
	end -- 5314
	return {t = best, index = bestI} -- 5326
end -- 5311
function Play.prototype.raycastWorld(self, ray) -- 5329
	return self:raycastSolid(ray).t -- 5330
end -- 5329
function Play.prototype.raycastSolid(self, ray) -- 5334
	local best = -1 -- 5335
	local bestBox = nil -- 5336
	for ____, box in ipairs(self.boxes) do -- 5337
		do -- 5337
			if box.broken == true or box.hidden == true then -- 5337
				goto __continue900 -- 5339
			end -- 5339
			local t = hitBox(ray, box) -- 5344
			if t > 2 and (best < 0 or t < best) then -- 5344
				best = t -- 5347
				bestBox = box -- 5348
			end -- 5348
		end -- 5348
		::__continue900:: -- 5348
	end -- 5348
	if ray.dy < 0 then -- 5348
		local t = -ray.y / ray.dy -- 5352
		if t >= 0 and (best < 0 or t < best) then -- 5352
			best = t -- 5354
			bestBox = nil -- 5355
		end -- 5355
	end -- 5355
	return {t = best, box = bestBox} -- 5358
end -- 5334
function Play.prototype.dropFor(self, e) -- 5362
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 5362
		return -- 5364
	end -- 5364
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 5364
		return -- 5367
	end -- 5367
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 5369
	local ____self_pickups_141 = self.pickups -- 5369
	____self_pickups_141[#____self_pickups_141 + 1] = { -- 5370
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 5371
		kind = e.drop, -- 5371
		x = e.x, -- 5371
		y = e.y, -- 5371
		depth = e.depth, -- 5372
		label = label .. " ×1" -- 5372
	} -- 5372
	self:log("掉落 " .. label) -- 5374
end -- 5362
function Play.prototype.damageProp(self, b, amount) -- 5378
	if b.breakable == nil or b.broken == true then -- 5378
		return -- 5380
	end -- 5380
	local ____b_breakable_142, ____hp_143 = b.breakable, "hp" -- 5380
	____b_breakable_142[____hp_143] = ____b_breakable_142[____hp_143] - amount -- 5382
	if b.breakable.hp > 0 then -- 5382
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 5384
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 5385
		return -- 5386
	end -- 5386
	b.broken = true -- 5388
	for ____, other in ipairs(self.boxes) do -- 5389
		if other.id ~= nil and other.id == b.id then -- 5389
			other.broken = true -- 5391
		end -- 5391
	end -- 5391
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 5394
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 5395
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 5396
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 5397
end -- 5378
function Play.prototype.slideDepth(self, a, distance) -- 5401
	a.depth = self:limitDepth(a, a.depth + distance) -- 5402
end -- 5401
function Play.prototype.limitDepth(self, a, target) -- 5405
	local road = self.room.depth -- 5406
	if road == nil or target == a.depth then -- 5406
		return a.depth -- 5408
	end -- 5408
	local next = math.max( -- 5410
		road.min, -- 5410
		math.min(road.max, target) -- 5410
	) -- 5410
	local half = a.w / 2 -- 5411
	for ____, b in ipairs(self.boxes) do -- 5412
		do -- 5412
			local footprint = b.depth -- 5413
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5413
				goto __continue918 -- 5418
			end -- 5418
			local front = footprint.min - ACTOR_DEPTH_HALF -- 5420
			local back = footprint.max + ACTOR_DEPTH_HALF -- 5421
			if a.depth <= front and next > front then -- 5421
				next = front -- 5423
			elseif a.depth >= back and next < back then -- 5423
				next = back -- 5425
			end -- 5425
		end -- 5425
		::__continue918:: -- 5425
	end -- 5425
	return next -- 5428
end -- 5405
function Play.prototype.cartLatchBounds(self) -- 5432
	if self.room.key ~= "outside" or self.cartDocked then -- 5432
		return nil -- 5433
	end -- 5433
	local arch = self.room.arch -- 5434
	local halfWidth = self.room.cart.bodyW / 2 -- 5435
	local left = math.max(arch.x0, self.cartAxle - halfWidth) -- 5436
	local right = math.min(arch.x1, self.cartAxle + halfWidth) -- 5437
	return right > left and Rect(left, arch.y, right - left, arch.h) or nil -- 5438
end -- 5432
function Play.prototype.slideX(self, a, dx) -- 5442
	local nx = a.x + dx -- 5443
	local half = a.w / 2 -- 5444
	local room = self.room -- 5445
	nx = math.max( -- 5446
		room.minX + half, -- 5446
		math.min(room.maxX - half, nx) -- 5446
	) -- 5446
	local i = 0 -- 5447
	do -- 5447
		i = 0 -- 5448
		while i < #self.boxes do -- 5448
			do -- 5448
				local b = self.boxes[i + 1] -- 5449
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5449
					goto __continue927 -- 5451
				end -- 5451
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5451
					goto __continue927 -- 5454
				end -- 5454
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5454
					goto __continue927 -- 5457
				end -- 5457
				if nx + half > b.x0 and nx - half < b.x1 then -- 5457
					if a.x <= b.x0 then -- 5457
						nx = b.x0 - half -- 5461
					elseif a.x >= b.x1 then -- 5461
						nx = b.x1 + half -- 5463
					else -- 5463
						nx = a.x -- 5465
					end -- 5465
				end -- 5465
			end -- 5465
			::__continue927:: -- 5465
			i = i + 1 -- 5448
		end -- 5448
	end -- 5448
	local latch = self:cartLatchBounds() -- 5469
	if latch ~= nil and a.y < latch.y + latch.height - 0.001 and nx + half > latch.x and nx - half < latch.x + latch.width then -- 5469
		if a.x <= latch.x then -- 5469
			nx = latch.x - half -- 5473
		elseif a.x >= latch.x + latch.width then -- 5473
			nx = latch.x + latch.width + half -- 5475
		else -- 5475
			nx = a.x -- 5477
		end -- 5477
	end -- 5477
	local arch = room.arch -- 5484
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 5484
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 5486
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 5486
			if a.x <= arch.x0 then -- 5486
				nx = arch.x0 - half -- 5489
			elseif a.x >= arch.x1 then -- 5489
				nx = arch.x1 + half -- 5491
			end -- 5491
		end -- 5491
	end -- 5491
	a.x = nx -- 5495
end -- 5442
function Play.prototype.fallY(self, a, dt) -- 5499
	a.vy = a.vy - ____exports.GRAVITY * dt -- 5500
	if a.vy < -900 then -- 5500
		a.vy = -900 -- 5502
	end -- 5502
	local ny = a.y + a.vy * dt -- 5504
	local half = a.w / 2 -- 5505
	if a.vy <= 0 then -- 5505
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 5508
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 5509
		if ny <= ground then -- 5509
			ny = ground -- 5511
			a.vy = 0 -- 5512
			a.onGround = true -- 5513
		else -- 5513
			a.onGround = false -- 5515
		end -- 5515
	else -- 5515
		a.onGround = false -- 5518
		local i = 0 -- 5519
		do -- 5519
			i = 0 -- 5520
			while i < #self.boxes do -- 5520
				do -- 5520
					local b = self.boxes[i + 1] -- 5521
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5521
						goto __continue950 -- 5523
					end -- 5523
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5523
						goto __continue950 -- 5526
					end -- 5526
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 5526
						goto __continue950 -- 5529
					end -- 5529
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 5529
						ny = b.y0 - a.h -- 5532
						a.vy = 0 -- 5533
					end -- 5533
				end -- 5533
				::__continue950:: -- 5533
				i = i + 1 -- 5520
			end -- 5520
		end -- 5520
	end -- 5520
	a.y = ny -- 5537
end -- 5499
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 5541
	if depth == nil then -- 5541
		depth = 0 -- 5541
	end -- 5541
	local g = -9999 -- 5542
	local i = 0 -- 5543
	do -- 5543
		i = 0 -- 5544
		while i < #self.floors do -- 5544
			local f = self.floors[i + 1] -- 5545
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 5545
				g = f.y1 -- 5547
			end -- 5547
			i = i + 1 -- 5544
		end -- 5544
	end -- 5544
	do -- 5544
		i = 0 -- 5550
		while i < #self.boxes do -- 5550
			do -- 5550
				local b = self.boxes[i + 1] -- 5551
				if b.broken == true or b.hidden == true or b.soft == true then -- 5551
					goto __continue960 -- 5553
				end -- 5553
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 5553
					g = b.y1 -- 5557
				end -- 5557
			end -- 5557
			::__continue960:: -- 5557
			i = i + 1 -- 5550
		end -- 5550
	end -- 5550
	return g -- 5560
end -- 5541
function Play.prototype.updateCamera(self, dt) -- 5563
	local p = self.player -- 5564
	local tx = p.x + p.facing * 30 -- 5565
	local ty = p.y + CAM_LOOK_UP -- 5566
	local k = math.min(1, CAM_FOLLOW * dt) -- 5567
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 5568
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 5569
end -- 5563
function Play.prototype.clampCamera(self, w, h) -- 5573
	local room = self.room -- 5574
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 5575
	local spanX = room.maxX - room.minX -- 5576
	if spanX <= halfW * 2 then -- 5576
		self.cam.x = (room.minX + room.maxX) / 2 -- 5578
	else -- 5578
		self.cam.x = math.max( -- 5580
			room.minX + halfW, -- 5580
			math.min(room.maxX - halfW, self.cam.x) -- 5580
		) -- 5580
	end -- 5580
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 5583
	local spanY = room.height -- 5584
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 5585
	if spanY <= halfH * 2 then -- 5585
		self.cam.y = camY -- 5587
	else -- 5587
		self.cam.y = math.max( -- 5589
			camY, -- 5589
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 5589
		) -- 5589
	end -- 5589
end -- 5573
function Play.prototype.flashSet(self, text, t) -- 5593
	self.flash = text -- 5594
	self.flashT = t -- 5595
end -- 5593
function Play.prototype.statusText(self) -- 5599
	local p = self.player -- 5600
	local parts = {} -- 5601
	local who = self.childMode and "小满" or "周戍" -- 5602
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 5603
	if self.room.key == "prologue" then -- 5603
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5606
		if self.phase == "prologue-wake" then -- 5606
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 5608
		elseif self.phase == "prologue-shadow" then -- 5608
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 5610
		elseif self.phase == "prologue-escape" then -- 5610
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 5612
		elseif self.phase == "prologue-hide" then -- 5612
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 5614
		elseif self.phase == "prologue-wait" then -- 5614
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 5616
		elseif self.phase == "prologue-give" then -- 5616
			parts[#parts + 1] = (("递物 " .. tostring(self.phaseTick)) .. "/") .. tostring(____exports.PROLOGUE_GIVE_TICKS) -- 5618
		else -- 5618
			parts[#parts + 1] = "跟随" -- 5620
		end -- 5620
		if self.paused then -- 5620
			parts[#parts + 1] = "已暂停" -- 5623
		end -- 5623
		return table.concat(parts, " · ") -- 5625
	end -- 5625
	if self.room.key == "street" then -- 5625
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5628
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5629
		if self.paused then -- 5629
			parts[#parts + 1] = "已暂停" -- 5631
		end -- 5631
		return table.concat(parts, " · ") -- 5633
	end -- 5633
	if self.room.key == "gate" then -- 5633
		local ____temp_144 -- 5636
		if self.room.story == nil then -- 5636
			____temp_144 = nil -- 5636
		else -- 5636
			____temp_144 = self.room.story.gate -- 5636
		end -- 5636
		local g = ____temp_144 -- 5636
		if g ~= nil then -- 5636
			parts[#parts + 1] = self:gateLabel() -- 5638
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 5639
				0, -- 5640
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 5640
			))) .. " 秒" -- 5640
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5641
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5642
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 5643
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 5644
			if self.gateFailCount > 0 then -- 5644
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 5646
			end -- 5646
			if self.flash ~= "" then -- 5646
				parts[#parts + 1] = self.flash -- 5649
			end -- 5649
		end -- 5649
		if self.paused then -- 5649
			parts[#parts + 1] = "已暂停" -- 5653
		end -- 5653
		return table.concat(parts, " · ") -- 5655
	end -- 5655
	if self.room.key == "forest" then -- 5655
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5658
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5659
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5660
		if self.caughtT > 0 then -- 5660
			parts[#parts + 1] = "复位中" -- 5662
		end -- 5662
		if self.paused then -- 5662
			parts[#parts + 1] = "已暂停" -- 5665
		end -- 5665
		return table.concat(parts, " · ") -- 5667
	end -- 5667
	if self.room.key == "tower" then -- 5667
		if self.phase == "tower-wait" then -- 5667
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5671
		elseif self.phase == "tower-knock" then -- 5671
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5673
		elseif self.phase == "tower-enter" then -- 5673
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5675
		elseif self.phase == "tower-desk" then -- 5675
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5677
		elseif self.phase == "tower-given" then -- 5677
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5679
		else -- 5679
			parts[#parts + 1] = "片尾" -- 5681
		end -- 5681
		if self.paused then -- 5681
			parts[#parts + 1] = "已暂停" -- 5684
		end -- 5684
		return table.concat(parts, " · ") -- 5686
	end -- 5686
	if self.room.key == "village" then -- 5686
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5689
		if self.hasBottle then -- 5689
			parts[#parts + 1] = "有瓶" -- 5691
		elseif self.bottleFly ~= nil then -- 5691
			parts[#parts + 1] = "瓶在飞" -- 5693
		else -- 5693
			parts[#parts + 1] = "空手" -- 5695
		end -- 5695
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5697
		if self.scavChase then -- 5697
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5699
		end -- 5699
		if self.passed then -- 5699
			parts[#parts + 1] = "已过通行线" -- 5702
		end -- 5702
		if self.paused then -- 5702
			parts[#parts + 1] = "已暂停" -- 5705
		end -- 5705
		return table.concat(parts, " · ") -- 5707
	end -- 5707
	local isChild = self.childMode -- 5710
	if isChild then -- 5710
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5712
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5713
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5714
	else -- 5714
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5716
		if p.rollT > 0 then -- 5716
			parts[#parts + 1] = "翻滚中" -- 5718
		end -- 5718
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5720
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5721
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5722
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5723
	end -- 5723
	if self.checkpoint >= 0 then -- 5723
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5726
	end -- 5726
	if self.paused then -- 5726
		parts[#parts + 1] = "已暂停" -- 5729
	end -- 5729
	return table.concat(parts, " · ") -- 5731
end -- 5599
function Play.prototype.aliveEnemies(self) -- 5735
	local n = 0 -- 5736
	local i = 0 -- 5737
	do -- 5737
		i = 0 -- 5738
		while i < #self.enemies do -- 5738
			if self.enemies[i + 1].alive then -- 5738
				n = n + 1 -- 5740
			end -- 5740
			i = i + 1 -- 5738
		end -- 5738
	end -- 5738
	return n -- 5743
end -- 5735
function Play.prototype.threatened(self) -- 5748
	do -- 5748
		local i = 0 -- 5749
		while i < #self.enemies do -- 5749
			local e = self.enemies[i + 1] -- 5750
			if e.alive and e.warnT > 0 then -- 5750
				return true -- 5752
			end -- 5752
			i = i + 1 -- 5749
		end -- 5749
	end -- 5749
	return false -- 5755
end -- 5748
function Play.prototype.gateSecondsLeft(self) -- 5758
	local ____temp_145 -- 5759
	if self.room.story == nil then -- 5759
		____temp_145 = nil -- 5759
	else -- 5759
		____temp_145 = self.room.story.gate -- 5759
	end -- 5759
	local g = ____temp_145 -- 5759
	if g == nil then -- 5759
		return 0 -- 5761
	end -- 5761
	return math.max( -- 5763
		0, -- 5763
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5763
	) -- 5763
end -- 5758
function Play.prototype.gateLabel(self) -- 5766
	if self.phase == "gate-idle" then -- 5766
		return "待就位" -- 5768
	end -- 5768
	if self.phase == "gate-hold" then -- 5768
		return "守点中" -- 5771
	end -- 5771
	if self.phase == "gate-send" then -- 5771
		return "送别" -- 5774
	end -- 5774
	if self.phase == "gate-farewell" then -- 5774
		return "嘱咐 " .. tostring(self.phaseTick) -- 5777
	end -- 5777
	if self.phase == "gate-count" then -- 5777
		return "数数 " .. tostring(self.countTick) -- 5780
	end -- 5780
	return "她走" -- 5782
end -- 5766
function Play.prototype.dogLabel(self) -- 5786
	if self.dogState == "ear" then -- 5786
		return "转耳" -- 5788
	end -- 5788
	if self.dogState == "chase" then -- 5788
		return "追" -- 5791
	end -- 5791
	if self.dogState == "sniff" then -- 5791
		return "停" -- 5794
	end -- 5794
	if self.dogState == "back" then -- 5794
		return "回线" -- 5797
	end -- 5797
	return "巡逻" -- 5799
end -- 5786
function Play.prototype.doorXOf(self) -- 5802
	local ____temp_146 -- 5803
	if self.room.story == nil then -- 5803
		____temp_146 = nil -- 5803
	else -- 5803
		____temp_146 = self.room.story.tower -- 5803
	end -- 5803
	local t = ____temp_146 -- 5803
	return t == nil and 0 or t.doorX -- 5804
end -- 5802
function Play.prototype.scavLabel(self) -- 5808
	if self.scavState == "chase" then -- 5808
		return "追" -- 5810
	end -- 5810
	if self.scavState == "turn" then -- 5810
		return "转头" -- 5813
	end -- 5813
	if self.scavState == "walk" then -- 5813
		return "赶来" -- 5816
	end -- 5816
	if self.scavState == "stall" then -- 5816
		return "停住" -- 5819
	end -- 5819
	if self.scavState == "back" then -- 5819
		return "回位" -- 5822
	end -- 5822
	return "巡逻" -- 5824
end -- 5808
function Play.prototype.hintText(self) -- 5828
	if self.paused then -- 5828
		return "Esc 继续 · R 重置" -- 5830
	end -- 5830
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5830
		if self:threatened() then -- 5830
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5836
		end -- 5836
		if self.coverHug then -- 5836
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5839
		end -- 5839
		if self.coverNear then -- 5839
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5842
		end -- 5842
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5844
	end -- 5844
	if self.flash ~= "" then -- 5844
		return self.flash -- 5847
	end -- 5847
	if self.room.key == "prologue" then -- 5847
		if self.phase == "prologue-wake" then -- 5847
			return "父亲在门外唤 · 小满睁眼" -- 5851
		end -- 5851
		if self.phase == "prologue-shadow" then -- 5851
			return "墙上两道人影 · 碗滚到脚边" -- 5854
		end -- 5854
		if self.phase == "prologue-escape" then -- 5854
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5857
		end -- 5857
		if self.phase == "prologue-hide" then -- 5857
			return "柜门合上 · 屏住呼吸" -- 5860
		end -- 5860
		if self.phase == "prologue-wait" then -- 5860
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5863
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5864
		end -- 5864
		if self.phase == "prologue-give" then -- 5864
			return ((("递物 " .. tostring(self.phaseTick)) .. " / ") .. tostring(____exports.PROLOGUE_GIVE_TICKS)) .. " 拍 · 站着别动" -- 5867
		end -- 5867
		return "她跟着你了 · 两人一起走到门口 680" -- 5869
	end -- 5869
	if self.room.key == "street" then -- 5869
		if self:aliveEnemies() > 0 then -- 5869
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5873
		end -- 5873
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5875
	end -- 5875
	if self.room.key == "gate" then -- 5875
		local ____temp_147 -- 5878
		if self.room.story == nil then -- 5878
			____temp_147 = nil -- 5878
		else -- 5878
			____temp_147 = self.room.story.gate -- 5878
		end -- 5878
		local g = ____temp_147 -- 5878
		if g ~= nil then -- 5878
			if self.phase == "gate-idle" then -- 5878
				if self.gateNeedConfirm then -- 5878
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5882
				end -- 5882
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5884
			end -- 5884
			if self.phase == "gate-hold" then -- 5884
				if self.coveredFlash > 0 then -- 5884
					return "掩体挡下了这一枪 · 别露头" -- 5888
				end -- 5888
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5890
			end -- 5890
			if self.phase == "gate-send" then -- 5890
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5893
			end -- 5893
			if self.phase == "gate-farewell" then -- 5893
				return "城门送别 · 嘱咐她慢慢数到二十" -- 5896
			end -- 5896
			if self.phase == "gate-count" then -- 5896
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5896
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5900
				end -- 5900
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5902
			end -- 5902
			return "她自己走 · 跟着出城门 1120" -- 5904
		end -- 5904
	end -- 5904
	if self.room.key == "forest" then -- 5904
		if self.dogState == "chase" then -- 5904
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5909
		end -- 5909
		if self.dogState == "ear" then -- 5909
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5912
		end -- 5912
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5914
	end -- 5914
	if self.room.key == "tower" then -- 5914
		if self.phase == "tower-wait" then -- 5914
			return "走到门前 445 点一次 E 敲两下" -- 5918
		end -- 5918
		if self.phase == "tower-knock" then -- 5918
			return "敲两下 · 等门开" -- 5921
		end -- 5921
		if self.phase == "tower-given" then -- 5921
			return "递交针套和纸条 · 看登记簿最后一行" -- 5924
		end -- 5924
		return "片尾 · 点 E 再玩一次，回到序章" -- 5926
	end -- 5926
	if self.room.key == "village" then -- 5926
		if self.bottleFly ~= nil then -- 5926
			return "等瓶子落地 · 触地才发声" -- 5930
		end -- 5930
		if self.hasBottle then -- 5930
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5933
		end -- 5933
		if self.passed then -- 5933
			return "已过第一院 · R 重置可再来一遍" -- 5936
		end -- 5936
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5938
	end -- 5938
	if self.room.key == "outside" then -- 5938
		if self.focusCart then -- 5938
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5942
		end -- 5942
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5944
	end -- 5944
	if self.escort.state == "frozen" then -- 5944
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5944
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5948
		end -- 5948
		return "小满吓住了 · 走过去，靠近再点 E" -- 5950
	end -- 5950
	if self.escort.state == "calming" then -- 5950
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5953
	end -- 5953
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5955
end -- 5828
function Play.prototype.draw(self, draw, w, h) -- 5960
	self.viewW = w -- 5961
	self.viewH = h -- 5962
	self.view = ____exports.computeViewport(w, h) -- 5963
	self:clampCamera(w, h) -- 5964
	draw:clear() -- 5965
	draw:drawRect( -- 5967
		Rect(0, 0, w, h), -- 5967
		BG_VOID -- 5967
	) -- 5967
	local box = self:canvasRect(w, h) -- 5968
	draw:drawRect(box, BG_FAR) -- 5969
	draw:drawRect( -- 5970
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 5970
		BG_MID -- 5970
	) -- 5970
	self:drawFloors(draw, w, h) -- 5972
	self:drawSolids(draw, w, h) -- 5973
	self:drawZones(draw, w, h) -- 5974
	self:drawArch(draw, w, h) -- 5975
	self:drawCart(draw, w, h) -- 5976
	self:drawCampaignProps(draw, w, h) -- 5977
	self:drawActors(draw, w, h) -- 5978
	self:drawTrace(draw, w, h) -- 5979
	self:drawAim(draw, w, h) -- 5980
end -- 5960
function Play.prototype.canvasRect(self, w, h) -- 5984
	local v = self.view -- 5985
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 5986
end -- 5984
function Play.prototype.px(self, n) -- 5990
	return n * self.view.zoom -- 5991
end -- 5990
function Play.prototype.sx(self, wx, w) -- 5995
	local v = self.view -- 5996
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 5997
	return v.ox + lx * v.zoom -- 5998
end -- 5995
function Play.prototype.sy(self, wy, h) -- 6002
	local v = self.view -- 6003
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 6004
	return v.oy + ly * v.zoom -- 6005
end -- 6002
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 6008
	local px0 = self:sx(x0, w) -- 6009
	local px1 = self:sx(x1, w) -- 6010
	local py0 = self:sy(y0, h) -- 6011
	local py1 = self:sy(y1, h) -- 6012
	if px1 <= px0 or py1 <= py0 then -- 6012
		return -- 6014
	end -- 6014
	draw:drawRect( -- 6016
		Rect(px0, py0, px1 - px0, py1 - py0), -- 6016
		color -- 6016
	) -- 6016
end -- 6008
function Play.prototype.drawFloors(self, draw, w, h) -- 6019
	local i = 0 -- 6020
	do -- 6020
		i = 0 -- 6021
		while i < #self.room.floors do -- 6021
			local f = self.room.floors[i + 1] -- 6022
			local ____temp_148 -- 6023
			if f.y == 0 then -- 6023
				____temp_148 = self.room.depth -- 6023
			else -- 6023
				____temp_148 = nil -- 6023
			end -- 6023
			local road = ____temp_148 -- 6023
			local y = self:sy(f.y + (road and road.min or 0), h) -- 6024
			local x0 = self:sx(f.x0, w) -- 6025
			local x1 = self:sx(f.x1, w) -- 6026
			local deck = self:px(5) -- 6027
			if road ~= nil then -- 6027
				local back = self:sy(f.y + road.max, h) -- 6029
				draw:drawRect( -- 6030
					Rect(x0, y, x1 - x0, back - y), -- 6030
					FLOOR_DECK, -- 6030
					self:px(1), -- 6030
					SOLID_EDGE -- 6030
				) -- 6030
			end -- 6030
			draw:drawRect( -- 6032
				Rect(x0, y - deck, x1 - x0, deck), -- 6032
				FLOOR_DECK -- 6032
			) -- 6032
			draw:drawSegment( -- 6033
				Vec2(x0, y), -- 6033
				Vec2(x1, y), -- 6033
				self:px(1), -- 6033
				GROUND -- 6033
			) -- 6033
			i = i + 1 -- 6021
		end -- 6021
	end -- 6021
end -- 6019
function Play.prototype.drawSolids(self, draw, w, h) -- 6037
	local i = 0 -- 6038
	do -- 6038
		i = 0 -- 6039
		while i < #self.boxes do -- 6039
			do -- 6039
				local b = self.boxes[i + 1] -- 6040
				if b.id == "braced_shield" or b.hidden == true then -- 6040
					goto __continue1093 -- 6042
				end -- 6042
				if b.broken == true then -- 6042
					if b.breakable ~= nil then -- 6042
						local gy = self:sy(b.y0, h) -- 6047
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 6048
						local k = 0 -- 6049
						do -- 6049
							k = 0 -- 6050
							while k < 3 do -- 6050
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 6051
								draw:drawSegment( -- 6052
									Vec2( -- 6052
										gx - self:px(4), -- 6052
										gy + self:px(k % 2) -- 6052
									), -- 6052
									Vec2( -- 6052
										gx + self:px(5), -- 6052
										gy + self:px(k % 2) -- 6052
									), -- 6052
									self:px(1), -- 6052
									rgb -- 6052
								) -- 6052
								k = k + 1 -- 6050
							end -- 6050
						end -- 6050
					end -- 6050
					goto __continue1093 -- 6055
				end -- 6055
				local ____opt_151 = b.depth -- 6055
				local front = ____opt_151 and ____opt_151.min or 0 -- 6057
				local ____opt_153 = b.depth -- 6057
				local back = ____opt_153 and ____opt_153.max or 0 -- 6058
				local fill = SOLID_FILL -- 6059
				local line = SOLID_EDGE -- 6060
				if b.soft == true then -- 6060
					fill = SOFT -- 6062
					line = SOFT_LINE -- 6063
				elseif b.breakable ~= nil then -- 6063
					line = DANGER_LINE -- 6065
					fill = Color(0.3, 0.24, 0.16, 1) -- 6066
				elseif b.interact ~= nil then -- 6066
					line = PASS_LINE -- 6068
				end -- 6068
				self:drawBox( -- 6070
					draw, -- 6070
					w, -- 6070
					h, -- 6070
					b.x0, -- 6070
					b.x1, -- 6070
					b.y0 + front, -- 6070
					b.y1 + back, -- 6070
					fill -- 6070
				) -- 6070
				draw:drawSegment( -- 6071
					Vec2( -- 6071
						self:sx(b.x0, w), -- 6071
						self:sy(b.y1 + front, h) -- 6071
					), -- 6071
					Vec2( -- 6072
						self:sx(b.x1, w), -- 6072
						self:sy(b.y1 + front, h) -- 6072
					), -- 6072
					self:px(1), -- 6072
					line -- 6072
				) -- 6072
				if b.breakable ~= nil then -- 6072
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 6075
					local cyp = self:sy(b.y1 + front, h) -- 6076
					draw:drawSegment( -- 6077
						Vec2( -- 6077
							cxp - self:px(4), -- 6077
							cyp + self:px(1) -- 6077
						), -- 6077
						Vec2( -- 6077
							cxp + self:px(3), -- 6077
							cyp + self:px(5) -- 6077
						), -- 6077
						self:px(1), -- 6077
						line -- 6077
					) -- 6077
				end -- 6077
			end -- 6077
			::__continue1093:: -- 6077
			i = i + 1 -- 6039
		end -- 6039
	end -- 6039
end -- 6037
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 6083
	local i = 0 -- 6084
	do -- 6084
		i = 0 -- 6085
		while i < #self.pickups do -- 6085
			do -- 6085
				local pk = self.pickups[i + 1] -- 6086
				if self.run.taken[pk.id] == true then -- 6086
					goto __continue1105 -- 6088
				end -- 6088
				local gy = pk.y + (pk.depth or 0) -- 6090
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 6091
				draw:drawRect( -- 6092
					Rect( -- 6092
						self:sx(pk.x - 5, w), -- 6092
						self:sy(gy + 12 + bob, h), -- 6092
						self:px(10), -- 6092
						self:px(10) -- 6092
					), -- 6092
					Color(0.84, 0.7, 0.3, 1) -- 6093
				) -- 6093
				draw:drawSegment( -- 6094
					Vec2( -- 6094
						self:sx(pk.x - 5, w), -- 6094
						self:sy(gy + 12 + bob, h) -- 6094
					), -- 6094
					Vec2( -- 6095
						self:sx(pk.x + 5, w), -- 6095
						self:sy(gy + 12 + bob, h) -- 6095
					), -- 6095
					self:px(1), -- 6095
					Color(0.95, 0.86, 0.52, 1) -- 6095
				) -- 6095
			end -- 6095
			::__continue1105:: -- 6095
			i = i + 1 -- 6085
		end -- 6085
	end -- 6085
	if self.bracedShield ~= nil then -- 6085
		local sh = self.bracedShield -- 6098
		draw:drawRect( -- 6099
			Rect( -- 6099
				self:sx(sh.x - sh.w / 2, w), -- 6099
				self:sy(sh.y, h), -- 6099
				self:px(sh.w), -- 6099
				self:px(sh.h) -- 6099
			), -- 6099
			Color(0.42, 0.4, 0.34, 1) -- 6100
		) -- 6100
		draw:drawSegment( -- 6101
			Vec2( -- 6101
				self:sx(sh.x - sh.w / 2, w), -- 6101
				self:sy(sh.y + sh.h, h) -- 6101
			), -- 6101
			Vec2( -- 6102
				self:sx(sh.x + sh.w / 2, w), -- 6102
				self:sy(sh.y + sh.h, h) -- 6102
			), -- 6102
			self:px(1), -- 6102
			Color(0.74, 0.72, 0.62, 1) -- 6102
		) -- 6102
	end -- 6102
end -- 6083
function Play.prototype.drawZones(self, draw, w, h) -- 6106
	local i = 0 -- 6107
	do -- 6107
		i = 0 -- 6108
		while i < #self.room.zones do -- 6108
			local z = self.room.zones[i + 1] -- 6109
			local fill = DANGER -- 6110
			local line = DANGER_LINE -- 6111
			if z.tint == 2 then -- 6111
				fill = SOFT -- 6113
				line = SOFT_LINE -- 6114
			elseif z.tint == 3 then -- 6114
				fill = BRICK -- 6116
				line = BRICK_LINE -- 6117
			elseif z.tint == 4 then -- 6117
				fill = PASS -- 6119
				line = PASS_LINE -- 6120
			end -- 6120
			self:drawBox( -- 6122
				draw, -- 6122
				w, -- 6122
				h, -- 6122
				z.x0, -- 6122
				z.x1, -- 6122
				z.y, -- 6122
				z.y + z.h, -- 6122
				fill -- 6122
			) -- 6122
			draw:drawSegment( -- 6123
				Vec2( -- 6123
					self:sx(z.x0, w), -- 6123
					self:sy(z.y, h) -- 6123
				), -- 6123
				Vec2( -- 6123
					self:sx(z.x0, w), -- 6123
					self:sy(z.y + z.h, h) -- 6123
				), -- 6123
				self:px(1), -- 6123
				line -- 6123
			) -- 6123
			draw:drawSegment( -- 6124
				Vec2( -- 6124
					self:sx(z.x1, w), -- 6124
					self:sy(z.y, h) -- 6124
				), -- 6124
				Vec2( -- 6124
					self:sx(z.x1, w), -- 6124
					self:sy(z.y + z.h, h) -- 6124
				), -- 6124
				self:px(1), -- 6124
				line -- 6124
			) -- 6124
			i = i + 1 -- 6108
		end -- 6108
	end -- 6108
end -- 6106
function Play.prototype.drawArch(self, draw, w, h) -- 6128
	local a = self.room.arch -- 6129
	if a.h <= 0 then -- 6129
		return -- 6131
	end -- 6131
	self:drawBox( -- 6133
		draw, -- 6133
		w, -- 6133
		h, -- 6133
		a.x0, -- 6133
		a.x1, -- 6133
		a.y, -- 6133
		a.y + a.h, -- 6133
		HOLE_FILL -- 6133
	) -- 6133
	draw:drawSegment( -- 6134
		Vec2( -- 6134
			self:sx(a.x0, w), -- 6134
			self:sy(a.y + a.h, h) -- 6134
		), -- 6134
		Vec2( -- 6134
			self:sx(a.x1, w), -- 6134
			self:sy(a.y + a.h, h) -- 6134
		), -- 6134
		self:px(1), -- 6134
		SOLID_EDGE -- 6134
	) -- 6134
	draw:drawSegment( -- 6135
		Vec2( -- 6135
			self:sx(a.x0, w), -- 6135
			self:sy(a.y, h) -- 6135
		), -- 6135
		Vec2( -- 6135
			self:sx(a.x0, w), -- 6135
			self:sy(a.y + a.h, h) -- 6135
		), -- 6135
		self:px(1), -- 6135
		SOLID_EDGE -- 6135
	) -- 6135
	draw:drawSegment( -- 6136
		Vec2( -- 6136
			self:sx(a.x1, w), -- 6136
			self:sy(a.y, h) -- 6136
		), -- 6136
		Vec2( -- 6136
			self:sx(a.x1, w), -- 6136
			self:sy(a.y + a.h, h) -- 6136
		), -- 6136
		self:px(1), -- 6136
		SOLID_EDGE -- 6136
	) -- 6136
end -- 6128
function Play.prototype.drawCart(self, draw, w, h) -- 6139
	local c = self.room.cart -- 6140
	if c.bodyW <= 0 then -- 6140
		return -- 6142
	end -- 6142
	drawCartShape( -- 6144
		draw, -- 6144
		self, -- 6144
		w, -- 6144
		h, -- 6144
		c, -- 6144
		self.cartAxle -- 6144
	) -- 6144
	draw:drawRect( -- 6145
		Rect( -- 6145
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 6145
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 6145
			self:px(2), -- 6145
			self:px(40) -- 6145
		), -- 6145
		STAND -- 6145
	) -- 6145
end -- 6139
function Play.prototype.drawActors(self, draw, w, h) -- 6148
	local p = self.player -- 6149
	local isChild = self.childMode -- 6150
	local footY = p.y + p.depth * DEPTH_Y_SCALE -- 6151
	if p.covered then -- 6151
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 6154
		draw:drawSegment( -- 6155
			Vec2( -- 6155
				self:sx(edge, w), -- 6155
				self:sy(footY + 8, h) -- 6155
			), -- 6155
			Vec2( -- 6155
				self:sx(edge, w), -- 6155
				self:sy(footY + p.h * 0.62, h) -- 6155
			), -- 6155
			self:px(2), -- 6155
			STAND -- 6155
		) -- 6155
		draw:drawSegment( -- 6157
			Vec2( -- 6157
				self:sx(p.x - 8, w), -- 6157
				self:sy(footY + p.h + 3, h) -- 6157
			), -- 6157
			Vec2( -- 6157
				self:sx(p.x + 8, w), -- 6157
				self:sy(footY + p.h + 3, h) -- 6157
			), -- 6157
			self:px(2), -- 6157
			STAND -- 6157
		) -- 6157
	elseif self.coverNear and not isChild then -- 6157
		draw:drawRect( -- 6160
			Rect( -- 6160
				self:sx(p.x - 3, w), -- 6160
				self:sy(footY + 1, h), -- 6160
				self:px(3), -- 6160
				self:px(3) -- 6160
			), -- 6160
			STAND -- 6160
		) -- 6160
	end -- 6160
	drawFigure( -- 6162
		draw, -- 6162
		self, -- 6162
		w, -- 6162
		h, -- 6162
		p, -- 6162
		isChild and CHILD_BODY or SOLDIER_BODY, -- 6162
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 6162
	) -- 6162
	local q = self.partner -- 6163
	if q.alive then -- 6163
		local childPartner = q.w == CHILD_W -- 6165
		drawFigure( -- 6166
			draw, -- 6166
			self, -- 6166
			w, -- 6166
			h, -- 6166
			q, -- 6166
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 6166
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 6166
		) -- 6166
	end -- 6166
	local i = 0 -- 6168
	do -- 6168
		i = 0 -- 6169
		while i < #self.enemies do -- 6169
			local e = self.enemies[i + 1] -- 6170
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 6171
			local enemyY = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 6172
			self:drawBox( -- 6173
				draw, -- 6173
				w, -- 6173
				h, -- 6173
				e.x - e.w / 2, -- 6173
				e.x + e.w / 2, -- 6173
				enemyY, -- 6173
				enemyY + e.h, -- 6173
				col -- 6173
			) -- 6173
			if e.alive then -- 6173
				local ef = p.x >= e.x and 1 or -1 -- 6175
				if e.kind == "shield" then -- 6175
					local sh = (e.shieldHp or 0) > 0 -- 6177
					draw:drawRect( -- 6178
						Rect( -- 6178
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 6178
							self:sy(enemyY, h), -- 6178
							self:px(6), -- 6178
							self:px(64) -- 6178
						), -- 6178
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 6179
					) -- 6179
				elseif e.kind == "breaker" then -- 6179
					draw:drawSegment( -- 6181
						Vec2( -- 6181
							self:sx(e.x + ef * 12, w), -- 6181
							self:sy(enemyY + 8, h) -- 6181
						), -- 6181
						Vec2( -- 6182
							self:sx(e.x + ef * 22, w), -- 6182
							self:sy(enemyY + 46, h) -- 6182
						), -- 6182
						self:px(3), -- 6182
						Color(0.5, 0.36, 0.22, 1) -- 6182
					) -- 6182
				end -- 6182
			end -- 6182
			if e.alive and e.warnT > 0 then -- 6182
				local gunX = self:sx(e.x, w) -- 6187
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 6188
				local aimX = self:sx(p.x, w) -- 6189
				local aimY = self:sy(footY + p.h * 0.55, h) -- 6190
				local seg = 8 -- 6191
				local s = 0 -- 6192
				do -- 6192
					s = 0 -- 6193
					while s < seg do -- 6193
						local t0 = s / seg -- 6194
						local t1 = (s + 1) / seg -- 6195
						draw:drawSegment( -- 6196
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 6197
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 6198
							self:px(1), -- 6199
							DANGER -- 6199
						) -- 6199
						s = s + 2 -- 6193
					end -- 6193
				end -- 6193
			end -- 6193
			i = i + 1 -- 6169
		end -- 6169
	end -- 6169
	local k = 0 -- 6204
	do -- 6204
		k = 0 -- 6205
		while k < #self.room.marks do -- 6205
			do -- 6205
				local m = self.room.marks[k + 1] -- 6206
				if m.kind ~= 0 then -- 6206
					goto __continue1131 -- 6208
				end -- 6208
				local on = self.checkpoint == m.x -- 6210
				local x = self:sx(m.x, w) -- 6211
				local y = self:sy(m.y, h) -- 6212
				draw:drawSegment( -- 6213
					Vec2(x, y), -- 6213
					Vec2( -- 6213
						x, -- 6213
						y + self:px(35) -- 6213
					), -- 6213
					self:px(1), -- 6213
					on and CHECK or INK_DIM -- 6213
				) -- 6213
				draw:drawDot( -- 6214
					Vec2( -- 6214
						x, -- 6214
						y + self:px(35) -- 6214
					), -- 6214
					self:px(2), -- 6214
					on and CHECK or INK_DIM -- 6214
				) -- 6214
			end -- 6214
			::__continue1131:: -- 6214
			k = k + 1 -- 6205
		end -- 6205
	end -- 6205
	local j = 0 -- 6218
	do -- 6218
		j = 0 -- 6219
		while j < #self.room.marks do -- 6219
			do -- 6219
				local m = self.room.marks[j + 1] -- 6220
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 6220
					goto __continue1134 -- 6222
				end -- 6222
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 6222
					goto __continue1134 -- 6226
				end -- 6226
				local col = STAND -- 6228
				if m.kind == 4 then -- 6228
					col = PASS_LINE -- 6230
				elseif m.kind == 5 then -- 6230
					col = BRICK_LINE -- 6232
				end -- 6232
				local mx = self:sx(m.x, w) -- 6234
				local my = self:sy(m.y, h) -- 6235
				draw:drawSegment( -- 6236
					Vec2(mx, my), -- 6236
					Vec2( -- 6236
						mx, -- 6236
						my + self:px(24) -- 6236
					), -- 6236
					self:px(1), -- 6236
					col -- 6236
				) -- 6236
			end -- 6236
			::__continue1134:: -- 6236
			j = j + 1 -- 6219
		end -- 6219
	end -- 6219
	local t = 0 -- 6239
	do -- 6239
		t = 0 -- 6240
		while t < #self.room.marks do -- 6240
			do -- 6240
				local m = self.room.marks[t + 1] -- 6241
				if m.kind ~= 6 then -- 6241
					goto __continue1140 -- 6243
				end -- 6243
				local mx = self:sx(m.x, w) -- 6245
				local my = self:sy(m.y, h) -- 6246
				draw:drawSegment( -- 6247
					Vec2(mx, my), -- 6247
					Vec2( -- 6247
						mx, -- 6247
						my + self:px(30) -- 6247
					), -- 6247
					self:px(1), -- 6247
					INK_DIM -- 6247
				) -- 6247
				self:drawBox( -- 6248
					draw, -- 6248
					w, -- 6248
					h, -- 6248
					m.x - 5, -- 6248
					m.x + 5, -- 6248
					m.y + 30, -- 6248
					m.y + 40, -- 6248
					CHECK -- 6248
				) -- 6248
			end -- 6248
			::__continue1140:: -- 6248
			t = t + 1 -- 6240
		end -- 6240
	end -- 6240
	if self.room.key == "village" then -- 6240
		self:drawVillage(draw, w, h) -- 6251
	end -- 6251
	if self.room.key == "forest" then -- 6251
		self:drawDog(draw, w, h) -- 6254
	end -- 6254
end -- 6148
function Play.prototype.drawDog(self, draw, w, h) -- 6259
	local x = self.dogX -- 6260
	self:drawBox( -- 6261
		draw, -- 6261
		w, -- 6261
		h, -- 6261
		x - 14, -- 6261
		x + 14, -- 6261
		0, -- 6261
		20, -- 6261
		SCAV_BODY -- 6261
	) -- 6261
	self:drawBox( -- 6262
		draw, -- 6262
		w, -- 6262
		h, -- 6262
		x - 10, -- 6262
		x - 2, -- 6262
		20, -- 6262
		30, -- 6262
		SCAV_BODY -- 6262
	) -- 6262
	self:drawBox( -- 6263
		draw, -- 6263
		w, -- 6263
		h, -- 6263
		x + 2, -- 6263
		x + 10, -- 6263
		20, -- 6263
		30, -- 6263
		SCAV_HEAD -- 6263
	) -- 6263
	if self.dogState == "ear" or self.dogState == "chase" then -- 6263
		draw:drawSegment( -- 6265
			Vec2( -- 6265
				self:sx(x, w), -- 6265
				self:sy(30, h) -- 6265
			), -- 6265
			Vec2( -- 6266
				self:sx(x, w), -- 6266
				self:sy(40, h) -- 6266
			), -- 6266
			self:px(1), -- 6266
			DANGER -- 6266
		) -- 6266
	end -- 6266
end -- 6259
function Play.prototype.drawVillage(self, draw, w, h) -- 6271
	local bottle = self.room.bottle -- 6272
	if bottle ~= nil then -- 6272
		self:drawBox( -- 6274
			draw, -- 6274
			w, -- 6274
			h, -- 6274
			bottle.x - 14, -- 6274
			bottle.x + 14, -- 6274
			0, -- 6274
			64, -- 6274
			SOLID_FILL -- 6274
		) -- 6274
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 6274
			self:drawBottle( -- 6276
				draw, -- 6276
				w, -- 6276
				h, -- 6276
				bottle.x, -- 6276
				64 -- 6276
			) -- 6276
		end -- 6276
	end -- 6276
	self:drawBox( -- 6280
		draw, -- 6280
		w, -- 6280
		h, -- 6280
		300, -- 6280
		420, -- 6280
		44, -- 6280
		50, -- 6280
		FLOOR_DECK -- 6280
	) -- 6280
	self:drawBox( -- 6281
		draw, -- 6281
		w, -- 6281
		h, -- 6281
		300, -- 6281
		306, -- 6281
		0, -- 6281
		44, -- 6281
		FLOOR_DECK -- 6281
	) -- 6281
	self:drawBox( -- 6282
		draw, -- 6282
		w, -- 6282
		h, -- 6282
		414, -- 6282
		420, -- 6282
		0, -- 6282
		44, -- 6282
		FLOOR_DECK -- 6282
	) -- 6282
	local s = self.room.scavenger -- 6284
	if s ~= nil then -- 6284
		local sx0 = self.scavX -- 6286
		self:drawBox( -- 6287
			draw, -- 6287
			w, -- 6287
			h, -- 6287
			sx0 - 12, -- 6287
			sx0 + 12, -- 6287
			0, -- 6287
			s.h - 14, -- 6287
			SCAV_BODY -- 6287
		) -- 6287
		self:drawBox( -- 6288
			draw, -- 6288
			w, -- 6288
			h, -- 6288
			sx0 - 7, -- 6288
			sx0 + 7, -- 6288
			s.h - 14, -- 6288
			s.h, -- 6288
			SCAV_HEAD -- 6288
		) -- 6288
		if self.scavState == "turn" then -- 6288
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 6290
			draw:drawSegment( -- 6291
				Vec2( -- 6291
					self:sx(sx0, w), -- 6291
					self:sy(s.h - 6, h) -- 6291
				), -- 6291
				Vec2( -- 6291
					self:sx(fx, w), -- 6291
					self:sy(s.h - 6, h) -- 6291
				), -- 6291
				self:px(1), -- 6291
				INK -- 6291
			) -- 6291
		end -- 6291
	end -- 6291
	if self.hasBottle then -- 6291
		local p = self.player -- 6296
		self:drawBottle( -- 6297
			draw, -- 6297
			w, -- 6297
			h, -- 6297
			p.x + p.facing * 10, -- 6297
			p.y + p.h * 0.62 -- 6297
		) -- 6297
	end -- 6297
	if self.bottleFly ~= nil then -- 6297
		self:drawBottle( -- 6300
			draw, -- 6300
			w, -- 6300
			h, -- 6300
			self.bottleFly.x, -- 6300
			self.bottleFly.y -- 6300
		) -- 6300
	end -- 6300
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 6300
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 6303
		draw:drawCircle( -- 6304
			Vec2( -- 6304
				self:sx(self.bottleLandX, w), -- 6304
				self:sy(0, h) -- 6304
			), -- 6304
			self:px(r / ____exports.UNITS_PER_PX), -- 6304
			BRICK_LINE -- 6304
		) -- 6304
	end -- 6304
end -- 6271
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 6308
	self:drawBox( -- 6309
		draw, -- 6309
		w, -- 6309
		h, -- 6309
		x - 3, -- 6309
		x + 3, -- 6309
		y - 10, -- 6309
		y, -- 6309
		BOTTLE -- 6309
	) -- 6309
end -- 6308
function Play.prototype.drawTrace(self, draw, w, h) -- 6312
	local t = self.trace -- 6313
	if t == nil or self.traceT <= 0 then -- 6313
		return -- 6315
	end -- 6315
	draw:drawSegment( -- 6317
		Vec2( -- 6318
			self:sx(t.x0, w), -- 6318
			self:sy(t.y0, h) -- 6318
		), -- 6318
		Vec2( -- 6319
			self:sx(t.x1, w), -- 6319
			self:sy(t.y1, h) -- 6319
		), -- 6319
		self:px(1), -- 6320
		t.hit and AIM_HIT or INK_DIM -- 6320
	) -- 6320
end -- 6312
function Play.prototype.drawAim(self, draw, w, h) -- 6323
	local v = self.view -- 6325
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 6326
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 6327
	local dot = self:px(1) -- 6328
	local arm = self:px(3) -- 6329
	local gap = self:px(1) -- 6330
	draw:drawSegment( -- 6331
		Vec2(gx - arm - gap, gy), -- 6331
		Vec2(gx - gap, gy), -- 6331
		dot / 2, -- 6331
		AIM -- 6331
	) -- 6331
	draw:drawSegment( -- 6332
		Vec2(gx + gap, gy), -- 6332
		Vec2(gx + arm + gap, gy), -- 6332
		dot / 2, -- 6332
		AIM -- 6332
	) -- 6332
	draw:drawSegment( -- 6333
		Vec2(gx, gy - arm - gap), -- 6333
		Vec2(gx, gy - gap), -- 6333
		dot / 2, -- 6333
		AIM -- 6333
	) -- 6333
	draw:drawSegment( -- 6334
		Vec2(gx, gy + gap), -- 6334
		Vec2(gx, gy + arm + gap), -- 6334
		dot / 2, -- 6334
		AIM -- 6334
	) -- 6334
	if self.room.key == "village" and self.hasBottle then -- 6334
		local p = self.player -- 6338
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 6340
		local dir = ____end.x >= p.x and 1 or -1 -- 6341
		local x0 = p.x + dir * 10 -- 6342
		local y0 = p.y + p.h * 0.7 -- 6343
		local T = BOTTLE_FLY_TIME -- 6344
		local vx = (____end.x - x0) / T -- 6345
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 6346
		local pxr = x0 -- 6347
		local pyr = y0 -- 6348
		local t = 1 -- 6349
		do -- 6349
			t = 1 -- 6350
			while t <= 12 do -- 6350
				local tt = t / 12 * T -- 6351
				local nx = x0 + vx * tt -- 6352
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 6353
				draw:drawSegment( -- 6354
					Vec2( -- 6354
						self:sx(pxr, w), -- 6354
						self:sy(pyr, h) -- 6354
					), -- 6354
					Vec2( -- 6354
						self:sx(nx, w), -- 6354
						self:sy(ny, h) -- 6354
					), -- 6354
					self:px(1) / 2, -- 6354
					BOTTLE -- 6354
				) -- 6354
				pxr = nx -- 6355
				pyr = ny -- 6356
				t = t + 1 -- 6350
			end -- 6350
		end -- 6350
		draw:drawCircle( -- 6358
			Vec2( -- 6358
				self:sx(____end.x, w), -- 6358
				self:sy(____end.y + 2, h) -- 6358
			), -- 6358
			self:px(2), -- 6358
			BOTTLE -- 6358
		) -- 6358
	end -- 6358
end -- 6323
return ____exports -- 6323