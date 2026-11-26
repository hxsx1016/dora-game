-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
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
local CRAFT_RECIPES = ____craft.CRAFT_RECIPES -- 29
local findRecipe = ____craft.findRecipe -- 29
local missingMaterials = ____craft.missingMaterials -- 29
local payMaterials = ____craft.payMaterials -- 29
local weaponEffectOf = ____craft.weaponEffectOf -- 29
local weaponNameOf = ____craft.weaponNameOf -- 29
function makeActor(room, index) -- 5193
	local sp = room.spawns -- 5194
	if index < 0 or index >= #sp then -- 5194
		return { -- 5196
			x = 0, -- 5196
			y = 0, -- 5196
			depth = 0, -- 5196
			depthSpeed = 0, -- 5196
			vx = 0, -- 5196
			vy = 0, -- 5196
			w = CHILD_W, -- 5196
			h = CHILD_H, -- 5196
			onGround = true, -- 5196
			facing = 1, -- 5196
			crouch = false, -- 5196
			rollT = 0, -- 5196
			covered = false, -- 5196
			alive = false -- 5196
		} -- 5196
	end -- 5196
	local s = sp[index + 1] -- 5198
	local child = s.h <= CHILD_H -- 5199
	local ground = room.depth -- 5200
	local depth = ground == nil and 0 or math.max( -- 5201
		ground.min, -- 5201
		math.min(ground.max, s.depth or 0) -- 5201
	) -- 5201
	return { -- 5202
		x = s.x, -- 5203
		y = s.y, -- 5203
		depth = depth, -- 5203
		depthSpeed = 0, -- 5203
		vx = 0, -- 5203
		vy = 0, -- 5203
		w = child and CHILD_W or SOLDIER_W, -- 5204
		h = child and CHILD_H or SOLDIER_H, -- 5205
		onGround = true, -- 5206
		facing = 1, -- 5206
		crouch = false, -- 5206
		rollT = 0, -- 5206
		covered = false, -- 5206
		alive = true -- 5206
	} -- 5206
end -- 5206
function drawFigure(draw, play, w, h, a, body, head) -- 5210
	if not a.alive then -- 5210
		return -- 5212
	end -- 5212
	local x0 = a.x - a.w / 2 -- 5214
	local x1 = a.x + a.w / 2 -- 5215
	local y0 = a.y + a.depth -- 5216
	local y1 = y0 + a.h -- 5217
	play:drawBox( -- 5218
		draw, -- 5218
		w, -- 5218
		h, -- 5218
		x0, -- 5218
		x1, -- 5218
		y0, -- 5218
		y1 - a.h * 0.26, -- 5218
		body -- 5218
	) -- 5218
	play:drawBox( -- 5219
		draw, -- 5219
		w, -- 5219
		h, -- 5219
		x0 + 2, -- 5219
		x1 - 2, -- 5219
		y1 - a.h * 0.26, -- 5219
		y1, -- 5219
		head -- 5219
	) -- 5219
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 5221
	play:drawBox( -- 5222
		draw, -- 5222
		w, -- 5222
		h, -- 5222
		eyeX, -- 5222
		eyeX + 4, -- 5222
		y1 - a.h * 0.14, -- 5222
		y1 - a.h * 0.08, -- 5222
		INK -- 5222
	) -- 5222
end -- 5222
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5226
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5227
end -- 5226
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5234
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5235
end -- 5234
function rayInterval(origin, direction, min, max) -- 5242
	if direction == 0 then -- 5242
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5244
	end -- 5244
	local a = (min - origin) / direction -- 5246
	local b = (max - origin) / direction -- 5247
	return { -- 5248
		min = math.min(a, b), -- 5248
		max = math.max(a, b) -- 5248
	} -- 5248
end -- 5248
function hitBox(ray, box) -- 5252
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5253
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5254
	local enter = math.max(0, x.min, y.min) -- 5255
	local leave = math.min(99999, x.max, y.max) -- 5256
	if box.depth ~= nil then -- 5256
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5258
		enter = math.max(enter, depth.min) -- 5259
		leave = math.min(leave, depth.max) -- 5260
	end -- 5260
	return leave >= enter and enter or -1 -- 5262
end -- 5262
function drawCartShape(draw, play, w, h, c, axleX) -- 5265
	local half = c.bodyW / 2 -- 5266
	local x0 = axleX - half -- 5267
	local x1 = axleX + half -- 5268
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 5269
	play:drawBox( -- 5270
		draw, -- 5270
		w, -- 5270
		h, -- 5270
		x0, -- 5270
		x1, -- 5270
		axleY, -- 5270
		axleY + c.bodyH, -- 5270
		CART_FILL -- 5270
	) -- 5270
	draw:drawCircle( -- 5271
		Vec2( -- 5271
			play:sx(x0 + c.bodyW * 0.28, w), -- 5271
			play:sy(axleY, h) -- 5271
		), -- 5271
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5271
		Color(52, 50, 48, 255) -- 5271
	) -- 5271
	draw:drawCircle( -- 5272
		Vec2( -- 5272
			play:sx(x1 - c.bodyW * 0.28, w), -- 5272
			play:sy(axleY, h) -- 5272
		), -- 5272
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5272
		Color(52, 50, 48, 255) -- 5272
	) -- 5272
	local cx = c.clothSide < 0 and x0 or x1 -- 5273
	play:drawBox( -- 5274
		draw, -- 5274
		w, -- 5274
		h, -- 5274
		cx - 10, -- 5274
		cx + 10, -- 5274
		axleY + c.bodyH, -- 5274
		axleY + c.bodyH + 18, -- 5274
		CLOTH -- 5274
	) -- 5274
end -- 5274
____exports.STEP = STEP -- 33
____exports.GRAVITY = 1000 -- 34
____exports.GATE_COUNT_END = 1440 -- 35
--- 牵手：按住 E 的有效拍数，60 拍/秒 → 0.6 秒。
____exports.GATE_HAND_TICKS = 36 -- 37
--- 80% 门槛：100*hpAtGate >= 80*maxHpAtGate 走男主线。
____exports.GATE_ROUTE_PERCENT = 80 -- 39
function ____exports.gateCountAtTick(tick) -- 41
	if tick >= ____exports.GATE_COUNT_END then -- 41
		return 20 -- 42
	end -- 42
	if tick >= 1260 then -- 42
		return 19 -- 43
	end -- 43
	if tick >= 1080 then -- 43
		return 18 -- 44
	end -- 44
	if tick >= 480 then -- 44
		return 11 + math.floor((tick - 480) * 7 / 600) -- 45
	end -- 45
	return 1 + math.floor(math.max(0, tick) / 48) -- 46
end -- 41
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 49
CHILD_W = 28 -- 122
CHILD_H = 64 -- 123
local CHILD_CROUCH_H = 36 -- 124
local CHILD_SPEED = 160 -- 125
local CHILD_SLOW = 80 -- 126
local CHILD_JUMP = 320 -- 127
SOLDIER_W = 30 -- 130
SOLDIER_H = 88 -- 131
local SOLDIER_SPEED = 264 -- 132
local ROLL_TIME = 0.35 -- 133
local ROLL_SPEED = 280 -- 134
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 136
local LEDGE_RISE = 60 -- 137
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 140
____exports.LOGIC_H = 180 -- 141
____exports.UNITS_PER_PX = 2 -- 142
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 144
local CAM_FOLLOW = 9 -- 145
local CAM_LOOK_UP = 46 -- 146
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 149
--- 握把触发半径。
____exports.CART_REACH = 70 -- 151
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 153
local CART_CLEAR = 44 -- 154
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 156
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 158
local CONSUMABLE_CAP = 1 -- 159
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 161
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 163
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 165
local FIRE_COOLDOWN = 150 -- 166
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 168
local ENEMY_RANGE = 760 -- 169
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 171
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 173
local DEPTH_SPEED_RATIO = 0.55 -- 174
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 175
INK = Color(232, 232, 228, 255) -- 177
local INK_DIM = Color(150, 152, 150, 255) -- 178
local BG_VOID = Color(8, 9, 10, 255) -- 179
local BG_FAR = Color(24, 26, 28, 255) -- 180
local BG_MID = Color(31, 34, 37, 255) -- 181
local GROUND = Color(112, 114, 112, 255) -- 182
local FLOOR_DECK = Color(66, 70, 72, 255) -- 183
local SOLID_FILL = Color(84, 86, 84, 255) -- 184
local SOLID_EDGE = Color(126, 130, 126, 255) -- 185
CART_FILL = Color(122, 78, 56, 255) -- 186
CLOTH = Color(178, 52, 46, 255) -- 187
local DANGER = Color(150, 54, 48, 46) -- 188
local DANGER_LINE = Color(178, 78, 64, 200) -- 189
local HOLE_FILL = Color(10, 11, 12, 255) -- 190
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 191
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 192
local CHILD_BODY = Color(214, 168, 96, 255) -- 193
local CHILD_HEAD = Color(232, 214, 186, 255) -- 194
local ENEMY_BODY = Color(176, 92, 84, 255) -- 195
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 196
local CHECK = Color(96, 186, 122, 255) -- 197
local STAND = Color(226, 186, 84, 255) -- 198
local AIM = Color(236, 236, 232, 230) -- 199
local AIM_HIT = Color(236, 96, 84, 255) -- 200
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 202
local SOFT_LINE = Color(140, 112, 80, 190) -- 203
local BRICK = Color(126, 118, 110, 70) -- 204
local BRICK_LINE = Color(160, 152, 142, 200) -- 205
local PASS = Color(96, 186, 122, 40) -- 206
local PASS_LINE = Color(96, 186, 122, 200) -- 207
local BOTTLE = Color(120, 186, 160, 255) -- 208
local SCAV_BODY = Color(128, 118, 96, 255) -- 209
local SCAV_HEAD = Color(196, 182, 158, 255) -- 210
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 297
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 298
	if zoom < 1 then -- 298
		zoom = 1 -- 300
	end -- 300
	return { -- 302
		zoom = zoom, -- 303
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 304
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 305
	} -- 305
end -- 297
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 328
	if key == "prologue" then -- 328
		return "prologue-wait" -- 330
	end -- 330
	if key == "street" then -- 330
		return "street-run" -- 333
	end -- 333
	if key == "gate" then -- 333
		return "gate-idle" -- 336
	end -- 336
	if key == "gatepath" then -- 336
		return "gatepath-start" -- 339
	end -- 339
	if key == "forest" then -- 339
		return "forest-run" -- 342
	end -- 342
	if key == "tower" then -- 342
		return "tower-wait" -- 345
	end -- 345
	if key == "museum" then -- 345
		return "museum-cabinet" -- 348
	end -- 348
	return "run" -- 350
end -- 328
____exports.Play = __TS__Class() -- 353
local Play = ____exports.Play -- 353
Play.name = "Play" -- 353
function Play.prototype.____constructor(self, room, resume, run) -- 603
	self.enemies = {} -- 358
	self.boxes = {} -- 359
	self.floors = {} -- 360
	self.checkpoint = -1 -- 362
	self.flash = "" -- 364
	self.flashT = 0 -- 365
	self.traceT = 0 -- 368
	self.focusCart = false -- 370
	self.knocks = 0 -- 372
	self.knockT = 0 -- 373
	self.cartAxle = 0 -- 377
	self.cartDocked = false -- 379
	self.gripping = false -- 381
	self.gateOpen = false -- 383
	self.calmConsumed = false -- 385
	self.craftT = 0 -- 387
	self.nextDangerId = 1 -- 389
	self.wantRoom = "" -- 391
	self.carryCartAxle = -1 -- 393
	self.carryCartDocked = false -- 394
	self.checkpointCartAxle = -1 -- 396
	self.hasBottle = false -- 400
	self.bottleLandX = -1 -- 404
	self.bottleTargetX = -1 -- 405
	self.bottleTargetY = 0 -- 406
	self.bottleLandT = 0 -- 407
	self.aimHold = 0 -- 409
	self.scavX = 0 -- 411
	self.scavDir = 1 -- 412
	self.scavState = "patrol" -- 413
	self.scavT = 0 -- 414
	self.scavTargetX = 0 -- 415
	self.passed = false -- 417
	self.childMode = false -- 421
	self.phase = "" -- 423
	self.phaseTick = 0 -- 425
	self.gateTick = 0 -- 427
	self.countTick = 0 -- 429
	self.countArmed = false -- 431
	self.countPrevMove = 0 -- 433
	self.caughtT = 0 -- 435
	self.hp = 3 -- 437
	self.maxHp = 3 -- 438
	self.invulnT = 0 -- 444
	self.partnerStuck = 0 -- 446
	self.partnerLaneIdx = 0 -- 448
	self.partnerLaneHold = 0 -- 449
	self.coveredFlash = 0 -- 451
	self.coverHug = false -- 453
	self.coverNear = false -- 455
	self.coverEntity = "" -- 457
	self.coverBlocking = false -- 459
	self.gateNeedConfirm = false -- 461
	self.gateRestartArmed = true -- 463
	self.bottleAimX = -1 -- 465
	self.bottleAimY = 0 -- 466
	self.bottleSurfaceY = -1 -- 468
	self.bottleLandY = 0 -- 470
	self.events = {} -- 472
	self.eventSeq = 0 -- 474
	self.dogX = 0 -- 476
	self.dogDir = 1 -- 477
	self.dogState = "patrol" -- 478
	self.dogT = 0 -- 479
	self.dogTargetX = 0 -- 480
	self.scavSee = 0 -- 482
	self.scavChase = false -- 483
	self.gateSpawned = 0 -- 485
	self.gateFailCount = 0 -- 487
	self.isCampaign = false -- 491
	self.archiveDirty = false -- 499
	self.restartStory = false -- 501
	self.wellOpen = false -- 503
	self.wellX = 430 -- 505
	self.wellTaken = false -- 507
	self.museumReturn = false -- 509
	self.endingLines = {"", ""} -- 511
	self.equippedWeapon = "standard_gun" -- 515
	self.craftBench = { -- 517
		active = false, -- 518
		firstCraftDone = false, -- 519
		justCraftedTimer = 0, -- 520
		inventory = {}, -- 521
		recipes = {}, -- 522
		equippedWeapon = "standard_gun" -- 523
	} -- 523
	self.handledCraftRequests = {} -- 526
	self.benchReach = 48 -- 528
	self.pickups = {} -- 532
	self.reloadT = 0 -- 534
	self.objectiveDone = false -- 538
	self.hint = "" -- 540
	self.roomStartTick = 0 -- 542
	self.cartHitT = 0 -- 544
	self.cartExposed = false -- 545
	self.storyRoute = "" -- 549
	self.storySettled = false -- 551
	self.hpAtGate = -1 -- 553
	self.maxHpAtGate = -1 -- 554
	self.handTicks = 0 -- 556
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 558
	self.handArmed = false -- 560
	self.handDone = false -- 562
	self.lineSaid = false -- 563
	self.tied = false -- 565
	self.pathDone = false -- 567
	self.carryOn = false -- 569
	self.escortDone = false -- 571
	self.reloadOpen = false -- 575
	self.reloadAnswerTicks = 0 -- 577
	self.reloadWorldTicks = 0 -- 579
	self.reloadPath = {RELOAD_START} -- 581
	self.reloadPendingEffect = "" -- 583
	self.reloadTryCount = 0 -- 585
	self.paused = false -- 587
	self.ticks = 0 -- 589
	self.view = {zoom = 1, ox = 0, oy = 0} -- 591
	self.ox = 0 -- 593
	self.aimX = 0 -- 595
	self.aimY = 0 -- 596
	self.viewW = 0 -- 598
	self.viewH = 0 -- 599
	self.ox = room.originX -- 605
	self.room = withOrigin(room) -- 606
	local wr = self.room -- 607
	self.run = run or createRun() -- 608
	self.inventory = self.run.inventory -- 609
	self.archive = self.run.archive -- 610
	self.equippedWeapon = self.run.story.craftedWeapon == "" and "standard_gun" or self.run.story.craftedWeapon -- 611
	self.isCampaign = wr.campaign ~= nil -- 612
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 613
	self:buildWorld() -- 614
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 617
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 619
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 620
	local soloRoom = wr.key == "museum" -- 622
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 623
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 624
	self.player = makeActor(wr, playerIdx) -- 625
	self.partner = makeActor(wr, partnerIdx) -- 626
	self.phase = phaseOf(wr.key) -- 627
	if soloRoom then -- 627
		local mp = self.archive.museumPhase -- 630
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 631
	end -- 631
	if wr.story ~= nil then -- 631
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 637
	end -- 637
	self.cam.x = self.player.x -- 639
	self.cam.y = self.player.y + CAM_LOOK_UP -- 640
	self.cartAxle = wr.cart.startX -- 641
	self.escort = __TS__New( -- 642
		Escort, -- 642
		safeAnchorX(wr.marks) -- 642
	) -- 642
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 643
	if self.isCampaign then -- 643
		self:setupCampaign() -- 645
	else -- 645
		self:buildEnemies() -- 647
	end -- 647
	if resume ~= nil and resume.checkpoint > 0 then -- 647
		self.checkpoint = resume.checkpoint -- 651
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 651
			self.cartAxle = self.room.cart.endX -- 653
			self.cartDocked = true -- 654
			self.player.x = self.ox + 380 -- 657
			self.player.y = 0 -- 658
			self.player.vy = 0 -- 659
			self.player.onGround = true -- 660
			self.cam.x = self.player.x -- 661
			self.cam.y = self.player.y + CAM_LOOK_UP -- 662
		end -- 662
	end -- 662
	self:restoreStory() -- 665
end -- 603
function Play.prototype.recipeViews(self) -- 678
	local out = {} -- 679
	local i = 0 -- 680
	do -- 680
		i = 0 -- 681
		while i < #CRAFT_RECIPES do -- 681
			local r = CRAFT_RECIPES[i + 1] -- 682
			local cost = {} -- 683
			if r.cost.wood ~= nil then -- 683
				cost.wood = r.cost.wood -- 685
			end -- 685
			if r.cost.bell ~= nil then -- 685
				cost.bell = r.cost.bell -- 688
			end -- 688
			out[#out + 1] = { -- 690
				id = r.id, -- 691
				name = r.name, -- 692
				desc = r.desc, -- 693
				enhancedEffect = r.enhancedEffect, -- 694
				cost = cost, -- 695
				crafted = self.run.story.craftedWeapon == r.id -- 696
			} -- 696
			i = i + 1 -- 681
		end -- 681
	end -- 681
	return out -- 699
end -- 678
function Play.prototype.syncCraftBench(self) -- 703
	local view = self.craftBench -- 704
	local inv = self.run.inventory -- 705
	view.inventory = { -- 706
		wood = inv.wood, -- 706
		bell = inv.bell, -- 706
		scrap = inv.scrap, -- 706
		wedge = inv.wedge, -- 706
		ammo = inv.ammo -- 706
	} -- 706
	view.recipes = self:recipeViews() -- 707
	view.equippedWeapon = self.equippedWeapon -- 708
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 709
	if view.justCraftedTimer > 0 then -- 709
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 711
	end -- 711
end -- 703
function Play.prototype.openCraftBench(self) -- 716
	if self.room.key ~= "escort3" or self.craftBench.active then -- 716
		return -- 718
	end -- 718
	self.craftBench.active = true -- 720
	self.carryOn = false -- 721
	self.run.story.carry = false -- 722
	self.player.vx = 0 -- 723
	self.player.vy = 0 -- 724
	self.craftBench.justCraftedTimer = 0 -- 725
	self:syncCraftBench() -- 726
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 727
	self:log("开工台") -- 728
	self:emit( -- 729
		"benchOpen", -- 729
		{ -- 729
			recipes = __TS__ArrayMap( -- 730
				self.craftBench.recipes, -- 730
				function(____, r) return r.id end -- 730
			), -- 730
			inventory = self.craftBench.inventory, -- 731
			carry = self.carryOn -- 732
		} -- 732
	) -- 732
end -- 716
function Play.prototype.closeCraftBench(self) -- 737
	if not self.craftBench.active then -- 737
		return -- 739
	end -- 739
	self.craftBench.active = false -- 741
	self.craftBench.justCraftedTimer = 0 -- 742
	self.carryOn = true -- 743
	self.run.story.carry = true -- 744
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 745
	self:log("离站背起") -- 746
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 747
end -- 737
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 754
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 754
		return false -- 756
	end -- 756
	local recipe = findRecipe(recipeId) -- 758
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 758
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 760
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 761
		return false -- 762
	end -- 762
	local missing = missingMaterials(self.run.inventory, recipe) -- 764
	if #missing > 0 then -- 764
		self:flashSet( -- 766
			"缺料 · " .. table.concat(missing, " / "), -- 766
			1.6 -- 766
		) -- 766
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 767
		return false -- 768
	end -- 768
	payMaterials(self.run.inventory, recipe) -- 770
	self.handledCraftRequests[requestId] = true -- 771
	self.run.story.craftedWeapon = recipe.id -- 772
	self.equippedWeapon = recipe.id -- 773
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 774
	self.craftBench.firstCraftDone = true -- 775
	self:syncCraftBench() -- 776
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 777
	self:log("改制 " .. recipe.id) -- 778
	self:emit("benchCraft", { -- 779
		recipeId = recipe.id, -- 780
		weapon = recipe.id, -- 781
		effect = recipe.enhancedEffect, -- 782
		wood = self.run.inventory.wood, -- 783
		bell = self.run.inventory.bell -- 784
	}) -- 784
	return true -- 786
end -- 754
function Play.prototype.equipWeapon(self, weaponId) -- 790
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId then -- 790
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 792
		return false -- 793
	end -- 793
	self.equippedWeapon = weaponId -- 795
	self:syncCraftBench() -- 796
	self:flashSet( -- 797
		"已装备 " .. weaponNameOf(weaponId), -- 797
		1 -- 797
	) -- 797
	self:emit("benchEquip", {weapon = weaponId}) -- 798
	return true -- 799
end -- 790
function Play.prototype.submitFeIntent(self, intent) -- 806
	local kind = intent == nil and "" or intent.kind -- 807
	if kind == "reloadTapNode" then -- 807
		local node = intent.node -- 809
		if type(node) == "number" then -- 809
			self:reloadTapNode(node) -- 811
			return true -- 812
		end -- 812
		return false -- 814
	end -- 814
	if kind == "reloadPathCommit" then -- 814
		local path = intent.path -- 817
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 817
			local list = path -- 819
			local i = 0 -- 820
			do -- 820
				i = 0 -- 821
				while i < #list do -- 821
					do -- 821
						if i == 0 and list[i + 1] == RELOAD_START then -- 821
							goto __continue48 -- 823
						end -- 823
						self:reloadTapNode(list[i + 1]) -- 825
					end -- 825
					::__continue48:: -- 825
					i = i + 1 -- 821
				end -- 821
			end -- 821
			return true -- 827
		end -- 827
		return false -- 829
	end -- 829
	if kind == "reloadCancel" then -- 829
		self:closeReloadPuzzle() -- 832
		return true -- 833
	end -- 833
	if kind == "craftSubmit" then -- 833
		local recipeId = intent.recipeId -- 836
		local requestId = intent.requestId -- 837
		if type(recipeId) == "string" and type(requestId) == "string" then -- 837
			return self:craftAtBench(recipeId, requestId) -- 839
		end -- 839
		return false -- 841
	end -- 841
	if kind == "craftEquip" then -- 841
		local weaponId = intent.weaponId -- 844
		if type(weaponId) == "string" then -- 844
			return self:equipWeapon(weaponId) -- 846
		end -- 846
		return false -- 848
	end -- 848
	if kind == "craftClose" then -- 848
		self:closeCraftBench() -- 851
		return true -- 852
	end -- 852
	if kind == "wellPick" then -- 852
		return self:pickWell() -- 855
	end -- 855
	return false -- 857
end -- 806
function Play.prototype.captureCheckpoint(self, id) -- 861
	local inv = self.run.inventory -- 862
	self.checkpointSnap = { -- 863
		id = id, -- 864
		wood = inv.wood, -- 865
		bell = inv.bell, -- 866
		scrap = inv.scrap, -- 867
		wedge = inv.wedge, -- 868
		ammo = inv.ammo, -- 869
		shield = inv.shield, -- 870
		pass = inv.pass, -- 871
		quickbelt = inv.quickbelt, -- 872
		crafted = self.run.story.craftedWeapon, -- 873
		equipped = self.equippedWeapon, -- 874
		carry = self.carryOn -- 875
	} -- 875
	self.run.story.cp = self.checkpointSnap -- 877
