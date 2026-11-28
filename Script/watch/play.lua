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
function makeActor(room, index) -- 5924
	local sp = room.spawns -- 5925
	if index < 0 or index >= #sp then -- 5925
		return { -- 5927
			x = 0, -- 5927
			y = 0, -- 5927
			depth = 0, -- 5927
			depthSpeed = 0, -- 5927
			vx = 0, -- 5927
			vy = 0, -- 5927
			w = CHILD_W, -- 5927
			h = CHILD_H, -- 5927
			onGround = true, -- 5927
			facing = 1, -- 5927
			crouch = false, -- 5927
			rollT = 0, -- 5927
			covered = false, -- 5927
			alive = false -- 5927
		} -- 5927
	end -- 5927
	local s = sp[index + 1] -- 5929
	local child = s.h < SOLDIER_H -- 5930
	local ground = room.depth -- 5931
	local depth = ground == nil and 0 or math.max( -- 5932
		ground.min, -- 5932
		math.min(ground.max, s.depth or 0) -- 5932
	) -- 5932
	return { -- 5933
		x = s.x, -- 5934
		y = s.y, -- 5934
		depth = depth, -- 5934
		depthSpeed = 0, -- 5934
		vx = 0, -- 5934
		vy = 0, -- 5934
		w = child and CHILD_W or SOLDIER_W, -- 5935
		h = child and CHILD_H or SOLDIER_H, -- 5936
		onGround = true, -- 5937
		facing = 1, -- 5937
		crouch = false, -- 5937
		rollT = 0, -- 5937
		covered = false, -- 5937
		alive = true -- 5937
	} -- 5937
end -- 5937
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5942
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5943
end -- 5942
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5950
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5951
end -- 5950
function rayInterval(origin, direction, min, max) -- 5958
	if direction == 0 then -- 5958
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5960
	end -- 5960
	local a = (min - origin) / direction -- 5962
	local b = (max - origin) / direction -- 5963
	return { -- 5964
		min = math.min(a, b), -- 5964
		max = math.max(a, b) -- 5964
	} -- 5964
end -- 5964
function hitBox(ray, box) -- 5968
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5969
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5970
	local enter = math.max(0, x.min, y.min) -- 5971
	local leave = math.min(99999, x.max, y.max) -- 5972
	if box.depth ~= nil then -- 5972
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5974
		enter = math.max(enter, depth.min) -- 5975
		leave = math.min(leave, depth.max) -- 5976
	end -- 5976
	return leave >= enter and enter or -1 -- 5978
end -- 5978
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
	self.redCartPulled = false -- 402
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
	if story.segments.outside_cart == true then -- 1230
		self.redCartPulled = true -- 1233
		local redBox = __TS__ArrayFind( -- 1234
			self.boxes, -- 1234
			function(____, b) return b.id == "outside_red_cart" end -- 1234
		) -- 1234
		if redBox ~= nil then -- 1234
			redBox.x0 = 430 -- 1236
			redBox.x1 = 474 -- 1237
		end -- 1237
		if self.room.key == "outside" and self.room.cart.bodyW > 0 then -- 1237
			self.cartAxle = self.room.cart.endX -- 1240
			self.cartDocked = true -- 1241
		end -- 1241
	end -- 1241
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 1244
	self.waterSeen = story.segments.water_lantern == true -- 1246
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 1246
		self:applyCheckpointSnap(self.checkpoint) -- 1249
	end -- 1249
	if self.room.key == "tower" and story.route == "soldier" then -- 1249
		self.carryOn = false -- 1253
		self.run.story.carry = false -- 1254
		self.player.w = SOLDIER_W -- 1255
		self.player.h = SOLDIER_H -- 1256
		self.player.x = math.max(self.ox + 422, self.player.x) -- 1257
		self.partner = { -- 1258
			x = math.max(self.ox + 408, self.player.x - 24), -- 1259
			y = 0, -- 1260
			depth = 0, -- 1261
			depthSpeed = 0, -- 1262
			vx = 0, -- 1263
			vy = 0, -- 1264
			w = CHILD_W, -- 1265
			h = CHILD_H, -- 1266
			onGround = true, -- 1267
			facing = 1, -- 1268
			crouch = false, -- 1269
			rollT = 0, -- 1270
			covered = false, -- 1271
			alive = true -- 1272
		} -- 1272
	end -- 1272
	if self.room.key == "tower" then -- 1272
		if story.segments.tower_door == true then -- 1272
			self:openTowerDoor() -- 1278
		end -- 1278
		self.towerHanded = story.segments.tower_handover == true -- 1280
		self.deskHold = 0 -- 1281
		if story.phase == "tower-enter" or story.phase == "tower-desk" or story.phase == "tower-given" then -- 1281
			self.phase = story.phase -- 1283
			self.phaseTick = 0 -- 1284
			if story.phase == "tower-desk" or story.phase == "tower-given" then -- 1284
				self.player.x = self.ox + 605 -- 1286
				self.player.y = 0 -- 1287
				if story.route == "soldier" and self.partner.alive then -- 1287
					self.partner.x = self.ox + 568 -- 1289
					self.partner.y = 0 -- 1290
					self.partner.facing = 1 -- 1291
				end -- 1291
			end -- 1291
		end -- 1291
	end -- 1291
	if self.room.key == "prologue" then -- 1291
		local ph = story.phase -- 1298
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 1298
			self.phase = ph -- 1300
			self.phaseTick = story.phaseTick -- 1301
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 1302
			self.player.y = 0 -- 1303
			self.player.depth = 0 -- 1304
			self.player.vx = 0 -- 1305
			self.partner.x = self.ox + 300 -- 1306
			self.partner.y = 0 -- 1307
			self.partner.depth = 0 -- 1308
			self.partner.vx = 0 -- 1309
			self.partner.alive = true -- 1310
			if ph == "prologue-follow" then -- 1310
				self.partner.crouch = false -- 1312
				self.partner.h = CHILD_H -- 1313
			else -- 1313
				self.partner.crouch = true -- 1315
				self.partner.h = CHILD_CROUCH_H -- 1316
			end -- 1316
			self.cam.x = self.player.x -- 1318
		end -- 1318
		return -- 1320
	end -- 1320
	if self.room.key ~= "gate" then -- 1320
		return -- 1323
	end -- 1323
	local ____temp_51 -- 1325
	if self.room.story == nil then -- 1325
		____temp_51 = nil -- 1325
	else -- 1325
		____temp_51 = self.room.story.gate -- 1325
	end -- 1325
	local g = ____temp_51 -- 1325
	if g == nil then -- 1325
		return -- 1327
	end -- 1327
	if story.phase == "gate-send" then -- 1327
		self.phase = "gate-send" -- 1331
		self.gateTick = g.holdTicks -- 1332
		self.gateSpawned = 4 -- 1333
		self.enemies = {} -- 1334
		self.player.x = self.ox + g.doorX - 40 -- 1335
		self.player.y = 0 -- 1336
		self.player.depth = 0 -- 1337
		self.player.vx = 0 -- 1338
		self.player.vy = 0 -- 1339
		self.player.onGround = true -- 1340
		self.partner.x = self.ox + g.waitX -- 1341
		self.partner.y = 0 -- 1342
		self.partner.depth = 0 -- 1343
		self.partner.alive = true -- 1344
		self.cam.x = self.player.x -- 1345
		self.handTicks = 0 -- 1346
		self.handArmed = false -- 1347
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1348
		return -- 1349
	end -- 1349
	if not story.settled then -- 1349
		return -- 1352
	end -- 1352
	self.gateTick = g.holdTicks -- 1355
	self.gateSpawned = 4 -- 1356
	self.enemies = {} -- 1357
	if story.phase == "gate-farewell" or story.phase == "gate-count" or story.phase == "gate-walk" then -- 1357
		self.phase = story.phase == "gate-farewell" and "gate-count" or story.phase -- 1359
		self.countTick = story.phase == "gate-farewell" and 0 or math.max(story.countTick, 0) -- 1360
		self:swapToChild(g.doorX + 30) -- 1361
		self.countPrevMove = 0 -- 1362
		self.countArmed = false -- 1363
		return -- 1364
	end -- 1364
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1364
		self.phase = story.phase -- 1367
		self.countTick = ____exports.GATE_COUNT_END -- 1368
		self.phaseTick = story.phaseTick -- 1369
		self:swapToChild(g.doorX + 30) -- 1370
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1371
			0, -- 1371
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1371
		) -- 1371
		self.handArmed = false -- 1372
	end -- 1372
