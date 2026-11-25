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
function makeActor(room, index) -- 5200
	local sp = room.spawns -- 5201
	if index < 0 or index >= #sp then -- 5201
		return { -- 5203
			x = 0, -- 5203
			y = 0, -- 5203
			depth = 0, -- 5203
			depthSpeed = 0, -- 5203
			vx = 0, -- 5203
			vy = 0, -- 5203
			w = CHILD_W, -- 5203
			h = CHILD_H, -- 5203
			onGround = true, -- 5203
			facing = 1, -- 5203
			crouch = false, -- 5203
			rollT = 0, -- 5203
			covered = false, -- 5203
			alive = false -- 5203
		} -- 5203
	end -- 5203
	local s = sp[index + 1] -- 5205
	local child = s.h <= CHILD_H -- 5206
	local ground = room.depth -- 5207
	local depth = ground == nil and 0 or math.max( -- 5208
		ground.min, -- 5208
		math.min(ground.max, s.depth or 0) -- 5208
	) -- 5208
	return { -- 5209
		x = s.x, -- 5210
		y = s.y, -- 5210
		depth = depth, -- 5210
		depthSpeed = 0, -- 5210
		vx = 0, -- 5210
		vy = 0, -- 5210
		w = child and CHILD_W or SOLDIER_W, -- 5211
		h = child and CHILD_H or SOLDIER_H, -- 5212
		onGround = true, -- 5213
		facing = 1, -- 5213
		crouch = false, -- 5213
		rollT = 0, -- 5213
		covered = false, -- 5213
		alive = true -- 5213
	} -- 5213
end -- 5213
function drawFigure(draw, play, w, h, a, body, head) -- 5217
	if not a.alive then -- 5217
		return -- 5219
	end -- 5219
	local x0 = a.x - a.w / 2 -- 5221
	local x1 = a.x + a.w / 2 -- 5222
	local y0 = a.y + a.depth -- 5223
	local y1 = y0 + a.h -- 5224
	play:drawBox( -- 5225
		draw, -- 5225
		w, -- 5225
		h, -- 5225
		x0, -- 5225
		x1, -- 5225
		y0, -- 5225
		y1 - a.h * 0.26, -- 5225
		body -- 5225
	) -- 5225
	play:drawBox( -- 5226
		draw, -- 5226
		w, -- 5226
		h, -- 5226
		x0 + 2, -- 5226
		x1 - 2, -- 5226
		y1 - a.h * 0.26, -- 5226
		y1, -- 5226
		head -- 5226
	) -- 5226
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 5228
	play:drawBox( -- 5229
		draw, -- 5229
		w, -- 5229
		h, -- 5229
		eyeX, -- 5229
		eyeX + 4, -- 5229
		y1 - a.h * 0.14, -- 5229
		y1 - a.h * 0.08, -- 5229
		INK -- 5229
	) -- 5229
end -- 5229
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5233
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5234
end -- 5233
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5241
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5242
end -- 5241
function rayInterval(origin, direction, min, max) -- 5249
	if direction == 0 then -- 5249
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5251
	end -- 5251
	local a = (min - origin) / direction -- 5253
	local b = (max - origin) / direction -- 5254
	return { -- 5255
		min = math.min(a, b), -- 5255
		max = math.max(a, b) -- 5255
	} -- 5255
end -- 5255
function hitBox(ray, box) -- 5259
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5260
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5261
	local enter = math.max(0, x.min, y.min) -- 5262
	local leave = math.min(99999, x.max, y.max) -- 5263
	if box.depth ~= nil then -- 5263
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5265
		enter = math.max(enter, depth.min) -- 5266
		leave = math.min(leave, depth.max) -- 5267
	end -- 5267
	return leave >= enter and enter or -1 -- 5269
end -- 5269
function drawCartShape(draw, play, w, h, c, axleX) -- 5272
	local half = c.bodyW / 2 -- 5273
	local x0 = axleX - half -- 5274
	local x1 = axleX + half -- 5275
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 5276
	play:drawBox( -- 5277
		draw, -- 5277
		w, -- 5277
		h, -- 5277
		x0, -- 5277
		x1, -- 5277
		axleY, -- 5277
		axleY + c.bodyH, -- 5277
		CART_FILL -- 5277
	) -- 5277
	draw:drawCircle( -- 5278
		Vec2( -- 5278
			play:sx(x0 + c.bodyW * 0.28, w), -- 5278
			play:sy(axleY, h) -- 5278
		), -- 5278
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5278
		Color(52, 50, 48, 255) -- 5278
	) -- 5278
	draw:drawCircle( -- 5279
		Vec2( -- 5279
			play:sx(x1 - c.bodyW * 0.28, w), -- 5279
			play:sy(axleY, h) -- 5279
		), -- 5279
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5279
		Color(52, 50, 48, 255) -- 5279
	) -- 5279
	local cx = c.clothSide < 0 and x0 or x1 -- 5280
	play:drawBox( -- 5281
		draw, -- 5281
		w, -- 5281
		h, -- 5281
		cx - 10, -- 5281
		cx + 10, -- 5281
		axleY + c.bodyH, -- 5281
		axleY + c.bodyH + 18, -- 5281
		CLOTH -- 5281
	) -- 5281
end -- 5281
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
function Play.prototype.canPersistProgress(self) -- 1833
	return not self.isCampaign and self.run.source == "official" -- 1834
end -- 1833
function Play.prototype.wellWindow(self) -- 1838
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 1839
end -- 1838
function Play.prototype.nearWell(self) -- 1844
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 1845
end -- 1844
function Play.prototype.pickWell(self) -- 1853
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 1853
		return false -- 1855
	end -- 1855
	self.phase = "prologue-well" -- 1857
	self.phaseTick = 0 -- 1858
	self.wellOpen = false -- 1859
	self:flashSet("井沿 · 伸手下去", 1.4) -- 1860
	self:log("旧井拾取") -- 1861
	return true -- 1862
end -- 1853
function Play.prototype.stepPrologue(self, dt, input) -- 1865
	local child = self.partner -- 1866
	if self.museumReturn then -- 1866
		self.museumReturn = false -- 1869
		self.phase = "prologue-wait" -- 1870
		self.phaseTick = 0 -- 1871
		self.player.x = self.ox + 260 -- 1872
		self.player.y = 0 -- 1873
		self.player.depth = 0 -- 1874
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 1875
	end -- 1875
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 1878
	if self.phase == "prologue-wait" then -- 1878
		child.crouch = true -- 1880
		child.h = CHILD_CROUCH_H -- 1881
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 1881
			self:pickWell() -- 1883
			return -- 1884
		end -- 1884
		if not self.wellOpen and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 1884
			if self:canPersistProgress() then -- 1884
				self.archive.museumPhase = "well_reflect" -- 1890
				self.archiveDirty = true -- 1891
			end -- 1891
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 1893
			return -- 1894
		end -- 1894
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1896
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1898
		if near and input.interact.pressed then -- 1898
			self.phase = "prologue-give" -- 1900
			self.phaseTick = 0 -- 1901
			self:flashSet("递出针套", 1) -- 1902
		end -- 1902
		return -- 1904
	end -- 1904
	if self.phase == "prologue-well" then -- 1904
		self.phaseTick = self.phaseTick + 1 -- 1908
		if self.phaseTick == 12 then -- 1908
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 1910
		elseif self.phaseTick >= 30 then -- 1910
			self.phase = "prologue-wait" -- 1912
			self.phaseTick = 0 -- 1913
			self.wellTaken = true -- 1914
			self.wellOpen = false -- 1915
			self.run.archive.artifactOwned = true -- 1916
			self.archiveDirty = true -- 1917
			self:emit("artifactFound", { -- 1918
				x = self.ox + self.wellX, -- 1919
				y = 0, -- 1919
				room = "prologue", -- 1919
				once = true, -- 1919
				source = self.run.source -- 1920
			}) -- 1920
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 1922
			self:log("井底取到时间穿梭器") -- 1923
		end -- 1923
		return -- 1925
	end -- 1925
	if self.phase == "prologue-give" then -- 1925
		self.phaseTick = self.phaseTick + 1 -- 1928
		if self.phaseTick == 12 then -- 1928
			self:flashSet("针套递过去", 0.7) -- 1930
		elseif self.phaseTick == 36 then -- 1930
			self:flashSet("纸条塞进针套", 0.9) -- 1932
		elseif self.phaseTick >= 60 then -- 1932
			self.phase = "prologue-follow" -- 1934
			self.phaseTick = 0 -- 1935
			child.crouch = false -- 1936
			child.h = CHILD_H -- 1937
			self:flashSet("她跟上了", 1.2) -- 1938
		end -- 1938
		return -- 1940
	end -- 1940
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1940
		self:requestRoom("street", "序章跟到门口") -- 1944
		self:flashSet("进街道", 1.2) -- 1945
	end -- 1945
end -- 1865
function Play.prototype.stepStreet(self, dt, input) -- 1950
	local p = self.player -- 1951
	local c = self.partner -- 1952
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1952
		self:requestRoom("checkpoint", "两人都到街尾") -- 1954
		self:flashSet("到检查站", 1.2) -- 1955
	end -- 1955
end -- 1950
function Play.prototype.stepGate(self, dt, input) -- 1960
	local ____temp_35 -- 1961
	if self.room.story == nil then -- 1961
		____temp_35 = nil -- 1961
	else -- 1961
		____temp_35 = self.room.story.gate -- 1961
	end -- 1961
	local g = ____temp_35 -- 1961
	if g == nil then -- 1961
		return -- 1963
	end -- 1963
	local p = self.player -- 1965
	if self.phase == "gate-idle" then -- 1965
		local a = self.partner -- 1968
		local gap = g.waitX - a.x -- 1969
		if math.abs(gap) > 3 then -- 1969
			a.facing = gap > 0 and 1 or -1 -- 1971
			a.vx = a.facing * CHILD_SPEED -- 1972
			local beforeX = a.x -- 1973
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1974
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1974
				a.vy = CHILD_JUMP -- 1976
				a.onGround = false -- 1977
			end -- 1977
			self:fallY(a, dt) -- 1979
		else -- 1979
			a.vx = 0 -- 1981
			a.x = g.waitX -- 1982
		end -- 1982
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1985
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1986
		if self.gateNeedConfirm then -- 1986
			if not input.interact.held then -- 1986
				self.gateRestartArmed = true -- 1991
			end -- 1991
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1991
				self.gateNeedConfirm = false -- 1994
				self.gateRestartArmed = true -- 1995
				self.phase = "gate-hold" -- 1996
				self.gateTick = 0 -- 1997
				self.gateSpawned = 0 -- 1998
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1999
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2000
			end -- 2000
			return -- 2002
		end -- 2002
		if atWinch and atWait then -- 2002
			self.phase = "gate-hold" -- 2005
			self.gateTick = 0 -- 2006
			self.gateSpawned = 0 -- 2007
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2008
		end -- 2008
		return -- 2010
	end -- 2010
	if self.phase == "gate-hold" then -- 2010
		self.gateTick = self.gateTick + 1 -- 2013
		local marks = {0, 540, 900, 1500} -- 2015
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2015
			local idx = self.gateSpawned -- 2017
			local ____self_enemies_36 = self.enemies -- 2017
			____self_enemies_36[#____self_enemies_36 + 1] = { -- 2018
				x = self.ox + 620 + idx * 62, -- 2019
				y = 0, -- 2019
				w = 26, -- 2019
				h = 84, -- 2019
				alive = true, -- 2020
				hitT = 0, -- 2020
				warnT = 0, -- 2020
				fireCd = 90 + idx * 45 -- 2020
			} -- 2020
			self.gateSpawned = self.gateSpawned + 1 -- 2022
			self:flashSet( -- 2023
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2023
				0.9 -- 2023
			) -- 2023
		end -- 2023
		if self.gateTick == 900 then -- 2023
			self:flashSet("灯灭了", 1) -- 2026
		elseif self.gateTick == 2100 then -- 2026
			self:flashSet("门底压下来了", 1) -- 2028
		end -- 2028
		if self.gateTick >= g.holdTicks then -- 2028
			self:captureGateBlood() -- 2033
			self.phase = "gate-send" -- 2034
			self.phaseTick = 0 -- 2035
			self.enemies = {} -- 2037
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2038
		end -- 2038
		return -- 2040
	end -- 2040
	if self.phase == "gate-send" then -- 2040
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2043
		if near and input.interact.pressed then -- 2043
			self:commitRoute() -- 2046
			self:swapToChild(g.doorX + 30) -- 2047
			self.phase = "gate-count" -- 2048
			self.countTick = 0 -- 2049
			self.countArmed = false -- 2051
			self.countPrevMove = input.moveX -- 2052
			self:flashSet("门开了 · 送她出去", 1.8) -- 2053
		end -- 2053
		return -- 2055
	end -- 2055
	if self.phase == "gate-count" then -- 2055
		self.countTick = self.countTick + 1 -- 2058
		if self.countTick == 360 then -- 2058
			self:flashSet("门关上", 0.9) -- 2060
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2060
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2062
			if self.storyRoute == "soldier" then -- 2062
				self.phase = "gate-wait" -- 2068
				self.phaseTick = 0 -- 2069
				self.knocks = 1 -- 2070
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2071
				self.handArmed = not input.interact.held -- 2073
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2074
			else -- 2074
				self:flashSet("数到二十", 2.2) -- 2076
			end -- 2076
		end -- 2076
		local prevMove = self.countPrevMove -- 2081
		self.countPrevMove = input.moveX -- 2082
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2082
			if prevMove <= 0 and input.moveX > 0 then -- 2082
				self.countArmed = true -- 2085
			end -- 2085
			if self.countArmed and input.moveX > 0 then -- 2085
				self.phase = "gate-walk" -- 2088
				self.phaseTick = 0 -- 2089
				self:flashSet("她迈出第一步", 1.4) -- 2090
				self:emit("storyExit", { -- 2091
					route = "child", -- 2091
					via = "walk", -- 2091
					countTick = self.countTick, -- 2091
					hp = self.hp, -- 2091
					maxHp = self.maxHp -- 2091
				}) -- 2091
			end -- 2091
		end -- 2091
		return -- 2094
	end -- 2094
	if self.phase == "gate-wait" then -- 2094
		self.phaseTick = self.phaseTick + 1 -- 2098
		if self.phaseTick == 12 then -- 2098
			self.knocks = 2 -- 2100
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2101
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2102
		end -- 2102
		if not input.interact.held then -- 2102
			if self.handTicks > 0 then -- 2102
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2106
			end -- 2106
			self.handTicks = 0 -- 2108
			self.handArmed = true -- 2109
			return -- 2110
		end -- 2110
		if self.handArmed then -- 2110
			self.handTicks = self.handTicks + 1 -- 2113
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2113
				self.phase = "gate-hand" -- 2115
				self.phaseTick = 0 -- 2116
				self.handDone = true -- 2117
				self.tied = true -- 2118
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2119
				if not self.lineSaid then -- 2119
					self.lineSaid = true -- 2121
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2122
				end -- 2122
				self:flashSet("我们走吧。", 3) -- 2124
			end -- 2124
		end -- 2124
		return -- 2127
	end -- 2127
	if self.phase == "gate-hand" then -- 2127
		self.phaseTick = self.phaseTick + 1 -- 2131
		if self.phaseTick == 30 then -- 2131
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2133
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2133
			self:emit("storyExit", { -- 2135
				route = "soldier", -- 2135
				via = "hand", -- 2135
				handTicks = self.handTicks, -- 2135
				hp = self.hp, -- 2135
				maxHp = self.maxHp -- 2135
			}) -- 2135
			self:requestRoom("gatepath", "牵手同行") -- 2136
		end -- 2136
		return -- 2138
	end -- 2138
	if self.phase == "gate-walk" then -- 2138
		if self.player.x >= g.exitX then -- 2138
			self:requestRoom("outside", "走出城门") -- 2143
			self:flashSet("出城门 · 城外", 1.4) -- 2144
		end -- 2144
	end -- 2144
end -- 1960
function Play.prototype.captureGateBlood(self) -- 2153
	self.hpAtGate = self.hp -- 2154
	self.maxHpAtGate = self.maxHp -- 2155
end -- 2153
function Play.prototype.commitRoute(self) -- 2162
	if self.storySettled then -- 2162
		return -- 2164
	end -- 2164
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2166
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2167
	self.hpAtGate = hp -- 2168
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2169
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2170
	self.storySettled = true -- 2171
	self:emit("storyRouteLocked", { -- 2172
		route = self.storyRoute, -- 2173
		hp = self.hp, -- 2173
		maxHp = self.maxHp, -- 2173
		hpAtGate = self.hpAtGate, -- 2174
		maxHpAtGate = self.maxHpAtGate -- 2174
	}) -- 2174
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2176
end -- 2162
function Play.prototype.syncStory(self) -- 2180
	if self.isCampaign and self.run.trial ~= nil then -- 2180
		return -- 2182
	end -- 2182
	local s = self.run.story -- 2184
	if s == nil then -- 2184
		return -- 2186
	end -- 2186
	s.hp = self.hp -- 2188
	s.maxHp = self.maxHp -- 2189
	s.route = self.storyRoute -- 2190
	s.settled = self.storySettled -- 2191
	s.hpAtGate = self.hpAtGate -- 2192
	s.maxHpAtGate = self.maxHpAtGate -- 2193
	s.handDone = self.handDone -- 2194
	s.lineSaid = self.lineSaid -- 2195
	s.tied = self.tied -- 2196
	s.carry = self.carryOn -- 2197
	s.museumReturn = self.museumReturn -- 2198
	s.escortDone = self.escortDone -- 2199
	s.craftedWeapon = self.run.story.craftedWeapon -- 2200
	s.ending = self.run.story.ending -- 2201
	if self.room.key == "gate" then -- 2201
		s.phase = self.phase -- 2203
		s.countTick = self.countTick -- 2204
		s.phaseTick = self.phaseTick -- 2205
		s.handTicks = self.handTicks -- 2206
	end -- 2206
