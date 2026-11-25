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
function makeActor(room, index) -- 5184
	local sp = room.spawns -- 5185
	if index < 0 or index >= #sp then -- 5185
		return { -- 5187
			x = 0, -- 5187
			y = 0, -- 5187
			depth = 0, -- 5187
			depthSpeed = 0, -- 5187
			vx = 0, -- 5187
			vy = 0, -- 5187
			w = CHILD_W, -- 5187
			h = CHILD_H, -- 5187
			onGround = true, -- 5187
			facing = 1, -- 5187
			crouch = false, -- 5187
			rollT = 0, -- 5187
			covered = false, -- 5187
			alive = false -- 5187
		} -- 5187
	end -- 5187
	local s = sp[index + 1] -- 5189
	local child = s.h <= CHILD_H -- 5190
	local ground = room.depth -- 5191
	local depth = ground == nil and 0 or math.max( -- 5192
		ground.min, -- 5192
		math.min(ground.max, s.depth or 0) -- 5192
	) -- 5192
	return { -- 5193
		x = s.x, -- 5194
		y = s.y, -- 5194
		depth = depth, -- 5194
		depthSpeed = 0, -- 5194
		vx = 0, -- 5194
		vy = 0, -- 5194
		w = child and CHILD_W or SOLDIER_W, -- 5195
		h = child and CHILD_H or SOLDIER_H, -- 5196
		onGround = true, -- 5197
		facing = 1, -- 5197
		crouch = false, -- 5197
		rollT = 0, -- 5197
		covered = false, -- 5197
		alive = true -- 5197
	} -- 5197
end -- 5197
function drawFigure(draw, play, w, h, a, body, head) -- 5201
	if not a.alive then -- 5201
		return -- 5203
	end -- 5203
	local x0 = a.x - a.w / 2 -- 5205
	local x1 = a.x + a.w / 2 -- 5206
	local y0 = a.y + a.depth -- 5207
	local y1 = y0 + a.h -- 5208
	play:drawBox( -- 5209
		draw, -- 5209
		w, -- 5209
		h, -- 5209
		x0, -- 5209
		x1, -- 5209
		y0, -- 5209
		y1 - a.h * 0.26, -- 5209
		body -- 5209
	) -- 5209
	play:drawBox( -- 5210
		draw, -- 5210
		w, -- 5210
		h, -- 5210
		x0 + 2, -- 5210
		x1 - 2, -- 5210
		y1 - a.h * 0.26, -- 5210
		y1, -- 5210
		head -- 5210
	) -- 5210
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 5212
	play:drawBox( -- 5213
		draw, -- 5213
		w, -- 5213
		h, -- 5213
		eyeX, -- 5213
		eyeX + 4, -- 5213
		y1 - a.h * 0.14, -- 5213
		y1 - a.h * 0.08, -- 5213
		INK -- 5213
	) -- 5213
end -- 5213
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5217
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5218
end -- 5217
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5225
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5226
end -- 5225
function rayInterval(origin, direction, min, max) -- 5233
	if direction == 0 then -- 5233
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5235
	end -- 5235
	local a = (min - origin) / direction -- 5237
	local b = (max - origin) / direction -- 5238
	return { -- 5239
		min = math.min(a, b), -- 5239
		max = math.max(a, b) -- 5239
	} -- 5239
end -- 5239
function hitBox(ray, box) -- 5243
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5244
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5245
	local enter = math.max(0, x.min, y.min) -- 5246
	local leave = math.min(99999, x.max, y.max) -- 5247
	if box.depth ~= nil then -- 5247
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5249
		enter = math.max(enter, depth.min) -- 5250
		leave = math.min(leave, depth.max) -- 5251
	end -- 5251
	return leave >= enter and enter or -1 -- 5253
end -- 5253
function drawCartShape(draw, play, w, h, c, axleX) -- 5256
	local half = c.bodyW / 2 -- 5257
	local x0 = axleX - half -- 5258
	local x1 = axleX + half -- 5259
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 5260
	play:drawBox( -- 5261
		draw, -- 5261
		w, -- 5261
		h, -- 5261
		x0, -- 5261
		x1, -- 5261
		axleY, -- 5261
		axleY + c.bodyH, -- 5261
		CART_FILL -- 5261
	) -- 5261
	draw:drawCircle( -- 5262
		Vec2( -- 5262
			play:sx(x0 + c.bodyW * 0.28, w), -- 5262
			play:sy(axleY, h) -- 5262
		), -- 5262
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5262
		Color(52, 50, 48, 255) -- 5262
	) -- 5262
	draw:drawCircle( -- 5263
		Vec2( -- 5263
			play:sx(x1 - c.bodyW * 0.28, w), -- 5263
			play:sy(axleY, h) -- 5263
		), -- 5263
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5263
		Color(52, 50, 48, 255) -- 5263
	) -- 5263
	local cx = c.clothSide < 0 and x0 or x1 -- 5264
	play:drawBox( -- 5265
		draw, -- 5265
		w, -- 5265
		h, -- 5265
		cx - 10, -- 5265
		cx + 10, -- 5265
		axleY + c.bodyH, -- 5265
		axleY + c.bodyH + 18, -- 5265
		CLOTH -- 5265
	) -- 5265
end -- 5265
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
	do -- 1109
		i = 0 -- 1112
		while i < #self.pickups do -- 1112
			local pk = self.pickups[i + 1] -- 1113
			if self.run.taken[pk.id] == true then -- 1113
				pk.id = "" -- 1115
			end -- 1115
			i = i + 1 -- 1112
		end -- 1112
	end -- 1112
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1118
end -- 1040
function Play.prototype.log(self, line) -- 1121
	local ____self_run_log_18 = self.run.log -- 1121
	____self_run_log_18[#____self_run_log_18 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1122
	if #self.run.log > 120 then -- 1122
		table.remove(self.run.log, 1) -- 1124
	end -- 1124
end -- 1121
function Play.prototype.buildEnemies(self) -- 1128
	self.enemies = {} -- 1129
	if self.isCampaign then -- 1129
		local i = 0 -- 1131
		do -- 1131
			i = 0 -- 1132
			while i < #self.room.spawns do -- 1132
				local sp = self.room.spawns[i + 1] -- 1133
				local kind = sp.kind or "gunner" -- 1134
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1135
				local ____self_enemies_19 = self.enemies -- 1135
				____self_enemies_19[#____self_enemies_19 + 1] = { -- 1136
					x = sp.x, -- 1137
					y = sp.y, -- 1137
					depth = sp.depth, -- 1137
					w = 26, -- 1137
					h = sp.h, -- 1137
					alive = true, -- 1137
					hitT = 0, -- 1137
					warnT = 0, -- 1137
					fireCd = 40, -- 1137
					kind = kind, -- 1138
					shieldHp = hp, -- 1138
					shieldHpMax = hp, -- 1138
					drop = sp.drop or "none", -- 1138
					homeX = sp.x, -- 1139
					swingT = 0, -- 1139
					awake = false, -- 1139
					squad = i -- 1139
				} -- 1139
				i = i + 1 -- 1132
			end -- 1132
		end -- 1132
		return -- 1142
	end -- 1142
	if self.room.key == "checkpoint" then -- 1142
		local ____self_enemies_20 = self.enemies -- 1142
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 1145
			x = self.ox + 430, -- 1145
			y = 0, -- 1145
			w = 26, -- 1145
			h = 84, -- 1145
			alive = true, -- 1145
			hitT = 0, -- 1145
			warnT = 0, -- 1145
			fireCd = 0 -- 1145
		} -- 1145
		local ____self_enemies_21 = self.enemies -- 1145
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 1146
			x = self.ox + 505, -- 1146
			y = 0, -- 1146
			w = 26, -- 1146
			h = 84, -- 1146
			alive = true, -- 1146
			hitT = 0, -- 1146
			warnT = 0, -- 1146
			fireCd = 0 -- 1146
		} -- 1146
		return -- 1147
	end -- 1147
	if self.room.key == "street" then -- 1147
		local ____self_enemies_22 = self.enemies -- 1147
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 1151
			x = self.ox + 340, -- 1151
			y = 0, -- 1151
			w = 26, -- 1151
			h = 84, -- 1151
			alive = true, -- 1151
			hitT = 0, -- 1151
			warnT = 0, -- 1151
			fireCd = 0 -- 1151
		} -- 1151
		local ____self_enemies_23 = self.enemies -- 1151
		____self_enemies_23[#____self_enemies_23 + 1] = { -- 1152
			x = self.ox + 560, -- 1152
			y = 0, -- 1152
			w = 26, -- 1152
			h = 84, -- 1152
			alive = true, -- 1152
			hitT = 0, -- 1152
			warnT = 0, -- 1152
			fireCd = 0 -- 1152
		} -- 1152
	end -- 1152
