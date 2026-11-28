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
function makeActor(room, index) -- 5886
	local sp = room.spawns -- 5887
	if index < 0 or index >= #sp then -- 5887
		return { -- 5889
			x = 0, -- 5889
			y = 0, -- 5889
			depth = 0, -- 5889
			depthSpeed = 0, -- 5889
			vx = 0, -- 5889
			vy = 0, -- 5889
			w = CHILD_W, -- 5889
			h = CHILD_H, -- 5889
			onGround = true, -- 5889
			facing = 1, -- 5889
			crouch = false, -- 5889
			rollT = 0, -- 5889
			covered = false, -- 5889
			alive = false -- 5889
		} -- 5889
	end -- 5889
	local s = sp[index + 1] -- 5891
	local child = s.h < SOLDIER_H -- 5892
	local ground = room.depth -- 5893
	local depth = ground == nil and 0 or math.max( -- 5894
		ground.min, -- 5894
		math.min(ground.max, s.depth or 0) -- 5894
	) -- 5894
	return { -- 5895
		x = s.x, -- 5896
		y = s.y, -- 5896
		depth = depth, -- 5896
		depthSpeed = 0, -- 5896
		vx = 0, -- 5896
		vy = 0, -- 5896
		w = child and CHILD_W or SOLDIER_W, -- 5897
		h = child and CHILD_H or SOLDIER_H, -- 5898
		onGround = true, -- 5899
		facing = 1, -- 5899
		crouch = false, -- 5899
		rollT = 0, -- 5899
		covered = false, -- 5899
		alive = true -- 5899
	} -- 5899
end -- 5899
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5904
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5905
end -- 5904
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5912
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5913
end -- 5912
function rayInterval(origin, direction, min, max) -- 5920
	if direction == 0 then -- 5920
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5922
	end -- 5922
	local a = (min - origin) / direction -- 5924
	local b = (max - origin) / direction -- 5925
	return { -- 5926
		min = math.min(a, b), -- 5926
		max = math.max(a, b) -- 5926
	} -- 5926
end -- 5926
function hitBox(ray, box) -- 5930
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5931
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5932
	local enter = math.max(0, x.min, y.min) -- 5933
	local leave = math.min(99999, x.max, y.max) -- 5934
	if box.depth ~= nil then -- 5934
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5936
		enter = math.max(enter, depth.min) -- 5937
		leave = math.min(leave, depth.max) -- 5938
	end -- 5938
	return leave >= enter and enter or -1 -- 5940
end -- 5940
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
function Play.prototype.____constructor(self, room, resume, run) -- 652
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
	self.redCartMemoryT = 0 -- 402
	self.footHintT = 0 -- 404
	self.ditchHinted = false -- 406
	self.forestPath = "" -- 408
	self.waterSeen = false -- 410
	self.scavStallBonus = 0 -- 412
	self.intentGateReunionHold = false -- 414
	self.pendingMuseumIntentTarget = "" -- 416
	self.scavX = 0 -- 418
	self.scavDir = 1 -- 419
	self.scavState = "patrol" -- 420
	self.scavT = 0 -- 421
	self.scavTargetX = 0 -- 422
	self.passed = false -- 424
	self.childMode = false -- 428
	self.phase = "" -- 430
	self.phaseTick = 0 -- 432
	self.gateTick = 0 -- 434
	self.countTick = 0 -- 436
	self.countArmed = false -- 438
	self.countPrevMove = 0 -- 440
	self.caughtT = 0 -- 442
	self.hp = 3 -- 444
	self.maxHp = 3 -- 445
	self.invulnT = 0 -- 451
	self.partnerStuck = 0 -- 453
	self.partnerLaneIdx = 0 -- 455
	self.partnerLaneHold = 0 -- 456
	self.coveredFlash = 0 -- 458
	self.coverHug = false -- 460
	self.coverNear = false -- 462
	self.coverEntity = "" -- 464
	self.coverBlocking = false -- 466
	self.gateNeedConfirm = false -- 468
	self.gateRestartArmed = true -- 470
	self.bottleAimX = -1 -- 472
	self.bottleAimY = 0 -- 473
	self.bottleSurfaceY = -1 -- 475
	self.bottleLandY = 0 -- 477
	self.events = {} -- 479
	self.eventSeq = 0 -- 481
	self.dogX = 0 -- 483
	self.dogDir = 1 -- 484
	self.dogState = "patrol" -- 485
	self.dogT = 0 -- 486
	self.dogTargetX = 0 -- 487
	self.scavSee = 0 -- 489
	self.scavChase = false -- 490
	self.gateSpawned = 0 -- 492
	self.gateFailCount = 0 -- 494
	self.isCampaign = false -- 498
	self.archiveDirty = false -- 506
	self.sessionDirty = false -- 508
	self.restartStory = false -- 510
	self.wellOpen = false -- 512
	self.wellX = 430 -- 514
	self.wellTaken = false -- 516
	self.museumReturn = false -- 518
	self.endingLines = {"", ""} -- 520
	self.towerDoorOpen = false -- 522
	self.towerHanded = false -- 523
	self.deskHold = 0 -- 524
	self.towerEndMustRelease = false -- 526
	self.equippedWeapon = "standard_gun" -- 539
	self.craftBench = { -- 541
		active = false, -- 542
		firstCraftDone = false, -- 543
		justCraftedTimer = 0, -- 544
		inventory = {}, -- 545
		recipes = {}, -- 546
		equippedWeapon = "standard_gun" -- 547
	} -- 547
	self.handledCraftRequests = {} -- 550
	self.benchReach = 48 -- 552
	self.pickups = {} -- 556
	self.reloadT = 0 -- 558
	self.objectiveDone = false -- 562
	self.hint = "" -- 564
	self.roomStartTick = 0 -- 566
	self.cartHitT = 0 -- 568
	self.cartExposed = false -- 569
	self.storyRoute = "" -- 573
	self.storySettled = false -- 575
	self.hpAtGate = -1 -- 577
	self.maxHpAtGate = -1 -- 578
	self.handTicks = 0 -- 580
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 582
	self.handArmed = false -- 584
	self.handDone = false -- 586
	self.lineSaid = false -- 587
	self.tied = false -- 589
	self.pathDone = false -- 591
	self.carryOn = false -- 593
	self.escortDone = false -- 595
	self.escapeDuration = ____exports.PROLOGUE_ESCAPE_TICKS / 60 -- 599
	self.escapeRemaining = 0 -- 601
	self.escapeRetryCount = 0 -- 603
	self.introTick = 0 -- 605
	self.reloadOpen = false -- 609
	self.reloadAnswerTicks = 0 -- 611
	self.reloadWorldTicks = 0 -- 613
	self.reloadPath = {RELOAD_START} -- 615
	self.reloadPendingEffect = "" -- 617
	self.reloadTryCount = 0 -- 619
	self.talentModalActive = false -- 622
	self.useEscortDeathSummary = false -- 623
	self.escortFailed = false -- 624
	self.escortFailedTicks = 0 -- 625
	self.escortSummary = nil -- 626
	self.fieldWedgeSeq = 0 -- 634
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
	local story = self.run.story -- 660
	local savedEq = story.equippedWeapon -- 661
	if savedEq == ARTIFACT_WEAPON_ID and self.archive.artifactOwned then -- 661
		self.equippedWeapon = ARTIFACT_WEAPON_ID -- 663
	elseif savedEq == "standard_gun" or savedEq ~= "" and savedEq == story.craftedWeapon then -- 663
		self.equippedWeapon = savedEq -- 665
	else -- 665
		self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 667
	end -- 667
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
end -- 652
function Play.prototype.towerEndReady(self) -- 529
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 530
	return self.room.key == "tower" and self.phase == "tower-end" and self.phaseTick >= waitTicks and not self.towerEndMustRelease -- 531
end -- 529
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
	if self.room.key == "escort3" and self.storyRoute == "soldier" then -- 815
		self:triggerDeferredEscort3Draft() -- 817
	end -- 817
end -- 805
function Play.prototype.triggerDeferredEscort3Draft(self) -- 822
	if self.room.key ~= "escort3" or self.storyRoute ~= "soldier" or self.run.finished then -- 822
		return false -- 824
	end -- 824
	if self.run.story.talents == nil then -- 824
		self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 827
	end -- 827
	local st = self.run.story.talents -- 829
	if not st.deferred and st.room == "escort3" then -- 829
		return false -- 831
	end -- 831
	draftTalentOffers(st, "escort3", self.equippedWeapon) -- 833
	if self.useEscortDeathSummary and #st.offers > 0 then -- 833
		self.talentModalActive = true -- 835
	end -- 835
	self.sessionDirty = true -- 837
	return #st.offers > 0 -- 838
end -- 822
function Play.prototype.openTalentDraft(self) -- 842
	if #self:getStoryTalentOffers() > 0 and not self.craftBench.active and not self.escortFailed then -- 842
		self.talentModalActive = true -- 844
	end -- 844
end -- 842
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 852
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 852
		return false -- 854
	end -- 854
	local recipe = findRecipe(recipeId) -- 856
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 856
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 858
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 859
		return false -- 860
	end -- 860
	local missing = missingMaterials(self.run.inventory, recipe) -- 862
	if #missing > 0 then -- 862
		self:flashSet( -- 864
			"缺料 · " .. table.concat(missing, " / "), -- 864
			1.6 -- 864
		) -- 864
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 865
		return false -- 866
	end -- 866
	payMaterials(self.run.inventory, recipe) -- 868
	self.handledCraftRequests[requestId] = true -- 869
	self.run.story.craftedWeapon = recipe.id -- 870
	self.run.story.equippedWeapon = recipe.id -- 871
	self.equippedWeapon = recipe.id -- 872
	self.sessionDirty = true -- 873
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 874
	self.craftBench.firstCraftDone = true -- 875
	self:syncCraftBench() -- 876
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 877
	self:log("改制 " .. recipe.id) -- 878
	self:emit("benchCraft", { -- 879
		recipeId = recipe.id, -- 880
		weapon = recipe.id, -- 881
		effect = recipe.enhancedEffect, -- 882
		wood = self.run.inventory.wood, -- 883
		bell = self.run.inventory.bell -- 884
	}) -- 884
	return true -- 886
end -- 852
function Play.prototype.equipWeapon(self, weaponId) -- 890
	local artifactOk = weaponId == ARTIFACT_WEAPON_ID and self.archive.artifactOwned -- 891
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId and not artifactOk then -- 891
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 893
		return false -- 894
	end -- 894
	self.equippedWeapon = weaponId -- 896
	self.run.story.equippedWeapon = weaponId -- 897
	self.sessionDirty = true -- 898
	self:syncCraftBench() -- 899
	self:flashSet( -- 900
		"已装备 " .. weaponNameOf(weaponId), -- 900
		1 -- 900
	) -- 900
	self:emit("benchEquip", {weapon = weaponId}) -- 901
	return true -- 902
end -- 890
function Play.prototype.toggleArtifactWeapon(self) -- 906
	if not self.archive.artifactOwned or self.childMode then -- 906
		return false -- 908
	end -- 908
	if self.equippedWeapon == ARTIFACT_WEAPON_ID then -- 908
		local fallback = self.run.story.craftedWeapon ~= "" and self.run.story.craftedWeapon or "standard_gun" -- 911
		return self:equipWeapon(fallback) -- 912
	end -- 912
	return self:equipWeapon(ARTIFACT_WEAPON_ID) -- 914