end -- 2180
function Play.prototype.stepGatePath(self) -- 2211
	local ____temp_37 -- 2212
	if self.room.story == nil then -- 2212
		____temp_37 = nil -- 2212
	else -- 2212
		____temp_37 = self.room.story.gatepath -- 2212
	end -- 2212
	local gp = ____temp_37 -- 2212
	if self.phase == "gatepath-start" then -- 2212
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2212
			self.carryOn = true -- 2215
			self.phase = "gatepath-carry" -- 2216
			self.phaseTick = 0 -- 2217
			self.pathDone = true -- 2218
			self.escortDone = false -- 2219
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2220
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2221
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2222
		end -- 2222
		return -- 2224
	end -- 2224
	if self.phase == "gatepath-carry" then -- 2224
		self.phaseTick = self.phaseTick + 1 -- 2227
		if self.phaseTick == 20 then -- 2227
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2229
		end -- 2229
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2229
			self:requestRoom(gp.next, "背负进首战") -- 2232
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2233
		end -- 2233
	end -- 2233
end -- 2211
function Play.prototype.carryPose(self) -- 2242
	local p = self.player -- 2243
	local a = self.partner -- 2244
	a.alive = true -- 2245
	a.x = p.x - p.facing * 12 -- 2246
	a.y = p.y + 26 -- 2247
	a.depth = p.depth -- 2248
	a.vx = p.vx -- 2249
	a.vy = 0 -- 2250
	a.onGround = true -- 2251
	a.crouch = false -- 2252
	a.h = CHILD_CROUCH_H -- 2253
	a.facing = p.facing -- 2254
end -- 2242
function Play.prototype.stepMuseum(self, dt, input) -- 2262
	self.partner.alive = false -- 2263
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2264
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2267
	if self.phase == "museum-cabinet" then -- 2267
		if atCase and input.interact.pressed then -- 2267
			self.phase = "museum-hall" -- 2270
			self.phaseTick = 0 -- 2271
			if self:canPersistProgress() then -- 2271
				self.archive.museumPhase = "hall_walk" -- 2273
				self.archiveDirty = true -- 2274
			end -- 2274
			self:emit( -- 2276
				"museumStep", -- 2276
				{ -- 2276
					step = "cabinet", -- 2276
					x = self.ox + mu.cabinetX, -- 2276
					persisted = self:canPersistProgress() -- 2276
				} -- 2276
			) -- 2276
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2277
		end -- 2277
		return -- 2279
	end -- 2279
	if self.phase == "museum-hall" then -- 2279
		if self.player.x >= self.ox + mu.hallX and input.interact.pressed then -- 2279
			self.phase = "museum-lamp" -- 2283
			self.phaseTick = 0 -- 2284
			if self:canPersistProgress() then -- 2284
				self.archive.museumPhase = "lamp_turn" -- 2286
				self.archiveDirty = true -- 2287
			end -- 2287
			self:emit( -- 2289
				"museumStep", -- 2289
				{ -- 2289
					step = "hall", -- 2289
					x = self.ox + mu.hallX, -- 2289
					persisted = self:canPersistProgress() -- 2289
				} -- 2289
			) -- 2289
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2290
		end -- 2290
		return -- 2292
	end -- 2292
	if self.phase == "museum-lamp" then -- 2292
		if self.player.x >= self.ox + mu.lampX and input.interact.pressed then -- 2292
			self.phase = "museum-return" -- 2296
			self.phaseTick = 0 -- 2297
			if self:canPersistProgress() then -- 2297
				self.archive.museumPhase = "return_cabinet" -- 2299
				self.archiveDirty = true -- 2300
			end -- 2300
			self:emit( -- 2302
				"museumStep", -- 2302
				{ -- 2302
					step = "lamp", -- 2302
					x = self.ox + mu.lampX, -- 2302
					persisted = self:canPersistProgress() -- 2302
				} -- 2302
			) -- 2302
			self:flashSet("灯 · 转向西窗", 1.8) -- 2303
		end -- 2303
		return -- 2305
	end -- 2305
	if self.phase == "museum-return" then -- 2305
		if atCase and input.interact.pressed then -- 2305
			self.phase = "museum-knock" -- 2309
			self.phaseTick = 0 -- 2310
			self:emit( -- 2311
				"museumStep", -- 2311
				{ -- 2311
					step = "knock", -- 2311
					count = 1, -- 2311
					x = self.ox + mu.cabinetX, -- 2311
					persisted = self:canPersistProgress() -- 2311
				} -- 2311
			) -- 2311
			self:flashSet("回柜边 · 第一下", 0.8) -- 2312
		end -- 2312
		return -- 2314
	end -- 2314
	if self.phase == "museum-knock" then -- 2314
		self.phaseTick = self.phaseTick + 1 -- 2317
		if self.phaseTick == 8 then -- 2317
			self:emit( -- 2319
				"museumStep", -- 2319
				{ -- 2319
					step = "knock", -- 2319
					count = 2, -- 2319
					x = self.ox + mu.cabinetX, -- 2319
					persisted = self:canPersistProgress() -- 2319
				} -- 2319
			) -- 2319
			self:flashSet("回柜边 · 第二下", 0.8) -- 2320
		elseif self.phaseTick >= 36 then -- 2320
			self.phase = "museum-done" -- 2322
			self.phaseTick = 0 -- 2323
			if self:canPersistProgress() then -- 2323
				self.archive.museumSeen = true -- 2325
				self.archive.museumPhase = "done" -- 2326
				self.archiveDirty = true -- 2327
			end -- 2327
			self:emit( -- 2329
				"museumDone", -- 2329
				{ -- 2329
					steps = 4, -- 2329
					museumSeen = self.archive.museumSeen, -- 2329
					persisted = self:canPersistProgress() -- 2329
				} -- 2329
			) -- 2329
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2330
			self:log("博物馆 · 回柜边") -- 2331
		end -- 2331
		return -- 2333
	end -- 2333
	if input.interact.pressed then -- 2333
		self.museumReturn = true -- 2336
		self:requestRoom("prologue", "回柜边") -- 2337
	end -- 2337
end -- 2262
function Play.prototype.stepTower(self, dt, input) -- 2341
	local ____temp_38 -- 2342
	if self.room.story == nil then -- 2342
		____temp_38 = nil -- 2342
	else -- 2342
		____temp_38 = self.room.story.tower -- 2342
	end -- 2342
	local t = ____temp_38 -- 2342
	if t == nil then -- 2342
		return -- 2344
	end -- 2344
	if self.phase == "tower-wait" then -- 2344
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2347
		if near and input.interact.pressed then -- 2347
			self.phase = "tower-knock" -- 2349
			self.phaseTick = 0 -- 2350
			self.knocks = 1 -- 2351
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2352
			self:flashSet("敲一下", 0.6) -- 2353
		end -- 2353
		return -- 2355
	end -- 2355
	if self.phase == "tower-knock" then -- 2355
		self.phaseTick = self.phaseTick + 1 -- 2358
		if self.phaseTick == 12 then -- 2358
			self.knocks = 2 -- 2360
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2361
			self:flashSet("敲两下 · 第二声", 1) -- 2362
		elseif self.phaseTick >= t.knockTicks then -- 2362
			self.phase = "tower-given" -- 2364
			self.phaseTick = 0 -- 2365
			self:flashSet("门开了 · 提灯", 1.4) -- 2366
		end -- 2366
		return -- 2368
	end -- 2368
	if self.phase == "tower-given" then -- 2368
		local soldier = self.storyRoute == "soldier" -- 2373
		self.phaseTick = self.phaseTick + 1 -- 2374
		if self.phaseTick == 60 then -- 2374
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 2376
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 2377
		elseif self.phaseTick == 120 then -- 2377
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 2379
		elseif self.phaseTick >= 180 then -- 2379
			self.phase = "tower-end" -- 2381
			self.phaseTick = 0 -- 2382
			if not self.run.finished then -- 2382
				self.run.finished = true -- 2384
				local ending = soldier and "reunion" or "lamp" -- 2385
				self.run.story.ending = ending -- 2386
				local ____soldier_39 -- 2389
				if soldier then -- 2389
					____soldier_39 = self.run.story.segments.escort5 == true -- 2390
				else -- 2390
					____soldier_39 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 2391
				end -- 2391
				local played = ____soldier_39 -- 2389
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 2392
				if official then -- 2392
					if soldier then -- 2392
						self.run.archive.soldierCleared = true -- 2396
					else -- 2396
						self.run.archive.childCleared = true -- 2398
					end -- 2398
					self.archiveDirty = true -- 2400
				end -- 2400
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 2402
				self:emit("endingReached", { -- 2403
					route = soldier and "soldier" or "child", -- 2404
					ending = ending, -- 2405
					official = official, -- 2406
					source = self.run.source, -- 2407
					lines = {self.endingLines[1], self.endingLines[2]}, -- 2408
					childCleared = self.run.archive.childCleared, -- 2409
					soldierCleared = self.run.archive.soldierCleared, -- 2410
					artifactOwned = self.run.archive.artifactOwned, -- 2411
					equipped = self.equippedWeapon -- 2412
				}) -- 2412
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 2414
			end -- 2414
		end -- 2414
		return -- 2417
	end -- 2417
	if input.interact.pressed or input.retry.pressed then -- 2417
		self.restartStory = true -- 2421
		self:requestRoom("prologue", "片尾再玩") -- 2422
		self:flashSet("回到序章", 1.4) -- 2423
	end -- 2423
end -- 2341
function Play.prototype.stepChase(self, dt, input) -- 2428
	if self.caughtT > 0 then -- 2428
		self.caughtT = self.caughtT - dt -- 2430
		if self.caughtT <= 0 then -- 2430
			self:recoverFromCaught() -- 2432
		end -- 2432
		return -- 2434
	end -- 2434
	if self.room.key == "village" then -- 2434
		self:stepScavChase() -- 2437
	elseif self.room.key == "forest" then -- 2437
		self:stepDog(dt) -- 2439
		if self.player.x >= self.ox + 1450 then -- 2439
			self:requestRoom("tower", "到林缘北塔") -- 2442
			self:flashSet("林缘 · 北塔", 1.4) -- 2443
		end -- 2443
	end -- 2443
end -- 2428
function Play.prototype.stepScavChase(self) -- 2449
	local s = self.room.scavenger -- 2450
	if s == nil then -- 2450
		return -- 2452
	end -- 2452
	local p = self.player -- 2454
	if self.passed and p.x > self.ox + 440 then -- 2454
		if self.scavChase then -- 2454
			self.scavChase = false -- 2458
			self.scavState = "back" -- 2459
			self.scavT = 0 -- 2460
		end -- 2460
		return -- 2462
	end -- 2462
	local dx = p.x - self.scavX -- 2464
	local dist = math.abs(dx) -- 2465
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 2466
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 2467
	if not self.scavChase then -- 2467
		if visible then -- 2467
			self.scavSee = self.scavSee + 1 -- 2470
			if self.scavSee >= 24 then -- 2470
				self.scavChase = true -- 2472
				self.scavState = "chase" -- 2473
				self.scavTargetX = p.x -- 2474
				self:flashSet("他看见你了", 1.2) -- 2475
			end -- 2475
		else -- 2475
			self.scavSee = 0 -- 2478
		end -- 2478
		return -- 2480
	end -- 2480
	local dir = p.x > self.scavX and 1 or -1 -- 2483
	self.scavX = self.scavX + dir * 96 / 60 -- 2484
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 2484
		self:caught() -- 2486
		return -- 2487
	end -- 2487
	if hidden then -- 2487
		self.scavSee = 0 -- 2491
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 2492
		self.scavT = self.scavT - 1 -- 2493
		if self.scavT <= 0 then -- 2493
			self.scavChase = false -- 2495
			self.scavState = "patrol" -- 2496
			self:flashSet("他失去了目标", 1) -- 2497
		end -- 2497
	end -- 2497
end -- 2449
function Play.prototype.stepDog(self, dt) -- 2503
	local ____temp_40 -- 2504
	if self.room.story == nil then -- 2504
		____temp_40 = nil -- 2504
	else -- 2504
		____temp_40 = self.room.story.dog -- 2504
	end -- 2504
	local dog = ____temp_40 -- 2504
	if dog == nil then -- 2504
		return -- 2506
	end -- 2506
	local p = self.player -- 2508
	local dist = math.abs(p.x - self.dogX) -- 2509
	if self.dogState == "patrol" then -- 2509
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 2511
		if self.dogX < dog.x0 then -- 2511
			self.dogX = dog.x0 -- 2513
			self.dogDir = 1 -- 2514
		elseif self.dogX > dog.x1 then -- 2514
			self.dogX = dog.x1 -- 2516
			self.dogDir = -1 -- 2517
		end -- 2517
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 2519
		if not p.crouch and moving and dist < dog.range then -- 2519
			self.dogState = "ear" -- 2521
			self.dogT = 18 -- 2522
			self.dogTargetX = p.x -- 2523
			self:flashSet("狗转耳朵", 0.8) -- 2524
		end -- 2524
		return -- 2526
	end -- 2526
	if self.dogState == "ear" then -- 2526
		self.dogT = self.dogT - 1 -- 2529
		if self.dogT <= 0 then -- 2529
			self.dogState = "chase" -- 2531
			self.dogTargetX = p.x -- 2532
			self:flashSet("狗追来了", 1.4) -- 2533
		end -- 2533
		return -- 2535
	end -- 2535
	if self.dogState == "chase" then -- 2535
		local dir = p.x > self.dogX and 1 or -1 -- 2538
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 2539
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 2539
			self:caught() -- 2541
			self.dogState = "sniff" -- 2542
			self.dogT = 60 -- 2543
		elseif dist > dog.range * 1.5 or p.crouch then -- 2543
			self.dogState = "sniff" -- 2545
			self.dogT = 60 -- 2546
			self:flashSet("狗停下了", 0.9) -- 2547
		end -- 2547
		return -- 2549
	end -- 2549
	if self.dogState == "sniff" then -- 2549
		self.dogT = self.dogT - 1 -- 2552
		if self.dogT <= 0 then -- 2552
			self.dogState = "back" -- 2554
		end -- 2554
		return -- 2556
	end -- 2556
	local dir = dog.x0 > self.dogX and 1 or -1 -- 2559
	self.dogX = self.dogX + dir * dog.speed * dt -- 2560
	if math.abs(self.dogX - dog.x0) < 2 then -- 2560
		self.dogX = dog.x0 -- 2562
		self.dogState = "patrol" -- 2563
	end -- 2563
end -- 2503
function Play.prototype.caught(self) -- 2567
	self.caughtT = 1 -- 2568
	self:flashSet("被抓 · 回到安全点", 1.6) -- 2569
end -- 2567
function Play.prototype.recoverFromCaught(self) -- 2573
	local p = self.player -- 2574
	p.x = self.ox + 140 -- 2575
	p.y = 0 -- 2576
	p.vy = 0 -- 2577
	p.vx = 0 -- 2578
	p.onGround = true -- 2579
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 2579
		self.scavX = self.room.scavenger.x0 -- 2581
		self.scavState = "patrol" -- 2582
		self.scavSee = 0 -- 2583
		self.scavChase = false -- 2584
		self.scavT = 0 -- 2585
	end -- 2585
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 2585
		self.dogX = self.room.story.dog.x0 -- 2588
		self.dogState = "patrol" -- 2589
		self.dogT = 0 -- 2590
	end -- 2590
	self.cam.x = p.x -- 2592
	self.cam.y = p.y + CAM_LOOK_UP -- 2593
	self:flashSet("回到安全点", 1.2) -- 2594
end -- 2573
function Play.prototype.updateGate(self) -- 2598
	if self.room.key ~= "checkpoint" then -- 2598
		self.gateOpen = false -- 2600
		return -- 2601
	end -- 2601
	local function inZone(x) -- 2603
		return x >= self.ox + 792 and x <= self.ox + 928 -- 2603
	end -- 2603
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 2604
end -- 2598
function Play.prototype.addItem(self, kind) -- 2610
	local inv = self.run.inventory -- 2611
	if kind == "shield" then -- 2611
		if inv.shield >= TOOL_CAP then -- 2611
			return false -- 2614
		end -- 2614
		inv.shield = inv.shield + 1 -- 2616
		return true -- 2617
	end -- 2617
	if kind == "wedge" then -- 2617
		if inv.wedge >= CONSUMABLE_CAP then -- 2617
			return false -- 2621
		end -- 2621
		inv.wedge = inv.wedge + 1 -- 2623
		return true -- 2624
	end -- 2624
	if kind == "ammo" then -- 2624
		if inv.ammo >= CONSUMABLE_CAP then -- 2624
			return false -- 2628
		end -- 2628
		inv.ammo = inv.ammo + 1 -- 2630
		return true -- 2631
	end -- 2631
	if kind == "scrap" then -- 2631
		inv.scrap = inv.scrap + 1 -- 2635
		return true -- 2636
	end -- 2636
	if kind == "wood" then -- 2636
		inv.wood = inv.wood + 1 -- 2639
		return true -- 2640
	end -- 2640
	if kind == "bell" then -- 2640
		inv.bell = inv.bell + 1 -- 2643
		return true -- 2644
	end -- 2644
	if kind == "pass" then -- 2644
		inv.pass = inv.pass + 1 -- 2647
		return true -- 2648
	end -- 2648
	if kind == "quickbelt" then -- 2648
		inv.quickbelt = inv.quickbelt + 1 -- 2651
		return true -- 2652
	end -- 2652
	return false -- 2654