end -- 1128
function Play.prototype.emit(self, name, data) -- 1158
	local ____self_events_24 = self.events -- 1158
	____self_events_24[#____self_events_24 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1159
	self.eventSeq = self.eventSeq + 1 -- 1160
	if #self.events > 256 then -- 1160
		table.remove(self.events, 1) -- 1162
	end -- 1162
end -- 1158
function Play.prototype.drainEvents(self) -- 1170
	local out = self.events -- 1171
	self.events = {} -- 1172
	return out -- 1173
end -- 1170
function Play.prototype.adoptEvents(self, events) -- 1182
	if #events == 0 then -- 1182
		return -- 1184
	end -- 1184
	local keep = {} -- 1186
	local i = 0 -- 1187
	do -- 1187
		i = 0 -- 1188
		while i < #events do -- 1188
			do -- 1188
				local e = events[i + 1] -- 1189
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1189
					goto __continue114 -- 1191
				end -- 1191
				keep[#keep + 1] = e -- 1193
			end -- 1193
			::__continue114:: -- 1193
			i = i + 1 -- 1188
		end -- 1188
	end -- 1188
	if #keep == 0 then -- 1188
		return -- 1196
	end -- 1196
	self.events = __TS__ArrayConcat(keep, self.events) -- 1198
	do -- 1198
		i = 0 -- 1199
		while i < #self.events do -- 1199
			self.events[i + 1].seq = i -- 1200
			i = i + 1 -- 1199
		end -- 1199
	end -- 1199
	self.eventSeq = #self.events -- 1202
end -- 1182
function Play.prototype.chooseTalent(self, slot) -- 1205
	local trial = self.run.trial -- 1206
	local talent = trial and trial.offers[slot + 1] -- 1207
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 1207
		return -- 1208
	end -- 1208
	local ____trial_ranks_27, ____talent_28 = trial.ranks, talent -- 1208
	____trial_ranks_27[____talent_28] = ____trial_ranks_27[____talent_28] + 1 -- 1209
	trial.offers = {} -- 1210
	if talent == "vitality" then -- 1210
		self.maxHp = self.maxHp + 1 -- 1212
		self.hp = self.hp + 1 -- 1213
		trial.hp = self.hp -- 1214
	end -- 1214
	self:flashSet(talentNames[talent], 1.2) -- 1216
end -- 1205
function Play.prototype.beginReload(self) -- 1224
	self.reloadT = self:reloadTicks() -- 1225
	local camp = self.room.campaign -- 1226
	if self.run.trial == nil and camp ~= nil and camp.reloadPuzzle == true then -- 1226
		self:openReloadPuzzle() -- 1229
	end -- 1229
end -- 1224
function Play.prototype.openReloadPuzzle(self) -- 1234
	self.reloadOpen = true -- 1235
	self.reloadAnswerTicks = 0 -- 1236
	self.reloadWorldTicks = 0 -- 1237
	self.reloadPath = {RELOAD_START} -- 1238
	self.reloadPendingEffect = "" -- 1239
	self.reloadTryCount = self.reloadTryCount + 1 -- 1240
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 1241
end -- 1234
function Play.prototype.closeReloadPuzzle(self) -- 1245
	self.reloadOpen = false -- 1246
	self.reloadAnswerTicks = 0 -- 1247
	self.reloadWorldTicks = 0 -- 1248
	self.reloadPath = {RELOAD_START} -- 1249
	self.reloadPendingEffect = "" -- 1250
end -- 1245
function Play.prototype.reloadTapNode(self, node) -- 1257
	if not self.reloadOpen then -- 1257
		return -- 1259
	end -- 1259
	local path = self.reloadPath -- 1261
	local last = path[#path] -- 1262
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1262
		self.reloadPath = {RELOAD_START} -- 1264
		self:emit("reloadInvalid", {node = node, at = last}) -- 1265
		return -- 1266
	end -- 1266
	path[#path + 1] = node -- 1268
	if node ~= RELOAD_TARGET then -- 1268
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1270
		return -- 1271
	end -- 1271
	if not reloadPathValid(path) then -- 1271
		self.reloadPath = {RELOAD_START} -- 1274
		self:emit("reloadInvalid", {node = node, at = last}) -- 1275
		return -- 1276
	end -- 1276
	self.reloadPendingEffect = reloadEffectOf(path) -- 1278
	self.reloadOpen = false -- 1279
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1280
	self:flashSet( -- 1283
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1283
		1.4 -- 1283
	) -- 1283
end -- 1257
function Play.prototype.consumeReloadEffect(self) -- 1287
	local e = self.reloadPendingEffect -- 1288
	if e ~= "" then -- 1288
		self.reloadPendingEffect = "" -- 1290
	end -- 1290
	return e -- 1292
end -- 1287
function Play.prototype.echoToSource(self, from, count) -- 1299
	if count == nil then -- 1299
		count = 1 -- 1299
	end -- 1299
	local best = -1 -- 1300
	local bestD = 1000000000 -- 1301
	local i = 0 -- 1302
	local woken = {} -- 1303
	local n = 0 -- 1304
	while n < count do -- 1304
		best = -1 -- 1306
		bestD = 1000000000 -- 1307
		do -- 1307
			i = 0 -- 1308
			while i < #self.enemies do -- 1308
				do -- 1308
					if woken[i] == true then -- 1308
						goto __continue136 -- 1310
					end -- 1310
					local e = self.enemies[i + 1] -- 1312
					if not e.alive then -- 1312
						goto __continue136 -- 1314
					end -- 1314
					local d = math.abs(e.x - from.x) -- 1316
					if d < bestD then -- 1316
						bestD = d -- 1318
						best = i -- 1319
					end -- 1319
				end -- 1319
				::__continue136:: -- 1319
				i = i + 1 -- 1308
			end -- 1308
		end -- 1308
		if best < 0 then -- 1308
			break -- 1323
		end -- 1323
		woken[best] = true -- 1325
		local e = self.enemies[best + 1] -- 1326
		e.awake = true -- 1327
		e.warnT = 0 -- 1328
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1329
		n = n + 1 -- 1330
	end -- 1330
	if n == 0 then -- 1330
		return -- 1333
	end -- 1333
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1335
end -- 1299
function Play.prototype.reloadTicks(self) -- 1338
	local ____temp_31 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 1339
	local ____opt_29 = self.run.trial -- 1339
	return math.max(6, ____temp_31 - 6 * (____opt_29 and ____opt_29.ranks.reload or 0)) -- 1339
end -- 1338
function Play.prototype.update(self, dt, input) -- 1342
	self:syncCraftBench() -- 1343
	local trial = self.run.trial -- 1344
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1344
		return -- 1345
	end -- 1345
	if input.pause.pressed then -- 1345
		self.paused = not self.paused -- 1347
	end -- 1347
	if self.flashT > 0 then -- 1347
		self.flashT = self.flashT - dt -- 1350
		if self.flashT <= 0 then -- 1350
			self.flash = "" -- 1352
		end -- 1352
	end -- 1352
	if self.traceT > 0 then -- 1352
		self.traceT = self.traceT - dt -- 1356
		if self.traceT <= 0 then -- 1356
			self.trace = nil -- 1358
		end -- 1358
	end -- 1358
	if self.paused then -- 1358
		self:updateCamera(dt) -- 1362
		return -- 1363
	end -- 1363
	if self.craftBench.active then -- 1363
		if input.interact.pressed or input.pause.pressed then -- 1363
			self:closeCraftBench() -- 1369
		end -- 1369
		self:updateCamera(dt) -- 1371
		return -- 1372
	end -- 1372
	if self.reloadOpen then -- 1372
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1378
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1378
			self.reloadOpen = false -- 1380
			self.reloadPendingEffect = "" -- 1381
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1382
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1383
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1383
			self:updateCamera(dt) -- 1385
			return -- 1386
		else -- 1386
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1388
		end -- 1388
	end -- 1388
	self.ticks = self.ticks + 1 -- 1392
	if self.invulnT > 0 then -- 1392
		self.invulnT = self.invulnT - 1 -- 1396
	end -- 1396
	if self.isCampaign then -- 1396
		local ____self_run_32, ____ticks_33 = self.run, "ticks" -- 1396
		____self_run_32[____ticks_33] = ____self_run_32[____ticks_33] + 1 -- 1399
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1400
	end -- 1400
	local p = self.player -- 1402
	self:stepPlayer(p, dt, input) -- 1403
	self:refreshCover(p, input) -- 1405
	if self.carryOn then -- 1405
		self:carryPose() -- 1407
	end -- 1407
	if self.isCampaign then -- 1407
		self:stepCampaign(dt, input) -- 1410
		if not self.carryOn then -- 1410
			self:stepCampaignPartner(dt) -- 1412
		end -- 1412
	end -- 1412
	if trial == nil or not self.run.finished then -- 1412
		self:stepEnemies(dt, input) -- 1420
	end -- 1420
	if trial ~= nil then -- 1420
		trial.hp = self.hp -- 1422
	end -- 1422
	if not self.isCampaign then -- 1422
		self:stepStory(dt, input) -- 1424
		self:stepEscort(dt, input) -- 1425
		self:stepVillage(dt, input) -- 1426
		self:stepChase(dt, input) -- 1427
		self:stepInteract(dt, input) -- 1428
	end -- 1428
	self:updateGate() -- 1430
	self:updateCamera(dt) -- 1431
	self:syncStory() -- 1433
end -- 1342
function Play.prototype.underLowArch(self, a) -- 1440
	local arch = self.room.arch -- 1441
	if arch.h <= 0 then -- 1441
		return false -- 1443
	end -- 1443
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1443
		return false -- 1446
	end -- 1446
	local top = arch.y + arch.h -- 1448
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1449
end -- 1440
function Play.prototype.coverAt(self, a) -- 1456
	local best = nil -- 1457
	local bestGap = 24 -- 1458
	local half = a.w / 2 -- 1459
	local i = 0 -- 1460
	do -- 1460
		i = 0 -- 1461
		while i < #self.boxes do -- 1461
			do -- 1461
				local b = self.boxes[i + 1] -- 1462
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1462
					goto __continue170 -- 1464
				end -- 1464
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1464
					goto __continue170 -- 1467
				end -- 1467
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1469
				if gap < bestGap then -- 1469
					bestGap = gap -- 1471
					best = b -- 1472
				end -- 1472
			end -- 1472
			::__continue170:: -- 1472
			i = i + 1 -- 1461
		end -- 1461
	end -- 1461
	return best -- 1475
end -- 1456
function Play.prototype.nearCover(self, a) -- 1478
	return self:coverAt(a) ~= nil -- 1479
end -- 1478
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1483
	if enemy == nil then -- 1483
		return false -- 1485
	end -- 1485
	local fromRight = enemy.x >= a.x -- 1487
	local edge = fromRight and b.x0 or b.x1 -- 1488
	local ____fromRight_34 -- 1489
	if fromRight then -- 1489
		____fromRight_34 = edge >= a.x - 0.001 and edge <= enemy.x -- 1489
	else -- 1489
		____fromRight_34 = edge <= a.x + 0.001 and edge >= enemy.x -- 1490
	end -- 1490
	local between = ____fromRight_34 -- 1489
	local separation = enemy.x - a.x -- 1491
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1492
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1493
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1494
end -- 1483
function Play.prototype.nearestEnemy(self, a) -- 1497
	local best -- 1498
	local bestD = 1000000000 -- 1499
	local i = 0 -- 1500
	do -- 1500
		i = 0 -- 1501
		while i < #self.enemies do -- 1501
			do -- 1501
				local e = self.enemies[i + 1] -- 1502
				if not e.alive then -- 1502
					goto __continue179 -- 1504
				end -- 1504
				local d = math.abs(e.x - a.x) -- 1506
				if d < bestD then -- 1506
					bestD = d -- 1508
					best = e -- 1509
				end -- 1509
			end -- 1509
			::__continue179:: -- 1509
			i = i + 1 -- 1501
		end -- 1501
	end -- 1501
	return best -- 1512
end -- 1497
function Play.prototype.refreshCover(self, a, input) -- 1516
	if self.childMode then -- 1516
		self.coverNear = false -- 1518
		self.coverHug = false -- 1519
		self.coverEntity = "" -- 1520
		self.coverBlocking = false -- 1521
		a.covered = false -- 1522
		return -- 1523
	end -- 1523
	local b = self:coverAt(a) -- 1525
	self.coverNear = b ~= nil -- 1526
	a.covered = self.coverNear and input.cover.held -- 1527
	self.coverHug = a.covered -- 1528
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1529
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1530
		b, -- 1530
		a, -- 1530
		self:nearestEnemy(a) -- 1530
	) -- 1530
end -- 1516
function Play.prototype.cartHandleInReach(self, a) -- 1534
	if a == nil then -- 1534
		a = self.player -- 1534
	end -- 1534
	local c = self.room.cart -- 1535
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1535
		return false -- 1537
	end -- 1537
	local handleX = self.cartAxle + c.handleOffset -- 1539
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1540
end -- 1534
function Play.prototype.nearLowLedge(self, a) -- 1545
	local reach = 26 -- 1546
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1547
	local x1 = x0 + reach -- 1548
	local i = 0 -- 1549
	do -- 1549
		i = 0 -- 1550
		while i < #self.boxes do -- 1550
			do -- 1550
				local b = self.boxes[i + 1] -- 1551
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1551
					goto __continue188 -- 1553
				end -- 1553
				local rise = b.y1 - a.y -- 1555
				if rise > 0 and rise <= LEDGE_RISE then -- 1555
					return true -- 1557
				end -- 1557
			end -- 1557
			::__continue188:: -- 1557
			i = i + 1 -- 1550
		end -- 1550
	end -- 1550
	return false -- 1560
end -- 1545
function Play.prototype.stepPlayer(self, a, dt, input) -- 1563
	a.depthSpeed = 0 -- 1564
	if not a.alive then -- 1564
		return -- 1566
	end -- 1566
	local isChild = self.childMode -- 1568
	local lowArch = isChild and self:underLowArch(a) -- 1570
	if self:storyLocked() then -- 1570
		a.vx = 0 -- 1573
		a.crouch = isChild and lowArch -- 1574
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1575
		self:fallY(a, dt) -- 1576
		return -- 1577
	end -- 1577
	if not isChild and self.escort.state == "calming" then -- 1577
		a.crouch = false -- 1581
		a.h = SOLDIER_H -- 1582
		a.vx = 0 -- 1583
		self:fallY(a, dt) -- 1584
		return -- 1585
	end -- 1585
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 1587
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1588
	local nearCover = not isChild and self:nearCover(a) -- 1589
	a.covered = nearCover and input.cover.held -- 1590
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1592
	if a.rollT > 0 then -- 1592
		a.rollT = a.rollT - dt -- 1596
		a.vx = a.facing * ROLL_SPEED -- 1597
		self:slideX(a, a.vx * dt) -- 1598
		self:fallY(a, dt) -- 1599
		if a.rollT <= 0 then -- 1599
			self:flashSet("翻滚结束", 0.5) -- 1601
		end -- 1601
		return -- 1603
	end -- 1603
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1603
		if input.moveX ~= 0 then -- 1603
			a.facing = input.moveX > 0 and 1 or -1 -- 1608
		end -- 1608
		if self:nearLowLedge(a) then -- 1608
			a.vy = SOLDIER_JUMP -- 1612
			a.onGround = false -- 1613
			self:flashSet("翻上去", 0.3) -- 1614
			return -- 1615
		end -- 1615
		a.rollT = ROLL_TIME -- 1617
		self:flashSet("翻滚", 0.3) -- 1618
		return -- 1619
	end -- 1619
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1622
	if isChild then -- 1622
		if input.cover.held then -- 1622
			speed = CHILD_SLOW -- 1625
		end -- 1625
		if a.crouch then -- 1625
			speed = CHILD_SLOW -- 1628
		end -- 1628
	elseif a.covered then -- 1628
		speed = SOLDIER_SPEED * 0.45 -- 1631
	end -- 1631
	local handsBusy = self.gripping or gripIntent -- 1635
	local dir = self.gripping and 0 or input.moveX -- 1636
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 1637
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1638
	if dir ~= 0 then -- 1638
		a.facing = dir > 0 and 1 or -1 -- 1640
	end -- 1640
	a.vx = dir * speed * diagonal -- 1642
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1642
		a.vy = CHILD_JUMP -- 1646
		a.onGround = false -- 1647
		self:flashSet("跳", 0.25) -- 1648
	end -- 1648
	local previousDepth = a.depth -- 1652
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1653
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1654
	self:slideX(a, a.vx * dt) -- 1655
	self:fallY(a, dt) -- 1656
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1656
		self:shoot(a) -- 1660
	end -- 1660
end -- 1563
function Play.prototype.stepPartner(self, p, dt) -- 1665
	local a = self.partner -- 1666
	if not a.alive then -- 1666
		return -- 1668
	end -- 1668
	a.crouch = false -- 1670
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1671
	a.vx = 0 -- 1672
	a.depthSpeed = 0 -- 1673
	self:fallY(a, dt) -- 1674
end -- 1665
function Play.prototype.stepEscort(self, dt, input) -- 1681
	local a = self.partner -- 1682
	a.depthSpeed = 0 -- 1683
	if not a.alive then -- 1683
		return -- 1685
	end -- 1685
	if self.room.key == "gatepath" then -- 1685
		if self.carryOn then -- 1685
			return -- 1690
		end -- 1690
		local p = self.player -- 1693
		a.depth = p.depth -- 1694
		a.facing = p.facing -- 1695
		a.crouch = false -- 1696
		a.h = CHILD_H -- 1697
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 1698
		a.y = p.y -- 1699
		a.vy = 0 -- 1700
		a.vx = p.vx -- 1701
		a.onGround = p.onGround -- 1702
		return -- 1703
	end -- 1703
	if not self:escortOn() then -- 1703
		a.vx = 0 -- 1706
		self:fallY(a, dt) -- 1707
		return -- 1708
	end -- 1708
	local p = self.player -- 1710
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1711
	local hadKnock1 = self.escort.knock1 -- 1712
	local hadKnock2 = self.escort.knock2 -- 1713
	self.calmConsumed = self.escort:update( -- 1714
		input, -- 1714
		p.x, -- 1714
		p.facing, -- 1714
		a.x, -- 1714
		dist -- 1714
	) -- 1714
	if not hadKnock1 and self.escort.knock1 then -- 1714
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1717
	end -- 1717
	if not hadKnock2 and self.escort.knock2 then -- 1717
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1720
	end -- 1720
	a.crouch = self.escort.crouchPose -- 1722
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1723
	if not self.escort.stopped then -- 1723
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1725
		local previousDepth = a.depth -- 1726
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1727
		local distance = math.max( -- 1728
			-travel, -- 1728
			math.min(travel, targetDepth - previousDepth) -- 1728
		) -- 1728
		self:slideDepth(a, distance) -- 1729
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1730
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1730
			a.vy = CHILD_JUMP -- 1732
			a.onGround = false -- 1733
		end -- 1733
	end -- 1733
	local dir = self.escort:moveDir(a.x) -- 1736
	a.vx = dir * CHILD_SPEED -- 1737
	if dir ~= 0 then -- 1737
		a.facing = dir -- 1739
		local before = a.x -- 1740
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1741
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1741
			a.vy = CHILD_JUMP -- 1744
			a.onGround = false -- 1745
		end -- 1745
	end -- 1745
	self:fallY(a, dt) -- 1748
end -- 1681
function Play.prototype.escortOn(self) -- 1752
	if self.room.key == "checkpoint" then -- 1752
		return true -- 1754
	end -- 1754
	if self.room.key == "gatepath" then -- 1754
		return true -- 1757
	end -- 1757
	if self.room.key == "prologue" then -- 1757
		return self.phase == "prologue-follow" -- 1760
	end -- 1760
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 1760
		return true -- 1764
	end -- 1764
	return self.room.key == "street" -- 1766
end -- 1752
function Play.prototype.storyLocked(self) -- 1770
	if self.caughtT > 0 then -- 1770
		return true -- 1772
	end -- 1772
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1772
		return true -- 1775
	end -- 1775
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 1775
		return true -- 1778
	end -- 1778
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1778
		return true -- 1781
	end -- 1781
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 1781
		return true -- 1784
	end -- 1784
	if self.craftBench.active then -- 1784
		return true -- 1788
	end -- 1788
	return false -- 1790
end -- 1770
function Play.prototype.swapToChild(self, x) -- 1794
	local tmp = self.player -- 1795
	self.player = self.partner -- 1796
	self.partner = tmp -- 1797
	self.childMode = true -- 1798
	self.player.alive = true -- 1799
	self.player.x = self.ox + x -- 1800
	self.player.y = 0 -- 1801
	self.player.depth = 0 -- 1802
	self.player.depthSpeed = 0 -- 1803
	self.player.vy = 0 -- 1804
	self.player.vx = 0 -- 1805
	self.player.onGround = true -- 1806
	self.player.crouch = false -- 1807
	self.player.h = CHILD_H -- 1808
	self.player.facing = 1 -- 1809
	self.partner.alive = true -- 1810
	self.cam.x = self.player.x -- 1811
end -- 1794
function Play.prototype.stepStory(self, dt, input) -- 1815
	if self.room.key == "prologue" then -- 1815
		self:stepPrologue(dt, input) -- 1817
	elseif self.room.key == "street" then -- 1817
		self:stepStreet(dt, input) -- 1819
	elseif self.room.key == "gate" then -- 1819
		self:stepGate(dt, input) -- 1821
	elseif self.room.key == "gatepath" then -- 1821
		self:stepGatePath() -- 1823
	elseif self.room.key == "tower" then -- 1823
		self:stepTower(dt, input) -- 1825
	elseif self.room.key == "museum" then -- 1825
		self:stepMuseum(dt, input) -- 1827
	end -- 1827
end -- 1815
function Play.prototype.wellWindow(self) -- 1833
	return not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 1834
end -- 1833
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
		self.player.x = self.ox + self.wellX -- 1866
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
			self.archive.museumPhase = "well_reflect" -- 1883
			self.archiveDirty = true -- 1884
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 1885
			return -- 1886
		end -- 1886
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1888
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1890
		if near and input.interact.pressed then -- 1890
			self.phase = "prologue-give" -- 1892
			self.phaseTick = 0 -- 1893
			self:flashSet("递出针套", 1) -- 1894
		end -- 1894
		return -- 1896
	end -- 1896
	if self.phase == "prologue-well" then -- 1896
		self.phaseTick = self.phaseTick + 1 -- 1900
		if self.phaseTick == 12 then -- 1900
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 1902
		elseif self.phaseTick >= 30 then -- 1902
			self.phase = "prologue-wait" -- 1904
			self.phaseTick = 0 -- 1905
			self.wellTaken = true -- 1906
			self.wellOpen = false -- 1907
			self.run.archive.artifactOwned = true -- 1908
			self.archiveDirty = true -- 1909
			self:emit("artifactFound", { -- 1910
				x = self.ox + self.wellX, -- 1911
				y = 0, -- 1911
				room = "prologue", -- 1911
				once = true, -- 1911
				source = self.run.source -- 1912
			}) -- 1912
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 1914
			self:log("井底取到时间穿梭器") -- 1915
		end -- 1915
		return -- 1917
	end -- 1917
	if self.phase == "prologue-give" then -- 1917
		self.phaseTick = self.phaseTick + 1 -- 1920
		if self.phaseTick == 12 then -- 1920
			self:flashSet("针套递过去", 0.7) -- 1922
		elseif self.phaseTick == 36 then -- 1922
			self:flashSet("纸条塞进针套", 0.9) -- 1924
		elseif self.phaseTick >= 60 then -- 1924
			self.phase = "prologue-follow" -- 1926
			self.phaseTick = 0 -- 1927
			child.crouch = false -- 1928
			child.h = CHILD_H -- 1929
			self:flashSet("她跟上了", 1.2) -- 1930
		end -- 1930
		return -- 1932
	end -- 1932
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1932
		self:requestRoom("street", "序章跟到门口") -- 1936
		self:flashSet("进街道", 1.2) -- 1937
	end -- 1937
end -- 1859
function Play.prototype.stepStreet(self, dt, input) -- 1942
	local p = self.player -- 1943
	local c = self.partner -- 1944
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1944
		self:requestRoom("checkpoint", "两人都到街尾") -- 1946
		self:flashSet("到检查站", 1.2) -- 1947
	end -- 1947
end -- 1942
function Play.prototype.stepGate(self, dt, input) -- 1952
	local ____temp_35 -- 1953
	if self.room.story == nil then -- 1953
		____temp_35 = nil -- 1953
	else -- 1953
		____temp_35 = self.room.story.gate -- 1953
	end -- 1953
	local g = ____temp_35 -- 1953
	if g == nil then -- 1953
		return -- 1955
	end -- 1955
	local p = self.player -- 1957
	if self.phase == "gate-idle" then -- 1957
		local a = self.partner -- 1960
		local gap = g.waitX - a.x -- 1961
		if math.abs(gap) > 3 then -- 1961
			a.facing = gap > 0 and 1 or -1 -- 1963
			a.vx = a.facing * CHILD_SPEED -- 1964
			local beforeX = a.x -- 1965
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1966
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1966
				a.vy = CHILD_JUMP -- 1968
				a.onGround = false -- 1969
			end -- 1969
			self:fallY(a, dt) -- 1971
		else -- 1971
			a.vx = 0 -- 1973
			a.x = g.waitX -- 1974
		end -- 1974
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1977
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1978
		if self.gateNeedConfirm then -- 1978
			if not input.interact.held then -- 1978
				self.gateRestartArmed = true -- 1983
			end -- 1983
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1983
				self.gateNeedConfirm = false -- 1986
				self.gateRestartArmed = true -- 1987
				self.phase = "gate-hold" -- 1988
				self.gateTick = 0 -- 1989
				self.gateSpawned = 0 -- 1990
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1991
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1992
			end -- 1992
			return -- 1994
		end -- 1994
		if atWinch and atWait then -- 1994
			self.phase = "gate-hold" -- 1997
			self.gateTick = 0 -- 1998
			self.gateSpawned = 0 -- 1999
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2000
		end -- 2000
		return -- 2002
	end -- 2002
	if self.phase == "gate-hold" then -- 2002
		self.gateTick = self.gateTick + 1 -- 2005
		local marks = {0, 540, 900, 1500} -- 2007
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2007
			local idx = self.gateSpawned -- 2009
			local ____self_enemies_36 = self.enemies -- 2009
			____self_enemies_36[#____self_enemies_36 + 1] = { -- 2010
				x = self.ox + 620 + idx * 62, -- 2011
				y = 0, -- 2011
				w = 26, -- 2011
				h = 84, -- 2011
				alive = true, -- 2012
				hitT = 0, -- 2012
				warnT = 0, -- 2012
				fireCd = 90 + idx * 45 -- 2012
			} -- 2012
			self.gateSpawned = self.gateSpawned + 1 -- 2014
			self:flashSet( -- 2015
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2015
				0.9 -- 2015
			) -- 2015
		end -- 2015
		if self.gateTick == 900 then -- 2015
			self:flashSet("灯灭了", 1) -- 2018
		elseif self.gateTick == 2100 then -- 2018
			self:flashSet("门底压下来了", 1) -- 2020
		end -- 2020
		if self.gateTick >= g.holdTicks then -- 2020
			self:captureGateBlood() -- 2025
			self.phase = "gate-send" -- 2026
			self.phaseTick = 0 -- 2027
			self.enemies = {} -- 2029
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2030
		end -- 2030
		return -- 2032
	end -- 2032
	if self.phase == "gate-send" then -- 2032
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2035
		if near and input.interact.pressed then -- 2035
			self:commitRoute() -- 2038
			self:swapToChild(g.doorX + 30) -- 2039
			self.phase = "gate-count" -- 2040
			self.countTick = 0 -- 2041
			self.countArmed = false -- 2043
			self.countPrevMove = input.moveX -- 2044
			self:flashSet("门开了 · 送她出去", 1.8) -- 2045
		end -- 2045
		return -- 2047
	end -- 2047
	if self.phase == "gate-count" then -- 2047
		self.countTick = self.countTick + 1 -- 2050
		if self.countTick == 360 then -- 2050
			self:flashSet("门关上", 0.9) -- 2052
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2052
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2054
			if self.storyRoute == "soldier" then -- 2054
				self.phase = "gate-wait" -- 2060
				self.phaseTick = 0 -- 2061
				self.knocks = 1 -- 2062
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2063
				self.handArmed = not input.interact.held -- 2065
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2066
			else -- 2066
				self:flashSet("数到二十", 2.2) -- 2068
			end -- 2068
		end -- 2068
		local prevMove = self.countPrevMove -- 2073
		self.countPrevMove = input.moveX -- 2074
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2074
			if prevMove <= 0 and input.moveX > 0 then -- 2074
				self.countArmed = true -- 2077
			end -- 2077
			if self.countArmed and input.moveX > 0 then -- 2077
				self.phase = "gate-walk" -- 2080
				self.phaseTick = 0 -- 2081
				self:flashSet("她迈出第一步", 1.4) -- 2082
				self:emit("storyExit", { -- 2083
					route = "child", -- 2083
					via = "walk", -- 2083
					countTick = self.countTick, -- 2083
					hp = self.hp, -- 2083
					maxHp = self.maxHp -- 2083
				}) -- 2083
			end -- 2083
		end -- 2083
		return -- 2086
	end -- 2086
	if self.phase == "gate-wait" then -- 2086
		self.phaseTick = self.phaseTick + 1 -- 2090
		if self.phaseTick == 12 then -- 2090
			self.knocks = 2 -- 2092
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2093
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2094
		end -- 2094
		if not input.interact.held then -- 2094
			if self.handTicks > 0 then -- 2094
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2098
			end -- 2098
			self.handTicks = 0 -- 2100
			self.handArmed = true -- 2101
			return -- 2102
		end -- 2102
		if self.handArmed then -- 2102
			self.handTicks = self.handTicks + 1 -- 2105
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2105
				self.phase = "gate-hand" -- 2107
				self.phaseTick = 0 -- 2108
				self.handDone = true -- 2109
				self.tied = true -- 2110
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2111
				if not self.lineSaid then -- 2111
					self.lineSaid = true -- 2113
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2114
				end -- 2114
				self:flashSet("我们走吧。", 3) -- 2116
			end -- 2116
		end -- 2116
		return -- 2119
	end -- 2119
	if self.phase == "gate-hand" then -- 2119
		self.phaseTick = self.phaseTick + 1 -- 2123
		if self.phaseTick == 30 then -- 2123
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2125
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2125
			self:emit("storyExit", { -- 2127
				route = "soldier", -- 2127
				via = "hand", -- 2127
				handTicks = self.handTicks, -- 2127
				hp = self.hp, -- 2127
				maxHp = self.maxHp -- 2127
			}) -- 2127
			self:requestRoom("gatepath", "牵手同行") -- 2128
		end -- 2128
		return -- 2130
	end -- 2130
	if self.phase == "gate-walk" then -- 2130
		if self.player.x >= g.exitX then -- 2130
			self:requestRoom("outside", "走出城门") -- 2135
			self:flashSet("出城门 · 城外", 1.4) -- 2136
		end -- 2136
	end -- 2136
end -- 1952
function Play.prototype.captureGateBlood(self) -- 2145
	self.hpAtGate = self.hp -- 2146
	self.maxHpAtGate = self.maxHp -- 2147
end -- 2145
function Play.prototype.commitRoute(self) -- 2154
	if self.storySettled then -- 2154
		return -- 2156
	end -- 2156
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2158
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2159
	self.hpAtGate = hp -- 2160
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2161
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2162
	self.storySettled = true -- 2163
	self:emit("storyRouteLocked", { -- 2164
		route = self.storyRoute, -- 2165
		hp = self.hp, -- 2165
		maxHp = self.maxHp, -- 2165
		hpAtGate = self.hpAtGate, -- 2166
		maxHpAtGate = self.maxHpAtGate -- 2166
	}) -- 2166
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2168
end -- 2154
function Play.prototype.syncStory(self) -- 2172
	if self.isCampaign and self.run.trial ~= nil then -- 2172
		return -- 2174
	end -- 2174
	local s = self.run.story -- 2176
	if s == nil then -- 2176
		return -- 2178
	end -- 2178
	s.hp = self.hp -- 2180
	s.maxHp = self.maxHp -- 2181
	s.route = self.storyRoute -- 2182
	s.settled = self.storySettled -- 2183
	s.hpAtGate = self.hpAtGate -- 2184
	s.maxHpAtGate = self.maxHpAtGate -- 2185
	s.handDone = self.handDone -- 2186
	s.lineSaid = self.lineSaid -- 2187
	s.tied = self.tied -- 2188
	s.carry = self.carryOn -- 2189
	s.museumReturn = self.museumReturn -- 2190
	s.escortDone = self.escortDone -- 2191
	s.craftedWeapon = self.run.story.craftedWeapon -- 2192
	s.ending = self.run.story.ending -- 2193
	if self.room.key == "gate" then -- 2193
		s.phase = self.phase -- 2195
		s.countTick = self.countTick -- 2196
		s.phaseTick = self.phaseTick -- 2197
		s.handTicks = self.handTicks -- 2198
	end -- 2198
end -- 2172
function Play.prototype.stepGatePath(self) -- 2203
	local ____temp_37 -- 2204
	if self.room.story == nil then -- 2204
		____temp_37 = nil -- 2204
	else -- 2204
		____temp_37 = self.room.story.gatepath -- 2204
	end -- 2204
	local gp = ____temp_37 -- 2204
	if self.phase == "gatepath-start" then -- 2204
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2204
			self.carryOn = true -- 2207
			self.phase = "gatepath-carry" -- 2208
			self.phaseTick = 0 -- 2209
			self.pathDone = true -- 2210
			self.escortDone = false -- 2211
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2212
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2213
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2214
		end -- 2214
		return -- 2216
	end -- 2216
	if self.phase == "gatepath-carry" then -- 2216
		self.phaseTick = self.phaseTick + 1 -- 2219
		if self.phaseTick == 20 then -- 2219
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2221
		end -- 2221
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2221
			self:requestRoom(gp.next, "背负进首战") -- 2224
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2225
		end -- 2225
	end -- 2225
end -- 2203
function Play.prototype.carryPose(self) -- 2234
	local p = self.player -- 2235
	local a = self.partner -- 2236
	a.alive = true -- 2237
	a.x = p.x - p.facing * 12 -- 2238
	a.y = p.y + 26 -- 2239
	a.depth = p.depth -- 2240
	a.vx = p.vx -- 2241
	a.vy = 0 -- 2242
	a.onGround = true -- 2243
	a.crouch = false -- 2244
	a.h = CHILD_CROUCH_H -- 2245
	a.facing = p.facing -- 2246
end -- 2234
function Play.prototype.stepMuseum(self, dt, input) -- 2254
	self.partner.alive = false -- 2255
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2256
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2259
	if self.phase == "museum-cabinet" then -- 2259
		if atCase and input.interact.pressed then -- 2259
			self.phase = "museum-hall" -- 2262
			self.phaseTick = 0 -- 2263
			self.archive.museumPhase = "hall_walk" -- 2264
			self.archiveDirty = true -- 2265
			self:emit("museumStep", {step = "cabinet", x = self.ox + mu.cabinetX}) -- 2266
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2267
		end -- 2267
		return -- 2269
	end -- 2269
	if self.phase == "museum-hall" then -- 2269
		if self.player.x >= self.ox + mu.hallX and input.interact.pressed then -- 2269
			self.phase = "museum-lamp" -- 2273
			self.phaseTick = 0 -- 2274
			self.archive.museumPhase = "lamp_turn" -- 2275
			self.archiveDirty = true -- 2276
			self:emit("museumStep", {step = "hall", x = self.ox + mu.hallX}) -- 2277
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2278
		end -- 2278
		return -- 2280
	end -- 2280
	if self.phase == "museum-lamp" then -- 2280
		if self.player.x >= self.ox + mu.lampX and input.interact.pressed then -- 2280
			self.phase = "museum-return" -- 2284
			self.phaseTick = 0 -- 2285
			self.archive.museumPhase = "return_cabinet" -- 2286
			self.archiveDirty = true -- 2287
			self:emit("museumStep", {step = "lamp", x = self.ox + mu.lampX}) -- 2288
			self:flashSet("灯 · 转向西窗", 1.8) -- 2289
		end -- 2289
		return -- 2291
	end -- 2291
	if self.phase == "museum-return" then -- 2291
		if atCase and input.interact.pressed then -- 2291
			self.phase = "museum-knock" -- 2295
			self.phaseTick = 0 -- 2296
			self:emit("museumStep", {step = "knock", count = 1, x = self.ox + mu.cabinetX}) -- 2297
			self:flashSet("回柜边 · 第一下", 0.8) -- 2298
		end -- 2298
		return -- 2300
	end -- 2300
	if self.phase == "museum-knock" then -- 2300
		self.phaseTick = self.phaseTick + 1 -- 2303
		if self.phaseTick == 8 then -- 2303
			self:emit("museumStep", {step = "knock", count = 2, x = self.ox + mu.cabinetX}) -- 2305
			self:flashSet("回柜边 · 第二下", 0.8) -- 2306
		elseif self.phaseTick >= 36 then -- 2306
			self.phase = "museum-done" -- 2308
			self.phaseTick = 0 -- 2309
			self.archive.museumSeen = true -- 2310
			self.archive.museumPhase = "done" -- 2311
			self.archiveDirty = true -- 2312
			self:emit("museumDone", {steps = 4, museumSeen = true}) -- 2313
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2314
			self:log("博物馆 · 回柜边") -- 2315
		end -- 2315
		return -- 2317
	end -- 2317
	if input.interact.pressed then -- 2317
		self.museumReturn = true -- 2320
		self:requestRoom("prologue", "回柜边") -- 2321
	end -- 2321
end -- 2254
function Play.prototype.stepTower(self, dt, input) -- 2325
	local ____temp_38 -- 2326
	if self.room.story == nil then -- 2326
		____temp_38 = nil -- 2326
	else -- 2326
		____temp_38 = self.room.story.tower -- 2326
	end -- 2326
	local t = ____temp_38 -- 2326
	if t == nil then -- 2326
		return -- 2328
	end -- 2328
	if self.phase == "tower-wait" then -- 2328
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2331
		if near and input.interact.pressed then -- 2331
			self.phase = "tower-knock" -- 2333
			self.phaseTick = 0 -- 2334
			self.knocks = 1 -- 2335
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2336
			self:flashSet("敲一下", 0.6) -- 2337
		end -- 2337
		return -- 2339
	end -- 2339
	if self.phase == "tower-knock" then -- 2339
		self.phaseTick = self.phaseTick + 1 -- 2342
		if self.phaseTick == 12 then -- 2342
			self.knocks = 2 -- 2344
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2345
			self:flashSet("敲两下 · 第二声", 1) -- 2346
		elseif self.phaseTick >= t.knockTicks then -- 2346
			self.phase = "tower-given" -- 2348
			self.phaseTick = 0 -- 2349
			self:flashSet("门开了 · 提灯", 1.4) -- 2350
		end -- 2350
		return -- 2352
	end -- 2352
	if self.phase == "tower-given" then -- 2352
		local soldier = self.storyRoute == "soldier" -- 2357
		self.phaseTick = self.phaseTick + 1 -- 2358
		if self.phaseTick == 60 then -- 2358
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 2360
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 2361
		elseif self.phaseTick == 120 then -- 2361
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 2363
		elseif self.phaseTick >= 180 then -- 2363
			self.phase = "tower-end" -- 2365
			self.phaseTick = 0 -- 2366
			if not self.run.finished then -- 2366
				self.run.finished = true -- 2368
				local ending = soldier and "reunion" or "lamp" -- 2369
				self.run.story.ending = ending -- 2370
				local ____soldier_39 -- 2373
				if soldier then -- 2373
					____soldier_39 = self.run.story.segments.escort5 == true -- 2374
				else -- 2374
					____soldier_39 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 2375
				end -- 2375
				local played = ____soldier_39 -- 2373
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 2376
				if official then -- 2376
					if soldier then -- 2376
						self.run.archive.soldierCleared = true -- 2380
					else -- 2380
						self.run.archive.childCleared = true -- 2382
					end -- 2382
					self.archiveDirty = true -- 2384
				end -- 2384
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 2386
				self:emit("endingReached", { -- 2387
					route = soldier and "soldier" or "child", -- 2388
					ending = ending, -- 2389
					official = official, -- 2390
					source = self.run.source, -- 2391
					lines = {self.endingLines[1], self.endingLines[2]}, -- 2392
					childCleared = self.run.archive.childCleared, -- 2393
					soldierCleared = self.run.archive.soldierCleared, -- 2394
					artifactOwned = self.run.archive.artifactOwned, -- 2395
					equipped = self.equippedWeapon -- 2396
				}) -- 2396
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 2398
			end -- 2398
		end -- 2398
		return -- 2401
	end -- 2401
	if input.interact.pressed or input.retry.pressed then -- 2401
		self.restartStory = true -- 2405
		self:requestRoom("prologue", "片尾再玩") -- 2406
		self:flashSet("回到序章", 1.4) -- 2407
	end -- 2407
end -- 2325
function Play.prototype.stepChase(self, dt, input) -- 2412
	if self.caughtT > 0 then -- 2412
		self.caughtT = self.caughtT - dt -- 2414
		if self.caughtT <= 0 then -- 2414
			self:recoverFromCaught() -- 2416
		end -- 2416
		return -- 2418
	end -- 2418
	if self.room.key == "village" then -- 2418
		self:stepScavChase() -- 2421
	elseif self.room.key == "forest" then -- 2421
		self:stepDog(dt) -- 2423
		if self.player.x >= self.ox + 1450 then -- 2423
			self:requestRoom("tower", "到林缘北塔") -- 2426
			self:flashSet("林缘 · 北塔", 1.4) -- 2427
		end -- 2427
	end -- 2427
end -- 2412
function Play.prototype.stepScavChase(self) -- 2433
	local s = self.room.scavenger -- 2434
	if s == nil then -- 2434
		return -- 2436
	end -- 2436
	local p = self.player -- 2438
	if self.passed and p.x > self.ox + 440 then -- 2438
		if self.scavChase then -- 2438
			self.scavChase = false -- 2442
			self.scavState = "back" -- 2443
			self.scavT = 0 -- 2444
		end -- 2444
		return -- 2446
	end -- 2446
	local dx = p.x - self.scavX -- 2448
	local dist = math.abs(dx) -- 2449
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 2450
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 2451
	if not self.scavChase then -- 2451
		if visible then -- 2451
			self.scavSee = self.scavSee + 1 -- 2454
			if self.scavSee >= 24 then -- 2454
				self.scavChase = true -- 2456
				self.scavState = "chase" -- 2457
				self.scavTargetX = p.x -- 2458
				self:flashSet("他看见你了", 1.2) -- 2459
			end -- 2459
		else -- 2459
			self.scavSee = 0 -- 2462
		end -- 2462
		return -- 2464
	end -- 2464
	local dir = p.x > self.scavX and 1 or -1 -- 2467
	self.scavX = self.scavX + dir * 96 / 60 -- 2468
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 2468
		self:caught() -- 2470
		return -- 2471
	end -- 2471
	if hidden then -- 2471
		self.scavSee = 0 -- 2475
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 2476
		self.scavT = self.scavT - 1 -- 2477
		if self.scavT <= 0 then -- 2477
			self.scavChase = false -- 2479
			self.scavState = "patrol" -- 2480
			self:flashSet("他失去了目标", 1) -- 2481
		end -- 2481
	end -- 2481
end -- 2433
function Play.prototype.stepDog(self, dt) -- 2487
	local ____temp_40 -- 2488
	if self.room.story == nil then -- 2488
		____temp_40 = nil -- 2488
	else -- 2488
		____temp_40 = self.room.story.dog -- 2488
	end -- 2488
	local dog = ____temp_40 -- 2488
	if dog == nil then -- 2488
		return -- 2490
	end -- 2490
	local p = self.player -- 2492
	local dist = math.abs(p.x - self.dogX) -- 2493
	if self.dogState == "patrol" then -- 2493
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 2495
		if self.dogX < dog.x0 then -- 2495
			self.dogX = dog.x0 -- 2497
			self.dogDir = 1 -- 2498
		elseif self.dogX > dog.x1 then -- 2498
			self.dogX = dog.x1 -- 2500
			self.dogDir = -1 -- 2501
		end -- 2501
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 2503
		if not p.crouch and moving and dist < dog.range then -- 2503
			self.dogState = "ear" -- 2505
			self.dogT = 18 -- 2506
			self.dogTargetX = p.x -- 2507
			self:flashSet("狗转耳朵", 0.8) -- 2508
		end -- 2508
		return -- 2510
	end -- 2510
	if self.dogState == "ear" then -- 2510
		self.dogT = self.dogT - 1 -- 2513
		if self.dogT <= 0 then -- 2513
			self.dogState = "chase" -- 2515
			self.dogTargetX = p.x -- 2516
			self:flashSet("狗追来了", 1.4) -- 2517
		end -- 2517
		return -- 2519
	end -- 2519
	if self.dogState == "chase" then -- 2519
		local dir = p.x > self.dogX and 1 or -1 -- 2522
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 2523
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 2523
			self:caught() -- 2525
			self.dogState = "sniff" -- 2526
			self.dogT = 60 -- 2527
		elseif dist > dog.range * 1.5 or p.crouch then -- 2527
			self.dogState = "sniff" -- 2529
			self.dogT = 60 -- 2530
			self:flashSet("狗停下了", 0.9) -- 2531
		end -- 2531
		return -- 2533
	end -- 2533
	if self.dogState == "sniff" then -- 2533
		self.dogT = self.dogT - 1 -- 2536
		if self.dogT <= 0 then -- 2536
			self.dogState = "back" -- 2538
		end -- 2538
		return -- 2540
	end -- 2540
	local dir = dog.x0 > self.dogX and 1 or -1 -- 2543
	self.dogX = self.dogX + dir * dog.speed * dt -- 2544
	if math.abs(self.dogX - dog.x0) < 2 then -- 2544
		self.dogX = dog.x0 -- 2546
		self.dogState = "patrol" -- 2547
	end -- 2547
end -- 2487
function Play.prototype.caught(self) -- 2551
	self.caughtT = 1 -- 2552
	self:flashSet("被抓 · 回到安全点", 1.6) -- 2553
end -- 2551
function Play.prototype.recoverFromCaught(self) -- 2557
	local p = self.player -- 2558
	p.x = self.ox + 140 -- 2559
	p.y = 0 -- 2560
	p.vy = 0 -- 2561
	p.vx = 0 -- 2562
	p.onGround = true -- 2563
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 2563
		self.scavX = self.room.scavenger.x0 -- 2565
		self.scavState = "patrol" -- 2566
		self.scavSee = 0 -- 2567
		self.scavChase = false -- 2568
		self.scavT = 0 -- 2569
	end -- 2569
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 2569
		self.dogX = self.room.story.dog.x0 -- 2572
		self.dogState = "patrol" -- 2573
		self.dogT = 0 -- 2574
	end -- 2574
	self.cam.x = p.x -- 2576
	self.cam.y = p.y + CAM_LOOK_UP -- 2577
	self:flashSet("回到安全点", 1.2) -- 2578
end -- 2557
function Play.prototype.updateGate(self) -- 2582
	if self.room.key ~= "checkpoint" then -- 2582
		self.gateOpen = false -- 2584
		return -- 2585
	end -- 2585
	local function inZone(x) -- 2587
		return x >= self.ox + 792 and x <= self.ox + 928 -- 2587
	end -- 2587
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 2588
end -- 2582
function Play.prototype.addItem(self, kind) -- 2594
	local inv = self.run.inventory -- 2595
	if kind == "shield" then -- 2595
		if inv.shield >= TOOL_CAP then -- 2595
			return false -- 2598
		end -- 2598
		inv.shield = inv.shield + 1 -- 2600
		return true -- 2601
	end -- 2601
	if kind == "wedge" then -- 2601
		if inv.wedge >= CONSUMABLE_CAP then -- 2601
			return false -- 2605
		end -- 2605
		inv.wedge = inv.wedge + 1 -- 2607
		return true -- 2608
	end -- 2608
	if kind == "ammo" then -- 2608
		if inv.ammo >= CONSUMABLE_CAP then -- 2608
			return false -- 2612
		end -- 2612
		inv.ammo = inv.ammo + 1 -- 2614
		return true -- 2615
	end -- 2615
	if kind == "scrap" then -- 2615
		inv.scrap = inv.scrap + 1 -- 2619
		return true -- 2620
	end -- 2620
	if kind == "wood" then -- 2620
		inv.wood = inv.wood + 1 -- 2623
		return true -- 2624
	end -- 2624
	if kind == "bell" then -- 2624
		inv.bell = inv.bell + 1 -- 2627
		return true -- 2628
	end -- 2628
	if kind == "pass" then -- 2628
		inv.pass = inv.pass + 1 -- 2631
		return true -- 2632
	end -- 2632
	if kind == "quickbelt" then -- 2632
		inv.quickbelt = inv.quickbelt + 1 -- 2635
		return true -- 2636
	end -- 2636
	return false -- 2638
end -- 2594
function Play.prototype.findBox(self, id) -- 2641
	local i = 0 -- 2642
	do -- 2642
		i = 0 -- 2643
		while i < #self.boxes do -- 2643
			if self.boxes[i + 1].id == id then -- 2643
				return self.boxes[i + 1] -- 2645
			end -- 2645
			i = i + 1 -- 2643
		end -- 2643
	end -- 2643
	return nil -- 2648
end -- 2641
function Play.prototype.findWedgeTarget(self) -- 2652
	local best = nil -- 2653
	local bestD = 0 -- 2654
	local i = 0 -- 2655
	do -- 2655
		i = 0 -- 2656
		while i < #self.boxes do -- 2656
			do -- 2656
				local b = self.boxes[i + 1] -- 2657
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 2657
					goto __continue396 -- 2659
				end -- 2659
				if not self:nearBox(b, 26) then -- 2659
					goto __continue396 -- 2662
				end -- 2662
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 2664
				if best == nil or d < bestD then -- 2664
					best = b -- 2666
					bestD = d -- 2667
				end -- 2667
			end -- 2667
			::__continue396:: -- 2667
			i = i + 1 -- 2656
		end -- 2656
	end -- 2656
	return best -- 2670
end -- 2652
function Play.prototype.stepCraft(self, input) -- 2678
	local inv = self.run.inventory -- 2679
	local ____opt_41 = self.run.trial -- 2679
	local required = CRAFT_TICKS - 6 * (____opt_41 and ____opt_41.ranks.craft or 0) -- 2680
	if self.craftT > 0 then -- 2680
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 2680
			self.craftT = 0 -- 2684
			self:flashSet("制作中断", 0.8) -- 2685
			return true -- 2686
		end -- 2686
		self.craftT = self.craftT + 1 -- 2688
		if self.craftT >= required then -- 2688
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 2688
				inv.scrap = inv.scrap - 1 -- 2691
				inv.wedge = inv.wedge + 1 -- 2692
				self:flashSet("制得木楔", 1.2) -- 2693
				self:log("制木楔") -- 2694
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 2695
			end -- 2695
			self.craftT = 0 -- 2697
		end -- 2697
		return true -- 2699
	end -- 2699
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 2699
		self.craftT = 1 -- 2702
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 2703
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 2704
		return true -- 2705
	end -- 2705
	return false -- 2707
end -- 2678
function Play.prototype.nearBox(self, b, reach) -- 2710
	local p = self.player -- 2711
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 2712
end -- 2710
function Play.prototype.findInteract(self) -- 2718
	local p = self.player -- 2719
	local best = nil -- 2720
	local bestD = 1000000000 -- 2721
	local i = 0 -- 2722
	do -- 2722
		i = 0 -- 2723
		while i < #self.boxes do -- 2723
			do -- 2723
				local b = self.boxes[i + 1] -- 2724
				if b.interact == nil or b.broken == true then -- 2724
					goto __continue409 -- 2726
				end -- 2726
				if not self:nearBox(b, b.interact.reach or 27) then -- 2726
					goto __continue409 -- 2729
				end -- 2729
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 2731
				if d < bestD then -- 2731
					bestD = d -- 2733
					best = b -- 2734
				end -- 2734
			end -- 2734
			::__continue409:: -- 2734
			i = i + 1 -- 2723
		end -- 2723
	end -- 2723
	return best -- 2737
end -- 2718
function Play.prototype.stepCampaign(self, dt, input) -- 2741
	local wr = self.room -- 2742
	local p = self.player -- 2743
	if self.reloadT > 0 then -- 2743
		self.reloadT = self.reloadT - 1 -- 2745
	end -- 2745
	if self.bracedShield ~= nil then -- 2745
		self.bracedShield.x = p.x + p.facing * 26 -- 2749
		self.bracedShield.y = p.y -- 2750
		local shBox = __TS__ArrayFind( -- 2751
			self.boxes, -- 2751
			function(____, b) return b.id == "braced_shield" end -- 2751
		) -- 2751
		if shBox ~= nil then -- 2751
			shBox.x0 = self.bracedShield.x - 15 -- 2753
			shBox.x1 = self.bracedShield.x + 15 -- 2754
			shBox.y0 = self.bracedShield.y -- 2755
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 2756
		end -- 2756
	end -- 2756
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 2756
		self.run.route = "drygoods" -- 2762
		self.run.joined = false -- 2763
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 2764
		self:log("转布行线") -- 2765
	end -- 2765
	if wr.key == "escort3" then -- 2765
		local benchX = wr.minX + 560 -- 2769
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 60 -- 2770
		if self.craftBench.active then -- 2770
			if input.interact.pressed or input.pause.pressed then -- 2770
				self:closeCraftBench() -- 2773
			end -- 2773
		elseif nearBench and input.interact.pressed then -- 2773
			self:openCraftBench() -- 2776
		end -- 2776
	end -- 2776
	local i = 0 -- 2780
	do -- 2780
		i = 0 -- 2781
		while i < #self.pickups do -- 2781
			do -- 2781
				local pk = self.pickups[i + 1] -- 2782
				if pk.id == "" or self.run.taken[pk.id] == true then -- 2782
					goto __continue424 -- 2784
				end -- 2784
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 2786
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 2787
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 2787
					if not self:addItem(pk.kind) then -- 2787
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 2791
						self:log("满包拒绝 " .. pk.kind) -- 2792
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 2793
						goto __continue424 -- 2794
					end -- 2794
					self.run.taken[pk.id] = true -- 2796
					pk.id = "" -- 2797
					self:flashSet("拾取 " .. pk.label, 1) -- 2798
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 2799
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 2800
				end -- 2800
			end -- 2800
			::__continue424:: -- 2800
			i = i + 1 -- 2781
		end -- 2781
	end -- 2781
	if not self:stepCraft(input) and input.interact.pressed then -- 2781
		self:campaignInteract() -- 2804
	end -- 2804
	self:stepCampaignCart(dt, input) -- 2806
	self:stepCampaignGoal() -- 2807
	self:campaignCheckpoint() -- 2808
end -- 2741
function Play.prototype.campaignCheckpoint(self) -- 2812
	local i = 0 -- 2813
	do -- 2813
		i = 0 -- 2814
		while i < #self.room.marks do -- 2814
			do -- 2814
				local m = self.room.marks[i + 1] -- 2815
				if m.kind ~= 0 then -- 2815
					goto __continue431 -- 2817
				end -- 2817
				local dx = self.player.x - m.x -- 2819
				local dy = self.player.y - m.y -- 2820
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2820
					self.checkpoint = m.x -- 2822
					self:captureCheckpoint(m.x) -- 2823
					self:flashSet("检查点", 1) -- 2824
				end -- 2824
			end -- 2824
			::__continue431:: -- 2824
			i = i + 1 -- 2814
		end -- 2814
	end -- 2814
end -- 2812
function Play.prototype.campaignInteract(self) -- 2830
	local b = self:findInteract() -- 2831
	if b ~= nil then -- 2831
		self:useInteract(b) -- 2833
		return -- 2834
	end -- 2834
	local inv = self.run.inventory -- 2836
	if inv.wedge > 0 then -- 2836
		local w = self:findWedgeTarget() -- 2838
		if w ~= nil then -- 2838
			if w.breakable ~= nil then -- 2838
				local ____w_breakable_43, ____hp_44 = w.breakable, "hp" -- 2838
				____w_breakable_43[____hp_44] = ____w_breakable_43[____hp_44] + (w.breakable.wedgeHp or 1) -- 2841
			end -- 2841
			inv.wedge = inv.wedge - 1 -- 2843
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 2844
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 2846
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 2847
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 2848
			return -- 2849
		end -- 2849
	end -- 2849
	if inv.ammo > 0 and self.reloadT > 0 then -- 2849
		self.reloadT = 0 -- 2854
		self:closeReloadPuzzle() -- 2855
		inv.ammo = inv.ammo - 1 -- 2856
		self:flashSet("备用弹包 · 膛内补满", 1) -- 2857
		self:log("用备用弹包") -- 2858
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 2859
		return -- 2860
	end -- 2860
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 2860
		local p = self.player -- 2864
		self.bracedShield = { -- 2865
			x = p.x + p.facing * 26, -- 2865
			y = p.y, -- 2865
			w = 30, -- 2865
			h = 64, -- 2865
			hp = 1 -- 2865
		} -- 2865
		local ____self_boxes_45 = self.boxes -- 2865
		____self_boxes_45[#____self_boxes_45 + 1] = { -- 2866
			x0 = self.bracedShield.x - 15, -- 2867
			x1 = self.bracedShield.x + 15, -- 2867
			y0 = p.y, -- 2868
			y1 = p.y + 64, -- 2868
			depth = {min = -46, max = 46}, -- 2868
			label = "架起的残盾", -- 2868
			id = "braced_shield", -- 2868
			soft = true -- 2869
		} -- 2869
		inv.shield = inv.shield - 1 -- 2872
		self:flashSet("架残盾 · 挡一发", 1.2) -- 2873
		self:log("架残盾") -- 2874
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 2875
		return -- 2876
	end -- 2876
	if inv.pass > 0 and self.run.joined == false then -- 2876
		inv.pass = inv.pass - 1 -- 2879
		self.run.joined = true -- 2880
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 2881
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 2882
		return -- 2883
	end -- 2883
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 2885
end -- 2830
function Play.prototype.useInteract(self, b) -- 2888
	local kind = b.interact == nil and "" or b.interact.kind -- 2889
	local wr = self.room -- 2890
	if kind == "open_board" then -- 2890
		b.broken = true -- 2892
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 2893
		for ____, cover in ipairs(self.boxes) do -- 2894
			if cover.id == "s2_board_cover" then -- 2894
				cover.broken = false -- 2896
				cover.hidden = false -- 2897
			end -- 2897
		end -- 2897
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 2900
		self.run.joined = true -- 2901
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 2902
		self:log("放下窗板") -- 2903
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 2904
		return -- 2905
	end -- 2905
	if kind == "lower_curtain" then -- 2905
		for ____, curtain in ipairs(self.boxes) do -- 2908
			if curtain.id == "c2_curtain" then -- 2908
				curtain.broken = false -- 2910
				curtain.hidden = false -- 2911
			end -- 2911
		end -- 2911
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 2914
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 2915
		self:log("放下木帘") -- 2916
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 2917
		return -- 2918
	end -- 2918
	if kind == "raise_latch" then -- 2918
		if wr.key == "c2-granary" and not self.cartDocked then -- 2918
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 2922
			return -- 2923
		end -- 2923
		b.broken = true -- 2925
		self.objectiveDone = true -- 2926
		if wr.key == "c1-yard" then -- 2926
			self.run.c1Latch = true -- 2929
			self.run.joined = true -- 2930
		else -- 2930
			self.run.c2Latch = true -- 2932
			self.run.joined = true -- 2933
		end -- 2933
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 2935
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 2936
		self:log("抬闩") -- 2937
		self:flashSet("抬闩 · 通路打开", 1.4) -- 2938
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 2939
	end -- 2939
end -- 2888
function Play.prototype.stepCampaignCart(self, dt, input) -- 2944
	local wr = self.room -- 2945
	local c = wr.cart -- 2946
	if c.bodyW <= 0 then -- 2946
		return -- 2948
	end -- 2948
	local p = self.player -- 2950
	local handleX = self.cartAxle + c.handleOffset -- 2951
	if not self.gripping then -- 2951
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 2951
			self.gripping = true -- 2955
			self:flashSet("握住车柄 · A/D 推", 1) -- 2956
		end -- 2956
		return -- 2958
	end -- 2958
	if input.interact.pressed then -- 2958
		self.gripping = false -- 2961
		self:flashSet("松手", 0.5) -- 2962
		return -- 2963
	end -- 2963
	if not self.cartDocked then -- 2963
		if input.moveX ~= 0 and not self:stuckCart() then -- 2963
			self.cartAxle = math.max( -- 2967
				c.startX, -- 2967
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 2967
			) -- 2967
		end -- 2967
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 2967
			self.cartExposed = true -- 2972
			local gun = nil -- 2973
			local gi = 0 -- 2974
			do -- 2974
				gi = 0 -- 2975
				while gi < #self.enemies do -- 2975
					local e = self.enemies[gi + 1] -- 2976
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 2976
						gun = e -- 2978
						break -- 2979
					end -- 2979
					gi = gi + 1 -- 2975
				end -- 2975
			end -- 2975
			if gun ~= nil then -- 2975
				self:campaignEnemyFire(gun) -- 2983
			end -- 2983
		end -- 2983
		p.x = self.cartAxle + c.handleOffset -- 2986
		p.y = c.baseY + (c.depth or 0) -- 2987
		p.vx = 0 -- 2988
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 2988
			self.cartAxle = c.endX -- 2990
			self.cartDocked = true -- 2991
			self.gripping = false -- 2992
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 2993
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 2994
			self:flashSet("车轮入窝", 1.2) -- 2995
			self:log("车轮入窝") -- 2996
		end -- 2996
	end -- 2996
end -- 2944
function Play.prototype.stuckCart(self) -- 3002
	local i = 0 -- 3003
	do -- 3003
		i = 0 -- 3004
		while i < #self.boxes do -- 3004
			do -- 3004
				local b = self.boxes[i + 1] -- 3005
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3005
					goto __continue470 -- 3007
				end -- 3007
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 3009
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3009
					return true -- 3011
				end -- 3011
			end -- 3011
			::__continue470:: -- 3011
			i = i + 1 -- 3004
		end -- 3004
	end -- 3004
	return false -- 3014
end -- 3002
function Play.prototype.stepCampaignGoal(self) -- 3018
	local wr = self.room -- 3019
	local c = wr.campaign -- 3020
	if c == nil then -- 3020
		return -- 3022
	end -- 3022
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3022
		self.objectiveDone = true -- 3025
	end -- 3025
	if c.goal == "reach_exit" then -- 3025
		self.objectiveDone = true -- 3028
	end -- 3028
	if not self.objectiveDone then -- 3028
		return -- 3031
	end -- 3031
	local p = self.player -- 3033
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3034
	if p.x < c.exitX or not partnerOk then -- 3034
		return -- 3036
	end -- 3036
	if self.run.story.segments[wr.key] ~= true then -- 3036
		self.run.story.segments[wr.key] = true -- 3040
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3041
	end -- 3041
	if wr.key == "escort5" then -- 3041
		self.escortDone = true -- 3045
		self.run.story.escortDone = true -- 3046
	end -- 3046
	if c.next ~= nil and c.next ~= "" then -- 3046
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3049
		self:flashSet("过关 · " .. c.next, 1.2) -- 3050
	elseif not self.run.finished then -- 3050
		self.run.finished = true -- 3052
		self:flashSet( -- 3053
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3053
			2 -- 3053
		) -- 3053
		self:log("C2 灰盒完成") -- 3054
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3055
	end -- 3055
end -- 3018
function Play.prototype.stepCampaignPartner(self, dt) -- 3060
	local a = self.partner -- 3061
	local wr = self.room -- 3062
	local cp = wr.companion -- 3063
	if not a.alive then -- 3063
		return -- 3065
	end -- 3065
	local p = self.player -- 3067
	if self.craftBench.active then -- 3067
		a.vx = 0 -- 3070
		return -- 3071
	end -- 3071
	local wait = false -- 3073
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3074
	local targetDepth = p.depth -- 3075
	if self.run.joined == false then -- 3075
		wait = true -- 3077
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3078
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3079
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3079
		wait = true -- 3081
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3082
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3083
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3083
		wait = true -- 3085
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3086
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3087
	end -- 3087
	if self.partnerStuck > 0.3 then -- 3087
		a.x = a.x + a.facing * 44 -- 3091
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3092
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3093
		self.partnerLaneHold = 1.1 -- 3094
		self.partnerStuck = 0 -- 3095
	end -- 3095
	if self.partnerLaneHold > 0 then -- 3095
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3098
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3099
	end -- 3099
	local dx = targetX - a.x -- 3101
	if not wait and math.abs(dx) > 74 then -- 3101
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3103
		local before = a.x -- 3104
		a.vx = dx > 0 and speed or -speed -- 3105
		a.facing = dx > 0 and 1 or -1 -- 3106
		self:slideX(a, a.vx * dt) -- 3107
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3107
			a.vy = CHILD_JUMP -- 3110
			a.onGround = false -- 3111
		end -- 3111
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3113
	else -- 3113
		a.vx = 0 -- 3115
		self.partnerStuck = 0 -- 3116
	end -- 3116
	local dz = targetDepth - a.depth -- 3118
	if math.abs(dz) > 6 then -- 3118
		local step = math.max( -- 3120
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3120
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3120
		) -- 3120
		a.depth = a.depth + step -- 3121
	end -- 3121
	a.depthSpeed = 0 -- 3123
	a.h = CHILD_H -- 3124
	a.crouch = false -- 3125
	self:fallY(a, dt) -- 3126
end -- 3060
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3130
	local p = self.player -- 3131
	local i = 0 -- 3132
	do -- 3132
		i = 0 -- 3133
		while i < #self.enemies do -- 3133
			do -- 3133
				local ____opt_46 = self.run.trial -- 3133
				if ____opt_46 and ____opt_46.lost then -- 3133
					return -- 3134
				end -- 3134
				local e = self.enemies[i + 1] -- 3135
				if not e.alive then -- 3135
					goto __continue497 -- 3137
				end -- 3137
				if e.hitT > 0 then -- 3137
					e.hitT = e.hitT - dt -- 3140
				end -- 3140
				if e.kind == "target" then -- 3140
					if not e.alive and e.hitT <= 0 then -- 3140
						e.alive = true -- 3145
					end -- 3145
					goto __continue497 -- 3147
				end -- 3147
				if e.kind == "breaker" then -- 3147
					self:stepBreaker(e, dt) -- 3150
					goto __continue497 -- 3151
				end -- 3151
				if e.kind == "shield" then -- 3151
					self:stepShield(e, dt, input) -- 3154
					goto __continue497 -- 3155
				end -- 3155
				local dx = e.x - p.x -- 3158
				if not e.awake then -- 3158
					if math.abs(dx) > 520 then -- 3158
						goto __continue497 -- 3161
					end -- 3161
					e.awake = true -- 3163
					e.fireCd = 48 -- 3164
					goto __continue497 -- 3165
				end -- 3165
				if math.abs(dx) > ENEMY_RANGE then -- 3165
					goto __continue497 -- 3168
				end -- 3168
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 3168
					goto __continue497 -- 3173
				end -- 3173
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 3173
					goto __continue497 -- 3176
				end -- 3176
				if self:blockedShot(e, p) then -- 3176
					if e.warnT > 0 then -- 3176
						e.warnT = 0 -- 3182
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3183
					end -- 3183
					goto __continue497 -- 3185
				end -- 3185
				if e.warnT > 0 then -- 3185
					e.warnT = e.warnT - 1 -- 3188
					if e.warnT <= 0 then -- 3188
						self:campaignEnemyFire(e) -- 3190
					end -- 3190
				elseif e.fireCd > 0 then -- 3190
					e.fireCd = e.fireCd - 1 -- 3193
					if e.fireCd <= 0 then -- 3193
						e.warnT = WARN_TICKS -- 3195
					end -- 3195
				else -- 3195
					e.fireCd = 40 -- 3198
				end -- 3198
			end -- 3198
			::__continue497:: -- 3198
			i = i + 1 -- 3133
		end -- 3133
	end -- 3133
end -- 3130
function Play.prototype.blockedShot(self, e, p) -- 3204
	local eDepth = e.depth or 0 -- 3205
	local ex = e.x -- 3206
	local ey = e.y + e.h * 0.62 -- 3208
	local px = p.x -- 3209
	local py = p.y + p.h * 0.55 -- 3210
	local dx = px - ex -- 3211
	local dyScreen = py + p.depth - (ey + eDepth) -- 3212
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3213
	if len < 0.01 then -- 3213
		return false -- 3215
	end -- 3215
	local ray = { -- 3219
		x = ex, -- 3220
		y = ey, -- 3220
		dx = dx / len, -- 3221
		dy = (py - ey) / len, -- 3221
		depth = eDepth, -- 3222
		dDepth = (p.depth - eDepth) / len -- 3222
	} -- 3222
	local best = -1 -- 3224
	local j = 0 -- 3225
	do -- 3225
		j = 0 -- 3226
		while j < #self.boxes do -- 3226
			do -- 3226
				local b = self.boxes[j + 1] -- 3227
				if b.broken == true or b.passable == true or b.hidden == true then -- 3227
					goto __continue520 -- 3229
				end -- 3229
				if b.id == "braced_shield" then -- 3229
					goto __continue520 -- 3234
				end -- 3234
				local t = hitBox(ray, b) -- 3236
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3236
					best = t -- 3240
				end -- 3240
			end -- 3240
			::__continue520:: -- 3240
			j = j + 1 -- 3226
		end -- 3226
	end -- 3226
	return best >= 0 -- 3243
end -- 3204
function Play.prototype.campaignEnemyFire(self, e) -- 3246
	local p = self.player -- 3247
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3248
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3248
		local ____self_bracedShield_48, ____hp_49 = self.bracedShield, "hp" -- 3248
		____self_bracedShield_48[____hp_49] = ____self_bracedShield_48[____hp_49] - 1 -- 3250
		self.boxes = __TS__ArrayFilter( -- 3251
			self.boxes, -- 3251
			function(____, b) return b.id ~= "braced_shield" end -- 3251
		) -- 3251
		self.bracedShield = nil -- 3252
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3253
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3254
		return -- 3255
	end -- 3255
	if self:blockedShot(e, p) then -- 3255
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3258
		return -- 3259
	end -- 3259
	local cover = self:blockedByCover(e, p) -- 3261
	if cover ~= nil and self.coverHug then -- 3261
		self.coveredFlash = 0.5 -- 3263
		self:flashSet("掩体挡下", 0.6) -- 3264
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3265
		return -- 3270
	end -- 3270
	if self.invulnT > 0 then -- 3270
		return -- 3273
	end -- 3273
	local ____opt_50 = self.run.trial -- 3273
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_50 and ____opt_50.ranks.guard or 0) -- 3275
	self.craftT = 0 -- 3276
	self.hp = self.hp - 1 -- 3277
	self:emit("actorHit", { -- 3278
		target = "player", -- 3278
		amount = 1, -- 3278
		hp = self.hp, -- 3278
		maxHp = self.maxHp, -- 3278
		enemyX = e.x -- 3278
	}) -- 3278
	self:flashSet( -- 3279
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3279
		0.8 -- 3279
	) -- 3279
	if self.hp <= 0 then -- 3279
		self:campaignFailed() -- 3281
	end -- 3281
end -- 3246
function Play.prototype.stepShield(self, e, dt, input) -- 3286
	local p = self.player -- 3287
	local dx = p.x - e.x -- 3288
	local adx = math.abs(dx) -- 3289
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 3292
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 3293
	if adx > 150 then -- 3293
		local before = e.x -- 3295
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 3296
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 3296
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3299
		end -- 3299
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 3299
		local fromFront = (e.x - p.x) * p.facing > 0 -- 3304
		local rollDodges = p.rollT > 0 and fromFront -- 3305
		if not rollDodges and self.invulnT <= 0 then -- 3305
			local ____opt_52 = self.run.trial -- 3305
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_52 and ____opt_52.ranks.guard or 0) -- 3307
			self.craftT = 0 -- 3308
			self.hp = self.hp - 1 -- 3309
			self:emit("actorHit", { -- 3310
				target = "player", -- 3310
				amount = 1, -- 3310
				hp = self.hp, -- 3310
				maxHp = self.maxHp, -- 3310
				enemyX = e.x -- 3310
			}) -- 3310
			self:flashSet( -- 3311
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3311
				0.8 -- 3311
			) -- 3311
			if self.hp <= 0 then -- 3311
				self:campaignFailed() -- 3313
				return -- 3314
			end -- 3314
		end -- 3314
		e.swingT = 70 -- 3317
	end -- 3317
	if (e.swingT or 0) > 0 then -- 3317
		e.swingT = (e.swingT or 0) - 1 -- 3320
	end -- 3320
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 3320
		local dd = p.depth - (e.depth or 0) -- 3323
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 3324
	end -- 3324
end -- 3286
function Play.prototype.stepBreaker(self, e, dt) -- 3329
	local p = self.player -- 3330
	if e.awake ~= true then -- 3330
		if math.abs(p.x - e.x) < 560 then -- 3330
			e.awake = true -- 3333
		else -- 3333
			return -- 3335
		end -- 3335
	end -- 3335
	local target = nil -- 3338
	local bestD = 1000000000 -- 3339
	local i = 0 -- 3340
	do -- 3340
		i = 0 -- 3341
		while i < #self.boxes do -- 3341
			do -- 3341
				local b = self.boxes[i + 1] -- 3342
				if b.breakable == nil or b.broken == true then -- 3342
					goto __continue544 -- 3344
				end -- 3344
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 3346
				if d < bestD then -- 3346
					bestD = d -- 3348
					target = b -- 3349
				end -- 3349
			end -- 3349
			::__continue544:: -- 3349
			i = i + 1 -- 3341
		end -- 3341
	end -- 3341
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 3352
	local dx = tx - e.x -- 3353
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 3354
	if math.abs(dx) > reach then -- 3354
		local before = e.x -- 3356
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 3357
		if math.abs(e.x - before) < 0.3 then -- 3357
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3359
		end -- 3359
	elseif (e.swingT or 0) <= 0 then -- 3359
		e.swingT = 64 -- 3362
		if target ~= nil then -- 3362
			self:damageProp(target, 2) -- 3364
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 3364
			local ____opt_54 = self.run.trial -- 3364
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_54 and ____opt_54.ranks.guard or 0) -- 3366
			self.craftT = 0 -- 3367
			self.hp = self.hp - 1 -- 3368
			self:emit("actorHit", { -- 3369
				target = "player", -- 3369
				amount = 1, -- 3369
				hp = self.hp, -- 3369
				maxHp = self.maxHp, -- 3369
				enemyX = e.x -- 3369
			}) -- 3369
			self:flashSet("破障手近身", 0.8) -- 3370
			if self.hp <= 0 then -- 3370
				self:campaignFailed() -- 3372
				return -- 3373
			end -- 3373
		end -- 3373
	end -- 3373
	if (e.swingT or 0) > 0 then -- 3373
		e.swingT = (e.swingT or 0) - 1 -- 3378
	end -- 3378