end -- 861
function Play.prototype.applyCheckpointSnap(self, id) -- 881
	local snap = self.run.story.cp -- 882
	if snap == nil or snap.id ~= id then -- 882
		return false -- 884
	end -- 884
	self.checkpointSnap = snap -- 886
	local inv = self.run.inventory -- 887
	inv.wood = snap.wood -- 888
	inv.bell = snap.bell -- 889
	inv.scrap = snap.scrap -- 890
	inv.wedge = snap.wedge -- 891
	inv.ammo = snap.ammo -- 892
	inv.shield = snap.shield -- 893
	inv.pass = snap.pass -- 894
	inv.quickbelt = snap.quickbelt -- 895
	self.run.story.craftedWeapon = snap.crafted -- 896
	self.equippedWeapon = snap.equipped -- 897
	self.carryOn = snap.carry -- 898
	self.run.story.carry = snap.carry -- 899
	self.craftBench.active = false -- 900
	self:syncCraftBench() -- 901
	return true -- 902
end -- 881
function Play.prototype.restoreStory(self) -- 905
	if self.isCampaign and self.run.trial ~= nil then -- 905
		return -- 909
	end -- 909
	local story = self.run.story -- 911
	if story == nil then -- 911
		return -- 913
	end -- 913
	if story.maxHp > 0 then -- 913
		self.maxHp = story.maxHp -- 916
		self.hp = math.max( -- 917
			1, -- 917
			math.min(story.hp, story.maxHp) -- 917
		) -- 917
	end -- 917
	self.storyRoute = story.route -- 919
	self.storySettled = story.settled -- 920
	self.hpAtGate = story.hpAtGate -- 921
	self.maxHpAtGate = story.maxHpAtGate -- 922
	self.handDone = story.handDone -- 923
	self.lineSaid = story.lineSaid -- 924
	self.tied = story.handDone -- 925
	self.carryOn = story.carry or story.route == "soldier" and self.room.key == "escort1" -- 926
	self.museumReturn = story.museumReturn -- 927
	story.museumReturn = false -- 928
	self.escortDone = story.escortDone -- 929
	self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 930
	self:syncCraftBench() -- 931
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 931
		self:applyCheckpointSnap(self.checkpoint) -- 934
	end -- 934
	if self.room.key == "tower" and story.route == "soldier" then -- 934
		self.carryOn = false -- 938
		self.run.story.carry = false -- 939
	end -- 939
	if self.room.key ~= "gate" then -- 939
		return -- 942
	end -- 942
	local ____temp_0 -- 944
	if self.room.story == nil then -- 944
		____temp_0 = nil -- 944
	else -- 944
		____temp_0 = self.room.story.gate -- 944
	end -- 944
	local g = ____temp_0 -- 944
	if g == nil then -- 944
		return -- 946
	end -- 946
	if story.phase == "gate-send" then -- 946
		self.phase = "gate-send" -- 950
		self.gateTick = g.holdTicks -- 951
		self.gateSpawned = 4 -- 952
		self.enemies = {} -- 953
		self.player.x = self.ox + g.doorX - 40 -- 954
		self.player.y = 0 -- 955
		self.player.depth = 0 -- 956
		self.player.vx = 0 -- 957
		self.player.vy = 0 -- 958
		self.player.onGround = true -- 959
		self.partner.x = self.ox + g.waitX -- 960
		self.partner.y = 0 -- 961
		self.partner.depth = 0 -- 962
		self.partner.alive = true -- 963
		self.cam.x = self.player.x -- 964
		self.handTicks = 0 -- 965
		self.handArmed = false -- 966
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 967
		return -- 968
	end -- 968
	if not story.settled then -- 968
		return -- 971
	end -- 971
	self.gateTick = g.holdTicks -- 974
	self.gateSpawned = 4 -- 975
	self.enemies = {} -- 976
	if story.phase == "gate-count" or story.phase == "gate-walk" then -- 976
		self.phase = story.phase -- 978
		self.countTick = math.max(story.countTick, 0) -- 979
		self:swapToChild(g.doorX + 30) -- 980
		self.countPrevMove = 0 -- 981
		self.countArmed = false -- 982
		return -- 983
	end -- 983
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 983
		self.phase = story.phase -- 986
		self.countTick = ____exports.GATE_COUNT_END -- 987
		self.phaseTick = story.phaseTick -- 988
		self:swapToChild(g.doorX + 30) -- 989
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 990
			0, -- 990
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 990
		) -- 990
		self.handArmed = false -- 991
	end -- 991
end -- 905
function Play.prototype.buildWorld(self) -- 996
	local room = self.room -- 997
	self.boxes = {} -- 998
	self.floors = {} -- 999
	local i = 0 -- 1000
	do -- 1000
		i = 0 -- 1001
		while i < #room.floors do -- 1001
			local f = room.floors[i + 1] -- 1002
			local ____self_floors_1 = self.floors -- 1002
			____self_floors_1[#____self_floors_1 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1003
			i = i + 1 -- 1001
		end -- 1001
	end -- 1001
	do -- 1001
		i = 0 -- 1005
		while i < #room.solids do -- 1005
			local s = room.solids[i + 1] -- 1006
			if not s.decorative then -- 1006
				local ____self_boxes_13 = self.boxes -- 1012
				local ____s_x_4 = s.x -- 1013
				local ____temp_5 = s.x + s.w -- 1013
				local ____s_y_6 = s.y -- 1013
				local ____temp_7 = s.y + s.h -- 1013
				local ____temp_2 -- 1014
				if room.depth == nil then -- 1014
					____temp_2 = nil -- 1014
				else -- 1014
					____temp_2 = s.depth -- 1014
				end -- 1014
				local ____temp_8 = s.passable == true -- 1015
				local ____s_label_9 = s.label -- 1015
				local ____s_id_10 = s.id -- 1016
				local ____temp_11 = s.soft == true -- 1016
				local ____temp_12 = s.hidden == true -- 1016
				local ____temp_3 -- 1017
				if s.breakable == nil then -- 1017
					____temp_3 = nil -- 1017
				else -- 1017
					____temp_3 = __TS__ObjectAssign({}, s.breakable) -- 1017
				end -- 1017
				____self_boxes_13[#____self_boxes_13 + 1] = { -- 1012
					x0 = ____s_x_4, -- 1013
					x1 = ____temp_5, -- 1013
					y0 = ____s_y_6, -- 1013
					y1 = ____temp_7, -- 1013
					depth = ____temp_2, -- 1014
					passable = ____temp_8, -- 1015
					label = ____s_label_9, -- 1015
					id = ____s_id_10, -- 1016
					soft = ____temp_11, -- 1016
					hidden = ____temp_12, -- 1016
					breakable = ____temp_3, -- 1017
					interact = s.interact -- 1018
				} -- 1018
			end -- 1018
			i = i + 1 -- 1005
		end -- 1005
	end -- 1005
	do -- 1005
		i = 0 -- 1022
		while i < #room.stairs do -- 1022
			local st = room.stairs[i + 1] -- 1023
			local n = st.steps + 1 -- 1024
			local stepW = (st.x1 - st.x0) / n -- 1025
			local k = 0 -- 1026
			do -- 1026
				k = 0 -- 1027
				while k < n do -- 1027
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1028
					local x0 = st.x0 + stepW * k -- 1029
					local ____self_boxes_14 = self.boxes -- 1029
					____self_boxes_14[#____self_boxes_14 + 1] = { -- 1031
						x0 = x0, -- 1031
						x1 = x0 + stepW, -- 1031
						y0 = -8, -- 1031
						y1 = y, -- 1031
						passable = true -- 1031
					} -- 1031
					k = k + 1 -- 1027
				end -- 1027
			end -- 1027
			i = i + 1 -- 1022
		end -- 1022
	end -- 1022
end -- 996
function Play.prototype.setupCampaign(self) -- 1040
	local wr = self.room -- 1041
	local c = wr.campaign -- 1042
	if c == nil then -- 1042
		return -- 1044
	end -- 1044
	self.roomStartTick = self.run.ticks -- 1046
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1046
		self.run.joined = true -- 1050
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1050
		local ____self_run_16 = self.run -- 1053
		local ____temp_15 -- 1053
		if wr.key == "s2-drygoods" then -- 1053
			____temp_15 = self.run.route ~= "drygoods" -- 1053
		else -- 1053
			____temp_15 = false -- 1053
		end -- 1053
		____self_run_16.joined = ____temp_15 -- 1053
	end -- 1053
	local x = wr.minX + 60 -- 1055
	local y = 0 -- 1056
	local depth = 0 -- 1057
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1057
		x = wr.minX + 210 -- 1059
		depth = -32 -- 1060
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1060
		x = wr.minX + 40 -- 1062
		y = 32 -- 1063
		depth = 32 -- 1064
	end -- 1064
	self.player = { -- 1066
		x = x, -- 1067
		y = y, -- 1067
		depth = depth, -- 1067
		depthSpeed = 0, -- 1067
		vx = 0, -- 1067
		vy = 0, -- 1067
		w = SOLDIER_W, -- 1068
		h = SOLDIER_H, -- 1068
		onGround = y <= 0, -- 1068
		facing = 1, -- 1068
		crouch = false, -- 1068
		rollT = 0, -- 1068
		covered = false, -- 1068
		alive = true -- 1068
	} -- 1068
	self.partner = { -- 1070
		x = x + 60, -- 1071
		y = y, -- 1071
		depth = depth, -- 1071
		depthSpeed = 0, -- 1071
		vx = 0, -- 1071
		vy = 0, -- 1071
		w = CHILD_W, -- 1072
		h = CHILD_H, -- 1072
		onGround = y <= 0, -- 1072
		facing = 1, -- 1072
		crouch = false, -- 1072
		rollT = 0, -- 1072
		covered = false, -- 1072
		alive = true -- 1072
	} -- 1072
	self.cam.x = x -- 1074
	self.cam.y = y + CAM_LOOK_UP -- 1075
	self.phase = "run" -- 1076
	self.hp = self.maxHp -- 1077
	local trial = self.run.trial -- 1078
	if trial ~= nil then -- 1078
		draftRoom(trial, wr.key) -- 1080
		self.maxHp = self.maxHp + trial.ranks.vitality -- 1081
		self.hp = trial.hp -- 1082
	end -- 1082
	self:buildEnemies() -- 1084
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1085
	local i = 0 -- 1086
	do -- 1086
		i = 0 -- 1087
		while i < #self.boxes do -- 1087
			do -- 1087
				local b = self.boxes[i + 1] -- 1088
				if b.id == nil then -- 1088
					goto __continue90 -- 1090
				end -- 1090
				local st = self.run.props[b.id] -- 1092
				if st ~= nil then -- 1092
					b.broken = st.broken -- 1094
					local ____temp_17 -- 1095
					if b.breakable == nil then -- 1095
						____temp_17 = nil -- 1095
					else -- 1095
						____temp_17 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1095
					end -- 1095
					b.breakable = ____temp_17 -- 1095
					b.hidden = b.hidden == true and st.revealed ~= true -- 1096
					if b.hidden then -- 1096
						b.broken = true -- 1098
					end -- 1098
				elseif b.hidden == true then -- 1098
					b.broken = true -- 1102
				end -- 1102
			end -- 1102
			::__continue90:: -- 1102
			i = i + 1 -- 1087
		end -- 1087
	end -- 1087
	if wr.cart.bodyW > 0 then -- 1087
		self.cartAxle = wr.cart.startX -- 1106
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1106
			self.cartAxle = wr.cart.endX -- 1108
			self.cartDocked = true -- 1109
		end -- 1109
	end -- 1109
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1112
end -- 1040
function Play.prototype.log(self, line) -- 1115
	local ____self_run_log_18 = self.run.log -- 1115
	____self_run_log_18[#____self_run_log_18 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1116
	if #self.run.log > 120 then -- 1116
		table.remove(self.run.log, 1) -- 1118
	end -- 1118
end -- 1115
function Play.prototype.buildEnemies(self) -- 1122
	self.enemies = {} -- 1123
	if self.isCampaign then -- 1123
		local i = 0 -- 1125
		do -- 1125
			i = 0 -- 1126
			while i < #self.room.spawns do -- 1126
				local sp = self.room.spawns[i + 1] -- 1127
				local kind = sp.kind or "gunner" -- 1128
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1129
				local ____self_enemies_19 = self.enemies -- 1129
				____self_enemies_19[#____self_enemies_19 + 1] = { -- 1130
					x = sp.x, -- 1131
					y = sp.y, -- 1131
					depth = sp.depth, -- 1131
					w = 26, -- 1131
					h = sp.h, -- 1131
					alive = true, -- 1131
					hitT = 0, -- 1131
					warnT = 0, -- 1131
					fireCd = 40, -- 1131
					kind = kind, -- 1132
					shieldHp = hp, -- 1132
					shieldHpMax = hp, -- 1132
					drop = sp.drop or "none", -- 1132
					homeX = sp.x, -- 1133
					swingT = 0, -- 1133
					awake = false, -- 1133
					squad = i -- 1133
				} -- 1133
				i = i + 1 -- 1126
			end -- 1126
		end -- 1126
		return -- 1136
	end -- 1136
	if self.room.key == "checkpoint" then -- 1136
		local ____self_enemies_20 = self.enemies -- 1136
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 1139
			x = self.ox + 430, -- 1139
			y = 0, -- 1139
			w = 26, -- 1139
			h = 84, -- 1139
			alive = true, -- 1139
			hitT = 0, -- 1139
			warnT = 0, -- 1139
			fireCd = 0 -- 1139
		} -- 1139
		local ____self_enemies_21 = self.enemies -- 1139
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 1140
			x = self.ox + 505, -- 1140
			y = 0, -- 1140
			w = 26, -- 1140
			h = 84, -- 1140
			alive = true, -- 1140
			hitT = 0, -- 1140
			warnT = 0, -- 1140
			fireCd = 0 -- 1140
		} -- 1140
		return -- 1141
	end -- 1141
	if self.room.key == "street" then -- 1141
		local ____self_enemies_22 = self.enemies -- 1141
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 1145
			x = self.ox + 340, -- 1145
			y = 0, -- 1145
			w = 26, -- 1145
			h = 84, -- 1145
			alive = true, -- 1145
			hitT = 0, -- 1145
			warnT = 0, -- 1145
			fireCd = 0 -- 1145
		} -- 1145
		local ____self_enemies_23 = self.enemies -- 1145
		____self_enemies_23[#____self_enemies_23 + 1] = { -- 1146
			x = self.ox + 560, -- 1146
			y = 0, -- 1146
			w = 26, -- 1146
			h = 84, -- 1146
			alive = true, -- 1146
			hitT = 0, -- 1146
			warnT = 0, -- 1146
			fireCd = 0 -- 1146
		} -- 1146
	end -- 1146
