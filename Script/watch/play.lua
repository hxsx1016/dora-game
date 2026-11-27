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
function makeActor(room, index) -- 5708
	local sp = room.spawns -- 5709
	if index < 0 or index >= #sp then -- 5709
		return { -- 5711
			x = 0, -- 5711
			y = 0, -- 5711
			depth = 0, -- 5711
			depthSpeed = 0, -- 5711
			vx = 0, -- 5711
			vy = 0, -- 5711
			w = CHILD_W, -- 5711
			h = CHILD_H, -- 5711
			onGround = true, -- 5711
			facing = 1, -- 5711
			crouch = false, -- 5711
			rollT = 0, -- 5711
			covered = false, -- 5711
			alive = false -- 5711
		} -- 5711
	end -- 5711
	local s = sp[index + 1] -- 5713
	local child = s.h < SOLDIER_H -- 5714
	local ground = room.depth -- 5715
	local depth = ground == nil and 0 or math.max( -- 5716
		ground.min, -- 5716
		math.min(ground.max, s.depth or 0) -- 5716
	) -- 5716
	return { -- 5717
		x = s.x, -- 5718
		y = s.y, -- 5718
		depth = depth, -- 5718
		depthSpeed = 0, -- 5718
		vx = 0, -- 5718
		vy = 0, -- 5718
		w = child and CHILD_W or SOLDIER_W, -- 5719
		h = child and CHILD_H or SOLDIER_H, -- 5720
		onGround = true, -- 5721
		facing = 1, -- 5721
		crouch = false, -- 5721
		rollT = 0, -- 5721
		covered = false, -- 5721
		alive = true -- 5721
	} -- 5721
end -- 5721
function drawFigure(draw, play, w, h, a, body, head) -- 5725
	if not a.alive then -- 5725
		return -- 5727
	end -- 5727
	local x0 = a.x - a.w / 2 -- 5729
	local x1 = a.x + a.w / 2 -- 5730
	local y0 = a.y + a.depth * DEPTH_Y_SCALE -- 5731
	local y1 = y0 + a.h -- 5732
	play:drawBox( -- 5733
		draw, -- 5733
		w, -- 5733
		h, -- 5733
		x0, -- 5733
		x1, -- 5733
		y0, -- 5733
		y1 - a.h * 0.26, -- 5733
		body -- 5733
	) -- 5733
	play:drawBox( -- 5734
		draw, -- 5734
		w, -- 5734
		h, -- 5734
		x0 + 2, -- 5734
		x1 - 2, -- 5734
		y1 - a.h * 0.26, -- 5734
		y1, -- 5734
		head -- 5734
	) -- 5734
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 5736
	play:drawBox( -- 5737
		draw, -- 5737
		w, -- 5737
		h, -- 5737
		eyeX, -- 5737
		eyeX + 4, -- 5737
		y1 - a.h * 0.14, -- 5737
		y1 - a.h * 0.08, -- 5737
		INK -- 5737
	) -- 5737
end -- 5737
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5741
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5742
end -- 5741
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5749
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5750
end -- 5749
function rayInterval(origin, direction, min, max) -- 5757
	if direction == 0 then -- 5757
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5759
	end -- 5759
	local a = (min - origin) / direction -- 5761
	local b = (max - origin) / direction -- 5762
	return { -- 5763
		min = math.min(a, b), -- 5763
		max = math.max(a, b) -- 5763
	} -- 5763
end -- 5763
function hitBox(ray, box) -- 5767
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5768
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5769
	local enter = math.max(0, x.min, y.min) -- 5770
	local leave = math.min(99999, x.max, y.max) -- 5771
	if box.depth ~= nil then -- 5771
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5773
		enter = math.max(enter, depth.min) -- 5774
		leave = math.min(leave, depth.max) -- 5775
	end -- 5775
	return leave >= enter and enter or -1 -- 5777
end -- 5777
function drawCartShape(draw, play, w, h, c, axleX) -- 5780
	local half = c.bodyW / 2 -- 5781
	local x0 = axleX - half -- 5782
	local x1 = axleX + half -- 5783
	local axleY = c.baseY + (c.depth or 0) * DEPTH_Y_SCALE + c.wheelR -- 5784
	play:drawBox( -- 5785
		draw, -- 5785
		w, -- 5785
		h, -- 5785
		x0, -- 5785
		x1, -- 5785
		axleY, -- 5785
		axleY + c.bodyH, -- 5785
		CART_FILL -- 5785
	) -- 5785
	draw:drawCircle( -- 5786
		Vec2( -- 5786
			play:sx(x0 + c.bodyW * 0.28, w), -- 5786
			play:sy(axleY, h) -- 5786
		), -- 5786
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5786
		Color(52, 50, 48, 255) -- 5786
	) -- 5786
	draw:drawCircle( -- 5787
		Vec2( -- 5787
			play:sx(x1 - c.bodyW * 0.28, w), -- 5787
			play:sy(axleY, h) -- 5787
		), -- 5787
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5787
		Color(52, 50, 48, 255) -- 5787
	) -- 5787
	local cx = c.clothSide < 0 and x0 or x1 -- 5788
	play:drawBox( -- 5789
		draw, -- 5789
		w, -- 5789
		h, -- 5789
		cx - 10, -- 5789
		cx + 10, -- 5789
		axleY + c.bodyH, -- 5789
		axleY + c.bodyH + 18, -- 5789
		CLOTH -- 5789
	) -- 5789
end -- 5789
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
function Play.prototype.____constructor(self, room, resume, run) -- 652
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
	self.footHintT = 0 -- 436
	self.ditchHinted = false -- 438
	self.forestPath = "" -- 440
	self.waterSeen = false -- 442
	self.scavX = 0 -- 444
	self.scavDir = 1 -- 445
	self.scavState = "patrol" -- 446
	self.scavT = 0 -- 447
	self.scavTargetX = 0 -- 448
	self.passed = false -- 450
	self.childMode = false -- 454
	self.phase = "" -- 456
	self.phaseTick = 0 -- 458
	self.gateTick = 0 -- 460
	self.countTick = 0 -- 462
	self.countArmed = false -- 464
	self.countPrevMove = 0 -- 466
	self.caughtT = 0 -- 468
	self.hp = 3 -- 470
	self.maxHp = 3 -- 471
	self.invulnT = 0 -- 477
	self.partnerStuck = 0 -- 479
	self.partnerLaneIdx = 0 -- 481
	self.partnerLaneHold = 0 -- 482
	self.coveredFlash = 0 -- 484
	self.coverHug = false -- 486
	self.coverNear = false -- 488
	self.coverEntity = "" -- 490
	self.coverBlocking = false -- 492
	self.gateNeedConfirm = false -- 494
	self.gateRestartArmed = true -- 496
	self.bottleAimX = -1 -- 498
	self.bottleAimY = 0 -- 499
	self.bottleSurfaceY = -1 -- 501
	self.bottleLandY = 0 -- 503
	self.events = {} -- 505
	self.eventSeq = 0 -- 507
	self.dogX = 0 -- 509
	self.dogDir = 1 -- 510
	self.dogState = "patrol" -- 511
	self.dogT = 0 -- 512
	self.dogTargetX = 0 -- 513
	self.scavSee = 0 -- 515
	self.scavChase = false -- 516
	self.gateSpawned = 0 -- 518
	self.gateFailCount = 0 -- 520
	self.isCampaign = false -- 524
	self.archiveDirty = false -- 532
	self.sessionDirty = false -- 534
	self.restartStory = false -- 536
	self.wellOpen = false -- 538
	self.wellX = 430 -- 540
	self.wellTaken = false -- 542
	self.museumReturn = false -- 544
	self.endingLines = {"", ""} -- 546
	self.towerDoorOpen = false -- 548
	self.towerHanded = false -- 549
	self.deskHold = 0 -- 550
	self.equippedWeapon = "standard_gun" -- 554
	self.craftBench = { -- 556
		active = false, -- 557
		firstCraftDone = false, -- 558
		justCraftedTimer = 0, -- 559
		inventory = {}, -- 560
		recipes = {}, -- 561
		equippedWeapon = "standard_gun" -- 562
	} -- 562
	self.handledCraftRequests = {} -- 565
	self.benchReach = 48 -- 567
	self.pickups = {} -- 571
	self.reloadT = 0 -- 573
	self.objectiveDone = false -- 577
	self.hint = "" -- 579
	self.roomStartTick = 0 -- 581
	self.cartHitT = 0 -- 583
	self.cartExposed = false -- 584
	self.storyRoute = "" -- 588
	self.storySettled = false -- 590
	self.hpAtGate = -1 -- 592
	self.maxHpAtGate = -1 -- 593
	self.handTicks = 0 -- 595
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 597
	self.handArmed = false -- 599
	self.handDone = false -- 601
	self.lineSaid = false -- 602
	self.tied = false -- 604
	self.pathDone = false -- 606
	self.carryOn = false -- 608
	self.escortDone = false -- 610
	self.escapeDuration = ____exports.PROLOGUE_ESCAPE_TICKS / 60 -- 614
	self.escapeRemaining = 0 -- 616
	self.escapeRetryCount = 0 -- 618
	self.introTick = 0 -- 620
	self.reloadOpen = false -- 624
	self.reloadAnswerTicks = 0 -- 626
	self.reloadWorldTicks = 0 -- 628
	self.reloadPath = {RELOAD_START} -- 630
	self.reloadPendingEffect = "" -- 632
	self.reloadTryCount = 0 -- 634
	self.paused = false -- 636
	self.ticks = 0 -- 638
	self.view = {zoom = 1, ox = 0, oy = 0} -- 640
	self.ox = 0 -- 642
	self.aimX = 0 -- 644
	self.aimY = 0 -- 645
	self.viewW = 0 -- 647
	self.viewH = 0 -- 648
	self.ox = room.originX -- 654
	self.room = withOrigin(room) -- 655
	local wr = self.room -- 656
	self.run = run or createRun() -- 657
	self.inventory = self.run.inventory -- 658
	self.archive = self.run.archive -- 659
	self.equippedWeapon = self.run.story.craftedWeapon == "" and "standard_gun" or self.run.story.craftedWeapon -- 660
	self.isCampaign = wr.campaign ~= nil -- 661
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 662
	self:buildWorld() -- 663
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 666
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 668
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 669
	local soloRoom = wr.key == "museum" -- 671
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 672
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 673
	self.player = makeActor(wr, playerIdx) -- 674
	self.partner = makeActor(wr, partnerIdx) -- 675
	self.phase = phaseOf(wr.key) -- 676
	if soloRoom then -- 676
		local mp = self.archive.museumPhase -- 679
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 680
	end -- 680
	if wr.story ~= nil then -- 680
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 686
	end -- 686
	self.cam.x = self.player.x -- 688
	self.cam.y = self.player.y + CAM_LOOK_UP -- 689
	self.cartAxle = wr.cart.startX -- 690
	self.escort = __TS__New( -- 691
		Escort, -- 691
		safeAnchorX(wr.marks) -- 691
	) -- 691
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 692
	if self.isCampaign then -- 692
		self:setupCampaign() -- 694
	else -- 694
		self:buildEnemies() -- 696
	end -- 696
	if resume ~= nil and resume.checkpoint > 0 then -- 696
		self.checkpoint = resume.checkpoint -- 700
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 700
			self.cartAxle = self.room.cart.endX -- 702
			self.cartDocked = true -- 703
			self.player.x = self.ox + 380 -- 706
			self.player.y = 0 -- 707
			self.player.vy = 0 -- 708
			self.player.onGround = true -- 709
			self.cam.x = self.player.x -- 710
			self.cam.y = self.player.y + CAM_LOOK_UP -- 711
		end -- 711
	end -- 711
	self:restoreStory() -- 714
end -- 652
function Play.prototype.recipeViews(self) -- 727
	local out = {} -- 728
	local i = 0 -- 729
	do -- 729
		i = 0 -- 730
		while i < #CRAFT_RECIPES do -- 730
			local r = CRAFT_RECIPES[i + 1] -- 731
			local cost = {} -- 732
			if r.cost.wood ~= nil then -- 732
				cost.wood = r.cost.wood -- 734
			end -- 734
			if r.cost.bell ~= nil then -- 734
				cost.bell = r.cost.bell -- 737
			end -- 737
			out[#out + 1] = { -- 739
				id = r.id, -- 740
				name = r.name, -- 741
				desc = r.desc, -- 742
				enhancedEffect = r.enhancedEffect, -- 743
				cost = cost, -- 744
				crafted = self.run.story.craftedWeapon == r.id -- 745
			} -- 745
			i = i + 1 -- 730
		end -- 730
	end -- 730
	if self.archive.artifactOwned then -- 730
		out[#out + 1] = { -- 750
			id = ARTIFACT_WEAPON_ID, -- 751
			name = weaponNameOf(ARTIFACT_WEAPON_ID), -- 752
			desc = "井底拾取彩蛋 · 男主线移动留下冷白微金轨迹残影", -- 753
			enhancedEffect = "light", -- 754
			cost = {}, -- 755
			crafted = true -- 756
		} -- 756
	end -- 756
	return out -- 759
end -- 727
function Play.prototype.syncCraftBench(self) -- 763
	local view = self.craftBench -- 764
	local inv = self.run.inventory -- 765
	view.inventory = { -- 766
		wood = inv.wood, -- 766
		bell = inv.bell, -- 766
		scrap = inv.scrap, -- 766
		wedge = inv.wedge, -- 766
		ammo = inv.ammo -- 766
	} -- 766
	view.recipes = self:recipeViews() -- 767
	view.equippedWeapon = self.equippedWeapon -- 768
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 769
	if view.justCraftedTimer > 0 then -- 769
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 771
	end -- 771
end -- 763
function Play.prototype.openCraftBench(self) -- 776
	if self.room.key ~= "escort3" or self.craftBench.active then -- 776
		return -- 778
	end -- 778
	self.craftBench.active = true -- 780
	self.carryOn = false -- 781
	self.run.story.carry = false -- 782
	self.player.vx = 0 -- 783
	self.player.vy = 0 -- 784
	self.craftBench.justCraftedTimer = 0 -- 785
	self:syncCraftBench() -- 786
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 787
	self:log("开工台") -- 788
	self:emit( -- 789
		"benchOpen", -- 789
		{ -- 789
			recipes = __TS__ArrayMap( -- 790
				self.craftBench.recipes, -- 790
				function(____, r) return r.id end -- 790
			), -- 790
			inventory = self.craftBench.inventory, -- 791
			carry = self.carryOn -- 792
		} -- 792
	) -- 792
end -- 776
function Play.prototype.closeCraftBench(self) -- 797
	if not self.craftBench.active then -- 797
		return -- 799
	end -- 799
	self.craftBench.active = false -- 801
	self.craftBench.justCraftedTimer = 0 -- 802
	self.carryOn = true -- 803
	self.run.story.carry = true -- 804
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 805
	self:log("离站背起") -- 806
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 807
end -- 797
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 814
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 814
		return false -- 816
	end -- 816
	local recipe = findRecipe(recipeId) -- 818
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 818
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 820
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 821
		return false -- 822
	end -- 822
	local missing = missingMaterials(self.run.inventory, recipe) -- 824
	if #missing > 0 then -- 824
		self:flashSet( -- 826
			"缺料 · " .. table.concat(missing, " / "), -- 826
			1.6 -- 826
		) -- 826
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 827
		return false -- 828
	end -- 828
	payMaterials(self.run.inventory, recipe) -- 830
	self.handledCraftRequests[requestId] = true -- 831
	self.run.story.craftedWeapon = recipe.id -- 832
	self.run.story.equippedWeapon = recipe.id -- 833
	self.equippedWeapon = recipe.id -- 834
	self.sessionDirty = true -- 835
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 836
	self.craftBench.firstCraftDone = true -- 837
	self:syncCraftBench() -- 838
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 839
	self:log("改制 " .. recipe.id) -- 840
	self:emit("benchCraft", { -- 841
		recipeId = recipe.id, -- 842
		weapon = recipe.id, -- 843
		effect = recipe.enhancedEffect, -- 844
		wood = self.run.inventory.wood, -- 845
		bell = self.run.inventory.bell -- 846
	}) -- 846
	return true -- 848
end -- 814
function Play.prototype.equipWeapon(self, weaponId) -- 852
	local artifactOk = weaponId == ARTIFACT_WEAPON_ID and self.archive.artifactOwned -- 853
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId and not artifactOk then -- 853
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 855
		return false -- 856
	end -- 856
	self.equippedWeapon = weaponId -- 858
	self.run.story.equippedWeapon = weaponId -- 859
	self.sessionDirty = true -- 860
	self:syncCraftBench() -- 861
	self:flashSet( -- 862
		"已装备 " .. weaponNameOf(weaponId), -- 862
		1 -- 862
	) -- 862
	self:emit("benchEquip", {weapon = weaponId}) -- 863
	return true -- 864
end -- 852
function Play.prototype.toggleArtifactWeapon(self) -- 868
	if not self.archive.artifactOwned or self.childMode then -- 868
		return false -- 870
	end -- 870
	if self.equippedWeapon == ARTIFACT_WEAPON_ID then -- 870
		local fallback = self.run.story.craftedWeapon ~= "" and self.run.story.craftedWeapon or "standard_gun" -- 873
		return self:equipWeapon(fallback) -- 874
	end -- 874
	return self:equipWeapon(ARTIFACT_WEAPON_ID) -- 876
