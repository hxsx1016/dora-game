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
local ARTIFACT_WEAPON_ID = ____craft.ARTIFACT_WEAPON_ID -- 29
local CRAFT_RECIPES = ____craft.CRAFT_RECIPES -- 29
local findRecipe = ____craft.findRecipe -- 29
local missingMaterials = ____craft.missingMaterials -- 29
local payMaterials = ____craft.payMaterials -- 29
local weaponEffectOf = ____craft.weaponEffectOf -- 29
local weaponNameOf = ____craft.weaponNameOf -- 29
function makeActor(room, index) -- 5843
	local sp = room.spawns -- 5844
	if index < 0 or index >= #sp then -- 5844
		return { -- 5846
			x = 0, -- 5846
			y = 0, -- 5846
			depth = 0, -- 5846
			depthSpeed = 0, -- 5846
			vx = 0, -- 5846
			vy = 0, -- 5846
			w = CHILD_W, -- 5846
			h = CHILD_H, -- 5846
			onGround = true, -- 5846
			facing = 1, -- 5846
			crouch = false, -- 5846
			rollT = 0, -- 5846
			covered = false, -- 5846
			alive = false -- 5846
		} -- 5846
	end -- 5846
	local s = sp[index + 1] -- 5848
	local child = s.h < SOLDIER_H -- 5849
	local ground = room.depth -- 5850
	local depth = ground == nil and 0 or math.max( -- 5851
		ground.min, -- 5851
		math.min(ground.max, s.depth or 0) -- 5851
	) -- 5851
	return { -- 5852
		x = s.x, -- 5853
		y = s.y, -- 5853
		depth = depth, -- 5853
		depthSpeed = 0, -- 5853
		vx = 0, -- 5853
		vy = 0, -- 5853
		w = child and CHILD_W or SOLDIER_W, -- 5854
		h = child and CHILD_H or SOLDIER_H, -- 5855
		onGround = true, -- 5856
		facing = 1, -- 5856
		crouch = false, -- 5856
		rollT = 0, -- 5856
		covered = false, -- 5856
		alive = true -- 5856
	} -- 5856
end -- 5856
function drawFigure(draw, play, w, h, a, body, head) -- 5860
	if not a.alive then -- 5860
		return -- 5862
	end -- 5862
	local x0 = a.x - a.w / 2 -- 5864
	local x1 = a.x + a.w / 2 -- 5865
	local y0 = a.y + a.depth * DEPTH_Y_SCALE -- 5866
	local y1 = y0 + a.h -- 5867
	play:drawBox( -- 5868
		draw, -- 5868
		w, -- 5868
		h, -- 5868
		x0, -- 5868
		x1, -- 5868
		y0, -- 5868
		y1 - a.h * 0.26, -- 5868
		body -- 5868
	) -- 5868
	play:drawBox( -- 5869
		draw, -- 5869
		w, -- 5869
		h, -- 5869
		x0 + 2, -- 5869
		x1 - 2, -- 5869
		y1 - a.h * 0.26, -- 5869
		y1, -- 5869
		head -- 5869
	) -- 5869
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 5871
	play:drawBox( -- 5872
		draw, -- 5872
		w, -- 5872
		h, -- 5872
		eyeX, -- 5872
		eyeX + 4, -- 5872
		y1 - a.h * 0.14, -- 5872
		y1 - a.h * 0.08, -- 5872
		INK -- 5872
	) -- 5872
end -- 5872
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5876
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5877
end -- 5876
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5884
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5885
end -- 5884
function rayInterval(origin, direction, min, max) -- 5892
	if direction == 0 then -- 5892
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5894
	end -- 5894
	local a = (min - origin) / direction -- 5896
	local b = (max - origin) / direction -- 5897
	return { -- 5898
		min = math.min(a, b), -- 5898
		max = math.max(a, b) -- 5898
	} -- 5898
end -- 5898
function hitBox(ray, box) -- 5902
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5903
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5904
	local enter = math.max(0, x.min, y.min) -- 5905
	local leave = math.min(99999, x.max, y.max) -- 5906
	if box.depth ~= nil then -- 5906
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5908
		enter = math.max(enter, depth.min) -- 5909
		leave = math.min(leave, depth.max) -- 5910
	end -- 5910
	return leave >= enter and enter or -1 -- 5912
end -- 5912
function drawCartShape(draw, play, w, h, c, axleX) -- 5915
	local half = c.bodyW / 2 -- 5916
	local x0 = axleX - half -- 5917
	local x1 = axleX + half -- 5918
	local axleY = c.baseY + (c.depth or 0) * DEPTH_Y_SCALE + c.wheelR -- 5919
	play:drawBox( -- 5920
		draw, -- 5920
		w, -- 5920
		h, -- 5920
		x0, -- 5920
		x1, -- 5920
		axleY, -- 5920
		axleY + c.bodyH, -- 5920
		CART_FILL -- 5920
	) -- 5920
	draw:drawCircle( -- 5921
		Vec2( -- 5921
			play:sx(x0 + c.bodyW * 0.28, w), -- 5921
			play:sy(axleY, h) -- 5921
		), -- 5921
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5921
		Color(52, 50, 48, 255) -- 5921
	) -- 5921
	draw:drawCircle( -- 5922
		Vec2( -- 5922
			play:sx(x1 - c.bodyW * 0.28, w), -- 5922
			play:sy(axleY, h) -- 5922
		), -- 5922
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5922
		Color(52, 50, 48, 255) -- 5922
	) -- 5922
	local cx = c.clothSide < 0 and x0 or x1 -- 5923
	play:drawBox( -- 5924
		draw, -- 5924
		w, -- 5924
		h, -- 5924
		cx - 10, -- 5924
		cx + 10, -- 5924
		axleY + c.bodyH, -- 5924
		axleY + c.bodyH + 18, -- 5924
		CLOTH -- 5924
	) -- 5924
end -- 5924
____exports.STEP = STEP -- 34
____exports.GRAVITY = 1000 -- 35
____exports.GATE_COUNT_END = 1440 -- 36
--- 牵手：按住 E 的有效拍数，60 拍/秒 → 0.6 秒。
____exports.GATE_HAND_TICKS = 36 -- 38
--- 80% 门槛：100*hpAtGate >= 80*maxHpAtGate 走男主线。
____exports.GATE_ROUTE_PERCENT = 80 -- 40
____exports.TOWER_CONFIRM_TICKS = 480 -- 41
local TOWER_REGISTER_TICKS = 180 -- 42
--- 值夜室桌前长按 E 的生效拍数（0.6 秒，与城门牵手同节奏）。
local TOWER_HANDOVER_TICKS = 36 -- 44
--- 跨过门槛的段内 x（门廊 400–490、值夜室 490–700）。
local TOWER_THRESHOLD_X = 500 -- 46
--- P01 黑场听父亲唤「小满」到睁眼落稳：4 秒 = 240 拍。
____exports.PROLOGUE_WAKE_TICKS = 240 -- 50
--- P02 门槛内墙上人影与瓷碗滚到脚边：2 秒 = 120 拍。
____exports.PROLOGUE_SHADOW_TICKS = 120 -- 52
--- 限时逃柜：7.5 秒 = 450 拍；超时退回门口重来，不扣血。
____exports.PROLOGUE_ESCAPE_TICKS = 450 -- 54
--- 入柜后红晕收尽、柜外脚步渐远：0.85 秒 = 51 拍。
____exports.PROLOGUE_HIDE_TICKS = 51 -- 56
--- 小满贴住倒柜左缘（段内 x，柜体从 152 起；玩家半宽 14）即拉门入柜。
____exports.PROLOGUE_CABINET_X = 132 -- 58
function ____exports.gateCountAtTick(tick) -- 60
	if tick >= ____exports.GATE_COUNT_END then -- 60
		return 20 -- 61
	end -- 61
	if tick >= 1260 then -- 61
		return 19 -- 62
	end -- 62
	if tick >= 1080 then -- 62
		return 18 -- 63
	end -- 63
	if tick >= 480 then -- 63
		return 11 + math.floor((tick - 480) * 7 / 600) -- 64
	end -- 64
	return 1 + math.floor(math.max(0, tick) / 48) -- 65
end -- 60
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 68
CHILD_W = 28 -- 143
CHILD_H = 56 -- 144
local CHILD_CROUCH_H = 34 -- 145
local CHILD_SPEED = 160 -- 146
local CHILD_SLOW = 80 -- 147
local CHILD_JUMP = 320 -- 148
SOLDIER_W = 30 -- 151
SOLDIER_H = 88 -- 152
local SOLDIER_SPEED = 264 -- 153
local ROLL_TIME = 0.35 -- 154
local ROLL_SPEED = 280 -- 155
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 157
local LEDGE_RISE = 60 -- 158
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 161
____exports.LOGIC_H = 180 -- 162
____exports.UNITS_PER_PX = 2 -- 163
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 165
local CAM_FOLLOW = 9 -- 166
local CAM_LOOK_UP = 46 -- 167
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 170
--- 握把触发半径。
____exports.CART_REACH = 70 -- 172
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 174
local CART_CLEAR = 44 -- 175
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 177
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 179
local CONSUMABLE_CAP = 1 -- 180
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 182
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 184
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 186
local FIRE_COOLDOWN = 150 -- 187
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 189
local ENEMY_RANGE = 760 -- 190
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 192
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 194
local DEPTH_SPEED_RATIO = 0.55 -- 195
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 196
INK = Color(232, 232, 228, 255) -- 198
local INK_DIM = Color(150, 152, 150, 255) -- 199
local BG_VOID = Color(8, 9, 10, 255) -- 200
local BG_FAR = Color(24, 26, 28, 255) -- 201
local BG_MID = Color(31, 34, 37, 255) -- 202
local GROUND = Color(112, 114, 112, 255) -- 203
local FLOOR_DECK = Color(66, 70, 72, 255) -- 204
local SOLID_FILL = Color(84, 86, 84, 255) -- 205
local SOLID_EDGE = Color(126, 130, 126, 255) -- 206
CART_FILL = Color(122, 78, 56, 255) -- 207
CLOTH = Color(178, 52, 46, 255) -- 208
local DANGER = Color(150, 54, 48, 46) -- 209
local DANGER_LINE = Color(178, 78, 64, 200) -- 210
local HOLE_FILL = Color(10, 11, 12, 255) -- 211
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 212
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 213
local CHILD_BODY = Color(214, 168, 96, 255) -- 214
local CHILD_HEAD = Color(232, 214, 186, 255) -- 215
local ENEMY_BODY = Color(176, 92, 84, 255) -- 216
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 217
local CHECK = Color(96, 186, 122, 255) -- 218
local STAND = Color(226, 186, 84, 255) -- 219
local AIM = Color(236, 236, 232, 230) -- 220
local AIM_HIT = Color(236, 96, 84, 255) -- 221
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 223
local SOFT_LINE = Color(140, 112, 80, 190) -- 224
local BRICK = Color(126, 118, 110, 70) -- 225
local BRICK_LINE = Color(160, 152, 142, 200) -- 226
local PASS = Color(96, 186, 122, 40) -- 227
local PASS_LINE = Color(96, 186, 122, 200) -- 228
local BOTTLE = Color(120, 186, 160, 255) -- 229
local SCAV_BODY = Color(128, 118, 96, 255) -- 230
local SCAV_HEAD = Color(196, 182, 158, 255) -- 231
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 318
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 319
	if zoom < 1 then -- 319
		zoom = 1 -- 321
	end -- 321
	return { -- 323
		zoom = zoom, -- 324
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 325
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 326
	} -- 326
end -- 318
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 349
	if key == "prologue" then -- 349
		return "prologue-wait" -- 353
	end -- 353
	if key == "street" then -- 353
		return "street-run" -- 356
	end -- 356
	if key == "gate" then -- 356
		return "gate-idle" -- 359
	end -- 359
	if key == "gatepath" then -- 359
		return "gatepath-start" -- 362
	end -- 362
	if key == "forest" then -- 362
		return "forest-run" -- 365
	end -- 365
	if key == "tower" then -- 365
		return "tower-wait" -- 368
	end -- 368
	if key == "museum" then -- 368
		return "museum-cabinet" -- 371
	end -- 371
	return "run" -- 373
end -- 349
____exports.Play = __TS__Class() -- 376
local Play = ____exports.Play -- 376
Play.name = "Play" -- 376
function Play.prototype.____constructor(self, room, resume, run) -- 660
	self.enemies = {} -- 381
	self.boxes = {} -- 382
	self.floors = {} -- 383
	self.checkpoint = -1 -- 385
	self.flash = "" -- 387
	self.flashT = 0 -- 388
	self.traceT = 0 -- 391
	self.focusCart = false -- 393
	self.knocks = 0 -- 395
	self.knockT = 0 -- 396
	self.cartAxle = 0 -- 400
	self.cartDocked = false -- 402
	self.gripping = false -- 404
	self.gateOpen = false -- 406
	self.calmConsumed = false -- 408
	self.craftT = 0 -- 410
	self.nextDangerId = 1 -- 412
	self.wantRoom = "" -- 414
	self.carryCartAxle = -1 -- 416
	self.carryCartDocked = false -- 417
	self.checkpointCartAxle = -1 -- 419
	self.hasBottle = false -- 423
	self.bottleLandX = -1 -- 427
	self.bottleTargetX = -1 -- 428
	self.bottleTargetY = 0 -- 429
	self.bottleLandT = 0 -- 430
	self.aimHold = 0 -- 432
	self.redCartPulled = false -- 434
	self.redCartMemoryT = 0 -- 436
	self.footHintT = 0 -- 438
	self.ditchHinted = false -- 440
	self.forestPath = "" -- 442
	self.waterSeen = false -- 444
	self.scavStallBonus = 0 -- 446
	self.intentGateReunionHold = false -- 448
	self.pendingMuseumIntentTarget = "" -- 450
	self.scavX = 0 -- 452
	self.scavDir = 1 -- 453
	self.scavState = "patrol" -- 454
	self.scavT = 0 -- 455
	self.scavTargetX = 0 -- 456
	self.passed = false -- 458
	self.childMode = false -- 462
	self.phase = "" -- 464
	self.phaseTick = 0 -- 466
	self.gateTick = 0 -- 468
	self.countTick = 0 -- 470
	self.countArmed = false -- 472
	self.countPrevMove = 0 -- 474
	self.caughtT = 0 -- 476
	self.hp = 3 -- 478
	self.maxHp = 3 -- 479
	self.invulnT = 0 -- 485
	self.partnerStuck = 0 -- 487
	self.partnerLaneIdx = 0 -- 489
	self.partnerLaneHold = 0 -- 490
	self.coveredFlash = 0 -- 492
	self.coverHug = false -- 494
	self.coverNear = false -- 496
	self.coverEntity = "" -- 498
	self.coverBlocking = false -- 500
	self.gateNeedConfirm = false -- 502
	self.gateRestartArmed = true -- 504
	self.bottleAimX = -1 -- 506
	self.bottleAimY = 0 -- 507
	self.bottleSurfaceY = -1 -- 509
	self.bottleLandY = 0 -- 511
	self.events = {} -- 513
	self.eventSeq = 0 -- 515
	self.dogX = 0 -- 517
	self.dogDir = 1 -- 518
	self.dogState = "patrol" -- 519
	self.dogT = 0 -- 520
	self.dogTargetX = 0 -- 521
	self.scavSee = 0 -- 523
	self.scavChase = false -- 524
	self.gateSpawned = 0 -- 526
	self.gateFailCount = 0 -- 528
	self.isCampaign = false -- 532
	self.archiveDirty = false -- 540
	self.sessionDirty = false -- 542
	self.restartStory = false -- 544
	self.wellOpen = false -- 546
	self.wellX = 430 -- 548
	self.wellTaken = false -- 550
	self.museumReturn = false -- 552
	self.endingLines = {"", ""} -- 554
	self.towerDoorOpen = false -- 556
	self.towerHanded = false -- 557
	self.deskHold = 0 -- 558
	self.equippedWeapon = "standard_gun" -- 562
	self.craftBench = { -- 564
		active = false, -- 565
		firstCraftDone = false, -- 566
		justCraftedTimer = 0, -- 567
		inventory = {}, -- 568
		recipes = {}, -- 569
		equippedWeapon = "standard_gun" -- 570
	} -- 570
	self.handledCraftRequests = {} -- 573
	self.benchReach = 48 -- 575
	self.pickups = {} -- 579
	self.reloadT = 0 -- 581
	self.objectiveDone = false -- 585
	self.hint = "" -- 587
	self.roomStartTick = 0 -- 589
	self.cartHitT = 0 -- 591
	self.cartExposed = false -- 592
	self.storyRoute = "" -- 596
	self.storySettled = false -- 598
	self.hpAtGate = -1 -- 600
	self.maxHpAtGate = -1 -- 601
	self.handTicks = 0 -- 603
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 605
	self.handArmed = false -- 607
	self.handDone = false -- 609
	self.lineSaid = false -- 610
	self.tied = false -- 612
	self.pathDone = false -- 614
	self.carryOn = false -- 616
	self.escortDone = false -- 618
	self.escapeDuration = ____exports.PROLOGUE_ESCAPE_TICKS / 60 -- 622
	self.escapeRemaining = 0 -- 624
	self.escapeRetryCount = 0 -- 626
	self.introTick = 0 -- 628
	self.reloadOpen = false -- 632
	self.reloadAnswerTicks = 0 -- 634
	self.reloadWorldTicks = 0 -- 636
	self.reloadPath = {RELOAD_START} -- 638
	self.reloadPendingEffect = "" -- 640
	self.reloadTryCount = 0 -- 642
	self.paused = false -- 644
	self.ticks = 0 -- 646
	self.view = {zoom = 1, ox = 0, oy = 0} -- 648
	self.ox = 0 -- 650
	self.aimX = 0 -- 652
	self.aimY = 0 -- 653
	self.viewW = 0 -- 655
	self.viewH = 0 -- 656
	self.ox = room.originX -- 662
	self.room = withOrigin(room) -- 663
	local wr = self.room -- 664
	self.run = run or createRun() -- 665
	self.inventory = self.run.inventory -- 666
	self.archive = self.run.archive -- 667
	self.equippedWeapon = self.run.story.craftedWeapon == "" and "standard_gun" or self.run.story.craftedWeapon -- 668
	self.isCampaign = wr.campaign ~= nil -- 669
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 670
	self:buildWorld() -- 671
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 674
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 676
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 677
	local soloRoom = wr.key == "museum" -- 679
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 680
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 681
	self.player = makeActor(wr, playerIdx) -- 682
	self.partner = makeActor(wr, partnerIdx) -- 683
	self.phase = phaseOf(wr.key) -- 684
	if soloRoom then -- 684
		local mp = self.archive.museumPhase -- 687
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 688
	end -- 688
	if wr.story ~= nil then -- 688
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 694
	end -- 694
	self.cam.x = self.player.x -- 696
	self.cam.y = self.player.y + CAM_LOOK_UP -- 697
	self.cartAxle = wr.cart.startX -- 698
	self.escort = __TS__New( -- 699
		Escort, -- 699
		safeAnchorX(wr.marks) -- 699
	) -- 699
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 700
	if self.isCampaign then -- 700
		self:setupCampaign() -- 702
	else -- 702
		self:buildEnemies() -- 704
	end -- 704
	if resume ~= nil and resume.checkpoint > 0 then -- 704
		self.checkpoint = resume.checkpoint -- 708
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 708
			self.cartAxle = self.room.cart.endX -- 710
			self.cartDocked = true -- 711
			self.player.x = self.ox + 380 -- 714
			self.player.y = 0 -- 715
			self.player.vy = 0 -- 716
			self.player.onGround = true -- 717
			self.cam.x = self.player.x -- 718
			self.cam.y = self.player.y + CAM_LOOK_UP -- 719
		end -- 719
	end -- 719
	self:restoreStory() -- 722
end -- 660
function Play.prototype.recipeViews(self) -- 735
	local out = {} -- 736
	local i = 0 -- 737
	do -- 737
		i = 0 -- 738
		while i < #CRAFT_RECIPES do -- 738
			local r = CRAFT_RECIPES[i + 1] -- 739
			local cost = {} -- 740
			if r.cost.wood ~= nil then -- 740
				cost.wood = r.cost.wood -- 742
			end -- 742
			if r.cost.bell ~= nil then -- 742
				cost.bell = r.cost.bell -- 745
			end -- 745
			out[#out + 1] = { -- 747
				id = r.id, -- 748
				name = r.name, -- 749
				desc = r.desc, -- 750
				enhancedEffect = r.enhancedEffect, -- 751
				cost = cost, -- 752
				crafted = self.run.story.craftedWeapon == r.id -- 753
			} -- 753
			i = i + 1 -- 738
		end -- 738
	end -- 738
	if self.archive.artifactOwned then -- 738
		out[#out + 1] = { -- 758
			id = ARTIFACT_WEAPON_ID, -- 759
			name = weaponNameOf(ARTIFACT_WEAPON_ID), -- 760
			desc = "井底拾取彩蛋 · 男主线移动留下冷白微金轨迹残影", -- 761
			enhancedEffect = "light", -- 762
			cost = {}, -- 763
			crafted = true -- 764
		} -- 764
	end -- 764
	return out -- 767
end -- 735
function Play.prototype.syncCraftBench(self) -- 771
	local view = self.craftBench -- 772
	local inv = self.run.inventory -- 773
	view.inventory = { -- 774
		wood = inv.wood, -- 774
		bell = inv.bell, -- 774
		scrap = inv.scrap, -- 774
		wedge = inv.wedge, -- 774
		ammo = inv.ammo -- 774
	} -- 774
	view.recipes = self:recipeViews() -- 775
	view.equippedWeapon = self.equippedWeapon -- 776
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 777
	if view.justCraftedTimer > 0 then -- 777
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 779
	end -- 779
end -- 771
function Play.prototype.openCraftBench(self) -- 784
	if self.room.key ~= "escort3" or self.craftBench.active then -- 784
		return -- 786
	end -- 786
	self.craftBench.active = true -- 788
	self.carryOn = false -- 789
	self.run.story.carry = false -- 790
	self.player.vx = 0 -- 791
	self.player.vy = 0 -- 792
	self.craftBench.justCraftedTimer = 0 -- 793
	self:syncCraftBench() -- 794
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 795
	self:log("开工台") -- 796
	self:emit( -- 797
		"benchOpen", -- 797
		{ -- 797
			recipes = __TS__ArrayMap( -- 798
				self.craftBench.recipes, -- 798
				function(____, r) return r.id end -- 798
			), -- 798
			inventory = self.craftBench.inventory, -- 799
			carry = self.carryOn -- 800
		} -- 800
	) -- 800
end -- 784
function Play.prototype.closeCraftBench(self) -- 805
	if not self.craftBench.active then -- 805
		return -- 807
	end -- 807
	self.craftBench.active = false -- 809
	self.craftBench.justCraftedTimer = 0 -- 810
	self.carryOn = true -- 811
	self.run.story.carry = true -- 812
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 813
	self:log("离站背起") -- 814
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 815
end -- 805
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 822
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 822
		return false -- 824
	end -- 824
	local recipe = findRecipe(recipeId) -- 826
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 826
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 828
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 829
		return false -- 830
	end -- 830
	local missing = missingMaterials(self.run.inventory, recipe) -- 832
	if #missing > 0 then -- 832
		self:flashSet( -- 834
			"缺料 · " .. table.concat(missing, " / "), -- 834
			1.6 -- 834
		) -- 834
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 835
		return false -- 836
	end -- 836
	payMaterials(self.run.inventory, recipe) -- 838
	self.handledCraftRequests[requestId] = true -- 839
	self.run.story.craftedWeapon = recipe.id -- 840
	self.run.story.equippedWeapon = recipe.id -- 841
	self.equippedWeapon = recipe.id -- 842
	self.sessionDirty = true -- 843
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 844
	self.craftBench.firstCraftDone = true -- 845
	self:syncCraftBench() -- 846
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 847
	self:log("改制 " .. recipe.id) -- 848
	self:emit("benchCraft", { -- 849
		recipeId = recipe.id, -- 850
		weapon = recipe.id, -- 851
		effect = recipe.enhancedEffect, -- 852
		wood = self.run.inventory.wood, -- 853
		bell = self.run.inventory.bell -- 854
	}) -- 854
	return true -- 856
end -- 822
function Play.prototype.equipWeapon(self, weaponId) -- 860
	local artifactOk = weaponId == ARTIFACT_WEAPON_ID and self.archive.artifactOwned -- 861
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId and not artifactOk then -- 861
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 863
		return false -- 864
	end -- 864
	self.equippedWeapon = weaponId -- 866
	self.run.story.equippedWeapon = weaponId -- 867
	self.sessionDirty = true -- 868
	self:syncCraftBench() -- 869
	self:flashSet( -- 870
		"已装备 " .. weaponNameOf(weaponId), -- 870
		1 -- 870
	) -- 870
	self:emit("benchEquip", {weapon = weaponId}) -- 871
	return true -- 872
end -- 860
function Play.prototype.toggleArtifactWeapon(self) -- 876
	if not self.archive.artifactOwned or self.childMode then -- 876
		return false -- 878
	end -- 878
	if self.equippedWeapon == ARTIFACT_WEAPON_ID then -- 878
		local fallback = self.run.story.craftedWeapon ~= "" and self.run.story.craftedWeapon or "standard_gun" -- 881
		return self:equipWeapon(fallback) -- 882
	end -- 882
	return self:equipWeapon(ARTIFACT_WEAPON_ID) -- 884