end -- 1122
function Play.prototype.emit(self, name, data) -- 1152
	local ____self_events_24 = self.events -- 1152
	____self_events_24[#____self_events_24 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1153
	self.eventSeq = self.eventSeq + 1 -- 1154
	if #self.events > 256 then -- 1154
		table.remove(self.events, 1) -- 1156
	end -- 1156
end -- 1152
function Play.prototype.drainEvents(self) -- 1164
	local out = self.events -- 1165
	self.events = {} -- 1166
	return out -- 1167
end -- 1164
function Play.prototype.adoptEvents(self, events) -- 1176
	if #events == 0 then -- 1176
		return -- 1178
	end -- 1178
	local keep = {} -- 1180
	local i = 0 -- 1181
	do -- 1181
		i = 0 -- 1182
		while i < #events do -- 1182
			do -- 1182
				local e = events[i + 1] -- 1183
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1183
					goto __continue111 -- 1185
				end -- 1185
				keep[#keep + 1] = e -- 1187
			end -- 1187
			::__continue111:: -- 1187
			i = i + 1 -- 1182
		end -- 1182
	end -- 1182
	if #keep == 0 then -- 1182
		return -- 1190
	end -- 1190
	self.events = __TS__ArrayConcat(keep, self.events) -- 1192
	do -- 1192
		i = 0 -- 1193
		while i < #self.events do -- 1193
			self.events[i + 1].seq = i -- 1194
			i = i + 1 -- 1193
		end -- 1193
	end -- 1193
	self.eventSeq = #self.events -- 1196
end -- 1176
function Play.prototype.chooseTalent(self, slot) -- 1199
	local trial = self.run.trial -- 1200
	local talent = trial and trial.offers[slot + 1] -- 1201
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 1201
		return -- 1202
	end -- 1202
	local ____trial_ranks_27, ____talent_28 = trial.ranks, talent -- 1202
	____trial_ranks_27[____talent_28] = ____trial_ranks_27[____talent_28] + 1 -- 1203
	trial.offers = {} -- 1204
	if talent == "vitality" then -- 1204
		self.maxHp = self.maxHp + 1 -- 1206
		self.hp = self.hp + 1 -- 1207
		trial.hp = self.hp -- 1208
	end -- 1208
	self:flashSet(talentNames[talent], 1.2) -- 1210
end -- 1199
function Play.prototype.beginReload(self) -- 1218
	self.reloadT = self:reloadTicks() -- 1219
	local camp = self.room.campaign -- 1220
	if self.run.trial == nil and camp ~= nil and camp.reloadPuzzle == true then -- 1220
		self:openReloadPuzzle() -- 1223
	end -- 1223
end -- 1218
function Play.prototype.openReloadPuzzle(self) -- 1228
	self.reloadOpen = true -- 1229
	self.reloadAnswerTicks = 0 -- 1230
	self.reloadWorldTicks = 0 -- 1231
	self.reloadPath = {RELOAD_START} -- 1232
	self.reloadPendingEffect = "" -- 1233
	self.reloadTryCount = self.reloadTryCount + 1 -- 1234
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 1235
end -- 1228
function Play.prototype.closeReloadPuzzle(self) -- 1239
	self.reloadOpen = false -- 1240
	self.reloadAnswerTicks = 0 -- 1241
	self.reloadWorldTicks = 0 -- 1242
	self.reloadPath = {RELOAD_START} -- 1243
	self.reloadPendingEffect = "" -- 1244
end -- 1239
function Play.prototype.reloadTapNode(self, node) -- 1251
	if not self.reloadOpen then -- 1251
		return -- 1253
	end -- 1253
	local path = self.reloadPath -- 1255
	local last = path[#path] -- 1256
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1256
		self.reloadPath = {RELOAD_START} -- 1258
		self:emit("reloadInvalid", {node = node, at = last}) -- 1259
		return -- 1260
	end -- 1260
	path[#path + 1] = node -- 1262
	if node ~= RELOAD_TARGET then -- 1262
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1264
		return -- 1265
	end -- 1265
	if not reloadPathValid(path) then -- 1265
		self.reloadPath = {RELOAD_START} -- 1268
		self:emit("reloadInvalid", {node = node, at = last}) -- 1269
		return -- 1270
	end -- 1270
	self.reloadPendingEffect = reloadEffectOf(path) -- 1272
	self.reloadOpen = false -- 1273
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1274
	self:flashSet( -- 1277
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1277
		1.4 -- 1277
	) -- 1277
end -- 1251
function Play.prototype.consumeReloadEffect(self) -- 1281
	local e = self.reloadPendingEffect -- 1282
	if e ~= "" then -- 1282
		self.reloadPendingEffect = "" -- 1284
	end -- 1284
	return e -- 1286
end -- 1281
function Play.prototype.echoToSource(self, from, count) -- 1293
	if count == nil then -- 1293
		count = 1 -- 1293
	end -- 1293
	local best = -1 -- 1294
	local bestD = 1000000000 -- 1295
	local i = 0 -- 1296
	local woken = {} -- 1297
	local n = 0 -- 1298
	while n < count do -- 1298
		best = -1 -- 1300
		bestD = 1000000000 -- 1301
		do -- 1301
			i = 0 -- 1302
			while i < #self.enemies do -- 1302
				do -- 1302
					if woken[i] == true then -- 1302
						goto __continue133 -- 1304
					end -- 1304
					local e = self.enemies[i + 1] -- 1306
					if not e.alive then -- 1306
						goto __continue133 -- 1308
					end -- 1308
					local d = math.abs(e.x - from.x) -- 1310
					if d < bestD then -- 1310
						bestD = d -- 1312
						best = i -- 1313
					end -- 1313
				end -- 1313
				::__continue133:: -- 1313
				i = i + 1 -- 1302
			end -- 1302
		end -- 1302
		if best < 0 then -- 1302
			break -- 1317
		end -- 1317
		woken[best] = true -- 1319
		local e = self.enemies[best + 1] -- 1320
		e.awake = true -- 1321
		e.warnT = 0 -- 1322
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1323
		n = n + 1 -- 1324
	end -- 1324
	if n == 0 then -- 1324
		return -- 1327
	end -- 1327
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1329
end -- 1293
function Play.prototype.reloadTicks(self) -- 1332
	local ____temp_31 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 1333
	local ____opt_29 = self.run.trial -- 1333
	return math.max(6, ____temp_31 - 6 * (____opt_29 and ____opt_29.ranks.reload or 0)) -- 1333
end -- 1332
function Play.prototype.update(self, dt, input) -- 1336
	self:syncCraftBench() -- 1337
	local trial = self.run.trial -- 1338
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1338
		return -- 1339
	end -- 1339
	if input.pause.pressed then -- 1339
		self.paused = not self.paused -- 1341
	end -- 1341
	if self.flashT > 0 then -- 1341
		self.flashT = self.flashT - dt -- 1344
		if self.flashT <= 0 then -- 1344
			self.flash = "" -- 1346
		end -- 1346
	end -- 1346
	if self.traceT > 0 then -- 1346
		self.traceT = self.traceT - dt -- 1350
		if self.traceT <= 0 then -- 1350
			self.trace = nil -- 1352
		end -- 1352
	end -- 1352
	if self.paused then -- 1352
		self:updateCamera(dt) -- 1356
		return -- 1357
	end -- 1357
	if self.craftBench.active then -- 1357
		if input.interact.pressed or input.pause.pressed then -- 1357
			self:closeCraftBench() -- 1363
		end -- 1363
		self:updateCamera(dt) -- 1365
		return -- 1366
	end -- 1366
	if self.reloadOpen then -- 1366
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1372
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1372
			self.reloadOpen = false -- 1374
			self.reloadPendingEffect = "" -- 1375
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1376
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1377
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1377
			self:updateCamera(dt) -- 1379
			return -- 1380
		else -- 1380
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1382
		end -- 1382
	end -- 1382
	self.ticks = self.ticks + 1 -- 1386
	if self.invulnT > 0 then -- 1386
		self.invulnT = self.invulnT - 1 -- 1390
	end -- 1390
	if self.isCampaign then -- 1390
		local ____self_run_32, ____ticks_33 = self.run, "ticks" -- 1390
		____self_run_32[____ticks_33] = ____self_run_32[____ticks_33] + 1 -- 1393
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1394
	end -- 1394
	local p = self.player -- 1396
	self:stepPlayer(p, dt, input) -- 1397
	self:refreshCover(p, input) -- 1399
	if self.carryOn then -- 1399
		self:carryPose() -- 1401
	end -- 1401
	if self.isCampaign then -- 1401
		self:stepCampaign(dt, input) -- 1404
		if not self.carryOn then -- 1404
			self:stepCampaignPartner(dt) -- 1406
		end -- 1406
	end -- 1406
	if trial == nil or not self.run.finished then -- 1406
		self:stepEnemies(dt, input) -- 1414
	end -- 1414
	if trial ~= nil then -- 1414
		trial.hp = self.hp -- 1416
	end -- 1416
	if not self.isCampaign then -- 1416
		self:stepStory(dt, input) -- 1418
		self:stepEscort(dt, input) -- 1419
		self:stepVillage(dt, input) -- 1420
		self:stepChase(dt, input) -- 1421
		self:stepInteract(dt, input) -- 1422
	end -- 1422
	self:updateGate() -- 1424
	self:updateCamera(dt) -- 1425
	self:syncStory() -- 1427
end -- 1336
function Play.prototype.underLowArch(self, a) -- 1434
	local arch = self.room.arch -- 1435
	if arch.h <= 0 then -- 1435
		return false -- 1437
	end -- 1437
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1437
		return false -- 1440
	end -- 1440
	local top = arch.y + arch.h -- 1442
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1443
end -- 1434
function Play.prototype.coverAt(self, a) -- 1450
	local best = nil -- 1451
	local bestGap = 24 -- 1452
	local half = a.w / 2 -- 1453
	local i = 0 -- 1454
	do -- 1454
		i = 0 -- 1455
		while i < #self.boxes do -- 1455
			do -- 1455
				local b = self.boxes[i + 1] -- 1456
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1456
					goto __continue167 -- 1458
				end -- 1458
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1458
					goto __continue167 -- 1461
				end -- 1461
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1463
				if gap < bestGap then -- 1463
					bestGap = gap -- 1465
					best = b -- 1466
				end -- 1466
			end -- 1466
			::__continue167:: -- 1466
			i = i + 1 -- 1455
		end -- 1455
	end -- 1455
	return best -- 1469
end -- 1450
function Play.prototype.nearCover(self, a) -- 1472
	return self:coverAt(a) ~= nil -- 1473
end -- 1472
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1477
	if enemy == nil then -- 1477
		return false -- 1479
	end -- 1479
	local fromRight = enemy.x >= a.x -- 1481
	local edge = fromRight and b.x0 or b.x1 -- 1482
	local ____fromRight_34 -- 1483
	if fromRight then -- 1483
		____fromRight_34 = edge >= a.x - 0.001 and edge <= enemy.x -- 1483
	else -- 1483
		____fromRight_34 = edge <= a.x + 0.001 and edge >= enemy.x -- 1484
	end -- 1484
	local between = ____fromRight_34 -- 1483
	local separation = enemy.x - a.x -- 1485
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1486
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1487
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1488
end -- 1477
function Play.prototype.nearestEnemy(self, a) -- 1491
	local best -- 1492
	local bestD = 1000000000 -- 1493
	local i = 0 -- 1494
	do -- 1494
		i = 0 -- 1495
		while i < #self.enemies do -- 1495
			do -- 1495
				local e = self.enemies[i + 1] -- 1496
				if not e.alive then -- 1496
					goto __continue176 -- 1498
				end -- 1498
				local d = math.abs(e.x - a.x) -- 1500
				if d < bestD then -- 1500
					bestD = d -- 1502
					best = e -- 1503
				end -- 1503
			end -- 1503
			::__continue176:: -- 1503
			i = i + 1 -- 1495
		end -- 1495
	end -- 1495
	return best -- 1506
end -- 1491
function Play.prototype.refreshCover(self, a, input) -- 1510
	if self.childMode then -- 1510
		self.coverNear = false -- 1512
		self.coverHug = false -- 1513
		self.coverEntity = "" -- 1514
		self.coverBlocking = false -- 1515
		a.covered = false -- 1516
		return -- 1517
	end -- 1517
	local b = self:coverAt(a) -- 1519
	self.coverNear = b ~= nil -- 1520
	a.covered = self.coverNear and input.cover.held -- 1521
	self.coverHug = a.covered -- 1522
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1523
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1524
		b, -- 1524
		a, -- 1524
		self:nearestEnemy(a) -- 1524
	) -- 1524
end -- 1510
function Play.prototype.cartHandleInReach(self, a) -- 1528
	if a == nil then -- 1528
		a = self.player -- 1528
	end -- 1528
	local c = self.room.cart -- 1529
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1529
		return false -- 1531
	end -- 1531
	local handleX = self.cartAxle + c.handleOffset -- 1533
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1534
end -- 1528
function Play.prototype.nearLowLedge(self, a) -- 1539
	local reach = 26 -- 1540
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1541
	local x1 = x0 + reach -- 1542
	local i = 0 -- 1543
	do -- 1543
		i = 0 -- 1544
		while i < #self.boxes do -- 1544
			do -- 1544
				local b = self.boxes[i + 1] -- 1545
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1545
					goto __continue185 -- 1547
				end -- 1547
				local rise = b.y1 - a.y -- 1549
				if rise > 0 and rise <= LEDGE_RISE then -- 1549
					return true -- 1551
				end -- 1551
			end -- 1551
			::__continue185:: -- 1551
			i = i + 1 -- 1544
		end -- 1544
	end -- 1544
	return false -- 1554
end -- 1539
function Play.prototype.stepPlayer(self, a, dt, input) -- 1557
	a.depthSpeed = 0 -- 1558
	if not a.alive then -- 1558
		return -- 1560
	end -- 1560
	local isChild = self.childMode -- 1562
	local lowArch = isChild and self:underLowArch(a) -- 1564
	if self:storyLocked() then -- 1564
		a.vx = 0 -- 1567
		a.crouch = isChild and lowArch -- 1568
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1569
		self:fallY(a, dt) -- 1570
		return -- 1571
	end -- 1571
	if not isChild and self.escort.state == "calming" then -- 1571
		a.crouch = false -- 1575
		a.h = SOLDIER_H -- 1576
		a.vx = 0 -- 1577
		self:fallY(a, dt) -- 1578
		return -- 1579
	end -- 1579
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 1581
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1582
	local nearCover = not isChild and self:nearCover(a) -- 1583
	a.covered = nearCover and input.cover.held -- 1584
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1586
	if a.rollT > 0 then -- 1586
		a.rollT = a.rollT - dt -- 1590
		a.vx = a.facing * ROLL_SPEED -- 1591
		self:slideX(a, a.vx * dt) -- 1592
		self:fallY(a, dt) -- 1593
		if a.rollT <= 0 then -- 1593
			self:flashSet("翻滚结束", 0.5) -- 1595
		end -- 1595
		return -- 1597
	end -- 1597
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1597
		if input.moveX ~= 0 then -- 1597
			a.facing = input.moveX > 0 and 1 or -1 -- 1602
		end -- 1602
		if self:nearLowLedge(a) then -- 1602
			a.vy = SOLDIER_JUMP -- 1606
			a.onGround = false -- 1607
			self:flashSet("翻上去", 0.3) -- 1608
			return -- 1609
		end -- 1609
		a.rollT = ROLL_TIME -- 1611
		self:flashSet("翻滚", 0.3) -- 1612
		return -- 1613
	end -- 1613
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1616
	if isChild then -- 1616
		if input.cover.held then -- 1616
			speed = CHILD_SLOW -- 1619
		end -- 1619
		if a.crouch then -- 1619
			speed = CHILD_SLOW -- 1622
		end -- 1622
	elseif a.covered then -- 1622
		speed = SOLDIER_SPEED * 0.45 -- 1625
	end -- 1625
	local handsBusy = self.gripping or gripIntent -- 1629
	local dir = self.gripping and 0 or input.moveX -- 1630
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 1631
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1632
	if dir ~= 0 then -- 1632
		a.facing = dir > 0 and 1 or -1 -- 1634
	end -- 1634
	a.vx = dir * speed * diagonal -- 1636
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1636
		a.vy = CHILD_JUMP -- 1640
		a.onGround = false -- 1641
		self:flashSet("跳", 0.25) -- 1642
	end -- 1642
	local previousDepth = a.depth -- 1646
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1647
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1648
	self:slideX(a, a.vx * dt) -- 1649
	self:fallY(a, dt) -- 1650
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1650
		self:shoot(a) -- 1654
	end -- 1654
end -- 1557
function Play.prototype.stepPartner(self, p, dt) -- 1659
	local a = self.partner -- 1660
	if not a.alive then -- 1660
		return -- 1662
	end -- 1662
	a.crouch = false -- 1664
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1665
	a.vx = 0 -- 1666
	a.depthSpeed = 0 -- 1667
	self:fallY(a, dt) -- 1668
end -- 1659
function Play.prototype.stepEscort(self, dt, input) -- 1675
	local a = self.partner -- 1676
	a.depthSpeed = 0 -- 1677
	if not a.alive then -- 1677
		return -- 1679
	end -- 1679
	if self.room.key == "gatepath" then -- 1679
		if self.carryOn then -- 1679
			return -- 1684
		end -- 1684
		local p = self.player -- 1687
		a.depth = p.depth -- 1688
		a.facing = p.facing -- 1689
		a.crouch = false -- 1690
		a.h = CHILD_H -- 1691
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 1692
		a.y = p.y -- 1693
		a.vy = 0 -- 1694
		a.vx = p.vx -- 1695
		a.onGround = p.onGround -- 1696
		return -- 1697
	end -- 1697
	if not self:escortOn() then -- 1697
		a.vx = 0 -- 1700
		self:fallY(a, dt) -- 1701
		return -- 1702
	end -- 1702
	local p = self.player -- 1704
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1705
	local hadKnock1 = self.escort.knock1 -- 1706
	local hadKnock2 = self.escort.knock2 -- 1707
	self.calmConsumed = self.escort:update( -- 1708
		input, -- 1708
		p.x, -- 1708
		p.facing, -- 1708
		a.x, -- 1708
		dist -- 1708
	) -- 1708
	if not hadKnock1 and self.escort.knock1 then -- 1708
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1711
	end -- 1711
	if not hadKnock2 and self.escort.knock2 then -- 1711
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1714
	end -- 1714
	a.crouch = self.escort.crouchPose -- 1716
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1717
	if not self.escort.stopped then -- 1717
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1719
		local previousDepth = a.depth -- 1720
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1721
		local distance = math.max( -- 1722
			-travel, -- 1722
			math.min(travel, targetDepth - previousDepth) -- 1722
		) -- 1722
		self:slideDepth(a, distance) -- 1723
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1724
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1724
			a.vy = CHILD_JUMP -- 1726
			a.onGround = false -- 1727
		end -- 1727
	end -- 1727
	local dir = self.escort:moveDir(a.x) -- 1730
	a.vx = dir * CHILD_SPEED -- 1731
	if dir ~= 0 then -- 1731
		a.facing = dir -- 1733
		local before = a.x -- 1734
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1735
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1735
			a.vy = CHILD_JUMP -- 1738
			a.onGround = false -- 1739
		end -- 1739
	end -- 1739
	self:fallY(a, dt) -- 1742
end -- 1675
function Play.prototype.escortOn(self) -- 1746
	if self.room.key == "checkpoint" then -- 1746
		return true -- 1748
	end -- 1748
	if self.room.key == "gatepath" then -- 1748
		return true -- 1751
	end -- 1751
	if self.room.key == "prologue" then -- 1751
		return self.phase == "prologue-follow" -- 1754
	end -- 1754
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 1754
		return true -- 1758
	end -- 1758
	return self.room.key == "street" -- 1760
end -- 1746
function Play.prototype.storyLocked(self) -- 1764
	if self.caughtT > 0 then -- 1764
		return true -- 1766
	end -- 1766
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1766
		return true -- 1769
	end -- 1769
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 1769
		return true -- 1772
	end -- 1772
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1772
		return true -- 1775
	end -- 1775
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 1775
		return true -- 1778
	end -- 1778
	if self.craftBench.active then -- 1778
		return true -- 1782
	end -- 1782
	return false -- 1784
end -- 1764
function Play.prototype.swapToChild(self, x) -- 1788
	local tmp = self.player -- 1789
	self.player = self.partner -- 1790
	self.partner = tmp -- 1791
	self.childMode = true -- 1792
	self.player.alive = true -- 1793
	self.player.x = self.ox + x -- 1794
	self.player.y = 0 -- 1795
	self.player.depth = 0 -- 1796
	self.player.depthSpeed = 0 -- 1797
	self.player.vy = 0 -- 1798
	self.player.vx = 0 -- 1799
	self.player.onGround = true -- 1800
	self.player.crouch = false -- 1801
	self.player.h = CHILD_H -- 1802
	self.player.facing = 1 -- 1803
	self.partner.alive = true -- 1804
	self.cam.x = self.player.x -- 1805
end -- 1788
function Play.prototype.stepStory(self, dt, input) -- 1809
	if self.room.key == "prologue" then -- 1809
		self:stepPrologue(dt, input) -- 1811
	elseif self.room.key == "street" then -- 1811
		self:stepStreet(dt, input) -- 1813
	elseif self.room.key == "gate" then -- 1813
		self:stepGate(dt, input) -- 1815
	elseif self.room.key == "gatepath" then -- 1815
		self:stepGatePath() -- 1817
	elseif self.room.key == "tower" then -- 1817
		self:stepTower(dt, input) -- 1819
	elseif self.room.key == "museum" then -- 1819
		self:stepMuseum(dt, input) -- 1821
	end -- 1821
end -- 1809
function Play.prototype.canPersistProgress(self) -- 1827
	return not self.isCampaign and self.run.source == "official" -- 1828
end -- 1827
function Play.prototype.wellWindow(self) -- 1832
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 1833
end -- 1832
function Play.prototype.nearWell(self) -- 1838
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 1839
end -- 1838
function Play.prototype.pickWell(self) -- 1847
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 1847
		return false -- 1849
	end -- 1849
	self.phase = "prologue-well" -- 1851
	self.phaseTick = 0 -- 1852
	self.wellOpen = false -- 1853
	self:flashSet("井沿 · 伸手下去", 1.4) -- 1854
	self:log("旧井拾取") -- 1855
	return true -- 1856
end -- 1847
function Play.prototype.stepPrologue(self, dt, input) -- 1859
	local child = self.partner -- 1860
	if self.museumReturn then -- 1860
		self.museumReturn = false -- 1863
		self.phase = "prologue-wait" -- 1864
		self.phaseTick = 0 -- 1865
		self.player.x = self.ox + 260 -- 1866
		self.player.y = 0 -- 1867
		self.player.depth = 0 -- 1868
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 1869
	end -- 1869
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 1872
	if self.phase == "prologue-wait" then -- 1872
		child.crouch = true -- 1874
		child.h = CHILD_CROUCH_H -- 1875
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 1875
			self:pickWell() -- 1877
			return -- 1878
		end -- 1878
		if not self.wellOpen and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 1878
			if self:canPersistProgress() then -- 1878
				self.archive.museumPhase = "well_reflect" -- 1884
				self.archiveDirty = true -- 1885
			end -- 1885
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 1887
			return -- 1888
		end -- 1888
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1890
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1892
		if near and input.interact.pressed then -- 1892
			self.phase = "prologue-give" -- 1894
			self.phaseTick = 0 -- 1895
			self:flashSet("递出针套", 1) -- 1896
		end -- 1896
		return -- 1898
	end -- 1898
	if self.phase == "prologue-well" then -- 1898
		self.phaseTick = self.phaseTick + 1 -- 1902
		if self.phaseTick == 12 then -- 1902
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 1904
		elseif self.phaseTick >= 30 then -- 1904
			self.phase = "prologue-wait" -- 1906
			self.phaseTick = 0 -- 1907
			self.wellTaken = true -- 1908
			self.wellOpen = false -- 1909
			self.run.archive.artifactOwned = true -- 1910
			self.archiveDirty = true -- 1911
			self:emit("artifactFound", { -- 1912
				x = self.ox + self.wellX, -- 1913
				y = 0, -- 1913
				room = "prologue", -- 1913
				once = true, -- 1913
				source = self.run.source -- 1914
			}) -- 1914
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 1916
			self:log("井底取到时间穿梭器") -- 1917
		end -- 1917
		return -- 1919
	end -- 1919
	if self.phase == "prologue-give" then -- 1919
		self.phaseTick = self.phaseTick + 1 -- 1922
		if self.phaseTick == 12 then -- 1922
			self:flashSet("针套递过去", 0.7) -- 1924
		elseif self.phaseTick == 36 then -- 1924
			self:flashSet("纸条塞进针套", 0.9) -- 1926
		elseif self.phaseTick >= 60 then -- 1926
			self.phase = "prologue-follow" -- 1928
			self.phaseTick = 0 -- 1929
			child.crouch = false -- 1930
			child.h = CHILD_H -- 1931
			self:flashSet("她跟上了", 1.2) -- 1932
		end -- 1932
		return -- 1934
	end -- 1934
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1934
		self:requestRoom("street", "序章跟到门口") -- 1938
		self:flashSet("进街道", 1.2) -- 1939
	end -- 1939
end -- 1859
function Play.prototype.stepStreet(self, dt, input) -- 1944
	local p = self.player -- 1945
	local c = self.partner -- 1946
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1946
		self:requestRoom("checkpoint", "两人都到街尾") -- 1948
		self:flashSet("到检查站", 1.2) -- 1949
	end -- 1949
end -- 1944
function Play.prototype.stepGate(self, dt, input) -- 1954
	local ____temp_35 -- 1955
	if self.room.story == nil then -- 1955
		____temp_35 = nil -- 1955
	else -- 1955
		____temp_35 = self.room.story.gate -- 1955
	end -- 1955
	local g = ____temp_35 -- 1955
	if g == nil then -- 1955
		return -- 1957
	end -- 1957
	local p = self.player -- 1959
	if self.phase == "gate-idle" then -- 1959
		local a = self.partner -- 1962
		local gap = g.waitX - a.x -- 1963
		if math.abs(gap) > 3 then -- 1963
			a.facing = gap > 0 and 1 or -1 -- 1965
			a.vx = a.facing * CHILD_SPEED -- 1966
			local beforeX = a.x -- 1967
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1968
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1968
				a.vy = CHILD_JUMP -- 1970
				a.onGround = false -- 1971
			end -- 1971
			self:fallY(a, dt) -- 1973
		else -- 1973
			a.vx = 0 -- 1975
			a.x = g.waitX -- 1976
		end -- 1976
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1979
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1980
		if self.gateNeedConfirm then -- 1980
			if not input.interact.held then -- 1980
				self.gateRestartArmed = true -- 1985
			end -- 1985
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1985
				self.gateNeedConfirm = false -- 1988
				self.gateRestartArmed = true -- 1989
				self.phase = "gate-hold" -- 1990
				self.gateTick = 0 -- 1991
				self.gateSpawned = 0 -- 1992
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1993
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1994
			end -- 1994
			return -- 1996
		end -- 1996
		if atWinch and atWait then -- 1996
			self.phase = "gate-hold" -- 1999
			self.gateTick = 0 -- 2000
			self.gateSpawned = 0 -- 2001
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2002
		end -- 2002
		return -- 2004
	end -- 2004
	if self.phase == "gate-hold" then -- 2004
		self.gateTick = self.gateTick + 1 -- 2007
		local marks = {0, 540, 900, 1500} -- 2009
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2009
			local idx = self.gateSpawned -- 2011
			local ____self_enemies_36 = self.enemies -- 2011
			____self_enemies_36[#____self_enemies_36 + 1] = { -- 2012
				x = self.ox + 620 + idx * 62, -- 2013
				y = 0, -- 2013
				w = 26, -- 2013
				h = 84, -- 2013
				alive = true, -- 2014
				hitT = 0, -- 2014
				warnT = 0, -- 2014
				fireCd = 90 + idx * 45 -- 2014
			} -- 2014
			self.gateSpawned = self.gateSpawned + 1 -- 2016
			self:flashSet( -- 2017
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2017
				0.9 -- 2017
			) -- 2017
		end -- 2017
		if self.gateTick == 900 then -- 2017
			self:flashSet("灯灭了", 1) -- 2020
		elseif self.gateTick == 2100 then -- 2020
			self:flashSet("门底压下来了", 1) -- 2022
		end -- 2022
		if self.gateTick >= g.holdTicks then -- 2022
			self:captureGateBlood() -- 2027
			self.phase = "gate-send" -- 2028
			self.phaseTick = 0 -- 2029
			self.enemies = {} -- 2031
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2032
		end -- 2032
		return -- 2034
	end -- 2034
	if self.phase == "gate-send" then -- 2034
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2037
		if near and input.interact.pressed then -- 2037
			self:commitRoute() -- 2040
			self:swapToChild(g.doorX + 30) -- 2041
			self.phase = "gate-count" -- 2042
			self.countTick = 0 -- 2043
			self.countArmed = false -- 2045
			self.countPrevMove = input.moveX -- 2046
			self:flashSet("门开了 · 送她出去", 1.8) -- 2047
		end -- 2047
		return -- 2049
	end -- 2049
	if self.phase == "gate-count" then -- 2049
		self.countTick = self.countTick + 1 -- 2052
		if self.countTick == 360 then -- 2052
			self:flashSet("门关上", 0.9) -- 2054
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2054
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2056
			if self.storyRoute == "soldier" then -- 2056
				self.phase = "gate-wait" -- 2062
				self.phaseTick = 0 -- 2063
				self.knocks = 1 -- 2064
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2065
				self.handArmed = not input.interact.held -- 2067
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2068
			else -- 2068
				self:flashSet("数到二十", 2.2) -- 2070
			end -- 2070
		end -- 2070
		local prevMove = self.countPrevMove -- 2075
		self.countPrevMove = input.moveX -- 2076
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2076
			if prevMove <= 0 and input.moveX > 0 then -- 2076
				self.countArmed = true -- 2079
			end -- 2079
			if self.countArmed and input.moveX > 0 then -- 2079
				self.phase = "gate-walk" -- 2082
				self.phaseTick = 0 -- 2083
				self:flashSet("她迈出第一步", 1.4) -- 2084
				self:emit("storyExit", { -- 2085
					route = "child", -- 2085
					via = "walk", -- 2085
					countTick = self.countTick, -- 2085
					hp = self.hp, -- 2085
					maxHp = self.maxHp -- 2085
				}) -- 2085
			end -- 2085
		end -- 2085
		return -- 2088
	end -- 2088
	if self.phase == "gate-wait" then -- 2088
		self.phaseTick = self.phaseTick + 1 -- 2092
		if self.phaseTick == 12 then -- 2092
			self.knocks = 2 -- 2094
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2095
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2096
		end -- 2096
		if not input.interact.held then -- 2096
			if self.handTicks > 0 then -- 2096
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2100
			end -- 2100
			self.handTicks = 0 -- 2102
			self.handArmed = true -- 2103
			return -- 2104
		end -- 2104
		if self.handArmed then -- 2104
			self.handTicks = self.handTicks + 1 -- 2107
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2107
				self.phase = "gate-hand" -- 2109
				self.phaseTick = 0 -- 2110
				self.handDone = true -- 2111
				self.tied = true -- 2112
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2113
				if not self.lineSaid then -- 2113
					self.lineSaid = true -- 2115
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2116
				end -- 2116
				self:flashSet("我们走吧。", 3) -- 2118
			end -- 2118
		end -- 2118
		return -- 2121
	end -- 2121
	if self.phase == "gate-hand" then -- 2121
		self.phaseTick = self.phaseTick + 1 -- 2125
		if self.phaseTick == 30 then -- 2125
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2127
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2127
			self:emit("storyExit", { -- 2129
				route = "soldier", -- 2129
				via = "hand", -- 2129
				handTicks = self.handTicks, -- 2129
				hp = self.hp, -- 2129
				maxHp = self.maxHp -- 2129
			}) -- 2129
			self:requestRoom("gatepath", "牵手同行") -- 2130
		end -- 2130
		return -- 2132
	end -- 2132
	if self.phase == "gate-walk" then -- 2132
		if self.player.x >= g.exitX then -- 2132
			self:requestRoom("outside", "走出城门") -- 2137
			self:flashSet("出城门 · 城外", 1.4) -- 2138
		end -- 2138
	end -- 2138
end -- 1954
function Play.prototype.captureGateBlood(self) -- 2147
	self.hpAtGate = self.hp -- 2148
	self.maxHpAtGate = self.maxHp -- 2149
end -- 2147
function Play.prototype.commitRoute(self) -- 2156
	if self.storySettled then -- 2156
		return -- 2158
	end -- 2158
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2160
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2161
	self.hpAtGate = hp -- 2162
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2163
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2164
	self.storySettled = true -- 2165
	self:emit("storyRouteLocked", { -- 2166
		route = self.storyRoute, -- 2167
		hp = self.hp, -- 2167
		maxHp = self.maxHp, -- 2167
		hpAtGate = self.hpAtGate, -- 2168
		maxHpAtGate = self.maxHpAtGate -- 2168
	}) -- 2168
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2170
end -- 2156
function Play.prototype.syncStory(self) -- 2174
	if self.isCampaign and self.run.trial ~= nil then -- 2174
		return -- 2176
	end -- 2176
	local s = self.run.story -- 2178
	if s == nil then -- 2178
		return -- 2180
	end -- 2180
	s.hp = self.hp -- 2182
	s.maxHp = self.maxHp -- 2183
	s.route = self.storyRoute -- 2184
	s.settled = self.storySettled -- 2185
	s.hpAtGate = self.hpAtGate -- 2186
	s.maxHpAtGate = self.maxHpAtGate -- 2187
	s.handDone = self.handDone -- 2188
	s.lineSaid = self.lineSaid -- 2189
	s.tied = self.tied -- 2190
	s.carry = self.carryOn -- 2191
	s.museumReturn = self.museumReturn -- 2192
	s.escortDone = self.escortDone -- 2193
	s.craftedWeapon = self.run.story.craftedWeapon -- 2194
	s.ending = self.run.story.ending -- 2195
	if self.room.key == "gate" then -- 2195
		s.phase = self.phase -- 2197
		s.countTick = self.countTick -- 2198
		s.phaseTick = self.phaseTick -- 2199
		s.handTicks = self.handTicks -- 2200
	end -- 2200
end -- 2174
function Play.prototype.stepGatePath(self) -- 2205
	local ____temp_37 -- 2206
	if self.room.story == nil then -- 2206
		____temp_37 = nil -- 2206
	else -- 2206
		____temp_37 = self.room.story.gatepath -- 2206
	end -- 2206
	local gp = ____temp_37 -- 2206
	if self.phase == "gatepath-start" then -- 2206
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2206
			self.carryOn = true -- 2209
			self.phase = "gatepath-carry" -- 2210
			self.phaseTick = 0 -- 2211
			self.pathDone = true -- 2212
			self.escortDone = false -- 2213
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2214
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2215
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2216
		end -- 2216
		return -- 2218
	end -- 2218
	if self.phase == "gatepath-carry" then -- 2218
		self.phaseTick = self.phaseTick + 1 -- 2221
		if self.phaseTick == 20 then -- 2221
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2223
		end -- 2223
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2223
			self:requestRoom(gp.next, "背负进首战") -- 2226
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2227
		end -- 2227
	end -- 2227
end -- 2205
function Play.prototype.carryPose(self) -- 2236
	local p = self.player -- 2237
	local a = self.partner -- 2238
	a.alive = true -- 2239
	a.x = p.x - p.facing * 12 -- 2240
	a.y = p.y + 26 -- 2241
	a.depth = p.depth -- 2242
	a.vx = p.vx -- 2243
	a.vy = 0 -- 2244
	a.onGround = true -- 2245
	a.crouch = false -- 2246
	a.h = CHILD_CROUCH_H -- 2247
	a.facing = p.facing -- 2248
end -- 2236
function Play.prototype.stepMuseum(self, dt, input) -- 2256
	self.partner.alive = false -- 2257
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2258
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2261
	if self.phase == "museum-cabinet" then -- 2261
		if atCase and input.interact.pressed then -- 2261
			self.phase = "museum-hall" -- 2264
			self.phaseTick = 0 -- 2265
			if self:canPersistProgress() then -- 2265
				self.archive.museumPhase = "hall_walk" -- 2267
				self.archiveDirty = true -- 2268
			end -- 2268
			self:emit( -- 2270
				"museumStep", -- 2270
				{ -- 2270
					step = "cabinet", -- 2270
					x = self.ox + mu.cabinetX, -- 2270
					persisted = self:canPersistProgress() -- 2270
				} -- 2270
			) -- 2270
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2271
		end -- 2271
		return -- 2273
	end -- 2273
	if self.phase == "museum-hall" then -- 2273
		if self.player.x >= self.ox + mu.hallX and input.interact.pressed then -- 2273
			self.phase = "museum-lamp" -- 2277
			self.phaseTick = 0 -- 2278
			if self:canPersistProgress() then -- 2278
				self.archive.museumPhase = "lamp_turn" -- 2280
				self.archiveDirty = true -- 2281
			end -- 2281
			self:emit( -- 2283
				"museumStep", -- 2283
				{ -- 2283
					step = "hall", -- 2283
					x = self.ox + mu.hallX, -- 2283
					persisted = self:canPersistProgress() -- 2283
				} -- 2283
			) -- 2283
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2284
		end -- 2284
		return -- 2286
	end -- 2286
	if self.phase == "museum-lamp" then -- 2286
		if self.player.x >= self.ox + mu.lampX and input.interact.pressed then -- 2286
			self.phase = "museum-return" -- 2290
			self.phaseTick = 0 -- 2291
			if self:canPersistProgress() then -- 2291
				self.archive.museumPhase = "return_cabinet" -- 2293
				self.archiveDirty = true -- 2294
			end -- 2294
			self:emit( -- 2296
				"museumStep", -- 2296
				{ -- 2296
					step = "lamp", -- 2296
					x = self.ox + mu.lampX, -- 2296
					persisted = self:canPersistProgress() -- 2296
				} -- 2296
			) -- 2296
			self:flashSet("灯 · 转向西窗", 1.8) -- 2297
		end -- 2297
		return -- 2299
	end -- 2299
	if self.phase == "museum-return" then -- 2299
		if atCase and input.interact.pressed then -- 2299
			self.phase = "museum-knock" -- 2303
			self.phaseTick = 0 -- 2304
			self:emit( -- 2305
				"museumStep", -- 2305
				{ -- 2305
					step = "knock", -- 2305
					count = 1, -- 2305
					x = self.ox + mu.cabinetX, -- 2305
					persisted = self:canPersistProgress() -- 2305
				} -- 2305
			) -- 2305
			self:flashSet("回柜边 · 第一下", 0.8) -- 2306
		end -- 2306
		return -- 2308
	end -- 2308
	if self.phase == "museum-knock" then -- 2308
		self.phaseTick = self.phaseTick + 1 -- 2311
		if self.phaseTick == 8 then -- 2311
			self:emit( -- 2313
				"museumStep", -- 2313
				{ -- 2313
					step = "knock", -- 2313
					count = 2, -- 2313
					x = self.ox + mu.cabinetX, -- 2313
					persisted = self:canPersistProgress() -- 2313
				} -- 2313
			) -- 2313
			self:flashSet("回柜边 · 第二下", 0.8) -- 2314
		elseif self.phaseTick >= 36 then -- 2314
			self.phase = "museum-done" -- 2316
			self.phaseTick = 0 -- 2317
			if self:canPersistProgress() then -- 2317
				self.archive.museumSeen = true -- 2319
				self.archive.museumPhase = "done" -- 2320
				self.archiveDirty = true -- 2321
			end -- 2321
			self:emit( -- 2323
				"museumDone", -- 2323
				{ -- 2323
					steps = 4, -- 2323
					museumSeen = self.archive.museumSeen, -- 2323
					persisted = self:canPersistProgress() -- 2323
				} -- 2323
			) -- 2323
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2324
			self:log("博物馆 · 回柜边") -- 2325
		end -- 2325
		return -- 2327
	end -- 2327
	if input.interact.pressed then -- 2327
		self.museumReturn = true -- 2330
		self:requestRoom("prologue", "回柜边") -- 2331
	end -- 2331
end -- 2256
function Play.prototype.stepTower(self, dt, input) -- 2335
	local ____temp_38 -- 2336
	if self.room.story == nil then -- 2336
		____temp_38 = nil -- 2336
	else -- 2336
		____temp_38 = self.room.story.tower -- 2336
	end -- 2336
	local t = ____temp_38 -- 2336
	if t == nil then -- 2336
		return -- 2338
	end -- 2338
	if self.phase == "tower-wait" then -- 2338
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2341
		if near and input.interact.pressed then -- 2341
			self.phase = "tower-knock" -- 2343
			self.phaseTick = 0 -- 2344
			self.knocks = 1 -- 2345
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2346
			self:flashSet("敲一下", 0.6) -- 2347
		end -- 2347
		return -- 2349
	end -- 2349
	if self.phase == "tower-knock" then -- 2349
		self.phaseTick = self.phaseTick + 1 -- 2352
		if self.phaseTick == 12 then -- 2352
			self.knocks = 2 -- 2354
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2355
			self:flashSet("敲两下 · 第二声", 1) -- 2356
		elseif self.phaseTick >= t.knockTicks then -- 2356
			self.phase = "tower-given" -- 2358
			self.phaseTick = 0 -- 2359
			self:flashSet("门开了 · 提灯", 1.4) -- 2360
		end -- 2360
		return -- 2362
	end -- 2362
	if self.phase == "tower-given" then -- 2362
		local soldier = self.storyRoute == "soldier" -- 2367
		self.phaseTick = self.phaseTick + 1 -- 2368
		if self.phaseTick == 60 then -- 2368
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 2370
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 2371
		elseif self.phaseTick == 120 then -- 2371
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 2373
		elseif self.phaseTick >= 180 then -- 2373
			self.phase = "tower-end" -- 2375
			self.phaseTick = 0 -- 2376
			if not self.run.finished then -- 2376
				self.run.finished = true -- 2378
				local ending = soldier and "reunion" or "lamp" -- 2379
				self.run.story.ending = ending -- 2380
				local ____soldier_39 -- 2383
				if soldier then -- 2383
					____soldier_39 = self.run.story.segments.escort5 == true -- 2384
				else -- 2384
					____soldier_39 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 2385
				end -- 2385
				local played = ____soldier_39 -- 2383
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 2386
				if official then -- 2386
					if soldier then -- 2386
						self.run.archive.soldierCleared = true -- 2390
					else -- 2390
						self.run.archive.childCleared = true -- 2392
					end -- 2392
					self.archiveDirty = true -- 2394
				end -- 2394
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 2396
				self:emit("endingReached", { -- 2397
					route = soldier and "soldier" or "child", -- 2398
					ending = ending, -- 2399
					official = official, -- 2400
					source = self.run.source, -- 2401
					lines = {self.endingLines[1], self.endingLines[2]}, -- 2402
					childCleared = self.run.archive.childCleared, -- 2403
					soldierCleared = self.run.archive.soldierCleared, -- 2404
					artifactOwned = self.run.archive.artifactOwned, -- 2405
					equipped = self.equippedWeapon -- 2406
				}) -- 2406
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 2408
			end -- 2408
		end -- 2408
		return -- 2411
	end -- 2411
	if input.interact.pressed or input.retry.pressed then -- 2411
		self.restartStory = true -- 2415
		self:requestRoom("prologue", "片尾再玩") -- 2416
		self:flashSet("回到序章", 1.4) -- 2417
	end -- 2417
end -- 2335
function Play.prototype.stepChase(self, dt, input) -- 2422
	if self.caughtT > 0 then -- 2422
		self.caughtT = self.caughtT - dt -- 2424
		if self.caughtT <= 0 then -- 2424
			self:recoverFromCaught() -- 2426
		end -- 2426
		return -- 2428
	end -- 2428
	if self.room.key == "village" then -- 2428
		self:stepScavChase() -- 2431
	elseif self.room.key == "forest" then -- 2431
		self:stepDog(dt) -- 2433
		if self.player.x >= self.ox + 1450 then -- 2433
			self:requestRoom("tower", "到林缘北塔") -- 2436
			self:flashSet("林缘 · 北塔", 1.4) -- 2437
		end -- 2437
	end -- 2437
end -- 2422
function Play.prototype.stepScavChase(self) -- 2443
	local s = self.room.scavenger -- 2444
	if s == nil then -- 2444
		return -- 2446
	end -- 2446
	local p = self.player -- 2448
	if self.passed and p.x > self.ox + 440 then -- 2448
		if self.scavChase then -- 2448
			self.scavChase = false -- 2452
			self.scavState = "back" -- 2453
			self.scavT = 0 -- 2454
		end -- 2454
		return -- 2456
	end -- 2456
	local dx = p.x - self.scavX -- 2458
	local dist = math.abs(dx) -- 2459
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 2460
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 2461
	if not self.scavChase then -- 2461
		if visible then -- 2461
			self.scavSee = self.scavSee + 1 -- 2464
			if self.scavSee >= 24 then -- 2464
				self.scavChase = true -- 2466
				self.scavState = "chase" -- 2467
				self.scavTargetX = p.x -- 2468
				self:flashSet("他看见你了", 1.2) -- 2469
			end -- 2469
		else -- 2469
			self.scavSee = 0 -- 2472
		end -- 2472
		return -- 2474
	end -- 2474
	local dir = p.x > self.scavX and 1 or -1 -- 2477
	self.scavX = self.scavX + dir * 96 / 60 -- 2478
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 2478
		self:caught() -- 2480
		return -- 2481
	end -- 2481
	if hidden then -- 2481
		self.scavSee = 0 -- 2485
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 2486
		self.scavT = self.scavT - 1 -- 2487
		if self.scavT <= 0 then -- 2487
			self.scavChase = false -- 2489
			self.scavState = "patrol" -- 2490
			self:flashSet("他失去了目标", 1) -- 2491
		end -- 2491
	end -- 2491
end -- 2443
function Play.prototype.stepDog(self, dt) -- 2497
	local ____temp_40 -- 2498
	if self.room.story == nil then -- 2498
		____temp_40 = nil -- 2498
	else -- 2498
		____temp_40 = self.room.story.dog -- 2498
	end -- 2498
	local dog = ____temp_40 -- 2498
	if dog == nil then -- 2498
		return -- 2500
	end -- 2500
	local p = self.player -- 2502
	local dist = math.abs(p.x - self.dogX) -- 2503
	if self.dogState == "patrol" then -- 2503
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 2505
		if self.dogX < dog.x0 then -- 2505
			self.dogX = dog.x0 -- 2507
			self.dogDir = 1 -- 2508
		elseif self.dogX > dog.x1 then -- 2508
			self.dogX = dog.x1 -- 2510
			self.dogDir = -1 -- 2511
		end -- 2511
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 2513
		if not p.crouch and moving and dist < dog.range then -- 2513
			self.dogState = "ear" -- 2515
			self.dogT = 18 -- 2516
			self.dogTargetX = p.x -- 2517
			self:flashSet("狗转耳朵", 0.8) -- 2518
		end -- 2518
		return -- 2520
	end -- 2520
	if self.dogState == "ear" then -- 2520
		self.dogT = self.dogT - 1 -- 2523
		if self.dogT <= 0 then -- 2523
			self.dogState = "chase" -- 2525
			self.dogTargetX = p.x -- 2526
			self:flashSet("狗追来了", 1.4) -- 2527
		end -- 2527
		return -- 2529
	end -- 2529
	if self.dogState == "chase" then -- 2529
		local dir = p.x > self.dogX and 1 or -1 -- 2532
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 2533
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 2533
			self:caught() -- 2535
			self.dogState = "sniff" -- 2536
			self.dogT = 60 -- 2537
		elseif dist > dog.range * 1.5 or p.crouch then -- 2537
			self.dogState = "sniff" -- 2539
			self.dogT = 60 -- 2540
			self:flashSet("狗停下了", 0.9) -- 2541
		end -- 2541
		return -- 2543
	end -- 2543
	if self.dogState == "sniff" then -- 2543
		self.dogT = self.dogT - 1 -- 2546
		if self.dogT <= 0 then -- 2546
			self.dogState = "back" -- 2548
		end -- 2548
		return -- 2550
	end -- 2550
	local dir = dog.x0 > self.dogX and 1 or -1 -- 2553
	self.dogX = self.dogX + dir * dog.speed * dt -- 2554
	if math.abs(self.dogX - dog.x0) < 2 then -- 2554
		self.dogX = dog.x0 -- 2556
		self.dogState = "patrol" -- 2557
	end -- 2557
end -- 2497
function Play.prototype.caught(self) -- 2561
	self.caughtT = 1 -- 2562
	self:flashSet("被抓 · 回到安全点", 1.6) -- 2563
end -- 2561
function Play.prototype.recoverFromCaught(self) -- 2567
	local p = self.player -- 2568
	p.x = self.ox + 140 -- 2569
	p.y = 0 -- 2570
	p.vy = 0 -- 2571
	p.vx = 0 -- 2572
	p.onGround = true -- 2573
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 2573
		self.scavX = self.room.scavenger.x0 -- 2575
		self.scavState = "patrol" -- 2576
		self.scavSee = 0 -- 2577
		self.scavChase = false -- 2578
		self.scavT = 0 -- 2579
	end -- 2579
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 2579
		self.dogX = self.room.story.dog.x0 -- 2582
		self.dogState = "patrol" -- 2583
		self.dogT = 0 -- 2584
	end -- 2584
	self.cam.x = p.x -- 2586
	self.cam.y = p.y + CAM_LOOK_UP -- 2587
	self:flashSet("回到安全点", 1.2) -- 2588
end -- 2567
function Play.prototype.updateGate(self) -- 2592
	if self.room.key ~= "checkpoint" then -- 2592
		self.gateOpen = false -- 2594
		return -- 2595
	end -- 2595
	local function inZone(x) -- 2597
		return x >= self.ox + 792 and x <= self.ox + 928 -- 2597
	end -- 2597
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 2598
end -- 2592
function Play.prototype.addItem(self, kind) -- 2604
	local inv = self.run.inventory -- 2605
	if kind == "shield" then -- 2605
		if inv.shield >= TOOL_CAP then -- 2605
			return false -- 2608
		end -- 2608
		inv.shield = inv.shield + 1 -- 2610
		return true -- 2611
	end -- 2611
	if kind == "wedge" then -- 2611
		if inv.wedge >= CONSUMABLE_CAP then -- 2611
			return false -- 2615
		end -- 2615
		inv.wedge = inv.wedge + 1 -- 2617
		return true -- 2618
	end -- 2618
	if kind == "ammo" then -- 2618
		if inv.ammo >= CONSUMABLE_CAP then -- 2618
			return false -- 2622
		end -- 2622
		inv.ammo = inv.ammo + 1 -- 2624
		return true -- 2625
	end -- 2625
	if kind == "scrap" then -- 2625
		inv.scrap = inv.scrap + 1 -- 2629
		return true -- 2630
	end -- 2630
	if kind == "wood" then -- 2630
		inv.wood = inv.wood + 1 -- 2633
		return true -- 2634
	end -- 2634
	if kind == "bell" then -- 2634
		inv.bell = inv.bell + 1 -- 2637
		return true -- 2638
	end -- 2638
	if kind == "pass" then -- 2638
		inv.pass = inv.pass + 1 -- 2641
		return true -- 2642
	end -- 2642
	if kind == "quickbelt" then -- 2642
		inv.quickbelt = inv.quickbelt + 1 -- 2645
		return true -- 2646
	end -- 2646
	return false -- 2648
end -- 2604
function Play.prototype.findBox(self, id) -- 2651
	local i = 0 -- 2652
	do -- 2652
		i = 0 -- 2653
		while i < #self.boxes do -- 2653
			if self.boxes[i + 1].id == id then -- 2653
				return self.boxes[i + 1] -- 2655
			end -- 2655
			i = i + 1 -- 2653
		end -- 2653
	end -- 2653
	return nil -- 2658
end -- 2651
function Play.prototype.findWedgeTarget(self) -- 2662
	local best = nil -- 2663
	local bestD = 0 -- 2664
	local i = 0 -- 2665
	do -- 2665
		i = 0 -- 2666
		while i < #self.boxes do -- 2666
			do -- 2666
				local b = self.boxes[i + 1] -- 2667
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 2667
					goto __continue399 -- 2669
				end -- 2669
				if not self:nearBox(b, 26) then -- 2669
					goto __continue399 -- 2672
				end -- 2672
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 2674
				if best == nil or d < bestD then -- 2674
					best = b -- 2676
					bestD = d -- 2677
				end -- 2677
			end -- 2677
			::__continue399:: -- 2677
			i = i + 1 -- 2666
		end -- 2666
	end -- 2666
	return best -- 2680
end -- 2662
function Play.prototype.stepCraft(self, input) -- 2688
	local inv = self.run.inventory -- 2689
	local ____opt_41 = self.run.trial -- 2689
	local required = CRAFT_TICKS - 6 * (____opt_41 and ____opt_41.ranks.craft or 0) -- 2690
	if self.craftT > 0 then -- 2690
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 2690
			self.craftT = 0 -- 2694
			self:flashSet("制作中断", 0.8) -- 2695
			return true -- 2696
		end -- 2696
		self.craftT = self.craftT + 1 -- 2698
		if self.craftT >= required then -- 2698
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 2698
				inv.scrap = inv.scrap - 1 -- 2701
				inv.wedge = inv.wedge + 1 -- 2702
				self:flashSet("制得木楔", 1.2) -- 2703
				self:log("制木楔") -- 2704
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 2705
			end -- 2705
			self.craftT = 0 -- 2707
		end -- 2707
		return true -- 2709
	end -- 2709
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 2709
		self.craftT = 1 -- 2712
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 2713
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 2714
		return true -- 2715
	end -- 2715
	return false -- 2717
end -- 2688
function Play.prototype.nearBox(self, b, reach) -- 2720
	local p = self.player -- 2721
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 2722
end -- 2720
function Play.prototype.findInteract(self) -- 2728
	local p = self.player -- 2729
	local best = nil -- 2730
	local bestD = 1000000000 -- 2731
	local i = 0 -- 2732
	do -- 2732
		i = 0 -- 2733
		while i < #self.boxes do -- 2733
			do -- 2733
				local b = self.boxes[i + 1] -- 2734
				if b.interact == nil or b.broken == true then -- 2734
					goto __continue412 -- 2736
				end -- 2736
				if not self:nearBox(b, b.interact.reach or 27) then -- 2736
					goto __continue412 -- 2739
				end -- 2739
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 2741
				if d < bestD then -- 2741
					bestD = d -- 2743
					best = b -- 2744
				end -- 2744
			end -- 2744
			::__continue412:: -- 2744
			i = i + 1 -- 2733
		end -- 2733
	end -- 2733
	return best -- 2747
end -- 2728
function Play.prototype.stepCampaign(self, dt, input) -- 2751
	local wr = self.room -- 2752
	local p = self.player -- 2753
	if self.reloadT > 0 then -- 2753
		self.reloadT = self.reloadT - 1 -- 2755
	end -- 2755
	if self.bracedShield ~= nil then -- 2755
		self.bracedShield.x = p.x + p.facing * 26 -- 2759
		self.bracedShield.y = p.y -- 2760
		local shBox = __TS__ArrayFind( -- 2761
			self.boxes, -- 2761
			function(____, b) return b.id == "braced_shield" end -- 2761
		) -- 2761
		if shBox ~= nil then -- 2761
			shBox.x0 = self.bracedShield.x - 15 -- 2763
			shBox.x1 = self.bracedShield.x + 15 -- 2764
			shBox.y0 = self.bracedShield.y -- 2765
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 2766
		end -- 2766
	end -- 2766
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 2766
		self.run.route = "drygoods" -- 2772
		self.run.joined = false -- 2773
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 2774
		self:log("转布行线") -- 2775
	end -- 2775
	if wr.key == "escort3" then -- 2775
		local benchX = wr.minX + 560 -- 2779
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 60 -- 2780
		if self.craftBench.active then -- 2780
			if input.interact.pressed or input.pause.pressed then -- 2780
				self:closeCraftBench() -- 2783
			end -- 2783
		elseif nearBench and input.interact.pressed then -- 2783
			self:openCraftBench() -- 2786
		end -- 2786
	end -- 2786
	local i = 0 -- 2790
	do -- 2790
		i = 0 -- 2791
		while i < #self.pickups do -- 2791
			do -- 2791
				local pk = self.pickups[i + 1] -- 2792
				if self.run.taken[pk.id] == true then -- 2792
					goto __continue427 -- 2794
				end -- 2794
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 2796
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 2797
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 2797
					if not self:addItem(pk.kind) then -- 2797
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 2801
						self:log("满包拒绝 " .. pk.kind) -- 2802
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 2803
						goto __continue427 -- 2804
					end -- 2804
					self.run.taken[pk.id] = true -- 2806
					self:flashSet("拾取 " .. pk.label, 1) -- 2807
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 2808
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 2809
				end -- 2809
			end -- 2809
			::__continue427:: -- 2809
			i = i + 1 -- 2791
		end -- 2791
	end -- 2791
	if not self:stepCraft(input) and input.interact.pressed then -- 2791
		self:campaignInteract() -- 2813
	end -- 2813
	self:stepCampaignCart(dt, input) -- 2815
	self:stepCampaignGoal() -- 2816
	self:campaignCheckpoint() -- 2817
end -- 2751
function Play.prototype.campaignCheckpoint(self) -- 2821
	local i = 0 -- 2822
	do -- 2822
		i = 0 -- 2823
		while i < #self.room.marks do -- 2823
			do -- 2823
				local m = self.room.marks[i + 1] -- 2824
				if m.kind ~= 0 then -- 2824
					goto __continue434 -- 2826
				end -- 2826
				local dx = self.player.x - m.x -- 2828
				local dy = self.player.y - m.y -- 2829
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2829
					self.checkpoint = m.x -- 2831
					self:captureCheckpoint(m.x) -- 2832
					self:flashSet("检查点", 1) -- 2833
				end -- 2833
			end -- 2833
			::__continue434:: -- 2833
			i = i + 1 -- 2823
		end -- 2823
	end -- 2823
end -- 2821
function Play.prototype.campaignInteract(self) -- 2839
	local b = self:findInteract() -- 2840
	if b ~= nil then -- 2840
		self:useInteract(b) -- 2842
		return -- 2843
	end -- 2843
	local inv = self.run.inventory -- 2845
	if inv.wedge > 0 then -- 2845
		local w = self:findWedgeTarget() -- 2847
		if w ~= nil then -- 2847
			if w.breakable ~= nil then -- 2847
				local ____w_breakable_43, ____hp_44 = w.breakable, "hp" -- 2847
				____w_breakable_43[____hp_44] = ____w_breakable_43[____hp_44] + (w.breakable.wedgeHp or 1) -- 2850
			end -- 2850
			inv.wedge = inv.wedge - 1 -- 2852
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 2853
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 2855
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 2856
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 2857
			return -- 2858
		end -- 2858
	end -- 2858
	if inv.ammo > 0 and self.reloadT > 0 then -- 2858
		self.reloadT = 0 -- 2863
		self:closeReloadPuzzle() -- 2864
		inv.ammo = inv.ammo - 1 -- 2865
		self:flashSet("备用弹包 · 膛内补满", 1) -- 2866
		self:log("用备用弹包") -- 2867
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 2868
		return -- 2869
	end -- 2869
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 2869
		local p = self.player -- 2873
		self.bracedShield = { -- 2874
			x = p.x + p.facing * 26, -- 2874
			y = p.y, -- 2874
			w = 30, -- 2874
			h = 64, -- 2874
			hp = 1 -- 2874
		} -- 2874
		local ____self_boxes_45 = self.boxes -- 2874
		____self_boxes_45[#____self_boxes_45 + 1] = { -- 2875
			x0 = self.bracedShield.x - 15, -- 2876
			x1 = self.bracedShield.x + 15, -- 2876
			y0 = p.y, -- 2877
			y1 = p.y + 64, -- 2877
			depth = {min = -46, max = 46}, -- 2877
			label = "架起的残盾", -- 2877
			id = "braced_shield", -- 2877
			soft = true -- 2878
		} -- 2878
		inv.shield = inv.shield - 1 -- 2881
		self:flashSet("架残盾 · 挡一发", 1.2) -- 2882
		self:log("架残盾") -- 2883
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 2884
		return -- 2885
	end -- 2885
	if inv.pass > 0 and self.run.joined == false then -- 2885
		inv.pass = inv.pass - 1 -- 2888
		self.run.joined = true -- 2889
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 2890
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 2891
		return -- 2892
	end -- 2892
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 2894
end -- 2839
function Play.prototype.useInteract(self, b) -- 2897
	local kind = b.interact == nil and "" or b.interact.kind -- 2898
	local wr = self.room -- 2899
	if kind == "open_board" then -- 2899
		b.broken = true -- 2901
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 2902
		for ____, cover in ipairs(self.boxes) do -- 2903
			if cover.id == "s2_board_cover" then -- 2903
				cover.broken = false -- 2905
				cover.hidden = false -- 2906
			end -- 2906
		end -- 2906
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 2909
		self.run.joined = true -- 2910
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 2911
		self:log("放下窗板") -- 2912
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 2913
		return -- 2914
	end -- 2914
	if kind == "lower_curtain" then -- 2914
		for ____, curtain in ipairs(self.boxes) do -- 2917
			if curtain.id == "c2_curtain" then -- 2917
				curtain.broken = false -- 2919
				curtain.hidden = false -- 2920
			end -- 2920
		end -- 2920
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 2923
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 2924
		self:log("放下木帘") -- 2925
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 2926
		return -- 2927
	end -- 2927
	if kind == "raise_latch" then -- 2927
		if wr.key == "c2-granary" and not self.cartDocked then -- 2927
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 2931
			return -- 2932
		end -- 2932
		b.broken = true -- 2934
		self.objectiveDone = true -- 2935
		if wr.key == "c1-yard" then -- 2935
			self.run.c1Latch = true -- 2938
			self.run.joined = true -- 2939
		else -- 2939
			self.run.c2Latch = true -- 2941
			self.run.joined = true -- 2942
		end -- 2942
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 2944
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 2945
		self:log("抬闩") -- 2946
		self:flashSet("抬闩 · 通路打开", 1.4) -- 2947
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 2948
	end -- 2948
end -- 2897
function Play.prototype.stepCampaignCart(self, dt, input) -- 2953
	local wr = self.room -- 2954
	local c = wr.cart -- 2955
	if c.bodyW <= 0 then -- 2955
		return -- 2957
	end -- 2957
	local p = self.player -- 2959
	local handleX = self.cartAxle + c.handleOffset -- 2960
	if not self.gripping then -- 2960
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 2960
			self.gripping = true -- 2964
			self:flashSet("握住车柄 · A/D 推", 1) -- 2965
		end -- 2965
		return -- 2967
	end -- 2967
	if input.interact.pressed then -- 2967
		self.gripping = false -- 2970
		self:flashSet("松手", 0.5) -- 2971
		return -- 2972
	end -- 2972
	if not self.cartDocked then -- 2972
		if input.moveX ~= 0 and not self:stuckCart() then -- 2972
			self.cartAxle = math.max( -- 2976
				c.startX, -- 2976
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 2976
			) -- 2976
		end -- 2976
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 2976
			self.cartExposed = true -- 2981
			local gun = nil -- 2982
			local gi = 0 -- 2983
			do -- 2983
				gi = 0 -- 2984
				while gi < #self.enemies do -- 2984
					local e = self.enemies[gi + 1] -- 2985
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 2985
						gun = e -- 2987
						break -- 2988
					end -- 2988
					gi = gi + 1 -- 2984
				end -- 2984
			end -- 2984
			if gun ~= nil then -- 2984
				self:campaignEnemyFire(gun) -- 2992
			end -- 2992
		end -- 2992
		p.x = self.cartAxle + c.handleOffset -- 2995
		p.y = c.baseY + (c.depth or 0) -- 2996
		p.vx = 0 -- 2997
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 2997
			self.cartAxle = c.endX -- 2999
			self.cartDocked = true -- 3000
			self.gripping = false -- 3001
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3002
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3003
			self:flashSet("车轮入窝", 1.2) -- 3004
			self:log("车轮入窝") -- 3005
		end -- 3005
	end -- 3005
end -- 2953
function Play.prototype.stuckCart(self) -- 3011
	local i = 0 -- 3012
	do -- 3012
		i = 0 -- 3013
		while i < #self.boxes do -- 3013
			do -- 3013
				local b = self.boxes[i + 1] -- 3014
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3014
					goto __continue473 -- 3016
				end -- 3016
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 3018
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3018
					return true -- 3020
				end -- 3020
			end -- 3020
			::__continue473:: -- 3020
			i = i + 1 -- 3013
		end -- 3013
	end -- 3013
	return false -- 3023
end -- 3011
function Play.prototype.stepCampaignGoal(self) -- 3027
	local wr = self.room -- 3028
	local c = wr.campaign -- 3029
	if c == nil then -- 3029
		return -- 3031
	end -- 3031
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3031
		self.objectiveDone = true -- 3034
	end -- 3034
	if c.goal == "reach_exit" then -- 3034
		self.objectiveDone = true -- 3037
	end -- 3037
	if not self.objectiveDone then -- 3037
		return -- 3040
	end -- 3040
	local p = self.player -- 3042
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3043
	if p.x < c.exitX or not partnerOk then -- 3043
		return -- 3045
	end -- 3045
	if self.run.story.segments[wr.key] ~= true then -- 3045
		self.run.story.segments[wr.key] = true -- 3049
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3050
	end -- 3050
	if wr.key == "escort5" then -- 3050
		self.escortDone = true -- 3054
		self.run.story.escortDone = true -- 3055
	end -- 3055
	if c.next ~= nil and c.next ~= "" then -- 3055
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3058
		self:flashSet("过关 · " .. c.next, 1.2) -- 3059
	elseif not self.run.finished then -- 3059
		self.run.finished = true -- 3061
		self:flashSet( -- 3062
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3062
			2 -- 3062
		) -- 3062
		self:log("C2 灰盒完成") -- 3063
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3064
	end -- 3064
end -- 3027
function Play.prototype.stepCampaignPartner(self, dt) -- 3069
	local a = self.partner -- 3070
	local wr = self.room -- 3071
	local cp = wr.companion -- 3072
	if not a.alive then -- 3072
		return -- 3074
	end -- 3074
	local p = self.player -- 3076
	if self.craftBench.active then -- 3076
		a.vx = 0 -- 3079
		return -- 3080
	end -- 3080
	local wait = false -- 3082
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3083
	local targetDepth = p.depth -- 3084
	if self.run.joined == false then -- 3084
		wait = true -- 3086
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3087
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3088
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3088
		wait = true -- 3090
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3091
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3092
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3092
		wait = true -- 3094
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3095
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3096
	end -- 3096
	if self.partnerStuck > 0.3 then -- 3096
		a.x = a.x + a.facing * 44 -- 3100
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3101
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3102
		self.partnerLaneHold = 1.1 -- 3103
		self.partnerStuck = 0 -- 3104
	end -- 3104
	if self.partnerLaneHold > 0 then -- 3104
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3107
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3108
	end -- 3108
	local dx = targetX - a.x -- 3110
	if not wait and math.abs(dx) > 74 then -- 3110
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3112
		local before = a.x -- 3113
		a.vx = dx > 0 and speed or -speed -- 3114
		a.facing = dx > 0 and 1 or -1 -- 3115
		self:slideX(a, a.vx * dt) -- 3116
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3116
			a.vy = CHILD_JUMP -- 3119
			a.onGround = false -- 3120
		end -- 3120
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3122
	else -- 3122
		a.vx = 0 -- 3124
		self.partnerStuck = 0 -- 3125
	end -- 3125
	local dz = targetDepth - a.depth -- 3127
	if math.abs(dz) > 6 then -- 3127
		local step = math.max( -- 3129
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3129
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3129
		) -- 3129
		a.depth = a.depth + step -- 3130
	end -- 3130
	a.depthSpeed = 0 -- 3132
	a.h = CHILD_H -- 3133
	a.crouch = false -- 3134
	self:fallY(a, dt) -- 3135
end -- 3069
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3139
	local p = self.player -- 3140
	local i = 0 -- 3141
	do -- 3141
		i = 0 -- 3142
		while i < #self.enemies do -- 3142
			do -- 3142
				local ____opt_46 = self.run.trial -- 3142
				if ____opt_46 and ____opt_46.lost then -- 3142
					return -- 3143
				end -- 3143
				local e = self.enemies[i + 1] -- 3144
				if not e.alive then -- 3144
					goto __continue500 -- 3146
				end -- 3146
				if e.hitT > 0 then -- 3146
					e.hitT = e.hitT - dt -- 3149
				end -- 3149
				if e.kind == "target" then -- 3149
					if not e.alive and e.hitT <= 0 then -- 3149
						e.alive = true -- 3154
					end -- 3154
					goto __continue500 -- 3156
				end -- 3156
				if e.kind == "breaker" then -- 3156
					self:stepBreaker(e, dt) -- 3159
					goto __continue500 -- 3160
				end -- 3160
				if e.kind == "shield" then -- 3160
					self:stepShield(e, dt, input) -- 3163
					goto __continue500 -- 3164
				end -- 3164
				local dx = e.x - p.x -- 3167
				if not e.awake then -- 3167
					if math.abs(dx) > 520 then -- 3167
						goto __continue500 -- 3170
					end -- 3170
					e.awake = true -- 3172
					e.fireCd = 48 -- 3173
					goto __continue500 -- 3174
				end -- 3174
				if math.abs(dx) > ENEMY_RANGE then -- 3174
					goto __continue500 -- 3177
				end -- 3177
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 3177
					goto __continue500 -- 3182
				end -- 3182
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 3182
					goto __continue500 -- 3185
				end -- 3185
				if self:blockedShot(e, p) then -- 3185
					if e.warnT > 0 then -- 3185
						e.warnT = 0 -- 3191
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3192
					end -- 3192
					goto __continue500 -- 3194
				end -- 3194
				if e.warnT > 0 then -- 3194
					e.warnT = e.warnT - 1 -- 3197
					if e.warnT <= 0 then -- 3197
						self:campaignEnemyFire(e) -- 3199
					end -- 3199
				elseif e.fireCd > 0 then -- 3199
					e.fireCd = e.fireCd - 1 -- 3202
					if e.fireCd <= 0 then -- 3202
						e.warnT = WARN_TICKS -- 3204
					end -- 3204
				else -- 3204
					e.fireCd = 40 -- 3207
				end -- 3207
			end -- 3207
			::__continue500:: -- 3207
			i = i + 1 -- 3142
		end -- 3142
	end -- 3142
end -- 3139
function Play.prototype.blockedShot(self, e, p) -- 3213
	local eDepth = e.depth or 0 -- 3214
	local ex = e.x -- 3215
	local ey = e.y + e.h * 0.62 -- 3217
	local px = p.x -- 3218
	local py = p.y + p.h * 0.55 -- 3219
	local dx = px - ex -- 3220
	local dyScreen = py + p.depth - (ey + eDepth) -- 3221
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3222
	if len < 0.01 then -- 3222
		return false -- 3224
	end -- 3224
	local ray = { -- 3228
		x = ex, -- 3229
		y = ey, -- 3229
		dx = dx / len, -- 3230
		dy = (py - ey) / len, -- 3230
		depth = eDepth, -- 3231
		dDepth = (p.depth - eDepth) / len -- 3231
	} -- 3231
	local best = -1 -- 3233
	local j = 0 -- 3234
	do -- 3234
		j = 0 -- 3235
		while j < #self.boxes do -- 3235
			do -- 3235
				local b = self.boxes[j + 1] -- 3236
				if b.broken == true or b.passable == true or b.hidden == true then -- 3236
					goto __continue523 -- 3238
				end -- 3238
				if b.id == "braced_shield" then -- 3238
					goto __continue523 -- 3243
				end -- 3243
				local t = hitBox(ray, b) -- 3245
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3245
					best = t -- 3249
				end -- 3249
			end -- 3249
			::__continue523:: -- 3249
			j = j + 1 -- 3235
		end -- 3235
	end -- 3235
	return best >= 0 -- 3252
end -- 3213
function Play.prototype.campaignEnemyFire(self, e) -- 3255
	local p = self.player -- 3256
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3257
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3257
		local ____self_bracedShield_48, ____hp_49 = self.bracedShield, "hp" -- 3257
		____self_bracedShield_48[____hp_49] = ____self_bracedShield_48[____hp_49] - 1 -- 3259
		self.boxes = __TS__ArrayFilter( -- 3260
			self.boxes, -- 3260
			function(____, b) return b.id ~= "braced_shield" end -- 3260
		) -- 3260
		self.bracedShield = nil -- 3261
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3262
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3263
		return -- 3264
	end -- 3264
	if self:blockedShot(e, p) then -- 3264
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3267
		return -- 3268
	end -- 3268
	local cover = self:blockedByCover(e, p) -- 3270
	if cover ~= nil and self.coverHug then -- 3270
		self.coveredFlash = 0.5 -- 3272
		self:flashSet("掩体挡下", 0.6) -- 3273
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3274
		return -- 3279
	end -- 3279
	if self.invulnT > 0 then -- 3279
		return -- 3282
	end -- 3282
	local ____opt_50 = self.run.trial -- 3282
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_50 and ____opt_50.ranks.guard or 0) -- 3284
	self.craftT = 0 -- 3285
	self.hp = self.hp - 1 -- 3286
	self:emit("actorHit", { -- 3287
		target = "player", -- 3287
		amount = 1, -- 3287
		hp = self.hp, -- 3287
		maxHp = self.maxHp, -- 3287
		enemyX = e.x -- 3287
	}) -- 3287
	self:flashSet( -- 3288
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3288
		0.8 -- 3288
	) -- 3288
	if self.hp <= 0 then -- 3288
		self:campaignFailed() -- 3290
	end -- 3290
end -- 3255
function Play.prototype.stepShield(self, e, dt, input) -- 3295
	local p = self.player -- 3296
	local dx = p.x - e.x -- 3297
	local adx = math.abs(dx) -- 3298
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 3301
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 3302
	if adx > 150 then -- 3302
		local before = e.x -- 3304
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 3305
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 3305
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3308
		end -- 3308
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 3308
		local fromFront = (e.x - p.x) * p.facing > 0 -- 3313
		local rollDodges = p.rollT > 0 and fromFront -- 3314
		if not rollDodges and self.invulnT <= 0 then -- 3314
			local ____opt_52 = self.run.trial -- 3314
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_52 and ____opt_52.ranks.guard or 0) -- 3316
			self.craftT = 0 -- 3317
			self.hp = self.hp - 1 -- 3318
			self:emit("actorHit", { -- 3319
				target = "player", -- 3319
				amount = 1, -- 3319
				hp = self.hp, -- 3319
				maxHp = self.maxHp, -- 3319
				enemyX = e.x -- 3319
			}) -- 3319
			self:flashSet( -- 3320
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3320
				0.8 -- 3320
			) -- 3320
			if self.hp <= 0 then -- 3320
				self:campaignFailed() -- 3322
				return -- 3323
			end -- 3323
		end -- 3323
		e.swingT = 70 -- 3326
	end -- 3326
	if (e.swingT or 0) > 0 then -- 3326
		e.swingT = (e.swingT or 0) - 1 -- 3329
	end -- 3329
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 3329
		local dd = p.depth - (e.depth or 0) -- 3332
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 3333
	end -- 3333
end -- 3295
function Play.prototype.stepBreaker(self, e, dt) -- 3338
	local p = self.player -- 3339
	if e.awake ~= true then -- 3339
		if math.abs(p.x - e.x) < 560 then -- 3339
			e.awake = true -- 3342
		else -- 3342
			return -- 3344
		end -- 3344
	end -- 3344
	local target = nil -- 3347
	local bestD = 1000000000 -- 3348
	local i = 0 -- 3349
	do -- 3349
		i = 0 -- 3350
		while i < #self.boxes do -- 3350
			do -- 3350
				local b = self.boxes[i + 1] -- 3351
				if b.breakable == nil or b.broken == true then -- 3351
					goto __continue547 -- 3353
				end -- 3353
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 3355
				if d < bestD then -- 3355
					bestD = d -- 3357
					target = b -- 3358
				end -- 3358
			end -- 3358
			::__continue547:: -- 3358
			i = i + 1 -- 3350
		end -- 3350
	end -- 3350
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 3361
	local dx = tx - e.x -- 3362
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 3363
	if math.abs(dx) > reach then -- 3363
		local before = e.x -- 3365
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 3366
		if math.abs(e.x - before) < 0.3 then -- 3366
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3368
		end -- 3368
	elseif (e.swingT or 0) <= 0 then -- 3368
		e.swingT = 64 -- 3371
		if target ~= nil then -- 3371
			self:damageProp(target, 2) -- 3373
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 3373
			local ____opt_54 = self.run.trial -- 3373
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_54 and ____opt_54.ranks.guard or 0) -- 3375
			self.craftT = 0 -- 3376
			self.hp = self.hp - 1 -- 3377
			self:emit("actorHit", { -- 3378
				target = "player", -- 3378
				amount = 1, -- 3378
				hp = self.hp, -- 3378
				maxHp = self.maxHp, -- 3378
				enemyX = e.x -- 3378
			}) -- 3378
			self:flashSet("破障手近身", 0.8) -- 3379
			if self.hp <= 0 then -- 3379
				self:campaignFailed() -- 3381
				return -- 3382
			end -- 3382
		end -- 3382
	end -- 3382
	if (e.swingT or 0) > 0 then -- 3382
		e.swingT = (e.swingT or 0) - 1 -- 3387
	end -- 3387