end -- 2610
function Play.prototype.findBox(self, id) -- 2657
	local i = 0 -- 2658
	do -- 2658
		i = 0 -- 2659
		while i < #self.boxes do -- 2659
			if self.boxes[i + 1].id == id then -- 2659
				return self.boxes[i + 1] -- 2661
			end -- 2661
			i = i + 1 -- 2659
		end -- 2659
	end -- 2659
	return nil -- 2664
end -- 2657
function Play.prototype.findWedgeTarget(self) -- 2668
	local best = nil -- 2669
	local bestD = 0 -- 2670
	local i = 0 -- 2671
	do -- 2671
		i = 0 -- 2672
		while i < #self.boxes do -- 2672
			do -- 2672
				local b = self.boxes[i + 1] -- 2673
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 2673
					goto __continue402 -- 2675
				end -- 2675
				if not self:nearBox(b, 26) then -- 2675
					goto __continue402 -- 2678
				end -- 2678
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 2680
				if best == nil or d < bestD then -- 2680
					best = b -- 2682
					bestD = d -- 2683
				end -- 2683
			end -- 2683
			::__continue402:: -- 2683
			i = i + 1 -- 2672
		end -- 2672
	end -- 2672
	return best -- 2686
end -- 2668
function Play.prototype.stepCraft(self, input) -- 2694
	local inv = self.run.inventory -- 2695
	local ____opt_41 = self.run.trial -- 2695
	local required = CRAFT_TICKS - 6 * (____opt_41 and ____opt_41.ranks.craft or 0) -- 2696
	if self.craftT > 0 then -- 2696
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 2696
			self.craftT = 0 -- 2700
			self:flashSet("制作中断", 0.8) -- 2701
			return true -- 2702
		end -- 2702
		self.craftT = self.craftT + 1 -- 2704
		if self.craftT >= required then -- 2704
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 2704
				inv.scrap = inv.scrap - 1 -- 2707
				inv.wedge = inv.wedge + 1 -- 2708
				self:flashSet("制得木楔", 1.2) -- 2709
				self:log("制木楔") -- 2710
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 2711
			end -- 2711
			self.craftT = 0 -- 2713
		end -- 2713
		return true -- 2715
	end -- 2715
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 2715
		self.craftT = 1 -- 2718
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 2719
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 2720
		return true -- 2721
	end -- 2721
	return false -- 2723
end -- 2694
function Play.prototype.nearBox(self, b, reach) -- 2726
	local p = self.player -- 2727
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 2728
end -- 2726
function Play.prototype.findInteract(self) -- 2734
	local p = self.player -- 2735
	local best = nil -- 2736
	local bestD = 1000000000 -- 2737
	local i = 0 -- 2738
	do -- 2738
		i = 0 -- 2739
		while i < #self.boxes do -- 2739
			do -- 2739
				local b = self.boxes[i + 1] -- 2740
				if b.interact == nil or b.broken == true then -- 2740
					goto __continue415 -- 2742
				end -- 2742
				if not self:nearBox(b, b.interact.reach or 27) then -- 2742
					goto __continue415 -- 2745
				end -- 2745
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 2747
				if d < bestD then -- 2747
					bestD = d -- 2749
					best = b -- 2750
				end -- 2750
			end -- 2750
			::__continue415:: -- 2750
			i = i + 1 -- 2739
		end -- 2739
	end -- 2739
	return best -- 2753
end -- 2734
function Play.prototype.stepCampaign(self, dt, input) -- 2757
	local wr = self.room -- 2758
	local p = self.player -- 2759
	if self.reloadT > 0 then -- 2759
		self.reloadT = self.reloadT - 1 -- 2761
	end -- 2761
	if self.bracedShield ~= nil then -- 2761
		self.bracedShield.x = p.x + p.facing * 26 -- 2765
		self.bracedShield.y = p.y -- 2766
		local shBox = __TS__ArrayFind( -- 2767
			self.boxes, -- 2767
			function(____, b) return b.id == "braced_shield" end -- 2767
		) -- 2767
		if shBox ~= nil then -- 2767
			shBox.x0 = self.bracedShield.x - 15 -- 2769
			shBox.x1 = self.bracedShield.x + 15 -- 2770
			shBox.y0 = self.bracedShield.y -- 2771
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 2772
		end -- 2772
	end -- 2772
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 2772
		self.run.route = "drygoods" -- 2778
		self.run.joined = false -- 2779
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 2780
		self:log("转布行线") -- 2781
	end -- 2781
	if wr.key == "escort3" then -- 2781
		local benchX = wr.minX + 560 -- 2785
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 60 -- 2786
		if self.craftBench.active then -- 2786
			if input.interact.pressed or input.pause.pressed then -- 2786
				self:closeCraftBench() -- 2789
			end -- 2789
		elseif nearBench and input.interact.pressed then -- 2789
			self:openCraftBench() -- 2792
		end -- 2792
	end -- 2792
	local i = 0 -- 2796
	do -- 2796
		i = 0 -- 2797
		while i < #self.pickups do -- 2797
			do -- 2797
				local pk = self.pickups[i + 1] -- 2798
				if pk.id == "" or self.run.taken[pk.id] == true then -- 2798
					goto __continue430 -- 2800
				end -- 2800
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 2802
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 2803
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 2803
					if not self:addItem(pk.kind) then -- 2803
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 2807
						self:log("满包拒绝 " .. pk.kind) -- 2808
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 2809
						goto __continue430 -- 2810
					end -- 2810
					self.run.taken[pk.id] = true -- 2812
					pk.id = "" -- 2813
					self:flashSet("拾取 " .. pk.label, 1) -- 2814
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 2815
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 2816
				end -- 2816
			end -- 2816
			::__continue430:: -- 2816
			i = i + 1 -- 2797
		end -- 2797
	end -- 2797
	if not self:stepCraft(input) and input.interact.pressed then -- 2797
		self:campaignInteract() -- 2820
	end -- 2820
	self:stepCampaignCart(dt, input) -- 2822
	self:stepCampaignGoal() -- 2823
	self:campaignCheckpoint() -- 2824
end -- 2757
function Play.prototype.campaignCheckpoint(self) -- 2828
	local i = 0 -- 2829
	do -- 2829
		i = 0 -- 2830
		while i < #self.room.marks do -- 2830
			do -- 2830
				local m = self.room.marks[i + 1] -- 2831
				if m.kind ~= 0 then -- 2831
					goto __continue437 -- 2833
				end -- 2833
				local dx = self.player.x - m.x -- 2835
				local dy = self.player.y - m.y -- 2836
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2836
					self.checkpoint = m.x -- 2838
					self:captureCheckpoint(m.x) -- 2839
					self:flashSet("检查点", 1) -- 2840
				end -- 2840
			end -- 2840
			::__continue437:: -- 2840
			i = i + 1 -- 2830
		end -- 2830
	end -- 2830
end -- 2828
function Play.prototype.campaignInteract(self) -- 2846
	local b = self:findInteract() -- 2847
	if b ~= nil then -- 2847
		self:useInteract(b) -- 2849
		return -- 2850
	end -- 2850
	local inv = self.run.inventory -- 2852
	if inv.wedge > 0 then -- 2852
		local w = self:findWedgeTarget() -- 2854
		if w ~= nil then -- 2854
			if w.breakable ~= nil then -- 2854
				local ____w_breakable_43, ____hp_44 = w.breakable, "hp" -- 2854
				____w_breakable_43[____hp_44] = ____w_breakable_43[____hp_44] + (w.breakable.wedgeHp or 1) -- 2857
			end -- 2857
			inv.wedge = inv.wedge - 1 -- 2859
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 2860
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 2862
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 2863
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 2864
			return -- 2865
		end -- 2865
	end -- 2865
	if inv.ammo > 0 and self.reloadT > 0 then -- 2865
		self.reloadT = 0 -- 2870
		self:closeReloadPuzzle() -- 2871
		inv.ammo = inv.ammo - 1 -- 2872
		self:flashSet("备用弹包 · 膛内补满", 1) -- 2873
		self:log("用备用弹包") -- 2874
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 2875
		return -- 2876
	end -- 2876
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 2876
		local p = self.player -- 2880
		self.bracedShield = { -- 2881
			x = p.x + p.facing * 26, -- 2881
			y = p.y, -- 2881
			w = 30, -- 2881
			h = 64, -- 2881
			hp = 1 -- 2881
		} -- 2881
		local ____self_boxes_45 = self.boxes -- 2881
		____self_boxes_45[#____self_boxes_45 + 1] = { -- 2882
			x0 = self.bracedShield.x - 15, -- 2883
			x1 = self.bracedShield.x + 15, -- 2883
			y0 = p.y, -- 2884
			y1 = p.y + 64, -- 2884
			depth = {min = -46, max = 46}, -- 2884
			label = "架起的残盾", -- 2884
			id = "braced_shield", -- 2884
			soft = true -- 2885
		} -- 2885
		inv.shield = inv.shield - 1 -- 2888
		self:flashSet("架残盾 · 挡一发", 1.2) -- 2889
		self:log("架残盾") -- 2890
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 2891
		return -- 2892
	end -- 2892
	if inv.pass > 0 and self.run.joined == false then -- 2892
		inv.pass = inv.pass - 1 -- 2895
		self.run.joined = true -- 2896
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 2897
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 2898
		return -- 2899
	end -- 2899
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 2901
end -- 2846
function Play.prototype.useInteract(self, b) -- 2904
	local kind = b.interact == nil and "" or b.interact.kind -- 2905
	local wr = self.room -- 2906
	if kind == "open_board" then -- 2906
		b.broken = true -- 2908
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 2909
		for ____, cover in ipairs(self.boxes) do -- 2910
			if cover.id == "s2_board_cover" then -- 2910
				cover.broken = false -- 2912
				cover.hidden = false -- 2913
			end -- 2913
		end -- 2913
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 2916
		self.run.joined = true -- 2917
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 2918
		self:log("放下窗板") -- 2919
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 2920
		return -- 2921
	end -- 2921
	if kind == "lower_curtain" then -- 2921
		for ____, curtain in ipairs(self.boxes) do -- 2924
			if curtain.id == "c2_curtain" then -- 2924
				curtain.broken = false -- 2926
				curtain.hidden = false -- 2927
			end -- 2927
		end -- 2927
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 2930
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 2931
		self:log("放下木帘") -- 2932
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 2933
		return -- 2934
	end -- 2934
	if kind == "raise_latch" then -- 2934
		if wr.key == "c2-granary" and not self.cartDocked then -- 2934
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 2938
			return -- 2939
		end -- 2939
		b.broken = true -- 2941
		self.objectiveDone = true -- 2942
		if wr.key == "c1-yard" then -- 2942
			self.run.c1Latch = true -- 2945
			self.run.joined = true -- 2946
		else -- 2946
			self.run.c2Latch = true -- 2948
			self.run.joined = true -- 2949
		end -- 2949
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 2951
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 2952
		self:log("抬闩") -- 2953
		self:flashSet("抬闩 · 通路打开", 1.4) -- 2954
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 2955
	end -- 2955
end -- 2904
function Play.prototype.stepCampaignCart(self, dt, input) -- 2960
	local wr = self.room -- 2961
	local c = wr.cart -- 2962
	if c.bodyW <= 0 then -- 2962
		return -- 2964
	end -- 2964
	local p = self.player -- 2966
	local handleX = self.cartAxle + c.handleOffset -- 2967
	if not self.gripping then -- 2967
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 2967
			self.gripping = true -- 2971
			self:flashSet("握住车柄 · A/D 推", 1) -- 2972
		end -- 2972
		return -- 2974
	end -- 2974
	if input.interact.pressed then -- 2974
		self.gripping = false -- 2977
		self:flashSet("松手", 0.5) -- 2978
		return -- 2979
	end -- 2979
	if not self.cartDocked then -- 2979
		if input.moveX ~= 0 and not self:stuckCart() then -- 2979
			self.cartAxle = math.max( -- 2983
				c.startX, -- 2983
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 2983
			) -- 2983
		end -- 2983
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 2983
			self.cartExposed = true -- 2988
			local gun = nil -- 2989
			local gi = 0 -- 2990
			do -- 2990
				gi = 0 -- 2991
				while gi < #self.enemies do -- 2991
					local e = self.enemies[gi + 1] -- 2992
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 2992
						gun = e -- 2994
						break -- 2995
					end -- 2995
					gi = gi + 1 -- 2991
				end -- 2991
			end -- 2991
			if gun ~= nil then -- 2991
				self:campaignEnemyFire(gun) -- 2999
			end -- 2999
		end -- 2999
		p.x = self.cartAxle + c.handleOffset -- 3002
		p.y = c.baseY + (c.depth or 0) -- 3003
		p.vx = 0 -- 3004
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3004
			self.cartAxle = c.endX -- 3006
			self.cartDocked = true -- 3007
			self.gripping = false -- 3008
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3009
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3010
			self:flashSet("车轮入窝", 1.2) -- 3011
			self:log("车轮入窝") -- 3012
		end -- 3012
	end -- 3012
end -- 2960
function Play.prototype.stuckCart(self) -- 3018
	local i = 0 -- 3019
	do -- 3019
		i = 0 -- 3020
		while i < #self.boxes do -- 3020
			do -- 3020
				local b = self.boxes[i + 1] -- 3021
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3021
					goto __continue476 -- 3023
				end -- 3023
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 3025
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3025
					return true -- 3027
				end -- 3027
			end -- 3027
			::__continue476:: -- 3027
			i = i + 1 -- 3020
		end -- 3020
	end -- 3020
	return false -- 3030
end -- 3018
function Play.prototype.stepCampaignGoal(self) -- 3034
	local wr = self.room -- 3035
	local c = wr.campaign -- 3036
	if c == nil then -- 3036
		return -- 3038
	end -- 3038
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3038
		self.objectiveDone = true -- 3041
	end -- 3041
	if c.goal == "reach_exit" then -- 3041
		self.objectiveDone = true -- 3044
	end -- 3044
	if not self.objectiveDone then -- 3044
		return -- 3047
	end -- 3047
	local p = self.player -- 3049
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3050
	if p.x < c.exitX or not partnerOk then -- 3050
		return -- 3052
	end -- 3052
	if self.run.story.segments[wr.key] ~= true then -- 3052
		self.run.story.segments[wr.key] = true -- 3056
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3057
	end -- 3057
	if wr.key == "escort5" then -- 3057
		self.escortDone = true -- 3061
		self.run.story.escortDone = true -- 3062
	end -- 3062
	if c.next ~= nil and c.next ~= "" then -- 3062
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3065
		self:flashSet("过关 · " .. c.next, 1.2) -- 3066
	elseif not self.run.finished then -- 3066
		self.run.finished = true -- 3068
		self:flashSet( -- 3069
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3069
			2 -- 3069
		) -- 3069
		self:log("C2 灰盒完成") -- 3070
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3071
	end -- 3071
end -- 3034
function Play.prototype.stepCampaignPartner(self, dt) -- 3076
	local a = self.partner -- 3077
	local wr = self.room -- 3078
	local cp = wr.companion -- 3079
	if not a.alive then -- 3079
		return -- 3081
	end -- 3081
	local p = self.player -- 3083
	if self.craftBench.active then -- 3083
		a.vx = 0 -- 3086
		return -- 3087
	end -- 3087
	local wait = false -- 3089
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3090
	local targetDepth = p.depth -- 3091
	if self.run.joined == false then -- 3091
		wait = true -- 3093
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3094
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3095
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3095
		wait = true -- 3097
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3098
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3099
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3099
		wait = true -- 3101
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3102
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3103
	end -- 3103
	if self.partnerStuck > 0.3 then -- 3103
		a.x = a.x + a.facing * 44 -- 3107
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3108
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3109
		self.partnerLaneHold = 1.1 -- 3110
		self.partnerStuck = 0 -- 3111
	end -- 3111
	if self.partnerLaneHold > 0 then -- 3111
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3114
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3115
	end -- 3115
	local dx = targetX - a.x -- 3117
	if not wait and math.abs(dx) > 74 then -- 3117
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3119
		local before = a.x -- 3120
		a.vx = dx > 0 and speed or -speed -- 3121
		a.facing = dx > 0 and 1 or -1 -- 3122
		self:slideX(a, a.vx * dt) -- 3123
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3123
			a.vy = CHILD_JUMP -- 3126
			a.onGround = false -- 3127
		end -- 3127
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3129
	else -- 3129
		a.vx = 0 -- 3131
		self.partnerStuck = 0 -- 3132
	end -- 3132
	local dz = targetDepth - a.depth -- 3134
	if math.abs(dz) > 6 then -- 3134
		local step = math.max( -- 3136
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3136
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3136
		) -- 3136
		a.depth = a.depth + step -- 3137
	end -- 3137
	a.depthSpeed = 0 -- 3139
	a.h = CHILD_H -- 3140
	a.crouch = false -- 3141
	self:fallY(a, dt) -- 3142