end -- 906
function Play.prototype.exportSession(self) -- 918
	self:syncStory() -- 919
	local story = self.run.story -- 920
	local inv = self.run.inventory -- 921
	local taken = {} -- 922
	for k in pairs(self.run.taken) do -- 923
		if self.run.taken[k] == true then -- 923
			taken[#taken + 1] = k -- 925
		end -- 925
	end -- 925
	local segments = {} -- 928
	for k in pairs(story.segments) do -- 929
		if story.segments[k] == true then -- 929
			segments[#segments + 1] = k -- 931
		end -- 931
	end -- 931
	local props = {} -- 934
	for k in pairs(self.run.props) do -- 935
		local st = self.run.props[k] -- 936
		if st ~= nil then -- 936
			props[#props + 1] = (((((((k .. ":") .. (st.broken and "1" or "0")) .. ":") .. tostring(math.floor(st.hp + 0.5))) .. ":") .. (st.wedge and "1" or "0")) .. ":") .. (st.revealed == true and "1" or "0") -- 938
		end -- 938
	end -- 938
	local talentRanks = {} -- 947
	if story.talents ~= nil then -- 947
		local ti = 0 -- 949
		do -- 949
			ti = 0 -- 950
			while ti < #ALL_TALENTS do -- 950
				local tid = ALL_TALENTS[ti + 1] -- 951
				local rk = story.talents.ranks[tid] or 0 -- 952
				if rk > 0 then -- 952
					talentRanks[#talentRanks + 1] = (tid .. ":") .. tostring(rk) -- 954
				end -- 954
				ti = ti + 1 -- 950
			end -- 950
		end -- 950
	end -- 950
	local ____temp_4 = self.escortFailed and "escort1" or self.room.key -- 960
	local ____temp_5 = self.escortFailed and 0 or self.checkpoint -- 961
	local ____self_run_seed_6 = self.run.seed -- 962
	local ____story_route_7 = story.route -- 963
	local ____story_hp_8 = story.hp -- 964
	local ____story_maxHp_9 = story.maxHp -- 965
	local ____story_hpAtGate_10 = story.hpAtGate -- 966
	local ____story_maxHpAtGate_11 = story.maxHpAtGate -- 967
	local ____story_settled_12 = story.settled -- 968
	local ____self_phase_13 = self.phase -- 969
	local ____story_countTick_14 = story.countTick -- 970
	local ____story_phaseTick_15 = story.phaseTick -- 971
	local ____story_handTicks_16 = story.handTicks -- 972
	local ____story_handDone_17 = story.handDone -- 973
	local ____story_lineSaid_18 = story.lineSaid -- 974
	local ____story_tied_19 = story.tied -- 975
	local ____story_carry_20 = story.carry -- 976
	local ____story_escortDone_21 = story.escortDone -- 977
	local ____story_craftedWeapon_22 = story.craftedWeapon -- 978
	local ____self_equippedWeapon_23 = self.equippedWeapon -- 979
	local ____inv_wood_24 = inv.wood -- 980
	local ____inv_bell_25 = inv.bell -- 981
	local ____inv_scrap_26 = inv.scrap -- 982
	local ____inv_wedge_27 = inv.wedge -- 983
	local ____inv_ammo_28 = inv.ammo -- 984
	local ____inv_shield_29 = inv.shield -- 985
	local ____inv_pass_30 = inv.pass -- 986
	local ____inv_quickbelt_31 = inv.quickbelt -- 987
	local ____taken_32 = taken -- 988
	local ____segments_33 = segments -- 989
	local ____self_cartAxle_34 = self.cartAxle -- 990
	local ____self_cartDocked_35 = self.cartDocked -- 991
	local ____self_run_route_36 = self.run.route -- 992
	local ____self_run_joined_37 = self.run.joined -- 993
	local ____self_run_c1Latch_38 = self.run.c1Latch -- 994
	local ____self_run_c2Latch_39 = self.run.c2Latch -- 995
	local ____temp_40 = story.talents ~= nil and story.talents.randomState or 0 -- 996
	local ____temp_41 = story.talents ~= nil and story.talents.room or "" -- 997
	local ____temp_42 = story.talents ~= nil and __TS__ArraySlice(story.talents.offers) or ({}) -- 998
	local ____talentRanks_43 = talentRanks -- 999
	local ____temp_44 = story.talents ~= nil and story.talents.attempt or 1 -- 1000
	local ____temp_45 = story.talents ~= nil and story.talents.variant or 0 -- 1001
	local ____temp_0 -- 1002
	if story.talents ~= nil then -- 1002
		____temp_0 = story.talents.deferred -- 1002
	else -- 1002
		____temp_0 = false -- 1002
	end -- 1002
	local ____temp_46 = story.talents ~= nil and story.talents.ranks.vitality or 0 -- 1003
	local ____temp_47 = story.talents ~= nil and story.talents.ranks.focus or 0 -- 1004
	local ____temp_48 = story.talents ~= nil and story.talents.ranks.guard or 0 -- 1005
	local ____temp_49 = story.talents ~= nil and story.talents.ranks.salvage or 0 -- 1006
	local ____props_50 = props -- 1007
	local ____table_escortFailed_1 -- 1008
	if self.escortFailed then -- 1008
		____table_escortFailed_1 = nil -- 1008
	else -- 1008
		____table_escortFailed_1 = self.player.x -- 1008
	end -- 1008
	local ____table_escortFailed_2 -- 1009
	if self.escortFailed then -- 1009
		____table_escortFailed_2 = nil -- 1009
	else -- 1009
		____table_escortFailed_2 = self.player.y -- 1009
	end -- 1009
	local ____table_escortFailed_3 -- 1010
	if self.escortFailed then -- 1010
		____table_escortFailed_3 = nil -- 1010
	else -- 1010
		____table_escortFailed_3 = self.player.depth -- 1010
	end -- 1010
	return { -- 958
		roomKey = ____temp_4, -- 960
		checkpoint = ____temp_5, -- 961
		seed = ____self_run_seed_6, -- 962
		route = ____story_route_7, -- 963
		hp = ____story_hp_8, -- 964
		maxHp = ____story_maxHp_9, -- 965
		hpAtGate = ____story_hpAtGate_10, -- 966
		maxHpAtGate = ____story_maxHpAtGate_11, -- 967
		settled = ____story_settled_12, -- 968
		phase = ____self_phase_13, -- 969
		countTick = ____story_countTick_14, -- 970
		phaseTick = ____story_phaseTick_15, -- 971
		handTicks = ____story_handTicks_16, -- 972
		handDone = ____story_handDone_17, -- 973
		lineSaid = ____story_lineSaid_18, -- 974
		tied = ____story_tied_19, -- 975
		carry = ____story_carry_20, -- 976
		escortDone = ____story_escortDone_21, -- 977
		craftedWeapon = ____story_craftedWeapon_22, -- 978
		equippedWeapon = ____self_equippedWeapon_23, -- 979
		wood = ____inv_wood_24, -- 980
		bell = ____inv_bell_25, -- 981
		scrap = ____inv_scrap_26, -- 982
		wedge = ____inv_wedge_27, -- 983
		ammo = ____inv_ammo_28, -- 984
		shield = ____inv_shield_29, -- 985
		pass = ____inv_pass_30, -- 986
		quickbelt = ____inv_quickbelt_31, -- 987
		taken = ____taken_32, -- 988
		segments = ____segments_33, -- 989
		cartAxle = ____self_cartAxle_34, -- 990
		cartDocked = ____self_cartDocked_35, -- 991
		campaignRoute = ____self_run_route_36, -- 992
		joined = ____self_run_joined_37, -- 993
		c1Latch = ____self_run_c1Latch_38, -- 994
		c2Latch = ____self_run_c2Latch_39, -- 995
		talentSeed = ____temp_40, -- 996
		talentRoom = ____temp_41, -- 997
		talentOffers = ____temp_42, -- 998
		talentRanks = ____talentRanks_43, -- 999
		escortAttempt = ____temp_44, -- 1000
		escortVariant = ____temp_45, -- 1001
		talentDeferred = ____temp_0, -- 1002
		talentVitality = ____temp_46, -- 1003
		talentReload = ____temp_47, -- 1004
		talentGuard = ____temp_48, -- 1005
		talentCraft = ____temp_49, -- 1006
		props = ____props_50, -- 1007
		playerX = ____table_escortFailed_1, -- 1008
		playerY = ____table_escortFailed_2, -- 1009
		playerDepth = ____table_escortFailed_3, -- 1010
		gateTick = self.gateTick, -- 1011
		hasBottle = self.hasBottle, -- 1012
		villagePassed = self.passed -- 1013
	} -- 1013
end -- 918
function Play.prototype.submitFeIntent(self, intent) -- 1021
	local kind = intent == nil and "" or intent.kind -- 1022
	if kind == "gateReunionHold" then -- 1022
		if self.room.key ~= "gate" or self.phase ~= "gate-wait" and self.phase ~= "gate-count" then -- 1022
			return false -- 1025
		end -- 1025
		local holding = intent.holding == true -- 1027
		self.intentGateReunionHold = holding -- 1028
		if not holding and self.phase == "gate-wait" then -- 1028
			if self.handTicks > 0 then -- 1028
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1031
			end -- 1031
			self.handTicks = 0 -- 1033
			self.handArmed = true -- 1034
		end -- 1034
		return true -- 1036
	end -- 1036
	if kind == "reloadOpen" then -- 1036
		local camp = self.room.campaign -- 1039
		if camp == nil or camp.reloadPuzzle ~= true or self.reloadOpen then -- 1039
			return false -- 1041
		end -- 1041
		self:beginReload() -- 1043
		return self.reloadOpen -- 1044
	end -- 1044
	if kind == "reloadPathPreview" then -- 1044
		local path = intent.path -- 1047
		return type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) -- 1048
	end -- 1048
	if kind == "reloadTapNode" then -- 1048
		local node = intent.node -- 1051
		if type(node) == "number" then -- 1051
			self:reloadTapNode(node) -- 1053
			return true -- 1054
		end -- 1054
		return false -- 1056
	end -- 1056
	if kind == "reloadPathCommit" then -- 1056
		local path = intent.path -- 1059
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 1059
			local list = path -- 1061
			local i = 0 -- 1062
			do -- 1062
				i = 0 -- 1063
				while i < #list do -- 1063
					do -- 1063
						if i == 0 and list[i + 1] == RELOAD_START then -- 1063
							goto __continue85 -- 1065
						end -- 1065
						self:reloadTapNode(list[i + 1]) -- 1067
					end -- 1067
					::__continue85:: -- 1067
					i = i + 1 -- 1063
				end -- 1063
			end -- 1063
			return true -- 1069
		end -- 1069
		return false -- 1071
	end -- 1071
	if kind == "reloadCancel" then -- 1071
		self:closeReloadPuzzle() -- 1074
		return true -- 1075
	end -- 1075
	if kind == "craftSubmit" then -- 1075
		local recipeId = intent.recipeId -- 1078
		local requestId = intent.requestId -- 1079
		if type(recipeId) == "string" and type(requestId) == "string" then -- 1079
			return self:craftAtBench(recipeId, requestId) -- 1081
		end -- 1081
		return false -- 1083
	end -- 1083
	if kind == "craftEquip" then -- 1083
		local weaponId = intent.weaponId -- 1086
		if type(weaponId) == "string" then -- 1086
			return self:equipWeapon(weaponId) -- 1088
		end -- 1088
		return false -- 1090
	end -- 1090
	if kind == "craftClose" then -- 1090
		self:closeCraftBench() -- 1093
		return true -- 1094
	end -- 1094
	if kind == "chooseTalent" then -- 1094
		local slot = intent.slot -- 1097
		if type(slot) == "number" then -- 1097
			return self:chooseTalent(slot) -- 1099
		end -- 1099
		return false -- 1101
	end -- 1101
	if kind == "wellPick" then -- 1101
		return self:pickWell() -- 1104
	end -- 1104
	if kind == "museumInteract" then -- 1104
		local target = type(intent.target) == "string" and intent.target or "" -- 1107
		if target == "well_pickup" or target == "well" then -- 1107
			return self:pickWell() -- 1109
		end -- 1109
		if self.room.key ~= "museum" then -- 1109
			return false -- 1112
		end -- 1112
		return self:triggerMuseumIntent(target) -- 1114
	end -- 1114
	return false -- 1116
end -- 1021
function Play.prototype.triggerMuseumIntent(self, target) -- 1120
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 1121
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 1124
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 1125
	if self.phase == "museum-cabinet" then -- 1125
		if target == "enter_hall" or (target == "" or target == "cabinet" or target == "weapon_case") and atCase then -- 1125
			self.pendingMuseumIntentTarget = "cabinet" -- 1128
			return true -- 1129
		end -- 1129
	end -- 1129
	if self.phase == "museum-hall" then -- 1129
		if (target == "lamp_turn" or target == "lamp" or target == "west_lamp") and nearLamp then -- 1129
			self.pendingMuseumIntentTarget = "lamp_direct" -- 1134
			return true -- 1135
		end -- 1135
		if (target == "" or target == "hall" or target == "corridor") and self.player.x >= self.ox + mu.hallX then -- 1135
			self.pendingMuseumIntentTarget = "hall" -- 1138
			return true -- 1139
		end -- 1139
	end -- 1139
	if self.phase == "museum-lamp" and (target == "" or target == "lamp" or target == "west_lamp" or target == "lamp_turn") and nearLamp then -- 1139
		self.pendingMuseumIntentTarget = "lamp" -- 1145
		return true -- 1146
	end -- 1146
	if self.phase == "museum-return" then -- 1146
		if target == "begin_return_cabinet" or (target == "" or target == "return_cabinet" or target == "cabinet" or target == "return") and atCase then -- 1146
			self.pendingMuseumIntentTarget = "return_cabinet" -- 1151
			return true -- 1152
		end -- 1152
	end -- 1152
	if self.phase == "museum-done" and (target == "" or target == "return_cabinet" or target == "return") then -- 1152
		self.pendingMuseumIntentTarget = "done" -- 1156
		return true -- 1157
	end -- 1157
	return false -- 1159
end -- 1120
function Play.prototype.captureCheckpoint(self, id) -- 1163
	local inv = self.run.inventory -- 1164
	self.checkpointSnap = { -- 1165
		id = id, -- 1166
		wood = inv.wood, -- 1167
		bell = inv.bell, -- 1168
		scrap = inv.scrap, -- 1169
		wedge = inv.wedge, -- 1170
		ammo = inv.ammo, -- 1171
		shield = inv.shield, -- 1172
		pass = inv.pass, -- 1173
		quickbelt = inv.quickbelt, -- 1174
		crafted = self.run.story.craftedWeapon, -- 1175
		equipped = self.equippedWeapon, -- 1176
		carry = self.carryOn -- 1177
	} -- 1177
	self.run.story.cp = self.checkpointSnap -- 1179
end -- 1163
function Play.prototype.applyCheckpointSnap(self, id) -- 1183
	local snap = self.run.story.cp -- 1184
	if snap == nil or snap.id ~= id then -- 1184
		return false -- 1186
	end -- 1186
	self.checkpointSnap = snap -- 1188
	local inv = self.run.inventory -- 1189
	inv.wood = snap.wood -- 1190
	inv.bell = snap.bell -- 1191
	inv.scrap = snap.scrap -- 1192
	inv.wedge = snap.wedge -- 1193
	inv.ammo = snap.ammo -- 1194
	inv.shield = snap.shield -- 1195
	inv.pass = snap.pass -- 1196
	inv.quickbelt = snap.quickbelt -- 1197
	self.run.story.craftedWeapon = snap.crafted -- 1198
	self.equippedWeapon = snap.equipped -- 1199
	self.run.story.equippedWeapon = snap.equipped -- 1200
	self.carryOn = snap.carry -- 1201
	self.run.story.carry = snap.carry -- 1202
	self.craftBench.active = false -- 1203
	self:syncCraftBench() -- 1204
	return true -- 1205
end -- 1183
function Play.prototype.restoreStory(self) -- 1208
	local story = self.run.story -- 1209
	if story == nil then -- 1209
		return -- 1211
	end -- 1211
	if story.maxHp > 0 then -- 1211
		self.maxHp = story.maxHp -- 1214
		self.hp = math.max( -- 1215
			1, -- 1215
			math.min(story.hp, story.maxHp) -- 1215
		) -- 1215
	end -- 1215
	self.storyRoute = story.route -- 1217
	self.storySettled = story.settled -- 1218
	self.hpAtGate = story.hpAtGate -- 1219
	self.maxHpAtGate = story.maxHpAtGate -- 1220
	self.handDone = story.handDone -- 1221
	self.lineSaid = story.lineSaid -- 1222
	self.tied = story.handDone -- 1223
	self.carryOn = story.carry or story.route == "soldier" and (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 1224
	self.museumReturn = story.museumReturn -- 1225
	story.museumReturn = false -- 1226
	self.escortDone = story.escortDone -- 1227
	self:syncCraftBench() -- 1228
	if self.room.key == "outside" and story.segments.outside_cart == true then -- 1228
		self.cartAxle = self.room.cart.endX -- 1230
		self.cartDocked = true -- 1231
	end -- 1231
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 1233
	self.waterSeen = story.segments.water_lantern == true -- 1235
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 1235
		self:applyCheckpointSnap(self.checkpoint) -- 1238
	end -- 1238
	if self.room.key == "tower" and story.route == "soldier" then -- 1238
		self.carryOn = false -- 1242
		self.run.story.carry = false -- 1243
		self.player.w = SOLDIER_W -- 1244
		self.player.h = SOLDIER_H -- 1245
		self.player.x = math.max(self.ox + 422, self.player.x) -- 1246
		self.partner = { -- 1247
			x = math.max(self.ox + 408, self.player.x - 24), -- 1248
			y = 0, -- 1249
			depth = 0, -- 1250
			depthSpeed = 0, -- 1251
			vx = 0, -- 1252
			vy = 0, -- 1253
			w = CHILD_W, -- 1254
			h = CHILD_H, -- 1255
			onGround = true, -- 1256
			facing = 1, -- 1257
			crouch = false, -- 1258
			rollT = 0, -- 1259
			covered = false, -- 1260
			alive = true -- 1261
		} -- 1261
	end -- 1261
	if self.room.key == "tower" then -- 1261
		if story.segments.tower_door == true then -- 1261
			self:openTowerDoor() -- 1267
		end -- 1267
		self.towerHanded = story.segments.tower_handover == true -- 1269
		self.deskHold = 0 -- 1270
		if story.phase == "tower-enter" or story.phase == "tower-desk" or story.phase == "tower-given" then -- 1270
			self.phase = story.phase -- 1272
			self.phaseTick = 0 -- 1273
			if story.phase == "tower-desk" or story.phase == "tower-given" then -- 1273
				self.player.x = self.ox + 605 -- 1275
				self.player.y = 0 -- 1276
				if story.route == "soldier" and self.partner.alive then -- 1276
					self.partner.x = self.ox + 568 -- 1278
					self.partner.y = 0 -- 1279
					self.partner.facing = 1 -- 1280
				end -- 1280
			end -- 1280
		end -- 1280
	end -- 1280
	if self.room.key == "prologue" then -- 1280
		local ph = story.phase -- 1287
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 1287
			self.phase = ph -- 1289
			self.phaseTick = story.phaseTick -- 1290
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 1291
			self.player.y = 0 -- 1292
			self.player.depth = 0 -- 1293
			self.player.vx = 0 -- 1294
			self.partner.x = self.ox + 300 -- 1295
			self.partner.y = 0 -- 1296
			self.partner.depth = 0 -- 1297
			self.partner.vx = 0 -- 1298
			self.partner.alive = true -- 1299
			if ph == "prologue-follow" then -- 1299
				self.partner.crouch = false -- 1301
				self.partner.h = CHILD_H -- 1302
			else -- 1302
				self.partner.crouch = true -- 1304
				self.partner.h = CHILD_CROUCH_H -- 1305
			end -- 1305
			self.cam.x = self.player.x -- 1307
		end -- 1307
		return -- 1309
	end -- 1309
	if self.room.key ~= "gate" then -- 1309
		return -- 1312
	end -- 1312
	local ____temp_51 -- 1314
	if self.room.story == nil then -- 1314
		____temp_51 = nil -- 1314
	else -- 1314
		____temp_51 = self.room.story.gate -- 1314
	end -- 1314
	local g = ____temp_51 -- 1314
	if g == nil then -- 1314
		return -- 1316
	end -- 1316
	if story.phase == "gate-send" then -- 1316
		self.phase = "gate-send" -- 1320
		self.gateTick = g.holdTicks -- 1321
		self.gateSpawned = 4 -- 1322
		self.enemies = {} -- 1323
		self.player.x = self.ox + g.doorX - 40 -- 1324
		self.player.y = 0 -- 1325
		self.player.depth = 0 -- 1326
		self.player.vx = 0 -- 1327
		self.player.vy = 0 -- 1328
		self.player.onGround = true -- 1329
		self.partner.x = self.ox + g.waitX -- 1330
		self.partner.y = 0 -- 1331
		self.partner.depth = 0 -- 1332
		self.partner.alive = true -- 1333
		self.cam.x = self.player.x -- 1334
		self.handTicks = 0 -- 1335
		self.handArmed = false -- 1336
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1337
		return -- 1338
	end -- 1338
	if not story.settled then -- 1338
		return -- 1341
	end -- 1341
	self.gateTick = g.holdTicks -- 1344
	self.gateSpawned = 4 -- 1345
	self.enemies = {} -- 1346
	if story.phase == "gate-farewell" or story.phase == "gate-count" or story.phase == "gate-walk" then -- 1346
		self.phase = story.phase == "gate-farewell" and "gate-count" or story.phase -- 1348
		self.countTick = story.phase == "gate-farewell" and 0 or math.max(story.countTick, 0) -- 1349
		self:swapToChild(g.doorX + 30) -- 1350
		self.countPrevMove = 0 -- 1351
		self.countArmed = false -- 1352
		return -- 1353
	end -- 1353
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1353
		self.phase = story.phase -- 1356
		self.countTick = ____exports.GATE_COUNT_END -- 1357
		self.phaseTick = story.phaseTick -- 1358
		self:swapToChild(g.doorX + 30) -- 1359
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1360
			0, -- 1360
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1360
		) -- 1360
		self.handArmed = false -- 1361
	end -- 1361
end -- 1208
function Play.prototype.buildWorld(self) -- 1366
	local room = self.room -- 1367
	self.boxes = {} -- 1368
	self.floors = {} -- 1369
	local i = 0 -- 1370
	do -- 1370
		i = 0 -- 1371
		while i < #room.floors do -- 1371
			local f = room.floors[i + 1] -- 1372
			local ____self_floors_52 = self.floors -- 1372
			____self_floors_52[#____self_floors_52 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1373
			i = i + 1 -- 1371
		end -- 1371
	end -- 1371
	do -- 1371
		i = 0 -- 1375
		while i < #room.solids do -- 1375
			local s = room.solids[i + 1] -- 1376
			if not s.decorative then -- 1376
				local ____self_boxes_64 = self.boxes -- 1382
				local ____s_x_55 = s.x -- 1383
				local ____temp_56 = s.x + s.w -- 1383
				local ____s_y_57 = s.y -- 1383
				local ____temp_58 = s.y + s.h -- 1383
				local ____temp_53 -- 1384
				if room.depth == nil then -- 1384
					____temp_53 = nil -- 1384
				else -- 1384
					____temp_53 = s.depth -- 1384
				end -- 1384
				local ____temp_59 = s.passable == true -- 1385
				local ____s_label_60 = s.label -- 1385
				local ____s_id_61 = s.id -- 1386
				local ____temp_62 = s.soft == true -- 1386
				local ____temp_63 = s.hidden == true -- 1386
				local ____temp_54 -- 1387
				if s.breakable == nil then -- 1387
					____temp_54 = nil -- 1387
				else -- 1387
					____temp_54 = __TS__ObjectAssign({}, s.breakable) -- 1387
				end -- 1387
				____self_boxes_64[#____self_boxes_64 + 1] = { -- 1382
					x0 = ____s_x_55, -- 1383
					x1 = ____temp_56, -- 1383
					y0 = ____s_y_57, -- 1383
					y1 = ____temp_58, -- 1383
					depth = ____temp_53, -- 1384
					passable = ____temp_59, -- 1385
					label = ____s_label_60, -- 1385
					id = ____s_id_61, -- 1386
					soft = ____temp_62, -- 1386
					hidden = ____temp_63, -- 1386
					breakable = ____temp_54, -- 1387
					interact = s.interact -- 1388
				} -- 1388
			end -- 1388
			i = i + 1 -- 1375
		end -- 1375
	end -- 1375
	do -- 1375
		i = 0 -- 1392
		while i < #room.stairs do -- 1392
			local st = room.stairs[i + 1] -- 1393
			local n = st.steps + 1 -- 1394
			local stepW = (st.x1 - st.x0) / n -- 1395
			local k = 0 -- 1396
			do -- 1396
				k = 0 -- 1397
				while k < n do -- 1397
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1398
					local x0 = st.x0 + stepW * k -- 1399
					local ____self_boxes_68 = self.boxes -- 1402
					local ____temp_66 = x0 + stepW -- 1403
					local ____temp_67 = -8 -- 1403
					local ____temp_65 -- 1404
					if room.depth == nil then -- 1404
						____temp_65 = nil -- 1404
					else -- 1404
						____temp_65 = st.depth -- 1404
					end -- 1404
					____self_boxes_68[#____self_boxes_68 + 1] = { -- 1402
						x0 = x0, -- 1403
						x1 = ____temp_66, -- 1403
						y0 = ____temp_67, -- 1403
						y1 = y, -- 1403
						depth = ____temp_65, -- 1404
						passable = true -- 1405
					} -- 1405
					k = k + 1 -- 1397
				end -- 1397
			end -- 1397
			i = i + 1 -- 1392
		end -- 1392
	end -- 1392
end -- 1366
function Play.prototype.setupCampaign(self) -- 1415
	local wr = self.room -- 1416
	local c = wr.campaign -- 1417
	if c == nil then -- 1417
		return -- 1419
	end -- 1419
	self.roomStartTick = self.run.ticks -- 1421
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1421
		self.run.joined = true -- 1425
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1425
		local ____self_run_73 = self.run -- 1428
		local ____temp_72 -- 1428
		if wr.key == "s2-drygoods" then -- 1428
			local ____temp_71 = self.run.route ~= "drygoods" -- 1429
			if not ____temp_71 then -- 1429
				local ____opt_69 = self.run.props.s2_board -- 1429
				____temp_71 = (____opt_69 and ____opt_69.broken) == true -- 1429
			end -- 1429
			____temp_72 = ____temp_71 -- 1429
		else -- 1429
			____temp_72 = wr.key == "c1-yard" and self.run.c1Latch -- 1430
		end -- 1430
		____self_run_73.joined = ____temp_72 -- 1428
	end -- 1428
	local x = wr.minX + 60 -- 1432
	local y = 0 -- 1433
	local depth = 0 -- 1434
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1434
		x = wr.minX + 210 -- 1436
		depth = -32 -- 1437
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1437
		x = wr.minX + 40 -- 1439
		y = 32 -- 1440
		depth = 32 -- 1441
	end -- 1441
	self.player = { -- 1443
		x = x, -- 1444
		y = y, -- 1444
		depth = depth, -- 1444
		depthSpeed = 0, -- 1444
		vx = 0, -- 1444
		vy = 0, -- 1444
		w = SOLDIER_W, -- 1445
		h = SOLDIER_H, -- 1445
		onGround = y <= 0, -- 1445
		facing = 1, -- 1445
		crouch = false, -- 1445
		rollT = 0, -- 1445
		covered = false, -- 1445
		alive = true -- 1445
	} -- 1445
	self.partner = { -- 1447
		x = x + 60, -- 1448
		y = y, -- 1448
		depth = depth, -- 1448
		depthSpeed = 0, -- 1448
		vx = 0, -- 1448
		vy = 0, -- 1448
		w = CHILD_W, -- 1449
		h = CHILD_H, -- 1449
		onGround = y <= 0, -- 1449
		facing = 1, -- 1449
		crouch = false, -- 1449
		rollT = 0, -- 1449
		covered = false, -- 1449
		alive = true -- 1449
	} -- 1449
	self.cam.x = x -- 1451
	self.cam.y = y + CAM_LOOK_UP -- 1452
	self.phase = "run" -- 1453
	self.hp = self.maxHp -- 1454
	if self:isEscortRoom() and self.run.story.route == "soldier" then -- 1454
		if self.run.story.talents == nil then -- 1454
			self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 1457
		end -- 1457
		local st = self.run.story.talents -- 1459
		local variants = ESCORT_VARIANTS[wr.key] -- 1460
		if self.run.source ~= "debug" and variants ~= nil and #variants > 0 then -- 1460
			st.variant = pickEscortVariant(self.run.seed, st.attempt, wr.key, #variants) -- 1462
		else -- 1462
			st.variant = 0 -- 1464
		end -- 1464
		if wr.key == "escort3" then -- 1464
			if st.room ~= "escort3" then -- 1464
				st.room = "escort3" -- 1470
				st.deferred = true -- 1471
				st.offers = {} -- 1472
			end -- 1472
		else -- 1472
			draftTalentOffers(st, wr.key, self.equippedWeapon) -- 1475
		end -- 1475
	end -- 1475
	self:buildEnemies() -- 1478
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1479
	local i = 0 -- 1480
	do -- 1480
		i = 0 -- 1481
		while i < #self.boxes do -- 1481
			do -- 1481
				local b = self.boxes[i + 1] -- 1482
				if b.id == nil then -- 1482
					goto __continue157 -- 1484
				end -- 1484
				local st = self.run.props[b.id] -- 1486
				if st ~= nil then -- 1486
					b.broken = st.broken -- 1488
					local ____temp_74 -- 1489
					if b.breakable == nil then -- 1489
						____temp_74 = nil -- 1489
					else -- 1489
						____temp_74 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1489
					end -- 1489
					b.breakable = ____temp_74 -- 1489
					b.hidden = b.hidden == true and st.revealed ~= true -- 1490
					if b.hidden then -- 1490
						b.broken = true -- 1492
					end -- 1492
				elseif b.hidden == true then -- 1492
					b.broken = true -- 1496
				end -- 1496
			end -- 1496
			::__continue157:: -- 1496
			i = i + 1 -- 1481
		end -- 1481
	end -- 1481
	if wr.cart.bodyW > 0 then -- 1481
		self.cartAxle = wr.cart.startX -- 1500
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1500
			self.cartAxle = wr.cart.endX -- 1502
			self.cartDocked = true -- 1503
		end -- 1503
	end -- 1503
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1506
end -- 1415
function Play.prototype.log(self, line) -- 1509
	local ____self_run_log_75 = self.run.log -- 1509
	____self_run_log_75[#____self_run_log_75 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1510
	if #self.run.log > 120 then -- 1510
		table.remove(self.run.log, 1) -- 1512
	end -- 1512
end -- 1509
function Play.prototype.buildEnemies(self) -- 1516
	self.enemies = {} -- 1517
	if self.isCampaign then -- 1517
		local variants = ESCORT_VARIANTS[self.room.key] -- 1519
		local useVariant = self:isEscortRoom() and self.run.story.route == "soldier" and self.run.source ~= "debug" and variants ~= nil and #variants > 0 -- 1520
		local ____useVariant_79 -- 1525
		if useVariant then -- 1525
			local ____temp_78 = #variants - 1 -- 1526
			local ____opt_76 = self.run.story.talents -- 1526
			____useVariant_79 = math.max( -- 1526
				0, -- 1526
				math.min(____temp_78, ____opt_76 and ____opt_76.variant or 0) -- 1526
			) -- 1526
		else -- 1526
			____useVariant_79 = 0 -- 1527
		end -- 1527
		local vIdx = ____useVariant_79 -- 1525
		local spawnList = useVariant and variants[vIdx + 1] or self.room.spawns -- 1528
		local i = 0 -- 1529
		do -- 1529
			i = 0 -- 1530
			while i < #spawnList do -- 1530
				local sp = spawnList[i + 1] -- 1531
				local kind = sp.kind or "gunner" -- 1532
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1533
				local sx = useVariant and self.ox + sp.x or sp.x -- 1534
				local ____self_enemies_80 = self.enemies -- 1534
				____self_enemies_80[#____self_enemies_80 + 1] = { -- 1535
					x = sx, -- 1536
					y = sp.y, -- 1536
					depth = sp.depth, -- 1536
					w = 26, -- 1536
					h = sp.h, -- 1536
					alive = true, -- 1536
					hitT = 0, -- 1536
					warnT = 0, -- 1536
					fireCd = 40, -- 1536
					kind = kind, -- 1537
					shieldHp = hp, -- 1537
					shieldHpMax = hp, -- 1537
					drop = sp.drop or "none", -- 1537
					homeX = sx, -- 1538
					swingT = 0, -- 1538
					awake = false, -- 1538
					squad = i -- 1538
				} -- 1538
				i = i + 1 -- 1530
			end -- 1530
		end -- 1530
		return -- 1541
	end -- 1541
	if self.room.key == "checkpoint" then -- 1541
		local ____self_enemies_81 = self.enemies -- 1541
		____self_enemies_81[#____self_enemies_81 + 1] = { -- 1544
			x = self.ox + 430, -- 1544
			y = 0, -- 1544
			w = 26, -- 1544
			h = 84, -- 1544
			alive = true, -- 1544
			hitT = 0, -- 1544
			warnT = 0, -- 1544
			fireCd = 0 -- 1544
		} -- 1544
		local ____self_enemies_82 = self.enemies -- 1544
		____self_enemies_82[#____self_enemies_82 + 1] = { -- 1545
			x = self.ox + 505, -- 1545
			y = 0, -- 1545
			w = 26, -- 1545
			h = 84, -- 1545
			alive = true, -- 1545
			hitT = 0, -- 1545
			warnT = 0, -- 1545
			fireCd = 0 -- 1545
		} -- 1545
		return -- 1546
	end -- 1546
	if self.room.key == "street" then -- 1546
		local ____self_enemies_83 = self.enemies -- 1546
		____self_enemies_83[#____self_enemies_83 + 1] = { -- 1550
			x = self.ox + 340, -- 1550
			y = 0, -- 1550
			w = 26, -- 1550
			h = 84, -- 1550
			alive = true, -- 1550
			hitT = 0, -- 1550
			warnT = 0, -- 1550
			fireCd = 0 -- 1550
		} -- 1550
		local ____self_enemies_84 = self.enemies -- 1550
		____self_enemies_84[#____self_enemies_84 + 1] = { -- 1551
			x = self.ox + 560, -- 1551
			y = 0, -- 1551
			w = 26, -- 1551
			h = 84, -- 1551
			alive = true, -- 1551
			hitT = 0, -- 1551
			warnT = 0, -- 1551
			fireCd = 0 -- 1551
		} -- 1551
	end -- 1551
end -- 1516
function Play.prototype.emit(self, name, data) -- 1557
	local ____self_events_85 = self.events -- 1557
	____self_events_85[#____self_events_85 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1558
	self.eventSeq = self.eventSeq + 1 -- 1559
	if #self.events > 256 then -- 1559
		table.remove(self.events, 1) -- 1561
	end -- 1561
end -- 1557
function Play.prototype.drainEvents(self) -- 1569
	local out = self.events -- 1570
	self.events = {} -- 1571
	return out -- 1572
end -- 1569
function Play.prototype.adoptEvents(self, events) -- 1581
	if #events == 0 then -- 1581
		return -- 1583
	end -- 1583
	local keep = {} -- 1585
	local i = 0 -- 1586
	do -- 1586
		i = 0 -- 1587
		while i < #events do -- 1587
			do -- 1587
				local e = events[i + 1] -- 1588
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1588
					goto __continue178 -- 1590
				end -- 1590
				keep[#keep + 1] = e -- 1592
			end -- 1592
			::__continue178:: -- 1592
			i = i + 1 -- 1587
		end -- 1587
	end -- 1587
	if #keep == 0 then -- 1587
		return -- 1595
	end -- 1595
	self.events = __TS__ArrayConcat(keep, self.events) -- 1597
	do -- 1597
		i = 0 -- 1598
		while i < #self.events do -- 1598
			self.events[i + 1].seq = i -- 1599
			i = i + 1 -- 1598
		end -- 1598
	end -- 1598
	self.eventSeq = #self.events -- 1601
end -- 1581
function Play.prototype.talentRank(self, talent) -- 1604
	if self.storyRoute == "soldier" and self:isEscortRoom() and self.run.story.talents ~= nil then -- 1604
		return self.run.story.talents.ranks[talent] or 0 -- 1606
	end -- 1606
	return 0 -- 1608
end -- 1604
function Play.prototype.reloadNeedTicks(self) -- 1612
	return RELOAD_ANSWER_TICKS + 60 * self:talentRank("focus") -- 1613
end -- 1612
function Play.prototype.getStoryTalentOffers(self) -- 1617
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1617
		return {} -- 1619
	end -- 1619
	local st = self.run.story.talents -- 1621
	return st ~= nil and st.room == self.room.key and st.offers or ({}) -- 1622
end -- 1617
function Play.prototype.getStoryTalentRanks(self) -- 1626
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() then -- 1626
		return nil -- 1628
	end -- 1628
	return self.run.story.talents ~= nil and self.run.story.talents.ranks or nil -- 1630
end -- 1626
function Play.prototype.getEscortAttempt(self) -- 1634
	return self.run.story.talents ~= nil and math.max(1, self.run.story.talents.attempt) or 1 -- 1635
end -- 1634
function Play.prototype.chooseTalent(self, slot) -- 1638
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1638
		return false -- 1640
	end -- 1640
	local st = self.run.story.talents -- 1642
	local talent = st ~= nil and st.offers[slot + 1] or nil -- 1643
	if st == nil or talent == nil then -- 1643
		return false -- 1645
	end -- 1645
	st.ranks[talent] = (st.ranks[talent] or 0) + 1 -- 1647
	st.offers = {} -- 1648
	self.talentModalActive = false -- 1649
	local extraMsg = "" -- 1650
	if talent == "vitality" then -- 1650
		self.maxHp = self.maxHp + 1 -- 1652
		self.hp = self.hp + 1 -- 1653
		self.run.story.maxHp = self.maxHp -- 1654
		self.run.story.hp = self.hp -- 1655
	elseif talent == "salvage" then -- 1655
		local inv = self.run.inventory -- 1657
		if inv.wood < 2 and inv.wood <= inv.bell or inv.bell >= 1 and st.ranks.salvage % 2 == 1 then -- 1657
			inv.wood = inv.wood + 1 -- 1659
			extraMsg = " · 得木纹筹×1" -- 1660
		else -- 1660
			inv.bell = inv.bell + 1 -- 1662
			extraMsg = " · 得铃纹筹×1" -- 1663
		end -- 1663
		self:syncCraftBench() -- 1665
	end -- 1665
	self.sessionDirty = true -- 1667
	self:flashSet(("本领 · " .. talentNames[talent]) .. extraMsg, 1.5) -- 1668
	self:emit("storyBeat", {beat = "talent_picked", talent = talent, rank = st.ranks[talent], room = self.room.key}) -- 1669
	return true -- 1670
end -- 1638
function Play.prototype.beginReload(self) -- 1677
	self.reloadT = self:reloadTicks() -- 1678
	local camp = self.room.campaign -- 1679
	if camp ~= nil and camp.reloadPuzzle == true then -- 1679
		self:openReloadPuzzle() -- 1681
	end -- 1681
end -- 1677
function Play.prototype.openReloadPuzzle(self) -- 1686
	self.reloadOpen = true -- 1687
	self.reloadAnswerTicks = 0 -- 1688
	self.reloadWorldTicks = 0 -- 1689
	self.reloadPath = {RELOAD_START} -- 1690
	self.reloadPendingEffect = "" -- 1691
	self.reloadTryCount = self.reloadTryCount + 1 -- 1692
	self:emit( -- 1693
		"reloadOpen", -- 1693
		{ -- 1693
			tryCount = self.reloadTryCount, -- 1693
			needTicks = self:reloadNeedTicks() -- 1693
		} -- 1693
	) -- 1693
end -- 1686
function Play.prototype.closeReloadPuzzle(self) -- 1697
	self.reloadOpen = false -- 1698
	self.reloadAnswerTicks = 0 -- 1699
	self.reloadWorldTicks = 0 -- 1700
	self.reloadPath = {RELOAD_START} -- 1701
	self.reloadPendingEffect = "" -- 1702
end -- 1697
function Play.prototype.reloadTapNode(self, node) -- 1709
	if not self.reloadOpen then -- 1709
		return -- 1711
	end -- 1711
	local path = self.reloadPath -- 1713
	local last = path[#path] -- 1714
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1714
		self.reloadPath = {RELOAD_START} -- 1716
		self:emit("reloadInvalid", {node = node, at = last}) -- 1717
		return -- 1718
	end -- 1718
	path[#path + 1] = node -- 1720
	if node ~= RELOAD_TARGET then -- 1720
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1722
		return -- 1723
	end -- 1723
	if not reloadPathValid(path) then -- 1723
		self.reloadPath = {RELOAD_START} -- 1726
		self:emit("reloadInvalid", {node = node, at = last}) -- 1727
		return -- 1728
	end -- 1728
	self.reloadPendingEffect = reloadEffectOf(path) -- 1730
	self.reloadOpen = false -- 1731
	self.reloadT = 0 -- 1732
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1733
	self:flashSet( -- 1736
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1736
		1.4 -- 1736
	) -- 1736
end -- 1709
function Play.prototype.consumeReloadEffect(self) -- 1740
	local e = self.reloadPendingEffect -- 1741
	if e ~= "" then -- 1741
		self.reloadPendingEffect = "" -- 1743
	end -- 1743
	return e -- 1745
end -- 1740
function Play.prototype.echoToSource(self, from, count, delayTicks) -- 1752
	if count == nil then -- 1752
		count = 1 -- 1752
	end -- 1752
	if delayTicks == nil then -- 1752
		delayTicks = 60 -- 1752
	end -- 1752
	local best = -1 -- 1753
	local bestD = 1000000000 -- 1754
	local i = 0 -- 1755
	local woken = {} -- 1756
	local n = 0 -- 1757
	while n < count do -- 1757
		best = -1 -- 1759
		bestD = 1000000000 -- 1760
		do -- 1760
			i = 0 -- 1761
			while i < #self.enemies do -- 1761
				do -- 1761
					if woken[i] == true then -- 1761
						goto __continue212 -- 1763
					end -- 1763
					local e = self.enemies[i + 1] -- 1765
					if not e.alive then -- 1765
						goto __continue212 -- 1767
					end -- 1767
					local d = math.abs(e.x - from.x) -- 1769
					if d < bestD then -- 1769
						bestD = d -- 1771
						best = i -- 1772
					end -- 1772
				end -- 1772
				::__continue212:: -- 1772
				i = i + 1 -- 1761
			end -- 1761
		end -- 1761
		if best < 0 then -- 1761
			break -- 1776
		end -- 1776
		woken[best] = true -- 1778
		local e = self.enemies[best + 1] -- 1779
		e.awake = true -- 1780
		e.warnT = 0 -- 1781
		e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 1782
		n = n + 1 -- 1783
	end -- 1783
	if n == 0 then -- 1783
		return -- 1786
	end -- 1786
	self:flashSet(n > 1 and "回声引到多处声源 · 敌群同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1788
end -- 1752
function Play.prototype.reloadTicks(self) -- 1791
	return math.max(6, self.run.inventory.quickbelt > 0 and 36 or 54) -- 1792
end -- 1791
function Play.prototype.update(self, dt, input) -- 1795
	self:syncCraftBench() -- 1796
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1796
		self:closeCraftBench() -- 1798
		return -- 1799
	end -- 1799
	if input.pause.pressed then -- 1799
		self.paused = not self.paused -- 1802
	end -- 1802
	if self.flashT > 0 then -- 1802
		self.flashT = self.flashT - dt -- 1805
		if self.flashT <= 0 then -- 1805
			self.flash = "" -- 1807
		end -- 1807
	end -- 1807
	if self.traceT > 0 then -- 1807
		self.traceT = self.traceT - dt -- 1811
		if self.traceT <= 0 then -- 1811
			self.trace = nil -- 1813
		end -- 1813
	end -- 1813
	if self.paused then -- 1813
		self:updateCamera(dt) -- 1817
		return -- 1818
	end -- 1818
	if self.escortFailed then -- 1818
		self.escortFailedTicks = self.escortFailedTicks + 1 -- 1822
		self:updateCamera(dt) -- 1823
		return -- 1824
	end -- 1824
	if self.craftBench.active then -- 1824
		self:updateCamera(dt) -- 1829
		return -- 1830
	end -- 1830
	if self.talentModalActive and #self:getStoryTalentOffers() > 0 and not self.reloadOpen then -- 1830
		self:updateCamera(dt) -- 1834
		return -- 1835
	end -- 1835
	if self.reloadOpen then -- 1835
		local needTicks = self:reloadNeedTicks() -- 1841
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1842
		if self.reloadAnswerTicks > needTicks then -- 1842
			self.reloadOpen = false -- 1844
			self.reloadPendingEffect = "" -- 1845
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = needTicks}) -- 1846
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1847
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1847
			self:updateCamera(dt) -- 1849
			return -- 1850
		else -- 1850
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1852
		end -- 1852
	end -- 1852
	self.ticks = self.ticks + 1 -- 1856
	if self.invulnT > 0 then -- 1856
		self.invulnT = self.invulnT - 1 -- 1860
	end -- 1860
	if self.isCampaign then -- 1860
		local ____self_run_86, ____ticks_87 = self.run, "ticks" -- 1860
		____self_run_86[____ticks_87] = ____self_run_86[____ticks_87] + 1 -- 1863
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1864
	end -- 1864
	local p = self.player -- 1866
	self:stepPlayer(p, dt, input) -- 1867
	self:refreshCover(p, input) -- 1869
	if self.carryOn then -- 1869
		self:carryPose() -- 1871
	end -- 1871
	if self.isCampaign then -- 1871
		self:stepCampaign(dt, input) -- 1874
		if not self.carryOn then -- 1874
			self:stepCampaignPartner(dt) -- 1876
		end -- 1876
	end -- 1876
	self:stepEnemies(dt, input) -- 1881
	if not self.isCampaign then -- 1881
		self:stepStory(dt, input) -- 1883
		self:stepEscort(dt, input) -- 1884
		self:stepVillage(dt, input) -- 1885
		self:stepChase(dt, input) -- 1886
		self:stepInteract(dt, input) -- 1887
	end -- 1887
	self:updateGate() -- 1889
	self:updateCamera(dt) -- 1890
	self:syncStory() -- 1892
end -- 1795
function Play.prototype.underLowArch(self, a) -- 1899
	local arch = self.room.arch -- 1900
	if arch.h <= 0 then -- 1900
		return false -- 1902
	end -- 1902
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1902
		return false -- 1905
	end -- 1905
	local top = arch.y + arch.h -- 1907
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1908
end -- 1899
function Play.prototype.coverAt(self, a) -- 1915
	local best = nil -- 1916
	local bestGap = 24 -- 1917
	local half = a.w / 2 -- 1918
	local i = 0 -- 1919
	do -- 1919
		i = 0 -- 1920
		while i < #self.boxes do -- 1920
			do -- 1920
				local b = self.boxes[i + 1] -- 1921
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1921
					goto __continue245 -- 1923
				end -- 1923
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1923
					goto __continue245 -- 1926
				end -- 1926
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1928
				if gap < bestGap then -- 1928
					bestGap = gap -- 1930
					best = b -- 1931
				end -- 1931
			end -- 1931
			::__continue245:: -- 1931
			i = i + 1 -- 1920
		end -- 1920
	end -- 1920
	return best -- 1934
end -- 1915
function Play.prototype.nearCover(self, a) -- 1937
	return self:coverAt(a) ~= nil -- 1938
end -- 1937
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1942
	if enemy == nil then -- 1942
		return false -- 1944
	end -- 1944
	local fromRight = enemy.x >= a.x -- 1946
	local edge = fromRight and b.x0 or b.x1 -- 1947
	local ____fromRight_88 -- 1948
	if fromRight then -- 1948
		____fromRight_88 = edge >= a.x - 0.001 and edge <= enemy.x -- 1948
	else -- 1948
		____fromRight_88 = edge <= a.x + 0.001 and edge >= enemy.x -- 1949
	end -- 1949
	local between = ____fromRight_88 -- 1948
	local separation = enemy.x - a.x -- 1950
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1951
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1952
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1953
end -- 1942
function Play.prototype.nearestEnemy(self, a) -- 1956
	local best -- 1957
	local bestD = 1000000000 -- 1958
	local i = 0 -- 1959
	do -- 1959
		i = 0 -- 1960
		while i < #self.enemies do -- 1960
			do -- 1960
				local e = self.enemies[i + 1] -- 1961
				if not e.alive then -- 1961
					goto __continue254 -- 1963
				end -- 1963
				local d = math.abs(e.x - a.x) -- 1965
				if d < bestD then -- 1965
					bestD = d -- 1967
					best = e -- 1968
				end -- 1968
			end -- 1968
			::__continue254:: -- 1968
			i = i + 1 -- 1960
		end -- 1960
	end -- 1960
	return best -- 1971
end -- 1956
function Play.prototype.refreshCover(self, a, input) -- 1975
	if self.childMode then -- 1975
		self.coverNear = false -- 1977
		self.coverHug = false -- 1978
		self.coverEntity = "" -- 1979
		self.coverBlocking = false -- 1980
		a.covered = false -- 1981
		return -- 1982
	end -- 1982
	local b = self:coverAt(a) -- 1984
	self.coverNear = b ~= nil -- 1985
	a.covered = self.coverNear and input.cover.held -- 1986
	self.coverHug = a.covered -- 1987
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1988
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1989
		b, -- 1989
		a, -- 1989
		self:nearestEnemy(a) -- 1989
	) -- 1989
end -- 1975
function Play.prototype.cartHandleInReach(self, a) -- 1993
	if a == nil then -- 1993
		a = self.player -- 1993
	end -- 1993
	local c = self.room.cart -- 1994
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1994
		return false -- 1996
	end -- 1996
	local handleX = self.cartAxle + c.handleOffset -- 1998
	local ____table_childMode_89 -- 1999
	if self.childMode then -- 1999
		____table_childMode_89 = math.abs(a.depth - (c.depth or 0)) <= 48 -- 2000
	else -- 2000
		____table_childMode_89 = inReachDepth(a.depth, c.depth or 0) -- 2001
	end -- 2001
	local depthOk = ____table_childMode_89 -- 1999
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and depthOk -- 2002
end -- 1993
function Play.prototype.nearLowLedge(self, a) -- 2007
	local reach = 26 -- 2008
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 2009
	local x1 = x0 + reach -- 2010
	local i = 0 -- 2011
	do -- 2011
		i = 0 -- 2012
		while i < #self.boxes do -- 2012
			do -- 2012
				local b = self.boxes[i + 1] -- 2013
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2013
					goto __continue263 -- 2015
				end -- 2015
				local rise = b.y1 - a.y -- 2017
				if rise > 0 and rise <= LEDGE_RISE then -- 2017
					return true -- 2019
				end -- 2019
			end -- 2019
			::__continue263:: -- 2019
			i = i + 1 -- 2012
		end -- 2012
	end -- 2012
	return false -- 2022
end -- 2007
function Play.prototype.stepPlayer(self, a, dt, input) -- 2025
	a.depthSpeed = 0 -- 2026
	if not a.alive then -- 2026
		return -- 2028
	end -- 2028
	local isChild = self.childMode -- 2030
	local lowArch = isChild and self:underLowArch(a) -- 2032
	if self:storyLocked() then -- 2032
		a.vx = 0 -- 2035
		a.crouch = isChild and lowArch -- 2036
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2037
		self:fallY(a, dt) -- 2038
		return -- 2039
	end -- 2039
	if not isChild and self.escort.state == "calming" then -- 2039
		a.crouch = false -- 2043
		a.h = SOLDIER_H -- 2044
		a.vx = 0 -- 2045
		self:fallY(a, dt) -- 2046
		return -- 2047
	end -- 2047
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 2049
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 2050
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2051
	local nearCover = not isChild and self:nearCover(a) -- 2052
	a.covered = nearCover and input.cover.held -- 2053
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 2055
	if a.rollT > 0 then -- 2055
		a.rollT = a.rollT - dt -- 2059
		local rollSpd = self:isEscortRoom() and ROLL_SPEED * (1 + 0.08 * self:talentRank("stride")) or ROLL_SPEED -- 2060
		a.vx = a.facing * rollSpd -- 2061
		self:slideX(a, a.vx * dt) -- 2062
		self:fallY(a, dt) -- 2063
		if a.rollT <= 0 then -- 2063
			self:flashSet("翻滚结束", 0.5) -- 2065
		end -- 2065
		return -- 2067
	end -- 2067
	local peacefulRoom = self.room.key == "museum" or self.room.key == "tower" -- 2070
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 2070
		if input.moveX ~= 0 then -- 2070
			a.facing = input.moveX > 0 and 1 or -1 -- 2073
		end -- 2073
		if self:nearLowLedge(a) then -- 2073
			a.vy = SOLDIER_JUMP -- 2077
			a.onGround = false -- 2078
			self:flashSet("翻上去", 0.3) -- 2079
			return -- 2080
		end -- 2080
		a.rollT = ROLL_TIME -- 2082
		self:flashSet("翻滚", 0.3) -- 2083
		return -- 2084
	end -- 2084
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 2087
	if isChild then -- 2087
		if input.cover.held then -- 2087
			speed = CHILD_SLOW -- 2090
		end -- 2090
		if a.crouch then -- 2090
			speed = CHILD_SLOW -- 2093
		elseif self.room.key == "forest" and self.forestPath == "ditch" and a.x >= self.ox + 700 and a.x <= self.ox + 1140 then -- 2093
			speed = CHILD_SPEED * 1.22 -- 2097
		end -- 2097
	else -- 2097
		if self:isEscortRoom() then -- 2097
			speed = speed * (1 + 0.1 * self:talentRank("stride")) -- 2101
		end -- 2101
		if a.covered then -- 2101
			speed = speed * 0.45 -- 2104
		end -- 2104
	end -- 2104
	local handsBusy = self.gripping or gripIntent or self.reloadOpen -- 2109
	local dir = (self.gripping or self.reloadOpen) and 0 or input.moveX -- 2110
	local depthDir = self.room.depth ~= nil and not handsBusy and -input.moveY or 0 -- 2112
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 2113
	if dir ~= 0 then -- 2113
		a.facing = dir > 0 and 1 or -1 -- 2115
	end -- 2115
	a.vx = dir * speed * diagonal -- 2117
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 2117
		a.vy = CHILD_JUMP -- 2121
		a.onGround = false -- 2122
		self:flashSet("跳", 0.25) -- 2123
	end -- 2123
	local previousDepth = a.depth -- 2127
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 2128
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2129
	self:slideX(a, a.vx * dt) -- 2130
	self:fallY(a, dt) -- 2131
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and not self.reloadOpen and input.fire.pressed then -- 2131
		self:shoot(a) -- 2135
	end -- 2135
	local ____temp_92 = not isChild and not peacefulRoom and not self.gripping and not self.reloadOpen and self.reloadPendingEffect == "" -- 2138
	if ____temp_92 then -- 2138
		local ____opt_90 = self.room.campaign -- 2138
		____temp_92 = (____opt_90 and ____opt_90.reloadPuzzle) == true -- 2138
	end -- 2138
	if ____temp_92 and input.flare.pressed then -- 2138
		self:beginReload() -- 2140
	end -- 2140
end -- 2025
function Play.prototype.stepPartner(self, p, dt) -- 2145
	local a = self.partner -- 2146
	if not a.alive then -- 2146
		return -- 2148
	end -- 2148
	a.crouch = false -- 2150
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 2151
	a.vx = 0 -- 2152
	a.depthSpeed = 0 -- 2153
	self:fallY(a, dt) -- 2154
end -- 2145
function Play.prototype.stepEscort(self, dt, input) -- 2161
	local a = self.partner -- 2162
	a.depthSpeed = 0 -- 2163
	if not a.alive then -- 2163
		return -- 2165
	end -- 2165
	if self.room.key == "gatepath" then -- 2165
		if self.carryOn then -- 2165
			return -- 2170
		end -- 2170
		local p = self.player -- 2173
		a.depth = p.depth -- 2174
		a.facing = p.facing -- 2175
		a.crouch = false -- 2176
		a.h = CHILD_H -- 2177
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 2178
		a.y = p.y -- 2179
		a.vy = 0 -- 2180
		a.vx = p.vx -- 2181
		a.onGround = p.onGround -- 2182
		return -- 2183
	end -- 2183
	if not self:escortOn() then -- 2183
		a.vx = 0 -- 2186
		self:fallY(a, dt) -- 2187
		return -- 2188
	end -- 2188
	local p = self.player -- 2190
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 2191
	local hadKnock1 = self.escort.knock1 -- 2192
	local hadKnock2 = self.escort.knock2 -- 2193
	self.calmConsumed = self.escort:update( -- 2194
		input, -- 2194
		p.x, -- 2194
		p.facing, -- 2194
		a.x, -- 2194
		dist -- 2194
	) -- 2194
	if not hadKnock1 and self.escort.knock1 then -- 2194
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 2197
	end -- 2197
	if not hadKnock2 and self.escort.knock2 then -- 2197
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 2200
	end -- 2200
	a.crouch = self.escort.crouchPose -- 2202
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 2203
	if not self.escort.stopped then -- 2203
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 2205
		local previousDepth = a.depth -- 2206
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 2207
		local distance = math.max( -- 2208
			-travel, -- 2208
			math.min(travel, targetDepth - previousDepth) -- 2208
		) -- 2208
		self:slideDepth(a, distance) -- 2209
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2210
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 2210
			a.vy = CHILD_JUMP -- 2212
			a.onGround = false -- 2213
		end -- 2213
	end -- 2213
	local dir = self.escort:moveDir(a.x) -- 2216
	a.vx = dir * CHILD_SPEED -- 2217
	if dir ~= 0 then -- 2217
		a.facing = dir -- 2219
		local before = a.x -- 2220
		self:slideX(a, dir * CHILD_SPEED * dt) -- 2221
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 2221
			a.vy = CHILD_JUMP -- 2224
			a.onGround = false -- 2225
		end -- 2225
	end -- 2225
	self:fallY(a, dt) -- 2228
end -- 2161
function Play.prototype.escortOn(self) -- 2232
	if self.room.key == "checkpoint" then -- 2232
		return true -- 2234
	end -- 2234
	if self.room.key == "gatepath" then -- 2234
		return true -- 2237
	end -- 2237
	if self.room.key == "prologue" then -- 2237
		return self.phase == "prologue-follow" -- 2240
	end -- 2240
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 2240
		return true -- 2244
	end -- 2244
	return self.room.key == "street" -- 2246
end -- 2232
function Play.prototype.storyLocked(self) -- 2250
	if self.caughtT > 0 then -- 2250
		return true -- 2252
	end -- 2252
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 2252
		return true -- 2256
	end -- 2256
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 2256
		return true -- 2259
	end -- 2259
	if self.room.key == "gate" and (self.phase == "gate-farewell" or self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 2259
		return true -- 2262
	end -- 2262
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2262
		return true -- 2265
	end -- 2265
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2265
		return true -- 2268
	end -- 2268
	if self.craftBench.active then -- 2268
		return true -- 2272
	end -- 2272
	return false -- 2274
end -- 2250
function Play.prototype.swapToChild(self, x) -- 2278
	local tmp = self.player -- 2279
	self.player = self.partner -- 2280
	self.partner = tmp -- 2281
	self.childMode = true -- 2282
	self.player.alive = true -- 2283
	self.player.x = self.ox + x -- 2284
	self.player.y = 0 -- 2285
	self.player.depth = 0 -- 2286
	self.player.depthSpeed = 0 -- 2287
	self.player.vy = 0 -- 2288
	self.player.vx = 0 -- 2289
	self.player.onGround = true -- 2290
	self.player.crouch = false -- 2291
	self.player.h = CHILD_H -- 2292
	self.player.facing = 1 -- 2293
	self.partner.alive = true -- 2294
	self.cam.x = self.player.x -- 2295
end -- 2278
function Play.prototype.swapToSoldier(self, x, childX) -- 2299
	local tmp = self.player -- 2300
	self.player = self.partner -- 2301
	self.partner = tmp -- 2302
	self.childMode = false -- 2303
	self.player.alive = true -- 2304
	self.player.x = self.ox + x -- 2305
	self.player.y = 0 -- 2306
	self.player.depth = 0 -- 2307
	self.player.depthSpeed = 0 -- 2308
	self.player.vy = 0 -- 2309
	self.player.vx = 0 -- 2310
	self.player.onGround = true -- 2311
	self.player.crouch = false -- 2312
	self.player.h = SOLDIER_H -- 2313
	self.player.facing = 1 -- 2314
	self.partner.alive = true -- 2315
	self.partner.x = self.ox + childX -- 2316
	self.partner.y = 0 -- 2317
	self.partner.depth = 0 -- 2318
	self.partner.depthSpeed = 0 -- 2319
	self.partner.vx = 0 -- 2320
	self.partner.vy = 0 -- 2321
	self.partner.onGround = true -- 2322
	self.partner.crouch = true -- 2323
	self.partner.h = CHILD_CROUCH_H -- 2324
	self.cam.x = self.player.x -- 2325
end -- 2299
function Play.prototype.stepStory(self, dt, input) -- 2329
	if self.room.key == "prologue" then -- 2329
		self:stepPrologue(dt, input) -- 2331
	elseif self.room.key == "street" then -- 2331
		self:stepStreet(dt, input) -- 2333
	elseif self.room.key == "gate" then -- 2333
		self:stepGate(dt, input) -- 2335
	elseif self.room.key == "gatepath" then -- 2335
		self:stepGatePath() -- 2337
	elseif self.room.key == "tower" then -- 2337
		self:stepTower(dt, input) -- 2339
	elseif self.room.key == "museum" then -- 2339
		self:stepMuseum(dt, input) -- 2341
	end -- 2341
end -- 2329
function Play.prototype.canPersistProgress(self) -- 2347
	return not self.isCampaign and self.run.source == "official" -- 2348
end -- 2347
function Play.prototype.wellWindow(self) -- 2352
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 2353
end -- 2352
function Play.prototype.nearWell(self) -- 2358
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 2359
end -- 2358
function Play.prototype.pickWell(self) -- 2367
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2367
		return false -- 2369
	end -- 2369
	self.phase = "prologue-well" -- 2371
	self.phaseTick = 0 -- 2372
	self.wellOpen = false -- 2373
	self:flashSet("井沿 · 伸手下去", 1.4) -- 2374
	self:log("旧井拾取") -- 2375
	return true -- 2376
end -- 2367
function Play.prototype.stepPrologue(self, dt, input) -- 2379
	local child = self.partner -- 2380
	if self.museumReturn then -- 2380
		self.museumReturn = false -- 2383
		self.phase = "prologue-wait" -- 2384
		self.phaseTick = 0 -- 2385
		self.player.x = self.ox + 260 -- 2386
		self.player.y = 0 -- 2387
		self.player.depth = 0 -- 2388
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2389
	end -- 2389
	if self.phase == "prologue-wake" then -- 2389
		self.introTick = self.introTick + 1 -- 2393
		if self.introTick == 60 then -- 2393
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2395
		end -- 2395
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2395
			self.phase = "prologue-shadow" -- 2398
			self.introTick = 0 -- 2399
			self:flashSet("门缝里两道影子", 1.2) -- 2400
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2401
		end -- 2401
		return -- 2403
	end -- 2403
	if self.phase == "prologue-shadow" then -- 2403
		self.introTick = self.introTick + 1 -- 2406
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2406
			self.phase = "prologue-escape" -- 2409
			self.introTick = 0 -- 2410
			self.escapeRemaining = self.escapeDuration -- 2411
			self.escapeRetryCount = 0 -- 2412
			self:swapToChild(100) -- 2413
			self:flashSet( -- 2414
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2414
				1.6 -- 2414
			) -- 2414
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2415
		end -- 2415
		return -- 2419
	end -- 2419
	if self.phase == "prologue-escape" then -- 2419
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2422
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2422
			self.phase = "prologue-hide" -- 2425
			self.introTick = 0 -- 2426
			self.player.vx = 0 -- 2427
			self.player.crouch = true -- 2428
			self.player.h = CHILD_CROUCH_H -- 2429
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2430
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2431
			return -- 2435
		end -- 2435
		if self.escapeRemaining <= 0 then -- 2435
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2439
			self.player.x = self.ox + 100 -- 2440
			self.player.y = 0 -- 2441
			self.player.depth = 0 -- 2442
			self.player.vx = 0 -- 2443
			self.player.vy = 0 -- 2444
			self.escapeRemaining = self.escapeDuration -- 2445
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2446
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2447
			return -- 2448
		end -- 2448
		return -- 2450
	end -- 2450
	if self.phase == "prologue-hide" then -- 2450
		self.introTick = self.introTick + 1 -- 2453
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2453
			self.phase = "prologue-wait" -- 2456
			self.phaseTick = 0 -- 2457
			self.introTick = 0 -- 2458
			self:swapToSoldier(260, 300) -- 2459
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2460
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2461
		end -- 2461
		return -- 2463
	end -- 2463
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2466
	if self.phase == "prologue-wait" then -- 2466
		child.crouch = true -- 2468
		child.h = CHILD_CROUCH_H -- 2469
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2469
			self:pickWell() -- 2471
			return -- 2472
		end -- 2472
		if not self.wellOpen and self:canPersistProgress() and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2472
			self.archive.museumPhase = "well_reflect" -- 2477
			self.archiveDirty = true -- 2478
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2479
			return -- 2480
		end -- 2480
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2482
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2484
		if near and input.interact.pressed then -- 2484
			self.phase = "prologue-give" -- 2486
			self.phaseTick = 0 -- 2487
			self:flashSet("递出针套", 1) -- 2488
		end -- 2488
		return -- 2490
	end -- 2490
	if self.phase == "prologue-well" then -- 2490
		self.phaseTick = self.phaseTick + 1 -- 2494
		if self.phaseTick == 12 then -- 2494
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2496
		elseif self.phaseTick >= 30 then -- 2496
			self.phase = "prologue-wait" -- 2498
			self.phaseTick = 0 -- 2499
			self.wellTaken = true -- 2500
			self.wellOpen = false -- 2501
			self.run.archive.artifactOwned = true -- 2502
			self.archiveDirty = true -- 2503
			self:emit("artifactFound", { -- 2504
				x = self.ox + self.wellX, -- 2505
				y = 0, -- 2505
				room = "prologue", -- 2505
				once = true, -- 2505
				source = self.run.source -- 2506
			}) -- 2506
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2508
			self:log("井底取到时间穿梭器") -- 2509
		end -- 2509
		return -- 2511
	end -- 2511
	if self.phase == "prologue-give" then -- 2511
		self.phaseTick = self.phaseTick + 1 -- 2514
		if self.phaseTick == 36 then -- 2514
			self:flashSet("针套递过去", 0.9) -- 2516
		elseif self.phaseTick == 108 then -- 2516
			self:flashSet("纸条塞进针套", 1) -- 2518
		elseif self.phaseTick >= ____exports.PROLOGUE_GIVE_TICKS then -- 2518
			self.phase = "prologue-follow" -- 2520
			self.phaseTick = 0 -- 2521
			child.crouch = false -- 2522
			child.h = CHILD_H -- 2523
			self:flashSet("她跟上了", 1.2) -- 2524
		end -- 2524
		return -- 2526
	end -- 2526
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2526
		local next = self.run.source == "debug" and "street" or "s1-crossroad" -- 2530
		self:requestRoom(next, "序章跟到门口") -- 2531
		self:flashSet(next == "s1-crossroad" and "进十字街" or "进街道", 1.2) -- 2532
	end -- 2532
end -- 2379
function Play.prototype.stepStreet(self, dt, input) -- 2537
	local p = self.player -- 2538
	local c = self.partner -- 2539
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2539
		local next = self.run.source == "debug" and "checkpoint" or "s1-crossroad" -- 2541
		self:requestRoom(next, "两人都到街尾") -- 2542
		self:flashSet(next == "s1-crossroad" and "进十字街" or "到检查站", 1.2) -- 2543
	end -- 2543
end -- 2537
function Play.prototype.stepGate(self, dt, input) -- 2548
	local ____temp_93 -- 2549
	if self.room.story == nil then -- 2549
		____temp_93 = nil -- 2549
	else -- 2549
		____temp_93 = self.room.story.gate -- 2549
	end -- 2549
	local g = ____temp_93 -- 2549
	if g == nil then -- 2549
		return -- 2551
	end -- 2551
	local p = self.player -- 2553
	if self.phase == "gate-idle" then -- 2553
		local a = self.partner -- 2556
		local gap = g.waitX - a.x -- 2557
		if math.abs(gap) > 3 then -- 2557
			a.facing = gap > 0 and 1 or -1 -- 2559
			a.vx = a.facing * CHILD_SPEED -- 2560
			local beforeX = a.x -- 2561
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2562
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2562
				a.vy = CHILD_JUMP -- 2564
				a.onGround = false -- 2565
			end -- 2565
			self:fallY(a, dt) -- 2567
		else -- 2567
			a.vx = 0 -- 2569
			a.x = g.waitX -- 2570
		end -- 2570
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2573
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2574
		if self.gateNeedConfirm then -- 2574
			if not input.interact.held then -- 2574
				self.gateRestartArmed = true -- 2579
			end -- 2579
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2579
				self.gateNeedConfirm = false -- 2582
				self.gateRestartArmed = true -- 2583
				self.phase = "gate-hold" -- 2584
				self.gateTick = 0 -- 2585
				self.gateSpawned = 0 -- 2586
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2587
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2588
			end -- 2588
			return -- 2590
		end -- 2590
		if atWinch and atWait then -- 2590
			self.phase = "gate-hold" -- 2593
			self.gateTick = 0 -- 2594
			self.gateSpawned = 0 -- 2595
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2596
		end -- 2596
		return -- 2598
	end -- 2598
	if self.phase == "gate-hold" then -- 2598
		self.gateTick = self.gateTick + 1 -- 2601
		local marks = {0, 540, 900, 1500} -- 2603
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2603
			local idx = self.gateSpawned -- 2605
			local ____self_enemies_94 = self.enemies -- 2605
			____self_enemies_94[#____self_enemies_94 + 1] = { -- 2606
				x = self.ox + 620 + idx * 62, -- 2607
				y = 0, -- 2607
				w = 26, -- 2607
				h = 84, -- 2607
				alive = true, -- 2608
				hitT = 0, -- 2608
				warnT = 0, -- 2608
				fireCd = 90 + idx * 45 -- 2608
			} -- 2608
			self.gateSpawned = self.gateSpawned + 1 -- 2610
			self:flashSet( -- 2611
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2611
				0.9 -- 2611
			) -- 2611
		end -- 2611
		if self.gateTick == 900 then -- 2611
			self:flashSet("棚布落下", 1) -- 2614
		elseif self.gateTick == 2100 then -- 2614
			self:flashSet("门底透进冷光了", 1) -- 2616
		end -- 2616
		if self.gateTick >= g.holdTicks then -- 2616
			self:captureGateBlood() -- 2621
			self.phase = "gate-send" -- 2622
			self.phaseTick = 0 -- 2623
			self.enemies = {} -- 2625
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2626
		end -- 2626
		return -- 2628
	end -- 2628
	if self.phase == "gate-send" then -- 2628
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2631
		if near and input.interact.pressed then -- 2631
			self:commitRoute() -- 2635
			self:swapToChild(g.doorX + 30) -- 2636
			self.phase = self.run.source == "debug" and "gate-count" or "gate-farewell" -- 2637
			self.phaseTick = 0 -- 2638
			self.countTick = 0 -- 2639
			self.countArmed = false -- 2641
			self.countPrevMove = input.moveX -- 2642
			self:flashSet("门开了 · 送她出去", 1.8) -- 2643
		end -- 2643
		return -- 2645
	end -- 2645
	if self.phase == "gate-farewell" then -- 2645
		self.phaseTick = self.phaseTick + 1 -- 2648
		self.countPrevMove = input.moveX -- 2649
		if self.phaseTick >= ____exports.GATE_FAREWELL_TICKS then -- 2649
			self.phase = "gate-count" -- 2651
			self.phaseTick = 0 -- 2652
			self.countTick = 0 -- 2653
			self.countArmed = false -- 2654
		end -- 2654
		return -- 2656
	end -- 2656
	if self.phase == "gate-count" then -- 2656
		self.countTick = self.countTick + 1 -- 2659
		if self.countTick == 360 then -- 2659
			self:flashSet("门关上", 0.9) -- 2661
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2661
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2663
			if self.storyRoute == "soldier" then -- 2663
				self.phase = "gate-wait" -- 2669
				self.phaseTick = 0 -- 2670
				self.knocks = 1 -- 2671
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2672
				self.handArmed = not input.interact.held and not self.intentGateReunionHold -- 2674
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2675
			else -- 2675
				self:flashSet("数到二十", 2.2) -- 2677
			end -- 2677
		end -- 2677
		local prevMove = self.countPrevMove -- 2682
		self.countPrevMove = input.moveX -- 2683
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2683
			if prevMove <= 0 and input.moveX > 0 then -- 2683
				self.countArmed = true -- 2686
			end -- 2686
			if self.countArmed and input.moveX > 0 then -- 2686
				self.phase = "gate-walk" -- 2689
				self.phaseTick = 0 -- 2690
				self:flashSet("她迈出第一步", 1.4) -- 2691
				self:emit("storyExit", { -- 2692
					route = "child", -- 2692
					via = "walk", -- 2692
					countTick = self.countTick, -- 2692
					hp = self.hp, -- 2692
					maxHp = self.maxHp -- 2692
				}) -- 2692
			end -- 2692
		end -- 2692
		return -- 2695
	end -- 2695
	if self.phase == "gate-wait" then -- 2695
		self.phaseTick = self.phaseTick + 1 -- 2699
		if self.phaseTick == 12 then -- 2699
			self.knocks = 2 -- 2701
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2702
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2703
		end -- 2703
		local held = input.interact.held or self.intentGateReunionHold -- 2705
		if not held then -- 2705
			if self.handTicks > 0 then -- 2705
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2708
			end -- 2708
			self.handTicks = 0 -- 2710
			self.handArmed = true -- 2711
			return -- 2712
		end -- 2712
		if self.handArmed then -- 2712
			self.handTicks = self.handTicks + 1 -- 2715
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2715
				self.intentGateReunionHold = false -- 2717
				self.phase = "gate-hand" -- 2718
				self.phaseTick = 0 -- 2719
				self.handDone = true -- 2720
				self.tied = true -- 2721
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2722
				if not self.lineSaid then -- 2722
					self.lineSaid = true -- 2724
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2725
				end -- 2725
				self:flashSet("我们走吧。", 3) -- 2727
			end -- 2727
		end -- 2727
		return -- 2730
	end -- 2730
	if self.phase == "gate-hand" then -- 2730
		self.phaseTick = self.phaseTick + 1 -- 2734
		if self.phaseTick == 30 then -- 2734
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2736
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2736
			self:emit("storyExit", { -- 2738
				route = "soldier", -- 2738
				via = "hand", -- 2738
				handTicks = self.handTicks, -- 2738
				hp = self.hp, -- 2738
				maxHp = self.maxHp -- 2738
			}) -- 2738
			self:requestRoom("gatepath", "牵手同行") -- 2739
		end -- 2739
		return -- 2741
	end -- 2741
	if self.phase == "gate-walk" then -- 2741
		if self.player.x >= g.exitX then -- 2741
			self:requestRoom("outside", "走出城门") -- 2746
			self:flashSet("出城门 · 城外", 1.4) -- 2747
		end -- 2747
	end -- 2747
end -- 2548
function Play.prototype.captureGateBlood(self) -- 2756
	self.hpAtGate = self.hp -- 2757
	self.maxHpAtGate = self.maxHp -- 2758
end -- 2756
function Play.prototype.commitRoute(self) -- 2765
	if self.storySettled then -- 2765
		return -- 2767
	end -- 2767
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2769
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2770
	self.hpAtGate = hp -- 2771
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2772
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2773
	self.storySettled = true -- 2774
	self.sessionDirty = true -- 2775
	self:emit("storyRouteLocked", { -- 2776
		route = self.storyRoute, -- 2777
		hp = self.hp, -- 2777
		maxHp = self.maxHp, -- 2777
		hpAtGate = self.hpAtGate, -- 2778
		maxHpAtGate = self.maxHpAtGate -- 2778
	}) -- 2778
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2780
end -- 2765
function Play.prototype.syncStory(self) -- 2784
	local s = self.run.story -- 2785
	if s == nil then -- 2785
		return -- 2787
	end -- 2787
	s.hp = self.hp -- 2789
	s.maxHp = self.maxHp -- 2790
	s.route = self.storyRoute -- 2791
	s.settled = self.storySettled -- 2792
	s.hpAtGate = self.hpAtGate -- 2793
	s.maxHpAtGate = self.maxHpAtGate -- 2794
	s.handDone = self.handDone -- 2795
	s.lineSaid = self.lineSaid -- 2796
	s.tied = self.tied -- 2797
	s.carry = self.carryOn -- 2798
	s.museumReturn = self.museumReturn -- 2799
	s.escortDone = self.escortDone -- 2800
	s.craftedWeapon = self.run.story.craftedWeapon -- 2801
	s.equippedWeapon = self.equippedWeapon -- 2802
	s.ending = self.run.story.ending -- 2803
	if self.room.key == "gate" then -- 2803
		s.phase = self.phase -- 2805
		s.countTick = self.countTick -- 2806
		s.phaseTick = self.phaseTick -- 2807
		s.handTicks = self.handTicks -- 2808
	end -- 2808
	if self.room.key == "prologue" then -- 2808
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2808
			s.phase = self.phase -- 2813
			s.phaseTick = self.phaseTick -- 2814
		end -- 2814
	end -- 2814
	if self.room.key == "tower" then -- 2814
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2814
			s.phase = self.phase -- 2820
			s.phaseTick = self.phaseTick -- 2821
		end -- 2821
	end -- 2821
end -- 2784
function Play.prototype.stepGatePath(self) -- 2827
	local ____temp_95 -- 2828
	if self.room.story == nil then -- 2828
		____temp_95 = nil -- 2828
	else -- 2828
		____temp_95 = self.room.story.gatepath -- 2828
	end -- 2828
	local gp = ____temp_95 -- 2828
	if self.phase == "gatepath-start" then -- 2828
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2828
			self.carryOn = true -- 2831
			self.phase = "gatepath-carry" -- 2832
			self.phaseTick = 0 -- 2833
			self.pathDone = true -- 2834
			self.escortDone = false -- 2835
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2836
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2837
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2838
		end -- 2838
		return -- 2840
	end -- 2840
	if self.phase == "gatepath-carry" then -- 2840
		self.phaseTick = self.phaseTick + 1 -- 2843
		if self.phaseTick == 20 then -- 2843
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2845
		end -- 2845
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2845
			self:requestRoom(gp.next, "背负进首战") -- 2848
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2849
		end -- 2849
	end -- 2849
end -- 2827
function Play.prototype.carryPose(self) -- 2858
	local p = self.player -- 2859
	local a = self.partner -- 2860
	a.alive = true -- 2861
	a.x = p.x - p.facing * 12 -- 2862
	a.y = p.y + 26 -- 2863
	a.depth = p.depth -- 2864
	a.vx = p.vx -- 2865
	a.vy = 0 -- 2866
	a.onGround = true -- 2867
	a.crouch = false -- 2868
	a.h = CHILD_CROUCH_H -- 2869
	a.facing = p.facing -- 2870
end -- 2858
function Play.prototype.stepMuseum(self, dt, input) -- 2878
	self.partner.alive = false -- 2879
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2880
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2883
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 2884
	local intentTarget = self.pendingMuseumIntentTarget -- 2885
	self.pendingMuseumIntentTarget = "" -- 2886
	local interactHit = input.interact.pressed or intentTarget ~= "" -- 2887
	if self.phase == "museum-cabinet" then -- 2887
		if atCase and interactHit or intentTarget == "cabinet" then -- 2887
			self.phase = "museum-hall" -- 2890
			self.phaseTick = 0 -- 2891
			if self:canPersistProgress() then -- 2891
				self.archive.museumPhase = "hall_walk" -- 2893
				self.archiveDirty = true -- 2894
			end -- 2894
			self:emit( -- 2896
				"museumStep", -- 2896
				{ -- 2896
					step = "cabinet", -- 2896
					x = self.ox + mu.cabinetX, -- 2896
					persisted = self:canPersistProgress() -- 2896
				} -- 2896
			) -- 2896
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2897
		end -- 2897
		return -- 2899
	end -- 2899
	if self.phase == "museum-hall" then -- 2899
		if intentTarget == "lamp_direct" and nearLamp then -- 2899
			self:emit( -- 2903
				"museumStep", -- 2903
				{ -- 2903
					step = "hall", -- 2903
					x = self.ox + mu.hallX, -- 2903
					persisted = self:canPersistProgress() -- 2903
				} -- 2903
			) -- 2903
			self.phase = "museum-return" -- 2904
			self.phaseTick = 0 -- 2905
			if self:canPersistProgress() then -- 2905
				self.archive.museumPhase = "return_cabinet" -- 2907
				self.archiveDirty = true -- 2908
			end -- 2908
			self:emit( -- 2910
				"museumStep", -- 2910
				{ -- 2910
					step = "lamp", -- 2910
					x = self.ox + mu.lampX, -- 2910
					persisted = self:canPersistProgress() -- 2910
				} -- 2910
			) -- 2910
			self:flashSet("灯 · 转向西窗", 1.8) -- 2911
			return -- 2912
		end -- 2912
		if self.player.x >= self.ox + mu.hallX and interactHit then -- 2912
			self.phase = "museum-lamp" -- 2915
			self.phaseTick = 0 -- 2916
			if self:canPersistProgress() then -- 2916
				self.archive.museumPhase = "lamp_turn" -- 2918
				self.archiveDirty = true -- 2919
			end -- 2919
			self:emit( -- 2921
				"museumStep", -- 2921
				{ -- 2921
					step = "hall", -- 2921
					x = self.ox + mu.hallX, -- 2921
					persisted = self:canPersistProgress() -- 2921
				} -- 2921
			) -- 2921
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2922
		end -- 2922
		return -- 2924
	end -- 2924
	if self.phase == "museum-lamp" then -- 2924
		if nearLamp and interactHit then -- 2924
			self.phase = "museum-return" -- 2928
			self.phaseTick = 0 -- 2929
			if self:canPersistProgress() then -- 2929
				self.archive.museumPhase = "return_cabinet" -- 2931
				self.archiveDirty = true -- 2932
			end -- 2932
			self:emit( -- 2934
				"museumStep", -- 2934
				{ -- 2934
					step = "lamp", -- 2934
					x = self.ox + mu.lampX, -- 2934
					persisted = self:canPersistProgress() -- 2934
				} -- 2934
			) -- 2934
			self:flashSet("灯 · 转向西窗", 1.8) -- 2935
		end -- 2935
		return -- 2937
	end -- 2937
	if self.phase == "museum-return" then -- 2937
		if atCase and interactHit or intentTarget == "return_cabinet" then -- 2937
			self.phase = "museum-knock" -- 2941
			self.phaseTick = 0 -- 2942
			self:emit( -- 2943
				"museumStep", -- 2943
				{ -- 2943
					step = "knock", -- 2943
					count = 1, -- 2943
					x = self.ox + mu.cabinetX, -- 2943
					persisted = self:canPersistProgress() -- 2943
				} -- 2943
			) -- 2943
			self:flashSet("回柜边 · 第一下", 0.8) -- 2944
		end -- 2944
		return -- 2946
	end -- 2946
	if self.phase == "museum-knock" then -- 2946
		self.phaseTick = self.phaseTick + 1 -- 2949
		if self.phaseTick == 8 then -- 2949
			self:emit( -- 2951
				"museumStep", -- 2951
				{ -- 2951
					step = "knock", -- 2951
					count = 2, -- 2951
					x = self.ox + mu.cabinetX, -- 2951
					persisted = self:canPersistProgress() -- 2951
				} -- 2951
			) -- 2951
			self:flashSet("回柜边 · 第二下", 0.8) -- 2952
		elseif self.phaseTick >= 36 then -- 2952
			self.phase = "museum-done" -- 2954
			self.phaseTick = 0 -- 2955
			if self:canPersistProgress() then -- 2955
				self.archive.museumSeen = true -- 2957
				self.archive.museumPhase = "done" -- 2958
				self.archiveDirty = true -- 2959
			end -- 2959
			self:emit( -- 2961
				"museumDone", -- 2961
				{ -- 2961
					steps = 4, -- 2961
					museumSeen = self.archive.museumSeen, -- 2961
					persisted = self:canPersistProgress() -- 2961
				} -- 2961
			) -- 2961
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2962
			self:log("博物馆 · 回柜边") -- 2963
		end -- 2963
		return -- 2965
	end -- 2965
	if interactHit then -- 2965
		self.museumReturn = true -- 2968
		self:requestRoom("prologue", "回柜边") -- 2969
	end -- 2969
end -- 2878
function Play.prototype.openTowerDoor(self) -- 2973
	self.towerDoorOpen = true -- 2974
	do -- 2974
		local i = 0 -- 2975
		while i < #self.boxes do -- 2975
			if self.boxes[i + 1].id == "tower_door" then -- 2975
				self.boxes[i + 1].hidden = true -- 2977
			end -- 2977
			i = i + 1 -- 2975
		end -- 2975
	end -- 2975
	self.run.story.segments.tower_door = true -- 2980
end -- 2973
function Play.prototype.stepTower(self, dt, input) -- 2983
	local ____temp_96 -- 2984
	if self.room.story == nil then -- 2984
		____temp_96 = nil -- 2984
	else -- 2984
		____temp_96 = self.room.story.tower -- 2984
	end -- 2984
	local t = ____temp_96 -- 2984
	if t == nil then -- 2984
		return -- 2986
	end -- 2986
	if self.storyRoute == "soldier" and self.partner.alive then -- 2986
		local targetX = math.max(self.ox + 408, self.player.x - 28) -- 2990
		local gap = targetX - self.partner.x -- 2991
		if math.abs(gap) > 2 then -- 2991
			local dir = gap > 0 and 1 or -1 -- 2993
			local stepDist = math.min( -- 2994
				math.abs(gap), -- 2994
				SOLDIER_SPEED * dt -- 2994
			) -- 2994
			self.partner.facing = dir -- 2995
			self.partner.vx = dir * SOLDIER_SPEED -- 2996
			local ____self_partner_97, ____x_98 = self.partner, "x" -- 2996
			____self_partner_97[____x_98] = ____self_partner_97[____x_98] + dir * stepDist -- 2997
		else -- 2997
			self.partner.vx = 0 -- 2999
			self.partner.facing = 1 -- 3000
		end -- 3000
	end -- 3000
	if self.phase == "tower-wait" then -- 3000
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 3004
		if near and input.interact.pressed then -- 3004
			self.phase = "tower-knock" -- 3006
			self.phaseTick = 0 -- 3007
			self.knocks = 1 -- 3008
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 3009
			self:flashSet("叩两下 · 第一声", 0.6) -- 3010
		end -- 3010
		return -- 3012
	end -- 3012
	if self.phase == "tower-knock" then -- 3012
		self.phaseTick = self.phaseTick + 1 -- 3015
		if self.phaseTick == 12 then -- 3015
			self.knocks = 2 -- 3017
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 3018
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 3019
		elseif self.phaseTick >= t.knockTicks then -- 3019
			self:openTowerDoor() -- 3021
			self.phase = "tower-enter" -- 3022
			self.phaseTick = 0 -- 3023
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 3024
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 3025
		end -- 3025
		return -- 3027
	end -- 3027
	if self.phase == "tower-enter" then -- 3027
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 3027
			self.phase = "tower-desk" -- 3031
			self.phaseTick = 0 -- 3032
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 3033
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 3034
		end -- 3034
		return -- 3036
	end -- 3036
	if self.phase == "tower-desk" then -- 3036
		local deskX = self.ox + 605 -- 3039
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 3040
		if not near or not input.interact.held then -- 3040
			self.deskHold = 0 -- 3042
			return -- 3043
		end -- 3043
		self.deskHold = self.deskHold + 1 -- 3045
		if self.deskHold == 12 then -- 3045
			self:flashSet("针套 · 放在桌上", 1) -- 3047
		elseif self.deskHold == 24 then -- 3047
			self:flashSet("指南针 · 压住纸条", 1) -- 3049
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 3049
			self.towerHanded = true -- 3051
			self.deskHold = 0 -- 3052
			self.run.story.segments.tower_handover = true -- 3053
			self.phase = "tower-given" -- 3054
			self.phaseTick = 0 -- 3055
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 3056
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 3061
		end -- 3061
		return -- 3063
	end -- 3063
	if self.phase == "tower-given" then -- 3063
		local soldier = self.storyRoute == "soldier" -- 3068
		self.phaseTick = self.phaseTick + 1 -- 3069
		if self.phaseTick == 60 then -- 3069
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 3071
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 3072
		elseif self.phaseTick == 120 then -- 3072
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 3074
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 3074
			self.phase = "tower-end" -- 3076
			self.phaseTick = 0 -- 3077
			self.towerEndMustRelease = input.interact.held or input.retry.held -- 3078
			if not self.run.finished then -- 3078
				self.run.finished = true -- 3080
				local ending = soldier and "reunion" or "lamp" -- 3081
				self.run.story.ending = ending -- 3082
				local ____soldier_99 -- 3085
				if soldier then -- 3085
					____soldier_99 = self.run.story.segments.escort5 == true -- 3086
				else -- 3086
					____soldier_99 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 3087
				end -- 3087
				local played = ____soldier_99 -- 3085
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 3088
				if official then -- 3088
					if soldier then -- 3088
						self.run.archive.soldierCleared = true -- 3092
					else -- 3092
						self.run.archive.childCleared = true -- 3094
					end -- 3094
					self.archiveDirty = true -- 3096
				end -- 3096
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 3098
				self:emit("endingReached", { -- 3099
					route = soldier and "soldier" or "child", -- 3100
					ending = ending, -- 3101
					official = official, -- 3102
					source = self.run.source, -- 3103
					lines = {self.endingLines[1], self.endingLines[2]}, -- 3104
					childCleared = self.run.archive.childCleared, -- 3105
					soldierCleared = self.run.archive.soldierCleared, -- 3106
					artifactOwned = self.run.archive.artifactOwned, -- 3107
					equipped = self.equippedWeapon -- 3108
				}) -- 3108
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 3110
			end -- 3110
		end -- 3110
		return -- 3113
	end -- 3113
	self.phaseTick = self.phaseTick + 1 -- 3115
	local held = input.interact.held or input.retry.held -- 3116
	if self.towerEndMustRelease then -- 3116
		if not held then -- 3116
			self.towerEndMustRelease = false -- 3119
		end -- 3119
		return -- 3121
	end -- 3121
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 3123
	if self.phaseTick < waitTicks then -- 3123
		if input.interact.pressed or input.retry.pressed then -- 3123
			self.towerEndMustRelease = held -- 3126
		end -- 3126
		return -- 3128
	end -- 3128
	if input.interact.pressed or input.retry.pressed then -- 3128
		self.restartStory = true -- 3132
		self:requestRoom("prologue", "片尾再玩") -- 3133
		self:flashSet("回到序章", 1.4) -- 3134
	end -- 3134
end -- 2983
function Play.prototype.stepChase(self, dt, input) -- 3139
	if self.caughtT > 0 then -- 3139
		self.caughtT = self.caughtT - dt -- 3141
		if self.caughtT <= 0 then -- 3141
			self:recoverFromCaught() -- 3143
		end -- 3143
		return -- 3145
	end -- 3145
	if self.room.key == "village" then -- 3145
		self:stepScavChase() -- 3148
	elseif self.room.key == "forest" then -- 3148
		self:stepForestRoute() -- 3150
		self:stepDog(dt) -- 3151
		if self.player.x >= self.ox + 1450 then -- 3151
			self:requestRoom("tower", "到林缘北塔") -- 3154
			self:flashSet("林缘 · 北塔", 1.4) -- 3155
		end -- 3155
	end -- 3155
end -- 3139
function Play.prototype.stepScavChase(self) -- 3161
	local s = self.room.scavenger -- 3162
	if s == nil then -- 3162
		return -- 3164
	end -- 3164
	local p = self.player -- 3166
	if self.passed and p.x > self.ox + 440 then -- 3166
		if self.scavChase then -- 3166
			self.scavChase = false -- 3170
			self.scavState = "back" -- 3171
			self.scavT = 0 -- 3172
		end -- 3172
		return -- 3174
	end -- 3174
	local dx = p.x - self.scavX -- 3176
	local dist = math.abs(dx) -- 3177
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 3178
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 3179
	if not self.scavChase then -- 3179
		if visible then -- 3179
			self.scavSee = self.scavSee + 1 -- 3182
			if self.scavSee >= 24 then -- 3182
				self.scavChase = true -- 3184
				self.scavState = "chase" -- 3185
				self.scavTargetX = p.x -- 3186
				self:flashSet("他看见你了", 1.2) -- 3187
			end -- 3187
		else -- 3187
			self.scavSee = 0 -- 3190
		end -- 3190
		return -- 3192
	end -- 3192
	if hidden then -- 3192
		self.scavSee = 0 -- 3196
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 3197
		self.scavT = self.scavT - 1 -- 3198
		if self.scavT <= 0 then -- 3198
			self.scavChase = false -- 3200
			self.scavState = "patrol" -- 3201
			self:flashSet("他失去了目标", 1) -- 3202
		end -- 3202
		return -- 3204
	end -- 3204
	local dir = p.x > self.scavX and 1 or -1 -- 3207
	self.scavX = self.scavX + dir * 96 / 60 -- 3208
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 3208
		self:caught() -- 3210
		return -- 3211
	end -- 3211
end -- 3161
function Play.prototype.stepDog(self, dt) -- 3216
	local ____temp_100 -- 3217
	if self.room.story == nil then -- 3217
		____temp_100 = nil -- 3217
	else -- 3217
		____temp_100 = self.room.story.dog -- 3217
	end -- 3217
	local dog = ____temp_100 -- 3217
	if dog == nil then -- 3217
		return -- 3219
	end -- 3219
	local p = self.player -- 3221
	local ox = self.ox -- 3222
	local dist = math.abs(p.x - self.dogX) -- 3223
	local inBurrowCover = p.crouch and p.x >= ox + 300 and p.x <= ox + 460 -- 3224
	local inBrushCover = p.crouch and (p.x >= ox + 700 and p.x <= ox + 790 or p.x >= ox + 1150 and p.x <= ox + 1240) -- 3225
	local sheltered = inBurrowCover or inBrushCover -- 3229
	local inDitchSprint = not p.crouch and self.forestPath == "ditch" and p.x >= ox + 700 and p.x <= ox + 1140 -- 3230
	local effectiveRange = inDitchSprint and dog.range * 1.25 or dog.range -- 3231
	local earNeedTicks = inDitchSprint and 12 or 18 -- 3232
	if self.dogState == "patrol" then -- 3232
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 3234
		if self.dogX < dog.x0 then -- 3234
			self.dogX = dog.x0 -- 3236
			self.dogDir = 1 -- 3237
		elseif self.dogX > dog.x1 then -- 3237
			self.dogX = dog.x1 -- 3239
			self.dogDir = -1 -- 3240
		end -- 3240
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 3242
		local twigOffsets = {235, 455, 865, 1115} -- 3243
		local nearTwig = false -- 3244
		local ti = 0 -- 3245
		do -- 3245
			ti = 0 -- 3246
			while ti < #twigOffsets do -- 3246
				if math.abs(p.x - (ox + twigOffsets[ti + 1])) <= 18 and p.y <= 8 then -- 3246
					nearTwig = true -- 3248
					break -- 3249
				end -- 3249
				ti = ti + 1 -- 3246
			end -- 3246
		end -- 3246
		local twigRange = nearTwig and math.max(effectiveRange, 400) or effectiveRange -- 3252
		if not sheltered and not p.crouch and moving and dist < twigRange then -- 3252
			self.dogState = "ear" -- 3254
			self.dogT = nearTwig and math.min(earNeedTicks, 12) or earNeedTicks -- 3255
			self.dogTargetX = p.x -- 3256
			self:flashSet(inDitchSprint and "旧渠枯枝响 · 狗立刻转耳" or (nearTwig and "踩断枯枝 · 狗立刻转耳" or "狗转耳朵"), 0.8) -- 3257
		end -- 3257
		return -- 3259
	end -- 3259
	if self.dogState == "ear" then -- 3259
		if sheltered then -- 3259
			self.dogState = "sniff" -- 3263
			self.dogT = 45 -- 3264
			self:flashSet("钻进遮蔽 · 狗顿住了", 0.9) -- 3265
			return -- 3266
		end -- 3266
		self.dogT = self.dogT - 1 -- 3268
		if self.dogT <= 0 then -- 3268
			self.dogState = "chase" -- 3270
			self.dogTargetX = p.x -- 3271
			self:flashSet("狗追来了", 1.4) -- 3272
		end -- 3272
		return -- 3274
	end -- 3274
	if self.dogState == "chase" then -- 3274
		local dir = p.x > self.dogX and 1 or -1 -- 3277
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 3278
		if not sheltered and math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 3278
			self:caught() -- 3280
			self.dogState = "sniff" -- 3281
			self.dogT = 60 -- 3282
		elseif dist > effectiveRange * 1.5 or sheltered then -- 3282
			self.dogState = "sniff" -- 3284
			self.dogT = 60 -- 3285
			self:flashSet(inBurrowCover and "树根窄洞遮住身形 · 狗停下了" or "狗停下了", 0.9) -- 3286
		end -- 3286
		return -- 3288
	end -- 3288
	if self.dogState == "sniff" then -- 3288
		self.dogT = self.dogT - 1 -- 3291
		if self.dogT <= 0 then -- 3291
			self.dogState = "back" -- 3293
		end -- 3293
		return -- 3295
	end -- 3295
	local dir = dog.x0 > self.dogX and 1 or -1 -- 3298
	self.dogX = self.dogX + dir * dog.speed * dt -- 3299
	if math.abs(self.dogX - dog.x0) < 2 then -- 3299
		self.dogX = dog.x0 -- 3301
		self.dogState = "patrol" -- 3302
	end -- 3302
end -- 3216
function Play.prototype.stepForestRoute(self) -- 3307
	local p = self.player -- 3308
	local ox = self.ox -- 3309
	if self.forestPath == "" then -- 3309
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 3309
			self.forestPath = "burrow" -- 3312
			self.run.story.segments.forest_burrow = true -- 3313
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 3314
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 3315
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 3315
			self.forestPath = "ditch" -- 3317
			self.run.story.segments.forest_ditch = true -- 3318
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 3319
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 3320
		end -- 3320
	end -- 3320
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 3320
		self.waterSeen = true -- 3324
		self.run.story.segments.water_lantern = true -- 3325
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 3326
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 3327
	end -- 3327
end -- 3307
function Play.prototype.caught(self) -- 3331
	self.caughtT = 1 -- 3332
	self:flashSet("被抓 · 回到安全点", 1.6) -- 3333
end -- 3331
function Play.prototype.recoverFromCaught(self) -- 3337
	local p = self.player -- 3338
	p.x = self.ox + 140 -- 3339
	p.y = 0 -- 3340
	p.vy = 0 -- 3341
	p.vx = 0 -- 3342
	p.onGround = true -- 3343
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3343
		self.scavX = self.room.scavenger.x0 -- 3345
		self.scavState = "patrol" -- 3346
		self.scavSee = 0 -- 3347
		self.scavChase = false -- 3348
		self.scavT = 0 -- 3349
	end -- 3349
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3349
		self.dogX = self.room.story.dog.x0 -- 3352
		self.dogState = "patrol" -- 3353
		self.dogT = 0 -- 3354
	end -- 3354
	self.cam.x = p.x -- 3356
	self.cam.y = p.y + CAM_LOOK_UP -- 3357
	self:flashSet("回到安全点", 1.2) -- 3358
end -- 3337
function Play.prototype.updateGate(self) -- 3362
	if self.room.key ~= "checkpoint" then -- 3362
		self.gateOpen = false -- 3364
		return -- 3365
	end -- 3365
	local function inZone(x) -- 3367
		return x >= self.ox + 792 and x <= self.ox + 928 -- 3367
	end -- 3367
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 3368
end -- 3362
function Play.prototype.addItem(self, kind) -- 3374
	local inv = self.run.inventory -- 3375
	if kind == "shield" then -- 3375
		if inv.shield >= TOOL_CAP then -- 3375
			return false -- 3378
		end -- 3378
		inv.shield = inv.shield + 1 -- 3380
		return true -- 3381
	end -- 3381
	if kind == "wedge" then -- 3381
		if inv.wedge >= CONSUMABLE_CAP then -- 3381
			return false -- 3385
		end -- 3385
		inv.wedge = inv.wedge + 1 -- 3387
		return true -- 3388
	end -- 3388
	if kind == "ammo" then -- 3388
		if inv.ammo >= CONSUMABLE_CAP then -- 3388
			return false -- 3392
		end -- 3392
		inv.ammo = inv.ammo + 1 -- 3394
		return true -- 3395
	end -- 3395
	if kind == "scrap" then -- 3395
		inv.scrap = inv.scrap + 1 -- 3399
		return true -- 3400
	end -- 3400
	if kind == "wood" then -- 3400
		inv.wood = inv.wood + 1 -- 3403
		return true -- 3404
	end -- 3404
	if kind == "bell" then -- 3404
		inv.bell = inv.bell + 1 -- 3407
		return true -- 3408
	end -- 3408
	if kind == "pass" then -- 3408
		inv.pass = inv.pass + 1 -- 3411
		return true -- 3412
	end -- 3412
	if kind == "quickbelt" then -- 3412
		inv.quickbelt = inv.quickbelt + 1 -- 3415
		return true -- 3416
	end -- 3416
	return false -- 3418
end -- 3374
function Play.prototype.findBox(self, id) -- 3421
	local i = 0 -- 3422
	do -- 3422
		i = 0 -- 3423
		while i < #self.boxes do -- 3423
			if self.boxes[i + 1].id == id then -- 3423
				return self.boxes[i + 1] -- 3425
			end -- 3425
			i = i + 1 -- 3423
		end -- 3423
	end -- 3423
	return nil -- 3428
end -- 3421
function Play.prototype.findWedgeTarget(self) -- 3432
	local best = nil -- 3433
	local bestD = 0 -- 3434
	local i = 0 -- 3435
	do -- 3435
		i = 0 -- 3436
		while i < #self.boxes do -- 3436
			do -- 3436
				local b = self.boxes[i + 1] -- 3437
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3437
					goto __continue526 -- 3439
				end -- 3439
				if not self:nearBox(b, 26) then -- 3439
					goto __continue526 -- 3442
				end -- 3442
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3444
				if best == nil or d < bestD then -- 3444
					best = b -- 3446
					bestD = d -- 3447
				end -- 3447
			end -- 3447
			::__continue526:: -- 3447
			i = i + 1 -- 3436
		end -- 3436
	end -- 3436
	return best -- 3450
end -- 3432
function Play.prototype.stepCraft(self, input) -- 3458
	local inv = self.run.inventory -- 3459
	local required = math.max( -- 3460
		6, -- 3460
		CRAFT_TICKS - 6 * self:talentRank("salvage") -- 3460
	) -- 3460
	if self.craftT > 0 then -- 3460
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3460
			self.craftT = 0 -- 3464
			self:flashSet("制作中断", 0.8) -- 3465
			return true -- 3466
		end -- 3466
		self.craftT = self.craftT + 1 -- 3468
		if self.craftT >= required then -- 3468
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3468
				inv.scrap = inv.scrap - 1 -- 3471
				inv.wedge = inv.wedge + 1 -- 3472
				self:flashSet("制得木楔", 1.2) -- 3473
				self:log("制木楔") -- 3474
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3475
			end -- 3475
			self.craftT = 0 -- 3477
		end -- 3477
		return true -- 3479
	end -- 3479
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3479
		self.craftT = 1 -- 3482
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3483
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3484
		return true -- 3485
	end -- 3485
	return false -- 3487
end -- 3458
function Play.prototype.nearBox(self, b, reach) -- 3490
	local p = self.player -- 3491
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3492
end -- 3490
function Play.prototype.findInteract(self) -- 3498
	local p = self.player -- 3499
	local best = nil -- 3500
	local bestD = 1000000000 -- 3501
	local i = 0 -- 3502
	do -- 3502
		i = 0 -- 3503
		while i < #self.boxes do -- 3503
			do -- 3503
				local b = self.boxes[i + 1] -- 3504
				if b.interact == nil or b.broken == true then -- 3504
					goto __continue539 -- 3506
				end -- 3506
				if not self:nearBox(b, b.interact.reach or 27) then -- 3506
					goto __continue539 -- 3509
				end -- 3509
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3511
				if d < bestD then -- 3511
					bestD = d -- 3513
					best = b -- 3514
				end -- 3514
			end -- 3514
			::__continue539:: -- 3514
			i = i + 1 -- 3503
		end -- 3503
	end -- 3503
	return best -- 3517
end -- 3498
function Play.prototype.stepCampaign(self, dt, input) -- 3521
	local wr = self.room -- 3522
	local p = self.player -- 3523
	if self.reloadT > 0 then -- 3523
		self.reloadT = self.reloadT - 1 -- 3525
	end -- 3525
	if self.bracedShield ~= nil then -- 3525
		self.bracedShield.x = p.x + p.facing * 26 -- 3529
		self.bracedShield.y = p.y -- 3530
		local shBox = __TS__ArrayFind( -- 3531
			self.boxes, -- 3531
			function(____, b) return b.id == "braced_shield" end -- 3531
		) -- 3531
		if shBox ~= nil then -- 3531
			shBox.x0 = self.bracedShield.x - 15 -- 3533
			shBox.x1 = self.bracedShield.x + 15 -- 3534
			shBox.y0 = self.bracedShield.y -- 3535
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3536
		end -- 3536
	end -- 3536
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3536
		self.run.route = "drygoods" -- 3542
		self.run.joined = false -- 3543
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3544
		self:log("转布行线") -- 3545
	end -- 3545
	if wr.key == "escort3" then -- 3545
		local nearBench = p.x >= wr.minX + 472 and p.x <= wr.minX + 710 and p.y < 60 -- 3550
		if nearBench and input.interact.pressed then -- 3550
			self:openCraftBench() -- 3552
			return -- 3553
		end -- 3553
		local ____temp_103 = self.storyRoute == "soldier" -- 3555
		if ____temp_103 then -- 3555
			local ____opt_101 = self.run.story.talents -- 3555
			____temp_103 = (____opt_101 and ____opt_101.deferred) == true -- 3555
		end -- 3555
		if ____temp_103 and p.x >= wr.minX + 940 then -- 3555
			self:triggerDeferredEscort3Draft() -- 3556
		end -- 3556
	end -- 3556
	local i = 0 -- 3560
	do -- 3560
		i = 0 -- 3561
		while i < #self.pickups do -- 3561
			do -- 3561
				local pk = self.pickups[i + 1] -- 3562
				if self.run.taken[pk.id] == true then -- 3562
					goto __continue553 -- 3564
				end -- 3564
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3566
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3567
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3567
					if not self:addItem(pk.kind) then -- 3567
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3571
						self:log("满包拒绝 " .. pk.kind) -- 3572
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3573
						goto __continue553 -- 3574
					end -- 3574
					self.run.taken[pk.id] = true -- 3576
					self:flashSet("拾取 " .. pk.label, 1) -- 3577
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3578
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3579
				end -- 3579
			end -- 3579
			::__continue553:: -- 3579
			i = i + 1 -- 3561
		end -- 3561
	end -- 3561
	self.calmConsumed = false -- 3583
	local ____temp_109 = self.partner.alive and self.run.joined -- 3584
	if ____temp_109 then -- 3584
		local ____opt_104 = self.room.campaign -- 3584
		local ____temp_108 = (____opt_104 and ____opt_104.chapter) == "S" -- 3585
		if not ____temp_108 then -- 3585
			local ____opt_106 = self.room.campaign -- 3585
			____temp_108 = (____opt_106 and ____opt_106.chapter) == "C" -- 3585
		end -- 3585
		____temp_109 = ____temp_108 -- 3584
	end -- 3584
	if ____temp_109 and (self.escort.fear > 0 or self.escort.state == "frozen" or self.escort.state == "calming") then -- 3584
		local dist = inReachDepth(p.depth, self.partner.depth) and math.abs(p.x - self.partner.x) or 1000000000 -- 3587
		local hadK1 = self.escort.knock1 -- 3588
		local hadK2 = self.escort.knock2 -- 3589
		self.calmConsumed = self.escort:update( -- 3590
			input, -- 3590
			p.x, -- 3590
			p.facing, -- 3590
			self.partner.x, -- 3590
			dist -- 3590
		) -- 3590
		if not hadK1 and self.escort.knock1 then -- 3590
			self:emit("knock", {count = 1, x = self.partner.x, room = self.room.key}) -- 3592
		end -- 3592
		if not hadK2 and self.escort.knock2 then -- 3592
			self:emit("knock", {count = 2, x = self.partner.x, room = self.room.key}) -- 3595
		end -- 3595
		self.partner.crouch = self.escort.crouchPose -- 3597
		self.partner.h = self.partner.crouch and CHILD_CROUCH_H or CHILD_H -- 3598
	end -- 3598
	if not self.calmConsumed and not self:stepCraft(input) and input.interact.pressed then -- 3598
		self:campaignInteract() -- 3601
	end -- 3601
	self:stepCampaignCart(dt, input) -- 3603
	self:stepCampaignGoal() -- 3604
	self:campaignCheckpoint() -- 3605
end -- 3521
function Play.prototype.campaignCheckpoint(self) -- 3609
	local i = 0 -- 3610
	do -- 3610
		i = 0 -- 3611
		while i < #self.room.marks do -- 3611
			do -- 3611
				local m = self.room.marks[i + 1] -- 3612
				if m.kind ~= 0 then -- 3612
					goto __continue563 -- 3614
				end -- 3614
				local dx = self.player.x - m.x -- 3616
				local dy = self.player.y - m.y -- 3617
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3617
					self.checkpoint = m.x -- 3619
					self:captureCheckpoint(m.x) -- 3620
					self:flashSet("检查点", 1) -- 3621
				end -- 3621
			end -- 3621
			::__continue563:: -- 3621
			i = i + 1 -- 3611
		end -- 3611
	end -- 3611
end -- 3609
function Play.prototype.campaignInteract(self) -- 3627
	local b = self:findInteract() -- 3628
	if b ~= nil then -- 3628
		self:useInteract(b) -- 3630
		return -- 3631
	end -- 3631
	local inv = self.run.inventory -- 3633
	if inv.wedge > 0 then -- 3633
		local w = self:findWedgeTarget() -- 3635
		if w ~= nil then -- 3635
			local ____opt_110 = w.breakable -- 3635
			local extraHp = (____opt_110 and ____opt_110.wedgeHp or 1) + self:talentRank("salvage") -- 3637
			if w.breakable ~= nil then -- 3637
				local ____w_breakable_112, ____hp_113 = w.breakable, "hp" -- 3637
				____w_breakable_112[____hp_113] = ____w_breakable_112[____hp_113] + extraHp -- 3639
			end -- 3639
			inv.wedge = inv.wedge - 1 -- 3641
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3642
			self:flashSet( -- 3644
				extraHp > 1 and ("钉木楔 · 多承" .. tostring(extraHp)) .. "次" or "钉木楔 · 多承一次", -- 3644
				1.2 -- 3644
			) -- 3644
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3645
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3646
			return -- 3647
		end -- 3647
		if self:isEscortRoom() then -- 3647
			local p = self.player -- 3650
			local wx = math.max( -- 3651
				self.room.minX + 64, -- 3651
				math.min(self.room.maxX - 64, p.x + p.facing * 32) -- 3651
			) -- 3651
			local hp = 1 + self:talentRank("salvage") -- 3652
			self.fieldWedgeSeq = self.fieldWedgeSeq + 1 -- 3653
			local wid = "field_wedge_" .. tostring(self.fieldWedgeSeq) -- 3654
			local ____self_boxes_114 = self.boxes -- 3654
			____self_boxes_114[#____self_boxes_114 + 1] = { -- 3655
				x0 = wx - 12, -- 3656
				x1 = wx + 12, -- 3657
				y0 = p.y, -- 3658
				y1 = p.y + 48, -- 3659
				depth = {min = p.depth - 20, max = p.depth + 20}, -- 3660
				label = "立起的木楔掩体", -- 3661
				id = wid, -- 3662
				breakable = {hp = hp, kind = "thin_wood", wedgeable = true} -- 3663
			} -- 3663
			inv.wedge = inv.wedge - 1 -- 3665
			self:flashSet( -- 3666
				"立木楔 · 临时挡弹" .. (hp > 1 and ("(" .. tostring(hp)) .. "击)" or ""), -- 3666
				1.2 -- 3666
			) -- 3666
			self:log("立木楔掩体") -- 3667
			self:emit("interactUsed", {kind = "wedge", x = wx}) -- 3668
			return -- 3669
		end -- 3669
	end -- 3669
	if inv.ammo > 0 and self.reloadT > 0 then -- 3669
		self.reloadT = 0 -- 3674
		self:closeReloadPuzzle() -- 3675
		inv.ammo = inv.ammo - 1 -- 3676
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3677
		self:log("用备用弹包") -- 3678
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3679
		return -- 3680
	end -- 3680
	local canBraceHere = self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 or self:isEscortRoom() -- 3682
	if inv.shield > 0 and self.bracedShield == nil and canBraceHere then -- 3682
		local p = self.player -- 3686
		local shHp = 1 + self:talentRank("salvage") -- 3687
		self.bracedShield = { -- 3688
			x = p.x + p.facing * 26, -- 3688
			y = p.y, -- 3688
			w = 30, -- 3688
			h = 64, -- 3688
			hp = shHp -- 3688
		} -- 3688
		local ____self_boxes_115 = self.boxes -- 3688
		____self_boxes_115[#____self_boxes_115 + 1] = { -- 3689
			x0 = self.bracedShield.x - 15, -- 3690
			x1 = self.bracedShield.x + 15, -- 3690
			y0 = p.y, -- 3691
			y1 = p.y + 64, -- 3691
			depth = {min = -46, max = 46}, -- 3691
			label = "架起的残盾", -- 3691
			id = "braced_shield", -- 3691
			soft = true -- 3692
		} -- 3692
		inv.shield = inv.shield - 1 -- 3694
		self:flashSet( -- 3695
			shHp > 1 and ("架残盾 · 可挡" .. tostring(shHp)) .. "发" or "架残盾 · 挡一发", -- 3695
			1.2 -- 3695
		) -- 3695
		self:log("架残盾") -- 3696
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3697
		return -- 3698
	end -- 3698
	if inv.pass > 0 and self.run.joined == false then -- 3698
		inv.pass = inv.pass - 1 -- 3701
		self.run.joined = true -- 3702
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3703
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3704
		return -- 3705
	end -- 3705
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3707
end -- 3627
function Play.prototype.useInteract(self, b) -- 3710
	local kind = b.interact == nil and "" or b.interact.kind -- 3711
	local wr = self.room -- 3712
	if kind == "open_board" then -- 3712
		b.broken = true -- 3714
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3715
		for ____, cover in ipairs(self.boxes) do -- 3716
			if cover.id == "s2_board_cover" then -- 3716
				cover.broken = false -- 3718
				cover.hidden = false -- 3719
			end -- 3719
		end -- 3719
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3722
		self.run.joined = true -- 3723
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3724
		self:log("放下窗板") -- 3725
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3726
		return -- 3727
	end -- 3727
	if kind == "lower_curtain" then -- 3727
		for ____, curtain in ipairs(self.boxes) do -- 3730
			if curtain.id == "c2_curtain" then -- 3730
				curtain.broken = false -- 3732
				curtain.hidden = false -- 3733
			end -- 3733
		end -- 3733
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3736
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3737
		self:log("放下木帘") -- 3738
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3739
		return -- 3740
	end -- 3740
	if kind == "raise_latch" then -- 3740
		if wr.key == "c2-granary" and not self.cartDocked then -- 3740
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3744
			return -- 3745
		end -- 3745
		b.broken = true -- 3747
		self.objectiveDone = true -- 3748
		if wr.key == "c1-yard" then -- 3748
			self.run.c1Latch = true -- 3751
			self.run.joined = true -- 3752
			for ____, door in ipairs(self.boxes) do -- 3753
				if door.id == "c1_door" then -- 3753
					door.broken = true -- 3755
				end -- 3755
			end -- 3755
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3758
		else -- 3758
			self.run.c2Latch = true -- 3760
			self.run.joined = true -- 3761
		end -- 3761
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3763
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3764
		self:log("抬闩") -- 3765
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3766
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3767
	end -- 3767
end -- 3710
function Play.prototype.stepCampaignCart(self, dt, input) -- 3772
	local wr = self.room -- 3773
	local c = wr.cart -- 3774
	if c.bodyW <= 0 then -- 3774
		return -- 3776
	end -- 3776
	local p = self.player -- 3778
	local handleX = self.cartAxle + c.handleOffset -- 3779
	if not self.gripping then -- 3779
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3779
			self.gripping = true -- 3783
			self:flashSet("握住车柄 · A/D 推", 1) -- 3784
		end -- 3784
		return -- 3786
	end -- 3786
	if input.interact.pressed then -- 3786
		self.gripping = false -- 3789
		self:flashSet("松手", 0.5) -- 3790
		return -- 3791
	end -- 3791
	if not self.cartDocked then -- 3791
		if input.moveX ~= 0 and not self:stuckCart() then -- 3791
			self.cartAxle = math.max( -- 3795
				c.startX, -- 3795
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3795
			) -- 3795
		end -- 3795
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3795
			self.cartExposed = true -- 3800
			local gun = nil -- 3801
			local gi = 0 -- 3802
			do -- 3802
				gi = 0 -- 3803
				while gi < #self.enemies do -- 3803
					local e = self.enemies[gi + 1] -- 3804
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3804
						gun = e -- 3806
						break -- 3807
					end -- 3807
					gi = gi + 1 -- 3803
				end -- 3803
			end -- 3803
			if gun ~= nil then -- 3803
				self:campaignEnemyFire(gun) -- 3811
			end -- 3811
		end -- 3811
		p.x = self.cartAxle + c.handleOffset -- 3814
		p.y = c.baseY -- 3815
		p.depth = c.depth or 0 -- 3816
		p.vx = 0 -- 3817
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3817
			self.cartAxle = c.endX -- 3819
			self.cartDocked = true -- 3820
			self.gripping = false -- 3821
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3822
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3823
			self:flashSet("车轮入窝", 1.2) -- 3824
			self:log("车轮入窝") -- 3825
		end -- 3825
	end -- 3825
end -- 3772
function Play.prototype.stuckCart(self) -- 3831
	local i = 0 -- 3832
	do -- 3832
		i = 0 -- 3833
		while i < #self.boxes do -- 3833
			do -- 3833
				local b = self.boxes[i + 1] -- 3834
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3834
					goto __continue606 -- 3836
				end -- 3836
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3838
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3838
					return true -- 3840
				end -- 3840
			end -- 3840
			::__continue606:: -- 3840
			i = i + 1 -- 3833
		end -- 3833
	end -- 3833
	return false -- 3843
end -- 3831
function Play.prototype.stepCampaignGoal(self) -- 3847
	local wr = self.room -- 3848
	local c = wr.campaign -- 3849
	if c == nil then -- 3849
		return -- 3851
	end -- 3851
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3851
		self.objectiveDone = true -- 3854
	end -- 3854
	if c.goal == "reach_exit" then -- 3854
		self.objectiveDone = true -- 3857
	end -- 3857
	if not self.objectiveDone then -- 3857
		return -- 3860
	end -- 3860
	local p = self.player -- 3862
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3863
	if p.x < c.exitX or not partnerOk then -- 3863
		return -- 3865
	end -- 3865
	if self.run.story.segments[wr.key] ~= true then -- 3865
		self.run.story.segments[wr.key] = true -- 3869
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3870
	end -- 3870
	if wr.key == "escort5" then -- 3870
		self.escortDone = true -- 3874
		self.run.story.escortDone = true -- 3875
	end -- 3875
	if c.next ~= nil and c.next ~= "" then -- 3875
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3878
		self:flashSet("过关 · " .. c.next, 1.2) -- 3879
	elseif wr.key == "c2-granary" and (self.run.source == "official" or self.run.source == "chapter") then -- 3879
		self:requestRoom("gate", "军粮棚出口") -- 3882
		self:flashSet("出军粮棚 · 城门", 1.4) -- 3883
	elseif not self.run.finished then -- 3883
		self.run.finished = true -- 3885
		self:flashSet( -- 3886
			"军粮棚清完 · 回城门 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3886
			2 -- 3886
		) -- 3886
		self:log("军粮棚清完 · 回城门") -- 3887
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3888
	end -- 3888
end -- 3847
function Play.prototype.stepCampaignPartner(self, dt) -- 3893
	local a = self.partner -- 3894
	local wr = self.room -- 3895
	local cp = wr.companion -- 3896
	if not a.alive then -- 3896
		return -- 3898
	end -- 3898
	local p = self.player -- 3900
	if self.craftBench.active then -- 3900
		a.vx = 0 -- 3903
		return -- 3904
	end -- 3904
	local wait = false -- 3906
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3907
	local targetDepth = p.depth -- 3908
	if self.run.joined == false then -- 3908
		wait = true -- 3910
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3911
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3912
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3912
		wait = true -- 3914
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3915
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3916
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3916
		wait = true -- 3918
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3919
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3920
	end -- 3920
	if self.partnerStuck > 0.3 then -- 3920
		a.x = a.x + a.facing * 44 -- 3924
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3925
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3926
		self.partnerLaneHold = 1.1 -- 3927
		self.partnerStuck = 0 -- 3928
	end -- 3928
	if self.partnerLaneHold > 0 then -- 3928
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3931
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3932
	end -- 3932
	local dx = targetX - a.x -- 3934
	local stopTol = wait and 18 or 74 -- 3935
	if math.abs(dx) > stopTol then -- 3935
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3937
		local before = a.x -- 3938
		a.vx = dx > 0 and speed or -speed -- 3939
		a.facing = dx > 0 and 1 or -1 -- 3940
		self:slideX(a, a.vx * dt) -- 3941
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3941
			a.vy = CHILD_JUMP -- 3944
			a.onGround = false -- 3945
		end -- 3945
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3947
	else -- 3947
		a.vx = 0 -- 3949
		self.partnerStuck = 0 -- 3950
	end -- 3950
	local dz = targetDepth - a.depth -- 3952
	if math.abs(dz) > 6 then -- 3952
		local step = math.max( -- 3954
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3954
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3954
		) -- 3954
		a.depth = a.depth + step -- 3955
	end -- 3955
	a.depthSpeed = 0 -- 3957
	a.h = CHILD_H -- 3958
	a.crouch = false -- 3959
	self:fallY(a, dt) -- 3960
end -- 3893
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3964
	local p = self.player -- 3965
	local i = 0 -- 3966
	do -- 3966
		i = 0 -- 3967
		while i < #self.enemies and not self.escortFailed do -- 3967
			do -- 3967
				local e = self.enemies[i + 1] -- 3968
				if e.kind == "target" then -- 3968
					if not e.alive then -- 3968
						if e.hitT > 0 then -- 3968
							e.hitT = e.hitT - dt -- 3973
						end -- 3973
						if e.hitT <= 0 then -- 3973
							e.alive = true -- 3976
							e.hitT = 0 -- 3977
						end -- 3977
					end -- 3977
					goto __continue634 -- 3980
				end -- 3980
				if not e.alive then -- 3980
					goto __continue634 -- 3983
				end -- 3983
				if e.kind == "breaker" then -- 3983
					self:stepBreaker(e, dt) -- 3986
					goto __continue634 -- 3987
				end -- 3987
				if e.kind == "shield" then -- 3987
					self:stepShield(e, dt, input) -- 3990
					goto __continue634 -- 3991
				end -- 3991
				local dx = e.x - p.x -- 3994
				if not e.awake then -- 3994
					if math.abs(dx) > 520 then -- 3994
						goto __continue634 -- 3997
					end -- 3997
					e.awake = true -- 3999
					e.fireCd = 48 -- 4000
					goto __continue634 -- 4001
				end -- 4001
				if math.abs(dx) > ENEMY_RANGE then -- 4001
					goto __continue634 -- 4004
				end -- 4004
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 4004
					goto __continue634 -- 4009
				end -- 4009
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 4009
					goto __continue634 -- 4012
				end -- 4012
				if self:blockedShot(e, p) then -- 4012
					if e.warnT > 0 then -- 4012
						e.warnT = 0 -- 4018
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4019
					end -- 4019
					goto __continue634 -- 4021
				end -- 4021
				if e.warnT > 0 then -- 4021
					e.warnT = e.warnT - 1 -- 4024
					if e.warnT <= 0 then -- 4024
						self:campaignEnemyFire(e) -- 4026
					end -- 4026
				elseif e.fireCd > 0 then -- 4026
					e.fireCd = e.fireCd - 1 -- 4029
					if e.fireCd <= 0 then -- 4029
						e.warnT = WARN_TICKS -- 4031
					end -- 4031
				else -- 4031
					e.fireCd = 40 -- 4034
				end -- 4034
			end -- 4034
			::__continue634:: -- 4034
			i = i + 1 -- 3967
		end -- 3967
	end -- 3967
end -- 3964
function Play.prototype.blockedShot(self, e, p) -- 4040
	local eDepth = e.depth or 0 -- 4041
	local ex = e.x -- 4042
	local ey = e.y + e.h * 0.62 -- 4044
	local px = p.x -- 4045
	local py = p.y + p.h * 0.55 -- 4046
	local dx = px - ex -- 4047
	local dyScreen = py + p.depth * DEPTH_Y_SCALE - (ey + eDepth * DEPTH_Y_SCALE) -- 4048
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 4049
	if len < 0.01 then -- 4049
		return false -- 4051
	end -- 4051
	local ray = { -- 4055
		x = ex, -- 4056
		y = ey, -- 4056
		dx = dx / len, -- 4057
		dy = (py - ey) / len, -- 4057
		depth = eDepth, -- 4058
		dDepth = (p.depth - eDepth) / len -- 4058
	} -- 4058
	local best = -1 -- 4060
	local j = 0 -- 4061
	do -- 4061
		j = 0 -- 4062
		while j < #self.boxes do -- 4062
			do -- 4062
				local b = self.boxes[j + 1] -- 4063
				if b.broken == true or b.passable == true or b.hidden == true then -- 4063
					goto __continue657 -- 4065
				end -- 4065
				if b.id == "braced_shield" then -- 4065
					goto __continue657 -- 4070
				end -- 4070
				local t = hitBox(ray, b) -- 4072
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 4072
					best = t -- 4076
				end -- 4076
			end -- 4076
			::__continue657:: -- 4076
			j = j + 1 -- 4062
		end -- 4062
	end -- 4062
	return best >= 0 -- 4079
end -- 4040
function Play.prototype.campaignEnemyFire(self, e) -- 4082
	local p = self.player -- 4083
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4084
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 4084
		local ____self_bracedShield_116, ____hp_117 = self.bracedShield, "hp" -- 4084
		____self_bracedShield_116[____hp_117] = ____self_bracedShield_116[____hp_117] - 1 -- 4086
		if self.bracedShield.hp <= 0 then -- 4086
			self.boxes = __TS__ArrayFilter( -- 4088
				self.boxes, -- 4088
				function(____, b) return b.id ~= "braced_shield" end -- 4088
			) -- 4088
			self.bracedShield = nil -- 4089
			self:flashSet("残盾碎 · 挡下一发", 1) -- 4090
		else -- 4090
			self:flashSet( -- 4092
				"残盾挡下一发 · 余" .. tostring(self.bracedShield.hp), -- 4092
				1 -- 4092
			) -- 4092
		end -- 4092
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 4094
		return -- 4095
	end -- 4095
	if self:blockedShot(e, p) then -- 4095
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4098
		return -- 4099
	end -- 4099
	local cover = self:blockedByCover(e, p) -- 4101
	if cover ~= nil and self.coverHug then -- 4101
		self.coveredFlash = 0.5 -- 4103
		self:flashSet("掩体挡下", 0.6) -- 4104
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4105
		return -- 4110
	end -- 4110
	if self.invulnT > 0 then -- 4110
		return -- 4113
	end -- 4113
	self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4115
	self.craftT = 0 -- 4116
	self.hp = self.hp - 1 -- 4117
	self:emit("actorHit", { -- 4118
		target = "player", -- 4118
		amount = 1, -- 4118
		hp = self.hp, -- 4118
		maxHp = self.maxHp, -- 4118
		enemyX = e.x -- 4118
	}) -- 4118
	self:flashSet( -- 4119
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4119
		0.8 -- 4119
	) -- 4119
	if self.hp <= 0 then -- 4119
		self:campaignFailed() -- 4121
	end -- 4121
end -- 4082
function Play.prototype.stepShield(self, e, dt, input) -- 4126
	local p = self.player -- 4127
	local dx = p.x - e.x -- 4128
	local adx = math.abs(dx) -- 4129
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 4132
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 4133
	if adx > 44 then -- 4133
		local before = e.x -- 4135
		local stepX = (dx > 0 and 1 or -1) * 60 * dt -- 4136
		local nextX = math.max( -- 4137
			self.room.minX + 16, -- 4137
			math.min(self.room.maxX - 16, e.x + stepX) -- 4137
		) -- 4137
		if not self:enemyBlockedAtX(e, nextX) then -- 4137
			e.x = nextX -- 4139
		end -- 4139
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 4139
			e.depth = math.max( -- 4143
				-32, -- 4143
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4143
			) -- 4143
		end -- 4143
	elseif adx <= 48 and sameLane and (e.swingT or 0) <= 0 then -- 4143
		local fromFront = (e.x - p.x) * p.facing > 0 -- 4148
		local rollDodges = p.rollT > 0 and (fromFront or self:talentRank("guard") > 0) -- 4149
		if not rollDodges and self.invulnT <= 0 then -- 4149
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4151
			self.craftT = 0 -- 4152
			self.hp = self.hp - 1 -- 4153
			self:emit("actorHit", { -- 4154
				target = "player", -- 4154
				amount = 1, -- 4154
				hp = self.hp, -- 4154
				maxHp = self.maxHp, -- 4154
				enemyX = e.x -- 4154
			}) -- 4154
			self:flashSet( -- 4155
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4155
				0.8 -- 4155
			) -- 4155
			if self.hp <= 0 then -- 4155
				self:campaignFailed() -- 4157
				return -- 4158
			end -- 4158
		end -- 4158
		e.swingT = 70 -- 4161
	end -- 4161
	if (e.swingT or 0) > 0 then -- 4161
		e.swingT = (e.swingT or 0) - 1 -- 4164
	end -- 4164
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 4164
		local dd = p.depth - (e.depth or 0) -- 4167
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 4168
	end -- 4168
end -- 4126
function Play.prototype.stepBreaker(self, e, dt) -- 4173
	local p = self.player -- 4174
	if e.awake ~= true then -- 4174
		if math.abs(p.x - e.x) < 560 then -- 4174
			e.awake = true -- 4177
		else -- 4177
			return -- 4179
		end -- 4179
	end -- 4179
	local target = nil -- 4182
	local bestD = 1000000000 -- 4183
	local i = 0 -- 4184
	do -- 4184
		i = 0 -- 4185
		while i < #self.boxes do -- 4185
			do -- 4185
				local b = self.boxes[i + 1] -- 4186
				if b.breakable == nil or b.broken == true then -- 4186
					goto __continue684 -- 4188
				end -- 4188
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 4190
				if d < bestD then -- 4190
					bestD = d -- 4192
					target = b -- 4193
				end -- 4193
			end -- 4193
			::__continue684:: -- 4193
			i = i + 1 -- 4185
		end -- 4185
	end -- 4185
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 4196
	local dx = tx - e.x -- 4197
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 4198
	if math.abs(dx) > reach then -- 4198
		local before = e.x -- 4200
		local nextX = math.max( -- 4201
			self.room.minX + 16, -- 4201
			math.min(self.room.maxX - 16, e.x + (dx > 0 and 1 or -1) * 48 * dt) -- 4201
		) -- 4201
		if not self:enemyBlockedAtX(e, nextX) then -- 4201
			e.x = nextX -- 4203
		end -- 4203
		if math.abs(e.x - before) < 0.3 then -- 4203
			e.depth = math.max( -- 4206
				-32, -- 4206
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4206
			) -- 4206
		end -- 4206
	elseif (e.swingT or 0) <= 0 then -- 4206
		e.swingT = 64 -- 4209
		if target ~= nil then -- 4209
			self:damageProp(target, 2) -- 4211
		elseif math.abs(p.x - e.x) < 60 and math.abs((e.depth or 0) - p.depth) <= 26 and not (p.rollT > 0 and self:talentRank("guard") > 0) and self.invulnT <= 0 then -- 4211
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4214
			self.craftT = 0 -- 4215
			self.hp = self.hp - 1 -- 4216
			self:emit("actorHit", { -- 4217
				target = "player", -- 4217
				amount = 1, -- 4217
				hp = self.hp, -- 4217
				maxHp = self.maxHp, -- 4217
				enemyX = e.x -- 4217
			}) -- 4217
			self:flashSet("破障手近身", 0.8) -- 4218
			if self.hp <= 0 then -- 4218
				self:campaignFailed() -- 4220
				return -- 4221
			end -- 4221
		end -- 4221
	end -- 4221
	if (e.swingT or 0) > 0 then -- 4221
		e.swingT = (e.swingT or 0) - 1 -- 4226
	end -- 4226
end -- 4173
function Play.prototype.enemyBlockedAtX(self, e, nextX) -- 4231
	local half = e.w * 0.5 -- 4232
	local d = e.depth or 0 -- 4233
	local i = 0 -- 4234
	do -- 4234
		i = 0 -- 4235
		while i < #self.boxes do -- 4235
			do -- 4235
				local b = self.boxes[i + 1] -- 4236
				if b.broken == true or b.passable == true or b.soft == true or b.hidden == true or b.y0 >= e.y + e.h or b.y1 <= e.y + 4 then -- 4236
					goto __continue697 -- 4238
				end -- 4238
				if b.depth ~= nil and (d < b.depth.min - 8 or d > b.depth.max + 8) then -- 4238
					goto __continue697 -- 4241
				end -- 4241
				if nextX + half > b.x0 and nextX - half < b.x1 then -- 4241
					return true -- 4244
				end -- 4244
			end -- 4244
			::__continue697:: -- 4244
			i = i + 1 -- 4235
		end -- 4235
	end -- 4235
	return false -- 4247
end -- 4231
function Play.prototype.campaignFailed(self) -- 4250
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 4250
		if self.escortFailed then -- 4250
			return -- 4255
		end -- 4255
		if self.useEscortDeathSummary then -- 4255
			local story = self.run.story -- 4257
			local st = story.talents -- 4258
			local ranksCopy = { -- 4259
				vitality = st and st.ranks.vitality or 0, -- 4260
				guard = st and st.ranks.guard or 0, -- 4261
				stride = st and st.ranks.stride or 0, -- 4262
				focus = st and st.ranks.focus or 0, -- 4263
				push_force = st and st.ranks.push_force or 0, -- 4264
				echo_wide = st and st.ranks.echo_wide or 0, -- 4265
				lantern_pierce = st and st.ranks.lantern_pierce or 0, -- 4266
				salvage = st and st.ranks.salvage or 0 -- 4267
			} -- 4267
			local cleared = 0 -- 4269
			local segKeys = { -- 4270
				"escort1", -- 4270
				"escort2", -- 4270
				"escort3", -- 4270
				"escort4", -- 4270
				"escort5" -- 4270
			} -- 4270
			local si = 0 -- 4271
			do -- 4271
				si = 0 -- 4272
				while si < #segKeys do -- 4272
					if story.segments[segKeys[si + 1]] == true then -- 4272
						cleared = cleared + 1 -- 4274
					end -- 4274
					si = si + 1 -- 4272
				end -- 4272
			end -- 4272
			self.escortFailed = true -- 4277
			self.escortFailedTicks = 0 -- 4278
			self.talentModalActive = false -- 4279
			self.craftBench.active = false -- 4280
			self.reloadT = 0 -- 4281
			self:closeReloadPuzzle() -- 4282
			self.gripping = false -- 4283
			self.escortSummary = { -- 4284
				roomKey = self.room.key, -- 4285
				attempt = st ~= nil and math.max(1, st.attempt) or 1, -- 4286
				seed = st ~= nil and st.randomState or self.run.seed, -- 4287
				equippedWeapon = self.equippedWeapon, -- 4288
				segmentsCleared = cleared, -- 4289
				ranks = ranksCopy -- 4290
			} -- 4290
			self:resetEscortAttempt() -- 4292
			self:flashSet("折返山道 · 重整再赴", 2) -- 4293
			self:log("男主线折返 · 展示小结") -- 4294
			self:emit("campaignFailed", { -- 4295
				room = self.room.key, -- 4296
				hp = 0, -- 4296
				maxHp = self.maxHp, -- 4296
				reset = true, -- 4297
				to = "escort1", -- 4297
				route = self.storyRoute, -- 4297
				summary = true -- 4297
			}) -- 4297
			return -- 4299
		end -- 4299
		self:restartEscortRun() -- 4301
		return -- 4302
	end -- 4302
	local p = self.player -- 4304
	self.hp = self.maxHp -- 4305
	self.invulnT = INVULN_RESPAWN_TICKS -- 4306
	self.reloadT = 0 -- 4307
	self:closeReloadPuzzle() -- 4308
	self.gripping = false -- 4309
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 4310
	self:log("被击倒") -- 4311
	p.x = self.room.minX + 90 -- 4312
	p.y = 0 -- 4313
	p.depth = 0 -- 4314
	p.vx = 0 -- 4315
	p.vy = 0 -- 4316
	p.onGround = true -- 4317
	p.rollT = 0 -- 4318
	self.partner.x = p.x - 50 -- 4319
	self.partner.y = 0 -- 4320
	self.partner.depth = 0 -- 4321
	self.cam.x = p.x -- 4322
	local i = 0 -- 4323
	do -- 4323
		i = 0 -- 4324
		while i < #self.enemies do -- 4324
			do -- 4324
				local e = self.enemies[i + 1] -- 4325
				if not e.alive then -- 4325
					goto __continue709 -- 4327
				end -- 4327
				e.x = e.homeX == nil and e.x or e.homeX -- 4329
				e.warnT = 0 -- 4330
				e.fireCd = 40 -- 4331
				e.swingT = 0 -- 4332
				e.awake = false -- 4333
			end -- 4333
			::__continue709:: -- 4333
			i = i + 1 -- 4324
		end -- 4324
	end -- 4324
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4335
end -- 4250
function Play.prototype.isEscortRoom(self) -- 4339
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 4340
end -- 4339
function Play.prototype.confirmEscortRestart(self) -- 4344
	if not self.escortFailed then -- 4344
		return false -- 4346
	end -- 4346
	self:requestRoom("escort1", "男主线失败重开") -- 4348
	return true -- 4349
end -- 4344
function Play.prototype.restartEscortRun(self) -- 4353
	self:resetEscortAttempt() -- 4354
	self:requestRoom("escort1", "男主线失败重开") -- 4355
end -- 4353
function Play.prototype.resetEscortAttempt(self) -- 4363
	local story = self.run.story -- 4364
	local inv = self.run.inventory -- 4365
	local prevAttempt = story.talents ~= nil and math.max(1, story.talents.attempt) or 1 -- 4366
	local nextAttempt = prevAttempt + 1 -- 4367
	local vitBonus = story.talents ~= nil and (story.talents.ranks.vitality or 0) or 0 -- 4368
	if vitBonus > 0 then -- 4368
		self.maxHp = math.max(3, self.maxHp - vitBonus) -- 4370
		story.maxHp = self.maxHp -- 4371
	end -- 4371
	story.talents = createStoryTalents(self.run.seed, nextAttempt) -- 4373
	self.hp = self.maxHp -- 4374
	story.hp = self.maxHp -- 4375
	story.cp = nil -- 4376
	self.checkpointSnap = nil -- 4377
	story.carry = false -- 4378
	self.carryOn = false -- 4379
	story.craftedWeapon = "" -- 4380
	self.equippedWeapon = "standard_gun" -- 4381
	story.equippedWeapon = "standard_gun" -- 4382
	story.escortDone = false -- 4383
	self.escortDone = false -- 4384
	story.segments = {} -- 4385
	inv.wood = 0 -- 4386
	inv.bell = 0 -- 4387
	inv.scrap = 0 -- 4388
	inv.wedge = 0 -- 4389
	inv.ammo = 0 -- 4390
	inv.quickbelt = 0 -- 4391
	inv.shield = 0 -- 4392
	inv.pass = 0 -- 4393
	local taken = self.run.taken -- 4394
	local keys = __TS__ObjectKeys(taken) -- 4395
	local i = 0 -- 4396
	do -- 4396
		i = 0 -- 4397
		while i < #keys do -- 4397
			local k = keys[i + 1] -- 4398
			if (string.find(k, "e2_", nil, true) or 0) - 1 == 0 or (string.find(k, "e3_", nil, true) or 0) - 1 == 0 or (string.find(k, "escort", nil, true) or 0) - 1 == 0 then -- 4398
				__TS__Delete(taken, k) -- 4400
			end -- 4400
			i = i + 1 -- 4397
		end -- 4397
	end -- 4397
	local propKeys = __TS__ObjectKeys(self.run.props) -- 4403
	do -- 4403
		i = 0 -- 4404
		while i < #propKeys do -- 4404
			local pk = propKeys[i + 1] -- 4405
			if (string.find(pk, "e1_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e2_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e3_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e4_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e5_", nil, true) or 0) - 1 == 0 or (string.find(pk, "field_wedge_", nil, true) or 0) - 1 == 0 then -- 4405
				__TS__Delete(self.run.props, pk) -- 4408
			end -- 4408
			i = i + 1 -- 4404
		end -- 4404
	end -- 4404
	self.bracedShield = nil -- 4411
	self.talentModalActive = false -- 4412
	self.run.joined = true -- 4413
	self.reloadT = 0 -- 4414
	self:closeReloadPuzzle() -- 4415
	self.gripping = false -- 4416
	self.sessionDirty = true -- 4417
	self:flashSet( -- 4418
		("重整启程 · 第" .. tostring(nextAttempt)) .. "轮护送", -- 4418
		2 -- 4418
	) -- 4418
	self:log(("男主线重开 · 第" .. tostring(nextAttempt)) .. "轮回 escort1") -- 4419
	if not self.useEscortDeathSummary then -- 4419
		self:emit("campaignFailed", { -- 4421
			room = self.room.key, -- 4422
			hp = 0, -- 4422
			maxHp = self.maxHp, -- 4422
			reset = true, -- 4423
			to = "escort1", -- 4423
			route = self.storyRoute, -- 4423
			attempt = nextAttempt -- 4423
		}) -- 4423
	end -- 4423
end -- 4363
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 4429
	local i = 0 -- 4430
	do -- 4430
		i = 0 -- 4431
		while i < #self.enemies do -- 4431
			do -- 4431
				if i == skipIndex then -- 4431
					goto __continue726 -- 4433
				end -- 4433
				local e = self.enemies[i + 1] -- 4435
				if not e.alive or math.abs(e.x - center.x) > radius then -- 4435
					goto __continue726 -- 4437
				end -- 4437
				e.awake = true -- 4439
				e.fireCd = math.max(e.fireCd or 0, 150) -- 4440
				e.warnT = 0 -- 4441
			end -- 4441
			::__continue726:: -- 4441
			i = i + 1 -- 4431
		end -- 4431
	end -- 4431
end -- 4429
function Play.prototype.stepEnemies(self, dt, input) -- 4445
	local i = 0 -- 4446
	do -- 4446
		i = 0 -- 4447
		while i < #self.enemies do -- 4447
			local e = self.enemies[i + 1] -- 4448
			if e.hitT > 0 then -- 4448
				e.hitT = e.hitT - dt -- 4450
			end -- 4450
			i = i + 1 -- 4447
		end -- 4447
	end -- 4447
	if self.coveredFlash > 0 then -- 4447
		self.coveredFlash = self.coveredFlash - dt -- 4454
	end -- 4454
	if self.isCampaign then -- 4454
		self:stepCampaignEnemies(dt, input) -- 4457
		return -- 4458
	end -- 4458
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 4458
		return -- 4462
	end -- 4462
	do -- 4462
		i = 0 -- 4464
		while i < #self.enemies do -- 4464
			do -- 4464
				local e = self.enemies[i + 1] -- 4465
				if not e.alive then -- 4465
					goto __continue737 -- 4467
				end -- 4467
				if e.warnT > 0 then -- 4467
					e.warnT = e.warnT - 1 -- 4470
					if e.warnT <= 0 then -- 4470
						self:enemyFire(e, input) -- 4472
					end -- 4472
					goto __continue737 -- 4474
				end -- 4474
				if e.fireCd > 0 then -- 4474
					e.fireCd = e.fireCd - 1 -- 4477
					if e.fireCd <= 0 then -- 4477
						e.warnT = WARN_TICKS -- 4479
					end -- 4479
				else -- 4479
					e.warnT = WARN_TICKS -- 4483
				end -- 4483
			end -- 4483
			::__continue737:: -- 4483
			i = i + 1 -- 4464
		end -- 4464
	end -- 4464
end -- 4445
function Play.prototype.enemyFire(self, e, input) -- 4489
	local p = self.player -- 4490
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 4490
		self:flashSet("枪声响在远处", 0.4) -- 4492
		e.fireCd = FIRE_COOLDOWN -- 4493
		return -- 4494
	end -- 4494
	if self:blockedShot(e, p) then -- 4494
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4497
		e.fireCd = FIRE_COOLDOWN -- 4498
		return -- 4499
	end -- 4499
	local cover = self:blockedByCover(e, p) -- 4502
	local hugging = cover ~= nil -- 4503
	self.coverBlocking = hugging -- 4504
	local covered = hugging and input.cover.held -- 4505
	if covered then -- 4505
		self.coveredFlash = 0.5 -- 4507
		self:flashSet("掩体挡下", 0.5) -- 4508
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4509
		e.fireCd = FIRE_COOLDOWN -- 4514
		return -- 4515
	end -- 4515
	if self.invulnT > 0 then -- 4515
		e.fireCd = FIRE_COOLDOWN -- 4518
		return -- 4519
	end -- 4519
	self.invulnT = INVULN_HIT_TICKS -- 4521
	self.hp = self.hp - 1 -- 4522
	self:emit("actorHit", { -- 4523
		target = "player", -- 4523
		amount = 1, -- 4523
		hp = self.hp, -- 4523
		maxHp = self.maxHp, -- 4523
		enemyX = e.x -- 4523
	}) -- 4523
	self:flashSet( -- 4524
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4524
		0.7 -- 4524
	) -- 4524
	e.fireCd = FIRE_COOLDOWN -- 4525
	if self.hp <= 0 then -- 4525
		self:gateFailed() -- 4527
	end -- 4527
end -- 4489
function Play.prototype.blockedByCover(self, enemy, p) -- 4532
	local b = self:coverAt(p) -- 4533
	if b == nil then -- 4533
		return nil -- 4535
	end -- 4535
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4537
end -- 4532
function Play.prototype.gateFailed(self) -- 4541
	local ____temp_134 -- 4542
	if self.room.story == nil then -- 4542
		____temp_134 = nil -- 4542
	else -- 4542
		____temp_134 = self.room.story.gate -- 4542
	end -- 4542
	local g = ____temp_134 -- 4542
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 4543
	self.hp = self.maxHp -- 4544
	self.gateTick = 0 -- 4545
	self.gateSpawned = 0 -- 4546
	self.enemies = {} -- 4547
	self.gateFailCount = self.gateFailCount + 1 -- 4548
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 4550
	self.player.y = 0 -- 4551
	self.player.vy = 0 -- 4552
	self.player.depth = 0 -- 4553
	self.player.depthSpeed = 0 -- 4554
	self.player.onGround = true -- 4555
	self.player.crouch = false -- 4556
	self.player.h = SOLDIER_H -- 4557
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 4558
	self.partner.y = 0 -- 4559
	self.partner.vy = 0 -- 4560
	self.partner.depth = 0 -- 4561
	self.partner.depthSpeed = 0 -- 4562
	self.partner.onGround = true -- 4563
	self.cam.x = self.player.x -- 4564
	self.phase = "gate-idle" -- 4565
	self.phaseTick = 0 -- 4566
	self.coverHug = false -- 4567
	self.coverBlocking = false -- 4568
	self.coverEntity = "" -- 4569
	self.gateNeedConfirm = true -- 4570
	self.gateRestartArmed = false -- 4571
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 4572
end -- 4541
function Play.prototype.finishOutsideCart(self) -- 4576
	self.redCartMemoryT = 30 -- 4577
	if self.run.story ~= nil then -- 4577
		self.run.story.segments.outside_cart = true -- 4579
		self.run.story.segments.outside_memory = true -- 4580
	end -- 4580
	self.sessionDirty = true -- 4582
	self:emit("storyBeat", {beat = "red_cart_memory", x = self.player.x, room = "outside", durationTicks = 30}) -- 4583
end -- 4576
function Play.prototype.stepInteract(self, dt, input) -- 4586
	local p = self.player -- 4587
	self.redCartMemoryT = math.max(0, self.redCartMemoryT - 1) -- 4588
	local calmUsed = self.calmConsumed -- 4589
	self.calmConsumed = false -- 4590
	local calming = self.escort.state == "calming" -- 4592
	self.focusCart = false -- 4593
	if self.room.key == "outside" then -- 4593
		self.focusCart = not calmUsed and not calming and self:cartHandleInReach(p) -- 4595
	end -- 4595
	if not calmUsed and not calming then -- 4595
		self:stepCart(dt, input) -- 4599
	end -- 4599
	if calmUsed then -- 4599
		self:flashSet("安抚 · 敲两下", 0.8) -- 4604
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4604
		if self.knockT > 0 then -- 4604
			self.knocks = self.knocks + 1 -- 4608
		else -- 4608
			self.knocks = 1 -- 4610
		end -- 4610
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4612
		self.knockT = 1.2 -- 4613
		if self.knocks >= 2 then -- 4613
			self:flashSet("敲两下", 0.8) -- 4615
			self.knocks = 0 -- 4616
		else -- 4616
			self:flashSet("敲一下", 0.5) -- 4618
		end -- 4618
	elseif self.knockT > 0 then -- 4618
		self.knockT = self.knockT - dt -- 4621
		if self.knockT <= 0 then -- 4621
			self.knocks = 0 -- 4623
		end -- 4623
	end -- 4623
	local i = 0 -- 4628
	do -- 4628
		i = 0 -- 4629
		while i < #self.room.marks do -- 4629
			do -- 4629
				local m = self.room.marks[i + 1] -- 4630
				if m.kind ~= 0 then -- 4630
					goto __continue767 -- 4632
				end -- 4632
				local subjects = {self.partner, self.player} -- 4634
				local k = 0 -- 4635
				do -- 4635
					k = 0 -- 4636
					while k < #subjects do -- 4636
						do -- 4636
							local s = subjects[k + 1] -- 4637
							if not s.alive then -- 4637
								goto __continue770 -- 4639
							end -- 4639
							local dx = s.x - m.x -- 4641
							local dy = s.y - m.y -- 4642
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4642
								self.checkpoint = m.x -- 4644
								self.checkpointCartAxle = self.cartAxle -- 4645
								if self.isCampaign then -- 4645
									self:captureCheckpoint(m.x) -- 4648
								end -- 4648
								if self.room.cart.bodyW > 0 then -- 4648
									if self.cartDocked then -- 4648
										self:flashSet("检查点 · 车已落窝", 1) -- 4652
									else -- 4652
										self:flashSet("检查点 · 车还没到位", 1) -- 4654
									end -- 4654
								else -- 4654
									self:flashSet("检查点", 1) -- 4657
								end -- 4657
							end -- 4657
						end -- 4657
						::__continue770:: -- 4657
						k = k + 1 -- 4636
					end -- 4636
				end -- 4636
			end -- 4636
			::__continue767:: -- 4636
			i = i + 1 -- 4629
		end -- 4629
	end -- 4629
	self:checkCarryGate() -- 4663
end -- 4586
function Play.prototype.stepVillage(self, dt, input) -- 4667
	if self.room.key ~= "village" then -- 4667
		return -- 4669
	end -- 4669
	local p = self.player -- 4671
	local bottle = self.room.bottle -- 4672
	local scav = self.room.scavenger -- 4673
	if not self.hasBottle and bottle ~= nil then -- 4673
		local dx = p.x - bottle.x -- 4677
		local dy = p.y + p.h * 0.5 - bottle.y -- 4678
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4678
			self.hasBottle = true -- 4680
			self:flashSet("拾起瓶子", 0.8) -- 4681
		end -- 4681
	end -- 4681
	if self.hasBottle then -- 4681
		if input.bottleCanceled then -- 4681
			self.aimHold = 0 -- 4688
			self.bottleAimX = -1 -- 4689
		elseif input.aim.held then -- 4689
			self.aimHold = self.aimHold + dt -- 4691
			if self.aimHold > 1.2 then -- 4691
				self.aimHold = 1.2 -- 4693
			end -- 4693
			local cached = self:bottleEnd() -- 4696
			self.bottleAimX = cached.x -- 4697
			self.bottleAimY = cached.y -- 4698
		elseif input.aim.released then -- 4698
			if self.aimHold < 0.12 then -- 4698
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 4702
				self.aimHold = 0 -- 4703
			else -- 4703
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4705
				self:throwBottle(____end.x, ____end.y) -- 4706
				self.aimHold = 0 -- 4707
			end -- 4707
		end -- 4707
	else -- 4707
		self.aimHold = 0 -- 4711
		self.bottleAimX = -1 -- 4712
	end -- 4712
	local fly = self.bottleFly -- 4717
	if fly ~= nil then -- 4717
		fly.t = fly.t + dt -- 4719
		fly.x = fly.x0 + fly.vx * fly.t -- 4720
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4721
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4722
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4722
			self:landBottle(fly) -- 4724
		end -- 4724
	end -- 4724
	if self.bottleLandT > 0 then -- 4724
		self.bottleLandT = self.bottleLandT - dt -- 4728
	end -- 4728
	if scav ~= nil then -- 4728
		self:stepScav(dt, scav) -- 4732
	end -- 4732
	local line = self.room.passLine -- 4735
	if line ~= nil and not self.passed and p.x >= line then -- 4735
		self.passed = true -- 4737
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4738
	end -- 4738
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4741
	if underTable then -- 4741
		self.footHintT = self.footHintT - 1 -- 4743
		if self.footHintT <= 0 then -- 4743
			self.footHintT = 90 -- 4745
			local scavX = self.scavX -- 4746
			local near = math.abs(scavX - p.x) < 120 -- 4747
			local walkingAway = self.scavState == "walk" and math.abs(self.scavTargetX - p.x) >= 120 -- 4748
			local heard = self.scavState == "chase" or near and not walkingAway -- 4749
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4750
			self:emit("storyBeat", {beat = heard and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4751
		end -- 4751
	else -- 4751
		self.footHintT = 0 -- 4754
	end -- 4754
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4754
		self.ditchHinted = true -- 4758
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4759
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4760
	end -- 4760
	local inCulvert = p.x >= self.ox + 560 and p.x <= self.ox + 640 -- 4763
	if self.passed and inCulvert and p.crouch and self.wantRoom == "" then -- 4763
		self:requestRoom("forest", "蹲下钻过暗渠") -- 4765
		self:flashSet("钻进暗渠 · 北塔森林", 1.4) -- 4766
	end -- 4766
end -- 4667
function Play.prototype.bottleEnd(self) -- 4771
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4772
	local clampedX = math.max( -- 4775
		self.room.minX + 12, -- 4775
		math.min(self.room.maxX - 12, aim.x) -- 4775
	) -- 4775
	local g = self:groundAt(clampedX, aim.y + 240, 3) -- 4776
	return {x = clampedX, y = g} -- 4777
end -- 4771
function Play.prototype.throwBottle(self, tx, ty) -- 4781
	local p = self.player -- 4782
	local dir = tx >= p.x and 1 or -1 -- 4784
	p.facing = dir -- 4785
	local x0 = p.x + dir * 10 -- 4786
	local y0 = p.y + p.h * 0.7 -- 4787
	self.bottleTargetX = tx -- 4788
	self.bottleTargetY = ty -- 4789
	self.bottleSurfaceY = ty -- 4790
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4791
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4792
	self.bottleFly = { -- 4793
		x = x0, -- 4793
		y = y0, -- 4793
		x0 = x0, -- 4793
		y0 = y0, -- 4793
		vx = vx, -- 4793
		vy = vy, -- 4793
		t = 0 -- 4793
	} -- 4793
	self.hasBottle = false -- 4794
	self:flashSet("投出", 0.4) -- 4795
	self:emit( -- 4796
		"bottleThrown", -- 4796
		{ -- 4796
			fromX = x0, -- 4797
			fromY = y0, -- 4798
			targetX = tx, -- 4799
			targetY = ty, -- 4800
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4801
		} -- 4801
	) -- 4801
end -- 4781
function Play.prototype.bottleSurfaceAt(self, x) -- 4806
	if self.room.softX ~= nil and math.abs(x - self.room.softX) <= 34 then -- 4806
		return "soft" -- 4808
	end -- 4808
	if self.room.basinX ~= nil and math.abs(x - self.room.basinX) <= 24 then -- 4808
		return "iron" -- 4811
	end -- 4811
	return "brick" -- 4813
end -- 4806
function Play.prototype.landBottle(self, fly) -- 4817
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4818
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4819
	local s = self.room.scavenger -- 4820
	local surface = self:bottleSurfaceAt(x) -- 4821
	local effRange = s == nil and 0 or (surface == "iron" and s.range * 1.25 or s.range) -- 4822
	local heard = surface ~= "soft" and s ~= nil and math.abs(x - self.scavX) <= effRange -- 4823
	local stallTicks = s == nil and 0 or (surface == "iron" and s.stallTicks + 90 or s.stallTicks) -- 4824
	self.bottleFly = nil -- 4825
	self.bottleTargetX = -1 -- 4826
	self.bottleTargetY = 0 -- 4827
	self.bottleSurfaceY = -1 -- 4828
	self.bottleLandX = x -- 4829
	self.bottleLandY = y -- 4830
	self.bottleLandT = 0.9 -- 4831
	self:emit("bottleLanded", { -- 4832
		x = x, -- 4833
		y = y, -- 4834
		surface = surface, -- 4835
		heard = heard, -- 4836
		resonance = surface == "iron", -- 4837
		stallTicks = heard and stallTicks or 0, -- 4838
		scavState = self.scavState -- 4839
	}) -- 4839
	self:hearBottle(x, surface) -- 4841
end -- 4817
function Play.prototype.hearBottle(self, x, surface) -- 4845
	if surface == nil then -- 4845
		surface = "brick" -- 4845
	end -- 4845
	local s = self.room.scavenger -- 4846
	if s == nil then -- 4846
		return -- 4848
	end -- 4848
	if surface == "soft" then -- 4848
		self:flashSet("落在软土 · 没出声", 0.8) -- 4851
		return -- 4852
	end -- 4852
	local effRange = surface == "iron" and s.range * 1.25 or s.range -- 4854
	if math.abs(x - self.scavX) > effRange then -- 4854
		self:flashSet("落地 · 他没听见", 0.6) -- 4856
		return -- 4857
	end -- 4857
	self.scavState = "turn" -- 4859
	self.scavT = s.hearTicks -- 4860
	self.scavTargetX = surface == "iron" and self.room.basinX ~= nil and self.room.basinX or x -- 4861
	self.scavStallBonus = surface == "iron" and 90 or 0 -- 4862
	self:flashSet(surface == "iron" and "铁盆余振两响 · 他停下来细听" or "砖地一响 · 他转头", 1.1) -- 4863
end -- 4845
function Play.prototype.stepScav(self, dt, s) -- 4867
	if self.scavState == "chase" then -- 4867
		return -- 4870
	end -- 4870
	if self.scavState == "turn" then -- 4870
		self.scavT = self.scavT - 1 -- 4873
		if self.scavT <= 0 then -- 4873
			self.scavState = "walk" -- 4875
		end -- 4875
		return -- 4877
	end -- 4877
	if self.scavState == "walk" then -- 4877
		local d = self.scavTargetX - self.scavX -- 4880
		if math.abs(d) < 4 then -- 4880
			self.scavState = "stall" -- 4882
			self.scavT = s.stallTicks + self.scavStallBonus -- 4883
			self.scavStallBonus = 0 -- 4884
			return -- 4885
		end -- 4885
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4887
		return -- 4888
	end -- 4888
	if self.scavState == "stall" then -- 4888
		self.scavT = self.scavT - 1 -- 4891
		if self.scavT <= 0 then -- 4891
			self.scavState = "back" -- 4893
		end -- 4893
		return -- 4895
	end -- 4895
	if self.scavState == "back" then -- 4895
		local home = math.max( -- 4898
			s.x0, -- 4898
			math.min(s.x1, self.scavX) -- 4898
		) -- 4898
		if math.abs(home - self.scavX) < 2 then -- 4898
			self.scavState = "patrol" -- 4900
			return -- 4901
		end -- 4901
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4903
		return -- 4904
	end -- 4904
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4906
	if self.scavX >= s.x1 then -- 4906
		self.scavX = s.x1 -- 4908
		self.scavDir = -1 -- 4909
	elseif self.scavX <= s.x0 then -- 4909
		self.scavX = s.x0 -- 4911
		self.scavDir = 1 -- 4912
	end -- 4912
end -- 4867
function Play.prototype.stepCart(self, dt, input) -- 4920
	local p = self.player -- 4921
	local c = self.room.cart -- 4922
	if self.gripping then -- 4922
		if not input.interact.held then -- 4922
			self.gripping = false -- 4926
			self:flashSet("松开车把", 0.4) -- 4927
			return -- 4928
		end -- 4928
	else -- 4928
		if not input.interact.pressed then -- 4928
			return -- 4932
		end -- 4932
		if not self:cartHandleInReach(p) then -- 4932
			return -- 4935
		end -- 4935
		local track = c.depth or 0 -- 4937
		if self:limitDepth(p, track) ~= track then -- 4937
			return -- 4939
		end -- 4939
		p.depth = track -- 4941
		p.depthSpeed = 0 -- 4942
		self.gripping = true -- 4943
		self:flashSet("握住车把", 0.4) -- 4944
		return -- 4945
	end -- 4945
	if self.cartDocked then -- 4945
		return -- 4949
	end -- 4949
	local dir = input.moveX -- 4951
	if dir == 0 then -- 4951
		return -- 4953
	end -- 4953
	local lo = math.min(c.startX, c.endX) -- 4955
	local hi = math.max(c.startX, c.endX) -- 4956
	local next = self.cartAxle + dir * CART_SPEED * dt -- 4957
	if next < lo then -- 4957
		next = lo -- 4959
	end -- 4959
	if next > hi then -- 4959
		next = hi -- 4962
	end -- 4962
	local delta = next - self.cartAxle -- 4964
	if delta == 0 then -- 4964
		return -- 4966
	end -- 4966
	self.cartAxle = next -- 4968
	p.x = p.x + delta -- 4969
	p.facing = dir > 0 and 1 or -1 -- 4970
	self:slideX(p, 0) -- 4971
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 4971
		self.gripping = false -- 4973
		self:flashSet("跟不上了，脱手", 0.6) -- 4974
		return -- 4975
	end -- 4975
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 4975
		self.cartDocked = true -- 4978
		self.gripping = false -- 4979
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 4980
		self:flashSet("车轮落窝", 1.2) -- 4981
		if self.room.key == "outside" then -- 4981
			self:finishOutsideCart() -- 4983
		end -- 4983
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 4983
		self:flashSet("车轮回到起点", 0.5) -- 4986
	end -- 4986
end -- 4920
function Play.prototype.requestRoom(self, key, reason) -- 4994
	if self.wantRoom ~= "" then -- 4994
		return -- 4998
	end -- 4998
	self.wantRoom = key -- 5000
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 5001
end -- 4994
function Play.prototype.checkCarryGate(self) -- 5008
	if self.room.key == "checkpoint" then -- 5008
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 5008
			self.carryCartAxle = self.cartAxle -- 5011
			self.carryCartDocked = self.cartDocked -- 5012
			self:requestRoom("gate", "检查站出口") -- 5013
			self:flashSet("出检查站 · 城门", 1.2) -- 5014
		end -- 5014
		return -- 5016
	end -- 5016
	if self.room.key == "outside" then -- 5016
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 5016
			self.carryCartAxle = self.cartAxle -- 5022
			self.carryCartDocked = self.cartDocked -- 5023
			self:requestRoom("village", "墙根走完") -- 5024
			self:flashSet("墙根走完 · 进村口", 1.2) -- 5025
		end -- 5025
	end -- 5025
end -- 5008
function Play.prototype.aimAt(self, wx, wy) -- 5032
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 5033
	self.aimX = s.x -- 5034
	self.aimY = s.y -- 5035
end -- 5032
function Play.prototype.shoot(self, a) -- 5038
	if self.isCampaign and self.reloadT > 0 then -- 5038
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 5040
		return -- 5041
	end -- 5041
	local ox = a.x + a.facing * 8 -- 5043
	local muzzleY = a.y + a.h * 0.72 -- 5044
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 5045
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 5047
	local dx = aim.x - ox -- 5050
	local dy = aim.y - oy -- 5051
	local len = math.sqrt(dx * dx + dy * dy) -- 5052
	if len < 0.001 then -- 5052
		dx = a.facing -- 5054
		dy = 0 -- 5055
	else -- 5055
		dx = dx / len -- 5057
		dy = dy / len -- 5058
	end -- 5058
	if dx ~= 0 then -- 5058
		a.facing = dx > 0 and 1 or -1 -- 5061
	end -- 5061
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 5064
	local hitEnemy = self:raycastEnemies(ray) -- 5065
	local tEnemy = hitEnemy.t -- 5066
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 5067
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 5068
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 5069
	local tWall = solid.t -- 5070
	local rawEffect = self:consumeReloadEffect() -- 5072
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 5073
	local reloadEffect = rawEffect -- 5074
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 5076
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 5077
	self.trace = { -- 5079
		x0 = ox, -- 5079
		y0 = oy, -- 5079
		x1 = ox + dx * t, -- 5079
		y1 = oy + dy * t, -- 5079
		hit = hit -- 5079
	} -- 5079
	self.traceT = 0.12 -- 5080
	self:applyFireDanger(ox) -- 5081
	local killed = false -- 5082
	if hit then -- 5082
		local i = hitEnemy.index -- 5084
		local e = self.enemies[i + 1] -- 5085
		local impactY = oy + dy * tEnemy -- 5086
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 5087
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 5088
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 5088
			local pushRank = self:talentRank("push_force") -- 5090
			local dmg = reloadEffect == "push" and 2 + pushRank or 1 -- 5091
			e.shieldHp = math.max(0, (e.shieldHp or 0) - dmg) -- 5092
			e.hitT = 0.3 -- 5093
			if reloadEffect == "push" then -- 5093
				local kb = 46 + 24 * pushRank -- 5095
				e.x = math.max( -- 5096
					self.room.minX + 20, -- 5096
					math.min(self.room.maxX - 20, e.x + a.facing * kb) -- 5096
				) -- 5096
				if pushRank > 0 then -- 5096
					self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5098
				end -- 5098
				self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5100
				self:flashSet(e.shieldHp <= 0 and "推退破盾！" or "推退震退持盾手", 0.9) -- 5101
			else -- 5101
				self:flashSet( -- 5103
					(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 5103
					0.8 -- 5103
				) -- 5103
			end -- 5103
			self:emit("shotResolved", { -- 5105
				hit = true, -- 5106
				enemyIndex = i, -- 5106
				enemyX = e.x, -- 5106
				aimX = aim.x, -- 5106
				aimY = aim.y, -- 5106
				impactX = ox + dx * t, -- 5107
				impactY = oy + dy * t, -- 5107
				shield = true -- 5107
			}) -- 5107
			self:beginReload() -- 5109
			return -- 5110
		end -- 5110
		e.alive = false -- 5112
		e.hitT = 0.4 -- 5113
		killed = true -- 5114
		self:flashSet("命中", 0.6) -- 5115
		self:dropFor(e) -- 5116
		local lpRank = self:talentRank("lantern_pierce") -- 5117
		if reloadEffect == "light" and (weaponFx == "light" or lpRank > 0) then -- 5117
			local blindRadius = (weaponFx == "light" and 160 or 110) + 50 * lpRank -- 5119
			self:blindNearby(e, blindRadius, i) -- 5120
		end -- 5120
		if reloadEffect == "push" then -- 5120
			local pushRank = self:talentRank("push_force") -- 5123
			e.x = e.x + a.facing * (46 + 24 * pushRank) -- 5124
			if pushRank > 0 then -- 5124
				self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5126
			end -- 5126
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5128
		elseif reloadEffect == "echo" then -- 5128
			local echoRank = self:talentRank("echo_wide") -- 5130
			self:echoToSource(a, (weaponFx == "echo" and 2 or 1) + echoRank, 60 + 30 * echoRank) -- 5131
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 5132
		elseif reloadEffect == "light" then -- 5132
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 5134
		end -- 5134
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 5134
		self:damageProp(solid.box, 1) -- 5137
	else -- 5137
		self:flashSet("打空", 0.35) -- 5139
	end -- 5139
	if self.isCampaign then -- 5139
		self:beginReload() -- 5142
	end -- 5142
	self:emit("shotResolved", { -- 5144
		hit = hit, -- 5145
		enemyIndex = hit and hitEnemy.index or -1, -- 5146
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 5147
		aimX = aim.x, -- 5148
		aimY = aim.y, -- 5149
		impactX = ox + dx * t, -- 5150
		impactY = oy + dy * t -- 5151
	}) -- 5151
end -- 5038
function Play.prototype.staggerNearby(self, center, radius, delayTicks, skipIndex) -- 5156
	local i = 0 -- 5157
	do -- 5157
		i = 0 -- 5158
		while i < #self.enemies do -- 5158
			do -- 5158
				if i == skipIndex then -- 5158
					goto __continue866 -- 5160
				end -- 5160
				local e = self.enemies[i + 1] -- 5162
				if not e.alive or math.abs(e.x - center.x) > radius then -- 5162
					goto __continue866 -- 5164
				end -- 5164
				e.warnT = 0 -- 5166
				e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 5167
				local pushDir = e.x >= center.x and 1 or -1 -- 5168
				e.x = math.max( -- 5169
					self.room.minX + 20, -- 5169
					math.min(self.room.maxX - 20, e.x + pushDir * 22) -- 5169
				) -- 5169
			end -- 5169
			::__continue866:: -- 5169
			i = i + 1 -- 5158
		end -- 5158
	end -- 5158
end -- 5156
function Play.prototype.applyFireDanger(self, shotX) -- 5174
	local ____temp_140 = self.isCampaign and self.run.joined -- 5175
	if ____temp_140 then -- 5175
		local ____opt_135 = self.room.campaign -- 5175
		local ____temp_139 = (____opt_135 and ____opt_135.chapter) == "S" -- 5176
		if not ____temp_139 then -- 5176
			local ____opt_137 = self.room.campaign -- 5176
			____temp_139 = (____opt_137 and ____opt_137.chapter) == "C" -- 5176
		end -- 5176
		____temp_140 = ____temp_139 -- 5175
	end -- 5175
	local isStorySc = ____temp_140 -- 5175
	if self.room.key ~= "checkpoint" and not isStorySc or not self.partner.alive then -- 5175
		return -- 5178
	end -- 5178
	local dangerX = shotX -- 5180
	local best = -1 -- 5181
	local bestD = 1000000000 -- 5182
	local i = 0 -- 5183
	do -- 5183
		i = 0 -- 5184
		while i < #self.enemies do -- 5184
			do -- 5184
				local e = self.enemies[i + 1] -- 5185
				if not e.alive then -- 5185
					goto __continue872 -- 5187
				end -- 5187
				local d = math.abs(e.x - self.partner.x) -- 5189
				if d < bestD then -- 5189
					bestD = d -- 5191
					best = i -- 5192
				end -- 5192
			end -- 5192
			::__continue872:: -- 5192
			i = i + 1 -- 5184
		end -- 5184
	end -- 5184
	if best >= 0 then -- 5184
		dangerX = self.enemies[best + 1].x -- 5196
	end -- 5196
	if isStorySc and math.abs(dangerX - self.partner.x) > 260 then -- 5196
		return -- 5200
	end -- 5200
	local exposed = self:childExposed(dangerX) -- 5202
	local before = self.escort.fear -- 5203
	local dangerId = self.nextDangerId -- 5204
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 5205
	self.nextDangerId = self.nextDangerId + 1 -- 5206
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 5207
	if after > before then -- 5207
		self:flashSet( -- 5209
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 5209
			1 -- 5209
		) -- 5209
	elseif not exposed then -- 5209
		self:flashSet("枪声没够到她", 0.5) -- 5211
	end -- 5211
end -- 5174
function Play.prototype.childExposed(self, dangerX) -- 5216
	local c = self.partner -- 5217
	if not c.alive then -- 5217
		return false -- 5219
	end -- 5219
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 5219
		self.boxes, -- 5222
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 5222
	) then -- 5222
		return false -- 5223
	end -- 5223
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 5223
		return false -- 5226
	end -- 5226
	local toDanger = dangerX - c.x -- 5228
	local toPlayer = self.player.x - c.x -- 5229
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 5229
		return false -- 5232
	end -- 5232
	return true -- 5234
end -- 5216
function Play.prototype.raycastEnemies(self, ray) -- 5238
	local best = -1 -- 5239
	local bestI = -1 -- 5240
	do -- 5240
		local i = 0 -- 5241
		while i < #self.enemies do -- 5241
			do -- 5241
				local e = self.enemies[i + 1] -- 5242
				if not e.alive then -- 5242
					goto __continue887 -- 5244
				end -- 5244
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 5246
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 5247
				if t >= 0 and (best < 0 or t < best) then -- 5247
					best = t -- 5249
					bestI = i -- 5250
				end -- 5250
			end -- 5250
			::__continue887:: -- 5250
			i = i + 1 -- 5241
		end -- 5241
	end -- 5241
	return {t = best, index = bestI} -- 5253
end -- 5238
function Play.prototype.raycastWorld(self, ray) -- 5256
	return self:raycastSolid(ray).t -- 5257
end -- 5256
function Play.prototype.raycastSolid(self, ray) -- 5261
	local best = -1 -- 5262
	local bestBox = nil -- 5263
	for ____, box in ipairs(self.boxes) do -- 5264
		do -- 5264
			if box.broken == true or box.hidden == true then -- 5264
				goto __continue892 -- 5266
			end -- 5266
			local t = hitBox(ray, box) -- 5271
			if t > 2 and (best < 0 or t < best) then -- 5271
				best = t -- 5274
				bestBox = box -- 5275
			end -- 5275
		end -- 5275
		::__continue892:: -- 5275
	end -- 5275
	if ray.dy < 0 then -- 5275
		local t = -ray.y / ray.dy -- 5279
		if t >= 0 and (best < 0 or t < best) then -- 5279
			best = t -- 5281
			bestBox = nil -- 5282
		end -- 5282
	end -- 5282
	return {t = best, box = bestBox} -- 5285
end -- 5261
function Play.prototype.dropFor(self, e) -- 5289
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 5289
		return -- 5291
	end -- 5291
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 5291
		return -- 5294
	end -- 5294
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 5296
	local ____self_pickups_141 = self.pickups -- 5296
	____self_pickups_141[#____self_pickups_141 + 1] = { -- 5297
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 5298
		kind = e.drop, -- 5298
		x = e.x, -- 5298
		y = e.y, -- 5298
		depth = e.depth, -- 5299
		label = label .. " ×1" -- 5299
	} -- 5299
	self:log("掉落 " .. label) -- 5301
end -- 5289
function Play.prototype.damageProp(self, b, amount) -- 5305
	if b.breakable == nil or b.broken == true then -- 5305
		return -- 5307
	end -- 5307
	local ____b_breakable_142, ____hp_143 = b.breakable, "hp" -- 5307
	____b_breakable_142[____hp_143] = ____b_breakable_142[____hp_143] - amount -- 5309
	if b.breakable.hp > 0 then -- 5309
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 5311
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 5312
		return -- 5313
	end -- 5313
	b.broken = true -- 5315
	for ____, other in ipairs(self.boxes) do -- 5316
		if other.id ~= nil and other.id == b.id then -- 5316
			other.broken = true -- 5318
		end -- 5318
	end -- 5318
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 5321
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 5322
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 5323
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 5324
end -- 5305
function Play.prototype.slideDepth(self, a, distance) -- 5328
	a.depth = self:limitDepth(a, a.depth + distance) -- 5329
end -- 5328
function Play.prototype.limitDepth(self, a, target) -- 5332
	local road = self.room.depth -- 5333
	if road == nil or target == a.depth then -- 5333
		return a.depth -- 5335
	end -- 5335
	local next = math.max( -- 5337
		road.min, -- 5337
		math.min(road.max, target) -- 5337
	) -- 5337
	local half = a.w / 2 -- 5338
	for ____, b in ipairs(self.boxes) do -- 5339
		do -- 5339
			local footprint = b.depth -- 5340
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5340
				goto __continue910 -- 5345
			end -- 5345
			local front = footprint.min - ACTOR_DEPTH_HALF -- 5347
			local back = footprint.max + ACTOR_DEPTH_HALF -- 5348
			if a.depth <= front and next > front then -- 5348
				next = front -- 5350
			elseif a.depth >= back and next < back then -- 5350
				next = back -- 5352
			end -- 5352
		end -- 5352
		::__continue910:: -- 5352
	end -- 5352
	return next -- 5355
end -- 5332
function Play.prototype.cartLatchBounds(self) -- 5359
	if self.room.key ~= "outside" or self.cartDocked then -- 5359
		return nil -- 5360
	end -- 5360
	local arch = self.room.arch -- 5361
	local halfWidth = self.room.cart.bodyW / 2 -- 5362
	local left = math.max(arch.x0, self.cartAxle - halfWidth) -- 5363
	local right = math.min(arch.x1, self.cartAxle + halfWidth) -- 5364
	return right > left and Rect(left, arch.y, right - left, arch.h) or nil -- 5365
end -- 5359
function Play.prototype.slideX(self, a, dx) -- 5369
	local nx = a.x + dx -- 5370
	local half = a.w / 2 -- 5371
	local room = self.room -- 5372
	nx = math.max( -- 5373
		room.minX + half, -- 5373
		math.min(room.maxX - half, nx) -- 5373
	) -- 5373
	local i = 0 -- 5374
	do -- 5374
		i = 0 -- 5375
		while i < #self.boxes do -- 5375
			do -- 5375
				local b = self.boxes[i + 1] -- 5376
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5376
					goto __continue919 -- 5378
				end -- 5378
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5378
					goto __continue919 -- 5381
				end -- 5381
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5381
					goto __continue919 -- 5384
				end -- 5384
				if nx + half > b.x0 and nx - half < b.x1 then -- 5384
					if a.x <= b.x0 then -- 5384
						nx = b.x0 - half -- 5388
					elseif a.x >= b.x1 then -- 5388
						nx = b.x1 + half -- 5390
					else -- 5390
						nx = a.x -- 5392
					end -- 5392
				end -- 5392
			end -- 5392
			::__continue919:: -- 5392
			i = i + 1 -- 5375
		end -- 5375
	end -- 5375
	local latch = self:cartLatchBounds() -- 5396
	if latch ~= nil and a.y < latch.y + latch.height - 0.001 and nx + half > latch.x and nx - half < latch.x + latch.width then -- 5396
		if a.x <= latch.x then -- 5396
			nx = latch.x - half -- 5400
		elseif a.x >= latch.x + latch.width then -- 5400
			nx = latch.x + latch.width + half -- 5402
		else -- 5402
			nx = a.x -- 5404
		end -- 5404
	end -- 5404
	local arch = room.arch -- 5411
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 5411
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 5413
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 5413
			if a.x <= arch.x0 then -- 5413
				nx = arch.x0 - half -- 5416
			elseif a.x >= arch.x1 then -- 5416
				nx = arch.x1 + half -- 5418
			end -- 5418
		end -- 5418
	end -- 5418
	a.x = nx -- 5422
end -- 5369
function Play.prototype.fallY(self, a, dt) -- 5426
	a.vy = a.vy - ____exports.GRAVITY * dt -- 5427
	if a.vy < -900 then -- 5427
		a.vy = -900 -- 5429
	end -- 5429
	local ny = a.y + a.vy * dt -- 5431
	local half = a.w / 2 -- 5432
	if a.vy <= 0 then -- 5432
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 5435
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 5436
		if ny <= ground then -- 5436
			ny = ground -- 5438
			a.vy = 0 -- 5439
			a.onGround = true -- 5440
		else -- 5440
			a.onGround = false -- 5442
		end -- 5442
	else -- 5442
		a.onGround = false -- 5445
		local i = 0 -- 5446
		do -- 5446
			i = 0 -- 5447
			while i < #self.boxes do -- 5447
				do -- 5447
					local b = self.boxes[i + 1] -- 5448
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5448
						goto __continue942 -- 5450
					end -- 5450
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5450
						goto __continue942 -- 5453
					end -- 5453
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 5453
						goto __continue942 -- 5456
					end -- 5456
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 5456
						ny = b.y0 - a.h -- 5459
						a.vy = 0 -- 5460
					end -- 5460
				end -- 5460
				::__continue942:: -- 5460
				i = i + 1 -- 5447
			end -- 5447
		end -- 5447
	end -- 5447
	a.y = ny -- 5464
end -- 5426
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 5468
	if depth == nil then -- 5468
		depth = 0 -- 5468
	end -- 5468
	local g = -9999 -- 5469
	local i = 0 -- 5470
	do -- 5470
		i = 0 -- 5471
		while i < #self.floors do -- 5471
			local f = self.floors[i + 1] -- 5472
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 5472
				g = f.y1 -- 5474
			end -- 5474
			i = i + 1 -- 5471
		end -- 5471
	end -- 5471
	do -- 5471
		i = 0 -- 5477
		while i < #self.boxes do -- 5477
			do -- 5477
				local b = self.boxes[i + 1] -- 5478
				if b.broken == true or b.hidden == true or b.soft == true then -- 5478
					goto __continue952 -- 5480
				end -- 5480
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 5480
					g = b.y1 -- 5484
				end -- 5484
			end -- 5484
			::__continue952:: -- 5484
			i = i + 1 -- 5477
		end -- 5477
	end -- 5477
	return g -- 5487
end -- 5468
function Play.prototype.updateCamera(self, dt) -- 5490
	local p = self.player -- 5491
	local tx = p.x + p.facing * 30 -- 5492
	local ty = p.y + CAM_LOOK_UP -- 5493
	local k = math.min(1, CAM_FOLLOW * dt) -- 5494
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 5495
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 5496
end -- 5490
function Play.prototype.clampCamera(self, w, h) -- 5500
	local room = self.room -- 5501
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 5502
	local spanX = room.maxX - room.minX -- 5503
	if spanX <= halfW * 2 then -- 5503
		self.cam.x = (room.minX + room.maxX) / 2 -- 5505
	else -- 5505
		self.cam.x = math.max( -- 5507
			room.minX + halfW, -- 5507
			math.min(room.maxX - halfW, self.cam.x) -- 5507
		) -- 5507
	end -- 5507
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 5510
	local spanY = room.height -- 5511
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 5512
	if spanY <= halfH * 2 then -- 5512
		self.cam.y = camY -- 5514
	else -- 5514
		self.cam.y = math.max( -- 5516
			camY, -- 5516
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 5516
		) -- 5516
	end -- 5516
end -- 5500
function Play.prototype.flashSet(self, text, t) -- 5520
	self.flash = text -- 5521
	self.flashT = t -- 5522
end -- 5520
function Play.prototype.statusText(self) -- 5526
	local p = self.player -- 5527
	local parts = {} -- 5528
	local who = self.childMode and "小满" or "周戍" -- 5529
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 5530
	if self.room.key == "prologue" then -- 5530
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5533
		if self.phase == "prologue-wake" then -- 5533
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 5535
		elseif self.phase == "prologue-shadow" then -- 5535
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 5537
		elseif self.phase == "prologue-escape" then -- 5537
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 5539
		elseif self.phase == "prologue-hide" then -- 5539
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 5541
		elseif self.phase == "prologue-wait" then -- 5541
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 5543
		elseif self.phase == "prologue-give" then -- 5543
			parts[#parts + 1] = (("递物 " .. tostring(self.phaseTick)) .. "/") .. tostring(____exports.PROLOGUE_GIVE_TICKS) -- 5545
		else -- 5545
			parts[#parts + 1] = "跟随" -- 5547
		end -- 5547
		if self.paused then -- 5547
			parts[#parts + 1] = "已暂停" -- 5550
		end -- 5550
		return table.concat(parts, " · ") -- 5552
	end -- 5552
	if self.room.key == "street" then -- 5552
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5555
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5556
		if self.paused then -- 5556
			parts[#parts + 1] = "已暂停" -- 5558
		end -- 5558
		return table.concat(parts, " · ") -- 5560
	end -- 5560
	if self.room.key == "gate" then -- 5560
		local ____temp_144 -- 5563
		if self.room.story == nil then -- 5563
			____temp_144 = nil -- 5563
		else -- 5563
			____temp_144 = self.room.story.gate -- 5563
		end -- 5563
		local g = ____temp_144 -- 5563
		if g ~= nil then -- 5563
			parts[#parts + 1] = self:gateLabel() -- 5565
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 5566
				0, -- 5567
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 5567
			))) .. " 秒" -- 5567
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5568
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5569
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 5570
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 5571
			if self.gateFailCount > 0 then -- 5571
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 5573
			end -- 5573
			if self.flash ~= "" then -- 5573
				parts[#parts + 1] = self.flash -- 5576
			end -- 5576
		end -- 5576
		if self.paused then -- 5576
			parts[#parts + 1] = "已暂停" -- 5580
		end -- 5580
		return table.concat(parts, " · ") -- 5582
	end -- 5582
	if self.room.key == "forest" then -- 5582
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5585
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5586
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5587
		if self.caughtT > 0 then -- 5587
			parts[#parts + 1] = "复位中" -- 5589
		end -- 5589
		if self.paused then -- 5589
			parts[#parts + 1] = "已暂停" -- 5592
		end -- 5592
		return table.concat(parts, " · ") -- 5594
	end -- 5594
	if self.room.key == "tower" then -- 5594
		if self.phase == "tower-wait" then -- 5594
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5598
		elseif self.phase == "tower-knock" then -- 5598
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5600
		elseif self.phase == "tower-enter" then -- 5600
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5602
		elseif self.phase == "tower-desk" then -- 5602
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5604
		elseif self.phase == "tower-given" then -- 5604
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5606
		else -- 5606
			parts[#parts + 1] = "片尾" -- 5608
		end -- 5608
		if self.paused then -- 5608
			parts[#parts + 1] = "已暂停" -- 5611
		end -- 5611
		return table.concat(parts, " · ") -- 5613
	end -- 5613
	if self.room.key == "village" then -- 5613
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5616
		if self.hasBottle then -- 5616
			parts[#parts + 1] = "有瓶" -- 5618
		elseif self.bottleFly ~= nil then -- 5618
			parts[#parts + 1] = "瓶在飞" -- 5620
		else -- 5620
			parts[#parts + 1] = "空手" -- 5622
		end -- 5622
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5624
		if self.scavChase then -- 5624
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5626
		end -- 5626
		if self.passed then -- 5626
			parts[#parts + 1] = "已过通行线" -- 5629
		end -- 5629
		if self.paused then -- 5629
			parts[#parts + 1] = "已暂停" -- 5632
		end -- 5632
		return table.concat(parts, " · ") -- 5634
	end -- 5634
	local isChild = self.childMode -- 5637
	if isChild then -- 5637
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5639
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5640
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5641
	else -- 5641
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5643
		if p.rollT > 0 then -- 5643
			parts[#parts + 1] = "翻滚中" -- 5645
		end -- 5645
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5647
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5648
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5649
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5650
	end -- 5650
	if self.checkpoint >= 0 then -- 5650
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5653
	end -- 5653
	if self.paused then -- 5653
		parts[#parts + 1] = "已暂停" -- 5656
	end -- 5656
	return table.concat(parts, " · ") -- 5658
end -- 5526
function Play.prototype.aliveEnemies(self) -- 5662
	local n = 0 -- 5663
	local i = 0 -- 5664
	do -- 5664
		i = 0 -- 5665
		while i < #self.enemies do -- 5665
			if self.enemies[i + 1].alive then -- 5665
				n = n + 1 -- 5667
			end -- 5667
			i = i + 1 -- 5665
		end -- 5665
	end -- 5665
	return n -- 5670
end -- 5662
function Play.prototype.threatened(self) -- 5675
	do -- 5675
		local i = 0 -- 5676
		while i < #self.enemies do -- 5676
			local e = self.enemies[i + 1] -- 5677
			if e.alive and e.warnT > 0 then -- 5677
				return true -- 5679
			end -- 5679
			i = i + 1 -- 5676
		end -- 5676
	end -- 5676
	return false -- 5682
end -- 5675
function Play.prototype.gateSecondsLeft(self) -- 5685
	local ____temp_145 -- 5686
	if self.room.story == nil then -- 5686
		____temp_145 = nil -- 5686
	else -- 5686
		____temp_145 = self.room.story.gate -- 5686
	end -- 5686
	local g = ____temp_145 -- 5686
	if g == nil then -- 5686
		return 0 -- 5688
	end -- 5688
	return math.max( -- 5690
		0, -- 5690
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5690
	) -- 5690
end -- 5685
function Play.prototype.gateLabel(self) -- 5693
	if self.phase == "gate-idle" then -- 5693
		return "待就位" -- 5695
	end -- 5695
	if self.phase == "gate-hold" then -- 5695
		return "守点中" -- 5698
	end -- 5698
	if self.phase == "gate-send" then -- 5698
		return "送别" -- 5701
	end -- 5701
	if self.phase == "gate-farewell" then -- 5701
		return "嘱咐 " .. tostring(self.phaseTick) -- 5704
	end -- 5704
	if self.phase == "gate-count" then -- 5704
		return "数数 " .. tostring(self.countTick) -- 5707
	end -- 5707
	return "她走" -- 5709
end -- 5693
function Play.prototype.dogLabel(self) -- 5713
	if self.dogState == "ear" then -- 5713
		return "转耳" -- 5715
	end -- 5715
	if self.dogState == "chase" then -- 5715
		return "追" -- 5718
	end -- 5718
	if self.dogState == "sniff" then -- 5718
		return "停" -- 5721
	end -- 5721
	if self.dogState == "back" then -- 5721
		return "回线" -- 5724
	end -- 5724
	return "巡逻" -- 5726
end -- 5713
function Play.prototype.doorXOf(self) -- 5729
	local ____temp_146 -- 5730
	if self.room.story == nil then -- 5730
		____temp_146 = nil -- 5730
	else -- 5730
		____temp_146 = self.room.story.tower -- 5730
	end -- 5730
	local t = ____temp_146 -- 5730
	return t == nil and 0 or t.doorX -- 5731
end -- 5729
function Play.prototype.scavLabel(self) -- 5735
	if self.scavState == "chase" then -- 5735
		return "追" -- 5737
	end -- 5737
	if self.scavState == "turn" then -- 5737
		return "转头" -- 5740
	end -- 5740
	if self.scavState == "walk" then -- 5740
		return "赶来" -- 5743
	end -- 5743
	if self.scavState == "stall" then -- 5743
		return "停住" -- 5746
	end -- 5746
	if self.scavState == "back" then -- 5746
		return "回位" -- 5749
	end -- 5749
	return "巡逻" -- 5751
end -- 5735
function Play.prototype.hintText(self) -- 5755
	if self.paused then -- 5755
		return "Esc 继续 · R 重置" -- 5757
	end -- 5757
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5757
		if self:threatened() then -- 5757
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5763
		end -- 5763
		if self.coverHug then -- 5763
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5766
		end -- 5766
		if self.coverNear then -- 5766
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5769
		end -- 5769
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5771
	end -- 5771
	if self.flash ~= "" then -- 5771
		return self.flash -- 5774
	end -- 5774
	if self.room.key == "prologue" then -- 5774
		if self.phase == "prologue-wake" then -- 5774
			return "父亲在门外唤 · 小满睁眼" -- 5778
		end -- 5778
		if self.phase == "prologue-shadow" then -- 5778
			return "墙上两道人影 · 碗滚到脚边" -- 5781
		end -- 5781
		if self.phase == "prologue-escape" then -- 5781
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5784
		end -- 5784
		if self.phase == "prologue-hide" then -- 5784
			return "柜门合上 · 屏住呼吸" -- 5787
		end -- 5787
		if self.phase == "prologue-wait" then -- 5787
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5790
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5791
		end -- 5791
		if self.phase == "prologue-give" then -- 5791
			return ((("递物 " .. tostring(self.phaseTick)) .. " / ") .. tostring(____exports.PROLOGUE_GIVE_TICKS)) .. " 拍 · 站着别动" -- 5794
		end -- 5794
		return "她跟着你了 · 两人一起走到门口 680" -- 5796
	end -- 5796
	if self.room.key == "street" then -- 5796
		if self:aliveEnemies() > 0 then -- 5796
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5800
		end -- 5800
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5802
	end -- 5802
	if self.room.key == "gate" then -- 5802
		local ____temp_147 -- 5805
		if self.room.story == nil then -- 5805
			____temp_147 = nil -- 5805
		else -- 5805
			____temp_147 = self.room.story.gate -- 5805
		end -- 5805
		local g = ____temp_147 -- 5805
		if g ~= nil then -- 5805
			if self.phase == "gate-idle" then -- 5805
				if self.gateNeedConfirm then -- 5805
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5809
				end -- 5809
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5811
			end -- 5811
			if self.phase == "gate-hold" then -- 5811
				if self.coveredFlash > 0 then -- 5811
					return "掩体挡下了这一枪 · 别露头" -- 5815
				end -- 5815
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5817
			end -- 5817
			if self.phase == "gate-send" then -- 5817
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5820
			end -- 5820
			if self.phase == "gate-farewell" then -- 5820
				return "城门送别 · 嘱咐她慢慢数到二十" -- 5823
			end -- 5823
			if self.phase == "gate-count" then -- 5823
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5823
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5827
				end -- 5827
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5829
			end -- 5829
			return "她自己走 · 跟着出城门 1120" -- 5831
		end -- 5831
	end -- 5831
	if self.room.key == "forest" then -- 5831
		if self.dogState == "chase" then -- 5831
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5836
		end -- 5836
		if self.dogState == "ear" then -- 5836
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5839
		end -- 5839
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5841
	end -- 5841
	if self.room.key == "tower" then -- 5841
		if self.phase == "tower-wait" then -- 5841
			return "走到门前 445 点一次 E 敲两下" -- 5845
		end -- 5845
		if self.phase == "tower-knock" then -- 5845
			return "敲两下 · 等门开" -- 5848
		end -- 5848
		if self.phase == "tower-given" then -- 5848
			return "递交针套和纸条 · 看登记簿最后一行" -- 5851
		end -- 5851
		return "片尾 · 点 E 再玩一次，回到序章" -- 5853
	end -- 5853
	if self.room.key == "village" then -- 5853
		if self.bottleFly ~= nil then -- 5853
			return "等瓶子落地 · 触地才发声" -- 5857
		end -- 5857
		if self.hasBottle then -- 5857
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5860
		end -- 5860
		if self.passed then -- 5860
			return "已过第一院 · R 重置可再来一遍" -- 5863
		end -- 5863
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5865
	end -- 5865
	if self.room.key == "outside" then -- 5865
		if self.focusCart then -- 5865
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5869
		end -- 5869
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5871
	end -- 5871
	if self.escort.state == "frozen" then -- 5871
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5871
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5875
		end -- 5875
		return "小满吓住了 · 走过去，靠近再点 E" -- 5877
	end -- 5877
	if self.escort.state == "calming" then -- 5877
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5880
	end -- 5880
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5882
end -- 5755
return ____exports -- 5755