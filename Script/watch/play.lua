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
function makeActor(room, index) -- 5931
	local sp = room.spawns -- 5932
	if index < 0 or index >= #sp then -- 5932
		return { -- 5934
			x = 0, -- 5934
			y = 0, -- 5934
			depth = 0, -- 5934
			depthSpeed = 0, -- 5934
			vx = 0, -- 5934
			vy = 0, -- 5934
			w = CHILD_W, -- 5934
			h = CHILD_H, -- 5934
			onGround = true, -- 5934
			facing = 1, -- 5934
			crouch = false, -- 5934
			rollT = 0, -- 5934
			covered = false, -- 5934
			alive = false -- 5934
		} -- 5934
	end -- 5934
	local s = sp[index + 1] -- 5936
	local child = s.h < SOLDIER_H -- 5937
	local ground = room.depth -- 5938
	local depth = ground == nil and 0 or math.max( -- 5939
		ground.min, -- 5939
		math.min(ground.max, s.depth or 0) -- 5939
	) -- 5939
	return { -- 5940
		x = s.x, -- 5941
		y = s.y, -- 5941
		depth = depth, -- 5941
		depthSpeed = 0, -- 5941
		vx = 0, -- 5941
		vy = 0, -- 5941
		w = child and CHILD_W or SOLDIER_W, -- 5942
		h = child and CHILD_H or SOLDIER_H, -- 5943
		onGround = true, -- 5944
		facing = 1, -- 5944
		crouch = false, -- 5944
		rollT = 0, -- 5944
		covered = false, -- 5944
		alive = true -- 5944
	} -- 5944
end -- 5944
function drawFigure(draw, play, w, h, a, body, head) -- 5948
	if not a.alive then -- 5948
		return -- 5950
	end -- 5950
	local x0 = a.x - a.w / 2 -- 5952
	local x1 = a.x + a.w / 2 -- 5953
	local y0 = a.y + a.depth * DEPTH_Y_SCALE -- 5954
	local y1 = y0 + a.h -- 5955
	play:drawBox( -- 5956
		draw, -- 5956
		w, -- 5956
		h, -- 5956
		x0, -- 5956
		x1, -- 5956
		y0, -- 5956
		y1 - a.h * 0.26, -- 5956
		body -- 5956
	) -- 5956
	play:drawBox( -- 5957
		draw, -- 5957
		w, -- 5957
		h, -- 5957
		x0 + 2, -- 5957
		x1 - 2, -- 5957
		y1 - a.h * 0.26, -- 5957
		y1, -- 5957
		head -- 5957
	) -- 5957
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 5959
	play:drawBox( -- 5960
		draw, -- 5960
		w, -- 5960
		h, -- 5960
		eyeX, -- 5960
		eyeX + 4, -- 5960
		y1 - a.h * 0.14, -- 5960
		y1 - a.h * 0.08, -- 5960
		INK -- 5960
	) -- 5960
end -- 5960
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5964
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5965
end -- 5964
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5972
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5973
end -- 5972
function rayInterval(origin, direction, min, max) -- 5980
	if direction == 0 then -- 5980
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5982
	end -- 5982
	local a = (min - origin) / direction -- 5984
	local b = (max - origin) / direction -- 5985
	return { -- 5986
		min = math.min(a, b), -- 5986
		max = math.max(a, b) -- 5986
	} -- 5986
end -- 5986
function hitBox(ray, box) -- 5990
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5991
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5992
	local enter = math.max(0, x.min, y.min) -- 5993
	local leave = math.min(99999, x.max, y.max) -- 5994
	if box.depth ~= nil then -- 5994
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5996
		enter = math.max(enter, depth.min) -- 5997
		leave = math.min(leave, depth.max) -- 5998
	end -- 5998
	return leave >= enter and enter or -1 -- 6000
end -- 6000
function drawCartShape(draw, play, w, h, c, axleX) -- 6003
	local half = c.bodyW / 2 -- 6004
	local x0 = axleX - half -- 6005
	local x1 = axleX + half -- 6006
	local axleY = c.baseY + (c.depth or 0) * DEPTH_Y_SCALE + c.wheelR -- 6007
	play:drawBox( -- 6008
		draw, -- 6008
		w, -- 6008
		h, -- 6008
		x0, -- 6008
		x1, -- 6008
		axleY, -- 6008
		axleY + c.bodyH, -- 6008
		CART_FILL -- 6008
	) -- 6008
	draw:drawCircle( -- 6009
		Vec2( -- 6009
			play:sx(x0 + c.bodyW * 0.28, w), -- 6009
			play:sy(axleY, h) -- 6009
		), -- 6009
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6009
		Color(52, 50, 48, 255) -- 6009
	) -- 6009
	draw:drawCircle( -- 6010
		Vec2( -- 6010
			play:sx(x1 - c.bodyW * 0.28, w), -- 6010
			play:sy(axleY, h) -- 6010
		), -- 6010
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6010
		Color(52, 50, 48, 255) -- 6010
	) -- 6010
	local cx = c.clothSide < 0 and x0 or x1 -- 6011
	play:drawBox( -- 6012
		draw, -- 6012
		w, -- 6012
		h, -- 6012
		cx - 10, -- 6012
		cx + 10, -- 6012
		axleY + c.bodyH, -- 6012
		axleY + c.bodyH + 18, -- 6012
		CLOTH -- 6012
	) -- 6012
end -- 6012
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
function Play.prototype.____constructor(self, room, resume, run) -- 661
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
	self.equippedWeapon = "standard_gun" -- 563
	self.craftBench = { -- 565
		active = false, -- 566
		firstCraftDone = false, -- 567
		justCraftedTimer = 0, -- 568
		inventory = {}, -- 569
		recipes = {}, -- 570
		equippedWeapon = "standard_gun" -- 571
	} -- 571
	self.handledCraftRequests = {} -- 574
	self.benchReach = 48 -- 576
	self.pickups = {} -- 580
	self.reloadT = 0 -- 582
	self.objectiveDone = false -- 586
	self.hint = "" -- 588
	self.roomStartTick = 0 -- 590
	self.cartHitT = 0 -- 592
	self.cartExposed = false -- 593
	self.storyRoute = "" -- 597
	self.storySettled = false -- 599
	self.hpAtGate = -1 -- 601
	self.maxHpAtGate = -1 -- 602
	self.handTicks = 0 -- 604
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 606
	self.handArmed = false -- 608
	self.handDone = false -- 610
	self.lineSaid = false -- 611
	self.tied = false -- 613
	self.pathDone = false -- 615
	self.carryOn = false -- 617
	self.escortDone = false -- 619
	self.escapeDuration = ____exports.PROLOGUE_ESCAPE_TICKS / 60 -- 623
	self.escapeRemaining = 0 -- 625
	self.escapeRetryCount = 0 -- 627
	self.introTick = 0 -- 629
	self.reloadOpen = false -- 633
	self.reloadAnswerTicks = 0 -- 635
	self.reloadWorldTicks = 0 -- 637
	self.reloadPath = {RELOAD_START} -- 639
	self.reloadPendingEffect = "" -- 641
	self.reloadTryCount = 0 -- 643
	self.paused = false -- 645
	self.ticks = 0 -- 647
	self.view = {zoom = 1, ox = 0, oy = 0} -- 649
	self.ox = 0 -- 651
	self.aimX = 0 -- 653
	self.aimY = 0 -- 654
	self.viewW = 0 -- 656
	self.viewH = 0 -- 657
	self.ox = room.originX -- 663
	self.room = withOrigin(room) -- 664
	local wr = self.room -- 665
	self.run = run or createRun() -- 666
	self.inventory = self.run.inventory -- 667
	self.archive = self.run.archive -- 668
	self.equippedWeapon = self.run.story.craftedWeapon == "" and "standard_gun" or self.run.story.craftedWeapon -- 669
	self.isCampaign = wr.campaign ~= nil -- 670
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 671
	self:buildWorld() -- 672
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 675
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 677
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 678
	local soloRoom = wr.key == "museum" -- 680
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 681
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 682
	self.player = makeActor(wr, playerIdx) -- 683
	self.partner = makeActor(wr, partnerIdx) -- 684
	self.phase = phaseOf(wr.key) -- 685
	if soloRoom then -- 685
		local mp = self.archive.museumPhase -- 688
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 689
	end -- 689
	if wr.story ~= nil then -- 689
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 695
	end -- 695
	self.cam.x = self.player.x -- 697
	self.cam.y = self.player.y + CAM_LOOK_UP -- 698
	self.cartAxle = wr.cart.startX -- 699
	self.escort = __TS__New( -- 700
		Escort, -- 700
		safeAnchorX(wr.marks) -- 700
	) -- 700
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 701
	if self.isCampaign then -- 701
		self:setupCampaign() -- 703
	else -- 703
		self:buildEnemies() -- 705
	end -- 705
	if resume ~= nil and resume.checkpoint > 0 then -- 705
		self.checkpoint = resume.checkpoint -- 709
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 709
			self.cartAxle = self.room.cart.endX -- 711
			self.cartDocked = true -- 712
			self.player.x = self.ox + 380 -- 715
			self.player.y = 0 -- 716
			self.player.vy = 0 -- 717
			self.player.onGround = true -- 718
			self.cam.x = self.player.x -- 719
			self.cam.y = self.player.y + CAM_LOOK_UP -- 720
		end -- 720
	end -- 720
	self:restoreStory() -- 723
end -- 661
function Play.prototype.recipeViews(self) -- 736
	local out = {} -- 737
	local i = 0 -- 738
	do -- 738
		i = 0 -- 739
		while i < #CRAFT_RECIPES do -- 739
			local r = CRAFT_RECIPES[i + 1] -- 740
			local cost = {} -- 741
			if r.cost.wood ~= nil then -- 741
				cost.wood = r.cost.wood -- 743
			end -- 743
			if r.cost.bell ~= nil then -- 743
				cost.bell = r.cost.bell -- 746
			end -- 746
			out[#out + 1] = { -- 748
				id = r.id, -- 749
				name = r.name, -- 750
				desc = r.desc, -- 751
				enhancedEffect = r.enhancedEffect, -- 752
				cost = cost, -- 753
				crafted = self.run.story.craftedWeapon == r.id -- 754
			} -- 754
			i = i + 1 -- 739
		end -- 739
	end -- 739
	if self.archive.artifactOwned then -- 739
		out[#out + 1] = { -- 759
			id = ARTIFACT_WEAPON_ID, -- 760
			name = weaponNameOf(ARTIFACT_WEAPON_ID), -- 761
			desc = "井底拾取彩蛋 · 男主线移动留下冷白微金轨迹残影", -- 762
			enhancedEffect = "light", -- 763
			cost = {}, -- 764
			crafted = true -- 765
		} -- 765
	end -- 765
	return out -- 768
end -- 736
function Play.prototype.syncCraftBench(self) -- 772
	local view = self.craftBench -- 773
	local inv = self.run.inventory -- 774
	view.inventory = { -- 775
		wood = inv.wood, -- 775
		bell = inv.bell, -- 775
		scrap = inv.scrap, -- 775
		wedge = inv.wedge, -- 775
		ammo = inv.ammo -- 775
	} -- 775
	view.recipes = self:recipeViews() -- 776
	view.equippedWeapon = self.equippedWeapon -- 777
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 778
	if view.justCraftedTimer > 0 then -- 778
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 780
	end -- 780
end -- 772
function Play.prototype.openCraftBench(self) -- 785
	if self.room.key ~= "escort3" or self.craftBench.active then -- 785
		return -- 787
	end -- 787
	self.craftBench.active = true -- 789
	self.carryOn = false -- 790
	self.run.story.carry = false -- 791
	self.player.vx = 0 -- 792
	self.player.vy = 0 -- 793
	self.craftBench.justCraftedTimer = 0 -- 794
	self:syncCraftBench() -- 795
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 796
	self:log("开工台") -- 797
	self:emit( -- 798
		"benchOpen", -- 798
		{ -- 798
			recipes = __TS__ArrayMap( -- 799
				self.craftBench.recipes, -- 799
				function(____, r) return r.id end -- 799
			), -- 799
			inventory = self.craftBench.inventory, -- 800
			carry = self.carryOn -- 801
		} -- 801
	) -- 801
end -- 785
function Play.prototype.closeCraftBench(self) -- 806
	if not self.craftBench.active then -- 806
		return -- 808
	end -- 808
	self.craftBench.active = false -- 810
	self.craftBench.justCraftedTimer = 0 -- 811
	self.carryOn = true -- 812
	self.run.story.carry = true -- 813
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 814
	self:log("离站背起") -- 815
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 816
end -- 806
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 823
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 823
		return false -- 825
	end -- 825
	local recipe = findRecipe(recipeId) -- 827
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 827
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 829
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 830
		return false -- 831
	end -- 831
	local missing = missingMaterials(self.run.inventory, recipe) -- 833
	if #missing > 0 then -- 833
		self:flashSet( -- 835
			"缺料 · " .. table.concat(missing, " / "), -- 835
			1.6 -- 835
		) -- 835
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 836
		return false -- 837
	end -- 837
	payMaterials(self.run.inventory, recipe) -- 839
	self.handledCraftRequests[requestId] = true -- 840
	self.run.story.craftedWeapon = recipe.id -- 841
	self.run.story.equippedWeapon = recipe.id -- 842
	self.equippedWeapon = recipe.id -- 843
	self.sessionDirty = true -- 844
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 845
	self.craftBench.firstCraftDone = true -- 846
	self:syncCraftBench() -- 847
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 848
	self:log("改制 " .. recipe.id) -- 849
	self:emit("benchCraft", { -- 850
		recipeId = recipe.id, -- 851
		weapon = recipe.id, -- 852
		effect = recipe.enhancedEffect, -- 853
		wood = self.run.inventory.wood, -- 854
		bell = self.run.inventory.bell -- 855
	}) -- 855
	return true -- 857
end -- 823
function Play.prototype.equipWeapon(self, weaponId) -- 861
	local artifactOk = weaponId == ARTIFACT_WEAPON_ID and self.archive.artifactOwned -- 862
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId and not artifactOk then -- 862
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 864
		return false -- 865
	end -- 865
	self.equippedWeapon = weaponId -- 867
	self.run.story.equippedWeapon = weaponId -- 868
	self.sessionDirty = true -- 869
	self:syncCraftBench() -- 870
	self:flashSet( -- 871
		"已装备 " .. weaponNameOf(weaponId), -- 871
		1 -- 871
	) -- 871
	self:emit("benchEquip", {weapon = weaponId}) -- 872
	return true -- 873
end -- 861
function Play.prototype.toggleArtifactWeapon(self) -- 877
	if not self.archive.artifactOwned or self.childMode then -- 877
		return false -- 879
	end -- 879
	if self.equippedWeapon == ARTIFACT_WEAPON_ID then -- 879
		local fallback = self.run.story.craftedWeapon ~= "" and self.run.story.craftedWeapon or "standard_gun" -- 882
		return self:equipWeapon(fallback) -- 883
	end -- 883
	return self:equipWeapon(ARTIFACT_WEAPON_ID) -- 885
end -- 877
function Play.prototype.exportSession(self) -- 889
	self:syncStory() -- 890
	local story = self.run.story -- 891
	local inv = self.run.inventory -- 892
	local taken = {} -- 893
	for k in pairs(self.run.taken) do -- 894
		if self.run.taken[k] == true then -- 894
			taken[#taken + 1] = k -- 896
		end -- 896
	end -- 896
	local segments = {} -- 899
	for k in pairs(story.segments) do -- 900
		if story.segments[k] == true then -- 900
			segments[#segments + 1] = k -- 902
		end -- 902
	end -- 902
	return { -- 905
		roomKey = self.room.key, -- 906
		checkpoint = self.checkpoint, -- 907
		seed = self.run.seed, -- 908
		route = story.route, -- 909
		hp = story.hp, -- 910
		maxHp = story.maxHp, -- 911
		hpAtGate = story.hpAtGate, -- 912
		maxHpAtGate = story.maxHpAtGate, -- 913
		settled = story.settled, -- 914
		phase = self.phase, -- 915
		countTick = story.countTick, -- 916
		phaseTick = story.phaseTick, -- 917
		handTicks = story.handTicks, -- 918
		handDone = story.handDone, -- 919
		lineSaid = story.lineSaid, -- 920
		tied = story.tied, -- 921
		carry = story.carry, -- 922
		escortDone = story.escortDone, -- 923
		craftedWeapon = story.craftedWeapon, -- 924
		equippedWeapon = self.equippedWeapon, -- 925
		wood = inv.wood, -- 926
		bell = inv.bell, -- 927
		scrap = inv.scrap, -- 928
		wedge = inv.wedge, -- 929
		ammo = inv.ammo, -- 930
		shield = inv.shield, -- 931
		pass = inv.pass, -- 932
		quickbelt = inv.quickbelt, -- 933
		taken = taken, -- 934
		segments = segments, -- 935
		cartAxle = self.cartAxle, -- 936
		cartDocked = self.cartDocked, -- 937
		campaignRoute = self.run.route, -- 938
		joined = self.run.joined, -- 939
		c1Latch = self.run.c1Latch, -- 940
		c2Latch = self.run.c2Latch, -- 941
		talentSeed = story.talents ~= nil and story.talents.randomState or 0, -- 942
		talentRoom = story.talents ~= nil and story.talents.room or "", -- 943
		talentOffers = story.talents ~= nil and __TS__ArraySlice(story.talents.offers) or ({}), -- 944
		talentVitality = story.talents ~= nil and story.talents.ranks.vitality or 0, -- 945
		talentReload = story.talents ~= nil and story.talents.ranks.reload or 0, -- 946
		talentGuard = story.talents ~= nil and story.talents.ranks.guard or 0, -- 947
		talentCraft = story.talents ~= nil and story.talents.ranks.craft or 0 -- 948
	} -- 948
end -- 889
function Play.prototype.submitFeIntent(self, intent) -- 956
	local kind = intent == nil and "" or intent.kind -- 957
	if kind == "gateReunionHold" then -- 957
		if self.room.key ~= "gate" or self.phase ~= "gate-wait" and self.phase ~= "gate-count" then -- 957
			return false -- 960
		end -- 960
		local holding = intent.holding == true -- 962
		self.intentGateReunionHold = holding -- 963
		if not holding and self.phase == "gate-wait" then -- 963
			if self.handTicks > 0 then -- 963
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 966
			end -- 966
			self.handTicks = 0 -- 968
			self.handArmed = true -- 969
		end -- 969
		return true -- 971
	end -- 971
	if kind == "reloadOpen" then -- 971
		local camp = self.room.campaign -- 974
		if self.run.trial ~= nil or camp == nil or camp.reloadPuzzle ~= true or self.reloadOpen then -- 974
			return false -- 976
		end -- 976
		self:beginReload() -- 978
		return self.reloadOpen -- 979
	end -- 979
	if kind == "reloadPathPreview" then -- 979
		local path = intent.path -- 982
		return type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) -- 983
	end -- 983
	if kind == "reloadTapNode" then -- 983
		local node = intent.node -- 986
		if type(node) == "number" then -- 986
			self:reloadTapNode(node) -- 988
			return true -- 989
		end -- 989
		return false -- 991
	end -- 991
	if kind == "reloadPathCommit" then -- 991
		local path = intent.path -- 994
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 994
			local list = path -- 996
			local i = 0 -- 997
			do -- 997
				i = 0 -- 998
				while i < #list do -- 998
					do -- 998
						if i == 0 and list[i + 1] == RELOAD_START then -- 998
							goto __continue66 -- 1000
						end -- 1000
						self:reloadTapNode(list[i + 1]) -- 1002
					end -- 1002
					::__continue66:: -- 1002
					i = i + 1 -- 998
				end -- 998
			end -- 998
			return true -- 1004
		end -- 1004
		return false -- 1006
	end -- 1006
	if kind == "reloadCancel" then -- 1006
		self:closeReloadPuzzle() -- 1009
		return true -- 1010
	end -- 1010
	if kind == "craftSubmit" then -- 1010
		local recipeId = intent.recipeId -- 1013
		local requestId = intent.requestId -- 1014
		if type(recipeId) == "string" and type(requestId) == "string" then -- 1014
			return self:craftAtBench(recipeId, requestId) -- 1016
		end -- 1016
		return false -- 1018
	end -- 1018
	if kind == "craftEquip" then -- 1018
		local weaponId = intent.weaponId -- 1021
		if type(weaponId) == "string" then -- 1021
			return self:equipWeapon(weaponId) -- 1023
		end -- 1023
		return false -- 1025
	end -- 1025
	if kind == "craftClose" then -- 1025
		self:closeCraftBench() -- 1028
		return true -- 1029
	end -- 1029
	if kind == "chooseTalent" then -- 1029
		local slot = intent.slot -- 1032
		if type(slot) == "number" then -- 1032
			return self:chooseTalent(slot) -- 1034
		end -- 1034
		return false -- 1036
	end -- 1036
	if kind == "wellPick" then -- 1036
		return self:pickWell() -- 1039
	end -- 1039
	if kind == "museumInteract" then -- 1039
		local target = type(intent.target) == "string" and intent.target or "" -- 1042
		if target == "well_pickup" or target == "well" then -- 1042
			return self:pickWell() -- 1044
		end -- 1044
		if self.room.key ~= "museum" then -- 1044
			return false -- 1047
		end -- 1047
		return self:triggerMuseumIntent(target) -- 1049
	end -- 1049
	return false -- 1051
end -- 956
function Play.prototype.triggerMuseumIntent(self, target) -- 1055
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 1056
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 1059
	if self.phase == "museum-cabinet" and (target == "" or target == "cabinet" or target == "weapon_case") and atCase then -- 1059
		self.pendingMuseumIntentTarget = "cabinet" -- 1061
		return true -- 1062
	end -- 1062
	if self.phase == "museum-hall" and (target == "" or target == "hall" or target == "corridor") and self.player.x >= self.ox + mu.hallX then -- 1062
		self.pendingMuseumIntentTarget = "hall" -- 1065
		return true -- 1066
	end -- 1066
	if self.phase == "museum-lamp" and (target == "" or target == "lamp" or target == "west_lamp") and self.player.x >= self.ox + mu.lampX then -- 1066
		self.pendingMuseumIntentTarget = "lamp" -- 1069
		return true -- 1070
	end -- 1070
	if self.phase == "museum-return" and (target == "" or target == "return_cabinet" or target == "cabinet" or target == "return") and atCase then -- 1070
		self.pendingMuseumIntentTarget = "return_cabinet" -- 1073
		return true -- 1074
	end -- 1074
	if self.phase == "museum-done" and (target == "" or target == "return_cabinet" or target == "return") then -- 1074
		self.pendingMuseumIntentTarget = "done" -- 1077
		return true -- 1078
	end -- 1078
	return false -- 1080
end -- 1055
function Play.prototype.captureCheckpoint(self, id) -- 1084
	local inv = self.run.inventory -- 1085
	self.checkpointSnap = { -- 1086
		id = id, -- 1087
		wood = inv.wood, -- 1088
		bell = inv.bell, -- 1089
		scrap = inv.scrap, -- 1090
		wedge = inv.wedge, -- 1091
		ammo = inv.ammo, -- 1092
		shield = inv.shield, -- 1093
		pass = inv.pass, -- 1094
		quickbelt = inv.quickbelt, -- 1095
		crafted = self.run.story.craftedWeapon, -- 1096
		equipped = self.equippedWeapon, -- 1097
		carry = self.carryOn -- 1098
	} -- 1098
	self.run.story.cp = self.checkpointSnap -- 1100
end -- 1084
function Play.prototype.applyCheckpointSnap(self, id) -- 1104
	local snap = self.run.story.cp -- 1105
	if snap == nil or snap.id ~= id then -- 1105
		return false -- 1107
	end -- 1107
	self.checkpointSnap = snap -- 1109
	local inv = self.run.inventory -- 1110
	inv.wood = snap.wood -- 1111
	inv.bell = snap.bell -- 1112
	inv.scrap = snap.scrap -- 1113
	inv.wedge = snap.wedge -- 1114
	inv.ammo = snap.ammo -- 1115
	inv.shield = snap.shield -- 1116
	inv.pass = snap.pass -- 1117
	inv.quickbelt = snap.quickbelt -- 1118
	self.run.story.craftedWeapon = snap.crafted -- 1119
	self.equippedWeapon = snap.equipped -- 1120
	self.carryOn = snap.carry -- 1121
	self.run.story.carry = snap.carry -- 1122
	self.craftBench.active = false -- 1123
	self:syncCraftBench() -- 1124
	return true -- 1125
end -- 1104
function Play.prototype.restoreStory(self) -- 1128
	if self.isCampaign and self.run.trial ~= nil then -- 1128
		return -- 1132
	end -- 1132
	local story = self.run.story -- 1134
	if story == nil then -- 1134
		return -- 1136
	end -- 1136
	if story.maxHp > 0 then -- 1136
		self.maxHp = story.maxHp -- 1139
		self.hp = math.max( -- 1140
			1, -- 1140
			math.min(story.hp, story.maxHp) -- 1140
		) -- 1140
	end -- 1140
	self.storyRoute = story.route -- 1142
	self.storySettled = story.settled -- 1143
	self.hpAtGate = story.hpAtGate -- 1144
	self.maxHpAtGate = story.maxHpAtGate -- 1145
	self.handDone = story.handDone -- 1146
	self.lineSaid = story.lineSaid -- 1147
	self.tied = story.handDone -- 1148
	self.carryOn = story.carry or story.route == "soldier" and self.room.key == "escort1" -- 1149
	self.museumReturn = story.museumReturn -- 1150
	story.museumReturn = false -- 1151
	self.escortDone = story.escortDone -- 1152
	local savedEq = story.equippedWeapon -- 1153
	if savedEq == ARTIFACT_WEAPON_ID and self.archive.artifactOwned then -- 1153
		self.equippedWeapon = ARTIFACT_WEAPON_ID -- 1155
	elseif savedEq == "standard_gun" or savedEq ~= "" and savedEq == story.craftedWeapon then -- 1155
		self.equippedWeapon = savedEq -- 1157
	else -- 1157
		self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 1159
	end -- 1159
	self:syncCraftBench() -- 1161
	if story.segments.outside_cart == true then -- 1161
		self.redCartPulled = true -- 1164
		local redBox = __TS__ArrayFind( -- 1165
			self.boxes, -- 1165
			function(____, b) return b.id == "outside_red_cart" end -- 1165
		) -- 1165
		if redBox ~= nil then -- 1165
			redBox.x0 = 430 -- 1167
			redBox.x1 = 474 -- 1168
		end -- 1168
		if self.room.key == "outside" and self.room.cart.bodyW > 0 then -- 1168
			self.cartAxle = self.room.cart.endX -- 1171
			self.cartDocked = true -- 1172
		end -- 1172
	end -- 1172
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 1175
	self.waterSeen = story.segments.water_lantern == true -- 1177
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 1177
		self:applyCheckpointSnap(self.checkpoint) -- 1180
	end -- 1180
	if self.room.key == "tower" and story.route == "soldier" then -- 1180
		self.carryOn = false -- 1184
		self.run.story.carry = false -- 1185
		self.partner = { -- 1186
			x = math.max(self.room.minX + 40, self.player.x - 36), -- 1187
			y = 0, -- 1188
			depth = 0, -- 1189
			depthSpeed = 0, -- 1190
			vx = 0, -- 1191
			vy = 0, -- 1192
			w = SOLDIER_W, -- 1193
			h = SOLDIER_H, -- 1194
			onGround = true, -- 1195
			facing = 1, -- 1196
			crouch = false, -- 1197
			rollT = 0, -- 1198
			covered = false, -- 1199
			alive = true -- 1200
		} -- 1200
	end -- 1200
	if self.room.key == "tower" then -- 1200
		if story.segments.tower_door == true then -- 1200
			self:openTowerDoor() -- 1206
		end -- 1206
		self.towerHanded = story.segments.tower_handover == true -- 1208
		self.deskHold = 0 -- 1209
		if story.phase == "tower-enter" or story.phase == "tower-desk" or story.phase == "tower-given" then -- 1209
			self.phase = story.phase -- 1211
			self.phaseTick = 0 -- 1212
			if story.phase == "tower-desk" or story.phase == "tower-given" then -- 1212
				self.player.x = self.ox + 605 -- 1214
				self.player.y = 0 -- 1215
				if story.route == "soldier" and self.partner.alive then -- 1215
					self.partner.x = self.ox + 568 -- 1217
					self.partner.y = 0 -- 1218
					self.partner.facing = 1 -- 1219
				end -- 1219
			end -- 1219
		end -- 1219
	end -- 1219
	if self.room.key == "prologue" then -- 1219
		local ph = story.phase -- 1226
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 1226
			self.phase = ph -- 1228
			self.phaseTick = story.phaseTick -- 1229
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 1230
			self.player.y = 0 -- 1231
			self.player.depth = 0 -- 1232
			self.player.vx = 0 -- 1233
			self.partner.x = self.ox + 300 -- 1234
			self.partner.y = 0 -- 1235
			self.partner.depth = 0 -- 1236
			self.partner.vx = 0 -- 1237
			self.partner.alive = true -- 1238
			if ph == "prologue-follow" then -- 1238
				self.partner.crouch = false -- 1240
				self.partner.h = CHILD_H -- 1241
			else -- 1241
				self.partner.crouch = true -- 1243
				self.partner.h = CHILD_CROUCH_H -- 1244
			end -- 1244
			self.cam.x = self.player.x -- 1246
		end -- 1246
		return -- 1248
	end -- 1248
	if self.room.key ~= "gate" then -- 1248
		return -- 1251
	end -- 1251
	local ____temp_0 -- 1253
	if self.room.story == nil then -- 1253
		____temp_0 = nil -- 1253
	else -- 1253
		____temp_0 = self.room.story.gate -- 1253
	end -- 1253
	local g = ____temp_0 -- 1253
	if g == nil then -- 1253
		return -- 1255
	end -- 1255
	if story.phase == "gate-send" then -- 1255
		self.phase = "gate-send" -- 1259
		self.gateTick = g.holdTicks -- 1260
		self.gateSpawned = 4 -- 1261
		self.enemies = {} -- 1262
		self.player.x = self.ox + g.doorX - 40 -- 1263
		self.player.y = 0 -- 1264
		self.player.depth = 0 -- 1265
		self.player.vx = 0 -- 1266
		self.player.vy = 0 -- 1267
		self.player.onGround = true -- 1268
		self.partner.x = self.ox + g.waitX -- 1269
		self.partner.y = 0 -- 1270
		self.partner.depth = 0 -- 1271
		self.partner.alive = true -- 1272
		self.cam.x = self.player.x -- 1273
		self.handTicks = 0 -- 1274
		self.handArmed = false -- 1275
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1276
		return -- 1277
	end -- 1277
	if not story.settled then -- 1277
		return -- 1280
	end -- 1280
	self.gateTick = g.holdTicks -- 1283
	self.gateSpawned = 4 -- 1284
	self.enemies = {} -- 1285
	if story.phase == "gate-count" or story.phase == "gate-walk" then -- 1285
		self.phase = story.phase -- 1287
		self.countTick = math.max(story.countTick, 0) -- 1288
		self:swapToChild(g.doorX + 30) -- 1289
		self.countPrevMove = 0 -- 1290
		self.countArmed = false -- 1291
		return -- 1292
	end -- 1292
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1292
		self.phase = story.phase -- 1295
		self.countTick = ____exports.GATE_COUNT_END -- 1296
		self.phaseTick = story.phaseTick -- 1297
		self:swapToChild(g.doorX + 30) -- 1298
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1299
			0, -- 1299
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1299
		) -- 1299
		self.handArmed = false -- 1300
	end -- 1300
