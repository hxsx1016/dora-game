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
function makeActor(room, index) -- 5949
	local sp = room.spawns -- 5950
	if index < 0 or index >= #sp then -- 5950
		return { -- 5952
			x = 0, -- 5952
			y = 0, -- 5952
			depth = 0, -- 5952
			depthSpeed = 0, -- 5952
			vx = 0, -- 5952
			vy = 0, -- 5952
			w = CHILD_W, -- 5952
			h = CHILD_H, -- 5952
			onGround = true, -- 5952
			facing = 1, -- 5952
			crouch = false, -- 5952
			rollT = 0, -- 5952
			covered = false, -- 5952
			alive = false -- 5952
		} -- 5952
	end -- 5952
	local s = sp[index + 1] -- 5954
	local child = s.h < SOLDIER_H -- 5955
	local ground = room.depth -- 5956
	local depth = ground == nil and 0 or math.max( -- 5957
		ground.min, -- 5957
		math.min(ground.max, s.depth or 0) -- 5957
	) -- 5957
	return { -- 5958
		x = s.x, -- 5959
		y = s.y, -- 5959
		depth = depth, -- 5959
		depthSpeed = 0, -- 5959
		vx = 0, -- 5959
		vy = 0, -- 5959
		w = child and CHILD_W or SOLDIER_W, -- 5960
		h = child and CHILD_H or SOLDIER_H, -- 5961
		onGround = true, -- 5962
		facing = 1, -- 5962
		crouch = false, -- 5962
		rollT = 0, -- 5962
		covered = false, -- 5962
		alive = true -- 5962
	} -- 5962
end -- 5962
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5967
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5968
end -- 5967
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5975
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5976
end -- 5975
function rayInterval(origin, direction, min, max) -- 5983
	if direction == 0 then -- 5983
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5985
	end -- 5985
	local a = (min - origin) / direction -- 5987
	local b = (max - origin) / direction -- 5988
	return { -- 5989
		min = math.min(a, b), -- 5989
		max = math.max(a, b) -- 5989
	} -- 5989
end -- 5989
function hitBox(ray, box) -- 5993
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5994
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5995
	local enter = math.max(0, x.min, y.min) -- 5996
	local leave = math.min(99999, x.max, y.max) -- 5997
	if box.depth ~= nil then -- 5997
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5999
		enter = math.max(enter, depth.min) -- 6000
		leave = math.min(leave, depth.max) -- 6001
	end -- 6001
	return leave >= enter and enter or -1 -- 6003
end -- 6003
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
____exports.BOTTLE_FLY_TIME = 0.62 -- 80
CHILD_W = 28 -- 155
CHILD_H = 56 -- 156
local CHILD_CROUCH_H = 34 -- 157
local CHILD_SPEED = 160 -- 158
local CHILD_SLOW = 80 -- 159
local CHILD_JUMP = 320 -- 160
SOLDIER_W = 30 -- 163
SOLDIER_H = 88 -- 164
local SOLDIER_SPEED = 264 -- 165
local ROLL_TIME = 0.35 -- 166
local ROLL_SPEED = 280 -- 167
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 169
local LEDGE_RISE = 60 -- 170
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 173
____exports.LOGIC_H = 180 -- 174
____exports.UNITS_PER_PX = 2 -- 175
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 177
local CAM_FOLLOW = 9 -- 178
local CAM_LOOK_UP = 46 -- 179
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 182
--- 握把触发半径。
____exports.CART_REACH = 70 -- 184
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 187
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 189
local CONSUMABLE_CAP = 1 -- 190
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 192
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 194
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 196
local FIRE_COOLDOWN = 150 -- 197
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 199
local ENEMY_RANGE = 760 -- 200
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 202
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 204
local DEPTH_SPEED_RATIO = 0.55 -- 205
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 206
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 293
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 294
	if zoom < 1 then -- 294
		zoom = 1 -- 296
	end -- 296
	return { -- 298
		zoom = zoom, -- 299
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 300
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 301
	} -- 301
end -- 293
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 324
	if key == "prologue" then -- 324
		return "prologue-wait" -- 328
	end -- 328
	if key == "street" then -- 328
		return "street-run" -- 331
	end -- 331
	if key == "gate" then -- 331
		return "gate-idle" -- 334
	end -- 334
	if key == "gatepath" then -- 334
		return "gatepath-start" -- 337
	end -- 337
	if key == "forest" then -- 337
		return "forest-run" -- 340
	end -- 340
	if key == "tower" then -- 340
		return "tower-wait" -- 343
	end -- 343
	if key == "museum" then -- 343
		return "museum-cabinet" -- 346
	end -- 346
	return "run" -- 348
end -- 324
____exports.Play = __TS__Class() -- 351
local Play = ____exports.Play -- 351
Play.name = "Play" -- 351
function Play.prototype.____constructor(self, room, resume, run) -- 666
	self.enemies = {} -- 356
	self.boxes = {} -- 357
	self.floors = {} -- 358
	self.checkpoint = -1 -- 360
	self.flash = "" -- 362
	self.flashT = 0 -- 363
	self.traceT = 0 -- 366
	self.focusCart = false -- 368
	self.knocks = 0 -- 370
	self.knockT = 0 -- 371
	self.cartAxle = 0 -- 375
	self.cartDocked = false -- 377
	self.gripping = false -- 379
	self.gateOpen = false -- 381
	self.calmConsumed = false -- 383
	self.craftT = 0 -- 385
	self.nextDangerId = 1 -- 387
	self.wantRoom = "" -- 389
	self.carryCartAxle = -1 -- 391
	self.carryCartDocked = false -- 392
	self.checkpointCartAxle = -1 -- 394
	self.hasBottle = false -- 398
	self.bottleLandX = -1 -- 402
	self.bottleLandDepth = 0 -- 403
	self.bottleLandSurface = "brick" -- 404
	self.bottleTargetX = -1 -- 405
	self.bottleTargetY = 0 -- 406
	self.bottleLandT = 0 -- 407
	self.aimHold = 0 -- 409
	self.bottleAimCancelLatch = false -- 411
	self.redCartMemoryT = 0 -- 413
	self.footHintT = 0 -- 415
	self.ditchHinted = false -- 417
	self.forestPath = "" -- 419
	self.waterSeen = false -- 421
	self.scavStallBonus = 0 -- 423
	self.intentGateReunionHold = false -- 425
	self.pendingMuseumIntentTarget = "" -- 427
	self.scavX = 0 -- 429
	self.scavDir = 1 -- 430
	self.scavState = "patrol" -- 431
	self.scavT = 0 -- 432
	self.scavTargetX = 0 -- 433
	self.passed = false -- 435
	self.childMode = false -- 439
	self.phase = "" -- 441
	self.phaseTick = 0 -- 443
	self.gateTick = 0 -- 445
	self.countTick = 0 -- 447
	self.countArmed = false -- 449
	self.countPrevMove = 0 -- 451
	self.caughtT = 0 -- 453
	self.hp = 3 -- 455
	self.maxHp = 3 -- 456
	self.invulnT = 0 -- 462
	self.partnerStuck = 0 -- 464
	self.partnerLaneIdx = 0 -- 466
	self.partnerLaneHold = 0 -- 467
	self.coveredFlash = 0 -- 469
	self.coverHug = false -- 471
	self.coverNear = false -- 473
	self.coverEntity = "" -- 475
	self.coverBlocking = false -- 477
	self.gateNeedConfirm = false -- 479
	self.gateRestartArmed = true -- 481
	self.bottleAimX = -1 -- 483
	self.bottleAimY = 0 -- 484
	self.bottleAimDepth = 0 -- 485
	self.bottleSurfaceY = -1 -- 489
	self.bottleLandY = 0 -- 491
	self.events = {} -- 493
	self.eventSeq = 0 -- 495
	self.dogX = 0 -- 497
	self.dogDir = 1 -- 498
	self.dogState = "patrol" -- 499
	self.dogT = 0 -- 500
	self.dogTargetX = 0 -- 501
	self.scavSee = 0 -- 503
	self.scavChase = false -- 504
	self.gateSpawned = 0 -- 506
	self.gateFailCount = 0 -- 508
	self.isCampaign = false -- 512
	self.archiveDirty = false -- 520
	self.sessionDirty = false -- 522
	self.restartStory = false -- 524
	self.wellOpen = false -- 526
	self.wellX = 430 -- 528
	self.wellTaken = false -- 530
	self.museumReturn = false -- 532
	self.endingLines = {"", ""} -- 534
	self.towerDoorOpen = false -- 536
	self.towerHanded = false -- 537
	self.deskHold = 0 -- 538
	self.towerEndMustRelease = false -- 540
	self.equippedWeapon = "standard_gun" -- 553
	self.craftBench = { -- 555
		active = false, -- 556
		firstCraftDone = false, -- 557
		justCraftedTimer = 0, -- 558
		inventory = {}, -- 559
		recipes = {}, -- 560
		equippedWeapon = "standard_gun" -- 561
	} -- 561
	self.handledCraftRequests = {} -- 564
	self.benchReach = 48 -- 566
	self.pickups = {} -- 570
	self.reloadT = 0 -- 572
	self.objectiveDone = false -- 576
	self.hint = "" -- 578
	self.roomStartTick = 0 -- 580
	self.cartHitT = 0 -- 582
	self.cartExposed = false -- 583
	self.storyRoute = "" -- 587
	self.storySettled = false -- 589
	self.hpAtGate = -1 -- 591
	self.maxHpAtGate = -1 -- 592
	self.handTicks = 0 -- 594
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 596
	self.handArmed = false -- 598
	self.handDone = false -- 600
	self.lineSaid = false -- 601
	self.tied = false -- 603
	self.pathDone = false -- 605
	self.carryOn = false -- 607
	self.escortDone = false -- 609
	self.escapeDuration = ____exports.PROLOGUE_ESCAPE_TICKS / 60 -- 613
	self.escapeRemaining = 0 -- 615
	self.escapeRetryCount = 0 -- 617
	self.introTick = 0 -- 619
	self.reloadOpen = false -- 623
	self.reloadAnswerTicks = 0 -- 625
	self.reloadWorldTicks = 0 -- 627
	self.reloadPath = {RELOAD_START} -- 629
	self.reloadPendingEffect = "" -- 631
	self.reloadTryCount = 0 -- 633
	self.talentModalActive = false -- 636
	self.useEscortDeathSummary = false -- 637
	self.escortFailed = false -- 638
	self.escortFailedTicks = 0 -- 639
	self.escortSummary = nil -- 640
	self.fieldWedgeSeq = 0 -- 648
	self.paused = false -- 650
	self.ticks = 0 -- 652
	self.view = {zoom = 1, ox = 0, oy = 0} -- 654
	self.ox = 0 -- 656
	self.aimX = 0 -- 658
	self.aimY = 0 -- 659
	self.viewW = 0 -- 661
	self.viewH = 0 -- 662
	self.ox = room.originX -- 668
	self.room = withOrigin(room) -- 669
	local wr = self.room -- 670
	self.run = run or createRun() -- 671
	self.inventory = self.run.inventory -- 672
	self.archive = self.run.archive -- 673
	local story = self.run.story -- 674
	local savedEq = story.equippedWeapon -- 675
	if savedEq == ARTIFACT_WEAPON_ID and self.archive.artifactOwned then -- 675
		self.equippedWeapon = ARTIFACT_WEAPON_ID -- 677
	elseif savedEq == "standard_gun" or savedEq ~= "" and savedEq == story.craftedWeapon then -- 677
		self.equippedWeapon = savedEq -- 679
	else -- 679
		self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 681
	end -- 681
	self.isCampaign = wr.campaign ~= nil -- 683
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 684
	self:buildWorld() -- 685
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 688
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 690
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 691
	local soloRoom = wr.key == "museum" -- 693
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 694
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 695
	self.player = makeActor(wr, playerIdx) -- 696
	self.partner = makeActor(wr, partnerIdx) -- 697
	self.phase = phaseOf(wr.key) -- 698
	if soloRoom then -- 698
		local mp = self.archive.museumPhase -- 701
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 702
	end -- 702
	if wr.story ~= nil then -- 702
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 708
	end -- 708
	self.cam.x = self.player.x -- 710
	self.cam.y = self.player.y + CAM_LOOK_UP -- 711
	self.cartAxle = wr.cart.startX -- 712
	self.escort = __TS__New( -- 713
		Escort, -- 713
		safeAnchorX(wr.marks) -- 713
	) -- 713
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 714
	if self.isCampaign then -- 714
		self:setupCampaign() -- 716
	else -- 716
		self:buildEnemies() -- 718
	end -- 718
	if resume ~= nil and resume.checkpoint > 0 then -- 718
		self.checkpoint = resume.checkpoint -- 722
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 722
			self.cartAxle = self.room.cart.endX -- 724
			self.cartDocked = true -- 725
			self.player.x = self.ox + 380 -- 728
			self.player.y = 0 -- 729
			self.player.vy = 0 -- 730
			self.player.onGround = true -- 731
			self.cam.x = self.player.x -- 732
			self.cam.y = self.player.y + CAM_LOOK_UP -- 733
		end -- 733
	end -- 733
	self:restoreStory() -- 736
end -- 666
function Play.prototype.towerEndReady(self) -- 543
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 544
	return self.room.key == "tower" and self.phase == "tower-end" and self.phaseTick >= waitTicks and not self.towerEndMustRelease -- 545
end -- 543
function Play.prototype.recipeViews(self) -- 749
	local out = {} -- 750
	local i = 0 -- 751
	do -- 751
		i = 0 -- 752
		while i < #CRAFT_RECIPES do -- 752
			local r = CRAFT_RECIPES[i + 1] -- 753
			local cost = {} -- 754
			if r.cost.wood ~= nil then -- 754
				cost.wood = r.cost.wood -- 756
			end -- 756
			if r.cost.bell ~= nil then -- 756
				cost.bell = r.cost.bell -- 759
			end -- 759
			out[#out + 1] = { -- 761
				id = r.id, -- 762
				name = r.name, -- 763
				desc = r.desc, -- 764
				enhancedEffect = r.enhancedEffect, -- 765
				cost = cost, -- 766
				crafted = self.run.story.craftedWeapon == r.id -- 767
			} -- 767
			i = i + 1 -- 752
		end -- 752
	end -- 752
	if self.archive.artifactOwned then -- 752
		out[#out + 1] = { -- 772
			id = ARTIFACT_WEAPON_ID, -- 773
			name = weaponNameOf(ARTIFACT_WEAPON_ID), -- 774
			desc = "井底拾取彩蛋 · 男主线移动留下冷白微金轨迹残影", -- 775
			enhancedEffect = "light", -- 776
			cost = {}, -- 777
			crafted = true -- 778
		} -- 778
	end -- 778
	return out -- 781
end -- 749
function Play.prototype.syncCraftBench(self) -- 785
	local view = self.craftBench -- 786
	local inv = self.run.inventory -- 787
	view.inventory = { -- 788
		wood = inv.wood, -- 788
		bell = inv.bell, -- 788
		scrap = inv.scrap, -- 788
		wedge = inv.wedge, -- 788
		ammo = inv.ammo -- 788
	} -- 788
	view.recipes = self:recipeViews() -- 789
	view.equippedWeapon = self.equippedWeapon -- 790
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 791
	if view.justCraftedTimer > 0 then -- 791
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 793
	end -- 793
end -- 785
function Play.prototype.openCraftBench(self) -- 798
	if self.room.key ~= "escort3" or self.craftBench.active then -- 798
		return -- 800
	end -- 800
	self.craftBench.active = true -- 802
	self.carryOn = false -- 803
	self.run.story.carry = false -- 804
	self.player.vx = 0 -- 805
	self.player.vy = 0 -- 806
	self.craftBench.justCraftedTimer = 0 -- 807
	self:syncCraftBench() -- 808
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 809
	self:log("开工台") -- 810
	self:emit( -- 811
		"benchOpen", -- 811
		{ -- 811
			recipes = __TS__ArrayMap( -- 812
				self.craftBench.recipes, -- 812
				function(____, r) return r.id end -- 812
			), -- 812
			inventory = self.craftBench.inventory, -- 813
			carry = self.carryOn -- 814
		} -- 814
	) -- 814
end -- 798
function Play.prototype.closeCraftBench(self) -- 819
	if not self.craftBench.active then -- 819
		return -- 821
	end -- 821
	self.craftBench.active = false -- 823
	self.craftBench.justCraftedTimer = 0 -- 824
	self.carryOn = true -- 825
	self.run.story.carry = true -- 826
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 827
	self:log("离站背起") -- 828
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 829
	if self.room.key == "escort3" and self.storyRoute == "soldier" then -- 829
		self:triggerDeferredEscort3Draft() -- 831
	end -- 831
end -- 819
function Play.prototype.triggerDeferredEscort3Draft(self) -- 836
	if self.room.key ~= "escort3" or self.storyRoute ~= "soldier" or self.run.finished then -- 836
		return false -- 838
	end -- 838
	if self.run.story.talents == nil then -- 838
		self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 841
	end -- 841
	local st = self.run.story.talents -- 843
	if not st.deferred and st.room == "escort3" then -- 843
		return false -- 845
	end -- 845
	draftTalentOffers(st, "escort3", self.equippedWeapon) -- 847
	if self.useEscortDeathSummary and #st.offers > 0 then -- 847
		self.talentModalActive = true -- 849
	end -- 849
	self.sessionDirty = true -- 851
	return #st.offers > 0 -- 852
end -- 836
function Play.prototype.openTalentDraft(self) -- 856
	if #self:getStoryTalentOffers() > 0 and not self.craftBench.active and not self.escortFailed then -- 856
		self.talentModalActive = true -- 858
	end -- 858
end -- 856
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 866
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 866
		return false -- 868
	end -- 868
	local recipe = findRecipe(recipeId) -- 870
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 870
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 872
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 873
		return false -- 874
	end -- 874
	local missing = missingMaterials(self.run.inventory, recipe) -- 876
	if #missing > 0 then -- 876
		self:flashSet( -- 878
			"缺料 · " .. table.concat(missing, " / "), -- 878
			1.6 -- 878
		) -- 878
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 879
		return false -- 880
	end -- 880
	payMaterials(self.run.inventory, recipe) -- 882
	self.handledCraftRequests[requestId] = true -- 883
	self.run.story.craftedWeapon = recipe.id -- 884
	self.run.story.equippedWeapon = recipe.id -- 885
	self.equippedWeapon = recipe.id -- 886
	self.sessionDirty = true -- 887
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 888
	self.craftBench.firstCraftDone = true -- 889
	self:syncCraftBench() -- 890
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 891
	self:log("改制 " .. recipe.id) -- 892
	self:emit("benchCraft", { -- 893
		recipeId = recipe.id, -- 894
		weapon = recipe.id, -- 895
		effect = recipe.enhancedEffect, -- 896
		wood = self.run.inventory.wood, -- 897
		bell = self.run.inventory.bell -- 898
	}) -- 898
	return true -- 900
end -- 866
function Play.prototype.equipWeapon(self, weaponId) -- 904
	local artifactOk = weaponId == ARTIFACT_WEAPON_ID and self.archive.artifactOwned -- 905
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId and not artifactOk then -- 905
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 907
		return false -- 908
	end -- 908
	self.equippedWeapon = weaponId -- 910
	self.run.story.equippedWeapon = weaponId -- 911
	self.sessionDirty = true -- 912
	self:syncCraftBench() -- 913
	self:flashSet( -- 914
		"已装备 " .. weaponNameOf(weaponId), -- 914
		1 -- 914
	) -- 914
	self:emit("benchEquip", {weapon = weaponId}) -- 915
	return true -- 916
end -- 904
function Play.prototype.toggleArtifactWeapon(self) -- 920
	if not self.archive.artifactOwned or self.childMode then -- 920
		return false -- 922
	end -- 922
	if self.equippedWeapon == ARTIFACT_WEAPON_ID then -- 922
		local fallback = self.run.story.craftedWeapon ~= "" and self.run.story.craftedWeapon or "standard_gun" -- 925
		return self:equipWeapon(fallback) -- 926
	end -- 926
	return self:equipWeapon(ARTIFACT_WEAPON_ID) -- 928