end -- 3329
function Play.prototype.campaignFailed(self) -- 3382
	if self.run.trial ~= nil then -- 3382
		self.run.trial.lost = true -- 3384
		self.wantRoom = "" -- 3385
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3386
		return -- 3387
	end -- 3387
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 3387
		self:restartEscortFromDeath() -- 3392
		return -- 3393
	end -- 3393
	local p = self.player -- 3395
	self.hp = self.maxHp -- 3396
	self.invulnT = INVULN_RESPAWN_TICKS -- 3397
	self.reloadT = 0 -- 3398
	self:closeReloadPuzzle() -- 3399
	self.gripping = false -- 3400
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 3401
	self:log("被击倒") -- 3402
	p.x = self.room.minX + 90 -- 3403
	p.y = 0 -- 3404
	p.depth = 0 -- 3405
	p.vx = 0 -- 3406
	p.vy = 0 -- 3407
	p.onGround = true -- 3408
	p.rollT = 0 -- 3409
	self.partner.x = p.x - 50 -- 3410
	self.partner.y = 0 -- 3411
	self.partner.depth = 0 -- 3412
	self.cam.x = p.x -- 3413
	local i = 0 -- 3414
	do -- 3414
		i = 0 -- 3415
		while i < #self.enemies do -- 3415
			do -- 3415
				local e = self.enemies[i + 1] -- 3416
				if not e.alive then -- 3416
					goto __continue558 -- 3418
				end -- 3418
				e.x = e.homeX == nil and e.x or e.homeX -- 3420
				e.warnT = 0 -- 3421
				e.fireCd = 40 -- 3422
				e.swingT = 0 -- 3423
				e.awake = false -- 3424
			end -- 3424
			::__continue558:: -- 3424
			i = i + 1 -- 3415
		end -- 3415
	end -- 3415
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3426
end -- 3382
function Play.prototype.isEscortRoom(self) -- 3430
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 3431
end -- 3430
function Play.prototype.restartEscortFromDeath(self) -- 3439
	local story = self.run.story -- 3440
	local inv = self.run.inventory -- 3441
	self.hp = self.maxHp -- 3442
	story.hp = self.maxHp -- 3443
	story.cp = nil -- 3444
	self.checkpointSnap = nil -- 3445
	story.carry = false -- 3446
	self.carryOn = false -- 3447
	story.craftedWeapon = "" -- 3448
	self.equippedWeapon = "standard_gun" -- 3449
	story.escortDone = false -- 3450
	self.escortDone = false -- 3451
	story.segments = {} -- 3452
	inv.wood = 0 -- 3453
	inv.bell = 0 -- 3454
	inv.scrap = 0 -- 3455
	inv.wedge = 0 -- 3456
	inv.ammo = 0 -- 3457
	inv.quickbelt = 0 -- 3458
	inv.shield = 0 -- 3459
	inv.pass = 0 -- 3460
	local taken = self.run.taken -- 3461
	local keys = __TS__ObjectKeys(taken) -- 3462
	local i = 0 -- 3463
	do -- 3463
		i = 0 -- 3464
		while i < #keys do -- 3464
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 3464
				__TS__Delete(taken, keys[i + 1]) -- 3466
			end -- 3466
			i = i + 1 -- 3464
		end -- 3464
	end -- 3464
	self.run.joined = true -- 3469
	self.reloadT = 0 -- 3470
	self:closeReloadPuzzle() -- 3471
	self.gripping = false -- 3472
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 3473
	self:log("男主线失败 · 回 escort1") -- 3474
	self:emit("campaignFailed", { -- 3475
		room = self.room.key, -- 3476
		hp = 0, -- 3476
		maxHp = self.maxHp, -- 3476
		reset = true, -- 3477
		to = "escort1", -- 3477
		route = self.storyRoute -- 3477
	}) -- 3477
	self:requestRoom("escort1", "男主线失败重开") -- 3479
