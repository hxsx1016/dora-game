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
local makeActor, drawFigure, rayInterval, hitBox, drawCartShape, CHILD_W, CHILD_H, SOLDIER_W, SOLDIER_H, INK, CART_FILL, CLOTH -- 6128
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
function makeActor(room, index) -- 6128
	local sp = room.spawns -- 6129
	if index < 0 or index >= #sp then -- 6130
		return { -- 6131
			x = 0, -- 6131
			y = 0, -- 6131
			depth = 0, -- 6131
			depthSpeed = 0, -- 6131
			vx = 0, -- 6131
			vy = 0, -- 6131
			w = CHILD_W, -- 6131
			h = CHILD_H, -- 6131
			onGround = true, -- 6131
			facing = 1, -- 6131
			crouch = false, -- 6131
			rollT = 0, -- 6131
			covered = false, -- 6131
			alive = false -- 6131
		} -- 6131
	end -- 6131
	local s = sp[index + 1] -- 6133
	local child = s.h < SOLDIER_H -- 6134
	local ground = room.depth -- 6135
	local depth = ground == nil and 0 or math.max( -- 6136
		ground.min, -- 6136
		math.min(ground.max, s.depth or 0) -- 6136
	) -- 6136
	return { -- 6137
		x = s.x, -- 6138
		y = s.y, -- 6138
		depth = depth, -- 6138
		depthSpeed = 0, -- 6138
		vx = 0, -- 6138
		vy = 0, -- 6138
		w = child and CHILD_W or SOLDIER_W, -- 6139
		h = child and CHILD_H or SOLDIER_H, -- 6140
		onGround = true, -- 6141
		facing = 1, -- 6141
		crouch = false, -- 6141
		rollT = 0, -- 6141
		covered = false, -- 6141
		alive = true -- 6141
	} -- 6141
end -- 6141
function drawFigure(draw, play, w, h, a, body, head) -- 6145
	if not a.alive then -- 6146
		return -- 6147
	end -- 6147
	local x0 = a.x - a.w / 2 -- 6149
	local x1 = a.x + a.w / 2 -- 6150
	local y0 = a.y + a.depth * DEPTH_Y_SCALE -- 6151
	local y1 = y0 + a.h -- 6152
	play:drawBox( -- 6153
		draw, -- 6153
		w, -- 6153
		h, -- 6153
		x0, -- 6153
		x1, -- 6153
		y0, -- 6153
		y1 - a.h * 0.26, -- 6153
		body -- 6153
	) -- 6153
	play:drawBox( -- 6154
		draw, -- 6154
		w, -- 6154
		h, -- 6154
		x0 + 2, -- 6154
		x1 - 2, -- 6154
		y1 - a.h * 0.26, -- 6154
		y1, -- 6154
		head -- 6154
	) -- 6154
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 6156
	play:drawBox( -- 6157
		draw, -- 6157
		w, -- 6157
		h, -- 6157
		eyeX, -- 6157
		eyeX + 4, -- 6157
		y1 - a.h * 0.14, -- 6157
		y1 - a.h * 0.08, -- 6157
		INK -- 6157
	) -- 6157
end -- 6157
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 6161
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 6162
end -- 6161
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 6169
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 6170
end -- 6169
function rayInterval(origin, direction, min, max) -- 6177
	if direction == 0 then -- 6178
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 6179
	end -- 6179
	local a = (min - origin) / direction -- 6181
	local b = (max - origin) / direction -- 6182
	return { -- 6183
		min = math.min(a, b), -- 6183
		max = math.max(a, b) -- 6183
	} -- 6183
end -- 6183
function hitBox(ray, box) -- 6187
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 6188
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 6189
	local enter = math.max(0, x.min, y.min) -- 6190
	local leave = math.min(99999, x.max, y.max) -- 6191
	if box.depth ~= nil then -- 6192
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 6193
		enter = math.max(enter, depth.min) -- 6194
		leave = math.min(leave, depth.max) -- 6195
	end -- 6195
	return leave >= enter and enter or -1 -- 6197
end -- 6197
function drawCartShape(draw, play, w, h, c, axleX) -- 6200
	local half = c.bodyW / 2 -- 6201
	local x0 = axleX - half -- 6202
	local x1 = axleX + half -- 6203
	local axleY = c.baseY + (c.depth or 0) * DEPTH_Y_SCALE + c.wheelR -- 6204
	play:drawBox( -- 6205
		draw, -- 6205
		w, -- 6205
		h, -- 6205
		x0, -- 6205
		x1, -- 6205
		axleY, -- 6205
		axleY + c.bodyH, -- 6205
		CART_FILL -- 6205
	) -- 6205
	draw:drawCircle( -- 6206
		Vec2( -- 6206
			play:sx(x0 + c.bodyW * 0.28, w), -- 6206
			play:sy(axleY, h) -- 6206
		), -- 6206
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6206
		Color(52, 50, 48, 255) -- 6206
	) -- 6206
	draw:drawCircle( -- 6207
		Vec2( -- 6207
			play:sx(x1 - c.bodyW * 0.28, w), -- 6207
			play:sy(axleY, h) -- 6207
		), -- 6207
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6207
		Color(52, 50, 48, 255) -- 6207
	) -- 6207
	local cx = c.clothSide < 0 and x0 or x1 -- 6208
	play:drawBox( -- 6209
		draw, -- 6209
		w, -- 6209
		h, -- 6209
		cx - 10, -- 6209
		cx + 10, -- 6209
		axleY + c.bodyH, -- 6209
		axleY + c.bodyH + 18, -- 6209
		CLOTH -- 6209
	) -- 6209
end -- 6209
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
function Play.prototype.____constructor(self, room, resume, run) -- 676
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
	self.paused = false -- 660
	self.ticks = 0 -- 662
	self.view = {zoom = 1, ox = 0, oy = 0} -- 664
	self.ox = 0 -- 666
	self.aimX = 0 -- 668
	self.aimY = 0 -- 669
	self.viewW = 0 -- 671
	self.viewH = 0 -- 672
	self.ox = room.originX -- 678
	self.room = withOrigin(room) -- 679
	local wr = self.room -- 680
	self.run = run or createRun() -- 681
	self.inventory = self.run.inventory -- 682
	self.archive = self.run.archive -- 683
	self.equippedWeapon = self.run.story.craftedWeapon == "" and "standard_gun" or self.run.story.craftedWeapon -- 684
	self.isCampaign = wr.campaign ~= nil -- 685
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 686
	self:buildWorld() -- 687
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 690
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 692
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 693
	local soloRoom = wr.key == "museum" -- 695
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 696
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 697
	self.player = makeActor(wr, playerIdx) -- 698
	self.partner = makeActor(wr, partnerIdx) -- 699
	self.phase = phaseOf(wr.key) -- 700
	if soloRoom then -- 701
		local mp = self.archive.museumPhase -- 703
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 704
	end -- 704
	if wr.story ~= nil then -- 709
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 710
	end -- 710
	self.cam.x = self.player.x -- 712
	self.cam.y = self.player.y + CAM_LOOK_UP -- 713
	self.cartAxle = wr.cart.startX -- 714
	self.escort = __TS__New( -- 715
		Escort, -- 715
		safeAnchorX(wr.marks) -- 715
	) -- 715
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 716
	if self.isCampaign then -- 717
		self:setupCampaign() -- 718
	else -- 718
		self:buildEnemies() -- 720
	end -- 720
	if resume ~= nil and resume.checkpoint > 0 then -- 723
		self.checkpoint = resume.checkpoint -- 724
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 725
			self.cartAxle = self.room.cart.endX -- 726
			self.cartDocked = true -- 727
			self.player.x = self.ox + 380 -- 730
			self.player.y = 0 -- 731
			self.player.vy = 0 -- 732
			self.player.onGround = true -- 733
			self.cam.x = self.player.x -- 734
			self.cam.y = self.player.y + CAM_LOOK_UP -- 735
		end -- 735
	end -- 735
	self:restoreStory() -- 738
end -- 676
function Play.prototype.towerEndReady(self) -- 568
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 569
	return self.room.key == "tower" and self.phase == "tower-end" and self.phaseTick >= waitTicks and not self.towerEndMustRelease -- 570
end -- 568
function Play.prototype.recipeViews(self) -- 751
	local out = {} -- 752
	local i = 0 -- 753
	do -- 753
		i = 0 -- 754
		while i < #CRAFT_RECIPES do -- 754
			local r = CRAFT_RECIPES[i + 1] -- 755
			local cost = {} -- 756
			if r.cost.wood ~= nil then -- 757
				cost.wood = r.cost.wood -- 758
			end -- 758
			if r.cost.bell ~= nil then -- 760
				cost.bell = r.cost.bell -- 761
			end -- 761
			out[#out + 1] = { -- 763
				id = r.id, -- 764
				name = r.name, -- 765
				desc = r.desc, -- 766
				enhancedEffect = r.enhancedEffect, -- 767
				cost = cost, -- 768
				crafted = self.run.story.craftedWeapon == r.id -- 769
			} -- 769
			i = i + 1 -- 754
		end -- 754
	end -- 754
	if self.archive.artifactOwned then -- 773
		out[#out + 1] = { -- 774
			id = ARTIFACT_WEAPON_ID, -- 775
			name = weaponNameOf(ARTIFACT_WEAPON_ID), -- 776
			desc = "井底拾取彩蛋 · 男主线移动留下冷白微金轨迹残影", -- 777
			enhancedEffect = "light", -- 778
			cost = {}, -- 779
			crafted = true -- 780
		} -- 780
	end -- 780
	return out -- 783
end -- 751
function Play.prototype.syncCraftBench(self) -- 787
	local view = self.craftBench -- 788
	local inv = self.run.inventory -- 789
	view.inventory = { -- 790
		wood = inv.wood, -- 790
		bell = inv.bell, -- 790
		scrap = inv.scrap, -- 790
		wedge = inv.wedge, -- 790
		ammo = inv.ammo -- 790
	} -- 790
	view.recipes = self:recipeViews() -- 791
	view.equippedWeapon = self.equippedWeapon -- 792
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 793
	if view.justCraftedTimer > 0 then -- 794
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 795
	end -- 795
end -- 787
function Play.prototype.openCraftBench(self) -- 800
	if self.room.key ~= "escort3" or self.craftBench.active then -- 801
		return -- 802
	end -- 802
	self.craftBench.active = true -- 804
	self.carryOn = false -- 805
	self.run.story.carry = false -- 806
	self.player.vx = 0 -- 807
	self.player.vy = 0 -- 808
	self.craftBench.justCraftedTimer = 0 -- 809
	self:syncCraftBench() -- 810
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 811
	self:log("开工台") -- 812
	self:emit( -- 813
		"benchOpen", -- 813
		{ -- 813
			recipes = __TS__ArrayMap( -- 814
				self.craftBench.recipes, -- 814
				function(____, r) return r.id end -- 814
			), -- 814
			inventory = self.craftBench.inventory, -- 815
			carry = self.carryOn -- 816
		} -- 816
	) -- 816
end -- 800
function Play.prototype.closeCraftBench(self) -- 821
	if not self.craftBench.active then -- 822
		return -- 823
	end -- 823
	self.craftBench.active = false -- 825
	self.craftBench.justCraftedTimer = 0 -- 826
	self.carryOn = true -- 827
	self.run.story.carry = true -- 828
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 829
	self:log("离站背起") -- 830
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 831
end -- 821
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 838
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 839
		return false -- 840
	end -- 840
	local recipe = findRecipe(recipeId) -- 842
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 843
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 844
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 845
		return false -- 846
	end -- 846
	local missing = missingMaterials(self.run.inventory, recipe) -- 848
	if #missing > 0 then -- 849
		self:flashSet( -- 850
			"缺料 · " .. table.concat(missing, " / "), -- 850
			1.6 -- 850
		) -- 850
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 851
		return false -- 852
	end -- 852
	payMaterials(self.run.inventory, recipe) -- 854
	self.handledCraftRequests[requestId] = true -- 855
	self.run.story.craftedWeapon = recipe.id -- 856
	self.run.story.equippedWeapon = recipe.id -- 857
	self.equippedWeapon = recipe.id -- 858
	self.sessionDirty = true -- 859
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 860
	self.craftBench.firstCraftDone = true -- 861
	self:syncCraftBench() -- 862
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 863
	self:log("改制 " .. recipe.id) -- 864
	self:emit("benchCraft", { -- 865
		recipeId = recipe.id, -- 866
		weapon = recipe.id, -- 867
		effect = recipe.enhancedEffect, -- 868
		wood = self.run.inventory.wood, -- 869
		bell = self.run.inventory.bell -- 870
	}) -- 870
	return true -- 872
end -- 838
function Play.prototype.equipWeapon(self, weaponId) -- 876
	local artifactOk = weaponId == ARTIFACT_WEAPON_ID and self.archive.artifactOwned -- 877
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId and not artifactOk then -- 878
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 879
		return false -- 880
	end -- 880
	self.equippedWeapon = weaponId -- 882
	self.run.story.equippedWeapon = weaponId -- 883
	self.sessionDirty = true -- 884
	self:syncCraftBench() -- 885
	self:flashSet( -- 886
		"已装备 " .. weaponNameOf(weaponId), -- 886
		1 -- 886
	) -- 886
	self:emit("benchEquip", {weapon = weaponId}) -- 887
	return true -- 888
end -- 876
function Play.prototype.toggleArtifactWeapon(self) -- 892
	if not self.archive.artifactOwned or self.childMode then -- 893
		return false -- 894
	end -- 894
	if self.equippedWeapon == ARTIFACT_WEAPON_ID then -- 896
		local fallback = self.run.story.craftedWeapon ~= "" and self.run.story.craftedWeapon or "standard_gun" -- 897
		return self:equipWeapon(fallback) -- 898
	end -- 898
	return self:equipWeapon(ARTIFACT_WEAPON_ID) -- 900