end -- 920
function Play.prototype.exportSession(self) -- 932
	self:syncStory() -- 933
	local story = self.run.story -- 934
	local inv = self.run.inventory -- 935
	local taken = {} -- 936
	for k in pairs(self.run.taken) do -- 937
		if self.run.taken[k] == true then -- 937
			taken[#taken + 1] = k -- 939
		end -- 939
	end -- 939
	local segments = {} -- 942
	for k in pairs(story.segments) do -- 943
		if story.segments[k] == true then -- 943
			segments[#segments + 1] = k -- 945
		end -- 945
	end -- 945
	local props = {} -- 948
	for k in pairs(self.run.props) do -- 949
		local st = self.run.props[k] -- 950
		if st ~= nil then -- 950
			props[#props + 1] = (((((((k .. ":") .. (st.broken and "1" or "0")) .. ":") .. tostring(math.floor(st.hp + 0.5))) .. ":") .. (st.wedge and "1" or "0")) .. ":") .. (st.revealed == true and "1" or "0") -- 952
		end -- 952
	end -- 952
	local talentRanks = {} -- 961
	if story.talents ~= nil then -- 961
		local ti = 0 -- 963
		do -- 963
			ti = 0 -- 964
			while ti < #ALL_TALENTS do -- 964
				local tid = ALL_TALENTS[ti + 1] -- 965
				local rk = story.talents.ranks[tid] or 0 -- 966
				if rk > 0 then -- 966
					talentRanks[#talentRanks + 1] = (tid .. ":") .. tostring(rk) -- 968
				end -- 968
				ti = ti + 1 -- 964
			end -- 964
		end -- 964
	end -- 964
	local ____temp_4 = self.escortFailed and "escort1" or self.room.key -- 974
	local ____temp_5 = self.escortFailed and 0 or self.checkpoint -- 975
	local ____self_run_seed_6 = self.run.seed -- 976
	local ____story_route_7 = story.route -- 977
	local ____story_hp_8 = story.hp -- 978
	local ____story_maxHp_9 = story.maxHp -- 979
	local ____story_hpAtGate_10 = story.hpAtGate -- 980
	local ____story_maxHpAtGate_11 = story.maxHpAtGate -- 981
	local ____story_settled_12 = story.settled -- 982
	local ____self_phase_13 = self.phase -- 983
	local ____story_countTick_14 = story.countTick -- 984
	local ____story_phaseTick_15 = story.phaseTick -- 985
	local ____story_handTicks_16 = story.handTicks -- 986
	local ____story_handDone_17 = story.handDone -- 987
	local ____story_lineSaid_18 = story.lineSaid -- 988
	local ____story_tied_19 = story.tied -- 989
	local ____story_carry_20 = story.carry -- 990
	local ____story_escortDone_21 = story.escortDone -- 991
	local ____story_craftedWeapon_22 = story.craftedWeapon -- 992
	local ____self_equippedWeapon_23 = self.equippedWeapon -- 993
	local ____inv_wood_24 = inv.wood -- 994
	local ____inv_bell_25 = inv.bell -- 995
	local ____inv_scrap_26 = inv.scrap -- 996
	local ____inv_wedge_27 = inv.wedge -- 997
	local ____inv_ammo_28 = inv.ammo -- 998
	local ____inv_shield_29 = inv.shield -- 999
	local ____inv_pass_30 = inv.pass -- 1000
	local ____inv_quickbelt_31 = inv.quickbelt -- 1001
	local ____taken_32 = taken -- 1002
	local ____segments_33 = segments -- 1003
	local ____self_cartAxle_34 = self.cartAxle -- 1004
	local ____self_cartDocked_35 = self.cartDocked -- 1005
	local ____self_run_route_36 = self.run.route -- 1006
	local ____self_run_joined_37 = self.run.joined -- 1007
	local ____self_run_c1Latch_38 = self.run.c1Latch -- 1008
	local ____self_run_c2Latch_39 = self.run.c2Latch -- 1009
	local ____temp_40 = story.talents ~= nil and story.talents.randomState or 0 -- 1010
	local ____temp_41 = story.talents ~= nil and story.talents.room or "" -- 1011
	local ____temp_42 = story.talents ~= nil and __TS__ArraySlice(story.talents.offers) or ({}) -- 1012
	local ____talentRanks_43 = talentRanks -- 1013
	local ____temp_44 = story.talents ~= nil and story.talents.attempt or 1 -- 1014
	local ____temp_45 = story.talents ~= nil and story.talents.variant or 0 -- 1015
	local ____temp_0 -- 1016
	if story.talents ~= nil then -- 1016
		____temp_0 = story.talents.deferred -- 1016
	else -- 1016
		____temp_0 = false -- 1016
	end -- 1016
	local ____temp_46 = story.talents ~= nil and story.talents.ranks.vitality or 0 -- 1017
	local ____temp_47 = story.talents ~= nil and story.talents.ranks.focus or 0 -- 1018
	local ____temp_48 = story.talents ~= nil and story.talents.ranks.guard or 0 -- 1019
	local ____temp_49 = story.talents ~= nil and story.talents.ranks.salvage or 0 -- 1020
	local ____props_50 = props -- 1021
	local ____table_escortFailed_1 -- 1022
	if self.escortFailed then -- 1022
		____table_escortFailed_1 = nil -- 1022
	else -- 1022
		____table_escortFailed_1 = self.player.x -- 1022
	end -- 1022
	local ____table_escortFailed_2 -- 1023
	if self.escortFailed then -- 1023
		____table_escortFailed_2 = nil -- 1023
	else -- 1023
		____table_escortFailed_2 = self.player.y -- 1023
	end -- 1023
	local ____table_escortFailed_3 -- 1024
	if self.escortFailed then -- 1024
		____table_escortFailed_3 = nil -- 1024
	else -- 1024
		____table_escortFailed_3 = self.player.depth -- 1024
	end -- 1024
	return { -- 972
		roomKey = ____temp_4, -- 974
		checkpoint = ____temp_5, -- 975
		seed = ____self_run_seed_6, -- 976
		route = ____story_route_7, -- 977
		hp = ____story_hp_8, -- 978
		maxHp = ____story_maxHp_9, -- 979
		hpAtGate = ____story_hpAtGate_10, -- 980
		maxHpAtGate = ____story_maxHpAtGate_11, -- 981
		settled = ____story_settled_12, -- 982
		phase = ____self_phase_13, -- 983
		countTick = ____story_countTick_14, -- 984
		phaseTick = ____story_phaseTick_15, -- 985
		handTicks = ____story_handTicks_16, -- 986
		handDone = ____story_handDone_17, -- 987
		lineSaid = ____story_lineSaid_18, -- 988
		tied = ____story_tied_19, -- 989
		carry = ____story_carry_20, -- 990
		escortDone = ____story_escortDone_21, -- 991
		craftedWeapon = ____story_craftedWeapon_22, -- 992
		equippedWeapon = ____self_equippedWeapon_23, -- 993
		wood = ____inv_wood_24, -- 994
		bell = ____inv_bell_25, -- 995
		scrap = ____inv_scrap_26, -- 996
		wedge = ____inv_wedge_27, -- 997
		ammo = ____inv_ammo_28, -- 998
		shield = ____inv_shield_29, -- 999
		pass = ____inv_pass_30, -- 1000
		quickbelt = ____inv_quickbelt_31, -- 1001
		taken = ____taken_32, -- 1002
		segments = ____segments_33, -- 1003
		cartAxle = ____self_cartAxle_34, -- 1004
		cartDocked = ____self_cartDocked_35, -- 1005
		campaignRoute = ____self_run_route_36, -- 1006
		joined = ____self_run_joined_37, -- 1007
		c1Latch = ____self_run_c1Latch_38, -- 1008
		c2Latch = ____self_run_c2Latch_39, -- 1009
		talentSeed = ____temp_40, -- 1010
		talentRoom = ____temp_41, -- 1011
		talentOffers = ____temp_42, -- 1012
		talentRanks = ____talentRanks_43, -- 1013
		escortAttempt = ____temp_44, -- 1014
		escortVariant = ____temp_45, -- 1015
		talentDeferred = ____temp_0, -- 1016
		talentVitality = ____temp_46, -- 1017
		talentReload = ____temp_47, -- 1018
		talentGuard = ____temp_48, -- 1019
		talentCraft = ____temp_49, -- 1020
		props = ____props_50, -- 1021
		playerX = ____table_escortFailed_1, -- 1022
		playerY = ____table_escortFailed_2, -- 1023
		playerDepth = ____table_escortFailed_3, -- 1024
		gateTick = self.gateTick, -- 1025
		hasBottle = self.hasBottle, -- 1026
		villagePassed = self.passed -- 1027
	} -- 1027
end -- 932
function Play.prototype.submitFeIntent(self, intent) -- 1035
	local kind = intent == nil and "" or intent.kind -- 1036
	if kind == "gateReunionHold" then -- 1036
		if self.room.key ~= "gate" or self.phase ~= "gate-wait" and self.phase ~= "gate-count" then -- 1036
			return false -- 1039
		end -- 1039
		local holding = intent.holding == true -- 1041
		self.intentGateReunionHold = holding -- 1042
		if not holding and self.phase == "gate-wait" then -- 1042
			if self.handTicks > 0 then -- 1042
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1045
			end -- 1045
			self.handTicks = 0 -- 1047
			self.handArmed = true -- 1048
		end -- 1048
		return true -- 1050
	end -- 1050
	if kind == "reloadOpen" then -- 1050
		local camp = self.room.campaign -- 1053
		if camp == nil or camp.reloadPuzzle ~= true or self.reloadOpen then -- 1053
			return false -- 1055
		end -- 1055
		self:beginReload() -- 1057
		return self.reloadOpen -- 1058
	end -- 1058
	if kind == "reloadPathPreview" then -- 1058
		local path = intent.path -- 1061
		return type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) -- 1062
	end -- 1062
	if kind == "reloadTapNode" then -- 1062
		local node = intent.node -- 1065
		if type(node) == "number" then -- 1065
			self:reloadTapNode(node) -- 1067
			return true -- 1068
		end -- 1068
		return false -- 1070
	end -- 1070
	if kind == "reloadPathCommit" then -- 1070
		local path = intent.path -- 1073
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 1073
			local list = path -- 1075
			local i = 0 -- 1076
			do -- 1076
				i = 0 -- 1077
				while i < #list do -- 1077
					do -- 1077
						if i == 0 and list[i + 1] == RELOAD_START then -- 1077
							goto __continue85 -- 1079
						end -- 1079
						self:reloadTapNode(list[i + 1]) -- 1081
					end -- 1081
					::__continue85:: -- 1081
					i = i + 1 -- 1077
				end -- 1077
			end -- 1077
			return true -- 1083
		end -- 1083
		return false -- 1085
	end -- 1085
	if kind == "reloadCancel" then -- 1085
		self:closeReloadPuzzle() -- 1088
		return true -- 1089
	end -- 1089
	if kind == "craftSubmit" then -- 1089
		local recipeId = intent.recipeId -- 1092
		local requestId = intent.requestId -- 1093
		if type(recipeId) == "string" and type(requestId) == "string" then -- 1093
			return self:craftAtBench(recipeId, requestId) -- 1095
		end -- 1095
		return false -- 1097
	end -- 1097
	if kind == "craftEquip" then -- 1097
		local weaponId = intent.weaponId -- 1100
		if type(weaponId) == "string" then -- 1100
			return self:equipWeapon(weaponId) -- 1102
		end -- 1102
		return false -- 1104
	end -- 1104
	if kind == "craftClose" then -- 1104
		self:closeCraftBench() -- 1107
		return true -- 1108
	end -- 1108
	if kind == "chooseTalent" then -- 1108
		local slot = intent.slot -- 1111
		if type(slot) == "number" then -- 1111
			return self:chooseTalent(slot) -- 1113
		end -- 1113
		return false -- 1115
	end -- 1115
	if kind == "wellPick" then -- 1115
		return self:pickWell() -- 1118
	end -- 1118
	if kind == "museumInteract" then -- 1118
		local target = type(intent.target) == "string" and intent.target or "" -- 1121
		if target == "well_pickup" or target == "well" then -- 1121
			return self:pickWell() -- 1123
		end -- 1123
		if self.room.key ~= "museum" then -- 1123
			return false -- 1126
		end -- 1126
		return self:triggerMuseumIntent(target) -- 1128
	end -- 1128
	return false -- 1130
end -- 1035
function Play.prototype.triggerMuseumIntent(self, target) -- 1134
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 1135
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 1138
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 1139
	if self.phase == "museum-cabinet" then -- 1139
		if target == "enter_hall" or (target == "" or target == "cabinet" or target == "weapon_case") and atCase then -- 1139
			self.pendingMuseumIntentTarget = "cabinet" -- 1142
			return true -- 1143
		end -- 1143
	end -- 1143
	if self.phase == "museum-hall" then -- 1143
		if (target == "lamp_turn" or target == "lamp" or target == "west_lamp") and nearLamp then -- 1143
			self.pendingMuseumIntentTarget = "lamp_direct" -- 1148
			return true -- 1149
		end -- 1149
		if (target == "" or target == "hall" or target == "corridor") and self.player.x >= self.ox + mu.hallX then -- 1149
			self.pendingMuseumIntentTarget = "hall" -- 1152
			return true -- 1153
		end -- 1153
	end -- 1153
	if self.phase == "museum-lamp" and (target == "" or target == "lamp" or target == "west_lamp" or target == "lamp_turn") and nearLamp then -- 1153
		self.pendingMuseumIntentTarget = "lamp" -- 1159
		return true -- 1160
	end -- 1160
	if self.phase == "museum-return" then -- 1160
		if target == "begin_return_cabinet" or (target == "" or target == "return_cabinet" or target == "cabinet" or target == "return") and atCase then -- 1160
			self.pendingMuseumIntentTarget = "return_cabinet" -- 1165
			return true -- 1166
		end -- 1166
	end -- 1166
	if self.phase == "museum-done" and (target == "" or target == "return_cabinet" or target == "return") then -- 1166
		self.pendingMuseumIntentTarget = "done" -- 1170
		return true -- 1171
	end -- 1171
	return false -- 1173
end -- 1134
function Play.prototype.captureCheckpoint(self, id) -- 1177
	local inv = self.run.inventory -- 1178
	self.checkpointSnap = { -- 1179
		id = id, -- 1180
		wood = inv.wood, -- 1181
		bell = inv.bell, -- 1182
		scrap = inv.scrap, -- 1183
		wedge = inv.wedge, -- 1184
		ammo = inv.ammo, -- 1185
		shield = inv.shield, -- 1186
		pass = inv.pass, -- 1187
		quickbelt = inv.quickbelt, -- 1188
		crafted = self.run.story.craftedWeapon, -- 1189
		equipped = self.equippedWeapon, -- 1190
		carry = self.carryOn -- 1191
	} -- 1191
	self.run.story.cp = self.checkpointSnap -- 1193
end -- 1177
function Play.prototype.applyCheckpointSnap(self, id) -- 1197
	local snap = self.run.story.cp -- 1198
	if snap == nil or snap.id ~= id then -- 1198
		return false -- 1200
	end -- 1200
	self.checkpointSnap = snap -- 1202
	local inv = self.run.inventory -- 1203
	inv.wood = snap.wood -- 1204
	inv.bell = snap.bell -- 1205
	inv.scrap = snap.scrap -- 1206
	inv.wedge = snap.wedge -- 1207
	inv.ammo = snap.ammo -- 1208
	inv.shield = snap.shield -- 1209
	inv.pass = snap.pass -- 1210
	inv.quickbelt = snap.quickbelt -- 1211
	self.run.story.craftedWeapon = snap.crafted -- 1212
	self.equippedWeapon = snap.equipped -- 1213
	self.run.story.equippedWeapon = snap.equipped -- 1214
	self.carryOn = snap.carry -- 1215
	self.run.story.carry = snap.carry -- 1216
	self.craftBench.active = false -- 1217
	self:syncCraftBench() -- 1218
	return true -- 1219
end -- 1197
function Play.prototype.restoreStory(self) -- 1222
	local story = self.run.story -- 1223
	if story == nil then -- 1223
		return -- 1225
	end -- 1225
	if story.maxHp > 0 then -- 1225
		self.maxHp = story.maxHp -- 1228
		self.hp = math.max( -- 1229
			1, -- 1229
			math.min(story.hp, story.maxHp) -- 1229
		) -- 1229
	end -- 1229
	self.storyRoute = story.route -- 1231
	self.storySettled = story.settled -- 1232
	self.hpAtGate = story.hpAtGate -- 1233
	self.maxHpAtGate = story.maxHpAtGate -- 1234
	self.handDone = story.handDone -- 1235
	self.lineSaid = story.lineSaid -- 1236
	self.tied = story.handDone -- 1237
	self.carryOn = story.carry or story.route == "soldier" and (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 1238
	self.museumReturn = story.museumReturn -- 1239
	story.museumReturn = false -- 1240
	self.escortDone = story.escortDone -- 1241
	self:syncCraftBench() -- 1242
	if self.room.key == "outside" and story.segments.outside_cart == true then -- 1242
		self.cartAxle = self.room.cart.endX -- 1244
		self.cartDocked = true -- 1245
	end -- 1245
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 1247
	self.waterSeen = story.segments.water_lantern == true -- 1249
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 1249
		self:applyCheckpointSnap(self.checkpoint) -- 1252
	end -- 1252
	if self.room.key == "tower" and story.route == "soldier" then -- 1252
		self.carryOn = false -- 1256
		self.run.story.carry = false -- 1257
		self.player.w = SOLDIER_W -- 1258
		self.player.h = SOLDIER_H -- 1259
		self.player.x = math.max(self.ox + 422, self.player.x) -- 1260
		self.partner = { -- 1261
			x = math.max(self.ox + 408, self.player.x - 24), -- 1262
			y = 0, -- 1263
			depth = 0, -- 1264
			depthSpeed = 0, -- 1265
			vx = 0, -- 1266
			vy = 0, -- 1267
			w = CHILD_W, -- 1268
			h = CHILD_H, -- 1269
			onGround = true, -- 1270
			facing = 1, -- 1271
			crouch = false, -- 1272
			rollT = 0, -- 1273
			covered = false, -- 1274
			alive = true -- 1275
		} -- 1275
	end -- 1275
	if self.room.key == "tower" then -- 1275
		if story.segments.tower_door == true then -- 1275
			self:openTowerDoor() -- 1281
		end -- 1281
		self.towerHanded = story.segments.tower_handover == true -- 1283
		self.deskHold = 0 -- 1284
		if story.phase == "tower-enter" or story.phase == "tower-desk" or story.phase == "tower-given" then -- 1284
			self.phase = story.phase -- 1286
			self.phaseTick = 0 -- 1287
			if story.phase == "tower-desk" or story.phase == "tower-given" then -- 1287
				self.player.x = self.ox + 605 -- 1289
				self.player.y = 0 -- 1290
				if story.route == "soldier" and self.partner.alive then -- 1290
					self.partner.x = self.ox + 568 -- 1292
					self.partner.y = 0 -- 1293
					self.partner.facing = 1 -- 1294
				end -- 1294
			end -- 1294
		end -- 1294
	end -- 1294
	if self.room.key == "prologue" then -- 1294
		local ph = story.phase -- 1301
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 1301
			self.phase = ph -- 1303
			self.phaseTick = story.phaseTick -- 1304
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 1305
			self.player.y = 0 -- 1306
			self.player.depth = 0 -- 1307
			self.player.vx = 0 -- 1308
			self.partner.x = self.ox + 300 -- 1309
			self.partner.y = 0 -- 1310
			self.partner.depth = 0 -- 1311
			self.partner.vx = 0 -- 1312
			self.partner.alive = true -- 1313
			if ph == "prologue-follow" then -- 1313
				self.partner.crouch = false -- 1315
				self.partner.h = CHILD_H -- 1316
			else -- 1316
				self.partner.crouch = true -- 1318
				self.partner.h = CHILD_CROUCH_H -- 1319
			end -- 1319
			self.cam.x = self.player.x -- 1321
		end -- 1321
		return -- 1323
	end -- 1323
	if self.room.key ~= "gate" then -- 1323
		return -- 1326
	end -- 1326
	local ____temp_51 -- 1328
	if self.room.story == nil then -- 1328
		____temp_51 = nil -- 1328
	else -- 1328
		____temp_51 = self.room.story.gate -- 1328
	end -- 1328
	local g = ____temp_51 -- 1328
	if g == nil then -- 1328
		return -- 1330
	end -- 1330
	if story.phase == "gate-send" then -- 1330
		self.phase = "gate-send" -- 1334
		self.gateTick = g.holdTicks -- 1335
		self.gateSpawned = 4 -- 1336
		self.enemies = {} -- 1337
		self.player.x = self.ox + g.doorX - 40 -- 1338
		self.player.y = 0 -- 1339
		self.player.depth = 0 -- 1340
		self.player.vx = 0 -- 1341
		self.player.vy = 0 -- 1342
		self.player.onGround = true -- 1343
		self.partner.x = self.ox + g.waitX -- 1344
		self.partner.y = 0 -- 1345
		self.partner.depth = 0 -- 1346
		self.partner.alive = true -- 1347
		self.cam.x = self.player.x -- 1348
		self.handTicks = 0 -- 1349
		self.handArmed = false -- 1350
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1351
		return -- 1352
	end -- 1352
	if not story.settled then -- 1352
		return -- 1355
	end -- 1355
	self.gateTick = g.holdTicks -- 1358
	self.gateSpawned = 4 -- 1359
	self.enemies = {} -- 1360
	if story.phase == "gate-farewell" or story.phase == "gate-count" or story.phase == "gate-walk" then -- 1360
		self.phase = story.phase == "gate-farewell" and "gate-count" or story.phase -- 1362
		self.countTick = story.phase == "gate-farewell" and 0 or math.max(story.countTick, 0) -- 1363
		self:swapToChild(g.doorX + 30) -- 1364
		self.countPrevMove = 0 -- 1365
		self.countArmed = false -- 1366
		return -- 1367
	end -- 1367
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1367
		self.phase = story.phase -- 1370
		self.countTick = ____exports.GATE_COUNT_END -- 1371
		self.phaseTick = story.phaseTick -- 1372
		self:swapToChild(g.doorX + 30) -- 1373
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1374
			0, -- 1374
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1374
		) -- 1374
		self.handArmed = false -- 1375
	end -- 1375
end -- 1222
function Play.prototype.buildWorld(self) -- 1380
	local room = self.room -- 1381
	self.boxes = {} -- 1382
	self.floors = {} -- 1383
	local i = 0 -- 1384
	do -- 1384
		i = 0 -- 1385
		while i < #room.floors do -- 1385
			local f = room.floors[i + 1] -- 1386
			local ____self_floors_52 = self.floors -- 1386
			____self_floors_52[#____self_floors_52 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1387
			i = i + 1 -- 1385
		end -- 1385
	end -- 1385
	do -- 1385
		i = 0 -- 1389
		while i < #room.solids do -- 1389
			local s = room.solids[i + 1] -- 1390
			if not s.decorative then -- 1390
				local ____self_boxes_64 = self.boxes -- 1396
				local ____s_x_55 = s.x -- 1397
				local ____temp_56 = s.x + s.w -- 1397
				local ____s_y_57 = s.y -- 1397
				local ____temp_58 = s.y + s.h -- 1397
				local ____temp_53 -- 1398
				if room.depth == nil then -- 1398
					____temp_53 = nil -- 1398
				else -- 1398
					____temp_53 = s.depth -- 1398
				end -- 1398
				local ____temp_59 = s.passable == true -- 1399
				local ____s_label_60 = s.label -- 1399
				local ____s_id_61 = s.id -- 1400
				local ____temp_62 = s.soft == true -- 1400
				local ____temp_63 = s.hidden == true -- 1400
				local ____temp_54 -- 1401
				if s.breakable == nil then -- 1401
					____temp_54 = nil -- 1401
				else -- 1401
					____temp_54 = __TS__ObjectAssign({}, s.breakable) -- 1401
				end -- 1401
				____self_boxes_64[#____self_boxes_64 + 1] = { -- 1396
					x0 = ____s_x_55, -- 1397
					x1 = ____temp_56, -- 1397
					y0 = ____s_y_57, -- 1397
					y1 = ____temp_58, -- 1397
					depth = ____temp_53, -- 1398
					passable = ____temp_59, -- 1399
					label = ____s_label_60, -- 1399
					id = ____s_id_61, -- 1400
					soft = ____temp_62, -- 1400
					hidden = ____temp_63, -- 1400
					breakable = ____temp_54, -- 1401
					interact = s.interact -- 1402
				} -- 1402
			end -- 1402
			i = i + 1 -- 1389
		end -- 1389
	end -- 1389
	do -- 1389
		i = 0 -- 1406
		while i < #room.stairs do -- 1406
			local st = room.stairs[i + 1] -- 1407
			local n = st.steps + 1 -- 1408
			local stepW = (st.x1 - st.x0) / n -- 1409
			local k = 0 -- 1410
			do -- 1410
				k = 0 -- 1411
				while k < n do -- 1411
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1412
					local x0 = st.x0 + stepW * k -- 1413
					local ____self_boxes_68 = self.boxes -- 1416
					local ____temp_66 = x0 + stepW -- 1417
					local ____temp_67 = -8 -- 1417
					local ____temp_65 -- 1418
					if room.depth == nil then -- 1418
						____temp_65 = nil -- 1418
					else -- 1418
						____temp_65 = st.depth -- 1418
					end -- 1418
					____self_boxes_68[#____self_boxes_68 + 1] = { -- 1416
						x0 = x0, -- 1417
						x1 = ____temp_66, -- 1417
						y0 = ____temp_67, -- 1417
						y1 = y, -- 1417
						depth = ____temp_65, -- 1418
						passable = true -- 1419
					} -- 1419
					k = k + 1 -- 1411
				end -- 1411
			end -- 1411
			i = i + 1 -- 1406
		end -- 1406
	end -- 1406
end -- 1380
function Play.prototype.setupCampaign(self) -- 1429
	local wr = self.room -- 1430
	local c = wr.campaign -- 1431
	if c == nil then -- 1431
		return -- 1433
	end -- 1433
	self.roomStartTick = self.run.ticks -- 1435
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1435
		self.run.joined = true -- 1439
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1439
		local ____self_run_73 = self.run -- 1442
		local ____temp_72 -- 1442
		if wr.key == "s2-drygoods" then -- 1442
			local ____temp_71 = self.run.route ~= "drygoods" -- 1443
			if not ____temp_71 then -- 1443
				local ____opt_69 = self.run.props.s2_board -- 1443
				____temp_71 = (____opt_69 and ____opt_69.broken) == true -- 1443
			end -- 1443
			____temp_72 = ____temp_71 -- 1443
		else -- 1443
			____temp_72 = wr.key == "c1-yard" and self.run.c1Latch -- 1444
		end -- 1444
		____self_run_73.joined = ____temp_72 -- 1442
	end -- 1442
	local x = wr.minX + 60 -- 1446
	local y = 0 -- 1447
	local depth = 0 -- 1448
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1448
		x = wr.minX + 210 -- 1450
		depth = -32 -- 1451
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1451
		x = wr.minX + 40 -- 1453
		y = 32 -- 1454
		depth = 32 -- 1455
	end -- 1455
	self.player = { -- 1457
		x = x, -- 1458
		y = y, -- 1458
		depth = depth, -- 1458
		depthSpeed = 0, -- 1458
		vx = 0, -- 1458
		vy = 0, -- 1458
		w = SOLDIER_W, -- 1459
		h = SOLDIER_H, -- 1459
		onGround = y <= 0, -- 1459
		facing = 1, -- 1459
		crouch = false, -- 1459
		rollT = 0, -- 1459
		covered = false, -- 1459
		alive = true -- 1459
	} -- 1459
	self.partner = { -- 1461
		x = x + 60, -- 1462
		y = y, -- 1462
		depth = depth, -- 1462
		depthSpeed = 0, -- 1462
		vx = 0, -- 1462
		vy = 0, -- 1462
		w = CHILD_W, -- 1463
		h = CHILD_H, -- 1463
		onGround = y <= 0, -- 1463
		facing = 1, -- 1463
		crouch = false, -- 1463
		rollT = 0, -- 1463
		covered = false, -- 1463
		alive = true -- 1463
	} -- 1463
	self.cam.x = x -- 1465
	self.cam.y = y + CAM_LOOK_UP -- 1466
	self.phase = "run" -- 1467
	self.hp = self.maxHp -- 1468
	if self:isEscortRoom() and self.run.story.route == "soldier" then -- 1468
		if self.run.story.talents == nil then -- 1468
			self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 1471
		end -- 1471
		local st = self.run.story.talents -- 1473
		local variants = ESCORT_VARIANTS[wr.key] -- 1474
		if self.run.source ~= "debug" and variants ~= nil and #variants > 0 then -- 1474
			st.variant = pickEscortVariant(self.run.seed, st.attempt, wr.key, #variants) -- 1476
		else -- 1476
			st.variant = 0 -- 1478
		end -- 1478
		if wr.key == "escort3" then -- 1478
			if st.room ~= "escort3" then -- 1478
				st.room = "escort3" -- 1484
				st.deferred = true -- 1485
				st.offers = {} -- 1486
			end -- 1486
		else -- 1486
			draftTalentOffers(st, wr.key, self.equippedWeapon) -- 1489
		end -- 1489
	end -- 1489
	self:buildEnemies() -- 1492
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1493
	local i = 0 -- 1494
	do -- 1494
		i = 0 -- 1495
		while i < #self.boxes do -- 1495
			do -- 1495
				local b = self.boxes[i + 1] -- 1496
				if b.id == nil then -- 1496
					goto __continue157 -- 1498
				end -- 1498
				local st = self.run.props[b.id] -- 1500
				if st ~= nil then -- 1500
					b.broken = st.broken -- 1502
					local ____temp_74 -- 1503
					if b.breakable == nil then -- 1503
						____temp_74 = nil -- 1503
					else -- 1503
						____temp_74 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1503
					end -- 1503
					b.breakable = ____temp_74 -- 1503
					b.hidden = b.hidden == true and st.revealed ~= true -- 1504
					if b.hidden then -- 1504
						b.broken = true -- 1506
					end -- 1506
				elseif b.hidden == true then -- 1506
					b.broken = true -- 1510
				end -- 1510
			end -- 1510
			::__continue157:: -- 1510
			i = i + 1 -- 1495
		end -- 1495
	end -- 1495
	if wr.cart.bodyW > 0 then -- 1495
		self.cartAxle = wr.cart.startX -- 1514
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1514
			self.cartAxle = wr.cart.endX -- 1516
			self.cartDocked = true -- 1517
		end -- 1517
	end -- 1517
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1520
end -- 1429
function Play.prototype.log(self, line) -- 1523
	local ____self_run_log_75 = self.run.log -- 1523
	____self_run_log_75[#____self_run_log_75 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1524
	if #self.run.log > 120 then -- 1524
		table.remove(self.run.log, 1) -- 1526
	end -- 1526
end -- 1523
function Play.prototype.buildEnemies(self) -- 1530
	self.enemies = {} -- 1531
	if self.isCampaign then -- 1531
		local variants = ESCORT_VARIANTS[self.room.key] -- 1533
		local useVariant = self:isEscortRoom() and self.run.story.route == "soldier" and self.run.source ~= "debug" and variants ~= nil and #variants > 0 -- 1534
		local ____useVariant_79 -- 1539
		if useVariant then -- 1539
			local ____temp_78 = #variants - 1 -- 1540
			local ____opt_76 = self.run.story.talents -- 1540
			____useVariant_79 = math.max( -- 1540
				0, -- 1540
				math.min(____temp_78, ____opt_76 and ____opt_76.variant or 0) -- 1540
			) -- 1540
		else -- 1540
			____useVariant_79 = 0 -- 1541
		end -- 1541
		local vIdx = ____useVariant_79 -- 1539
		local spawnList = useVariant and variants[vIdx + 1] or self.room.spawns -- 1542
		local i = 0 -- 1543
		do -- 1543
			i = 0 -- 1544
			while i < #spawnList do -- 1544
				local sp = spawnList[i + 1] -- 1545
				local kind = sp.kind or "gunner" -- 1546
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1547
				local sx = useVariant and self.ox + sp.x or sp.x -- 1548
				local ____self_enemies_80 = self.enemies -- 1548
				____self_enemies_80[#____self_enemies_80 + 1] = { -- 1549
					x = sx, -- 1550
					y = sp.y, -- 1550
					depth = sp.depth, -- 1550
					w = 26, -- 1550
					h = sp.h, -- 1550
					alive = true, -- 1550
					hitT = 0, -- 1550
					warnT = 0, -- 1550
					fireCd = 40, -- 1550
					kind = kind, -- 1551
					shieldHp = hp, -- 1551
					shieldHpMax = hp, -- 1551
					drop = sp.drop or "none", -- 1551
					homeX = sx, -- 1552
					swingT = 0, -- 1552
					awake = false, -- 1552
					squad = i -- 1552
				} -- 1552
				i = i + 1 -- 1544
			end -- 1544
		end -- 1544
		return -- 1555
	end -- 1555
	if self.room.key == "checkpoint" then -- 1555
		local ____self_enemies_81 = self.enemies -- 1555
		____self_enemies_81[#____self_enemies_81 + 1] = { -- 1558
			x = self.ox + 430, -- 1558
			y = 0, -- 1558
			w = 26, -- 1558
			h = 84, -- 1558
			alive = true, -- 1558
			hitT = 0, -- 1558
			warnT = 0, -- 1558
			fireCd = 0 -- 1558
		} -- 1558
		local ____self_enemies_82 = self.enemies -- 1558
		____self_enemies_82[#____self_enemies_82 + 1] = { -- 1559
			x = self.ox + 505, -- 1559
			y = 0, -- 1559
			w = 26, -- 1559
			h = 84, -- 1559
			alive = true, -- 1559
			hitT = 0, -- 1559
			warnT = 0, -- 1559
			fireCd = 0 -- 1559
		} -- 1559
		return -- 1560
	end -- 1560
	if self.room.key == "street" then -- 1560
		local ____self_enemies_83 = self.enemies -- 1560
		____self_enemies_83[#____self_enemies_83 + 1] = { -- 1564
			x = self.ox + 340, -- 1564
			y = 0, -- 1564
			w = 26, -- 1564
			h = 84, -- 1564
			alive = true, -- 1564
			hitT = 0, -- 1564
			warnT = 0, -- 1564
			fireCd = 0 -- 1564
		} -- 1564
		local ____self_enemies_84 = self.enemies -- 1564
		____self_enemies_84[#____self_enemies_84 + 1] = { -- 1565
			x = self.ox + 560, -- 1565
			y = 0, -- 1565
			w = 26, -- 1565
			h = 84, -- 1565
			alive = true, -- 1565
			hitT = 0, -- 1565
			warnT = 0, -- 1565
			fireCd = 0 -- 1565
		} -- 1565
	end -- 1565
end -- 1530
function Play.prototype.emit(self, name, data) -- 1571
	local ____self_events_85 = self.events -- 1571
	____self_events_85[#____self_events_85 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1572
	self.eventSeq = self.eventSeq + 1 -- 1573
	if #self.events > 256 then -- 1573
		table.remove(self.events, 1) -- 1575
	end -- 1575
end -- 1571
function Play.prototype.drainEvents(self) -- 1583
	local out = self.events -- 1584
	self.events = {} -- 1585
	return out -- 1586
end -- 1583
function Play.prototype.adoptEvents(self, events) -- 1595
	if #events == 0 then -- 1595
		return -- 1597
	end -- 1597
	local keep = {} -- 1599
	local i = 0 -- 1600
	do -- 1600
		i = 0 -- 1601
		while i < #events do -- 1601
			do -- 1601
				local e = events[i + 1] -- 1602
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1602
					goto __continue178 -- 1604
				end -- 1604
				keep[#keep + 1] = e -- 1606
			end -- 1606
			::__continue178:: -- 1606
			i = i + 1 -- 1601
		end -- 1601
	end -- 1601
	if #keep == 0 then -- 1601
		return -- 1609
	end -- 1609
	self.events = __TS__ArrayConcat(keep, self.events) -- 1611
	do -- 1611
		i = 0 -- 1612
		while i < #self.events do -- 1612
			self.events[i + 1].seq = i -- 1613
			i = i + 1 -- 1612
		end -- 1612
	end -- 1612
	self.eventSeq = #self.events -- 1615
end -- 1595
function Play.prototype.talentRank(self, talent) -- 1618
	if self.storyRoute == "soldier" and self:isEscortRoom() and self.run.story.talents ~= nil then -- 1618
		return self.run.story.talents.ranks[talent] or 0 -- 1620
	end -- 1620
	return 0 -- 1622
end -- 1618
function Play.prototype.reloadNeedTicks(self) -- 1626
	return RELOAD_ANSWER_TICKS + 60 * self:talentRank("focus") -- 1627
end -- 1626
function Play.prototype.getStoryTalentOffers(self) -- 1631
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1631
		return {} -- 1633
	end -- 1633
	local st = self.run.story.talents -- 1635
	return st ~= nil and st.room == self.room.key and st.offers or ({}) -- 1636
end -- 1631
function Play.prototype.getStoryTalentRanks(self) -- 1640
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() then -- 1640
		return nil -- 1642
	end -- 1642
	return self.run.story.talents ~= nil and self.run.story.talents.ranks or nil -- 1644
end -- 1640
function Play.prototype.getEscortAttempt(self) -- 1648
	return self.run.story.talents ~= nil and math.max(1, self.run.story.talents.attempt) or 1 -- 1649
end -- 1648
function Play.prototype.chooseTalent(self, slot) -- 1652
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1652
		return false -- 1654
	end -- 1654
	local st = self.run.story.talents -- 1656
	local talent = st ~= nil and st.offers[slot + 1] or nil -- 1657
	if st == nil or talent == nil then -- 1657
		return false -- 1659
	end -- 1659
	st.ranks[talent] = (st.ranks[talent] or 0) + 1 -- 1661
	st.offers = {} -- 1662
	self.talentModalActive = false -- 1663
	local extraMsg = "" -- 1664
	if talent == "vitality" then -- 1664
		self.maxHp = self.maxHp + 1 -- 1666
		self.hp = self.hp + 1 -- 1667
		self.run.story.maxHp = self.maxHp -- 1668
		self.run.story.hp = self.hp -- 1669
	elseif talent == "salvage" then -- 1669
		local inv = self.run.inventory -- 1671
		if inv.wood < 2 and inv.wood <= inv.bell or inv.bell >= 1 and st.ranks.salvage % 2 == 1 then -- 1671
			inv.wood = inv.wood + 1 -- 1673
			extraMsg = " · 得木纹筹×1" -- 1674
		else -- 1674
			inv.bell = inv.bell + 1 -- 1676
			extraMsg = " · 得铃纹筹×1" -- 1677
		end -- 1677
		self:syncCraftBench() -- 1679
	end -- 1679
	self.sessionDirty = true -- 1681
	self:flashSet(("本领 · " .. talentNames[talent]) .. extraMsg, 1.5) -- 1682
	self:emit("storyBeat", {beat = "talent_picked", talent = talent, rank = st.ranks[talent], room = self.room.key}) -- 1683
	return true -- 1684
end -- 1652
function Play.prototype.beginReload(self) -- 1691
	self.reloadT = self:reloadTicks() -- 1692
	local camp = self.room.campaign -- 1693
	if camp ~= nil and camp.reloadPuzzle == true then -- 1693
		self:openReloadPuzzle() -- 1695
	end -- 1695
end -- 1691
function Play.prototype.openReloadPuzzle(self) -- 1700
	self.reloadOpen = true -- 1701
	self.reloadAnswerTicks = 0 -- 1702
	self.reloadWorldTicks = 0 -- 1703
	self.reloadPath = {RELOAD_START} -- 1704
	self.reloadPendingEffect = "" -- 1705
	self.reloadTryCount = self.reloadTryCount + 1 -- 1706
	self:emit( -- 1707
		"reloadOpen", -- 1707
		{ -- 1707
			tryCount = self.reloadTryCount, -- 1707
			needTicks = self:reloadNeedTicks() -- 1707
		} -- 1707
	) -- 1707
end -- 1700
function Play.prototype.closeReloadPuzzle(self) -- 1711
	self.reloadOpen = false -- 1712
	self.reloadAnswerTicks = 0 -- 1713
	self.reloadWorldTicks = 0 -- 1714
	self.reloadPath = {RELOAD_START} -- 1715
	self.reloadPendingEffect = "" -- 1716
end -- 1711
function Play.prototype.reloadTapNode(self, node) -- 1723
	if not self.reloadOpen then -- 1723
		return -- 1725
	end -- 1725
	local path = self.reloadPath -- 1727
	local last = path[#path] -- 1728
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1728
		self.reloadPath = {RELOAD_START} -- 1730
		self:emit("reloadInvalid", {node = node, at = last}) -- 1731
		return -- 1732
	end -- 1732
	path[#path + 1] = node -- 1734
	if node ~= RELOAD_TARGET then -- 1734
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1736
		return -- 1737
	end -- 1737
	if not reloadPathValid(path) then -- 1737
		self.reloadPath = {RELOAD_START} -- 1740
		self:emit("reloadInvalid", {node = node, at = last}) -- 1741
		return -- 1742
	end -- 1742
	self.reloadPendingEffect = reloadEffectOf(path) -- 1744
	self.reloadOpen = false -- 1745
	self.reloadT = 0 -- 1746
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1747
	self:flashSet( -- 1750
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1750
		1.4 -- 1750
	) -- 1750
end -- 1723
function Play.prototype.consumeReloadEffect(self) -- 1754
	local e = self.reloadPendingEffect -- 1755
	if e ~= "" then -- 1755
		self.reloadPendingEffect = "" -- 1757
	end -- 1757
	return e -- 1759
end -- 1754
function Play.prototype.echoToSource(self, from, count, delayTicks) -- 1766
	if count == nil then -- 1766
		count = 1 -- 1766
	end -- 1766
	if delayTicks == nil then -- 1766
		delayTicks = 60 -- 1766
	end -- 1766
	local best = -1 -- 1767
	local bestD = 1000000000 -- 1768
	local i = 0 -- 1769
	local woken = {} -- 1770
	local n = 0 -- 1771
	while n < count do -- 1771
		best = -1 -- 1773
		bestD = 1000000000 -- 1774
		do -- 1774
			i = 0 -- 1775
			while i < #self.enemies do -- 1775
				do -- 1775
					if woken[i] == true then -- 1775
						goto __continue212 -- 1777
					end -- 1777
					local e = self.enemies[i + 1] -- 1779
					if not e.alive then -- 1779
						goto __continue212 -- 1781
					end -- 1781
					local d = math.abs(e.x - from.x) -- 1783
					if d < bestD then -- 1783
						bestD = d -- 1785
						best = i -- 1786
					end -- 1786
				end -- 1786
				::__continue212:: -- 1786
				i = i + 1 -- 1775
			end -- 1775
		end -- 1775
		if best < 0 then -- 1775
			break -- 1790
		end -- 1790
		woken[best] = true -- 1792
		local e = self.enemies[best + 1] -- 1793
		e.awake = true -- 1794
		e.warnT = 0 -- 1795
		e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 1796
		n = n + 1 -- 1797
	end -- 1797
	if n == 0 then -- 1797
		return -- 1800
	end -- 1800
	self:flashSet(n > 1 and "回声引到多处声源 · 敌群同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1802
end -- 1766
function Play.prototype.reloadTicks(self) -- 1805
	return math.max(6, self.run.inventory.quickbelt > 0 and 36 or 54) -- 1806
end -- 1805
function Play.prototype.update(self, dt, input) -- 1809
	self:syncCraftBench() -- 1810
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1810
		self:closeCraftBench() -- 1812
		return -- 1813
	end -- 1813
	if input.pause.pressed then -- 1813
		self.paused = not self.paused -- 1816
	end -- 1816
	if self.flashT > 0 then -- 1816
		self.flashT = self.flashT - dt -- 1819
		if self.flashT <= 0 then -- 1819
			self.flash = "" -- 1821
		end -- 1821
	end -- 1821
	if self.traceT > 0 then -- 1821
		self.traceT = self.traceT - dt -- 1825
		if self.traceT <= 0 then -- 1825
			self.trace = nil -- 1827
		end -- 1827
	end -- 1827
	if self.paused then -- 1827
		self:updateCamera(dt) -- 1831
		return -- 1832
	end -- 1832
	if self.escortFailed then -- 1832
		self.escortFailedTicks = self.escortFailedTicks + 1 -- 1836
		self:updateCamera(dt) -- 1837
		return -- 1838
	end -- 1838
	if self.craftBench.active then -- 1838
		self:updateCamera(dt) -- 1843
		return -- 1844
	end -- 1844
	if self.talentModalActive and #self:getStoryTalentOffers() > 0 and not self.reloadOpen then -- 1844
		self:updateCamera(dt) -- 1848
		return -- 1849
	end -- 1849
	if self.reloadOpen then -- 1849
		local needTicks = self:reloadNeedTicks() -- 1855
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1856
		if self.reloadAnswerTicks > needTicks then -- 1856
			self.reloadOpen = false -- 1858
			self.reloadPendingEffect = "" -- 1859
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = needTicks}) -- 1860
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1861
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1861
			self:updateCamera(dt) -- 1863
			return -- 1864
		else -- 1864
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1866
		end -- 1866
	end -- 1866
	self.ticks = self.ticks + 1 -- 1870
	if self.invulnT > 0 then -- 1870
		self.invulnT = self.invulnT - 1 -- 1874
	end -- 1874
	if self.isCampaign then -- 1874
		local ____self_run_86, ____ticks_87 = self.run, "ticks" -- 1874
		____self_run_86[____ticks_87] = ____self_run_86[____ticks_87] + 1 -- 1877
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1878
	end -- 1878
	local p = self.player -- 1880
	self:stepPlayer(p, dt, input) -- 1881
	self:refreshCover(p, input) -- 1883
	if self.carryOn then -- 1883
		self:carryPose() -- 1885
	end -- 1885
	if self.isCampaign then -- 1885
		self:stepCampaign(dt, input) -- 1888
		if not self.carryOn then -- 1888
			self:stepCampaignPartner(dt) -- 1890
		end -- 1890
	end -- 1890
	self:stepEnemies(dt, input) -- 1895
	if not self.isCampaign then -- 1895
		self:stepStory(dt, input) -- 1897
		self:stepEscort(dt, input) -- 1898
		self:stepVillage(dt, input) -- 1899
		self:stepChase(dt, input) -- 1900
		self:stepInteract(dt, input) -- 1901
	end -- 1901
	self:updateGate() -- 1903
	self:updateCamera(dt) -- 1904
	self:syncStory() -- 1906
end -- 1809
function Play.prototype.underLowArch(self, a) -- 1913
	local arch = self.room.arch -- 1914
	if arch.h <= 0 then -- 1914
		return false -- 1916
	end -- 1916
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1916
		return false -- 1919
	end -- 1919
	local top = arch.y + arch.h -- 1921
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1922
end -- 1913
function Play.prototype.coverAt(self, a) -- 1929
	local best = nil -- 1930
	local bestGap = 24 -- 1931
	local half = a.w / 2 -- 1932
	local i = 0 -- 1933
	do -- 1933
		i = 0 -- 1934
		while i < #self.boxes do -- 1934
			do -- 1934
				local b = self.boxes[i + 1] -- 1935
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1935
					goto __continue245 -- 1937
				end -- 1937
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1937
					goto __continue245 -- 1940
				end -- 1940
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1942
				if gap < bestGap then -- 1942
					bestGap = gap -- 1944
					best = b -- 1945
				end -- 1945
			end -- 1945
			::__continue245:: -- 1945
			i = i + 1 -- 1934
		end -- 1934
	end -- 1934
	return best -- 1948
end -- 1929
function Play.prototype.nearCover(self, a) -- 1951
	return self:coverAt(a) ~= nil -- 1952
end -- 1951
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1956
	if enemy == nil then -- 1956
		return false -- 1958
	end -- 1958
	local fromRight = enemy.x >= a.x -- 1960
	local edge = fromRight and b.x0 or b.x1 -- 1961
	local ____fromRight_88 -- 1962
	if fromRight then -- 1962
		____fromRight_88 = edge >= a.x - 0.001 and edge <= enemy.x -- 1962
	else -- 1962
		____fromRight_88 = edge <= a.x + 0.001 and edge >= enemy.x -- 1963
	end -- 1963
	local between = ____fromRight_88 -- 1962
	local separation = enemy.x - a.x -- 1964
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1965
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1966
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1967
end -- 1956
function Play.prototype.nearestEnemy(self, a) -- 1970
	local best -- 1971
	local bestD = 1000000000 -- 1972
	local i = 0 -- 1973
	do -- 1973
		i = 0 -- 1974
		while i < #self.enemies do -- 1974
			do -- 1974
				local e = self.enemies[i + 1] -- 1975
				if not e.alive then -- 1975
					goto __continue254 -- 1977
				end -- 1977
				local d = math.abs(e.x - a.x) -- 1979
				if d < bestD then -- 1979
					bestD = d -- 1981
					best = e -- 1982
				end -- 1982
			end -- 1982
			::__continue254:: -- 1982
			i = i + 1 -- 1974
		end -- 1974
	end -- 1974
	return best -- 1985
end -- 1970
function Play.prototype.refreshCover(self, a, input) -- 1989
	if self.childMode then -- 1989
		self.coverNear = false -- 1991
		self.coverHug = false -- 1992
		self.coverEntity = "" -- 1993
		self.coverBlocking = false -- 1994
		a.covered = false -- 1995
		return -- 1996
	end -- 1996
	local b = self:coverAt(a) -- 1998
	self.coverNear = b ~= nil -- 1999
	a.covered = self.coverNear and input.cover.held -- 2000
	self.coverHug = a.covered -- 2001
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 2002
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 2003
		b, -- 2003
		a, -- 2003
		self:nearestEnemy(a) -- 2003
	) -- 2003
end -- 1989
function Play.prototype.cartHandleInReach(self, a) -- 2007
	if a == nil then -- 2007
		a = self.player -- 2007
	end -- 2007
	local c = self.room.cart -- 2008
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 2008
		return false -- 2010
	end -- 2010
	local handleX = self.cartAxle + c.handleOffset -- 2012
	local ____table_childMode_89 -- 2013
	if self.childMode then -- 2013
		____table_childMode_89 = math.abs(a.depth - (c.depth or 0)) <= 48 -- 2014
	else -- 2014
		____table_childMode_89 = inReachDepth(a.depth, c.depth or 0) -- 2015
	end -- 2015
	local depthOk = ____table_childMode_89 -- 2013
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and depthOk -- 2016
end -- 2007
function Play.prototype.nearLowLedge(self, a) -- 2021
	local reach = 26 -- 2022
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 2023
	local x1 = x0 + reach -- 2024
	local i = 0 -- 2025
	do -- 2025
		i = 0 -- 2026
		while i < #self.boxes do -- 2026
			do -- 2026
				local b = self.boxes[i + 1] -- 2027
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2027
					goto __continue263 -- 2029
				end -- 2029
				local rise = b.y1 - a.y -- 2031
				if rise > 0 and rise <= LEDGE_RISE then -- 2031
					return true -- 2033
				end -- 2033
			end -- 2033
			::__continue263:: -- 2033
			i = i + 1 -- 2026
		end -- 2026
	end -- 2026
	return false -- 2036
end -- 2021
function Play.prototype.stepPlayer(self, a, dt, input) -- 2039
	a.depthSpeed = 0 -- 2040
	if not a.alive then -- 2040
		return -- 2042
	end -- 2042
	local isChild = self.childMode -- 2044
	local lowArch = isChild and self:underLowArch(a) -- 2046
	if self:storyLocked() then -- 2046
		a.vx = 0 -- 2049
		a.crouch = isChild and lowArch -- 2050
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2051
		self:fallY(a, dt) -- 2052
		return -- 2053
	end -- 2053
	if not isChild and self.escort.state == "calming" then -- 2053
		a.crouch = false -- 2057
		a.h = SOLDIER_H -- 2058
		a.vx = 0 -- 2059
		self:fallY(a, dt) -- 2060
		return -- 2061
	end -- 2061
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 2063
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 2064
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2065
	local nearCover = not isChild and self:nearCover(a) -- 2066
	a.covered = nearCover and input.cover.held -- 2067
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 2069
	if a.rollT > 0 then -- 2069
		a.rollT = a.rollT - dt -- 2073
		local rollSpd = self:isEscortRoom() and ROLL_SPEED * (1 + 0.08 * self:talentRank("stride")) or ROLL_SPEED -- 2074
		a.vx = a.facing * rollSpd -- 2075
		self:slideX(a, a.vx * dt) -- 2076
		self:fallY(a, dt) -- 2077
		if a.rollT <= 0 then -- 2077
			self:flashSet("翻滚结束", 0.5) -- 2079
		end -- 2079
		return -- 2081
	end -- 2081
	local peacefulRoom = self.room.key == "museum" or self.room.key == "tower" -- 2084
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 2084
		if input.moveX ~= 0 then -- 2084
			a.facing = input.moveX > 0 and 1 or -1 -- 2087
		end -- 2087
		if self:nearLowLedge(a) then -- 2087
			a.vy = SOLDIER_JUMP -- 2091
			a.onGround = false -- 2092
			self:flashSet("翻上去", 0.3) -- 2093
			return -- 2094
		end -- 2094
		a.rollT = ROLL_TIME -- 2096
		self:flashSet("翻滚", 0.3) -- 2097
		return -- 2098
	end -- 2098
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 2101
	if isChild then -- 2101
		if input.cover.held then -- 2101
			speed = CHILD_SLOW -- 2104
		end -- 2104
		if a.crouch then -- 2104
			speed = CHILD_SLOW -- 2107
		elseif self.room.key == "forest" and self.forestPath == "ditch" and a.x >= self.ox + 700 and a.x <= self.ox + 1140 then -- 2107
			speed = CHILD_SPEED * 1.22 -- 2111
		end -- 2111
	else -- 2111
		if self:isEscortRoom() then -- 2111
			speed = speed * (1 + 0.1 * self:talentRank("stride")) -- 2115
		end -- 2115
		if a.covered then -- 2115
			speed = speed * 0.45 -- 2118
		end -- 2118
	end -- 2118
	local handsBusy = self.gripping or gripIntent or self.reloadOpen -- 2123
	local dir = (self.gripping or self.reloadOpen) and 0 or input.moveX -- 2124
	local depthDir = self.room.depth ~= nil and not handsBusy and -input.moveY or 0 -- 2126
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 2127
	if dir ~= 0 then -- 2127
		a.facing = dir > 0 and 1 or -1 -- 2129
	end -- 2129
	a.vx = dir * speed * diagonal -- 2131
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 2131
		a.vy = CHILD_JUMP -- 2135
		a.onGround = false -- 2136
		self:flashSet("跳", 0.25) -- 2137
	end -- 2137
	local previousDepth = a.depth -- 2141
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 2142
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2143
	self:slideX(a, a.vx * dt) -- 2144
	self:fallY(a, dt) -- 2145
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and not self.reloadOpen and input.fire.pressed then -- 2145
		self:shoot(a) -- 2149
	end -- 2149
	local wantManualReload = input.flare.pressed or input:isKbmMode() and input.uiRightPressed -- 2152
	local ____temp_92 = not isChild and not peacefulRoom and not self.gripping and not self.reloadOpen and self.reloadPendingEffect == "" -- 2153
	if ____temp_92 then -- 2153
		local ____opt_90 = self.room.campaign -- 2153
		____temp_92 = (____opt_90 and ____opt_90.reloadPuzzle) == true -- 2153
	end -- 2153
	if ____temp_92 and wantManualReload then -- 2153
		input.uiRightPressed = false -- 2155
		self:beginReload() -- 2156
	end -- 2156
end -- 2039
function Play.prototype.stepPartner(self, p, dt) -- 2161
	local a = self.partner -- 2162
	if not a.alive then -- 2162
		return -- 2164
	end -- 2164
	a.crouch = false -- 2166
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 2167
	a.vx = 0 -- 2168
	a.depthSpeed = 0 -- 2169
	self:fallY(a, dt) -- 2170
end -- 2161
function Play.prototype.stepEscort(self, dt, input) -- 2177
	local a = self.partner -- 2178
	a.depthSpeed = 0 -- 2179
	if not a.alive then -- 2179
		return -- 2181
	end -- 2181
	if self.room.key == "gatepath" then -- 2181
		if self.carryOn then -- 2181
			return -- 2186
		end -- 2186
		local p = self.player -- 2189
		a.depth = p.depth -- 2190
		a.facing = p.facing -- 2191
		a.crouch = false -- 2192
		a.h = CHILD_H -- 2193
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 2194
		a.y = p.y -- 2195
		a.vy = 0 -- 2196
		a.vx = p.vx -- 2197
		a.onGround = p.onGround -- 2198
		return -- 2199
	end -- 2199
	if not self:escortOn() then -- 2199
		a.vx = 0 -- 2202
		self:fallY(a, dt) -- 2203
		return -- 2204
	end -- 2204
	local p = self.player -- 2206
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 2207
	local hadKnock1 = self.escort.knock1 -- 2208
	local hadKnock2 = self.escort.knock2 -- 2209
	self.calmConsumed = self.escort:update( -- 2210
		input, -- 2210
		p.x, -- 2210
		p.facing, -- 2210
		a.x, -- 2210
		dist -- 2210
	) -- 2210
	if not hadKnock1 and self.escort.knock1 then -- 2210
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 2213
	end -- 2213
	if not hadKnock2 and self.escort.knock2 then -- 2213
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 2216
	end -- 2216
	a.crouch = self.escort.crouchPose -- 2218
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 2219
	if not self.escort.stopped then -- 2219
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 2221
		local previousDepth = a.depth -- 2222
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 2223
		local distance = math.max( -- 2224
			-travel, -- 2224
			math.min(travel, targetDepth - previousDepth) -- 2224
		) -- 2224
		self:slideDepth(a, distance) -- 2225
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2226
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 2226
			a.vy = CHILD_JUMP -- 2228
			a.onGround = false -- 2229
		end -- 2229
	end -- 2229
	local dir = self.escort:moveDir(a.x) -- 2232
	a.vx = dir * CHILD_SPEED -- 2233
	if dir ~= 0 then -- 2233
		a.facing = dir -- 2235
		local before = a.x -- 2236
		self:slideX(a, dir * CHILD_SPEED * dt) -- 2237
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 2237
			a.vy = CHILD_JUMP -- 2240
			a.onGround = false -- 2241
		end -- 2241
	end -- 2241
	self:fallY(a, dt) -- 2244
end -- 2177
function Play.prototype.escortOn(self) -- 2248
	if self.room.key == "checkpoint" then -- 2248
		return true -- 2250
	end -- 2250
	if self.room.key == "gatepath" then -- 2250
		return true -- 2253
	end -- 2253
	if self.room.key == "prologue" then -- 2253
		return self.phase == "prologue-follow" -- 2256
	end -- 2256
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 2256
		return true -- 2260
	end -- 2260
	return self.room.key == "street" -- 2262
end -- 2248
function Play.prototype.storyLocked(self) -- 2266
	if self.caughtT > 0 then -- 2266
		return true -- 2268
	end -- 2268
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 2268
		return true -- 2272
	end -- 2272
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 2272
		return true -- 2275
	end -- 2275
	if self.room.key == "gate" and (self.phase == "gate-farewell" or self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 2275
		return true -- 2278
	end -- 2278
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2278
		return true -- 2281
	end -- 2281
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2281
		return true -- 2284
	end -- 2284
	if self.craftBench.active then -- 2284
		return true -- 2288
	end -- 2288
	return false -- 2290
end -- 2266
function Play.prototype.swapToChild(self, x) -- 2294
	local tmp = self.player -- 2295
	self.player = self.partner -- 2296
	self.partner = tmp -- 2297
	self.childMode = true -- 2298
	self.player.alive = true -- 2299
	self.player.x = self.ox + x -- 2300
	self.player.y = 0 -- 2301
	self.player.depth = 0 -- 2302
	self.player.depthSpeed = 0 -- 2303
	self.player.vy = 0 -- 2304
	self.player.vx = 0 -- 2305
	self.player.onGround = true -- 2306
	self.player.crouch = false -- 2307
	self.player.h = CHILD_H -- 2308
	self.player.facing = 1 -- 2309
	self.partner.alive = true -- 2310
	self.cam.x = self.player.x -- 2311
end -- 2294
function Play.prototype.swapToSoldier(self, x, childX) -- 2315
	local tmp = self.player -- 2316
	self.player = self.partner -- 2317
	self.partner = tmp -- 2318
	self.childMode = false -- 2319
	self.player.alive = true -- 2320
	self.player.x = self.ox + x -- 2321
	self.player.y = 0 -- 2322
	self.player.depth = 0 -- 2323
	self.player.depthSpeed = 0 -- 2324
	self.player.vy = 0 -- 2325
	self.player.vx = 0 -- 2326
	self.player.onGround = true -- 2327
	self.player.crouch = false -- 2328
	self.player.h = SOLDIER_H -- 2329
	self.player.facing = 1 -- 2330
	self.partner.alive = true -- 2331
	self.partner.x = self.ox + childX -- 2332
	self.partner.y = 0 -- 2333
	self.partner.depth = 0 -- 2334
	self.partner.depthSpeed = 0 -- 2335
	self.partner.vx = 0 -- 2336
	self.partner.vy = 0 -- 2337
	self.partner.onGround = true -- 2338
	self.partner.crouch = true -- 2339
	self.partner.h = CHILD_CROUCH_H -- 2340
	self.cam.x = self.player.x -- 2341
end -- 2315
function Play.prototype.stepStory(self, dt, input) -- 2345
	if self.room.key == "prologue" then -- 2345
		self:stepPrologue(dt, input) -- 2347
	elseif self.room.key == "street" then -- 2347
		self:stepStreet(dt, input) -- 2349
	elseif self.room.key == "gate" then -- 2349
		self:stepGate(dt, input) -- 2351
	elseif self.room.key == "gatepath" then -- 2351
		self:stepGatePath() -- 2353
	elseif self.room.key == "tower" then -- 2353
		self:stepTower(dt, input) -- 2355
	elseif self.room.key == "museum" then -- 2355
		self:stepMuseum(dt, input) -- 2357
	end -- 2357
end -- 2345
function Play.prototype.canPersistProgress(self) -- 2363
	return not self.isCampaign and self.run.source == "official" -- 2364
end -- 2363
function Play.prototype.wellWindow(self) -- 2368
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 2369
end -- 2368
function Play.prototype.nearWell(self) -- 2374
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 2375
end -- 2374
function Play.prototype.pickWell(self) -- 2383
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2383
		return false -- 2385
	end -- 2385
	self.phase = "prologue-well" -- 2387
	self.phaseTick = 0 -- 2388
	self.wellOpen = false -- 2389
	self:flashSet("井沿 · 伸手下去", 1.4) -- 2390
	self:log("旧井拾取") -- 2391
	return true -- 2392
end -- 2383
function Play.prototype.stepPrologue(self, dt, input) -- 2395
	local child = self.partner -- 2396
	if self.museumReturn then -- 2396
		self.museumReturn = false -- 2399
		self.phase = "prologue-wait" -- 2400
		self.phaseTick = 0 -- 2401
		self.player.x = self.ox + 260 -- 2402
		self.player.y = 0 -- 2403
		self.player.depth = 0 -- 2404
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2405
	end -- 2405
	if self.phase == "prologue-wake" then -- 2405
		self.introTick = self.introTick + 1 -- 2409
		if self.introTick == 60 then -- 2409
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2411
		end -- 2411
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2411
			self.phase = "prologue-shadow" -- 2414
			self.introTick = 0 -- 2415
			self:flashSet("门缝里两道影子", 1.2) -- 2416
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2417
		end -- 2417
		return -- 2419
	end -- 2419
	if self.phase == "prologue-shadow" then -- 2419
		self.introTick = self.introTick + 1 -- 2422
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2422
			self.phase = "prologue-escape" -- 2425
			self.introTick = 0 -- 2426
			self.escapeRemaining = self.escapeDuration -- 2427
			self.escapeRetryCount = 0 -- 2428
			self:swapToChild(100) -- 2429
			self:flashSet( -- 2430
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2430
				1.6 -- 2430
			) -- 2430
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2431
		end -- 2431
		return -- 2435
	end -- 2435
	if self.phase == "prologue-escape" then -- 2435
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2438
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2438
			self.phase = "prologue-hide" -- 2441
			self.introTick = 0 -- 2442
			self.player.vx = 0 -- 2443
			self.player.crouch = true -- 2444
			self.player.h = CHILD_CROUCH_H -- 2445
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2446
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2447
			return -- 2451
		end -- 2451
		if self.escapeRemaining <= 0 then -- 2451
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2455
			self.player.x = self.ox + 100 -- 2456
			self.player.y = 0 -- 2457
			self.player.depth = 0 -- 2458
			self.player.vx = 0 -- 2459
			self.player.vy = 0 -- 2460
			self.escapeRemaining = self.escapeDuration -- 2461
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2462
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2463
			return -- 2464
		end -- 2464
		return -- 2466
	end -- 2466
	if self.phase == "prologue-hide" then -- 2466
		self.introTick = self.introTick + 1 -- 2469
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2469
			self.phase = "prologue-wait" -- 2472
			self.phaseTick = 0 -- 2473
			self.introTick = 0 -- 2474
			self:swapToSoldier(260, 300) -- 2475
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2476
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2477
		end -- 2477
		return -- 2479
	end -- 2479
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2482
	if self.phase == "prologue-wait" then -- 2482
		child.crouch = true -- 2484
		child.h = CHILD_CROUCH_H -- 2485
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2485
			self:pickWell() -- 2487
			return -- 2488
		end -- 2488
		if not self.wellOpen and self:canPersistProgress() and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2488
			self.archive.museumPhase = "well_reflect" -- 2493
			self.archiveDirty = true -- 2494
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2495
			return -- 2496
		end -- 2496
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2498
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2500
		if near and input.interact.pressed then -- 2500
			self.phase = "prologue-give" -- 2502
			self.phaseTick = 0 -- 2503
			self:flashSet("递出针套", 1) -- 2504
		end -- 2504
		return -- 2506
	end -- 2506
	if self.phase == "prologue-well" then -- 2506
		self.phaseTick = self.phaseTick + 1 -- 2510
		if self.phaseTick == 12 then -- 2510
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2512
		elseif self.phaseTick >= 30 then -- 2512
			self.phase = "prologue-wait" -- 2514
			self.phaseTick = 0 -- 2515
			self.wellTaken = true -- 2516
			self.wellOpen = false -- 2517
			self.run.archive.artifactOwned = true -- 2518
			self.archiveDirty = true -- 2519
			self:emit("artifactFound", { -- 2520
				x = self.ox + self.wellX, -- 2521
				y = 0, -- 2521
				room = "prologue", -- 2521
				once = true, -- 2521
				source = self.run.source -- 2522
			}) -- 2522
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2524
			self:log("井底取到时间穿梭器") -- 2525
		end -- 2525
		return -- 2527
	end -- 2527
	if self.phase == "prologue-give" then -- 2527
		self.phaseTick = self.phaseTick + 1 -- 2530
		if self.phaseTick == 36 then -- 2530
			self:flashSet("针套递过去", 0.9) -- 2532
		elseif self.phaseTick == 108 then -- 2532
			self:flashSet("纸条塞进针套", 1) -- 2534
		elseif self.phaseTick >= ____exports.PROLOGUE_GIVE_TICKS then -- 2534
			self.phase = "prologue-follow" -- 2536
			self.phaseTick = 0 -- 2537
			child.crouch = false -- 2538
			child.h = CHILD_H -- 2539
			self:flashSet("她跟上了", 1.2) -- 2540
		end -- 2540
		return -- 2542
	end -- 2542
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2542
		local next = self.run.source == "debug" and "street" or "s1-crossroad" -- 2546
		self:requestRoom(next, "序章跟到门口") -- 2547
		self:flashSet(next == "s1-crossroad" and "进十字街" or "进街道", 1.2) -- 2548
	end -- 2548
end -- 2395
function Play.prototype.stepStreet(self, dt, input) -- 2553
	local p = self.player -- 2554
	local c = self.partner -- 2555
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2555
		local next = self.run.source == "debug" and "checkpoint" or "s1-crossroad" -- 2557
		self:requestRoom(next, "两人都到街尾") -- 2558
		self:flashSet(next == "s1-crossroad" and "进十字街" or "到检查站", 1.2) -- 2559
	end -- 2559
end -- 2553
function Play.prototype.stepGate(self, dt, input) -- 2564
	local ____temp_93 -- 2565
	if self.room.story == nil then -- 2565
		____temp_93 = nil -- 2565
	else -- 2565
		____temp_93 = self.room.story.gate -- 2565
	end -- 2565
	local g = ____temp_93 -- 2565
	if g == nil then -- 2565
		return -- 2567
	end -- 2567
	local p = self.player -- 2569
	if self.phase == "gate-idle" then -- 2569
		local a = self.partner -- 2572
		local gap = g.waitX - a.x -- 2573
		if math.abs(gap) > 3 then -- 2573
			a.facing = gap > 0 and 1 or -1 -- 2575
			a.vx = a.facing * CHILD_SPEED -- 2576
			local beforeX = a.x -- 2577
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2578
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2578
				a.vy = CHILD_JUMP -- 2580
				a.onGround = false -- 2581
			end -- 2581
			self:fallY(a, dt) -- 2583
		else -- 2583
			a.vx = 0 -- 2585
			a.x = g.waitX -- 2586
		end -- 2586
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2589
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2590
		if self.gateNeedConfirm then -- 2590
			if not input.interact.held then -- 2590
				self.gateRestartArmed = true -- 2595
			end -- 2595
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2595
				self.gateNeedConfirm = false -- 2598
				self.gateRestartArmed = true -- 2599
				self.phase = "gate-hold" -- 2600
				self.gateTick = 0 -- 2601
				self.gateSpawned = 0 -- 2602
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2603
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2604
			end -- 2604
			return -- 2606
		end -- 2606
		if atWinch and atWait then -- 2606
			self.phase = "gate-hold" -- 2609
			self.gateTick = 0 -- 2610
			self.gateSpawned = 0 -- 2611
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2612
		end -- 2612
		return -- 2614
	end -- 2614
	if self.phase == "gate-hold" then -- 2614
		self.gateTick = self.gateTick + 1 -- 2617
		local marks = {0, 540, 900, 1500} -- 2619
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2619
			local idx = self.gateSpawned -- 2621
			local ____self_enemies_94 = self.enemies -- 2621
			____self_enemies_94[#____self_enemies_94 + 1] = { -- 2622
				x = self.ox + 620 + idx * 62, -- 2623
				y = 0, -- 2623
				w = 26, -- 2623
				h = 84, -- 2623
				alive = true, -- 2624
				hitT = 0, -- 2624
				warnT = 0, -- 2624
				fireCd = 90 + idx * 45 -- 2624
			} -- 2624
			self.gateSpawned = self.gateSpawned + 1 -- 2626
			self:flashSet( -- 2627
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2627
				0.9 -- 2627
			) -- 2627
		end -- 2627
		if self.gateTick == 900 then -- 2627
			self:flashSet("棚布落下", 1) -- 2630
		elseif self.gateTick == 2100 then -- 2630
			self:flashSet("门底透进冷光了", 1) -- 2632
		end -- 2632
		if self.gateTick >= g.holdTicks then -- 2632
			self:captureGateBlood() -- 2637
			self.phase = "gate-send" -- 2638
			self.phaseTick = 0 -- 2639
			self.enemies = {} -- 2641
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2642
		end -- 2642
		return -- 2644
	end -- 2644
	if self.phase == "gate-send" then -- 2644
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2647
		if near and input.interact.pressed then -- 2647
			self:commitRoute() -- 2651
			self:swapToChild(g.doorX + 30) -- 2652
			self.phase = self.run.source == "debug" and "gate-count" or "gate-farewell" -- 2653
			self.phaseTick = 0 -- 2654
			self.countTick = 0 -- 2655
			self.countArmed = false -- 2657
			self.countPrevMove = input.moveX -- 2658
			self:flashSet("门开了 · 送她出去", 1.8) -- 2659
		end -- 2659
		return -- 2661
	end -- 2661
	if self.phase == "gate-farewell" then -- 2661
		self.phaseTick = self.phaseTick + 1 -- 2664
		self.countPrevMove = input.moveX -- 2665
		if self.phaseTick >= ____exports.GATE_FAREWELL_TICKS then -- 2665
			self.phase = "gate-count" -- 2667
			self.phaseTick = 0 -- 2668
			self.countTick = 0 -- 2669
			self.countArmed = false -- 2670
		end -- 2670
		return -- 2672
	end -- 2672
	if self.phase == "gate-count" then -- 2672
		self.countTick = self.countTick + 1 -- 2675
		if self.countTick == 360 then -- 2675
			self:flashSet("门关上", 0.9) -- 2677
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2677
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2679
			if self.storyRoute == "soldier" then -- 2679
				self.phase = "gate-wait" -- 2685
				self.phaseTick = 0 -- 2686
				self.knocks = 1 -- 2687
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2688
				self.handArmed = not input.interact.held and not self.intentGateReunionHold -- 2690
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2691
			else -- 2691
				self:flashSet("数到二十", 2.2) -- 2693
			end -- 2693
		end -- 2693
		local prevMove = self.countPrevMove -- 2698
		self.countPrevMove = input.moveX -- 2699
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2699
			if prevMove <= 0 and input.moveX > 0 then -- 2699
				self.countArmed = true -- 2702
			end -- 2702
			if self.countArmed and input.moveX > 0 then -- 2702
				self.phase = "gate-walk" -- 2705
				self.phaseTick = 0 -- 2706
				self:flashSet("她迈出第一步", 1.4) -- 2707
				self:emit("storyExit", { -- 2708
					route = "child", -- 2708
					via = "walk", -- 2708
					countTick = self.countTick, -- 2708
					hp = self.hp, -- 2708
					maxHp = self.maxHp -- 2708
				}) -- 2708
			end -- 2708
		end -- 2708
		return -- 2711
	end -- 2711
	if self.phase == "gate-wait" then -- 2711
		self.phaseTick = self.phaseTick + 1 -- 2715
		if self.phaseTick == 12 then -- 2715
			self.knocks = 2 -- 2717
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2718
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2719
		end -- 2719
		local held = input.interact.held or self.intentGateReunionHold -- 2721
		if not held then -- 2721
			if self.handTicks > 0 then -- 2721
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2724
			end -- 2724
			self.handTicks = 0 -- 2726
			self.handArmed = true -- 2727
			return -- 2728
		end -- 2728
		if self.handArmed then -- 2728
			self.handTicks = self.handTicks + 1 -- 2731
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2731
				self.intentGateReunionHold = false -- 2733
				self.phase = "gate-hand" -- 2734
				self.phaseTick = 0 -- 2735
				self.handDone = true -- 2736
				self.tied = true -- 2737
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2738
				if not self.lineSaid then -- 2738
					self.lineSaid = true -- 2740
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2741
				end -- 2741
				self:flashSet("我们走吧。", 3) -- 2743
			end -- 2743
		end -- 2743
		return -- 2746
	end -- 2746
	if self.phase == "gate-hand" then -- 2746
		self.phaseTick = self.phaseTick + 1 -- 2750
		if self.phaseTick == 30 then -- 2750
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2752
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2752
			self:emit("storyExit", { -- 2754
				route = "soldier", -- 2754
				via = "hand", -- 2754
				handTicks = self.handTicks, -- 2754
				hp = self.hp, -- 2754
				maxHp = self.maxHp -- 2754
			}) -- 2754
			self:requestRoom("gatepath", "牵手同行") -- 2755
		end -- 2755
		return -- 2757
	end -- 2757
	if self.phase == "gate-walk" then -- 2757
		if self.player.x >= g.exitX then -- 2757
			self:requestRoom("outside", "走出城门") -- 2762
			self:flashSet("出城门 · 城外", 1.4) -- 2763
		end -- 2763
	end -- 2763
end -- 2564
function Play.prototype.captureGateBlood(self) -- 2772
	self.hpAtGate = self.hp -- 2773
	self.maxHpAtGate = self.maxHp -- 2774
end -- 2772
function Play.prototype.commitRoute(self) -- 2781
	if self.storySettled then -- 2781
		return -- 2783
	end -- 2783
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2785
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2786
	self.hpAtGate = hp -- 2787
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2788
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2789
	self.storySettled = true -- 2790
	self.sessionDirty = true -- 2791
	self:emit("storyRouteLocked", { -- 2792
		route = self.storyRoute, -- 2793
		hp = self.hp, -- 2793
		maxHp = self.maxHp, -- 2793
		hpAtGate = self.hpAtGate, -- 2794
		maxHpAtGate = self.maxHpAtGate -- 2794
	}) -- 2794
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2796
end -- 2781
function Play.prototype.syncStory(self) -- 2800
	local s = self.run.story -- 2801
	if s == nil then -- 2801
		return -- 2803
	end -- 2803
	s.hp = self.hp -- 2805
	s.maxHp = self.maxHp -- 2806
	s.route = self.storyRoute -- 2807
	s.settled = self.storySettled -- 2808
	s.hpAtGate = self.hpAtGate -- 2809
	s.maxHpAtGate = self.maxHpAtGate -- 2810
	s.handDone = self.handDone -- 2811
	s.lineSaid = self.lineSaid -- 2812
	s.tied = self.tied -- 2813
	s.carry = self.carryOn -- 2814
	s.museumReturn = self.museumReturn -- 2815
	s.escortDone = self.escortDone -- 2816
	s.craftedWeapon = self.run.story.craftedWeapon -- 2817
	s.equippedWeapon = self.equippedWeapon -- 2818
	s.ending = self.run.story.ending -- 2819
	if self.room.key == "gate" then -- 2819
		s.phase = self.phase -- 2821
		s.countTick = self.countTick -- 2822
		s.phaseTick = self.phaseTick -- 2823
		s.handTicks = self.handTicks -- 2824
	end -- 2824
	if self.room.key == "prologue" then -- 2824
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2824
			s.phase = self.phase -- 2829
			s.phaseTick = self.phaseTick -- 2830
		end -- 2830
	end -- 2830
	if self.room.key == "tower" then -- 2830
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2830
			s.phase = self.phase -- 2836
			s.phaseTick = self.phaseTick -- 2837
		end -- 2837
	end -- 2837
end -- 2800
function Play.prototype.stepGatePath(self) -- 2843
	local ____temp_95 -- 2844
	if self.room.story == nil then -- 2844
		____temp_95 = nil -- 2844
	else -- 2844
		____temp_95 = self.room.story.gatepath -- 2844
	end -- 2844
	local gp = ____temp_95 -- 2844
	if self.phase == "gatepath-start" then -- 2844
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2844
			self.carryOn = true -- 2847
			self.phase = "gatepath-carry" -- 2848
			self.phaseTick = 0 -- 2849
			self.pathDone = true -- 2850
			self.escortDone = false -- 2851
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2852
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2853
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2854
		end -- 2854
		return -- 2856
	end -- 2856
	if self.phase == "gatepath-carry" then -- 2856
		self.phaseTick = self.phaseTick + 1 -- 2859
		if self.phaseTick == 20 then -- 2859
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2861
		end -- 2861
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2861
			self:requestRoom(gp.next, "背负进首战") -- 2864
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2865
		end -- 2865
	end -- 2865
end -- 2843
function Play.prototype.carryPose(self) -- 2874
	local p = self.player -- 2875
	local a = self.partner -- 2876
	a.alive = true -- 2877
	a.x = p.x - p.facing * 12 -- 2878
	a.y = p.y + 26 -- 2879
	a.depth = p.depth -- 2880
	a.vx = p.vx -- 2881
	a.vy = 0 -- 2882
	a.onGround = true -- 2883
	a.crouch = false -- 2884
	a.h = CHILD_CROUCH_H -- 2885
	a.facing = p.facing -- 2886
end -- 2874
function Play.prototype.stepMuseum(self, dt, input) -- 2894
	self.partner.alive = false -- 2895
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2896
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2899
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 2900
	local intentTarget = self.pendingMuseumIntentTarget -- 2901
	self.pendingMuseumIntentTarget = "" -- 2902
	local interactHit = input.interact.pressed or intentTarget ~= "" -- 2903
	if self.phase == "museum-cabinet" then -- 2903
		if atCase and interactHit or intentTarget == "cabinet" then -- 2903
			self.phase = "museum-hall" -- 2906
			self.phaseTick = 0 -- 2907
			if self:canPersistProgress() then -- 2907
				self.archive.museumPhase = "hall_walk" -- 2909
				self.archiveDirty = true -- 2910
			end -- 2910
			self:emit( -- 2912
				"museumStep", -- 2912
				{ -- 2912
					step = "cabinet", -- 2912
					x = self.ox + mu.cabinetX, -- 2912
					persisted = self:canPersistProgress() -- 2912
				} -- 2912
			) -- 2912
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2913
		end -- 2913
		return -- 2915
	end -- 2915
	if self.phase == "museum-hall" then -- 2915
		if intentTarget == "lamp_direct" and nearLamp then -- 2915
			self:emit( -- 2919
				"museumStep", -- 2919
				{ -- 2919
					step = "hall", -- 2919
					x = self.ox + mu.hallX, -- 2919
					persisted = self:canPersistProgress() -- 2919
				} -- 2919
			) -- 2919
			self.phase = "museum-return" -- 2920
			self.phaseTick = 0 -- 2921
			if self:canPersistProgress() then -- 2921
				self.archive.museumPhase = "return_cabinet" -- 2923
				self.archiveDirty = true -- 2924
			end -- 2924
			self:emit( -- 2926
				"museumStep", -- 2926
				{ -- 2926
					step = "lamp", -- 2926
					x = self.ox + mu.lampX, -- 2926
					persisted = self:canPersistProgress() -- 2926
				} -- 2926
			) -- 2926
			self:flashSet("灯 · 转向西窗", 1.8) -- 2927
			return -- 2928
		end -- 2928
		if self.player.x >= self.ox + mu.hallX and interactHit then -- 2928
			self.phase = "museum-lamp" -- 2931
			self.phaseTick = 0 -- 2932
			if self:canPersistProgress() then -- 2932
				self.archive.museumPhase = "lamp_turn" -- 2934
				self.archiveDirty = true -- 2935
			end -- 2935
			self:emit( -- 2937
				"museumStep", -- 2937
				{ -- 2937
					step = "hall", -- 2937
					x = self.ox + mu.hallX, -- 2937
					persisted = self:canPersistProgress() -- 2937
				} -- 2937
			) -- 2937
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2938
		end -- 2938
		return -- 2940
	end -- 2940
	if self.phase == "museum-lamp" then -- 2940
		if nearLamp and interactHit then -- 2940
			self.phase = "museum-return" -- 2944
			self.phaseTick = 0 -- 2945
			if self:canPersistProgress() then -- 2945
				self.archive.museumPhase = "return_cabinet" -- 2947
				self.archiveDirty = true -- 2948
			end -- 2948
			self:emit( -- 2950
				"museumStep", -- 2950
				{ -- 2950
					step = "lamp", -- 2950
					x = self.ox + mu.lampX, -- 2950
					persisted = self:canPersistProgress() -- 2950
				} -- 2950
			) -- 2950
			self:flashSet("灯 · 转向西窗", 1.8) -- 2951
		end -- 2951
		return -- 2953
	end -- 2953
	if self.phase == "museum-return" then -- 2953
		if atCase and interactHit or intentTarget == "return_cabinet" then -- 2953
			self.phase = "museum-knock" -- 2957
			self.phaseTick = 0 -- 2958
			self:emit( -- 2959
				"museumStep", -- 2959
				{ -- 2959
					step = "knock", -- 2959
					count = 1, -- 2959
					x = self.ox + mu.cabinetX, -- 2959
					persisted = self:canPersistProgress() -- 2959
				} -- 2959
			) -- 2959
			self:flashSet("回柜边 · 第一下", 0.8) -- 2960
		end -- 2960
		return -- 2962
	end -- 2962
	if self.phase == "museum-knock" then -- 2962
		self.phaseTick = self.phaseTick + 1 -- 2965
		if self.phaseTick == 8 then -- 2965
			self:emit( -- 2967
				"museumStep", -- 2967
				{ -- 2967
					step = "knock", -- 2967
					count = 2, -- 2967
					x = self.ox + mu.cabinetX, -- 2967
					persisted = self:canPersistProgress() -- 2967
				} -- 2967
			) -- 2967
			self:flashSet("回柜边 · 第二下", 0.8) -- 2968
		elseif self.phaseTick >= 36 then -- 2968
			self.phase = "museum-done" -- 2970
			self.phaseTick = 0 -- 2971
			if self:canPersistProgress() then -- 2971
				self.archive.museumSeen = true -- 2973
				self.archive.museumPhase = "done" -- 2974
				self.archiveDirty = true -- 2975
			end -- 2975
			self:emit( -- 2977
				"museumDone", -- 2977
				{ -- 2977
					steps = 4, -- 2977
					museumSeen = self.archive.museumSeen, -- 2977
					persisted = self:canPersistProgress() -- 2977
				} -- 2977
			) -- 2977
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2978
			self:log("博物馆 · 回柜边") -- 2979
		end -- 2979
		return -- 2981
	end -- 2981
	if interactHit then -- 2981
		self.museumReturn = true -- 2984
		self:requestRoom("prologue", "回柜边") -- 2985
	end -- 2985
end -- 2894
function Play.prototype.openTowerDoor(self) -- 2989
	self.towerDoorOpen = true -- 2990
	do -- 2990
		local i = 0 -- 2991
		while i < #self.boxes do -- 2991
			if self.boxes[i + 1].id == "tower_door" then -- 2991
				self.boxes[i + 1].hidden = true -- 2993
			end -- 2993
			i = i + 1 -- 2991
		end -- 2991
	end -- 2991
	self.run.story.segments.tower_door = true -- 2996
end -- 2989
function Play.prototype.stepTower(self, dt, input) -- 2999
	local ____temp_96 -- 3000
	if self.room.story == nil then -- 3000
		____temp_96 = nil -- 3000
	else -- 3000
		____temp_96 = self.room.story.tower -- 3000
	end -- 3000
	local t = ____temp_96 -- 3000
	if t == nil then -- 3000
		return -- 3002
	end -- 3002
	if self.storyRoute == "soldier" and self.partner.alive then -- 3002
		local targetX = math.max(self.ox + 408, self.player.x - 28) -- 3006
		local gap = targetX - self.partner.x -- 3007
		if math.abs(gap) > 2 then -- 3007
			local dir = gap > 0 and 1 or -1 -- 3009
			local stepDist = math.min( -- 3010
				math.abs(gap), -- 3010
				SOLDIER_SPEED * dt -- 3010
			) -- 3010
			self.partner.facing = dir -- 3011
			self.partner.vx = dir * SOLDIER_SPEED -- 3012
			local ____self_partner_97, ____x_98 = self.partner, "x" -- 3012
			____self_partner_97[____x_98] = ____self_partner_97[____x_98] + dir * stepDist -- 3013
		else -- 3013
			self.partner.vx = 0 -- 3015
			self.partner.facing = 1 -- 3016
		end -- 3016
	end -- 3016
	if self.phase == "tower-wait" then -- 3016
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 3020
		if near and input.interact.pressed then -- 3020
			self.phase = "tower-knock" -- 3022
			self.phaseTick = 0 -- 3023
			self.knocks = 1 -- 3024
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 3025
			self:flashSet("叩两下 · 第一声", 0.6) -- 3026
		end -- 3026
		return -- 3028
	end -- 3028
	if self.phase == "tower-knock" then -- 3028
		self.phaseTick = self.phaseTick + 1 -- 3031
		if self.phaseTick == 12 then -- 3031
			self.knocks = 2 -- 3033
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 3034
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 3035
		elseif self.phaseTick >= t.knockTicks then -- 3035
			self:openTowerDoor() -- 3037
			self.phase = "tower-enter" -- 3038
			self.phaseTick = 0 -- 3039
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 3040
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 3041
		end -- 3041
		return -- 3043
	end -- 3043
	if self.phase == "tower-enter" then -- 3043
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 3043
			self.phase = "tower-desk" -- 3047
			self.phaseTick = 0 -- 3048
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 3049
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 3050
		end -- 3050
		return -- 3052
	end -- 3052
	if self.phase == "tower-desk" then -- 3052
		local deskX = self.ox + 605 -- 3055
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 3056
		if not near or not input.interact.held then -- 3056
			self.deskHold = 0 -- 3058
			return -- 3059
		end -- 3059
		self.deskHold = self.deskHold + 1 -- 3061
		if self.deskHold == 12 then -- 3061
			self:flashSet("针套 · 放在桌上", 1) -- 3063
		elseif self.deskHold == 24 then -- 3063
			self:flashSet("指南针 · 压住纸条", 1) -- 3065
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 3065
			self.towerHanded = true -- 3067
			self.deskHold = 0 -- 3068
			self.run.story.segments.tower_handover = true -- 3069
			self.phase = "tower-given" -- 3070
			self.phaseTick = 0 -- 3071
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 3072
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 3077
		end -- 3077
		return -- 3079
	end -- 3079
	if self.phase == "tower-given" then -- 3079
		local soldier = self.storyRoute == "soldier" -- 3084
		self.phaseTick = self.phaseTick + 1 -- 3085
		if self.phaseTick == 60 then -- 3085
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 3087
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 3088
		elseif self.phaseTick == 120 then -- 3088
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 3090
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 3090
			self.phase = "tower-end" -- 3092
			self.phaseTick = 0 -- 3093
			self.towerEndMustRelease = input.interact.held or input.retry.held -- 3094
			if not self.run.finished then -- 3094
				self.run.finished = true -- 3096
				local ending = soldier and "reunion" or "lamp" -- 3097
				self.run.story.ending = ending -- 3098
				local ____soldier_99 -- 3101
				if soldier then -- 3101
					____soldier_99 = self.run.story.segments.escort5 == true -- 3102
				else -- 3102
					____soldier_99 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 3103
				end -- 3103
				local played = ____soldier_99 -- 3101
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 3104
				if official then -- 3104
					if soldier then -- 3104
						self.run.archive.soldierCleared = true -- 3108
					else -- 3108
						self.run.archive.childCleared = true -- 3110
					end -- 3110
					self.archiveDirty = true -- 3112
				end -- 3112
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 3114
				self:emit("endingReached", { -- 3115
					route = soldier and "soldier" or "child", -- 3116
					ending = ending, -- 3117
					official = official, -- 3118
					source = self.run.source, -- 3119
					lines = {self.endingLines[1], self.endingLines[2]}, -- 3120
					childCleared = self.run.archive.childCleared, -- 3121
					soldierCleared = self.run.archive.soldierCleared, -- 3122
					artifactOwned = self.run.archive.artifactOwned, -- 3123
					equipped = self.equippedWeapon -- 3124
				}) -- 3124
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 3126
			end -- 3126
		end -- 3126
		return -- 3129
	end -- 3129
	self.phaseTick = self.phaseTick + 1 -- 3131
	local held = input.interact.held or input.retry.held -- 3132
	if self.towerEndMustRelease then -- 3132
		if not held then -- 3132
			self.towerEndMustRelease = false -- 3135
		end -- 3135
		return -- 3137
	end -- 3137
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 3139
	if self.phaseTick < waitTicks then -- 3139
		if input.interact.pressed or input.retry.pressed then -- 3139
			self.towerEndMustRelease = held -- 3142
		end -- 3142
		return -- 3144
	end -- 3144
	if input.interact.pressed or input.retry.pressed then -- 3144
		self.restartStory = true -- 3148
		self:requestRoom("prologue", "片尾再玩") -- 3149
		self:flashSet("回到序章", 1.4) -- 3150
	end -- 3150
end -- 2999
function Play.prototype.stepChase(self, dt, input) -- 3155
	if self.caughtT > 0 then -- 3155
		self.caughtT = self.caughtT - dt -- 3157
		if self.caughtT <= 0 then -- 3157
			self:recoverFromCaught() -- 3159
		end -- 3159
		return -- 3161
	end -- 3161
	if self.room.key == "village" then -- 3161
		self:stepScavChase() -- 3164
	elseif self.room.key == "forest" then -- 3164
		self:stepForestRoute() -- 3166
		self:stepDog(dt) -- 3167
		if self.player.x >= self.ox + 1450 then -- 3167
			self:requestRoom("tower", "到林缘北塔") -- 3170
			self:flashSet("林缘 · 北塔", 1.4) -- 3171
		end -- 3171
	end -- 3171
end -- 3155
function Play.prototype.stepScavChase(self) -- 3177
	local s = self.room.scavenger -- 3178
	if s == nil then -- 3178
		return -- 3180
	end -- 3180
	local p = self.player -- 3182
	if self.passed and p.x > self.ox + 440 then -- 3182
		if self.scavChase then -- 3182
			self.scavChase = false -- 3186
			self.scavState = "back" -- 3187
			self.scavT = 0 -- 3188
		end -- 3188
		return -- 3190
	end -- 3190
	local dx = p.x - self.scavX -- 3192
	local dist = math.abs(dx) -- 3193
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 3194
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 3195
	if not self.scavChase then -- 3195
		if visible then -- 3195
			self.scavSee = self.scavSee + 1 -- 3198
			if self.scavSee >= 24 then -- 3198
				self.scavChase = true -- 3200
				self.scavState = "chase" -- 3201
				self.scavTargetX = p.x -- 3202
				self:flashSet("他看见你了", 1.2) -- 3203
			end -- 3203
		else -- 3203
			self.scavSee = 0 -- 3206
		end -- 3206
		return -- 3208
	end -- 3208
	if hidden then -- 3208
		self.scavSee = 0 -- 3212
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 3213
		self.scavT = self.scavT - 1 -- 3214
		if self.scavT <= 0 then -- 3214
			self.scavChase = false -- 3216
			self.scavState = "patrol" -- 3217
			self:flashSet("他失去了目标", 1) -- 3218
		end -- 3218
		return -- 3220
	end -- 3220
	local dir = p.x > self.scavX and 1 or -1 -- 3223
	self.scavX = self.scavX + dir * 96 / 60 -- 3224
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 3224
		self:caught() -- 3226
		return -- 3227
	end -- 3227
end -- 3177
function Play.prototype.stepDog(self, dt) -- 3232
	local ____temp_100 -- 3233
	if self.room.story == nil then -- 3233
		____temp_100 = nil -- 3233
	else -- 3233
		____temp_100 = self.room.story.dog -- 3233
	end -- 3233
	local dog = ____temp_100 -- 3233
	if dog == nil then -- 3233
		return -- 3235
	end -- 3235
	local p = self.player -- 3237
	local ox = self.ox -- 3238
	local dist = math.abs(p.x - self.dogX) -- 3239
	local inBurrowCover = p.crouch and p.x >= ox + 300 and p.x <= ox + 460 -- 3240
	local inBrushCover = p.crouch and (p.x >= ox + 700 and p.x <= ox + 790 or p.x >= ox + 1150 and p.x <= ox + 1240) -- 3241
	local sheltered = inBurrowCover or inBrushCover -- 3245
	local inDitchSprint = not p.crouch and self.forestPath == "ditch" and p.x >= ox + 700 and p.x <= ox + 1140 -- 3246
	local effectiveRange = inDitchSprint and dog.range * 1.25 or dog.range -- 3247
	local earNeedTicks = inDitchSprint and 12 or 18 -- 3248
	if self.dogState == "patrol" then -- 3248
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 3250
		if self.dogX < dog.x0 then -- 3250
			self.dogX = dog.x0 -- 3252
			self.dogDir = 1 -- 3253
		elseif self.dogX > dog.x1 then -- 3253
			self.dogX = dog.x1 -- 3255
			self.dogDir = -1 -- 3256
		end -- 3256
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 3258
		local twigOffsets = {235, 455, 865, 1115} -- 3259
		local nearTwig = false -- 3260
		local ti = 0 -- 3261
		do -- 3261
			ti = 0 -- 3262
			while ti < #twigOffsets do -- 3262
				if math.abs(p.x - (ox + twigOffsets[ti + 1])) <= 18 and p.y <= 8 then -- 3262
					nearTwig = true -- 3264
					break -- 3265
				end -- 3265
				ti = ti + 1 -- 3262
			end -- 3262
		end -- 3262
		local twigRange = nearTwig and math.max(effectiveRange, 400) or effectiveRange -- 3268
		if not sheltered and not p.crouch and moving and dist < twigRange then -- 3268
			self.dogState = "ear" -- 3270
			self.dogT = nearTwig and math.min(earNeedTicks, 12) or earNeedTicks -- 3271
			self.dogTargetX = p.x -- 3272
			self:flashSet(inDitchSprint and "旧渠枯枝响 · 狗立刻转耳" or (nearTwig and "踩断枯枝 · 狗立刻转耳" or "狗转耳朵"), 0.8) -- 3273
		end -- 3273
		return -- 3275
	end -- 3275
	if self.dogState == "ear" then -- 3275
		if sheltered then -- 3275
			self.dogState = "sniff" -- 3279
			self.dogT = 45 -- 3280
			self:flashSet("钻进遮蔽 · 狗顿住了", 0.9) -- 3281
			return -- 3282
		end -- 3282
		self.dogT = self.dogT - 1 -- 3284
		if self.dogT <= 0 then -- 3284
			self.dogState = "chase" -- 3286
			self.dogTargetX = p.x -- 3287
			self:flashSet("狗追来了", 1.4) -- 3288
		end -- 3288
		return -- 3290
	end -- 3290
	if self.dogState == "chase" then -- 3290
		local dir = p.x > self.dogX and 1 or -1 -- 3293
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 3294
		if not sheltered and math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 3294
			self:caught() -- 3296
			self.dogState = "sniff" -- 3297
			self.dogT = 60 -- 3298
		elseif dist > effectiveRange * 1.5 or sheltered then -- 3298
			self.dogState = "sniff" -- 3300
			self.dogT = 60 -- 3301
			self:flashSet(inBurrowCover and "树根窄洞遮住身形 · 狗停下了" or "狗停下了", 0.9) -- 3302
		end -- 3302
		return -- 3304
	end -- 3304
	if self.dogState == "sniff" then -- 3304
		self.dogT = self.dogT - 1 -- 3307
		if self.dogT <= 0 then -- 3307
			self.dogState = "back" -- 3309
		end -- 3309
		return -- 3311
	end -- 3311
	local dir = dog.x0 > self.dogX and 1 or -1 -- 3314
	self.dogX = self.dogX + dir * dog.speed * dt -- 3315
	if math.abs(self.dogX - dog.x0) < 2 then -- 3315
		self.dogX = dog.x0 -- 3317
		self.dogState = "patrol" -- 3318
	end -- 3318
end -- 3232
function Play.prototype.stepForestRoute(self) -- 3323
	local p = self.player -- 3324
	local ox = self.ox -- 3325
	if self.forestPath == "" then -- 3325
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 3325
			self.forestPath = "burrow" -- 3328
			self.run.story.segments.forest_burrow = true -- 3329
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 3330
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 3331
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 3331
			self.forestPath = "ditch" -- 3333
			self.run.story.segments.forest_ditch = true -- 3334
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 3335
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 3336
		end -- 3336
	end -- 3336
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 3336
		self.waterSeen = true -- 3340
		self.run.story.segments.water_lantern = true -- 3341
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 3342
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 3343
	end -- 3343
end -- 3323
function Play.prototype.caught(self) -- 3347
	self.caughtT = 1 -- 3348
	self:flashSet("被抓 · 回到安全点", 1.6) -- 3349
end -- 3347
function Play.prototype.recoverFromCaught(self) -- 3353
	local p = self.player -- 3354
	p.x = self.ox + 140 -- 3355
	p.y = 0 -- 3356
	p.vy = 0 -- 3357
	p.vx = 0 -- 3358
	p.onGround = true -- 3359
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3359
		self.scavX = self.room.scavenger.x0 -- 3361
		self.scavState = "patrol" -- 3362
		self.scavSee = 0 -- 3363
		self.scavChase = false -- 3364
		self.scavT = 0 -- 3365
	end -- 3365
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3365
		self.dogX = self.room.story.dog.x0 -- 3368
		self.dogState = "patrol" -- 3369
		self.dogT = 0 -- 3370
	end -- 3370
	self.cam.x = p.x -- 3372
	self.cam.y = p.y + CAM_LOOK_UP -- 3373
	self:flashSet("回到安全点", 1.2) -- 3374
end -- 3353
function Play.prototype.updateGate(self) -- 3378
	if self.room.key ~= "checkpoint" then -- 3378
		self.gateOpen = false -- 3380
		return -- 3381
	end -- 3381
	local function inZone(x) -- 3383
		return x >= self.ox + 792 and x <= self.ox + 928 -- 3383
	end -- 3383
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 3384
end -- 3378
function Play.prototype.addItem(self, kind) -- 3390
	local inv = self.run.inventory -- 3391
	if kind == "shield" then -- 3391
		if inv.shield >= TOOL_CAP then -- 3391
			return false -- 3394
		end -- 3394
		inv.shield = inv.shield + 1 -- 3396
		return true -- 3397
	end -- 3397
	if kind == "wedge" then -- 3397
		if inv.wedge >= CONSUMABLE_CAP then -- 3397
			return false -- 3401
		end -- 3401
		inv.wedge = inv.wedge + 1 -- 3403
		return true -- 3404
	end -- 3404
	if kind == "ammo" then -- 3404
		if inv.ammo >= CONSUMABLE_CAP then -- 3404
			return false -- 3408
		end -- 3408
		inv.ammo = inv.ammo + 1 -- 3410
		return true -- 3411
	end -- 3411
	if kind == "scrap" then -- 3411
		inv.scrap = inv.scrap + 1 -- 3415
		return true -- 3416
	end -- 3416
	if kind == "wood" then -- 3416
		inv.wood = inv.wood + 1 -- 3419
		return true -- 3420
	end -- 3420
	if kind == "bell" then -- 3420
		inv.bell = inv.bell + 1 -- 3423
		return true -- 3424
	end -- 3424
	if kind == "pass" then -- 3424
		inv.pass = inv.pass + 1 -- 3427
		return true -- 3428
	end -- 3428
	if kind == "quickbelt" then -- 3428
		inv.quickbelt = inv.quickbelt + 1 -- 3431
		return true -- 3432
	end -- 3432
	return false -- 3434
end -- 3390
function Play.prototype.findBox(self, id) -- 3437
	local i = 0 -- 3438
	do -- 3438
		i = 0 -- 3439
		while i < #self.boxes do -- 3439
			if self.boxes[i + 1].id == id then -- 3439
				return self.boxes[i + 1] -- 3441
			end -- 3441
			i = i + 1 -- 3439
		end -- 3439
	end -- 3439
	return nil -- 3444
end -- 3437
function Play.prototype.findWedgeTarget(self) -- 3448
	local best = nil -- 3449
	local bestD = 0 -- 3450
	local i = 0 -- 3451
	do -- 3451
		i = 0 -- 3452
		while i < #self.boxes do -- 3452
			do -- 3452
				local b = self.boxes[i + 1] -- 3453
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3453
					goto __continue526 -- 3455
				end -- 3455
				if not self:nearBox(b, 26) then -- 3455
					goto __continue526 -- 3458
				end -- 3458
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3460
				if best == nil or d < bestD then -- 3460
					best = b -- 3462
					bestD = d -- 3463
				end -- 3463
			end -- 3463
			::__continue526:: -- 3463
			i = i + 1 -- 3452
		end -- 3452
	end -- 3452
	return best -- 3466
end -- 3448
function Play.prototype.stepCraft(self, input) -- 3474
	local inv = self.run.inventory -- 3475
	local required = math.max( -- 3476
		6, -- 3476
		CRAFT_TICKS - 6 * self:talentRank("salvage") -- 3476
	) -- 3476
	if self.craftT > 0 then -- 3476
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3476
			self.craftT = 0 -- 3480
			self:flashSet("制作中断", 0.8) -- 3481
			return true -- 3482
		end -- 3482
		self.craftT = self.craftT + 1 -- 3484
		if self.craftT >= required then -- 3484
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3484
				inv.scrap = inv.scrap - 1 -- 3487
				inv.wedge = inv.wedge + 1 -- 3488
				self:flashSet("制得木楔", 1.2) -- 3489
				self:log("制木楔") -- 3490
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3491
			end -- 3491
			self.craftT = 0 -- 3493
		end -- 3493
		return true -- 3495
	end -- 3495
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3495
		self.craftT = 1 -- 3498
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3499
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3500
		return true -- 3501
	end -- 3501
	return false -- 3503
end -- 3474
function Play.prototype.nearBox(self, b, reach) -- 3506
	local p = self.player -- 3507
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3508
end -- 3506
function Play.prototype.findInteract(self) -- 3514
	local p = self.player -- 3515
	local best = nil -- 3516
	local bestD = 1000000000 -- 3517
	local i = 0 -- 3518
	do -- 3518
		i = 0 -- 3519
		while i < #self.boxes do -- 3519
			do -- 3519
				local b = self.boxes[i + 1] -- 3520
				if b.interact == nil or b.broken == true then -- 3520
					goto __continue539 -- 3522
				end -- 3522
				if not self:nearBox(b, b.interact.reach or 27) then -- 3522
					goto __continue539 -- 3525
				end -- 3525
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3527
				if d < bestD then -- 3527
					bestD = d -- 3529
					best = b -- 3530
				end -- 3530
			end -- 3530
			::__continue539:: -- 3530
			i = i + 1 -- 3519
		end -- 3519
	end -- 3519
	return best -- 3533
end -- 3514
function Play.prototype.stepCampaign(self, dt, input) -- 3537
	local wr = self.room -- 3538
	local p = self.player -- 3539
	if self.reloadT > 0 then -- 3539
		self.reloadT = self.reloadT - 1 -- 3541
	end -- 3541
	if self.bracedShield ~= nil then -- 3541
		self.bracedShield.x = p.x + p.facing * 26 -- 3545
		self.bracedShield.y = p.y -- 3546
		local shBox = __TS__ArrayFind( -- 3547
			self.boxes, -- 3547
			function(____, b) return b.id == "braced_shield" end -- 3547
		) -- 3547
		if shBox ~= nil then -- 3547
			shBox.x0 = self.bracedShield.x - 15 -- 3549
			shBox.x1 = self.bracedShield.x + 15 -- 3550
			shBox.y0 = self.bracedShield.y -- 3551
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3552
		end -- 3552
	end -- 3552
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3552
		self.run.route = "drygoods" -- 3558
		self.run.joined = false -- 3559
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3560
		self:log("转布行线") -- 3561
	end -- 3561
	if wr.key == "escort3" then -- 3561
		local nearBench = p.x >= wr.minX + 472 and p.x <= wr.minX + 710 and p.y < 60 -- 3566
		if nearBench and input.interact.pressed then -- 3566
			self:openCraftBench() -- 3568
			return -- 3569
		end -- 3569
		local ____temp_103 = self.storyRoute == "soldier" -- 3571
		if ____temp_103 then -- 3571
			local ____opt_101 = self.run.story.talents -- 3571
			____temp_103 = (____opt_101 and ____opt_101.deferred) == true -- 3571
		end -- 3571
		if ____temp_103 and p.x >= wr.minX + 940 then -- 3571
			self:triggerDeferredEscort3Draft() -- 3572
		end -- 3572
	end -- 3572
	local i = 0 -- 3576
	do -- 3576
		i = 0 -- 3577
		while i < #self.pickups do -- 3577
			do -- 3577
				local pk = self.pickups[i + 1] -- 3578
				if self.run.taken[pk.id] == true then -- 3578
					goto __continue553 -- 3580
				end -- 3580
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3582
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3583
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3583
					if not self:addItem(pk.kind) then -- 3583
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3587
						self:log("满包拒绝 " .. pk.kind) -- 3588
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3589
						goto __continue553 -- 3590
					end -- 3590
					self.run.taken[pk.id] = true -- 3592
					self:flashSet("拾取 " .. pk.label, 1) -- 3593
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3594
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3595
				end -- 3595
			end -- 3595
			::__continue553:: -- 3595
			i = i + 1 -- 3577
		end -- 3577
	end -- 3577
	self.calmConsumed = false -- 3599
	local ____temp_109 = self.partner.alive and self.run.joined -- 3600
	if ____temp_109 then -- 3600
		local ____opt_104 = self.room.campaign -- 3600
		local ____temp_108 = (____opt_104 and ____opt_104.chapter) == "S" -- 3601
		if not ____temp_108 then -- 3601
			local ____opt_106 = self.room.campaign -- 3601
			____temp_108 = (____opt_106 and ____opt_106.chapter) == "C" -- 3601
		end -- 3601
		____temp_109 = ____temp_108 -- 3600
	end -- 3600
	if ____temp_109 and (self.escort.fear > 0 or self.escort.state == "frozen" or self.escort.state == "calming") then -- 3600
		local dist = inReachDepth(p.depth, self.partner.depth) and math.abs(p.x - self.partner.x) or 1000000000 -- 3603
		local hadK1 = self.escort.knock1 -- 3604
		local hadK2 = self.escort.knock2 -- 3605
		self.calmConsumed = self.escort:update( -- 3606
			input, -- 3606
			p.x, -- 3606
			p.facing, -- 3606
			self.partner.x, -- 3606
			dist -- 3606
		) -- 3606
		if not hadK1 and self.escort.knock1 then -- 3606
			self:emit("knock", {count = 1, x = self.partner.x, room = self.room.key}) -- 3608
		end -- 3608
		if not hadK2 and self.escort.knock2 then -- 3608
			self:emit("knock", {count = 2, x = self.partner.x, room = self.room.key}) -- 3611
		end -- 3611
		self.partner.crouch = self.escort.crouchPose -- 3613
		self.partner.h = self.partner.crouch and CHILD_CROUCH_H or CHILD_H -- 3614
	end -- 3614
	if not self.calmConsumed and not self:stepCraft(input) and input.interact.pressed then -- 3614
		self:campaignInteract() -- 3617
	end -- 3617
	self:stepCampaignCart(dt, input) -- 3619
	self:stepCampaignGoal() -- 3620
	self:campaignCheckpoint() -- 3621
end -- 3537
function Play.prototype.campaignCheckpoint(self) -- 3625
	local i = 0 -- 3626
	do -- 3626
		i = 0 -- 3627
		while i < #self.room.marks do -- 3627
			do -- 3627
				local m = self.room.marks[i + 1] -- 3628
				if m.kind ~= 0 then -- 3628
					goto __continue563 -- 3630
				end -- 3630
				local dx = self.player.x - m.x -- 3632
				local dy = self.player.y - m.y -- 3633
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3633
					self.checkpoint = m.x -- 3635
					self:captureCheckpoint(m.x) -- 3636
					self:flashSet("检查点", 1) -- 3637
				end -- 3637
			end -- 3637
			::__continue563:: -- 3637
			i = i + 1 -- 3627
		end -- 3627
	end -- 3627
end -- 3625
function Play.prototype.campaignInteract(self) -- 3643
	local b = self:findInteract() -- 3644
	if b ~= nil then -- 3644
		self:useInteract(b) -- 3646
		return -- 3647
	end -- 3647
	local inv = self.run.inventory -- 3649
	if inv.wedge > 0 then -- 3649
		local w = self:findWedgeTarget() -- 3651
		if w ~= nil then -- 3651
			local ____opt_110 = w.breakable -- 3651
			local extraHp = (____opt_110 and ____opt_110.wedgeHp or 1) + self:talentRank("salvage") -- 3653
			if w.breakable ~= nil then -- 3653
				local ____w_breakable_112, ____hp_113 = w.breakable, "hp" -- 3653
				____w_breakable_112[____hp_113] = ____w_breakable_112[____hp_113] + extraHp -- 3655
			end -- 3655
			inv.wedge = inv.wedge - 1 -- 3657
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3658
			self:flashSet( -- 3660
				extraHp > 1 and ("钉木楔 · 多承" .. tostring(extraHp)) .. "次" or "钉木楔 · 多承一次", -- 3660
				1.2 -- 3660
			) -- 3660
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3661
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3662
			return -- 3663
		end -- 3663
		if self:isEscortRoom() then -- 3663
			local p = self.player -- 3666
			local wx = math.max( -- 3667
				self.room.minX + 64, -- 3667
				math.min(self.room.maxX - 64, p.x + p.facing * 32) -- 3667
			) -- 3667
			local hp = 1 + self:talentRank("salvage") -- 3668
			self.fieldWedgeSeq = self.fieldWedgeSeq + 1 -- 3669
			local wid = "field_wedge_" .. tostring(self.fieldWedgeSeq) -- 3670
			local ____self_boxes_114 = self.boxes -- 3670
			____self_boxes_114[#____self_boxes_114 + 1] = { -- 3671
				x0 = wx - 12, -- 3672
				x1 = wx + 12, -- 3673
				y0 = p.y, -- 3674
				y1 = p.y + 48, -- 3675
				depth = {min = p.depth - 20, max = p.depth + 20}, -- 3676
				label = "立起的木楔掩体", -- 3677
				id = wid, -- 3678
				breakable = {hp = hp, kind = "thin_wood", wedgeable = true} -- 3679
			} -- 3679
			inv.wedge = inv.wedge - 1 -- 3681
			self:flashSet( -- 3682
				"立木楔 · 临时挡弹" .. (hp > 1 and ("(" .. tostring(hp)) .. "击)" or ""), -- 3682
				1.2 -- 3682
			) -- 3682
			self:log("立木楔掩体") -- 3683
			self:emit("interactUsed", {kind = "wedge", x = wx}) -- 3684
			return -- 3685
		end -- 3685
	end -- 3685
	if inv.ammo > 0 and self.reloadT > 0 then -- 3685
		self.reloadT = 0 -- 3690
		self:closeReloadPuzzle() -- 3691
		inv.ammo = inv.ammo - 1 -- 3692
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3693
		self:log("用备用弹包") -- 3694
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3695
		return -- 3696
	end -- 3696
	local canBraceHere = self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 or self:isEscortRoom() -- 3698
	if inv.shield > 0 and self.bracedShield == nil and canBraceHere then -- 3698
		local p = self.player -- 3702
		local shHp = 1 + self:talentRank("salvage") -- 3703
		self.bracedShield = { -- 3704
			x = p.x + p.facing * 26, -- 3704
			y = p.y, -- 3704
			w = 30, -- 3704
			h = 64, -- 3704
			hp = shHp -- 3704
		} -- 3704
		local ____self_boxes_115 = self.boxes -- 3704
		____self_boxes_115[#____self_boxes_115 + 1] = { -- 3705
			x0 = self.bracedShield.x - 15, -- 3706
			x1 = self.bracedShield.x + 15, -- 3706
			y0 = p.y, -- 3707
			y1 = p.y + 64, -- 3707
			depth = {min = -46, max = 46}, -- 3707
			label = "架起的残盾", -- 3707
			id = "braced_shield", -- 3707
			soft = true -- 3708
		} -- 3708
		inv.shield = inv.shield - 1 -- 3710
		self:flashSet( -- 3711
			shHp > 1 and ("架残盾 · 可挡" .. tostring(shHp)) .. "发" or "架残盾 · 挡一发", -- 3711
			1.2 -- 3711
		) -- 3711
		self:log("架残盾") -- 3712
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3713
		return -- 3714
	end -- 3714
	if inv.pass > 0 and self.run.joined == false then -- 3714
		inv.pass = inv.pass - 1 -- 3717
		self.run.joined = true -- 3718
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3719
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3720
		return -- 3721
	end -- 3721
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3723
end -- 3643
function Play.prototype.useInteract(self, b) -- 3726
	local kind = b.interact == nil and "" or b.interact.kind -- 3727
	local wr = self.room -- 3728
	if kind == "open_board" then -- 3728
		b.broken = true -- 3730
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3731
		for ____, cover in ipairs(self.boxes) do -- 3732
			if cover.id == "s2_board_cover" then -- 3732
				cover.broken = false -- 3734
				cover.hidden = false -- 3735
			end -- 3735
		end -- 3735
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3738
		self.run.joined = true -- 3739
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3740
		self:log("放下窗板") -- 3741
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3742
		return -- 3743
	end -- 3743
	if kind == "lower_curtain" then -- 3743
		for ____, curtain in ipairs(self.boxes) do -- 3746
			if curtain.id == "c2_curtain" then -- 3746
				curtain.broken = false -- 3748
				curtain.hidden = false -- 3749
			end -- 3749
		end -- 3749
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3752
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3753
		self:log("放下木帘") -- 3754
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3755
		return -- 3756
	end -- 3756
	if kind == "raise_latch" then -- 3756
		if wr.key == "c2-granary" and not self.cartDocked then -- 3756
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3760
			return -- 3761
		end -- 3761
		b.broken = true -- 3763
		self.objectiveDone = true -- 3764
		if wr.key == "c1-yard" then -- 3764
			self.run.c1Latch = true -- 3767
			self.run.joined = true -- 3768
			for ____, door in ipairs(self.boxes) do -- 3769
				if door.id == "c1_door" then -- 3769
					door.broken = true -- 3771
				end -- 3771
			end -- 3771
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3774
		else -- 3774
			self.run.c2Latch = true -- 3776
			self.run.joined = true -- 3777
		end -- 3777
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3779
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3780
		self:log("抬闩") -- 3781
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3782
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3783
	end -- 3783
end -- 3726
function Play.prototype.stepCampaignCart(self, dt, input) -- 3788
	local wr = self.room -- 3789
	local c = wr.cart -- 3790
	if c.bodyW <= 0 then -- 3790
		return -- 3792
	end -- 3792
	local p = self.player -- 3794
	local handleX = self.cartAxle + c.handleOffset -- 3795
	if not self.gripping then -- 3795
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3795
			self.gripping = true -- 3799
			self:flashSet("握住车柄 · 往右推车", 1) -- 3800
		end -- 3800
		return -- 3802
	end -- 3802
	if input.interact.pressed then -- 3802
		self.gripping = false -- 3805
		self:flashSet("松手", 0.5) -- 3806
		return -- 3807
	end -- 3807
	if not self.cartDocked then -- 3807
		if input.moveX ~= 0 and not self:stuckCart() then -- 3807
			self.cartAxle = math.max( -- 3811
				c.startX, -- 3811
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3811
			) -- 3811
		end -- 3811
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3811
			self.cartExposed = true -- 3816
			local gun = nil -- 3817
			local gi = 0 -- 3818
			do -- 3818
				gi = 0 -- 3819
				while gi < #self.enemies do -- 3819
					local e = self.enemies[gi + 1] -- 3820
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3820
						gun = e -- 3822
						break -- 3823
					end -- 3823
					gi = gi + 1 -- 3819
				end -- 3819
			end -- 3819
			if gun ~= nil then -- 3819
				self:campaignEnemyFire(gun) -- 3827
			end -- 3827
		end -- 3827
		p.x = self.cartAxle + c.handleOffset -- 3830
		p.y = c.baseY -- 3831
		p.depth = c.depth or 0 -- 3832
		p.vx = 0 -- 3833
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3833
			self.cartAxle = c.endX -- 3835
			self.cartDocked = true -- 3836
			self.gripping = false -- 3837
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3838
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3839
			self:flashSet("车轮入窝", 1.2) -- 3840
			self:log("车轮入窝") -- 3841
		end -- 3841
	end -- 3841
end -- 3788
function Play.prototype.stuckCart(self) -- 3847
	local i = 0 -- 3848
	do -- 3848
		i = 0 -- 3849
		while i < #self.boxes do -- 3849
			do -- 3849
				local b = self.boxes[i + 1] -- 3850
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3850
					goto __continue606 -- 3852
				end -- 3852
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3854
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3854
					return true -- 3856
				end -- 3856
			end -- 3856
			::__continue606:: -- 3856
			i = i + 1 -- 3849
		end -- 3849
	end -- 3849
	return false -- 3859
end -- 3847
function Play.prototype.stepCampaignGoal(self) -- 3863
	local wr = self.room -- 3864
	local c = wr.campaign -- 3865
	if c == nil then -- 3865
		return -- 3867
	end -- 3867
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3867
		self.objectiveDone = true -- 3870
	end -- 3870
	if c.goal == "reach_exit" then -- 3870
		self.objectiveDone = true -- 3873
	end -- 3873
	if not self.objectiveDone then -- 3873
		return -- 3876
	end -- 3876
	local p = self.player -- 3878
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3879
	if p.x < c.exitX or not partnerOk then -- 3879
		return -- 3881
	end -- 3881
	if self.run.story.segments[wr.key] ~= true then -- 3881
		self.run.story.segments[wr.key] = true -- 3885
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3886
	end -- 3886
	if wr.key == "escort5" then -- 3886
		self.escortDone = true -- 3890
		self.run.story.escortDone = true -- 3891
	end -- 3891
	if c.next ~= nil and c.next ~= "" then -- 3891
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3894
		self:flashSet("过关 · " .. c.next, 1.2) -- 3895
	elseif wr.key == "c2-granary" and (self.run.source == "official" or self.run.source == "chapter") then -- 3895
		self:requestRoom("gate", "军粮棚出口") -- 3898
		self:flashSet("出军粮棚 · 城门", 1.4) -- 3899
	elseif not self.run.finished then -- 3899
		self.run.finished = true -- 3901
		self:flashSet( -- 3902
			"军粮棚清完 · 回城门 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3902
			2 -- 3902
		) -- 3902
		self:log("军粮棚清完 · 回城门") -- 3903
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3904
	end -- 3904
end -- 3863
function Play.prototype.stepCampaignPartner(self, dt) -- 3909
	local a = self.partner -- 3910
	local wr = self.room -- 3911
	local cp = wr.companion -- 3912
	if not a.alive then -- 3912
		return -- 3914
	end -- 3914
	local p = self.player -- 3916
	if self.craftBench.active then -- 3916
		a.vx = 0 -- 3919
		return -- 3920
	end -- 3920
	local wait = false -- 3922
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3923
	local targetDepth = p.depth -- 3924
	if self.run.joined == false then -- 3924
		wait = true -- 3926
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3927
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3928
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3928
		wait = true -- 3930
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3931
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3932
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3932
		wait = true -- 3934
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3935
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3936
	end -- 3936
	local bypass = cp and cp.groundBypass -- 3938
	if bypass ~= nil then -- 3938
		if wait and not self.cartDocked and a.x < targetX - 18 then -- 3938
			targetX = math.min( -- 3942
				targetX, -- 3942
				math.max(a.x, p.x - 52) -- 3942
			) -- 3942
		end -- 3942
		local approachesBypass = a.x >= bypass.x0 - 80 and a.x <= bypass.x1 + 80 and math.max(a.x, targetX) >= bypass.x0 - a.w * 0.5 and math.min(a.x, targetX) <= bypass.x1 + a.w * 0.5 -- 3944
		local walkDepth = approachesBypass and (cp and cp.waitDepth or LANE_DEPTH.upper) or 0 -- 3947
		local depthStep = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 3948
		local lastDepth = a.depth -- 3949
		local lastX = a.x -- 3950
		a.h = CHILD_H -- 3951
		a.crouch = false -- 3952
		self:slideDepth( -- 3953
			a, -- 3953
			math.max( -- 3953
				-depthStep, -- 3953
				math.min(depthStep, walkDepth - lastDepth) -- 3953
			) -- 3953
		) -- 3953
		local dx = targetX - a.x -- 3954
		if math.abs(dx) > (wait and 18 or 74) then -- 3954
			local speed = not wait and math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3956
			a.facing = dx > 0 and 1 or -1 -- 3957
			self:slideX( -- 3958
				a, -- 3958
				a.facing * math.min( -- 3958
					math.abs(dx), -- 3958
					speed * dt -- 3958
				) -- 3958
			) -- 3958
		end -- 3958
		a.depthSpeed = dt > 0 and (a.depth - lastDepth) / dt or 0 -- 3960
		a.vx = dt > 0 and (a.x - lastX) / dt or 0 -- 3961
		self:fallY(a, dt) -- 3962
		return -- 3963
	end -- 3963
	if self.partnerStuck > 0.3 then -- 3963
		a.x = a.x + a.facing * 44 -- 3967
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3968
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3969
		self.partnerLaneHold = 1.1 -- 3970
		self.partnerStuck = 0 -- 3971
	end -- 3971
	if self.partnerLaneHold > 0 then -- 3971
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3974
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3975
	end -- 3975
	local dx = targetX - a.x -- 3977
	local stopTol = wait and 18 or 74 -- 3978
	if math.abs(dx) > stopTol then -- 3978
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3980
		local before = a.x -- 3981
		a.vx = dx > 0 and speed or -speed -- 3982
		a.facing = dx > 0 and 1 or -1 -- 3983
		self:slideX(a, a.vx * dt) -- 3984
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3984
			a.vy = CHILD_JUMP -- 3987
			a.onGround = false -- 3988
		end -- 3988
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3990
	else -- 3990
		a.vx = 0 -- 3992
		self.partnerStuck = 0 -- 3993
	end -- 3993
	local dz = targetDepth - a.depth -- 3995
	if math.abs(dz) > 6 then -- 3995
		local step = math.max( -- 3997
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3997
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3997
		) -- 3997
		a.depth = a.depth + step -- 3998
	end -- 3998
	a.depthSpeed = 0 -- 4000
	a.h = CHILD_H -- 4001
	a.crouch = false -- 4002
	self:fallY(a, dt) -- 4003
end -- 3909
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 4007
	local p = self.player -- 4008
	local i = 0 -- 4009
	do -- 4009
		i = 0 -- 4010
		while i < #self.enemies and not self.escortFailed do -- 4010
			do -- 4010
				local e = self.enemies[i + 1] -- 4011
				if e.kind == "target" then -- 4011
					if not e.alive then -- 4011
						if e.hitT > 0 then -- 4011
							e.hitT = e.hitT - dt -- 4016
						end -- 4016
						if e.hitT <= 0 then -- 4016
							e.alive = true -- 4019
							e.hitT = 0 -- 4020
						end -- 4020
					end -- 4020
					goto __continue637 -- 4023
				end -- 4023
				if not e.alive then -- 4023
					goto __continue637 -- 4026
				end -- 4026
				if e.kind == "breaker" then -- 4026
					self:stepBreaker(e, dt) -- 4029
					goto __continue637 -- 4030
				end -- 4030
				if e.kind == "shield" then -- 4030
					self:stepShield(e, dt, input) -- 4033
					goto __continue637 -- 4034
				end -- 4034
				local dx = e.x - p.x -- 4037
				if not e.awake then -- 4037
					if math.abs(dx) > 520 then -- 4037
						goto __continue637 -- 4040
					end -- 4040
					e.awake = true -- 4042
					e.fireCd = 48 -- 4043
					goto __continue637 -- 4044
				end -- 4044
				if math.abs(dx) > ENEMY_RANGE then -- 4044
					goto __continue637 -- 4047
				end -- 4047
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 4047
					goto __continue637 -- 4052
				end -- 4052
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 4052
					goto __continue637 -- 4055
				end -- 4055
				if self:blockedShot(e, p) then -- 4055
					if e.warnT > 0 then -- 4055
						e.warnT = 0 -- 4061
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4062
					end -- 4062
					goto __continue637 -- 4064
				end -- 4064
				if e.warnT > 0 then -- 4064
					e.warnT = e.warnT - 1 -- 4067
					if e.warnT <= 0 then -- 4067
						self:campaignEnemyFire(e) -- 4069
					end -- 4069
				elseif e.fireCd > 0 then -- 4069
					e.fireCd = e.fireCd - 1 -- 4072
					if e.fireCd <= 0 then -- 4072
						e.warnT = WARN_TICKS -- 4074
					end -- 4074
				else -- 4074
					e.fireCd = 40 -- 4077
				end -- 4077
			end -- 4077
			::__continue637:: -- 4077
			i = i + 1 -- 4010
		end -- 4010
	end -- 4010
end -- 4007
function Play.prototype.blockedShot(self, e, p) -- 4083
	local eDepth = e.depth or 0 -- 4084
	local ex = e.x -- 4085
	local ey = e.y + e.h * 0.62 -- 4087
	local px = p.x -- 4088
	local py = p.y + p.h * 0.55 -- 4089
	local dx = px - ex -- 4090
	local dyScreen = py + p.depth * DEPTH_Y_SCALE - (ey + eDepth * DEPTH_Y_SCALE) -- 4091
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 4092
	if len < 0.01 then -- 4092
		return false -- 4094
	end -- 4094
	local ray = { -- 4098
		x = ex, -- 4099
		y = ey, -- 4099
		dx = dx / len, -- 4100
		dy = (py - ey) / len, -- 4100
		depth = eDepth, -- 4101
		dDepth = (p.depth - eDepth) / len -- 4101
	} -- 4101
	local best = -1 -- 4103
	local j = 0 -- 4104
	do -- 4104
		j = 0 -- 4105
		while j < #self.boxes do -- 4105
			do -- 4105
				local b = self.boxes[j + 1] -- 4106
				if b.broken == true or b.passable == true or b.hidden == true then -- 4106
					goto __continue660 -- 4108
				end -- 4108
				if b.id == "braced_shield" then -- 4108
					goto __continue660 -- 4113
				end -- 4113
				local t = hitBox(ray, b) -- 4115
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 4115
					best = t -- 4119
				end -- 4119
			end -- 4119
			::__continue660:: -- 4119
			j = j + 1 -- 4105
		end -- 4105
	end -- 4105
	return best >= 0 -- 4122
end -- 4083
function Play.prototype.campaignEnemyFire(self, e) -- 4125
	local p = self.player -- 4126
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4127
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 4127
		local ____self_bracedShield_120, ____hp_121 = self.bracedShield, "hp" -- 4127
		____self_bracedShield_120[____hp_121] = ____self_bracedShield_120[____hp_121] - 1 -- 4129
		if self.bracedShield.hp <= 0 then -- 4129
			self.boxes = __TS__ArrayFilter( -- 4131
				self.boxes, -- 4131
				function(____, b) return b.id ~= "braced_shield" end -- 4131
			) -- 4131
			self.bracedShield = nil -- 4132
			self:flashSet("残盾碎 · 挡下一发", 1) -- 4133
		else -- 4133
			self:flashSet( -- 4135
				"残盾挡下一发 · 余" .. tostring(self.bracedShield.hp), -- 4135
				1 -- 4135
			) -- 4135
		end -- 4135
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 4137
		return -- 4138
	end -- 4138
	if self:blockedShot(e, p) then -- 4138
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4141
		return -- 4142
	end -- 4142
	local cover = self:blockedByCover(e, p) -- 4144
	if cover ~= nil and self.coverHug then -- 4144
		self.coveredFlash = 0.5 -- 4146
		self:flashSet("掩体挡下", 0.6) -- 4147
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4148
		return -- 4153
	end -- 4153
	if self.invulnT > 0 then -- 4153
		return -- 4156
	end -- 4156
	self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4158
	self.craftT = 0 -- 4159
	self.hp = self.hp - 1 -- 4160
	self:emit("actorHit", { -- 4161
		target = "player", -- 4161
		amount = 1, -- 4161
		hp = self.hp, -- 4161
		maxHp = self.maxHp, -- 4161
		enemyX = e.x -- 4161
	}) -- 4161
	self:flashSet( -- 4162
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4162
		0.8 -- 4162
	) -- 4162
	if self.hp <= 0 then -- 4162
		self:campaignFailed() -- 4164
	end -- 4164
end -- 4125
function Play.prototype.stepShield(self, e, dt, input) -- 4169
	local p = self.player -- 4170
	local dx = p.x - e.x -- 4171
	local adx = math.abs(dx) -- 4172
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 4175
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 4176
	if adx > 44 then -- 4176
		local before = e.x -- 4178
		local stepX = (dx > 0 and 1 or -1) * 60 * dt -- 4179
		local nextX = math.max( -- 4180
			self.room.minX + 16, -- 4180
			math.min(self.room.maxX - 16, e.x + stepX) -- 4180
		) -- 4180
		if not self:enemyBlockedAtX(e, nextX) then -- 4180
			e.x = nextX -- 4182
		end -- 4182
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 4182
			e.depth = math.max( -- 4186
				-32, -- 4186
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4186
			) -- 4186
		end -- 4186
	elseif adx <= 48 and sameLane and (e.swingT or 0) <= 0 then -- 4186
		local fromFront = (e.x - p.x) * p.facing > 0 -- 4191
		local rollDodges = p.rollT > 0 and (fromFront or self:talentRank("guard") > 0) -- 4192
		if not rollDodges and self.invulnT <= 0 then -- 4192
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4194
			self.craftT = 0 -- 4195
			self.hp = self.hp - 1 -- 4196
			self:emit("actorHit", { -- 4197
				target = "player", -- 4197
				amount = 1, -- 4197
				hp = self.hp, -- 4197
				maxHp = self.maxHp, -- 4197
				enemyX = e.x -- 4197
			}) -- 4197
			self:flashSet( -- 4198
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4198
				0.8 -- 4198
			) -- 4198
			if self.hp <= 0 then -- 4198
				self:campaignFailed() -- 4200
				return -- 4201
			end -- 4201
		end -- 4201
		e.swingT = 70 -- 4204
	end -- 4204
	if (e.swingT or 0) > 0 then -- 4204
		e.swingT = (e.swingT or 0) - 1 -- 4207
	end -- 4207
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 4207
		local dd = p.depth - (e.depth or 0) -- 4210
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 4211
	end -- 4211
end -- 4169
function Play.prototype.stepBreaker(self, e, dt) -- 4216
	local p = self.player -- 4217
	if e.awake ~= true then -- 4217
		if math.abs(p.x - e.x) < 560 then -- 4217
			e.awake = true -- 4220
		else -- 4220
			return -- 4222
		end -- 4222
	end -- 4222
	local target = nil -- 4225
	local bestD = 1000000000 -- 4226
	local i = 0 -- 4227
	do -- 4227
		i = 0 -- 4228
		while i < #self.boxes do -- 4228
			do -- 4228
				local b = self.boxes[i + 1] -- 4229
				if b.breakable == nil or b.broken == true then -- 4229
					goto __continue687 -- 4231
				end -- 4231
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 4233
				if d < bestD then -- 4233
					bestD = d -- 4235
					target = b -- 4236
				end -- 4236
			end -- 4236
			::__continue687:: -- 4236
			i = i + 1 -- 4228
		end -- 4228
	end -- 4228
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 4239
	local dx = tx - e.x -- 4240
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 4241
	if math.abs(dx) > reach then -- 4241
		local before = e.x -- 4243
		local nextX = math.max( -- 4244
			self.room.minX + 16, -- 4244
			math.min(self.room.maxX - 16, e.x + (dx > 0 and 1 or -1) * 48 * dt) -- 4244
		) -- 4244
		if not self:enemyBlockedAtX(e, nextX) then -- 4244
			e.x = nextX -- 4246
		end -- 4246
		if math.abs(e.x - before) < 0.3 then -- 4246
			e.depth = math.max( -- 4249
				-32, -- 4249
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4249
			) -- 4249
		end -- 4249
	elseif (e.swingT or 0) <= 0 then -- 4249
		e.swingT = 64 -- 4252
		if target ~= nil then -- 4252
			self:damageProp(target, 2) -- 4254
		elseif math.abs(p.x - e.x) < 60 and math.abs((e.depth or 0) - p.depth) <= 26 and not (p.rollT > 0 and self:talentRank("guard") > 0) and self.invulnT <= 0 then -- 4254
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4257
			self.craftT = 0 -- 4258
			self.hp = self.hp - 1 -- 4259
			self:emit("actorHit", { -- 4260
				target = "player", -- 4260
				amount = 1, -- 4260
				hp = self.hp, -- 4260
				maxHp = self.maxHp, -- 4260
				enemyX = e.x -- 4260
			}) -- 4260
			self:flashSet("破障手近身", 0.8) -- 4261
			if self.hp <= 0 then -- 4261
				self:campaignFailed() -- 4263
				return -- 4264
			end -- 4264
		end -- 4264
	end -- 4264
	if (e.swingT or 0) > 0 then -- 4264
		e.swingT = (e.swingT or 0) - 1 -- 4269
	end -- 4269
end -- 4216
function Play.prototype.enemyBlockedAtX(self, e, nextX) -- 4274
	local half = e.w * 0.5 -- 4275
	local d = e.depth or 0 -- 4276
	local i = 0 -- 4277
	do -- 4277
		i = 0 -- 4278
		while i < #self.boxes do -- 4278
			do -- 4278
				local b = self.boxes[i + 1] -- 4279
				if b.broken == true or b.passable == true or b.soft == true or b.hidden == true or b.y0 >= e.y + e.h or b.y1 <= e.y + 4 then -- 4279
					goto __continue700 -- 4281
				end -- 4281
				if b.depth ~= nil and (d < b.depth.min - 8 or d > b.depth.max + 8) then -- 4281
					goto __continue700 -- 4284
				end -- 4284
				if nextX + half > b.x0 and nextX - half < b.x1 then -- 4284
					return true -- 4287
				end -- 4287
			end -- 4287
			::__continue700:: -- 4287
			i = i + 1 -- 4278
		end -- 4278
	end -- 4278
	return false -- 4290
end -- 4274
function Play.prototype.campaignFailed(self) -- 4293
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 4293
		if self.escortFailed then -- 4293
			return -- 4298
		end -- 4298
		if self.useEscortDeathSummary then -- 4298
			local story = self.run.story -- 4300
			local st = story.talents -- 4301
			local ranksCopy = { -- 4302
				vitality = st and st.ranks.vitality or 0, -- 4303
				guard = st and st.ranks.guard or 0, -- 4304
				stride = st and st.ranks.stride or 0, -- 4305
				focus = st and st.ranks.focus or 0, -- 4306
				push_force = st and st.ranks.push_force or 0, -- 4307
				echo_wide = st and st.ranks.echo_wide or 0, -- 4308
				lantern_pierce = st and st.ranks.lantern_pierce or 0, -- 4309
				salvage = st and st.ranks.salvage or 0 -- 4310
			} -- 4310
			local cleared = 0 -- 4312
			local segKeys = { -- 4313
				"escort1", -- 4313
				"escort2", -- 4313
				"escort3", -- 4313
				"escort4", -- 4313
				"escort5" -- 4313
			} -- 4313
			local si = 0 -- 4314
			do -- 4314
				si = 0 -- 4315
				while si < #segKeys do -- 4315
					if story.segments[segKeys[si + 1]] == true then -- 4315
						cleared = cleared + 1 -- 4317
					end -- 4317
					si = si + 1 -- 4315
				end -- 4315
			end -- 4315
			self.escortFailed = true -- 4320
			self.escortFailedTicks = 0 -- 4321
			self.talentModalActive = false -- 4322
			self.craftBench.active = false -- 4323
			self.reloadT = 0 -- 4324
			self:closeReloadPuzzle() -- 4325
			self.gripping = false -- 4326
			self.escortSummary = { -- 4327
				roomKey = self.room.key, -- 4328
				attempt = st ~= nil and math.max(1, st.attempt) or 1, -- 4329
				seed = st ~= nil and st.randomState or self.run.seed, -- 4330
				equippedWeapon = self.equippedWeapon, -- 4331
				segmentsCleared = cleared, -- 4332
				ranks = ranksCopy -- 4333
			} -- 4333
			self:resetEscortAttempt() -- 4335
			self:flashSet("折返山道 · 重整再赴", 2) -- 4336
			self:log("男主线折返 · 展示小结") -- 4337
			self:emit("campaignFailed", { -- 4338
				room = self.room.key, -- 4339
				hp = 0, -- 4339
				maxHp = self.maxHp, -- 4339
				reset = true, -- 4340
				to = "escort1", -- 4340
				route = self.storyRoute, -- 4340
				summary = true -- 4340
			}) -- 4340
			return -- 4342
		end -- 4342
		self:restartEscortRun() -- 4344
		return -- 4345
	end -- 4345
	local p = self.player -- 4347
	self.hp = self.maxHp -- 4348
	self.invulnT = INVULN_RESPAWN_TICKS -- 4349
	self.reloadT = 0 -- 4350
	self:closeReloadPuzzle() -- 4351
	self.gripping = false -- 4352
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 4353
	self:log("被击倒") -- 4354
	p.x = self.room.minX + 90 -- 4355
	p.y = 0 -- 4356
	p.depth = 0 -- 4357
	p.vx = 0 -- 4358
	p.vy = 0 -- 4359
	p.onGround = true -- 4360
	p.rollT = 0 -- 4361
	self.partner.x = p.x - 50 -- 4362
	self.partner.y = 0 -- 4363
	self.partner.depth = 0 -- 4364
	self.cam.x = p.x -- 4365
	local i = 0 -- 4366
	do -- 4366
		i = 0 -- 4367
		while i < #self.enemies do -- 4367
			do -- 4367
				local e = self.enemies[i + 1] -- 4368
				if not e.alive then -- 4368
					goto __continue712 -- 4370
				end -- 4370
				e.x = e.homeX == nil and e.x or e.homeX -- 4372
				e.warnT = 0 -- 4373
				e.fireCd = 40 -- 4374
				e.swingT = 0 -- 4375
				e.awake = false -- 4376
			end -- 4376
			::__continue712:: -- 4376
			i = i + 1 -- 4367
		end -- 4367
	end -- 4367
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4378
end -- 4293
function Play.prototype.isEscortRoom(self) -- 4382
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 4383
end -- 4382
function Play.prototype.confirmEscortRestart(self) -- 4387
	if not self.escortFailed then -- 4387
		return false -- 4389
	end -- 4389
	self:requestRoom("escort1", "男主线失败重开") -- 4391
	return true -- 4392
end -- 4387
function Play.prototype.restartEscortRun(self) -- 4396
	self:resetEscortAttempt() -- 4397
	self:requestRoom("escort1", "男主线失败重开") -- 4398
end -- 4396
function Play.prototype.resetEscortAttempt(self) -- 4406
	local story = self.run.story -- 4407
	local inv = self.run.inventory -- 4408
	local prevAttempt = story.talents ~= nil and math.max(1, story.talents.attempt) or 1 -- 4409
	local nextAttempt = prevAttempt + 1 -- 4410
	local vitBonus = story.talents ~= nil and (story.talents.ranks.vitality or 0) or 0 -- 4411
	if vitBonus > 0 then -- 4411
		self.maxHp = math.max(3, self.maxHp - vitBonus) -- 4413
		story.maxHp = self.maxHp -- 4414
	end -- 4414
	story.talents = createStoryTalents(self.run.seed, nextAttempt) -- 4416
	self.hp = self.maxHp -- 4417
	story.hp = self.maxHp -- 4418
	story.cp = nil -- 4419
	self.checkpointSnap = nil -- 4420
	story.carry = false -- 4421
	self.carryOn = false -- 4422
	story.craftedWeapon = "" -- 4423
	self.equippedWeapon = "standard_gun" -- 4424
	story.equippedWeapon = "standard_gun" -- 4425
	story.escortDone = false -- 4426
	self.escortDone = false -- 4427
	story.segments = {} -- 4428
	inv.wood = 0 -- 4429
	inv.bell = 0 -- 4430
	inv.scrap = 0 -- 4431
	inv.wedge = 0 -- 4432
	inv.ammo = 0 -- 4433
	inv.quickbelt = 0 -- 4434
	inv.shield = 0 -- 4435
	inv.pass = 0 -- 4436
	local taken = self.run.taken -- 4437
	local keys = __TS__ObjectKeys(taken) -- 4438
	local i = 0 -- 4439
	do -- 4439
		i = 0 -- 4440
		while i < #keys do -- 4440
			local k = keys[i + 1] -- 4441
			if (string.find(k, "e2_", nil, true) or 0) - 1 == 0 or (string.find(k, "e3_", nil, true) or 0) - 1 == 0 or (string.find(k, "escort", nil, true) or 0) - 1 == 0 then -- 4441
				__TS__Delete(taken, k) -- 4443
			end -- 4443
			i = i + 1 -- 4440
		end -- 4440
	end -- 4440
	local propKeys = __TS__ObjectKeys(self.run.props) -- 4446
	do -- 4446
		i = 0 -- 4447
		while i < #propKeys do -- 4447
			local pk = propKeys[i + 1] -- 4448
			if (string.find(pk, "e1_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e2_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e3_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e4_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e5_", nil, true) or 0) - 1 == 0 or (string.find(pk, "field_wedge_", nil, true) or 0) - 1 == 0 then -- 4448
				__TS__Delete(self.run.props, pk) -- 4451
			end -- 4451
			i = i + 1 -- 4447
		end -- 4447
	end -- 4447
	self.bracedShield = nil -- 4454
	self.talentModalActive = false -- 4455
	self.run.joined = true -- 4456
	self.reloadT = 0 -- 4457
	self:closeReloadPuzzle() -- 4458
	self.gripping = false -- 4459
	self.sessionDirty = true -- 4460
	self:flashSet( -- 4461
		("重整启程 · 第" .. tostring(nextAttempt)) .. "轮护送", -- 4461
		2 -- 4461
	) -- 4461
	self:log(("男主线重开 · 第" .. tostring(nextAttempt)) .. "轮回 escort1") -- 4462
	if not self.useEscortDeathSummary then -- 4462
		self:emit("campaignFailed", { -- 4464
			room = self.room.key, -- 4465
			hp = 0, -- 4465
			maxHp = self.maxHp, -- 4465
			reset = true, -- 4466
			to = "escort1", -- 4466
			route = self.storyRoute, -- 4466
			attempt = nextAttempt -- 4466
		}) -- 4466
	end -- 4466
end -- 4406
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 4472
	local i = 0 -- 4473
	do -- 4473
		i = 0 -- 4474
		while i < #self.enemies do -- 4474
			do -- 4474
				if i == skipIndex then -- 4474
					goto __continue729 -- 4476
				end -- 4476
				local e = self.enemies[i + 1] -- 4478
				if not e.alive or math.abs(e.x - center.x) > radius then -- 4478
					goto __continue729 -- 4480
				end -- 4480
				e.awake = true -- 4482
				e.fireCd = math.max(e.fireCd or 0, 150) -- 4483
				e.warnT = 0 -- 4484
			end -- 4484
			::__continue729:: -- 4484
			i = i + 1 -- 4474
		end -- 4474
	end -- 4474
end -- 4472
function Play.prototype.stepEnemies(self, dt, input) -- 4488
	local i = 0 -- 4489
	do -- 4489
		i = 0 -- 4490
		while i < #self.enemies do -- 4490
			local e = self.enemies[i + 1] -- 4491
			if e.hitT > 0 then -- 4491
				e.hitT = e.hitT - dt -- 4493
			end -- 4493
			i = i + 1 -- 4490
		end -- 4490
	end -- 4490
	if self.coveredFlash > 0 then -- 4490
		self.coveredFlash = self.coveredFlash - dt -- 4497
	end -- 4497
	if self.isCampaign then -- 4497
		self:stepCampaignEnemies(dt, input) -- 4500
		return -- 4501
	end -- 4501
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 4501
		return -- 4505
	end -- 4505
	do -- 4505
		i = 0 -- 4507
		while i < #self.enemies do -- 4507
			do -- 4507
				local e = self.enemies[i + 1] -- 4508
				if not e.alive then -- 4508
					goto __continue740 -- 4510
				end -- 4510
				if e.warnT > 0 then -- 4510
					e.warnT = e.warnT - 1 -- 4513
					if e.warnT <= 0 then -- 4513
						self:enemyFire(e, input) -- 4515
					end -- 4515
					goto __continue740 -- 4517
				end -- 4517
				if e.fireCd > 0 then -- 4517
					e.fireCd = e.fireCd - 1 -- 4520
					if e.fireCd <= 0 then -- 4520
						e.warnT = WARN_TICKS -- 4522
					end -- 4522
				else -- 4522
					e.warnT = WARN_TICKS -- 4526
				end -- 4526
			end -- 4526
			::__continue740:: -- 4526
			i = i + 1 -- 4507
		end -- 4507
	end -- 4507
end -- 4488
function Play.prototype.enemyFire(self, e, input) -- 4532
	local p = self.player -- 4533
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 4533
		self:flashSet("枪声响在远处", 0.4) -- 4535
		e.fireCd = FIRE_COOLDOWN -- 4536
		return -- 4537
	end -- 4537
	if self:blockedShot(e, p) then -- 4537
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4540
		e.fireCd = FIRE_COOLDOWN -- 4541
		return -- 4542
	end -- 4542
	local cover = self:blockedByCover(e, p) -- 4545
	local hugging = cover ~= nil -- 4546
	self.coverBlocking = hugging -- 4547
	local covered = hugging and input.cover.held -- 4548
	if covered then -- 4548
		self.coveredFlash = 0.5 -- 4550
		self:flashSet("掩体挡下", 0.5) -- 4551
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4552
		e.fireCd = FIRE_COOLDOWN -- 4557
		return -- 4558
	end -- 4558
	if self.invulnT > 0 then -- 4558
		e.fireCd = FIRE_COOLDOWN -- 4561
		return -- 4562
	end -- 4562
	self.invulnT = INVULN_HIT_TICKS -- 4564
	self.hp = self.hp - 1 -- 4565
	self:emit("actorHit", { -- 4566
		target = "player", -- 4566
		amount = 1, -- 4566
		hp = self.hp, -- 4566
		maxHp = self.maxHp, -- 4566
		enemyX = e.x -- 4566
	}) -- 4566
	self:flashSet( -- 4567
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4567
		0.7 -- 4567
	) -- 4567
	e.fireCd = FIRE_COOLDOWN -- 4568
	if self.hp <= 0 then -- 4568
		self:gateFailed() -- 4570
	end -- 4570
end -- 4532
function Play.prototype.blockedByCover(self, enemy, p) -- 4575
	local b = self:coverAt(p) -- 4576
	if b == nil then -- 4576
		return nil -- 4578
	end -- 4578
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4580
end -- 4575
function Play.prototype.gateFailed(self) -- 4584
	local ____temp_138 -- 4585
	if self.room.story == nil then -- 4585
		____temp_138 = nil -- 4585
	else -- 4585
		____temp_138 = self.room.story.gate -- 4585
	end -- 4585
	local g = ____temp_138 -- 4585
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 4586
	self.hp = self.maxHp -- 4587
	self.gateTick = 0 -- 4588
	self.gateSpawned = 0 -- 4589
	self.enemies = {} -- 4590
	self.gateFailCount = self.gateFailCount + 1 -- 4591
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 4593
	self.player.y = 0 -- 4594
	self.player.vy = 0 -- 4595
	self.player.depth = 0 -- 4596
	self.player.depthSpeed = 0 -- 4597
	self.player.onGround = true -- 4598
	self.player.crouch = false -- 4599
	self.player.h = SOLDIER_H -- 4600
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 4601
	self.partner.y = 0 -- 4602
	self.partner.vy = 0 -- 4603
	self.partner.depth = 0 -- 4604
	self.partner.depthSpeed = 0 -- 4605
	self.partner.onGround = true -- 4606
	self.cam.x = self.player.x -- 4607
	self.phase = "gate-idle" -- 4608
	self.phaseTick = 0 -- 4609
	self.coverHug = false -- 4610
	self.coverBlocking = false -- 4611
	self.coverEntity = "" -- 4612
	self.gateNeedConfirm = true -- 4613
	self.gateRestartArmed = false -- 4614
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 4615
end -- 4584
function Play.prototype.finishOutsideCart(self) -- 4619
	self.redCartMemoryT = 30 -- 4620
	if self.run.story ~= nil then -- 4620
		self.run.story.segments.outside_cart = true -- 4622
		self.run.story.segments.outside_memory = true -- 4623
	end -- 4623
	self.sessionDirty = true -- 4625
	self:emit("storyBeat", {beat = "red_cart_memory", x = self.player.x, room = "outside", durationTicks = 30}) -- 4626
end -- 4619
function Play.prototype.stepInteract(self, dt, input) -- 4629
	local p = self.player -- 4630
	self.redCartMemoryT = math.max(0, self.redCartMemoryT - 1) -- 4631
	local calmUsed = self.calmConsumed -- 4632
	self.calmConsumed = false -- 4633
	local calming = self.escort.state == "calming" -- 4635
	self.focusCart = false -- 4636
	if self.room.key == "outside" then -- 4636
		self.focusCart = not calmUsed and not calming and self:cartHandleInReach(p) -- 4638
	end -- 4638
	if not calmUsed and not calming then -- 4638
		self:stepCart(dt, input) -- 4642
	end -- 4642
	if calmUsed then -- 4642
		self:flashSet("安抚 · 敲两下", 0.8) -- 4647
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4647
		if self.knockT > 0 then -- 4647
			self.knocks = self.knocks + 1 -- 4651
		else -- 4651
			self.knocks = 1 -- 4653
		end -- 4653
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4655
		self.knockT = 1.2 -- 4656
		if self.knocks >= 2 then -- 4656
			self:flashSet("敲两下", 0.8) -- 4658
			self.knocks = 0 -- 4659
		else -- 4659
			self:flashSet("敲一下", 0.5) -- 4661
		end -- 4661
	elseif self.knockT > 0 then -- 4661
		self.knockT = self.knockT - dt -- 4664
		if self.knockT <= 0 then -- 4664
			self.knocks = 0 -- 4666
		end -- 4666
	end -- 4666
	local i = 0 -- 4671
	do -- 4671
		i = 0 -- 4672
		while i < #self.room.marks do -- 4672
			do -- 4672
				local m = self.room.marks[i + 1] -- 4673
				if m.kind ~= 0 then -- 4673
					goto __continue770 -- 4675
				end -- 4675
				local subjects = {self.partner, self.player} -- 4677
				local k = 0 -- 4678
				do -- 4678
					k = 0 -- 4679
					while k < #subjects do -- 4679
						do -- 4679
							local s = subjects[k + 1] -- 4680
							if not s.alive then -- 4680
								goto __continue773 -- 4682
							end -- 4682
							local dx = s.x - m.x -- 4684
							local dy = s.y - m.y -- 4685
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4685
								self.checkpoint = m.x -- 4687
								self.checkpointCartAxle = self.cartAxle -- 4688
								if self.isCampaign then -- 4688
									self:captureCheckpoint(m.x) -- 4691
								end -- 4691
								if self.room.cart.bodyW > 0 then -- 4691
									if self.cartDocked then -- 4691
										self:flashSet("检查点 · 车已落窝", 1) -- 4695
									else -- 4695
										self:flashSet("检查点 · 车还没到位", 1) -- 4697
									end -- 4697
								else -- 4697
									self:flashSet("检查点", 1) -- 4700
								end -- 4700
							end -- 4700
						end -- 4700
						::__continue773:: -- 4700
						k = k + 1 -- 4679
					end -- 4679
				end -- 4679
			end -- 4679
			::__continue770:: -- 4679
			i = i + 1 -- 4672
		end -- 4672
	end -- 4672
	self:checkCarryGate() -- 4706
end -- 4629
function Play.prototype.stepVillage(self, dt, input) -- 4710
	if self.room.key ~= "village" then -- 4710
		return -- 4712
	end -- 4712
	local p = self.player -- 4714
	local bottle = self.room.bottle -- 4715
	local scav = self.room.scavenger -- 4716
	if not self.hasBottle and bottle ~= nil then -- 4716
		local dx = p.x - bottle.x -- 4720
		local dy = p.y + p.h * 0.5 - bottle.y -- 4721
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4721
			self.hasBottle = true -- 4723
			self:flashSet("拾起瓶子", 0.8) -- 4724
		end -- 4724
	end -- 4724
	if self.hasBottle then -- 4724
		local kbmMouseAim = input:isKbmMode() and input.inside -- 4730
		local rawAimHeld = input.aim.held or kbmMouseAim and input.fire.held -- 4731
		local rawAimReleased = input.aim.released or kbmMouseAim and input.fire.released -- 4732
		if input.bottleCanceled then -- 4732
			self.aimHold = 0 -- 4734
			self.bottleAimX = -1 -- 4735
			self.bottleAimCancelLatch = rawAimHeld -- 4736
		elseif self.bottleAimCancelLatch then -- 4736
			self.bottleAimCancelLatch = rawAimHeld -- 4738
		elseif rawAimHeld then -- 4738
			self.aimHold = self.aimHold + dt -- 4740
			if self.aimHold > 1.2 then -- 4740
				self.aimHold = 1.2 -- 4742
			end -- 4742
			local cached = self:bottleEnd() -- 4745
			self.bottleAimX = cached.x -- 4746
			self.bottleAimY = cached.y -- 4747
			self.bottleAimDepth = cached.depth -- 4748
			self.bottleAimHitBasin = cached.hitBasin -- 4749
		elseif rawAimReleased then -- 4749
			if self.aimHold < 0.12 then -- 4749
				self:flashSet( -- 4753
					input:isKbmMode() and "按住 F 或左键瞄一下再松手" or "按住 F 瞄一下再松手", -- 4753
					0.9 -- 4753
				) -- 4753
				self.aimHold = 0 -- 4754
			else -- 4754
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY, depth = self.bottleAimDepth, hitBasin = self.bottleAimHitBasin}) or self:bottleEnd() -- 4756
				self:throwBottle(____end) -- 4759
				self.aimHold = 0 -- 4760
			end -- 4760
		end -- 4760
	else -- 4760
		self.aimHold = 0 -- 4764
		self.bottleAimX = -1 -- 4765
		self.bottleAimCancelLatch = false -- 4766
	end -- 4766
	local fly = self.bottleFly -- 4771
	if fly ~= nil then -- 4771
		fly.t = fly.t + dt -- 4773
		fly.x = fly.x0 + fly.vx * fly.t -- 4774
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4775
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4776
		if fly.t >= ____exports.BOTTLE_FLY_TIME and falling then -- 4776
			self:landBottle(fly) -- 4778
		end -- 4778
	end -- 4778
	if self.bottleLandT > 0 then -- 4778
		self.bottleLandT = self.bottleLandT - dt -- 4782
	end -- 4782
	if scav ~= nil then -- 4782
		self:stepScav(dt, scav) -- 4786
	end -- 4786
	local line = self.room.passLine -- 4789
	if line ~= nil and not self.passed and p.x >= line then -- 4789
		self.passed = true -- 4791
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4792
	end -- 4792
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4795
	if underTable then -- 4795
		self.footHintT = self.footHintT - 1 -- 4797
		if self.footHintT <= 0 then -- 4797
			self.footHintT = 90 -- 4799
			local scavX = self.scavX -- 4800
			local near = math.abs(scavX - p.x) < 120 -- 4801
			local walkingAway = self.scavState == "walk" and math.abs(self.scavTargetX - p.x) >= 120 -- 4802
			local heard = self.scavState == "chase" or near and not walkingAway -- 4803
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4804
			self:emit("storyBeat", {beat = heard and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4805
		end -- 4805
	else -- 4805
		self.footHintT = 0 -- 4808
	end -- 4808
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4808
		self.ditchHinted = true -- 4812
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4813
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4814
	end -- 4814
	local inCulvert = p.x >= self.ox + 560 and p.x <= self.ox + 640 -- 4817
	if self.passed and inCulvert and p.crouch and self.wantRoom == "" then -- 4817
		self:requestRoom("forest", "蹲下钻过暗渠") -- 4819
		self:flashSet("钻进暗渠 · 北塔森林", 1.4) -- 4820
	end -- 4820
end -- 4710
function Play.prototype.bottleEnd(self) -- 4825
	if self.bottleMapper ~= nil then -- 4825
		local hit = self:bottleMapper(self.aimX, self.aimY) -- 4827
		hit.x = math.max( -- 4828
			self.room.minX + 12, -- 4828
			math.min(self.room.maxX - 12, hit.x) -- 4828
		) -- 4828
		return hit -- 4829
	end -- 4829
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4831
	local clampedX = math.max( -- 4834
		self.room.minX + 12, -- 4834
		math.min(self.room.maxX - 12, aim.x) -- 4834
	) -- 4834
	local g = self:groundAt(clampedX, aim.y + 240, 3) -- 4835
	return {x = clampedX, y = g, depth = 0} -- 4836
end -- 4825
function Play.prototype.throwBottle(self, ____end) -- 4840
	local tx = ____end.x -- 4841
	local ty = ____end.y -- 4842
	local p = self.player -- 4843
	local dir = tx >= p.x and 1 or -1 -- 4845
	p.facing = dir -- 4846
	local x0 = p.x + dir * 10 -- 4847
	local y0 = p.y + p.h * 0.7 -- 4848
	self.bottleTargetX = tx -- 4849
	self.bottleTargetY = ty -- 4850
	self.bottleSurfaceY = ty -- 4851
	local vx = (tx - x0) / ____exports.BOTTLE_FLY_TIME -- 4852
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * ____exports.BOTTLE_FLY_TIME * ____exports.BOTTLE_FLY_TIME) / ____exports.BOTTLE_FLY_TIME -- 4853
	self.bottleFly = { -- 4854
		x = x0, -- 4854
		y = y0, -- 4854
		x0 = x0, -- 4854
		y0 = y0, -- 4854
		vx = vx, -- 4854
		vy = vy, -- 4854
		t = 0, -- 4854
		startDepth = p.depth, -- 4854
		target = ____end -- 4854
	} -- 4854
	self.hasBottle = false -- 4855
	self:flashSet("投出", 0.4) -- 4856
	self:emit( -- 4857
		"bottleThrown", -- 4857
		{ -- 4857
			fromX = x0, -- 4858
			fromY = y0, -- 4859
			targetX = tx, -- 4860
			targetY = ty, -- 4861
			flightTicks = math.floor(____exports.BOTTLE_FLY_TIME * 60 + 0.5) -- 4862
		} -- 4862
	) -- 4862
end -- 4840
function Play.prototype.bottleSurfaceAt(self, x, hitBasin) -- 4867
	if self.room.softX ~= nil and math.abs(x - self.room.softX) <= 34 then -- 4867
		return "soft" -- 4869
	end -- 4869
	local ____hitBasin_139 = hitBasin -- 4871
	if ____hitBasin_139 == nil then -- 4871
		____hitBasin_139 = self.room.basinX ~= nil and math.abs(x - self.room.basinX) <= 24 -- 4871
	end -- 4871
	if ____hitBasin_139 then -- 4871
		return "iron" -- 4872
	end -- 4872
	return "brick" -- 4874
end -- 4867
function Play.prototype.landBottle(self, fly) -- 4878
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4879
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4880
	local s = self.room.scavenger -- 4881
	local surface = self:bottleSurfaceAt(x, fly.target.hitBasin) -- 4882
	local effRange = s == nil and 0 or (surface == "iron" and s.range * 1.25 or s.range) -- 4883
	local heard = surface ~= "soft" and s ~= nil and math.abs(x - self.scavX) <= effRange -- 4884
	local stallTicks = s == nil and 0 or (surface == "iron" and s.stallTicks + 90 or s.stallTicks) -- 4885
	self.bottleFly = nil -- 4886
	self.bottleTargetX = -1 -- 4887
	self.bottleTargetY = 0 -- 4888
	self.bottleSurfaceY = -1 -- 4889
	self.bottleLandX = x -- 4890
	self.bottleLandY = y -- 4891
	self.bottleLandDepth = fly.target.depth -- 4892
	self.bottleLandSurface = surface -- 4893
	self.bottleLandT = 0.9 -- 4894
	self:emit("bottleLanded", { -- 4895
		x = x, -- 4896
		y = y, -- 4897
		surface = surface, -- 4898
		heard = heard, -- 4899
		resonance = surface == "iron", -- 4900
		stallTicks = heard and stallTicks or 0, -- 4901
		scavState = self.scavState -- 4902
	}) -- 4902
	self:hearBottle(x, surface) -- 4904
end -- 4878
function Play.prototype.hearBottle(self, x, surface) -- 4908
	if surface == nil then -- 4908
		surface = "brick" -- 4908
	end -- 4908
	local s = self.room.scavenger -- 4909
	if s == nil then -- 4909
		return -- 4911
	end -- 4911
	if surface == "soft" then -- 4911
		self:flashSet("落在软土 · 没出声", 0.8) -- 4914
		return -- 4915
	end -- 4915
	local effRange = surface == "iron" and s.range * 1.25 or s.range -- 4917
	if math.abs(x - self.scavX) > effRange then -- 4917
		self:flashSet("落地 · 他没听见", 0.6) -- 4919
		return -- 4920
	end -- 4920
	self.scavState = "turn" -- 4922
	self.scavT = s.hearTicks -- 4923
	self.scavTargetX = surface == "iron" and self.room.basinX ~= nil and self.room.basinX or x -- 4924
	self.scavStallBonus = surface == "iron" and 90 or 0 -- 4925
	self:flashSet(surface == "iron" and "铁盆余振两响 · 他停下来细听" or "砖地一响 · 他转头", 1.1) -- 4926
end -- 4908
function Play.prototype.stepScav(self, dt, s) -- 4930
	if self.scavState == "chase" then -- 4930
		return -- 4933
	end -- 4933
	if self.scavState == "turn" then -- 4933
		self.scavT = self.scavT - 1 -- 4936
		if self.scavT <= 0 then -- 4936
			self.scavState = "walk" -- 4938
		end -- 4938
		return -- 4940
	end -- 4940
	if self.scavState == "walk" then -- 4940
		local d = self.scavTargetX - self.scavX -- 4943
		if math.abs(d) < 4 then -- 4943
			self.scavState = "stall" -- 4945
			self.scavT = s.stallTicks + self.scavStallBonus -- 4946
			self.scavStallBonus = 0 -- 4947
			return -- 4948
		end -- 4948
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4950
		return -- 4951
	end -- 4951
	if self.scavState == "stall" then -- 4951
		self.scavT = self.scavT - 1 -- 4954
		if self.scavT <= 0 then -- 4954
			self.scavState = "back" -- 4956
		end -- 4956
		return -- 4958
	end -- 4958
	if self.scavState == "back" then -- 4958
		local home = math.max( -- 4961
			s.x0, -- 4961
			math.min(s.x1, self.scavX) -- 4961
		) -- 4961
		if math.abs(home - self.scavX) < 2 then -- 4961
			self.scavState = "patrol" -- 4963
			return -- 4964
		end -- 4964
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4966
		return -- 4967
	end -- 4967
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4969
	if self.scavX >= s.x1 then -- 4969
		self.scavX = s.x1 -- 4971
		self.scavDir = -1 -- 4972
	elseif self.scavX <= s.x0 then -- 4972
		self.scavX = s.x0 -- 4974
		self.scavDir = 1 -- 4975
	end -- 4975
end -- 4930
function Play.prototype.stepCart(self, dt, input) -- 4983
	local p = self.player -- 4984
	local c = self.room.cart -- 4985
	if self.gripping then -- 4985
		if not input.interact.held then -- 4985
			self.gripping = false -- 4989
			self:flashSet("松开车把", 0.4) -- 4990
			return -- 4991
		end -- 4991
	else -- 4991
		if not input.interact.pressed then -- 4991
			return -- 4995
		end -- 4995
		if not self:cartHandleInReach(p) then -- 4995
			return -- 4998
		end -- 4998
		local track = c.depth or 0 -- 5000
		if self:limitDepth(p, track) ~= track then -- 5000
			return -- 5002
		end -- 5002
		p.depth = track -- 5004
		p.depthSpeed = 0 -- 5005
		self.gripping = true -- 5006
		self:flashSet("握住车把", 0.4) -- 5007
		return -- 5008
	end -- 5008
	if self.cartDocked then -- 5008
		return -- 5012
	end -- 5012
	local dir = input.moveX -- 5014
	if dir == 0 then -- 5014
		return -- 5016
	end -- 5016
	local lo = math.min(c.startX, c.endX) -- 5018
	local hi = math.max(c.startX, c.endX) -- 5019
	local next = self.cartAxle + dir * CART_SPEED * dt -- 5020
	if next < lo then -- 5020
		next = lo -- 5022
	end -- 5022
	if next > hi then -- 5022
		next = hi -- 5025
	end -- 5025
	local delta = next - self.cartAxle -- 5027
	if delta == 0 then -- 5027
		return -- 5029
	end -- 5029
	self.cartAxle = next -- 5031
	p.x = p.x + delta -- 5032
	p.facing = dir > 0 and 1 or -1 -- 5033
	self:slideX(p, 0) -- 5034
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 5034
		self.gripping = false -- 5036
		self:flashSet("跟不上了，脱手", 0.6) -- 5037
		return -- 5038
	end -- 5038
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 5038
		self.cartDocked = true -- 5041
		self.gripping = false -- 5042
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 5043
		self:flashSet("车轮落窝", 1.2) -- 5044
		if self.room.key == "outside" then -- 5044
			self:finishOutsideCart() -- 5046
		end -- 5046
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 5046
		self:flashSet("车轮回到起点", 0.5) -- 5049
	end -- 5049
end -- 4983
function Play.prototype.requestRoom(self, key, reason) -- 5057
	if self.wantRoom ~= "" then -- 5057
		return -- 5061
	end -- 5061
	self.wantRoom = key -- 5063
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 5064
end -- 5057
function Play.prototype.checkCarryGate(self) -- 5071
	if self.room.key == "checkpoint" then -- 5071
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 5071
			self.carryCartAxle = self.cartAxle -- 5074
			self.carryCartDocked = self.cartDocked -- 5075
			self:requestRoom("gate", "检查站出口") -- 5076
			self:flashSet("出检查站 · 城门", 1.2) -- 5077
		end -- 5077
		return -- 5079
	end -- 5079
	if self.room.key == "outside" then -- 5079
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 5079
			self.carryCartAxle = self.cartAxle -- 5085
			self.carryCartDocked = self.cartDocked -- 5086
			self:requestRoom("village", "墙根走完") -- 5087
			self:flashSet("墙根走完 · 进村口", 1.2) -- 5088
		end -- 5088
	end -- 5088
end -- 5071
function Play.prototype.aimAt(self, wx, wy) -- 5095
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 5096
	self.aimX = s.x -- 5097
	self.aimY = s.y -- 5098
end -- 5095
function Play.prototype.shoot(self, a) -- 5101
	if self.isCampaign and self.reloadT > 0 then -- 5101
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 5103
		return -- 5104
	end -- 5104
	local ox = a.x + a.facing * 8 -- 5106
	local muzzleY = a.y + a.h * 0.72 -- 5107
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 5108
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 5110
	local dx = aim.x - ox -- 5113
	local dy = aim.y - oy -- 5114
	local len = math.sqrt(dx * dx + dy * dy) -- 5115
	if len < 0.001 then -- 5115
		dx = a.facing -- 5117
		dy = 0 -- 5118
	else -- 5118
		dx = dx / len -- 5120
		dy = dy / len -- 5121
	end -- 5121
	if dx ~= 0 then -- 5121
		a.facing = dx > 0 and 1 or -1 -- 5124
	end -- 5124
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 5127
	local hitEnemy = self:raycastEnemies(ray) -- 5128
	local tEnemy = hitEnemy.t -- 5129
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 5130
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 5131
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 5132
	local tWall = solid.t -- 5133
	local rawEffect = self:consumeReloadEffect() -- 5135
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 5136
	local reloadEffect = rawEffect -- 5137
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 5139
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 5140
	self.trace = { -- 5142
		x0 = ox, -- 5142
		y0 = oy, -- 5142
		x1 = ox + dx * t, -- 5142
		y1 = oy + dy * t, -- 5142
		hit = hit -- 5142
	} -- 5142
	self.traceT = 0.12 -- 5143
	self:applyFireDanger(ox) -- 5144
	local killed = false -- 5145
	if hit then -- 5145
		local i = hitEnemy.index -- 5147
		local e = self.enemies[i + 1] -- 5148
		local impactY = oy + dy * tEnemy -- 5149
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 5150
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 5151
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 5151
			local pushRank = self:talentRank("push_force") -- 5153
			local dmg = reloadEffect == "push" and 2 + pushRank or 1 -- 5154
			e.shieldHp = math.max(0, (e.shieldHp or 0) - dmg) -- 5155
			e.hitT = 0.3 -- 5156
			if reloadEffect == "push" then -- 5156
				local kb = 46 + 24 * pushRank -- 5158
				e.x = math.max( -- 5159
					self.room.minX + 20, -- 5159
					math.min(self.room.maxX - 20, e.x + a.facing * kb) -- 5159
				) -- 5159
				if pushRank > 0 then -- 5159
					self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5161
				end -- 5161
				self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5163
				self:flashSet(e.shieldHp <= 0 and "推退破盾！" or "推退震退持盾手", 0.9) -- 5164
			else -- 5164
				self:flashSet( -- 5166
					(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 5166
					0.8 -- 5166
				) -- 5166
			end -- 5166
			self:emit("shotResolved", { -- 5168
				hit = true, -- 5169
				enemyIndex = i, -- 5169
				enemyX = e.x, -- 5169
				aimX = aim.x, -- 5169
				aimY = aim.y, -- 5169
				impactX = ox + dx * t, -- 5170
				impactY = oy + dy * t, -- 5170
				shield = true -- 5170
			}) -- 5170
			self:beginReload() -- 5172
			return -- 5173
		end -- 5173
		e.alive = false -- 5175
		e.hitT = 0.4 -- 5176
		killed = true -- 5177
		self:flashSet("命中", 0.6) -- 5178
		self:dropFor(e) -- 5179
		local lpRank = self:talentRank("lantern_pierce") -- 5180
		if reloadEffect == "light" and (weaponFx == "light" or lpRank > 0) then -- 5180
			local blindRadius = (weaponFx == "light" and 160 or 110) + 50 * lpRank -- 5182
			self:blindNearby(e, blindRadius, i) -- 5183
		end -- 5183
		if reloadEffect == "push" then -- 5183
			local pushRank = self:talentRank("push_force") -- 5186
			e.x = e.x + a.facing * (46 + 24 * pushRank) -- 5187
			if pushRank > 0 then -- 5187
				self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5189
			end -- 5189
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5191
		elseif reloadEffect == "echo" then -- 5191
			local echoRank = self:talentRank("echo_wide") -- 5193
			self:echoToSource(a, (weaponFx == "echo" and 2 or 1) + echoRank, 60 + 30 * echoRank) -- 5194
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 5195
		elseif reloadEffect == "light" then -- 5195
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 5197
		end -- 5197
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 5197
		self:damageProp(solid.box, 1) -- 5200
	else -- 5200
		self:flashSet("打空", 0.35) -- 5202
	end -- 5202
	if self.isCampaign then -- 5202
		self:beginReload() -- 5205
	end -- 5205
	self:emit("shotResolved", { -- 5207
		hit = hit, -- 5208
		enemyIndex = hit and hitEnemy.index or -1, -- 5209
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 5210
		aimX = aim.x, -- 5211
		aimY = aim.y, -- 5212
		impactX = ox + dx * t, -- 5213
		impactY = oy + dy * t -- 5214
	}) -- 5214
end -- 5101
function Play.prototype.staggerNearby(self, center, radius, delayTicks, skipIndex) -- 5219
	local i = 0 -- 5220
	do -- 5220
		i = 0 -- 5221
		while i < #self.enemies do -- 5221
			do -- 5221
				if i == skipIndex then -- 5221
					goto __continue871 -- 5223
				end -- 5223
				local e = self.enemies[i + 1] -- 5225
				if not e.alive or math.abs(e.x - center.x) > radius then -- 5225
					goto __continue871 -- 5227
				end -- 5227
				e.warnT = 0 -- 5229
				e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 5230
				local pushDir = e.x >= center.x and 1 or -1 -- 5231
				e.x = math.max( -- 5232
					self.room.minX + 20, -- 5232
					math.min(self.room.maxX - 20, e.x + pushDir * 22) -- 5232
				) -- 5232
			end -- 5232
			::__continue871:: -- 5232
			i = i + 1 -- 5221
		end -- 5221
	end -- 5221
end -- 5219
function Play.prototype.applyFireDanger(self, shotX) -- 5237
	local ____temp_145 = self.isCampaign and self.run.joined -- 5238
	if ____temp_145 then -- 5238
		local ____opt_140 = self.room.campaign -- 5238
		local ____temp_144 = (____opt_140 and ____opt_140.chapter) == "S" -- 5239
		if not ____temp_144 then -- 5239
			local ____opt_142 = self.room.campaign -- 5239
			____temp_144 = (____opt_142 and ____opt_142.chapter) == "C" -- 5239
		end -- 5239
		____temp_145 = ____temp_144 -- 5238
	end -- 5238
	local isStorySc = ____temp_145 -- 5238
	if self.room.key ~= "checkpoint" and not isStorySc or not self.partner.alive then -- 5238
		return -- 5241
	end -- 5241
	local dangerX = shotX -- 5243
	local best = -1 -- 5244
	local bestD = 1000000000 -- 5245
	local i = 0 -- 5246
	do -- 5246
		i = 0 -- 5247
		while i < #self.enemies do -- 5247
			do -- 5247
				local e = self.enemies[i + 1] -- 5248
				if not e.alive then -- 5248
					goto __continue877 -- 5250
				end -- 5250
				local d = math.abs(e.x - self.partner.x) -- 5252
				if d < bestD then -- 5252
					bestD = d -- 5254
					best = i -- 5255
				end -- 5255
			end -- 5255
			::__continue877:: -- 5255
			i = i + 1 -- 5247
		end -- 5247
	end -- 5247
	if best >= 0 then -- 5247
		dangerX = self.enemies[best + 1].x -- 5259
	end -- 5259
	if isStorySc and math.abs(dangerX - self.partner.x) > 260 then -- 5259
		return -- 5263
	end -- 5263
	local exposed = self:childExposed(dangerX) -- 5265
	local before = self.escort.fear -- 5266
	local dangerId = self.nextDangerId -- 5267
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 5268
	self.nextDangerId = self.nextDangerId + 1 -- 5269
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 5270
	if after > before then -- 5270
		self:flashSet( -- 5272
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 5272
			1 -- 5272
		) -- 5272
	elseif not exposed then -- 5272
		self:flashSet("枪声没够到她", 0.5) -- 5274
	end -- 5274
end -- 5237
function Play.prototype.childExposed(self, dangerX) -- 5279
	local c = self.partner -- 5280
	if not c.alive then -- 5280
		return false -- 5282
	end -- 5282
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 5282
		self.boxes, -- 5285
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 5285
	) then -- 5285
		return false -- 5286
	end -- 5286
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 5286
		return false -- 5289
	end -- 5289
	local toDanger = dangerX - c.x -- 5291
	local toPlayer = self.player.x - c.x -- 5292
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 5292
		return false -- 5295
	end -- 5295
	return true -- 5297
end -- 5279
function Play.prototype.raycastEnemies(self, ray) -- 5301
	local best = -1 -- 5302
	local bestI = -1 -- 5303
	do -- 5303
		local i = 0 -- 5304
		while i < #self.enemies do -- 5304
			do -- 5304
				local e = self.enemies[i + 1] -- 5305
				if not e.alive then -- 5305
					goto __continue892 -- 5307
				end -- 5307
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 5309
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 5310
				if t >= 0 and (best < 0 or t < best) then -- 5310
					best = t -- 5312
					bestI = i -- 5313
				end -- 5313
			end -- 5313
			::__continue892:: -- 5313
			i = i + 1 -- 5304
		end -- 5304
	end -- 5304
	return {t = best, index = bestI} -- 5316
end -- 5301
function Play.prototype.raycastWorld(self, ray) -- 5319
	return self:raycastSolid(ray).t -- 5320
end -- 5319
function Play.prototype.raycastSolid(self, ray) -- 5324
	local best = -1 -- 5325
	local bestBox = nil -- 5326
	for ____, box in ipairs(self.boxes) do -- 5327
		do -- 5327
			if box.broken == true or box.hidden == true then -- 5327
				goto __continue897 -- 5329
			end -- 5329
			local t = hitBox(ray, box) -- 5334
			if t > 2 and (best < 0 or t < best) then -- 5334
				best = t -- 5337
				bestBox = box -- 5338
			end -- 5338
		end -- 5338
		::__continue897:: -- 5338
	end -- 5338
	if ray.dy < 0 then -- 5338
		local t = -ray.y / ray.dy -- 5342
		if t >= 0 and (best < 0 or t < best) then -- 5342
			best = t -- 5344
			bestBox = nil -- 5345
		end -- 5345
	end -- 5345
	return {t = best, box = bestBox} -- 5348
end -- 5324
function Play.prototype.dropFor(self, e) -- 5352
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 5352
		return -- 5354
	end -- 5354
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 5354
		return -- 5357
	end -- 5357
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 5359
	local ____self_pickups_146 = self.pickups -- 5359
	____self_pickups_146[#____self_pickups_146 + 1] = { -- 5360
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 5361
		kind = e.drop, -- 5361
		x = e.x, -- 5361
		y = e.y, -- 5361
		depth = e.depth, -- 5362
		label = label .. " ×1" -- 5362
	} -- 5362
	self:log("掉落 " .. label) -- 5364
end -- 5352
function Play.prototype.damageProp(self, b, amount) -- 5368
	if b.breakable == nil or b.broken == true then -- 5368
		return -- 5370
	end -- 5370
	local ____b_breakable_147, ____hp_148 = b.breakable, "hp" -- 5370
	____b_breakable_147[____hp_148] = ____b_breakable_147[____hp_148] - amount -- 5372
	if b.breakable.hp > 0 then -- 5372
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 5374
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 5375
		return -- 5376
	end -- 5376
	b.broken = true -- 5378
	for ____, other in ipairs(self.boxes) do -- 5379
		if other.id ~= nil and other.id == b.id then -- 5379
			other.broken = true -- 5381
		end -- 5381
	end -- 5381
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 5384
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 5385
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 5386
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 5387
end -- 5368
function Play.prototype.slideDepth(self, a, distance) -- 5391
	a.depth = self:limitDepth(a, a.depth + distance) -- 5392
end -- 5391
function Play.prototype.limitDepth(self, a, target) -- 5395
	local road = self.room.depth -- 5396
	if road == nil or target == a.depth then -- 5396
		return a.depth -- 5398
	end -- 5398
	local next = math.max( -- 5400
		road.min, -- 5400
		math.min(road.max, target) -- 5400
	) -- 5400
	local half = a.w / 2 -- 5401
	for ____, b in ipairs(self.boxes) do -- 5402
		do -- 5402
			local footprint = b.depth -- 5403
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5403
				goto __continue915 -- 5408
			end -- 5408
			local front = footprint.min - ACTOR_DEPTH_HALF -- 5410
			local back = footprint.max + ACTOR_DEPTH_HALF -- 5411
			if a.depth <= front and next > front then -- 5411
				next = front -- 5413
			elseif a.depth >= back and next < back then -- 5413
				next = back -- 5415
			end -- 5415
		end -- 5415
		::__continue915:: -- 5415
	end -- 5415
	return next -- 5418
end -- 5395
function Play.prototype.cartLatchBounds(self) -- 5422
	if self.room.key ~= "outside" or self.cartDocked then -- 5422
		return nil -- 5423
	end -- 5423
	local arch = self.room.arch -- 5424
	local halfWidth = self.room.cart.bodyW / 2 -- 5425
	local left = math.max(arch.x0, self.room.cart.startX - halfWidth) -- 5426
	local right = math.min(arch.x1, self.room.cart.startX + halfWidth) -- 5427
	return right > left and Rect(left, arch.y, right - left, arch.h) or nil -- 5428
end -- 5422
function Play.prototype.slideX(self, a, dx) -- 5432
	local nx = a.x + dx -- 5433
	local half = a.w / 2 -- 5434
	local room = self.room -- 5435
	nx = math.max( -- 5436
		room.minX + half, -- 5436
		math.min(room.maxX - half, nx) -- 5436
	) -- 5436
	local i = 0 -- 5437
	do -- 5437
		i = 0 -- 5438
		while i < #self.boxes do -- 5438
			do -- 5438
				local b = self.boxes[i + 1] -- 5439
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5439
					goto __continue924 -- 5441
				end -- 5441
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5441
					goto __continue924 -- 5444
				end -- 5444
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5444
					goto __continue924 -- 5447
				end -- 5447
				if nx + half > b.x0 and nx - half < b.x1 then -- 5447
					if a.x <= b.x0 then -- 5447
						nx = b.x0 - half -- 5451
					elseif a.x >= b.x1 then -- 5451
						nx = b.x1 + half -- 5453
					else -- 5453
						nx = a.x -- 5455
					end -- 5455
				end -- 5455
			end -- 5455
			::__continue924:: -- 5455
			i = i + 1 -- 5438
		end -- 5438
	end -- 5438
	local latch = self:cartLatchBounds() -- 5459
	if latch ~= nil and a.y < latch.y + latch.height - 0.001 and nx + half > latch.x and nx - half < latch.x + latch.width then -- 5459
		if a.x <= latch.x then -- 5459
			nx = latch.x - half -- 5463
		elseif a.x >= latch.x + latch.width then -- 5463
			nx = latch.x + latch.width + half -- 5465
		else -- 5465
			nx = a.x -- 5467
		end -- 5467
	end -- 5467
	local arch = room.arch -- 5474
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 5474
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 5476
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 5476
			if a.x <= arch.x0 then -- 5476
				nx = arch.x0 - half -- 5479
			elseif a.x >= arch.x1 then -- 5479
				nx = arch.x1 + half -- 5481
			end -- 5481
		end -- 5481
	end -- 5481
	a.x = nx -- 5485
end -- 5432
function Play.prototype.fallY(self, a, dt) -- 5489
	a.vy = a.vy - ____exports.GRAVITY * dt -- 5490
	if a.vy < -900 then -- 5490
		a.vy = -900 -- 5492
	end -- 5492
	local ny = a.y + a.vy * dt -- 5494
	local half = a.w / 2 -- 5495
	if a.vy <= 0 then -- 5495
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 5498
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 5499
		if ny <= ground then -- 5499
			ny = ground -- 5501
			a.vy = 0 -- 5502
			a.onGround = true -- 5503
		else -- 5503
			a.onGround = false -- 5505
		end -- 5505
	else -- 5505
		a.onGround = false -- 5508
		local i = 0 -- 5509
		do -- 5509
			i = 0 -- 5510
			while i < #self.boxes do -- 5510
				do -- 5510
					local b = self.boxes[i + 1] -- 5511
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5511
						goto __continue947 -- 5513
					end -- 5513
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5513
						goto __continue947 -- 5516
					end -- 5516
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 5516
						goto __continue947 -- 5519
					end -- 5519
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 5519
						ny = b.y0 - a.h -- 5522
						a.vy = 0 -- 5523
					end -- 5523
				end -- 5523
				::__continue947:: -- 5523
				i = i + 1 -- 5510
			end -- 5510
		end -- 5510
	end -- 5510
	a.y = ny -- 5527
end -- 5489
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 5531
	if depth == nil then -- 5531
		depth = 0 -- 5531
	end -- 5531
	local g = -9999 -- 5532
	local i = 0 -- 5533
	do -- 5533
		i = 0 -- 5534
		while i < #self.floors do -- 5534
			local f = self.floors[i + 1] -- 5535
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 5535
				g = f.y1 -- 5537
			end -- 5537
			i = i + 1 -- 5534
		end -- 5534
	end -- 5534
	do -- 5534
		i = 0 -- 5540
		while i < #self.boxes do -- 5540
			do -- 5540
				local b = self.boxes[i + 1] -- 5541
				if b.broken == true or b.hidden == true or b.soft == true then -- 5541
					goto __continue957 -- 5543
				end -- 5543
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 5543
					g = b.y1 -- 5547
				end -- 5547
			end -- 5547
			::__continue957:: -- 5547
			i = i + 1 -- 5540
		end -- 5540
	end -- 5540
	return g -- 5550
end -- 5531
function Play.prototype.updateCamera(self, dt) -- 5553
	local p = self.player -- 5554
	local tx = p.x + p.facing * 30 -- 5555
	local ty = p.y + CAM_LOOK_UP -- 5556
	local k = math.min(1, CAM_FOLLOW * dt) -- 5557
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 5558
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 5559
end -- 5553
function Play.prototype.clampCamera(self, w, h) -- 5563
	local room = self.room -- 5564
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 5565
	local spanX = room.maxX - room.minX -- 5566
	if spanX <= halfW * 2 then -- 5566
		self.cam.x = (room.minX + room.maxX) / 2 -- 5568
	else -- 5568
		self.cam.x = math.max( -- 5570
			room.minX + halfW, -- 5570
			math.min(room.maxX - halfW, self.cam.x) -- 5570
		) -- 5570
	end -- 5570
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 5573
	local spanY = room.height -- 5574
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 5575
	if spanY <= halfH * 2 then -- 5575
		self.cam.y = camY -- 5577
	else -- 5577
		self.cam.y = math.max( -- 5579
			camY, -- 5579
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 5579
		) -- 5579
	end -- 5579
end -- 5563
function Play.prototype.flashSet(self, text, t) -- 5583
	self.flash = text -- 5584
	self.flashT = t -- 5585
end -- 5583
function Play.prototype.statusText(self) -- 5589
	local p = self.player -- 5590
	local parts = {} -- 5591
	local who = self.childMode and "小满" or "周戍" -- 5592
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 5593
	if self.room.key == "prologue" then -- 5593
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5596
		if self.phase == "prologue-wake" then -- 5596
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 5598
		elseif self.phase == "prologue-shadow" then -- 5598
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 5600
		elseif self.phase == "prologue-escape" then -- 5600
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 5602
		elseif self.phase == "prologue-hide" then -- 5602
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 5604
		elseif self.phase == "prologue-wait" then -- 5604
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 5606
		elseif self.phase == "prologue-give" then -- 5606
			parts[#parts + 1] = (("递物 " .. tostring(self.phaseTick)) .. "/") .. tostring(____exports.PROLOGUE_GIVE_TICKS) -- 5608
		else -- 5608
			parts[#parts + 1] = "跟随" -- 5610
		end -- 5610
		if self.paused then -- 5610
			parts[#parts + 1] = "已暂停" -- 5613
		end -- 5613
		return table.concat(parts, " · ") -- 5615
	end -- 5615
	if self.room.key == "street" then -- 5615
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5618
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5619
		if self.paused then -- 5619
			parts[#parts + 1] = "已暂停" -- 5621
		end -- 5621
		return table.concat(parts, " · ") -- 5623
	end -- 5623
	if self.room.key == "gate" then -- 5623
		local ____temp_149 -- 5626
		if self.room.story == nil then -- 5626
			____temp_149 = nil -- 5626
		else -- 5626
			____temp_149 = self.room.story.gate -- 5626
		end -- 5626
		local g = ____temp_149 -- 5626
		if g ~= nil then -- 5626
			parts[#parts + 1] = self:gateLabel() -- 5628
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 5629
				0, -- 5630
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 5630
			))) .. " 秒" -- 5630
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5631
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5632
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 5633
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 5634
			if self.gateFailCount > 0 then -- 5634
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 5636
			end -- 5636
			if self.flash ~= "" then -- 5636
				parts[#parts + 1] = self.flash -- 5639
			end -- 5639
		end -- 5639
		if self.paused then -- 5639
			parts[#parts + 1] = "已暂停" -- 5643
		end -- 5643
		return table.concat(parts, " · ") -- 5645
	end -- 5645
	if self.room.key == "forest" then -- 5645
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5648
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5649
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5650
		if self.caughtT > 0 then -- 5650
			parts[#parts + 1] = "复位中" -- 5652
		end -- 5652
		if self.paused then -- 5652
			parts[#parts + 1] = "已暂停" -- 5655
		end -- 5655
		return table.concat(parts, " · ") -- 5657
	end -- 5657
	if self.room.key == "tower" then -- 5657
		if self.phase == "tower-wait" then -- 5657
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5661
		elseif self.phase == "tower-knock" then -- 5661
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5663
		elseif self.phase == "tower-enter" then -- 5663
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5665
		elseif self.phase == "tower-desk" then -- 5665
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5667
		elseif self.phase == "tower-given" then -- 5667
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5669
		else -- 5669
			parts[#parts + 1] = "片尾" -- 5671
		end -- 5671
		if self.paused then -- 5671
			parts[#parts + 1] = "已暂停" -- 5674
		end -- 5674
		return table.concat(parts, " · ") -- 5676
	end -- 5676
	if self.room.key == "village" then -- 5676
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5679
		if self.hasBottle then -- 5679
			parts[#parts + 1] = "有瓶" -- 5681
		elseif self.bottleFly ~= nil then -- 5681
			parts[#parts + 1] = "瓶在飞" -- 5683
		else -- 5683
			parts[#parts + 1] = "空手" -- 5685
		end -- 5685
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5687
		if self.scavChase then -- 5687
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5689
		end -- 5689
		if self.passed then -- 5689
			parts[#parts + 1] = "已过通行线" -- 5692
		end -- 5692
		if self.paused then -- 5692
			parts[#parts + 1] = "已暂停" -- 5695
		end -- 5695
		return table.concat(parts, " · ") -- 5697
	end -- 5697
	local isChild = self.childMode -- 5700
	if isChild then -- 5700
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5702
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5703
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5704
	else -- 5704
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5706
		if p.rollT > 0 then -- 5706
			parts[#parts + 1] = "翻滚中" -- 5708
		end -- 5708
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5710
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5711
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5712
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5713
	end -- 5713
	if self.checkpoint >= 0 then -- 5713
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5716
	end -- 5716
	if self.paused then -- 5716
		parts[#parts + 1] = "已暂停" -- 5719
	end -- 5719
	return table.concat(parts, " · ") -- 5721
end -- 5589
function Play.prototype.aliveEnemies(self) -- 5725
	local n = 0 -- 5726
	local i = 0 -- 5727
	do -- 5727
		i = 0 -- 5728
		while i < #self.enemies do -- 5728
			if self.enemies[i + 1].alive then -- 5728
				n = n + 1 -- 5730
			end -- 5730
			i = i + 1 -- 5728
		end -- 5728
	end -- 5728
	return n -- 5733
end -- 5725
function Play.prototype.threatened(self) -- 5738
	do -- 5738
		local i = 0 -- 5739
		while i < #self.enemies do -- 5739
			local e = self.enemies[i + 1] -- 5740
			if e.alive and e.warnT > 0 then -- 5740
				return true -- 5742
			end -- 5742
			i = i + 1 -- 5739
		end -- 5739
	end -- 5739
	return false -- 5745
end -- 5738
function Play.prototype.gateSecondsLeft(self) -- 5748
	local ____temp_150 -- 5749
	if self.room.story == nil then -- 5749
		____temp_150 = nil -- 5749
	else -- 5749
		____temp_150 = self.room.story.gate -- 5749
	end -- 5749
	local g = ____temp_150 -- 5749
	if g == nil then -- 5749
		return 0 -- 5751
	end -- 5751
	return math.max( -- 5753
		0, -- 5753
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5753
	) -- 5753
end -- 5748
function Play.prototype.gateLabel(self) -- 5756
	if self.phase == "gate-idle" then -- 5756
		return "待就位" -- 5758
	end -- 5758
	if self.phase == "gate-hold" then -- 5758
		return "守点中" -- 5761
	end -- 5761
	if self.phase == "gate-send" then -- 5761
		return "送别" -- 5764
	end -- 5764
	if self.phase == "gate-farewell" then -- 5764
		return "嘱咐 " .. tostring(self.phaseTick) -- 5767
	end -- 5767
	if self.phase == "gate-count" then -- 5767
		return "数数 " .. tostring(self.countTick) -- 5770
	end -- 5770
	return "她走" -- 5772
end -- 5756
function Play.prototype.dogLabel(self) -- 5776
	if self.dogState == "ear" then -- 5776
		return "转耳" -- 5778
	end -- 5778
	if self.dogState == "chase" then -- 5778
		return "追" -- 5781
	end -- 5781
	if self.dogState == "sniff" then -- 5781
		return "停" -- 5784
	end -- 5784
	if self.dogState == "back" then -- 5784
		return "回线" -- 5787
	end -- 5787
	return "巡逻" -- 5789
end -- 5776
function Play.prototype.doorXOf(self) -- 5792
	local ____temp_151 -- 5793
	if self.room.story == nil then -- 5793
		____temp_151 = nil -- 5793
	else -- 5793
		____temp_151 = self.room.story.tower -- 5793
	end -- 5793
	local t = ____temp_151 -- 5793
	return t == nil and 0 or t.doorX -- 5794
end -- 5792
function Play.prototype.scavLabel(self) -- 5798
	if self.scavState == "chase" then -- 5798
		return "追" -- 5800
	end -- 5800
	if self.scavState == "turn" then -- 5800
		return "转头" -- 5803
	end -- 5803
	if self.scavState == "walk" then -- 5803
		return "赶来" -- 5806
	end -- 5806
	if self.scavState == "stall" then -- 5806
		return "停住" -- 5809
	end -- 5809
	if self.scavState == "back" then -- 5809
		return "回位" -- 5812
	end -- 5812
	return "巡逻" -- 5814
end -- 5798
function Play.prototype.hintText(self) -- 5818
	if self.paused then -- 5818
		return "Esc 继续 · R 重置" -- 5820
	end -- 5820
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5820
		if self:threatened() then -- 5820
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5826
		end -- 5826
		if self.coverHug then -- 5826
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5829
		end -- 5829
		if self.coverNear then -- 5829
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5832
		end -- 5832
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5834
	end -- 5834
	if self.flash ~= "" then -- 5834
		return self.flash -- 5837
	end -- 5837
	if self.room.key == "prologue" then -- 5837
		if self.phase == "prologue-wake" then -- 5837
			return "父亲在门外唤 · 小满睁眼" -- 5841
		end -- 5841
		if self.phase == "prologue-shadow" then -- 5841
			return "墙上两道人影 · 碗滚到脚边" -- 5844
		end -- 5844
		if self.phase == "prologue-escape" then -- 5844
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5847
		end -- 5847
		if self.phase == "prologue-hide" then -- 5847
			return "柜门合上 · 屏住呼吸" -- 5850
		end -- 5850
		if self.phase == "prologue-wait" then -- 5850
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5853
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5854
		end -- 5854
		if self.phase == "prologue-give" then -- 5854
			return ((("递物 " .. tostring(self.phaseTick)) .. " / ") .. tostring(____exports.PROLOGUE_GIVE_TICKS)) .. " 拍 · 站着别动" -- 5857
		end -- 5857
		return "她跟着你了 · 两人一起走到门口 680" -- 5859
	end -- 5859
	if self.room.key == "street" then -- 5859
		if self:aliveEnemies() > 0 then -- 5859
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5863
		end -- 5863
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5865
	end -- 5865
	if self.room.key == "gate" then -- 5865
		local ____temp_152 -- 5868
		if self.room.story == nil then -- 5868
			____temp_152 = nil -- 5868
		else -- 5868
			____temp_152 = self.room.story.gate -- 5868
		end -- 5868
		local g = ____temp_152 -- 5868
		if g ~= nil then -- 5868
			if self.phase == "gate-idle" then -- 5868
				if self.gateNeedConfirm then -- 5868
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5872
				end -- 5872
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5874
			end -- 5874
			if self.phase == "gate-hold" then -- 5874
				if self.coveredFlash > 0 then -- 5874
					return "掩体挡下了这一枪 · 别露头" -- 5878
				end -- 5878
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5880
			end -- 5880
			if self.phase == "gate-send" then -- 5880
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5883
			end -- 5883
			if self.phase == "gate-farewell" then -- 5883
				return "城门送别 · 嘱咐她慢慢数到二十" -- 5886
			end -- 5886
			if self.phase == "gate-count" then -- 5886
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5886
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5890
				end -- 5890
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5892
			end -- 5892
			return "她自己走 · 跟着出城门 1120" -- 5894
		end -- 5894
	end -- 5894
	if self.room.key == "forest" then -- 5894
		if self.dogState == "chase" then -- 5894
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5899
		end -- 5899
		if self.dogState == "ear" then -- 5899
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5902
		end -- 5902
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5904
	end -- 5904
	if self.room.key == "tower" then -- 5904
		if self.phase == "tower-wait" then -- 5904
			return "走到门前 445 点一次 E 敲两下" -- 5908
		end -- 5908
		if self.phase == "tower-knock" then -- 5908
			return "敲两下 · 等门开" -- 5911
		end -- 5911
		if self.phase == "tower-given" then -- 5911
			return "递交针套和纸条 · 看登记簿最后一行" -- 5914
		end -- 5914
		return "片尾 · 点 E 再玩一次，回到序章" -- 5916
	end -- 5916
	if self.room.key == "village" then -- 5916
		if self.bottleFly ~= nil then -- 5916
			return "等瓶子落地 · 触地才发声" -- 5920
		end -- 5920
		if self.hasBottle then -- 5920
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5923
		end -- 5923
		if self.passed then -- 5923
			return "已过第一院 · R 重置可再来一遍" -- 5926
		end -- 5926
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5928
	end -- 5928
	if self.room.key == "outside" then -- 5928
		if self.focusCart then -- 5928
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5932
		end -- 5932
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5934
	end -- 5934
	if self.escort.state == "frozen" then -- 5934
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5934
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5938
		end -- 5938
		return "小满吓住了 · 走过去，靠近再点 E" -- 5940
	end -- 5940
	if self.escort.state == "calming" then -- 5940
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5943
	end -- 5943
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5945
end -- 5818
return ____exports -- 5818