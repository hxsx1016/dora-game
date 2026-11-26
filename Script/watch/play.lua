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
local CRAFT_RECIPES = ____craft.CRAFT_RECIPES -- 29
local findRecipe = ____craft.findRecipe -- 29
local missingMaterials = ____craft.missingMaterials -- 29
local payMaterials = ____craft.payMaterials -- 29
local weaponEffectOf = ____craft.weaponEffectOf -- 29
local weaponNameOf = ____craft.weaponNameOf -- 29
function makeActor(room, index) -- 5211
	local sp = room.spawns -- 5212
	if index < 0 or index >= #sp then -- 5212
		return { -- 5214
			x = 0, -- 5214
			y = 0, -- 5214
			depth = 0, -- 5214
			depthSpeed = 0, -- 5214
			vx = 0, -- 5214
			vy = 0, -- 5214
			w = CHILD_W, -- 5214
			h = CHILD_H, -- 5214
			onGround = true, -- 5214
			facing = 1, -- 5214
			crouch = false, -- 5214
			rollT = 0, -- 5214
			covered = false, -- 5214
			alive = false -- 5214
		} -- 5214
	end -- 5214
	local s = sp[index + 1] -- 5216
	local child = s.h < SOLDIER_H -- 5217
	local ground = room.depth -- 5218
	local depth = ground == nil and 0 or math.max( -- 5219
		ground.min, -- 5219
		math.min(ground.max, s.depth or 0) -- 5219
	) -- 5219
	return { -- 5220
		x = s.x, -- 5221
		y = s.y, -- 5221
		depth = depth, -- 5221
		depthSpeed = 0, -- 5221
		vx = 0, -- 5221
		vy = 0, -- 5221
		w = child and CHILD_W or SOLDIER_W, -- 5222
		h = child and CHILD_H or SOLDIER_H, -- 5223
		onGround = true, -- 5224
		facing = 1, -- 5224
		crouch = false, -- 5224
		rollT = 0, -- 5224
		covered = false, -- 5224
		alive = true -- 5224
	} -- 5224
end -- 5224
function drawFigure(draw, play, w, h, a, body, head) -- 5228
	if not a.alive then -- 5228
		return -- 5230
	end -- 5230
	local x0 = a.x - a.w / 2 -- 5232
	local x1 = a.x + a.w / 2 -- 5233
	local y0 = a.y + a.depth * DEPTH_Y_SCALE -- 5234
	local y1 = y0 + a.h -- 5235
	play:drawBox( -- 5236
		draw, -- 5236
		w, -- 5236
		h, -- 5236
		x0, -- 5236
		x1, -- 5236
		y0, -- 5236
		y1 - a.h * 0.26, -- 5236
		body -- 5236
	) -- 5236
	play:drawBox( -- 5237
		draw, -- 5237
		w, -- 5237
		h, -- 5237
		x0 + 2, -- 5237
		x1 - 2, -- 5237
		y1 - a.h * 0.26, -- 5237
		y1, -- 5237
		head -- 5237
	) -- 5237
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 5239
	play:drawBox( -- 5240
		draw, -- 5240
		w, -- 5240
		h, -- 5240
		eyeX, -- 5240
		eyeX + 4, -- 5240
		y1 - a.h * 0.14, -- 5240
		y1 - a.h * 0.08, -- 5240
		INK -- 5240
	) -- 5240
end -- 5240
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5244
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5245
end -- 5244
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5252
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5253
end -- 5252
function rayInterval(origin, direction, min, max) -- 5260
	if direction == 0 then -- 5260
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5262
	end -- 5262
	local a = (min - origin) / direction -- 5264
	local b = (max - origin) / direction -- 5265
	return { -- 5266
		min = math.min(a, b), -- 5266
		max = math.max(a, b) -- 5266
	} -- 5266
end -- 5266
function hitBox(ray, box) -- 5270
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5271
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5272
	local enter = math.max(0, x.min, y.min) -- 5273
	local leave = math.min(99999, x.max, y.max) -- 5274
	if box.depth ~= nil then -- 5274
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5276
		enter = math.max(enter, depth.min) -- 5277
		leave = math.min(leave, depth.max) -- 5278
	end -- 5278
	return leave >= enter and enter or -1 -- 5280
end -- 5280
function drawCartShape(draw, play, w, h, c, axleX) -- 5283
	local half = c.bodyW / 2 -- 5284
	local x0 = axleX - half -- 5285
	local x1 = axleX + half -- 5286
	local axleY = c.baseY + (c.depth or 0) * DEPTH_Y_SCALE + c.wheelR -- 5287
	play:drawBox( -- 5288
		draw, -- 5288
		w, -- 5288
		h, -- 5288
		x0, -- 5288
		x1, -- 5288
		axleY, -- 5288
		axleY + c.bodyH, -- 5288
		CART_FILL -- 5288
	) -- 5288
	draw:drawCircle( -- 5289
		Vec2( -- 5289
			play:sx(x0 + c.bodyW * 0.28, w), -- 5289
			play:sy(axleY, h) -- 5289
		), -- 5289
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5289
		Color(52, 50, 48, 255) -- 5289
	) -- 5289
	draw:drawCircle( -- 5290
		Vec2( -- 5290
			play:sx(x1 - c.bodyW * 0.28, w), -- 5290
			play:sy(axleY, h) -- 5290
		), -- 5290
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5290
		Color(52, 50, 48, 255) -- 5290
	) -- 5290
	local cx = c.clothSide < 0 and x0 or x1 -- 5291
	play:drawBox( -- 5292
		draw, -- 5292
		w, -- 5292
		h, -- 5292
		cx - 10, -- 5292
		cx + 10, -- 5292
		axleY + c.bodyH, -- 5292
		axleY + c.bodyH + 18, -- 5292
		CLOTH -- 5292
	) -- 5292
end -- 5292
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
CHILD_H = 56 -- 123
local CHILD_CROUCH_H = 34 -- 124
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
					local ____self_boxes_17 = self.boxes -- 1032
					local ____temp_15 = x0 + stepW -- 1033
					local ____temp_16 = -8 -- 1033
					local ____temp_14 -- 1034
					if room.depth == nil then -- 1034
						____temp_14 = nil -- 1034
					else -- 1034
						____temp_14 = st.depth -- 1034
					end -- 1034
					____self_boxes_17[#____self_boxes_17 + 1] = { -- 1032
						x0 = x0, -- 1033
						x1 = ____temp_15, -- 1033
						y0 = ____temp_16, -- 1033
						y1 = y, -- 1033
						depth = ____temp_14, -- 1034
						passable = true -- 1035
					} -- 1035
					k = k + 1 -- 1027
				end -- 1027
			end -- 1027
			i = i + 1 -- 1022
		end -- 1022
	end -- 1022