end -- 3076
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3146
	local p = self.player -- 3147
	local i = 0 -- 3148
	do -- 3148
		i = 0 -- 3149
		while i < #self.enemies do -- 3149
			do -- 3149
				local ____opt_46 = self.run.trial -- 3149
				if ____opt_46 and ____opt_46.lost then -- 3149
					return -- 3150
				end -- 3150
				local e = self.enemies[i + 1] -- 3151
				if not e.alive then -- 3151
					goto __continue503 -- 3153
				end -- 3153
				if e.hitT > 0 then -- 3153
					e.hitT = e.hitT - dt -- 3156
				end -- 3156
				if e.kind == "target" then -- 3156
					if not e.alive and e.hitT <= 0 then -- 3156
						e.alive = true -- 3161
					end -- 3161
					goto __continue503 -- 3163
				end -- 3163
				if e.kind == "breaker" then -- 3163
					self:stepBreaker(e, dt) -- 3166
					goto __continue503 -- 3167
				end -- 3167
				if e.kind == "shield" then -- 3167
					self:stepShield(e, dt, input) -- 3170
					goto __continue503 -- 3171
				end -- 3171
				local dx = e.x - p.x -- 3174
				if not e.awake then -- 3174
					if math.abs(dx) > 520 then -- 3174
						goto __continue503 -- 3177
					end -- 3177
					e.awake = true -- 3179
					e.fireCd = 48 -- 3180
					goto __continue503 -- 3181
				end -- 3181
				if math.abs(dx) > ENEMY_RANGE then -- 3181
					goto __continue503 -- 3184
				end -- 3184
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 3184
					goto __continue503 -- 3189
				end -- 3189
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 3189
					goto __continue503 -- 3192
				end -- 3192
				if self:blockedShot(e, p) then -- 3192
					if e.warnT > 0 then -- 3192
						e.warnT = 0 -- 3198
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3199
					end -- 3199
					goto __continue503 -- 3201
				end -- 3201
				if e.warnT > 0 then -- 3201
					e.warnT = e.warnT - 1 -- 3204
					if e.warnT <= 0 then -- 3204
						self:campaignEnemyFire(e) -- 3206
					end -- 3206
				elseif e.fireCd > 0 then -- 3206
					e.fireCd = e.fireCd - 1 -- 3209
					if e.fireCd <= 0 then -- 3209
						e.warnT = WARN_TICKS -- 3211
					end -- 3211
				else -- 3211
					e.fireCd = 40 -- 3214
				end -- 3214
			end -- 3214
			::__continue503:: -- 3214
			i = i + 1 -- 3149
		end -- 3149
	end -- 3149
end -- 3146
function Play.prototype.blockedShot(self, e, p) -- 3220
	local eDepth = e.depth or 0 -- 3221
	local ex = e.x -- 3222
	local ey = e.y + e.h * 0.62 -- 3224
	local px = p.x -- 3225
	local py = p.y + p.h * 0.55 -- 3226
	local dx = px - ex -- 3227
	local dyScreen = py + p.depth - (ey + eDepth) -- 3228
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3229
	if len < 0.01 then -- 3229
		return false -- 3231
	end -- 3231
	local ray = { -- 3235
		x = ex, -- 3236
		y = ey, -- 3236
		dx = dx / len, -- 3237
		dy = (py - ey) / len, -- 3237
		depth = eDepth, -- 3238
		dDepth = (p.depth - eDepth) / len -- 3238
	} -- 3238
	local best = -1 -- 3240
	local j = 0 -- 3241
	do -- 3241
		j = 0 -- 3242
		while j < #self.boxes do -- 3242
			do -- 3242
				local b = self.boxes[j + 1] -- 3243
				if b.broken == true or b.passable == true or b.hidden == true then -- 3243
					goto __continue526 -- 3245
				end -- 3245
				if b.id == "braced_shield" then -- 3245
					goto __continue526 -- 3250
				end -- 3250
				local t = hitBox(ray, b) -- 3252
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3252
					best = t -- 3256
				end -- 3256
			end -- 3256
			::__continue526:: -- 3256
			j = j + 1 -- 3242
		end -- 3242
	end -- 3242
	return best >= 0 -- 3259
end -- 3220
function Play.prototype.campaignEnemyFire(self, e) -- 3262
	local p = self.player -- 3263
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3264
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3264
		local ____self_bracedShield_48, ____hp_49 = self.bracedShield, "hp" -- 3264
		____self_bracedShield_48[____hp_49] = ____self_bracedShield_48[____hp_49] - 1 -- 3266
		self.boxes = __TS__ArrayFilter( -- 3267
			self.boxes, -- 3267
			function(____, b) return b.id ~= "braced_shield" end -- 3267
		) -- 3267
		self.bracedShield = nil -- 3268
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3269
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3270
		return -- 3271
	end -- 3271
	if self:blockedShot(e, p) then -- 3271
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3274
		return -- 3275
	end -- 3275
	local cover = self:blockedByCover(e, p) -- 3277
	if cover ~= nil and self.coverHug then -- 3277
		self.coveredFlash = 0.5 -- 3279
		self:flashSet("掩体挡下", 0.6) -- 3280
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3281
		return -- 3286
	end -- 3286
	if self.invulnT > 0 then -- 3286
		return -- 3289
	end -- 3289
	local ____opt_50 = self.run.trial -- 3289
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_50 and ____opt_50.ranks.guard or 0) -- 3291
	self.craftT = 0 -- 3292
	self.hp = self.hp - 1 -- 3293
	self:emit("actorHit", { -- 3294
		target = "player", -- 3294
		amount = 1, -- 3294
		hp = self.hp, -- 3294
		maxHp = self.maxHp, -- 3294
		enemyX = e.x -- 3294
	}) -- 3294
	self:flashSet( -- 3295
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3295
		0.8 -- 3295
	) -- 3295
	if self.hp <= 0 then -- 3295
		self:campaignFailed() -- 3297
	end -- 3297
end -- 3262
function Play.prototype.stepShield(self, e, dt, input) -- 3302
	local p = self.player -- 3303
	local dx = p.x - e.x -- 3304
	local adx = math.abs(dx) -- 3305
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 3308
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 3309
	if adx > 150 then -- 3309
		local before = e.x -- 3311
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 3312
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 3312
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3315
		end -- 3315
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 3315
		local fromFront = (e.x - p.x) * p.facing > 0 -- 3320
		local rollDodges = p.rollT > 0 and fromFront -- 3321
		if not rollDodges and self.invulnT <= 0 then -- 3321
			local ____opt_52 = self.run.trial -- 3321
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_52 and ____opt_52.ranks.guard or 0) -- 3323
			self.craftT = 0 -- 3324
			self.hp = self.hp - 1 -- 3325
			self:emit("actorHit", { -- 3326
				target = "player", -- 3326
				amount = 1, -- 3326
				hp = self.hp, -- 3326
				maxHp = self.maxHp, -- 3326
				enemyX = e.x -- 3326
			}) -- 3326
			self:flashSet( -- 3327
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3327
				0.8 -- 3327
			) -- 3327
			if self.hp <= 0 then -- 3327
				self:campaignFailed() -- 3329
				return -- 3330
			end -- 3330
		end -- 3330
		e.swingT = 70 -- 3333
	end -- 3333
	if (e.swingT or 0) > 0 then -- 3333
		e.swingT = (e.swingT or 0) - 1 -- 3336
	end -- 3336
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 3336
		local dd = p.depth - (e.depth or 0) -- 3339
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 3340
	end -- 3340
end -- 3302
function Play.prototype.stepBreaker(self, e, dt) -- 3345
	local p = self.player -- 3346
	if e.awake ~= true then -- 3346
		if math.abs(p.x - e.x) < 560 then -- 3346
			e.awake = true -- 3349
		else -- 3349
			return -- 3351
		end -- 3351
	end -- 3351
	local target = nil -- 3354
	local bestD = 1000000000 -- 3355
	local i = 0 -- 3356
	do -- 3356
		i = 0 -- 3357
		while i < #self.boxes do -- 3357
			do -- 3357
				local b = self.boxes[i + 1] -- 3358
				if b.breakable == nil or b.broken == true then -- 3358
					goto __continue550 -- 3360
				end -- 3360
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 3362
				if d < bestD then -- 3362
					bestD = d -- 3364
					target = b -- 3365
				end -- 3365
			end -- 3365
			::__continue550:: -- 3365
			i = i + 1 -- 3357
		end -- 3357
	end -- 3357
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 3368
	local dx = tx - e.x -- 3369
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 3370
	if math.abs(dx) > reach then -- 3370
		local before = e.x -- 3372
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 3373
		if math.abs(e.x - before) < 0.3 then -- 3373
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3375
		end -- 3375
	elseif (e.swingT or 0) <= 0 then -- 3375
		e.swingT = 64 -- 3378
		if target ~= nil then -- 3378
			self:damageProp(target, 2) -- 3380
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 3380
			local ____opt_54 = self.run.trial -- 3380
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_54 and ____opt_54.ranks.guard or 0) -- 3382
			self.craftT = 0 -- 3383
			self.hp = self.hp - 1 -- 3384
			self:emit("actorHit", { -- 3385
				target = "player", -- 3385
				amount = 1, -- 3385
				hp = self.hp, -- 3385
				maxHp = self.maxHp, -- 3385
				enemyX = e.x -- 3385
			}) -- 3385
			self:flashSet("破障手近身", 0.8) -- 3386
			if self.hp <= 0 then -- 3386
				self:campaignFailed() -- 3388
				return -- 3389
			end -- 3389
		end -- 3389
	end -- 3389
	if (e.swingT or 0) > 0 then -- 3389
		e.swingT = (e.swingT or 0) - 1 -- 3394
	end -- 3394
end -- 3345
function Play.prototype.campaignFailed(self) -- 3398
	if self.run.trial ~= nil then -- 3398
		self.run.trial.lost = true -- 3400
		self.wantRoom = "" -- 3401
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3402
		return -- 3403
	end -- 3403
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 3403
		self:restartEscortFromDeath() -- 3408
		return -- 3409
	end -- 3409
	local p = self.player -- 3411
	self.hp = self.maxHp -- 3412
	self.invulnT = INVULN_RESPAWN_TICKS -- 3413
	self.reloadT = 0 -- 3414
	self:closeReloadPuzzle() -- 3415
	self.gripping = false -- 3416
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 3417
	self:log("被击倒") -- 3418
	p.x = self.room.minX + 90 -- 3419
	p.y = 0 -- 3420
	p.depth = 0 -- 3421
	p.vx = 0 -- 3422
	p.vy = 0 -- 3423
	p.onGround = true -- 3424
	p.rollT = 0 -- 3425
	self.partner.x = p.x - 50 -- 3426
	self.partner.y = 0 -- 3427
	self.partner.depth = 0 -- 3428
	self.cam.x = p.x -- 3429
	local i = 0 -- 3430
	do -- 3430
		i = 0 -- 3431
		while i < #self.enemies do -- 3431
			do -- 3431
				local e = self.enemies[i + 1] -- 3432
				if not e.alive then -- 3432
					goto __continue564 -- 3434
				end -- 3434
				e.x = e.homeX == nil and e.x or e.homeX -- 3436
				e.warnT = 0 -- 3437
				e.fireCd = 40 -- 3438
				e.swingT = 0 -- 3439
				e.awake = false -- 3440
			end -- 3440
			::__continue564:: -- 3440
			i = i + 1 -- 3431
		end -- 3431
	end -- 3431
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3442
end -- 3398
function Play.prototype.isEscortRoom(self) -- 3446
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 3447
end -- 3446
function Play.prototype.restartEscortFromDeath(self) -- 3455
	local story = self.run.story -- 3456
	local inv = self.run.inventory -- 3457
	self.hp = self.maxHp -- 3458
	story.hp = self.maxHp -- 3459
	story.cp = nil -- 3460
	self.checkpointSnap = nil -- 3461
	story.carry = false -- 3462
	self.carryOn = false -- 3463
	story.craftedWeapon = "" -- 3464
	self.equippedWeapon = "standard_gun" -- 3465
	story.escortDone = false -- 3466
	self.escortDone = false -- 3467
	story.segments = {} -- 3468
	inv.wood = 0 -- 3469
	inv.bell = 0 -- 3470
	inv.scrap = 0 -- 3471
	inv.wedge = 0 -- 3472
	inv.ammo = 0 -- 3473
	inv.quickbelt = 0 -- 3474
	inv.shield = 0 -- 3475
	inv.pass = 0 -- 3476
	local taken = self.run.taken -- 3477
	local keys = __TS__ObjectKeys(taken) -- 3478
	local i = 0 -- 3479
	do -- 3479
		i = 0 -- 3480
		while i < #keys do -- 3480
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 3480
				__TS__Delete(taken, keys[i + 1]) -- 3482
			end -- 3482
			i = i + 1 -- 3480
		end -- 3480
	end -- 3480
	self.run.joined = true -- 3485
	self.reloadT = 0 -- 3486
	self:closeReloadPuzzle() -- 3487
	self.gripping = false -- 3488
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 3489
	self:log("男主线失败 · 回 escort1") -- 3490
	self:emit("campaignFailed", { -- 3491
		room = self.room.key, -- 3492
		hp = 0, -- 3492
		maxHp = self.maxHp, -- 3492
		reset = true, -- 3493
		to = "escort1", -- 3493
		route = self.storyRoute -- 3493
	}) -- 3493
	self:requestRoom("escort1", "男主线失败重开") -- 3495
end -- 3455
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 3499
	local i = 0 -- 3500
	do -- 3500
		i = 0 -- 3501
		while i < #self.enemies do -- 3501
			do -- 3501
				if i == skipIndex then -- 3501
					goto __continue573 -- 3503
				end -- 3503
				local e = self.enemies[i + 1] -- 3505
				if not e.alive or math.abs(e.x - center.x) > radius then -- 3505
					goto __continue573 -- 3507
				end -- 3507
				e.fireCd = 150 -- 3509
				e.warnT = 0 -- 3510
			end -- 3510
			::__continue573:: -- 3510
			i = i + 1 -- 3501
		end -- 3501
	end -- 3501
end -- 3499
function Play.prototype.stepEnemies(self, dt, input) -- 3514
	local i = 0 -- 3515
	do -- 3515
		i = 0 -- 3516
		while i < #self.enemies do -- 3516
			local e = self.enemies[i + 1] -- 3517
			if e.hitT > 0 then -- 3517
				e.hitT = e.hitT - dt -- 3519
			end -- 3519
			i = i + 1 -- 3516
		end -- 3516
	end -- 3516
	if self.coveredFlash > 0 then -- 3516
		self.coveredFlash = self.coveredFlash - dt -- 3523
	end -- 3523
	if self.isCampaign then -- 3523
		self:stepCampaignEnemies(dt, input) -- 3526
		return -- 3527
	end -- 3527
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 3527
		return -- 3531
	end -- 3531
	do -- 3531
		i = 0 -- 3533
		while i < #self.enemies do -- 3533
			do -- 3533
				local e = self.enemies[i + 1] -- 3534
				if not e.alive then -- 3534
					goto __continue584 -- 3536
				end -- 3536
				if e.warnT > 0 then -- 3536
					e.warnT = e.warnT - 1 -- 3539
					if e.warnT <= 0 then -- 3539
						self:enemyFire(e, input) -- 3541
					end -- 3541
					goto __continue584 -- 3543
				end -- 3543
				if e.fireCd > 0 then -- 3543
					e.fireCd = e.fireCd - 1 -- 3546
					if e.fireCd <= 0 then -- 3546
						e.warnT = WARN_TICKS -- 3548
					end -- 3548
				else -- 3548
					e.warnT = WARN_TICKS -- 3552
				end -- 3552
			end -- 3552
			::__continue584:: -- 3552
			i = i + 1 -- 3533
		end -- 3533
	end -- 3533
end -- 3514
function Play.prototype.enemyFire(self, e, input) -- 3558
	local p = self.player -- 3559
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 3559
		self:flashSet("枪声响在远处", 0.4) -- 3561
		e.fireCd = FIRE_COOLDOWN -- 3562
		return -- 3563
	end -- 3563
	local cover = self:blockedByCover(e, p) -- 3566
	local hugging = cover ~= nil -- 3567
	self.coverBlocking = hugging -- 3568
	local covered = hugging and input.cover.held -- 3569
	if covered then -- 3569
		self.coveredFlash = 0.5 -- 3571
		self:flashSet("掩体挡下", 0.5) -- 3572
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3573
		e.fireCd = FIRE_COOLDOWN -- 3578
		return -- 3579
	end -- 3579
	self.hp = self.hp - 1 -- 3581
	self:emit("actorHit", { -- 3582
		target = "player", -- 3582
		amount = 1, -- 3582
		hp = self.hp, -- 3582
		maxHp = self.maxHp, -- 3582
		enemyX = e.x -- 3582
	}) -- 3582
	self:flashSet( -- 3583
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3583
		0.7 -- 3583
	) -- 3583
	e.fireCd = FIRE_COOLDOWN -- 3584
	if self.hp <= 0 then -- 3584
		self:gateFailed() -- 3586
	end -- 3586
