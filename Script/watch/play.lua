-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
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
local createRun = ____run.createRun -- 17
local mmss = ____run.mmss -- 17
local ____clock = require("Script.watch.clock") -- 19
local STEP = ____clock.STEP -- 19
local ____escort = require("Script.watch.escort") -- 20
local CALM_REACH = ____escort.CALM_REACH -- 20
local Escort = ____escort.Escort -- 20
local FEAR_MAX = ____escort.FEAR_MAX -- 20
local safeAnchorX = ____escort.safeAnchorX -- 20
local ____depth = require("Script.watch.depth") -- 21
local ACTOR_DEPTH_HALF = ____depth.ACTOR_DEPTH_HALF -- 21
local INTERACT_DEPTH_REACH = ____depth.INTERACT_DEPTH_REACH -- 21
local inReachDepth = ____depth.inReachDepth -- 21
local overlapsDepth = ____depth.overlapsDepth -- 21
function makeActor(room, index) -- 3819
	local sp = room.spawns -- 3820
	if index < 0 or index >= #sp then -- 3820
		return { -- 3822
			x = 0, -- 3822
			y = 0, -- 3822
			depth = 0, -- 3822
			depthSpeed = 0, -- 3822
			vx = 0, -- 3822
			vy = 0, -- 3822
			w = CHILD_W, -- 3822
			h = CHILD_H, -- 3822
			onGround = true, -- 3822
			facing = 1, -- 3822
			crouch = false, -- 3822
			rollT = 0, -- 3822
			covered = false, -- 3822
			alive = false -- 3822
		} -- 3822
	end -- 3822
	local s = sp[index + 1] -- 3824
	local child = s.h <= CHILD_H -- 3825
	local ground = room.depth -- 3826
	local depth = ground == nil and 0 or math.max( -- 3827
		ground.min, -- 3827
		math.min(ground.max, s.depth or 0) -- 3827
	) -- 3827
	return { -- 3828
		x = s.x, -- 3829
		y = s.y, -- 3829
		depth = depth, -- 3829
		depthSpeed = 0, -- 3829
		vx = 0, -- 3829
		vy = 0, -- 3829
		w = child and CHILD_W or SOLDIER_W, -- 3830
		h = child and CHILD_H or SOLDIER_H, -- 3831
		onGround = true, -- 3832
		facing = 1, -- 3832
		crouch = false, -- 3832
		rollT = 0, -- 3832
		covered = false, -- 3832
		alive = true -- 3832
	} -- 3832
end -- 3832
function drawFigure(draw, play, w, h, a, body, head) -- 3836
	if not a.alive then -- 3836
		return -- 3838
	end -- 3838
	local x0 = a.x - a.w / 2 -- 3840
	local x1 = a.x + a.w / 2 -- 3841
	local y0 = a.y + a.depth -- 3842
	local y1 = y0 + a.h -- 3843
	play:drawBox( -- 3844
		draw, -- 3844
		w, -- 3844
		h, -- 3844
		x0, -- 3844
		x1, -- 3844
		y0, -- 3844
		y1 - a.h * 0.26, -- 3844
		body -- 3844
	) -- 3844
	play:drawBox( -- 3845
		draw, -- 3845
		w, -- 3845
		h, -- 3845
		x0 + 2, -- 3845
		x1 - 2, -- 3845
		y1 - a.h * 0.26, -- 3845
		y1, -- 3845
		head -- 3845
	) -- 3845
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 3847
	play:drawBox( -- 3848
		draw, -- 3848
		w, -- 3848
		h, -- 3848
		eyeX, -- 3848
		eyeX + 4, -- 3848
		y1 - a.h * 0.14, -- 3848
		y1 - a.h * 0.08, -- 3848
		INK -- 3848
	) -- 3848
end -- 3848
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 3852
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 3853
end -- 3852
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 3860
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 3861
end -- 3860
function rayInterval(origin, direction, min, max) -- 3868
	if direction == 0 then -- 3868
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 3870
	end -- 3870
	local a = (min - origin) / direction -- 3872
	local b = (max - origin) / direction -- 3873
	return { -- 3874
		min = math.min(a, b), -- 3874
		max = math.max(a, b) -- 3874
	} -- 3874
end -- 3874
function hitBox(ray, box) -- 3878
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 3879
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 3880
	local enter = math.max(0, x.min, y.min) -- 3881
	local leave = math.min(99999, x.max, y.max) -- 3882
	if box.depth ~= nil then -- 3882
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 3884
		enter = math.max(enter, depth.min) -- 3885
		leave = math.min(leave, depth.max) -- 3886
	end -- 3886
	return leave >= enter and enter or -1 -- 3888
end -- 3888
function drawCartShape(draw, play, w, h, c, axleX) -- 3891
	local half = c.bodyW / 2 -- 3892
	local x0 = axleX - half -- 3893
	local x1 = axleX + half -- 3894
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 3895
	play:drawBox( -- 3896
		draw, -- 3896
		w, -- 3896
		h, -- 3896
		x0, -- 3896
		x1, -- 3896
		axleY, -- 3896
		axleY + c.bodyH, -- 3896
		CART_FILL -- 3896
	) -- 3896
	draw:drawCircle( -- 3897
		Vec2( -- 3897
			play:sx(x0 + c.bodyW * 0.28, w), -- 3897
			play:sy(axleY, h) -- 3897
		), -- 3897
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 3897
		Color(52, 50, 48, 255) -- 3897
	) -- 3897
	draw:drawCircle( -- 3898
		Vec2( -- 3898
			play:sx(x1 - c.bodyW * 0.28, w), -- 3898
			play:sy(axleY, h) -- 3898
		), -- 3898
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 3898
		Color(52, 50, 48, 255) -- 3898
	) -- 3898
	local cx = c.clothSide < 0 and x0 or x1 -- 3899
	play:drawBox( -- 3900
		draw, -- 3900
		w, -- 3900
		h, -- 3900
		cx - 10, -- 3900
		cx + 10, -- 3900
		axleY + c.bodyH, -- 3900
		axleY + c.bodyH + 18, -- 3900
		CLOTH -- 3900
	) -- 3900
end -- 3900
____exports.STEP = STEP -- 24
____exports.GRAVITY = 1000 -- 25
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 27
CHILD_W = 28 -- 62
CHILD_H = 64 -- 63
local CHILD_CROUCH_H = 36 -- 64
local CHILD_SPEED = 160 -- 65
local CHILD_SLOW = 80 -- 66
local CHILD_JUMP = 320 -- 67
SOLDIER_W = 30 -- 70
SOLDIER_H = 88 -- 71
local SOLDIER_SPEED = 264 -- 72
local ROLL_TIME = 0.35 -- 73
local ROLL_SPEED = 280 -- 74
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 76
local LEDGE_RISE = 60 -- 77
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 80
____exports.LOGIC_H = 180 -- 81
____exports.UNITS_PER_PX = 2 -- 82
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 84
local CAM_FOLLOW = 9 -- 85
local CAM_LOOK_UP = 46 -- 86
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 89
--- 握把触发半径。
____exports.CART_REACH = 70 -- 91
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 93
local CART_CLEAR = 44 -- 94
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 96
local FIRE_COOLDOWN = 150 -- 97
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 99
local ENEMY_RANGE = 760 -- 100
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 102
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 104
local DEPTH_SPEED_RATIO = 0.55 -- 105
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 106
INK = Color(232, 232, 228, 255) -- 108
local INK_DIM = Color(150, 152, 150, 255) -- 109
local BG_VOID = Color(8, 9, 10, 255) -- 110
local BG_FAR = Color(24, 26, 28, 255) -- 111
local BG_MID = Color(31, 34, 37, 255) -- 112
local GROUND = Color(112, 114, 112, 255) -- 113
local FLOOR_DECK = Color(66, 70, 72, 255) -- 114
local SOLID_FILL = Color(84, 86, 84, 255) -- 115
local SOLID_EDGE = Color(126, 130, 126, 255) -- 116
CART_FILL = Color(122, 78, 56, 255) -- 117
CLOTH = Color(178, 52, 46, 255) -- 118
local DANGER = Color(150, 54, 48, 46) -- 119
local DANGER_LINE = Color(178, 78, 64, 200) -- 120
local HOLE_FILL = Color(10, 11, 12, 255) -- 121
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 122
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 123
local CHILD_BODY = Color(214, 168, 96, 255) -- 124
local CHILD_HEAD = Color(232, 214, 186, 255) -- 125
local ENEMY_BODY = Color(176, 92, 84, 255) -- 126
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 127
local CHECK = Color(96, 186, 122, 255) -- 128
local STAND = Color(226, 186, 84, 255) -- 129
local AIM = Color(236, 236, 232, 230) -- 130
local AIM_HIT = Color(236, 96, 84, 255) -- 131
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 133
local SOFT_LINE = Color(140, 112, 80, 190) -- 134
local BRICK = Color(126, 118, 110, 70) -- 135
local BRICK_LINE = Color(160, 152, 142, 200) -- 136
local PASS = Color(96, 186, 122, 40) -- 137
local PASS_LINE = Color(96, 186, 122, 200) -- 138
local BOTTLE = Color(120, 186, 160, 255) -- 139
local SCAV_BODY = Color(128, 118, 96, 255) -- 140
local SCAV_HEAD = Color(196, 182, 158, 255) -- 141
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 228
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 229
	if zoom < 1 then -- 229
		zoom = 1 -- 231
	end -- 231
	return { -- 233
		zoom = zoom, -- 234
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 235
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 236
	} -- 236
end -- 228
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 259
	if key == "prologue" then -- 259
		return "prologue-wait" -- 261
	end -- 261
	if key == "street" then -- 261
		return "street-run" -- 264
	end -- 264
	if key == "gate" then -- 264
		return "gate-idle" -- 267
	end -- 267
	if key == "forest" then -- 267
		return "forest-run" -- 270
	end -- 270
	if key == "tower" then -- 270
		return "tower-wait" -- 273
	end -- 273
	return "run" -- 275
end -- 259
____exports.Play = __TS__Class() -- 278
local Play = ____exports.Play -- 278
Play.name = "Play" -- 278
function Play.prototype.____constructor(self, room, resume, run) -- 445
	self.enemies = {} -- 283
	self.boxes = {} -- 284
	self.floors = {} -- 285
	self.checkpoint = -1 -- 287
	self.flash = "" -- 289
	self.flashT = 0 -- 290
	self.traceT = 0 -- 293
	self.focusCart = false -- 295
	self.knocks = 0 -- 297
	self.knockT = 0 -- 298
	self.cartAxle = 0 -- 302
	self.cartDocked = false -- 304
	self.gripping = false -- 306
	self.gateOpen = false -- 308
	self.calmConsumed = false -- 310
	self.nextDangerId = 1 -- 312
	self.wantRoom = "" -- 314
	self.carryCartAxle = -1 -- 316
	self.carryCartDocked = false -- 317
	self.checkpointCartAxle = -1 -- 319
	self.hasBottle = false -- 323
	self.bottleLandX = -1 -- 327
	self.bottleTargetX = -1 -- 328
	self.bottleTargetY = 0 -- 329
	self.bottleLandT = 0 -- 330
	self.aimHold = 0 -- 332
	self.scavX = 0 -- 334
	self.scavDir = 1 -- 335
	self.scavState = "patrol" -- 336
	self.scavT = 0 -- 337
	self.scavTargetX = 0 -- 338
	self.passed = false -- 340
	self.childMode = false -- 344
	self.phase = "" -- 346
	self.phaseTick = 0 -- 348
	self.gateTick = 0 -- 350
	self.countTick = 0 -- 352
	self.countArmed = false -- 354
	self.countPrevMove = 0 -- 356
	self.caughtT = 0 -- 358
	self.hp = 3 -- 360
	self.maxHp = 3 -- 361
	self.invulnT = 0 -- 363
	self.partnerStuck = 0 -- 365
	self.partnerLaneIdx = 0 -- 367
	self.partnerLaneHold = 0 -- 368
	self.coveredFlash = 0 -- 370
	self.coverHug = false -- 372
	self.coverNear = false -- 374
	self.coverEntity = "" -- 376
	self.coverBlocking = false -- 378
	self.gateNeedConfirm = false -- 380
	self.gateRestartArmed = true -- 382
	self.bottleAimX = -1 -- 384
	self.bottleAimY = 0 -- 385
	self.bottleSurfaceY = -1 -- 387
	self.bottleLandY = 0 -- 389
	self.events = {} -- 391
	self.eventSeq = 0 -- 393
	self.dogX = 0 -- 395
	self.dogDir = 1 -- 396
	self.dogState = "patrol" -- 397
	self.dogT = 0 -- 398
	self.dogTargetX = 0 -- 399
	self.scavSee = 0 -- 401
	self.scavChase = false -- 402
	self.gateSpawned = 0 -- 404
	self.gateFailCount = 0 -- 406
	self.isCampaign = false -- 410
	self.pickups = {} -- 414
	self.reloadT = 0 -- 416
	self.objectiveDone = false -- 420
	self.hint = "" -- 422
	self.roomStartTick = 0 -- 424
	self.cartHitT = 0 -- 426
	self.cartExposed = false -- 427
	self.paused = false -- 429
	self.ticks = 0 -- 431
	self.view = {zoom = 1, ox = 0, oy = 0} -- 433
	self.ox = 0 -- 435
	self.aimX = 0 -- 437
	self.aimY = 0 -- 438
	self.viewW = 0 -- 440
	self.viewH = 0 -- 441
	self.ox = room.originX -- 447
	self.room = withOrigin(room) -- 448
	local wr = self.room -- 449
	self.run = run or createRun() -- 450
	self.isCampaign = wr.campaign ~= nil -- 451
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 452
	self:buildWorld() -- 453
	self.childMode = wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower" -- 455
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 456
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 457
	self.player = makeActor(wr, playerIdx) -- 458
	self.partner = makeActor(wr, partnerIdx) -- 459
	self.phase = phaseOf(wr.key) -- 460
	if wr.story ~= nil then -- 460
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 462
	end -- 462
	self.cam.x = self.player.x -- 464
	self.cam.y = self.player.y + CAM_LOOK_UP -- 465
	self.cartAxle = wr.cart.startX -- 466
	self.escort = __TS__New( -- 467
		Escort, -- 467
		safeAnchorX(wr.marks) -- 467
	) -- 467
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 468
	if self.isCampaign then -- 468
		self:setupCampaign() -- 470
	else -- 470
		self:buildEnemies() -- 472
	end -- 472
	if resume ~= nil and resume.checkpoint > 0 then -- 472
		self.checkpoint = resume.checkpoint -- 476
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 476
			self.cartAxle = self.room.cart.endX -- 478
			self.cartDocked = true -- 479
			self.player.x = self.ox + 380 -- 482
			self.player.y = 0 -- 483
			self.player.vy = 0 -- 484
			self.player.onGround = true -- 485
			self.cam.x = self.player.x -- 486
			self.cam.y = self.player.y + CAM_LOOK_UP -- 487
		end -- 487
	end -- 487
end -- 445
function Play.prototype.buildWorld(self) -- 493
	local room = self.room -- 494
	self.boxes = {} -- 495
	self.floors = {} -- 496
	local i = 0 -- 497
	do -- 497
		i = 0 -- 498
		while i < #room.floors do -- 498
			local f = room.floors[i + 1] -- 499
			local ____self_floors_0 = self.floors -- 499
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 500
			i = i + 1 -- 498
		end -- 498
	end -- 498
	do -- 498
		i = 0 -- 502
		while i < #room.solids do -- 502
			local s = room.solids[i + 1] -- 503
			if not s.decorative then -- 503
				local ____self_boxes_12 = self.boxes -- 509
				local ____s_x_3 = s.x -- 510
				local ____temp_4 = s.x + s.w -- 510
				local ____s_y_5 = s.y -- 510
				local ____temp_6 = s.y + s.h -- 510
				local ____temp_1 -- 511
				if room.depth == nil then -- 511
					____temp_1 = nil -- 511
				else -- 511
					____temp_1 = s.depth -- 511
				end -- 511
				local ____temp_7 = s.passable == true -- 512
				local ____s_label_8 = s.label -- 512
				local ____s_id_9 = s.id -- 513
				local ____temp_10 = s.soft == true -- 513
				local ____temp_11 = s.hidden == true -- 513
				local ____temp_2 -- 514
				if s.breakable == nil then -- 514
					____temp_2 = nil -- 514
				else -- 514
					____temp_2 = __TS__ObjectAssign({}, s.breakable) -- 514
				end -- 514
				____self_boxes_12[#____self_boxes_12 + 1] = { -- 509
					x0 = ____s_x_3, -- 510
					x1 = ____temp_4, -- 510
					y0 = ____s_y_5, -- 510
					y1 = ____temp_6, -- 510
					depth = ____temp_1, -- 511
					passable = ____temp_7, -- 512
					label = ____s_label_8, -- 512
					id = ____s_id_9, -- 513
					soft = ____temp_10, -- 513
					hidden = ____temp_11, -- 513
					breakable = ____temp_2, -- 514
					interact = s.interact -- 515
				} -- 515
			end -- 515
			i = i + 1 -- 502
		end -- 502
	end -- 502
	do -- 502
		i = 0 -- 519
		while i < #room.stairs do -- 519
			local st = room.stairs[i + 1] -- 520
			local n = st.steps + 1 -- 521
			local stepW = (st.x1 - st.x0) / n -- 522
			local k = 0 -- 523
			do -- 523
				k = 0 -- 524
				while k < n do -- 524
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 525
					local x0 = st.x0 + stepW * k -- 526
					local ____self_boxes_13 = self.boxes -- 526
					____self_boxes_13[#____self_boxes_13 + 1] = { -- 528
						x0 = x0, -- 528
						x1 = x0 + stepW, -- 528
						y0 = -8, -- 528
						y1 = y, -- 528
						passable = true -- 528
					} -- 528
					k = k + 1 -- 524
				end -- 524
			end -- 524
			i = i + 1 -- 519
		end -- 519
	end -- 519