end -- 996
function Play.prototype.setupCampaign(self) -- 1045
	local wr = self.room -- 1046
	local c = wr.campaign -- 1047
	if c == nil then -- 1047
		return -- 1049
	end -- 1049
	self.roomStartTick = self.run.ticks -- 1051
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1051
		self.run.joined = true -- 1055
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1055
		local ____self_run_19 = self.run -- 1058
		local ____temp_18 -- 1058
		if wr.key == "s2-drygoods" then -- 1058
			____temp_18 = self.run.route ~= "drygoods" -- 1058
		else -- 1058
			____temp_18 = false -- 1058
		end -- 1058
		____self_run_19.joined = ____temp_18 -- 1058
	end -- 1058
	local x = wr.minX + 60 -- 1060
	local y = 0 -- 1061
	local depth = 0 -- 1062
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1062
		x = wr.minX + 210 -- 1064
		depth = -32 -- 1065
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1065
		x = wr.minX + 40 -- 1067
		y = 32 -- 1068
		depth = 32 -- 1069
	end -- 1069
	self.player = { -- 1071
		x = x, -- 1072
		y = y, -- 1072
		depth = depth, -- 1072
		depthSpeed = 0, -- 1072
		vx = 0, -- 1072
		vy = 0, -- 1072
		w = SOLDIER_W, -- 1073
		h = SOLDIER_H, -- 1073
		onGround = y <= 0, -- 1073
		facing = 1, -- 1073
		crouch = false, -- 1073
		rollT = 0, -- 1073
		covered = false, -- 1073
		alive = true -- 1073
	} -- 1073
	self.partner = { -- 1075
		x = x + 60, -- 1076
		y = y, -- 1076
		depth = depth, -- 1076
		depthSpeed = 0, -- 1076
		vx = 0, -- 1076
		vy = 0, -- 1076
		w = CHILD_W, -- 1077
		h = CHILD_H, -- 1077
		onGround = y <= 0, -- 1077
		facing = 1, -- 1077
		crouch = false, -- 1077
		rollT = 0, -- 1077
		covered = false, -- 1077
		alive = true -- 1077
	} -- 1077
	self.cam.x = x -- 1079
	self.cam.y = y + CAM_LOOK_UP -- 1080
	self.phase = "run" -- 1081
	self.hp = self.maxHp -- 1082
	local trial = self.run.trial -- 1083
	if trial ~= nil then -- 1083
		draftRoom(trial, wr.key) -- 1085
		self.maxHp = self.maxHp + trial.ranks.vitality -- 1086
		self.hp = trial.hp -- 1087
	end -- 1087
	self:buildEnemies() -- 1089
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1090
	local i = 0 -- 1091
	do -- 1091
		i = 0 -- 1092
		while i < #self.boxes do -- 1092
			do -- 1092
				local b = self.boxes[i + 1] -- 1093
				if b.id == nil then -- 1093
					goto __continue90 -- 1095
				end -- 1095
				local st = self.run.props[b.id] -- 1097
				if st ~= nil then -- 1097
					b.broken = st.broken -- 1099
					local ____temp_20 -- 1100
					if b.breakable == nil then -- 1100
						____temp_20 = nil -- 1100
					else -- 1100
						____temp_20 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1100
					end -- 1100
					b.breakable = ____temp_20 -- 1100
					b.hidden = b.hidden == true and st.revealed ~= true -- 1101
					if b.hidden then -- 1101
						b.broken = true -- 1103
					end -- 1103
				elseif b.hidden == true then -- 1103
					b.broken = true -- 1107
				end -- 1107
			end -- 1107
			::__continue90:: -- 1107
			i = i + 1 -- 1092
		end -- 1092
	end -- 1092
	if wr.cart.bodyW > 0 then -- 1092
		self.cartAxle = wr.cart.startX -- 1111
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1111
			self.cartAxle = wr.cart.endX -- 1113
			self.cartDocked = true -- 1114
		end -- 1114
	end -- 1114
	do -- 1114
		i = 0 -- 1117
		while i < #self.pickups do -- 1117
			local pk = self.pickups[i + 1] -- 1118
			if self.run.taken[pk.id] == true then -- 1118
				pk.id = "" -- 1120
			end -- 1120
			i = i + 1 -- 1117
		end -- 1117
	end -- 1117
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1123
end -- 1045
function Play.prototype.log(self, line) -- 1126
	local ____self_run_log_21 = self.run.log -- 1126
	____self_run_log_21[#____self_run_log_21 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1127
	if #self.run.log > 120 then -- 1127
		table.remove(self.run.log, 1) -- 1129
	end -- 1129
end -- 1126
function Play.prototype.buildEnemies(self) -- 1133
	self.enemies = {} -- 1134
	if self.isCampaign then -- 1134
		local i = 0 -- 1136
		do -- 1136
			i = 0 -- 1137
			while i < #self.room.spawns do -- 1137
				local sp = self.room.spawns[i + 1] -- 1138
				local kind = sp.kind or "gunner" -- 1139
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1140
				local ____self_enemies_22 = self.enemies -- 1140
				____self_enemies_22[#____self_enemies_22 + 1] = { -- 1141
					x = sp.x, -- 1142
					y = sp.y, -- 1142
					depth = sp.depth, -- 1142
					w = 26, -- 1142
					h = sp.h, -- 1142
					alive = true, -- 1142
					hitT = 0, -- 1142
					warnT = 0, -- 1142
					fireCd = 40, -- 1142
					kind = kind, -- 1143
					shieldHp = hp, -- 1143
					shieldHpMax = hp, -- 1143
					drop = sp.drop or "none", -- 1143
					homeX = sp.x, -- 1144
					swingT = 0, -- 1144
					awake = false, -- 1144
					squad = i -- 1144
				} -- 1144
				i = i + 1 -- 1137
			end -- 1137
		end -- 1137
		return -- 1147
	end -- 1147
	if self.room.key == "checkpoint" then -- 1147
		local ____self_enemies_23 = self.enemies -- 1147
		____self_enemies_23[#____self_enemies_23 + 1] = { -- 1150
			x = self.ox + 430, -- 1150
			y = 0, -- 1150
			w = 26, -- 1150
			h = 84, -- 1150
			alive = true, -- 1150
			hitT = 0, -- 1150
			warnT = 0, -- 1150
			fireCd = 0 -- 1150
		} -- 1150
		local ____self_enemies_24 = self.enemies -- 1150
		____self_enemies_24[#____self_enemies_24 + 1] = { -- 1151
			x = self.ox + 505, -- 1151
			y = 0, -- 1151
			w = 26, -- 1151
			h = 84, -- 1151
			alive = true, -- 1151
			hitT = 0, -- 1151
			warnT = 0, -- 1151
			fireCd = 0 -- 1151
		} -- 1151
		return -- 1152
	end -- 1152
	if self.room.key == "street" then -- 1152
		local ____self_enemies_25 = self.enemies -- 1152
		____self_enemies_25[#____self_enemies_25 + 1] = { -- 1156
			x = self.ox + 340, -- 1156
			y = 0, -- 1156
			w = 26, -- 1156
			h = 84, -- 1156
			alive = true, -- 1156
			hitT = 0, -- 1156
			warnT = 0, -- 1156
			fireCd = 0 -- 1156
		} -- 1156
		local ____self_enemies_26 = self.enemies -- 1156
		____self_enemies_26[#____self_enemies_26 + 1] = { -- 1157
			x = self.ox + 560, -- 1157
			y = 0, -- 1157
			w = 26, -- 1157
			h = 84, -- 1157
			alive = true, -- 1157
			hitT = 0, -- 1157
			warnT = 0, -- 1157
			fireCd = 0 -- 1157
		} -- 1157
	end -- 1157
end -- 1133
function Play.prototype.emit(self, name, data) -- 1163
	local ____self_events_27 = self.events -- 1163
	____self_events_27[#____self_events_27 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1164
	self.eventSeq = self.eventSeq + 1 -- 1165
	if #self.events > 256 then -- 1165
		table.remove(self.events, 1) -- 1167
	end -- 1167
end -- 1163
function Play.prototype.drainEvents(self) -- 1175
	local out = self.events -- 1176
	self.events = {} -- 1177
	return out -- 1178
end -- 1175
function Play.prototype.adoptEvents(self, events) -- 1187
	if #events == 0 then -- 1187
		return -- 1189
	end -- 1189
	local keep = {} -- 1191
	local i = 0 -- 1192
	do -- 1192
		i = 0 -- 1193
		while i < #events do -- 1193
			do -- 1193
				local e = events[i + 1] -- 1194
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1194
					goto __continue114 -- 1196
				end -- 1196
				keep[#keep + 1] = e -- 1198
			end -- 1198
			::__continue114:: -- 1198
			i = i + 1 -- 1193
		end -- 1193
	end -- 1193
	if #keep == 0 then -- 1193
		return -- 1201
	end -- 1201
	self.events = __TS__ArrayConcat(keep, self.events) -- 1203
	do -- 1203
		i = 0 -- 1204
		while i < #self.events do -- 1204
			self.events[i + 1].seq = i -- 1205
			i = i + 1 -- 1204
		end -- 1204
	end -- 1204
	self.eventSeq = #self.events -- 1207
end -- 1187
function Play.prototype.chooseTalent(self, slot) -- 1210
	local trial = self.run.trial -- 1211
	local talent = trial and trial.offers[slot + 1] -- 1212
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 1212
		return -- 1213
	end -- 1213
	local ____trial_ranks_30, ____talent_31 = trial.ranks, talent -- 1213
	____trial_ranks_30[____talent_31] = ____trial_ranks_30[____talent_31] + 1 -- 1214
	trial.offers = {} -- 1215
	if talent == "vitality" then -- 1215
		self.maxHp = self.maxHp + 1 -- 1217
		self.hp = self.hp + 1 -- 1218
		trial.hp = self.hp -- 1219
	end -- 1219
	self:flashSet(talentNames[talent], 1.2) -- 1221
end -- 1210
function Play.prototype.beginReload(self) -- 1229
	self.reloadT = self:reloadTicks() -- 1230
	local camp = self.room.campaign -- 1231
	if self.run.trial == nil and camp ~= nil and camp.reloadPuzzle == true then -- 1231
		self:openReloadPuzzle() -- 1234
	end -- 1234
end -- 1229
function Play.prototype.openReloadPuzzle(self) -- 1239
	self.reloadOpen = true -- 1240
	self.reloadAnswerTicks = 0 -- 1241
	self.reloadWorldTicks = 0 -- 1242
	self.reloadPath = {RELOAD_START} -- 1243
	self.reloadPendingEffect = "" -- 1244
	self.reloadTryCount = self.reloadTryCount + 1 -- 1245
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 1246
end -- 1239
function Play.prototype.closeReloadPuzzle(self) -- 1250
	self.reloadOpen = false -- 1251
	self.reloadAnswerTicks = 0 -- 1252
	self.reloadWorldTicks = 0 -- 1253
	self.reloadPath = {RELOAD_START} -- 1254
	self.reloadPendingEffect = "" -- 1255
end -- 1250
function Play.prototype.reloadTapNode(self, node) -- 1262
	if not self.reloadOpen then -- 1262
		return -- 1264
	end -- 1264
	local path = self.reloadPath -- 1266
	local last = path[#path] -- 1267
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1267
		self.reloadPath = {RELOAD_START} -- 1269
		self:emit("reloadInvalid", {node = node, at = last}) -- 1270
		return -- 1271
	end -- 1271
	path[#path + 1] = node -- 1273
	if node ~= RELOAD_TARGET then -- 1273
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1275
		return -- 1276
	end -- 1276
	if not reloadPathValid(path) then -- 1276
		self.reloadPath = {RELOAD_START} -- 1279
		self:emit("reloadInvalid", {node = node, at = last}) -- 1280
		return -- 1281
	end -- 1281
	self.reloadPendingEffect = reloadEffectOf(path) -- 1283
	self.reloadOpen = false -- 1284
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1285
	self:flashSet( -- 1288
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1288
		1.4 -- 1288
	) -- 1288
end -- 1262
function Play.prototype.consumeReloadEffect(self) -- 1292
	local e = self.reloadPendingEffect -- 1293
	if e ~= "" then -- 1293
		self.reloadPendingEffect = "" -- 1295
	end -- 1295
	return e -- 1297
end -- 1292
function Play.prototype.echoToSource(self, from, count) -- 1304
	if count == nil then -- 1304
		count = 1 -- 1304
	end -- 1304
	local best = -1 -- 1305
	local bestD = 1000000000 -- 1306
	local i = 0 -- 1307
	local woken = {} -- 1308
	local n = 0 -- 1309
	while n < count do -- 1309
		best = -1 -- 1311
		bestD = 1000000000 -- 1312
		do -- 1312
			i = 0 -- 1313
			while i < #self.enemies do -- 1313
				do -- 1313
					if woken[i] == true then -- 1313
						goto __continue136 -- 1315
					end -- 1315
					local e = self.enemies[i + 1] -- 1317
					if not e.alive then -- 1317
						goto __continue136 -- 1319
					end -- 1319
					local d = math.abs(e.x - from.x) -- 1321
					if d < bestD then -- 1321
						bestD = d -- 1323
						best = i -- 1324
					end -- 1324
				end -- 1324
				::__continue136:: -- 1324
				i = i + 1 -- 1313
			end -- 1313
		end -- 1313
		if best < 0 then -- 1313
			break -- 1328
		end -- 1328
		woken[best] = true -- 1330
		local e = self.enemies[best + 1] -- 1331
		e.awake = true -- 1332
		e.warnT = 0 -- 1333
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1334
		n = n + 1 -- 1335
	end -- 1335
	if n == 0 then -- 1335
		return -- 1338
	end -- 1338
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1340
end -- 1304
function Play.prototype.reloadTicks(self) -- 1343
	local ____temp_34 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 1344
	local ____opt_32 = self.run.trial -- 1344
	return math.max(6, ____temp_34 - 6 * (____opt_32 and ____opt_32.ranks.reload or 0)) -- 1344
end -- 1343
function Play.prototype.update(self, dt, input) -- 1347
	self:syncCraftBench() -- 1348
	local trial = self.run.trial -- 1349
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1349
		return -- 1350
	end -- 1350
	if input.pause.pressed then -- 1350
		self.paused = not self.paused -- 1352
	end -- 1352
	if self.flashT > 0 then -- 1352
		self.flashT = self.flashT - dt -- 1355
		if self.flashT <= 0 then -- 1355
			self.flash = "" -- 1357
		end -- 1357
	end -- 1357
	if self.traceT > 0 then -- 1357
		self.traceT = self.traceT - dt -- 1361
		if self.traceT <= 0 then -- 1361
			self.trace = nil -- 1363
		end -- 1363
	end -- 1363
	if self.paused then -- 1363
		self:updateCamera(dt) -- 1367
		return -- 1368
	end -- 1368
	if self.craftBench.active then -- 1368
		if input.interact.pressed or input.pause.pressed then -- 1368
			self:closeCraftBench() -- 1374
		end -- 1374
		self:updateCamera(dt) -- 1376
		return -- 1377
	end -- 1377
	if self.reloadOpen then -- 1377
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1383
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1383
			self.reloadOpen = false -- 1385
			self.reloadPendingEffect = "" -- 1386
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1387
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1388
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1388
			self:updateCamera(dt) -- 1390
			return -- 1391
		else -- 1391
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1393
		end -- 1393
	end -- 1393
	self.ticks = self.ticks + 1 -- 1397
	if self.invulnT > 0 then -- 1397
		self.invulnT = self.invulnT - 1 -- 1401
	end -- 1401
	if self.isCampaign then -- 1401
		local ____self_run_35, ____ticks_36 = self.run, "ticks" -- 1401
		____self_run_35[____ticks_36] = ____self_run_35[____ticks_36] + 1 -- 1404
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1405
	end -- 1405
	local p = self.player -- 1407
	self:stepPlayer(p, dt, input) -- 1408
	self:refreshCover(p, input) -- 1410
	if self.carryOn then -- 1410
		self:carryPose() -- 1412
	end -- 1412
	if self.isCampaign then -- 1412
		self:stepCampaign(dt, input) -- 1415
		if not self.carryOn then -- 1415
			self:stepCampaignPartner(dt) -- 1417
		end -- 1417
	end -- 1417
	if trial == nil or not self.run.finished then -- 1417
		self:stepEnemies(dt, input) -- 1425
	end -- 1425
	if trial ~= nil then -- 1425
		trial.hp = self.hp -- 1427
	end -- 1427
	if not self.isCampaign then -- 1427
		self:stepStory(dt, input) -- 1429
		self:stepEscort(dt, input) -- 1430
		self:stepVillage(dt, input) -- 1431
		self:stepChase(dt, input) -- 1432
		self:stepInteract(dt, input) -- 1433
	end -- 1433
	self:updateGate() -- 1435
	self:updateCamera(dt) -- 1436
	self:syncStory() -- 1438
end -- 1347
function Play.prototype.underLowArch(self, a) -- 1445
	local arch = self.room.arch -- 1446
	if arch.h <= 0 then -- 1446
		return false -- 1448
	end -- 1448
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1448
		return false -- 1451
	end -- 1451
	local top = arch.y + arch.h -- 1453
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1454
end -- 1445
function Play.prototype.coverAt(self, a) -- 1461
	local best = nil -- 1462
	local bestGap = 24 -- 1463
	local half = a.w / 2 -- 1464
	local i = 0 -- 1465
	do -- 1465
		i = 0 -- 1466
		while i < #self.boxes do -- 1466
			do -- 1466
				local b = self.boxes[i + 1] -- 1467
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1467
					goto __continue170 -- 1469
				end -- 1469
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1469
					goto __continue170 -- 1472
				end -- 1472
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1474
				if gap < bestGap then -- 1474
					bestGap = gap -- 1476
					best = b -- 1477
				end -- 1477
			end -- 1477
			::__continue170:: -- 1477
			i = i + 1 -- 1466
		end -- 1466
	end -- 1466
	return best -- 1480
end -- 1461
function Play.prototype.nearCover(self, a) -- 1483
	return self:coverAt(a) ~= nil -- 1484
end -- 1483
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1488
	if enemy == nil then -- 1488
		return false -- 1490
	end -- 1490
	local fromRight = enemy.x >= a.x -- 1492
	local edge = fromRight and b.x0 or b.x1 -- 1493
	local ____fromRight_37 -- 1494
	if fromRight then -- 1494
		____fromRight_37 = edge >= a.x - 0.001 and edge <= enemy.x -- 1494
	else -- 1494
		____fromRight_37 = edge <= a.x + 0.001 and edge >= enemy.x -- 1495
	end -- 1495
	local between = ____fromRight_37 -- 1494
	local separation = enemy.x - a.x -- 1496
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1497
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1498
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1499
end -- 1488
function Play.prototype.nearestEnemy(self, a) -- 1502
	local best -- 1503
	local bestD = 1000000000 -- 1504
	local i = 0 -- 1505
	do -- 1505
		i = 0 -- 1506
		while i < #self.enemies do -- 1506
			do -- 1506
				local e = self.enemies[i + 1] -- 1507
				if not e.alive then -- 1507
					goto __continue179 -- 1509
				end -- 1509
				local d = math.abs(e.x - a.x) -- 1511
				if d < bestD then -- 1511
					bestD = d -- 1513
					best = e -- 1514
				end -- 1514
			end -- 1514
			::__continue179:: -- 1514
			i = i + 1 -- 1506
		end -- 1506
	end -- 1506
	return best -- 1517
end -- 1502
function Play.prototype.refreshCover(self, a, input) -- 1521
	if self.childMode then -- 1521
		self.coverNear = false -- 1523
		self.coverHug = false -- 1524
		self.coverEntity = "" -- 1525
		self.coverBlocking = false -- 1526
		a.covered = false -- 1527
		return -- 1528
	end -- 1528
	local b = self:coverAt(a) -- 1530
	self.coverNear = b ~= nil -- 1531
	a.covered = self.coverNear and input.cover.held -- 1532
	self.coverHug = a.covered -- 1533
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1534
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1535
		b, -- 1535
		a, -- 1535
		self:nearestEnemy(a) -- 1535
	) -- 1535
end -- 1521
function Play.prototype.cartHandleInReach(self, a) -- 1539
	if a == nil then -- 1539
		a = self.player -- 1539
	end -- 1539
	local c = self.room.cart -- 1540
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1540
		return false -- 1542
	end -- 1542
	local handleX = self.cartAxle + c.handleOffset -- 1544
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1545
end -- 1539
function Play.prototype.nearLowLedge(self, a) -- 1550
	local reach = 26 -- 1551
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1552
	local x1 = x0 + reach -- 1553
	local i = 0 -- 1554
	do -- 1554
		i = 0 -- 1555
		while i < #self.boxes do -- 1555
			do -- 1555
				local b = self.boxes[i + 1] -- 1556
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1556
					goto __continue188 -- 1558
				end -- 1558
				local rise = b.y1 - a.y -- 1560
				if rise > 0 and rise <= LEDGE_RISE then -- 1560
					return true -- 1562
				end -- 1562
			end -- 1562
			::__continue188:: -- 1562
			i = i + 1 -- 1555
		end -- 1555
	end -- 1555
	return false -- 1565
end -- 1550
function Play.prototype.stepPlayer(self, a, dt, input) -- 1568
	a.depthSpeed = 0 -- 1569
	if not a.alive then -- 1569
		return -- 1571
	end -- 1571
	local isChild = self.childMode -- 1573
	local lowArch = isChild and self:underLowArch(a) -- 1575
	if self:storyLocked() then -- 1575
		a.vx = 0 -- 1578
		a.crouch = isChild and lowArch -- 1579
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1580
		self:fallY(a, dt) -- 1581
		return -- 1582
	end -- 1582
	if not isChild and self.escort.state == "calming" then -- 1582
		a.crouch = false -- 1586
		a.h = SOLDIER_H -- 1587
		a.vx = 0 -- 1588
		self:fallY(a, dt) -- 1589
		return -- 1590
	end -- 1590
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 1592
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 1593
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1594
	local nearCover = not isChild and self:nearCover(a) -- 1595
	a.covered = nearCover and input.cover.held -- 1596
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1598
	if a.rollT > 0 then -- 1598
		a.rollT = a.rollT - dt -- 1602
		a.vx = a.facing * ROLL_SPEED -- 1603
		self:slideX(a, a.vx * dt) -- 1604
		self:fallY(a, dt) -- 1605
		if a.rollT <= 0 then -- 1605
			self:flashSet("翻滚结束", 0.5) -- 1607
		end -- 1607
		return -- 1609
	end -- 1609
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1609
		if input.moveX ~= 0 then -- 1609
			a.facing = input.moveX > 0 and 1 or -1 -- 1614
		end -- 1614
		if self:nearLowLedge(a) then -- 1614
			a.vy = SOLDIER_JUMP -- 1618
			a.onGround = false -- 1619
			self:flashSet("翻上去", 0.3) -- 1620
			return -- 1621
		end -- 1621
		a.rollT = ROLL_TIME -- 1623
		self:flashSet("翻滚", 0.3) -- 1624
		return -- 1625
	end -- 1625
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1628
	if isChild then -- 1628
		if input.cover.held then -- 1628
			speed = CHILD_SLOW -- 1631
		end -- 1631
		if a.crouch then -- 1631
			speed = CHILD_SLOW -- 1634
		end -- 1634
	elseif a.covered then -- 1634
		speed = SOLDIER_SPEED * 0.45 -- 1637
	end -- 1637
	local handsBusy = self.gripping or gripIntent -- 1641
	local dir = self.gripping and 0 or input.moveX -- 1642
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 1643
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1644
	if dir ~= 0 then -- 1644
		a.facing = dir > 0 and 1 or -1 -- 1646
	end -- 1646
	a.vx = dir * speed * diagonal -- 1648
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1648
		a.vy = CHILD_JUMP -- 1652
		a.onGround = false -- 1653
		self:flashSet("跳", 0.25) -- 1654
	end -- 1654
	local previousDepth = a.depth -- 1658
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1659
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1660
	self:slideX(a, a.vx * dt) -- 1661
	self:fallY(a, dt) -- 1662
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1662
		self:shoot(a) -- 1666
	end -- 1666
end -- 1568
function Play.prototype.stepPartner(self, p, dt) -- 1671
	local a = self.partner -- 1672
	if not a.alive then -- 1672
		return -- 1674
	end -- 1674
	a.crouch = false -- 1676
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1677
	a.vx = 0 -- 1678
	a.depthSpeed = 0 -- 1679
	self:fallY(a, dt) -- 1680
end -- 1671
function Play.prototype.stepEscort(self, dt, input) -- 1687
	local a = self.partner -- 1688
	a.depthSpeed = 0 -- 1689
	if not a.alive then -- 1689
		return -- 1691
	end -- 1691
	if self.room.key == "gatepath" then -- 1691
		if self.carryOn then -- 1691
			return -- 1696
		end -- 1696
		local p = self.player -- 1699
		a.depth = p.depth -- 1700
		a.facing = p.facing -- 1701
		a.crouch = false -- 1702
		a.h = CHILD_H -- 1703
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 1704
		a.y = p.y -- 1705
		a.vy = 0 -- 1706
		a.vx = p.vx -- 1707
		a.onGround = p.onGround -- 1708
		return -- 1709
	end -- 1709
	if not self:escortOn() then -- 1709
		a.vx = 0 -- 1712
		self:fallY(a, dt) -- 1713
		return -- 1714
	end -- 1714
	local p = self.player -- 1716
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1717
	local hadKnock1 = self.escort.knock1 -- 1718
	local hadKnock2 = self.escort.knock2 -- 1719
	self.calmConsumed = self.escort:update( -- 1720
		input, -- 1720
		p.x, -- 1720
		p.facing, -- 1720
		a.x, -- 1720
		dist -- 1720
	) -- 1720
	if not hadKnock1 and self.escort.knock1 then -- 1720
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1723
	end -- 1723
	if not hadKnock2 and self.escort.knock2 then -- 1723
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1726
	end -- 1726
	a.crouch = self.escort.crouchPose -- 1728
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1729
	if not self.escort.stopped then -- 1729
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1731
		local previousDepth = a.depth -- 1732
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1733
		local distance = math.max( -- 1734
			-travel, -- 1734
			math.min(travel, targetDepth - previousDepth) -- 1734
		) -- 1734
		self:slideDepth(a, distance) -- 1735
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1736
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1736
			a.vy = CHILD_JUMP -- 1738
			a.onGround = false -- 1739
		end -- 1739
	end -- 1739
	local dir = self.escort:moveDir(a.x) -- 1742
	a.vx = dir * CHILD_SPEED -- 1743
	if dir ~= 0 then -- 1743
		a.facing = dir -- 1745
		local before = a.x -- 1746
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1747
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1747
			a.vy = CHILD_JUMP -- 1750
			a.onGround = false -- 1751
		end -- 1751
	end -- 1751
	self:fallY(a, dt) -- 1754
end -- 1687
function Play.prototype.escortOn(self) -- 1758
	if self.room.key == "checkpoint" then -- 1758
		return true -- 1760
	end -- 1760
	if self.room.key == "gatepath" then -- 1760
		return true -- 1763
	end -- 1763
	if self.room.key == "prologue" then -- 1763
		return self.phase == "prologue-follow" -- 1766
	end -- 1766
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 1766
		return true -- 1770
	end -- 1770
	return self.room.key == "street" -- 1772
end -- 1758
function Play.prototype.storyLocked(self) -- 1776
	if self.caughtT > 0 then -- 1776
		return true -- 1778
	end -- 1778
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1778
		return true -- 1781
	end -- 1781
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 1781
		return true -- 1784
	end -- 1784
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1784
		return true -- 1787
	end -- 1787
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 1787
		return true -- 1790
	end -- 1790
	if self.craftBench.active then -- 1790
		return true -- 1794
	end -- 1794
	return false -- 1796
end -- 1776
function Play.prototype.swapToChild(self, x) -- 1800
	local tmp = self.player -- 1801
	self.player = self.partner -- 1802
	self.partner = tmp -- 1803
	self.childMode = true -- 1804
	self.player.alive = true -- 1805
	self.player.x = self.ox + x -- 1806
	self.player.y = 0 -- 1807
	self.player.depth = 0 -- 1808
	self.player.depthSpeed = 0 -- 1809
	self.player.vy = 0 -- 1810
	self.player.vx = 0 -- 1811
	self.player.onGround = true -- 1812
	self.player.crouch = false -- 1813
	self.player.h = CHILD_H -- 1814
	self.player.facing = 1 -- 1815
	self.partner.alive = true -- 1816
	self.cam.x = self.player.x -- 1817
end -- 1800
function Play.prototype.stepStory(self, dt, input) -- 1821
	if self.room.key == "prologue" then -- 1821
		self:stepPrologue(dt, input) -- 1823
	elseif self.room.key == "street" then -- 1823
		self:stepStreet(dt, input) -- 1825
	elseif self.room.key == "gate" then -- 1825
		self:stepGate(dt, input) -- 1827
	elseif self.room.key == "gatepath" then -- 1827
		self:stepGatePath() -- 1829
	elseif self.room.key == "tower" then -- 1829
		self:stepTower(dt, input) -- 1831
	elseif self.room.key == "museum" then -- 1831
		self:stepMuseum(dt, input) -- 1833
	end -- 1833
end -- 1821
function Play.prototype.canPersistProgress(self) -- 1839
	return not self.isCampaign and self.run.source == "official" -- 1840
end -- 1839
function Play.prototype.wellWindow(self) -- 1844
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 1845
end -- 1844
function Play.prototype.nearWell(self) -- 1850
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 1851
end -- 1850
function Play.prototype.pickWell(self) -- 1859
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 1859
		return false -- 1861
	end -- 1861
	self.phase = "prologue-well" -- 1863
	self.phaseTick = 0 -- 1864
	self.wellOpen = false -- 1865
	self:flashSet("井沿 · 伸手下去", 1.4) -- 1866
	self:log("旧井拾取") -- 1867
	return true -- 1868
end -- 1859
function Play.prototype.stepPrologue(self, dt, input) -- 1871
	local child = self.partner -- 1872
	if self.museumReturn then -- 1872
		self.museumReturn = false -- 1875
		self.phase = "prologue-wait" -- 1876
		self.phaseTick = 0 -- 1877
		self.player.x = self.ox + 260 -- 1878
		self.player.y = 0 -- 1879
		self.player.depth = 0 -- 1880
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 1881
	end -- 1881
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 1884
	if self.phase == "prologue-wait" then -- 1884
		child.crouch = true -- 1886
		child.h = CHILD_CROUCH_H -- 1887
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 1887
			self:pickWell() -- 1889
			return -- 1890
		end -- 1890
		if not self.wellOpen and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 1890
			if self:canPersistProgress() then -- 1890
				self.archive.museumPhase = "well_reflect" -- 1896
				self.archiveDirty = true -- 1897
			end -- 1897
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 1899
			return -- 1900
		end -- 1900
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1902
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1904
		if near and input.interact.pressed then -- 1904
			self.phase = "prologue-give" -- 1906
			self.phaseTick = 0 -- 1907
			self:flashSet("递出针套", 1) -- 1908
		end -- 1908
		return -- 1910
	end -- 1910
	if self.phase == "prologue-well" then -- 1910
		self.phaseTick = self.phaseTick + 1 -- 1914
		if self.phaseTick == 12 then -- 1914
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 1916
		elseif self.phaseTick >= 30 then -- 1916
			self.phase = "prologue-wait" -- 1918
			self.phaseTick = 0 -- 1919
			self.wellTaken = true -- 1920
			self.wellOpen = false -- 1921
			self.run.archive.artifactOwned = true -- 1922
			self.archiveDirty = true -- 1923
			self:emit("artifactFound", { -- 1924
				x = self.ox + self.wellX, -- 1925
				y = 0, -- 1925
				room = "prologue", -- 1925
				once = true, -- 1925
				source = self.run.source -- 1926
			}) -- 1926
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 1928
			self:log("井底取到时间穿梭器") -- 1929
		end -- 1929
		return -- 1931
	end -- 1931
	if self.phase == "prologue-give" then -- 1931
		self.phaseTick = self.phaseTick + 1 -- 1934
		if self.phaseTick == 12 then -- 1934
			self:flashSet("针套递过去", 0.7) -- 1936
		elseif self.phaseTick == 36 then -- 1936
			self:flashSet("纸条塞进针套", 0.9) -- 1938
		elseif self.phaseTick >= 60 then -- 1938
			self.phase = "prologue-follow" -- 1940
			self.phaseTick = 0 -- 1941
			child.crouch = false -- 1942
			child.h = CHILD_H -- 1943
			self:flashSet("她跟上了", 1.2) -- 1944
		end -- 1944
		return -- 1946
	end -- 1946
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1946
		self:requestRoom("street", "序章跟到门口") -- 1950
		self:flashSet("进街道", 1.2) -- 1951
	end -- 1951
end -- 1871
function Play.prototype.stepStreet(self, dt, input) -- 1956
	local p = self.player -- 1957
	local c = self.partner -- 1958
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1958
		self:requestRoom("checkpoint", "两人都到街尾") -- 1960
		self:flashSet("到检查站", 1.2) -- 1961
	end -- 1961
end -- 1956
function Play.prototype.stepGate(self, dt, input) -- 1966
	local ____temp_38 -- 1967
	if self.room.story == nil then -- 1967
		____temp_38 = nil -- 1967
	else -- 1967
		____temp_38 = self.room.story.gate -- 1967
	end -- 1967
	local g = ____temp_38 -- 1967
	if g == nil then -- 1967
		return -- 1969
	end -- 1969
	local p = self.player -- 1971
	if self.phase == "gate-idle" then -- 1971
		local a = self.partner -- 1974
		local gap = g.waitX - a.x -- 1975
		if math.abs(gap) > 3 then -- 1975
			a.facing = gap > 0 and 1 or -1 -- 1977
			a.vx = a.facing * CHILD_SPEED -- 1978
			local beforeX = a.x -- 1979
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1980
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1980
				a.vy = CHILD_JUMP -- 1982
				a.onGround = false -- 1983
			end -- 1983
			self:fallY(a, dt) -- 1985
		else -- 1985
			a.vx = 0 -- 1987
			a.x = g.waitX -- 1988
		end -- 1988
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1991
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1992
		if self.gateNeedConfirm then -- 1992
			if not input.interact.held then -- 1992
				self.gateRestartArmed = true -- 1997
			end -- 1997
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1997
				self.gateNeedConfirm = false -- 2000
				self.gateRestartArmed = true -- 2001
				self.phase = "gate-hold" -- 2002
				self.gateTick = 0 -- 2003
				self.gateSpawned = 0 -- 2004
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2005
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2006
			end -- 2006
			return -- 2008
		end -- 2008
		if atWinch and atWait then -- 2008
			self.phase = "gate-hold" -- 2011
			self.gateTick = 0 -- 2012
			self.gateSpawned = 0 -- 2013
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2014
		end -- 2014
		return -- 2016
	end -- 2016
	if self.phase == "gate-hold" then -- 2016
		self.gateTick = self.gateTick + 1 -- 2019
		local marks = {0, 540, 900, 1500} -- 2021
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2021
			local idx = self.gateSpawned -- 2023
			local ____self_enemies_39 = self.enemies -- 2023
			____self_enemies_39[#____self_enemies_39 + 1] = { -- 2024
				x = self.ox + 620 + idx * 62, -- 2025
				y = 0, -- 2025
				w = 26, -- 2025
				h = 84, -- 2025
				alive = true, -- 2026
				hitT = 0, -- 2026
				warnT = 0, -- 2026
				fireCd = 90 + idx * 45 -- 2026
			} -- 2026
			self.gateSpawned = self.gateSpawned + 1 -- 2028
			self:flashSet( -- 2029
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2029
				0.9 -- 2029
			) -- 2029
		end -- 2029
		if self.gateTick == 900 then -- 2029
			self:flashSet("灯灭了", 1) -- 2032
		elseif self.gateTick == 2100 then -- 2032
			self:flashSet("门底压下来了", 1) -- 2034
		end -- 2034
		if self.gateTick >= g.holdTicks then -- 2034
			self:captureGateBlood() -- 2039
			self.phase = "gate-send" -- 2040
			self.phaseTick = 0 -- 2041
			self.enemies = {} -- 2043
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2044
		end -- 2044
		return -- 2046
	end -- 2046
	if self.phase == "gate-send" then -- 2046
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2049
		if near and input.interact.pressed then -- 2049
			self:commitRoute() -- 2052
			self:swapToChild(g.doorX + 30) -- 2053
			self.phase = "gate-count" -- 2054
			self.countTick = 0 -- 2055
			self.countArmed = false -- 2057
			self.countPrevMove = input.moveX -- 2058
			self:flashSet("门开了 · 送她出去", 1.8) -- 2059
		end -- 2059
		return -- 2061
	end -- 2061
	if self.phase == "gate-count" then -- 2061
		self.countTick = self.countTick + 1 -- 2064
		if self.countTick == 360 then -- 2064
			self:flashSet("门关上", 0.9) -- 2066
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2066
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2068
			if self.storyRoute == "soldier" then -- 2068
				self.phase = "gate-wait" -- 2074
				self.phaseTick = 0 -- 2075
				self.knocks = 1 -- 2076
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2077
				self.handArmed = not input.interact.held -- 2079
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2080
			else -- 2080
				self:flashSet("数到二十", 2.2) -- 2082
			end -- 2082
		end -- 2082
		local prevMove = self.countPrevMove -- 2087
		self.countPrevMove = input.moveX -- 2088
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2088
			if prevMove <= 0 and input.moveX > 0 then -- 2088
				self.countArmed = true -- 2091
			end -- 2091
			if self.countArmed and input.moveX > 0 then -- 2091
				self.phase = "gate-walk" -- 2094
				self.phaseTick = 0 -- 2095
				self:flashSet("她迈出第一步", 1.4) -- 2096
				self:emit("storyExit", { -- 2097
					route = "child", -- 2097
					via = "walk", -- 2097
					countTick = self.countTick, -- 2097
					hp = self.hp, -- 2097
					maxHp = self.maxHp -- 2097
				}) -- 2097
			end -- 2097
		end -- 2097
		return -- 2100
	end -- 2100
	if self.phase == "gate-wait" then -- 2100
		self.phaseTick = self.phaseTick + 1 -- 2104
		if self.phaseTick == 12 then -- 2104
			self.knocks = 2 -- 2106
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2107
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2108
		end -- 2108
		if not input.interact.held then -- 2108
			if self.handTicks > 0 then -- 2108
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2112
			end -- 2112
			self.handTicks = 0 -- 2114
			self.handArmed = true -- 2115
			return -- 2116
		end -- 2116
		if self.handArmed then -- 2116
			self.handTicks = self.handTicks + 1 -- 2119
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2119
				self.phase = "gate-hand" -- 2121
				self.phaseTick = 0 -- 2122
				self.handDone = true -- 2123
				self.tied = true -- 2124
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2125
				if not self.lineSaid then -- 2125
					self.lineSaid = true -- 2127
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2128
				end -- 2128
				self:flashSet("我们走吧。", 3) -- 2130
			end -- 2130
		end -- 2130
		return -- 2133
	end -- 2133
	if self.phase == "gate-hand" then -- 2133
		self.phaseTick = self.phaseTick + 1 -- 2137
		if self.phaseTick == 30 then -- 2137
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2139
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2139
			self:emit("storyExit", { -- 2141
				route = "soldier", -- 2141
				via = "hand", -- 2141
				handTicks = self.handTicks, -- 2141
				hp = self.hp, -- 2141
				maxHp = self.maxHp -- 2141
			}) -- 2141
			self:requestRoom("gatepath", "牵手同行") -- 2142
		end -- 2142
		return -- 2144
	end -- 2144
	if self.phase == "gate-walk" then -- 2144
		if self.player.x >= g.exitX then -- 2144
			self:requestRoom("outside", "走出城门") -- 2149
			self:flashSet("出城门 · 城外", 1.4) -- 2150
		end -- 2150
	end -- 2150
end -- 1966
function Play.prototype.captureGateBlood(self) -- 2159
	self.hpAtGate = self.hp -- 2160
	self.maxHpAtGate = self.maxHp -- 2161
end -- 2159
function Play.prototype.commitRoute(self) -- 2168
	if self.storySettled then -- 2168
		return -- 2170
	end -- 2170
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2172
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2173
	self.hpAtGate = hp -- 2174
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2175
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2176
	self.storySettled = true -- 2177
	self:emit("storyRouteLocked", { -- 2178
		route = self.storyRoute, -- 2179
		hp = self.hp, -- 2179
		maxHp = self.maxHp, -- 2179
		hpAtGate = self.hpAtGate, -- 2180
		maxHpAtGate = self.maxHpAtGate -- 2180
	}) -- 2180
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2182
end -- 2168
function Play.prototype.syncStory(self) -- 2186
	if self.isCampaign and self.run.trial ~= nil then -- 2186
		return -- 2188
	end -- 2188
	local s = self.run.story -- 2190
	if s == nil then -- 2190
		return -- 2192
	end -- 2192
	s.hp = self.hp -- 2194
	s.maxHp = self.maxHp -- 2195
	s.route = self.storyRoute -- 2196
	s.settled = self.storySettled -- 2197
	s.hpAtGate = self.hpAtGate -- 2198
	s.maxHpAtGate = self.maxHpAtGate -- 2199
	s.handDone = self.handDone -- 2200
	s.lineSaid = self.lineSaid -- 2201
	s.tied = self.tied -- 2202
	s.carry = self.carryOn -- 2203
	s.museumReturn = self.museumReturn -- 2204
	s.escortDone = self.escortDone -- 2205
	s.craftedWeapon = self.run.story.craftedWeapon -- 2206
	s.ending = self.run.story.ending -- 2207
	if self.room.key == "gate" then -- 2207
		s.phase = self.phase -- 2209
		s.countTick = self.countTick -- 2210
		s.phaseTick = self.phaseTick -- 2211
		s.handTicks = self.handTicks -- 2212
	end -- 2212
end -- 2186
function Play.prototype.stepGatePath(self) -- 2217
	local ____temp_40 -- 2218
	if self.room.story == nil then -- 2218
		____temp_40 = nil -- 2218
	else -- 2218
		____temp_40 = self.room.story.gatepath -- 2218
	end -- 2218
	local gp = ____temp_40 -- 2218
	if self.phase == "gatepath-start" then -- 2218
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2218
			self.carryOn = true -- 2221
			self.phase = "gatepath-carry" -- 2222
			self.phaseTick = 0 -- 2223
			self.pathDone = true -- 2224
			self.escortDone = false -- 2225
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2226
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2227
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2228
		end -- 2228
		return -- 2230
	end -- 2230
	if self.phase == "gatepath-carry" then -- 2230
		self.phaseTick = self.phaseTick + 1 -- 2233
		if self.phaseTick == 20 then -- 2233
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2235
		end -- 2235
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2235
			self:requestRoom(gp.next, "背负进首战") -- 2238
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2239
		end -- 2239
	end -- 2239
end -- 2217
function Play.prototype.carryPose(self) -- 2248
	local p = self.player -- 2249
	local a = self.partner -- 2250
	a.alive = true -- 2251
	a.x = p.x - p.facing * 12 -- 2252
	a.y = p.y + 26 -- 2253
	a.depth = p.depth -- 2254
	a.vx = p.vx -- 2255
	a.vy = 0 -- 2256
	a.onGround = true -- 2257
	a.crouch = false -- 2258
	a.h = CHILD_CROUCH_H -- 2259
	a.facing = p.facing -- 2260
end -- 2248
function Play.prototype.stepMuseum(self, dt, input) -- 2268
	self.partner.alive = false -- 2269
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2270
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2273
	if self.phase == "museum-cabinet" then -- 2273
		if atCase and input.interact.pressed then -- 2273
			self.phase = "museum-hall" -- 2276
			self.phaseTick = 0 -- 2277
			if self:canPersistProgress() then -- 2277
				self.archive.museumPhase = "hall_walk" -- 2279
				self.archiveDirty = true -- 2280
			end -- 2280
			self:emit( -- 2282
				"museumStep", -- 2282
				{ -- 2282
					step = "cabinet", -- 2282
					x = self.ox + mu.cabinetX, -- 2282
					persisted = self:canPersistProgress() -- 2282
				} -- 2282
			) -- 2282
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2283
		end -- 2283
		return -- 2285
	end -- 2285
	if self.phase == "museum-hall" then -- 2285
		if self.player.x >= self.ox + mu.hallX and input.interact.pressed then -- 2285
			self.phase = "museum-lamp" -- 2289
			self.phaseTick = 0 -- 2290
			if self:canPersistProgress() then -- 2290
				self.archive.museumPhase = "lamp_turn" -- 2292
				self.archiveDirty = true -- 2293
			end -- 2293
			self:emit( -- 2295
				"museumStep", -- 2295
				{ -- 2295
					step = "hall", -- 2295
					x = self.ox + mu.hallX, -- 2295
					persisted = self:canPersistProgress() -- 2295
				} -- 2295
			) -- 2295
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2296
		end -- 2296
		return -- 2298
	end -- 2298
	if self.phase == "museum-lamp" then -- 2298
		if self.player.x >= self.ox + mu.lampX and input.interact.pressed then -- 2298
			self.phase = "museum-return" -- 2302
			self.phaseTick = 0 -- 2303
			if self:canPersistProgress() then -- 2303
				self.archive.museumPhase = "return_cabinet" -- 2305
				self.archiveDirty = true -- 2306
			end -- 2306
			self:emit( -- 2308
				"museumStep", -- 2308
				{ -- 2308
					step = "lamp", -- 2308
					x = self.ox + mu.lampX, -- 2308
					persisted = self:canPersistProgress() -- 2308
				} -- 2308
			) -- 2308
			self:flashSet("灯 · 转向西窗", 1.8) -- 2309
		end -- 2309
		return -- 2311
	end -- 2311
	if self.phase == "museum-return" then -- 2311
		if atCase and input.interact.pressed then -- 2311
			self.phase = "museum-knock" -- 2315
			self.phaseTick = 0 -- 2316
			self:emit( -- 2317
				"museumStep", -- 2317
				{ -- 2317
					step = "knock", -- 2317
					count = 1, -- 2317
					x = self.ox + mu.cabinetX, -- 2317
					persisted = self:canPersistProgress() -- 2317
				} -- 2317
			) -- 2317
			self:flashSet("回柜边 · 第一下", 0.8) -- 2318
		end -- 2318
		return -- 2320
	end -- 2320
	if self.phase == "museum-knock" then -- 2320
		self.phaseTick = self.phaseTick + 1 -- 2323
		if self.phaseTick == 8 then -- 2323
			self:emit( -- 2325
				"museumStep", -- 2325
				{ -- 2325
					step = "knock", -- 2325
					count = 2, -- 2325
					x = self.ox + mu.cabinetX, -- 2325
					persisted = self:canPersistProgress() -- 2325
				} -- 2325
			) -- 2325
			self:flashSet("回柜边 · 第二下", 0.8) -- 2326
		elseif self.phaseTick >= 36 then -- 2326
			self.phase = "museum-done" -- 2328
			self.phaseTick = 0 -- 2329
			if self:canPersistProgress() then -- 2329
				self.archive.museumSeen = true -- 2331
				self.archive.museumPhase = "done" -- 2332
				self.archiveDirty = true -- 2333
			end -- 2333
			self:emit( -- 2335
				"museumDone", -- 2335
				{ -- 2335
					steps = 4, -- 2335
					museumSeen = self.archive.museumSeen, -- 2335
					persisted = self:canPersistProgress() -- 2335
				} -- 2335
			) -- 2335
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2336
			self:log("博物馆 · 回柜边") -- 2337
		end -- 2337
		return -- 2339
	end -- 2339
	if input.interact.pressed then -- 2339
		self.museumReturn = true -- 2342
		self:requestRoom("prologue", "回柜边") -- 2343
	end -- 2343
end -- 2268
function Play.prototype.stepTower(self, dt, input) -- 2347
	local ____temp_41 -- 2348
	if self.room.story == nil then -- 2348
		____temp_41 = nil -- 2348
	else -- 2348
		____temp_41 = self.room.story.tower -- 2348
	end -- 2348
	local t = ____temp_41 -- 2348
	if t == nil then -- 2348
		return -- 2350
	end -- 2350
	if self.phase == "tower-wait" then -- 2350
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2353
		if near and input.interact.pressed then -- 2353
			self.phase = "tower-knock" -- 2355
			self.phaseTick = 0 -- 2356
			self.knocks = 1 -- 2357
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2358
			self:flashSet("敲一下", 0.6) -- 2359
		end -- 2359
		return -- 2361
	end -- 2361
	if self.phase == "tower-knock" then -- 2361
		self.phaseTick = self.phaseTick + 1 -- 2364
		if self.phaseTick == 12 then -- 2364
			self.knocks = 2 -- 2366
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2367
			self:flashSet("敲两下 · 第二声", 1) -- 2368
		elseif self.phaseTick >= t.knockTicks then -- 2368
			self.phase = "tower-given" -- 2370
			self.phaseTick = 0 -- 2371
			self:flashSet("门开了 · 提灯", 1.4) -- 2372
		end -- 2372
		return -- 2374
	end -- 2374
	if self.phase == "tower-given" then -- 2374
		local soldier = self.storyRoute == "soldier" -- 2379
		self.phaseTick = self.phaseTick + 1 -- 2380
		if self.phaseTick == 60 then -- 2380
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 2382
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 2383
		elseif self.phaseTick == 120 then -- 2383
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 2385
		elseif self.phaseTick >= 180 then -- 2385
			self.phase = "tower-end" -- 2387
			self.phaseTick = 0 -- 2388
			if not self.run.finished then -- 2388
				self.run.finished = true -- 2390
				local ending = soldier and "reunion" or "lamp" -- 2391
				self.run.story.ending = ending -- 2392
				local ____soldier_42 -- 2395
				if soldier then -- 2395
					____soldier_42 = self.run.story.segments.escort5 == true -- 2396
				else -- 2396
					____soldier_42 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 2397
				end -- 2397
				local played = ____soldier_42 -- 2395
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 2398
				if official then -- 2398
					if soldier then -- 2398
						self.run.archive.soldierCleared = true -- 2402
					else -- 2402
						self.run.archive.childCleared = true -- 2404
					end -- 2404
					self.archiveDirty = true -- 2406
				end -- 2406
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 2408
				self:emit("endingReached", { -- 2409
					route = soldier and "soldier" or "child", -- 2410
					ending = ending, -- 2411
					official = official, -- 2412
					source = self.run.source, -- 2413
					lines = {self.endingLines[1], self.endingLines[2]}, -- 2414
					childCleared = self.run.archive.childCleared, -- 2415
					soldierCleared = self.run.archive.soldierCleared, -- 2416
					artifactOwned = self.run.archive.artifactOwned, -- 2417
					equipped = self.equippedWeapon -- 2418
				}) -- 2418
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 2420
			end -- 2420
		end -- 2420
		return -- 2423
	end -- 2423
	if input.interact.pressed or input.retry.pressed then -- 2423
		self.restartStory = true -- 2427
		self:requestRoom("prologue", "片尾再玩") -- 2428
		self:flashSet("回到序章", 1.4) -- 2429
	end -- 2429
end -- 2347
function Play.prototype.stepChase(self, dt, input) -- 2434
	if self.caughtT > 0 then -- 2434
		self.caughtT = self.caughtT - dt -- 2436
		if self.caughtT <= 0 then -- 2436
			self:recoverFromCaught() -- 2438
		end -- 2438
		return -- 2440
	end -- 2440
	if self.room.key == "village" then -- 2440
		self:stepScavChase() -- 2443
	elseif self.room.key == "forest" then -- 2443
		self:stepDog(dt) -- 2445
		if self.player.x >= self.ox + 1450 then -- 2445
			self:requestRoom("tower", "到林缘北塔") -- 2448
			self:flashSet("林缘 · 北塔", 1.4) -- 2449
		end -- 2449
	end -- 2449
end -- 2434
function Play.prototype.stepScavChase(self) -- 2455
	local s = self.room.scavenger -- 2456
	if s == nil then -- 2456
		return -- 2458
	end -- 2458
	local p = self.player -- 2460
	if self.passed and p.x > self.ox + 440 then -- 2460
		if self.scavChase then -- 2460
			self.scavChase = false -- 2464
			self.scavState = "back" -- 2465
			self.scavT = 0 -- 2466
		end -- 2466
		return -- 2468
	end -- 2468
	local dx = p.x - self.scavX -- 2470
	local dist = math.abs(dx) -- 2471
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 2472
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 2473
	if not self.scavChase then -- 2473
		if visible then -- 2473
			self.scavSee = self.scavSee + 1 -- 2476
			if self.scavSee >= 24 then -- 2476
				self.scavChase = true -- 2478
				self.scavState = "chase" -- 2479
				self.scavTargetX = p.x -- 2480
				self:flashSet("他看见你了", 1.2) -- 2481
			end -- 2481
		else -- 2481
			self.scavSee = 0 -- 2484
		end -- 2484
		return -- 2486
	end -- 2486
	local dir = p.x > self.scavX and 1 or -1 -- 2489
	self.scavX = self.scavX + dir * 96 / 60 -- 2490
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 2490
		self:caught() -- 2492
		return -- 2493
	end -- 2493
	if hidden then -- 2493
		self.scavSee = 0 -- 2497
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 2498
		self.scavT = self.scavT - 1 -- 2499
		if self.scavT <= 0 then -- 2499
			self.scavChase = false -- 2501
			self.scavState = "patrol" -- 2502
			self:flashSet("他失去了目标", 1) -- 2503
		end -- 2503
	end -- 2503
end -- 2455
function Play.prototype.stepDog(self, dt) -- 2509
	local ____temp_43 -- 2510
	if self.room.story == nil then -- 2510
		____temp_43 = nil -- 2510
	else -- 2510
		____temp_43 = self.room.story.dog -- 2510
	end -- 2510
	local dog = ____temp_43 -- 2510
	if dog == nil then -- 2510
		return -- 2512
	end -- 2512
	local p = self.player -- 2514
	local dist = math.abs(p.x - self.dogX) -- 2515
	if self.dogState == "patrol" then -- 2515
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 2517
		if self.dogX < dog.x0 then -- 2517
			self.dogX = dog.x0 -- 2519
			self.dogDir = 1 -- 2520
		elseif self.dogX > dog.x1 then -- 2520
			self.dogX = dog.x1 -- 2522
			self.dogDir = -1 -- 2523
		end -- 2523
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 2525
		if not p.crouch and moving and dist < dog.range then -- 2525
			self.dogState = "ear" -- 2527
			self.dogT = 18 -- 2528
			self.dogTargetX = p.x -- 2529
			self:flashSet("狗转耳朵", 0.8) -- 2530
		end -- 2530
		return -- 2532
	end -- 2532
	if self.dogState == "ear" then -- 2532
		self.dogT = self.dogT - 1 -- 2535
		if self.dogT <= 0 then -- 2535
			self.dogState = "chase" -- 2537
			self.dogTargetX = p.x -- 2538
			self:flashSet("狗追来了", 1.4) -- 2539
		end -- 2539
		return -- 2541
	end -- 2541
	if self.dogState == "chase" then -- 2541
		local dir = p.x > self.dogX and 1 or -1 -- 2544
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 2545
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 2545
			self:caught() -- 2547
			self.dogState = "sniff" -- 2548
			self.dogT = 60 -- 2549
		elseif dist > dog.range * 1.5 or p.crouch then -- 2549
			self.dogState = "sniff" -- 2551
			self.dogT = 60 -- 2552
			self:flashSet("狗停下了", 0.9) -- 2553
		end -- 2553
		return -- 2555
	end -- 2555
	if self.dogState == "sniff" then -- 2555
		self.dogT = self.dogT - 1 -- 2558
		if self.dogT <= 0 then -- 2558
			self.dogState = "back" -- 2560
		end -- 2560
		return -- 2562
	end -- 2562
	local dir = dog.x0 > self.dogX and 1 or -1 -- 2565
	self.dogX = self.dogX + dir * dog.speed * dt -- 2566
	if math.abs(self.dogX - dog.x0) < 2 then -- 2566
		self.dogX = dog.x0 -- 2568
		self.dogState = "patrol" -- 2569
	end -- 2569
end -- 2509
function Play.prototype.caught(self) -- 2573
	self.caughtT = 1 -- 2574
	self:flashSet("被抓 · 回到安全点", 1.6) -- 2575
end -- 2573
function Play.prototype.recoverFromCaught(self) -- 2579
	local p = self.player -- 2580
	p.x = self.ox + 140 -- 2581
	p.y = 0 -- 2582
	p.vy = 0 -- 2583
	p.vx = 0 -- 2584
	p.onGround = true -- 2585
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 2585
		self.scavX = self.room.scavenger.x0 -- 2587
		self.scavState = "patrol" -- 2588
		self.scavSee = 0 -- 2589
		self.scavChase = false -- 2590
		self.scavT = 0 -- 2591
	end -- 2591
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 2591
		self.dogX = self.room.story.dog.x0 -- 2594
		self.dogState = "patrol" -- 2595
		self.dogT = 0 -- 2596
	end -- 2596
	self.cam.x = p.x -- 2598
	self.cam.y = p.y + CAM_LOOK_UP -- 2599
	self:flashSet("回到安全点", 1.2) -- 2600
end -- 2579
function Play.prototype.updateGate(self) -- 2604
	if self.room.key ~= "checkpoint" then -- 2604
		self.gateOpen = false -- 2606
		return -- 2607
	end -- 2607
	local function inZone(x) -- 2609
		return x >= self.ox + 792 and x <= self.ox + 928 -- 2609
	end -- 2609
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 2610
end -- 2604
function Play.prototype.addItem(self, kind) -- 2616
	local inv = self.run.inventory -- 2617
	if kind == "shield" then -- 2617
		if inv.shield >= TOOL_CAP then -- 2617
			return false -- 2620
		end -- 2620
		inv.shield = inv.shield + 1 -- 2622
		return true -- 2623
	end -- 2623
	if kind == "wedge" then -- 2623
		if inv.wedge >= CONSUMABLE_CAP then -- 2623
			return false -- 2627
		end -- 2627
		inv.wedge = inv.wedge + 1 -- 2629
		return true -- 2630
	end -- 2630
	if kind == "ammo" then -- 2630
		if inv.ammo >= CONSUMABLE_CAP then -- 2630
			return false -- 2634
		end -- 2634
		inv.ammo = inv.ammo + 1 -- 2636
		return true -- 2637
	end -- 2637
	if kind == "scrap" then -- 2637
		inv.scrap = inv.scrap + 1 -- 2641
		return true -- 2642
	end -- 2642
	if kind == "wood" then -- 2642
		inv.wood = inv.wood + 1 -- 2645
		return true -- 2646
	end -- 2646
	if kind == "bell" then -- 2646
		inv.bell = inv.bell + 1 -- 2649
		return true -- 2650
	end -- 2650
	if kind == "pass" then -- 2650
		inv.pass = inv.pass + 1 -- 2653
		return true -- 2654
	end -- 2654
	if kind == "quickbelt" then -- 2654
		inv.quickbelt = inv.quickbelt + 1 -- 2657
		return true -- 2658
	end -- 2658
	return false -- 2660
end -- 2616
function Play.prototype.findBox(self, id) -- 2663
	local i = 0 -- 2664
	do -- 2664
		i = 0 -- 2665
		while i < #self.boxes do -- 2665
			if self.boxes[i + 1].id == id then -- 2665
				return self.boxes[i + 1] -- 2667
			end -- 2667
			i = i + 1 -- 2665
		end -- 2665
	end -- 2665
	return nil -- 2670
end -- 2663
function Play.prototype.findWedgeTarget(self) -- 2674
	local best = nil -- 2675
	local bestD = 0 -- 2676
	local i = 0 -- 2677
	do -- 2677
		i = 0 -- 2678
		while i < #self.boxes do -- 2678
			do -- 2678
				local b = self.boxes[i + 1] -- 2679
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 2679
					goto __continue402 -- 2681
				end -- 2681
				if not self:nearBox(b, 26) then -- 2681
					goto __continue402 -- 2684
				end -- 2684
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 2686
				if best == nil or d < bestD then -- 2686
					best = b -- 2688
					bestD = d -- 2689
				end -- 2689
			end -- 2689
			::__continue402:: -- 2689
			i = i + 1 -- 2678
		end -- 2678
	end -- 2678
	return best -- 2692
end -- 2674
function Play.prototype.stepCraft(self, input) -- 2700
	local inv = self.run.inventory -- 2701
	local ____opt_44 = self.run.trial -- 2701
	local required = CRAFT_TICKS - 6 * (____opt_44 and ____opt_44.ranks.craft or 0) -- 2702
	if self.craftT > 0 then -- 2702
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 2702
			self.craftT = 0 -- 2706
			self:flashSet("制作中断", 0.8) -- 2707
			return true -- 2708
		end -- 2708
		self.craftT = self.craftT + 1 -- 2710
		if self.craftT >= required then -- 2710
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 2710
				inv.scrap = inv.scrap - 1 -- 2713
				inv.wedge = inv.wedge + 1 -- 2714
				self:flashSet("制得木楔", 1.2) -- 2715
				self:log("制木楔") -- 2716
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 2717
			end -- 2717
			self.craftT = 0 -- 2719
		end -- 2719
		return true -- 2721
	end -- 2721
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 2721
		self.craftT = 1 -- 2724
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 2725
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 2726
		return true -- 2727
	end -- 2727
	return false -- 2729
end -- 2700
function Play.prototype.nearBox(self, b, reach) -- 2732
	local p = self.player -- 2733
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 2734
end -- 2732
function Play.prototype.findInteract(self) -- 2740
	local p = self.player -- 2741
	local best = nil -- 2742
	local bestD = 1000000000 -- 2743
	local i = 0 -- 2744
	do -- 2744
		i = 0 -- 2745
		while i < #self.boxes do -- 2745
			do -- 2745
				local b = self.boxes[i + 1] -- 2746
				if b.interact == nil or b.broken == true then -- 2746
					goto __continue415 -- 2748
				end -- 2748
				if not self:nearBox(b, b.interact.reach or 27) then -- 2748
					goto __continue415 -- 2751
				end -- 2751
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 2753
				if d < bestD then -- 2753
					bestD = d -- 2755
					best = b -- 2756
				end -- 2756
			end -- 2756
			::__continue415:: -- 2756
			i = i + 1 -- 2745
		end -- 2745
	end -- 2745
	return best -- 2759
end -- 2740
function Play.prototype.stepCampaign(self, dt, input) -- 2763
	local wr = self.room -- 2764
	local p = self.player -- 2765
	if self.reloadT > 0 then -- 2765
		self.reloadT = self.reloadT - 1 -- 2767
	end -- 2767
	if self.bracedShield ~= nil then -- 2767
		self.bracedShield.x = p.x + p.facing * 26 -- 2771
		self.bracedShield.y = p.y -- 2772
		local shBox = __TS__ArrayFind( -- 2773
			self.boxes, -- 2773
			function(____, b) return b.id == "braced_shield" end -- 2773
		) -- 2773
		if shBox ~= nil then -- 2773
			shBox.x0 = self.bracedShield.x - 15 -- 2775
			shBox.x1 = self.bracedShield.x + 15 -- 2776
			shBox.y0 = self.bracedShield.y -- 2777
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 2778
		end -- 2778
	end -- 2778
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 2778
		self.run.route = "drygoods" -- 2784
		self.run.joined = false -- 2785
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 2786
		self:log("转布行线") -- 2787
	end -- 2787
	if wr.key == "escort3" then -- 2787
		local benchX = wr.minX + 560 -- 2791
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 60 -- 2792
		if self.craftBench.active then -- 2792
			if input.interact.pressed or input.pause.pressed then -- 2792
				self:closeCraftBench() -- 2795
			end -- 2795
		elseif nearBench and input.interact.pressed then -- 2795
			self:openCraftBench() -- 2798
		end -- 2798
	end -- 2798
	local i = 0 -- 2802
	do -- 2802
		i = 0 -- 2803
		while i < #self.pickups do -- 2803
			do -- 2803
				local pk = self.pickups[i + 1] -- 2804
				if pk.id == "" or self.run.taken[pk.id] == true then -- 2804
					goto __continue430 -- 2806
				end -- 2806
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 2808
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 2809
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 2809
					if not self:addItem(pk.kind) then -- 2809
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 2813
						self:log("满包拒绝 " .. pk.kind) -- 2814
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 2815
						goto __continue430 -- 2816
					end -- 2816
					self.run.taken[pk.id] = true -- 2818
					pk.id = "" -- 2819
					self:flashSet("拾取 " .. pk.label, 1) -- 2820
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 2821
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 2822
				end -- 2822
			end -- 2822
			::__continue430:: -- 2822
			i = i + 1 -- 2803
		end -- 2803
	end -- 2803
	if not self:stepCraft(input) and input.interact.pressed then -- 2803
		self:campaignInteract() -- 2826
	end -- 2826
	self:stepCampaignCart(dt, input) -- 2828
	self:stepCampaignGoal() -- 2829
	self:campaignCheckpoint() -- 2830
end -- 2763
function Play.prototype.campaignCheckpoint(self) -- 2834
	local i = 0 -- 2835
	do -- 2835
		i = 0 -- 2836
		while i < #self.room.marks do -- 2836
			do -- 2836
				local m = self.room.marks[i + 1] -- 2837
				if m.kind ~= 0 then -- 2837
					goto __continue437 -- 2839
				end -- 2839
				local dx = self.player.x - m.x -- 2841
				local dy = self.player.y - m.y -- 2842
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2842
					self.checkpoint = m.x -- 2844
					self:captureCheckpoint(m.x) -- 2845
					self:flashSet("检查点", 1) -- 2846
				end -- 2846
			end -- 2846
			::__continue437:: -- 2846
			i = i + 1 -- 2836
		end -- 2836
	end -- 2836
end -- 2834
function Play.prototype.campaignInteract(self) -- 2852
	local b = self:findInteract() -- 2853
	if b ~= nil then -- 2853
		self:useInteract(b) -- 2855
		return -- 2856
	end -- 2856
	local inv = self.run.inventory -- 2858
	if inv.wedge > 0 then -- 2858
		local w = self:findWedgeTarget() -- 2860
		if w ~= nil then -- 2860
			if w.breakable ~= nil then -- 2860
				local ____w_breakable_46, ____hp_47 = w.breakable, "hp" -- 2860
				____w_breakable_46[____hp_47] = ____w_breakable_46[____hp_47] + (w.breakable.wedgeHp or 1) -- 2863
			end -- 2863
			inv.wedge = inv.wedge - 1 -- 2865
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 2866
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 2868
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 2869
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 2870
			return -- 2871
		end -- 2871
	end -- 2871
	if inv.ammo > 0 and self.reloadT > 0 then -- 2871
		self.reloadT = 0 -- 2876
		self:closeReloadPuzzle() -- 2877
		inv.ammo = inv.ammo - 1 -- 2878
		self:flashSet("备用弹包 · 膛内补满", 1) -- 2879
		self:log("用备用弹包") -- 2880
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 2881
		return -- 2882
	end -- 2882
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 2882
		local p = self.player -- 2886
		self.bracedShield = { -- 2887
			x = p.x + p.facing * 26, -- 2887
			y = p.y, -- 2887
			w = 30, -- 2887
			h = 64, -- 2887
			hp = 1 -- 2887
		} -- 2887
		local ____self_boxes_48 = self.boxes -- 2887
		____self_boxes_48[#____self_boxes_48 + 1] = { -- 2888
			x0 = self.bracedShield.x - 15, -- 2889
			x1 = self.bracedShield.x + 15, -- 2889
			y0 = p.y, -- 2890
			y1 = p.y + 64, -- 2890
			depth = {min = -46, max = 46}, -- 2890
			label = "架起的残盾", -- 2890
			id = "braced_shield", -- 2890
			soft = true -- 2891
		} -- 2891
		inv.shield = inv.shield - 1 -- 2894
		self:flashSet("架残盾 · 挡一发", 1.2) -- 2895
		self:log("架残盾") -- 2896
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 2897
		return -- 2898
	end -- 2898
	if inv.pass > 0 and self.run.joined == false then -- 2898
		inv.pass = inv.pass - 1 -- 2901
		self.run.joined = true -- 2902
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 2903
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 2904
		return -- 2905
	end -- 2905
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 2907
end -- 2852
function Play.prototype.useInteract(self, b) -- 2910
	local kind = b.interact == nil and "" or b.interact.kind -- 2911
	local wr = self.room -- 2912
	if kind == "open_board" then -- 2912
		b.broken = true -- 2914
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 2915
		for ____, cover in ipairs(self.boxes) do -- 2916
			if cover.id == "s2_board_cover" then -- 2916
				cover.broken = false -- 2918
				cover.hidden = false -- 2919
			end -- 2919
		end -- 2919
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 2922
		self.run.joined = true -- 2923
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 2924
		self:log("放下窗板") -- 2925
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 2926
		return -- 2927
	end -- 2927
	if kind == "lower_curtain" then -- 2927
		for ____, curtain in ipairs(self.boxes) do -- 2930
			if curtain.id == "c2_curtain" then -- 2930
				curtain.broken = false -- 2932
				curtain.hidden = false -- 2933
			end -- 2933
		end -- 2933
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 2936
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 2937
		self:log("放下木帘") -- 2938
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 2939
		return -- 2940
	end -- 2940
	if kind == "raise_latch" then -- 2940
		if wr.key == "c2-granary" and not self.cartDocked then -- 2940
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 2944
			return -- 2945
		end -- 2945
		b.broken = true -- 2947
		self.objectiveDone = true -- 2948
		if wr.key == "c1-yard" then -- 2948
			self.run.c1Latch = true -- 2951
			self.run.joined = true -- 2952
			for ____, door in ipairs(self.boxes) do -- 2953
				if door.id == "c1_door" then -- 2953
					door.broken = true -- 2955
				end -- 2955
			end -- 2955
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 2958
		else -- 2958
			self.run.c2Latch = true -- 2960
			self.run.joined = true -- 2961
		end -- 2961
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 2963
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 2964
		self:log("抬闩") -- 2965
		self:flashSet("抬闩 · 通路打开", 1.4) -- 2966
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 2967
	end -- 2967
end -- 2910
function Play.prototype.stepCampaignCart(self, dt, input) -- 2972
	local wr = self.room -- 2973
	local c = wr.cart -- 2974
	if c.bodyW <= 0 then -- 2974
		return -- 2976
	end -- 2976
	local p = self.player -- 2978
	local handleX = self.cartAxle + c.handleOffset -- 2979
	if not self.gripping then -- 2979
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 2979
			self.gripping = true -- 2983
			self:flashSet("握住车柄 · A/D 推", 1) -- 2984
		end -- 2984
		return -- 2986
	end -- 2986
	if input.interact.pressed then -- 2986
		self.gripping = false -- 2989
		self:flashSet("松手", 0.5) -- 2990
		return -- 2991
	end -- 2991
	if not self.cartDocked then -- 2991
		if input.moveX ~= 0 and not self:stuckCart() then -- 2991
			self.cartAxle = math.max( -- 2995
				c.startX, -- 2995
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 2995
			) -- 2995
		end -- 2995
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 2995
			self.cartExposed = true -- 3000
			local gun = nil -- 3001
			local gi = 0 -- 3002
			do -- 3002
				gi = 0 -- 3003
				while gi < #self.enemies do -- 3003
					local e = self.enemies[gi + 1] -- 3004
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3004
						gun = e -- 3006
						break -- 3007
					end -- 3007
					gi = gi + 1 -- 3003
				end -- 3003
			end -- 3003
			if gun ~= nil then -- 3003
				self:campaignEnemyFire(gun) -- 3011
			end -- 3011
		end -- 3011
		p.x = self.cartAxle + c.handleOffset -- 3014
		p.y = c.baseY -- 3015
		p.depth = c.depth or 0 -- 3016
		p.vx = 0 -- 3017
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3017
			self.cartAxle = c.endX -- 3019
			self.cartDocked = true -- 3020
			self.gripping = false -- 3021
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3022
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3023
			self:flashSet("车轮入窝", 1.2) -- 3024
			self:log("车轮入窝") -- 3025
		end -- 3025
	end -- 3025
end -- 2972
function Play.prototype.stuckCart(self) -- 3031
	local i = 0 -- 3032
	do -- 3032
		i = 0 -- 3033
		while i < #self.boxes do -- 3033
			do -- 3033
				local b = self.boxes[i + 1] -- 3034
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3034
					goto __continue479 -- 3036
				end -- 3036
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3038
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3038
					return true -- 3040
				end -- 3040
			end -- 3040
			::__continue479:: -- 3040
			i = i + 1 -- 3033
		end -- 3033
	end -- 3033
	return false -- 3043
end -- 3031
function Play.prototype.stepCampaignGoal(self) -- 3047
	local wr = self.room -- 3048
	local c = wr.campaign -- 3049
	if c == nil then -- 3049
		return -- 3051
	end -- 3051
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3051
		self.objectiveDone = true -- 3054
	end -- 3054
	if c.goal == "reach_exit" then -- 3054
		self.objectiveDone = true -- 3057
	end -- 3057
	if not self.objectiveDone then -- 3057
		return -- 3060
	end -- 3060
	local p = self.player -- 3062
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3063
	if p.x < c.exitX or not partnerOk then -- 3063
		return -- 3065
	end -- 3065
	if self.run.story.segments[wr.key] ~= true then -- 3065
		self.run.story.segments[wr.key] = true -- 3069
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3070
	end -- 3070
	if wr.key == "escort5" then -- 3070
		self.escortDone = true -- 3074
		self.run.story.escortDone = true -- 3075
	end -- 3075
	if c.next ~= nil and c.next ~= "" then -- 3075
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3078
		self:flashSet("过关 · " .. c.next, 1.2) -- 3079
	elseif not self.run.finished then -- 3079
		self.run.finished = true -- 3081
		self:flashSet( -- 3082
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3082
			2 -- 3082
		) -- 3082
		self:log("C2 灰盒完成") -- 3083
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3084
	end -- 3084
end -- 3047
function Play.prototype.stepCampaignPartner(self, dt) -- 3089
	local a = self.partner -- 3090
	local wr = self.room -- 3091
	local cp = wr.companion -- 3092
	if not a.alive then -- 3092
		return -- 3094
	end -- 3094
	local p = self.player -- 3096
	if self.craftBench.active then -- 3096
		a.vx = 0 -- 3099
		return -- 3100
	end -- 3100
	local wait = false -- 3102
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3103
	local targetDepth = p.depth -- 3104
	if self.run.joined == false then -- 3104
		wait = true -- 3106
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3107
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3108
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3108
		wait = true -- 3110
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3111
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3112
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3112
		wait = true -- 3114
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3115
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3116
	end -- 3116
	if self.partnerStuck > 0.3 then -- 3116
		a.x = a.x + a.facing * 44 -- 3120
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3121
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3122
		self.partnerLaneHold = 1.1 -- 3123
		self.partnerStuck = 0 -- 3124
	end -- 3124
	if self.partnerLaneHold > 0 then -- 3124
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3127
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3128
	end -- 3128
	local dx = targetX - a.x -- 3130
	if not wait and math.abs(dx) > 74 then -- 3130
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3132
		local before = a.x -- 3133
		a.vx = dx > 0 and speed or -speed -- 3134
		a.facing = dx > 0 and 1 or -1 -- 3135
		self:slideX(a, a.vx * dt) -- 3136
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3136
			a.vy = CHILD_JUMP -- 3139
			a.onGround = false -- 3140
		end -- 3140
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3142
	else -- 3142
		a.vx = 0 -- 3144
		self.partnerStuck = 0 -- 3145
	end -- 3145
	local dz = targetDepth - a.depth -- 3147
	if math.abs(dz) > 6 then -- 3147
		local step = math.max( -- 3149
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3149
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3149
		) -- 3149
		a.depth = a.depth + step -- 3150
	end -- 3150
	a.depthSpeed = 0 -- 3152
	a.h = CHILD_H -- 3153
	a.crouch = false -- 3154
	self:fallY(a, dt) -- 3155
end -- 3089
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3159
	local p = self.player -- 3160
	local i = 0 -- 3161
	do -- 3161
		i = 0 -- 3162
		while i < #self.enemies do -- 3162
			do -- 3162
				local ____opt_49 = self.run.trial -- 3162
				if ____opt_49 and ____opt_49.lost then -- 3162
					return -- 3163
				end -- 3163
				local e = self.enemies[i + 1] -- 3164
				if not e.alive then -- 3164
					goto __continue506 -- 3166
				end -- 3166
				if e.hitT > 0 then -- 3166
					e.hitT = e.hitT - dt -- 3169
				end -- 3169
				if e.kind == "target" then -- 3169
					if not e.alive and e.hitT <= 0 then -- 3169
						e.alive = true -- 3174
					end -- 3174
					goto __continue506 -- 3176
				end -- 3176
				if e.kind == "breaker" then -- 3176
					self:stepBreaker(e, dt) -- 3179
					goto __continue506 -- 3180
				end -- 3180
				if e.kind == "shield" then -- 3180
					self:stepShield(e, dt, input) -- 3183
					goto __continue506 -- 3184
				end -- 3184
				local dx = e.x - p.x -- 3187
				if not e.awake then -- 3187
					if math.abs(dx) > 520 then -- 3187
						goto __continue506 -- 3190
					end -- 3190
					e.awake = true -- 3192
					e.fireCd = 48 -- 3193
					goto __continue506 -- 3194
				end -- 3194
				if math.abs(dx) > ENEMY_RANGE then -- 3194
					goto __continue506 -- 3197
				end -- 3197
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 3197
					goto __continue506 -- 3202
				end -- 3202
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 3202
					goto __continue506 -- 3205
				end -- 3205
				if self:blockedShot(e, p) then -- 3205
					if e.warnT > 0 then -- 3205
						e.warnT = 0 -- 3211
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3212
					end -- 3212
					goto __continue506 -- 3214
				end -- 3214
				if e.warnT > 0 then -- 3214
					e.warnT = e.warnT - 1 -- 3217
					if e.warnT <= 0 then -- 3217
						self:campaignEnemyFire(e) -- 3219
					end -- 3219
				elseif e.fireCd > 0 then -- 3219
					e.fireCd = e.fireCd - 1 -- 3222
					if e.fireCd <= 0 then -- 3222
						e.warnT = WARN_TICKS -- 3224
					end -- 3224
				else -- 3224
					e.fireCd = 40 -- 3227
				end -- 3227
			end -- 3227
			::__continue506:: -- 3227
			i = i + 1 -- 3162
		end -- 3162
	end -- 3162
end -- 3159
function Play.prototype.blockedShot(self, e, p) -- 3233
	local eDepth = e.depth or 0 -- 3234
	local ex = e.x -- 3235
	local ey = e.y + e.h * 0.62 -- 3237
	local px = p.x -- 3238
	local py = p.y + p.h * 0.55 -- 3239
	local dx = px - ex -- 3240
	local dyScreen = py + p.depth - (ey + eDepth) -- 3241
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3242
	if len < 0.01 then -- 3242
		return false -- 3244
	end -- 3244
	local ray = { -- 3248
		x = ex, -- 3249
		y = ey, -- 3249
		dx = dx / len, -- 3250
		dy = (py - ey) / len, -- 3250
		depth = eDepth, -- 3251
		dDepth = (p.depth - eDepth) / len -- 3251
	} -- 3251
	local best = -1 -- 3253
	local j = 0 -- 3254
	do -- 3254
		j = 0 -- 3255
		while j < #self.boxes do -- 3255
			do -- 3255
				local b = self.boxes[j + 1] -- 3256
				if b.broken == true or b.passable == true or b.hidden == true then -- 3256
					goto __continue529 -- 3258
				end -- 3258
				if b.id == "braced_shield" then -- 3258
					goto __continue529 -- 3263
				end -- 3263
				local t = hitBox(ray, b) -- 3265
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3265
					best = t -- 3269
				end -- 3269
			end -- 3269
			::__continue529:: -- 3269
			j = j + 1 -- 3255
		end -- 3255
	end -- 3255
	return best >= 0 -- 3272
end -- 3233
function Play.prototype.campaignEnemyFire(self, e) -- 3275
	local p = self.player -- 3276
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3277
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3277
		local ____self_bracedShield_51, ____hp_52 = self.bracedShield, "hp" -- 3277
		____self_bracedShield_51[____hp_52] = ____self_bracedShield_51[____hp_52] - 1 -- 3279
		self.boxes = __TS__ArrayFilter( -- 3280
			self.boxes, -- 3280
			function(____, b) return b.id ~= "braced_shield" end -- 3280
		) -- 3280
		self.bracedShield = nil -- 3281
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3282
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3283
		return -- 3284
	end -- 3284
	if self:blockedShot(e, p) then -- 3284
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3287
		return -- 3288
	end -- 3288
	local cover = self:blockedByCover(e, p) -- 3290
	if cover ~= nil and self.coverHug then -- 3290
		self.coveredFlash = 0.5 -- 3292
		self:flashSet("掩体挡下", 0.6) -- 3293
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3294
		return -- 3299
	end -- 3299
	if self.invulnT > 0 then -- 3299
		return -- 3302
	end -- 3302
	local ____opt_53 = self.run.trial -- 3302
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_53 and ____opt_53.ranks.guard or 0) -- 3304
	self.craftT = 0 -- 3305
	self.hp = self.hp - 1 -- 3306
	self:emit("actorHit", { -- 3307
		target = "player", -- 3307
		amount = 1, -- 3307
		hp = self.hp, -- 3307
		maxHp = self.maxHp, -- 3307
		enemyX = e.x -- 3307
	}) -- 3307
	self:flashSet( -- 3308
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3308
		0.8 -- 3308
	) -- 3308
	if self.hp <= 0 then -- 3308
		self:campaignFailed() -- 3310
	end -- 3310
end -- 3275
function Play.prototype.stepShield(self, e, dt, input) -- 3315
	local p = self.player -- 3316
	local dx = p.x - e.x -- 3317
	local adx = math.abs(dx) -- 3318
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 3321
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 3322
	if adx > 150 then -- 3322
		local before = e.x -- 3324
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 3325
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 3325
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3328
		end -- 3328
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 3328
		local fromFront = (e.x - p.x) * p.facing > 0 -- 3333
		local rollDodges = p.rollT > 0 and fromFront -- 3334
		if not rollDodges and self.invulnT <= 0 then -- 3334
			local ____opt_55 = self.run.trial -- 3334
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_55 and ____opt_55.ranks.guard or 0) -- 3336
			self.craftT = 0 -- 3337
			self.hp = self.hp - 1 -- 3338
			self:emit("actorHit", { -- 3339
				target = "player", -- 3339
				amount = 1, -- 3339
				hp = self.hp, -- 3339
				maxHp = self.maxHp, -- 3339
				enemyX = e.x -- 3339
			}) -- 3339
			self:flashSet( -- 3340
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3340
				0.8 -- 3340
			) -- 3340
			if self.hp <= 0 then -- 3340
				self:campaignFailed() -- 3342
				return -- 3343
			end -- 3343
		end -- 3343
		e.swingT = 70 -- 3346
	end -- 3346
	if (e.swingT or 0) > 0 then -- 3346
		e.swingT = (e.swingT or 0) - 1 -- 3349
	end -- 3349
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 3349
		local dd = p.depth - (e.depth or 0) -- 3352
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 3353
	end -- 3353
end -- 3315
function Play.prototype.stepBreaker(self, e, dt) -- 3358
	local p = self.player -- 3359
	if e.awake ~= true then -- 3359
		if math.abs(p.x - e.x) < 560 then -- 3359
			e.awake = true -- 3362
		else -- 3362
			return -- 3364
		end -- 3364
	end -- 3364
	local target = nil -- 3367
	local bestD = 1000000000 -- 3368
	local i = 0 -- 3369
	do -- 3369
		i = 0 -- 3370
		while i < #self.boxes do -- 3370
			do -- 3370
				local b = self.boxes[i + 1] -- 3371
				if b.breakable == nil or b.broken == true then -- 3371
					goto __continue553 -- 3373
				end -- 3373
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 3375
				if d < bestD then -- 3375
					bestD = d -- 3377
					target = b -- 3378
				end -- 3378
			end -- 3378
			::__continue553:: -- 3378
			i = i + 1 -- 3370
		end -- 3370
	end -- 3370
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 3381
	local dx = tx - e.x -- 3382
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 3383
	if math.abs(dx) > reach then -- 3383
		local before = e.x -- 3385
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 3386
		if math.abs(e.x - before) < 0.3 then -- 3386
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3388
		end -- 3388
	elseif (e.swingT or 0) <= 0 then -- 3388
		e.swingT = 64 -- 3391
		if target ~= nil then -- 3391
			self:damageProp(target, 2) -- 3393
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 3393
			local ____opt_57 = self.run.trial -- 3393
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_57 and ____opt_57.ranks.guard or 0) -- 3395
			self.craftT = 0 -- 3396
			self.hp = self.hp - 1 -- 3397
			self:emit("actorHit", { -- 3398
				target = "player", -- 3398
				amount = 1, -- 3398
				hp = self.hp, -- 3398
				maxHp = self.maxHp, -- 3398
				enemyX = e.x -- 3398
			}) -- 3398
			self:flashSet("破障手近身", 0.8) -- 3399
			if self.hp <= 0 then -- 3399
				self:campaignFailed() -- 3401
				return -- 3402
			end -- 3402
		end -- 3402
	end -- 3402
	if (e.swingT or 0) > 0 then -- 3402
		e.swingT = (e.swingT or 0) - 1 -- 3407
	end -- 3407
end -- 3358
function Play.prototype.campaignFailed(self) -- 3411
	if self.run.trial ~= nil then -- 3411
		self.run.trial.lost = true -- 3413
		self.wantRoom = "" -- 3414
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3415
		return -- 3416
	end -- 3416
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 3416
		self:restartEscortFromDeath() -- 3421
		return -- 3422
	end -- 3422
	local p = self.player -- 3424
	self.hp = self.maxHp -- 3425
	self.invulnT = INVULN_RESPAWN_TICKS -- 3426
	self.reloadT = 0 -- 3427
	self:closeReloadPuzzle() -- 3428
	self.gripping = false -- 3429
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 3430
	self:log("被击倒") -- 3431
	p.x = self.room.minX + 90 -- 3432
	p.y = 0 -- 3433
	p.depth = 0 -- 3434
	p.vx = 0 -- 3435
	p.vy = 0 -- 3436
	p.onGround = true -- 3437
	p.rollT = 0 -- 3438
	self.partner.x = p.x - 50 -- 3439
	self.partner.y = 0 -- 3440
	self.partner.depth = 0 -- 3441
	self.cam.x = p.x -- 3442
	local i = 0 -- 3443
	do -- 3443
		i = 0 -- 3444
		while i < #self.enemies do -- 3444
			do -- 3444
				local e = self.enemies[i + 1] -- 3445
				if not e.alive then -- 3445
					goto __continue567 -- 3447
				end -- 3447
				e.x = e.homeX == nil and e.x or e.homeX -- 3449
				e.warnT = 0 -- 3450
				e.fireCd = 40 -- 3451
				e.swingT = 0 -- 3452
				e.awake = false -- 3453
			end -- 3453
			::__continue567:: -- 3453
			i = i + 1 -- 3444
		end -- 3444
	end -- 3444
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3455
end -- 3411
function Play.prototype.isEscortRoom(self) -- 3459
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 3460
end -- 3459
function Play.prototype.restartEscortFromDeath(self) -- 3468
	local story = self.run.story -- 3469
	local inv = self.run.inventory -- 3470
	self.hp = self.maxHp -- 3471
	story.hp = self.maxHp -- 3472
	story.cp = nil -- 3473
	self.checkpointSnap = nil -- 3474
	story.carry = false -- 3475
	self.carryOn = false -- 3476
	story.craftedWeapon = "" -- 3477
	self.equippedWeapon = "standard_gun" -- 3478
	story.escortDone = false -- 3479
	self.escortDone = false -- 3480
	story.segments = {} -- 3481
	inv.wood = 0 -- 3482
	inv.bell = 0 -- 3483
	inv.scrap = 0 -- 3484
	inv.wedge = 0 -- 3485
	inv.ammo = 0 -- 3486
	inv.quickbelt = 0 -- 3487
	inv.shield = 0 -- 3488
	inv.pass = 0 -- 3489
	local taken = self.run.taken -- 3490
	local keys = __TS__ObjectKeys(taken) -- 3491
	local i = 0 -- 3492
	do -- 3492
		i = 0 -- 3493
		while i < #keys do -- 3493
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 3493
				__TS__Delete(taken, keys[i + 1]) -- 3495
			end -- 3495
			i = i + 1 -- 3493
		end -- 3493
	end -- 3493
	self.run.joined = true -- 3498
	self.reloadT = 0 -- 3499
	self:closeReloadPuzzle() -- 3500
	self.gripping = false -- 3501
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 3502
	self:log("男主线失败 · 回 escort1") -- 3503
	self:emit("campaignFailed", { -- 3504
		room = self.room.key, -- 3505
		hp = 0, -- 3505
		maxHp = self.maxHp, -- 3505
		reset = true, -- 3506
		to = "escort1", -- 3506
		route = self.storyRoute -- 3506
	}) -- 3506
	self:requestRoom("escort1", "男主线失败重开") -- 3508
end -- 3468
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 3512
	local i = 0 -- 3513
	do -- 3513
		i = 0 -- 3514
		while i < #self.enemies do -- 3514
			do -- 3514
				if i == skipIndex then -- 3514
					goto __continue576 -- 3516
				end -- 3516
				local e = self.enemies[i + 1] -- 3518
				if not e.alive or math.abs(e.x - center.x) > radius then -- 3518
					goto __continue576 -- 3520
				end -- 3520
				e.fireCd = 150 -- 3522
				e.warnT = 0 -- 3523
			end -- 3523
			::__continue576:: -- 3523
			i = i + 1 -- 3514
		end -- 3514
	end -- 3514
end -- 3512
function Play.prototype.stepEnemies(self, dt, input) -- 3527
	local i = 0 -- 3528
	do -- 3528
		i = 0 -- 3529
		while i < #self.enemies do -- 3529
			local e = self.enemies[i + 1] -- 3530
			if e.hitT > 0 then -- 3530
				e.hitT = e.hitT - dt -- 3532
			end -- 3532
			i = i + 1 -- 3529
		end -- 3529
	end -- 3529
	if self.coveredFlash > 0 then -- 3529
		self.coveredFlash = self.coveredFlash - dt -- 3536
	end -- 3536
	if self.isCampaign then -- 3536
		self:stepCampaignEnemies(dt, input) -- 3539
		return -- 3540
	end -- 3540
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 3540
		return -- 3544
	end -- 3544
	do -- 3544
		i = 0 -- 3546
		while i < #self.enemies do -- 3546
			do -- 3546
				local e = self.enemies[i + 1] -- 3547
				if not e.alive then -- 3547
					goto __continue587 -- 3549
				end -- 3549
				if e.warnT > 0 then -- 3549
					e.warnT = e.warnT - 1 -- 3552
					if e.warnT <= 0 then -- 3552
						self:enemyFire(e, input) -- 3554
					end -- 3554
					goto __continue587 -- 3556
				end -- 3556
				if e.fireCd > 0 then -- 3556
					e.fireCd = e.fireCd - 1 -- 3559
					if e.fireCd <= 0 then -- 3559
						e.warnT = WARN_TICKS -- 3561
					end -- 3561
				else -- 3561
					e.warnT = WARN_TICKS -- 3565
				end -- 3565
			end -- 3565
			::__continue587:: -- 3565
			i = i + 1 -- 3546
		end -- 3546
	end -- 3546
end -- 3527
function Play.prototype.enemyFire(self, e, input) -- 3571
	local p = self.player -- 3572
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 3572
		self:flashSet("枪声响在远处", 0.4) -- 3574
		e.fireCd = FIRE_COOLDOWN -- 3575
		return -- 3576
	end -- 3576
	local cover = self:blockedByCover(e, p) -- 3579
	local hugging = cover ~= nil -- 3580
	self.coverBlocking = hugging -- 3581
	local covered = hugging and input.cover.held -- 3582
	if covered then -- 3582
		self.coveredFlash = 0.5 -- 3584
		self:flashSet("掩体挡下", 0.5) -- 3585
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3586
		e.fireCd = FIRE_COOLDOWN -- 3591
		return -- 3592
	end -- 3592
	self.hp = self.hp - 1 -- 3594
	self:emit("actorHit", { -- 3595
		target = "player", -- 3595
		amount = 1, -- 3595
		hp = self.hp, -- 3595
		maxHp = self.maxHp, -- 3595
		enemyX = e.x -- 3595
	}) -- 3595
	self:flashSet( -- 3596
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3596
		0.7 -- 3596
	) -- 3596
	e.fireCd = FIRE_COOLDOWN -- 3597
	if self.hp <= 0 then -- 3597
		self:gateFailed() -- 3599
	end -- 3599
end -- 3571
function Play.prototype.blockedByCover(self, enemy, p) -- 3604
	local b = self:coverAt(p) -- 3605
	if b == nil then -- 3605
		return nil -- 3607
	end -- 3607
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 3609
end -- 3604
function Play.prototype.gateFailed(self) -- 3613
	local ____temp_59 -- 3614
	if self.room.story == nil then -- 3614
		____temp_59 = nil -- 3614
	else -- 3614
		____temp_59 = self.room.story.gate -- 3614
	end -- 3614
	local g = ____temp_59 -- 3614
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 3615
	self.hp = self.maxHp -- 3616
	self.gateTick = 0 -- 3617
	self.gateSpawned = 0 -- 3618
	self.enemies = {} -- 3619
	self.gateFailCount = self.gateFailCount + 1 -- 3620
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 3622
	self.player.y = 0 -- 3623
	self.player.vy = 0 -- 3624
	self.player.depth = 0 -- 3625
	self.player.depthSpeed = 0 -- 3626
	self.player.onGround = true -- 3627
	self.player.crouch = false -- 3628
	self.player.h = SOLDIER_H -- 3629
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 3630
	self.partner.y = 0 -- 3631
	self.partner.vy = 0 -- 3632
	self.partner.depth = 0 -- 3633
	self.partner.depthSpeed = 0 -- 3634
	self.partner.onGround = true -- 3635
	self.cam.x = self.player.x -- 3636
	self.phase = "gate-idle" -- 3637
	self.phaseTick = 0 -- 3638
	self.coverHug = false -- 3639
	self.coverBlocking = false -- 3640
	self.coverEntity = "" -- 3641
	self.gateNeedConfirm = true -- 3642
	self.gateRestartArmed = false -- 3643
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 3644
end -- 3613
function Play.prototype.stepInteract(self, dt, input) -- 3647
	local p = self.player -- 3648
	local calmUsed = self.calmConsumed -- 3649
	self.calmConsumed = false -- 3650
	local calming = self.escort.state == "calming" -- 3652
	self.focusCart = false -- 3653
	if self.room.key == "outside" then -- 3653
		local c = self.room.cart -- 3655
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 3656
		local dy = p.y - c.baseY -- 3657
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 3658
	end -- 3658
	if not calmUsed and not calming then -- 3658
		self:stepCart(dt, input) -- 3662
	end -- 3662
	if calmUsed then -- 3662
		self:flashSet("安抚 · 敲两下", 0.8) -- 3667
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 3667
		if self.knockT > 0 then -- 3667
			self.knocks = self.knocks + 1 -- 3671
		else -- 3671
			self.knocks = 1 -- 3673
		end -- 3673
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 3675
		self.knockT = 1.2 -- 3676
		if self.knocks >= 2 then -- 3676
			self:flashSet("敲两下", 0.8) -- 3678
			self.knocks = 0 -- 3679
		else -- 3679
			self:flashSet("敲一下", 0.5) -- 3681
		end -- 3681
	elseif self.knockT > 0 then -- 3681
		self.knockT = self.knockT - dt -- 3684
		if self.knockT <= 0 then -- 3684
			self.knocks = 0 -- 3686
		end -- 3686
	end -- 3686
	local i = 0 -- 3691
	do -- 3691
		i = 0 -- 3692
		while i < #self.room.marks do -- 3692
			do -- 3692
				local m = self.room.marks[i + 1] -- 3693
				if m.kind ~= 0 then -- 3693
					goto __continue613 -- 3695
				end -- 3695
				local subjects = {self.partner, self.player} -- 3697
				local k = 0 -- 3698
				do -- 3698
					k = 0 -- 3699
					while k < #subjects do -- 3699
						do -- 3699
							local s = subjects[k + 1] -- 3700
							if not s.alive then -- 3700
								goto __continue616 -- 3702
							end -- 3702
							local dx = s.x - m.x -- 3704
							local dy = s.y - m.y -- 3705
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3705
								self.checkpoint = m.x -- 3707
								self.checkpointCartAxle = self.cartAxle -- 3708
								if self.isCampaign then -- 3708
									self:captureCheckpoint(m.x) -- 3711
								end -- 3711
								if self.cartDocked then -- 3711
									self:flashSet("检查点 · 车已落窝", 1) -- 3714
								else -- 3714
									self:flashSet("检查点 · 车还没到位", 1) -- 3716
								end -- 3716
							end -- 3716
						end -- 3716
						::__continue616:: -- 3716
						k = k + 1 -- 3699
					end -- 3699
				end -- 3699
			end -- 3699
			::__continue613:: -- 3699
			i = i + 1 -- 3692
		end -- 3692
	end -- 3692
	self:checkCarryGate() -- 3722
end -- 3647
function Play.prototype.stepVillage(self, dt, input) -- 3726
	if self.room.key ~= "village" then -- 3726
		return -- 3728
	end -- 3728
	local p = self.player -- 3730
	local bottle = self.room.bottle -- 3731
	local scav = self.room.scavenger -- 3732
	if not self.hasBottle and bottle ~= nil then -- 3732
		local dx = p.x - bottle.x -- 3736
		local dy = p.y + p.h * 0.5 - bottle.y -- 3737
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 3737
			self.hasBottle = true -- 3739
			self:flashSet("拾起瓶子", 0.8) -- 3740
		end -- 3740
	end -- 3740
	if self.hasBottle then -- 3740
		if input.aim.held then -- 3740
			self.aimHold = self.aimHold + dt -- 3747
			if self.aimHold > 1.2 then -- 3747
				self.aimHold = 1.2 -- 3749
			end -- 3749
			local cached = self:bottleEnd() -- 3752
			self.bottleAimX = cached.x -- 3753
			self.bottleAimY = cached.y -- 3754
		elseif input.aim.released then -- 3754
			if self.aimHold < 0.12 then -- 3754
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 3758
				self.aimHold = 0 -- 3759
			else -- 3759
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3761
				self:throwBottle(____end.x, ____end.y) -- 3762
				self.aimHold = 0 -- 3763
			end -- 3763
		end -- 3763
	else -- 3763
		self.aimHold = 0 -- 3767
		self.bottleAimX = -1 -- 3768
	end -- 3768
	local fly = self.bottleFly -- 3773
	if fly ~= nil then -- 3773
		fly.t = fly.t + dt -- 3775
		fly.x = fly.x0 + fly.vx * fly.t -- 3776
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 3777
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 3778
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 3778
			self:landBottle(fly) -- 3780
		end -- 3780
	end -- 3780
	if self.bottleLandT > 0 then -- 3780
		self.bottleLandT = self.bottleLandT - dt -- 3784
	end -- 3784
	if scav ~= nil then -- 3784
		self:stepScav(dt, scav) -- 3788
	end -- 3788
	local line = self.room.passLine -- 3791
	if line ~= nil and not self.passed and p.x >= line then -- 3791
		self.passed = true -- 3793
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 3794
	end -- 3794
	if self.passed and p.x >= self.ox + 640 then -- 3794
		self:requestRoom("forest", "过第一院出院") -- 3798
		self:flashSet("出院 · 北塔森林", 1.4) -- 3799
	end -- 3799
end -- 3726
function Play.prototype.bottleEnd(self) -- 3804
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3805
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 3808
	return {x = aim.x, y = g} -- 3809
end -- 3804
function Play.prototype.throwBottle(self, tx, ty) -- 3813
	local p = self.player -- 3814
	local dir = tx >= p.x and 1 or -1 -- 3816
	p.facing = dir -- 3817
	local x0 = p.x + dir * 10 -- 3818
	local y0 = p.y + p.h * 0.7 -- 3819
	self.bottleTargetX = tx -- 3820
	self.bottleTargetY = ty -- 3821
	self.bottleSurfaceY = ty -- 3822
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 3823
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 3824
	self.bottleFly = { -- 3825
		x = x0, -- 3825
		y = y0, -- 3825
		x0 = x0, -- 3825
		y0 = y0, -- 3825
		vx = vx, -- 3825
		vy = vy, -- 3825
		t = 0 -- 3825
	} -- 3825
	self.hasBottle = false -- 3826
	self:flashSet("投出", 0.4) -- 3827
	self:emit( -- 3828
		"bottleThrown", -- 3828
		{ -- 3828
			fromX = x0, -- 3829
			fromY = y0, -- 3830
			targetX = tx, -- 3831
			targetY = ty, -- 3832
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 3833
		} -- 3833
	) -- 3833
end -- 3813
function Play.prototype.landBottle(self, fly) -- 3838
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 3839
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 3840
	local s = self.room.scavenger -- 3841
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 3842
	self.bottleFly = nil -- 3843
	self.bottleTargetX = -1 -- 3844
	self.bottleTargetY = 0 -- 3845
	self.bottleSurfaceY = -1 -- 3846
	self.bottleLandX = x -- 3847
	self.bottleLandY = y -- 3848
	self.bottleLandT = 0.9 -- 3849
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 3850
	self:hearBottle(x) -- 3851
end -- 3838
function Play.prototype.hearBottle(self, x) -- 3855
	local s = self.room.scavenger -- 3856
	if s == nil then -- 3856
		return -- 3858
	end -- 3858
	if math.abs(x - self.scavX) > s.range then -- 3858
		self:flashSet("落地 · 他没听见", 0.6) -- 3861
		return -- 3862
	end -- 3862
	self.scavState = "turn" -- 3864
	self.scavT = s.hearTicks -- 3865
	self.scavTargetX = x -- 3866
	self:flashSet("砖地一响 · 他转头", 0.9) -- 3867
end -- 3855
function Play.prototype.stepScav(self, dt, s) -- 3871
	if self.scavState == "chase" then -- 3871
		return -- 3874
	end -- 3874
	if self.scavState == "turn" then -- 3874
		self.scavT = self.scavT - 1 -- 3877
		if self.scavT <= 0 then -- 3877
			self.scavState = "walk" -- 3879
		end -- 3879
		return -- 3881
	end -- 3881
	if self.scavState == "walk" then -- 3881
		local d = self.scavTargetX - self.scavX -- 3884
		if math.abs(d) < 4 then -- 3884
			self.scavState = "stall" -- 3886
			self.scavT = s.stallTicks -- 3887
			return -- 3888
		end -- 3888
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 3890
		return -- 3891
	end -- 3891
	if self.scavState == "stall" then -- 3891
		self.scavT = self.scavT - 1 -- 3894
		if self.scavT <= 0 then -- 3894
			self.scavState = "back" -- 3896
		end -- 3896
		return -- 3898
	end -- 3898
	if self.scavState == "back" then -- 3898
		local home = math.max( -- 3901
			s.x0, -- 3901
			math.min(s.x1, self.scavX) -- 3901
		) -- 3901
		if math.abs(home - self.scavX) < 2 then -- 3901
			self.scavState = "patrol" -- 3903
			return -- 3904
		end -- 3904
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 3906
		return -- 3907
	end -- 3907
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 3909
	if self.scavX >= s.x1 then -- 3909
		self.scavX = s.x1 -- 3911
		self.scavDir = -1 -- 3912
	elseif self.scavX <= s.x0 then -- 3912
		self.scavX = s.x0 -- 3914
		self.scavDir = 1 -- 3915
	end -- 3915
end -- 3871
function Play.prototype.stepCart(self, dt, input) -- 3923
	local p = self.player -- 3924
	local c = self.room.cart -- 3925
	if self.gripping then -- 3925
		if not input.interact.held then -- 3925
			self.gripping = false -- 3929
			self:flashSet("松开车把", 0.4) -- 3930
			return -- 3931
		end -- 3931
	else -- 3931
		if not input.interact.pressed then -- 3931
			return -- 3935
		end -- 3935
		if not self:cartHandleInReach(p) then -- 3935
			return -- 3938
		end -- 3938
		local track = c.depth or 0 -- 3940
		if self:limitDepth(p, track) ~= track then -- 3940
			return -- 3942
		end -- 3942
		p.depth = track -- 3944
		p.depthSpeed = 0 -- 3945
		self.gripping = true -- 3946
		self:flashSet("握住车把", 0.4) -- 3947
		return -- 3948
	end -- 3948
	if self.cartDocked then -- 3948
		return -- 3952
	end -- 3952
	local dir = input.moveX -- 3954
	if dir == 0 then -- 3954
		return -- 3956
	end -- 3956
	local lo = math.min(c.startX, c.endX) -- 3958
	local hi = math.max(c.startX, c.endX) -- 3959
	local next = self.cartAxle + dir * CART_SPEED * dt -- 3960
	if next < lo then -- 3960
		next = lo -- 3962
	end -- 3962
	if next > hi then -- 3962
		next = hi -- 3965
	end -- 3965
	local delta = next - self.cartAxle -- 3967
	if delta == 0 then -- 3967
		return -- 3969
	end -- 3969
	self.cartAxle = next -- 3971
	p.x = p.x + delta -- 3972
	p.facing = dir > 0 and 1 or -1 -- 3973
	self:slideX(p, 0) -- 3974
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 3974
		self.gripping = false -- 3976
		self:flashSet("跟不上了，脱手", 0.6) -- 3977
		return -- 3978
	end -- 3978
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 3978
		self.cartDocked = true -- 3981
		self.gripping = false -- 3982
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 3983
		self:flashSet("车轮落窝", 1.2) -- 3984
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 3984
		self:flashSet("车轮回到起点", 0.5) -- 3986
	end -- 3986
end -- 3923
function Play.prototype.requestRoom(self, key, reason) -- 3994
	if self.wantRoom ~= "" then -- 3994
		return -- 3998
	end -- 3998
	self.wantRoom = key -- 4000
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 4001
end -- 3994
function Play.prototype.checkCarryGate(self) -- 4008
	if self.room.key == "checkpoint" then -- 4008
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 4008
			self.carryCartAxle = self.cartAxle -- 4011
			self.carryCartDocked = self.cartDocked -- 4012
			self:requestRoom("gate", "检查站出口") -- 4013
			self:flashSet("出检查站 · 城门", 1.2) -- 4014
		end -- 4014
		return -- 4016
	end -- 4016
	if self.room.key == "outside" then -- 4016
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 4016
			self.carryCartAxle = self.cartAxle -- 4022
			self.carryCartDocked = self.cartDocked -- 4023
			self:requestRoom("village", "墙根走完") -- 4024
			self:flashSet("墙根走完 · 进村口", 1.2) -- 4025
		end -- 4025
	end -- 4025
end -- 4008
function Play.prototype.aimAt(self, wx, wy) -- 4032
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 4033
	self.aimX = s.x -- 4034
	self.aimY = s.y -- 4035
end -- 4032
function Play.prototype.shoot(self, a) -- 4038
	if self.isCampaign and self.reloadT > 0 then -- 4038
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 4040
		return -- 4041
	end -- 4041
	local ox = a.x + a.facing * 8 -- 4043
	local muzzleY = a.y + a.h * 0.72 -- 4044
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 4045
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4047
	local dx = aim.x - ox -- 4050
	local dy = aim.y - oy -- 4051
	local len = math.sqrt(dx * dx + dy * dy) -- 4052
	if len < 0.001 then -- 4052
		dx = a.facing -- 4054
		dy = 0 -- 4055
	else -- 4055
		dx = dx / len -- 4057
		dy = dy / len -- 4058
	end -- 4058
	if dx ~= 0 then -- 4058
		a.facing = dx > 0 and 1 or -1 -- 4061
	end -- 4061
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 4064
	local hitEnemy = self:raycastEnemies(ray) -- 4065
	local tEnemy = hitEnemy.t -- 4066
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 4067
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 4068
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 4069
	local tWall = solid.t -- 4070
	local rawEffect = self:consumeReloadEffect() -- 4072
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 4073
	local reloadEffect = rawEffect -- 4074
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 4076
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 4077
	self.trace = { -- 4079
		x0 = ox, -- 4079
		y0 = oy, -- 4079
		x1 = ox + dx * t, -- 4079
		y1 = oy + dy * t, -- 4079
		hit = hit -- 4079
	} -- 4079
	self.traceT = 0.12 -- 4080
	self:applyFireDanger(ox) -- 4081
	local killed = false -- 4082
	if hit then -- 4082
		local i = hitEnemy.index -- 4084
		local e = self.enemies[i + 1] -- 4085
		local impactY = oy + dy * tEnemy -- 4086
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 4087
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 4088
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 4088
			e.shieldHp = (e.shieldHp or 0) - 1 -- 4090
			e.hitT = 0.3 -- 4091
			self:flashSet( -- 4092
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 4092
				0.8 -- 4092
			) -- 4092
			self:emit("shotResolved", { -- 4093
				hit = true, -- 4094
				enemyIndex = i, -- 4094
				enemyX = e.x, -- 4094
				aimX = aim.x, -- 4094
				aimY = aim.y, -- 4094
				impactX = ox + dx * t, -- 4095
				impactY = oy + dy * t, -- 4095
				shield = true -- 4095
			}) -- 4095
			self:beginReload() -- 4097
			return -- 4098
		end -- 4098
		e.alive = false -- 4100
		e.hitT = 0.4 -- 4101
		killed = true -- 4102
		self:flashSet("命中", 0.6) -- 4103
		self:dropFor(e) -- 4104
		if reloadEffect == "light" and weaponFx == "light" then -- 4104
			self:blindNearby(e, 160, i) -- 4106
		end -- 4106
		if reloadEffect == "push" then -- 4106
			e.x = e.x + a.facing * 46 -- 4109
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4110
		elseif reloadEffect == "echo" then -- 4110
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 4112
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 4113
		elseif reloadEffect == "light" then -- 4113
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 4115
		end -- 4115
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 4115
		self:damageProp(solid.box, 1) -- 4118
	else -- 4118
		self:flashSet("打空", 0.35) -- 4120
	end -- 4120
	if self.isCampaign then -- 4120
		self:beginReload() -- 4123
	end -- 4123
	self:emit("shotResolved", { -- 4125
		hit = hit, -- 4126
		enemyIndex = hit and hitEnemy.index or -1, -- 4127
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 4128
		aimX = aim.x, -- 4129
		aimY = aim.y, -- 4130
		impactX = ox + dx * t, -- 4131
		impactY = oy + dy * t -- 4132
	}) -- 4132
end -- 4038
function Play.prototype.applyFireDanger(self, shotX) -- 4137
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 4137
		return -- 4139
	end -- 4139
	local dangerX = shotX -- 4141
	local best = -1 -- 4142
	local bestD = 1000000000 -- 4143
	local i = 0 -- 4144
	do -- 4144
		i = 0 -- 4145
		while i < #self.enemies do -- 4145
			do -- 4145
				local e = self.enemies[i + 1] -- 4146
				if not e.alive then -- 4146
					goto __continue697 -- 4148
				end -- 4148
				local d = math.abs(e.x - self.partner.x) -- 4150
				if d < bestD then -- 4150
					bestD = d -- 4152
					best = i -- 4153
				end -- 4153
			end -- 4153
			::__continue697:: -- 4153
			i = i + 1 -- 4145
		end -- 4145
	end -- 4145
	if best >= 0 then -- 4145
		dangerX = self.enemies[best + 1].x -- 4157
	end -- 4157
	local exposed = self:childExposed(dangerX) -- 4159
	local before = self.escort.fear -- 4160
	local dangerId = self.nextDangerId -- 4161
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 4162
	self.nextDangerId = self.nextDangerId + 1 -- 4163
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 4164
	if after > before then -- 4164
		self:flashSet( -- 4166
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 4166
			1 -- 4166
		) -- 4166
	elseif not exposed then -- 4166
		self:flashSet("枪声没够到她", 0.5) -- 4168
	end -- 4168
end -- 4137
function Play.prototype.childExposed(self, dangerX) -- 4173
	local c = self.partner -- 4174
	if not c.alive then -- 4174
		return false -- 4176
	end -- 4176
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 4176
		self.boxes, -- 4179
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 4179
	) then -- 4179
		return false -- 4180
	end -- 4180
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 4180
		return false -- 4183
	end -- 4183
	local toDanger = dangerX - c.x -- 4185
	local toPlayer = self.player.x - c.x -- 4186
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 4186
		return false -- 4189
	end -- 4189
	return true -- 4191