end -- 1128
function Play.prototype.buildWorld(self) -- 1305
	local room = self.room -- 1306
	self.boxes = {} -- 1307
	self.floors = {} -- 1308
	local i = 0 -- 1309
	do -- 1309
		i = 0 -- 1310
		while i < #room.floors do -- 1310
			local f = room.floors[i + 1] -- 1311
			local ____self_floors_1 = self.floors -- 1311
			____self_floors_1[#____self_floors_1 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1312
			i = i + 1 -- 1310
		end -- 1310
	end -- 1310
	do -- 1310
		i = 0 -- 1314
		while i < #room.solids do -- 1314
			local s = room.solids[i + 1] -- 1315
			if not s.decorative then -- 1315
				local ____self_boxes_13 = self.boxes -- 1321
				local ____s_x_4 = s.x -- 1322
				local ____temp_5 = s.x + s.w -- 1322
				local ____s_y_6 = s.y -- 1322
				local ____temp_7 = s.y + s.h -- 1322
				local ____temp_2 -- 1323
				if room.depth == nil then -- 1323
					____temp_2 = nil -- 1323
				else -- 1323
					____temp_2 = s.depth -- 1323
				end -- 1323
				local ____temp_8 = s.passable == true -- 1324
				local ____s_label_9 = s.label -- 1324
				local ____s_id_10 = s.id -- 1325
				local ____temp_11 = s.soft == true -- 1325
				local ____temp_12 = s.hidden == true -- 1325
				local ____temp_3 -- 1326
				if s.breakable == nil then -- 1326
					____temp_3 = nil -- 1326
				else -- 1326
					____temp_3 = __TS__ObjectAssign({}, s.breakable) -- 1326
				end -- 1326
				____self_boxes_13[#____self_boxes_13 + 1] = { -- 1321
					x0 = ____s_x_4, -- 1322
					x1 = ____temp_5, -- 1322
					y0 = ____s_y_6, -- 1322
					y1 = ____temp_7, -- 1322
					depth = ____temp_2, -- 1323
					passable = ____temp_8, -- 1324
					label = ____s_label_9, -- 1324
					id = ____s_id_10, -- 1325
					soft = ____temp_11, -- 1325
					hidden = ____temp_12, -- 1325
					breakable = ____temp_3, -- 1326
					interact = s.interact -- 1327
				} -- 1327
			end -- 1327
			i = i + 1 -- 1314
		end -- 1314
	end -- 1314
	do -- 1314
		i = 0 -- 1331
		while i < #room.stairs do -- 1331
			local st = room.stairs[i + 1] -- 1332
			local n = st.steps + 1 -- 1333
			local stepW = (st.x1 - st.x0) / n -- 1334
			local k = 0 -- 1335
			do -- 1335
				k = 0 -- 1336
				while k < n do -- 1336
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1337
					local x0 = st.x0 + stepW * k -- 1338
					local ____self_boxes_17 = self.boxes -- 1341
					local ____temp_15 = x0 + stepW -- 1342
					local ____temp_16 = -8 -- 1342
					local ____temp_14 -- 1343
					if room.depth == nil then -- 1343
						____temp_14 = nil -- 1343
					else -- 1343
						____temp_14 = st.depth -- 1343
					end -- 1343
					____self_boxes_17[#____self_boxes_17 + 1] = { -- 1341
						x0 = x0, -- 1342
						x1 = ____temp_15, -- 1342
						y0 = ____temp_16, -- 1342
						y1 = y, -- 1342
						depth = ____temp_14, -- 1343
						passable = true -- 1344
					} -- 1344
					k = k + 1 -- 1336
				end -- 1336
			end -- 1336
			i = i + 1 -- 1331
		end -- 1331
	end -- 1331
end -- 1305
function Play.prototype.setupCampaign(self) -- 1354
	local wr = self.room -- 1355
	local c = wr.campaign -- 1356
	if c == nil then -- 1356
		return -- 1358
	end -- 1358
	self.roomStartTick = self.run.ticks -- 1360
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1360
		self.run.joined = true -- 1364
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1364
		local ____self_run_22 = self.run -- 1367
		local ____temp_21 -- 1367
		if wr.key == "s2-drygoods" then -- 1367
			local ____temp_20 = self.run.route ~= "drygoods" -- 1368
			if not ____temp_20 then -- 1368
				local ____opt_18 = self.run.props.s2_board -- 1368
				____temp_20 = (____opt_18 and ____opt_18.broken) == true -- 1368
			end -- 1368
			____temp_21 = ____temp_20 -- 1368
		else -- 1368
			____temp_21 = wr.key == "c1-yard" and self.run.c1Latch -- 1369
		end -- 1369
		____self_run_22.joined = ____temp_21 -- 1367
	end -- 1367
	local x = wr.minX + 60 -- 1371
	local y = 0 -- 1372
	local depth = 0 -- 1373
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1373
		x = wr.minX + 210 -- 1375
		depth = -32 -- 1376
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1376
		x = wr.minX + 40 -- 1378
		y = 32 -- 1379
		depth = 32 -- 1380
	end -- 1380
	self.player = { -- 1382
		x = x, -- 1383
		y = y, -- 1383
		depth = depth, -- 1383
		depthSpeed = 0, -- 1383
		vx = 0, -- 1383
		vy = 0, -- 1383
		w = SOLDIER_W, -- 1384
		h = SOLDIER_H, -- 1384
		onGround = y <= 0, -- 1384
		facing = 1, -- 1384
		crouch = false, -- 1384
		rollT = 0, -- 1384
		covered = false, -- 1384
		alive = true -- 1384
	} -- 1384
	self.partner = { -- 1386
		x = x + 60, -- 1387
		y = y, -- 1387
		depth = depth, -- 1387
		depthSpeed = 0, -- 1387
		vx = 0, -- 1387
		vy = 0, -- 1387
		w = CHILD_W, -- 1388
		h = CHILD_H, -- 1388
		onGround = y <= 0, -- 1388
		facing = 1, -- 1388
		crouch = false, -- 1388
		rollT = 0, -- 1388
		covered = false, -- 1388
		alive = true -- 1388
	} -- 1388
	self.cam.x = x -- 1390
	self.cam.y = y + CAM_LOOK_UP -- 1391
	self.phase = "run" -- 1392
	self.hp = self.maxHp -- 1393
	local trial = self.run.trial -- 1394
	if trial ~= nil then -- 1394
		draftRoom(trial, wr.key) -- 1396
		self.maxHp = self.maxHp + trial.ranks.vitality -- 1397
		self.hp = trial.hp -- 1398
	elseif self:isEscortRoom() and self.run.story.route == "soldier" then -- 1398
		if self.run.story.talents == nil then -- 1398
			self.run.story.talents = createStoryTalents(self.run.seed) -- 1402
		end -- 1402
		draftTalentOffers(self.run.story.talents, wr.key) -- 1404
	end -- 1404
	self:buildEnemies() -- 1406
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1407
	local i = 0 -- 1408
	do -- 1408
		i = 0 -- 1409
		while i < #self.boxes do -- 1409
			do -- 1409
				local b = self.boxes[i + 1] -- 1410
				if b.id == nil then -- 1410
					goto __continue137 -- 1412
				end -- 1412
				local st = self.run.props[b.id] -- 1414
				if st ~= nil then -- 1414
					b.broken = st.broken -- 1416
					local ____temp_23 -- 1417
					if b.breakable == nil then -- 1417
						____temp_23 = nil -- 1417
					else -- 1417
						____temp_23 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1417
					end -- 1417
					b.breakable = ____temp_23 -- 1417
					b.hidden = b.hidden == true and st.revealed ~= true -- 1418
					if b.hidden then -- 1418
						b.broken = true -- 1420
					end -- 1420
				elseif b.hidden == true then -- 1420
					b.broken = true -- 1424
				end -- 1424
			end -- 1424
			::__continue137:: -- 1424
			i = i + 1 -- 1409
		end -- 1409
	end -- 1409
	if wr.cart.bodyW > 0 then -- 1409
		self.cartAxle = wr.cart.startX -- 1428
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1428
			self.cartAxle = wr.cart.endX -- 1430
			self.cartDocked = true -- 1431
		end -- 1431
	end -- 1431
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1434
end -- 1354
function Play.prototype.log(self, line) -- 1437
	local ____self_run_log_24 = self.run.log -- 1437
	____self_run_log_24[#____self_run_log_24 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1438
	if #self.run.log > 120 then -- 1438
		table.remove(self.run.log, 1) -- 1440
	end -- 1440
end -- 1437
function Play.prototype.buildEnemies(self) -- 1444
	self.enemies = {} -- 1445
	if self.isCampaign then -- 1445
		local i = 0 -- 1447
		do -- 1447
			i = 0 -- 1448
			while i < #self.room.spawns do -- 1448
				local sp = self.room.spawns[i + 1] -- 1449
				local kind = sp.kind or "gunner" -- 1450
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1451
				local ____self_enemies_25 = self.enemies -- 1451
				____self_enemies_25[#____self_enemies_25 + 1] = { -- 1452
					x = sp.x, -- 1453
					y = sp.y, -- 1453
					depth = sp.depth, -- 1453
					w = 26, -- 1453
					h = sp.h, -- 1453
					alive = true, -- 1453
					hitT = 0, -- 1453
					warnT = 0, -- 1453
					fireCd = 40, -- 1453
					kind = kind, -- 1454
					shieldHp = hp, -- 1454
					shieldHpMax = hp, -- 1454
					drop = sp.drop or "none", -- 1454
					homeX = sp.x, -- 1455
					swingT = 0, -- 1455
					awake = false, -- 1455
					squad = i -- 1455
				} -- 1455
				i = i + 1 -- 1448
			end -- 1448
		end -- 1448
		return -- 1458
	end -- 1458
	if self.room.key == "checkpoint" then -- 1458
		local ____self_enemies_26 = self.enemies -- 1458
		____self_enemies_26[#____self_enemies_26 + 1] = { -- 1461
			x = self.ox + 430, -- 1461
			y = 0, -- 1461
			w = 26, -- 1461
			h = 84, -- 1461
			alive = true, -- 1461
			hitT = 0, -- 1461
			warnT = 0, -- 1461
			fireCd = 0 -- 1461
		} -- 1461
		local ____self_enemies_27 = self.enemies -- 1461
		____self_enemies_27[#____self_enemies_27 + 1] = { -- 1462
			x = self.ox + 505, -- 1462
			y = 0, -- 1462
			w = 26, -- 1462
			h = 84, -- 1462
			alive = true, -- 1462
			hitT = 0, -- 1462
			warnT = 0, -- 1462
			fireCd = 0 -- 1462
		} -- 1462
		return -- 1463
	end -- 1463
	if self.room.key == "street" then -- 1463
		local ____self_enemies_28 = self.enemies -- 1463
		____self_enemies_28[#____self_enemies_28 + 1] = { -- 1467
			x = self.ox + 340, -- 1467
			y = 0, -- 1467
			w = 26, -- 1467
			h = 84, -- 1467
			alive = true, -- 1467
			hitT = 0, -- 1467
			warnT = 0, -- 1467
			fireCd = 0 -- 1467
		} -- 1467
		local ____self_enemies_29 = self.enemies -- 1467
		____self_enemies_29[#____self_enemies_29 + 1] = { -- 1468
			x = self.ox + 560, -- 1468
			y = 0, -- 1468
			w = 26, -- 1468
			h = 84, -- 1468
			alive = true, -- 1468
			hitT = 0, -- 1468
			warnT = 0, -- 1468
			fireCd = 0 -- 1468
		} -- 1468
	end -- 1468
end -- 1444
function Play.prototype.emit(self, name, data) -- 1474
	local ____self_events_30 = self.events -- 1474
	____self_events_30[#____self_events_30 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1475
	self.eventSeq = self.eventSeq + 1 -- 1476
	if #self.events > 256 then -- 1476
		table.remove(self.events, 1) -- 1478
	end -- 1478
end -- 1474
function Play.prototype.drainEvents(self) -- 1486
	local out = self.events -- 1487
	self.events = {} -- 1488
	return out -- 1489
end -- 1486
function Play.prototype.adoptEvents(self, events) -- 1498
	if #events == 0 then -- 1498
		return -- 1500
	end -- 1500
	local keep = {} -- 1502
	local i = 0 -- 1503
	do -- 1503
		i = 0 -- 1504
		while i < #events do -- 1504
			do -- 1504
				local e = events[i + 1] -- 1505
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1505
					goto __continue158 -- 1507
				end -- 1507
				keep[#keep + 1] = e -- 1509
			end -- 1509
			::__continue158:: -- 1509
			i = i + 1 -- 1504
		end -- 1504
	end -- 1504
	if #keep == 0 then -- 1504
		return -- 1512
	end -- 1512
	self.events = __TS__ArrayConcat(keep, self.events) -- 1514
	do -- 1514
		i = 0 -- 1515
		while i < #self.events do -- 1515
			self.events[i + 1].seq = i -- 1516
			i = i + 1 -- 1515
		end -- 1515
	end -- 1515
	self.eventSeq = #self.events -- 1518
end -- 1498
function Play.prototype.talentRank(self, talent) -- 1521
	if self.run.trial ~= nil then -- 1521
		return self.run.trial.ranks[talent] -- 1523
	end -- 1523
	if self.storyRoute == "soldier" and self:isEscortRoom() and self.run.story.talents ~= nil then -- 1523
		return self.run.story.talents.ranks[talent] -- 1526
	end -- 1526
	return 0 -- 1528
end -- 1521
function Play.prototype.getStoryTalentOffers(self) -- 1532
	if self.run.trial ~= nil or self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1532
		return {} -- 1534
	end -- 1534
	local st = self.run.story.talents -- 1536
	return st ~= nil and st.room == self.room.key and st.offers or ({}) -- 1537
end -- 1532
function Play.prototype.getStoryTalentRanks(self) -- 1541
	if self.run.trial ~= nil or self.storyRoute ~= "soldier" or not self:isEscortRoom() then -- 1541
		return nil -- 1543
	end -- 1543
	return self.run.story.talents ~= nil and self.run.story.talents.ranks or nil -- 1545
end -- 1541
function Play.prototype.chooseTalent(self, slot) -- 1548
	local trial = self.run.trial -- 1549
	if trial ~= nil then -- 1549
		local talent = trial.offers[slot + 1] -- 1551
		if talent == nil or trial.lost or self.run.finished then -- 1551
			return false -- 1552
		end -- 1552
		local ____trial_ranks_31, ____talent_32 = trial.ranks, talent -- 1552
		____trial_ranks_31[____talent_32] = ____trial_ranks_31[____talent_32] + 1 -- 1553
		trial.offers = {} -- 1554
		if talent == "vitality" then -- 1554
			self.maxHp = self.maxHp + 1 -- 1556
			self.hp = self.hp + 1 -- 1557
			trial.hp = self.hp -- 1558
		end -- 1558
		self:flashSet(talentNames[talent], 1.2) -- 1560
		return true -- 1561
	end -- 1561
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1561
		return false -- 1564
	end -- 1564
	local st = self.run.story.talents -- 1566
	local talent = st ~= nil and st.offers[slot + 1] or nil -- 1567
	if st == nil or talent == nil then -- 1567
		return false -- 1569
	end -- 1569
	local ____st_ranks_33, ____talent_34 = st.ranks, talent -- 1569
	____st_ranks_33[____talent_34] = ____st_ranks_33[____talent_34] + 1 -- 1571
	st.offers = {} -- 1572
	if talent == "vitality" then -- 1572
		self.maxHp = self.maxHp + 1 -- 1574
		self.hp = self.hp + 1 -- 1575
		self.run.story.maxHp = self.maxHp -- 1576
		self.run.story.hp = self.hp -- 1577
	end -- 1577
	self.sessionDirty = true -- 1579
	self:flashSet("本领 · " .. talentNames[talent], 1.4) -- 1580
	self:emit("storyBeat", {beat = "talent_picked", talent = talent, rank = st.ranks[talent], room = self.room.key}) -- 1581
	return true -- 1582
end -- 1548
function Play.prototype.beginReload(self) -- 1590
	self.reloadT = self:reloadTicks() -- 1591
	local camp = self.room.campaign -- 1592
	if self.run.trial == nil and camp ~= nil and camp.reloadPuzzle == true then -- 1592
		self:openReloadPuzzle() -- 1595
	end -- 1595
end -- 1590
function Play.prototype.openReloadPuzzle(self) -- 1600
	self.reloadOpen = true -- 1601
	self.reloadAnswerTicks = 0 -- 1602
	self.reloadWorldTicks = 0 -- 1603
	self.reloadPath = {RELOAD_START} -- 1604
	self.reloadPendingEffect = "" -- 1605
	self.reloadTryCount = self.reloadTryCount + 1 -- 1606
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 1607
end -- 1600
function Play.prototype.closeReloadPuzzle(self) -- 1611
	self.reloadOpen = false -- 1612
	self.reloadAnswerTicks = 0 -- 1613
	self.reloadWorldTicks = 0 -- 1614
	self.reloadPath = {RELOAD_START} -- 1615
	self.reloadPendingEffect = "" -- 1616
end -- 1611
function Play.prototype.reloadTapNode(self, node) -- 1623
	if not self.reloadOpen then -- 1623
		return -- 1625
	end -- 1625
	local path = self.reloadPath -- 1627
	local last = path[#path] -- 1628
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1628
		self.reloadPath = {RELOAD_START} -- 1630
		self:emit("reloadInvalid", {node = node, at = last}) -- 1631
		return -- 1632
	end -- 1632
	path[#path + 1] = node -- 1634
	if node ~= RELOAD_TARGET then -- 1634
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1636
		return -- 1637
	end -- 1637
	if not reloadPathValid(path) then -- 1637
		self.reloadPath = {RELOAD_START} -- 1640
		self:emit("reloadInvalid", {node = node, at = last}) -- 1641
		return -- 1642
	end -- 1642
	self.reloadPendingEffect = reloadEffectOf(path) -- 1644
	self.reloadOpen = false -- 1645
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1646
	self:flashSet( -- 1649
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1649
		1.4 -- 1649
	) -- 1649
end -- 1623
function Play.prototype.consumeReloadEffect(self) -- 1653
	local e = self.reloadPendingEffect -- 1654
	if e ~= "" then -- 1654
		self.reloadPendingEffect = "" -- 1656
	end -- 1656
	return e -- 1658
end -- 1653
function Play.prototype.echoToSource(self, from, count) -- 1665
	if count == nil then -- 1665
		count = 1 -- 1665
	end -- 1665
	local best = -1 -- 1666
	local bestD = 1000000000 -- 1667
	local i = 0 -- 1668
	local woken = {} -- 1669
	local n = 0 -- 1670
	while n < count do -- 1670
		best = -1 -- 1672
		bestD = 1000000000 -- 1673
		do -- 1673
			i = 0 -- 1674
			while i < #self.enemies do -- 1674
				do -- 1674
					if woken[i] == true then -- 1674
						goto __continue191 -- 1676
					end -- 1676
					local e = self.enemies[i + 1] -- 1678
					if not e.alive then -- 1678
						goto __continue191 -- 1680
					end -- 1680
					local d = math.abs(e.x - from.x) -- 1682
					if d < bestD then -- 1682
						bestD = d -- 1684
						best = i -- 1685
					end -- 1685
				end -- 1685
				::__continue191:: -- 1685
				i = i + 1 -- 1674
			end -- 1674
		end -- 1674
		if best < 0 then -- 1674
			break -- 1689
		end -- 1689
		woken[best] = true -- 1691
		local e = self.enemies[best + 1] -- 1692
		e.awake = true -- 1693
		e.warnT = 0 -- 1694
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1695
		n = n + 1 -- 1696
	end -- 1696
	if n == 0 then -- 1696
		return -- 1699
	end -- 1699
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1701
end -- 1665
function Play.prototype.reloadTicks(self) -- 1704
	return math.max( -- 1705
		6, -- 1705
		(self.run.inventory.quickbelt > 0 and 36 or 54) - 6 * self:talentRank("reload") -- 1705
	) -- 1705
end -- 1704
function Play.prototype.update(self, dt, input) -- 1708
	self:syncCraftBench() -- 1709
	local trial = self.run.trial -- 1710
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1710
		return -- 1711
	end -- 1711
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1711
		self:closeCraftBench() -- 1713
		return -- 1714
	end -- 1714
	if input.pause.pressed then -- 1714
		self.paused = not self.paused -- 1717
	end -- 1717
	if self.flashT > 0 then -- 1717
		self.flashT = self.flashT - dt -- 1720
		if self.flashT <= 0 then -- 1720
			self.flash = "" -- 1722
		end -- 1722
	end -- 1722
	if self.traceT > 0 then -- 1722
		self.traceT = self.traceT - dt -- 1726
		if self.traceT <= 0 then -- 1726
			self.trace = nil -- 1728
		end -- 1728
	end -- 1728
	if self.paused then -- 1728
		self:updateCamera(dt) -- 1732
		return -- 1733
	end -- 1733
	if self.craftBench.active then -- 1733
		self:updateCamera(dt) -- 1738
		return -- 1739
	end -- 1739
	if self.reloadOpen then -- 1739
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1745
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1745
			self.reloadOpen = false -- 1747
			self.reloadPendingEffect = "" -- 1748
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1749
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1750
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1750
			self:updateCamera(dt) -- 1752
			return -- 1753
		else -- 1753
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1755
		end -- 1755
	end -- 1755
	self.ticks = self.ticks + 1 -- 1759
	if self.invulnT > 0 then -- 1759
		self.invulnT = self.invulnT - 1 -- 1763
	end -- 1763
	if self.isCampaign then -- 1763
		local ____self_run_35, ____ticks_36 = self.run, "ticks" -- 1763
		____self_run_35[____ticks_36] = ____self_run_35[____ticks_36] + 1 -- 1766
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1767
	end -- 1767
	local p = self.player -- 1769
	self:stepPlayer(p, dt, input) -- 1770
	self:refreshCover(p, input) -- 1772
	if self.carryOn then -- 1772
		self:carryPose() -- 1774
	end -- 1774
	if self.isCampaign then -- 1774
		self:stepCampaign(dt, input) -- 1777
		if not self.carryOn then -- 1777
			self:stepCampaignPartner(dt) -- 1779
		end -- 1779
	end -- 1779
	if trial == nil or not self.run.finished then -- 1779
		self:stepEnemies(dt, input) -- 1787
	end -- 1787
	if trial ~= nil then -- 1787
		trial.hp = self.hp -- 1789
	end -- 1789
	if not self.isCampaign then -- 1789
		self:stepStory(dt, input) -- 1791
		self:stepEscort(dt, input) -- 1792
		self:stepVillage(dt, input) -- 1793
		self:stepChase(dt, input) -- 1794
		self:stepInteract(dt, input) -- 1795
	end -- 1795
	self:updateGate() -- 1797
	self:updateCamera(dt) -- 1798
	self:syncStory() -- 1800
end -- 1708
function Play.prototype.underLowArch(self, a) -- 1807
	local arch = self.room.arch -- 1808
	if arch.h <= 0 then -- 1808
		return false -- 1810
	end -- 1810
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1810
		return false -- 1813
	end -- 1813
	local top = arch.y + arch.h -- 1815
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1816
end -- 1807
function Play.prototype.coverAt(self, a) -- 1823
	local best = nil -- 1824
	local bestGap = 24 -- 1825
	local half = a.w / 2 -- 1826
	local i = 0 -- 1827
	do -- 1827
		i = 0 -- 1828
		while i < #self.boxes do -- 1828
			do -- 1828
				local b = self.boxes[i + 1] -- 1829
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1829
					goto __continue225 -- 1831
				end -- 1831
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1831
					goto __continue225 -- 1834
				end -- 1834
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1836
				if gap < bestGap then -- 1836
					bestGap = gap -- 1838
					best = b -- 1839
				end -- 1839
			end -- 1839
			::__continue225:: -- 1839
			i = i + 1 -- 1828
		end -- 1828
	end -- 1828
	return best -- 1842
end -- 1823
function Play.prototype.nearCover(self, a) -- 1845
	return self:coverAt(a) ~= nil -- 1846
end -- 1845
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1850
	if enemy == nil then -- 1850
		return false -- 1852
	end -- 1852
	local fromRight = enemy.x >= a.x -- 1854
	local edge = fromRight and b.x0 or b.x1 -- 1855
	local ____fromRight_37 -- 1856
	if fromRight then -- 1856
		____fromRight_37 = edge >= a.x - 0.001 and edge <= enemy.x -- 1856
	else -- 1856
		____fromRight_37 = edge <= a.x + 0.001 and edge >= enemy.x -- 1857
	end -- 1857
	local between = ____fromRight_37 -- 1856
	local separation = enemy.x - a.x -- 1858
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1859
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1860
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1861
end -- 1850
function Play.prototype.nearestEnemy(self, a) -- 1864
	local best -- 1865
	local bestD = 1000000000 -- 1866
	local i = 0 -- 1867
	do -- 1867
		i = 0 -- 1868
		while i < #self.enemies do -- 1868
			do -- 1868
				local e = self.enemies[i + 1] -- 1869
				if not e.alive then -- 1869
					goto __continue234 -- 1871
				end -- 1871
				local d = math.abs(e.x - a.x) -- 1873
				if d < bestD then -- 1873
					bestD = d -- 1875
					best = e -- 1876
				end -- 1876
			end -- 1876
			::__continue234:: -- 1876
			i = i + 1 -- 1868
		end -- 1868
	end -- 1868
	return best -- 1879
end -- 1864
function Play.prototype.refreshCover(self, a, input) -- 1883
	if self.childMode then -- 1883
		self.coverNear = false -- 1885
		self.coverHug = false -- 1886
		self.coverEntity = "" -- 1887
		self.coverBlocking = false -- 1888
		a.covered = false -- 1889
		return -- 1890
	end -- 1890
	local b = self:coverAt(a) -- 1892
	self.coverNear = b ~= nil -- 1893
	a.covered = self.coverNear and input.cover.held -- 1894
	self.coverHug = a.covered -- 1895
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1896
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1897
		b, -- 1897
		a, -- 1897
		self:nearestEnemy(a) -- 1897
	) -- 1897
end -- 1883
function Play.prototype.cartHandleInReach(self, a) -- 1901
	if a == nil then -- 1901
		a = self.player -- 1901
	end -- 1901
	local c = self.room.cart -- 1902
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1902
		return false -- 1904
	end -- 1904
	local handleX = self.cartAxle + c.handleOffset -- 1906
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1907
end -- 1901
function Play.prototype.nearLowLedge(self, a) -- 1912
	local reach = 26 -- 1913
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1914
	local x1 = x0 + reach -- 1915
	local i = 0 -- 1916
	do -- 1916
		i = 0 -- 1917
		while i < #self.boxes do -- 1917
			do -- 1917
				local b = self.boxes[i + 1] -- 1918
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1918
					goto __continue243 -- 1920
				end -- 1920
				local rise = b.y1 - a.y -- 1922
				if rise > 0 and rise <= LEDGE_RISE then -- 1922
					return true -- 1924
				end -- 1924
			end -- 1924
			::__continue243:: -- 1924
			i = i + 1 -- 1917
		end -- 1917
	end -- 1917
	return false -- 1927
end -- 1912
function Play.prototype.stepPlayer(self, a, dt, input) -- 1930
	a.depthSpeed = 0 -- 1931
	if not a.alive then -- 1931
		return -- 1933
	end -- 1933
	local isChild = self.childMode -- 1935
	local lowArch = isChild and self:underLowArch(a) -- 1937
	if self:storyLocked() then -- 1937
		a.vx = 0 -- 1940
		a.crouch = isChild and lowArch -- 1941
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1942
		self:fallY(a, dt) -- 1943
		return -- 1944
	end -- 1944
	if not isChild and self.escort.state == "calming" then -- 1944
		a.crouch = false -- 1948
		a.h = SOLDIER_H -- 1949
		a.vx = 0 -- 1950
		self:fallY(a, dt) -- 1951
		return -- 1952
	end -- 1952
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 1954
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 1955
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1956
	local nearCover = not isChild and self:nearCover(a) -- 1957
	a.covered = nearCover and input.cover.held -- 1958
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1960
	if a.rollT > 0 then -- 1960
		a.rollT = a.rollT - dt -- 1964
		a.vx = a.facing * ROLL_SPEED -- 1965
		self:slideX(a, a.vx * dt) -- 1966
		self:fallY(a, dt) -- 1967
		if a.rollT <= 0 then -- 1967
			self:flashSet("翻滚结束", 0.5) -- 1969
		end -- 1969
		return -- 1971
	end -- 1971
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1971
		if input.moveX ~= 0 then -- 1971
			a.facing = input.moveX > 0 and 1 or -1 -- 1976
		end -- 1976
		if self:nearLowLedge(a) then -- 1976
			a.vy = SOLDIER_JUMP -- 1980
			a.onGround = false -- 1981
			self:flashSet("翻上去", 0.3) -- 1982
			return -- 1983
		end -- 1983
		a.rollT = ROLL_TIME -- 1985
		self:flashSet("翻滚", 0.3) -- 1986
		return -- 1987
	end -- 1987
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1990
	if isChild then -- 1990
		if input.cover.held then -- 1990
			speed = CHILD_SLOW -- 1993
		end -- 1993
		if a.crouch then -- 1993
			speed = CHILD_SLOW -- 1996
		elseif self.room.key == "forest" and self.forestPath == "ditch" and a.x >= self.ox + 700 and a.x <= self.ox + 1140 then -- 1996
			speed = CHILD_SPEED * 1.22 -- 2000
		end -- 2000
	elseif a.covered then -- 2000
		speed = SOLDIER_SPEED * 0.45 -- 2003
	end -- 2003
	local handsBusy = self.gripping or gripIntent -- 2007
	local dir = self.gripping and 0 or input.moveX -- 2008
	local depthDir = self.room.depth ~= nil and not handsBusy and (not isChild or self.phase == "prologue-escape") and -input.moveY or 0 -- 2010
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 2012
	if dir ~= 0 then -- 2012
		a.facing = dir > 0 and 1 or -1 -- 2014
	end -- 2014
	a.vx = dir * speed * diagonal -- 2016
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 2016
		a.vy = CHILD_JUMP -- 2020
		a.onGround = false -- 2021
		self:flashSet("跳", 0.25) -- 2022
	end -- 2022
	local previousDepth = a.depth -- 2026
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 2027
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2028
	self:slideX(a, a.vx * dt) -- 2029
	self:fallY(a, dt) -- 2030
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 2030
		self:shoot(a) -- 2034
	end -- 2034
end -- 1930
function Play.prototype.stepPartner(self, p, dt) -- 2039
	local a = self.partner -- 2040
	if not a.alive then -- 2040
		return -- 2042
	end -- 2042
	a.crouch = false -- 2044
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 2045
	a.vx = 0 -- 2046
	a.depthSpeed = 0 -- 2047
	self:fallY(a, dt) -- 2048
end -- 2039
function Play.prototype.stepEscort(self, dt, input) -- 2055
	local a = self.partner -- 2056
	a.depthSpeed = 0 -- 2057
	if not a.alive then -- 2057
		return -- 2059
	end -- 2059
	if self.room.key == "gatepath" then -- 2059
		if self.carryOn then -- 2059
			return -- 2064
		end -- 2064
		local p = self.player -- 2067
		a.depth = p.depth -- 2068
		a.facing = p.facing -- 2069
		a.crouch = false -- 2070
		a.h = CHILD_H -- 2071
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 2072
		a.y = p.y -- 2073
		a.vy = 0 -- 2074
		a.vx = p.vx -- 2075
		a.onGround = p.onGround -- 2076
		return -- 2077
	end -- 2077
	if not self:escortOn() then -- 2077
		a.vx = 0 -- 2080
		self:fallY(a, dt) -- 2081
		return -- 2082
	end -- 2082
	local p = self.player -- 2084
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 2085
	local hadKnock1 = self.escort.knock1 -- 2086
	local hadKnock2 = self.escort.knock2 -- 2087
	self.calmConsumed = self.escort:update( -- 2088
		input, -- 2088
		p.x, -- 2088
		p.facing, -- 2088
		a.x, -- 2088
		dist -- 2088
	) -- 2088
	if not hadKnock1 and self.escort.knock1 then -- 2088
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 2091
	end -- 2091
	if not hadKnock2 and self.escort.knock2 then -- 2091
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 2094
	end -- 2094
	a.crouch = self.escort.crouchPose -- 2096
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 2097
	if not self.escort.stopped then -- 2097
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 2099
		local previousDepth = a.depth -- 2100
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 2101
		local distance = math.max( -- 2102
			-travel, -- 2102
			math.min(travel, targetDepth - previousDepth) -- 2102
		) -- 2102
		self:slideDepth(a, distance) -- 2103
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2104
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 2104
			a.vy = CHILD_JUMP -- 2106
			a.onGround = false -- 2107
		end -- 2107
	end -- 2107
	local dir = self.escort:moveDir(a.x) -- 2110
	a.vx = dir * CHILD_SPEED -- 2111
	if dir ~= 0 then -- 2111
		a.facing = dir -- 2113
		local before = a.x -- 2114
		self:slideX(a, dir * CHILD_SPEED * dt) -- 2115
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 2115
			a.vy = CHILD_JUMP -- 2118
			a.onGround = false -- 2119
		end -- 2119
	end -- 2119
	self:fallY(a, dt) -- 2122
end -- 2055
function Play.prototype.escortOn(self) -- 2126
	if self.room.key == "checkpoint" then -- 2126
		return true -- 2128
	end -- 2128
	if self.room.key == "gatepath" then -- 2128
		return true -- 2131
	end -- 2131
	if self.room.key == "prologue" then -- 2131
		return self.phase == "prologue-follow" -- 2134
	end -- 2134
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 2134
		return true -- 2138
	end -- 2138
	return self.room.key == "street" -- 2140
end -- 2126
function Play.prototype.storyLocked(self) -- 2144
	if self.caughtT > 0 then -- 2144
		return true -- 2146
	end -- 2146
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 2146
		return true -- 2150
	end -- 2150
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 2150
		return true -- 2153
	end -- 2153
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 2153
		return true -- 2156
	end -- 2156
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2156
		return true -- 2159
	end -- 2159
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2159
		return true -- 2162
	end -- 2162
	if self.craftBench.active then -- 2162
		return true -- 2166
	end -- 2166
	return false -- 2168
end -- 2144
function Play.prototype.swapToChild(self, x) -- 2172
	local tmp = self.player -- 2173
	self.player = self.partner -- 2174
	self.partner = tmp -- 2175
	self.childMode = true -- 2176
	self.player.alive = true -- 2177
	self.player.x = self.ox + x -- 2178
	self.player.y = 0 -- 2179
	self.player.depth = 0 -- 2180
	self.player.depthSpeed = 0 -- 2181
	self.player.vy = 0 -- 2182
	self.player.vx = 0 -- 2183
	self.player.onGround = true -- 2184
	self.player.crouch = false -- 2185
	self.player.h = CHILD_H -- 2186
	self.player.facing = 1 -- 2187
	self.partner.alive = true -- 2188
	self.cam.x = self.player.x -- 2189
end -- 2172
function Play.prototype.swapToSoldier(self, x, childX) -- 2193
	local tmp = self.player -- 2194
	self.player = self.partner -- 2195
	self.partner = tmp -- 2196
	self.childMode = false -- 2197
	self.player.alive = true -- 2198
	self.player.x = self.ox + x -- 2199
	self.player.y = 0 -- 2200
	self.player.depth = 0 -- 2201
	self.player.depthSpeed = 0 -- 2202
	self.player.vy = 0 -- 2203
	self.player.vx = 0 -- 2204
	self.player.onGround = true -- 2205
	self.player.crouch = false -- 2206
	self.player.h = SOLDIER_H -- 2207
	self.player.facing = 1 -- 2208
	self.partner.alive = true -- 2209
	self.partner.x = self.ox + childX -- 2210
	self.partner.y = 0 -- 2211
	self.partner.depth = 0 -- 2212
	self.partner.depthSpeed = 0 -- 2213
	self.partner.vx = 0 -- 2214
	self.partner.vy = 0 -- 2215
	self.partner.onGround = true -- 2216
	self.partner.crouch = true -- 2217
	self.partner.h = CHILD_CROUCH_H -- 2218
	self.cam.x = self.player.x -- 2219
end -- 2193
function Play.prototype.stepStory(self, dt, input) -- 2223
	if self.room.key == "prologue" then -- 2223
		self:stepPrologue(dt, input) -- 2225
	elseif self.room.key == "street" then -- 2225
		self:stepStreet(dt, input) -- 2227
	elseif self.room.key == "gate" then -- 2227
		self:stepGate(dt, input) -- 2229
	elseif self.room.key == "gatepath" then -- 2229
		self:stepGatePath() -- 2231
	elseif self.room.key == "tower" then -- 2231
		self:stepTower(dt, input) -- 2233
	elseif self.room.key == "museum" then -- 2233
		self:stepMuseum(dt, input) -- 2235
	end -- 2235
end -- 2223
function Play.prototype.canPersistProgress(self) -- 2241
	return not self.isCampaign and self.run.source == "official" -- 2242
end -- 2241
function Play.prototype.wellWindow(self) -- 2246
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 2247
end -- 2246
function Play.prototype.nearWell(self) -- 2252
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 2253
end -- 2252
function Play.prototype.pickWell(self) -- 2261
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2261
		return false -- 2263
	end -- 2263
	self.phase = "prologue-well" -- 2265
	self.phaseTick = 0 -- 2266
	self.wellOpen = false -- 2267
	self:flashSet("井沿 · 伸手下去", 1.4) -- 2268
	self:log("旧井拾取") -- 2269
	return true -- 2270
end -- 2261
function Play.prototype.stepPrologue(self, dt, input) -- 2273
	local child = self.partner -- 2274
	if self.museumReturn then -- 2274
		self.museumReturn = false -- 2277
		self.phase = "prologue-wait" -- 2278
		self.phaseTick = 0 -- 2279
		self.player.x = self.ox + 260 -- 2280
		self.player.y = 0 -- 2281
		self.player.depth = 0 -- 2282
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2283
	end -- 2283
	if self.phase == "prologue-wake" then -- 2283
		self.introTick = self.introTick + 1 -- 2287
		if self.introTick == 60 then -- 2287
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2289
		end -- 2289
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2289
			self.phase = "prologue-shadow" -- 2292
			self.introTick = 0 -- 2293
			self:flashSet("门缝里两道影子", 1.2) -- 2294
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2295
		end -- 2295
		return -- 2297
	end -- 2297
	if self.phase == "prologue-shadow" then -- 2297
		self.introTick = self.introTick + 1 -- 2300
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2300
			self.phase = "prologue-escape" -- 2303
			self.introTick = 0 -- 2304
			self.escapeRemaining = self.escapeDuration -- 2305
			self.escapeRetryCount = 0 -- 2306
			self:swapToChild(100) -- 2307
			self:flashSet( -- 2308
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2308
				1.6 -- 2308
			) -- 2308
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2309
		end -- 2309
		return -- 2313
	end -- 2313
	if self.phase == "prologue-escape" then -- 2313
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2316
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2316
			self.phase = "prologue-hide" -- 2319
			self.introTick = 0 -- 2320
			self.player.vx = 0 -- 2321
			self.player.crouch = true -- 2322
			self.player.h = CHILD_CROUCH_H -- 2323
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2324
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2325
			return -- 2329
		end -- 2329
		if self.escapeRemaining <= 0 then -- 2329
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2333
			self.player.x = self.ox + 100 -- 2334
			self.player.y = 0 -- 2335
			self.player.depth = 0 -- 2336
			self.player.vx = 0 -- 2337
			self.player.vy = 0 -- 2338
			self.escapeRemaining = self.escapeDuration -- 2339
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2340
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2341
			return -- 2342
		end -- 2342
		return -- 2344
	end -- 2344
	if self.phase == "prologue-hide" then -- 2344
		self.introTick = self.introTick + 1 -- 2347
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2347
			self.phase = "prologue-wait" -- 2350
			self.phaseTick = 0 -- 2351
			self.introTick = 0 -- 2352
			self:swapToSoldier(260, 300) -- 2353
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2354
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2355
		end -- 2355
		return -- 2357
	end -- 2357
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2360
	if self.phase == "prologue-wait" then -- 2360
		child.crouch = true -- 2362
		child.h = CHILD_CROUCH_H -- 2363
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2363
			self:pickWell() -- 2365
			return -- 2366
		end -- 2366
		if not self.wellOpen and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2366
			if self:canPersistProgress() then -- 2366
				self.archive.museumPhase = "well_reflect" -- 2372
				self.archiveDirty = true -- 2373
			end -- 2373
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2375
			return -- 2376
		end -- 2376
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2378
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2380
		if near and input.interact.pressed then -- 2380
			self.phase = "prologue-give" -- 2382
			self.phaseTick = 0 -- 2383
			self:flashSet("递出针套", 1) -- 2384
		end -- 2384
		return -- 2386
	end -- 2386
	if self.phase == "prologue-well" then -- 2386
		self.phaseTick = self.phaseTick + 1 -- 2390
		if self.phaseTick == 12 then -- 2390
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2392
		elseif self.phaseTick >= 30 then -- 2392
			self.phase = "prologue-wait" -- 2394
			self.phaseTick = 0 -- 2395
			self.wellTaken = true -- 2396
			self.wellOpen = false -- 2397
			self.run.archive.artifactOwned = true -- 2398
			self.archiveDirty = true -- 2399
			self:emit("artifactFound", { -- 2400
				x = self.ox + self.wellX, -- 2401
				y = 0, -- 2401
				room = "prologue", -- 2401
				once = true, -- 2401
				source = self.run.source -- 2402
			}) -- 2402
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2404
			self:log("井底取到时间穿梭器") -- 2405
		end -- 2405
		return -- 2407
	end -- 2407
	if self.phase == "prologue-give" then -- 2407
		self.phaseTick = self.phaseTick + 1 -- 2410
		if self.phaseTick == 12 then -- 2410
			self:flashSet("针套递过去", 0.7) -- 2412
		elseif self.phaseTick == 36 then -- 2412
			self:flashSet("纸条塞进针套", 0.9) -- 2414
		elseif self.phaseTick >= 60 then -- 2414
			self.phase = "prologue-follow" -- 2416
			self.phaseTick = 0 -- 2417
			child.crouch = false -- 2418
			child.h = CHILD_H -- 2419
			self:flashSet("她跟上了", 1.2) -- 2420
		end -- 2420
		return -- 2422
	end -- 2422
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2422
		self:requestRoom("street", "序章跟到门口") -- 2426
		self:flashSet("进街道", 1.2) -- 2427
	end -- 2427
end -- 2273
function Play.prototype.stepStreet(self, dt, input) -- 2432
	local p = self.player -- 2433
	local c = self.partner -- 2434
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2434
		local next = self.run.source == "debug" and "checkpoint" or "s1-crossroad" -- 2436
		self:requestRoom(next, "两人都到街尾") -- 2437
		self:flashSet(next == "s1-crossroad" and "进十字街" or "到检查站", 1.2) -- 2438
	end -- 2438
end -- 2432
function Play.prototype.stepGate(self, dt, input) -- 2443
	local ____temp_38 -- 2444
	if self.room.story == nil then -- 2444
		____temp_38 = nil -- 2444
	else -- 2444
		____temp_38 = self.room.story.gate -- 2444
	end -- 2444
	local g = ____temp_38 -- 2444
	if g == nil then -- 2444
		return -- 2446
	end -- 2446
	local p = self.player -- 2448
	if self.phase == "gate-idle" then -- 2448
		local a = self.partner -- 2451
		local gap = g.waitX - a.x -- 2452
		if math.abs(gap) > 3 then -- 2452
			a.facing = gap > 0 and 1 or -1 -- 2454
			a.vx = a.facing * CHILD_SPEED -- 2455
			local beforeX = a.x -- 2456
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2457
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2457
				a.vy = CHILD_JUMP -- 2459
				a.onGround = false -- 2460
			end -- 2460
			self:fallY(a, dt) -- 2462
		else -- 2462
			a.vx = 0 -- 2464
			a.x = g.waitX -- 2465
		end -- 2465
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2468
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2469
		if self.gateNeedConfirm then -- 2469
			if not input.interact.held then -- 2469
				self.gateRestartArmed = true -- 2474
			end -- 2474
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2474
				self.gateNeedConfirm = false -- 2477
				self.gateRestartArmed = true -- 2478
				self.phase = "gate-hold" -- 2479
				self.gateTick = 0 -- 2480
				self.gateSpawned = 0 -- 2481
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2482
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2483
			end -- 2483
			return -- 2485
		end -- 2485
		if atWinch and atWait then -- 2485
			self.phase = "gate-hold" -- 2488
			self.gateTick = 0 -- 2489
			self.gateSpawned = 0 -- 2490
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2491
		end -- 2491
		return -- 2493
	end -- 2493
	if self.phase == "gate-hold" then -- 2493
		self.gateTick = self.gateTick + 1 -- 2496
		local marks = {0, 540, 900, 1500} -- 2498
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2498
			local idx = self.gateSpawned -- 2500
			local ____self_enemies_39 = self.enemies -- 2500
			____self_enemies_39[#____self_enemies_39 + 1] = { -- 2501
				x = self.ox + 620 + idx * 62, -- 2502
				y = 0, -- 2502
				w = 26, -- 2502
				h = 84, -- 2502
				alive = true, -- 2503
				hitT = 0, -- 2503
				warnT = 0, -- 2503
				fireCd = 90 + idx * 45 -- 2503
			} -- 2503
			self.gateSpawned = self.gateSpawned + 1 -- 2505
			self:flashSet( -- 2506
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2506
				0.9 -- 2506
			) -- 2506
		end -- 2506
		if self.gateTick == 900 then -- 2506
			self:flashSet("灯灭了", 1) -- 2509
		elseif self.gateTick == 2100 then -- 2509
			self:flashSet("门底压下来了", 1) -- 2511
		end -- 2511
		if self.gateTick >= g.holdTicks then -- 2511
			self:captureGateBlood() -- 2516
			self.phase = "gate-send" -- 2517
			self.phaseTick = 0 -- 2518
			self.enemies = {} -- 2520
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2521
		end -- 2521
		return -- 2523
	end -- 2523
	if self.phase == "gate-send" then -- 2523
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2526
		if near and input.interact.pressed then -- 2526
			self:commitRoute() -- 2529
			self:swapToChild(g.doorX + 30) -- 2530
			self.phase = "gate-count" -- 2531
			self.countTick = 0 -- 2532
			self.countArmed = false -- 2534
			self.countPrevMove = input.moveX -- 2535
			self:flashSet("门开了 · 送她出去", 1.8) -- 2536
		end -- 2536
		return -- 2538
	end -- 2538
	if self.phase == "gate-count" then -- 2538
		self.countTick = self.countTick + 1 -- 2541
		if self.countTick == 360 then -- 2541
			self:flashSet("门关上", 0.9) -- 2543
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2543
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2545
			if self.storyRoute == "soldier" then -- 2545
				self.phase = "gate-wait" -- 2551
				self.phaseTick = 0 -- 2552
				self.knocks = 1 -- 2553
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2554
				self.handArmed = not input.interact.held -- 2556
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2557
			else -- 2557
				self:flashSet("数到二十", 2.2) -- 2559
			end -- 2559
		end -- 2559
		local prevMove = self.countPrevMove -- 2564
		self.countPrevMove = input.moveX -- 2565
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2565
			if prevMove <= 0 and input.moveX > 0 then -- 2565
				self.countArmed = true -- 2568
			end -- 2568
			if self.countArmed and input.moveX > 0 then -- 2568
				self.phase = "gate-walk" -- 2571
				self.phaseTick = 0 -- 2572
				self:flashSet("她迈出第一步", 1.4) -- 2573
				self:emit("storyExit", { -- 2574
					route = "child", -- 2574
					via = "walk", -- 2574
					countTick = self.countTick, -- 2574
					hp = self.hp, -- 2574
					maxHp = self.maxHp -- 2574
				}) -- 2574
			end -- 2574
		end -- 2574
		return -- 2577
	end -- 2577
	if self.phase == "gate-wait" then -- 2577
		self.phaseTick = self.phaseTick + 1 -- 2581
		if self.phaseTick == 12 then -- 2581
			self.knocks = 2 -- 2583
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2584
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2585
		end -- 2585
		local held = input.interact.held or self.intentGateReunionHold -- 2587
		if not held then -- 2587
			if self.handTicks > 0 then -- 2587
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2590
			end -- 2590
			self.handTicks = 0 -- 2592
			self.handArmed = true -- 2593
			return -- 2594
		end -- 2594
		if self.handArmed then -- 2594
			self.handTicks = self.handTicks + 1 -- 2597
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2597
				self.intentGateReunionHold = false -- 2599
				self.phase = "gate-hand" -- 2600
				self.phaseTick = 0 -- 2601
				self.handDone = true -- 2602
				self.tied = true -- 2603
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2604
				if not self.lineSaid then -- 2604
					self.lineSaid = true -- 2606
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2607
				end -- 2607
				self:flashSet("我们走吧。", 3) -- 2609
			end -- 2609
		end -- 2609
		return -- 2612
	end -- 2612
	if self.phase == "gate-hand" then -- 2612
		self.phaseTick = self.phaseTick + 1 -- 2616
		if self.phaseTick == 30 then -- 2616
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2618
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2618
			self:emit("storyExit", { -- 2620
				route = "soldier", -- 2620
				via = "hand", -- 2620
				handTicks = self.handTicks, -- 2620
				hp = self.hp, -- 2620
				maxHp = self.maxHp -- 2620
			}) -- 2620
			self:requestRoom("gatepath", "牵手同行") -- 2621
		end -- 2621
		return -- 2623
	end -- 2623
	if self.phase == "gate-walk" then -- 2623
		if self.player.x >= g.exitX then -- 2623
			self:requestRoom("outside", "走出城门") -- 2628
			self:flashSet("出城门 · 城外", 1.4) -- 2629
		end -- 2629
	end -- 2629
end -- 2443
function Play.prototype.captureGateBlood(self) -- 2638
	self.hpAtGate = self.hp -- 2639
	self.maxHpAtGate = self.maxHp -- 2640
end -- 2638
function Play.prototype.commitRoute(self) -- 2647
	if self.storySettled then -- 2647
		return -- 2649
	end -- 2649
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2651
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2652
	self.hpAtGate = hp -- 2653
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2654
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2655
	self.storySettled = true -- 2656
	self:emit("storyRouteLocked", { -- 2657
		route = self.storyRoute, -- 2658
		hp = self.hp, -- 2658
		maxHp = self.maxHp, -- 2658
		hpAtGate = self.hpAtGate, -- 2659
		maxHpAtGate = self.maxHpAtGate -- 2659
	}) -- 2659
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2661
end -- 2647
function Play.prototype.syncStory(self) -- 2665
	if self.isCampaign and self.run.trial ~= nil then -- 2665
		return -- 2667
	end -- 2667
	local s = self.run.story -- 2669
	if s == nil then -- 2669
		return -- 2671
	end -- 2671
	s.hp = self.hp -- 2673
	s.maxHp = self.maxHp -- 2674
	s.route = self.storyRoute -- 2675
	s.settled = self.storySettled -- 2676
	s.hpAtGate = self.hpAtGate -- 2677
	s.maxHpAtGate = self.maxHpAtGate -- 2678
	s.handDone = self.handDone -- 2679
	s.lineSaid = self.lineSaid -- 2680
	s.tied = self.tied -- 2681
	s.carry = self.carryOn -- 2682
	s.museumReturn = self.museumReturn -- 2683
	s.escortDone = self.escortDone -- 2684
	s.craftedWeapon = self.run.story.craftedWeapon -- 2685
	s.ending = self.run.story.ending -- 2686
	if self.room.key == "gate" then -- 2686
		s.phase = self.phase -- 2688
		s.countTick = self.countTick -- 2689
		s.phaseTick = self.phaseTick -- 2690
		s.handTicks = self.handTicks -- 2691
	end -- 2691
	if self.room.key == "prologue" then -- 2691
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2691
			s.phase = self.phase -- 2696
			s.phaseTick = self.phaseTick -- 2697
		end -- 2697
	end -- 2697
	if self.room.key == "tower" then -- 2697
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2697
			s.phase = self.phase -- 2703
			s.phaseTick = self.phaseTick -- 2704
		end -- 2704
	end -- 2704
end -- 2665
function Play.prototype.stepGatePath(self) -- 2710
	local ____temp_40 -- 2711
	if self.room.story == nil then -- 2711
		____temp_40 = nil -- 2711
	else -- 2711
		____temp_40 = self.room.story.gatepath -- 2711
	end -- 2711
	local gp = ____temp_40 -- 2711
	if self.phase == "gatepath-start" then -- 2711
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2711
			self.carryOn = true -- 2714
			self.phase = "gatepath-carry" -- 2715
			self.phaseTick = 0 -- 2716
			self.pathDone = true -- 2717
			self.escortDone = false -- 2718
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2719
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2720
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2721
		end -- 2721
		return -- 2723
	end -- 2723
	if self.phase == "gatepath-carry" then -- 2723
		self.phaseTick = self.phaseTick + 1 -- 2726
		if self.phaseTick == 20 then -- 2726
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2728
		end -- 2728
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2728
			self:requestRoom(gp.next, "背负进首战") -- 2731
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2732
		end -- 2732
	end -- 2732
end -- 2710
function Play.prototype.carryPose(self) -- 2741
	local p = self.player -- 2742
	local a = self.partner -- 2743
	a.alive = true -- 2744
	a.x = p.x - p.facing * 12 -- 2745
	a.y = p.y + 26 -- 2746
	a.depth = p.depth -- 2747
	a.vx = p.vx -- 2748
	a.vy = 0 -- 2749
	a.onGround = true -- 2750
	a.crouch = false -- 2751
	a.h = CHILD_CROUCH_H -- 2752
	a.facing = p.facing -- 2753
end -- 2741
function Play.prototype.stepMuseum(self, dt, input) -- 2761
	self.partner.alive = false -- 2762
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2763
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2766
	local intentTarget = self.pendingMuseumIntentTarget -- 2767
	self.pendingMuseumIntentTarget = "" -- 2768
	local interactHit = input.interact.pressed or intentTarget ~= "" -- 2769
	if self.phase == "museum-cabinet" then -- 2769
		if atCase and interactHit then -- 2769
			self.phase = "museum-hall" -- 2772
			self.phaseTick = 0 -- 2773
			if self:canPersistProgress() then -- 2773
				self.archive.museumPhase = "hall_walk" -- 2775
				self.archiveDirty = true -- 2776
			end -- 2776
			self:emit( -- 2778
				"museumStep", -- 2778
				{ -- 2778
					step = "cabinet", -- 2778
					x = self.ox + mu.cabinetX, -- 2778
					persisted = self:canPersistProgress() -- 2778
				} -- 2778
			) -- 2778
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2779
		end -- 2779
		return -- 2781
	end -- 2781
	if self.phase == "museum-hall" then -- 2781
		if self.player.x >= self.ox + mu.hallX and interactHit then -- 2781
			self.phase = "museum-lamp" -- 2785
			self.phaseTick = 0 -- 2786
			if self:canPersistProgress() then -- 2786
				self.archive.museumPhase = "lamp_turn" -- 2788
				self.archiveDirty = true -- 2789
			end -- 2789
			self:emit( -- 2791
				"museumStep", -- 2791
				{ -- 2791
					step = "hall", -- 2791
					x = self.ox + mu.hallX, -- 2791
					persisted = self:canPersistProgress() -- 2791
				} -- 2791
			) -- 2791
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2792
		end -- 2792
		return -- 2794
	end -- 2794
	if self.phase == "museum-lamp" then -- 2794
		if self.player.x >= self.ox + mu.lampX and interactHit then -- 2794
			self.phase = "museum-return" -- 2798
			self.phaseTick = 0 -- 2799
			if self:canPersistProgress() then -- 2799
				self.archive.museumPhase = "return_cabinet" -- 2801
				self.archiveDirty = true -- 2802
			end -- 2802
			self:emit( -- 2804
				"museumStep", -- 2804
				{ -- 2804
					step = "lamp", -- 2804
					x = self.ox + mu.lampX, -- 2804
					persisted = self:canPersistProgress() -- 2804
				} -- 2804
			) -- 2804
			self:flashSet("灯 · 转向西窗", 1.8) -- 2805
		end -- 2805
		return -- 2807
	end -- 2807
	if self.phase == "museum-return" then -- 2807
		if atCase and interactHit then -- 2807
			self.phase = "museum-knock" -- 2811
			self.phaseTick = 0 -- 2812
			self:emit( -- 2813
				"museumStep", -- 2813
				{ -- 2813
					step = "knock", -- 2813
					count = 1, -- 2813
					x = self.ox + mu.cabinetX, -- 2813
					persisted = self:canPersistProgress() -- 2813
				} -- 2813
			) -- 2813
			self:flashSet("回柜边 · 第一下", 0.8) -- 2814
		end -- 2814
		return -- 2816
	end -- 2816
	if self.phase == "museum-knock" then -- 2816
		self.phaseTick = self.phaseTick + 1 -- 2819
		if self.phaseTick == 8 then -- 2819
			self:emit( -- 2821
				"museumStep", -- 2821
				{ -- 2821
					step = "knock", -- 2821
					count = 2, -- 2821
					x = self.ox + mu.cabinetX, -- 2821
					persisted = self:canPersistProgress() -- 2821
				} -- 2821
			) -- 2821
			self:flashSet("回柜边 · 第二下", 0.8) -- 2822
		elseif self.phaseTick >= 36 then -- 2822
			self.phase = "museum-done" -- 2824
			self.phaseTick = 0 -- 2825
			if self:canPersistProgress() then -- 2825
				self.archive.museumSeen = true -- 2827
				self.archive.museumPhase = "done" -- 2828
				self.archiveDirty = true -- 2829
			end -- 2829
			self:emit( -- 2831
				"museumDone", -- 2831
				{ -- 2831
					steps = 4, -- 2831
					museumSeen = self.archive.museumSeen, -- 2831
					persisted = self:canPersistProgress() -- 2831
				} -- 2831
			) -- 2831
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2832
			self:log("博物馆 · 回柜边") -- 2833
		end -- 2833
		return -- 2835
	end -- 2835
	if interactHit then -- 2835
		self.museumReturn = true -- 2838
		self:requestRoom("prologue", "回柜边") -- 2839
	end -- 2839
end -- 2761
function Play.prototype.openTowerDoor(self) -- 2843
	self.towerDoorOpen = true -- 2844
	do -- 2844
		local i = 0 -- 2845
		while i < #self.boxes do -- 2845
			if self.boxes[i + 1].id == "tower_door" then -- 2845
				self.boxes[i + 1].hidden = true -- 2847
			end -- 2847
			i = i + 1 -- 2845
		end -- 2845
	end -- 2845
	self.run.story.segments.tower_door = true -- 2850
end -- 2843
function Play.prototype.stepTower(self, dt, input) -- 2853
	local ____temp_41 -- 2854
	if self.room.story == nil then -- 2854
		____temp_41 = nil -- 2854
	else -- 2854
		____temp_41 = self.room.story.tower -- 2854
	end -- 2854
	local t = ____temp_41 -- 2854
	if t == nil then -- 2854
		return -- 2856
	end -- 2856
	if self.storyRoute == "soldier" and self.partner.alive then -- 2856
		local targetX = math.max(self.room.minX + 40, self.player.x - 36) -- 2860
		local gap = targetX - self.partner.x -- 2861
		if math.abs(gap) > 2 then -- 2861
			local dir = gap > 0 and 1 or -1 -- 2863
			local stepDist = math.min( -- 2864
				math.abs(gap), -- 2864
				SOLDIER_SPEED * dt -- 2864
			) -- 2864
			self.partner.facing = dir -- 2865
			self.partner.vx = dir * SOLDIER_SPEED -- 2866
			local ____self_partner_42, ____x_43 = self.partner, "x" -- 2866
			____self_partner_42[____x_43] = ____self_partner_42[____x_43] + dir * stepDist -- 2867
		else -- 2867
			self.partner.vx = 0 -- 2869
			self.partner.facing = 1 -- 2870
		end -- 2870
	end -- 2870
	if self.phase == "tower-wait" then -- 2870
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2874
		if near and input.interact.pressed then -- 2874
			self.phase = "tower-knock" -- 2876
			self.phaseTick = 0 -- 2877
			self.knocks = 1 -- 2878
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2879
			self:flashSet("叩两下 · 第一声", 0.6) -- 2880
		end -- 2880
		return -- 2882
	end -- 2882
	if self.phase == "tower-knock" then -- 2882
		self.phaseTick = self.phaseTick + 1 -- 2885
		if self.phaseTick == 12 then -- 2885
			self.knocks = 2 -- 2887
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2888
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 2889
		elseif self.phaseTick >= t.knockTicks then -- 2889
			self:openTowerDoor() -- 2891
			self.phase = "tower-enter" -- 2892
			self.phaseTick = 0 -- 2893
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 2894
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 2895
		end -- 2895
		return -- 2897
	end -- 2897
	if self.phase == "tower-enter" then -- 2897
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 2897
			self.phase = "tower-desk" -- 2901
			self.phaseTick = 0 -- 2902
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 2903
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 2904
		end -- 2904
		return -- 2906
	end -- 2906
	if self.phase == "tower-desk" then -- 2906
		local deskX = self.ox + 605 -- 2909
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 2910
		if not near or not input.interact.held then -- 2910
			self.deskHold = 0 -- 2912
			return -- 2913
		end -- 2913
		self.deskHold = self.deskHold + 1 -- 2915
		if self.deskHold == 12 then -- 2915
			self:flashSet("针套 · 放在桌上", 1) -- 2917
		elseif self.deskHold == 24 then -- 2917
			self:flashSet("指南针 · 压住纸条", 1) -- 2919
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 2919
			self.towerHanded = true -- 2921
			self.deskHold = 0 -- 2922
			self.run.story.segments.tower_handover = true -- 2923
			self.phase = "tower-given" -- 2924
			self.phaseTick = 0 -- 2925
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 2926
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 2931
		end -- 2931
		return -- 2933
	end -- 2933
	if self.phase == "tower-given" then -- 2933
		local soldier = self.storyRoute == "soldier" -- 2938
		self.phaseTick = self.phaseTick + 1 -- 2939
		if self.phaseTick == 60 then -- 2939
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 2941
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 2942
		elseif self.phaseTick == 120 then -- 2942
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 2944
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 2944
			self.phase = "tower-end" -- 2946
			self.phaseTick = 0 -- 2947
			if not self.run.finished then -- 2947
				self.run.finished = true -- 2949
				local ending = soldier and "reunion" or "lamp" -- 2950
				self.run.story.ending = ending -- 2951
				local ____soldier_44 -- 2954
				if soldier then -- 2954
					____soldier_44 = self.run.story.segments.escort5 == true -- 2955
				else -- 2955
					____soldier_44 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 2956
				end -- 2956
				local played = ____soldier_44 -- 2954
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 2957
				if official then -- 2957
					if soldier then -- 2957
						self.run.archive.soldierCleared = true -- 2961
					else -- 2961
						self.run.archive.childCleared = true -- 2963
					end -- 2963
					self.archiveDirty = true -- 2965
				end -- 2965
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 2967
				self:emit("endingReached", { -- 2968
					route = soldier and "soldier" or "child", -- 2969
					ending = ending, -- 2970
					official = official, -- 2971
					source = self.run.source, -- 2972
					lines = {self.endingLines[1], self.endingLines[2]}, -- 2973
					childCleared = self.run.archive.childCleared, -- 2974
					soldierCleared = self.run.archive.soldierCleared, -- 2975
					artifactOwned = self.run.archive.artifactOwned, -- 2976
					equipped = self.equippedWeapon -- 2977
				}) -- 2977
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 2979
			end -- 2979
		end -- 2979
		return -- 2982
	end -- 2982
	self.phaseTick = self.phaseTick + 1 -- 2984
	if input.interact.pressed or input.retry.pressed then -- 2984
		self.restartStory = true -- 2987
		self:requestRoom("prologue", "片尾再玩") -- 2988
		self:flashSet("回到序章", 1.4) -- 2989
	end -- 2989
end -- 2853
function Play.prototype.stepChase(self, dt, input) -- 2994
	if self.caughtT > 0 then -- 2994
		self.caughtT = self.caughtT - dt -- 2996
		if self.caughtT <= 0 then -- 2996
			self:recoverFromCaught() -- 2998
		end -- 2998
		return -- 3000
	end -- 3000
	if self.room.key == "village" then -- 3000
		self:stepScavChase() -- 3003
	elseif self.room.key == "forest" then -- 3003
		self:stepForestRoute() -- 3005
		self:stepDog(dt) -- 3006
		if self.player.x >= self.ox + 1450 then -- 3006
			self:requestRoom("tower", "到林缘北塔") -- 3009
			self:flashSet("林缘 · 北塔", 1.4) -- 3010
		end -- 3010
	end -- 3010
end -- 2994
function Play.prototype.stepScavChase(self) -- 3016
	local s = self.room.scavenger -- 3017
	if s == nil then -- 3017
		return -- 3019
	end -- 3019
	local p = self.player -- 3021
	if self.passed and p.x > self.ox + 440 then -- 3021
		if self.scavChase then -- 3021
			self.scavChase = false -- 3025
			self.scavState = "back" -- 3026
			self.scavT = 0 -- 3027
		end -- 3027
		return -- 3029
	end -- 3029
	local dx = p.x - self.scavX -- 3031
	local dist = math.abs(dx) -- 3032
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 3033
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 3034
	if not self.scavChase then -- 3034
		if visible then -- 3034
			self.scavSee = self.scavSee + 1 -- 3037
			if self.scavSee >= 24 then -- 3037
				self.scavChase = true -- 3039
				self.scavState = "chase" -- 3040
				self.scavTargetX = p.x -- 3041
				self:flashSet("他看见你了", 1.2) -- 3042
			end -- 3042
		else -- 3042
			self.scavSee = 0 -- 3045
		end -- 3045
		return -- 3047
	end -- 3047
	local dir = p.x > self.scavX and 1 or -1 -- 3050
	self.scavX = self.scavX + dir * 96 / 60 -- 3051
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 3051
		self:caught() -- 3053
		return -- 3054
	end -- 3054
	if hidden then -- 3054
		self.scavSee = 0 -- 3058
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 3059
		self.scavT = self.scavT - 1 -- 3060
		if self.scavT <= 0 then -- 3060
			self.scavChase = false -- 3062
			self.scavState = "patrol" -- 3063
			self:flashSet("他失去了目标", 1) -- 3064
		end -- 3064
	end -- 3064
end -- 3016
function Play.prototype.stepDog(self, dt) -- 3070
	local ____temp_45 -- 3071
	if self.room.story == nil then -- 3071
		____temp_45 = nil -- 3071
	else -- 3071
		____temp_45 = self.room.story.dog -- 3071
	end -- 3071
	local dog = ____temp_45 -- 3071
	if dog == nil then -- 3071
		return -- 3073
	end -- 3073
	local p = self.player -- 3075
	local ox = self.ox -- 3076
	local dist = math.abs(p.x - self.dogX) -- 3077
	local inBurrowCover = p.crouch and p.x >= ox + 300 and p.x <= ox + 460 -- 3078
	local inBrushCover = p.crouch and (p.x >= ox + 700 and p.x <= ox + 790 or p.x >= ox + 1150 and p.x <= ox + 1240) -- 3079
	local sheltered = inBurrowCover or inBrushCover -- 3083
	local inDitchSprint = not p.crouch and self.forestPath == "ditch" and p.x >= ox + 700 and p.x <= ox + 1140 -- 3084
	local effectiveRange = inDitchSprint and dog.range * 1.25 or dog.range -- 3085
	local earNeedTicks = inDitchSprint and 12 or 18 -- 3086
	if self.dogState == "patrol" then -- 3086
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 3088
		if self.dogX < dog.x0 then -- 3088
			self.dogX = dog.x0 -- 3090
			self.dogDir = 1 -- 3091
		elseif self.dogX > dog.x1 then -- 3091
			self.dogX = dog.x1 -- 3093
			self.dogDir = -1 -- 3094
		end -- 3094
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 3096
		if not sheltered and not p.crouch and moving and dist < effectiveRange then -- 3096
			self.dogState = "ear" -- 3098
			self.dogT = earNeedTicks -- 3099
			self.dogTargetX = p.x -- 3100
			self:flashSet(inDitchSprint and "旧渠枯枝响 · 狗立刻转耳" or "狗转耳朵", 0.8) -- 3101
		end -- 3101
		return -- 3103
	end -- 3103
	if self.dogState == "ear" then -- 3103
		if sheltered then -- 3103
			self.dogState = "sniff" -- 3107
			self.dogT = 45 -- 3108
			self:flashSet("钻进遮蔽 · 狗顿住了", 0.9) -- 3109
			return -- 3110
		end -- 3110
		self.dogT = self.dogT - 1 -- 3112
		if self.dogT <= 0 then -- 3112
			self.dogState = "chase" -- 3114
			self.dogTargetX = p.x -- 3115
			self:flashSet("狗追来了", 1.4) -- 3116
		end -- 3116
		return -- 3118
	end -- 3118
	if self.dogState == "chase" then -- 3118
		local dir = p.x > self.dogX and 1 or -1 -- 3121
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 3122
		if not sheltered and math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 3122
			self:caught() -- 3124
			self.dogState = "sniff" -- 3125
			self.dogT = 60 -- 3126
		elseif dist > effectiveRange * 1.5 or p.crouch or sheltered then -- 3126
			self.dogState = "sniff" -- 3128
			self.dogT = 60 -- 3129
			self:flashSet(inBurrowCover and "树根窄洞遮住身形 · 狗停下了" or "狗停下了", 0.9) -- 3130
		end -- 3130
		return -- 3132
	end -- 3132
	if self.dogState == "sniff" then -- 3132
		self.dogT = self.dogT - 1 -- 3135
		if self.dogT <= 0 then -- 3135
			self.dogState = "back" -- 3137
		end -- 3137
		return -- 3139
	end -- 3139
	local dir = dog.x0 > self.dogX and 1 or -1 -- 3142
	self.dogX = self.dogX + dir * dog.speed * dt -- 3143
	if math.abs(self.dogX - dog.x0) < 2 then -- 3143
		self.dogX = dog.x0 -- 3145
		self.dogState = "patrol" -- 3146
	end -- 3146
end -- 3070
function Play.prototype.stepForestRoute(self) -- 3151
	local p = self.player -- 3152
	local ox = self.ox -- 3153
	if self.forestPath == "" then -- 3153
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 3153
			self.forestPath = "burrow" -- 3156
			self.run.story.segments.forest_burrow = true -- 3157
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 3158
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 3159
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 3159
			self.forestPath = "ditch" -- 3161
			self.run.story.segments.forest_ditch = true -- 3162
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 3163
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 3164
		end -- 3164
	end -- 3164
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 3164
		self.waterSeen = true -- 3168
		self.run.story.segments.water_lantern = true -- 3169
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 3170
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 3171
	end -- 3171
end -- 3151
function Play.prototype.caught(self) -- 3175
	self.caughtT = 1 -- 3176
	self:flashSet("被抓 · 回到安全点", 1.6) -- 3177
end -- 3175
function Play.prototype.recoverFromCaught(self) -- 3181
	local p = self.player -- 3182
	p.x = self.ox + 140 -- 3183
	p.y = 0 -- 3184
	p.vy = 0 -- 3185
	p.vx = 0 -- 3186
	p.onGround = true -- 3187
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3187
		self.scavX = self.room.scavenger.x0 -- 3189
		self.scavState = "patrol" -- 3190
		self.scavSee = 0 -- 3191
		self.scavChase = false -- 3192
		self.scavT = 0 -- 3193
	end -- 3193
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3193
		self.dogX = self.room.story.dog.x0 -- 3196
		self.dogState = "patrol" -- 3197
		self.dogT = 0 -- 3198
	end -- 3198
	self.cam.x = p.x -- 3200
	self.cam.y = p.y + CAM_LOOK_UP -- 3201
	self:flashSet("回到安全点", 1.2) -- 3202
end -- 3181
function Play.prototype.updateGate(self) -- 3206
	if self.room.key ~= "checkpoint" then -- 3206
		self.gateOpen = false -- 3208
		return -- 3209
	end -- 3209
	local function inZone(x) -- 3211
		return x >= self.ox + 792 and x <= self.ox + 928 -- 3211
	end -- 3211
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 3212
end -- 3206
function Play.prototype.addItem(self, kind) -- 3218
	local inv = self.run.inventory -- 3219
	if kind == "shield" then -- 3219
		if inv.shield >= TOOL_CAP then -- 3219
			return false -- 3222
		end -- 3222
		inv.shield = inv.shield + 1 -- 3224
		return true -- 3225
	end -- 3225
	if kind == "wedge" then -- 3225
		if inv.wedge >= CONSUMABLE_CAP then -- 3225
			return false -- 3229
		end -- 3229
		inv.wedge = inv.wedge + 1 -- 3231
		return true -- 3232
	end -- 3232
	if kind == "ammo" then -- 3232
		if inv.ammo >= CONSUMABLE_CAP then -- 3232
			return false -- 3236
		end -- 3236
		inv.ammo = inv.ammo + 1 -- 3238
		return true -- 3239
	end -- 3239
	if kind == "scrap" then -- 3239
		inv.scrap = inv.scrap + 1 -- 3243
		return true -- 3244
	end -- 3244
	if kind == "wood" then -- 3244
		inv.wood = inv.wood + 1 -- 3247
		return true -- 3248
	end -- 3248
	if kind == "bell" then -- 3248
		inv.bell = inv.bell + 1 -- 3251
		return true -- 3252
	end -- 3252
	if kind == "pass" then -- 3252
		inv.pass = inv.pass + 1 -- 3255
		return true -- 3256
	end -- 3256
	if kind == "quickbelt" then -- 3256
		inv.quickbelt = inv.quickbelt + 1 -- 3259
		return true -- 3260
	end -- 3260
	return false -- 3262
end -- 3218
function Play.prototype.findBox(self, id) -- 3265
	local i = 0 -- 3266
	do -- 3266
		i = 0 -- 3267
		while i < #self.boxes do -- 3267
			if self.boxes[i + 1].id == id then -- 3267
				return self.boxes[i + 1] -- 3269
			end -- 3269
			i = i + 1 -- 3267
		end -- 3267
	end -- 3267
	return nil -- 3272
end -- 3265
function Play.prototype.findWedgeTarget(self) -- 3276
	local best = nil -- 3277
	local bestD = 0 -- 3278
	local i = 0 -- 3279
	do -- 3279
		i = 0 -- 3280
		while i < #self.boxes do -- 3280
			do -- 3280
				local b = self.boxes[i + 1] -- 3281
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3281
					goto __continue494 -- 3283
				end -- 3283
				if not self:nearBox(b, 26) then -- 3283
					goto __continue494 -- 3286
				end -- 3286
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3288
				if best == nil or d < bestD then -- 3288
					best = b -- 3290
					bestD = d -- 3291
				end -- 3291
			end -- 3291
			::__continue494:: -- 3291
			i = i + 1 -- 3280
		end -- 3280
	end -- 3280
	return best -- 3294
end -- 3276
function Play.prototype.stepCraft(self, input) -- 3302
	local inv = self.run.inventory -- 3303
	local required = math.max( -- 3304
		6, -- 3304
		CRAFT_TICKS - 6 * self:talentRank("craft") -- 3304
	) -- 3304
	if self.craftT > 0 then -- 3304
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3304
			self.craftT = 0 -- 3308
			self:flashSet("制作中断", 0.8) -- 3309
			return true -- 3310
		end -- 3310
		self.craftT = self.craftT + 1 -- 3312
		if self.craftT >= required then -- 3312
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3312
				inv.scrap = inv.scrap - 1 -- 3315
				inv.wedge = inv.wedge + 1 -- 3316
				self:flashSet("制得木楔", 1.2) -- 3317
				self:log("制木楔") -- 3318
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3319
			end -- 3319
			self.craftT = 0 -- 3321
		end -- 3321
		return true -- 3323
	end -- 3323
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3323
		self.craftT = 1 -- 3326
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3327
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3328
		return true -- 3329
	end -- 3329
	return false -- 3331
end -- 3302
function Play.prototype.nearBox(self, b, reach) -- 3334
	local p = self.player -- 3335
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3336
end -- 3334
function Play.prototype.findInteract(self) -- 3342
	local p = self.player -- 3343
	local best = nil -- 3344
	local bestD = 1000000000 -- 3345
	local i = 0 -- 3346
	do -- 3346
		i = 0 -- 3347
		while i < #self.boxes do -- 3347
			do -- 3347
				local b = self.boxes[i + 1] -- 3348
				if b.interact == nil or b.broken == true then -- 3348
					goto __continue507 -- 3350
				end -- 3350
				if not self:nearBox(b, b.interact.reach or 27) then -- 3350
					goto __continue507 -- 3353
				end -- 3353
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3355
				if d < bestD then -- 3355
					bestD = d -- 3357
					best = b -- 3358
				end -- 3358
			end -- 3358
			::__continue507:: -- 3358
			i = i + 1 -- 3347
		end -- 3347
	end -- 3347
	return best -- 3361
end -- 3342
function Play.prototype.stepCampaign(self, dt, input) -- 3365
	local wr = self.room -- 3366
	local p = self.player -- 3367
	if self.reloadT > 0 then -- 3367
		self.reloadT = self.reloadT - 1 -- 3369
	end -- 3369
	if self.bracedShield ~= nil then -- 3369
		self.bracedShield.x = p.x + p.facing * 26 -- 3373
		self.bracedShield.y = p.y -- 3374
		local shBox = __TS__ArrayFind( -- 3375
			self.boxes, -- 3375
			function(____, b) return b.id == "braced_shield" end -- 3375
		) -- 3375
		if shBox ~= nil then -- 3375
			shBox.x0 = self.bracedShield.x - 15 -- 3377
			shBox.x1 = self.bracedShield.x + 15 -- 3378
			shBox.y0 = self.bracedShield.y -- 3379
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3380
		end -- 3380
	end -- 3380
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3380
		self.run.route = "drygoods" -- 3386
		self.run.joined = false -- 3387
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3388
		self:log("转布行线") -- 3389
	end -- 3389
	if wr.key == "escort3" then -- 3389
		local benchX = wr.minX + 560 -- 3393
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 60 -- 3394
		if nearBench and input.interact.pressed then -- 3394
			self:openCraftBench() -- 3396
		end -- 3396
	end -- 3396
	local i = 0 -- 3400
	do -- 3400
		i = 0 -- 3401
		while i < #self.pickups do -- 3401
			do -- 3401
				local pk = self.pickups[i + 1] -- 3402
				if self.run.taken[pk.id] == true then -- 3402
					goto __continue520 -- 3404
				end -- 3404
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3406
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3407
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3407
					if not self:addItem(pk.kind) then -- 3407
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3411
						self:log("满包拒绝 " .. pk.kind) -- 3412
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3413
						goto __continue520 -- 3414
					end -- 3414
					self.run.taken[pk.id] = true -- 3416
					self:flashSet("拾取 " .. pk.label, 1) -- 3417
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3418
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3419
				end -- 3419
			end -- 3419
			::__continue520:: -- 3419
			i = i + 1 -- 3401
		end -- 3401
	end -- 3401
	if not self:stepCraft(input) and input.interact.pressed then -- 3401
		self:campaignInteract() -- 3423
	end -- 3423
	self:stepCampaignCart(dt, input) -- 3425
	self:stepCampaignGoal() -- 3426
	self:campaignCheckpoint() -- 3427
end -- 3365
function Play.prototype.campaignCheckpoint(self) -- 3431
	local i = 0 -- 3432
	do -- 3432
		i = 0 -- 3433
		while i < #self.room.marks do -- 3433
			do -- 3433
				local m = self.room.marks[i + 1] -- 3434
				if m.kind ~= 0 then -- 3434
					goto __continue527 -- 3436
				end -- 3436
				local dx = self.player.x - m.x -- 3438
				local dy = self.player.y - m.y -- 3439
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3439
					self.checkpoint = m.x -- 3441
					self:captureCheckpoint(m.x) -- 3442
					self:flashSet("检查点", 1) -- 3443
				end -- 3443
			end -- 3443
			::__continue527:: -- 3443
			i = i + 1 -- 3433
		end -- 3433
	end -- 3433
end -- 3431
function Play.prototype.campaignInteract(self) -- 3449
	local b = self:findInteract() -- 3450
	if b ~= nil then -- 3450
		self:useInteract(b) -- 3452
		return -- 3453
	end -- 3453
	local inv = self.run.inventory -- 3455
	if inv.wedge > 0 then -- 3455
		local w = self:findWedgeTarget() -- 3457
		if w ~= nil then -- 3457
			if w.breakable ~= nil then -- 3457
				local ____w_breakable_46, ____hp_47 = w.breakable, "hp" -- 3457
				____w_breakable_46[____hp_47] = ____w_breakable_46[____hp_47] + (w.breakable.wedgeHp or 1) -- 3460
			end -- 3460
			inv.wedge = inv.wedge - 1 -- 3462
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3463
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 3465
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3466
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3467
			return -- 3468
		end -- 3468
	end -- 3468
	if inv.ammo > 0 and self.reloadT > 0 then -- 3468
		self.reloadT = 0 -- 3473
		self:closeReloadPuzzle() -- 3474
		inv.ammo = inv.ammo - 1 -- 3475
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3476
		self:log("用备用弹包") -- 3477
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3478
		return -- 3479
	end -- 3479
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 3479
		local p = self.player -- 3483
		self.bracedShield = { -- 3484
			x = p.x + p.facing * 26, -- 3484
			y = p.y, -- 3484
			w = 30, -- 3484
			h = 64, -- 3484
			hp = 1 -- 3484
		} -- 3484
		local ____self_boxes_48 = self.boxes -- 3484
		____self_boxes_48[#____self_boxes_48 + 1] = { -- 3485
			x0 = self.bracedShield.x - 15, -- 3486
			x1 = self.bracedShield.x + 15, -- 3486
			y0 = p.y, -- 3487
			y1 = p.y + 64, -- 3487
			depth = {min = -46, max = 46}, -- 3487
			label = "架起的残盾", -- 3487
			id = "braced_shield", -- 3487
			soft = true -- 3488
		} -- 3488
		inv.shield = inv.shield - 1 -- 3491
		self:flashSet("架残盾 · 挡一发", 1.2) -- 3492
		self:log("架残盾") -- 3493
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3494
		return -- 3495
	end -- 3495
	if inv.pass > 0 and self.run.joined == false then -- 3495
		inv.pass = inv.pass - 1 -- 3498
		self.run.joined = true -- 3499
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3500
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3501
		return -- 3502
	end -- 3502
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3504
end -- 3449
function Play.prototype.useInteract(self, b) -- 3507
	local kind = b.interact == nil and "" or b.interact.kind -- 3508
	local wr = self.room -- 3509
	if kind == "open_board" then -- 3509
		b.broken = true -- 3511
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3512
		for ____, cover in ipairs(self.boxes) do -- 3513
			if cover.id == "s2_board_cover" then -- 3513
				cover.broken = false -- 3515
				cover.hidden = false -- 3516
			end -- 3516
		end -- 3516
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3519
		self.run.joined = true -- 3520
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3521
		self:log("放下窗板") -- 3522
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3523
		return -- 3524
	end -- 3524
	if kind == "lower_curtain" then -- 3524
		for ____, curtain in ipairs(self.boxes) do -- 3527
			if curtain.id == "c2_curtain" then -- 3527
				curtain.broken = false -- 3529
				curtain.hidden = false -- 3530
			end -- 3530
		end -- 3530
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3533
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3534
		self:log("放下木帘") -- 3535
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3536
		return -- 3537
	end -- 3537
	if kind == "raise_latch" then -- 3537
		if wr.key == "c2-granary" and not self.cartDocked then -- 3537
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3541
			return -- 3542
		end -- 3542
		b.broken = true -- 3544
		self.objectiveDone = true -- 3545
		if wr.key == "c1-yard" then -- 3545
			self.run.c1Latch = true -- 3548
			self.run.joined = true -- 3549
			for ____, door in ipairs(self.boxes) do -- 3550
				if door.id == "c1_door" then -- 3550
					door.broken = true -- 3552
				end -- 3552
			end -- 3552
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3555
		else -- 3555
			self.run.c2Latch = true -- 3557
			self.run.joined = true -- 3558
		end -- 3558
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3560
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3561
		self:log("抬闩") -- 3562
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3563
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3564
	end -- 3564
end -- 3507
function Play.prototype.stepCampaignCart(self, dt, input) -- 3569
	local wr = self.room -- 3570
	local c = wr.cart -- 3571
	if c.bodyW <= 0 then -- 3571
		return -- 3573
	end -- 3573
	local p = self.player -- 3575
	local handleX = self.cartAxle + c.handleOffset -- 3576
	if not self.gripping then -- 3576
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3576
			self.gripping = true -- 3580
			self:flashSet("握住车柄 · A/D 推", 1) -- 3581
		end -- 3581
		return -- 3583
	end -- 3583
	if input.interact.pressed then -- 3583
		self.gripping = false -- 3586
		self:flashSet("松手", 0.5) -- 3587
		return -- 3588
	end -- 3588
	if not self.cartDocked then -- 3588
		if input.moveX ~= 0 and not self:stuckCart() then -- 3588
			self.cartAxle = math.max( -- 3592
				c.startX, -- 3592
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3592
			) -- 3592
		end -- 3592
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3592
			self.cartExposed = true -- 3597
			local gun = nil -- 3598
			local gi = 0 -- 3599
			do -- 3599
				gi = 0 -- 3600
				while gi < #self.enemies do -- 3600
					local e = self.enemies[gi + 1] -- 3601
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3601
						gun = e -- 3603
						break -- 3604
					end -- 3604
					gi = gi + 1 -- 3600
				end -- 3600
			end -- 3600
			if gun ~= nil then -- 3600
				self:campaignEnemyFire(gun) -- 3608
			end -- 3608
		end -- 3608
		p.x = self.cartAxle + c.handleOffset -- 3611
		p.y = c.baseY -- 3612
		p.depth = c.depth or 0 -- 3613
		p.vx = 0 -- 3614
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3614
			self.cartAxle = c.endX -- 3616
			self.cartDocked = true -- 3617
			self.gripping = false -- 3618
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3619
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3620
			self:flashSet("车轮入窝", 1.2) -- 3621
			self:log("车轮入窝") -- 3622
		end -- 3622
	end -- 3622
end -- 3569
function Play.prototype.stuckCart(self) -- 3628
	local i = 0 -- 3629
	do -- 3629
		i = 0 -- 3630
		while i < #self.boxes do -- 3630
			do -- 3630
				local b = self.boxes[i + 1] -- 3631
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3631
					goto __continue569 -- 3633
				end -- 3633
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3635
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3635
					return true -- 3637
				end -- 3637
			end -- 3637
			::__continue569:: -- 3637
			i = i + 1 -- 3630
		end -- 3630
	end -- 3630
	return false -- 3640
end -- 3628
function Play.prototype.stepCampaignGoal(self) -- 3644
	local wr = self.room -- 3645
	local c = wr.campaign -- 3646
	if c == nil then -- 3646
		return -- 3648
	end -- 3648
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3648
		self.objectiveDone = true -- 3651
	end -- 3651
	if c.goal == "reach_exit" then -- 3651
		self.objectiveDone = true -- 3654
	end -- 3654
	if not self.objectiveDone then -- 3654
		return -- 3657
	end -- 3657
	local p = self.player -- 3659
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3660
	if p.x < c.exitX or not partnerOk then -- 3660
		return -- 3662
	end -- 3662
	if self.run.story.segments[wr.key] ~= true then -- 3662
		self.run.story.segments[wr.key] = true -- 3666
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3667
	end -- 3667
	if wr.key == "escort5" then -- 3667
		self.escortDone = true -- 3671
		self.run.story.escortDone = true -- 3672
	end -- 3672
	if c.next ~= nil and c.next ~= "" then -- 3672
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3675
		self:flashSet("过关 · " .. c.next, 1.2) -- 3676
	elseif wr.key == "c2-granary" and self.run.trial == nil and (self.run.source == "official" or self.run.source == "chapter") then -- 3676
		self:requestRoom("gate", "军粮棚出口") -- 3679
		self:flashSet("出军粮棚 · 城门", 1.4) -- 3680
	elseif not self.run.finished then -- 3680
		self.run.finished = true -- 3682
		self:flashSet( -- 3683
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3683
			2 -- 3683
		) -- 3683
		self:log("C2 灰盒完成") -- 3684
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3685
	end -- 3685
end -- 3644
function Play.prototype.stepCampaignPartner(self, dt) -- 3690
	local a = self.partner -- 3691
	local wr = self.room -- 3692
	local cp = wr.companion -- 3693
	if not a.alive then -- 3693
		return -- 3695
	end -- 3695
	local p = self.player -- 3697
	if self.craftBench.active then -- 3697
		a.vx = 0 -- 3700
		return -- 3701
	end -- 3701
	local wait = false -- 3703
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3704
	local targetDepth = p.depth -- 3705
	if self.run.joined == false then -- 3705
		wait = true -- 3707
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3708
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3709
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3709
		wait = true -- 3711
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3712
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3713
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3713
		wait = true -- 3715
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3716
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3717
	end -- 3717
	if self.partnerStuck > 0.3 then -- 3717
		a.x = a.x + a.facing * 44 -- 3721
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3722
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3723
		self.partnerLaneHold = 1.1 -- 3724
		self.partnerStuck = 0 -- 3725
	end -- 3725
	if self.partnerLaneHold > 0 then -- 3725
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3728
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3729
	end -- 3729
	local dx = targetX - a.x -- 3731
	if not wait and math.abs(dx) > 74 then -- 3731
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3733
		local before = a.x -- 3734
		a.vx = dx > 0 and speed or -speed -- 3735
		a.facing = dx > 0 and 1 or -1 -- 3736
		self:slideX(a, a.vx * dt) -- 3737
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3737
			a.vy = CHILD_JUMP -- 3740
			a.onGround = false -- 3741
		end -- 3741
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3743
	else -- 3743
		a.vx = 0 -- 3745
		self.partnerStuck = 0 -- 3746
	end -- 3746
	local dz = targetDepth - a.depth -- 3748
	if math.abs(dz) > 6 then -- 3748
		local step = math.max( -- 3750
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3750
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3750
		) -- 3750
		a.depth = a.depth + step -- 3751
	end -- 3751
	a.depthSpeed = 0 -- 3753
	a.h = CHILD_H -- 3754
	a.crouch = false -- 3755
	self:fallY(a, dt) -- 3756
end -- 3690
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3760
	local p = self.player -- 3761
	local i = 0 -- 3762
	do -- 3762
		i = 0 -- 3763
		while i < #self.enemies do -- 3763
			do -- 3763
				local ____opt_49 = self.run.trial -- 3763
				if ____opt_49 and ____opt_49.lost then -- 3763
					return -- 3764
				end -- 3764
				local e = self.enemies[i + 1] -- 3765
				if not e.alive then -- 3765
					goto __continue597 -- 3767
				end -- 3767
				if e.hitT > 0 then -- 3767
					e.hitT = e.hitT - dt -- 3770
				end -- 3770
				if e.kind == "target" then -- 3770
					if not e.alive and e.hitT <= 0 then -- 3770
						e.alive = true -- 3775
					end -- 3775
					goto __continue597 -- 3777
				end -- 3777
				if e.kind == "breaker" then -- 3777
					self:stepBreaker(e, dt) -- 3780
					goto __continue597 -- 3781
				end -- 3781
				if e.kind == "shield" then -- 3781
					self:stepShield(e, dt, input) -- 3784
					goto __continue597 -- 3785
				end -- 3785
				local dx = e.x - p.x -- 3788
				if not e.awake then -- 3788
					if math.abs(dx) > 520 then -- 3788
						goto __continue597 -- 3791
					end -- 3791
					e.awake = true -- 3793
					e.fireCd = 48 -- 3794
					goto __continue597 -- 3795
				end -- 3795
				if math.abs(dx) > ENEMY_RANGE then -- 3795
					goto __continue597 -- 3798
				end -- 3798
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 3798
					goto __continue597 -- 3803
				end -- 3803
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 3803
					goto __continue597 -- 3806
				end -- 3806
				if self:blockedShot(e, p) then -- 3806
					if e.warnT > 0 then -- 3806
						e.warnT = 0 -- 3812
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3813
					end -- 3813
					goto __continue597 -- 3815
				end -- 3815
				if e.warnT > 0 then -- 3815
					e.warnT = e.warnT - 1 -- 3818
					if e.warnT <= 0 then -- 3818
						self:campaignEnemyFire(e) -- 3820
					end -- 3820
				elseif e.fireCd > 0 then -- 3820
					e.fireCd = e.fireCd - 1 -- 3823
					if e.fireCd <= 0 then -- 3823
						e.warnT = WARN_TICKS -- 3825
					end -- 3825
				else -- 3825
					e.fireCd = 40 -- 3828
				end -- 3828
			end -- 3828
			::__continue597:: -- 3828
			i = i + 1 -- 3763
		end -- 3763
	end -- 3763
end -- 3760
function Play.prototype.blockedShot(self, e, p) -- 3834
	local eDepth = e.depth or 0 -- 3835
	local ex = e.x -- 3836
	local ey = e.y + e.h * 0.62 -- 3838
	local px = p.x -- 3839
	local py = p.y + p.h * 0.55 -- 3840
	local dx = px - ex -- 3841
	local dyScreen = py + p.depth - (ey + eDepth) -- 3842
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3843
	if len < 0.01 then -- 3843
		return false -- 3845
	end -- 3845
	local ray = { -- 3849
		x = ex, -- 3850
		y = ey, -- 3850
		dx = dx / len, -- 3851
		dy = (py - ey) / len, -- 3851
		depth = eDepth, -- 3852
		dDepth = (p.depth - eDepth) / len -- 3852
	} -- 3852
	local best = -1 -- 3854
	local j = 0 -- 3855
	do -- 3855
		j = 0 -- 3856
		while j < #self.boxes do -- 3856
			do -- 3856
				local b = self.boxes[j + 1] -- 3857
				if b.broken == true or b.passable == true or b.hidden == true then -- 3857
					goto __continue620 -- 3859
				end -- 3859
				if b.id == "braced_shield" then -- 3859
					goto __continue620 -- 3864
				end -- 3864
				local t = hitBox(ray, b) -- 3866
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3866
					best = t -- 3870
				end -- 3870
			end -- 3870
			::__continue620:: -- 3870
			j = j + 1 -- 3856
		end -- 3856
	end -- 3856
	return best >= 0 -- 3873
end -- 3834
function Play.prototype.campaignEnemyFire(self, e) -- 3876
	local p = self.player -- 3877
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3878
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3878
		local ____self_bracedShield_51, ____hp_52 = self.bracedShield, "hp" -- 3878
		____self_bracedShield_51[____hp_52] = ____self_bracedShield_51[____hp_52] - 1 -- 3880
		self.boxes = __TS__ArrayFilter( -- 3881
			self.boxes, -- 3881
			function(____, b) return b.id ~= "braced_shield" end -- 3881
		) -- 3881
		self.bracedShield = nil -- 3882
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3883
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3884
		return -- 3885
	end -- 3885
	if self:blockedShot(e, p) then -- 3885
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3888
		return -- 3889
	end -- 3889
	local cover = self:blockedByCover(e, p) -- 3891
	if cover ~= nil and self.coverHug then -- 3891
		self.coveredFlash = 0.5 -- 3893
		self:flashSet("掩体挡下", 0.6) -- 3894
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3895
		return -- 3900
	end -- 3900
	if self.invulnT > 0 then -- 3900
		return -- 3903
	end -- 3903
	self.invulnT = INVULN_HIT_TICKS + 12 * self:talentRank("guard") -- 3905
	self.craftT = 0 -- 3906
	self.hp = self.hp - 1 -- 3907
	self:emit("actorHit", { -- 3908
		target = "player", -- 3908
		amount = 1, -- 3908
		hp = self.hp, -- 3908
		maxHp = self.maxHp, -- 3908
		enemyX = e.x -- 3908
	}) -- 3908
	self:flashSet( -- 3909
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3909
		0.8 -- 3909
	) -- 3909
	if self.hp <= 0 then -- 3909
		self:campaignFailed() -- 3911
	end -- 3911
end -- 3876
function Play.prototype.stepShield(self, e, dt, input) -- 3916
	local p = self.player -- 3917
	local dx = p.x - e.x -- 3918
	local adx = math.abs(dx) -- 3919
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 3922
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 3923
	if adx > 150 then -- 3923
		local before = e.x -- 3925
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 3926
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 3926
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3929
		end -- 3929
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 3929
		local fromFront = (e.x - p.x) * p.facing > 0 -- 3934
		local rollDodges = p.rollT > 0 and fromFront -- 3935
		if not rollDodges and self.invulnT <= 0 then -- 3935
			self.invulnT = INVULN_HIT_TICKS + 12 * self:talentRank("guard") -- 3937
			self.craftT = 0 -- 3938
			self.hp = self.hp - 1 -- 3939
			self:emit("actorHit", { -- 3940
				target = "player", -- 3940
				amount = 1, -- 3940
				hp = self.hp, -- 3940
				maxHp = self.maxHp, -- 3940
				enemyX = e.x -- 3940
			}) -- 3940
			self:flashSet( -- 3941
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3941
				0.8 -- 3941
			) -- 3941
			if self.hp <= 0 then -- 3941
				self:campaignFailed() -- 3943
				return -- 3944
			end -- 3944
		end -- 3944
		e.swingT = 70 -- 3947
	end -- 3947
	if (e.swingT or 0) > 0 then -- 3947
		e.swingT = (e.swingT or 0) - 1 -- 3950
	end -- 3950
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 3950
		local dd = p.depth - (e.depth or 0) -- 3953
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 3954
	end -- 3954
end -- 3916
function Play.prototype.stepBreaker(self, e, dt) -- 3959
	local p = self.player -- 3960
	if e.awake ~= true then -- 3960
		if math.abs(p.x - e.x) < 560 then -- 3960
			e.awake = true -- 3963
		else -- 3963
			return -- 3965
		end -- 3965
	end -- 3965
	local target = nil -- 3968
	local bestD = 1000000000 -- 3969
	local i = 0 -- 3970
	do -- 3970
		i = 0 -- 3971
		while i < #self.boxes do -- 3971
			do -- 3971
				local b = self.boxes[i + 1] -- 3972
				if b.breakable == nil or b.broken == true then -- 3972
					goto __continue644 -- 3974
				end -- 3974
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 3976
				if d < bestD then -- 3976
					bestD = d -- 3978
					target = b -- 3979
				end -- 3979
			end -- 3979
			::__continue644:: -- 3979
			i = i + 1 -- 3971
		end -- 3971
	end -- 3971
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 3982
	local dx = tx - e.x -- 3983
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 3984
	if math.abs(dx) > reach then -- 3984
		local before = e.x -- 3986
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 3987
		if math.abs(e.x - before) < 0.3 then -- 3987
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3989
		end -- 3989
	elseif (e.swingT or 0) <= 0 then -- 3989
		e.swingT = 64 -- 3992
		if target ~= nil then -- 3992
			self:damageProp(target, 2) -- 3994
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 3994
			self.invulnT = INVULN_HIT_TICKS + 12 * self:talentRank("guard") -- 3996
			self.craftT = 0 -- 3997
			self.hp = self.hp - 1 -- 3998
			self:emit("actorHit", { -- 3999
				target = "player", -- 3999
				amount = 1, -- 3999
				hp = self.hp, -- 3999
				maxHp = self.maxHp, -- 3999
				enemyX = e.x -- 3999
			}) -- 3999
			self:flashSet("破障手近身", 0.8) -- 4000
			if self.hp <= 0 then -- 4000
				self:campaignFailed() -- 4002
				return -- 4003
			end -- 4003
		end -- 4003
	end -- 4003
	if (e.swingT or 0) > 0 then -- 4003
		e.swingT = (e.swingT or 0) - 1 -- 4008
	end -- 4008
end -- 3959
function Play.prototype.campaignFailed(self) -- 4012
	if self.run.trial ~= nil then -- 4012
		self.run.trial.lost = true -- 4014
		self.wantRoom = "" -- 4015
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4016
		return -- 4017
	end -- 4017
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 4017
		self:restartEscortFromDeath() -- 4022
		return -- 4023
	end -- 4023
	local p = self.player -- 4025
	self.hp = self.maxHp -- 4026
	self.invulnT = INVULN_RESPAWN_TICKS -- 4027
	self.reloadT = 0 -- 4028
	self:closeReloadPuzzle() -- 4029
	self.gripping = false -- 4030
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 4031
	self:log("被击倒") -- 4032
	p.x = self.room.minX + 90 -- 4033
	p.y = 0 -- 4034
	p.depth = 0 -- 4035
	p.vx = 0 -- 4036
	p.vy = 0 -- 4037
	p.onGround = true -- 4038
	p.rollT = 0 -- 4039
	self.partner.x = p.x - 50 -- 4040
	self.partner.y = 0 -- 4041
	self.partner.depth = 0 -- 4042
	self.cam.x = p.x -- 4043
	local i = 0 -- 4044
	do -- 4044
		i = 0 -- 4045
		while i < #self.enemies do -- 4045
			do -- 4045
				local e = self.enemies[i + 1] -- 4046
				if not e.alive then -- 4046
					goto __continue658 -- 4048
				end -- 4048
				e.x = e.homeX == nil and e.x or e.homeX -- 4050
				e.warnT = 0 -- 4051
				e.fireCd = 40 -- 4052
				e.swingT = 0 -- 4053
				e.awake = false -- 4054
			end -- 4054
			::__continue658:: -- 4054
			i = i + 1 -- 4045
		end -- 4045
	end -- 4045
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4056
end -- 4012
function Play.prototype.isEscortRoom(self) -- 4060
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 4061
end -- 4060
function Play.prototype.restartEscortFromDeath(self) -- 4069
	local story = self.run.story -- 4070
	local inv = self.run.inventory -- 4071
	local vitBonus = story.talents ~= nil and story.talents.ranks.vitality or 0 -- 4072
	if vitBonus > 0 then -- 4072
		self.maxHp = math.max(3, self.maxHp - vitBonus) -- 4074
		story.maxHp = self.maxHp -- 4075
	end -- 4075
	story.talents = createStoryTalents(self.run.seed) -- 4077
	self.hp = self.maxHp -- 4078
	story.hp = self.maxHp -- 4079
	story.cp = nil -- 4080
	self.checkpointSnap = nil -- 4081
	story.carry = false -- 4082
	self.carryOn = false -- 4083
	story.craftedWeapon = "" -- 4084
	self.equippedWeapon = "standard_gun" -- 4085
	story.escortDone = false -- 4086
	self.escortDone = false -- 4087
	story.segments = {} -- 4088
	inv.wood = 0 -- 4089
	inv.bell = 0 -- 4090
	inv.scrap = 0 -- 4091
	inv.wedge = 0 -- 4092
	inv.ammo = 0 -- 4093
	inv.quickbelt = 0 -- 4094
	inv.shield = 0 -- 4095
	inv.pass = 0 -- 4096
	local taken = self.run.taken -- 4097
	local keys = __TS__ObjectKeys(taken) -- 4098
	local i = 0 -- 4099
	do -- 4099
		i = 0 -- 4100
		while i < #keys do -- 4100
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 4100
				__TS__Delete(taken, keys[i + 1]) -- 4102
			end -- 4102
			i = i + 1 -- 4100
		end -- 4100
	end -- 4100
	self.run.joined = true -- 4105
	self.reloadT = 0 -- 4106
	self:closeReloadPuzzle() -- 4107
	self.gripping = false -- 4108
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 4109
	self:log("男主线失败 · 回 escort1") -- 4110
	self:emit("campaignFailed", { -- 4111
		room = self.room.key, -- 4112
		hp = 0, -- 4112
		maxHp = self.maxHp, -- 4112
		reset = true, -- 4113
		to = "escort1", -- 4113
		route = self.storyRoute -- 4113
	}) -- 4113
	self:requestRoom("escort1", "男主线失败重开") -- 4115
end -- 4069
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 4119
	local i = 0 -- 4120
	do -- 4120
		i = 0 -- 4121
		while i < #self.enemies do -- 4121
			do -- 4121
				if i == skipIndex then -- 4121
					goto __continue668 -- 4123
				end -- 4123
				local e = self.enemies[i + 1] -- 4125
				if not e.alive or math.abs(e.x - center.x) > radius then -- 4125
					goto __continue668 -- 4127
				end -- 4127
				e.fireCd = 150 -- 4129
				e.warnT = 0 -- 4130
			end -- 4130
			::__continue668:: -- 4130
			i = i + 1 -- 4121
		end -- 4121
	end -- 4121
end -- 4119
function Play.prototype.stepEnemies(self, dt, input) -- 4134
	local i = 0 -- 4135
	do -- 4135
		i = 0 -- 4136
		while i < #self.enemies do -- 4136
			local e = self.enemies[i + 1] -- 4137
			if e.hitT > 0 then -- 4137
				e.hitT = e.hitT - dt -- 4139
			end -- 4139
			i = i + 1 -- 4136
		end -- 4136
	end -- 4136
	if self.coveredFlash > 0 then -- 4136
		self.coveredFlash = self.coveredFlash - dt -- 4143
	end -- 4143
	if self.isCampaign then -- 4143
		self:stepCampaignEnemies(dt, input) -- 4146
		return -- 4147
	end -- 4147
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 4147
		return -- 4151
	end -- 4151
	do -- 4151
		i = 0 -- 4153
		while i < #self.enemies do -- 4153
			do -- 4153
				local e = self.enemies[i + 1] -- 4154
				if not e.alive then -- 4154
					goto __continue679 -- 4156
				end -- 4156
				if e.warnT > 0 then -- 4156
					e.warnT = e.warnT - 1 -- 4159
					if e.warnT <= 0 then -- 4159
						self:enemyFire(e, input) -- 4161
					end -- 4161
					goto __continue679 -- 4163
				end -- 4163
				if e.fireCd > 0 then -- 4163
					e.fireCd = e.fireCd - 1 -- 4166
					if e.fireCd <= 0 then -- 4166
						e.warnT = WARN_TICKS -- 4168
					end -- 4168
				else -- 4168
					e.warnT = WARN_TICKS -- 4172
				end -- 4172
			end -- 4172
			::__continue679:: -- 4172
			i = i + 1 -- 4153
		end -- 4153
	end -- 4153
end -- 4134
function Play.prototype.enemyFire(self, e, input) -- 4178
	local p = self.player -- 4179
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 4179
		self:flashSet("枪声响在远处", 0.4) -- 4181
		e.fireCd = FIRE_COOLDOWN -- 4182
		return -- 4183
	end -- 4183
	local cover = self:blockedByCover(e, p) -- 4186
	local hugging = cover ~= nil -- 4187
	self.coverBlocking = hugging -- 4188
	local covered = hugging and input.cover.held -- 4189
	if covered then -- 4189
		self.coveredFlash = 0.5 -- 4191
		self:flashSet("掩体挡下", 0.5) -- 4192
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4193
		e.fireCd = FIRE_COOLDOWN -- 4198
		return -- 4199
	end -- 4199
	self.hp = self.hp - 1 -- 4201
	self:emit("actorHit", { -- 4202
		target = "player", -- 4202
		amount = 1, -- 4202
		hp = self.hp, -- 4202
		maxHp = self.maxHp, -- 4202
		enemyX = e.x -- 4202
	}) -- 4202
	self:flashSet( -- 4203
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4203
		0.7 -- 4203
	) -- 4203
	e.fireCd = FIRE_COOLDOWN -- 4204
	if self.hp <= 0 then -- 4204
		self:gateFailed() -- 4206
	end -- 4206
end -- 4178
function Play.prototype.blockedByCover(self, enemy, p) -- 4211
	local b = self:coverAt(p) -- 4212
	if b == nil then -- 4212
		return nil -- 4214
	end -- 4214
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4216
end -- 4211
function Play.prototype.gateFailed(self) -- 4220
	local ____temp_53 -- 4221
	if self.room.story == nil then -- 4221
		____temp_53 = nil -- 4221
	else -- 4221
		____temp_53 = self.room.story.gate -- 4221
	end -- 4221
	local g = ____temp_53 -- 4221
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 4222
	self.hp = self.maxHp -- 4223
	self.gateTick = 0 -- 4224
	self.gateSpawned = 0 -- 4225
	self.enemies = {} -- 4226
	self.gateFailCount = self.gateFailCount + 1 -- 4227
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 4229
	self.player.y = 0 -- 4230
	self.player.vy = 0 -- 4231
	self.player.depth = 0 -- 4232
	self.player.depthSpeed = 0 -- 4233
	self.player.onGround = true -- 4234
	self.player.crouch = false -- 4235
	self.player.h = SOLDIER_H -- 4236
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 4237
	self.partner.y = 0 -- 4238
	self.partner.vy = 0 -- 4239
	self.partner.depth = 0 -- 4240
	self.partner.depthSpeed = 0 -- 4241
	self.partner.onGround = true -- 4242
	self.cam.x = self.player.x -- 4243
	self.phase = "gate-idle" -- 4244
	self.phaseTick = 0 -- 4245
	self.coverHug = false -- 4246
	self.coverBlocking = false -- 4247
	self.coverEntity = "" -- 4248
	self.gateNeedConfirm = true -- 4249
	self.gateRestartArmed = false -- 4250
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 4251
end -- 4220
function Play.prototype.stepRedCart(self, input) -- 4255
	if self.redCartMemoryT > 0 then -- 4255
		self.redCartMemoryT = self.redCartMemoryT - 1 -- 4257
	end -- 4257
	if self.room.key ~= "outside" or self.redCartPulled then -- 4257
		return -- 4260
	end -- 4260
	local box = __TS__ArrayFind( -- 4262
		self.boxes, -- 4262
		function(____, b) return b.id == "outside_red_cart" end -- 4262
	) -- 4262
	if box == nil then -- 4262
		self.redCartPulled = true -- 4264
		return -- 4265
	end -- 4265
	local cx = (box.x0 + box.x1) * 0.5 -- 4267
	local p = self.player -- 4268
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 4268
		return -- 4270
	end -- 4270
	if not input.interact.pressed then -- 4270
		return -- 4273
	end -- 4273
	box.x0 = 430 -- 4275
	box.x1 = 474 -- 4276
	self.cartAxle = self.room.cart.endX -- 4278
	self.cartDocked = true -- 4279
	self.redCartPulled = true -- 4280
	self.redCartMemoryT = 30 -- 4281
	if self.run.story ~= nil then -- 4281
		self.run.story.segments.outside_cart = true -- 4283
		self.run.story.segments.outside_memory = true -- 4284
	end -- 4284
	self.sessionDirty = true -- 4286
	self:flashSet("红布补丁 · 想起家里那一针 · 石阶口露出来", 1.8) -- 4287
	self:emit("storyBeat", {beat = "red_cart", x = p.x, room = "outside"}) -- 4288
	self:emit("storyBeat", {beat = "red_cart_memory", x = p.x, room = "outside", durationTicks = 30}) -- 4289
end -- 4255
function Play.prototype.stepInteract(self, dt, input) -- 4292
	local p = self.player -- 4293
	self:stepRedCart(input) -- 4294
	local calmUsed = self.calmConsumed -- 4295
	self.calmConsumed = false -- 4296
	local calming = self.escort.state == "calming" -- 4298
	self.focusCart = false -- 4299
	if self.room.key == "outside" then -- 4299
		local c = self.room.cart -- 4301
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 4302
		local dy = p.y - c.baseY -- 4303
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 4304
	end -- 4304
	if not calmUsed and not calming then -- 4304
		self:stepCart(dt, input) -- 4308
	end -- 4308
	if calmUsed then -- 4308
		self:flashSet("安抚 · 敲两下", 0.8) -- 4313
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4313
		if self.knockT > 0 then -- 4313
			self.knocks = self.knocks + 1 -- 4317
		else -- 4317
			self.knocks = 1 -- 4319
		end -- 4319
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4321
		self.knockT = 1.2 -- 4322
		if self.knocks >= 2 then -- 4322
			self:flashSet("敲两下", 0.8) -- 4324
			self.knocks = 0 -- 4325
		else -- 4325
			self:flashSet("敲一下", 0.5) -- 4327
		end -- 4327
	elseif self.knockT > 0 then -- 4327
		self.knockT = self.knockT - dt -- 4330
		if self.knockT <= 0 then -- 4330
			self.knocks = 0 -- 4332
		end -- 4332
	end -- 4332
	local i = 0 -- 4337
	do -- 4337
		i = 0 -- 4338
		while i < #self.room.marks do -- 4338
			do -- 4338
				local m = self.room.marks[i + 1] -- 4339
				if m.kind ~= 0 then -- 4339
					goto __continue713 -- 4341
				end -- 4341
				local subjects = {self.partner, self.player} -- 4343
				local k = 0 -- 4344
				do -- 4344
					k = 0 -- 4345
					while k < #subjects do -- 4345
						do -- 4345
							local s = subjects[k + 1] -- 4346
							if not s.alive then -- 4346
								goto __continue716 -- 4348
							end -- 4348
							local dx = s.x - m.x -- 4350
							local dy = s.y - m.y -- 4351
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4351
								self.checkpoint = m.x -- 4353
								self.checkpointCartAxle = self.cartAxle -- 4354
								if self.isCampaign then -- 4354
									self:captureCheckpoint(m.x) -- 4357
								end -- 4357
								if self.cartDocked then -- 4357
									self:flashSet("检查点 · 车已落窝", 1) -- 4360
								else -- 4360
									self:flashSet("检查点 · 车还没到位", 1) -- 4362
								end -- 4362
							end -- 4362
						end -- 4362
						::__continue716:: -- 4362
						k = k + 1 -- 4345
					end -- 4345
				end -- 4345
			end -- 4345
			::__continue713:: -- 4345
			i = i + 1 -- 4338
		end -- 4338
	end -- 4338
	self:checkCarryGate() -- 4368
end -- 4292
function Play.prototype.stepVillage(self, dt, input) -- 4372
	if self.room.key ~= "village" then -- 4372
		return -- 4374
	end -- 4374
	local p = self.player -- 4376
	local bottle = self.room.bottle -- 4377
	local scav = self.room.scavenger -- 4378
	if not self.hasBottle and bottle ~= nil then -- 4378
		local dx = p.x - bottle.x -- 4382
		local dy = p.y + p.h * 0.5 - bottle.y -- 4383
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4383
			self.hasBottle = true -- 4385
			self:flashSet("拾起瓶子", 0.8) -- 4386
		end -- 4386
	end -- 4386
	if self.hasBottle then -- 4386
		if input.aim.held then -- 4386
			self.aimHold = self.aimHold + dt -- 4393
			if self.aimHold > 1.2 then -- 4393
				self.aimHold = 1.2 -- 4395
			end -- 4395
			local cached = self:bottleEnd() -- 4398
			self.bottleAimX = cached.x -- 4399
			self.bottleAimY = cached.y -- 4400
		elseif input.aim.released then -- 4400
			if self.aimHold < 0.12 then -- 4400
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 4404
				self.aimHold = 0 -- 4405
			else -- 4405
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4407
				self:throwBottle(____end.x, ____end.y) -- 4408
				self.aimHold = 0 -- 4409
			end -- 4409
		end -- 4409
	else -- 4409
		self.aimHold = 0 -- 4413
		self.bottleAimX = -1 -- 4414
	end -- 4414
	local fly = self.bottleFly -- 4419
	if fly ~= nil then -- 4419
		fly.t = fly.t + dt -- 4421
		fly.x = fly.x0 + fly.vx * fly.t -- 4422
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4423
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4424
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4424
			self:landBottle(fly) -- 4426
		end -- 4426
	end -- 4426
	if self.bottleLandT > 0 then -- 4426
		self.bottleLandT = self.bottleLandT - dt -- 4430
	end -- 4430
	if scav ~= nil then -- 4430
		self:stepScav(dt, scav) -- 4434
	end -- 4434
	local line = self.room.passLine -- 4437
	if line ~= nil and not self.passed and p.x >= line then -- 4437
		self.passed = true -- 4439
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4440
	end -- 4440
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4443
	if underTable then -- 4443
		self.footHintT = self.footHintT - 1 -- 4445
		if self.footHintT <= 0 then -- 4445
			self.footHintT = 90 -- 4447
			local scavX = self.scavX -- 4448
			local near = math.abs(scavX - p.x) < 120 -- 4449
			local heard = near or self.scavState == "walk" or self.scavState == "chase" -- 4450
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4451
			self:emit("storyBeat", {beat = near and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4452
		end -- 4452
	else -- 4452
		self.footHintT = 0 -- 4455
	end -- 4455
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4455
		self.ditchHinted = true -- 4459
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4460
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4461
	end -- 4461
	if self.passed and p.x >= self.ox + 640 then -- 4461
		self:requestRoom("forest", "过第一院出院") -- 4465
		self:flashSet("钻出暗渠 · 北塔森林", 1.4) -- 4466
	end -- 4466
end -- 4372
function Play.prototype.bottleEnd(self) -- 4471
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4472
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 4475
	return {x = aim.x, y = g} -- 4476
end -- 4471
function Play.prototype.throwBottle(self, tx, ty) -- 4480
	local p = self.player -- 4481
	local dir = tx >= p.x and 1 or -1 -- 4483
	p.facing = dir -- 4484
	local x0 = p.x + dir * 10 -- 4485
	local y0 = p.y + p.h * 0.7 -- 4486
	self.bottleTargetX = tx -- 4487
	self.bottleTargetY = ty -- 4488
	self.bottleSurfaceY = ty -- 4489
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4490
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4491
	self.bottleFly = { -- 4492
		x = x0, -- 4492
		y = y0, -- 4492
		x0 = x0, -- 4492
		y0 = y0, -- 4492
		vx = vx, -- 4492
		vy = vy, -- 4492
		t = 0 -- 4492
	} -- 4492
	self.hasBottle = false -- 4493
	self:flashSet("投出", 0.4) -- 4494
	self:emit( -- 4495
		"bottleThrown", -- 4495
		{ -- 4495
			fromX = x0, -- 4496
			fromY = y0, -- 4497
			targetX = tx, -- 4498
			targetY = ty, -- 4499
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4500
		} -- 4500
	) -- 4500
end -- 4480
function Play.prototype.bottleSurfaceAt(self, x) -- 4505
	if self.room.softX ~= nil and math.abs(x - self.room.softX) <= 34 then -- 4505
		return "soft" -- 4507
	end -- 4507
	if self.room.basinX ~= nil and math.abs(x - self.room.basinX) <= 24 then -- 4507
		return "iron" -- 4510
	end -- 4510
	return "brick" -- 4512
end -- 4505
function Play.prototype.landBottle(self, fly) -- 4516
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4517
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4518
	local s = self.room.scavenger -- 4519
	local surface = self:bottleSurfaceAt(x) -- 4520
	local effRange = s == nil and 0 or (surface == "iron" and s.range * 1.25 or s.range) -- 4521
	local heard = surface ~= "soft" and s ~= nil and math.abs(x - self.scavX) <= effRange -- 4522
	local stallTicks = s == nil and 0 or (surface == "iron" and s.stallTicks + 90 or s.stallTicks) -- 4523
	self.bottleFly = nil -- 4524
	self.bottleTargetX = -1 -- 4525
	self.bottleTargetY = 0 -- 4526
	self.bottleSurfaceY = -1 -- 4527
	self.bottleLandX = x -- 4528
	self.bottleLandY = y -- 4529
	self.bottleLandT = 0.9 -- 4530
	self:emit("bottleLanded", { -- 4531
		x = x, -- 4532
		y = y, -- 4533
		surface = surface, -- 4534
		heard = heard, -- 4535
		resonance = surface == "iron", -- 4536
		stallTicks = heard and stallTicks or 0, -- 4537
		scavState = self.scavState -- 4538
	}) -- 4538
	self:hearBottle(x, surface) -- 4540
end -- 4516
function Play.prototype.hearBottle(self, x, surface) -- 4544
	if surface == nil then -- 4544
		surface = "brick" -- 4544
	end -- 4544
	local s = self.room.scavenger -- 4545
	if s == nil then -- 4545
		return -- 4547
	end -- 4547
	if surface == "soft" then -- 4547
		self:flashSet("落在软土 · 没出声", 0.8) -- 4550
		return -- 4551
	end -- 4551
	local effRange = surface == "iron" and s.range * 1.25 or s.range -- 4553
	if math.abs(x - self.scavX) > effRange then -- 4553
		self:flashSet("落地 · 他没听见", 0.6) -- 4555
		return -- 4556
	end -- 4556
	self.scavState = "turn" -- 4558
	self.scavT = s.hearTicks -- 4559
	self.scavTargetX = surface == "iron" and self.room.basinX ~= nil and self.room.basinX or x -- 4560
	self.scavStallBonus = surface == "iron" and 90 or 0 -- 4561
	self:flashSet(surface == "iron" and "铁盆余振两响 · 他停下来细听" or "砖地一响 · 他转头", 1.1) -- 4562
end -- 4544
function Play.prototype.stepScav(self, dt, s) -- 4566
	if self.scavState == "chase" then -- 4566
		return -- 4569
	end -- 4569
	if self.scavState == "turn" then -- 4569
		self.scavT = self.scavT - 1 -- 4572
		if self.scavT <= 0 then -- 4572
			self.scavState = "walk" -- 4574
		end -- 4574
		return -- 4576
	end -- 4576
	if self.scavState == "walk" then -- 4576
		local d = self.scavTargetX - self.scavX -- 4579
		if math.abs(d) < 4 then -- 4579
			self.scavState = "stall" -- 4581
			self.scavT = s.stallTicks + self.scavStallBonus -- 4582
			self.scavStallBonus = 0 -- 4583
			return -- 4584
		end -- 4584
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4586
		return -- 4587
	end -- 4587
	if self.scavState == "stall" then -- 4587
		self.scavT = self.scavT - 1 -- 4590
		if self.scavT <= 0 then -- 4590
			self.scavState = "back" -- 4592
		end -- 4592
		return -- 4594
	end -- 4594
	if self.scavState == "back" then -- 4594
		local home = math.max( -- 4597
			s.x0, -- 4597
			math.min(s.x1, self.scavX) -- 4597
		) -- 4597
		if math.abs(home - self.scavX) < 2 then -- 4597
			self.scavState = "patrol" -- 4599
			return -- 4600
		end -- 4600
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4602
		return -- 4603
	end -- 4603
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4605
	if self.scavX >= s.x1 then -- 4605
		self.scavX = s.x1 -- 4607
		self.scavDir = -1 -- 4608
	elseif self.scavX <= s.x0 then -- 4608
		self.scavX = s.x0 -- 4610
		self.scavDir = 1 -- 4611
	end -- 4611
end -- 4566
function Play.prototype.stepCart(self, dt, input) -- 4619
	local p = self.player -- 4620
	local c = self.room.cart -- 4621
	if self.gripping then -- 4621
		if not input.interact.held then -- 4621
			self.gripping = false -- 4625
			self:flashSet("松开车把", 0.4) -- 4626
			return -- 4627
		end -- 4627
	else -- 4627
		if not input.interact.pressed then -- 4627
			return -- 4631
		end -- 4631
		if not self:cartHandleInReach(p) then -- 4631
			return -- 4634
		end -- 4634
		local track = c.depth or 0 -- 4636
		if self:limitDepth(p, track) ~= track then -- 4636
			return -- 4638
		end -- 4638
		p.depth = track -- 4640
		p.depthSpeed = 0 -- 4641
		self.gripping = true -- 4642
		self:flashSet("握住车把", 0.4) -- 4643
		return -- 4644
	end -- 4644
	if self.cartDocked then -- 4644
		return -- 4648
	end -- 4648
	local dir = input.moveX -- 4650
	if dir == 0 then -- 4650
		return -- 4652
	end -- 4652
	local lo = math.min(c.startX, c.endX) -- 4654
	local hi = math.max(c.startX, c.endX) -- 4655
	local next = self.cartAxle + dir * CART_SPEED * dt -- 4656
	if next < lo then -- 4656
		next = lo -- 4658
	end -- 4658
	if next > hi then -- 4658
		next = hi -- 4661
	end -- 4661
	local delta = next - self.cartAxle -- 4663
	if delta == 0 then -- 4663
		return -- 4665
	end -- 4665
	self.cartAxle = next -- 4667
	p.x = p.x + delta -- 4668
	p.facing = dir > 0 and 1 or -1 -- 4669
	self:slideX(p, 0) -- 4670
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 4670
		self.gripping = false -- 4672
		self:flashSet("跟不上了，脱手", 0.6) -- 4673
		return -- 4674
	end -- 4674
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 4674
		self.cartDocked = true -- 4677
		self.gripping = false -- 4678
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 4679
		self:flashSet("车轮落窝", 1.2) -- 4680
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 4680
		self:flashSet("车轮回到起点", 0.5) -- 4682
	end -- 4682
end -- 4619
function Play.prototype.requestRoom(self, key, reason) -- 4690
	if self.wantRoom ~= "" then -- 4690
		return -- 4694
	end -- 4694
	self.wantRoom = key -- 4696
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 4697
end -- 4690
function Play.prototype.checkCarryGate(self) -- 4704
	if self.room.key == "checkpoint" then -- 4704
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 4704
			self.carryCartAxle = self.cartAxle -- 4707
			self.carryCartDocked = self.cartDocked -- 4708
			self:requestRoom("gate", "检查站出口") -- 4709
			self:flashSet("出检查站 · 城门", 1.2) -- 4710
		end -- 4710
		return -- 4712
	end -- 4712
	if self.room.key == "outside" then -- 4712
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 4712
			self.carryCartAxle = self.cartAxle -- 4718
			self.carryCartDocked = self.cartDocked -- 4719
			self:requestRoom("village", "墙根走完") -- 4720
			self:flashSet("墙根走完 · 进村口", 1.2) -- 4721
		end -- 4721
	end -- 4721
end -- 4704
function Play.prototype.aimAt(self, wx, wy) -- 4728
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 4729
	self.aimX = s.x -- 4730
	self.aimY = s.y -- 4731
end -- 4728
function Play.prototype.shoot(self, a) -- 4734
	if self.isCampaign and self.reloadT > 0 then -- 4734
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 4736
		return -- 4737
	end -- 4737
	local ox = a.x + a.facing * 8 -- 4739
	local muzzleY = a.y + a.h * 0.72 -- 4740
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 4741
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4743
	local dx = aim.x - ox -- 4746
	local dy = aim.y - oy -- 4747
	local len = math.sqrt(dx * dx + dy * dy) -- 4748
	if len < 0.001 then -- 4748
		dx = a.facing -- 4750
		dy = 0 -- 4751
	else -- 4751
		dx = dx / len -- 4753
		dy = dy / len -- 4754
	end -- 4754
	if dx ~= 0 then -- 4754
		a.facing = dx > 0 and 1 or -1 -- 4757
	end -- 4757
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 4760
	local hitEnemy = self:raycastEnemies(ray) -- 4761
	local tEnemy = hitEnemy.t -- 4762
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 4763
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 4764
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 4765
	local tWall = solid.t -- 4766
	local rawEffect = self:consumeReloadEffect() -- 4768
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 4769
	local reloadEffect = rawEffect -- 4770
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 4772
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 4773
	self.trace = { -- 4775
		x0 = ox, -- 4775
		y0 = oy, -- 4775
		x1 = ox + dx * t, -- 4775
		y1 = oy + dy * t, -- 4775
		hit = hit -- 4775
	} -- 4775
	self.traceT = 0.12 -- 4776
	self:applyFireDanger(ox) -- 4777
	local killed = false -- 4778
	if hit then -- 4778
		local i = hitEnemy.index -- 4780
		local e = self.enemies[i + 1] -- 4781
		local impactY = oy + dy * tEnemy -- 4782
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 4783
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 4784
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 4784
			e.shieldHp = (e.shieldHp or 0) - 1 -- 4786
			e.hitT = 0.3 -- 4787
			self:flashSet( -- 4788
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 4788
				0.8 -- 4788
			) -- 4788
			self:emit("shotResolved", { -- 4789
				hit = true, -- 4790
				enemyIndex = i, -- 4790
				enemyX = e.x, -- 4790
				aimX = aim.x, -- 4790
				aimY = aim.y, -- 4790
				impactX = ox + dx * t, -- 4791
				impactY = oy + dy * t, -- 4791
				shield = true -- 4791
			}) -- 4791
			self:beginReload() -- 4793
			return -- 4794
		end -- 4794
		e.alive = false -- 4796
		e.hitT = 0.4 -- 4797
		killed = true -- 4798
		self:flashSet("命中", 0.6) -- 4799
		self:dropFor(e) -- 4800
		if reloadEffect == "light" and weaponFx == "light" then -- 4800
			self:blindNearby(e, 160, i) -- 4802
		end -- 4802
		if reloadEffect == "push" then -- 4802
			e.x = e.x + a.facing * 46 -- 4805
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4806
		elseif reloadEffect == "echo" then -- 4806
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 4808
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 4809
		elseif reloadEffect == "light" then -- 4809
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 4811
		end -- 4811
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 4811
		self:damageProp(solid.box, 1) -- 4814
	else -- 4814
		self:flashSet("打空", 0.35) -- 4816
	end -- 4816
	if self.isCampaign then -- 4816
		self:beginReload() -- 4819
	end -- 4819
	self:emit("shotResolved", { -- 4821
		hit = hit, -- 4822
		enemyIndex = hit and hitEnemy.index or -1, -- 4823
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 4824
		aimX = aim.x, -- 4825
		aimY = aim.y, -- 4826
		impactX = ox + dx * t, -- 4827
		impactY = oy + dy * t -- 4828
	}) -- 4828
end -- 4734
function Play.prototype.applyFireDanger(self, shotX) -- 4833
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 4833
		return -- 4835
	end -- 4835
	local dangerX = shotX -- 4837
	local best = -1 -- 4838
	local bestD = 1000000000 -- 4839
	local i = 0 -- 4840
	do -- 4840
		i = 0 -- 4841
		while i < #self.enemies do -- 4841
			do -- 4841
				local e = self.enemies[i + 1] -- 4842
				if not e.alive then -- 4842
					goto __continue805 -- 4844
				end -- 4844
				local d = math.abs(e.x - self.partner.x) -- 4846
				if d < bestD then -- 4846
					bestD = d -- 4848
					best = i -- 4849
				end -- 4849
			end -- 4849
			::__continue805:: -- 4849
			i = i + 1 -- 4841
		end -- 4841
	end -- 4841
	if best >= 0 then -- 4841
		dangerX = self.enemies[best + 1].x -- 4853
	end -- 4853
	local exposed = self:childExposed(dangerX) -- 4855
	local before = self.escort.fear -- 4856
	local dangerId = self.nextDangerId -- 4857
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 4858
	self.nextDangerId = self.nextDangerId + 1 -- 4859
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 4860
	if after > before then -- 4860
		self:flashSet( -- 4862
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 4862
			1 -- 4862
		) -- 4862
	elseif not exposed then -- 4862
		self:flashSet("枪声没够到她", 0.5) -- 4864
	end -- 4864
end -- 4833
function Play.prototype.childExposed(self, dangerX) -- 4869
	local c = self.partner -- 4870
	if not c.alive then -- 4870
		return false -- 4872
	end -- 4872
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 4872
		self.boxes, -- 4875
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 4875
	) then -- 4875
		return false -- 4876
	end -- 4876
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 4876
		return false -- 4879
	end -- 4879
	local toDanger = dangerX - c.x -- 4881
	local toPlayer = self.player.x - c.x -- 4882
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 4882
		return false -- 4885
	end -- 4885
	return true -- 4887
end -- 4869
function Play.prototype.raycastEnemies(self, ray) -- 4891
	local best = -1 -- 4892
	local bestI = -1 -- 4893
	do -- 4893
		local i = 0 -- 4894
		while i < #self.enemies do -- 4894
			do -- 4894
				local e = self.enemies[i + 1] -- 4895
				if not e.alive then -- 4895
					goto __continue819 -- 4897
				end -- 4897
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 4899
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 4900
				if t >= 0 and (best < 0 or t < best) then -- 4900
					best = t -- 4902
					bestI = i -- 4903
				end -- 4903
			end -- 4903
			::__continue819:: -- 4903
			i = i + 1 -- 4894
		end -- 4894
	end -- 4894
	return {t = best, index = bestI} -- 4906
end -- 4891
function Play.prototype.raycastWorld(self, ray) -- 4909
	return self:raycastSolid(ray).t -- 4910
end -- 4909
function Play.prototype.raycastSolid(self, ray) -- 4914
	local best = -1 -- 4915
	local bestBox = nil -- 4916
	for ____, box in ipairs(self.boxes) do -- 4917
		do -- 4917
			if box.broken == true or box.hidden == true then -- 4917
				goto __continue824 -- 4919
			end -- 4919
			local t = hitBox(ray, box) -- 4924
			if t > 2 and (best < 0 or t < best) then -- 4924
				best = t -- 4927
				bestBox = box -- 4928
			end -- 4928
		end -- 4928
		::__continue824:: -- 4928
	end -- 4928
	if ray.dy < 0 then -- 4928
		local t = -ray.y / ray.dy -- 4932
		if t >= 0 and (best < 0 or t < best) then -- 4932
			best = t -- 4934
			bestBox = nil -- 4935
		end -- 4935
	end -- 4935
	return {t = best, box = bestBox} -- 4938
end -- 4914
function Play.prototype.dropFor(self, e) -- 4942
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 4942
		return -- 4944
	end -- 4944
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 4944
		return -- 4947
	end -- 4947
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 4949
	local ____self_pickups_54 = self.pickups -- 4949
	____self_pickups_54[#____self_pickups_54 + 1] = { -- 4950
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 4951
		kind = e.drop, -- 4951
		x = e.x, -- 4951
		y = e.y, -- 4951
		depth = e.depth, -- 4952
		label = label .. " ×1" -- 4952
	} -- 4952
	self:log("掉落 " .. label) -- 4954
end -- 4942
function Play.prototype.damageProp(self, b, amount) -- 4958
	if b.breakable == nil or b.broken == true then -- 4958
		return -- 4960
	end -- 4960
	local ____b_breakable_55, ____hp_56 = b.breakable, "hp" -- 4960
	____b_breakable_55[____hp_56] = ____b_breakable_55[____hp_56] - amount -- 4962
	if b.breakable.hp > 0 then -- 4962
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 4964
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 4965
		return -- 4966
	end -- 4966
	b.broken = true -- 4968
	for ____, other in ipairs(self.boxes) do -- 4969
		if other.id ~= nil and other.id == b.id then -- 4969
			other.broken = true -- 4971
		end -- 4971
	end -- 4971
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 4974
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 4975
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 4976
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 4977
end -- 4958
function Play.prototype.slideDepth(self, a, distance) -- 4981
	a.depth = self:limitDepth(a, a.depth + distance) -- 4982
end -- 4981
function Play.prototype.limitDepth(self, a, target) -- 4985
	local road = self.room.depth -- 4986
	if road == nil or target == a.depth then -- 4986
		return a.depth -- 4988
	end -- 4988
	local next = math.max( -- 4990
		road.min, -- 4990
		math.min(road.max, target) -- 4990
	) -- 4990
	local half = a.w / 2 -- 4991
	for ____, b in ipairs(self.boxes) do -- 4992
		do -- 4992
			local footprint = b.depth -- 4993
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4993
				goto __continue842 -- 4998
			end -- 4998
			local front = footprint.min - ACTOR_DEPTH_HALF -- 5000
			local back = footprint.max + ACTOR_DEPTH_HALF -- 5001
			if a.depth <= front and next > front then -- 5001
				next = front -- 5003
			elseif a.depth >= back and next < back then -- 5003
				next = back -- 5005
			end -- 5005
		end -- 5005
		::__continue842:: -- 5005
	end -- 5005
	return next -- 5008
end -- 4985
function Play.prototype.slideX(self, a, dx) -- 5012
	local nx = a.x + dx -- 5013
	local half = a.w / 2 -- 5014
	local room = self.room -- 5015
	nx = math.max( -- 5016
		room.minX + half, -- 5016
		math.min(room.maxX - half, nx) -- 5016
	) -- 5016
	local i = 0 -- 5017
	do -- 5017
		i = 0 -- 5018
		while i < #self.boxes do -- 5018
			do -- 5018
				local b = self.boxes[i + 1] -- 5019
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5019
					goto __continue849 -- 5021
				end -- 5021
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5021
					goto __continue849 -- 5024
				end -- 5024
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5024
					goto __continue849 -- 5027
				end -- 5027
				if nx + half > b.x0 and nx - half < b.x1 then -- 5027
					if a.x <= b.x0 then -- 5027
						nx = b.x0 - half -- 5031
					elseif a.x >= b.x1 then -- 5031
						nx = b.x1 + half -- 5033
					else -- 5033
						nx = a.x -- 5035
					end -- 5035
				end -- 5035
			end -- 5035
			::__continue849:: -- 5035
			i = i + 1 -- 5018
		end -- 5018
	end -- 5018
	if self.room.key == "outside" and not self.cartDocked and a.y < CART_CLEAR - 0.001 then -- 5018
		local bx0 = math.max(room.arch.x0, self.cartAxle - CART_HALF) -- 5042
		local bx1 = math.min(room.arch.x1, self.cartAxle + CART_HALF) -- 5043
		if bx1 > bx0 and nx + half > bx0 and nx - half < bx1 then -- 5043
			if a.x <= bx0 then -- 5043
				nx = bx0 - half -- 5046
			elseif a.x >= bx1 then -- 5046
				nx = bx1 + half -- 5048
			else -- 5048
				nx = a.x -- 5050
			end -- 5050
		end -- 5050
	end -- 5050
	local arch = room.arch -- 5058
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 5058
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 5060
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 5060
			if a.x <= arch.x0 then -- 5060
				nx = arch.x0 - half -- 5063
			elseif a.x >= arch.x1 then -- 5063
				nx = arch.x1 + half -- 5065
			end -- 5065
		end -- 5065
	end -- 5065
	a.x = nx -- 5069
end -- 5012
function Play.prototype.fallY(self, a, dt) -- 5073
	a.vy = a.vy - ____exports.GRAVITY * dt -- 5074
	if a.vy < -900 then -- 5074
		a.vy = -900 -- 5076
	end -- 5076
	local ny = a.y + a.vy * dt -- 5078
	local half = a.w / 2 -- 5079
	if a.vy <= 0 then -- 5079
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 5082
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 5083
		if ny <= ground then -- 5083
			ny = ground -- 5085
			a.vy = 0 -- 5086
			a.onGround = true -- 5087
		else -- 5087
			a.onGround = false -- 5089
		end -- 5089
	else -- 5089
		a.onGround = false -- 5092
		local i = 0 -- 5093
		do -- 5093
			i = 0 -- 5094
			while i < #self.boxes do -- 5094
				do -- 5094
					local b = self.boxes[i + 1] -- 5095
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5095
						goto __continue873 -- 5097
					end -- 5097
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5097
						goto __continue873 -- 5100
					end -- 5100
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 5100
						goto __continue873 -- 5103
					end -- 5103
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 5103
						ny = b.y0 - a.h -- 5106
						a.vy = 0 -- 5107
					end -- 5107
				end -- 5107
				::__continue873:: -- 5107
				i = i + 1 -- 5094
			end -- 5094
		end -- 5094
	end -- 5094
	a.y = ny -- 5111
end -- 5073
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 5115
	if depth == nil then -- 5115
		depth = 0 -- 5115
	end -- 5115
	local g = -9999 -- 5116
	local i = 0 -- 5117
	do -- 5117
		i = 0 -- 5118
		while i < #self.floors do -- 5118
			local f = self.floors[i + 1] -- 5119
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 5119
				g = f.y1 -- 5121
			end -- 5121
			i = i + 1 -- 5118
		end -- 5118
	end -- 5118
	do -- 5118
		i = 0 -- 5124
		while i < #self.boxes do -- 5124
			do -- 5124
				local b = self.boxes[i + 1] -- 5125
				if b.broken == true or b.hidden == true or b.soft == true then -- 5125
					goto __continue883 -- 5127
				end -- 5127
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 5127
					g = b.y1 -- 5131
				end -- 5131
			end -- 5131
			::__continue883:: -- 5131
			i = i + 1 -- 5124
		end -- 5124
	end -- 5124
	return g -- 5134
end -- 5115
function Play.prototype.updateCamera(self, dt) -- 5137
	local p = self.player -- 5138
	local tx = p.x + p.facing * 30 -- 5139
	local ty = p.y + CAM_LOOK_UP -- 5140
	local k = math.min(1, CAM_FOLLOW * dt) -- 5141
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 5142
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 5143
end -- 5137
function Play.prototype.clampCamera(self, w, h) -- 5147
	local room = self.room -- 5148
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 5149
	local spanX = room.maxX - room.minX -- 5150
	if spanX <= halfW * 2 then -- 5150
		self.cam.x = (room.minX + room.maxX) / 2 -- 5152
	else -- 5152
		self.cam.x = math.max( -- 5154
			room.minX + halfW, -- 5154
			math.min(room.maxX - halfW, self.cam.x) -- 5154
		) -- 5154
	end -- 5154
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 5157
	local spanY = room.height -- 5158
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 5159
	if spanY <= halfH * 2 then -- 5159
		self.cam.y = camY -- 5161
	else -- 5161
		self.cam.y = math.max( -- 5163
			camY, -- 5163
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 5163
		) -- 5163
	end -- 5163
end -- 5147
function Play.prototype.flashSet(self, text, t) -- 5167
	self.flash = text -- 5168
	self.flashT = t -- 5169
end -- 5167
function Play.prototype.statusText(self) -- 5173
	local p = self.player -- 5174
	local parts = {} -- 5175
	local who = self.childMode and "小满" or "周戍" -- 5176
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 5177
	if self.room.key == "prologue" then -- 5177
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5180
		if self.phase == "prologue-wake" then -- 5180
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 5182
		elseif self.phase == "prologue-shadow" then -- 5182
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 5184
		elseif self.phase == "prologue-escape" then -- 5184
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 5186
		elseif self.phase == "prologue-hide" then -- 5186
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 5188
		elseif self.phase == "prologue-wait" then -- 5188
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 5190
		elseif self.phase == "prologue-give" then -- 5190
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 5192
		else -- 5192
			parts[#parts + 1] = "跟随" -- 5194
		end -- 5194
		if self.paused then -- 5194
			parts[#parts + 1] = "已暂停" -- 5197
		end -- 5197
		return table.concat(parts, " · ") -- 5199
	end -- 5199
	if self.room.key == "street" then -- 5199
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5202
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5203
		if self.paused then -- 5203
			parts[#parts + 1] = "已暂停" -- 5205
		end -- 5205
		return table.concat(parts, " · ") -- 5207
	end -- 5207
	if self.room.key == "gate" then -- 5207
		local ____temp_57 -- 5210
		if self.room.story == nil then -- 5210
			____temp_57 = nil -- 5210
		else -- 5210
			____temp_57 = self.room.story.gate -- 5210
		end -- 5210
		local g = ____temp_57 -- 5210
		if g ~= nil then -- 5210
			parts[#parts + 1] = self:gateLabel() -- 5212
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 5213
				0, -- 5214
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 5214
			))) .. " 秒" -- 5214
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5215
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5216
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 5217
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 5218
			if self.gateFailCount > 0 then -- 5218
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 5220
			end -- 5220
			if self.flash ~= "" then -- 5220
				parts[#parts + 1] = self.flash -- 5223
			end -- 5223
		end -- 5223
		if self.paused then -- 5223
			parts[#parts + 1] = "已暂停" -- 5227
		end -- 5227
		return table.concat(parts, " · ") -- 5229
	end -- 5229
	if self.room.key == "forest" then -- 5229
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5232
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5233
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5234
		if self.caughtT > 0 then -- 5234
			parts[#parts + 1] = "复位中" -- 5236
		end -- 5236
		if self.paused then -- 5236
			parts[#parts + 1] = "已暂停" -- 5239
		end -- 5239
		return table.concat(parts, " · ") -- 5241
	end -- 5241
	if self.room.key == "tower" then -- 5241
		if self.phase == "tower-wait" then -- 5241
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5245
		elseif self.phase == "tower-knock" then -- 5245
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5247
		elseif self.phase == "tower-enter" then -- 5247
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5249
		elseif self.phase == "tower-desk" then -- 5249
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5251
		elseif self.phase == "tower-given" then -- 5251
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5253
		else -- 5253
			parts[#parts + 1] = "片尾" -- 5255
		end -- 5255
		if self.paused then -- 5255
			parts[#parts + 1] = "已暂停" -- 5258
		end -- 5258
		return table.concat(parts, " · ") -- 5260
	end -- 5260
	if self.room.key == "village" then -- 5260
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5263
		if self.hasBottle then -- 5263
			parts[#parts + 1] = "有瓶" -- 5265
		elseif self.bottleFly ~= nil then -- 5265
			parts[#parts + 1] = "瓶在飞" -- 5267
		else -- 5267
			parts[#parts + 1] = "空手" -- 5269
		end -- 5269
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5271
		if self.scavChase then -- 5271
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5273
		end -- 5273
		if self.passed then -- 5273
			parts[#parts + 1] = "已过通行线" -- 5276
		end -- 5276
		if self.paused then -- 5276
			parts[#parts + 1] = "已暂停" -- 5279
		end -- 5279
		return table.concat(parts, " · ") -- 5281
	end -- 5281
	local isChild = self.childMode -- 5284
	if isChild then -- 5284
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5286
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5287
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5288
	else -- 5288
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5290
		if p.rollT > 0 then -- 5290
			parts[#parts + 1] = "翻滚中" -- 5292
		end -- 5292
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5294
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5295
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5296
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5297
	end -- 5297
	if self.checkpoint >= 0 then -- 5297
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5300
	end -- 5300
	if self.paused then -- 5300
		parts[#parts + 1] = "已暂停" -- 5303
	end -- 5303
	return table.concat(parts, " · ") -- 5305
end -- 5173
function Play.prototype.aliveEnemies(self) -- 5309
	local n = 0 -- 5310
	local i = 0 -- 5311
	do -- 5311
		i = 0 -- 5312
		while i < #self.enemies do -- 5312
			if self.enemies[i + 1].alive then -- 5312
				n = n + 1 -- 5314
			end -- 5314
			i = i + 1 -- 5312
		end -- 5312
	end -- 5312
	return n -- 5317
end -- 5309
function Play.prototype.threatened(self) -- 5322
	do -- 5322
		local i = 0 -- 5323
		while i < #self.enemies do -- 5323
			local e = self.enemies[i + 1] -- 5324
			if e.alive and e.warnT > 0 then -- 5324
				return true -- 5326
			end -- 5326
			i = i + 1 -- 5323
		end -- 5323
	end -- 5323
	return false -- 5329
end -- 5322
function Play.prototype.gateSecondsLeft(self) -- 5332
	local ____temp_58 -- 5333
	if self.room.story == nil then -- 5333
		____temp_58 = nil -- 5333
	else -- 5333
		____temp_58 = self.room.story.gate -- 5333
	end -- 5333
	local g = ____temp_58 -- 5333
	if g == nil then -- 5333
		return 0 -- 5335
	end -- 5335
	return math.max( -- 5337
		0, -- 5337
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5337
	) -- 5337
end -- 5332
function Play.prototype.gateLabel(self) -- 5340
	if self.phase == "gate-idle" then -- 5340
		return "待就位" -- 5342
	end -- 5342
	if self.phase == "gate-hold" then -- 5342
		return "守点中" -- 5345
	end -- 5345
	if self.phase == "gate-send" then -- 5345
		return "送别" -- 5348
	end -- 5348
	if self.phase == "gate-count" then -- 5348
		return "数数 " .. tostring(self.countTick) -- 5351
	end -- 5351
	return "她走" -- 5353
end -- 5340
function Play.prototype.dogLabel(self) -- 5357
	if self.dogState == "ear" then -- 5357
		return "转耳" -- 5359
	end -- 5359
	if self.dogState == "chase" then -- 5359
		return "追" -- 5362
	end -- 5362
	if self.dogState == "sniff" then -- 5362
		return "停" -- 5365
	end -- 5365
	if self.dogState == "back" then -- 5365
		return "回线" -- 5368
	end -- 5368
	return "巡逻" -- 5370
end -- 5357
function Play.prototype.doorXOf(self) -- 5373
	local ____temp_59 -- 5374
	if self.room.story == nil then -- 5374
		____temp_59 = nil -- 5374
	else -- 5374
		____temp_59 = self.room.story.tower -- 5374
	end -- 5374
	local t = ____temp_59 -- 5374
	return t == nil and 0 or t.doorX -- 5375
end -- 5373
function Play.prototype.scavLabel(self) -- 5379
	if self.scavState == "chase" then -- 5379
		return "追" -- 5381
	end -- 5381
	if self.scavState == "turn" then -- 5381
		return "转头" -- 5384
	end -- 5384
	if self.scavState == "walk" then -- 5384
		return "赶来" -- 5387
	end -- 5387
	if self.scavState == "stall" then -- 5387
		return "停住" -- 5390
	end -- 5390
	if self.scavState == "back" then -- 5390
		return "回位" -- 5393
	end -- 5393
	return "巡逻" -- 5395
end -- 5379
function Play.prototype.hintText(self) -- 5399
	if self.paused then -- 5399
		return "Esc 继续 · R 重置" -- 5401
	end -- 5401
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5401
		if self:threatened() then -- 5401
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5407
		end -- 5407
		if self.coverHug then -- 5407
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5410
		end -- 5410
		if self.coverNear then -- 5410
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5413
		end -- 5413
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5415
	end -- 5415
	if self.flash ~= "" then -- 5415
		return self.flash -- 5418
	end -- 5418
	if self.room.key == "prologue" then -- 5418
		if self.phase == "prologue-wake" then -- 5418
			return "父亲在门外唤 · 小满睁眼" -- 5422
		end -- 5422
		if self.phase == "prologue-shadow" then -- 5422
			return "墙上两道人影 · 碗滚到脚边" -- 5425
		end -- 5425
		if self.phase == "prologue-escape" then -- 5425
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5428
		end -- 5428
		if self.phase == "prologue-hide" then -- 5428
			return "柜门合上 · 屏住呼吸" -- 5431
		end -- 5431
		if self.phase == "prologue-wait" then -- 5431
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5434
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5435
		end -- 5435
		if self.phase == "prologue-give" then -- 5435
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 5438
		end -- 5438
		return "她跟着你了 · 两人一起走到门口 680" -- 5440
	end -- 5440
	if self.room.key == "street" then -- 5440
		if self:aliveEnemies() > 0 then -- 5440
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5444
		end -- 5444
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5446
	end -- 5446
	if self.room.key == "gate" then -- 5446
		local ____temp_60 -- 5449
		if self.room.story == nil then -- 5449
			____temp_60 = nil -- 5449
		else -- 5449
			____temp_60 = self.room.story.gate -- 5449
		end -- 5449
		local g = ____temp_60 -- 5449
		if g ~= nil then -- 5449
			if self.phase == "gate-idle" then -- 5449
				if self.gateNeedConfirm then -- 5449
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5453
				end -- 5453
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5455
			end -- 5455
			if self.phase == "gate-hold" then -- 5455
				if self.coveredFlash > 0 then -- 5455
					return "掩体挡下了这一枪 · 别露头" -- 5459
				end -- 5459
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5461
			end -- 5461
			if self.phase == "gate-send" then -- 5461
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5464
			end -- 5464
			if self.phase == "gate-count" then -- 5464
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5464
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5468
				end -- 5468
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5470
			end -- 5470
			return "她自己走 · 跟着出城门 1120" -- 5472
		end -- 5472
	end -- 5472
	if self.room.key == "forest" then -- 5472
		if self.dogState == "chase" then -- 5472
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5477
		end -- 5477
		if self.dogState == "ear" then -- 5477
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5480
		end -- 5480
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5482
	end -- 5482
	if self.room.key == "tower" then -- 5482
		if self.phase == "tower-wait" then -- 5482
			return "走到门前 445 点一次 E 敲两下" -- 5486
		end -- 5486
		if self.phase == "tower-knock" then -- 5486
			return "敲两下 · 等门开" -- 5489
		end -- 5489
		if self.phase == "tower-given" then -- 5489
			return "递交针套和纸条 · 看登记簿最后一行" -- 5492
		end -- 5492
		return "片尾 · 点 E 再玩一次，回到序章" -- 5494
	end -- 5494
	if self.room.key == "village" then -- 5494
		if self.bottleFly ~= nil then -- 5494
			return "等瓶子落地 · 触地才发声" -- 5498
		end -- 5498
		if self.hasBottle then -- 5498
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5501
		end -- 5501
		if self.passed then -- 5501
			return "已过第一院 · R 重置可再来一遍" -- 5504
		end -- 5504
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5506
	end -- 5506
	if self.room.key == "outside" then -- 5506
		if self.focusCart then -- 5506
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5510
		end -- 5510
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5512
	end -- 5512
	if self.escort.state == "frozen" then -- 5512
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5512
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5516
		end -- 5516
		return "小满吓住了 · 走过去，靠近再点 E" -- 5518
	end -- 5518
	if self.escort.state == "calming" then -- 5518
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5521
	end -- 5521
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5523
end -- 5399
function Play.prototype.draw(self, draw, w, h) -- 5528
	self.viewW = w -- 5529
	self.viewH = h -- 5530
	self.view = ____exports.computeViewport(w, h) -- 5531
	self:clampCamera(w, h) -- 5532
	draw:clear() -- 5533
	draw:drawRect( -- 5535
		Rect(0, 0, w, h), -- 5535
		BG_VOID -- 5535
	) -- 5535
	local box = self:canvasRect(w, h) -- 5536
	draw:drawRect(box, BG_FAR) -- 5537
	draw:drawRect( -- 5538
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 5538
		BG_MID -- 5538
	) -- 5538
	self:drawFloors(draw, w, h) -- 5540
	self:drawSolids(draw, w, h) -- 5541
	self:drawZones(draw, w, h) -- 5542
	self:drawArch(draw, w, h) -- 5543
	self:drawCart(draw, w, h) -- 5544
	self:drawCampaignProps(draw, w, h) -- 5545
	self:drawActors(draw, w, h) -- 5546
	self:drawTrace(draw, w, h) -- 5547
	self:drawAim(draw, w, h) -- 5548
end -- 5528
function Play.prototype.canvasRect(self, w, h) -- 5552
	local v = self.view -- 5553
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 5554
end -- 5552
function Play.prototype.px(self, n) -- 5558
	return n * self.view.zoom -- 5559
end -- 5558
function Play.prototype.sx(self, wx, w) -- 5563
	local v = self.view -- 5564
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 5565
	return v.ox + lx * v.zoom -- 5566
end -- 5563
function Play.prototype.sy(self, wy, h) -- 5570
	local v = self.view -- 5571
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 5572
	return v.oy + ly * v.zoom -- 5573
end -- 5570
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 5576
	local px0 = self:sx(x0, w) -- 5577
	local px1 = self:sx(x1, w) -- 5578
	local py0 = self:sy(y0, h) -- 5579
	local py1 = self:sy(y1, h) -- 5580
	if px1 <= px0 or py1 <= py0 then -- 5580
		return -- 5582
	end -- 5582
	draw:drawRect( -- 5584
		Rect(px0, py0, px1 - px0, py1 - py0), -- 5584
		color -- 5584
	) -- 5584
end -- 5576
function Play.prototype.drawFloors(self, draw, w, h) -- 5587
	local i = 0 -- 5588
	do -- 5588
		i = 0 -- 5589
		while i < #self.room.floors do -- 5589
			local f = self.room.floors[i + 1] -- 5590
			local ____temp_61 -- 5591
			if f.y == 0 then -- 5591
				____temp_61 = self.room.depth -- 5591
			else -- 5591
				____temp_61 = nil -- 5591
			end -- 5591
			local road = ____temp_61 -- 5591
			local y = self:sy(f.y + (road and road.min or 0), h) -- 5592
			local x0 = self:sx(f.x0, w) -- 5593
			local x1 = self:sx(f.x1, w) -- 5594
			local deck = self:px(5) -- 5595
			if road ~= nil then -- 5595
				local back = self:sy(f.y + road.max, h) -- 5597
				draw:drawRect( -- 5598
					Rect(x0, y, x1 - x0, back - y), -- 5598
					FLOOR_DECK, -- 5598
					self:px(1), -- 5598
					SOLID_EDGE -- 5598
				) -- 5598
			end -- 5598
			draw:drawRect( -- 5600
				Rect(x0, y - deck, x1 - x0, deck), -- 5600
				FLOOR_DECK -- 5600
			) -- 5600
			draw:drawSegment( -- 5601
				Vec2(x0, y), -- 5601
				Vec2(x1, y), -- 5601
				self:px(1), -- 5601
				GROUND -- 5601
			) -- 5601
			i = i + 1 -- 5589
		end -- 5589
	end -- 5589
end -- 5587
function Play.prototype.drawSolids(self, draw, w, h) -- 5605
	local i = 0 -- 5606
	do -- 5606
		i = 0 -- 5607
		while i < #self.boxes do -- 5607
			do -- 5607
				local b = self.boxes[i + 1] -- 5608
				if b.id == "braced_shield" or b.hidden == true then -- 5608
					goto __continue1014 -- 5610
				end -- 5610
				if b.broken == true then -- 5610
					if b.breakable ~= nil then -- 5610
						local gy = self:sy(b.y0, h) -- 5615
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 5616
						local k = 0 -- 5617
						do -- 5617
							k = 0 -- 5618
							while k < 3 do -- 5618
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 5619
								draw:drawSegment( -- 5620
									Vec2( -- 5620
										gx - self:px(4), -- 5620
										gy + self:px(k % 2) -- 5620
									), -- 5620
									Vec2( -- 5620
										gx + self:px(5), -- 5620
										gy + self:px(k % 2) -- 5620
									), -- 5620
									self:px(1), -- 5620
									rgb -- 5620
								) -- 5620
								k = k + 1 -- 5618
							end -- 5618
						end -- 5618
					end -- 5618
					goto __continue1014 -- 5623
				end -- 5623
				local ____opt_64 = b.depth -- 5623
				local front = ____opt_64 and ____opt_64.min or 0 -- 5625
				local ____opt_66 = b.depth -- 5625
				local back = ____opt_66 and ____opt_66.max or 0 -- 5626
				local fill = SOLID_FILL -- 5627
				local line = SOLID_EDGE -- 5628
				if b.soft == true then -- 5628
					fill = SOFT -- 5630
					line = SOFT_LINE -- 5631
				elseif b.breakable ~= nil then -- 5631
					line = DANGER_LINE -- 5633
					fill = Color(0.3, 0.24, 0.16, 1) -- 5634
				elseif b.interact ~= nil then -- 5634
					line = PASS_LINE -- 5636
				end -- 5636
				self:drawBox( -- 5638
					draw, -- 5638
					w, -- 5638
					h, -- 5638
					b.x0, -- 5638
					b.x1, -- 5638
					b.y0 + front, -- 5638
					b.y1 + back, -- 5638
					fill -- 5638
				) -- 5638
				draw:drawSegment( -- 5639
					Vec2( -- 5639
						self:sx(b.x0, w), -- 5639
						self:sy(b.y1 + front, h) -- 5639
					), -- 5639
					Vec2( -- 5640
						self:sx(b.x1, w), -- 5640
						self:sy(b.y1 + front, h) -- 5640
					), -- 5640
					self:px(1), -- 5640
					line -- 5640
				) -- 5640
				if b.breakable ~= nil then -- 5640
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 5643
					local cyp = self:sy(b.y1 + front, h) -- 5644
					draw:drawSegment( -- 5645
						Vec2( -- 5645
							cxp - self:px(4), -- 5645
							cyp + self:px(1) -- 5645
						), -- 5645
						Vec2( -- 5645
							cxp + self:px(3), -- 5645
							cyp + self:px(5) -- 5645
						), -- 5645
						self:px(1), -- 5645
						line -- 5645
					) -- 5645
				end -- 5645
			end -- 5645
			::__continue1014:: -- 5645
			i = i + 1 -- 5607
		end -- 5607
	end -- 5607
end -- 5605
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 5651
	local i = 0 -- 5652
	do -- 5652
		i = 0 -- 5653
		while i < #self.pickups do -- 5653
			do -- 5653
				local pk = self.pickups[i + 1] -- 5654
				if self.run.taken[pk.id] == true then -- 5654
					goto __continue1026 -- 5656
				end -- 5656
				local gy = pk.y + (pk.depth or 0) -- 5658
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 5659
				draw:drawRect( -- 5660
					Rect( -- 5660
						self:sx(pk.x - 5, w), -- 5660
						self:sy(gy + 12 + bob, h), -- 5660
						self:px(10), -- 5660
						self:px(10) -- 5660
					), -- 5660
					Color(0.84, 0.7, 0.3, 1) -- 5661
				) -- 5661
				draw:drawSegment( -- 5662
					Vec2( -- 5662
						self:sx(pk.x - 5, w), -- 5662
						self:sy(gy + 12 + bob, h) -- 5662
					), -- 5662
					Vec2( -- 5663
						self:sx(pk.x + 5, w), -- 5663
						self:sy(gy + 12 + bob, h) -- 5663
					), -- 5663
					self:px(1), -- 5663
					Color(0.95, 0.86, 0.52, 1) -- 5663
				) -- 5663
			end -- 5663
			::__continue1026:: -- 5663
			i = i + 1 -- 5653
		end -- 5653
	end -- 5653
	if self.bracedShield ~= nil then -- 5653
		local sh = self.bracedShield -- 5666
		draw:drawRect( -- 5667
			Rect( -- 5667
				self:sx(sh.x - sh.w / 2, w), -- 5667
				self:sy(sh.y, h), -- 5667
				self:px(sh.w), -- 5667
				self:px(sh.h) -- 5667
			), -- 5667
			Color(0.42, 0.4, 0.34, 1) -- 5668
		) -- 5668
		draw:drawSegment( -- 5669
			Vec2( -- 5669
				self:sx(sh.x - sh.w / 2, w), -- 5669
				self:sy(sh.y + sh.h, h) -- 5669
			), -- 5669
			Vec2( -- 5670
				self:sx(sh.x + sh.w / 2, w), -- 5670
				self:sy(sh.y + sh.h, h) -- 5670
			), -- 5670
			self:px(1), -- 5670
			Color(0.74, 0.72, 0.62, 1) -- 5670
		) -- 5670
	end -- 5670
end -- 5651
function Play.prototype.drawZones(self, draw, w, h) -- 5674
	local i = 0 -- 5675
	do -- 5675
		i = 0 -- 5676
		while i < #self.room.zones do -- 5676
			local z = self.room.zones[i + 1] -- 5677
			local fill = DANGER -- 5678
			local line = DANGER_LINE -- 5679
			if z.tint == 2 then -- 5679
				fill = SOFT -- 5681
				line = SOFT_LINE -- 5682
			elseif z.tint == 3 then -- 5682
				fill = BRICK -- 5684
				line = BRICK_LINE -- 5685
			elseif z.tint == 4 then -- 5685
				fill = PASS -- 5687
				line = PASS_LINE -- 5688
			end -- 5688
			self:drawBox( -- 5690
				draw, -- 5690
				w, -- 5690
				h, -- 5690
				z.x0, -- 5690
				z.x1, -- 5690
				z.y, -- 5690
				z.y + z.h, -- 5690
				fill -- 5690
			) -- 5690
			draw:drawSegment( -- 5691
				Vec2( -- 5691
					self:sx(z.x0, w), -- 5691
					self:sy(z.y, h) -- 5691
				), -- 5691
				Vec2( -- 5691
					self:sx(z.x0, w), -- 5691
					self:sy(z.y + z.h, h) -- 5691
				), -- 5691
				self:px(1), -- 5691
				line -- 5691
			) -- 5691
			draw:drawSegment( -- 5692
				Vec2( -- 5692
					self:sx(z.x1, w), -- 5692
					self:sy(z.y, h) -- 5692
				), -- 5692
				Vec2( -- 5692
					self:sx(z.x1, w), -- 5692
					self:sy(z.y + z.h, h) -- 5692
				), -- 5692
				self:px(1), -- 5692
				line -- 5692
			) -- 5692
			i = i + 1 -- 5676
		end -- 5676
	end -- 5676
end -- 5674
function Play.prototype.drawArch(self, draw, w, h) -- 5696
	local a = self.room.arch -- 5697
	if a.h <= 0 then -- 5697
		return -- 5699
	end -- 5699
	self:drawBox( -- 5701
		draw, -- 5701
		w, -- 5701
		h, -- 5701
		a.x0, -- 5701
		a.x1, -- 5701
		a.y, -- 5701
		a.y + a.h, -- 5701
		HOLE_FILL -- 5701
	) -- 5701
	draw:drawSegment( -- 5702
		Vec2( -- 5702
			self:sx(a.x0, w), -- 5702
			self:sy(a.y + a.h, h) -- 5702
		), -- 5702
		Vec2( -- 5702
			self:sx(a.x1, w), -- 5702
			self:sy(a.y + a.h, h) -- 5702
		), -- 5702
		self:px(1), -- 5702
		SOLID_EDGE -- 5702
	) -- 5702
	draw:drawSegment( -- 5703
		Vec2( -- 5703
			self:sx(a.x0, w), -- 5703
			self:sy(a.y, h) -- 5703
		), -- 5703
		Vec2( -- 5703
			self:sx(a.x0, w), -- 5703
			self:sy(a.y + a.h, h) -- 5703
		), -- 5703
		self:px(1), -- 5703
		SOLID_EDGE -- 5703
	) -- 5703
	draw:drawSegment( -- 5704
		Vec2( -- 5704
			self:sx(a.x1, w), -- 5704
			self:sy(a.y, h) -- 5704
		), -- 5704
		Vec2( -- 5704
			self:sx(a.x1, w), -- 5704
			self:sy(a.y + a.h, h) -- 5704
		), -- 5704
		self:px(1), -- 5704
		SOLID_EDGE -- 5704
	) -- 5704
end -- 5696
function Play.prototype.drawCart(self, draw, w, h) -- 5707
	local c = self.room.cart -- 5708
	if c.bodyW <= 0 then -- 5708
		return -- 5710
	end -- 5710
	drawCartShape( -- 5712
		draw, -- 5712
		self, -- 5712
		w, -- 5712
		h, -- 5712
		c, -- 5712
		self.cartAxle -- 5712
	) -- 5712
	draw:drawRect( -- 5713
		Rect( -- 5713
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 5713
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 5713
			self:px(2), -- 5713
			self:px(40) -- 5713
		), -- 5713
		STAND -- 5713
	) -- 5713
end -- 5707
function Play.prototype.drawActors(self, draw, w, h) -- 5716
	local p = self.player -- 5717
	local isChild = self.childMode -- 5718
	local footY = p.y + p.depth -- 5719
	if p.covered then -- 5719
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 5722
		draw:drawSegment( -- 5723
			Vec2( -- 5723
				self:sx(edge, w), -- 5723
				self:sy(footY + 8, h) -- 5723
			), -- 5723
			Vec2( -- 5723
				self:sx(edge, w), -- 5723
				self:sy(footY + p.h * 0.62, h) -- 5723
			), -- 5723
			self:px(2), -- 5723
			STAND -- 5723
		) -- 5723
		draw:drawSegment( -- 5725
			Vec2( -- 5725
				self:sx(p.x - 8, w), -- 5725
				self:sy(footY + p.h + 3, h) -- 5725
			), -- 5725
			Vec2( -- 5725
				self:sx(p.x + 8, w), -- 5725
				self:sy(footY + p.h + 3, h) -- 5725
			), -- 5725
			self:px(2), -- 5725
			STAND -- 5725
		) -- 5725
	elseif self.coverNear and not isChild then -- 5725
		draw:drawRect( -- 5728
			Rect( -- 5728
				self:sx(p.x - 3, w), -- 5728
				self:sy(footY + 1, h), -- 5728
				self:px(3), -- 5728
				self:px(3) -- 5728
			), -- 5728
			STAND -- 5728
		) -- 5728
	end -- 5728
	drawFigure( -- 5730
		draw, -- 5730
		self, -- 5730
		w, -- 5730
		h, -- 5730
		p, -- 5730
		isChild and CHILD_BODY or SOLDIER_BODY, -- 5730
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 5730
	) -- 5730
	local q = self.partner -- 5731
	if q.alive then -- 5731
		local childPartner = q.w == CHILD_W -- 5733
		drawFigure( -- 5734
			draw, -- 5734
			self, -- 5734
			w, -- 5734
			h, -- 5734
			q, -- 5734
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 5734
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 5734
		) -- 5734
	end -- 5734
	local i = 0 -- 5736
	do -- 5736
		i = 0 -- 5737
		while i < #self.enemies do -- 5737
			local e = self.enemies[i + 1] -- 5738
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 5739
			local enemyY = e.y + (e.depth or 0) -- 5740
			self:drawBox( -- 5741
				draw, -- 5741
				w, -- 5741
				h, -- 5741
				e.x - e.w / 2, -- 5741
				e.x + e.w / 2, -- 5741
				enemyY, -- 5741
				enemyY + e.h, -- 5741
				col -- 5741
			) -- 5741
			if e.alive then -- 5741
				local ef = p.x >= e.x and 1 or -1 -- 5743
				if e.kind == "shield" then -- 5743
					local sh = (e.shieldHp or 0) > 0 -- 5745
					draw:drawRect( -- 5746
						Rect( -- 5746
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 5746
							self:sy(enemyY, h), -- 5746
							self:px(6), -- 5746
							self:px(64) -- 5746
						), -- 5746
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 5747
					) -- 5747
				elseif e.kind == "breaker" then -- 5747
					draw:drawSegment( -- 5749
						Vec2( -- 5749
							self:sx(e.x + ef * 12, w), -- 5749
							self:sy(enemyY + 8, h) -- 5749
						), -- 5749
						Vec2( -- 5750
							self:sx(e.x + ef * 22, w), -- 5750
							self:sy(enemyY + 46, h) -- 5750
						), -- 5750
						self:px(3), -- 5750
						Color(0.5, 0.36, 0.22, 1) -- 5750
					) -- 5750
				end -- 5750
			end -- 5750
			if e.alive and e.warnT > 0 then -- 5750
				local gunX = self:sx(e.x, w) -- 5755
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 5756
				local aimX = self:sx(p.x, w) -- 5757
				local aimY = self:sy(footY + p.h * 0.55, h) -- 5758
				local seg = 8 -- 5759
				local s = 0 -- 5760
				do -- 5760
					s = 0 -- 5761
					while s < seg do -- 5761
						local t0 = s / seg -- 5762
						local t1 = (s + 1) / seg -- 5763
						draw:drawSegment( -- 5764
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 5765
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 5766
							self:px(1), -- 5767
							DANGER -- 5767
						) -- 5767
						s = s + 2 -- 5761
					end -- 5761
				end -- 5761
			end -- 5761
			i = i + 1 -- 5737
		end -- 5737
	end -- 5737
	local k = 0 -- 5772
	do -- 5772
		k = 0 -- 5773
		while k < #self.room.marks do -- 5773
			do -- 5773
				local m = self.room.marks[k + 1] -- 5774
				if m.kind ~= 0 then -- 5774
					goto __continue1052 -- 5776
				end -- 5776
				local on = self.checkpoint == m.x -- 5778
				local x = self:sx(m.x, w) -- 5779
				local y = self:sy(m.y, h) -- 5780
				draw:drawSegment( -- 5781
					Vec2(x, y), -- 5781
					Vec2( -- 5781
						x, -- 5781
						y + self:px(35) -- 5781
					), -- 5781
					self:px(1), -- 5781
					on and CHECK or INK_DIM -- 5781
				) -- 5781
				draw:drawDot( -- 5782
					Vec2( -- 5782
						x, -- 5782
						y + self:px(35) -- 5782
					), -- 5782
					self:px(2), -- 5782
					on and CHECK or INK_DIM -- 5782
				) -- 5782
			end -- 5782
			::__continue1052:: -- 5782
			k = k + 1 -- 5773
		end -- 5773
	end -- 5773
	local j = 0 -- 5786
	do -- 5786
		j = 0 -- 5787
		while j < #self.room.marks do -- 5787
			do -- 5787
				local m = self.room.marks[j + 1] -- 5788
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 5788
					goto __continue1055 -- 5790
				end -- 5790
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 5790
					goto __continue1055 -- 5794
				end -- 5794
				local col = STAND -- 5796
				if m.kind == 4 then -- 5796
					col = PASS_LINE -- 5798
				elseif m.kind == 5 then -- 5798
					col = BRICK_LINE -- 5800
				end -- 5800
				local mx = self:sx(m.x, w) -- 5802
				local my = self:sy(m.y, h) -- 5803
				draw:drawSegment( -- 5804
					Vec2(mx, my), -- 5804
					Vec2( -- 5804
						mx, -- 5804
						my + self:px(24) -- 5804
					), -- 5804
					self:px(1), -- 5804
					col -- 5804
				) -- 5804
			end -- 5804
			::__continue1055:: -- 5804
			j = j + 1 -- 5787
		end -- 5787
	end -- 5787
	local t = 0 -- 5807
	do -- 5807
		t = 0 -- 5808
		while t < #self.room.marks do -- 5808
			do -- 5808
				local m = self.room.marks[t + 1] -- 5809
				if m.kind ~= 6 then -- 5809
					goto __continue1061 -- 5811
				end -- 5811
				local mx = self:sx(m.x, w) -- 5813
				local my = self:sy(m.y, h) -- 5814
				draw:drawSegment( -- 5815
					Vec2(mx, my), -- 5815
					Vec2( -- 5815
						mx, -- 5815
						my + self:px(30) -- 5815
					), -- 5815
					self:px(1), -- 5815
					INK_DIM -- 5815
				) -- 5815
				self:drawBox( -- 5816
					draw, -- 5816
					w, -- 5816
					h, -- 5816
					m.x - 5, -- 5816
					m.x + 5, -- 5816
					m.y + 30, -- 5816
					m.y + 40, -- 5816
					CHECK -- 5816
				) -- 5816
			end -- 5816
			::__continue1061:: -- 5816
			t = t + 1 -- 5808
		end -- 5808
	end -- 5808
	if self.room.key == "village" then -- 5808
		self:drawVillage(draw, w, h) -- 5819
	end -- 5819
	if self.room.key == "forest" then -- 5819
		self:drawDog(draw, w, h) -- 5822
	end -- 5822
end -- 5716
function Play.prototype.drawDog(self, draw, w, h) -- 5827
	local x = self.dogX -- 5828
	self:drawBox( -- 5829
		draw, -- 5829
		w, -- 5829
		h, -- 5829
		x - 14, -- 5829
		x + 14, -- 5829
		0, -- 5829
		20, -- 5829
		SCAV_BODY -- 5829
	) -- 5829
	self:drawBox( -- 5830
		draw, -- 5830
		w, -- 5830
		h, -- 5830
		x - 10, -- 5830
		x - 2, -- 5830
		20, -- 5830
		30, -- 5830
		SCAV_BODY -- 5830
	) -- 5830
	self:drawBox( -- 5831
		draw, -- 5831
		w, -- 5831
		h, -- 5831
		x + 2, -- 5831
		x + 10, -- 5831
		20, -- 5831
		30, -- 5831
		SCAV_HEAD -- 5831
	) -- 5831
	if self.dogState == "ear" or self.dogState == "chase" then -- 5831
		draw:drawSegment( -- 5833
			Vec2( -- 5833
				self:sx(x, w), -- 5833
				self:sy(30, h) -- 5833
			), -- 5833
			Vec2( -- 5834
				self:sx(x, w), -- 5834
				self:sy(40, h) -- 5834
			), -- 5834
			self:px(1), -- 5834
			DANGER -- 5834
		) -- 5834
	end -- 5834
end -- 5827
function Play.prototype.drawVillage(self, draw, w, h) -- 5839
	local bottle = self.room.bottle -- 5840
	if bottle ~= nil then -- 5840
		self:drawBox( -- 5842
			draw, -- 5842
			w, -- 5842
			h, -- 5842
			bottle.x - 14, -- 5842
			bottle.x + 14, -- 5842
			0, -- 5842
			64, -- 5842
			SOLID_FILL -- 5842
		) -- 5842
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 5842
			self:drawBottle( -- 5844
				draw, -- 5844
				w, -- 5844
				h, -- 5844
				bottle.x, -- 5844
				64 -- 5844
			) -- 5844
		end -- 5844
	end -- 5844
	self:drawBox( -- 5848
		draw, -- 5848
		w, -- 5848
		h, -- 5848
		300, -- 5848
		420, -- 5848
		44, -- 5848
		50, -- 5848
		FLOOR_DECK -- 5848
	) -- 5848
	self:drawBox( -- 5849
		draw, -- 5849
		w, -- 5849
		h, -- 5849
		300, -- 5849
		306, -- 5849
		0, -- 5849
		44, -- 5849
		FLOOR_DECK -- 5849
	) -- 5849
	self:drawBox( -- 5850
		draw, -- 5850
		w, -- 5850
		h, -- 5850
		414, -- 5850
		420, -- 5850
		0, -- 5850
		44, -- 5850
		FLOOR_DECK -- 5850
	) -- 5850
	local s = self.room.scavenger -- 5852
	if s ~= nil then -- 5852
		local sx0 = self.scavX -- 5854
		self:drawBox( -- 5855
			draw, -- 5855
			w, -- 5855
			h, -- 5855
			sx0 - 12, -- 5855
			sx0 + 12, -- 5855
			0, -- 5855
			s.h - 14, -- 5855
			SCAV_BODY -- 5855
		) -- 5855
		self:drawBox( -- 5856
			draw, -- 5856
			w, -- 5856
			h, -- 5856
			sx0 - 7, -- 5856
			sx0 + 7, -- 5856
			s.h - 14, -- 5856
			s.h, -- 5856
			SCAV_HEAD -- 5856
		) -- 5856
		if self.scavState == "turn" then -- 5856
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 5858
			draw:drawSegment( -- 5859
				Vec2( -- 5859
					self:sx(sx0, w), -- 5859
					self:sy(s.h - 6, h) -- 5859
				), -- 5859
				Vec2( -- 5859
					self:sx(fx, w), -- 5859
					self:sy(s.h - 6, h) -- 5859
				), -- 5859
				self:px(1), -- 5859
				INK -- 5859
			) -- 5859
		end -- 5859
	end -- 5859
	if self.hasBottle then -- 5859
		local p = self.player -- 5864
		self:drawBottle( -- 5865
			draw, -- 5865
			w, -- 5865
			h, -- 5865
			p.x + p.facing * 10, -- 5865
			p.y + p.h * 0.62 -- 5865
		) -- 5865
	end -- 5865
	if self.bottleFly ~= nil then -- 5865
		self:drawBottle( -- 5868
			draw, -- 5868
			w, -- 5868
			h, -- 5868
			self.bottleFly.x, -- 5868
			self.bottleFly.y -- 5868
		) -- 5868
	end -- 5868
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 5868
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 5871
		draw:drawCircle( -- 5872
			Vec2( -- 5872
				self:sx(self.bottleLandX, w), -- 5872
				self:sy(0, h) -- 5872
			), -- 5872
			self:px(r / ____exports.UNITS_PER_PX), -- 5872
			BRICK_LINE -- 5872
		) -- 5872
	end -- 5872
end -- 5839
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 5876
	self:drawBox( -- 5877
		draw, -- 5877
		w, -- 5877
		h, -- 5877
		x - 3, -- 5877
		x + 3, -- 5877
		y - 10, -- 5877
		y, -- 5877
		BOTTLE -- 5877
	) -- 5877
end -- 5876
function Play.prototype.drawTrace(self, draw, w, h) -- 5880
	local t = self.trace -- 5881
	if t == nil or self.traceT <= 0 then -- 5881
		return -- 5883
	end -- 5883
	draw:drawSegment( -- 5885
		Vec2( -- 5886
			self:sx(t.x0, w), -- 5886
			self:sy(t.y0, h) -- 5886
		), -- 5886
		Vec2( -- 5887
			self:sx(t.x1, w), -- 5887
			self:sy(t.y1, h) -- 5887
		), -- 5887
		self:px(1), -- 5888
		t.hit and AIM_HIT or INK_DIM -- 5888
	) -- 5888
end -- 5880
function Play.prototype.drawAim(self, draw, w, h) -- 5891
	local v = self.view -- 5893
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 5894
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 5895
	local dot = self:px(1) -- 5896
	local arm = self:px(3) -- 5897
	local gap = self:px(1) -- 5898
	draw:drawSegment( -- 5899
		Vec2(gx - arm - gap, gy), -- 5899
		Vec2(gx - gap, gy), -- 5899
		dot / 2, -- 5899
		AIM -- 5899
	) -- 5899
	draw:drawSegment( -- 5900
		Vec2(gx + gap, gy), -- 5900
		Vec2(gx + arm + gap, gy), -- 5900
		dot / 2, -- 5900
		AIM -- 5900
	) -- 5900
	draw:drawSegment( -- 5901
		Vec2(gx, gy - arm - gap), -- 5901
		Vec2(gx, gy - gap), -- 5901
		dot / 2, -- 5901
		AIM -- 5901
	) -- 5901
	draw:drawSegment( -- 5902
		Vec2(gx, gy + gap), -- 5902
		Vec2(gx, gy + arm + gap), -- 5902
		dot / 2, -- 5902
		AIM -- 5902
	) -- 5902
	if self.room.key == "village" and self.hasBottle then -- 5902
		local p = self.player -- 5906
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 5908
		local dir = ____end.x >= p.x and 1 or -1 -- 5909
		local x0 = p.x + dir * 10 -- 5910
		local y0 = p.y + p.h * 0.7 -- 5911
		local T = BOTTLE_FLY_TIME -- 5912
		local vx = (____end.x - x0) / T -- 5913
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 5914
		local pxr = x0 -- 5915
		local pyr = y0 -- 5916
		local t = 1 -- 5917
		do -- 5917
			t = 1 -- 5918
			while t <= 12 do -- 5918
				local tt = t / 12 * T -- 5919
				local nx = x0 + vx * tt -- 5920
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 5921
				draw:drawSegment( -- 5922
					Vec2( -- 5922
						self:sx(pxr, w), -- 5922
						self:sy(pyr, h) -- 5922
					), -- 5922
					Vec2( -- 5922
						self:sx(nx, w), -- 5922
						self:sy(ny, h) -- 5922
					), -- 5922
					self:px(1) / 2, -- 5922
					BOTTLE -- 5922
				) -- 5922
				pxr = nx -- 5923
				pyr = ny -- 5924
				t = t + 1 -- 5918
			end -- 5918
		end -- 5918
		draw:drawCircle( -- 5926
			Vec2( -- 5926
				self:sx(____end.x, w), -- 5926
				self:sy(____end.y + 2, h) -- 5926
			), -- 5926
			self:px(2), -- 5926
			BOTTLE -- 5926
		) -- 5926
	end -- 5926
end -- 5891
return ____exports -- 5891