end -- 876
function Play.prototype.exportSession(self) -- 888
	self:syncStory() -- 889
	local story = self.run.story -- 890
	local inv = self.run.inventory -- 891
	local taken = {} -- 892
	for k in pairs(self.run.taken) do -- 893
		if self.run.taken[k] == true then -- 893
			taken[#taken + 1] = k -- 895
		end -- 895
	end -- 895
	local segments = {} -- 898
	for k in pairs(story.segments) do -- 899
		if story.segments[k] == true then -- 899
			segments[#segments + 1] = k -- 901
		end -- 901
	end -- 901
	return { -- 904
		roomKey = self.room.key, -- 905
		checkpoint = self.checkpoint, -- 906
		seed = self.run.seed, -- 907
		route = story.route, -- 908
		hp = story.hp, -- 909
		maxHp = story.maxHp, -- 910
		hpAtGate = story.hpAtGate, -- 911
		maxHpAtGate = story.maxHpAtGate, -- 912
		settled = story.settled, -- 913
		phase = self.phase, -- 914
		countTick = story.countTick, -- 915
		phaseTick = story.phaseTick, -- 916
		handTicks = story.handTicks, -- 917
		handDone = story.handDone, -- 918
		lineSaid = story.lineSaid, -- 919
		tied = story.tied, -- 920
		carry = story.carry, -- 921
		escortDone = story.escortDone, -- 922
		craftedWeapon = story.craftedWeapon, -- 923
		equippedWeapon = self.equippedWeapon, -- 924
		wood = inv.wood, -- 925
		bell = inv.bell, -- 926
		scrap = inv.scrap, -- 927
		wedge = inv.wedge, -- 928
		ammo = inv.ammo, -- 929
		shield = inv.shield, -- 930
		pass = inv.pass, -- 931
		quickbelt = inv.quickbelt, -- 932
		taken = taken, -- 933
		segments = segments, -- 934
		cartAxle = self.cartAxle, -- 935
		cartDocked = self.cartDocked -- 936
	} -- 936
end -- 888
function Play.prototype.submitFeIntent(self, intent) -- 944
	local kind = intent == nil and "" or intent.kind -- 945
	if kind == "gateReunionHold" then -- 945
		if self.room.key ~= "gate" or self.phase ~= "gate-wait" and self.phase ~= "gate-count" then -- 945
			return false -- 948
		end -- 948
		local holding = intent.holding == true -- 950
		self.intentGateReunionHold = holding -- 951
		if not holding and self.phase == "gate-wait" then -- 951
			if self.handTicks > 0 then -- 951
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 954
			end -- 954
			self.handTicks = 0 -- 956
			self.handArmed = true -- 957
		end -- 957
		return true -- 959
	end -- 959
	if kind == "reloadOpen" then -- 959
		local camp = self.room.campaign -- 962
		if self.run.trial ~= nil or camp == nil or camp.reloadPuzzle ~= true or self.reloadOpen then -- 962
			return false -- 964
		end -- 964
		self:beginReload() -- 966
		return self.reloadOpen -- 967
	end -- 967
	if kind == "reloadPathPreview" then -- 967
		local path = intent.path -- 970
		return type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) -- 971
	end -- 971
	if kind == "reloadTapNode" then -- 971
		local node = intent.node -- 974
		if type(node) == "number" then -- 974
			self:reloadTapNode(node) -- 976
			return true -- 977
		end -- 977
		return false -- 979
	end -- 979
	if kind == "reloadPathCommit" then -- 979
		local path = intent.path -- 982
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 982
			local list = path -- 984
			local i = 0 -- 985
			do -- 985
				i = 0 -- 986
				while i < #list do -- 986
					do -- 986
						if i == 0 and list[i + 1] == RELOAD_START then -- 986
							goto __continue66 -- 988
						end -- 988
						self:reloadTapNode(list[i + 1]) -- 990
					end -- 990
					::__continue66:: -- 990
					i = i + 1 -- 986
				end -- 986
			end -- 986
			return true -- 992
		end -- 992
		return false -- 994
	end -- 994
	if kind == "reloadCancel" then -- 994
		self:closeReloadPuzzle() -- 997
		return true -- 998
	end -- 998
	if kind == "craftSubmit" then -- 998
		local recipeId = intent.recipeId -- 1001
		local requestId = intent.requestId -- 1002
		if type(recipeId) == "string" and type(requestId) == "string" then -- 1002
			return self:craftAtBench(recipeId, requestId) -- 1004
		end -- 1004
		return false -- 1006
	end -- 1006
	if kind == "craftEquip" then -- 1006
		local weaponId = intent.weaponId -- 1009
		if type(weaponId) == "string" then -- 1009
			return self:equipWeapon(weaponId) -- 1011
		end -- 1011
		return false -- 1013
	end -- 1013
	if kind == "craftClose" then -- 1013
		self:closeCraftBench() -- 1016
		return true -- 1017
	end -- 1017
	if kind == "wellPick" then -- 1017
		return self:pickWell() -- 1020
	end -- 1020
	if kind == "museumInteract" then -- 1020
		local target = type(intent.target) == "string" and intent.target or "" -- 1023
		if target == "well_pickup" or target == "well" then -- 1023
			return self:pickWell() -- 1025
		end -- 1025
		if self.room.key ~= "museum" then -- 1025
			return false -- 1028
		end -- 1028
		return self:triggerMuseumIntent(target) -- 1030
	end -- 1030
	return false -- 1032
end -- 944
function Play.prototype.triggerMuseumIntent(self, target) -- 1036
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 1037
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 1040
	if self.phase == "museum-cabinet" and (target == "" or target == "cabinet" or target == "weapon_case") and atCase then -- 1040
		self.pendingMuseumIntentTarget = "cabinet" -- 1042
		return true -- 1043
	end -- 1043
	if self.phase == "museum-hall" and (target == "" or target == "hall" or target == "corridor") and self.player.x >= self.ox + mu.hallX then -- 1043
		self.pendingMuseumIntentTarget = "hall" -- 1046
		return true -- 1047
	end -- 1047
	if self.phase == "museum-lamp" and (target == "" or target == "lamp" or target == "west_lamp") and self.player.x >= self.ox + mu.lampX then -- 1047
		self.pendingMuseumIntentTarget = "lamp" -- 1050
		return true -- 1051
	end -- 1051
	if self.phase == "museum-return" and (target == "" or target == "return_cabinet" or target == "cabinet" or target == "return") and atCase then -- 1051
		self.pendingMuseumIntentTarget = "return_cabinet" -- 1054
		return true -- 1055
	end -- 1055
	if self.phase == "museum-done" and (target == "" or target == "return_cabinet" or target == "return") then -- 1055
		self.pendingMuseumIntentTarget = "done" -- 1058
		return true -- 1059
	end -- 1059
	return false -- 1061
end -- 1036
function Play.prototype.captureCheckpoint(self, id) -- 1065
	local inv = self.run.inventory -- 1066
	self.checkpointSnap = { -- 1067
		id = id, -- 1068
		wood = inv.wood, -- 1069
		bell = inv.bell, -- 1070
		scrap = inv.scrap, -- 1071
		wedge = inv.wedge, -- 1072
		ammo = inv.ammo, -- 1073
		shield = inv.shield, -- 1074
		pass = inv.pass, -- 1075
		quickbelt = inv.quickbelt, -- 1076
		crafted = self.run.story.craftedWeapon, -- 1077
		equipped = self.equippedWeapon, -- 1078
		carry = self.carryOn -- 1079
	} -- 1079
	self.run.story.cp = self.checkpointSnap -- 1081
end -- 1065
function Play.prototype.applyCheckpointSnap(self, id) -- 1085
	local snap = self.run.story.cp -- 1086
	if snap == nil or snap.id ~= id then -- 1086
		return false -- 1088
	end -- 1088
	self.checkpointSnap = snap -- 1090
	local inv = self.run.inventory -- 1091
	inv.wood = snap.wood -- 1092
	inv.bell = snap.bell -- 1093
	inv.scrap = snap.scrap -- 1094
	inv.wedge = snap.wedge -- 1095
	inv.ammo = snap.ammo -- 1096
	inv.shield = snap.shield -- 1097
	inv.pass = snap.pass -- 1098
	inv.quickbelt = snap.quickbelt -- 1099
	self.run.story.craftedWeapon = snap.crafted -- 1100
	self.equippedWeapon = snap.equipped -- 1101
	self.carryOn = snap.carry -- 1102
	self.run.story.carry = snap.carry -- 1103
	self.craftBench.active = false -- 1104
	self:syncCraftBench() -- 1105
	return true -- 1106
end -- 1085
function Play.prototype.restoreStory(self) -- 1109
	if self.isCampaign and self.run.trial ~= nil then -- 1109
		return -- 1113
	end -- 1113
	local story = self.run.story -- 1115
	if story == nil then -- 1115
		return -- 1117
	end -- 1117
	if story.maxHp > 0 then -- 1117
		self.maxHp = story.maxHp -- 1120
		self.hp = math.max( -- 1121
			1, -- 1121
			math.min(story.hp, story.maxHp) -- 1121
		) -- 1121
	end -- 1121
	self.storyRoute = story.route -- 1123
	self.storySettled = story.settled -- 1124
	self.hpAtGate = story.hpAtGate -- 1125
	self.maxHpAtGate = story.maxHpAtGate -- 1126
	self.handDone = story.handDone -- 1127
	self.lineSaid = story.lineSaid -- 1128
	self.tied = story.handDone -- 1129
	self.carryOn = story.carry or story.route == "soldier" and self.room.key == "escort1" -- 1130
	self.museumReturn = story.museumReturn -- 1131
	story.museumReturn = false -- 1132
	self.escortDone = story.escortDone -- 1133
	local savedEq = story.equippedWeapon -- 1134
	if savedEq == ARTIFACT_WEAPON_ID and self.archive.artifactOwned then -- 1134
		self.equippedWeapon = ARTIFACT_WEAPON_ID -- 1136
	elseif savedEq == "standard_gun" or savedEq ~= "" and savedEq == story.craftedWeapon then -- 1136
		self.equippedWeapon = savedEq -- 1138
	else -- 1138
		self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 1140
	end -- 1140
	self:syncCraftBench() -- 1142
	if story.segments.outside_cart == true then -- 1142
		self.redCartPulled = true -- 1145
		local redBox = __TS__ArrayFind( -- 1146
			self.boxes, -- 1146
			function(____, b) return b.id == "outside_red_cart" end -- 1146
		) -- 1146
		if redBox ~= nil then -- 1146
			redBox.x0 = 430 -- 1148
			redBox.x1 = 474 -- 1149
		end -- 1149
		if self.room.key == "outside" and self.room.cart.bodyW > 0 then -- 1149
			self.cartAxle = self.room.cart.endX -- 1152
			self.cartDocked = true -- 1153
		end -- 1153
	end -- 1153
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 1156
	self.waterSeen = story.segments.water_lantern == true -- 1158
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 1158
		self:applyCheckpointSnap(self.checkpoint) -- 1161
	end -- 1161
	if self.room.key == "tower" and story.route == "soldier" then -- 1161
		self.carryOn = false -- 1165
		self.run.story.carry = false -- 1166
		self.partner = { -- 1167
			x = math.max(self.room.minX + 40, self.player.x - 36), -- 1168
			y = 0, -- 1169
			depth = 0, -- 1170
			depthSpeed = 0, -- 1171
			vx = 0, -- 1172
			vy = 0, -- 1173
			w = SOLDIER_W, -- 1174
			h = SOLDIER_H, -- 1175
			onGround = true, -- 1176
			facing = 1, -- 1177
			crouch = false, -- 1178
			rollT = 0, -- 1179
			covered = false, -- 1180
			alive = true -- 1181
		} -- 1181
	end -- 1181
	if self.room.key == "tower" then -- 1181
		if story.segments.tower_door == true then -- 1181
			self:openTowerDoor() -- 1187
		end -- 1187
		self.towerHanded = story.segments.tower_handover == true -- 1189
		self.deskHold = 0 -- 1190
		if story.phase == "tower-enter" or story.phase == "tower-desk" or story.phase == "tower-given" then -- 1190
			self.phase = story.phase -- 1192
			self.phaseTick = 0 -- 1193
			if story.phase == "tower-desk" or story.phase == "tower-given" then -- 1193
				self.player.x = self.ox + 605 -- 1195
				self.player.y = 0 -- 1196
				if story.route == "soldier" and self.partner.alive then -- 1196
					self.partner.x = self.ox + 568 -- 1198
					self.partner.y = 0 -- 1199
					self.partner.facing = 1 -- 1200
				end -- 1200
			end -- 1200
		end -- 1200
	end -- 1200
	if self.room.key == "prologue" then -- 1200
		local ph = story.phase -- 1207
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 1207
			self.phase = ph -- 1209
			self.phaseTick = story.phaseTick -- 1210
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 1211
			self.player.y = 0 -- 1212
			self.player.depth = 0 -- 1213
			self.player.vx = 0 -- 1214
			self.partner.x = self.ox + 300 -- 1215
			self.partner.y = 0 -- 1216
			self.partner.depth = 0 -- 1217
			self.partner.vx = 0 -- 1218
			self.partner.alive = true -- 1219
			if ph == "prologue-follow" then -- 1219
				self.partner.crouch = false -- 1221
				self.partner.h = CHILD_H -- 1222
			else -- 1222
				self.partner.crouch = true -- 1224
				self.partner.h = CHILD_CROUCH_H -- 1225
			end -- 1225
			self.cam.x = self.player.x -- 1227
		end -- 1227
		return -- 1229
	end -- 1229
	if self.room.key ~= "gate" then -- 1229
		return -- 1232
	end -- 1232
	local ____temp_0 -- 1234
	if self.room.story == nil then -- 1234
		____temp_0 = nil -- 1234
	else -- 1234
		____temp_0 = self.room.story.gate -- 1234
	end -- 1234
	local g = ____temp_0 -- 1234
	if g == nil then -- 1234
		return -- 1236
	end -- 1236
	if story.phase == "gate-send" then -- 1236
		self.phase = "gate-send" -- 1240
		self.gateTick = g.holdTicks -- 1241
		self.gateSpawned = 4 -- 1242
		self.enemies = {} -- 1243
		self.player.x = self.ox + g.doorX - 40 -- 1244
		self.player.y = 0 -- 1245
		self.player.depth = 0 -- 1246
		self.player.vx = 0 -- 1247
		self.player.vy = 0 -- 1248
		self.player.onGround = true -- 1249
		self.partner.x = self.ox + g.waitX -- 1250
		self.partner.y = 0 -- 1251
		self.partner.depth = 0 -- 1252
		self.partner.alive = true -- 1253
		self.cam.x = self.player.x -- 1254
		self.handTicks = 0 -- 1255
		self.handArmed = false -- 1256
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1257
		return -- 1258
	end -- 1258
	if not story.settled then -- 1258
		return -- 1261
	end -- 1261
	self.gateTick = g.holdTicks -- 1264
	self.gateSpawned = 4 -- 1265
	self.enemies = {} -- 1266
	if story.phase == "gate-count" or story.phase == "gate-walk" then -- 1266
		self.phase = story.phase -- 1268
		self.countTick = math.max(story.countTick, 0) -- 1269
		self:swapToChild(g.doorX + 30) -- 1270
		self.countPrevMove = 0 -- 1271
		self.countArmed = false -- 1272
		return -- 1273
	end -- 1273
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1273
		self.phase = story.phase -- 1276
		self.countTick = ____exports.GATE_COUNT_END -- 1277
		self.phaseTick = story.phaseTick -- 1278
		self:swapToChild(g.doorX + 30) -- 1279
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1280
			0, -- 1280
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1280
		) -- 1280
		self.handArmed = false -- 1281
	end -- 1281