end -- 3439
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 3483
	local i = 0 -- 3484
	do -- 3484
		i = 0 -- 3485
		while i < #self.enemies do -- 3485
			do -- 3485
				if i == skipIndex then -- 3485
					goto __continue567 -- 3487
				end -- 3487
				local e = self.enemies[i + 1] -- 3489
				if not e.alive or math.abs(e.x - center.x) > radius then -- 3489
					goto __continue567 -- 3491
				end -- 3491
				e.fireCd = 150 -- 3493
				e.warnT = 0 -- 3494
			end -- 3494
			::__continue567:: -- 3494
			i = i + 1 -- 3485
		end -- 3485
	end -- 3485
end -- 3483
function Play.prototype.stepEnemies(self, dt, input) -- 3498
	local i = 0 -- 3499
	do -- 3499
		i = 0 -- 3500
		while i < #self.enemies do -- 3500
			local e = self.enemies[i + 1] -- 3501
			if e.hitT > 0 then -- 3501
				e.hitT = e.hitT - dt -- 3503
			end -- 3503
			i = i + 1 -- 3500
		end -- 3500
	end -- 3500
	if self.coveredFlash > 0 then -- 3500
		self.coveredFlash = self.coveredFlash - dt -- 3507
	end -- 3507
	if self.isCampaign then -- 3507
		self:stepCampaignEnemies(dt, input) -- 3510
		return -- 3511
	end -- 3511
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 3511
		return -- 3515
	end -- 3515
	do -- 3515
		i = 0 -- 3517
		while i < #self.enemies do -- 3517
			do -- 3517
				local e = self.enemies[i + 1] -- 3518
				if not e.alive then -- 3518
					goto __continue578 -- 3520
				end -- 3520
				if e.warnT > 0 then -- 3520
					e.warnT = e.warnT - 1 -- 3523
					if e.warnT <= 0 then -- 3523
						self:enemyFire(e, input) -- 3525
					end -- 3525
					goto __continue578 -- 3527
				end -- 3527
				if e.fireCd > 0 then -- 3527
					e.fireCd = e.fireCd - 1 -- 3530
					if e.fireCd <= 0 then -- 3530
						e.warnT = WARN_TICKS -- 3532
					end -- 3532
				else -- 3532
					e.warnT = WARN_TICKS -- 3536
				end -- 3536
			end -- 3536
			::__continue578:: -- 3536
			i = i + 1 -- 3517
		end -- 3517
	end -- 3517