end -- 4173
function Play.prototype.raycastEnemies(self, ray) -- 4195
	local best = -1 -- 4196
	local bestI = -1 -- 4197
	do -- 4197
		local i = 0 -- 4198
		while i < #self.enemies do -- 4198
			do -- 4198
				local e = self.enemies[i + 1] -- 4199
				if not e.alive then -- 4199
					goto __continue711 -- 4201
				end -- 4201
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 4203
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 4204
				if t >= 0 and (best < 0 or t < best) then -- 4204
					best = t -- 4206
					bestI = i -- 4207
				end -- 4207
			end -- 4207
			::__continue711:: -- 4207
			i = i + 1 -- 4198
		end -- 4198
	end -- 4198
	return {t = best, index = bestI} -- 4210
end -- 4195
function Play.prototype.raycastWorld(self, ray) -- 4213
	return self:raycastSolid(ray).t -- 4214
end -- 4213
function Play.prototype.raycastSolid(self, ray) -- 4218
	local best = -1 -- 4219
	local bestBox = nil -- 4220
	for ____, box in ipairs(self.boxes) do -- 4221
		do -- 4221
			if box.broken == true or box.hidden == true then -- 4221
				goto __continue716 -- 4223
			end -- 4223
			local t = hitBox(ray, box) -- 4228
			if t > 2 and (best < 0 or t < best) then -- 4228
				best = t -- 4231
				bestBox = box -- 4232
			end -- 4232
		end -- 4232
		::__continue716:: -- 4232
	end -- 4232
	if ray.dy < 0 then -- 4232
		local t = -ray.y / ray.dy -- 4236
		if t >= 0 and (best < 0 or t < best) then -- 4236
			best = t -- 4238
			bestBox = nil -- 4239
		end -- 4239
	end -- 4239
	return {t = best, box = bestBox} -- 4242
