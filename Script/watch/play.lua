-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local makeActor, rayInterval, hitBox, CHILD_W, CHILD_H, SOLDIER_W, SOLDIER_H -- 1
local ____Dora = require("Dora") -- 12
local Rect = ____Dora.Rect -- 12
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
local LANE_DEPTH = ____depth.LANE_DEPTH -- 24
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
function makeActor(room, index) -- 5925
	local sp = room.spawns -- 5926
	if index < 0 or index >= #sp then -- 5926
		return { -- 5928
			x = 0, -- 5928
			y = 0, -- 5928
			depth = 0, -- 5928
			depthSpeed = 0, -- 5928
			vx = 0, -- 5928
			vy = 0, -- 5928
			w = CHILD_W, -- 5928
			h = CHILD_H, -- 5928
			onGround = true, -- 5928
			facing = 1, -- 5928
			crouch = false, -- 5928
			rollT = 0, -- 5928
			covered = false, -- 5928
			alive = false -- 5928
		} -- 5928
	end -- 5928
	local s = sp[index + 1] -- 5930
	local child = s.h < SOLDIER_H -- 5931
	local ground = room.depth -- 5932
	local depth = ground == nil and 0 or math.max( -- 5933
		ground.min, -- 5933
		math.min(ground.max, s.depth or 0) -- 5933
	) -- 5933
	return { -- 5934
		x = s.x, -- 5935
		y = s.y, -- 5935
		depth = depth, -- 5935
		depthSpeed = 0, -- 5935
		vx = 0, -- 5935
		vy = 0, -- 5935
		w = child and CHILD_W or SOLDIER_W, -- 5936
		h = child and CHILD_H or SOLDIER_H, -- 5937
		onGround = true, -- 5938
		facing = 1, -- 5938
		crouch = false, -- 5938
		rollT = 0, -- 5938
		covered = false, -- 5938
		alive = true -- 5938
	} -- 5938
end -- 5938
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5943
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5944
end -- 5943
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5951
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5952
end -- 5951
function rayInterval(origin, direction, min, max) -- 5959
	if direction == 0 then -- 5959
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5961
	end -- 5961
	local a = (min - origin) / direction -- 5963
	local b = (max - origin) / direction -- 5964
	return { -- 5965
		min = math.min(a, b), -- 5965
		max = math.max(a, b) -- 5965
	} -- 5965
end -- 5965
function hitBox(ray, box) -- 5969
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5970
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5971
	local enter = math.max(0, x.min, y.min) -- 5972
	local leave = math.min(99999, x.max, y.max) -- 5973
	if box.depth ~= nil then -- 5973
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5975
		enter = math.max(enter, depth.min) -- 5976
		leave = math.min(leave, depth.max) -- 5977
	end -- 5977
	return leave >= enter and enter or -1 -- 5979
end -- 5979
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
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 286
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 287
	if zoom < 1 then -- 287
		zoom = 1 -- 289
	end -- 289
	return { -- 291
		zoom = zoom, -- 292
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 293
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 294
	} -- 294
end -- 286
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 317
	if key == "prologue" then -- 317
		return "prologue-wait" -- 321
	end -- 321
	if key == "street" then -- 321
		return "street-run" -- 324
	end -- 324
	if key == "gate" then -- 324
		return "gate-idle" -- 327
	end -- 327
	if key == "gatepath" then -- 327
		return "gatepath-start" -- 330
	end -- 330
	if key == "forest" then -- 330
		return "forest-run" -- 333
	end -- 333
	if key == "tower" then -- 333
		return "tower-wait" -- 336
	end -- 336
	if key == "museum" then -- 336
		return "museum-cabinet" -- 339
	end -- 339
	return "run" -- 341
end -- 317
____exports.Play = __TS__Class() -- 344
local Play = ____exports.Play -- 344
Play.name = "Play" -- 344
function Play.prototype.____constructor(self, room, resume, run) -- 654
	self.enemies = {} -- 349
	self.boxes = {} -- 350
	self.floors = {} -- 351
	self.checkpoint = -1 -- 353
	self.flash = "" -- 355
	self.flashT = 0 -- 356
	self.traceT = 0 -- 359
	self.focusCart = false -- 361
	self.knocks = 0 -- 363
	self.knockT = 0 -- 364
	self.cartAxle = 0 -- 368
	self.cartDocked = false -- 370
	self.gripping = false -- 372
	self.gateOpen = false -- 374
	self.calmConsumed = false -- 376
	self.craftT = 0 -- 378
	self.nextDangerId = 1 -- 380
	self.wantRoom = "" -- 382
	self.carryCartAxle = -1 -- 384
	self.carryCartDocked = false -- 385
	self.checkpointCartAxle = -1 -- 387
	self.hasBottle = false -- 391
	self.bottleLandX = -1 -- 395
	self.bottleTargetX = -1 -- 396
	self.bottleTargetY = 0 -- 397
	self.bottleLandT = 0 -- 398
	self.aimHold = 0 -- 400
	self.bottleAimCancelLatch = false -- 402
	self.redCartMemoryT = 0 -- 404
	self.footHintT = 0 -- 406
	self.ditchHinted = false -- 408
	self.forestPath = "" -- 410
	self.waterSeen = false -- 412
	self.scavStallBonus = 0 -- 414
	self.intentGateReunionHold = false -- 416
	self.pendingMuseumIntentTarget = "" -- 418
	self.scavX = 0 -- 420
	self.scavDir = 1 -- 421
	self.scavState = "patrol" -- 422
	self.scavT = 0 -- 423
	self.scavTargetX = 0 -- 424
	self.passed = false -- 426
	self.childMode = false -- 430
	self.phase = "" -- 432
	self.phaseTick = 0 -- 434
	self.gateTick = 0 -- 436
	self.countTick = 0 -- 438
	self.countArmed = false -- 440
	self.countPrevMove = 0 -- 442
	self.caughtT = 0 -- 444
	self.hp = 3 -- 446
	self.maxHp = 3 -- 447
	self.invulnT = 0 -- 453
	self.partnerStuck = 0 -- 455
	self.partnerLaneIdx = 0 -- 457
	self.partnerLaneHold = 0 -- 458
	self.coveredFlash = 0 -- 460
	self.coverHug = false -- 462
	self.coverNear = false -- 464
	self.coverEntity = "" -- 466
	self.coverBlocking = false -- 468
	self.gateNeedConfirm = false -- 470
	self.gateRestartArmed = true -- 472
	self.bottleAimX = -1 -- 474
	self.bottleAimY = 0 -- 475
	self.bottleSurfaceY = -1 -- 477
	self.bottleLandY = 0 -- 479
	self.events = {} -- 481
	self.eventSeq = 0 -- 483
	self.dogX = 0 -- 485
	self.dogDir = 1 -- 486
	self.dogState = "patrol" -- 487
	self.dogT = 0 -- 488
	self.dogTargetX = 0 -- 489
	self.scavSee = 0 -- 491
	self.scavChase = false -- 492
	self.gateSpawned = 0 -- 494
	self.gateFailCount = 0 -- 496
	self.isCampaign = false -- 500
	self.archiveDirty = false -- 508
	self.sessionDirty = false -- 510
	self.restartStory = false -- 512
	self.wellOpen = false -- 514
	self.wellX = 430 -- 516
	self.wellTaken = false -- 518
	self.museumReturn = false -- 520
	self.endingLines = {"", ""} -- 522
	self.towerDoorOpen = false -- 524
	self.towerHanded = false -- 525
	self.deskHold = 0 -- 526
	self.towerEndMustRelease = false -- 528
	self.equippedWeapon = "standard_gun" -- 541
	self.craftBench = { -- 543
		active = false, -- 544
		firstCraftDone = false, -- 545
		justCraftedTimer = 0, -- 546
		inventory = {}, -- 547
		recipes = {}, -- 548
		equippedWeapon = "standard_gun" -- 549
	} -- 549
	self.handledCraftRequests = {} -- 552
	self.benchReach = 48 -- 554
	self.pickups = {} -- 558
	self.reloadT = 0 -- 560
	self.objectiveDone = false -- 564
	self.hint = "" -- 566
	self.roomStartTick = 0 -- 568
	self.cartHitT = 0 -- 570
	self.cartExposed = false -- 571
	self.storyRoute = "" -- 575
	self.storySettled = false -- 577
	self.hpAtGate = -1 -- 579
	self.maxHpAtGate = -1 -- 580
	self.handTicks = 0 -- 582
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 584
	self.handArmed = false -- 586
	self.handDone = false -- 588
	self.lineSaid = false -- 589
	self.tied = false -- 591
	self.pathDone = false -- 593
	self.carryOn = false -- 595
	self.escortDone = false -- 597
	self.escapeDuration = ____exports.PROLOGUE_ESCAPE_TICKS / 60 -- 601
	self.escapeRemaining = 0 -- 603
	self.escapeRetryCount = 0 -- 605
	self.introTick = 0 -- 607
	self.reloadOpen = false -- 611
	self.reloadAnswerTicks = 0 -- 613
	self.reloadWorldTicks = 0 -- 615
	self.reloadPath = {RELOAD_START} -- 617
	self.reloadPendingEffect = "" -- 619
	self.reloadTryCount = 0 -- 621
	self.talentModalActive = false -- 624
	self.useEscortDeathSummary = false -- 625
	self.escortFailed = false -- 626
	self.escortFailedTicks = 0 -- 627
	self.escortSummary = nil -- 628
	self.fieldWedgeSeq = 0 -- 636
	self.paused = false -- 638
	self.ticks = 0 -- 640
	self.view = {zoom = 1, ox = 0, oy = 0} -- 642
	self.ox = 0 -- 644
	self.aimX = 0 -- 646
	self.aimY = 0 -- 647
	self.viewW = 0 -- 649
	self.viewH = 0 -- 650
	self.ox = room.originX -- 656
	self.room = withOrigin(room) -- 657
	local wr = self.room -- 658
	self.run = run or createRun() -- 659
	self.inventory = self.run.inventory -- 660
	self.archive = self.run.archive -- 661
	local story = self.run.story -- 662
	local savedEq = story.equippedWeapon -- 663
	if savedEq == ARTIFACT_WEAPON_ID and self.archive.artifactOwned then -- 663
		self.equippedWeapon = ARTIFACT_WEAPON_ID -- 665
	elseif savedEq == "standard_gun" or savedEq ~= "" and savedEq == story.craftedWeapon then -- 665
		self.equippedWeapon = savedEq -- 667
	else -- 667
		self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 669
	end -- 669
	self.isCampaign = wr.campaign ~= nil -- 671
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 672
	self:buildWorld() -- 673
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 676
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 678
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 679
	local soloRoom = wr.key == "museum" -- 681
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 682
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 683
	self.player = makeActor(wr, playerIdx) -- 684
	self.partner = makeActor(wr, partnerIdx) -- 685
	self.phase = phaseOf(wr.key) -- 686
	if soloRoom then -- 686
		local mp = self.archive.museumPhase -- 689
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 690
	end -- 690
	if wr.story ~= nil then -- 690
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 696
	end -- 696
	self.cam.x = self.player.x -- 698
	self.cam.y = self.player.y + CAM_LOOK_UP -- 699
	self.cartAxle = wr.cart.startX -- 700
	self.escort = __TS__New( -- 701
		Escort, -- 701
		safeAnchorX(wr.marks) -- 701
	) -- 701
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 702
	if self.isCampaign then -- 702
		self:setupCampaign() -- 704
	else -- 704
		self:buildEnemies() -- 706
	end -- 706
	if resume ~= nil and resume.checkpoint > 0 then -- 706
		self.checkpoint = resume.checkpoint -- 710
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 710
			self.cartAxle = self.room.cart.endX -- 712
			self.cartDocked = true -- 713
			self.player.x = self.ox + 380 -- 716
			self.player.y = 0 -- 717
			self.player.vy = 0 -- 718
			self.player.onGround = true -- 719
			self.cam.x = self.player.x -- 720
			self.cam.y = self.player.y + CAM_LOOK_UP -- 721
		end -- 721
	end -- 721
	self:restoreStory() -- 724
end -- 654
function Play.prototype.towerEndReady(self) -- 531
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 532
	return self.room.key == "tower" and self.phase == "tower-end" and self.phaseTick >= waitTicks and not self.towerEndMustRelease -- 533
end -- 531
function Play.prototype.recipeViews(self) -- 737
	local out = {} -- 738
	local i = 0 -- 739
	do -- 739
		i = 0 -- 740
		while i < #CRAFT_RECIPES do -- 740
			local r = CRAFT_RECIPES[i + 1] -- 741
			local cost = {} -- 742
			if r.cost.wood ~= nil then -- 742
				cost.wood = r.cost.wood -- 744
			end -- 744
			if r.cost.bell ~= nil then -- 744
				cost.bell = r.cost.bell -- 747
			end -- 747
			out[#out + 1] = { -- 749
				id = r.id, -- 750
				name = r.name, -- 751
				desc = r.desc, -- 752
				enhancedEffect = r.enhancedEffect, -- 753
				cost = cost, -- 754
				crafted = self.run.story.craftedWeapon == r.id -- 755
			} -- 755
			i = i + 1 -- 740
		end -- 740
	end -- 740
	if self.archive.artifactOwned then -- 740
		out[#out + 1] = { -- 760
			id = ARTIFACT_WEAPON_ID, -- 761
			name = weaponNameOf(ARTIFACT_WEAPON_ID), -- 762
			desc = "井底拾取彩蛋 · 男主线移动留下冷白微金轨迹残影", -- 763
			enhancedEffect = "light", -- 764
			cost = {}, -- 765
			crafted = true -- 766
		} -- 766
	end -- 766
	return out -- 769
end -- 737
function Play.prototype.syncCraftBench(self) -- 773
	local view = self.craftBench -- 774
	local inv = self.run.inventory -- 775
	view.inventory = { -- 776
		wood = inv.wood, -- 776
		bell = inv.bell, -- 776
		scrap = inv.scrap, -- 776
		wedge = inv.wedge, -- 776
		ammo = inv.ammo -- 776
	} -- 776
	view.recipes = self:recipeViews() -- 777
	view.equippedWeapon = self.equippedWeapon -- 778
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 779
	if view.justCraftedTimer > 0 then -- 779
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 781
	end -- 781
end -- 773
function Play.prototype.openCraftBench(self) -- 786
	if self.room.key ~= "escort3" or self.craftBench.active then -- 786
		return -- 788
	end -- 788
	self.craftBench.active = true -- 790
	self.carryOn = false -- 791
	self.run.story.carry = false -- 792
	self.player.vx = 0 -- 793
	self.player.vy = 0 -- 794
	self.craftBench.justCraftedTimer = 0 -- 795
	self:syncCraftBench() -- 796
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 797
	self:log("开工台") -- 798
	self:emit( -- 799
		"benchOpen", -- 799
		{ -- 799
			recipes = __TS__ArrayMap( -- 800
				self.craftBench.recipes, -- 800
				function(____, r) return r.id end -- 800
			), -- 800
			inventory = self.craftBench.inventory, -- 801
			carry = self.carryOn -- 802
		} -- 802
	) -- 802
end -- 786
function Play.prototype.closeCraftBench(self) -- 807
	if not self.craftBench.active then -- 807
		return -- 809
	end -- 809
	self.craftBench.active = false -- 811
	self.craftBench.justCraftedTimer = 0 -- 812
	self.carryOn = true -- 813
	self.run.story.carry = true -- 814
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 815
	self:log("离站背起") -- 816
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 817
	if self.room.key == "escort3" and self.storyRoute == "soldier" then -- 817
		self:triggerDeferredEscort3Draft() -- 819
	end -- 819
end -- 807
function Play.prototype.triggerDeferredEscort3Draft(self) -- 824
	if self.room.key ~= "escort3" or self.storyRoute ~= "soldier" or self.run.finished then -- 824
		return false -- 826
	end -- 826
	if self.run.story.talents == nil then -- 826
		self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 829
	end -- 829
	local st = self.run.story.talents -- 831
	if not st.deferred and st.room == "escort3" then -- 831
		return false -- 833
	end -- 833
	draftTalentOffers(st, "escort3", self.equippedWeapon) -- 835
	if self.useEscortDeathSummary and #st.offers > 0 then -- 835
		self.talentModalActive = true -- 837
	end -- 837
	self.sessionDirty = true -- 839
	return #st.offers > 0 -- 840
end -- 824
function Play.prototype.openTalentDraft(self) -- 844
	if #self:getStoryTalentOffers() > 0 and not self.craftBench.active and not self.escortFailed then -- 844
		self.talentModalActive = true -- 846
	end -- 846
end -- 844
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 854
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 854
		return false -- 856
	end -- 856
	local recipe = findRecipe(recipeId) -- 858
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 858
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 860
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 861
		return false -- 862
	end -- 862
	local missing = missingMaterials(self.run.inventory, recipe) -- 864
	if #missing > 0 then -- 864
		self:flashSet( -- 866
			"缺料 · " .. table.concat(missing, " / "), -- 866
			1.6 -- 866
		) -- 866
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 867
		return false -- 868
	end -- 868
	payMaterials(self.run.inventory, recipe) -- 870
	self.handledCraftRequests[requestId] = true -- 871
	self.run.story.craftedWeapon = recipe.id -- 872
	self.run.story.equippedWeapon = recipe.id -- 873
	self.equippedWeapon = recipe.id -- 874
	self.sessionDirty = true -- 875
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 876
	self.craftBench.firstCraftDone = true -- 877
	self:syncCraftBench() -- 878
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 879
	self:log("改制 " .. recipe.id) -- 880
	self:emit("benchCraft", { -- 881
		recipeId = recipe.id, -- 882
		weapon = recipe.id, -- 883
		effect = recipe.enhancedEffect, -- 884
		wood = self.run.inventory.wood, -- 885
		bell = self.run.inventory.bell -- 886
	}) -- 886
	return true -- 888
end -- 854
function Play.prototype.equipWeapon(self, weaponId) -- 892
	local artifactOk = weaponId == ARTIFACT_WEAPON_ID and self.archive.artifactOwned -- 893
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId and not artifactOk then -- 893
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 895
		return false -- 896
	end -- 896
	self.equippedWeapon = weaponId -- 898
	self.run.story.equippedWeapon = weaponId -- 899
	self.sessionDirty = true -- 900
	self:syncCraftBench() -- 901
	self:flashSet( -- 902
		"已装备 " .. weaponNameOf(weaponId), -- 902
		1 -- 902
	) -- 902
	self:emit("benchEquip", {weapon = weaponId}) -- 903
	return true -- 904
end -- 892
function Play.prototype.toggleArtifactWeapon(self) -- 908
	if not self.archive.artifactOwned or self.childMode then -- 908
		return false -- 910
	end -- 910
	if self.equippedWeapon == ARTIFACT_WEAPON_ID then -- 910
		local fallback = self.run.story.craftedWeapon ~= "" and self.run.story.craftedWeapon or "standard_gun" -- 913
		return self:equipWeapon(fallback) -- 914
	end -- 914
	return self:equipWeapon(ARTIFACT_WEAPON_ID) -- 916