end -- 3338
function Play.prototype.campaignFailed(self) -- 3391
	if self.run.trial ~= nil then -- 3391
		self.run.trial.lost = true -- 3393
		self.wantRoom = "" -- 3394
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3395
		return -- 3396
	end -- 3396
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 3396
		self:restartEscortFromDeath() -- 3401
		return -- 3402
	end -- 3402
	local p = self.player -- 3404
	self.hp = self.maxHp -- 3405
	self.invulnT = INVULN_RESPAWN_TICKS -- 3406
	self.reloadT = 0 -- 3407
	self:closeReloadPuzzle() -- 3408
	self.gripping = false -- 3409
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 3410
	self:log("被击倒") -- 3411
	p.x = self.room.minX + 90 -- 3412
	p.y = 0 -- 3413
	p.depth = 0 -- 3414
	p.vx = 0 -- 3415
	p.vy = 0 -- 3416
	p.onGround = true -- 3417
	p.rollT = 0 -- 3418
	self.partner.x = p.x - 50 -- 3419
	self.partner.y = 0 -- 3420
	self.partner.depth = 0 -- 3421
	self.cam.x = p.x -- 3422
	local i = 0 -- 3423
	do -- 3423
		i = 0 -- 3424
		while i < #self.enemies do -- 3424
			do -- 3424
				local e = self.enemies[i + 1] -- 3425
				if not e.alive then -- 3425
					goto __continue561 -- 3427
				end -- 3427
				e.x = e.homeX == nil and e.x or e.homeX -- 3429
				e.warnT = 0 -- 3430
				e.fireCd = 40 -- 3431
				e.swingT = 0 -- 3432
				e.awake = false -- 3433
			end -- 3433
			::__continue561:: -- 3433
			i = i + 1 -- 3424
		end -- 3424
	end -- 3424
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3435
end -- 3391
function Play.prototype.isEscortRoom(self) -- 3439
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 3440
end -- 3439
function Play.prototype.restartEscortFromDeath(self) -- 3448
	local story = self.run.story -- 3449
	local inv = self.run.inventory -- 3450
	self.hp = self.maxHp -- 3451
	story.hp = self.maxHp -- 3452
	story.cp = nil -- 3453
	self.checkpointSnap = nil -- 3454
	story.carry = false -- 3455
	self.carryOn = false -- 3456
	story.craftedWeapon = "" -- 3457
	self.equippedWeapon = "standard_gun" -- 3458
	story.escortDone = false -- 3459
	self.escortDone = false -- 3460
	story.segments = {} -- 3461
	inv.wood = 0 -- 3462
	inv.bell = 0 -- 3463
	inv.scrap = 0 -- 3464
	inv.wedge = 0 -- 3465
	inv.ammo = 0 -- 3466
	inv.quickbelt = 0 -- 3467
	inv.shield = 0 -- 3468
	inv.pass = 0 -- 3469
	local taken = self.run.taken -- 3470
	local keys = __TS__ObjectKeys(taken) -- 3471
	local i = 0 -- 3472
	do -- 3472
		i = 0 -- 3473
		while i < #keys do -- 3473
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 3473
				__TS__Delete(taken, keys[i + 1]) -- 3475
			end -- 3475
			i = i + 1 -- 3473
		end -- 3473
	end -- 3473
	self.run.joined = true -- 3478
	self.reloadT = 0 -- 3479
	self:closeReloadPuzzle() -- 3480
	self.gripping = false -- 3481
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 3482
	self:log("男主线失败 · 回 escort1") -- 3483
	self:emit("campaignFailed", { -- 3484
		room = self.room.key, -- 3485
		hp = 0, -- 3485
		maxHp = self.maxHp, -- 3485
		reset = true, -- 3486
		to = "escort1", -- 3486
		route = self.storyRoute -- 3486
	}) -- 3486
	self:requestRoom("escort1", "男主线失败重开") -- 3488