end -- 4218
function Play.prototype.dropFor(self, e) -- 4246
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 4246
		return -- 4248
	end -- 4248
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 4248
		return -- 4251
	end -- 4251
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 4253
	local ____self_pickups_60 = self.pickups -- 4253
	____self_pickups_60[#____self_pickups_60 + 1] = { -- 4254
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 4255
		kind = e.drop, -- 4255
		x = e.x, -- 4255
		y = e.y, -- 4255
		depth = e.depth, -- 4256
		label = label .. " ×1" -- 4256
	} -- 4256
	self:log("掉落 " .. label) -- 4258
end -- 4246
function Play.prototype.damageProp(self, b, amount) -- 4262
	if b.breakable == nil or b.broken == true then -- 4262
		return -- 4264
	end -- 4264
	local ____b_breakable_61, ____hp_62 = b.breakable, "hp" -- 4264
	____b_breakable_61[____hp_62] = ____b_breakable_61[____hp_62] - amount -- 4266
	if b.breakable.hp > 0 then -- 4266
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 4268
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 4269
		return -- 4270
	end -- 4270
	b.broken = true -- 4272
	for ____, other in ipairs(self.boxes) do -- 4273
		if other.id ~= nil and other.id == b.id then -- 4273
			other.broken = true -- 4275
		end -- 4275
	end -- 4275
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 4278
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 4279
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 4280
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 4281
end -- 4262
function Play.prototype.slideDepth(self, a, distance) -- 4285
	a.depth = self:limitDepth(a, a.depth + distance) -- 4286