end -- 3558
function Play.prototype.blockedByCover(self, enemy, p) -- 3591
	local b = self:coverAt(p) -- 3592
	if b == nil then -- 3592
		return nil -- 3594
	end -- 3594
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 3596
end -- 3591
function Play.prototype.gateFailed(self) -- 3600
	local ____temp_56 -- 3601
	if self.room.story == nil then -- 3601
		____temp_56 = nil -- 3601
	else -- 3601
		____temp_56 = self.room.story.gate -- 3601
	end -- 3601
	local g = ____temp_56 -- 3601
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 3602
	self.hp = self.maxHp -- 3603
	self.gateTick = 0 -- 3604
	self.gateSpawned = 0 -- 3605
	self.enemies = {} -- 3606
	self.gateFailCount = self.gateFailCount + 1 -- 3607
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 3609
	self.player.y = 0 -- 3610
	self.player.vy = 0 -- 3611
	self.player.depth = 0 -- 3612
	self.player.depthSpeed = 0 -- 3613
	self.player.onGround = true -- 3614
	self.player.crouch = false -- 3615
	self.player.h = SOLDIER_H -- 3616
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 3617
	self.partner.y = 0 -- 3618
	self.partner.vy = 0 -- 3619
	self.partner.depth = 0 -- 3620
	self.partner.depthSpeed = 0 -- 3621
	self.partner.onGround = true -- 3622
	self.cam.x = self.player.x -- 3623
	self.phase = "gate-idle" -- 3624
	self.phaseTick = 0 -- 3625
	self.coverHug = false -- 3626
	self.coverBlocking = false -- 3627
	self.coverEntity = "" -- 3628
	self.gateNeedConfirm = true -- 3629
	self.gateRestartArmed = false -- 3630
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 3631
end -- 3600
function Play.prototype.stepInteract(self, dt, input) -- 3634
	local p = self.player -- 3635
	local calmUsed = self.calmConsumed -- 3636
	self.calmConsumed = false -- 3637
	local calming = self.escort.state == "calming" -- 3639
	self.focusCart = false -- 3640
	if self.room.key == "outside" then -- 3640
		local c = self.room.cart -- 3642
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 3643
		local dy = p.y - c.baseY -- 3644
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 3645
	end -- 3645
	if not calmUsed and not calming then -- 3645
		self:stepCart(dt, input) -- 3649
	end -- 3649
	if calmUsed then -- 3649
		self:flashSet("安抚 · 敲两下", 0.8) -- 3654
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 3654
		if self.knockT > 0 then -- 3654
			self.knocks = self.knocks + 1 -- 3658
		else -- 3658
			self.knocks = 1 -- 3660
		end -- 3660
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 3662
		self.knockT = 1.2 -- 3663
		if self.knocks >= 2 then -- 3663
			self:flashSet("敲两下", 0.8) -- 3665
			self.knocks = 0 -- 3666
		else -- 3666
			self:flashSet("敲一下", 0.5) -- 3668
		end -- 3668
	elseif self.knockT > 0 then -- 3668
		self.knockT = self.knockT - dt -- 3671
		if self.knockT <= 0 then -- 3671
			self.knocks = 0 -- 3673
		end -- 3673
	end -- 3673
	local i = 0 -- 3678
	do -- 3678
		i = 0 -- 3679
		while i < #self.room.marks do -- 3679
			do -- 3679
				local m = self.room.marks[i + 1] -- 3680
				if m.kind ~= 0 then -- 3680
					goto __continue610 -- 3682
				end -- 3682
				local subjects = {self.partner, self.player} -- 3684
				local k = 0 -- 3685
				do -- 3685
					k = 0 -- 3686
					while k < #subjects do -- 3686
						do -- 3686
							local s = subjects[k + 1] -- 3687
							if not s.alive then -- 3687
								goto __continue613 -- 3689
							end -- 3689
							local dx = s.x - m.x -- 3691
							local dy = s.y - m.y -- 3692
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3692
								self.checkpoint = m.x -- 3694
								self.checkpointCartAxle = self.cartAxle -- 3695
								if self.isCampaign then -- 3695
									self:captureCheckpoint(m.x) -- 3698
								end -- 3698
								if self.cartDocked then -- 3698
									self:flashSet("检查点 · 车已落窝", 1) -- 3701
								else -- 3701
									self:flashSet("检查点 · 车还没到位", 1) -- 3703
								end -- 3703
							end -- 3703
						end -- 3703
						::__continue613:: -- 3703
						k = k + 1 -- 3686
					end -- 3686
				end -- 3686
			end -- 3686
			::__continue610:: -- 3686
			i = i + 1 -- 3679
		end -- 3679
	end -- 3679
	self:checkCarryGate() -- 3709
end -- 3634
function Play.prototype.stepVillage(self, dt, input) -- 3713
	if self.room.key ~= "village" then -- 3713
		return -- 3715
	end -- 3715
	local p = self.player -- 3717
	local bottle = self.room.bottle -- 3718
	local scav = self.room.scavenger -- 3719
	if not self.hasBottle and bottle ~= nil then -- 3719
		local dx = p.x - bottle.x -- 3723
		local dy = p.y + p.h * 0.5 - bottle.y -- 3724
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 3724
			self.hasBottle = true -- 3726
			self:flashSet("拾起瓶子", 0.8) -- 3727
		end -- 3727
	end -- 3727
	if self.hasBottle then -- 3727
		if input.aim.held then -- 3727
			self.aimHold = self.aimHold + dt -- 3734
			if self.aimHold > 1.2 then -- 3734
				self.aimHold = 1.2 -- 3736
			end -- 3736
			local cached = self:bottleEnd() -- 3739
			self.bottleAimX = cached.x -- 3740
			self.bottleAimY = cached.y -- 3741
		elseif input.aim.released then -- 3741
			if self.aimHold < 0.12 then -- 3741
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 3745
				self.aimHold = 0 -- 3746
			else -- 3746
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3748
				self:throwBottle(____end.x, ____end.y) -- 3749
				self.aimHold = 0 -- 3750
			end -- 3750
		end -- 3750
	else -- 3750
		self.aimHold = 0 -- 3754
		self.bottleAimX = -1 -- 3755
	end -- 3755
	local fly = self.bottleFly -- 3760
	if fly ~= nil then -- 3760
		fly.t = fly.t + dt -- 3762
		fly.x = fly.x0 + fly.vx * fly.t -- 3763
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 3764
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 3765
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 3765
			self:landBottle(fly) -- 3767
		end -- 3767
	end -- 3767
	if self.bottleLandT > 0 then -- 3767
		self.bottleLandT = self.bottleLandT - dt -- 3771
	end -- 3771
	if scav ~= nil then -- 3771
		self:stepScav(dt, scav) -- 3775
	end -- 3775
	local line = self.room.passLine -- 3778
	if line ~= nil and not self.passed and p.x >= line then -- 3778
		self.passed = true -- 3780
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 3781
	end -- 3781
	if self.passed and p.x >= self.ox + 640 then -- 3781
		self:requestRoom("forest", "过第一院出院") -- 3785
		self:flashSet("出院 · 北塔森林", 1.4) -- 3786
	end -- 3786
end -- 3713
function Play.prototype.bottleEnd(self) -- 3791
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3792
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 3795
	return {x = aim.x, y = g} -- 3796
end -- 3791
function Play.prototype.throwBottle(self, tx, ty) -- 3800
	local p = self.player -- 3801
	local dir = tx >= p.x and 1 or -1 -- 3803
	p.facing = dir -- 3804
	local x0 = p.x + dir * 10 -- 3805
	local y0 = p.y + p.h * 0.7 -- 3806
	self.bottleTargetX = tx -- 3807
	self.bottleTargetY = ty -- 3808
	self.bottleSurfaceY = ty -- 3809
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 3810
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 3811
	self.bottleFly = { -- 3812
		x = x0, -- 3812
		y = y0, -- 3812
		x0 = x0, -- 3812
		y0 = y0, -- 3812
		vx = vx, -- 3812
		vy = vy, -- 3812
		t = 0 -- 3812
	} -- 3812
	self.hasBottle = false -- 3813
	self:flashSet("投出", 0.4) -- 3814
	self:emit( -- 3815
		"bottleThrown", -- 3815
		{ -- 3815
			fromX = x0, -- 3816
			fromY = y0, -- 3817
			targetX = tx, -- 3818
			targetY = ty, -- 3819
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 3820
		} -- 3820
	) -- 3820
end -- 3800
function Play.prototype.landBottle(self, fly) -- 3825
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 3826
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 3827
	local s = self.room.scavenger -- 3828
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 3829
	self.bottleFly = nil -- 3830
	self.bottleTargetX = -1 -- 3831
	self.bottleTargetY = 0 -- 3832
	self.bottleSurfaceY = -1 -- 3833
	self.bottleLandX = x -- 3834
	self.bottleLandY = y -- 3835
	self.bottleLandT = 0.9 -- 3836
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 3837
	self:hearBottle(x) -- 3838
end -- 3825
function Play.prototype.hearBottle(self, x) -- 3842
	local s = self.room.scavenger -- 3843
	if s == nil then -- 3843
		return -- 3845
	end -- 3845
	if math.abs(x - self.scavX) > s.range then -- 3845
		self:flashSet("落地 · 他没听见", 0.6) -- 3848
		return -- 3849
	end -- 3849
	self.scavState = "turn" -- 3851
	self.scavT = s.hearTicks -- 3852
	self.scavTargetX = x -- 3853
	self:flashSet("砖地一响 · 他转头", 0.9) -- 3854
end -- 3842
function Play.prototype.stepScav(self, dt, s) -- 3858
	if self.scavState == "chase" then -- 3858
		return -- 3861
	end -- 3861
	if self.scavState == "turn" then -- 3861
		self.scavT = self.scavT - 1 -- 3864
		if self.scavT <= 0 then -- 3864
			self.scavState = "walk" -- 3866
		end -- 3866
		return -- 3868
	end -- 3868
	if self.scavState == "walk" then -- 3868
		local d = self.scavTargetX - self.scavX -- 3871
		if math.abs(d) < 4 then -- 3871
			self.scavState = "stall" -- 3873
			self.scavT = s.stallTicks -- 3874
			return -- 3875
		end -- 3875
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 3877
		return -- 3878
	end -- 3878
	if self.scavState == "stall" then -- 3878
		self.scavT = self.scavT - 1 -- 3881
		if self.scavT <= 0 then -- 3881
			self.scavState = "back" -- 3883
		end -- 3883
		return -- 3885
	end -- 3885
	if self.scavState == "back" then -- 3885
		local home = math.max( -- 3888
			s.x0, -- 3888
			math.min(s.x1, self.scavX) -- 3888
		) -- 3888
		if math.abs(home - self.scavX) < 2 then -- 3888
			self.scavState = "patrol" -- 3890
			return -- 3891
		end -- 3891
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 3893
		return -- 3894
	end -- 3894
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 3896
	if self.scavX >= s.x1 then -- 3896
		self.scavX = s.x1 -- 3898
		self.scavDir = -1 -- 3899
	elseif self.scavX <= s.x0 then -- 3899
		self.scavX = s.x0 -- 3901
		self.scavDir = 1 -- 3902
	end -- 3902
end -- 3858
function Play.prototype.stepCart(self, dt, input) -- 3910
	local p = self.player -- 3911
	local c = self.room.cart -- 3912
	if self.gripping then -- 3912
		if not input.interact.held then -- 3912
			self.gripping = false -- 3916
			self:flashSet("松开车把", 0.4) -- 3917
			return -- 3918
		end -- 3918
	else -- 3918
		if not input.interact.pressed then -- 3918
			return -- 3922
		end -- 3922
		if not self:cartHandleInReach(p) then -- 3922
			return -- 3925
		end -- 3925
		local track = c.depth or 0 -- 3927
		if self:limitDepth(p, track) ~= track then -- 3927
			return -- 3929
		end -- 3929
		p.depth = track -- 3931
		p.depthSpeed = 0 -- 3932
		self.gripping = true -- 3933
		self:flashSet("握住车把", 0.4) -- 3934
		return -- 3935
	end -- 3935
	if self.cartDocked then -- 3935
		return -- 3939
	end -- 3939
	local dir = input.moveX -- 3941
	if dir == 0 then -- 3941
		return -- 3943
	end -- 3943
	local lo = math.min(c.startX, c.endX) -- 3945
	local hi = math.max(c.startX, c.endX) -- 3946
	local next = self.cartAxle + dir * CART_SPEED * dt -- 3947
	if next < lo then -- 3947
		next = lo -- 3949
	end -- 3949
	if next > hi then -- 3949
		next = hi -- 3952
	end -- 3952
	local delta = next - self.cartAxle -- 3954
	if delta == 0 then -- 3954
		return -- 3956
	end -- 3956
	self.cartAxle = next -- 3958
	p.x = p.x + delta -- 3959
	p.facing = dir > 0 and 1 or -1 -- 3960
	self:slideX(p, 0) -- 3961
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 3961
		self.gripping = false -- 3963
		self:flashSet("跟不上了，脱手", 0.6) -- 3964
		return -- 3965
	end -- 3965
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 3965
		self.cartDocked = true -- 3968
		self.gripping = false -- 3969
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 3970
		self:flashSet("车轮落窝", 1.2) -- 3971
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 3971
		self:flashSet("车轮回到起点", 0.5) -- 3973
	end -- 3973
end -- 3910
function Play.prototype.requestRoom(self, key, reason) -- 3981
	if self.wantRoom ~= "" then -- 3981
		return -- 3985
	end -- 3985
	self.wantRoom = key -- 3987
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 3988
end -- 3981
function Play.prototype.checkCarryGate(self) -- 3995
	if self.room.key == "checkpoint" then -- 3995
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 3995
			self.carryCartAxle = self.cartAxle -- 3998
			self.carryCartDocked = self.cartDocked -- 3999
			self:requestRoom("gate", "检查站出口") -- 4000
			self:flashSet("出检查站 · 城门", 1.2) -- 4001
		end -- 4001
		return -- 4003
	end -- 4003
	if self.room.key == "outside" then -- 4003
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 4003
			self.carryCartAxle = self.cartAxle -- 4009
			self.carryCartDocked = self.cartDocked -- 4010
			self:requestRoom("village", "墙根走完") -- 4011
			self:flashSet("墙根走完 · 进村口", 1.2) -- 4012
		end -- 4012
	end -- 4012
end -- 3995
function Play.prototype.aimAt(self, wx, wy) -- 4019
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 4020
	self.aimX = s.x -- 4021
	self.aimY = s.y -- 4022
end -- 4019
function Play.prototype.shoot(self, a) -- 4025
	if self.isCampaign and self.reloadT > 0 then -- 4025
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 4027
		return -- 4028
	end -- 4028
	local ox = a.x + a.facing * 8 -- 4030
	local muzzleY = a.y + a.h * 0.72 -- 4031
	local oy = muzzleY + a.depth -- 4032
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4034
	local dx = aim.x - ox -- 4037
	local dy = aim.y - oy -- 4038
	local len = math.sqrt(dx * dx + dy * dy) -- 4039
	if len < 0.001 then -- 4039
		dx = a.facing -- 4041
		dy = 0 -- 4042
	else -- 4042
		dx = dx / len -- 4044
		dy = dy / len -- 4045
	end -- 4045
	if dx ~= 0 then -- 4045
		a.facing = dx > 0 and 1 or -1 -- 4048
	end -- 4048
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 4051
	local hitEnemy = self:raycastEnemies(ray) -- 4052
	local tEnemy = hitEnemy.t -- 4053
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 4054
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 4055
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 4056
	local tWall = solid.t -- 4057
	local rawEffect = self:consumeReloadEffect() -- 4059
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 4060
	local reloadEffect = rawEffect -- 4061
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 4063
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 4064
	self.trace = { -- 4066
		x0 = ox, -- 4066
		y0 = oy, -- 4066
		x1 = ox + dx * t, -- 4066
		y1 = oy + dy * t, -- 4066
		hit = hit -- 4066
	} -- 4066
	self.traceT = 0.12 -- 4067
	self:applyFireDanger(ox) -- 4068
	local killed = false -- 4069
	if hit then -- 4069
		local i = hitEnemy.index -- 4071
		local e = self.enemies[i + 1] -- 4072
		local impactY = oy + dy * tEnemy -- 4073
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 4074
		local shieldTop = e.y + (e.depth or 0) + 64 -- 4075
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 4075
			e.shieldHp = (e.shieldHp or 0) - 1 -- 4077
			e.hitT = 0.3 -- 4078
			self:flashSet( -- 4079
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 4079
				0.8 -- 4079
			) -- 4079
			self:emit("shotResolved", { -- 4080
				hit = true, -- 4081
				enemyIndex = i, -- 4081
				enemyX = e.x, -- 4081
				aimX = aim.x, -- 4081
				aimY = aim.y, -- 4081
				impactX = ox + dx * t, -- 4082
				impactY = oy + dy * t, -- 4082
				shield = true -- 4082
			}) -- 4082
			self:beginReload() -- 4084
			return -- 4085
		end -- 4085
		e.alive = false -- 4087
		e.hitT = 0.4 -- 4088
		killed = true -- 4089
		self:flashSet("命中", 0.6) -- 4090
		self:dropFor(e) -- 4091
		if reloadEffect == "light" and weaponFx == "light" then -- 4091
			self:blindNearby(e, 160, i) -- 4093
		end -- 4093
		if reloadEffect == "push" then -- 4093
			e.x = e.x + a.facing * 46 -- 4096
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4097
		elseif reloadEffect == "echo" then -- 4097
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 4099
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 4100
		elseif reloadEffect == "light" then -- 4100
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 4102
		end -- 4102
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 4102
		self:damageProp(solid.box, 1) -- 4105
	else -- 4105
		self:flashSet("打空", 0.35) -- 4107
	end -- 4107
	if self.isCampaign then -- 4107
		self:beginReload() -- 4110
	end -- 4110
	self:emit("shotResolved", { -- 4112
		hit = hit, -- 4113
		enemyIndex = hit and hitEnemy.index or -1, -- 4114
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 4115
		aimX = aim.x, -- 4116
		aimY = aim.y, -- 4117
		impactX = ox + dx * t, -- 4118
		impactY = oy + dy * t -- 4119
	}) -- 4119