end -- 3448
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 3492
	local i = 0 -- 3493
	do -- 3493
		i = 0 -- 3494
		while i < #self.enemies do -- 3494
			do -- 3494
				if i == skipIndex then -- 3494
					goto __continue570 -- 3496
				end -- 3496
				local e = self.enemies[i + 1] -- 3498
				if not e.alive or math.abs(e.x - center.x) > radius then -- 3498
					goto __continue570 -- 3500
				end -- 3500
				e.fireCd = 150 -- 3502
				e.warnT = 0 -- 3503
			end -- 3503
			::__continue570:: -- 3503
			i = i + 1 -- 3494
		end -- 3494
	end -- 3494
end -- 3492
function Play.prototype.stepEnemies(self, dt, input) -- 3507
	local i = 0 -- 3508
	do -- 3508
		i = 0 -- 3509
		while i < #self.enemies do -- 3509
			local e = self.enemies[i + 1] -- 3510
			if e.hitT > 0 then -- 3510
				e.hitT = e.hitT - dt -- 3512
			end -- 3512
			i = i + 1 -- 3509
		end -- 3509
	end -- 3509
	if self.coveredFlash > 0 then -- 3509
		self.coveredFlash = self.coveredFlash - dt -- 3516
	end -- 3516
	if self.isCampaign then -- 3516
		self:stepCampaignEnemies(dt, input) -- 3519
		return -- 3520
	end -- 3520
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 3520
		return -- 3524
	end -- 3524
	do -- 3524
		i = 0 -- 3526
		while i < #self.enemies do -- 3526
			do -- 3526
				local e = self.enemies[i + 1] -- 3527
				if not e.alive then -- 3527
					goto __continue581 -- 3529
				end -- 3529
				if e.warnT > 0 then -- 3529
					e.warnT = e.warnT - 1 -- 3532
					if e.warnT <= 0 then -- 3532
						self:enemyFire(e, input) -- 3534
					end -- 3534
					goto __continue581 -- 3536
				end -- 3536
				if e.fireCd > 0 then -- 3536
					e.fireCd = e.fireCd - 1 -- 3539
					if e.fireCd <= 0 then -- 3539
						e.warnT = WARN_TICKS -- 3541
					end -- 3541
				else -- 3541
					e.warnT = WARN_TICKS -- 3545
				end -- 3545
			end -- 3545
			::__continue581:: -- 3545
			i = i + 1 -- 3526
		end -- 3526
	end -- 3526