end -- 4285
function Play.prototype.limitDepth(self, a, target) -- 4289
	local road = self.room.depth -- 4290
	if road == nil or target == a.depth then -- 4290
		return a.depth -- 4292
	end -- 4292
	local next = math.max( -- 4294
		road.min, -- 4294
		math.min(road.max, target) -- 4294
	) -- 4294
	local half = a.w / 2 -- 4295
	for ____, b in ipairs(self.boxes) do -- 4296
		do -- 4296
			local footprint = b.depth -- 4297
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4297
				goto __continue734 -- 4302
			end -- 4302
			local front = footprint.min - ACTOR_DEPTH_HALF -- 4304
			local back = footprint.max + ACTOR_DEPTH_HALF -- 4305
			if a.depth <= front and next > front then -- 4305
				next = front -- 4307
			elseif a.depth >= back and next < back then -- 4307
				next = back -- 4309
			end -- 4309
		end -- 4309
		::__continue734:: -- 4309
	end -- 4309
	return next -- 4312
end -- 4289
function Play.prototype.slideX(self, a, dx) -- 4316
	local nx = a.x + dx -- 4317
	local half = a.w / 2 -- 4318
	local room = self.room -- 4319
	nx = math.max( -- 4320
		room.minX + half, -- 4320
		math.min(room.maxX - half, nx) -- 4320
	) -- 4320
	local i = 0 -- 4321
	do -- 4321
		i = 0 -- 4322
		while i < #self.boxes do -- 4322
			do -- 4322
				local b = self.boxes[i + 1] -- 4323
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4323
					goto __continue741 -- 4325
				end -- 4325
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4325
					goto __continue741 -- 4328
				end -- 4328
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4328
					goto __continue741 -- 4331
				end -- 4331
				if nx + half > b.x0 and nx - half < b.x1 then -- 4331
					if a.x <= b.x0 then -- 4331
						nx = b.x0 - half -- 4335
					elseif a.x >= b.x1 then -- 4335
						nx = b.x1 + half -- 4337
					else -- 4337
						nx = a.x -- 4339
					end -- 4339
				end -- 4339
			end -- 4339
			::__continue741:: -- 4339
			i = i + 1 -- 4322
		end -- 4322
	end -- 4322
	if self.room.key == "outside" and not self.cartDocked and a.y < CART_CLEAR - 0.001 then -- 4322
		local bx0 = math.max(room.arch.x0, self.cartAxle - CART_HALF) -- 4346
		local bx1 = math.min(room.arch.x1, self.cartAxle + CART_HALF) -- 4347
		if bx1 > bx0 and nx + half > bx0 and nx - half < bx1 then -- 4347
			if a.x <= bx0 then -- 4347
				nx = bx0 - half -- 4350
			elseif a.x >= bx1 then -- 4350
				nx = bx1 + half -- 4352
			else -- 4352
				nx = a.x -- 4354
			end -- 4354
		end -- 4354
	end -- 4354
	local arch = room.arch -- 4362
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 4362
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 4364
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 4364
			if a.x <= arch.x0 then -- 4364
				nx = arch.x0 - half -- 4367
			elseif a.x >= arch.x1 then -- 4367
				nx = arch.x1 + half -- 4369
			end -- 4369
		end -- 4369
	end -- 4369
	a.x = nx -- 4373