end -- 892
function Play.prototype.exportSession(self) -- 904
	self:syncStory() -- 905
	local story = self.run.story -- 906
	local inv = self.run.inventory -- 907
	local taken = {} -- 908
	for k in pairs(self.run.taken) do -- 909
		if self.run.taken[k] == true then -- 910
			taken[#taken + 1] = k -- 911
		end -- 911
	end -- 911
	local segments = {} -- 914
	for k in pairs(story.segments) do -- 915
		if story.segments[k] == true then -- 916
			segments[#segments + 1] = k -- 917
		end -- 917
	end -- 917
	local props = {} -- 920
	for k in pairs(self.run.props) do -- 921
		local st = self.run.props[k] -- 922
		if st ~= nil then -- 923
			props[#props + 1] = (((((((k .. ":") .. (st.broken and "1" or "0")) .. ":") .. tostring(math.floor(st.hp + 0.5))) .. ":") .. (st.wedge and "1" or "0")) .. ":") .. (st.revealed == true and "1" or "0") -- 924
		end -- 924
	end -- 924
	return { -- 933
		roomKey = self.room.key, -- 934
		checkpoint = self.checkpoint, -- 935
		seed = self.run.seed, -- 936
		route = story.route, -- 937
		hp = story.hp, -- 938
		maxHp = story.maxHp, -- 939
		hpAtGate = story.hpAtGate, -- 940
		maxHpAtGate = story.maxHpAtGate, -- 941
		settled = story.settled, -- 942
		phase = self.phase, -- 943
		countTick = story.countTick, -- 944
		phaseTick = story.phaseTick, -- 945
		handTicks = story.handTicks, -- 946
		handDone = story.handDone, -- 947
		lineSaid = story.lineSaid, -- 948
		tied = story.tied, -- 949
		carry = story.carry, -- 950
		escortDone = story.escortDone, -- 951
		craftedWeapon = story.craftedWeapon, -- 952
		equippedWeapon = self.equippedWeapon, -- 953
		wood = inv.wood, -- 954
		bell = inv.bell, -- 955
		scrap = inv.scrap, -- 956
		wedge = inv.wedge, -- 957
		ammo = inv.ammo, -- 958
		shield = inv.shield, -- 959
		pass = inv.pass, -- 960
		quickbelt = inv.quickbelt, -- 961
		taken = taken, -- 962
		segments = segments, -- 963
		cartAxle = self.cartAxle, -- 964
		cartDocked = self.cartDocked, -- 965
		campaignRoute = self.run.route, -- 966
		joined = self.run.joined, -- 967
		c1Latch = self.run.c1Latch, -- 968
		c2Latch = self.run.c2Latch, -- 969
		talentSeed = story.talents ~= nil and story.talents.randomState or 0, -- 970
		talentRoom = story.talents ~= nil and story.talents.room or "", -- 971
		talentOffers = story.talents ~= nil and __TS__ArraySlice(story.talents.offers) or ({}), -- 972
		talentVitality = story.talents ~= nil and story.talents.ranks.vitality or 0, -- 973
		talentReload = story.talents ~= nil and story.talents.ranks.reload or 0, -- 974
		talentGuard = story.talents ~= nil and story.talents.ranks.guard or 0, -- 975
		talentCraft = story.talents ~= nil and story.talents.ranks.craft or 0, -- 976
		props = props, -- 977
		playerX = self.player.x, -- 978
		playerY = self.player.y, -- 979
		playerDepth = self.player.depth, -- 980
		gateTick = self.gateTick, -- 981
		hasBottle = self.hasBottle, -- 982
		villagePassed = self.passed -- 983
	} -- 983
end -- 904
function Play.prototype.submitFeIntent(self, intent) -- 991
	local kind = intent == nil and "" or intent.kind -- 992
	if kind == "gateReunionHold" then -- 993
		if self.room.key ~= "gate" or self.phase ~= "gate-wait" and self.phase ~= "gate-count" then -- 994
			return false -- 995
		end -- 995
		local holding = intent.holding == true -- 997
		self.intentGateReunionHold = holding -- 998
		if not holding and self.phase == "gate-wait" then -- 999
			if self.handTicks > 0 then -- 1000
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1001
			end -- 1001
			self.handTicks = 0 -- 1003
			self.handArmed = true -- 1004
		end -- 1004
		return true -- 1006
	end -- 1006
	if kind == "reloadOpen" then -- 1008
		local camp = self.room.campaign -- 1009
		if self.run.trial ~= nil or camp == nil or camp.reloadPuzzle ~= true or self.reloadOpen then -- 1010
			return false -- 1011
		end -- 1011
		self:beginReload() -- 1013
		return self.reloadOpen -- 1014
	end -- 1014
	if kind == "reloadPathPreview" then -- 1016
		local path = intent.path -- 1017
		return type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) -- 1018
	end -- 1018
	if kind == "reloadTapNode" then -- 1020
		local node = intent.node -- 1021
		if type(node) == "number" then -- 1022
			self:reloadTapNode(node) -- 1023
			return true -- 1024
		end -- 1024
		return false -- 1026
	end -- 1026
	if kind == "reloadPathCommit" then -- 1028
		local path = intent.path -- 1029
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 1030
			local list = path -- 1031
			local i = 0 -- 1032
			do -- 1032
				i = 0 -- 1033
				while i < #list do -- 1033
					do -- 1033
						if i == 0 and list[i + 1] == RELOAD_START then -- 1034
							goto __continue70 -- 1035
						end -- 1035
						self:reloadTapNode(list[i + 1]) -- 1037
					end -- 1037
					::__continue70:: -- 1037
					i = i + 1 -- 1033
				end -- 1033
			end -- 1033
			return true -- 1039
		end -- 1039
		return false -- 1041
	end -- 1041
	if kind == "reloadCancel" then -- 1043
		self:closeReloadPuzzle() -- 1044
		return true -- 1045
	end -- 1045
	if kind == "craftSubmit" then -- 1047
		local recipeId = intent.recipeId -- 1048
		local requestId = intent.requestId -- 1049
		if type(recipeId) == "string" and type(requestId) == "string" then -- 1050
			return self:craftAtBench(recipeId, requestId) -- 1051
		end -- 1051
		return false -- 1053
	end -- 1053
	if kind == "craftEquip" then -- 1055
		local weaponId = intent.weaponId -- 1056
		if type(weaponId) == "string" then -- 1057
			return self:equipWeapon(weaponId) -- 1058
		end -- 1058
		return false -- 1060
	end -- 1060
	if kind == "craftClose" then -- 1062
		self:closeCraftBench() -- 1063
		return true -- 1064
	end -- 1064
	if kind == "chooseTalent" then -- 1066
		local slot = intent.slot -- 1067
		if type(slot) == "number" then -- 1068
			return self:chooseTalent(slot) -- 1069
		end -- 1069
		return false -- 1071
	end -- 1071
	if kind == "wellPick" then -- 1073
		return self:pickWell() -- 1074
	end -- 1074
	if kind == "museumInteract" then -- 1076
		local target = type(intent.target) == "string" and intent.target or "" -- 1077
		if target == "well_pickup" or target == "well" then -- 1078
			return self:pickWell() -- 1079
		end -- 1079
		if self.room.key ~= "museum" then -- 1081
			return false -- 1082
		end -- 1082
		return self:triggerMuseumIntent(target) -- 1084
	end -- 1084
	return false -- 1086
end -- 991
function Play.prototype.triggerMuseumIntent(self, target) -- 1090
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 1091
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 1094
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 1095
	if self.phase == "museum-cabinet" then -- 1096
		if target == "enter_hall" or (target == "" or target == "cabinet" or target == "weapon_case") and atCase then -- 1097
			self.pendingMuseumIntentTarget = "cabinet" -- 1098
			return true -- 1099
		end -- 1099
	end -- 1099
	if self.phase == "museum-hall" then -- 1102
		if (target == "lamp_turn" or target == "lamp" or target == "west_lamp") and nearLamp then -- 1103
			self.pendingMuseumIntentTarget = "lamp_direct" -- 1104
			return true -- 1105
		end -- 1105
		if (target == "" or target == "hall" or target == "corridor") and self.player.x >= self.ox + mu.hallX then -- 1107
			self.pendingMuseumIntentTarget = "hall" -- 1108
			return true -- 1109
		end -- 1109
	end -- 1109
	if self.phase == "museum-lamp" and (target == "" or target == "lamp" or target == "west_lamp" or target == "lamp_turn") and nearLamp then -- 1112
		self.pendingMuseumIntentTarget = "lamp" -- 1115
		return true -- 1116
	end -- 1116
	if self.phase == "museum-return" then -- 1118
		if target == "begin_return_cabinet" or (target == "" or target == "return_cabinet" or target == "cabinet" or target == "return") and atCase then -- 1119
			self.pendingMuseumIntentTarget = "return_cabinet" -- 1121
			return true -- 1122
		end -- 1122
	end -- 1122
	if self.phase == "museum-done" and (target == "" or target == "return_cabinet" or target == "return") then -- 1125
		self.pendingMuseumIntentTarget = "done" -- 1126
		return true -- 1127
	end -- 1127
	return false -- 1129
end -- 1090
function Play.prototype.captureCheckpoint(self, id) -- 1133
	local inv = self.run.inventory -- 1134
	self.checkpointSnap = { -- 1135
		id = id, -- 1136
		wood = inv.wood, -- 1137
		bell = inv.bell, -- 1138
		scrap = inv.scrap, -- 1139
		wedge = inv.wedge, -- 1140
		ammo = inv.ammo, -- 1141
		shield = inv.shield, -- 1142
		pass = inv.pass, -- 1143
		quickbelt = inv.quickbelt, -- 1144
		crafted = self.run.story.craftedWeapon, -- 1145
		equipped = self.equippedWeapon, -- 1146
		carry = self.carryOn -- 1147
	} -- 1147
	self.run.story.cp = self.checkpointSnap -- 1149
end -- 1133
function Play.prototype.applyCheckpointSnap(self, id) -- 1153
	local snap = self.run.story.cp -- 1154
	if snap == nil or snap.id ~= id then -- 1155
		return false -- 1156
	end -- 1156
	self.checkpointSnap = snap -- 1158
	local inv = self.run.inventory -- 1159
	inv.wood = snap.wood -- 1160
	inv.bell = snap.bell -- 1161
	inv.scrap = snap.scrap -- 1162
	inv.wedge = snap.wedge -- 1163
	inv.ammo = snap.ammo -- 1164
	inv.shield = snap.shield -- 1165
	inv.pass = snap.pass -- 1166
	inv.quickbelt = snap.quickbelt -- 1167
	self.run.story.craftedWeapon = snap.crafted -- 1168
	self.equippedWeapon = snap.equipped -- 1169
	self.run.story.equippedWeapon = snap.equipped -- 1170
	self.carryOn = snap.carry -- 1171
	self.run.story.carry = snap.carry -- 1172
	self.craftBench.active = false -- 1173
	self:syncCraftBench() -- 1174
	return true -- 1175
end -- 1153
function Play.prototype.restoreStory(self) -- 1178
	if self.isCampaign and self.run.trial ~= nil then -- 1181
		return -- 1182
	end -- 1182
	local story = self.run.story -- 1184
	if story == nil then -- 1185
		return -- 1186
	end -- 1186
	if story.maxHp > 0 then -- 1188
		self.maxHp = story.maxHp -- 1189
		self.hp = math.max( -- 1190
			1, -- 1190
			math.min(story.hp, story.maxHp) -- 1190
		) -- 1190
	end -- 1190
	self.storyRoute = story.route -- 1192
	self.storySettled = story.settled -- 1193
	self.hpAtGate = story.hpAtGate -- 1194
	self.maxHpAtGate = story.maxHpAtGate -- 1195
	self.handDone = story.handDone -- 1196
	self.lineSaid = story.lineSaid -- 1197
	self.tied = story.handDone -- 1198
	self.carryOn = story.carry or story.route == "soldier" and (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 1199
	self.museumReturn = story.museumReturn -- 1200
	story.museumReturn = false -- 1201
	self.escortDone = story.escortDone -- 1202
	local savedEq = story.equippedWeapon -- 1203
	if savedEq == ARTIFACT_WEAPON_ID and self.archive.artifactOwned then -- 1204
		self.equippedWeapon = ARTIFACT_WEAPON_ID -- 1205
	elseif savedEq == "standard_gun" or savedEq ~= "" and savedEq == story.craftedWeapon then -- 1206
		self.equippedWeapon = savedEq -- 1207
	else -- 1207
		self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 1209
	end -- 1209
	self:syncCraftBench() -- 1211
	if story.segments.outside_cart == true then -- 1213
		self.redCartPulled = true -- 1214
		local redBox = __TS__ArrayFind( -- 1215
			self.boxes, -- 1215
			function(____, b) return b.id == "outside_red_cart" end -- 1215
		) -- 1215
		if redBox ~= nil then -- 1216
			redBox.x0 = 430 -- 1217
			redBox.x1 = 474 -- 1218
		end -- 1218
		if self.room.key == "outside" and self.room.cart.bodyW > 0 then -- 1220
			self.cartAxle = self.room.cart.endX -- 1221
			self.cartDocked = true -- 1222
		end -- 1222
	end -- 1222
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 1225
	self.waterSeen = story.segments.water_lantern == true -- 1227
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 1229
		self:applyCheckpointSnap(self.checkpoint) -- 1230
	end -- 1230
	if self.room.key == "tower" and story.route == "soldier" then -- 1233
		self.carryOn = false -- 1234
		self.run.story.carry = false -- 1235
		self.player.w = SOLDIER_W -- 1236
		self.player.h = SOLDIER_H -- 1237
		self.player.x = math.max(self.ox + 422, self.player.x) -- 1238
		self.partner = { -- 1239
			x = math.max(self.ox + 408, self.player.x - 24), -- 1240
			y = 0, -- 1241
			depth = 0, -- 1242
			depthSpeed = 0, -- 1243
			vx = 0, -- 1244
			vy = 0, -- 1245
			w = CHILD_W, -- 1246
			h = CHILD_H, -- 1247
			onGround = true, -- 1248
			facing = 1, -- 1249
			crouch = false, -- 1250
			rollT = 0, -- 1251
			covered = false, -- 1252
			alive = true -- 1253
		} -- 1253
	end -- 1253
	if self.room.key == "tower" then -- 1257
		if story.segments.tower_door == true then -- 1258
			self:openTowerDoor() -- 1259
		end -- 1259
		self.towerHanded = story.segments.tower_handover == true -- 1261
		self.deskHold = 0 -- 1262
		if story.phase == "tower-enter" or story.phase == "tower-desk" or story.phase == "tower-given" then -- 1263
			self.phase = story.phase -- 1264
			self.phaseTick = 0 -- 1265
			if story.phase == "tower-desk" or story.phase == "tower-given" then -- 1266
				self.player.x = self.ox + 605 -- 1267
				self.player.y = 0 -- 1268
				if story.route == "soldier" and self.partner.alive then -- 1269
					self.partner.x = self.ox + 568 -- 1270
					self.partner.y = 0 -- 1271
					self.partner.facing = 1 -- 1272
				end -- 1272
			end -- 1272
		end -- 1272
	end -- 1272
	if self.room.key == "prologue" then -- 1278
		local ph = story.phase -- 1279
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 1280
			self.phase = ph -- 1281
			self.phaseTick = story.phaseTick -- 1282
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 1283
			self.player.y = 0 -- 1284
			self.player.depth = 0 -- 1285
			self.player.vx = 0 -- 1286
			self.partner.x = self.ox + 300 -- 1287
			self.partner.y = 0 -- 1288
			self.partner.depth = 0 -- 1289
			self.partner.vx = 0 -- 1290
			self.partner.alive = true -- 1291
			if ph == "prologue-follow" then -- 1292
				self.partner.crouch = false -- 1293
				self.partner.h = CHILD_H -- 1294
			else -- 1294
				self.partner.crouch = true -- 1296
				self.partner.h = CHILD_CROUCH_H -- 1297
			end -- 1297
			self.cam.x = self.player.x -- 1299
		end -- 1299
		return -- 1301
	end -- 1301
	if self.room.key ~= "gate" then -- 1303
		return -- 1304
	end -- 1304
	local ____temp_0 -- 1306
	if self.room.story == nil then -- 1306
		____temp_0 = nil -- 1306
	else -- 1306
		____temp_0 = self.room.story.gate -- 1306
	end -- 1306
	local g = ____temp_0 -- 1306
	if g == nil then -- 1307
		return -- 1308
	end -- 1308
	if story.phase == "gate-send" then -- 1311
		self.phase = "gate-send" -- 1312
		self.gateTick = g.holdTicks -- 1313
		self.gateSpawned = 4 -- 1314
		self.enemies = {} -- 1315
		self.player.x = self.ox + g.doorX - 40 -- 1316
		self.player.y = 0 -- 1317
		self.player.depth = 0 -- 1318
		self.player.vx = 0 -- 1319
		self.player.vy = 0 -- 1320
		self.player.onGround = true -- 1321
		self.partner.x = self.ox + g.waitX -- 1322
		self.partner.y = 0 -- 1323
		self.partner.depth = 0 -- 1324
		self.partner.alive = true -- 1325
		self.cam.x = self.player.x -- 1326
		self.handTicks = 0 -- 1327
		self.handArmed = false -- 1328
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1329
		return -- 1330
	end -- 1330
	if not story.settled then -- 1332
		return -- 1333
	end -- 1333
	self.gateTick = g.holdTicks -- 1336
	self.gateSpawned = 4 -- 1337
	self.enemies = {} -- 1338
	if story.phase == "gate-farewell" or story.phase == "gate-count" or story.phase == "gate-walk" then -- 1339
		self.phase = story.phase == "gate-farewell" and "gate-count" or story.phase -- 1340
		self.countTick = story.phase == "gate-farewell" and 0 or math.max(story.countTick, 0) -- 1341
		self:swapToChild(g.doorX + 30) -- 1342
		self.countPrevMove = 0 -- 1343
		self.countArmed = false -- 1344
		return -- 1345
	end -- 1345
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1347
		self.phase = story.phase -- 1348
		self.countTick = ____exports.GATE_COUNT_END -- 1349
		self.phaseTick = story.phaseTick -- 1350
		self:swapToChild(g.doorX + 30) -- 1351
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1352
			0, -- 1352
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1352
		) -- 1352
		self.handArmed = false -- 1353
	end -- 1353
end -- 1178
function Play.prototype.buildWorld(self) -- 1358
	local room = self.room -- 1359
	self.boxes = {} -- 1360
	self.floors = {} -- 1361
	local i = 0 -- 1362
	do -- 1362
		i = 0 -- 1363
		while i < #room.floors do -- 1363
			local f = room.floors[i + 1] -- 1364
			local ____self_floors_1 = self.floors -- 1365
			____self_floors_1[#____self_floors_1 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1365
			i = i + 1 -- 1363
		end -- 1363
	end -- 1363
	do -- 1363
		i = 0 -- 1367
		while i < #room.solids do -- 1367
			local s = room.solids[i + 1] -- 1368
			if not s.decorative then -- 1369
				local ____self_boxes_13 = self.boxes -- 1374
				local ____s_x_4 = s.x -- 1375
				local ____temp_5 = s.x + s.w -- 1375
				local ____s_y_6 = s.y -- 1375
				local ____temp_7 = s.y + s.h -- 1375
				local ____temp_2 -- 1376
				if room.depth == nil then -- 1376
					____temp_2 = nil -- 1376
				else -- 1376
					____temp_2 = s.depth -- 1376
				end -- 1376
				local ____temp_8 = s.passable == true -- 1377
				local ____s_label_9 = s.label -- 1377
				local ____s_id_10 = s.id -- 1378
				local ____temp_11 = s.soft == true -- 1378
				local ____temp_12 = s.hidden == true -- 1378
				local ____temp_3 -- 1379
				if s.breakable == nil then -- 1379
					____temp_3 = nil -- 1379
				else -- 1379
					____temp_3 = __TS__ObjectAssign({}, s.breakable) -- 1379
				end -- 1379
				____self_boxes_13[#____self_boxes_13 + 1] = { -- 1374
					x0 = ____s_x_4, -- 1375
					x1 = ____temp_5, -- 1375
					y0 = ____s_y_6, -- 1375
					y1 = ____temp_7, -- 1375
					depth = ____temp_2, -- 1376
					passable = ____temp_8, -- 1377
					label = ____s_label_9, -- 1377
					id = ____s_id_10, -- 1378
					soft = ____temp_11, -- 1378
					hidden = ____temp_12, -- 1378
					breakable = ____temp_3, -- 1379
					interact = s.interact -- 1380
				} -- 1380
			end -- 1380
			i = i + 1 -- 1367
		end -- 1367
	end -- 1367
	do -- 1367
		i = 0 -- 1384
		while i < #room.stairs do -- 1384
			local st = room.stairs[i + 1] -- 1385
			local n = st.steps + 1 -- 1386
			local stepW = (st.x1 - st.x0) / n -- 1387
			local k = 0 -- 1388
			do -- 1388
				k = 0 -- 1389
				while k < n do -- 1389
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1390
					local x0 = st.x0 + stepW * k -- 1391
					local ____self_boxes_17 = self.boxes -- 1394
					local ____temp_15 = x0 + stepW -- 1395
					local ____temp_16 = -8 -- 1395
					local ____temp_14 -- 1396
					if room.depth == nil then -- 1396
						____temp_14 = nil -- 1396
					else -- 1396
						____temp_14 = st.depth -- 1396
					end -- 1396
					____self_boxes_17[#____self_boxes_17 + 1] = { -- 1394
						x0 = x0, -- 1395
						x1 = ____temp_15, -- 1395
						y0 = ____temp_16, -- 1395
						y1 = y, -- 1395
						depth = ____temp_14, -- 1396
						passable = true -- 1397
					} -- 1397
					k = k + 1 -- 1389
				end -- 1389
			end -- 1389
			i = i + 1 -- 1384
		end -- 1384
	end -- 1384
end -- 1358
function Play.prototype.setupCampaign(self) -- 1407
	local wr = self.room -- 1408
	local c = wr.campaign -- 1409
	if c == nil then -- 1410
		return -- 1411
	end -- 1411
	self.roomStartTick = self.run.ticks -- 1413
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1415
		self.run.joined = true -- 1417
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1418
		local ____self_run_22 = self.run -- 1420
		local ____temp_21 -- 1420
		if wr.key == "s2-drygoods" then -- 1420
			local ____temp_20 = self.run.route ~= "drygoods" -- 1421
			if not ____temp_20 then -- 1421
				local ____opt_18 = self.run.props.s2_board -- 1421
				____temp_20 = (____opt_18 and ____opt_18.broken) == true -- 1421
			end -- 1421
			____temp_21 = ____temp_20 -- 1421
		else -- 1421
			____temp_21 = wr.key == "c1-yard" and self.run.c1Latch -- 1422
		end -- 1422
		____self_run_22.joined = ____temp_21 -- 1420
	end -- 1420
	local x = wr.minX + 60 -- 1424
	local y = 0 -- 1425
	local depth = 0 -- 1426
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1427
		x = wr.minX + 210 -- 1428
		depth = -32 -- 1429
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1430
		x = wr.minX + 40 -- 1431
		y = 32 -- 1432
		depth = 32 -- 1433
	end -- 1433
	self.player = { -- 1435
		x = x, -- 1436
		y = y, -- 1436
		depth = depth, -- 1436
		depthSpeed = 0, -- 1436
		vx = 0, -- 1436
		vy = 0, -- 1436
		w = SOLDIER_W, -- 1437
		h = SOLDIER_H, -- 1437
		onGround = y <= 0, -- 1437
		facing = 1, -- 1437
		crouch = false, -- 1437
		rollT = 0, -- 1437
		covered = false, -- 1437
		alive = true -- 1437
	} -- 1437
	self.partner = { -- 1439
		x = x + 60, -- 1440
		y = y, -- 1440
		depth = depth, -- 1440
		depthSpeed = 0, -- 1440
		vx = 0, -- 1440
		vy = 0, -- 1440
		w = CHILD_W, -- 1441
		h = CHILD_H, -- 1441
		onGround = y <= 0, -- 1441
		facing = 1, -- 1441
		crouch = false, -- 1441
		rollT = 0, -- 1441
		covered = false, -- 1441
		alive = true -- 1441
	} -- 1441
	self.cam.x = x -- 1443
	self.cam.y = y + CAM_LOOK_UP -- 1444
	self.phase = "run" -- 1445
	self.hp = self.maxHp -- 1446
	local trial = self.run.trial -- 1447
	if trial ~= nil then -- 1448
		draftRoom(trial, wr.key) -- 1449
		self.maxHp = self.maxHp + trial.ranks.vitality -- 1450
		self.hp = trial.hp -- 1451
	elseif self:isEscortRoom() and self.run.story.route == "soldier" then -- 1452
		if self.run.story.talents == nil then -- 1454
			self.run.story.talents = createStoryTalents(self.run.seed) -- 1455
		end -- 1455
		draftTalentOffers(self.run.story.talents, wr.key) -- 1457
	end -- 1457
	self:buildEnemies() -- 1459
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1460
	local i = 0 -- 1461
	do -- 1461
		i = 0 -- 1462
		while i < #self.boxes do -- 1462
			do -- 1462
				local b = self.boxes[i + 1] -- 1463
				if b.id == nil then -- 1464
					goto __continue145 -- 1465
				end -- 1465
				local st = self.run.props[b.id] -- 1467
				if st ~= nil then -- 1468
					b.broken = st.broken -- 1469
					local ____temp_23 -- 1470
					if b.breakable == nil then -- 1470
						____temp_23 = nil -- 1470
					else -- 1470
						____temp_23 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1470
					end -- 1470
					b.breakable = ____temp_23 -- 1470
					b.hidden = b.hidden == true and st.revealed ~= true -- 1471
					if b.hidden then -- 1472
						b.broken = true -- 1473
					end -- 1473
				elseif b.hidden == true then -- 1475
					b.broken = true -- 1477
				end -- 1477
			end -- 1477
			::__continue145:: -- 1477
			i = i + 1 -- 1462
		end -- 1462
	end -- 1462
	if wr.cart.bodyW > 0 then -- 1480
		self.cartAxle = wr.cart.startX -- 1481
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1482
			self.cartAxle = wr.cart.endX -- 1483
			self.cartDocked = true -- 1484
		end -- 1484
	end -- 1484
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1487
end -- 1407
function Play.prototype.log(self, line) -- 1490
	local ____self_run_log_24 = self.run.log -- 1491
	____self_run_log_24[#____self_run_log_24 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1491
	if #self.run.log > 120 then -- 1492
		table.remove(self.run.log, 1) -- 1493
	end -- 1493
end -- 1490
function Play.prototype.buildEnemies(self) -- 1497
	self.enemies = {} -- 1498
	if self.isCampaign then -- 1499
		local i = 0 -- 1500
		do -- 1500
			i = 0 -- 1501
			while i < #self.room.spawns do -- 1501
				local sp = self.room.spawns[i + 1] -- 1502
				local kind = sp.kind or "gunner" -- 1503
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1504
				local ____self_enemies_25 = self.enemies -- 1505
				____self_enemies_25[#____self_enemies_25 + 1] = { -- 1505
					x = sp.x, -- 1506
					y = sp.y, -- 1506
					depth = sp.depth, -- 1506
					w = 26, -- 1506
					h = sp.h, -- 1506
					alive = true, -- 1506
					hitT = 0, -- 1506
					warnT = 0, -- 1506
					fireCd = 40, -- 1506
					kind = kind, -- 1507
					shieldHp = hp, -- 1507
					shieldHpMax = hp, -- 1507
					drop = sp.drop or "none", -- 1507
					homeX = sp.x, -- 1508
					swingT = 0, -- 1508
					awake = false, -- 1508
					squad = i -- 1508
				} -- 1508
				i = i + 1 -- 1501
			end -- 1501
		end -- 1501
		return -- 1511
	end -- 1511
	if self.room.key == "checkpoint" then -- 1513
		local ____self_enemies_26 = self.enemies -- 1514
		____self_enemies_26[#____self_enemies_26 + 1] = { -- 1514
			x = self.ox + 430, -- 1514
			y = 0, -- 1514
			w = 26, -- 1514
			h = 84, -- 1514
			alive = true, -- 1514
			hitT = 0, -- 1514
			warnT = 0, -- 1514
			fireCd = 0 -- 1514
		} -- 1514
		local ____self_enemies_27 = self.enemies -- 1515
		____self_enemies_27[#____self_enemies_27 + 1] = { -- 1515
			x = self.ox + 505, -- 1515
			y = 0, -- 1515
			w = 26, -- 1515
			h = 84, -- 1515
			alive = true, -- 1515
			hitT = 0, -- 1515
			warnT = 0, -- 1515
			fireCd = 0 -- 1515
		} -- 1515
		return -- 1516
	end -- 1516
	if self.room.key == "street" then -- 1518
		local ____self_enemies_28 = self.enemies -- 1520
		____self_enemies_28[#____self_enemies_28 + 1] = { -- 1520
			x = self.ox + 340, -- 1520
			y = 0, -- 1520
			w = 26, -- 1520
			h = 84, -- 1520
			alive = true, -- 1520
			hitT = 0, -- 1520
			warnT = 0, -- 1520
			fireCd = 0 -- 1520
		} -- 1520
		local ____self_enemies_29 = self.enemies -- 1521
		____self_enemies_29[#____self_enemies_29 + 1] = { -- 1521
			x = self.ox + 560, -- 1521
			y = 0, -- 1521
			w = 26, -- 1521
			h = 84, -- 1521
			alive = true, -- 1521
			hitT = 0, -- 1521
			warnT = 0, -- 1521
			fireCd = 0 -- 1521
		} -- 1521
	end -- 1521
end -- 1497
function Play.prototype.emit(self, name, data) -- 1527
	local ____self_events_30 = self.events -- 1528
	____self_events_30[#____self_events_30 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1528
	self.eventSeq = self.eventSeq + 1 -- 1529
	if #self.events > 256 then -- 1530
		table.remove(self.events, 1) -- 1531
	end -- 1531
end -- 1527
function Play.prototype.drainEvents(self) -- 1539
	local out = self.events -- 1540
	self.events = {} -- 1541
	return out -- 1542
end -- 1539
function Play.prototype.adoptEvents(self, events) -- 1551
	if #events == 0 then -- 1552
		return -- 1553
	end -- 1553
	local keep = {} -- 1555
	local i = 0 -- 1556
	do -- 1556
		i = 0 -- 1557
		while i < #events do -- 1557
			do -- 1557
				local e = events[i + 1] -- 1558
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1559
					goto __continue166 -- 1560
				end -- 1560
				keep[#keep + 1] = e -- 1562
			end -- 1562
			::__continue166:: -- 1562
			i = i + 1 -- 1557
		end -- 1557
	end -- 1557
	if #keep == 0 then -- 1564
		return -- 1565
	end -- 1565
	self.events = __TS__ArrayConcat(keep, self.events) -- 1567
	do -- 1567
		i = 0 -- 1568
		while i < #self.events do -- 1568
			self.events[i + 1].seq = i -- 1569
			i = i + 1 -- 1568
		end -- 1568
	end -- 1568
	self.eventSeq = #self.events -- 1571
end -- 1551
function Play.prototype.talentRank(self, talent) -- 1574
	if self.run.trial ~= nil then -- 1575
		return self.run.trial.ranks[talent] -- 1576
	end -- 1576
	if self.storyRoute == "soldier" and self:isEscortRoom() and self.run.story.talents ~= nil then -- 1578
		return self.run.story.talents.ranks[talent] -- 1579
	end -- 1579
	return 0 -- 1581
end -- 1574
function Play.prototype.getStoryTalentOffers(self) -- 1585
	if self.run.trial ~= nil or self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1586
		return {} -- 1587
	end -- 1587
	local st = self.run.story.talents -- 1589
	return st ~= nil and st.room == self.room.key and st.offers or ({}) -- 1590
end -- 1585
function Play.prototype.getStoryTalentRanks(self) -- 1594
	if self.run.trial ~= nil or self.storyRoute ~= "soldier" or not self:isEscortRoom() then -- 1595
		return nil -- 1596
	end -- 1596
	return self.run.story.talents ~= nil and self.run.story.talents.ranks or nil -- 1598
end -- 1594
function Play.prototype.chooseTalent(self, slot) -- 1601
	local trial = self.run.trial -- 1602
	if trial ~= nil then -- 1603
		local talent = trial.offers[slot + 1] -- 1604
		if talent == nil or trial.lost or self.run.finished then -- 1605
			return false -- 1605
		end -- 1605
		local ____trial_ranks_31, ____talent_32 = trial.ranks, talent -- 1606
		____trial_ranks_31[____talent_32] = ____trial_ranks_31[____talent_32] + 1 -- 1606
		trial.offers = {} -- 1607
		if talent == "vitality" then -- 1608
			self.maxHp = self.maxHp + 1 -- 1609
			self.hp = self.hp + 1 -- 1610
			trial.hp = self.hp -- 1611
		end -- 1611
		self:flashSet(talentNames[talent], 1.2) -- 1613
		return true -- 1614
	end -- 1614
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1616
		return false -- 1617
	end -- 1617
	local st = self.run.story.talents -- 1619
	local talent = st ~= nil and st.offers[slot + 1] or nil -- 1620
	if st == nil or talent == nil then -- 1621
		return false -- 1622
	end -- 1622
	local ____st_ranks_33, ____talent_34 = st.ranks, talent -- 1624
	____st_ranks_33[____talent_34] = ____st_ranks_33[____talent_34] + 1 -- 1624
	st.offers = {} -- 1625
	if talent == "vitality" then -- 1626
		self.maxHp = self.maxHp + 1 -- 1627
		self.hp = self.hp + 1 -- 1628
		self.run.story.maxHp = self.maxHp -- 1629
		self.run.story.hp = self.hp -- 1630
	end -- 1630
	self.sessionDirty = true -- 1632
	self:flashSet("本领 · " .. talentNames[talent], 1.4) -- 1633
	self:emit("storyBeat", {beat = "talent_picked", talent = talent, rank = st.ranks[talent], room = self.room.key}) -- 1634
	return true -- 1635
end -- 1601
function Play.prototype.beginReload(self) -- 1643
	self.reloadT = self:reloadTicks() -- 1644
	local camp = self.room.campaign -- 1645
	if self.run.trial == nil and camp ~= nil and camp.reloadPuzzle == true then -- 1647
		self:openReloadPuzzle() -- 1648
	end -- 1648
end -- 1643
function Play.prototype.openReloadPuzzle(self) -- 1653
	self.reloadOpen = true -- 1654
	self.reloadAnswerTicks = 0 -- 1655
	self.reloadWorldTicks = 0 -- 1656
	self.reloadPath = {RELOAD_START} -- 1657
	self.reloadPendingEffect = "" -- 1658
	self.reloadTryCount = self.reloadTryCount + 1 -- 1659
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 1660
end -- 1653
function Play.prototype.closeReloadPuzzle(self) -- 1664
	self.reloadOpen = false -- 1665
	self.reloadAnswerTicks = 0 -- 1666
	self.reloadWorldTicks = 0 -- 1667
	self.reloadPath = {RELOAD_START} -- 1668
	self.reloadPendingEffect = "" -- 1669
end -- 1664
function Play.prototype.reloadTapNode(self, node) -- 1676
	if not self.reloadOpen then -- 1677
		return -- 1678
	end -- 1678
	local path = self.reloadPath -- 1680
	local last = path[#path] -- 1681
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1682
		self.reloadPath = {RELOAD_START} -- 1683
		self:emit("reloadInvalid", {node = node, at = last}) -- 1684
		return -- 1685
	end -- 1685
	path[#path + 1] = node -- 1687
	if node ~= RELOAD_TARGET then -- 1688
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1689
		return -- 1690
	end -- 1690
	if not reloadPathValid(path) then -- 1692
		self.reloadPath = {RELOAD_START} -- 1693
		self:emit("reloadInvalid", {node = node, at = last}) -- 1694
		return -- 1695
	end -- 1695
	self.reloadPendingEffect = reloadEffectOf(path) -- 1697
	self.reloadOpen = false -- 1698
	self.reloadT = 0 -- 1699
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1700
	self:flashSet( -- 1703
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1703
		1.4 -- 1703
	) -- 1703
end -- 1676
function Play.prototype.consumeReloadEffect(self) -- 1707
	local e = self.reloadPendingEffect -- 1708
	if e ~= "" then -- 1709
		self.reloadPendingEffect = "" -- 1710
	end -- 1710
	return e -- 1712
end -- 1707
function Play.prototype.echoToSource(self, from, count) -- 1719
	if count == nil then -- 1719
		count = 1 -- 1719
	end -- 1719
	local best = -1 -- 1720
	local bestD = 1000000000 -- 1721
	local i = 0 -- 1722
	local woken = {} -- 1723
	local n = 0 -- 1724
	while n < count do -- 1725
		best = -1 -- 1726
		bestD = 1000000000 -- 1727
		do -- 1727
			i = 0 -- 1728
			while i < #self.enemies do -- 1728
				do -- 1728
					if woken[i] == true then -- 1729
						goto __continue199 -- 1730
					end -- 1730
					local e = self.enemies[i + 1] -- 1732
					if not e.alive then -- 1733
						goto __continue199 -- 1734
					end -- 1734
					local d = math.abs(e.x - from.x) -- 1736
					if d < bestD then -- 1737
						bestD = d -- 1738
						best = i -- 1739
					end -- 1739
				end -- 1739
				::__continue199:: -- 1739
				i = i + 1 -- 1728
			end -- 1728
		end -- 1728
		if best < 0 then -- 1742
			break -- 1743
		end -- 1743
		woken[best] = true -- 1745
		local e = self.enemies[best + 1] -- 1746
		e.awake = true -- 1747
		e.warnT = 0 -- 1748
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1749
		n = n + 1 -- 1750
	end -- 1750
	if n == 0 then -- 1752
		return -- 1753
	end -- 1753
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1755
end -- 1719
function Play.prototype.reloadTicks(self) -- 1758
	return math.max( -- 1759
		6, -- 1759
		(self.run.inventory.quickbelt > 0 and 36 or 54) - 6 * self:talentRank("reload") - 3 * self:talentRank("craft") -- 1759
	) -- 1759
end -- 1758
function Play.prototype.update(self, dt, input) -- 1762
	self:syncCraftBench() -- 1763
	local trial = self.run.trial -- 1764
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1765
		return -- 1765
	end -- 1765
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1766
		self:closeCraftBench() -- 1767
		return -- 1768
	end -- 1768
	if input.pause.pressed then -- 1770
		self.paused = not self.paused -- 1771
	end -- 1771
	if self.flashT > 0 then -- 1773
		self.flashT = self.flashT - dt -- 1774
		if self.flashT <= 0 then -- 1775
			self.flash = "" -- 1776
		end -- 1776
	end -- 1776
	if self.traceT > 0 then -- 1779
		self.traceT = self.traceT - dt -- 1780
		if self.traceT <= 0 then -- 1781
			self.trace = nil -- 1782
		end -- 1782
	end -- 1782
	if self.paused then -- 1785
		self:updateCamera(dt) -- 1786
		return -- 1787
	end -- 1787
	if self.craftBench.active then -- 1791
		self:updateCamera(dt) -- 1792
		return -- 1793
	end -- 1793
	if self.reloadOpen then -- 1798
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1799
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1800
			self.reloadOpen = false -- 1801
			self.reloadPendingEffect = "" -- 1802
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1803
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1804
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1805
			self:updateCamera(dt) -- 1806
			return -- 1807
		else -- 1807
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1809
		end -- 1809
	end -- 1809
	self.ticks = self.ticks + 1 -- 1813
	if self.invulnT > 0 then -- 1816
		self.invulnT = self.invulnT - 1 -- 1817
	end -- 1817
	if self.isCampaign then -- 1819
		local ____self_run_35, ____ticks_36 = self.run, "ticks" -- 1820
		____self_run_35[____ticks_36] = ____self_run_35[____ticks_36] + 1 -- 1820
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1821
	end -- 1821
	local p = self.player -- 1823
	self:stepPlayer(p, dt, input) -- 1824
	self:refreshCover(p, input) -- 1826
	if self.carryOn then -- 1827
		self:carryPose() -- 1828
	end -- 1828
	if self.isCampaign then -- 1830
		self:stepCampaign(dt, input) -- 1831
		if not self.carryOn then -- 1832
			self:stepCampaignPartner(dt) -- 1833
		end -- 1833
	end -- 1833
	if trial == nil or not self.run.finished then -- 1840
		self:stepEnemies(dt, input) -- 1841
	end -- 1841
	if trial ~= nil then -- 1843
		trial.hp = self.hp -- 1843
	end -- 1843
	if not self.isCampaign then -- 1844
		self:stepStory(dt, input) -- 1845
		self:stepEscort(dt, input) -- 1846
		self:stepVillage(dt, input) -- 1847
		self:stepChase(dt, input) -- 1848
		self:stepInteract(dt, input) -- 1849
	end -- 1849
	self:updateGate() -- 1851
	self:updateCamera(dt) -- 1852
	self:syncStory() -- 1854
end -- 1762
function Play.prototype.underLowArch(self, a) -- 1861
	local arch = self.room.arch -- 1862
	if arch.h <= 0 then -- 1863
		return false -- 1864
	end -- 1864
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1866
		return false -- 1867
	end -- 1867
	local top = arch.y + arch.h -- 1869
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1870
end -- 1861
function Play.prototype.coverAt(self, a) -- 1877
	local best = nil -- 1878
	local bestGap = 24 -- 1879
	local half = a.w / 2 -- 1880
	local i = 0 -- 1881
	do -- 1881
		i = 0 -- 1882
		while i < #self.boxes do -- 1882
			do -- 1882
				local b = self.boxes[i + 1] -- 1883
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1884
					goto __continue233 -- 1885
				end -- 1885
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1887
					goto __continue233 -- 1888
				end -- 1888
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1890
				if gap < bestGap then -- 1891
					bestGap = gap -- 1892
					best = b -- 1893
				end -- 1893
			end -- 1893
			::__continue233:: -- 1893
			i = i + 1 -- 1882
		end -- 1882
	end -- 1882
	return best -- 1896
end -- 1877
function Play.prototype.nearCover(self, a) -- 1899
	return self:coverAt(a) ~= nil -- 1900
end -- 1899
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1904
	if enemy == nil then -- 1905
		return false -- 1906
	end -- 1906
	local fromRight = enemy.x >= a.x -- 1908
	local edge = fromRight and b.x0 or b.x1 -- 1909
	local ____fromRight_37 -- 1910
	if fromRight then -- 1910
		____fromRight_37 = edge >= a.x - 0.001 and edge <= enemy.x -- 1910
	else -- 1910
		____fromRight_37 = edge <= a.x + 0.001 and edge >= enemy.x -- 1911
	end -- 1911
	local between = ____fromRight_37 -- 1910
	local separation = enemy.x - a.x -- 1912
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1913
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1914
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1915
end -- 1904
function Play.prototype.nearestEnemy(self, a) -- 1918
	local best -- 1919
	local bestD = 1000000000 -- 1920
	local i = 0 -- 1921
	do -- 1921
		i = 0 -- 1922
		while i < #self.enemies do -- 1922
			do -- 1922
				local e = self.enemies[i + 1] -- 1923
				if not e.alive then -- 1924
					goto __continue242 -- 1925
				end -- 1925
				local d = math.abs(e.x - a.x) -- 1927
				if d < bestD then -- 1928
					bestD = d -- 1929
					best = e -- 1930
				end -- 1930
			end -- 1930
			::__continue242:: -- 1930
			i = i + 1 -- 1922
		end -- 1922
	end -- 1922
	return best -- 1933
end -- 1918
function Play.prototype.refreshCover(self, a, input) -- 1937
	if self.childMode then -- 1938
		self.coverNear = false -- 1939
		self.coverHug = false -- 1940
		self.coverEntity = "" -- 1941
		self.coverBlocking = false -- 1942
		a.covered = false -- 1943
		return -- 1944
	end -- 1944
	local b = self:coverAt(a) -- 1946
	self.coverNear = b ~= nil -- 1947
	a.covered = self.coverNear and input.cover.held -- 1948
	self.coverHug = a.covered -- 1949
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1950
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1951
		b, -- 1951
		a, -- 1951
		self:nearestEnemy(a) -- 1951
	) -- 1951
end -- 1937
function Play.prototype.cartHandleInReach(self, a) -- 1955
	if a == nil then -- 1955
		a = self.player -- 1955
	end -- 1955
	local c = self.room.cart -- 1956
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1957
		return false -- 1958
	end -- 1958
	local handleX = self.cartAxle + c.handleOffset -- 1960
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1961
end -- 1955
function Play.prototype.nearLowLedge(self, a) -- 1966
	local reach = 26 -- 1967
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1968
	local x1 = x0 + reach -- 1969
	local i = 0 -- 1970
	do -- 1970
		i = 0 -- 1971
		while i < #self.boxes do -- 1971
			do -- 1971
				local b = self.boxes[i + 1] -- 1972
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1973
					goto __continue251 -- 1974
				end -- 1974
				local rise = b.y1 - a.y -- 1976
				if rise > 0 and rise <= LEDGE_RISE then -- 1977
					return true -- 1978
				end -- 1978
			end -- 1978
			::__continue251:: -- 1978
			i = i + 1 -- 1971
		end -- 1971
	end -- 1971
	return false -- 1981
end -- 1966
function Play.prototype.stepPlayer(self, a, dt, input) -- 1984
	a.depthSpeed = 0 -- 1985
	if not a.alive then -- 1986
		return -- 1987
	end -- 1987
	local isChild = self.childMode -- 1989
	local lowArch = isChild and self:underLowArch(a) -- 1991
	if self:storyLocked() then -- 1993
		a.vx = 0 -- 1994
		a.crouch = isChild and lowArch -- 1995
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1996
		self:fallY(a, dt) -- 1997
		return -- 1998
	end -- 1998
	if not isChild and self.escort.state == "calming" then -- 2001
		a.crouch = false -- 2002
		a.h = SOLDIER_H -- 2003
		a.vx = 0 -- 2004
		self:fallY(a, dt) -- 2005
		return -- 2006
	end -- 2006
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 2008
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 2009
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2010
	local nearCover = not isChild and self:nearCover(a) -- 2011
	a.covered = nearCover and input.cover.held -- 2012
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 2014
	if a.rollT > 0 then -- 2017
		a.rollT = a.rollT - dt -- 2018
		a.vx = a.facing * ROLL_SPEED -- 2019
		self:slideX(a, a.vx * dt) -- 2020
		self:fallY(a, dt) -- 2021
		if a.rollT <= 0 then -- 2022
			self:flashSet("翻滚结束", 0.5) -- 2023
		end -- 2023
		return -- 2025
	end -- 2025
	local peacefulRoom = self.room.key == "museum" or self.room.key == "tower" -- 2028
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 2029
		if input.moveX ~= 0 then -- 2030
			a.facing = input.moveX > 0 and 1 or -1 -- 2031
		end -- 2031
		if self:nearLowLedge(a) then -- 2034
			a.vy = SOLDIER_JUMP -- 2035
			a.onGround = false -- 2036
			self:flashSet("翻上去", 0.3) -- 2037
			return -- 2038
		end -- 2038
		a.rollT = ROLL_TIME -- 2040
		self:flashSet("翻滚", 0.3) -- 2041
		return -- 2042
	end -- 2042
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 2045
	if isChild then -- 2046
		if input.cover.held then -- 2047
			speed = CHILD_SLOW -- 2048
		end -- 2048
		if a.crouch then -- 2050
			speed = CHILD_SLOW -- 2051
		elseif self.room.key == "forest" and self.forestPath == "ditch" and a.x >= self.ox + 700 and a.x <= self.ox + 1140 then -- 2052
			speed = CHILD_SPEED * 1.22 -- 2055
		end -- 2055
	elseif a.covered then -- 2057
		speed = SOLDIER_SPEED * 0.45 -- 2058
	end -- 2058
	local handsBusy = self.gripping or gripIntent or self.reloadOpen -- 2062
	local dir = (self.gripping or self.reloadOpen) and 0 or input.moveX -- 2063
	local depthDir = self.room.depth ~= nil and not handsBusy and (not isChild or self.phase == "prologue-escape") and -input.moveY or 0 -- 2065
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 2067
	if dir ~= 0 then -- 2068
		a.facing = dir > 0 and 1 or -1 -- 2069
	end -- 2069
	a.vx = dir * speed * diagonal -- 2071
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 2074
		a.vy = CHILD_JUMP -- 2075
		a.onGround = false -- 2076
		self:flashSet("跳", 0.25) -- 2077
	end -- 2077
	local previousDepth = a.depth -- 2081
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 2082
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2083
	self:slideX(a, a.vx * dt) -- 2084
	self:fallY(a, dt) -- 2085
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and not self.reloadOpen and input.fire.pressed then -- 2088
		self:shoot(a) -- 2089
	end -- 2089
	local ____temp_40 = not isChild and not peacefulRoom and not self.gripping and not self.reloadOpen and self.reloadPendingEffect == "" and self.run.trial == nil -- 2092
	if ____temp_40 then -- 2092
		local ____opt_38 = self.room.campaign -- 2093
		____temp_40 = (____opt_38 and ____opt_38.reloadPuzzle) == true -- 2092
	end -- 2092
	if ____temp_40 and input.flare.pressed then -- 2092
		self:beginReload() -- 2094
	end -- 2094
end -- 1984
function Play.prototype.stepPartner(self, p, dt) -- 2099
	local a = self.partner -- 2100
	if not a.alive then -- 2101
		return -- 2102
	end -- 2102
	a.crouch = false -- 2104
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 2105
	a.vx = 0 -- 2106
	a.depthSpeed = 0 -- 2107
	self:fallY(a, dt) -- 2108
end -- 2099
function Play.prototype.stepEscort(self, dt, input) -- 2115
	local a = self.partner -- 2116
	a.depthSpeed = 0 -- 2117
	if not a.alive then -- 2118
		return -- 2119
	end -- 2119
	if self.room.key == "gatepath" then -- 2121
		if self.carryOn then -- 2123
			return -- 2124
		end -- 2124
		local p = self.player -- 2127
		a.depth = p.depth -- 2128
		a.facing = p.facing -- 2129
		a.crouch = false -- 2130
		a.h = CHILD_H -- 2131
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 2132
		a.y = p.y -- 2133
		a.vy = 0 -- 2134
		a.vx = p.vx -- 2135
		a.onGround = p.onGround -- 2136
		return -- 2137
	end -- 2137
	if not self:escortOn() then -- 2139
		a.vx = 0 -- 2140
		self:fallY(a, dt) -- 2141
		return -- 2142
	end -- 2142
	local p = self.player -- 2144
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 2145
	local hadKnock1 = self.escort.knock1 -- 2146
	local hadKnock2 = self.escort.knock2 -- 2147
	self.calmConsumed = self.escort:update( -- 2148
		input, -- 2148
		p.x, -- 2148
		p.facing, -- 2148
		a.x, -- 2148
		dist -- 2148
	) -- 2148
	if not hadKnock1 and self.escort.knock1 then -- 2150
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 2151
	end -- 2151
	if not hadKnock2 and self.escort.knock2 then -- 2153
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 2154
	end -- 2154
	a.crouch = self.escort.crouchPose -- 2156
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 2157
	if not self.escort.stopped then -- 2158
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 2159
		local previousDepth = a.depth -- 2160
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 2161
		local distance = math.max( -- 2162
			-travel, -- 2162
			math.min(travel, targetDepth - previousDepth) -- 2162
		) -- 2162
		self:slideDepth(a, distance) -- 2163
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2164
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 2165
			a.vy = CHILD_JUMP -- 2166
			a.onGround = false -- 2167
		end -- 2167
	end -- 2167
	local dir = self.escort:moveDir(a.x) -- 2170
	a.vx = dir * CHILD_SPEED -- 2171
	if dir ~= 0 then -- 2172
		a.facing = dir -- 2173
		local before = a.x -- 2174
		self:slideX(a, dir * CHILD_SPEED * dt) -- 2175
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 2177
			a.vy = CHILD_JUMP -- 2178
			a.onGround = false -- 2179
		end -- 2179
	end -- 2179
	self:fallY(a, dt) -- 2182
end -- 2115
function Play.prototype.escortOn(self) -- 2186
	if self.room.key == "checkpoint" then -- 2187
		return true -- 2188
	end -- 2188
	if self.room.key == "gatepath" then -- 2190
		return true -- 2191
	end -- 2191
	if self.room.key == "prologue" then -- 2193
		return self.phase == "prologue-follow" -- 2194
	end -- 2194
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 2196
		return true -- 2198
	end -- 2198
	return self.room.key == "street" -- 2200
end -- 2186
function Play.prototype.storyLocked(self) -- 2204
	if self.caughtT > 0 then -- 2205
		return true -- 2206
	end -- 2206
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 2208
		return true -- 2210
	end -- 2210
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 2212
		return true -- 2213
	end -- 2213
	if self.room.key == "gate" and (self.phase == "gate-farewell" or self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 2215
		return true -- 2216
	end -- 2216
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2218
		return true -- 2219
	end -- 2219
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2221
		return true -- 2222
	end -- 2222
	if self.craftBench.active then -- 2225
		return true -- 2226
	end -- 2226
	return false -- 2228
end -- 2204
function Play.prototype.swapToChild(self, x) -- 2232
	local tmp = self.player -- 2233
	self.player = self.partner -- 2234
	self.partner = tmp -- 2235
	self.childMode = true -- 2236
	self.player.alive = true -- 2237
	self.player.x = self.ox + x -- 2238
	self.player.y = 0 -- 2239
	self.player.depth = 0 -- 2240
	self.player.depthSpeed = 0 -- 2241
	self.player.vy = 0 -- 2242
	self.player.vx = 0 -- 2243
	self.player.onGround = true -- 2244
	self.player.crouch = false -- 2245
	self.player.h = CHILD_H -- 2246
	self.player.facing = 1 -- 2247
	self.partner.alive = true -- 2248
	self.cam.x = self.player.x -- 2249
end -- 2232
function Play.prototype.swapToSoldier(self, x, childX) -- 2253
	local tmp = self.player -- 2254
	self.player = self.partner -- 2255
	self.partner = tmp -- 2256
	self.childMode = false -- 2257
	self.player.alive = true -- 2258
	self.player.x = self.ox + x -- 2259
	self.player.y = 0 -- 2260
	self.player.depth = 0 -- 2261
	self.player.depthSpeed = 0 -- 2262
	self.player.vy = 0 -- 2263
	self.player.vx = 0 -- 2264
	self.player.onGround = true -- 2265
	self.player.crouch = false -- 2266
	self.player.h = SOLDIER_H -- 2267
	self.player.facing = 1 -- 2268
	self.partner.alive = true -- 2269
	self.partner.x = self.ox + childX -- 2270
	self.partner.y = 0 -- 2271
	self.partner.depth = 0 -- 2272
	self.partner.depthSpeed = 0 -- 2273
	self.partner.vx = 0 -- 2274
	self.partner.vy = 0 -- 2275
	self.partner.onGround = true -- 2276
	self.partner.crouch = true -- 2277
	self.partner.h = CHILD_CROUCH_H -- 2278
	self.cam.x = self.player.x -- 2279
end -- 2253
function Play.prototype.stepStory(self, dt, input) -- 2283
	if self.room.key == "prologue" then -- 2284
		self:stepPrologue(dt, input) -- 2285
	elseif self.room.key == "street" then -- 2286
		self:stepStreet(dt, input) -- 2287
	elseif self.room.key == "gate" then -- 2288
		self:stepGate(dt, input) -- 2289
	elseif self.room.key == "gatepath" then -- 2290
		self:stepGatePath() -- 2291
	elseif self.room.key == "tower" then -- 2292
		self:stepTower(dt, input) -- 2293
	elseif self.room.key == "museum" then -- 2294
		self:stepMuseum(dt, input) -- 2295
	end -- 2295
end -- 2283
function Play.prototype.canPersistProgress(self) -- 2301
	return not self.isCampaign and self.run.source == "official" -- 2302
end -- 2301
function Play.prototype.wellWindow(self) -- 2306
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 2307
end -- 2306
function Play.prototype.nearWell(self) -- 2312
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 2313
end -- 2312
function Play.prototype.pickWell(self) -- 2321
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2322
		return false -- 2323
	end -- 2323
	self.phase = "prologue-well" -- 2325
	self.phaseTick = 0 -- 2326
	self.wellOpen = false -- 2327
	self:flashSet("井沿 · 伸手下去", 1.4) -- 2328
	self:log("旧井拾取") -- 2329
	return true -- 2330
end -- 2321
function Play.prototype.stepPrologue(self, dt, input) -- 2333
	local child = self.partner -- 2334
	if self.museumReturn then -- 2335
		self.museumReturn = false -- 2337
		self.phase = "prologue-wait" -- 2338
		self.phaseTick = 0 -- 2339
		self.player.x = self.ox + 260 -- 2340
		self.player.y = 0 -- 2341
		self.player.depth = 0 -- 2342
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2343
	end -- 2343
	if self.phase == "prologue-wake" then -- 2346
		self.introTick = self.introTick + 1 -- 2347
		if self.introTick == 60 then -- 2348
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2349
		end -- 2349
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2351
			self.phase = "prologue-shadow" -- 2352
			self.introTick = 0 -- 2353
			self:flashSet("门缝里两道影子", 1.2) -- 2354
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2355
		end -- 2355
		return -- 2357
	end -- 2357
	if self.phase == "prologue-shadow" then -- 2359
		self.introTick = self.introTick + 1 -- 2360
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2361
			self.phase = "prologue-escape" -- 2363
			self.introTick = 0 -- 2364
			self.escapeRemaining = self.escapeDuration -- 2365
			self.escapeRetryCount = 0 -- 2366
			self:swapToChild(100) -- 2367
			self:flashSet( -- 2368
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2368
				1.6 -- 2368
			) -- 2368
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2369
		end -- 2369
		return -- 2373
	end -- 2373
	if self.phase == "prologue-escape" then -- 2375
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2376
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2377
			self.phase = "prologue-hide" -- 2379
			self.introTick = 0 -- 2380
			self.player.vx = 0 -- 2381
			self.player.crouch = true -- 2382
			self.player.h = CHILD_CROUCH_H -- 2383
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2384
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2385
			return -- 2389
		end -- 2389
		if self.escapeRemaining <= 0 then -- 2391
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2393
			self.player.x = self.ox + 100 -- 2394
			self.player.y = 0 -- 2395
			self.player.depth = 0 -- 2396
			self.player.vx = 0 -- 2397
			self.player.vy = 0 -- 2398
			self.escapeRemaining = self.escapeDuration -- 2399
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2400
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2401
			return -- 2402
		end -- 2402
		return -- 2404
	end -- 2404
	if self.phase == "prologue-hide" then -- 2406
		self.introTick = self.introTick + 1 -- 2407
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2408
			self.phase = "prologue-wait" -- 2410
			self.phaseTick = 0 -- 2411
			self.introTick = 0 -- 2412
			self:swapToSoldier(260, 300) -- 2413
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2414
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2415
		end -- 2415
		return -- 2417
	end -- 2417
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2420
	if self.phase == "prologue-wait" then -- 2421
		child.crouch = true -- 2422
		child.h = CHILD_CROUCH_H -- 2423
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2424
			self:pickWell() -- 2425
			return -- 2426
		end -- 2426
		if not self.wellOpen and self:canPersistProgress() and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2429
			self.archive.museumPhase = "well_reflect" -- 2431
			self.archiveDirty = true -- 2432
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2433
			return -- 2434
		end -- 2434
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2436
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2438
		if near and input.interact.pressed then -- 2439
			self.phase = "prologue-give" -- 2440
			self.phaseTick = 0 -- 2441
			self:flashSet("递出针套", 1) -- 2442
		end -- 2442
		return -- 2444
	end -- 2444
	if self.phase == "prologue-well" then -- 2446
		self.phaseTick = self.phaseTick + 1 -- 2448
		if self.phaseTick == 12 then -- 2449
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2450
		elseif self.phaseTick >= 30 then -- 2451
			self.phase = "prologue-wait" -- 2452
			self.phaseTick = 0 -- 2453
			self.wellTaken = true -- 2454
			self.wellOpen = false -- 2455
			self.run.archive.artifactOwned = true -- 2456
			self.archiveDirty = true -- 2457
			self:emit("artifactFound", { -- 2458
				x = self.ox + self.wellX, -- 2459
				y = 0, -- 2459
				room = "prologue", -- 2459
				once = true, -- 2459
				source = self.run.source -- 2460
			}) -- 2460
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2462
			self:log("井底取到时间穿梭器") -- 2463
		end -- 2463
		return -- 2465
	end -- 2465
	if self.phase == "prologue-give" then -- 2467
		self.phaseTick = self.phaseTick + 1 -- 2468
		if self.phaseTick == 36 then -- 2469
			self:flashSet("针套递过去", 0.9) -- 2470
		elseif self.phaseTick == 108 then -- 2471
			self:flashSet("纸条塞进针套", 1) -- 2472
		elseif self.phaseTick >= ____exports.PROLOGUE_GIVE_TICKS then -- 2473
			self.phase = "prologue-follow" -- 2474
			self.phaseTick = 0 -- 2475
			child.crouch = false -- 2476
			child.h = CHILD_H -- 2477
			self:flashSet("她跟上了", 1.2) -- 2478
		end -- 2478
		return -- 2480
	end -- 2480
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2483
		local next = self.run.source == "debug" and "street" or "s1-crossroad" -- 2484
		self:requestRoom(next, "序章跟到门口") -- 2485
		self:flashSet(next == "s1-crossroad" and "进十字街" or "进街道", 1.2) -- 2486
	end -- 2486
end -- 2333
function Play.prototype.stepStreet(self, dt, input) -- 2491
	local p = self.player -- 2492
	local c = self.partner -- 2493
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2494
		local next = self.run.source == "debug" and "checkpoint" or "s1-crossroad" -- 2495
		self:requestRoom(next, "两人都到街尾") -- 2496
		self:flashSet(next == "s1-crossroad" and "进十字街" or "到检查站", 1.2) -- 2497
	end -- 2497
end -- 2491
function Play.prototype.stepGate(self, dt, input) -- 2502
	local ____temp_41 -- 2503
	if self.room.story == nil then -- 2503
		____temp_41 = nil -- 2503
	else -- 2503
		____temp_41 = self.room.story.gate -- 2503
	end -- 2503
	local g = ____temp_41 -- 2503
	if g == nil then -- 2504
		return -- 2505
	end -- 2505
	local p = self.player -- 2507
	if self.phase == "gate-idle" then -- 2508
		local a = self.partner -- 2510
		local gap = g.waitX - a.x -- 2511
		if math.abs(gap) > 3 then -- 2512
			a.facing = gap > 0 and 1 or -1 -- 2513
			a.vx = a.facing * CHILD_SPEED -- 2514
			local beforeX = a.x -- 2515
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2516
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2517
				a.vy = CHILD_JUMP -- 2518
				a.onGround = false -- 2519
			end -- 2519
			self:fallY(a, dt) -- 2521
		else -- 2521
			a.vx = 0 -- 2523
			a.x = g.waitX -- 2524
		end -- 2524
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2527
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2528
		if self.gateNeedConfirm then -- 2529
			if not input.interact.held then -- 2532
				self.gateRestartArmed = true -- 2533
			end -- 2533
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2535
				self.gateNeedConfirm = false -- 2536
				self.gateRestartArmed = true -- 2537
				self.phase = "gate-hold" -- 2538
				self.gateTick = 0 -- 2539
				self.gateSpawned = 0 -- 2540
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2541
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2542
			end -- 2542
			return -- 2544
		end -- 2544
		if atWinch and atWait then -- 2546
			self.phase = "gate-hold" -- 2547
			self.gateTick = 0 -- 2548
			self.gateSpawned = 0 -- 2549
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2550
		end -- 2550
		return -- 2552
	end -- 2552
	if self.phase == "gate-hold" then -- 2554
		self.gateTick = self.gateTick + 1 -- 2555
		local marks = {0, 540, 900, 1500} -- 2557
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2558
			local idx = self.gateSpawned -- 2559
			local ____self_enemies_42 = self.enemies -- 2560
			____self_enemies_42[#____self_enemies_42 + 1] = { -- 2560
				x = self.ox + 620 + idx * 62, -- 2561
				y = 0, -- 2561
				w = 26, -- 2561
				h = 84, -- 2561
				alive = true, -- 2562
				hitT = 0, -- 2562
				warnT = 0, -- 2562
				fireCd = 90 + idx * 45 -- 2562
			} -- 2562
			self.gateSpawned = self.gateSpawned + 1 -- 2564
			self:flashSet( -- 2565
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2565
				0.9 -- 2565
			) -- 2565
		end -- 2565
		if self.gateTick == 900 then -- 2567
			self:flashSet("棚布落下", 1) -- 2568
		elseif self.gateTick == 2100 then -- 2569
			self:flashSet("门底透进冷光了", 1) -- 2570
		end -- 2570
		if self.gateTick >= g.holdTicks then -- 2572
			self:captureGateBlood() -- 2575
			self.phase = "gate-send" -- 2576
			self.phaseTick = 0 -- 2577
			self.enemies = {} -- 2579
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2580
		end -- 2580
		return -- 2582
	end -- 2582
	if self.phase == "gate-send" then -- 2584
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2585
		if near and input.interact.pressed then -- 2586
			self:commitRoute() -- 2589
			self:swapToChild(g.doorX + 30) -- 2590
			self.phase = self.run.source == "debug" and "gate-count" or "gate-farewell" -- 2591
			self.phaseTick = 0 -- 2592
			self.countTick = 0 -- 2593
			self.countArmed = false -- 2595
			self.countPrevMove = input.moveX -- 2596
			self:flashSet("门开了 · 送她出去", 1.8) -- 2597
		end -- 2597
		return -- 2599
	end -- 2599
	if self.phase == "gate-farewell" then -- 2601
		self.phaseTick = self.phaseTick + 1 -- 2602
		self.countPrevMove = input.moveX -- 2603
		if self.phaseTick >= ____exports.GATE_FAREWELL_TICKS then -- 2604
			self.phase = "gate-count" -- 2605
			self.phaseTick = 0 -- 2606
			self.countTick = 0 -- 2607
			self.countArmed = false -- 2608
		end -- 2608
		return -- 2610
	end -- 2610
	if self.phase == "gate-count" then -- 2612
		self.countTick = self.countTick + 1 -- 2613
		if self.countTick == 360 then -- 2614
			self:flashSet("门关上", 0.9) -- 2615
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2616
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2617
			if self.storyRoute == "soldier" then -- 2621
				self.phase = "gate-wait" -- 2623
				self.phaseTick = 0 -- 2624
				self.knocks = 1 -- 2625
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2626
				self.handArmed = not input.interact.held and not self.intentGateReunionHold -- 2628
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2629
			else -- 2629
				self:flashSet("数到二十", 2.2) -- 2631
			end -- 2631
		end -- 2631
		local prevMove = self.countPrevMove -- 2636
		self.countPrevMove = input.moveX -- 2637
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2638
			if prevMove <= 0 and input.moveX > 0 then -- 2639
				self.countArmed = true -- 2640
			end -- 2640
			if self.countArmed and input.moveX > 0 then -- 2642
				self.phase = "gate-walk" -- 2643
				self.phaseTick = 0 -- 2644
				self:flashSet("她迈出第一步", 1.4) -- 2645
				self:emit("storyExit", { -- 2646
					route = "child", -- 2646
					via = "walk", -- 2646
					countTick = self.countTick, -- 2646
					hp = self.hp, -- 2646
					maxHp = self.maxHp -- 2646
				}) -- 2646
			end -- 2646
		end -- 2646
		return -- 2649
	end -- 2649
	if self.phase == "gate-wait" then -- 2651
		self.phaseTick = self.phaseTick + 1 -- 2653
		if self.phaseTick == 12 then -- 2654
			self.knocks = 2 -- 2655
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2656
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2657
		end -- 2657
		local held = input.interact.held or self.intentGateReunionHold -- 2659
		if not held then -- 2660
			if self.handTicks > 0 then -- 2661
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2662
			end -- 2662
			self.handTicks = 0 -- 2664
			self.handArmed = true -- 2665
			return -- 2666
		end -- 2666
		if self.handArmed then -- 2668
			self.handTicks = self.handTicks + 1 -- 2669
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2670
				self.intentGateReunionHold = false -- 2671
				self.phase = "gate-hand" -- 2672
				self.phaseTick = 0 -- 2673
				self.handDone = true -- 2674
				self.tied = true -- 2675
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2676
				if not self.lineSaid then -- 2677
					self.lineSaid = true -- 2678
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2679
				end -- 2679
				self:flashSet("我们走吧。", 3) -- 2681
			end -- 2681
		end -- 2681
		return -- 2684
	end -- 2684
	if self.phase == "gate-hand" then -- 2686
		self.phaseTick = self.phaseTick + 1 -- 2688
		if self.phaseTick == 30 then -- 2689
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2690
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2691
			self:emit("storyExit", { -- 2692
				route = "soldier", -- 2692
				via = "hand", -- 2692
				handTicks = self.handTicks, -- 2692
				hp = self.hp, -- 2692
				maxHp = self.maxHp -- 2692
			}) -- 2692
			self:requestRoom("gatepath", "牵手同行") -- 2693
		end -- 2693
		return -- 2695
	end -- 2695
	if self.phase == "gate-walk" then -- 2698
		if self.player.x >= g.exitX then -- 2699
			self:requestRoom("outside", "走出城门") -- 2700
			self:flashSet("出城门 · 城外", 1.4) -- 2701
		end -- 2701
	end -- 2701
end -- 2502
function Play.prototype.captureGateBlood(self) -- 2710
	self.hpAtGate = self.hp -- 2711
	self.maxHpAtGate = self.maxHp -- 2712
end -- 2710
function Play.prototype.commitRoute(self) -- 2719
	if self.storySettled then -- 2720
		return -- 2721
	end -- 2721
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2723
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2724
	self.hpAtGate = hp -- 2725
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2726
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2727
	self.storySettled = true -- 2728
	self.sessionDirty = true -- 2729
	self:emit("storyRouteLocked", { -- 2730
		route = self.storyRoute, -- 2731
		hp = self.hp, -- 2731
		maxHp = self.maxHp, -- 2731
		hpAtGate = self.hpAtGate, -- 2732
		maxHpAtGate = self.maxHpAtGate -- 2732
	}) -- 2732
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2734
end -- 2719
function Play.prototype.syncStory(self) -- 2738
	if self.isCampaign and self.run.trial ~= nil then -- 2739
		return -- 2740
	end -- 2740
	local s = self.run.story -- 2742
	if s == nil then -- 2743
		return -- 2744
	end -- 2744
	s.hp = self.hp -- 2746
	s.maxHp = self.maxHp -- 2747
	s.route = self.storyRoute -- 2748
	s.settled = self.storySettled -- 2749
	s.hpAtGate = self.hpAtGate -- 2750
	s.maxHpAtGate = self.maxHpAtGate -- 2751
	s.handDone = self.handDone -- 2752
	s.lineSaid = self.lineSaid -- 2753
	s.tied = self.tied -- 2754
	s.carry = self.carryOn -- 2755
	s.museumReturn = self.museumReturn -- 2756
	s.escortDone = self.escortDone -- 2757
	s.craftedWeapon = self.run.story.craftedWeapon -- 2758
	s.equippedWeapon = self.equippedWeapon -- 2759
	s.ending = self.run.story.ending -- 2760
	if self.room.key == "gate" then -- 2761
		s.phase = self.phase -- 2762
		s.countTick = self.countTick -- 2763
		s.phaseTick = self.phaseTick -- 2764
		s.handTicks = self.handTicks -- 2765
	end -- 2765
	if self.room.key == "prologue" then -- 2767
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2769
			s.phase = self.phase -- 2770
			s.phaseTick = self.phaseTick -- 2771
		end -- 2771
	end -- 2771
	if self.room.key == "tower" then -- 2774
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2776
			s.phase = self.phase -- 2777
			s.phaseTick = self.phaseTick -- 2778
		end -- 2778
	end -- 2778
end -- 2738
function Play.prototype.stepGatePath(self) -- 2784
	local ____temp_43 -- 2785
	if self.room.story == nil then -- 2785
		____temp_43 = nil -- 2785
	else -- 2785
		____temp_43 = self.room.story.gatepath -- 2785
	end -- 2785
	local gp = ____temp_43 -- 2785
	if self.phase == "gatepath-start" then -- 2786
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2787
			self.carryOn = true -- 2788
			self.phase = "gatepath-carry" -- 2789
			self.phaseTick = 0 -- 2790
			self.pathDone = true -- 2791
			self.escortDone = false -- 2792
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2793
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2794
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2795
		end -- 2795
		return -- 2797
	end -- 2797
	if self.phase == "gatepath-carry" then -- 2799
		self.phaseTick = self.phaseTick + 1 -- 2800
		if self.phaseTick == 20 then -- 2801
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2802
		end -- 2802
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2804
			self:requestRoom(gp.next, "背负进首战") -- 2805
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2806
		end -- 2806
	end -- 2806
end -- 2784
function Play.prototype.carryPose(self) -- 2815
	local p = self.player -- 2816
	local a = self.partner -- 2817
	a.alive = true -- 2818
	a.x = p.x - p.facing * 12 -- 2819
	a.y = p.y + 26 -- 2820
	a.depth = p.depth -- 2821
	a.vx = p.vx -- 2822
	a.vy = 0 -- 2823
	a.onGround = true -- 2824
	a.crouch = false -- 2825
	a.h = CHILD_CROUCH_H -- 2826
	a.facing = p.facing -- 2827
end -- 2815
function Play.prototype.stepMuseum(self, dt, input) -- 2835
	self.partner.alive = false -- 2836
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2837
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2840
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 2841
	local intentTarget = self.pendingMuseumIntentTarget -- 2842
	self.pendingMuseumIntentTarget = "" -- 2843
	local interactHit = input.interact.pressed or intentTarget ~= "" -- 2844
	if self.phase == "museum-cabinet" then -- 2845
		if atCase and interactHit or intentTarget == "cabinet" then -- 2846
			self.phase = "museum-hall" -- 2847
			self.phaseTick = 0 -- 2848
			if self:canPersistProgress() then -- 2849
				self.archive.museumPhase = "hall_walk" -- 2850
				self.archiveDirty = true -- 2851
			end -- 2851
			self:emit( -- 2853
				"museumStep", -- 2853
				{ -- 2853
					step = "cabinet", -- 2853
					x = self.ox + mu.cabinetX, -- 2853
					persisted = self:canPersistProgress() -- 2853
				} -- 2853
			) -- 2853
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2854
		end -- 2854
		return -- 2856
	end -- 2856
	if self.phase == "museum-hall" then -- 2858
		if intentTarget == "lamp_direct" and nearLamp then -- 2859
			self:emit( -- 2860
				"museumStep", -- 2860
				{ -- 2860
					step = "hall", -- 2860
					x = self.ox + mu.hallX, -- 2860
					persisted = self:canPersistProgress() -- 2860
				} -- 2860
			) -- 2860
			self.phase = "museum-return" -- 2861
			self.phaseTick = 0 -- 2862
			if self:canPersistProgress() then -- 2863
				self.archive.museumPhase = "return_cabinet" -- 2864
				self.archiveDirty = true -- 2865
			end -- 2865
			self:emit( -- 2867
				"museumStep", -- 2867
				{ -- 2867
					step = "lamp", -- 2867
					x = self.ox + mu.lampX, -- 2867
					persisted = self:canPersistProgress() -- 2867
				} -- 2867
			) -- 2867
			self:flashSet("灯 · 转向西窗", 1.8) -- 2868
			return -- 2869
		end -- 2869
		if self.player.x >= self.ox + mu.hallX and interactHit then -- 2871
			self.phase = "museum-lamp" -- 2872
			self.phaseTick = 0 -- 2873
			if self:canPersistProgress() then -- 2874
				self.archive.museumPhase = "lamp_turn" -- 2875
				self.archiveDirty = true -- 2876
			end -- 2876
			self:emit( -- 2878
				"museumStep", -- 2878
				{ -- 2878
					step = "hall", -- 2878
					x = self.ox + mu.hallX, -- 2878
					persisted = self:canPersistProgress() -- 2878
				} -- 2878
			) -- 2878
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2879
		end -- 2879
		return -- 2881
	end -- 2881
	if self.phase == "museum-lamp" then -- 2883
		if nearLamp and interactHit then -- 2884
			self.phase = "museum-return" -- 2885
			self.phaseTick = 0 -- 2886
			if self:canPersistProgress() then -- 2887
				self.archive.museumPhase = "return_cabinet" -- 2888
				self.archiveDirty = true -- 2889
			end -- 2889
			self:emit( -- 2891
				"museumStep", -- 2891
				{ -- 2891
					step = "lamp", -- 2891
					x = self.ox + mu.lampX, -- 2891
					persisted = self:canPersistProgress() -- 2891
				} -- 2891
			) -- 2891
			self:flashSet("灯 · 转向西窗", 1.8) -- 2892
		end -- 2892
		return -- 2894
	end -- 2894
	if self.phase == "museum-return" then -- 2896
		if atCase and interactHit or intentTarget == "return_cabinet" then -- 2897
			self.phase = "museum-knock" -- 2898
			self.phaseTick = 0 -- 2899
			self:emit( -- 2900
				"museumStep", -- 2900
				{ -- 2900
					step = "knock", -- 2900
					count = 1, -- 2900
					x = self.ox + mu.cabinetX, -- 2900
					persisted = self:canPersistProgress() -- 2900
				} -- 2900
			) -- 2900
			self:flashSet("回柜边 · 第一下", 0.8) -- 2901
		end -- 2901
		return -- 2903
	end -- 2903
	if self.phase == "museum-knock" then -- 2905
		self.phaseTick = self.phaseTick + 1 -- 2906
		if self.phaseTick == 8 then -- 2907
			self:emit( -- 2908
				"museumStep", -- 2908
				{ -- 2908
					step = "knock", -- 2908
					count = 2, -- 2908
					x = self.ox + mu.cabinetX, -- 2908
					persisted = self:canPersistProgress() -- 2908
				} -- 2908
			) -- 2908
			self:flashSet("回柜边 · 第二下", 0.8) -- 2909
		elseif self.phaseTick >= 36 then -- 2910
			self.phase = "museum-done" -- 2911
			self.phaseTick = 0 -- 2912
			if self:canPersistProgress() then -- 2913
				self.archive.museumSeen = true -- 2914
				self.archive.museumPhase = "done" -- 2915
				self.archiveDirty = true -- 2916
			end -- 2916
			self:emit( -- 2918
				"museumDone", -- 2918
				{ -- 2918
					steps = 4, -- 2918
					museumSeen = self.archive.museumSeen, -- 2918
					persisted = self:canPersistProgress() -- 2918
				} -- 2918
			) -- 2918
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2919
			self:log("博物馆 · 回柜边") -- 2920
		end -- 2920
		return -- 2922
	end -- 2922
	if interactHit then -- 2924
		self.museumReturn = true -- 2925
		self:requestRoom("prologue", "回柜边") -- 2926
	end -- 2926
end -- 2835
function Play.prototype.openTowerDoor(self) -- 2930
	self.towerDoorOpen = true -- 2931
	do -- 2931
		local i = 0 -- 2932
		while i < #self.boxes do -- 2932
			if self.boxes[i + 1].id == "tower_door" then -- 2933
				self.boxes[i + 1].hidden = true -- 2934
			end -- 2934
			i = i + 1 -- 2932
		end -- 2932
	end -- 2932
	self.run.story.segments.tower_door = true -- 2937
end -- 2930
function Play.prototype.stepTower(self, dt, input) -- 2940
	local ____temp_44 -- 2941
	if self.room.story == nil then -- 2941
		____temp_44 = nil -- 2941
	else -- 2941
		____temp_44 = self.room.story.tower -- 2941
	end -- 2941
	local t = ____temp_44 -- 2941
	if t == nil then -- 2942
		return -- 2943
	end -- 2943
	if self.storyRoute == "soldier" and self.partner.alive then -- 2946
		local targetX = math.max(self.ox + 408, self.player.x - 28) -- 2947
		local gap = targetX - self.partner.x -- 2948
		if math.abs(gap) > 2 then -- 2949
			local dir = gap > 0 and 1 or -1 -- 2950
			local stepDist = math.min( -- 2951
				math.abs(gap), -- 2951
				SOLDIER_SPEED * dt -- 2951
			) -- 2951
			self.partner.facing = dir -- 2952
			self.partner.vx = dir * SOLDIER_SPEED -- 2953
			local ____self_partner_45, ____x_46 = self.partner, "x" -- 2954
			____self_partner_45[____x_46] = ____self_partner_45[____x_46] + dir * stepDist -- 2954
		else -- 2954
			self.partner.vx = 0 -- 2956
			self.partner.facing = 1 -- 2957
		end -- 2957
	end -- 2957
	if self.phase == "tower-wait" then -- 2960
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2961
		if near and input.interact.pressed then -- 2962
			self.phase = "tower-knock" -- 2963
			self.phaseTick = 0 -- 2964
			self.knocks = 1 -- 2965
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2966
			self:flashSet("叩两下 · 第一声", 0.6) -- 2967
		end -- 2967
		return -- 2969
	end -- 2969
	if self.phase == "tower-knock" then -- 2971
		self.phaseTick = self.phaseTick + 1 -- 2972
		if self.phaseTick == 12 then -- 2973
			self.knocks = 2 -- 2974
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2975
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 2976
		elseif self.phaseTick >= t.knockTicks then -- 2977
			self:openTowerDoor() -- 2978
			self.phase = "tower-enter" -- 2979
			self.phaseTick = 0 -- 2980
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 2981
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 2982
		end -- 2982
		return -- 2984
	end -- 2984
	if self.phase == "tower-enter" then -- 2986
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 2987
			self.phase = "tower-desk" -- 2988
			self.phaseTick = 0 -- 2989
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 2990
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 2991
		end -- 2991
		return -- 2993
	end -- 2993
	if self.phase == "tower-desk" then -- 2995
		local deskX = self.ox + 605 -- 2996
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 2997
		if not near or not input.interact.held then -- 2998
			self.deskHold = 0 -- 2999
			return -- 3000
		end -- 3000
		self.deskHold = self.deskHold + 1 -- 3002
		if self.deskHold == 12 then -- 3003
			self:flashSet("针套 · 放在桌上", 1) -- 3004
		elseif self.deskHold == 24 then -- 3005
			self:flashSet("指南针 · 压住纸条", 1) -- 3006
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 3007
			self.towerHanded = true -- 3008
			self.deskHold = 0 -- 3009
			self.run.story.segments.tower_handover = true -- 3010
			self.phase = "tower-given" -- 3011
			self.phaseTick = 0 -- 3012
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 3013
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 3018
		end -- 3018
		return -- 3020
	end -- 3020
	if self.phase == "tower-given" then -- 3022
		local soldier = self.storyRoute == "soldier" -- 3025
		self.phaseTick = self.phaseTick + 1 -- 3026
		if self.phaseTick == 60 then -- 3027
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 3028
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 3029
		elseif self.phaseTick == 120 then -- 3030
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 3031
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 3032
			self.phase = "tower-end" -- 3033
			self.phaseTick = 0 -- 3034
			self.towerEndMustRelease = input.interact.held or input.retry.held -- 3035
			if not self.run.finished then -- 3036
				self.run.finished = true -- 3037
				local ending = soldier and "reunion" or "lamp" -- 3038
				self.run.story.ending = ending -- 3039
				local ____soldier_47 -- 3042
				if soldier then -- 3042
					____soldier_47 = self.run.story.segments.escort5 == true -- 3043
				else -- 3043
					____soldier_47 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 3044
				end -- 3044
				local played = ____soldier_47 -- 3042
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 3045
				if official then -- 3047
					if soldier then -- 3048
						self.run.archive.soldierCleared = true -- 3049
					else -- 3049
						self.run.archive.childCleared = true -- 3051
					end -- 3051
					self.archiveDirty = true -- 3053
				end -- 3053
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 3055
				self:emit("endingReached", { -- 3056
					route = soldier and "soldier" or "child", -- 3057
					ending = ending, -- 3058
					official = official, -- 3059
					source = self.run.source, -- 3060
					lines = {self.endingLines[1], self.endingLines[2]}, -- 3061
					childCleared = self.run.archive.childCleared, -- 3062
					soldierCleared = self.run.archive.soldierCleared, -- 3063
					artifactOwned = self.run.archive.artifactOwned, -- 3064
					equipped = self.equippedWeapon -- 3065
				}) -- 3065
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 3067
			end -- 3067
		end -- 3067
		return -- 3070
	end -- 3070
	self.phaseTick = self.phaseTick + 1 -- 3072
	local held = input.interact.held or input.retry.held -- 3073
	if self.towerEndMustRelease then -- 3074
		if not held then -- 3075
			self.towerEndMustRelease = false -- 3076
		end -- 3076
		return -- 3078
	end -- 3078
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 3080
	if self.phaseTick < waitTicks then -- 3081
		if input.interact.pressed or input.retry.pressed then -- 3082
			self.towerEndMustRelease = held -- 3083
		end -- 3083
		return -- 3085
	end -- 3085
	if input.interact.pressed or input.retry.pressed then -- 3087
		self.restartStory = true -- 3089
		self:requestRoom("prologue", "片尾再玩") -- 3090
		self:flashSet("回到序章", 1.4) -- 3091
	end -- 3091
end -- 2940
function Play.prototype.stepChase(self, dt, input) -- 3096
	if self.caughtT > 0 then -- 3097
		self.caughtT = self.caughtT - dt -- 3098
		if self.caughtT <= 0 then -- 3099
			self:recoverFromCaught() -- 3100
		end -- 3100
		return -- 3102
	end -- 3102
	if self.room.key == "village" then -- 3104
		self:stepScavChase() -- 3105
	elseif self.room.key == "forest" then -- 3106
		self:stepForestRoute() -- 3107
		self:stepDog(dt) -- 3108
		if self.player.x >= self.ox + 1450 then -- 3110
			self:requestRoom("tower", "到林缘北塔") -- 3111
			self:flashSet("林缘 · 北塔", 1.4) -- 3112
		end -- 3112
	end -- 3112
end -- 3096
function Play.prototype.stepScavChase(self) -- 3118
	local s = self.room.scavenger -- 3119
	if s == nil then -- 3120
		return -- 3121
	end -- 3121
	local p = self.player -- 3123
	if self.passed and p.x > self.ox + 440 then -- 3125
		if self.scavChase then -- 3126
			self.scavChase = false -- 3127
			self.scavState = "back" -- 3128
			self.scavT = 0 -- 3129
		end -- 3129
		return -- 3131
	end -- 3131
	local dx = p.x - self.scavX -- 3133
	local dist = math.abs(dx) -- 3134
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 3135
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 3136
	if not self.scavChase then -- 3137
		if visible then -- 3138
			self.scavSee = self.scavSee + 1 -- 3139
			if self.scavSee >= 24 then -- 3140
				self.scavChase = true -- 3141
				self.scavState = "chase" -- 3142
				self.scavTargetX = p.x -- 3143
				self:flashSet("他看见你了", 1.2) -- 3144
			end -- 3144
		else -- 3144
			self.scavSee = 0 -- 3147
		end -- 3147
		return -- 3149
	end -- 3149
	if hidden then -- 3152
		self.scavSee = 0 -- 3153
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 3154
		self.scavT = self.scavT - 1 -- 3155
		if self.scavT <= 0 then -- 3156
			self.scavChase = false -- 3157
			self.scavState = "patrol" -- 3158
			self:flashSet("他失去了目标", 1) -- 3159
		end -- 3159
		return -- 3161
	end -- 3161
	local dir = p.x > self.scavX and 1 or -1 -- 3164
	self.scavX = self.scavX + dir * 96 / 60 -- 3165
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 3166
		self:caught() -- 3167
		return -- 3168
	end -- 3168
end -- 3118
function Play.prototype.stepDog(self, dt) -- 3173
	local ____temp_48 -- 3174
	if self.room.story == nil then -- 3174
		____temp_48 = nil -- 3174
	else -- 3174
		____temp_48 = self.room.story.dog -- 3174
	end -- 3174
	local dog = ____temp_48 -- 3174
	if dog == nil then -- 3175
		return -- 3176
	end -- 3176
	local p = self.player -- 3178
	local ox = self.ox -- 3179
	local dist = math.abs(p.x - self.dogX) -- 3180
	local inBurrowCover = p.crouch and p.x >= ox + 300 and p.x <= ox + 460 -- 3181
	local inBrushCover = p.crouch and (p.x >= ox + 700 and p.x <= ox + 790 or p.x >= ox + 1150 and p.x <= ox + 1240) -- 3182
	local sheltered = inBurrowCover or inBrushCover -- 3186
	local inDitchSprint = not p.crouch and self.forestPath == "ditch" and p.x >= ox + 700 and p.x <= ox + 1140 -- 3187
	local effectiveRange = inDitchSprint and dog.range * 1.25 or dog.range -- 3188
	local earNeedTicks = inDitchSprint and 12 or 18 -- 3189
	if self.dogState == "patrol" then -- 3190
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 3191
		if self.dogX < dog.x0 then -- 3192
			self.dogX = dog.x0 -- 3193
			self.dogDir = 1 -- 3194
		elseif self.dogX > dog.x1 then -- 3195
			self.dogX = dog.x1 -- 3196
			self.dogDir = -1 -- 3197
		end -- 3197
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 3199
		local twigOffsets = {235, 455, 865, 1115} -- 3200
		local nearTwig = false -- 3201
		local ti = 0 -- 3202
		do -- 3202
			ti = 0 -- 3203
			while ti < #twigOffsets do -- 3203
				if math.abs(p.x - (ox + twigOffsets[ti + 1])) <= 18 and p.y <= 8 then -- 3204
					nearTwig = true -- 3205
					break -- 3206
				end -- 3206
				ti = ti + 1 -- 3203
			end -- 3203
		end -- 3203
		local twigRange = nearTwig and math.max(effectiveRange, 400) or effectiveRange -- 3209
		if not sheltered and not p.crouch and moving and dist < twigRange then -- 3210
			self.dogState = "ear" -- 3211
			self.dogT = nearTwig and math.min(earNeedTicks, 12) or earNeedTicks -- 3212
			self.dogTargetX = p.x -- 3213
			self:flashSet(inDitchSprint and "旧渠枯枝响 · 狗立刻转耳" or (nearTwig and "踩断枯枝 · 狗立刻转耳" or "狗转耳朵"), 0.8) -- 3214
		end -- 3214
		return -- 3216
	end -- 3216
	if self.dogState == "ear" then -- 3218
		if sheltered then -- 3219
			self.dogState = "sniff" -- 3220
			self.dogT = 45 -- 3221
			self:flashSet("钻进遮蔽 · 狗顿住了", 0.9) -- 3222
			return -- 3223
		end -- 3223
		self.dogT = self.dogT - 1 -- 3225
		if self.dogT <= 0 then -- 3226
			self.dogState = "chase" -- 3227
			self.dogTargetX = p.x -- 3228
			self:flashSet("狗追来了", 1.4) -- 3229
		end -- 3229
		return -- 3231
	end -- 3231
	if self.dogState == "chase" then -- 3233
		local dir = p.x > self.dogX and 1 or -1 -- 3234
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 3235
		if not sheltered and math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 3236
			self:caught() -- 3237
			self.dogState = "sniff" -- 3238
			self.dogT = 60 -- 3239
		elseif dist > effectiveRange * 1.5 or sheltered then -- 3240
			self.dogState = "sniff" -- 3241
			self.dogT = 60 -- 3242
			self:flashSet(inBurrowCover and "树根窄洞遮住身形 · 狗停下了" or "狗停下了", 0.9) -- 3243
		end -- 3243
		return -- 3245
	end -- 3245
	if self.dogState == "sniff" then -- 3247
		self.dogT = self.dogT - 1 -- 3248
		if self.dogT <= 0 then -- 3249
			self.dogState = "back" -- 3250
		end -- 3250
		return -- 3252
	end -- 3252
	local dir = dog.x0 > self.dogX and 1 or -1 -- 3255
	self.dogX = self.dogX + dir * dog.speed * dt -- 3256
	if math.abs(self.dogX - dog.x0) < 2 then -- 3257
		self.dogX = dog.x0 -- 3258
		self.dogState = "patrol" -- 3259
	end -- 3259
end -- 3173
function Play.prototype.stepForestRoute(self) -- 3264
	local p = self.player -- 3265
	local ox = self.ox -- 3266
	if self.forestPath == "" then -- 3267
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 3268
			self.forestPath = "burrow" -- 3269
			self.run.story.segments.forest_burrow = true -- 3270
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 3271
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 3272
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 3273
			self.forestPath = "ditch" -- 3274
			self.run.story.segments.forest_ditch = true -- 3275
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 3276
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 3277
		end -- 3277
	end -- 3277
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 3280
		self.waterSeen = true -- 3281
		self.run.story.segments.water_lantern = true -- 3282
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 3283
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 3284
	end -- 3284
end -- 3264
function Play.prototype.caught(self) -- 3288
	self.caughtT = 1 -- 3289
	self:flashSet("被抓 · 回到安全点", 1.6) -- 3290
end -- 3288
function Play.prototype.recoverFromCaught(self) -- 3294
	local p = self.player -- 3295
	p.x = self.ox + 140 -- 3296
	p.y = 0 -- 3297
	p.vy = 0 -- 3298
	p.vx = 0 -- 3299
	p.onGround = true -- 3300
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3301
		self.scavX = self.room.scavenger.x0 -- 3302
		self.scavState = "patrol" -- 3303
		self.scavSee = 0 -- 3304
		self.scavChase = false -- 3305
		self.scavT = 0 -- 3306
	end -- 3306
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3308
		self.dogX = self.room.story.dog.x0 -- 3309
		self.dogState = "patrol" -- 3310
		self.dogT = 0 -- 3311
	end -- 3311
	self.cam.x = p.x -- 3313
	self.cam.y = p.y + CAM_LOOK_UP -- 3314
	self:flashSet("回到安全点", 1.2) -- 3315
end -- 3294
function Play.prototype.updateGate(self) -- 3319
	if self.room.key ~= "checkpoint" then -- 3320
		self.gateOpen = false -- 3321
		return -- 3322
	end -- 3322
	local function inZone(x) -- 3324
		return x >= self.ox + 792 and x <= self.ox + 928 -- 3324
	end -- 3324
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 3325
end -- 3319
function Play.prototype.addItem(self, kind) -- 3331
	local inv = self.run.inventory -- 3332
	if kind == "shield" then -- 3333
		if inv.shield >= TOOL_CAP then -- 3334
			return false -- 3335
		end -- 3335
		inv.shield = inv.shield + 1 -- 3337
		return true -- 3338
	end -- 3338
	if kind == "wedge" then -- 3340
		if inv.wedge >= CONSUMABLE_CAP then -- 3341
			return false -- 3342
		end -- 3342
		inv.wedge = inv.wedge + 1 -- 3344
		return true -- 3345
	end -- 3345
	if kind == "ammo" then -- 3347
		if inv.ammo >= CONSUMABLE_CAP then -- 3348
			return false -- 3349
		end -- 3349
		inv.ammo = inv.ammo + 1 -- 3351
		return true -- 3352
	end -- 3352
	if kind == "scrap" then -- 3354
		inv.scrap = inv.scrap + 1 -- 3356
		return true -- 3357
	end -- 3357
	if kind == "wood" then -- 3359
		inv.wood = inv.wood + 1 -- 3360
		return true -- 3361
	end -- 3361
	if kind == "bell" then -- 3363
		inv.bell = inv.bell + 1 -- 3364
		return true -- 3365
	end -- 3365
	if kind == "pass" then -- 3367
		inv.pass = inv.pass + 1 -- 3368
		return true -- 3369
	end -- 3369
	if kind == "quickbelt" then -- 3371
		inv.quickbelt = inv.quickbelt + 1 -- 3372
		return true -- 3373
	end -- 3373
	return false -- 3375
end -- 3331
function Play.prototype.findBox(self, id) -- 3378
	local i = 0 -- 3379
	do -- 3379
		i = 0 -- 3380
		while i < #self.boxes do -- 3380
			if self.boxes[i + 1].id == id then -- 3381
				return self.boxes[i + 1] -- 3382
			end -- 3382
			i = i + 1 -- 3380
		end -- 3380
	end -- 3380
	return nil -- 3385
end -- 3378
function Play.prototype.findWedgeTarget(self) -- 3389
	local best = nil -- 3390
	local bestD = 0 -- 3391
	local i = 0 -- 3392
	do -- 3392
		i = 0 -- 3393
		while i < #self.boxes do -- 3393
			do -- 3393
				local b = self.boxes[i + 1] -- 3394
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3395
					goto __continue513 -- 3396
				end -- 3396
				if not self:nearBox(b, 26) then -- 3398
					goto __continue513 -- 3399
				end -- 3399
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3401
				if best == nil or d < bestD then -- 3402
					best = b -- 3403
					bestD = d -- 3404
				end -- 3404
			end -- 3404
			::__continue513:: -- 3404
			i = i + 1 -- 3393
		end -- 3393
	end -- 3393
	return best -- 3407
end -- 3389
function Play.prototype.stepCraft(self, input) -- 3415
	local inv = self.run.inventory -- 3416
	local required = math.max( -- 3417
		6, -- 3417
		CRAFT_TICKS - 6 * self:talentRank("craft") -- 3417
	) -- 3417
	if self.craftT > 0 then -- 3418
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3419
			self.craftT = 0 -- 3421
			self:flashSet("制作中断", 0.8) -- 3422
			return true -- 3423
		end -- 3423
		self.craftT = self.craftT + 1 -- 3425
		if self.craftT >= required then -- 3426
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3427
				inv.scrap = inv.scrap - 1 -- 3428
				inv.wedge = inv.wedge + 1 -- 3429
				self:flashSet("制得木楔", 1.2) -- 3430
				self:log("制木楔") -- 3431
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3432
			end -- 3432
			self.craftT = 0 -- 3434
		end -- 3434
		return true -- 3436
	end -- 3436
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3438
		self.craftT = 1 -- 3439
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3440
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3441
		return true -- 3442
	end -- 3442
	return false -- 3444
end -- 3415
function Play.prototype.nearBox(self, b, reach) -- 3447
	local p = self.player -- 3448
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3449
end -- 3447
function Play.prototype.findInteract(self) -- 3455
	local p = self.player -- 3456
	local best = nil -- 3457
	local bestD = 1000000000 -- 3458
	local i = 0 -- 3459
	do -- 3459
		i = 0 -- 3460
		while i < #self.boxes do -- 3460
			do -- 3460
				local b = self.boxes[i + 1] -- 3461
				if b.interact == nil or b.broken == true then -- 3462
					goto __continue526 -- 3463
				end -- 3463
				if not self:nearBox(b, b.interact.reach or 27) then -- 3465
					goto __continue526 -- 3466
				end -- 3466
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3468
				if d < bestD then -- 3469
					bestD = d -- 3470
					best = b -- 3471
				end -- 3471
			end -- 3471
			::__continue526:: -- 3471
			i = i + 1 -- 3460
		end -- 3460
	end -- 3460
	return best -- 3474
end -- 3455
function Play.prototype.stepCampaign(self, dt, input) -- 3478
	local wr = self.room -- 3479
	local p = self.player -- 3480
	if self.reloadT > 0 then -- 3481
		self.reloadT = self.reloadT - 1 -- 3482
	end -- 3482
	if self.bracedShield ~= nil then -- 3485
		self.bracedShield.x = p.x + p.facing * 26 -- 3486
		self.bracedShield.y = p.y -- 3487
		local shBox = __TS__ArrayFind( -- 3488
			self.boxes, -- 3488
			function(____, b) return b.id == "braced_shield" end -- 3488
		) -- 3488
		if shBox ~= nil then -- 3489
			shBox.x0 = self.bracedShield.x - 15 -- 3490
			shBox.x1 = self.bracedShield.x + 15 -- 3491
			shBox.y0 = self.bracedShield.y -- 3492
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3493
		end -- 3493
	end -- 3493
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3497
		self.run.route = "drygoods" -- 3499
		self.run.joined = false -- 3500
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3501
		self:log("转布行线") -- 3502
	end -- 3502
	if wr.key == "escort3" then -- 3505
		local nearBench = p.x >= wr.minX + 472 and p.x <= wr.minX + 710 and p.y < 60 -- 3506
		if nearBench and input.interact.pressed then -- 3507
			self:openCraftBench() -- 3508
			return -- 3509
		end -- 3509
	end -- 3509
	local i = 0 -- 3513
	do -- 3513
		i = 0 -- 3514
		while i < #self.pickups do -- 3514
			do -- 3514
				local pk = self.pickups[i + 1] -- 3515
				if self.run.taken[pk.id] == true then -- 3516
					goto __continue539 -- 3517
				end -- 3517
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3519
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3520
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3521
					if not self:addItem(pk.kind) then -- 3522
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3524
						self:log("满包拒绝 " .. pk.kind) -- 3525
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3526
						goto __continue539 -- 3527
					end -- 3527
					self.run.taken[pk.id] = true -- 3529
					self:flashSet("拾取 " .. pk.label, 1) -- 3530
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3531
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3532
				end -- 3532
			end -- 3532
			::__continue539:: -- 3532
			i = i + 1 -- 3514
		end -- 3514
	end -- 3514
	self.calmConsumed = false -- 3536
	local ____temp_54 = self.run.trial == nil and self.partner.alive and self.run.joined -- 3537
	if ____temp_54 then -- 3537
		local ____opt_49 = self.room.campaign -- 3538
		local ____temp_53 = (____opt_49 and ____opt_49.chapter) == "S" -- 3538
		if not ____temp_53 then -- 3538
			local ____opt_51 = self.room.campaign -- 3538
			____temp_53 = (____opt_51 and ____opt_51.chapter) == "C" -- 3538
		end -- 3538
		____temp_54 = ____temp_53 -- 3537
	end -- 3537
	if ____temp_54 and (self.escort.fear > 0 or self.escort.state == "frozen" or self.escort.state == "calming") then -- 3537
		local dist = inReachDepth(p.depth, self.partner.depth) and math.abs(p.x - self.partner.x) or 1000000000 -- 3540
		local hadK1 = self.escort.knock1 -- 3541
		local hadK2 = self.escort.knock2 -- 3542
		self.calmConsumed = self.escort:update( -- 3543
			input, -- 3543
			p.x, -- 3543
			p.facing, -- 3543
			self.partner.x, -- 3543
			dist -- 3543
		) -- 3543
		if not hadK1 and self.escort.knock1 then -- 3544
			self:emit("knock", {count = 1, x = self.partner.x, room = self.room.key}) -- 3545
		end -- 3545
		if not hadK2 and self.escort.knock2 then -- 3547
			self:emit("knock", {count = 2, x = self.partner.x, room = self.room.key}) -- 3548
		end -- 3548
		self.partner.crouch = self.escort.crouchPose -- 3550
		self.partner.h = self.partner.crouch and CHILD_CROUCH_H or CHILD_H -- 3551
	end -- 3551
	if not self.calmConsumed and not self:stepCraft(input) and input.interact.pressed then -- 3553
		self:campaignInteract() -- 3554
	end -- 3554
	self:stepCampaignCart(dt, input) -- 3556
	self:stepCampaignGoal() -- 3557
	self:campaignCheckpoint() -- 3558
end -- 3478
function Play.prototype.campaignCheckpoint(self) -- 3562
	local i = 0 -- 3563
	do -- 3563
		i = 0 -- 3564
		while i < #self.room.marks do -- 3564
			do -- 3564
				local m = self.room.marks[i + 1] -- 3565
				if m.kind ~= 0 then -- 3566
					goto __continue549 -- 3567
				end -- 3567
				local dx = self.player.x - m.x -- 3569
				local dy = self.player.y - m.y -- 3570
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3571
					self.checkpoint = m.x -- 3572
					self:captureCheckpoint(m.x) -- 3573
					self:flashSet("检查点", 1) -- 3574
				end -- 3574
			end -- 3574
			::__continue549:: -- 3574
			i = i + 1 -- 3564
		end -- 3564
	end -- 3564
end -- 3562
function Play.prototype.campaignInteract(self) -- 3580
	local b = self:findInteract() -- 3581
	if b ~= nil then -- 3582
		self:useInteract(b) -- 3583
		return -- 3584
	end -- 3584
	local inv = self.run.inventory -- 3586
	if inv.wedge > 0 then -- 3587
		local w = self:findWedgeTarget() -- 3588
		if w ~= nil then -- 3589
			if w.breakable ~= nil then -- 3590
				local ____w_breakable_55, ____hp_56 = w.breakable, "hp" -- 3591
				____w_breakable_55[____hp_56] = ____w_breakable_55[____hp_56] + (w.breakable.wedgeHp or 1) -- 3591
			end -- 3591
			inv.wedge = inv.wedge - 1 -- 3593
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3594
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 3596
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3597
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3598
			return -- 3599
		end -- 3599
	end -- 3599
	if inv.ammo > 0 and self.reloadT > 0 then -- 3602
		self.reloadT = 0 -- 3604
		self:closeReloadPuzzle() -- 3605
		inv.ammo = inv.ammo - 1 -- 3606
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3607
		self:log("用备用弹包") -- 3608
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3609
		return -- 3610
	end -- 3610
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 3612
		local p = self.player -- 3614
		self.bracedShield = { -- 3615
			x = p.x + p.facing * 26, -- 3615
			y = p.y, -- 3615
			w = 30, -- 3615
			h = 64, -- 3615
			hp = 1 -- 3615
		} -- 3615
		local ____self_boxes_57 = self.boxes -- 3616
		____self_boxes_57[#____self_boxes_57 + 1] = { -- 3616
			x0 = self.bracedShield.x - 15, -- 3617
			x1 = self.bracedShield.x + 15, -- 3617
			y0 = p.y, -- 3618
			y1 = p.y + 64, -- 3618
			depth = {min = -46, max = 46}, -- 3618
			label = "架起的残盾", -- 3618
			id = "braced_shield", -- 3618
			soft = true -- 3619
		} -- 3619
		inv.shield = inv.shield - 1 -- 3622
		self:flashSet("架残盾 · 挡一发", 1.2) -- 3623
		self:log("架残盾") -- 3624
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3625
		return -- 3626
	end -- 3626
	if inv.pass > 0 and self.run.joined == false then -- 3628
		inv.pass = inv.pass - 1 -- 3629
		self.run.joined = true -- 3630
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3631
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3632
		return -- 3633
	end -- 3633
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3635
end -- 3580
function Play.prototype.useInteract(self, b) -- 3638
	local kind = b.interact == nil and "" or b.interact.kind -- 3639
	local wr = self.room -- 3640
	if kind == "open_board" then -- 3641
		b.broken = true -- 3642
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3643
		for ____, cover in ipairs(self.boxes) do -- 3644
			if cover.id == "s2_board_cover" then -- 3645
				cover.broken = false -- 3646
				cover.hidden = false -- 3647
			end -- 3647
		end -- 3647
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3650
		self.run.joined = true -- 3651
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3652
		self:log("放下窗板") -- 3653
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3654
		return -- 3655
	end -- 3655
	if kind == "lower_curtain" then -- 3657
		for ____, curtain in ipairs(self.boxes) do -- 3658
			if curtain.id == "c2_curtain" then -- 3659
				curtain.broken = false -- 3660
				curtain.hidden = false -- 3661
			end -- 3661
		end -- 3661
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3664
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3665
		self:log("放下木帘") -- 3666
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3667
		return -- 3668
	end -- 3668
	if kind == "raise_latch" then -- 3670
		if wr.key == "c2-granary" and not self.cartDocked then -- 3671
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3672
			return -- 3673
		end -- 3673
		b.broken = true -- 3675
		self.objectiveDone = true -- 3676
		if wr.key == "c1-yard" then -- 3678
			self.run.c1Latch = true -- 3679
			self.run.joined = true -- 3680
			for ____, door in ipairs(self.boxes) do -- 3681
				if door.id == "c1_door" then -- 3682
					door.broken = true -- 3683
				end -- 3683
			end -- 3683
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3686
		else -- 3686
			self.run.c2Latch = true -- 3688
			self.run.joined = true -- 3689
		end -- 3689
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3691
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3692
		self:log("抬闩") -- 3693
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3694
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3695
	end -- 3695
end -- 3638
function Play.prototype.stepCampaignCart(self, dt, input) -- 3700
	local wr = self.room -- 3701
	local c = wr.cart -- 3702
	if c.bodyW <= 0 then -- 3703
		return -- 3704
	end -- 3704
	local p = self.player -- 3706
	local handleX = self.cartAxle + c.handleOffset -- 3707
	if not self.gripping then -- 3708
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3709
			self.gripping = true -- 3711
			self:flashSet("握住车柄 · A/D 推", 1) -- 3712
		end -- 3712
		return -- 3714
	end -- 3714
	if input.interact.pressed then -- 3716
		self.gripping = false -- 3717
		self:flashSet("松手", 0.5) -- 3718
		return -- 3719
	end -- 3719
	if not self.cartDocked then -- 3721
		if input.moveX ~= 0 and not self:stuckCart() then -- 3722
			self.cartAxle = math.max( -- 3723
				c.startX, -- 3723
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3723
			) -- 3723
		end -- 3723
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3727
			self.cartExposed = true -- 3728
			local gun = nil -- 3729
			local gi = 0 -- 3730
			do -- 3730
				gi = 0 -- 3731
				while gi < #self.enemies do -- 3731
					local e = self.enemies[gi + 1] -- 3732
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3733
						gun = e -- 3734
						break -- 3735
					end -- 3735
					gi = gi + 1 -- 3731
				end -- 3731
			end -- 3731
			if gun ~= nil then -- 3738
				self:campaignEnemyFire(gun) -- 3739
			end -- 3739
		end -- 3739
		p.x = self.cartAxle + c.handleOffset -- 3742
		p.y = c.baseY -- 3743
		p.depth = c.depth or 0 -- 3744
		p.vx = 0 -- 3745
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3746
			self.cartAxle = c.endX -- 3747
			self.cartDocked = true -- 3748
			self.gripping = false -- 3749
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3750
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3751
			self:flashSet("车轮入窝", 1.2) -- 3752
			self:log("车轮入窝") -- 3753
		end -- 3753
	end -- 3753
end -- 3700
function Play.prototype.stuckCart(self) -- 3759
	local i = 0 -- 3760
	do -- 3760
		i = 0 -- 3761
		while i < #self.boxes do -- 3761
			do -- 3761
				local b = self.boxes[i + 1] -- 3762
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3763
					goto __continue591 -- 3764
				end -- 3764
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3766
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3767
					return true -- 3768
				end -- 3768
			end -- 3768
			::__continue591:: -- 3768
			i = i + 1 -- 3761
		end -- 3761
	end -- 3761
	return false -- 3771
end -- 3759
function Play.prototype.stepCampaignGoal(self) -- 3775
	local wr = self.room -- 3776
	local c = wr.campaign -- 3777
	if c == nil then -- 3778
		return -- 3779
	end -- 3779
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3781
		self.objectiveDone = true -- 3782
	end -- 3782
	if c.goal == "reach_exit" then -- 3784
		self.objectiveDone = true -- 3785
	end -- 3785
	if not self.objectiveDone then -- 3787
		return -- 3788
	end -- 3788
	local p = self.player -- 3790
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3791
	if p.x < c.exitX or not partnerOk then -- 3792
		return -- 3793
	end -- 3793
	if self.run.story.segments[wr.key] ~= true then -- 3796
		self.run.story.segments[wr.key] = true -- 3797
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3798
	end -- 3798
	if wr.key == "escort5" then -- 3801
		self.escortDone = true -- 3802
		self.run.story.escortDone = true -- 3803
	end -- 3803
	if c.next ~= nil and c.next ~= "" then -- 3805
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3806
		self:flashSet("过关 · " .. c.next, 1.2) -- 3807
	elseif wr.key == "c2-granary" and self.run.trial == nil and (self.run.source == "official" or self.run.source == "chapter") then -- 3808
		self:requestRoom("gate", "军粮棚出口") -- 3810
		self:flashSet("出军粮棚 · 城门", 1.4) -- 3811
	elseif not self.run.finished then -- 3812
		self.run.finished = true -- 3813
		self:flashSet( -- 3814
			"军粮棚清完 · 回城门 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3814
			2 -- 3814
		) -- 3814
		self:log("军粮棚清完 · 回城门") -- 3815
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3816
	end -- 3816
end -- 3775
function Play.prototype.stepCampaignPartner(self, dt) -- 3821
	local a = self.partner -- 3822
	local wr = self.room -- 3823
	local cp = wr.companion -- 3824
	if not a.alive then -- 3825
		return -- 3826
	end -- 3826
	local p = self.player -- 3828
	if self.craftBench.active then -- 3830
		a.vx = 0 -- 3831
		return -- 3832
	end -- 3832
	local wait = false -- 3834
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3835
	local targetDepth = p.depth -- 3836
	if self.run.joined == false then -- 3837
		wait = true -- 3838
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3839
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3840
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3841
		wait = true -- 3842
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3843
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3844
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3845
		wait = true -- 3846
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3847
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3848
	end -- 3848
	if self.partnerStuck > 0.3 then -- 3850
		a.x = a.x + a.facing * 44 -- 3852
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3853
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3854
		self.partnerLaneHold = 1.1 -- 3855
		self.partnerStuck = 0 -- 3856
	end -- 3856
	if self.partnerLaneHold > 0 then -- 3858
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3859
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3860
	end -- 3860
	local dx = targetX - a.x -- 3862
	local stopTol = wait and 18 or 74 -- 3863
	if math.abs(dx) > stopTol then -- 3864
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3865
		local before = a.x -- 3866
		a.vx = dx > 0 and speed or -speed -- 3867
		a.facing = dx > 0 and 1 or -1 -- 3868
		self:slideX(a, a.vx * dt) -- 3869
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3871
			a.vy = CHILD_JUMP -- 3872
			a.onGround = false -- 3873
		end -- 3873
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3875
	else -- 3875
		a.vx = 0 -- 3877
		self.partnerStuck = 0 -- 3878
	end -- 3878
	local dz = targetDepth - a.depth -- 3880
	if math.abs(dz) > 6 then -- 3881
		local step = math.max( -- 3882
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3882
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3882
		) -- 3882
		a.depth = a.depth + step -- 3883
	end -- 3883
	a.depthSpeed = 0 -- 3885
	a.h = CHILD_H -- 3886
	a.crouch = false -- 3887
	self:fallY(a, dt) -- 3888
end -- 3821
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3892
	local p = self.player -- 3893
	local i = 0 -- 3894
	do -- 3894
		i = 0 -- 3895
		while i < #self.enemies do -- 3895
			do -- 3895
				local ____opt_58 = self.run.trial -- 3896
				if ____opt_58 and ____opt_58.lost then -- 3896
					return -- 3896
				end -- 3896
				local e = self.enemies[i + 1] -- 3897
				if e.kind == "target" then -- 3898
					if not e.alive then -- 3900
						if e.hitT > 0 then -- 3901
							e.hitT = e.hitT - dt -- 3902
						end -- 3902
						if e.hitT <= 0 then -- 3904
							e.alive = true -- 3905
							e.hitT = 0 -- 3906
						end -- 3906
					end -- 3906
					goto __continue619 -- 3909
				end -- 3909
				if not e.alive then -- 3911
					goto __continue619 -- 3912
				end -- 3912
				if e.kind == "breaker" then -- 3914
					self:stepBreaker(e, dt) -- 3915
					goto __continue619 -- 3916
				end -- 3916
				if e.kind == "shield" then -- 3918
					self:stepShield(e, dt, input) -- 3919
					goto __continue619 -- 3920
				end -- 3920
				local dx = e.x - p.x -- 3923
				if not e.awake then -- 3924
					if math.abs(dx) > 520 then -- 3925
						goto __continue619 -- 3926
					end -- 3926
					e.awake = true -- 3928
					e.fireCd = 48 -- 3929
					goto __continue619 -- 3930
				end -- 3930
				if math.abs(dx) > ENEMY_RANGE then -- 3932
					goto __continue619 -- 3933
				end -- 3933
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 3937
					goto __continue619 -- 3938
				end -- 3938
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 3940
					goto __continue619 -- 3941
				end -- 3941
				if self:blockedShot(e, p) then -- 3943
					if e.warnT > 0 then -- 3946
						e.warnT = 0 -- 3947
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3948
					end -- 3948
					goto __continue619 -- 3950
				end -- 3950
				if e.warnT > 0 then -- 3952
					e.warnT = e.warnT - 1 -- 3953
					if e.warnT <= 0 then -- 3954
						self:campaignEnemyFire(e) -- 3955
					end -- 3955
				elseif e.fireCd > 0 then -- 3957
					e.fireCd = e.fireCd - 1 -- 3958
					if e.fireCd <= 0 then -- 3959
						e.warnT = WARN_TICKS -- 3960
					end -- 3960
				else -- 3960
					e.fireCd = 40 -- 3963
				end -- 3963
			end -- 3963
			::__continue619:: -- 3963
			i = i + 1 -- 3895
		end -- 3895
	end -- 3895
end -- 3892
function Play.prototype.blockedShot(self, e, p) -- 3969
	local eDepth = e.depth or 0 -- 3970
	local ex = e.x -- 3971
	local ey = e.y + e.h * 0.62 -- 3973
	local px = p.x -- 3974
	local py = p.y + p.h * 0.55 -- 3975
	local dx = px - ex -- 3976
	local dyScreen = py + p.depth * DEPTH_Y_SCALE - (ey + eDepth * DEPTH_Y_SCALE) -- 3977
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3978
	if len < 0.01 then -- 3979
		return false -- 3980
	end -- 3980
	local ray = { -- 3984
		x = ex, -- 3985
		y = ey, -- 3985
		dx = dx / len, -- 3986
		dy = (py - ey) / len, -- 3986
		depth = eDepth, -- 3987
		dDepth = (p.depth - eDepth) / len -- 3987
	} -- 3987
	local best = -1 -- 3989
	local j = 0 -- 3990
	do -- 3990
		j = 0 -- 3991
		while j < #self.boxes do -- 3991
			do -- 3991
				local b = self.boxes[j + 1] -- 3992
				if b.broken == true or b.passable == true or b.hidden == true then -- 3993
					goto __continue643 -- 3994
				end -- 3994
				if b.id == "braced_shield" then -- 3998
					goto __continue643 -- 3999
				end -- 3999
				local t = hitBox(ray, b) -- 4001
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 4004
					best = t -- 4005
				end -- 4005
			end -- 4005
			::__continue643:: -- 4005
			j = j + 1 -- 3991
		end -- 3991
	end -- 3991
	return best >= 0 -- 4008
end -- 3969
function Play.prototype.campaignEnemyFire(self, e) -- 4011
	local p = self.player -- 4012
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4013
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 4014
		local ____self_bracedShield_60, ____hp_61 = self.bracedShield, "hp" -- 4015
		____self_bracedShield_60[____hp_61] = ____self_bracedShield_60[____hp_61] - 1 -- 4015
		self.boxes = __TS__ArrayFilter( -- 4016
			self.boxes, -- 4016
			function(____, b) return b.id ~= "braced_shield" end -- 4016
		) -- 4016
		self.bracedShield = nil -- 4017
		self:flashSet("残盾碎 · 挡下一发", 1) -- 4018
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 4019
		return -- 4020
	end -- 4020
	if self:blockedShot(e, p) then -- 4022
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4023
		return -- 4024
	end -- 4024
	local cover = self:blockedByCover(e, p) -- 4026
	if cover ~= nil and self.coverHug then -- 4027
		self.coveredFlash = 0.5 -- 4028
		self:flashSet("掩体挡下", 0.6) -- 4029
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4030
		return -- 4035
	end -- 4035
	if self.invulnT > 0 then -- 4037
		return -- 4038
	end -- 4038
	self.invulnT = INVULN_HIT_TICKS + 12 * self:talentRank("guard") -- 4040
	self.craftT = 0 -- 4041
	self.hp = self.hp - 1 -- 4042
	self:emit("actorHit", { -- 4043
		target = "player", -- 4043
		amount = 1, -- 4043
		hp = self.hp, -- 4043
		maxHp = self.maxHp, -- 4043
		enemyX = e.x -- 4043
	}) -- 4043
	self:flashSet( -- 4044
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4044
		0.8 -- 4044
	) -- 4044
	if self.hp <= 0 then -- 4045
		self:campaignFailed() -- 4046
	end -- 4046
end -- 4011
function Play.prototype.stepShield(self, e, dt, input) -- 4051
	local p = self.player -- 4052
	local dx = p.x - e.x -- 4053
	local adx = math.abs(dx) -- 4054
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 4057
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 4058
	if adx > 44 then -- 4059
		local before = e.x -- 4060
		local stepX = (dx > 0 and 1 or -1) * 60 * dt -- 4061
		local nextX = math.max( -- 4062
			self.room.minX + 16, -- 4062
			math.min(self.room.maxX - 16, e.x + stepX) -- 4062
		) -- 4062
		if not self:enemyBlockedAtX(e, nextX) then -- 4063
			e.x = nextX -- 4064
		end -- 4064
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 4066
			e.depth = math.max( -- 4068
				-32, -- 4068
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4068
			) -- 4068
		end -- 4068
	elseif adx <= 48 and sameLane and (e.swingT or 0) <= 0 then -- 4070
		local fromFront = (e.x - p.x) * p.facing > 0 -- 4073
		local rollDodges = p.rollT > 0 and fromFront -- 4074
		if not rollDodges and self.invulnT <= 0 then -- 4075
			self.invulnT = INVULN_HIT_TICKS + 12 * self:talentRank("guard") -- 4076
			self.craftT = 0 -- 4077
			self.hp = self.hp - 1 -- 4078
			self:emit("actorHit", { -- 4079
				target = "player", -- 4079
				amount = 1, -- 4079
				hp = self.hp, -- 4079
				maxHp = self.maxHp, -- 4079
				enemyX = e.x -- 4079
			}) -- 4079
			self:flashSet( -- 4080
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4080
				0.8 -- 4080
			) -- 4080
			if self.hp <= 0 then -- 4081
				self:campaignFailed() -- 4082
				return -- 4083
			end -- 4083
		end -- 4083
		e.swingT = 70 -- 4086
	end -- 4086
	if (e.swingT or 0) > 0 then -- 4088
		e.swingT = (e.swingT or 0) - 1 -- 4089
	end -- 4089
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 4091
		local dd = p.depth - (e.depth or 0) -- 4092
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 4093
	end -- 4093
end -- 4051
function Play.prototype.stepBreaker(self, e, dt) -- 4098
	local p = self.player -- 4099
	if e.awake ~= true then -- 4100
		if math.abs(p.x - e.x) < 560 then -- 4101
			e.awake = true -- 4102
		else -- 4102
			return -- 4104
		end -- 4104
	end -- 4104
	local target = nil -- 4107
	local bestD = 1000000000 -- 4108
	local i = 0 -- 4109
	do -- 4109
		i = 0 -- 4110
		while i < #self.boxes do -- 4110
			do -- 4110
				local b = self.boxes[i + 1] -- 4111
				if b.breakable == nil or b.broken == true then -- 4112
					goto __continue668 -- 4113
				end -- 4113
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 4115
				if d < bestD then -- 4116
					bestD = d -- 4117
					target = b -- 4118
				end -- 4118
			end -- 4118
			::__continue668:: -- 4118
			i = i + 1 -- 4110
		end -- 4110
	end -- 4110
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 4121
	local dx = tx - e.x -- 4122
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 4123
	if math.abs(dx) > reach then -- 4124
		local before = e.x -- 4125
		local nextX = math.max( -- 4126
			self.room.minX + 16, -- 4126
			math.min(self.room.maxX - 16, e.x + (dx > 0 and 1 or -1) * 48 * dt) -- 4126
		) -- 4126
		if not self:enemyBlockedAtX(e, nextX) then -- 4127
			e.x = nextX -- 4128
		end -- 4128
		if math.abs(e.x - before) < 0.3 then -- 4130
			e.depth = math.max( -- 4131
				-32, -- 4131
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4131
			) -- 4131
		end -- 4131
	elseif (e.swingT or 0) <= 0 then -- 4133
		e.swingT = 64 -- 4134
		if target ~= nil then -- 4135
			self:damageProp(target, 2) -- 4136
		elseif math.abs(p.x - e.x) < 60 and math.abs((e.depth or 0) - p.depth) <= 26 and self.invulnT <= 0 then -- 4137
			self.invulnT = INVULN_HIT_TICKS + 12 * self:talentRank("guard") -- 4138
			self.craftT = 0 -- 4139
			self.hp = self.hp - 1 -- 4140
			self:emit("actorHit", { -- 4141
				target = "player", -- 4141
				amount = 1, -- 4141
				hp = self.hp, -- 4141
				maxHp = self.maxHp, -- 4141
				enemyX = e.x -- 4141
			}) -- 4141
			self:flashSet("破障手近身", 0.8) -- 4142
			if self.hp <= 0 then -- 4143
				self:campaignFailed() -- 4144
				return -- 4145
			end -- 4145
		end -- 4145
	end -- 4145
	if (e.swingT or 0) > 0 then -- 4149
		e.swingT = (e.swingT or 0) - 1 -- 4150
	end -- 4150
end -- 4098
function Play.prototype.enemyBlockedAtX(self, e, nextX) -- 4155
	local half = e.w * 0.5 -- 4156
	local d = e.depth or 0 -- 4157
	local i = 0 -- 4158
	do -- 4158
		i = 0 -- 4159
		while i < #self.boxes do -- 4159
			do -- 4159
				local b = self.boxes[i + 1] -- 4160
				if b.broken == true or b.passable == true or b.soft == true or b.hidden == true or b.y0 >= e.y + e.h or b.y1 <= e.y + 4 then -- 4161
					goto __continue681 -- 4162
				end -- 4162
				if b.depth ~= nil and (d < b.depth.min - 8 or d > b.depth.max + 8) then -- 4164
					goto __continue681 -- 4165
				end -- 4165
				if nextX + half > b.x0 and nextX - half < b.x1 then -- 4167
					return true -- 4168
				end -- 4168
			end -- 4168
			::__continue681:: -- 4168
			i = i + 1 -- 4159
		end -- 4159
	end -- 4159
	return false -- 4171
end -- 4155
function Play.prototype.campaignFailed(self) -- 4174
	if self.run.trial ~= nil then -- 4175
		self.run.trial.lost = true -- 4176
		self.wantRoom = "" -- 4177
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4178
		return -- 4179
	end -- 4179
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 4183
		self:restartEscortFromDeath() -- 4184
		return -- 4185
	end -- 4185
	local p = self.player -- 4187
	self.hp = self.maxHp -- 4188
	self.invulnT = INVULN_RESPAWN_TICKS -- 4189
	self.reloadT = 0 -- 4190
	self:closeReloadPuzzle() -- 4191
	self.gripping = false -- 4192
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 4193
	self:log("被击倒") -- 4194
	p.x = self.room.minX + 90 -- 4195
	p.y = 0 -- 4196
	p.depth = 0 -- 4197
	p.vx = 0 -- 4198
	p.vy = 0 -- 4199
	p.onGround = true -- 4200
	p.rollT = 0 -- 4201
	self.partner.x = p.x - 50 -- 4202
	self.partner.y = 0 -- 4203
	self.partner.depth = 0 -- 4204
	self.cam.x = p.x -- 4205
	local i = 0 -- 4206
	do -- 4206
		i = 0 -- 4207
		while i < #self.enemies do -- 4207
			do -- 4207
				local e = self.enemies[i + 1] -- 4208
				if not e.alive then -- 4209
					goto __continue689 -- 4210
				end -- 4210
				e.x = e.homeX == nil and e.x or e.homeX -- 4212
				e.warnT = 0 -- 4213
				e.fireCd = 40 -- 4214
				e.swingT = 0 -- 4215
				e.awake = false -- 4216
			end -- 4216
			::__continue689:: -- 4216
			i = i + 1 -- 4207
		end -- 4207
	end -- 4207
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4218
end -- 4174
function Play.prototype.isEscortRoom(self) -- 4222
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 4223
end -- 4222
function Play.prototype.restartEscortFromDeath(self) -- 4231
	local story = self.run.story -- 4232
	local inv = self.run.inventory -- 4233
	local vitBonus = story.talents ~= nil and story.talents.ranks.vitality or 0 -- 4234
	if vitBonus > 0 then -- 4235
		self.maxHp = math.max(3, self.maxHp - vitBonus) -- 4236
		story.maxHp = self.maxHp -- 4237
	end -- 4237
	story.talents = createStoryTalents(self.run.seed) -- 4239
	self.hp = self.maxHp -- 4240
	story.hp = self.maxHp -- 4241
	story.cp = nil -- 4242
	self.checkpointSnap = nil -- 4243
	story.carry = false -- 4244
	self.carryOn = false -- 4245
	story.craftedWeapon = "" -- 4246
	self.equippedWeapon = "standard_gun" -- 4247
	story.equippedWeapon = "standard_gun" -- 4248
	story.escortDone = false -- 4249
	self.escortDone = false -- 4250
	story.segments = {} -- 4251
	inv.wood = 0 -- 4252
	inv.bell = 0 -- 4253
	inv.scrap = 0 -- 4254
	inv.wedge = 0 -- 4255
	inv.ammo = 0 -- 4256
	inv.quickbelt = 0 -- 4257
	inv.shield = 0 -- 4258
	inv.pass = 0 -- 4259
	local taken = self.run.taken -- 4260
	local keys = __TS__ObjectKeys(taken) -- 4261
	local i = 0 -- 4262
	do -- 4262
		i = 0 -- 4263
		while i < #keys do -- 4263
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 4264
				__TS__Delete(taken, keys[i + 1]) -- 4265
			end -- 4265
			i = i + 1 -- 4263
		end -- 4263
	end -- 4263
	self.run.joined = true -- 4268
	self.reloadT = 0 -- 4269
	self:closeReloadPuzzle() -- 4270
	self.gripping = false -- 4271
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 4272
	self:log("男主线失败 · 回 escort1") -- 4273
	self:emit("campaignFailed", { -- 4274
		room = self.room.key, -- 4275
		hp = 0, -- 4275
		maxHp = self.maxHp, -- 4275
		reset = true, -- 4276
		to = "escort1", -- 4276
		route = self.storyRoute -- 4276
	}) -- 4276
	self:requestRoom("escort1", "男主线失败重开") -- 4278
end -- 4231
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 4282
	local i = 0 -- 4283
	do -- 4283
		i = 0 -- 4284
		while i < #self.enemies do -- 4284
			do -- 4284
				if i == skipIndex then -- 4285
					goto __continue699 -- 4286
				end -- 4286
				local e = self.enemies[i + 1] -- 4288
				if not e.alive or math.abs(e.x - center.x) > radius then -- 4289
					goto __continue699 -- 4290
				end -- 4290
				e.fireCd = 150 -- 4292
				e.warnT = 0 -- 4293
			end -- 4293
			::__continue699:: -- 4293
			i = i + 1 -- 4284
		end -- 4284
	end -- 4284
end -- 4282
function Play.prototype.stepEnemies(self, dt, input) -- 4297
	local i = 0 -- 4298
	do -- 4298
		i = 0 -- 4299
		while i < #self.enemies do -- 4299
			local e = self.enemies[i + 1] -- 4300
			if e.hitT > 0 then -- 4301
				e.hitT = e.hitT - dt -- 4302
			end -- 4302
			i = i + 1 -- 4299
		end -- 4299
	end -- 4299
	if self.coveredFlash > 0 then -- 4305
		self.coveredFlash = self.coveredFlash - dt -- 4306
	end -- 4306
	if self.isCampaign then -- 4308
		self:stepCampaignEnemies(dt, input) -- 4309
		return -- 4310
	end -- 4310
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 4313
		return -- 4314
	end -- 4314
	do -- 4314
		i = 0 -- 4316
		while i < #self.enemies do -- 4316
			do -- 4316
				local e = self.enemies[i + 1] -- 4317
				if not e.alive then -- 4318
					goto __continue710 -- 4319
				end -- 4319
				if e.warnT > 0 then -- 4321
					e.warnT = e.warnT - 1 -- 4322
					if e.warnT <= 0 then -- 4323
						self:enemyFire(e, input) -- 4324
					end -- 4324
					goto __continue710 -- 4326
				end -- 4326
				if e.fireCd > 0 then -- 4328
					e.fireCd = e.fireCd - 1 -- 4329
					if e.fireCd <= 0 then -- 4330
						e.warnT = WARN_TICKS -- 4331
					end -- 4331
				else -- 4331
					e.warnT = WARN_TICKS -- 4335
				end -- 4335
			end -- 4335
			::__continue710:: -- 4335
			i = i + 1 -- 4316
		end -- 4316
	end -- 4316
end -- 4297
function Play.prototype.enemyFire(self, e, input) -- 4341
	local p = self.player -- 4342
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 4343
		self:flashSet("枪声响在远处", 0.4) -- 4344
		e.fireCd = FIRE_COOLDOWN -- 4345
		return -- 4346
	end -- 4346
	if self:blockedShot(e, p) then -- 4348
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4349
		e.fireCd = FIRE_COOLDOWN -- 4350
		return -- 4351
	end -- 4351
	local cover = self:blockedByCover(e, p) -- 4354
	local hugging = cover ~= nil -- 4355
	self.coverBlocking = hugging -- 4356
	local covered = hugging and input.cover.held -- 4357
	if covered then -- 4358
		self.coveredFlash = 0.5 -- 4359
		self:flashSet("掩体挡下", 0.5) -- 4360
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4361
		e.fireCd = FIRE_COOLDOWN -- 4366
		return -- 4367
	end -- 4367
	if self.invulnT > 0 then -- 4369
		e.fireCd = FIRE_COOLDOWN -- 4370
		return -- 4371
	end -- 4371
	self.invulnT = INVULN_HIT_TICKS -- 4373
	self.hp = self.hp - 1 -- 4374
	self:emit("actorHit", { -- 4375
		target = "player", -- 4375
		amount = 1, -- 4375
		hp = self.hp, -- 4375
		maxHp = self.maxHp, -- 4375
		enemyX = e.x -- 4375
	}) -- 4375
	self:flashSet( -- 4376
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4376
		0.7 -- 4376
	) -- 4376
	e.fireCd = FIRE_COOLDOWN -- 4377
	if self.hp <= 0 then -- 4378
		self:gateFailed() -- 4379
	end -- 4379
end -- 4341
function Play.prototype.blockedByCover(self, enemy, p) -- 4384
	local b = self:coverAt(p) -- 4385
	if b == nil then -- 4386
		return nil -- 4387
	end -- 4387
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4389
end -- 4384
function Play.prototype.gateFailed(self) -- 4393
	local ____temp_62 -- 4394
	if self.room.story == nil then -- 4394
		____temp_62 = nil -- 4394
	else -- 4394
		____temp_62 = self.room.story.gate -- 4394
	end -- 4394
	local g = ____temp_62 -- 4394
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 4395
	self.hp = self.maxHp -- 4396
	self.gateTick = 0 -- 4397
	self.gateSpawned = 0 -- 4398
	self.enemies = {} -- 4399
	self.gateFailCount = self.gateFailCount + 1 -- 4400
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 4402
	self.player.y = 0 -- 4403
	self.player.vy = 0 -- 4404
	self.player.depth = 0 -- 4405
	self.player.depthSpeed = 0 -- 4406
	self.player.onGround = true -- 4407
	self.player.crouch = false -- 4408
	self.player.h = SOLDIER_H -- 4409
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 4410
	self.partner.y = 0 -- 4411
	self.partner.vy = 0 -- 4412
	self.partner.depth = 0 -- 4413
	self.partner.depthSpeed = 0 -- 4414
	self.partner.onGround = true -- 4415
	self.cam.x = self.player.x -- 4416
	self.phase = "gate-idle" -- 4417
	self.phaseTick = 0 -- 4418
	self.coverHug = false -- 4419
	self.coverBlocking = false -- 4420
	self.coverEntity = "" -- 4421
	self.gateNeedConfirm = true -- 4422
	self.gateRestartArmed = false -- 4423
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 4424
end -- 4393
function Play.prototype.stepRedCart(self, input) -- 4428
	if self.redCartMemoryT > 0 then -- 4429
		self.redCartMemoryT = self.redCartMemoryT - 1 -- 4430
	end -- 4430
	if self.room.key ~= "outside" or self.redCartPulled then -- 4432
		return -- 4433
	end -- 4433
	local box = __TS__ArrayFind( -- 4435
		self.boxes, -- 4435
		function(____, b) return b.id == "outside_red_cart" end -- 4435
	) -- 4435
	if box == nil then -- 4436
		self.redCartPulled = true -- 4437
		return -- 4438
	end -- 4438
	local cx = (box.x0 + box.x1) * 0.5 -- 4440
	local p = self.player -- 4441
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 4442
		return -- 4443
	end -- 4443
	if not input.interact.pressed then -- 4445
		return -- 4446
	end -- 4446
	box.x0 = 430 -- 4448
	box.x1 = 474 -- 4449
	self.cartAxle = self.room.cart.endX -- 4451
	self.cartDocked = true -- 4452
	self.redCartPulled = true -- 4453
	self.redCartMemoryT = 30 -- 4454
	if self.run.story ~= nil then -- 4455
		self.run.story.segments.outside_cart = true -- 4456
		self.run.story.segments.outside_memory = true -- 4457
	end -- 4457
	self.sessionDirty = true -- 4459
	self:flashSet("红布补丁 · 想起家里那一针 · 石阶口露出来", 1.8) -- 4460
	self:emit("storyBeat", {beat = "red_cart", x = p.x, room = "outside"}) -- 4461
	self:emit("storyBeat", {beat = "red_cart_memory", x = p.x, room = "outside", durationTicks = 30}) -- 4462
end -- 4428
function Play.prototype.stepInteract(self, dt, input) -- 4465
	local p = self.player -- 4466
	self:stepRedCart(input) -- 4467
	local calmUsed = self.calmConsumed -- 4468
	self.calmConsumed = false -- 4469
	local calming = self.escort.state == "calming" -- 4471
	self.focusCart = false -- 4472
	if self.room.key == "outside" then -- 4473
		local c = self.room.cart -- 4474
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 4475
		local dy = p.y - c.baseY -- 4476
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 4477
	end -- 4477
	if not calmUsed and not calming then -- 4480
		self:stepCart(dt, input) -- 4481
	end -- 4481
	if calmUsed then -- 4485
		self:flashSet("安抚 · 敲两下", 0.8) -- 4486
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4487
		if self.knockT > 0 then -- 4489
			self.knocks = self.knocks + 1 -- 4490
		else -- 4490
			self.knocks = 1 -- 4492
		end -- 4492
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4494
		self.knockT = 1.2 -- 4495
		if self.knocks >= 2 then -- 4496
			self:flashSet("敲两下", 0.8) -- 4497
			self.knocks = 0 -- 4498
		else -- 4498
			self:flashSet("敲一下", 0.5) -- 4500
		end -- 4500
	elseif self.knockT > 0 then -- 4502
		self.knockT = self.knockT - dt -- 4503
		if self.knockT <= 0 then -- 4504
			self.knocks = 0 -- 4505
		end -- 4505
	end -- 4505
	local i = 0 -- 4510
	do -- 4510
		i = 0 -- 4511
		while i < #self.room.marks do -- 4511
			do -- 4511
				local m = self.room.marks[i + 1] -- 4512
				if m.kind ~= 0 then -- 4513
					goto __continue746 -- 4514
				end -- 4514
				local subjects = {self.partner, self.player} -- 4516
				local k = 0 -- 4517
				do -- 4517
					k = 0 -- 4518
					while k < #subjects do -- 4518
						do -- 4518
							local s = subjects[k + 1] -- 4519
							if not s.alive then -- 4520
								goto __continue749 -- 4521
							end -- 4521
							local dx = s.x - m.x -- 4523
							local dy = s.y - m.y -- 4524
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4525
								self.checkpoint = m.x -- 4526
								self.checkpointCartAxle = self.cartAxle -- 4527
								if self.isCampaign then -- 4529
									self:captureCheckpoint(m.x) -- 4530
								end -- 4530
								if self.cartDocked then -- 4532
									self:flashSet("检查点 · 车已落窝", 1) -- 4533
								else -- 4533
									self:flashSet("检查点 · 车还没到位", 1) -- 4535
								end -- 4535
							end -- 4535
						end -- 4535
						::__continue749:: -- 4535
						k = k + 1 -- 4518
					end -- 4518
				end -- 4518
			end -- 4518
			::__continue746:: -- 4518
			i = i + 1 -- 4511
		end -- 4511
	end -- 4511
	self:checkCarryGate() -- 4541
end -- 4465
function Play.prototype.stepVillage(self, dt, input) -- 4545
	if self.room.key ~= "village" then -- 4546
		return -- 4547
	end -- 4547
	local p = self.player -- 4549
	local bottle = self.room.bottle -- 4550
	local scav = self.room.scavenger -- 4551
	if not self.hasBottle and bottle ~= nil then -- 4554
		local dx = p.x - bottle.x -- 4555
		local dy = p.y + p.h * 0.5 - bottle.y -- 4556
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4557
			self.hasBottle = true -- 4558
			self:flashSet("拾起瓶子", 0.8) -- 4559
		end -- 4559
	end -- 4559
	if self.hasBottle then -- 4564
		if input.bottleCanceled then -- 4565
			self.aimHold = 0 -- 4566
			self.bottleAimX = -1 -- 4567
		elseif input.aim.held then -- 4568
			self.aimHold = self.aimHold + dt -- 4569
			if self.aimHold > 1.2 then -- 4570
				self.aimHold = 1.2 -- 4571
			end -- 4571
			local cached = self:bottleEnd() -- 4574
			self.bottleAimX = cached.x -- 4575
			self.bottleAimY = cached.y -- 4576
		elseif input.aim.released then -- 4577
			if self.aimHold < 0.12 then -- 4578
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 4580
				self.aimHold = 0 -- 4581
			else -- 4581
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4583
				self:throwBottle(____end.x, ____end.y) -- 4584
				self.aimHold = 0 -- 4585
			end -- 4585
		end -- 4585
	else -- 4585
		self.aimHold = 0 -- 4589
		self.bottleAimX = -1 -- 4590
	end -- 4590
	local fly = self.bottleFly -- 4595
	if fly ~= nil then -- 4596
		fly.t = fly.t + dt -- 4597
		fly.x = fly.x0 + fly.vx * fly.t -- 4598
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4599
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4600
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4601
			self:landBottle(fly) -- 4602
		end -- 4602
	end -- 4602
	if self.bottleLandT > 0 then -- 4605
		self.bottleLandT = self.bottleLandT - dt -- 4606
	end -- 4606
	if scav ~= nil then -- 4609
		self:stepScav(dt, scav) -- 4610
	end -- 4610
	local line = self.room.passLine -- 4613
	if line ~= nil and not self.passed and p.x >= line then -- 4614
		self.passed = true -- 4615
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4616
	end -- 4616
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4619
	if underTable then -- 4620
		self.footHintT = self.footHintT - 1 -- 4621
		if self.footHintT <= 0 then -- 4622
			self.footHintT = 90 -- 4623
			local scavX = self.scavX -- 4624
			local near = math.abs(scavX - p.x) < 120 -- 4625
			local walkingAway = self.scavState == "walk" and math.abs(self.scavTargetX - p.x) >= 120 -- 4626
			local heard = self.scavState == "chase" or near and not walkingAway -- 4627
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4628
			self:emit("storyBeat", {beat = heard and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4629
		end -- 4629
	else -- 4629
		self.footHintT = 0 -- 4632
	end -- 4632
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4635
		self.ditchHinted = true -- 4636
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4637
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4638
	end -- 4638
	if self.passed and p.x >= self.ox + 640 then -- 4641
		self:requestRoom("forest", "过第一院出院") -- 4642
		self:flashSet("钻出暗渠 · 北塔森林", 1.4) -- 4643
	end -- 4643
end -- 4545
function Play.prototype.bottleEnd(self) -- 4648
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4649
	local clampedX = math.max( -- 4652
		self.room.minX + 12, -- 4652
		math.min(self.room.maxX - 12, aim.x) -- 4652
	) -- 4652
	local g = self:groundAt(clampedX, aim.y + 240, 3) -- 4653
	return {x = clampedX, y = g} -- 4654
end -- 4648
function Play.prototype.throwBottle(self, tx, ty) -- 4658
	local p = self.player -- 4659
	local dir = tx >= p.x and 1 or -1 -- 4661
	p.facing = dir -- 4662
	local x0 = p.x + dir * 10 -- 4663
	local y0 = p.y + p.h * 0.7 -- 4664
	self.bottleTargetX = tx -- 4665
	self.bottleTargetY = ty -- 4666
	self.bottleSurfaceY = ty -- 4667
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4668
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4669
	self.bottleFly = { -- 4670
		x = x0, -- 4670
		y = y0, -- 4670
		x0 = x0, -- 4670
		y0 = y0, -- 4670
		vx = vx, -- 4670
		vy = vy, -- 4670
		t = 0 -- 4670
	} -- 4670
	self.hasBottle = false -- 4671
	self:flashSet("投出", 0.4) -- 4672
	self:emit( -- 4673
		"bottleThrown", -- 4673
		{ -- 4673
			fromX = x0, -- 4674
			fromY = y0, -- 4675
			targetX = tx, -- 4676
			targetY = ty, -- 4677
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4678
		} -- 4678
	) -- 4678
end -- 4658
function Play.prototype.bottleSurfaceAt(self, x) -- 4683
	if self.room.softX ~= nil and math.abs(x - self.room.softX) <= 34 then -- 4684
		return "soft" -- 4685
	end -- 4685
	if self.room.basinX ~= nil and math.abs(x - self.room.basinX) <= 24 then -- 4687
		return "iron" -- 4688
	end -- 4688
	return "brick" -- 4690
end -- 4683
function Play.prototype.landBottle(self, fly) -- 4694
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4695
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4696
	local s = self.room.scavenger -- 4697
	local surface = self:bottleSurfaceAt(x) -- 4698
	local effRange = s == nil and 0 or (surface == "iron" and s.range * 1.25 or s.range) -- 4699
	local heard = surface ~= "soft" and s ~= nil and math.abs(x - self.scavX) <= effRange -- 4700
	local stallTicks = s == nil and 0 or (surface == "iron" and s.stallTicks + 90 or s.stallTicks) -- 4701
	self.bottleFly = nil -- 4702
	self.bottleTargetX = -1 -- 4703
	self.bottleTargetY = 0 -- 4704
	self.bottleSurfaceY = -1 -- 4705
	self.bottleLandX = x -- 4706
	self.bottleLandY = y -- 4707
	self.bottleLandT = 0.9 -- 4708
	self:emit("bottleLanded", { -- 4709
		x = x, -- 4710
		y = y, -- 4711
		surface = surface, -- 4712
		heard = heard, -- 4713
		resonance = surface == "iron", -- 4714
		stallTicks = heard and stallTicks or 0, -- 4715
		scavState = self.scavState -- 4716
	}) -- 4716
	self:hearBottle(x, surface) -- 4718
end -- 4694
function Play.prototype.hearBottle(self, x, surface) -- 4722
	if surface == nil then -- 4722
		surface = "brick" -- 4722
	end -- 4722
	local s = self.room.scavenger -- 4723
	if s == nil then -- 4724
		return -- 4725
	end -- 4725
	if surface == "soft" then -- 4727
		self:flashSet("落在软土 · 没出声", 0.8) -- 4728
		return -- 4729
	end -- 4729
	local effRange = surface == "iron" and s.range * 1.25 or s.range -- 4731
	if math.abs(x - self.scavX) > effRange then -- 4732
		self:flashSet("落地 · 他没听见", 0.6) -- 4733
		return -- 4734
	end -- 4734
	self.scavState = "turn" -- 4736
	self.scavT = s.hearTicks -- 4737
	self.scavTargetX = surface == "iron" and self.room.basinX ~= nil and self.room.basinX or x -- 4738
	self.scavStallBonus = surface == "iron" and 90 or 0 -- 4739
	self:flashSet(surface == "iron" and "铁盆余振两响 · 他停下来细听" or "砖地一响 · 他转头", 1.1) -- 4740
end -- 4722
function Play.prototype.stepScav(self, dt, s) -- 4744
	if self.scavState == "chase" then -- 4746
		return -- 4747
	end -- 4747
	if self.scavState == "turn" then -- 4749
		self.scavT = self.scavT - 1 -- 4750
		if self.scavT <= 0 then -- 4751
			self.scavState = "walk" -- 4752
		end -- 4752
		return -- 4754
	end -- 4754
	if self.scavState == "walk" then -- 4756
		local d = self.scavTargetX - self.scavX -- 4757
		if math.abs(d) < 4 then -- 4758
			self.scavState = "stall" -- 4759
			self.scavT = s.stallTicks + self.scavStallBonus -- 4760
			self.scavStallBonus = 0 -- 4761
			return -- 4762
		end -- 4762
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4764
		return -- 4765
	end -- 4765
	if self.scavState == "stall" then -- 4767
		self.scavT = self.scavT - 1 -- 4768
		if self.scavT <= 0 then -- 4769
			self.scavState = "back" -- 4770
		end -- 4770
		return -- 4772
	end -- 4772
	if self.scavState == "back" then -- 4774
		local home = math.max( -- 4775
			s.x0, -- 4775
			math.min(s.x1, self.scavX) -- 4775
		) -- 4775
		if math.abs(home - self.scavX) < 2 then -- 4776
			self.scavState = "patrol" -- 4777
			return -- 4778
		end -- 4778
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4780
		return -- 4781
	end -- 4781
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4783
	if self.scavX >= s.x1 then -- 4784
		self.scavX = s.x1 -- 4785
		self.scavDir = -1 -- 4786
	elseif self.scavX <= s.x0 then -- 4787
		self.scavX = s.x0 -- 4788
		self.scavDir = 1 -- 4789
	end -- 4789
end -- 4744
function Play.prototype.stepCart(self, dt, input) -- 4797
	local p = self.player -- 4798
	local c = self.room.cart -- 4799
	if self.gripping then -- 4801
		if not input.interact.held then -- 4802
			self.gripping = false -- 4803
			self:flashSet("松开车把", 0.4) -- 4804
			return -- 4805
		end -- 4805
	else -- 4805
		if not input.interact.pressed then -- 4808
			return -- 4809
		end -- 4809
		if not self:cartHandleInReach(p) then -- 4811
			return -- 4812
		end -- 4812
		local track = c.depth or 0 -- 4814
		if self:limitDepth(p, track) ~= track then -- 4815
			return -- 4816
		end -- 4816
		p.depth = track -- 4818
		p.depthSpeed = 0 -- 4819
		self.gripping = true -- 4820
		self:flashSet("握住车把", 0.4) -- 4821
		return -- 4822
	end -- 4822
	if self.cartDocked then -- 4825
		return -- 4826
	end -- 4826
	local dir = input.moveX -- 4828
	if dir == 0 then -- 4829
		return -- 4830
	end -- 4830
	local lo = math.min(c.startX, c.endX) -- 4832
	local hi = math.max(c.startX, c.endX) -- 4833
	local next = self.cartAxle + dir * CART_SPEED * dt -- 4834
	if next < lo then -- 4835
		next = lo -- 4836
	end -- 4836
	if next > hi then -- 4838
		next = hi -- 4839
	end -- 4839
	local delta = next - self.cartAxle -- 4841
	if delta == 0 then -- 4842
		return -- 4843
	end -- 4843
	self.cartAxle = next -- 4845
	p.x = p.x + delta -- 4846
	p.facing = dir > 0 and 1 or -1 -- 4847
	self:slideX(p, 0) -- 4848
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 4849
		self.gripping = false -- 4850
		self:flashSet("跟不上了，脱手", 0.6) -- 4851
		return -- 4852
	end -- 4852
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 4854
		self.cartDocked = true -- 4855
		self.gripping = false -- 4856
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 4857
		self:flashSet("车轮落窝", 1.2) -- 4858
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 4859
		self:flashSet("车轮回到起点", 0.5) -- 4860
	end -- 4860
end -- 4797
function Play.prototype.requestRoom(self, key, reason) -- 4868
	if self.wantRoom ~= "" then -- 4871
		return -- 4872
	end -- 4872
	self.wantRoom = key -- 4874
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 4875
end -- 4868
function Play.prototype.checkCarryGate(self) -- 4882
	if self.room.key == "checkpoint" then -- 4883
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 4884
			self.carryCartAxle = self.cartAxle -- 4885
			self.carryCartDocked = self.cartDocked -- 4886
			self:requestRoom("gate", "检查站出口") -- 4887
			self:flashSet("出检查站 · 城门", 1.2) -- 4888
		end -- 4888
		return -- 4890
	end -- 4890
	if self.room.key == "outside" then -- 4892
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 4895
			self.carryCartAxle = self.cartAxle -- 4896
			self.carryCartDocked = self.cartDocked -- 4897
			self:requestRoom("village", "墙根走完") -- 4898
			self:flashSet("墙根走完 · 进村口", 1.2) -- 4899
		end -- 4899
	end -- 4899
end -- 4882
function Play.prototype.aimAt(self, wx, wy) -- 4906
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 4907
	self.aimX = s.x -- 4908
	self.aimY = s.y -- 4909
end -- 4906
function Play.prototype.shoot(self, a) -- 4912
	if self.isCampaign and self.reloadT > 0 then -- 4913
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 4914
		return -- 4915
	end -- 4915
	local ox = a.x + a.facing * 8 -- 4917
	local muzzleY = a.y + a.h * 0.72 -- 4918
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 4919
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4921
	local dx = aim.x - ox -- 4924
	local dy = aim.y - oy -- 4925
	local len = math.sqrt(dx * dx + dy * dy) -- 4926
	if len < 0.001 then -- 4927
		dx = a.facing -- 4928
		dy = 0 -- 4929
	else -- 4929
		dx = dx / len -- 4931
		dy = dy / len -- 4932
	end -- 4932
	if dx ~= 0 then -- 4934
		a.facing = dx > 0 and 1 or -1 -- 4935
	end -- 4935
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 4938
	local hitEnemy = self:raycastEnemies(ray) -- 4939
	local tEnemy = hitEnemy.t -- 4940
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 4941
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 4942
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 4943
	local tWall = solid.t -- 4944
	local rawEffect = self:consumeReloadEffect() -- 4946
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 4947
	local reloadEffect = rawEffect -- 4948
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 4950
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 4951
	self.trace = { -- 4953
		x0 = ox, -- 4953
		y0 = oy, -- 4953
		x1 = ox + dx * t, -- 4953
		y1 = oy + dy * t, -- 4953
		hit = hit -- 4953
	} -- 4953
	self.traceT = 0.12 -- 4954
	self:applyFireDanger(ox) -- 4955
	local killed = false -- 4956
	if hit then -- 4957
		local i = hitEnemy.index -- 4958
		local e = self.enemies[i + 1] -- 4959
		local impactY = oy + dy * tEnemy -- 4960
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 4961
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 4962
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 4963
			local dmg = reloadEffect == "push" and 2 or 1 -- 4964
			e.shieldHp = math.max(0, (e.shieldHp or 0) - dmg) -- 4965
			e.hitT = 0.3 -- 4966
			if reloadEffect == "push" then -- 4967
				e.x = math.max( -- 4968
					self.room.minX + 20, -- 4968
					math.min(self.room.maxX - 20, e.x + a.facing * 46) -- 4968
				) -- 4968
				self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4969
				self:flashSet(e.shieldHp <= 0 and "推退破盾！" or "推退震退持盾手", 0.9) -- 4970
			else -- 4970
				self:flashSet( -- 4972
					(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 4972
					0.8 -- 4972
				) -- 4972
			end -- 4972
			self:emit("shotResolved", { -- 4974
				hit = true, -- 4975
				enemyIndex = i, -- 4975
				enemyX = e.x, -- 4975
				aimX = aim.x, -- 4975
				aimY = aim.y, -- 4975
				impactX = ox + dx * t, -- 4976
				impactY = oy + dy * t, -- 4976
				shield = true -- 4976
			}) -- 4976
			self:beginReload() -- 4978
			return -- 4979
		end -- 4979
		e.alive = false -- 4981
		e.hitT = 0.4 -- 4982
		killed = true -- 4983
		self:flashSet("命中", 0.6) -- 4984
		self:dropFor(e) -- 4985
		if reloadEffect == "light" and weaponFx == "light" then -- 4986
			self:blindNearby(e, 160, i) -- 4987
		end -- 4987
		if reloadEffect == "push" then -- 4989
			e.x = e.x + a.facing * 46 -- 4990
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4991
		elseif reloadEffect == "echo" then -- 4992
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 4993
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 4994
		elseif reloadEffect == "light" then -- 4995
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 4996
		end -- 4996
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 4998
		self:damageProp(solid.box, 1) -- 4999
	else -- 4999
		self:flashSet("打空", 0.35) -- 5001
	end -- 5001
	if self.isCampaign then -- 5003
		self:beginReload() -- 5004
	end -- 5004
	self:emit("shotResolved", { -- 5006
		hit = hit, -- 5007
		enemyIndex = hit and hitEnemy.index or -1, -- 5008
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 5009
		aimX = aim.x, -- 5010
		aimY = aim.y, -- 5011
		impactX = ox + dx * t, -- 5012
		impactY = oy + dy * t -- 5013
	}) -- 5013
end -- 4912
function Play.prototype.applyFireDanger(self, shotX) -- 5018
	local ____temp_68 = self.isCampaign and self.run.trial == nil and self.run.joined -- 5019
	if ____temp_68 then -- 5019
		local ____opt_63 = self.room.campaign -- 5020
		local ____temp_67 = (____opt_63 and ____opt_63.chapter) == "S" -- 5020
		if not ____temp_67 then -- 5020
			local ____opt_65 = self.room.campaign -- 5020
			____temp_67 = (____opt_65 and ____opt_65.chapter) == "C" -- 5020
		end -- 5020
		____temp_68 = ____temp_67 -- 5019
	end -- 5019
	local isStorySc = ____temp_68 -- 5019
	if self.room.key ~= "checkpoint" and not isStorySc or not self.partner.alive then -- 5021
		return -- 5022
	end -- 5022
	local dangerX = shotX -- 5024
	local best = -1 -- 5025
	local bestD = 1000000000 -- 5026
	local i = 0 -- 5027
	do -- 5027
		i = 0 -- 5028
		while i < #self.enemies do -- 5028
			do -- 5028
				local e = self.enemies[i + 1] -- 5029
				if not e.alive then -- 5030
					goto __continue841 -- 5031
				end -- 5031
				local d = math.abs(e.x - self.partner.x) -- 5033
				if d < bestD then -- 5034
					bestD = d -- 5035
					best = i -- 5036
				end -- 5036
			end -- 5036
			::__continue841:: -- 5036
			i = i + 1 -- 5028
		end -- 5028
	end -- 5028
	if best >= 0 then -- 5039
		dangerX = self.enemies[best + 1].x -- 5040
	end -- 5040
	if isStorySc and math.abs(dangerX - self.partner.x) > 260 then -- 5043
		return -- 5044
	end -- 5044
	local exposed = self:childExposed(dangerX) -- 5046
	local before = self.escort.fear -- 5047
	local dangerId = self.nextDangerId -- 5048
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 5049
	self.nextDangerId = self.nextDangerId + 1 -- 5050
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 5051
	if after > before then -- 5052
		self:flashSet( -- 5053
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 5053
			1 -- 5053
		) -- 5053
	elseif not exposed then -- 5054
		self:flashSet("枪声没够到她", 0.5) -- 5055
	end -- 5055
end -- 5018
function Play.prototype.childExposed(self, dangerX) -- 5060
	local c = self.partner -- 5061
	if not c.alive then -- 5062
		return false -- 5063
	end -- 5063
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 5065
		self.boxes, -- 5066
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 5066
	) then -- 5066
		return false -- 5067
	end -- 5067
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 5069
		return false -- 5070
	end -- 5070
	local toDanger = dangerX - c.x -- 5072
	local toPlayer = self.player.x - c.x -- 5073
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 5074
		return false -- 5076
	end -- 5076
	return true -- 5078
end -- 5060
function Play.prototype.raycastEnemies(self, ray) -- 5082
	local best = -1 -- 5083
	local bestI = -1 -- 5084
	do -- 5084
		local i = 0 -- 5085
		while i < #self.enemies do -- 5085
			do -- 5085
				local e = self.enemies[i + 1] -- 5086
				if not e.alive then -- 5087
					goto __continue856 -- 5088
				end -- 5088
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 5090
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 5091
				if t >= 0 and (best < 0 or t < best) then -- 5092
					best = t -- 5093
					bestI = i -- 5094
				end -- 5094
			end -- 5094
			::__continue856:: -- 5094
			i = i + 1 -- 5085
		end -- 5085
	end -- 5085
	return {t = best, index = bestI} -- 5097
end -- 5082
function Play.prototype.raycastWorld(self, ray) -- 5100
	return self:raycastSolid(ray).t -- 5101
end -- 5100
function Play.prototype.raycastSolid(self, ray) -- 5105
	local best = -1 -- 5106
	local bestBox = nil -- 5107
	for ____, box in ipairs(self.boxes) do -- 5108
		do -- 5108
			if box.broken == true or box.hidden == true then -- 5109
				goto __continue861 -- 5110
			end -- 5110
			local t = hitBox(ray, box) -- 5115
			if t > 2 and (best < 0 or t < best) then -- 5117
				best = t -- 5118
				bestBox = box -- 5119
			end -- 5119
		end -- 5119
		::__continue861:: -- 5119
	end -- 5119
	if ray.dy < 0 then -- 5122
		local t = -ray.y / ray.dy -- 5123
		if t >= 0 and (best < 0 or t < best) then -- 5124
			best = t -- 5125
			bestBox = nil -- 5126
		end -- 5126
	end -- 5126
	return {t = best, box = bestBox} -- 5129
end -- 5105
function Play.prototype.dropFor(self, e) -- 5133
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 5134
		return -- 5135
	end -- 5135
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 5137
		return -- 5138
	end -- 5138
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 5140
	local ____self_pickups_69 = self.pickups -- 5141
	____self_pickups_69[#____self_pickups_69 + 1] = { -- 5141
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 5142
		kind = e.drop, -- 5142
		x = e.x, -- 5142
		y = e.y, -- 5142
		depth = e.depth, -- 5143
		label = label .. " ×1" -- 5143
	} -- 5143
	self:log("掉落 " .. label) -- 5145
end -- 5133
function Play.prototype.damageProp(self, b, amount) -- 5149
	if b.breakable == nil or b.broken == true then -- 5150
		return -- 5151
	end -- 5151
	local ____b_breakable_70, ____hp_71 = b.breakable, "hp" -- 5153
	____b_breakable_70[____hp_71] = ____b_breakable_70[____hp_71] - amount -- 5153
	if b.breakable.hp > 0 then -- 5154
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 5155
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 5156
		return -- 5157
	end -- 5157
	b.broken = true -- 5159
	for ____, other in ipairs(self.boxes) do -- 5160
		if other.id ~= nil and other.id == b.id then -- 5161
			other.broken = true -- 5162
		end -- 5162
	end -- 5162
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 5165
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 5166
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 5167
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 5168
end -- 5149
function Play.prototype.slideDepth(self, a, distance) -- 5172
	a.depth = self:limitDepth(a, a.depth + distance) -- 5173
end -- 5172
function Play.prototype.limitDepth(self, a, target) -- 5176
	local road = self.room.depth -- 5177
	if road == nil or target == a.depth then -- 5178
		return a.depth -- 5179
	end -- 5179
	local next = math.max( -- 5181
		road.min, -- 5181
		math.min(road.max, target) -- 5181
	) -- 5181
	local half = a.w / 2 -- 5182
	for ____, b in ipairs(self.boxes) do -- 5183
		do -- 5183
			local footprint = b.depth -- 5184
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5185
				goto __continue879 -- 5189
			end -- 5189
			local front = footprint.min - ACTOR_DEPTH_HALF -- 5191
			local back = footprint.max + ACTOR_DEPTH_HALF -- 5192
			if a.depth <= front and next > front then -- 5193
				next = front -- 5194
			elseif a.depth >= back and next < back then -- 5195
				next = back -- 5196
			end -- 5196
		end -- 5196
		::__continue879:: -- 5196
	end -- 5196
	return next -- 5199
end -- 5176
function Play.prototype.slideX(self, a, dx) -- 5203
	local nx = a.x + dx -- 5204
	local half = a.w / 2 -- 5205
	local room = self.room -- 5206
	nx = math.max( -- 5207
		room.minX + half, -- 5207
		math.min(room.maxX - half, nx) -- 5207
	) -- 5207
	local i = 0 -- 5208
	do -- 5208
		i = 0 -- 5209
		while i < #self.boxes do -- 5209
			do -- 5209
				local b = self.boxes[i + 1] -- 5210
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5211
					goto __continue886 -- 5212
				end -- 5212
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5214
					goto __continue886 -- 5215
				end -- 5215
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5217
					goto __continue886 -- 5218
				end -- 5218
				if nx + half > b.x0 and nx - half < b.x1 then -- 5220
					if a.x <= b.x0 then -- 5221
						nx = b.x0 - half -- 5222
					elseif a.x >= b.x1 then -- 5223
						nx = b.x1 + half -- 5224
					else -- 5224
						nx = a.x -- 5226
					end -- 5226
				end -- 5226
			end -- 5226
			::__continue886:: -- 5226
			i = i + 1 -- 5209
		end -- 5209
	end -- 5209
	if self.room.key == "outside" and not self.cartDocked and a.y < CART_CLEAR - 0.001 then -- 5232
		local bx0 = math.max(room.arch.x0, self.cartAxle - CART_HALF) -- 5233
		local bx1 = math.min(room.arch.x1, self.cartAxle + CART_HALF) -- 5234
		if bx1 > bx0 and nx + half > bx0 and nx - half < bx1 then -- 5235
			if a.x <= bx0 then -- 5236
				nx = bx0 - half -- 5237
			elseif a.x >= bx1 then -- 5238
				nx = bx1 + half -- 5239
			else -- 5239
				nx = a.x -- 5241
			end -- 5241
		end -- 5241
	end -- 5241
	local arch = room.arch -- 5249
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 5250
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 5251
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 5252
			if a.x <= arch.x0 then -- 5253
				nx = arch.x0 - half -- 5254
			elseif a.x >= arch.x1 then -- 5255
				nx = arch.x1 + half -- 5256
			end -- 5256
		end -- 5256
	end -- 5256
	a.x = nx -- 5260
end -- 5203
function Play.prototype.fallY(self, a, dt) -- 5264
	a.vy = a.vy - ____exports.GRAVITY * dt -- 5265
	if a.vy < -900 then -- 5266
		a.vy = -900 -- 5267
	end -- 5267
	local ny = a.y + a.vy * dt -- 5269
	local half = a.w / 2 -- 5270
	if a.vy <= 0 then -- 5271
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 5273
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 5274
		if ny <= ground then -- 5275
			ny = ground -- 5276
			a.vy = 0 -- 5277
			a.onGround = true -- 5278
		else -- 5278
			a.onGround = false -- 5280
		end -- 5280
	else -- 5280
		a.onGround = false -- 5283
		local i = 0 -- 5284
		do -- 5284
			i = 0 -- 5285
			while i < #self.boxes do -- 5285
				do -- 5285
					local b = self.boxes[i + 1] -- 5286
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5287
						goto __continue910 -- 5288
					end -- 5288
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5290
						goto __continue910 -- 5291
					end -- 5291
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 5293
						goto __continue910 -- 5294
					end -- 5294
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 5296
						ny = b.y0 - a.h -- 5297
						a.vy = 0 -- 5298
					end -- 5298
				end -- 5298
				::__continue910:: -- 5298
				i = i + 1 -- 5285
			end -- 5285
		end -- 5285
	end -- 5285
	a.y = ny -- 5302
end -- 5264
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 5306
	if depth == nil then -- 5306
		depth = 0 -- 5306
	end -- 5306
	local g = -9999 -- 5307
	local i = 0 -- 5308
	do -- 5308
		i = 0 -- 5309
		while i < #self.floors do -- 5309
			local f = self.floors[i + 1] -- 5310
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 5311
				g = f.y1 -- 5312
			end -- 5312
			i = i + 1 -- 5309
		end -- 5309
	end -- 5309
	do -- 5309
		i = 0 -- 5315
		while i < #self.boxes do -- 5315
			do -- 5315
				local b = self.boxes[i + 1] -- 5316
				if b.broken == true or b.hidden == true or b.soft == true then -- 5317
					goto __continue920 -- 5318
				end -- 5318
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 5320
					g = b.y1 -- 5322
				end -- 5322
			end -- 5322
			::__continue920:: -- 5322
			i = i + 1 -- 5315
		end -- 5315
	end -- 5315
	return g -- 5325
end -- 5306
function Play.prototype.updateCamera(self, dt) -- 5328
	local p = self.player -- 5329
	local tx = p.x + p.facing * 30 -- 5330
	local ty = p.y + CAM_LOOK_UP -- 5331
	local k = math.min(1, CAM_FOLLOW * dt) -- 5332
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 5333
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 5334
end -- 5328
function Play.prototype.clampCamera(self, w, h) -- 5338
	local room = self.room -- 5339
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 5340
	local spanX = room.maxX - room.minX -- 5341
	if spanX <= halfW * 2 then -- 5342
		self.cam.x = (room.minX + room.maxX) / 2 -- 5343
	else -- 5343
		self.cam.x = math.max( -- 5345
			room.minX + halfW, -- 5345
			math.min(room.maxX - halfW, self.cam.x) -- 5345
		) -- 5345
	end -- 5345
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 5348
	local spanY = room.height -- 5349
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 5350
	if spanY <= halfH * 2 then -- 5351
		self.cam.y = camY -- 5352
	else -- 5352
		self.cam.y = math.max( -- 5354
			camY, -- 5354
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 5354
		) -- 5354
	end -- 5354
end -- 5338
function Play.prototype.flashSet(self, text, t) -- 5358
	self.flash = text -- 5359
	self.flashT = t -- 5360
end -- 5358
function Play.prototype.statusText(self) -- 5364
	local p = self.player -- 5365
	local parts = {} -- 5366
	local who = self.childMode and "小满" or "周戍" -- 5367
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 5368
	if self.room.key == "prologue" then -- 5370
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5371
		if self.phase == "prologue-wake" then -- 5372
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 5373
		elseif self.phase == "prologue-shadow" then -- 5374
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 5375
		elseif self.phase == "prologue-escape" then -- 5376
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 5377
		elseif self.phase == "prologue-hide" then -- 5378
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 5379
		elseif self.phase == "prologue-wait" then -- 5380
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 5381
		elseif self.phase == "prologue-give" then -- 5382
			parts[#parts + 1] = (("递物 " .. tostring(self.phaseTick)) .. "/") .. tostring(____exports.PROLOGUE_GIVE_TICKS) -- 5383
		else -- 5383
			parts[#parts + 1] = "跟随" -- 5385
		end -- 5385
		if self.paused then -- 5387
			parts[#parts + 1] = "已暂停" -- 5388
		end -- 5388
		return table.concat(parts, " · ") -- 5390
	end -- 5390
	if self.room.key == "street" then -- 5392
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5393
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5394
		if self.paused then -- 5395
			parts[#parts + 1] = "已暂停" -- 5396
		end -- 5396
		return table.concat(parts, " · ") -- 5398
	end -- 5398
	if self.room.key == "gate" then -- 5400
		local ____temp_72 -- 5401
		if self.room.story == nil then -- 5401
			____temp_72 = nil -- 5401
		else -- 5401
			____temp_72 = self.room.story.gate -- 5401
		end -- 5401
		local g = ____temp_72 -- 5401
		if g ~= nil then -- 5402
			parts[#parts + 1] = self:gateLabel() -- 5403
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 5404
				0, -- 5405
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 5405
			))) .. " 秒" -- 5405
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5406
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5407
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 5408
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 5409
			if self.gateFailCount > 0 then -- 5410
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 5411
			end -- 5411
			if self.flash ~= "" then -- 5413
				parts[#parts + 1] = self.flash -- 5414
			end -- 5414
		end -- 5414
		if self.paused then -- 5417
			parts[#parts + 1] = "已暂停" -- 5418
		end -- 5418
		return table.concat(parts, " · ") -- 5420
	end -- 5420
	if self.room.key == "forest" then -- 5422
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5423
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5424
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5425
		if self.caughtT > 0 then -- 5426
			parts[#parts + 1] = "复位中" -- 5427
		end -- 5427
		if self.paused then -- 5429
			parts[#parts + 1] = "已暂停" -- 5430
		end -- 5430
		return table.concat(parts, " · ") -- 5432
	end -- 5432
	if self.room.key == "tower" then -- 5434
		if self.phase == "tower-wait" then -- 5435
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5436
		elseif self.phase == "tower-knock" then -- 5437
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5438
		elseif self.phase == "tower-enter" then -- 5439
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5440
		elseif self.phase == "tower-desk" then -- 5441
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5442
		elseif self.phase == "tower-given" then -- 5443
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5444
		else -- 5444
			parts[#parts + 1] = "片尾" -- 5446
		end -- 5446
		if self.paused then -- 5448
			parts[#parts + 1] = "已暂停" -- 5449
		end -- 5449
		return table.concat(parts, " · ") -- 5451
	end -- 5451
	if self.room.key == "village" then -- 5453
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5454
		if self.hasBottle then -- 5455
			parts[#parts + 1] = "有瓶" -- 5456
		elseif self.bottleFly ~= nil then -- 5457
			parts[#parts + 1] = "瓶在飞" -- 5458
		else -- 5458
			parts[#parts + 1] = "空手" -- 5460
		end -- 5460
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5462
		if self.scavChase then -- 5463
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5464
		end -- 5464
		if self.passed then -- 5466
			parts[#parts + 1] = "已过通行线" -- 5467
		end -- 5467
		if self.paused then -- 5469
			parts[#parts + 1] = "已暂停" -- 5470
		end -- 5470
		return table.concat(parts, " · ") -- 5472
	end -- 5472
	local isChild = self.childMode -- 5475
	if isChild then -- 5476
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5477
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5478
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5479
	else -- 5479
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5481
		if p.rollT > 0 then -- 5482
			parts[#parts + 1] = "翻滚中" -- 5483
		end -- 5483
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5485
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5486
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5487
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5488
	end -- 5488
	if self.checkpoint >= 0 then -- 5490
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5491
	end -- 5491
	if self.paused then -- 5493
		parts[#parts + 1] = "已暂停" -- 5494
	end -- 5494
	return table.concat(parts, " · ") -- 5496
end -- 5364
function Play.prototype.aliveEnemies(self) -- 5500
	local n = 0 -- 5501
	local i = 0 -- 5502
	do -- 5502
		i = 0 -- 5503
		while i < #self.enemies do -- 5503
			if self.enemies[i + 1].alive then -- 5504
				n = n + 1 -- 5505
			end -- 5505
			i = i + 1 -- 5503
		end -- 5503
	end -- 5503
	return n -- 5508
end -- 5500
function Play.prototype.threatened(self) -- 5513
	do -- 5513
		local i = 0 -- 5514
		while i < #self.enemies do -- 5514
			local e = self.enemies[i + 1] -- 5515
			if e.alive and e.warnT > 0 then -- 5516
				return true -- 5517
			end -- 5517
			i = i + 1 -- 5514
		end -- 5514
	end -- 5514
	return false -- 5520
end -- 5513
function Play.prototype.gateSecondsLeft(self) -- 5523
	local ____temp_73 -- 5524
	if self.room.story == nil then -- 5524
		____temp_73 = nil -- 5524
	else -- 5524
		____temp_73 = self.room.story.gate -- 5524
	end -- 5524
	local g = ____temp_73 -- 5524
	if g == nil then -- 5525
		return 0 -- 5526
	end -- 5526
	return math.max( -- 5528
		0, -- 5528
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5528
	) -- 5528
end -- 5523
function Play.prototype.gateLabel(self) -- 5531
	if self.phase == "gate-idle" then -- 5532
		return "待就位" -- 5533
	end -- 5533
	if self.phase == "gate-hold" then -- 5535
		return "守点中" -- 5536
	end -- 5536
	if self.phase == "gate-send" then -- 5538
		return "送别" -- 5539
	end -- 5539
	if self.phase == "gate-farewell" then -- 5541
		return "嘱咐 " .. tostring(self.phaseTick) -- 5542
	end -- 5542
	if self.phase == "gate-count" then -- 5544
		return "数数 " .. tostring(self.countTick) -- 5545
	end -- 5545
	return "她走" -- 5547
end -- 5531
function Play.prototype.dogLabel(self) -- 5551
	if self.dogState == "ear" then -- 5552
		return "转耳" -- 5553
	end -- 5553
	if self.dogState == "chase" then -- 5555
		return "追" -- 5556
	end -- 5556
	if self.dogState == "sniff" then -- 5558
		return "停" -- 5559
	end -- 5559
	if self.dogState == "back" then -- 5561
		return "回线" -- 5562
	end -- 5562
	return "巡逻" -- 5564
end -- 5551
function Play.prototype.doorXOf(self) -- 5567
	local ____temp_74 -- 5568
	if self.room.story == nil then -- 5568
		____temp_74 = nil -- 5568
	else -- 5568
		____temp_74 = self.room.story.tower -- 5568
	end -- 5568
	local t = ____temp_74 -- 5568
	return t == nil and 0 or t.doorX -- 5569
end -- 5567
function Play.prototype.scavLabel(self) -- 5573
	if self.scavState == "chase" then -- 5574
		return "追" -- 5575
	end -- 5575
	if self.scavState == "turn" then -- 5577
		return "转头" -- 5578
	end -- 5578
	if self.scavState == "walk" then -- 5580
		return "赶来" -- 5581
	end -- 5581
	if self.scavState == "stall" then -- 5583
		return "停住" -- 5584
	end -- 5584
	if self.scavState == "back" then -- 5586
		return "回位" -- 5587
	end -- 5587
	return "巡逻" -- 5589
end -- 5573
function Play.prototype.hintText(self) -- 5593
	if self.paused then -- 5594
		return "Esc 继续 · R 重置" -- 5595
	end -- 5595
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5599
		if self:threatened() then -- 5600
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5601
		end -- 5601
		if self.coverHug then -- 5603
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5604
		end -- 5604
		if self.coverNear then -- 5606
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5607
		end -- 5607
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5609
	end -- 5609
	if self.flash ~= "" then -- 5611
		return self.flash -- 5612
	end -- 5612
	if self.room.key == "prologue" then -- 5614
		if self.phase == "prologue-wake" then -- 5615
			return "父亲在门外唤 · 小满睁眼" -- 5616
		end -- 5616
		if self.phase == "prologue-shadow" then -- 5618
			return "墙上两道人影 · 碗滚到脚边" -- 5619
		end -- 5619
		if self.phase == "prologue-escape" then -- 5621
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5622
		end -- 5622
		if self.phase == "prologue-hide" then -- 5624
			return "柜门合上 · 屏住呼吸" -- 5625
		end -- 5625
		if self.phase == "prologue-wait" then -- 5627
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5628
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5629
		end -- 5629
		if self.phase == "prologue-give" then -- 5631
			return ((("递物 " .. tostring(self.phaseTick)) .. " / ") .. tostring(____exports.PROLOGUE_GIVE_TICKS)) .. " 拍 · 站着别动" -- 5632
		end -- 5632
		return "她跟着你了 · 两人一起走到门口 680" -- 5634
	end -- 5634
	if self.room.key == "street" then -- 5636
		if self:aliveEnemies() > 0 then -- 5637
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5638
		end -- 5638
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5640
	end -- 5640
	if self.room.key == "gate" then -- 5642
		local ____temp_75 -- 5643
		if self.room.story == nil then -- 5643
			____temp_75 = nil -- 5643
		else -- 5643
			____temp_75 = self.room.story.gate -- 5643
		end -- 5643
		local g = ____temp_75 -- 5643
		if g ~= nil then -- 5644
			if self.phase == "gate-idle" then -- 5645
				if self.gateNeedConfirm then -- 5646
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5647
				end -- 5647
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5649
			end -- 5649
			if self.phase == "gate-hold" then -- 5651
				if self.coveredFlash > 0 then -- 5652
					return "掩体挡下了这一枪 · 别露头" -- 5653
				end -- 5653
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5655
			end -- 5655
			if self.phase == "gate-send" then -- 5657
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5658
			end -- 5658
			if self.phase == "gate-farewell" then -- 5660
				return "城门送别 · 嘱咐她慢慢数到二十" -- 5661
			end -- 5661
			if self.phase == "gate-count" then -- 5663
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5664
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5665
				end -- 5665
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5667
			end -- 5667
			return "她自己走 · 跟着出城门 1120" -- 5669
		end -- 5669
	end -- 5669
	if self.room.key == "forest" then -- 5672
		if self.dogState == "chase" then -- 5673
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5674
		end -- 5674
		if self.dogState == "ear" then -- 5676
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5677
		end -- 5677
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5679
	end -- 5679
	if self.room.key == "tower" then -- 5681
		if self.phase == "tower-wait" then -- 5682
			return "走到门前 445 点一次 E 敲两下" -- 5683
		end -- 5683
		if self.phase == "tower-knock" then -- 5685
			return "敲两下 · 等门开" -- 5686
		end -- 5686
		if self.phase == "tower-given" then -- 5688
			return "递交针套和纸条 · 看登记簿最后一行" -- 5689
		end -- 5689
		return "片尾 · 点 E 再玩一次，回到序章" -- 5691
	end -- 5691
	if self.room.key == "village" then -- 5693
		if self.bottleFly ~= nil then -- 5694
			return "等瓶子落地 · 触地才发声" -- 5695
		end -- 5695
		if self.hasBottle then -- 5697
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5698
		end -- 5698
		if self.passed then -- 5700
			return "已过第一院 · R 重置可再来一遍" -- 5701
		end -- 5701
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5703
	end -- 5703
	if self.room.key == "outside" then -- 5705
		if self.focusCart then -- 5706
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5707
		end -- 5707
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5709
	end -- 5709
	if self.escort.state == "frozen" then -- 5711
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5712
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5713
		end -- 5713
		return "小满吓住了 · 走过去，靠近再点 E" -- 5715
	end -- 5715
	if self.escort.state == "calming" then -- 5717
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5718
	end -- 5718
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5720
end -- 5593
function Play.prototype.draw(self, draw, w, h) -- 5725
	self.viewW = w -- 5726
	self.viewH = h -- 5727
	self.view = ____exports.computeViewport(w, h) -- 5728
	self:clampCamera(w, h) -- 5729
	draw:clear() -- 5730
	draw:drawRect( -- 5732
		Rect(0, 0, w, h), -- 5732
		BG_VOID -- 5732
	) -- 5732
	local box = self:canvasRect(w, h) -- 5733
	draw:drawRect(box, BG_FAR) -- 5734
	draw:drawRect( -- 5735
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 5735
		BG_MID -- 5735
	) -- 5735
	self:drawFloors(draw, w, h) -- 5737
	self:drawSolids(draw, w, h) -- 5738
	self:drawZones(draw, w, h) -- 5739
	self:drawArch(draw, w, h) -- 5740
	self:drawCart(draw, w, h) -- 5741
	self:drawCampaignProps(draw, w, h) -- 5742
	self:drawActors(draw, w, h) -- 5743
	self:drawTrace(draw, w, h) -- 5744
	self:drawAim(draw, w, h) -- 5745
end -- 5725
function Play.prototype.canvasRect(self, w, h) -- 5749
	local v = self.view -- 5750
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 5751
end -- 5749
function Play.prototype.px(self, n) -- 5755
	return n * self.view.zoom -- 5756
end -- 5755
function Play.prototype.sx(self, wx, w) -- 5760
	local v = self.view -- 5761
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 5762
	return v.ox + lx * v.zoom -- 5763
end -- 5760
function Play.prototype.sy(self, wy, h) -- 5767
	local v = self.view -- 5768
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 5769
	return v.oy + ly * v.zoom -- 5770
end -- 5767
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 5773
	local px0 = self:sx(x0, w) -- 5774
	local px1 = self:sx(x1, w) -- 5775
	local py0 = self:sy(y0, h) -- 5776
	local py1 = self:sy(y1, h) -- 5777
	if px1 <= px0 or py1 <= py0 then -- 5778
		return -- 5779
	end -- 5779
	draw:drawRect( -- 5781
		Rect(px0, py0, px1 - px0, py1 - py0), -- 5781
		color -- 5781
	) -- 5781
end -- 5773
function Play.prototype.drawFloors(self, draw, w, h) -- 5784
	local i = 0 -- 5785
	do -- 5785
		i = 0 -- 5786
		while i < #self.room.floors do -- 5786
			local f = self.room.floors[i + 1] -- 5787
			local ____temp_76 -- 5788
			if f.y == 0 then -- 5788
				____temp_76 = self.room.depth -- 5788
			else -- 5788
				____temp_76 = nil -- 5788
			end -- 5788
			local road = ____temp_76 -- 5788
			local y = self:sy(f.y + (road and road.min or 0), h) -- 5789
			local x0 = self:sx(f.x0, w) -- 5790
			local x1 = self:sx(f.x1, w) -- 5791
			local deck = self:px(5) -- 5792
			if road ~= nil then -- 5793
				local back = self:sy(f.y + road.max, h) -- 5794
				draw:drawRect( -- 5795
					Rect(x0, y, x1 - x0, back - y), -- 5795
					FLOOR_DECK, -- 5795
					self:px(1), -- 5795
					SOLID_EDGE -- 5795
				) -- 5795
			end -- 5795
			draw:drawRect( -- 5797
				Rect(x0, y - deck, x1 - x0, deck), -- 5797
				FLOOR_DECK -- 5797
			) -- 5797
			draw:drawSegment( -- 5798
				Vec2(x0, y), -- 5798
				Vec2(x1, y), -- 5798
				self:px(1), -- 5798
				GROUND -- 5798
			) -- 5798
			i = i + 1 -- 5786
		end -- 5786
	end -- 5786
end -- 5784
function Play.prototype.drawSolids(self, draw, w, h) -- 5802
	local i = 0 -- 5803
	do -- 5803
		i = 0 -- 5804
		while i < #self.boxes do -- 5804
			do -- 5804
				local b = self.boxes[i + 1] -- 5805
				if b.id == "braced_shield" or b.hidden == true then -- 5806
					goto __continue1053 -- 5807
				end -- 5807
				if b.broken == true then -- 5809
					if b.breakable ~= nil then -- 5811
						local gy = self:sy(b.y0, h) -- 5812
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 5813
						local k = 0 -- 5814
						do -- 5814
							k = 0 -- 5815
							while k < 3 do -- 5815
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 5816
								draw:drawSegment( -- 5817
									Vec2( -- 5817
										gx - self:px(4), -- 5817
										gy + self:px(k % 2) -- 5817
									), -- 5817
									Vec2( -- 5817
										gx + self:px(5), -- 5817
										gy + self:px(k % 2) -- 5817
									), -- 5817
									self:px(1), -- 5817
									rgb -- 5817
								) -- 5817
								k = k + 1 -- 5815
							end -- 5815
						end -- 5815
					end -- 5815
					goto __continue1053 -- 5820
				end -- 5820
				local ____opt_79 = b.depth -- 5822
				local front = ____opt_79 and ____opt_79.min or 0 -- 5822
				local ____opt_81 = b.depth -- 5823
				local back = ____opt_81 and ____opt_81.max or 0 -- 5823
				local fill = SOLID_FILL -- 5824
				local line = SOLID_EDGE -- 5825
				if b.soft == true then -- 5826
					fill = SOFT -- 5827
					line = SOFT_LINE -- 5828
				elseif b.breakable ~= nil then -- 5829
					line = DANGER_LINE -- 5830
					fill = Color(0.3, 0.24, 0.16, 1) -- 5831
				elseif b.interact ~= nil then -- 5832
					line = PASS_LINE -- 5833
				end -- 5833
				self:drawBox( -- 5835
					draw, -- 5835
					w, -- 5835
					h, -- 5835
					b.x0, -- 5835
					b.x1, -- 5835
					b.y0 + front, -- 5835
					b.y1 + back, -- 5835
					fill -- 5835
				) -- 5835
				draw:drawSegment( -- 5836
					Vec2( -- 5836
						self:sx(b.x0, w), -- 5836
						self:sy(b.y1 + front, h) -- 5836
					), -- 5836
					Vec2( -- 5837
						self:sx(b.x1, w), -- 5837
						self:sy(b.y1 + front, h) -- 5837
					), -- 5837
					self:px(1), -- 5837
					line -- 5837
				) -- 5837
				if b.breakable ~= nil then -- 5839
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 5840
					local cyp = self:sy(b.y1 + front, h) -- 5841
					draw:drawSegment( -- 5842
						Vec2( -- 5842
							cxp - self:px(4), -- 5842
							cyp + self:px(1) -- 5842
						), -- 5842
						Vec2( -- 5842
							cxp + self:px(3), -- 5842
							cyp + self:px(5) -- 5842
						), -- 5842
						self:px(1), -- 5842
						line -- 5842
					) -- 5842
				end -- 5842
			end -- 5842
			::__continue1053:: -- 5842
			i = i + 1 -- 5804
		end -- 5804
	end -- 5804
end -- 5802
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 5848
	local i = 0 -- 5849
	do -- 5849
		i = 0 -- 5850
		while i < #self.pickups do -- 5850
			do -- 5850
				local pk = self.pickups[i + 1] -- 5851
				if self.run.taken[pk.id] == true then -- 5852
					goto __continue1065 -- 5853
				end -- 5853
				local gy = pk.y + (pk.depth or 0) -- 5855
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 5856
				draw:drawRect( -- 5857
					Rect( -- 5857
						self:sx(pk.x - 5, w), -- 5857
						self:sy(gy + 12 + bob, h), -- 5857
						self:px(10), -- 5857
						self:px(10) -- 5857
					), -- 5857
					Color(0.84, 0.7, 0.3, 1) -- 5858
				) -- 5858
				draw:drawSegment( -- 5859
					Vec2( -- 5859
						self:sx(pk.x - 5, w), -- 5859
						self:sy(gy + 12 + bob, h) -- 5859
					), -- 5859
					Vec2( -- 5860
						self:sx(pk.x + 5, w), -- 5860
						self:sy(gy + 12 + bob, h) -- 5860
					), -- 5860
					self:px(1), -- 5860
					Color(0.95, 0.86, 0.52, 1) -- 5860
				) -- 5860
			end -- 5860
			::__continue1065:: -- 5860
			i = i + 1 -- 5850
		end -- 5850
	end -- 5850
	if self.bracedShield ~= nil then -- 5862
		local sh = self.bracedShield -- 5863
		draw:drawRect( -- 5864
			Rect( -- 5864
				self:sx(sh.x - sh.w / 2, w), -- 5864
				self:sy(sh.y, h), -- 5864
				self:px(sh.w), -- 5864
				self:px(sh.h) -- 5864
			), -- 5864
			Color(0.42, 0.4, 0.34, 1) -- 5865
		) -- 5865
		draw:drawSegment( -- 5866
			Vec2( -- 5866
				self:sx(sh.x - sh.w / 2, w), -- 5866
				self:sy(sh.y + sh.h, h) -- 5866
			), -- 5866
			Vec2( -- 5867
				self:sx(sh.x + sh.w / 2, w), -- 5867
				self:sy(sh.y + sh.h, h) -- 5867
			), -- 5867
			self:px(1), -- 5867
			Color(0.74, 0.72, 0.62, 1) -- 5867
		) -- 5867
	end -- 5867
end -- 5848
function Play.prototype.drawZones(self, draw, w, h) -- 5871
	local i = 0 -- 5872
	do -- 5872
		i = 0 -- 5873
		while i < #self.room.zones do -- 5873
			local z = self.room.zones[i + 1] -- 5874
			local fill = DANGER -- 5875
			local line = DANGER_LINE -- 5876
			if z.tint == 2 then -- 5877
				fill = SOFT -- 5878
				line = SOFT_LINE -- 5879
			elseif z.tint == 3 then -- 5880
				fill = BRICK -- 5881
				line = BRICK_LINE -- 5882
			elseif z.tint == 4 then -- 5883
				fill = PASS -- 5884
				line = PASS_LINE -- 5885
			end -- 5885
			self:drawBox( -- 5887
				draw, -- 5887
				w, -- 5887
				h, -- 5887
				z.x0, -- 5887
				z.x1, -- 5887
				z.y, -- 5887
				z.y + z.h, -- 5887
				fill -- 5887
			) -- 5887
			draw:drawSegment( -- 5888
				Vec2( -- 5888
					self:sx(z.x0, w), -- 5888
					self:sy(z.y, h) -- 5888
				), -- 5888
				Vec2( -- 5888
					self:sx(z.x0, w), -- 5888
					self:sy(z.y + z.h, h) -- 5888
				), -- 5888
				self:px(1), -- 5888
				line -- 5888
			) -- 5888
			draw:drawSegment( -- 5889
				Vec2( -- 5889
					self:sx(z.x1, w), -- 5889
					self:sy(z.y, h) -- 5889
				), -- 5889
				Vec2( -- 5889
					self:sx(z.x1, w), -- 5889
					self:sy(z.y + z.h, h) -- 5889
				), -- 5889
				self:px(1), -- 5889
				line -- 5889
			) -- 5889
			i = i + 1 -- 5873
		end -- 5873
	end -- 5873
end -- 5871
function Play.prototype.drawArch(self, draw, w, h) -- 5893
	local a = self.room.arch -- 5894
	if a.h <= 0 then -- 5895
		return -- 5896
	end -- 5896
	self:drawBox( -- 5898
		draw, -- 5898
		w, -- 5898
		h, -- 5898
		a.x0, -- 5898
		a.x1, -- 5898
		a.y, -- 5898
		a.y + a.h, -- 5898
		HOLE_FILL -- 5898
	) -- 5898
	draw:drawSegment( -- 5899
		Vec2( -- 5899
			self:sx(a.x0, w), -- 5899
			self:sy(a.y + a.h, h) -- 5899
		), -- 5899
		Vec2( -- 5899
			self:sx(a.x1, w), -- 5899
			self:sy(a.y + a.h, h) -- 5899
		), -- 5899
		self:px(1), -- 5899
		SOLID_EDGE -- 5899
	) -- 5899
	draw:drawSegment( -- 5900
		Vec2( -- 5900
			self:sx(a.x0, w), -- 5900
			self:sy(a.y, h) -- 5900
		), -- 5900
		Vec2( -- 5900
			self:sx(a.x0, w), -- 5900
			self:sy(a.y + a.h, h) -- 5900
		), -- 5900
		self:px(1), -- 5900
		SOLID_EDGE -- 5900
	) -- 5900
	draw:drawSegment( -- 5901
		Vec2( -- 5901
			self:sx(a.x1, w), -- 5901
			self:sy(a.y, h) -- 5901
		), -- 5901
		Vec2( -- 5901
			self:sx(a.x1, w), -- 5901
			self:sy(a.y + a.h, h) -- 5901
		), -- 5901
		self:px(1), -- 5901
		SOLID_EDGE -- 5901
	) -- 5901
end -- 5893
function Play.prototype.drawCart(self, draw, w, h) -- 5904
	local c = self.room.cart -- 5905
	if c.bodyW <= 0 then -- 5906
		return -- 5907
	end -- 5907
	drawCartShape( -- 5909
		draw, -- 5909
		self, -- 5909
		w, -- 5909
		h, -- 5909
		c, -- 5909
		self.cartAxle -- 5909
	) -- 5909
	draw:drawRect( -- 5910
		Rect( -- 5910
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 5910
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 5910
			self:px(2), -- 5910
			self:px(40) -- 5910
		), -- 5910
		STAND -- 5910
	) -- 5910
end -- 5904
function Play.prototype.drawActors(self, draw, w, h) -- 5913
	local p = self.player -- 5914
	local isChild = self.childMode -- 5915
	local footY = p.y + p.depth * DEPTH_Y_SCALE -- 5916
	if p.covered then -- 5918
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 5919
		draw:drawSegment( -- 5920
			Vec2( -- 5920
				self:sx(edge, w), -- 5920
				self:sy(footY + 8, h) -- 5920
			), -- 5920
			Vec2( -- 5920
				self:sx(edge, w), -- 5920
				self:sy(footY + p.h * 0.62, h) -- 5920
			), -- 5920
			self:px(2), -- 5920
			STAND -- 5920
		) -- 5920
		draw:drawSegment( -- 5922
			Vec2( -- 5922
				self:sx(p.x - 8, w), -- 5922
				self:sy(footY + p.h + 3, h) -- 5922
			), -- 5922
			Vec2( -- 5922
				self:sx(p.x + 8, w), -- 5922
				self:sy(footY + p.h + 3, h) -- 5922
			), -- 5922
			self:px(2), -- 5922
			STAND -- 5922
		) -- 5922
	elseif self.coverNear and not isChild then -- 5923
		draw:drawRect( -- 5925
			Rect( -- 5925
				self:sx(p.x - 3, w), -- 5925
				self:sy(footY + 1, h), -- 5925
				self:px(3), -- 5925
				self:px(3) -- 5925
			), -- 5925
			STAND -- 5925
		) -- 5925
	end -- 5925
	drawFigure( -- 5927
		draw, -- 5927
		self, -- 5927
		w, -- 5927
		h, -- 5927
		p, -- 5927
		isChild and CHILD_BODY or SOLDIER_BODY, -- 5927
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 5927
	) -- 5927
	local q = self.partner -- 5928
	if q.alive then -- 5929
		local childPartner = q.w == CHILD_W -- 5930
		drawFigure( -- 5931
			draw, -- 5931
			self, -- 5931
			w, -- 5931
			h, -- 5931
			q, -- 5931
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 5931
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 5931
		) -- 5931
	end -- 5931
	local i = 0 -- 5933
	do -- 5933
		i = 0 -- 5934
		while i < #self.enemies do -- 5934
			local e = self.enemies[i + 1] -- 5935
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 5936
			local enemyY = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 5937
			self:drawBox( -- 5938
				draw, -- 5938
				w, -- 5938
				h, -- 5938
				e.x - e.w / 2, -- 5938
				e.x + e.w / 2, -- 5938
				enemyY, -- 5938
				enemyY + e.h, -- 5938
				col -- 5938
			) -- 5938
			if e.alive then -- 5939
				local ef = p.x >= e.x and 1 or -1 -- 5940
				if e.kind == "shield" then -- 5941
					local sh = (e.shieldHp or 0) > 0 -- 5942
					draw:drawRect( -- 5943
						Rect( -- 5943
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 5943
							self:sy(enemyY, h), -- 5943
							self:px(6), -- 5943
							self:px(64) -- 5943
						), -- 5943
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 5944
					) -- 5944
				elseif e.kind == "breaker" then -- 5945
					draw:drawSegment( -- 5946
						Vec2( -- 5946
							self:sx(e.x + ef * 12, w), -- 5946
							self:sy(enemyY + 8, h) -- 5946
						), -- 5946
						Vec2( -- 5947
							self:sx(e.x + ef * 22, w), -- 5947
							self:sy(enemyY + 46, h) -- 5947
						), -- 5947
						self:px(3), -- 5947
						Color(0.5, 0.36, 0.22, 1) -- 5947
					) -- 5947
				end -- 5947
			end -- 5947
			if e.alive and e.warnT > 0 then -- 5951
				local gunX = self:sx(e.x, w) -- 5952
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 5953
				local aimX = self:sx(p.x, w) -- 5954
				local aimY = self:sy(footY + p.h * 0.55, h) -- 5955
				local seg = 8 -- 5956
				local s = 0 -- 5957
				do -- 5957
					s = 0 -- 5958
					while s < seg do -- 5958
						local t0 = s / seg -- 5959
						local t1 = (s + 1) / seg -- 5960
						draw:drawSegment( -- 5961
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 5962
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 5963
							self:px(1), -- 5964
							DANGER -- 5964
						) -- 5964
						s = s + 2 -- 5958
					end -- 5958
				end -- 5958
			end -- 5958
			i = i + 1 -- 5934
		end -- 5934
	end -- 5934
	local k = 0 -- 5969
	do -- 5969
		k = 0 -- 5970
		while k < #self.room.marks do -- 5970
			do -- 5970
				local m = self.room.marks[k + 1] -- 5971
				if m.kind ~= 0 then -- 5972
					goto __continue1091 -- 5973
				end -- 5973
				local on = self.checkpoint == m.x -- 5975
				local x = self:sx(m.x, w) -- 5976
				local y = self:sy(m.y, h) -- 5977
				draw:drawSegment( -- 5978
					Vec2(x, y), -- 5978
					Vec2( -- 5978
						x, -- 5978
						y + self:px(35) -- 5978
					), -- 5978
					self:px(1), -- 5978
					on and CHECK or INK_DIM -- 5978
				) -- 5978
				draw:drawDot( -- 5979
					Vec2( -- 5979
						x, -- 5979
						y + self:px(35) -- 5979
					), -- 5979
					self:px(2), -- 5979
					on and CHECK or INK_DIM -- 5979
				) -- 5979
			end -- 5979
			::__continue1091:: -- 5979
			k = k + 1 -- 5970
		end -- 5970
	end -- 5970
	local j = 0 -- 5983
	do -- 5983
		j = 0 -- 5984
		while j < #self.room.marks do -- 5984
			do -- 5984
				local m = self.room.marks[j + 1] -- 5985
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 5986
					goto __continue1094 -- 5987
				end -- 5987
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 5989
					goto __continue1094 -- 5991
				end -- 5991
				local col = STAND -- 5993
				if m.kind == 4 then -- 5994
					col = PASS_LINE -- 5995
				elseif m.kind == 5 then -- 5996
					col = BRICK_LINE -- 5997
				end -- 5997
				local mx = self:sx(m.x, w) -- 5999
				local my = self:sy(m.y, h) -- 6000
				draw:drawSegment( -- 6001
					Vec2(mx, my), -- 6001
					Vec2( -- 6001
						mx, -- 6001
						my + self:px(24) -- 6001
					), -- 6001
					self:px(1), -- 6001
					col -- 6001
				) -- 6001
			end -- 6001
			::__continue1094:: -- 6001
			j = j + 1 -- 5984
		end -- 5984
	end -- 5984
	local t = 0 -- 6004
	do -- 6004
		t = 0 -- 6005
		while t < #self.room.marks do -- 6005
			do -- 6005
				local m = self.room.marks[t + 1] -- 6006
				if m.kind ~= 6 then -- 6007
					goto __continue1100 -- 6008
				end -- 6008
				local mx = self:sx(m.x, w) -- 6010
				local my = self:sy(m.y, h) -- 6011
				draw:drawSegment( -- 6012
					Vec2(mx, my), -- 6012
					Vec2( -- 6012
						mx, -- 6012
						my + self:px(30) -- 6012
					), -- 6012
					self:px(1), -- 6012
					INK_DIM -- 6012
				) -- 6012
				self:drawBox( -- 6013
					draw, -- 6013
					w, -- 6013
					h, -- 6013
					m.x - 5, -- 6013
					m.x + 5, -- 6013
					m.y + 30, -- 6013
					m.y + 40, -- 6013
					CHECK -- 6013
				) -- 6013
			end -- 6013
			::__continue1100:: -- 6013
			t = t + 1 -- 6005
		end -- 6005
	end -- 6005
	if self.room.key == "village" then -- 6015
		self:drawVillage(draw, w, h) -- 6016
	end -- 6016
	if self.room.key == "forest" then -- 6018
		self:drawDog(draw, w, h) -- 6019
	end -- 6019
end -- 5913
function Play.prototype.drawDog(self, draw, w, h) -- 6024
	local x = self.dogX -- 6025
	self:drawBox( -- 6026
		draw, -- 6026
		w, -- 6026
		h, -- 6026
		x - 14, -- 6026
		x + 14, -- 6026
		0, -- 6026
		20, -- 6026
		SCAV_BODY -- 6026
	) -- 6026
	self:drawBox( -- 6027
		draw, -- 6027
		w, -- 6027
		h, -- 6027
		x - 10, -- 6027
		x - 2, -- 6027
		20, -- 6027
		30, -- 6027
		SCAV_BODY -- 6027
	) -- 6027
	self:drawBox( -- 6028
		draw, -- 6028
		w, -- 6028
		h, -- 6028
		x + 2, -- 6028
		x + 10, -- 6028
		20, -- 6028
		30, -- 6028
		SCAV_HEAD -- 6028
	) -- 6028
	if self.dogState == "ear" or self.dogState == "chase" then -- 6029
		draw:drawSegment( -- 6030
			Vec2( -- 6030
				self:sx(x, w), -- 6030
				self:sy(30, h) -- 6030
			), -- 6030
			Vec2( -- 6031
				self:sx(x, w), -- 6031
				self:sy(40, h) -- 6031
			), -- 6031
			self:px(1), -- 6031
			DANGER -- 6031
		) -- 6031
	end -- 6031
end -- 6024
function Play.prototype.drawVillage(self, draw, w, h) -- 6036
	local bottle = self.room.bottle -- 6037
	if bottle ~= nil then -- 6038
		self:drawBox( -- 6039
			draw, -- 6039
			w, -- 6039
			h, -- 6039
			bottle.x - 14, -- 6039
			bottle.x + 14, -- 6039
			0, -- 6039
			64, -- 6039
			SOLID_FILL -- 6039
		) -- 6039
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 6040
			self:drawBottle( -- 6041
				draw, -- 6041
				w, -- 6041
				h, -- 6041
				bottle.x, -- 6041
				64 -- 6041
			) -- 6041
		end -- 6041
	end -- 6041
	self:drawBox( -- 6045
		draw, -- 6045
		w, -- 6045
		h, -- 6045
		300, -- 6045
		420, -- 6045
		44, -- 6045
		50, -- 6045
		FLOOR_DECK -- 6045
	) -- 6045
	self:drawBox( -- 6046
		draw, -- 6046
		w, -- 6046
		h, -- 6046
		300, -- 6046
		306, -- 6046
		0, -- 6046
		44, -- 6046
		FLOOR_DECK -- 6046
	) -- 6046
	self:drawBox( -- 6047
		draw, -- 6047
		w, -- 6047
		h, -- 6047
		414, -- 6047
		420, -- 6047
		0, -- 6047
		44, -- 6047
		FLOOR_DECK -- 6047
	) -- 6047
	local s = self.room.scavenger -- 6049
	if s ~= nil then -- 6050
		local sx0 = self.scavX -- 6051
		self:drawBox( -- 6052
			draw, -- 6052
			w, -- 6052
			h, -- 6052
			sx0 - 12, -- 6052
			sx0 + 12, -- 6052
			0, -- 6052
			s.h - 14, -- 6052
			SCAV_BODY -- 6052
		) -- 6052
		self:drawBox( -- 6053
			draw, -- 6053
			w, -- 6053
			h, -- 6053
			sx0 - 7, -- 6053
			sx0 + 7, -- 6053
			s.h - 14, -- 6053
			s.h, -- 6053
			SCAV_HEAD -- 6053
		) -- 6053
		if self.scavState == "turn" then -- 6054
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 6055
			draw:drawSegment( -- 6056
				Vec2( -- 6056
					self:sx(sx0, w), -- 6056
					self:sy(s.h - 6, h) -- 6056
				), -- 6056
				Vec2( -- 6056
					self:sx(fx, w), -- 6056
					self:sy(s.h - 6, h) -- 6056
				), -- 6056
				self:px(1), -- 6056
				INK -- 6056
			) -- 6056
		end -- 6056
	end -- 6056
	if self.hasBottle then -- 6060
		local p = self.player -- 6061
		self:drawBottle( -- 6062
			draw, -- 6062
			w, -- 6062
			h, -- 6062
			p.x + p.facing * 10, -- 6062
			p.y + p.h * 0.62 -- 6062
		) -- 6062
	end -- 6062
	if self.bottleFly ~= nil then -- 6064
		self:drawBottle( -- 6065
			draw, -- 6065
			w, -- 6065
			h, -- 6065
			self.bottleFly.x, -- 6065
			self.bottleFly.y -- 6065
		) -- 6065
	end -- 6065
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 6067
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 6068
		draw:drawCircle( -- 6069
			Vec2( -- 6069
				self:sx(self.bottleLandX, w), -- 6069
				self:sy(0, h) -- 6069
			), -- 6069
			self:px(r / ____exports.UNITS_PER_PX), -- 6069
			BRICK_LINE -- 6069
		) -- 6069
	end -- 6069
end -- 6036
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 6073
	self:drawBox( -- 6074
		draw, -- 6074
		w, -- 6074
		h, -- 6074
		x - 3, -- 6074
		x + 3, -- 6074
		y - 10, -- 6074
		y, -- 6074
		BOTTLE -- 6074
	) -- 6074
end -- 6073
function Play.prototype.drawTrace(self, draw, w, h) -- 6077
	local t = self.trace -- 6078
	if t == nil or self.traceT <= 0 then -- 6079
		return -- 6080
	end -- 6080
	draw:drawSegment( -- 6082
		Vec2( -- 6083
			self:sx(t.x0, w), -- 6083
			self:sy(t.y0, h) -- 6083
		), -- 6083
		Vec2( -- 6084
			self:sx(t.x1, w), -- 6084
			self:sy(t.y1, h) -- 6084
		), -- 6084
		self:px(1), -- 6085
		t.hit and AIM_HIT or INK_DIM -- 6085
	) -- 6085
end -- 6077
function Play.prototype.drawAim(self, draw, w, h) -- 6088
	local v = self.view -- 6090
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 6091
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 6092
	local dot = self:px(1) -- 6093
	local arm = self:px(3) -- 6094
	local gap = self:px(1) -- 6095
	draw:drawSegment( -- 6096
		Vec2(gx - arm - gap, gy), -- 6096
		Vec2(gx - gap, gy), -- 6096
		dot / 2, -- 6096
		AIM -- 6096
	) -- 6096
	draw:drawSegment( -- 6097
		Vec2(gx + gap, gy), -- 6097
		Vec2(gx + arm + gap, gy), -- 6097
		dot / 2, -- 6097
		AIM -- 6097
	) -- 6097
	draw:drawSegment( -- 6098
		Vec2(gx, gy - arm - gap), -- 6098
		Vec2(gx, gy - gap), -- 6098
		dot / 2, -- 6098
		AIM -- 6098
	) -- 6098
	draw:drawSegment( -- 6099
		Vec2(gx, gy + gap), -- 6099
		Vec2(gx, gy + arm + gap), -- 6099
		dot / 2, -- 6099
		AIM -- 6099
	) -- 6099
	if self.room.key == "village" and self.hasBottle then -- 6102
		local p = self.player -- 6103
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 6105
		local dir = ____end.x >= p.x and 1 or -1 -- 6106
		local x0 = p.x + dir * 10 -- 6107
		local y0 = p.y + p.h * 0.7 -- 6108
		local T = BOTTLE_FLY_TIME -- 6109
		local vx = (____end.x - x0) / T -- 6110
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 6111
		local pxr = x0 -- 6112
		local pyr = y0 -- 6113
		local t = 1 -- 6114
		do -- 6114
			t = 1 -- 6115
			while t <= 12 do -- 6115
				local tt = t / 12 * T -- 6116
				local nx = x0 + vx * tt -- 6117
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 6118
				draw:drawSegment( -- 6119
					Vec2( -- 6119
						self:sx(pxr, w), -- 6119
						self:sy(pyr, h) -- 6119
					), -- 6119
					Vec2( -- 6119
						self:sx(nx, w), -- 6119
						self:sy(ny, h) -- 6119
					), -- 6119
					self:px(1) / 2, -- 6119
					BOTTLE -- 6119
				) -- 6119
				pxr = nx -- 6120
				pyr = ny -- 6121
				t = t + 1 -- 6115
			end -- 6115
		end -- 6115
		draw:drawCircle( -- 6123
			Vec2( -- 6123
				self:sx(____end.x, w), -- 6123
				self:sy(____end.y + 2, h) -- 6123
			), -- 6123
			self:px(2), -- 6123
			BOTTLE -- 6123
		) -- 6123
	end -- 6123
end -- 6088
return ____exports -- 6088