end -- 493
function Play.prototype.setupCampaign(self) -- 537
	local wr = self.room -- 538
	local c = wr.campaign -- 539
	if c == nil then -- 539
		return -- 541
	end -- 541
	self.roomStartTick = self.run.ticks -- 543
	if wr.key == "s1-crossroad" then -- 543
		self.run.joined = true -- 546
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 546
		local ____self_run_15 = self.run -- 549
		local ____temp_14 -- 549
		if wr.key == "s2-drygoods" then -- 549
			____temp_14 = self.run.route ~= "drygoods" -- 549
		else -- 549
			____temp_14 = false -- 549
		end -- 549
		____self_run_15.joined = ____temp_14 -- 549
	end -- 549
	local x = wr.minX + 60 -- 551
	local y = 0 -- 552
	local depth = 0 -- 553
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 553
		x = wr.minX + 210 -- 555
		depth = -32 -- 556
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 556
		x = wr.minX + 40 -- 558
		y = 32 -- 559
		depth = 32 -- 560
	end -- 560
	self.player = { -- 562
		x = x, -- 563
		y = y, -- 563
		depth = depth, -- 563
		depthSpeed = 0, -- 563
		vx = 0, -- 563
		vy = 0, -- 563
		w = SOLDIER_W, -- 564
		h = SOLDIER_H, -- 564
		onGround = y <= 0, -- 564
		facing = 1, -- 564
		crouch = false, -- 564
		rollT = 0, -- 564
		covered = false, -- 564
		alive = true -- 564
	} -- 564
	self.partner = { -- 566
		x = x + 60, -- 567
		y = y, -- 567
		depth = depth, -- 567
		depthSpeed = 0, -- 567
		vx = 0, -- 567
		vy = 0, -- 567
		w = CHILD_W, -- 568
		h = CHILD_H, -- 568
		onGround = y <= 0, -- 568
		facing = 1, -- 568
		crouch = false, -- 568
		rollT = 0, -- 568
		covered = false, -- 568
		alive = true -- 568
	} -- 568
	self.cam.x = x -- 570
	self.cam.y = y + CAM_LOOK_UP -- 571
	self.phase = "run" -- 572
	self.hp = self.maxHp -- 573
	self:buildEnemies() -- 574
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 575
	local i = 0 -- 576
	do -- 576
		i = 0 -- 577
		while i < #self.boxes do -- 577
			do -- 577
				local b = self.boxes[i + 1] -- 578
				if b.id == nil then -- 578
					goto __continue33 -- 580
				end -- 580
				local st = self.run.props[b.id] -- 582
				if st ~= nil then -- 582
					b.broken = st.broken -- 584
					local ____temp_16 -- 585
					if b.breakable == nil then -- 585
						____temp_16 = nil -- 585
					else -- 585
						____temp_16 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 585
					end -- 585
					b.breakable = ____temp_16 -- 585
					b.hidden = b.hidden == true and st.revealed ~= true -- 586
					if b.hidden then -- 586
						b.broken = true -- 588
					end -- 588
				elseif b.hidden == true then -- 588
					b.broken = true -- 592
				end -- 592
			end -- 592
			::__continue33:: -- 592
			i = i + 1 -- 577
		end -- 577
	end -- 577
	if wr.cart.bodyW > 0 then -- 577
		self.cartAxle = wr.cart.startX -- 596
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 596
			self.cartAxle = wr.cart.endX -- 598
			self.cartDocked = true -- 599
		end -- 599
	end -- 599
	do -- 599
		i = 0 -- 602
		while i < #self.pickups do -- 602
			local pk = self.pickups[i + 1] -- 603
			if self.run.taken[pk.id] == true then -- 603
				pk.id = "" -- 605
			end -- 605
			i = i + 1 -- 602
		end -- 602
	end -- 602
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 608
end -- 537
function Play.prototype.log(self, line) -- 611
	local ____self_run_log_17 = self.run.log -- 611
	____self_run_log_17[#____self_run_log_17 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 612
	if #self.run.log > 120 then -- 612
		table.remove(self.run.log, 1) -- 614
	end -- 614
end -- 611
function Play.prototype.buildEnemies(self) -- 618
	self.enemies = {} -- 619
	if self.isCampaign then -- 619
		local i = 0 -- 621
		do -- 621
			i = 0 -- 622
			while i < #self.room.spawns do -- 622
				local sp = self.room.spawns[i + 1] -- 623
				local kind = sp.kind or "gunner" -- 624
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 625
				local ____self_enemies_18 = self.enemies -- 625
				____self_enemies_18[#____self_enemies_18 + 1] = { -- 626
					x = sp.x, -- 627
					y = sp.y, -- 627
					depth = sp.depth, -- 627
					w = 26, -- 627
					h = sp.h, -- 627
					alive = true, -- 627
					hitT = 0, -- 627
					warnT = 0, -- 627
					fireCd = 40, -- 627
					kind = kind, -- 628
					shieldHp = hp, -- 628
					shieldHpMax = hp, -- 628
					drop = sp.drop or "none", -- 628
					homeX = sp.x, -- 629
					swingT = 0, -- 629
					awake = false, -- 629
					squad = i -- 629
				} -- 629
				i = i + 1 -- 622
			end -- 622
		end -- 622
		return -- 632
	end -- 632
	if self.room.key == "checkpoint" then -- 632
		local ____self_enemies_19 = self.enemies -- 632
		____self_enemies_19[#____self_enemies_19 + 1] = { -- 635
			x = self.ox + 430, -- 635
			y = 0, -- 635
			w = 26, -- 635
			h = 84, -- 635
			alive = true, -- 635
			hitT = 0, -- 635
			warnT = 0, -- 635
			fireCd = 0 -- 635
		} -- 635
		local ____self_enemies_20 = self.enemies -- 635
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 636
			x = self.ox + 505, -- 636
			y = 0, -- 636
			w = 26, -- 636
			h = 84, -- 636
			alive = true, -- 636
			hitT = 0, -- 636
			warnT = 0, -- 636
			fireCd = 0 -- 636
		} -- 636
		return -- 637
	end -- 637
	if self.room.key == "street" then -- 637
		local ____self_enemies_21 = self.enemies -- 637
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 641
			x = self.ox + 340, -- 641
			y = 0, -- 641
			w = 26, -- 641
			h = 84, -- 641
			alive = true, -- 641
			hitT = 0, -- 641
			warnT = 0, -- 641
			fireCd = 0 -- 641
		} -- 641
		local ____self_enemies_22 = self.enemies -- 641
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 642
			x = self.ox + 560, -- 642
			y = 0, -- 642
			w = 26, -- 642
			h = 84, -- 642
			alive = true, -- 642
			hitT = 0, -- 642
			warnT = 0, -- 642
			fireCd = 0 -- 642
		} -- 642
	end -- 642