end -- 4316
function Play.prototype.fallY(self, a, dt) -- 4377
	a.vy = a.vy - ____exports.GRAVITY * dt -- 4378
	if a.vy < -900 then -- 4378
		a.vy = -900 -- 4380
	end -- 4380
	local ny = a.y + a.vy * dt -- 4382
	local half = a.w / 2 -- 4383
	if a.vy <= 0 then -- 4383
		local reach = a.onGround and STEP_UP or 0 -- 4386
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 4387
		if ny <= ground then -- 4387
			ny = ground -- 4389
			a.vy = 0 -- 4390
			a.onGround = true -- 4391
		else -- 4391
			a.onGround = false -- 4393
		end -- 4393
	else -- 4393
		a.onGround = false -- 4396
		local i = 0 -- 4397
		do -- 4397
			i = 0 -- 4398
			while i < #self.boxes do -- 4398
				do -- 4398
					local b = self.boxes[i + 1] -- 4399
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4399
						goto __continue765 -- 4401
					end -- 4401
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4401
						goto __continue765 -- 4404
					end -- 4404
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 4404
						goto __continue765 -- 4407
					end -- 4407
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 4407
						ny = b.y0 - a.h -- 4410
						a.vy = 0 -- 4411
					end -- 4411
				end -- 4411
				::__continue765:: -- 4411
				i = i + 1 -- 4398
			end -- 4398
		end -- 4398
	end -- 4398
	a.y = ny -- 4415