end -- 4025
function Play.prototype.applyFireDanger(self, shotX) -- 4124
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 4124
		return -- 4126
	end -- 4126
	local dangerX = shotX -- 4128
	local best = -1 -- 4129
	local bestD = 1000000000 -- 4130
	local i = 0 -- 4131
	do -- 4131
		i = 0 -- 4132
		while i < #self.enemies do -- 4132
			do -- 4132
				local e = self.enemies[i + 1] -- 4133
				if not e.alive then -- 4133
					goto __continue694 -- 4135
				end -- 4135
				local d = math.abs(e.x - self.partner.x) -- 4137
				if d < bestD then -- 4137
					bestD = d -- 4139
					best = i -- 4140
				end -- 4140
			end -- 4140
			::__continue694:: -- 4140
			i = i + 1 -- 4132
		end -- 4132
	end -- 4132
	if best >= 0 then -- 4132
		dangerX = self.enemies[best + 1].x -- 4144
	end -- 4144
	local exposed = self:childExposed(dangerX) -- 4146
	local before = self.escort.fear -- 4147
	local dangerId = self.nextDangerId -- 4148
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 4149
	self.nextDangerId = self.nextDangerId + 1 -- 4150
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 4151
	if after > before then -- 4151
		self:flashSet( -- 4153
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 4153
			1 -- 4153
		) -- 4153
	elseif not exposed then -- 4153
		self:flashSet("枪声没够到她", 0.5) -- 4155
	end -- 4155
end -- 4124
function Play.prototype.childExposed(self, dangerX) -- 4160
	local c = self.partner -- 4161
	if not c.alive then -- 4161
		return false -- 4163
	end -- 4163
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 4163
		self.boxes, -- 4166
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 4166
	) then -- 4166
		return false -- 4167
	end -- 4167
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 4167
		return false -- 4170
	end -- 4170
	local toDanger = dangerX - c.x -- 4172
	local toPlayer = self.player.x - c.x -- 4173
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 4173
		return false -- 4176
	end -- 4176
	return true -- 4178
end -- 4160
function Play.prototype.raycastEnemies(self, ray) -- 4182
	local best = -1 -- 4183
	local bestI = -1 -- 4184
	do -- 4184
		local i = 0 -- 4185
		while i < #self.enemies do -- 4185
			do -- 4185
				local e = self.enemies[i + 1] -- 4186
				if not e.alive then -- 4186
					goto __continue708 -- 4188
				end -- 4188
				local y = e.y + (e.depth or 0) -- 4190
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 4191
				if t >= 0 and (best < 0 or t < best) then -- 4191
					best = t -- 4193
					bestI = i -- 4194
				end -- 4194
			end -- 4194
			::__continue708:: -- 4194
			i = i + 1 -- 4185
		end -- 4185
	end -- 4185
	return {t = best, index = bestI} -- 4197
end -- 4182
function Play.prototype.raycastWorld(self, ray) -- 4200
	return self:raycastSolid(ray).t -- 4201
end -- 4200
function Play.prototype.raycastSolid(self, ray) -- 4205
	local best = -1 -- 4206
	local bestBox = nil -- 4207
	for ____, box in ipairs(self.boxes) do -- 4208
		do -- 4208
			if box.broken == true or box.hidden == true then -- 4208
				goto __continue713 -- 4210
			end -- 4210
			local t = hitBox(ray, box) -- 4215
			if t > 2 and (best < 0 or t < best) then -- 4215
				best = t -- 4218
				bestBox = box -- 4219
			end -- 4219
		end -- 4219
		::__continue713:: -- 4219
	end -- 4219
	if ray.dy < 0 then -- 4219
		local t = -ray.y / ray.dy -- 4223
		if t >= 0 and (best < 0 or t < best) then -- 4223
			best = t -- 4225
			bestBox = nil -- 4226
		end -- 4226
	end -- 4226
	return {t = best, box = bestBox} -- 4229
end -- 4205
function Play.prototype.dropFor(self, e) -- 4233
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 4233
		return -- 4235
	end -- 4235
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 4235
		return -- 4238
	end -- 4238
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 4240
	local ____self_pickups_57 = self.pickups -- 4240
	____self_pickups_57[#____self_pickups_57 + 1] = { -- 4241
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 4242
		kind = e.drop, -- 4242
		x = e.x, -- 4242
		y = e.y, -- 4242
		depth = e.depth, -- 4243
		label = label .. " ×1" -- 4243
	} -- 4243
	self:log("掉落 " .. label) -- 4245
end -- 4233
function Play.prototype.damageProp(self, b, amount) -- 4249
	if b.breakable == nil or b.broken == true then -- 4249
		return -- 4251
	end -- 4251
	local ____b_breakable_58, ____hp_59 = b.breakable, "hp" -- 4251
	____b_breakable_58[____hp_59] = ____b_breakable_58[____hp_59] - amount -- 4253
	if b.breakable.hp > 0 then -- 4253
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 4255
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 4256
		return -- 4257
	end -- 4257
	b.broken = true -- 4259
	for ____, other in ipairs(self.boxes) do -- 4260
		if other.id ~= nil and other.id == b.id then -- 4260
			other.broken = true -- 4262
		end -- 4262
	end -- 4262
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 4265
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 4266
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 4267
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 4268
end -- 4249
function Play.prototype.slideDepth(self, a, distance) -- 4272
	a.depth = self:limitDepth(a, a.depth + distance) -- 4273
end -- 4272
function Play.prototype.limitDepth(self, a, target) -- 4276
	local road = self.room.depth -- 4277
	if road == nil or target == a.depth then -- 4277
		return a.depth -- 4279
	end -- 4279
	local next = math.max( -- 4281
		road.min, -- 4281
		math.min(road.max, target) -- 4281
	) -- 4281
	local half = a.w / 2 -- 4282
	for ____, b in ipairs(self.boxes) do -- 4283
		do -- 4283
			local footprint = b.depth -- 4284
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4284
				goto __continue731 -- 4289
			end -- 4289
			local front = footprint.min - ACTOR_DEPTH_HALF -- 4291
			local back = footprint.max + ACTOR_DEPTH_HALF -- 4292
			if a.depth <= front and next > front then -- 4292
				next = front -- 4294
			elseif a.depth >= back and next < back then -- 4294
				next = back -- 4296
			end -- 4296
		end -- 4296
		::__continue731:: -- 4296
	end -- 4296
	return next -- 4299
end -- 4276
function Play.prototype.slideX(self, a, dx) -- 4303
	local nx = a.x + dx -- 4304
	local half = a.w / 2 -- 4305
	local room = self.room -- 4306
	nx = math.max( -- 4307
		room.minX + half, -- 4307
		math.min(room.maxX - half, nx) -- 4307
	) -- 4307
	local i = 0 -- 4308
	do -- 4308
		i = 0 -- 4309
		while i < #self.boxes do -- 4309
			do -- 4309
				local b = self.boxes[i + 1] -- 4310
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4310
					goto __continue738 -- 4312
				end -- 4312
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4312
					goto __continue738 -- 4315
				end -- 4315
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4315
					goto __continue738 -- 4318
				end -- 4318
				if nx + half > b.x0 and nx - half < b.x1 then -- 4318
					if a.x <= b.x0 then -- 4318
						nx = b.x0 - half -- 4322
					elseif a.x >= b.x1 then -- 4322
						nx = b.x1 + half -- 4324
					else -- 4324
						nx = a.x -- 4326
					end -- 4326
				end -- 4326
			end -- 4326
			::__continue738:: -- 4326
			i = i + 1 -- 4309
		end -- 4309
	end -- 4309
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 4309
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 4334
		local bx0 = self.cartAxle - CART_HALF -- 4335
		local bx1 = self.cartAxle + CART_HALF -- 4336
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 4336
			if a.x <= bx0 then -- 4336
				nx = bx0 - half -- 4339
			elseif a.x >= bx1 then -- 4339
				nx = bx1 + half -- 4341
			else -- 4341
				nx = a.x -- 4343
			end -- 4343
		end -- 4343
	end -- 4343
	local arch = room.arch -- 4351
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 4351
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 4353
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 4353
			if a.x <= arch.x0 then -- 4353
				nx = arch.x0 - half -- 4356
			elseif a.x >= arch.x1 then -- 4356
				nx = arch.x1 + half -- 4358
			end -- 4358
		end -- 4358
	end -- 4358
	a.x = nx -- 4362
end -- 4303
function Play.prototype.fallY(self, a, dt) -- 4366
	a.vy = a.vy - ____exports.GRAVITY * dt -- 4367
	if a.vy < -900 then -- 4367
		a.vy = -900 -- 4369
	end -- 4369
	local ny = a.y + a.vy * dt -- 4371
	local half = a.w / 2 -- 4372
	if a.vy <= 0 then -- 4372
		local reach = a.onGround and STEP_UP or 0 -- 4375
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 4376
		if ny <= ground then -- 4376
			ny = ground -- 4378
			a.vy = 0 -- 4379
			a.onGround = true -- 4380
		else -- 4380
			a.onGround = false -- 4382
		end -- 4382
	else -- 4382
		a.onGround = false -- 4385
		local i = 0 -- 4386
		do -- 4386
			i = 0 -- 4387
			while i < #self.boxes do -- 4387
				do -- 4387
					local b = self.boxes[i + 1] -- 4388
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4388
						goto __continue762 -- 4390
					end -- 4390
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4390
						goto __continue762 -- 4393
					end -- 4393
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 4393
						goto __continue762 -- 4396
					end -- 4396
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 4396
						ny = b.y0 - a.h -- 4399
						a.vy = 0 -- 4400
					end -- 4400
				end -- 4400
				::__continue762:: -- 4400
				i = i + 1 -- 4387
			end -- 4387
		end -- 4387
	end -- 4387
	a.y = ny -- 4404
end -- 4366
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 4408
	if depth == nil then -- 4408
		depth = 0 -- 4408
	end -- 4408
	local g = -9999 -- 4409
	local i = 0 -- 4410
	do -- 4410
		i = 0 -- 4411
		while i < #self.floors do -- 4411
			local f = self.floors[i + 1] -- 4412
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 4412
				g = f.y1 -- 4414
			end -- 4414
			i = i + 1 -- 4411
		end -- 4411
	end -- 4411
	do -- 4411
		i = 0 -- 4417
		while i < #self.boxes do -- 4417
			do -- 4417
				local b = self.boxes[i + 1] -- 4418
				if b.broken == true or b.hidden == true or b.soft == true then -- 4418
					goto __continue772 -- 4420
				end -- 4420
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 4420
					g = b.y1 -- 4424
				end -- 4424
			end -- 4424
			::__continue772:: -- 4424
			i = i + 1 -- 4417
		end -- 4417
	end -- 4417
	return g -- 4427
end -- 4408
function Play.prototype.updateCamera(self, dt) -- 4430
	local p = self.player -- 4431
	local tx = p.x + p.facing * 30 -- 4432
	local ty = p.y + CAM_LOOK_UP -- 4433
	local k = math.min(1, CAM_FOLLOW * dt) -- 4434
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 4435
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 4436
end -- 4430
function Play.prototype.clampCamera(self, w, h) -- 4440
	local room = self.room -- 4441
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 4442
	local spanX = room.maxX - room.minX -- 4443
	if spanX <= halfW * 2 then -- 4443
		self.cam.x = (room.minX + room.maxX) / 2 -- 4445
	else -- 4445
		self.cam.x = math.max( -- 4447
			room.minX + halfW, -- 4447
			math.min(room.maxX - halfW, self.cam.x) -- 4447
		) -- 4447
	end -- 4447
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 4450
	local spanY = room.height -- 4451
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 4452
	if spanY <= halfH * 2 then -- 4452
		self.cam.y = camY -- 4454
	else -- 4454
		self.cam.y = math.max( -- 4456
			camY, -- 4456
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 4456
		) -- 4456
	end -- 4456
end -- 4440
function Play.prototype.flashSet(self, text, t) -- 4460
	self.flash = text -- 4461
	self.flashT = t -- 4462