end -- 1109
function Play.prototype.buildWorld(self) -- 1286
	local room = self.room -- 1287
	self.boxes = {} -- 1288
	self.floors = {} -- 1289
	local i = 0 -- 1290
	do -- 1290
		i = 0 -- 1291
		while i < #room.floors do -- 1291
			local f = room.floors[i + 1] -- 1292
			local ____self_floors_1 = self.floors -- 1292
			____self_floors_1[#____self_floors_1 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1293
			i = i + 1 -- 1291
		end -- 1291
	end -- 1291
	do -- 1291
		i = 0 -- 1295
		while i < #room.solids do -- 1295
			local s = room.solids[i + 1] -- 1296
			if not s.decorative then -- 1296
				local ____self_boxes_13 = self.boxes -- 1302
				local ____s_x_4 = s.x -- 1303
				local ____temp_5 = s.x + s.w -- 1303
				local ____s_y_6 = s.y -- 1303
				local ____temp_7 = s.y + s.h -- 1303
				local ____temp_2 -- 1304
				if room.depth == nil then -- 1304
					____temp_2 = nil -- 1304
				else -- 1304
					____temp_2 = s.depth -- 1304
				end -- 1304
				local ____temp_8 = s.passable == true -- 1305
				local ____s_label_9 = s.label -- 1305
				local ____s_id_10 = s.id -- 1306
				local ____temp_11 = s.soft == true -- 1306
				local ____temp_12 = s.hidden == true -- 1306
				local ____temp_3 -- 1307
				if s.breakable == nil then -- 1307
					____temp_3 = nil -- 1307
				else -- 1307
					____temp_3 = __TS__ObjectAssign({}, s.breakable) -- 1307
				end -- 1307
				____self_boxes_13[#____self_boxes_13 + 1] = { -- 1302
					x0 = ____s_x_4, -- 1303
					x1 = ____temp_5, -- 1303
					y0 = ____s_y_6, -- 1303
					y1 = ____temp_7, -- 1303
					depth = ____temp_2, -- 1304
					passable = ____temp_8, -- 1305
					label = ____s_label_9, -- 1305
					id = ____s_id_10, -- 1306
					soft = ____temp_11, -- 1306
					hidden = ____temp_12, -- 1306
					breakable = ____temp_3, -- 1307
					interact = s.interact -- 1308
				} -- 1308
			end -- 1308
			i = i + 1 -- 1295
		end -- 1295
	end -- 1295
	do -- 1295
		i = 0 -- 1312
		while i < #room.stairs do -- 1312
			local st = room.stairs[i + 1] -- 1313
			local n = st.steps + 1 -- 1314
			local stepW = (st.x1 - st.x0) / n -- 1315
			local k = 0 -- 1316
			do -- 1316
				k = 0 -- 1317
				while k < n do -- 1317
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1318
					local x0 = st.x0 + stepW * k -- 1319
					local ____self_boxes_17 = self.boxes -- 1322
					local ____temp_15 = x0 + stepW -- 1323
					local ____temp_16 = -8 -- 1323
					local ____temp_14 -- 1324
					if room.depth == nil then -- 1324
						____temp_14 = nil -- 1324
					else -- 1324
						____temp_14 = st.depth -- 1324
					end -- 1324
					____self_boxes_17[#____self_boxes_17 + 1] = { -- 1322
						x0 = x0, -- 1323
						x1 = ____temp_15, -- 1323
						y0 = ____temp_16, -- 1323
						y1 = y, -- 1323
						depth = ____temp_14, -- 1324
						passable = true -- 1325
					} -- 1325
					k = k + 1 -- 1317
				end -- 1317
			end -- 1317
			i = i + 1 -- 1312
		end -- 1312
	end -- 1312
end -- 1286
function Play.prototype.setupCampaign(self) -- 1335
	local wr = self.room -- 1336
	local c = wr.campaign -- 1337
	if c == nil then -- 1337
		return -- 1339
	end -- 1339
	self.roomStartTick = self.run.ticks -- 1341
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1341
		self.run.joined = true -- 1345
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1345
		local ____self_run_19 = self.run -- 1348
		local ____temp_18 -- 1348
		if wr.key == "s2-drygoods" then -- 1348
			____temp_18 = self.run.route ~= "drygoods" -- 1348
		else -- 1348
			____temp_18 = false -- 1348
		end -- 1348
		____self_run_19.joined = ____temp_18 -- 1348
	end -- 1348
	local x = wr.minX + 60 -- 1350
	local y = 0 -- 1351
	local depth = 0 -- 1352
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1352
		x = wr.minX + 210 -- 1354
		depth = -32 -- 1355
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1355
		x = wr.minX + 40 -- 1357
		y = 32 -- 1358
		depth = 32 -- 1359
	end -- 1359
	self.player = { -- 1361
		x = x, -- 1362
		y = y, -- 1362
		depth = depth, -- 1362
		depthSpeed = 0, -- 1362
		vx = 0, -- 1362
		vy = 0, -- 1362
		w = SOLDIER_W, -- 1363
		h = SOLDIER_H, -- 1363
		onGround = y <= 0, -- 1363
		facing = 1, -- 1363
		crouch = false, -- 1363
		rollT = 0, -- 1363
		covered = false, -- 1363
		alive = true -- 1363
	} -- 1363
	self.partner = { -- 1365
		x = x + 60, -- 1366
		y = y, -- 1366
		depth = depth, -- 1366
		depthSpeed = 0, -- 1366
		vx = 0, -- 1366
		vy = 0, -- 1366
		w = CHILD_W, -- 1367
		h = CHILD_H, -- 1367
		onGround = y <= 0, -- 1367
		facing = 1, -- 1367
		crouch = false, -- 1367
		rollT = 0, -- 1367
		covered = false, -- 1367
		alive = true -- 1367
	} -- 1367
	self.cam.x = x -- 1369
	self.cam.y = y + CAM_LOOK_UP -- 1370
	self.phase = "run" -- 1371
	self.hp = self.maxHp -- 1372
	local trial = self.run.trial -- 1373
	if trial ~= nil then -- 1373
		draftRoom(trial, wr.key) -- 1375
		self.maxHp = self.maxHp + trial.ranks.vitality -- 1376
		self.hp = trial.hp -- 1377
	end -- 1377
	self:buildEnemies() -- 1379
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1380
	local i = 0 -- 1381
	do -- 1381
		i = 0 -- 1382
		while i < #self.boxes do -- 1382
			do -- 1382
				local b = self.boxes[i + 1] -- 1383
				if b.id == nil then -- 1383
					goto __continue133 -- 1385
				end -- 1385
				local st = self.run.props[b.id] -- 1387
				if st ~= nil then -- 1387
					b.broken = st.broken -- 1389
					local ____temp_20 -- 1390
					if b.breakable == nil then -- 1390
						____temp_20 = nil -- 1390
					else -- 1390
						____temp_20 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1390
					end -- 1390
					b.breakable = ____temp_20 -- 1390
					b.hidden = b.hidden == true and st.revealed ~= true -- 1391
					if b.hidden then -- 1391
						b.broken = true -- 1393
					end -- 1393
				elseif b.hidden == true then -- 1393
					b.broken = true -- 1397
				end -- 1397
			end -- 1397
			::__continue133:: -- 1397
			i = i + 1 -- 1382
		end -- 1382
	end -- 1382
	if wr.cart.bodyW > 0 then -- 1382
		self.cartAxle = wr.cart.startX -- 1401
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1401
			self.cartAxle = wr.cart.endX -- 1403
			self.cartDocked = true -- 1404
		end -- 1404
	end -- 1404
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1407
end -- 1335
function Play.prototype.log(self, line) -- 1410
	local ____self_run_log_21 = self.run.log -- 1410
	____self_run_log_21[#____self_run_log_21 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1411
	if #self.run.log > 120 then -- 1411
		table.remove(self.run.log, 1) -- 1413
	end -- 1413
end -- 1410
function Play.prototype.buildEnemies(self) -- 1417
	self.enemies = {} -- 1418
	if self.isCampaign then -- 1418
		local i = 0 -- 1420
		do -- 1420
			i = 0 -- 1421
			while i < #self.room.spawns do -- 1421
				local sp = self.room.spawns[i + 1] -- 1422
				local kind = sp.kind or "gunner" -- 1423
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1424
				local ____self_enemies_22 = self.enemies -- 1424
				____self_enemies_22[#____self_enemies_22 + 1] = { -- 1425
					x = sp.x, -- 1426
					y = sp.y, -- 1426
					depth = sp.depth, -- 1426
					w = 26, -- 1426
					h = sp.h, -- 1426
					alive = true, -- 1426
					hitT = 0, -- 1426
					warnT = 0, -- 1426
					fireCd = 40, -- 1426
					kind = kind, -- 1427
					shieldHp = hp, -- 1427
					shieldHpMax = hp, -- 1427
					drop = sp.drop or "none", -- 1427
					homeX = sp.x, -- 1428
					swingT = 0, -- 1428
					awake = false, -- 1428
					squad = i -- 1428
				} -- 1428
				i = i + 1 -- 1421
			end -- 1421
		end -- 1421
		return -- 1431
	end -- 1431
	if self.room.key == "checkpoint" then -- 1431
		local ____self_enemies_23 = self.enemies -- 1431
		____self_enemies_23[#____self_enemies_23 + 1] = { -- 1434
			x = self.ox + 430, -- 1434
			y = 0, -- 1434
			w = 26, -- 1434
			h = 84, -- 1434
			alive = true, -- 1434
			hitT = 0, -- 1434
			warnT = 0, -- 1434
			fireCd = 0 -- 1434
		} -- 1434
		local ____self_enemies_24 = self.enemies -- 1434
		____self_enemies_24[#____self_enemies_24 + 1] = { -- 1435
			x = self.ox + 505, -- 1435
			y = 0, -- 1435
			w = 26, -- 1435
			h = 84, -- 1435
			alive = true, -- 1435
			hitT = 0, -- 1435
			warnT = 0, -- 1435
			fireCd = 0 -- 1435
		} -- 1435
		return -- 1436
	end -- 1436
	if self.room.key == "street" then -- 1436
		local ____self_enemies_25 = self.enemies -- 1436
		____self_enemies_25[#____self_enemies_25 + 1] = { -- 1440
			x = self.ox + 340, -- 1440
			y = 0, -- 1440
			w = 26, -- 1440
			h = 84, -- 1440
			alive = true, -- 1440
			hitT = 0, -- 1440
			warnT = 0, -- 1440
			fireCd = 0 -- 1440
		} -- 1440
		local ____self_enemies_26 = self.enemies -- 1440
		____self_enemies_26[#____self_enemies_26 + 1] = { -- 1441
			x = self.ox + 560, -- 1441
			y = 0, -- 1441
			w = 26, -- 1441
			h = 84, -- 1441
			alive = true, -- 1441
			hitT = 0, -- 1441
			warnT = 0, -- 1441
			fireCd = 0 -- 1441
		} -- 1441
	end -- 1441
end -- 1417
function Play.prototype.emit(self, name, data) -- 1447
	local ____self_events_27 = self.events -- 1447
	____self_events_27[#____self_events_27 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1448
	self.eventSeq = self.eventSeq + 1 -- 1449
	if #self.events > 256 then -- 1449
		table.remove(self.events, 1) -- 1451
	end -- 1451
end -- 1447
function Play.prototype.drainEvents(self) -- 1459
	local out = self.events -- 1460
	self.events = {} -- 1461
	return out -- 1462
end -- 1459
function Play.prototype.adoptEvents(self, events) -- 1471
	if #events == 0 then -- 1471
		return -- 1473
	end -- 1473
	local keep = {} -- 1475
	local i = 0 -- 1476
	do -- 1476
		i = 0 -- 1477
		while i < #events do -- 1477
			do -- 1477
				local e = events[i + 1] -- 1478
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1478
					goto __continue154 -- 1480
				end -- 1480
				keep[#keep + 1] = e -- 1482
			end -- 1482
			::__continue154:: -- 1482
			i = i + 1 -- 1477
		end -- 1477
	end -- 1477
	if #keep == 0 then -- 1477
		return -- 1485
	end -- 1485
	self.events = __TS__ArrayConcat(keep, self.events) -- 1487
	do -- 1487
		i = 0 -- 1488
		while i < #self.events do -- 1488
			self.events[i + 1].seq = i -- 1489
			i = i + 1 -- 1488
		end -- 1488
	end -- 1488
	self.eventSeq = #self.events -- 1491
end -- 1471
function Play.prototype.chooseTalent(self, slot) -- 1494
	local trial = self.run.trial -- 1495
	local talent = trial and trial.offers[slot + 1] -- 1496
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 1496
		return -- 1497
	end -- 1497
	local ____trial_ranks_30, ____talent_31 = trial.ranks, talent -- 1497
	____trial_ranks_30[____talent_31] = ____trial_ranks_30[____talent_31] + 1 -- 1498
	trial.offers = {} -- 1499
	if talent == "vitality" then -- 1499
		self.maxHp = self.maxHp + 1 -- 1501
		self.hp = self.hp + 1 -- 1502
		trial.hp = self.hp -- 1503
	end -- 1503
	self:flashSet(talentNames[talent], 1.2) -- 1505
end -- 1494
function Play.prototype.beginReload(self) -- 1513
	self.reloadT = self:reloadTicks() -- 1514
	local camp = self.room.campaign -- 1515
	if self.run.trial == nil and camp ~= nil and camp.reloadPuzzle == true then -- 1515
		self:openReloadPuzzle() -- 1518
	end -- 1518
end -- 1513
function Play.prototype.openReloadPuzzle(self) -- 1523
	self.reloadOpen = true -- 1524
	self.reloadAnswerTicks = 0 -- 1525
	self.reloadWorldTicks = 0 -- 1526
	self.reloadPath = {RELOAD_START} -- 1527
	self.reloadPendingEffect = "" -- 1528
	self.reloadTryCount = self.reloadTryCount + 1 -- 1529
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 1530
end -- 1523
function Play.prototype.closeReloadPuzzle(self) -- 1534
	self.reloadOpen = false -- 1535
	self.reloadAnswerTicks = 0 -- 1536
	self.reloadWorldTicks = 0 -- 1537
	self.reloadPath = {RELOAD_START} -- 1538
	self.reloadPendingEffect = "" -- 1539
end -- 1534
function Play.prototype.reloadTapNode(self, node) -- 1546
	if not self.reloadOpen then -- 1546
		return -- 1548
	end -- 1548
	local path = self.reloadPath -- 1550
	local last = path[#path] -- 1551
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1551
		self.reloadPath = {RELOAD_START} -- 1553
		self:emit("reloadInvalid", {node = node, at = last}) -- 1554
		return -- 1555
	end -- 1555
	path[#path + 1] = node -- 1557
	if node ~= RELOAD_TARGET then -- 1557
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1559
		return -- 1560
	end -- 1560
	if not reloadPathValid(path) then -- 1560
		self.reloadPath = {RELOAD_START} -- 1563
		self:emit("reloadInvalid", {node = node, at = last}) -- 1564
		return -- 1565
	end -- 1565
	self.reloadPendingEffect = reloadEffectOf(path) -- 1567
	self.reloadOpen = false -- 1568
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1569
	self:flashSet( -- 1572
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1572
		1.4 -- 1572
	) -- 1572
end -- 1546
function Play.prototype.consumeReloadEffect(self) -- 1576
	local e = self.reloadPendingEffect -- 1577
	if e ~= "" then -- 1577
		self.reloadPendingEffect = "" -- 1579
	end -- 1579
	return e -- 1581
end -- 1576
function Play.prototype.echoToSource(self, from, count) -- 1588
	if count == nil then -- 1588
		count = 1 -- 1588
	end -- 1588
	local best = -1 -- 1589
	local bestD = 1000000000 -- 1590
	local i = 0 -- 1591
	local woken = {} -- 1592
	local n = 0 -- 1593
	while n < count do -- 1593
		best = -1 -- 1595
		bestD = 1000000000 -- 1596
		do -- 1596
			i = 0 -- 1597
			while i < #self.enemies do -- 1597
				do -- 1597
					if woken[i] == true then -- 1597
						goto __continue176 -- 1599
					end -- 1599
					local e = self.enemies[i + 1] -- 1601
					if not e.alive then -- 1601
						goto __continue176 -- 1603
					end -- 1603
					local d = math.abs(e.x - from.x) -- 1605
					if d < bestD then -- 1605
						bestD = d -- 1607
						best = i -- 1608
					end -- 1608
				end -- 1608
				::__continue176:: -- 1608
				i = i + 1 -- 1597
			end -- 1597
		end -- 1597
		if best < 0 then -- 1597
			break -- 1612
		end -- 1612
		woken[best] = true -- 1614
		local e = self.enemies[best + 1] -- 1615
		e.awake = true -- 1616
		e.warnT = 0 -- 1617
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1618
		n = n + 1 -- 1619
	end -- 1619
	if n == 0 then -- 1619
		return -- 1622
	end -- 1622
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1624
end -- 1588
function Play.prototype.reloadTicks(self) -- 1627
	local ____temp_34 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 1628
	local ____opt_32 = self.run.trial -- 1628
	return math.max(6, ____temp_34 - 6 * (____opt_32 and ____opt_32.ranks.reload or 0)) -- 1628
end -- 1627
function Play.prototype.update(self, dt, input) -- 1631
	self:syncCraftBench() -- 1632
	local trial = self.run.trial -- 1633
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1633
		return -- 1634
	end -- 1634
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1634
		self:closeCraftBench() -- 1636
		return -- 1637
	end -- 1637
	if input.pause.pressed then -- 1637
		self.paused = not self.paused -- 1640
	end -- 1640
	if self.flashT > 0 then -- 1640
		self.flashT = self.flashT - dt -- 1643
		if self.flashT <= 0 then -- 1643
			self.flash = "" -- 1645
		end -- 1645
	end -- 1645
	if self.traceT > 0 then -- 1645
		self.traceT = self.traceT - dt -- 1649
		if self.traceT <= 0 then -- 1649
			self.trace = nil -- 1651
		end -- 1651
	end -- 1651
	if self.paused then -- 1651
		self:updateCamera(dt) -- 1655
		return -- 1656
	end -- 1656
	if self.craftBench.active then -- 1656
		self:updateCamera(dt) -- 1661
		return -- 1662
	end -- 1662
	if self.reloadOpen then -- 1662
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1668
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1668
			self.reloadOpen = false -- 1670
			self.reloadPendingEffect = "" -- 1671
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1672
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1673
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1673
			self:updateCamera(dt) -- 1675
			return -- 1676
		else -- 1676
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1678
		end -- 1678
	end -- 1678
	self.ticks = self.ticks + 1 -- 1682
	if self.invulnT > 0 then -- 1682
		self.invulnT = self.invulnT - 1 -- 1686
	end -- 1686
	if self.isCampaign then -- 1686
		local ____self_run_35, ____ticks_36 = self.run, "ticks" -- 1686
		____self_run_35[____ticks_36] = ____self_run_35[____ticks_36] + 1 -- 1689
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1690
	end -- 1690
	local p = self.player -- 1692
	self:stepPlayer(p, dt, input) -- 1693
	self:refreshCover(p, input) -- 1695
	if self.carryOn then -- 1695
		self:carryPose() -- 1697
	end -- 1697
	if self.isCampaign then -- 1697
		self:stepCampaign(dt, input) -- 1700
		if not self.carryOn then -- 1700
			self:stepCampaignPartner(dt) -- 1702
		end -- 1702
	end -- 1702
	if trial == nil or not self.run.finished then -- 1702
		self:stepEnemies(dt, input) -- 1710
	end -- 1710
	if trial ~= nil then -- 1710
		trial.hp = self.hp -- 1712
	end -- 1712
	if not self.isCampaign then -- 1712
		self:stepStory(dt, input) -- 1714
		self:stepEscort(dt, input) -- 1715
		self:stepVillage(dt, input) -- 1716
		self:stepChase(dt, input) -- 1717
		self:stepInteract(dt, input) -- 1718
	end -- 1718
	self:updateGate() -- 1720
	self:updateCamera(dt) -- 1721
	self:syncStory() -- 1723
end -- 1631
function Play.prototype.underLowArch(self, a) -- 1730
	local arch = self.room.arch -- 1731
	if arch.h <= 0 then -- 1731
		return false -- 1733
	end -- 1733
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1733
		return false -- 1736
	end -- 1736
	local top = arch.y + arch.h -- 1738
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1739
end -- 1730
function Play.prototype.coverAt(self, a) -- 1746
	local best = nil -- 1747
	local bestGap = 24 -- 1748
	local half = a.w / 2 -- 1749
	local i = 0 -- 1750
	do -- 1750
		i = 0 -- 1751
		while i < #self.boxes do -- 1751
			do -- 1751
				local b = self.boxes[i + 1] -- 1752
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1752
					goto __continue210 -- 1754
				end -- 1754
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1754
					goto __continue210 -- 1757
				end -- 1757
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1759
				if gap < bestGap then -- 1759
					bestGap = gap -- 1761
					best = b -- 1762
				end -- 1762
			end -- 1762
			::__continue210:: -- 1762
			i = i + 1 -- 1751
		end -- 1751
	end -- 1751
	return best -- 1765
end -- 1746
function Play.prototype.nearCover(self, a) -- 1768
	return self:coverAt(a) ~= nil -- 1769
end -- 1768
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1773
	if enemy == nil then -- 1773
		return false -- 1775
	end -- 1775
	local fromRight = enemy.x >= a.x -- 1777
	local edge = fromRight and b.x0 or b.x1 -- 1778
	local ____fromRight_37 -- 1779
	if fromRight then -- 1779
		____fromRight_37 = edge >= a.x - 0.001 and edge <= enemy.x -- 1779
	else -- 1779
		____fromRight_37 = edge <= a.x + 0.001 and edge >= enemy.x -- 1780
	end -- 1780
	local between = ____fromRight_37 -- 1779
	local separation = enemy.x - a.x -- 1781
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1782
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1783
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1784
end -- 1773
function Play.prototype.nearestEnemy(self, a) -- 1787
	local best -- 1788
	local bestD = 1000000000 -- 1789
	local i = 0 -- 1790
	do -- 1790
		i = 0 -- 1791
		while i < #self.enemies do -- 1791
			do -- 1791
				local e = self.enemies[i + 1] -- 1792
				if not e.alive then -- 1792
					goto __continue219 -- 1794
				end -- 1794
				local d = math.abs(e.x - a.x) -- 1796
				if d < bestD then -- 1796
					bestD = d -- 1798
					best = e -- 1799
				end -- 1799
			end -- 1799
			::__continue219:: -- 1799
			i = i + 1 -- 1791
		end -- 1791
	end -- 1791
	return best -- 1802
end -- 1787
function Play.prototype.refreshCover(self, a, input) -- 1806
	if self.childMode then -- 1806
		self.coverNear = false -- 1808
		self.coverHug = false -- 1809
		self.coverEntity = "" -- 1810
		self.coverBlocking = false -- 1811
		a.covered = false -- 1812
		return -- 1813
	end -- 1813
	local b = self:coverAt(a) -- 1815
	self.coverNear = b ~= nil -- 1816
	a.covered = self.coverNear and input.cover.held -- 1817
	self.coverHug = a.covered -- 1818
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1819
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1820
		b, -- 1820
		a, -- 1820
		self:nearestEnemy(a) -- 1820
	) -- 1820
end -- 1806
function Play.prototype.cartHandleInReach(self, a) -- 1824
	if a == nil then -- 1824
		a = self.player -- 1824
	end -- 1824
	local c = self.room.cart -- 1825
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1825
		return false -- 1827
	end -- 1827
	local handleX = self.cartAxle + c.handleOffset -- 1829
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1830
end -- 1824
function Play.prototype.nearLowLedge(self, a) -- 1835
	local reach = 26 -- 1836
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1837
	local x1 = x0 + reach -- 1838
	local i = 0 -- 1839
	do -- 1839
		i = 0 -- 1840
		while i < #self.boxes do -- 1840
			do -- 1840
				local b = self.boxes[i + 1] -- 1841
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1841
					goto __continue228 -- 1843
				end -- 1843
				local rise = b.y1 - a.y -- 1845
				if rise > 0 and rise <= LEDGE_RISE then -- 1845
					return true -- 1847
				end -- 1847
			end -- 1847
			::__continue228:: -- 1847
			i = i + 1 -- 1840
		end -- 1840
	end -- 1840
	return false -- 1850
end -- 1835
function Play.prototype.stepPlayer(self, a, dt, input) -- 1853
	a.depthSpeed = 0 -- 1854
	if not a.alive then -- 1854
		return -- 1856
	end -- 1856
	local isChild = self.childMode -- 1858
	local lowArch = isChild and self:underLowArch(a) -- 1860
	if self:storyLocked() then -- 1860
		a.vx = 0 -- 1863
		a.crouch = isChild and lowArch -- 1864
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1865
		self:fallY(a, dt) -- 1866
		return -- 1867
	end -- 1867
	if not isChild and self.escort.state == "calming" then -- 1867
		a.crouch = false -- 1871
		a.h = SOLDIER_H -- 1872
		a.vx = 0 -- 1873
		self:fallY(a, dt) -- 1874
		return -- 1875
	end -- 1875
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 1877
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 1878
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1879
	local nearCover = not isChild and self:nearCover(a) -- 1880
	a.covered = nearCover and input.cover.held -- 1881
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1883
	if a.rollT > 0 then -- 1883
		a.rollT = a.rollT - dt -- 1887
		a.vx = a.facing * ROLL_SPEED -- 1888
		self:slideX(a, a.vx * dt) -- 1889
		self:fallY(a, dt) -- 1890
		if a.rollT <= 0 then -- 1890
			self:flashSet("翻滚结束", 0.5) -- 1892
		end -- 1892
		return -- 1894
	end -- 1894
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1894
		if input.moveX ~= 0 then -- 1894
			a.facing = input.moveX > 0 and 1 or -1 -- 1899
		end -- 1899
		if self:nearLowLedge(a) then -- 1899
			a.vy = SOLDIER_JUMP -- 1903
			a.onGround = false -- 1904
			self:flashSet("翻上去", 0.3) -- 1905
			return -- 1906
		end -- 1906
		a.rollT = ROLL_TIME -- 1908
		self:flashSet("翻滚", 0.3) -- 1909
		return -- 1910
	end -- 1910
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1913
	if isChild then -- 1913
		if input.cover.held then -- 1913
			speed = CHILD_SLOW -- 1916
		end -- 1916
		if a.crouch then -- 1916
			speed = CHILD_SLOW -- 1919
		elseif self.room.key == "forest" and self.forestPath == "ditch" and a.x >= self.ox + 700 and a.x <= self.ox + 1140 then -- 1919
			speed = CHILD_SPEED * 1.22 -- 1923
		end -- 1923
	elseif a.covered then -- 1923
		speed = SOLDIER_SPEED * 0.45 -- 1926
	end -- 1926
	local handsBusy = self.gripping or gripIntent -- 1930
	local dir = self.gripping and 0 or input.moveX -- 1931
	local depthDir = self.room.depth ~= nil and not handsBusy and (not isChild or self.phase == "prologue-escape") and -input.moveY or 0 -- 1933
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1935
	if dir ~= 0 then -- 1935
		a.facing = dir > 0 and 1 or -1 -- 1937
	end -- 1937
	a.vx = dir * speed * diagonal -- 1939
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1939
		a.vy = CHILD_JUMP -- 1943
		a.onGround = false -- 1944
		self:flashSet("跳", 0.25) -- 1945
	end -- 1945
	local previousDepth = a.depth -- 1949
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1950
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1951
	self:slideX(a, a.vx * dt) -- 1952
	self:fallY(a, dt) -- 1953
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1953
		self:shoot(a) -- 1957
	end -- 1957
end -- 1853
function Play.prototype.stepPartner(self, p, dt) -- 1962
	local a = self.partner -- 1963
	if not a.alive then -- 1963
		return -- 1965
	end -- 1965
	a.crouch = false -- 1967
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1968
	a.vx = 0 -- 1969
	a.depthSpeed = 0 -- 1970
	self:fallY(a, dt) -- 1971
end -- 1962
function Play.prototype.stepEscort(self, dt, input) -- 1978
	local a = self.partner -- 1979
	a.depthSpeed = 0 -- 1980
	if not a.alive then -- 1980
		return -- 1982
	end -- 1982
	if self.room.key == "gatepath" then -- 1982
		if self.carryOn then -- 1982
			return -- 1987
		end -- 1987
		local p = self.player -- 1990
		a.depth = p.depth -- 1991
		a.facing = p.facing -- 1992
		a.crouch = false -- 1993
		a.h = CHILD_H -- 1994
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 1995
		a.y = p.y -- 1996
		a.vy = 0 -- 1997
		a.vx = p.vx -- 1998
		a.onGround = p.onGround -- 1999
		return -- 2000
	end -- 2000
	if not self:escortOn() then -- 2000
		a.vx = 0 -- 2003
		self:fallY(a, dt) -- 2004
		return -- 2005
	end -- 2005
	local p = self.player -- 2007
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 2008
	local hadKnock1 = self.escort.knock1 -- 2009
	local hadKnock2 = self.escort.knock2 -- 2010
	self.calmConsumed = self.escort:update( -- 2011
		input, -- 2011
		p.x, -- 2011
		p.facing, -- 2011
		a.x, -- 2011
		dist -- 2011
	) -- 2011
	if not hadKnock1 and self.escort.knock1 then -- 2011
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 2014
	end -- 2014
	if not hadKnock2 and self.escort.knock2 then -- 2014
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 2017
	end -- 2017
	a.crouch = self.escort.crouchPose -- 2019
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 2020
	if not self.escort.stopped then -- 2020
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 2022
		local previousDepth = a.depth -- 2023
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 2024
		local distance = math.max( -- 2025
			-travel, -- 2025
			math.min(travel, targetDepth - previousDepth) -- 2025
		) -- 2025
		self:slideDepth(a, distance) -- 2026
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2027
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 2027
			a.vy = CHILD_JUMP -- 2029
			a.onGround = false -- 2030
		end -- 2030
	end -- 2030
	local dir = self.escort:moveDir(a.x) -- 2033
	a.vx = dir * CHILD_SPEED -- 2034
	if dir ~= 0 then -- 2034
		a.facing = dir -- 2036
		local before = a.x -- 2037
		self:slideX(a, dir * CHILD_SPEED * dt) -- 2038
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 2038
			a.vy = CHILD_JUMP -- 2041
			a.onGround = false -- 2042
		end -- 2042
	end -- 2042
	self:fallY(a, dt) -- 2045
end -- 1978
function Play.prototype.escortOn(self) -- 2049
	if self.room.key == "checkpoint" then -- 2049
		return true -- 2051
	end -- 2051
	if self.room.key == "gatepath" then -- 2051
		return true -- 2054
	end -- 2054
	if self.room.key == "prologue" then -- 2054
		return self.phase == "prologue-follow" -- 2057
	end -- 2057
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 2057
		return true -- 2061
	end -- 2061
	return self.room.key == "street" -- 2063
end -- 2049
function Play.prototype.storyLocked(self) -- 2067
	if self.caughtT > 0 then -- 2067
		return true -- 2069
	end -- 2069
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 2069
		return true -- 2073
	end -- 2073
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 2073
		return true -- 2076
	end -- 2076
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 2076
		return true -- 2079
	end -- 2079
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2079
		return true -- 2082
	end -- 2082
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2082
		return true -- 2085
	end -- 2085
	if self.craftBench.active then -- 2085
		return true -- 2089
	end -- 2089
	return false -- 2091
end -- 2067
function Play.prototype.swapToChild(self, x) -- 2095
	local tmp = self.player -- 2096
	self.player = self.partner -- 2097
	self.partner = tmp -- 2098
	self.childMode = true -- 2099
	self.player.alive = true -- 2100
	self.player.x = self.ox + x -- 2101
	self.player.y = 0 -- 2102
	self.player.depth = 0 -- 2103
	self.player.depthSpeed = 0 -- 2104
	self.player.vy = 0 -- 2105
	self.player.vx = 0 -- 2106
	self.player.onGround = true -- 2107
	self.player.crouch = false -- 2108
	self.player.h = CHILD_H -- 2109
	self.player.facing = 1 -- 2110
	self.partner.alive = true -- 2111
	self.cam.x = self.player.x -- 2112
end -- 2095
function Play.prototype.swapToSoldier(self, x, childX) -- 2116
	local tmp = self.player -- 2117
	self.player = self.partner -- 2118
	self.partner = tmp -- 2119
	self.childMode = false -- 2120
	self.player.alive = true -- 2121
	self.player.x = self.ox + x -- 2122
	self.player.y = 0 -- 2123
	self.player.depth = 0 -- 2124
	self.player.depthSpeed = 0 -- 2125
	self.player.vy = 0 -- 2126
	self.player.vx = 0 -- 2127
	self.player.onGround = true -- 2128
	self.player.crouch = false -- 2129
	self.player.h = SOLDIER_H -- 2130
	self.player.facing = 1 -- 2131
	self.partner.alive = true -- 2132
	self.partner.x = self.ox + childX -- 2133
	self.partner.y = 0 -- 2134
	self.partner.depth = 0 -- 2135
	self.partner.depthSpeed = 0 -- 2136
	self.partner.vx = 0 -- 2137
	self.partner.vy = 0 -- 2138
	self.partner.onGround = true -- 2139
	self.partner.crouch = true -- 2140
	self.partner.h = CHILD_CROUCH_H -- 2141
	self.cam.x = self.player.x -- 2142
end -- 2116
function Play.prototype.stepStory(self, dt, input) -- 2146
	if self.room.key == "prologue" then -- 2146
		self:stepPrologue(dt, input) -- 2148
	elseif self.room.key == "street" then -- 2148
		self:stepStreet(dt, input) -- 2150
	elseif self.room.key == "gate" then -- 2150
		self:stepGate(dt, input) -- 2152
	elseif self.room.key == "gatepath" then -- 2152
		self:stepGatePath() -- 2154
	elseif self.room.key == "tower" then -- 2154
		self:stepTower(dt, input) -- 2156
	elseif self.room.key == "museum" then -- 2156
		self:stepMuseum(dt, input) -- 2158
	end -- 2158
end -- 2146
function Play.prototype.canPersistProgress(self) -- 2164
	return not self.isCampaign and self.run.source == "official" -- 2165
end -- 2164
function Play.prototype.wellWindow(self) -- 2169
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 2170
end -- 2169
function Play.prototype.nearWell(self) -- 2175
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 2176
end -- 2175
function Play.prototype.pickWell(self) -- 2184
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2184
		return false -- 2186
	end -- 2186
	self.phase = "prologue-well" -- 2188
	self.phaseTick = 0 -- 2189
	self.wellOpen = false -- 2190
	self:flashSet("井沿 · 伸手下去", 1.4) -- 2191
	self:log("旧井拾取") -- 2192
	return true -- 2193
end -- 2184
function Play.prototype.stepPrologue(self, dt, input) -- 2196
	local child = self.partner -- 2197
	if self.museumReturn then -- 2197
		self.museumReturn = false -- 2200
		self.phase = "prologue-wait" -- 2201
		self.phaseTick = 0 -- 2202
		self.player.x = self.ox + 260 -- 2203
		self.player.y = 0 -- 2204
		self.player.depth = 0 -- 2205
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2206
	end -- 2206
	if self.phase == "prologue-wake" then -- 2206
		self.introTick = self.introTick + 1 -- 2210
		if self.introTick == 60 then -- 2210
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2212
		end -- 2212
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2212
			self.phase = "prologue-shadow" -- 2215
			self.introTick = 0 -- 2216
			self:flashSet("门缝里两道影子", 1.2) -- 2217
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2218
		end -- 2218
		return -- 2220
	end -- 2220
	if self.phase == "prologue-shadow" then -- 2220
		self.introTick = self.introTick + 1 -- 2223
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2223
			self.phase = "prologue-escape" -- 2226
			self.introTick = 0 -- 2227
			self.escapeRemaining = self.escapeDuration -- 2228
			self.escapeRetryCount = 0 -- 2229
			self:swapToChild(100) -- 2230
			self:flashSet( -- 2231
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2231
				1.6 -- 2231
			) -- 2231
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2232
		end -- 2232
		return -- 2236
	end -- 2236
	if self.phase == "prologue-escape" then -- 2236
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2239
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2239
			self.phase = "prologue-hide" -- 2242
			self.introTick = 0 -- 2243
			self.player.vx = 0 -- 2244
			self.player.crouch = true -- 2245
			self.player.h = CHILD_CROUCH_H -- 2246
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2247
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2248
			return -- 2252
		end -- 2252
		if self.escapeRemaining <= 0 then -- 2252
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2256
			self.player.x = self.ox + 100 -- 2257
			self.player.y = 0 -- 2258
			self.player.depth = 0 -- 2259
			self.player.vx = 0 -- 2260
			self.player.vy = 0 -- 2261
			self.escapeRemaining = self.escapeDuration -- 2262
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2263
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2264
			return -- 2265
		end -- 2265
		return -- 2267
	end -- 2267
	if self.phase == "prologue-hide" then -- 2267
		self.introTick = self.introTick + 1 -- 2270
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2270
			self.phase = "prologue-wait" -- 2273
			self.phaseTick = 0 -- 2274
			self.introTick = 0 -- 2275
			self:swapToSoldier(260, 300) -- 2276
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2277
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2278
		end -- 2278
		return -- 2280
	end -- 2280
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2283
	if self.phase == "prologue-wait" then -- 2283
		child.crouch = true -- 2285
		child.h = CHILD_CROUCH_H -- 2286
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2286
			self:pickWell() -- 2288
			return -- 2289
		end -- 2289
		if not self.wellOpen and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2289
			if self:canPersistProgress() then -- 2289
				self.archive.museumPhase = "well_reflect" -- 2295
				self.archiveDirty = true -- 2296
			end -- 2296
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2298
			return -- 2299
		end -- 2299
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2301
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2303
		if near and input.interact.pressed then -- 2303
			self.phase = "prologue-give" -- 2305
			self.phaseTick = 0 -- 2306
			self:flashSet("递出针套", 1) -- 2307
		end -- 2307
		return -- 2309
	end -- 2309
	if self.phase == "prologue-well" then -- 2309
		self.phaseTick = self.phaseTick + 1 -- 2313
		if self.phaseTick == 12 then -- 2313
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2315
		elseif self.phaseTick >= 30 then -- 2315
			self.phase = "prologue-wait" -- 2317
			self.phaseTick = 0 -- 2318
			self.wellTaken = true -- 2319
			self.wellOpen = false -- 2320
			self.run.archive.artifactOwned = true -- 2321
			self.archiveDirty = true -- 2322
			self:emit("artifactFound", { -- 2323
				x = self.ox + self.wellX, -- 2324
				y = 0, -- 2324
				room = "prologue", -- 2324
				once = true, -- 2324
				source = self.run.source -- 2325
			}) -- 2325
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2327
			self:log("井底取到时间穿梭器") -- 2328
		end -- 2328
		return -- 2330
	end -- 2330
	if self.phase == "prologue-give" then -- 2330
		self.phaseTick = self.phaseTick + 1 -- 2333
		if self.phaseTick == 12 then -- 2333
			self:flashSet("针套递过去", 0.7) -- 2335
		elseif self.phaseTick == 36 then -- 2335
			self:flashSet("纸条塞进针套", 0.9) -- 2337
		elseif self.phaseTick >= 60 then -- 2337
			self.phase = "prologue-follow" -- 2339
			self.phaseTick = 0 -- 2340
			child.crouch = false -- 2341
			child.h = CHILD_H -- 2342
			self:flashSet("她跟上了", 1.2) -- 2343
		end -- 2343
		return -- 2345
	end -- 2345
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2345
		self:requestRoom("street", "序章跟到门口") -- 2349
		self:flashSet("进街道", 1.2) -- 2350
	end -- 2350
end -- 2196
function Play.prototype.stepStreet(self, dt, input) -- 2355
	local p = self.player -- 2356
	local c = self.partner -- 2357
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2357
		self:requestRoom("checkpoint", "两人都到街尾") -- 2359
		self:flashSet("到检查站", 1.2) -- 2360
	end -- 2360
end -- 2355
function Play.prototype.stepGate(self, dt, input) -- 2365
	local ____temp_38 -- 2366
	if self.room.story == nil then -- 2366
		____temp_38 = nil -- 2366
	else -- 2366
		____temp_38 = self.room.story.gate -- 2366
	end -- 2366
	local g = ____temp_38 -- 2366
	if g == nil then -- 2366
		return -- 2368
	end -- 2368
	local p = self.player -- 2370
	if self.phase == "gate-idle" then -- 2370
		local a = self.partner -- 2373
		local gap = g.waitX - a.x -- 2374
		if math.abs(gap) > 3 then -- 2374
			a.facing = gap > 0 and 1 or -1 -- 2376
			a.vx = a.facing * CHILD_SPEED -- 2377
			local beforeX = a.x -- 2378
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2379
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2379
				a.vy = CHILD_JUMP -- 2381
				a.onGround = false -- 2382
			end -- 2382
			self:fallY(a, dt) -- 2384
		else -- 2384
			a.vx = 0 -- 2386
			a.x = g.waitX -- 2387
		end -- 2387
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2390
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2391
		if self.gateNeedConfirm then -- 2391
			if not input.interact.held then -- 2391
				self.gateRestartArmed = true -- 2396
			end -- 2396
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2396
				self.gateNeedConfirm = false -- 2399
				self.gateRestartArmed = true -- 2400
				self.phase = "gate-hold" -- 2401
				self.gateTick = 0 -- 2402
				self.gateSpawned = 0 -- 2403
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2404
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2405
			end -- 2405
			return -- 2407
		end -- 2407
		if atWinch and atWait then -- 2407
			self.phase = "gate-hold" -- 2410
			self.gateTick = 0 -- 2411
			self.gateSpawned = 0 -- 2412
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2413
		end -- 2413
		return -- 2415
	end -- 2415
	if self.phase == "gate-hold" then -- 2415
		self.gateTick = self.gateTick + 1 -- 2418
		local marks = {0, 540, 900, 1500} -- 2420
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2420
			local idx = self.gateSpawned -- 2422
			local ____self_enemies_39 = self.enemies -- 2422
			____self_enemies_39[#____self_enemies_39 + 1] = { -- 2423
				x = self.ox + 620 + idx * 62, -- 2424
				y = 0, -- 2424
				w = 26, -- 2424
				h = 84, -- 2424
				alive = true, -- 2425
				hitT = 0, -- 2425
				warnT = 0, -- 2425
				fireCd = 90 + idx * 45 -- 2425
			} -- 2425
			self.gateSpawned = self.gateSpawned + 1 -- 2427
			self:flashSet( -- 2428
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2428
				0.9 -- 2428
			) -- 2428
		end -- 2428
		if self.gateTick == 900 then -- 2428
			self:flashSet("灯灭了", 1) -- 2431
		elseif self.gateTick == 2100 then -- 2431
			self:flashSet("门底压下来了", 1) -- 2433
		end -- 2433
		if self.gateTick >= g.holdTicks then -- 2433
			self:captureGateBlood() -- 2438
			self.phase = "gate-send" -- 2439
			self.phaseTick = 0 -- 2440
			self.enemies = {} -- 2442
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2443
		end -- 2443
		return -- 2445
	end -- 2445
	if self.phase == "gate-send" then -- 2445
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2448
		if near and input.interact.pressed then -- 2448
			self:commitRoute() -- 2451
			self:swapToChild(g.doorX + 30) -- 2452
			self.phase = "gate-count" -- 2453
			self.countTick = 0 -- 2454
			self.countArmed = false -- 2456
			self.countPrevMove = input.moveX -- 2457
			self:flashSet("门开了 · 送她出去", 1.8) -- 2458
		end -- 2458
		return -- 2460
	end -- 2460
	if self.phase == "gate-count" then -- 2460
		self.countTick = self.countTick + 1 -- 2463
		if self.countTick == 360 then -- 2463
			self:flashSet("门关上", 0.9) -- 2465
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2465
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2467
			if self.storyRoute == "soldier" then -- 2467
				self.phase = "gate-wait" -- 2473
				self.phaseTick = 0 -- 2474
				self.knocks = 1 -- 2475
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2476
				self.handArmed = not input.interact.held -- 2478
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2479
			else -- 2479
				self:flashSet("数到二十", 2.2) -- 2481
			end -- 2481
		end -- 2481
		local prevMove = self.countPrevMove -- 2486
		self.countPrevMove = input.moveX -- 2487
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2487
			if prevMove <= 0 and input.moveX > 0 then -- 2487
				self.countArmed = true -- 2490
			end -- 2490
			if self.countArmed and input.moveX > 0 then -- 2490
				self.phase = "gate-walk" -- 2493
				self.phaseTick = 0 -- 2494
				self:flashSet("她迈出第一步", 1.4) -- 2495
				self:emit("storyExit", { -- 2496
					route = "child", -- 2496
					via = "walk", -- 2496
					countTick = self.countTick, -- 2496
					hp = self.hp, -- 2496
					maxHp = self.maxHp -- 2496
				}) -- 2496
			end -- 2496
		end -- 2496
		return -- 2499
	end -- 2499
	if self.phase == "gate-wait" then -- 2499
		self.phaseTick = self.phaseTick + 1 -- 2503
		if self.phaseTick == 12 then -- 2503
			self.knocks = 2 -- 2505
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2506
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2507
		end -- 2507
		local held = input.interact.held or self.intentGateReunionHold -- 2509
		if not held then -- 2509
			if self.handTicks > 0 then -- 2509
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2512
			end -- 2512
			self.handTicks = 0 -- 2514
			self.handArmed = true -- 2515
			return -- 2516
		end -- 2516
		if self.handArmed then -- 2516
			self.handTicks = self.handTicks + 1 -- 2519
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2519
				self.intentGateReunionHold = false -- 2521
				self.phase = "gate-hand" -- 2522
				self.phaseTick = 0 -- 2523
				self.handDone = true -- 2524
				self.tied = true -- 2525
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2526
				if not self.lineSaid then -- 2526
					self.lineSaid = true -- 2528
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2529
				end -- 2529
				self:flashSet("我们走吧。", 3) -- 2531
			end -- 2531
		end -- 2531
		return -- 2534
	end -- 2534
	if self.phase == "gate-hand" then -- 2534
		self.phaseTick = self.phaseTick + 1 -- 2538
		if self.phaseTick == 30 then -- 2538
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2540
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2540
			self:emit("storyExit", { -- 2542
				route = "soldier", -- 2542
				via = "hand", -- 2542
				handTicks = self.handTicks, -- 2542
				hp = self.hp, -- 2542
				maxHp = self.maxHp -- 2542
			}) -- 2542
			self:requestRoom("gatepath", "牵手同行") -- 2543
		end -- 2543
		return -- 2545
	end -- 2545
	if self.phase == "gate-walk" then -- 2545
		if self.player.x >= g.exitX then -- 2545
			self:requestRoom("outside", "走出城门") -- 2550
			self:flashSet("出城门 · 城外", 1.4) -- 2551
		end -- 2551
	end -- 2551
end -- 2365
function Play.prototype.captureGateBlood(self) -- 2560
	self.hpAtGate = self.hp -- 2561
	self.maxHpAtGate = self.maxHp -- 2562
end -- 2560
function Play.prototype.commitRoute(self) -- 2569
	if self.storySettled then -- 2569
		return -- 2571
	end -- 2571
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2573
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2574
	self.hpAtGate = hp -- 2575
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2576
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2577
	self.storySettled = true -- 2578
	self:emit("storyRouteLocked", { -- 2579
		route = self.storyRoute, -- 2580
		hp = self.hp, -- 2580
		maxHp = self.maxHp, -- 2580
		hpAtGate = self.hpAtGate, -- 2581
		maxHpAtGate = self.maxHpAtGate -- 2581
	}) -- 2581
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2583
end -- 2569
function Play.prototype.syncStory(self) -- 2587
	if self.isCampaign and self.run.trial ~= nil then -- 2587
		return -- 2589
	end -- 2589
	local s = self.run.story -- 2591
	if s == nil then -- 2591
		return -- 2593
	end -- 2593
	s.hp = self.hp -- 2595
	s.maxHp = self.maxHp -- 2596
	s.route = self.storyRoute -- 2597
	s.settled = self.storySettled -- 2598
	s.hpAtGate = self.hpAtGate -- 2599
	s.maxHpAtGate = self.maxHpAtGate -- 2600
	s.handDone = self.handDone -- 2601
	s.lineSaid = self.lineSaid -- 2602
	s.tied = self.tied -- 2603
	s.carry = self.carryOn -- 2604
	s.museumReturn = self.museumReturn -- 2605
	s.escortDone = self.escortDone -- 2606
	s.craftedWeapon = self.run.story.craftedWeapon -- 2607
	s.ending = self.run.story.ending -- 2608
	if self.room.key == "gate" then -- 2608
		s.phase = self.phase -- 2610
		s.countTick = self.countTick -- 2611
		s.phaseTick = self.phaseTick -- 2612
		s.handTicks = self.handTicks -- 2613
	end -- 2613
	if self.room.key == "prologue" then -- 2613
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2613
			s.phase = self.phase -- 2618
			s.phaseTick = self.phaseTick -- 2619
		end -- 2619
	end -- 2619
	if self.room.key == "tower" then -- 2619
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2619
			s.phase = self.phase -- 2625
			s.phaseTick = self.phaseTick -- 2626
		end -- 2626
	end -- 2626
end -- 2587
function Play.prototype.stepGatePath(self) -- 2632
	local ____temp_40 -- 2633
	if self.room.story == nil then -- 2633
		____temp_40 = nil -- 2633
	else -- 2633
		____temp_40 = self.room.story.gatepath -- 2633
	end -- 2633
	local gp = ____temp_40 -- 2633
	if self.phase == "gatepath-start" then -- 2633
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2633
			self.carryOn = true -- 2636
			self.phase = "gatepath-carry" -- 2637
			self.phaseTick = 0 -- 2638
			self.pathDone = true -- 2639
			self.escortDone = false -- 2640
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2641
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2642
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2643
		end -- 2643
		return -- 2645
	end -- 2645
	if self.phase == "gatepath-carry" then -- 2645
		self.phaseTick = self.phaseTick + 1 -- 2648
		if self.phaseTick == 20 then -- 2648
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2650
		end -- 2650
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2650
			self:requestRoom(gp.next, "背负进首战") -- 2653
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2654
		end -- 2654
	end -- 2654
end -- 2632
function Play.prototype.carryPose(self) -- 2663
	local p = self.player -- 2664
	local a = self.partner -- 2665
	a.alive = true -- 2666
	a.x = p.x - p.facing * 12 -- 2667
	a.y = p.y + 26 -- 2668
	a.depth = p.depth -- 2669
	a.vx = p.vx -- 2670
	a.vy = 0 -- 2671
	a.onGround = true -- 2672
	a.crouch = false -- 2673
	a.h = CHILD_CROUCH_H -- 2674
	a.facing = p.facing -- 2675
end -- 2663
function Play.prototype.stepMuseum(self, dt, input) -- 2683
	self.partner.alive = false -- 2684
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2685
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2688
	local intentTarget = self.pendingMuseumIntentTarget -- 2689
	self.pendingMuseumIntentTarget = "" -- 2690
	local interactHit = input.interact.pressed or intentTarget ~= "" -- 2691
	if self.phase == "museum-cabinet" then -- 2691
		if atCase and interactHit then -- 2691
			self.phase = "museum-hall" -- 2694
			self.phaseTick = 0 -- 2695
			if self:canPersistProgress() then -- 2695
				self.archive.museumPhase = "hall_walk" -- 2697
				self.archiveDirty = true -- 2698
			end -- 2698
			self:emit( -- 2700
				"museumStep", -- 2700
				{ -- 2700
					step = "cabinet", -- 2700
					x = self.ox + mu.cabinetX, -- 2700
					persisted = self:canPersistProgress() -- 2700
				} -- 2700
			) -- 2700
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2701
		end -- 2701
		return -- 2703
	end -- 2703
	if self.phase == "museum-hall" then -- 2703
		if self.player.x >= self.ox + mu.hallX and interactHit then -- 2703
			self.phase = "museum-lamp" -- 2707
			self.phaseTick = 0 -- 2708
			if self:canPersistProgress() then -- 2708
				self.archive.museumPhase = "lamp_turn" -- 2710
				self.archiveDirty = true -- 2711
			end -- 2711
			self:emit( -- 2713
				"museumStep", -- 2713
				{ -- 2713
					step = "hall", -- 2713
					x = self.ox + mu.hallX, -- 2713
					persisted = self:canPersistProgress() -- 2713
				} -- 2713
			) -- 2713
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2714
		end -- 2714
		return -- 2716
	end -- 2716
	if self.phase == "museum-lamp" then -- 2716
		if self.player.x >= self.ox + mu.lampX and interactHit then -- 2716
			self.phase = "museum-return" -- 2720
			self.phaseTick = 0 -- 2721
			if self:canPersistProgress() then -- 2721
				self.archive.museumPhase = "return_cabinet" -- 2723
				self.archiveDirty = true -- 2724
			end -- 2724
			self:emit( -- 2726
				"museumStep", -- 2726
				{ -- 2726
					step = "lamp", -- 2726
					x = self.ox + mu.lampX, -- 2726
					persisted = self:canPersistProgress() -- 2726
				} -- 2726
			) -- 2726
			self:flashSet("灯 · 转向西窗", 1.8) -- 2727
		end -- 2727
		return -- 2729
	end -- 2729
	if self.phase == "museum-return" then -- 2729
		if atCase and interactHit then -- 2729
			self.phase = "museum-knock" -- 2733
			self.phaseTick = 0 -- 2734
			self:emit( -- 2735
				"museumStep", -- 2735
				{ -- 2735
					step = "knock", -- 2735
					count = 1, -- 2735
					x = self.ox + mu.cabinetX, -- 2735
					persisted = self:canPersistProgress() -- 2735
				} -- 2735
			) -- 2735
			self:flashSet("回柜边 · 第一下", 0.8) -- 2736
		end -- 2736
		return -- 2738
	end -- 2738
	if self.phase == "museum-knock" then -- 2738
		self.phaseTick = self.phaseTick + 1 -- 2741
		if self.phaseTick == 8 then -- 2741
			self:emit( -- 2743
				"museumStep", -- 2743
				{ -- 2743
					step = "knock", -- 2743
					count = 2, -- 2743
					x = self.ox + mu.cabinetX, -- 2743
					persisted = self:canPersistProgress() -- 2743
				} -- 2743
			) -- 2743
			self:flashSet("回柜边 · 第二下", 0.8) -- 2744
		elseif self.phaseTick >= 36 then -- 2744
			self.phase = "museum-done" -- 2746
			self.phaseTick = 0 -- 2747
			if self:canPersistProgress() then -- 2747
				self.archive.museumSeen = true -- 2749
				self.archive.museumPhase = "done" -- 2750
				self.archiveDirty = true -- 2751
			end -- 2751
			self:emit( -- 2753
				"museumDone", -- 2753
				{ -- 2753
					steps = 4, -- 2753
					museumSeen = self.archive.museumSeen, -- 2753
					persisted = self:canPersistProgress() -- 2753
				} -- 2753
			) -- 2753
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2754
			self:log("博物馆 · 回柜边") -- 2755
		end -- 2755
		return -- 2757
	end -- 2757
	if interactHit then -- 2757
		self.museumReturn = true -- 2760
		self:requestRoom("prologue", "回柜边") -- 2761
	end -- 2761
end -- 2683
function Play.prototype.openTowerDoor(self) -- 2765
	self.towerDoorOpen = true -- 2766
	do -- 2766
		local i = 0 -- 2767
		while i < #self.boxes do -- 2767
			if self.boxes[i + 1].id == "tower_door" then -- 2767
				self.boxes[i + 1].hidden = true -- 2769
			end -- 2769
			i = i + 1 -- 2767
		end -- 2767
	end -- 2767
	self.run.story.segments.tower_door = true -- 2772
end -- 2765
function Play.prototype.stepTower(self, dt, input) -- 2775
	local ____temp_41 -- 2776
	if self.room.story == nil then -- 2776
		____temp_41 = nil -- 2776
	else -- 2776
		____temp_41 = self.room.story.tower -- 2776
	end -- 2776
	local t = ____temp_41 -- 2776
	if t == nil then -- 2776
		return -- 2778
	end -- 2778
	if self.storyRoute == "soldier" and self.partner.alive then -- 2778
		local targetX = math.max(self.room.minX + 40, self.player.x - 36) -- 2782
		local gap = targetX - self.partner.x -- 2783
		if math.abs(gap) > 2 then -- 2783
			local dir = gap > 0 and 1 or -1 -- 2785
			local stepDist = math.min( -- 2786
				math.abs(gap), -- 2786
				SOLDIER_SPEED * dt -- 2786
			) -- 2786
			self.partner.facing = dir -- 2787
			self.partner.vx = dir * SOLDIER_SPEED -- 2788
			local ____self_partner_42, ____x_43 = self.partner, "x" -- 2788
			____self_partner_42[____x_43] = ____self_partner_42[____x_43] + dir * stepDist -- 2789
		else -- 2789
			self.partner.vx = 0 -- 2791
			self.partner.facing = 1 -- 2792
		end -- 2792
	end -- 2792
	if self.phase == "tower-wait" then -- 2792
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2796
		if near and input.interact.pressed then -- 2796
			self.phase = "tower-knock" -- 2798
			self.phaseTick = 0 -- 2799
			self.knocks = 1 -- 2800
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2801
			self:flashSet("叩两下 · 第一声", 0.6) -- 2802
		end -- 2802
		return -- 2804
	end -- 2804
	if self.phase == "tower-knock" then -- 2804
		self.phaseTick = self.phaseTick + 1 -- 2807
		if self.phaseTick == 12 then -- 2807
			self.knocks = 2 -- 2809
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2810
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 2811
		elseif self.phaseTick >= t.knockTicks then -- 2811
			self:openTowerDoor() -- 2813
			self.phase = "tower-enter" -- 2814
			self.phaseTick = 0 -- 2815
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 2816
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 2817
		end -- 2817
		return -- 2819
	end -- 2819
	if self.phase == "tower-enter" then -- 2819
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 2819
			self.phase = "tower-desk" -- 2823
			self.phaseTick = 0 -- 2824
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 2825
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 2826
		end -- 2826
		return -- 2828
	end -- 2828
	if self.phase == "tower-desk" then -- 2828
		local deskX = self.ox + 605 -- 2831
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 2832
		if not near or not input.interact.held then -- 2832
			self.deskHold = 0 -- 2834
			return -- 2835
		end -- 2835
		self.deskHold = self.deskHold + 1 -- 2837
		if self.deskHold == 12 then -- 2837
			self:flashSet("针套 · 放在桌上", 1) -- 2839
		elseif self.deskHold == 24 then -- 2839
			self:flashSet("指南针 · 压住纸条", 1) -- 2841
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 2841
			self.towerHanded = true -- 2843
			self.deskHold = 0 -- 2844
			self.run.story.segments.tower_handover = true -- 2845
			self.phase = "tower-given" -- 2846
			self.phaseTick = 0 -- 2847
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 2848
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 2853
		end -- 2853
		return -- 2855
	end -- 2855
	if self.phase == "tower-given" then -- 2855
		local soldier = self.storyRoute == "soldier" -- 2860
		self.phaseTick = self.phaseTick + 1 -- 2861
		if self.phaseTick == 60 then -- 2861
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 2863
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 2864
		elseif self.phaseTick == 120 then -- 2864
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 2866
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 2866
			self.phase = "tower-end" -- 2868
			self.phaseTick = 0 -- 2869
			if not self.run.finished then -- 2869
				self.run.finished = true -- 2871
				local ending = soldier and "reunion" or "lamp" -- 2872
				self.run.story.ending = ending -- 2873
				local ____soldier_44 -- 2876
				if soldier then -- 2876
					____soldier_44 = self.run.story.segments.escort5 == true -- 2877
				else -- 2877
					____soldier_44 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 2878
				end -- 2878
				local played = ____soldier_44 -- 2876
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 2879
				if official then -- 2879
					if soldier then -- 2879
						self.run.archive.soldierCleared = true -- 2883
					else -- 2883
						self.run.archive.childCleared = true -- 2885
					end -- 2885
					self.archiveDirty = true -- 2887
				end -- 2887
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 2889
				self:emit("endingReached", { -- 2890
					route = soldier and "soldier" or "child", -- 2891
					ending = ending, -- 2892
					official = official, -- 2893
					source = self.run.source, -- 2894
					lines = {self.endingLines[1], self.endingLines[2]}, -- 2895
					childCleared = self.run.archive.childCleared, -- 2896
					soldierCleared = self.run.archive.soldierCleared, -- 2897
					artifactOwned = self.run.archive.artifactOwned, -- 2898
					equipped = self.equippedWeapon -- 2899
				}) -- 2899
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 2901
			end -- 2901
		end -- 2901
		return -- 2904
	end -- 2904
	self.phaseTick = self.phaseTick + 1 -- 2906
	if input.interact.pressed or input.retry.pressed then -- 2906
		self.restartStory = true -- 2909
		self:requestRoom("prologue", "片尾再玩") -- 2910
		self:flashSet("回到序章", 1.4) -- 2911
	end -- 2911
end -- 2775
function Play.prototype.stepChase(self, dt, input) -- 2916
	if self.caughtT > 0 then -- 2916
		self.caughtT = self.caughtT - dt -- 2918
		if self.caughtT <= 0 then -- 2918
			self:recoverFromCaught() -- 2920
		end -- 2920
		return -- 2922
	end -- 2922
	if self.room.key == "village" then -- 2922
		self:stepScavChase() -- 2925
	elseif self.room.key == "forest" then -- 2925
		self:stepForestRoute() -- 2927
		self:stepDog(dt) -- 2928
		if self.player.x >= self.ox + 1450 then -- 2928
			self:requestRoom("tower", "到林缘北塔") -- 2931
			self:flashSet("林缘 · 北塔", 1.4) -- 2932
		end -- 2932
	end -- 2932
end -- 2916
function Play.prototype.stepScavChase(self) -- 2938
	local s = self.room.scavenger -- 2939
	if s == nil then -- 2939
		return -- 2941
	end -- 2941
	local p = self.player -- 2943
	if self.passed and p.x > self.ox + 440 then -- 2943
		if self.scavChase then -- 2943
			self.scavChase = false -- 2947
			self.scavState = "back" -- 2948
			self.scavT = 0 -- 2949
		end -- 2949
		return -- 2951
	end -- 2951
	local dx = p.x - self.scavX -- 2953
	local dist = math.abs(dx) -- 2954
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 2955
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 2956
	if not self.scavChase then -- 2956
		if visible then -- 2956
			self.scavSee = self.scavSee + 1 -- 2959
			if self.scavSee >= 24 then -- 2959
				self.scavChase = true -- 2961
				self.scavState = "chase" -- 2962
				self.scavTargetX = p.x -- 2963
				self:flashSet("他看见你了", 1.2) -- 2964
			end -- 2964
		else -- 2964
			self.scavSee = 0 -- 2967
		end -- 2967
		return -- 2969
	end -- 2969
	local dir = p.x > self.scavX and 1 or -1 -- 2972
	self.scavX = self.scavX + dir * 96 / 60 -- 2973
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 2973
		self:caught() -- 2975
		return -- 2976
	end -- 2976
	if hidden then -- 2976
		self.scavSee = 0 -- 2980
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 2981
		self.scavT = self.scavT - 1 -- 2982
		if self.scavT <= 0 then -- 2982
			self.scavChase = false -- 2984
			self.scavState = "patrol" -- 2985
			self:flashSet("他失去了目标", 1) -- 2986
		end -- 2986
	end -- 2986
end -- 2938
function Play.prototype.stepDog(self, dt) -- 2992
	local ____temp_45 -- 2993
	if self.room.story == nil then -- 2993
		____temp_45 = nil -- 2993
	else -- 2993
		____temp_45 = self.room.story.dog -- 2993
	end -- 2993
	local dog = ____temp_45 -- 2993
	if dog == nil then -- 2993
		return -- 2995
	end -- 2995
	local p = self.player -- 2997
	local ox = self.ox -- 2998
	local dist = math.abs(p.x - self.dogX) -- 2999
	local inBurrowCover = p.crouch and p.x >= ox + 300 and p.x <= ox + 460 -- 3000
	local inBrushCover = p.crouch and (p.x >= ox + 700 and p.x <= ox + 790 or p.x >= ox + 1150 and p.x <= ox + 1240) -- 3001
	local sheltered = inBurrowCover or inBrushCover -- 3005
	local inDitchSprint = not p.crouch and self.forestPath == "ditch" and p.x >= ox + 700 and p.x <= ox + 1140 -- 3006
	local effectiveRange = inDitchSprint and dog.range * 1.25 or dog.range -- 3007
	local earNeedTicks = inDitchSprint and 12 or 18 -- 3008
	if self.dogState == "patrol" then -- 3008
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 3010
		if self.dogX < dog.x0 then -- 3010
			self.dogX = dog.x0 -- 3012
			self.dogDir = 1 -- 3013
		elseif self.dogX > dog.x1 then -- 3013
			self.dogX = dog.x1 -- 3015
			self.dogDir = -1 -- 3016
		end -- 3016
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 3018
		if not sheltered and not p.crouch and moving and dist < effectiveRange then -- 3018
			self.dogState = "ear" -- 3020
			self.dogT = earNeedTicks -- 3021
			self.dogTargetX = p.x -- 3022
			self:flashSet(inDitchSprint and "旧渠枯枝响 · 狗立刻转耳" or "狗转耳朵", 0.8) -- 3023
		end -- 3023
		return -- 3025
	end -- 3025
	if self.dogState == "ear" then -- 3025
		if sheltered then -- 3025
			self.dogState = "sniff" -- 3029
			self.dogT = 45 -- 3030
			self:flashSet("钻进遮蔽 · 狗顿住了", 0.9) -- 3031
			return -- 3032
		end -- 3032
		self.dogT = self.dogT - 1 -- 3034
		if self.dogT <= 0 then -- 3034
			self.dogState = "chase" -- 3036
			self.dogTargetX = p.x -- 3037
			self:flashSet("狗追来了", 1.4) -- 3038
		end -- 3038
		return -- 3040
	end -- 3040
	if self.dogState == "chase" then -- 3040
		local dir = p.x > self.dogX and 1 or -1 -- 3043
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 3044
		if not sheltered and math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 3044
			self:caught() -- 3046
			self.dogState = "sniff" -- 3047
			self.dogT = 60 -- 3048
		elseif dist > effectiveRange * 1.5 or p.crouch or sheltered then -- 3048
			self.dogState = "sniff" -- 3050
			self.dogT = 60 -- 3051
			self:flashSet(inBurrowCover and "树根窄洞遮住身形 · 狗停下了" or "狗停下了", 0.9) -- 3052
		end -- 3052
		return -- 3054
	end -- 3054
	if self.dogState == "sniff" then -- 3054
		self.dogT = self.dogT - 1 -- 3057
		if self.dogT <= 0 then -- 3057
			self.dogState = "back" -- 3059
		end -- 3059
		return -- 3061
	end -- 3061
	local dir = dog.x0 > self.dogX and 1 or -1 -- 3064
	self.dogX = self.dogX + dir * dog.speed * dt -- 3065
	if math.abs(self.dogX - dog.x0) < 2 then -- 3065
		self.dogX = dog.x0 -- 3067
		self.dogState = "patrol" -- 3068
	end -- 3068
end -- 2992
function Play.prototype.stepForestRoute(self) -- 3073
	local p = self.player -- 3074
	local ox = self.ox -- 3075
	if self.forestPath == "" then -- 3075
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 3075
			self.forestPath = "burrow" -- 3078
			self.run.story.segments.forest_burrow = true -- 3079
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 3080
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 3081
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 3081
			self.forestPath = "ditch" -- 3083
			self.run.story.segments.forest_ditch = true -- 3084
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 3085
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 3086
		end -- 3086
	end -- 3086
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 3086
		self.waterSeen = true -- 3090
		self.run.story.segments.water_lantern = true -- 3091
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 3092
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 3093
	end -- 3093
end -- 3073
function Play.prototype.caught(self) -- 3097
	self.caughtT = 1 -- 3098
	self:flashSet("被抓 · 回到安全点", 1.6) -- 3099
end -- 3097
function Play.prototype.recoverFromCaught(self) -- 3103
	local p = self.player -- 3104
	p.x = self.ox + 140 -- 3105
	p.y = 0 -- 3106
	p.vy = 0 -- 3107
	p.vx = 0 -- 3108
	p.onGround = true -- 3109
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3109
		self.scavX = self.room.scavenger.x0 -- 3111
		self.scavState = "patrol" -- 3112
		self.scavSee = 0 -- 3113
		self.scavChase = false -- 3114
		self.scavT = 0 -- 3115
	end -- 3115
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3115
		self.dogX = self.room.story.dog.x0 -- 3118
		self.dogState = "patrol" -- 3119
		self.dogT = 0 -- 3120
	end -- 3120
	self.cam.x = p.x -- 3122
	self.cam.y = p.y + CAM_LOOK_UP -- 3123
	self:flashSet("回到安全点", 1.2) -- 3124
end -- 3103
function Play.prototype.updateGate(self) -- 3128
	if self.room.key ~= "checkpoint" then -- 3128
		self.gateOpen = false -- 3130
		return -- 3131
	end -- 3131
	local function inZone(x) -- 3133
		return x >= self.ox + 792 and x <= self.ox + 928 -- 3133
	end -- 3133
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 3134
end -- 3128
function Play.prototype.addItem(self, kind) -- 3140
	local inv = self.run.inventory -- 3141
	if kind == "shield" then -- 3141
		if inv.shield >= TOOL_CAP then -- 3141
			return false -- 3144
		end -- 3144
		inv.shield = inv.shield + 1 -- 3146
		return true -- 3147
	end -- 3147
	if kind == "wedge" then -- 3147
		if inv.wedge >= CONSUMABLE_CAP then -- 3147
			return false -- 3151
		end -- 3151
		inv.wedge = inv.wedge + 1 -- 3153
		return true -- 3154
	end -- 3154
	if kind == "ammo" then -- 3154
		if inv.ammo >= CONSUMABLE_CAP then -- 3154
			return false -- 3158
		end -- 3158
		inv.ammo = inv.ammo + 1 -- 3160
		return true -- 3161
	end -- 3161
	if kind == "scrap" then -- 3161
		inv.scrap = inv.scrap + 1 -- 3165
		return true -- 3166
	end -- 3166
	if kind == "wood" then -- 3166
		inv.wood = inv.wood + 1 -- 3169
		return true -- 3170
	end -- 3170
	if kind == "bell" then -- 3170
		inv.bell = inv.bell + 1 -- 3173
		return true -- 3174
	end -- 3174
	if kind == "pass" then -- 3174
		inv.pass = inv.pass + 1 -- 3177
		return true -- 3178
	end -- 3178
	if kind == "quickbelt" then -- 3178
		inv.quickbelt = inv.quickbelt + 1 -- 3181
		return true -- 3182
	end -- 3182
	return false -- 3184
end -- 3140
function Play.prototype.findBox(self, id) -- 3187
	local i = 0 -- 3188
	do -- 3188
		i = 0 -- 3189
		while i < #self.boxes do -- 3189
			if self.boxes[i + 1].id == id then -- 3189
				return self.boxes[i + 1] -- 3191
			end -- 3191
			i = i + 1 -- 3189
		end -- 3189
	end -- 3189
	return nil -- 3194
end -- 3187
function Play.prototype.findWedgeTarget(self) -- 3198
	local best = nil -- 3199
	local bestD = 0 -- 3200
	local i = 0 -- 3201
	do -- 3201
		i = 0 -- 3202
		while i < #self.boxes do -- 3202
			do -- 3202
				local b = self.boxes[i + 1] -- 3203
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3203
					goto __continue479 -- 3205
				end -- 3205
				if not self:nearBox(b, 26) then -- 3205
					goto __continue479 -- 3208
				end -- 3208
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3210
				if best == nil or d < bestD then -- 3210
					best = b -- 3212
					bestD = d -- 3213
				end -- 3213
			end -- 3213
			::__continue479:: -- 3213
			i = i + 1 -- 3202
		end -- 3202
	end -- 3202
	return best -- 3216
end -- 3198
function Play.prototype.stepCraft(self, input) -- 3224
	local inv = self.run.inventory -- 3225
	local ____opt_46 = self.run.trial -- 3225
	local required = CRAFT_TICKS - 6 * (____opt_46 and ____opt_46.ranks.craft or 0) -- 3226
	if self.craftT > 0 then -- 3226
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3226
			self.craftT = 0 -- 3230
			self:flashSet("制作中断", 0.8) -- 3231
			return true -- 3232
		end -- 3232
		self.craftT = self.craftT + 1 -- 3234
		if self.craftT >= required then -- 3234
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3234
				inv.scrap = inv.scrap - 1 -- 3237
				inv.wedge = inv.wedge + 1 -- 3238
				self:flashSet("制得木楔", 1.2) -- 3239
				self:log("制木楔") -- 3240
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3241
			end -- 3241
			self.craftT = 0 -- 3243
		end -- 3243
		return true -- 3245
	end -- 3245
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3245
		self.craftT = 1 -- 3248
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3249
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3250
		return true -- 3251
	end -- 3251
	return false -- 3253
end -- 3224
function Play.prototype.nearBox(self, b, reach) -- 3256
	local p = self.player -- 3257
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3258
end -- 3256
function Play.prototype.findInteract(self) -- 3264
	local p = self.player -- 3265
	local best = nil -- 3266
	local bestD = 1000000000 -- 3267
	local i = 0 -- 3268
	do -- 3268
		i = 0 -- 3269
		while i < #self.boxes do -- 3269
			do -- 3269
				local b = self.boxes[i + 1] -- 3270
				if b.interact == nil or b.broken == true then -- 3270
					goto __continue492 -- 3272
				end -- 3272
				if not self:nearBox(b, b.interact.reach or 27) then -- 3272
					goto __continue492 -- 3275
				end -- 3275
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3277
				if d < bestD then -- 3277
					bestD = d -- 3279
					best = b -- 3280
				end -- 3280
			end -- 3280
			::__continue492:: -- 3280
			i = i + 1 -- 3269
		end -- 3269
	end -- 3269
	return best -- 3283
end -- 3264
function Play.prototype.stepCampaign(self, dt, input) -- 3287
	local wr = self.room -- 3288
	local p = self.player -- 3289
	if self.reloadT > 0 then -- 3289
		self.reloadT = self.reloadT - 1 -- 3291
	end -- 3291
	if self.bracedShield ~= nil then -- 3291
		self.bracedShield.x = p.x + p.facing * 26 -- 3295
		self.bracedShield.y = p.y -- 3296
		local shBox = __TS__ArrayFind( -- 3297
			self.boxes, -- 3297
			function(____, b) return b.id == "braced_shield" end -- 3297
		) -- 3297
		if shBox ~= nil then -- 3297
			shBox.x0 = self.bracedShield.x - 15 -- 3299
			shBox.x1 = self.bracedShield.x + 15 -- 3300
			shBox.y0 = self.bracedShield.y -- 3301
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3302
		end -- 3302
	end -- 3302
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3302
		self.run.route = "drygoods" -- 3308
		self.run.joined = false -- 3309
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3310
		self:log("转布行线") -- 3311
	end -- 3311
	if wr.key == "escort3" then -- 3311
		local benchX = wr.minX + 560 -- 3315
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 60 -- 3316
		if nearBench and input.interact.pressed then -- 3316
			self:openCraftBench() -- 3318
		end -- 3318
	end -- 3318
	local i = 0 -- 3322
	do -- 3322
		i = 0 -- 3323
		while i < #self.pickups do -- 3323
			do -- 3323
				local pk = self.pickups[i + 1] -- 3324
				if self.run.taken[pk.id] == true then -- 3324
					goto __continue505 -- 3326
				end -- 3326
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3328
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3329
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3329
					if not self:addItem(pk.kind) then -- 3329
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3333
						self:log("满包拒绝 " .. pk.kind) -- 3334
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3335
						goto __continue505 -- 3336
					end -- 3336
					self.run.taken[pk.id] = true -- 3338
					self:flashSet("拾取 " .. pk.label, 1) -- 3339
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3340
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3341
				end -- 3341
			end -- 3341
			::__continue505:: -- 3341
			i = i + 1 -- 3323
		end -- 3323
	end -- 3323
	if not self:stepCraft(input) and input.interact.pressed then -- 3323
		self:campaignInteract() -- 3345
	end -- 3345
	self:stepCampaignCart(dt, input) -- 3347
	self:stepCampaignGoal() -- 3348
	self:campaignCheckpoint() -- 3349
end -- 3287
function Play.prototype.campaignCheckpoint(self) -- 3353
	local i = 0 -- 3354
	do -- 3354
		i = 0 -- 3355
		while i < #self.room.marks do -- 3355
			do -- 3355
				local m = self.room.marks[i + 1] -- 3356
				if m.kind ~= 0 then -- 3356
					goto __continue512 -- 3358
				end -- 3358
				local dx = self.player.x - m.x -- 3360
				local dy = self.player.y - m.y -- 3361
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3361
					self.checkpoint = m.x -- 3363
					self:captureCheckpoint(m.x) -- 3364
					self:flashSet("检查点", 1) -- 3365
				end -- 3365
			end -- 3365
			::__continue512:: -- 3365
			i = i + 1 -- 3355
		end -- 3355
	end -- 3355
end -- 3353
function Play.prototype.campaignInteract(self) -- 3371
	local b = self:findInteract() -- 3372
	if b ~= nil then -- 3372
		self:useInteract(b) -- 3374
		return -- 3375
	end -- 3375
	local inv = self.run.inventory -- 3377
	if inv.wedge > 0 then -- 3377
		local w = self:findWedgeTarget() -- 3379
		if w ~= nil then -- 3379
			if w.breakable ~= nil then -- 3379
				local ____w_breakable_48, ____hp_49 = w.breakable, "hp" -- 3379
				____w_breakable_48[____hp_49] = ____w_breakable_48[____hp_49] + (w.breakable.wedgeHp or 1) -- 3382
			end -- 3382
			inv.wedge = inv.wedge - 1 -- 3384
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3385
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 3387
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3388
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3389
			return -- 3390
		end -- 3390
	end -- 3390
	if inv.ammo > 0 and self.reloadT > 0 then -- 3390
		self.reloadT = 0 -- 3395
		self:closeReloadPuzzle() -- 3396
		inv.ammo = inv.ammo - 1 -- 3397
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3398
		self:log("用备用弹包") -- 3399
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3400
		return -- 3401
	end -- 3401
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 3401
		local p = self.player -- 3405
		self.bracedShield = { -- 3406
			x = p.x + p.facing * 26, -- 3406
			y = p.y, -- 3406
			w = 30, -- 3406
			h = 64, -- 3406
			hp = 1 -- 3406
		} -- 3406
		local ____self_boxes_50 = self.boxes -- 3406
		____self_boxes_50[#____self_boxes_50 + 1] = { -- 3407
			x0 = self.bracedShield.x - 15, -- 3408
			x1 = self.bracedShield.x + 15, -- 3408
			y0 = p.y, -- 3409
			y1 = p.y + 64, -- 3409
			depth = {min = -46, max = 46}, -- 3409
			label = "架起的残盾", -- 3409
			id = "braced_shield", -- 3409
			soft = true -- 3410
		} -- 3410
		inv.shield = inv.shield - 1 -- 3413
		self:flashSet("架残盾 · 挡一发", 1.2) -- 3414
		self:log("架残盾") -- 3415
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3416
		return -- 3417
	end -- 3417
	if inv.pass > 0 and self.run.joined == false then -- 3417
		inv.pass = inv.pass - 1 -- 3420
		self.run.joined = true -- 3421
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3422
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3423
		return -- 3424
	end -- 3424
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3426
end -- 3371
function Play.prototype.useInteract(self, b) -- 3429
	local kind = b.interact == nil and "" or b.interact.kind -- 3430
	local wr = self.room -- 3431
	if kind == "open_board" then -- 3431
		b.broken = true -- 3433
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3434
		for ____, cover in ipairs(self.boxes) do -- 3435
			if cover.id == "s2_board_cover" then -- 3435
				cover.broken = false -- 3437
				cover.hidden = false -- 3438
			end -- 3438
		end -- 3438
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3441
		self.run.joined = true -- 3442
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3443
		self:log("放下窗板") -- 3444
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3445
		return -- 3446
	end -- 3446
	if kind == "lower_curtain" then -- 3446
		for ____, curtain in ipairs(self.boxes) do -- 3449
			if curtain.id == "c2_curtain" then -- 3449
				curtain.broken = false -- 3451
				curtain.hidden = false -- 3452
			end -- 3452
		end -- 3452
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3455
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3456
		self:log("放下木帘") -- 3457
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3458
		return -- 3459
	end -- 3459
	if kind == "raise_latch" then -- 3459
		if wr.key == "c2-granary" and not self.cartDocked then -- 3459
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3463
			return -- 3464
		end -- 3464
		b.broken = true -- 3466
		self.objectiveDone = true -- 3467
		if wr.key == "c1-yard" then -- 3467
			self.run.c1Latch = true -- 3470
			self.run.joined = true -- 3471
			for ____, door in ipairs(self.boxes) do -- 3472
				if door.id == "c1_door" then -- 3472
					door.broken = true -- 3474
				end -- 3474
			end -- 3474
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3477
		else -- 3477
			self.run.c2Latch = true -- 3479
			self.run.joined = true -- 3480
		end -- 3480
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3482
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3483
		self:log("抬闩") -- 3484
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3485
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3486
	end -- 3486
end -- 3429
function Play.prototype.stepCampaignCart(self, dt, input) -- 3491
	local wr = self.room -- 3492
	local c = wr.cart -- 3493
	if c.bodyW <= 0 then -- 3493
		return -- 3495
	end -- 3495
	local p = self.player -- 3497
	local handleX = self.cartAxle + c.handleOffset -- 3498
	if not self.gripping then -- 3498
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3498
			self.gripping = true -- 3502
			self:flashSet("握住车柄 · A/D 推", 1) -- 3503
		end -- 3503
		return -- 3505
	end -- 3505
	if input.interact.pressed then -- 3505
		self.gripping = false -- 3508
		self:flashSet("松手", 0.5) -- 3509
		return -- 3510
	end -- 3510
	if not self.cartDocked then -- 3510
		if input.moveX ~= 0 and not self:stuckCart() then -- 3510
			self.cartAxle = math.max( -- 3514
				c.startX, -- 3514
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3514
			) -- 3514
		end -- 3514
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3514
			self.cartExposed = true -- 3519
			local gun = nil -- 3520
			local gi = 0 -- 3521
			do -- 3521
				gi = 0 -- 3522
				while gi < #self.enemies do -- 3522
					local e = self.enemies[gi + 1] -- 3523
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3523
						gun = e -- 3525
						break -- 3526
					end -- 3526
					gi = gi + 1 -- 3522
				end -- 3522
			end -- 3522
			if gun ~= nil then -- 3522
				self:campaignEnemyFire(gun) -- 3530
			end -- 3530
		end -- 3530
		p.x = self.cartAxle + c.handleOffset -- 3533
		p.y = c.baseY -- 3534
		p.depth = c.depth or 0 -- 3535
		p.vx = 0 -- 3536
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3536
			self.cartAxle = c.endX -- 3538
			self.cartDocked = true -- 3539
			self.gripping = false -- 3540
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3541
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3542
			self:flashSet("车轮入窝", 1.2) -- 3543
			self:log("车轮入窝") -- 3544
		end -- 3544
	end -- 3544
end -- 3491
function Play.prototype.stuckCart(self) -- 3550
	local i = 0 -- 3551
	do -- 3551
		i = 0 -- 3552
		while i < #self.boxes do -- 3552
			do -- 3552
				local b = self.boxes[i + 1] -- 3553
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3553
					goto __continue554 -- 3555
				end -- 3555
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3557
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3557
					return true -- 3559
				end -- 3559
			end -- 3559
			::__continue554:: -- 3559
			i = i + 1 -- 3552
		end -- 3552
	end -- 3552
	return false -- 3562
end -- 3550
function Play.prototype.stepCampaignGoal(self) -- 3566
	local wr = self.room -- 3567
	local c = wr.campaign -- 3568
	if c == nil then -- 3568
		return -- 3570
	end -- 3570
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3570
		self.objectiveDone = true -- 3573
	end -- 3573
	if c.goal == "reach_exit" then -- 3573
		self.objectiveDone = true -- 3576
	end -- 3576
	if not self.objectiveDone then -- 3576
		return -- 3579
	end -- 3579
	local p = self.player -- 3581
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3582
	if p.x < c.exitX or not partnerOk then -- 3582
		return -- 3584
	end -- 3584
	if self.run.story.segments[wr.key] ~= true then -- 3584
		self.run.story.segments[wr.key] = true -- 3588
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3589
	end -- 3589
	if wr.key == "escort5" then -- 3589
		self.escortDone = true -- 3593
		self.run.story.escortDone = true -- 3594
	end -- 3594
	if c.next ~= nil and c.next ~= "" then -- 3594
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3597
		self:flashSet("过关 · " .. c.next, 1.2) -- 3598
	elseif not self.run.finished then -- 3598
		self.run.finished = true -- 3600
		self:flashSet( -- 3601
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3601
			2 -- 3601
		) -- 3601
		self:log("C2 灰盒完成") -- 3602
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3603
	end -- 3603
end -- 3566
function Play.prototype.stepCampaignPartner(self, dt) -- 3608
	local a = self.partner -- 3609
	local wr = self.room -- 3610
	local cp = wr.companion -- 3611
	if not a.alive then -- 3611
		return -- 3613
	end -- 3613
	local p = self.player -- 3615
	if self.craftBench.active then -- 3615
		a.vx = 0 -- 3618
		return -- 3619
	end -- 3619
	local wait = false -- 3621
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3622
	local targetDepth = p.depth -- 3623
	if self.run.joined == false then -- 3623
		wait = true -- 3625
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3626
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3627
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3627
		wait = true -- 3629
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3630
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3631
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3631
		wait = true -- 3633
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3634
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3635
	end -- 3635
	if self.partnerStuck > 0.3 then -- 3635
		a.x = a.x + a.facing * 44 -- 3639
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3640
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3641
		self.partnerLaneHold = 1.1 -- 3642
		self.partnerStuck = 0 -- 3643
	end -- 3643
	if self.partnerLaneHold > 0 then -- 3643
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3646
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3647
	end -- 3647
	local dx = targetX - a.x -- 3649
	if not wait and math.abs(dx) > 74 then -- 3649
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3651
		local before = a.x -- 3652
		a.vx = dx > 0 and speed or -speed -- 3653
		a.facing = dx > 0 and 1 or -1 -- 3654
		self:slideX(a, a.vx * dt) -- 3655
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3655
			a.vy = CHILD_JUMP -- 3658
			a.onGround = false -- 3659
		end -- 3659
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3661
	else -- 3661
		a.vx = 0 -- 3663
		self.partnerStuck = 0 -- 3664
	end -- 3664
	local dz = targetDepth - a.depth -- 3666
	if math.abs(dz) > 6 then -- 3666
		local step = math.max( -- 3668
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3668
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3668
		) -- 3668
		a.depth = a.depth + step -- 3669
	end -- 3669
	a.depthSpeed = 0 -- 3671
	a.h = CHILD_H -- 3672
	a.crouch = false -- 3673
	self:fallY(a, dt) -- 3674
end -- 3608
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3678
	local p = self.player -- 3679
	local i = 0 -- 3680
	do -- 3680
		i = 0 -- 3681
		while i < #self.enemies do -- 3681
			do -- 3681
				local ____opt_51 = self.run.trial -- 3681
				if ____opt_51 and ____opt_51.lost then -- 3681
					return -- 3682
				end -- 3682
				local e = self.enemies[i + 1] -- 3683
				if not e.alive then -- 3683
					goto __continue581 -- 3685
				end -- 3685
				if e.hitT > 0 then -- 3685
					e.hitT = e.hitT - dt -- 3688
				end -- 3688
				if e.kind == "target" then -- 3688
					if not e.alive and e.hitT <= 0 then -- 3688
						e.alive = true -- 3693
					end -- 3693
					goto __continue581 -- 3695
				end -- 3695
				if e.kind == "breaker" then -- 3695
					self:stepBreaker(e, dt) -- 3698
					goto __continue581 -- 3699
				end -- 3699
				if e.kind == "shield" then -- 3699
					self:stepShield(e, dt, input) -- 3702
					goto __continue581 -- 3703
				end -- 3703
				local dx = e.x - p.x -- 3706
				if not e.awake then -- 3706
					if math.abs(dx) > 520 then -- 3706
						goto __continue581 -- 3709
					end -- 3709
					e.awake = true -- 3711
					e.fireCd = 48 -- 3712
					goto __continue581 -- 3713
				end -- 3713
				if math.abs(dx) > ENEMY_RANGE then -- 3713
					goto __continue581 -- 3716
				end -- 3716
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 3716
					goto __continue581 -- 3721
				end -- 3721
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 3721
					goto __continue581 -- 3724
				end -- 3724
				if self:blockedShot(e, p) then -- 3724
					if e.warnT > 0 then -- 3724
						e.warnT = 0 -- 3730
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3731
					end -- 3731
					goto __continue581 -- 3733
				end -- 3733
				if e.warnT > 0 then -- 3733
					e.warnT = e.warnT - 1 -- 3736
					if e.warnT <= 0 then -- 3736
						self:campaignEnemyFire(e) -- 3738
					end -- 3738
				elseif e.fireCd > 0 then -- 3738
					e.fireCd = e.fireCd - 1 -- 3741
					if e.fireCd <= 0 then -- 3741
						e.warnT = WARN_TICKS -- 3743
					end -- 3743
				else -- 3743
					e.fireCd = 40 -- 3746
				end -- 3746
			end -- 3746
			::__continue581:: -- 3746
			i = i + 1 -- 3681
		end -- 3681
	end -- 3681
end -- 3678
function Play.prototype.blockedShot(self, e, p) -- 3752
	local eDepth = e.depth or 0 -- 3753
	local ex = e.x -- 3754
	local ey = e.y + e.h * 0.62 -- 3756
	local px = p.x -- 3757
	local py = p.y + p.h * 0.55 -- 3758
	local dx = px - ex -- 3759
	local dyScreen = py + p.depth - (ey + eDepth) -- 3760
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3761
	if len < 0.01 then -- 3761
		return false -- 3763
	end -- 3763
	local ray = { -- 3767
		x = ex, -- 3768
		y = ey, -- 3768
		dx = dx / len, -- 3769
		dy = (py - ey) / len, -- 3769
		depth = eDepth, -- 3770
		dDepth = (p.depth - eDepth) / len -- 3770
	} -- 3770
	local best = -1 -- 3772
	local j = 0 -- 3773
	do -- 3773
		j = 0 -- 3774
		while j < #self.boxes do -- 3774
			do -- 3774
				local b = self.boxes[j + 1] -- 3775
				if b.broken == true or b.passable == true or b.hidden == true then -- 3775
					goto __continue604 -- 3777
				end -- 3777
				if b.id == "braced_shield" then -- 3777
					goto __continue604 -- 3782
				end -- 3782
				local t = hitBox(ray, b) -- 3784
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3784
					best = t -- 3788
				end -- 3788
			end -- 3788
			::__continue604:: -- 3788
			j = j + 1 -- 3774
		end -- 3774
	end -- 3774
	return best >= 0 -- 3791
end -- 3752
function Play.prototype.campaignEnemyFire(self, e) -- 3794
	local p = self.player -- 3795
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3796
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3796
		local ____self_bracedShield_53, ____hp_54 = self.bracedShield, "hp" -- 3796
		____self_bracedShield_53[____hp_54] = ____self_bracedShield_53[____hp_54] - 1 -- 3798
		self.boxes = __TS__ArrayFilter( -- 3799
			self.boxes, -- 3799
			function(____, b) return b.id ~= "braced_shield" end -- 3799
		) -- 3799
		self.bracedShield = nil -- 3800
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3801
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3802
		return -- 3803
	end -- 3803
	if self:blockedShot(e, p) then -- 3803
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3806
		return -- 3807
	end -- 3807
	local cover = self:blockedByCover(e, p) -- 3809
	if cover ~= nil and self.coverHug then -- 3809
		self.coveredFlash = 0.5 -- 3811
		self:flashSet("掩体挡下", 0.6) -- 3812
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3813
		return -- 3818
	end -- 3818
	if self.invulnT > 0 then -- 3818
		return -- 3821
	end -- 3821
	local ____opt_55 = self.run.trial -- 3821
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_55 and ____opt_55.ranks.guard or 0) -- 3823
	self.craftT = 0 -- 3824
	self.hp = self.hp - 1 -- 3825
	self:emit("actorHit", { -- 3826
		target = "player", -- 3826
		amount = 1, -- 3826
		hp = self.hp, -- 3826
		maxHp = self.maxHp, -- 3826
		enemyX = e.x -- 3826
	}) -- 3826
	self:flashSet( -- 3827
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3827
		0.8 -- 3827
	) -- 3827
	if self.hp <= 0 then -- 3827
		self:campaignFailed() -- 3829
	end -- 3829
end -- 3794
function Play.prototype.stepShield(self, e, dt, input) -- 3834
	local p = self.player -- 3835
	local dx = p.x - e.x -- 3836
	local adx = math.abs(dx) -- 3837
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 3840
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 3841
	if adx > 150 then -- 3841
		local before = e.x -- 3843
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 3844
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 3844
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3847
		end -- 3847
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 3847
		local fromFront = (e.x - p.x) * p.facing > 0 -- 3852
		local rollDodges = p.rollT > 0 and fromFront -- 3853
		if not rollDodges and self.invulnT <= 0 then -- 3853
			local ____opt_57 = self.run.trial -- 3853
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_57 and ____opt_57.ranks.guard or 0) -- 3855
			self.craftT = 0 -- 3856
			self.hp = self.hp - 1 -- 3857
			self:emit("actorHit", { -- 3858
				target = "player", -- 3858
				amount = 1, -- 3858
				hp = self.hp, -- 3858
				maxHp = self.maxHp, -- 3858
				enemyX = e.x -- 3858
			}) -- 3858
			self:flashSet( -- 3859
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3859
				0.8 -- 3859
			) -- 3859
			if self.hp <= 0 then -- 3859
				self:campaignFailed() -- 3861
				return -- 3862
			end -- 3862
		end -- 3862
		e.swingT = 70 -- 3865
	end -- 3865
	if (e.swingT or 0) > 0 then -- 3865
		e.swingT = (e.swingT or 0) - 1 -- 3868
	end -- 3868
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 3868
		local dd = p.depth - (e.depth or 0) -- 3871
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 3872
	end -- 3872
end -- 3834
function Play.prototype.stepBreaker(self, e, dt) -- 3877
	local p = self.player -- 3878
	if e.awake ~= true then -- 3878
		if math.abs(p.x - e.x) < 560 then -- 3878
			e.awake = true -- 3881
		else -- 3881
			return -- 3883
		end -- 3883
	end -- 3883
	local target = nil -- 3886
	local bestD = 1000000000 -- 3887
	local i = 0 -- 3888
	do -- 3888
		i = 0 -- 3889
		while i < #self.boxes do -- 3889
			do -- 3889
				local b = self.boxes[i + 1] -- 3890
				if b.breakable == nil or b.broken == true then -- 3890
					goto __continue628 -- 3892
				end -- 3892
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 3894
				if d < bestD then -- 3894
					bestD = d -- 3896
					target = b -- 3897
				end -- 3897
			end -- 3897
			::__continue628:: -- 3897
			i = i + 1 -- 3889
		end -- 3889
	end -- 3889
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 3900
	local dx = tx - e.x -- 3901
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 3902
	if math.abs(dx) > reach then -- 3902
		local before = e.x -- 3904
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 3905
		if math.abs(e.x - before) < 0.3 then -- 3905
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3907
		end -- 3907
	elseif (e.swingT or 0) <= 0 then -- 3907
		e.swingT = 64 -- 3910
		if target ~= nil then -- 3910
			self:damageProp(target, 2) -- 3912
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 3912
			local ____opt_59 = self.run.trial -- 3912
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_59 and ____opt_59.ranks.guard or 0) -- 3914
			self.craftT = 0 -- 3915
			self.hp = self.hp - 1 -- 3916
			self:emit("actorHit", { -- 3917
				target = "player", -- 3917
				amount = 1, -- 3917
				hp = self.hp, -- 3917
				maxHp = self.maxHp, -- 3917
				enemyX = e.x -- 3917
			}) -- 3917
			self:flashSet("破障手近身", 0.8) -- 3918
			if self.hp <= 0 then -- 3918
				self:campaignFailed() -- 3920
				return -- 3921
			end -- 3921
		end -- 3921
	end -- 3921
	if (e.swingT or 0) > 0 then -- 3921
		e.swingT = (e.swingT or 0) - 1 -- 3926
	end -- 3926
end -- 3877
function Play.prototype.campaignFailed(self) -- 3930
	if self.run.trial ~= nil then -- 3930
		self.run.trial.lost = true -- 3932
		self.wantRoom = "" -- 3933
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3934
		return -- 3935
	end -- 3935
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 3935
		self:restartEscortFromDeath() -- 3940
		return -- 3941
	end -- 3941
	local p = self.player -- 3943
	self.hp = self.maxHp -- 3944
	self.invulnT = INVULN_RESPAWN_TICKS -- 3945
	self.reloadT = 0 -- 3946
	self:closeReloadPuzzle() -- 3947
	self.gripping = false -- 3948
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 3949
	self:log("被击倒") -- 3950
	p.x = self.room.minX + 90 -- 3951
	p.y = 0 -- 3952
	p.depth = 0 -- 3953
	p.vx = 0 -- 3954
	p.vy = 0 -- 3955
	p.onGround = true -- 3956
	p.rollT = 0 -- 3957
	self.partner.x = p.x - 50 -- 3958
	self.partner.y = 0 -- 3959
	self.partner.depth = 0 -- 3960
	self.cam.x = p.x -- 3961
	local i = 0 -- 3962
	do -- 3962
		i = 0 -- 3963
		while i < #self.enemies do -- 3963
			do -- 3963
				local e = self.enemies[i + 1] -- 3964
				if not e.alive then -- 3964
					goto __continue642 -- 3966
				end -- 3966
				e.x = e.homeX == nil and e.x or e.homeX -- 3968
				e.warnT = 0 -- 3969
				e.fireCd = 40 -- 3970
				e.swingT = 0 -- 3971
				e.awake = false -- 3972
			end -- 3972
			::__continue642:: -- 3972
			i = i + 1 -- 3963
		end -- 3963
	end -- 3963
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3974
end -- 3930
function Play.prototype.isEscortRoom(self) -- 3978
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 3979
end -- 3978
function Play.prototype.restartEscortFromDeath(self) -- 3987
	local story = self.run.story -- 3988
	local inv = self.run.inventory -- 3989
	self.hp = self.maxHp -- 3990
	story.hp = self.maxHp -- 3991
	story.cp = nil -- 3992
	self.checkpointSnap = nil -- 3993
	story.carry = false -- 3994
	self.carryOn = false -- 3995
	story.craftedWeapon = "" -- 3996
	self.equippedWeapon = "standard_gun" -- 3997
	story.escortDone = false -- 3998
	self.escortDone = false -- 3999
	story.segments = {} -- 4000
	inv.wood = 0 -- 4001
	inv.bell = 0 -- 4002
	inv.scrap = 0 -- 4003
	inv.wedge = 0 -- 4004
	inv.ammo = 0 -- 4005
	inv.quickbelt = 0 -- 4006
	inv.shield = 0 -- 4007
	inv.pass = 0 -- 4008
	local taken = self.run.taken -- 4009
	local keys = __TS__ObjectKeys(taken) -- 4010
	local i = 0 -- 4011
	do -- 4011
		i = 0 -- 4012
		while i < #keys do -- 4012
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 4012
				__TS__Delete(taken, keys[i + 1]) -- 4014
			end -- 4014
			i = i + 1 -- 4012
		end -- 4012
	end -- 4012
	self.run.joined = true -- 4017
	self.reloadT = 0 -- 4018
	self:closeReloadPuzzle() -- 4019
	self.gripping = false -- 4020
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 4021
	self:log("男主线失败 · 回 escort1") -- 4022
	self:emit("campaignFailed", { -- 4023
		room = self.room.key, -- 4024
		hp = 0, -- 4024
		maxHp = self.maxHp, -- 4024
		reset = true, -- 4025
		to = "escort1", -- 4025
		route = self.storyRoute -- 4025
	}) -- 4025
	self:requestRoom("escort1", "男主线失败重开") -- 4027
end -- 3987
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 4031
	local i = 0 -- 4032
	do -- 4032
		i = 0 -- 4033
		while i < #self.enemies do -- 4033
			do -- 4033
				if i == skipIndex then -- 4033
					goto __continue651 -- 4035
				end -- 4035
				local e = self.enemies[i + 1] -- 4037
				if not e.alive or math.abs(e.x - center.x) > radius then -- 4037
					goto __continue651 -- 4039
				end -- 4039
				e.fireCd = 150 -- 4041
				e.warnT = 0 -- 4042
			end -- 4042
			::__continue651:: -- 4042
			i = i + 1 -- 4033
		end -- 4033
	end -- 4033
end -- 4031
function Play.prototype.stepEnemies(self, dt, input) -- 4046
	local i = 0 -- 4047
	do -- 4047
		i = 0 -- 4048
		while i < #self.enemies do -- 4048
			local e = self.enemies[i + 1] -- 4049
			if e.hitT > 0 then -- 4049
				e.hitT = e.hitT - dt -- 4051
			end -- 4051
			i = i + 1 -- 4048
		end -- 4048
	end -- 4048
	if self.coveredFlash > 0 then -- 4048
		self.coveredFlash = self.coveredFlash - dt -- 4055
	end -- 4055
	if self.isCampaign then -- 4055
		self:stepCampaignEnemies(dt, input) -- 4058
		return -- 4059
	end -- 4059
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 4059
		return -- 4063
	end -- 4063
	do -- 4063
		i = 0 -- 4065
		while i < #self.enemies do -- 4065
			do -- 4065
				local e = self.enemies[i + 1] -- 4066
				if not e.alive then -- 4066
					goto __continue662 -- 4068
				end -- 4068
				if e.warnT > 0 then -- 4068
					e.warnT = e.warnT - 1 -- 4071
					if e.warnT <= 0 then -- 4071
						self:enemyFire(e, input) -- 4073
					end -- 4073
					goto __continue662 -- 4075
				end -- 4075
				if e.fireCd > 0 then -- 4075
					e.fireCd = e.fireCd - 1 -- 4078
					if e.fireCd <= 0 then -- 4078
						e.warnT = WARN_TICKS -- 4080
					end -- 4080
				else -- 4080
					e.warnT = WARN_TICKS -- 4084
				end -- 4084
			end -- 4084
			::__continue662:: -- 4084
			i = i + 1 -- 4065
		end -- 4065
	end -- 4065
end -- 4046
function Play.prototype.enemyFire(self, e, input) -- 4090
	local p = self.player -- 4091
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 4091
		self:flashSet("枪声响在远处", 0.4) -- 4093
		e.fireCd = FIRE_COOLDOWN -- 4094
		return -- 4095
	end -- 4095
	local cover = self:blockedByCover(e, p) -- 4098
	local hugging = cover ~= nil -- 4099
	self.coverBlocking = hugging -- 4100
	local covered = hugging and input.cover.held -- 4101
	if covered then -- 4101
		self.coveredFlash = 0.5 -- 4103
		self:flashSet("掩体挡下", 0.5) -- 4104
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4105
		e.fireCd = FIRE_COOLDOWN -- 4110
		return -- 4111
	end -- 4111
	self.hp = self.hp - 1 -- 4113
	self:emit("actorHit", { -- 4114
		target = "player", -- 4114
		amount = 1, -- 4114
		hp = self.hp, -- 4114
		maxHp = self.maxHp, -- 4114
		enemyX = e.x -- 4114
	}) -- 4114
	self:flashSet( -- 4115
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4115
		0.7 -- 4115
	) -- 4115
	e.fireCd = FIRE_COOLDOWN -- 4116
	if self.hp <= 0 then -- 4116
		self:gateFailed() -- 4118
	end -- 4118
end -- 4090
function Play.prototype.blockedByCover(self, enemy, p) -- 4123
	local b = self:coverAt(p) -- 4124
	if b == nil then -- 4124
		return nil -- 4126
	end -- 4126
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4128
end -- 4123
function Play.prototype.gateFailed(self) -- 4132
	local ____temp_61 -- 4133
	if self.room.story == nil then -- 4133
		____temp_61 = nil -- 4133
	else -- 4133
		____temp_61 = self.room.story.gate -- 4133
	end -- 4133
	local g = ____temp_61 -- 4133
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 4134
	self.hp = self.maxHp -- 4135
	self.gateTick = 0 -- 4136
	self.gateSpawned = 0 -- 4137
	self.enemies = {} -- 4138
	self.gateFailCount = self.gateFailCount + 1 -- 4139
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 4141
	self.player.y = 0 -- 4142
	self.player.vy = 0 -- 4143
	self.player.depth = 0 -- 4144
	self.player.depthSpeed = 0 -- 4145
	self.player.onGround = true -- 4146
	self.player.crouch = false -- 4147
	self.player.h = SOLDIER_H -- 4148
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 4149
	self.partner.y = 0 -- 4150
	self.partner.vy = 0 -- 4151
	self.partner.depth = 0 -- 4152
	self.partner.depthSpeed = 0 -- 4153
	self.partner.onGround = true -- 4154
	self.cam.x = self.player.x -- 4155
	self.phase = "gate-idle" -- 4156
	self.phaseTick = 0 -- 4157
	self.coverHug = false -- 4158
	self.coverBlocking = false -- 4159
	self.coverEntity = "" -- 4160
	self.gateNeedConfirm = true -- 4161
	self.gateRestartArmed = false -- 4162
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 4163
end -- 4132
function Play.prototype.stepRedCart(self, input) -- 4167
	if self.redCartMemoryT > 0 then -- 4167
		self.redCartMemoryT = self.redCartMemoryT - 1 -- 4169
	end -- 4169
	if self.room.key ~= "outside" or self.redCartPulled then -- 4169
		return -- 4172
	end -- 4172
	local box = __TS__ArrayFind( -- 4174
		self.boxes, -- 4174
		function(____, b) return b.id == "outside_red_cart" end -- 4174
	) -- 4174
	if box == nil then -- 4174
		self.redCartPulled = true -- 4176
		return -- 4177
	end -- 4177
	local cx = (box.x0 + box.x1) * 0.5 -- 4179
	local p = self.player -- 4180
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 4180
		return -- 4182
	end -- 4182
	if not input.interact.pressed then -- 4182
		return -- 4185
	end -- 4185
	box.x0 = 430 -- 4187
	box.x1 = 474 -- 4188
	self.cartAxle = self.room.cart.endX -- 4190
	self.cartDocked = true -- 4191
	self.redCartPulled = true -- 4192
	self.redCartMemoryT = 30 -- 4193
	if self.run.story ~= nil then -- 4193
		self.run.story.segments.outside_cart = true -- 4195
		self.run.story.segments.outside_memory = true -- 4196
	end -- 4196
	self.sessionDirty = true -- 4198
	self:flashSet("红布补丁 · 想起家里那一针 · 石阶口露出来", 1.8) -- 4199
	self:emit("storyBeat", {beat = "red_cart", x = p.x, room = "outside"}) -- 4200
	self:emit("storyBeat", {beat = "red_cart_memory", x = p.x, room = "outside", durationTicks = 30}) -- 4201
end -- 4167
function Play.prototype.stepInteract(self, dt, input) -- 4204
	local p = self.player -- 4205
	self:stepRedCart(input) -- 4206
	local calmUsed = self.calmConsumed -- 4207
	self.calmConsumed = false -- 4208
	local calming = self.escort.state == "calming" -- 4210
	self.focusCart = false -- 4211
	if self.room.key == "outside" then -- 4211
		local c = self.room.cart -- 4213
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 4214
		local dy = p.y - c.baseY -- 4215
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 4216
	end -- 4216
	if not calmUsed and not calming then -- 4216
		self:stepCart(dt, input) -- 4220
	end -- 4220
	if calmUsed then -- 4220
		self:flashSet("安抚 · 敲两下", 0.8) -- 4225
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4225
		if self.knockT > 0 then -- 4225
			self.knocks = self.knocks + 1 -- 4229
		else -- 4229
			self.knocks = 1 -- 4231
		end -- 4231
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4233
		self.knockT = 1.2 -- 4234
		if self.knocks >= 2 then -- 4234
			self:flashSet("敲两下", 0.8) -- 4236
			self.knocks = 0 -- 4237
		else -- 4237
			self:flashSet("敲一下", 0.5) -- 4239
		end -- 4239
	elseif self.knockT > 0 then -- 4239
		self.knockT = self.knockT - dt -- 4242
		if self.knockT <= 0 then -- 4242
			self.knocks = 0 -- 4244
		end -- 4244
	end -- 4244
	local i = 0 -- 4249
	do -- 4249
		i = 0 -- 4250
		while i < #self.room.marks do -- 4250
			do -- 4250
				local m = self.room.marks[i + 1] -- 4251
				if m.kind ~= 0 then -- 4251
					goto __continue696 -- 4253
				end -- 4253
				local subjects = {self.partner, self.player} -- 4255
				local k = 0 -- 4256
				do -- 4256
					k = 0 -- 4257
					while k < #subjects do -- 4257
						do -- 4257
							local s = subjects[k + 1] -- 4258
							if not s.alive then -- 4258
								goto __continue699 -- 4260
							end -- 4260
							local dx = s.x - m.x -- 4262
							local dy = s.y - m.y -- 4263
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4263
								self.checkpoint = m.x -- 4265
								self.checkpointCartAxle = self.cartAxle -- 4266
								if self.isCampaign then -- 4266
									self:captureCheckpoint(m.x) -- 4269
								end -- 4269
								if self.cartDocked then -- 4269
									self:flashSet("检查点 · 车已落窝", 1) -- 4272
								else -- 4272
									self:flashSet("检查点 · 车还没到位", 1) -- 4274
								end -- 4274
							end -- 4274
						end -- 4274
						::__continue699:: -- 4274
						k = k + 1 -- 4257
					end -- 4257
				end -- 4257
			end -- 4257
			::__continue696:: -- 4257
			i = i + 1 -- 4250
		end -- 4250
	end -- 4250
	self:checkCarryGate() -- 4280
end -- 4204
function Play.prototype.stepVillage(self, dt, input) -- 4284
	if self.room.key ~= "village" then -- 4284
		return -- 4286
	end -- 4286
	local p = self.player -- 4288
	local bottle = self.room.bottle -- 4289
	local scav = self.room.scavenger -- 4290
	if not self.hasBottle and bottle ~= nil then -- 4290
		local dx = p.x - bottle.x -- 4294
		local dy = p.y + p.h * 0.5 - bottle.y -- 4295
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4295
			self.hasBottle = true -- 4297
			self:flashSet("拾起瓶子", 0.8) -- 4298
		end -- 4298
	end -- 4298
	if self.hasBottle then -- 4298
		if input.aim.held then -- 4298
			self.aimHold = self.aimHold + dt -- 4305
			if self.aimHold > 1.2 then -- 4305
				self.aimHold = 1.2 -- 4307
			end -- 4307
			local cached = self:bottleEnd() -- 4310
			self.bottleAimX = cached.x -- 4311
			self.bottleAimY = cached.y -- 4312
		elseif input.aim.released then -- 4312
			if self.aimHold < 0.12 then -- 4312
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 4316
				self.aimHold = 0 -- 4317
			else -- 4317
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4319
				self:throwBottle(____end.x, ____end.y) -- 4320
				self.aimHold = 0 -- 4321
			end -- 4321
		end -- 4321
	else -- 4321
		self.aimHold = 0 -- 4325
		self.bottleAimX = -1 -- 4326
	end -- 4326
	local fly = self.bottleFly -- 4331
	if fly ~= nil then -- 4331
		fly.t = fly.t + dt -- 4333
		fly.x = fly.x0 + fly.vx * fly.t -- 4334
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4335
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4336
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4336
			self:landBottle(fly) -- 4338
		end -- 4338
	end -- 4338
	if self.bottleLandT > 0 then -- 4338
		self.bottleLandT = self.bottleLandT - dt -- 4342
	end -- 4342
	if scav ~= nil then -- 4342
		self:stepScav(dt, scav) -- 4346
	end -- 4346
	local line = self.room.passLine -- 4349
	if line ~= nil and not self.passed and p.x >= line then -- 4349
		self.passed = true -- 4351
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4352
	end -- 4352
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4355
	if underTable then -- 4355
		self.footHintT = self.footHintT - 1 -- 4357
		if self.footHintT <= 0 then -- 4357
			self.footHintT = 90 -- 4359
			local scavX = self.scavX -- 4360
			local near = math.abs(scavX - p.x) < 120 -- 4361
			local heard = near or self.scavState == "walk" or self.scavState == "chase" -- 4362
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4363
			self:emit("storyBeat", {beat = near and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4364
		end -- 4364
	else -- 4364
		self.footHintT = 0 -- 4367
	end -- 4367
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4367
		self.ditchHinted = true -- 4371
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4372
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4373
	end -- 4373
	if self.passed and p.x >= self.ox + 640 then -- 4373
		self:requestRoom("forest", "过第一院出院") -- 4377
		self:flashSet("钻出暗渠 · 北塔森林", 1.4) -- 4378
	end -- 4378
end -- 4284
function Play.prototype.bottleEnd(self) -- 4383
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4384
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 4387
	return {x = aim.x, y = g} -- 4388
end -- 4383
function Play.prototype.throwBottle(self, tx, ty) -- 4392
	local p = self.player -- 4393
	local dir = tx >= p.x and 1 or -1 -- 4395
	p.facing = dir -- 4396
	local x0 = p.x + dir * 10 -- 4397
	local y0 = p.y + p.h * 0.7 -- 4398
	self.bottleTargetX = tx -- 4399
	self.bottleTargetY = ty -- 4400
	self.bottleSurfaceY = ty -- 4401
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4402
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4403
	self.bottleFly = { -- 4404
		x = x0, -- 4404
		y = y0, -- 4404
		x0 = x0, -- 4404
		y0 = y0, -- 4404
		vx = vx, -- 4404
		vy = vy, -- 4404
		t = 0 -- 4404
	} -- 4404
	self.hasBottle = false -- 4405
	self:flashSet("投出", 0.4) -- 4406
	self:emit( -- 4407
		"bottleThrown", -- 4407
		{ -- 4407
			fromX = x0, -- 4408
			fromY = y0, -- 4409
			targetX = tx, -- 4410
			targetY = ty, -- 4411
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4412
		} -- 4412
	) -- 4412
end -- 4392
function Play.prototype.bottleSurfaceAt(self, x) -- 4417
	if self.room.softX ~= nil and math.abs(x - self.room.softX) <= 34 then -- 4417
		return "soft" -- 4419
	end -- 4419
	if self.room.basinX ~= nil and math.abs(x - self.room.basinX) <= 24 then -- 4419
		return "iron" -- 4422
	end -- 4422
	return "brick" -- 4424
end -- 4417
function Play.prototype.landBottle(self, fly) -- 4428
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4429
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4430
	local s = self.room.scavenger -- 4431
	local surface = self:bottleSurfaceAt(x) -- 4432
	local effRange = s == nil and 0 or (surface == "iron" and s.range * 1.25 or s.range) -- 4433
	local heard = surface ~= "soft" and s ~= nil and math.abs(x - self.scavX) <= effRange -- 4434
	local stallTicks = s == nil and 0 or (surface == "iron" and s.stallTicks + 90 or s.stallTicks) -- 4435
	self.bottleFly = nil -- 4436
	self.bottleTargetX = -1 -- 4437
	self.bottleTargetY = 0 -- 4438
	self.bottleSurfaceY = -1 -- 4439
	self.bottleLandX = x -- 4440
	self.bottleLandY = y -- 4441
	self.bottleLandT = 0.9 -- 4442
	self:emit("bottleLanded", { -- 4443
		x = x, -- 4444
		y = y, -- 4445
		surface = surface, -- 4446
		heard = heard, -- 4447
		resonance = surface == "iron", -- 4448
		stallTicks = heard and stallTicks or 0, -- 4449
		scavState = self.scavState -- 4450
	}) -- 4450
	self:hearBottle(x, surface) -- 4452
end -- 4428
function Play.prototype.hearBottle(self, x, surface) -- 4456
	if surface == nil then -- 4456
		surface = "brick" -- 4456
	end -- 4456
	local s = self.room.scavenger -- 4457
	if s == nil then -- 4457
		return -- 4459
	end -- 4459
	if surface == "soft" then -- 4459
		self:flashSet("落在软土 · 没出声", 0.8) -- 4462
		return -- 4463
	end -- 4463
	local effRange = surface == "iron" and s.range * 1.25 or s.range -- 4465
	if math.abs(x - self.scavX) > effRange then -- 4465
		self:flashSet("落地 · 他没听见", 0.6) -- 4467
		return -- 4468
	end -- 4468
	self.scavState = "turn" -- 4470
	self.scavT = s.hearTicks -- 4471
	self.scavTargetX = surface == "iron" and self.room.basinX ~= nil and self.room.basinX or x -- 4472
	self.scavStallBonus = surface == "iron" and 90 or 0 -- 4473
	self:flashSet(surface == "iron" and "铁盆余振两响 · 他停下来细听" or "砖地一响 · 他转头", 1.1) -- 4474
end -- 4456
function Play.prototype.stepScav(self, dt, s) -- 4478
	if self.scavState == "chase" then -- 4478
		return -- 4481
	end -- 4481
	if self.scavState == "turn" then -- 4481
		self.scavT = self.scavT - 1 -- 4484
		if self.scavT <= 0 then -- 4484
			self.scavState = "walk" -- 4486
		end -- 4486
		return -- 4488
	end -- 4488
	if self.scavState == "walk" then -- 4488
		local d = self.scavTargetX - self.scavX -- 4491
		if math.abs(d) < 4 then -- 4491
			self.scavState = "stall" -- 4493
			self.scavT = s.stallTicks + self.scavStallBonus -- 4494
			self.scavStallBonus = 0 -- 4495
			return -- 4496
		end -- 4496
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4498
		return -- 4499
	end -- 4499
	if self.scavState == "stall" then -- 4499
		self.scavT = self.scavT - 1 -- 4502
		if self.scavT <= 0 then -- 4502
			self.scavState = "back" -- 4504
		end -- 4504
		return -- 4506
	end -- 4506
	if self.scavState == "back" then -- 4506
		local home = math.max( -- 4509
			s.x0, -- 4509
			math.min(s.x1, self.scavX) -- 4509
		) -- 4509
		if math.abs(home - self.scavX) < 2 then -- 4509
			self.scavState = "patrol" -- 4511
			return -- 4512
		end -- 4512
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4514
		return -- 4515
	end -- 4515
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4517
	if self.scavX >= s.x1 then -- 4517
		self.scavX = s.x1 -- 4519
		self.scavDir = -1 -- 4520
	elseif self.scavX <= s.x0 then -- 4520
		self.scavX = s.x0 -- 4522
		self.scavDir = 1 -- 4523
	end -- 4523
end -- 4478
function Play.prototype.stepCart(self, dt, input) -- 4531
	local p = self.player -- 4532
	local c = self.room.cart -- 4533
	if self.gripping then -- 4533
		if not input.interact.held then -- 4533
			self.gripping = false -- 4537
			self:flashSet("松开车把", 0.4) -- 4538
			return -- 4539
		end -- 4539
	else -- 4539
		if not input.interact.pressed then -- 4539
			return -- 4543
		end -- 4543
		if not self:cartHandleInReach(p) then -- 4543
			return -- 4546
		end -- 4546
		local track = c.depth or 0 -- 4548
		if self:limitDepth(p, track) ~= track then -- 4548
			return -- 4550
		end -- 4550
		p.depth = track -- 4552
		p.depthSpeed = 0 -- 4553
		self.gripping = true -- 4554
		self:flashSet("握住车把", 0.4) -- 4555
		return -- 4556
	end -- 4556
	if self.cartDocked then -- 4556
		return -- 4560
	end -- 4560
	local dir = input.moveX -- 4562
	if dir == 0 then -- 4562
		return -- 4564
	end -- 4564
	local lo = math.min(c.startX, c.endX) -- 4566
	local hi = math.max(c.startX, c.endX) -- 4567
	local next = self.cartAxle + dir * CART_SPEED * dt -- 4568
	if next < lo then -- 4568
		next = lo -- 4570
	end -- 4570
	if next > hi then -- 4570
		next = hi -- 4573
	end -- 4573
	local delta = next - self.cartAxle -- 4575
	if delta == 0 then -- 4575
		return -- 4577
	end -- 4577
	self.cartAxle = next -- 4579
	p.x = p.x + delta -- 4580
	p.facing = dir > 0 and 1 or -1 -- 4581
	self:slideX(p, 0) -- 4582
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 4582
		self.gripping = false -- 4584
		self:flashSet("跟不上了，脱手", 0.6) -- 4585
		return -- 4586
	end -- 4586
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 4586
		self.cartDocked = true -- 4589
		self.gripping = false -- 4590
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 4591
		self:flashSet("车轮落窝", 1.2) -- 4592
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 4592
		self:flashSet("车轮回到起点", 0.5) -- 4594
	end -- 4594
end -- 4531
function Play.prototype.requestRoom(self, key, reason) -- 4602
	if self.wantRoom ~= "" then -- 4602
		return -- 4606
	end -- 4606
	self.wantRoom = key -- 4608
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 4609
end -- 4602
function Play.prototype.checkCarryGate(self) -- 4616
	if self.room.key == "checkpoint" then -- 4616
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 4616
			self.carryCartAxle = self.cartAxle -- 4619
			self.carryCartDocked = self.cartDocked -- 4620
			self:requestRoom("gate", "检查站出口") -- 4621
			self:flashSet("出检查站 · 城门", 1.2) -- 4622
		end -- 4622
		return -- 4624
	end -- 4624
	if self.room.key == "outside" then -- 4624
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 4624
			self.carryCartAxle = self.cartAxle -- 4630
			self.carryCartDocked = self.cartDocked -- 4631
			self:requestRoom("village", "墙根走完") -- 4632
			self:flashSet("墙根走完 · 进村口", 1.2) -- 4633
		end -- 4633
	end -- 4633
end -- 4616
function Play.prototype.aimAt(self, wx, wy) -- 4640
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 4641
	self.aimX = s.x -- 4642
	self.aimY = s.y -- 4643
end -- 4640
function Play.prototype.shoot(self, a) -- 4646
	if self.isCampaign and self.reloadT > 0 then -- 4646
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 4648
		return -- 4649
	end -- 4649
	local ox = a.x + a.facing * 8 -- 4651
	local muzzleY = a.y + a.h * 0.72 -- 4652
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 4653
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4655
	local dx = aim.x - ox -- 4658
	local dy = aim.y - oy -- 4659
	local len = math.sqrt(dx * dx + dy * dy) -- 4660
	if len < 0.001 then -- 4660
		dx = a.facing -- 4662
		dy = 0 -- 4663
	else -- 4663
		dx = dx / len -- 4665
		dy = dy / len -- 4666
	end -- 4666
	if dx ~= 0 then -- 4666
		a.facing = dx > 0 and 1 or -1 -- 4669
	end -- 4669
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 4672
	local hitEnemy = self:raycastEnemies(ray) -- 4673
	local tEnemy = hitEnemy.t -- 4674
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 4675
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 4676
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 4677
	local tWall = solid.t -- 4678
	local rawEffect = self:consumeReloadEffect() -- 4680
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 4681
	local reloadEffect = rawEffect -- 4682
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 4684
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 4685
	self.trace = { -- 4687
		x0 = ox, -- 4687
		y0 = oy, -- 4687
		x1 = ox + dx * t, -- 4687
		y1 = oy + dy * t, -- 4687
		hit = hit -- 4687
	} -- 4687
	self.traceT = 0.12 -- 4688
	self:applyFireDanger(ox) -- 4689
	local killed = false -- 4690
	if hit then -- 4690
		local i = hitEnemy.index -- 4692
		local e = self.enemies[i + 1] -- 4693
		local impactY = oy + dy * tEnemy -- 4694
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 4695
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 4696
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 4696
			e.shieldHp = (e.shieldHp or 0) - 1 -- 4698
			e.hitT = 0.3 -- 4699
			self:flashSet( -- 4700
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 4700
				0.8 -- 4700
			) -- 4700
			self:emit("shotResolved", { -- 4701
				hit = true, -- 4702
				enemyIndex = i, -- 4702
				enemyX = e.x, -- 4702
				aimX = aim.x, -- 4702
				aimY = aim.y, -- 4702
				impactX = ox + dx * t, -- 4703
				impactY = oy + dy * t, -- 4703
				shield = true -- 4703
			}) -- 4703
			self:beginReload() -- 4705
			return -- 4706
		end -- 4706
		e.alive = false -- 4708
		e.hitT = 0.4 -- 4709
		killed = true -- 4710
		self:flashSet("命中", 0.6) -- 4711
		self:dropFor(e) -- 4712
		if reloadEffect == "light" and weaponFx == "light" then -- 4712
			self:blindNearby(e, 160, i) -- 4714
		end -- 4714
		if reloadEffect == "push" then -- 4714
			e.x = e.x + a.facing * 46 -- 4717
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4718
		elseif reloadEffect == "echo" then -- 4718
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 4720
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 4721
		elseif reloadEffect == "light" then -- 4721
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 4723
		end -- 4723
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 4723
		self:damageProp(solid.box, 1) -- 4726
	else -- 4726
		self:flashSet("打空", 0.35) -- 4728
	end -- 4728
	if self.isCampaign then -- 4728
		self:beginReload() -- 4731
	end -- 4731
	self:emit("shotResolved", { -- 4733
		hit = hit, -- 4734
		enemyIndex = hit and hitEnemy.index or -1, -- 4735
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 4736
		aimX = aim.x, -- 4737
		aimY = aim.y, -- 4738
		impactX = ox + dx * t, -- 4739
		impactY = oy + dy * t -- 4740
	}) -- 4740
end -- 4646
function Play.prototype.applyFireDanger(self, shotX) -- 4745
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 4745
		return -- 4747
	end -- 4747
	local dangerX = shotX -- 4749
	local best = -1 -- 4750
	local bestD = 1000000000 -- 4751
	local i = 0 -- 4752
	do -- 4752
		i = 0 -- 4753
		while i < #self.enemies do -- 4753
			do -- 4753
				local e = self.enemies[i + 1] -- 4754
				if not e.alive then -- 4754
					goto __continue788 -- 4756
				end -- 4756
				local d = math.abs(e.x - self.partner.x) -- 4758
				if d < bestD then -- 4758
					bestD = d -- 4760
					best = i -- 4761
				end -- 4761
			end -- 4761
			::__continue788:: -- 4761
			i = i + 1 -- 4753
		end -- 4753
	end -- 4753
	if best >= 0 then -- 4753
		dangerX = self.enemies[best + 1].x -- 4765
	end -- 4765
	local exposed = self:childExposed(dangerX) -- 4767
	local before = self.escort.fear -- 4768
	local dangerId = self.nextDangerId -- 4769
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 4770
	self.nextDangerId = self.nextDangerId + 1 -- 4771
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 4772
	if after > before then -- 4772
		self:flashSet( -- 4774
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 4774
			1 -- 4774
		) -- 4774
	elseif not exposed then -- 4774
		self:flashSet("枪声没够到她", 0.5) -- 4776
	end -- 4776
end -- 4745
function Play.prototype.childExposed(self, dangerX) -- 4781
	local c = self.partner -- 4782
	if not c.alive then -- 4782
		return false -- 4784
	end -- 4784
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 4784
		self.boxes, -- 4787
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 4787
	) then -- 4787
		return false -- 4788
	end -- 4788
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 4788
		return false -- 4791
	end -- 4791
	local toDanger = dangerX - c.x -- 4793
	local toPlayer = self.player.x - c.x -- 4794
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 4794
		return false -- 4797
	end -- 4797
	return true -- 4799
end -- 4781
function Play.prototype.raycastEnemies(self, ray) -- 4803
	local best = -1 -- 4804
	local bestI = -1 -- 4805
	do -- 4805
		local i = 0 -- 4806
		while i < #self.enemies do -- 4806
			do -- 4806
				local e = self.enemies[i + 1] -- 4807
				if not e.alive then -- 4807
					goto __continue802 -- 4809
				end -- 4809
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 4811
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 4812
				if t >= 0 and (best < 0 or t < best) then -- 4812
					best = t -- 4814
					bestI = i -- 4815
				end -- 4815
			end -- 4815
			::__continue802:: -- 4815
			i = i + 1 -- 4806
		end -- 4806
	end -- 4806
	return {t = best, index = bestI} -- 4818
end -- 4803
function Play.prototype.raycastWorld(self, ray) -- 4821
	return self:raycastSolid(ray).t -- 4822
end -- 4821
function Play.prototype.raycastSolid(self, ray) -- 4826
	local best = -1 -- 4827
	local bestBox = nil -- 4828
	for ____, box in ipairs(self.boxes) do -- 4829
		do -- 4829
			if box.broken == true or box.hidden == true then -- 4829
				goto __continue807 -- 4831
			end -- 4831
			local t = hitBox(ray, box) -- 4836
			if t > 2 and (best < 0 or t < best) then -- 4836
				best = t -- 4839
				bestBox = box -- 4840
			end -- 4840
		end -- 4840
		::__continue807:: -- 4840
	end -- 4840
	if ray.dy < 0 then -- 4840
		local t = -ray.y / ray.dy -- 4844
		if t >= 0 and (best < 0 or t < best) then -- 4844
			best = t -- 4846
			bestBox = nil -- 4847
		end -- 4847
	end -- 4847
	return {t = best, box = bestBox} -- 4850
end -- 4826
function Play.prototype.dropFor(self, e) -- 4854
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 4854
		return -- 4856
	end -- 4856
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 4856
		return -- 4859
	end -- 4859
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 4861
	local ____self_pickups_62 = self.pickups -- 4861
	____self_pickups_62[#____self_pickups_62 + 1] = { -- 4862
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 4863
		kind = e.drop, -- 4863
		x = e.x, -- 4863
		y = e.y, -- 4863
		depth = e.depth, -- 4864
		label = label .. " ×1" -- 4864
	} -- 4864
	self:log("掉落 " .. label) -- 4866
end -- 4854
function Play.prototype.damageProp(self, b, amount) -- 4870
	if b.breakable == nil or b.broken == true then -- 4870
		return -- 4872
	end -- 4872
	local ____b_breakable_63, ____hp_64 = b.breakable, "hp" -- 4872
	____b_breakable_63[____hp_64] = ____b_breakable_63[____hp_64] - amount -- 4874
	if b.breakable.hp > 0 then -- 4874
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 4876
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 4877
		return -- 4878
	end -- 4878
	b.broken = true -- 4880
	for ____, other in ipairs(self.boxes) do -- 4881
		if other.id ~= nil and other.id == b.id then -- 4881
			other.broken = true -- 4883
		end -- 4883
	end -- 4883
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 4886
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 4887
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 4888
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 4889
end -- 4870
function Play.prototype.slideDepth(self, a, distance) -- 4893
	a.depth = self:limitDepth(a, a.depth + distance) -- 4894
end -- 4893
function Play.prototype.limitDepth(self, a, target) -- 4897
	local road = self.room.depth -- 4898
	if road == nil or target == a.depth then -- 4898
		return a.depth -- 4900
	end -- 4900
	local next = math.max( -- 4902
		road.min, -- 4902
		math.min(road.max, target) -- 4902
	) -- 4902
	local half = a.w / 2 -- 4903
	for ____, b in ipairs(self.boxes) do -- 4904
		do -- 4904
			local footprint = b.depth -- 4905
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4905
				goto __continue825 -- 4910
			end -- 4910
			local front = footprint.min - ACTOR_DEPTH_HALF -- 4912
			local back = footprint.max + ACTOR_DEPTH_HALF -- 4913
			if a.depth <= front and next > front then -- 4913
				next = front -- 4915
			elseif a.depth >= back and next < back then -- 4915
				next = back -- 4917
			end -- 4917
		end -- 4917
		::__continue825:: -- 4917
	end -- 4917
	return next -- 4920
end -- 4897
function Play.prototype.slideX(self, a, dx) -- 4924
	local nx = a.x + dx -- 4925
	local half = a.w / 2 -- 4926
	local room = self.room -- 4927
	nx = math.max( -- 4928
		room.minX + half, -- 4928
		math.min(room.maxX - half, nx) -- 4928
	) -- 4928
	local i = 0 -- 4929
	do -- 4929
		i = 0 -- 4930
		while i < #self.boxes do -- 4930
			do -- 4930
				local b = self.boxes[i + 1] -- 4931
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4931
					goto __continue832 -- 4933
				end -- 4933
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4933
					goto __continue832 -- 4936
				end -- 4936
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4936
					goto __continue832 -- 4939
				end -- 4939
				if nx + half > b.x0 and nx - half < b.x1 then -- 4939
					if a.x <= b.x0 then -- 4939
						nx = b.x0 - half -- 4943
					elseif a.x >= b.x1 then -- 4943
						nx = b.x1 + half -- 4945
					else -- 4945
						nx = a.x -- 4947
					end -- 4947
				end -- 4947
			end -- 4947
			::__continue832:: -- 4947
			i = i + 1 -- 4930
		end -- 4930
	end -- 4930
	if self.room.key == "outside" and not self.cartDocked and a.y < CART_CLEAR - 0.001 then -- 4930
		local bx0 = math.max(room.arch.x0, self.cartAxle - CART_HALF) -- 4954
		local bx1 = math.min(room.arch.x1, self.cartAxle + CART_HALF) -- 4955
		if bx1 > bx0 and nx + half > bx0 and nx - half < bx1 then -- 4955
			if a.x <= bx0 then -- 4955
				nx = bx0 - half -- 4958
			elseif a.x >= bx1 then -- 4958
				nx = bx1 + half -- 4960
			else -- 4960
				nx = a.x -- 4962
			end -- 4962
		end -- 4962
	end -- 4962
	local arch = room.arch -- 4970
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 4970
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 4972
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 4972
			if a.x <= arch.x0 then -- 4972
				nx = arch.x0 - half -- 4975
			elseif a.x >= arch.x1 then -- 4975
				nx = arch.x1 + half -- 4977
			end -- 4977
		end -- 4977
	end -- 4977
	a.x = nx -- 4981
end -- 4924
function Play.prototype.fallY(self, a, dt) -- 4985
	a.vy = a.vy - ____exports.GRAVITY * dt -- 4986
	if a.vy < -900 then -- 4986
		a.vy = -900 -- 4988
	end -- 4988
	local ny = a.y + a.vy * dt -- 4990
	local half = a.w / 2 -- 4991
	if a.vy <= 0 then -- 4991
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 4994
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 4995
		if ny <= ground then -- 4995
			ny = ground -- 4997
			a.vy = 0 -- 4998
			a.onGround = true -- 4999
		else -- 4999
			a.onGround = false -- 5001
		end -- 5001
	else -- 5001
		a.onGround = false -- 5004
		local i = 0 -- 5005
		do -- 5005
			i = 0 -- 5006
			while i < #self.boxes do -- 5006
				do -- 5006
					local b = self.boxes[i + 1] -- 5007
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5007
						goto __continue856 -- 5009
					end -- 5009
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5009
						goto __continue856 -- 5012
					end -- 5012
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 5012
						goto __continue856 -- 5015
					end -- 5015
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 5015
						ny = b.y0 - a.h -- 5018
						a.vy = 0 -- 5019
					end -- 5019
				end -- 5019
				::__continue856:: -- 5019
				i = i + 1 -- 5006
			end -- 5006
		end -- 5006
	end -- 5006
	a.y = ny -- 5023
end -- 4985
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 5027
	if depth == nil then -- 5027
		depth = 0 -- 5027
	end -- 5027
	local g = -9999 -- 5028
	local i = 0 -- 5029
	do -- 5029
		i = 0 -- 5030
		while i < #self.floors do -- 5030
			local f = self.floors[i + 1] -- 5031
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 5031
				g = f.y1 -- 5033
			end -- 5033
			i = i + 1 -- 5030
		end -- 5030
	end -- 5030
	do -- 5030
		i = 0 -- 5036
		while i < #self.boxes do -- 5036
			do -- 5036
				local b = self.boxes[i + 1] -- 5037
				if b.broken == true or b.hidden == true or b.soft == true then -- 5037
					goto __continue866 -- 5039
				end -- 5039
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 5039
					g = b.y1 -- 5043
				end -- 5043
			end -- 5043
			::__continue866:: -- 5043
			i = i + 1 -- 5036
		end -- 5036
	end -- 5036
	return g -- 5046
end -- 5027
function Play.prototype.updateCamera(self, dt) -- 5049
	local p = self.player -- 5050
	local tx = p.x + p.facing * 30 -- 5051
	local ty = p.y + CAM_LOOK_UP -- 5052
	local k = math.min(1, CAM_FOLLOW * dt) -- 5053
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 5054
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 5055
end -- 5049
function Play.prototype.clampCamera(self, w, h) -- 5059
	local room = self.room -- 5060
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 5061
	local spanX = room.maxX - room.minX -- 5062
	if spanX <= halfW * 2 then -- 5062
		self.cam.x = (room.minX + room.maxX) / 2 -- 5064
	else -- 5064
		self.cam.x = math.max( -- 5066
			room.minX + halfW, -- 5066
			math.min(room.maxX - halfW, self.cam.x) -- 5066
		) -- 5066
	end -- 5066
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 5069
	local spanY = room.height -- 5070
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 5071
	if spanY <= halfH * 2 then -- 5071
		self.cam.y = camY -- 5073
	else -- 5073
		self.cam.y = math.max( -- 5075
			camY, -- 5075
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 5075
		) -- 5075
	end -- 5075
end -- 5059
function Play.prototype.flashSet(self, text, t) -- 5079
	self.flash = text -- 5080
	self.flashT = t -- 5081
end -- 5079
function Play.prototype.statusText(self) -- 5085
	local p = self.player -- 5086
	local parts = {} -- 5087
	local who = self.childMode and "小满" or "周戍" -- 5088
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 5089
	if self.room.key == "prologue" then -- 5089
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5092
		if self.phase == "prologue-wake" then -- 5092
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 5094
		elseif self.phase == "prologue-shadow" then -- 5094
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 5096
		elseif self.phase == "prologue-escape" then -- 5096
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 5098
		elseif self.phase == "prologue-hide" then -- 5098
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 5100
		elseif self.phase == "prologue-wait" then -- 5100
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 5102
		elseif self.phase == "prologue-give" then -- 5102
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 5104
		else -- 5104
			parts[#parts + 1] = "跟随" -- 5106
		end -- 5106
		if self.paused then -- 5106
			parts[#parts + 1] = "已暂停" -- 5109
		end -- 5109
		return table.concat(parts, " · ") -- 5111
	end -- 5111
	if self.room.key == "street" then -- 5111
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5114
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5115
		if self.paused then -- 5115
			parts[#parts + 1] = "已暂停" -- 5117
		end -- 5117
		return table.concat(parts, " · ") -- 5119
	end -- 5119
	if self.room.key == "gate" then -- 5119
		local ____temp_65 -- 5122
		if self.room.story == nil then -- 5122
			____temp_65 = nil -- 5122
		else -- 5122
			____temp_65 = self.room.story.gate -- 5122
		end -- 5122
		local g = ____temp_65 -- 5122
		if g ~= nil then -- 5122
			parts[#parts + 1] = self:gateLabel() -- 5124
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 5125
				0, -- 5126
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 5126
			))) .. " 秒" -- 5126
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5127
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5128
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 5129
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 5130
			if self.gateFailCount > 0 then -- 5130
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 5132
			end -- 5132
			if self.flash ~= "" then -- 5132
				parts[#parts + 1] = self.flash -- 5135
			end -- 5135
		end -- 5135
		if self.paused then -- 5135
			parts[#parts + 1] = "已暂停" -- 5139
		end -- 5139
		return table.concat(parts, " · ") -- 5141
	end -- 5141
	if self.room.key == "forest" then -- 5141
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5144
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5145
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5146
		if self.caughtT > 0 then -- 5146
			parts[#parts + 1] = "复位中" -- 5148
		end -- 5148
		if self.paused then -- 5148
			parts[#parts + 1] = "已暂停" -- 5151
		end -- 5151
		return table.concat(parts, " · ") -- 5153
	end -- 5153
	if self.room.key == "tower" then -- 5153
		if self.phase == "tower-wait" then -- 5153
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5157
		elseif self.phase == "tower-knock" then -- 5157
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5159
		elseif self.phase == "tower-enter" then -- 5159
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5161
		elseif self.phase == "tower-desk" then -- 5161
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5163
		elseif self.phase == "tower-given" then -- 5163
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5165
		else -- 5165
			parts[#parts + 1] = "片尾" -- 5167
		end -- 5167
		if self.paused then -- 5167
			parts[#parts + 1] = "已暂停" -- 5170
		end -- 5170
		return table.concat(parts, " · ") -- 5172
	end -- 5172
	if self.room.key == "village" then -- 5172
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5175
		if self.hasBottle then -- 5175
			parts[#parts + 1] = "有瓶" -- 5177
		elseif self.bottleFly ~= nil then -- 5177
			parts[#parts + 1] = "瓶在飞" -- 5179
		else -- 5179
			parts[#parts + 1] = "空手" -- 5181
		end -- 5181
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5183
		if self.scavChase then -- 5183
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5185
		end -- 5185
		if self.passed then -- 5185
			parts[#parts + 1] = "已过通行线" -- 5188
		end -- 5188
		if self.paused then -- 5188
			parts[#parts + 1] = "已暂停" -- 5191
		end -- 5191
		return table.concat(parts, " · ") -- 5193
	end -- 5193
	local isChild = self.childMode -- 5196
	if isChild then -- 5196
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5198
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5199
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5200
	else -- 5200
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5202
		if p.rollT > 0 then -- 5202
			parts[#parts + 1] = "翻滚中" -- 5204
		end -- 5204
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5206
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5207
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5208
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5209
	end -- 5209
	if self.checkpoint >= 0 then -- 5209
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5212
	end -- 5212
	if self.paused then -- 5212
		parts[#parts + 1] = "已暂停" -- 5215
	end -- 5215
	return table.concat(parts, " · ") -- 5217
end -- 5085
function Play.prototype.aliveEnemies(self) -- 5221
	local n = 0 -- 5222
	local i = 0 -- 5223
	do -- 5223
		i = 0 -- 5224
		while i < #self.enemies do -- 5224
			if self.enemies[i + 1].alive then -- 5224
				n = n + 1 -- 5226
			end -- 5226
			i = i + 1 -- 5224
		end -- 5224
	end -- 5224
	return n -- 5229
end -- 5221
function Play.prototype.threatened(self) -- 5234
	do -- 5234
		local i = 0 -- 5235
		while i < #self.enemies do -- 5235
			local e = self.enemies[i + 1] -- 5236
			if e.alive and e.warnT > 0 then -- 5236
				return true -- 5238
			end -- 5238
			i = i + 1 -- 5235
		end -- 5235
	end -- 5235
	return false -- 5241
end -- 5234
function Play.prototype.gateSecondsLeft(self) -- 5244
	local ____temp_66 -- 5245
	if self.room.story == nil then -- 5245
		____temp_66 = nil -- 5245
	else -- 5245
		____temp_66 = self.room.story.gate -- 5245
	end -- 5245
	local g = ____temp_66 -- 5245
	if g == nil then -- 5245
		return 0 -- 5247
	end -- 5247
	return math.max( -- 5249
		0, -- 5249
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5249
	) -- 5249
end -- 5244
function Play.prototype.gateLabel(self) -- 5252
	if self.phase == "gate-idle" then -- 5252
		return "待就位" -- 5254
	end -- 5254
	if self.phase == "gate-hold" then -- 5254
		return "守点中" -- 5257
	end -- 5257
	if self.phase == "gate-send" then -- 5257
		return "送别" -- 5260
	end -- 5260
	if self.phase == "gate-count" then -- 5260
		return "数数 " .. tostring(self.countTick) -- 5263
	end -- 5263
	return "她走" -- 5265
end -- 5252
function Play.prototype.dogLabel(self) -- 5269
	if self.dogState == "ear" then -- 5269
		return "转耳" -- 5271
	end -- 5271
	if self.dogState == "chase" then -- 5271
		return "追" -- 5274
	end -- 5274
	if self.dogState == "sniff" then -- 5274
		return "停" -- 5277
	end -- 5277
	if self.dogState == "back" then -- 5277
		return "回线" -- 5280
	end -- 5280
	return "巡逻" -- 5282
end -- 5269
function Play.prototype.doorXOf(self) -- 5285
	local ____temp_67 -- 5286
	if self.room.story == nil then -- 5286
		____temp_67 = nil -- 5286
	else -- 5286
		____temp_67 = self.room.story.tower -- 5286
	end -- 5286
	local t = ____temp_67 -- 5286
	return t == nil and 0 or t.doorX -- 5287
end -- 5285
function Play.prototype.scavLabel(self) -- 5291
	if self.scavState == "chase" then -- 5291
		return "追" -- 5293
	end -- 5293
	if self.scavState == "turn" then -- 5293
		return "转头" -- 5296
	end -- 5296
	if self.scavState == "walk" then -- 5296
		return "赶来" -- 5299
	end -- 5299
	if self.scavState == "stall" then -- 5299
		return "停住" -- 5302
	end -- 5302
	if self.scavState == "back" then -- 5302
		return "回位" -- 5305
	end -- 5305
	return "巡逻" -- 5307
end -- 5291
function Play.prototype.hintText(self) -- 5311
	if self.paused then -- 5311
		return "Esc 继续 · R 重置" -- 5313
	end -- 5313
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5313
		if self:threatened() then -- 5313
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5319
		end -- 5319
		if self.coverHug then -- 5319
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5322
		end -- 5322
		if self.coverNear then -- 5322
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5325
		end -- 5325
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5327
	end -- 5327
	if self.flash ~= "" then -- 5327
		return self.flash -- 5330
	end -- 5330
	if self.room.key == "prologue" then -- 5330
		if self.phase == "prologue-wake" then -- 5330
			return "父亲在门外唤 · 小满睁眼" -- 5334
		end -- 5334
		if self.phase == "prologue-shadow" then -- 5334
			return "墙上两道人影 · 碗滚到脚边" -- 5337
		end -- 5337
		if self.phase == "prologue-escape" then -- 5337
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5340
		end -- 5340
		if self.phase == "prologue-hide" then -- 5340
			return "柜门合上 · 屏住呼吸" -- 5343
		end -- 5343
		if self.phase == "prologue-wait" then -- 5343
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5346
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5347
		end -- 5347
		if self.phase == "prologue-give" then -- 5347
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 5350
		end -- 5350
		return "她跟着你了 · 两人一起走到门口 680" -- 5352
	end -- 5352
	if self.room.key == "street" then -- 5352
		if self:aliveEnemies() > 0 then -- 5352
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5356
		end -- 5356
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5358
	end -- 5358
	if self.room.key == "gate" then -- 5358
		local ____temp_68 -- 5361
		if self.room.story == nil then -- 5361
			____temp_68 = nil -- 5361
		else -- 5361
			____temp_68 = self.room.story.gate -- 5361
		end -- 5361
		local g = ____temp_68 -- 5361
		if g ~= nil then -- 5361
			if self.phase == "gate-idle" then -- 5361
				if self.gateNeedConfirm then -- 5361
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5365
				end -- 5365
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5367
			end -- 5367
			if self.phase == "gate-hold" then -- 5367
				if self.coveredFlash > 0 then -- 5367
					return "掩体挡下了这一枪 · 别露头" -- 5371
				end -- 5371
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5373
			end -- 5373
			if self.phase == "gate-send" then -- 5373
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5376
			end -- 5376
			if self.phase == "gate-count" then -- 5376
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5376
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5380
				end -- 5380
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5382
			end -- 5382
			return "她自己走 · 跟着出城门 1120" -- 5384
		end -- 5384
	end -- 5384
	if self.room.key == "forest" then -- 5384
		if self.dogState == "chase" then -- 5384
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5389
		end -- 5389
		if self.dogState == "ear" then -- 5389
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5392
		end -- 5392
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5394
	end -- 5394
	if self.room.key == "tower" then -- 5394
		if self.phase == "tower-wait" then -- 5394
			return "走到门前 445 点一次 E 敲两下" -- 5398
		end -- 5398
		if self.phase == "tower-knock" then -- 5398
			return "敲两下 · 等门开" -- 5401
		end -- 5401
		if self.phase == "tower-given" then -- 5401
			return "递交针套和纸条 · 看登记簿最后一行" -- 5404
		end -- 5404
		return "片尾 · 点 E 再玩一次，回到序章" -- 5406
	end -- 5406
	if self.room.key == "village" then -- 5406
		if self.bottleFly ~= nil then -- 5406
			return "等瓶子落地 · 触地才发声" -- 5410
		end -- 5410
		if self.hasBottle then -- 5410
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5413
		end -- 5413
		if self.passed then -- 5413
			return "已过第一院 · R 重置可再来一遍" -- 5416
		end -- 5416
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5418
	end -- 5418
	if self.room.key == "outside" then -- 5418
		if self.focusCart then -- 5418
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5422
		end -- 5422
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5424
	end -- 5424
	if self.escort.state == "frozen" then -- 5424
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5424
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5428
		end -- 5428
		return "小满吓住了 · 走过去，靠近再点 E" -- 5430
	end -- 5430
	if self.escort.state == "calming" then -- 5430
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5433
	end -- 5433
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5435
end -- 5311
function Play.prototype.draw(self, draw, w, h) -- 5440
	self.viewW = w -- 5441
	self.viewH = h -- 5442
	self.view = ____exports.computeViewport(w, h) -- 5443
	self:clampCamera(w, h) -- 5444
	draw:clear() -- 5445
	draw:drawRect( -- 5447
		Rect(0, 0, w, h), -- 5447
		BG_VOID -- 5447
	) -- 5447
	local box = self:canvasRect(w, h) -- 5448
	draw:drawRect(box, BG_FAR) -- 5449
	draw:drawRect( -- 5450
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 5450
		BG_MID -- 5450
	) -- 5450
	self:drawFloors(draw, w, h) -- 5452
	self:drawSolids(draw, w, h) -- 5453
	self:drawZones(draw, w, h) -- 5454
	self:drawArch(draw, w, h) -- 5455
	self:drawCart(draw, w, h) -- 5456
	self:drawCampaignProps(draw, w, h) -- 5457
	self:drawActors(draw, w, h) -- 5458
	self:drawTrace(draw, w, h) -- 5459
	self:drawAim(draw, w, h) -- 5460
end -- 5440
function Play.prototype.canvasRect(self, w, h) -- 5464
	local v = self.view -- 5465
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 5466
end -- 5464
function Play.prototype.px(self, n) -- 5470
	return n * self.view.zoom -- 5471
end -- 5470
function Play.prototype.sx(self, wx, w) -- 5475
	local v = self.view -- 5476
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 5477
	return v.ox + lx * v.zoom -- 5478
end -- 5475
function Play.prototype.sy(self, wy, h) -- 5482
	local v = self.view -- 5483
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 5484
	return v.oy + ly * v.zoom -- 5485
end -- 5482
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 5488
	local px0 = self:sx(x0, w) -- 5489
	local px1 = self:sx(x1, w) -- 5490
	local py0 = self:sy(y0, h) -- 5491
	local py1 = self:sy(y1, h) -- 5492
	if px1 <= px0 or py1 <= py0 then -- 5492
		return -- 5494
	end -- 5494
	draw:drawRect( -- 5496
		Rect(px0, py0, px1 - px0, py1 - py0), -- 5496
		color -- 5496
	) -- 5496
end -- 5488
function Play.prototype.drawFloors(self, draw, w, h) -- 5499
	local i = 0 -- 5500
	do -- 5500
		i = 0 -- 5501
		while i < #self.room.floors do -- 5501
			local f = self.room.floors[i + 1] -- 5502
			local ____temp_69 -- 5503
			if f.y == 0 then -- 5503
				____temp_69 = self.room.depth -- 5503
			else -- 5503
				____temp_69 = nil -- 5503
			end -- 5503
			local road = ____temp_69 -- 5503
			local y = self:sy(f.y + (road and road.min or 0), h) -- 5504
			local x0 = self:sx(f.x0, w) -- 5505
			local x1 = self:sx(f.x1, w) -- 5506
			local deck = self:px(5) -- 5507
			if road ~= nil then -- 5507
				local back = self:sy(f.y + road.max, h) -- 5509
				draw:drawRect( -- 5510
					Rect(x0, y, x1 - x0, back - y), -- 5510
					FLOOR_DECK, -- 5510
					self:px(1), -- 5510
					SOLID_EDGE -- 5510
				) -- 5510
			end -- 5510
			draw:drawRect( -- 5512
				Rect(x0, y - deck, x1 - x0, deck), -- 5512
				FLOOR_DECK -- 5512
			) -- 5512
			draw:drawSegment( -- 5513
				Vec2(x0, y), -- 5513
				Vec2(x1, y), -- 5513
				self:px(1), -- 5513
				GROUND -- 5513
			) -- 5513
			i = i + 1 -- 5501
		end -- 5501
	end -- 5501
end -- 5499
function Play.prototype.drawSolids(self, draw, w, h) -- 5517
	local i = 0 -- 5518
	do -- 5518
		i = 0 -- 5519
		while i < #self.boxes do -- 5519
			do -- 5519
				local b = self.boxes[i + 1] -- 5520
				if b.id == "braced_shield" or b.hidden == true then -- 5520
					goto __continue997 -- 5522
				end -- 5522
				if b.broken == true then -- 5522
					if b.breakable ~= nil then -- 5522
						local gy = self:sy(b.y0, h) -- 5527
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 5528
						local k = 0 -- 5529
						do -- 5529
							k = 0 -- 5530
							while k < 3 do -- 5530
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 5531
								draw:drawSegment( -- 5532
									Vec2( -- 5532
										gx - self:px(4), -- 5532
										gy + self:px(k % 2) -- 5532
									), -- 5532
									Vec2( -- 5532
										gx + self:px(5), -- 5532
										gy + self:px(k % 2) -- 5532
									), -- 5532
									self:px(1), -- 5532
									rgb -- 5532
								) -- 5532
								k = k + 1 -- 5530
							end -- 5530
						end -- 5530
					end -- 5530
					goto __continue997 -- 5535
				end -- 5535
				local ____opt_72 = b.depth -- 5535
				local front = ____opt_72 and ____opt_72.min or 0 -- 5537
				local ____opt_74 = b.depth -- 5537
				local back = ____opt_74 and ____opt_74.max or 0 -- 5538
				local fill = SOLID_FILL -- 5539
				local line = SOLID_EDGE -- 5540
				if b.soft == true then -- 5540
					fill = SOFT -- 5542
					line = SOFT_LINE -- 5543
				elseif b.breakable ~= nil then -- 5543
					line = DANGER_LINE -- 5545
					fill = Color(0.3, 0.24, 0.16, 1) -- 5546
				elseif b.interact ~= nil then -- 5546
					line = PASS_LINE -- 5548
				end -- 5548
				self:drawBox( -- 5550
					draw, -- 5550
					w, -- 5550
					h, -- 5550
					b.x0, -- 5550
					b.x1, -- 5550
					b.y0 + front, -- 5550
					b.y1 + back, -- 5550
					fill -- 5550
				) -- 5550
				draw:drawSegment( -- 5551
					Vec2( -- 5551
						self:sx(b.x0, w), -- 5551
						self:sy(b.y1 + front, h) -- 5551
					), -- 5551
					Vec2( -- 5552
						self:sx(b.x1, w), -- 5552
						self:sy(b.y1 + front, h) -- 5552
					), -- 5552
					self:px(1), -- 5552
					line -- 5552
				) -- 5552
				if b.breakable ~= nil then -- 5552
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 5555
					local cyp = self:sy(b.y1 + front, h) -- 5556
					draw:drawSegment( -- 5557
						Vec2( -- 5557
							cxp - self:px(4), -- 5557
							cyp + self:px(1) -- 5557
						), -- 5557
						Vec2( -- 5557
							cxp + self:px(3), -- 5557
							cyp + self:px(5) -- 5557
						), -- 5557
						self:px(1), -- 5557
						line -- 5557
					) -- 5557
				end -- 5557
			end -- 5557
			::__continue997:: -- 5557
			i = i + 1 -- 5519
		end -- 5519
	end -- 5519
end -- 5517
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 5563
	local i = 0 -- 5564
	do -- 5564
		i = 0 -- 5565
		while i < #self.pickups do -- 5565
			do -- 5565
				local pk = self.pickups[i + 1] -- 5566
				if self.run.taken[pk.id] == true then -- 5566
					goto __continue1009 -- 5568
				end -- 5568
				local gy = pk.y + (pk.depth or 0) -- 5570
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 5571
				draw:drawRect( -- 5572
					Rect( -- 5572
						self:sx(pk.x - 5, w), -- 5572
						self:sy(gy + 12 + bob, h), -- 5572
						self:px(10), -- 5572
						self:px(10) -- 5572
					), -- 5572
					Color(0.84, 0.7, 0.3, 1) -- 5573
				) -- 5573
				draw:drawSegment( -- 5574
					Vec2( -- 5574
						self:sx(pk.x - 5, w), -- 5574
						self:sy(gy + 12 + bob, h) -- 5574
					), -- 5574
					Vec2( -- 5575
						self:sx(pk.x + 5, w), -- 5575
						self:sy(gy + 12 + bob, h) -- 5575
					), -- 5575
					self:px(1), -- 5575
					Color(0.95, 0.86, 0.52, 1) -- 5575
				) -- 5575
			end -- 5575
			::__continue1009:: -- 5575
			i = i + 1 -- 5565
		end -- 5565
	end -- 5565
	if self.bracedShield ~= nil then -- 5565
		local sh = self.bracedShield -- 5578
		draw:drawRect( -- 5579
			Rect( -- 5579
				self:sx(sh.x - sh.w / 2, w), -- 5579
				self:sy(sh.y, h), -- 5579
				self:px(sh.w), -- 5579
				self:px(sh.h) -- 5579
			), -- 5579
			Color(0.42, 0.4, 0.34, 1) -- 5580
		) -- 5580
		draw:drawSegment( -- 5581
			Vec2( -- 5581
				self:sx(sh.x - sh.w / 2, w), -- 5581
				self:sy(sh.y + sh.h, h) -- 5581
			), -- 5581
			Vec2( -- 5582
				self:sx(sh.x + sh.w / 2, w), -- 5582
				self:sy(sh.y + sh.h, h) -- 5582
			), -- 5582
			self:px(1), -- 5582
			Color(0.74, 0.72, 0.62, 1) -- 5582
		) -- 5582
	end -- 5582
end -- 5563
function Play.prototype.drawZones(self, draw, w, h) -- 5586
	local i = 0 -- 5587
	do -- 5587
		i = 0 -- 5588
		while i < #self.room.zones do -- 5588
			local z = self.room.zones[i + 1] -- 5589
			local fill = DANGER -- 5590
			local line = DANGER_LINE -- 5591
			if z.tint == 2 then -- 5591
				fill = SOFT -- 5593
				line = SOFT_LINE -- 5594
			elseif z.tint == 3 then -- 5594
				fill = BRICK -- 5596
				line = BRICK_LINE -- 5597
			elseif z.tint == 4 then -- 5597
				fill = PASS -- 5599
				line = PASS_LINE -- 5600
			end -- 5600
			self:drawBox( -- 5602
				draw, -- 5602
				w, -- 5602
				h, -- 5602
				z.x0, -- 5602
				z.x1, -- 5602
				z.y, -- 5602
				z.y + z.h, -- 5602
				fill -- 5602
			) -- 5602
			draw:drawSegment( -- 5603
				Vec2( -- 5603
					self:sx(z.x0, w), -- 5603
					self:sy(z.y, h) -- 5603
				), -- 5603
				Vec2( -- 5603
					self:sx(z.x0, w), -- 5603
					self:sy(z.y + z.h, h) -- 5603
				), -- 5603
				self:px(1), -- 5603
				line -- 5603
			) -- 5603
			draw:drawSegment( -- 5604
				Vec2( -- 5604
					self:sx(z.x1, w), -- 5604
					self:sy(z.y, h) -- 5604
				), -- 5604
				Vec2( -- 5604
					self:sx(z.x1, w), -- 5604
					self:sy(z.y + z.h, h) -- 5604
				), -- 5604
				self:px(1), -- 5604
				line -- 5604
			) -- 5604
			i = i + 1 -- 5588
		end -- 5588
	end -- 5588
end -- 5586
function Play.prototype.drawArch(self, draw, w, h) -- 5608
	local a = self.room.arch -- 5609
	if a.h <= 0 then -- 5609
		return -- 5611
	end -- 5611
	self:drawBox( -- 5613
		draw, -- 5613
		w, -- 5613
		h, -- 5613
		a.x0, -- 5613
		a.x1, -- 5613
		a.y, -- 5613
		a.y + a.h, -- 5613
		HOLE_FILL -- 5613
	) -- 5613
	draw:drawSegment( -- 5614
		Vec2( -- 5614
			self:sx(a.x0, w), -- 5614
			self:sy(a.y + a.h, h) -- 5614
		), -- 5614
		Vec2( -- 5614
			self:sx(a.x1, w), -- 5614
			self:sy(a.y + a.h, h) -- 5614
		), -- 5614
		self:px(1), -- 5614
		SOLID_EDGE -- 5614
	) -- 5614
	draw:drawSegment( -- 5615
		Vec2( -- 5615
			self:sx(a.x0, w), -- 5615
			self:sy(a.y, h) -- 5615
		), -- 5615
		Vec2( -- 5615
			self:sx(a.x0, w), -- 5615
			self:sy(a.y + a.h, h) -- 5615
		), -- 5615
		self:px(1), -- 5615
		SOLID_EDGE -- 5615
	) -- 5615
	draw:drawSegment( -- 5616
		Vec2( -- 5616
			self:sx(a.x1, w), -- 5616
			self:sy(a.y, h) -- 5616
		), -- 5616
		Vec2( -- 5616
			self:sx(a.x1, w), -- 5616
			self:sy(a.y + a.h, h) -- 5616
		), -- 5616
		self:px(1), -- 5616
		SOLID_EDGE -- 5616
	) -- 5616
end -- 5608
function Play.prototype.drawCart(self, draw, w, h) -- 5619
	local c = self.room.cart -- 5620
	if c.bodyW <= 0 then -- 5620
		return -- 5622
	end -- 5622
	drawCartShape( -- 5624
		draw, -- 5624
		self, -- 5624
		w, -- 5624
		h, -- 5624
		c, -- 5624
		self.cartAxle -- 5624
	) -- 5624
	draw:drawRect( -- 5625
		Rect( -- 5625
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 5625
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 5625
			self:px(2), -- 5625
			self:px(40) -- 5625
		), -- 5625
		STAND -- 5625
	) -- 5625
end -- 5619
function Play.prototype.drawActors(self, draw, w, h) -- 5628
	local p = self.player -- 5629
	local isChild = self.childMode -- 5630
	local footY = p.y + p.depth -- 5631
	if p.covered then -- 5631
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 5634
		draw:drawSegment( -- 5635
			Vec2( -- 5635
				self:sx(edge, w), -- 5635
				self:sy(footY + 8, h) -- 5635
			), -- 5635
			Vec2( -- 5635
				self:sx(edge, w), -- 5635
				self:sy(footY + p.h * 0.62, h) -- 5635
			), -- 5635
			self:px(2), -- 5635
			STAND -- 5635
		) -- 5635
		draw:drawSegment( -- 5637
			Vec2( -- 5637
				self:sx(p.x - 8, w), -- 5637
				self:sy(footY + p.h + 3, h) -- 5637
			), -- 5637
			Vec2( -- 5637
				self:sx(p.x + 8, w), -- 5637
				self:sy(footY + p.h + 3, h) -- 5637
			), -- 5637
			self:px(2), -- 5637
			STAND -- 5637
		) -- 5637
	elseif self.coverNear and not isChild then -- 5637
		draw:drawRect( -- 5640
			Rect( -- 5640
				self:sx(p.x - 3, w), -- 5640
				self:sy(footY + 1, h), -- 5640
				self:px(3), -- 5640
				self:px(3) -- 5640
			), -- 5640
			STAND -- 5640
		) -- 5640
	end -- 5640
	drawFigure( -- 5642
		draw, -- 5642
		self, -- 5642
		w, -- 5642
		h, -- 5642
		p, -- 5642
		isChild and CHILD_BODY or SOLDIER_BODY, -- 5642
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 5642
	) -- 5642
	local q = self.partner -- 5643
	if q.alive then -- 5643
		local childPartner = q.w == CHILD_W -- 5645
		drawFigure( -- 5646
			draw, -- 5646
			self, -- 5646
			w, -- 5646
			h, -- 5646
			q, -- 5646
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 5646
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 5646
		) -- 5646
	end -- 5646
	local i = 0 -- 5648
	do -- 5648
		i = 0 -- 5649
		while i < #self.enemies do -- 5649
			local e = self.enemies[i + 1] -- 5650
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 5651
			local enemyY = e.y + (e.depth or 0) -- 5652
			self:drawBox( -- 5653
				draw, -- 5653
				w, -- 5653
				h, -- 5653
				e.x - e.w / 2, -- 5653
				e.x + e.w / 2, -- 5653
				enemyY, -- 5653
				enemyY + e.h, -- 5653
				col -- 5653
			) -- 5653
			if e.alive then -- 5653
				local ef = p.x >= e.x and 1 or -1 -- 5655
				if e.kind == "shield" then -- 5655
					local sh = (e.shieldHp or 0) > 0 -- 5657
					draw:drawRect( -- 5658
						Rect( -- 5658
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 5658
							self:sy(enemyY, h), -- 5658
							self:px(6), -- 5658
							self:px(64) -- 5658
						), -- 5658
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 5659
					) -- 5659
				elseif e.kind == "breaker" then -- 5659
					draw:drawSegment( -- 5661
						Vec2( -- 5661
							self:sx(e.x + ef * 12, w), -- 5661
							self:sy(enemyY + 8, h) -- 5661
						), -- 5661
						Vec2( -- 5662
							self:sx(e.x + ef * 22, w), -- 5662
							self:sy(enemyY + 46, h) -- 5662
						), -- 5662
						self:px(3), -- 5662
						Color(0.5, 0.36, 0.22, 1) -- 5662
					) -- 5662
				end -- 5662
			end -- 5662
			if e.alive and e.warnT > 0 then -- 5662
				local gunX = self:sx(e.x, w) -- 5667
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 5668
				local aimX = self:sx(p.x, w) -- 5669
				local aimY = self:sy(footY + p.h * 0.55, h) -- 5670
				local seg = 8 -- 5671
				local s = 0 -- 5672
				do -- 5672
					s = 0 -- 5673
					while s < seg do -- 5673
						local t0 = s / seg -- 5674
						local t1 = (s + 1) / seg -- 5675
						draw:drawSegment( -- 5676
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 5677
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 5678
							self:px(1), -- 5679
							DANGER -- 5679
						) -- 5679
						s = s + 2 -- 5673
					end -- 5673
				end -- 5673
			end -- 5673
			i = i + 1 -- 5649
		end -- 5649
	end -- 5649
	local k = 0 -- 5684
	do -- 5684
		k = 0 -- 5685
		while k < #self.room.marks do -- 5685
			do -- 5685
				local m = self.room.marks[k + 1] -- 5686
				if m.kind ~= 0 then -- 5686
					goto __continue1035 -- 5688
				end -- 5688
				local on = self.checkpoint == m.x -- 5690
				local x = self:sx(m.x, w) -- 5691
				local y = self:sy(m.y, h) -- 5692
				draw:drawSegment( -- 5693
					Vec2(x, y), -- 5693
					Vec2( -- 5693
						x, -- 5693
						y + self:px(35) -- 5693
					), -- 5693
					self:px(1), -- 5693
					on and CHECK or INK_DIM -- 5693
				) -- 5693
				draw:drawDot( -- 5694
					Vec2( -- 5694
						x, -- 5694
						y + self:px(35) -- 5694
					), -- 5694
					self:px(2), -- 5694
					on and CHECK or INK_DIM -- 5694
				) -- 5694
			end -- 5694
			::__continue1035:: -- 5694
			k = k + 1 -- 5685
		end -- 5685
	end -- 5685
	local j = 0 -- 5698
	do -- 5698
		j = 0 -- 5699
		while j < #self.room.marks do -- 5699
			do -- 5699
				local m = self.room.marks[j + 1] -- 5700
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 5700
					goto __continue1038 -- 5702
				end -- 5702
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 5702
					goto __continue1038 -- 5706
				end -- 5706
				local col = STAND -- 5708
				if m.kind == 4 then -- 5708
					col = PASS_LINE -- 5710
				elseif m.kind == 5 then -- 5710
					col = BRICK_LINE -- 5712
				end -- 5712
				local mx = self:sx(m.x, w) -- 5714
				local my = self:sy(m.y, h) -- 5715
				draw:drawSegment( -- 5716
					Vec2(mx, my), -- 5716
					Vec2( -- 5716
						mx, -- 5716
						my + self:px(24) -- 5716
					), -- 5716
					self:px(1), -- 5716
					col -- 5716
				) -- 5716
			end -- 5716
			::__continue1038:: -- 5716
			j = j + 1 -- 5699
		end -- 5699
	end -- 5699
	local t = 0 -- 5719
	do -- 5719
		t = 0 -- 5720
		while t < #self.room.marks do -- 5720
			do -- 5720
				local m = self.room.marks[t + 1] -- 5721
				if m.kind ~= 6 then -- 5721
					goto __continue1044 -- 5723
				end -- 5723
				local mx = self:sx(m.x, w) -- 5725
				local my = self:sy(m.y, h) -- 5726
				draw:drawSegment( -- 5727
					Vec2(mx, my), -- 5727
					Vec2( -- 5727
						mx, -- 5727
						my + self:px(30) -- 5727
					), -- 5727
					self:px(1), -- 5727
					INK_DIM -- 5727
				) -- 5727
				self:drawBox( -- 5728
					draw, -- 5728
					w, -- 5728
					h, -- 5728
					m.x - 5, -- 5728
					m.x + 5, -- 5728
					m.y + 30, -- 5728
					m.y + 40, -- 5728
					CHECK -- 5728
				) -- 5728
			end -- 5728
			::__continue1044:: -- 5728
			t = t + 1 -- 5720
		end -- 5720
	end -- 5720
	if self.room.key == "village" then -- 5720
		self:drawVillage(draw, w, h) -- 5731
	end -- 5731
	if self.room.key == "forest" then -- 5731
		self:drawDog(draw, w, h) -- 5734
	end -- 5734
end -- 5628
function Play.prototype.drawDog(self, draw, w, h) -- 5739
	local x = self.dogX -- 5740
	self:drawBox( -- 5741
		draw, -- 5741
		w, -- 5741
		h, -- 5741
		x - 14, -- 5741
		x + 14, -- 5741
		0, -- 5741
		20, -- 5741
		SCAV_BODY -- 5741
	) -- 5741
	self:drawBox( -- 5742
		draw, -- 5742
		w, -- 5742
		h, -- 5742
		x - 10, -- 5742
		x - 2, -- 5742
		20, -- 5742
		30, -- 5742
		SCAV_BODY -- 5742
	) -- 5742
	self:drawBox( -- 5743
		draw, -- 5743
		w, -- 5743
		h, -- 5743
		x + 2, -- 5743
		x + 10, -- 5743
		20, -- 5743
		30, -- 5743
		SCAV_HEAD -- 5743
	) -- 5743
	if self.dogState == "ear" or self.dogState == "chase" then -- 5743
		draw:drawSegment( -- 5745
			Vec2( -- 5745
				self:sx(x, w), -- 5745
				self:sy(30, h) -- 5745
			), -- 5745
			Vec2( -- 5746
				self:sx(x, w), -- 5746
				self:sy(40, h) -- 5746
			), -- 5746
			self:px(1), -- 5746
			DANGER -- 5746
		) -- 5746
	end -- 5746
end -- 5739
function Play.prototype.drawVillage(self, draw, w, h) -- 5751
	local bottle = self.room.bottle -- 5752
	if bottle ~= nil then -- 5752
		self:drawBox( -- 5754
			draw, -- 5754
			w, -- 5754
			h, -- 5754
			bottle.x - 14, -- 5754
			bottle.x + 14, -- 5754
			0, -- 5754
			64, -- 5754
			SOLID_FILL -- 5754
		) -- 5754
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 5754
			self:drawBottle( -- 5756
				draw, -- 5756
				w, -- 5756
				h, -- 5756
				bottle.x, -- 5756
				64 -- 5756
			) -- 5756
		end -- 5756
	end -- 5756
	self:drawBox( -- 5760
		draw, -- 5760
		w, -- 5760
		h, -- 5760
		300, -- 5760
		420, -- 5760
		44, -- 5760
		50, -- 5760
		FLOOR_DECK -- 5760
	) -- 5760
	self:drawBox( -- 5761
		draw, -- 5761
		w, -- 5761
		h, -- 5761
		300, -- 5761
		306, -- 5761
		0, -- 5761
		44, -- 5761
		FLOOR_DECK -- 5761
	) -- 5761
	self:drawBox( -- 5762
		draw, -- 5762
		w, -- 5762
		h, -- 5762
		414, -- 5762
		420, -- 5762
		0, -- 5762
		44, -- 5762
		FLOOR_DECK -- 5762
	) -- 5762
	local s = self.room.scavenger -- 5764
	if s ~= nil then -- 5764
		local sx0 = self.scavX -- 5766
		self:drawBox( -- 5767
			draw, -- 5767
			w, -- 5767
			h, -- 5767
			sx0 - 12, -- 5767
			sx0 + 12, -- 5767
			0, -- 5767
			s.h - 14, -- 5767
			SCAV_BODY -- 5767
		) -- 5767
		self:drawBox( -- 5768
			draw, -- 5768
			w, -- 5768
			h, -- 5768
			sx0 - 7, -- 5768
			sx0 + 7, -- 5768
			s.h - 14, -- 5768
			s.h, -- 5768
			SCAV_HEAD -- 5768
		) -- 5768
		if self.scavState == "turn" then -- 5768
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 5770
			draw:drawSegment( -- 5771
				Vec2( -- 5771
					self:sx(sx0, w), -- 5771
					self:sy(s.h - 6, h) -- 5771
				), -- 5771
				Vec2( -- 5771
					self:sx(fx, w), -- 5771
					self:sy(s.h - 6, h) -- 5771
				), -- 5771
				self:px(1), -- 5771
				INK -- 5771
			) -- 5771
		end -- 5771
	end -- 5771
	if self.hasBottle then -- 5771
		local p = self.player -- 5776
		self:drawBottle( -- 5777
			draw, -- 5777
			w, -- 5777
			h, -- 5777
			p.x + p.facing * 10, -- 5777
			p.y + p.h * 0.62 -- 5777
		) -- 5777
	end -- 5777
	if self.bottleFly ~= nil then -- 5777
		self:drawBottle( -- 5780
			draw, -- 5780
			w, -- 5780
			h, -- 5780
			self.bottleFly.x, -- 5780
			self.bottleFly.y -- 5780
		) -- 5780
	end -- 5780
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 5780
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 5783
		draw:drawCircle( -- 5784
			Vec2( -- 5784
				self:sx(self.bottleLandX, w), -- 5784
				self:sy(0, h) -- 5784
			), -- 5784
			self:px(r / ____exports.UNITS_PER_PX), -- 5784
			BRICK_LINE -- 5784
		) -- 5784
	end -- 5784
end -- 5751
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 5788
	self:drawBox( -- 5789
		draw, -- 5789
		w, -- 5789
		h, -- 5789
		x - 3, -- 5789
		x + 3, -- 5789
		y - 10, -- 5789
		y, -- 5789
		BOTTLE -- 5789
	) -- 5789
end -- 5788
function Play.prototype.drawTrace(self, draw, w, h) -- 5792
	local t = self.trace -- 5793
	if t == nil or self.traceT <= 0 then -- 5793
		return -- 5795
	end -- 5795
	draw:drawSegment( -- 5797
		Vec2( -- 5798
			self:sx(t.x0, w), -- 5798
			self:sy(t.y0, h) -- 5798
		), -- 5798
		Vec2( -- 5799
			self:sx(t.x1, w), -- 5799
			self:sy(t.y1, h) -- 5799
		), -- 5799
		self:px(1), -- 5800
		t.hit and AIM_HIT or INK_DIM -- 5800
	) -- 5800
end -- 5792
function Play.prototype.drawAim(self, draw, w, h) -- 5803
	local v = self.view -- 5805
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 5806
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 5807
	local dot = self:px(1) -- 5808
	local arm = self:px(3) -- 5809
	local gap = self:px(1) -- 5810
	draw:drawSegment( -- 5811
		Vec2(gx - arm - gap, gy), -- 5811
		Vec2(gx - gap, gy), -- 5811
		dot / 2, -- 5811
		AIM -- 5811
	) -- 5811
	draw:drawSegment( -- 5812
		Vec2(gx + gap, gy), -- 5812
		Vec2(gx + arm + gap, gy), -- 5812
		dot / 2, -- 5812
		AIM -- 5812
	) -- 5812
	draw:drawSegment( -- 5813
		Vec2(gx, gy - arm - gap), -- 5813
		Vec2(gx, gy - gap), -- 5813
		dot / 2, -- 5813
		AIM -- 5813
	) -- 5813
	draw:drawSegment( -- 5814
		Vec2(gx, gy + gap), -- 5814
		Vec2(gx, gy + arm + gap), -- 5814
		dot / 2, -- 5814
		AIM -- 5814
	) -- 5814
	if self.room.key == "village" and self.hasBottle then -- 5814
		local p = self.player -- 5818
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 5820
		local dir = ____end.x >= p.x and 1 or -1 -- 5821
		local x0 = p.x + dir * 10 -- 5822
		local y0 = p.y + p.h * 0.7 -- 5823
		local T = BOTTLE_FLY_TIME -- 5824
		local vx = (____end.x - x0) / T -- 5825
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 5826
		local pxr = x0 -- 5827
		local pyr = y0 -- 5828
		local t = 1 -- 5829
		do -- 5829
			t = 1 -- 5830
			while t <= 12 do -- 5830
				local tt = t / 12 * T -- 5831
				local nx = x0 + vx * tt -- 5832
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 5833
				draw:drawSegment( -- 5834
					Vec2( -- 5834
						self:sx(pxr, w), -- 5834
						self:sy(pyr, h) -- 5834
					), -- 5834
					Vec2( -- 5834
						self:sx(nx, w), -- 5834
						self:sy(ny, h) -- 5834
					), -- 5834
					self:px(1) / 2, -- 5834
					BOTTLE -- 5834
				) -- 5834
				pxr = nx -- 5835
				pyr = ny -- 5836
				t = t + 1 -- 5830
			end -- 5830
		end -- 5830
		draw:drawCircle( -- 5838
			Vec2( -- 5838
				self:sx(____end.x, w), -- 5838
				self:sy(____end.y + 2, h) -- 5838
			), -- 5838
			self:px(2), -- 5838
			BOTTLE -- 5838
		) -- 5838
	end -- 5838
end -- 5803
return ____exports -- 5803