end -- 4377
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 4419
	if depth == nil then -- 4419
		depth = 0 -- 4419
	end -- 4419
	local g = -9999 -- 4420
	local i = 0 -- 4421
	do -- 4421
		i = 0 -- 4422
		while i < #self.floors do -- 4422
			local f = self.floors[i + 1] -- 4423
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 4423
				g = f.y1 -- 4425
			end -- 4425
			i = i + 1 -- 4422
		end -- 4422
	end -- 4422
	do -- 4422
		i = 0 -- 4428
		while i < #self.boxes do -- 4428
			do -- 4428
				local b = self.boxes[i + 1] -- 4429
				if b.broken == true or b.hidden == true or b.soft == true then -- 4429
					goto __continue775 -- 4431
				end -- 4431
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 4431
					g = b.y1 -- 4435
				end -- 4435
			end -- 4435
			::__continue775:: -- 4435
			i = i + 1 -- 4428
		end -- 4428
	end -- 4428
	return g -- 4438
end -- 4419
function Play.prototype.updateCamera(self, dt) -- 4441
	local p = self.player -- 4442
	local tx = p.x + p.facing * 30 -- 4443
	local ty = p.y + CAM_LOOK_UP -- 4444
	local k = math.min(1, CAM_FOLLOW * dt) -- 4445
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 4446
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 4447
end -- 4441
function Play.prototype.clampCamera(self, w, h) -- 4451
	local room = self.room -- 4452
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 4453
	local spanX = room.maxX - room.minX -- 4454
	if spanX <= halfW * 2 then -- 4454
		self.cam.x = (room.minX + room.maxX) / 2 -- 4456
	else -- 4456
		self.cam.x = math.max( -- 4458
			room.minX + halfW, -- 4458
			math.min(room.maxX - halfW, self.cam.x) -- 4458
		) -- 4458
	end -- 4458
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 4461
	local spanY = room.height -- 4462
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 4463
	if spanY <= halfH * 2 then -- 4463
		self.cam.y = camY -- 4465
	else -- 4465
		self.cam.y = math.max( -- 4467
			camY, -- 4467
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 4467
		) -- 4467
	end -- 4467
end -- 4451
function Play.prototype.flashSet(self, text, t) -- 4471
	self.flash = text -- 4472
	self.flashT = t -- 4473