end -- 1210
function Play.prototype.buildWorld(self) -- 1377
	local room = self.room -- 1378
	self.boxes = {} -- 1379
	self.floors = {} -- 1380
	local i = 0 -- 1381
	do -- 1381
		i = 0 -- 1382
		while i < #room.floors do -- 1382
			local f = room.floors[i + 1] -- 1383
			local ____self_floors_52 = self.floors -- 1383
			____self_floors_52[#____self_floors_52 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1384
			i = i + 1 -- 1382
		end -- 1382
	end -- 1382
	do -- 1382
		i = 0 -- 1386
		while i < #room.solids do -- 1386
			local s = room.solids[i + 1] -- 1387
			if not s.decorative then -- 1387
				local ____self_boxes_64 = self.boxes -- 1393
				local ____s_x_55 = s.x -- 1394
				local ____temp_56 = s.x + s.w -- 1394
				local ____s_y_57 = s.y -- 1394
				local ____temp_58 = s.y + s.h -- 1394
				local ____temp_53 -- 1395
				if room.depth == nil then -- 1395
					____temp_53 = nil -- 1395
				else -- 1395
					____temp_53 = s.depth -- 1395
				end -- 1395
				local ____temp_59 = s.passable == true -- 1396
				local ____s_label_60 = s.label -- 1396
				local ____s_id_61 = s.id -- 1397
				local ____temp_62 = s.soft == true -- 1397
				local ____temp_63 = s.hidden == true -- 1397
				local ____temp_54 -- 1398
				if s.breakable == nil then -- 1398
					____temp_54 = nil -- 1398
				else -- 1398
					____temp_54 = __TS__ObjectAssign({}, s.breakable) -- 1398
				end -- 1398
				____self_boxes_64[#____self_boxes_64 + 1] = { -- 1393
					x0 = ____s_x_55, -- 1394
					x1 = ____temp_56, -- 1394
					y0 = ____s_y_57, -- 1394
					y1 = ____temp_58, -- 1394
					depth = ____temp_53, -- 1395
					passable = ____temp_59, -- 1396
					label = ____s_label_60, -- 1396
					id = ____s_id_61, -- 1397
					soft = ____temp_62, -- 1397
					hidden = ____temp_63, -- 1397
					breakable = ____temp_54, -- 1398
					interact = s.interact -- 1399
				} -- 1399
			end -- 1399
			i = i + 1 -- 1386
		end -- 1386
	end -- 1386
	do -- 1386
		i = 0 -- 1403
		while i < #room.stairs do -- 1403
			local st = room.stairs[i + 1] -- 1404
			local n = st.steps + 1 -- 1405
			local stepW = (st.x1 - st.x0) / n -- 1406
			local k = 0 -- 1407
			do -- 1407
				k = 0 -- 1408
				while k < n do -- 1408
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1409
					local x0 = st.x0 + stepW * k -- 1410
					local ____self_boxes_68 = self.boxes -- 1413
					local ____temp_66 = x0 + stepW -- 1414
					local ____temp_67 = -8 -- 1414
					local ____temp_65 -- 1415
					if room.depth == nil then -- 1415
						____temp_65 = nil -- 1415
					else -- 1415
						____temp_65 = st.depth -- 1415
					end -- 1415
					____self_boxes_68[#____self_boxes_68 + 1] = { -- 1413
						x0 = x0, -- 1414
						x1 = ____temp_66, -- 1414
						y0 = ____temp_67, -- 1414
						y1 = y, -- 1414
						depth = ____temp_65, -- 1415
						passable = true -- 1416
					} -- 1416
					k = k + 1 -- 1408
				end -- 1408
			end -- 1408
			i = i + 1 -- 1403
		end -- 1403
	end -- 1403
end -- 1377
function Play.prototype.setupCampaign(self) -- 1426
	local wr = self.room -- 1427
	local c = wr.campaign -- 1428
	if c == nil then -- 1428
		return -- 1430
	end -- 1430
	self.roomStartTick = self.run.ticks -- 1432
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1432
		self.run.joined = true -- 1436
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1436
		local ____self_run_73 = self.run -- 1439
		local ____temp_72 -- 1439
		if wr.key == "s2-drygoods" then -- 1439
			local ____temp_71 = self.run.route ~= "drygoods" -- 1440
			if not ____temp_71 then -- 1440
				local ____opt_69 = self.run.props.s2_board -- 1440
				____temp_71 = (____opt_69 and ____opt_69.broken) == true -- 1440
			end -- 1440
			____temp_72 = ____temp_71 -- 1440
		else -- 1440
			____temp_72 = wr.key == "c1-yard" and self.run.c1Latch -- 1441
		end -- 1441
		____self_run_73.joined = ____temp_72 -- 1439
	end -- 1439
	local x = wr.minX + 60 -- 1443
	local y = 0 -- 1444
	local depth = 0 -- 1445
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1445
		x = wr.minX + 210 -- 1447
		depth = -32 -- 1448
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1448
		x = wr.minX + 40 -- 1450
		y = 32 -- 1451
		depth = 32 -- 1452
	end -- 1452
	self.player = { -- 1454
		x = x, -- 1455
		y = y, -- 1455
		depth = depth, -- 1455
		depthSpeed = 0, -- 1455
		vx = 0, -- 1455
		vy = 0, -- 1455
		w = SOLDIER_W, -- 1456
		h = SOLDIER_H, -- 1456
		onGround = y <= 0, -- 1456
		facing = 1, -- 1456
		crouch = false, -- 1456
		rollT = 0, -- 1456
		covered = false, -- 1456
		alive = true -- 1456
	} -- 1456
	self.partner = { -- 1458
		x = x + 60, -- 1459
		y = y, -- 1459
		depth = depth, -- 1459
		depthSpeed = 0, -- 1459
		vx = 0, -- 1459
		vy = 0, -- 1459
		w = CHILD_W, -- 1460
		h = CHILD_H, -- 1460
		onGround = y <= 0, -- 1460
		facing = 1, -- 1460
		crouch = false, -- 1460
		rollT = 0, -- 1460
		covered = false, -- 1460
		alive = true -- 1460
	} -- 1460
	self.cam.x = x -- 1462
	self.cam.y = y + CAM_LOOK_UP -- 1463
	self.phase = "run" -- 1464
	self.hp = self.maxHp -- 1465
	if self:isEscortRoom() and self.run.story.route == "soldier" then -- 1465
		if self.run.story.talents == nil then -- 1465
			self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 1468
		end -- 1468
		local st = self.run.story.talents -- 1470
		local variants = ESCORT_VARIANTS[wr.key] -- 1471
		if self.run.source ~= "debug" and variants ~= nil and #variants > 0 then -- 1471
			st.variant = pickEscortVariant(self.run.seed, st.attempt, wr.key, #variants) -- 1473
		else -- 1473
			st.variant = 0 -- 1475
		end -- 1475
		if wr.key == "escort3" then -- 1475
			if st.room ~= "escort3" then -- 1475
				st.room = "escort3" -- 1481
				st.deferred = true -- 1482
				st.offers = {} -- 1483
			end -- 1483
		else -- 1483
			draftTalentOffers(st, wr.key, self.equippedWeapon) -- 1486
		end -- 1486
	end -- 1486
	self:buildEnemies() -- 1489
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1490
	local i = 0 -- 1491
	do -- 1491
		i = 0 -- 1492
		while i < #self.boxes do -- 1492
			do -- 1492
				local b = self.boxes[i + 1] -- 1493
				if b.id == nil then -- 1493
					goto __continue160 -- 1495
				end -- 1495
				local st = self.run.props[b.id] -- 1497
				if st ~= nil then -- 1497
					b.broken = st.broken -- 1499
					local ____temp_74 -- 1500
					if b.breakable == nil then -- 1500
						____temp_74 = nil -- 1500
					else -- 1500
						____temp_74 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1500
					end -- 1500
					b.breakable = ____temp_74 -- 1500
					b.hidden = b.hidden == true and st.revealed ~= true -- 1501
					if b.hidden then -- 1501
						b.broken = true -- 1503
					end -- 1503
				elseif b.hidden == true then -- 1503
					b.broken = true -- 1507
				end -- 1507
			end -- 1507
			::__continue160:: -- 1507
			i = i + 1 -- 1492
		end -- 1492
	end -- 1492
	if wr.cart.bodyW > 0 then -- 1492
		self.cartAxle = wr.cart.startX -- 1511
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1511
			self.cartAxle = wr.cart.endX -- 1513
			self.cartDocked = true -- 1514
		end -- 1514
	end -- 1514
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1517
end -- 1426
function Play.prototype.log(self, line) -- 1520
	local ____self_run_log_75 = self.run.log -- 1520
	____self_run_log_75[#____self_run_log_75 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1521
	if #self.run.log > 120 then -- 1521
		table.remove(self.run.log, 1) -- 1523
	end -- 1523
end -- 1520
function Play.prototype.buildEnemies(self) -- 1527
	self.enemies = {} -- 1528
	if self.isCampaign then -- 1528
		local variants = ESCORT_VARIANTS[self.room.key] -- 1530
		local useVariant = self:isEscortRoom() and self.run.story.route == "soldier" and self.run.source ~= "debug" and variants ~= nil and #variants > 0 -- 1531
		local ____useVariant_79 -- 1536
		if useVariant then -- 1536
			local ____temp_78 = #variants - 1 -- 1537
			local ____opt_76 = self.run.story.talents -- 1537
			____useVariant_79 = math.max( -- 1537
				0, -- 1537
				math.min(____temp_78, ____opt_76 and ____opt_76.variant or 0) -- 1537
			) -- 1537
		else -- 1537
			____useVariant_79 = 0 -- 1538
		end -- 1538
		local vIdx = ____useVariant_79 -- 1536
		local spawnList = useVariant and variants[vIdx + 1] or self.room.spawns -- 1539
		local i = 0 -- 1540
		do -- 1540
			i = 0 -- 1541
			while i < #spawnList do -- 1541
				local sp = spawnList[i + 1] -- 1542
				local kind = sp.kind or "gunner" -- 1543
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1544
				local sx = useVariant and self.ox + sp.x or sp.x -- 1545
				local ____self_enemies_80 = self.enemies -- 1545
				____self_enemies_80[#____self_enemies_80 + 1] = { -- 1546
					x = sx, -- 1547
					y = sp.y, -- 1547
					depth = sp.depth, -- 1547
					w = 26, -- 1547
					h = sp.h, -- 1547
					alive = true, -- 1547
					hitT = 0, -- 1547
					warnT = 0, -- 1547
					fireCd = 40, -- 1547
					kind = kind, -- 1548
					shieldHp = hp, -- 1548
					shieldHpMax = hp, -- 1548
					drop = sp.drop or "none", -- 1548
					homeX = sx, -- 1549
					swingT = 0, -- 1549
					awake = false, -- 1549
					squad = i -- 1549
				} -- 1549
				i = i + 1 -- 1541
			end -- 1541
		end -- 1541
		return -- 1552
	end -- 1552
	if self.room.key == "checkpoint" then -- 1552
		local ____self_enemies_81 = self.enemies -- 1552
		____self_enemies_81[#____self_enemies_81 + 1] = { -- 1555
			x = self.ox + 430, -- 1555
			y = 0, -- 1555
			w = 26, -- 1555
			h = 84, -- 1555
			alive = true, -- 1555
			hitT = 0, -- 1555
			warnT = 0, -- 1555
			fireCd = 0 -- 1555
		} -- 1555
		local ____self_enemies_82 = self.enemies -- 1555
		____self_enemies_82[#____self_enemies_82 + 1] = { -- 1556
			x = self.ox + 505, -- 1556
			y = 0, -- 1556
			w = 26, -- 1556
			h = 84, -- 1556
			alive = true, -- 1556
			hitT = 0, -- 1556
			warnT = 0, -- 1556
			fireCd = 0 -- 1556
		} -- 1556
		return -- 1557
	end -- 1557
	if self.room.key == "street" then -- 1557
		local ____self_enemies_83 = self.enemies -- 1557
		____self_enemies_83[#____self_enemies_83 + 1] = { -- 1561
			x = self.ox + 340, -- 1561
			y = 0, -- 1561
			w = 26, -- 1561
			h = 84, -- 1561
			alive = true, -- 1561
			hitT = 0, -- 1561
			warnT = 0, -- 1561
			fireCd = 0 -- 1561
		} -- 1561
		local ____self_enemies_84 = self.enemies -- 1561
		____self_enemies_84[#____self_enemies_84 + 1] = { -- 1562
			x = self.ox + 560, -- 1562
			y = 0, -- 1562
			w = 26, -- 1562
			h = 84, -- 1562
			alive = true, -- 1562
			hitT = 0, -- 1562
			warnT = 0, -- 1562
			fireCd = 0 -- 1562
		} -- 1562
	end -- 1562
end -- 1527
function Play.prototype.emit(self, name, data) -- 1568
	local ____self_events_85 = self.events -- 1568
	____self_events_85[#____self_events_85 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1569
	self.eventSeq = self.eventSeq + 1 -- 1570
	if #self.events > 256 then -- 1570
		table.remove(self.events, 1) -- 1572
	end -- 1572
end -- 1568
function Play.prototype.drainEvents(self) -- 1580
	local out = self.events -- 1581
	self.events = {} -- 1582
	return out -- 1583
end -- 1580
function Play.prototype.adoptEvents(self, events) -- 1592
	if #events == 0 then -- 1592
		return -- 1594
	end -- 1594
	local keep = {} -- 1596
	local i = 0 -- 1597
	do -- 1597
		i = 0 -- 1598
		while i < #events do -- 1598
			do -- 1598
				local e = events[i + 1] -- 1599
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1599
					goto __continue181 -- 1601
				end -- 1601
				keep[#keep + 1] = e -- 1603
			end -- 1603
			::__continue181:: -- 1603
			i = i + 1 -- 1598
		end -- 1598
	end -- 1598
	if #keep == 0 then -- 1598
		return -- 1606
	end -- 1606
	self.events = __TS__ArrayConcat(keep, self.events) -- 1608
	do -- 1608
		i = 0 -- 1609
		while i < #self.events do -- 1609
			self.events[i + 1].seq = i -- 1610
			i = i + 1 -- 1609
		end -- 1609
	end -- 1609
	self.eventSeq = #self.events -- 1612
end -- 1592
function Play.prototype.talentRank(self, talent) -- 1615
	if self.storyRoute == "soldier" and self:isEscortRoom() and self.run.story.talents ~= nil then -- 1615
		return self.run.story.talents.ranks[talent] or 0 -- 1617
	end -- 1617
	return 0 -- 1619
end -- 1615
function Play.prototype.reloadNeedTicks(self) -- 1623
	return RELOAD_ANSWER_TICKS + 60 * self:talentRank("focus") -- 1624
end -- 1623
function Play.prototype.getStoryTalentOffers(self) -- 1628
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1628
		return {} -- 1630
	end -- 1630
	local st = self.run.story.talents -- 1632
	return st ~= nil and st.room == self.room.key and st.offers or ({}) -- 1633
end -- 1628
function Play.prototype.getStoryTalentRanks(self) -- 1637
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() then -- 1637
		return nil -- 1639
	end -- 1639
	return self.run.story.talents ~= nil and self.run.story.talents.ranks or nil -- 1641
end -- 1637
function Play.prototype.getEscortAttempt(self) -- 1645
	return self.run.story.talents ~= nil and math.max(1, self.run.story.talents.attempt) or 1 -- 1646
end -- 1645
function Play.prototype.chooseTalent(self, slot) -- 1649
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1649
		return false -- 1651
	end -- 1651
	local st = self.run.story.talents -- 1653
	local talent = st ~= nil and st.offers[slot + 1] or nil -- 1654
	if st == nil or talent == nil then -- 1654
		return false -- 1656
	end -- 1656
	st.ranks[talent] = (st.ranks[talent] or 0) + 1 -- 1658
	st.offers = {} -- 1659
	self.talentModalActive = false -- 1660
	local extraMsg = "" -- 1661
	if talent == "vitality" then -- 1661
		self.maxHp = self.maxHp + 1 -- 1663
		self.hp = self.hp + 1 -- 1664
		self.run.story.maxHp = self.maxHp -- 1665
		self.run.story.hp = self.hp -- 1666
	elseif talent == "salvage" then -- 1666
		local inv = self.run.inventory -- 1668
		if inv.wood < 2 and inv.wood <= inv.bell or inv.bell >= 1 and st.ranks.salvage % 2 == 1 then -- 1668
			inv.wood = inv.wood + 1 -- 1670
			extraMsg = " · 得木纹筹×1" -- 1671
		else -- 1671
			inv.bell = inv.bell + 1 -- 1673
			extraMsg = " · 得铃纹筹×1" -- 1674
		end -- 1674
		self:syncCraftBench() -- 1676
	end -- 1676
	self.sessionDirty = true -- 1678
	self:flashSet(("本领 · " .. talentNames[talent]) .. extraMsg, 1.5) -- 1679
	self:emit("storyBeat", {beat = "talent_picked", talent = talent, rank = st.ranks[talent], room = self.room.key}) -- 1680
	return true -- 1681
end -- 1649
function Play.prototype.beginReload(self) -- 1688
	self.reloadT = self:reloadTicks() -- 1689
	local camp = self.room.campaign -- 1690
	if camp ~= nil and camp.reloadPuzzle == true then -- 1690
		self:openReloadPuzzle() -- 1692
	end -- 1692
end -- 1688
function Play.prototype.openReloadPuzzle(self) -- 1697
	self.reloadOpen = true -- 1698
	self.reloadAnswerTicks = 0 -- 1699
	self.reloadWorldTicks = 0 -- 1700
	self.reloadPath = {RELOAD_START} -- 1701
	self.reloadPendingEffect = "" -- 1702
	self.reloadTryCount = self.reloadTryCount + 1 -- 1703
	self:emit( -- 1704
		"reloadOpen", -- 1704
		{ -- 1704
			tryCount = self.reloadTryCount, -- 1704
			needTicks = self:reloadNeedTicks() -- 1704
		} -- 1704
	) -- 1704
end -- 1697
function Play.prototype.closeReloadPuzzle(self) -- 1708
	self.reloadOpen = false -- 1709
	self.reloadAnswerTicks = 0 -- 1710
	self.reloadWorldTicks = 0 -- 1711
	self.reloadPath = {RELOAD_START} -- 1712
	self.reloadPendingEffect = "" -- 1713
end -- 1708
function Play.prototype.reloadTapNode(self, node) -- 1720
	if not self.reloadOpen then -- 1720
		return -- 1722
	end -- 1722
	local path = self.reloadPath -- 1724
	local last = path[#path] -- 1725
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1725
		self.reloadPath = {RELOAD_START} -- 1727
		self:emit("reloadInvalid", {node = node, at = last}) -- 1728
		return -- 1729
	end -- 1729
	path[#path + 1] = node -- 1731
	if node ~= RELOAD_TARGET then -- 1731
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1733
		return -- 1734
	end -- 1734
	if not reloadPathValid(path) then -- 1734
		self.reloadPath = {RELOAD_START} -- 1737
		self:emit("reloadInvalid", {node = node, at = last}) -- 1738
		return -- 1739
	end -- 1739
	self.reloadPendingEffect = reloadEffectOf(path) -- 1741
	self.reloadOpen = false -- 1742
	self.reloadT = 0 -- 1743
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1744
	self:flashSet( -- 1747
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1747
		1.4 -- 1747
	) -- 1747
end -- 1720
function Play.prototype.consumeReloadEffect(self) -- 1751
	local e = self.reloadPendingEffect -- 1752
	if e ~= "" then -- 1752
		self.reloadPendingEffect = "" -- 1754
	end -- 1754
	return e -- 1756
end -- 1751
function Play.prototype.echoToSource(self, from, count, delayTicks) -- 1763
	if count == nil then -- 1763
		count = 1 -- 1763
	end -- 1763
	if delayTicks == nil then -- 1763
		delayTicks = 60 -- 1763
	end -- 1763
	local best = -1 -- 1764
	local bestD = 1000000000 -- 1765
	local i = 0 -- 1766
	local woken = {} -- 1767
	local n = 0 -- 1768
	while n < count do -- 1768
		best = -1 -- 1770
		bestD = 1000000000 -- 1771
		do -- 1771
			i = 0 -- 1772
			while i < #self.enemies do -- 1772
				do -- 1772
					if woken[i] == true then -- 1772
						goto __continue215 -- 1774
					end -- 1774
					local e = self.enemies[i + 1] -- 1776
					if not e.alive then -- 1776
						goto __continue215 -- 1778
					end -- 1778
					local d = math.abs(e.x - from.x) -- 1780
					if d < bestD then -- 1780
						bestD = d -- 1782
						best = i -- 1783
					end -- 1783
				end -- 1783
				::__continue215:: -- 1783
				i = i + 1 -- 1772
			end -- 1772
		end -- 1772
		if best < 0 then -- 1772
			break -- 1787
		end -- 1787
		woken[best] = true -- 1789
		local e = self.enemies[best + 1] -- 1790
		e.awake = true -- 1791
		e.warnT = 0 -- 1792
		e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 1793
		n = n + 1 -- 1794
	end -- 1794
	if n == 0 then -- 1794
		return -- 1797
	end -- 1797
	self:flashSet(n > 1 and "回声引到多处声源 · 敌群同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1799
end -- 1763
function Play.prototype.reloadTicks(self) -- 1802
	return math.max(6, self.run.inventory.quickbelt > 0 and 36 or 54) -- 1803
end -- 1802
function Play.prototype.update(self, dt, input) -- 1806
	self:syncCraftBench() -- 1807
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1807
		self:closeCraftBench() -- 1809
		return -- 1810
	end -- 1810
	if input.pause.pressed then -- 1810
		self.paused = not self.paused -- 1813
	end -- 1813
	if self.flashT > 0 then -- 1813
		self.flashT = self.flashT - dt -- 1816
		if self.flashT <= 0 then -- 1816
			self.flash = "" -- 1818
		end -- 1818
	end -- 1818
	if self.traceT > 0 then -- 1818
		self.traceT = self.traceT - dt -- 1822
		if self.traceT <= 0 then -- 1822
			self.trace = nil -- 1824
		end -- 1824
	end -- 1824
	if self.paused then -- 1824
		self:updateCamera(dt) -- 1828
		return -- 1829
	end -- 1829
	if self.escortFailed then -- 1829
		self.escortFailedTicks = self.escortFailedTicks + 1 -- 1833
		self:updateCamera(dt) -- 1834
		return -- 1835
	end -- 1835
	if self.craftBench.active then -- 1835
		self:updateCamera(dt) -- 1840
		return -- 1841
	end -- 1841
	if self.talentModalActive and #self:getStoryTalentOffers() > 0 and not self.reloadOpen then -- 1841
		self:updateCamera(dt) -- 1845
		return -- 1846
	end -- 1846
	if self.reloadOpen then -- 1846
		local needTicks = self:reloadNeedTicks() -- 1852
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1853
		if self.reloadAnswerTicks > needTicks then -- 1853
			self.reloadOpen = false -- 1855
			self.reloadPendingEffect = "" -- 1856
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = needTicks}) -- 1857
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1858
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1858
			self:updateCamera(dt) -- 1860
			return -- 1861
		else -- 1861
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1863
		end -- 1863
	end -- 1863
	self.ticks = self.ticks + 1 -- 1867
	if self.invulnT > 0 then -- 1867
		self.invulnT = self.invulnT - 1 -- 1871
	end -- 1871
	if self.isCampaign then -- 1871
		local ____self_run_86, ____ticks_87 = self.run, "ticks" -- 1871
		____self_run_86[____ticks_87] = ____self_run_86[____ticks_87] + 1 -- 1874
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1875
	end -- 1875
	local p = self.player -- 1877
	self:stepPlayer(p, dt, input) -- 1878
	self:refreshCover(p, input) -- 1880
	if self.carryOn then -- 1880
		self:carryPose() -- 1882
	end -- 1882
	if self.isCampaign then -- 1882
		self:stepCampaign(dt, input) -- 1885
		if not self.carryOn then -- 1885
			self:stepCampaignPartner(dt) -- 1887
		end -- 1887
	end -- 1887
	self:stepEnemies(dt, input) -- 1892
	if not self.isCampaign then -- 1892
		self:stepStory(dt, input) -- 1894
		self:stepEscort(dt, input) -- 1895
		self:stepVillage(dt, input) -- 1896
		self:stepChase(dt, input) -- 1897
		self:stepInteract(dt, input) -- 1898
	end -- 1898
	self:updateGate() -- 1900
	self:updateCamera(dt) -- 1901
	self:syncStory() -- 1903
end -- 1806
function Play.prototype.underLowArch(self, a) -- 1910
	local arch = self.room.arch -- 1911
	if arch.h <= 0 then -- 1911
		return false -- 1913
	end -- 1913
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1913
		return false -- 1916
	end -- 1916
	local top = arch.y + arch.h -- 1918
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1919
end -- 1910
function Play.prototype.coverAt(self, a) -- 1926
	local best = nil -- 1927
	local bestGap = 24 -- 1928
	local half = a.w / 2 -- 1929
	local i = 0 -- 1930
	do -- 1930
		i = 0 -- 1931
		while i < #self.boxes do -- 1931
			do -- 1931
				local b = self.boxes[i + 1] -- 1932
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1932
					goto __continue248 -- 1934
				end -- 1934
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1934
					goto __continue248 -- 1937
				end -- 1937
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1939
				if gap < bestGap then -- 1939
					bestGap = gap -- 1941
					best = b -- 1942
				end -- 1942
			end -- 1942
			::__continue248:: -- 1942
			i = i + 1 -- 1931
		end -- 1931
	end -- 1931
	return best -- 1945
end -- 1926
function Play.prototype.nearCover(self, a) -- 1948
	return self:coverAt(a) ~= nil -- 1949
end -- 1948
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1953
	if enemy == nil then -- 1953
		return false -- 1955
	end -- 1955
	local fromRight = enemy.x >= a.x -- 1957
	local edge = fromRight and b.x0 or b.x1 -- 1958
	local ____fromRight_88 -- 1959
	if fromRight then -- 1959
		____fromRight_88 = edge >= a.x - 0.001 and edge <= enemy.x -- 1959
	else -- 1959
		____fromRight_88 = edge <= a.x + 0.001 and edge >= enemy.x -- 1960
	end -- 1960
	local between = ____fromRight_88 -- 1959
	local separation = enemy.x - a.x -- 1961
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1962
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1963
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1964
end -- 1953
function Play.prototype.nearestEnemy(self, a) -- 1967
	local best -- 1968
	local bestD = 1000000000 -- 1969
	local i = 0 -- 1970
	do -- 1970
		i = 0 -- 1971
		while i < #self.enemies do -- 1971
			do -- 1971
				local e = self.enemies[i + 1] -- 1972
				if not e.alive then -- 1972
					goto __continue257 -- 1974
				end -- 1974
				local d = math.abs(e.x - a.x) -- 1976
				if d < bestD then -- 1976
					bestD = d -- 1978
					best = e -- 1979
				end -- 1979
			end -- 1979
			::__continue257:: -- 1979
			i = i + 1 -- 1971
		end -- 1971
	end -- 1971
	return best -- 1982
end -- 1967
function Play.prototype.refreshCover(self, a, input) -- 1986
	if self.childMode then -- 1986
		self.coverNear = false -- 1988
		self.coverHug = false -- 1989
		self.coverEntity = "" -- 1990
		self.coverBlocking = false -- 1991
		a.covered = false -- 1992
		return -- 1993
	end -- 1993
	local b = self:coverAt(a) -- 1995
	self.coverNear = b ~= nil -- 1996
	a.covered = self.coverNear and input.cover.held -- 1997
	self.coverHug = a.covered -- 1998
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1999
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 2000
		b, -- 2000
		a, -- 2000
		self:nearestEnemy(a) -- 2000
	) -- 2000
end -- 1986
function Play.prototype.cartHandleInReach(self, a) -- 2004
	if a == nil then -- 2004
		a = self.player -- 2004
	end -- 2004
	local c = self.room.cart -- 2005
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 2005
		return false -- 2007
	end -- 2007
	local handleX = self.cartAxle + c.handleOffset -- 2009
	local ____table_childMode_89 -- 2010
	if self.childMode then -- 2010
		____table_childMode_89 = math.abs(a.depth - (c.depth or 0)) <= 48 -- 2011
	else -- 2011
		____table_childMode_89 = inReachDepth(a.depth, c.depth or 0) -- 2012
	end -- 2012
	local depthOk = ____table_childMode_89 -- 2010
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and depthOk -- 2013
end -- 2004
function Play.prototype.nearLowLedge(self, a) -- 2018
	local reach = 26 -- 2019
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 2020
	local x1 = x0 + reach -- 2021
	local i = 0 -- 2022
	do -- 2022
		i = 0 -- 2023
		while i < #self.boxes do -- 2023
			do -- 2023
				local b = self.boxes[i + 1] -- 2024
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2024
					goto __continue266 -- 2026
				end -- 2026
				local rise = b.y1 - a.y -- 2028
				if rise > 0 and rise <= LEDGE_RISE then -- 2028
					return true -- 2030
				end -- 2030
			end -- 2030
			::__continue266:: -- 2030
			i = i + 1 -- 2023
		end -- 2023
	end -- 2023
	return false -- 2033
end -- 2018
function Play.prototype.stepPlayer(self, a, dt, input) -- 2036
	a.depthSpeed = 0 -- 2037
	if not a.alive then -- 2037
		return -- 2039
	end -- 2039
	local isChild = self.childMode -- 2041
	local lowArch = isChild and self:underLowArch(a) -- 2043
	if self:storyLocked() then -- 2043
		a.vx = 0 -- 2046
		a.crouch = isChild and lowArch -- 2047
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2048
		self:fallY(a, dt) -- 2049
		return -- 2050
	end -- 2050
	if not isChild and self.escort.state == "calming" then -- 2050
		a.crouch = false -- 2054
		a.h = SOLDIER_H -- 2055
		a.vx = 0 -- 2056
		self:fallY(a, dt) -- 2057
		return -- 2058
	end -- 2058
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 2060
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 2061
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2062
	local nearCover = not isChild and self:nearCover(a) -- 2063
	a.covered = nearCover and input.cover.held -- 2064
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 2066
	if a.rollT > 0 then -- 2066
		a.rollT = a.rollT - dt -- 2070
		local rollSpd = self:isEscortRoom() and ROLL_SPEED * (1 + 0.08 * self:talentRank("stride")) or ROLL_SPEED -- 2071
		a.vx = a.facing * rollSpd -- 2072
		self:slideX(a, a.vx * dt) -- 2073
		self:fallY(a, dt) -- 2074
		if a.rollT <= 0 then -- 2074
			self:flashSet("翻滚结束", 0.5) -- 2076
		end -- 2076
		return -- 2078
	end -- 2078
	local peacefulRoom = self.room.key == "museum" or self.room.key == "tower" -- 2081
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 2081
		if input.moveX ~= 0 then -- 2081
			a.facing = input.moveX > 0 and 1 or -1 -- 2084
		end -- 2084
		if self:nearLowLedge(a) then -- 2084
			a.vy = SOLDIER_JUMP -- 2088
			a.onGround = false -- 2089
			self:flashSet("翻上去", 0.3) -- 2090
			return -- 2091
		end -- 2091
		a.rollT = ROLL_TIME -- 2093
		self:flashSet("翻滚", 0.3) -- 2094
		return -- 2095
	end -- 2095
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 2098
	if isChild then -- 2098
		if input.cover.held then -- 2098
			speed = CHILD_SLOW -- 2101
		end -- 2101
		if a.crouch then -- 2101
			speed = CHILD_SLOW -- 2104
		elseif self.room.key == "forest" and self.forestPath == "ditch" and a.x >= self.ox + 700 and a.x <= self.ox + 1140 then -- 2104
			speed = CHILD_SPEED * 1.22 -- 2108
		end -- 2108
	else -- 2108
		if self:isEscortRoom() then -- 2108
			speed = speed * (1 + 0.1 * self:talentRank("stride")) -- 2112
		end -- 2112
		if a.covered then -- 2112
			speed = speed * 0.45 -- 2115
		end -- 2115
	end -- 2115
	local handsBusy = self.gripping or gripIntent or self.reloadOpen -- 2120
	local dir = (self.gripping or self.reloadOpen) and 0 or input.moveX -- 2121
	local depthDir = self.room.depth ~= nil and not handsBusy and -input.moveY or 0 -- 2123
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 2124
	if dir ~= 0 then -- 2124
		a.facing = dir > 0 and 1 or -1 -- 2126
	end -- 2126
	a.vx = dir * speed * diagonal -- 2128
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 2128
		a.vy = CHILD_JUMP -- 2132
		a.onGround = false -- 2133
		self:flashSet("跳", 0.25) -- 2134
	end -- 2134
	local previousDepth = a.depth -- 2138
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 2139
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2140
	self:slideX(a, a.vx * dt) -- 2141
	self:fallY(a, dt) -- 2142
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and not self.reloadOpen and input.fire.pressed then -- 2142
		self:shoot(a) -- 2146
	end -- 2146
	local ____temp_92 = not isChild and not peacefulRoom and not self.gripping and not self.reloadOpen and self.reloadPendingEffect == "" -- 2149
	if ____temp_92 then -- 2149
		local ____opt_90 = self.room.campaign -- 2149
		____temp_92 = (____opt_90 and ____opt_90.reloadPuzzle) == true -- 2149
	end -- 2149
	if ____temp_92 and input.flare.pressed then -- 2149
		self:beginReload() -- 2151
	end -- 2151
end -- 2036
function Play.prototype.stepPartner(self, p, dt) -- 2156
	local a = self.partner -- 2157
	if not a.alive then -- 2157
		return -- 2159
	end -- 2159
	a.crouch = false -- 2161
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 2162
	a.vx = 0 -- 2163
	a.depthSpeed = 0 -- 2164
	self:fallY(a, dt) -- 2165
end -- 2156
function Play.prototype.stepEscort(self, dt, input) -- 2172
	local a = self.partner -- 2173
	a.depthSpeed = 0 -- 2174
	if not a.alive then -- 2174
		return -- 2176
	end -- 2176
	if self.room.key == "gatepath" then -- 2176
		if self.carryOn then -- 2176
			return -- 2181
		end -- 2181
		local p = self.player -- 2184
		a.depth = p.depth -- 2185
		a.facing = p.facing -- 2186
		a.crouch = false -- 2187
		a.h = CHILD_H -- 2188
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 2189
		a.y = p.y -- 2190
		a.vy = 0 -- 2191
		a.vx = p.vx -- 2192
		a.onGround = p.onGround -- 2193
		return -- 2194
	end -- 2194
	if not self:escortOn() then -- 2194
		a.vx = 0 -- 2197
		self:fallY(a, dt) -- 2198
		return -- 2199
	end -- 2199
	local p = self.player -- 2201
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 2202
	local hadKnock1 = self.escort.knock1 -- 2203
	local hadKnock2 = self.escort.knock2 -- 2204
	self.calmConsumed = self.escort:update( -- 2205
		input, -- 2205
		p.x, -- 2205
		p.facing, -- 2205
		a.x, -- 2205
		dist -- 2205
	) -- 2205
	if not hadKnock1 and self.escort.knock1 then -- 2205
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 2208
	end -- 2208
	if not hadKnock2 and self.escort.knock2 then -- 2208
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 2211
	end -- 2211
	a.crouch = self.escort.crouchPose -- 2213
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 2214
	if not self.escort.stopped then -- 2214
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 2216
		local previousDepth = a.depth -- 2217
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 2218
		local distance = math.max( -- 2219
			-travel, -- 2219
			math.min(travel, targetDepth - previousDepth) -- 2219
		) -- 2219
		self:slideDepth(a, distance) -- 2220
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2221
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 2221
			a.vy = CHILD_JUMP -- 2223
			a.onGround = false -- 2224
		end -- 2224
	end -- 2224
	local dir = self.escort:moveDir(a.x) -- 2227
	a.vx = dir * CHILD_SPEED -- 2228
	if dir ~= 0 then -- 2228
		a.facing = dir -- 2230
		local before = a.x -- 2231
		self:slideX(a, dir * CHILD_SPEED * dt) -- 2232
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 2232
			a.vy = CHILD_JUMP -- 2235
			a.onGround = false -- 2236
		end -- 2236
	end -- 2236
	self:fallY(a, dt) -- 2239
end -- 2172
function Play.prototype.escortOn(self) -- 2243
	if self.room.key == "checkpoint" then -- 2243
		return true -- 2245
	end -- 2245
	if self.room.key == "gatepath" then -- 2245
		return true -- 2248
	end -- 2248
	if self.room.key == "prologue" then -- 2248
		return self.phase == "prologue-follow" -- 2251
	end -- 2251
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 2251
		return true -- 2255
	end -- 2255
	return self.room.key == "street" -- 2257
end -- 2243
function Play.prototype.storyLocked(self) -- 2261
	if self.caughtT > 0 then -- 2261
		return true -- 2263
	end -- 2263
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 2263
		return true -- 2267
	end -- 2267
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 2267
		return true -- 2270
	end -- 2270
	if self.room.key == "gate" and (self.phase == "gate-farewell" or self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 2270
		return true -- 2273
	end -- 2273
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2273
		return true -- 2276
	end -- 2276
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2276
		return true -- 2279
	end -- 2279
	if self.craftBench.active then -- 2279
		return true -- 2283
	end -- 2283
	return false -- 2285
end -- 2261
function Play.prototype.swapToChild(self, x) -- 2289
	local tmp = self.player -- 2290
	self.player = self.partner -- 2291
	self.partner = tmp -- 2292
	self.childMode = true -- 2293
	self.player.alive = true -- 2294
	self.player.x = self.ox + x -- 2295
	self.player.y = 0 -- 2296
	self.player.depth = 0 -- 2297
	self.player.depthSpeed = 0 -- 2298
	self.player.vy = 0 -- 2299
	self.player.vx = 0 -- 2300
	self.player.onGround = true -- 2301
	self.player.crouch = false -- 2302
	self.player.h = CHILD_H -- 2303
	self.player.facing = 1 -- 2304
	self.partner.alive = true -- 2305
	self.cam.x = self.player.x -- 2306
end -- 2289
function Play.prototype.swapToSoldier(self, x, childX) -- 2310
	local tmp = self.player -- 2311
	self.player = self.partner -- 2312
	self.partner = tmp -- 2313
	self.childMode = false -- 2314
	self.player.alive = true -- 2315
	self.player.x = self.ox + x -- 2316
	self.player.y = 0 -- 2317
	self.player.depth = 0 -- 2318
	self.player.depthSpeed = 0 -- 2319
	self.player.vy = 0 -- 2320
	self.player.vx = 0 -- 2321
	self.player.onGround = true -- 2322
	self.player.crouch = false -- 2323
	self.player.h = SOLDIER_H -- 2324
	self.player.facing = 1 -- 2325
	self.partner.alive = true -- 2326
	self.partner.x = self.ox + childX -- 2327
	self.partner.y = 0 -- 2328
	self.partner.depth = 0 -- 2329
	self.partner.depthSpeed = 0 -- 2330
	self.partner.vx = 0 -- 2331
	self.partner.vy = 0 -- 2332
	self.partner.onGround = true -- 2333
	self.partner.crouch = true -- 2334
	self.partner.h = CHILD_CROUCH_H -- 2335
	self.cam.x = self.player.x -- 2336
end -- 2310
function Play.prototype.stepStory(self, dt, input) -- 2340
	if self.room.key == "prologue" then -- 2340
		self:stepPrologue(dt, input) -- 2342
	elseif self.room.key == "street" then -- 2342
		self:stepStreet(dt, input) -- 2344
	elseif self.room.key == "gate" then -- 2344
		self:stepGate(dt, input) -- 2346
	elseif self.room.key == "gatepath" then -- 2346
		self:stepGatePath() -- 2348
	elseif self.room.key == "tower" then -- 2348
		self:stepTower(dt, input) -- 2350
	elseif self.room.key == "museum" then -- 2350
		self:stepMuseum(dt, input) -- 2352
	end -- 2352
end -- 2340
function Play.prototype.canPersistProgress(self) -- 2358
	return not self.isCampaign and self.run.source == "official" -- 2359
end -- 2358
function Play.prototype.wellWindow(self) -- 2363
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 2364
end -- 2363
function Play.prototype.nearWell(self) -- 2369
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 2370
end -- 2369
function Play.prototype.pickWell(self) -- 2378
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2378
		return false -- 2380
	end -- 2380
	self.phase = "prologue-well" -- 2382
	self.phaseTick = 0 -- 2383
	self.wellOpen = false -- 2384
	self:flashSet("井沿 · 伸手下去", 1.4) -- 2385
	self:log("旧井拾取") -- 2386
	return true -- 2387
end -- 2378
function Play.prototype.stepPrologue(self, dt, input) -- 2390
	local child = self.partner -- 2391
	if self.museumReturn then -- 2391
		self.museumReturn = false -- 2394
		self.phase = "prologue-wait" -- 2395
		self.phaseTick = 0 -- 2396
		self.player.x = self.ox + 260 -- 2397
		self.player.y = 0 -- 2398
		self.player.depth = 0 -- 2399
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2400
	end -- 2400
	if self.phase == "prologue-wake" then -- 2400
		self.introTick = self.introTick + 1 -- 2404
		if self.introTick == 60 then -- 2404
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2406
		end -- 2406
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2406
			self.phase = "prologue-shadow" -- 2409
			self.introTick = 0 -- 2410
			self:flashSet("门缝里两道影子", 1.2) -- 2411
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2412
		end -- 2412
		return -- 2414
	end -- 2414
	if self.phase == "prologue-shadow" then -- 2414
		self.introTick = self.introTick + 1 -- 2417
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2417
			self.phase = "prologue-escape" -- 2420
			self.introTick = 0 -- 2421
			self.escapeRemaining = self.escapeDuration -- 2422
			self.escapeRetryCount = 0 -- 2423
			self:swapToChild(100) -- 2424
			self:flashSet( -- 2425
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2425
				1.6 -- 2425
			) -- 2425
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2426
		end -- 2426
		return -- 2430
	end -- 2430
	if self.phase == "prologue-escape" then -- 2430
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2433
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2433
			self.phase = "prologue-hide" -- 2436
			self.introTick = 0 -- 2437
			self.player.vx = 0 -- 2438
			self.player.crouch = true -- 2439
			self.player.h = CHILD_CROUCH_H -- 2440
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2441
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2442
			return -- 2446
		end -- 2446
		if self.escapeRemaining <= 0 then -- 2446
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2450
			self.player.x = self.ox + 100 -- 2451
			self.player.y = 0 -- 2452
			self.player.depth = 0 -- 2453
			self.player.vx = 0 -- 2454
			self.player.vy = 0 -- 2455
			self.escapeRemaining = self.escapeDuration -- 2456
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2457
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2458
			return -- 2459
		end -- 2459
		return -- 2461
	end -- 2461
	if self.phase == "prologue-hide" then -- 2461
		self.introTick = self.introTick + 1 -- 2464
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2464
			self.phase = "prologue-wait" -- 2467
			self.phaseTick = 0 -- 2468
			self.introTick = 0 -- 2469
			self:swapToSoldier(260, 300) -- 2470
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2471
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2472
		end -- 2472
		return -- 2474
	end -- 2474
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2477
	if self.phase == "prologue-wait" then -- 2477
		child.crouch = true -- 2479
		child.h = CHILD_CROUCH_H -- 2480
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2480
			self:pickWell() -- 2482
			return -- 2483
		end -- 2483
		if not self.wellOpen and self:canPersistProgress() and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2483
			self.archive.museumPhase = "well_reflect" -- 2488
			self.archiveDirty = true -- 2489
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2490
			return -- 2491
		end -- 2491
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2493
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2495
		if near and input.interact.pressed then -- 2495
			self.phase = "prologue-give" -- 2497
			self.phaseTick = 0 -- 2498
			self:flashSet("递出针套", 1) -- 2499
		end -- 2499
		return -- 2501
	end -- 2501
	if self.phase == "prologue-well" then -- 2501
		self.phaseTick = self.phaseTick + 1 -- 2505
		if self.phaseTick == 12 then -- 2505
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2507
		elseif self.phaseTick >= 30 then -- 2507
			self.phase = "prologue-wait" -- 2509
			self.phaseTick = 0 -- 2510
			self.wellTaken = true -- 2511
			self.wellOpen = false -- 2512
			self.run.archive.artifactOwned = true -- 2513
			self.archiveDirty = true -- 2514
			self:emit("artifactFound", { -- 2515
				x = self.ox + self.wellX, -- 2516
				y = 0, -- 2516
				room = "prologue", -- 2516
				once = true, -- 2516
				source = self.run.source -- 2517
			}) -- 2517
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2519
			self:log("井底取到时间穿梭器") -- 2520
		end -- 2520
		return -- 2522
	end -- 2522
	if self.phase == "prologue-give" then -- 2522
		self.phaseTick = self.phaseTick + 1 -- 2525
		if self.phaseTick == 36 then -- 2525
			self:flashSet("针套递过去", 0.9) -- 2527
		elseif self.phaseTick == 108 then -- 2527
			self:flashSet("纸条塞进针套", 1) -- 2529
		elseif self.phaseTick >= ____exports.PROLOGUE_GIVE_TICKS then -- 2529
			self.phase = "prologue-follow" -- 2531
			self.phaseTick = 0 -- 2532
			child.crouch = false -- 2533
			child.h = CHILD_H -- 2534
			self:flashSet("她跟上了", 1.2) -- 2535
		end -- 2535
		return -- 2537
	end -- 2537
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2537
		local next = self.run.source == "debug" and "street" or "s1-crossroad" -- 2541
		self:requestRoom(next, "序章跟到门口") -- 2542
		self:flashSet(next == "s1-crossroad" and "进十字街" or "进街道", 1.2) -- 2543
	end -- 2543
end -- 2390
function Play.prototype.stepStreet(self, dt, input) -- 2548
	local p = self.player -- 2549
	local c = self.partner -- 2550
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2550
		local next = self.run.source == "debug" and "checkpoint" or "s1-crossroad" -- 2552
		self:requestRoom(next, "两人都到街尾") -- 2553
		self:flashSet(next == "s1-crossroad" and "进十字街" or "到检查站", 1.2) -- 2554
	end -- 2554
end -- 2548
function Play.prototype.stepGate(self, dt, input) -- 2559
	local ____temp_93 -- 2560
	if self.room.story == nil then -- 2560
		____temp_93 = nil -- 2560
	else -- 2560
		____temp_93 = self.room.story.gate -- 2560
	end -- 2560
	local g = ____temp_93 -- 2560
	if g == nil then -- 2560
		return -- 2562
	end -- 2562
	local p = self.player -- 2564
	if self.phase == "gate-idle" then -- 2564
		local a = self.partner -- 2567
		local gap = g.waitX - a.x -- 2568
		if math.abs(gap) > 3 then -- 2568
			a.facing = gap > 0 and 1 or -1 -- 2570
			a.vx = a.facing * CHILD_SPEED -- 2571
			local beforeX = a.x -- 2572
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2573
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2573
				a.vy = CHILD_JUMP -- 2575
				a.onGround = false -- 2576
			end -- 2576
			self:fallY(a, dt) -- 2578
		else -- 2578
			a.vx = 0 -- 2580
			a.x = g.waitX -- 2581
		end -- 2581
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2584
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2585
		if self.gateNeedConfirm then -- 2585
			if not input.interact.held then -- 2585
				self.gateRestartArmed = true -- 2590
			end -- 2590
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2590
				self.gateNeedConfirm = false -- 2593
				self.gateRestartArmed = true -- 2594
				self.phase = "gate-hold" -- 2595
				self.gateTick = 0 -- 2596
				self.gateSpawned = 0 -- 2597
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2598
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2599
			end -- 2599
			return -- 2601
		end -- 2601
		if atWinch and atWait then -- 2601
			self.phase = "gate-hold" -- 2604
			self.gateTick = 0 -- 2605
			self.gateSpawned = 0 -- 2606
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2607
		end -- 2607
		return -- 2609
	end -- 2609
	if self.phase == "gate-hold" then -- 2609
		self.gateTick = self.gateTick + 1 -- 2612
		local marks = {0, 540, 900, 1500} -- 2614
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2614
			local idx = self.gateSpawned -- 2616
			local ____self_enemies_94 = self.enemies -- 2616
			____self_enemies_94[#____self_enemies_94 + 1] = { -- 2617
				x = self.ox + 620 + idx * 62, -- 2618
				y = 0, -- 2618
				w = 26, -- 2618
				h = 84, -- 2618
				alive = true, -- 2619
				hitT = 0, -- 2619
				warnT = 0, -- 2619
				fireCd = 90 + idx * 45 -- 2619
			} -- 2619
			self.gateSpawned = self.gateSpawned + 1 -- 2621
			self:flashSet( -- 2622
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2622
				0.9 -- 2622
			) -- 2622
		end -- 2622
		if self.gateTick == 900 then -- 2622
			self:flashSet("棚布落下", 1) -- 2625
		elseif self.gateTick == 2100 then -- 2625
			self:flashSet("门底透进冷光了", 1) -- 2627
		end -- 2627
		if self.gateTick >= g.holdTicks then -- 2627
			self:captureGateBlood() -- 2632
			self.phase = "gate-send" -- 2633
			self.phaseTick = 0 -- 2634
			self.enemies = {} -- 2636
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2637
		end -- 2637
		return -- 2639
	end -- 2639
	if self.phase == "gate-send" then -- 2639
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2642
		if near and input.interact.pressed then -- 2642
			self:commitRoute() -- 2646
			self:swapToChild(g.doorX + 30) -- 2647
			self.phase = self.run.source == "debug" and "gate-count" or "gate-farewell" -- 2648
			self.phaseTick = 0 -- 2649
			self.countTick = 0 -- 2650
			self.countArmed = false -- 2652
			self.countPrevMove = input.moveX -- 2653
			self:flashSet("门开了 · 送她出去", 1.8) -- 2654
		end -- 2654
		return -- 2656
	end -- 2656
	if self.phase == "gate-farewell" then -- 2656
		self.phaseTick = self.phaseTick + 1 -- 2659
		self.countPrevMove = input.moveX -- 2660
		if self.phaseTick >= ____exports.GATE_FAREWELL_TICKS then -- 2660
			self.phase = "gate-count" -- 2662
			self.phaseTick = 0 -- 2663
			self.countTick = 0 -- 2664
			self.countArmed = false -- 2665
		end -- 2665
		return -- 2667
	end -- 2667
	if self.phase == "gate-count" then -- 2667
		self.countTick = self.countTick + 1 -- 2670
		if self.countTick == 360 then -- 2670
			self:flashSet("门关上", 0.9) -- 2672
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2672
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2674
			if self.storyRoute == "soldier" then -- 2674
				self.phase = "gate-wait" -- 2680
				self.phaseTick = 0 -- 2681
				self.knocks = 1 -- 2682
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2683
				self.handArmed = not input.interact.held and not self.intentGateReunionHold -- 2685
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2686
			else -- 2686
				self:flashSet("数到二十", 2.2) -- 2688
			end -- 2688
		end -- 2688
		local prevMove = self.countPrevMove -- 2693
		self.countPrevMove = input.moveX -- 2694
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2694
			if prevMove <= 0 and input.moveX > 0 then -- 2694
				self.countArmed = true -- 2697
			end -- 2697
			if self.countArmed and input.moveX > 0 then -- 2697
				self.phase = "gate-walk" -- 2700
				self.phaseTick = 0 -- 2701
				self:flashSet("她迈出第一步", 1.4) -- 2702
				self:emit("storyExit", { -- 2703
					route = "child", -- 2703
					via = "walk", -- 2703
					countTick = self.countTick, -- 2703
					hp = self.hp, -- 2703
					maxHp = self.maxHp -- 2703
				}) -- 2703
			end -- 2703
		end -- 2703
		return -- 2706
	end -- 2706
	if self.phase == "gate-wait" then -- 2706
		self.phaseTick = self.phaseTick + 1 -- 2710
		if self.phaseTick == 12 then -- 2710
			self.knocks = 2 -- 2712
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2713
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2714
		end -- 2714
		local held = input.interact.held or self.intentGateReunionHold -- 2716
		if not held then -- 2716
			if self.handTicks > 0 then -- 2716
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2719
			end -- 2719
			self.handTicks = 0 -- 2721
			self.handArmed = true -- 2722
			return -- 2723
		end -- 2723
		if self.handArmed then -- 2723
			self.handTicks = self.handTicks + 1 -- 2726
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2726
				self.intentGateReunionHold = false -- 2728
				self.phase = "gate-hand" -- 2729
				self.phaseTick = 0 -- 2730
				self.handDone = true -- 2731
				self.tied = true -- 2732
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2733
				if not self.lineSaid then -- 2733
					self.lineSaid = true -- 2735
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2736
				end -- 2736
				self:flashSet("我们走吧。", 3) -- 2738
			end -- 2738
		end -- 2738
		return -- 2741
	end -- 2741
	if self.phase == "gate-hand" then -- 2741
		self.phaseTick = self.phaseTick + 1 -- 2745
		if self.phaseTick == 30 then -- 2745
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2747
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2747
			self:emit("storyExit", { -- 2749
				route = "soldier", -- 2749
				via = "hand", -- 2749
				handTicks = self.handTicks, -- 2749
				hp = self.hp, -- 2749
				maxHp = self.maxHp -- 2749
			}) -- 2749
			self:requestRoom("gatepath", "牵手同行") -- 2750
		end -- 2750
		return -- 2752
	end -- 2752
	if self.phase == "gate-walk" then -- 2752
		if self.player.x >= g.exitX then -- 2752
			self:requestRoom("outside", "走出城门") -- 2757
			self:flashSet("出城门 · 城外", 1.4) -- 2758
		end -- 2758
	end -- 2758
end -- 2559
function Play.prototype.captureGateBlood(self) -- 2767
	self.hpAtGate = self.hp -- 2768
	self.maxHpAtGate = self.maxHp -- 2769
end -- 2767
function Play.prototype.commitRoute(self) -- 2776
	if self.storySettled then -- 2776
		return -- 2778
	end -- 2778
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2780
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2781
	self.hpAtGate = hp -- 2782
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2783
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2784
	self.storySettled = true -- 2785
	self.sessionDirty = true -- 2786
	self:emit("storyRouteLocked", { -- 2787
		route = self.storyRoute, -- 2788
		hp = self.hp, -- 2788
		maxHp = self.maxHp, -- 2788
		hpAtGate = self.hpAtGate, -- 2789
		maxHpAtGate = self.maxHpAtGate -- 2789
	}) -- 2789
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2791
end -- 2776
function Play.prototype.syncStory(self) -- 2795
	local s = self.run.story -- 2796
	if s == nil then -- 2796
		return -- 2798
	end -- 2798
	s.hp = self.hp -- 2800
	s.maxHp = self.maxHp -- 2801
	s.route = self.storyRoute -- 2802
	s.settled = self.storySettled -- 2803
	s.hpAtGate = self.hpAtGate -- 2804
	s.maxHpAtGate = self.maxHpAtGate -- 2805
	s.handDone = self.handDone -- 2806
	s.lineSaid = self.lineSaid -- 2807
	s.tied = self.tied -- 2808
	s.carry = self.carryOn -- 2809
	s.museumReturn = self.museumReturn -- 2810
	s.escortDone = self.escortDone -- 2811
	s.craftedWeapon = self.run.story.craftedWeapon -- 2812
	s.equippedWeapon = self.equippedWeapon -- 2813
	s.ending = self.run.story.ending -- 2814
	if self.room.key == "gate" then -- 2814
		s.phase = self.phase -- 2816
		s.countTick = self.countTick -- 2817
		s.phaseTick = self.phaseTick -- 2818
		s.handTicks = self.handTicks -- 2819
	end -- 2819
	if self.room.key == "prologue" then -- 2819
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2819
			s.phase = self.phase -- 2824
			s.phaseTick = self.phaseTick -- 2825
		end -- 2825
	end -- 2825
	if self.room.key == "tower" then -- 2825
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2825
			s.phase = self.phase -- 2831
			s.phaseTick = self.phaseTick -- 2832
		end -- 2832
	end -- 2832
end -- 2795
function Play.prototype.stepGatePath(self) -- 2838
	local ____temp_95 -- 2839
	if self.room.story == nil then -- 2839
		____temp_95 = nil -- 2839
	else -- 2839
		____temp_95 = self.room.story.gatepath -- 2839
	end -- 2839
	local gp = ____temp_95 -- 2839
	if self.phase == "gatepath-start" then -- 2839
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2839
			self.carryOn = true -- 2842
			self.phase = "gatepath-carry" -- 2843
			self.phaseTick = 0 -- 2844
			self.pathDone = true -- 2845
			self.escortDone = false -- 2846
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2847
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2848
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2849
		end -- 2849
		return -- 2851
	end -- 2851
	if self.phase == "gatepath-carry" then -- 2851
		self.phaseTick = self.phaseTick + 1 -- 2854
		if self.phaseTick == 20 then -- 2854
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2856
		end -- 2856
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2856
			self:requestRoom(gp.next, "背负进首战") -- 2859
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2860
		end -- 2860
	end -- 2860
end -- 2838
function Play.prototype.carryPose(self) -- 2869
	local p = self.player -- 2870
	local a = self.partner -- 2871
	a.alive = true -- 2872
	a.x = p.x - p.facing * 12 -- 2873
	a.y = p.y + 26 -- 2874
	a.depth = p.depth -- 2875
	a.vx = p.vx -- 2876
	a.vy = 0 -- 2877
	a.onGround = true -- 2878
	a.crouch = false -- 2879
	a.h = CHILD_CROUCH_H -- 2880
	a.facing = p.facing -- 2881
end -- 2869
function Play.prototype.stepMuseum(self, dt, input) -- 2889
	self.partner.alive = false -- 2890
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2891
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2894
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 2895
	local intentTarget = self.pendingMuseumIntentTarget -- 2896
	self.pendingMuseumIntentTarget = "" -- 2897
	local interactHit = input.interact.pressed or intentTarget ~= "" -- 2898
	if self.phase == "museum-cabinet" then -- 2898
		if atCase and interactHit or intentTarget == "cabinet" then -- 2898
			self.phase = "museum-hall" -- 2901
			self.phaseTick = 0 -- 2902
			if self:canPersistProgress() then -- 2902
				self.archive.museumPhase = "hall_walk" -- 2904
				self.archiveDirty = true -- 2905
			end -- 2905
			self:emit( -- 2907
				"museumStep", -- 2907
				{ -- 2907
					step = "cabinet", -- 2907
					x = self.ox + mu.cabinetX, -- 2907
					persisted = self:canPersistProgress() -- 2907
				} -- 2907
			) -- 2907
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2908
		end -- 2908
		return -- 2910
	end -- 2910
	if self.phase == "museum-hall" then -- 2910
		if intentTarget == "lamp_direct" and nearLamp then -- 2910
			self:emit( -- 2914
				"museumStep", -- 2914
				{ -- 2914
					step = "hall", -- 2914
					x = self.ox + mu.hallX, -- 2914
					persisted = self:canPersistProgress() -- 2914
				} -- 2914
			) -- 2914
			self.phase = "museum-return" -- 2915
			self.phaseTick = 0 -- 2916
			if self:canPersistProgress() then -- 2916
				self.archive.museumPhase = "return_cabinet" -- 2918
				self.archiveDirty = true -- 2919
			end -- 2919
			self:emit( -- 2921
				"museumStep", -- 2921
				{ -- 2921
					step = "lamp", -- 2921
					x = self.ox + mu.lampX, -- 2921
					persisted = self:canPersistProgress() -- 2921
				} -- 2921
			) -- 2921
			self:flashSet("灯 · 转向西窗", 1.8) -- 2922
			return -- 2923
		end -- 2923
		if self.player.x >= self.ox + mu.hallX and interactHit then -- 2923
			self.phase = "museum-lamp" -- 2926
			self.phaseTick = 0 -- 2927
			if self:canPersistProgress() then -- 2927
				self.archive.museumPhase = "lamp_turn" -- 2929
				self.archiveDirty = true -- 2930
			end -- 2930
			self:emit( -- 2932
				"museumStep", -- 2932
				{ -- 2932
					step = "hall", -- 2932
					x = self.ox + mu.hallX, -- 2932
					persisted = self:canPersistProgress() -- 2932
				} -- 2932
			) -- 2932
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2933
		end -- 2933
		return -- 2935
	end -- 2935
	if self.phase == "museum-lamp" then -- 2935
		if nearLamp and interactHit then -- 2935
			self.phase = "museum-return" -- 2939
			self.phaseTick = 0 -- 2940
			if self:canPersistProgress() then -- 2940
				self.archive.museumPhase = "return_cabinet" -- 2942
				self.archiveDirty = true -- 2943
			end -- 2943
			self:emit( -- 2945
				"museumStep", -- 2945
				{ -- 2945
					step = "lamp", -- 2945
					x = self.ox + mu.lampX, -- 2945
					persisted = self:canPersistProgress() -- 2945
				} -- 2945
			) -- 2945
			self:flashSet("灯 · 转向西窗", 1.8) -- 2946
		end -- 2946
		return -- 2948
	end -- 2948
	if self.phase == "museum-return" then -- 2948
		if atCase and interactHit or intentTarget == "return_cabinet" then -- 2948
			self.phase = "museum-knock" -- 2952
			self.phaseTick = 0 -- 2953
			self:emit( -- 2954
				"museumStep", -- 2954
				{ -- 2954
					step = "knock", -- 2954
					count = 1, -- 2954
					x = self.ox + mu.cabinetX, -- 2954
					persisted = self:canPersistProgress() -- 2954
				} -- 2954
			) -- 2954
			self:flashSet("回柜边 · 第一下", 0.8) -- 2955
		end -- 2955
		return -- 2957
	end -- 2957
	if self.phase == "museum-knock" then -- 2957
		self.phaseTick = self.phaseTick + 1 -- 2960
		if self.phaseTick == 8 then -- 2960
			self:emit( -- 2962
				"museumStep", -- 2962
				{ -- 2962
					step = "knock", -- 2962
					count = 2, -- 2962
					x = self.ox + mu.cabinetX, -- 2962
					persisted = self:canPersistProgress() -- 2962
				} -- 2962
			) -- 2962
			self:flashSet("回柜边 · 第二下", 0.8) -- 2963
		elseif self.phaseTick >= 36 then -- 2963
			self.phase = "museum-done" -- 2965
			self.phaseTick = 0 -- 2966
			if self:canPersistProgress() then -- 2966
				self.archive.museumSeen = true -- 2968
				self.archive.museumPhase = "done" -- 2969
				self.archiveDirty = true -- 2970
			end -- 2970
			self:emit( -- 2972
				"museumDone", -- 2972
				{ -- 2972
					steps = 4, -- 2972
					museumSeen = self.archive.museumSeen, -- 2972
					persisted = self:canPersistProgress() -- 2972
				} -- 2972
			) -- 2972
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2973
			self:log("博物馆 · 回柜边") -- 2974
		end -- 2974
		return -- 2976
	end -- 2976
	if interactHit then -- 2976
		self.museumReturn = true -- 2979
		self:requestRoom("prologue", "回柜边") -- 2980
	end -- 2980
end -- 2889
function Play.prototype.openTowerDoor(self) -- 2984
	self.towerDoorOpen = true -- 2985
	do -- 2985
		local i = 0 -- 2986
		while i < #self.boxes do -- 2986
			if self.boxes[i + 1].id == "tower_door" then -- 2986
				self.boxes[i + 1].hidden = true -- 2988
			end -- 2988
			i = i + 1 -- 2986
		end -- 2986
	end -- 2986
	self.run.story.segments.tower_door = true -- 2991
end -- 2984
function Play.prototype.stepTower(self, dt, input) -- 2994
	local ____temp_96 -- 2995
	if self.room.story == nil then -- 2995
		____temp_96 = nil -- 2995
	else -- 2995
		____temp_96 = self.room.story.tower -- 2995
	end -- 2995
	local t = ____temp_96 -- 2995
	if t == nil then -- 2995
		return -- 2997
	end -- 2997
	if self.storyRoute == "soldier" and self.partner.alive then -- 2997
		local targetX = math.max(self.ox + 408, self.player.x - 28) -- 3001
		local gap = targetX - self.partner.x -- 3002
		if math.abs(gap) > 2 then -- 3002
			local dir = gap > 0 and 1 or -1 -- 3004
			local stepDist = math.min( -- 3005
				math.abs(gap), -- 3005
				SOLDIER_SPEED * dt -- 3005
			) -- 3005
			self.partner.facing = dir -- 3006
			self.partner.vx = dir * SOLDIER_SPEED -- 3007
			local ____self_partner_97, ____x_98 = self.partner, "x" -- 3007
			____self_partner_97[____x_98] = ____self_partner_97[____x_98] + dir * stepDist -- 3008
		else -- 3008
			self.partner.vx = 0 -- 3010
			self.partner.facing = 1 -- 3011
		end -- 3011
	end -- 3011
	if self.phase == "tower-wait" then -- 3011
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 3015
		if near and input.interact.pressed then -- 3015
			self.phase = "tower-knock" -- 3017
			self.phaseTick = 0 -- 3018
			self.knocks = 1 -- 3019
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 3020
			self:flashSet("叩两下 · 第一声", 0.6) -- 3021
		end -- 3021
		return -- 3023
	end -- 3023
	if self.phase == "tower-knock" then -- 3023
		self.phaseTick = self.phaseTick + 1 -- 3026
		if self.phaseTick == 12 then -- 3026
			self.knocks = 2 -- 3028
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 3029
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 3030
		elseif self.phaseTick >= t.knockTicks then -- 3030
			self:openTowerDoor() -- 3032
			self.phase = "tower-enter" -- 3033
			self.phaseTick = 0 -- 3034
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 3035
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 3036
		end -- 3036
		return -- 3038
	end -- 3038
	if self.phase == "tower-enter" then -- 3038
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 3038
			self.phase = "tower-desk" -- 3042
			self.phaseTick = 0 -- 3043
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 3044
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 3045
		end -- 3045
		return -- 3047
	end -- 3047
	if self.phase == "tower-desk" then -- 3047
		local deskX = self.ox + 605 -- 3050
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 3051
		if not near or not input.interact.held then -- 3051
			self.deskHold = 0 -- 3053
			return -- 3054
		end -- 3054
		self.deskHold = self.deskHold + 1 -- 3056
		if self.deskHold == 12 then -- 3056
			self:flashSet("针套 · 放在桌上", 1) -- 3058
		elseif self.deskHold == 24 then -- 3058
			self:flashSet("指南针 · 压住纸条", 1) -- 3060
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 3060
			self.towerHanded = true -- 3062
			self.deskHold = 0 -- 3063
			self.run.story.segments.tower_handover = true -- 3064
			self.phase = "tower-given" -- 3065
			self.phaseTick = 0 -- 3066
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 3067
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 3072
		end -- 3072
		return -- 3074
	end -- 3074
	if self.phase == "tower-given" then -- 3074
		local soldier = self.storyRoute == "soldier" -- 3079
		self.phaseTick = self.phaseTick + 1 -- 3080
		if self.phaseTick == 60 then -- 3080
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 3082
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 3083
		elseif self.phaseTick == 120 then -- 3083
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 3085
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 3085
			self.phase = "tower-end" -- 3087
			self.phaseTick = 0 -- 3088
			self.towerEndMustRelease = input.interact.held or input.retry.held -- 3089
			if not self.run.finished then -- 3089
				self.run.finished = true -- 3091
				local ending = soldier and "reunion" or "lamp" -- 3092
				self.run.story.ending = ending -- 3093
				local ____soldier_99 -- 3096
				if soldier then -- 3096
					____soldier_99 = self.run.story.segments.escort5 == true -- 3097
				else -- 3097
					____soldier_99 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 3098
				end -- 3098
				local played = ____soldier_99 -- 3096
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 3099
				if official then -- 3099
					if soldier then -- 3099
						self.run.archive.soldierCleared = true -- 3103
					else -- 3103
						self.run.archive.childCleared = true -- 3105
					end -- 3105
					self.archiveDirty = true -- 3107
				end -- 3107
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 3109
				self:emit("endingReached", { -- 3110
					route = soldier and "soldier" or "child", -- 3111
					ending = ending, -- 3112
					official = official, -- 3113
					source = self.run.source, -- 3114
					lines = {self.endingLines[1], self.endingLines[2]}, -- 3115
					childCleared = self.run.archive.childCleared, -- 3116
					soldierCleared = self.run.archive.soldierCleared, -- 3117
					artifactOwned = self.run.archive.artifactOwned, -- 3118
					equipped = self.equippedWeapon -- 3119
				}) -- 3119
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 3121
			end -- 3121
		end -- 3121
		return -- 3124
	end -- 3124
	self.phaseTick = self.phaseTick + 1 -- 3126
	local held = input.interact.held or input.retry.held -- 3127
	if self.towerEndMustRelease then -- 3127
		if not held then -- 3127
			self.towerEndMustRelease = false -- 3130
		end -- 3130
		return -- 3132
	end -- 3132
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 3134
	if self.phaseTick < waitTicks then -- 3134
		if input.interact.pressed or input.retry.pressed then -- 3134
			self.towerEndMustRelease = held -- 3137
		end -- 3137
		return -- 3139
	end -- 3139
	if input.interact.pressed or input.retry.pressed then -- 3139
		self.restartStory = true -- 3143
		self:requestRoom("prologue", "片尾再玩") -- 3144
		self:flashSet("回到序章", 1.4) -- 3145
	end -- 3145
end -- 2994
function Play.prototype.stepChase(self, dt, input) -- 3150
	if self.caughtT > 0 then -- 3150
		self.caughtT = self.caughtT - dt -- 3152
		if self.caughtT <= 0 then -- 3152
			self:recoverFromCaught() -- 3154
		end -- 3154
		return -- 3156
	end -- 3156
	if self.room.key == "village" then -- 3156
		self:stepScavChase() -- 3159
	elseif self.room.key == "forest" then -- 3159
		self:stepForestRoute() -- 3161
		self:stepDog(dt) -- 3162
		if self.player.x >= self.ox + 1450 then -- 3162
			self:requestRoom("tower", "到林缘北塔") -- 3165
			self:flashSet("林缘 · 北塔", 1.4) -- 3166
		end -- 3166
	end -- 3166
end -- 3150
function Play.prototype.stepScavChase(self) -- 3172
	local s = self.room.scavenger -- 3173
	if s == nil then -- 3173
		return -- 3175
	end -- 3175
	local p = self.player -- 3177
	if self.passed and p.x > self.ox + 440 then -- 3177
		if self.scavChase then -- 3177
			self.scavChase = false -- 3181
			self.scavState = "back" -- 3182
			self.scavT = 0 -- 3183
		end -- 3183
		return -- 3185
	end -- 3185
	local dx = p.x - self.scavX -- 3187
	local dist = math.abs(dx) -- 3188
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 3189
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 3190
	if not self.scavChase then -- 3190
		if visible then -- 3190
			self.scavSee = self.scavSee + 1 -- 3193
			if self.scavSee >= 24 then -- 3193
				self.scavChase = true -- 3195
				self.scavState = "chase" -- 3196
				self.scavTargetX = p.x -- 3197
				self:flashSet("他看见你了", 1.2) -- 3198
			end -- 3198
		else -- 3198
			self.scavSee = 0 -- 3201
		end -- 3201
		return -- 3203
	end -- 3203
	if hidden then -- 3203
		self.scavSee = 0 -- 3207
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 3208
		self.scavT = self.scavT - 1 -- 3209
		if self.scavT <= 0 then -- 3209
			self.scavChase = false -- 3211
			self.scavState = "patrol" -- 3212
			self:flashSet("他失去了目标", 1) -- 3213
		end -- 3213
		return -- 3215
	end -- 3215
	local dir = p.x > self.scavX and 1 or -1 -- 3218
	self.scavX = self.scavX + dir * 96 / 60 -- 3219
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 3219
		self:caught() -- 3221
		return -- 3222
	end -- 3222
end -- 3172
function Play.prototype.stepDog(self, dt) -- 3227
	local ____temp_100 -- 3228
	if self.room.story == nil then -- 3228
		____temp_100 = nil -- 3228
	else -- 3228
		____temp_100 = self.room.story.dog -- 3228
	end -- 3228
	local dog = ____temp_100 -- 3228
	if dog == nil then -- 3228
		return -- 3230
	end -- 3230
	local p = self.player -- 3232
	local ox = self.ox -- 3233
	local dist = math.abs(p.x - self.dogX) -- 3234
	local inBurrowCover = p.crouch and p.x >= ox + 300 and p.x <= ox + 460 -- 3235
	local inBrushCover = p.crouch and (p.x >= ox + 700 and p.x <= ox + 790 or p.x >= ox + 1150 and p.x <= ox + 1240) -- 3236
	local sheltered = inBurrowCover or inBrushCover -- 3240
	local inDitchSprint = not p.crouch and self.forestPath == "ditch" and p.x >= ox + 700 and p.x <= ox + 1140 -- 3241
	local effectiveRange = inDitchSprint and dog.range * 1.25 or dog.range -- 3242
	local earNeedTicks = inDitchSprint and 12 or 18 -- 3243
	if self.dogState == "patrol" then -- 3243
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 3245
		if self.dogX < dog.x0 then -- 3245
			self.dogX = dog.x0 -- 3247
			self.dogDir = 1 -- 3248
		elseif self.dogX > dog.x1 then -- 3248
			self.dogX = dog.x1 -- 3250
			self.dogDir = -1 -- 3251
		end -- 3251
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 3253
		local twigOffsets = {235, 455, 865, 1115} -- 3254
		local nearTwig = false -- 3255
		local ti = 0 -- 3256
		do -- 3256
			ti = 0 -- 3257
			while ti < #twigOffsets do -- 3257
				if math.abs(p.x - (ox + twigOffsets[ti + 1])) <= 18 and p.y <= 8 then -- 3257
					nearTwig = true -- 3259
					break -- 3260
				end -- 3260
				ti = ti + 1 -- 3257
			end -- 3257
		end -- 3257
		local twigRange = nearTwig and math.max(effectiveRange, 400) or effectiveRange -- 3263
		if not sheltered and not p.crouch and moving and dist < twigRange then -- 3263
			self.dogState = "ear" -- 3265
			self.dogT = nearTwig and math.min(earNeedTicks, 12) or earNeedTicks -- 3266
			self.dogTargetX = p.x -- 3267
			self:flashSet(inDitchSprint and "旧渠枯枝响 · 狗立刻转耳" or (nearTwig and "踩断枯枝 · 狗立刻转耳" or "狗转耳朵"), 0.8) -- 3268
		end -- 3268
		return -- 3270
	end -- 3270
	if self.dogState == "ear" then -- 3270
		if sheltered then -- 3270
			self.dogState = "sniff" -- 3274
			self.dogT = 45 -- 3275
			self:flashSet("钻进遮蔽 · 狗顿住了", 0.9) -- 3276
			return -- 3277
		end -- 3277
		self.dogT = self.dogT - 1 -- 3279
		if self.dogT <= 0 then -- 3279
			self.dogState = "chase" -- 3281
			self.dogTargetX = p.x -- 3282
			self:flashSet("狗追来了", 1.4) -- 3283
		end -- 3283
		return -- 3285
	end -- 3285
	if self.dogState == "chase" then -- 3285
		local dir = p.x > self.dogX and 1 or -1 -- 3288
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 3289
		if not sheltered and math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 3289
			self:caught() -- 3291
			self.dogState = "sniff" -- 3292
			self.dogT = 60 -- 3293
		elseif dist > effectiveRange * 1.5 or sheltered then -- 3293
			self.dogState = "sniff" -- 3295
			self.dogT = 60 -- 3296
			self:flashSet(inBurrowCover and "树根窄洞遮住身形 · 狗停下了" or "狗停下了", 0.9) -- 3297
		end -- 3297
		return -- 3299
	end -- 3299
	if self.dogState == "sniff" then -- 3299
		self.dogT = self.dogT - 1 -- 3302
		if self.dogT <= 0 then -- 3302
			self.dogState = "back" -- 3304
		end -- 3304
		return -- 3306
	end -- 3306
	local dir = dog.x0 > self.dogX and 1 or -1 -- 3309
	self.dogX = self.dogX + dir * dog.speed * dt -- 3310
	if math.abs(self.dogX - dog.x0) < 2 then -- 3310
		self.dogX = dog.x0 -- 3312
		self.dogState = "patrol" -- 3313
	end -- 3313
end -- 3227
function Play.prototype.stepForestRoute(self) -- 3318
	local p = self.player -- 3319
	local ox = self.ox -- 3320
	if self.forestPath == "" then -- 3320
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 3320
			self.forestPath = "burrow" -- 3323
			self.run.story.segments.forest_burrow = true -- 3324
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 3325
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 3326
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 3326
			self.forestPath = "ditch" -- 3328
			self.run.story.segments.forest_ditch = true -- 3329
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 3330
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 3331
		end -- 3331
	end -- 3331
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 3331
		self.waterSeen = true -- 3335
		self.run.story.segments.water_lantern = true -- 3336
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 3337
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 3338
	end -- 3338
end -- 3318
function Play.prototype.caught(self) -- 3342
	self.caughtT = 1 -- 3343
	self:flashSet("被抓 · 回到安全点", 1.6) -- 3344
end -- 3342
function Play.prototype.recoverFromCaught(self) -- 3348
	local p = self.player -- 3349
	p.x = self.ox + 140 -- 3350
	p.y = 0 -- 3351
	p.vy = 0 -- 3352
	p.vx = 0 -- 3353
	p.onGround = true -- 3354
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3354
		self.scavX = self.room.scavenger.x0 -- 3356
		self.scavState = "patrol" -- 3357
		self.scavSee = 0 -- 3358
		self.scavChase = false -- 3359
		self.scavT = 0 -- 3360
	end -- 3360
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3360
		self.dogX = self.room.story.dog.x0 -- 3363
		self.dogState = "patrol" -- 3364
		self.dogT = 0 -- 3365
	end -- 3365
	self.cam.x = p.x -- 3367
	self.cam.y = p.y + CAM_LOOK_UP -- 3368
	self:flashSet("回到安全点", 1.2) -- 3369
end -- 3348
function Play.prototype.updateGate(self) -- 3373
	if self.room.key ~= "checkpoint" then -- 3373
		self.gateOpen = false -- 3375
		return -- 3376
	end -- 3376
	local function inZone(x) -- 3378
		return x >= self.ox + 792 and x <= self.ox + 928 -- 3378
	end -- 3378
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 3379
end -- 3373
function Play.prototype.addItem(self, kind) -- 3385
	local inv = self.run.inventory -- 3386
	if kind == "shield" then -- 3386
		if inv.shield >= TOOL_CAP then -- 3386
			return false -- 3389
		end -- 3389
		inv.shield = inv.shield + 1 -- 3391
		return true -- 3392
	end -- 3392
	if kind == "wedge" then -- 3392
		if inv.wedge >= CONSUMABLE_CAP then -- 3392
			return false -- 3396
		end -- 3396
		inv.wedge = inv.wedge + 1 -- 3398
		return true -- 3399
	end -- 3399
	if kind == "ammo" then -- 3399
		if inv.ammo >= CONSUMABLE_CAP then -- 3399
			return false -- 3403
		end -- 3403
		inv.ammo = inv.ammo + 1 -- 3405
		return true -- 3406
	end -- 3406
	if kind == "scrap" then -- 3406
		inv.scrap = inv.scrap + 1 -- 3410
		return true -- 3411
	end -- 3411
	if kind == "wood" then -- 3411
		inv.wood = inv.wood + 1 -- 3414
		return true -- 3415
	end -- 3415
	if kind == "bell" then -- 3415
		inv.bell = inv.bell + 1 -- 3418
		return true -- 3419
	end -- 3419
	if kind == "pass" then -- 3419
		inv.pass = inv.pass + 1 -- 3422
		return true -- 3423
	end -- 3423
	if kind == "quickbelt" then -- 3423
		inv.quickbelt = inv.quickbelt + 1 -- 3426
		return true -- 3427
	end -- 3427
	return false -- 3429
end -- 3385
function Play.prototype.findBox(self, id) -- 3432
	local i = 0 -- 3433
	do -- 3433
		i = 0 -- 3434
		while i < #self.boxes do -- 3434
			if self.boxes[i + 1].id == id then -- 3434
				return self.boxes[i + 1] -- 3436
			end -- 3436
			i = i + 1 -- 3434
		end -- 3434
	end -- 3434
	return nil -- 3439
end -- 3432
function Play.prototype.findWedgeTarget(self) -- 3443
	local best = nil -- 3444
	local bestD = 0 -- 3445
	local i = 0 -- 3446
	do -- 3446
		i = 0 -- 3447
		while i < #self.boxes do -- 3447
			do -- 3447
				local b = self.boxes[i + 1] -- 3448
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3448
					goto __continue529 -- 3450
				end -- 3450
				if not self:nearBox(b, 26) then -- 3450
					goto __continue529 -- 3453
				end -- 3453
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3455
				if best == nil or d < bestD then -- 3455
					best = b -- 3457
					bestD = d -- 3458
				end -- 3458
			end -- 3458
			::__continue529:: -- 3458
			i = i + 1 -- 3447
		end -- 3447
	end -- 3447
	return best -- 3461
end -- 3443
function Play.prototype.stepCraft(self, input) -- 3469
	local inv = self.run.inventory -- 3470
	local required = math.max( -- 3471
		6, -- 3471
		CRAFT_TICKS - 6 * self:talentRank("salvage") -- 3471
	) -- 3471
	if self.craftT > 0 then -- 3471
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3471
			self.craftT = 0 -- 3475
			self:flashSet("制作中断", 0.8) -- 3476
			return true -- 3477
		end -- 3477
		self.craftT = self.craftT + 1 -- 3479
		if self.craftT >= required then -- 3479
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3479
				inv.scrap = inv.scrap - 1 -- 3482
				inv.wedge = inv.wedge + 1 -- 3483
				self:flashSet("制得木楔", 1.2) -- 3484
				self:log("制木楔") -- 3485
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3486
			end -- 3486
			self.craftT = 0 -- 3488
		end -- 3488
		return true -- 3490
	end -- 3490
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3490
		self.craftT = 1 -- 3493
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3494
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3495
		return true -- 3496
	end -- 3496
	return false -- 3498
end -- 3469
function Play.prototype.nearBox(self, b, reach) -- 3501
	local p = self.player -- 3502
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3503
end -- 3501
function Play.prototype.findInteract(self) -- 3509
	local p = self.player -- 3510
	local best = nil -- 3511
	local bestD = 1000000000 -- 3512
	local i = 0 -- 3513
	do -- 3513
		i = 0 -- 3514
		while i < #self.boxes do -- 3514
			do -- 3514
				local b = self.boxes[i + 1] -- 3515
				if b.interact == nil or b.broken == true then -- 3515
					goto __continue542 -- 3517
				end -- 3517
				if not self:nearBox(b, b.interact.reach or 27) then -- 3517
					goto __continue542 -- 3520
				end -- 3520
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3522
				if d < bestD then -- 3522
					bestD = d -- 3524
					best = b -- 3525
				end -- 3525
			end -- 3525
			::__continue542:: -- 3525
			i = i + 1 -- 3514
		end -- 3514
	end -- 3514
	return best -- 3528
end -- 3509
function Play.prototype.stepCampaign(self, dt, input) -- 3532
	local wr = self.room -- 3533
	local p = self.player -- 3534
	if self.reloadT > 0 then -- 3534
		self.reloadT = self.reloadT - 1 -- 3536
	end -- 3536
	if self.bracedShield ~= nil then -- 3536
		self.bracedShield.x = p.x + p.facing * 26 -- 3540
		self.bracedShield.y = p.y -- 3541
		local shBox = __TS__ArrayFind( -- 3542
			self.boxes, -- 3542
			function(____, b) return b.id == "braced_shield" end -- 3542
		) -- 3542
		if shBox ~= nil then -- 3542
			shBox.x0 = self.bracedShield.x - 15 -- 3544
			shBox.x1 = self.bracedShield.x + 15 -- 3545
			shBox.y0 = self.bracedShield.y -- 3546
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3547
		end -- 3547
	end -- 3547
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3547
		self.run.route = "drygoods" -- 3553
		self.run.joined = false -- 3554
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3555
		self:log("转布行线") -- 3556
	end -- 3556
	if wr.key == "escort3" then -- 3556
		local nearBench = p.x >= wr.minX + 472 and p.x <= wr.minX + 710 and p.y < 60 -- 3561
		if nearBench and input.interact.pressed then -- 3561
			self:openCraftBench() -- 3563
			return -- 3564
		end -- 3564
		local ____temp_103 = self.storyRoute == "soldier" -- 3566
		if ____temp_103 then -- 3566
			local ____opt_101 = self.run.story.talents -- 3566
			____temp_103 = (____opt_101 and ____opt_101.deferred) == true -- 3566
		end -- 3566
		if ____temp_103 and p.x >= wr.minX + 940 then -- 3566
			self:triggerDeferredEscort3Draft() -- 3567
		end -- 3567
	end -- 3567
	local i = 0 -- 3571
	do -- 3571
		i = 0 -- 3572
		while i < #self.pickups do -- 3572
			do -- 3572
				local pk = self.pickups[i + 1] -- 3573
				if self.run.taken[pk.id] == true then -- 3573
					goto __continue556 -- 3575
				end -- 3575
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3577
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3578
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3578
					if not self:addItem(pk.kind) then -- 3578
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3582
						self:log("满包拒绝 " .. pk.kind) -- 3583
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3584
						goto __continue556 -- 3585
					end -- 3585
					self.run.taken[pk.id] = true -- 3587
					self:flashSet("拾取 " .. pk.label, 1) -- 3588
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3589
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3590
				end -- 3590
			end -- 3590
			::__continue556:: -- 3590
			i = i + 1 -- 3572
		end -- 3572
	end -- 3572
	self.calmConsumed = false -- 3594
	local ____temp_109 = self.partner.alive and self.run.joined -- 3595
	if ____temp_109 then -- 3595
		local ____opt_104 = self.room.campaign -- 3595
		local ____temp_108 = (____opt_104 and ____opt_104.chapter) == "S" -- 3596
		if not ____temp_108 then -- 3596
			local ____opt_106 = self.room.campaign -- 3596
			____temp_108 = (____opt_106 and ____opt_106.chapter) == "C" -- 3596
		end -- 3596
		____temp_109 = ____temp_108 -- 3595
	end -- 3595
	if ____temp_109 and (self.escort.fear > 0 or self.escort.state == "frozen" or self.escort.state == "calming") then -- 3595
		local dist = inReachDepth(p.depth, self.partner.depth) and math.abs(p.x - self.partner.x) or 1000000000 -- 3598
		local hadK1 = self.escort.knock1 -- 3599
		local hadK2 = self.escort.knock2 -- 3600
		self.calmConsumed = self.escort:update( -- 3601
			input, -- 3601
			p.x, -- 3601
			p.facing, -- 3601
			self.partner.x, -- 3601
			dist -- 3601
		) -- 3601
		if not hadK1 and self.escort.knock1 then -- 3601
			self:emit("knock", {count = 1, x = self.partner.x, room = self.room.key}) -- 3603
		end -- 3603
		if not hadK2 and self.escort.knock2 then -- 3603
			self:emit("knock", {count = 2, x = self.partner.x, room = self.room.key}) -- 3606
		end -- 3606
		self.partner.crouch = self.escort.crouchPose -- 3608
		self.partner.h = self.partner.crouch and CHILD_CROUCH_H or CHILD_H -- 3609
	end -- 3609
	if not self.calmConsumed and not self:stepCraft(input) and input.interact.pressed then -- 3609
		self:campaignInteract() -- 3612
	end -- 3612
	self:stepCampaignCart(dt, input) -- 3614
	self:stepCampaignGoal() -- 3615
	self:campaignCheckpoint() -- 3616
end -- 3532
function Play.prototype.campaignCheckpoint(self) -- 3620
	local i = 0 -- 3621
	do -- 3621
		i = 0 -- 3622
		while i < #self.room.marks do -- 3622
			do -- 3622
				local m = self.room.marks[i + 1] -- 3623
				if m.kind ~= 0 then -- 3623
					goto __continue566 -- 3625
				end -- 3625
				local dx = self.player.x - m.x -- 3627
				local dy = self.player.y - m.y -- 3628
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3628
					self.checkpoint = m.x -- 3630
					self:captureCheckpoint(m.x) -- 3631
					self:flashSet("检查点", 1) -- 3632
				end -- 3632
			end -- 3632
			::__continue566:: -- 3632
			i = i + 1 -- 3622
		end -- 3622
	end -- 3622
end -- 3620
function Play.prototype.campaignInteract(self) -- 3638
	local b = self:findInteract() -- 3639
	if b ~= nil then -- 3639
		self:useInteract(b) -- 3641
		return -- 3642
	end -- 3642
	local inv = self.run.inventory -- 3644
	if inv.wedge > 0 then -- 3644
		local w = self:findWedgeTarget() -- 3646
		if w ~= nil then -- 3646
			local ____opt_110 = w.breakable -- 3646
			local extraHp = (____opt_110 and ____opt_110.wedgeHp or 1) + self:talentRank("salvage") -- 3648
			if w.breakable ~= nil then -- 3648
				local ____w_breakable_112, ____hp_113 = w.breakable, "hp" -- 3648
				____w_breakable_112[____hp_113] = ____w_breakable_112[____hp_113] + extraHp -- 3650
			end -- 3650
			inv.wedge = inv.wedge - 1 -- 3652
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3653
			self:flashSet( -- 3655
				extraHp > 1 and ("钉木楔 · 多承" .. tostring(extraHp)) .. "次" or "钉木楔 · 多承一次", -- 3655
				1.2 -- 3655
			) -- 3655
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3656
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3657
			return -- 3658
		end -- 3658
		if self:isEscortRoom() then -- 3658
			local p = self.player -- 3661
			local wx = math.max( -- 3662
				self.room.minX + 64, -- 3662
				math.min(self.room.maxX - 64, p.x + p.facing * 32) -- 3662
			) -- 3662
			local hp = 1 + self:talentRank("salvage") -- 3663
			self.fieldWedgeSeq = self.fieldWedgeSeq + 1 -- 3664
			local wid = "field_wedge_" .. tostring(self.fieldWedgeSeq) -- 3665
			local ____self_boxes_114 = self.boxes -- 3665
			____self_boxes_114[#____self_boxes_114 + 1] = { -- 3666
				x0 = wx - 12, -- 3667
				x1 = wx + 12, -- 3668
				y0 = p.y, -- 3669
				y1 = p.y + 48, -- 3670
				depth = {min = p.depth - 20, max = p.depth + 20}, -- 3671
				label = "立起的木楔掩体", -- 3672
				id = wid, -- 3673
				breakable = {hp = hp, kind = "thin_wood", wedgeable = true} -- 3674
			} -- 3674
			inv.wedge = inv.wedge - 1 -- 3676
			self:flashSet( -- 3677
				"立木楔 · 临时挡弹" .. (hp > 1 and ("(" .. tostring(hp)) .. "击)" or ""), -- 3677
				1.2 -- 3677
			) -- 3677
			self:log("立木楔掩体") -- 3678
			self:emit("interactUsed", {kind = "wedge", x = wx}) -- 3679
			return -- 3680
		end -- 3680
	end -- 3680
	if inv.ammo > 0 and self.reloadT > 0 then -- 3680
		self.reloadT = 0 -- 3685
		self:closeReloadPuzzle() -- 3686
		inv.ammo = inv.ammo - 1 -- 3687
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3688
		self:log("用备用弹包") -- 3689
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3690
		return -- 3691
	end -- 3691
	local canBraceHere = self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 or self:isEscortRoom() -- 3693
	if inv.shield > 0 and self.bracedShield == nil and canBraceHere then -- 3693
		local p = self.player -- 3697
		local shHp = 1 + self:talentRank("salvage") -- 3698
		self.bracedShield = { -- 3699
			x = p.x + p.facing * 26, -- 3699
			y = p.y, -- 3699
			w = 30, -- 3699
			h = 64, -- 3699
			hp = shHp -- 3699
		} -- 3699
		local ____self_boxes_115 = self.boxes -- 3699
		____self_boxes_115[#____self_boxes_115 + 1] = { -- 3700
			x0 = self.bracedShield.x - 15, -- 3701
			x1 = self.bracedShield.x + 15, -- 3701
			y0 = p.y, -- 3702
			y1 = p.y + 64, -- 3702
			depth = {min = -46, max = 46}, -- 3702
			label = "架起的残盾", -- 3702
			id = "braced_shield", -- 3702
			soft = true -- 3703
		} -- 3703
		inv.shield = inv.shield - 1 -- 3705
		self:flashSet( -- 3706
			shHp > 1 and ("架残盾 · 可挡" .. tostring(shHp)) .. "发" or "架残盾 · 挡一发", -- 3706
			1.2 -- 3706
		) -- 3706
		self:log("架残盾") -- 3707
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3708
		return -- 3709
	end -- 3709
	if inv.pass > 0 and self.run.joined == false then -- 3709
		inv.pass = inv.pass - 1 -- 3712
		self.run.joined = true -- 3713
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3714
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3715
		return -- 3716
	end -- 3716
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3718
end -- 3638
function Play.prototype.useInteract(self, b) -- 3721
	local kind = b.interact == nil and "" or b.interact.kind -- 3722
	local wr = self.room -- 3723
	if kind == "open_board" then -- 3723
		b.broken = true -- 3725
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3726
		for ____, cover in ipairs(self.boxes) do -- 3727
			if cover.id == "s2_board_cover" then -- 3727
				cover.broken = false -- 3729
				cover.hidden = false -- 3730
			end -- 3730
		end -- 3730
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3733
		self.run.joined = true -- 3734
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3735
		self:log("放下窗板") -- 3736
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3737
		return -- 3738
	end -- 3738
	if kind == "lower_curtain" then -- 3738
		for ____, curtain in ipairs(self.boxes) do -- 3741
			if curtain.id == "c2_curtain" then -- 3741
				curtain.broken = false -- 3743
				curtain.hidden = false -- 3744
			end -- 3744
		end -- 3744
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3747
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3748
		self:log("放下木帘") -- 3749
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3750
		return -- 3751
	end -- 3751
	if kind == "raise_latch" then -- 3751
		if wr.key == "c2-granary" and not self.cartDocked then -- 3751
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3755
			return -- 3756
		end -- 3756
		b.broken = true -- 3758
		self.objectiveDone = true -- 3759
		if wr.key == "c1-yard" then -- 3759
			self.run.c1Latch = true -- 3762
			self.run.joined = true -- 3763
			for ____, door in ipairs(self.boxes) do -- 3764
				if door.id == "c1_door" then -- 3764
					door.broken = true -- 3766
				end -- 3766
			end -- 3766
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3769
		else -- 3769
			self.run.c2Latch = true -- 3771
			self.run.joined = true -- 3772
		end -- 3772
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3774
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3775
		self:log("抬闩") -- 3776
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3777
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3778
	end -- 3778
end -- 3721
function Play.prototype.stepCampaignCart(self, dt, input) -- 3783
	local wr = self.room -- 3784
	local c = wr.cart -- 3785
	if c.bodyW <= 0 then -- 3785
		return -- 3787
	end -- 3787
	local p = self.player -- 3789
	local handleX = self.cartAxle + c.handleOffset -- 3790
	if not self.gripping then -- 3790
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3790
			self.gripping = true -- 3794
			self:flashSet("握住车柄 · A/D 推", 1) -- 3795
		end -- 3795
		return -- 3797
	end -- 3797
	if input.interact.pressed then -- 3797
		self.gripping = false -- 3800
		self:flashSet("松手", 0.5) -- 3801
		return -- 3802
	end -- 3802
	if not self.cartDocked then -- 3802
		if input.moveX ~= 0 and not self:stuckCart() then -- 3802
			self.cartAxle = math.max( -- 3806
				c.startX, -- 3806
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3806
			) -- 3806
		end -- 3806
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3806
			self.cartExposed = true -- 3811
			local gun = nil -- 3812
			local gi = 0 -- 3813
			do -- 3813
				gi = 0 -- 3814
				while gi < #self.enemies do -- 3814
					local e = self.enemies[gi + 1] -- 3815
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3815
						gun = e -- 3817
						break -- 3818
					end -- 3818
					gi = gi + 1 -- 3814
				end -- 3814
			end -- 3814
			if gun ~= nil then -- 3814
				self:campaignEnemyFire(gun) -- 3822
			end -- 3822
		end -- 3822
		p.x = self.cartAxle + c.handleOffset -- 3825
		p.y = c.baseY -- 3826
		p.depth = c.depth or 0 -- 3827
		p.vx = 0 -- 3828
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3828
			self.cartAxle = c.endX -- 3830
			self.cartDocked = true -- 3831
			self.gripping = false -- 3832
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3833
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3834
			self:flashSet("车轮入窝", 1.2) -- 3835
			self:log("车轮入窝") -- 3836
		end -- 3836
	end -- 3836
end -- 3783
function Play.prototype.stuckCart(self) -- 3842
	local i = 0 -- 3843
	do -- 3843
		i = 0 -- 3844
		while i < #self.boxes do -- 3844
			do -- 3844
				local b = self.boxes[i + 1] -- 3845
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3845
					goto __continue609 -- 3847
				end -- 3847
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3849
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3849
					return true -- 3851
				end -- 3851
			end -- 3851
			::__continue609:: -- 3851
			i = i + 1 -- 3844
		end -- 3844
	end -- 3844
	return false -- 3854
end -- 3842
function Play.prototype.stepCampaignGoal(self) -- 3858
	local wr = self.room -- 3859
	local c = wr.campaign -- 3860
	if c == nil then -- 3860
		return -- 3862
	end -- 3862
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3862
		self.objectiveDone = true -- 3865
	end -- 3865
	if c.goal == "reach_exit" then -- 3865
		self.objectiveDone = true -- 3868
	end -- 3868
	if not self.objectiveDone then -- 3868
		return -- 3871
	end -- 3871
	local p = self.player -- 3873
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3874
	if p.x < c.exitX or not partnerOk then -- 3874
		return -- 3876
	end -- 3876
	if self.run.story.segments[wr.key] ~= true then -- 3876
		self.run.story.segments[wr.key] = true -- 3880
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3881
	end -- 3881
	if wr.key == "escort5" then -- 3881
		self.escortDone = true -- 3885
		self.run.story.escortDone = true -- 3886
	end -- 3886
	if c.next ~= nil and c.next ~= "" then -- 3886
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3889
		self:flashSet("过关 · " .. c.next, 1.2) -- 3890
	elseif wr.key == "c2-granary" and (self.run.source == "official" or self.run.source == "chapter") then -- 3890
		self:requestRoom("gate", "军粮棚出口") -- 3893
		self:flashSet("出军粮棚 · 城门", 1.4) -- 3894
	elseif not self.run.finished then -- 3894
		self.run.finished = true -- 3896
		self:flashSet( -- 3897
			"军粮棚清完 · 回城门 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3897
			2 -- 3897
		) -- 3897
		self:log("军粮棚清完 · 回城门") -- 3898
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3899
	end -- 3899
end -- 3858
function Play.prototype.stepCampaignPartner(self, dt) -- 3904
	local a = self.partner -- 3905
	local wr = self.room -- 3906
	local cp = wr.companion -- 3907
	if not a.alive then -- 3907
		return -- 3909
	end -- 3909
	local p = self.player -- 3911
	if self.craftBench.active then -- 3911
		a.vx = 0 -- 3914
		return -- 3915
	end -- 3915
	local wait = false -- 3917
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3918
	local targetDepth = p.depth -- 3919
	if self.run.joined == false then -- 3919
		wait = true -- 3921
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3922
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3923
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3923
		wait = true -- 3925
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3926
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3927
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3927
		wait = true -- 3929
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3930
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3931
	end -- 3931
	if self.partnerStuck > 0.3 then -- 3931
		a.x = a.x + a.facing * 44 -- 3935
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3936
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3937
		self.partnerLaneHold = 1.1 -- 3938
		self.partnerStuck = 0 -- 3939
	end -- 3939
	if self.partnerLaneHold > 0 then -- 3939
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3942
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3943
	end -- 3943
	local dx = targetX - a.x -- 3945
	local stopTol = wait and 18 or 74 -- 3946
	if math.abs(dx) > stopTol then -- 3946
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3948
		local before = a.x -- 3949
		a.vx = dx > 0 and speed or -speed -- 3950
		a.facing = dx > 0 and 1 or -1 -- 3951
		self:slideX(a, a.vx * dt) -- 3952
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3952
			a.vy = CHILD_JUMP -- 3955
			a.onGround = false -- 3956
		end -- 3956
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3958
	else -- 3958
		a.vx = 0 -- 3960
		self.partnerStuck = 0 -- 3961
	end -- 3961
	local dz = targetDepth - a.depth -- 3963
	if math.abs(dz) > 6 then -- 3963
		local step = math.max( -- 3965
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3965
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3965
		) -- 3965
		a.depth = a.depth + step -- 3966
	end -- 3966
	a.depthSpeed = 0 -- 3968
	a.h = CHILD_H -- 3969
	a.crouch = false -- 3970
	self:fallY(a, dt) -- 3971
end -- 3904
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3975
	local p = self.player -- 3976
	local i = 0 -- 3977
	do -- 3977
		i = 0 -- 3978
		while i < #self.enemies and not self.escortFailed do -- 3978
			do -- 3978
				local e = self.enemies[i + 1] -- 3979
				if e.kind == "target" then -- 3979
					if not e.alive then -- 3979
						if e.hitT > 0 then -- 3979
							e.hitT = e.hitT - dt -- 3984
						end -- 3984
						if e.hitT <= 0 then -- 3984
							e.alive = true -- 3987
							e.hitT = 0 -- 3988
						end -- 3988
					end -- 3988
					goto __continue637 -- 3991
				end -- 3991
				if not e.alive then -- 3991
					goto __continue637 -- 3994
				end -- 3994
				if e.kind == "breaker" then -- 3994
					self:stepBreaker(e, dt) -- 3997
					goto __continue637 -- 3998
				end -- 3998
				if e.kind == "shield" then -- 3998
					self:stepShield(e, dt, input) -- 4001
					goto __continue637 -- 4002
				end -- 4002
				local dx = e.x - p.x -- 4005
				if not e.awake then -- 4005
					if math.abs(dx) > 520 then -- 4005
						goto __continue637 -- 4008
					end -- 4008
					e.awake = true -- 4010
					e.fireCd = 48 -- 4011
					goto __continue637 -- 4012
				end -- 4012
				if math.abs(dx) > ENEMY_RANGE then -- 4012
					goto __continue637 -- 4015
				end -- 4015
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 4015
					goto __continue637 -- 4020
				end -- 4020
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 4020
					goto __continue637 -- 4023
				end -- 4023
				if self:blockedShot(e, p) then -- 4023
					if e.warnT > 0 then -- 4023
						e.warnT = 0 -- 4029
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4030
					end -- 4030
					goto __continue637 -- 4032
				end -- 4032
				if e.warnT > 0 then -- 4032
					e.warnT = e.warnT - 1 -- 4035
					if e.warnT <= 0 then -- 4035
						self:campaignEnemyFire(e) -- 4037
					end -- 4037
				elseif e.fireCd > 0 then -- 4037
					e.fireCd = e.fireCd - 1 -- 4040
					if e.fireCd <= 0 then -- 4040
						e.warnT = WARN_TICKS -- 4042
					end -- 4042
				else -- 4042
					e.fireCd = 40 -- 4045
				end -- 4045
			end -- 4045
			::__continue637:: -- 4045
			i = i + 1 -- 3978
		end -- 3978
	end -- 3978
end -- 3975
function Play.prototype.blockedShot(self, e, p) -- 4051
	local eDepth = e.depth or 0 -- 4052
	local ex = e.x -- 4053
	local ey = e.y + e.h * 0.62 -- 4055
	local px = p.x -- 4056
	local py = p.y + p.h * 0.55 -- 4057
	local dx = px - ex -- 4058
	local dyScreen = py + p.depth * DEPTH_Y_SCALE - (ey + eDepth * DEPTH_Y_SCALE) -- 4059
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 4060
	if len < 0.01 then -- 4060
		return false -- 4062
	end -- 4062
	local ray = { -- 4066
		x = ex, -- 4067
		y = ey, -- 4067
		dx = dx / len, -- 4068
		dy = (py - ey) / len, -- 4068
		depth = eDepth, -- 4069
		dDepth = (p.depth - eDepth) / len -- 4069
	} -- 4069
	local best = -1 -- 4071
	local j = 0 -- 4072
	do -- 4072
		j = 0 -- 4073
		while j < #self.boxes do -- 4073
			do -- 4073
				local b = self.boxes[j + 1] -- 4074
				if b.broken == true or b.passable == true or b.hidden == true then -- 4074
					goto __continue660 -- 4076
				end -- 4076
				if b.id == "braced_shield" then -- 4076
					goto __continue660 -- 4081
				end -- 4081
				local t = hitBox(ray, b) -- 4083
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 4083
					best = t -- 4087
				end -- 4087
			end -- 4087
			::__continue660:: -- 4087
			j = j + 1 -- 4073
		end -- 4073
	end -- 4073
	return best >= 0 -- 4090
end -- 4051
function Play.prototype.campaignEnemyFire(self, e) -- 4093
	local p = self.player -- 4094
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4095
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 4095
		local ____self_bracedShield_116, ____hp_117 = self.bracedShield, "hp" -- 4095
		____self_bracedShield_116[____hp_117] = ____self_bracedShield_116[____hp_117] - 1 -- 4097
		if self.bracedShield.hp <= 0 then -- 4097
			self.boxes = __TS__ArrayFilter( -- 4099
				self.boxes, -- 4099
				function(____, b) return b.id ~= "braced_shield" end -- 4099
			) -- 4099
			self.bracedShield = nil -- 4100
			self:flashSet("残盾碎 · 挡下一发", 1) -- 4101
		else -- 4101
			self:flashSet( -- 4103
				"残盾挡下一发 · 余" .. tostring(self.bracedShield.hp), -- 4103
				1 -- 4103
			) -- 4103
		end -- 4103
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 4105
		return -- 4106
	end -- 4106
	if self:blockedShot(e, p) then -- 4106
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4109
		return -- 4110
	end -- 4110
	local cover = self:blockedByCover(e, p) -- 4112
	if cover ~= nil and self.coverHug then -- 4112
		self.coveredFlash = 0.5 -- 4114
		self:flashSet("掩体挡下", 0.6) -- 4115
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4116
		return -- 4121
	end -- 4121
	if self.invulnT > 0 then -- 4121
		return -- 4124
	end -- 4124
	self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4126
	self.craftT = 0 -- 4127
	self.hp = self.hp - 1 -- 4128
	self:emit("actorHit", { -- 4129
		target = "player", -- 4129
		amount = 1, -- 4129
		hp = self.hp, -- 4129
		maxHp = self.maxHp, -- 4129
		enemyX = e.x -- 4129
	}) -- 4129
	self:flashSet( -- 4130
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4130
		0.8 -- 4130
	) -- 4130
	if self.hp <= 0 then -- 4130
		self:campaignFailed() -- 4132
	end -- 4132
end -- 4093
function Play.prototype.stepShield(self, e, dt, input) -- 4137
	local p = self.player -- 4138
	local dx = p.x - e.x -- 4139
	local adx = math.abs(dx) -- 4140
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 4143
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 4144
	if adx > 44 then -- 4144
		local before = e.x -- 4146
		local stepX = (dx > 0 and 1 or -1) * 60 * dt -- 4147
		local nextX = math.max( -- 4148
			self.room.minX + 16, -- 4148
			math.min(self.room.maxX - 16, e.x + stepX) -- 4148
		) -- 4148
		if not self:enemyBlockedAtX(e, nextX) then -- 4148
			e.x = nextX -- 4150
		end -- 4150
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 4150
			e.depth = math.max( -- 4154
				-32, -- 4154
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4154
			) -- 4154
		end -- 4154
	elseif adx <= 48 and sameLane and (e.swingT or 0) <= 0 then -- 4154
		local fromFront = (e.x - p.x) * p.facing > 0 -- 4159
		local rollDodges = p.rollT > 0 and (fromFront or self:talentRank("guard") > 0) -- 4160
		if not rollDodges and self.invulnT <= 0 then -- 4160
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4162
			self.craftT = 0 -- 4163
			self.hp = self.hp - 1 -- 4164
			self:emit("actorHit", { -- 4165
				target = "player", -- 4165
				amount = 1, -- 4165
				hp = self.hp, -- 4165
				maxHp = self.maxHp, -- 4165
				enemyX = e.x -- 4165
			}) -- 4165
			self:flashSet( -- 4166
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4166
				0.8 -- 4166
			) -- 4166
			if self.hp <= 0 then -- 4166
				self:campaignFailed() -- 4168
				return -- 4169
			end -- 4169
		end -- 4169
		e.swingT = 70 -- 4172
	end -- 4172
	if (e.swingT or 0) > 0 then -- 4172
		e.swingT = (e.swingT or 0) - 1 -- 4175
	end -- 4175
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 4175
		local dd = p.depth - (e.depth or 0) -- 4178
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 4179
	end -- 4179
end -- 4137
function Play.prototype.stepBreaker(self, e, dt) -- 4184
	local p = self.player -- 4185
	if e.awake ~= true then -- 4185
		if math.abs(p.x - e.x) < 560 then -- 4185
			e.awake = true -- 4188
		else -- 4188
			return -- 4190
		end -- 4190
	end -- 4190
	local target = nil -- 4193
	local bestD = 1000000000 -- 4194
	local i = 0 -- 4195
	do -- 4195
		i = 0 -- 4196
		while i < #self.boxes do -- 4196
			do -- 4196
				local b = self.boxes[i + 1] -- 4197
				if b.breakable == nil or b.broken == true then -- 4197
					goto __continue687 -- 4199
				end -- 4199
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 4201
				if d < bestD then -- 4201
					bestD = d -- 4203
					target = b -- 4204
				end -- 4204
			end -- 4204
			::__continue687:: -- 4204
			i = i + 1 -- 4196
		end -- 4196
	end -- 4196
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 4207
	local dx = tx - e.x -- 4208
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 4209
	if math.abs(dx) > reach then -- 4209
		local before = e.x -- 4211
		local nextX = math.max( -- 4212
			self.room.minX + 16, -- 4212
			math.min(self.room.maxX - 16, e.x + (dx > 0 and 1 or -1) * 48 * dt) -- 4212
		) -- 4212
		if not self:enemyBlockedAtX(e, nextX) then -- 4212
			e.x = nextX -- 4214
		end -- 4214
		if math.abs(e.x - before) < 0.3 then -- 4214
			e.depth = math.max( -- 4217
				-32, -- 4217
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4217
			) -- 4217
		end -- 4217
	elseif (e.swingT or 0) <= 0 then -- 4217
		e.swingT = 64 -- 4220
		if target ~= nil then -- 4220
			self:damageProp(target, 2) -- 4222
		elseif math.abs(p.x - e.x) < 60 and math.abs((e.depth or 0) - p.depth) <= 26 and not (p.rollT > 0 and self:talentRank("guard") > 0) and self.invulnT <= 0 then -- 4222
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4225
			self.craftT = 0 -- 4226
			self.hp = self.hp - 1 -- 4227
			self:emit("actorHit", { -- 4228
				target = "player", -- 4228
				amount = 1, -- 4228
				hp = self.hp, -- 4228
				maxHp = self.maxHp, -- 4228
				enemyX = e.x -- 4228
			}) -- 4228
			self:flashSet("破障手近身", 0.8) -- 4229
			if self.hp <= 0 then -- 4229
				self:campaignFailed() -- 4231
				return -- 4232
			end -- 4232
		end -- 4232
	end -- 4232
	if (e.swingT or 0) > 0 then -- 4232
		e.swingT = (e.swingT or 0) - 1 -- 4237
	end -- 4237
end -- 4184
function Play.prototype.enemyBlockedAtX(self, e, nextX) -- 4242
	local half = e.w * 0.5 -- 4243
	local d = e.depth or 0 -- 4244
	local i = 0 -- 4245
	do -- 4245
		i = 0 -- 4246
		while i < #self.boxes do -- 4246
			do -- 4246
				local b = self.boxes[i + 1] -- 4247
				if b.broken == true or b.passable == true or b.soft == true or b.hidden == true or b.y0 >= e.y + e.h or b.y1 <= e.y + 4 then -- 4247
					goto __continue700 -- 4249
				end -- 4249
				if b.depth ~= nil and (d < b.depth.min - 8 or d > b.depth.max + 8) then -- 4249
					goto __continue700 -- 4252
				end -- 4252
				if nextX + half > b.x0 and nextX - half < b.x1 then -- 4252
					return true -- 4255
				end -- 4255
			end -- 4255
			::__continue700:: -- 4255
			i = i + 1 -- 4246
		end -- 4246
	end -- 4246
	return false -- 4258
end -- 4242
function Play.prototype.campaignFailed(self) -- 4261
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 4261
		if self.escortFailed then -- 4261
			return -- 4266
		end -- 4266
		if self.useEscortDeathSummary then -- 4266
			local story = self.run.story -- 4268
			local st = story.talents -- 4269
			local ranksCopy = { -- 4270
				vitality = st and st.ranks.vitality or 0, -- 4271
				guard = st and st.ranks.guard or 0, -- 4272
				stride = st and st.ranks.stride or 0, -- 4273
				focus = st and st.ranks.focus or 0, -- 4274
				push_force = st and st.ranks.push_force or 0, -- 4275
				echo_wide = st and st.ranks.echo_wide or 0, -- 4276
				lantern_pierce = st and st.ranks.lantern_pierce or 0, -- 4277
				salvage = st and st.ranks.salvage or 0 -- 4278
			} -- 4278
			local cleared = 0 -- 4280
			local segKeys = { -- 4281
				"escort1", -- 4281
				"escort2", -- 4281
				"escort3", -- 4281
				"escort4", -- 4281
				"escort5" -- 4281
			} -- 4281
			local si = 0 -- 4282
			do -- 4282
				si = 0 -- 4283
				while si < #segKeys do -- 4283
					if story.segments[segKeys[si + 1]] == true then -- 4283
						cleared = cleared + 1 -- 4285
					end -- 4285
					si = si + 1 -- 4283
				end -- 4283
			end -- 4283
			self.escortFailed = true -- 4288
			self.escortFailedTicks = 0 -- 4289
			self.talentModalActive = false -- 4290
			self.craftBench.active = false -- 4291
			self.reloadT = 0 -- 4292
			self:closeReloadPuzzle() -- 4293
			self.gripping = false -- 4294
			self.escortSummary = { -- 4295
				roomKey = self.room.key, -- 4296
				attempt = st ~= nil and math.max(1, st.attempt) or 1, -- 4297
				seed = st ~= nil and st.randomState or self.run.seed, -- 4298
				equippedWeapon = self.equippedWeapon, -- 4299
				segmentsCleared = cleared, -- 4300
				ranks = ranksCopy -- 4301
			} -- 4301
			self:resetEscortAttempt() -- 4303
			self:flashSet("折返山道 · 重整再赴", 2) -- 4304
			self:log("男主线折返 · 展示小结") -- 4305
			self:emit("campaignFailed", { -- 4306
				room = self.room.key, -- 4307
				hp = 0, -- 4307
				maxHp = self.maxHp, -- 4307
				reset = true, -- 4308
				to = "escort1", -- 4308
				route = self.storyRoute, -- 4308
				summary = true -- 4308
			}) -- 4308
			return -- 4310
		end -- 4310
		self:restartEscortRun() -- 4312
		return -- 4313
	end -- 4313
	local p = self.player -- 4315
	self.hp = self.maxHp -- 4316
	self.invulnT = INVULN_RESPAWN_TICKS -- 4317
	self.reloadT = 0 -- 4318
	self:closeReloadPuzzle() -- 4319
	self.gripping = false -- 4320
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 4321
	self:log("被击倒") -- 4322
	p.x = self.room.minX + 90 -- 4323
	p.y = 0 -- 4324
	p.depth = 0 -- 4325
	p.vx = 0 -- 4326
	p.vy = 0 -- 4327
	p.onGround = true -- 4328
	p.rollT = 0 -- 4329
	self.partner.x = p.x - 50 -- 4330
	self.partner.y = 0 -- 4331
	self.partner.depth = 0 -- 4332
	self.cam.x = p.x -- 4333
	local i = 0 -- 4334
	do -- 4334
		i = 0 -- 4335
		while i < #self.enemies do -- 4335
			do -- 4335
				local e = self.enemies[i + 1] -- 4336
				if not e.alive then -- 4336
					goto __continue712 -- 4338
				end -- 4338
				e.x = e.homeX == nil and e.x or e.homeX -- 4340
				e.warnT = 0 -- 4341
				e.fireCd = 40 -- 4342
				e.swingT = 0 -- 4343
				e.awake = false -- 4344
			end -- 4344
			::__continue712:: -- 4344
			i = i + 1 -- 4335
		end -- 4335
	end -- 4335
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4346
end -- 4261
function Play.prototype.isEscortRoom(self) -- 4350
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 4351
end -- 4350
function Play.prototype.confirmEscortRestart(self) -- 4355
	if not self.escortFailed then -- 4355
		return false -- 4357
	end -- 4357
	self:requestRoom("escort1", "男主线失败重开") -- 4359
	return true -- 4360
end -- 4355
function Play.prototype.restartEscortRun(self) -- 4364
	self:resetEscortAttempt() -- 4365
	self:requestRoom("escort1", "男主线失败重开") -- 4366
end -- 4364
function Play.prototype.resetEscortAttempt(self) -- 4374
	local story = self.run.story -- 4375
	local inv = self.run.inventory -- 4376
	local prevAttempt = story.talents ~= nil and math.max(1, story.talents.attempt) or 1 -- 4377
	local nextAttempt = prevAttempt + 1 -- 4378
	local vitBonus = story.talents ~= nil and (story.talents.ranks.vitality or 0) or 0 -- 4379
	if vitBonus > 0 then -- 4379
		self.maxHp = math.max(3, self.maxHp - vitBonus) -- 4381
		story.maxHp = self.maxHp -- 4382
	end -- 4382
	story.talents = createStoryTalents(self.run.seed, nextAttempt) -- 4384
	self.hp = self.maxHp -- 4385
	story.hp = self.maxHp -- 4386
	story.cp = nil -- 4387
	self.checkpointSnap = nil -- 4388
	story.carry = false -- 4389
	self.carryOn = false -- 4390
	story.craftedWeapon = "" -- 4391
	self.equippedWeapon = "standard_gun" -- 4392
	story.equippedWeapon = "standard_gun" -- 4393
	story.escortDone = false -- 4394
	self.escortDone = false -- 4395
	story.segments = {} -- 4396
	inv.wood = 0 -- 4397
	inv.bell = 0 -- 4398
	inv.scrap = 0 -- 4399
	inv.wedge = 0 -- 4400
	inv.ammo = 0 -- 4401
	inv.quickbelt = 0 -- 4402
	inv.shield = 0 -- 4403
	inv.pass = 0 -- 4404
	local taken = self.run.taken -- 4405
	local keys = __TS__ObjectKeys(taken) -- 4406
	local i = 0 -- 4407
	do -- 4407
		i = 0 -- 4408
		while i < #keys do -- 4408
			local k = keys[i + 1] -- 4409
			if (string.find(k, "e2_", nil, true) or 0) - 1 == 0 or (string.find(k, "e3_", nil, true) or 0) - 1 == 0 or (string.find(k, "escort", nil, true) or 0) - 1 == 0 then -- 4409
				__TS__Delete(taken, k) -- 4411
			end -- 4411
			i = i + 1 -- 4408
		end -- 4408
	end -- 4408
	local propKeys = __TS__ObjectKeys(self.run.props) -- 4414
	do -- 4414
		i = 0 -- 4415
		while i < #propKeys do -- 4415
			local pk = propKeys[i + 1] -- 4416
			if (string.find(pk, "e1_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e2_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e3_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e4_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e5_", nil, true) or 0) - 1 == 0 or (string.find(pk, "field_wedge_", nil, true) or 0) - 1 == 0 then -- 4416
				__TS__Delete(self.run.props, pk) -- 4419
			end -- 4419
			i = i + 1 -- 4415
		end -- 4415
	end -- 4415
	self.bracedShield = nil -- 4422
	self.talentModalActive = false -- 4423
	self.run.joined = true -- 4424
	self.reloadT = 0 -- 4425
	self:closeReloadPuzzle() -- 4426
	self.gripping = false -- 4427
	self.sessionDirty = true -- 4428
	self:flashSet( -- 4429
		("重整启程 · 第" .. tostring(nextAttempt)) .. "轮护送", -- 4429
		2 -- 4429
	) -- 4429
	self:log(("男主线重开 · 第" .. tostring(nextAttempt)) .. "轮回 escort1") -- 4430
	if not self.useEscortDeathSummary then -- 4430
		self:emit("campaignFailed", { -- 4432
			room = self.room.key, -- 4433
			hp = 0, -- 4433
			maxHp = self.maxHp, -- 4433
			reset = true, -- 4434
			to = "escort1", -- 4434
			route = self.storyRoute, -- 4434
			attempt = nextAttempt -- 4434
		}) -- 4434
	end -- 4434
end -- 4374
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 4440
	local i = 0 -- 4441
	do -- 4441
		i = 0 -- 4442
		while i < #self.enemies do -- 4442
			do -- 4442
				if i == skipIndex then -- 4442
					goto __continue729 -- 4444
				end -- 4444
				local e = self.enemies[i + 1] -- 4446
				if not e.alive or math.abs(e.x - center.x) > radius then -- 4446
					goto __continue729 -- 4448
				end -- 4448
				e.awake = true -- 4450
				e.fireCd = math.max(e.fireCd or 0, 150) -- 4451
				e.warnT = 0 -- 4452
			end -- 4452
			::__continue729:: -- 4452
			i = i + 1 -- 4442
		end -- 4442
	end -- 4442
end -- 4440
function Play.prototype.stepEnemies(self, dt, input) -- 4456
	local i = 0 -- 4457
	do -- 4457
		i = 0 -- 4458
		while i < #self.enemies do -- 4458
			local e = self.enemies[i + 1] -- 4459
			if e.hitT > 0 then -- 4459
				e.hitT = e.hitT - dt -- 4461
			end -- 4461
			i = i + 1 -- 4458
		end -- 4458
	end -- 4458
	if self.coveredFlash > 0 then -- 4458
		self.coveredFlash = self.coveredFlash - dt -- 4465
	end -- 4465
	if self.isCampaign then -- 4465
		self:stepCampaignEnemies(dt, input) -- 4468
		return -- 4469
	end -- 4469
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 4469
		return -- 4473
	end -- 4473
	do -- 4473
		i = 0 -- 4475
		while i < #self.enemies do -- 4475
			do -- 4475
				local e = self.enemies[i + 1] -- 4476
				if not e.alive then -- 4476
					goto __continue740 -- 4478
				end -- 4478
				if e.warnT > 0 then -- 4478
					e.warnT = e.warnT - 1 -- 4481
					if e.warnT <= 0 then -- 4481
						self:enemyFire(e, input) -- 4483
					end -- 4483
					goto __continue740 -- 4485
				end -- 4485
				if e.fireCd > 0 then -- 4485
					e.fireCd = e.fireCd - 1 -- 4488
					if e.fireCd <= 0 then -- 4488
						e.warnT = WARN_TICKS -- 4490
					end -- 4490
				else -- 4490
					e.warnT = WARN_TICKS -- 4494
				end -- 4494
			end -- 4494
			::__continue740:: -- 4494
			i = i + 1 -- 4475
		end -- 4475
	end -- 4475
end -- 4456
function Play.prototype.enemyFire(self, e, input) -- 4500
	local p = self.player -- 4501
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 4501
		self:flashSet("枪声响在远处", 0.4) -- 4503
		e.fireCd = FIRE_COOLDOWN -- 4504
		return -- 4505
	end -- 4505
	if self:blockedShot(e, p) then -- 4505
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4508
		e.fireCd = FIRE_COOLDOWN -- 4509
		return -- 4510
	end -- 4510
	local cover = self:blockedByCover(e, p) -- 4513
	local hugging = cover ~= nil -- 4514
	self.coverBlocking = hugging -- 4515
	local covered = hugging and input.cover.held -- 4516
	if covered then -- 4516
		self.coveredFlash = 0.5 -- 4518
		self:flashSet("掩体挡下", 0.5) -- 4519
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4520
		e.fireCd = FIRE_COOLDOWN -- 4525
		return -- 4526
	end -- 4526
	if self.invulnT > 0 then -- 4526
		e.fireCd = FIRE_COOLDOWN -- 4529
		return -- 4530
	end -- 4530
	self.invulnT = INVULN_HIT_TICKS -- 4532
	self.hp = self.hp - 1 -- 4533
	self:emit("actorHit", { -- 4534
		target = "player", -- 4534
		amount = 1, -- 4534
		hp = self.hp, -- 4534
		maxHp = self.maxHp, -- 4534
		enemyX = e.x -- 4534
	}) -- 4534
	self:flashSet( -- 4535
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4535
		0.7 -- 4535
	) -- 4535
	e.fireCd = FIRE_COOLDOWN -- 4536
	if self.hp <= 0 then -- 4536
		self:gateFailed() -- 4538
	end -- 4538
end -- 4500
function Play.prototype.blockedByCover(self, enemy, p) -- 4543
	local b = self:coverAt(p) -- 4544
	if b == nil then -- 4544
		return nil -- 4546
	end -- 4546
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4548
end -- 4543
function Play.prototype.gateFailed(self) -- 4552
	local ____temp_134 -- 4553
	if self.room.story == nil then -- 4553
		____temp_134 = nil -- 4553
	else -- 4553
		____temp_134 = self.room.story.gate -- 4553
	end -- 4553
	local g = ____temp_134 -- 4553
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 4554
	self.hp = self.maxHp -- 4555
	self.gateTick = 0 -- 4556
	self.gateSpawned = 0 -- 4557
	self.enemies = {} -- 4558
	self.gateFailCount = self.gateFailCount + 1 -- 4559
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 4561
	self.player.y = 0 -- 4562
	self.player.vy = 0 -- 4563
	self.player.depth = 0 -- 4564
	self.player.depthSpeed = 0 -- 4565
	self.player.onGround = true -- 4566
	self.player.crouch = false -- 4567
	self.player.h = SOLDIER_H -- 4568
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 4569
	self.partner.y = 0 -- 4570
	self.partner.vy = 0 -- 4571
	self.partner.depth = 0 -- 4572
	self.partner.depthSpeed = 0 -- 4573
	self.partner.onGround = true -- 4574
	self.cam.x = self.player.x -- 4575
	self.phase = "gate-idle" -- 4576
	self.phaseTick = 0 -- 4577
	self.coverHug = false -- 4578
	self.coverBlocking = false -- 4579
	self.coverEntity = "" -- 4580
	self.gateNeedConfirm = true -- 4581
	self.gateRestartArmed = false -- 4582
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 4583
end -- 4552
function Play.prototype.stepRedCart(self, input) -- 4587
	if self.redCartMemoryT > 0 then -- 4587
		self.redCartMemoryT = self.redCartMemoryT - 1 -- 4589
	end -- 4589
	if self.room.key ~= "outside" or self.redCartPulled then -- 4589
		return -- 4592
	end -- 4592
	local box = __TS__ArrayFind( -- 4594
		self.boxes, -- 4594
		function(____, b) return b.id == "outside_red_cart" end -- 4594
	) -- 4594
	if box == nil then -- 4594
		self.redCartPulled = true -- 4596
		return -- 4597
	end -- 4597
	local cx = (box.x0 + box.x1) * 0.5 -- 4599
	local p = self.player -- 4600
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 4600
		return -- 4602
	end -- 4602
	if not input.interact.pressed then -- 4602
		return -- 4605
	end -- 4605
	box.x0 = 430 -- 4607
	box.x1 = 474 -- 4608
	self.cartAxle = self.room.cart.endX -- 4610
	self.cartDocked = true -- 4611
	self.redCartPulled = true -- 4612
	self.redCartMemoryT = 30 -- 4613
	if self.run.story ~= nil then -- 4613
		self.run.story.segments.outside_cart = true -- 4615
		self.run.story.segments.outside_memory = true -- 4616
	end -- 4616
	self.sessionDirty = true -- 4618
	self:flashSet("红布补丁 · 想起家里那一针 · 石阶口露出来", 1.8) -- 4619
	self:emit("storyBeat", {beat = "red_cart", x = p.x, room = "outside"}) -- 4620
	self:emit("storyBeat", {beat = "red_cart_memory", x = p.x, room = "outside", durationTicks = 30}) -- 4621
end -- 4587
function Play.prototype.stepInteract(self, dt, input) -- 4624
	local p = self.player -- 4625
	self:stepRedCart(input) -- 4626
	local calmUsed = self.calmConsumed -- 4627
	self.calmConsumed = false -- 4628
	local calming = self.escort.state == "calming" -- 4630
	self.focusCart = false -- 4631
	if self.room.key == "outside" then -- 4631
		local c = self.room.cart -- 4633
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 4634
		local dy = p.y - c.baseY -- 4635
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 4636
	end -- 4636
	if not calmUsed and not calming then -- 4636
		self:stepCart(dt, input) -- 4640
	end -- 4640
	if calmUsed then -- 4640
		self:flashSet("安抚 · 敲两下", 0.8) -- 4645
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4645
		if self.knockT > 0 then -- 4645
			self.knocks = self.knocks + 1 -- 4649
		else -- 4649
			self.knocks = 1 -- 4651
		end -- 4651
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4653
		self.knockT = 1.2 -- 4654
		if self.knocks >= 2 then -- 4654
			self:flashSet("敲两下", 0.8) -- 4656
			self.knocks = 0 -- 4657
		else -- 4657
			self:flashSet("敲一下", 0.5) -- 4659
		end -- 4659
	elseif self.knockT > 0 then -- 4659
		self.knockT = self.knockT - dt -- 4662
		if self.knockT <= 0 then -- 4662
			self.knocks = 0 -- 4664
		end -- 4664
	end -- 4664
	local i = 0 -- 4669
	do -- 4669
		i = 0 -- 4670
		while i < #self.room.marks do -- 4670
			do -- 4670
				local m = self.room.marks[i + 1] -- 4671
				if m.kind ~= 0 then -- 4671
					goto __continue776 -- 4673
				end -- 4673
				local subjects = {self.partner, self.player} -- 4675
				local k = 0 -- 4676
				do -- 4676
					k = 0 -- 4677
					while k < #subjects do -- 4677
						do -- 4677
							local s = subjects[k + 1] -- 4678
							if not s.alive then -- 4678
								goto __continue779 -- 4680
							end -- 4680
							local dx = s.x - m.x -- 4682
							local dy = s.y - m.y -- 4683
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4683
								self.checkpoint = m.x -- 4685
								self.checkpointCartAxle = self.cartAxle -- 4686
								if self.isCampaign then -- 4686
									self:captureCheckpoint(m.x) -- 4689
								end -- 4689
								if self.room.cart.bodyW > 0 then -- 4689
									if self.cartDocked then -- 4689
										self:flashSet("检查点 · 车已落窝", 1) -- 4693
									else -- 4693
										self:flashSet("检查点 · 车还没到位", 1) -- 4695
									end -- 4695
								else -- 4695
									self:flashSet("检查点", 1) -- 4698
								end -- 4698
							end -- 4698
						end -- 4698
						::__continue779:: -- 4698
						k = k + 1 -- 4677
					end -- 4677
				end -- 4677
			end -- 4677
			::__continue776:: -- 4677
			i = i + 1 -- 4670
		end -- 4670
	end -- 4670
	self:checkCarryGate() -- 4704
end -- 4624
function Play.prototype.stepVillage(self, dt, input) -- 4708
	if self.room.key ~= "village" then -- 4708
		return -- 4710
	end -- 4710
	local p = self.player -- 4712
	local bottle = self.room.bottle -- 4713
	local scav = self.room.scavenger -- 4714
	if not self.hasBottle and bottle ~= nil then -- 4714
		local dx = p.x - bottle.x -- 4718
		local dy = p.y + p.h * 0.5 - bottle.y -- 4719
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4719
			self.hasBottle = true -- 4721
			self:flashSet("拾起瓶子", 0.8) -- 4722
		end -- 4722
	end -- 4722
	if self.hasBottle then -- 4722
		if input.bottleCanceled then -- 4722
			self.aimHold = 0 -- 4729
			self.bottleAimX = -1 -- 4730
		elseif input.aim.held then -- 4730
			self.aimHold = self.aimHold + dt -- 4732
			if self.aimHold > 1.2 then -- 4732
				self.aimHold = 1.2 -- 4734
			end -- 4734
			local cached = self:bottleEnd() -- 4737
			self.bottleAimX = cached.x -- 4738
			self.bottleAimY = cached.y -- 4739
		elseif input.aim.released then -- 4739
			if self.aimHold < 0.12 then -- 4739
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 4743
				self.aimHold = 0 -- 4744
			else -- 4744
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4746
				self:throwBottle(____end.x, ____end.y) -- 4747
				self.aimHold = 0 -- 4748
			end -- 4748
		end -- 4748
	else -- 4748
		self.aimHold = 0 -- 4752
		self.bottleAimX = -1 -- 4753
	end -- 4753
	local fly = self.bottleFly -- 4758
	if fly ~= nil then -- 4758
		fly.t = fly.t + dt -- 4760
		fly.x = fly.x0 + fly.vx * fly.t -- 4761
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4762
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4763
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4763
			self:landBottle(fly) -- 4765
		end -- 4765
	end -- 4765
	if self.bottleLandT > 0 then -- 4765
		self.bottleLandT = self.bottleLandT - dt -- 4769
	end -- 4769
	if scav ~= nil then -- 4769
		self:stepScav(dt, scav) -- 4773
	end -- 4773
	local line = self.room.passLine -- 4776
	if line ~= nil and not self.passed and p.x >= line then -- 4776
		self.passed = true -- 4778
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4779
	end -- 4779
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4782
	if underTable then -- 4782
		self.footHintT = self.footHintT - 1 -- 4784
		if self.footHintT <= 0 then -- 4784
			self.footHintT = 90 -- 4786
			local scavX = self.scavX -- 4787
			local near = math.abs(scavX - p.x) < 120 -- 4788
			local walkingAway = self.scavState == "walk" and math.abs(self.scavTargetX - p.x) >= 120 -- 4789
			local heard = self.scavState == "chase" or near and not walkingAway -- 4790
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4791
			self:emit("storyBeat", {beat = heard and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4792
		end -- 4792
	else -- 4792
		self.footHintT = 0 -- 4795
	end -- 4795
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4795
		self.ditchHinted = true -- 4799
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4800
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4801
	end -- 4801
	local inCulvert = p.x >= self.ox + 560 and p.x <= self.ox + 640 -- 4804
	if self.passed and inCulvert and p.crouch and self.wantRoom == "" then -- 4804
		self:requestRoom("forest", "蹲下钻过暗渠") -- 4806
		self:flashSet("钻进暗渠 · 北塔森林", 1.4) -- 4807
	end -- 4807
end -- 4708
function Play.prototype.bottleEnd(self) -- 4812
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4813
	local clampedX = math.max( -- 4816
		self.room.minX + 12, -- 4816
		math.min(self.room.maxX - 12, aim.x) -- 4816
	) -- 4816
	local g = self:groundAt(clampedX, aim.y + 240, 3) -- 4817
	return {x = clampedX, y = g} -- 4818
end -- 4812
function Play.prototype.throwBottle(self, tx, ty) -- 4822
	local p = self.player -- 4823
	local dir = tx >= p.x and 1 or -1 -- 4825
	p.facing = dir -- 4826
	local x0 = p.x + dir * 10 -- 4827
	local y0 = p.y + p.h * 0.7 -- 4828
	self.bottleTargetX = tx -- 4829
	self.bottleTargetY = ty -- 4830
	self.bottleSurfaceY = ty -- 4831
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4832
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4833
	self.bottleFly = { -- 4834
		x = x0, -- 4834
		y = y0, -- 4834
		x0 = x0, -- 4834
		y0 = y0, -- 4834
		vx = vx, -- 4834
		vy = vy, -- 4834
		t = 0 -- 4834
	} -- 4834
	self.hasBottle = false -- 4835
	self:flashSet("投出", 0.4) -- 4836
	self:emit( -- 4837
		"bottleThrown", -- 4837
		{ -- 4837
			fromX = x0, -- 4838
			fromY = y0, -- 4839
			targetX = tx, -- 4840
			targetY = ty, -- 4841
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4842
		} -- 4842
	) -- 4842
end -- 4822
function Play.prototype.bottleSurfaceAt(self, x) -- 4847
	if self.room.softX ~= nil and math.abs(x - self.room.softX) <= 34 then -- 4847
		return "soft" -- 4849
	end -- 4849
	if self.room.basinX ~= nil and math.abs(x - self.room.basinX) <= 24 then -- 4849
		return "iron" -- 4852
	end -- 4852
	return "brick" -- 4854
end -- 4847
function Play.prototype.landBottle(self, fly) -- 4858
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4859
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4860
	local s = self.room.scavenger -- 4861
	local surface = self:bottleSurfaceAt(x) -- 4862
	local effRange = s == nil and 0 or (surface == "iron" and s.range * 1.25 or s.range) -- 4863
	local heard = surface ~= "soft" and s ~= nil and math.abs(x - self.scavX) <= effRange -- 4864
	local stallTicks = s == nil and 0 or (surface == "iron" and s.stallTicks + 90 or s.stallTicks) -- 4865
	self.bottleFly = nil -- 4866
	self.bottleTargetX = -1 -- 4867
	self.bottleTargetY = 0 -- 4868
	self.bottleSurfaceY = -1 -- 4869
	self.bottleLandX = x -- 4870
	self.bottleLandY = y -- 4871
	self.bottleLandT = 0.9 -- 4872
	self:emit("bottleLanded", { -- 4873
		x = x, -- 4874
		y = y, -- 4875
		surface = surface, -- 4876
		heard = heard, -- 4877
		resonance = surface == "iron", -- 4878
		stallTicks = heard and stallTicks or 0, -- 4879
		scavState = self.scavState -- 4880
	}) -- 4880
	self:hearBottle(x, surface) -- 4882
end -- 4858
function Play.prototype.hearBottle(self, x, surface) -- 4886
	if surface == nil then -- 4886
		surface = "brick" -- 4886
	end -- 4886
	local s = self.room.scavenger -- 4887
	if s == nil then -- 4887
		return -- 4889
	end -- 4889
	if surface == "soft" then -- 4889
		self:flashSet("落在软土 · 没出声", 0.8) -- 4892
		return -- 4893
	end -- 4893
	local effRange = surface == "iron" and s.range * 1.25 or s.range -- 4895
	if math.abs(x - self.scavX) > effRange then -- 4895
		self:flashSet("落地 · 他没听见", 0.6) -- 4897
		return -- 4898
	end -- 4898
	self.scavState = "turn" -- 4900
	self.scavT = s.hearTicks -- 4901
	self.scavTargetX = surface == "iron" and self.room.basinX ~= nil and self.room.basinX or x -- 4902
	self.scavStallBonus = surface == "iron" and 90 or 0 -- 4903
	self:flashSet(surface == "iron" and "铁盆余振两响 · 他停下来细听" or "砖地一响 · 他转头", 1.1) -- 4904
end -- 4886
function Play.prototype.stepScav(self, dt, s) -- 4908
	if self.scavState == "chase" then -- 4908
		return -- 4911
	end -- 4911
	if self.scavState == "turn" then -- 4911
		self.scavT = self.scavT - 1 -- 4914
		if self.scavT <= 0 then -- 4914
			self.scavState = "walk" -- 4916
		end -- 4916
		return -- 4918
	end -- 4918
	if self.scavState == "walk" then -- 4918
		local d = self.scavTargetX - self.scavX -- 4921
		if math.abs(d) < 4 then -- 4921
			self.scavState = "stall" -- 4923
			self.scavT = s.stallTicks + self.scavStallBonus -- 4924
			self.scavStallBonus = 0 -- 4925
			return -- 4926
		end -- 4926
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4928
		return -- 4929
	end -- 4929
	if self.scavState == "stall" then -- 4929
		self.scavT = self.scavT - 1 -- 4932
		if self.scavT <= 0 then -- 4932
			self.scavState = "back" -- 4934
		end -- 4934
		return -- 4936
	end -- 4936
	if self.scavState == "back" then -- 4936
		local home = math.max( -- 4939
			s.x0, -- 4939
			math.min(s.x1, self.scavX) -- 4939
		) -- 4939
		if math.abs(home - self.scavX) < 2 then -- 4939
			self.scavState = "patrol" -- 4941
			return -- 4942
		end -- 4942
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4944
		return -- 4945
	end -- 4945
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4947
	if self.scavX >= s.x1 then -- 4947
		self.scavX = s.x1 -- 4949
		self.scavDir = -1 -- 4950
	elseif self.scavX <= s.x0 then -- 4950
		self.scavX = s.x0 -- 4952
		self.scavDir = 1 -- 4953
	end -- 4953
end -- 4908
function Play.prototype.stepCart(self, dt, input) -- 4961
	local p = self.player -- 4962
	local c = self.room.cart -- 4963
	if self.gripping then -- 4963
		if not input.interact.held then -- 4963
			self.gripping = false -- 4967
			self:flashSet("松开车把", 0.4) -- 4968
			return -- 4969
		end -- 4969
	else -- 4969
		if not input.interact.pressed then -- 4969
			return -- 4973
		end -- 4973
		if not self:cartHandleInReach(p) then -- 4973
			return -- 4976
		end -- 4976
		local track = c.depth or 0 -- 4978
		if self:limitDepth(p, track) ~= track then -- 4978
			return -- 4980
		end -- 4980
		p.depth = track -- 4982
		p.depthSpeed = 0 -- 4983
		self.gripping = true -- 4984
		self:flashSet("握住车把", 0.4) -- 4985
		return -- 4986
	end -- 4986
	if self.cartDocked then -- 4986
		return -- 4990
	end -- 4990
	local dir = input.moveX -- 4992
	if dir == 0 then -- 4992
		return -- 4994
	end -- 4994
	local lo = math.min(c.startX, c.endX) -- 4996
	local hi = math.max(c.startX, c.endX) -- 4997
	local next = self.cartAxle + dir * CART_SPEED * dt -- 4998
	if next < lo then -- 4998
		next = lo -- 5000
	end -- 5000
	if next > hi then -- 5000
		next = hi -- 5003
	end -- 5003
	local delta = next - self.cartAxle -- 5005
	if delta == 0 then -- 5005
		return -- 5007
	end -- 5007
	self.cartAxle = next -- 5009
	p.x = p.x + delta -- 5010
	p.facing = dir > 0 and 1 or -1 -- 5011
	self:slideX(p, 0) -- 5012
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 5012
		self.gripping = false -- 5014
		self:flashSet("跟不上了，脱手", 0.6) -- 5015
		return -- 5016
	end -- 5016
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 5016
		self.cartDocked = true -- 5019
		self.gripping = false -- 5020
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 5021
		self:flashSet("车轮落窝", 1.2) -- 5022
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 5022
		self:flashSet("车轮回到起点", 0.5) -- 5024
	end -- 5024
end -- 4961
function Play.prototype.requestRoom(self, key, reason) -- 5032
	if self.wantRoom ~= "" then -- 5032
		return -- 5036
	end -- 5036
	self.wantRoom = key -- 5038
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 5039
end -- 5032
function Play.prototype.checkCarryGate(self) -- 5046
	if self.room.key == "checkpoint" then -- 5046
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 5046
			self.carryCartAxle = self.cartAxle -- 5049
			self.carryCartDocked = self.cartDocked -- 5050
			self:requestRoom("gate", "检查站出口") -- 5051
			self:flashSet("出检查站 · 城门", 1.2) -- 5052
		end -- 5052
		return -- 5054
	end -- 5054
	if self.room.key == "outside" then -- 5054
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 5054
			self.carryCartAxle = self.cartAxle -- 5060
			self.carryCartDocked = self.cartDocked -- 5061
			self:requestRoom("village", "墙根走完") -- 5062
			self:flashSet("墙根走完 · 进村口", 1.2) -- 5063
		end -- 5063
	end -- 5063
end -- 5046
function Play.prototype.aimAt(self, wx, wy) -- 5070
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 5071
	self.aimX = s.x -- 5072
	self.aimY = s.y -- 5073
end -- 5070
function Play.prototype.shoot(self, a) -- 5076
	if self.isCampaign and self.reloadT > 0 then -- 5076
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 5078
		return -- 5079
	end -- 5079
	local ox = a.x + a.facing * 8 -- 5081
	local muzzleY = a.y + a.h * 0.72 -- 5082
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 5083
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 5085
	local dx = aim.x - ox -- 5088
	local dy = aim.y - oy -- 5089
	local len = math.sqrt(dx * dx + dy * dy) -- 5090
	if len < 0.001 then -- 5090
		dx = a.facing -- 5092
		dy = 0 -- 5093
	else -- 5093
		dx = dx / len -- 5095
		dy = dy / len -- 5096
	end -- 5096
	if dx ~= 0 then -- 5096
		a.facing = dx > 0 and 1 or -1 -- 5099
	end -- 5099
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 5102
	local hitEnemy = self:raycastEnemies(ray) -- 5103
	local tEnemy = hitEnemy.t -- 5104
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 5105
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 5106
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 5107
	local tWall = solid.t -- 5108
	local rawEffect = self:consumeReloadEffect() -- 5110
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 5111
	local reloadEffect = rawEffect -- 5112
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 5114
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 5115
	self.trace = { -- 5117
		x0 = ox, -- 5117
		y0 = oy, -- 5117
		x1 = ox + dx * t, -- 5117
		y1 = oy + dy * t, -- 5117
		hit = hit -- 5117
	} -- 5117
	self.traceT = 0.12 -- 5118
	self:applyFireDanger(ox) -- 5119
	local killed = false -- 5120
	if hit then -- 5120
		local i = hitEnemy.index -- 5122
		local e = self.enemies[i + 1] -- 5123
		local impactY = oy + dy * tEnemy -- 5124
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 5125
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 5126
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 5126
			local pushRank = self:talentRank("push_force") -- 5128
			local dmg = reloadEffect == "push" and 2 + pushRank or 1 -- 5129
			e.shieldHp = math.max(0, (e.shieldHp or 0) - dmg) -- 5130
			e.hitT = 0.3 -- 5131
			if reloadEffect == "push" then -- 5131
				local kb = 46 + 24 * pushRank -- 5133
				e.x = math.max( -- 5134
					self.room.minX + 20, -- 5134
					math.min(self.room.maxX - 20, e.x + a.facing * kb) -- 5134
				) -- 5134
				if pushRank > 0 then -- 5134
					self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5136
				end -- 5136
				self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5138
				self:flashSet(e.shieldHp <= 0 and "推退破盾！" or "推退震退持盾手", 0.9) -- 5139
			else -- 5139
				self:flashSet( -- 5141
					(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 5141
					0.8 -- 5141
				) -- 5141
			end -- 5141
			self:emit("shotResolved", { -- 5143
				hit = true, -- 5144
				enemyIndex = i, -- 5144
				enemyX = e.x, -- 5144
				aimX = aim.x, -- 5144
				aimY = aim.y, -- 5144
				impactX = ox + dx * t, -- 5145
				impactY = oy + dy * t, -- 5145
				shield = true -- 5145
			}) -- 5145
			self:beginReload() -- 5147
			return -- 5148
		end -- 5148
		e.alive = false -- 5150
		e.hitT = 0.4 -- 5151
		killed = true -- 5152
		self:flashSet("命中", 0.6) -- 5153
		self:dropFor(e) -- 5154
		local lpRank = self:talentRank("lantern_pierce") -- 5155
		if reloadEffect == "light" and (weaponFx == "light" or lpRank > 0) then -- 5155
			local blindRadius = (weaponFx == "light" and 160 or 110) + 50 * lpRank -- 5157
			self:blindNearby(e, blindRadius, i) -- 5158
		end -- 5158
		if reloadEffect == "push" then -- 5158
			local pushRank = self:talentRank("push_force") -- 5161
			e.x = e.x + a.facing * (46 + 24 * pushRank) -- 5162
			if pushRank > 0 then -- 5162
				self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5164
			end -- 5164
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5166
		elseif reloadEffect == "echo" then -- 5166
			local echoRank = self:talentRank("echo_wide") -- 5168
			self:echoToSource(a, (weaponFx == "echo" and 2 or 1) + echoRank, 60 + 30 * echoRank) -- 5169
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 5170
		elseif reloadEffect == "light" then -- 5170
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 5172
		end -- 5172
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 5172
		self:damageProp(solid.box, 1) -- 5175
	else -- 5175
		self:flashSet("打空", 0.35) -- 5177
	end -- 5177
	if self.isCampaign then -- 5177
		self:beginReload() -- 5180
	end -- 5180
	self:emit("shotResolved", { -- 5182
		hit = hit, -- 5183
		enemyIndex = hit and hitEnemy.index or -1, -- 5184
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 5185
		aimX = aim.x, -- 5186
		aimY = aim.y, -- 5187
		impactX = ox + dx * t, -- 5188
		impactY = oy + dy * t -- 5189
	}) -- 5189
end -- 5076
function Play.prototype.staggerNearby(self, center, radius, delayTicks, skipIndex) -- 5194
	local i = 0 -- 5195
	do -- 5195
		i = 0 -- 5196
		while i < #self.enemies do -- 5196
			do -- 5196
				if i == skipIndex then -- 5196
					goto __continue874 -- 5198
				end -- 5198
				local e = self.enemies[i + 1] -- 5200
				if not e.alive or math.abs(e.x - center.x) > radius then -- 5200
					goto __continue874 -- 5202
				end -- 5202
				e.warnT = 0 -- 5204
				e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 5205
				local pushDir = e.x >= center.x and 1 or -1 -- 5206
				e.x = math.max( -- 5207
					self.room.minX + 20, -- 5207
					math.min(self.room.maxX - 20, e.x + pushDir * 22) -- 5207
				) -- 5207
			end -- 5207
			::__continue874:: -- 5207
			i = i + 1 -- 5196
		end -- 5196
	end -- 5196
end -- 5194
function Play.prototype.applyFireDanger(self, shotX) -- 5212
	local ____temp_140 = self.isCampaign and self.run.joined -- 5213
	if ____temp_140 then -- 5213
		local ____opt_135 = self.room.campaign -- 5213
		local ____temp_139 = (____opt_135 and ____opt_135.chapter) == "S" -- 5214
		if not ____temp_139 then -- 5214
			local ____opt_137 = self.room.campaign -- 5214
			____temp_139 = (____opt_137 and ____opt_137.chapter) == "C" -- 5214
		end -- 5214
		____temp_140 = ____temp_139 -- 5213
	end -- 5213
	local isStorySc = ____temp_140 -- 5213
	if self.room.key ~= "checkpoint" and not isStorySc or not self.partner.alive then -- 5213
		return -- 5216
	end -- 5216
	local dangerX = shotX -- 5218
	local best = -1 -- 5219
	local bestD = 1000000000 -- 5220
	local i = 0 -- 5221
	do -- 5221
		i = 0 -- 5222
		while i < #self.enemies do -- 5222
			do -- 5222
				local e = self.enemies[i + 1] -- 5223
				if not e.alive then -- 5223
					goto __continue880 -- 5225
				end -- 5225
				local d = math.abs(e.x - self.partner.x) -- 5227
				if d < bestD then -- 5227
					bestD = d -- 5229
					best = i -- 5230
				end -- 5230
			end -- 5230
			::__continue880:: -- 5230
			i = i + 1 -- 5222
		end -- 5222
	end -- 5222
	if best >= 0 then -- 5222
		dangerX = self.enemies[best + 1].x -- 5234
	end -- 5234
	if isStorySc and math.abs(dangerX - self.partner.x) > 260 then -- 5234
		return -- 5238
	end -- 5238
	local exposed = self:childExposed(dangerX) -- 5240
	local before = self.escort.fear -- 5241
	local dangerId = self.nextDangerId -- 5242
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 5243
	self.nextDangerId = self.nextDangerId + 1 -- 5244
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 5245
	if after > before then -- 5245
		self:flashSet( -- 5247
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 5247
			1 -- 5247
		) -- 5247
	elseif not exposed then -- 5247
		self:flashSet("枪声没够到她", 0.5) -- 5249
	end -- 5249
end -- 5212
function Play.prototype.childExposed(self, dangerX) -- 5254
	local c = self.partner -- 5255
	if not c.alive then -- 5255
		return false -- 5257
	end -- 5257
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 5257
		self.boxes, -- 5260
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 5260
	) then -- 5260
		return false -- 5261
	end -- 5261
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 5261
		return false -- 5264
	end -- 5264
	local toDanger = dangerX - c.x -- 5266
	local toPlayer = self.player.x - c.x -- 5267
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 5267
		return false -- 5270
	end -- 5270
	return true -- 5272
end -- 5254
function Play.prototype.raycastEnemies(self, ray) -- 5276
	local best = -1 -- 5277
	local bestI = -1 -- 5278
	do -- 5278
		local i = 0 -- 5279
		while i < #self.enemies do -- 5279
			do -- 5279
				local e = self.enemies[i + 1] -- 5280
				if not e.alive then -- 5280
					goto __continue895 -- 5282
				end -- 5282
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 5284
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 5285
				if t >= 0 and (best < 0 or t < best) then -- 5285
					best = t -- 5287
					bestI = i -- 5288
				end -- 5288
			end -- 5288
			::__continue895:: -- 5288
			i = i + 1 -- 5279
		end -- 5279
	end -- 5279
	return {t = best, index = bestI} -- 5291
end -- 5276
function Play.prototype.raycastWorld(self, ray) -- 5294
	return self:raycastSolid(ray).t -- 5295
end -- 5294
function Play.prototype.raycastSolid(self, ray) -- 5299
	local best = -1 -- 5300
	local bestBox = nil -- 5301
	for ____, box in ipairs(self.boxes) do -- 5302
		do -- 5302
			if box.broken == true or box.hidden == true then -- 5302
				goto __continue900 -- 5304
			end -- 5304
			local t = hitBox(ray, box) -- 5309
			if t > 2 and (best < 0 or t < best) then -- 5309
				best = t -- 5312
				bestBox = box -- 5313
			end -- 5313
		end -- 5313
		::__continue900:: -- 5313
	end -- 5313
	if ray.dy < 0 then -- 5313
		local t = -ray.y / ray.dy -- 5317
		if t >= 0 and (best < 0 or t < best) then -- 5317
			best = t -- 5319
			bestBox = nil -- 5320
		end -- 5320
	end -- 5320
	return {t = best, box = bestBox} -- 5323
end -- 5299
function Play.prototype.dropFor(self, e) -- 5327
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 5327
		return -- 5329
	end -- 5329
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 5329
		return -- 5332
	end -- 5332
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 5334
	local ____self_pickups_141 = self.pickups -- 5334
	____self_pickups_141[#____self_pickups_141 + 1] = { -- 5335
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 5336
		kind = e.drop, -- 5336
		x = e.x, -- 5336
		y = e.y, -- 5336
		depth = e.depth, -- 5337
		label = label .. " ×1" -- 5337
	} -- 5337
	self:log("掉落 " .. label) -- 5339
end -- 5327
function Play.prototype.damageProp(self, b, amount) -- 5343
	if b.breakable == nil or b.broken == true then -- 5343
		return -- 5345
	end -- 5345
	local ____b_breakable_142, ____hp_143 = b.breakable, "hp" -- 5345
	____b_breakable_142[____hp_143] = ____b_breakable_142[____hp_143] - amount -- 5347
	if b.breakable.hp > 0 then -- 5347
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 5349
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 5350
		return -- 5351
	end -- 5351
	b.broken = true -- 5353
	for ____, other in ipairs(self.boxes) do -- 5354
		if other.id ~= nil and other.id == b.id then -- 5354
			other.broken = true -- 5356
		end -- 5356
	end -- 5356
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 5359
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 5360
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 5361
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 5362
end -- 5343
function Play.prototype.slideDepth(self, a, distance) -- 5366
	a.depth = self:limitDepth(a, a.depth + distance) -- 5367
end -- 5366
function Play.prototype.limitDepth(self, a, target) -- 5370
	local road = self.room.depth -- 5371
	if road == nil or target == a.depth then -- 5371
		return a.depth -- 5373
	end -- 5373
	local next = math.max( -- 5375
		road.min, -- 5375
		math.min(road.max, target) -- 5375
	) -- 5375
	local half = a.w / 2 -- 5376
	for ____, b in ipairs(self.boxes) do -- 5377
		do -- 5377
			local footprint = b.depth -- 5378
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5378
				goto __continue918 -- 5383
			end -- 5383
			local front = footprint.min - ACTOR_DEPTH_HALF -- 5385
			local back = footprint.max + ACTOR_DEPTH_HALF -- 5386
			if a.depth <= front and next > front then -- 5386
				next = front -- 5388
			elseif a.depth >= back and next < back then -- 5388
				next = back -- 5390
			end -- 5390
		end -- 5390
		::__continue918:: -- 5390
	end -- 5390
	return next -- 5393
end -- 5370
function Play.prototype.cartLatchBounds(self) -- 5397
	if self.room.key ~= "outside" or self.cartDocked then -- 5397
		return nil -- 5398
	end -- 5398
	local arch = self.room.arch -- 5399
	local halfWidth = self.room.cart.bodyW / 2 -- 5400
	local left = math.max(arch.x0, self.cartAxle - halfWidth) -- 5401
	local right = math.min(arch.x1, self.cartAxle + halfWidth) -- 5402
	return right > left and Rect(left, arch.y, right - left, arch.h) or nil -- 5403
end -- 5397
function Play.prototype.slideX(self, a, dx) -- 5407
	local nx = a.x + dx -- 5408
	local half = a.w / 2 -- 5409
	local room = self.room -- 5410
	nx = math.max( -- 5411
		room.minX + half, -- 5411
		math.min(room.maxX - half, nx) -- 5411
	) -- 5411
	local i = 0 -- 5412
	do -- 5412
		i = 0 -- 5413
		while i < #self.boxes do -- 5413
			do -- 5413
				local b = self.boxes[i + 1] -- 5414
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5414
					goto __continue927 -- 5416
				end -- 5416
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5416
					goto __continue927 -- 5419
				end -- 5419
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5419
					goto __continue927 -- 5422
				end -- 5422
				if nx + half > b.x0 and nx - half < b.x1 then -- 5422
					if a.x <= b.x0 then -- 5422
						nx = b.x0 - half -- 5426
					elseif a.x >= b.x1 then -- 5426
						nx = b.x1 + half -- 5428
					else -- 5428
						nx = a.x -- 5430
					end -- 5430
				end -- 5430
			end -- 5430
			::__continue927:: -- 5430
			i = i + 1 -- 5413
		end -- 5413
	end -- 5413
	local latch = self:cartLatchBounds() -- 5434
	if latch ~= nil and a.y < latch.y + latch.height - 0.001 and nx + half > latch.x and nx - half < latch.x + latch.width then -- 5434
		if a.x <= latch.x then -- 5434
			nx = latch.x - half -- 5438
		elseif a.x >= latch.x + latch.width then -- 5438
			nx = latch.x + latch.width + half -- 5440
		else -- 5440
			nx = a.x -- 5442
		end -- 5442
	end -- 5442
	local arch = room.arch -- 5449
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 5449
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 5451
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 5451
			if a.x <= arch.x0 then -- 5451
				nx = arch.x0 - half -- 5454
			elseif a.x >= arch.x1 then -- 5454
				nx = arch.x1 + half -- 5456
			end -- 5456
		end -- 5456
	end -- 5456
	a.x = nx -- 5460
end -- 5407
function Play.prototype.fallY(self, a, dt) -- 5464
	a.vy = a.vy - ____exports.GRAVITY * dt -- 5465
	if a.vy < -900 then -- 5465
		a.vy = -900 -- 5467
	end -- 5467
	local ny = a.y + a.vy * dt -- 5469
	local half = a.w / 2 -- 5470
	if a.vy <= 0 then -- 5470
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 5473
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 5474
		if ny <= ground then -- 5474
			ny = ground -- 5476
			a.vy = 0 -- 5477
			a.onGround = true -- 5478
		else -- 5478
			a.onGround = false -- 5480
		end -- 5480
	else -- 5480
		a.onGround = false -- 5483
		local i = 0 -- 5484
		do -- 5484
			i = 0 -- 5485
			while i < #self.boxes do -- 5485
				do -- 5485
					local b = self.boxes[i + 1] -- 5486
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5486
						goto __continue950 -- 5488
					end -- 5488
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5488
						goto __continue950 -- 5491
					end -- 5491
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 5491
						goto __continue950 -- 5494
					end -- 5494
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 5494
						ny = b.y0 - a.h -- 5497
						a.vy = 0 -- 5498
					end -- 5498
				end -- 5498
				::__continue950:: -- 5498
				i = i + 1 -- 5485
			end -- 5485
		end -- 5485
	end -- 5485
	a.y = ny -- 5502
end -- 5464
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 5506
	if depth == nil then -- 5506
		depth = 0 -- 5506
	end -- 5506
	local g = -9999 -- 5507
	local i = 0 -- 5508
	do -- 5508
		i = 0 -- 5509
		while i < #self.floors do -- 5509
			local f = self.floors[i + 1] -- 5510
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 5510
				g = f.y1 -- 5512
			end -- 5512
			i = i + 1 -- 5509
		end -- 5509
	end -- 5509
	do -- 5509
		i = 0 -- 5515
		while i < #self.boxes do -- 5515
			do -- 5515
				local b = self.boxes[i + 1] -- 5516
				if b.broken == true or b.hidden == true or b.soft == true then -- 5516
					goto __continue960 -- 5518
				end -- 5518
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 5518
					g = b.y1 -- 5522
				end -- 5522
			end -- 5522
			::__continue960:: -- 5522
			i = i + 1 -- 5515
		end -- 5515
	end -- 5515
	return g -- 5525
end -- 5506
function Play.prototype.updateCamera(self, dt) -- 5528
	local p = self.player -- 5529
	local tx = p.x + p.facing * 30 -- 5530
	local ty = p.y + CAM_LOOK_UP -- 5531
	local k = math.min(1, CAM_FOLLOW * dt) -- 5532
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 5533
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 5534
end -- 5528
function Play.prototype.clampCamera(self, w, h) -- 5538
	local room = self.room -- 5539
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 5540
	local spanX = room.maxX - room.minX -- 5541
	if spanX <= halfW * 2 then -- 5541
		self.cam.x = (room.minX + room.maxX) / 2 -- 5543
	else -- 5543
		self.cam.x = math.max( -- 5545
			room.minX + halfW, -- 5545
			math.min(room.maxX - halfW, self.cam.x) -- 5545
		) -- 5545
	end -- 5545
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 5548
	local spanY = room.height -- 5549
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 5550
	if spanY <= halfH * 2 then -- 5550
		self.cam.y = camY -- 5552
	else -- 5552
		self.cam.y = math.max( -- 5554
			camY, -- 5554
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 5554
		) -- 5554
	end -- 5554
end -- 5538
function Play.prototype.flashSet(self, text, t) -- 5558
	self.flash = text -- 5559
	self.flashT = t -- 5560
end -- 5558
function Play.prototype.statusText(self) -- 5564
	local p = self.player -- 5565
	local parts = {} -- 5566
	local who = self.childMode and "小满" or "周戍" -- 5567
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 5568
	if self.room.key == "prologue" then -- 5568
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5571
		if self.phase == "prologue-wake" then -- 5571
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 5573
		elseif self.phase == "prologue-shadow" then -- 5573
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 5575
		elseif self.phase == "prologue-escape" then -- 5575
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 5577
		elseif self.phase == "prologue-hide" then -- 5577
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 5579
		elseif self.phase == "prologue-wait" then -- 5579
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 5581
		elseif self.phase == "prologue-give" then -- 5581
			parts[#parts + 1] = (("递物 " .. tostring(self.phaseTick)) .. "/") .. tostring(____exports.PROLOGUE_GIVE_TICKS) -- 5583
		else -- 5583
			parts[#parts + 1] = "跟随" -- 5585
		end -- 5585
		if self.paused then -- 5585
			parts[#parts + 1] = "已暂停" -- 5588
		end -- 5588
		return table.concat(parts, " · ") -- 5590
	end -- 5590
	if self.room.key == "street" then -- 5590
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5593
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5594
		if self.paused then -- 5594
			parts[#parts + 1] = "已暂停" -- 5596
		end -- 5596
		return table.concat(parts, " · ") -- 5598
	end -- 5598
	if self.room.key == "gate" then -- 5598
		local ____temp_144 -- 5601
		if self.room.story == nil then -- 5601
			____temp_144 = nil -- 5601
		else -- 5601
			____temp_144 = self.room.story.gate -- 5601
		end -- 5601
		local g = ____temp_144 -- 5601
		if g ~= nil then -- 5601
			parts[#parts + 1] = self:gateLabel() -- 5603
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 5604
				0, -- 5605
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 5605
			))) .. " 秒" -- 5605
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5606
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5607
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 5608
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 5609
			if self.gateFailCount > 0 then -- 5609
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 5611
			end -- 5611
			if self.flash ~= "" then -- 5611
				parts[#parts + 1] = self.flash -- 5614
			end -- 5614
		end -- 5614
		if self.paused then -- 5614
			parts[#parts + 1] = "已暂停" -- 5618
		end -- 5618
		return table.concat(parts, " · ") -- 5620
	end -- 5620
	if self.room.key == "forest" then -- 5620
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5623
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5624
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5625
		if self.caughtT > 0 then -- 5625
			parts[#parts + 1] = "复位中" -- 5627
		end -- 5627
		if self.paused then -- 5627
			parts[#parts + 1] = "已暂停" -- 5630
		end -- 5630
		return table.concat(parts, " · ") -- 5632
	end -- 5632
	if self.room.key == "tower" then -- 5632
		if self.phase == "tower-wait" then -- 5632
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5636
		elseif self.phase == "tower-knock" then -- 5636
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5638
		elseif self.phase == "tower-enter" then -- 5638
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5640
		elseif self.phase == "tower-desk" then -- 5640
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5642
		elseif self.phase == "tower-given" then -- 5642
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5644
		else -- 5644
			parts[#parts + 1] = "片尾" -- 5646
		end -- 5646
		if self.paused then -- 5646
			parts[#parts + 1] = "已暂停" -- 5649
		end -- 5649
		return table.concat(parts, " · ") -- 5651
	end -- 5651
	if self.room.key == "village" then -- 5651
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5654
		if self.hasBottle then -- 5654
			parts[#parts + 1] = "有瓶" -- 5656
		elseif self.bottleFly ~= nil then -- 5656
			parts[#parts + 1] = "瓶在飞" -- 5658
		else -- 5658
			parts[#parts + 1] = "空手" -- 5660
		end -- 5660
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5662
		if self.scavChase then -- 5662
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5664
		end -- 5664
		if self.passed then -- 5664
			parts[#parts + 1] = "已过通行线" -- 5667
		end -- 5667
		if self.paused then -- 5667
			parts[#parts + 1] = "已暂停" -- 5670
		end -- 5670
		return table.concat(parts, " · ") -- 5672
	end -- 5672
	local isChild = self.childMode -- 5675
	if isChild then -- 5675
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5677
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5678
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5679
	else -- 5679
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5681
		if p.rollT > 0 then -- 5681
			parts[#parts + 1] = "翻滚中" -- 5683
		end -- 5683
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5685
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5686
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5687
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5688
	end -- 5688
	if self.checkpoint >= 0 then -- 5688
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5691
	end -- 5691
	if self.paused then -- 5691
		parts[#parts + 1] = "已暂停" -- 5694
	end -- 5694
	return table.concat(parts, " · ") -- 5696
end -- 5564
function Play.prototype.aliveEnemies(self) -- 5700
	local n = 0 -- 5701
	local i = 0 -- 5702
	do -- 5702
		i = 0 -- 5703
		while i < #self.enemies do -- 5703
			if self.enemies[i + 1].alive then -- 5703
				n = n + 1 -- 5705
			end -- 5705
			i = i + 1 -- 5703
		end -- 5703
	end -- 5703
	return n -- 5708
end -- 5700
function Play.prototype.threatened(self) -- 5713
	do -- 5713
		local i = 0 -- 5714
		while i < #self.enemies do -- 5714
			local e = self.enemies[i + 1] -- 5715
			if e.alive and e.warnT > 0 then -- 5715
				return true -- 5717
			end -- 5717
			i = i + 1 -- 5714
		end -- 5714
	end -- 5714
	return false -- 5720
end -- 5713
function Play.prototype.gateSecondsLeft(self) -- 5723
	local ____temp_145 -- 5724
	if self.room.story == nil then -- 5724
		____temp_145 = nil -- 5724
	else -- 5724
		____temp_145 = self.room.story.gate -- 5724
	end -- 5724
	local g = ____temp_145 -- 5724
	if g == nil then -- 5724
		return 0 -- 5726
	end -- 5726
	return math.max( -- 5728
		0, -- 5728
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5728
	) -- 5728
end -- 5723
function Play.prototype.gateLabel(self) -- 5731
	if self.phase == "gate-idle" then -- 5731
		return "待就位" -- 5733
	end -- 5733
	if self.phase == "gate-hold" then -- 5733
		return "守点中" -- 5736
	end -- 5736
	if self.phase == "gate-send" then -- 5736
		return "送别" -- 5739
	end -- 5739
	if self.phase == "gate-farewell" then -- 5739
		return "嘱咐 " .. tostring(self.phaseTick) -- 5742
	end -- 5742
	if self.phase == "gate-count" then -- 5742
		return "数数 " .. tostring(self.countTick) -- 5745
	end -- 5745
	return "她走" -- 5747
end -- 5731
function Play.prototype.dogLabel(self) -- 5751
	if self.dogState == "ear" then -- 5751
		return "转耳" -- 5753
	end -- 5753
	if self.dogState == "chase" then -- 5753
		return "追" -- 5756
	end -- 5756
	if self.dogState == "sniff" then -- 5756
		return "停" -- 5759
	end -- 5759
	if self.dogState == "back" then -- 5759
		return "回线" -- 5762
	end -- 5762
	return "巡逻" -- 5764
end -- 5751
function Play.prototype.doorXOf(self) -- 5767
	local ____temp_146 -- 5768
	if self.room.story == nil then -- 5768
		____temp_146 = nil -- 5768
	else -- 5768
		____temp_146 = self.room.story.tower -- 5768
	end -- 5768
	local t = ____temp_146 -- 5768
	return t == nil and 0 or t.doorX -- 5769
end -- 5767
function Play.prototype.scavLabel(self) -- 5773
	if self.scavState == "chase" then -- 5773
		return "追" -- 5775
	end -- 5775
	if self.scavState == "turn" then -- 5775
		return "转头" -- 5778
	end -- 5778
	if self.scavState == "walk" then -- 5778
		return "赶来" -- 5781
	end -- 5781
	if self.scavState == "stall" then -- 5781
		return "停住" -- 5784
	end -- 5784
	if self.scavState == "back" then -- 5784
		return "回位" -- 5787
	end -- 5787
	return "巡逻" -- 5789
end -- 5773
function Play.prototype.hintText(self) -- 5793
	if self.paused then -- 5793
		return "Esc 继续 · R 重置" -- 5795
	end -- 5795
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5795
		if self:threatened() then -- 5795
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5801
		end -- 5801
		if self.coverHug then -- 5801
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5804
		end -- 5804
		if self.coverNear then -- 5804
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5807
		end -- 5807
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5809
	end -- 5809
	if self.flash ~= "" then -- 5809
		return self.flash -- 5812
	end -- 5812
	if self.room.key == "prologue" then -- 5812
		if self.phase == "prologue-wake" then -- 5812
			return "父亲在门外唤 · 小满睁眼" -- 5816
		end -- 5816
		if self.phase == "prologue-shadow" then -- 5816
			return "墙上两道人影 · 碗滚到脚边" -- 5819
		end -- 5819
		if self.phase == "prologue-escape" then -- 5819
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5822
		end -- 5822
		if self.phase == "prologue-hide" then -- 5822
			return "柜门合上 · 屏住呼吸" -- 5825
		end -- 5825
		if self.phase == "prologue-wait" then -- 5825
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5828
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5829
		end -- 5829
		if self.phase == "prologue-give" then -- 5829
			return ((("递物 " .. tostring(self.phaseTick)) .. " / ") .. tostring(____exports.PROLOGUE_GIVE_TICKS)) .. " 拍 · 站着别动" -- 5832
		end -- 5832
		return "她跟着你了 · 两人一起走到门口 680" -- 5834
	end -- 5834
	if self.room.key == "street" then -- 5834
		if self:aliveEnemies() > 0 then -- 5834
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5838
		end -- 5838
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5840
	end -- 5840
	if self.room.key == "gate" then -- 5840
		local ____temp_147 -- 5843
		if self.room.story == nil then -- 5843
			____temp_147 = nil -- 5843
		else -- 5843
			____temp_147 = self.room.story.gate -- 5843
		end -- 5843
		local g = ____temp_147 -- 5843
		if g ~= nil then -- 5843
			if self.phase == "gate-idle" then -- 5843
				if self.gateNeedConfirm then -- 5843
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5847
				end -- 5847
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5849
			end -- 5849
			if self.phase == "gate-hold" then -- 5849
				if self.coveredFlash > 0 then -- 5849
					return "掩体挡下了这一枪 · 别露头" -- 5853
				end -- 5853
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5855
			end -- 5855
			if self.phase == "gate-send" then -- 5855
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5858
			end -- 5858
			if self.phase == "gate-farewell" then -- 5858
				return "城门送别 · 嘱咐她慢慢数到二十" -- 5861
			end -- 5861
			if self.phase == "gate-count" then -- 5861
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5861
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5865
				end -- 5865
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5867
			end -- 5867
			return "她自己走 · 跟着出城门 1120" -- 5869
		end -- 5869
	end -- 5869
	if self.room.key == "forest" then -- 5869
		if self.dogState == "chase" then -- 5869
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5874
		end -- 5874
		if self.dogState == "ear" then -- 5874
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5877
		end -- 5877
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5879
	end -- 5879
	if self.room.key == "tower" then -- 5879
		if self.phase == "tower-wait" then -- 5879
			return "走到门前 445 点一次 E 敲两下" -- 5883
		end -- 5883
		if self.phase == "tower-knock" then -- 5883
			return "敲两下 · 等门开" -- 5886
		end -- 5886
		if self.phase == "tower-given" then -- 5886
			return "递交针套和纸条 · 看登记簿最后一行" -- 5889
		end -- 5889
		return "片尾 · 点 E 再玩一次，回到序章" -- 5891
	end -- 5891
	if self.room.key == "village" then -- 5891
		if self.bottleFly ~= nil then -- 5891
			return "等瓶子落地 · 触地才发声" -- 5895
		end -- 5895
		if self.hasBottle then -- 5895
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5898
		end -- 5898
		if self.passed then -- 5898
			return "已过第一院 · R 重置可再来一遍" -- 5901
		end -- 5901
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5903
	end -- 5903
	if self.room.key == "outside" then -- 5903
		if self.focusCart then -- 5903
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5907
		end -- 5907
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5909
	end -- 5909
	if self.escort.state == "frozen" then -- 5909
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5909
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5913
		end -- 5913
		return "小满吓住了 · 走过去，靠近再点 E" -- 5915
	end -- 5915
	if self.escort.state == "calming" then -- 5915
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5918
	end -- 5918
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5920
end -- 5793
return ____exports -- 5793