end -- 3507
function Play.prototype.enemyFire(self, e, input) -- 3551
	local p = self.player -- 3552
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 3552
		self:flashSet("枪声响在远处", 0.4) -- 3554
		e.fireCd = FIRE_COOLDOWN -- 3555
		return -- 3556
	end -- 3556
	local cover = self:blockedByCover(e, p) -- 3559
	local hugging = cover ~= nil -- 3560
	self.coverBlocking = hugging -- 3561
	local covered = hugging and input.cover.held -- 3562
	if covered then -- 3562
		self.coveredFlash = 0.5 -- 3564
		self:flashSet("掩体挡下", 0.5) -- 3565
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3566
		e.fireCd = FIRE_COOLDOWN -- 3571
		return -- 3572
	end -- 3572
	self.hp = self.hp - 1 -- 3574
	self:emit("actorHit", { -- 3575
		target = "player", -- 3575
		amount = 1, -- 3575
		hp = self.hp, -- 3575
		maxHp = self.maxHp, -- 3575
		enemyX = e.x -- 3575
	}) -- 3575
	self:flashSet( -- 3576
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3576
		0.7 -- 3576
	) -- 3576
	e.fireCd = FIRE_COOLDOWN -- 3577
	if self.hp <= 0 then -- 3577
		self:gateFailed() -- 3579
	end -- 3579
end -- 3551
function Play.prototype.blockedByCover(self, enemy, p) -- 3584
	local b = self:coverAt(p) -- 3585
	if b == nil then -- 3585
		return nil -- 3587
	end -- 3587
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 3589
end -- 3584
function Play.prototype.gateFailed(self) -- 3593
	local ____temp_56 -- 3594
	if self.room.story == nil then -- 3594
		____temp_56 = nil -- 3594
	else -- 3594
		____temp_56 = self.room.story.gate -- 3594
	end -- 3594
	local g = ____temp_56 -- 3594
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 3595
	self.hp = self.maxHp -- 3596
	self.gateTick = 0 -- 3597
	self.gateSpawned = 0 -- 3598
	self.enemies = {} -- 3599
	self.gateFailCount = self.gateFailCount + 1 -- 3600
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 3602
	self.player.y = 0 -- 3603
	self.player.vy = 0 -- 3604
	self.player.depth = 0 -- 3605
	self.player.depthSpeed = 0 -- 3606
	self.player.onGround = true -- 3607
	self.player.crouch = false -- 3608
	self.player.h = SOLDIER_H -- 3609
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 3610
	self.partner.y = 0 -- 3611
	self.partner.vy = 0 -- 3612
	self.partner.depth = 0 -- 3613
	self.partner.depthSpeed = 0 -- 3614
	self.partner.onGround = true -- 3615
	self.cam.x = self.player.x -- 3616
	self.phase = "gate-idle" -- 3617
	self.phaseTick = 0 -- 3618
	self.coverHug = false -- 3619
	self.coverBlocking = false -- 3620
	self.coverEntity = "" -- 3621
	self.gateNeedConfirm = true -- 3622
	self.gateRestartArmed = false -- 3623
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 3624
end -- 3593
function Play.prototype.stepInteract(self, dt, input) -- 3627
	local p = self.player -- 3628
	local calmUsed = self.calmConsumed -- 3629
	self.calmConsumed = false -- 3630
	local calming = self.escort.state == "calming" -- 3632
	self.focusCart = false -- 3633
	if self.room.key == "outside" then -- 3633
		local c = self.room.cart -- 3635
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 3636
		local dy = p.y - c.baseY -- 3637
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 3638
	end -- 3638
	if not calmUsed and not calming then -- 3638
		self:stepCart(dt, input) -- 3642
	end -- 3642
	if calmUsed then -- 3642
		self:flashSet("安抚 · 敲两下", 0.8) -- 3647
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 3647
		if self.knockT > 0 then -- 3647
			self.knocks = self.knocks + 1 -- 3651
		else -- 3651
			self.knocks = 1 -- 3653
		end -- 3653
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 3655
		self.knockT = 1.2 -- 3656
		if self.knocks >= 2 then -- 3656
			self:flashSet("敲两下", 0.8) -- 3658
			self.knocks = 0 -- 3659
		else -- 3659
			self:flashSet("敲一下", 0.5) -- 3661
		end -- 3661
	elseif self.knockT > 0 then -- 3661
		self.knockT = self.knockT - dt -- 3664
		if self.knockT <= 0 then -- 3664
			self.knocks = 0 -- 3666
		end -- 3666
	end -- 3666
	local i = 0 -- 3671
	do -- 3671
		i = 0 -- 3672
		while i < #self.room.marks do -- 3672
			do -- 3672
				local m = self.room.marks[i + 1] -- 3673
				if m.kind ~= 0 then -- 3673
					goto __continue607 -- 3675
				end -- 3675
				local subjects = {self.partner, self.player} -- 3677
				local k = 0 -- 3678
				do -- 3678
					k = 0 -- 3679
					while k < #subjects do -- 3679
						do -- 3679
							local s = subjects[k + 1] -- 3680
							if not s.alive then -- 3680
								goto __continue610 -- 3682
							end -- 3682
							local dx = s.x - m.x -- 3684
							local dy = s.y - m.y -- 3685
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3685
								self.checkpoint = m.x -- 3687
								self.checkpointCartAxle = self.cartAxle -- 3688
								if self.isCampaign then -- 3688
									self:captureCheckpoint(m.x) -- 3691
								end -- 3691
								if self.cartDocked then -- 3691
									self:flashSet("检查点 · 车已落窝", 1) -- 3694
								else -- 3694
									self:flashSet("检查点 · 车还没到位", 1) -- 3696
								end -- 3696
							end -- 3696
						end -- 3696
						::__continue610:: -- 3696
						k = k + 1 -- 3679
					end -- 3679
				end -- 3679
			end -- 3679
			::__continue607:: -- 3679
			i = i + 1 -- 3672
		end -- 3672
	end -- 3672
	self:checkCarryGate() -- 3702
end -- 3627
function Play.prototype.stepVillage(self, dt, input) -- 3706
	if self.room.key ~= "village" then -- 3706
		return -- 3708
	end -- 3708
	local p = self.player -- 3710
	local bottle = self.room.bottle -- 3711
	local scav = self.room.scavenger -- 3712
	if not self.hasBottle and bottle ~= nil then -- 3712
		local dx = p.x - bottle.x -- 3716
		local dy = p.y + p.h * 0.5 - bottle.y -- 3717
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 3717
			self.hasBottle = true -- 3719
			self:flashSet("拾起瓶子", 0.8) -- 3720
		end -- 3720
	end -- 3720
	if self.hasBottle then -- 3720
		if input.aim.held then -- 3720
			self.aimHold = self.aimHold + dt -- 3727
			if self.aimHold > 1.2 then -- 3727
				self.aimHold = 1.2 -- 3729
			end -- 3729
			local cached = self:bottleEnd() -- 3732
			self.bottleAimX = cached.x -- 3733
			self.bottleAimY = cached.y -- 3734
		elseif input.aim.released then -- 3734
			if self.aimHold < 0.12 then -- 3734
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 3738
				self.aimHold = 0 -- 3739
			else -- 3739
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3741
				self:throwBottle(____end.x, ____end.y) -- 3742
				self.aimHold = 0 -- 3743
			end -- 3743
		end -- 3743
	else -- 3743
		self.aimHold = 0 -- 3747
		self.bottleAimX = -1 -- 3748
	end -- 3748
	local fly = self.bottleFly -- 3753
	if fly ~= nil then -- 3753
		fly.t = fly.t + dt -- 3755
		fly.x = fly.x0 + fly.vx * fly.t -- 3756
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 3757
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 3758
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 3758
			self:landBottle(fly) -- 3760
		end -- 3760
	end -- 3760
	if self.bottleLandT > 0 then -- 3760
		self.bottleLandT = self.bottleLandT - dt -- 3764
	end -- 3764
	if scav ~= nil then -- 3764
		self:stepScav(dt, scav) -- 3768
	end -- 3768
	local line = self.room.passLine -- 3771
	if line ~= nil and not self.passed and p.x >= line then -- 3771
		self.passed = true -- 3773
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 3774
	end -- 3774
	if self.passed and p.x >= self.ox + 640 then -- 3774
		self:requestRoom("forest", "过第一院出院") -- 3778
		self:flashSet("出院 · 北塔森林", 1.4) -- 3779
	end -- 3779
end -- 3706
function Play.prototype.bottleEnd(self) -- 3784
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3785
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 3788
	return {x = aim.x, y = g} -- 3789
end -- 3784
function Play.prototype.throwBottle(self, tx, ty) -- 3793
	local p = self.player -- 3794
	local dir = tx >= p.x and 1 or -1 -- 3796
	p.facing = dir -- 3797
	local x0 = p.x + dir * 10 -- 3798
	local y0 = p.y + p.h * 0.7 -- 3799
	self.bottleTargetX = tx -- 3800
	self.bottleTargetY = ty -- 3801
	self.bottleSurfaceY = ty -- 3802
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 3803
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 3804
	self.bottleFly = { -- 3805
		x = x0, -- 3805
		y = y0, -- 3805
		x0 = x0, -- 3805
		y0 = y0, -- 3805
		vx = vx, -- 3805
		vy = vy, -- 3805
		t = 0 -- 3805
	} -- 3805
	self.hasBottle = false -- 3806
	self:flashSet("投出", 0.4) -- 3807
	self:emit( -- 3808
		"bottleThrown", -- 3808
		{ -- 3808
			fromX = x0, -- 3809
			fromY = y0, -- 3810
			targetX = tx, -- 3811
			targetY = ty, -- 3812
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 3813
		} -- 3813
	) -- 3813
end -- 3793
function Play.prototype.landBottle(self, fly) -- 3818
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 3819
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 3820
	local s = self.room.scavenger -- 3821
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 3822
	self.bottleFly = nil -- 3823
	self.bottleTargetX = -1 -- 3824
	self.bottleTargetY = 0 -- 3825
	self.bottleSurfaceY = -1 -- 3826
	self.bottleLandX = x -- 3827
	self.bottleLandY = y -- 3828
	self.bottleLandT = 0.9 -- 3829
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 3830
	self:hearBottle(x) -- 3831
end -- 3818
function Play.prototype.hearBottle(self, x) -- 3835
	local s = self.room.scavenger -- 3836
	if s == nil then -- 3836
		return -- 3838
	end -- 3838
	if math.abs(x - self.scavX) > s.range then -- 3838
		self:flashSet("落地 · 他没听见", 0.6) -- 3841
		return -- 3842
	end -- 3842
	self.scavState = "turn" -- 3844
	self.scavT = s.hearTicks -- 3845
	self.scavTargetX = x -- 3846
	self:flashSet("砖地一响 · 他转头", 0.9) -- 3847
end -- 3835
function Play.prototype.stepScav(self, dt, s) -- 3851
	if self.scavState == "chase" then -- 3851
		return -- 3854
	end -- 3854
	if self.scavState == "turn" then -- 3854
		self.scavT = self.scavT - 1 -- 3857
		if self.scavT <= 0 then -- 3857
			self.scavState = "walk" -- 3859
		end -- 3859
		return -- 3861
	end -- 3861
	if self.scavState == "walk" then -- 3861
		local d = self.scavTargetX - self.scavX -- 3864
		if math.abs(d) < 4 then -- 3864
			self.scavState = "stall" -- 3866
			self.scavT = s.stallTicks -- 3867
			return -- 3868
		end -- 3868
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 3870
		return -- 3871
	end -- 3871
	if self.scavState == "stall" then -- 3871
		self.scavT = self.scavT - 1 -- 3874
		if self.scavT <= 0 then -- 3874
			self.scavState = "back" -- 3876
		end -- 3876
		return -- 3878
	end -- 3878
	if self.scavState == "back" then -- 3878
		local home = math.max( -- 3881
			s.x0, -- 3881
			math.min(s.x1, self.scavX) -- 3881
		) -- 3881
		if math.abs(home - self.scavX) < 2 then -- 3881
			self.scavState = "patrol" -- 3883
			return -- 3884
		end -- 3884
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 3886
		return -- 3887
	end -- 3887
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 3889
	if self.scavX >= s.x1 then -- 3889
		self.scavX = s.x1 -- 3891
		self.scavDir = -1 -- 3892
	elseif self.scavX <= s.x0 then -- 3892
		self.scavX = s.x0 -- 3894
		self.scavDir = 1 -- 3895
	end -- 3895
end -- 3851
function Play.prototype.stepCart(self, dt, input) -- 3903
	local p = self.player -- 3904
	local c = self.room.cart -- 3905
	if self.gripping then -- 3905
		if not input.interact.held then -- 3905
			self.gripping = false -- 3909
			self:flashSet("松开车把", 0.4) -- 3910
			return -- 3911
		end -- 3911
	else -- 3911
		if not input.interact.pressed then -- 3911
			return -- 3915
		end -- 3915
		if not self:cartHandleInReach(p) then -- 3915
			return -- 3918
		end -- 3918
		local track = c.depth or 0 -- 3920
		if self:limitDepth(p, track) ~= track then -- 3920
			return -- 3922
		end -- 3922
		p.depth = track -- 3924
		p.depthSpeed = 0 -- 3925
		self.gripping = true -- 3926
		self:flashSet("握住车把", 0.4) -- 3927
		return -- 3928
	end -- 3928
	if self.cartDocked then -- 3928
		return -- 3932
	end -- 3932
	local dir = input.moveX -- 3934
	if dir == 0 then -- 3934
		return -- 3936
	end -- 3936
	local lo = math.min(c.startX, c.endX) -- 3938
	local hi = math.max(c.startX, c.endX) -- 3939
	local next = self.cartAxle + dir * CART_SPEED * dt -- 3940
	if next < lo then -- 3940
		next = lo -- 3942
	end -- 3942
	if next > hi then -- 3942
		next = hi -- 3945
	end -- 3945
	local delta = next - self.cartAxle -- 3947
	if delta == 0 then -- 3947
		return -- 3949
	end -- 3949
	self.cartAxle = next -- 3951
	p.x = p.x + delta -- 3952
	p.facing = dir > 0 and 1 or -1 -- 3953
	self:slideX(p, 0) -- 3954
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 3954
		self.gripping = false -- 3956
		self:flashSet("跟不上了，脱手", 0.6) -- 3957
		return -- 3958
	end -- 3958
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 3958
		self.cartDocked = true -- 3961
		self.gripping = false -- 3962
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 3963
		self:flashSet("车轮落窝", 1.2) -- 3964
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 3964
		self:flashSet("车轮回到起点", 0.5) -- 3966
	end -- 3966
end -- 3903
function Play.prototype.requestRoom(self, key, reason) -- 3974
	if self.wantRoom ~= "" then -- 3974
		return -- 3978
	end -- 3978
	self.wantRoom = key -- 3980
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 3981
end -- 3974
function Play.prototype.checkCarryGate(self) -- 3988
	if self.room.key == "checkpoint" then -- 3988
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 3988
			self.carryCartAxle = self.cartAxle -- 3991
			self.carryCartDocked = self.cartDocked -- 3992
			self:requestRoom("gate", "检查站出口") -- 3993
			self:flashSet("出检查站 · 城门", 1.2) -- 3994
		end -- 3994
		return -- 3996
	end -- 3996
	if self.room.key == "outside" then -- 3996
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 3996
			self.carryCartAxle = self.cartAxle -- 4002
			self.carryCartDocked = self.cartDocked -- 4003
			self:requestRoom("village", "墙根走完") -- 4004
			self:flashSet("墙根走完 · 进村口", 1.2) -- 4005
		end -- 4005
	end -- 4005
end -- 3988
function Play.prototype.aimAt(self, wx, wy) -- 4012
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 4013
	self.aimX = s.x -- 4014
	self.aimY = s.y -- 4015
end -- 4012
function Play.prototype.shoot(self, a) -- 4018
	if self.isCampaign and self.reloadT > 0 then -- 4018
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 4020
		return -- 4021
	end -- 4021
	local ox = a.x + a.facing * 8 -- 4023
	local muzzleY = a.y + a.h * 0.72 -- 4024
	local oy = muzzleY + a.depth -- 4025
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4027
	local dx = aim.x - ox -- 4030
	local dy = aim.y - oy -- 4031
	local len = math.sqrt(dx * dx + dy * dy) -- 4032
	if len < 0.001 then -- 4032
		dx = a.facing -- 4034
		dy = 0 -- 4035
	else -- 4035
		dx = dx / len -- 4037
		dy = dy / len -- 4038
	end -- 4038
	if dx ~= 0 then -- 4038
		a.facing = dx > 0 and 1 or -1 -- 4041
	end -- 4041
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 4044
	local hitEnemy = self:raycastEnemies(ray) -- 4045
	local tEnemy = hitEnemy.t -- 4046
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 4047
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 4048
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 4049
	local tWall = solid.t -- 4050
	local rawEffect = self:consumeReloadEffect() -- 4052
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 4053
	local reloadEffect = rawEffect -- 4054
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 4056
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 4057
	self.trace = { -- 4059
		x0 = ox, -- 4059
		y0 = oy, -- 4059
		x1 = ox + dx * t, -- 4059
		y1 = oy + dy * t, -- 4059
		hit = hit -- 4059
	} -- 4059
	self.traceT = 0.12 -- 4060
	self:applyFireDanger(ox) -- 4061
	local killed = false -- 4062
	if hit then -- 4062
		local i = hitEnemy.index -- 4064
		local e = self.enemies[i + 1] -- 4065
		local impactY = oy + dy * tEnemy -- 4066
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 4067
		local shieldTop = e.y + (e.depth or 0) + 64 -- 4068
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 4068
			e.shieldHp = (e.shieldHp or 0) - 1 -- 4070
			e.hitT = 0.3 -- 4071
			self:flashSet( -- 4072
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 4072
				0.8 -- 4072
			) -- 4072
			self:emit("shotResolved", { -- 4073
				hit = true, -- 4074
				enemyIndex = i, -- 4074
				enemyX = e.x, -- 4074
				aimX = aim.x, -- 4074
				aimY = aim.y, -- 4074
				impactX = ox + dx * t, -- 4075
				impactY = oy + dy * t, -- 4075
				shield = true -- 4075
			}) -- 4075
			self:beginReload() -- 4077
			return -- 4078
		end -- 4078
		e.alive = false -- 4080
		e.hitT = 0.4 -- 4081
		killed = true -- 4082
		self:flashSet("命中", 0.6) -- 4083
		self:dropFor(e) -- 4084
		if reloadEffect == "light" and weaponFx == "light" then -- 4084
			self:blindNearby(e, 160, i) -- 4086
		end -- 4086
		if reloadEffect == "push" then -- 4086
			e.x = e.x + a.facing * 46 -- 4089
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4090
		elseif reloadEffect == "echo" then -- 4090
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 4092
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 4093
		elseif reloadEffect == "light" then -- 4093
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 4095
		end -- 4095
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 4095
		self:damageProp(solid.box, 1) -- 4098
	else -- 4098
		self:flashSet("打空", 0.35) -- 4100
	end -- 4100
	if self.isCampaign then -- 4100
		self:beginReload() -- 4103
	end -- 4103
	self:emit("shotResolved", { -- 4105
		hit = hit, -- 4106
		enemyIndex = hit and hitEnemy.index or -1, -- 4107
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 4108
		aimX = aim.x, -- 4109
		aimY = aim.y, -- 4110
		impactX = ox + dx * t, -- 4111
		impactY = oy + dy * t -- 4112
	}) -- 4112
end -- 4018
function Play.prototype.applyFireDanger(self, shotX) -- 4117
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 4117
		return -- 4119
	end -- 4119
	local dangerX = shotX -- 4121
	local best = -1 -- 4122
	local bestD = 1000000000 -- 4123
	local i = 0 -- 4124
	do -- 4124
		i = 0 -- 4125
		while i < #self.enemies do -- 4125
			do -- 4125
				local e = self.enemies[i + 1] -- 4126
				if not e.alive then -- 4126
					goto __continue691 -- 4128
				end -- 4128
				local d = math.abs(e.x - self.partner.x) -- 4130
				if d < bestD then -- 4130
					bestD = d -- 4132
					best = i -- 4133
				end -- 4133
			end -- 4133
			::__continue691:: -- 4133
			i = i + 1 -- 4125
		end -- 4125
	end -- 4125
	if best >= 0 then -- 4125
		dangerX = self.enemies[best + 1].x -- 4137
	end -- 4137
	local exposed = self:childExposed(dangerX) -- 4139
	local before = self.escort.fear -- 4140
	local dangerId = self.nextDangerId -- 4141
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 4142
	self.nextDangerId = self.nextDangerId + 1 -- 4143
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 4144
	if after > before then -- 4144
		self:flashSet( -- 4146
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 4146
			1 -- 4146
		) -- 4146
	elseif not exposed then -- 4146
		self:flashSet("枪声没够到她", 0.5) -- 4148
	end -- 4148
end -- 4117
function Play.prototype.childExposed(self, dangerX) -- 4153
	local c = self.partner -- 4154
	if not c.alive then -- 4154
		return false -- 4156
	end -- 4156
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 4156
		self.boxes, -- 4159
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 4159
	) then -- 4159
		return false -- 4160
	end -- 4160
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 4160
		return false -- 4163
	end -- 4163
	local toDanger = dangerX - c.x -- 4165
	local toPlayer = self.player.x - c.x -- 4166
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 4166
		return false -- 4169
	end -- 4169
	return true -- 4171
end -- 4153
function Play.prototype.raycastEnemies(self, ray) -- 4175
	local best = -1 -- 4176
	local bestI = -1 -- 4177
	do -- 4177
		local i = 0 -- 4178
		while i < #self.enemies do -- 4178
			do -- 4178
				local e = self.enemies[i + 1] -- 4179
				if not e.alive then -- 4179
					goto __continue705 -- 4181
				end -- 4181
				local y = e.y + (e.depth or 0) -- 4183
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 4184
				if t >= 0 and (best < 0 or t < best) then -- 4184
					best = t -- 4186
					bestI = i -- 4187
				end -- 4187
			end -- 4187
			::__continue705:: -- 4187
			i = i + 1 -- 4178
		end -- 4178
	end -- 4178
	return {t = best, index = bestI} -- 4190
end -- 4175
function Play.prototype.raycastWorld(self, ray) -- 4193
	return self:raycastSolid(ray).t -- 4194
end -- 4193
function Play.prototype.raycastSolid(self, ray) -- 4198
	local best = -1 -- 4199
	local bestBox = nil -- 4200
	for ____, box in ipairs(self.boxes) do -- 4201
		do -- 4201
			if box.broken == true or box.hidden == true then -- 4201
				goto __continue710 -- 4203
			end -- 4203
			local t = hitBox(ray, box) -- 4208
			if t > 2 and (best < 0 or t < best) then -- 4208
				best = t -- 4211
				bestBox = box -- 4212
			end -- 4212
		end -- 4212
		::__continue710:: -- 4212
	end -- 4212
	if ray.dy < 0 then -- 4212
		local t = -ray.y / ray.dy -- 4216
		if t >= 0 and (best < 0 or t < best) then -- 4216
			best = t -- 4218
			bestBox = nil -- 4219
		end -- 4219
	end -- 4219
	return {t = best, box = bestBox} -- 4222