end -- 4471
function Play.prototype.statusText(self) -- 4477
	local p = self.player -- 4478
	local parts = {} -- 4479
	local who = self.childMode and "小满" or "周戍" -- 4480
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 4481
	if self.room.key == "prologue" then -- 4481
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4484
		if self.phase == "prologue-wait" then -- 4484
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 4486
		elseif self.phase == "prologue-give" then -- 4486
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 4488
		else -- 4488
			parts[#parts + 1] = "跟随" -- 4490
		end -- 4490
		if self.paused then -- 4490
			parts[#parts + 1] = "已暂停" -- 4493
		end -- 4493
		return table.concat(parts, " · ") -- 4495
	end -- 4495
	if self.room.key == "street" then -- 4495
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4498
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4499
		if self.paused then -- 4499
			parts[#parts + 1] = "已暂停" -- 4501
		end -- 4501
		return table.concat(parts, " · ") -- 4503
	end -- 4503
	if self.room.key == "gate" then -- 4503
		local ____temp_63 -- 4506
		if self.room.story == nil then -- 4506
			____temp_63 = nil -- 4506
		else -- 4506
			____temp_63 = self.room.story.gate -- 4506
		end -- 4506
		local g = ____temp_63 -- 4506
		if g ~= nil then -- 4506
			parts[#parts + 1] = self:gateLabel() -- 4508
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 4509
				0, -- 4510
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 4510
			))) .. " 秒" -- 4510
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4511
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4512
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 4513
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 4514
			if self.gateFailCount > 0 then -- 4514
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 4516
			end -- 4516
			if self.flash ~= "" then -- 4516
				parts[#parts + 1] = self.flash -- 4519
			end -- 4519
		end -- 4519
		if self.paused then -- 4519
			parts[#parts + 1] = "已暂停" -- 4523
		end -- 4523
		return table.concat(parts, " · ") -- 4525
	end -- 4525
	if self.room.key == "forest" then -- 4525
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4528
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 4529
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 4530
		if self.caughtT > 0 then -- 4530
			parts[#parts + 1] = "复位中" -- 4532
		end -- 4532
		if self.paused then -- 4532
			parts[#parts + 1] = "已暂停" -- 4535
		end -- 4535
		return table.concat(parts, " · ") -- 4537
	end -- 4537
	if self.room.key == "tower" then -- 4537
		if self.phase == "tower-wait" then -- 4537
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 4541
		elseif self.phase == "tower-knock" then -- 4541
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 4543
		elseif self.phase == "tower-given" then -- 4543
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 4545
		else -- 4545
			parts[#parts + 1] = "片尾" -- 4547
		end -- 4547
		if self.paused then -- 4547
			parts[#parts + 1] = "已暂停" -- 4550
		end -- 4550
		return table.concat(parts, " · ") -- 4552
	end -- 4552
	if self.room.key == "village" then -- 4552
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4555
		if self.hasBottle then -- 4555
			parts[#parts + 1] = "有瓶" -- 4557
		elseif self.bottleFly ~= nil then -- 4557
			parts[#parts + 1] = "瓶在飞" -- 4559
		else -- 4559
			parts[#parts + 1] = "空手" -- 4561
		end -- 4561
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 4563
		if self.scavChase then -- 4563
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 4565
		end -- 4565
		if self.passed then -- 4565
			parts[#parts + 1] = "已过通行线" -- 4568
		end -- 4568
		if self.paused then -- 4568
			parts[#parts + 1] = "已暂停" -- 4571
		end -- 4571
		return table.concat(parts, " · ") -- 4573
	end -- 4573
	local isChild = self.childMode -- 4576
	if isChild then -- 4576
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4578
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 4579
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4580
	else -- 4580
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 4582
		if p.rollT > 0 then -- 4582
			parts[#parts + 1] = "翻滚中" -- 4584
		end -- 4584
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4586
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4587
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 4588
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 4589
	end -- 4589
	if self.checkpoint >= 0 then -- 4589
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 4592
	end -- 4592
	if self.paused then -- 4592
		parts[#parts + 1] = "已暂停" -- 4595
	end -- 4595
	return table.concat(parts, " · ") -- 4597
end -- 4477
function Play.prototype.aliveEnemies(self) -- 4601
	local n = 0 -- 4602
	local i = 0 -- 4603
	do -- 4603
		i = 0 -- 4604
		while i < #self.enemies do -- 4604
			if self.enemies[i + 1].alive then -- 4604
				n = n + 1 -- 4606
			end -- 4606
			i = i + 1 -- 4604
		end -- 4604
	end -- 4604
	return n -- 4609
end -- 4601
function Play.prototype.threatened(self) -- 4614
	do -- 4614
		local i = 0 -- 4615
		while i < #self.enemies do -- 4615
			local e = self.enemies[i + 1] -- 4616
			if e.alive and e.warnT > 0 then -- 4616
				return true -- 4618
			end -- 4618
			i = i + 1 -- 4615
		end -- 4615
	end -- 4615
	return false -- 4621
end -- 4614
function Play.prototype.gateSecondsLeft(self) -- 4624
	local ____temp_64 -- 4625
	if self.room.story == nil then -- 4625
		____temp_64 = nil -- 4625
	else -- 4625
		____temp_64 = self.room.story.gate -- 4625
	end -- 4625
	local g = ____temp_64 -- 4625
	if g == nil then -- 4625
		return 0 -- 4627
	end -- 4627
	return math.max( -- 4629
		0, -- 4629
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 4629
	) -- 4629
end -- 4624
function Play.prototype.gateLabel(self) -- 4632
	if self.phase == "gate-idle" then -- 4632
		return "待就位" -- 4634
	end -- 4634
	if self.phase == "gate-hold" then -- 4634
		return "守点中" -- 4637
	end -- 4637
	if self.phase == "gate-send" then -- 4637
		return "送别" -- 4640
	end -- 4640
	if self.phase == "gate-count" then -- 4640
		return "数数 " .. tostring(self.countTick) -- 4643
	end -- 4643
	return "她走" -- 4645
end -- 4632
function Play.prototype.dogLabel(self) -- 4649
	if self.dogState == "ear" then -- 4649
		return "转耳" -- 4651
	end -- 4651
	if self.dogState == "chase" then -- 4651
		return "追" -- 4654
	end -- 4654
	if self.dogState == "sniff" then -- 4654
		return "停" -- 4657
	end -- 4657
	if self.dogState == "back" then -- 4657
		return "回线" -- 4660
	end -- 4660
	return "巡逻" -- 4662
end -- 4649
function Play.prototype.doorXOf(self) -- 4665
	local ____temp_65 -- 4666
	if self.room.story == nil then -- 4666
		____temp_65 = nil -- 4666
	else -- 4666
		____temp_65 = self.room.story.tower -- 4666
	end -- 4666
	local t = ____temp_65 -- 4666
	return t == nil and 0 or t.doorX -- 4667
end -- 4665
function Play.prototype.scavLabel(self) -- 4671
	if self.scavState == "chase" then -- 4671
		return "追" -- 4673
	end -- 4673
	if self.scavState == "turn" then -- 4673
		return "转头" -- 4676
	end -- 4676
	if self.scavState == "walk" then -- 4676
		return "赶来" -- 4679
	end -- 4679
	if self.scavState == "stall" then -- 4679
		return "停住" -- 4682
	end -- 4682
	if self.scavState == "back" then -- 4682
		return "回位" -- 4685
	end -- 4685
	return "巡逻" -- 4687
end -- 4671
function Play.prototype.hintText(self) -- 4691
	if self.paused then -- 4691
		return "Esc 继续 · R 重置" -- 4693
	end -- 4693
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 4693
		if self:threatened() then -- 4693
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 4699
		end -- 4699
		if self.coverHug then -- 4699
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 4702
		end -- 4702
		if self.coverNear then -- 4702
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 4705
		end -- 4705
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 4707
	end -- 4707
	if self.flash ~= "" then -- 4707
		return self.flash -- 4710
	end -- 4710
	if self.room.key == "prologue" then -- 4710
		if self.phase == "prologue-wait" then -- 4710
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 4714
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 4715
		end -- 4715
		if self.phase == "prologue-give" then -- 4715
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 4718
		end -- 4718
		return "她跟着你了 · 两人一起走到门口 680" -- 4720
	end -- 4720
	if self.room.key == "street" then -- 4720
		if self:aliveEnemies() > 0 then -- 4720
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 4724
		end -- 4724
		return "清完了 · 两人一起走到右边检查站入口 900" -- 4726
	end -- 4726
	if self.room.key == "gate" then -- 4726
		local ____temp_66 -- 4729
		if self.room.story == nil then -- 4729
			____temp_66 = nil -- 4729
		else -- 4729
			____temp_66 = self.room.story.gate -- 4729
		end -- 4729
		local g = ____temp_66 -- 4729
		if g ~= nil then -- 4729
			if self.phase == "gate-idle" then -- 4729
				if self.gateNeedConfirm then -- 4729
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 4733
				end -- 4733
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 4735
			end -- 4735
			if self.phase == "gate-hold" then -- 4735
				if self.coveredFlash > 0 then -- 4735
					return "掩体挡下了这一枪 · 别露头" -- 4739
				end -- 4739
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 4741
			end -- 4741
			if self.phase == "gate-send" then -- 4741
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 4744
			end -- 4744
			if self.phase == "gate-count" then -- 4744
				if self.countTick >= ____exports.GATE_COUNT_END then -- 4744
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 4748
				end -- 4748
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 4750
			end -- 4750
			return "她自己走 · 跟着出城门 1120" -- 4752
		end -- 4752
	end -- 4752
	if self.room.key == "forest" then -- 4752
		if self.dogState == "chase" then -- 4752
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 4757
		end -- 4757
		if self.dogState == "ear" then -- 4757
			return "狗转耳朵了 · 停下或蹲下别出声" -- 4760
		end -- 4760
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 4762
	end -- 4762
	if self.room.key == "tower" then -- 4762
		if self.phase == "tower-wait" then -- 4762
			return "走到门前 445 点一次 E 敲两下" -- 4766
		end -- 4766
		if self.phase == "tower-knock" then -- 4766
			return "敲两下 · 等门开" -- 4769
		end -- 4769
		if self.phase == "tower-given" then -- 4769
			return "递交针套和纸条 · 看登记簿最后一行" -- 4772
		end -- 4772
		return "片尾 · 点 E 再玩一次，回到序章" -- 4774
	end -- 4774
	if self.room.key == "village" then -- 4774
		if self.bottleFly ~= nil then -- 4774
			return "等瓶子落地 · 触地才发声" -- 4778
		end -- 4778
		if self.hasBottle then -- 4778
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 4781
		end -- 4781
		if self.passed then -- 4781
			return "已过第一院 · R 重置可再来一遍" -- 4784
		end -- 4784
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 4786
	end -- 4786
	if self.room.key == "outside" then -- 4786
		if self.focusCart then -- 4786
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 4790
		end -- 4790
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 4792
	end -- 4792
	if self.escort.state == "frozen" then -- 4792
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 4792
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 4796
		end -- 4796
		return "小满吓住了 · 走过去，靠近再点 E" -- 4798
	end -- 4798
	if self.escort.state == "calming" then -- 4798
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 4801
	end -- 4801
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 4803
end -- 4691
function Play.prototype.draw(self, draw, w, h) -- 4808
	self.viewW = w -- 4809
	self.viewH = h -- 4810
	self.view = ____exports.computeViewport(w, h) -- 4811
	self:clampCamera(w, h) -- 4812
	draw:clear() -- 4813
	draw:drawRect( -- 4815
		Rect(0, 0, w, h), -- 4815
		BG_VOID -- 4815
	) -- 4815
	local box = self:canvasRect(w, h) -- 4816
	draw:drawRect(box, BG_FAR) -- 4817
	draw:drawRect( -- 4818
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 4818
		BG_MID -- 4818
	) -- 4818
	self:drawFloors(draw, w, h) -- 4820
	self:drawSolids(draw, w, h) -- 4821
	self:drawZones(draw, w, h) -- 4822
	self:drawArch(draw, w, h) -- 4823
	self:drawCart(draw, w, h) -- 4824
	self:drawCampaignProps(draw, w, h) -- 4825
	self:drawActors(draw, w, h) -- 4826
	self:drawTrace(draw, w, h) -- 4827
	self:drawAim(draw, w, h) -- 4828
end -- 4808
function Play.prototype.canvasRect(self, w, h) -- 4832
	local v = self.view -- 4833
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 4834
end -- 4832
function Play.prototype.px(self, n) -- 4838
	return n * self.view.zoom -- 4839
end -- 4838
function Play.prototype.sx(self, wx, w) -- 4843
	local v = self.view -- 4844
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 4845
	return v.ox + lx * v.zoom -- 4846
end -- 4843
function Play.prototype.sy(self, wy, h) -- 4850
	local v = self.view -- 4851
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 4852
	return v.oy + ly * v.zoom -- 4853
end -- 4850
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 4856
	local px0 = self:sx(x0, w) -- 4857
	local px1 = self:sx(x1, w) -- 4858
	local py0 = self:sy(y0, h) -- 4859
	local py1 = self:sy(y1, h) -- 4860
	if px1 <= px0 or py1 <= py0 then -- 4860
		return -- 4862
	end -- 4862
	draw:drawRect( -- 4864
		Rect(px0, py0, px1 - px0, py1 - py0), -- 4864
		color -- 4864
	) -- 4864
end -- 4856
function Play.prototype.drawFloors(self, draw, w, h) -- 4867
	local i = 0 -- 4868
	do -- 4868
		i = 0 -- 4869
		while i < #self.room.floors do -- 4869
			local f = self.room.floors[i + 1] -- 4870
			local ____temp_67 -- 4871
			if f.y == 0 then -- 4871
				____temp_67 = self.room.depth -- 4871
			else -- 4871
				____temp_67 = nil -- 4871
			end -- 4871
			local road = ____temp_67 -- 4871
			local y = self:sy(f.y + (road and road.min or 0), h) -- 4872
			local x0 = self:sx(f.x0, w) -- 4873
			local x1 = self:sx(f.x1, w) -- 4874
			local deck = self:px(5) -- 4875
			if road ~= nil then -- 4875
				local back = self:sy(f.y + road.max, h) -- 4877
				draw:drawRect( -- 4878
					Rect(x0, y, x1 - x0, back - y), -- 4878
					FLOOR_DECK, -- 4878
					self:px(1), -- 4878
					SOLID_EDGE -- 4878
				) -- 4878
			end -- 4878
			draw:drawRect( -- 4880
				Rect(x0, y - deck, x1 - x0, deck), -- 4880
				FLOOR_DECK -- 4880
			) -- 4880
			draw:drawSegment( -- 4881
				Vec2(x0, y), -- 4881
				Vec2(x1, y), -- 4881
				self:px(1), -- 4881
				GROUND -- 4881
			) -- 4881
			i = i + 1 -- 4869
		end -- 4869
	end -- 4869
end -- 4867
function Play.prototype.drawSolids(self, draw, w, h) -- 4885
	local i = 0 -- 4886
	do -- 4886
		i = 0 -- 4887
		while i < #self.boxes do -- 4887
			do -- 4887
				local b = self.boxes[i + 1] -- 4888
				if b.id == "braced_shield" or b.hidden == true then -- 4888
					goto __continue896 -- 4890
				end -- 4890
				if b.broken == true then -- 4890
					if b.breakable ~= nil then -- 4890
						local gy = self:sy(b.y0, h) -- 4895
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 4896
						local k = 0 -- 4897
						do -- 4897
							k = 0 -- 4898
							while k < 3 do -- 4898
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 4899
								draw:drawSegment( -- 4900
									Vec2( -- 4900
										gx - self:px(4), -- 4900
										gy + self:px(k % 2) -- 4900
									), -- 4900
									Vec2( -- 4900
										gx + self:px(5), -- 4900
										gy + self:px(k % 2) -- 4900
									), -- 4900
									self:px(1), -- 4900
									rgb -- 4900
								) -- 4900
								k = k + 1 -- 4898
							end -- 4898
						end -- 4898
					end -- 4898
					goto __continue896 -- 4903
				end -- 4903
				local ____opt_70 = b.depth -- 4903
				local front = ____opt_70 and ____opt_70.min or 0 -- 4905
				local ____opt_72 = b.depth -- 4905
				local back = ____opt_72 and ____opt_72.max or 0 -- 4906
				local fill = SOLID_FILL -- 4907
				local line = SOLID_EDGE -- 4908
				if b.soft == true then -- 4908
					fill = SOFT -- 4910
					line = SOFT_LINE -- 4911
				elseif b.breakable ~= nil then -- 4911
					line = DANGER_LINE -- 4913
					fill = Color(0.3, 0.24, 0.16, 1) -- 4914
				elseif b.interact ~= nil then -- 4914
					line = PASS_LINE -- 4916
				end -- 4916
				self:drawBox( -- 4918
					draw, -- 4918
					w, -- 4918
					h, -- 4918
					b.x0, -- 4918
					b.x1, -- 4918
					b.y0 + front, -- 4918
					b.y1 + back, -- 4918
					fill -- 4918
				) -- 4918
				draw:drawSegment( -- 4919
					Vec2( -- 4919
						self:sx(b.x0, w), -- 4919
						self:sy(b.y1 + front, h) -- 4919
					), -- 4919
					Vec2( -- 4920
						self:sx(b.x1, w), -- 4920
						self:sy(b.y1 + front, h) -- 4920
					), -- 4920
					self:px(1), -- 4920
					line -- 4920
				) -- 4920
				if b.breakable ~= nil then -- 4920
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 4923
					local cyp = self:sy(b.y1 + front, h) -- 4924
					draw:drawSegment( -- 4925
						Vec2( -- 4925
							cxp - self:px(4), -- 4925
							cyp + self:px(1) -- 4925
						), -- 4925
						Vec2( -- 4925
							cxp + self:px(3), -- 4925
							cyp + self:px(5) -- 4925
						), -- 4925
						self:px(1), -- 4925
						line -- 4925
					) -- 4925
				end -- 4925
			end -- 4925
			::__continue896:: -- 4925
			i = i + 1 -- 4887
		end -- 4887
	end -- 4887
end -- 4885
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 4931
	local i = 0 -- 4932
	do -- 4932
		i = 0 -- 4933
		while i < #self.pickups do -- 4933
			do -- 4933
				local pk = self.pickups[i + 1] -- 4934
				if pk.id == "" then -- 4934
					goto __continue908 -- 4936
				end -- 4936
				local gy = pk.y + (pk.depth or 0) -- 4938
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 4939
				draw:drawRect( -- 4940
					Rect( -- 4940
						self:sx(pk.x - 5, w), -- 4940
						self:sy(gy + 12 + bob, h), -- 4940
						self:px(10), -- 4940
						self:px(10) -- 4940
					), -- 4940
					Color(0.84, 0.7, 0.3, 1) -- 4941
				) -- 4941
				draw:drawSegment( -- 4942
					Vec2( -- 4942
						self:sx(pk.x - 5, w), -- 4942
						self:sy(gy + 12 + bob, h) -- 4942
					), -- 4942
					Vec2( -- 4943
						self:sx(pk.x + 5, w), -- 4943
						self:sy(gy + 12 + bob, h) -- 4943
					), -- 4943
					self:px(1), -- 4943
					Color(0.95, 0.86, 0.52, 1) -- 4943
				) -- 4943
			end -- 4943
			::__continue908:: -- 4943
			i = i + 1 -- 4933
		end -- 4933
	end -- 4933
	if self.bracedShield ~= nil then -- 4933
		local sh = self.bracedShield -- 4946
		draw:drawRect( -- 4947
			Rect( -- 4947
				self:sx(sh.x - sh.w / 2, w), -- 4947
				self:sy(sh.y, h), -- 4947
				self:px(sh.w), -- 4947
				self:px(sh.h) -- 4947
			), -- 4947
			Color(0.42, 0.4, 0.34, 1) -- 4948
		) -- 4948
		draw:drawSegment( -- 4949
			Vec2( -- 4949
				self:sx(sh.x - sh.w / 2, w), -- 4949
				self:sy(sh.y + sh.h, h) -- 4949
			), -- 4949
			Vec2( -- 4950
				self:sx(sh.x + sh.w / 2, w), -- 4950
				self:sy(sh.y + sh.h, h) -- 4950
			), -- 4950
			self:px(1), -- 4950
			Color(0.74, 0.72, 0.62, 1) -- 4950
		) -- 4950
	end -- 4950
end -- 4931
function Play.prototype.drawZones(self, draw, w, h) -- 4954
	local i = 0 -- 4955
	do -- 4955
		i = 0 -- 4956
		while i < #self.room.zones do -- 4956
			local z = self.room.zones[i + 1] -- 4957
			local fill = DANGER -- 4958
			local line = DANGER_LINE -- 4959
			if z.tint == 2 then -- 4959
				fill = SOFT -- 4961
				line = SOFT_LINE -- 4962
			elseif z.tint == 3 then -- 4962
				fill = BRICK -- 4964
				line = BRICK_LINE -- 4965
			elseif z.tint == 4 then -- 4965
				fill = PASS -- 4967
				line = PASS_LINE -- 4968
			end -- 4968
			self:drawBox( -- 4970
				draw, -- 4970
				w, -- 4970
				h, -- 4970
				z.x0, -- 4970
				z.x1, -- 4970
				z.y, -- 4970
				z.y + z.h, -- 4970
				fill -- 4970
			) -- 4970
			draw:drawSegment( -- 4971
				Vec2( -- 4971
					self:sx(z.x0, w), -- 4971
					self:sy(z.y, h) -- 4971
				), -- 4971
				Vec2( -- 4971
					self:sx(z.x0, w), -- 4971
					self:sy(z.y + z.h, h) -- 4971
				), -- 4971
				self:px(1), -- 4971
				line -- 4971
			) -- 4971
			draw:drawSegment( -- 4972
				Vec2( -- 4972
					self:sx(z.x1, w), -- 4972
					self:sy(z.y, h) -- 4972
				), -- 4972
				Vec2( -- 4972
					self:sx(z.x1, w), -- 4972
					self:sy(z.y + z.h, h) -- 4972
				), -- 4972
				self:px(1), -- 4972
				line -- 4972
			) -- 4972
			i = i + 1 -- 4956
		end -- 4956
	end -- 4956
end -- 4954
function Play.prototype.drawArch(self, draw, w, h) -- 4976
	local a = self.room.arch -- 4977
	if a.h <= 0 then -- 4977
		return -- 4979
	end -- 4979
	self:drawBox( -- 4981
		draw, -- 4981
		w, -- 4981
		h, -- 4981
		a.x0, -- 4981
		a.x1, -- 4981
		a.y, -- 4981
		a.y + a.h, -- 4981
		HOLE_FILL -- 4981
	) -- 4981
	draw:drawSegment( -- 4982
		Vec2( -- 4982
			self:sx(a.x0, w), -- 4982
			self:sy(a.y + a.h, h) -- 4982
		), -- 4982
		Vec2( -- 4982
			self:sx(a.x1, w), -- 4982
			self:sy(a.y + a.h, h) -- 4982
		), -- 4982
		self:px(1), -- 4982
		SOLID_EDGE -- 4982
	) -- 4982
	draw:drawSegment( -- 4983
		Vec2( -- 4983
			self:sx(a.x0, w), -- 4983
			self:sy(a.y, h) -- 4983
		), -- 4983
		Vec2( -- 4983
			self:sx(a.x0, w), -- 4983
			self:sy(a.y + a.h, h) -- 4983
		), -- 4983
		self:px(1), -- 4983
		SOLID_EDGE -- 4983
	) -- 4983
	draw:drawSegment( -- 4984
		Vec2( -- 4984
			self:sx(a.x1, w), -- 4984
			self:sy(a.y, h) -- 4984
		), -- 4984
		Vec2( -- 4984
			self:sx(a.x1, w), -- 4984
			self:sy(a.y + a.h, h) -- 4984
		), -- 4984
		self:px(1), -- 4984
		SOLID_EDGE -- 4984
	) -- 4984
end -- 4976
function Play.prototype.drawCart(self, draw, w, h) -- 4987
	local c = self.room.cart -- 4988
	if c.bodyW <= 0 then -- 4988
		return -- 4990
	end -- 4990
	drawCartShape( -- 4992
		draw, -- 4992
		self, -- 4992
		w, -- 4992
		h, -- 4992
		c, -- 4992
		self.cartAxle -- 4992
	) -- 4992
	draw:drawRect( -- 4993
		Rect( -- 4993
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 4993
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 4993
			self:px(2), -- 4993
			self:px(40) -- 4993
		), -- 4993
		STAND -- 4993
	) -- 4993
end -- 4987
function Play.prototype.drawActors(self, draw, w, h) -- 4996
	local p = self.player -- 4997
	local isChild = self.childMode -- 4998
	local footY = p.y + p.depth -- 4999
	if p.covered then -- 4999
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 5002
		draw:drawSegment( -- 5003
			Vec2( -- 5003
				self:sx(edge, w), -- 5003
				self:sy(footY + 8, h) -- 5003
			), -- 5003
			Vec2( -- 5003
				self:sx(edge, w), -- 5003
				self:sy(footY + p.h * 0.62, h) -- 5003
			), -- 5003
			self:px(2), -- 5003
			STAND -- 5003
		) -- 5003
		draw:drawSegment( -- 5005
			Vec2( -- 5005
				self:sx(p.x - 8, w), -- 5005
				self:sy(footY + p.h + 3, h) -- 5005
			), -- 5005
			Vec2( -- 5005
				self:sx(p.x + 8, w), -- 5005
				self:sy(footY + p.h + 3, h) -- 5005
			), -- 5005
			self:px(2), -- 5005
			STAND -- 5005
		) -- 5005
	elseif self.coverNear and not isChild then -- 5005
		draw:drawRect( -- 5008
			Rect( -- 5008
				self:sx(p.x - 3, w), -- 5008
				self:sy(footY + 1, h), -- 5008
				self:px(3), -- 5008
				self:px(3) -- 5008
			), -- 5008
			STAND -- 5008
		) -- 5008
	end -- 5008
	drawFigure( -- 5010
		draw, -- 5010
		self, -- 5010
		w, -- 5010
		h, -- 5010
		p, -- 5010
		isChild and CHILD_BODY or SOLDIER_BODY, -- 5010
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 5010
	) -- 5010
	local q = self.partner -- 5011
	if q.alive then -- 5011
		local childPartner = q.w == CHILD_W -- 5013
		drawFigure( -- 5014
			draw, -- 5014
			self, -- 5014
			w, -- 5014
			h, -- 5014
			q, -- 5014
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 5014
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 5014
		) -- 5014
	end -- 5014
	local i = 0 -- 5016
	do -- 5016
		i = 0 -- 5017
		while i < #self.enemies do -- 5017
			local e = self.enemies[i + 1] -- 5018
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 5019
			local enemyY = e.y + (e.depth or 0) -- 5020
			self:drawBox( -- 5021
				draw, -- 5021
				w, -- 5021
				h, -- 5021
				e.x - e.w / 2, -- 5021
				e.x + e.w / 2, -- 5021
				enemyY, -- 5021
				enemyY + e.h, -- 5021
				col -- 5021
			) -- 5021
			if e.alive then -- 5021
				local ef = p.x >= e.x and 1 or -1 -- 5023
				if e.kind == "shield" then -- 5023
					local sh = (e.shieldHp or 0) > 0 -- 5025
					draw:drawRect( -- 5026
						Rect( -- 5026
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 5026
							self:sy(enemyY, h), -- 5026
							self:px(6), -- 5026
							self:px(64) -- 5026
						), -- 5026
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 5027
					) -- 5027
				elseif e.kind == "breaker" then -- 5027
					draw:drawSegment( -- 5029
						Vec2( -- 5029
							self:sx(e.x + ef * 12, w), -- 5029
							self:sy(enemyY + 8, h) -- 5029
						), -- 5029
						Vec2( -- 5030
							self:sx(e.x + ef * 22, w), -- 5030
							self:sy(enemyY + 46, h) -- 5030
						), -- 5030
						self:px(3), -- 5030
						Color(0.5, 0.36, 0.22, 1) -- 5030
					) -- 5030
				end -- 5030
			end -- 5030
			if e.alive and e.warnT > 0 then -- 5030
				local gunX = self:sx(e.x, w) -- 5035
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 5036
				local aimX = self:sx(p.x, w) -- 5037
				local aimY = self:sy(footY + p.h * 0.55, h) -- 5038
				local seg = 8 -- 5039
				local s = 0 -- 5040
				do -- 5040
					s = 0 -- 5041
					while s < seg do -- 5041
						local t0 = s / seg -- 5042
						local t1 = (s + 1) / seg -- 5043
						draw:drawSegment( -- 5044
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 5045
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 5046
							self:px(1), -- 5047
							DANGER -- 5047
						) -- 5047
						s = s + 2 -- 5041
					end -- 5041
				end -- 5041
			end -- 5041
			i = i + 1 -- 5017
		end -- 5017
	end -- 5017
	local k = 0 -- 5052
	do -- 5052
		k = 0 -- 5053
		while k < #self.room.marks do -- 5053
			do -- 5053
				local m = self.room.marks[k + 1] -- 5054
				if m.kind ~= 0 then -- 5054
					goto __continue934 -- 5056
				end -- 5056
				local on = self.checkpoint == m.x -- 5058
				local x = self:sx(m.x, w) -- 5059
				local y = self:sy(m.y, h) -- 5060
				draw:drawSegment( -- 5061
					Vec2(x, y), -- 5061
					Vec2( -- 5061
						x, -- 5061
						y + self:px(35) -- 5061
					), -- 5061
					self:px(1), -- 5061
					on and CHECK or INK_DIM -- 5061
				) -- 5061
				draw:drawDot( -- 5062
					Vec2( -- 5062
						x, -- 5062
						y + self:px(35) -- 5062
					), -- 5062
					self:px(2), -- 5062
					on and CHECK or INK_DIM -- 5062
				) -- 5062
			end -- 5062
			::__continue934:: -- 5062
			k = k + 1 -- 5053
		end -- 5053
	end -- 5053
	local j = 0 -- 5066
	do -- 5066
		j = 0 -- 5067
		while j < #self.room.marks do -- 5067
			do -- 5067
				local m = self.room.marks[j + 1] -- 5068
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 5068
					goto __continue937 -- 5070
				end -- 5070
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 5070
					goto __continue937 -- 5074
				end -- 5074
				local col = STAND -- 5076
				if m.kind == 4 then -- 5076
					col = PASS_LINE -- 5078
				elseif m.kind == 5 then -- 5078
					col = BRICK_LINE -- 5080
				end -- 5080
				local mx = self:sx(m.x, w) -- 5082
				local my = self:sy(m.y, h) -- 5083
				draw:drawSegment( -- 5084
					Vec2(mx, my), -- 5084
					Vec2( -- 5084
						mx, -- 5084
						my + self:px(24) -- 5084
					), -- 5084
					self:px(1), -- 5084
					col -- 5084
				) -- 5084
			end -- 5084
			::__continue937:: -- 5084
			j = j + 1 -- 5067
		end -- 5067
	end -- 5067
	local t = 0 -- 5087
	do -- 5087
		t = 0 -- 5088
		while t < #self.room.marks do -- 5088
			do -- 5088
				local m = self.room.marks[t + 1] -- 5089
				if m.kind ~= 6 then -- 5089
					goto __continue943 -- 5091
				end -- 5091
				local mx = self:sx(m.x, w) -- 5093
				local my = self:sy(m.y, h) -- 5094
				draw:drawSegment( -- 5095
					Vec2(mx, my), -- 5095
					Vec2( -- 5095
						mx, -- 5095
						my + self:px(30) -- 5095
					), -- 5095
					self:px(1), -- 5095
					INK_DIM -- 5095
				) -- 5095
				self:drawBox( -- 5096
					draw, -- 5096
					w, -- 5096
					h, -- 5096
					m.x - 5, -- 5096
					m.x + 5, -- 5096
					m.y + 30, -- 5096
					m.y + 40, -- 5096
					CHECK -- 5096
				) -- 5096
			end -- 5096
			::__continue943:: -- 5096
			t = t + 1 -- 5088
		end -- 5088
	end -- 5088
	if self.room.key == "village" then -- 5088
		self:drawVillage(draw, w, h) -- 5099
	end -- 5099
	if self.room.key == "forest" then -- 5099
		self:drawDog(draw, w, h) -- 5102
	end -- 5102
end -- 4996
function Play.prototype.drawDog(self, draw, w, h) -- 5107
	local x = self.dogX -- 5108
	self:drawBox( -- 5109
		draw, -- 5109
		w, -- 5109
		h, -- 5109
		x - 14, -- 5109
		x + 14, -- 5109
		0, -- 5109
		20, -- 5109
		SCAV_BODY -- 5109
	) -- 5109
	self:drawBox( -- 5110
		draw, -- 5110
		w, -- 5110
		h, -- 5110
		x - 10, -- 5110
		x - 2, -- 5110
		20, -- 5110
		30, -- 5110
		SCAV_BODY -- 5110
	) -- 5110
	self:drawBox( -- 5111
		draw, -- 5111
		w, -- 5111
		h, -- 5111
		x + 2, -- 5111
		x + 10, -- 5111
		20, -- 5111
		30, -- 5111
		SCAV_HEAD -- 5111
	) -- 5111
	if self.dogState == "ear" or self.dogState == "chase" then -- 5111
		draw:drawSegment( -- 5113
			Vec2( -- 5113
				self:sx(x, w), -- 5113
				self:sy(30, h) -- 5113
			), -- 5113
			Vec2( -- 5114
				self:sx(x, w), -- 5114
				self:sy(40, h) -- 5114
			), -- 5114
			self:px(1), -- 5114
			DANGER -- 5114
		) -- 5114
	end -- 5114
end -- 5107
function Play.prototype.drawVillage(self, draw, w, h) -- 5119
	local bottle = self.room.bottle -- 5120
	if bottle ~= nil then -- 5120
		self:drawBox( -- 5122
			draw, -- 5122
			w, -- 5122
			h, -- 5122
			bottle.x - 14, -- 5122
			bottle.x + 14, -- 5122
			0, -- 5122
			64, -- 5122
			SOLID_FILL -- 5122
		) -- 5122
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 5122
			self:drawBottle( -- 5124
				draw, -- 5124
				w, -- 5124
				h, -- 5124
				bottle.x, -- 5124
				64 -- 5124
			) -- 5124
		end -- 5124
	end -- 5124
	self:drawBox( -- 5128
		draw, -- 5128
		w, -- 5128
		h, -- 5128
		300, -- 5128
		420, -- 5128
		44, -- 5128
		50, -- 5128
		FLOOR_DECK -- 5128
	) -- 5128
	self:drawBox( -- 5129
		draw, -- 5129
		w, -- 5129
		h, -- 5129
		300, -- 5129
		306, -- 5129
		0, -- 5129
		44, -- 5129
		FLOOR_DECK -- 5129
	) -- 5129
	self:drawBox( -- 5130
		draw, -- 5130
		w, -- 5130
		h, -- 5130
		414, -- 5130
		420, -- 5130
		0, -- 5130
		44, -- 5130
		FLOOR_DECK -- 5130
	) -- 5130
	local s = self.room.scavenger -- 5132
	if s ~= nil then -- 5132
		local sx0 = self.scavX -- 5134
		self:drawBox( -- 5135
			draw, -- 5135
			w, -- 5135
			h, -- 5135
			sx0 - 12, -- 5135
			sx0 + 12, -- 5135
			0, -- 5135
			s.h - 14, -- 5135
			SCAV_BODY -- 5135
		) -- 5135
		self:drawBox( -- 5136
			draw, -- 5136
			w, -- 5136
			h, -- 5136
			sx0 - 7, -- 5136
			sx0 + 7, -- 5136
			s.h - 14, -- 5136
			s.h, -- 5136
			SCAV_HEAD -- 5136
		) -- 5136
		if self.scavState == "turn" then -- 5136
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 5138
			draw:drawSegment( -- 5139
				Vec2( -- 5139
					self:sx(sx0, w), -- 5139
					self:sy(s.h - 6, h) -- 5139
				), -- 5139
				Vec2( -- 5139
					self:sx(fx, w), -- 5139
					self:sy(s.h - 6, h) -- 5139
				), -- 5139
				self:px(1), -- 5139
				INK -- 5139
			) -- 5139
		end -- 5139
	end -- 5139
	if self.hasBottle then -- 5139
		local p = self.player -- 5144
		self:drawBottle( -- 5145
			draw, -- 5145
			w, -- 5145
			h, -- 5145
			p.x + p.facing * 10, -- 5145
			p.y + p.h * 0.62 -- 5145
		) -- 5145
	end -- 5145
	if self.bottleFly ~= nil then -- 5145
		self:drawBottle( -- 5148
			draw, -- 5148
			w, -- 5148
			h, -- 5148
			self.bottleFly.x, -- 5148
			self.bottleFly.y -- 5148
		) -- 5148
	end -- 5148
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 5148
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 5151
		draw:drawCircle( -- 5152
			Vec2( -- 5152
				self:sx(self.bottleLandX, w), -- 5152
				self:sy(0, h) -- 5152
			), -- 5152
			self:px(r / ____exports.UNITS_PER_PX), -- 5152
			BRICK_LINE -- 5152
		) -- 5152
	end -- 5152
end -- 5119
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 5156
	self:drawBox( -- 5157
		draw, -- 5157
		w, -- 5157
		h, -- 5157
		x - 3, -- 5157
		x + 3, -- 5157
		y - 10, -- 5157
		y, -- 5157
		BOTTLE -- 5157
	) -- 5157
end -- 5156
function Play.prototype.drawTrace(self, draw, w, h) -- 5160
	local t = self.trace -- 5161
	if t == nil or self.traceT <= 0 then -- 5161
		return -- 5163
	end -- 5163
	draw:drawSegment( -- 5165
		Vec2( -- 5166
			self:sx(t.x0, w), -- 5166
			self:sy(t.y0, h) -- 5166
		), -- 5166
		Vec2( -- 5167
			self:sx(t.x1, w), -- 5167
			self:sy(t.y1, h) -- 5167
		), -- 5167
		self:px(1), -- 5168
		t.hit and AIM_HIT or INK_DIM -- 5168
	) -- 5168
end -- 5160
function Play.prototype.drawAim(self, draw, w, h) -- 5171
	local v = self.view -- 5173
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 5174
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 5175
	local dot = self:px(1) -- 5176
	local arm = self:px(3) -- 5177
	local gap = self:px(1) -- 5178
	draw:drawSegment( -- 5179
		Vec2(gx - arm - gap, gy), -- 5179
		Vec2(gx - gap, gy), -- 5179
		dot / 2, -- 5179
		AIM -- 5179
	) -- 5179
	draw:drawSegment( -- 5180
		Vec2(gx + gap, gy), -- 5180
		Vec2(gx + arm + gap, gy), -- 5180
		dot / 2, -- 5180
		AIM -- 5180
	) -- 5180
	draw:drawSegment( -- 5181
		Vec2(gx, gy - arm - gap), -- 5181
		Vec2(gx, gy - gap), -- 5181
		dot / 2, -- 5181
		AIM -- 5181
	) -- 5181
	draw:drawSegment( -- 5182
		Vec2(gx, gy + gap), -- 5182
		Vec2(gx, gy + arm + gap), -- 5182
		dot / 2, -- 5182
		AIM -- 5182
	) -- 5182
	if self.room.key == "village" and self.hasBottle then -- 5182
		local p = self.player -- 5186
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 5188
		local dir = ____end.x >= p.x and 1 or -1 -- 5189
		local x0 = p.x + dir * 10 -- 5190
		local y0 = p.y + p.h * 0.7 -- 5191
		local T = BOTTLE_FLY_TIME -- 5192
		local vx = (____end.x - x0) / T -- 5193
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 5194
		local pxr = x0 -- 5195
		local pyr = y0 -- 5196
		local t = 1 -- 5197
		do -- 5197
			t = 1 -- 5198
			while t <= 12 do -- 5198
				local tt = t / 12 * T -- 5199
				local nx = x0 + vx * tt -- 5200
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 5201
				draw:drawSegment( -- 5202
					Vec2( -- 5202
						self:sx(pxr, w), -- 5202
						self:sy(pyr, h) -- 5202
					), -- 5202
					Vec2( -- 5202
						self:sx(nx, w), -- 5202
						self:sy(ny, h) -- 5202
					), -- 5202
					self:px(1) / 2, -- 5202
					BOTTLE -- 5202
				) -- 5202
				pxr = nx -- 5203
				pyr = ny -- 5204
				t = t + 1 -- 5198
			end -- 5198
		end -- 5198
		draw:drawCircle( -- 5206
			Vec2( -- 5206
				self:sx(____end.x, w), -- 5206
				self:sy(____end.y + 2, h) -- 5206
			), -- 5206
			self:px(2), -- 5206
			BOTTLE -- 5206
		) -- 5206
	end -- 5206
end -- 5171
return ____exports -- 5171