end -- 4460
function Play.prototype.statusText(self) -- 4466
	local p = self.player -- 4467
	local parts = {} -- 4468
	local who = self.childMode and "小满" or "周戍" -- 4469
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 4470
	if self.room.key == "prologue" then -- 4470
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4473
		if self.phase == "prologue-wait" then -- 4473
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 4475
		elseif self.phase == "prologue-give" then -- 4475
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 4477
		else -- 4477
			parts[#parts + 1] = "跟随" -- 4479
		end -- 4479
		if self.paused then -- 4479
			parts[#parts + 1] = "已暂停" -- 4482
		end -- 4482
		return table.concat(parts, " · ") -- 4484
	end -- 4484
	if self.room.key == "street" then -- 4484
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4487
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4488
		if self.paused then -- 4488
			parts[#parts + 1] = "已暂停" -- 4490
		end -- 4490
		return table.concat(parts, " · ") -- 4492
	end -- 4492
	if self.room.key == "gate" then -- 4492
		local ____temp_60 -- 4495
		if self.room.story == nil then -- 4495
			____temp_60 = nil -- 4495
		else -- 4495
			____temp_60 = self.room.story.gate -- 4495
		end -- 4495
		local g = ____temp_60 -- 4495
		if g ~= nil then -- 4495
			parts[#parts + 1] = self:gateLabel() -- 4497
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 4498
				0, -- 4499
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 4499
			))) .. " 秒" -- 4499
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4500
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4501
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 4502
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 4503
			if self.gateFailCount > 0 then -- 4503
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 4505
			end -- 4505
			if self.flash ~= "" then -- 4505
				parts[#parts + 1] = self.flash -- 4508
			end -- 4508
		end -- 4508
		if self.paused then -- 4508
			parts[#parts + 1] = "已暂停" -- 4512
		end -- 4512
		return table.concat(parts, " · ") -- 4514
	end -- 4514
	if self.room.key == "forest" then -- 4514
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4517
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 4518
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 4519
		if self.caughtT > 0 then -- 4519
			parts[#parts + 1] = "复位中" -- 4521
		end -- 4521
		if self.paused then -- 4521
			parts[#parts + 1] = "已暂停" -- 4524
		end -- 4524
		return table.concat(parts, " · ") -- 4526
	end -- 4526
	if self.room.key == "tower" then -- 4526
		if self.phase == "tower-wait" then -- 4526
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 4530
		elseif self.phase == "tower-knock" then -- 4530
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 4532
		elseif self.phase == "tower-given" then -- 4532
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 4534
		else -- 4534
			parts[#parts + 1] = "片尾" -- 4536
		end -- 4536
		if self.paused then -- 4536
			parts[#parts + 1] = "已暂停" -- 4539
		end -- 4539
		return table.concat(parts, " · ") -- 4541
	end -- 4541
	if self.room.key == "village" then -- 4541
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4544
		if self.hasBottle then -- 4544
			parts[#parts + 1] = "有瓶" -- 4546
		elseif self.bottleFly ~= nil then -- 4546
			parts[#parts + 1] = "瓶在飞" -- 4548
		else -- 4548
			parts[#parts + 1] = "空手" -- 4550
		end -- 4550
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 4552
		if self.scavChase then -- 4552
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 4554
		end -- 4554
		if self.passed then -- 4554
			parts[#parts + 1] = "已过通行线" -- 4557
		end -- 4557
		if self.paused then -- 4557
			parts[#parts + 1] = "已暂停" -- 4560
		end -- 4560
		return table.concat(parts, " · ") -- 4562
	end -- 4562
	local isChild = self.childMode -- 4565
	if isChild then -- 4565
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4567
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 4568
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4569
	else -- 4569
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 4571
		if p.rollT > 0 then -- 4571
			parts[#parts + 1] = "翻滚中" -- 4573
		end -- 4573
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4575
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4576
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 4577
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 4578
	end -- 4578
	if self.checkpoint >= 0 then -- 4578
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 4581
	end -- 4581
	if self.paused then -- 4581
		parts[#parts + 1] = "已暂停" -- 4584
	end -- 4584
	return table.concat(parts, " · ") -- 4586
end -- 4466
function Play.prototype.aliveEnemies(self) -- 4590
	local n = 0 -- 4591
	local i = 0 -- 4592
	do -- 4592
		i = 0 -- 4593
		while i < #self.enemies do -- 4593
			if self.enemies[i + 1].alive then -- 4593
				n = n + 1 -- 4595
			end -- 4595
			i = i + 1 -- 4593
		end -- 4593
	end -- 4593
	return n -- 4598
end -- 4590
function Play.prototype.threatened(self) -- 4603
	do -- 4603
		local i = 0 -- 4604
		while i < #self.enemies do -- 4604
			local e = self.enemies[i + 1] -- 4605
			if e.alive and e.warnT > 0 then -- 4605
				return true -- 4607
			end -- 4607
			i = i + 1 -- 4604
		end -- 4604
	end -- 4604
	return false -- 4610
end -- 4603
function Play.prototype.gateSecondsLeft(self) -- 4613
	local ____temp_61 -- 4614
	if self.room.story == nil then -- 4614
		____temp_61 = nil -- 4614
	else -- 4614
		____temp_61 = self.room.story.gate -- 4614
	end -- 4614
	local g = ____temp_61 -- 4614
	if g == nil then -- 4614
		return 0 -- 4616
	end -- 4616
	return math.max( -- 4618
		0, -- 4618
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 4618
	) -- 4618
end -- 4613
function Play.prototype.gateLabel(self) -- 4621
	if self.phase == "gate-idle" then -- 4621
		return "待就位" -- 4623
	end -- 4623
	if self.phase == "gate-hold" then -- 4623
		return "守点中" -- 4626
	end -- 4626
	if self.phase == "gate-send" then -- 4626
		return "送别" -- 4629
	end -- 4629
	if self.phase == "gate-count" then -- 4629
		return "数数 " .. tostring(self.countTick) -- 4632
	end -- 4632
	return "她走" -- 4634
end -- 4621
function Play.prototype.dogLabel(self) -- 4638
	if self.dogState == "ear" then -- 4638
		return "转耳" -- 4640
	end -- 4640
	if self.dogState == "chase" then -- 4640
		return "追" -- 4643
	end -- 4643
	if self.dogState == "sniff" then -- 4643
		return "停" -- 4646
	end -- 4646
	if self.dogState == "back" then -- 4646
		return "回线" -- 4649
	end -- 4649
	return "巡逻" -- 4651
end -- 4638
function Play.prototype.doorXOf(self) -- 4654
	local ____temp_62 -- 4655
	if self.room.story == nil then -- 4655
		____temp_62 = nil -- 4655
	else -- 4655
		____temp_62 = self.room.story.tower -- 4655
	end -- 4655
	local t = ____temp_62 -- 4655
	return t == nil and 0 or t.doorX -- 4656
end -- 4654
function Play.prototype.scavLabel(self) -- 4660
	if self.scavState == "chase" then -- 4660
		return "追" -- 4662
	end -- 4662
	if self.scavState == "turn" then -- 4662
		return "转头" -- 4665
	end -- 4665
	if self.scavState == "walk" then -- 4665
		return "赶来" -- 4668
	end -- 4668
	if self.scavState == "stall" then -- 4668
		return "停住" -- 4671
	end -- 4671
	if self.scavState == "back" then -- 4671
		return "回位" -- 4674
	end -- 4674
	return "巡逻" -- 4676
end -- 4660
function Play.prototype.hintText(self) -- 4680
	if self.paused then -- 4680
		return "Esc 继续 · R 重置" -- 4682
	end -- 4682
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 4682
		if self:threatened() then -- 4682
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 4688
		end -- 4688
		if self.coverHug then -- 4688
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 4691
		end -- 4691
		if self.coverNear then -- 4691
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 4694
		end -- 4694
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 4696
	end -- 4696
	if self.flash ~= "" then -- 4696
		return self.flash -- 4699
	end -- 4699
	if self.room.key == "prologue" then -- 4699
		if self.phase == "prologue-wait" then -- 4699
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 4703
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 4704
		end -- 4704
		if self.phase == "prologue-give" then -- 4704
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 4707
		end -- 4707
		return "她跟着你了 · 两人一起走到门口 680" -- 4709
	end -- 4709
	if self.room.key == "street" then -- 4709
		if self:aliveEnemies() > 0 then -- 4709
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 4713
		end -- 4713
		return "清完了 · 两人一起走到右边检查站入口 900" -- 4715
	end -- 4715
	if self.room.key == "gate" then -- 4715
		local ____temp_63 -- 4718
		if self.room.story == nil then -- 4718
			____temp_63 = nil -- 4718
		else -- 4718
			____temp_63 = self.room.story.gate -- 4718
		end -- 4718
		local g = ____temp_63 -- 4718
		if g ~= nil then -- 4718
			if self.phase == "gate-idle" then -- 4718
				if self.gateNeedConfirm then -- 4718
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 4722
				end -- 4722
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 4724
			end -- 4724
			if self.phase == "gate-hold" then -- 4724
				if self.coveredFlash > 0 then -- 4724
					return "掩体挡下了这一枪 · 别露头" -- 4728
				end -- 4728
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 4730
			end -- 4730
			if self.phase == "gate-send" then -- 4730
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 4733
			end -- 4733
			if self.phase == "gate-count" then -- 4733
				if self.countTick >= ____exports.GATE_COUNT_END then -- 4733
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 4737
				end -- 4737
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 4739
			end -- 4739
			return "她自己走 · 跟着出城门 1120" -- 4741
		end -- 4741
	end -- 4741
	if self.room.key == "forest" then -- 4741
		if self.dogState == "chase" then -- 4741
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 4746
		end -- 4746
		if self.dogState == "ear" then -- 4746
			return "狗转耳朵了 · 停下或蹲下别出声" -- 4749
		end -- 4749
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 4751
	end -- 4751
	if self.room.key == "tower" then -- 4751
		if self.phase == "tower-wait" then -- 4751
			return "走到门前 445 点一次 E 敲两下" -- 4755
		end -- 4755
		if self.phase == "tower-knock" then -- 4755
			return "敲两下 · 等门开" -- 4758
		end -- 4758
		if self.phase == "tower-given" then -- 4758
			return "递交针套和纸条 · 看登记簿最后一行" -- 4761
		end -- 4761
		return "片尾 · 点 E 再玩一次，回到序章" -- 4763
	end -- 4763
	if self.room.key == "village" then -- 4763
		if self.bottleFly ~= nil then -- 4763
			return "等瓶子落地 · 触地才发声" -- 4767
		end -- 4767
		if self.hasBottle then -- 4767
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 4770
		end -- 4770
		if self.passed then -- 4770
			return "已过第一院 · R 重置可再来一遍" -- 4773
		end -- 4773
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 4775
	end -- 4775
	if self.room.key == "outside" then -- 4775
		if self.focusCart then -- 4775
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 4779
		end -- 4779
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 4781
	end -- 4781
	if self.escort.state == "frozen" then -- 4781
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 4781
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 4785
		end -- 4785
		return "小满吓住了 · 走过去，靠近再点 E" -- 4787
	end -- 4787
	if self.escort.state == "calming" then -- 4787
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 4790
	end -- 4790
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 4792
end -- 4680
function Play.prototype.draw(self, draw, w, h) -- 4797
	self.viewW = w -- 4798
	self.viewH = h -- 4799
	self.view = ____exports.computeViewport(w, h) -- 4800
	self:clampCamera(w, h) -- 4801
	draw:clear() -- 4802
	draw:drawRect( -- 4804
		Rect(0, 0, w, h), -- 4804
		BG_VOID -- 4804
	) -- 4804
	local box = self:canvasRect(w, h) -- 4805
	draw:drawRect(box, BG_FAR) -- 4806
	draw:drawRect( -- 4807
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 4807
		BG_MID -- 4807
	) -- 4807
	self:drawFloors(draw, w, h) -- 4809
	self:drawSolids(draw, w, h) -- 4810
	self:drawZones(draw, w, h) -- 4811
	self:drawArch(draw, w, h) -- 4812
	self:drawCart(draw, w, h) -- 4813
	self:drawCampaignProps(draw, w, h) -- 4814
	self:drawActors(draw, w, h) -- 4815
	self:drawTrace(draw, w, h) -- 4816
	self:drawAim(draw, w, h) -- 4817
end -- 4797
function Play.prototype.canvasRect(self, w, h) -- 4821
	local v = self.view -- 4822
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 4823
end -- 4821
function Play.prototype.px(self, n) -- 4827
	return n * self.view.zoom -- 4828
end -- 4827
function Play.prototype.sx(self, wx, w) -- 4832
	local v = self.view -- 4833
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 4834
	return v.ox + lx * v.zoom -- 4835
end -- 4832
function Play.prototype.sy(self, wy, h) -- 4839
	local v = self.view -- 4840
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 4841
	return v.oy + ly * v.zoom -- 4842
end -- 4839
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 4845
	local px0 = self:sx(x0, w) -- 4846
	local px1 = self:sx(x1, w) -- 4847
	local py0 = self:sy(y0, h) -- 4848
	local py1 = self:sy(y1, h) -- 4849
	if px1 <= px0 or py1 <= py0 then -- 4849
		return -- 4851
	end -- 4851
	draw:drawRect( -- 4853
		Rect(px0, py0, px1 - px0, py1 - py0), -- 4853
		color -- 4853
	) -- 4853
end -- 4845
function Play.prototype.drawFloors(self, draw, w, h) -- 4856
	local i = 0 -- 4857
	do -- 4857
		i = 0 -- 4858
		while i < #self.room.floors do -- 4858
			local f = self.room.floors[i + 1] -- 4859
			local ____temp_64 -- 4860
			if f.y == 0 then -- 4860
				____temp_64 = self.room.depth -- 4860
			else -- 4860
				____temp_64 = nil -- 4860
			end -- 4860
			local road = ____temp_64 -- 4860
			local y = self:sy(f.y + (road and road.min or 0), h) -- 4861
			local x0 = self:sx(f.x0, w) -- 4862
			local x1 = self:sx(f.x1, w) -- 4863
			local deck = self:px(5) -- 4864
			if road ~= nil then -- 4864
				local back = self:sy(f.y + road.max, h) -- 4866
				draw:drawRect( -- 4867
					Rect(x0, y, x1 - x0, back - y), -- 4867
					FLOOR_DECK, -- 4867
					self:px(1), -- 4867
					SOLID_EDGE -- 4867
				) -- 4867
			end -- 4867
			draw:drawRect( -- 4869
				Rect(x0, y - deck, x1 - x0, deck), -- 4869
				FLOOR_DECK -- 4869
			) -- 4869
			draw:drawSegment( -- 4870
				Vec2(x0, y), -- 4870
				Vec2(x1, y), -- 4870
				self:px(1), -- 4870
				GROUND -- 4870
			) -- 4870
			i = i + 1 -- 4858
		end -- 4858
	end -- 4858
end -- 4856
function Play.prototype.drawSolids(self, draw, w, h) -- 4874
	local i = 0 -- 4875
	do -- 4875
		i = 0 -- 4876
		while i < #self.boxes do -- 4876
			do -- 4876
				local b = self.boxes[i + 1] -- 4877
				if b.id == "braced_shield" or b.hidden == true then -- 4877
					goto __continue893 -- 4879
				end -- 4879
				if b.broken == true then -- 4879
					if b.breakable ~= nil then -- 4879
						local gy = self:sy(b.y0, h) -- 4884
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 4885
						local k = 0 -- 4886
						do -- 4886
							k = 0 -- 4887
							while k < 3 do -- 4887
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 4888
								draw:drawSegment( -- 4889
									Vec2( -- 4889
										gx - self:px(4), -- 4889
										gy + self:px(k % 2) -- 4889
									), -- 4889
									Vec2( -- 4889
										gx + self:px(5), -- 4889
										gy + self:px(k % 2) -- 4889
									), -- 4889
									self:px(1), -- 4889
									rgb -- 4889
								) -- 4889
								k = k + 1 -- 4887
							end -- 4887
						end -- 4887
					end -- 4887
					goto __continue893 -- 4892
				end -- 4892
				local ____opt_67 = b.depth -- 4892
				local front = ____opt_67 and ____opt_67.min or 0 -- 4894
				local ____opt_69 = b.depth -- 4894
				local back = ____opt_69 and ____opt_69.max or 0 -- 4895
				local fill = SOLID_FILL -- 4896
				local line = SOLID_EDGE -- 4897
				if b.soft == true then -- 4897
					fill = SOFT -- 4899
					line = SOFT_LINE -- 4900
				elseif b.breakable ~= nil then -- 4900
					line = DANGER_LINE -- 4902
					fill = Color(0.3, 0.24, 0.16, 1) -- 4903
				elseif b.interact ~= nil then -- 4903
					line = PASS_LINE -- 4905
				end -- 4905
				self:drawBox( -- 4907
					draw, -- 4907
					w, -- 4907
					h, -- 4907
					b.x0, -- 4907
					b.x1, -- 4907
					b.y0 + front, -- 4907
					b.y1 + back, -- 4907
					fill -- 4907
				) -- 4907
				draw:drawSegment( -- 4908
					Vec2( -- 4908
						self:sx(b.x0, w), -- 4908
						self:sy(b.y1 + front, h) -- 4908
					), -- 4908
					Vec2( -- 4909
						self:sx(b.x1, w), -- 4909
						self:sy(b.y1 + front, h) -- 4909
					), -- 4909
					self:px(1), -- 4909
					line -- 4909
				) -- 4909
				if b.breakable ~= nil then -- 4909
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 4912
					local cyp = self:sy(b.y1 + front, h) -- 4913
					draw:drawSegment( -- 4914
						Vec2( -- 4914
							cxp - self:px(4), -- 4914
							cyp + self:px(1) -- 4914
						), -- 4914
						Vec2( -- 4914
							cxp + self:px(3), -- 4914
							cyp + self:px(5) -- 4914
						), -- 4914
						self:px(1), -- 4914
						line -- 4914
					) -- 4914
				end -- 4914
			end -- 4914
			::__continue893:: -- 4914
			i = i + 1 -- 4876
		end -- 4876
	end -- 4876
end -- 4874
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 4920
	local i = 0 -- 4921
	do -- 4921
		i = 0 -- 4922
		while i < #self.pickups do -- 4922
			do -- 4922
				local pk = self.pickups[i + 1] -- 4923
				if pk.id == "" then -- 4923
					goto __continue905 -- 4925
				end -- 4925
				local gy = pk.y + (pk.depth or 0) -- 4927
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 4928
				draw:drawRect( -- 4929
					Rect( -- 4929
						self:sx(pk.x - 5, w), -- 4929
						self:sy(gy + 12 + bob, h), -- 4929
						self:px(10), -- 4929
						self:px(10) -- 4929
					), -- 4929
					Color(0.84, 0.7, 0.3, 1) -- 4930
				) -- 4930
				draw:drawSegment( -- 4931
					Vec2( -- 4931
						self:sx(pk.x - 5, w), -- 4931
						self:sy(gy + 12 + bob, h) -- 4931
					), -- 4931
					Vec2( -- 4932
						self:sx(pk.x + 5, w), -- 4932
						self:sy(gy + 12 + bob, h) -- 4932
					), -- 4932
					self:px(1), -- 4932
					Color(0.95, 0.86, 0.52, 1) -- 4932
				) -- 4932
			end -- 4932
			::__continue905:: -- 4932
			i = i + 1 -- 4922
		end -- 4922
	end -- 4922
	if self.bracedShield ~= nil then -- 4922
		local sh = self.bracedShield -- 4935
		draw:drawRect( -- 4936
			Rect( -- 4936
				self:sx(sh.x - sh.w / 2, w), -- 4936
				self:sy(sh.y, h), -- 4936
				self:px(sh.w), -- 4936
				self:px(sh.h) -- 4936
			), -- 4936
			Color(0.42, 0.4, 0.34, 1) -- 4937
		) -- 4937
		draw:drawSegment( -- 4938
			Vec2( -- 4938
				self:sx(sh.x - sh.w / 2, w), -- 4938
				self:sy(sh.y + sh.h, h) -- 4938
			), -- 4938
			Vec2( -- 4939
				self:sx(sh.x + sh.w / 2, w), -- 4939
				self:sy(sh.y + sh.h, h) -- 4939
			), -- 4939
			self:px(1), -- 4939
			Color(0.74, 0.72, 0.62, 1) -- 4939
		) -- 4939
	end -- 4939
end -- 4920
function Play.prototype.drawZones(self, draw, w, h) -- 4943
	local i = 0 -- 4944
	do -- 4944
		i = 0 -- 4945
		while i < #self.room.zones do -- 4945
			local z = self.room.zones[i + 1] -- 4946
			local fill = DANGER -- 4947
			local line = DANGER_LINE -- 4948
			if z.tint == 2 then -- 4948
				fill = SOFT -- 4950
				line = SOFT_LINE -- 4951
			elseif z.tint == 3 then -- 4951
				fill = BRICK -- 4953
				line = BRICK_LINE -- 4954
			elseif z.tint == 4 then -- 4954
				fill = PASS -- 4956
				line = PASS_LINE -- 4957
			end -- 4957
			self:drawBox( -- 4959
				draw, -- 4959
				w, -- 4959
				h, -- 4959
				z.x0, -- 4959
				z.x1, -- 4959
				z.y, -- 4959
				z.y + z.h, -- 4959
				fill -- 4959
			) -- 4959
			draw:drawSegment( -- 4960
				Vec2( -- 4960
					self:sx(z.x0, w), -- 4960
					self:sy(z.y, h) -- 4960
				), -- 4960
				Vec2( -- 4960
					self:sx(z.x0, w), -- 4960
					self:sy(z.y + z.h, h) -- 4960
				), -- 4960
				self:px(1), -- 4960
				line -- 4960
			) -- 4960
			draw:drawSegment( -- 4961
				Vec2( -- 4961
					self:sx(z.x1, w), -- 4961
					self:sy(z.y, h) -- 4961
				), -- 4961
				Vec2( -- 4961
					self:sx(z.x1, w), -- 4961
					self:sy(z.y + z.h, h) -- 4961
				), -- 4961
				self:px(1), -- 4961
				line -- 4961
			) -- 4961
			i = i + 1 -- 4945
		end -- 4945
	end -- 4945
end -- 4943
function Play.prototype.drawArch(self, draw, w, h) -- 4965
	local a = self.room.arch -- 4966
	if a.h <= 0 then -- 4966
		return -- 4968
	end -- 4968
	self:drawBox( -- 4970
		draw, -- 4970
		w, -- 4970
		h, -- 4970
		a.x0, -- 4970
		a.x1, -- 4970
		a.y, -- 4970
		a.y + a.h, -- 4970
		HOLE_FILL -- 4970
	) -- 4970
	draw:drawSegment( -- 4971
		Vec2( -- 4971
			self:sx(a.x0, w), -- 4971
			self:sy(a.y + a.h, h) -- 4971
		), -- 4971
		Vec2( -- 4971
			self:sx(a.x1, w), -- 4971
			self:sy(a.y + a.h, h) -- 4971
		), -- 4971
		self:px(1), -- 4971
		SOLID_EDGE -- 4971
	) -- 4971
	draw:drawSegment( -- 4972
		Vec2( -- 4972
			self:sx(a.x0, w), -- 4972
			self:sy(a.y, h) -- 4972
		), -- 4972
		Vec2( -- 4972
			self:sx(a.x0, w), -- 4972
			self:sy(a.y + a.h, h) -- 4972
		), -- 4972
		self:px(1), -- 4972
		SOLID_EDGE -- 4972
	) -- 4972
	draw:drawSegment( -- 4973
		Vec2( -- 4973
			self:sx(a.x1, w), -- 4973
			self:sy(a.y, h) -- 4973
		), -- 4973
		Vec2( -- 4973
			self:sx(a.x1, w), -- 4973
			self:sy(a.y + a.h, h) -- 4973
		), -- 4973
		self:px(1), -- 4973
		SOLID_EDGE -- 4973
	) -- 4973
end -- 4965
function Play.prototype.drawCart(self, draw, w, h) -- 4976
	local c = self.room.cart -- 4977
	if c.bodyW <= 0 then -- 4977
		return -- 4979
	end -- 4979
	drawCartShape( -- 4981
		draw, -- 4981
		self, -- 4981
		w, -- 4981
		h, -- 4981
		c, -- 4981
		self.cartAxle -- 4981
	) -- 4981
	draw:drawRect( -- 4982
		Rect( -- 4982
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 4982
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 4982
			self:px(2), -- 4982
			self:px(40) -- 4982
		), -- 4982
		STAND -- 4982
	) -- 4982
end -- 4976
function Play.prototype.drawActors(self, draw, w, h) -- 4985
	local p = self.player -- 4986
	local isChild = self.childMode -- 4987
	local footY = p.y + p.depth -- 4988
	if p.covered then -- 4988
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 4991
		draw:drawSegment( -- 4992
			Vec2( -- 4992
				self:sx(edge, w), -- 4992
				self:sy(footY + 8, h) -- 4992
			), -- 4992
			Vec2( -- 4992
				self:sx(edge, w), -- 4992
				self:sy(footY + p.h * 0.62, h) -- 4992
			), -- 4992
			self:px(2), -- 4992
			STAND -- 4992
		) -- 4992
		draw:drawSegment( -- 4994
			Vec2( -- 4994
				self:sx(p.x - 8, w), -- 4994
				self:sy(footY + p.h + 3, h) -- 4994
			), -- 4994
			Vec2( -- 4994
				self:sx(p.x + 8, w), -- 4994
				self:sy(footY + p.h + 3, h) -- 4994
			), -- 4994
			self:px(2), -- 4994
			STAND -- 4994
		) -- 4994
	elseif self.coverNear and not isChild then -- 4994
		draw:drawRect( -- 4997
			Rect( -- 4997
				self:sx(p.x - 3, w), -- 4997
				self:sy(footY + 1, h), -- 4997
				self:px(3), -- 4997
				self:px(3) -- 4997
			), -- 4997
			STAND -- 4997
		) -- 4997
	end -- 4997
	drawFigure( -- 4999
		draw, -- 4999
		self, -- 4999
		w, -- 4999
		h, -- 4999
		p, -- 4999
		isChild and CHILD_BODY or SOLDIER_BODY, -- 4999
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 4999
	) -- 4999
	local q = self.partner -- 5000
	if q.alive then -- 5000
		local childPartner = q.w == CHILD_W -- 5002
		drawFigure( -- 5003
			draw, -- 5003
			self, -- 5003
			w, -- 5003
			h, -- 5003
			q, -- 5003
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 5003
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 5003
		) -- 5003
	end -- 5003
	local i = 0 -- 5005
	do -- 5005
		i = 0 -- 5006
		while i < #self.enemies do -- 5006
			local e = self.enemies[i + 1] -- 5007
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 5008
			local enemyY = e.y + (e.depth or 0) -- 5009
			self:drawBox( -- 5010
				draw, -- 5010
				w, -- 5010
				h, -- 5010
				e.x - e.w / 2, -- 5010
				e.x + e.w / 2, -- 5010
				enemyY, -- 5010
				enemyY + e.h, -- 5010
				col -- 5010
			) -- 5010
			if e.alive then -- 5010
				local ef = p.x >= e.x and 1 or -1 -- 5012
				if e.kind == "shield" then -- 5012
					local sh = (e.shieldHp or 0) > 0 -- 5014
					draw:drawRect( -- 5015
						Rect( -- 5015
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 5015
							self:sy(enemyY, h), -- 5015
							self:px(6), -- 5015
							self:px(64) -- 5015
						), -- 5015
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 5016
					) -- 5016
				elseif e.kind == "breaker" then -- 5016
					draw:drawSegment( -- 5018
						Vec2( -- 5018
							self:sx(e.x + ef * 12, w), -- 5018
							self:sy(enemyY + 8, h) -- 5018
						), -- 5018
						Vec2( -- 5019
							self:sx(e.x + ef * 22, w), -- 5019
							self:sy(enemyY + 46, h) -- 5019
						), -- 5019
						self:px(3), -- 5019
						Color(0.5, 0.36, 0.22, 1) -- 5019
					) -- 5019
				end -- 5019
			end -- 5019
			if e.alive and e.warnT > 0 then -- 5019
				local gunX = self:sx(e.x, w) -- 5024
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 5025
				local aimX = self:sx(p.x, w) -- 5026
				local aimY = self:sy(footY + p.h * 0.55, h) -- 5027
				local seg = 8 -- 5028
				local s = 0 -- 5029
				do -- 5029
					s = 0 -- 5030
					while s < seg do -- 5030
						local t0 = s / seg -- 5031
						local t1 = (s + 1) / seg -- 5032
						draw:drawSegment( -- 5033
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 5034
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 5035
							self:px(1), -- 5036
							DANGER -- 5036
						) -- 5036
						s = s + 2 -- 5030
					end -- 5030
				end -- 5030
			end -- 5030
			i = i + 1 -- 5006
		end -- 5006
	end -- 5006
	local k = 0 -- 5041
	do -- 5041
		k = 0 -- 5042
		while k < #self.room.marks do -- 5042
			do -- 5042
				local m = self.room.marks[k + 1] -- 5043
				if m.kind ~= 0 then -- 5043
					goto __continue931 -- 5045
				end -- 5045
				local on = self.checkpoint == m.x -- 5047
				local x = self:sx(m.x, w) -- 5048
				local y = self:sy(m.y, h) -- 5049
				draw:drawSegment( -- 5050
					Vec2(x, y), -- 5050
					Vec2( -- 5050
						x, -- 5050
						y + self:px(35) -- 5050
					), -- 5050
					self:px(1), -- 5050
					on and CHECK or INK_DIM -- 5050
				) -- 5050
				draw:drawDot( -- 5051
					Vec2( -- 5051
						x, -- 5051
						y + self:px(35) -- 5051
					), -- 5051
					self:px(2), -- 5051
					on and CHECK or INK_DIM -- 5051
				) -- 5051
			end -- 5051
			::__continue931:: -- 5051
			k = k + 1 -- 5042
		end -- 5042
	end -- 5042
	local j = 0 -- 5055
	do -- 5055
		j = 0 -- 5056
		while j < #self.room.marks do -- 5056
			do -- 5056
				local m = self.room.marks[j + 1] -- 5057
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 5057
					goto __continue934 -- 5059
				end -- 5059
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 5059
					goto __continue934 -- 5063
				end -- 5063
				local col = STAND -- 5065
				if m.kind == 4 then -- 5065
					col = PASS_LINE -- 5067
				elseif m.kind == 5 then -- 5067
					col = BRICK_LINE -- 5069
				end -- 5069
				local mx = self:sx(m.x, w) -- 5071
				local my = self:sy(m.y, h) -- 5072
				draw:drawSegment( -- 5073
					Vec2(mx, my), -- 5073
					Vec2( -- 5073
						mx, -- 5073
						my + self:px(24) -- 5073
					), -- 5073
					self:px(1), -- 5073
					col -- 5073
				) -- 5073
			end -- 5073
			::__continue934:: -- 5073
			j = j + 1 -- 5056
		end -- 5056
	end -- 5056
	local t = 0 -- 5076
	do -- 5076
		t = 0 -- 5077
		while t < #self.room.marks do -- 5077
			do -- 5077
				local m = self.room.marks[t + 1] -- 5078
				if m.kind ~= 6 then -- 5078
					goto __continue940 -- 5080
				end -- 5080
				local mx = self:sx(m.x, w) -- 5082
				local my = self:sy(m.y, h) -- 5083
				draw:drawSegment( -- 5084
					Vec2(mx, my), -- 5084
					Vec2( -- 5084
						mx, -- 5084
						my + self:px(30) -- 5084
					), -- 5084
					self:px(1), -- 5084
					INK_DIM -- 5084
				) -- 5084
				self:drawBox( -- 5085
					draw, -- 5085
					w, -- 5085
					h, -- 5085
					m.x - 5, -- 5085
					m.x + 5, -- 5085
					m.y + 30, -- 5085
					m.y + 40, -- 5085
					CHECK -- 5085
				) -- 5085
			end -- 5085
			::__continue940:: -- 5085
			t = t + 1 -- 5077
		end -- 5077
	end -- 5077
	if self.room.key == "village" then -- 5077
		self:drawVillage(draw, w, h) -- 5088
	end -- 5088
	if self.room.key == "forest" then -- 5088
		self:drawDog(draw, w, h) -- 5091
	end -- 5091
end -- 4985
function Play.prototype.drawDog(self, draw, w, h) -- 5096
	local x = self.dogX -- 5097
	self:drawBox( -- 5098
		draw, -- 5098
		w, -- 5098
		h, -- 5098
		x - 14, -- 5098
		x + 14, -- 5098
		0, -- 5098
		20, -- 5098
		SCAV_BODY -- 5098
	) -- 5098
	self:drawBox( -- 5099
		draw, -- 5099
		w, -- 5099
		h, -- 5099
		x - 10, -- 5099
		x - 2, -- 5099
		20, -- 5099
		30, -- 5099
		SCAV_BODY -- 5099
	) -- 5099
	self:drawBox( -- 5100
		draw, -- 5100
		w, -- 5100
		h, -- 5100
		x + 2, -- 5100
		x + 10, -- 5100
		20, -- 5100
		30, -- 5100
		SCAV_HEAD -- 5100
	) -- 5100
	if self.dogState == "ear" or self.dogState == "chase" then -- 5100
		draw:drawSegment( -- 5102
			Vec2( -- 5102
				self:sx(x, w), -- 5102
				self:sy(30, h) -- 5102
			), -- 5102
			Vec2( -- 5103
				self:sx(x, w), -- 5103
				self:sy(40, h) -- 5103
			), -- 5103
			self:px(1), -- 5103
			DANGER -- 5103
		) -- 5103
	end -- 5103
end -- 5096
function Play.prototype.drawVillage(self, draw, w, h) -- 5108
	local bottle = self.room.bottle -- 5109
	if bottle ~= nil then -- 5109
		self:drawBox( -- 5111
			draw, -- 5111
			w, -- 5111
			h, -- 5111
			bottle.x - 14, -- 5111
			bottle.x + 14, -- 5111
			0, -- 5111
			64, -- 5111
			SOLID_FILL -- 5111
		) -- 5111
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 5111
			self:drawBottle( -- 5113
				draw, -- 5113
				w, -- 5113
				h, -- 5113
				bottle.x, -- 5113
				64 -- 5113
			) -- 5113
		end -- 5113
	end -- 5113
	self:drawBox( -- 5117
		draw, -- 5117
		w, -- 5117
		h, -- 5117
		300, -- 5117
		420, -- 5117
		44, -- 5117
		50, -- 5117
		FLOOR_DECK -- 5117
	) -- 5117
	self:drawBox( -- 5118
		draw, -- 5118
		w, -- 5118
		h, -- 5118
		300, -- 5118
		306, -- 5118
		0, -- 5118
		44, -- 5118
		FLOOR_DECK -- 5118
	) -- 5118
	self:drawBox( -- 5119
		draw, -- 5119
		w, -- 5119
		h, -- 5119
		414, -- 5119
		420, -- 5119
		0, -- 5119
		44, -- 5119
		FLOOR_DECK -- 5119
	) -- 5119
	local s = self.room.scavenger -- 5121
	if s ~= nil then -- 5121
		local sx0 = self.scavX -- 5123
		self:drawBox( -- 5124
			draw, -- 5124
			w, -- 5124
			h, -- 5124
			sx0 - 12, -- 5124
			sx0 + 12, -- 5124
			0, -- 5124
			s.h - 14, -- 5124
			SCAV_BODY -- 5124
		) -- 5124
		self:drawBox( -- 5125
			draw, -- 5125
			w, -- 5125
			h, -- 5125
			sx0 - 7, -- 5125
			sx0 + 7, -- 5125
			s.h - 14, -- 5125
			s.h, -- 5125
			SCAV_HEAD -- 5125
		) -- 5125
		if self.scavState == "turn" then -- 5125
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 5127
			draw:drawSegment( -- 5128
				Vec2( -- 5128
					self:sx(sx0, w), -- 5128
					self:sy(s.h - 6, h) -- 5128
				), -- 5128
				Vec2( -- 5128
					self:sx(fx, w), -- 5128
					self:sy(s.h - 6, h) -- 5128
				), -- 5128
				self:px(1), -- 5128
				INK -- 5128
			) -- 5128
		end -- 5128
	end -- 5128
	if self.hasBottle then -- 5128
		local p = self.player -- 5133
		self:drawBottle( -- 5134
			draw, -- 5134
			w, -- 5134
			h, -- 5134
			p.x + p.facing * 10, -- 5134
			p.y + p.h * 0.62 -- 5134
		) -- 5134
	end -- 5134
	if self.bottleFly ~= nil then -- 5134
		self:drawBottle( -- 5137
			draw, -- 5137
			w, -- 5137
			h, -- 5137
			self.bottleFly.x, -- 5137
			self.bottleFly.y -- 5137
		) -- 5137
	end -- 5137
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 5137
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 5140
		draw:drawCircle( -- 5141
			Vec2( -- 5141
				self:sx(self.bottleLandX, w), -- 5141
				self:sy(0, h) -- 5141
			), -- 5141
			self:px(r / ____exports.UNITS_PER_PX), -- 5141
			BRICK_LINE -- 5141
		) -- 5141
	end -- 5141
end -- 5108
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 5145
	self:drawBox( -- 5146
		draw, -- 5146
		w, -- 5146
		h, -- 5146
		x - 3, -- 5146
		x + 3, -- 5146
		y - 10, -- 5146
		y, -- 5146
		BOTTLE -- 5146
	) -- 5146
end -- 5145
function Play.prototype.drawTrace(self, draw, w, h) -- 5149
	local t = self.trace -- 5150
	if t == nil or self.traceT <= 0 then -- 5150
		return -- 5152
	end -- 5152
	draw:drawSegment( -- 5154
		Vec2( -- 5155
			self:sx(t.x0, w), -- 5155
			self:sy(t.y0, h) -- 5155
		), -- 5155
		Vec2( -- 5156
			self:sx(t.x1, w), -- 5156
			self:sy(t.y1, h) -- 5156
		), -- 5156
		self:px(1), -- 5157
		t.hit and AIM_HIT or INK_DIM -- 5157
	) -- 5157
end -- 5149
function Play.prototype.drawAim(self, draw, w, h) -- 5160
	local v = self.view -- 5162
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 5163
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 5164
	local dot = self:px(1) -- 5165
	local arm = self:px(3) -- 5166
	local gap = self:px(1) -- 5167
	draw:drawSegment( -- 5168
		Vec2(gx - arm - gap, gy), -- 5168
		Vec2(gx - gap, gy), -- 5168
		dot / 2, -- 5168
		AIM -- 5168
	) -- 5168
	draw:drawSegment( -- 5169
		Vec2(gx + gap, gy), -- 5169
		Vec2(gx + arm + gap, gy), -- 5169
		dot / 2, -- 5169
		AIM -- 5169
	) -- 5169
	draw:drawSegment( -- 5170
		Vec2(gx, gy - arm - gap), -- 5170
		Vec2(gx, gy - gap), -- 5170
		dot / 2, -- 5170
		AIM -- 5170
	) -- 5170
	draw:drawSegment( -- 5171
		Vec2(gx, gy + gap), -- 5171
		Vec2(gx, gy + arm + gap), -- 5171
		dot / 2, -- 5171
		AIM -- 5171
	) -- 5171
	if self.room.key == "village" and self.hasBottle then -- 5171
		local p = self.player -- 5175
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 5177
		local dir = ____end.x >= p.x and 1 or -1 -- 5178
		local x0 = p.x + dir * 10 -- 5179
		local y0 = p.y + p.h * 0.7 -- 5180
		local T = BOTTLE_FLY_TIME -- 5181
		local vx = (____end.x - x0) / T -- 5182
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 5183
		local pxr = x0 -- 5184
		local pyr = y0 -- 5185
		local t = 1 -- 5186
		do -- 5186
			t = 1 -- 5187
			while t <= 12 do -- 5187
				local tt = t / 12 * T -- 5188
				local nx = x0 + vx * tt -- 5189
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 5190
				draw:drawSegment( -- 5191
					Vec2( -- 5191
						self:sx(pxr, w), -- 5191
						self:sy(pyr, h) -- 5191
					), -- 5191
					Vec2( -- 5191
						self:sx(nx, w), -- 5191
						self:sy(ny, h) -- 5191
					), -- 5191
					self:px(1) / 2, -- 5191
					BOTTLE -- 5191
				) -- 5191
				pxr = nx -- 5192
				pyr = ny -- 5193
				t = t + 1 -- 5187
			end -- 5187
		end -- 5187
		draw:drawCircle( -- 5195
			Vec2( -- 5195
				self:sx(____end.x, w), -- 5195
				self:sy(____end.y + 2, h) -- 5195
			), -- 5195
			self:px(2), -- 5195
			BOTTLE -- 5195
		) -- 5195
	end -- 5195
end -- 5160
return ____exports -- 5160