end -- 908
function Play.prototype.exportSession(self) -- 920
	self:syncStory() -- 921
	local story = self.run.story -- 922
	local inv = self.run.inventory -- 923
	local taken = {} -- 924
	for k in pairs(self.run.taken) do -- 925
		if self.run.taken[k] == true then -- 925
			taken[#taken + 1] = k -- 927
		end -- 927
	end -- 927
	local segments = {} -- 930
	for k in pairs(story.segments) do -- 931
		if story.segments[k] == true then -- 931
			segments[#segments + 1] = k -- 933
		end -- 933
	end -- 933
	local props = {} -- 936
	for k in pairs(self.run.props) do -- 937
		local st = self.run.props[k] -- 938
		if st ~= nil then -- 938
			props[#props + 1] = (((((((k .. ":") .. (st.broken and "1" or "0")) .. ":") .. tostring(math.floor(st.hp + 0.5))) .. ":") .. (st.wedge and "1" or "0")) .. ":") .. (st.revealed == true and "1" or "0") -- 940
		end -- 940
	end -- 940
	local talentRanks = {} -- 949
	if story.talents ~= nil then -- 949
		local ti = 0 -- 951
		do -- 951
			ti = 0 -- 952
			while ti < #ALL_TALENTS do -- 952
				local tid = ALL_TALENTS[ti + 1] -- 953
				local rk = story.talents.ranks[tid] or 0 -- 954
				if rk > 0 then -- 954
					talentRanks[#talentRanks + 1] = (tid .. ":") .. tostring(rk) -- 956
				end -- 956
				ti = ti + 1 -- 952
			end -- 952
		end -- 952
	end -- 952
	local ____temp_4 = self.escortFailed and "escort1" or self.room.key -- 962
	local ____temp_5 = self.escortFailed and 0 or self.checkpoint -- 963
	local ____self_run_seed_6 = self.run.seed -- 964
	local ____story_route_7 = story.route -- 965
	local ____story_hp_8 = story.hp -- 966
	local ____story_maxHp_9 = story.maxHp -- 967
	local ____story_hpAtGate_10 = story.hpAtGate -- 968
	local ____story_maxHpAtGate_11 = story.maxHpAtGate -- 969
	local ____story_settled_12 = story.settled -- 970
	local ____self_phase_13 = self.phase -- 971
	local ____story_countTick_14 = story.countTick -- 972
	local ____story_phaseTick_15 = story.phaseTick -- 973
	local ____story_handTicks_16 = story.handTicks -- 974
	local ____story_handDone_17 = story.handDone -- 975
	local ____story_lineSaid_18 = story.lineSaid -- 976
	local ____story_tied_19 = story.tied -- 977
	local ____story_carry_20 = story.carry -- 978
	local ____story_escortDone_21 = story.escortDone -- 979
	local ____story_craftedWeapon_22 = story.craftedWeapon -- 980
	local ____self_equippedWeapon_23 = self.equippedWeapon -- 981
	local ____inv_wood_24 = inv.wood -- 982
	local ____inv_bell_25 = inv.bell -- 983
	local ____inv_scrap_26 = inv.scrap -- 984
	local ____inv_wedge_27 = inv.wedge -- 985
	local ____inv_ammo_28 = inv.ammo -- 986
	local ____inv_shield_29 = inv.shield -- 987
	local ____inv_pass_30 = inv.pass -- 988
	local ____inv_quickbelt_31 = inv.quickbelt -- 989
	local ____taken_32 = taken -- 990
	local ____segments_33 = segments -- 991
	local ____self_cartAxle_34 = self.cartAxle -- 992
	local ____self_cartDocked_35 = self.cartDocked -- 993
	local ____self_run_route_36 = self.run.route -- 994
	local ____self_run_joined_37 = self.run.joined -- 995
	local ____self_run_c1Latch_38 = self.run.c1Latch -- 996
	local ____self_run_c2Latch_39 = self.run.c2Latch -- 997
	local ____temp_40 = story.talents ~= nil and story.talents.randomState or 0 -- 998
	local ____temp_41 = story.talents ~= nil and story.talents.room or "" -- 999
	local ____temp_42 = story.talents ~= nil and __TS__ArraySlice(story.talents.offers) or ({}) -- 1000
	local ____talentRanks_43 = talentRanks -- 1001
	local ____temp_44 = story.talents ~= nil and story.talents.attempt or 1 -- 1002
	local ____temp_45 = story.talents ~= nil and story.talents.variant or 0 -- 1003
	local ____temp_0 -- 1004
	if story.talents ~= nil then -- 1004
		____temp_0 = story.talents.deferred -- 1004
	else -- 1004
		____temp_0 = false -- 1004
	end -- 1004
	local ____temp_46 = story.talents ~= nil and story.talents.ranks.vitality or 0 -- 1005
	local ____temp_47 = story.talents ~= nil and story.talents.ranks.focus or 0 -- 1006
	local ____temp_48 = story.talents ~= nil and story.talents.ranks.guard or 0 -- 1007
	local ____temp_49 = story.talents ~= nil and story.talents.ranks.salvage or 0 -- 1008
	local ____props_50 = props -- 1009
	local ____table_escortFailed_1 -- 1010
	if self.escortFailed then -- 1010
		____table_escortFailed_1 = nil -- 1010
	else -- 1010
		____table_escortFailed_1 = self.player.x -- 1010
	end -- 1010
	local ____table_escortFailed_2 -- 1011
	if self.escortFailed then -- 1011
		____table_escortFailed_2 = nil -- 1011
	else -- 1011
		____table_escortFailed_2 = self.player.y -- 1011
	end -- 1011
	local ____table_escortFailed_3 -- 1012
	if self.escortFailed then -- 1012
		____table_escortFailed_3 = nil -- 1012
	else -- 1012
		____table_escortFailed_3 = self.player.depth -- 1012
	end -- 1012
	return { -- 960
		roomKey = ____temp_4, -- 962
		checkpoint = ____temp_5, -- 963
		seed = ____self_run_seed_6, -- 964
		route = ____story_route_7, -- 965
		hp = ____story_hp_8, -- 966
		maxHp = ____story_maxHp_9, -- 967
		hpAtGate = ____story_hpAtGate_10, -- 968
		maxHpAtGate = ____story_maxHpAtGate_11, -- 969
		settled = ____story_settled_12, -- 970
		phase = ____self_phase_13, -- 971
		countTick = ____story_countTick_14, -- 972
		phaseTick = ____story_phaseTick_15, -- 973
		handTicks = ____story_handTicks_16, -- 974
		handDone = ____story_handDone_17, -- 975
		lineSaid = ____story_lineSaid_18, -- 976
		tied = ____story_tied_19, -- 977
		carry = ____story_carry_20, -- 978
		escortDone = ____story_escortDone_21, -- 979
		craftedWeapon = ____story_craftedWeapon_22, -- 980
		equippedWeapon = ____self_equippedWeapon_23, -- 981
		wood = ____inv_wood_24, -- 982
		bell = ____inv_bell_25, -- 983
		scrap = ____inv_scrap_26, -- 984
		wedge = ____inv_wedge_27, -- 985
		ammo = ____inv_ammo_28, -- 986
		shield = ____inv_shield_29, -- 987
		pass = ____inv_pass_30, -- 988
		quickbelt = ____inv_quickbelt_31, -- 989
		taken = ____taken_32, -- 990
		segments = ____segments_33, -- 991
		cartAxle = ____self_cartAxle_34, -- 992
		cartDocked = ____self_cartDocked_35, -- 993
		campaignRoute = ____self_run_route_36, -- 994
		joined = ____self_run_joined_37, -- 995
		c1Latch = ____self_run_c1Latch_38, -- 996
		c2Latch = ____self_run_c2Latch_39, -- 997
		talentSeed = ____temp_40, -- 998
		talentRoom = ____temp_41, -- 999
		talentOffers = ____temp_42, -- 1000
		talentRanks = ____talentRanks_43, -- 1001
		escortAttempt = ____temp_44, -- 1002
		escortVariant = ____temp_45, -- 1003
		talentDeferred = ____temp_0, -- 1004
		talentVitality = ____temp_46, -- 1005
		talentReload = ____temp_47, -- 1006
		talentGuard = ____temp_48, -- 1007
		talentCraft = ____temp_49, -- 1008
		props = ____props_50, -- 1009
		playerX = ____table_escortFailed_1, -- 1010
		playerY = ____table_escortFailed_2, -- 1011
		playerDepth = ____table_escortFailed_3, -- 1012
		gateTick = self.gateTick, -- 1013
		hasBottle = self.hasBottle, -- 1014
		villagePassed = self.passed -- 1015
	} -- 1015
end -- 920
function Play.prototype.submitFeIntent(self, intent) -- 1023
	local kind = intent == nil and "" or intent.kind -- 1024
	if kind == "gateReunionHold" then -- 1024
		if self.room.key ~= "gate" or self.phase ~= "gate-wait" and self.phase ~= "gate-count" then -- 1024
			return false -- 1027
		end -- 1027
		local holding = intent.holding == true -- 1029
		self.intentGateReunionHold = holding -- 1030
		if not holding and self.phase == "gate-wait" then -- 1030
			if self.handTicks > 0 then -- 1030
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1033
			end -- 1033
			self.handTicks = 0 -- 1035
			self.handArmed = true -- 1036
		end -- 1036
		return true -- 1038
	end -- 1038
	if kind == "reloadOpen" then -- 1038
		local camp = self.room.campaign -- 1041
		if camp == nil or camp.reloadPuzzle ~= true or self.reloadOpen then -- 1041
			return false -- 1043
		end -- 1043
		self:beginReload() -- 1045
		return self.reloadOpen -- 1046
	end -- 1046
	if kind == "reloadPathPreview" then -- 1046
		local path = intent.path -- 1049
		return type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) -- 1050
	end -- 1050
	if kind == "reloadTapNode" then -- 1050
		local node = intent.node -- 1053
		if type(node) == "number" then -- 1053
			self:reloadTapNode(node) -- 1055
			return true -- 1056
		end -- 1056
		return false -- 1058
	end -- 1058
	if kind == "reloadPathCommit" then -- 1058
		local path = intent.path -- 1061
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 1061
			local list = path -- 1063
			local i = 0 -- 1064
			do -- 1064
				i = 0 -- 1065
				while i < #list do -- 1065
					do -- 1065
						if i == 0 and list[i + 1] == RELOAD_START then -- 1065
							goto __continue85 -- 1067
						end -- 1067
						self:reloadTapNode(list[i + 1]) -- 1069
					end -- 1069
					::__continue85:: -- 1069
					i = i + 1 -- 1065
				end -- 1065
			end -- 1065
			return true -- 1071
		end -- 1071
		return false -- 1073
	end -- 1073
	if kind == "reloadCancel" then -- 1073
		self:closeReloadPuzzle() -- 1076
		return true -- 1077
	end -- 1077
	if kind == "craftSubmit" then -- 1077
		local recipeId = intent.recipeId -- 1080
		local requestId = intent.requestId -- 1081
		if type(recipeId) == "string" and type(requestId) == "string" then -- 1081
			return self:craftAtBench(recipeId, requestId) -- 1083
		end -- 1083
		return false -- 1085
	end -- 1085
	if kind == "craftEquip" then -- 1085
		local weaponId = intent.weaponId -- 1088
		if type(weaponId) == "string" then -- 1088
			return self:equipWeapon(weaponId) -- 1090
		end -- 1090
		return false -- 1092
	end -- 1092
	if kind == "craftClose" then -- 1092
		self:closeCraftBench() -- 1095
		return true -- 1096
	end -- 1096
	if kind == "chooseTalent" then -- 1096
		local slot = intent.slot -- 1099
		if type(slot) == "number" then -- 1099
			return self:chooseTalent(slot) -- 1101
		end -- 1101
		return false -- 1103
	end -- 1103
	if kind == "wellPick" then -- 1103
		return self:pickWell() -- 1106
	end -- 1106
	if kind == "museumInteract" then -- 1106
		local target = type(intent.target) == "string" and intent.target or "" -- 1109
		if target == "well_pickup" or target == "well" then -- 1109
			return self:pickWell() -- 1111
		end -- 1111
		if self.room.key ~= "museum" then -- 1111
			return false -- 1114
		end -- 1114
		return self:triggerMuseumIntent(target) -- 1116
	end -- 1116
	return false -- 1118
end -- 1023
function Play.prototype.triggerMuseumIntent(self, target) -- 1122
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 1123
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 1126
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 1127
	if self.phase == "museum-cabinet" then -- 1127
		if target == "enter_hall" or (target == "" or target == "cabinet" or target == "weapon_case") and atCase then -- 1127
			self.pendingMuseumIntentTarget = "cabinet" -- 1130
			return true -- 1131
		end -- 1131
	end -- 1131
	if self.phase == "museum-hall" then -- 1131
		if (target == "lamp_turn" or target == "lamp" or target == "west_lamp") and nearLamp then -- 1131
			self.pendingMuseumIntentTarget = "lamp_direct" -- 1136
			return true -- 1137
		end -- 1137
		if (target == "" or target == "hall" or target == "corridor") and self.player.x >= self.ox + mu.hallX then -- 1137
			self.pendingMuseumIntentTarget = "hall" -- 1140
			return true -- 1141
		end -- 1141
	end -- 1141
	if self.phase == "museum-lamp" and (target == "" or target == "lamp" or target == "west_lamp" or target == "lamp_turn") and nearLamp then -- 1141
		self.pendingMuseumIntentTarget = "lamp" -- 1147
		return true -- 1148
	end -- 1148
	if self.phase == "museum-return" then -- 1148
		if target == "begin_return_cabinet" or (target == "" or target == "return_cabinet" or target == "cabinet" or target == "return") and atCase then -- 1148
			self.pendingMuseumIntentTarget = "return_cabinet" -- 1153
			return true -- 1154
		end -- 1154
	end -- 1154
	if self.phase == "museum-done" and (target == "" or target == "return_cabinet" or target == "return") then -- 1154
		self.pendingMuseumIntentTarget = "done" -- 1158
		return true -- 1159
	end -- 1159
	return false -- 1161
end -- 1122
function Play.prototype.captureCheckpoint(self, id) -- 1165
	local inv = self.run.inventory -- 1166
	self.checkpointSnap = { -- 1167
		id = id, -- 1168
		wood = inv.wood, -- 1169
		bell = inv.bell, -- 1170
		scrap = inv.scrap, -- 1171
		wedge = inv.wedge, -- 1172
		ammo = inv.ammo, -- 1173
		shield = inv.shield, -- 1174
		pass = inv.pass, -- 1175
		quickbelt = inv.quickbelt, -- 1176
		crafted = self.run.story.craftedWeapon, -- 1177
		equipped = self.equippedWeapon, -- 1178
		carry = self.carryOn -- 1179
	} -- 1179
	self.run.story.cp = self.checkpointSnap -- 1181
end -- 1165
function Play.prototype.applyCheckpointSnap(self, id) -- 1185
	local snap = self.run.story.cp -- 1186
	if snap == nil or snap.id ~= id then -- 1186
		return false -- 1188
	end -- 1188
	self.checkpointSnap = snap -- 1190
	local inv = self.run.inventory -- 1191
	inv.wood = snap.wood -- 1192
	inv.bell = snap.bell -- 1193
	inv.scrap = snap.scrap -- 1194
	inv.wedge = snap.wedge -- 1195
	inv.ammo = snap.ammo -- 1196
	inv.shield = snap.shield -- 1197
	inv.pass = snap.pass -- 1198
	inv.quickbelt = snap.quickbelt -- 1199
	self.run.story.craftedWeapon = snap.crafted -- 1200
	self.equippedWeapon = snap.equipped -- 1201
	self.run.story.equippedWeapon = snap.equipped -- 1202
	self.carryOn = snap.carry -- 1203
	self.run.story.carry = snap.carry -- 1204
	self.craftBench.active = false -- 1205
	self:syncCraftBench() -- 1206
	return true -- 1207
end -- 1185
function Play.prototype.restoreStory(self) -- 1210
	local story = self.run.story -- 1211
	if story == nil then -- 1211
		return -- 1213
	end -- 1213
	if story.maxHp > 0 then -- 1213
		self.maxHp = story.maxHp -- 1216
		self.hp = math.max( -- 1217
			1, -- 1217
			math.min(story.hp, story.maxHp) -- 1217
		) -- 1217
	end -- 1217
	self.storyRoute = story.route -- 1219
	self.storySettled = story.settled -- 1220
	self.hpAtGate = story.hpAtGate -- 1221
	self.maxHpAtGate = story.maxHpAtGate -- 1222
	self.handDone = story.handDone -- 1223
	self.lineSaid = story.lineSaid -- 1224
	self.tied = story.handDone -- 1225
	self.carryOn = story.carry or story.route == "soldier" and (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 1226
	self.museumReturn = story.museumReturn -- 1227
	story.museumReturn = false -- 1228
	self.escortDone = story.escortDone -- 1229
	self:syncCraftBench() -- 1230
	if self.room.key == "outside" and story.segments.outside_cart == true then -- 1230
		self.cartAxle = self.room.cart.endX -- 1232
		self.cartDocked = true -- 1233
	end -- 1233
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 1235
	self.waterSeen = story.segments.water_lantern == true -- 1237
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 1237
		self:applyCheckpointSnap(self.checkpoint) -- 1240
	end -- 1240
	if self.room.key == "tower" and story.route == "soldier" then -- 1240
		self.carryOn = false -- 1244
		self.run.story.carry = false -- 1245
		self.player.w = SOLDIER_W -- 1246
		self.player.h = SOLDIER_H -- 1247
		self.player.x = math.max(self.ox + 422, self.player.x) -- 1248
		self.partner = { -- 1249
			x = math.max(self.ox + 408, self.player.x - 24), -- 1250
			y = 0, -- 1251
			depth = 0, -- 1252
			depthSpeed = 0, -- 1253
			vx = 0, -- 1254
			vy = 0, -- 1255
			w = CHILD_W, -- 1256
			h = CHILD_H, -- 1257
			onGround = true, -- 1258
			facing = 1, -- 1259
			crouch = false, -- 1260
			rollT = 0, -- 1261
			covered = false, -- 1262
			alive = true -- 1263
		} -- 1263
	end -- 1263
	if self.room.key == "tower" then -- 1263
		if story.segments.tower_door == true then -- 1263
			self:openTowerDoor() -- 1269
		end -- 1269
		self.towerHanded = story.segments.tower_handover == true -- 1271
		self.deskHold = 0 -- 1272
		if story.phase == "tower-enter" or story.phase == "tower-desk" or story.phase == "tower-given" then -- 1272
			self.phase = story.phase -- 1274
			self.phaseTick = 0 -- 1275
			if story.phase == "tower-desk" or story.phase == "tower-given" then -- 1275
				self.player.x = self.ox + 605 -- 1277
				self.player.y = 0 -- 1278
				if story.route == "soldier" and self.partner.alive then -- 1278
					self.partner.x = self.ox + 568 -- 1280
					self.partner.y = 0 -- 1281
					self.partner.facing = 1 -- 1282
				end -- 1282
			end -- 1282
		end -- 1282
	end -- 1282
	if self.room.key == "prologue" then -- 1282
		local ph = story.phase -- 1289
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 1289
			self.phase = ph -- 1291
			self.phaseTick = story.phaseTick -- 1292
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 1293
			self.player.y = 0 -- 1294
			self.player.depth = 0 -- 1295
			self.player.vx = 0 -- 1296
			self.partner.x = self.ox + 300 -- 1297
			self.partner.y = 0 -- 1298
			self.partner.depth = 0 -- 1299
			self.partner.vx = 0 -- 1300
			self.partner.alive = true -- 1301
			if ph == "prologue-follow" then -- 1301
				self.partner.crouch = false -- 1303
				self.partner.h = CHILD_H -- 1304
			else -- 1304
				self.partner.crouch = true -- 1306
				self.partner.h = CHILD_CROUCH_H -- 1307
			end -- 1307
			self.cam.x = self.player.x -- 1309
		end -- 1309
		return -- 1311
	end -- 1311
	if self.room.key ~= "gate" then -- 1311
		return -- 1314
	end -- 1314
	local ____temp_51 -- 1316
	if self.room.story == nil then -- 1316
		____temp_51 = nil -- 1316
	else -- 1316
		____temp_51 = self.room.story.gate -- 1316
	end -- 1316
	local g = ____temp_51 -- 1316
	if g == nil then -- 1316
		return -- 1318
	end -- 1318
	if story.phase == "gate-send" then -- 1318
		self.phase = "gate-send" -- 1322
		self.gateTick = g.holdTicks -- 1323
		self.gateSpawned = 4 -- 1324
		self.enemies = {} -- 1325
		self.player.x = self.ox + g.doorX - 40 -- 1326
		self.player.y = 0 -- 1327
		self.player.depth = 0 -- 1328
		self.player.vx = 0 -- 1329
		self.player.vy = 0 -- 1330
		self.player.onGround = true -- 1331
		self.partner.x = self.ox + g.waitX -- 1332
		self.partner.y = 0 -- 1333
		self.partner.depth = 0 -- 1334
		self.partner.alive = true -- 1335
		self.cam.x = self.player.x -- 1336
		self.handTicks = 0 -- 1337
		self.handArmed = false -- 1338
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1339
		return -- 1340
	end -- 1340
	if not story.settled then -- 1340
		return -- 1343
	end -- 1343
	self.gateTick = g.holdTicks -- 1346
	self.gateSpawned = 4 -- 1347
	self.enemies = {} -- 1348
	if story.phase == "gate-farewell" or story.phase == "gate-count" or story.phase == "gate-walk" then -- 1348
		self.phase = story.phase == "gate-farewell" and "gate-count" or story.phase -- 1350
		self.countTick = story.phase == "gate-farewell" and 0 or math.max(story.countTick, 0) -- 1351
		self:swapToChild(g.doorX + 30) -- 1352
		self.countPrevMove = 0 -- 1353
		self.countArmed = false -- 1354
		return -- 1355
	end -- 1355
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1355
		self.phase = story.phase -- 1358
		self.countTick = ____exports.GATE_COUNT_END -- 1359
		self.phaseTick = story.phaseTick -- 1360
		self:swapToChild(g.doorX + 30) -- 1361
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1362
			0, -- 1362
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1362
		) -- 1362
		self.handArmed = false -- 1363
	end -- 1363
end -- 1210
function Play.prototype.buildWorld(self) -- 1368
	local room = self.room -- 1369
	self.boxes = {} -- 1370
	self.floors = {} -- 1371
	local i = 0 -- 1372
	do -- 1372
		i = 0 -- 1373
		while i < #room.floors do -- 1373
			local f = room.floors[i + 1] -- 1374
			local ____self_floors_52 = self.floors -- 1374
			____self_floors_52[#____self_floors_52 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1375
			i = i + 1 -- 1373
		end -- 1373
	end -- 1373
	do -- 1373
		i = 0 -- 1377
		while i < #room.solids do -- 1377
			local s = room.solids[i + 1] -- 1378
			if not s.decorative then -- 1378
				local ____self_boxes_64 = self.boxes -- 1384
				local ____s_x_55 = s.x -- 1385
				local ____temp_56 = s.x + s.w -- 1385
				local ____s_y_57 = s.y -- 1385
				local ____temp_58 = s.y + s.h -- 1385
				local ____temp_53 -- 1386
				if room.depth == nil then -- 1386
					____temp_53 = nil -- 1386
				else -- 1386
					____temp_53 = s.depth -- 1386
				end -- 1386
				local ____temp_59 = s.passable == true -- 1387
				local ____s_label_60 = s.label -- 1387
				local ____s_id_61 = s.id -- 1388
				local ____temp_62 = s.soft == true -- 1388
				local ____temp_63 = s.hidden == true -- 1388
				local ____temp_54 -- 1389
				if s.breakable == nil then -- 1389
					____temp_54 = nil -- 1389
				else -- 1389
					____temp_54 = __TS__ObjectAssign({}, s.breakable) -- 1389
				end -- 1389
				____self_boxes_64[#____self_boxes_64 + 1] = { -- 1384
					x0 = ____s_x_55, -- 1385
					x1 = ____temp_56, -- 1385
					y0 = ____s_y_57, -- 1385
					y1 = ____temp_58, -- 1385
					depth = ____temp_53, -- 1386
					passable = ____temp_59, -- 1387
					label = ____s_label_60, -- 1387
					id = ____s_id_61, -- 1388
					soft = ____temp_62, -- 1388
					hidden = ____temp_63, -- 1388
					breakable = ____temp_54, -- 1389
					interact = s.interact -- 1390
				} -- 1390
			end -- 1390
			i = i + 1 -- 1377
		end -- 1377
	end -- 1377
	do -- 1377
		i = 0 -- 1394
		while i < #room.stairs do -- 1394
			local st = room.stairs[i + 1] -- 1395
			local n = st.steps + 1 -- 1396
			local stepW = (st.x1 - st.x0) / n -- 1397
			local k = 0 -- 1398
			do -- 1398
				k = 0 -- 1399
				while k < n do -- 1399
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1400
					local x0 = st.x0 + stepW * k -- 1401
					local ____self_boxes_68 = self.boxes -- 1404
					local ____temp_66 = x0 + stepW -- 1405
					local ____temp_67 = -8 -- 1405
					local ____temp_65 -- 1406
					if room.depth == nil then -- 1406
						____temp_65 = nil -- 1406
					else -- 1406
						____temp_65 = st.depth -- 1406
					end -- 1406
					____self_boxes_68[#____self_boxes_68 + 1] = { -- 1404
						x0 = x0, -- 1405
						x1 = ____temp_66, -- 1405
						y0 = ____temp_67, -- 1405
						y1 = y, -- 1405
						depth = ____temp_65, -- 1406
						passable = true -- 1407
					} -- 1407
					k = k + 1 -- 1399
				end -- 1399
			end -- 1399
			i = i + 1 -- 1394
		end -- 1394
	end -- 1394
end -- 1368
function Play.prototype.setupCampaign(self) -- 1417
	local wr = self.room -- 1418
	local c = wr.campaign -- 1419
	if c == nil then -- 1419
		return -- 1421
	end -- 1421
	self.roomStartTick = self.run.ticks -- 1423
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1423
		self.run.joined = true -- 1427
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1427
		local ____self_run_73 = self.run -- 1430
		local ____temp_72 -- 1430
		if wr.key == "s2-drygoods" then -- 1430
			local ____temp_71 = self.run.route ~= "drygoods" -- 1431
			if not ____temp_71 then -- 1431
				local ____opt_69 = self.run.props.s2_board -- 1431
				____temp_71 = (____opt_69 and ____opt_69.broken) == true -- 1431
			end -- 1431
			____temp_72 = ____temp_71 -- 1431
		else -- 1431
			____temp_72 = wr.key == "c1-yard" and self.run.c1Latch -- 1432
		end -- 1432
		____self_run_73.joined = ____temp_72 -- 1430
	end -- 1430
	local x = wr.minX + 60 -- 1434
	local y = 0 -- 1435
	local depth = 0 -- 1436
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1436
		x = wr.minX + 210 -- 1438
		depth = -32 -- 1439
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1439
		x = wr.minX + 40 -- 1441
		y = 32 -- 1442
		depth = 32 -- 1443
	end -- 1443
	self.player = { -- 1445
		x = x, -- 1446
		y = y, -- 1446
		depth = depth, -- 1446
		depthSpeed = 0, -- 1446
		vx = 0, -- 1446
		vy = 0, -- 1446
		w = SOLDIER_W, -- 1447
		h = SOLDIER_H, -- 1447
		onGround = y <= 0, -- 1447
		facing = 1, -- 1447
		crouch = false, -- 1447
		rollT = 0, -- 1447
		covered = false, -- 1447
		alive = true -- 1447
	} -- 1447
	self.partner = { -- 1449
		x = x + 60, -- 1450
		y = y, -- 1450
		depth = depth, -- 1450
		depthSpeed = 0, -- 1450
		vx = 0, -- 1450
		vy = 0, -- 1450
		w = CHILD_W, -- 1451
		h = CHILD_H, -- 1451
		onGround = y <= 0, -- 1451
		facing = 1, -- 1451
		crouch = false, -- 1451
		rollT = 0, -- 1451
		covered = false, -- 1451
		alive = true -- 1451
	} -- 1451
	self.cam.x = x -- 1453
	self.cam.y = y + CAM_LOOK_UP -- 1454
	self.phase = "run" -- 1455
	self.hp = self.maxHp -- 1456
	if self:isEscortRoom() and self.run.story.route == "soldier" then -- 1456
		if self.run.story.talents == nil then -- 1456
			self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 1459
		end -- 1459
		local st = self.run.story.talents -- 1461
		local variants = ESCORT_VARIANTS[wr.key] -- 1462
		if self.run.source ~= "debug" and variants ~= nil and #variants > 0 then -- 1462
			st.variant = pickEscortVariant(self.run.seed, st.attempt, wr.key, #variants) -- 1464
		else -- 1464
			st.variant = 0 -- 1466
		end -- 1466
		if wr.key == "escort3" then -- 1466
			if st.room ~= "escort3" then -- 1466
				st.room = "escort3" -- 1472
				st.deferred = true -- 1473
				st.offers = {} -- 1474
			end -- 1474
		else -- 1474
			draftTalentOffers(st, wr.key, self.equippedWeapon) -- 1477
		end -- 1477
	end -- 1477
	self:buildEnemies() -- 1480
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1481
	local i = 0 -- 1482
	do -- 1482
		i = 0 -- 1483
		while i < #self.boxes do -- 1483
			do -- 1483
				local b = self.boxes[i + 1] -- 1484
				if b.id == nil then -- 1484
					goto __continue157 -- 1486
				end -- 1486
				local st = self.run.props[b.id] -- 1488
				if st ~= nil then -- 1488
					b.broken = st.broken -- 1490
					local ____temp_74 -- 1491
					if b.breakable == nil then -- 1491
						____temp_74 = nil -- 1491
					else -- 1491
						____temp_74 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1491
					end -- 1491
					b.breakable = ____temp_74 -- 1491
					b.hidden = b.hidden == true and st.revealed ~= true -- 1492
					if b.hidden then -- 1492
						b.broken = true -- 1494
					end -- 1494
				elseif b.hidden == true then -- 1494
					b.broken = true -- 1498
				end -- 1498
			end -- 1498
			::__continue157:: -- 1498
			i = i + 1 -- 1483
		end -- 1483
	end -- 1483
	if wr.cart.bodyW > 0 then -- 1483
		self.cartAxle = wr.cart.startX -- 1502
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1502
			self.cartAxle = wr.cart.endX -- 1504
			self.cartDocked = true -- 1505
		end -- 1505
	end -- 1505
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1508
end -- 1417
function Play.prototype.log(self, line) -- 1511
	local ____self_run_log_75 = self.run.log -- 1511
	____self_run_log_75[#____self_run_log_75 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1512
	if #self.run.log > 120 then -- 1512
		table.remove(self.run.log, 1) -- 1514
	end -- 1514
end -- 1511
function Play.prototype.buildEnemies(self) -- 1518
	self.enemies = {} -- 1519
	if self.isCampaign then -- 1519
		local variants = ESCORT_VARIANTS[self.room.key] -- 1521
		local useVariant = self:isEscortRoom() and self.run.story.route == "soldier" and self.run.source ~= "debug" and variants ~= nil and #variants > 0 -- 1522
		local ____useVariant_79 -- 1527
		if useVariant then -- 1527
			local ____temp_78 = #variants - 1 -- 1528
			local ____opt_76 = self.run.story.talents -- 1528
			____useVariant_79 = math.max( -- 1528
				0, -- 1528
				math.min(____temp_78, ____opt_76 and ____opt_76.variant or 0) -- 1528
			) -- 1528
		else -- 1528
			____useVariant_79 = 0 -- 1529
		end -- 1529
		local vIdx = ____useVariant_79 -- 1527
		local spawnList = useVariant and variants[vIdx + 1] or self.room.spawns -- 1530
		local i = 0 -- 1531
		do -- 1531
			i = 0 -- 1532
			while i < #spawnList do -- 1532
				local sp = spawnList[i + 1] -- 1533
				local kind = sp.kind or "gunner" -- 1534
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1535
				local sx = useVariant and self.ox + sp.x or sp.x -- 1536
				local ____self_enemies_80 = self.enemies -- 1536
				____self_enemies_80[#____self_enemies_80 + 1] = { -- 1537
					x = sx, -- 1538
					y = sp.y, -- 1538
					depth = sp.depth, -- 1538
					w = 26, -- 1538
					h = sp.h, -- 1538
					alive = true, -- 1538
					hitT = 0, -- 1538
					warnT = 0, -- 1538
					fireCd = 40, -- 1538
					kind = kind, -- 1539
					shieldHp = hp, -- 1539
					shieldHpMax = hp, -- 1539
					drop = sp.drop or "none", -- 1539
					homeX = sx, -- 1540
					swingT = 0, -- 1540
					awake = false, -- 1540
					squad = i -- 1540
				} -- 1540
				i = i + 1 -- 1532
			end -- 1532
		end -- 1532
		return -- 1543
	end -- 1543
	if self.room.key == "checkpoint" then -- 1543
		local ____self_enemies_81 = self.enemies -- 1543
		____self_enemies_81[#____self_enemies_81 + 1] = { -- 1546
			x = self.ox + 430, -- 1546
			y = 0, -- 1546
			w = 26, -- 1546
			h = 84, -- 1546
			alive = true, -- 1546
			hitT = 0, -- 1546
			warnT = 0, -- 1546
			fireCd = 0 -- 1546
		} -- 1546
		local ____self_enemies_82 = self.enemies -- 1546
		____self_enemies_82[#____self_enemies_82 + 1] = { -- 1547
			x = self.ox + 505, -- 1547
			y = 0, -- 1547
			w = 26, -- 1547
			h = 84, -- 1547
			alive = true, -- 1547
			hitT = 0, -- 1547
			warnT = 0, -- 1547
			fireCd = 0 -- 1547
		} -- 1547
		return -- 1548
	end -- 1548
	if self.room.key == "street" then -- 1548
		local ____self_enemies_83 = self.enemies -- 1548
		____self_enemies_83[#____self_enemies_83 + 1] = { -- 1552
			x = self.ox + 340, -- 1552
			y = 0, -- 1552
			w = 26, -- 1552
			h = 84, -- 1552
			alive = true, -- 1552
			hitT = 0, -- 1552
			warnT = 0, -- 1552
			fireCd = 0 -- 1552
		} -- 1552
		local ____self_enemies_84 = self.enemies -- 1552
		____self_enemies_84[#____self_enemies_84 + 1] = { -- 1553
			x = self.ox + 560, -- 1553
			y = 0, -- 1553
			w = 26, -- 1553
			h = 84, -- 1553
			alive = true, -- 1553
			hitT = 0, -- 1553
			warnT = 0, -- 1553
			fireCd = 0 -- 1553
		} -- 1553
	end -- 1553
end -- 1518
function Play.prototype.emit(self, name, data) -- 1559
	local ____self_events_85 = self.events -- 1559
	____self_events_85[#____self_events_85 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1560
	self.eventSeq = self.eventSeq + 1 -- 1561
	if #self.events > 256 then -- 1561
		table.remove(self.events, 1) -- 1563
	end -- 1563
end -- 1559
function Play.prototype.drainEvents(self) -- 1571
	local out = self.events -- 1572
	self.events = {} -- 1573
	return out -- 1574
end -- 1571
function Play.prototype.adoptEvents(self, events) -- 1583
	if #events == 0 then -- 1583
		return -- 1585
	end -- 1585
	local keep = {} -- 1587
	local i = 0 -- 1588
	do -- 1588
		i = 0 -- 1589
		while i < #events do -- 1589
			do -- 1589
				local e = events[i + 1] -- 1590
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1590
					goto __continue178 -- 1592
				end -- 1592
				keep[#keep + 1] = e -- 1594
			end -- 1594
			::__continue178:: -- 1594
			i = i + 1 -- 1589
		end -- 1589
	end -- 1589
	if #keep == 0 then -- 1589
		return -- 1597
	end -- 1597
	self.events = __TS__ArrayConcat(keep, self.events) -- 1599
	do -- 1599
		i = 0 -- 1600
		while i < #self.events do -- 1600
			self.events[i + 1].seq = i -- 1601
			i = i + 1 -- 1600
		end -- 1600
	end -- 1600
	self.eventSeq = #self.events -- 1603
end -- 1583
function Play.prototype.talentRank(self, talent) -- 1606
	if self.storyRoute == "soldier" and self:isEscortRoom() and self.run.story.talents ~= nil then -- 1606
		return self.run.story.talents.ranks[talent] or 0 -- 1608
	end -- 1608
	return 0 -- 1610
end -- 1606
function Play.prototype.reloadNeedTicks(self) -- 1614
	return RELOAD_ANSWER_TICKS + 60 * self:talentRank("focus") -- 1615
end -- 1614
function Play.prototype.getStoryTalentOffers(self) -- 1619
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1619
		return {} -- 1621
	end -- 1621
	local st = self.run.story.talents -- 1623
	return st ~= nil and st.room == self.room.key and st.offers or ({}) -- 1624
end -- 1619
function Play.prototype.getStoryTalentRanks(self) -- 1628
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() then -- 1628
		return nil -- 1630
	end -- 1630
	return self.run.story.talents ~= nil and self.run.story.talents.ranks or nil -- 1632
end -- 1628
function Play.prototype.getEscortAttempt(self) -- 1636
	return self.run.story.talents ~= nil and math.max(1, self.run.story.talents.attempt) or 1 -- 1637
end -- 1636
function Play.prototype.chooseTalent(self, slot) -- 1640
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1640
		return false -- 1642
	end -- 1642
	local st = self.run.story.talents -- 1644
	local talent = st ~= nil and st.offers[slot + 1] or nil -- 1645
	if st == nil or talent == nil then -- 1645
		return false -- 1647
	end -- 1647
	st.ranks[talent] = (st.ranks[talent] or 0) + 1 -- 1649
	st.offers = {} -- 1650
	self.talentModalActive = false -- 1651
	local extraMsg = "" -- 1652
	if talent == "vitality" then -- 1652
		self.maxHp = self.maxHp + 1 -- 1654
		self.hp = self.hp + 1 -- 1655
		self.run.story.maxHp = self.maxHp -- 1656
		self.run.story.hp = self.hp -- 1657
	elseif talent == "salvage" then -- 1657
		local inv = self.run.inventory -- 1659
		if inv.wood < 2 and inv.wood <= inv.bell or inv.bell >= 1 and st.ranks.salvage % 2 == 1 then -- 1659
			inv.wood = inv.wood + 1 -- 1661
			extraMsg = " · 得木纹筹×1" -- 1662
		else -- 1662
			inv.bell = inv.bell + 1 -- 1664
			extraMsg = " · 得铃纹筹×1" -- 1665
		end -- 1665
		self:syncCraftBench() -- 1667
	end -- 1667
	self.sessionDirty = true -- 1669
	self:flashSet(("本领 · " .. talentNames[talent]) .. extraMsg, 1.5) -- 1670
	self:emit("storyBeat", {beat = "talent_picked", talent = talent, rank = st.ranks[talent], room = self.room.key}) -- 1671
	return true -- 1672
end -- 1640
function Play.prototype.beginReload(self) -- 1679
	self.reloadT = self:reloadTicks() -- 1680
	local camp = self.room.campaign -- 1681
	if camp ~= nil and camp.reloadPuzzle == true then -- 1681
		self:openReloadPuzzle() -- 1683
	end -- 1683
end -- 1679
function Play.prototype.openReloadPuzzle(self) -- 1688
	self.reloadOpen = true -- 1689
	self.reloadAnswerTicks = 0 -- 1690
	self.reloadWorldTicks = 0 -- 1691
	self.reloadPath = {RELOAD_START} -- 1692
	self.reloadPendingEffect = "" -- 1693
	self.reloadTryCount = self.reloadTryCount + 1 -- 1694
	self:emit( -- 1695
		"reloadOpen", -- 1695
		{ -- 1695
			tryCount = self.reloadTryCount, -- 1695
			needTicks = self:reloadNeedTicks() -- 1695
		} -- 1695
	) -- 1695
end -- 1688
function Play.prototype.closeReloadPuzzle(self) -- 1699
	self.reloadOpen = false -- 1700
	self.reloadAnswerTicks = 0 -- 1701
	self.reloadWorldTicks = 0 -- 1702
	self.reloadPath = {RELOAD_START} -- 1703
	self.reloadPendingEffect = "" -- 1704
end -- 1699
function Play.prototype.reloadTapNode(self, node) -- 1711
	if not self.reloadOpen then -- 1711
		return -- 1713
	end -- 1713
	local path = self.reloadPath -- 1715
	local last = path[#path] -- 1716
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1716
		self.reloadPath = {RELOAD_START} -- 1718
		self:emit("reloadInvalid", {node = node, at = last}) -- 1719
		return -- 1720
	end -- 1720
	path[#path + 1] = node -- 1722
	if node ~= RELOAD_TARGET then -- 1722
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1724
		return -- 1725
	end -- 1725
	if not reloadPathValid(path) then -- 1725
		self.reloadPath = {RELOAD_START} -- 1728
		self:emit("reloadInvalid", {node = node, at = last}) -- 1729
		return -- 1730
	end -- 1730
	self.reloadPendingEffect = reloadEffectOf(path) -- 1732
	self.reloadOpen = false -- 1733
	self.reloadT = 0 -- 1734
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1735
	self:flashSet( -- 1738
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1738
		1.4 -- 1738
	) -- 1738
end -- 1711
function Play.prototype.consumeReloadEffect(self) -- 1742
	local e = self.reloadPendingEffect -- 1743
	if e ~= "" then -- 1743
		self.reloadPendingEffect = "" -- 1745
	end -- 1745
	return e -- 1747
end -- 1742
function Play.prototype.echoToSource(self, from, count, delayTicks) -- 1754
	if count == nil then -- 1754
		count = 1 -- 1754
	end -- 1754
	if delayTicks == nil then -- 1754
		delayTicks = 60 -- 1754
	end -- 1754
	local best = -1 -- 1755
	local bestD = 1000000000 -- 1756
	local i = 0 -- 1757
	local woken = {} -- 1758
	local n = 0 -- 1759
	while n < count do -- 1759
		best = -1 -- 1761
		bestD = 1000000000 -- 1762
		do -- 1762
			i = 0 -- 1763
			while i < #self.enemies do -- 1763
				do -- 1763
					if woken[i] == true then -- 1763
						goto __continue212 -- 1765
					end -- 1765
					local e = self.enemies[i + 1] -- 1767
					if not e.alive then -- 1767
						goto __continue212 -- 1769
					end -- 1769
					local d = math.abs(e.x - from.x) -- 1771
					if d < bestD then -- 1771
						bestD = d -- 1773
						best = i -- 1774
					end -- 1774
				end -- 1774
				::__continue212:: -- 1774
				i = i + 1 -- 1763
			end -- 1763
		end -- 1763
		if best < 0 then -- 1763
			break -- 1778
		end -- 1778
		woken[best] = true -- 1780
		local e = self.enemies[best + 1] -- 1781
		e.awake = true -- 1782
		e.warnT = 0 -- 1783
		e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 1784
		n = n + 1 -- 1785
	end -- 1785
	if n == 0 then -- 1785
		return -- 1788
	end -- 1788
	self:flashSet(n > 1 and "回声引到多处声源 · 敌群同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1790
end -- 1754
function Play.prototype.reloadTicks(self) -- 1793
	return math.max(6, self.run.inventory.quickbelt > 0 and 36 or 54) -- 1794
end -- 1793
function Play.prototype.update(self, dt, input) -- 1797
	self:syncCraftBench() -- 1798
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1798
		self:closeCraftBench() -- 1800
		return -- 1801
	end -- 1801
	if input.pause.pressed then -- 1801
		self.paused = not self.paused -- 1804
	end -- 1804
	if self.flashT > 0 then -- 1804
		self.flashT = self.flashT - dt -- 1807
		if self.flashT <= 0 then -- 1807
			self.flash = "" -- 1809
		end -- 1809
	end -- 1809
	if self.traceT > 0 then -- 1809
		self.traceT = self.traceT - dt -- 1813
		if self.traceT <= 0 then -- 1813
			self.trace = nil -- 1815
		end -- 1815
	end -- 1815
	if self.paused then -- 1815
		self:updateCamera(dt) -- 1819
		return -- 1820
	end -- 1820
	if self.escortFailed then -- 1820
		self.escortFailedTicks = self.escortFailedTicks + 1 -- 1824
		self:updateCamera(dt) -- 1825
		return -- 1826
	end -- 1826
	if self.craftBench.active then -- 1826
		self:updateCamera(dt) -- 1831
		return -- 1832
	end -- 1832
	if self.talentModalActive and #self:getStoryTalentOffers() > 0 and not self.reloadOpen then -- 1832
		self:updateCamera(dt) -- 1836
		return -- 1837
	end -- 1837
	if self.reloadOpen then -- 1837
		local needTicks = self:reloadNeedTicks() -- 1843
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1844
		if self.reloadAnswerTicks > needTicks then -- 1844
			self.reloadOpen = false -- 1846
			self.reloadPendingEffect = "" -- 1847
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = needTicks}) -- 1848
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1849
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1849
			self:updateCamera(dt) -- 1851
			return -- 1852
		else -- 1852
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1854
		end -- 1854
	end -- 1854
	self.ticks = self.ticks + 1 -- 1858
	if self.invulnT > 0 then -- 1858
		self.invulnT = self.invulnT - 1 -- 1862
	end -- 1862
	if self.isCampaign then -- 1862
		local ____self_run_86, ____ticks_87 = self.run, "ticks" -- 1862
		____self_run_86[____ticks_87] = ____self_run_86[____ticks_87] + 1 -- 1865
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1866
	end -- 1866
	local p = self.player -- 1868
	self:stepPlayer(p, dt, input) -- 1869
	self:refreshCover(p, input) -- 1871
	if self.carryOn then -- 1871
		self:carryPose() -- 1873
	end -- 1873
	if self.isCampaign then -- 1873
		self:stepCampaign(dt, input) -- 1876
		if not self.carryOn then -- 1876
			self:stepCampaignPartner(dt) -- 1878
		end -- 1878
	end -- 1878
	self:stepEnemies(dt, input) -- 1883
	if not self.isCampaign then -- 1883
		self:stepStory(dt, input) -- 1885
		self:stepEscort(dt, input) -- 1886
		self:stepVillage(dt, input) -- 1887
		self:stepChase(dt, input) -- 1888
		self:stepInteract(dt, input) -- 1889
	end -- 1889
	self:updateGate() -- 1891
	self:updateCamera(dt) -- 1892
	self:syncStory() -- 1894
end -- 1797
function Play.prototype.underLowArch(self, a) -- 1901
	local arch = self.room.arch -- 1902
	if arch.h <= 0 then -- 1902
		return false -- 1904
	end -- 1904
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1904
		return false -- 1907
	end -- 1907
	local top = arch.y + arch.h -- 1909
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1910
end -- 1901
function Play.prototype.coverAt(self, a) -- 1917
	local best = nil -- 1918
	local bestGap = 24 -- 1919
	local half = a.w / 2 -- 1920
	local i = 0 -- 1921
	do -- 1921
		i = 0 -- 1922
		while i < #self.boxes do -- 1922
			do -- 1922
				local b = self.boxes[i + 1] -- 1923
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1923
					goto __continue245 -- 1925
				end -- 1925
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1925
					goto __continue245 -- 1928
				end -- 1928
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1930
				if gap < bestGap then -- 1930
					bestGap = gap -- 1932
					best = b -- 1933
				end -- 1933
			end -- 1933
			::__continue245:: -- 1933
			i = i + 1 -- 1922
		end -- 1922
	end -- 1922
	return best -- 1936
end -- 1917
function Play.prototype.nearCover(self, a) -- 1939
	return self:coverAt(a) ~= nil -- 1940
end -- 1939
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1944
	if enemy == nil then -- 1944
		return false -- 1946
	end -- 1946
	local fromRight = enemy.x >= a.x -- 1948
	local edge = fromRight and b.x0 or b.x1 -- 1949
	local ____fromRight_88 -- 1950
	if fromRight then -- 1950
		____fromRight_88 = edge >= a.x - 0.001 and edge <= enemy.x -- 1950
	else -- 1950
		____fromRight_88 = edge <= a.x + 0.001 and edge >= enemy.x -- 1951
	end -- 1951
	local between = ____fromRight_88 -- 1950
	local separation = enemy.x - a.x -- 1952
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1953
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1954
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1955
end -- 1944
function Play.prototype.nearestEnemy(self, a) -- 1958
	local best -- 1959
	local bestD = 1000000000 -- 1960
	local i = 0 -- 1961
	do -- 1961
		i = 0 -- 1962
		while i < #self.enemies do -- 1962
			do -- 1962
				local e = self.enemies[i + 1] -- 1963
				if not e.alive then -- 1963
					goto __continue254 -- 1965
				end -- 1965
				local d = math.abs(e.x - a.x) -- 1967
				if d < bestD then -- 1967
					bestD = d -- 1969
					best = e -- 1970
				end -- 1970
			end -- 1970
			::__continue254:: -- 1970
			i = i + 1 -- 1962
		end -- 1962
	end -- 1962
	return best -- 1973
end -- 1958
function Play.prototype.refreshCover(self, a, input) -- 1977
	if self.childMode then -- 1977
		self.coverNear = false -- 1979
		self.coverHug = false -- 1980
		self.coverEntity = "" -- 1981
		self.coverBlocking = false -- 1982
		a.covered = false -- 1983
		return -- 1984
	end -- 1984
	local b = self:coverAt(a) -- 1986
	self.coverNear = b ~= nil -- 1987
	a.covered = self.coverNear and input.cover.held -- 1988
	self.coverHug = a.covered -- 1989
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1990
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1991
		b, -- 1991
		a, -- 1991
		self:nearestEnemy(a) -- 1991
	) -- 1991
end -- 1977
function Play.prototype.cartHandleInReach(self, a) -- 1995
	if a == nil then -- 1995
		a = self.player -- 1995
	end -- 1995
	local c = self.room.cart -- 1996
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1996
		return false -- 1998
	end -- 1998
	local handleX = self.cartAxle + c.handleOffset -- 2000
	local ____table_childMode_89 -- 2001
	if self.childMode then -- 2001
		____table_childMode_89 = math.abs(a.depth - (c.depth or 0)) <= 48 -- 2002
	else -- 2002
		____table_childMode_89 = inReachDepth(a.depth, c.depth or 0) -- 2003
	end -- 2003
	local depthOk = ____table_childMode_89 -- 2001
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and depthOk -- 2004
end -- 1995
function Play.prototype.nearLowLedge(self, a) -- 2009
	local reach = 26 -- 2010
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 2011
	local x1 = x0 + reach -- 2012
	local i = 0 -- 2013
	do -- 2013
		i = 0 -- 2014
		while i < #self.boxes do -- 2014
			do -- 2014
				local b = self.boxes[i + 1] -- 2015
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2015
					goto __continue263 -- 2017
				end -- 2017
				local rise = b.y1 - a.y -- 2019
				if rise > 0 and rise <= LEDGE_RISE then -- 2019
					return true -- 2021
				end -- 2021
			end -- 2021
			::__continue263:: -- 2021
			i = i + 1 -- 2014
		end -- 2014
	end -- 2014
	return false -- 2024
end -- 2009
function Play.prototype.stepPlayer(self, a, dt, input) -- 2027
	a.depthSpeed = 0 -- 2028
	if not a.alive then -- 2028
		return -- 2030
	end -- 2030
	local isChild = self.childMode -- 2032
	local lowArch = isChild and self:underLowArch(a) -- 2034
	if self:storyLocked() then -- 2034
		a.vx = 0 -- 2037
		a.crouch = isChild and lowArch -- 2038
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2039
		self:fallY(a, dt) -- 2040
		return -- 2041
	end -- 2041
	if not isChild and self.escort.state == "calming" then -- 2041
		a.crouch = false -- 2045
		a.h = SOLDIER_H -- 2046
		a.vx = 0 -- 2047
		self:fallY(a, dt) -- 2048
		return -- 2049
	end -- 2049
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 2051
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 2052
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2053
	local nearCover = not isChild and self:nearCover(a) -- 2054
	a.covered = nearCover and input.cover.held -- 2055
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 2057
	if a.rollT > 0 then -- 2057
		a.rollT = a.rollT - dt -- 2061
		local rollSpd = self:isEscortRoom() and ROLL_SPEED * (1 + 0.08 * self:talentRank("stride")) or ROLL_SPEED -- 2062
		a.vx = a.facing * rollSpd -- 2063
		self:slideX(a, a.vx * dt) -- 2064
		self:fallY(a, dt) -- 2065
		if a.rollT <= 0 then -- 2065
			self:flashSet("翻滚结束", 0.5) -- 2067
		end -- 2067
		return -- 2069
	end -- 2069
	local peacefulRoom = self.room.key == "museum" or self.room.key == "tower" -- 2072
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 2072
		if input.moveX ~= 0 then -- 2072
			a.facing = input.moveX > 0 and 1 or -1 -- 2075
		end -- 2075
		if self:nearLowLedge(a) then -- 2075
			a.vy = SOLDIER_JUMP -- 2079
			a.onGround = false -- 2080
			self:flashSet("翻上去", 0.3) -- 2081
			return -- 2082
		end -- 2082
		a.rollT = ROLL_TIME -- 2084
		self:flashSet("翻滚", 0.3) -- 2085
		return -- 2086
	end -- 2086
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 2089
	if isChild then -- 2089
		if input.cover.held then -- 2089
			speed = CHILD_SLOW -- 2092
		end -- 2092
		if a.crouch then -- 2092
			speed = CHILD_SLOW -- 2095
		elseif self.room.key == "forest" and self.forestPath == "ditch" and a.x >= self.ox + 700 and a.x <= self.ox + 1140 then -- 2095
			speed = CHILD_SPEED * 1.22 -- 2099
		end -- 2099
	else -- 2099
		if self:isEscortRoom() then -- 2099
			speed = speed * (1 + 0.1 * self:talentRank("stride")) -- 2103
		end -- 2103
		if a.covered then -- 2103
			speed = speed * 0.45 -- 2106
		end -- 2106
	end -- 2106
	local handsBusy = self.gripping or gripIntent or self.reloadOpen -- 2111
	local dir = (self.gripping or self.reloadOpen) and 0 or input.moveX -- 2112
	local depthDir = self.room.depth ~= nil and not handsBusy and -input.moveY or 0 -- 2114
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 2115
	if dir ~= 0 then -- 2115
		a.facing = dir > 0 and 1 or -1 -- 2117
	end -- 2117
	a.vx = dir * speed * diagonal -- 2119
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 2119
		a.vy = CHILD_JUMP -- 2123
		a.onGround = false -- 2124
		self:flashSet("跳", 0.25) -- 2125
	end -- 2125
	local previousDepth = a.depth -- 2129
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 2130
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2131
	self:slideX(a, a.vx * dt) -- 2132
	self:fallY(a, dt) -- 2133
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and not self.reloadOpen and input.fire.pressed then -- 2133
		self:shoot(a) -- 2137
	end -- 2137
	local wantManualReload = input.flare.pressed or input:isKbmMode() and input.uiRightPressed -- 2140
	local ____temp_92 = not isChild and not peacefulRoom and not self.gripping and not self.reloadOpen and self.reloadPendingEffect == "" -- 2141
	if ____temp_92 then -- 2141
		local ____opt_90 = self.room.campaign -- 2141
		____temp_92 = (____opt_90 and ____opt_90.reloadPuzzle) == true -- 2141
	end -- 2141
	if ____temp_92 and wantManualReload then -- 2141
		input.uiRightPressed = false -- 2143
		self:beginReload() -- 2144
	end -- 2144
end -- 2027
function Play.prototype.stepPartner(self, p, dt) -- 2149
	local a = self.partner -- 2150
	if not a.alive then -- 2150
		return -- 2152
	end -- 2152
	a.crouch = false -- 2154
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 2155
	a.vx = 0 -- 2156
	a.depthSpeed = 0 -- 2157
	self:fallY(a, dt) -- 2158
end -- 2149
function Play.prototype.stepEscort(self, dt, input) -- 2165
	local a = self.partner -- 2166
	a.depthSpeed = 0 -- 2167
	if not a.alive then -- 2167
		return -- 2169
	end -- 2169
	if self.room.key == "gatepath" then -- 2169
		if self.carryOn then -- 2169
			return -- 2174
		end -- 2174
		local p = self.player -- 2177
		a.depth = p.depth -- 2178
		a.facing = p.facing -- 2179
		a.crouch = false -- 2180
		a.h = CHILD_H -- 2181
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 2182
		a.y = p.y -- 2183
		a.vy = 0 -- 2184
		a.vx = p.vx -- 2185
		a.onGround = p.onGround -- 2186
		return -- 2187
	end -- 2187
	if not self:escortOn() then -- 2187
		a.vx = 0 -- 2190
		self:fallY(a, dt) -- 2191
		return -- 2192
	end -- 2192
	local p = self.player -- 2194
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 2195
	local hadKnock1 = self.escort.knock1 -- 2196
	local hadKnock2 = self.escort.knock2 -- 2197
	self.calmConsumed = self.escort:update( -- 2198
		input, -- 2198
		p.x, -- 2198
		p.facing, -- 2198
		a.x, -- 2198
		dist -- 2198
	) -- 2198
	if not hadKnock1 and self.escort.knock1 then -- 2198
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 2201
	end -- 2201
	if not hadKnock2 and self.escort.knock2 then -- 2201
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 2204
	end -- 2204
	a.crouch = self.escort.crouchPose -- 2206
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 2207
	if not self.escort.stopped then -- 2207
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 2209
		local previousDepth = a.depth -- 2210
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 2211
		local distance = math.max( -- 2212
			-travel, -- 2212
			math.min(travel, targetDepth - previousDepth) -- 2212
		) -- 2212
		self:slideDepth(a, distance) -- 2213
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2214
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 2214
			a.vy = CHILD_JUMP -- 2216
			a.onGround = false -- 2217
		end -- 2217
	end -- 2217
	local dir = self.escort:moveDir(a.x) -- 2220
	a.vx = dir * CHILD_SPEED -- 2221
	if dir ~= 0 then -- 2221
		a.facing = dir -- 2223
		local before = a.x -- 2224
		self:slideX(a, dir * CHILD_SPEED * dt) -- 2225
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 2225
			a.vy = CHILD_JUMP -- 2228
			a.onGround = false -- 2229
		end -- 2229
	end -- 2229
	self:fallY(a, dt) -- 2232
end -- 2165
function Play.prototype.escortOn(self) -- 2236
	if self.room.key == "checkpoint" then -- 2236
		return true -- 2238
	end -- 2238
	if self.room.key == "gatepath" then -- 2238
		return true -- 2241
	end -- 2241
	if self.room.key == "prologue" then -- 2241
		return self.phase == "prologue-follow" -- 2244
	end -- 2244
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 2244
		return true -- 2248
	end -- 2248
	return self.room.key == "street" -- 2250
end -- 2236
function Play.prototype.storyLocked(self) -- 2254
	if self.caughtT > 0 then -- 2254
		return true -- 2256
	end -- 2256
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 2256
		return true -- 2260
	end -- 2260
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 2260
		return true -- 2263
	end -- 2263
	if self.room.key == "gate" and (self.phase == "gate-farewell" or self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 2263
		return true -- 2266
	end -- 2266
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2266
		return true -- 2269
	end -- 2269
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2269
		return true -- 2272
	end -- 2272
	if self.craftBench.active then -- 2272
		return true -- 2276
	end -- 2276
	return false -- 2278
end -- 2254
function Play.prototype.swapToChild(self, x) -- 2282
	local tmp = self.player -- 2283
	self.player = self.partner -- 2284
	self.partner = tmp -- 2285
	self.childMode = true -- 2286
	self.player.alive = true -- 2287
	self.player.x = self.ox + x -- 2288
	self.player.y = 0 -- 2289
	self.player.depth = 0 -- 2290
	self.player.depthSpeed = 0 -- 2291
	self.player.vy = 0 -- 2292
	self.player.vx = 0 -- 2293
	self.player.onGround = true -- 2294
	self.player.crouch = false -- 2295
	self.player.h = CHILD_H -- 2296
	self.player.facing = 1 -- 2297
	self.partner.alive = true -- 2298
	self.cam.x = self.player.x -- 2299
end -- 2282
function Play.prototype.swapToSoldier(self, x, childX) -- 2303
	local tmp = self.player -- 2304
	self.player = self.partner -- 2305
	self.partner = tmp -- 2306
	self.childMode = false -- 2307
	self.player.alive = true -- 2308
	self.player.x = self.ox + x -- 2309
	self.player.y = 0 -- 2310
	self.player.depth = 0 -- 2311
	self.player.depthSpeed = 0 -- 2312
	self.player.vy = 0 -- 2313
	self.player.vx = 0 -- 2314
	self.player.onGround = true -- 2315
	self.player.crouch = false -- 2316
	self.player.h = SOLDIER_H -- 2317
	self.player.facing = 1 -- 2318
	self.partner.alive = true -- 2319
	self.partner.x = self.ox + childX -- 2320
	self.partner.y = 0 -- 2321
	self.partner.depth = 0 -- 2322
	self.partner.depthSpeed = 0 -- 2323
	self.partner.vx = 0 -- 2324
	self.partner.vy = 0 -- 2325
	self.partner.onGround = true -- 2326
	self.partner.crouch = true -- 2327
	self.partner.h = CHILD_CROUCH_H -- 2328
	self.cam.x = self.player.x -- 2329
end -- 2303
function Play.prototype.stepStory(self, dt, input) -- 2333
	if self.room.key == "prologue" then -- 2333
		self:stepPrologue(dt, input) -- 2335
	elseif self.room.key == "street" then -- 2335
		self:stepStreet(dt, input) -- 2337
	elseif self.room.key == "gate" then -- 2337
		self:stepGate(dt, input) -- 2339
	elseif self.room.key == "gatepath" then -- 2339
		self:stepGatePath() -- 2341
	elseif self.room.key == "tower" then -- 2341
		self:stepTower(dt, input) -- 2343
	elseif self.room.key == "museum" then -- 2343
		self:stepMuseum(dt, input) -- 2345
	end -- 2345
end -- 2333
function Play.prototype.canPersistProgress(self) -- 2351
	return not self.isCampaign and self.run.source == "official" -- 2352
end -- 2351
function Play.prototype.wellWindow(self) -- 2356
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 2357
end -- 2356
function Play.prototype.nearWell(self) -- 2362
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 2363
end -- 2362
function Play.prototype.pickWell(self) -- 2371
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2371
		return false -- 2373
	end -- 2373
	self.phase = "prologue-well" -- 2375
	self.phaseTick = 0 -- 2376
	self.wellOpen = false -- 2377
	self:flashSet("井沿 · 伸手下去", 1.4) -- 2378
	self:log("旧井拾取") -- 2379
	return true -- 2380
end -- 2371
function Play.prototype.stepPrologue(self, dt, input) -- 2383
	local child = self.partner -- 2384
	if self.museumReturn then -- 2384
		self.museumReturn = false -- 2387
		self.phase = "prologue-wait" -- 2388
		self.phaseTick = 0 -- 2389
		self.player.x = self.ox + 260 -- 2390
		self.player.y = 0 -- 2391
		self.player.depth = 0 -- 2392
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2393
	end -- 2393
	if self.phase == "prologue-wake" then -- 2393
		self.introTick = self.introTick + 1 -- 2397
		if self.introTick == 60 then -- 2397
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2399
		end -- 2399
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2399
			self.phase = "prologue-shadow" -- 2402
			self.introTick = 0 -- 2403
			self:flashSet("门缝里两道影子", 1.2) -- 2404
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2405
		end -- 2405
		return -- 2407
	end -- 2407
	if self.phase == "prologue-shadow" then -- 2407
		self.introTick = self.introTick + 1 -- 2410
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2410
			self.phase = "prologue-escape" -- 2413
			self.introTick = 0 -- 2414
			self.escapeRemaining = self.escapeDuration -- 2415
			self.escapeRetryCount = 0 -- 2416
			self:swapToChild(100) -- 2417
			self:flashSet( -- 2418
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2418
				1.6 -- 2418
			) -- 2418
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2419
		end -- 2419
		return -- 2423
	end -- 2423
	if self.phase == "prologue-escape" then -- 2423
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2426
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2426
			self.phase = "prologue-hide" -- 2429
			self.introTick = 0 -- 2430
			self.player.vx = 0 -- 2431
			self.player.crouch = true -- 2432
			self.player.h = CHILD_CROUCH_H -- 2433
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2434
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2435
			return -- 2439
		end -- 2439
		if self.escapeRemaining <= 0 then -- 2439
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2443
			self.player.x = self.ox + 100 -- 2444
			self.player.y = 0 -- 2445
			self.player.depth = 0 -- 2446
			self.player.vx = 0 -- 2447
			self.player.vy = 0 -- 2448
			self.escapeRemaining = self.escapeDuration -- 2449
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2450
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2451
			return -- 2452
		end -- 2452
		return -- 2454
	end -- 2454
	if self.phase == "prologue-hide" then -- 2454
		self.introTick = self.introTick + 1 -- 2457
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2457
			self.phase = "prologue-wait" -- 2460
			self.phaseTick = 0 -- 2461
			self.introTick = 0 -- 2462
			self:swapToSoldier(260, 300) -- 2463
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2464
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2465
		end -- 2465
		return -- 2467
	end -- 2467
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2470
	if self.phase == "prologue-wait" then -- 2470
		child.crouch = true -- 2472
		child.h = CHILD_CROUCH_H -- 2473
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2473
			self:pickWell() -- 2475
			return -- 2476
		end -- 2476
		if not self.wellOpen and self:canPersistProgress() and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2476
			self.archive.museumPhase = "well_reflect" -- 2481
			self.archiveDirty = true -- 2482
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2483
			return -- 2484
		end -- 2484
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2486
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2488
		if near and input.interact.pressed then -- 2488
			self.phase = "prologue-give" -- 2490
			self.phaseTick = 0 -- 2491
			self:flashSet("递出针套", 1) -- 2492
		end -- 2492
		return -- 2494
	end -- 2494
	if self.phase == "prologue-well" then -- 2494
		self.phaseTick = self.phaseTick + 1 -- 2498
		if self.phaseTick == 12 then -- 2498
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2500
		elseif self.phaseTick >= 30 then -- 2500
			self.phase = "prologue-wait" -- 2502
			self.phaseTick = 0 -- 2503
			self.wellTaken = true -- 2504
			self.wellOpen = false -- 2505
			self.run.archive.artifactOwned = true -- 2506
			self.archiveDirty = true -- 2507
			self:emit("artifactFound", { -- 2508
				x = self.ox + self.wellX, -- 2509
				y = 0, -- 2509
				room = "prologue", -- 2509
				once = true, -- 2509
				source = self.run.source -- 2510
			}) -- 2510
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2512
			self:log("井底取到时间穿梭器") -- 2513
		end -- 2513
		return -- 2515
	end -- 2515
	if self.phase == "prologue-give" then -- 2515
		self.phaseTick = self.phaseTick + 1 -- 2518
		if self.phaseTick == 36 then -- 2518
			self:flashSet("针套递过去", 0.9) -- 2520
		elseif self.phaseTick == 108 then -- 2520
			self:flashSet("纸条塞进针套", 1) -- 2522
		elseif self.phaseTick >= ____exports.PROLOGUE_GIVE_TICKS then -- 2522
			self.phase = "prologue-follow" -- 2524
			self.phaseTick = 0 -- 2525
			child.crouch = false -- 2526
			child.h = CHILD_H -- 2527
			self:flashSet("她跟上了", 1.2) -- 2528
		end -- 2528
		return -- 2530
	end -- 2530
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2530
		local next = self.run.source == "debug" and "street" or "s1-crossroad" -- 2534
		self:requestRoom(next, "序章跟到门口") -- 2535
		self:flashSet(next == "s1-crossroad" and "进十字街" or "进街道", 1.2) -- 2536
	end -- 2536
end -- 2383
function Play.prototype.stepStreet(self, dt, input) -- 2541
	local p = self.player -- 2542
	local c = self.partner -- 2543
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2543
		local next = self.run.source == "debug" and "checkpoint" or "s1-crossroad" -- 2545
		self:requestRoom(next, "两人都到街尾") -- 2546
		self:flashSet(next == "s1-crossroad" and "进十字街" or "到检查站", 1.2) -- 2547
	end -- 2547
end -- 2541
function Play.prototype.stepGate(self, dt, input) -- 2552
	local ____temp_93 -- 2553
	if self.room.story == nil then -- 2553
		____temp_93 = nil -- 2553
	else -- 2553
		____temp_93 = self.room.story.gate -- 2553
	end -- 2553
	local g = ____temp_93 -- 2553
	if g == nil then -- 2553
		return -- 2555
	end -- 2555
	local p = self.player -- 2557
	if self.phase == "gate-idle" then -- 2557
		local a = self.partner -- 2560
		local gap = g.waitX - a.x -- 2561
		if math.abs(gap) > 3 then -- 2561
			a.facing = gap > 0 and 1 or -1 -- 2563
			a.vx = a.facing * CHILD_SPEED -- 2564
			local beforeX = a.x -- 2565
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2566
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2566
				a.vy = CHILD_JUMP -- 2568
				a.onGround = false -- 2569
			end -- 2569
			self:fallY(a, dt) -- 2571
		else -- 2571
			a.vx = 0 -- 2573
			a.x = g.waitX -- 2574
		end -- 2574
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2577
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2578
		if self.gateNeedConfirm then -- 2578
			if not input.interact.held then -- 2578
				self.gateRestartArmed = true -- 2583
			end -- 2583
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2583
				self.gateNeedConfirm = false -- 2586
				self.gateRestartArmed = true -- 2587
				self.phase = "gate-hold" -- 2588
				self.gateTick = 0 -- 2589
				self.gateSpawned = 0 -- 2590
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2591
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2592
			end -- 2592
			return -- 2594
		end -- 2594
		if atWinch and atWait then -- 2594
			self.phase = "gate-hold" -- 2597
			self.gateTick = 0 -- 2598
			self.gateSpawned = 0 -- 2599
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2600
		end -- 2600
		return -- 2602
	end -- 2602
	if self.phase == "gate-hold" then -- 2602
		self.gateTick = self.gateTick + 1 -- 2605
		local marks = {0, 540, 900, 1500} -- 2607
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2607
			local idx = self.gateSpawned -- 2609
			local ____self_enemies_94 = self.enemies -- 2609
			____self_enemies_94[#____self_enemies_94 + 1] = { -- 2610
				x = self.ox + 620 + idx * 62, -- 2611
				y = 0, -- 2611
				w = 26, -- 2611
				h = 84, -- 2611
				alive = true, -- 2612
				hitT = 0, -- 2612
				warnT = 0, -- 2612
				fireCd = 90 + idx * 45 -- 2612
			} -- 2612
			self.gateSpawned = self.gateSpawned + 1 -- 2614
			self:flashSet( -- 2615
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2615
				0.9 -- 2615
			) -- 2615
		end -- 2615
		if self.gateTick == 900 then -- 2615
			self:flashSet("棚布落下", 1) -- 2618
		elseif self.gateTick == 2100 then -- 2618
			self:flashSet("门底透进冷光了", 1) -- 2620
		end -- 2620
		if self.gateTick >= g.holdTicks then -- 2620
			self:captureGateBlood() -- 2625
			self.phase = "gate-send" -- 2626
			self.phaseTick = 0 -- 2627
			self.enemies = {} -- 2629
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2630
		end -- 2630
		return -- 2632
	end -- 2632
	if self.phase == "gate-send" then -- 2632
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2635
		if near and input.interact.pressed then -- 2635
			self:commitRoute() -- 2639
			self:swapToChild(g.doorX + 30) -- 2640
			self.phase = self.run.source == "debug" and "gate-count" or "gate-farewell" -- 2641
			self.phaseTick = 0 -- 2642
			self.countTick = 0 -- 2643
			self.countArmed = false -- 2645
			self.countPrevMove = input.moveX -- 2646
			self:flashSet("门开了 · 送她出去", 1.8) -- 2647
		end -- 2647
		return -- 2649
	end -- 2649
	if self.phase == "gate-farewell" then -- 2649
		self.phaseTick = self.phaseTick + 1 -- 2652
		self.countPrevMove = input.moveX -- 2653
		if self.phaseTick >= ____exports.GATE_FAREWELL_TICKS then -- 2653
			self.phase = "gate-count" -- 2655
			self.phaseTick = 0 -- 2656
			self.countTick = 0 -- 2657
			self.countArmed = false -- 2658
		end -- 2658
		return -- 2660
	end -- 2660
	if self.phase == "gate-count" then -- 2660
		self.countTick = self.countTick + 1 -- 2663
		if self.countTick == 360 then -- 2663
			self:flashSet("门关上", 0.9) -- 2665
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2665
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2667
			if self.storyRoute == "soldier" then -- 2667
				self.phase = "gate-wait" -- 2673
				self.phaseTick = 0 -- 2674
				self.knocks = 1 -- 2675
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2676
				self.handArmed = not input.interact.held and not self.intentGateReunionHold -- 2678
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2679
			else -- 2679
				self:flashSet("数到二十", 2.2) -- 2681
			end -- 2681
		end -- 2681
		local prevMove = self.countPrevMove -- 2686
		self.countPrevMove = input.moveX -- 2687
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2687
			if prevMove <= 0 and input.moveX > 0 then -- 2687
				self.countArmed = true -- 2690
			end -- 2690
			if self.countArmed and input.moveX > 0 then -- 2690
				self.phase = "gate-walk" -- 2693
				self.phaseTick = 0 -- 2694
				self:flashSet("她迈出第一步", 1.4) -- 2695
				self:emit("storyExit", { -- 2696
					route = "child", -- 2696
					via = "walk", -- 2696
					countTick = self.countTick, -- 2696
					hp = self.hp, -- 2696
					maxHp = self.maxHp -- 2696
				}) -- 2696
			end -- 2696
		end -- 2696
		return -- 2699
	end -- 2699
	if self.phase == "gate-wait" then -- 2699
		self.phaseTick = self.phaseTick + 1 -- 2703
		if self.phaseTick == 12 then -- 2703
			self.knocks = 2 -- 2705
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2706
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2707
		end -- 2707
		local held = input.interact.held or self.intentGateReunionHold -- 2709
		if not held then -- 2709
			if self.handTicks > 0 then -- 2709
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2712
			end -- 2712
			self.handTicks = 0 -- 2714
			self.handArmed = true -- 2715
			return -- 2716
		end -- 2716
		if self.handArmed then -- 2716
			self.handTicks = self.handTicks + 1 -- 2719
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2719
				self.intentGateReunionHold = false -- 2721
				self.phase = "gate-hand" -- 2722
				self.phaseTick = 0 -- 2723
				self.handDone = true -- 2724
				self.tied = true -- 2725
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2726
				if not self.lineSaid then -- 2726
					self.lineSaid = true -- 2728
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2729
				end -- 2729
				self:flashSet("我们走吧。", 3) -- 2731
			end -- 2731
		end -- 2731
		return -- 2734
	end -- 2734
	if self.phase == "gate-hand" then -- 2734
		self.phaseTick = self.phaseTick + 1 -- 2738
		if self.phaseTick == 30 then -- 2738
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2740
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2740
			self:emit("storyExit", { -- 2742
				route = "soldier", -- 2742
				via = "hand", -- 2742
				handTicks = self.handTicks, -- 2742
				hp = self.hp, -- 2742
				maxHp = self.maxHp -- 2742
			}) -- 2742
			self:requestRoom("gatepath", "牵手同行") -- 2743
		end -- 2743
		return -- 2745
	end -- 2745
	if self.phase == "gate-walk" then -- 2745
		if self.player.x >= g.exitX then -- 2745
			self:requestRoom("outside", "走出城门") -- 2750
			self:flashSet("出城门 · 城外", 1.4) -- 2751
		end -- 2751
	end -- 2751
end -- 2552
function Play.prototype.captureGateBlood(self) -- 2760
	self.hpAtGate = self.hp -- 2761
	self.maxHpAtGate = self.maxHp -- 2762
end -- 2760
function Play.prototype.commitRoute(self) -- 2769
	if self.storySettled then -- 2769
		return -- 2771
	end -- 2771
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2773
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2774
	self.hpAtGate = hp -- 2775
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2776
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2777
	self.storySettled = true -- 2778
	self.sessionDirty = true -- 2779
	self:emit("storyRouteLocked", { -- 2780
		route = self.storyRoute, -- 2781
		hp = self.hp, -- 2781
		maxHp = self.maxHp, -- 2781
		hpAtGate = self.hpAtGate, -- 2782
		maxHpAtGate = self.maxHpAtGate -- 2782
	}) -- 2782
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2784
end -- 2769
function Play.prototype.syncStory(self) -- 2788
	local s = self.run.story -- 2789
	if s == nil then -- 2789
		return -- 2791
	end -- 2791
	s.hp = self.hp -- 2793
	s.maxHp = self.maxHp -- 2794
	s.route = self.storyRoute -- 2795
	s.settled = self.storySettled -- 2796
	s.hpAtGate = self.hpAtGate -- 2797
	s.maxHpAtGate = self.maxHpAtGate -- 2798
	s.handDone = self.handDone -- 2799
	s.lineSaid = self.lineSaid -- 2800
	s.tied = self.tied -- 2801
	s.carry = self.carryOn -- 2802
	s.museumReturn = self.museumReturn -- 2803
	s.escortDone = self.escortDone -- 2804
	s.craftedWeapon = self.run.story.craftedWeapon -- 2805
	s.equippedWeapon = self.equippedWeapon -- 2806
	s.ending = self.run.story.ending -- 2807
	if self.room.key == "gate" then -- 2807
		s.phase = self.phase -- 2809
		s.countTick = self.countTick -- 2810
		s.phaseTick = self.phaseTick -- 2811
		s.handTicks = self.handTicks -- 2812
	end -- 2812
	if self.room.key == "prologue" then -- 2812
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2812
			s.phase = self.phase -- 2817
			s.phaseTick = self.phaseTick -- 2818
		end -- 2818
	end -- 2818
	if self.room.key == "tower" then -- 2818
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2818
			s.phase = self.phase -- 2824
			s.phaseTick = self.phaseTick -- 2825
		end -- 2825
	end -- 2825
end -- 2788
function Play.prototype.stepGatePath(self) -- 2831
	local ____temp_95 -- 2832
	if self.room.story == nil then -- 2832
		____temp_95 = nil -- 2832
	else -- 2832
		____temp_95 = self.room.story.gatepath -- 2832
	end -- 2832
	local gp = ____temp_95 -- 2832
	if self.phase == "gatepath-start" then -- 2832
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2832
			self.carryOn = true -- 2835
			self.phase = "gatepath-carry" -- 2836
			self.phaseTick = 0 -- 2837
			self.pathDone = true -- 2838
			self.escortDone = false -- 2839
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2840
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2841
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2842
		end -- 2842
		return -- 2844
	end -- 2844
	if self.phase == "gatepath-carry" then -- 2844
		self.phaseTick = self.phaseTick + 1 -- 2847
		if self.phaseTick == 20 then -- 2847
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2849
		end -- 2849
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2849
			self:requestRoom(gp.next, "背负进首战") -- 2852
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2853
		end -- 2853
	end -- 2853
end -- 2831
function Play.prototype.carryPose(self) -- 2862
	local p = self.player -- 2863
	local a = self.partner -- 2864
	a.alive = true -- 2865
	a.x = p.x - p.facing * 12 -- 2866
	a.y = p.y + 26 -- 2867
	a.depth = p.depth -- 2868
	a.vx = p.vx -- 2869
	a.vy = 0 -- 2870
	a.onGround = true -- 2871
	a.crouch = false -- 2872
	a.h = CHILD_CROUCH_H -- 2873
	a.facing = p.facing -- 2874
end -- 2862
function Play.prototype.stepMuseum(self, dt, input) -- 2882
	self.partner.alive = false -- 2883
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2884
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2887
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 2888
	local intentTarget = self.pendingMuseumIntentTarget -- 2889
	self.pendingMuseumIntentTarget = "" -- 2890
	local interactHit = input.interact.pressed or intentTarget ~= "" -- 2891
	if self.phase == "museum-cabinet" then -- 2891
		if atCase and interactHit or intentTarget == "cabinet" then -- 2891
			self.phase = "museum-hall" -- 2894
			self.phaseTick = 0 -- 2895
			if self:canPersistProgress() then -- 2895
				self.archive.museumPhase = "hall_walk" -- 2897
				self.archiveDirty = true -- 2898
			end -- 2898
			self:emit( -- 2900
				"museumStep", -- 2900
				{ -- 2900
					step = "cabinet", -- 2900
					x = self.ox + mu.cabinetX, -- 2900
					persisted = self:canPersistProgress() -- 2900
				} -- 2900
			) -- 2900
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2901
		end -- 2901
		return -- 2903
	end -- 2903
	if self.phase == "museum-hall" then -- 2903
		if intentTarget == "lamp_direct" and nearLamp then -- 2903
			self:emit( -- 2907
				"museumStep", -- 2907
				{ -- 2907
					step = "hall", -- 2907
					x = self.ox + mu.hallX, -- 2907
					persisted = self:canPersistProgress() -- 2907
				} -- 2907
			) -- 2907
			self.phase = "museum-return" -- 2908
			self.phaseTick = 0 -- 2909
			if self:canPersistProgress() then -- 2909
				self.archive.museumPhase = "return_cabinet" -- 2911
				self.archiveDirty = true -- 2912
			end -- 2912
			self:emit( -- 2914
				"museumStep", -- 2914
				{ -- 2914
					step = "lamp", -- 2914
					x = self.ox + mu.lampX, -- 2914
					persisted = self:canPersistProgress() -- 2914
				} -- 2914
			) -- 2914
			self:flashSet("灯 · 转向西窗", 1.8) -- 2915
			return -- 2916
		end -- 2916
		if self.player.x >= self.ox + mu.hallX and interactHit then -- 2916
			self.phase = "museum-lamp" -- 2919
			self.phaseTick = 0 -- 2920
			if self:canPersistProgress() then -- 2920
				self.archive.museumPhase = "lamp_turn" -- 2922
				self.archiveDirty = true -- 2923
			end -- 2923
			self:emit( -- 2925
				"museumStep", -- 2925
				{ -- 2925
					step = "hall", -- 2925
					x = self.ox + mu.hallX, -- 2925
					persisted = self:canPersistProgress() -- 2925
				} -- 2925
			) -- 2925
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2926
		end -- 2926
		return -- 2928
	end -- 2928
	if self.phase == "museum-lamp" then -- 2928
		if nearLamp and interactHit then -- 2928
			self.phase = "museum-return" -- 2932
			self.phaseTick = 0 -- 2933
			if self:canPersistProgress() then -- 2933
				self.archive.museumPhase = "return_cabinet" -- 2935
				self.archiveDirty = true -- 2936
			end -- 2936
			self:emit( -- 2938
				"museumStep", -- 2938
				{ -- 2938
					step = "lamp", -- 2938
					x = self.ox + mu.lampX, -- 2938
					persisted = self:canPersistProgress() -- 2938
				} -- 2938
			) -- 2938
			self:flashSet("灯 · 转向西窗", 1.8) -- 2939
		end -- 2939
		return -- 2941
	end -- 2941
	if self.phase == "museum-return" then -- 2941
		if atCase and interactHit or intentTarget == "return_cabinet" then -- 2941
			self.phase = "museum-knock" -- 2945
			self.phaseTick = 0 -- 2946
			self:emit( -- 2947
				"museumStep", -- 2947
				{ -- 2947
					step = "knock", -- 2947
					count = 1, -- 2947
					x = self.ox + mu.cabinetX, -- 2947
					persisted = self:canPersistProgress() -- 2947
				} -- 2947
			) -- 2947
			self:flashSet("回柜边 · 第一下", 0.8) -- 2948
		end -- 2948
		return -- 2950
	end -- 2950
	if self.phase == "museum-knock" then -- 2950
		self.phaseTick = self.phaseTick + 1 -- 2953
		if self.phaseTick == 8 then -- 2953
			self:emit( -- 2955
				"museumStep", -- 2955
				{ -- 2955
					step = "knock", -- 2955
					count = 2, -- 2955
					x = self.ox + mu.cabinetX, -- 2955
					persisted = self:canPersistProgress() -- 2955
				} -- 2955
			) -- 2955
			self:flashSet("回柜边 · 第二下", 0.8) -- 2956
		elseif self.phaseTick >= 36 then -- 2956
			self.phase = "museum-done" -- 2958
			self.phaseTick = 0 -- 2959
			if self:canPersistProgress() then -- 2959
				self.archive.museumSeen = true -- 2961
				self.archive.museumPhase = "done" -- 2962
				self.archiveDirty = true -- 2963
			end -- 2963
			self:emit( -- 2965
				"museumDone", -- 2965
				{ -- 2965
					steps = 4, -- 2965
					museumSeen = self.archive.museumSeen, -- 2965
					persisted = self:canPersistProgress() -- 2965
				} -- 2965
			) -- 2965
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2966
			self:log("博物馆 · 回柜边") -- 2967
		end -- 2967
		return -- 2969
	end -- 2969
	if interactHit then -- 2969
		self.museumReturn = true -- 2972
		self:requestRoom("prologue", "回柜边") -- 2973
	end -- 2973
end -- 2882
function Play.prototype.openTowerDoor(self) -- 2977
	self.towerDoorOpen = true -- 2978
	do -- 2978
		local i = 0 -- 2979
		while i < #self.boxes do -- 2979
			if self.boxes[i + 1].id == "tower_door" then -- 2979
				self.boxes[i + 1].hidden = true -- 2981
			end -- 2981
			i = i + 1 -- 2979
		end -- 2979
	end -- 2979
	self.run.story.segments.tower_door = true -- 2984
end -- 2977
function Play.prototype.stepTower(self, dt, input) -- 2987
	local ____temp_96 -- 2988
	if self.room.story == nil then -- 2988
		____temp_96 = nil -- 2988
	else -- 2988
		____temp_96 = self.room.story.tower -- 2988
	end -- 2988
	local t = ____temp_96 -- 2988
	if t == nil then -- 2988
		return -- 2990
	end -- 2990
	if self.storyRoute == "soldier" and self.partner.alive then -- 2990
		local targetX = math.max(self.ox + 408, self.player.x - 28) -- 2994
		local gap = targetX - self.partner.x -- 2995
		if math.abs(gap) > 2 then -- 2995
			local dir = gap > 0 and 1 or -1 -- 2997
			local stepDist = math.min( -- 2998
				math.abs(gap), -- 2998
				SOLDIER_SPEED * dt -- 2998
			) -- 2998
			self.partner.facing = dir -- 2999
			self.partner.vx = dir * SOLDIER_SPEED -- 3000
			local ____self_partner_97, ____x_98 = self.partner, "x" -- 3000
			____self_partner_97[____x_98] = ____self_partner_97[____x_98] + dir * stepDist -- 3001
		else -- 3001
			self.partner.vx = 0 -- 3003
			self.partner.facing = 1 -- 3004
		end -- 3004
	end -- 3004
	if self.phase == "tower-wait" then -- 3004
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 3008
		if near and input.interact.pressed then -- 3008
			self.phase = "tower-knock" -- 3010
			self.phaseTick = 0 -- 3011
			self.knocks = 1 -- 3012
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 3013
			self:flashSet("叩两下 · 第一声", 0.6) -- 3014
		end -- 3014
		return -- 3016
	end -- 3016
	if self.phase == "tower-knock" then -- 3016
		self.phaseTick = self.phaseTick + 1 -- 3019
		if self.phaseTick == 12 then -- 3019
			self.knocks = 2 -- 3021
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 3022
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 3023
		elseif self.phaseTick >= t.knockTicks then -- 3023
			self:openTowerDoor() -- 3025
			self.phase = "tower-enter" -- 3026
			self.phaseTick = 0 -- 3027
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 3028
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 3029
		end -- 3029
		return -- 3031
	end -- 3031
	if self.phase == "tower-enter" then -- 3031
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 3031
			self.phase = "tower-desk" -- 3035
			self.phaseTick = 0 -- 3036
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 3037
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 3038
		end -- 3038
		return -- 3040
	end -- 3040
	if self.phase == "tower-desk" then -- 3040
		local deskX = self.ox + 605 -- 3043
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 3044
		if not near or not input.interact.held then -- 3044
			self.deskHold = 0 -- 3046
			return -- 3047
		end -- 3047
		self.deskHold = self.deskHold + 1 -- 3049
		if self.deskHold == 12 then -- 3049
			self:flashSet("针套 · 放在桌上", 1) -- 3051
		elseif self.deskHold == 24 then -- 3051
			self:flashSet("指南针 · 压住纸条", 1) -- 3053
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 3053
			self.towerHanded = true -- 3055
			self.deskHold = 0 -- 3056
			self.run.story.segments.tower_handover = true -- 3057
			self.phase = "tower-given" -- 3058
			self.phaseTick = 0 -- 3059
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 3060
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 3065
		end -- 3065
		return -- 3067
	end -- 3067
	if self.phase == "tower-given" then -- 3067
		local soldier = self.storyRoute == "soldier" -- 3072
		self.phaseTick = self.phaseTick + 1 -- 3073
		if self.phaseTick == 60 then -- 3073
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 3075
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 3076
		elseif self.phaseTick == 120 then -- 3076
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 3078
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 3078
			self.phase = "tower-end" -- 3080
			self.phaseTick = 0 -- 3081
			self.towerEndMustRelease = input.interact.held or input.retry.held -- 3082
			if not self.run.finished then -- 3082
				self.run.finished = true -- 3084
				local ending = soldier and "reunion" or "lamp" -- 3085
				self.run.story.ending = ending -- 3086
				local ____soldier_99 -- 3089
				if soldier then -- 3089
					____soldier_99 = self.run.story.segments.escort5 == true -- 3090
				else -- 3090
					____soldier_99 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 3091
				end -- 3091
				local played = ____soldier_99 -- 3089
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 3092
				if official then -- 3092
					if soldier then -- 3092
						self.run.archive.soldierCleared = true -- 3096
					else -- 3096
						self.run.archive.childCleared = true -- 3098
					end -- 3098
					self.archiveDirty = true -- 3100
				end -- 3100
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 3102
				self:emit("endingReached", { -- 3103
					route = soldier and "soldier" or "child", -- 3104
					ending = ending, -- 3105
					official = official, -- 3106
					source = self.run.source, -- 3107
					lines = {self.endingLines[1], self.endingLines[2]}, -- 3108
					childCleared = self.run.archive.childCleared, -- 3109
					soldierCleared = self.run.archive.soldierCleared, -- 3110
					artifactOwned = self.run.archive.artifactOwned, -- 3111
					equipped = self.equippedWeapon -- 3112
				}) -- 3112
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 3114
			end -- 3114
		end -- 3114
		return -- 3117
	end -- 3117
	self.phaseTick = self.phaseTick + 1 -- 3119
	local held = input.interact.held or input.retry.held -- 3120
	if self.towerEndMustRelease then -- 3120
		if not held then -- 3120
			self.towerEndMustRelease = false -- 3123
		end -- 3123
		return -- 3125
	end -- 3125
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 3127
	if self.phaseTick < waitTicks then -- 3127
		if input.interact.pressed or input.retry.pressed then -- 3127
			self.towerEndMustRelease = held -- 3130
		end -- 3130
		return -- 3132
	end -- 3132
	if input.interact.pressed or input.retry.pressed then -- 3132
		self.restartStory = true -- 3136
		self:requestRoom("prologue", "片尾再玩") -- 3137
		self:flashSet("回到序章", 1.4) -- 3138
	end -- 3138
end -- 2987
function Play.prototype.stepChase(self, dt, input) -- 3143
	if self.caughtT > 0 then -- 3143
		self.caughtT = self.caughtT - dt -- 3145
		if self.caughtT <= 0 then -- 3145
			self:recoverFromCaught() -- 3147
		end -- 3147
		return -- 3149
	end -- 3149
	if self.room.key == "village" then -- 3149
		self:stepScavChase() -- 3152
	elseif self.room.key == "forest" then -- 3152
		self:stepForestRoute() -- 3154
		self:stepDog(dt) -- 3155
		if self.player.x >= self.ox + 1450 then -- 3155
			self:requestRoom("tower", "到林缘北塔") -- 3158
			self:flashSet("林缘 · 北塔", 1.4) -- 3159
		end -- 3159
	end -- 3159
end -- 3143
function Play.prototype.stepScavChase(self) -- 3165
	local s = self.room.scavenger -- 3166
	if s == nil then -- 3166
		return -- 3168
	end -- 3168
	local p = self.player -- 3170
	if self.passed and p.x > self.ox + 440 then -- 3170
		if self.scavChase then -- 3170
			self.scavChase = false -- 3174
			self.scavState = "back" -- 3175
			self.scavT = 0 -- 3176
		end -- 3176
		return -- 3178
	end -- 3178
	local dx = p.x - self.scavX -- 3180
	local dist = math.abs(dx) -- 3181
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 3182
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 3183
	if not self.scavChase then -- 3183
		if visible then -- 3183
			self.scavSee = self.scavSee + 1 -- 3186
			if self.scavSee >= 24 then -- 3186
				self.scavChase = true -- 3188
				self.scavState = "chase" -- 3189
				self.scavTargetX = p.x -- 3190
				self:flashSet("他看见你了", 1.2) -- 3191
			end -- 3191
		else -- 3191
			self.scavSee = 0 -- 3194
		end -- 3194
		return -- 3196
	end -- 3196
	if hidden then -- 3196
		self.scavSee = 0 -- 3200
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 3201
		self.scavT = self.scavT - 1 -- 3202
		if self.scavT <= 0 then -- 3202
			self.scavChase = false -- 3204
			self.scavState = "patrol" -- 3205
			self:flashSet("他失去了目标", 1) -- 3206
		end -- 3206
		return -- 3208
	end -- 3208
	local dir = p.x > self.scavX and 1 or -1 -- 3211
	self.scavX = self.scavX + dir * 96 / 60 -- 3212
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 3212
		self:caught() -- 3214
		return -- 3215
	end -- 3215
end -- 3165
function Play.prototype.stepDog(self, dt) -- 3220
	local ____temp_100 -- 3221
	if self.room.story == nil then -- 3221
		____temp_100 = nil -- 3221
	else -- 3221
		____temp_100 = self.room.story.dog -- 3221
	end -- 3221
	local dog = ____temp_100 -- 3221
	if dog == nil then -- 3221
		return -- 3223
	end -- 3223
	local p = self.player -- 3225
	local ox = self.ox -- 3226
	local dist = math.abs(p.x - self.dogX) -- 3227
	local inBurrowCover = p.crouch and p.x >= ox + 300 and p.x <= ox + 460 -- 3228
	local inBrushCover = p.crouch and (p.x >= ox + 700 and p.x <= ox + 790 or p.x >= ox + 1150 and p.x <= ox + 1240) -- 3229
	local sheltered = inBurrowCover or inBrushCover -- 3233
	local inDitchSprint = not p.crouch and self.forestPath == "ditch" and p.x >= ox + 700 and p.x <= ox + 1140 -- 3234
	local effectiveRange = inDitchSprint and dog.range * 1.25 or dog.range -- 3235
	local earNeedTicks = inDitchSprint and 12 or 18 -- 3236
	if self.dogState == "patrol" then -- 3236
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 3238
		if self.dogX < dog.x0 then -- 3238
			self.dogX = dog.x0 -- 3240
			self.dogDir = 1 -- 3241
		elseif self.dogX > dog.x1 then -- 3241
			self.dogX = dog.x1 -- 3243
			self.dogDir = -1 -- 3244
		end -- 3244
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 3246
		local twigOffsets = {235, 455, 865, 1115} -- 3247
		local nearTwig = false -- 3248
		local ti = 0 -- 3249
		do -- 3249
			ti = 0 -- 3250
			while ti < #twigOffsets do -- 3250
				if math.abs(p.x - (ox + twigOffsets[ti + 1])) <= 18 and p.y <= 8 then -- 3250
					nearTwig = true -- 3252
					break -- 3253
				end -- 3253
				ti = ti + 1 -- 3250
			end -- 3250
		end -- 3250
		local twigRange = nearTwig and math.max(effectiveRange, 400) or effectiveRange -- 3256
		if not sheltered and not p.crouch and moving and dist < twigRange then -- 3256
			self.dogState = "ear" -- 3258
			self.dogT = nearTwig and math.min(earNeedTicks, 12) or earNeedTicks -- 3259
			self.dogTargetX = p.x -- 3260
			self:flashSet(inDitchSprint and "旧渠枯枝响 · 狗立刻转耳" or (nearTwig and "踩断枯枝 · 狗立刻转耳" or "狗转耳朵"), 0.8) -- 3261
		end -- 3261
		return -- 3263
	end -- 3263
	if self.dogState == "ear" then -- 3263
		if sheltered then -- 3263
			self.dogState = "sniff" -- 3267
			self.dogT = 45 -- 3268
			self:flashSet("钻进遮蔽 · 狗顿住了", 0.9) -- 3269
			return -- 3270
		end -- 3270
		self.dogT = self.dogT - 1 -- 3272
		if self.dogT <= 0 then -- 3272
			self.dogState = "chase" -- 3274
			self.dogTargetX = p.x -- 3275
			self:flashSet("狗追来了", 1.4) -- 3276
		end -- 3276
		return -- 3278
	end -- 3278
	if self.dogState == "chase" then -- 3278
		local dir = p.x > self.dogX and 1 or -1 -- 3281
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 3282
		if not sheltered and math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 3282
			self:caught() -- 3284
			self.dogState = "sniff" -- 3285
			self.dogT = 60 -- 3286
		elseif dist > effectiveRange * 1.5 or sheltered then -- 3286
			self.dogState = "sniff" -- 3288
			self.dogT = 60 -- 3289
			self:flashSet(inBurrowCover and "树根窄洞遮住身形 · 狗停下了" or "狗停下了", 0.9) -- 3290
		end -- 3290
		return -- 3292
	end -- 3292
	if self.dogState == "sniff" then -- 3292
		self.dogT = self.dogT - 1 -- 3295
		if self.dogT <= 0 then -- 3295
			self.dogState = "back" -- 3297
		end -- 3297
		return -- 3299
	end -- 3299
	local dir = dog.x0 > self.dogX and 1 or -1 -- 3302
	self.dogX = self.dogX + dir * dog.speed * dt -- 3303
	if math.abs(self.dogX - dog.x0) < 2 then -- 3303
		self.dogX = dog.x0 -- 3305
		self.dogState = "patrol" -- 3306
	end -- 3306
end -- 3220
function Play.prototype.stepForestRoute(self) -- 3311
	local p = self.player -- 3312
	local ox = self.ox -- 3313
	if self.forestPath == "" then -- 3313
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 3313
			self.forestPath = "burrow" -- 3316
			self.run.story.segments.forest_burrow = true -- 3317
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 3318
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 3319
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 3319
			self.forestPath = "ditch" -- 3321
			self.run.story.segments.forest_ditch = true -- 3322
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 3323
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 3324
		end -- 3324
	end -- 3324
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 3324
		self.waterSeen = true -- 3328
		self.run.story.segments.water_lantern = true -- 3329
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 3330
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 3331
	end -- 3331
end -- 3311
function Play.prototype.caught(self) -- 3335
	self.caughtT = 1 -- 3336
	self:flashSet("被抓 · 回到安全点", 1.6) -- 3337
end -- 3335
function Play.prototype.recoverFromCaught(self) -- 3341
	local p = self.player -- 3342
	p.x = self.ox + 140 -- 3343
	p.y = 0 -- 3344
	p.vy = 0 -- 3345
	p.vx = 0 -- 3346
	p.onGround = true -- 3347
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3347
		self.scavX = self.room.scavenger.x0 -- 3349
		self.scavState = "patrol" -- 3350
		self.scavSee = 0 -- 3351
		self.scavChase = false -- 3352
		self.scavT = 0 -- 3353
	end -- 3353
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3353
		self.dogX = self.room.story.dog.x0 -- 3356
		self.dogState = "patrol" -- 3357
		self.dogT = 0 -- 3358
	end -- 3358
	self.cam.x = p.x -- 3360
	self.cam.y = p.y + CAM_LOOK_UP -- 3361
	self:flashSet("回到安全点", 1.2) -- 3362
end -- 3341
function Play.prototype.updateGate(self) -- 3366
	if self.room.key ~= "checkpoint" then -- 3366
		self.gateOpen = false -- 3368
		return -- 3369
	end -- 3369
	local function inZone(x) -- 3371
		return x >= self.ox + 792 and x <= self.ox + 928 -- 3371
	end -- 3371
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 3372
end -- 3366
function Play.prototype.addItem(self, kind) -- 3378
	local inv = self.run.inventory -- 3379
	if kind == "shield" then -- 3379
		if inv.shield >= TOOL_CAP then -- 3379
			return false -- 3382
		end -- 3382
		inv.shield = inv.shield + 1 -- 3384
		return true -- 3385
	end -- 3385
	if kind == "wedge" then -- 3385
		if inv.wedge >= CONSUMABLE_CAP then -- 3385
			return false -- 3389
		end -- 3389
		inv.wedge = inv.wedge + 1 -- 3391
		return true -- 3392
	end -- 3392
	if kind == "ammo" then -- 3392
		if inv.ammo >= CONSUMABLE_CAP then -- 3392
			return false -- 3396
		end -- 3396
		inv.ammo = inv.ammo + 1 -- 3398
		return true -- 3399
	end -- 3399
	if kind == "scrap" then -- 3399
		inv.scrap = inv.scrap + 1 -- 3403
		return true -- 3404
	end -- 3404
	if kind == "wood" then -- 3404
		inv.wood = inv.wood + 1 -- 3407
		return true -- 3408
	end -- 3408
	if kind == "bell" then -- 3408
		inv.bell = inv.bell + 1 -- 3411
		return true -- 3412
	end -- 3412
	if kind == "pass" then -- 3412
		inv.pass = inv.pass + 1 -- 3415
		return true -- 3416
	end -- 3416
	if kind == "quickbelt" then -- 3416
		inv.quickbelt = inv.quickbelt + 1 -- 3419
		return true -- 3420
	end -- 3420
	return false -- 3422
end -- 3378
function Play.prototype.findBox(self, id) -- 3425
	local i = 0 -- 3426
	do -- 3426
		i = 0 -- 3427
		while i < #self.boxes do -- 3427
			if self.boxes[i + 1].id == id then -- 3427
				return self.boxes[i + 1] -- 3429
			end -- 3429
			i = i + 1 -- 3427
		end -- 3427
	end -- 3427
	return nil -- 3432
end -- 3425
function Play.prototype.findWedgeTarget(self) -- 3436
	local best = nil -- 3437
	local bestD = 0 -- 3438
	local i = 0 -- 3439
	do -- 3439
		i = 0 -- 3440
		while i < #self.boxes do -- 3440
			do -- 3440
				local b = self.boxes[i + 1] -- 3441
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3441
					goto __continue526 -- 3443
				end -- 3443
				if not self:nearBox(b, 26) then -- 3443
					goto __continue526 -- 3446
				end -- 3446
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3448
				if best == nil or d < bestD then -- 3448
					best = b -- 3450
					bestD = d -- 3451
				end -- 3451
			end -- 3451
			::__continue526:: -- 3451
			i = i + 1 -- 3440
		end -- 3440
	end -- 3440
	return best -- 3454
end -- 3436
function Play.prototype.stepCraft(self, input) -- 3462
	local inv = self.run.inventory -- 3463
	local required = math.max( -- 3464
		6, -- 3464
		CRAFT_TICKS - 6 * self:talentRank("salvage") -- 3464
	) -- 3464
	if self.craftT > 0 then -- 3464
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3464
			self.craftT = 0 -- 3468
			self:flashSet("制作中断", 0.8) -- 3469
			return true -- 3470
		end -- 3470
		self.craftT = self.craftT + 1 -- 3472
		if self.craftT >= required then -- 3472
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3472
				inv.scrap = inv.scrap - 1 -- 3475
				inv.wedge = inv.wedge + 1 -- 3476
				self:flashSet("制得木楔", 1.2) -- 3477
				self:log("制木楔") -- 3478
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3479
			end -- 3479
			self.craftT = 0 -- 3481
		end -- 3481
		return true -- 3483
	end -- 3483
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3483
		self.craftT = 1 -- 3486
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3487
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3488
		return true -- 3489
	end -- 3489
	return false -- 3491
end -- 3462
function Play.prototype.nearBox(self, b, reach) -- 3494
	local p = self.player -- 3495
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3496
end -- 3494
function Play.prototype.findInteract(self) -- 3502
	local p = self.player -- 3503
	local best = nil -- 3504
	local bestD = 1000000000 -- 3505
	local i = 0 -- 3506
	do -- 3506
		i = 0 -- 3507
		while i < #self.boxes do -- 3507
			do -- 3507
				local b = self.boxes[i + 1] -- 3508
				if b.interact == nil or b.broken == true then -- 3508
					goto __continue539 -- 3510
				end -- 3510
				if not self:nearBox(b, b.interact.reach or 27) then -- 3510
					goto __continue539 -- 3513
				end -- 3513
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3515
				if d < bestD then -- 3515
					bestD = d -- 3517
					best = b -- 3518
				end -- 3518
			end -- 3518
			::__continue539:: -- 3518
			i = i + 1 -- 3507
		end -- 3507
	end -- 3507
	return best -- 3521
end -- 3502
function Play.prototype.stepCampaign(self, dt, input) -- 3525
	local wr = self.room -- 3526
	local p = self.player -- 3527
	if self.reloadT > 0 then -- 3527
		self.reloadT = self.reloadT - 1 -- 3529
	end -- 3529
	if self.bracedShield ~= nil then -- 3529
		self.bracedShield.x = p.x + p.facing * 26 -- 3533
		self.bracedShield.y = p.y -- 3534
		local shBox = __TS__ArrayFind( -- 3535
			self.boxes, -- 3535
			function(____, b) return b.id == "braced_shield" end -- 3535
		) -- 3535
		if shBox ~= nil then -- 3535
			shBox.x0 = self.bracedShield.x - 15 -- 3537
			shBox.x1 = self.bracedShield.x + 15 -- 3538
			shBox.y0 = self.bracedShield.y -- 3539
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3540
		end -- 3540
	end -- 3540
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3540
		self.run.route = "drygoods" -- 3546
		self.run.joined = false -- 3547
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3548
		self:log("转布行线") -- 3549
	end -- 3549
	if wr.key == "escort3" then -- 3549
		local nearBench = p.x >= wr.minX + 472 and p.x <= wr.minX + 710 and p.y < 60 -- 3554
		if nearBench and input.interact.pressed then -- 3554
			self:openCraftBench() -- 3556
			return -- 3557
		end -- 3557
		local ____temp_103 = self.storyRoute == "soldier" -- 3559
		if ____temp_103 then -- 3559
			local ____opt_101 = self.run.story.talents -- 3559
			____temp_103 = (____opt_101 and ____opt_101.deferred) == true -- 3559
		end -- 3559
		if ____temp_103 and p.x >= wr.minX + 940 then -- 3559
			self:triggerDeferredEscort3Draft() -- 3560
		end -- 3560
	end -- 3560
	local i = 0 -- 3564
	do -- 3564
		i = 0 -- 3565
		while i < #self.pickups do -- 3565
			do -- 3565
				local pk = self.pickups[i + 1] -- 3566
				if self.run.taken[pk.id] == true then -- 3566
					goto __continue553 -- 3568
				end -- 3568
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3570
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3571
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3571
					if not self:addItem(pk.kind) then -- 3571
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3575
						self:log("满包拒绝 " .. pk.kind) -- 3576
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3577
						goto __continue553 -- 3578
					end -- 3578
					self.run.taken[pk.id] = true -- 3580
					self:flashSet("拾取 " .. pk.label, 1) -- 3581
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3582
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3583
				end -- 3583
			end -- 3583
			::__continue553:: -- 3583
			i = i + 1 -- 3565
		end -- 3565
	end -- 3565
	self.calmConsumed = false -- 3587
	local ____temp_109 = self.partner.alive and self.run.joined -- 3588
	if ____temp_109 then -- 3588
		local ____opt_104 = self.room.campaign -- 3588
		local ____temp_108 = (____opt_104 and ____opt_104.chapter) == "S" -- 3589
		if not ____temp_108 then -- 3589
			local ____opt_106 = self.room.campaign -- 3589
			____temp_108 = (____opt_106 and ____opt_106.chapter) == "C" -- 3589
		end -- 3589
		____temp_109 = ____temp_108 -- 3588
	end -- 3588
	if ____temp_109 and (self.escort.fear > 0 or self.escort.state == "frozen" or self.escort.state == "calming") then -- 3588
		local dist = inReachDepth(p.depth, self.partner.depth) and math.abs(p.x - self.partner.x) or 1000000000 -- 3591
		local hadK1 = self.escort.knock1 -- 3592
		local hadK2 = self.escort.knock2 -- 3593
		self.calmConsumed = self.escort:update( -- 3594
			input, -- 3594
			p.x, -- 3594
			p.facing, -- 3594
			self.partner.x, -- 3594
			dist -- 3594
		) -- 3594
		if not hadK1 and self.escort.knock1 then -- 3594
			self:emit("knock", {count = 1, x = self.partner.x, room = self.room.key}) -- 3596
		end -- 3596
		if not hadK2 and self.escort.knock2 then -- 3596
			self:emit("knock", {count = 2, x = self.partner.x, room = self.room.key}) -- 3599
		end -- 3599
		self.partner.crouch = self.escort.crouchPose -- 3601
		self.partner.h = self.partner.crouch and CHILD_CROUCH_H or CHILD_H -- 3602
	end -- 3602
	if not self.calmConsumed and not self:stepCraft(input) and input.interact.pressed then -- 3602
		self:campaignInteract() -- 3605
	end -- 3605
	self:stepCampaignCart(dt, input) -- 3607
	self:stepCampaignGoal() -- 3608
	self:campaignCheckpoint() -- 3609
end -- 3525
function Play.prototype.campaignCheckpoint(self) -- 3613
	local i = 0 -- 3614
	do -- 3614
		i = 0 -- 3615
		while i < #self.room.marks do -- 3615
			do -- 3615
				local m = self.room.marks[i + 1] -- 3616
				if m.kind ~= 0 then -- 3616
					goto __continue563 -- 3618
				end -- 3618
				local dx = self.player.x - m.x -- 3620
				local dy = self.player.y - m.y -- 3621
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3621
					self.checkpoint = m.x -- 3623
					self:captureCheckpoint(m.x) -- 3624
					self:flashSet("检查点", 1) -- 3625
				end -- 3625
			end -- 3625
			::__continue563:: -- 3625
			i = i + 1 -- 3615
		end -- 3615
	end -- 3615
end -- 3613
function Play.prototype.campaignInteract(self) -- 3631
	local b = self:findInteract() -- 3632
	if b ~= nil then -- 3632
		self:useInteract(b) -- 3634
		return -- 3635
	end -- 3635
	local inv = self.run.inventory -- 3637
	if inv.wedge > 0 then -- 3637
		local w = self:findWedgeTarget() -- 3639
		if w ~= nil then -- 3639
			local ____opt_110 = w.breakable -- 3639
			local extraHp = (____opt_110 and ____opt_110.wedgeHp or 1) + self:talentRank("salvage") -- 3641
			if w.breakable ~= nil then -- 3641
				local ____w_breakable_112, ____hp_113 = w.breakable, "hp" -- 3641
				____w_breakable_112[____hp_113] = ____w_breakable_112[____hp_113] + extraHp -- 3643
			end -- 3643
			inv.wedge = inv.wedge - 1 -- 3645
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3646
			self:flashSet( -- 3648
				extraHp > 1 and ("钉木楔 · 多承" .. tostring(extraHp)) .. "次" or "钉木楔 · 多承一次", -- 3648
				1.2 -- 3648
			) -- 3648
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3649
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3650
			return -- 3651
		end -- 3651
		if self:isEscortRoom() then -- 3651
			local p = self.player -- 3654
			local wx = math.max( -- 3655
				self.room.minX + 64, -- 3655
				math.min(self.room.maxX - 64, p.x + p.facing * 32) -- 3655
			) -- 3655
			local hp = 1 + self:talentRank("salvage") -- 3656
			self.fieldWedgeSeq = self.fieldWedgeSeq + 1 -- 3657
			local wid = "field_wedge_" .. tostring(self.fieldWedgeSeq) -- 3658
			local ____self_boxes_114 = self.boxes -- 3658
			____self_boxes_114[#____self_boxes_114 + 1] = { -- 3659
				x0 = wx - 12, -- 3660
				x1 = wx + 12, -- 3661
				y0 = p.y, -- 3662
				y1 = p.y + 48, -- 3663
				depth = {min = p.depth - 20, max = p.depth + 20}, -- 3664
				label = "立起的木楔掩体", -- 3665
				id = wid, -- 3666
				breakable = {hp = hp, kind = "thin_wood", wedgeable = true} -- 3667
			} -- 3667
			inv.wedge = inv.wedge - 1 -- 3669
			self:flashSet( -- 3670
				"立木楔 · 临时挡弹" .. (hp > 1 and ("(" .. tostring(hp)) .. "击)" or ""), -- 3670
				1.2 -- 3670
			) -- 3670
			self:log("立木楔掩体") -- 3671
			self:emit("interactUsed", {kind = "wedge", x = wx}) -- 3672
			return -- 3673
		end -- 3673
	end -- 3673
	if inv.ammo > 0 and self.reloadT > 0 then -- 3673
		self.reloadT = 0 -- 3678
		self:closeReloadPuzzle() -- 3679
		inv.ammo = inv.ammo - 1 -- 3680
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3681
		self:log("用备用弹包") -- 3682
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3683
		return -- 3684
	end -- 3684
	local canBraceHere = self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 or self:isEscortRoom() -- 3686
	if inv.shield > 0 and self.bracedShield == nil and canBraceHere then -- 3686
		local p = self.player -- 3690
		local shHp = 1 + self:talentRank("salvage") -- 3691
		self.bracedShield = { -- 3692
			x = p.x + p.facing * 26, -- 3692
			y = p.y, -- 3692
			w = 30, -- 3692
			h = 64, -- 3692
			hp = shHp -- 3692
		} -- 3692
		local ____self_boxes_115 = self.boxes -- 3692
		____self_boxes_115[#____self_boxes_115 + 1] = { -- 3693
			x0 = self.bracedShield.x - 15, -- 3694
			x1 = self.bracedShield.x + 15, -- 3694
			y0 = p.y, -- 3695
			y1 = p.y + 64, -- 3695
			depth = {min = -46, max = 46}, -- 3695
			label = "架起的残盾", -- 3695
			id = "braced_shield", -- 3695
			soft = true -- 3696
		} -- 3696
		inv.shield = inv.shield - 1 -- 3698
		self:flashSet( -- 3699
			shHp > 1 and ("架残盾 · 可挡" .. tostring(shHp)) .. "发" or "架残盾 · 挡一发", -- 3699
			1.2 -- 3699
		) -- 3699
		self:log("架残盾") -- 3700
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3701
		return -- 3702
	end -- 3702
	if inv.pass > 0 and self.run.joined == false then -- 3702
		inv.pass = inv.pass - 1 -- 3705
		self.run.joined = true -- 3706
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3707
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3708
		return -- 3709
	end -- 3709
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3711
end -- 3631
function Play.prototype.useInteract(self, b) -- 3714
	local kind = b.interact == nil and "" or b.interact.kind -- 3715
	local wr = self.room -- 3716
	if kind == "open_board" then -- 3716
		b.broken = true -- 3718
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3719
		for ____, cover in ipairs(self.boxes) do -- 3720
			if cover.id == "s2_board_cover" then -- 3720
				cover.broken = false -- 3722
				cover.hidden = false -- 3723
			end -- 3723
		end -- 3723
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3726
		self.run.joined = true -- 3727
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3728
		self:log("放下窗板") -- 3729
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3730
		return -- 3731
	end -- 3731
	if kind == "lower_curtain" then -- 3731
		for ____, curtain in ipairs(self.boxes) do -- 3734
			if curtain.id == "c2_curtain" then -- 3734
				curtain.broken = false -- 3736
				curtain.hidden = false -- 3737
			end -- 3737
		end -- 3737
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3740
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3741
		self:log("放下木帘") -- 3742
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3743
		return -- 3744
	end -- 3744
	if kind == "raise_latch" then -- 3744
		if wr.key == "c2-granary" and not self.cartDocked then -- 3744
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3748
			return -- 3749
		end -- 3749
		b.broken = true -- 3751
		self.objectiveDone = true -- 3752
		if wr.key == "c1-yard" then -- 3752
			self.run.c1Latch = true -- 3755
			self.run.joined = true -- 3756
			for ____, door in ipairs(self.boxes) do -- 3757
				if door.id == "c1_door" then -- 3757
					door.broken = true -- 3759
				end -- 3759
			end -- 3759
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3762
		else -- 3762
			self.run.c2Latch = true -- 3764
			self.run.joined = true -- 3765
		end -- 3765
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3767
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3768
		self:log("抬闩") -- 3769
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3770
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3771
	end -- 3771
end -- 3714
function Play.prototype.stepCampaignCart(self, dt, input) -- 3776
	local wr = self.room -- 3777
	local c = wr.cart -- 3778
	if c.bodyW <= 0 then -- 3778
		return -- 3780
	end -- 3780
	local p = self.player -- 3782
	local handleX = self.cartAxle + c.handleOffset -- 3783
	if not self.gripping then -- 3783
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3783
			self.gripping = true -- 3787
			self:flashSet("握住车柄 · A/D 推", 1) -- 3788
		end -- 3788
		return -- 3790
	end -- 3790
	if input.interact.pressed then -- 3790
		self.gripping = false -- 3793
		self:flashSet("松手", 0.5) -- 3794
		return -- 3795
	end -- 3795
	if not self.cartDocked then -- 3795
		if input.moveX ~= 0 and not self:stuckCart() then -- 3795
			self.cartAxle = math.max( -- 3799
				c.startX, -- 3799
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3799
			) -- 3799
		end -- 3799
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3799
			self.cartExposed = true -- 3804
			local gun = nil -- 3805
			local gi = 0 -- 3806
			do -- 3806
				gi = 0 -- 3807
				while gi < #self.enemies do -- 3807
					local e = self.enemies[gi + 1] -- 3808
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3808
						gun = e -- 3810
						break -- 3811
					end -- 3811
					gi = gi + 1 -- 3807
				end -- 3807
			end -- 3807
			if gun ~= nil then -- 3807
				self:campaignEnemyFire(gun) -- 3815
			end -- 3815
		end -- 3815
		p.x = self.cartAxle + c.handleOffset -- 3818
		p.y = c.baseY -- 3819
		p.depth = c.depth or 0 -- 3820
		p.vx = 0 -- 3821
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3821
			self.cartAxle = c.endX -- 3823
			self.cartDocked = true -- 3824
			self.gripping = false -- 3825
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3826
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3827
			self:flashSet("车轮入窝", 1.2) -- 3828
			self:log("车轮入窝") -- 3829
		end -- 3829
	end -- 3829
end -- 3776
function Play.prototype.stuckCart(self) -- 3835
	local i = 0 -- 3836
	do -- 3836
		i = 0 -- 3837
		while i < #self.boxes do -- 3837
			do -- 3837
				local b = self.boxes[i + 1] -- 3838
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3838
					goto __continue606 -- 3840
				end -- 3840
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3842
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3842
					return true -- 3844
				end -- 3844
			end -- 3844
			::__continue606:: -- 3844
			i = i + 1 -- 3837
		end -- 3837
	end -- 3837
	return false -- 3847
end -- 3835
function Play.prototype.stepCampaignGoal(self) -- 3851
	local wr = self.room -- 3852
	local c = wr.campaign -- 3853
	if c == nil then -- 3853
		return -- 3855
	end -- 3855
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3855
		self.objectiveDone = true -- 3858
	end -- 3858
	if c.goal == "reach_exit" then -- 3858
		self.objectiveDone = true -- 3861
	end -- 3861
	if not self.objectiveDone then -- 3861
		return -- 3864
	end -- 3864
	local p = self.player -- 3866
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3867
	if p.x < c.exitX or not partnerOk then -- 3867
		return -- 3869
	end -- 3869
	if self.run.story.segments[wr.key] ~= true then -- 3869
		self.run.story.segments[wr.key] = true -- 3873
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3874
	end -- 3874
	if wr.key == "escort5" then -- 3874
		self.escortDone = true -- 3878
		self.run.story.escortDone = true -- 3879
	end -- 3879
	if c.next ~= nil and c.next ~= "" then -- 3879
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3882
		self:flashSet("过关 · " .. c.next, 1.2) -- 3883
	elseif wr.key == "c2-granary" and (self.run.source == "official" or self.run.source == "chapter") then -- 3883
		self:requestRoom("gate", "军粮棚出口") -- 3886
		self:flashSet("出军粮棚 · 城门", 1.4) -- 3887
	elseif not self.run.finished then -- 3887
		self.run.finished = true -- 3889
		self:flashSet( -- 3890
			"军粮棚清完 · 回城门 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3890
			2 -- 3890
		) -- 3890
		self:log("军粮棚清完 · 回城门") -- 3891
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3892
	end -- 3892
end -- 3851
function Play.prototype.stepCampaignPartner(self, dt) -- 3897
	local a = self.partner -- 3898
	local wr = self.room -- 3899
	local cp = wr.companion -- 3900
	if not a.alive then -- 3900
		return -- 3902
	end -- 3902
	local p = self.player -- 3904
	if self.craftBench.active then -- 3904
		a.vx = 0 -- 3907
		return -- 3908
	end -- 3908
	local wait = false -- 3910
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3911
	local targetDepth = p.depth -- 3912
	if self.run.joined == false then -- 3912
		wait = true -- 3914
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3915
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3916
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3916
		wait = true -- 3918
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3919
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3920
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3920
		wait = true -- 3922
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3923
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3924
	end -- 3924
	local bypass = cp and cp.groundBypass -- 3926
	if bypass ~= nil then -- 3926
		if wait and not self.cartDocked and a.x < targetX - 18 then -- 3926
			targetX = math.min( -- 3930
				targetX, -- 3930
				math.max(a.x, p.x - 52) -- 3930
			) -- 3930
		end -- 3930
		local approachesBypass = a.x >= bypass.x0 - 80 and a.x <= bypass.x1 + 80 and math.max(a.x, targetX) >= bypass.x0 - a.w * 0.5 and math.min(a.x, targetX) <= bypass.x1 + a.w * 0.5 -- 3932
		local walkDepth = approachesBypass and (cp and cp.waitDepth or LANE_DEPTH.upper) or 0 -- 3935
		local depthStep = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 3936
		local lastDepth = a.depth -- 3937
		local lastX = a.x -- 3938
		a.h = CHILD_H -- 3939
		a.crouch = false -- 3940
		self:slideDepth( -- 3941
			a, -- 3941
			math.max( -- 3941
				-depthStep, -- 3941
				math.min(depthStep, walkDepth - lastDepth) -- 3941
			) -- 3941
		) -- 3941
		local dx = targetX - a.x -- 3942
		if math.abs(dx) > (wait and 18 or 74) then -- 3942
			local speed = not wait and math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3944
			a.facing = dx > 0 and 1 or -1 -- 3945
			self:slideX( -- 3946
				a, -- 3946
				a.facing * math.min( -- 3946
					math.abs(dx), -- 3946
					speed * dt -- 3946
				) -- 3946
			) -- 3946
		end -- 3946
		a.depthSpeed = dt > 0 and (a.depth - lastDepth) / dt or 0 -- 3948
		a.vx = dt > 0 and (a.x - lastX) / dt or 0 -- 3949
		self:fallY(a, dt) -- 3950
		return -- 3951
	end -- 3951
	if self.partnerStuck > 0.3 then -- 3951
		a.x = a.x + a.facing * 44 -- 3955
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3956
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3957
		self.partnerLaneHold = 1.1 -- 3958
		self.partnerStuck = 0 -- 3959
	end -- 3959
	if self.partnerLaneHold > 0 then -- 3959
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3962
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3963
	end -- 3963
	local dx = targetX - a.x -- 3965
	local stopTol = wait and 18 or 74 -- 3966
	if math.abs(dx) > stopTol then -- 3966
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3968
		local before = a.x -- 3969
		a.vx = dx > 0 and speed or -speed -- 3970
		a.facing = dx > 0 and 1 or -1 -- 3971
		self:slideX(a, a.vx * dt) -- 3972
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3972
			a.vy = CHILD_JUMP -- 3975
			a.onGround = false -- 3976
		end -- 3976
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3978
	else -- 3978
		a.vx = 0 -- 3980
		self.partnerStuck = 0 -- 3981
	end -- 3981
	local dz = targetDepth - a.depth -- 3983
	if math.abs(dz) > 6 then -- 3983
		local step = math.max( -- 3985
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3985
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3985
		) -- 3985
		a.depth = a.depth + step -- 3986
	end -- 3986
	a.depthSpeed = 0 -- 3988
	a.h = CHILD_H -- 3989
	a.crouch = false -- 3990
	self:fallY(a, dt) -- 3991
end -- 3897
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3995
	local p = self.player -- 3996
	local i = 0 -- 3997
	do -- 3997
		i = 0 -- 3998
		while i < #self.enemies and not self.escortFailed do -- 3998
			do -- 3998
				local e = self.enemies[i + 1] -- 3999
				if e.kind == "target" then -- 3999
					if not e.alive then -- 3999
						if e.hitT > 0 then -- 3999
							e.hitT = e.hitT - dt -- 4004
						end -- 4004
						if e.hitT <= 0 then -- 4004
							e.alive = true -- 4007
							e.hitT = 0 -- 4008
						end -- 4008
					end -- 4008
					goto __continue637 -- 4011
				end -- 4011
				if not e.alive then -- 4011
					goto __continue637 -- 4014
				end -- 4014
				if e.kind == "breaker" then -- 4014
					self:stepBreaker(e, dt) -- 4017
					goto __continue637 -- 4018
				end -- 4018
				if e.kind == "shield" then -- 4018
					self:stepShield(e, dt, input) -- 4021
					goto __continue637 -- 4022
				end -- 4022
				local dx = e.x - p.x -- 4025
				if not e.awake then -- 4025
					if math.abs(dx) > 520 then -- 4025
						goto __continue637 -- 4028
					end -- 4028
					e.awake = true -- 4030
					e.fireCd = 48 -- 4031
					goto __continue637 -- 4032
				end -- 4032
				if math.abs(dx) > ENEMY_RANGE then -- 4032
					goto __continue637 -- 4035
				end -- 4035
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 4035
					goto __continue637 -- 4040
				end -- 4040
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 4040
					goto __continue637 -- 4043
				end -- 4043
				if self:blockedShot(e, p) then -- 4043
					if e.warnT > 0 then -- 4043
						e.warnT = 0 -- 4049
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4050
					end -- 4050
					goto __continue637 -- 4052
				end -- 4052
				if e.warnT > 0 then -- 4052
					e.warnT = e.warnT - 1 -- 4055
					if e.warnT <= 0 then -- 4055
						self:campaignEnemyFire(e) -- 4057
					end -- 4057
				elseif e.fireCd > 0 then -- 4057
					e.fireCd = e.fireCd - 1 -- 4060
					if e.fireCd <= 0 then -- 4060
						e.warnT = WARN_TICKS -- 4062
					end -- 4062
				else -- 4062
					e.fireCd = 40 -- 4065
				end -- 4065
			end -- 4065
			::__continue637:: -- 4065
			i = i + 1 -- 3998
		end -- 3998
	end -- 3998
end -- 3995
function Play.prototype.blockedShot(self, e, p) -- 4071
	local eDepth = e.depth or 0 -- 4072
	local ex = e.x -- 4073
	local ey = e.y + e.h * 0.62 -- 4075
	local px = p.x -- 4076
	local py = p.y + p.h * 0.55 -- 4077
	local dx = px - ex -- 4078
	local dyScreen = py + p.depth * DEPTH_Y_SCALE - (ey + eDepth * DEPTH_Y_SCALE) -- 4079
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 4080
	if len < 0.01 then -- 4080
		return false -- 4082
	end -- 4082
	local ray = { -- 4086
		x = ex, -- 4087
		y = ey, -- 4087
		dx = dx / len, -- 4088
		dy = (py - ey) / len, -- 4088
		depth = eDepth, -- 4089
		dDepth = (p.depth - eDepth) / len -- 4089
	} -- 4089
	local best = -1 -- 4091
	local j = 0 -- 4092
	do -- 4092
		j = 0 -- 4093
		while j < #self.boxes do -- 4093
			do -- 4093
				local b = self.boxes[j + 1] -- 4094
				if b.broken == true or b.passable == true or b.hidden == true then -- 4094
					goto __continue660 -- 4096
				end -- 4096
				if b.id == "braced_shield" then -- 4096
					goto __continue660 -- 4101
				end -- 4101
				local t = hitBox(ray, b) -- 4103
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 4103
					best = t -- 4107
				end -- 4107
			end -- 4107
			::__continue660:: -- 4107
			j = j + 1 -- 4093
		end -- 4093
	end -- 4093
	return best >= 0 -- 4110
end -- 4071
function Play.prototype.campaignEnemyFire(self, e) -- 4113
	local p = self.player -- 4114
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4115
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 4115
		local ____self_bracedShield_120, ____hp_121 = self.bracedShield, "hp" -- 4115
		____self_bracedShield_120[____hp_121] = ____self_bracedShield_120[____hp_121] - 1 -- 4117
		if self.bracedShield.hp <= 0 then -- 4117
			self.boxes = __TS__ArrayFilter( -- 4119
				self.boxes, -- 4119
				function(____, b) return b.id ~= "braced_shield" end -- 4119
			) -- 4119
			self.bracedShield = nil -- 4120
			self:flashSet("残盾碎 · 挡下一发", 1) -- 4121
		else -- 4121
			self:flashSet( -- 4123
				"残盾挡下一发 · 余" .. tostring(self.bracedShield.hp), -- 4123
				1 -- 4123
			) -- 4123
		end -- 4123
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 4125
		return -- 4126
	end -- 4126
	if self:blockedShot(e, p) then -- 4126
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4129
		return -- 4130
	end -- 4130
	local cover = self:blockedByCover(e, p) -- 4132
	if cover ~= nil and self.coverHug then -- 4132
		self.coveredFlash = 0.5 -- 4134
		self:flashSet("掩体挡下", 0.6) -- 4135
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4136
		return -- 4141
	end -- 4141
	if self.invulnT > 0 then -- 4141
		return -- 4144
	end -- 4144
	self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4146
	self.craftT = 0 -- 4147
	self.hp = self.hp - 1 -- 4148
	self:emit("actorHit", { -- 4149
		target = "player", -- 4149
		amount = 1, -- 4149
		hp = self.hp, -- 4149
		maxHp = self.maxHp, -- 4149
		enemyX = e.x -- 4149
	}) -- 4149
	self:flashSet( -- 4150
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4150
		0.8 -- 4150
	) -- 4150
	if self.hp <= 0 then -- 4150
		self:campaignFailed() -- 4152
	end -- 4152
end -- 4113
function Play.prototype.stepShield(self, e, dt, input) -- 4157
	local p = self.player -- 4158
	local dx = p.x - e.x -- 4159
	local adx = math.abs(dx) -- 4160
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 4163
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 4164
	if adx > 44 then -- 4164
		local before = e.x -- 4166
		local stepX = (dx > 0 and 1 or -1) * 60 * dt -- 4167
		local nextX = math.max( -- 4168
			self.room.minX + 16, -- 4168
			math.min(self.room.maxX - 16, e.x + stepX) -- 4168
		) -- 4168
		if not self:enemyBlockedAtX(e, nextX) then -- 4168
			e.x = nextX -- 4170
		end -- 4170
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 4170
			e.depth = math.max( -- 4174
				-32, -- 4174
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4174
			) -- 4174
		end -- 4174
	elseif adx <= 48 and sameLane and (e.swingT or 0) <= 0 then -- 4174
		local fromFront = (e.x - p.x) * p.facing > 0 -- 4179
		local rollDodges = p.rollT > 0 and (fromFront or self:talentRank("guard") > 0) -- 4180
		if not rollDodges and self.invulnT <= 0 then -- 4180
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4182
			self.craftT = 0 -- 4183
			self.hp = self.hp - 1 -- 4184
			self:emit("actorHit", { -- 4185
				target = "player", -- 4185
				amount = 1, -- 4185
				hp = self.hp, -- 4185
				maxHp = self.maxHp, -- 4185
				enemyX = e.x -- 4185
			}) -- 4185
			self:flashSet( -- 4186
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4186
				0.8 -- 4186
			) -- 4186
			if self.hp <= 0 then -- 4186
				self:campaignFailed() -- 4188
				return -- 4189
			end -- 4189
		end -- 4189
		e.swingT = 70 -- 4192
	end -- 4192
	if (e.swingT or 0) > 0 then -- 4192
		e.swingT = (e.swingT or 0) - 1 -- 4195
	end -- 4195
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 4195
		local dd = p.depth - (e.depth or 0) -- 4198
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 4199
	end -- 4199
end -- 4157
function Play.prototype.stepBreaker(self, e, dt) -- 4204
	local p = self.player -- 4205
	if e.awake ~= true then -- 4205
		if math.abs(p.x - e.x) < 560 then -- 4205
			e.awake = true -- 4208
		else -- 4208
			return -- 4210
		end -- 4210
	end -- 4210
	local target = nil -- 4213
	local bestD = 1000000000 -- 4214
	local i = 0 -- 4215
	do -- 4215
		i = 0 -- 4216
		while i < #self.boxes do -- 4216
			do -- 4216
				local b = self.boxes[i + 1] -- 4217
				if b.breakable == nil or b.broken == true then -- 4217
					goto __continue687 -- 4219
				end -- 4219
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 4221
				if d < bestD then -- 4221
					bestD = d -- 4223
					target = b -- 4224
				end -- 4224
			end -- 4224
			::__continue687:: -- 4224
			i = i + 1 -- 4216
		end -- 4216
	end -- 4216
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 4227
	local dx = tx - e.x -- 4228
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 4229
	if math.abs(dx) > reach then -- 4229
		local before = e.x -- 4231
		local nextX = math.max( -- 4232
			self.room.minX + 16, -- 4232
			math.min(self.room.maxX - 16, e.x + (dx > 0 and 1 or -1) * 48 * dt) -- 4232
		) -- 4232
		if not self:enemyBlockedAtX(e, nextX) then -- 4232
			e.x = nextX -- 4234
		end -- 4234
		if math.abs(e.x - before) < 0.3 then -- 4234
			e.depth = math.max( -- 4237
				-32, -- 4237
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4237
			) -- 4237
		end -- 4237
	elseif (e.swingT or 0) <= 0 then -- 4237
		e.swingT = 64 -- 4240
		if target ~= nil then -- 4240
			self:damageProp(target, 2) -- 4242
		elseif math.abs(p.x - e.x) < 60 and math.abs((e.depth or 0) - p.depth) <= 26 and not (p.rollT > 0 and self:talentRank("guard") > 0) and self.invulnT <= 0 then -- 4242
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4245
			self.craftT = 0 -- 4246
			self.hp = self.hp - 1 -- 4247
			self:emit("actorHit", { -- 4248
				target = "player", -- 4248
				amount = 1, -- 4248
				hp = self.hp, -- 4248
				maxHp = self.maxHp, -- 4248
				enemyX = e.x -- 4248
			}) -- 4248
			self:flashSet("破障手近身", 0.8) -- 4249
			if self.hp <= 0 then -- 4249
				self:campaignFailed() -- 4251
				return -- 4252
			end -- 4252
		end -- 4252
	end -- 4252
	if (e.swingT or 0) > 0 then -- 4252
		e.swingT = (e.swingT or 0) - 1 -- 4257
	end -- 4257
end -- 4204
function Play.prototype.enemyBlockedAtX(self, e, nextX) -- 4262
	local half = e.w * 0.5 -- 4263
	local d = e.depth or 0 -- 4264
	local i = 0 -- 4265
	do -- 4265
		i = 0 -- 4266
		while i < #self.boxes do -- 4266
			do -- 4266
				local b = self.boxes[i + 1] -- 4267
				if b.broken == true or b.passable == true or b.soft == true or b.hidden == true or b.y0 >= e.y + e.h or b.y1 <= e.y + 4 then -- 4267
					goto __continue700 -- 4269
				end -- 4269
				if b.depth ~= nil and (d < b.depth.min - 8 or d > b.depth.max + 8) then -- 4269
					goto __continue700 -- 4272
				end -- 4272
				if nextX + half > b.x0 and nextX - half < b.x1 then -- 4272
					return true -- 4275
				end -- 4275
			end -- 4275
			::__continue700:: -- 4275
			i = i + 1 -- 4266
		end -- 4266
	end -- 4266
	return false -- 4278
end -- 4262
function Play.prototype.campaignFailed(self) -- 4281
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 4281
		if self.escortFailed then -- 4281
			return -- 4286
		end -- 4286
		if self.useEscortDeathSummary then -- 4286
			local story = self.run.story -- 4288
			local st = story.talents -- 4289
			local ranksCopy = { -- 4290
				vitality = st and st.ranks.vitality or 0, -- 4291
				guard = st and st.ranks.guard or 0, -- 4292
				stride = st and st.ranks.stride or 0, -- 4293
				focus = st and st.ranks.focus or 0, -- 4294
				push_force = st and st.ranks.push_force or 0, -- 4295
				echo_wide = st and st.ranks.echo_wide or 0, -- 4296
				lantern_pierce = st and st.ranks.lantern_pierce or 0, -- 4297
				salvage = st and st.ranks.salvage or 0 -- 4298
			} -- 4298
			local cleared = 0 -- 4300
			local segKeys = { -- 4301
				"escort1", -- 4301
				"escort2", -- 4301
				"escort3", -- 4301
				"escort4", -- 4301
				"escort5" -- 4301
			} -- 4301
			local si = 0 -- 4302
			do -- 4302
				si = 0 -- 4303
				while si < #segKeys do -- 4303
					if story.segments[segKeys[si + 1]] == true then -- 4303
						cleared = cleared + 1 -- 4305
					end -- 4305
					si = si + 1 -- 4303
				end -- 4303
			end -- 4303
			self.escortFailed = true -- 4308
			self.escortFailedTicks = 0 -- 4309
			self.talentModalActive = false -- 4310
			self.craftBench.active = false -- 4311
			self.reloadT = 0 -- 4312
			self:closeReloadPuzzle() -- 4313
			self.gripping = false -- 4314
			self.escortSummary = { -- 4315
				roomKey = self.room.key, -- 4316
				attempt = st ~= nil and math.max(1, st.attempt) or 1, -- 4317
				seed = st ~= nil and st.randomState or self.run.seed, -- 4318
				equippedWeapon = self.equippedWeapon, -- 4319
				segmentsCleared = cleared, -- 4320
				ranks = ranksCopy -- 4321
			} -- 4321
			self:resetEscortAttempt() -- 4323
			self:flashSet("折返山道 · 重整再赴", 2) -- 4324
			self:log("男主线折返 · 展示小结") -- 4325
			self:emit("campaignFailed", { -- 4326
				room = self.room.key, -- 4327
				hp = 0, -- 4327
				maxHp = self.maxHp, -- 4327
				reset = true, -- 4328
				to = "escort1", -- 4328
				route = self.storyRoute, -- 4328
				summary = true -- 4328
			}) -- 4328
			return -- 4330
		end -- 4330
		self:restartEscortRun() -- 4332
		return -- 4333
	end -- 4333
	local p = self.player -- 4335
	self.hp = self.maxHp -- 4336
	self.invulnT = INVULN_RESPAWN_TICKS -- 4337
	self.reloadT = 0 -- 4338
	self:closeReloadPuzzle() -- 4339
	self.gripping = false -- 4340
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 4341
	self:log("被击倒") -- 4342
	p.x = self.room.minX + 90 -- 4343
	p.y = 0 -- 4344
	p.depth = 0 -- 4345
	p.vx = 0 -- 4346
	p.vy = 0 -- 4347
	p.onGround = true -- 4348
	p.rollT = 0 -- 4349
	self.partner.x = p.x - 50 -- 4350
	self.partner.y = 0 -- 4351
	self.partner.depth = 0 -- 4352
	self.cam.x = p.x -- 4353
	local i = 0 -- 4354
	do -- 4354
		i = 0 -- 4355
		while i < #self.enemies do -- 4355
			do -- 4355
				local e = self.enemies[i + 1] -- 4356
				if not e.alive then -- 4356
					goto __continue712 -- 4358
				end -- 4358
				e.x = e.homeX == nil and e.x or e.homeX -- 4360
				e.warnT = 0 -- 4361
				e.fireCd = 40 -- 4362
				e.swingT = 0 -- 4363
				e.awake = false -- 4364
			end -- 4364
			::__continue712:: -- 4364
			i = i + 1 -- 4355
		end -- 4355
	end -- 4355
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4366
end -- 4281
function Play.prototype.isEscortRoom(self) -- 4370
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 4371
end -- 4370
function Play.prototype.confirmEscortRestart(self) -- 4375
	if not self.escortFailed then -- 4375
		return false -- 4377
	end -- 4377
	self:requestRoom("escort1", "男主线失败重开") -- 4379
	return true -- 4380
end -- 4375
function Play.prototype.restartEscortRun(self) -- 4384
	self:resetEscortAttempt() -- 4385
	self:requestRoom("escort1", "男主线失败重开") -- 4386
end -- 4384
function Play.prototype.resetEscortAttempt(self) -- 4394
	local story = self.run.story -- 4395
	local inv = self.run.inventory -- 4396
	local prevAttempt = story.talents ~= nil and math.max(1, story.talents.attempt) or 1 -- 4397
	local nextAttempt = prevAttempt + 1 -- 4398
	local vitBonus = story.talents ~= nil and (story.talents.ranks.vitality or 0) or 0 -- 4399
	if vitBonus > 0 then -- 4399
		self.maxHp = math.max(3, self.maxHp - vitBonus) -- 4401
		story.maxHp = self.maxHp -- 4402
	end -- 4402
	story.talents = createStoryTalents(self.run.seed, nextAttempt) -- 4404
	self.hp = self.maxHp -- 4405
	story.hp = self.maxHp -- 4406
	story.cp = nil -- 4407
	self.checkpointSnap = nil -- 4408
	story.carry = false -- 4409
	self.carryOn = false -- 4410
	story.craftedWeapon = "" -- 4411
	self.equippedWeapon = "standard_gun" -- 4412
	story.equippedWeapon = "standard_gun" -- 4413
	story.escortDone = false -- 4414
	self.escortDone = false -- 4415
	story.segments = {} -- 4416
	inv.wood = 0 -- 4417
	inv.bell = 0 -- 4418
	inv.scrap = 0 -- 4419
	inv.wedge = 0 -- 4420
	inv.ammo = 0 -- 4421
	inv.quickbelt = 0 -- 4422
	inv.shield = 0 -- 4423
	inv.pass = 0 -- 4424
	local taken = self.run.taken -- 4425
	local keys = __TS__ObjectKeys(taken) -- 4426
	local i = 0 -- 4427
	do -- 4427
		i = 0 -- 4428
		while i < #keys do -- 4428
			local k = keys[i + 1] -- 4429
			if (string.find(k, "e2_", nil, true) or 0) - 1 == 0 or (string.find(k, "e3_", nil, true) or 0) - 1 == 0 or (string.find(k, "escort", nil, true) or 0) - 1 == 0 then -- 4429
				__TS__Delete(taken, k) -- 4431
			end -- 4431
			i = i + 1 -- 4428
		end -- 4428
	end -- 4428
	local propKeys = __TS__ObjectKeys(self.run.props) -- 4434
	do -- 4434
		i = 0 -- 4435
		while i < #propKeys do -- 4435
			local pk = propKeys[i + 1] -- 4436
			if (string.find(pk, "e1_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e2_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e3_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e4_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e5_", nil, true) or 0) - 1 == 0 or (string.find(pk, "field_wedge_", nil, true) or 0) - 1 == 0 then -- 4436
				__TS__Delete(self.run.props, pk) -- 4439
			end -- 4439
			i = i + 1 -- 4435
		end -- 4435
	end -- 4435
	self.bracedShield = nil -- 4442
	self.talentModalActive = false -- 4443
	self.run.joined = true -- 4444
	self.reloadT = 0 -- 4445
	self:closeReloadPuzzle() -- 4446
	self.gripping = false -- 4447
	self.sessionDirty = true -- 4448
	self:flashSet( -- 4449
		("重整启程 · 第" .. tostring(nextAttempt)) .. "轮护送", -- 4449
		2 -- 4449
	) -- 4449
	self:log(("男主线重开 · 第" .. tostring(nextAttempt)) .. "轮回 escort1") -- 4450
	if not self.useEscortDeathSummary then -- 4450
		self:emit("campaignFailed", { -- 4452
			room = self.room.key, -- 4453
			hp = 0, -- 4453
			maxHp = self.maxHp, -- 4453
			reset = true, -- 4454
			to = "escort1", -- 4454
			route = self.storyRoute, -- 4454
			attempt = nextAttempt -- 4454
		}) -- 4454
	end -- 4454
end -- 4394
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 4460
	local i = 0 -- 4461
	do -- 4461
		i = 0 -- 4462
		while i < #self.enemies do -- 4462
			do -- 4462
				if i == skipIndex then -- 4462
					goto __continue729 -- 4464
				end -- 4464
				local e = self.enemies[i + 1] -- 4466
				if not e.alive or math.abs(e.x - center.x) > radius then -- 4466
					goto __continue729 -- 4468
				end -- 4468
				e.awake = true -- 4470
				e.fireCd = math.max(e.fireCd or 0, 150) -- 4471
				e.warnT = 0 -- 4472
			end -- 4472
			::__continue729:: -- 4472
			i = i + 1 -- 4462
		end -- 4462
	end -- 4462
end -- 4460
function Play.prototype.stepEnemies(self, dt, input) -- 4476
	local i = 0 -- 4477
	do -- 4477
		i = 0 -- 4478
		while i < #self.enemies do -- 4478
			local e = self.enemies[i + 1] -- 4479
			if e.hitT > 0 then -- 4479
				e.hitT = e.hitT - dt -- 4481
			end -- 4481
			i = i + 1 -- 4478
		end -- 4478
	end -- 4478
	if self.coveredFlash > 0 then -- 4478
		self.coveredFlash = self.coveredFlash - dt -- 4485
	end -- 4485
	if self.isCampaign then -- 4485
		self:stepCampaignEnemies(dt, input) -- 4488
		return -- 4489
	end -- 4489
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 4489
		return -- 4493
	end -- 4493
	do -- 4493
		i = 0 -- 4495
		while i < #self.enemies do -- 4495
			do -- 4495
				local e = self.enemies[i + 1] -- 4496
				if not e.alive then -- 4496
					goto __continue740 -- 4498
				end -- 4498
				if e.warnT > 0 then -- 4498
					e.warnT = e.warnT - 1 -- 4501
					if e.warnT <= 0 then -- 4501
						self:enemyFire(e, input) -- 4503
					end -- 4503
					goto __continue740 -- 4505
				end -- 4505
				if e.fireCd > 0 then -- 4505
					e.fireCd = e.fireCd - 1 -- 4508
					if e.fireCd <= 0 then -- 4508
						e.warnT = WARN_TICKS -- 4510
					end -- 4510
				else -- 4510
					e.warnT = WARN_TICKS -- 4514
				end -- 4514
			end -- 4514
			::__continue740:: -- 4514
			i = i + 1 -- 4495
		end -- 4495
	end -- 4495
end -- 4476
function Play.prototype.enemyFire(self, e, input) -- 4520
	local p = self.player -- 4521
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 4521
		self:flashSet("枪声响在远处", 0.4) -- 4523
		e.fireCd = FIRE_COOLDOWN -- 4524
		return -- 4525
	end -- 4525
	if self:blockedShot(e, p) then -- 4525
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4528
		e.fireCd = FIRE_COOLDOWN -- 4529
		return -- 4530
	end -- 4530
	local cover = self:blockedByCover(e, p) -- 4533
	local hugging = cover ~= nil -- 4534
	self.coverBlocking = hugging -- 4535
	local covered = hugging and input.cover.held -- 4536
	if covered then -- 4536
		self.coveredFlash = 0.5 -- 4538
		self:flashSet("掩体挡下", 0.5) -- 4539
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4540
		e.fireCd = FIRE_COOLDOWN -- 4545
		return -- 4546
	end -- 4546
	if self.invulnT > 0 then -- 4546
		e.fireCd = FIRE_COOLDOWN -- 4549
		return -- 4550
	end -- 4550
	self.invulnT = INVULN_HIT_TICKS -- 4552
	self.hp = self.hp - 1 -- 4553
	self:emit("actorHit", { -- 4554
		target = "player", -- 4554
		amount = 1, -- 4554
		hp = self.hp, -- 4554
		maxHp = self.maxHp, -- 4554
		enemyX = e.x -- 4554
	}) -- 4554
	self:flashSet( -- 4555
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4555
		0.7 -- 4555
	) -- 4555
	e.fireCd = FIRE_COOLDOWN -- 4556
	if self.hp <= 0 then -- 4556
		self:gateFailed() -- 4558
	end -- 4558
end -- 4520
function Play.prototype.blockedByCover(self, enemy, p) -- 4563
	local b = self:coverAt(p) -- 4564
	if b == nil then -- 4564
		return nil -- 4566
	end -- 4566
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4568
end -- 4563
function Play.prototype.gateFailed(self) -- 4572
	local ____temp_138 -- 4573
	if self.room.story == nil then -- 4573
		____temp_138 = nil -- 4573
	else -- 4573
		____temp_138 = self.room.story.gate -- 4573
	end -- 4573
	local g = ____temp_138 -- 4573
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 4574
	self.hp = self.maxHp -- 4575
	self.gateTick = 0 -- 4576
	self.gateSpawned = 0 -- 4577
	self.enemies = {} -- 4578
	self.gateFailCount = self.gateFailCount + 1 -- 4579
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 4581
	self.player.y = 0 -- 4582
	self.player.vy = 0 -- 4583
	self.player.depth = 0 -- 4584
	self.player.depthSpeed = 0 -- 4585
	self.player.onGround = true -- 4586
	self.player.crouch = false -- 4587
	self.player.h = SOLDIER_H -- 4588
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 4589
	self.partner.y = 0 -- 4590
	self.partner.vy = 0 -- 4591
	self.partner.depth = 0 -- 4592
	self.partner.depthSpeed = 0 -- 4593
	self.partner.onGround = true -- 4594
	self.cam.x = self.player.x -- 4595
	self.phase = "gate-idle" -- 4596
	self.phaseTick = 0 -- 4597
	self.coverHug = false -- 4598
	self.coverBlocking = false -- 4599
	self.coverEntity = "" -- 4600
	self.gateNeedConfirm = true -- 4601
	self.gateRestartArmed = false -- 4602
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 4603
end -- 4572
function Play.prototype.finishOutsideCart(self) -- 4607
	self.redCartMemoryT = 30 -- 4608
	if self.run.story ~= nil then -- 4608
		self.run.story.segments.outside_cart = true -- 4610
		self.run.story.segments.outside_memory = true -- 4611
	end -- 4611
	self.sessionDirty = true -- 4613
	self:emit("storyBeat", {beat = "red_cart_memory", x = self.player.x, room = "outside", durationTicks = 30}) -- 4614
end -- 4607
function Play.prototype.stepInteract(self, dt, input) -- 4617
	local p = self.player -- 4618
	self.redCartMemoryT = math.max(0, self.redCartMemoryT - 1) -- 4619
	local calmUsed = self.calmConsumed -- 4620
	self.calmConsumed = false -- 4621
	local calming = self.escort.state == "calming" -- 4623
	self.focusCart = false -- 4624
	if self.room.key == "outside" then -- 4624
		self.focusCart = not calmUsed and not calming and self:cartHandleInReach(p) -- 4626
	end -- 4626
	if not calmUsed and not calming then -- 4626
		self:stepCart(dt, input) -- 4630
	end -- 4630
	if calmUsed then -- 4630
		self:flashSet("安抚 · 敲两下", 0.8) -- 4635
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4635
		if self.knockT > 0 then -- 4635
			self.knocks = self.knocks + 1 -- 4639
		else -- 4639
			self.knocks = 1 -- 4641
		end -- 4641
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4643
		self.knockT = 1.2 -- 4644
		if self.knocks >= 2 then -- 4644
			self:flashSet("敲两下", 0.8) -- 4646
			self.knocks = 0 -- 4647
		else -- 4647
			self:flashSet("敲一下", 0.5) -- 4649
		end -- 4649
	elseif self.knockT > 0 then -- 4649
		self.knockT = self.knockT - dt -- 4652
		if self.knockT <= 0 then -- 4652
			self.knocks = 0 -- 4654
		end -- 4654
	end -- 4654
	local i = 0 -- 4659
	do -- 4659
		i = 0 -- 4660
		while i < #self.room.marks do -- 4660
			do -- 4660
				local m = self.room.marks[i + 1] -- 4661
				if m.kind ~= 0 then -- 4661
					goto __continue770 -- 4663
				end -- 4663
				local subjects = {self.partner, self.player} -- 4665
				local k = 0 -- 4666
				do -- 4666
					k = 0 -- 4667
					while k < #subjects do -- 4667
						do -- 4667
							local s = subjects[k + 1] -- 4668
							if not s.alive then -- 4668
								goto __continue773 -- 4670
							end -- 4670
							local dx = s.x - m.x -- 4672
							local dy = s.y - m.y -- 4673
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4673
								self.checkpoint = m.x -- 4675
								self.checkpointCartAxle = self.cartAxle -- 4676
								if self.isCampaign then -- 4676
									self:captureCheckpoint(m.x) -- 4679
								end -- 4679
								if self.room.cart.bodyW > 0 then -- 4679
									if self.cartDocked then -- 4679
										self:flashSet("检查点 · 车已落窝", 1) -- 4683
									else -- 4683
										self:flashSet("检查点 · 车还没到位", 1) -- 4685
									end -- 4685
								else -- 4685
									self:flashSet("检查点", 1) -- 4688
								end -- 4688
							end -- 4688
						end -- 4688
						::__continue773:: -- 4688
						k = k + 1 -- 4667
					end -- 4667
				end -- 4667
			end -- 4667
			::__continue770:: -- 4667
			i = i + 1 -- 4660
		end -- 4660
	end -- 4660
	self:checkCarryGate() -- 4694
end -- 4617
function Play.prototype.stepVillage(self, dt, input) -- 4698
	if self.room.key ~= "village" then -- 4698
		return -- 4700
	end -- 4700
	local p = self.player -- 4702
	local bottle = self.room.bottle -- 4703
	local scav = self.room.scavenger -- 4704
	if not self.hasBottle and bottle ~= nil then -- 4704
		local dx = p.x - bottle.x -- 4708
		local dy = p.y + p.h * 0.5 - bottle.y -- 4709
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4709
			self.hasBottle = true -- 4711
			self:flashSet("拾起瓶子", 0.8) -- 4712
		end -- 4712
	end -- 4712
	if self.hasBottle then -- 4712
		local kbmMouseAim = input:isKbmMode() and input.inside -- 4718
		local rawAimHeld = input.aim.held or kbmMouseAim and input.fire.held -- 4719
		local rawAimReleased = input.aim.released or kbmMouseAim and input.fire.released -- 4720
		if not rawAimHeld then -- 4720
			self.bottleAimCancelLatch = false -- 4722
		end -- 4722
		if input.bottleCanceled then -- 4722
			self.aimHold = 0 -- 4725
			self.bottleAimX = -1 -- 4726
			self.bottleAimCancelLatch = rawAimHeld -- 4727
		elseif rawAimHeld and not self.bottleAimCancelLatch then -- 4727
			self.aimHold = self.aimHold + dt -- 4729
			if self.aimHold > 1.2 then -- 4729
				self.aimHold = 1.2 -- 4731
			end -- 4731
			local cached = self:bottleEnd() -- 4734
			self.bottleAimX = cached.x -- 4735
			self.bottleAimY = cached.y -- 4736
		elseif rawAimReleased and not self.bottleAimCancelLatch then -- 4736
			if self.aimHold < 0.12 then -- 4736
				self:flashSet( -- 4740
					input:isKbmMode() and "按住 F 或左键瞄一下再松手" or "按住 F 瞄一下再松手", -- 4740
					0.9 -- 4740
				) -- 4740
				self.aimHold = 0 -- 4741
			else -- 4741
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4743
				self:throwBottle(____end.x, ____end.y) -- 4744
				self.aimHold = 0 -- 4745
			end -- 4745
		end -- 4745
	else -- 4745
		self.aimHold = 0 -- 4749
		self.bottleAimX = -1 -- 4750
		self.bottleAimCancelLatch = false -- 4751
	end -- 4751
	local fly = self.bottleFly -- 4756
	if fly ~= nil then -- 4756
		fly.t = fly.t + dt -- 4758
		fly.x = fly.x0 + fly.vx * fly.t -- 4759
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4760
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4761
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4761
			self:landBottle(fly) -- 4763
		end -- 4763
	end -- 4763
	if self.bottleLandT > 0 then -- 4763
		self.bottleLandT = self.bottleLandT - dt -- 4767
	end -- 4767
	if scav ~= nil then -- 4767
		self:stepScav(dt, scav) -- 4771
	end -- 4771
	local line = self.room.passLine -- 4774
	if line ~= nil and not self.passed and p.x >= line then -- 4774
		self.passed = true -- 4776
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4777
	end -- 4777
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4780
	if underTable then -- 4780
		self.footHintT = self.footHintT - 1 -- 4782
		if self.footHintT <= 0 then -- 4782
			self.footHintT = 90 -- 4784
			local scavX = self.scavX -- 4785
			local near = math.abs(scavX - p.x) < 120 -- 4786
			local walkingAway = self.scavState == "walk" and math.abs(self.scavTargetX - p.x) >= 120 -- 4787
			local heard = self.scavState == "chase" or near and not walkingAway -- 4788
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4789
			self:emit("storyBeat", {beat = heard and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4790
		end -- 4790
	else -- 4790
		self.footHintT = 0 -- 4793
	end -- 4793
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4793
		self.ditchHinted = true -- 4797
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4798
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4799
	end -- 4799
	local inCulvert = p.x >= self.ox + 560 and p.x <= self.ox + 640 -- 4802
	if self.passed and inCulvert and p.crouch and self.wantRoom == "" then -- 4802
		self:requestRoom("forest", "蹲下钻过暗渠") -- 4804
		self:flashSet("钻进暗渠 · 北塔森林", 1.4) -- 4805
	end -- 4805
end -- 4698
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
		if self.room.key == "outside" then -- 5020
			self:finishOutsideCart() -- 5022
		end -- 5022
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 5022
		self:flashSet("车轮回到起点", 0.5) -- 5025
	end -- 5025
end -- 4959
function Play.prototype.requestRoom(self, key, reason) -- 5033
	if self.wantRoom ~= "" then -- 5033
		return -- 5037
	end -- 5037
	self.wantRoom = key -- 5039
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 5040
end -- 5033
function Play.prototype.checkCarryGate(self) -- 5047
	if self.room.key == "checkpoint" then -- 5047
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 5047
			self.carryCartAxle = self.cartAxle -- 5050
			self.carryCartDocked = self.cartDocked -- 5051
			self:requestRoom("gate", "检查站出口") -- 5052
			self:flashSet("出检查站 · 城门", 1.2) -- 5053
		end -- 5053
		return -- 5055
	end -- 5055
	if self.room.key == "outside" then -- 5055
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 5055
			self.carryCartAxle = self.cartAxle -- 5061
			self.carryCartDocked = self.cartDocked -- 5062
			self:requestRoom("village", "墙根走完") -- 5063
			self:flashSet("墙根走完 · 进村口", 1.2) -- 5064
		end -- 5064
	end -- 5064
end -- 5047
function Play.prototype.aimAt(self, wx, wy) -- 5071
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 5072
	self.aimX = s.x -- 5073
	self.aimY = s.y -- 5074
end -- 5071
function Play.prototype.shoot(self, a) -- 5077
	if self.isCampaign and self.reloadT > 0 then -- 5077
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 5079
		return -- 5080
	end -- 5080
	local ox = a.x + a.facing * 8 -- 5082
	local muzzleY = a.y + a.h * 0.72 -- 5083
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 5084
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 5086
	local dx = aim.x - ox -- 5089
	local dy = aim.y - oy -- 5090
	local len = math.sqrt(dx * dx + dy * dy) -- 5091
	if len < 0.001 then -- 5091
		dx = a.facing -- 5093
		dy = 0 -- 5094
	else -- 5094
		dx = dx / len -- 5096
		dy = dy / len -- 5097
	end -- 5097
	if dx ~= 0 then -- 5097
		a.facing = dx > 0 and 1 or -1 -- 5100
	end -- 5100
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 5103
	local hitEnemy = self:raycastEnemies(ray) -- 5104
	local tEnemy = hitEnemy.t -- 5105
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 5106
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 5107
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 5108
	local tWall = solid.t -- 5109
	local rawEffect = self:consumeReloadEffect() -- 5111
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 5112
	local reloadEffect = rawEffect -- 5113
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 5115
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 5116
	self.trace = { -- 5118
		x0 = ox, -- 5118
		y0 = oy, -- 5118
		x1 = ox + dx * t, -- 5118
		y1 = oy + dy * t, -- 5118
		hit = hit -- 5118
	} -- 5118
	self.traceT = 0.12 -- 5119
	self:applyFireDanger(ox) -- 5120
	local killed = false -- 5121
	if hit then -- 5121
		local i = hitEnemy.index -- 5123
		local e = self.enemies[i + 1] -- 5124
		local impactY = oy + dy * tEnemy -- 5125
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 5126
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 5127
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 5127
			local pushRank = self:talentRank("push_force") -- 5129
			local dmg = reloadEffect == "push" and 2 + pushRank or 1 -- 5130
			e.shieldHp = math.max(0, (e.shieldHp or 0) - dmg) -- 5131
			e.hitT = 0.3 -- 5132
			if reloadEffect == "push" then -- 5132
				local kb = 46 + 24 * pushRank -- 5134
				e.x = math.max( -- 5135
					self.room.minX + 20, -- 5135
					math.min(self.room.maxX - 20, e.x + a.facing * kb) -- 5135
				) -- 5135
				if pushRank > 0 then -- 5135
					self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5137
				end -- 5137
				self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5139
				self:flashSet(e.shieldHp <= 0 and "推退破盾！" or "推退震退持盾手", 0.9) -- 5140
			else -- 5140
				self:flashSet( -- 5142
					(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 5142
					0.8 -- 5142
				) -- 5142
			end -- 5142
			self:emit("shotResolved", { -- 5144
				hit = true, -- 5145
				enemyIndex = i, -- 5145
				enemyX = e.x, -- 5145
				aimX = aim.x, -- 5145
				aimY = aim.y, -- 5145
				impactX = ox + dx * t, -- 5146
				impactY = oy + dy * t, -- 5146
				shield = true -- 5146
			}) -- 5146
			self:beginReload() -- 5148
			return -- 5149
		end -- 5149
		e.alive = false -- 5151
		e.hitT = 0.4 -- 5152
		killed = true -- 5153
		self:flashSet("命中", 0.6) -- 5154
		self:dropFor(e) -- 5155
		local lpRank = self:talentRank("lantern_pierce") -- 5156
		if reloadEffect == "light" and (weaponFx == "light" or lpRank > 0) then -- 5156
			local blindRadius = (weaponFx == "light" and 160 or 110) + 50 * lpRank -- 5158
			self:blindNearby(e, blindRadius, i) -- 5159
		end -- 5159
		if reloadEffect == "push" then -- 5159
			local pushRank = self:talentRank("push_force") -- 5162
			e.x = e.x + a.facing * (46 + 24 * pushRank) -- 5163
			if pushRank > 0 then -- 5163
				self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5165
			end -- 5165
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5167
		elseif reloadEffect == "echo" then -- 5167
			local echoRank = self:talentRank("echo_wide") -- 5169
			self:echoToSource(a, (weaponFx == "echo" and 2 or 1) + echoRank, 60 + 30 * echoRank) -- 5170
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 5171
		elseif reloadEffect == "light" then -- 5171
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 5173
		end -- 5173
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 5173
		self:damageProp(solid.box, 1) -- 5176
	else -- 5176
		self:flashSet("打空", 0.35) -- 5178
	end -- 5178
	if self.isCampaign then -- 5178
		self:beginReload() -- 5181
	end -- 5181
	self:emit("shotResolved", { -- 5183
		hit = hit, -- 5184
		enemyIndex = hit and hitEnemy.index or -1, -- 5185
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 5186
		aimX = aim.x, -- 5187
		aimY = aim.y, -- 5188
		impactX = ox + dx * t, -- 5189
		impactY = oy + dy * t -- 5190
	}) -- 5190
end -- 5077
function Play.prototype.staggerNearby(self, center, radius, delayTicks, skipIndex) -- 5195
	local i = 0 -- 5196
	do -- 5196
		i = 0 -- 5197
		while i < #self.enemies do -- 5197
			do -- 5197
				if i == skipIndex then -- 5197
					goto __continue870 -- 5199
				end -- 5199
				local e = self.enemies[i + 1] -- 5201
				if not e.alive or math.abs(e.x - center.x) > radius then -- 5201
					goto __continue870 -- 5203
				end -- 5203
				e.warnT = 0 -- 5205
				e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 5206
				local pushDir = e.x >= center.x and 1 or -1 -- 5207
				e.x = math.max( -- 5208
					self.room.minX + 20, -- 5208
					math.min(self.room.maxX - 20, e.x + pushDir * 22) -- 5208
				) -- 5208
			end -- 5208
			::__continue870:: -- 5208
			i = i + 1 -- 5197
		end -- 5197
	end -- 5197
end -- 5195
function Play.prototype.applyFireDanger(self, shotX) -- 5213
	local ____temp_144 = self.isCampaign and self.run.joined -- 5214
	if ____temp_144 then -- 5214
		local ____opt_139 = self.room.campaign -- 5214
		local ____temp_143 = (____opt_139 and ____opt_139.chapter) == "S" -- 5215
		if not ____temp_143 then -- 5215
			local ____opt_141 = self.room.campaign -- 5215
			____temp_143 = (____opt_141 and ____opt_141.chapter) == "C" -- 5215
		end -- 5215
		____temp_144 = ____temp_143 -- 5214
	end -- 5214
	local isStorySc = ____temp_144 -- 5214
	if self.room.key ~= "checkpoint" and not isStorySc or not self.partner.alive then -- 5214
		return -- 5217
	end -- 5217
	local dangerX = shotX -- 5219
	local best = -1 -- 5220
	local bestD = 1000000000 -- 5221
	local i = 0 -- 5222
	do -- 5222
		i = 0 -- 5223
		while i < #self.enemies do -- 5223
			do -- 5223
				local e = self.enemies[i + 1] -- 5224
				if not e.alive then -- 5224
					goto __continue876 -- 5226
				end -- 5226
				local d = math.abs(e.x - self.partner.x) -- 5228
				if d < bestD then -- 5228
					bestD = d -- 5230
					best = i -- 5231
				end -- 5231
			end -- 5231
			::__continue876:: -- 5231
			i = i + 1 -- 5223
		end -- 5223
	end -- 5223
	if best >= 0 then -- 5223
		dangerX = self.enemies[best + 1].x -- 5235
	end -- 5235
	if isStorySc and math.abs(dangerX - self.partner.x) > 260 then -- 5235
		return -- 5239
	end -- 5239
	local exposed = self:childExposed(dangerX) -- 5241
	local before = self.escort.fear -- 5242
	local dangerId = self.nextDangerId -- 5243
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 5244
	self.nextDangerId = self.nextDangerId + 1 -- 5245
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 5246
	if after > before then -- 5246
		self:flashSet( -- 5248
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 5248
			1 -- 5248
		) -- 5248
	elseif not exposed then -- 5248
		self:flashSet("枪声没够到她", 0.5) -- 5250
	end -- 5250
end -- 5213
function Play.prototype.childExposed(self, dangerX) -- 5255
	local c = self.partner -- 5256
	if not c.alive then -- 5256
		return false -- 5258
	end -- 5258
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 5258
		self.boxes, -- 5261
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 5261
	) then -- 5261
		return false -- 5262
	end -- 5262
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 5262
		return false -- 5265
	end -- 5265
	local toDanger = dangerX - c.x -- 5267
	local toPlayer = self.player.x - c.x -- 5268
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 5268
		return false -- 5271
	end -- 5271
	return true -- 5273
end -- 5255
function Play.prototype.raycastEnemies(self, ray) -- 5277
	local best = -1 -- 5278
	local bestI = -1 -- 5279
	do -- 5279
		local i = 0 -- 5280
		while i < #self.enemies do -- 5280
			do -- 5280
				local e = self.enemies[i + 1] -- 5281
				if not e.alive then -- 5281
					goto __continue891 -- 5283
				end -- 5283
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 5285
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 5286
				if t >= 0 and (best < 0 or t < best) then -- 5286
					best = t -- 5288
					bestI = i -- 5289
				end -- 5289
			end -- 5289
			::__continue891:: -- 5289
			i = i + 1 -- 5280
		end -- 5280
	end -- 5280
	return {t = best, index = bestI} -- 5292
end -- 5277
function Play.prototype.raycastWorld(self, ray) -- 5295
	return self:raycastSolid(ray).t -- 5296
end -- 5295
function Play.prototype.raycastSolid(self, ray) -- 5300
	local best = -1 -- 5301
	local bestBox = nil -- 5302
	for ____, box in ipairs(self.boxes) do -- 5303
		do -- 5303
			if box.broken == true or box.hidden == true then -- 5303
				goto __continue896 -- 5305
			end -- 5305
			local t = hitBox(ray, box) -- 5310
			if t > 2 and (best < 0 or t < best) then -- 5310
				best = t -- 5313
				bestBox = box -- 5314
			end -- 5314
		end -- 5314
		::__continue896:: -- 5314
	end -- 5314
	if ray.dy < 0 then -- 5314
		local t = -ray.y / ray.dy -- 5318
		if t >= 0 and (best < 0 or t < best) then -- 5318
			best = t -- 5320
			bestBox = nil -- 5321
		end -- 5321
	end -- 5321
	return {t = best, box = bestBox} -- 5324
end -- 5300
function Play.prototype.dropFor(self, e) -- 5328
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 5328
		return -- 5330
	end -- 5330
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 5330
		return -- 5333
	end -- 5333
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 5335
	local ____self_pickups_145 = self.pickups -- 5335
	____self_pickups_145[#____self_pickups_145 + 1] = { -- 5336
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 5337
		kind = e.drop, -- 5337
		x = e.x, -- 5337
		y = e.y, -- 5337
		depth = e.depth, -- 5338
		label = label .. " ×1" -- 5338
	} -- 5338
	self:log("掉落 " .. label) -- 5340
end -- 5328
function Play.prototype.damageProp(self, b, amount) -- 5344
	if b.breakable == nil or b.broken == true then -- 5344
		return -- 5346
	end -- 5346
	local ____b_breakable_146, ____hp_147 = b.breakable, "hp" -- 5346
	____b_breakable_146[____hp_147] = ____b_breakable_146[____hp_147] - amount -- 5348
	if b.breakable.hp > 0 then -- 5348
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 5350
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 5351
		return -- 5352
	end -- 5352
	b.broken = true -- 5354
	for ____, other in ipairs(self.boxes) do -- 5355
		if other.id ~= nil and other.id == b.id then -- 5355
			other.broken = true -- 5357
		end -- 5357
	end -- 5357
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 5360
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 5361
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 5362
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 5363
end -- 5344
function Play.prototype.slideDepth(self, a, distance) -- 5367
	a.depth = self:limitDepth(a, a.depth + distance) -- 5368
end -- 5367
function Play.prototype.limitDepth(self, a, target) -- 5371
	local road = self.room.depth -- 5372
	if road == nil or target == a.depth then -- 5372
		return a.depth -- 5374
	end -- 5374
	local next = math.max( -- 5376
		road.min, -- 5376
		math.min(road.max, target) -- 5376
	) -- 5376
	local half = a.w / 2 -- 5377
	for ____, b in ipairs(self.boxes) do -- 5378
		do -- 5378
			local footprint = b.depth -- 5379
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5379
				goto __continue914 -- 5384
			end -- 5384
			local front = footprint.min - ACTOR_DEPTH_HALF -- 5386
			local back = footprint.max + ACTOR_DEPTH_HALF -- 5387
			if a.depth <= front and next > front then -- 5387
				next = front -- 5389
			elseif a.depth >= back and next < back then -- 5389
				next = back -- 5391
			end -- 5391
		end -- 5391
		::__continue914:: -- 5391
	end -- 5391
	return next -- 5394
end -- 5371
function Play.prototype.cartLatchBounds(self) -- 5398
	if self.room.key ~= "outside" or self.cartDocked then -- 5398
		return nil -- 5399
	end -- 5399
	local arch = self.room.arch -- 5400
	local halfWidth = self.room.cart.bodyW / 2 -- 5401
	local left = math.max(arch.x0, self.room.cart.startX - halfWidth) -- 5402
	local right = math.min(arch.x1, self.room.cart.startX + halfWidth) -- 5403
	return right > left and Rect(left, arch.y, right - left, arch.h) or nil -- 5404
end -- 5398
function Play.prototype.slideX(self, a, dx) -- 5408
	local nx = a.x + dx -- 5409
	local half = a.w / 2 -- 5410
	local room = self.room -- 5411
	nx = math.max( -- 5412
		room.minX + half, -- 5412
		math.min(room.maxX - half, nx) -- 5412
	) -- 5412
	local i = 0 -- 5413
	do -- 5413
		i = 0 -- 5414
		while i < #self.boxes do -- 5414
			do -- 5414
				local b = self.boxes[i + 1] -- 5415
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5415
					goto __continue923 -- 5417
				end -- 5417
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5417
					goto __continue923 -- 5420
				end -- 5420
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5420
					goto __continue923 -- 5423
				end -- 5423
				if nx + half > b.x0 and nx - half < b.x1 then -- 5423
					if a.x <= b.x0 then -- 5423
						nx = b.x0 - half -- 5427
					elseif a.x >= b.x1 then -- 5427
						nx = b.x1 + half -- 5429
					else -- 5429
						nx = a.x -- 5431
					end -- 5431
				end -- 5431
			end -- 5431
			::__continue923:: -- 5431
			i = i + 1 -- 5414
		end -- 5414
	end -- 5414
	local latch = self:cartLatchBounds() -- 5435
	if latch ~= nil and a.y < latch.y + latch.height - 0.001 and nx + half > latch.x and nx - half < latch.x + latch.width then -- 5435
		if a.x <= latch.x then -- 5435
			nx = latch.x - half -- 5439
		elseif a.x >= latch.x + latch.width then -- 5439
			nx = latch.x + latch.width + half -- 5441
		else -- 5441
			nx = a.x -- 5443
		end -- 5443
	end -- 5443
	local arch = room.arch -- 5450
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 5450
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 5452
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 5452
			if a.x <= arch.x0 then -- 5452
				nx = arch.x0 - half -- 5455
			elseif a.x >= arch.x1 then -- 5455
				nx = arch.x1 + half -- 5457
			end -- 5457
		end -- 5457
	end -- 5457
	a.x = nx -- 5461
end -- 5408
function Play.prototype.fallY(self, a, dt) -- 5465
	a.vy = a.vy - ____exports.GRAVITY * dt -- 5466
	if a.vy < -900 then -- 5466
		a.vy = -900 -- 5468
	end -- 5468
	local ny = a.y + a.vy * dt -- 5470
	local half = a.w / 2 -- 5471
	if a.vy <= 0 then -- 5471
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 5474
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 5475
		if ny <= ground then -- 5475
			ny = ground -- 5477
			a.vy = 0 -- 5478
			a.onGround = true -- 5479
		else -- 5479
			a.onGround = false -- 5481
		end -- 5481
	else -- 5481
		a.onGround = false -- 5484
		local i = 0 -- 5485
		do -- 5485
			i = 0 -- 5486
			while i < #self.boxes do -- 5486
				do -- 5486
					local b = self.boxes[i + 1] -- 5487
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5487
						goto __continue946 -- 5489
					end -- 5489
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5489
						goto __continue946 -- 5492
					end -- 5492
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 5492
						goto __continue946 -- 5495
					end -- 5495
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 5495
						ny = b.y0 - a.h -- 5498
						a.vy = 0 -- 5499
					end -- 5499
				end -- 5499
				::__continue946:: -- 5499
				i = i + 1 -- 5486
			end -- 5486
		end -- 5486
	end -- 5486
	a.y = ny -- 5503
end -- 5465
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 5507
	if depth == nil then -- 5507
		depth = 0 -- 5507
	end -- 5507
	local g = -9999 -- 5508
	local i = 0 -- 5509
	do -- 5509
		i = 0 -- 5510
		while i < #self.floors do -- 5510
			local f = self.floors[i + 1] -- 5511
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 5511
				g = f.y1 -- 5513
			end -- 5513
			i = i + 1 -- 5510
		end -- 5510
	end -- 5510
	do -- 5510
		i = 0 -- 5516
		while i < #self.boxes do -- 5516
			do -- 5516
				local b = self.boxes[i + 1] -- 5517
				if b.broken == true or b.hidden == true or b.soft == true then -- 5517
					goto __continue956 -- 5519
				end -- 5519
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 5519
					g = b.y1 -- 5523
				end -- 5523
			end -- 5523
			::__continue956:: -- 5523
			i = i + 1 -- 5516
		end -- 5516
	end -- 5516
	return g -- 5526
end -- 5507
function Play.prototype.updateCamera(self, dt) -- 5529
	local p = self.player -- 5530
	local tx = p.x + p.facing * 30 -- 5531
	local ty = p.y + CAM_LOOK_UP -- 5532
	local k = math.min(1, CAM_FOLLOW * dt) -- 5533
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 5534
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 5535
end -- 5529
function Play.prototype.clampCamera(self, w, h) -- 5539
	local room = self.room -- 5540
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 5541
	local spanX = room.maxX - room.minX -- 5542
	if spanX <= halfW * 2 then -- 5542
		self.cam.x = (room.minX + room.maxX) / 2 -- 5544
	else -- 5544
		self.cam.x = math.max( -- 5546
			room.minX + halfW, -- 5546
			math.min(room.maxX - halfW, self.cam.x) -- 5546
		) -- 5546
	end -- 5546
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 5549
	local spanY = room.height -- 5550
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 5551
	if spanY <= halfH * 2 then -- 5551
		self.cam.y = camY -- 5553
	else -- 5553
		self.cam.y = math.max( -- 5555
			camY, -- 5555
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 5555
		) -- 5555
	end -- 5555
end -- 5539
function Play.prototype.flashSet(self, text, t) -- 5559
	self.flash = text -- 5560
	self.flashT = t -- 5561
end -- 5559
function Play.prototype.statusText(self) -- 5565
	local p = self.player -- 5566
	local parts = {} -- 5567
	local who = self.childMode and "小满" or "周戍" -- 5568
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 5569
	if self.room.key == "prologue" then -- 5569
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5572
		if self.phase == "prologue-wake" then -- 5572
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 5574
		elseif self.phase == "prologue-shadow" then -- 5574
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 5576
		elseif self.phase == "prologue-escape" then -- 5576
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 5578
		elseif self.phase == "prologue-hide" then -- 5578
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 5580
		elseif self.phase == "prologue-wait" then -- 5580
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 5582
		elseif self.phase == "prologue-give" then -- 5582
			parts[#parts + 1] = (("递物 " .. tostring(self.phaseTick)) .. "/") .. tostring(____exports.PROLOGUE_GIVE_TICKS) -- 5584
		else -- 5584
			parts[#parts + 1] = "跟随" -- 5586
		end -- 5586
		if self.paused then -- 5586
			parts[#parts + 1] = "已暂停" -- 5589
		end -- 5589
		return table.concat(parts, " · ") -- 5591
	end -- 5591
	if self.room.key == "street" then -- 5591
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5594
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5595
		if self.paused then -- 5595
			parts[#parts + 1] = "已暂停" -- 5597
		end -- 5597
		return table.concat(parts, " · ") -- 5599
	end -- 5599
	if self.room.key == "gate" then -- 5599
		local ____temp_148 -- 5602
		if self.room.story == nil then -- 5602
			____temp_148 = nil -- 5602
		else -- 5602
			____temp_148 = self.room.story.gate -- 5602
		end -- 5602
		local g = ____temp_148 -- 5602
		if g ~= nil then -- 5602
			parts[#parts + 1] = self:gateLabel() -- 5604
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 5605
				0, -- 5606
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 5606
			))) .. " 秒" -- 5606
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5607
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5608
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 5609
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 5610
			if self.gateFailCount > 0 then -- 5610
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 5612
			end -- 5612
			if self.flash ~= "" then -- 5612
				parts[#parts + 1] = self.flash -- 5615
			end -- 5615
		end -- 5615
		if self.paused then -- 5615
			parts[#parts + 1] = "已暂停" -- 5619
		end -- 5619
		return table.concat(parts, " · ") -- 5621
	end -- 5621
	if self.room.key == "forest" then -- 5621
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5624
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5625
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5626
		if self.caughtT > 0 then -- 5626
			parts[#parts + 1] = "复位中" -- 5628
		end -- 5628
		if self.paused then -- 5628
			parts[#parts + 1] = "已暂停" -- 5631
		end -- 5631
		return table.concat(parts, " · ") -- 5633
	end -- 5633
	if self.room.key == "tower" then -- 5633
		if self.phase == "tower-wait" then -- 5633
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5637
		elseif self.phase == "tower-knock" then -- 5637
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5639
		elseif self.phase == "tower-enter" then -- 5639
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5641
		elseif self.phase == "tower-desk" then -- 5641
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5643
		elseif self.phase == "tower-given" then -- 5643
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5645
		else -- 5645
			parts[#parts + 1] = "片尾" -- 5647
		end -- 5647
		if self.paused then -- 5647
			parts[#parts + 1] = "已暂停" -- 5650
		end -- 5650
		return table.concat(parts, " · ") -- 5652
	end -- 5652
	if self.room.key == "village" then -- 5652
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5655
		if self.hasBottle then -- 5655
			parts[#parts + 1] = "有瓶" -- 5657
		elseif self.bottleFly ~= nil then -- 5657
			parts[#parts + 1] = "瓶在飞" -- 5659
		else -- 5659
			parts[#parts + 1] = "空手" -- 5661
		end -- 5661
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5663
		if self.scavChase then -- 5663
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5665
		end -- 5665
		if self.passed then -- 5665
			parts[#parts + 1] = "已过通行线" -- 5668
		end -- 5668
		if self.paused then -- 5668
			parts[#parts + 1] = "已暂停" -- 5671
		end -- 5671
		return table.concat(parts, " · ") -- 5673
	end -- 5673
	local isChild = self.childMode -- 5676
	if isChild then -- 5676
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5678
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5679
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5680
	else -- 5680
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5682
		if p.rollT > 0 then -- 5682
			parts[#parts + 1] = "翻滚中" -- 5684
		end -- 5684
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5686
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5687
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5688
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5689
	end -- 5689
	if self.checkpoint >= 0 then -- 5689
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5692
	end -- 5692
	if self.paused then -- 5692
		parts[#parts + 1] = "已暂停" -- 5695
	end -- 5695
	return table.concat(parts, " · ") -- 5697
end -- 5565
function Play.prototype.aliveEnemies(self) -- 5701
	local n = 0 -- 5702
	local i = 0 -- 5703
	do -- 5703
		i = 0 -- 5704
		while i < #self.enemies do -- 5704
			if self.enemies[i + 1].alive then -- 5704
				n = n + 1 -- 5706
			end -- 5706
			i = i + 1 -- 5704
		end -- 5704
	end -- 5704
	return n -- 5709
end -- 5701
function Play.prototype.threatened(self) -- 5714
	do -- 5714
		local i = 0 -- 5715
		while i < #self.enemies do -- 5715
			local e = self.enemies[i + 1] -- 5716
			if e.alive and e.warnT > 0 then -- 5716
				return true -- 5718
			end -- 5718
			i = i + 1 -- 5715
		end -- 5715
	end -- 5715
	return false -- 5721
end -- 5714
function Play.prototype.gateSecondsLeft(self) -- 5724
	local ____temp_149 -- 5725
	if self.room.story == nil then -- 5725
		____temp_149 = nil -- 5725
	else -- 5725
		____temp_149 = self.room.story.gate -- 5725
	end -- 5725
	local g = ____temp_149 -- 5725
	if g == nil then -- 5725
		return 0 -- 5727
	end -- 5727
	return math.max( -- 5729
		0, -- 5729
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5729
	) -- 5729
end -- 5724
function Play.prototype.gateLabel(self) -- 5732
	if self.phase == "gate-idle" then -- 5732
		return "待就位" -- 5734
	end -- 5734
	if self.phase == "gate-hold" then -- 5734
		return "守点中" -- 5737
	end -- 5737
	if self.phase == "gate-send" then -- 5737
		return "送别" -- 5740
	end -- 5740
	if self.phase == "gate-farewell" then -- 5740
		return "嘱咐 " .. tostring(self.phaseTick) -- 5743
	end -- 5743
	if self.phase == "gate-count" then -- 5743
		return "数数 " .. tostring(self.countTick) -- 5746
	end -- 5746
	return "她走" -- 5748
end -- 5732
function Play.prototype.dogLabel(self) -- 5752
	if self.dogState == "ear" then -- 5752
		return "转耳" -- 5754
	end -- 5754
	if self.dogState == "chase" then -- 5754
		return "追" -- 5757
	end -- 5757
	if self.dogState == "sniff" then -- 5757
		return "停" -- 5760
	end -- 5760
	if self.dogState == "back" then -- 5760
		return "回线" -- 5763
	end -- 5763
	return "巡逻" -- 5765
end -- 5752
function Play.prototype.doorXOf(self) -- 5768
	local ____temp_150 -- 5769
	if self.room.story == nil then -- 5769
		____temp_150 = nil -- 5769
	else -- 5769
		____temp_150 = self.room.story.tower -- 5769
	end -- 5769
	local t = ____temp_150 -- 5769
	return t == nil and 0 or t.doorX -- 5770
end -- 5768
function Play.prototype.scavLabel(self) -- 5774
	if self.scavState == "chase" then -- 5774
		return "追" -- 5776
	end -- 5776
	if self.scavState == "turn" then -- 5776
		return "转头" -- 5779
	end -- 5779
	if self.scavState == "walk" then -- 5779
		return "赶来" -- 5782
	end -- 5782
	if self.scavState == "stall" then -- 5782
		return "停住" -- 5785
	end -- 5785
	if self.scavState == "back" then -- 5785
		return "回位" -- 5788
	end -- 5788
	return "巡逻" -- 5790
end -- 5774
function Play.prototype.hintText(self) -- 5794
	if self.paused then -- 5794
		return "Esc 继续 · R 重置" -- 5796
	end -- 5796
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5796
		if self:threatened() then -- 5796
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5802
		end -- 5802
		if self.coverHug then -- 5802
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5805
		end -- 5805
		if self.coverNear then -- 5805
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5808
		end -- 5808
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5810
	end -- 5810
	if self.flash ~= "" then -- 5810
		return self.flash -- 5813
	end -- 5813
	if self.room.key == "prologue" then -- 5813
		if self.phase == "prologue-wake" then -- 5813
			return "父亲在门外唤 · 小满睁眼" -- 5817
		end -- 5817
		if self.phase == "prologue-shadow" then -- 5817
			return "墙上两道人影 · 碗滚到脚边" -- 5820
		end -- 5820
		if self.phase == "prologue-escape" then -- 5820
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5823
		end -- 5823
		if self.phase == "prologue-hide" then -- 5823
			return "柜门合上 · 屏住呼吸" -- 5826
		end -- 5826
		if self.phase == "prologue-wait" then -- 5826
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5829
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5830
		end -- 5830
		if self.phase == "prologue-give" then -- 5830
			return ((("递物 " .. tostring(self.phaseTick)) .. " / ") .. tostring(____exports.PROLOGUE_GIVE_TICKS)) .. " 拍 · 站着别动" -- 5833
		end -- 5833
		return "她跟着你了 · 两人一起走到门口 680" -- 5835
	end -- 5835
	if self.room.key == "street" then -- 5835
		if self:aliveEnemies() > 0 then -- 5835
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5839
		end -- 5839
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5841
	end -- 5841
	if self.room.key == "gate" then -- 5841
		local ____temp_151 -- 5844
		if self.room.story == nil then -- 5844
			____temp_151 = nil -- 5844
		else -- 5844
			____temp_151 = self.room.story.gate -- 5844
		end -- 5844
		local g = ____temp_151 -- 5844
		if g ~= nil then -- 5844
			if self.phase == "gate-idle" then -- 5844
				if self.gateNeedConfirm then -- 5844
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5848
				end -- 5848
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5850
			end -- 5850
			if self.phase == "gate-hold" then -- 5850
				if self.coveredFlash > 0 then -- 5850
					return "掩体挡下了这一枪 · 别露头" -- 5854
				end -- 5854
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5856
			end -- 5856
			if self.phase == "gate-send" then -- 5856
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5859
			end -- 5859
			if self.phase == "gate-farewell" then -- 5859
				return "城门送别 · 嘱咐她慢慢数到二十" -- 5862
			end -- 5862
			if self.phase == "gate-count" then -- 5862
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5862
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5866
				end -- 5866
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5868
			end -- 5868
			return "她自己走 · 跟着出城门 1120" -- 5870
		end -- 5870
	end -- 5870
	if self.room.key == "forest" then -- 5870
		if self.dogState == "chase" then -- 5870
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5875
		end -- 5875
		if self.dogState == "ear" then -- 5875
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5878
		end -- 5878
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5880
	end -- 5880
	if self.room.key == "tower" then -- 5880
		if self.phase == "tower-wait" then -- 5880
			return "走到门前 445 点一次 E 敲两下" -- 5884
		end -- 5884
		if self.phase == "tower-knock" then -- 5884
			return "敲两下 · 等门开" -- 5887
		end -- 5887
		if self.phase == "tower-given" then -- 5887
			return "递交针套和纸条 · 看登记簿最后一行" -- 5890
		end -- 5890
		return "片尾 · 点 E 再玩一次，回到序章" -- 5892
	end -- 5892
	if self.room.key == "village" then -- 5892
		if self.bottleFly ~= nil then -- 5892
			return "等瓶子落地 · 触地才发声" -- 5896
		end -- 5896
		if self.hasBottle then -- 5896
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5899
		end -- 5899
		if self.passed then -- 5899
			return "已过第一院 · R 重置可再来一遍" -- 5902
		end -- 5902
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5904
	end -- 5904
	if self.room.key == "outside" then -- 5904
		if self.focusCart then -- 5904
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5908
		end -- 5908
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5910
	end -- 5910
	if self.escort.state == "frozen" then -- 5910
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5910
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5914
		end -- 5914
		return "小满吓住了 · 走过去，靠近再点 E" -- 5916
	end -- 5916
	if self.escort.state == "calming" then -- 5916
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5919
	end -- 5919
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5921
end -- 5794
return ____exports -- 5794