end -- 4198
function Play.prototype.dropFor(self, e) -- 4226
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 4226
		return -- 4228
	end -- 4228
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 4228
		return -- 4231
	end -- 4231
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 4233
	local ____self_pickups_57 = self.pickups -- 4233
	____self_pickups_57[#____self_pickups_57 + 1] = { -- 4234
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 4235
		kind = e.drop, -- 4235
		x = e.x, -- 4235
		y = e.y, -- 4235
		depth = e.depth, -- 4236
		label = label .. " ×1" -- 4236
	} -- 4236
	self:log("掉落 " .. label) -- 4238
end -- 4226
function Play.prototype.damageProp(self, b, amount) -- 4242
	if b.breakable == nil or b.broken == true then -- 4242
		return -- 4244
	end -- 4244
	local ____b_breakable_58, ____hp_59 = b.breakable, "hp" -- 4244
	____b_breakable_58[____hp_59] = ____b_breakable_58[____hp_59] - amount -- 4246
	if b.breakable.hp > 0 then -- 4246
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 4248
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 4249
		return -- 4250
	end -- 4250
	b.broken = true -- 4252
	for ____, other in ipairs(self.boxes) do -- 4253
		if other.id ~= nil and other.id == b.id then -- 4253
			other.broken = true -- 4255
		end -- 4255
	end -- 4255
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 4258
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 4259
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 4260
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 4261
end -- 4242
function Play.prototype.slideDepth(self, a, distance) -- 4265
	a.depth = self:limitDepth(a, a.depth + distance) -- 4266
end -- 4265
function Play.prototype.limitDepth(self, a, target) -- 4269
	local road = self.room.depth -- 4270
	if road == nil or target == a.depth then -- 4270
		return a.depth -- 4272
	end -- 4272
	local next = math.max( -- 4274
		road.min, -- 4274
		math.min(road.max, target) -- 4274
	) -- 4274
	local half = a.w / 2 -- 4275
	for ____, b in ipairs(self.boxes) do -- 4276
		do -- 4276
			local footprint = b.depth -- 4277
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4277
				goto __continue728 -- 4282
			end -- 4282
			local front = footprint.min - ACTOR_DEPTH_HALF -- 4284
			local back = footprint.max + ACTOR_DEPTH_HALF -- 4285
			if a.depth <= front and next > front then -- 4285
				next = front -- 4287
			elseif a.depth >= back and next < back then -- 4287
				next = back -- 4289
			end -- 4289
		end -- 4289
		::__continue728:: -- 4289
	end -- 4289
	return next -- 4292
end -- 4269
function Play.prototype.slideX(self, a, dx) -- 4296
	local nx = a.x + dx -- 4297
	local half = a.w / 2 -- 4298
	local room = self.room -- 4299
	nx = math.max( -- 4300
		room.minX + half, -- 4300
		math.min(room.maxX - half, nx) -- 4300
	) -- 4300
	local i = 0 -- 4301
	do -- 4301
		i = 0 -- 4302
		while i < #self.boxes do -- 4302
			do -- 4302
				local b = self.boxes[i + 1] -- 4303
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4303
					goto __continue735 -- 4305
				end -- 4305
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4305
					goto __continue735 -- 4308
				end -- 4308
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4308
					goto __continue735 -- 4311
				end -- 4311
				if nx + half > b.x0 and nx - half < b.x1 then -- 4311
					if a.x <= b.x0 then -- 4311
						nx = b.x0 - half -- 4315
					elseif a.x >= b.x1 then -- 4315
						nx = b.x1 + half -- 4317
					else -- 4317
						nx = a.x -- 4319
					end -- 4319
				end -- 4319
			end -- 4319
			::__continue735:: -- 4319
			i = i + 1 -- 4302
		end -- 4302
	end -- 4302
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 4302
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 4327
		local bx0 = self.cartAxle - CART_HALF -- 4328
		local bx1 = self.cartAxle + CART_HALF -- 4329
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 4329
			if a.x <= bx0 then -- 4329
				nx = bx0 - half -- 4332
			elseif a.x >= bx1 then -- 4332
				nx = bx1 + half -- 4334
			else -- 4334
				nx = a.x -- 4336
			end -- 4336
		end -- 4336
	end -- 4336
	local arch = room.arch -- 4344
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 4344
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 4346
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 4346
			if a.x <= arch.x0 then -- 4346
				nx = arch.x0 - half -- 4349
			elseif a.x >= arch.x1 then -- 4349
				nx = arch.x1 + half -- 4351
			end -- 4351
		end -- 4351
	end -- 4351
	a.x = nx -- 4355
end -- 4296
function Play.prototype.fallY(self, a, dt) -- 4359
	a.vy = a.vy - ____exports.GRAVITY * dt -- 4360
	if a.vy < -900 then -- 4360
		a.vy = -900 -- 4362
	end -- 4362
	local ny = a.y + a.vy * dt -- 4364
	local half = a.w / 2 -- 4365
	if a.vy <= 0 then -- 4365
		local reach = a.onGround and STEP_UP or 0 -- 4368
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 4369
		if ny <= ground then -- 4369
			ny = ground -- 4371
			a.vy = 0 -- 4372
			a.onGround = true -- 4373
		else -- 4373
			a.onGround = false -- 4375
		end -- 4375
	else -- 4375
		a.onGround = false -- 4378
		local i = 0 -- 4379
		do -- 4379
			i = 0 -- 4380
			while i < #self.boxes do -- 4380
				do -- 4380
					local b = self.boxes[i + 1] -- 4381
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4381
						goto __continue759 -- 4383
					end -- 4383
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4383
						goto __continue759 -- 4386
					end -- 4386
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 4386
						goto __continue759 -- 4389
					end -- 4389
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 4389
						ny = b.y0 - a.h -- 4392
						a.vy = 0 -- 4393
					end -- 4393
				end -- 4393
				::__continue759:: -- 4393
				i = i + 1 -- 4380
			end -- 4380
		end -- 4380
	end -- 4380
	a.y = ny -- 4397
end -- 4359
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 4401
	if depth == nil then -- 4401
		depth = 0 -- 4401
	end -- 4401
	local g = -9999 -- 4402
	local i = 0 -- 4403
	do -- 4403
		i = 0 -- 4404
		while i < #self.floors do -- 4404
			local f = self.floors[i + 1] -- 4405
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 4405
				g = f.y1 -- 4407
			end -- 4407
			i = i + 1 -- 4404
		end -- 4404
	end -- 4404
	do -- 4404
		i = 0 -- 4410
		while i < #self.boxes do -- 4410
			do -- 4410
				local b = self.boxes[i + 1] -- 4411
				if b.broken == true or b.hidden == true or b.soft == true then -- 4411
					goto __continue769 -- 4413
				end -- 4413
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 4413
					g = b.y1 -- 4417
				end -- 4417
			end -- 4417
			::__continue769:: -- 4417
			i = i + 1 -- 4410
		end -- 4410
	end -- 4410
	return g -- 4420
end -- 4401
function Play.prototype.updateCamera(self, dt) -- 4423
	local p = self.player -- 4424
	local tx = p.x + p.facing * 30 -- 4425
	local ty = p.y + CAM_LOOK_UP -- 4426
	local k = math.min(1, CAM_FOLLOW * dt) -- 4427
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 4428
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 4429
end -- 4423
function Play.prototype.clampCamera(self, w, h) -- 4433
	local room = self.room -- 4434
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 4435
	local spanX = room.maxX - room.minX -- 4436
	if spanX <= halfW * 2 then -- 4436
		self.cam.x = (room.minX + room.maxX) / 2 -- 4438
	else -- 4438
		self.cam.x = math.max( -- 4440
			room.minX + halfW, -- 4440
			math.min(room.maxX - halfW, self.cam.x) -- 4440
		) -- 4440
	end -- 4440
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 4443
	local spanY = room.height -- 4444
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 4445
	if spanY <= halfH * 2 then -- 4445
		self.cam.y = camY -- 4447
	else -- 4447
		self.cam.y = math.max( -- 4449
			camY, -- 4449
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 4449
		) -- 4449
	end -- 4449
end -- 4433
function Play.prototype.flashSet(self, text, t) -- 4453
	self.flash = text -- 4454
	self.flashT = t -- 4455