end -- 3498
function Play.prototype.enemyFire(self, e, input) -- 3542
	local p = self.player -- 3543
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 3543
		self:flashSet("枪声响在远处", 0.4) -- 3545
		e.fireCd = FIRE_COOLDOWN -- 3546
		return -- 3547
	end -- 3547
	local cover = self:blockedByCover(e, p) -- 3550
	local hugging = cover ~= nil -- 3551
	self.coverBlocking = hugging -- 3552
	local covered = hugging and input.cover.held -- 3553
	if covered then -- 3553
		self.coveredFlash = 0.5 -- 3555
		self:flashSet("掩体挡下", 0.5) -- 3556
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3557
		e.fireCd = FIRE_COOLDOWN -- 3562
		return -- 3563
	end -- 3563
	self.hp = self.hp - 1 -- 3565
	self:emit("actorHit", { -- 3566
		target = "player", -- 3566
		amount = 1, -- 3566
		hp = self.hp, -- 3566
		maxHp = self.maxHp, -- 3566
		enemyX = e.x -- 3566
	}) -- 3566
	self:flashSet( -- 3567
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3567
		0.7 -- 3567
	) -- 3567
	e.fireCd = FIRE_COOLDOWN -- 3568
	if self.hp <= 0 then -- 3568
		self:gateFailed() -- 3570
	end -- 3570
end -- 3542
function Play.prototype.blockedByCover(self, enemy, p) -- 3575
	local b = self:coverAt(p) -- 3576
	if b == nil then -- 3576
		return nil -- 3578
	end -- 3578
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 3580
end -- 3575
function Play.prototype.gateFailed(self) -- 3584
	local ____temp_56 -- 3585
	if self.room.story == nil then -- 3585
		____temp_56 = nil -- 3585
	else -- 3585
		____temp_56 = self.room.story.gate -- 3585
	end -- 3585
	local g = ____temp_56 -- 3585
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 3586
	self.hp = self.maxHp -- 3587
	self.gateTick = 0 -- 3588
	self.gateSpawned = 0 -- 3589
	self.enemies = {} -- 3590
	self.gateFailCount = self.gateFailCount + 1 -- 3591
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 3593
	self.player.y = 0 -- 3594
	self.player.vy = 0 -- 3595
	self.player.depth = 0 -- 3596
	self.player.depthSpeed = 0 -- 3597
	self.player.onGround = true -- 3598
	self.player.crouch = false -- 3599
	self.player.h = SOLDIER_H -- 3600
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 3601
	self.partner.y = 0 -- 3602
	self.partner.vy = 0 -- 3603
	self.partner.depth = 0 -- 3604
	self.partner.depthSpeed = 0 -- 3605
	self.partner.onGround = true -- 3606
	self.cam.x = self.player.x -- 3607
	self.phase = "gate-idle" -- 3608
	self.phaseTick = 0 -- 3609
	self.coverHug = false -- 3610
	self.coverBlocking = false -- 3611
	self.coverEntity = "" -- 3612
	self.gateNeedConfirm = true -- 3613
	self.gateRestartArmed = false -- 3614
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 3615
end -- 3584
function Play.prototype.stepInteract(self, dt, input) -- 3618
	local p = self.player -- 3619
	local calmUsed = self.calmConsumed -- 3620
	self.calmConsumed = false -- 3621
	local calming = self.escort.state == "calming" -- 3623
	self.focusCart = false -- 3624
	if self.room.key == "outside" then -- 3624
		local c = self.room.cart -- 3626
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 3627
		local dy = p.y - c.baseY -- 3628
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 3629
	end -- 3629
	if not calmUsed and not calming then -- 3629
		self:stepCart(dt, input) -- 3633
	end -- 3633
	if calmUsed then -- 3633
		self:flashSet("安抚 · 敲两下", 0.8) -- 3638
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 3638
		if self.knockT > 0 then -- 3638
			self.knocks = self.knocks + 1 -- 3642
		else -- 3642
			self.knocks = 1 -- 3644
		end -- 3644
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 3646
		self.knockT = 1.2 -- 3647
		if self.knocks >= 2 then -- 3647
			self:flashSet("敲两下", 0.8) -- 3649
			self.knocks = 0 -- 3650
		else -- 3650
			self:flashSet("敲一下", 0.5) -- 3652
		end -- 3652
	elseif self.knockT > 0 then -- 3652
		self.knockT = self.knockT - dt -- 3655
		if self.knockT <= 0 then -- 3655
			self.knocks = 0 -- 3657
		end -- 3657
	end -- 3657
	local i = 0 -- 3662
	do -- 3662
		i = 0 -- 3663
		while i < #self.room.marks do -- 3663
			do -- 3663
				local m = self.room.marks[i + 1] -- 3664
				if m.kind ~= 0 then -- 3664
					goto __continue604 -- 3666
				end -- 3666
				local subjects = {self.partner, self.player} -- 3668
				local k = 0 -- 3669
				do -- 3669
					k = 0 -- 3670
					while k < #subjects do -- 3670
						do -- 3670
							local s = subjects[k + 1] -- 3671
							if not s.alive then -- 3671
								goto __continue607 -- 3673
							end -- 3673
							local dx = s.x - m.x -- 3675
							local dy = s.y - m.y -- 3676
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3676
								self.checkpoint = m.x -- 3678
								self.checkpointCartAxle = self.cartAxle -- 3679
								if self.isCampaign then -- 3679
									self:captureCheckpoint(m.x) -- 3682
								end -- 3682
								if self.cartDocked then -- 3682
									self:flashSet("检查点 · 车已落窝", 1) -- 3685
								else -- 3685
									self:flashSet("检查点 · 车还没到位", 1) -- 3687
								end -- 3687
							end -- 3687
						end -- 3687
						::__continue607:: -- 3687
						k = k + 1 -- 3670
					end -- 3670
				end -- 3670
			end -- 3670
			::__continue604:: -- 3670
			i = i + 1 -- 3663
		end -- 3663
	end -- 3663
	self:checkCarryGate() -- 3693
end -- 3618
function Play.prototype.stepVillage(self, dt, input) -- 3697
	if self.room.key ~= "village" then -- 3697
		return -- 3699
	end -- 3699
	local p = self.player -- 3701
	local bottle = self.room.bottle -- 3702
	local scav = self.room.scavenger -- 3703
	if not self.hasBottle and bottle ~= nil then -- 3703
		local dx = p.x - bottle.x -- 3707
		local dy = p.y + p.h * 0.5 - bottle.y -- 3708
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 3708
			self.hasBottle = true -- 3710
			self:flashSet("拾起瓶子", 0.8) -- 3711
		end -- 3711
	end -- 3711
	if self.hasBottle then -- 3711
		if input.aim.held then -- 3711
			self.aimHold = self.aimHold + dt -- 3718
			if self.aimHold > 1.2 then -- 3718
				self.aimHold = 1.2 -- 3720
			end -- 3720
			local cached = self:bottleEnd() -- 3723
			self.bottleAimX = cached.x -- 3724
			self.bottleAimY = cached.y -- 3725
		elseif input.aim.released then -- 3725
			if self.aimHold < 0.12 then -- 3725
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 3729
				self.aimHold = 0 -- 3730
			else -- 3730
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3732
				self:throwBottle(____end.x, ____end.y) -- 3733
				self.aimHold = 0 -- 3734
			end -- 3734
		end -- 3734
	else -- 3734
		self.aimHold = 0 -- 3738
		self.bottleAimX = -1 -- 3739
	end -- 3739
	local fly = self.bottleFly -- 3744
	if fly ~= nil then -- 3744
		fly.t = fly.t + dt -- 3746
		fly.x = fly.x0 + fly.vx * fly.t -- 3747
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 3748
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 3749
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 3749
			self:landBottle(fly) -- 3751
		end -- 3751
	end -- 3751
	if self.bottleLandT > 0 then -- 3751
		self.bottleLandT = self.bottleLandT - dt -- 3755
	end -- 3755
	if scav ~= nil then -- 3755
		self:stepScav(dt, scav) -- 3759
	end -- 3759
	local line = self.room.passLine -- 3762
	if line ~= nil and not self.passed and p.x >= line then -- 3762
		self.passed = true -- 3764
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 3765
	end -- 3765
	if self.passed and p.x >= self.ox + 640 then -- 3765
		self:requestRoom("forest", "过第一院出院") -- 3769
		self:flashSet("出院 · 北塔森林", 1.4) -- 3770
	end -- 3770
end -- 3697
function Play.prototype.bottleEnd(self) -- 3775
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3776
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 3779
	return {x = aim.x, y = g} -- 3780
end -- 3775
function Play.prototype.throwBottle(self, tx, ty) -- 3784
	local p = self.player -- 3785
	local dir = tx >= p.x and 1 or -1 -- 3787
	p.facing = dir -- 3788
	local x0 = p.x + dir * 10 -- 3789
	local y0 = p.y + p.h * 0.7 -- 3790
	self.bottleTargetX = tx -- 3791
	self.bottleTargetY = ty -- 3792
	self.bottleSurfaceY = ty -- 3793
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 3794
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 3795
	self.bottleFly = { -- 3796
		x = x0, -- 3796
		y = y0, -- 3796
		x0 = x0, -- 3796
		y0 = y0, -- 3796
		vx = vx, -- 3796
		vy = vy, -- 3796
		t = 0 -- 3796
	} -- 3796
	self.hasBottle = false -- 3797
	self:flashSet("投出", 0.4) -- 3798
	self:emit( -- 3799
		"bottleThrown", -- 3799
		{ -- 3799
			fromX = x0, -- 3800
			fromY = y0, -- 3801
			targetX = tx, -- 3802
			targetY = ty, -- 3803
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 3804
		} -- 3804
	) -- 3804
end -- 3784
function Play.prototype.landBottle(self, fly) -- 3809
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 3810
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 3811
	local s = self.room.scavenger -- 3812
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 3813
	self.bottleFly = nil -- 3814
	self.bottleTargetX = -1 -- 3815
	self.bottleTargetY = 0 -- 3816
	self.bottleSurfaceY = -1 -- 3817
	self.bottleLandX = x -- 3818
	self.bottleLandY = y -- 3819
	self.bottleLandT = 0.9 -- 3820
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 3821
	self:hearBottle(x) -- 3822
end -- 3809
function Play.prototype.hearBottle(self, x) -- 3826
	local s = self.room.scavenger -- 3827
	if s == nil then -- 3827
		return -- 3829
	end -- 3829
	if math.abs(x - self.scavX) > s.range then -- 3829
		self:flashSet("落地 · 他没听见", 0.6) -- 3832
		return -- 3833
	end -- 3833
	self.scavState = "turn" -- 3835
	self.scavT = s.hearTicks -- 3836
	self.scavTargetX = x -- 3837
	self:flashSet("砖地一响 · 他转头", 0.9) -- 3838