end -- 868
function Play.prototype.exportSession(self) -- 880
	self:syncStory() -- 881
	local story = self.run.story -- 882
	local inv = self.run.inventory -- 883
	local taken = {} -- 884
	for k in pairs(self.run.taken) do -- 885
		if self.run.taken[k] == true then -- 885
			taken[#taken + 1] = k -- 887
		end -- 887
	end -- 887
	local segments = {} -- 890
	for k in pairs(story.segments) do -- 891
		if story.segments[k] == true then -- 891
			segments[#segments + 1] = k -- 893
		end -- 893
	end -- 893
	return { -- 896
		roomKey = self.room.key, -- 897
		checkpoint = self.checkpoint, -- 898
		seed = self.run.seed, -- 899
		route = story.route, -- 900
		hp = story.hp, -- 901
		maxHp = story.maxHp, -- 902
		hpAtGate = story.hpAtGate, -- 903
		maxHpAtGate = story.maxHpAtGate, -- 904
		settled = story.settled, -- 905
		phase = self.phase, -- 906
		countTick = story.countTick, -- 907
		phaseTick = story.phaseTick, -- 908
		handTicks = story.handTicks, -- 909
		handDone = story.handDone, -- 910
		lineSaid = story.lineSaid, -- 911
		tied = story.tied, -- 912
		carry = story.carry, -- 913
		escortDone = story.escortDone, -- 914
		craftedWeapon = story.craftedWeapon, -- 915
		equippedWeapon = self.equippedWeapon, -- 916
		wood = inv.wood, -- 917
		bell = inv.bell, -- 918
		scrap = inv.scrap, -- 919
		wedge = inv.wedge, -- 920
		ammo = inv.ammo, -- 921
		shield = inv.shield, -- 922
		pass = inv.pass, -- 923
		quickbelt = inv.quickbelt, -- 924
		taken = taken, -- 925
		segments = segments, -- 926
		cartAxle = self.cartAxle, -- 927
		cartDocked = self.cartDocked -- 928
	} -- 928
end -- 880
function Play.prototype.submitFeIntent(self, intent) -- 936
	local kind = intent == nil and "" or intent.kind -- 937
	if kind == "reloadTapNode" then -- 937
		local node = intent.node -- 939
		if type(node) == "number" then -- 939
			self:reloadTapNode(node) -- 941
			return true -- 942
		end -- 942
		return false -- 944
	end -- 944
	if kind == "reloadPathCommit" then -- 944
		local path = intent.path -- 947
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 947
			local list = path -- 949
			local i = 0 -- 950
			do -- 950
				i = 0 -- 951
				while i < #list do -- 951
					do -- 951
						if i == 0 and list[i + 1] == RELOAD_START then -- 951
							goto __continue59 -- 953
						end -- 953
						self:reloadTapNode(list[i + 1]) -- 955
					end -- 955
					::__continue59:: -- 955
					i = i + 1 -- 951
				end -- 951
			end -- 951
			return true -- 957
		end -- 957
		return false -- 959
	end -- 959
	if kind == "reloadCancel" then -- 959
		self:closeReloadPuzzle() -- 962
		return true -- 963
	end -- 963
	if kind == "craftSubmit" then -- 963
		local recipeId = intent.recipeId -- 966
		local requestId = intent.requestId -- 967
		if type(recipeId) == "string" and type(requestId) == "string" then -- 967
			return self:craftAtBench(recipeId, requestId) -- 969
		end -- 969
		return false -- 971
	end -- 971
	if kind == "craftEquip" then -- 971
		local weaponId = intent.weaponId -- 974
		if type(weaponId) == "string" then -- 974
			return self:equipWeapon(weaponId) -- 976
		end -- 976
		return false -- 978
	end -- 978
	if kind == "craftClose" then -- 978
		self:closeCraftBench() -- 981
		return true -- 982
	end -- 982
	if kind == "wellPick" then -- 982
		return self:pickWell() -- 985
	end -- 985
	return false -- 987
end -- 936
function Play.prototype.captureCheckpoint(self, id) -- 991
	local inv = self.run.inventory -- 992
	self.checkpointSnap = { -- 993
		id = id, -- 994
		wood = inv.wood, -- 995
		bell = inv.bell, -- 996
		scrap = inv.scrap, -- 997
		wedge = inv.wedge, -- 998
		ammo = inv.ammo, -- 999
		shield = inv.shield, -- 1000
		pass = inv.pass, -- 1001
		quickbelt = inv.quickbelt, -- 1002
		crafted = self.run.story.craftedWeapon, -- 1003
		equipped = self.equippedWeapon, -- 1004
		carry = self.carryOn -- 1005
	} -- 1005
	self.run.story.cp = self.checkpointSnap -- 1007
end -- 991
function Play.prototype.applyCheckpointSnap(self, id) -- 1011
	local snap = self.run.story.cp -- 1012
	if snap == nil or snap.id ~= id then -- 1012
		return false -- 1014
	end -- 1014
	self.checkpointSnap = snap -- 1016
	local inv = self.run.inventory -- 1017
	inv.wood = snap.wood -- 1018
	inv.bell = snap.bell -- 1019
	inv.scrap = snap.scrap -- 1020
	inv.wedge = snap.wedge -- 1021
	inv.ammo = snap.ammo -- 1022
	inv.shield = snap.shield -- 1023
	inv.pass = snap.pass -- 1024
	inv.quickbelt = snap.quickbelt -- 1025
	self.run.story.craftedWeapon = snap.crafted -- 1026
	self.equippedWeapon = snap.equipped -- 1027
	self.carryOn = snap.carry -- 1028
	self.run.story.carry = snap.carry -- 1029
	self.craftBench.active = false -- 1030
	self:syncCraftBench() -- 1031
	return true -- 1032
end -- 1011
function Play.prototype.restoreStory(self) -- 1035
	if self.isCampaign and self.run.trial ~= nil then -- 1035
		return -- 1039
	end -- 1039
	local story = self.run.story -- 1041
	if story == nil then -- 1041
		return -- 1043
	end -- 1043
	if story.maxHp > 0 then -- 1043
		self.maxHp = story.maxHp -- 1046
		self.hp = math.max( -- 1047
			1, -- 1047
			math.min(story.hp, story.maxHp) -- 1047
		) -- 1047
	end -- 1047
	self.storyRoute = story.route -- 1049
	self.storySettled = story.settled -- 1050
	self.hpAtGate = story.hpAtGate -- 1051
	self.maxHpAtGate = story.maxHpAtGate -- 1052
	self.handDone = story.handDone -- 1053
	self.lineSaid = story.lineSaid -- 1054
	self.tied = story.handDone -- 1055
	self.carryOn = story.carry or story.route == "soldier" and self.room.key == "escort1" -- 1056
	self.museumReturn = story.museumReturn -- 1057
	story.museumReturn = false -- 1058
	self.escortDone = story.escortDone -- 1059
	local savedEq = story.equippedWeapon -- 1060
	if savedEq == ARTIFACT_WEAPON_ID and self.archive.artifactOwned then -- 1060
		self.equippedWeapon = ARTIFACT_WEAPON_ID -- 1062
	elseif savedEq == "standard_gun" or savedEq ~= "" and savedEq == story.craftedWeapon then -- 1062
		self.equippedWeapon = savedEq -- 1064
	else -- 1064
		self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 1066
	end -- 1066
	self:syncCraftBench() -- 1068
	if story.segments.outside_cart == true then -- 1068
		self.redCartPulled = true -- 1071
		local redBox = __TS__ArrayFind( -- 1072
			self.boxes, -- 1072
			function(____, b) return b.id == "outside_red_cart" end -- 1072
		) -- 1072
		if redBox ~= nil then -- 1072
			redBox.x0 = 430 -- 1074
			redBox.x1 = 474 -- 1075
		end -- 1075
		if self.room.key == "outside" and self.room.cart.bodyW > 0 then -- 1075
			self.cartAxle = self.room.cart.endX -- 1078
			self.cartDocked = true -- 1079
		end -- 1079
	end -- 1079
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 1082
	self.waterSeen = story.segments.water_lantern == true -- 1084
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 1084
		self:applyCheckpointSnap(self.checkpoint) -- 1087
	end -- 1087
	if self.room.key == "tower" and story.route == "soldier" then -- 1087
		self.carryOn = false -- 1091
		self.run.story.carry = false -- 1092
		self.partner = { -- 1093
			x = math.max(self.room.minX + 40, self.player.x - 36), -- 1094
			y = 0, -- 1095
			depth = 0, -- 1096
			depthSpeed = 0, -- 1097
			vx = 0, -- 1098
			vy = 0, -- 1099
			w = SOLDIER_W, -- 1100
			h = SOLDIER_H, -- 1101
			onGround = true, -- 1102
			facing = 1, -- 1103
			crouch = false, -- 1104
			rollT = 0, -- 1105
			covered = false, -- 1106
			alive = true -- 1107
		} -- 1107
	end -- 1107
	if self.room.key == "tower" then -- 1107
		if story.segments.tower_door == true then -- 1107
			self:openTowerDoor() -- 1113
		end -- 1113
		self.towerHanded = story.segments.tower_handover == true -- 1115
		self.deskHold = 0 -- 1116
		if story.phase == "tower-enter" or story.phase == "tower-desk" or story.phase == "tower-given" then -- 1116
			self.phase = story.phase -- 1118
			self.phaseTick = 0 -- 1119
			if story.phase == "tower-desk" or story.phase == "tower-given" then -- 1119
				self.player.x = self.ox + 605 -- 1121
				self.player.y = 0 -- 1122
				if story.route == "soldier" and self.partner.alive then -- 1122
					self.partner.x = self.ox + 568 -- 1124
					self.partner.y = 0 -- 1125
					self.partner.facing = 1 -- 1126
				end -- 1126
			end -- 1126
		end -- 1126
	end -- 1126
	if self.room.key == "prologue" then -- 1126
		local ph = story.phase -- 1133
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 1133
			self.phase = ph -- 1135
			self.phaseTick = story.phaseTick -- 1136
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 1137
			self.player.y = 0 -- 1138
			self.player.depth = 0 -- 1139
			self.player.vx = 0 -- 1140
			self.partner.x = self.ox + 300 -- 1141
			self.partner.y = 0 -- 1142
			self.partner.depth = 0 -- 1143
			self.partner.vx = 0 -- 1144
			self.partner.alive = true -- 1145
			if ph == "prologue-follow" then -- 1145
				self.partner.crouch = false -- 1147
				self.partner.h = CHILD_H -- 1148
			else -- 1148
				self.partner.crouch = true -- 1150
				self.partner.h = CHILD_CROUCH_H -- 1151
			end -- 1151
			self.cam.x = self.player.x -- 1153
		end -- 1153
		return -- 1155
	end -- 1155
	if self.room.key ~= "gate" then -- 1155
		return -- 1158
	end -- 1158
	local ____temp_0 -- 1160
	if self.room.story == nil then -- 1160
		____temp_0 = nil -- 1160
	else -- 1160
		____temp_0 = self.room.story.gate -- 1160
	end -- 1160
	local g = ____temp_0 -- 1160
	if g == nil then -- 1160
		return -- 1162
	end -- 1162
	if story.phase == "gate-send" then -- 1162
		self.phase = "gate-send" -- 1166
		self.gateTick = g.holdTicks -- 1167
		self.gateSpawned = 4 -- 1168
		self.enemies = {} -- 1169
		self.player.x = self.ox + g.doorX - 40 -- 1170
		self.player.y = 0 -- 1171
		self.player.depth = 0 -- 1172
		self.player.vx = 0 -- 1173
		self.player.vy = 0 -- 1174
		self.player.onGround = true -- 1175
		self.partner.x = self.ox + g.waitX -- 1176
		self.partner.y = 0 -- 1177
		self.partner.depth = 0 -- 1178
		self.partner.alive = true -- 1179
		self.cam.x = self.player.x -- 1180
		self.handTicks = 0 -- 1181
		self.handArmed = false -- 1182
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1183
		return -- 1184
	end -- 1184
	if not story.settled then -- 1184
		return -- 1187
	end -- 1187
	self.gateTick = g.holdTicks -- 1190
	self.gateSpawned = 4 -- 1191
	self.enemies = {} -- 1192
	if story.phase == "gate-count" or story.phase == "gate-walk" then -- 1192
		self.phase = story.phase -- 1194
		self.countTick = math.max(story.countTick, 0) -- 1195
		self:swapToChild(g.doorX + 30) -- 1196
		self.countPrevMove = 0 -- 1197
		self.countArmed = false -- 1198
		return -- 1199
	end -- 1199
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1199
		self.phase = story.phase -- 1202
		self.countTick = ____exports.GATE_COUNT_END -- 1203
		self.phaseTick = story.phaseTick -- 1204
		self:swapToChild(g.doorX + 30) -- 1205
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1206
			0, -- 1206
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1206
		) -- 1206
		self.handArmed = false -- 1207
	end -- 1207
end -- 1035
function Play.prototype.buildWorld(self) -- 1212
	local room = self.room -- 1213
	self.boxes = {} -- 1214
	self.floors = {} -- 1215
	local i = 0 -- 1216
	do -- 1216
		i = 0 -- 1217
		while i < #room.floors do -- 1217
			local f = room.floors[i + 1] -- 1218
			local ____self_floors_1 = self.floors -- 1218
			____self_floors_1[#____self_floors_1 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1219
			i = i + 1 -- 1217
		end -- 1217
	end -- 1217
	do -- 1217
		i = 0 -- 1221
		while i < #room.solids do -- 1221
			local s = room.solids[i + 1] -- 1222
			if not s.decorative then -- 1222
				local ____self_boxes_13 = self.boxes -- 1228
				local ____s_x_4 = s.x -- 1229
				local ____temp_5 = s.x + s.w -- 1229
				local ____s_y_6 = s.y -- 1229
				local ____temp_7 = s.y + s.h -- 1229
				local ____temp_2 -- 1230
				if room.depth == nil then -- 1230
					____temp_2 = nil -- 1230
				else -- 1230
					____temp_2 = s.depth -- 1230
				end -- 1230
				local ____temp_8 = s.passable == true -- 1231
				local ____s_label_9 = s.label -- 1231
				local ____s_id_10 = s.id -- 1232
				local ____temp_11 = s.soft == true -- 1232
				local ____temp_12 = s.hidden == true -- 1232
				local ____temp_3 -- 1233
				if s.breakable == nil then -- 1233
					____temp_3 = nil -- 1233
				else -- 1233
					____temp_3 = __TS__ObjectAssign({}, s.breakable) -- 1233
				end -- 1233
				____self_boxes_13[#____self_boxes_13 + 1] = { -- 1228
					x0 = ____s_x_4, -- 1229
					x1 = ____temp_5, -- 1229
					y0 = ____s_y_6, -- 1229
					y1 = ____temp_7, -- 1229
					depth = ____temp_2, -- 1230
					passable = ____temp_8, -- 1231
					label = ____s_label_9, -- 1231
					id = ____s_id_10, -- 1232
					soft = ____temp_11, -- 1232
					hidden = ____temp_12, -- 1232
					breakable = ____temp_3, -- 1233
					interact = s.interact -- 1234
				} -- 1234
			end -- 1234
			i = i + 1 -- 1221
		end -- 1221
	end -- 1221
	do -- 1221
		i = 0 -- 1238
		while i < #room.stairs do -- 1238
			local st = room.stairs[i + 1] -- 1239
			local n = st.steps + 1 -- 1240
			local stepW = (st.x1 - st.x0) / n -- 1241
			local k = 0 -- 1242
			do -- 1242
				k = 0 -- 1243
				while k < n do -- 1243
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1244
					local x0 = st.x0 + stepW * k -- 1245
					local ____self_boxes_17 = self.boxes -- 1248
					local ____temp_15 = x0 + stepW -- 1249
					local ____temp_16 = -8 -- 1249
					local ____temp_14 -- 1250
					if room.depth == nil then -- 1250
						____temp_14 = nil -- 1250
					else -- 1250
						____temp_14 = st.depth -- 1250
					end -- 1250
					____self_boxes_17[#____self_boxes_17 + 1] = { -- 1248
						x0 = x0, -- 1249
						x1 = ____temp_15, -- 1249
						y0 = ____temp_16, -- 1249
						y1 = y, -- 1249
						depth = ____temp_14, -- 1250
						passable = true -- 1251
					} -- 1251
					k = k + 1 -- 1243
				end -- 1243
			end -- 1243
			i = i + 1 -- 1238
		end -- 1238
	end -- 1238
end -- 1212
function Play.prototype.setupCampaign(self) -- 1261
	local wr = self.room -- 1262
	local c = wr.campaign -- 1263
	if c == nil then -- 1263
		return -- 1265
	end -- 1265
	self.roomStartTick = self.run.ticks -- 1267
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1267
		self.run.joined = true -- 1271
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1271
		local ____self_run_19 = self.run -- 1274
		local ____temp_18 -- 1274
		if wr.key == "s2-drygoods" then -- 1274
			____temp_18 = self.run.route ~= "drygoods" -- 1274
		else -- 1274
			____temp_18 = false -- 1274
		end -- 1274
		____self_run_19.joined = ____temp_18 -- 1274
	end -- 1274
	local x = wr.minX + 60 -- 1276
	local y = 0 -- 1277
	local depth = 0 -- 1278
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1278
		x = wr.minX + 210 -- 1280
		depth = -32 -- 1281
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1281
		x = wr.minX + 40 -- 1283
		y = 32 -- 1284
		depth = 32 -- 1285
	end -- 1285
	self.player = { -- 1287
		x = x, -- 1288
		y = y, -- 1288
		depth = depth, -- 1288
		depthSpeed = 0, -- 1288
		vx = 0, -- 1288
		vy = 0, -- 1288
		w = SOLDIER_W, -- 1289
		h = SOLDIER_H, -- 1289
		onGround = y <= 0, -- 1289
		facing = 1, -- 1289
		crouch = false, -- 1289
		rollT = 0, -- 1289
		covered = false, -- 1289
		alive = true -- 1289
	} -- 1289
	self.partner = { -- 1291
		x = x + 60, -- 1292
		y = y, -- 1292
		depth = depth, -- 1292
		depthSpeed = 0, -- 1292
		vx = 0, -- 1292
		vy = 0, -- 1292
		w = CHILD_W, -- 1293
		h = CHILD_H, -- 1293
		onGround = y <= 0, -- 1293
		facing = 1, -- 1293
		crouch = false, -- 1293
		rollT = 0, -- 1293
		covered = false, -- 1293
		alive = true -- 1293
	} -- 1293
	self.cam.x = x -- 1295
	self.cam.y = y + CAM_LOOK_UP -- 1296
	self.phase = "run" -- 1297
	self.hp = self.maxHp -- 1298
	local trial = self.run.trial -- 1299
	if trial ~= nil then -- 1299
		draftRoom(trial, wr.key) -- 1301
		self.maxHp = self.maxHp + trial.ranks.vitality -- 1302
		self.hp = trial.hp -- 1303
	end -- 1303
	self:buildEnemies() -- 1305
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1306
	local i = 0 -- 1307
	do -- 1307
		i = 0 -- 1308
		while i < #self.boxes do -- 1308
			do -- 1308
				local b = self.boxes[i + 1] -- 1309
				if b.id == nil then -- 1309
					goto __continue117 -- 1311
				end -- 1311
				local st = self.run.props[b.id] -- 1313
				if st ~= nil then -- 1313
					b.broken = st.broken -- 1315
					local ____temp_20 -- 1316
					if b.breakable == nil then -- 1316
						____temp_20 = nil -- 1316
					else -- 1316
						____temp_20 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1316
					end -- 1316
					b.breakable = ____temp_20 -- 1316
					b.hidden = b.hidden == true and st.revealed ~= true -- 1317
					if b.hidden then -- 1317
						b.broken = true -- 1319
					end -- 1319
				elseif b.hidden == true then -- 1319
					b.broken = true -- 1323
				end -- 1323
			end -- 1323
			::__continue117:: -- 1323
			i = i + 1 -- 1308
		end -- 1308
	end -- 1308
	if wr.cart.bodyW > 0 then -- 1308
		self.cartAxle = wr.cart.startX -- 1327
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1327
			self.cartAxle = wr.cart.endX -- 1329
			self.cartDocked = true -- 1330
		end -- 1330
	end -- 1330
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1333
end -- 1261
function Play.prototype.log(self, line) -- 1336
	local ____self_run_log_21 = self.run.log -- 1336
	____self_run_log_21[#____self_run_log_21 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1337
	if #self.run.log > 120 then -- 1337
		table.remove(self.run.log, 1) -- 1339
	end -- 1339
end -- 1336
function Play.prototype.buildEnemies(self) -- 1343
	self.enemies = {} -- 1344
	if self.isCampaign then -- 1344
		local i = 0 -- 1346
		do -- 1346
			i = 0 -- 1347
			while i < #self.room.spawns do -- 1347
				local sp = self.room.spawns[i + 1] -- 1348
				local kind = sp.kind or "gunner" -- 1349
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1350
				local ____self_enemies_22 = self.enemies -- 1350
				____self_enemies_22[#____self_enemies_22 + 1] = { -- 1351
					x = sp.x, -- 1352
					y = sp.y, -- 1352
					depth = sp.depth, -- 1352
					w = 26, -- 1352
					h = sp.h, -- 1352
					alive = true, -- 1352
					hitT = 0, -- 1352
					warnT = 0, -- 1352
					fireCd = 40, -- 1352
					kind = kind, -- 1353
					shieldHp = hp, -- 1353
					shieldHpMax = hp, -- 1353
					drop = sp.drop or "none", -- 1353
					homeX = sp.x, -- 1354
					swingT = 0, -- 1354
					awake = false, -- 1354
					squad = i -- 1354
				} -- 1354
				i = i + 1 -- 1347
			end -- 1347
		end -- 1347
		return -- 1357
	end -- 1357
	if self.room.key == "checkpoint" then -- 1357
		local ____self_enemies_23 = self.enemies -- 1357
		____self_enemies_23[#____self_enemies_23 + 1] = { -- 1360
			x = self.ox + 430, -- 1360
			y = 0, -- 1360
			w = 26, -- 1360
			h = 84, -- 1360
			alive = true, -- 1360
			hitT = 0, -- 1360
			warnT = 0, -- 1360
			fireCd = 0 -- 1360
		} -- 1360
		local ____self_enemies_24 = self.enemies -- 1360
		____self_enemies_24[#____self_enemies_24 + 1] = { -- 1361
			x = self.ox + 505, -- 1361
			y = 0, -- 1361
			w = 26, -- 1361
			h = 84, -- 1361
			alive = true, -- 1361
			hitT = 0, -- 1361
			warnT = 0, -- 1361
			fireCd = 0 -- 1361
		} -- 1361
		return -- 1362
	end -- 1362
	if self.room.key == "street" then -- 1362
		local ____self_enemies_25 = self.enemies -- 1362
		____self_enemies_25[#____self_enemies_25 + 1] = { -- 1366
			x = self.ox + 340, -- 1366
			y = 0, -- 1366
			w = 26, -- 1366
			h = 84, -- 1366
			alive = true, -- 1366
			hitT = 0, -- 1366
			warnT = 0, -- 1366
			fireCd = 0 -- 1366
		} -- 1366
		local ____self_enemies_26 = self.enemies -- 1366
		____self_enemies_26[#____self_enemies_26 + 1] = { -- 1367
			x = self.ox + 560, -- 1367
			y = 0, -- 1367
			w = 26, -- 1367
			h = 84, -- 1367
			alive = true, -- 1367
			hitT = 0, -- 1367
			warnT = 0, -- 1367
			fireCd = 0 -- 1367
		} -- 1367
	end -- 1367
end -- 1343
function Play.prototype.emit(self, name, data) -- 1373
	local ____self_events_27 = self.events -- 1373
	____self_events_27[#____self_events_27 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1374
	self.eventSeq = self.eventSeq + 1 -- 1375
	if #self.events > 256 then -- 1375
		table.remove(self.events, 1) -- 1377
	end -- 1377
end -- 1373
function Play.prototype.drainEvents(self) -- 1385
	local out = self.events -- 1386
	self.events = {} -- 1387
	return out -- 1388
end -- 1385
function Play.prototype.adoptEvents(self, events) -- 1397
	if #events == 0 then -- 1397
		return -- 1399
	end -- 1399
	local keep = {} -- 1401
	local i = 0 -- 1402
	do -- 1402
		i = 0 -- 1403
		while i < #events do -- 1403
			do -- 1403
				local e = events[i + 1] -- 1404
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1404
					goto __continue138 -- 1406
				end -- 1406
				keep[#keep + 1] = e -- 1408
			end -- 1408
			::__continue138:: -- 1408
			i = i + 1 -- 1403
		end -- 1403
	end -- 1403
	if #keep == 0 then -- 1403
		return -- 1411
	end -- 1411
	self.events = __TS__ArrayConcat(keep, self.events) -- 1413
	do -- 1413
		i = 0 -- 1414
		while i < #self.events do -- 1414
			self.events[i + 1].seq = i -- 1415
			i = i + 1 -- 1414
		end -- 1414
	end -- 1414
	self.eventSeq = #self.events -- 1417
end -- 1397
function Play.prototype.chooseTalent(self, slot) -- 1420
	local trial = self.run.trial -- 1421
	local talent = trial and trial.offers[slot + 1] -- 1422
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 1422
		return -- 1423
	end -- 1423
	local ____trial_ranks_30, ____talent_31 = trial.ranks, talent -- 1423
	____trial_ranks_30[____talent_31] = ____trial_ranks_30[____talent_31] + 1 -- 1424
	trial.offers = {} -- 1425
	if talent == "vitality" then -- 1425
		self.maxHp = self.maxHp + 1 -- 1427
		self.hp = self.hp + 1 -- 1428
		trial.hp = self.hp -- 1429
	end -- 1429
	self:flashSet(talentNames[talent], 1.2) -- 1431
end -- 1420
function Play.prototype.beginReload(self) -- 1439
	self.reloadT = self:reloadTicks() -- 1440
	local camp = self.room.campaign -- 1441
	if self.run.trial == nil and camp ~= nil and camp.reloadPuzzle == true then -- 1441
		self:openReloadPuzzle() -- 1444
	end -- 1444
end -- 1439
function Play.prototype.openReloadPuzzle(self) -- 1449
	self.reloadOpen = true -- 1450
	self.reloadAnswerTicks = 0 -- 1451
	self.reloadWorldTicks = 0 -- 1452
	self.reloadPath = {RELOAD_START} -- 1453
	self.reloadPendingEffect = "" -- 1454
	self.reloadTryCount = self.reloadTryCount + 1 -- 1455
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 1456
end -- 1449
function Play.prototype.closeReloadPuzzle(self) -- 1460
	self.reloadOpen = false -- 1461
	self.reloadAnswerTicks = 0 -- 1462
	self.reloadWorldTicks = 0 -- 1463
	self.reloadPath = {RELOAD_START} -- 1464
	self.reloadPendingEffect = "" -- 1465
end -- 1460
function Play.prototype.reloadTapNode(self, node) -- 1472
	if not self.reloadOpen then -- 1472
		return -- 1474
	end -- 1474
	local path = self.reloadPath -- 1476
	local last = path[#path] -- 1477
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1477
		self.reloadPath = {RELOAD_START} -- 1479
		self:emit("reloadInvalid", {node = node, at = last}) -- 1480
		return -- 1481
	end -- 1481
	path[#path + 1] = node -- 1483
	if node ~= RELOAD_TARGET then -- 1483
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1485
		return -- 1486
	end -- 1486
	if not reloadPathValid(path) then -- 1486
		self.reloadPath = {RELOAD_START} -- 1489
		self:emit("reloadInvalid", {node = node, at = last}) -- 1490
		return -- 1491
	end -- 1491
	self.reloadPendingEffect = reloadEffectOf(path) -- 1493
	self.reloadOpen = false -- 1494
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1495
	self:flashSet( -- 1498
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1498
		1.4 -- 1498
	) -- 1498
end -- 1472
function Play.prototype.consumeReloadEffect(self) -- 1502
	local e = self.reloadPendingEffect -- 1503
	if e ~= "" then -- 1503
		self.reloadPendingEffect = "" -- 1505
	end -- 1505
	return e -- 1507
end -- 1502
function Play.prototype.echoToSource(self, from, count) -- 1514
	if count == nil then -- 1514
		count = 1 -- 1514
	end -- 1514
	local best = -1 -- 1515
	local bestD = 1000000000 -- 1516
	local i = 0 -- 1517
	local woken = {} -- 1518
	local n = 0 -- 1519
	while n < count do -- 1519
		best = -1 -- 1521
		bestD = 1000000000 -- 1522
		do -- 1522
			i = 0 -- 1523
			while i < #self.enemies do -- 1523
				do -- 1523
					if woken[i] == true then -- 1523
						goto __continue160 -- 1525
					end -- 1525
					local e = self.enemies[i + 1] -- 1527
					if not e.alive then -- 1527
						goto __continue160 -- 1529
					end -- 1529
					local d = math.abs(e.x - from.x) -- 1531
					if d < bestD then -- 1531
						bestD = d -- 1533
						best = i -- 1534
					end -- 1534
				end -- 1534
				::__continue160:: -- 1534
				i = i + 1 -- 1523
			end -- 1523
		end -- 1523
		if best < 0 then -- 1523
			break -- 1538
		end -- 1538
		woken[best] = true -- 1540
		local e = self.enemies[best + 1] -- 1541
		e.awake = true -- 1542
		e.warnT = 0 -- 1543
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1544
		n = n + 1 -- 1545
	end -- 1545
	if n == 0 then -- 1545
		return -- 1548
	end -- 1548
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1550
end -- 1514
function Play.prototype.reloadTicks(self) -- 1553
	local ____temp_34 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 1554
	local ____opt_32 = self.run.trial -- 1554
	return math.max(6, ____temp_34 - 6 * (____opt_32 and ____opt_32.ranks.reload or 0)) -- 1554
end -- 1553
function Play.prototype.update(self, dt, input) -- 1557
	self:syncCraftBench() -- 1558
	local trial = self.run.trial -- 1559
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1559
		return -- 1560
	end -- 1560
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1560
		self:closeCraftBench() -- 1562
		return -- 1563
	end -- 1563
	if input.pause.pressed then -- 1563
		self.paused = not self.paused -- 1566
	end -- 1566
	if self.flashT > 0 then -- 1566
		self.flashT = self.flashT - dt -- 1569
		if self.flashT <= 0 then -- 1569
			self.flash = "" -- 1571
		end -- 1571
	end -- 1571
	if self.traceT > 0 then -- 1571
		self.traceT = self.traceT - dt -- 1575
		if self.traceT <= 0 then -- 1575
			self.trace = nil -- 1577
		end -- 1577
	end -- 1577
	if self.paused then -- 1577
		self:updateCamera(dt) -- 1581
		return -- 1582
	end -- 1582
	if self.craftBench.active then -- 1582
		self:updateCamera(dt) -- 1587
		return -- 1588
	end -- 1588
	if self.reloadOpen then -- 1588
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1594
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1594
			self.reloadOpen = false -- 1596
			self.reloadPendingEffect = "" -- 1597
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1598
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1599
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1599
			self:updateCamera(dt) -- 1601
			return -- 1602
		else -- 1602
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1604
		end -- 1604
	end -- 1604
	self.ticks = self.ticks + 1 -- 1608
	if self.invulnT > 0 then -- 1608
		self.invulnT = self.invulnT - 1 -- 1612
	end -- 1612
	if self.isCampaign then -- 1612
		local ____self_run_35, ____ticks_36 = self.run, "ticks" -- 1612
		____self_run_35[____ticks_36] = ____self_run_35[____ticks_36] + 1 -- 1615
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1616
	end -- 1616
	local p = self.player -- 1618
	self:stepPlayer(p, dt, input) -- 1619
	self:refreshCover(p, input) -- 1621
	if self.carryOn then -- 1621
		self:carryPose() -- 1623
	end -- 1623
	if self.isCampaign then -- 1623
		self:stepCampaign(dt, input) -- 1626
		if not self.carryOn then -- 1626
			self:stepCampaignPartner(dt) -- 1628
		end -- 1628
	end -- 1628
	if trial == nil or not self.run.finished then -- 1628
		self:stepEnemies(dt, input) -- 1636
	end -- 1636
	if trial ~= nil then -- 1636
		trial.hp = self.hp -- 1638
	end -- 1638
	if not self.isCampaign then -- 1638
		self:stepStory(dt, input) -- 1640
		self:stepEscort(dt, input) -- 1641
		self:stepVillage(dt, input) -- 1642
		self:stepChase(dt, input) -- 1643
		self:stepInteract(dt, input) -- 1644
	end -- 1644
	self:updateGate() -- 1646
	self:updateCamera(dt) -- 1647
	self:syncStory() -- 1649
end -- 1557
function Play.prototype.underLowArch(self, a) -- 1656
	local arch = self.room.arch -- 1657
	if arch.h <= 0 then -- 1657
		return false -- 1659
	end -- 1659
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1659
		return false -- 1662
	end -- 1662
	local top = arch.y + arch.h -- 1664
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1665
end -- 1656
function Play.prototype.coverAt(self, a) -- 1672
	local best = nil -- 1673
	local bestGap = 24 -- 1674
	local half = a.w / 2 -- 1675
	local i = 0 -- 1676
	do -- 1676
		i = 0 -- 1677
		while i < #self.boxes do -- 1677
			do -- 1677
				local b = self.boxes[i + 1] -- 1678
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1678
					goto __continue194 -- 1680
				end -- 1680
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1680
					goto __continue194 -- 1683
				end -- 1683
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1685
				if gap < bestGap then -- 1685
					bestGap = gap -- 1687
					best = b -- 1688
				end -- 1688
			end -- 1688
			::__continue194:: -- 1688
			i = i + 1 -- 1677
		end -- 1677
	end -- 1677
	return best -- 1691
end -- 1672
function Play.prototype.nearCover(self, a) -- 1694
	return self:coverAt(a) ~= nil -- 1695
end -- 1694
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1699
	if enemy == nil then -- 1699
		return false -- 1701
	end -- 1701
	local fromRight = enemy.x >= a.x -- 1703
	local edge = fromRight and b.x0 or b.x1 -- 1704
	local ____fromRight_37 -- 1705
	if fromRight then -- 1705
		____fromRight_37 = edge >= a.x - 0.001 and edge <= enemy.x -- 1705
	else -- 1705
		____fromRight_37 = edge <= a.x + 0.001 and edge >= enemy.x -- 1706
	end -- 1706
	local between = ____fromRight_37 -- 1705
	local separation = enemy.x - a.x -- 1707
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1708
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1709
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1710
end -- 1699
function Play.prototype.nearestEnemy(self, a) -- 1713
	local best -- 1714
	local bestD = 1000000000 -- 1715
	local i = 0 -- 1716
	do -- 1716
		i = 0 -- 1717
		while i < #self.enemies do -- 1717
			do -- 1717
				local e = self.enemies[i + 1] -- 1718
				if not e.alive then -- 1718
					goto __continue203 -- 1720
				end -- 1720
				local d = math.abs(e.x - a.x) -- 1722
				if d < bestD then -- 1722
					bestD = d -- 1724
					best = e -- 1725
				end -- 1725
			end -- 1725
			::__continue203:: -- 1725
			i = i + 1 -- 1717
		end -- 1717
	end -- 1717
	return best -- 1728
end -- 1713
function Play.prototype.refreshCover(self, a, input) -- 1732
	if self.childMode then -- 1732
		self.coverNear = false -- 1734
		self.coverHug = false -- 1735
		self.coverEntity = "" -- 1736
		self.coverBlocking = false -- 1737
		a.covered = false -- 1738
		return -- 1739
	end -- 1739
	local b = self:coverAt(a) -- 1741
	self.coverNear = b ~= nil -- 1742
	a.covered = self.coverNear and input.cover.held -- 1743
	self.coverHug = a.covered -- 1744
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1745
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1746
		b, -- 1746
		a, -- 1746
		self:nearestEnemy(a) -- 1746
	) -- 1746
end -- 1732
function Play.prototype.cartHandleInReach(self, a) -- 1750
	if a == nil then -- 1750
		a = self.player -- 1750
	end -- 1750
	local c = self.room.cart -- 1751
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1751
		return false -- 1753
	end -- 1753
	local handleX = self.cartAxle + c.handleOffset -- 1755
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1756
end -- 1750
function Play.prototype.nearLowLedge(self, a) -- 1761
	local reach = 26 -- 1762
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1763
	local x1 = x0 + reach -- 1764
	local i = 0 -- 1765
	do -- 1765
		i = 0 -- 1766
		while i < #self.boxes do -- 1766
			do -- 1766
				local b = self.boxes[i + 1] -- 1767
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1767
					goto __continue212 -- 1769
				end -- 1769
				local rise = b.y1 - a.y -- 1771
				if rise > 0 and rise <= LEDGE_RISE then -- 1771
					return true -- 1773
				end -- 1773
			end -- 1773
			::__continue212:: -- 1773
			i = i + 1 -- 1766
		end -- 1766
	end -- 1766
	return false -- 1776
end -- 1761
function Play.prototype.stepPlayer(self, a, dt, input) -- 1779
	a.depthSpeed = 0 -- 1780
	if not a.alive then -- 1780
		return -- 1782
	end -- 1782
	local isChild = self.childMode -- 1784
	local lowArch = isChild and self:underLowArch(a) -- 1786
	if self:storyLocked() then -- 1786
		a.vx = 0 -- 1789
		a.crouch = isChild and lowArch -- 1790
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1791
		self:fallY(a, dt) -- 1792
		return -- 1793
	end -- 1793
	if not isChild and self.escort.state == "calming" then -- 1793
		a.crouch = false -- 1797
		a.h = SOLDIER_H -- 1798
		a.vx = 0 -- 1799
		self:fallY(a, dt) -- 1800
		return -- 1801
	end -- 1801
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 1803
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 1804
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1805
	local nearCover = not isChild and self:nearCover(a) -- 1806
	a.covered = nearCover and input.cover.held -- 1807
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1809
	if a.rollT > 0 then -- 1809
		a.rollT = a.rollT - dt -- 1813
		a.vx = a.facing * ROLL_SPEED -- 1814
		self:slideX(a, a.vx * dt) -- 1815
		self:fallY(a, dt) -- 1816
		if a.rollT <= 0 then -- 1816
			self:flashSet("翻滚结束", 0.5) -- 1818
		end -- 1818
		return -- 1820
	end -- 1820
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1820
		if input.moveX ~= 0 then -- 1820
			a.facing = input.moveX > 0 and 1 or -1 -- 1825
		end -- 1825
		if self:nearLowLedge(a) then -- 1825
			a.vy = SOLDIER_JUMP -- 1829
			a.onGround = false -- 1830
			self:flashSet("翻上去", 0.3) -- 1831
			return -- 1832
		end -- 1832
		a.rollT = ROLL_TIME -- 1834
		self:flashSet("翻滚", 0.3) -- 1835
		return -- 1836
	end -- 1836
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1839
	if isChild then -- 1839
		if input.cover.held then -- 1839
			speed = CHILD_SLOW -- 1842
		end -- 1842
		if a.crouch then -- 1842
			speed = CHILD_SLOW -- 1845
		end -- 1845
	elseif a.covered then -- 1845
		speed = SOLDIER_SPEED * 0.45 -- 1848
	end -- 1848
	local handsBusy = self.gripping or gripIntent -- 1852
	local dir = self.gripping and 0 or input.moveX -- 1853
	local depthDir = self.room.depth ~= nil and not handsBusy and (not isChild or self.phase == "prologue-escape") and -input.moveY or 0 -- 1855
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1857
	if dir ~= 0 then -- 1857
		a.facing = dir > 0 and 1 or -1 -- 1859
	end -- 1859
	a.vx = dir * speed * diagonal -- 1861
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1861
		a.vy = CHILD_JUMP -- 1865
		a.onGround = false -- 1866
		self:flashSet("跳", 0.25) -- 1867
	end -- 1867
	local previousDepth = a.depth -- 1871
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1872
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1873
	self:slideX(a, a.vx * dt) -- 1874
	self:fallY(a, dt) -- 1875
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1875
		self:shoot(a) -- 1879
	end -- 1879
end -- 1779
function Play.prototype.stepPartner(self, p, dt) -- 1884
	local a = self.partner -- 1885
	if not a.alive then -- 1885
		return -- 1887
	end -- 1887
	a.crouch = false -- 1889
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1890
	a.vx = 0 -- 1891
	a.depthSpeed = 0 -- 1892
	self:fallY(a, dt) -- 1893
end -- 1884
function Play.prototype.stepEscort(self, dt, input) -- 1900
	local a = self.partner -- 1901
	a.depthSpeed = 0 -- 1902
	if not a.alive then -- 1902
		return -- 1904
	end -- 1904
	if self.room.key == "gatepath" then -- 1904
		if self.carryOn then -- 1904
			return -- 1909
		end -- 1909
		local p = self.player -- 1912
		a.depth = p.depth -- 1913
		a.facing = p.facing -- 1914
		a.crouch = false -- 1915
		a.h = CHILD_H -- 1916
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 1917
		a.y = p.y -- 1918
		a.vy = 0 -- 1919
		a.vx = p.vx -- 1920
		a.onGround = p.onGround -- 1921
		return -- 1922
	end -- 1922
	if not self:escortOn() then -- 1922
		a.vx = 0 -- 1925
		self:fallY(a, dt) -- 1926
		return -- 1927
	end -- 1927
	local p = self.player -- 1929
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1930
	local hadKnock1 = self.escort.knock1 -- 1931
	local hadKnock2 = self.escort.knock2 -- 1932
	self.calmConsumed = self.escort:update( -- 1933
		input, -- 1933
		p.x, -- 1933
		p.facing, -- 1933
		a.x, -- 1933
		dist -- 1933
	) -- 1933
	if not hadKnock1 and self.escort.knock1 then -- 1933
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1936
	end -- 1936
	if not hadKnock2 and self.escort.knock2 then -- 1936
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1939
	end -- 1939
	a.crouch = self.escort.crouchPose -- 1941
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1942
	if not self.escort.stopped then -- 1942
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1944
		local previousDepth = a.depth -- 1945
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1946
		local distance = math.max( -- 1947
			-travel, -- 1947
			math.min(travel, targetDepth - previousDepth) -- 1947
		) -- 1947
		self:slideDepth(a, distance) -- 1948
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1949
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1949
			a.vy = CHILD_JUMP -- 1951
			a.onGround = false -- 1952
		end -- 1952
	end -- 1952
	local dir = self.escort:moveDir(a.x) -- 1955
	a.vx = dir * CHILD_SPEED -- 1956
	if dir ~= 0 then -- 1956
		a.facing = dir -- 1958
		local before = a.x -- 1959
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1960
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1960
			a.vy = CHILD_JUMP -- 1963
			a.onGround = false -- 1964
		end -- 1964
	end -- 1964
	self:fallY(a, dt) -- 1967
end -- 1900
function Play.prototype.escortOn(self) -- 1971
	if self.room.key == "checkpoint" then -- 1971
		return true -- 1973
	end -- 1973
	if self.room.key == "gatepath" then -- 1973
		return true -- 1976
	end -- 1976
	if self.room.key == "prologue" then -- 1976
		return self.phase == "prologue-follow" -- 1979
	end -- 1979
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 1979
		return true -- 1983
	end -- 1983
	return self.room.key == "street" -- 1985
end -- 1971
function Play.prototype.storyLocked(self) -- 1989
	if self.caughtT > 0 then -- 1989
		return true -- 1991
	end -- 1991
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 1991
		return true -- 1995
	end -- 1995
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1995
		return true -- 1998
	end -- 1998
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 1998
		return true -- 2001
	end -- 2001
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2001
		return true -- 2004
	end -- 2004
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2004
		return true -- 2007
	end -- 2007
	if self.craftBench.active then -- 2007
		return true -- 2011
	end -- 2011
	return false -- 2013
end -- 1989
function Play.prototype.swapToChild(self, x) -- 2017
	local tmp = self.player -- 2018
	self.player = self.partner -- 2019
	self.partner = tmp -- 2020
	self.childMode = true -- 2021
	self.player.alive = true -- 2022
	self.player.x = self.ox + x -- 2023
	self.player.y = 0 -- 2024
	self.player.depth = 0 -- 2025
	self.player.depthSpeed = 0 -- 2026
	self.player.vy = 0 -- 2027
	self.player.vx = 0 -- 2028
	self.player.onGround = true -- 2029
	self.player.crouch = false -- 2030
	self.player.h = CHILD_H -- 2031
	self.player.facing = 1 -- 2032
	self.partner.alive = true -- 2033
	self.cam.x = self.player.x -- 2034
end -- 2017
function Play.prototype.swapToSoldier(self, x, childX) -- 2038
	local tmp = self.player -- 2039
	self.player = self.partner -- 2040
	self.partner = tmp -- 2041
	self.childMode = false -- 2042
	self.player.alive = true -- 2043
	self.player.x = self.ox + x -- 2044
	self.player.y = 0 -- 2045
	self.player.depth = 0 -- 2046
	self.player.depthSpeed = 0 -- 2047
	self.player.vy = 0 -- 2048
	self.player.vx = 0 -- 2049
	self.player.onGround = true -- 2050
	self.player.crouch = false -- 2051
	self.player.h = SOLDIER_H -- 2052
	self.player.facing = 1 -- 2053
	self.partner.alive = true -- 2054
	self.partner.x = self.ox + childX -- 2055
	self.partner.y = 0 -- 2056
	self.partner.depth = 0 -- 2057
	self.partner.depthSpeed = 0 -- 2058
	self.partner.vx = 0 -- 2059
	self.partner.vy = 0 -- 2060
	self.partner.onGround = true -- 2061
	self.partner.crouch = true -- 2062
	self.partner.h = CHILD_CROUCH_H -- 2063
	self.cam.x = self.player.x -- 2064
end -- 2038
function Play.prototype.stepStory(self, dt, input) -- 2068
	if self.room.key == "prologue" then -- 2068
		self:stepPrologue(dt, input) -- 2070
	elseif self.room.key == "street" then -- 2070
		self:stepStreet(dt, input) -- 2072
	elseif self.room.key == "gate" then -- 2072
		self:stepGate(dt, input) -- 2074
	elseif self.room.key == "gatepath" then -- 2074
		self:stepGatePath() -- 2076
	elseif self.room.key == "tower" then -- 2076
		self:stepTower(dt, input) -- 2078
	elseif self.room.key == "museum" then -- 2078
		self:stepMuseum(dt, input) -- 2080
	end -- 2080
end -- 2068
function Play.prototype.canPersistProgress(self) -- 2086
	return not self.isCampaign and self.run.source == "official" -- 2087
end -- 2086
function Play.prototype.wellWindow(self) -- 2091
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 2092
end -- 2091
function Play.prototype.nearWell(self) -- 2097
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 2098
end -- 2097
function Play.prototype.pickWell(self) -- 2106
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2106
		return false -- 2108
	end -- 2108
	self.phase = "prologue-well" -- 2110
	self.phaseTick = 0 -- 2111
	self.wellOpen = false -- 2112
	self:flashSet("井沿 · 伸手下去", 1.4) -- 2113
	self:log("旧井拾取") -- 2114
	return true -- 2115
end -- 2106
function Play.prototype.stepPrologue(self, dt, input) -- 2118
	local child = self.partner -- 2119
	if self.museumReturn then -- 2119
		self.museumReturn = false -- 2122
		self.phase = "prologue-wait" -- 2123
		self.phaseTick = 0 -- 2124
		self.player.x = self.ox + 260 -- 2125
		self.player.y = 0 -- 2126
		self.player.depth = 0 -- 2127
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2128
	end -- 2128
	if self.phase == "prologue-wake" then -- 2128
		self.introTick = self.introTick + 1 -- 2132
		if self.introTick == 60 then -- 2132
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2134
		end -- 2134
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2134
			self.phase = "prologue-shadow" -- 2137
			self.introTick = 0 -- 2138
			self:flashSet("门缝里两道影子", 1.2) -- 2139
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2140
		end -- 2140
		return -- 2142
	end -- 2142
	if self.phase == "prologue-shadow" then -- 2142
		self.introTick = self.introTick + 1 -- 2145
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2145
			self.phase = "prologue-escape" -- 2148
			self.introTick = 0 -- 2149
			self.escapeRemaining = self.escapeDuration -- 2150
			self.escapeRetryCount = 0 -- 2151
			self:swapToChild(100) -- 2152
			self:flashSet( -- 2153
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2153
				1.6 -- 2153
			) -- 2153
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2154
		end -- 2154
		return -- 2158
	end -- 2158
	if self.phase == "prologue-escape" then -- 2158
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2161
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2161
			self.phase = "prologue-hide" -- 2164
			self.introTick = 0 -- 2165
			self.player.vx = 0 -- 2166
			self.player.crouch = true -- 2167
			self.player.h = CHILD_CROUCH_H -- 2168
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2169
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2170
			return -- 2174
		end -- 2174
		if self.escapeRemaining <= 0 then -- 2174
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2178
			self.player.x = self.ox + 100 -- 2179
			self.player.y = 0 -- 2180
			self.player.depth = 0 -- 2181
			self.player.vx = 0 -- 2182
			self.player.vy = 0 -- 2183
			self.escapeRemaining = self.escapeDuration -- 2184
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2185
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2186
			return -- 2187
		end -- 2187
		return -- 2189
	end -- 2189
	if self.phase == "prologue-hide" then -- 2189
		self.introTick = self.introTick + 1 -- 2192
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2192
			self.phase = "prologue-wait" -- 2195
			self.phaseTick = 0 -- 2196
			self.introTick = 0 -- 2197
			self:swapToSoldier(260, 300) -- 2198
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2199
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2200
		end -- 2200
		return -- 2202
	end -- 2202
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2205
	if self.phase == "prologue-wait" then -- 2205
		child.crouch = true -- 2207
		child.h = CHILD_CROUCH_H -- 2208
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2208
			self:pickWell() -- 2210
			return -- 2211
		end -- 2211
		if not self.wellOpen and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2211
			if self:canPersistProgress() then -- 2211
				self.archive.museumPhase = "well_reflect" -- 2217
				self.archiveDirty = true -- 2218
			end -- 2218
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2220
			return -- 2221
		end -- 2221
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2223
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2225
		if near and input.interact.pressed then -- 2225
			self.phase = "prologue-give" -- 2227
			self.phaseTick = 0 -- 2228
			self:flashSet("递出针套", 1) -- 2229
		end -- 2229
		return -- 2231
	end -- 2231
	if self.phase == "prologue-well" then -- 2231
		self.phaseTick = self.phaseTick + 1 -- 2235
		if self.phaseTick == 12 then -- 2235
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2237
		elseif self.phaseTick >= 30 then -- 2237
			self.phase = "prologue-wait" -- 2239
			self.phaseTick = 0 -- 2240
			self.wellTaken = true -- 2241
			self.wellOpen = false -- 2242
			self.run.archive.artifactOwned = true -- 2243
			self.archiveDirty = true -- 2244
			self:emit("artifactFound", { -- 2245
				x = self.ox + self.wellX, -- 2246
				y = 0, -- 2246
				room = "prologue", -- 2246
				once = true, -- 2246
				source = self.run.source -- 2247
			}) -- 2247
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2249
			self:log("井底取到时间穿梭器") -- 2250
		end -- 2250
		return -- 2252
	end -- 2252
	if self.phase == "prologue-give" then -- 2252
		self.phaseTick = self.phaseTick + 1 -- 2255
		if self.phaseTick == 12 then -- 2255
			self:flashSet("针套递过去", 0.7) -- 2257
		elseif self.phaseTick == 36 then -- 2257
			self:flashSet("纸条塞进针套", 0.9) -- 2259
		elseif self.phaseTick >= 60 then -- 2259
			self.phase = "prologue-follow" -- 2261
			self.phaseTick = 0 -- 2262
			child.crouch = false -- 2263
			child.h = CHILD_H -- 2264
			self:flashSet("她跟上了", 1.2) -- 2265
		end -- 2265
		return -- 2267
	end -- 2267
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2267
		self:requestRoom("street", "序章跟到门口") -- 2271
		self:flashSet("进街道", 1.2) -- 2272
	end -- 2272
end -- 2118
function Play.prototype.stepStreet(self, dt, input) -- 2277
	local p = self.player -- 2278
	local c = self.partner -- 2279
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2279
		self:requestRoom("checkpoint", "两人都到街尾") -- 2281
		self:flashSet("到检查站", 1.2) -- 2282
	end -- 2282
end -- 2277
function Play.prototype.stepGate(self, dt, input) -- 2287
	local ____temp_38 -- 2288
	if self.room.story == nil then -- 2288
		____temp_38 = nil -- 2288
	else -- 2288
		____temp_38 = self.room.story.gate -- 2288
	end -- 2288
	local g = ____temp_38 -- 2288
	if g == nil then -- 2288
		return -- 2290
	end -- 2290
	local p = self.player -- 2292
	if self.phase == "gate-idle" then -- 2292
		local a = self.partner -- 2295
		local gap = g.waitX - a.x -- 2296
		if math.abs(gap) > 3 then -- 2296
			a.facing = gap > 0 and 1 or -1 -- 2298
			a.vx = a.facing * CHILD_SPEED -- 2299
			local beforeX = a.x -- 2300
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2301
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2301
				a.vy = CHILD_JUMP -- 2303
				a.onGround = false -- 2304
			end -- 2304
			self:fallY(a, dt) -- 2306
		else -- 2306
			a.vx = 0 -- 2308
			a.x = g.waitX -- 2309
		end -- 2309
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2312
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2313
		if self.gateNeedConfirm then -- 2313
			if not input.interact.held then -- 2313
				self.gateRestartArmed = true -- 2318
			end -- 2318
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2318
				self.gateNeedConfirm = false -- 2321
				self.gateRestartArmed = true -- 2322
				self.phase = "gate-hold" -- 2323
				self.gateTick = 0 -- 2324
				self.gateSpawned = 0 -- 2325
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2326
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2327
			end -- 2327
			return -- 2329
		end -- 2329
		if atWinch and atWait then -- 2329
			self.phase = "gate-hold" -- 2332
			self.gateTick = 0 -- 2333
			self.gateSpawned = 0 -- 2334
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2335
		end -- 2335
		return -- 2337
	end -- 2337
	if self.phase == "gate-hold" then -- 2337
		self.gateTick = self.gateTick + 1 -- 2340
		local marks = {0, 540, 900, 1500} -- 2342
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2342
			local idx = self.gateSpawned -- 2344
			local ____self_enemies_39 = self.enemies -- 2344
			____self_enemies_39[#____self_enemies_39 + 1] = { -- 2345
				x = self.ox + 620 + idx * 62, -- 2346
				y = 0, -- 2346
				w = 26, -- 2346
				h = 84, -- 2346
				alive = true, -- 2347
				hitT = 0, -- 2347
				warnT = 0, -- 2347
				fireCd = 90 + idx * 45 -- 2347
			} -- 2347
			self.gateSpawned = self.gateSpawned + 1 -- 2349
			self:flashSet( -- 2350
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2350
				0.9 -- 2350
			) -- 2350
		end -- 2350
		if self.gateTick == 900 then -- 2350
			self:flashSet("灯灭了", 1) -- 2353
		elseif self.gateTick == 2100 then -- 2353
			self:flashSet("门底压下来了", 1) -- 2355
		end -- 2355
		if self.gateTick >= g.holdTicks then -- 2355
			self:captureGateBlood() -- 2360
			self.phase = "gate-send" -- 2361
			self.phaseTick = 0 -- 2362
			self.enemies = {} -- 2364
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2365
		end -- 2365
		return -- 2367
	end -- 2367
	if self.phase == "gate-send" then -- 2367
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2370
		if near and input.interact.pressed then -- 2370
			self:commitRoute() -- 2373
			self:swapToChild(g.doorX + 30) -- 2374
			self.phase = "gate-count" -- 2375
			self.countTick = 0 -- 2376
			self.countArmed = false -- 2378
			self.countPrevMove = input.moveX -- 2379
			self:flashSet("门开了 · 送她出去", 1.8) -- 2380
		end -- 2380
		return -- 2382
	end -- 2382
	if self.phase == "gate-count" then -- 2382
		self.countTick = self.countTick + 1 -- 2385
		if self.countTick == 360 then -- 2385
			self:flashSet("门关上", 0.9) -- 2387
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2387
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2389
			if self.storyRoute == "soldier" then -- 2389
				self.phase = "gate-wait" -- 2395
				self.phaseTick = 0 -- 2396
				self.knocks = 1 -- 2397
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2398
				self.handArmed = not input.interact.held -- 2400
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2401
			else -- 2401
				self:flashSet("数到二十", 2.2) -- 2403
			end -- 2403
		end -- 2403
		local prevMove = self.countPrevMove -- 2408
		self.countPrevMove = input.moveX -- 2409
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2409
			if prevMove <= 0 and input.moveX > 0 then -- 2409
				self.countArmed = true -- 2412
			end -- 2412
			if self.countArmed and input.moveX > 0 then -- 2412
				self.phase = "gate-walk" -- 2415
				self.phaseTick = 0 -- 2416
				self:flashSet("她迈出第一步", 1.4) -- 2417
				self:emit("storyExit", { -- 2418
					route = "child", -- 2418
					via = "walk", -- 2418
					countTick = self.countTick, -- 2418
					hp = self.hp, -- 2418
					maxHp = self.maxHp -- 2418
				}) -- 2418
			end -- 2418
		end -- 2418
		return -- 2421
	end -- 2421
	if self.phase == "gate-wait" then -- 2421
		self.phaseTick = self.phaseTick + 1 -- 2425
		if self.phaseTick == 12 then -- 2425
			self.knocks = 2 -- 2427
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2428
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2429
		end -- 2429
		if not input.interact.held then -- 2429
			if self.handTicks > 0 then -- 2429
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2433
			end -- 2433
			self.handTicks = 0 -- 2435
			self.handArmed = true -- 2436
			return -- 2437
		end -- 2437
		if self.handArmed then -- 2437
			self.handTicks = self.handTicks + 1 -- 2440
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2440
				self.phase = "gate-hand" -- 2442
				self.phaseTick = 0 -- 2443
				self.handDone = true -- 2444
				self.tied = true -- 2445
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2446
				if not self.lineSaid then -- 2446
					self.lineSaid = true -- 2448
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2449
				end -- 2449
				self:flashSet("我们走吧。", 3) -- 2451
			end -- 2451
		end -- 2451
		return -- 2454
	end -- 2454
	if self.phase == "gate-hand" then -- 2454
		self.phaseTick = self.phaseTick + 1 -- 2458
		if self.phaseTick == 30 then -- 2458
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2460
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2460
			self:emit("storyExit", { -- 2462
				route = "soldier", -- 2462
				via = "hand", -- 2462
				handTicks = self.handTicks, -- 2462
				hp = self.hp, -- 2462
				maxHp = self.maxHp -- 2462
			}) -- 2462
			self:requestRoom("gatepath", "牵手同行") -- 2463
		end -- 2463
		return -- 2465
	end -- 2465
	if self.phase == "gate-walk" then -- 2465
		if self.player.x >= g.exitX then -- 2465
			self:requestRoom("outside", "走出城门") -- 2470
			self:flashSet("出城门 · 城外", 1.4) -- 2471
		end -- 2471
	end -- 2471
end -- 2287
function Play.prototype.captureGateBlood(self) -- 2480
	self.hpAtGate = self.hp -- 2481
	self.maxHpAtGate = self.maxHp -- 2482
end -- 2480
function Play.prototype.commitRoute(self) -- 2489
	if self.storySettled then -- 2489
		return -- 2491
	end -- 2491
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2493
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2494
	self.hpAtGate = hp -- 2495
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2496
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2497
	self.storySettled = true -- 2498
	self:emit("storyRouteLocked", { -- 2499
		route = self.storyRoute, -- 2500
		hp = self.hp, -- 2500
		maxHp = self.maxHp, -- 2500
		hpAtGate = self.hpAtGate, -- 2501
		maxHpAtGate = self.maxHpAtGate -- 2501
	}) -- 2501
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2503
end -- 2489
function Play.prototype.syncStory(self) -- 2507
	if self.isCampaign and self.run.trial ~= nil then -- 2507
		return -- 2509
	end -- 2509
	local s = self.run.story -- 2511
	if s == nil then -- 2511
		return -- 2513
	end -- 2513
	s.hp = self.hp -- 2515
	s.maxHp = self.maxHp -- 2516
	s.route = self.storyRoute -- 2517
	s.settled = self.storySettled -- 2518
	s.hpAtGate = self.hpAtGate -- 2519
	s.maxHpAtGate = self.maxHpAtGate -- 2520
	s.handDone = self.handDone -- 2521
	s.lineSaid = self.lineSaid -- 2522
	s.tied = self.tied -- 2523
	s.carry = self.carryOn -- 2524
	s.museumReturn = self.museumReturn -- 2525
	s.escortDone = self.escortDone -- 2526
	s.craftedWeapon = self.run.story.craftedWeapon -- 2527
	s.ending = self.run.story.ending -- 2528
	if self.room.key == "gate" then -- 2528
		s.phase = self.phase -- 2530
		s.countTick = self.countTick -- 2531
		s.phaseTick = self.phaseTick -- 2532
		s.handTicks = self.handTicks -- 2533
	end -- 2533
	if self.room.key == "prologue" then -- 2533
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2533
			s.phase = self.phase -- 2538
			s.phaseTick = self.phaseTick -- 2539
		end -- 2539
	end -- 2539
	if self.room.key == "tower" then -- 2539
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2539
			s.phase = self.phase -- 2545
			s.phaseTick = self.phaseTick -- 2546
		end -- 2546
	end -- 2546
end -- 2507
function Play.prototype.stepGatePath(self) -- 2552
	local ____temp_40 -- 2553
	if self.room.story == nil then -- 2553
		____temp_40 = nil -- 2553
	else -- 2553
		____temp_40 = self.room.story.gatepath -- 2553
	end -- 2553
	local gp = ____temp_40 -- 2553
	if self.phase == "gatepath-start" then -- 2553
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2553
			self.carryOn = true -- 2556
			self.phase = "gatepath-carry" -- 2557
			self.phaseTick = 0 -- 2558
			self.pathDone = true -- 2559
			self.escortDone = false -- 2560
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2561
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2562
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2563
		end -- 2563
		return -- 2565
	end -- 2565
	if self.phase == "gatepath-carry" then -- 2565
		self.phaseTick = self.phaseTick + 1 -- 2568
		if self.phaseTick == 20 then -- 2568
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2570
		end -- 2570
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2570
			self:requestRoom(gp.next, "背负进首战") -- 2573
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2574
		end -- 2574
	end -- 2574
end -- 2552
function Play.prototype.carryPose(self) -- 2583
	local p = self.player -- 2584
	local a = self.partner -- 2585
	a.alive = true -- 2586
	a.x = p.x - p.facing * 12 -- 2587
	a.y = p.y + 26 -- 2588
	a.depth = p.depth -- 2589
	a.vx = p.vx -- 2590
	a.vy = 0 -- 2591
	a.onGround = true -- 2592
	a.crouch = false -- 2593
	a.h = CHILD_CROUCH_H -- 2594
	a.facing = p.facing -- 2595
end -- 2583
function Play.prototype.stepMuseum(self, dt, input) -- 2603
	self.partner.alive = false -- 2604
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2605
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2608
	if self.phase == "museum-cabinet" then -- 2608
		if atCase and input.interact.pressed then -- 2608
			self.phase = "museum-hall" -- 2611
			self.phaseTick = 0 -- 2612
			if self:canPersistProgress() then -- 2612
				self.archive.museumPhase = "hall_walk" -- 2614
				self.archiveDirty = true -- 2615
			end -- 2615
			self:emit( -- 2617
				"museumStep", -- 2617
				{ -- 2617
					step = "cabinet", -- 2617
					x = self.ox + mu.cabinetX, -- 2617
					persisted = self:canPersistProgress() -- 2617
				} -- 2617
			) -- 2617
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2618
		end -- 2618
		return -- 2620
	end -- 2620
	if self.phase == "museum-hall" then -- 2620
		if self.player.x >= self.ox + mu.hallX and input.interact.pressed then -- 2620
			self.phase = "museum-lamp" -- 2624
			self.phaseTick = 0 -- 2625
			if self:canPersistProgress() then -- 2625
				self.archive.museumPhase = "lamp_turn" -- 2627
				self.archiveDirty = true -- 2628
			end -- 2628
			self:emit( -- 2630
				"museumStep", -- 2630
				{ -- 2630
					step = "hall", -- 2630
					x = self.ox + mu.hallX, -- 2630
					persisted = self:canPersistProgress() -- 2630
				} -- 2630
			) -- 2630
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2631
		end -- 2631
		return -- 2633
	end -- 2633
	if self.phase == "museum-lamp" then -- 2633
		if self.player.x >= self.ox + mu.lampX and input.interact.pressed then -- 2633
			self.phase = "museum-return" -- 2637
			self.phaseTick = 0 -- 2638
			if self:canPersistProgress() then -- 2638
				self.archive.museumPhase = "return_cabinet" -- 2640
				self.archiveDirty = true -- 2641
			end -- 2641
			self:emit( -- 2643
				"museumStep", -- 2643
				{ -- 2643
					step = "lamp", -- 2643
					x = self.ox + mu.lampX, -- 2643
					persisted = self:canPersistProgress() -- 2643
				} -- 2643
			) -- 2643
			self:flashSet("灯 · 转向西窗", 1.8) -- 2644
		end -- 2644
		return -- 2646
	end -- 2646
	if self.phase == "museum-return" then -- 2646
		if atCase and input.interact.pressed then -- 2646
			self.phase = "museum-knock" -- 2650
			self.phaseTick = 0 -- 2651
			self:emit( -- 2652
				"museumStep", -- 2652
				{ -- 2652
					step = "knock", -- 2652
					count = 1, -- 2652
					x = self.ox + mu.cabinetX, -- 2652
					persisted = self:canPersistProgress() -- 2652
				} -- 2652
			) -- 2652
			self:flashSet("回柜边 · 第一下", 0.8) -- 2653
		end -- 2653
		return -- 2655
	end -- 2655
	if self.phase == "museum-knock" then -- 2655
		self.phaseTick = self.phaseTick + 1 -- 2658
		if self.phaseTick == 8 then -- 2658
			self:emit( -- 2660
				"museumStep", -- 2660
				{ -- 2660
					step = "knock", -- 2660
					count = 2, -- 2660
					x = self.ox + mu.cabinetX, -- 2660
					persisted = self:canPersistProgress() -- 2660
				} -- 2660
			) -- 2660
			self:flashSet("回柜边 · 第二下", 0.8) -- 2661
		elseif self.phaseTick >= 36 then -- 2661
			self.phase = "museum-done" -- 2663
			self.phaseTick = 0 -- 2664
			if self:canPersistProgress() then -- 2664
				self.archive.museumSeen = true -- 2666
				self.archive.museumPhase = "done" -- 2667
				self.archiveDirty = true -- 2668
			end -- 2668
			self:emit( -- 2670
				"museumDone", -- 2670
				{ -- 2670
					steps = 4, -- 2670
					museumSeen = self.archive.museumSeen, -- 2670
					persisted = self:canPersistProgress() -- 2670
				} -- 2670
			) -- 2670
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2671
			self:log("博物馆 · 回柜边") -- 2672
		end -- 2672
		return -- 2674
	end -- 2674
	if input.interact.pressed then -- 2674
		self.museumReturn = true -- 2677
		self:requestRoom("prologue", "回柜边") -- 2678
	end -- 2678
end -- 2603
function Play.prototype.openTowerDoor(self) -- 2682
	self.towerDoorOpen = true -- 2683
	do -- 2683
		local i = 0 -- 2684
		while i < #self.boxes do -- 2684
			if self.boxes[i + 1].id == "tower_door" then -- 2684
				self.boxes[i + 1].hidden = true -- 2686
			end -- 2686
			i = i + 1 -- 2684
		end -- 2684
	end -- 2684
	self.run.story.segments.tower_door = true -- 2689
end -- 2682
function Play.prototype.stepTower(self, dt, input) -- 2692
	local ____temp_41 -- 2693
	if self.room.story == nil then -- 2693
		____temp_41 = nil -- 2693
	else -- 2693
		____temp_41 = self.room.story.tower -- 2693
	end -- 2693
	local t = ____temp_41 -- 2693
	if t == nil then -- 2693
		return -- 2695
	end -- 2695
	if self.storyRoute == "soldier" and self.partner.alive then -- 2695
		local targetX = math.max(self.room.minX + 40, self.player.x - 36) -- 2699
		local gap = targetX - self.partner.x -- 2700
		if math.abs(gap) > 2 then -- 2700
			local dir = gap > 0 and 1 or -1 -- 2702
			local stepDist = math.min( -- 2703
				math.abs(gap), -- 2703
				SOLDIER_SPEED * dt -- 2703
			) -- 2703
			self.partner.facing = dir -- 2704
			self.partner.vx = dir * SOLDIER_SPEED -- 2705
			local ____self_partner_42, ____x_43 = self.partner, "x" -- 2705
			____self_partner_42[____x_43] = ____self_partner_42[____x_43] + dir * stepDist -- 2706
		else -- 2706
			self.partner.vx = 0 -- 2708
			self.partner.facing = 1 -- 2709
		end -- 2709
	end -- 2709
	if self.phase == "tower-wait" then -- 2709
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2713
		if near and input.interact.pressed then -- 2713
			self.phase = "tower-knock" -- 2715
			self.phaseTick = 0 -- 2716
			self.knocks = 1 -- 2717
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2718
			self:flashSet("叩两下 · 第一声", 0.6) -- 2719
		end -- 2719
		return -- 2721
	end -- 2721
	if self.phase == "tower-knock" then -- 2721
		self.phaseTick = self.phaseTick + 1 -- 2724
		if self.phaseTick == 12 then -- 2724
			self.knocks = 2 -- 2726
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2727
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 2728
		elseif self.phaseTick >= t.knockTicks then -- 2728
			self:openTowerDoor() -- 2730
			self.phase = "tower-enter" -- 2731
			self.phaseTick = 0 -- 2732
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 2733
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 2734
		end -- 2734
		return -- 2736
	end -- 2736
	if self.phase == "tower-enter" then -- 2736
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 2736
			self.phase = "tower-desk" -- 2740
			self.phaseTick = 0 -- 2741
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 2742
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 2743
		end -- 2743
		return -- 2745
	end -- 2745
	if self.phase == "tower-desk" then -- 2745
		local deskX = self.ox + 605 -- 2748
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 2749
		if not near or not input.interact.held then -- 2749
			self.deskHold = 0 -- 2751
			return -- 2752
		end -- 2752
		self.deskHold = self.deskHold + 1 -- 2754
		if self.deskHold == 12 then -- 2754
			self:flashSet("针套 · 放在桌上", 1) -- 2756
		elseif self.deskHold == 24 then -- 2756
			self:flashSet("指南针 · 压住纸条", 1) -- 2758
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 2758
			self.towerHanded = true -- 2760
			self.deskHold = 0 -- 2761
			self.run.story.segments.tower_handover = true -- 2762
			self.phase = "tower-given" -- 2763
			self.phaseTick = 0 -- 2764
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 2765
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 2770
		end -- 2770
		return -- 2772
	end -- 2772
	if self.phase == "tower-given" then -- 2772
		local soldier = self.storyRoute == "soldier" -- 2777
		self.phaseTick = self.phaseTick + 1 -- 2778
		if self.phaseTick == 60 then -- 2778
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 2780
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 2781
		elseif self.phaseTick == 120 then -- 2781
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 2783
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 2783
			self.phase = "tower-end" -- 2785
			self.phaseTick = 0 -- 2786
			if not self.run.finished then -- 2786
				self.run.finished = true -- 2788
				local ending = soldier and "reunion" or "lamp" -- 2789
				self.run.story.ending = ending -- 2790
				local ____soldier_44 -- 2793
				if soldier then -- 2793
					____soldier_44 = self.run.story.segments.escort5 == true -- 2794
				else -- 2794
					____soldier_44 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 2795
				end -- 2795
				local played = ____soldier_44 -- 2793
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 2796
				if official then -- 2796
					if soldier then -- 2796
						self.run.archive.soldierCleared = true -- 2800
					else -- 2800
						self.run.archive.childCleared = true -- 2802
					end -- 2802
					self.archiveDirty = true -- 2804
				end -- 2804
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 2806
				self:emit("endingReached", { -- 2807
					route = soldier and "soldier" or "child", -- 2808
					ending = ending, -- 2809
					official = official, -- 2810
					source = self.run.source, -- 2811
					lines = {self.endingLines[1], self.endingLines[2]}, -- 2812
					childCleared = self.run.archive.childCleared, -- 2813
					soldierCleared = self.run.archive.soldierCleared, -- 2814
					artifactOwned = self.run.archive.artifactOwned, -- 2815
					equipped = self.equippedWeapon -- 2816
				}) -- 2816
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 2818
			end -- 2818
		end -- 2818
		return -- 2821
	end -- 2821
	self.phaseTick = self.phaseTick + 1 -- 2823
	if input.interact.pressed or input.retry.pressed then -- 2823
		self.restartStory = true -- 2826
		self:requestRoom("prologue", "片尾再玩") -- 2827
		self:flashSet("回到序章", 1.4) -- 2828
	end -- 2828
end -- 2692
function Play.prototype.stepChase(self, dt, input) -- 2833
	if self.caughtT > 0 then -- 2833
		self.caughtT = self.caughtT - dt -- 2835
		if self.caughtT <= 0 then -- 2835
			self:recoverFromCaught() -- 2837
		end -- 2837
		return -- 2839
	end -- 2839
	if self.room.key == "village" then -- 2839
		self:stepScavChase() -- 2842
	elseif self.room.key == "forest" then -- 2842
		self:stepForestRoute() -- 2844
		self:stepDog(dt) -- 2845
		if self.player.x >= self.ox + 1450 then -- 2845
			self:requestRoom("tower", "到林缘北塔") -- 2848
			self:flashSet("林缘 · 北塔", 1.4) -- 2849
		end -- 2849
	end -- 2849
end -- 2833
function Play.prototype.stepScavChase(self) -- 2855
	local s = self.room.scavenger -- 2856
	if s == nil then -- 2856
		return -- 2858
	end -- 2858
	local p = self.player -- 2860
	if self.passed and p.x > self.ox + 440 then -- 2860
		if self.scavChase then -- 2860
			self.scavChase = false -- 2864
			self.scavState = "back" -- 2865
			self.scavT = 0 -- 2866
		end -- 2866
		return -- 2868
	end -- 2868
	local dx = p.x - self.scavX -- 2870
	local dist = math.abs(dx) -- 2871
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 2872
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 2873
	if not self.scavChase then -- 2873
		if visible then -- 2873
			self.scavSee = self.scavSee + 1 -- 2876
			if self.scavSee >= 24 then -- 2876
				self.scavChase = true -- 2878
				self.scavState = "chase" -- 2879
				self.scavTargetX = p.x -- 2880
				self:flashSet("他看见你了", 1.2) -- 2881
			end -- 2881
		else -- 2881
			self.scavSee = 0 -- 2884
		end -- 2884
		return -- 2886
	end -- 2886
	local dir = p.x > self.scavX and 1 or -1 -- 2889
	self.scavX = self.scavX + dir * 96 / 60 -- 2890
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 2890
		self:caught() -- 2892
		return -- 2893
	end -- 2893
	if hidden then -- 2893
		self.scavSee = 0 -- 2897
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 2898
		self.scavT = self.scavT - 1 -- 2899
		if self.scavT <= 0 then -- 2899
			self.scavChase = false -- 2901
			self.scavState = "patrol" -- 2902
			self:flashSet("他失去了目标", 1) -- 2903
		end -- 2903
	end -- 2903
end -- 2855
function Play.prototype.stepDog(self, dt) -- 2909
	local ____temp_45 -- 2910
	if self.room.story == nil then -- 2910
		____temp_45 = nil -- 2910
	else -- 2910
		____temp_45 = self.room.story.dog -- 2910
	end -- 2910
	local dog = ____temp_45 -- 2910
	if dog == nil then -- 2910
		return -- 2912
	end -- 2912
	local p = self.player -- 2914
	local dist = math.abs(p.x - self.dogX) -- 2915
	if self.dogState == "patrol" then -- 2915
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 2917
		if self.dogX < dog.x0 then -- 2917
			self.dogX = dog.x0 -- 2919
			self.dogDir = 1 -- 2920
		elseif self.dogX > dog.x1 then -- 2920
			self.dogX = dog.x1 -- 2922
			self.dogDir = -1 -- 2923
		end -- 2923
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 2925
		if not p.crouch and moving and dist < dog.range then -- 2925
			self.dogState = "ear" -- 2927
			self.dogT = 18 -- 2928
			self.dogTargetX = p.x -- 2929
			self:flashSet("狗转耳朵", 0.8) -- 2930
		end -- 2930
		return -- 2932
	end -- 2932
	if self.dogState == "ear" then -- 2932
		self.dogT = self.dogT - 1 -- 2935
		if self.dogT <= 0 then -- 2935
			self.dogState = "chase" -- 2937
			self.dogTargetX = p.x -- 2938
			self:flashSet("狗追来了", 1.4) -- 2939
		end -- 2939
		return -- 2941
	end -- 2941
	if self.dogState == "chase" then -- 2941
		local dir = p.x > self.dogX and 1 or -1 -- 2944
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 2945
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 2945
			self:caught() -- 2947
			self.dogState = "sniff" -- 2948
			self.dogT = 60 -- 2949
		elseif dist > dog.range * 1.5 or p.crouch then -- 2949
			self.dogState = "sniff" -- 2951
			self.dogT = 60 -- 2952
			self:flashSet("狗停下了", 0.9) -- 2953
		end -- 2953
		return -- 2955
	end -- 2955
	if self.dogState == "sniff" then -- 2955
		self.dogT = self.dogT - 1 -- 2958
		if self.dogT <= 0 then -- 2958
			self.dogState = "back" -- 2960
		end -- 2960
		return -- 2962
	end -- 2962
	local dir = dog.x0 > self.dogX and 1 or -1 -- 2965
	self.dogX = self.dogX + dir * dog.speed * dt -- 2966
	if math.abs(self.dogX - dog.x0) < 2 then -- 2966
		self.dogX = dog.x0 -- 2968
		self.dogState = "patrol" -- 2969
	end -- 2969
end -- 2909
function Play.prototype.stepForestRoute(self) -- 2974
	local p = self.player -- 2975
	local ox = self.ox -- 2976
	if self.forestPath == "" then -- 2976
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 2976
			self.forestPath = "burrow" -- 2979
			self.run.story.segments.forest_burrow = true -- 2980
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 2981
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 2982
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 2982
			self.forestPath = "ditch" -- 2984
			self.run.story.segments.forest_ditch = true -- 2985
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 2986
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 2987
		end -- 2987
	end -- 2987
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 2987
		self.waterSeen = true -- 2991
		self.run.story.segments.water_lantern = true -- 2992
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 2993
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 2994
	end -- 2994
end -- 2974
function Play.prototype.caught(self) -- 2998
	self.caughtT = 1 -- 2999
	self:flashSet("被抓 · 回到安全点", 1.6) -- 3000
end -- 2998
function Play.prototype.recoverFromCaught(self) -- 3004
	local p = self.player -- 3005
	p.x = self.ox + 140 -- 3006
	p.y = 0 -- 3007
	p.vy = 0 -- 3008
	p.vx = 0 -- 3009
	p.onGround = true -- 3010
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3010
		self.scavX = self.room.scavenger.x0 -- 3012
		self.scavState = "patrol" -- 3013
		self.scavSee = 0 -- 3014
		self.scavChase = false -- 3015
		self.scavT = 0 -- 3016
	end -- 3016
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3016
		self.dogX = self.room.story.dog.x0 -- 3019
		self.dogState = "patrol" -- 3020
		self.dogT = 0 -- 3021
	end -- 3021
	self.cam.x = p.x -- 3023
	self.cam.y = p.y + CAM_LOOK_UP -- 3024
	self:flashSet("回到安全点", 1.2) -- 3025
end -- 3004
function Play.prototype.updateGate(self) -- 3029
	if self.room.key ~= "checkpoint" then -- 3029
		self.gateOpen = false -- 3031
		return -- 3032
	end -- 3032
	local function inZone(x) -- 3034
		return x >= self.ox + 792 and x <= self.ox + 928 -- 3034
	end -- 3034
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 3035
end -- 3029
function Play.prototype.addItem(self, kind) -- 3041
	local inv = self.run.inventory -- 3042
	if kind == "shield" then -- 3042
		if inv.shield >= TOOL_CAP then -- 3042
			return false -- 3045
		end -- 3045
		inv.shield = inv.shield + 1 -- 3047
		return true -- 3048
	end -- 3048
	if kind == "wedge" then -- 3048
		if inv.wedge >= CONSUMABLE_CAP then -- 3048
			return false -- 3052
		end -- 3052
		inv.wedge = inv.wedge + 1 -- 3054
		return true -- 3055
	end -- 3055
	if kind == "ammo" then -- 3055
		if inv.ammo >= CONSUMABLE_CAP then -- 3055
			return false -- 3059
		end -- 3059
		inv.ammo = inv.ammo + 1 -- 3061
		return true -- 3062
	end -- 3062
	if kind == "scrap" then -- 3062
		inv.scrap = inv.scrap + 1 -- 3066
		return true -- 3067
	end -- 3067
	if kind == "wood" then -- 3067
		inv.wood = inv.wood + 1 -- 3070
		return true -- 3071
	end -- 3071
	if kind == "bell" then -- 3071
		inv.bell = inv.bell + 1 -- 3074
		return true -- 3075
	end -- 3075
	if kind == "pass" then -- 3075
		inv.pass = inv.pass + 1 -- 3078
		return true -- 3079
	end -- 3079
	if kind == "quickbelt" then -- 3079
		inv.quickbelt = inv.quickbelt + 1 -- 3082
		return true -- 3083
	end -- 3083
	return false -- 3085
end -- 3041
function Play.prototype.findBox(self, id) -- 3088
	local i = 0 -- 3089
	do -- 3089
		i = 0 -- 3090
		while i < #self.boxes do -- 3090
			if self.boxes[i + 1].id == id then -- 3090
				return self.boxes[i + 1] -- 3092
			end -- 3092
			i = i + 1 -- 3090
		end -- 3090
	end -- 3090
	return nil -- 3095
end -- 3088
function Play.prototype.findWedgeTarget(self) -- 3099
	local best = nil -- 3100
	local bestD = 0 -- 3101
	local i = 0 -- 3102
	do -- 3102
		i = 0 -- 3103
		while i < #self.boxes do -- 3103
			do -- 3103
				local b = self.boxes[i + 1] -- 3104
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3104
					goto __continue461 -- 3106
				end -- 3106
				if not self:nearBox(b, 26) then -- 3106
					goto __continue461 -- 3109
				end -- 3109
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3111
				if best == nil or d < bestD then -- 3111
					best = b -- 3113
					bestD = d -- 3114
				end -- 3114
			end -- 3114
			::__continue461:: -- 3114
			i = i + 1 -- 3103
		end -- 3103
	end -- 3103
	return best -- 3117
end -- 3099
function Play.prototype.stepCraft(self, input) -- 3125
	local inv = self.run.inventory -- 3126
	local ____opt_46 = self.run.trial -- 3126
	local required = CRAFT_TICKS - 6 * (____opt_46 and ____opt_46.ranks.craft or 0) -- 3127
	if self.craftT > 0 then -- 3127
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3127
			self.craftT = 0 -- 3131
			self:flashSet("制作中断", 0.8) -- 3132
			return true -- 3133
		end -- 3133
		self.craftT = self.craftT + 1 -- 3135
		if self.craftT >= required then -- 3135
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3135
				inv.scrap = inv.scrap - 1 -- 3138
				inv.wedge = inv.wedge + 1 -- 3139
				self:flashSet("制得木楔", 1.2) -- 3140
				self:log("制木楔") -- 3141
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3142
			end -- 3142
			self.craftT = 0 -- 3144
		end -- 3144
		return true -- 3146
	end -- 3146
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3146
		self.craftT = 1 -- 3149
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3150
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3151
		return true -- 3152
	end -- 3152
	return false -- 3154
end -- 3125
function Play.prototype.nearBox(self, b, reach) -- 3157
	local p = self.player -- 3158
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3159
end -- 3157
function Play.prototype.findInteract(self) -- 3165
	local p = self.player -- 3166
	local best = nil -- 3167
	local bestD = 1000000000 -- 3168
	local i = 0 -- 3169
	do -- 3169
		i = 0 -- 3170
		while i < #self.boxes do -- 3170
			do -- 3170
				local b = self.boxes[i + 1] -- 3171
				if b.interact == nil or b.broken == true then -- 3171
					goto __continue474 -- 3173
				end -- 3173
				if not self:nearBox(b, b.interact.reach or 27) then -- 3173
					goto __continue474 -- 3176
				end -- 3176
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3178
				if d < bestD then -- 3178
					bestD = d -- 3180
					best = b -- 3181
				end -- 3181
			end -- 3181
			::__continue474:: -- 3181
			i = i + 1 -- 3170
		end -- 3170
	end -- 3170
	return best -- 3184
end -- 3165
function Play.prototype.stepCampaign(self, dt, input) -- 3188
	local wr = self.room -- 3189
	local p = self.player -- 3190
	if self.reloadT > 0 then -- 3190
		self.reloadT = self.reloadT - 1 -- 3192
	end -- 3192
	if self.bracedShield ~= nil then -- 3192
		self.bracedShield.x = p.x + p.facing * 26 -- 3196
		self.bracedShield.y = p.y -- 3197
		local shBox = __TS__ArrayFind( -- 3198
			self.boxes, -- 3198
			function(____, b) return b.id == "braced_shield" end -- 3198
		) -- 3198
		if shBox ~= nil then -- 3198
			shBox.x0 = self.bracedShield.x - 15 -- 3200
			shBox.x1 = self.bracedShield.x + 15 -- 3201
			shBox.y0 = self.bracedShield.y -- 3202
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3203
		end -- 3203
	end -- 3203
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3203
		self.run.route = "drygoods" -- 3209
		self.run.joined = false -- 3210
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3211
		self:log("转布行线") -- 3212
	end -- 3212
	if wr.key == "escort3" then -- 3212
		local benchX = wr.minX + 560 -- 3216
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 60 -- 3217
		if nearBench and input.interact.pressed then -- 3217
			self:openCraftBench() -- 3219
		end -- 3219
	end -- 3219
	local i = 0 -- 3223
	do -- 3223
		i = 0 -- 3224
		while i < #self.pickups do -- 3224
			do -- 3224
				local pk = self.pickups[i + 1] -- 3225
				if self.run.taken[pk.id] == true then -- 3225
					goto __continue487 -- 3227
				end -- 3227
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3229
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3230
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3230
					if not self:addItem(pk.kind) then -- 3230
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3234
						self:log("满包拒绝 " .. pk.kind) -- 3235
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3236
						goto __continue487 -- 3237
					end -- 3237
					self.run.taken[pk.id] = true -- 3239
					self:flashSet("拾取 " .. pk.label, 1) -- 3240
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3241
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3242
				end -- 3242
			end -- 3242
			::__continue487:: -- 3242
			i = i + 1 -- 3224
		end -- 3224
	end -- 3224
	if not self:stepCraft(input) and input.interact.pressed then -- 3224
		self:campaignInteract() -- 3246
	end -- 3246
	self:stepCampaignCart(dt, input) -- 3248
	self:stepCampaignGoal() -- 3249
	self:campaignCheckpoint() -- 3250
end -- 3188
function Play.prototype.campaignCheckpoint(self) -- 3254
	local i = 0 -- 3255
	do -- 3255
		i = 0 -- 3256
		while i < #self.room.marks do -- 3256
			do -- 3256
				local m = self.room.marks[i + 1] -- 3257
				if m.kind ~= 0 then -- 3257
					goto __continue494 -- 3259
				end -- 3259
				local dx = self.player.x - m.x -- 3261
				local dy = self.player.y - m.y -- 3262
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3262
					self.checkpoint = m.x -- 3264
					self:captureCheckpoint(m.x) -- 3265
					self:flashSet("检查点", 1) -- 3266
				end -- 3266
			end -- 3266
			::__continue494:: -- 3266
			i = i + 1 -- 3256
		end -- 3256
	end -- 3256
end -- 3254
function Play.prototype.campaignInteract(self) -- 3272
	local b = self:findInteract() -- 3273
	if b ~= nil then -- 3273
		self:useInteract(b) -- 3275
		return -- 3276
	end -- 3276
	local inv = self.run.inventory -- 3278
	if inv.wedge > 0 then -- 3278
		local w = self:findWedgeTarget() -- 3280
		if w ~= nil then -- 3280
			if w.breakable ~= nil then -- 3280
				local ____w_breakable_48, ____hp_49 = w.breakable, "hp" -- 3280
				____w_breakable_48[____hp_49] = ____w_breakable_48[____hp_49] + (w.breakable.wedgeHp or 1) -- 3283
			end -- 3283
			inv.wedge = inv.wedge - 1 -- 3285
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3286
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 3288
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3289
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3290
			return -- 3291
		end -- 3291
	end -- 3291
	if inv.ammo > 0 and self.reloadT > 0 then -- 3291
		self.reloadT = 0 -- 3296
		self:closeReloadPuzzle() -- 3297
		inv.ammo = inv.ammo - 1 -- 3298
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3299
		self:log("用备用弹包") -- 3300
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3301
		return -- 3302
	end -- 3302
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 3302
		local p = self.player -- 3306
		self.bracedShield = { -- 3307
			x = p.x + p.facing * 26, -- 3307
			y = p.y, -- 3307
			w = 30, -- 3307
			h = 64, -- 3307
			hp = 1 -- 3307
		} -- 3307
		local ____self_boxes_50 = self.boxes -- 3307
		____self_boxes_50[#____self_boxes_50 + 1] = { -- 3308
			x0 = self.bracedShield.x - 15, -- 3309
			x1 = self.bracedShield.x + 15, -- 3309
			y0 = p.y, -- 3310
			y1 = p.y + 64, -- 3310
			depth = {min = -46, max = 46}, -- 3310
			label = "架起的残盾", -- 3310
			id = "braced_shield", -- 3310
			soft = true -- 3311
		} -- 3311
		inv.shield = inv.shield - 1 -- 3314
		self:flashSet("架残盾 · 挡一发", 1.2) -- 3315
		self:log("架残盾") -- 3316
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3317
		return -- 3318
	end -- 3318
	if inv.pass > 0 and self.run.joined == false then -- 3318
		inv.pass = inv.pass - 1 -- 3321
		self.run.joined = true -- 3322
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3323
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3324
		return -- 3325
	end -- 3325
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3327
end -- 3272
function Play.prototype.useInteract(self, b) -- 3330
	local kind = b.interact == nil and "" or b.interact.kind -- 3331
	local wr = self.room -- 3332
	if kind == "open_board" then -- 3332
		b.broken = true -- 3334
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3335
		for ____, cover in ipairs(self.boxes) do -- 3336
			if cover.id == "s2_board_cover" then -- 3336
				cover.broken = false -- 3338
				cover.hidden = false -- 3339
			end -- 3339
		end -- 3339
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3342
		self.run.joined = true -- 3343
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3344
		self:log("放下窗板") -- 3345
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3346
		return -- 3347
	end -- 3347
	if kind == "lower_curtain" then -- 3347
		for ____, curtain in ipairs(self.boxes) do -- 3350
			if curtain.id == "c2_curtain" then -- 3350
				curtain.broken = false -- 3352
				curtain.hidden = false -- 3353
			end -- 3353
		end -- 3353
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3356
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3357
		self:log("放下木帘") -- 3358
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3359
		return -- 3360
	end -- 3360
	if kind == "raise_latch" then -- 3360
		if wr.key == "c2-granary" and not self.cartDocked then -- 3360
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3364
			return -- 3365
		end -- 3365
		b.broken = true -- 3367
		self.objectiveDone = true -- 3368
		if wr.key == "c1-yard" then -- 3368
			self.run.c1Latch = true -- 3371
			self.run.joined = true -- 3372
			for ____, door in ipairs(self.boxes) do -- 3373
				if door.id == "c1_door" then -- 3373
					door.broken = true -- 3375
				end -- 3375
			end -- 3375
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3378
		else -- 3378
			self.run.c2Latch = true -- 3380
			self.run.joined = true -- 3381
		end -- 3381
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3383
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3384
		self:log("抬闩") -- 3385
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3386
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3387
	end -- 3387
end -- 3330
function Play.prototype.stepCampaignCart(self, dt, input) -- 3392
	local wr = self.room -- 3393
	local c = wr.cart -- 3394
	if c.bodyW <= 0 then -- 3394
		return -- 3396
	end -- 3396
	local p = self.player -- 3398
	local handleX = self.cartAxle + c.handleOffset -- 3399
	if not self.gripping then -- 3399
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3399
			self.gripping = true -- 3403
			self:flashSet("握住车柄 · A/D 推", 1) -- 3404
		end -- 3404
		return -- 3406
	end -- 3406
	if input.interact.pressed then -- 3406
		self.gripping = false -- 3409
		self:flashSet("松手", 0.5) -- 3410
		return -- 3411
	end -- 3411
	if not self.cartDocked then -- 3411
		if input.moveX ~= 0 and not self:stuckCart() then -- 3411
			self.cartAxle = math.max( -- 3415
				c.startX, -- 3415
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3415
			) -- 3415
		end -- 3415
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3415
			self.cartExposed = true -- 3420
			local gun = nil -- 3421
			local gi = 0 -- 3422
			do -- 3422
				gi = 0 -- 3423
				while gi < #self.enemies do -- 3423
					local e = self.enemies[gi + 1] -- 3424
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3424
						gun = e -- 3426
						break -- 3427
					end -- 3427
					gi = gi + 1 -- 3423
				end -- 3423
			end -- 3423
			if gun ~= nil then -- 3423
				self:campaignEnemyFire(gun) -- 3431
			end -- 3431
		end -- 3431
		p.x = self.cartAxle + c.handleOffset -- 3434
		p.y = c.baseY -- 3435
		p.depth = c.depth or 0 -- 3436
		p.vx = 0 -- 3437
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3437
			self.cartAxle = c.endX -- 3439
			self.cartDocked = true -- 3440
			self.gripping = false -- 3441
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3442
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3443
			self:flashSet("车轮入窝", 1.2) -- 3444
			self:log("车轮入窝") -- 3445
		end -- 3445
	end -- 3445
end -- 3392
function Play.prototype.stuckCart(self) -- 3451
	local i = 0 -- 3452
	do -- 3452
		i = 0 -- 3453
		while i < #self.boxes do -- 3453
			do -- 3453
				local b = self.boxes[i + 1] -- 3454
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3454
					goto __continue536 -- 3456
				end -- 3456
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3458
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3458
					return true -- 3460
				end -- 3460
			end -- 3460
			::__continue536:: -- 3460
			i = i + 1 -- 3453
		end -- 3453
	end -- 3453
	return false -- 3463
end -- 3451
function Play.prototype.stepCampaignGoal(self) -- 3467
	local wr = self.room -- 3468
	local c = wr.campaign -- 3469
	if c == nil then -- 3469
		return -- 3471
	end -- 3471
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3471
		self.objectiveDone = true -- 3474
	end -- 3474
	if c.goal == "reach_exit" then -- 3474
		self.objectiveDone = true -- 3477
	end -- 3477
	if not self.objectiveDone then -- 3477
		return -- 3480
	end -- 3480
	local p = self.player -- 3482
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3483
	if p.x < c.exitX or not partnerOk then -- 3483
		return -- 3485
	end -- 3485
	if self.run.story.segments[wr.key] ~= true then -- 3485
		self.run.story.segments[wr.key] = true -- 3489
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3490
	end -- 3490
	if wr.key == "escort5" then -- 3490
		self.escortDone = true -- 3494
		self.run.story.escortDone = true -- 3495
	end -- 3495
	if c.next ~= nil and c.next ~= "" then -- 3495
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3498
		self:flashSet("过关 · " .. c.next, 1.2) -- 3499
	elseif not self.run.finished then -- 3499
		self.run.finished = true -- 3501
		self:flashSet( -- 3502
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3502
			2 -- 3502
		) -- 3502
		self:log("C2 灰盒完成") -- 3503
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3504
	end -- 3504
end -- 3467
function Play.prototype.stepCampaignPartner(self, dt) -- 3509
	local a = self.partner -- 3510
	local wr = self.room -- 3511
	local cp = wr.companion -- 3512
	if not a.alive then -- 3512
		return -- 3514
	end -- 3514
	local p = self.player -- 3516
	if self.craftBench.active then -- 3516
		a.vx = 0 -- 3519
		return -- 3520
	end -- 3520
	local wait = false -- 3522
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3523
	local targetDepth = p.depth -- 3524
	if self.run.joined == false then -- 3524
		wait = true -- 3526
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3527
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3528
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3528
		wait = true -- 3530
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3531
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3532
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3532
		wait = true -- 3534
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3535
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3536
	end -- 3536
	if self.partnerStuck > 0.3 then -- 3536
		a.x = a.x + a.facing * 44 -- 3540
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3541
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3542
		self.partnerLaneHold = 1.1 -- 3543
		self.partnerStuck = 0 -- 3544
	end -- 3544
	if self.partnerLaneHold > 0 then -- 3544
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3547
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3548
	end -- 3548
	local dx = targetX - a.x -- 3550
	if not wait and math.abs(dx) > 74 then -- 3550
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3552
		local before = a.x -- 3553
		a.vx = dx > 0 and speed or -speed -- 3554
		a.facing = dx > 0 and 1 or -1 -- 3555
		self:slideX(a, a.vx * dt) -- 3556
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3556
			a.vy = CHILD_JUMP -- 3559
			a.onGround = false -- 3560
		end -- 3560
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3562
	else -- 3562
		a.vx = 0 -- 3564
		self.partnerStuck = 0 -- 3565
	end -- 3565
	local dz = targetDepth - a.depth -- 3567
	if math.abs(dz) > 6 then -- 3567
		local step = math.max( -- 3569
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3569
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3569
		) -- 3569
		a.depth = a.depth + step -- 3570
	end -- 3570
	a.depthSpeed = 0 -- 3572
	a.h = CHILD_H -- 3573
	a.crouch = false -- 3574
	self:fallY(a, dt) -- 3575
end -- 3509
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3579
	local p = self.player -- 3580
	local i = 0 -- 3581
	do -- 3581
		i = 0 -- 3582
		while i < #self.enemies do -- 3582
			do -- 3582
				local ____opt_51 = self.run.trial -- 3582
				if ____opt_51 and ____opt_51.lost then -- 3582
					return -- 3583
				end -- 3583
				local e = self.enemies[i + 1] -- 3584
				if not e.alive then -- 3584
					goto __continue563 -- 3586
				end -- 3586
				if e.hitT > 0 then -- 3586
					e.hitT = e.hitT - dt -- 3589
				end -- 3589
				if e.kind == "target" then -- 3589
					if not e.alive and e.hitT <= 0 then -- 3589
						e.alive = true -- 3594
					end -- 3594
					goto __continue563 -- 3596
				end -- 3596
				if e.kind == "breaker" then -- 3596
					self:stepBreaker(e, dt) -- 3599
					goto __continue563 -- 3600
				end -- 3600
				if e.kind == "shield" then -- 3600
					self:stepShield(e, dt, input) -- 3603
					goto __continue563 -- 3604
				end -- 3604
				local dx = e.x - p.x -- 3607
				if not e.awake then -- 3607
					if math.abs(dx) > 520 then -- 3607
						goto __continue563 -- 3610
					end -- 3610
					e.awake = true -- 3612
					e.fireCd = 48 -- 3613
					goto __continue563 -- 3614
				end -- 3614
				if math.abs(dx) > ENEMY_RANGE then -- 3614
					goto __continue563 -- 3617
				end -- 3617
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 3617
					goto __continue563 -- 3622
				end -- 3622
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 3622
					goto __continue563 -- 3625
				end -- 3625
				if self:blockedShot(e, p) then -- 3625
					if e.warnT > 0 then -- 3625
						e.warnT = 0 -- 3631
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3632
					end -- 3632
					goto __continue563 -- 3634
				end -- 3634
				if e.warnT > 0 then -- 3634
					e.warnT = e.warnT - 1 -- 3637
					if e.warnT <= 0 then -- 3637
						self:campaignEnemyFire(e) -- 3639
					end -- 3639
				elseif e.fireCd > 0 then -- 3639
					e.fireCd = e.fireCd - 1 -- 3642
					if e.fireCd <= 0 then -- 3642
						e.warnT = WARN_TICKS -- 3644
					end -- 3644
				else -- 3644
					e.fireCd = 40 -- 3647
				end -- 3647
			end -- 3647
			::__continue563:: -- 3647
			i = i + 1 -- 3582
		end -- 3582
	end -- 3582
end -- 3579
function Play.prototype.blockedShot(self, e, p) -- 3653
	local eDepth = e.depth or 0 -- 3654
	local ex = e.x -- 3655
	local ey = e.y + e.h * 0.62 -- 3657
	local px = p.x -- 3658
	local py = p.y + p.h * 0.55 -- 3659
	local dx = px - ex -- 3660
	local dyScreen = py + p.depth - (ey + eDepth) -- 3661
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3662
	if len < 0.01 then -- 3662
		return false -- 3664
	end -- 3664
	local ray = { -- 3668
		x = ex, -- 3669
		y = ey, -- 3669
		dx = dx / len, -- 3670
		dy = (py - ey) / len, -- 3670
		depth = eDepth, -- 3671
		dDepth = (p.depth - eDepth) / len -- 3671
	} -- 3671
	local best = -1 -- 3673
	local j = 0 -- 3674
	do -- 3674
		j = 0 -- 3675
		while j < #self.boxes do -- 3675
			do -- 3675
				local b = self.boxes[j + 1] -- 3676
				if b.broken == true or b.passable == true or b.hidden == true then -- 3676
					goto __continue586 -- 3678
				end -- 3678
				if b.id == "braced_shield" then -- 3678
					goto __continue586 -- 3683
				end -- 3683
				local t = hitBox(ray, b) -- 3685
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3685
					best = t -- 3689
				end -- 3689
			end -- 3689
			::__continue586:: -- 3689
			j = j + 1 -- 3675
		end -- 3675
	end -- 3675
	return best >= 0 -- 3692
end -- 3653
function Play.prototype.campaignEnemyFire(self, e) -- 3695
	local p = self.player -- 3696
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3697
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3697
		local ____self_bracedShield_53, ____hp_54 = self.bracedShield, "hp" -- 3697
		____self_bracedShield_53[____hp_54] = ____self_bracedShield_53[____hp_54] - 1 -- 3699
		self.boxes = __TS__ArrayFilter( -- 3700
			self.boxes, -- 3700
			function(____, b) return b.id ~= "braced_shield" end -- 3700
		) -- 3700
		self.bracedShield = nil -- 3701
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3702
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3703
		return -- 3704
	end -- 3704
	if self:blockedShot(e, p) then -- 3704
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3707
		return -- 3708
	end -- 3708
	local cover = self:blockedByCover(e, p) -- 3710
	if cover ~= nil and self.coverHug then -- 3710
		self.coveredFlash = 0.5 -- 3712
		self:flashSet("掩体挡下", 0.6) -- 3713
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3714
		return -- 3719
	end -- 3719
	if self.invulnT > 0 then -- 3719
		return -- 3722
	end -- 3722
	local ____opt_55 = self.run.trial -- 3722
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_55 and ____opt_55.ranks.guard or 0) -- 3724
	self.craftT = 0 -- 3725
	self.hp = self.hp - 1 -- 3726
	self:emit("actorHit", { -- 3727
		target = "player", -- 3727
		amount = 1, -- 3727
		hp = self.hp, -- 3727
		maxHp = self.maxHp, -- 3727
		enemyX = e.x -- 3727
	}) -- 3727
	self:flashSet( -- 3728
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3728
		0.8 -- 3728
	) -- 3728
	if self.hp <= 0 then -- 3728
		self:campaignFailed() -- 3730
	end -- 3730
end -- 3695
function Play.prototype.stepShield(self, e, dt, input) -- 3735
	local p = self.player -- 3736
	local dx = p.x - e.x -- 3737
	local adx = math.abs(dx) -- 3738
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 3741
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 3742
	if adx > 150 then -- 3742
		local before = e.x -- 3744
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 3745
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 3745
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3748
		end -- 3748
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 3748
		local fromFront = (e.x - p.x) * p.facing > 0 -- 3753
		local rollDodges = p.rollT > 0 and fromFront -- 3754
		if not rollDodges and self.invulnT <= 0 then -- 3754
			local ____opt_57 = self.run.trial -- 3754
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_57 and ____opt_57.ranks.guard or 0) -- 3756
			self.craftT = 0 -- 3757
			self.hp = self.hp - 1 -- 3758
			self:emit("actorHit", { -- 3759
				target = "player", -- 3759
				amount = 1, -- 3759
				hp = self.hp, -- 3759
				maxHp = self.maxHp, -- 3759
				enemyX = e.x -- 3759
			}) -- 3759
			self:flashSet( -- 3760
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3760
				0.8 -- 3760
			) -- 3760
			if self.hp <= 0 then -- 3760
				self:campaignFailed() -- 3762
				return -- 3763
			end -- 3763
		end -- 3763
		e.swingT = 70 -- 3766
	end -- 3766
	if (e.swingT or 0) > 0 then -- 3766
		e.swingT = (e.swingT or 0) - 1 -- 3769
	end -- 3769
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 3769
		local dd = p.depth - (e.depth or 0) -- 3772
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 3773
	end -- 3773
end -- 3735
function Play.prototype.stepBreaker(self, e, dt) -- 3778
	local p = self.player -- 3779
	if e.awake ~= true then -- 3779
		if math.abs(p.x - e.x) < 560 then -- 3779
			e.awake = true -- 3782
		else -- 3782
			return -- 3784
		end -- 3784
	end -- 3784
	local target = nil -- 3787
	local bestD = 1000000000 -- 3788
	local i = 0 -- 3789
	do -- 3789
		i = 0 -- 3790
		while i < #self.boxes do -- 3790
			do -- 3790
				local b = self.boxes[i + 1] -- 3791
				if b.breakable == nil or b.broken == true then -- 3791
					goto __continue610 -- 3793
				end -- 3793
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 3795
				if d < bestD then -- 3795
					bestD = d -- 3797
					target = b -- 3798
				end -- 3798
			end -- 3798
			::__continue610:: -- 3798
			i = i + 1 -- 3790
		end -- 3790
	end -- 3790
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 3801
	local dx = tx - e.x -- 3802
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 3803
	if math.abs(dx) > reach then -- 3803
		local before = e.x -- 3805
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 3806
		if math.abs(e.x - before) < 0.3 then -- 3806
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3808
		end -- 3808
	elseif (e.swingT or 0) <= 0 then -- 3808
		e.swingT = 64 -- 3811
		if target ~= nil then -- 3811
			self:damageProp(target, 2) -- 3813
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 3813
			local ____opt_59 = self.run.trial -- 3813
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_59 and ____opt_59.ranks.guard or 0) -- 3815
			self.craftT = 0 -- 3816
			self.hp = self.hp - 1 -- 3817
			self:emit("actorHit", { -- 3818
				target = "player", -- 3818
				amount = 1, -- 3818
				hp = self.hp, -- 3818
				maxHp = self.maxHp, -- 3818
				enemyX = e.x -- 3818
			}) -- 3818
			self:flashSet("破障手近身", 0.8) -- 3819
			if self.hp <= 0 then -- 3819
				self:campaignFailed() -- 3821
				return -- 3822
			end -- 3822
		end -- 3822
	end -- 3822
	if (e.swingT or 0) > 0 then -- 3822
		e.swingT = (e.swingT or 0) - 1 -- 3827
	end -- 3827
end -- 3778
function Play.prototype.campaignFailed(self) -- 3831
	if self.run.trial ~= nil then -- 3831
		self.run.trial.lost = true -- 3833
		self.wantRoom = "" -- 3834
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3835
		return -- 3836
	end -- 3836
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 3836
		self:restartEscortFromDeath() -- 3841
		return -- 3842
	end -- 3842
	local p = self.player -- 3844
	self.hp = self.maxHp -- 3845
	self.invulnT = INVULN_RESPAWN_TICKS -- 3846
	self.reloadT = 0 -- 3847
	self:closeReloadPuzzle() -- 3848
	self.gripping = false -- 3849
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 3850
	self:log("被击倒") -- 3851
	p.x = self.room.minX + 90 -- 3852
	p.y = 0 -- 3853
	p.depth = 0 -- 3854
	p.vx = 0 -- 3855
	p.vy = 0 -- 3856
	p.onGround = true -- 3857
	p.rollT = 0 -- 3858
	self.partner.x = p.x - 50 -- 3859
	self.partner.y = 0 -- 3860
	self.partner.depth = 0 -- 3861
	self.cam.x = p.x -- 3862
	local i = 0 -- 3863
	do -- 3863
		i = 0 -- 3864
		while i < #self.enemies do -- 3864
			do -- 3864
				local e = self.enemies[i + 1] -- 3865
				if not e.alive then -- 3865
					goto __continue624 -- 3867
				end -- 3867
				e.x = e.homeX == nil and e.x or e.homeX -- 3869
				e.warnT = 0 -- 3870
				e.fireCd = 40 -- 3871
				e.swingT = 0 -- 3872
				e.awake = false -- 3873
			end -- 3873
			::__continue624:: -- 3873
			i = i + 1 -- 3864
		end -- 3864
	end -- 3864
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3875
end -- 3831
function Play.prototype.isEscortRoom(self) -- 3879
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 3880
end -- 3879
function Play.prototype.restartEscortFromDeath(self) -- 3888
	local story = self.run.story -- 3889
	local inv = self.run.inventory -- 3890
	self.hp = self.maxHp -- 3891
	story.hp = self.maxHp -- 3892
	story.cp = nil -- 3893
	self.checkpointSnap = nil -- 3894
	story.carry = false -- 3895
	self.carryOn = false -- 3896
	story.craftedWeapon = "" -- 3897
	self.equippedWeapon = "standard_gun" -- 3898
	story.escortDone = false -- 3899
	self.escortDone = false -- 3900
	story.segments = {} -- 3901
	inv.wood = 0 -- 3902
	inv.bell = 0 -- 3903
	inv.scrap = 0 -- 3904
	inv.wedge = 0 -- 3905
	inv.ammo = 0 -- 3906
	inv.quickbelt = 0 -- 3907
	inv.shield = 0 -- 3908
	inv.pass = 0 -- 3909
	local taken = self.run.taken -- 3910
	local keys = __TS__ObjectKeys(taken) -- 3911
	local i = 0 -- 3912
	do -- 3912
		i = 0 -- 3913
		while i < #keys do -- 3913
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 3913
				__TS__Delete(taken, keys[i + 1]) -- 3915
			end -- 3915
			i = i + 1 -- 3913
		end -- 3913
	end -- 3913
	self.run.joined = true -- 3918
	self.reloadT = 0 -- 3919
	self:closeReloadPuzzle() -- 3920
	self.gripping = false -- 3921
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 3922
	self:log("男主线失败 · 回 escort1") -- 3923
	self:emit("campaignFailed", { -- 3924
		room = self.room.key, -- 3925
		hp = 0, -- 3925
		maxHp = self.maxHp, -- 3925
		reset = true, -- 3926
		to = "escort1", -- 3926
		route = self.storyRoute -- 3926
	}) -- 3926
	self:requestRoom("escort1", "男主线失败重开") -- 3928
end -- 3888
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 3932
	local i = 0 -- 3933
	do -- 3933
		i = 0 -- 3934
		while i < #self.enemies do -- 3934
			do -- 3934
				if i == skipIndex then -- 3934
					goto __continue633 -- 3936
				end -- 3936
				local e = self.enemies[i + 1] -- 3938
				if not e.alive or math.abs(e.x - center.x) > radius then -- 3938
					goto __continue633 -- 3940
				end -- 3940
				e.fireCd = 150 -- 3942
				e.warnT = 0 -- 3943
			end -- 3943
			::__continue633:: -- 3943
			i = i + 1 -- 3934
		end -- 3934
	end -- 3934
end -- 3932
function Play.prototype.stepEnemies(self, dt, input) -- 3947
	local i = 0 -- 3948
	do -- 3948
		i = 0 -- 3949
		while i < #self.enemies do -- 3949
			local e = self.enemies[i + 1] -- 3950
			if e.hitT > 0 then -- 3950
				e.hitT = e.hitT - dt -- 3952
			end -- 3952
			i = i + 1 -- 3949
		end -- 3949
	end -- 3949
	if self.coveredFlash > 0 then -- 3949
		self.coveredFlash = self.coveredFlash - dt -- 3956
	end -- 3956
	if self.isCampaign then -- 3956
		self:stepCampaignEnemies(dt, input) -- 3959
		return -- 3960
	end -- 3960
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 3960
		return -- 3964
	end -- 3964
	do -- 3964
		i = 0 -- 3966
		while i < #self.enemies do -- 3966
			do -- 3966
				local e = self.enemies[i + 1] -- 3967
				if not e.alive then -- 3967
					goto __continue644 -- 3969
				end -- 3969
				if e.warnT > 0 then -- 3969
					e.warnT = e.warnT - 1 -- 3972
					if e.warnT <= 0 then -- 3972
						self:enemyFire(e, input) -- 3974
					end -- 3974
					goto __continue644 -- 3976
				end -- 3976
				if e.fireCd > 0 then -- 3976
					e.fireCd = e.fireCd - 1 -- 3979
					if e.fireCd <= 0 then -- 3979
						e.warnT = WARN_TICKS -- 3981
					end -- 3981
				else -- 3981
					e.warnT = WARN_TICKS -- 3985
				end -- 3985
			end -- 3985
			::__continue644:: -- 3985
			i = i + 1 -- 3966
		end -- 3966
	end -- 3966
end -- 3947
function Play.prototype.enemyFire(self, e, input) -- 3991
	local p = self.player -- 3992
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 3992
		self:flashSet("枪声响在远处", 0.4) -- 3994
		e.fireCd = FIRE_COOLDOWN -- 3995
		return -- 3996
	end -- 3996
	local cover = self:blockedByCover(e, p) -- 3999
	local hugging = cover ~= nil -- 4000
	self.coverBlocking = hugging -- 4001
	local covered = hugging and input.cover.held -- 4002
	if covered then -- 4002
		self.coveredFlash = 0.5 -- 4004
		self:flashSet("掩体挡下", 0.5) -- 4005
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4006
		e.fireCd = FIRE_COOLDOWN -- 4011
		return -- 4012
	end -- 4012
	self.hp = self.hp - 1 -- 4014
	self:emit("actorHit", { -- 4015
		target = "player", -- 4015
		amount = 1, -- 4015
		hp = self.hp, -- 4015
		maxHp = self.maxHp, -- 4015
		enemyX = e.x -- 4015
	}) -- 4015
	self:flashSet( -- 4016
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4016
		0.7 -- 4016
	) -- 4016
	e.fireCd = FIRE_COOLDOWN -- 4017
	if self.hp <= 0 then -- 4017
		self:gateFailed() -- 4019
	end -- 4019
end -- 3991
function Play.prototype.blockedByCover(self, enemy, p) -- 4024
	local b = self:coverAt(p) -- 4025
	if b == nil then -- 4025
		return nil -- 4027
	end -- 4027
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4029
end -- 4024
function Play.prototype.gateFailed(self) -- 4033
	local ____temp_61 -- 4034
	if self.room.story == nil then -- 4034
		____temp_61 = nil -- 4034
	else -- 4034
		____temp_61 = self.room.story.gate -- 4034
	end -- 4034
	local g = ____temp_61 -- 4034
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 4035
	self.hp = self.maxHp -- 4036
	self.gateTick = 0 -- 4037
	self.gateSpawned = 0 -- 4038
	self.enemies = {} -- 4039
	self.gateFailCount = self.gateFailCount + 1 -- 4040
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 4042
	self.player.y = 0 -- 4043
	self.player.vy = 0 -- 4044
	self.player.depth = 0 -- 4045
	self.player.depthSpeed = 0 -- 4046
	self.player.onGround = true -- 4047
	self.player.crouch = false -- 4048
	self.player.h = SOLDIER_H -- 4049
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 4050
	self.partner.y = 0 -- 4051
	self.partner.vy = 0 -- 4052
	self.partner.depth = 0 -- 4053
	self.partner.depthSpeed = 0 -- 4054
	self.partner.onGround = true -- 4055
	self.cam.x = self.player.x -- 4056
	self.phase = "gate-idle" -- 4057
	self.phaseTick = 0 -- 4058
	self.coverHug = false -- 4059
	self.coverBlocking = false -- 4060
	self.coverEntity = "" -- 4061
	self.gateNeedConfirm = true -- 4062
	self.gateRestartArmed = false -- 4063
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 4064
end -- 4033
function Play.prototype.stepRedCart(self, input) -- 4068
	if self.room.key ~= "outside" or self.redCartPulled then -- 4068
		return -- 4070
	end -- 4070
	local box = __TS__ArrayFind( -- 4072
		self.boxes, -- 4072
		function(____, b) return b.id == "outside_red_cart" end -- 4072
	) -- 4072
	if box == nil then -- 4072
		self.redCartPulled = true -- 4074
		return -- 4075
	end -- 4075
	local cx = (box.x0 + box.x1) * 0.5 -- 4077
	local p = self.player -- 4078
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 4078
		return -- 4080
	end -- 4080
	if not input.interact.pressed then -- 4080
		return -- 4083
	end -- 4083
	box.x0 = 430 -- 4085
	box.x1 = 474 -- 4086
	self.cartAxle = self.room.cart.endX -- 4088
	self.cartDocked = true -- 4089
	self.redCartPulled = true -- 4090
	if self.run.story ~= nil then -- 4090
		self.run.story.segments.outside_cart = true -- 4092
	end -- 4092
	self:flashSet("拉开红布车 · 石阶口露出来", 1.6) -- 4094
	self:emit("storyBeat", {beat = "red_cart", x = p.x, room = "outside"}) -- 4095
end -- 4068
function Play.prototype.stepInteract(self, dt, input) -- 4098
	local p = self.player -- 4099
	self:stepRedCart(input) -- 4100
	local calmUsed = self.calmConsumed -- 4101
	self.calmConsumed = false -- 4102
	local calming = self.escort.state == "calming" -- 4104
	self.focusCart = false -- 4105
	if self.room.key == "outside" then -- 4105
		local c = self.room.cart -- 4107
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 4108
		local dy = p.y - c.baseY -- 4109
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 4110
	end -- 4110
	if not calmUsed and not calming then -- 4110
		self:stepCart(dt, input) -- 4114
	end -- 4114
	if calmUsed then -- 4114
		self:flashSet("安抚 · 敲两下", 0.8) -- 4119
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4119
		if self.knockT > 0 then -- 4119
			self.knocks = self.knocks + 1 -- 4123
		else -- 4123
			self.knocks = 1 -- 4125
		end -- 4125
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4127
		self.knockT = 1.2 -- 4128
		if self.knocks >= 2 then -- 4128
			self:flashSet("敲两下", 0.8) -- 4130
			self.knocks = 0 -- 4131
		else -- 4131
			self:flashSet("敲一下", 0.5) -- 4133
		end -- 4133
	elseif self.knockT > 0 then -- 4133
		self.knockT = self.knockT - dt -- 4136
		if self.knockT <= 0 then -- 4136
			self.knocks = 0 -- 4138
		end -- 4138
	end -- 4138
	local i = 0 -- 4143
	do -- 4143
		i = 0 -- 4144
		while i < #self.room.marks do -- 4144
			do -- 4144
				local m = self.room.marks[i + 1] -- 4145
				if m.kind ~= 0 then -- 4145
					goto __continue677 -- 4147
				end -- 4147
				local subjects = {self.partner, self.player} -- 4149
				local k = 0 -- 4150
				do -- 4150
					k = 0 -- 4151
					while k < #subjects do -- 4151
						do -- 4151
							local s = subjects[k + 1] -- 4152
							if not s.alive then -- 4152
								goto __continue680 -- 4154
							end -- 4154
							local dx = s.x - m.x -- 4156
							local dy = s.y - m.y -- 4157
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4157
								self.checkpoint = m.x -- 4159
								self.checkpointCartAxle = self.cartAxle -- 4160
								if self.isCampaign then -- 4160
									self:captureCheckpoint(m.x) -- 4163
								end -- 4163
								if self.cartDocked then -- 4163
									self:flashSet("检查点 · 车已落窝", 1) -- 4166
								else -- 4166
									self:flashSet("检查点 · 车还没到位", 1) -- 4168
								end -- 4168
							end -- 4168
						end -- 4168
						::__continue680:: -- 4168
						k = k + 1 -- 4151
					end -- 4151
				end -- 4151
			end -- 4151
			::__continue677:: -- 4151
			i = i + 1 -- 4144
		end -- 4144
	end -- 4144
	self:checkCarryGate() -- 4174
end -- 4098
function Play.prototype.stepVillage(self, dt, input) -- 4178
	if self.room.key ~= "village" then -- 4178
		return -- 4180
	end -- 4180
	local p = self.player -- 4182
	local bottle = self.room.bottle -- 4183
	local scav = self.room.scavenger -- 4184
	if not self.hasBottle and bottle ~= nil then -- 4184
		local dx = p.x - bottle.x -- 4188
		local dy = p.y + p.h * 0.5 - bottle.y -- 4189
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4189
			self.hasBottle = true -- 4191
			self:flashSet("拾起瓶子", 0.8) -- 4192
		end -- 4192
	end -- 4192
	if self.hasBottle then -- 4192
		if input.aim.held then -- 4192
			self.aimHold = self.aimHold + dt -- 4199
			if self.aimHold > 1.2 then -- 4199
				self.aimHold = 1.2 -- 4201
			end -- 4201
			local cached = self:bottleEnd() -- 4204
			self.bottleAimX = cached.x -- 4205
			self.bottleAimY = cached.y -- 4206
		elseif input.aim.released then -- 4206
			if self.aimHold < 0.12 then -- 4206
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 4210
				self.aimHold = 0 -- 4211
			else -- 4211
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4213
				self:throwBottle(____end.x, ____end.y) -- 4214
				self.aimHold = 0 -- 4215
			end -- 4215
		end -- 4215
	else -- 4215
		self.aimHold = 0 -- 4219
		self.bottleAimX = -1 -- 4220
	end -- 4220
	local fly = self.bottleFly -- 4225
	if fly ~= nil then -- 4225
		fly.t = fly.t + dt -- 4227
		fly.x = fly.x0 + fly.vx * fly.t -- 4228
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4229
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4230
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4230
			self:landBottle(fly) -- 4232
		end -- 4232
	end -- 4232
	if self.bottleLandT > 0 then -- 4232
		self.bottleLandT = self.bottleLandT - dt -- 4236
	end -- 4236
	if scav ~= nil then -- 4236
		self:stepScav(dt, scav) -- 4240
	end -- 4240
	local line = self.room.passLine -- 4243
	if line ~= nil and not self.passed and p.x >= line then -- 4243
		self.passed = true -- 4245
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4246
	end -- 4246
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4249
	if underTable then -- 4249
		self.footHintT = self.footHintT - 1 -- 4251
		if self.footHintT <= 0 then -- 4251
			self.footHintT = 90 -- 4253
			local scavX = self.scavX -- 4254
			local near = math.abs(scavX - p.x) < 120 -- 4255
			local heard = near or self.scavState == "walk" or self.scavState == "chase" -- 4256
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4257
			self:emit("storyBeat", {beat = near and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4258
		end -- 4258
	else -- 4258
		self.footHintT = 0 -- 4261
	end -- 4261
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4261
		self.ditchHinted = true -- 4265
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4266
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4267
	end -- 4267
	if self.passed and p.x >= self.ox + 640 then -- 4267
		self:requestRoom("forest", "过第一院出院") -- 4271
		self:flashSet("钻出暗渠 · 北塔森林", 1.4) -- 4272
	end -- 4272
end -- 4178
function Play.prototype.bottleEnd(self) -- 4277
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4278
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 4281
	return {x = aim.x, y = g} -- 4282
end -- 4277
function Play.prototype.throwBottle(self, tx, ty) -- 4286
	local p = self.player -- 4287
	local dir = tx >= p.x and 1 or -1 -- 4289
	p.facing = dir -- 4290
	local x0 = p.x + dir * 10 -- 4291
	local y0 = p.y + p.h * 0.7 -- 4292
	self.bottleTargetX = tx -- 4293
	self.bottleTargetY = ty -- 4294
	self.bottleSurfaceY = ty -- 4295
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4296
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4297
	self.bottleFly = { -- 4298
		x = x0, -- 4298
		y = y0, -- 4298
		x0 = x0, -- 4298
		y0 = y0, -- 4298
		vx = vx, -- 4298
		vy = vy, -- 4298
		t = 0 -- 4298
	} -- 4298
	self.hasBottle = false -- 4299
	self:flashSet("投出", 0.4) -- 4300
	self:emit( -- 4301
		"bottleThrown", -- 4301
		{ -- 4301
			fromX = x0, -- 4302
			fromY = y0, -- 4303
			targetX = tx, -- 4304
			targetY = ty, -- 4305
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4306
		} -- 4306
	) -- 4306
end -- 4286
function Play.prototype.landBottle(self, fly) -- 4311
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4312
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4313
	local s = self.room.scavenger -- 4314
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 4315
	self.bottleFly = nil -- 4316
	self.bottleTargetX = -1 -- 4317
	self.bottleTargetY = 0 -- 4318
	self.bottleSurfaceY = -1 -- 4319
	self.bottleLandX = x -- 4320
	self.bottleLandY = y -- 4321
	self.bottleLandT = 0.9 -- 4322
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 4323
	self:hearBottle(x) -- 4324
end -- 4311
function Play.prototype.hearBottle(self, x) -- 4328
	local s = self.room.scavenger -- 4329
	if s == nil then -- 4329
		return -- 4331
	end -- 4331
	if math.abs(x - self.scavX) > s.range then -- 4331
		self:flashSet("落地 · 他没听见", 0.6) -- 4334
		return -- 4335
	end -- 4335
	self.scavState = "turn" -- 4337
	self.scavT = s.hearTicks -- 4338
	self.scavTargetX = x -- 4339
	self:flashSet("砖地一响 · 他转头", 0.9) -- 4340
end -- 4328
function Play.prototype.stepScav(self, dt, s) -- 4344
	if self.scavState == "chase" then -- 4344
		return -- 4347
	end -- 4347
	if self.scavState == "turn" then -- 4347
		self.scavT = self.scavT - 1 -- 4350
		if self.scavT <= 0 then -- 4350
			self.scavState = "walk" -- 4352
		end -- 4352
		return -- 4354
	end -- 4354
	if self.scavState == "walk" then -- 4354
		local d = self.scavTargetX - self.scavX -- 4357
		if math.abs(d) < 4 then -- 4357
			self.scavState = "stall" -- 4359
			self.scavT = s.stallTicks -- 4360
			return -- 4361
		end -- 4361
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4363
		return -- 4364
	end -- 4364
	if self.scavState == "stall" then -- 4364
		self.scavT = self.scavT - 1 -- 4367
		if self.scavT <= 0 then -- 4367
			self.scavState = "back" -- 4369
		end -- 4369
		return -- 4371
	end -- 4371
	if self.scavState == "back" then -- 4371
		local home = math.max( -- 4374
			s.x0, -- 4374
			math.min(s.x1, self.scavX) -- 4374
		) -- 4374
		if math.abs(home - self.scavX) < 2 then -- 4374
			self.scavState = "patrol" -- 4376
			return -- 4377
		end -- 4377
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4379
		return -- 4380
	end -- 4380
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4382
	if self.scavX >= s.x1 then -- 4382
		self.scavX = s.x1 -- 4384
		self.scavDir = -1 -- 4385
	elseif self.scavX <= s.x0 then -- 4385
		self.scavX = s.x0 -- 4387
		self.scavDir = 1 -- 4388
	end -- 4388
end -- 4344
function Play.prototype.stepCart(self, dt, input) -- 4396
	local p = self.player -- 4397
	local c = self.room.cart -- 4398
	if self.gripping then -- 4398
		if not input.interact.held then -- 4398
			self.gripping = false -- 4402
			self:flashSet("松开车把", 0.4) -- 4403
			return -- 4404
		end -- 4404
	else -- 4404
		if not input.interact.pressed then -- 4404
			return -- 4408
		end -- 4408
		if not self:cartHandleInReach(p) then -- 4408
			return -- 4411
		end -- 4411
		local track = c.depth or 0 -- 4413
		if self:limitDepth(p, track) ~= track then -- 4413
			return -- 4415
		end -- 4415
		p.depth = track -- 4417
		p.depthSpeed = 0 -- 4418
		self.gripping = true -- 4419
		self:flashSet("握住车把", 0.4) -- 4420
		return -- 4421
	end -- 4421
	if self.cartDocked then -- 4421
		return -- 4425
	end -- 4425
	local dir = input.moveX -- 4427
	if dir == 0 then -- 4427
		return -- 4429
	end -- 4429
	local lo = math.min(c.startX, c.endX) -- 4431
	local hi = math.max(c.startX, c.endX) -- 4432
	local next = self.cartAxle + dir * CART_SPEED * dt -- 4433
	if next < lo then -- 4433
		next = lo -- 4435
	end -- 4435
	if next > hi then -- 4435
		next = hi -- 4438
	end -- 4438
	local delta = next - self.cartAxle -- 4440
	if delta == 0 then -- 4440
		return -- 4442
	end -- 4442
	self.cartAxle = next -- 4444
	p.x = p.x + delta -- 4445
	p.facing = dir > 0 and 1 or -1 -- 4446
	self:slideX(p, 0) -- 4447
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 4447
		self.gripping = false -- 4449
		self:flashSet("跟不上了，脱手", 0.6) -- 4450
		return -- 4451
	end -- 4451
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 4451
		self.cartDocked = true -- 4454
		self.gripping = false -- 4455
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 4456
		self:flashSet("车轮落窝", 1.2) -- 4457
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 4457
		self:flashSet("车轮回到起点", 0.5) -- 4459
	end -- 4459
end -- 4396
function Play.prototype.requestRoom(self, key, reason) -- 4467
	if self.wantRoom ~= "" then -- 4467
		return -- 4471
	end -- 4471
	self.wantRoom = key -- 4473
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 4474
end -- 4467
function Play.prototype.checkCarryGate(self) -- 4481
	if self.room.key == "checkpoint" then -- 4481
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 4481
			self.carryCartAxle = self.cartAxle -- 4484
			self.carryCartDocked = self.cartDocked -- 4485
			self:requestRoom("gate", "检查站出口") -- 4486
			self:flashSet("出检查站 · 城门", 1.2) -- 4487
		end -- 4487
		return -- 4489
	end -- 4489
	if self.room.key == "outside" then -- 4489
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 4489
			self.carryCartAxle = self.cartAxle -- 4495
			self.carryCartDocked = self.cartDocked -- 4496
			self:requestRoom("village", "墙根走完") -- 4497
			self:flashSet("墙根走完 · 进村口", 1.2) -- 4498
		end -- 4498
	end -- 4498
end -- 4481
function Play.prototype.aimAt(self, wx, wy) -- 4505
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 4506
	self.aimX = s.x -- 4507
	self.aimY = s.y -- 4508
end -- 4505
function Play.prototype.shoot(self, a) -- 4511
	if self.isCampaign and self.reloadT > 0 then -- 4511
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 4513
		return -- 4514
	end -- 4514
	local ox = a.x + a.facing * 8 -- 4516
	local muzzleY = a.y + a.h * 0.72 -- 4517
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 4518
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4520
	local dx = aim.x - ox -- 4523
	local dy = aim.y - oy -- 4524
	local len = math.sqrt(dx * dx + dy * dy) -- 4525
	if len < 0.001 then -- 4525
		dx = a.facing -- 4527
		dy = 0 -- 4528
	else -- 4528
		dx = dx / len -- 4530
		dy = dy / len -- 4531
	end -- 4531
	if dx ~= 0 then -- 4531
		a.facing = dx > 0 and 1 or -1 -- 4534
	end -- 4534
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 4537
	local hitEnemy = self:raycastEnemies(ray) -- 4538
	local tEnemy = hitEnemy.t -- 4539
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 4540
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 4541
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 4542
	local tWall = solid.t -- 4543
	local rawEffect = self:consumeReloadEffect() -- 4545
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 4546
	local reloadEffect = rawEffect -- 4547
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 4549
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 4550
	self.trace = { -- 4552
		x0 = ox, -- 4552
		y0 = oy, -- 4552
		x1 = ox + dx * t, -- 4552
		y1 = oy + dy * t, -- 4552
		hit = hit -- 4552
	} -- 4552
	self.traceT = 0.12 -- 4553
	self:applyFireDanger(ox) -- 4554
	local killed = false -- 4555
	if hit then -- 4555
		local i = hitEnemy.index -- 4557
		local e = self.enemies[i + 1] -- 4558
		local impactY = oy + dy * tEnemy -- 4559
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 4560
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 4561
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 4561
			e.shieldHp = (e.shieldHp or 0) - 1 -- 4563
			e.hitT = 0.3 -- 4564
			self:flashSet( -- 4565
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 4565
				0.8 -- 4565
			) -- 4565
			self:emit("shotResolved", { -- 4566
				hit = true, -- 4567
				enemyIndex = i, -- 4567
				enemyX = e.x, -- 4567
				aimX = aim.x, -- 4567
				aimY = aim.y, -- 4567
				impactX = ox + dx * t, -- 4568
				impactY = oy + dy * t, -- 4568
				shield = true -- 4568
			}) -- 4568
			self:beginReload() -- 4570
			return -- 4571
		end -- 4571
		e.alive = false -- 4573
		e.hitT = 0.4 -- 4574
		killed = true -- 4575
		self:flashSet("命中", 0.6) -- 4576
		self:dropFor(e) -- 4577
		if reloadEffect == "light" and weaponFx == "light" then -- 4577
			self:blindNearby(e, 160, i) -- 4579
		end -- 4579
		if reloadEffect == "push" then -- 4579
			e.x = e.x + a.facing * 46 -- 4582
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4583
		elseif reloadEffect == "echo" then -- 4583
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 4585
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 4586
		elseif reloadEffect == "light" then -- 4586
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 4588
		end -- 4588
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 4588
		self:damageProp(solid.box, 1) -- 4591
	else -- 4591
		self:flashSet("打空", 0.35) -- 4593
	end -- 4593
	if self.isCampaign then -- 4593
		self:beginReload() -- 4596
	end -- 4596
	self:emit("shotResolved", { -- 4598
		hit = hit, -- 4599
		enemyIndex = hit and hitEnemy.index or -1, -- 4600
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 4601
		aimX = aim.x, -- 4602
		aimY = aim.y, -- 4603
		impactX = ox + dx * t, -- 4604
		impactY = oy + dy * t -- 4605
	}) -- 4605
end -- 4511
function Play.prototype.applyFireDanger(self, shotX) -- 4610
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 4610
		return -- 4612
	end -- 4612
	local dangerX = shotX -- 4614
	local best = -1 -- 4615
	local bestD = 1000000000 -- 4616
	local i = 0 -- 4617
	do -- 4617
		i = 0 -- 4618
		while i < #self.enemies do -- 4618
			do -- 4618
				local e = self.enemies[i + 1] -- 4619
				if not e.alive then -- 4619
					goto __continue765 -- 4621
				end -- 4621
				local d = math.abs(e.x - self.partner.x) -- 4623
				if d < bestD then -- 4623
					bestD = d -- 4625
					best = i -- 4626
				end -- 4626
			end -- 4626
			::__continue765:: -- 4626
			i = i + 1 -- 4618
		end -- 4618
	end -- 4618
	if best >= 0 then -- 4618
		dangerX = self.enemies[best + 1].x -- 4630
	end -- 4630
	local exposed = self:childExposed(dangerX) -- 4632
	local before = self.escort.fear -- 4633
	local dangerId = self.nextDangerId -- 4634
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 4635
	self.nextDangerId = self.nextDangerId + 1 -- 4636
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 4637
	if after > before then -- 4637
		self:flashSet( -- 4639
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 4639
			1 -- 4639
		) -- 4639
	elseif not exposed then -- 4639
		self:flashSet("枪声没够到她", 0.5) -- 4641
	end -- 4641
end -- 4610
function Play.prototype.childExposed(self, dangerX) -- 4646
	local c = self.partner -- 4647
	if not c.alive then -- 4647
		return false -- 4649
	end -- 4649
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 4649
		self.boxes, -- 4652
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 4652
	) then -- 4652
		return false -- 4653
	end -- 4653
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 4653
		return false -- 4656
	end -- 4656
	local toDanger = dangerX - c.x -- 4658
	local toPlayer = self.player.x - c.x -- 4659
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 4659
		return false -- 4662
	end -- 4662
	return true -- 4664
end -- 4646
function Play.prototype.raycastEnemies(self, ray) -- 4668
	local best = -1 -- 4669
	local bestI = -1 -- 4670
	do -- 4670
		local i = 0 -- 4671
		while i < #self.enemies do -- 4671
			do -- 4671
				local e = self.enemies[i + 1] -- 4672
				if not e.alive then -- 4672
					goto __continue779 -- 4674
				end -- 4674
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 4676
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 4677
				if t >= 0 and (best < 0 or t < best) then -- 4677
					best = t -- 4679
					bestI = i -- 4680
				end -- 4680
			end -- 4680
			::__continue779:: -- 4680
			i = i + 1 -- 4671
		end -- 4671
	end -- 4671
	return {t = best, index = bestI} -- 4683
end -- 4668
function Play.prototype.raycastWorld(self, ray) -- 4686
	return self:raycastSolid(ray).t -- 4687
end -- 4686
function Play.prototype.raycastSolid(self, ray) -- 4691
	local best = -1 -- 4692
	local bestBox = nil -- 4693
	for ____, box in ipairs(self.boxes) do -- 4694
		do -- 4694
			if box.broken == true or box.hidden == true then -- 4694
				goto __continue784 -- 4696
			end -- 4696
			local t = hitBox(ray, box) -- 4701
			if t > 2 and (best < 0 or t < best) then -- 4701
				best = t -- 4704
				bestBox = box -- 4705
			end -- 4705
		end -- 4705
		::__continue784:: -- 4705
	end -- 4705
	if ray.dy < 0 then -- 4705
		local t = -ray.y / ray.dy -- 4709
		if t >= 0 and (best < 0 or t < best) then -- 4709
			best = t -- 4711
			bestBox = nil -- 4712
		end -- 4712
	end -- 4712
	return {t = best, box = bestBox} -- 4715
end -- 4691
function Play.prototype.dropFor(self, e) -- 4719
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 4719
		return -- 4721
	end -- 4721
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 4721
		return -- 4724
	end -- 4724
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 4726
	local ____self_pickups_62 = self.pickups -- 4726
	____self_pickups_62[#____self_pickups_62 + 1] = { -- 4727
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 4728
		kind = e.drop, -- 4728
		x = e.x, -- 4728
		y = e.y, -- 4728
		depth = e.depth, -- 4729
		label = label .. " ×1" -- 4729
	} -- 4729
	self:log("掉落 " .. label) -- 4731
end -- 4719
function Play.prototype.damageProp(self, b, amount) -- 4735
	if b.breakable == nil or b.broken == true then -- 4735
		return -- 4737
	end -- 4737
	local ____b_breakable_63, ____hp_64 = b.breakable, "hp" -- 4737
	____b_breakable_63[____hp_64] = ____b_breakable_63[____hp_64] - amount -- 4739
	if b.breakable.hp > 0 then -- 4739
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 4741
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 4742
		return -- 4743
	end -- 4743
	b.broken = true -- 4745
	for ____, other in ipairs(self.boxes) do -- 4746
		if other.id ~= nil and other.id == b.id then -- 4746
			other.broken = true -- 4748
		end -- 4748
	end -- 4748
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 4751
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 4752
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 4753
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 4754
end -- 4735
function Play.prototype.slideDepth(self, a, distance) -- 4758
	a.depth = self:limitDepth(a, a.depth + distance) -- 4759
end -- 4758
function Play.prototype.limitDepth(self, a, target) -- 4762
	local road = self.room.depth -- 4763
	if road == nil or target == a.depth then -- 4763
		return a.depth -- 4765
	end -- 4765
	local next = math.max( -- 4767
		road.min, -- 4767
		math.min(road.max, target) -- 4767
	) -- 4767
	local half = a.w / 2 -- 4768
	for ____, b in ipairs(self.boxes) do -- 4769
		do -- 4769
			local footprint = b.depth -- 4770
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4770
				goto __continue802 -- 4775
			end -- 4775
			local front = footprint.min - ACTOR_DEPTH_HALF -- 4777
			local back = footprint.max + ACTOR_DEPTH_HALF -- 4778
			if a.depth <= front and next > front then -- 4778
				next = front -- 4780
			elseif a.depth >= back and next < back then -- 4780
				next = back -- 4782
			end -- 4782
		end -- 4782
		::__continue802:: -- 4782
	end -- 4782
	return next -- 4785
end -- 4762
function Play.prototype.slideX(self, a, dx) -- 4789
	local nx = a.x + dx -- 4790
	local half = a.w / 2 -- 4791
	local room = self.room -- 4792
	nx = math.max( -- 4793
		room.minX + half, -- 4793
		math.min(room.maxX - half, nx) -- 4793
	) -- 4793
	local i = 0 -- 4794
	do -- 4794
		i = 0 -- 4795
		while i < #self.boxes do -- 4795
			do -- 4795
				local b = self.boxes[i + 1] -- 4796
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4796
					goto __continue809 -- 4798
				end -- 4798
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4798
					goto __continue809 -- 4801
				end -- 4801
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4801
					goto __continue809 -- 4804
				end -- 4804
				if nx + half > b.x0 and nx - half < b.x1 then -- 4804
					if a.x <= b.x0 then -- 4804
						nx = b.x0 - half -- 4808
					elseif a.x >= b.x1 then -- 4808
						nx = b.x1 + half -- 4810
					else -- 4810
						nx = a.x -- 4812
					end -- 4812
				end -- 4812
			end -- 4812
			::__continue809:: -- 4812
			i = i + 1 -- 4795
		end -- 4795
	end -- 4795
	if self.room.key == "outside" and not self.cartDocked and a.y < CART_CLEAR - 0.001 then -- 4795
		local bx0 = math.max(room.arch.x0, self.cartAxle - CART_HALF) -- 4819
		local bx1 = math.min(room.arch.x1, self.cartAxle + CART_HALF) -- 4820
		if bx1 > bx0 and nx + half > bx0 and nx - half < bx1 then -- 4820
			if a.x <= bx0 then -- 4820
				nx = bx0 - half -- 4823
			elseif a.x >= bx1 then -- 4823
				nx = bx1 + half -- 4825
			else -- 4825
				nx = a.x -- 4827
			end -- 4827
		end -- 4827
	end -- 4827
	local arch = room.arch -- 4835
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 4835
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 4837
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 4837
			if a.x <= arch.x0 then -- 4837
				nx = arch.x0 - half -- 4840
			elseif a.x >= arch.x1 then -- 4840
				nx = arch.x1 + half -- 4842
			end -- 4842
		end -- 4842
	end -- 4842
	a.x = nx -- 4846
end -- 4789
function Play.prototype.fallY(self, a, dt) -- 4850
	a.vy = a.vy - ____exports.GRAVITY * dt -- 4851
	if a.vy < -900 then -- 4851
		a.vy = -900 -- 4853
	end -- 4853
	local ny = a.y + a.vy * dt -- 4855
	local half = a.w / 2 -- 4856
	if a.vy <= 0 then -- 4856
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 4859
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 4860
		if ny <= ground then -- 4860
			ny = ground -- 4862
			a.vy = 0 -- 4863
			a.onGround = true -- 4864
		else -- 4864
			a.onGround = false -- 4866
		end -- 4866
	else -- 4866
		a.onGround = false -- 4869
		local i = 0 -- 4870
		do -- 4870
			i = 0 -- 4871
			while i < #self.boxes do -- 4871
				do -- 4871
					local b = self.boxes[i + 1] -- 4872
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4872
						goto __continue833 -- 4874
					end -- 4874
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4874
						goto __continue833 -- 4877
					end -- 4877
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 4877
						goto __continue833 -- 4880
					end -- 4880
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 4880
						ny = b.y0 - a.h -- 4883
						a.vy = 0 -- 4884
					end -- 4884
				end -- 4884
				::__continue833:: -- 4884
				i = i + 1 -- 4871
			end -- 4871
		end -- 4871
	end -- 4871
	a.y = ny -- 4888
end -- 4850
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 4892
	if depth == nil then -- 4892
		depth = 0 -- 4892
	end -- 4892
	local g = -9999 -- 4893
	local i = 0 -- 4894
	do -- 4894
		i = 0 -- 4895
		while i < #self.floors do -- 4895
			local f = self.floors[i + 1] -- 4896
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 4896
				g = f.y1 -- 4898
			end -- 4898
			i = i + 1 -- 4895
		end -- 4895
	end -- 4895
	do -- 4895
		i = 0 -- 4901
		while i < #self.boxes do -- 4901
			do -- 4901
				local b = self.boxes[i + 1] -- 4902
				if b.broken == true or b.hidden == true or b.soft == true then -- 4902
					goto __continue843 -- 4904
				end -- 4904
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 4904
					g = b.y1 -- 4908
				end -- 4908
			end -- 4908
			::__continue843:: -- 4908
			i = i + 1 -- 4901
		end -- 4901
	end -- 4901
	return g -- 4911
end -- 4892
function Play.prototype.updateCamera(self, dt) -- 4914
	local p = self.player -- 4915
	local tx = p.x + p.facing * 30 -- 4916
	local ty = p.y + CAM_LOOK_UP -- 4917
	local k = math.min(1, CAM_FOLLOW * dt) -- 4918
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 4919
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 4920
end -- 4914
function Play.prototype.clampCamera(self, w, h) -- 4924
	local room = self.room -- 4925
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 4926
	local spanX = room.maxX - room.minX -- 4927
	if spanX <= halfW * 2 then -- 4927
		self.cam.x = (room.minX + room.maxX) / 2 -- 4929
	else -- 4929
		self.cam.x = math.max( -- 4931
			room.minX + halfW, -- 4931
			math.min(room.maxX - halfW, self.cam.x) -- 4931
		) -- 4931
	end -- 4931
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 4934
	local spanY = room.height -- 4935
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 4936
	if spanY <= halfH * 2 then -- 4936
		self.cam.y = camY -- 4938
	else -- 4938
		self.cam.y = math.max( -- 4940
			camY, -- 4940
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 4940
		) -- 4940
	end -- 4940
end -- 4924
function Play.prototype.flashSet(self, text, t) -- 4944
	self.flash = text -- 4945
	self.flashT = t -- 4946
end -- 4944
function Play.prototype.statusText(self) -- 4950
	local p = self.player -- 4951
	local parts = {} -- 4952
	local who = self.childMode and "小满" or "周戍" -- 4953
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 4954
	if self.room.key == "prologue" then -- 4954
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4957
		if self.phase == "prologue-wake" then -- 4957
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 4959
		elseif self.phase == "prologue-shadow" then -- 4959
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 4961
		elseif self.phase == "prologue-escape" then -- 4961
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 4963
		elseif self.phase == "prologue-hide" then -- 4963
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 4965
		elseif self.phase == "prologue-wait" then -- 4965
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 4967
		elseif self.phase == "prologue-give" then -- 4967
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 4969
		else -- 4969
			parts[#parts + 1] = "跟随" -- 4971
		end -- 4971
		if self.paused then -- 4971
			parts[#parts + 1] = "已暂停" -- 4974
		end -- 4974
		return table.concat(parts, " · ") -- 4976
	end -- 4976
	if self.room.key == "street" then -- 4976
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4979
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4980
		if self.paused then -- 4980
			parts[#parts + 1] = "已暂停" -- 4982
		end -- 4982
		return table.concat(parts, " · ") -- 4984
	end -- 4984
	if self.room.key == "gate" then -- 4984
		local ____temp_65 -- 4987
		if self.room.story == nil then -- 4987
			____temp_65 = nil -- 4987
		else -- 4987
			____temp_65 = self.room.story.gate -- 4987
		end -- 4987
		local g = ____temp_65 -- 4987
		if g ~= nil then -- 4987
			parts[#parts + 1] = self:gateLabel() -- 4989
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 4990
				0, -- 4991
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 4991
			))) .. " 秒" -- 4991
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4992
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4993
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 4994
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 4995
			if self.gateFailCount > 0 then -- 4995
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 4997
			end -- 4997
			if self.flash ~= "" then -- 4997
				parts[#parts + 1] = self.flash -- 5000
			end -- 5000
		end -- 5000
		if self.paused then -- 5000
			parts[#parts + 1] = "已暂停" -- 5004
		end -- 5004
		return table.concat(parts, " · ") -- 5006
	end -- 5006
	if self.room.key == "forest" then -- 5006
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5009
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5010
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5011
		if self.caughtT > 0 then -- 5011
			parts[#parts + 1] = "复位中" -- 5013
		end -- 5013
		if self.paused then -- 5013
			parts[#parts + 1] = "已暂停" -- 5016
		end -- 5016
		return table.concat(parts, " · ") -- 5018
	end -- 5018
	if self.room.key == "tower" then -- 5018
		if self.phase == "tower-wait" then -- 5018
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5022
		elseif self.phase == "tower-knock" then -- 5022
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5024
		elseif self.phase == "tower-enter" then -- 5024
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5026
		elseif self.phase == "tower-desk" then -- 5026
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5028
		elseif self.phase == "tower-given" then -- 5028
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5030
		else -- 5030
			parts[#parts + 1] = "片尾" -- 5032
		end -- 5032
		if self.paused then -- 5032
			parts[#parts + 1] = "已暂停" -- 5035
		end -- 5035
		return table.concat(parts, " · ") -- 5037
	end -- 5037
	if self.room.key == "village" then -- 5037
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5040
		if self.hasBottle then -- 5040
			parts[#parts + 1] = "有瓶" -- 5042
		elseif self.bottleFly ~= nil then -- 5042
			parts[#parts + 1] = "瓶在飞" -- 5044
		else -- 5044
			parts[#parts + 1] = "空手" -- 5046
		end -- 5046
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5048
		if self.scavChase then -- 5048
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5050
		end -- 5050
		if self.passed then -- 5050
			parts[#parts + 1] = "已过通行线" -- 5053
		end -- 5053
		if self.paused then -- 5053
			parts[#parts + 1] = "已暂停" -- 5056
		end -- 5056
		return table.concat(parts, " · ") -- 5058
	end -- 5058
	local isChild = self.childMode -- 5061
	if isChild then -- 5061
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5063
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5064
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5065
	else -- 5065
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5067
		if p.rollT > 0 then -- 5067
			parts[#parts + 1] = "翻滚中" -- 5069
		end -- 5069
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5071
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5072
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5073
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5074
	end -- 5074
	if self.checkpoint >= 0 then -- 5074
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5077
	end -- 5077
	if self.paused then -- 5077
		parts[#parts + 1] = "已暂停" -- 5080
	end -- 5080
	return table.concat(parts, " · ") -- 5082
end -- 4950
function Play.prototype.aliveEnemies(self) -- 5086
	local n = 0 -- 5087
	local i = 0 -- 5088
	do -- 5088
		i = 0 -- 5089
		while i < #self.enemies do -- 5089
			if self.enemies[i + 1].alive then -- 5089
				n = n + 1 -- 5091
			end -- 5091
			i = i + 1 -- 5089
		end -- 5089
	end -- 5089
	return n -- 5094
end -- 5086
function Play.prototype.threatened(self) -- 5099
	do -- 5099
		local i = 0 -- 5100
		while i < #self.enemies do -- 5100
			local e = self.enemies[i + 1] -- 5101
			if e.alive and e.warnT > 0 then -- 5101
				return true -- 5103
			end -- 5103
			i = i + 1 -- 5100
		end -- 5100
	end -- 5100
	return false -- 5106
end -- 5099
function Play.prototype.gateSecondsLeft(self) -- 5109
	local ____temp_66 -- 5110
	if self.room.story == nil then -- 5110
		____temp_66 = nil -- 5110
	else -- 5110
		____temp_66 = self.room.story.gate -- 5110
	end -- 5110
	local g = ____temp_66 -- 5110
	if g == nil then -- 5110
		return 0 -- 5112
	end -- 5112
	return math.max( -- 5114
		0, -- 5114
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5114
	) -- 5114
end -- 5109
function Play.prototype.gateLabel(self) -- 5117
	if self.phase == "gate-idle" then -- 5117
		return "待就位" -- 5119
	end -- 5119
	if self.phase == "gate-hold" then -- 5119
		return "守点中" -- 5122
	end -- 5122
	if self.phase == "gate-send" then -- 5122
		return "送别" -- 5125
	end -- 5125
	if self.phase == "gate-count" then -- 5125
		return "数数 " .. tostring(self.countTick) -- 5128
	end -- 5128
	return "她走" -- 5130
end -- 5117
function Play.prototype.dogLabel(self) -- 5134
	if self.dogState == "ear" then -- 5134
		return "转耳" -- 5136
	end -- 5136
	if self.dogState == "chase" then -- 5136
		return "追" -- 5139
	end -- 5139
	if self.dogState == "sniff" then -- 5139
		return "停" -- 5142
	end -- 5142
	if self.dogState == "back" then -- 5142
		return "回线" -- 5145
	end -- 5145
	return "巡逻" -- 5147
end -- 5134
function Play.prototype.doorXOf(self) -- 5150
	local ____temp_67 -- 5151
	if self.room.story == nil then -- 5151
		____temp_67 = nil -- 5151
	else -- 5151
		____temp_67 = self.room.story.tower -- 5151
	end -- 5151
	local t = ____temp_67 -- 5151
	return t == nil and 0 or t.doorX -- 5152
end -- 5150
function Play.prototype.scavLabel(self) -- 5156
	if self.scavState == "chase" then -- 5156
		return "追" -- 5158
	end -- 5158
	if self.scavState == "turn" then -- 5158
		return "转头" -- 5161
	end -- 5161
	if self.scavState == "walk" then -- 5161
		return "赶来" -- 5164
	end -- 5164
	if self.scavState == "stall" then -- 5164
		return "停住" -- 5167
	end -- 5167
	if self.scavState == "back" then -- 5167
		return "回位" -- 5170
	end -- 5170
	return "巡逻" -- 5172
end -- 5156
function Play.prototype.hintText(self) -- 5176
	if self.paused then -- 5176
		return "Esc 继续 · R 重置" -- 5178
	end -- 5178
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5178
		if self:threatened() then -- 5178
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5184
		end -- 5184
		if self.coverHug then -- 5184
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5187
		end -- 5187
		if self.coverNear then -- 5187
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5190
		end -- 5190
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5192
	end -- 5192
	if self.flash ~= "" then -- 5192
		return self.flash -- 5195
	end -- 5195
	if self.room.key == "prologue" then -- 5195
		if self.phase == "prologue-wake" then -- 5195
			return "父亲在门外唤 · 小满睁眼" -- 5199
		end -- 5199
		if self.phase == "prologue-shadow" then -- 5199
			return "墙上两道人影 · 碗滚到脚边" -- 5202
		end -- 5202
		if self.phase == "prologue-escape" then -- 5202
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5205
		end -- 5205
		if self.phase == "prologue-hide" then -- 5205
			return "柜门合上 · 屏住呼吸" -- 5208
		end -- 5208
		if self.phase == "prologue-wait" then -- 5208
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5211
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5212
		end -- 5212
		if self.phase == "prologue-give" then -- 5212
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 5215
		end -- 5215
		return "她跟着你了 · 两人一起走到门口 680" -- 5217
	end -- 5217
	if self.room.key == "street" then -- 5217
		if self:aliveEnemies() > 0 then -- 5217
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5221
		end -- 5221
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5223
	end -- 5223
	if self.room.key == "gate" then -- 5223
		local ____temp_68 -- 5226
		if self.room.story == nil then -- 5226
			____temp_68 = nil -- 5226
		else -- 5226
			____temp_68 = self.room.story.gate -- 5226
		end -- 5226
		local g = ____temp_68 -- 5226
		if g ~= nil then -- 5226
			if self.phase == "gate-idle" then -- 5226
				if self.gateNeedConfirm then -- 5226
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5230
				end -- 5230
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5232
			end -- 5232
			if self.phase == "gate-hold" then -- 5232
				if self.coveredFlash > 0 then -- 5232
					return "掩体挡下了这一枪 · 别露头" -- 5236
				end -- 5236
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5238
			end -- 5238
			if self.phase == "gate-send" then -- 5238
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5241
			end -- 5241
			if self.phase == "gate-count" then -- 5241
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5241
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5245
				end -- 5245
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5247
			end -- 5247
			return "她自己走 · 跟着出城门 1120" -- 5249
		end -- 5249
	end -- 5249
	if self.room.key == "forest" then -- 5249
		if self.dogState == "chase" then -- 5249
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5254
		end -- 5254
		if self.dogState == "ear" then -- 5254
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5257
		end -- 5257
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5259
	end -- 5259
	if self.room.key == "tower" then -- 5259
		if self.phase == "tower-wait" then -- 5259
			return "走到门前 445 点一次 E 敲两下" -- 5263
		end -- 5263
		if self.phase == "tower-knock" then -- 5263
			return "敲两下 · 等门开" -- 5266
		end -- 5266
		if self.phase == "tower-given" then -- 5266
			return "递交针套和纸条 · 看登记簿最后一行" -- 5269
		end -- 5269
		return "片尾 · 点 E 再玩一次，回到序章" -- 5271
	end -- 5271
	if self.room.key == "village" then -- 5271
		if self.bottleFly ~= nil then -- 5271
			return "等瓶子落地 · 触地才发声" -- 5275
		end -- 5275
		if self.hasBottle then -- 5275
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5278
		end -- 5278
		if self.passed then -- 5278
			return "已过第一院 · R 重置可再来一遍" -- 5281
		end -- 5281
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5283
	end -- 5283
	if self.room.key == "outside" then -- 5283
		if self.focusCart then -- 5283
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5287
		end -- 5287
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5289
	end -- 5289
	if self.escort.state == "frozen" then -- 5289
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5289
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5293
		end -- 5293
		return "小满吓住了 · 走过去，靠近再点 E" -- 5295
	end -- 5295
	if self.escort.state == "calming" then -- 5295
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5298
	end -- 5298
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5300
end -- 5176
function Play.prototype.draw(self, draw, w, h) -- 5305
	self.viewW = w -- 5306
	self.viewH = h -- 5307
	self.view = ____exports.computeViewport(w, h) -- 5308
	self:clampCamera(w, h) -- 5309
	draw:clear() -- 5310
	draw:drawRect( -- 5312
		Rect(0, 0, w, h), -- 5312
		BG_VOID -- 5312
	) -- 5312
	local box = self:canvasRect(w, h) -- 5313
	draw:drawRect(box, BG_FAR) -- 5314
	draw:drawRect( -- 5315
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 5315
		BG_MID -- 5315
	) -- 5315
	self:drawFloors(draw, w, h) -- 5317
	self:drawSolids(draw, w, h) -- 5318
	self:drawZones(draw, w, h) -- 5319
	self:drawArch(draw, w, h) -- 5320
	self:drawCart(draw, w, h) -- 5321
	self:drawCampaignProps(draw, w, h) -- 5322
	self:drawActors(draw, w, h) -- 5323
	self:drawTrace(draw, w, h) -- 5324
	self:drawAim(draw, w, h) -- 5325
end -- 5305
function Play.prototype.canvasRect(self, w, h) -- 5329
	local v = self.view -- 5330
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 5331
end -- 5329
function Play.prototype.px(self, n) -- 5335
	return n * self.view.zoom -- 5336
end -- 5335
function Play.prototype.sx(self, wx, w) -- 5340
	local v = self.view -- 5341
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 5342
	return v.ox + lx * v.zoom -- 5343
end -- 5340
function Play.prototype.sy(self, wy, h) -- 5347
	local v = self.view -- 5348
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 5349
	return v.oy + ly * v.zoom -- 5350
end -- 5347
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 5353
	local px0 = self:sx(x0, w) -- 5354
	local px1 = self:sx(x1, w) -- 5355
	local py0 = self:sy(y0, h) -- 5356
	local py1 = self:sy(y1, h) -- 5357
	if px1 <= px0 or py1 <= py0 then -- 5357
		return -- 5359
	end -- 5359
	draw:drawRect( -- 5361
		Rect(px0, py0, px1 - px0, py1 - py0), -- 5361
		color -- 5361
	) -- 5361
end -- 5353
function Play.prototype.drawFloors(self, draw, w, h) -- 5364
	local i = 0 -- 5365
	do -- 5365
		i = 0 -- 5366
		while i < #self.room.floors do -- 5366
			local f = self.room.floors[i + 1] -- 5367
			local ____temp_69 -- 5368
			if f.y == 0 then -- 5368
				____temp_69 = self.room.depth -- 5368
			else -- 5368
				____temp_69 = nil -- 5368
			end -- 5368
			local road = ____temp_69 -- 5368
			local y = self:sy(f.y + (road and road.min or 0), h) -- 5369
			local x0 = self:sx(f.x0, w) -- 5370
			local x1 = self:sx(f.x1, w) -- 5371
			local deck = self:px(5) -- 5372
			if road ~= nil then -- 5372
				local back = self:sy(f.y + road.max, h) -- 5374
				draw:drawRect( -- 5375
					Rect(x0, y, x1 - x0, back - y), -- 5375
					FLOOR_DECK, -- 5375
					self:px(1), -- 5375
					SOLID_EDGE -- 5375
				) -- 5375
			end -- 5375
			draw:drawRect( -- 5377
				Rect(x0, y - deck, x1 - x0, deck), -- 5377
				FLOOR_DECK -- 5377
			) -- 5377
			draw:drawSegment( -- 5378
				Vec2(x0, y), -- 5378
				Vec2(x1, y), -- 5378
				self:px(1), -- 5378
				GROUND -- 5378
			) -- 5378
			i = i + 1 -- 5366
		end -- 5366
	end -- 5366
end -- 5364
function Play.prototype.drawSolids(self, draw, w, h) -- 5382
	local i = 0 -- 5383
	do -- 5383
		i = 0 -- 5384
		while i < #self.boxes do -- 5384
			do -- 5384
				local b = self.boxes[i + 1] -- 5385
				if b.id == "braced_shield" or b.hidden == true then -- 5385
					goto __continue974 -- 5387
				end -- 5387
				if b.broken == true then -- 5387
					if b.breakable ~= nil then -- 5387
						local gy = self:sy(b.y0, h) -- 5392
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 5393
						local k = 0 -- 5394
						do -- 5394
							k = 0 -- 5395
							while k < 3 do -- 5395
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 5396
								draw:drawSegment( -- 5397
									Vec2( -- 5397
										gx - self:px(4), -- 5397
										gy + self:px(k % 2) -- 5397
									), -- 5397
									Vec2( -- 5397
										gx + self:px(5), -- 5397
										gy + self:px(k % 2) -- 5397
									), -- 5397
									self:px(1), -- 5397
									rgb -- 5397
								) -- 5397
								k = k + 1 -- 5395
							end -- 5395
						end -- 5395
					end -- 5395
					goto __continue974 -- 5400
				end -- 5400
				local ____opt_72 = b.depth -- 5400
				local front = ____opt_72 and ____opt_72.min or 0 -- 5402
				local ____opt_74 = b.depth -- 5402
				local back = ____opt_74 and ____opt_74.max or 0 -- 5403
				local fill = SOLID_FILL -- 5404
				local line = SOLID_EDGE -- 5405
				if b.soft == true then -- 5405
					fill = SOFT -- 5407
					line = SOFT_LINE -- 5408
				elseif b.breakable ~= nil then -- 5408
					line = DANGER_LINE -- 5410
					fill = Color(0.3, 0.24, 0.16, 1) -- 5411
				elseif b.interact ~= nil then -- 5411
					line = PASS_LINE -- 5413
				end -- 5413
				self:drawBox( -- 5415
					draw, -- 5415
					w, -- 5415
					h, -- 5415
					b.x0, -- 5415
					b.x1, -- 5415
					b.y0 + front, -- 5415
					b.y1 + back, -- 5415
					fill -- 5415
				) -- 5415
				draw:drawSegment( -- 5416
					Vec2( -- 5416
						self:sx(b.x0, w), -- 5416
						self:sy(b.y1 + front, h) -- 5416
					), -- 5416
					Vec2( -- 5417
						self:sx(b.x1, w), -- 5417
						self:sy(b.y1 + front, h) -- 5417
					), -- 5417
					self:px(1), -- 5417
					line -- 5417
				) -- 5417
				if b.breakable ~= nil then -- 5417
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 5420
					local cyp = self:sy(b.y1 + front, h) -- 5421
					draw:drawSegment( -- 5422
						Vec2( -- 5422
							cxp - self:px(4), -- 5422
							cyp + self:px(1) -- 5422
						), -- 5422
						Vec2( -- 5422
							cxp + self:px(3), -- 5422
							cyp + self:px(5) -- 5422
						), -- 5422
						self:px(1), -- 5422
						line -- 5422
					) -- 5422
				end -- 5422
			end -- 5422
			::__continue974:: -- 5422
			i = i + 1 -- 5384
		end -- 5384
	end -- 5384
end -- 5382
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 5428
	local i = 0 -- 5429
	do -- 5429
		i = 0 -- 5430
		while i < #self.pickups do -- 5430
			do -- 5430
				local pk = self.pickups[i + 1] -- 5431
				if self.run.taken[pk.id] == true then -- 5431
					goto __continue986 -- 5433
				end -- 5433
				local gy = pk.y + (pk.depth or 0) -- 5435
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 5436
				draw:drawRect( -- 5437
					Rect( -- 5437
						self:sx(pk.x - 5, w), -- 5437
						self:sy(gy + 12 + bob, h), -- 5437
						self:px(10), -- 5437
						self:px(10) -- 5437
					), -- 5437
					Color(0.84, 0.7, 0.3, 1) -- 5438
				) -- 5438
				draw:drawSegment( -- 5439
					Vec2( -- 5439
						self:sx(pk.x - 5, w), -- 5439
						self:sy(gy + 12 + bob, h) -- 5439
					), -- 5439
					Vec2( -- 5440
						self:sx(pk.x + 5, w), -- 5440
						self:sy(gy + 12 + bob, h) -- 5440
					), -- 5440
					self:px(1), -- 5440
					Color(0.95, 0.86, 0.52, 1) -- 5440
				) -- 5440
			end -- 5440
			::__continue986:: -- 5440
			i = i + 1 -- 5430
		end -- 5430
	end -- 5430
	if self.bracedShield ~= nil then -- 5430
		local sh = self.bracedShield -- 5443
		draw:drawRect( -- 5444
			Rect( -- 5444
				self:sx(sh.x - sh.w / 2, w), -- 5444
				self:sy(sh.y, h), -- 5444
				self:px(sh.w), -- 5444
				self:px(sh.h) -- 5444
			), -- 5444
			Color(0.42, 0.4, 0.34, 1) -- 5445
		) -- 5445
		draw:drawSegment( -- 5446
			Vec2( -- 5446
				self:sx(sh.x - sh.w / 2, w), -- 5446
				self:sy(sh.y + sh.h, h) -- 5446
			), -- 5446
			Vec2( -- 5447
				self:sx(sh.x + sh.w / 2, w), -- 5447
				self:sy(sh.y + sh.h, h) -- 5447
			), -- 5447
			self:px(1), -- 5447
			Color(0.74, 0.72, 0.62, 1) -- 5447
		) -- 5447
	end -- 5447
end -- 5428
function Play.prototype.drawZones(self, draw, w, h) -- 5451
	local i = 0 -- 5452
	do -- 5452
		i = 0 -- 5453
		while i < #self.room.zones do -- 5453
			local z = self.room.zones[i + 1] -- 5454
			local fill = DANGER -- 5455
			local line = DANGER_LINE -- 5456
			if z.tint == 2 then -- 5456
				fill = SOFT -- 5458
				line = SOFT_LINE -- 5459
			elseif z.tint == 3 then -- 5459
				fill = BRICK -- 5461
				line = BRICK_LINE -- 5462
			elseif z.tint == 4 then -- 5462
				fill = PASS -- 5464
				line = PASS_LINE -- 5465
			end -- 5465
			self:drawBox( -- 5467
				draw, -- 5467
				w, -- 5467
				h, -- 5467
				z.x0, -- 5467
				z.x1, -- 5467
				z.y, -- 5467
				z.y + z.h, -- 5467
				fill -- 5467
			) -- 5467
			draw:drawSegment( -- 5468
				Vec2( -- 5468
					self:sx(z.x0, w), -- 5468
					self:sy(z.y, h) -- 5468
				), -- 5468
				Vec2( -- 5468
					self:sx(z.x0, w), -- 5468
					self:sy(z.y + z.h, h) -- 5468
				), -- 5468
				self:px(1), -- 5468
				line -- 5468
			) -- 5468
			draw:drawSegment( -- 5469
				Vec2( -- 5469
					self:sx(z.x1, w), -- 5469
					self:sy(z.y, h) -- 5469
				), -- 5469
				Vec2( -- 5469
					self:sx(z.x1, w), -- 5469
					self:sy(z.y + z.h, h) -- 5469
				), -- 5469
				self:px(1), -- 5469
				line -- 5469
			) -- 5469
			i = i + 1 -- 5453
		end -- 5453
	end -- 5453
end -- 5451
function Play.prototype.drawArch(self, draw, w, h) -- 5473
	local a = self.room.arch -- 5474
	if a.h <= 0 then -- 5474
		return -- 5476
	end -- 5476
	self:drawBox( -- 5478
		draw, -- 5478
		w, -- 5478
		h, -- 5478
		a.x0, -- 5478
		a.x1, -- 5478
		a.y, -- 5478
		a.y + a.h, -- 5478
		HOLE_FILL -- 5478
	) -- 5478
	draw:drawSegment( -- 5479
		Vec2( -- 5479
			self:sx(a.x0, w), -- 5479
			self:sy(a.y + a.h, h) -- 5479
		), -- 5479
		Vec2( -- 5479
			self:sx(a.x1, w), -- 5479
			self:sy(a.y + a.h, h) -- 5479
		), -- 5479
		self:px(1), -- 5479
		SOLID_EDGE -- 5479
	) -- 5479
	draw:drawSegment( -- 5480
		Vec2( -- 5480
			self:sx(a.x0, w), -- 5480
			self:sy(a.y, h) -- 5480
		), -- 5480
		Vec2( -- 5480
			self:sx(a.x0, w), -- 5480
			self:sy(a.y + a.h, h) -- 5480
		), -- 5480
		self:px(1), -- 5480
		SOLID_EDGE -- 5480
	) -- 5480
	draw:drawSegment( -- 5481
		Vec2( -- 5481
			self:sx(a.x1, w), -- 5481
			self:sy(a.y, h) -- 5481
		), -- 5481
		Vec2( -- 5481
			self:sx(a.x1, w), -- 5481
			self:sy(a.y + a.h, h) -- 5481
		), -- 5481
		self:px(1), -- 5481
		SOLID_EDGE -- 5481
	) -- 5481
end -- 5473
function Play.prototype.drawCart(self, draw, w, h) -- 5484
	local c = self.room.cart -- 5485
	if c.bodyW <= 0 then -- 5485
		return -- 5487
	end -- 5487
	drawCartShape( -- 5489
		draw, -- 5489
		self, -- 5489
		w, -- 5489
		h, -- 5489
		c, -- 5489
		self.cartAxle -- 5489
	) -- 5489
	draw:drawRect( -- 5490
		Rect( -- 5490
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 5490
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 5490
			self:px(2), -- 5490
			self:px(40) -- 5490
		), -- 5490
		STAND -- 5490
	) -- 5490
end -- 5484
function Play.prototype.drawActors(self, draw, w, h) -- 5493
	local p = self.player -- 5494
	local isChild = self.childMode -- 5495
	local footY = p.y + p.depth -- 5496
	if p.covered then -- 5496
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 5499
		draw:drawSegment( -- 5500
			Vec2( -- 5500
				self:sx(edge, w), -- 5500
				self:sy(footY + 8, h) -- 5500
			), -- 5500
			Vec2( -- 5500
				self:sx(edge, w), -- 5500
				self:sy(footY + p.h * 0.62, h) -- 5500
			), -- 5500
			self:px(2), -- 5500
			STAND -- 5500
		) -- 5500
		draw:drawSegment( -- 5502
			Vec2( -- 5502
				self:sx(p.x - 8, w), -- 5502
				self:sy(footY + p.h + 3, h) -- 5502
			), -- 5502
			Vec2( -- 5502
				self:sx(p.x + 8, w), -- 5502
				self:sy(footY + p.h + 3, h) -- 5502
			), -- 5502
			self:px(2), -- 5502
			STAND -- 5502
		) -- 5502
	elseif self.coverNear and not isChild then -- 5502
		draw:drawRect( -- 5505
			Rect( -- 5505
				self:sx(p.x - 3, w), -- 5505
				self:sy(footY + 1, h), -- 5505
				self:px(3), -- 5505
				self:px(3) -- 5505
			), -- 5505
			STAND -- 5505
		) -- 5505
	end -- 5505
	drawFigure( -- 5507
		draw, -- 5507
		self, -- 5507
		w, -- 5507
		h, -- 5507
		p, -- 5507
		isChild and CHILD_BODY or SOLDIER_BODY, -- 5507
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 5507
	) -- 5507
	local q = self.partner -- 5508
	if q.alive then -- 5508
		local childPartner = q.w == CHILD_W -- 5510
		drawFigure( -- 5511
			draw, -- 5511
			self, -- 5511
			w, -- 5511
			h, -- 5511
			q, -- 5511
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 5511
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 5511
		) -- 5511
	end -- 5511
	local i = 0 -- 5513
	do -- 5513
		i = 0 -- 5514
		while i < #self.enemies do -- 5514
			local e = self.enemies[i + 1] -- 5515
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 5516
			local enemyY = e.y + (e.depth or 0) -- 5517
			self:drawBox( -- 5518
				draw, -- 5518
				w, -- 5518
				h, -- 5518
				e.x - e.w / 2, -- 5518
				e.x + e.w / 2, -- 5518
				enemyY, -- 5518
				enemyY + e.h, -- 5518
				col -- 5518
			) -- 5518
			if e.alive then -- 5518
				local ef = p.x >= e.x and 1 or -1 -- 5520
				if e.kind == "shield" then -- 5520
					local sh = (e.shieldHp or 0) > 0 -- 5522
					draw:drawRect( -- 5523
						Rect( -- 5523
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 5523
							self:sy(enemyY, h), -- 5523
							self:px(6), -- 5523
							self:px(64) -- 5523
						), -- 5523
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 5524
					) -- 5524
				elseif e.kind == "breaker" then -- 5524
					draw:drawSegment( -- 5526
						Vec2( -- 5526
							self:sx(e.x + ef * 12, w), -- 5526
							self:sy(enemyY + 8, h) -- 5526
						), -- 5526
						Vec2( -- 5527
							self:sx(e.x + ef * 22, w), -- 5527
							self:sy(enemyY + 46, h) -- 5527
						), -- 5527
						self:px(3), -- 5527
						Color(0.5, 0.36, 0.22, 1) -- 5527
					) -- 5527
				end -- 5527
			end -- 5527
			if e.alive and e.warnT > 0 then -- 5527
				local gunX = self:sx(e.x, w) -- 5532
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 5533
				local aimX = self:sx(p.x, w) -- 5534
				local aimY = self:sy(footY + p.h * 0.55, h) -- 5535
				local seg = 8 -- 5536
				local s = 0 -- 5537
				do -- 5537
					s = 0 -- 5538
					while s < seg do -- 5538
						local t0 = s / seg -- 5539
						local t1 = (s + 1) / seg -- 5540
						draw:drawSegment( -- 5541
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 5542
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 5543
							self:px(1), -- 5544
							DANGER -- 5544
						) -- 5544
						s = s + 2 -- 5538
					end -- 5538
				end -- 5538
			end -- 5538
			i = i + 1 -- 5514
		end -- 5514
	end -- 5514
	local k = 0 -- 5549
	do -- 5549
		k = 0 -- 5550
		while k < #self.room.marks do -- 5550
			do -- 5550
				local m = self.room.marks[k + 1] -- 5551
				if m.kind ~= 0 then -- 5551
					goto __continue1012 -- 5553
				end -- 5553
				local on = self.checkpoint == m.x -- 5555
				local x = self:sx(m.x, w) -- 5556
				local y = self:sy(m.y, h) -- 5557
				draw:drawSegment( -- 5558
					Vec2(x, y), -- 5558
					Vec2( -- 5558
						x, -- 5558
						y + self:px(35) -- 5558
					), -- 5558
					self:px(1), -- 5558
					on and CHECK or INK_DIM -- 5558
				) -- 5558
				draw:drawDot( -- 5559
					Vec2( -- 5559
						x, -- 5559
						y + self:px(35) -- 5559
					), -- 5559
					self:px(2), -- 5559
					on and CHECK or INK_DIM -- 5559
				) -- 5559
			end -- 5559
			::__continue1012:: -- 5559
			k = k + 1 -- 5550
		end -- 5550
	end -- 5550
	local j = 0 -- 5563
	do -- 5563
		j = 0 -- 5564
		while j < #self.room.marks do -- 5564
			do -- 5564
				local m = self.room.marks[j + 1] -- 5565
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 5565
					goto __continue1015 -- 5567
				end -- 5567
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 5567
					goto __continue1015 -- 5571
				end -- 5571
				local col = STAND -- 5573
				if m.kind == 4 then -- 5573
					col = PASS_LINE -- 5575
				elseif m.kind == 5 then -- 5575
					col = BRICK_LINE -- 5577
				end -- 5577
				local mx = self:sx(m.x, w) -- 5579
				local my = self:sy(m.y, h) -- 5580
				draw:drawSegment( -- 5581
					Vec2(mx, my), -- 5581
					Vec2( -- 5581
						mx, -- 5581
						my + self:px(24) -- 5581
					), -- 5581
					self:px(1), -- 5581
					col -- 5581
				) -- 5581
			end -- 5581
			::__continue1015:: -- 5581
			j = j + 1 -- 5564
		end -- 5564
	end -- 5564
	local t = 0 -- 5584
	do -- 5584
		t = 0 -- 5585
		while t < #self.room.marks do -- 5585
			do -- 5585
				local m = self.room.marks[t + 1] -- 5586
				if m.kind ~= 6 then -- 5586
					goto __continue1021 -- 5588
				end -- 5588
				local mx = self:sx(m.x, w) -- 5590
				local my = self:sy(m.y, h) -- 5591
				draw:drawSegment( -- 5592
					Vec2(mx, my), -- 5592
					Vec2( -- 5592
						mx, -- 5592
						my + self:px(30) -- 5592
					), -- 5592
					self:px(1), -- 5592
					INK_DIM -- 5592
				) -- 5592
				self:drawBox( -- 5593
					draw, -- 5593
					w, -- 5593
					h, -- 5593
					m.x - 5, -- 5593
					m.x + 5, -- 5593
					m.y + 30, -- 5593
					m.y + 40, -- 5593
					CHECK -- 5593
				) -- 5593
			end -- 5593
			::__continue1021:: -- 5593
			t = t + 1 -- 5585
		end -- 5585
	end -- 5585
	if self.room.key == "village" then -- 5585
		self:drawVillage(draw, w, h) -- 5596
	end -- 5596
	if self.room.key == "forest" then -- 5596
		self:drawDog(draw, w, h) -- 5599
	end -- 5599
end -- 5493
function Play.prototype.drawDog(self, draw, w, h) -- 5604
	local x = self.dogX -- 5605
	self:drawBox( -- 5606
		draw, -- 5606
		w, -- 5606
		h, -- 5606
		x - 14, -- 5606
		x + 14, -- 5606
		0, -- 5606
		20, -- 5606
		SCAV_BODY -- 5606
	) -- 5606
	self:drawBox( -- 5607
		draw, -- 5607
		w, -- 5607
		h, -- 5607
		x - 10, -- 5607
		x - 2, -- 5607
		20, -- 5607
		30, -- 5607
		SCAV_BODY -- 5607
	) -- 5607
	self:drawBox( -- 5608
		draw, -- 5608
		w, -- 5608
		h, -- 5608
		x + 2, -- 5608
		x + 10, -- 5608
		20, -- 5608
		30, -- 5608
		SCAV_HEAD -- 5608
	) -- 5608
	if self.dogState == "ear" or self.dogState == "chase" then -- 5608
		draw:drawSegment( -- 5610
			Vec2( -- 5610
				self:sx(x, w), -- 5610
				self:sy(30, h) -- 5610
			), -- 5610
			Vec2( -- 5611
				self:sx(x, w), -- 5611
				self:sy(40, h) -- 5611
			), -- 5611
			self:px(1), -- 5611
			DANGER -- 5611
		) -- 5611
	end -- 5611
end -- 5604
function Play.prototype.drawVillage(self, draw, w, h) -- 5616
	local bottle = self.room.bottle -- 5617
	if bottle ~= nil then -- 5617
		self:drawBox( -- 5619
			draw, -- 5619
			w, -- 5619
			h, -- 5619
			bottle.x - 14, -- 5619
			bottle.x + 14, -- 5619
			0, -- 5619
			64, -- 5619
			SOLID_FILL -- 5619
		) -- 5619
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 5619
			self:drawBottle( -- 5621
				draw, -- 5621
				w, -- 5621
				h, -- 5621
				bottle.x, -- 5621
				64 -- 5621
			) -- 5621
		end -- 5621
	end -- 5621
	self:drawBox( -- 5625
		draw, -- 5625
		w, -- 5625
		h, -- 5625
		300, -- 5625
		420, -- 5625
		44, -- 5625
		50, -- 5625
		FLOOR_DECK -- 5625
	) -- 5625
	self:drawBox( -- 5626
		draw, -- 5626
		w, -- 5626
		h, -- 5626
		300, -- 5626
		306, -- 5626
		0, -- 5626
		44, -- 5626
		FLOOR_DECK -- 5626
	) -- 5626
	self:drawBox( -- 5627
		draw, -- 5627
		w, -- 5627
		h, -- 5627
		414, -- 5627
		420, -- 5627
		0, -- 5627
		44, -- 5627
		FLOOR_DECK -- 5627
	) -- 5627
	local s = self.room.scavenger -- 5629
	if s ~= nil then -- 5629
		local sx0 = self.scavX -- 5631
		self:drawBox( -- 5632
			draw, -- 5632
			w, -- 5632
			h, -- 5632
			sx0 - 12, -- 5632
			sx0 + 12, -- 5632
			0, -- 5632
			s.h - 14, -- 5632
			SCAV_BODY -- 5632
		) -- 5632
		self:drawBox( -- 5633
			draw, -- 5633
			w, -- 5633
			h, -- 5633
			sx0 - 7, -- 5633
			sx0 + 7, -- 5633
			s.h - 14, -- 5633
			s.h, -- 5633
			SCAV_HEAD -- 5633
		) -- 5633
		if self.scavState == "turn" then -- 5633
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 5635
			draw:drawSegment( -- 5636
				Vec2( -- 5636
					self:sx(sx0, w), -- 5636
					self:sy(s.h - 6, h) -- 5636
				), -- 5636
				Vec2( -- 5636
					self:sx(fx, w), -- 5636
					self:sy(s.h - 6, h) -- 5636
				), -- 5636
				self:px(1), -- 5636
				INK -- 5636
			) -- 5636
		end -- 5636
	end -- 5636
	if self.hasBottle then -- 5636
		local p = self.player -- 5641
		self:drawBottle( -- 5642
			draw, -- 5642
			w, -- 5642
			h, -- 5642
			p.x + p.facing * 10, -- 5642
			p.y + p.h * 0.62 -- 5642
		) -- 5642
	end -- 5642
	if self.bottleFly ~= nil then -- 5642
		self:drawBottle( -- 5645
			draw, -- 5645
			w, -- 5645
			h, -- 5645
			self.bottleFly.x, -- 5645
			self.bottleFly.y -- 5645
		) -- 5645
	end -- 5645
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 5645
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 5648
		draw:drawCircle( -- 5649
			Vec2( -- 5649
				self:sx(self.bottleLandX, w), -- 5649
				self:sy(0, h) -- 5649
			), -- 5649
			self:px(r / ____exports.UNITS_PER_PX), -- 5649
			BRICK_LINE -- 5649
		) -- 5649
	end -- 5649
end -- 5616
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 5653
	self:drawBox( -- 5654
		draw, -- 5654
		w, -- 5654
		h, -- 5654
		x - 3, -- 5654
		x + 3, -- 5654
		y - 10, -- 5654
		y, -- 5654
		BOTTLE -- 5654
	) -- 5654
end -- 5653
function Play.prototype.drawTrace(self, draw, w, h) -- 5657
	local t = self.trace -- 5658
	if t == nil or self.traceT <= 0 then -- 5658
		return -- 5660
	end -- 5660
	draw:drawSegment( -- 5662
		Vec2( -- 5663
			self:sx(t.x0, w), -- 5663
			self:sy(t.y0, h) -- 5663
		), -- 5663
		Vec2( -- 5664
			self:sx(t.x1, w), -- 5664
			self:sy(t.y1, h) -- 5664
		), -- 5664
		self:px(1), -- 5665
		t.hit and AIM_HIT or INK_DIM -- 5665
	) -- 5665
end -- 5657
function Play.prototype.drawAim(self, draw, w, h) -- 5668
	local v = self.view -- 5670
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 5671
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 5672
	local dot = self:px(1) -- 5673
	local arm = self:px(3) -- 5674
	local gap = self:px(1) -- 5675
	draw:drawSegment( -- 5676
		Vec2(gx - arm - gap, gy), -- 5676
		Vec2(gx - gap, gy), -- 5676
		dot / 2, -- 5676
		AIM -- 5676
	) -- 5676
	draw:drawSegment( -- 5677
		Vec2(gx + gap, gy), -- 5677
		Vec2(gx + arm + gap, gy), -- 5677
		dot / 2, -- 5677
		AIM -- 5677
	) -- 5677
	draw:drawSegment( -- 5678
		Vec2(gx, gy - arm - gap), -- 5678
		Vec2(gx, gy - gap), -- 5678
		dot / 2, -- 5678
		AIM -- 5678
	) -- 5678
	draw:drawSegment( -- 5679
		Vec2(gx, gy + gap), -- 5679
		Vec2(gx, gy + arm + gap), -- 5679
		dot / 2, -- 5679
		AIM -- 5679
	) -- 5679
	if self.room.key == "village" and self.hasBottle then -- 5679
		local p = self.player -- 5683
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 5685
		local dir = ____end.x >= p.x and 1 or -1 -- 5686
		local x0 = p.x + dir * 10 -- 5687
		local y0 = p.y + p.h * 0.7 -- 5688
		local T = BOTTLE_FLY_TIME -- 5689
		local vx = (____end.x - x0) / T -- 5690
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 5691
		local pxr = x0 -- 5692
		local pyr = y0 -- 5693
		local t = 1 -- 5694
		do -- 5694
			t = 1 -- 5695
			while t <= 12 do -- 5695
				local tt = t / 12 * T -- 5696
				local nx = x0 + vx * tt -- 5697
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 5698
				draw:drawSegment( -- 5699
					Vec2( -- 5699
						self:sx(pxr, w), -- 5699
						self:sy(pyr, h) -- 5699
					), -- 5699
					Vec2( -- 5699
						self:sx(nx, w), -- 5699
						self:sy(ny, h) -- 5699
					), -- 5699
					self:px(1) / 2, -- 5699
					BOTTLE -- 5699
				) -- 5699
				pxr = nx -- 5700
				pyr = ny -- 5701
				t = t + 1 -- 5695
			end -- 5695
		end -- 5695
		draw:drawCircle( -- 5703
			Vec2( -- 5703
				self:sx(____end.x, w), -- 5703
				self:sy(____end.y + 2, h) -- 5703
			), -- 5703
			self:px(2), -- 5703
			BOTTLE -- 5703
		) -- 5703
	end -- 5703
end -- 5668
return ____exports -- 5668