end -- 4453
function Play.prototype.statusText(self) -- 4459
	local p = self.player -- 4460
	local parts = {} -- 4461
	local who = self.childMode and "小满" or "周戍" -- 4462
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 4463
	if self.room.key == "prologue" then -- 4463
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4466
		if self.phase == "prologue-wait" then -- 4466
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 4468
		elseif self.phase == "prologue-give" then -- 4468
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 4470
		else -- 4470
			parts[#parts + 1] = "跟随" -- 4472
		end -- 4472
		if self.paused then -- 4472
			parts[#parts + 1] = "已暂停" -- 4475
		end -- 4475
		return table.concat(parts, " · ") -- 4477
	end -- 4477
	if self.room.key == "street" then -- 4477
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4480
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4481
		if self.paused then -- 4481
			parts[#parts + 1] = "已暂停" -- 4483
		end -- 4483
		return table.concat(parts, " · ") -- 4485
	end -- 4485
	if self.room.key == "gate" then -- 4485
		local ____temp_60 -- 4488
		if self.room.story == nil then -- 4488
			____temp_60 = nil -- 4488
		else -- 4488
			____temp_60 = self.room.story.gate -- 4488
		end -- 4488
		local g = ____temp_60 -- 4488
		if g ~= nil then -- 4488
			parts[#parts + 1] = self:gateLabel() -- 4490
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 4491
				0, -- 4492
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 4492
			))) .. " 秒" -- 4492
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4493
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4494
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 4495
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 4496
			if self.gateFailCount > 0 then -- 4496
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 4498
			end -- 4498
			if self.flash ~= "" then -- 4498
				parts[#parts + 1] = self.flash -- 4501
			end -- 4501
		end -- 4501
		if self.paused then -- 4501
			parts[#parts + 1] = "已暂停" -- 4505
		end -- 4505
		return table.concat(parts, " · ") -- 4507
	end -- 4507
	if self.room.key == "forest" then -- 4507
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4510
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 4511
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 4512
		if self.caughtT > 0 then -- 4512
			parts[#parts + 1] = "复位中" -- 4514
		end -- 4514
		if self.paused then -- 4514
			parts[#parts + 1] = "已暂停" -- 4517
		end -- 4517
		return table.concat(parts, " · ") -- 4519
	end -- 4519
	if self.room.key == "tower" then -- 4519
		if self.phase == "tower-wait" then -- 4519
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 4523
		elseif self.phase == "tower-knock" then -- 4523
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 4525
		elseif self.phase == "tower-given" then -- 4525
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 4527
		else -- 4527
			parts[#parts + 1] = "片尾" -- 4529
		end -- 4529
		if self.paused then -- 4529
			parts[#parts + 1] = "已暂停" -- 4532
		end -- 4532
		return table.concat(parts, " · ") -- 4534
	end -- 4534
	if self.room.key == "village" then -- 4534
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4537
		if self.hasBottle then -- 4537
			parts[#parts + 1] = "有瓶" -- 4539
		elseif self.bottleFly ~= nil then -- 4539
			parts[#parts + 1] = "瓶在飞" -- 4541
		else -- 4541
			parts[#parts + 1] = "空手" -- 4543
		end -- 4543
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 4545
		if self.scavChase then -- 4545
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 4547
		end -- 4547
		if self.passed then -- 4547
			parts[#parts + 1] = "已过通行线" -- 4550
		end -- 4550
		if self.paused then -- 4550
			parts[#parts + 1] = "已暂停" -- 4553
		end -- 4553
		return table.concat(parts, " · ") -- 4555
	end -- 4555
	local isChild = self.childMode -- 4558
	if isChild then -- 4558
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4560
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 4561
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4562
	else -- 4562
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 4564
		if p.rollT > 0 then -- 4564
			parts[#parts + 1] = "翻滚中" -- 4566
		end -- 4566
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4568
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4569
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 4570
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 4571
	end -- 4571
	if self.checkpoint >= 0 then -- 4571
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 4574
	end -- 4574
	if self.paused then -- 4574
		parts[#parts + 1] = "已暂停" -- 4577
	end -- 4577
	return table.concat(parts, " · ") -- 4579
end -- 4459
function Play.prototype.aliveEnemies(self) -- 4583
	local n = 0 -- 4584
	local i = 0 -- 4585
	do -- 4585
		i = 0 -- 4586
		while i < #self.enemies do -- 4586
			if self.enemies[i + 1].alive then -- 4586
				n = n + 1 -- 4588
			end -- 4588
			i = i + 1 -- 4586
		end -- 4586
	end -- 4586
	return n -- 4591
end -- 4583
function Play.prototype.threatened(self) -- 4596
	do -- 4596
		local i = 0 -- 4597
		while i < #self.enemies do -- 4597
			local e = self.enemies[i + 1] -- 4598
			if e.alive and e.warnT > 0 then -- 4598
				return true -- 4600
			end -- 4600
			i = i + 1 -- 4597
		end -- 4597
	end -- 4597
	return false -- 4603
end -- 4596
function Play.prototype.gateSecondsLeft(self) -- 4606
	local ____temp_61 -- 4607
	if self.room.story == nil then -- 4607
		____temp_61 = nil -- 4607
	else -- 4607
		____temp_61 = self.room.story.gate -- 4607
	end -- 4607
	local g = ____temp_61 -- 4607
	if g == nil then -- 4607
		return 0 -- 4609
	end -- 4609
	return math.max( -- 4611
		0, -- 4611
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 4611
	) -- 4611
end -- 4606
function Play.prototype.gateLabel(self) -- 4614
	if self.phase == "gate-idle" then -- 4614
		return "待就位" -- 4616
	end -- 4616
	if self.phase == "gate-hold" then -- 4616
		return "守点中" -- 4619
	end -- 4619
	if self.phase == "gate-send" then -- 4619
		return "送别" -- 4622
	end -- 4622
	if self.phase == "gate-count" then -- 4622
		return "数数 " .. tostring(self.countTick) -- 4625
	end -- 4625
	return "她走" -- 4627
end -- 4614
function Play.prototype.dogLabel(self) -- 4631
	if self.dogState == "ear" then -- 4631
		return "转耳" -- 4633
	end -- 4633
	if self.dogState == "chase" then -- 4633
		return "追" -- 4636
	end -- 4636
	if self.dogState == "sniff" then -- 4636
		return "停" -- 4639
	end -- 4639
	if self.dogState == "back" then -- 4639
		return "回线" -- 4642
	end -- 4642
	return "巡逻" -- 4644
end -- 4631
function Play.prototype.doorXOf(self) -- 4647
	local ____temp_62 -- 4648
	if self.room.story == nil then -- 4648
		____temp_62 = nil -- 4648
	else -- 4648
		____temp_62 = self.room.story.tower -- 4648
	end -- 4648
	local t = ____temp_62 -- 4648
	return t == nil and 0 or t.doorX -- 4649
end -- 4647
function Play.prototype.scavLabel(self) -- 4653
	if self.scavState == "chase" then -- 4653
		return "追" -- 4655
	end -- 4655
	if self.scavState == "turn" then -- 4655
		return "转头" -- 4658
	end -- 4658
	if self.scavState == "walk" then -- 4658
		return "赶来" -- 4661
	end -- 4661
	if self.scavState == "stall" then -- 4661
		return "停住" -- 4664
	end -- 4664
	if self.scavState == "back" then -- 4664
		return "回位" -- 4667
	end -- 4667
	return "巡逻" -- 4669
end -- 4653
function Play.prototype.hintText(self) -- 4673
	if self.paused then -- 4673
		return "Esc 继续 · R 重置" -- 4675
	end -- 4675
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 4675
		if self:threatened() then -- 4675
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 4681
		end -- 4681
		if self.coverHug then -- 4681
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 4684
		end -- 4684
		if self.coverNear then -- 4684
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 4687
		end -- 4687
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 4689
	end -- 4689
	if self.flash ~= "" then -- 4689
		return self.flash -- 4692
	end -- 4692
	if self.room.key == "prologue" then -- 4692
		if self.phase == "prologue-wait" then -- 4692
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 4696
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 4697
		end -- 4697
		if self.phase == "prologue-give" then -- 4697
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 4700
		end -- 4700
		return "她跟着你了 · 两人一起走到门口 680" -- 4702
	end -- 4702
	if self.room.key == "street" then -- 4702
		if self:aliveEnemies() > 0 then -- 4702
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 4706
		end -- 4706
		return "清完了 · 两人一起走到右边检查站入口 900" -- 4708
	end -- 4708
	if self.room.key == "gate" then -- 4708
		local ____temp_63 -- 4711
		if self.room.story == nil then -- 4711
			____temp_63 = nil -- 4711
		else -- 4711
			____temp_63 = self.room.story.gate -- 4711
		end -- 4711
		local g = ____temp_63 -- 4711
		if g ~= nil then -- 4711
			if self.phase == "gate-idle" then -- 4711
				if self.gateNeedConfirm then -- 4711
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 4715
				end -- 4715
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 4717
			end -- 4717
			if self.phase == "gate-hold" then -- 4717
				if self.coveredFlash > 0 then -- 4717
					return "掩体挡下了这一枪 · 别露头" -- 4721
				end -- 4721
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 4723
			end -- 4723
			if self.phase == "gate-send" then -- 4723
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 4726
			end -- 4726
			if self.phase == "gate-count" then -- 4726
				if self.countTick >= ____exports.GATE_COUNT_END then -- 4726
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 4730
				end -- 4730
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 4732
			end -- 4732
			return "她自己走 · 跟着出城门 1120" -- 4734
		end -- 4734
	end -- 4734
	if self.room.key == "forest" then -- 4734
		if self.dogState == "chase" then -- 4734
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 4739
		end -- 4739
		if self.dogState == "ear" then -- 4739
			return "狗转耳朵了 · 停下或蹲下别出声" -- 4742
		end -- 4742
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 4744
	end -- 4744
	if self.room.key == "tower" then -- 4744
		if self.phase == "tower-wait" then -- 4744
			return "走到门前 445 点一次 E 敲两下" -- 4748
		end -- 4748
		if self.phase == "tower-knock" then -- 4748
			return "敲两下 · 等门开" -- 4751
		end -- 4751
		if self.phase == "tower-given" then -- 4751
			return "递交针套和纸条 · 看登记簿最后一行" -- 4754
		end -- 4754
		return "片尾 · 点 E 再玩一次，回到序章" -- 4756
	end -- 4756
	if self.room.key == "village" then -- 4756
		if self.bottleFly ~= nil then -- 4756
			return "等瓶子落地 · 触地才发声" -- 4760
		end -- 4760
		if self.hasBottle then -- 4760
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 4763
		end -- 4763
		if self.passed then -- 4763
			return "已过第一院 · R 重置可再来一遍" -- 4766
		end -- 4766
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 4768
	end -- 4768
	if self.room.key == "outside" then -- 4768
		if self.focusCart then -- 4768
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 4772
		end -- 4772
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 4774
	end -- 4774
	if self.escort.state == "frozen" then -- 4774
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 4774
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 4778
		end -- 4778
		return "小满吓住了 · 走过去，靠近再点 E" -- 4780
	end -- 4780
	if self.escort.state == "calming" then -- 4780
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 4783
	end -- 4783
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 4785
end -- 4673
function Play.prototype.draw(self, draw, w, h) -- 4790
	self.viewW = w -- 4791
	self.viewH = h -- 4792
	self.view = ____exports.computeViewport(w, h) -- 4793
	self:clampCamera(w, h) -- 4794
	draw:clear() -- 4795
	draw:drawRect( -- 4797
		Rect(0, 0, w, h), -- 4797
		BG_VOID -- 4797
	) -- 4797
	local box = self:canvasRect(w, h) -- 4798
	draw:drawRect(box, BG_FAR) -- 4799
	draw:drawRect( -- 4800
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 4800
		BG_MID -- 4800
	) -- 4800
	self:drawFloors(draw, w, h) -- 4802
	self:drawSolids(draw, w, h) -- 4803
	self:drawZones(draw, w, h) -- 4804
	self:drawArch(draw, w, h) -- 4805
	self:drawCart(draw, w, h) -- 4806
	self:drawCampaignProps(draw, w, h) -- 4807
	self:drawActors(draw, w, h) -- 4808
	self:drawTrace(draw, w, h) -- 4809
	self:drawAim(draw, w, h) -- 4810
end -- 4790
function Play.prototype.canvasRect(self, w, h) -- 4814
	local v = self.view -- 4815
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 4816
end -- 4814
function Play.prototype.px(self, n) -- 4820
	return n * self.view.zoom -- 4821
end -- 4820
function Play.prototype.sx(self, wx, w) -- 4825
	local v = self.view -- 4826
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 4827
	return v.ox + lx * v.zoom -- 4828
end -- 4825
function Play.prototype.sy(self, wy, h) -- 4832
	local v = self.view -- 4833
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 4834
	return v.oy + ly * v.zoom -- 4835
end -- 4832
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 4838
	local px0 = self:sx(x0, w) -- 4839
	local px1 = self:sx(x1, w) -- 4840
	local py0 = self:sy(y0, h) -- 4841
	local py1 = self:sy(y1, h) -- 4842
	if px1 <= px0 or py1 <= py0 then -- 4842
		return -- 4844
	end -- 4844
	draw:drawRect( -- 4846
		Rect(px0, py0, px1 - px0, py1 - py0), -- 4846
		color -- 4846
	) -- 4846
end -- 4838
function Play.prototype.drawFloors(self, draw, w, h) -- 4849
	local i = 0 -- 4850
	do -- 4850
		i = 0 -- 4851
		while i < #self.room.floors do -- 4851
			local f = self.room.floors[i + 1] -- 4852
			local ____temp_64 -- 4853
			if f.y == 0 then -- 4853
				____temp_64 = self.room.depth -- 4853
			else -- 4853
				____temp_64 = nil -- 4853
			end -- 4853
			local road = ____temp_64 -- 4853
			local y = self:sy(f.y + (road and road.min or 0), h) -- 4854
			local x0 = self:sx(f.x0, w) -- 4855
			local x1 = self:sx(f.x1, w) -- 4856
			local deck = self:px(5) -- 4857
			if road ~= nil then -- 4857
				local back = self:sy(f.y + road.max, h) -- 4859
				draw:drawRect( -- 4860
					Rect(x0, y, x1 - x0, back - y), -- 4860
					FLOOR_DECK, -- 4860
					self:px(1), -- 4860
					SOLID_EDGE -- 4860
				) -- 4860
			end -- 4860
			draw:drawRect( -- 4862
				Rect(x0, y - deck, x1 - x0, deck), -- 4862
				FLOOR_DECK -- 4862
			) -- 4862
			draw:drawSegment( -- 4863
				Vec2(x0, y), -- 4863
				Vec2(x1, y), -- 4863
				self:px(1), -- 4863
				GROUND -- 4863
			) -- 4863
			i = i + 1 -- 4851
		end -- 4851
	end -- 4851
end -- 4849
function Play.prototype.drawSolids(self, draw, w, h) -- 4867
	local i = 0 -- 4868
	do -- 4868
		i = 0 -- 4869
		while i < #self.boxes do -- 4869
			do -- 4869
				local b = self.boxes[i + 1] -- 4870
				if b.id == "braced_shield" or b.hidden == true then -- 4870
					goto __continue890 -- 4872
				end -- 4872
				if b.broken == true then -- 4872
					if b.breakable ~= nil then -- 4872
						local gy = self:sy(b.y0, h) -- 4877
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 4878
						local k = 0 -- 4879
						do -- 4879
							k = 0 -- 4880
							while k < 3 do -- 4880
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 4881
								draw:drawSegment( -- 4882
									Vec2( -- 4882
										gx - self:px(4), -- 4882
										gy + self:px(k % 2) -- 4882
									), -- 4882
									Vec2( -- 4882
										gx + self:px(5), -- 4882
										gy + self:px(k % 2) -- 4882
									), -- 4882
									self:px(1), -- 4882
									rgb -- 4882
								) -- 4882
								k = k + 1 -- 4880
							end -- 4880
						end -- 4880
					end -- 4880
					goto __continue890 -- 4885
				end -- 4885
				local ____opt_67 = b.depth -- 4885
				local front = ____opt_67 and ____opt_67.min or 0 -- 4887
				local ____opt_69 = b.depth -- 4887
				local back = ____opt_69 and ____opt_69.max or 0 -- 4888
				local fill = SOLID_FILL -- 4889
				local line = SOLID_EDGE -- 4890
				if b.soft == true then -- 4890
					fill = SOFT -- 4892
					line = SOFT_LINE -- 4893
				elseif b.breakable ~= nil then -- 4893
					line = DANGER_LINE -- 4895
					fill = Color(0.3, 0.24, 0.16, 1) -- 4896
				elseif b.interact ~= nil then -- 4896
					line = PASS_LINE -- 4898
				end -- 4898
				self:drawBox( -- 4900
					draw, -- 4900
					w, -- 4900
					h, -- 4900
					b.x0, -- 4900
					b.x1, -- 4900
					b.y0 + front, -- 4900
					b.y1 + back, -- 4900
					fill -- 4900
				) -- 4900
				draw:drawSegment( -- 4901
					Vec2( -- 4901
						self:sx(b.x0, w), -- 4901
						self:sy(b.y1 + front, h) -- 4901
					), -- 4901
					Vec2( -- 4902
						self:sx(b.x1, w), -- 4902
						self:sy(b.y1 + front, h) -- 4902
					), -- 4902
					self:px(1), -- 4902
					line -- 4902
				) -- 4902
				if b.breakable ~= nil then -- 4902
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 4905
					local cyp = self:sy(b.y1 + front, h) -- 4906
					draw:drawSegment( -- 4907
						Vec2( -- 4907
							cxp - self:px(4), -- 4907
							cyp + self:px(1) -- 4907
						), -- 4907
						Vec2( -- 4907
							cxp + self:px(3), -- 4907
							cyp + self:px(5) -- 4907
						), -- 4907
						self:px(1), -- 4907
						line -- 4907
					) -- 4907
				end -- 4907
			end -- 4907
			::__continue890:: -- 4907
			i = i + 1 -- 4869
		end -- 4869
	end -- 4869
end -- 4867
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 4913
	local i = 0 -- 4914
	do -- 4914
		i = 0 -- 4915
		while i < #self.pickups do -- 4915
			do -- 4915
				local pk = self.pickups[i + 1] -- 4916
				if self.run.taken[pk.id] == true then -- 4916
					goto __continue902 -- 4918
				end -- 4918
				local gy = pk.y + (pk.depth or 0) -- 4920
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 4921
				draw:drawRect( -- 4922
					Rect( -- 4922
						self:sx(pk.x - 5, w), -- 4922
						self:sy(gy + 12 + bob, h), -- 4922
						self:px(10), -- 4922
						self:px(10) -- 4922
					), -- 4922
					Color(0.84, 0.7, 0.3, 1) -- 4923
				) -- 4923
				draw:drawSegment( -- 4924
					Vec2( -- 4924
						self:sx(pk.x - 5, w), -- 4924
						self:sy(gy + 12 + bob, h) -- 4924
					), -- 4924
					Vec2( -- 4925
						self:sx(pk.x + 5, w), -- 4925
						self:sy(gy + 12 + bob, h) -- 4925
					), -- 4925
					self:px(1), -- 4925
					Color(0.95, 0.86, 0.52, 1) -- 4925
				) -- 4925
			end -- 4925
			::__continue902:: -- 4925
			i = i + 1 -- 4915
		end -- 4915
	end -- 4915
	if self.bracedShield ~= nil then -- 4915
		local sh = self.bracedShield -- 4928
		draw:drawRect( -- 4929
			Rect( -- 4929
				self:sx(sh.x - sh.w / 2, w), -- 4929
				self:sy(sh.y, h), -- 4929
				self:px(sh.w), -- 4929
				self:px(sh.h) -- 4929
			), -- 4929
			Color(0.42, 0.4, 0.34, 1) -- 4930
		) -- 4930
		draw:drawSegment( -- 4931
			Vec2( -- 4931
				self:sx(sh.x - sh.w / 2, w), -- 4931
				self:sy(sh.y + sh.h, h) -- 4931
			), -- 4931
			Vec2( -- 4932
				self:sx(sh.x + sh.w / 2, w), -- 4932
				self:sy(sh.y + sh.h, h) -- 4932
			), -- 4932
			self:px(1), -- 4932
			Color(0.74, 0.72, 0.62, 1) -- 4932
		) -- 4932
	end -- 4932
end -- 4913
function Play.prototype.drawZones(self, draw, w, h) -- 4936
	local i = 0 -- 4937
	do -- 4937
		i = 0 -- 4938
		while i < #self.room.zones do -- 4938
			local z = self.room.zones[i + 1] -- 4939
			local fill = DANGER -- 4940
			local line = DANGER_LINE -- 4941
			if z.tint == 2 then -- 4941
				fill = SOFT -- 4943
				line = SOFT_LINE -- 4944
			elseif z.tint == 3 then -- 4944
				fill = BRICK -- 4946
				line = BRICK_LINE -- 4947
			elseif z.tint == 4 then -- 4947
				fill = PASS -- 4949
				line = PASS_LINE -- 4950
			end -- 4950
			self:drawBox( -- 4952
				draw, -- 4952
				w, -- 4952
				h, -- 4952
				z.x0, -- 4952
				z.x1, -- 4952
				z.y, -- 4952
				z.y + z.h, -- 4952
				fill -- 4952
			) -- 4952
			draw:drawSegment( -- 4953
				Vec2( -- 4953
					self:sx(z.x0, w), -- 4953
					self:sy(z.y, h) -- 4953
				), -- 4953
				Vec2( -- 4953
					self:sx(z.x0, w), -- 4953
					self:sy(z.y + z.h, h) -- 4953
				), -- 4953
				self:px(1), -- 4953
				line -- 4953
			) -- 4953
			draw:drawSegment( -- 4954
				Vec2( -- 4954
					self:sx(z.x1, w), -- 4954
					self:sy(z.y, h) -- 4954
				), -- 4954
				Vec2( -- 4954
					self:sx(z.x1, w), -- 4954
					self:sy(z.y + z.h, h) -- 4954
				), -- 4954
				self:px(1), -- 4954
				line -- 4954
			) -- 4954
			i = i + 1 -- 4938
		end -- 4938
	end -- 4938
end -- 4936
function Play.prototype.drawArch(self, draw, w, h) -- 4958
	local a = self.room.arch -- 4959
	if a.h <= 0 then -- 4959
		return -- 4961
	end -- 4961
	self:drawBox( -- 4963
		draw, -- 4963
		w, -- 4963
		h, -- 4963
		a.x0, -- 4963
		a.x1, -- 4963
		a.y, -- 4963
		a.y + a.h, -- 4963
		HOLE_FILL -- 4963
	) -- 4963
	draw:drawSegment( -- 4964
		Vec2( -- 4964
			self:sx(a.x0, w), -- 4964
			self:sy(a.y + a.h, h) -- 4964
		), -- 4964
		Vec2( -- 4964
			self:sx(a.x1, w), -- 4964
			self:sy(a.y + a.h, h) -- 4964
		), -- 4964
		self:px(1), -- 4964
		SOLID_EDGE -- 4964
	) -- 4964
	draw:drawSegment( -- 4965
		Vec2( -- 4965
			self:sx(a.x0, w), -- 4965
			self:sy(a.y, h) -- 4965
		), -- 4965
		Vec2( -- 4965
			self:sx(a.x0, w), -- 4965
			self:sy(a.y + a.h, h) -- 4965
		), -- 4965
		self:px(1), -- 4965
		SOLID_EDGE -- 4965
	) -- 4965
	draw:drawSegment( -- 4966
		Vec2( -- 4966
			self:sx(a.x1, w), -- 4966
			self:sy(a.y, h) -- 4966
		), -- 4966
		Vec2( -- 4966
			self:sx(a.x1, w), -- 4966
			self:sy(a.y + a.h, h) -- 4966
		), -- 4966
		self:px(1), -- 4966
		SOLID_EDGE -- 4966
	) -- 4966
end -- 4958
function Play.prototype.drawCart(self, draw, w, h) -- 4969
	local c = self.room.cart -- 4970
	if c.bodyW <= 0 then -- 4970
		return -- 4972
	end -- 4972
	drawCartShape( -- 4974
		draw, -- 4974
		self, -- 4974
		w, -- 4974
		h, -- 4974
		c, -- 4974
		self.cartAxle -- 4974
	) -- 4974
	draw:drawRect( -- 4975
		Rect( -- 4975
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 4975
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 4975
			self:px(2), -- 4975
			self:px(40) -- 4975
		), -- 4975
		STAND -- 4975
	) -- 4975
end -- 4969
function Play.prototype.drawActors(self, draw, w, h) -- 4978
	local p = self.player -- 4979
	local isChild = self.childMode -- 4980
	local footY = p.y + p.depth -- 4981
	if p.covered then -- 4981
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 4984
		draw:drawSegment( -- 4985
			Vec2( -- 4985
				self:sx(edge, w), -- 4985
				self:sy(footY + 8, h) -- 4985
			), -- 4985
			Vec2( -- 4985
				self:sx(edge, w), -- 4985
				self:sy(footY + p.h * 0.62, h) -- 4985
			), -- 4985
			self:px(2), -- 4985
			STAND -- 4985
		) -- 4985
		draw:drawSegment( -- 4987
			Vec2( -- 4987
				self:sx(p.x - 8, w), -- 4987
				self:sy(footY + p.h + 3, h) -- 4987
			), -- 4987
			Vec2( -- 4987
				self:sx(p.x + 8, w), -- 4987
				self:sy(footY + p.h + 3, h) -- 4987
			), -- 4987
			self:px(2), -- 4987
			STAND -- 4987
		) -- 4987
	elseif self.coverNear and not isChild then -- 4987
		draw:drawRect( -- 4990
			Rect( -- 4990
				self:sx(p.x - 3, w), -- 4990
				self:sy(footY + 1, h), -- 4990
				self:px(3), -- 4990
				self:px(3) -- 4990
			), -- 4990
			STAND -- 4990
		) -- 4990
	end -- 4990
	drawFigure( -- 4992
		draw, -- 4992
		self, -- 4992
		w, -- 4992
		h, -- 4992
		p, -- 4992
		isChild and CHILD_BODY or SOLDIER_BODY, -- 4992
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 4992
	) -- 4992
	local q = self.partner -- 4993
	if q.alive then -- 4993
		local childPartner = q.w == CHILD_W -- 4995
		drawFigure( -- 4996
			draw, -- 4996
			self, -- 4996
			w, -- 4996
			h, -- 4996
			q, -- 4996
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 4996
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 4996
		) -- 4996
	end -- 4996
	local i = 0 -- 4998
	do -- 4998
		i = 0 -- 4999
		while i < #self.enemies do -- 4999
			local e = self.enemies[i + 1] -- 5000
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 5001
			local enemyY = e.y + (e.depth or 0) -- 5002
			self:drawBox( -- 5003
				draw, -- 5003
				w, -- 5003
				h, -- 5003
				e.x - e.w / 2, -- 5003
				e.x + e.w / 2, -- 5003
				enemyY, -- 5003
				enemyY + e.h, -- 5003
				col -- 5003
			) -- 5003
			if e.alive then -- 5003
				local ef = p.x >= e.x and 1 or -1 -- 5005
				if e.kind == "shield" then -- 5005
					local sh = (e.shieldHp or 0) > 0 -- 5007
					draw:drawRect( -- 5008
						Rect( -- 5008
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 5008
							self:sy(enemyY, h), -- 5008
							self:px(6), -- 5008
							self:px(64) -- 5008
						), -- 5008
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 5009
					) -- 5009
				elseif e.kind == "breaker" then -- 5009
					draw:drawSegment( -- 5011
						Vec2( -- 5011
							self:sx(e.x + ef * 12, w), -- 5011
							self:sy(enemyY + 8, h) -- 5011
						), -- 5011
						Vec2( -- 5012
							self:sx(e.x + ef * 22, w), -- 5012
							self:sy(enemyY + 46, h) -- 5012
						), -- 5012
						self:px(3), -- 5012
						Color(0.5, 0.36, 0.22, 1) -- 5012
					) -- 5012
				end -- 5012
			end -- 5012
			if e.alive and e.warnT > 0 then -- 5012
				local gunX = self:sx(e.x, w) -- 5017
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 5018
				local aimX = self:sx(p.x, w) -- 5019
				local aimY = self:sy(footY + p.h * 0.55, h) -- 5020
				local seg = 8 -- 5021
				local s = 0 -- 5022
				do -- 5022
					s = 0 -- 5023
					while s < seg do -- 5023
						local t0 = s / seg -- 5024
						local t1 = (s + 1) / seg -- 5025
						draw:drawSegment( -- 5026
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 5027
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 5028
							self:px(1), -- 5029
							DANGER -- 5029
						) -- 5029
						s = s + 2 -- 5023
					end -- 5023
				end -- 5023
			end -- 5023
			i = i + 1 -- 4999
		end -- 4999
	end -- 4999
	local k = 0 -- 5034
	do -- 5034
		k = 0 -- 5035
		while k < #self.room.marks do -- 5035
			do -- 5035
				local m = self.room.marks[k + 1] -- 5036
				if m.kind ~= 0 then -- 5036
					goto __continue928 -- 5038
				end -- 5038
				local on = self.checkpoint == m.x -- 5040
				local x = self:sx(m.x, w) -- 5041
				local y = self:sy(m.y, h) -- 5042
				draw:drawSegment( -- 5043
					Vec2(x, y), -- 5043
					Vec2( -- 5043
						x, -- 5043
						y + self:px(35) -- 5043
					), -- 5043
					self:px(1), -- 5043
					on and CHECK or INK_DIM -- 5043
				) -- 5043
				draw:drawDot( -- 5044
					Vec2( -- 5044
						x, -- 5044
						y + self:px(35) -- 5044
					), -- 5044
					self:px(2), -- 5044
					on and CHECK or INK_DIM -- 5044
				) -- 5044
			end -- 5044
			::__continue928:: -- 5044
			k = k + 1 -- 5035
		end -- 5035
	end -- 5035
	local j = 0 -- 5048
	do -- 5048
		j = 0 -- 5049
		while j < #self.room.marks do -- 5049
			do -- 5049
				local m = self.room.marks[j + 1] -- 5050
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 5050
					goto __continue931 -- 5052
				end -- 5052
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 5052
					goto __continue931 -- 5056
				end -- 5056
				local col = STAND -- 5058
				if m.kind == 4 then -- 5058
					col = PASS_LINE -- 5060
				elseif m.kind == 5 then -- 5060
					col = BRICK_LINE -- 5062
				end -- 5062
				local mx = self:sx(m.x, w) -- 5064
				local my = self:sy(m.y, h) -- 5065
				draw:drawSegment( -- 5066
					Vec2(mx, my), -- 5066
					Vec2( -- 5066
						mx, -- 5066
						my + self:px(24) -- 5066
					), -- 5066
					self:px(1), -- 5066
					col -- 5066
				) -- 5066
			end -- 5066
			::__continue931:: -- 5066
			j = j + 1 -- 5049
		end -- 5049
	end -- 5049
	local t = 0 -- 5069
	do -- 5069
		t = 0 -- 5070
		while t < #self.room.marks do -- 5070
			do -- 5070
				local m = self.room.marks[t + 1] -- 5071
				if m.kind ~= 6 then -- 5071
					goto __continue937 -- 5073
				end -- 5073
				local mx = self:sx(m.x, w) -- 5075
				local my = self:sy(m.y, h) -- 5076
				draw:drawSegment( -- 5077
					Vec2(mx, my), -- 5077
					Vec2( -- 5077
						mx, -- 5077
						my + self:px(30) -- 5077
					), -- 5077
					self:px(1), -- 5077
					INK_DIM -- 5077
				) -- 5077
				self:drawBox( -- 5078
					draw, -- 5078
					w, -- 5078
					h, -- 5078
					m.x - 5, -- 5078
					m.x + 5, -- 5078
					m.y + 30, -- 5078
					m.y + 40, -- 5078
					CHECK -- 5078
				) -- 5078
			end -- 5078
			::__continue937:: -- 5078
			t = t + 1 -- 5070
		end -- 5070
	end -- 5070
	if self.room.key == "village" then -- 5070
		self:drawVillage(draw, w, h) -- 5081
	end -- 5081
	if self.room.key == "forest" then -- 5081
		self:drawDog(draw, w, h) -- 5084
	end -- 5084
end -- 4978
function Play.prototype.drawDog(self, draw, w, h) -- 5089
	local x = self.dogX -- 5090
	self:drawBox( -- 5091
		draw, -- 5091
		w, -- 5091
		h, -- 5091
		x - 14, -- 5091
		x + 14, -- 5091
		0, -- 5091
		20, -- 5091
		SCAV_BODY -- 5091
	) -- 5091
	self:drawBox( -- 5092
		draw, -- 5092
		w, -- 5092
		h, -- 5092
		x - 10, -- 5092
		x - 2, -- 5092
		20, -- 5092
		30, -- 5092
		SCAV_BODY -- 5092
	) -- 5092
	self:drawBox( -- 5093
		draw, -- 5093
		w, -- 5093
		h, -- 5093
		x + 2, -- 5093
		x + 10, -- 5093
		20, -- 5093
		30, -- 5093
		SCAV_HEAD -- 5093
	) -- 5093
	if self.dogState == "ear" or self.dogState == "chase" then -- 5093
		draw:drawSegment( -- 5095
			Vec2( -- 5095
				self:sx(x, w), -- 5095
				self:sy(30, h) -- 5095
			), -- 5095
			Vec2( -- 5096
				self:sx(x, w), -- 5096
				self:sy(40, h) -- 5096
			), -- 5096
			self:px(1), -- 5096
			DANGER -- 5096
		) -- 5096
	end -- 5096
end -- 5089
function Play.prototype.drawVillage(self, draw, w, h) -- 5101
	local bottle = self.room.bottle -- 5102
	if bottle ~= nil then -- 5102
		self:drawBox( -- 5104
			draw, -- 5104
			w, -- 5104
			h, -- 5104
			bottle.x - 14, -- 5104
			bottle.x + 14, -- 5104
			0, -- 5104
			64, -- 5104
			SOLID_FILL -- 5104
		) -- 5104
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 5104
			self:drawBottle( -- 5106
				draw, -- 5106
				w, -- 5106
				h, -- 5106
				bottle.x, -- 5106
				64 -- 5106
			) -- 5106
		end -- 5106
	end -- 5106
	self:drawBox( -- 5110
		draw, -- 5110
		w, -- 5110
		h, -- 5110
		300, -- 5110
		420, -- 5110
		44, -- 5110
		50, -- 5110
		FLOOR_DECK -- 5110
	) -- 5110
	self:drawBox( -- 5111
		draw, -- 5111
		w, -- 5111
		h, -- 5111
		300, -- 5111
		306, -- 5111
		0, -- 5111
		44, -- 5111
		FLOOR_DECK -- 5111
	) -- 5111
	self:drawBox( -- 5112
		draw, -- 5112
		w, -- 5112
		h, -- 5112
		414, -- 5112
		420, -- 5112
		0, -- 5112
		44, -- 5112
		FLOOR_DECK -- 5112
	) -- 5112
	local s = self.room.scavenger -- 5114
	if s ~= nil then -- 5114
		local sx0 = self.scavX -- 5116
		self:drawBox( -- 5117
			draw, -- 5117
			w, -- 5117
			h, -- 5117
			sx0 - 12, -- 5117
			sx0 + 12, -- 5117
			0, -- 5117
			s.h - 14, -- 5117
			SCAV_BODY -- 5117
		) -- 5117
		self:drawBox( -- 5118
			draw, -- 5118
			w, -- 5118
			h, -- 5118
			sx0 - 7, -- 5118
			sx0 + 7, -- 5118
			s.h - 14, -- 5118
			s.h, -- 5118
			SCAV_HEAD -- 5118
		) -- 5118
		if self.scavState == "turn" then -- 5118
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 5120
			draw:drawSegment( -- 5121
				Vec2( -- 5121
					self:sx(sx0, w), -- 5121
					self:sy(s.h - 6, h) -- 5121
				), -- 5121
				Vec2( -- 5121
					self:sx(fx, w), -- 5121
					self:sy(s.h - 6, h) -- 5121
				), -- 5121
				self:px(1), -- 5121
				INK -- 5121
			) -- 5121
		end -- 5121
	end -- 5121
	if self.hasBottle then -- 5121
		local p = self.player -- 5126
		self:drawBottle( -- 5127
			draw, -- 5127
			w, -- 5127
			h, -- 5127
			p.x + p.facing * 10, -- 5127
			p.y + p.h * 0.62 -- 5127
		) -- 5127
	end -- 5127
	if self.bottleFly ~= nil then -- 5127
		self:drawBottle( -- 5130
			draw, -- 5130
			w, -- 5130
			h, -- 5130
			self.bottleFly.x, -- 5130
			self.bottleFly.y -- 5130
		) -- 5130
	end -- 5130
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 5130
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 5133
		draw:drawCircle( -- 5134
			Vec2( -- 5134
				self:sx(self.bottleLandX, w), -- 5134
				self:sy(0, h) -- 5134
			), -- 5134
			self:px(r / ____exports.UNITS_PER_PX), -- 5134
			BRICK_LINE -- 5134
		) -- 5134
	end -- 5134
end -- 5101
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 5138
	self:drawBox( -- 5139
		draw, -- 5139
		w, -- 5139
		h, -- 5139
		x - 3, -- 5139
		x + 3, -- 5139
		y - 10, -- 5139
		y, -- 5139
		BOTTLE -- 5139
	) -- 5139
end -- 5138
function Play.prototype.drawTrace(self, draw, w, h) -- 5142
	local t = self.trace -- 5143
	if t == nil or self.traceT <= 0 then -- 5143
		return -- 5145
	end -- 5145
	draw:drawSegment( -- 5147
		Vec2( -- 5148
			self:sx(t.x0, w), -- 5148
			self:sy(t.y0, h) -- 5148
		), -- 5148
		Vec2( -- 5149
			self:sx(t.x1, w), -- 5149
			self:sy(t.y1, h) -- 5149
		), -- 5149
		self:px(1), -- 5150
		t.hit and AIM_HIT or INK_DIM -- 5150
	) -- 5150
end -- 5142
function Play.prototype.drawAim(self, draw, w, h) -- 5153
	local v = self.view -- 5155
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 5156
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 5157
	local dot = self:px(1) -- 5158
	local arm = self:px(3) -- 5159
	local gap = self:px(1) -- 5160
	draw:drawSegment( -- 5161
		Vec2(gx - arm - gap, gy), -- 5161
		Vec2(gx - gap, gy), -- 5161
		dot / 2, -- 5161
		AIM -- 5161
	) -- 5161
	draw:drawSegment( -- 5162
		Vec2(gx + gap, gy), -- 5162
		Vec2(gx + arm + gap, gy), -- 5162
		dot / 2, -- 5162
		AIM -- 5162
	) -- 5162
	draw:drawSegment( -- 5163
		Vec2(gx, gy - arm - gap), -- 5163
		Vec2(gx, gy - gap), -- 5163
		dot / 2, -- 5163
		AIM -- 5163
	) -- 5163
	draw:drawSegment( -- 5164
		Vec2(gx, gy + gap), -- 5164
		Vec2(gx, gy + arm + gap), -- 5164
		dot / 2, -- 5164
		AIM -- 5164
	) -- 5164
	if self.room.key == "village" and self.hasBottle then -- 5164
		local p = self.player -- 5168
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 5170
		local dir = ____end.x >= p.x and 1 or -1 -- 5171
		local x0 = p.x + dir * 10 -- 5172
		local y0 = p.y + p.h * 0.7 -- 5173
		local T = BOTTLE_FLY_TIME -- 5174
		local vx = (____end.x - x0) / T -- 5175
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 5176
		local pxr = x0 -- 5177
		local pyr = y0 -- 5178
		local t = 1 -- 5179
		do -- 5179
			t = 1 -- 5180
			while t <= 12 do -- 5180
				local tt = t / 12 * T -- 5181
				local nx = x0 + vx * tt -- 5182
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 5183
				draw:drawSegment( -- 5184
					Vec2( -- 5184
						self:sx(pxr, w), -- 5184
						self:sy(pyr, h) -- 5184
					), -- 5184
					Vec2( -- 5184
						self:sx(nx, w), -- 5184
						self:sy(ny, h) -- 5184
					), -- 5184
					self:px(1) / 2, -- 5184
					BOTTLE -- 5184
				) -- 5184
				pxr = nx -- 5185
				pyr = ny -- 5186
				t = t + 1 -- 5180
			end -- 5180
		end -- 5180
		draw:drawCircle( -- 5188
			Vec2( -- 5188
				self:sx(____end.x, w), -- 5188
				self:sy(____end.y + 2, h) -- 5188
			), -- 5188
			self:px(2), -- 5188
			BOTTLE -- 5188
		) -- 5188
	end -- 5188
end -- 5153
return ____exports -- 5153