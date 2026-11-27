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
local makeActor, rayInterval, hitBox, CHILD_W, CHILD_H, SOLDIER_W, SOLDIER_H -- 1
local ____rooms = require("Script.watch.rooms") -- 12
local ESCORT_VARIANTS = ____rooms.ESCORT_VARIANTS -- 13
local withOrigin = ____rooms.withOrigin -- 14
local ____run = require("Script.watch.run") -- 16
local ALL_TALENTS = ____run.ALL_TALENTS -- 17
local createRun = ____run.createRun -- 17
local createStoryTalents = ____run.createStoryTalents -- 17
local draftTalentOffers = ____run.draftTalentOffers -- 17
local mmss = ____run.mmss -- 18
local pickEscortVariant = ____run.pickEscortVariant -- 18
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
function makeActor(room, index) -- 5916
	local sp = room.spawns -- 5917
	if index < 0 or index >= #sp then -- 5917
		return { -- 5919
			x = 0, -- 5919
			y = 0, -- 5919
			depth = 0, -- 5919
			depthSpeed = 0, -- 5919
			vx = 0, -- 5919
			vy = 0, -- 5919
			w = CHILD_W, -- 5919
			h = CHILD_H, -- 5919
			onGround = true, -- 5919
			facing = 1, -- 5919
			crouch = false, -- 5919
			rollT = 0, -- 5919
			covered = false, -- 5919
			alive = false -- 5919
		} -- 5919
	end -- 5919
	local s = sp[index + 1] -- 5921
	local child = s.h < SOLDIER_H -- 5922
	local ground = room.depth -- 5923
	local depth = ground == nil and 0 or math.max( -- 5924
		ground.min, -- 5924
		math.min(ground.max, s.depth or 0) -- 5924
	) -- 5924
	return { -- 5925
		x = s.x, -- 5926
		y = s.y, -- 5926
		depth = depth, -- 5926
		depthSpeed = 0, -- 5926
		vx = 0, -- 5926
		vy = 0, -- 5926
		w = child and CHILD_W or SOLDIER_W, -- 5927
		h = child and CHILD_H or SOLDIER_H, -- 5928
		onGround = true, -- 5929
		facing = 1, -- 5929
		crouch = false, -- 5929
		rollT = 0, -- 5929
		covered = false, -- 5929
		alive = true -- 5929
	} -- 5929
end -- 5929
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5934
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5935
end -- 5934
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5942
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5943
end -- 5942
function rayInterval(origin, direction, min, max) -- 5950
	if direction == 0 then -- 5950
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5952
	end -- 5952
	local a = (min - origin) / direction -- 5954
	local b = (max - origin) / direction -- 5955
	return { -- 5956
		min = math.min(a, b), -- 5956
		max = math.max(a, b) -- 5956
	} -- 5956
end -- 5956
function hitBox(ray, box) -- 5960
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5961
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5962
	local enter = math.max(0, x.min, y.min) -- 5963
	local leave = math.min(99999, x.max, y.max) -- 5964
	if box.depth ~= nil then -- 5964
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5966
		enter = math.max(enter, depth.min) -- 5967
		leave = math.min(leave, depth.max) -- 5968
	end -- 5968
	return leave >= enter and enter or -1 -- 5970
end -- 5970
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
--- P02 门槛内墙上人影截断与瓷碗滚撞门槛（硬核漫画逐帧舒展节奏）：4.5 秒 = 270 拍。
____exports.PROLOGUE_SHADOW_TICKS = 270 -- 52
--- 限时逃柜：7.5 秒 = 450 拍；超时退回门口重来，不扣血。
____exports.PROLOGUE_ESCAPE_TICKS = 450 -- 54
--- 入柜后红晕收尽、门缝三阶合拢与柜外脚步渐远：1.8 秒 = 108 拍。
____exports.PROLOGUE_HIDE_TICKS = 108 -- 56
--- 序章 P03 柜边递针套特写时长：3.0 秒 = 180 拍（对齐分镜稿与 D01 对白节拍）。
____exports.PROLOGUE_GIVE_TICKS = 180 -- 58
--- 城门 P05 送别嘱咐独立演出时长：约 3.67 秒 = 220 拍（演完再切入 24 秒数到二十，零叠字叠音）。
____exports.GATE_FAREWELL_TICKS = 220 -- 60
--- 小满贴住倒柜左缘（段内 x，柜体从 152 起；玩家半宽 14）即拉门入柜。
____exports.PROLOGUE_CABINET_X = 132 -- 62
function ____exports.gateCountAtTick(tick) -- 64
	if tick >= ____exports.GATE_COUNT_END then -- 64
		return 20 -- 65
	end -- 65
	if tick >= 1260 then -- 65
		return 19 -- 66
	end -- 66
	if tick >= 1080 then -- 66
		return 18 -- 67
	end -- 67
	if tick >= 480 then -- 67
		return 11 + math.floor((tick - 480) * 7 / 600) -- 68
	end -- 68
	return 1 + math.floor(math.max(0, tick) / 48) -- 69
end -- 64
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 72
CHILD_W = 28 -- 147
CHILD_H = 56 -- 148
local CHILD_CROUCH_H = 34 -- 149
local CHILD_SPEED = 160 -- 150
local CHILD_SLOW = 80 -- 151
local CHILD_JUMP = 320 -- 152
SOLDIER_W = 30 -- 155
SOLDIER_H = 88 -- 156
local SOLDIER_SPEED = 264 -- 157
local ROLL_TIME = 0.35 -- 158
local ROLL_SPEED = 280 -- 159
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 161
local LEDGE_RISE = 60 -- 162
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 165
____exports.LOGIC_H = 180 -- 166
____exports.UNITS_PER_PX = 2 -- 167
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 169
local CAM_FOLLOW = 9 -- 170
local CAM_LOOK_UP = 46 -- 171
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 174
--- 握把触发半径。
____exports.CART_REACH = 70 -- 176
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 178
local CART_CLEAR = 44 -- 179
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 181
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 183
local CONSUMABLE_CAP = 1 -- 184
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 186
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 188
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 190
local FIRE_COOLDOWN = 150 -- 191
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 193
local ENEMY_RANGE = 760 -- 194
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 196
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 198
local DEPTH_SPEED_RATIO = 0.55 -- 199
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 200
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 287
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 288
	if zoom < 1 then -- 288
		zoom = 1 -- 290
	end -- 290
	return { -- 292
		zoom = zoom, -- 293
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 294
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 295
	} -- 295
end -- 287
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 318
	if key == "prologue" then -- 318
		return "prologue-wait" -- 322
	end -- 322
	if key == "street" then -- 322
		return "street-run" -- 325
	end -- 325
	if key == "gate" then -- 325
		return "gate-idle" -- 328
	end -- 328
	if key == "gatepath" then -- 328
		return "gatepath-start" -- 331
	end -- 331
	if key == "forest" then -- 331
		return "forest-run" -- 334
	end -- 334
	if key == "tower" then -- 334
		return "tower-wait" -- 337
	end -- 337
	if key == "museum" then -- 337
		return "museum-cabinet" -- 340
	end -- 340
	return "run" -- 342
end -- 318
____exports.Play = __TS__Class() -- 345
local Play = ____exports.Play -- 345
Play.name = "Play" -- 345
function Play.prototype.____constructor(self, room, resume, run) -- 655
	self.enemies = {} -- 350
	self.boxes = {} -- 351
	self.floors = {} -- 352
	self.checkpoint = -1 -- 354
	self.flash = "" -- 356
	self.flashT = 0 -- 357
	self.traceT = 0 -- 360
	self.focusCart = false -- 362
	self.knocks = 0 -- 364
	self.knockT = 0 -- 365
	self.cartAxle = 0 -- 369
	self.cartDocked = false -- 371
	self.gripping = false -- 373
	self.gateOpen = false -- 375
	self.calmConsumed = false -- 377
	self.craftT = 0 -- 379
	self.nextDangerId = 1 -- 381
	self.wantRoom = "" -- 383
	self.carryCartAxle = -1 -- 385
	self.carryCartDocked = false -- 386
	self.checkpointCartAxle = -1 -- 388
	self.hasBottle = false -- 392
	self.bottleLandX = -1 -- 396
	self.bottleTargetX = -1 -- 397
	self.bottleTargetY = 0 -- 398
	self.bottleLandT = 0 -- 399
	self.aimHold = 0 -- 401
	self.redCartPulled = false -- 403
	self.redCartMemoryT = 0 -- 405
	self.footHintT = 0 -- 407
	self.ditchHinted = false -- 409
	self.forestPath = "" -- 411
	self.waterSeen = false -- 413
	self.scavStallBonus = 0 -- 415
	self.intentGateReunionHold = false -- 417
	self.pendingMuseumIntentTarget = "" -- 419
	self.scavX = 0 -- 421
	self.scavDir = 1 -- 422
	self.scavState = "patrol" -- 423
	self.scavT = 0 -- 424
	self.scavTargetX = 0 -- 425
	self.passed = false -- 427
	self.childMode = false -- 431
	self.phase = "" -- 433
	self.phaseTick = 0 -- 435
	self.gateTick = 0 -- 437
	self.countTick = 0 -- 439
	self.countArmed = false -- 441
	self.countPrevMove = 0 -- 443
	self.caughtT = 0 -- 445
	self.hp = 3 -- 447
	self.maxHp = 3 -- 448
	self.invulnT = 0 -- 454
	self.partnerStuck = 0 -- 456
	self.partnerLaneIdx = 0 -- 458
	self.partnerLaneHold = 0 -- 459
	self.coveredFlash = 0 -- 461
	self.coverHug = false -- 463
	self.coverNear = false -- 465
	self.coverEntity = "" -- 467
	self.coverBlocking = false -- 469
	self.gateNeedConfirm = false -- 471
	self.gateRestartArmed = true -- 473
	self.bottleAimX = -1 -- 475
	self.bottleAimY = 0 -- 476
	self.bottleSurfaceY = -1 -- 478
	self.bottleLandY = 0 -- 480
	self.events = {} -- 482
	self.eventSeq = 0 -- 484
	self.dogX = 0 -- 486
	self.dogDir = 1 -- 487
	self.dogState = "patrol" -- 488
	self.dogT = 0 -- 489
	self.dogTargetX = 0 -- 490
	self.scavSee = 0 -- 492
	self.scavChase = false -- 493
	self.gateSpawned = 0 -- 495
	self.gateFailCount = 0 -- 497
	self.isCampaign = false -- 501
	self.archiveDirty = false -- 509
	self.sessionDirty = false -- 511
	self.restartStory = false -- 513
	self.wellOpen = false -- 515
	self.wellX = 430 -- 517
	self.wellTaken = false -- 519
	self.museumReturn = false -- 521
	self.endingLines = {"", ""} -- 523
	self.towerDoorOpen = false -- 525
	self.towerHanded = false -- 526
	self.deskHold = 0 -- 527
	self.towerEndMustRelease = false -- 529
	self.equippedWeapon = "standard_gun" -- 542
	self.craftBench = { -- 544
		active = false, -- 545
		firstCraftDone = false, -- 546
		justCraftedTimer = 0, -- 547
		inventory = {}, -- 548
		recipes = {}, -- 549
		equippedWeapon = "standard_gun" -- 550
	} -- 550
	self.handledCraftRequests = {} -- 553
	self.benchReach = 48 -- 555
	self.pickups = {} -- 559
	self.reloadT = 0 -- 561
	self.objectiveDone = false -- 565
	self.hint = "" -- 567
	self.roomStartTick = 0 -- 569
	self.cartHitT = 0 -- 571
	self.cartExposed = false -- 572
	self.storyRoute = "" -- 576
	self.storySettled = false -- 578
	self.hpAtGate = -1 -- 580
	self.maxHpAtGate = -1 -- 581
	self.handTicks = 0 -- 583
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 585
	self.handArmed = false -- 587
	self.handDone = false -- 589
	self.lineSaid = false -- 590
	self.tied = false -- 592
	self.pathDone = false -- 594
	self.carryOn = false -- 596
	self.escortDone = false -- 598
	self.escapeDuration = ____exports.PROLOGUE_ESCAPE_TICKS / 60 -- 602
	self.escapeRemaining = 0 -- 604
	self.escapeRetryCount = 0 -- 606
	self.introTick = 0 -- 608
	self.reloadOpen = false -- 612
	self.reloadAnswerTicks = 0 -- 614
	self.reloadWorldTicks = 0 -- 616
	self.reloadPath = {RELOAD_START} -- 618
	self.reloadPendingEffect = "" -- 620
	self.reloadTryCount = 0 -- 622
	self.talentModalActive = false -- 625
	self.useEscortDeathSummary = false -- 626
	self.escortFailed = false -- 627
	self.escortFailedTicks = 0 -- 628
	self.escortSummary = nil -- 629
	self.fieldWedgeSeq = 0 -- 637
	self.paused = false -- 639
	self.ticks = 0 -- 641
	self.view = {zoom = 1, ox = 0, oy = 0} -- 643
	self.ox = 0 -- 645
	self.aimX = 0 -- 647
	self.aimY = 0 -- 648
	self.viewW = 0 -- 650
	self.viewH = 0 -- 651
	self.ox = room.originX -- 657
	self.room = withOrigin(room) -- 658
	local wr = self.room -- 659
	self.run = run or createRun() -- 660
	self.inventory = self.run.inventory -- 661
	self.archive = self.run.archive -- 662
	local story = self.run.story -- 663
	local savedEq = story.equippedWeapon -- 664
	if savedEq == ARTIFACT_WEAPON_ID and self.archive.artifactOwned then -- 664
		self.equippedWeapon = ARTIFACT_WEAPON_ID -- 666
	elseif savedEq == "standard_gun" or savedEq ~= "" and savedEq == story.craftedWeapon then -- 666
		self.equippedWeapon = savedEq -- 668
	else -- 668
		self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 670
	end -- 670
	self.isCampaign = wr.campaign ~= nil -- 672
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 673
	self:buildWorld() -- 674
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 677
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 679
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 680
	local soloRoom = wr.key == "museum" -- 682
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 683
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 684
	self.player = makeActor(wr, playerIdx) -- 685
	self.partner = makeActor(wr, partnerIdx) -- 686
	self.phase = phaseOf(wr.key) -- 687
	if soloRoom then -- 687
		local mp = self.archive.museumPhase -- 690
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 691
	end -- 691
	if wr.story ~= nil then -- 691
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 697
	end -- 697
	self.cam.x = self.player.x -- 699
	self.cam.y = self.player.y + CAM_LOOK_UP -- 700
	self.cartAxle = wr.cart.startX -- 701
	self.escort = __TS__New( -- 702
		Escort, -- 702
		safeAnchorX(wr.marks) -- 702
	) -- 702
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 703
	if self.isCampaign then -- 703
		self:setupCampaign() -- 705
	else -- 705
		self:buildEnemies() -- 707
	end -- 707
	if resume ~= nil and resume.checkpoint > 0 then -- 707
		self.checkpoint = resume.checkpoint -- 711
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 711
			self.cartAxle = self.room.cart.endX -- 713
			self.cartDocked = true -- 714
			self.player.x = self.ox + 380 -- 717
			self.player.y = 0 -- 718
			self.player.vy = 0 -- 719
			self.player.onGround = true -- 720
			self.cam.x = self.player.x -- 721
			self.cam.y = self.player.y + CAM_LOOK_UP -- 722
		end -- 722
	end -- 722
	self:restoreStory() -- 725
end -- 655
function Play.prototype.towerEndReady(self) -- 532
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 533
	return self.room.key == "tower" and self.phase == "tower-end" and self.phaseTick >= waitTicks and not self.towerEndMustRelease -- 534
end -- 532
function Play.prototype.recipeViews(self) -- 738
	local out = {} -- 739
	local i = 0 -- 740
	do -- 740
		i = 0 -- 741
		while i < #CRAFT_RECIPES do -- 741
			local r = CRAFT_RECIPES[i + 1] -- 742
			local cost = {} -- 743
			if r.cost.wood ~= nil then -- 743
				cost.wood = r.cost.wood -- 745
			end -- 745
			if r.cost.bell ~= nil then -- 745
				cost.bell = r.cost.bell -- 748
			end -- 748
			out[#out + 1] = { -- 750
				id = r.id, -- 751
				name = r.name, -- 752
				desc = r.desc, -- 753
				enhancedEffect = r.enhancedEffect, -- 754
				cost = cost, -- 755
				crafted = self.run.story.craftedWeapon == r.id -- 756
			} -- 756
			i = i + 1 -- 741
		end -- 741
	end -- 741
	if self.archive.artifactOwned then -- 741
		out[#out + 1] = { -- 761
			id = ARTIFACT_WEAPON_ID, -- 762
			name = weaponNameOf(ARTIFACT_WEAPON_ID), -- 763
			desc = "井底拾取彩蛋 · 男主线移动留下冷白微金轨迹残影", -- 764
			enhancedEffect = "light", -- 765
			cost = {}, -- 766
			crafted = true -- 767
		} -- 767
	end -- 767
	return out -- 770
end -- 738
function Play.prototype.syncCraftBench(self) -- 774
	local view = self.craftBench -- 775
	local inv = self.run.inventory -- 776
	view.inventory = { -- 777
		wood = inv.wood, -- 777
		bell = inv.bell, -- 777
		scrap = inv.scrap, -- 777
		wedge = inv.wedge, -- 777
		ammo = inv.ammo -- 777
	} -- 777
	view.recipes = self:recipeViews() -- 778
	view.equippedWeapon = self.equippedWeapon -- 779
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 780
	if view.justCraftedTimer > 0 then -- 780
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 782
	end -- 782
end -- 774
function Play.prototype.openCraftBench(self) -- 787
	if self.room.key ~= "escort3" or self.craftBench.active then -- 787
		return -- 789
	end -- 789
	self.craftBench.active = true -- 791
	self.carryOn = false -- 792
	self.run.story.carry = false -- 793
	self.player.vx = 0 -- 794
	self.player.vy = 0 -- 795
	self.craftBench.justCraftedTimer = 0 -- 796
	self:syncCraftBench() -- 797
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 798
	self:log("开工台") -- 799
	self:emit( -- 800
		"benchOpen", -- 800
		{ -- 800
			recipes = __TS__ArrayMap( -- 801
				self.craftBench.recipes, -- 801
				function(____, r) return r.id end -- 801
			), -- 801
			inventory = self.craftBench.inventory, -- 802
			carry = self.carryOn -- 803
		} -- 803
	) -- 803
end -- 787
function Play.prototype.closeCraftBench(self) -- 808
	if not self.craftBench.active then -- 808
		return -- 810
	end -- 810
	self.craftBench.active = false -- 812
	self.craftBench.justCraftedTimer = 0 -- 813
	self.carryOn = true -- 814
	self.run.story.carry = true -- 815
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 816
	self:log("离站背起") -- 817
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 818
	if self.room.key == "escort3" and self.storyRoute == "soldier" then -- 818
		self:triggerDeferredEscort3Draft() -- 820
	end -- 820
end -- 808
function Play.prototype.triggerDeferredEscort3Draft(self) -- 825
	if self.room.key ~= "escort3" or self.storyRoute ~= "soldier" or self.run.finished then -- 825
		return false -- 827
	end -- 827
	if self.run.story.talents == nil then -- 827
		self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 830
	end -- 830
	local st = self.run.story.talents -- 832
	if not st.deferred and st.room == "escort3" then -- 832
		return false -- 834
	end -- 834
	draftTalentOffers(st, "escort3", self.equippedWeapon) -- 836
	if self.useEscortDeathSummary and #st.offers > 0 then -- 836
		self.talentModalActive = true -- 838
	end -- 838
	self.sessionDirty = true -- 840
	return #st.offers > 0 -- 841
end -- 825
function Play.prototype.openTalentDraft(self) -- 845
	if #self:getStoryTalentOffers() > 0 and not self.craftBench.active and not self.escortFailed then -- 845
		self.talentModalActive = true -- 847
	end -- 847
end -- 845
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 855
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 855
		return false -- 857
	end -- 857
	local recipe = findRecipe(recipeId) -- 859
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 859
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 861
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 862
		return false -- 863
	end -- 863
	local missing = missingMaterials(self.run.inventory, recipe) -- 865
	if #missing > 0 then -- 865
		self:flashSet( -- 867
			"缺料 · " .. table.concat(missing, " / "), -- 867
			1.6 -- 867
		) -- 867
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 868
		return false -- 869
	end -- 869
	payMaterials(self.run.inventory, recipe) -- 871
	self.handledCraftRequests[requestId] = true -- 872
	self.run.story.craftedWeapon = recipe.id -- 873
	self.run.story.equippedWeapon = recipe.id -- 874
	self.equippedWeapon = recipe.id -- 875
	self.sessionDirty = true -- 876
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 877
	self.craftBench.firstCraftDone = true -- 878
	self:syncCraftBench() -- 879
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 880
	self:log("改制 " .. recipe.id) -- 881
	self:emit("benchCraft", { -- 882
		recipeId = recipe.id, -- 883
		weapon = recipe.id, -- 884
		effect = recipe.enhancedEffect, -- 885
		wood = self.run.inventory.wood, -- 886
		bell = self.run.inventory.bell -- 887
	}) -- 887
	return true -- 889
end -- 855
function Play.prototype.equipWeapon(self, weaponId) -- 893
	local artifactOk = weaponId == ARTIFACT_WEAPON_ID and self.archive.artifactOwned -- 894
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId and not artifactOk then -- 894
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 896
		return false -- 897
	end -- 897
	self.equippedWeapon = weaponId -- 899
	self.run.story.equippedWeapon = weaponId -- 900
	self.sessionDirty = true -- 901
	self:syncCraftBench() -- 902
	self:flashSet( -- 903
		"已装备 " .. weaponNameOf(weaponId), -- 903
		1 -- 903
	) -- 903
	self:emit("benchEquip", {weapon = weaponId}) -- 904
	return true -- 905
end -- 893
function Play.prototype.toggleArtifactWeapon(self) -- 909
	if not self.archive.artifactOwned or self.childMode then -- 909
		return false -- 911
	end -- 911
	if self.equippedWeapon == ARTIFACT_WEAPON_ID then -- 911
		local fallback = self.run.story.craftedWeapon ~= "" and self.run.story.craftedWeapon or "standard_gun" -- 914
		return self:equipWeapon(fallback) -- 915
	end -- 915
	return self:equipWeapon(ARTIFACT_WEAPON_ID) -- 917