end -- 3826
function Play.prototype.stepScav(self, dt, s) -- 3842
	if self.scavState == "chase" then -- 3842
		return -- 3845
	end -- 3845
	if self.scavState == "turn" then -- 3845
		self.scavT = self.scavT - 1 -- 3848
		if self.scavT <= 0 then -- 3848
			self.scavState = "walk" -- 3850
		end -- 3850
		return -- 3852
	end -- 3852
	if self.scavState == "walk" then -- 3852
		local d = self.scavTargetX - self.scavX -- 3855
		if math.abs(d) < 4 then -- 3855
			self.scavState = "stall" -- 3857
			self.scavT = s.stallTicks -- 3858
			return -- 3859
		end -- 3859
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 3861
		return -- 3862
	end -- 3862
	if self.scavState == "stall" then -- 3862
		self.scavT = self.scavT - 1 -- 3865
		if self.scavT <= 0 then -- 3865
			self.scavState = "back" -- 3867
		end -- 3867
		return -- 3869
	end -- 3869
	if self.scavState == "back" then -- 3869
		local home = math.max( -- 3872
			s.x0, -- 3872
			math.min(s.x1, self.scavX) -- 3872
		) -- 3872
		if math.abs(home - self.scavX) < 2 then -- 3872
			self.scavState = "patrol" -- 3874
			return -- 3875
		end -- 3875
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 3877
		return -- 3878
	end -- 3878
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 3880
	if self.scavX >= s.x1 then -- 3880
		self.scavX = s.x1 -- 3882
		self.scavDir = -1 -- 3883
	elseif self.scavX <= s.x0 then -- 3883
		self.scavX = s.x0 -- 3885
		self.scavDir = 1 -- 3886
	end -- 3886
end -- 3842
function Play.prototype.stepCart(self, dt, input) -- 3894
	local p = self.player -- 3895
	local c = self.room.cart -- 3896
	if self.gripping then -- 3896
		if not input.interact.held then -- 3896
			self.gripping = false -- 3900
			self:flashSet("松开车把", 0.4) -- 3901
			return -- 3902
		end -- 3902
	else -- 3902
		if not input.interact.pressed then -- 3902
			return -- 3906
		end -- 3906
		if not self:cartHandleInReach(p) then -- 3906
			return -- 3909
		end -- 3909
		local track = c.depth or 0 -- 3911
		if self:limitDepth(p, track) ~= track then -- 3911
			return -- 3913
		end -- 3913
		p.depth = track -- 3915
		p.depthSpeed = 0 -- 3916
		self.gripping = true -- 3917
		self:flashSet("握住车把", 0.4) -- 3918
		return -- 3919
	end -- 3919
	if self.cartDocked then -- 3919
		return -- 3923
	end -- 3923
	local dir = input.moveX -- 3925
	if dir == 0 then -- 3925
		return -- 3927
	end -- 3927
	local lo = math.min(c.startX, c.endX) -- 3929
	local hi = math.max(c.startX, c.endX) -- 3930
	local next = self.cartAxle + dir * CART_SPEED * dt -- 3931
	if next < lo then -- 3931
		next = lo -- 3933
	end -- 3933
	if next > hi then -- 3933
		next = hi -- 3936
	end -- 3936
	local delta = next - self.cartAxle -- 3938
	if delta == 0 then -- 3938
		return -- 3940
	end -- 3940
	self.cartAxle = next -- 3942
	p.x = p.x + delta -- 3943
	p.facing = dir > 0 and 1 or -1 -- 3944
	self:slideX(p, 0) -- 3945
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 3945
		self.gripping = false -- 3947
		self:flashSet("跟不上了，脱手", 0.6) -- 3948
		return -- 3949
	end -- 3949
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 3949
		self.cartDocked = true -- 3952
		self.gripping = false -- 3953
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 3954
		self:flashSet("车轮落窝", 1.2) -- 3955
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 3955
		self:flashSet("车轮回到起点", 0.5) -- 3957
	end -- 3957
end -- 3894
function Play.prototype.requestRoom(self, key, reason) -- 3965
	if self.wantRoom ~= "" then -- 3965
		return -- 3969
	end -- 3969
	self.wantRoom = key -- 3971
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 3972
end -- 3965
function Play.prototype.checkCarryGate(self) -- 3979
	if self.room.key == "checkpoint" then -- 3979
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 3979
			self.carryCartAxle = self.cartAxle -- 3982
			self.carryCartDocked = self.cartDocked -- 3983
			self:requestRoom("gate", "检查站出口") -- 3984
			self:flashSet("出检查站 · 城门", 1.2) -- 3985
		end -- 3985
		return -- 3987
	end -- 3987
	if self.room.key == "outside" then -- 3987
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 3987
			self.carryCartAxle = self.cartAxle -- 3993
			self.carryCartDocked = self.cartDocked -- 3994
			self:requestRoom("village", "墙根走完") -- 3995
			self:flashSet("墙根走完 · 进村口", 1.2) -- 3996
		end -- 3996
	end -- 3996
end -- 3979
function Play.prototype.aimAt(self, wx, wy) -- 4003
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 4004
	self.aimX = s.x -- 4005
	self.aimY = s.y -- 4006
end -- 4003
function Play.prototype.shoot(self, a) -- 4009
	if self.isCampaign and self.reloadT > 0 then -- 4009
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 4011
		return -- 4012
	end -- 4012
	local ox = a.x + a.facing * 8 -- 4014
	local muzzleY = a.y + a.h * 0.72 -- 4015
	local oy = muzzleY + a.depth -- 4016
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4018
	local dx = aim.x - ox -- 4021
	local dy = aim.y - oy -- 4022
	local len = math.sqrt(dx * dx + dy * dy) -- 4023
	if len < 0.001 then -- 4023
		dx = a.facing -- 4025
		dy = 0 -- 4026
	else -- 4026
		dx = dx / len -- 4028
		dy = dy / len -- 4029
	end -- 4029
	if dx ~= 0 then -- 4029
		a.facing = dx > 0 and 1 or -1 -- 4032
	end -- 4032
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 4035
	local hitEnemy = self:raycastEnemies(ray) -- 4036
	local tEnemy = hitEnemy.t -- 4037
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 4038
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 4039
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 4040
	local tWall = solid.t -- 4041
	local rawEffect = self:consumeReloadEffect() -- 4043
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 4044
	local reloadEffect = rawEffect -- 4045
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 4047
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 4048
	self.trace = { -- 4050
		x0 = ox, -- 4050
		y0 = oy, -- 4050
		x1 = ox + dx * t, -- 4050
		y1 = oy + dy * t, -- 4050
		hit = hit -- 4050
	} -- 4050
	self.traceT = 0.12 -- 4051
	self:applyFireDanger(ox) -- 4052
	local killed = false -- 4053
	if hit then -- 4053
		local i = hitEnemy.index -- 4055
		local e = self.enemies[i + 1] -- 4056
		local impactY = oy + dy * tEnemy -- 4057
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 4058
		local shieldTop = e.y + (e.depth or 0) + 64 -- 4059
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 4059
			e.shieldHp = (e.shieldHp or 0) - 1 -- 4061
			e.hitT = 0.3 -- 4062
			self:flashSet( -- 4063
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 4063
				0.8 -- 4063
			) -- 4063
			self:emit("shotResolved", { -- 4064
				hit = true, -- 4065
				enemyIndex = i, -- 4065
				enemyX = e.x, -- 4065
				aimX = aim.x, -- 4065
				aimY = aim.y, -- 4065
				impactX = ox + dx * t, -- 4066
				impactY = oy + dy * t, -- 4066
				shield = true -- 4066
			}) -- 4066
			self:beginReload() -- 4068
			return -- 4069
		end -- 4069
		e.alive = false -- 4071
		e.hitT = 0.4 -- 4072
		killed = true -- 4073
		self:flashSet("命中", 0.6) -- 4074
		self:dropFor(e) -- 4075
		if reloadEffect == "light" and weaponFx == "light" then -- 4075
			self:blindNearby(e, 160, i) -- 4077
		end -- 4077
		if reloadEffect == "push" then -- 4077
			e.x = e.x + a.facing * 46 -- 4080
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4081
		elseif reloadEffect == "echo" then -- 4081
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 4083
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 4084
		elseif reloadEffect == "light" then -- 4084
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 4086
		end -- 4086
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 4086
		self:damageProp(solid.box, 1) -- 4089
	else -- 4089
		self:flashSet("打空", 0.35) -- 4091
	end -- 4091
	if self.isCampaign then -- 4091
		self:beginReload() -- 4094
	end -- 4094
	self:emit("shotResolved", { -- 4096
		hit = hit, -- 4097
		enemyIndex = hit and hitEnemy.index or -1, -- 4098
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 4099
		aimX = aim.x, -- 4100
		aimY = aim.y, -- 4101
		impactX = ox + dx * t, -- 4102
		impactY = oy + dy * t -- 4103
	}) -- 4103
end -- 4009
function Play.prototype.applyFireDanger(self, shotX) -- 4108
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 4108
		return -- 4110
	end -- 4110
	local dangerX = shotX -- 4112
	local best = -1 -- 4113
	local bestD = 1000000000 -- 4114
	local i = 0 -- 4115
	do -- 4115
		i = 0 -- 4116
		while i < #self.enemies do -- 4116
			do -- 4116
				local e = self.enemies[i + 1] -- 4117
				if not e.alive then -- 4117
					goto __continue688 -- 4119
				end -- 4119
				local d = math.abs(e.x - self.partner.x) -- 4121
				if d < bestD then -- 4121
					bestD = d -- 4123
					best = i -- 4124
				end -- 4124
			end -- 4124
			::__continue688:: -- 4124
			i = i + 1 -- 4116
		end -- 4116
	end -- 4116
	if best >= 0 then -- 4116
		dangerX = self.enemies[best + 1].x -- 4128
	end -- 4128
	local exposed = self:childExposed(dangerX) -- 4130
	local before = self.escort.fear -- 4131
	local dangerId = self.nextDangerId -- 4132
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 4133
	self.nextDangerId = self.nextDangerId + 1 -- 4134
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 4135
	if after > before then -- 4135
		self:flashSet( -- 4137
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 4137
			1 -- 4137
		) -- 4137
	elseif not exposed then -- 4137
		self:flashSet("枪声没够到她", 0.5) -- 4139
	end -- 4139
end -- 4108
function Play.prototype.childExposed(self, dangerX) -- 4144
	local c = self.partner -- 4145
	if not c.alive then -- 4145
		return false -- 4147
	end -- 4147
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 4147
		self.boxes, -- 4150
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 4150
	) then -- 4150
		return false -- 4151
	end -- 4151
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 4151
		return false -- 4154
	end -- 4154
	local toDanger = dangerX - c.x -- 4156
	local toPlayer = self.player.x - c.x -- 4157
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 4157
		return false -- 4160
	end -- 4160
	return true -- 4162
end -- 4144
function Play.prototype.raycastEnemies(self, ray) -- 4166
	local best = -1 -- 4167
	local bestI = -1 -- 4168
	do -- 4168
		local i = 0 -- 4169
		while i < #self.enemies do -- 4169
			do -- 4169
				local e = self.enemies[i + 1] -- 4170
				if not e.alive then -- 4170
					goto __continue702 -- 4172
				end -- 4172
				local y = e.y + (e.depth or 0) -- 4174
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 4175
				if t >= 0 and (best < 0 or t < best) then -- 4175
					best = t -- 4177
					bestI = i -- 4178
				end -- 4178
			end -- 4178
			::__continue702:: -- 4178
			i = i + 1 -- 4169
		end -- 4169
	end -- 4169
	return {t = best, index = bestI} -- 4181
end -- 4166
function Play.prototype.raycastWorld(self, ray) -- 4184
	return self:raycastSolid(ray).t -- 4185
end -- 4184
function Play.prototype.raycastSolid(self, ray) -- 4189
	local best = -1 -- 4190
	local bestBox = nil -- 4191
	for ____, box in ipairs(self.boxes) do -- 4192
		do -- 4192
			if box.broken == true or box.hidden == true then -- 4192
				goto __continue707 -- 4194
			end -- 4194
			local t = hitBox(ray, box) -- 4199
			if t > 2 and (best < 0 or t < best) then -- 4199
				best = t -- 4202
				bestBox = box -- 4203
			end -- 4203
		end -- 4203
		::__continue707:: -- 4203
	end -- 4203
	if ray.dy < 0 then -- 4203
		local t = -ray.y / ray.dy -- 4207
		if t >= 0 and (best < 0 or t < best) then -- 4207
			best = t -- 4209
			bestBox = nil -- 4210
		end -- 4210
	end -- 4210
	return {t = best, box = bestBox} -- 4213
end -- 4189
function Play.prototype.dropFor(self, e) -- 4217
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 4217
		return -- 4219
	end -- 4219
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 4219
		return -- 4222
	end -- 4222
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 4224
	local ____self_pickups_57 = self.pickups -- 4224
	____self_pickups_57[#____self_pickups_57 + 1] = { -- 4225
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 4226
		kind = e.drop, -- 4226
		x = e.x, -- 4226
		y = e.y, -- 4226
		depth = e.depth, -- 4227
		label = label .. " ×1" -- 4227
	} -- 4227
	self:log("掉落 " .. label) -- 4229
end -- 4217
function Play.prototype.damageProp(self, b, amount) -- 4233
	if b.breakable == nil or b.broken == true then -- 4233
		return -- 4235
	end -- 4235
	local ____b_breakable_58, ____hp_59 = b.breakable, "hp" -- 4235
	____b_breakable_58[____hp_59] = ____b_breakable_58[____hp_59] - amount -- 4237
	if b.breakable.hp > 0 then -- 4237
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 4239
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 4240
		return -- 4241
	end -- 4241
	b.broken = true -- 4243
	for ____, other in ipairs(self.boxes) do -- 4244
		if other.id ~= nil and other.id == b.id then -- 4244
			other.broken = true -- 4246
		end -- 4246
	end -- 4246
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 4249
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 4250
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 4251
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 4252
end -- 4233
function Play.prototype.slideDepth(self, a, distance) -- 4256
	a.depth = self:limitDepth(a, a.depth + distance) -- 4257
end -- 4256
function Play.prototype.limitDepth(self, a, target) -- 4260
	local road = self.room.depth -- 4261
	if road == nil or target == a.depth then -- 4261
		return a.depth -- 4263
	end -- 4263
	local next = math.max( -- 4265
		road.min, -- 4265
		math.min(road.max, target) -- 4265
	) -- 4265
	local half = a.w / 2 -- 4266
	for ____, b in ipairs(self.boxes) do -- 4267
		do -- 4267
			local footprint = b.depth -- 4268
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4268
				goto __continue725 -- 4273
			end -- 4273
			local front = footprint.min - ACTOR_DEPTH_HALF -- 4275
			local back = footprint.max + ACTOR_DEPTH_HALF -- 4276
			if a.depth <= front and next > front then -- 4276
				next = front -- 4278
			elseif a.depth >= back and next < back then -- 4278
				next = back -- 4280
			end -- 4280
		end -- 4280
		::__continue725:: -- 4280
	end -- 4280
	return next -- 4283
end -- 4260
function Play.prototype.slideX(self, a, dx) -- 4287
	local nx = a.x + dx -- 4288
	local half = a.w / 2 -- 4289
	local room = self.room -- 4290
	nx = math.max( -- 4291
		room.minX + half, -- 4291
		math.min(room.maxX - half, nx) -- 4291
	) -- 4291
	local i = 0 -- 4292
	do -- 4292
		i = 0 -- 4293
		while i < #self.boxes do -- 4293
			do -- 4293
				local b = self.boxes[i + 1] -- 4294
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4294
					goto __continue732 -- 4296
				end -- 4296
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4296
					goto __continue732 -- 4299
				end -- 4299
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4299
					goto __continue732 -- 4302
				end -- 4302
				if nx + half > b.x0 and nx - half < b.x1 then -- 4302
					if a.x <= b.x0 then -- 4302
						nx = b.x0 - half -- 4306
					elseif a.x >= b.x1 then -- 4306
						nx = b.x1 + half -- 4308
					else -- 4308
						nx = a.x -- 4310
					end -- 4310
				end -- 4310
			end -- 4310
			::__continue732:: -- 4310
			i = i + 1 -- 4293
		end -- 4293
	end -- 4293
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 4293
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 4318
		local bx0 = self.cartAxle - CART_HALF -- 4319
		local bx1 = self.cartAxle + CART_HALF -- 4320
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 4320
			if a.x <= bx0 then -- 4320
				nx = bx0 - half -- 4323
			elseif a.x >= bx1 then -- 4323
				nx = bx1 + half -- 4325
			else -- 4325
				nx = a.x -- 4327
			end -- 4327
		end -- 4327
	end -- 4327
	local arch = room.arch -- 4335
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 4335
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 4337
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 4337
			if a.x <= arch.x0 then -- 4337
				nx = arch.x0 - half -- 4340
			elseif a.x >= arch.x1 then -- 4340
				nx = arch.x1 + half -- 4342
			end -- 4342
		end -- 4342
	end -- 4342
	a.x = nx -- 4346
end -- 4287
function Play.prototype.fallY(self, a, dt) -- 4350
	a.vy = a.vy - ____exports.GRAVITY * dt -- 4351
	if a.vy < -900 then -- 4351
		a.vy = -900 -- 4353
	end -- 4353
	local ny = a.y + a.vy * dt -- 4355
	local half = a.w / 2 -- 4356
	if a.vy <= 0 then -- 4356
		local reach = a.onGround and STEP_UP or 0 -- 4359
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 4360
		if ny <= ground then -- 4360
			ny = ground -- 4362
			a.vy = 0 -- 4363
			a.onGround = true -- 4364
		else -- 4364
			a.onGround = false -- 4366
		end -- 4366
	else -- 4366
		a.onGround = false -- 4369
		local i = 0 -- 4370
		do -- 4370
			i = 0 -- 4371
			while i < #self.boxes do -- 4371
				do -- 4371
					local b = self.boxes[i + 1] -- 4372
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4372
						goto __continue756 -- 4374
					end -- 4374
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4374
						goto __continue756 -- 4377
					end -- 4377
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 4377
						goto __continue756 -- 4380
					end -- 4380
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 4380
						ny = b.y0 - a.h -- 4383
						a.vy = 0 -- 4384
					end -- 4384
				end -- 4384
				::__continue756:: -- 4384
				i = i + 1 -- 4371
			end -- 4371
		end -- 4371
	end -- 4371
	a.y = ny -- 4388
end -- 4350
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 4392
	if depth == nil then -- 4392
		depth = 0 -- 4392
	end -- 4392
	local g = -9999 -- 4393
	local i = 0 -- 4394
	do -- 4394
		i = 0 -- 4395
		while i < #self.floors do -- 4395
			local f = self.floors[i + 1] -- 4396
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 4396
				g = f.y1 -- 4398
			end -- 4398
			i = i + 1 -- 4395
		end -- 4395
	end -- 4395
	do -- 4395
		i = 0 -- 4401
		while i < #self.boxes do -- 4401
			do -- 4401
				local b = self.boxes[i + 1] -- 4402
				if b.broken == true or b.hidden == true or b.soft == true then -- 4402
					goto __continue766 -- 4404
				end -- 4404
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 4404
					g = b.y1 -- 4408
				end -- 4408
			end -- 4408
			::__continue766:: -- 4408
			i = i + 1 -- 4401
		end -- 4401
	end -- 4401
	return g -- 4411
end -- 4392
function Play.prototype.updateCamera(self, dt) -- 4414
	local p = self.player -- 4415
	local tx = p.x + p.facing * 30 -- 4416
	local ty = p.y + CAM_LOOK_UP -- 4417
	local k = math.min(1, CAM_FOLLOW * dt) -- 4418
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 4419
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 4420
end -- 4414
function Play.prototype.clampCamera(self, w, h) -- 4424
	local room = self.room -- 4425
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 4426
	local spanX = room.maxX - room.minX -- 4427
	if spanX <= halfW * 2 then -- 4427
		self.cam.x = (room.minX + room.maxX) / 2 -- 4429
	else -- 4429
		self.cam.x = math.max( -- 4431
			room.minX + halfW, -- 4431
			math.min(room.maxX - halfW, self.cam.x) -- 4431
		) -- 4431
	end -- 4431
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 4434
	local spanY = room.height -- 4435
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 4436
	if spanY <= halfH * 2 then -- 4436
		self.cam.y = camY -- 4438
	else -- 4438
		self.cam.y = math.max( -- 4440
			camY, -- 4440
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 4440
		) -- 4440
	end -- 4440
end -- 4424
function Play.prototype.flashSet(self, text, t) -- 4444
	self.flash = text -- 4445
	self.flashT = t -- 4446