end -- 618
function Play.prototype.emit(self, name, data) -- 648
	local ____self_events_23 = self.events -- 648
	____self_events_23[#____self_events_23 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 649
	self.eventSeq = self.eventSeq + 1 -- 650
	if #self.events > 256 then -- 650
		table.remove(self.events, 1) -- 652
	end -- 652
end -- 648
function Play.prototype.drainEvents(self) -- 660
	local out = self.events -- 661
	self.events = {} -- 662
	return out -- 663
end -- 660
function Play.prototype.adoptEvents(self, events) -- 672
	if #events == 0 then -- 672
		return -- 674
	end -- 674
	local keep = {} -- 676
	local i = 0 -- 677
	do -- 677
		i = 0 -- 678
		while i < #events do -- 678
			do -- 678
				local e = events[i + 1] -- 679
				if e.name == "knock" and e.data.room ~= self.room.key then -- 679
					goto __continue57 -- 681
				end -- 681
				keep[#keep + 1] = e -- 683
			end -- 683
			::__continue57:: -- 683
			i = i + 1 -- 678
		end -- 678
	end -- 678
	if #keep == 0 then -- 678
		return -- 686
	end -- 686
	self.events = __TS__ArrayConcat(keep, self.events) -- 688
	do -- 688
		i = 0 -- 689
		while i < #self.events do -- 689
			self.events[i + 1].seq = i -- 690
			i = i + 1 -- 689
		end -- 689
	end -- 689
	self.eventSeq = #self.events -- 692
end -- 672
function Play.prototype.update(self, dt, input) -- 696
	if input.pause.pressed then -- 696
		self.paused = not self.paused -- 698
	end -- 698
	if self.invulnT > 0 then -- 698
		self.invulnT = self.invulnT - dt -- 701
	end -- 701
	if self.flashT > 0 then -- 701
		self.flashT = self.flashT - dt -- 704
		if self.flashT <= 0 then -- 704
			self.flash = "" -- 706
		end -- 706
	end -- 706
	if self.traceT > 0 then -- 706
		self.traceT = self.traceT - dt -- 710
		if self.traceT <= 0 then -- 710
			self.trace = nil -- 712
		end -- 712
	end -- 712
	if self.paused then -- 712
		self:updateCamera(dt) -- 716
		return -- 717
	end -- 717
	self.ticks = self.ticks + 1 -- 720
	if self.isCampaign then -- 720
		local ____self_run_24, ____ticks_25 = self.run, "ticks" -- 720
		____self_run_24[____ticks_25] = ____self_run_24[____ticks_25] + 1 -- 722
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 723
	end -- 723
	local p = self.player -- 725
	self:stepPlayer(p, dt, input) -- 726
	self:refreshCover(p, input) -- 728
	if self.isCampaign then -- 728
		self:stepCampaign(dt, input) -- 730
		self:stepCampaignPartner(dt) -- 731
	end -- 731
	self:stepEnemies(dt, input) -- 734
	if not self.isCampaign then -- 734
		self:stepStory(dt, input) -- 736
		self:stepEscort(dt, input) -- 737
		self:stepVillage(dt, input) -- 738
		self:stepChase(dt, input) -- 739
		self:stepInteract(dt, input) -- 740
	end -- 740
	self:updateGate() -- 742
	self:updateCamera(dt) -- 743
end -- 696
function Play.prototype.underLowArch(self, a) -- 750
	local arch = self.room.arch -- 751
	if arch.h <= 0 then -- 751
		return false -- 753
	end -- 753
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 753
		return false -- 756
	end -- 756
	local top = arch.y + arch.h -- 758
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 759
end -- 750
function Play.prototype.coverAt(self, a) -- 766
	local best = nil -- 767
	local bestGap = 24 -- 768
	local half = a.w / 2 -- 769
	local i = 0 -- 770
	do -- 770
		i = 0 -- 771
		while i < #self.boxes do -- 771
			do -- 771
				local b = self.boxes[i + 1] -- 772
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 772
					goto __continue78 -- 774
				end -- 774
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 774
					goto __continue78 -- 777
				end -- 777
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 779
				if gap < bestGap then -- 779
					bestGap = gap -- 781
					best = b -- 782
				end -- 782
			end -- 782
			::__continue78:: -- 782
			i = i + 1 -- 771
		end -- 771
	end -- 771
	return best -- 785
end -- 766
function Play.prototype.nearCover(self, a) -- 788
	return self:coverAt(a) ~= nil -- 789
end -- 788
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 793
	if enemy == nil then -- 793
		return false -- 795
	end -- 795
	local fromRight = enemy.x >= a.x -- 797
	local edge = fromRight and b.x0 or b.x1 -- 798
	local ____fromRight_26 -- 799
	if fromRight then -- 799
		____fromRight_26 = edge >= a.x - 0.001 and edge <= enemy.x -- 799
	else -- 799
		____fromRight_26 = edge <= a.x + 0.001 and edge >= enemy.x -- 800
	end -- 800
	local between = ____fromRight_26 -- 799
	local separation = enemy.x - a.x -- 801
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 802
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 803
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 804
end -- 793
function Play.prototype.nearestEnemy(self, a) -- 807
	local best -- 808
	local bestD = 1000000000 -- 809
	local i = 0 -- 810
	do -- 810
		i = 0 -- 811
		while i < #self.enemies do -- 811
			do -- 811
				local e = self.enemies[i + 1] -- 812
				if not e.alive then -- 812
					goto __continue87 -- 814
				end -- 814
				local d = math.abs(e.x - a.x) -- 816
				if d < bestD then -- 816
					bestD = d -- 818
					best = e -- 819
				end -- 819
			end -- 819
			::__continue87:: -- 819
			i = i + 1 -- 811
		end -- 811
	end -- 811
	return best -- 822
end -- 807
function Play.prototype.refreshCover(self, a, input) -- 826
	if self.childMode then -- 826
		self.coverNear = false -- 828
		self.coverHug = false -- 829
		self.coverEntity = "" -- 830
		self.coverBlocking = false -- 831
		a.covered = false -- 832
		return -- 833
	end -- 833
	local b = self:coverAt(a) -- 835
	self.coverNear = b ~= nil -- 836
	a.covered = self.coverNear and input.cover.held -- 837
	self.coverHug = a.covered -- 838
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 839
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 840
		b, -- 840
		a, -- 840
		self:nearestEnemy(a) -- 840
	) -- 840
end -- 826
function Play.prototype.cartHandleInReach(self, a) -- 844
	if a == nil then -- 844
		a = self.player -- 844
	end -- 844
	local c = self.room.cart -- 845
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 845
		return false -- 847
	end -- 847
	local handleX = self.cartAxle + c.handleOffset -- 849
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 850
end -- 844
function Play.prototype.nearLowLedge(self, a) -- 855
	local reach = 26 -- 856
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 857
	local x1 = x0 + reach -- 858
	local i = 0 -- 859
	do -- 859
		i = 0 -- 860
		while i < #self.boxes do -- 860
			do -- 860
				local b = self.boxes[i + 1] -- 861
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 861
					goto __continue96 -- 863
				end -- 863
				local rise = b.y1 - a.y -- 865
				if rise > 0 and rise <= LEDGE_RISE then -- 865
					return true -- 867
				end -- 867
			end -- 867
			::__continue96:: -- 867
			i = i + 1 -- 860
		end -- 860
	end -- 860
	return false -- 870
end -- 855
function Play.prototype.stepPlayer(self, a, dt, input) -- 873
	a.depthSpeed = 0 -- 874
	if not a.alive then -- 874
		return -- 876
	end -- 876
	local isChild = self.childMode -- 878
	local lowArch = isChild and self:underLowArch(a) -- 880
	if self:storyLocked() then -- 880
		a.vx = 0 -- 883
		a.crouch = isChild and lowArch -- 884
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 885
		self:fallY(a, dt) -- 886
		return -- 887
	end -- 887
	if not isChild and self.escort.state == "calming" then -- 887
		a.crouch = false -- 891
		a.h = SOLDIER_H -- 892
		a.vx = 0 -- 893
		self:fallY(a, dt) -- 894
		return -- 895
	end -- 895
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 897
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 898
	local nearCover = not isChild and self:nearCover(a) -- 899
	a.covered = nearCover and input.cover.held -- 900
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 902
	if a.rollT > 0 then -- 902
		a.rollT = a.rollT - dt -- 906
		a.vx = a.facing * ROLL_SPEED -- 907
		self:slideX(a, a.vx * dt) -- 908
		self:fallY(a, dt) -- 909
		if a.rollT <= 0 then -- 909
			self:flashSet("翻滚结束", 0.5) -- 911
		end -- 911
		return -- 913
	end -- 913
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 913
		if input.moveX ~= 0 then -- 913
			a.facing = input.moveX > 0 and 1 or -1 -- 918
		end -- 918
		if self:nearLowLedge(a) then -- 918
			a.vy = SOLDIER_JUMP -- 922
			a.onGround = false -- 923
			self:flashSet("翻上去", 0.3) -- 924
			return -- 925
		end -- 925
		a.rollT = ROLL_TIME -- 927
		self:flashSet("翻滚", 0.3) -- 928
		return -- 929
	end -- 929
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 932
	if isChild then -- 932
		if input.cover.held then -- 932
			speed = CHILD_SLOW -- 935
		end -- 935
		if a.crouch then -- 935
			speed = CHILD_SLOW -- 938
		end -- 938
	elseif a.covered then -- 938
		speed = SOLDIER_SPEED * 0.45 -- 941
	end -- 941
	local handsBusy = self.gripping or gripIntent -- 945
	local dir = self.gripping and 0 or input.moveX -- 946
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 947
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 948
	if dir ~= 0 then -- 948
		a.facing = dir > 0 and 1 or -1 -- 950
	end -- 950
	a.vx = dir * speed * diagonal -- 952
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 952
		a.vy = CHILD_JUMP -- 956
		a.onGround = false -- 957
		self:flashSet("跳", 0.25) -- 958
	end -- 958
	local previousDepth = a.depth -- 962
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 963
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 964
	self:slideX(a, a.vx * dt) -- 965
	self:fallY(a, dt) -- 966
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 966
		self:shoot(a) -- 970
	end -- 970
end -- 873
function Play.prototype.stepPartner(self, p, dt) -- 975
	local a = self.partner -- 976
	if not a.alive then -- 976
		return -- 978
	end -- 978
	a.crouch = false -- 980
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 981
	a.vx = 0 -- 982
	a.depthSpeed = 0 -- 983
	self:fallY(a, dt) -- 984
end -- 975
function Play.prototype.stepEscort(self, dt, input) -- 991
	local a = self.partner -- 992
	a.depthSpeed = 0 -- 993
	if not a.alive then -- 993
		return -- 995
	end -- 995
	if not self:escortOn() then -- 995
		a.vx = 0 -- 998
		self:fallY(a, dt) -- 999
		return -- 1000
	end -- 1000
	local p = self.player -- 1002
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1003
	local hadKnock1 = self.escort.knock1 -- 1004
	local hadKnock2 = self.escort.knock2 -- 1005
	self.calmConsumed = self.escort:update( -- 1006
		input, -- 1006
		p.x, -- 1006
		p.facing, -- 1006
		a.x, -- 1006
		dist -- 1006
	) -- 1006
	if not hadKnock1 and self.escort.knock1 then -- 1006
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1009
	end -- 1009
	if not hadKnock2 and self.escort.knock2 then -- 1009
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1012
	end -- 1012
	a.crouch = self.escort.crouchPose -- 1014
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1015
	if not self.escort.stopped then -- 1015
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1017
		local previousDepth = a.depth -- 1018
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1019
		local distance = math.max( -- 1020
			-travel, -- 1020
			math.min(travel, targetDepth - previousDepth) -- 1020
		) -- 1020
		self:slideDepth(a, distance) -- 1021
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1022
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1022
			a.vy = CHILD_JUMP -- 1024
			a.onGround = false -- 1025
		end -- 1025
	end -- 1025
	local dir = self.escort:moveDir(a.x) -- 1028
	a.vx = dir * CHILD_SPEED -- 1029
	if dir ~= 0 then -- 1029
		a.facing = dir -- 1031
		local before = a.x -- 1032
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1033
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1033
			a.vy = CHILD_JUMP -- 1036
			a.onGround = false -- 1037
		end -- 1037
	end -- 1037
	self:fallY(a, dt) -- 1040
end -- 991
function Play.prototype.escortOn(self) -- 1044
	if self.room.key == "checkpoint" then -- 1044
		return true -- 1046
	end -- 1046
	if self.room.key == "prologue" then -- 1046
		return self.phase == "prologue-follow" -- 1049
	end -- 1049
	return self.room.key == "street" -- 1051
end -- 1044
function Play.prototype.storyLocked(self) -- 1055
	if self.caughtT > 0 then -- 1055
		return true -- 1057
	end -- 1057
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1057
		return true -- 1060
	end -- 1060
	if self.room.key == "gate" and self.phase == "gate-count" then -- 1060
		return true -- 1063
	end -- 1063
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1063
		return true -- 1066
	end -- 1066
	return false -- 1068
end -- 1055
function Play.prototype.swapToChild(self, x) -- 1072
	local tmp = self.player -- 1073
	self.player = self.partner -- 1074
	self.partner = tmp -- 1075
	self.childMode = true -- 1076
	self.player.alive = true -- 1077
	self.player.x = self.ox + x -- 1078
	self.player.y = 0 -- 1079
	self.player.depth = 0 -- 1080
	self.player.depthSpeed = 0 -- 1081
	self.player.vy = 0 -- 1082
	self.player.vx = 0 -- 1083
	self.player.onGround = true -- 1084
	self.player.crouch = false -- 1085
	self.player.h = CHILD_H -- 1086
	self.player.facing = 1 -- 1087
	self.partner.alive = true -- 1088
	self.cam.x = self.player.x -- 1089
end -- 1072
function Play.prototype.stepStory(self, dt, input) -- 1093
	if self.room.key == "prologue" then -- 1093
		self:stepPrologue(dt, input) -- 1095
	elseif self.room.key == "street" then -- 1095
		self:stepStreet(dt, input) -- 1097
	elseif self.room.key == "gate" then -- 1097
		self:stepGate(dt, input) -- 1099
	elseif self.room.key == "tower" then -- 1099
		self:stepTower(dt, input) -- 1101
	end -- 1101
end -- 1093
function Play.prototype.stepPrologue(self, dt, input) -- 1106
	local child = self.partner -- 1107
	if self.phase == "prologue-wait" then -- 1107
		child.crouch = true -- 1109
		child.h = CHILD_CROUCH_H -- 1110
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1111
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1113
		if near and input.interact.pressed then -- 1113
			self.phase = "prologue-give" -- 1115
			self.phaseTick = 0 -- 1116
			self:flashSet("递出针套", 1) -- 1117
		end -- 1117
		return -- 1119
	end -- 1119
	if self.phase == "prologue-give" then -- 1119
		self.phaseTick = self.phaseTick + 1 -- 1122
		if self.phaseTick == 12 then -- 1122
			self:flashSet("针套递过去", 0.7) -- 1124
		elseif self.phaseTick == 36 then -- 1124
			self:flashSet("纸条塞进针套", 0.9) -- 1126
		elseif self.phaseTick >= 60 then -- 1126
			self.phase = "prologue-follow" -- 1128
			self.phaseTick = 0 -- 1129
			child.crouch = false -- 1130
			child.h = CHILD_H -- 1131
			self:flashSet("她跟上了", 1.2) -- 1132
		end -- 1132
		return -- 1134
	end -- 1134
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1134
		self:requestRoom("street", "序章跟到门口") -- 1138
		self:flashSet("进街道", 1.2) -- 1139
	end -- 1139
end -- 1106
function Play.prototype.stepStreet(self, dt, input) -- 1144
	local p = self.player -- 1145
	local c = self.partner -- 1146
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1146
		self:requestRoom("checkpoint", "两人都到街尾") -- 1148
		self:flashSet("到检查站", 1.2) -- 1149
	end -- 1149
end -- 1144
function Play.prototype.stepGate(self, dt, input) -- 1154
	local ____temp_27 -- 1155
	if self.room.story == nil then -- 1155
		____temp_27 = nil -- 1155
	else -- 1155
		____temp_27 = self.room.story.gate -- 1155
	end -- 1155
	local g = ____temp_27 -- 1155
	if g == nil then -- 1155
		return -- 1157
	end -- 1157
	local p = self.player -- 1159
	if self.phase == "gate-idle" then -- 1159
		local a = self.partner -- 1162
		local gap = g.waitX - a.x -- 1163
		if math.abs(gap) > 3 then -- 1163
			a.facing = gap > 0 and 1 or -1 -- 1165
			a.vx = a.facing * CHILD_SPEED -- 1166
			local beforeX = a.x -- 1167
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1168
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1168
				a.vy = CHILD_JUMP -- 1170
				a.onGround = false -- 1171
			end -- 1171
			self:fallY(a, dt) -- 1173
		else -- 1173
			a.vx = 0 -- 1175
			a.x = g.waitX -- 1176
		end -- 1176
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1179
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1180
		if self.gateNeedConfirm then -- 1180
			if not input.interact.held then -- 1180
				self.gateRestartArmed = true -- 1185
			end -- 1185
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1185
				self.gateNeedConfirm = false -- 1188
				self.gateRestartArmed = true -- 1189
				self.phase = "gate-hold" -- 1190
				self.gateTick = 0 -- 1191
				self.gateSpawned = 0 -- 1192
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1193
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1194
			end -- 1194
			return -- 1196
		end -- 1196
		if atWinch and atWait then -- 1196
			self.phase = "gate-hold" -- 1199
			self.gateTick = 0 -- 1200
			self.gateSpawned = 0 -- 1201
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1202
		end -- 1202
		return -- 1204
	end -- 1204
	if self.phase == "gate-hold" then -- 1204
		self.gateTick = self.gateTick + 1 -- 1207
		local marks = {0, 540, 900, 1500} -- 1209
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1209
			local idx = self.gateSpawned -- 1211
			local ____self_enemies_28 = self.enemies -- 1211
			____self_enemies_28[#____self_enemies_28 + 1] = { -- 1212
				x = self.ox + 620 + idx * 62, -- 1213
				y = 0, -- 1213
				w = 26, -- 1213
				h = 84, -- 1213
				alive = true, -- 1214
				hitT = 0, -- 1214
				warnT = 0, -- 1214
				fireCd = 90 + idx * 45 -- 1214
			} -- 1214
			self.gateSpawned = self.gateSpawned + 1 -- 1216
			self:flashSet( -- 1217
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1217
				0.9 -- 1217
			) -- 1217
		end -- 1217
		if self.gateTick == 900 then -- 1217
			self:flashSet("灯灭了", 1) -- 1220
		elseif self.gateTick == 2100 then -- 1220
			self:flashSet("门底压下来了", 1) -- 1222
		end -- 1222
		if self.gateTick >= g.holdTicks then -- 1222
			self.phase = "gate-send" -- 1225
			self.phaseTick = 0 -- 1226
			self.enemies = {} -- 1228
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1229
		end -- 1229
		return -- 1231
	end -- 1231
	if self.phase == "gate-send" then -- 1231
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1234
		if near and input.interact.pressed then -- 1234
			self:swapToChild(g.doorX + 30) -- 1236
			self.phase = "gate-count" -- 1237
			self.countTick = 0 -- 1238
			self.countArmed = false -- 1240
			self.countPrevMove = input.moveX -- 1241
			self:flashSet("门开了 · 送她出去", 1.8) -- 1242
		end -- 1242
		return -- 1244
	end -- 1244
	if self.phase == "gate-count" then -- 1244
		self.countTick = self.countTick + 1 -- 1247
		if self.countTick == 360 then -- 1247
			self:flashSet("门关上", 0.9) -- 1249
		elseif self.countTick == 1020 then -- 1249
			self:flashSet("数到一百", 2.2) -- 1251
		end -- 1251
		local prevMove = self.countPrevMove -- 1255
		self.countPrevMove = input.moveX -- 1256
		if self.countTick >= 1440 then -- 1256
			if prevMove <= 0 and input.moveX > 0 then -- 1256
				self.countArmed = true -- 1259
			end -- 1259
			if self.countArmed and input.moveX > 0 then -- 1259
				self.phase = "gate-walk" -- 1262
				self.phaseTick = 0 -- 1263
				self:flashSet("她迈出第一步", 1.4) -- 1264
			end -- 1264
		end -- 1264
		return -- 1267
	end -- 1267
	if self.player.x >= g.exitX then -- 1267
		self:requestRoom("outside", "走出城门") -- 1271
		self:flashSet("出城门 · 城外", 1.4) -- 1272
	end -- 1272
end -- 1154
function Play.prototype.stepTower(self, dt, input) -- 1277
	local ____temp_29 -- 1278
	if self.room.story == nil then -- 1278
		____temp_29 = nil -- 1278
	else -- 1278
		____temp_29 = self.room.story.tower -- 1278
	end -- 1278
	local t = ____temp_29 -- 1278
	if t == nil then -- 1278
		return -- 1280
	end -- 1280
	if self.phase == "tower-wait" then -- 1280
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1283
		if near and input.interact.pressed then -- 1283
			self.phase = "tower-knock" -- 1285
			self.phaseTick = 0 -- 1286
			self.knocks = 1 -- 1287
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1288
			self:flashSet("敲一下", 0.6) -- 1289
		end -- 1289
		return -- 1291
	end -- 1291
	if self.phase == "tower-knock" then -- 1291
		self.phaseTick = self.phaseTick + 1 -- 1294
		if self.phaseTick == 12 then -- 1294
			self.knocks = 2 -- 1296
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1297
			self:flashSet("敲两下 · 第二声", 1) -- 1298
		elseif self.phaseTick >= t.knockTicks then -- 1298
			self.phase = "tower-given" -- 1300
			self.phaseTick = 0 -- 1301
			self:flashSet("门开了 · 提灯", 1.4) -- 1302
		end -- 1302
		return -- 1304
	end -- 1304
	if self.phase == "tower-given" then -- 1304
		self.phaseTick = self.phaseTick + 1 -- 1307
		if self.phaseTick == 60 then -- 1307
			self:flashSet("她递出针套和纸条", 1.6) -- 1309
		elseif self.phaseTick == 120 then -- 1309
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1311
		elseif self.phaseTick >= 180 then -- 1311
			self.phase = "tower-end" -- 1313
			self.phaseTick = 0 -- 1314
			self:flashSet("片尾 · E 再玩一次", 3) -- 1315
		end -- 1315
		return -- 1317
	end -- 1317
	if input.interact.pressed or input.retry.pressed then -- 1317
		self:requestRoom("prologue", "片尾再玩") -- 1320
		self:flashSet("回到序章", 1.4) -- 1321
	end -- 1321
end -- 1277
function Play.prototype.stepChase(self, dt, input) -- 1326
	if self.caughtT > 0 then -- 1326
		self.caughtT = self.caughtT - dt -- 1328
		if self.caughtT <= 0 then -- 1328
			self:recoverFromCaught() -- 1330
		end -- 1330
		return -- 1332
	end -- 1332
	if self.room.key == "village" then -- 1332
		self:stepScavChase() -- 1335
	elseif self.room.key == "forest" then -- 1335
		self:stepDog(dt) -- 1337
		if self.player.x >= self.ox + 1450 then -- 1337
			self:requestRoom("tower", "到林缘北塔") -- 1340
			self:flashSet("林缘 · 北塔", 1.4) -- 1341
		end -- 1341
	end -- 1341
end -- 1326
function Play.prototype.stepScavChase(self) -- 1347
	local s = self.room.scavenger -- 1348
	if s == nil then -- 1348
		return -- 1350
	end -- 1350
	local p = self.player -- 1352
	if self.passed and p.x > self.ox + 440 then -- 1352
		if self.scavChase then -- 1352
			self.scavChase = false -- 1356
			self.scavState = "back" -- 1357
			self.scavT = 0 -- 1358
		end -- 1358
		return -- 1360
	end -- 1360
	local dx = p.x - self.scavX -- 1362
	local dist = math.abs(dx) -- 1363
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1364
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1365
	if not self.scavChase then -- 1365
		if visible then -- 1365
			self.scavSee = self.scavSee + 1 -- 1368
			if self.scavSee >= 24 then -- 1368
				self.scavChase = true -- 1370
				self.scavState = "chase" -- 1371
				self.scavTargetX = p.x -- 1372
				self:flashSet("他看见你了", 1.2) -- 1373
			end -- 1373
		else -- 1373
			self.scavSee = 0 -- 1376
		end -- 1376
		return -- 1378
	end -- 1378
	local dir = p.x > self.scavX and 1 or -1 -- 1381
	self.scavX = self.scavX + dir * 96 / 60 -- 1382
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1382
		self:caught() -- 1384
		return -- 1385
	end -- 1385
	if hidden then -- 1385
		self.scavSee = 0 -- 1389
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1390
		self.scavT = self.scavT - 1 -- 1391
		if self.scavT <= 0 then -- 1391
			self.scavChase = false -- 1393
			self.scavState = "patrol" -- 1394
			self:flashSet("他失去了目标", 1) -- 1395
		end -- 1395
	end -- 1395
end -- 1347
function Play.prototype.stepDog(self, dt) -- 1401
	local ____temp_30 -- 1402
	if self.room.story == nil then -- 1402
		____temp_30 = nil -- 1402
	else -- 1402
		____temp_30 = self.room.story.dog -- 1402
	end -- 1402
	local dog = ____temp_30 -- 1402
	if dog == nil then -- 1402
		return -- 1404
	end -- 1404
	local p = self.player -- 1406
	local dist = math.abs(p.x - self.dogX) -- 1407
	if self.dogState == "patrol" then -- 1407
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1409
		if self.dogX < dog.x0 then -- 1409
			self.dogX = dog.x0 -- 1411
			self.dogDir = 1 -- 1412
		elseif self.dogX > dog.x1 then -- 1412
			self.dogX = dog.x1 -- 1414
			self.dogDir = -1 -- 1415
		end -- 1415
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1417
		if not p.crouch and moving and dist < dog.range then -- 1417
			self.dogState = "ear" -- 1419
			self.dogT = 18 -- 1420
			self.dogTargetX = p.x -- 1421
			self:flashSet("狗转耳朵", 0.8) -- 1422
		end -- 1422
		return -- 1424
	end -- 1424
	if self.dogState == "ear" then -- 1424
		self.dogT = self.dogT - 1 -- 1427
		if self.dogT <= 0 then -- 1427
			self.dogState = "chase" -- 1429
			self.dogTargetX = p.x -- 1430
			self:flashSet("狗追来了", 1.4) -- 1431
		end -- 1431
		return -- 1433
	end -- 1433
	if self.dogState == "chase" then -- 1433
		local dir = p.x > self.dogX and 1 or -1 -- 1436
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1437
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1437
			self:caught() -- 1439
			self.dogState = "sniff" -- 1440
			self.dogT = 60 -- 1441
		elseif dist > dog.range * 1.5 or p.crouch then -- 1441
			self.dogState = "sniff" -- 1443
			self.dogT = 60 -- 1444
			self:flashSet("狗停下了", 0.9) -- 1445
		end -- 1445
		return -- 1447
	end -- 1447
	if self.dogState == "sniff" then -- 1447
		self.dogT = self.dogT - 1 -- 1450
		if self.dogT <= 0 then -- 1450
			self.dogState = "back" -- 1452
		end -- 1452
		return -- 1454
	end -- 1454
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1457
	self.dogX = self.dogX + dir * dog.speed * dt -- 1458
	if math.abs(self.dogX - dog.x0) < 2 then -- 1458
		self.dogX = dog.x0 -- 1460
		self.dogState = "patrol" -- 1461
	end -- 1461
end -- 1401
function Play.prototype.caught(self) -- 1465
	self.caughtT = 1 -- 1466
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1467
end -- 1465
function Play.prototype.recoverFromCaught(self) -- 1471
	local p = self.player -- 1472
	p.x = self.ox + 140 -- 1473
	p.y = 0 -- 1474
	p.vy = 0 -- 1475
	p.vx = 0 -- 1476
	p.onGround = true -- 1477
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1477
		self.scavX = self.room.scavenger.x0 -- 1479
		self.scavState = "patrol" -- 1480
		self.scavSee = 0 -- 1481
		self.scavChase = false -- 1482
		self.scavT = 0 -- 1483
	end -- 1483
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1483
		self.dogX = self.room.story.dog.x0 -- 1486
		self.dogState = "patrol" -- 1487
		self.dogT = 0 -- 1488
	end -- 1488
	self.cam.x = p.x -- 1490
	self.cam.y = p.y + CAM_LOOK_UP -- 1491
	self:flashSet("回到安全点", 1.2) -- 1492
end -- 1471
function Play.prototype.updateGate(self) -- 1496
	if self.room.key ~= "checkpoint" then -- 1496
		self.gateOpen = false -- 1498
		return -- 1499
	end -- 1499
	local function inZone(x) -- 1501
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1501
	end -- 1501
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1502
end -- 1496
function Play.prototype.addItem(self, kind) -- 1508
	local inv = self.run.inventory -- 1509
	if kind == "shield" then -- 1509
		inv.shield = inv.shield + 1 -- 1511
	elseif kind == "wedge" then -- 1511
		inv.wedge = inv.wedge + 1 -- 1513
	elseif kind == "ammo" then -- 1513
		inv.ammo = inv.ammo + 1 -- 1515
	elseif kind == "pass" then -- 1515
		inv.pass = inv.pass + 1 -- 1517
	elseif kind == "quickbelt" then -- 1517
		inv.quickbelt = inv.quickbelt + 1 -- 1519
	end -- 1519
end -- 1508
function Play.prototype.findBox(self, id) -- 1523
	local i = 0 -- 1524
	do -- 1524
		i = 0 -- 1525
		while i < #self.boxes do -- 1525
			if self.boxes[i + 1].id == id then -- 1525
				return self.boxes[i + 1] -- 1527
			end -- 1527
			i = i + 1 -- 1525
		end -- 1525
	end -- 1525
	return nil -- 1530
end -- 1523
function Play.prototype.nearBox(self, b, reach) -- 1533
	local p = self.player -- 1534
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 1535
end -- 1533
function Play.prototype.findInteract(self) -- 1541
	local p = self.player -- 1542
	local best = nil -- 1543
	local bestD = 1000000000 -- 1544
	local i = 0 -- 1545
	do -- 1545
		i = 0 -- 1546
		while i < #self.boxes do -- 1546
			do -- 1546
				local b = self.boxes[i + 1] -- 1547
				if b.interact == nil or b.broken == true then -- 1547
					goto __continue237 -- 1549
				end -- 1549
				if not self:nearBox(b, b.interact.reach or 27) then -- 1549
					goto __continue237 -- 1552
				end -- 1552
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 1554
				if d < bestD then -- 1554
					bestD = d -- 1556
					best = b -- 1557
				end -- 1557
			end -- 1557
			::__continue237:: -- 1557
			i = i + 1 -- 1546
		end -- 1546
	end -- 1546
	return best -- 1560
end -- 1541
function Play.prototype.stepCampaign(self, dt, input) -- 1564
	local wr = self.room -- 1565
	local p = self.player -- 1566
	if self.reloadT > 0 then -- 1566
		self.reloadT = self.reloadT - 1 -- 1568
	end -- 1568
	if self.bracedShield ~= nil then -- 1568
		self.bracedShield.x = p.x + p.facing * 26 -- 1572
		self.bracedShield.y = p.y -- 1573
		local shBox = __TS__ArrayFind( -- 1574
			self.boxes, -- 1574
			function(____, b) return b.id == "braced_shield" end -- 1574
		) -- 1574
		if shBox ~= nil then -- 1574
			shBox.x0 = self.bracedShield.x - 15 -- 1576
			shBox.x1 = self.bracedShield.x + 15 -- 1577
			shBox.y0 = self.bracedShield.y -- 1578
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 1579
		end -- 1579
	end -- 1579
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 1579
		self.run.route = "drygoods" -- 1585
		self.run.joined = false -- 1586
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 1587
		self:log("转布行线") -- 1588
	end -- 1588
	local i = 0 -- 1591
	do -- 1591
		i = 0 -- 1592
		while i < #self.pickups do -- 1592
			do -- 1592
				local pk = self.pickups[i + 1] -- 1593
				if pk.id == "" or self.run.taken[pk.id] == true then -- 1593
					goto __continue248 -- 1595
				end -- 1595
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 1597
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 1598
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 1598
					self.run.taken[pk.id] = true -- 1600
					self:addItem(pk.kind) -- 1601
					pk.id = "" -- 1602
					self:flashSet("拾取 " .. pk.label, 1) -- 1603
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 1604
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 1605
				end -- 1605
			end -- 1605
			::__continue248:: -- 1605
			i = i + 1 -- 1592
		end -- 1592
	end -- 1592
	if input.interact.pressed then -- 1592
		self:campaignInteract() -- 1609
	end -- 1609
	self:stepCampaignCart(dt, input) -- 1611
	self:stepCampaignGoal() -- 1612
end -- 1564
function Play.prototype.campaignInteract(self) -- 1616
	local b = self:findInteract() -- 1617
	if b ~= nil then -- 1617
		self:useInteract(b) -- 1619
		return -- 1620
	end -- 1620
	local inv = self.run.inventory -- 1622
	if inv.wedge > 0 then -- 1622
		local w = self:findBox("s2_wood") -- 1624
		if w ~= nil and w.broken ~= true and self:nearBox(w, 26) then -- 1624
			if w.breakable ~= nil then -- 1624
				local ____w_breakable_31, ____hp_32 = w.breakable, "hp" -- 1624
				____w_breakable_31[____hp_32] = ____w_breakable_31[____hp_32] + (w.breakable.wedgeHp or 1) -- 1627
			end -- 1627
			inv.wedge = inv.wedge - 1 -- 1629
			self.run.props.s2_wood = {broken = false, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 1630
			self:flashSet("钉木楔 · 薄木挡多承一次", 1.2) -- 1631
			self:log("加固薄木挡") -- 1632
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 1633
			return -- 1634
		end -- 1634
	end -- 1634
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 1634
		local p = self.player -- 1639
		self.bracedShield = { -- 1640
			x = p.x + p.facing * 26, -- 1640
			y = p.y, -- 1640
			w = 30, -- 1640
			h = 64, -- 1640
			hp = 1 -- 1640
		} -- 1640
		local ____self_boxes_33 = self.boxes -- 1640
		____self_boxes_33[#____self_boxes_33 + 1] = { -- 1641
			x0 = self.bracedShield.x - 15, -- 1642
			x1 = self.bracedShield.x + 15, -- 1642
			y0 = p.y, -- 1643
			y1 = p.y + 64, -- 1643
			depth = {min = -46, max = 46}, -- 1643
			label = "架起的残盾", -- 1643
			id = "braced_shield", -- 1643
			soft = true -- 1644
		} -- 1644
		inv.shield = inv.shield - 1 -- 1647
		self:flashSet("架残盾 · 挡一发", 1.2) -- 1648
		self:log("架残盾") -- 1649
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 1650
		return -- 1651
	end -- 1651
	if inv.pass > 0 and self.run.joined == false then -- 1651
		inv.pass = inv.pass - 1 -- 1654
		self.run.joined = true -- 1655
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 1656
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 1657
		return -- 1658
	end -- 1658
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 1660
end -- 1616
function Play.prototype.useInteract(self, b) -- 1663
	local kind = b.interact == nil and "" or b.interact.kind -- 1664
	local wr = self.room -- 1665
	if kind == "open_board" then -- 1665
		b.broken = true -- 1667
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 1668
		for ____, cover in ipairs(self.boxes) do -- 1669
			if cover.id == "s2_board_cover" then -- 1669
				cover.broken = false -- 1671
				cover.hidden = false -- 1672
			end -- 1672
		end -- 1672
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 1675
		self.run.joined = true -- 1676
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 1677
		self:log("放下窗板") -- 1678
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 1679
		return -- 1680
	end -- 1680
	if kind == "lower_curtain" then -- 1680
		for ____, curtain in ipairs(self.boxes) do -- 1683
			if curtain.id == "c2_curtain" then -- 1683
				curtain.broken = false -- 1685
				curtain.hidden = false -- 1686
			end -- 1686
		end -- 1686
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 1689
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 1690
		self:log("放下木帘") -- 1691
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 1692
		return -- 1693
	end -- 1693
	if kind == "raise_latch" then -- 1693
		if wr.key == "c2-granary" and not self.cartDocked then -- 1693
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 1697
			return -- 1698
		end -- 1698
		b.broken = true -- 1700
		self.objectiveDone = true -- 1701
		if wr.key == "c1-yard" then -- 1701
			self.run.c1Latch = true -- 1704
			self.run.joined = true -- 1705
		else -- 1705
			self.run.c2Latch = true -- 1707
			self.run.joined = true -- 1708
		end -- 1708
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 1710
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 1711
		self:log("抬闩") -- 1712
		self:flashSet("抬闩 · 通路打开", 1.4) -- 1713
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 1714
	end -- 1714
end -- 1663
function Play.prototype.stepCampaignCart(self, dt, input) -- 1719
	local wr = self.room -- 1720
	local c = wr.cart -- 1721
	if c.bodyW <= 0 then -- 1721
		return -- 1723
	end -- 1723
	local p = self.player -- 1725
	local handleX = self.cartAxle + c.handleOffset -- 1726
	if not self.gripping then -- 1726
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 1726
			self.gripping = true -- 1730
			self:flashSet("握住车柄 · A/D 推", 1) -- 1731
		end -- 1731
		return -- 1733
	end -- 1733
	if input.interact.pressed then -- 1733
		self.gripping = false -- 1736
		self:flashSet("松手", 0.5) -- 1737
		return -- 1738
	end -- 1738
	if not self.cartDocked then -- 1738
		if input.moveX ~= 0 and not self:stuckCart() then -- 1738
			self.cartAxle = math.max( -- 1742
				c.startX, -- 1742
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 1742
			) -- 1742
		end -- 1742
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 1742
			self.cartExposed = true -- 1747
			local gun = nil -- 1748
			local gi = 0 -- 1749
			do -- 1749
				gi = 0 -- 1750
				while gi < #self.enemies do -- 1750
					local e = self.enemies[gi + 1] -- 1751
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 1751
						gun = e -- 1753
						break -- 1754
					end -- 1754
					gi = gi + 1 -- 1750
				end -- 1750
			end -- 1750
			if gun ~= nil then -- 1750
				self:campaignEnemyFire(gun) -- 1758
			end -- 1758
		end -- 1758
		p.x = self.cartAxle + c.handleOffset -- 1761
		p.y = c.baseY + (c.depth or 0) -- 1762
		p.vx = 0 -- 1763
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 1763
			self.cartAxle = c.endX -- 1765
			self.cartDocked = true -- 1766
			self.gripping = false -- 1767
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 1768
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 1769
			self:flashSet("车轮入窝", 1.2) -- 1770
			self:log("车轮入窝") -- 1771
		end -- 1771
	end -- 1771
end -- 1719
function Play.prototype.stuckCart(self) -- 1777
	local i = 0 -- 1778
	do -- 1778
		i = 0 -- 1779
		while i < #self.boxes do -- 1779
			do -- 1779
				local b = self.boxes[i + 1] -- 1780
				if b.broken == true or b.breakable == nil or b.soft == true then -- 1780
					goto __continue287 -- 1782
				end -- 1782
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 1784
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 1784
					return true -- 1786
				end -- 1786
			end -- 1786
			::__continue287:: -- 1786
			i = i + 1 -- 1779
		end -- 1779
	end -- 1779
	return false -- 1789
end -- 1777
function Play.prototype.stepCampaignGoal(self) -- 1793
	local wr = self.room -- 1794
	local c = wr.campaign -- 1795
	if c == nil then -- 1795
		return -- 1797
	end -- 1797
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 1797
		self.objectiveDone = true -- 1800
	end -- 1800
	if c.goal == "reach_exit" then -- 1800
		self.objectiveDone = true -- 1803
	end -- 1803
	if not self.objectiveDone then -- 1803
		return -- 1806
	end -- 1806
	local p = self.player -- 1808
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 1809
	if p.x < c.exitX or not partnerOk then -- 1809
		return -- 1811
	end -- 1811
	if c.next ~= nil and c.next ~= "" then -- 1811
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 1814
		self:flashSet("过关 · " .. c.next, 1.2) -- 1815
	elseif not self.run.finished then -- 1815
		self.run.finished = true -- 1817
		self:flashSet( -- 1818
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 1818
			2 -- 1818
		) -- 1818
		self:log("C2 灰盒完成") -- 1819
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 1820
	end -- 1820
end -- 1793
function Play.prototype.stepCampaignPartner(self, dt) -- 1825
	local a = self.partner -- 1826
	local wr = self.room -- 1827
	local cp = wr.companion -- 1828
	if not a.alive then -- 1828
		return -- 1830
	end -- 1830
	local p = self.player -- 1832
	local wait = false -- 1833
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 1834
	local targetDepth = p.depth -- 1835
	if self.run.joined == false then -- 1835
		wait = true -- 1837
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1838
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1839
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 1839
		wait = true -- 1841
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1842
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1843
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 1843
		wait = true -- 1845
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1846
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1847
	end -- 1847
	if self.partnerStuck > 0.3 then -- 1847
		a.x = a.x + a.facing * 44 -- 1851
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 1852
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 1853
		self.partnerLaneHold = 1.1 -- 1854
		self.partnerStuck = 0 -- 1855
	end -- 1855
	if self.partnerLaneHold > 0 then -- 1855
		self.partnerLaneHold = self.partnerLaneHold - dt -- 1858
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 1859
	end -- 1859
	local dx = targetX - a.x -- 1861
	if not wait and math.abs(dx) > 74 then -- 1861
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 1863
		local before = a.x -- 1864
		a.vx = dx > 0 and speed or -speed -- 1865
		a.facing = dx > 0 and 1 or -1 -- 1866
		self:slideX(a, a.vx * dt) -- 1867
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 1867
			a.vy = CHILD_JUMP -- 1870
			a.onGround = false -- 1871
		end -- 1871
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 1873
	else -- 1873
		a.vx = 0 -- 1875
		self.partnerStuck = 0 -- 1876
	end -- 1876
	local dz = targetDepth - a.depth -- 1878
	if math.abs(dz) > 6 then -- 1878
		local step = math.max( -- 1880
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 1880
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 1880
		) -- 1880
		a.depth = a.depth + step -- 1881
	end -- 1881
	a.depthSpeed = 0 -- 1883
	a.h = CHILD_H -- 1884
	a.crouch = false -- 1885
	self:fallY(a, dt) -- 1886
end -- 1825
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 1890
	local p = self.player -- 1891
	local i = 0 -- 1892
	do -- 1892
		i = 0 -- 1893
		while i < #self.enemies do -- 1893
			do -- 1893
				local e = self.enemies[i + 1] -- 1894
				if not e.alive then -- 1894
					goto __continue311 -- 1896
				end -- 1896
				if e.hitT > 0 then -- 1896
					e.hitT = e.hitT - dt -- 1899
				end -- 1899
				if e.kind == "breaker" then -- 1899
					self:stepBreaker(e, dt) -- 1902
					goto __continue311 -- 1903
				end -- 1903
				if e.kind == "shield" then -- 1903
					self:stepShield(e, dt, input) -- 1906
					goto __continue311 -- 1907
				end -- 1907
				local dx = e.x - p.x -- 1910
				if not e.awake then -- 1910
					if math.abs(dx) > 520 then -- 1910
						goto __continue311 -- 1913
					end -- 1913
					e.awake = true -- 1915
					e.fireCd = 48 -- 1916
					goto __continue311 -- 1917
				end -- 1917
				if math.abs(dx) > ENEMY_RANGE then -- 1917
					goto __continue311 -- 1920
				end -- 1920
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 1920
					goto __continue311 -- 1925
				end -- 1925
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 1925
					goto __continue311 -- 1928
				end -- 1928
				if self:blockedShot(e, p) then -- 1928
					if e.warnT > 0 then -- 1928
						e.warnT = 0 -- 1934
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 1935
					end -- 1935
					goto __continue311 -- 1937
				end -- 1937
				if e.warnT > 0 then -- 1937
					e.warnT = e.warnT - 1 -- 1940
					if e.warnT <= 0 then -- 1940
						self:campaignEnemyFire(e) -- 1942
					end -- 1942
				elseif e.fireCd > 0 then -- 1942
					e.fireCd = e.fireCd - 1 -- 1945
					if e.fireCd <= 0 then -- 1945
						e.warnT = WARN_TICKS -- 1947
					end -- 1947
				else -- 1947
					e.fireCd = 40 -- 1950
				end -- 1950
			end -- 1950
			::__continue311:: -- 1950
			i = i + 1 -- 1893
		end -- 1893
	end -- 1893
end -- 1890
function Play.prototype.blockedShot(self, e, p) -- 1956
	local ex = e.x -- 1957
	local ey = e.y + (e.depth or 0) + e.h * 0.62 -- 1958
	local px = p.x -- 1959
	local py = p.y + p.depth + p.h * 0.55 -- 1960
	local dx = px - ex -- 1961
	local dy = py - ey -- 1962
	local len = math.sqrt(dx * dx + dy * dy) -- 1963
	if len < 0.01 then -- 1963
		return false -- 1965
	end -- 1965
	local ray = {x = ex, y = ey, dx = dx / len, dy = dy / len} -- 1967
	local best = -1 -- 1968
	local j = 0 -- 1969
	do -- 1969
		j = 0 -- 1970
		while j < #self.boxes do -- 1970
			do -- 1970
				local b = self.boxes[j + 1] -- 1971
				if b.broken == true or b.passable == true then -- 1971
					goto __continue331 -- 1973
				end -- 1973
				if b.id == "braced_shield" then -- 1973
					goto __continue331 -- 1978
				end -- 1978
				if not overlapsDepth(e.depth or 0, b.depth, ACTOR_DEPTH_HALF) then -- 1978
					goto __continue331 -- 1981
				end -- 1981
				local t = hitBox(ray, b) -- 1983
				if t >= 0 and t < len - 2 and (best < 0 or t < best) then -- 1983
					best = t -- 1985
				end -- 1985
			end -- 1985
			::__continue331:: -- 1985
			j = j + 1 -- 1970
		end -- 1970
	end -- 1970
	return best >= 0 -- 1988
end -- 1956
function Play.prototype.campaignEnemyFire(self, e) -- 1991
	local p = self.player -- 1992
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 1993
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 1993
		local ____self_bracedShield_34, ____hp_35 = self.bracedShield, "hp" -- 1993
		____self_bracedShield_34[____hp_35] = ____self_bracedShield_34[____hp_35] - 1 -- 1995
		self.boxes = __TS__ArrayFilter( -- 1996
			self.boxes, -- 1996
			function(____, b) return b.id ~= "braced_shield" end -- 1996
		) -- 1996
		self.bracedShield = nil -- 1997
		self:flashSet("残盾碎 · 挡下一发", 1) -- 1998
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 1999
		return -- 2000
	end -- 2000
	if self:blockedShot(e, p) then -- 2000
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 2003
		return -- 2004
	end -- 2004
	local cover = self:blockedByCover(e, p) -- 2006
	if cover ~= nil and self.coverHug then -- 2006
		self.coveredFlash = 0.5 -- 2008
		self:flashSet("掩体挡下", 0.6) -- 2009
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2010
		return -- 2015
	end -- 2015
	if self.invulnT > 0 then -- 2015
		return -- 2018
	end -- 2018
	self.invulnT = 0.7 -- 2020
	self.hp = self.hp - 1 -- 2021
	self:emit("actorHit", { -- 2022
		target = "player", -- 2022
		amount = 1, -- 2022
		hp = self.hp, -- 2022
		maxHp = self.maxHp, -- 2022
		enemyX = e.x -- 2022
	}) -- 2022
	self:flashSet( -- 2023
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2023
		0.8 -- 2023
	) -- 2023
	if self.hp <= 0 then -- 2023
		self:campaignFailed() -- 2025
	end -- 2025
end -- 1991
function Play.prototype.stepShield(self, e, dt, input) -- 2030
	local p = self.player -- 2031
	local dx = p.x - e.x -- 2032
	local adx = math.abs(dx) -- 2033
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 2036
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 2037
	if adx > 150 then -- 2037
		local before = e.x -- 2039
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 2040
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 2040
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2043
		end -- 2043
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 2043
		if p.rollT <= 0 and self.invulnT <= 0 then -- 2043
			self.invulnT = 0.7 -- 2047
			self.hp = self.hp - 1 -- 2048
			self:emit("actorHit", { -- 2049
				target = "player", -- 2049
				amount = 1, -- 2049
				hp = self.hp, -- 2049
				maxHp = self.maxHp, -- 2049
				enemyX = e.x -- 2049
			}) -- 2049
			self:flashSet( -- 2050
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2050
				0.8 -- 2050
			) -- 2050
			if self.hp <= 0 then -- 2050
				self:campaignFailed() -- 2052
				return -- 2053
			end -- 2053
		end -- 2053
		e.swingT = 70 -- 2056
	end -- 2056
	if (e.swingT or 0) > 0 then -- 2056
		e.swingT = (e.swingT or 0) - 1 -- 2059
	end -- 2059
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 2059
		local dd = p.depth - (e.depth or 0) -- 2062
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 2063
	end -- 2063
end -- 2030
function Play.prototype.stepBreaker(self, e, dt) -- 2068
	local p = self.player -- 2069
	if e.awake ~= true then -- 2069
		if math.abs(p.x - e.x) < 560 then -- 2069
			e.awake = true -- 2072
		else -- 2072
			return -- 2074
		end -- 2074
	end -- 2074
	local target = nil -- 2077
	local bestD = 1000000000 -- 2078
	local i = 0 -- 2079
	do -- 2079
		i = 0 -- 2080
		while i < #self.boxes do -- 2080
			do -- 2080
				local b = self.boxes[i + 1] -- 2081
				if b.breakable == nil or b.broken == true then -- 2081
					goto __continue356 -- 2083
				end -- 2083
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 2085
				if d < bestD then -- 2085
					bestD = d -- 2087
					target = b -- 2088
				end -- 2088
			end -- 2088
			::__continue356:: -- 2088
			i = i + 1 -- 2080
		end -- 2080
	end -- 2080
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 2091
	local dx = tx - e.x -- 2092
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 2093
	if math.abs(dx) > reach then -- 2093
		local before = e.x -- 2095
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 2096
		if math.abs(e.x - before) < 0.3 then -- 2096
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2098
		end -- 2098
	elseif (e.swingT or 0) <= 0 then -- 2098
		e.swingT = 64 -- 2101
		if target ~= nil then -- 2101
			self:damageProp(target, 2) -- 2103
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 2103
			self.invulnT = 0.7 -- 2105
			self.hp = self.hp - 1 -- 2106
			self:emit("actorHit", { -- 2107
				target = "player", -- 2107
				amount = 1, -- 2107
				hp = self.hp, -- 2107
				maxHp = self.maxHp, -- 2107
				enemyX = e.x -- 2107
			}) -- 2107
			self:flashSet("破障手近身", 0.8) -- 2108
			if self.hp <= 0 then -- 2108
				self:campaignFailed() -- 2110
				return -- 2111
			end -- 2111
		end -- 2111
	end -- 2111
	if (e.swingT or 0) > 0 then -- 2111
		e.swingT = (e.swingT or 0) - 1 -- 2116
	end -- 2116
end -- 2068
function Play.prototype.campaignFailed(self) -- 2120
	local p = self.player -- 2121
	self.hp = self.maxHp -- 2122
	self.invulnT = 1.2 -- 2123
	self.reloadT = 0 -- 2124
	self.gripping = false -- 2125
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 2126
	self:log("被击倒") -- 2127
	p.x = self.room.minX + 90 -- 2128
	p.y = 0 -- 2129
	p.depth = 0 -- 2130
	p.vx = 0 -- 2131
	p.vy = 0 -- 2132
	p.onGround = true -- 2133
	p.rollT = 0 -- 2134
	self.partner.x = p.x - 50 -- 2135
	self.partner.y = 0 -- 2136
	self.partner.depth = 0 -- 2137
	self.cam.x = p.x -- 2138
	local i = 0 -- 2139
	do -- 2139
		i = 0 -- 2140
		while i < #self.enemies do -- 2140
			do -- 2140
				local e = self.enemies[i + 1] -- 2141
				if not e.alive then -- 2141
					goto __continue368 -- 2143
				end -- 2143
				e.x = e.homeX == nil and e.x or e.homeX -- 2145
				e.warnT = 0 -- 2146
				e.fireCd = 40 -- 2147
				e.swingT = 0 -- 2148
				e.awake = false -- 2149
			end -- 2149
			::__continue368:: -- 2149
			i = i + 1 -- 2140
		end -- 2140
	end -- 2140
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 2151
end -- 2120
function Play.prototype.stepEnemies(self, dt, input) -- 2154
	local i = 0 -- 2155
	do -- 2155
		i = 0 -- 2156
		while i < #self.enemies do -- 2156
			local e = self.enemies[i + 1] -- 2157
			if e.hitT > 0 then -- 2157
				e.hitT = e.hitT - dt -- 2159
			end -- 2159
			i = i + 1 -- 2156
		end -- 2156
	end -- 2156
	if self.coveredFlash > 0 then -- 2156
		self.coveredFlash = self.coveredFlash - dt -- 2163
	end -- 2163
	if self.isCampaign then -- 2163
		self:stepCampaignEnemies(dt, input) -- 2166
		return -- 2167
	end -- 2167
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 2167
		return -- 2171
	end -- 2171
	do -- 2171
		i = 0 -- 2173
		while i < #self.enemies do -- 2173
			do -- 2173
				local e = self.enemies[i + 1] -- 2174
				if not e.alive then -- 2174
					goto __continue378 -- 2176
				end -- 2176
				if e.warnT > 0 then -- 2176
					e.warnT = e.warnT - 1 -- 2179
					if e.warnT <= 0 then -- 2179
						self:enemyFire(e, input) -- 2181
					end -- 2181
					goto __continue378 -- 2183
				end -- 2183
				if e.fireCd > 0 then -- 2183
					e.fireCd = e.fireCd - 1 -- 2186
					if e.fireCd <= 0 then -- 2186
						e.warnT = WARN_TICKS -- 2188
					end -- 2188
				else -- 2188
					e.warnT = WARN_TICKS -- 2192
				end -- 2192
			end -- 2192
			::__continue378:: -- 2192
			i = i + 1 -- 2173
		end -- 2173
	end -- 2173
end -- 2154
function Play.prototype.enemyFire(self, e, input) -- 2198
	local p = self.player -- 2199
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 2199
		self:flashSet("枪声响在远处", 0.4) -- 2201
		e.fireCd = FIRE_COOLDOWN -- 2202
		return -- 2203
	end -- 2203
	local cover = self:blockedByCover(e, p) -- 2206
	local hugging = cover ~= nil -- 2207
	self.coverBlocking = hugging -- 2208
	local covered = hugging and input.cover.held -- 2209
	if covered then -- 2209
		self.coveredFlash = 0.5 -- 2211
		self:flashSet("掩体挡下", 0.5) -- 2212
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2213
		e.fireCd = FIRE_COOLDOWN -- 2218
		return -- 2219
	end -- 2219
	self.hp = self.hp - 1 -- 2221
	self:emit("actorHit", { -- 2222
		target = "player", -- 2222
		amount = 1, -- 2222
		hp = self.hp, -- 2222
		maxHp = self.maxHp, -- 2222
		enemyX = e.x -- 2222
	}) -- 2222
	self:flashSet( -- 2223
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2223
		0.7 -- 2223
	) -- 2223
	e.fireCd = FIRE_COOLDOWN -- 2224
	if self.hp <= 0 then -- 2224
		self:gateFailed() -- 2226
	end -- 2226
end -- 2198
function Play.prototype.blockedByCover(self, enemy, p) -- 2231
	local b = self:coverAt(p) -- 2232
	if b == nil then -- 2232
		return nil -- 2234
	end -- 2234
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 2236
end -- 2231
function Play.prototype.gateFailed(self) -- 2240
	local ____temp_36 -- 2241
	if self.room.story == nil then -- 2241
		____temp_36 = nil -- 2241
	else -- 2241
		____temp_36 = self.room.story.gate -- 2241
	end -- 2241
	local g = ____temp_36 -- 2241
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 2242
	self.hp = self.maxHp -- 2243
	self.gateTick = 0 -- 2244
	self.gateSpawned = 0 -- 2245
	self.enemies = {} -- 2246
	self.gateFailCount = self.gateFailCount + 1 -- 2247
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 2249
	self.player.y = 0 -- 2250
	self.player.vy = 0 -- 2251
	self.player.depth = 0 -- 2252
	self.player.depthSpeed = 0 -- 2253
	self.player.onGround = true -- 2254
	self.player.crouch = false -- 2255
	self.player.h = SOLDIER_H -- 2256
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 2257
	self.partner.y = 0 -- 2258
	self.partner.vy = 0 -- 2259
	self.partner.depth = 0 -- 2260
	self.partner.depthSpeed = 0 -- 2261
	self.partner.onGround = true -- 2262
	self.cam.x = self.player.x -- 2263
	self.phase = "gate-idle" -- 2264
	self.phaseTick = 0 -- 2265
	self.coverHug = false -- 2266
	self.coverBlocking = false -- 2267
	self.coverEntity = "" -- 2268
	self.gateNeedConfirm = true -- 2269
	self.gateRestartArmed = false -- 2270
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 2271
end -- 2240
function Play.prototype.stepInteract(self, dt, input) -- 2274
	local p = self.player -- 2275
	local calmUsed = self.calmConsumed -- 2276
	self.calmConsumed = false -- 2277
	local calming = self.escort.state == "calming" -- 2279
	self.focusCart = false -- 2280
	if self.room.key == "outside" then -- 2280
		local c = self.room.cart -- 2282
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 2283
		local dy = p.y - c.baseY -- 2284
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 2285
	end -- 2285
	if not calmUsed and not calming then -- 2285
		self:stepCart(dt, input) -- 2289
	end -- 2289
	if calmUsed then -- 2289
		self:flashSet("安抚 · 敲两下", 0.8) -- 2294
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 2294
		if self.knockT > 0 then -- 2294
			self.knocks = self.knocks + 1 -- 2298
		else -- 2298
			self.knocks = 1 -- 2300
		end -- 2300
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 2302
		self.knockT = 1.2 -- 2303
		if self.knocks >= 2 then -- 2303
			self:flashSet("敲两下", 0.8) -- 2305
			self.knocks = 0 -- 2306
		else -- 2306
			self:flashSet("敲一下", 0.5) -- 2308
		end -- 2308
	elseif self.knockT > 0 then -- 2308
		self.knockT = self.knockT - dt -- 2311
		if self.knockT <= 0 then -- 2311
			self.knocks = 0 -- 2313
		end -- 2313
	end -- 2313
	local i = 0 -- 2318
	do -- 2318
		i = 0 -- 2319
		while i < #self.room.marks do -- 2319
			do -- 2319
				local m = self.room.marks[i + 1] -- 2320
				if m.kind ~= 0 then -- 2320
					goto __continue404 -- 2322
				end -- 2322
				local subjects = {self.partner, self.player} -- 2324
				local k = 0 -- 2325
				do -- 2325
					k = 0 -- 2326
					while k < #subjects do -- 2326
						do -- 2326
							local s = subjects[k + 1] -- 2327
							if not s.alive then -- 2327
								goto __continue407 -- 2329
							end -- 2329
							local dx = s.x - m.x -- 2331
							local dy = s.y - m.y -- 2332
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2332
								self.checkpoint = m.x -- 2334
								self.checkpointCartAxle = self.cartAxle -- 2335
								if self.cartDocked then -- 2335
									self:flashSet("检查点 · 车已落窝", 1) -- 2337
								else -- 2337
									self:flashSet("检查点 · 车还没到位", 1) -- 2339
								end -- 2339
							end -- 2339
						end -- 2339
						::__continue407:: -- 2339
						k = k + 1 -- 2326
					end -- 2326
				end -- 2326
			end -- 2326
			::__continue404:: -- 2326
			i = i + 1 -- 2319
		end -- 2319
	end -- 2319
	self:checkCarryGate() -- 2345
end -- 2274
function Play.prototype.stepVillage(self, dt, input) -- 2349
	if self.room.key ~= "village" then -- 2349
		return -- 2351
	end -- 2351
	local p = self.player -- 2353
	local bottle = self.room.bottle -- 2354
	local scav = self.room.scavenger -- 2355
	if not self.hasBottle and bottle ~= nil then -- 2355
		local dx = p.x - bottle.x -- 2359
		local dy = p.y + p.h * 0.5 - bottle.y -- 2360
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 2360
			self.hasBottle = true -- 2362
			self:flashSet("拾起瓶子", 0.8) -- 2363
		end -- 2363
	end -- 2363
	if self.hasBottle then -- 2363
		if input.aim.held then -- 2363
			self.aimHold = self.aimHold + dt -- 2370
			if self.aimHold > 1.2 then -- 2370
				self.aimHold = 1.2 -- 2372
			end -- 2372
			local cached = self:bottleEnd() -- 2375
			self.bottleAimX = cached.x -- 2376
			self.bottleAimY = cached.y -- 2377
		elseif input.aim.released then -- 2377
			if self.aimHold < 0.12 then -- 2377
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 2381
				self.aimHold = 0 -- 2382
			else -- 2382
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2384
				self:throwBottle(____end.x, ____end.y) -- 2385
				self.aimHold = 0 -- 2386
			end -- 2386
		end -- 2386
	else -- 2386
		self.aimHold = 0 -- 2390
		self.bottleAimX = -1 -- 2391
	end -- 2391
	local fly = self.bottleFly -- 2396
	if fly ~= nil then -- 2396
		fly.t = fly.t + dt -- 2398
		fly.x = fly.x0 + fly.vx * fly.t -- 2399
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 2400
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 2401
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 2401
			self:landBottle(fly) -- 2403
		end -- 2403
	end -- 2403
	if self.bottleLandT > 0 then -- 2403
		self.bottleLandT = self.bottleLandT - dt -- 2407
	end -- 2407
	if scav ~= nil then -- 2407
		self:stepScav(dt, scav) -- 2411
	end -- 2411
	local line = self.room.passLine -- 2414
	if line ~= nil and not self.passed and p.x >= line then -- 2414
		self.passed = true -- 2416
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 2417
	end -- 2417
	if self.passed and p.x >= self.ox + 640 then -- 2417
		self:requestRoom("forest", "过第一院出院") -- 2421
		self:flashSet("出院 · 北塔森林", 1.4) -- 2422
	end -- 2422
end -- 2349
function Play.prototype.bottleEnd(self) -- 2427
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2428
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 2431
	return {x = aim.x, y = g} -- 2432
end -- 2427
function Play.prototype.throwBottle(self, tx, ty) -- 2436
	local p = self.player -- 2437
	local dir = tx >= p.x and 1 or -1 -- 2439
	p.facing = dir -- 2440
	local x0 = p.x + dir * 10 -- 2441
	local y0 = p.y + p.h * 0.7 -- 2442
	self.bottleTargetX = tx -- 2443
	self.bottleTargetY = ty -- 2444
	self.bottleSurfaceY = ty -- 2445
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 2446
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 2447
	self.bottleFly = { -- 2448
		x = x0, -- 2448
		y = y0, -- 2448
		x0 = x0, -- 2448
		y0 = y0, -- 2448
		vx = vx, -- 2448
		vy = vy, -- 2448
		t = 0 -- 2448
	} -- 2448
	self.hasBottle = false -- 2449
	self:flashSet("投出", 0.4) -- 2450
	self:emit( -- 2451
		"bottleThrown", -- 2451
		{ -- 2451
			fromX = x0, -- 2452
			fromY = y0, -- 2453
			targetX = tx, -- 2454
			targetY = ty, -- 2455
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 2456
		} -- 2456
	) -- 2456
end -- 2436
function Play.prototype.landBottle(self, fly) -- 2461
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 2462
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 2463
	local s = self.room.scavenger -- 2464
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 2465
	self.bottleFly = nil -- 2466
	self.bottleTargetX = -1 -- 2467
	self.bottleTargetY = 0 -- 2468
	self.bottleSurfaceY = -1 -- 2469
	self.bottleLandX = x -- 2470
	self.bottleLandY = y -- 2471
	self.bottleLandT = 0.9 -- 2472
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 2473
	self:hearBottle(x) -- 2474
end -- 2461
function Play.prototype.hearBottle(self, x) -- 2478
	local s = self.room.scavenger -- 2479
	if s == nil then -- 2479
		return -- 2481
	end -- 2481
	if math.abs(x - self.scavX) > s.range then -- 2481
		self:flashSet("落地 · 他没听见", 0.6) -- 2484
		return -- 2485
	end -- 2485
	self.scavState = "turn" -- 2487
	self.scavT = s.hearTicks -- 2488
	self.scavTargetX = x -- 2489
	self:flashSet("砖地一响 · 他转头", 0.9) -- 2490
end -- 2478
function Play.prototype.stepScav(self, dt, s) -- 2494
	if self.scavState == "chase" then -- 2494
		return -- 2497
	end -- 2497
	if self.scavState == "turn" then -- 2497
		self.scavT = self.scavT - 1 -- 2500
		if self.scavT <= 0 then -- 2500
			self.scavState = "walk" -- 2502
		end -- 2502
		return -- 2504
	end -- 2504
	if self.scavState == "walk" then -- 2504
		local d = self.scavTargetX - self.scavX -- 2507
		if math.abs(d) < 4 then -- 2507
			self.scavState = "stall" -- 2509
			self.scavT = s.stallTicks -- 2510
			return -- 2511
		end -- 2511
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 2513
		return -- 2514
	end -- 2514
	if self.scavState == "stall" then -- 2514
		self.scavT = self.scavT - 1 -- 2517
		if self.scavT <= 0 then -- 2517
			self.scavState = "back" -- 2519
		end -- 2519
		return -- 2521
	end -- 2521
	if self.scavState == "back" then -- 2521
		local home = math.max( -- 2524
			s.x0, -- 2524
			math.min(s.x1, self.scavX) -- 2524
		) -- 2524
		if math.abs(home - self.scavX) < 2 then -- 2524
			self.scavState = "patrol" -- 2526
			return -- 2527
		end -- 2527
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 2529
		return -- 2530
	end -- 2530
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 2532
	if self.scavX >= s.x1 then -- 2532
		self.scavX = s.x1 -- 2534
		self.scavDir = -1 -- 2535
	elseif self.scavX <= s.x0 then -- 2535
		self.scavX = s.x0 -- 2537
		self.scavDir = 1 -- 2538
	end -- 2538
end -- 2494
function Play.prototype.stepCart(self, dt, input) -- 2546
	local p = self.player -- 2547
	local c = self.room.cart -- 2548
	if self.gripping then -- 2548
		if not input.interact.held then -- 2548
			self.gripping = false -- 2552
			self:flashSet("松开车把", 0.4) -- 2553
			return -- 2554
		end -- 2554
	else -- 2554
		if not input.interact.pressed then -- 2554
			return -- 2558
		end -- 2558
		if not self:cartHandleInReach(p) then -- 2558
			return -- 2561
		end -- 2561
		local track = c.depth or 0 -- 2563
		if self:limitDepth(p, track) ~= track then -- 2563
			return -- 2565
		end -- 2565
		p.depth = track -- 2567
		p.depthSpeed = 0 -- 2568
		self.gripping = true -- 2569
		self:flashSet("握住车把", 0.4) -- 2570
		return -- 2571
	end -- 2571
	if self.cartDocked then -- 2571
		return -- 2575
	end -- 2575
	local dir = input.moveX -- 2577
	if dir == 0 then -- 2577
		return -- 2579
	end -- 2579
	local lo = math.min(c.startX, c.endX) -- 2581
	local hi = math.max(c.startX, c.endX) -- 2582
	local next = self.cartAxle + dir * CART_SPEED * dt -- 2583
	if next < lo then -- 2583
		next = lo -- 2585
	end -- 2585
	if next > hi then -- 2585
		next = hi -- 2588
	end -- 2588
	local delta = next - self.cartAxle -- 2590
	if delta == 0 then -- 2590
		return -- 2592
	end -- 2592
	self.cartAxle = next -- 2594
	p.x = p.x + delta -- 2595
	p.facing = dir > 0 and 1 or -1 -- 2596
	self:slideX(p, 0) -- 2597
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 2597
		self.gripping = false -- 2599
		self:flashSet("跟不上了，脱手", 0.6) -- 2600
		return -- 2601
	end -- 2601
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 2601
		self.cartDocked = true -- 2604
		self.gripping = false -- 2605
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 2606
		self:flashSet("车轮落窝", 1.2) -- 2607
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 2607
		self:flashSet("车轮回到起点", 0.5) -- 2609
	end -- 2609
end -- 2546
function Play.prototype.requestRoom(self, key, reason) -- 2617
	if self.wantRoom ~= "" then -- 2617
		return -- 2621
	end -- 2621
	self.wantRoom = key -- 2623
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 2624
end -- 2617
function Play.prototype.checkCarryGate(self) -- 2631
	if self.room.key == "checkpoint" then -- 2631
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 2631
			self.carryCartAxle = self.cartAxle -- 2634
			self.carryCartDocked = self.cartDocked -- 2635
			self:requestRoom("gate", "检查站出口") -- 2636
			self:flashSet("出检查站 · 城门", 1.2) -- 2637
		end -- 2637
		return -- 2639
	end -- 2639
	if self.room.key == "outside" then -- 2639
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 2639
			self.carryCartAxle = self.cartAxle -- 2645
			self.carryCartDocked = self.cartDocked -- 2646
			self:requestRoom("village", "墙根走完") -- 2647
			self:flashSet("墙根走完 · 进村口", 1.2) -- 2648
		end -- 2648
	end -- 2648
end -- 2631
function Play.prototype.aimAt(self, wx, wy) -- 2655
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 2656
	self.aimX = s.x -- 2657
	self.aimY = s.y -- 2658
end -- 2655
function Play.prototype.shoot(self, a) -- 2661
	if self.isCampaign and self.reloadT > 0 then -- 2661
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 2663
		return -- 2664
	end -- 2664
	local ox = a.x + a.facing * 8 -- 2666
	local muzzleY = a.y + a.h * 0.72 -- 2667
	local oy = muzzleY + a.depth -- 2668
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2670
	local dx = aim.x - ox -- 2673
	local dy = aim.y - oy -- 2674
	local len = math.sqrt(dx * dx + dy * dy) -- 2675
	if len < 0.001 then -- 2675
		dx = a.facing -- 2677
		dy = 0 -- 2678
	else -- 2678
		dx = dx / len -- 2680
		dy = dy / len -- 2681
	end -- 2681
	if dx ~= 0 then -- 2681
		a.facing = dx > 0 and 1 or -1 -- 2684
	end -- 2684
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 2687
	local hitEnemy = self:raycastEnemies(ray) -- 2688
	local tEnemy = hitEnemy.t -- 2689
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 2690
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 2691
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 2692
	local tWall = solid.t -- 2693
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 2694
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 2695
	self.trace = { -- 2697
		x0 = ox, -- 2697
		y0 = oy, -- 2697
		x1 = ox + dx * t, -- 2697
		y1 = oy + dy * t, -- 2697
		hit = hit -- 2697
	} -- 2697
	self.traceT = 0.12 -- 2698
	self:applyFireDanger(ox) -- 2699
	local killed = false -- 2700
	if hit then -- 2700
		local i = hitEnemy.index -- 2702
		local e = self.enemies[i + 1] -- 2703
		local impactY = oy + dy * tEnemy -- 2704
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 2705
		local shieldTop = e.y + (e.depth or 0) + 64 -- 2706
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 2706
			e.shieldHp = (e.shieldHp or 0) - 1 -- 2708
			e.hitT = 0.3 -- 2709
			self:flashSet( -- 2710
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 2710
				0.8 -- 2710
			) -- 2710
			self:emit("shotResolved", { -- 2711
				hit = true, -- 2712
				enemyIndex = i, -- 2712
				enemyX = e.x, -- 2712
				aimX = aim.x, -- 2712
				aimY = aim.y, -- 2712
				impactX = ox + dx * t, -- 2713
				impactY = oy + dy * t, -- 2713
				shield = true -- 2713
			}) -- 2713
			self.reloadT = self.run.inventory.quickbelt > 0 and 36 or 54 -- 2715
			return -- 2716
		end -- 2716
		e.alive = false -- 2718
		e.hitT = 0.4 -- 2719
		killed = true -- 2720
		self:flashSet("命中", 0.6) -- 2721
		self:dropFor(e) -- 2722
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 2722
		self:damageProp(solid.box, 1) -- 2724
	else -- 2724
		self:flashSet("打空", 0.35) -- 2726
	end -- 2726
	if self.isCampaign then -- 2726
		self.reloadT = self.run.inventory.quickbelt > 0 and 36 or 54 -- 2729
	end -- 2729
	self:emit("shotResolved", { -- 2731
		hit = hit, -- 2732
		enemyIndex = hit and hitEnemy.index or -1, -- 2733
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 2734
		aimX = aim.x, -- 2735
		aimY = aim.y, -- 2736
		impactX = ox + dx * t, -- 2737
		impactY = oy + dy * t -- 2738
	}) -- 2738
end -- 2661
function Play.prototype.applyFireDanger(self, shotX) -- 2743
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 2743
		return -- 2745
	end -- 2745
	local dangerX = shotX -- 2747
	local best = -1 -- 2748
	local bestD = 1000000000 -- 2749
	local i = 0 -- 2750
	do -- 2750
		i = 0 -- 2751
		while i < #self.enemies do -- 2751
			do -- 2751
				local e = self.enemies[i + 1] -- 2752
				if not e.alive then -- 2752
					goto __continue483 -- 2754
				end -- 2754
				local d = math.abs(e.x - self.partner.x) -- 2756
				if d < bestD then -- 2756
					bestD = d -- 2758
					best = i -- 2759
				end -- 2759
			end -- 2759
			::__continue483:: -- 2759
			i = i + 1 -- 2751
		end -- 2751
	end -- 2751
	if best >= 0 then -- 2751
		dangerX = self.enemies[best + 1].x -- 2763
	end -- 2763
	local exposed = self:childExposed(dangerX) -- 2765
	local before = self.escort.fear -- 2766
	local dangerId = self.nextDangerId -- 2767
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 2768
	self.nextDangerId = self.nextDangerId + 1 -- 2769
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 2770
	if after > before then -- 2770
		self:flashSet( -- 2772
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 2772
			1 -- 2772
		) -- 2772
	elseif not exposed then -- 2772
		self:flashSet("枪声没够到她", 0.5) -- 2774
	end -- 2774
end -- 2743
function Play.prototype.childExposed(self, dangerX) -- 2779
	local c = self.partner -- 2780
	if not c.alive then -- 2780
		return false -- 2782
	end -- 2782
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 2782
		self.boxes, -- 2785
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 2785
	) then -- 2785
		return false -- 2786
	end -- 2786
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 2786
		return false -- 2789
	end -- 2789
	local toDanger = dangerX - c.x -- 2791
	local toPlayer = self.player.x - c.x -- 2792
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 2792
		return false -- 2795
	end -- 2795
	return true -- 2797
end -- 2779
function Play.prototype.raycastEnemies(self, ray) -- 2801
	local best = -1 -- 2802
	local bestI = -1 -- 2803
	do -- 2803
		local i = 0 -- 2804
		while i < #self.enemies do -- 2804
			do -- 2804
				local e = self.enemies[i + 1] -- 2805
				if not e.alive then -- 2805
					goto __continue497 -- 2807
				end -- 2807
				local y = e.y + (e.depth or 0) -- 2809
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 2810
				if t >= 0 and (best < 0 or t < best) then -- 2810
					best = t -- 2812
					bestI = i -- 2813
				end -- 2813
			end -- 2813
			::__continue497:: -- 2813
			i = i + 1 -- 2804
		end -- 2804
	end -- 2804
	return {t = best, index = bestI} -- 2816
end -- 2801
function Play.prototype.raycastWorld(self, ray) -- 2819
	return self:raycastSolid(ray).t -- 2820
end -- 2819
function Play.prototype.raycastSolid(self, ray) -- 2824
	local best = -1 -- 2825
	local bestBox = nil -- 2826
	for ____, box in ipairs(self.boxes) do -- 2827
		do -- 2827
			if box.broken == true or box.hidden == true then -- 2827
				goto __continue502 -- 2829
			end -- 2829
			if ray.depth ~= nil and not overlapsDepth(ray.depth, box.depth, ACTOR_DEPTH_HALF) then -- 2829
				goto __continue502 -- 2833
			end -- 2833
			local t = hitBox(ray, box) -- 2835
			if t >= 0 and (best < 0 or t < best) then -- 2835
				best = t -- 2837
				bestBox = box -- 2838
			end -- 2838
		end -- 2838
		::__continue502:: -- 2838
	end -- 2838
	if ray.dy < 0 then -- 2838
		local t = -ray.y / ray.dy -- 2842
		if t >= 0 and (best < 0 or t < best) then -- 2842
			best = t -- 2844
			bestBox = nil -- 2845
		end -- 2845
	end -- 2845
	return {t = best, box = bestBox} -- 2848
end -- 2824
function Play.prototype.dropFor(self, e) -- 2852
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 2852
		return -- 2854
	end -- 2854
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 2854
		return -- 2857
	end -- 2857
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 2859
	local ____self_pickups_37 = self.pickups -- 2859
	____self_pickups_37[#____self_pickups_37 + 1] = { -- 2860
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 2861
		kind = e.drop, -- 2861
		x = e.x, -- 2861
		y = e.y, -- 2861
		depth = e.depth, -- 2862
		label = label .. " ×1" -- 2862
	} -- 2862
	self:log("掉落 " .. label) -- 2864
end -- 2852
function Play.prototype.damageProp(self, b, amount) -- 2868
	if b.breakable == nil or b.broken == true then -- 2868
		return -- 2870
	end -- 2870
	local ____b_breakable_38, ____hp_39 = b.breakable, "hp" -- 2870
	____b_breakable_38[____hp_39] = ____b_breakable_38[____hp_39] - amount -- 2872
	if b.breakable.hp > 0 then -- 2872
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 2874
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 2875
		return -- 2876
	end -- 2876
	b.broken = true -- 2878
	for ____, other in ipairs(self.boxes) do -- 2879
		if other.id ~= nil and other.id == b.id then -- 2879
			other.broken = true -- 2881
		end -- 2881
	end -- 2881
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 2884
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 2885
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 2886
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 2887
end -- 2868
function Play.prototype.slideDepth(self, a, distance) -- 2891
	a.depth = self:limitDepth(a, a.depth + distance) -- 2892
end -- 2891
function Play.prototype.limitDepth(self, a, target) -- 2895
	local road = self.room.depth -- 2896
	if road == nil or target == a.depth then -- 2896
		return a.depth -- 2898
	end -- 2898
	local next = math.max( -- 2900
		road.min, -- 2900
		math.min(road.max, target) -- 2900
	) -- 2900
	local half = a.w / 2 -- 2901
	for ____, b in ipairs(self.boxes) do -- 2902
		do -- 2902
			local footprint = b.depth -- 2903
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 2903
				goto __continue521 -- 2908
			end -- 2908
			local front = footprint.min - ACTOR_DEPTH_HALF -- 2910
			local back = footprint.max + ACTOR_DEPTH_HALF -- 2911
			if a.depth <= front and next > front then -- 2911
				next = front -- 2913
			elseif a.depth >= back and next < back then -- 2913
				next = back -- 2915
			end -- 2915
		end -- 2915
		::__continue521:: -- 2915
	end -- 2915
	return next -- 2918
end -- 2895
function Play.prototype.slideX(self, a, dx) -- 2922
	local nx = a.x + dx -- 2923
	local half = a.w / 2 -- 2924
	local room = self.room -- 2925
	nx = math.max( -- 2926
		room.minX + half, -- 2926
		math.min(room.maxX - half, nx) -- 2926
	) -- 2926
	local i = 0 -- 2927
	do -- 2927
		i = 0 -- 2928
		while i < #self.boxes do -- 2928
			do -- 2928
				local b = self.boxes[i + 1] -- 2929
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 2929
					goto __continue528 -- 2931
				end -- 2931
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2931
					goto __continue528 -- 2934
				end -- 2934
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 2934
					goto __continue528 -- 2937
				end -- 2937
				if nx + half > b.x0 and nx - half < b.x1 then -- 2937
					if a.x <= b.x0 then -- 2937
						nx = b.x0 - half -- 2941
					elseif a.x >= b.x1 then -- 2941
						nx = b.x1 + half -- 2943
					else -- 2943
						nx = a.x -- 2945
					end -- 2945
				end -- 2945
			end -- 2945
			::__continue528:: -- 2945
			i = i + 1 -- 2928
		end -- 2928
	end -- 2928
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 2928
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 2953
		local bx0 = self.cartAxle - CART_HALF -- 2954
		local bx1 = self.cartAxle + CART_HALF -- 2955
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 2955
			if a.x <= bx0 then -- 2955
				nx = bx0 - half -- 2958
			elseif a.x >= bx1 then -- 2958
				nx = bx1 + half -- 2960
			else -- 2960
				nx = a.x -- 2962
			end -- 2962
		end -- 2962
	end -- 2962
	local arch = room.arch -- 2970
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 2970
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 2972
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 2972
			if a.x <= arch.x0 then -- 2972
				nx = arch.x0 - half -- 2975
			elseif a.x >= arch.x1 then -- 2975
				nx = arch.x1 + half -- 2977
			end -- 2977
		end -- 2977
	end -- 2977
	a.x = nx -- 2981
end -- 2922
function Play.prototype.fallY(self, a, dt) -- 2985
	a.vy = a.vy - ____exports.GRAVITY * dt -- 2986
	if a.vy < -900 then -- 2986
		a.vy = -900 -- 2988
	end -- 2988
	local ny = a.y + a.vy * dt -- 2990
	local half = a.w / 2 -- 2991
	if a.vy <= 0 then -- 2991
		local reach = a.onGround and STEP_UP or 0 -- 2994
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 2995
		if ny <= ground then -- 2995
			ny = ground -- 2997
			a.vy = 0 -- 2998
			a.onGround = true -- 2999
		else -- 2999
			a.onGround = false -- 3001
		end -- 3001
	else -- 3001
		a.onGround = false -- 3004
		local i = 0 -- 3005
		do -- 3005
			i = 0 -- 3006
			while i < #self.boxes do -- 3006
				do -- 3006
					local b = self.boxes[i + 1] -- 3007
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3007
						goto __continue552 -- 3009
					end -- 3009
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3009
						goto __continue552 -- 3012
					end -- 3012
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 3012
						goto __continue552 -- 3015
					end -- 3015
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 3015
						ny = b.y0 - a.h -- 3018
						a.vy = 0 -- 3019
					end -- 3019
				end -- 3019
				::__continue552:: -- 3019
				i = i + 1 -- 3006
			end -- 3006
		end -- 3006
	end -- 3006
	a.y = ny -- 3023
end -- 2985
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 3027
	if depth == nil then -- 3027
		depth = 0 -- 3027
	end -- 3027
	local g = -9999 -- 3028
	local i = 0 -- 3029
	do -- 3029
		i = 0 -- 3030
		while i < #self.floors do -- 3030
			local f = self.floors[i + 1] -- 3031
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 3031
				g = f.y1 -- 3033
			end -- 3033
			i = i + 1 -- 3030
		end -- 3030
	end -- 3030
	do -- 3030
		i = 0 -- 3036
		while i < #self.boxes do -- 3036
			do -- 3036
				local b = self.boxes[i + 1] -- 3037
				if b.broken == true or b.hidden == true or b.soft == true then -- 3037
					goto __continue562 -- 3039
				end -- 3039
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 3039
					g = b.y1 -- 3043
				end -- 3043
			end -- 3043
			::__continue562:: -- 3043
			i = i + 1 -- 3036
		end -- 3036
	end -- 3036
	return g -- 3046
end -- 3027
function Play.prototype.updateCamera(self, dt) -- 3049
	local p = self.player -- 3050
	local tx = p.x + p.facing * 30 -- 3051
	local ty = p.y + CAM_LOOK_UP -- 3052
	local k = math.min(1, CAM_FOLLOW * dt) -- 3053
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 3054
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 3055
end -- 3049
function Play.prototype.clampCamera(self, w, h) -- 3059
	local room = self.room -- 3060
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 3061
	local spanX = room.maxX - room.minX -- 3062
	if spanX <= halfW * 2 then -- 3062
		self.cam.x = (room.minX + room.maxX) / 2 -- 3064
	else -- 3064
		self.cam.x = math.max( -- 3066
			room.minX + halfW, -- 3066
			math.min(room.maxX - halfW, self.cam.x) -- 3066
		) -- 3066
	end -- 3066
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 3069
	local spanY = room.height -- 3070
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 3071
	if spanY <= halfH * 2 then -- 3071
		self.cam.y = camY -- 3073
	else -- 3073
		self.cam.y = math.max( -- 3075
			camY, -- 3075
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 3075
		) -- 3075
	end -- 3075
end -- 3059
function Play.prototype.flashSet(self, text, t) -- 3079
	self.flash = text -- 3080
	self.flashT = t -- 3081
end -- 3079
function Play.prototype.statusText(self) -- 3085
	local p = self.player -- 3086
	local parts = {} -- 3087
	local who = self.childMode and "小满" or "周戍" -- 3088
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 3089
	if self.room.key == "prologue" then -- 3089
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3092
		if self.phase == "prologue-wait" then -- 3092
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 3094
		elseif self.phase == "prologue-give" then -- 3094
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 3096
		else -- 3096
			parts[#parts + 1] = "跟随" -- 3098
		end -- 3098
		if self.paused then -- 3098
			parts[#parts + 1] = "已暂停" -- 3101
		end -- 3101
		return table.concat(parts, " · ") -- 3103
	end -- 3103
	if self.room.key == "street" then -- 3103
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3106
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3107
		if self.paused then -- 3107
			parts[#parts + 1] = "已暂停" -- 3109
		end -- 3109
		return table.concat(parts, " · ") -- 3111
	end -- 3111
	if self.room.key == "gate" then -- 3111
		local ____temp_40 -- 3114
		if self.room.story == nil then -- 3114
			____temp_40 = nil -- 3114
		else -- 3114
			____temp_40 = self.room.story.gate -- 3114
		end -- 3114
		local g = ____temp_40 -- 3114
		if g ~= nil then -- 3114
			parts[#parts + 1] = self:gateLabel() -- 3116
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 3117
				0, -- 3118
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 3118
			))) .. " 秒" -- 3118
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3119
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3120
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 3121
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 3122
			if self.gateFailCount > 0 then -- 3122
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 3124
			end -- 3124
			if self.flash ~= "" then -- 3124
				parts[#parts + 1] = self.flash -- 3127
			end -- 3127
		end -- 3127
		if self.paused then -- 3127
			parts[#parts + 1] = "已暂停" -- 3131
		end -- 3131
		return table.concat(parts, " · ") -- 3133
	end -- 3133
	if self.room.key == "forest" then -- 3133
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3136
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 3137
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 3138
		if self.caughtT > 0 then -- 3138
			parts[#parts + 1] = "复位中" -- 3140
		end -- 3140
		if self.paused then -- 3140
			parts[#parts + 1] = "已暂停" -- 3143
		end -- 3143
		return table.concat(parts, " · ") -- 3145
	end -- 3145
	if self.room.key == "tower" then -- 3145
		if self.phase == "tower-wait" then -- 3145
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 3149
		elseif self.phase == "tower-knock" then -- 3149
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 3151
		elseif self.phase == "tower-given" then -- 3151
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 3153
		else -- 3153
			parts[#parts + 1] = "片尾" -- 3155
		end -- 3155
		if self.paused then -- 3155
			parts[#parts + 1] = "已暂停" -- 3158
		end -- 3158
		return table.concat(parts, " · ") -- 3160
	end -- 3160
	if self.room.key == "village" then -- 3160
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3163
		if self.hasBottle then -- 3163
			parts[#parts + 1] = "有瓶" -- 3165
		elseif self.bottleFly ~= nil then -- 3165
			parts[#parts + 1] = "瓶在飞" -- 3167
		else -- 3167
			parts[#parts + 1] = "空手" -- 3169
		end -- 3169
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 3171
		if self.scavChase then -- 3171
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 3173
		end -- 3173
		if self.passed then -- 3173
			parts[#parts + 1] = "已过通行线" -- 3176
		end -- 3176
		if self.paused then -- 3176
			parts[#parts + 1] = "已暂停" -- 3179
		end -- 3179
		return table.concat(parts, " · ") -- 3181
	end -- 3181
	local isChild = self.childMode -- 3184
	if isChild then -- 3184
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3186
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 3187
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3188
	else -- 3188
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 3190
		if p.rollT > 0 then -- 3190
			parts[#parts + 1] = "翻滚中" -- 3192
		end -- 3192
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3194
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3195
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 3196
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 3197
	end -- 3197
	if self.checkpoint >= 0 then -- 3197
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 3200
	end -- 3200
	if self.paused then -- 3200
		parts[#parts + 1] = "已暂停" -- 3203
	end -- 3203
	return table.concat(parts, " · ") -- 3205
end -- 3085
function Play.prototype.aliveEnemies(self) -- 3209
	local n = 0 -- 3210
	local i = 0 -- 3211
	do -- 3211
		i = 0 -- 3212
		while i < #self.enemies do -- 3212
			if self.enemies[i + 1].alive then -- 3212
				n = n + 1 -- 3214
			end -- 3214
			i = i + 1 -- 3212
		end -- 3212
	end -- 3212
	return n -- 3217
end -- 3209
function Play.prototype.threatened(self) -- 3222
	do -- 3222
		local i = 0 -- 3223
		while i < #self.enemies do -- 3223
			local e = self.enemies[i + 1] -- 3224
			if e.alive and e.warnT > 0 then -- 3224
				return true -- 3226
			end -- 3226
			i = i + 1 -- 3223
		end -- 3223
	end -- 3223
	return false -- 3229
end -- 3222
function Play.prototype.gateSecondsLeft(self) -- 3232
	local ____temp_41 -- 3233
	if self.room.story == nil then -- 3233
		____temp_41 = nil -- 3233
	else -- 3233
		____temp_41 = self.room.story.gate -- 3233
	end -- 3233
	local g = ____temp_41 -- 3233
	if g == nil then -- 3233
		return 0 -- 3235
	end -- 3235
	return math.max( -- 3237
		0, -- 3237
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 3237
	) -- 3237
end -- 3232
function Play.prototype.gateLabel(self) -- 3240
	if self.phase == "gate-idle" then -- 3240
		return "待就位" -- 3242
	end -- 3242
	if self.phase == "gate-hold" then -- 3242
		return "守点中" -- 3245
	end -- 3245
	if self.phase == "gate-send" then -- 3245
		return "送别" -- 3248
	end -- 3248
	if self.phase == "gate-count" then -- 3248
		return "数数 " .. tostring(self.countTick) -- 3251
	end -- 3251
	return "她走" -- 3253
end -- 3240
function Play.prototype.dogLabel(self) -- 3257
	if self.dogState == "ear" then -- 3257
		return "转耳" -- 3259
	end -- 3259
	if self.dogState == "chase" then -- 3259
		return "追" -- 3262
	end -- 3262
	if self.dogState == "sniff" then -- 3262
		return "停" -- 3265
	end -- 3265
	if self.dogState == "back" then -- 3265
		return "回线" -- 3268
	end -- 3268
	return "巡逻" -- 3270
end -- 3257
function Play.prototype.doorXOf(self) -- 3273
	local ____temp_42 -- 3274
	if self.room.story == nil then -- 3274
		____temp_42 = nil -- 3274
	else -- 3274
		____temp_42 = self.room.story.tower -- 3274
	end -- 3274
	local t = ____temp_42 -- 3274
	return t == nil and 0 or t.doorX -- 3275
end -- 3273
function Play.prototype.scavLabel(self) -- 3279
	if self.scavState == "chase" then -- 3279
		return "追" -- 3281
	end -- 3281
	if self.scavState == "turn" then -- 3281
		return "转头" -- 3284
	end -- 3284
	if self.scavState == "walk" then -- 3284
		return "赶来" -- 3287
	end -- 3287
	if self.scavState == "stall" then -- 3287
		return "停住" -- 3290
	end -- 3290
	if self.scavState == "back" then -- 3290
		return "回位" -- 3293
	end -- 3293
	return "巡逻" -- 3295
end -- 3279
function Play.prototype.hintText(self) -- 3299
	if self.paused then -- 3299
		return "Esc 继续 · R 重置" -- 3301
	end -- 3301
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 3301
		if self:threatened() then -- 3301
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 3307
		end -- 3307
		if self.coverHug then -- 3307
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 3310
		end -- 3310
		if self.coverNear then -- 3310
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 3313
		end -- 3313
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 3315
	end -- 3315
	if self.flash ~= "" then -- 3315
		return self.flash -- 3318
	end -- 3318
	if self.room.key == "prologue" then -- 3318
		if self.phase == "prologue-wait" then -- 3318
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 3322
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 3323
		end -- 3323
		if self.phase == "prologue-give" then -- 3323
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 3326
		end -- 3326
		return "她跟着你了 · 两人一起走到门口 680" -- 3328
	end -- 3328
	if self.room.key == "street" then -- 3328
		if self:aliveEnemies() > 0 then -- 3328
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 3332
		end -- 3332
		return "清完了 · 两人一起走到右边检查站入口 900" -- 3334
	end -- 3334
	if self.room.key == "gate" then -- 3334
		local ____temp_43 -- 3337
		if self.room.story == nil then -- 3337
			____temp_43 = nil -- 3337
		else -- 3337
			____temp_43 = self.room.story.gate -- 3337
		end -- 3337
		local g = ____temp_43 -- 3337
		if g ~= nil then -- 3337
			if self.phase == "gate-idle" then -- 3337
				if self.gateNeedConfirm then -- 3337
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 3341
				end -- 3341
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 3343
			end -- 3343
			if self.phase == "gate-hold" then -- 3343
				if self.coveredFlash > 0 then -- 3343
					return "掩体挡下了这一枪 · 别露头" -- 3347
				end -- 3347
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 3349
			end -- 3349
			if self.phase == "gate-send" then -- 3349
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 3352
			end -- 3352
			if self.phase == "gate-count" then -- 3352
				if self.countTick >= 1440 then -- 3352
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 3356
				end -- 3356
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 3358
			end -- 3358
			return "她自己走 · 跟着出城门 1120" -- 3360
		end -- 3360
	end -- 3360
	if self.room.key == "forest" then -- 3360
		if self.dogState == "chase" then -- 3360
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 3365
		end -- 3365
		if self.dogState == "ear" then -- 3365
			return "狗转耳朵了 · 停下或蹲下别出声" -- 3368
		end -- 3368
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 3370
	end -- 3370
	if self.room.key == "tower" then -- 3370
		if self.phase == "tower-wait" then -- 3370
			return "走到门前 445 点一次 E 敲两下" -- 3374
		end -- 3374
		if self.phase == "tower-knock" then -- 3374
			return "敲两下 · 等门开" -- 3377
		end -- 3377
		if self.phase == "tower-given" then -- 3377
			return "递交针套和纸条 · 看登记簿最后一行" -- 3380
		end -- 3380
		return "片尾 · 点 E 再玩一次，回到序章" -- 3382
	end -- 3382
	if self.room.key == "village" then -- 3382
		if self.bottleFly ~= nil then -- 3382
			return "等瓶子落地 · 触地才发声" -- 3386
		end -- 3386
		if self.hasBottle then -- 3386
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 3389
		end -- 3389
		if self.passed then -- 3389
			return "已过第一院 · R 重置可再来一遍" -- 3392
		end -- 3392
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 3394
	end -- 3394
	if self.room.key == "outside" then -- 3394
		if self.focusCart then -- 3394
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 3398
		end -- 3398
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 3400
	end -- 3400
	if self.escort.state == "frozen" then -- 3400
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 3400
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 3404
		end -- 3404
		return "小满吓住了 · 走过去，靠近再点 E" -- 3406
	end -- 3406
	if self.escort.state == "calming" then -- 3406
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 3409
	end -- 3409
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 3411
end -- 3299
function Play.prototype.draw(self, draw, w, h) -- 3416
	self.viewW = w -- 3417
	self.viewH = h -- 3418
	self.view = ____exports.computeViewport(w, h) -- 3419
	self:clampCamera(w, h) -- 3420
	draw:clear() -- 3421
	draw:drawRect( -- 3423
		Rect(0, 0, w, h), -- 3423
		BG_VOID -- 3423
	) -- 3423
	local box = self:canvasRect(w, h) -- 3424
	draw:drawRect(box, BG_FAR) -- 3425
	draw:drawRect( -- 3426
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 3426
		BG_MID -- 3426
	) -- 3426
	self:drawFloors(draw, w, h) -- 3428
	self:drawSolids(draw, w, h) -- 3429
	self:drawZones(draw, w, h) -- 3430
	self:drawArch(draw, w, h) -- 3431
	self:drawCart(draw, w, h) -- 3432
	self:drawCampaignProps(draw, w, h) -- 3433
	self:drawActors(draw, w, h) -- 3434
	self:drawTrace(draw, w, h) -- 3435
	self:drawAim(draw, w, h) -- 3436
end -- 3416
function Play.prototype.canvasRect(self, w, h) -- 3440
	local v = self.view -- 3441
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 3442
end -- 3440
function Play.prototype.px(self, n) -- 3446
	return n * self.view.zoom -- 3447
end -- 3446
function Play.prototype.sx(self, wx, w) -- 3451
	local v = self.view -- 3452
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 3453
	return v.ox + lx * v.zoom -- 3454
end -- 3451
function Play.prototype.sy(self, wy, h) -- 3458
	local v = self.view -- 3459
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 3460
	return v.oy + ly * v.zoom -- 3461
end -- 3458
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 3464
	local px0 = self:sx(x0, w) -- 3465
	local px1 = self:sx(x1, w) -- 3466
	local py0 = self:sy(y0, h) -- 3467
	local py1 = self:sy(y1, h) -- 3468
	if px1 <= px0 or py1 <= py0 then -- 3468
		return -- 3470
	end -- 3470
	draw:drawRect( -- 3472
		Rect(px0, py0, px1 - px0, py1 - py0), -- 3472
		color -- 3472
	) -- 3472
end -- 3464
function Play.prototype.drawFloors(self, draw, w, h) -- 3475
	local i = 0 -- 3476
	do -- 3476
		i = 0 -- 3477
		while i < #self.room.floors do -- 3477
			local f = self.room.floors[i + 1] -- 3478
			local ____temp_44 -- 3479
			if f.y == 0 then -- 3479
				____temp_44 = self.room.depth -- 3479
			else -- 3479
				____temp_44 = nil -- 3479
			end -- 3479
			local road = ____temp_44 -- 3479
			local y = self:sy(f.y + (road and road.min or 0), h) -- 3480
			local x0 = self:sx(f.x0, w) -- 3481
			local x1 = self:sx(f.x1, w) -- 3482
			local deck = self:px(5) -- 3483
			if road ~= nil then -- 3483
				local back = self:sy(f.y + road.max, h) -- 3485
				draw:drawRect( -- 3486
					Rect(x0, y, x1 - x0, back - y), -- 3486
					FLOOR_DECK, -- 3486
					self:px(1), -- 3486
					SOLID_EDGE -- 3486
				) -- 3486
			end -- 3486
			draw:drawRect( -- 3488
				Rect(x0, y - deck, x1 - x0, deck), -- 3488
				FLOOR_DECK -- 3488
			) -- 3488
			draw:drawSegment( -- 3489
				Vec2(x0, y), -- 3489
				Vec2(x1, y), -- 3489
				self:px(1), -- 3489
				GROUND -- 3489
			) -- 3489
			i = i + 1 -- 3477
		end -- 3477
	end -- 3477
end -- 3475
function Play.prototype.drawSolids(self, draw, w, h) -- 3493
	local i = 0 -- 3494
	do -- 3494
		i = 0 -- 3495
		while i < #self.boxes do -- 3495
			do -- 3495
				local b = self.boxes[i + 1] -- 3496
				if b.id == "braced_shield" or b.hidden == true then -- 3496
					goto __continue683 -- 3498
				end -- 3498
				if b.broken == true then -- 3498
					if b.breakable ~= nil then -- 3498
						local gy = self:sy(b.y0, h) -- 3503
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 3504
						local k = 0 -- 3505
						do -- 3505
							k = 0 -- 3506
							while k < 3 do -- 3506
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 3507
								draw:drawSegment( -- 3508
									Vec2( -- 3508
										gx - self:px(4), -- 3508
										gy + self:px(k % 2) -- 3508
									), -- 3508
									Vec2( -- 3508
										gx + self:px(5), -- 3508
										gy + self:px(k % 2) -- 3508
									), -- 3508
									self:px(1), -- 3508
									rgb -- 3508
								) -- 3508
								k = k + 1 -- 3506
							end -- 3506
						end -- 3506
					end -- 3506
					goto __continue683 -- 3511
				end -- 3511
				local ____opt_47 = b.depth -- 3511
				local front = ____opt_47 and ____opt_47.min or 0 -- 3513
				local ____opt_49 = b.depth -- 3513
				local back = ____opt_49 and ____opt_49.max or 0 -- 3514
				local fill = SOLID_FILL -- 3515
				local line = SOLID_EDGE -- 3516
				if b.soft == true then -- 3516
					fill = SOFT -- 3518
					line = SOFT_LINE -- 3519
				elseif b.breakable ~= nil then -- 3519
					line = DANGER_LINE -- 3521
					fill = Color(0.3, 0.24, 0.16, 1) -- 3522
				elseif b.interact ~= nil then -- 3522
					line = PASS_LINE -- 3524
				end -- 3524
				self:drawBox( -- 3526
					draw, -- 3526
					w, -- 3526
					h, -- 3526
					b.x0, -- 3526
					b.x1, -- 3526
					b.y0 + front, -- 3526
					b.y1 + back, -- 3526
					fill -- 3526
				) -- 3526
				draw:drawSegment( -- 3527
					Vec2( -- 3527
						self:sx(b.x0, w), -- 3527
						self:sy(b.y1 + front, h) -- 3527
					), -- 3527
					Vec2( -- 3528
						self:sx(b.x1, w), -- 3528
						self:sy(b.y1 + front, h) -- 3528
					), -- 3528
					self:px(1), -- 3528
					line -- 3528
				) -- 3528
				if b.breakable ~= nil then -- 3528
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 3531
					local cyp = self:sy(b.y1 + front, h) -- 3532
					draw:drawSegment( -- 3533
						Vec2( -- 3533
							cxp - self:px(4), -- 3533
							cyp + self:px(1) -- 3533
						), -- 3533
						Vec2( -- 3533
							cxp + self:px(3), -- 3533
							cyp + self:px(5) -- 3533
						), -- 3533
						self:px(1), -- 3533
						line -- 3533
					) -- 3533
				end -- 3533
			end -- 3533
			::__continue683:: -- 3533
			i = i + 1 -- 3495
		end -- 3495
	end -- 3495
end -- 3493
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 3539
	local i = 0 -- 3540
	do -- 3540
		i = 0 -- 3541
		while i < #self.pickups do -- 3541
			do -- 3541
				local pk = self.pickups[i + 1] -- 3542
				if pk.id == "" then -- 3542
					goto __continue695 -- 3544
				end -- 3544
				local gy = pk.y + (pk.depth or 0) -- 3546
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 3547
				draw:drawRect( -- 3548
					Rect( -- 3548
						self:sx(pk.x - 5, w), -- 3548
						self:sy(gy + 12 + bob, h), -- 3548
						self:px(10), -- 3548
						self:px(10) -- 3548
					), -- 3548
					Color(0.84, 0.7, 0.3, 1) -- 3549
				) -- 3549
				draw:drawSegment( -- 3550
					Vec2( -- 3550
						self:sx(pk.x - 5, w), -- 3550
						self:sy(gy + 12 + bob, h) -- 3550
					), -- 3550
					Vec2( -- 3551
						self:sx(pk.x + 5, w), -- 3551
						self:sy(gy + 12 + bob, h) -- 3551
					), -- 3551
					self:px(1), -- 3551
					Color(0.95, 0.86, 0.52, 1) -- 3551
				) -- 3551
			end -- 3551
			::__continue695:: -- 3551
			i = i + 1 -- 3541
		end -- 3541
	end -- 3541
	if self.bracedShield ~= nil then -- 3541
		local sh = self.bracedShield -- 3554
		draw:drawRect( -- 3555
			Rect( -- 3555
				self:sx(sh.x - sh.w / 2, w), -- 3555
				self:sy(sh.y, h), -- 3555
				self:px(sh.w), -- 3555
				self:px(sh.h) -- 3555
			), -- 3555
			Color(0.42, 0.4, 0.34, 1) -- 3556
		) -- 3556
		draw:drawSegment( -- 3557
			Vec2( -- 3557
				self:sx(sh.x - sh.w / 2, w), -- 3557
				self:sy(sh.y + sh.h, h) -- 3557
			), -- 3557
			Vec2( -- 3558
				self:sx(sh.x + sh.w / 2, w), -- 3558
				self:sy(sh.y + sh.h, h) -- 3558
			), -- 3558
			self:px(1), -- 3558
			Color(0.74, 0.72, 0.62, 1) -- 3558
		) -- 3558
	end -- 3558
end -- 3539
function Play.prototype.drawZones(self, draw, w, h) -- 3562
	local i = 0 -- 3563
	do -- 3563
		i = 0 -- 3564
		while i < #self.room.zones do -- 3564
			local z = self.room.zones[i + 1] -- 3565
			local fill = DANGER -- 3566
			local line = DANGER_LINE -- 3567
			if z.tint == 2 then -- 3567
				fill = SOFT -- 3569
				line = SOFT_LINE -- 3570
			elseif z.tint == 3 then -- 3570
				fill = BRICK -- 3572
				line = BRICK_LINE -- 3573
			elseif z.tint == 4 then -- 3573
				fill = PASS -- 3575
				line = PASS_LINE -- 3576
			end -- 3576
			self:drawBox( -- 3578
				draw, -- 3578
				w, -- 3578
				h, -- 3578
				z.x0, -- 3578
				z.x1, -- 3578
				z.y, -- 3578
				z.y + z.h, -- 3578
				fill -- 3578
			) -- 3578
			draw:drawSegment( -- 3579
				Vec2( -- 3579
					self:sx(z.x0, w), -- 3579
					self:sy(z.y, h) -- 3579
				), -- 3579
				Vec2( -- 3579
					self:sx(z.x0, w), -- 3579
					self:sy(z.y + z.h, h) -- 3579
				), -- 3579
				self:px(1), -- 3579
				line -- 3579
			) -- 3579
			draw:drawSegment( -- 3580
				Vec2( -- 3580
					self:sx(z.x1, w), -- 3580
					self:sy(z.y, h) -- 3580
				), -- 3580
				Vec2( -- 3580
					self:sx(z.x1, w), -- 3580
					self:sy(z.y + z.h, h) -- 3580
				), -- 3580
				self:px(1), -- 3580
				line -- 3580
			) -- 3580
			i = i + 1 -- 3564
		end -- 3564
	end -- 3564
end -- 3562
function Play.prototype.drawArch(self, draw, w, h) -- 3584
	local a = self.room.arch -- 3585
	if a.h <= 0 then -- 3585
		return -- 3587
	end -- 3587
	self:drawBox( -- 3589
		draw, -- 3589
		w, -- 3589
		h, -- 3589
		a.x0, -- 3589
		a.x1, -- 3589
		a.y, -- 3589
		a.y + a.h, -- 3589
		HOLE_FILL -- 3589
	) -- 3589
	draw:drawSegment( -- 3590
		Vec2( -- 3590
			self:sx(a.x0, w), -- 3590
			self:sy(a.y + a.h, h) -- 3590
		), -- 3590
		Vec2( -- 3590
			self:sx(a.x1, w), -- 3590
			self:sy(a.y + a.h, h) -- 3590
		), -- 3590
		self:px(1), -- 3590
		SOLID_EDGE -- 3590
	) -- 3590
	draw:drawSegment( -- 3591
		Vec2( -- 3591
			self:sx(a.x0, w), -- 3591
			self:sy(a.y, h) -- 3591
		), -- 3591
		Vec2( -- 3591
			self:sx(a.x0, w), -- 3591
			self:sy(a.y + a.h, h) -- 3591
		), -- 3591
		self:px(1), -- 3591
		SOLID_EDGE -- 3591
	) -- 3591
	draw:drawSegment( -- 3592
		Vec2( -- 3592
			self:sx(a.x1, w), -- 3592
			self:sy(a.y, h) -- 3592
		), -- 3592
		Vec2( -- 3592
			self:sx(a.x1, w), -- 3592
			self:sy(a.y + a.h, h) -- 3592
		), -- 3592
		self:px(1), -- 3592
		SOLID_EDGE -- 3592
	) -- 3592
end -- 3584
function Play.prototype.drawCart(self, draw, w, h) -- 3595
	local c = self.room.cart -- 3596
	if c.bodyW <= 0 then -- 3596
		return -- 3598
	end -- 3598
	drawCartShape( -- 3600
		draw, -- 3600
		self, -- 3600
		w, -- 3600
		h, -- 3600
		c, -- 3600
		self.cartAxle -- 3600
	) -- 3600
	draw:drawRect( -- 3601
		Rect( -- 3601
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 3601
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 3601
			self:px(2), -- 3601
			self:px(40) -- 3601
		), -- 3601
		STAND -- 3601
	) -- 3601
end -- 3595
function Play.prototype.drawActors(self, draw, w, h) -- 3604
	local p = self.player -- 3605
	local isChild = self.childMode -- 3606
	local footY = p.y + p.depth -- 3607
	if p.covered then -- 3607
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 3610
		draw:drawSegment( -- 3611
			Vec2( -- 3611
				self:sx(edge, w), -- 3611
				self:sy(footY + 8, h) -- 3611
			), -- 3611
			Vec2( -- 3611
				self:sx(edge, w), -- 3611
				self:sy(footY + p.h * 0.62, h) -- 3611
			), -- 3611
			self:px(2), -- 3611
			STAND -- 3611
		) -- 3611
		draw:drawSegment( -- 3613
			Vec2( -- 3613
				self:sx(p.x - 8, w), -- 3613
				self:sy(footY + p.h + 3, h) -- 3613
			), -- 3613
			Vec2( -- 3613
				self:sx(p.x + 8, w), -- 3613
				self:sy(footY + p.h + 3, h) -- 3613
			), -- 3613
			self:px(2), -- 3613
			STAND -- 3613
		) -- 3613
	elseif self.coverNear and not isChild then -- 3613
		draw:drawRect( -- 3616
			Rect( -- 3616
				self:sx(p.x - 3, w), -- 3616
				self:sy(footY + 1, h), -- 3616
				self:px(3), -- 3616
				self:px(3) -- 3616
			), -- 3616
			STAND -- 3616
		) -- 3616
	end -- 3616
	drawFigure( -- 3618
		draw, -- 3618
		self, -- 3618
		w, -- 3618
		h, -- 3618
		p, -- 3618
		isChild and CHILD_BODY or SOLDIER_BODY, -- 3618
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 3618
	) -- 3618
	local q = self.partner -- 3619
	if q.alive then -- 3619
		local childPartner = q.w == CHILD_W -- 3621
		drawFigure( -- 3622
			draw, -- 3622
			self, -- 3622
			w, -- 3622
			h, -- 3622
			q, -- 3622
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 3622
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 3622
		) -- 3622
	end -- 3622
	local i = 0 -- 3624
	do -- 3624
		i = 0 -- 3625
		while i < #self.enemies do -- 3625
			local e = self.enemies[i + 1] -- 3626
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 3627
			local enemyY = e.y + (e.depth or 0) -- 3628
			self:drawBox( -- 3629
				draw, -- 3629
				w, -- 3629
				h, -- 3629
				e.x - e.w / 2, -- 3629
				e.x + e.w / 2, -- 3629
				enemyY, -- 3629
				enemyY + e.h, -- 3629
				col -- 3629
			) -- 3629
			if e.alive then -- 3629
				local ef = p.x >= e.x and 1 or -1 -- 3631
				if e.kind == "shield" then -- 3631
					local sh = (e.shieldHp or 0) > 0 -- 3633
					draw:drawRect( -- 3634
						Rect( -- 3634
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 3634
							self:sy(enemyY, h), -- 3634
							self:px(6), -- 3634
							self:px(64) -- 3634
						), -- 3634
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 3635
					) -- 3635
				elseif e.kind == "breaker" then -- 3635
					draw:drawSegment( -- 3637
						Vec2( -- 3637
							self:sx(e.x + ef * 12, w), -- 3637
							self:sy(enemyY + 8, h) -- 3637
						), -- 3637
						Vec2( -- 3638
							self:sx(e.x + ef * 22, w), -- 3638
							self:sy(enemyY + 46, h) -- 3638
						), -- 3638
						self:px(3), -- 3638
						Color(0.5, 0.36, 0.22, 1) -- 3638
					) -- 3638
				end -- 3638
			end -- 3638
			if e.alive and e.warnT > 0 then -- 3638
				local gunX = self:sx(e.x, w) -- 3643
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 3644
				local aimX = self:sx(p.x, w) -- 3645
				local aimY = self:sy(footY + p.h * 0.55, h) -- 3646
				local seg = 8 -- 3647
				local s = 0 -- 3648
				do -- 3648
					s = 0 -- 3649
					while s < seg do -- 3649
						local t0 = s / seg -- 3650
						local t1 = (s + 1) / seg -- 3651
						draw:drawSegment( -- 3652
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 3653
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 3654
							self:px(1), -- 3655
							DANGER -- 3655
						) -- 3655
						s = s + 2 -- 3649
					end -- 3649
				end -- 3649
			end -- 3649
			i = i + 1 -- 3625
		end -- 3625
	end -- 3625
	local k = 0 -- 3660
	do -- 3660
		k = 0 -- 3661
		while k < #self.room.marks do -- 3661
			do -- 3661
				local m = self.room.marks[k + 1] -- 3662
				if m.kind ~= 0 then -- 3662
					goto __continue721 -- 3664
				end -- 3664
				local on = self.checkpoint == m.x -- 3666
				local x = self:sx(m.x, w) -- 3667
				local y = self:sy(m.y, h) -- 3668
				draw:drawSegment( -- 3669
					Vec2(x, y), -- 3669
					Vec2( -- 3669
						x, -- 3669
						y + self:px(35) -- 3669
					), -- 3669
					self:px(1), -- 3669
					on and CHECK or INK_DIM -- 3669
				) -- 3669
				draw:drawDot( -- 3670
					Vec2( -- 3670
						x, -- 3670
						y + self:px(35) -- 3670
					), -- 3670
					self:px(2), -- 3670
					on and CHECK or INK_DIM -- 3670
				) -- 3670
			end -- 3670
			::__continue721:: -- 3670
			k = k + 1 -- 3661
		end -- 3661
	end -- 3661
	local j = 0 -- 3674
	do -- 3674
		j = 0 -- 3675
		while j < #self.room.marks do -- 3675
			do -- 3675
				local m = self.room.marks[j + 1] -- 3676
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 3676
					goto __continue724 -- 3678
				end -- 3678
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 3678
					goto __continue724 -- 3682
				end -- 3682
				local col = STAND -- 3684
				if m.kind == 4 then -- 3684
					col = PASS_LINE -- 3686
				elseif m.kind == 5 then -- 3686
					col = BRICK_LINE -- 3688
				end -- 3688
				local mx = self:sx(m.x, w) -- 3690
				local my = self:sy(m.y, h) -- 3691
				draw:drawSegment( -- 3692
					Vec2(mx, my), -- 3692
					Vec2( -- 3692
						mx, -- 3692
						my + self:px(24) -- 3692
					), -- 3692
					self:px(1), -- 3692
					col -- 3692
				) -- 3692
			end -- 3692
			::__continue724:: -- 3692
			j = j + 1 -- 3675
		end -- 3675
	end -- 3675
	local t = 0 -- 3695
	do -- 3695
		t = 0 -- 3696
		while t < #self.room.marks do -- 3696
			do -- 3696
				local m = self.room.marks[t + 1] -- 3697
				if m.kind ~= 6 then -- 3697
					goto __continue730 -- 3699
				end -- 3699
				local mx = self:sx(m.x, w) -- 3701
				local my = self:sy(m.y, h) -- 3702
				draw:drawSegment( -- 3703
					Vec2(mx, my), -- 3703
					Vec2( -- 3703
						mx, -- 3703
						my + self:px(30) -- 3703
					), -- 3703
					self:px(1), -- 3703
					INK_DIM -- 3703
				) -- 3703
				self:drawBox( -- 3704
					draw, -- 3704
					w, -- 3704
					h, -- 3704
					m.x - 5, -- 3704
					m.x + 5, -- 3704
					m.y + 30, -- 3704
					m.y + 40, -- 3704
					CHECK -- 3704
				) -- 3704
			end -- 3704
			::__continue730:: -- 3704
			t = t + 1 -- 3696
		end -- 3696
	end -- 3696
	if self.room.key == "village" then -- 3696
		self:drawVillage(draw, w, h) -- 3707
	end -- 3707
	if self.room.key == "forest" then -- 3707
		self:drawDog(draw, w, h) -- 3710
	end -- 3710
end -- 3604
function Play.prototype.drawDog(self, draw, w, h) -- 3715
	local x = self.dogX -- 3716
	self:drawBox( -- 3717
		draw, -- 3717
		w, -- 3717
		h, -- 3717
		x - 14, -- 3717
		x + 14, -- 3717
		0, -- 3717
		20, -- 3717
		SCAV_BODY -- 3717
	) -- 3717
	self:drawBox( -- 3718
		draw, -- 3718
		w, -- 3718
		h, -- 3718
		x - 10, -- 3718
		x - 2, -- 3718
		20, -- 3718
		30, -- 3718
		SCAV_BODY -- 3718
	) -- 3718
	self:drawBox( -- 3719
		draw, -- 3719
		w, -- 3719
		h, -- 3719
		x + 2, -- 3719
		x + 10, -- 3719
		20, -- 3719
		30, -- 3719
		SCAV_HEAD -- 3719
	) -- 3719
	if self.dogState == "ear" or self.dogState == "chase" then -- 3719
		draw:drawSegment( -- 3721
			Vec2( -- 3721
				self:sx(x, w), -- 3721
				self:sy(30, h) -- 3721
			), -- 3721
			Vec2( -- 3722
				self:sx(x, w), -- 3722
				self:sy(40, h) -- 3722
			), -- 3722
			self:px(1), -- 3722
			DANGER -- 3722
		) -- 3722
	end -- 3722
end -- 3715
function Play.prototype.drawVillage(self, draw, w, h) -- 3727
	local bottle = self.room.bottle -- 3728
	if bottle ~= nil then -- 3728
		self:drawBox( -- 3730
			draw, -- 3730
			w, -- 3730
			h, -- 3730
			bottle.x - 14, -- 3730
			bottle.x + 14, -- 3730
			0, -- 3730
			64, -- 3730
			SOLID_FILL -- 3730
		) -- 3730
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 3730
			self:drawBottle( -- 3732
				draw, -- 3732
				w, -- 3732
				h, -- 3732
				bottle.x, -- 3732
				64 -- 3732
			) -- 3732
		end -- 3732
	end -- 3732
	self:drawBox( -- 3736
		draw, -- 3736
		w, -- 3736
		h, -- 3736
		300, -- 3736
		420, -- 3736
		44, -- 3736
		50, -- 3736
		FLOOR_DECK -- 3736
	) -- 3736
	self:drawBox( -- 3737
		draw, -- 3737
		w, -- 3737
		h, -- 3737
		300, -- 3737
		306, -- 3737
		0, -- 3737
		44, -- 3737
		FLOOR_DECK -- 3737
	) -- 3737
	self:drawBox( -- 3738
		draw, -- 3738
		w, -- 3738
		h, -- 3738
		414, -- 3738
		420, -- 3738
		0, -- 3738
		44, -- 3738
		FLOOR_DECK -- 3738
	) -- 3738
	local s = self.room.scavenger -- 3740
	if s ~= nil then -- 3740
		local sx0 = self.scavX -- 3742
		self:drawBox( -- 3743
			draw, -- 3743
			w, -- 3743
			h, -- 3743
			sx0 - 12, -- 3743
			sx0 + 12, -- 3743
			0, -- 3743
			s.h - 14, -- 3743
			SCAV_BODY -- 3743
		) -- 3743
		self:drawBox( -- 3744
			draw, -- 3744
			w, -- 3744
			h, -- 3744
			sx0 - 7, -- 3744
			sx0 + 7, -- 3744
			s.h - 14, -- 3744
			s.h, -- 3744
			SCAV_HEAD -- 3744
		) -- 3744
		if self.scavState == "turn" then -- 3744
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 3746
			draw:drawSegment( -- 3747
				Vec2( -- 3747
					self:sx(sx0, w), -- 3747
					self:sy(s.h - 6, h) -- 3747
				), -- 3747
				Vec2( -- 3747
					self:sx(fx, w), -- 3747
					self:sy(s.h - 6, h) -- 3747
				), -- 3747
				self:px(1), -- 3747
				INK -- 3747
			) -- 3747
		end -- 3747
	end -- 3747
	if self.hasBottle then -- 3747
		local p = self.player -- 3752
		self:drawBottle( -- 3753
			draw, -- 3753
			w, -- 3753
			h, -- 3753
			p.x + p.facing * 10, -- 3753
			p.y + p.h * 0.62 -- 3753
		) -- 3753
	end -- 3753
	if self.bottleFly ~= nil then -- 3753
		self:drawBottle( -- 3756
			draw, -- 3756
			w, -- 3756
			h, -- 3756
			self.bottleFly.x, -- 3756
			self.bottleFly.y -- 3756
		) -- 3756
	end -- 3756
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 3756
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 3759
		draw:drawCircle( -- 3760
			Vec2( -- 3760
				self:sx(self.bottleLandX, w), -- 3760
				self:sy(0, h) -- 3760
			), -- 3760
			self:px(r / ____exports.UNITS_PER_PX), -- 3760
			BRICK_LINE -- 3760
		) -- 3760
	end -- 3760
end -- 3727
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 3764
	self:drawBox( -- 3765
		draw, -- 3765
		w, -- 3765
		h, -- 3765
		x - 3, -- 3765
		x + 3, -- 3765
		y - 10, -- 3765
		y, -- 3765
		BOTTLE -- 3765
	) -- 3765
end -- 3764
function Play.prototype.drawTrace(self, draw, w, h) -- 3768
	local t = self.trace -- 3769
	if t == nil or self.traceT <= 0 then -- 3769
		return -- 3771
	end -- 3771
	draw:drawSegment( -- 3773
		Vec2( -- 3774
			self:sx(t.x0, w), -- 3774
			self:sy(t.y0, h) -- 3774
		), -- 3774
		Vec2( -- 3775
			self:sx(t.x1, w), -- 3775
			self:sy(t.y1, h) -- 3775
		), -- 3775
		self:px(1), -- 3776
		t.hit and AIM_HIT or INK_DIM -- 3776
	) -- 3776
end -- 3768
function Play.prototype.drawAim(self, draw, w, h) -- 3779
	local v = self.view -- 3781
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 3782
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 3783
	local dot = self:px(1) -- 3784
	local arm = self:px(3) -- 3785
	local gap = self:px(1) -- 3786
	draw:drawSegment( -- 3787
		Vec2(gx - arm - gap, gy), -- 3787
		Vec2(gx - gap, gy), -- 3787
		dot / 2, -- 3787
		AIM -- 3787
	) -- 3787
	draw:drawSegment( -- 3788
		Vec2(gx + gap, gy), -- 3788
		Vec2(gx + arm + gap, gy), -- 3788
		dot / 2, -- 3788
		AIM -- 3788
	) -- 3788
	draw:drawSegment( -- 3789
		Vec2(gx, gy - arm - gap), -- 3789
		Vec2(gx, gy - gap), -- 3789
		dot / 2, -- 3789
		AIM -- 3789
	) -- 3789
	draw:drawSegment( -- 3790
		Vec2(gx, gy + gap), -- 3790
		Vec2(gx, gy + arm + gap), -- 3790
		dot / 2, -- 3790
		AIM -- 3790
	) -- 3790
	if self.room.key == "village" and self.hasBottle then -- 3790
		local p = self.player -- 3794
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3796
		local dir = ____end.x >= p.x and 1 or -1 -- 3797
		local x0 = p.x + dir * 10 -- 3798
		local y0 = p.y + p.h * 0.7 -- 3799
		local T = BOTTLE_FLY_TIME -- 3800
		local vx = (____end.x - x0) / T -- 3801
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 3802
		local pxr = x0 -- 3803
		local pyr = y0 -- 3804
		local t = 1 -- 3805
		do -- 3805
			t = 1 -- 3806
			while t <= 12 do -- 3806
				local tt = t / 12 * T -- 3807
				local nx = x0 + vx * tt -- 3808
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 3809
				draw:drawSegment( -- 3810
					Vec2( -- 3810
						self:sx(pxr, w), -- 3810
						self:sy(pyr, h) -- 3810
					), -- 3810
					Vec2( -- 3810
						self:sx(nx, w), -- 3810
						self:sy(ny, h) -- 3810
					), -- 3810
					self:px(1) / 2, -- 3810
					BOTTLE -- 3810
				) -- 3810
				pxr = nx -- 3811
				pyr = ny -- 3812
				t = t + 1 -- 3806
			end -- 3806
		end -- 3806
		draw:drawCircle( -- 3814
			Vec2( -- 3814
				self:sx(____end.x, w), -- 3814
				self:sy(____end.y + 2, h) -- 3814
			), -- 3814
			self:px(2), -- 3814
			BOTTLE -- 3814
		) -- 3814
	end -- 3814
end -- 3779
return ____exports -- 3779