end -- 909
function Play.prototype.exportSession(self) -- 921
	self:syncStory() -- 922
	local story = self.run.story -- 923
	local inv = self.run.inventory -- 924
	local taken = {} -- 925
	for k in pairs(self.run.taken) do -- 926
		if self.run.taken[k] == true then -- 926
			taken[#taken + 1] = k -- 928
		end -- 928
	end -- 928
	local segments = {} -- 931
	for k in pairs(story.segments) do -- 932
		if story.segments[k] == true then -- 932
			segments[#segments + 1] = k -- 934
		end -- 934
	end -- 934
	local props = {} -- 937
	for k in pairs(self.run.props) do -- 938
		local st = self.run.props[k] -- 939
		if st ~= nil then -- 939
			props[#props + 1] = (((((((k .. ":") .. (st.broken and "1" or "0")) .. ":") .. tostring(math.floor(st.hp + 0.5))) .. ":") .. (st.wedge and "1" or "0")) .. ":") .. (st.revealed == true and "1" or "0") -- 941
		end -- 941
	end -- 941
	local talentRanks = {} -- 950
	if story.talents ~= nil then -- 950
		local ti = 0 -- 952
		do -- 952
			ti = 0 -- 953
			while ti < #ALL_TALENTS do -- 953
				local tid = ALL_TALENTS[ti + 1] -- 954
				local rk = story.talents.ranks[tid] or 0 -- 955
				if rk > 0 then -- 955
					talentRanks[#talentRanks + 1] = (tid .. ":") .. tostring(rk) -- 957
				end -- 957
				ti = ti + 1 -- 953
			end -- 953
		end -- 953
	end -- 953
	local ____temp_4 = self.escortFailed and "escort1" or self.room.key -- 963
	local ____temp_5 = self.escortFailed and 0 or self.checkpoint -- 964
	local ____self_run_seed_6 = self.run.seed -- 965
	local ____story_route_7 = story.route -- 966
	local ____story_hp_8 = story.hp -- 967
	local ____story_maxHp_9 = story.maxHp -- 968
	local ____story_hpAtGate_10 = story.hpAtGate -- 969
	local ____story_maxHpAtGate_11 = story.maxHpAtGate -- 970
	local ____story_settled_12 = story.settled -- 971
	local ____self_phase_13 = self.phase -- 972
	local ____story_countTick_14 = story.countTick -- 973
	local ____story_phaseTick_15 = story.phaseTick -- 974
	local ____story_handTicks_16 = story.handTicks -- 975
	local ____story_handDone_17 = story.handDone -- 976
	local ____story_lineSaid_18 = story.lineSaid -- 977
	local ____story_tied_19 = story.tied -- 978
	local ____story_carry_20 = story.carry -- 979
	local ____story_escortDone_21 = story.escortDone -- 980
	local ____story_craftedWeapon_22 = story.craftedWeapon -- 981
	local ____self_equippedWeapon_23 = self.equippedWeapon -- 982
	local ____inv_wood_24 = inv.wood -- 983
	local ____inv_bell_25 = inv.bell -- 984
	local ____inv_scrap_26 = inv.scrap -- 985
	local ____inv_wedge_27 = inv.wedge -- 986
	local ____inv_ammo_28 = inv.ammo -- 987
	local ____inv_shield_29 = inv.shield -- 988
	local ____inv_pass_30 = inv.pass -- 989
	local ____inv_quickbelt_31 = inv.quickbelt -- 990
	local ____taken_32 = taken -- 991
	local ____segments_33 = segments -- 992
	local ____self_cartAxle_34 = self.cartAxle -- 993
	local ____self_cartDocked_35 = self.cartDocked -- 994
	local ____self_run_route_36 = self.run.route -- 995
	local ____self_run_joined_37 = self.run.joined -- 996
	local ____self_run_c1Latch_38 = self.run.c1Latch -- 997
	local ____self_run_c2Latch_39 = self.run.c2Latch -- 998
	local ____temp_40 = story.talents ~= nil and story.talents.randomState or 0 -- 999
	local ____temp_41 = story.talents ~= nil and story.talents.room or "" -- 1000
	local ____temp_42 = story.talents ~= nil and __TS__ArraySlice(story.talents.offers) or ({}) -- 1001
	local ____talentRanks_43 = talentRanks -- 1002
	local ____temp_44 = story.talents ~= nil and story.talents.attempt or 1 -- 1003
	local ____temp_45 = story.talents ~= nil and story.talents.variant or 0 -- 1004
	local ____temp_0 -- 1005
	if story.talents ~= nil then -- 1005
		____temp_0 = story.talents.deferred -- 1005
	else -- 1005
		____temp_0 = false -- 1005
	end -- 1005
	local ____temp_46 = story.talents ~= nil and story.talents.ranks.vitality or 0 -- 1006
	local ____temp_47 = story.talents ~= nil and story.talents.ranks.focus or 0 -- 1007
	local ____temp_48 = story.talents ~= nil and story.talents.ranks.guard or 0 -- 1008
	local ____temp_49 = story.talents ~= nil and story.talents.ranks.salvage or 0 -- 1009
	local ____props_50 = props -- 1010
	local ____table_escortFailed_1 -- 1011
	if self.escortFailed then -- 1011
		____table_escortFailed_1 = nil -- 1011
	else -- 1011
		____table_escortFailed_1 = self.player.x -- 1011
	end -- 1011
	local ____table_escortFailed_2 -- 1012
	if self.escortFailed then -- 1012
		____table_escortFailed_2 = nil -- 1012
	else -- 1012
		____table_escortFailed_2 = self.player.y -- 1012
	end -- 1012
	local ____table_escortFailed_3 -- 1013
	if self.escortFailed then -- 1013
		____table_escortFailed_3 = nil -- 1013
	else -- 1013
		____table_escortFailed_3 = self.player.depth -- 1013
	end -- 1013
	return { -- 961
		roomKey = ____temp_4, -- 963
		checkpoint = ____temp_5, -- 964
		seed = ____self_run_seed_6, -- 965
		route = ____story_route_7, -- 966
		hp = ____story_hp_8, -- 967
		maxHp = ____story_maxHp_9, -- 968
		hpAtGate = ____story_hpAtGate_10, -- 969
		maxHpAtGate = ____story_maxHpAtGate_11, -- 970
		settled = ____story_settled_12, -- 971
		phase = ____self_phase_13, -- 972
		countTick = ____story_countTick_14, -- 973
		phaseTick = ____story_phaseTick_15, -- 974
		handTicks = ____story_handTicks_16, -- 975
		handDone = ____story_handDone_17, -- 976
		lineSaid = ____story_lineSaid_18, -- 977
		tied = ____story_tied_19, -- 978
		carry = ____story_carry_20, -- 979
		escortDone = ____story_escortDone_21, -- 980
		craftedWeapon = ____story_craftedWeapon_22, -- 981
		equippedWeapon = ____self_equippedWeapon_23, -- 982
		wood = ____inv_wood_24, -- 983
		bell = ____inv_bell_25, -- 984
		scrap = ____inv_scrap_26, -- 985
		wedge = ____inv_wedge_27, -- 986
		ammo = ____inv_ammo_28, -- 987
		shield = ____inv_shield_29, -- 988
		pass = ____inv_pass_30, -- 989
		quickbelt = ____inv_quickbelt_31, -- 990
		taken = ____taken_32, -- 991
		segments = ____segments_33, -- 992
		cartAxle = ____self_cartAxle_34, -- 993
		cartDocked = ____self_cartDocked_35, -- 994
		campaignRoute = ____self_run_route_36, -- 995
		joined = ____self_run_joined_37, -- 996
		c1Latch = ____self_run_c1Latch_38, -- 997
		c2Latch = ____self_run_c2Latch_39, -- 998
		talentSeed = ____temp_40, -- 999
		talentRoom = ____temp_41, -- 1000
		talentOffers = ____temp_42, -- 1001
		talentRanks = ____talentRanks_43, -- 1002
		escortAttempt = ____temp_44, -- 1003
		escortVariant = ____temp_45, -- 1004
		talentDeferred = ____temp_0, -- 1005
		talentVitality = ____temp_46, -- 1006
		talentReload = ____temp_47, -- 1007
		talentGuard = ____temp_48, -- 1008
		talentCraft = ____temp_49, -- 1009
		props = ____props_50, -- 1010
		playerX = ____table_escortFailed_1, -- 1011
		playerY = ____table_escortFailed_2, -- 1012
		playerDepth = ____table_escortFailed_3, -- 1013
		gateTick = self.gateTick, -- 1014
		hasBottle = self.hasBottle, -- 1015
		villagePassed = self.passed -- 1016
	} -- 1016
end -- 921
function Play.prototype.submitFeIntent(self, intent) -- 1024
	local kind = intent == nil and "" or intent.kind -- 1025
	if kind == "gateReunionHold" then -- 1025
		if self.room.key ~= "gate" or self.phase ~= "gate-wait" and self.phase ~= "gate-count" then -- 1025
			return false -- 1028
		end -- 1028
		local holding = intent.holding == true -- 1030
		self.intentGateReunionHold = holding -- 1031
		if not holding and self.phase == "gate-wait" then -- 1031
			if self.handTicks > 0 then -- 1031
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1034
			end -- 1034
			self.handTicks = 0 -- 1036
			self.handArmed = true -- 1037
		end -- 1037
		return true -- 1039
	end -- 1039
	if kind == "reloadOpen" then -- 1039
		local camp = self.room.campaign -- 1042
		if camp == nil or camp.reloadPuzzle ~= true or self.reloadOpen then -- 1042
			return false -- 1044
		end -- 1044
		self:beginReload() -- 1046
		return self.reloadOpen -- 1047
	end -- 1047
	if kind == "reloadPathPreview" then -- 1047
		local path = intent.path -- 1050
		return type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) -- 1051
	end -- 1051
	if kind == "reloadTapNode" then -- 1051
		local node = intent.node -- 1054
		if type(node) == "number" then -- 1054
			self:reloadTapNode(node) -- 1056
			return true -- 1057
		end -- 1057
		return false -- 1059
	end -- 1059
	if kind == "reloadPathCommit" then -- 1059
		local path = intent.path -- 1062
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 1062
			local list = path -- 1064
			local i = 0 -- 1065
			do -- 1065
				i = 0 -- 1066
				while i < #list do -- 1066
					do -- 1066
						if i == 0 and list[i + 1] == RELOAD_START then -- 1066
							goto __continue85 -- 1068
						end -- 1068
						self:reloadTapNode(list[i + 1]) -- 1070
					end -- 1070
					::__continue85:: -- 1070
					i = i + 1 -- 1066
				end -- 1066
			end -- 1066
			return true -- 1072
		end -- 1072
		return false -- 1074
	end -- 1074
	if kind == "reloadCancel" then -- 1074
		self:closeReloadPuzzle() -- 1077
		return true -- 1078
	end -- 1078
	if kind == "craftSubmit" then -- 1078
		local recipeId = intent.recipeId -- 1081
		local requestId = intent.requestId -- 1082
		if type(recipeId) == "string" and type(requestId) == "string" then -- 1082
			return self:craftAtBench(recipeId, requestId) -- 1084
		end -- 1084
		return false -- 1086
	end -- 1086
	if kind == "craftEquip" then -- 1086
		local weaponId = intent.weaponId -- 1089
		if type(weaponId) == "string" then -- 1089
			return self:equipWeapon(weaponId) -- 1091
		end -- 1091
		return false -- 1093
	end -- 1093
	if kind == "craftClose" then -- 1093
		self:closeCraftBench() -- 1096
		return true -- 1097
	end -- 1097
	if kind == "chooseTalent" then -- 1097
		local slot = intent.slot -- 1100
		if type(slot) == "number" then -- 1100
			return self:chooseTalent(slot) -- 1102
		end -- 1102
		return false -- 1104
	end -- 1104
	if kind == "wellPick" then -- 1104
		return self:pickWell() -- 1107
	end -- 1107
	if kind == "museumInteract" then -- 1107
		local target = type(intent.target) == "string" and intent.target or "" -- 1110
		if target == "well_pickup" or target == "well" then -- 1110
			return self:pickWell() -- 1112
		end -- 1112
		if self.room.key ~= "museum" then -- 1112
			return false -- 1115
		end -- 1115
		return self:triggerMuseumIntent(target) -- 1117
	end -- 1117
	return false -- 1119
end -- 1024
function Play.prototype.triggerMuseumIntent(self, target) -- 1123
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 1124
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 1127
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 1128
	if self.phase == "museum-cabinet" then -- 1128
		if target == "enter_hall" or (target == "" or target == "cabinet" or target == "weapon_case") and atCase then -- 1128
			self.pendingMuseumIntentTarget = "cabinet" -- 1131
			return true -- 1132
		end -- 1132
	end -- 1132
	if self.phase == "museum-hall" then -- 1132
		if (target == "lamp_turn" or target == "lamp" or target == "west_lamp") and nearLamp then -- 1132
			self.pendingMuseumIntentTarget = "lamp_direct" -- 1137
			return true -- 1138
		end -- 1138
		if (target == "" or target == "hall" or target == "corridor") and self.player.x >= self.ox + mu.hallX then -- 1138
			self.pendingMuseumIntentTarget = "hall" -- 1141
			return true -- 1142
		end -- 1142
	end -- 1142
	if self.phase == "museum-lamp" and (target == "" or target == "lamp" or target == "west_lamp" or target == "lamp_turn") and nearLamp then -- 1142
		self.pendingMuseumIntentTarget = "lamp" -- 1148
		return true -- 1149
	end -- 1149
	if self.phase == "museum-return" then -- 1149
		if target == "begin_return_cabinet" or (target == "" or target == "return_cabinet" or target == "cabinet" or target == "return") and atCase then -- 1149
			self.pendingMuseumIntentTarget = "return_cabinet" -- 1154
			return true -- 1155
		end -- 1155
	end -- 1155
	if self.phase == "museum-done" and (target == "" or target == "return_cabinet" or target == "return") then -- 1155
		self.pendingMuseumIntentTarget = "done" -- 1159
		return true -- 1160
	end -- 1160
	return false -- 1162
end -- 1123
function Play.prototype.captureCheckpoint(self, id) -- 1166
	local inv = self.run.inventory -- 1167
	self.checkpointSnap = { -- 1168
		id = id, -- 1169
		wood = inv.wood, -- 1170
		bell = inv.bell, -- 1171
		scrap = inv.scrap, -- 1172
		wedge = inv.wedge, -- 1173
		ammo = inv.ammo, -- 1174
		shield = inv.shield, -- 1175
		pass = inv.pass, -- 1176
		quickbelt = inv.quickbelt, -- 1177
		crafted = self.run.story.craftedWeapon, -- 1178
		equipped = self.equippedWeapon, -- 1179
		carry = self.carryOn -- 1180
	} -- 1180
	self.run.story.cp = self.checkpointSnap -- 1182
end -- 1166
function Play.prototype.applyCheckpointSnap(self, id) -- 1186
	local snap = self.run.story.cp -- 1187
	if snap == nil or snap.id ~= id then -- 1187
		return false -- 1189
	end -- 1189
	self.checkpointSnap = snap -- 1191
	local inv = self.run.inventory -- 1192
	inv.wood = snap.wood -- 1193
	inv.bell = snap.bell -- 1194
	inv.scrap = snap.scrap -- 1195
	inv.wedge = snap.wedge -- 1196
	inv.ammo = snap.ammo -- 1197
	inv.shield = snap.shield -- 1198
	inv.pass = snap.pass -- 1199
	inv.quickbelt = snap.quickbelt -- 1200
	self.run.story.craftedWeapon = snap.crafted -- 1201
	self.equippedWeapon = snap.equipped -- 1202
	self.run.story.equippedWeapon = snap.equipped -- 1203
	self.carryOn = snap.carry -- 1204
	self.run.story.carry = snap.carry -- 1205
	self.craftBench.active = false -- 1206
	self:syncCraftBench() -- 1207
	return true -- 1208
end -- 1186
function Play.prototype.restoreStory(self) -- 1211
	local story = self.run.story -- 1212
	if story == nil then -- 1212
		return -- 1214
	end -- 1214
	if story.maxHp > 0 then -- 1214
		self.maxHp = story.maxHp -- 1217
		self.hp = math.max( -- 1218
			1, -- 1218
			math.min(story.hp, story.maxHp) -- 1218
		) -- 1218
	end -- 1218
	self.storyRoute = story.route -- 1220
	self.storySettled = story.settled -- 1221
	self.hpAtGate = story.hpAtGate -- 1222
	self.maxHpAtGate = story.maxHpAtGate -- 1223
	self.handDone = story.handDone -- 1224
	self.lineSaid = story.lineSaid -- 1225
	self.tied = story.handDone -- 1226
	self.carryOn = story.carry or story.route == "soldier" and (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 1227
	self.museumReturn = story.museumReturn -- 1228
	story.museumReturn = false -- 1229
	self.escortDone = story.escortDone -- 1230
	self:syncCraftBench() -- 1231
	if story.segments.outside_cart == true then -- 1231
		self.redCartPulled = true -- 1234
		local redBox = __TS__ArrayFind( -- 1235
			self.boxes, -- 1235
			function(____, b) return b.id == "outside_red_cart" end -- 1235
		) -- 1235
		if redBox ~= nil then -- 1235
			redBox.x0 = 430 -- 1237
			redBox.x1 = 474 -- 1238
		end -- 1238
		if self.room.key == "outside" and self.room.cart.bodyW > 0 then -- 1238
			self.cartAxle = self.room.cart.endX -- 1241
			self.cartDocked = true -- 1242
		end -- 1242
	end -- 1242
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 1245
	self.waterSeen = story.segments.water_lantern == true -- 1247
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 1247
		self:applyCheckpointSnap(self.checkpoint) -- 1250
	end -- 1250
	if self.room.key == "tower" and story.route == "soldier" then -- 1250
		self.carryOn = false -- 1254
		self.run.story.carry = false -- 1255
		self.player.w = SOLDIER_W -- 1256
		self.player.h = SOLDIER_H -- 1257
		self.player.x = math.max(self.ox + 422, self.player.x) -- 1258
		self.partner = { -- 1259
			x = math.max(self.ox + 408, self.player.x - 24), -- 1260
			y = 0, -- 1261
			depth = 0, -- 1262
			depthSpeed = 0, -- 1263
			vx = 0, -- 1264
			vy = 0, -- 1265
			w = CHILD_W, -- 1266
			h = CHILD_H, -- 1267
			onGround = true, -- 1268
			facing = 1, -- 1269
			crouch = false, -- 1270
			rollT = 0, -- 1271
			covered = false, -- 1272
			alive = true -- 1273
		} -- 1273
	end -- 1273
	if self.room.key == "tower" then -- 1273
		if story.segments.tower_door == true then -- 1273
			self:openTowerDoor() -- 1279
		end -- 1279
		self.towerHanded = story.segments.tower_handover == true -- 1281
		self.deskHold = 0 -- 1282
		if story.phase == "tower-enter" or story.phase == "tower-desk" or story.phase == "tower-given" then -- 1282
			self.phase = story.phase -- 1284
			self.phaseTick = 0 -- 1285
			if story.phase == "tower-desk" or story.phase == "tower-given" then -- 1285
				self.player.x = self.ox + 605 -- 1287
				self.player.y = 0 -- 1288
				if story.route == "soldier" and self.partner.alive then -- 1288
					self.partner.x = self.ox + 568 -- 1290
					self.partner.y = 0 -- 1291
					self.partner.facing = 1 -- 1292
				end -- 1292
			end -- 1292
		end -- 1292
	end -- 1292
	if self.room.key == "prologue" then -- 1292
		local ph = story.phase -- 1299
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 1299
			self.phase = ph -- 1301
			self.phaseTick = story.phaseTick -- 1302
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 1303
			self.player.y = 0 -- 1304
			self.player.depth = 0 -- 1305
			self.player.vx = 0 -- 1306
			self.partner.x = self.ox + 300 -- 1307
			self.partner.y = 0 -- 1308
			self.partner.depth = 0 -- 1309
			self.partner.vx = 0 -- 1310
			self.partner.alive = true -- 1311
			if ph == "prologue-follow" then -- 1311
				self.partner.crouch = false -- 1313
				self.partner.h = CHILD_H -- 1314
			else -- 1314
				self.partner.crouch = true -- 1316
				self.partner.h = CHILD_CROUCH_H -- 1317
			end -- 1317
			self.cam.x = self.player.x -- 1319
		end -- 1319
		return -- 1321
	end -- 1321
	if self.room.key ~= "gate" then -- 1321
		return -- 1324
	end -- 1324
	local ____temp_51 -- 1326
	if self.room.story == nil then -- 1326
		____temp_51 = nil -- 1326
	else -- 1326
		____temp_51 = self.room.story.gate -- 1326
	end -- 1326
	local g = ____temp_51 -- 1326
	if g == nil then -- 1326
		return -- 1328
	end -- 1328
	if story.phase == "gate-send" then -- 1328
		self.phase = "gate-send" -- 1332
		self.gateTick = g.holdTicks -- 1333
		self.gateSpawned = 4 -- 1334
		self.enemies = {} -- 1335
		self.player.x = self.ox + g.doorX - 40 -- 1336
		self.player.y = 0 -- 1337
		self.player.depth = 0 -- 1338
		self.player.vx = 0 -- 1339
		self.player.vy = 0 -- 1340
		self.player.onGround = true -- 1341
		self.partner.x = self.ox + g.waitX -- 1342
		self.partner.y = 0 -- 1343
		self.partner.depth = 0 -- 1344
		self.partner.alive = true -- 1345
		self.cam.x = self.player.x -- 1346
		self.handTicks = 0 -- 1347
		self.handArmed = false -- 1348
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1349
		return -- 1350
	end -- 1350
	if not story.settled then -- 1350
		return -- 1353
	end -- 1353
	self.gateTick = g.holdTicks -- 1356
	self.gateSpawned = 4 -- 1357
	self.enemies = {} -- 1358
	if story.phase == "gate-farewell" or story.phase == "gate-count" or story.phase == "gate-walk" then -- 1358
		self.phase = story.phase == "gate-farewell" and "gate-count" or story.phase -- 1360
		self.countTick = story.phase == "gate-farewell" and 0 or math.max(story.countTick, 0) -- 1361
		self:swapToChild(g.doorX + 30) -- 1362
		self.countPrevMove = 0 -- 1363
		self.countArmed = false -- 1364
		return -- 1365
	end -- 1365
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1365
		self.phase = story.phase -- 1368
		self.countTick = ____exports.GATE_COUNT_END -- 1369
		self.phaseTick = story.phaseTick -- 1370
		self:swapToChild(g.doorX + 30) -- 1371
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1372
			0, -- 1372
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1372
		) -- 1372
		self.handArmed = false -- 1373
	end -- 1373
end -- 1211
function Play.prototype.buildWorld(self) -- 1378
	local room = self.room -- 1379
	self.boxes = {} -- 1380
	self.floors = {} -- 1381
	local i = 0 -- 1382
	do -- 1382
		i = 0 -- 1383
		while i < #room.floors do -- 1383
			local f = room.floors[i + 1] -- 1384
			local ____self_floors_52 = self.floors -- 1384
			____self_floors_52[#____self_floors_52 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1385
			i = i + 1 -- 1383
		end -- 1383
	end -- 1383
	do -- 1383
		i = 0 -- 1387
		while i < #room.solids do -- 1387
			local s = room.solids[i + 1] -- 1388
			if not s.decorative then -- 1388
				local ____self_boxes_64 = self.boxes -- 1394
				local ____s_x_55 = s.x -- 1395
				local ____temp_56 = s.x + s.w -- 1395
				local ____s_y_57 = s.y -- 1395
				local ____temp_58 = s.y + s.h -- 1395
				local ____temp_53 -- 1396
				if room.depth == nil then -- 1396
					____temp_53 = nil -- 1396
				else -- 1396
					____temp_53 = s.depth -- 1396
				end -- 1396
				local ____temp_59 = s.passable == true -- 1397
				local ____s_label_60 = s.label -- 1397
				local ____s_id_61 = s.id -- 1398
				local ____temp_62 = s.soft == true -- 1398
				local ____temp_63 = s.hidden == true -- 1398
				local ____temp_54 -- 1399
				if s.breakable == nil then -- 1399
					____temp_54 = nil -- 1399
				else -- 1399
					____temp_54 = __TS__ObjectAssign({}, s.breakable) -- 1399
				end -- 1399
				____self_boxes_64[#____self_boxes_64 + 1] = { -- 1394
					x0 = ____s_x_55, -- 1395
					x1 = ____temp_56, -- 1395
					y0 = ____s_y_57, -- 1395
					y1 = ____temp_58, -- 1395
					depth = ____temp_53, -- 1396
					passable = ____temp_59, -- 1397
					label = ____s_label_60, -- 1397
					id = ____s_id_61, -- 1398
					soft = ____temp_62, -- 1398
					hidden = ____temp_63, -- 1398
					breakable = ____temp_54, -- 1399
					interact = s.interact -- 1400
				} -- 1400
			end -- 1400
			i = i + 1 -- 1387
		end -- 1387
	end -- 1387
	do -- 1387
		i = 0 -- 1404
		while i < #room.stairs do -- 1404
			local st = room.stairs[i + 1] -- 1405
			local n = st.steps + 1 -- 1406
			local stepW = (st.x1 - st.x0) / n -- 1407
			local k = 0 -- 1408
			do -- 1408
				k = 0 -- 1409
				while k < n do -- 1409
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1410
					local x0 = st.x0 + stepW * k -- 1411
					local ____self_boxes_68 = self.boxes -- 1414
					local ____temp_66 = x0 + stepW -- 1415
					local ____temp_67 = -8 -- 1415
					local ____temp_65 -- 1416
					if room.depth == nil then -- 1416
						____temp_65 = nil -- 1416
					else -- 1416
						____temp_65 = st.depth -- 1416
					end -- 1416
					____self_boxes_68[#____self_boxes_68 + 1] = { -- 1414
						x0 = x0, -- 1415
						x1 = ____temp_66, -- 1415
						y0 = ____temp_67, -- 1415
						y1 = y, -- 1415
						depth = ____temp_65, -- 1416
						passable = true -- 1417
					} -- 1417
					k = k + 1 -- 1409
				end -- 1409
			end -- 1409
			i = i + 1 -- 1404
		end -- 1404
	end -- 1404
end -- 1378
function Play.prototype.setupCampaign(self) -- 1427
	local wr = self.room -- 1428
	local c = wr.campaign -- 1429
	if c == nil then -- 1429
		return -- 1431
	end -- 1431
	self.roomStartTick = self.run.ticks -- 1433
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1433
		self.run.joined = true -- 1437
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1437
		local ____self_run_73 = self.run -- 1440
		local ____temp_72 -- 1440
		if wr.key == "s2-drygoods" then -- 1440
			local ____temp_71 = self.run.route ~= "drygoods" -- 1441
			if not ____temp_71 then -- 1441
				local ____opt_69 = self.run.props.s2_board -- 1441
				____temp_71 = (____opt_69 and ____opt_69.broken) == true -- 1441
			end -- 1441
			____temp_72 = ____temp_71 -- 1441
		else -- 1441
			____temp_72 = wr.key == "c1-yard" and self.run.c1Latch -- 1442
		end -- 1442
		____self_run_73.joined = ____temp_72 -- 1440
	end -- 1440
	local x = wr.minX + 60 -- 1444
	local y = 0 -- 1445
	local depth = 0 -- 1446
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1446
		x = wr.minX + 210 -- 1448
		depth = -32 -- 1449
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1449
		x = wr.minX + 40 -- 1451
		y = 32 -- 1452
		depth = 32 -- 1453
	end -- 1453
	self.player = { -- 1455
		x = x, -- 1456
		y = y, -- 1456
		depth = depth, -- 1456
		depthSpeed = 0, -- 1456
		vx = 0, -- 1456
		vy = 0, -- 1456
		w = SOLDIER_W, -- 1457
		h = SOLDIER_H, -- 1457
		onGround = y <= 0, -- 1457
		facing = 1, -- 1457
		crouch = false, -- 1457
		rollT = 0, -- 1457
		covered = false, -- 1457
		alive = true -- 1457
	} -- 1457
	self.partner = { -- 1459
		x = x + 60, -- 1460
		y = y, -- 1460
		depth = depth, -- 1460
		depthSpeed = 0, -- 1460
		vx = 0, -- 1460
		vy = 0, -- 1460
		w = CHILD_W, -- 1461
		h = CHILD_H, -- 1461
		onGround = y <= 0, -- 1461
		facing = 1, -- 1461
		crouch = false, -- 1461
		rollT = 0, -- 1461
		covered = false, -- 1461
		alive = true -- 1461
	} -- 1461
	self.cam.x = x -- 1463
	self.cam.y = y + CAM_LOOK_UP -- 1464
	self.phase = "run" -- 1465
	self.hp = self.maxHp -- 1466
	if self:isEscortRoom() and self.run.story.route == "soldier" then -- 1466
		if self.run.story.talents == nil then -- 1466
			self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 1469
		end -- 1469
		local st = self.run.story.talents -- 1471
		local variants = ESCORT_VARIANTS[wr.key] -- 1472
		if self.run.source ~= "debug" and variants ~= nil and #variants > 0 then -- 1472
			st.variant = pickEscortVariant(self.run.seed, st.attempt, wr.key, #variants) -- 1474
		else -- 1474
			st.variant = 0 -- 1476
		end -- 1476
		if wr.key == "escort3" then -- 1476
			if st.room ~= "escort3" then -- 1476
				st.room = "escort3" -- 1482
				st.deferred = true -- 1483
				st.offers = {} -- 1484
			end -- 1484
		else -- 1484
			draftTalentOffers(st, wr.key, self.equippedWeapon) -- 1487
		end -- 1487
	end -- 1487
	self:buildEnemies() -- 1490
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1491
	local i = 0 -- 1492
	do -- 1492
		i = 0 -- 1493
		while i < #self.boxes do -- 1493
			do -- 1493
				local b = self.boxes[i + 1] -- 1494
				if b.id == nil then -- 1494
					goto __continue160 -- 1496
				end -- 1496
				local st = self.run.props[b.id] -- 1498
				if st ~= nil then -- 1498
					b.broken = st.broken -- 1500
					local ____temp_74 -- 1501
					if b.breakable == nil then -- 1501
						____temp_74 = nil -- 1501
					else -- 1501
						____temp_74 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1501
					end -- 1501
					b.breakable = ____temp_74 -- 1501
					b.hidden = b.hidden == true and st.revealed ~= true -- 1502
					if b.hidden then -- 1502
						b.broken = true -- 1504
					end -- 1504
				elseif b.hidden == true then -- 1504
					b.broken = true -- 1508
				end -- 1508
			end -- 1508
			::__continue160:: -- 1508
			i = i + 1 -- 1493
		end -- 1493
	end -- 1493
	if wr.cart.bodyW > 0 then -- 1493
		self.cartAxle = wr.cart.startX -- 1512
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1512
			self.cartAxle = wr.cart.endX -- 1514
			self.cartDocked = true -- 1515
		end -- 1515
	end -- 1515
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1518
end -- 1427
function Play.prototype.log(self, line) -- 1521
	local ____self_run_log_75 = self.run.log -- 1521
	____self_run_log_75[#____self_run_log_75 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1522
	if #self.run.log > 120 then -- 1522
		table.remove(self.run.log, 1) -- 1524
	end -- 1524
end -- 1521
function Play.prototype.buildEnemies(self) -- 1528
	self.enemies = {} -- 1529
	if self.isCampaign then -- 1529
		local variants = ESCORT_VARIANTS[self.room.key] -- 1531
		local useVariant = self:isEscortRoom() and self.run.story.route == "soldier" and self.run.source ~= "debug" and variants ~= nil and #variants > 0 -- 1532
		local ____useVariant_79 -- 1537
		if useVariant then -- 1537
			local ____temp_78 = #variants - 1 -- 1538
			local ____opt_76 = self.run.story.talents -- 1538
			____useVariant_79 = math.max( -- 1538
				0, -- 1538
				math.min(____temp_78, ____opt_76 and ____opt_76.variant or 0) -- 1538
			) -- 1538
		else -- 1538
			____useVariant_79 = 0 -- 1539
		end -- 1539
		local vIdx = ____useVariant_79 -- 1537
		local spawnList = useVariant and variants[vIdx + 1] or self.room.spawns -- 1540
		local i = 0 -- 1541
		do -- 1541
			i = 0 -- 1542
			while i < #spawnList do -- 1542
				local sp = spawnList[i + 1] -- 1543
				local kind = sp.kind or "gunner" -- 1544
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1545
				local sx = useVariant and self.ox + sp.x or sp.x -- 1546
				local ____self_enemies_80 = self.enemies -- 1546
				____self_enemies_80[#____self_enemies_80 + 1] = { -- 1547
					x = sx, -- 1548
					y = sp.y, -- 1548
					depth = sp.depth, -- 1548
					w = 26, -- 1548
					h = sp.h, -- 1548
					alive = true, -- 1548
					hitT = 0, -- 1548
					warnT = 0, -- 1548
					fireCd = 40, -- 1548
					kind = kind, -- 1549
					shieldHp = hp, -- 1549
					shieldHpMax = hp, -- 1549
					drop = sp.drop or "none", -- 1549
					homeX = sx, -- 1550
					swingT = 0, -- 1550
					awake = false, -- 1550
					squad = i -- 1550
				} -- 1550
				i = i + 1 -- 1542
			end -- 1542
		end -- 1542
		return -- 1553
	end -- 1553
	if self.room.key == "checkpoint" then -- 1553
		local ____self_enemies_81 = self.enemies -- 1553
		____self_enemies_81[#____self_enemies_81 + 1] = { -- 1556
			x = self.ox + 430, -- 1556
			y = 0, -- 1556
			w = 26, -- 1556
			h = 84, -- 1556
			alive = true, -- 1556
			hitT = 0, -- 1556
			warnT = 0, -- 1556
			fireCd = 0 -- 1556
		} -- 1556
		local ____self_enemies_82 = self.enemies -- 1556
		____self_enemies_82[#____self_enemies_82 + 1] = { -- 1557
			x = self.ox + 505, -- 1557
			y = 0, -- 1557
			w = 26, -- 1557
			h = 84, -- 1557
			alive = true, -- 1557
			hitT = 0, -- 1557
			warnT = 0, -- 1557
			fireCd = 0 -- 1557
		} -- 1557
		return -- 1558
	end -- 1558
	if self.room.key == "street" then -- 1558
		local ____self_enemies_83 = self.enemies -- 1558
		____self_enemies_83[#____self_enemies_83 + 1] = { -- 1562
			x = self.ox + 340, -- 1562
			y = 0, -- 1562
			w = 26, -- 1562
			h = 84, -- 1562
			alive = true, -- 1562
			hitT = 0, -- 1562
			warnT = 0, -- 1562
			fireCd = 0 -- 1562
		} -- 1562
		local ____self_enemies_84 = self.enemies -- 1562
		____self_enemies_84[#____self_enemies_84 + 1] = { -- 1563
			x = self.ox + 560, -- 1563
			y = 0, -- 1563
			w = 26, -- 1563
			h = 84, -- 1563
			alive = true, -- 1563
			hitT = 0, -- 1563
			warnT = 0, -- 1563
			fireCd = 0 -- 1563
		} -- 1563
	end -- 1563
end -- 1528
function Play.prototype.emit(self, name, data) -- 1569
	local ____self_events_85 = self.events -- 1569
	____self_events_85[#____self_events_85 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1570
	self.eventSeq = self.eventSeq + 1 -- 1571
	if #self.events > 256 then -- 1571
		table.remove(self.events, 1) -- 1573
	end -- 1573
end -- 1569
function Play.prototype.drainEvents(self) -- 1581
	local out = self.events -- 1582
	self.events = {} -- 1583
	return out -- 1584
end -- 1581
function Play.prototype.adoptEvents(self, events) -- 1593
	if #events == 0 then -- 1593
		return -- 1595
	end -- 1595
	local keep = {} -- 1597
	local i = 0 -- 1598
	do -- 1598
		i = 0 -- 1599
		while i < #events do -- 1599
			do -- 1599
				local e = events[i + 1] -- 1600
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1600
					goto __continue181 -- 1602
				end -- 1602
				keep[#keep + 1] = e -- 1604
			end -- 1604
			::__continue181:: -- 1604
			i = i + 1 -- 1599
		end -- 1599
	end -- 1599
	if #keep == 0 then -- 1599
		return -- 1607
	end -- 1607
	self.events = __TS__ArrayConcat(keep, self.events) -- 1609
	do -- 1609
		i = 0 -- 1610
		while i < #self.events do -- 1610
			self.events[i + 1].seq = i -- 1611
			i = i + 1 -- 1610
		end -- 1610
	end -- 1610
	self.eventSeq = #self.events -- 1613
end -- 1593
function Play.prototype.talentRank(self, talent) -- 1616
	if self.storyRoute == "soldier" and self:isEscortRoom() and self.run.story.talents ~= nil then -- 1616
		return self.run.story.talents.ranks[talent] or 0 -- 1618
	end -- 1618
	return 0 -- 1620
end -- 1616
function Play.prototype.reloadNeedTicks(self) -- 1624
	return RELOAD_ANSWER_TICKS + 60 * self:talentRank("focus") -- 1625
end -- 1624
function Play.prototype.getStoryTalentOffers(self) -- 1629
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1629
		return {} -- 1631
	end -- 1631
	local st = self.run.story.talents -- 1633
	return st ~= nil and st.room == self.room.key and st.offers or ({}) -- 1634
end -- 1629
function Play.prototype.getStoryTalentRanks(self) -- 1638
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() then -- 1638
		return nil -- 1640
	end -- 1640
	return self.run.story.talents ~= nil and self.run.story.talents.ranks or nil -- 1642
end -- 1638
function Play.prototype.getEscortAttempt(self) -- 1646
	return self.run.story.talents ~= nil and math.max(1, self.run.story.talents.attempt) or 1 -- 1647
end -- 1646
function Play.prototype.chooseTalent(self, slot) -- 1650
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1650
		return false -- 1652
	end -- 1652
	local st = self.run.story.talents -- 1654
	local talent = st ~= nil and st.offers[slot + 1] or nil -- 1655
	if st == nil or talent == nil then -- 1655
		return false -- 1657
	end -- 1657
	st.ranks[talent] = (st.ranks[talent] or 0) + 1 -- 1659
	st.offers = {} -- 1660
	self.talentModalActive = false -- 1661
	local extraMsg = "" -- 1662
	if talent == "vitality" then -- 1662
		self.maxHp = self.maxHp + 1 -- 1664
		self.hp = self.hp + 1 -- 1665
		self.run.story.maxHp = self.maxHp -- 1666
		self.run.story.hp = self.hp -- 1667
	elseif talent == "salvage" then -- 1667
		local inv = self.run.inventory -- 1669
		if inv.wood < 2 and inv.wood <= inv.bell or inv.bell >= 1 and st.ranks.salvage % 2 == 1 then -- 1669
			inv.wood = inv.wood + 1 -- 1671
			extraMsg = " · 得木纹筹×1" -- 1672
		else -- 1672
			inv.bell = inv.bell + 1 -- 1674
			extraMsg = " · 得铃纹筹×1" -- 1675
		end -- 1675
		self:syncCraftBench() -- 1677
	end -- 1677
	self.sessionDirty = true -- 1679
	self:flashSet(("本领 · " .. talentNames[talent]) .. extraMsg, 1.5) -- 1680
	self:emit("storyBeat", {beat = "talent_picked", talent = talent, rank = st.ranks[talent], room = self.room.key}) -- 1681
	return true -- 1682
end -- 1650
function Play.prototype.beginReload(self) -- 1689
	self.reloadT = self:reloadTicks() -- 1690
	local camp = self.room.campaign -- 1691
	if camp ~= nil and camp.reloadPuzzle == true then -- 1691
		self:openReloadPuzzle() -- 1693
	end -- 1693
end -- 1689
function Play.prototype.openReloadPuzzle(self) -- 1698
	self.reloadOpen = true -- 1699
	self.reloadAnswerTicks = 0 -- 1700
	self.reloadWorldTicks = 0 -- 1701
	self.reloadPath = {RELOAD_START} -- 1702
	self.reloadPendingEffect = "" -- 1703
	self.reloadTryCount = self.reloadTryCount + 1 -- 1704
	self:emit( -- 1705
		"reloadOpen", -- 1705
		{ -- 1705
			tryCount = self.reloadTryCount, -- 1705
			needTicks = self:reloadNeedTicks() -- 1705
		} -- 1705
	) -- 1705
end -- 1698
function Play.prototype.closeReloadPuzzle(self) -- 1709
	self.reloadOpen = false -- 1710
	self.reloadAnswerTicks = 0 -- 1711
	self.reloadWorldTicks = 0 -- 1712
	self.reloadPath = {RELOAD_START} -- 1713
	self.reloadPendingEffect = "" -- 1714
end -- 1709
function Play.prototype.reloadTapNode(self, node) -- 1721
	if not self.reloadOpen then -- 1721
		return -- 1723
	end -- 1723
	local path = self.reloadPath -- 1725
	local last = path[#path] -- 1726
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1726
		self.reloadPath = {RELOAD_START} -- 1728
		self:emit("reloadInvalid", {node = node, at = last}) -- 1729
		return -- 1730
	end -- 1730
	path[#path + 1] = node -- 1732
	if node ~= RELOAD_TARGET then -- 1732
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1734
		return -- 1735
	end -- 1735
	if not reloadPathValid(path) then -- 1735
		self.reloadPath = {RELOAD_START} -- 1738
		self:emit("reloadInvalid", {node = node, at = last}) -- 1739
		return -- 1740
	end -- 1740
	self.reloadPendingEffect = reloadEffectOf(path) -- 1742
	self.reloadOpen = false -- 1743
	self.reloadT = 0 -- 1744
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1745
	self:flashSet( -- 1748
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1748
		1.4 -- 1748
	) -- 1748
end -- 1721
function Play.prototype.consumeReloadEffect(self) -- 1752
	local e = self.reloadPendingEffect -- 1753
	if e ~= "" then -- 1753
		self.reloadPendingEffect = "" -- 1755
	end -- 1755
	return e -- 1757
end -- 1752
function Play.prototype.echoToSource(self, from, count, delayTicks) -- 1764
	if count == nil then -- 1764
		count = 1 -- 1764
	end -- 1764
	if delayTicks == nil then -- 1764
		delayTicks = 60 -- 1764
	end -- 1764
	local best = -1 -- 1765
	local bestD = 1000000000 -- 1766
	local i = 0 -- 1767
	local woken = {} -- 1768
	local n = 0 -- 1769
	while n < count do -- 1769
		best = -1 -- 1771
		bestD = 1000000000 -- 1772
		do -- 1772
			i = 0 -- 1773
			while i < #self.enemies do -- 1773
				do -- 1773
					if woken[i] == true then -- 1773
						goto __continue215 -- 1775
					end -- 1775
					local e = self.enemies[i + 1] -- 1777
					if not e.alive then -- 1777
						goto __continue215 -- 1779
					end -- 1779
					local d = math.abs(e.x - from.x) -- 1781
					if d < bestD then -- 1781
						bestD = d -- 1783
						best = i -- 1784
					end -- 1784
				end -- 1784
				::__continue215:: -- 1784
				i = i + 1 -- 1773
			end -- 1773
		end -- 1773
		if best < 0 then -- 1773
			break -- 1788
		end -- 1788
		woken[best] = true -- 1790
		local e = self.enemies[best + 1] -- 1791
		e.awake = true -- 1792
		e.warnT = 0 -- 1793
		e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 1794
		n = n + 1 -- 1795
	end -- 1795
	if n == 0 then -- 1795
		return -- 1798
	end -- 1798
	self:flashSet(n > 1 and "回声引到多处声源 · 敌群同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1800
end -- 1764
function Play.prototype.reloadTicks(self) -- 1803
	return math.max(6, self.run.inventory.quickbelt > 0 and 36 or 54) -- 1804
end -- 1803
function Play.prototype.update(self, dt, input) -- 1807
	self:syncCraftBench() -- 1808
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1808
		self:closeCraftBench() -- 1810
		return -- 1811
	end -- 1811
	if input.pause.pressed then -- 1811
		self.paused = not self.paused -- 1814
	end -- 1814
	if self.flashT > 0 then -- 1814
		self.flashT = self.flashT - dt -- 1817
		if self.flashT <= 0 then -- 1817
			self.flash = "" -- 1819
		end -- 1819
	end -- 1819
	if self.traceT > 0 then -- 1819
		self.traceT = self.traceT - dt -- 1823
		if self.traceT <= 0 then -- 1823
			self.trace = nil -- 1825
		end -- 1825
	end -- 1825
	if self.paused then -- 1825
		self:updateCamera(dt) -- 1829
		return -- 1830
	end -- 1830
	if self.escortFailed then -- 1830
		self.escortFailedTicks = self.escortFailedTicks + 1 -- 1834
		self:updateCamera(dt) -- 1835
		return -- 1836
	end -- 1836
	if self.craftBench.active then -- 1836
		self:updateCamera(dt) -- 1841
		return -- 1842
	end -- 1842
	if self.talentModalActive and #self:getStoryTalentOffers() > 0 and not self.reloadOpen then -- 1842
		self:updateCamera(dt) -- 1846
		return -- 1847
	end -- 1847
	if self.reloadOpen then -- 1847
		local needTicks = self:reloadNeedTicks() -- 1853
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1854
		if self.reloadAnswerTicks > needTicks then -- 1854
			self.reloadOpen = false -- 1856
			self.reloadPendingEffect = "" -- 1857
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = needTicks}) -- 1858
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1859
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1859
			self:updateCamera(dt) -- 1861
			return -- 1862
		else -- 1862
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1864
		end -- 1864
	end -- 1864
	self.ticks = self.ticks + 1 -- 1868
	if self.invulnT > 0 then -- 1868
		self.invulnT = self.invulnT - 1 -- 1872
	end -- 1872
	if self.isCampaign then -- 1872
		local ____self_run_86, ____ticks_87 = self.run, "ticks" -- 1872
		____self_run_86[____ticks_87] = ____self_run_86[____ticks_87] + 1 -- 1875
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1876
	end -- 1876
	local p = self.player -- 1878
	self:stepPlayer(p, dt, input) -- 1879
	self:refreshCover(p, input) -- 1881
	if self.carryOn then -- 1881
		self:carryPose() -- 1883
	end -- 1883
	if self.isCampaign then -- 1883
		self:stepCampaign(dt, input) -- 1886
		if not self.carryOn then -- 1886
			self:stepCampaignPartner(dt) -- 1888
		end -- 1888
	end -- 1888
	self:stepEnemies(dt, input) -- 1893
	if not self.isCampaign then -- 1893
		self:stepStory(dt, input) -- 1895
		self:stepEscort(dt, input) -- 1896
		self:stepVillage(dt, input) -- 1897
		self:stepChase(dt, input) -- 1898
		self:stepInteract(dt, input) -- 1899
	end -- 1899
	self:updateGate() -- 1901
	self:updateCamera(dt) -- 1902
	self:syncStory() -- 1904
end -- 1807
function Play.prototype.underLowArch(self, a) -- 1911
	local arch = self.room.arch -- 1912
	if arch.h <= 0 then -- 1912
		return false -- 1914
	end -- 1914
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1914
		return false -- 1917
	end -- 1917
	local top = arch.y + arch.h -- 1919
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1920
end -- 1911
function Play.prototype.coverAt(self, a) -- 1927
	local best = nil -- 1928
	local bestGap = 24 -- 1929
	local half = a.w / 2 -- 1930
	local i = 0 -- 1931
	do -- 1931
		i = 0 -- 1932
		while i < #self.boxes do -- 1932
			do -- 1932
				local b = self.boxes[i + 1] -- 1933
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1933
					goto __continue248 -- 1935
				end -- 1935
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1935
					goto __continue248 -- 1938
				end -- 1938
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1940
				if gap < bestGap then -- 1940
					bestGap = gap -- 1942
					best = b -- 1943
				end -- 1943
			end -- 1943
			::__continue248:: -- 1943
			i = i + 1 -- 1932
		end -- 1932
	end -- 1932
	return best -- 1946
end -- 1927
function Play.prototype.nearCover(self, a) -- 1949
	return self:coverAt(a) ~= nil -- 1950
end -- 1949
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1954
	if enemy == nil then -- 1954
		return false -- 1956
	end -- 1956
	local fromRight = enemy.x >= a.x -- 1958
	local edge = fromRight and b.x0 or b.x1 -- 1959
	local ____fromRight_88 -- 1960
	if fromRight then -- 1960
		____fromRight_88 = edge >= a.x - 0.001 and edge <= enemy.x -- 1960
	else -- 1960
		____fromRight_88 = edge <= a.x + 0.001 and edge >= enemy.x -- 1961
	end -- 1961
	local between = ____fromRight_88 -- 1960
	local separation = enemy.x - a.x -- 1962
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1963
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1964
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1965
end -- 1954
function Play.prototype.nearestEnemy(self, a) -- 1968
	local best -- 1969
	local bestD = 1000000000 -- 1970
	local i = 0 -- 1971
	do -- 1971
		i = 0 -- 1972
		while i < #self.enemies do -- 1972
			do -- 1972
				local e = self.enemies[i + 1] -- 1973
				if not e.alive then -- 1973
					goto __continue257 -- 1975
				end -- 1975
				local d = math.abs(e.x - a.x) -- 1977
				if d < bestD then -- 1977
					bestD = d -- 1979
					best = e -- 1980
				end -- 1980
			end -- 1980
			::__continue257:: -- 1980
			i = i + 1 -- 1972
		end -- 1972
	end -- 1972
	return best -- 1983
end -- 1968
function Play.prototype.refreshCover(self, a, input) -- 1987
	if self.childMode then -- 1987
		self.coverNear = false -- 1989
		self.coverHug = false -- 1990
		self.coverEntity = "" -- 1991
		self.coverBlocking = false -- 1992
		a.covered = false -- 1993
		return -- 1994
	end -- 1994
	local b = self:coverAt(a) -- 1996
	self.coverNear = b ~= nil -- 1997
	a.covered = self.coverNear and input.cover.held -- 1998
	self.coverHug = a.covered -- 1999
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 2000
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 2001
		b, -- 2001
		a, -- 2001
		self:nearestEnemy(a) -- 2001
	) -- 2001
end -- 1987
function Play.prototype.cartHandleInReach(self, a) -- 2005
	if a == nil then -- 2005
		a = self.player -- 2005
	end -- 2005
	local c = self.room.cart -- 2006
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 2006
		return false -- 2008
	end -- 2008
	local handleX = self.cartAxle + c.handleOffset -- 2010
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 2011
end -- 2005
function Play.prototype.nearLowLedge(self, a) -- 2016
	local reach = 26 -- 2017
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 2018
	local x1 = x0 + reach -- 2019
	local i = 0 -- 2020
	do -- 2020
		i = 0 -- 2021
		while i < #self.boxes do -- 2021
			do -- 2021
				local b = self.boxes[i + 1] -- 2022
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2022
					goto __continue266 -- 2024
				end -- 2024
				local rise = b.y1 - a.y -- 2026
				if rise > 0 and rise <= LEDGE_RISE then -- 2026
					return true -- 2028
				end -- 2028
			end -- 2028
			::__continue266:: -- 2028
			i = i + 1 -- 2021
		end -- 2021
	end -- 2021
	return false -- 2031
end -- 2016
function Play.prototype.stepPlayer(self, a, dt, input) -- 2034
	a.depthSpeed = 0 -- 2035
	if not a.alive then -- 2035
		return -- 2037
	end -- 2037
	local isChild = self.childMode -- 2039
	local lowArch = isChild and self:underLowArch(a) -- 2041
	if self:storyLocked() then -- 2041
		a.vx = 0 -- 2044
		a.crouch = isChild and lowArch -- 2045
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2046
		self:fallY(a, dt) -- 2047
		return -- 2048
	end -- 2048
	if not isChild and self.escort.state == "calming" then -- 2048
		a.crouch = false -- 2052
		a.h = SOLDIER_H -- 2053
		a.vx = 0 -- 2054
		self:fallY(a, dt) -- 2055
		return -- 2056
	end -- 2056
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 2058
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 2059
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2060
	local nearCover = not isChild and self:nearCover(a) -- 2061
	a.covered = nearCover and input.cover.held -- 2062
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 2064
	if a.rollT > 0 then -- 2064
		a.rollT = a.rollT - dt -- 2068
		local rollSpd = self:isEscortRoom() and ROLL_SPEED * (1 + 0.08 * self:talentRank("stride")) or ROLL_SPEED -- 2069
		a.vx = a.facing * rollSpd -- 2070
		self:slideX(a, a.vx * dt) -- 2071
		self:fallY(a, dt) -- 2072
		if a.rollT <= 0 then -- 2072
			self:flashSet("翻滚结束", 0.5) -- 2074
		end -- 2074
		return -- 2076
	end -- 2076
	local peacefulRoom = self.room.key == "museum" or self.room.key == "tower" -- 2079
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 2079
		if input.moveX ~= 0 then -- 2079
			a.facing = input.moveX > 0 and 1 or -1 -- 2082
		end -- 2082
		if self:nearLowLedge(a) then -- 2082
			a.vy = SOLDIER_JUMP -- 2086
			a.onGround = false -- 2087
			self:flashSet("翻上去", 0.3) -- 2088
			return -- 2089
		end -- 2089
		a.rollT = ROLL_TIME -- 2091
		self:flashSet("翻滚", 0.3) -- 2092
		return -- 2093
	end -- 2093
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 2096
	if isChild then -- 2096
		if input.cover.held then -- 2096
			speed = CHILD_SLOW -- 2099
		end -- 2099
		if a.crouch then -- 2099
			speed = CHILD_SLOW -- 2102
		elseif self.room.key == "forest" and self.forestPath == "ditch" and a.x >= self.ox + 700 and a.x <= self.ox + 1140 then -- 2102
			speed = CHILD_SPEED * 1.22 -- 2106
		end -- 2106
	else -- 2106
		if self:isEscortRoom() then -- 2106
			speed = speed * (1 + 0.1 * self:talentRank("stride")) -- 2110
		end -- 2110
		if a.covered then -- 2110
			speed = speed * 0.45 -- 2113
		end -- 2113
	end -- 2113
	local handsBusy = self.gripping or gripIntent or self.reloadOpen -- 2118
	local dir = (self.gripping or self.reloadOpen) and 0 or input.moveX -- 2119
	local depthDir = self.room.depth ~= nil and not handsBusy and (not isChild or self.phase == "prologue-escape") and -input.moveY or 0 -- 2121
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 2123
	if dir ~= 0 then -- 2123
		a.facing = dir > 0 and 1 or -1 -- 2125
	end -- 2125
	a.vx = dir * speed * diagonal -- 2127
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 2127
		a.vy = CHILD_JUMP -- 2131
		a.onGround = false -- 2132
		self:flashSet("跳", 0.25) -- 2133
	end -- 2133
	local previousDepth = a.depth -- 2137
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 2138
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2139
	self:slideX(a, a.vx * dt) -- 2140
	self:fallY(a, dt) -- 2141
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and not self.reloadOpen and input.fire.pressed then -- 2141
		self:shoot(a) -- 2145
	end -- 2145
	local ____temp_91 = not isChild and not peacefulRoom and not self.gripping and not self.reloadOpen and self.reloadPendingEffect == "" -- 2148
	if ____temp_91 then -- 2148
		local ____opt_89 = self.room.campaign -- 2148
		____temp_91 = (____opt_89 and ____opt_89.reloadPuzzle) == true -- 2148
	end -- 2148
	if ____temp_91 and input.flare.pressed then -- 2148
		self:beginReload() -- 2150
	end -- 2150
end -- 2034
function Play.prototype.stepPartner(self, p, dt) -- 2155
	local a = self.partner -- 2156
	if not a.alive then -- 2156
		return -- 2158
	end -- 2158
	a.crouch = false -- 2160
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 2161
	a.vx = 0 -- 2162
	a.depthSpeed = 0 -- 2163
	self:fallY(a, dt) -- 2164
end -- 2155
function Play.prototype.stepEscort(self, dt, input) -- 2171
	local a = self.partner -- 2172
	a.depthSpeed = 0 -- 2173
	if not a.alive then -- 2173
		return -- 2175
	end -- 2175
	if self.room.key == "gatepath" then -- 2175
		if self.carryOn then -- 2175
			return -- 2180
		end -- 2180
		local p = self.player -- 2183
		a.depth = p.depth -- 2184
		a.facing = p.facing -- 2185
		a.crouch = false -- 2186
		a.h = CHILD_H -- 2187
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 2188
		a.y = p.y -- 2189
		a.vy = 0 -- 2190
		a.vx = p.vx -- 2191
		a.onGround = p.onGround -- 2192
		return -- 2193
	end -- 2193
	if not self:escortOn() then -- 2193
		a.vx = 0 -- 2196
		self:fallY(a, dt) -- 2197
		return -- 2198
	end -- 2198
	local p = self.player -- 2200
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 2201
	local hadKnock1 = self.escort.knock1 -- 2202
	local hadKnock2 = self.escort.knock2 -- 2203
	self.calmConsumed = self.escort:update( -- 2204
		input, -- 2204
		p.x, -- 2204
		p.facing, -- 2204
		a.x, -- 2204
		dist -- 2204
	) -- 2204
	if not hadKnock1 and self.escort.knock1 then -- 2204
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 2207
	end -- 2207
	if not hadKnock2 and self.escort.knock2 then -- 2207
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 2210
	end -- 2210
	a.crouch = self.escort.crouchPose -- 2212
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 2213
	if not self.escort.stopped then -- 2213
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 2215
		local previousDepth = a.depth -- 2216
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 2217
		local distance = math.max( -- 2218
			-travel, -- 2218
			math.min(travel, targetDepth - previousDepth) -- 2218
		) -- 2218
		self:slideDepth(a, distance) -- 2219
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2220
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 2220
			a.vy = CHILD_JUMP -- 2222
			a.onGround = false -- 2223
		end -- 2223
	end -- 2223
	local dir = self.escort:moveDir(a.x) -- 2226
	a.vx = dir * CHILD_SPEED -- 2227
	if dir ~= 0 then -- 2227
		a.facing = dir -- 2229
		local before = a.x -- 2230
		self:slideX(a, dir * CHILD_SPEED * dt) -- 2231
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 2231
			a.vy = CHILD_JUMP -- 2234
			a.onGround = false -- 2235
		end -- 2235
	end -- 2235
	self:fallY(a, dt) -- 2238
end -- 2171
function Play.prototype.escortOn(self) -- 2242
	if self.room.key == "checkpoint" then -- 2242
		return true -- 2244
	end -- 2244
	if self.room.key == "gatepath" then -- 2244
		return true -- 2247
	end -- 2247
	if self.room.key == "prologue" then -- 2247
		return self.phase == "prologue-follow" -- 2250
	end -- 2250
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 2250
		return true -- 2254
	end -- 2254
	return self.room.key == "street" -- 2256
end -- 2242
function Play.prototype.storyLocked(self) -- 2260
	if self.caughtT > 0 then -- 2260
		return true -- 2262
	end -- 2262
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 2262
		return true -- 2266
	end -- 2266
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 2266
		return true -- 2269
	end -- 2269
	if self.room.key == "gate" and (self.phase == "gate-farewell" or self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 2269
		return true -- 2272
	end -- 2272
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2272
		return true -- 2275
	end -- 2275
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2275
		return true -- 2278
	end -- 2278
	if self.craftBench.active then -- 2278
		return true -- 2282
	end -- 2282
	return false -- 2284
end -- 2260
function Play.prototype.swapToChild(self, x) -- 2288
	local tmp = self.player -- 2289
	self.player = self.partner -- 2290
	self.partner = tmp -- 2291
	self.childMode = true -- 2292
	self.player.alive = true -- 2293
	self.player.x = self.ox + x -- 2294
	self.player.y = 0 -- 2295
	self.player.depth = 0 -- 2296
	self.player.depthSpeed = 0 -- 2297
	self.player.vy = 0 -- 2298
	self.player.vx = 0 -- 2299
	self.player.onGround = true -- 2300
	self.player.crouch = false -- 2301
	self.player.h = CHILD_H -- 2302
	self.player.facing = 1 -- 2303
	self.partner.alive = true -- 2304
	self.cam.x = self.player.x -- 2305
end -- 2288
function Play.prototype.swapToSoldier(self, x, childX) -- 2309
	local tmp = self.player -- 2310
	self.player = self.partner -- 2311
	self.partner = tmp -- 2312
	self.childMode = false -- 2313
	self.player.alive = true -- 2314
	self.player.x = self.ox + x -- 2315
	self.player.y = 0 -- 2316
	self.player.depth = 0 -- 2317
	self.player.depthSpeed = 0 -- 2318
	self.player.vy = 0 -- 2319
	self.player.vx = 0 -- 2320
	self.player.onGround = true -- 2321
	self.player.crouch = false -- 2322
	self.player.h = SOLDIER_H -- 2323
	self.player.facing = 1 -- 2324
	self.partner.alive = true -- 2325
	self.partner.x = self.ox + childX -- 2326
	self.partner.y = 0 -- 2327
	self.partner.depth = 0 -- 2328
	self.partner.depthSpeed = 0 -- 2329
	self.partner.vx = 0 -- 2330
	self.partner.vy = 0 -- 2331
	self.partner.onGround = true -- 2332
	self.partner.crouch = true -- 2333
	self.partner.h = CHILD_CROUCH_H -- 2334
	self.cam.x = self.player.x -- 2335
end -- 2309
function Play.prototype.stepStory(self, dt, input) -- 2339
	if self.room.key == "prologue" then -- 2339
		self:stepPrologue(dt, input) -- 2341
	elseif self.room.key == "street" then -- 2341
		self:stepStreet(dt, input) -- 2343
	elseif self.room.key == "gate" then -- 2343
		self:stepGate(dt, input) -- 2345
	elseif self.room.key == "gatepath" then -- 2345
		self:stepGatePath() -- 2347
	elseif self.room.key == "tower" then -- 2347
		self:stepTower(dt, input) -- 2349
	elseif self.room.key == "museum" then -- 2349
		self:stepMuseum(dt, input) -- 2351
	end -- 2351
end -- 2339
function Play.prototype.canPersistProgress(self) -- 2357
	return not self.isCampaign and self.run.source == "official" -- 2358
end -- 2357
function Play.prototype.wellWindow(self) -- 2362
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 2363
end -- 2362
function Play.prototype.nearWell(self) -- 2368
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 2369
end -- 2368
function Play.prototype.pickWell(self) -- 2377
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2377
		return false -- 2379
	end -- 2379
	self.phase = "prologue-well" -- 2381
	self.phaseTick = 0 -- 2382
	self.wellOpen = false -- 2383
	self:flashSet("井沿 · 伸手下去", 1.4) -- 2384
	self:log("旧井拾取") -- 2385
	return true -- 2386
end -- 2377
function Play.prototype.stepPrologue(self, dt, input) -- 2389
	local child = self.partner -- 2390
	if self.museumReturn then -- 2390
		self.museumReturn = false -- 2393
		self.phase = "prologue-wait" -- 2394
		self.phaseTick = 0 -- 2395
		self.player.x = self.ox + 260 -- 2396
		self.player.y = 0 -- 2397
		self.player.depth = 0 -- 2398
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2399
	end -- 2399
	if self.phase == "prologue-wake" then -- 2399
		self.introTick = self.introTick + 1 -- 2403
		if self.introTick == 60 then -- 2403
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2405
		end -- 2405
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2405
			self.phase = "prologue-shadow" -- 2408
			self.introTick = 0 -- 2409
			self:flashSet("门缝里两道影子", 1.2) -- 2410
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2411
		end -- 2411
		return -- 2413
	end -- 2413
	if self.phase == "prologue-shadow" then -- 2413
		self.introTick = self.introTick + 1 -- 2416
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2416
			self.phase = "prologue-escape" -- 2419
			self.introTick = 0 -- 2420
			self.escapeRemaining = self.escapeDuration -- 2421
			self.escapeRetryCount = 0 -- 2422
			self:swapToChild(100) -- 2423
			self:flashSet( -- 2424
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2424
				1.6 -- 2424
			) -- 2424
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2425
		end -- 2425
		return -- 2429
	end -- 2429
	if self.phase == "prologue-escape" then -- 2429
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2432
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2432
			self.phase = "prologue-hide" -- 2435
			self.introTick = 0 -- 2436
			self.player.vx = 0 -- 2437
			self.player.crouch = true -- 2438
			self.player.h = CHILD_CROUCH_H -- 2439
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2440
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2441
			return -- 2445
		end -- 2445
		if self.escapeRemaining <= 0 then -- 2445
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2449
			self.player.x = self.ox + 100 -- 2450
			self.player.y = 0 -- 2451
			self.player.depth = 0 -- 2452
			self.player.vx = 0 -- 2453
			self.player.vy = 0 -- 2454
			self.escapeRemaining = self.escapeDuration -- 2455
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2456
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2457
			return -- 2458
		end -- 2458
		return -- 2460
	end -- 2460
	if self.phase == "prologue-hide" then -- 2460
		self.introTick = self.introTick + 1 -- 2463
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2463
			self.phase = "prologue-wait" -- 2466
			self.phaseTick = 0 -- 2467
			self.introTick = 0 -- 2468
			self:swapToSoldier(260, 300) -- 2469
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2470
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2471
		end -- 2471
		return -- 2473
	end -- 2473
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2476
	if self.phase == "prologue-wait" then -- 2476
		child.crouch = true -- 2478
		child.h = CHILD_CROUCH_H -- 2479
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2479
			self:pickWell() -- 2481
			return -- 2482
		end -- 2482
		if not self.wellOpen and self:canPersistProgress() and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2482
			self.archive.museumPhase = "well_reflect" -- 2487
			self.archiveDirty = true -- 2488
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2489
			return -- 2490
		end -- 2490
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2492
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2494
		if near and input.interact.pressed then -- 2494
			self.phase = "prologue-give" -- 2496
			self.phaseTick = 0 -- 2497
			self:flashSet("递出针套", 1) -- 2498
		end -- 2498
		return -- 2500
	end -- 2500
	if self.phase == "prologue-well" then -- 2500
		self.phaseTick = self.phaseTick + 1 -- 2504
		if self.phaseTick == 12 then -- 2504
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2506
		elseif self.phaseTick >= 30 then -- 2506
			self.phase = "prologue-wait" -- 2508
			self.phaseTick = 0 -- 2509
			self.wellTaken = true -- 2510
			self.wellOpen = false -- 2511
			self.run.archive.artifactOwned = true -- 2512
			self.archiveDirty = true -- 2513
			self:emit("artifactFound", { -- 2514
				x = self.ox + self.wellX, -- 2515
				y = 0, -- 2515
				room = "prologue", -- 2515
				once = true, -- 2515
				source = self.run.source -- 2516
			}) -- 2516
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2518
			self:log("井底取到时间穿梭器") -- 2519
		end -- 2519
		return -- 2521
	end -- 2521
	if self.phase == "prologue-give" then -- 2521
		self.phaseTick = self.phaseTick + 1 -- 2524
		if self.phaseTick == 36 then -- 2524
			self:flashSet("针套递过去", 0.9) -- 2526
		elseif self.phaseTick == 108 then -- 2526
			self:flashSet("纸条塞进针套", 1) -- 2528
		elseif self.phaseTick >= ____exports.PROLOGUE_GIVE_TICKS then -- 2528
			self.phase = "prologue-follow" -- 2530
			self.phaseTick = 0 -- 2531
			child.crouch = false -- 2532
			child.h = CHILD_H -- 2533
			self:flashSet("她跟上了", 1.2) -- 2534
		end -- 2534
		return -- 2536
	end -- 2536
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2536
		local next = self.run.source == "debug" and "street" or "s1-crossroad" -- 2540
		self:requestRoom(next, "序章跟到门口") -- 2541
		self:flashSet(next == "s1-crossroad" and "进十字街" or "进街道", 1.2) -- 2542
	end -- 2542
end -- 2389
function Play.prototype.stepStreet(self, dt, input) -- 2547
	local p = self.player -- 2548
	local c = self.partner -- 2549
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2549
		local next = self.run.source == "debug" and "checkpoint" or "s1-crossroad" -- 2551
		self:requestRoom(next, "两人都到街尾") -- 2552
		self:flashSet(next == "s1-crossroad" and "进十字街" or "到检查站", 1.2) -- 2553
	end -- 2553
end -- 2547
function Play.prototype.stepGate(self, dt, input) -- 2558
	local ____temp_92 -- 2559
	if self.room.story == nil then -- 2559
		____temp_92 = nil -- 2559
	else -- 2559
		____temp_92 = self.room.story.gate -- 2559
	end -- 2559
	local g = ____temp_92 -- 2559
	if g == nil then -- 2559
		return -- 2561
	end -- 2561
	local p = self.player -- 2563
	if self.phase == "gate-idle" then -- 2563
		local a = self.partner -- 2566
		local gap = g.waitX - a.x -- 2567
		if math.abs(gap) > 3 then -- 2567
			a.facing = gap > 0 and 1 or -1 -- 2569
			a.vx = a.facing * CHILD_SPEED -- 2570
			local beforeX = a.x -- 2571
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2572
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2572
				a.vy = CHILD_JUMP -- 2574
				a.onGround = false -- 2575
			end -- 2575
			self:fallY(a, dt) -- 2577
		else -- 2577
			a.vx = 0 -- 2579
			a.x = g.waitX -- 2580
		end -- 2580
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2583
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2584
		if self.gateNeedConfirm then -- 2584
			if not input.interact.held then -- 2584
				self.gateRestartArmed = true -- 2589
			end -- 2589
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2589
				self.gateNeedConfirm = false -- 2592
				self.gateRestartArmed = true -- 2593
				self.phase = "gate-hold" -- 2594
				self.gateTick = 0 -- 2595
				self.gateSpawned = 0 -- 2596
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2597
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2598
			end -- 2598
			return -- 2600
		end -- 2600
		if atWinch and atWait then -- 2600
			self.phase = "gate-hold" -- 2603
			self.gateTick = 0 -- 2604
			self.gateSpawned = 0 -- 2605
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2606
		end -- 2606
		return -- 2608
	end -- 2608
	if self.phase == "gate-hold" then -- 2608
		self.gateTick = self.gateTick + 1 -- 2611
		local marks = {0, 540, 900, 1500} -- 2613
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2613
			local idx = self.gateSpawned -- 2615
			local ____self_enemies_93 = self.enemies -- 2615
			____self_enemies_93[#____self_enemies_93 + 1] = { -- 2616
				x = self.ox + 620 + idx * 62, -- 2617
				y = 0, -- 2617
				w = 26, -- 2617
				h = 84, -- 2617
				alive = true, -- 2618
				hitT = 0, -- 2618
				warnT = 0, -- 2618
				fireCd = 90 + idx * 45 -- 2618
			} -- 2618
			self.gateSpawned = self.gateSpawned + 1 -- 2620
			self:flashSet( -- 2621
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2621
				0.9 -- 2621
			) -- 2621
		end -- 2621
		if self.gateTick == 900 then -- 2621
			self:flashSet("棚布落下", 1) -- 2624
		elseif self.gateTick == 2100 then -- 2624
			self:flashSet("门底透进冷光了", 1) -- 2626
		end -- 2626
		if self.gateTick >= g.holdTicks then -- 2626
			self:captureGateBlood() -- 2631
			self.phase = "gate-send" -- 2632
			self.phaseTick = 0 -- 2633
			self.enemies = {} -- 2635
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2636
		end -- 2636
		return -- 2638
	end -- 2638
	if self.phase == "gate-send" then -- 2638
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2641
		if near and input.interact.pressed then -- 2641
			self:commitRoute() -- 2645
			self:swapToChild(g.doorX + 30) -- 2646
			self.phase = self.run.source == "debug" and "gate-count" or "gate-farewell" -- 2647
			self.phaseTick = 0 -- 2648
			self.countTick = 0 -- 2649
			self.countArmed = false -- 2651
			self.countPrevMove = input.moveX -- 2652
			self:flashSet("门开了 · 送她出去", 1.8) -- 2653
		end -- 2653
		return -- 2655
	end -- 2655
	if self.phase == "gate-farewell" then -- 2655
		self.phaseTick = self.phaseTick + 1 -- 2658
		self.countPrevMove = input.moveX -- 2659
		if self.phaseTick >= ____exports.GATE_FAREWELL_TICKS then -- 2659
			self.phase = "gate-count" -- 2661
			self.phaseTick = 0 -- 2662
			self.countTick = 0 -- 2663
			self.countArmed = false -- 2664
		end -- 2664
		return -- 2666
	end -- 2666
	if self.phase == "gate-count" then -- 2666
		self.countTick = self.countTick + 1 -- 2669
		if self.countTick == 360 then -- 2669
			self:flashSet("门关上", 0.9) -- 2671
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2671
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2673
			if self.storyRoute == "soldier" then -- 2673
				self.phase = "gate-wait" -- 2679
				self.phaseTick = 0 -- 2680
				self.knocks = 1 -- 2681
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2682
				self.handArmed = not input.interact.held and not self.intentGateReunionHold -- 2684
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2685
			else -- 2685
				self:flashSet("数到二十", 2.2) -- 2687
			end -- 2687
		end -- 2687
		local prevMove = self.countPrevMove -- 2692
		self.countPrevMove = input.moveX -- 2693
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2693
			if prevMove <= 0 and input.moveX > 0 then -- 2693
				self.countArmed = true -- 2696
			end -- 2696
			if self.countArmed and input.moveX > 0 then -- 2696
				self.phase = "gate-walk" -- 2699
				self.phaseTick = 0 -- 2700
				self:flashSet("她迈出第一步", 1.4) -- 2701
				self:emit("storyExit", { -- 2702
					route = "child", -- 2702
					via = "walk", -- 2702
					countTick = self.countTick, -- 2702
					hp = self.hp, -- 2702
					maxHp = self.maxHp -- 2702
				}) -- 2702
			end -- 2702
		end -- 2702
		return -- 2705
	end -- 2705
	if self.phase == "gate-wait" then -- 2705
		self.phaseTick = self.phaseTick + 1 -- 2709
		if self.phaseTick == 12 then -- 2709
			self.knocks = 2 -- 2711
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2712
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2713
		end -- 2713
		local held = input.interact.held or self.intentGateReunionHold -- 2715
		if not held then -- 2715
			if self.handTicks > 0 then -- 2715
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2718
			end -- 2718
			self.handTicks = 0 -- 2720
			self.handArmed = true -- 2721
			return -- 2722
		end -- 2722
		if self.handArmed then -- 2722
			self.handTicks = self.handTicks + 1 -- 2725
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2725
				self.intentGateReunionHold = false -- 2727
				self.phase = "gate-hand" -- 2728
				self.phaseTick = 0 -- 2729
				self.handDone = true -- 2730
				self.tied = true -- 2731
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2732
				if not self.lineSaid then -- 2732
					self.lineSaid = true -- 2734
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2735
				end -- 2735
				self:flashSet("我们走吧。", 3) -- 2737
			end -- 2737
		end -- 2737
		return -- 2740
	end -- 2740
	if self.phase == "gate-hand" then -- 2740
		self.phaseTick = self.phaseTick + 1 -- 2744
		if self.phaseTick == 30 then -- 2744
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2746
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2746
			self:emit("storyExit", { -- 2748
				route = "soldier", -- 2748
				via = "hand", -- 2748
				handTicks = self.handTicks, -- 2748
				hp = self.hp, -- 2748
				maxHp = self.maxHp -- 2748
			}) -- 2748
			self:requestRoom("gatepath", "牵手同行") -- 2749
		end -- 2749
		return -- 2751
	end -- 2751
	if self.phase == "gate-walk" then -- 2751
		if self.player.x >= g.exitX then -- 2751
			self:requestRoom("outside", "走出城门") -- 2756
			self:flashSet("出城门 · 城外", 1.4) -- 2757
		end -- 2757
	end -- 2757
end -- 2558
function Play.prototype.captureGateBlood(self) -- 2766
	self.hpAtGate = self.hp -- 2767
	self.maxHpAtGate = self.maxHp -- 2768
end -- 2766
function Play.prototype.commitRoute(self) -- 2775
	if self.storySettled then -- 2775
		return -- 2777
	end -- 2777
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2779
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2780
	self.hpAtGate = hp -- 2781
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2782
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2783
	self.storySettled = true -- 2784
	self.sessionDirty = true -- 2785
	self:emit("storyRouteLocked", { -- 2786
		route = self.storyRoute, -- 2787
		hp = self.hp, -- 2787
		maxHp = self.maxHp, -- 2787
		hpAtGate = self.hpAtGate, -- 2788
		maxHpAtGate = self.maxHpAtGate -- 2788
	}) -- 2788
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2790
end -- 2775
function Play.prototype.syncStory(self) -- 2794
	local s = self.run.story -- 2795
	if s == nil then -- 2795
		return -- 2797
	end -- 2797
	s.hp = self.hp -- 2799
	s.maxHp = self.maxHp -- 2800
	s.route = self.storyRoute -- 2801
	s.settled = self.storySettled -- 2802
	s.hpAtGate = self.hpAtGate -- 2803
	s.maxHpAtGate = self.maxHpAtGate -- 2804
	s.handDone = self.handDone -- 2805
	s.lineSaid = self.lineSaid -- 2806
	s.tied = self.tied -- 2807
	s.carry = self.carryOn -- 2808
	s.museumReturn = self.museumReturn -- 2809
	s.escortDone = self.escortDone -- 2810
	s.craftedWeapon = self.run.story.craftedWeapon -- 2811
	s.equippedWeapon = self.equippedWeapon -- 2812
	s.ending = self.run.story.ending -- 2813
	if self.room.key == "gate" then -- 2813
		s.phase = self.phase -- 2815
		s.countTick = self.countTick -- 2816
		s.phaseTick = self.phaseTick -- 2817
		s.handTicks = self.handTicks -- 2818
	end -- 2818
	if self.room.key == "prologue" then -- 2818
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2818
			s.phase = self.phase -- 2823
			s.phaseTick = self.phaseTick -- 2824
		end -- 2824
	end -- 2824
	if self.room.key == "tower" then -- 2824
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2824
			s.phase = self.phase -- 2830
			s.phaseTick = self.phaseTick -- 2831
		end -- 2831
	end -- 2831
end -- 2794
function Play.prototype.stepGatePath(self) -- 2837
	local ____temp_94 -- 2838
	if self.room.story == nil then -- 2838
		____temp_94 = nil -- 2838
	else -- 2838
		____temp_94 = self.room.story.gatepath -- 2838
	end -- 2838
	local gp = ____temp_94 -- 2838
	if self.phase == "gatepath-start" then -- 2838
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2838
			self.carryOn = true -- 2841
			self.phase = "gatepath-carry" -- 2842
			self.phaseTick = 0 -- 2843
			self.pathDone = true -- 2844
			self.escortDone = false -- 2845
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2846
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2847
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2848
		end -- 2848
		return -- 2850
	end -- 2850
	if self.phase == "gatepath-carry" then -- 2850
		self.phaseTick = self.phaseTick + 1 -- 2853
		if self.phaseTick == 20 then -- 2853
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2855
		end -- 2855
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2855
			self:requestRoom(gp.next, "背负进首战") -- 2858
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2859
		end -- 2859
	end -- 2859
end -- 2837
function Play.prototype.carryPose(self) -- 2868
	local p = self.player -- 2869
	local a = self.partner -- 2870
	a.alive = true -- 2871
	a.x = p.x - p.facing * 12 -- 2872
	a.y = p.y + 26 -- 2873
	a.depth = p.depth -- 2874
	a.vx = p.vx -- 2875
	a.vy = 0 -- 2876
	a.onGround = true -- 2877
	a.crouch = false -- 2878
	a.h = CHILD_CROUCH_H -- 2879
	a.facing = p.facing -- 2880
end -- 2868
function Play.prototype.stepMuseum(self, dt, input) -- 2888
	self.partner.alive = false -- 2889
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2890
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2893
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 2894
	local intentTarget = self.pendingMuseumIntentTarget -- 2895
	self.pendingMuseumIntentTarget = "" -- 2896
	local interactHit = input.interact.pressed or intentTarget ~= "" -- 2897
	if self.phase == "museum-cabinet" then -- 2897
		if atCase and interactHit or intentTarget == "cabinet" then -- 2897
			self.phase = "museum-hall" -- 2900
			self.phaseTick = 0 -- 2901
			if self:canPersistProgress() then -- 2901
				self.archive.museumPhase = "hall_walk" -- 2903
				self.archiveDirty = true -- 2904
			end -- 2904
			self:emit( -- 2906
				"museumStep", -- 2906
				{ -- 2906
					step = "cabinet", -- 2906
					x = self.ox + mu.cabinetX, -- 2906
					persisted = self:canPersistProgress() -- 2906
				} -- 2906
			) -- 2906
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2907
		end -- 2907
		return -- 2909
	end -- 2909
	if self.phase == "museum-hall" then -- 2909
		if intentTarget == "lamp_direct" and nearLamp then -- 2909
			self:emit( -- 2913
				"museumStep", -- 2913
				{ -- 2913
					step = "hall", -- 2913
					x = self.ox + mu.hallX, -- 2913
					persisted = self:canPersistProgress() -- 2913
				} -- 2913
			) -- 2913
			self.phase = "museum-return" -- 2914
			self.phaseTick = 0 -- 2915
			if self:canPersistProgress() then -- 2915
				self.archive.museumPhase = "return_cabinet" -- 2917
				self.archiveDirty = true -- 2918
			end -- 2918
			self:emit( -- 2920
				"museumStep", -- 2920
				{ -- 2920
					step = "lamp", -- 2920
					x = self.ox + mu.lampX, -- 2920
					persisted = self:canPersistProgress() -- 2920
				} -- 2920
			) -- 2920
			self:flashSet("灯 · 转向西窗", 1.8) -- 2921
			return -- 2922
		end -- 2922
		if self.player.x >= self.ox + mu.hallX and interactHit then -- 2922
			self.phase = "museum-lamp" -- 2925
			self.phaseTick = 0 -- 2926
			if self:canPersistProgress() then -- 2926
				self.archive.museumPhase = "lamp_turn" -- 2928
				self.archiveDirty = true -- 2929
			end -- 2929
			self:emit( -- 2931
				"museumStep", -- 2931
				{ -- 2931
					step = "hall", -- 2931
					x = self.ox + mu.hallX, -- 2931
					persisted = self:canPersistProgress() -- 2931
				} -- 2931
			) -- 2931
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2932
		end -- 2932
		return -- 2934
	end -- 2934
	if self.phase == "museum-lamp" then -- 2934
		if nearLamp and interactHit then -- 2934
			self.phase = "museum-return" -- 2938
			self.phaseTick = 0 -- 2939
			if self:canPersistProgress() then -- 2939
				self.archive.museumPhase = "return_cabinet" -- 2941
				self.archiveDirty = true -- 2942
			end -- 2942
			self:emit( -- 2944
				"museumStep", -- 2944
				{ -- 2944
					step = "lamp", -- 2944
					x = self.ox + mu.lampX, -- 2944
					persisted = self:canPersistProgress() -- 2944
				} -- 2944
			) -- 2944
			self:flashSet("灯 · 转向西窗", 1.8) -- 2945
		end -- 2945
		return -- 2947
	end -- 2947
	if self.phase == "museum-return" then -- 2947
		if atCase and interactHit or intentTarget == "return_cabinet" then -- 2947
			self.phase = "museum-knock" -- 2951
			self.phaseTick = 0 -- 2952
			self:emit( -- 2953
				"museumStep", -- 2953
				{ -- 2953
					step = "knock", -- 2953
					count = 1, -- 2953
					x = self.ox + mu.cabinetX, -- 2953
					persisted = self:canPersistProgress() -- 2953
				} -- 2953
			) -- 2953
			self:flashSet("回柜边 · 第一下", 0.8) -- 2954
		end -- 2954
		return -- 2956
	end -- 2956
	if self.phase == "museum-knock" then -- 2956
		self.phaseTick = self.phaseTick + 1 -- 2959
		if self.phaseTick == 8 then -- 2959
			self:emit( -- 2961
				"museumStep", -- 2961
				{ -- 2961
					step = "knock", -- 2961
					count = 2, -- 2961
					x = self.ox + mu.cabinetX, -- 2961
					persisted = self:canPersistProgress() -- 2961
				} -- 2961
			) -- 2961
			self:flashSet("回柜边 · 第二下", 0.8) -- 2962
		elseif self.phaseTick >= 36 then -- 2962
			self.phase = "museum-done" -- 2964
			self.phaseTick = 0 -- 2965
			if self:canPersistProgress() then -- 2965
				self.archive.museumSeen = true -- 2967
				self.archive.museumPhase = "done" -- 2968
				self.archiveDirty = true -- 2969
			end -- 2969
			self:emit( -- 2971
				"museumDone", -- 2971
				{ -- 2971
					steps = 4, -- 2971
					museumSeen = self.archive.museumSeen, -- 2971
					persisted = self:canPersistProgress() -- 2971
				} -- 2971
			) -- 2971
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2972
			self:log("博物馆 · 回柜边") -- 2973
		end -- 2973
		return -- 2975
	end -- 2975
	if interactHit then -- 2975
		self.museumReturn = true -- 2978
		self:requestRoom("prologue", "回柜边") -- 2979
	end -- 2979
end -- 2888
function Play.prototype.openTowerDoor(self) -- 2983
	self.towerDoorOpen = true -- 2984
	do -- 2984
		local i = 0 -- 2985
		while i < #self.boxes do -- 2985
			if self.boxes[i + 1].id == "tower_door" then -- 2985
				self.boxes[i + 1].hidden = true -- 2987
			end -- 2987
			i = i + 1 -- 2985
		end -- 2985
	end -- 2985
	self.run.story.segments.tower_door = true -- 2990
end -- 2983
function Play.prototype.stepTower(self, dt, input) -- 2993
	local ____temp_95 -- 2994
	if self.room.story == nil then -- 2994
		____temp_95 = nil -- 2994
	else -- 2994
		____temp_95 = self.room.story.tower -- 2994
	end -- 2994
	local t = ____temp_95 -- 2994
	if t == nil then -- 2994
		return -- 2996
	end -- 2996
	if self.storyRoute == "soldier" and self.partner.alive then -- 2996
		local targetX = math.max(self.ox + 408, self.player.x - 28) -- 3000
		local gap = targetX - self.partner.x -- 3001
		if math.abs(gap) > 2 then -- 3001
			local dir = gap > 0 and 1 or -1 -- 3003
			local stepDist = math.min( -- 3004
				math.abs(gap), -- 3004
				SOLDIER_SPEED * dt -- 3004
			) -- 3004
			self.partner.facing = dir -- 3005
			self.partner.vx = dir * SOLDIER_SPEED -- 3006
			local ____self_partner_96, ____x_97 = self.partner, "x" -- 3006
			____self_partner_96[____x_97] = ____self_partner_96[____x_97] + dir * stepDist -- 3007
		else -- 3007
			self.partner.vx = 0 -- 3009
			self.partner.facing = 1 -- 3010
		end -- 3010
	end -- 3010
	if self.phase == "tower-wait" then -- 3010
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 3014
		if near and input.interact.pressed then -- 3014
			self.phase = "tower-knock" -- 3016
			self.phaseTick = 0 -- 3017
			self.knocks = 1 -- 3018
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 3019
			self:flashSet("叩两下 · 第一声", 0.6) -- 3020
		end -- 3020
		return -- 3022
	end -- 3022
	if self.phase == "tower-knock" then -- 3022
		self.phaseTick = self.phaseTick + 1 -- 3025
		if self.phaseTick == 12 then -- 3025
			self.knocks = 2 -- 3027
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 3028
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 3029
		elseif self.phaseTick >= t.knockTicks then -- 3029
			self:openTowerDoor() -- 3031
			self.phase = "tower-enter" -- 3032
			self.phaseTick = 0 -- 3033
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 3034
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 3035
		end -- 3035
		return -- 3037
	end -- 3037
	if self.phase == "tower-enter" then -- 3037
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 3037
			self.phase = "tower-desk" -- 3041
			self.phaseTick = 0 -- 3042
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 3043
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 3044
		end -- 3044
		return -- 3046
	end -- 3046
	if self.phase == "tower-desk" then -- 3046
		local deskX = self.ox + 605 -- 3049
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 3050
		if not near or not input.interact.held then -- 3050
			self.deskHold = 0 -- 3052
			return -- 3053
		end -- 3053
		self.deskHold = self.deskHold + 1 -- 3055
		if self.deskHold == 12 then -- 3055
			self:flashSet("针套 · 放在桌上", 1) -- 3057
		elseif self.deskHold == 24 then -- 3057
			self:flashSet("指南针 · 压住纸条", 1) -- 3059
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 3059
			self.towerHanded = true -- 3061
			self.deskHold = 0 -- 3062
			self.run.story.segments.tower_handover = true -- 3063
			self.phase = "tower-given" -- 3064
			self.phaseTick = 0 -- 3065
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 3066
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 3071
		end -- 3071
		return -- 3073
	end -- 3073
	if self.phase == "tower-given" then -- 3073
		local soldier = self.storyRoute == "soldier" -- 3078
		self.phaseTick = self.phaseTick + 1 -- 3079
		if self.phaseTick == 60 then -- 3079
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 3081
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 3082
		elseif self.phaseTick == 120 then -- 3082
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 3084
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 3084
			self.phase = "tower-end" -- 3086
			self.phaseTick = 0 -- 3087
			self.towerEndMustRelease = input.interact.held or input.retry.held -- 3088
			if not self.run.finished then -- 3088
				self.run.finished = true -- 3090
				local ending = soldier and "reunion" or "lamp" -- 3091
				self.run.story.ending = ending -- 3092
				local ____soldier_98 -- 3095
				if soldier then -- 3095
					____soldier_98 = self.run.story.segments.escort5 == true -- 3096
				else -- 3096
					____soldier_98 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 3097
				end -- 3097
				local played = ____soldier_98 -- 3095
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 3098
				if official then -- 3098
					if soldier then -- 3098
						self.run.archive.soldierCleared = true -- 3102
					else -- 3102
						self.run.archive.childCleared = true -- 3104
					end -- 3104
					self.archiveDirty = true -- 3106
				end -- 3106
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 3108
				self:emit("endingReached", { -- 3109
					route = soldier and "soldier" or "child", -- 3110
					ending = ending, -- 3111
					official = official, -- 3112
					source = self.run.source, -- 3113
					lines = {self.endingLines[1], self.endingLines[2]}, -- 3114
					childCleared = self.run.archive.childCleared, -- 3115
					soldierCleared = self.run.archive.soldierCleared, -- 3116
					artifactOwned = self.run.archive.artifactOwned, -- 3117
					equipped = self.equippedWeapon -- 3118
				}) -- 3118
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 3120
			end -- 3120
		end -- 3120
		return -- 3123
	end -- 3123
	self.phaseTick = self.phaseTick + 1 -- 3125
	local held = input.interact.held or input.retry.held -- 3126
	if self.towerEndMustRelease then -- 3126
		if not held then -- 3126
			self.towerEndMustRelease = false -- 3129
		end -- 3129
		return -- 3131
	end -- 3131
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 3133
	if self.phaseTick < waitTicks then -- 3133
		if input.interact.pressed or input.retry.pressed then -- 3133
			self.towerEndMustRelease = held -- 3136
		end -- 3136
		return -- 3138
	end -- 3138
	if input.interact.pressed or input.retry.pressed then -- 3138
		self.restartStory = true -- 3142
		self:requestRoom("prologue", "片尾再玩") -- 3143
		self:flashSet("回到序章", 1.4) -- 3144
	end -- 3144
end -- 2993
function Play.prototype.stepChase(self, dt, input) -- 3149
	if self.caughtT > 0 then -- 3149
		self.caughtT = self.caughtT - dt -- 3151
		if self.caughtT <= 0 then -- 3151
			self:recoverFromCaught() -- 3153
		end -- 3153
		return -- 3155
	end -- 3155
	if self.room.key == "village" then -- 3155
		self:stepScavChase() -- 3158
	elseif self.room.key == "forest" then -- 3158
		self:stepForestRoute() -- 3160
		self:stepDog(dt) -- 3161
		if self.player.x >= self.ox + 1450 then -- 3161
			self:requestRoom("tower", "到林缘北塔") -- 3164
			self:flashSet("林缘 · 北塔", 1.4) -- 3165
		end -- 3165
	end -- 3165
end -- 3149
function Play.prototype.stepScavChase(self) -- 3171
	local s = self.room.scavenger -- 3172
	if s == nil then -- 3172
		return -- 3174
	end -- 3174
	local p = self.player -- 3176
	if self.passed and p.x > self.ox + 440 then -- 3176
		if self.scavChase then -- 3176
			self.scavChase = false -- 3180
			self.scavState = "back" -- 3181
			self.scavT = 0 -- 3182
		end -- 3182
		return -- 3184
	end -- 3184
	local dx = p.x - self.scavX -- 3186
	local dist = math.abs(dx) -- 3187
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 3188
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 3189
	if not self.scavChase then -- 3189
		if visible then -- 3189
			self.scavSee = self.scavSee + 1 -- 3192
			if self.scavSee >= 24 then -- 3192
				self.scavChase = true -- 3194
				self.scavState = "chase" -- 3195
				self.scavTargetX = p.x -- 3196
				self:flashSet("他看见你了", 1.2) -- 3197
			end -- 3197
		else -- 3197
			self.scavSee = 0 -- 3200
		end -- 3200
		return -- 3202
	end -- 3202
	if hidden then -- 3202
		self.scavSee = 0 -- 3206
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 3207
		self.scavT = self.scavT - 1 -- 3208
		if self.scavT <= 0 then -- 3208
			self.scavChase = false -- 3210
			self.scavState = "patrol" -- 3211
			self:flashSet("他失去了目标", 1) -- 3212
		end -- 3212
		return -- 3214
	end -- 3214
	local dir = p.x > self.scavX and 1 or -1 -- 3217
	self.scavX = self.scavX + dir * 96 / 60 -- 3218
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 3218
		self:caught() -- 3220
		return -- 3221
	end -- 3221
end -- 3171
function Play.prototype.stepDog(self, dt) -- 3226
	local ____temp_99 -- 3227
	if self.room.story == nil then -- 3227
		____temp_99 = nil -- 3227
	else -- 3227
		____temp_99 = self.room.story.dog -- 3227
	end -- 3227
	local dog = ____temp_99 -- 3227
	if dog == nil then -- 3227
		return -- 3229
	end -- 3229
	local p = self.player -- 3231
	local ox = self.ox -- 3232
	local dist = math.abs(p.x - self.dogX) -- 3233
	local inBurrowCover = p.crouch and p.x >= ox + 300 and p.x <= ox + 460 -- 3234
	local inBrushCover = p.crouch and (p.x >= ox + 700 and p.x <= ox + 790 or p.x >= ox + 1150 and p.x <= ox + 1240) -- 3235
	local sheltered = inBurrowCover or inBrushCover -- 3239
	local inDitchSprint = not p.crouch and self.forestPath == "ditch" and p.x >= ox + 700 and p.x <= ox + 1140 -- 3240
	local effectiveRange = inDitchSprint and dog.range * 1.25 or dog.range -- 3241
	local earNeedTicks = inDitchSprint and 12 or 18 -- 3242
	if self.dogState == "patrol" then -- 3242
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 3244
		if self.dogX < dog.x0 then -- 3244
			self.dogX = dog.x0 -- 3246
			self.dogDir = 1 -- 3247
		elseif self.dogX > dog.x1 then -- 3247
			self.dogX = dog.x1 -- 3249
			self.dogDir = -1 -- 3250
		end -- 3250
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 3252
		local twigOffsets = {235, 455, 865, 1115} -- 3253
		local nearTwig = false -- 3254
		local ti = 0 -- 3255
		do -- 3255
			ti = 0 -- 3256
			while ti < #twigOffsets do -- 3256
				if math.abs(p.x - (ox + twigOffsets[ti + 1])) <= 18 and p.y <= 8 then -- 3256
					nearTwig = true -- 3258
					break -- 3259
				end -- 3259
				ti = ti + 1 -- 3256
			end -- 3256
		end -- 3256
		local twigRange = nearTwig and math.max(effectiveRange, 400) or effectiveRange -- 3262
		if not sheltered and not p.crouch and moving and dist < twigRange then -- 3262
			self.dogState = "ear" -- 3264
			self.dogT = nearTwig and math.min(earNeedTicks, 12) or earNeedTicks -- 3265
			self.dogTargetX = p.x -- 3266
			self:flashSet(inDitchSprint and "旧渠枯枝响 · 狗立刻转耳" or (nearTwig and "踩断枯枝 · 狗立刻转耳" or "狗转耳朵"), 0.8) -- 3267
		end -- 3267
		return -- 3269
	end -- 3269
	if self.dogState == "ear" then -- 3269
		if sheltered then -- 3269
			self.dogState = "sniff" -- 3273
			self.dogT = 45 -- 3274
			self:flashSet("钻进遮蔽 · 狗顿住了", 0.9) -- 3275
			return -- 3276
		end -- 3276
		self.dogT = self.dogT - 1 -- 3278
		if self.dogT <= 0 then -- 3278
			self.dogState = "chase" -- 3280
			self.dogTargetX = p.x -- 3281
			self:flashSet("狗追来了", 1.4) -- 3282
		end -- 3282
		return -- 3284
	end -- 3284
	if self.dogState == "chase" then -- 3284
		local dir = p.x > self.dogX and 1 or -1 -- 3287
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 3288
		if not sheltered and math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 3288
			self:caught() -- 3290
			self.dogState = "sniff" -- 3291
			self.dogT = 60 -- 3292
		elseif dist > effectiveRange * 1.5 or sheltered then -- 3292
			self.dogState = "sniff" -- 3294
			self.dogT = 60 -- 3295
			self:flashSet(inBurrowCover and "树根窄洞遮住身形 · 狗停下了" or "狗停下了", 0.9) -- 3296
		end -- 3296
		return -- 3298
	end -- 3298
	if self.dogState == "sniff" then -- 3298
		self.dogT = self.dogT - 1 -- 3301
		if self.dogT <= 0 then -- 3301
			self.dogState = "back" -- 3303
		end -- 3303
		return -- 3305
	end -- 3305
	local dir = dog.x0 > self.dogX and 1 or -1 -- 3308
	self.dogX = self.dogX + dir * dog.speed * dt -- 3309
	if math.abs(self.dogX - dog.x0) < 2 then -- 3309
		self.dogX = dog.x0 -- 3311
		self.dogState = "patrol" -- 3312
	end -- 3312
end -- 3226
function Play.prototype.stepForestRoute(self) -- 3317
	local p = self.player -- 3318
	local ox = self.ox -- 3319
	if self.forestPath == "" then -- 3319
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 3319
			self.forestPath = "burrow" -- 3322
			self.run.story.segments.forest_burrow = true -- 3323
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 3324
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 3325
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 3325
			self.forestPath = "ditch" -- 3327
			self.run.story.segments.forest_ditch = true -- 3328
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 3329
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 3330
		end -- 3330
	end -- 3330
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 3330
		self.waterSeen = true -- 3334
		self.run.story.segments.water_lantern = true -- 3335
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 3336
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 3337
	end -- 3337
end -- 3317
function Play.prototype.caught(self) -- 3341
	self.caughtT = 1 -- 3342
	self:flashSet("被抓 · 回到安全点", 1.6) -- 3343
end -- 3341
function Play.prototype.recoverFromCaught(self) -- 3347
	local p = self.player -- 3348
	p.x = self.ox + 140 -- 3349
	p.y = 0 -- 3350
	p.vy = 0 -- 3351
	p.vx = 0 -- 3352
	p.onGround = true -- 3353
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3353
		self.scavX = self.room.scavenger.x0 -- 3355
		self.scavState = "patrol" -- 3356
		self.scavSee = 0 -- 3357
		self.scavChase = false -- 3358
		self.scavT = 0 -- 3359
	end -- 3359
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3359
		self.dogX = self.room.story.dog.x0 -- 3362
		self.dogState = "patrol" -- 3363
		self.dogT = 0 -- 3364
	end -- 3364
	self.cam.x = p.x -- 3366
	self.cam.y = p.y + CAM_LOOK_UP -- 3367
	self:flashSet("回到安全点", 1.2) -- 3368
end -- 3347
function Play.prototype.updateGate(self) -- 3372
	if self.room.key ~= "checkpoint" then -- 3372
		self.gateOpen = false -- 3374
		return -- 3375
	end -- 3375
	local function inZone(x) -- 3377
		return x >= self.ox + 792 and x <= self.ox + 928 -- 3377
	end -- 3377
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 3378
end -- 3372
function Play.prototype.addItem(self, kind) -- 3384
	local inv = self.run.inventory -- 3385
	if kind == "shield" then -- 3385
		if inv.shield >= TOOL_CAP then -- 3385
			return false -- 3388
		end -- 3388
		inv.shield = inv.shield + 1 -- 3390
		return true -- 3391
	end -- 3391
	if kind == "wedge" then -- 3391
		if inv.wedge >= CONSUMABLE_CAP then -- 3391
			return false -- 3395
		end -- 3395
		inv.wedge = inv.wedge + 1 -- 3397
		return true -- 3398
	end -- 3398
	if kind == "ammo" then -- 3398
		if inv.ammo >= CONSUMABLE_CAP then -- 3398
			return false -- 3402
		end -- 3402
		inv.ammo = inv.ammo + 1 -- 3404
		return true -- 3405
	end -- 3405
	if kind == "scrap" then -- 3405
		inv.scrap = inv.scrap + 1 -- 3409
		return true -- 3410
	end -- 3410
	if kind == "wood" then -- 3410
		inv.wood = inv.wood + 1 -- 3413
		return true -- 3414
	end -- 3414
	if kind == "bell" then -- 3414
		inv.bell = inv.bell + 1 -- 3417
		return true -- 3418
	end -- 3418
	if kind == "pass" then -- 3418
		inv.pass = inv.pass + 1 -- 3421
		return true -- 3422
	end -- 3422
	if kind == "quickbelt" then -- 3422
		inv.quickbelt = inv.quickbelt + 1 -- 3425
		return true -- 3426
	end -- 3426
	return false -- 3428
end -- 3384
function Play.prototype.findBox(self, id) -- 3431
	local i = 0 -- 3432
	do -- 3432
		i = 0 -- 3433
		while i < #self.boxes do -- 3433
			if self.boxes[i + 1].id == id then -- 3433
				return self.boxes[i + 1] -- 3435
			end -- 3435
			i = i + 1 -- 3433
		end -- 3433
	end -- 3433
	return nil -- 3438
end -- 3431
function Play.prototype.findWedgeTarget(self) -- 3442
	local best = nil -- 3443
	local bestD = 0 -- 3444
	local i = 0 -- 3445
	do -- 3445
		i = 0 -- 3446
		while i < #self.boxes do -- 3446
			do -- 3446
				local b = self.boxes[i + 1] -- 3447
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3447
					goto __continue529 -- 3449
				end -- 3449
				if not self:nearBox(b, 26) then -- 3449
					goto __continue529 -- 3452
				end -- 3452
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3454
				if best == nil or d < bestD then -- 3454
					best = b -- 3456
					bestD = d -- 3457
				end -- 3457
			end -- 3457
			::__continue529:: -- 3457
			i = i + 1 -- 3446
		end -- 3446
	end -- 3446
	return best -- 3460
end -- 3442
function Play.prototype.stepCraft(self, input) -- 3468
	local inv = self.run.inventory -- 3469
	local required = math.max( -- 3470
		6, -- 3470
		CRAFT_TICKS - 6 * self:talentRank("salvage") -- 3470
	) -- 3470
	if self.craftT > 0 then -- 3470
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3470
			self.craftT = 0 -- 3474
			self:flashSet("制作中断", 0.8) -- 3475
			return true -- 3476
		end -- 3476
		self.craftT = self.craftT + 1 -- 3478
		if self.craftT >= required then -- 3478
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3478
				inv.scrap = inv.scrap - 1 -- 3481
				inv.wedge = inv.wedge + 1 -- 3482
				self:flashSet("制得木楔", 1.2) -- 3483
				self:log("制木楔") -- 3484
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3485
			end -- 3485
			self.craftT = 0 -- 3487
		end -- 3487
		return true -- 3489
	end -- 3489
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3489
		self.craftT = 1 -- 3492
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3493
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3494
		return true -- 3495
	end -- 3495
	return false -- 3497
end -- 3468
function Play.prototype.nearBox(self, b, reach) -- 3500
	local p = self.player -- 3501
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3502
end -- 3500
function Play.prototype.findInteract(self) -- 3508
	local p = self.player -- 3509
	local best = nil -- 3510
	local bestD = 1000000000 -- 3511
	local i = 0 -- 3512
	do -- 3512
		i = 0 -- 3513
		while i < #self.boxes do -- 3513
			do -- 3513
				local b = self.boxes[i + 1] -- 3514
				if b.interact == nil or b.broken == true then -- 3514
					goto __continue542 -- 3516
				end -- 3516
				if not self:nearBox(b, b.interact.reach or 27) then -- 3516
					goto __continue542 -- 3519
				end -- 3519
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3521
				if d < bestD then -- 3521
					bestD = d -- 3523
					best = b -- 3524
				end -- 3524
			end -- 3524
			::__continue542:: -- 3524
			i = i + 1 -- 3513
		end -- 3513
	end -- 3513
	return best -- 3527
end -- 3508
function Play.prototype.stepCampaign(self, dt, input) -- 3531
	local wr = self.room -- 3532
	local p = self.player -- 3533
	if self.reloadT > 0 then -- 3533
		self.reloadT = self.reloadT - 1 -- 3535
	end -- 3535
	if self.bracedShield ~= nil then -- 3535
		self.bracedShield.x = p.x + p.facing * 26 -- 3539
		self.bracedShield.y = p.y -- 3540
		local shBox = __TS__ArrayFind( -- 3541
			self.boxes, -- 3541
			function(____, b) return b.id == "braced_shield" end -- 3541
		) -- 3541
		if shBox ~= nil then -- 3541
			shBox.x0 = self.bracedShield.x - 15 -- 3543
			shBox.x1 = self.bracedShield.x + 15 -- 3544
			shBox.y0 = self.bracedShield.y -- 3545
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3546
		end -- 3546
	end -- 3546
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3546
		self.run.route = "drygoods" -- 3552
		self.run.joined = false -- 3553
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3554
		self:log("转布行线") -- 3555
	end -- 3555
	if wr.key == "escort3" then -- 3555
		local nearBench = p.x >= wr.minX + 472 and p.x <= wr.minX + 710 and p.y < 60 -- 3560
		if nearBench and input.interact.pressed then -- 3560
			self:openCraftBench() -- 3562
			return -- 3563
		end -- 3563
		local ____temp_102 = self.storyRoute == "soldier" -- 3565
		if ____temp_102 then -- 3565
			local ____opt_100 = self.run.story.talents -- 3565
			____temp_102 = (____opt_100 and ____opt_100.deferred) == true -- 3565
		end -- 3565
		if ____temp_102 and p.x >= wr.minX + 940 then -- 3565
			self:triggerDeferredEscort3Draft() -- 3566
		end -- 3566
	end -- 3566
	local i = 0 -- 3570
	do -- 3570
		i = 0 -- 3571
		while i < #self.pickups do -- 3571
			do -- 3571
				local pk = self.pickups[i + 1] -- 3572
				if self.run.taken[pk.id] == true then -- 3572
					goto __continue556 -- 3574
				end -- 3574
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3576
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3577
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3577
					if not self:addItem(pk.kind) then -- 3577
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3581
						self:log("满包拒绝 " .. pk.kind) -- 3582
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3583
						goto __continue556 -- 3584
					end -- 3584
					self.run.taken[pk.id] = true -- 3586
					self:flashSet("拾取 " .. pk.label, 1) -- 3587
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3588
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3589
				end -- 3589
			end -- 3589
			::__continue556:: -- 3589
			i = i + 1 -- 3571
		end -- 3571
	end -- 3571
	self.calmConsumed = false -- 3593
	local ____temp_108 = self.partner.alive and self.run.joined -- 3594
	if ____temp_108 then -- 3594
		local ____opt_103 = self.room.campaign -- 3594
		local ____temp_107 = (____opt_103 and ____opt_103.chapter) == "S" -- 3595
		if not ____temp_107 then -- 3595
			local ____opt_105 = self.room.campaign -- 3595
			____temp_107 = (____opt_105 and ____opt_105.chapter) == "C" -- 3595
		end -- 3595
		____temp_108 = ____temp_107 -- 3594
	end -- 3594
	if ____temp_108 and (self.escort.fear > 0 or self.escort.state == "frozen" or self.escort.state == "calming") then -- 3594
		local dist = inReachDepth(p.depth, self.partner.depth) and math.abs(p.x - self.partner.x) or 1000000000 -- 3597
		local hadK1 = self.escort.knock1 -- 3598
		local hadK2 = self.escort.knock2 -- 3599
		self.calmConsumed = self.escort:update( -- 3600
			input, -- 3600
			p.x, -- 3600
			p.facing, -- 3600
			self.partner.x, -- 3600
			dist -- 3600
		) -- 3600
		if not hadK1 and self.escort.knock1 then -- 3600
			self:emit("knock", {count = 1, x = self.partner.x, room = self.room.key}) -- 3602
		end -- 3602
		if not hadK2 and self.escort.knock2 then -- 3602
			self:emit("knock", {count = 2, x = self.partner.x, room = self.room.key}) -- 3605
		end -- 3605
		self.partner.crouch = self.escort.crouchPose -- 3607
		self.partner.h = self.partner.crouch and CHILD_CROUCH_H or CHILD_H -- 3608
	end -- 3608
	if not self.calmConsumed and not self:stepCraft(input) and input.interact.pressed then -- 3608
		self:campaignInteract() -- 3611
	end -- 3611
	self:stepCampaignCart(dt, input) -- 3613
	self:stepCampaignGoal() -- 3614
	self:campaignCheckpoint() -- 3615
end -- 3531
function Play.prototype.campaignCheckpoint(self) -- 3619
	local i = 0 -- 3620
	do -- 3620
		i = 0 -- 3621
		while i < #self.room.marks do -- 3621
			do -- 3621
				local m = self.room.marks[i + 1] -- 3622
				if m.kind ~= 0 then -- 3622
					goto __continue566 -- 3624
				end -- 3624
				local dx = self.player.x - m.x -- 3626
				local dy = self.player.y - m.y -- 3627
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3627
					self.checkpoint = m.x -- 3629
					self:captureCheckpoint(m.x) -- 3630
					self:flashSet("检查点", 1) -- 3631
				end -- 3631
			end -- 3631
			::__continue566:: -- 3631
			i = i + 1 -- 3621
		end -- 3621
	end -- 3621
end -- 3619
function Play.prototype.campaignInteract(self) -- 3637
	local b = self:findInteract() -- 3638
	if b ~= nil then -- 3638
		self:useInteract(b) -- 3640
		return -- 3641
	end -- 3641
	local inv = self.run.inventory -- 3643
	if inv.wedge > 0 then -- 3643
		local w = self:findWedgeTarget() -- 3645
		if w ~= nil then -- 3645
			local ____opt_109 = w.breakable -- 3645
			local extraHp = (____opt_109 and ____opt_109.wedgeHp or 1) + self:talentRank("salvage") -- 3647
			if w.breakable ~= nil then -- 3647
				local ____w_breakable_111, ____hp_112 = w.breakable, "hp" -- 3647
				____w_breakable_111[____hp_112] = ____w_breakable_111[____hp_112] + extraHp -- 3649
			end -- 3649
			inv.wedge = inv.wedge - 1 -- 3651
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3652
			self:flashSet( -- 3654
				extraHp > 1 and ("钉木楔 · 多承" .. tostring(extraHp)) .. "次" or "钉木楔 · 多承一次", -- 3654
				1.2 -- 3654
			) -- 3654
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3655
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3656
			return -- 3657
		end -- 3657
		if self:isEscortRoom() then -- 3657
			local p = self.player -- 3660
			local wx = math.max( -- 3661
				self.room.minX + 64, -- 3661
				math.min(self.room.maxX - 64, p.x + p.facing * 32) -- 3661
			) -- 3661
			local hp = 1 + self:talentRank("salvage") -- 3662
			self.fieldWedgeSeq = self.fieldWedgeSeq + 1 -- 3663
			local wid = "field_wedge_" .. tostring(self.fieldWedgeSeq) -- 3664
			local ____self_boxes_113 = self.boxes -- 3664
			____self_boxes_113[#____self_boxes_113 + 1] = { -- 3665
				x0 = wx - 12, -- 3666
				x1 = wx + 12, -- 3667
				y0 = p.y, -- 3668
				y1 = p.y + 48, -- 3669
				depth = {min = p.depth - 20, max = p.depth + 20}, -- 3670
				label = "立起的木楔掩体", -- 3671
				id = wid, -- 3672
				breakable = {hp = hp, kind = "thin_wood", wedgeable = true} -- 3673
			} -- 3673
			inv.wedge = inv.wedge - 1 -- 3675
			self:flashSet( -- 3676
				"立木楔 · 临时挡弹" .. (hp > 1 and ("(" .. tostring(hp)) .. "击)" or ""), -- 3676
				1.2 -- 3676
			) -- 3676
			self:log("立木楔掩体") -- 3677
			self:emit("interactUsed", {kind = "wedge", x = wx}) -- 3678
			return -- 3679
		end -- 3679
	end -- 3679
	if inv.ammo > 0 and self.reloadT > 0 then -- 3679
		self.reloadT = 0 -- 3684
		self:closeReloadPuzzle() -- 3685
		inv.ammo = inv.ammo - 1 -- 3686
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3687
		self:log("用备用弹包") -- 3688
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3689
		return -- 3690
	end -- 3690
	local canBraceHere = self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 or self:isEscortRoom() -- 3692
	if inv.shield > 0 and self.bracedShield == nil and canBraceHere then -- 3692
		local p = self.player -- 3696
		local shHp = 1 + self:talentRank("salvage") -- 3697
		self.bracedShield = { -- 3698
			x = p.x + p.facing * 26, -- 3698
			y = p.y, -- 3698
			w = 30, -- 3698
			h = 64, -- 3698
			hp = shHp -- 3698
		} -- 3698
		local ____self_boxes_114 = self.boxes -- 3698
		____self_boxes_114[#____self_boxes_114 + 1] = { -- 3699
			x0 = self.bracedShield.x - 15, -- 3700
			x1 = self.bracedShield.x + 15, -- 3700
			y0 = p.y, -- 3701
			y1 = p.y + 64, -- 3701
			depth = {min = -46, max = 46}, -- 3701
			label = "架起的残盾", -- 3701
			id = "braced_shield", -- 3701
			soft = true -- 3702
		} -- 3702
		inv.shield = inv.shield - 1 -- 3704
		self:flashSet( -- 3705
			shHp > 1 and ("架残盾 · 可挡" .. tostring(shHp)) .. "发" or "架残盾 · 挡一发", -- 3705
			1.2 -- 3705
		) -- 3705
		self:log("架残盾") -- 3706
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3707
		return -- 3708
	end -- 3708
	if inv.pass > 0 and self.run.joined == false then -- 3708
		inv.pass = inv.pass - 1 -- 3711
		self.run.joined = true -- 3712
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3713
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3714
		return -- 3715
	end -- 3715
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3717
end -- 3637
function Play.prototype.useInteract(self, b) -- 3720
	local kind = b.interact == nil and "" or b.interact.kind -- 3721
	local wr = self.room -- 3722
	if kind == "open_board" then -- 3722
		b.broken = true -- 3724
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3725
		for ____, cover in ipairs(self.boxes) do -- 3726
			if cover.id == "s2_board_cover" then -- 3726
				cover.broken = false -- 3728
				cover.hidden = false -- 3729
			end -- 3729
		end -- 3729
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3732
		self.run.joined = true -- 3733
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3734
		self:log("放下窗板") -- 3735
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3736
		return -- 3737
	end -- 3737
	if kind == "lower_curtain" then -- 3737
		for ____, curtain in ipairs(self.boxes) do -- 3740
			if curtain.id == "c2_curtain" then -- 3740
				curtain.broken = false -- 3742
				curtain.hidden = false -- 3743
			end -- 3743
		end -- 3743
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3746
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3747
		self:log("放下木帘") -- 3748
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3749
		return -- 3750
	end -- 3750
	if kind == "raise_latch" then -- 3750
		if wr.key == "c2-granary" and not self.cartDocked then -- 3750
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3754
			return -- 3755
		end -- 3755
		b.broken = true -- 3757
		self.objectiveDone = true -- 3758
		if wr.key == "c1-yard" then -- 3758
			self.run.c1Latch = true -- 3761
			self.run.joined = true -- 3762
			for ____, door in ipairs(self.boxes) do -- 3763
				if door.id == "c1_door" then -- 3763
					door.broken = true -- 3765
				end -- 3765
			end -- 3765
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3768
		else -- 3768
			self.run.c2Latch = true -- 3770
			self.run.joined = true -- 3771
		end -- 3771
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3773
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3774
		self:log("抬闩") -- 3775
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3776
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3777
	end -- 3777
end -- 3720
function Play.prototype.stepCampaignCart(self, dt, input) -- 3782
	local wr = self.room -- 3783
	local c = wr.cart -- 3784
	if c.bodyW <= 0 then -- 3784
		return -- 3786
	end -- 3786
	local p = self.player -- 3788
	local handleX = self.cartAxle + c.handleOffset -- 3789
	if not self.gripping then -- 3789
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3789
			self.gripping = true -- 3793
			self:flashSet("握住车柄 · A/D 推", 1) -- 3794
		end -- 3794
		return -- 3796
	end -- 3796
	if input.interact.pressed then -- 3796
		self.gripping = false -- 3799
		self:flashSet("松手", 0.5) -- 3800
		return -- 3801
	end -- 3801
	if not self.cartDocked then -- 3801
		if input.moveX ~= 0 and not self:stuckCart() then -- 3801
			self.cartAxle = math.max( -- 3805
				c.startX, -- 3805
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3805
			) -- 3805
		end -- 3805
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3805
			self.cartExposed = true -- 3810
			local gun = nil -- 3811
			local gi = 0 -- 3812
			do -- 3812
				gi = 0 -- 3813
				while gi < #self.enemies do -- 3813
					local e = self.enemies[gi + 1] -- 3814
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3814
						gun = e -- 3816
						break -- 3817
					end -- 3817
					gi = gi + 1 -- 3813
				end -- 3813
			end -- 3813
			if gun ~= nil then -- 3813
				self:campaignEnemyFire(gun) -- 3821
			end -- 3821
		end -- 3821
		p.x = self.cartAxle + c.handleOffset -- 3824
		p.y = c.baseY -- 3825
		p.depth = c.depth or 0 -- 3826
		p.vx = 0 -- 3827
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3827
			self.cartAxle = c.endX -- 3829
			self.cartDocked = true -- 3830
			self.gripping = false -- 3831
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3832
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3833
			self:flashSet("车轮入窝", 1.2) -- 3834
			self:log("车轮入窝") -- 3835
		end -- 3835
	end -- 3835
end -- 3782
function Play.prototype.stuckCart(self) -- 3841
	local i = 0 -- 3842
	do -- 3842
		i = 0 -- 3843
		while i < #self.boxes do -- 3843
			do -- 3843
				local b = self.boxes[i + 1] -- 3844
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3844
					goto __continue609 -- 3846
				end -- 3846
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3848
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3848
					return true -- 3850
				end -- 3850
			end -- 3850
			::__continue609:: -- 3850
			i = i + 1 -- 3843
		end -- 3843
	end -- 3843
	return false -- 3853
end -- 3841
function Play.prototype.stepCampaignGoal(self) -- 3857
	local wr = self.room -- 3858
	local c = wr.campaign -- 3859
	if c == nil then -- 3859
		return -- 3861
	end -- 3861
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3861
		self.objectiveDone = true -- 3864
	end -- 3864
	if c.goal == "reach_exit" then -- 3864
		self.objectiveDone = true -- 3867
	end -- 3867
	if not self.objectiveDone then -- 3867
		return -- 3870
	end -- 3870
	local p = self.player -- 3872
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3873
	if p.x < c.exitX or not partnerOk then -- 3873
		return -- 3875
	end -- 3875
	if self.run.story.segments[wr.key] ~= true then -- 3875
		self.run.story.segments[wr.key] = true -- 3879
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3880
	end -- 3880
	if wr.key == "escort5" then -- 3880
		self.escortDone = true -- 3884
		self.run.story.escortDone = true -- 3885
	end -- 3885
	if c.next ~= nil and c.next ~= "" then -- 3885
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3888
		self:flashSet("过关 · " .. c.next, 1.2) -- 3889
	elseif wr.key == "c2-granary" and (self.run.source == "official" or self.run.source == "chapter") then -- 3889
		self:requestRoom("gate", "军粮棚出口") -- 3892
		self:flashSet("出军粮棚 · 城门", 1.4) -- 3893
	elseif not self.run.finished then -- 3893
		self.run.finished = true -- 3895
		self:flashSet( -- 3896
			"军粮棚清完 · 回城门 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3896
			2 -- 3896
		) -- 3896
		self:log("军粮棚清完 · 回城门") -- 3897
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3898
	end -- 3898
end -- 3857
function Play.prototype.stepCampaignPartner(self, dt) -- 3903
	local a = self.partner -- 3904
	local wr = self.room -- 3905
	local cp = wr.companion -- 3906
	if not a.alive then -- 3906
		return -- 3908
	end -- 3908
	local p = self.player -- 3910
	if self.craftBench.active then -- 3910
		a.vx = 0 -- 3913
		return -- 3914
	end -- 3914
	local wait = false -- 3916
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3917
	local targetDepth = p.depth -- 3918
	if self.run.joined == false then -- 3918
		wait = true -- 3920
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3921
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3922
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3922
		wait = true -- 3924
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3925
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3926
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3926
		wait = true -- 3928
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3929
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3930
	end -- 3930
	if self.partnerStuck > 0.3 then -- 3930
		a.x = a.x + a.facing * 44 -- 3934
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3935
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3936
		self.partnerLaneHold = 1.1 -- 3937
		self.partnerStuck = 0 -- 3938
	end -- 3938
	if self.partnerLaneHold > 0 then -- 3938
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3941
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3942
	end -- 3942
	local dx = targetX - a.x -- 3944
	local stopTol = wait and 18 or 74 -- 3945
	if math.abs(dx) > stopTol then -- 3945
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3947
		local before = a.x -- 3948
		a.vx = dx > 0 and speed or -speed -- 3949
		a.facing = dx > 0 and 1 or -1 -- 3950
		self:slideX(a, a.vx * dt) -- 3951
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3951
			a.vy = CHILD_JUMP -- 3954
			a.onGround = false -- 3955
		end -- 3955
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3957
	else -- 3957
		a.vx = 0 -- 3959
		self.partnerStuck = 0 -- 3960
	end -- 3960
	local dz = targetDepth - a.depth -- 3962
	if math.abs(dz) > 6 then -- 3962
		local step = math.max( -- 3964
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3964
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3964
		) -- 3964
		a.depth = a.depth + step -- 3965
	end -- 3965
	a.depthSpeed = 0 -- 3967
	a.h = CHILD_H -- 3968
	a.crouch = false -- 3969
	self:fallY(a, dt) -- 3970
end -- 3903
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3974
	local p = self.player -- 3975
	local i = 0 -- 3976
	do -- 3976
		i = 0 -- 3977
		while i < #self.enemies and not self.escortFailed do -- 3977
			do -- 3977
				local e = self.enemies[i + 1] -- 3978
				if e.kind == "target" then -- 3978
					if not e.alive then -- 3978
						if e.hitT > 0 then -- 3978
							e.hitT = e.hitT - dt -- 3983
						end -- 3983
						if e.hitT <= 0 then -- 3983
							e.alive = true -- 3986
							e.hitT = 0 -- 3987
						end -- 3987
					end -- 3987
					goto __continue637 -- 3990
				end -- 3990
				if not e.alive then -- 3990
					goto __continue637 -- 3993
				end -- 3993
				if e.kind == "breaker" then -- 3993
					self:stepBreaker(e, dt) -- 3996
					goto __continue637 -- 3997
				end -- 3997
				if e.kind == "shield" then -- 3997
					self:stepShield(e, dt, input) -- 4000
					goto __continue637 -- 4001
				end -- 4001
				local dx = e.x - p.x -- 4004
				if not e.awake then -- 4004
					if math.abs(dx) > 520 then -- 4004
						goto __continue637 -- 4007
					end -- 4007
					e.awake = true -- 4009
					e.fireCd = 48 -- 4010
					goto __continue637 -- 4011
				end -- 4011
				if math.abs(dx) > ENEMY_RANGE then -- 4011
					goto __continue637 -- 4014
				end -- 4014
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 4014
					goto __continue637 -- 4019
				end -- 4019
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 4019
					goto __continue637 -- 4022
				end -- 4022
				if self:blockedShot(e, p) then -- 4022
					if e.warnT > 0 then -- 4022
						e.warnT = 0 -- 4028
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4029
					end -- 4029
					goto __continue637 -- 4031
				end -- 4031
				if e.warnT > 0 then -- 4031
					e.warnT = e.warnT - 1 -- 4034
					if e.warnT <= 0 then -- 4034
						self:campaignEnemyFire(e) -- 4036
					end -- 4036
				elseif e.fireCd > 0 then -- 4036
					e.fireCd = e.fireCd - 1 -- 4039
					if e.fireCd <= 0 then -- 4039
						e.warnT = WARN_TICKS -- 4041
					end -- 4041
				else -- 4041
					e.fireCd = 40 -- 4044
				end -- 4044
			end -- 4044
			::__continue637:: -- 4044
			i = i + 1 -- 3977
		end -- 3977
	end -- 3977
end -- 3974
function Play.prototype.blockedShot(self, e, p) -- 4050
	local eDepth = e.depth or 0 -- 4051
	local ex = e.x -- 4052
	local ey = e.y + e.h * 0.62 -- 4054
	local px = p.x -- 4055
	local py = p.y + p.h * 0.55 -- 4056
	local dx = px - ex -- 4057
	local dyScreen = py + p.depth * DEPTH_Y_SCALE - (ey + eDepth * DEPTH_Y_SCALE) -- 4058
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 4059
	if len < 0.01 then -- 4059
		return false -- 4061
	end -- 4061
	local ray = { -- 4065
		x = ex, -- 4066
		y = ey, -- 4066
		dx = dx / len, -- 4067
		dy = (py - ey) / len, -- 4067
		depth = eDepth, -- 4068
		dDepth = (p.depth - eDepth) / len -- 4068
	} -- 4068
	local best = -1 -- 4070
	local j = 0 -- 4071
	do -- 4071
		j = 0 -- 4072
		while j < #self.boxes do -- 4072
			do -- 4072
				local b = self.boxes[j + 1] -- 4073
				if b.broken == true or b.passable == true or b.hidden == true then -- 4073
					goto __continue660 -- 4075
				end -- 4075
				if b.id == "braced_shield" then -- 4075
					goto __continue660 -- 4080
				end -- 4080
				local t = hitBox(ray, b) -- 4082
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 4082
					best = t -- 4086
				end -- 4086
			end -- 4086
			::__continue660:: -- 4086
			j = j + 1 -- 4072
		end -- 4072
	end -- 4072
	return best >= 0 -- 4089
end -- 4050
function Play.prototype.campaignEnemyFire(self, e) -- 4092
	local p = self.player -- 4093
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4094
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 4094
		local ____self_bracedShield_115, ____hp_116 = self.bracedShield, "hp" -- 4094
		____self_bracedShield_115[____hp_116] = ____self_bracedShield_115[____hp_116] - 1 -- 4096
		if self.bracedShield.hp <= 0 then -- 4096
			self.boxes = __TS__ArrayFilter( -- 4098
				self.boxes, -- 4098
				function(____, b) return b.id ~= "braced_shield" end -- 4098
			) -- 4098
			self.bracedShield = nil -- 4099
			self:flashSet("残盾碎 · 挡下一发", 1) -- 4100
		else -- 4100
			self:flashSet( -- 4102
				"残盾挡下一发 · 余" .. tostring(self.bracedShield.hp), -- 4102
				1 -- 4102
			) -- 4102
		end -- 4102
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 4104
		return -- 4105
	end -- 4105
	if self:blockedShot(e, p) then -- 4105
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4108
		return -- 4109
	end -- 4109
	local cover = self:blockedByCover(e, p) -- 4111
	if cover ~= nil and self.coverHug then -- 4111
		self.coveredFlash = 0.5 -- 4113
		self:flashSet("掩体挡下", 0.6) -- 4114
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4115
		return -- 4120
	end -- 4120
	if self.invulnT > 0 then -- 4120
		return -- 4123
	end -- 4123
	self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4125
	self.craftT = 0 -- 4126
	self.hp = self.hp - 1 -- 4127
	self:emit("actorHit", { -- 4128
		target = "player", -- 4128
		amount = 1, -- 4128
		hp = self.hp, -- 4128
		maxHp = self.maxHp, -- 4128
		enemyX = e.x -- 4128
	}) -- 4128
	self:flashSet( -- 4129
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4129
		0.8 -- 4129
	) -- 4129
	if self.hp <= 0 then -- 4129
		self:campaignFailed() -- 4131
	end -- 4131
end -- 4092
function Play.prototype.stepShield(self, e, dt, input) -- 4136
	local p = self.player -- 4137
	local dx = p.x - e.x -- 4138
	local adx = math.abs(dx) -- 4139
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 4142
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 4143
	if adx > 44 then -- 4143
		local before = e.x -- 4145
		local stepX = (dx > 0 and 1 or -1) * 60 * dt -- 4146
		local nextX = math.max( -- 4147
			self.room.minX + 16, -- 4147
			math.min(self.room.maxX - 16, e.x + stepX) -- 4147
		) -- 4147
		if not self:enemyBlockedAtX(e, nextX) then -- 4147
			e.x = nextX -- 4149
		end -- 4149
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 4149
			e.depth = math.max( -- 4153
				-32, -- 4153
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4153
			) -- 4153
		end -- 4153
	elseif adx <= 48 and sameLane and (e.swingT or 0) <= 0 then -- 4153
		local fromFront = (e.x - p.x) * p.facing > 0 -- 4158
		local rollDodges = p.rollT > 0 and (fromFront or self:talentRank("guard") > 0) -- 4159
		if not rollDodges and self.invulnT <= 0 then -- 4159
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
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4165
				0.8 -- 4165
			) -- 4165
			if self.hp <= 0 then -- 4165
				self:campaignFailed() -- 4167
				return -- 4168
			end -- 4168
		end -- 4168
		e.swingT = 70 -- 4171
	end -- 4171
	if (e.swingT or 0) > 0 then -- 4171
		e.swingT = (e.swingT or 0) - 1 -- 4174
	end -- 4174
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 4174
		local dd = p.depth - (e.depth or 0) -- 4177
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 4178
	end -- 4178
end -- 4136
function Play.prototype.stepBreaker(self, e, dt) -- 4183
	local p = self.player -- 4184
	if e.awake ~= true then -- 4184
		if math.abs(p.x - e.x) < 560 then -- 4184
			e.awake = true -- 4187
		else -- 4187
			return -- 4189
		end -- 4189
	end -- 4189
	local target = nil -- 4192
	local bestD = 1000000000 -- 4193
	local i = 0 -- 4194
	do -- 4194
		i = 0 -- 4195
		while i < #self.boxes do -- 4195
			do -- 4195
				local b = self.boxes[i + 1] -- 4196
				if b.breakable == nil or b.broken == true then -- 4196
					goto __continue687 -- 4198
				end -- 4198
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 4200
				if d < bestD then -- 4200
					bestD = d -- 4202
					target = b -- 4203
				end -- 4203
			end -- 4203
			::__continue687:: -- 4203
			i = i + 1 -- 4195
		end -- 4195
	end -- 4195
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 4206
	local dx = tx - e.x -- 4207
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 4208
	if math.abs(dx) > reach then -- 4208
		local before = e.x -- 4210
		local nextX = math.max( -- 4211
			self.room.minX + 16, -- 4211
			math.min(self.room.maxX - 16, e.x + (dx > 0 and 1 or -1) * 48 * dt) -- 4211
		) -- 4211
		if not self:enemyBlockedAtX(e, nextX) then -- 4211
			e.x = nextX -- 4213
		end -- 4213
		if math.abs(e.x - before) < 0.3 then -- 4213
			e.depth = math.max( -- 4216
				-32, -- 4216
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4216
			) -- 4216
		end -- 4216
	elseif (e.swingT or 0) <= 0 then -- 4216
		e.swingT = 64 -- 4219
		if target ~= nil then -- 4219
			self:damageProp(target, 2) -- 4221
		elseif math.abs(p.x - e.x) < 60 and math.abs((e.depth or 0) - p.depth) <= 26 and not (p.rollT > 0 and self:talentRank("guard") > 0) and self.invulnT <= 0 then -- 4221
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4224
			self.craftT = 0 -- 4225
			self.hp = self.hp - 1 -- 4226
			self:emit("actorHit", { -- 4227
				target = "player", -- 4227
				amount = 1, -- 4227
				hp = self.hp, -- 4227
				maxHp = self.maxHp, -- 4227
				enemyX = e.x -- 4227
			}) -- 4227
			self:flashSet("破障手近身", 0.8) -- 4228
			if self.hp <= 0 then -- 4228
				self:campaignFailed() -- 4230
				return -- 4231
			end -- 4231
		end -- 4231
	end -- 4231
	if (e.swingT or 0) > 0 then -- 4231
		e.swingT = (e.swingT or 0) - 1 -- 4236
	end -- 4236
end -- 4183
function Play.prototype.enemyBlockedAtX(self, e, nextX) -- 4241
	local half = e.w * 0.5 -- 4242
	local d = e.depth or 0 -- 4243
	local i = 0 -- 4244
	do -- 4244
		i = 0 -- 4245
		while i < #self.boxes do -- 4245
			do -- 4245
				local b = self.boxes[i + 1] -- 4246
				if b.broken == true or b.passable == true or b.soft == true or b.hidden == true or b.y0 >= e.y + e.h or b.y1 <= e.y + 4 then -- 4246
					goto __continue700 -- 4248
				end -- 4248
				if b.depth ~= nil and (d < b.depth.min - 8 or d > b.depth.max + 8) then -- 4248
					goto __continue700 -- 4251
				end -- 4251
				if nextX + half > b.x0 and nextX - half < b.x1 then -- 4251
					return true -- 4254
				end -- 4254
			end -- 4254
			::__continue700:: -- 4254
			i = i + 1 -- 4245
		end -- 4245
	end -- 4245
	return false -- 4257
end -- 4241
function Play.prototype.campaignFailed(self) -- 4260
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 4260
		if self.escortFailed then -- 4260
			return -- 4265
		end -- 4265
		if self.useEscortDeathSummary then -- 4265
			local story = self.run.story -- 4267
			local st = story.talents -- 4268
			local ranksCopy = { -- 4269
				vitality = st and st.ranks.vitality or 0, -- 4270
				guard = st and st.ranks.guard or 0, -- 4271
				stride = st and st.ranks.stride or 0, -- 4272
				focus = st and st.ranks.focus or 0, -- 4273
				push_force = st and st.ranks.push_force or 0, -- 4274
				echo_wide = st and st.ranks.echo_wide or 0, -- 4275
				lantern_pierce = st and st.ranks.lantern_pierce or 0, -- 4276
				salvage = st and st.ranks.salvage or 0 -- 4277
			} -- 4277
			local cleared = 0 -- 4279
			local segKeys = { -- 4280
				"escort1", -- 4280
				"escort2", -- 4280
				"escort3", -- 4280
				"escort4", -- 4280
				"escort5" -- 4280
			} -- 4280
			local si = 0 -- 4281
			do -- 4281
				si = 0 -- 4282
				while si < #segKeys do -- 4282
					if story.segments[segKeys[si + 1]] == true then -- 4282
						cleared = cleared + 1 -- 4284
					end -- 4284
					si = si + 1 -- 4282
				end -- 4282
			end -- 4282
			self.escortFailed = true -- 4287
			self.escortFailedTicks = 0 -- 4288
			self.talentModalActive = false -- 4289
			self.craftBench.active = false -- 4290
			self.reloadT = 0 -- 4291
			self:closeReloadPuzzle() -- 4292
			self.gripping = false -- 4293
			self.escortSummary = { -- 4294
				roomKey = self.room.key, -- 4295
				attempt = st ~= nil and math.max(1, st.attempt) or 1, -- 4296
				seed = st ~= nil and st.randomState or self.run.seed, -- 4297
				equippedWeapon = self.equippedWeapon, -- 4298
				segmentsCleared = cleared, -- 4299
				ranks = ranksCopy -- 4300
			} -- 4300
			self:resetEscortAttempt() -- 4302
			self:flashSet("折返山道 · 重整再赴", 2) -- 4303
			self:log("男主线折返 · 展示小结") -- 4304
			self:emit("campaignFailed", { -- 4305
				room = self.room.key, -- 4306
				hp = 0, -- 4306
				maxHp = self.maxHp, -- 4306
				reset = true, -- 4307
				to = "escort1", -- 4307
				route = self.storyRoute, -- 4307
				summary = true -- 4307
			}) -- 4307
			return -- 4309
		end -- 4309
		self:restartEscortRun() -- 4311
		return -- 4312
	end -- 4312
	local p = self.player -- 4314
	self.hp = self.maxHp -- 4315
	self.invulnT = INVULN_RESPAWN_TICKS -- 4316
	self.reloadT = 0 -- 4317
	self:closeReloadPuzzle() -- 4318
	self.gripping = false -- 4319
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 4320
	self:log("被击倒") -- 4321
	p.x = self.room.minX + 90 -- 4322
	p.y = 0 -- 4323
	p.depth = 0 -- 4324
	p.vx = 0 -- 4325
	p.vy = 0 -- 4326
	p.onGround = true -- 4327
	p.rollT = 0 -- 4328
	self.partner.x = p.x - 50 -- 4329
	self.partner.y = 0 -- 4330
	self.partner.depth = 0 -- 4331
	self.cam.x = p.x -- 4332
	local i = 0 -- 4333
	do -- 4333
		i = 0 -- 4334
		while i < #self.enemies do -- 4334
			do -- 4334
				local e = self.enemies[i + 1] -- 4335
				if not e.alive then -- 4335
					goto __continue712 -- 4337
				end -- 4337
				e.x = e.homeX == nil and e.x or e.homeX -- 4339
				e.warnT = 0 -- 4340
				e.fireCd = 40 -- 4341
				e.swingT = 0 -- 4342
				e.awake = false -- 4343
			end -- 4343
			::__continue712:: -- 4343
			i = i + 1 -- 4334
		end -- 4334
	end -- 4334
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4345
end -- 4260
function Play.prototype.isEscortRoom(self) -- 4349
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 4350
end -- 4349
function Play.prototype.confirmEscortRestart(self) -- 4354
	if not self.escortFailed then -- 4354
		return false -- 4356
	end -- 4356
	self:requestRoom("escort1", "男主线失败重开") -- 4358
	return true -- 4359
end -- 4354
function Play.prototype.restartEscortRun(self) -- 4363
	self:resetEscortAttempt() -- 4364
	self:requestRoom("escort1", "男主线失败重开") -- 4365
end -- 4363
function Play.prototype.resetEscortAttempt(self) -- 4373
	local story = self.run.story -- 4374
	local inv = self.run.inventory -- 4375
	local prevAttempt = story.talents ~= nil and math.max(1, story.talents.attempt) or 1 -- 4376
	local nextAttempt = prevAttempt + 1 -- 4377
	local vitBonus = story.talents ~= nil and (story.talents.ranks.vitality or 0) or 0 -- 4378
	if vitBonus > 0 then -- 4378
		self.maxHp = math.max(3, self.maxHp - vitBonus) -- 4380
		story.maxHp = self.maxHp -- 4381
	end -- 4381
	story.talents = createStoryTalents(self.run.seed, nextAttempt) -- 4383
	self.hp = self.maxHp -- 4384
	story.hp = self.maxHp -- 4385
	story.cp = nil -- 4386
	self.checkpointSnap = nil -- 4387
	story.carry = false -- 4388
	self.carryOn = false -- 4389
	story.craftedWeapon = "" -- 4390
	self.equippedWeapon = "standard_gun" -- 4391
	story.equippedWeapon = "standard_gun" -- 4392
	story.escortDone = false -- 4393
	self.escortDone = false -- 4394
	story.segments = {} -- 4395
	inv.wood = 0 -- 4396
	inv.bell = 0 -- 4397
	inv.scrap = 0 -- 4398
	inv.wedge = 0 -- 4399
	inv.ammo = 0 -- 4400
	inv.quickbelt = 0 -- 4401
	inv.shield = 0 -- 4402
	inv.pass = 0 -- 4403
	local taken = self.run.taken -- 4404
	local keys = __TS__ObjectKeys(taken) -- 4405
	local i = 0 -- 4406
	do -- 4406
		i = 0 -- 4407
		while i < #keys do -- 4407
			local k = keys[i + 1] -- 4408
			if (string.find(k, "e2_", nil, true) or 0) - 1 == 0 or (string.find(k, "e3_", nil, true) or 0) - 1 == 0 or (string.find(k, "escort", nil, true) or 0) - 1 == 0 then -- 4408
				__TS__Delete(taken, k) -- 4410
			end -- 4410
			i = i + 1 -- 4407
		end -- 4407
	end -- 4407
	local propKeys = __TS__ObjectKeys(self.run.props) -- 4413
	do -- 4413
		i = 0 -- 4414
		while i < #propKeys do -- 4414
			local pk = propKeys[i + 1] -- 4415
			if (string.find(pk, "e1_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e2_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e3_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e4_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e5_", nil, true) or 0) - 1 == 0 or (string.find(pk, "field_wedge_", nil, true) or 0) - 1 == 0 then -- 4415
				__TS__Delete(self.run.props, pk) -- 4418
			end -- 4418
			i = i + 1 -- 4414
		end -- 4414
	end -- 4414
	self.bracedShield = nil -- 4421
	self.talentModalActive = false -- 4422
	self.run.joined = true -- 4423
	self.reloadT = 0 -- 4424
	self:closeReloadPuzzle() -- 4425
	self.gripping = false -- 4426
	self.sessionDirty = true -- 4427
	self:flashSet( -- 4428
		("重整启程 · 第" .. tostring(nextAttempt)) .. "轮护送", -- 4428
		2 -- 4428
	) -- 4428
	self:log(("男主线重开 · 第" .. tostring(nextAttempt)) .. "轮回 escort1") -- 4429
	if not self.useEscortDeathSummary then -- 4429
		self:emit("campaignFailed", { -- 4431
			room = self.room.key, -- 4432
			hp = 0, -- 4432
			maxHp = self.maxHp, -- 4432
			reset = true, -- 4433
			to = "escort1", -- 4433
			route = self.storyRoute, -- 4433
			attempt = nextAttempt -- 4433
		}) -- 4433
	end -- 4433
end -- 4373
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 4439
	local i = 0 -- 4440
	do -- 4440
		i = 0 -- 4441
		while i < #self.enemies do -- 4441
			do -- 4441
				if i == skipIndex then -- 4441
					goto __continue729 -- 4443
				end -- 4443
				local e = self.enemies[i + 1] -- 4445
				if not e.alive or math.abs(e.x - center.x) > radius then -- 4445
					goto __continue729 -- 4447
				end -- 4447
				e.awake = true -- 4449
				e.fireCd = math.max(e.fireCd or 0, 150) -- 4450
				e.warnT = 0 -- 4451
			end -- 4451
			::__continue729:: -- 4451
			i = i + 1 -- 4441
		end -- 4441
	end -- 4441
end -- 4439
function Play.prototype.stepEnemies(self, dt, input) -- 4455
	local i = 0 -- 4456
	do -- 4456
		i = 0 -- 4457
		while i < #self.enemies do -- 4457
			local e = self.enemies[i + 1] -- 4458
			if e.hitT > 0 then -- 4458
				e.hitT = e.hitT - dt -- 4460
			end -- 4460
			i = i + 1 -- 4457
		end -- 4457
	end -- 4457
	if self.coveredFlash > 0 then -- 4457
		self.coveredFlash = self.coveredFlash - dt -- 4464
	end -- 4464
	if self.isCampaign then -- 4464
		self:stepCampaignEnemies(dt, input) -- 4467
		return -- 4468
	end -- 4468
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 4468
		return -- 4472
	end -- 4472
	do -- 4472
		i = 0 -- 4474
		while i < #self.enemies do -- 4474
			do -- 4474
				local e = self.enemies[i + 1] -- 4475
				if not e.alive then -- 4475
					goto __continue740 -- 4477
				end -- 4477
				if e.warnT > 0 then -- 4477
					e.warnT = e.warnT - 1 -- 4480
					if e.warnT <= 0 then -- 4480
						self:enemyFire(e, input) -- 4482
					end -- 4482
					goto __continue740 -- 4484
				end -- 4484
				if e.fireCd > 0 then -- 4484
					e.fireCd = e.fireCd - 1 -- 4487
					if e.fireCd <= 0 then -- 4487
						e.warnT = WARN_TICKS -- 4489
					end -- 4489
				else -- 4489
					e.warnT = WARN_TICKS -- 4493
				end -- 4493
			end -- 4493
			::__continue740:: -- 4493
			i = i + 1 -- 4474
		end -- 4474
	end -- 4474
end -- 4455
function Play.prototype.enemyFire(self, e, input) -- 4499
	local p = self.player -- 4500
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 4500
		self:flashSet("枪声响在远处", 0.4) -- 4502
		e.fireCd = FIRE_COOLDOWN -- 4503
		return -- 4504
	end -- 4504
	if self:blockedShot(e, p) then -- 4504
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4507
		e.fireCd = FIRE_COOLDOWN -- 4508
		return -- 4509
	end -- 4509
	local cover = self:blockedByCover(e, p) -- 4512
	local hugging = cover ~= nil -- 4513
	self.coverBlocking = hugging -- 4514
	local covered = hugging and input.cover.held -- 4515
	if covered then -- 4515
		self.coveredFlash = 0.5 -- 4517
		self:flashSet("掩体挡下", 0.5) -- 4518
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4519
		e.fireCd = FIRE_COOLDOWN -- 4524
		return -- 4525
	end -- 4525
	if self.invulnT > 0 then -- 4525
		e.fireCd = FIRE_COOLDOWN -- 4528
		return -- 4529
	end -- 4529
	self.invulnT = INVULN_HIT_TICKS -- 4531
	self.hp = self.hp - 1 -- 4532
	self:emit("actorHit", { -- 4533
		target = "player", -- 4533
		amount = 1, -- 4533
		hp = self.hp, -- 4533
		maxHp = self.maxHp, -- 4533
		enemyX = e.x -- 4533
	}) -- 4533
	self:flashSet( -- 4534
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4534
		0.7 -- 4534
	) -- 4534
	e.fireCd = FIRE_COOLDOWN -- 4535
	if self.hp <= 0 then -- 4535
		self:gateFailed() -- 4537
	end -- 4537
end -- 4499
function Play.prototype.blockedByCover(self, enemy, p) -- 4542
	local b = self:coverAt(p) -- 4543
	if b == nil then -- 4543
		return nil -- 4545
	end -- 4545
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4547
end -- 4542
function Play.prototype.gateFailed(self) -- 4551
	local ____temp_133 -- 4552
	if self.room.story == nil then -- 4552
		____temp_133 = nil -- 4552
	else -- 4552
		____temp_133 = self.room.story.gate -- 4552
	end -- 4552
	local g = ____temp_133 -- 4552
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 4553
	self.hp = self.maxHp -- 4554
	self.gateTick = 0 -- 4555
	self.gateSpawned = 0 -- 4556
	self.enemies = {} -- 4557
	self.gateFailCount = self.gateFailCount + 1 -- 4558
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 4560
	self.player.y = 0 -- 4561
	self.player.vy = 0 -- 4562
	self.player.depth = 0 -- 4563
	self.player.depthSpeed = 0 -- 4564
	self.player.onGround = true -- 4565
	self.player.crouch = false -- 4566
	self.player.h = SOLDIER_H -- 4567
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 4568
	self.partner.y = 0 -- 4569
	self.partner.vy = 0 -- 4570
	self.partner.depth = 0 -- 4571
	self.partner.depthSpeed = 0 -- 4572
	self.partner.onGround = true -- 4573
	self.cam.x = self.player.x -- 4574
	self.phase = "gate-idle" -- 4575
	self.phaseTick = 0 -- 4576
	self.coverHug = false -- 4577
	self.coverBlocking = false -- 4578
	self.coverEntity = "" -- 4579
	self.gateNeedConfirm = true -- 4580
	self.gateRestartArmed = false -- 4581
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 4582
end -- 4551
function Play.prototype.stepRedCart(self, input) -- 4586
	if self.redCartMemoryT > 0 then -- 4586
		self.redCartMemoryT = self.redCartMemoryT - 1 -- 4588
	end -- 4588
	if self.room.key ~= "outside" or self.redCartPulled then -- 4588
		return -- 4591
	end -- 4591
	local box = __TS__ArrayFind( -- 4593
		self.boxes, -- 4593
		function(____, b) return b.id == "outside_red_cart" end -- 4593
	) -- 4593
	if box == nil then -- 4593
		self.redCartPulled = true -- 4595
		return -- 4596
	end -- 4596
	local cx = (box.x0 + box.x1) * 0.5 -- 4598
	local p = self.player -- 4599
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 4599
		return -- 4601
	end -- 4601
	if not input.interact.pressed then -- 4601
		return -- 4604
	end -- 4604
	box.x0 = 430 -- 4606
	box.x1 = 474 -- 4607
	self.cartAxle = self.room.cart.endX -- 4609
	self.cartDocked = true -- 4610
	self.redCartPulled = true -- 4611
	self.redCartMemoryT = 30 -- 4612
	if self.run.story ~= nil then -- 4612
		self.run.story.segments.outside_cart = true -- 4614
		self.run.story.segments.outside_memory = true -- 4615
	end -- 4615
	self.sessionDirty = true -- 4617
	self:flashSet("红布补丁 · 想起家里那一针 · 石阶口露出来", 1.8) -- 4618
	self:emit("storyBeat", {beat = "red_cart", x = p.x, room = "outside"}) -- 4619
	self:emit("storyBeat", {beat = "red_cart_memory", x = p.x, room = "outside", durationTicks = 30}) -- 4620
end -- 4586
function Play.prototype.stepInteract(self, dt, input) -- 4623
	local p = self.player -- 4624
	self:stepRedCart(input) -- 4625
	local calmUsed = self.calmConsumed -- 4626
	self.calmConsumed = false -- 4627
	local calming = self.escort.state == "calming" -- 4629
	self.focusCart = false -- 4630
	if self.room.key == "outside" then -- 4630
		local c = self.room.cart -- 4632
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 4633
		local dy = p.y - c.baseY -- 4634
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 4635
	end -- 4635
	if not calmUsed and not calming then -- 4635
		self:stepCart(dt, input) -- 4639
	end -- 4639
	if calmUsed then -- 4639
		self:flashSet("安抚 · 敲两下", 0.8) -- 4644
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4644
		if self.knockT > 0 then -- 4644
			self.knocks = self.knocks + 1 -- 4648
		else -- 4648
			self.knocks = 1 -- 4650
		end -- 4650
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4652
		self.knockT = 1.2 -- 4653
		if self.knocks >= 2 then -- 4653
			self:flashSet("敲两下", 0.8) -- 4655
			self.knocks = 0 -- 4656
		else -- 4656
			self:flashSet("敲一下", 0.5) -- 4658
		end -- 4658
	elseif self.knockT > 0 then -- 4658
		self.knockT = self.knockT - dt -- 4661
		if self.knockT <= 0 then -- 4661
			self.knocks = 0 -- 4663
		end -- 4663
	end -- 4663
	local i = 0 -- 4668
	do -- 4668
		i = 0 -- 4669
		while i < #self.room.marks do -- 4669
			do -- 4669
				local m = self.room.marks[i + 1] -- 4670
				if m.kind ~= 0 then -- 4670
					goto __continue776 -- 4672
				end -- 4672
				local subjects = {self.partner, self.player} -- 4674
				local k = 0 -- 4675
				do -- 4675
					k = 0 -- 4676
					while k < #subjects do -- 4676
						do -- 4676
							local s = subjects[k + 1] -- 4677
							if not s.alive then -- 4677
								goto __continue779 -- 4679
							end -- 4679
							local dx = s.x - m.x -- 4681
							local dy = s.y - m.y -- 4682
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4682
								self.checkpoint = m.x -- 4684
								self.checkpointCartAxle = self.cartAxle -- 4685
								if self.isCampaign then -- 4685
									self:captureCheckpoint(m.x) -- 4688
								end -- 4688
								if self.room.cart.bodyW > 0 then -- 4688
									if self.cartDocked then -- 4688
										self:flashSet("检查点 · 车已落窝", 1) -- 4692
									else -- 4692
										self:flashSet("检查点 · 车还没到位", 1) -- 4694
									end -- 4694
								else -- 4694
									self:flashSet("检查点", 1) -- 4697
								end -- 4697
							end -- 4697
						end -- 4697
						::__continue779:: -- 4697
						k = k + 1 -- 4676
					end -- 4676
				end -- 4676
			end -- 4676
			::__continue776:: -- 4676
			i = i + 1 -- 4669
		end -- 4669
	end -- 4669
	self:checkCarryGate() -- 4703
end -- 4623
function Play.prototype.stepVillage(self, dt, input) -- 4707
	if self.room.key ~= "village" then -- 4707
		return -- 4709
	end -- 4709
	local p = self.player -- 4711
	local bottle = self.room.bottle -- 4712
	local scav = self.room.scavenger -- 4713
	if not self.hasBottle and bottle ~= nil then -- 4713
		local dx = p.x - bottle.x -- 4717
		local dy = p.y + p.h * 0.5 - bottle.y -- 4718
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4718
			self.hasBottle = true -- 4720
			self:flashSet("拾起瓶子", 0.8) -- 4721
		end -- 4721
	end -- 4721
	if self.hasBottle then -- 4721
		if input.bottleCanceled then -- 4721
			self.aimHold = 0 -- 4728
			self.bottleAimX = -1 -- 4729
		elseif input.aim.held then -- 4729
			self.aimHold = self.aimHold + dt -- 4731
			if self.aimHold > 1.2 then -- 4731
				self.aimHold = 1.2 -- 4733
			end -- 4733
			local cached = self:bottleEnd() -- 4736
			self.bottleAimX = cached.x -- 4737
			self.bottleAimY = cached.y -- 4738
		elseif input.aim.released then -- 4738
			if self.aimHold < 0.12 then -- 4738
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 4742
				self.aimHold = 0 -- 4743
			else -- 4743
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4745
				self:throwBottle(____end.x, ____end.y) -- 4746
				self.aimHold = 0 -- 4747
			end -- 4747
		end -- 4747
	else -- 4747
		self.aimHold = 0 -- 4751
		self.bottleAimX = -1 -- 4752
	end -- 4752
	local fly = self.bottleFly -- 4757
	if fly ~= nil then -- 4757
		fly.t = fly.t + dt -- 4759
		fly.x = fly.x0 + fly.vx * fly.t -- 4760
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4761
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4762
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4762
			self:landBottle(fly) -- 4764
		end -- 4764
	end -- 4764
	if self.bottleLandT > 0 then -- 4764
		self.bottleLandT = self.bottleLandT - dt -- 4768
	end -- 4768
	if scav ~= nil then -- 4768
		self:stepScav(dt, scav) -- 4772
	end -- 4772
	local line = self.room.passLine -- 4775
	if line ~= nil and not self.passed and p.x >= line then -- 4775
		self.passed = true -- 4777
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4778
	end -- 4778
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4781
	if underTable then -- 4781
		self.footHintT = self.footHintT - 1 -- 4783
		if self.footHintT <= 0 then -- 4783
			self.footHintT = 90 -- 4785
			local scavX = self.scavX -- 4786
			local near = math.abs(scavX - p.x) < 120 -- 4787
			local walkingAway = self.scavState == "walk" and math.abs(self.scavTargetX - p.x) >= 120 -- 4788
			local heard = self.scavState == "chase" or near and not walkingAway -- 4789
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4790
			self:emit("storyBeat", {beat = heard and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4791
		end -- 4791
	else -- 4791
		self.footHintT = 0 -- 4794
	end -- 4794
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4794
		self.ditchHinted = true -- 4798
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4799
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4800
	end -- 4800
	if self.passed and p.x >= self.ox + 640 then -- 4800
		self:requestRoom("forest", "过第一院出院") -- 4804
		self:flashSet("钻出暗渠 · 北塔森林", 1.4) -- 4805
	end -- 4805
end -- 4707
function Play.prototype.bottleEnd(self) -- 4810
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4811
	local clampedX = math.max( -- 4814
		self.room.minX + 12, -- 4814
		math.min(self.room.maxX - 12, aim.x) -- 4814
	) -- 4814
	local g = self:groundAt(clampedX, aim.y + 240, 3) -- 4815
	return {x = clampedX, y = g} -- 4816
end -- 4810
function Play.prototype.throwBottle(self, tx, ty) -- 4820
	local p = self.player -- 4821
	local dir = tx >= p.x and 1 or -1 -- 4823
	p.facing = dir -- 4824
	local x0 = p.x + dir * 10 -- 4825
	local y0 = p.y + p.h * 0.7 -- 4826
	self.bottleTargetX = tx -- 4827
	self.bottleTargetY = ty -- 4828
	self.bottleSurfaceY = ty -- 4829
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4830
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4831
	self.bottleFly = { -- 4832
		x = x0, -- 4832
		y = y0, -- 4832
		x0 = x0, -- 4832
		y0 = y0, -- 4832
		vx = vx, -- 4832
		vy = vy, -- 4832
		t = 0 -- 4832
	} -- 4832
	self.hasBottle = false -- 4833
	self:flashSet("投出", 0.4) -- 4834
	self:emit( -- 4835
		"bottleThrown", -- 4835
		{ -- 4835
			fromX = x0, -- 4836
			fromY = y0, -- 4837
			targetX = tx, -- 4838
			targetY = ty, -- 4839
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4840
		} -- 4840
	) -- 4840
end -- 4820
function Play.prototype.bottleSurfaceAt(self, x) -- 4845
	if self.room.softX ~= nil and math.abs(x - self.room.softX) <= 34 then -- 4845
		return "soft" -- 4847
	end -- 4847
	if self.room.basinX ~= nil and math.abs(x - self.room.basinX) <= 24 then -- 4847
		return "iron" -- 4850
	end -- 4850
	return "brick" -- 4852
end -- 4845
function Play.prototype.landBottle(self, fly) -- 4856
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4857
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4858
	local s = self.room.scavenger -- 4859
	local surface = self:bottleSurfaceAt(x) -- 4860
	local effRange = s == nil and 0 or (surface == "iron" and s.range * 1.25 or s.range) -- 4861
	local heard = surface ~= "soft" and s ~= nil and math.abs(x - self.scavX) <= effRange -- 4862
	local stallTicks = s == nil and 0 or (surface == "iron" and s.stallTicks + 90 or s.stallTicks) -- 4863
	self.bottleFly = nil -- 4864
	self.bottleTargetX = -1 -- 4865
	self.bottleTargetY = 0 -- 4866
	self.bottleSurfaceY = -1 -- 4867
	self.bottleLandX = x -- 4868
	self.bottleLandY = y -- 4869
	self.bottleLandT = 0.9 -- 4870
	self:emit("bottleLanded", { -- 4871
		x = x, -- 4872
		y = y, -- 4873
		surface = surface, -- 4874
		heard = heard, -- 4875
		resonance = surface == "iron", -- 4876
		stallTicks = heard and stallTicks or 0, -- 4877
		scavState = self.scavState -- 4878
	}) -- 4878
	self:hearBottle(x, surface) -- 4880
end -- 4856
function Play.prototype.hearBottle(self, x, surface) -- 4884
	if surface == nil then -- 4884
		surface = "brick" -- 4884
	end -- 4884
	local s = self.room.scavenger -- 4885
	if s == nil then -- 4885
		return -- 4887
	end -- 4887
	if surface == "soft" then -- 4887
		self:flashSet("落在软土 · 没出声", 0.8) -- 4890
		return -- 4891
	end -- 4891
	local effRange = surface == "iron" and s.range * 1.25 or s.range -- 4893
	if math.abs(x - self.scavX) > effRange then -- 4893
		self:flashSet("落地 · 他没听见", 0.6) -- 4895
		return -- 4896
	end -- 4896
	self.scavState = "turn" -- 4898
	self.scavT = s.hearTicks -- 4899
	self.scavTargetX = surface == "iron" and self.room.basinX ~= nil and self.room.basinX or x -- 4900
	self.scavStallBonus = surface == "iron" and 90 or 0 -- 4901
	self:flashSet(surface == "iron" and "铁盆余振两响 · 他停下来细听" or "砖地一响 · 他转头", 1.1) -- 4902
end -- 4884
function Play.prototype.stepScav(self, dt, s) -- 4906
	if self.scavState == "chase" then -- 4906
		return -- 4909
	end -- 4909
	if self.scavState == "turn" then -- 4909
		self.scavT = self.scavT - 1 -- 4912
		if self.scavT <= 0 then -- 4912
			self.scavState = "walk" -- 4914
		end -- 4914
		return -- 4916
	end -- 4916
	if self.scavState == "walk" then -- 4916
		local d = self.scavTargetX - self.scavX -- 4919
		if math.abs(d) < 4 then -- 4919
			self.scavState = "stall" -- 4921
			self.scavT = s.stallTicks + self.scavStallBonus -- 4922
			self.scavStallBonus = 0 -- 4923
			return -- 4924
		end -- 4924
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4926
		return -- 4927
	end -- 4927
	if self.scavState == "stall" then -- 4927
		self.scavT = self.scavT - 1 -- 4930
		if self.scavT <= 0 then -- 4930
			self.scavState = "back" -- 4932
		end -- 4932
		return -- 4934
	end -- 4934
	if self.scavState == "back" then -- 4934
		local home = math.max( -- 4937
			s.x0, -- 4937
			math.min(s.x1, self.scavX) -- 4937
		) -- 4937
		if math.abs(home - self.scavX) < 2 then -- 4937
			self.scavState = "patrol" -- 4939
			return -- 4940
		end -- 4940
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4942
		return -- 4943
	end -- 4943
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4945
	if self.scavX >= s.x1 then -- 4945
		self.scavX = s.x1 -- 4947
		self.scavDir = -1 -- 4948
	elseif self.scavX <= s.x0 then -- 4948
		self.scavX = s.x0 -- 4950
		self.scavDir = 1 -- 4951
	end -- 4951
end -- 4906
function Play.prototype.stepCart(self, dt, input) -- 4959
	local p = self.player -- 4960
	local c = self.room.cart -- 4961
	if self.gripping then -- 4961
		if not input.interact.held then -- 4961
			self.gripping = false -- 4965
			self:flashSet("松开车把", 0.4) -- 4966
			return -- 4967
		end -- 4967
	else -- 4967
		if not input.interact.pressed then -- 4967
			return -- 4971
		end -- 4971
		if not self:cartHandleInReach(p) then -- 4971
			return -- 4974
		end -- 4974
		local track = c.depth or 0 -- 4976
		if self:limitDepth(p, track) ~= track then -- 4976
			return -- 4978
		end -- 4978
		p.depth = track -- 4980
		p.depthSpeed = 0 -- 4981
		self.gripping = true -- 4982
		self:flashSet("握住车把", 0.4) -- 4983
		return -- 4984
	end -- 4984
	if self.cartDocked then -- 4984
		return -- 4988
	end -- 4988
	local dir = input.moveX -- 4990
	if dir == 0 then -- 4990
		return -- 4992
	end -- 4992
	local lo = math.min(c.startX, c.endX) -- 4994
	local hi = math.max(c.startX, c.endX) -- 4995
	local next = self.cartAxle + dir * CART_SPEED * dt -- 4996
	if next < lo then -- 4996
		next = lo -- 4998
	end -- 4998
	if next > hi then -- 4998
		next = hi -- 5001
	end -- 5001
	local delta = next - self.cartAxle -- 5003
	if delta == 0 then -- 5003
		return -- 5005
	end -- 5005
	self.cartAxle = next -- 5007
	p.x = p.x + delta -- 5008
	p.facing = dir > 0 and 1 or -1 -- 5009
	self:slideX(p, 0) -- 5010
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 5010
		self.gripping = false -- 5012
		self:flashSet("跟不上了，脱手", 0.6) -- 5013
		return -- 5014
	end -- 5014
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 5014
		self.cartDocked = true -- 5017
		self.gripping = false -- 5018
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 5019
		self:flashSet("车轮落窝", 1.2) -- 5020
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 5020
		self:flashSet("车轮回到起点", 0.5) -- 5022
	end -- 5022
end -- 4959
function Play.prototype.requestRoom(self, key, reason) -- 5030
	if self.wantRoom ~= "" then -- 5030
		return -- 5034
	end -- 5034
	self.wantRoom = key -- 5036
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 5037
end -- 5030
function Play.prototype.checkCarryGate(self) -- 5044
	if self.room.key == "checkpoint" then -- 5044
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 5044
			self.carryCartAxle = self.cartAxle -- 5047
			self.carryCartDocked = self.cartDocked -- 5048
			self:requestRoom("gate", "检查站出口") -- 5049
			self:flashSet("出检查站 · 城门", 1.2) -- 5050
		end -- 5050
		return -- 5052
	end -- 5052
	if self.room.key == "outside" then -- 5052
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 5052
			self.carryCartAxle = self.cartAxle -- 5058
			self.carryCartDocked = self.cartDocked -- 5059
			self:requestRoom("village", "墙根走完") -- 5060
			self:flashSet("墙根走完 · 进村口", 1.2) -- 5061
		end -- 5061
	end -- 5061
end -- 5044
function Play.prototype.aimAt(self, wx, wy) -- 5068
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 5069
	self.aimX = s.x -- 5070
	self.aimY = s.y -- 5071
end -- 5068
function Play.prototype.shoot(self, a) -- 5074
	if self.isCampaign and self.reloadT > 0 then -- 5074
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 5076
		return -- 5077
	end -- 5077
	local ox = a.x + a.facing * 8 -- 5079
	local muzzleY = a.y + a.h * 0.72 -- 5080
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 5081
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 5083
	local dx = aim.x - ox -- 5086
	local dy = aim.y - oy -- 5087
	local len = math.sqrt(dx * dx + dy * dy) -- 5088
	if len < 0.001 then -- 5088
		dx = a.facing -- 5090
		dy = 0 -- 5091
	else -- 5091
		dx = dx / len -- 5093
		dy = dy / len -- 5094
	end -- 5094
	if dx ~= 0 then -- 5094
		a.facing = dx > 0 and 1 or -1 -- 5097
	end -- 5097
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 5100
	local hitEnemy = self:raycastEnemies(ray) -- 5101
	local tEnemy = hitEnemy.t -- 5102
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 5103
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 5104
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 5105
	local tWall = solid.t -- 5106
	local rawEffect = self:consumeReloadEffect() -- 5108
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 5109
	local reloadEffect = rawEffect -- 5110
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 5112
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 5113
	self.trace = { -- 5115
		x0 = ox, -- 5115
		y0 = oy, -- 5115
		x1 = ox + dx * t, -- 5115
		y1 = oy + dy * t, -- 5115
		hit = hit -- 5115
	} -- 5115
	self.traceT = 0.12 -- 5116
	self:applyFireDanger(ox) -- 5117
	local killed = false -- 5118
	if hit then -- 5118
		local i = hitEnemy.index -- 5120
		local e = self.enemies[i + 1] -- 5121
		local impactY = oy + dy * tEnemy -- 5122
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 5123
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 5124
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 5124
			local pushRank = self:talentRank("push_force") -- 5126
			local dmg = reloadEffect == "push" and 2 + pushRank or 1 -- 5127
			e.shieldHp = math.max(0, (e.shieldHp or 0) - dmg) -- 5128
			e.hitT = 0.3 -- 5129
			if reloadEffect == "push" then -- 5129
				local kb = 46 + 24 * pushRank -- 5131
				e.x = math.max( -- 5132
					self.room.minX + 20, -- 5132
					math.min(self.room.maxX - 20, e.x + a.facing * kb) -- 5132
				) -- 5132
				if pushRank > 0 then -- 5132
					self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5134
				end -- 5134
				self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5136
				self:flashSet(e.shieldHp <= 0 and "推退破盾！" or "推退震退持盾手", 0.9) -- 5137
			else -- 5137
				self:flashSet( -- 5139
					(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 5139
					0.8 -- 5139
				) -- 5139
			end -- 5139
			self:emit("shotResolved", { -- 5141
				hit = true, -- 5142
				enemyIndex = i, -- 5142
				enemyX = e.x, -- 5142
				aimX = aim.x, -- 5142
				aimY = aim.y, -- 5142
				impactX = ox + dx * t, -- 5143
				impactY = oy + dy * t, -- 5143
				shield = true -- 5143
			}) -- 5143
			self:beginReload() -- 5145
			return -- 5146
		end -- 5146
		e.alive = false -- 5148
		e.hitT = 0.4 -- 5149
		killed = true -- 5150
		self:flashSet("命中", 0.6) -- 5151
		self:dropFor(e) -- 5152
		local lpRank = self:talentRank("lantern_pierce") -- 5153
		if reloadEffect == "light" and (weaponFx == "light" or lpRank > 0) then -- 5153
			local blindRadius = (weaponFx == "light" and 160 or 110) + 50 * lpRank -- 5155
			self:blindNearby(e, blindRadius, i) -- 5156
		end -- 5156
		if reloadEffect == "push" then -- 5156
			local pushRank = self:talentRank("push_force") -- 5159
			e.x = e.x + a.facing * (46 + 24 * pushRank) -- 5160
			if pushRank > 0 then -- 5160
				self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5162
			end -- 5162
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5164
		elseif reloadEffect == "echo" then -- 5164
			local echoRank = self:talentRank("echo_wide") -- 5166
			self:echoToSource(a, (weaponFx == "echo" and 2 or 1) + echoRank, 60 + 30 * echoRank) -- 5167
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 5168
		elseif reloadEffect == "light" then -- 5168
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 5170
		end -- 5170
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 5170
		self:damageProp(solid.box, 1) -- 5173
	else -- 5173
		self:flashSet("打空", 0.35) -- 5175
	end -- 5175
	if self.isCampaign then -- 5175
		self:beginReload() -- 5178
	end -- 5178
	self:emit("shotResolved", { -- 5180
		hit = hit, -- 5181
		enemyIndex = hit and hitEnemy.index or -1, -- 5182
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 5183
		aimX = aim.x, -- 5184
		aimY = aim.y, -- 5185
		impactX = ox + dx * t, -- 5186
		impactY = oy + dy * t -- 5187
	}) -- 5187
end -- 5074
function Play.prototype.staggerNearby(self, center, radius, delayTicks, skipIndex) -- 5192
	local i = 0 -- 5193
	do -- 5193
		i = 0 -- 5194
		while i < #self.enemies do -- 5194
			do -- 5194
				if i == skipIndex then -- 5194
					goto __continue874 -- 5196
				end -- 5196
				local e = self.enemies[i + 1] -- 5198
				if not e.alive or math.abs(e.x - center.x) > radius then -- 5198
					goto __continue874 -- 5200
				end -- 5200
				e.warnT = 0 -- 5202
				e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 5203
				local pushDir = e.x >= center.x and 1 or -1 -- 5204
				e.x = math.max( -- 5205
					self.room.minX + 20, -- 5205
					math.min(self.room.maxX - 20, e.x + pushDir * 22) -- 5205
				) -- 5205
			end -- 5205
			::__continue874:: -- 5205
			i = i + 1 -- 5194
		end -- 5194
	end -- 5194
end -- 5192
function Play.prototype.applyFireDanger(self, shotX) -- 5210
	local ____temp_139 = self.isCampaign and self.run.joined -- 5211
	if ____temp_139 then -- 5211
		local ____opt_134 = self.room.campaign -- 5211
		local ____temp_138 = (____opt_134 and ____opt_134.chapter) == "S" -- 5212
		if not ____temp_138 then -- 5212
			local ____opt_136 = self.room.campaign -- 5212
			____temp_138 = (____opt_136 and ____opt_136.chapter) == "C" -- 5212
		end -- 5212
		____temp_139 = ____temp_138 -- 5211
	end -- 5211
	local isStorySc = ____temp_139 -- 5211
	if self.room.key ~= "checkpoint" and not isStorySc or not self.partner.alive then -- 5211
		return -- 5214
	end -- 5214
	local dangerX = shotX -- 5216
	local best = -1 -- 5217
	local bestD = 1000000000 -- 5218
	local i = 0 -- 5219
	do -- 5219
		i = 0 -- 5220
		while i < #self.enemies do -- 5220
			do -- 5220
				local e = self.enemies[i + 1] -- 5221
				if not e.alive then -- 5221
					goto __continue880 -- 5223
				end -- 5223
				local d = math.abs(e.x - self.partner.x) -- 5225
				if d < bestD then -- 5225
					bestD = d -- 5227
					best = i -- 5228
				end -- 5228
			end -- 5228
			::__continue880:: -- 5228
			i = i + 1 -- 5220
		end -- 5220
	end -- 5220
	if best >= 0 then -- 5220
		dangerX = self.enemies[best + 1].x -- 5232
	end -- 5232
	if isStorySc and math.abs(dangerX - self.partner.x) > 260 then -- 5232
		return -- 5236
	end -- 5236
	local exposed = self:childExposed(dangerX) -- 5238
	local before = self.escort.fear -- 5239
	local dangerId = self.nextDangerId -- 5240
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 5241
	self.nextDangerId = self.nextDangerId + 1 -- 5242
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 5243
	if after > before then -- 5243
		self:flashSet( -- 5245
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 5245
			1 -- 5245
		) -- 5245
	elseif not exposed then -- 5245
		self:flashSet("枪声没够到她", 0.5) -- 5247
	end -- 5247
end -- 5210
function Play.prototype.childExposed(self, dangerX) -- 5252
	local c = self.partner -- 5253
	if not c.alive then -- 5253
		return false -- 5255
	end -- 5255
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 5255
		self.boxes, -- 5258
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 5258
	) then -- 5258
		return false -- 5259
	end -- 5259
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 5259
		return false -- 5262
	end -- 5262
	local toDanger = dangerX - c.x -- 5264
	local toPlayer = self.player.x - c.x -- 5265
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 5265
		return false -- 5268
	end -- 5268
	return true -- 5270
end -- 5252
function Play.prototype.raycastEnemies(self, ray) -- 5274
	local best = -1 -- 5275
	local bestI = -1 -- 5276
	do -- 5276
		local i = 0 -- 5277
		while i < #self.enemies do -- 5277
			do -- 5277
				local e = self.enemies[i + 1] -- 5278
				if not e.alive then -- 5278
					goto __continue895 -- 5280
				end -- 5280
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 5282
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 5283
				if t >= 0 and (best < 0 or t < best) then -- 5283
					best = t -- 5285
					bestI = i -- 5286
				end -- 5286
			end -- 5286
			::__continue895:: -- 5286
			i = i + 1 -- 5277
		end -- 5277
	end -- 5277
	return {t = best, index = bestI} -- 5289
end -- 5274
function Play.prototype.raycastWorld(self, ray) -- 5292
	return self:raycastSolid(ray).t -- 5293
end -- 5292
function Play.prototype.raycastSolid(self, ray) -- 5297
	local best = -1 -- 5298
	local bestBox = nil -- 5299
	for ____, box in ipairs(self.boxes) do -- 5300
		do -- 5300
			if box.broken == true or box.hidden == true then -- 5300
				goto __continue900 -- 5302
			end -- 5302
			local t = hitBox(ray, box) -- 5307
			if t > 2 and (best < 0 or t < best) then -- 5307
				best = t -- 5310
				bestBox = box -- 5311
			end -- 5311
		end -- 5311
		::__continue900:: -- 5311
	end -- 5311
	if ray.dy < 0 then -- 5311
		local t = -ray.y / ray.dy -- 5315
		if t >= 0 and (best < 0 or t < best) then -- 5315
			best = t -- 5317
			bestBox = nil -- 5318
		end -- 5318
	end -- 5318
	return {t = best, box = bestBox} -- 5321
end -- 5297
function Play.prototype.dropFor(self, e) -- 5325
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 5325
		return -- 5327
	end -- 5327
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 5327
		return -- 5330
	end -- 5330
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 5332
	local ____self_pickups_140 = self.pickups -- 5332
	____self_pickups_140[#____self_pickups_140 + 1] = { -- 5333
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 5334
		kind = e.drop, -- 5334
		x = e.x, -- 5334
		y = e.y, -- 5334
		depth = e.depth, -- 5335
		label = label .. " ×1" -- 5335
	} -- 5335
	self:log("掉落 " .. label) -- 5337
end -- 5325
function Play.prototype.damageProp(self, b, amount) -- 5341
	if b.breakable == nil or b.broken == true then -- 5341
		return -- 5343
	end -- 5343
	local ____b_breakable_141, ____hp_142 = b.breakable, "hp" -- 5343
	____b_breakable_141[____hp_142] = ____b_breakable_141[____hp_142] - amount -- 5345
	if b.breakable.hp > 0 then -- 5345
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 5347
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 5348
		return -- 5349
	end -- 5349
	b.broken = true -- 5351
	for ____, other in ipairs(self.boxes) do -- 5352
		if other.id ~= nil and other.id == b.id then -- 5352
			other.broken = true -- 5354
		end -- 5354
	end -- 5354
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 5357
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 5358
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 5359
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 5360
end -- 5341
function Play.prototype.slideDepth(self, a, distance) -- 5364
	a.depth = self:limitDepth(a, a.depth + distance) -- 5365
end -- 5364
function Play.prototype.limitDepth(self, a, target) -- 5368
	local road = self.room.depth -- 5369
	if road == nil or target == a.depth then -- 5369
		return a.depth -- 5371
	end -- 5371
	local next = math.max( -- 5373
		road.min, -- 5373
		math.min(road.max, target) -- 5373
	) -- 5373
	local half = a.w / 2 -- 5374
	for ____, b in ipairs(self.boxes) do -- 5375
		do -- 5375
			local footprint = b.depth -- 5376
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5376
				goto __continue918 -- 5381
			end -- 5381
			local front = footprint.min - ACTOR_DEPTH_HALF -- 5383
			local back = footprint.max + ACTOR_DEPTH_HALF -- 5384
			if a.depth <= front and next > front then -- 5384
				next = front -- 5386
			elseif a.depth >= back and next < back then -- 5386
				next = back -- 5388
			end -- 5388
		end -- 5388
		::__continue918:: -- 5388
	end -- 5388
	return next -- 5391
end -- 5368
function Play.prototype.slideX(self, a, dx) -- 5395
	local nx = a.x + dx -- 5396
	local half = a.w / 2 -- 5397
	local room = self.room -- 5398
	nx = math.max( -- 5399
		room.minX + half, -- 5399
		math.min(room.maxX - half, nx) -- 5399
	) -- 5399
	local i = 0 -- 5400
	do -- 5400
		i = 0 -- 5401
		while i < #self.boxes do -- 5401
			do -- 5401
				local b = self.boxes[i + 1] -- 5402
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5402
					goto __continue925 -- 5404
				end -- 5404
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5404
					goto __continue925 -- 5407
				end -- 5407
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5407
					goto __continue925 -- 5410
				end -- 5410
				if nx + half > b.x0 and nx - half < b.x1 then -- 5410
					if a.x <= b.x0 then -- 5410
						nx = b.x0 - half -- 5414
					elseif a.x >= b.x1 then -- 5414
						nx = b.x1 + half -- 5416
					else -- 5416
						nx = a.x -- 5418
					end -- 5418
				end -- 5418
			end -- 5418
			::__continue925:: -- 5418
			i = i + 1 -- 5401
		end -- 5401
	end -- 5401
	if self.room.key == "outside" and not self.cartDocked and a.y < CART_CLEAR - 0.001 then -- 5401
		local bx0 = math.max(room.arch.x0, self.cartAxle - CART_HALF) -- 5425
		local bx1 = math.min(room.arch.x1, self.cartAxle + CART_HALF) -- 5426
		if bx1 > bx0 and nx + half > bx0 and nx - half < bx1 then -- 5426
			if a.x <= bx0 then -- 5426
				nx = bx0 - half -- 5429
			elseif a.x >= bx1 then -- 5429
				nx = bx1 + half -- 5431
			else -- 5431
				nx = a.x -- 5433
			end -- 5433
		end -- 5433
	end -- 5433
	local arch = room.arch -- 5441
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 5441
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 5443
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 5443
			if a.x <= arch.x0 then -- 5443
				nx = arch.x0 - half -- 5446
			elseif a.x >= arch.x1 then -- 5446
				nx = arch.x1 + half -- 5448
			end -- 5448
		end -- 5448
	end -- 5448
	a.x = nx -- 5452
end -- 5395
function Play.prototype.fallY(self, a, dt) -- 5456
	a.vy = a.vy - ____exports.GRAVITY * dt -- 5457
	if a.vy < -900 then -- 5457
		a.vy = -900 -- 5459
	end -- 5459
	local ny = a.y + a.vy * dt -- 5461
	local half = a.w / 2 -- 5462
	if a.vy <= 0 then -- 5462
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 5465
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 5466
		if ny <= ground then -- 5466
			ny = ground -- 5468
			a.vy = 0 -- 5469
			a.onGround = true -- 5470
		else -- 5470
			a.onGround = false -- 5472
		end -- 5472
	else -- 5472
		a.onGround = false -- 5475
		local i = 0 -- 5476
		do -- 5476
			i = 0 -- 5477
			while i < #self.boxes do -- 5477
				do -- 5477
					local b = self.boxes[i + 1] -- 5478
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5478
						goto __continue949 -- 5480
					end -- 5480
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5480
						goto __continue949 -- 5483
					end -- 5483
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 5483
						goto __continue949 -- 5486
					end -- 5486
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 5486
						ny = b.y0 - a.h -- 5489
						a.vy = 0 -- 5490
					end -- 5490
				end -- 5490
				::__continue949:: -- 5490
				i = i + 1 -- 5477
			end -- 5477
		end -- 5477
	end -- 5477
	a.y = ny -- 5494
end -- 5456
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 5498
	if depth == nil then -- 5498
		depth = 0 -- 5498
	end -- 5498
	local g = -9999 -- 5499
	local i = 0 -- 5500
	do -- 5500
		i = 0 -- 5501
		while i < #self.floors do -- 5501
			local f = self.floors[i + 1] -- 5502
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 5502
				g = f.y1 -- 5504
			end -- 5504
			i = i + 1 -- 5501
		end -- 5501
	end -- 5501
	do -- 5501
		i = 0 -- 5507
		while i < #self.boxes do -- 5507
			do -- 5507
				local b = self.boxes[i + 1] -- 5508
				if b.broken == true or b.hidden == true or b.soft == true then -- 5508
					goto __continue959 -- 5510
				end -- 5510
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 5510
					g = b.y1 -- 5514
				end -- 5514
			end -- 5514
			::__continue959:: -- 5514
			i = i + 1 -- 5507
		end -- 5507
	end -- 5507
	return g -- 5517
end -- 5498
function Play.prototype.updateCamera(self, dt) -- 5520
	local p = self.player -- 5521
	local tx = p.x + p.facing * 30 -- 5522
	local ty = p.y + CAM_LOOK_UP -- 5523
	local k = math.min(1, CAM_FOLLOW * dt) -- 5524
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 5525
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 5526
end -- 5520
function Play.prototype.clampCamera(self, w, h) -- 5530
	local room = self.room -- 5531
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 5532
	local spanX = room.maxX - room.minX -- 5533
	if spanX <= halfW * 2 then -- 5533
		self.cam.x = (room.minX + room.maxX) / 2 -- 5535
	else -- 5535
		self.cam.x = math.max( -- 5537
			room.minX + halfW, -- 5537
			math.min(room.maxX - halfW, self.cam.x) -- 5537
		) -- 5537
	end -- 5537
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 5540
	local spanY = room.height -- 5541
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 5542
	if spanY <= halfH * 2 then -- 5542
		self.cam.y = camY -- 5544
	else -- 5544
		self.cam.y = math.max( -- 5546
			camY, -- 5546
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 5546
		) -- 5546
	end -- 5546
end -- 5530
function Play.prototype.flashSet(self, text, t) -- 5550
	self.flash = text -- 5551
	self.flashT = t -- 5552
end -- 5550
function Play.prototype.statusText(self) -- 5556
	local p = self.player -- 5557
	local parts = {} -- 5558
	local who = self.childMode and "小满" or "周戍" -- 5559
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 5560
	if self.room.key == "prologue" then -- 5560
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5563
		if self.phase == "prologue-wake" then -- 5563
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 5565
		elseif self.phase == "prologue-shadow" then -- 5565
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 5567
		elseif self.phase == "prologue-escape" then -- 5567
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 5569
		elseif self.phase == "prologue-hide" then -- 5569
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 5571
		elseif self.phase == "prologue-wait" then -- 5571
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 5573
		elseif self.phase == "prologue-give" then -- 5573
			parts[#parts + 1] = (("递物 " .. tostring(self.phaseTick)) .. "/") .. tostring(____exports.PROLOGUE_GIVE_TICKS) -- 5575
		else -- 5575
			parts[#parts + 1] = "跟随" -- 5577
		end -- 5577
		if self.paused then -- 5577
			parts[#parts + 1] = "已暂停" -- 5580
		end -- 5580
		return table.concat(parts, " · ") -- 5582
	end -- 5582
	if self.room.key == "street" then -- 5582
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5585
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5586
		if self.paused then -- 5586
			parts[#parts + 1] = "已暂停" -- 5588
		end -- 5588
		return table.concat(parts, " · ") -- 5590
	end -- 5590
	if self.room.key == "gate" then -- 5590
		local ____temp_143 -- 5593
		if self.room.story == nil then -- 5593
			____temp_143 = nil -- 5593
		else -- 5593
			____temp_143 = self.room.story.gate -- 5593
		end -- 5593
		local g = ____temp_143 -- 5593
		if g ~= nil then -- 5593
			parts[#parts + 1] = self:gateLabel() -- 5595
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 5596
				0, -- 5597
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 5597
			))) .. " 秒" -- 5597
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5598
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5599
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 5600
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 5601
			if self.gateFailCount > 0 then -- 5601
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 5603
			end -- 5603
			if self.flash ~= "" then -- 5603
				parts[#parts + 1] = self.flash -- 5606
			end -- 5606
		end -- 5606
		if self.paused then -- 5606
			parts[#parts + 1] = "已暂停" -- 5610
		end -- 5610
		return table.concat(parts, " · ") -- 5612
	end -- 5612
	if self.room.key == "forest" then -- 5612
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5615
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5616
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5617
		if self.caughtT > 0 then -- 5617
			parts[#parts + 1] = "复位中" -- 5619
		end -- 5619
		if self.paused then -- 5619
			parts[#parts + 1] = "已暂停" -- 5622
		end -- 5622
		return table.concat(parts, " · ") -- 5624
	end -- 5624
	if self.room.key == "tower" then -- 5624
		if self.phase == "tower-wait" then -- 5624
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5628
		elseif self.phase == "tower-knock" then -- 5628
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5630
		elseif self.phase == "tower-enter" then -- 5630
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5632
		elseif self.phase == "tower-desk" then -- 5632
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5634
		elseif self.phase == "tower-given" then -- 5634
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5636
		else -- 5636
			parts[#parts + 1] = "片尾" -- 5638
		end -- 5638
		if self.paused then -- 5638
			parts[#parts + 1] = "已暂停" -- 5641
		end -- 5641
		return table.concat(parts, " · ") -- 5643
	end -- 5643
	if self.room.key == "village" then -- 5643
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5646
		if self.hasBottle then -- 5646
			parts[#parts + 1] = "有瓶" -- 5648
		elseif self.bottleFly ~= nil then -- 5648
			parts[#parts + 1] = "瓶在飞" -- 5650
		else -- 5650
			parts[#parts + 1] = "空手" -- 5652
		end -- 5652
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5654
		if self.scavChase then -- 5654
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5656
		end -- 5656
		if self.passed then -- 5656
			parts[#parts + 1] = "已过通行线" -- 5659
		end -- 5659
		if self.paused then -- 5659
			parts[#parts + 1] = "已暂停" -- 5662
		end -- 5662
		return table.concat(parts, " · ") -- 5664
	end -- 5664
	local isChild = self.childMode -- 5667
	if isChild then -- 5667
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5669
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5670
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5671
	else -- 5671
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5673
		if p.rollT > 0 then -- 5673
			parts[#parts + 1] = "翻滚中" -- 5675
		end -- 5675
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5677
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5678
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5679
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5680
	end -- 5680
	if self.checkpoint >= 0 then -- 5680
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5683
	end -- 5683
	if self.paused then -- 5683
		parts[#parts + 1] = "已暂停" -- 5686
	end -- 5686
	return table.concat(parts, " · ") -- 5688
end -- 5556
function Play.prototype.aliveEnemies(self) -- 5692
	local n = 0 -- 5693
	local i = 0 -- 5694
	do -- 5694
		i = 0 -- 5695
		while i < #self.enemies do -- 5695
			if self.enemies[i + 1].alive then -- 5695
				n = n + 1 -- 5697
			end -- 5697
			i = i + 1 -- 5695
		end -- 5695
	end -- 5695
	return n -- 5700
end -- 5692
function Play.prototype.threatened(self) -- 5705
	do -- 5705
		local i = 0 -- 5706
		while i < #self.enemies do -- 5706
			local e = self.enemies[i + 1] -- 5707
			if e.alive and e.warnT > 0 then -- 5707
				return true -- 5709
			end -- 5709
			i = i + 1 -- 5706
		end -- 5706
	end -- 5706
	return false -- 5712
end -- 5705
function Play.prototype.gateSecondsLeft(self) -- 5715
	local ____temp_144 -- 5716
	if self.room.story == nil then -- 5716
		____temp_144 = nil -- 5716
	else -- 5716
		____temp_144 = self.room.story.gate -- 5716
	end -- 5716
	local g = ____temp_144 -- 5716
	if g == nil then -- 5716
		return 0 -- 5718
	end -- 5718
	return math.max( -- 5720
		0, -- 5720
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5720
	) -- 5720
end -- 5715
function Play.prototype.gateLabel(self) -- 5723
	if self.phase == "gate-idle" then -- 5723
		return "待就位" -- 5725
	end -- 5725
	if self.phase == "gate-hold" then -- 5725
		return "守点中" -- 5728
	end -- 5728
	if self.phase == "gate-send" then -- 5728
		return "送别" -- 5731
	end -- 5731
	if self.phase == "gate-farewell" then -- 5731
		return "嘱咐 " .. tostring(self.phaseTick) -- 5734
	end -- 5734
	if self.phase == "gate-count" then -- 5734
		return "数数 " .. tostring(self.countTick) -- 5737
	end -- 5737
	return "她走" -- 5739
end -- 5723
function Play.prototype.dogLabel(self) -- 5743
	if self.dogState == "ear" then -- 5743
		return "转耳" -- 5745
	end -- 5745
	if self.dogState == "chase" then -- 5745
		return "追" -- 5748
	end -- 5748
	if self.dogState == "sniff" then -- 5748
		return "停" -- 5751
	end -- 5751
	if self.dogState == "back" then -- 5751
		return "回线" -- 5754
	end -- 5754
	return "巡逻" -- 5756
end -- 5743
function Play.prototype.doorXOf(self) -- 5759
	local ____temp_145 -- 5760
	if self.room.story == nil then -- 5760
		____temp_145 = nil -- 5760
	else -- 5760
		____temp_145 = self.room.story.tower -- 5760
	end -- 5760
	local t = ____temp_145 -- 5760
	return t == nil and 0 or t.doorX -- 5761
end -- 5759
function Play.prototype.scavLabel(self) -- 5765
	if self.scavState == "chase" then -- 5765
		return "追" -- 5767
	end -- 5767
	if self.scavState == "turn" then -- 5767
		return "转头" -- 5770
	end -- 5770
	if self.scavState == "walk" then -- 5770
		return "赶来" -- 5773
	end -- 5773
	if self.scavState == "stall" then -- 5773
		return "停住" -- 5776
	end -- 5776
	if self.scavState == "back" then -- 5776
		return "回位" -- 5779
	end -- 5779
	return "巡逻" -- 5781
end -- 5765
function Play.prototype.hintText(self) -- 5785
	if self.paused then -- 5785
		return "Esc 继续 · R 重置" -- 5787
	end -- 5787
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5787
		if self:threatened() then -- 5787
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5793
		end -- 5793
		if self.coverHug then -- 5793
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5796
		end -- 5796
		if self.coverNear then -- 5796
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5799
		end -- 5799
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5801
	end -- 5801
	if self.flash ~= "" then -- 5801
		return self.flash -- 5804
	end -- 5804
	if self.room.key == "prologue" then -- 5804
		if self.phase == "prologue-wake" then -- 5804
			return "父亲在门外唤 · 小满睁眼" -- 5808
		end -- 5808
		if self.phase == "prologue-shadow" then -- 5808
			return "墙上两道人影 · 碗滚到脚边" -- 5811
		end -- 5811
		if self.phase == "prologue-escape" then -- 5811
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5814
		end -- 5814
		if self.phase == "prologue-hide" then -- 5814
			return "柜门合上 · 屏住呼吸" -- 5817
		end -- 5817
		if self.phase == "prologue-wait" then -- 5817
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5820
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5821
		end -- 5821
		if self.phase == "prologue-give" then -- 5821
			return ((("递物 " .. tostring(self.phaseTick)) .. " / ") .. tostring(____exports.PROLOGUE_GIVE_TICKS)) .. " 拍 · 站着别动" -- 5824
		end -- 5824
		return "她跟着你了 · 两人一起走到门口 680" -- 5826
	end -- 5826
	if self.room.key == "street" then -- 5826
		if self:aliveEnemies() > 0 then -- 5826
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5830
		end -- 5830
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5832
	end -- 5832
	if self.room.key == "gate" then -- 5832
		local ____temp_146 -- 5835
		if self.room.story == nil then -- 5835
			____temp_146 = nil -- 5835
		else -- 5835
			____temp_146 = self.room.story.gate -- 5835
		end -- 5835
		local g = ____temp_146 -- 5835
		if g ~= nil then -- 5835
			if self.phase == "gate-idle" then -- 5835
				if self.gateNeedConfirm then -- 5835
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5839
				end -- 5839
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5841
			end -- 5841
			if self.phase == "gate-hold" then -- 5841
				if self.coveredFlash > 0 then -- 5841
					return "掩体挡下了这一枪 · 别露头" -- 5845
				end -- 5845
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5847
			end -- 5847
			if self.phase == "gate-send" then -- 5847
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5850
			end -- 5850
			if self.phase == "gate-farewell" then -- 5850
				return "城门送别 · 嘱咐她慢慢数到二十" -- 5853
			end -- 5853
			if self.phase == "gate-count" then -- 5853
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5853
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5857
				end -- 5857
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5859
			end -- 5859
			return "她自己走 · 跟着出城门 1120" -- 5861
		end -- 5861
	end -- 5861
	if self.room.key == "forest" then -- 5861
		if self.dogState == "chase" then -- 5861
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5866
		end -- 5866
		if self.dogState == "ear" then -- 5866
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5869
		end -- 5869
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5871
	end -- 5871
	if self.room.key == "tower" then -- 5871
		if self.phase == "tower-wait" then -- 5871
			return "走到门前 445 点一次 E 敲两下" -- 5875
		end -- 5875
		if self.phase == "tower-knock" then -- 5875
			return "敲两下 · 等门开" -- 5878
		end -- 5878
		if self.phase == "tower-given" then -- 5878
			return "递交针套和纸条 · 看登记簿最后一行" -- 5881
		end -- 5881
		return "片尾 · 点 E 再玩一次，回到序章" -- 5883
	end -- 5883
	if self.room.key == "village" then -- 5883
		if self.bottleFly ~= nil then -- 5883
			return "等瓶子落地 · 触地才发声" -- 5887
		end -- 5887
		if self.hasBottle then -- 5887
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5890
		end -- 5890
		if self.passed then -- 5890
			return "已过第一院 · R 重置可再来一遍" -- 5893
		end -- 5893
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5895
	end -- 5895
	if self.room.key == "outside" then -- 5895
		if self.focusCart then -- 5895
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5899
		end -- 5899
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5901
	end -- 5901
	if self.escort.state == "frozen" then -- 5901
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5901
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5905
		end -- 5905
		return "小满吓住了 · 走过去，靠近再点 E" -- 5907
	end -- 5907
	if self.escort.state == "calming" then -- 5907
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5910
	end -- 5910
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5912
end -- 5785
return ____exports -- 5785