end -- 4444
function Play.prototype.statusText(self) -- 4450
	local p = self.player -- 4451
	local parts = {} -- 4452
	local who = self.childMode and "小满" or "周戍" -- 4453
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 4454
	if self.room.key == "prologue" then -- 4454
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4457
		if self.phase == "prologue-wait" then -- 4457
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 4459
		elseif self.phase == "prologue-give" then -- 4459
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 4461
		else -- 4461
			parts[#parts + 1] = "跟随" -- 4463
		end -- 4463
		if self.paused then -- 4463
			parts[#parts + 1] = "已暂停" -- 4466
		end -- 4466
		return table.concat(parts, " · ") -- 4468
	end -- 4468
	if self.room.key == "street" then -- 4468
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4471
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4472
		if self.paused then -- 4472
			parts[#parts + 1] = "已暂停" -- 4474
		end -- 4474
		return table.concat(parts, " · ") -- 4476
	end -- 4476
	if self.room.key == "gate" then -- 4476
		local ____temp_60 -- 4479
		if self.room.story == nil then -- 4479
			____temp_60 = nil -- 4479
		else -- 4479
			____temp_60 = self.room.story.gate -- 4479
		end -- 4479
		local g = ____temp_60 -- 4479
		if g ~= nil then -- 4479
			parts[#parts + 1] = self:gateLabel() -- 4481
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 4482
				0, -- 4483
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 4483
			))) .. " 秒" -- 4483
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4484
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4485
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 4486
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 4487
			if self.gateFailCount > 0 then -- 4487
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 4489
			end -- 4489
			if self.flash ~= "" then -- 4489
				parts[#parts + 1] = self.flash -- 4492
			end -- 4492
		end -- 4492
		if self.paused then -- 4492
			parts[#parts + 1] = "已暂停" -- 4496
		end -- 4496
		return table.concat(parts, " · ") -- 4498
	end -- 4498
	if self.room.key == "forest" then -- 4498
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4501
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 4502
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 4503
		if self.caughtT > 0 then -- 4503
			parts[#parts + 1] = "复位中" -- 4505
		end -- 4505
		if self.paused then -- 4505
			parts[#parts + 1] = "已暂停" -- 4508
		end -- 4508
		return table.concat(parts, " · ") -- 4510
	end -- 4510
	if self.room.key == "tower" then -- 4510
		if self.phase == "tower-wait" then -- 4510
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 4514
		elseif self.phase == "tower-knock" then -- 4514
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 4516
		elseif self.phase == "tower-given" then -- 4516
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 4518
		else -- 4518
			parts[#parts + 1] = "片尾" -- 4520
		end -- 4520
		if self.paused then -- 4520
			parts[#parts + 1] = "已暂停" -- 4523
		end -- 4523
		return table.concat(parts, " · ") -- 4525
	end -- 4525
	if self.room.key == "village" then -- 4525
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4528
		if self.hasBottle then -- 4528
			parts[#parts + 1] = "有瓶" -- 4530
		elseif self.bottleFly ~= nil then -- 4530
			parts[#parts + 1] = "瓶在飞" -- 4532
		else -- 4532
			parts[#parts + 1] = "空手" -- 4534
		end -- 4534
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 4536
		if self.scavChase then -- 4536
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 4538
		end -- 4538
		if self.passed then -- 4538
			parts[#parts + 1] = "已过通行线" -- 4541
		end -- 4541
		if self.paused then -- 4541
			parts[#parts + 1] = "已暂停" -- 4544
		end -- 4544
		return table.concat(parts, " · ") -- 4546
	end -- 4546
	local isChild = self.childMode -- 4549
	if isChild then -- 4549
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4551
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 4552
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4553
	else -- 4553
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 4555
		if p.rollT > 0 then -- 4555
			parts[#parts + 1] = "翻滚中" -- 4557
		end -- 4557
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4559
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4560
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 4561
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 4562
	end -- 4562
	if self.checkpoint >= 0 then -- 4562
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 4565
	end -- 4565
	if self.paused then -- 4565
		parts[#parts + 1] = "已暂停" -- 4568
	end -- 4568
	return table.concat(parts, " · ") -- 4570
end -- 4450
function Play.prototype.aliveEnemies(self) -- 4574
	local n = 0 -- 4575
	local i = 0 -- 4576
	do -- 4576
		i = 0 -- 4577
		while i < #self.enemies do -- 4577
			if self.enemies[i + 1].alive then -- 4577
				n = n + 1 -- 4579
			end -- 4579
			i = i + 1 -- 4577
		end -- 4577
	end -- 4577
	return n -- 4582
end -- 4574
function Play.prototype.threatened(self) -- 4587
	do -- 4587
		local i = 0 -- 4588
		while i < #self.enemies do -- 4588
			local e = self.enemies[i + 1] -- 4589
			if e.alive and e.warnT > 0 then -- 4589
				return true -- 4591
			end -- 4591
			i = i + 1 -- 4588
		end -- 4588
	end -- 4588
	return false -- 4594
end -- 4587
function Play.prototype.gateSecondsLeft(self) -- 4597
	local ____temp_61 -- 4598
	if self.room.story == nil then -- 4598
		____temp_61 = nil -- 4598
	else -- 4598
		____temp_61 = self.room.story.gate -- 4598
	end -- 4598
	local g = ____temp_61 -- 4598
	if g == nil then -- 4598
		return 0 -- 4600
	end -- 4600
	return math.max( -- 4602
		0, -- 4602
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 4602
	) -- 4602
end -- 4597
function Play.prototype.gateLabel(self) -- 4605
	if self.phase == "gate-idle" then -- 4605
		return "待就位" -- 4607
	end -- 4607
	if self.phase == "gate-hold" then -- 4607
		return "守点中" -- 4610
	end -- 4610
	if self.phase == "gate-send" then -- 4610
		return "送别" -- 4613
	end -- 4613
	if self.phase == "gate-count" then -- 4613
		return "数数 " .. tostring(self.countTick) -- 4616
	end -- 4616
	return "她走" -- 4618
end -- 4605
function Play.prototype.dogLabel(self) -- 4622
	if self.dogState == "ear" then -- 4622
		return "转耳" -- 4624
	end -- 4624
	if self.dogState == "chase" then -- 4624
		return "追" -- 4627
	end -- 4627
	if self.dogState == "sniff" then -- 4627
		return "停" -- 4630
	end -- 4630
	if self.dogState == "back" then -- 4630
		return "回线" -- 4633
	end -- 4633
	return "巡逻" -- 4635
end -- 4622
function Play.prototype.doorXOf(self) -- 4638
	local ____temp_62 -- 4639
	if self.room.story == nil then -- 4639
		____temp_62 = nil -- 4639
	else -- 4639
		____temp_62 = self.room.story.tower -- 4639
	end -- 4639
	local t = ____temp_62 -- 4639
	return t == nil and 0 or t.doorX -- 4640
end -- 4638
function Play.prototype.scavLabel(self) -- 4644
	if self.scavState == "chase" then -- 4644
		return "追" -- 4646
	end -- 4646
	if self.scavState == "turn" then -- 4646
		return "转头" -- 4649
	end -- 4649
	if self.scavState == "walk" then -- 4649
		return "赶来" -- 4652
	end -- 4652
	if self.scavState == "stall" then -- 4652
		return "停住" -- 4655
	end -- 4655
	if self.scavState == "back" then -- 4655
		return "回位" -- 4658
	end -- 4658
	return "巡逻" -- 4660
end -- 4644
function Play.prototype.hintText(self) -- 4664
	if self.paused then -- 4664
		return "Esc 继续 · R 重置" -- 4666
	end -- 4666
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 4666
		if self:threatened() then -- 4666
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 4672
		end -- 4672
		if self.coverHug then -- 4672
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 4675
		end -- 4675
		if self.coverNear then -- 4675
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 4678
		end -- 4678
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 4680
	end -- 4680
	if self.flash ~= "" then -- 4680
		return self.flash -- 4683
	end -- 4683
	if self.room.key == "prologue" then -- 4683
		if self.phase == "prologue-wait" then -- 4683
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 4687
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 4688
		end -- 4688
		if self.phase == "prologue-give" then -- 4688
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 4691
		end -- 4691
		return "她跟着你了 · 两人一起走到门口 680" -- 4693
	end -- 4693
	if self.room.key == "street" then -- 4693
		if self:aliveEnemies() > 0 then -- 4693
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 4697
		end -- 4697
		return "清完了 · 两人一起走到右边检查站入口 900" -- 4699
	end -- 4699
	if self.room.key == "gate" then -- 4699
		local ____temp_63 -- 4702
		if self.room.story == nil then -- 4702
			____temp_63 = nil -- 4702
		else -- 4702
			____temp_63 = self.room.story.gate -- 4702
		end -- 4702
		local g = ____temp_63 -- 4702
		if g ~= nil then -- 4702
			if self.phase == "gate-idle" then -- 4702
				if self.gateNeedConfirm then -- 4702
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 4706
				end -- 4706
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 4708
			end -- 4708
			if self.phase == "gate-hold" then -- 4708
				if self.coveredFlash > 0 then -- 4708
					return "掩体挡下了这一枪 · 别露头" -- 4712
				end -- 4712
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 4714
			end -- 4714
			if self.phase == "gate-send" then -- 4714
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 4717
			end -- 4717
			if self.phase == "gate-count" then -- 4717
				if self.countTick >= ____exports.GATE_COUNT_END then -- 4717
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 4721
				end -- 4721
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 4723
			end -- 4723
			return "她自己走 · 跟着出城门 1120" -- 4725
		end -- 4725
	end -- 4725
	if self.room.key == "forest" then -- 4725
		if self.dogState == "chase" then -- 4725
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 4730
		end -- 4730
		if self.dogState == "ear" then -- 4730
			return "狗转耳朵了 · 停下或蹲下别出声" -- 4733
		end -- 4733
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 4735
	end -- 4735
	if self.room.key == "tower" then -- 4735
		if self.phase == "tower-wait" then -- 4735
			return "走到门前 445 点一次 E 敲两下" -- 4739
		end -- 4739
		if self.phase == "tower-knock" then -- 4739
			return "敲两下 · 等门开" -- 4742
		end -- 4742
		if self.phase == "tower-given" then -- 4742
			return "递交针套和纸条 · 看登记簿最后一行" -- 4745
		end -- 4745
		return "片尾 · 点 E 再玩一次，回到序章" -- 4747
	end -- 4747
	if self.room.key == "village" then -- 4747
		if self.bottleFly ~= nil then -- 4747
			return "等瓶子落地 · 触地才发声" -- 4751
		end -- 4751
		if self.hasBottle then -- 4751
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 4754
		end -- 4754
		if self.passed then -- 4754
			return "已过第一院 · R 重置可再来一遍" -- 4757
		end -- 4757
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 4759
	end -- 4759
	if self.room.key == "outside" then -- 4759
		if self.focusCart then -- 4759
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 4763
		end -- 4763
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 4765
	end -- 4765
	if self.escort.state == "frozen" then -- 4765
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 4765
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 4769
		end -- 4769
		return "小满吓住了 · 走过去，靠近再点 E" -- 4771
	end -- 4771
	if self.escort.state == "calming" then -- 4771
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 4774
	end -- 4774
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 4776
end -- 4664
function Play.prototype.draw(self, draw, w, h) -- 4781
	self.viewW = w -- 4782
	self.viewH = h -- 4783
	self.view = ____exports.computeViewport(w, h) -- 4784
	self:clampCamera(w, h) -- 4785
	draw:clear() -- 4786
	draw:drawRect( -- 4788
		Rect(0, 0, w, h), -- 4788
		BG_VOID -- 4788
	) -- 4788
	local box = self:canvasRect(w, h) -- 4789
	draw:drawRect(box, BG_FAR) -- 4790
	draw:drawRect( -- 4791
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 4791
		BG_MID -- 4791
	) -- 4791
	self:drawFloors(draw, w, h) -- 4793
	self:drawSolids(draw, w, h) -- 4794
	self:drawZones(draw, w, h) -- 4795
	self:drawArch(draw, w, h) -- 4796
	self:drawCart(draw, w, h) -- 4797
	self:drawCampaignProps(draw, w, h) -- 4798
	self:drawActors(draw, w, h) -- 4799
	self:drawTrace(draw, w, h) -- 4800
	self:drawAim(draw, w, h) -- 4801
end -- 4781
function Play.prototype.canvasRect(self, w, h) -- 4805
	local v = self.view -- 4806
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 4807
end -- 4805
function Play.prototype.px(self, n) -- 4811
	return n * self.view.zoom -- 4812
end -- 4811
function Play.prototype.sx(self, wx, w) -- 4816
	local v = self.view -- 4817
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 4818
	return v.ox + lx * v.zoom -- 4819
end -- 4816
function Play.prototype.sy(self, wy, h) -- 4823
	local v = self.view -- 4824
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 4825
	return v.oy + ly * v.zoom -- 4826
end -- 4823
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 4829
	local px0 = self:sx(x0, w) -- 4830
	local px1 = self:sx(x1, w) -- 4831
	local py0 = self:sy(y0, h) -- 4832
	local py1 = self:sy(y1, h) -- 4833
	if px1 <= px0 or py1 <= py0 then -- 4833
		return -- 4835
	end -- 4835
	draw:drawRect( -- 4837
		Rect(px0, py0, px1 - px0, py1 - py0), -- 4837
		color -- 4837
	) -- 4837
end -- 4829
function Play.prototype.drawFloors(self, draw, w, h) -- 4840
	local i = 0 -- 4841
	do -- 4841
		i = 0 -- 4842
		while i < #self.room.floors do -- 4842
			local f = self.room.floors[i + 1] -- 4843
			local ____temp_64 -- 4844
			if f.y == 0 then -- 4844
				____temp_64 = self.room.depth -- 4844
			else -- 4844
				____temp_64 = nil -- 4844
			end -- 4844
			local road = ____temp_64 -- 4844
			local y = self:sy(f.y + (road and road.min or 0), h) -- 4845
			local x0 = self:sx(f.x0, w) -- 4846
			local x1 = self:sx(f.x1, w) -- 4847
			local deck = self:px(5) -- 4848
			if road ~= nil then -- 4848
				local back = self:sy(f.y + road.max, h) -- 4850
				draw:drawRect( -- 4851
					Rect(x0, y, x1 - x0, back - y), -- 4851
					FLOOR_DECK, -- 4851
					self:px(1), -- 4851
					SOLID_EDGE -- 4851
				) -- 4851
			end -- 4851
			draw:drawRect( -- 4853
				Rect(x0, y - deck, x1 - x0, deck), -- 4853
				FLOOR_DECK -- 4853
			) -- 4853
			draw:drawSegment( -- 4854
				Vec2(x0, y), -- 4854
				Vec2(x1, y), -- 4854
				self:px(1), -- 4854
				GROUND -- 4854
			) -- 4854
			i = i + 1 -- 4842
		end -- 4842
	end -- 4842
end -- 4840
function Play.prototype.drawSolids(self, draw, w, h) -- 4858
	local i = 0 -- 4859
	do -- 4859
		i = 0 -- 4860
		while i < #self.boxes do -- 4860
			do -- 4860
				local b = self.boxes[i + 1] -- 4861
				if b.id == "braced_shield" or b.hidden == true then -- 4861
					goto __continue887 -- 4863
				end -- 4863
				if b.broken == true then -- 4863
					if b.breakable ~= nil then -- 4863
						local gy = self:sy(b.y0, h) -- 4868
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 4869
						local k = 0 -- 4870
						do -- 4870
							k = 0 -- 4871
							while k < 3 do -- 4871
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 4872
								draw:drawSegment( -- 4873
									Vec2( -- 4873
										gx - self:px(4), -- 4873
										gy + self:px(k % 2) -- 4873
									), -- 4873
									Vec2( -- 4873
										gx + self:px(5), -- 4873
										gy + self:px(k % 2) -- 4873
									), -- 4873
									self:px(1), -- 4873
									rgb -- 4873
								) -- 4873
								k = k + 1 -- 4871
							end -- 4871
						end -- 4871
					end -- 4871
					goto __continue887 -- 4876
				end -- 4876
				local ____opt_67 = b.depth -- 4876
				local front = ____opt_67 and ____opt_67.min or 0 -- 4878
				local ____opt_69 = b.depth -- 4878
				local back = ____opt_69 and ____opt_69.max or 0 -- 4879
				local fill = SOLID_FILL -- 4880
				local line = SOLID_EDGE -- 4881
				if b.soft == true then -- 4881
					fill = SOFT -- 4883
					line = SOFT_LINE -- 4884
				elseif b.breakable ~= nil then -- 4884
					line = DANGER_LINE -- 4886
					fill = Color(0.3, 0.24, 0.16, 1) -- 4887
				elseif b.interact ~= nil then -- 4887
					line = PASS_LINE -- 4889
				end -- 4889
				self:drawBox( -- 4891
					draw, -- 4891
					w, -- 4891
					h, -- 4891
					b.x0, -- 4891
					b.x1, -- 4891
					b.y0 + front, -- 4891
					b.y1 + back, -- 4891
					fill -- 4891
				) -- 4891
				draw:drawSegment( -- 4892
					Vec2( -- 4892
						self:sx(b.x0, w), -- 4892
						self:sy(b.y1 + front, h) -- 4892
					), -- 4892
					Vec2( -- 4893
						self:sx(b.x1, w), -- 4893
						self:sy(b.y1 + front, h) -- 4893
					), -- 4893
					self:px(1), -- 4893
					line -- 4893
				) -- 4893
				if b.breakable ~= nil then -- 4893
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 4896
					local cyp = self:sy(b.y1 + front, h) -- 4897
					draw:drawSegment( -- 4898
						Vec2( -- 4898
							cxp - self:px(4), -- 4898
							cyp + self:px(1) -- 4898
						), -- 4898
						Vec2( -- 4898
							cxp + self:px(3), -- 4898
							cyp + self:px(5) -- 4898
						), -- 4898
						self:px(1), -- 4898
						line -- 4898
					) -- 4898
				end -- 4898
			end -- 4898
			::__continue887:: -- 4898
			i = i + 1 -- 4860
		end -- 4860
	end -- 4860
end -- 4858
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 4904
	local i = 0 -- 4905
	do -- 4905
		i = 0 -- 4906
		while i < #self.pickups do -- 4906
			do -- 4906
				local pk = self.pickups[i + 1] -- 4907
				if pk.id == "" then -- 4907
					goto __continue899 -- 4909
				end -- 4909
				local gy = pk.y + (pk.depth or 0) -- 4911
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 4912
				draw:drawRect( -- 4913
					Rect( -- 4913
						self:sx(pk.x - 5, w), -- 4913
						self:sy(gy + 12 + bob, h), -- 4913
						self:px(10), -- 4913
						self:px(10) -- 4913
					), -- 4913
					Color(0.84, 0.7, 0.3, 1) -- 4914
				) -- 4914
				draw:drawSegment( -- 4915
					Vec2( -- 4915
						self:sx(pk.x - 5, w), -- 4915
						self:sy(gy + 12 + bob, h) -- 4915
					), -- 4915
					Vec2( -- 4916
						self:sx(pk.x + 5, w), -- 4916
						self:sy(gy + 12 + bob, h) -- 4916
					), -- 4916
					self:px(1), -- 4916
					Color(0.95, 0.86, 0.52, 1) -- 4916
				) -- 4916
			end -- 4916
			::__continue899:: -- 4916
			i = i + 1 -- 4906
		end -- 4906
	end -- 4906
	if self.bracedShield ~= nil then -- 4906
		local sh = self.bracedShield -- 4919
		draw:drawRect( -- 4920
			Rect( -- 4920
				self:sx(sh.x - sh.w / 2, w), -- 4920
				self:sy(sh.y, h), -- 4920
				self:px(sh.w), -- 4920
				self:px(sh.h) -- 4920
			), -- 4920
			Color(0.42, 0.4, 0.34, 1) -- 4921
		) -- 4921
		draw:drawSegment( -- 4922
			Vec2( -- 4922
				self:sx(sh.x - sh.w / 2, w), -- 4922
				self:sy(sh.y + sh.h, h) -- 4922
			), -- 4922
			Vec2( -- 4923
				self:sx(sh.x + sh.w / 2, w), -- 4923
				self:sy(sh.y + sh.h, h) -- 4923
			), -- 4923
			self:px(1), -- 4923
			Color(0.74, 0.72, 0.62, 1) -- 4923
		) -- 4923
	end -- 4923
end -- 4904
function Play.prototype.drawZones(self, draw, w, h) -- 4927
	local i = 0 -- 4928
	do -- 4928
		i = 0 -- 4929
		while i < #self.room.zones do -- 4929
			local z = self.room.zones[i + 1] -- 4930
			local fill = DANGER -- 4931
			local line = DANGER_LINE -- 4932
			if z.tint == 2 then -- 4932
				fill = SOFT -- 4934
				line = SOFT_LINE -- 4935
			elseif z.tint == 3 then -- 4935
				fill = BRICK -- 4937
				line = BRICK_LINE -- 4938
			elseif z.tint == 4 then -- 4938
				fill = PASS -- 4940
				line = PASS_LINE -- 4941
			end -- 4941
			self:drawBox( -- 4943
				draw, -- 4943
				w, -- 4943
				h, -- 4943
				z.x0, -- 4943
				z.x1, -- 4943
				z.y, -- 4943
				z.y + z.h, -- 4943
				fill -- 4943
			) -- 4943
			draw:drawSegment( -- 4944
				Vec2( -- 4944
					self:sx(z.x0, w), -- 4944
					self:sy(z.y, h) -- 4944
				), -- 4944
				Vec2( -- 4944
					self:sx(z.x0, w), -- 4944
					self:sy(z.y + z.h, h) -- 4944
				), -- 4944
				self:px(1), -- 4944
				line -- 4944
			) -- 4944
			draw:drawSegment( -- 4945
				Vec2( -- 4945
					self:sx(z.x1, w), -- 4945
					self:sy(z.y, h) -- 4945
				), -- 4945
				Vec2( -- 4945
					self:sx(z.x1, w), -- 4945
					self:sy(z.y + z.h, h) -- 4945
				), -- 4945
				self:px(1), -- 4945
				line -- 4945
			) -- 4945
			i = i + 1 -- 4929
		end -- 4929
	end -- 4929
end -- 4927
function Play.prototype.drawArch(self, draw, w, h) -- 4949
	local a = self.room.arch -- 4950
	if a.h <= 0 then -- 4950
		return -- 4952
	end -- 4952
	self:drawBox( -- 4954
		draw, -- 4954
		w, -- 4954
		h, -- 4954
		a.x0, -- 4954
		a.x1, -- 4954
		a.y, -- 4954
		a.y + a.h, -- 4954
		HOLE_FILL -- 4954
	) -- 4954
	draw:drawSegment( -- 4955
		Vec2( -- 4955
			self:sx(a.x0, w), -- 4955
			self:sy(a.y + a.h, h) -- 4955
		), -- 4955
		Vec2( -- 4955
			self:sx(a.x1, w), -- 4955
			self:sy(a.y + a.h, h) -- 4955
		), -- 4955
		self:px(1), -- 4955
		SOLID_EDGE -- 4955
	) -- 4955
	draw:drawSegment( -- 4956
		Vec2( -- 4956
			self:sx(a.x0, w), -- 4956
			self:sy(a.y, h) -- 4956
		), -- 4956
		Vec2( -- 4956
			self:sx(a.x0, w), -- 4956
			self:sy(a.y + a.h, h) -- 4956
		), -- 4956
		self:px(1), -- 4956
		SOLID_EDGE -- 4956
	) -- 4956
	draw:drawSegment( -- 4957
		Vec2( -- 4957
			self:sx(a.x1, w), -- 4957
			self:sy(a.y, h) -- 4957
		), -- 4957
		Vec2( -- 4957
			self:sx(a.x1, w), -- 4957
			self:sy(a.y + a.h, h) -- 4957
		), -- 4957
		self:px(1), -- 4957
		SOLID_EDGE -- 4957
	) -- 4957
end -- 4949
function Play.prototype.drawCart(self, draw, w, h) -- 4960
	local c = self.room.cart -- 4961
	if c.bodyW <= 0 then -- 4961
		return -- 4963
	end -- 4963
	drawCartShape( -- 4965
		draw, -- 4965
		self, -- 4965
		w, -- 4965
		h, -- 4965
		c, -- 4965
		self.cartAxle -- 4965
	) -- 4965
	draw:drawRect( -- 4966
		Rect( -- 4966
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 4966
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 4966
			self:px(2), -- 4966
			self:px(40) -- 4966
		), -- 4966
		STAND -- 4966
	) -- 4966
end -- 4960
function Play.prototype.drawActors(self, draw, w, h) -- 4969
	local p = self.player -- 4970
	local isChild = self.childMode -- 4971
	local footY = p.y + p.depth -- 4972
	if p.covered then -- 4972
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 4975
		draw:drawSegment( -- 4976
			Vec2( -- 4976
				self:sx(edge, w), -- 4976
				self:sy(footY + 8, h) -- 4976
			), -- 4976
			Vec2( -- 4976
				self:sx(edge, w), -- 4976
				self:sy(footY + p.h * 0.62, h) -- 4976
			), -- 4976
			self:px(2), -- 4976
			STAND -- 4976
		) -- 4976
		draw:drawSegment( -- 4978
			Vec2( -- 4978
				self:sx(p.x - 8, w), -- 4978
				self:sy(footY + p.h + 3, h) -- 4978
			), -- 4978
			Vec2( -- 4978
				self:sx(p.x + 8, w), -- 4978
				self:sy(footY + p.h + 3, h) -- 4978
			), -- 4978
			self:px(2), -- 4978
			STAND -- 4978
		) -- 4978
	elseif self.coverNear and not isChild then -- 4978
		draw:drawRect( -- 4981
			Rect( -- 4981
				self:sx(p.x - 3, w), -- 4981
				self:sy(footY + 1, h), -- 4981
				self:px(3), -- 4981
				self:px(3) -- 4981
			), -- 4981
			STAND -- 4981
		) -- 4981
	end -- 4981
	drawFigure( -- 4983
		draw, -- 4983
		self, -- 4983
		w, -- 4983
		h, -- 4983
		p, -- 4983
		isChild and CHILD_BODY or SOLDIER_BODY, -- 4983
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 4983
	) -- 4983
	local q = self.partner -- 4984
	if q.alive then -- 4984
		local childPartner = q.w == CHILD_W -- 4986
		drawFigure( -- 4987
			draw, -- 4987
			self, -- 4987
			w, -- 4987
			h, -- 4987
			q, -- 4987
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 4987
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 4987
		) -- 4987
	end -- 4987
	local i = 0 -- 4989
	do -- 4989
		i = 0 -- 4990
		while i < #self.enemies do -- 4990
			local e = self.enemies[i + 1] -- 4991
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 4992
			local enemyY = e.y + (e.depth or 0) -- 4993
			self:drawBox( -- 4994
				draw, -- 4994
				w, -- 4994
				h, -- 4994
				e.x - e.w / 2, -- 4994
				e.x + e.w / 2, -- 4994
				enemyY, -- 4994
				enemyY + e.h, -- 4994
				col -- 4994
			) -- 4994
			if e.alive then -- 4994
				local ef = p.x >= e.x and 1 or -1 -- 4996
				if e.kind == "shield" then -- 4996
					local sh = (e.shieldHp or 0) > 0 -- 4998
					draw:drawRect( -- 4999
						Rect( -- 4999
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 4999
							self:sy(enemyY, h), -- 4999
							self:px(6), -- 4999
							self:px(64) -- 4999
						), -- 4999
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 5000
					) -- 5000
				elseif e.kind == "breaker" then -- 5000
					draw:drawSegment( -- 5002
						Vec2( -- 5002
							self:sx(e.x + ef * 12, w), -- 5002
							self:sy(enemyY + 8, h) -- 5002
						), -- 5002
						Vec2( -- 5003
							self:sx(e.x + ef * 22, w), -- 5003
							self:sy(enemyY + 46, h) -- 5003
						), -- 5003
						self:px(3), -- 5003
						Color(0.5, 0.36, 0.22, 1) -- 5003
					) -- 5003
				end -- 5003
			end -- 5003
			if e.alive and e.warnT > 0 then -- 5003
				local gunX = self:sx(e.x, w) -- 5008
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 5009
				local aimX = self:sx(p.x, w) -- 5010
				local aimY = self:sy(footY + p.h * 0.55, h) -- 5011
				local seg = 8 -- 5012
				local s = 0 -- 5013
				do -- 5013
					s = 0 -- 5014
					while s < seg do -- 5014
						local t0 = s / seg -- 5015
						local t1 = (s + 1) / seg -- 5016
						draw:drawSegment( -- 5017
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 5018
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 5019
							self:px(1), -- 5020
							DANGER -- 5020
						) -- 5020
						s = s + 2 -- 5014
					end -- 5014
				end -- 5014
			end -- 5014
			i = i + 1 -- 4990
		end -- 4990
	end -- 4990
	local k = 0 -- 5025
	do -- 5025
		k = 0 -- 5026
		while k < #self.room.marks do -- 5026
			do -- 5026
				local m = self.room.marks[k + 1] -- 5027
				if m.kind ~= 0 then -- 5027
					goto __continue925 -- 5029
				end -- 5029
				local on = self.checkpoint == m.x -- 5031
				local x = self:sx(m.x, w) -- 5032
				local y = self:sy(m.y, h) -- 5033
				draw:drawSegment( -- 5034
					Vec2(x, y), -- 5034
					Vec2( -- 5034
						x, -- 5034
						y + self:px(35) -- 5034
					), -- 5034
					self:px(1), -- 5034
					on and CHECK or INK_DIM -- 5034
				) -- 5034
				draw:drawDot( -- 5035
					Vec2( -- 5035
						x, -- 5035
						y + self:px(35) -- 5035
					), -- 5035
					self:px(2), -- 5035
					on and CHECK or INK_DIM -- 5035
				) -- 5035
			end -- 5035
			::__continue925:: -- 5035
			k = k + 1 -- 5026
		end -- 5026
	end -- 5026
	local j = 0 -- 5039
	do -- 5039
		j = 0 -- 5040
		while j < #self.room.marks do -- 5040
			do -- 5040
				local m = self.room.marks[j + 1] -- 5041
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 5041
					goto __continue928 -- 5043
				end -- 5043
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 5043
					goto __continue928 -- 5047
				end -- 5047
				local col = STAND -- 5049
				if m.kind == 4 then -- 5049
					col = PASS_LINE -- 5051
				elseif m.kind == 5 then -- 5051
					col = BRICK_LINE -- 5053
				end -- 5053
				local mx = self:sx(m.x, w) -- 5055
				local my = self:sy(m.y, h) -- 5056
				draw:drawSegment( -- 5057
					Vec2(mx, my), -- 5057
					Vec2( -- 5057
						mx, -- 5057
						my + self:px(24) -- 5057
					), -- 5057
					self:px(1), -- 5057
					col -- 5057
				) -- 5057
			end -- 5057
			::__continue928:: -- 5057
			j = j + 1 -- 5040
		end -- 5040
	end -- 5040
	local t = 0 -- 5060
	do -- 5060
		t = 0 -- 5061
		while t < #self.room.marks do -- 5061
			do -- 5061
				local m = self.room.marks[t + 1] -- 5062
				if m.kind ~= 6 then -- 5062
					goto __continue934 -- 5064
				end -- 5064
				local mx = self:sx(m.x, w) -- 5066
				local my = self:sy(m.y, h) -- 5067
				draw:drawSegment( -- 5068
					Vec2(mx, my), -- 5068
					Vec2( -- 5068
						mx, -- 5068
						my + self:px(30) -- 5068
					), -- 5068
					self:px(1), -- 5068
					INK_DIM -- 5068
				) -- 5068
				self:drawBox( -- 5069
					draw, -- 5069
					w, -- 5069
					h, -- 5069
					m.x - 5, -- 5069
					m.x + 5, -- 5069
					m.y + 30, -- 5069
					m.y + 40, -- 5069
					CHECK -- 5069
				) -- 5069
			end -- 5069
			::__continue934:: -- 5069
			t = t + 1 -- 5061
		end -- 5061
	end -- 5061
	if self.room.key == "village" then -- 5061
		self:drawVillage(draw, w, h) -- 5072
	end -- 5072
	if self.room.key == "forest" then -- 5072
		self:drawDog(draw, w, h) -- 5075
	end -- 5075
end -- 4969
function Play.prototype.drawDog(self, draw, w, h) -- 5080
	local x = self.dogX -- 5081
	self:drawBox( -- 5082
		draw, -- 5082
		w, -- 5082
		h, -- 5082
		x - 14, -- 5082
		x + 14, -- 5082
		0, -- 5082
		20, -- 5082
		SCAV_BODY -- 5082
	) -- 5082
	self:drawBox( -- 5083
		draw, -- 5083
		w, -- 5083
		h, -- 5083
		x - 10, -- 5083
		x - 2, -- 5083
		20, -- 5083
		30, -- 5083
		SCAV_BODY -- 5083
	) -- 5083
	self:drawBox( -- 5084
		draw, -- 5084
		w, -- 5084
		h, -- 5084
		x + 2, -- 5084
		x + 10, -- 5084
		20, -- 5084
		30, -- 5084
		SCAV_HEAD -- 5084
	) -- 5084
	if self.dogState == "ear" or self.dogState == "chase" then -- 5084
		draw:drawSegment( -- 5086
			Vec2( -- 5086
				self:sx(x, w), -- 5086
				self:sy(30, h) -- 5086
			), -- 5086
			Vec2( -- 5087
				self:sx(x, w), -- 5087
				self:sy(40, h) -- 5087
			), -- 5087
			self:px(1), -- 5087
			DANGER -- 5087
		) -- 5087
	end -- 5087
end -- 5080
function Play.prototype.drawVillage(self, draw, w, h) -- 5092
	local bottle = self.room.bottle -- 5093
	if bottle ~= nil then -- 5093
		self:drawBox( -- 5095
			draw, -- 5095
			w, -- 5095
			h, -- 5095
			bottle.x - 14, -- 5095
			bottle.x + 14, -- 5095
			0, -- 5095
			64, -- 5095
			SOLID_FILL -- 5095
		) -- 5095
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 5095
			self:drawBottle( -- 5097
				draw, -- 5097
				w, -- 5097
				h, -- 5097
				bottle.x, -- 5097
				64 -- 5097
			) -- 5097
		end -- 5097
	end -- 5097
	self:drawBox( -- 5101
		draw, -- 5101
		w, -- 5101
		h, -- 5101
		300, -- 5101
		420, -- 5101
		44, -- 5101
		50, -- 5101
		FLOOR_DECK -- 5101
	) -- 5101
	self:drawBox( -- 5102
		draw, -- 5102
		w, -- 5102
		h, -- 5102
		300, -- 5102
		306, -- 5102
		0, -- 5102
		44, -- 5102
		FLOOR_DECK -- 5102
	) -- 5102
	self:drawBox( -- 5103
		draw, -- 5103
		w, -- 5103
		h, -- 5103
		414, -- 5103
		420, -- 5103
		0, -- 5103
		44, -- 5103
		FLOOR_DECK -- 5103
	) -- 5103
	local s = self.room.scavenger -- 5105
	if s ~= nil then -- 5105
		local sx0 = self.scavX -- 5107
		self:drawBox( -- 5108
			draw, -- 5108
			w, -- 5108
			h, -- 5108
			sx0 - 12, -- 5108
			sx0 + 12, -- 5108
			0, -- 5108
			s.h - 14, -- 5108
			SCAV_BODY -- 5108
		) -- 5108
		self:drawBox( -- 5109
			draw, -- 5109
			w, -- 5109
			h, -- 5109
			sx0 - 7, -- 5109
			sx0 + 7, -- 5109
			s.h - 14, -- 5109
			s.h, -- 5109
			SCAV_HEAD -- 5109
		) -- 5109
		if self.scavState == "turn" then -- 5109
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 5111
			draw:drawSegment( -- 5112
				Vec2( -- 5112
					self:sx(sx0, w), -- 5112
					self:sy(s.h - 6, h) -- 5112
				), -- 5112
				Vec2( -- 5112
					self:sx(fx, w), -- 5112
					self:sy(s.h - 6, h) -- 5112
				), -- 5112
				self:px(1), -- 5112
				INK -- 5112
			) -- 5112
		end -- 5112
	end -- 5112
	if self.hasBottle then -- 5112
		local p = self.player -- 5117
		self:drawBottle( -- 5118
			draw, -- 5118
			w, -- 5118
			h, -- 5118
			p.x + p.facing * 10, -- 5118
			p.y + p.h * 0.62 -- 5118
		) -- 5118
	end -- 5118
	if self.bottleFly ~= nil then -- 5118
		self:drawBottle( -- 5121
			draw, -- 5121
			w, -- 5121
			h, -- 5121
			self.bottleFly.x, -- 5121
			self.bottleFly.y -- 5121
		) -- 5121
	end -- 5121
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 5121
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 5124
		draw:drawCircle( -- 5125
			Vec2( -- 5125
				self:sx(self.bottleLandX, w), -- 5125
				self:sy(0, h) -- 5125
			), -- 5125
			self:px(r / ____exports.UNITS_PER_PX), -- 5125
			BRICK_LINE -- 5125
		) -- 5125
	end -- 5125
end -- 5092
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 5129
	self:drawBox( -- 5130
		draw, -- 5130
		w, -- 5130
		h, -- 5130
		x - 3, -- 5130
		x + 3, -- 5130
		y - 10, -- 5130
		y, -- 5130
		BOTTLE -- 5130
	) -- 5130
end -- 5129
function Play.prototype.drawTrace(self, draw, w, h) -- 5133
	local t = self.trace -- 5134
	if t == nil or self.traceT <= 0 then -- 5134
		return -- 5136
	end -- 5136
	draw:drawSegment( -- 5138
		Vec2( -- 5139
			self:sx(t.x0, w), -- 5139
			self:sy(t.y0, h) -- 5139
		), -- 5139
		Vec2( -- 5140
			self:sx(t.x1, w), -- 5140
			self:sy(t.y1, h) -- 5140
		), -- 5140
		self:px(1), -- 5141
		t.hit and AIM_HIT or INK_DIM -- 5141
	) -- 5141
end -- 5133
function Play.prototype.drawAim(self, draw, w, h) -- 5144
	local v = self.view -- 5146
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 5147
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 5148
	local dot = self:px(1) -- 5149
	local arm = self:px(3) -- 5150
	local gap = self:px(1) -- 5151
	draw:drawSegment( -- 5152
		Vec2(gx - arm - gap, gy), -- 5152
		Vec2(gx - gap, gy), -- 5152
		dot / 2, -- 5152
		AIM -- 5152
	) -- 5152
	draw:drawSegment( -- 5153
		Vec2(gx + gap, gy), -- 5153
		Vec2(gx + arm + gap, gy), -- 5153
		dot / 2, -- 5153
		AIM -- 5153
	) -- 5153
	draw:drawSegment( -- 5154
		Vec2(gx, gy - arm - gap), -- 5154
		Vec2(gx, gy - gap), -- 5154
		dot / 2, -- 5154
		AIM -- 5154
	) -- 5154
	draw:drawSegment( -- 5155
		Vec2(gx, gy + gap), -- 5155
		Vec2(gx, gy + arm + gap), -- 5155
		dot / 2, -- 5155
		AIM -- 5155
	) -- 5155
	if self.room.key == "village" and self.hasBottle then -- 5155
		local p = self.player -- 5159
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 5161
		local dir = ____end.x >= p.x and 1 or -1 -- 5162
		local x0 = p.x + dir * 10 -- 5163
		local y0 = p.y + p.h * 0.7 -- 5164
		local T = BOTTLE_FLY_TIME -- 5165
		local vx = (____end.x - x0) / T -- 5166
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 5167
		local pxr = x0 -- 5168
		local pyr = y0 -- 5169
		local t = 1 -- 5170
		do -- 5170
			t = 1 -- 5171
			while t <= 12 do -- 5171
				local tt = t / 12 * T -- 5172
				local nx = x0 + vx * tt -- 5173
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 5174
				draw:drawSegment( -- 5175
					Vec2( -- 5175
						self:sx(pxr, w), -- 5175
						self:sy(pyr, h) -- 5175
					), -- 5175
					Vec2( -- 5175
						self:sx(nx, w), -- 5175
						self:sy(ny, h) -- 5175
					), -- 5175
					self:px(1) / 2, -- 5175
					BOTTLE -- 5175
				) -- 5175
				pxr = nx -- 5176
				pyr = ny -- 5177
				t = t + 1 -- 5171
			end -- 5171
		end -- 5171
		draw:drawCircle( -- 5179
			Vec2( -- 5179
				self:sx(____end.x, w), -- 5179
				self:sy(____end.y + 2, h) -- 5179
			), -- 5179
			self:px(2), -- 5179
			BOTTLE -- 5179
		) -- 5179
	end -- 5179
end -- 5144
return ____exports -- 5144