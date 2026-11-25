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
function makeActor(room, index) -- 3818
	local sp = room.spawns -- 3819
	if index < 0 or index >= #sp then -- 3819
		return { -- 3821
			x = 0, -- 3821
			y = 0, -- 3821
			depth = 0, -- 3821
			depthSpeed = 0, -- 3821
			vx = 0, -- 3821
			vy = 0, -- 3821
			w = CHILD_W, -- 3821
			h = CHILD_H, -- 3821
			onGround = true, -- 3821
			facing = 1, -- 3821
			crouch = false, -- 3821
			rollT = 0, -- 3821
			covered = false, -- 3821
			alive = false -- 3821
		} -- 3821
	end -- 3821
	local s = sp[index + 1] -- 3823
	local child = s.h <= CHILD_H -- 3824
	local ground = room.depth -- 3825
	local depth = ground == nil and 0 or math.max( -- 3826
		ground.min, -- 3826
		math.min(ground.max, s.depth or 0) -- 3826
	) -- 3826
	return { -- 3827
		x = s.x, -- 3828
		y = s.y, -- 3828
		depth = depth, -- 3828
		depthSpeed = 0, -- 3828
		vx = 0, -- 3828
		vy = 0, -- 3828
		w = child and CHILD_W or SOLDIER_W, -- 3829
		h = child and CHILD_H or SOLDIER_H, -- 3830
		onGround = true, -- 3831
		facing = 1, -- 3831
		crouch = false, -- 3831
		rollT = 0, -- 3831
		covered = false, -- 3831
		alive = true -- 3831
	} -- 3831
end -- 3831
function drawFigure(draw, play, w, h, a, body, head) -- 3835
	if not a.alive then -- 3835
		return -- 3837
	end -- 3837
	local x0 = a.x - a.w / 2 -- 3839
	local x1 = a.x + a.w / 2 -- 3840
	local y0 = a.y + a.depth -- 3841
	local y1 = y0 + a.h -- 3842
	play:drawBox( -- 3843
		draw, -- 3843
		w, -- 3843
		h, -- 3843
		x0, -- 3843
		x1, -- 3843
		y0, -- 3843
		y1 - a.h * 0.26, -- 3843
		body -- 3843
	) -- 3843
	play:drawBox( -- 3844
		draw, -- 3844
		w, -- 3844
		h, -- 3844
		x0 + 2, -- 3844
		x1 - 2, -- 3844
		y1 - a.h * 0.26, -- 3844
		y1, -- 3844
		head -- 3844
	) -- 3844
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 3846
	play:drawBox( -- 3847
		draw, -- 3847
		w, -- 3847
		h, -- 3847
		eyeX, -- 3847
		eyeX + 4, -- 3847
		y1 - a.h * 0.14, -- 3847
		y1 - a.h * 0.08, -- 3847
		INK -- 3847
	) -- 3847
end -- 3847
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 3851
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 3852
end -- 3851
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 3859
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 3860
end -- 3859
function rayInterval(origin, direction, min, max) -- 3867
	if direction == 0 then -- 3867
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 3869
	end -- 3869
	local a = (min - origin) / direction -- 3871
	local b = (max - origin) / direction -- 3872
	return { -- 3873
		min = math.min(a, b), -- 3873
		max = math.max(a, b) -- 3873
	} -- 3873
end -- 3873
function hitBox(ray, box) -- 3877
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 3878
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 3879
	local enter = math.max(0, x.min, y.min) -- 3880
	local leave = math.min(99999, x.max, y.max) -- 3881
	if box.depth ~= nil then -- 3881
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 3883
		enter = math.max(enter, depth.min) -- 3884
		leave = math.min(leave, depth.max) -- 3885
	end -- 3885
	return leave >= enter and enter or -1 -- 3887
end -- 3887
function drawCartShape(draw, play, w, h, c, axleX) -- 3890
	local half = c.bodyW / 2 -- 3891
	local x0 = axleX - half -- 3892
	local x1 = axleX + half -- 3893
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 3894
	play:drawBox( -- 3895
		draw, -- 3895
		w, -- 3895
		h, -- 3895
		x0, -- 3895
		x1, -- 3895
		axleY, -- 3895
		axleY + c.bodyH, -- 3895
		CART_FILL -- 3895
	) -- 3895
	draw:drawCircle( -- 3896
		Vec2( -- 3896
			play:sx(x0 + c.bodyW * 0.28, w), -- 3896
			play:sy(axleY, h) -- 3896
		), -- 3896
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 3896
		Color(52, 50, 48, 255) -- 3896
	) -- 3896
	draw:drawCircle( -- 3897
		Vec2( -- 3897
			play:sx(x1 - c.bodyW * 0.28, w), -- 3897
			play:sy(axleY, h) -- 3897
		), -- 3897
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 3897
		Color(52, 50, 48, 255) -- 3897
	) -- 3897
	local cx = c.clothSide < 0 and x0 or x1 -- 3898
	play:drawBox( -- 3899
		draw, -- 3899
		w, -- 3899
		h, -- 3899
		cx - 10, -- 3899
		cx + 10, -- 3899
		axleY + c.bodyH, -- 3899
		axleY + c.bodyH + 18, -- 3899
		CLOTH -- 3899
	) -- 3899
end -- 3899
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
		a.x = a.x - a.facing * 16 -- 1851
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 1852
		self.partnerLaneHold = 1.1 -- 1853
		self.partnerStuck = 0 -- 1854
	end -- 1854
	if self.partnerLaneHold > 0 then -- 1854
		self.partnerLaneHold = self.partnerLaneHold - dt -- 1857
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 1858
	end -- 1858
	local dx = targetX - a.x -- 1860
	if not wait and math.abs(dx) > 74 then -- 1860
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 1862
		local before = a.x -- 1863
		a.vx = dx > 0 and speed or -speed -- 1864
		a.facing = dx > 0 and 1 or -1 -- 1865
		self:slideX(a, a.vx * dt) -- 1866
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 1866
			a.vy = CHILD_JUMP -- 1869
			a.onGround = false -- 1870
		end -- 1870
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 1872
	else -- 1872
		a.vx = 0 -- 1874
		self.partnerStuck = 0 -- 1875
	end -- 1875
	local dz = targetDepth - a.depth -- 1877
	if math.abs(dz) > 6 then -- 1877
		local step = math.max( -- 1879
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 1879
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 1879
		) -- 1879
		a.depth = a.depth + step -- 1880
	end -- 1880
	a.depthSpeed = 0 -- 1882
	a.h = CHILD_H -- 1883
	a.crouch = false -- 1884
	self:fallY(a, dt) -- 1885
end -- 1825
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 1889
	local p = self.player -- 1890
	local i = 0 -- 1891
	do -- 1891
		i = 0 -- 1892
		while i < #self.enemies do -- 1892
			do -- 1892
				local e = self.enemies[i + 1] -- 1893
				if not e.alive then -- 1893
					goto __continue311 -- 1895
				end -- 1895
				if e.hitT > 0 then -- 1895
					e.hitT = e.hitT - dt -- 1898
				end -- 1898
				if e.kind == "breaker" then -- 1898
					self:stepBreaker(e, dt) -- 1901
					goto __continue311 -- 1902
				end -- 1902
				if e.kind == "shield" then -- 1902
					self:stepShield(e, dt, input) -- 1905
					goto __continue311 -- 1906
				end -- 1906
				local dx = e.x - p.x -- 1909
				if not e.awake then -- 1909
					if math.abs(dx) > 520 then -- 1909
						goto __continue311 -- 1912
					end -- 1912
					e.awake = true -- 1914
					e.fireCd = 48 -- 1915
					goto __continue311 -- 1916
				end -- 1916
				if math.abs(dx) > ENEMY_RANGE then -- 1916
					goto __continue311 -- 1919
				end -- 1919
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 1919
					goto __continue311 -- 1924
				end -- 1924
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 1924
					goto __continue311 -- 1927
				end -- 1927
				if self:blockedShot(e, p) then -- 1927
					if e.warnT > 0 then -- 1927
						e.warnT = 0 -- 1933
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 1934
					end -- 1934
					goto __continue311 -- 1936
				end -- 1936
				if e.warnT > 0 then -- 1936
					e.warnT = e.warnT - 1 -- 1939
					if e.warnT <= 0 then -- 1939
						self:campaignEnemyFire(e) -- 1941
					end -- 1941
				elseif e.fireCd > 0 then -- 1941
					e.fireCd = e.fireCd - 1 -- 1944
					if e.fireCd <= 0 then -- 1944
						e.warnT = WARN_TICKS -- 1946
					end -- 1946
				else -- 1946
					e.fireCd = 40 -- 1949
				end -- 1949
			end -- 1949
			::__continue311:: -- 1949
			i = i + 1 -- 1892
		end -- 1892
	end -- 1892
end -- 1889
function Play.prototype.blockedShot(self, e, p) -- 1955
	local ex = e.x -- 1956
	local ey = e.y + (e.depth or 0) + e.h * 0.62 -- 1957
	local px = p.x -- 1958
	local py = p.y + p.depth + p.h * 0.55 -- 1959
	local dx = px - ex -- 1960
	local dy = py - ey -- 1961
	local len = math.sqrt(dx * dx + dy * dy) -- 1962
	if len < 0.01 then -- 1962
		return false -- 1964
	end -- 1964
	local ray = {x = ex, y = ey, dx = dx / len, dy = dy / len} -- 1966
	local best = -1 -- 1967
	local j = 0 -- 1968
	do -- 1968
		j = 0 -- 1969
		while j < #self.boxes do -- 1969
			do -- 1969
				local b = self.boxes[j + 1] -- 1970
				if b.broken == true or b.passable == true then -- 1970
					goto __continue331 -- 1972
				end -- 1972
				if b.id == "braced_shield" then -- 1972
					goto __continue331 -- 1977
				end -- 1977
				if not overlapsDepth(e.depth or 0, b.depth, ACTOR_DEPTH_HALF) then -- 1977
					goto __continue331 -- 1980
				end -- 1980
				local t = hitBox(ray, b) -- 1982
				if t >= 0 and t < len - 2 and (best < 0 or t < best) then -- 1982
					best = t -- 1984
				end -- 1984
			end -- 1984
			::__continue331:: -- 1984
			j = j + 1 -- 1969
		end -- 1969
	end -- 1969
	return best >= 0 -- 1987
end -- 1955
function Play.prototype.campaignEnemyFire(self, e) -- 1990
	local p = self.player -- 1991
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 1992
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 1992
		local ____self_bracedShield_34, ____hp_35 = self.bracedShield, "hp" -- 1992
		____self_bracedShield_34[____hp_35] = ____self_bracedShield_34[____hp_35] - 1 -- 1994
		self.boxes = __TS__ArrayFilter( -- 1995
			self.boxes, -- 1995
			function(____, b) return b.id ~= "braced_shield" end -- 1995
		) -- 1995
		self.bracedShield = nil -- 1996
		self:flashSet("残盾碎 · 挡下一发", 1) -- 1997
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 1998
		return -- 1999
	end -- 1999
	if self:blockedShot(e, p) then -- 1999
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 2002
		return -- 2003
	end -- 2003
	local cover = self:blockedByCover(e, p) -- 2005
	if cover ~= nil and self.coverHug then -- 2005
		self.coveredFlash = 0.5 -- 2007
		self:flashSet("掩体挡下", 0.6) -- 2008
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2009
		return -- 2014
	end -- 2014
	if self.invulnT > 0 then -- 2014
		return -- 2017
	end -- 2017
	self.invulnT = 0.7 -- 2019
	self.hp = self.hp - 1 -- 2020
	self:emit("actorHit", { -- 2021
		target = "player", -- 2021
		amount = 1, -- 2021
		hp = self.hp, -- 2021
		maxHp = self.maxHp, -- 2021
		enemyX = e.x -- 2021
	}) -- 2021
	self:flashSet( -- 2022
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2022
		0.8 -- 2022
	) -- 2022
	if self.hp <= 0 then -- 2022
		self:campaignFailed() -- 2024
	end -- 2024
end -- 1990
function Play.prototype.stepShield(self, e, dt, input) -- 2029
	local p = self.player -- 2030
	local dx = p.x - e.x -- 2031
	local adx = math.abs(dx) -- 2032
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 2035
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 2036
	if adx > 150 then -- 2036
		local before = e.x -- 2038
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 2039
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 2039
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2042
		end -- 2042
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 2042
		if p.rollT <= 0 and self.invulnT <= 0 then -- 2042
			self.invulnT = 0.7 -- 2046
			self.hp = self.hp - 1 -- 2047
			self:emit("actorHit", { -- 2048
				target = "player", -- 2048
				amount = 1, -- 2048
				hp = self.hp, -- 2048
				maxHp = self.maxHp, -- 2048
				enemyX = e.x -- 2048
			}) -- 2048
			self:flashSet( -- 2049
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2049
				0.8 -- 2049
			) -- 2049
			if self.hp <= 0 then -- 2049
				self:campaignFailed() -- 2051
				return -- 2052
			end -- 2052
		end -- 2052
		e.swingT = 70 -- 2055
	end -- 2055
	if (e.swingT or 0) > 0 then -- 2055
		e.swingT = (e.swingT or 0) - 1 -- 2058
	end -- 2058
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 2058
		local dd = p.depth - (e.depth or 0) -- 2061
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 2062
	end -- 2062
end -- 2029
function Play.prototype.stepBreaker(self, e, dt) -- 2067
	local p = self.player -- 2068
	if e.awake ~= true then -- 2068
		if math.abs(p.x - e.x) < 560 then -- 2068
			e.awake = true -- 2071
		else -- 2071
			return -- 2073
		end -- 2073
	end -- 2073
	local target = nil -- 2076
	local bestD = 1000000000 -- 2077
	local i = 0 -- 2078
	do -- 2078
		i = 0 -- 2079
		while i < #self.boxes do -- 2079
			do -- 2079
				local b = self.boxes[i + 1] -- 2080
				if b.breakable == nil or b.broken == true then -- 2080
					goto __continue356 -- 2082
				end -- 2082
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 2084
				if d < bestD then -- 2084
					bestD = d -- 2086
					target = b -- 2087
				end -- 2087
			end -- 2087
			::__continue356:: -- 2087
			i = i + 1 -- 2079
		end -- 2079
	end -- 2079
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 2090
	local dx = tx - e.x -- 2091
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 2092
	if math.abs(dx) > reach then -- 2092
		local before = e.x -- 2094
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 2095
		if math.abs(e.x - before) < 0.3 then -- 2095
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2097
		end -- 2097
	elseif (e.swingT or 0) <= 0 then -- 2097
		e.swingT = 64 -- 2100
		if target ~= nil then -- 2100
			self:damageProp(target, 2) -- 2102
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 2102
			self.invulnT = 0.7 -- 2104
			self.hp = self.hp - 1 -- 2105
			self:emit("actorHit", { -- 2106
				target = "player", -- 2106
				amount = 1, -- 2106
				hp = self.hp, -- 2106
				maxHp = self.maxHp, -- 2106
				enemyX = e.x -- 2106
			}) -- 2106
			self:flashSet("破障手近身", 0.8) -- 2107
			if self.hp <= 0 then -- 2107
				self:campaignFailed() -- 2109
				return -- 2110
			end -- 2110
		end -- 2110
	end -- 2110
	if (e.swingT or 0) > 0 then -- 2110
		e.swingT = (e.swingT or 0) - 1 -- 2115
	end -- 2115
end -- 2067
function Play.prototype.campaignFailed(self) -- 2119
	local p = self.player -- 2120
	self.hp = self.maxHp -- 2121
	self.invulnT = 1.2 -- 2122
	self.reloadT = 0 -- 2123
	self.gripping = false -- 2124
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 2125
	self:log("被击倒") -- 2126
	p.x = self.room.minX + 90 -- 2127
	p.y = 0 -- 2128
	p.depth = 0 -- 2129
	p.vx = 0 -- 2130
	p.vy = 0 -- 2131
	p.onGround = true -- 2132
	p.rollT = 0 -- 2133
	self.partner.x = p.x - 50 -- 2134
	self.partner.y = 0 -- 2135
	self.partner.depth = 0 -- 2136
	self.cam.x = p.x -- 2137
	local i = 0 -- 2138
	do -- 2138
		i = 0 -- 2139
		while i < #self.enemies do -- 2139
			do -- 2139
				local e = self.enemies[i + 1] -- 2140
				if not e.alive then -- 2140
					goto __continue368 -- 2142
				end -- 2142
				e.x = e.homeX == nil and e.x or e.homeX -- 2144
				e.warnT = 0 -- 2145
				e.fireCd = 40 -- 2146
				e.swingT = 0 -- 2147
				e.awake = false -- 2148
			end -- 2148
			::__continue368:: -- 2148
			i = i + 1 -- 2139
		end -- 2139
	end -- 2139
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 2150
end -- 2119
function Play.prototype.stepEnemies(self, dt, input) -- 2153
	local i = 0 -- 2154
	do -- 2154
		i = 0 -- 2155
		while i < #self.enemies do -- 2155
			local e = self.enemies[i + 1] -- 2156
			if e.hitT > 0 then -- 2156
				e.hitT = e.hitT - dt -- 2158
			end -- 2158
			i = i + 1 -- 2155
		end -- 2155
	end -- 2155
	if self.coveredFlash > 0 then -- 2155
		self.coveredFlash = self.coveredFlash - dt -- 2162
	end -- 2162
	if self.isCampaign then -- 2162
		self:stepCampaignEnemies(dt, input) -- 2165
		return -- 2166
	end -- 2166
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 2166
		return -- 2170
	end -- 2170
	do -- 2170
		i = 0 -- 2172
		while i < #self.enemies do -- 2172
			do -- 2172
				local e = self.enemies[i + 1] -- 2173
				if not e.alive then -- 2173
					goto __continue378 -- 2175
				end -- 2175
				if e.warnT > 0 then -- 2175
					e.warnT = e.warnT - 1 -- 2178
					if e.warnT <= 0 then -- 2178
						self:enemyFire(e, input) -- 2180
					end -- 2180
					goto __continue378 -- 2182
				end -- 2182
				if e.fireCd > 0 then -- 2182
					e.fireCd = e.fireCd - 1 -- 2185
					if e.fireCd <= 0 then -- 2185
						e.warnT = WARN_TICKS -- 2187
					end -- 2187
				else -- 2187
					e.warnT = WARN_TICKS -- 2191
				end -- 2191
			end -- 2191
			::__continue378:: -- 2191
			i = i + 1 -- 2172
		end -- 2172
	end -- 2172
end -- 2153
function Play.prototype.enemyFire(self, e, input) -- 2197
	local p = self.player -- 2198
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 2198
		self:flashSet("枪声响在远处", 0.4) -- 2200
		e.fireCd = FIRE_COOLDOWN -- 2201
		return -- 2202
	end -- 2202
	local cover = self:blockedByCover(e, p) -- 2205
	local hugging = cover ~= nil -- 2206
	self.coverBlocking = hugging -- 2207
	local covered = hugging and input.cover.held -- 2208
	if covered then -- 2208
		self.coveredFlash = 0.5 -- 2210
		self:flashSet("掩体挡下", 0.5) -- 2211
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2212
		e.fireCd = FIRE_COOLDOWN -- 2217
		return -- 2218
	end -- 2218
	self.hp = self.hp - 1 -- 2220
	self:emit("actorHit", { -- 2221
		target = "player", -- 2221
		amount = 1, -- 2221
		hp = self.hp, -- 2221
		maxHp = self.maxHp, -- 2221
		enemyX = e.x -- 2221
	}) -- 2221
	self:flashSet( -- 2222
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2222
		0.7 -- 2222
	) -- 2222
	e.fireCd = FIRE_COOLDOWN -- 2223
	if self.hp <= 0 then -- 2223
		self:gateFailed() -- 2225
	end -- 2225
end -- 2197
function Play.prototype.blockedByCover(self, enemy, p) -- 2230
	local b = self:coverAt(p) -- 2231
	if b == nil then -- 2231
		return nil -- 2233
	end -- 2233
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 2235
end -- 2230
function Play.prototype.gateFailed(self) -- 2239
	local ____temp_36 -- 2240
	if self.room.story == nil then -- 2240
		____temp_36 = nil -- 2240
	else -- 2240
		____temp_36 = self.room.story.gate -- 2240
	end -- 2240
	local g = ____temp_36 -- 2240
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 2241
	self.hp = self.maxHp -- 2242
	self.gateTick = 0 -- 2243
	self.gateSpawned = 0 -- 2244
	self.enemies = {} -- 2245
	self.gateFailCount = self.gateFailCount + 1 -- 2246
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 2248
	self.player.y = 0 -- 2249
	self.player.vy = 0 -- 2250
	self.player.depth = 0 -- 2251
	self.player.depthSpeed = 0 -- 2252
	self.player.onGround = true -- 2253
	self.player.crouch = false -- 2254
	self.player.h = SOLDIER_H -- 2255
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 2256
	self.partner.y = 0 -- 2257
	self.partner.vy = 0 -- 2258
	self.partner.depth = 0 -- 2259
	self.partner.depthSpeed = 0 -- 2260
	self.partner.onGround = true -- 2261
	self.cam.x = self.player.x -- 2262
	self.phase = "gate-idle" -- 2263
	self.phaseTick = 0 -- 2264
	self.coverHug = false -- 2265
	self.coverBlocking = false -- 2266
	self.coverEntity = "" -- 2267
	self.gateNeedConfirm = true -- 2268
	self.gateRestartArmed = false -- 2269
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 2270
end -- 2239
function Play.prototype.stepInteract(self, dt, input) -- 2273
	local p = self.player -- 2274
	local calmUsed = self.calmConsumed -- 2275
	self.calmConsumed = false -- 2276
	local calming = self.escort.state == "calming" -- 2278
	self.focusCart = false -- 2279
	if self.room.key == "outside" then -- 2279
		local c = self.room.cart -- 2281
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 2282
		local dy = p.y - c.baseY -- 2283
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 2284
	end -- 2284
	if not calmUsed and not calming then -- 2284
		self:stepCart(dt, input) -- 2288
	end -- 2288
	if calmUsed then -- 2288
		self:flashSet("安抚 · 敲两下", 0.8) -- 2293
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 2293
		if self.knockT > 0 then -- 2293
			self.knocks = self.knocks + 1 -- 2297
		else -- 2297
			self.knocks = 1 -- 2299
		end -- 2299
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 2301
		self.knockT = 1.2 -- 2302
		if self.knocks >= 2 then -- 2302
			self:flashSet("敲两下", 0.8) -- 2304
			self.knocks = 0 -- 2305
		else -- 2305
			self:flashSet("敲一下", 0.5) -- 2307
		end -- 2307
	elseif self.knockT > 0 then -- 2307
		self.knockT = self.knockT - dt -- 2310
		if self.knockT <= 0 then -- 2310
			self.knocks = 0 -- 2312
		end -- 2312
	end -- 2312
	local i = 0 -- 2317
	do -- 2317
		i = 0 -- 2318
		while i < #self.room.marks do -- 2318
			do -- 2318
				local m = self.room.marks[i + 1] -- 2319
				if m.kind ~= 0 then -- 2319
					goto __continue404 -- 2321
				end -- 2321
				local subjects = {self.partner, self.player} -- 2323
				local k = 0 -- 2324
				do -- 2324
					k = 0 -- 2325
					while k < #subjects do -- 2325
						do -- 2325
							local s = subjects[k + 1] -- 2326
							if not s.alive then -- 2326
								goto __continue407 -- 2328
							end -- 2328
							local dx = s.x - m.x -- 2330
							local dy = s.y - m.y -- 2331
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2331
								self.checkpoint = m.x -- 2333
								self.checkpointCartAxle = self.cartAxle -- 2334
								if self.cartDocked then -- 2334
									self:flashSet("检查点 · 车已落窝", 1) -- 2336
								else -- 2336
									self:flashSet("检查点 · 车还没到位", 1) -- 2338
								end -- 2338
							end -- 2338
						end -- 2338
						::__continue407:: -- 2338
						k = k + 1 -- 2325
					end -- 2325
				end -- 2325
			end -- 2325
			::__continue404:: -- 2325
			i = i + 1 -- 2318
		end -- 2318
	end -- 2318
	self:checkCarryGate() -- 2344
end -- 2273
function Play.prototype.stepVillage(self, dt, input) -- 2348
	if self.room.key ~= "village" then -- 2348
		return -- 2350
	end -- 2350
	local p = self.player -- 2352
	local bottle = self.room.bottle -- 2353
	local scav = self.room.scavenger -- 2354
	if not self.hasBottle and bottle ~= nil then -- 2354
		local dx = p.x - bottle.x -- 2358
		local dy = p.y + p.h * 0.5 - bottle.y -- 2359
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 2359
			self.hasBottle = true -- 2361
			self:flashSet("拾起瓶子", 0.8) -- 2362
		end -- 2362
	end -- 2362
	if self.hasBottle then -- 2362
		if input.aim.held then -- 2362
			self.aimHold = self.aimHold + dt -- 2369
			if self.aimHold > 1.2 then -- 2369
				self.aimHold = 1.2 -- 2371
			end -- 2371
			local cached = self:bottleEnd() -- 2374
			self.bottleAimX = cached.x -- 2375
			self.bottleAimY = cached.y -- 2376
		elseif input.aim.released then -- 2376
			if self.aimHold < 0.12 then -- 2376
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 2380
				self.aimHold = 0 -- 2381
			else -- 2381
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2383
				self:throwBottle(____end.x, ____end.y) -- 2384
				self.aimHold = 0 -- 2385
			end -- 2385
		end -- 2385
	else -- 2385
		self.aimHold = 0 -- 2389
		self.bottleAimX = -1 -- 2390
	end -- 2390
	local fly = self.bottleFly -- 2395
	if fly ~= nil then -- 2395
		fly.t = fly.t + dt -- 2397
		fly.x = fly.x0 + fly.vx * fly.t -- 2398
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 2399
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 2400
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 2400
			self:landBottle(fly) -- 2402
		end -- 2402
	end -- 2402
	if self.bottleLandT > 0 then -- 2402
		self.bottleLandT = self.bottleLandT - dt -- 2406
	end -- 2406
	if scav ~= nil then -- 2406
		self:stepScav(dt, scav) -- 2410
	end -- 2410
	local line = self.room.passLine -- 2413
	if line ~= nil and not self.passed and p.x >= line then -- 2413
		self.passed = true -- 2415
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 2416
	end -- 2416
	if self.passed and p.x >= self.ox + 640 then -- 2416
		self:requestRoom("forest", "过第一院出院") -- 2420
		self:flashSet("出院 · 北塔森林", 1.4) -- 2421
	end -- 2421
end -- 2348
function Play.prototype.bottleEnd(self) -- 2426
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2427
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 2430
	return {x = aim.x, y = g} -- 2431
end -- 2426
function Play.prototype.throwBottle(self, tx, ty) -- 2435
	local p = self.player -- 2436
	local dir = tx >= p.x and 1 or -1 -- 2438
	p.facing = dir -- 2439
	local x0 = p.x + dir * 10 -- 2440
	local y0 = p.y + p.h * 0.7 -- 2441
	self.bottleTargetX = tx -- 2442
	self.bottleTargetY = ty -- 2443
	self.bottleSurfaceY = ty -- 2444
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 2445
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 2446
	self.bottleFly = { -- 2447
		x = x0, -- 2447
		y = y0, -- 2447
		x0 = x0, -- 2447
		y0 = y0, -- 2447
		vx = vx, -- 2447
		vy = vy, -- 2447
		t = 0 -- 2447
	} -- 2447
	self.hasBottle = false -- 2448
	self:flashSet("投出", 0.4) -- 2449
	self:emit( -- 2450
		"bottleThrown", -- 2450
		{ -- 2450
			fromX = x0, -- 2451
			fromY = y0, -- 2452
			targetX = tx, -- 2453
			targetY = ty, -- 2454
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 2455
		} -- 2455
	) -- 2455
end -- 2435
function Play.prototype.landBottle(self, fly) -- 2460
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 2461
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 2462
	local s = self.room.scavenger -- 2463
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 2464
	self.bottleFly = nil -- 2465
	self.bottleTargetX = -1 -- 2466
	self.bottleTargetY = 0 -- 2467
	self.bottleSurfaceY = -1 -- 2468
	self.bottleLandX = x -- 2469
	self.bottleLandY = y -- 2470
	self.bottleLandT = 0.9 -- 2471
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 2472
	self:hearBottle(x) -- 2473
end -- 2460
function Play.prototype.hearBottle(self, x) -- 2477
	local s = self.room.scavenger -- 2478
	if s == nil then -- 2478
		return -- 2480
	end -- 2480
	if math.abs(x - self.scavX) > s.range then -- 2480
		self:flashSet("落地 · 他没听见", 0.6) -- 2483
		return -- 2484
	end -- 2484
	self.scavState = "turn" -- 2486
	self.scavT = s.hearTicks -- 2487
	self.scavTargetX = x -- 2488
	self:flashSet("砖地一响 · 他转头", 0.9) -- 2489
end -- 2477
function Play.prototype.stepScav(self, dt, s) -- 2493
	if self.scavState == "chase" then -- 2493
		return -- 2496
	end -- 2496
	if self.scavState == "turn" then -- 2496
		self.scavT = self.scavT - 1 -- 2499
		if self.scavT <= 0 then -- 2499
			self.scavState = "walk" -- 2501
		end -- 2501
		return -- 2503
	end -- 2503
	if self.scavState == "walk" then -- 2503
		local d = self.scavTargetX - self.scavX -- 2506
		if math.abs(d) < 4 then -- 2506
			self.scavState = "stall" -- 2508
			self.scavT = s.stallTicks -- 2509
			return -- 2510
		end -- 2510
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 2512
		return -- 2513
	end -- 2513
	if self.scavState == "stall" then -- 2513
		self.scavT = self.scavT - 1 -- 2516
		if self.scavT <= 0 then -- 2516
			self.scavState = "back" -- 2518
		end -- 2518
		return -- 2520
	end -- 2520
	if self.scavState == "back" then -- 2520
		local home = math.max( -- 2523
			s.x0, -- 2523
			math.min(s.x1, self.scavX) -- 2523
		) -- 2523
		if math.abs(home - self.scavX) < 2 then -- 2523
			self.scavState = "patrol" -- 2525
			return -- 2526
		end -- 2526
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 2528
		return -- 2529
	end -- 2529
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 2531
	if self.scavX >= s.x1 then -- 2531
		self.scavX = s.x1 -- 2533
		self.scavDir = -1 -- 2534
	elseif self.scavX <= s.x0 then -- 2534
		self.scavX = s.x0 -- 2536
		self.scavDir = 1 -- 2537
	end -- 2537
end -- 2493
function Play.prototype.stepCart(self, dt, input) -- 2545
	local p = self.player -- 2546
	local c = self.room.cart -- 2547
	if self.gripping then -- 2547
		if not input.interact.held then -- 2547
			self.gripping = false -- 2551
			self:flashSet("松开车把", 0.4) -- 2552
			return -- 2553
		end -- 2553
	else -- 2553
		if not input.interact.pressed then -- 2553
			return -- 2557
		end -- 2557
		if not self:cartHandleInReach(p) then -- 2557
			return -- 2560
		end -- 2560
		local track = c.depth or 0 -- 2562
		if self:limitDepth(p, track) ~= track then -- 2562
			return -- 2564
		end -- 2564
		p.depth = track -- 2566
		p.depthSpeed = 0 -- 2567
		self.gripping = true -- 2568
		self:flashSet("握住车把", 0.4) -- 2569
		return -- 2570
	end -- 2570
	if self.cartDocked then -- 2570
		return -- 2574
	end -- 2574
	local dir = input.moveX -- 2576
	if dir == 0 then -- 2576
		return -- 2578
	end -- 2578
	local lo = math.min(c.startX, c.endX) -- 2580
	local hi = math.max(c.startX, c.endX) -- 2581
	local next = self.cartAxle + dir * CART_SPEED * dt -- 2582
	if next < lo then -- 2582
		next = lo -- 2584
	end -- 2584
	if next > hi then -- 2584
		next = hi -- 2587
	end -- 2587
	local delta = next - self.cartAxle -- 2589
	if delta == 0 then -- 2589
		return -- 2591
	end -- 2591
	self.cartAxle = next -- 2593
	p.x = p.x + delta -- 2594
	p.facing = dir > 0 and 1 or -1 -- 2595
	self:slideX(p, 0) -- 2596
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 2596
		self.gripping = false -- 2598
		self:flashSet("跟不上了，脱手", 0.6) -- 2599
		return -- 2600
	end -- 2600
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 2600
		self.cartDocked = true -- 2603
		self.gripping = false -- 2604
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 2605
		self:flashSet("车轮落窝", 1.2) -- 2606
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 2606
		self:flashSet("车轮回到起点", 0.5) -- 2608
	end -- 2608
end -- 2545
function Play.prototype.requestRoom(self, key, reason) -- 2616
	if self.wantRoom ~= "" then -- 2616
		return -- 2620
	end -- 2620
	self.wantRoom = key -- 2622
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 2623
end -- 2616
function Play.prototype.checkCarryGate(self) -- 2630
	if self.room.key == "checkpoint" then -- 2630
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 2630
			self.carryCartAxle = self.cartAxle -- 2633
			self.carryCartDocked = self.cartDocked -- 2634
			self:requestRoom("gate", "检查站出口") -- 2635
			self:flashSet("出检查站 · 城门", 1.2) -- 2636
		end -- 2636
		return -- 2638
	end -- 2638
	if self.room.key == "outside" then -- 2638
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 2638
			self.carryCartAxle = self.cartAxle -- 2644
			self.carryCartDocked = self.cartDocked -- 2645
			self:requestRoom("village", "墙根走完") -- 2646
			self:flashSet("墙根走完 · 进村口", 1.2) -- 2647
		end -- 2647
	end -- 2647
end -- 2630
function Play.prototype.aimAt(self, wx, wy) -- 2654
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 2655
	self.aimX = s.x -- 2656
	self.aimY = s.y -- 2657
end -- 2654
function Play.prototype.shoot(self, a) -- 2660
	if self.isCampaign and self.reloadT > 0 then -- 2660
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 2662
		return -- 2663
	end -- 2663
	local ox = a.x + a.facing * 8 -- 2665
	local muzzleY = a.y + a.h * 0.72 -- 2666
	local oy = muzzleY + a.depth -- 2667
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2669
	local dx = aim.x - ox -- 2672
	local dy = aim.y - oy -- 2673
	local len = math.sqrt(dx * dx + dy * dy) -- 2674
	if len < 0.001 then -- 2674
		dx = a.facing -- 2676
		dy = 0 -- 2677
	else -- 2677
		dx = dx / len -- 2679
		dy = dy / len -- 2680
	end -- 2680
	if dx ~= 0 then -- 2680
		a.facing = dx > 0 and 1 or -1 -- 2683
	end -- 2683
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 2686
	local hitEnemy = self:raycastEnemies(ray) -- 2687
	local tEnemy = hitEnemy.t -- 2688
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 2689
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 2690
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 2691
	local tWall = solid.t -- 2692
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 2693
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 2694
	self.trace = { -- 2696
		x0 = ox, -- 2696
		y0 = oy, -- 2696
		x1 = ox + dx * t, -- 2696
		y1 = oy + dy * t, -- 2696
		hit = hit -- 2696
	} -- 2696
	self.traceT = 0.12 -- 2697
	self:applyFireDanger(ox) -- 2698
	local killed = false -- 2699
	if hit then -- 2699
		local i = hitEnemy.index -- 2701
		local e = self.enemies[i + 1] -- 2702
		local impactY = oy + dy * tEnemy -- 2703
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 2704
		local shieldTop = e.y + (e.depth or 0) + 64 -- 2705
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 2705
			e.shieldHp = (e.shieldHp or 0) - 1 -- 2707
			e.hitT = 0.3 -- 2708
			self:flashSet( -- 2709
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 2709
				0.8 -- 2709
			) -- 2709
			self:emit("shotResolved", { -- 2710
				hit = true, -- 2711
				enemyIndex = i, -- 2711
				enemyX = e.x, -- 2711
				aimX = aim.x, -- 2711
				aimY = aim.y, -- 2711
				impactX = ox + dx * t, -- 2712
				impactY = oy + dy * t, -- 2712
				shield = true -- 2712
			}) -- 2712
			self.reloadT = self.run.inventory.quickbelt > 0 and 36 or 54 -- 2714
			return -- 2715
		end -- 2715
		e.alive = false -- 2717
		e.hitT = 0.4 -- 2718
		killed = true -- 2719
		self:flashSet("命中", 0.6) -- 2720
		self:dropFor(e) -- 2721
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 2721
		self:damageProp(solid.box, 1) -- 2723
	else -- 2723
		self:flashSet("打空", 0.35) -- 2725
	end -- 2725
	if self.isCampaign then -- 2725
		self.reloadT = self.run.inventory.quickbelt > 0 and 36 or 54 -- 2728
	end -- 2728
	self:emit("shotResolved", { -- 2730
		hit = hit, -- 2731
		enemyIndex = hit and hitEnemy.index or -1, -- 2732
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 2733
		aimX = aim.x, -- 2734
		aimY = aim.y, -- 2735
		impactX = ox + dx * t, -- 2736
		impactY = oy + dy * t -- 2737
	}) -- 2737
end -- 2660
function Play.prototype.applyFireDanger(self, shotX) -- 2742
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 2742
		return -- 2744
	end -- 2744
	local dangerX = shotX -- 2746
	local best = -1 -- 2747
	local bestD = 1000000000 -- 2748
	local i = 0 -- 2749
	do -- 2749
		i = 0 -- 2750
		while i < #self.enemies do -- 2750
			do -- 2750
				local e = self.enemies[i + 1] -- 2751
				if not e.alive then -- 2751
					goto __continue483 -- 2753
				end -- 2753
				local d = math.abs(e.x - self.partner.x) -- 2755
				if d < bestD then -- 2755
					bestD = d -- 2757
					best = i -- 2758
				end -- 2758
			end -- 2758
			::__continue483:: -- 2758
			i = i + 1 -- 2750
		end -- 2750
	end -- 2750
	if best >= 0 then -- 2750
		dangerX = self.enemies[best + 1].x -- 2762
	end -- 2762
	local exposed = self:childExposed(dangerX) -- 2764
	local before = self.escort.fear -- 2765
	local dangerId = self.nextDangerId -- 2766
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 2767
	self.nextDangerId = self.nextDangerId + 1 -- 2768
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 2769
	if after > before then -- 2769
		self:flashSet( -- 2771
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 2771
			1 -- 2771
		) -- 2771
	elseif not exposed then -- 2771
		self:flashSet("枪声没够到她", 0.5) -- 2773
	end -- 2773
end -- 2742
function Play.prototype.childExposed(self, dangerX) -- 2778
	local c = self.partner -- 2779
	if not c.alive then -- 2779
		return false -- 2781
	end -- 2781
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 2781
		self.boxes, -- 2784
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 2784
	) then -- 2784
		return false -- 2785
	end -- 2785
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 2785
		return false -- 2788
	end -- 2788
	local toDanger = dangerX - c.x -- 2790
	local toPlayer = self.player.x - c.x -- 2791
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 2791
		return false -- 2794
	end -- 2794
	return true -- 2796
end -- 2778
function Play.prototype.raycastEnemies(self, ray) -- 2800
	local best = -1 -- 2801
	local bestI = -1 -- 2802
	do -- 2802
		local i = 0 -- 2803
		while i < #self.enemies do -- 2803
			do -- 2803
				local e = self.enemies[i + 1] -- 2804
				if not e.alive then -- 2804
					goto __continue497 -- 2806
				end -- 2806
				local y = e.y + (e.depth or 0) -- 2808
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 2809
				if t >= 0 and (best < 0 or t < best) then -- 2809
					best = t -- 2811
					bestI = i -- 2812
				end -- 2812
			end -- 2812
			::__continue497:: -- 2812
			i = i + 1 -- 2803
		end -- 2803
	end -- 2803
	return {t = best, index = bestI} -- 2815
end -- 2800
function Play.prototype.raycastWorld(self, ray) -- 2818
	return self:raycastSolid(ray).t -- 2819
end -- 2818
function Play.prototype.raycastSolid(self, ray) -- 2823
	local best = -1 -- 2824
	local bestBox = nil -- 2825
	for ____, box in ipairs(self.boxes) do -- 2826
		do -- 2826
			if box.broken == true or box.hidden == true then -- 2826
				goto __continue502 -- 2828
			end -- 2828
			if ray.depth ~= nil and not overlapsDepth(ray.depth, box.depth, ACTOR_DEPTH_HALF) then -- 2828
				goto __continue502 -- 2832
			end -- 2832
			local t = hitBox(ray, box) -- 2834
			if t >= 0 and (best < 0 or t < best) then -- 2834
				best = t -- 2836
				bestBox = box -- 2837
			end -- 2837
		end -- 2837
		::__continue502:: -- 2837
	end -- 2837
	if ray.dy < 0 then -- 2837
		local t = -ray.y / ray.dy -- 2841
		if t >= 0 and (best < 0 or t < best) then -- 2841
			best = t -- 2843
			bestBox = nil -- 2844
		end -- 2844
	end -- 2844
	return {t = best, box = bestBox} -- 2847
end -- 2823
function Play.prototype.dropFor(self, e) -- 2851
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 2851
		return -- 2853
	end -- 2853
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 2853
		return -- 2856
	end -- 2856
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 2858
	local ____self_pickups_37 = self.pickups -- 2858
	____self_pickups_37[#____self_pickups_37 + 1] = { -- 2859
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 2860
		kind = e.drop, -- 2860
		x = e.x, -- 2860
		y = e.y, -- 2860
		depth = e.depth, -- 2861
		label = label .. " ×1" -- 2861
	} -- 2861
	self:log("掉落 " .. label) -- 2863
end -- 2851
function Play.prototype.damageProp(self, b, amount) -- 2867
	if b.breakable == nil or b.broken == true then -- 2867
		return -- 2869
	end -- 2869
	local ____b_breakable_38, ____hp_39 = b.breakable, "hp" -- 2869
	____b_breakable_38[____hp_39] = ____b_breakable_38[____hp_39] - amount -- 2871
	if b.breakable.hp > 0 then -- 2871
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 2873
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 2874
		return -- 2875
	end -- 2875
	b.broken = true -- 2877
	for ____, other in ipairs(self.boxes) do -- 2878
		if other.id ~= nil and other.id == b.id then -- 2878
			other.broken = true -- 2880
		end -- 2880
	end -- 2880
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 2883
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 2884
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 2885
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 2886
end -- 2867
function Play.prototype.slideDepth(self, a, distance) -- 2890
	a.depth = self:limitDepth(a, a.depth + distance) -- 2891
end -- 2890
function Play.prototype.limitDepth(self, a, target) -- 2894
	local road = self.room.depth -- 2895
	if road == nil or target == a.depth then -- 2895
		return a.depth -- 2897
	end -- 2897
	local next = math.max( -- 2899
		road.min, -- 2899
		math.min(road.max, target) -- 2899
	) -- 2899
	local half = a.w / 2 -- 2900
	for ____, b in ipairs(self.boxes) do -- 2901
		do -- 2901
			local footprint = b.depth -- 2902
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 2902
				goto __continue521 -- 2907
			end -- 2907
			local front = footprint.min - ACTOR_DEPTH_HALF -- 2909
			local back = footprint.max + ACTOR_DEPTH_HALF -- 2910
			if a.depth <= front and next > front then -- 2910
				next = front -- 2912
			elseif a.depth >= back and next < back then -- 2912
				next = back -- 2914
			end -- 2914
		end -- 2914
		::__continue521:: -- 2914
	end -- 2914
	return next -- 2917
end -- 2894
function Play.prototype.slideX(self, a, dx) -- 2921
	local nx = a.x + dx -- 2922
	local half = a.w / 2 -- 2923
	local room = self.room -- 2924
	nx = math.max( -- 2925
		room.minX + half, -- 2925
		math.min(room.maxX - half, nx) -- 2925
	) -- 2925
	local i = 0 -- 2926
	do -- 2926
		i = 0 -- 2927
		while i < #self.boxes do -- 2927
			do -- 2927
				local b = self.boxes[i + 1] -- 2928
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 2928
					goto __continue528 -- 2930
				end -- 2930
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2930
					goto __continue528 -- 2933
				end -- 2933
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 2933
					goto __continue528 -- 2936
				end -- 2936
				if nx + half > b.x0 and nx - half < b.x1 then -- 2936
					if a.x <= b.x0 then -- 2936
						nx = b.x0 - half -- 2940
					elseif a.x >= b.x1 then -- 2940
						nx = b.x1 + half -- 2942
					else -- 2942
						nx = a.x -- 2944
					end -- 2944
				end -- 2944
			end -- 2944
			::__continue528:: -- 2944
			i = i + 1 -- 2927
		end -- 2927
	end -- 2927
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 2927
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 2952
		local bx0 = self.cartAxle - CART_HALF -- 2953
		local bx1 = self.cartAxle + CART_HALF -- 2954
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 2954
			if a.x <= bx0 then -- 2954
				nx = bx0 - half -- 2957
			elseif a.x >= bx1 then -- 2957
				nx = bx1 + half -- 2959
			else -- 2959
				nx = a.x -- 2961
			end -- 2961
		end -- 2961
	end -- 2961
	local arch = room.arch -- 2969
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 2969
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 2971
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 2971
			if a.x <= arch.x0 then -- 2971
				nx = arch.x0 - half -- 2974
			elseif a.x >= arch.x1 then -- 2974
				nx = arch.x1 + half -- 2976
			end -- 2976
		end -- 2976
	end -- 2976
	a.x = nx -- 2980
end -- 2921
function Play.prototype.fallY(self, a, dt) -- 2984
	a.vy = a.vy - ____exports.GRAVITY * dt -- 2985
	if a.vy < -900 then -- 2985
		a.vy = -900 -- 2987
	end -- 2987
	local ny = a.y + a.vy * dt -- 2989
	local half = a.w / 2 -- 2990
	if a.vy <= 0 then -- 2990
		local reach = a.onGround and STEP_UP or 0 -- 2993
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 2994
		if ny <= ground then -- 2994
			ny = ground -- 2996
			a.vy = 0 -- 2997
			a.onGround = true -- 2998
		else -- 2998
			a.onGround = false -- 3000
		end -- 3000
	else -- 3000
		a.onGround = false -- 3003
		local i = 0 -- 3004
		do -- 3004
			i = 0 -- 3005
			while i < #self.boxes do -- 3005
				do -- 3005
					local b = self.boxes[i + 1] -- 3006
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3006
						goto __continue552 -- 3008
					end -- 3008
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3008
						goto __continue552 -- 3011
					end -- 3011
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 3011
						goto __continue552 -- 3014
					end -- 3014
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 3014
						ny = b.y0 - a.h -- 3017
						a.vy = 0 -- 3018
					end -- 3018
				end -- 3018
				::__continue552:: -- 3018
				i = i + 1 -- 3005
			end -- 3005
		end -- 3005
	end -- 3005
	a.y = ny -- 3022
end -- 2984
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 3026
	if depth == nil then -- 3026
		depth = 0 -- 3026
	end -- 3026
	local g = -9999 -- 3027
	local i = 0 -- 3028
	do -- 3028
		i = 0 -- 3029
		while i < #self.floors do -- 3029
			local f = self.floors[i + 1] -- 3030
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 3030
				g = f.y1 -- 3032
			end -- 3032
			i = i + 1 -- 3029
		end -- 3029
	end -- 3029
	do -- 3029
		i = 0 -- 3035
		while i < #self.boxes do -- 3035
			do -- 3035
				local b = self.boxes[i + 1] -- 3036
				if b.broken == true or b.hidden == true or b.soft == true then -- 3036
					goto __continue562 -- 3038
				end -- 3038
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 3038
					g = b.y1 -- 3042
				end -- 3042
			end -- 3042
			::__continue562:: -- 3042
			i = i + 1 -- 3035
		end -- 3035
	end -- 3035
	return g -- 3045
end -- 3026
function Play.prototype.updateCamera(self, dt) -- 3048
	local p = self.player -- 3049
	local tx = p.x + p.facing * 30 -- 3050
	local ty = p.y + CAM_LOOK_UP -- 3051
	local k = math.min(1, CAM_FOLLOW * dt) -- 3052
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 3053
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 3054
end -- 3048
function Play.prototype.clampCamera(self, w, h) -- 3058
	local room = self.room -- 3059
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 3060
	local spanX = room.maxX - room.minX -- 3061
	if spanX <= halfW * 2 then -- 3061
		self.cam.x = (room.minX + room.maxX) / 2 -- 3063
	else -- 3063
		self.cam.x = math.max( -- 3065
			room.minX + halfW, -- 3065
			math.min(room.maxX - halfW, self.cam.x) -- 3065
		) -- 3065
	end -- 3065
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 3068
	local spanY = room.height -- 3069
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 3070
	if spanY <= halfH * 2 then -- 3070
		self.cam.y = camY -- 3072
	else -- 3072
		self.cam.y = math.max( -- 3074
			camY, -- 3074
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 3074
		) -- 3074
	end -- 3074
end -- 3058
function Play.prototype.flashSet(self, text, t) -- 3078
	self.flash = text -- 3079
	self.flashT = t -- 3080
end -- 3078
function Play.prototype.statusText(self) -- 3084
	local p = self.player -- 3085
	local parts = {} -- 3086
	local who = self.childMode and "小满" or "周戍" -- 3087
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 3088
	if self.room.key == "prologue" then -- 3088
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3091
		if self.phase == "prologue-wait" then -- 3091
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 3093
		elseif self.phase == "prologue-give" then -- 3093
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 3095
		else -- 3095
			parts[#parts + 1] = "跟随" -- 3097
		end -- 3097
		if self.paused then -- 3097
			parts[#parts + 1] = "已暂停" -- 3100
		end -- 3100
		return table.concat(parts, " · ") -- 3102
	end -- 3102
	if self.room.key == "street" then -- 3102
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3105
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3106
		if self.paused then -- 3106
			parts[#parts + 1] = "已暂停" -- 3108
		end -- 3108
		return table.concat(parts, " · ") -- 3110
	end -- 3110
	if self.room.key == "gate" then -- 3110
		local ____temp_40 -- 3113
		if self.room.story == nil then -- 3113
			____temp_40 = nil -- 3113
		else -- 3113
			____temp_40 = self.room.story.gate -- 3113
		end -- 3113
		local g = ____temp_40 -- 3113
		if g ~= nil then -- 3113
			parts[#parts + 1] = self:gateLabel() -- 3115
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 3116
				0, -- 3117
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 3117
			))) .. " 秒" -- 3117
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3118
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3119
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 3120
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 3121
			if self.gateFailCount > 0 then -- 3121
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 3123
			end -- 3123
			if self.flash ~= "" then -- 3123
				parts[#parts + 1] = self.flash -- 3126
			end -- 3126
		end -- 3126
		if self.paused then -- 3126
			parts[#parts + 1] = "已暂停" -- 3130
		end -- 3130
		return table.concat(parts, " · ") -- 3132
	end -- 3132
	if self.room.key == "forest" then -- 3132
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3135
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 3136
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 3137
		if self.caughtT > 0 then -- 3137
			parts[#parts + 1] = "复位中" -- 3139
		end -- 3139
		if self.paused then -- 3139
			parts[#parts + 1] = "已暂停" -- 3142
		end -- 3142
		return table.concat(parts, " · ") -- 3144
	end -- 3144
	if self.room.key == "tower" then -- 3144
		if self.phase == "tower-wait" then -- 3144
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 3148
		elseif self.phase == "tower-knock" then -- 3148
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 3150
		elseif self.phase == "tower-given" then -- 3150
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 3152
		else -- 3152
			parts[#parts + 1] = "片尾" -- 3154
		end -- 3154
		if self.paused then -- 3154
			parts[#parts + 1] = "已暂停" -- 3157
		end -- 3157
		return table.concat(parts, " · ") -- 3159
	end -- 3159
	if self.room.key == "village" then -- 3159
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3162
		if self.hasBottle then -- 3162
			parts[#parts + 1] = "有瓶" -- 3164
		elseif self.bottleFly ~= nil then -- 3164
			parts[#parts + 1] = "瓶在飞" -- 3166
		else -- 3166
			parts[#parts + 1] = "空手" -- 3168
		end -- 3168
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 3170
		if self.scavChase then -- 3170
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 3172
		end -- 3172
		if self.passed then -- 3172
			parts[#parts + 1] = "已过通行线" -- 3175
		end -- 3175
		if self.paused then -- 3175
			parts[#parts + 1] = "已暂停" -- 3178
		end -- 3178
		return table.concat(parts, " · ") -- 3180
	end -- 3180
	local isChild = self.childMode -- 3183
	if isChild then -- 3183
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3185
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 3186
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3187
	else -- 3187
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 3189
		if p.rollT > 0 then -- 3189
			parts[#parts + 1] = "翻滚中" -- 3191
		end -- 3191
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3193
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3194
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 3195
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 3196
	end -- 3196
	if self.checkpoint >= 0 then -- 3196
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 3199
	end -- 3199
	if self.paused then -- 3199
		parts[#parts + 1] = "已暂停" -- 3202
	end -- 3202
	return table.concat(parts, " · ") -- 3204
end -- 3084
function Play.prototype.aliveEnemies(self) -- 3208
	local n = 0 -- 3209
	local i = 0 -- 3210
	do -- 3210
		i = 0 -- 3211
		while i < #self.enemies do -- 3211
			if self.enemies[i + 1].alive then -- 3211
				n = n + 1 -- 3213
			end -- 3213
			i = i + 1 -- 3211
		end -- 3211
	end -- 3211
	return n -- 3216
end -- 3208
function Play.prototype.threatened(self) -- 3221
	do -- 3221
		local i = 0 -- 3222
		while i < #self.enemies do -- 3222
			local e = self.enemies[i + 1] -- 3223
			if e.alive and e.warnT > 0 then -- 3223
				return true -- 3225
			end -- 3225
			i = i + 1 -- 3222
		end -- 3222
	end -- 3222
	return false -- 3228
end -- 3221
function Play.prototype.gateSecondsLeft(self) -- 3231
	local ____temp_41 -- 3232
	if self.room.story == nil then -- 3232
		____temp_41 = nil -- 3232
	else -- 3232
		____temp_41 = self.room.story.gate -- 3232
	end -- 3232
	local g = ____temp_41 -- 3232
	if g == nil then -- 3232
		return 0 -- 3234
	end -- 3234
	return math.max( -- 3236
		0, -- 3236
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 3236
	) -- 3236
end -- 3231
function Play.prototype.gateLabel(self) -- 3239
	if self.phase == "gate-idle" then -- 3239
		return "待就位" -- 3241
	end -- 3241
	if self.phase == "gate-hold" then -- 3241
		return "守点中" -- 3244
	end -- 3244
	if self.phase == "gate-send" then -- 3244
		return "送别" -- 3247
	end -- 3247
	if self.phase == "gate-count" then -- 3247
		return "数数 " .. tostring(self.countTick) -- 3250
	end -- 3250
	return "她走" -- 3252
end -- 3239
function Play.prototype.dogLabel(self) -- 3256
	if self.dogState == "ear" then -- 3256
		return "转耳" -- 3258
	end -- 3258
	if self.dogState == "chase" then -- 3258
		return "追" -- 3261
	end -- 3261
	if self.dogState == "sniff" then -- 3261
		return "停" -- 3264
	end -- 3264
	if self.dogState == "back" then -- 3264
		return "回线" -- 3267
	end -- 3267
	return "巡逻" -- 3269
end -- 3256
function Play.prototype.doorXOf(self) -- 3272
	local ____temp_42 -- 3273
	if self.room.story == nil then -- 3273
		____temp_42 = nil -- 3273
	else -- 3273
		____temp_42 = self.room.story.tower -- 3273
	end -- 3273
	local t = ____temp_42 -- 3273
	return t == nil and 0 or t.doorX -- 3274
end -- 3272
function Play.prototype.scavLabel(self) -- 3278
	if self.scavState == "chase" then -- 3278
		return "追" -- 3280
	end -- 3280
	if self.scavState == "turn" then -- 3280
		return "转头" -- 3283
	end -- 3283
	if self.scavState == "walk" then -- 3283
		return "赶来" -- 3286
	end -- 3286
	if self.scavState == "stall" then -- 3286
		return "停住" -- 3289
	end -- 3289
	if self.scavState == "back" then -- 3289
		return "回位" -- 3292
	end -- 3292
	return "巡逻" -- 3294
end -- 3278
function Play.prototype.hintText(self) -- 3298
	if self.paused then -- 3298
		return "Esc 继续 · R 重置" -- 3300
	end -- 3300
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 3300
		if self:threatened() then -- 3300
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 3306
		end -- 3306
		if self.coverHug then -- 3306
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 3309
		end -- 3309
		if self.coverNear then -- 3309
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 3312
		end -- 3312
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 3314
	end -- 3314
	if self.flash ~= "" then -- 3314
		return self.flash -- 3317
	end -- 3317
	if self.room.key == "prologue" then -- 3317
		if self.phase == "prologue-wait" then -- 3317
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 3321
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 3322
		end -- 3322
		if self.phase == "prologue-give" then -- 3322
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 3325
		end -- 3325
		return "她跟着你了 · 两人一起走到门口 680" -- 3327
	end -- 3327
	if self.room.key == "street" then -- 3327
		if self:aliveEnemies() > 0 then -- 3327
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 3331
		end -- 3331
		return "清完了 · 两人一起走到右边检查站入口 900" -- 3333
	end -- 3333
	if self.room.key == "gate" then -- 3333
		local ____temp_43 -- 3336
		if self.room.story == nil then -- 3336
			____temp_43 = nil -- 3336
		else -- 3336
			____temp_43 = self.room.story.gate -- 3336
		end -- 3336
		local g = ____temp_43 -- 3336
		if g ~= nil then -- 3336
			if self.phase == "gate-idle" then -- 3336
				if self.gateNeedConfirm then -- 3336
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 3340
				end -- 3340
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 3342
			end -- 3342
			if self.phase == "gate-hold" then -- 3342
				if self.coveredFlash > 0 then -- 3342
					return "掩体挡下了这一枪 · 别露头" -- 3346
				end -- 3346
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 3348
			end -- 3348
			if self.phase == "gate-send" then -- 3348
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 3351
			end -- 3351
			if self.phase == "gate-count" then -- 3351
				if self.countTick >= 1440 then -- 3351
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 3355
				end -- 3355
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 3357
			end -- 3357
			return "她自己走 · 跟着出城门 1120" -- 3359
		end -- 3359
	end -- 3359
	if self.room.key == "forest" then -- 3359
		if self.dogState == "chase" then -- 3359
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 3364
		end -- 3364
		if self.dogState == "ear" then -- 3364
			return "狗转耳朵了 · 停下或蹲下别出声" -- 3367
		end -- 3367
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 3369
	end -- 3369
	if self.room.key == "tower" then -- 3369
		if self.phase == "tower-wait" then -- 3369
			return "走到门前 445 点一次 E 敲两下" -- 3373
		end -- 3373
		if self.phase == "tower-knock" then -- 3373
			return "敲两下 · 等门开" -- 3376
		end -- 3376
		if self.phase == "tower-given" then -- 3376
			return "递交针套和纸条 · 看登记簿最后一行" -- 3379
		end -- 3379
		return "片尾 · 点 E 再玩一次，回到序章" -- 3381
	end -- 3381
	if self.room.key == "village" then -- 3381
		if self.bottleFly ~= nil then -- 3381
			return "等瓶子落地 · 触地才发声" -- 3385
		end -- 3385
		if self.hasBottle then -- 3385
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 3388
		end -- 3388
		if self.passed then -- 3388
			return "已过第一院 · R 重置可再来一遍" -- 3391
		end -- 3391
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 3393
	end -- 3393
	if self.room.key == "outside" then -- 3393
		if self.focusCart then -- 3393
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 3397
		end -- 3397
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 3399
	end -- 3399
	if self.escort.state == "frozen" then -- 3399
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 3399
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 3403
		end -- 3403
		return "小满吓住了 · 走过去，靠近再点 E" -- 3405
	end -- 3405
	if self.escort.state == "calming" then -- 3405
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 3408
	end -- 3408
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 3410
end -- 3298
function Play.prototype.draw(self, draw, w, h) -- 3415
	self.viewW = w -- 3416
	self.viewH = h -- 3417
	self.view = ____exports.computeViewport(w, h) -- 3418
	self:clampCamera(w, h) -- 3419
	draw:clear() -- 3420
	draw:drawRect( -- 3422
		Rect(0, 0, w, h), -- 3422
		BG_VOID -- 3422
	) -- 3422
	local box = self:canvasRect(w, h) -- 3423
	draw:drawRect(box, BG_FAR) -- 3424
	draw:drawRect( -- 3425
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 3425
		BG_MID -- 3425
	) -- 3425
	self:drawFloors(draw, w, h) -- 3427
	self:drawSolids(draw, w, h) -- 3428
	self:drawZones(draw, w, h) -- 3429
	self:drawArch(draw, w, h) -- 3430
	self:drawCart(draw, w, h) -- 3431
	self:drawCampaignProps(draw, w, h) -- 3432
	self:drawActors(draw, w, h) -- 3433
	self:drawTrace(draw, w, h) -- 3434
	self:drawAim(draw, w, h) -- 3435
end -- 3415
function Play.prototype.canvasRect(self, w, h) -- 3439
	local v = self.view -- 3440
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 3441
end -- 3439
function Play.prototype.px(self, n) -- 3445
	return n * self.view.zoom -- 3446
end -- 3445
function Play.prototype.sx(self, wx, w) -- 3450
	local v = self.view -- 3451
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 3452
	return v.ox + lx * v.zoom -- 3453
end -- 3450
function Play.prototype.sy(self, wy, h) -- 3457
	local v = self.view -- 3458
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 3459
	return v.oy + ly * v.zoom -- 3460
end -- 3457
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 3463
	local px0 = self:sx(x0, w) -- 3464
	local px1 = self:sx(x1, w) -- 3465
	local py0 = self:sy(y0, h) -- 3466
	local py1 = self:sy(y1, h) -- 3467
	if px1 <= px0 or py1 <= py0 then -- 3467
		return -- 3469
	end -- 3469
	draw:drawRect( -- 3471
		Rect(px0, py0, px1 - px0, py1 - py0), -- 3471
		color -- 3471
	) -- 3471
end -- 3463
function Play.prototype.drawFloors(self, draw, w, h) -- 3474
	local i = 0 -- 3475
	do -- 3475
		i = 0 -- 3476
		while i < #self.room.floors do -- 3476
			local f = self.room.floors[i + 1] -- 3477
			local ____temp_44 -- 3478
			if f.y == 0 then -- 3478
				____temp_44 = self.room.depth -- 3478
			else -- 3478
				____temp_44 = nil -- 3478
			end -- 3478
			local road = ____temp_44 -- 3478
			local y = self:sy(f.y + (road and road.min or 0), h) -- 3479
			local x0 = self:sx(f.x0, w) -- 3480
			local x1 = self:sx(f.x1, w) -- 3481
			local deck = self:px(5) -- 3482
			if road ~= nil then -- 3482
				local back = self:sy(f.y + road.max, h) -- 3484
				draw:drawRect( -- 3485
					Rect(x0, y, x1 - x0, back - y), -- 3485
					FLOOR_DECK, -- 3485
					self:px(1), -- 3485
					SOLID_EDGE -- 3485
				) -- 3485
			end -- 3485
			draw:drawRect( -- 3487
				Rect(x0, y - deck, x1 - x0, deck), -- 3487
				FLOOR_DECK -- 3487
			) -- 3487
			draw:drawSegment( -- 3488
				Vec2(x0, y), -- 3488
				Vec2(x1, y), -- 3488
				self:px(1), -- 3488
				GROUND -- 3488
			) -- 3488
			i = i + 1 -- 3476
		end -- 3476
	end -- 3476
end -- 3474
function Play.prototype.drawSolids(self, draw, w, h) -- 3492
	local i = 0 -- 3493
	do -- 3493
		i = 0 -- 3494
		while i < #self.boxes do -- 3494
			do -- 3494
				local b = self.boxes[i + 1] -- 3495
				if b.id == "braced_shield" or b.hidden == true then -- 3495
					goto __continue683 -- 3497
				end -- 3497
				if b.broken == true then -- 3497
					if b.breakable ~= nil then -- 3497
						local gy = self:sy(b.y0, h) -- 3502
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 3503
						local k = 0 -- 3504
						do -- 3504
							k = 0 -- 3505
							while k < 3 do -- 3505
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 3506
								draw:drawSegment( -- 3507
									Vec2( -- 3507
										gx - self:px(4), -- 3507
										gy + self:px(k % 2) -- 3507
									), -- 3507
									Vec2( -- 3507
										gx + self:px(5), -- 3507
										gy + self:px(k % 2) -- 3507
									), -- 3507
									self:px(1), -- 3507
									rgb -- 3507
								) -- 3507
								k = k + 1 -- 3505
							end -- 3505
						end -- 3505
					end -- 3505
					goto __continue683 -- 3510
				end -- 3510
				local ____opt_47 = b.depth -- 3510
				local front = ____opt_47 and ____opt_47.min or 0 -- 3512
				local ____opt_49 = b.depth -- 3512
				local back = ____opt_49 and ____opt_49.max or 0 -- 3513
				local fill = SOLID_FILL -- 3514
				local line = SOLID_EDGE -- 3515
				if b.soft == true then -- 3515
					fill = SOFT -- 3517
					line = SOFT_LINE -- 3518
				elseif b.breakable ~= nil then -- 3518
					line = DANGER_LINE -- 3520
					fill = Color(0.3, 0.24, 0.16, 1) -- 3521
				elseif b.interact ~= nil then -- 3521
					line = PASS_LINE -- 3523
				end -- 3523
				self:drawBox( -- 3525
					draw, -- 3525
					w, -- 3525
					h, -- 3525
					b.x0, -- 3525
					b.x1, -- 3525
					b.y0 + front, -- 3525
					b.y1 + back, -- 3525
					fill -- 3525
				) -- 3525
				draw:drawSegment( -- 3526
					Vec2( -- 3526
						self:sx(b.x0, w), -- 3526
						self:sy(b.y1 + front, h) -- 3526
					), -- 3526
					Vec2( -- 3527
						self:sx(b.x1, w), -- 3527
						self:sy(b.y1 + front, h) -- 3527
					), -- 3527
					self:px(1), -- 3527
					line -- 3527
				) -- 3527
				if b.breakable ~= nil then -- 3527
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 3530
					local cyp = self:sy(b.y1 + front, h) -- 3531
					draw:drawSegment( -- 3532
						Vec2( -- 3532
							cxp - self:px(4), -- 3532
							cyp + self:px(1) -- 3532
						), -- 3532
						Vec2( -- 3532
							cxp + self:px(3), -- 3532
							cyp + self:px(5) -- 3532
						), -- 3532
						self:px(1), -- 3532
						line -- 3532
					) -- 3532
				end -- 3532
			end -- 3532
			::__continue683:: -- 3532
			i = i + 1 -- 3494
		end -- 3494
	end -- 3494
end -- 3492
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 3538
	local i = 0 -- 3539
	do -- 3539
		i = 0 -- 3540
		while i < #self.pickups do -- 3540
			do -- 3540
				local pk = self.pickups[i + 1] -- 3541
				if pk.id == "" then -- 3541
					goto __continue695 -- 3543
				end -- 3543
				local gy = pk.y + (pk.depth or 0) -- 3545
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 3546
				draw:drawRect( -- 3547
					Rect( -- 3547
						self:sx(pk.x - 5, w), -- 3547
						self:sy(gy + 12 + bob, h), -- 3547
						self:px(10), -- 3547
						self:px(10) -- 3547
					), -- 3547
					Color(0.84, 0.7, 0.3, 1) -- 3548
				) -- 3548
				draw:drawSegment( -- 3549
					Vec2( -- 3549
						self:sx(pk.x - 5, w), -- 3549
						self:sy(gy + 12 + bob, h) -- 3549
					), -- 3549
					Vec2( -- 3550
						self:sx(pk.x + 5, w), -- 3550
						self:sy(gy + 12 + bob, h) -- 3550
					), -- 3550
					self:px(1), -- 3550
					Color(0.95, 0.86, 0.52, 1) -- 3550
				) -- 3550
			end -- 3550
			::__continue695:: -- 3550
			i = i + 1 -- 3540
		end -- 3540
	end -- 3540
	if self.bracedShield ~= nil then -- 3540
		local sh = self.bracedShield -- 3553
		draw:drawRect( -- 3554
			Rect( -- 3554
				self:sx(sh.x - sh.w / 2, w), -- 3554
				self:sy(sh.y, h), -- 3554
				self:px(sh.w), -- 3554
				self:px(sh.h) -- 3554
			), -- 3554
			Color(0.42, 0.4, 0.34, 1) -- 3555
		) -- 3555
		draw:drawSegment( -- 3556
			Vec2( -- 3556
				self:sx(sh.x - sh.w / 2, w), -- 3556
				self:sy(sh.y + sh.h, h) -- 3556
			), -- 3556
			Vec2( -- 3557
				self:sx(sh.x + sh.w / 2, w), -- 3557
				self:sy(sh.y + sh.h, h) -- 3557
			), -- 3557
			self:px(1), -- 3557
			Color(0.74, 0.72, 0.62, 1) -- 3557
		) -- 3557
	end -- 3557
end -- 3538
function Play.prototype.drawZones(self, draw, w, h) -- 3561
	local i = 0 -- 3562
	do -- 3562
		i = 0 -- 3563
		while i < #self.room.zones do -- 3563
			local z = self.room.zones[i + 1] -- 3564
			local fill = DANGER -- 3565
			local line = DANGER_LINE -- 3566
			if z.tint == 2 then -- 3566
				fill = SOFT -- 3568
				line = SOFT_LINE -- 3569
			elseif z.tint == 3 then -- 3569
				fill = BRICK -- 3571
				line = BRICK_LINE -- 3572
			elseif z.tint == 4 then -- 3572
				fill = PASS -- 3574
				line = PASS_LINE -- 3575
			end -- 3575
			self:drawBox( -- 3577
				draw, -- 3577
				w, -- 3577
				h, -- 3577
				z.x0, -- 3577
				z.x1, -- 3577
				z.y, -- 3577
				z.y + z.h, -- 3577
				fill -- 3577
			) -- 3577
			draw:drawSegment( -- 3578
				Vec2( -- 3578
					self:sx(z.x0, w), -- 3578
					self:sy(z.y, h) -- 3578
				), -- 3578
				Vec2( -- 3578
					self:sx(z.x0, w), -- 3578
					self:sy(z.y + z.h, h) -- 3578
				), -- 3578
				self:px(1), -- 3578
				line -- 3578
			) -- 3578
			draw:drawSegment( -- 3579
				Vec2( -- 3579
					self:sx(z.x1, w), -- 3579
					self:sy(z.y, h) -- 3579
				), -- 3579
				Vec2( -- 3579
					self:sx(z.x1, w), -- 3579
					self:sy(z.y + z.h, h) -- 3579
				), -- 3579
				self:px(1), -- 3579
				line -- 3579
			) -- 3579
			i = i + 1 -- 3563
		end -- 3563
	end -- 3563
end -- 3561
function Play.prototype.drawArch(self, draw, w, h) -- 3583
	local a = self.room.arch -- 3584
	if a.h <= 0 then -- 3584
		return -- 3586
	end -- 3586
	self:drawBox( -- 3588
		draw, -- 3588
		w, -- 3588
		h, -- 3588
		a.x0, -- 3588
		a.x1, -- 3588
		a.y, -- 3588
		a.y + a.h, -- 3588
		HOLE_FILL -- 3588
	) -- 3588
	draw:drawSegment( -- 3589
		Vec2( -- 3589
			self:sx(a.x0, w), -- 3589
			self:sy(a.y + a.h, h) -- 3589
		), -- 3589
		Vec2( -- 3589
			self:sx(a.x1, w), -- 3589
			self:sy(a.y + a.h, h) -- 3589
		), -- 3589
		self:px(1), -- 3589
		SOLID_EDGE -- 3589
	) -- 3589
	draw:drawSegment( -- 3590
		Vec2( -- 3590
			self:sx(a.x0, w), -- 3590
			self:sy(a.y, h) -- 3590
		), -- 3590
		Vec2( -- 3590
			self:sx(a.x0, w), -- 3590
			self:sy(a.y + a.h, h) -- 3590
		), -- 3590
		self:px(1), -- 3590
		SOLID_EDGE -- 3590
	) -- 3590
	draw:drawSegment( -- 3591
		Vec2( -- 3591
			self:sx(a.x1, w), -- 3591
			self:sy(a.y, h) -- 3591
		), -- 3591
		Vec2( -- 3591
			self:sx(a.x1, w), -- 3591
			self:sy(a.y + a.h, h) -- 3591
		), -- 3591
		self:px(1), -- 3591
		SOLID_EDGE -- 3591
	) -- 3591
end -- 3583
function Play.prototype.drawCart(self, draw, w, h) -- 3594
	local c = self.room.cart -- 3595
	if c.bodyW <= 0 then -- 3595
		return -- 3597
	end -- 3597
	drawCartShape( -- 3599
		draw, -- 3599
		self, -- 3599
		w, -- 3599
		h, -- 3599
		c, -- 3599
		self.cartAxle -- 3599
	) -- 3599
	draw:drawRect( -- 3600
		Rect( -- 3600
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 3600
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 3600
			self:px(2), -- 3600
			self:px(40) -- 3600
		), -- 3600
		STAND -- 3600
	) -- 3600
end -- 3594
function Play.prototype.drawActors(self, draw, w, h) -- 3603
	local p = self.player -- 3604
	local isChild = self.childMode -- 3605
	local footY = p.y + p.depth -- 3606
	if p.covered then -- 3606
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 3609
		draw:drawSegment( -- 3610
			Vec2( -- 3610
				self:sx(edge, w), -- 3610
				self:sy(footY + 8, h) -- 3610
			), -- 3610
			Vec2( -- 3610
				self:sx(edge, w), -- 3610
				self:sy(footY + p.h * 0.62, h) -- 3610
			), -- 3610
			self:px(2), -- 3610
			STAND -- 3610
		) -- 3610
		draw:drawSegment( -- 3612
			Vec2( -- 3612
				self:sx(p.x - 8, w), -- 3612
				self:sy(footY + p.h + 3, h) -- 3612
			), -- 3612
			Vec2( -- 3612
				self:sx(p.x + 8, w), -- 3612
				self:sy(footY + p.h + 3, h) -- 3612
			), -- 3612
			self:px(2), -- 3612
			STAND -- 3612
		) -- 3612
	elseif self.coverNear and not isChild then -- 3612
		draw:drawRect( -- 3615
			Rect( -- 3615
				self:sx(p.x - 3, w), -- 3615
				self:sy(footY + 1, h), -- 3615
				self:px(3), -- 3615
				self:px(3) -- 3615
			), -- 3615
			STAND -- 3615
		) -- 3615
	end -- 3615
	drawFigure( -- 3617
		draw, -- 3617
		self, -- 3617
		w, -- 3617
		h, -- 3617
		p, -- 3617
		isChild and CHILD_BODY or SOLDIER_BODY, -- 3617
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 3617
	) -- 3617
	local q = self.partner -- 3618
	if q.alive then -- 3618
		local childPartner = q.w == CHILD_W -- 3620
		drawFigure( -- 3621
			draw, -- 3621
			self, -- 3621
			w, -- 3621
			h, -- 3621
			q, -- 3621
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 3621
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 3621
		) -- 3621
	end -- 3621
	local i = 0 -- 3623
	do -- 3623
		i = 0 -- 3624
		while i < #self.enemies do -- 3624
			local e = self.enemies[i + 1] -- 3625
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 3626
			local enemyY = e.y + (e.depth or 0) -- 3627
			self:drawBox( -- 3628
				draw, -- 3628
				w, -- 3628
				h, -- 3628
				e.x - e.w / 2, -- 3628
				e.x + e.w / 2, -- 3628
				enemyY, -- 3628
				enemyY + e.h, -- 3628
				col -- 3628
			) -- 3628
			if e.alive then -- 3628
				local ef = p.x >= e.x and 1 or -1 -- 3630
				if e.kind == "shield" then -- 3630
					local sh = (e.shieldHp or 0) > 0 -- 3632
					draw:drawRect( -- 3633
						Rect( -- 3633
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 3633
							self:sy(enemyY, h), -- 3633
							self:px(6), -- 3633
							self:px(64) -- 3633
						), -- 3633
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 3634
					) -- 3634
				elseif e.kind == "breaker" then -- 3634
					draw:drawSegment( -- 3636
						Vec2( -- 3636
							self:sx(e.x + ef * 12, w), -- 3636
							self:sy(enemyY + 8, h) -- 3636
						), -- 3636
						Vec2( -- 3637
							self:sx(e.x + ef * 22, w), -- 3637
							self:sy(enemyY + 46, h) -- 3637
						), -- 3637
						self:px(3), -- 3637
						Color(0.5, 0.36, 0.22, 1) -- 3637
					) -- 3637
				end -- 3637
			end -- 3637
			if e.alive and e.warnT > 0 then -- 3637
				local gunX = self:sx(e.x, w) -- 3642
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 3643
				local aimX = self:sx(p.x, w) -- 3644
				local aimY = self:sy(footY + p.h * 0.55, h) -- 3645
				local seg = 8 -- 3646
				local s = 0 -- 3647
				do -- 3647
					s = 0 -- 3648
					while s < seg do -- 3648
						local t0 = s / seg -- 3649
						local t1 = (s + 1) / seg -- 3650
						draw:drawSegment( -- 3651
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 3652
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 3653
							self:px(1), -- 3654
							DANGER -- 3654
						) -- 3654
						s = s + 2 -- 3648
					end -- 3648
				end -- 3648
			end -- 3648
			i = i + 1 -- 3624
		end -- 3624
	end -- 3624
	local k = 0 -- 3659
	do -- 3659
		k = 0 -- 3660
		while k < #self.room.marks do -- 3660
			do -- 3660
				local m = self.room.marks[k + 1] -- 3661
				if m.kind ~= 0 then -- 3661
					goto __continue721 -- 3663
				end -- 3663
				local on = self.checkpoint == m.x -- 3665
				local x = self:sx(m.x, w) -- 3666
				local y = self:sy(m.y, h) -- 3667
				draw:drawSegment( -- 3668
					Vec2(x, y), -- 3668
					Vec2( -- 3668
						x, -- 3668
						y + self:px(35) -- 3668
					), -- 3668
					self:px(1), -- 3668
					on and CHECK or INK_DIM -- 3668
				) -- 3668
				draw:drawDot( -- 3669
					Vec2( -- 3669
						x, -- 3669
						y + self:px(35) -- 3669
					), -- 3669
					self:px(2), -- 3669
					on and CHECK or INK_DIM -- 3669
				) -- 3669
			end -- 3669
			::__continue721:: -- 3669
			k = k + 1 -- 3660
		end -- 3660
	end -- 3660
	local j = 0 -- 3673
	do -- 3673
		j = 0 -- 3674
		while j < #self.room.marks do -- 3674
			do -- 3674
				local m = self.room.marks[j + 1] -- 3675
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 3675
					goto __continue724 -- 3677
				end -- 3677
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 3677
					goto __continue724 -- 3681
				end -- 3681
				local col = STAND -- 3683
				if m.kind == 4 then -- 3683
					col = PASS_LINE -- 3685
				elseif m.kind == 5 then -- 3685
					col = BRICK_LINE -- 3687
				end -- 3687
				local mx = self:sx(m.x, w) -- 3689
				local my = self:sy(m.y, h) -- 3690
				draw:drawSegment( -- 3691
					Vec2(mx, my), -- 3691
					Vec2( -- 3691
						mx, -- 3691
						my + self:px(24) -- 3691
					), -- 3691
					self:px(1), -- 3691
					col -- 3691
				) -- 3691
			end -- 3691
			::__continue724:: -- 3691
			j = j + 1 -- 3674
		end -- 3674
	end -- 3674
	local t = 0 -- 3694
	do -- 3694
		t = 0 -- 3695
		while t < #self.room.marks do -- 3695
			do -- 3695
				local m = self.room.marks[t + 1] -- 3696
				if m.kind ~= 6 then -- 3696
					goto __continue730 -- 3698
				end -- 3698
				local mx = self:sx(m.x, w) -- 3700
				local my = self:sy(m.y, h) -- 3701
				draw:drawSegment( -- 3702
					Vec2(mx, my), -- 3702
					Vec2( -- 3702
						mx, -- 3702
						my + self:px(30) -- 3702
					), -- 3702
					self:px(1), -- 3702
					INK_DIM -- 3702
				) -- 3702
				self:drawBox( -- 3703
					draw, -- 3703
					w, -- 3703
					h, -- 3703
					m.x - 5, -- 3703
					m.x + 5, -- 3703
					m.y + 30, -- 3703
					m.y + 40, -- 3703
					CHECK -- 3703
				) -- 3703
			end -- 3703
			::__continue730:: -- 3703
			t = t + 1 -- 3695
		end -- 3695
	end -- 3695
	if self.room.key == "village" then -- 3695
		self:drawVillage(draw, w, h) -- 3706
	end -- 3706
	if self.room.key == "forest" then -- 3706
		self:drawDog(draw, w, h) -- 3709
	end -- 3709
end -- 3603
function Play.prototype.drawDog(self, draw, w, h) -- 3714
	local x = self.dogX -- 3715
	self:drawBox( -- 3716
		draw, -- 3716
		w, -- 3716
		h, -- 3716
		x - 14, -- 3716
		x + 14, -- 3716
		0, -- 3716
		20, -- 3716
		SCAV_BODY -- 3716
	) -- 3716
	self:drawBox( -- 3717
		draw, -- 3717
		w, -- 3717
		h, -- 3717
		x - 10, -- 3717
		x - 2, -- 3717
		20, -- 3717
		30, -- 3717
		SCAV_BODY -- 3717
	) -- 3717
	self:drawBox( -- 3718
		draw, -- 3718
		w, -- 3718
		h, -- 3718
		x + 2, -- 3718
		x + 10, -- 3718
		20, -- 3718
		30, -- 3718
		SCAV_HEAD -- 3718
	) -- 3718
	if self.dogState == "ear" or self.dogState == "chase" then -- 3718
		draw:drawSegment( -- 3720
			Vec2( -- 3720
				self:sx(x, w), -- 3720
				self:sy(30, h) -- 3720
			), -- 3720
			Vec2( -- 3721
				self:sx(x, w), -- 3721
				self:sy(40, h) -- 3721
			), -- 3721
			self:px(1), -- 3721
			DANGER -- 3721
		) -- 3721
	end -- 3721
end -- 3714
function Play.prototype.drawVillage(self, draw, w, h) -- 3726
	local bottle = self.room.bottle -- 3727
	if bottle ~= nil then -- 3727
		self:drawBox( -- 3729
			draw, -- 3729
			w, -- 3729
			h, -- 3729
			bottle.x - 14, -- 3729
			bottle.x + 14, -- 3729
			0, -- 3729
			64, -- 3729
			SOLID_FILL -- 3729
		) -- 3729
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 3729
			self:drawBottle( -- 3731
				draw, -- 3731
				w, -- 3731
				h, -- 3731
				bottle.x, -- 3731
				64 -- 3731
			) -- 3731
		end -- 3731
	end -- 3731
	self:drawBox( -- 3735
		draw, -- 3735
		w, -- 3735
		h, -- 3735
		300, -- 3735
		420, -- 3735
		44, -- 3735
		50, -- 3735
		FLOOR_DECK -- 3735
	) -- 3735
	self:drawBox( -- 3736
		draw, -- 3736
		w, -- 3736
		h, -- 3736
		300, -- 3736
		306, -- 3736
		0, -- 3736
		44, -- 3736
		FLOOR_DECK -- 3736
	) -- 3736
	self:drawBox( -- 3737
		draw, -- 3737
		w, -- 3737
		h, -- 3737
		414, -- 3737
		420, -- 3737
		0, -- 3737
		44, -- 3737
		FLOOR_DECK -- 3737
	) -- 3737
	local s = self.room.scavenger -- 3739
	if s ~= nil then -- 3739
		local sx0 = self.scavX -- 3741
		self:drawBox( -- 3742
			draw, -- 3742
			w, -- 3742
			h, -- 3742
			sx0 - 12, -- 3742
			sx0 + 12, -- 3742
			0, -- 3742
			s.h - 14, -- 3742
			SCAV_BODY -- 3742
		) -- 3742
		self:drawBox( -- 3743
			draw, -- 3743
			w, -- 3743
			h, -- 3743
			sx0 - 7, -- 3743
			sx0 + 7, -- 3743
			s.h - 14, -- 3743
			s.h, -- 3743
			SCAV_HEAD -- 3743
		) -- 3743
		if self.scavState == "turn" then -- 3743
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 3745
			draw:drawSegment( -- 3746
				Vec2( -- 3746
					self:sx(sx0, w), -- 3746
					self:sy(s.h - 6, h) -- 3746
				), -- 3746
				Vec2( -- 3746
					self:sx(fx, w), -- 3746
					self:sy(s.h - 6, h) -- 3746
				), -- 3746
				self:px(1), -- 3746
				INK -- 3746
			) -- 3746
		end -- 3746
	end -- 3746
	if self.hasBottle then -- 3746
		local p = self.player -- 3751
		self:drawBottle( -- 3752
			draw, -- 3752
			w, -- 3752
			h, -- 3752
			p.x + p.facing * 10, -- 3752
			p.y + p.h * 0.62 -- 3752
		) -- 3752
	end -- 3752
	if self.bottleFly ~= nil then -- 3752
		self:drawBottle( -- 3755
			draw, -- 3755
			w, -- 3755
			h, -- 3755
			self.bottleFly.x, -- 3755
			self.bottleFly.y -- 3755
		) -- 3755
	end -- 3755
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 3755
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 3758
		draw:drawCircle( -- 3759
			Vec2( -- 3759
				self:sx(self.bottleLandX, w), -- 3759
				self:sy(0, h) -- 3759
			), -- 3759
			self:px(r / ____exports.UNITS_PER_PX), -- 3759
			BRICK_LINE -- 3759
		) -- 3759
	end -- 3759
end -- 3726
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 3763
	self:drawBox( -- 3764
		draw, -- 3764
		w, -- 3764
		h, -- 3764
		x - 3, -- 3764
		x + 3, -- 3764
		y - 10, -- 3764
		y, -- 3764
		BOTTLE -- 3764
	) -- 3764
end -- 3763
function Play.prototype.drawTrace(self, draw, w, h) -- 3767
	local t = self.trace -- 3768
	if t == nil or self.traceT <= 0 then -- 3768
		return -- 3770
	end -- 3770
	draw:drawSegment( -- 3772
		Vec2( -- 3773
			self:sx(t.x0, w), -- 3773
			self:sy(t.y0, h) -- 3773
		), -- 3773
		Vec2( -- 3774
			self:sx(t.x1, w), -- 3774
			self:sy(t.y1, h) -- 3774
		), -- 3774
		self:px(1), -- 3775
		t.hit and AIM_HIT or INK_DIM -- 3775
	) -- 3775
end -- 3767
function Play.prototype.drawAim(self, draw, w, h) -- 3778
	local v = self.view -- 3780
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 3781
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 3782
	local dot = self:px(1) -- 3783
	local arm = self:px(3) -- 3784
	local gap = self:px(1) -- 3785
	draw:drawSegment( -- 3786
		Vec2(gx - arm - gap, gy), -- 3786
		Vec2(gx - gap, gy), -- 3786
		dot / 2, -- 3786
		AIM -- 3786
	) -- 3786
	draw:drawSegment( -- 3787
		Vec2(gx + gap, gy), -- 3787
		Vec2(gx + arm + gap, gy), -- 3787
		dot / 2, -- 3787
		AIM -- 3787
	) -- 3787
	draw:drawSegment( -- 3788
		Vec2(gx, gy - arm - gap), -- 3788
		Vec2(gx, gy - gap), -- 3788
		dot / 2, -- 3788
		AIM -- 3788
	) -- 3788
	draw:drawSegment( -- 3789
		Vec2(gx, gy + gap), -- 3789
		Vec2(gx, gy + arm + gap), -- 3789
		dot / 2, -- 3789
		AIM -- 3789
	) -- 3789
	if self.room.key == "village" and self.hasBottle then -- 3789
		local p = self.player -- 3793
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3795
		local dir = ____end.x >= p.x and 1 or -1 -- 3796
		local x0 = p.x + dir * 10 -- 3797
		local y0 = p.y + p.h * 0.7 -- 3798
		local T = BOTTLE_FLY_TIME -- 3799
		local vx = (____end.x - x0) / T -- 3800
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 3801
		local pxr = x0 -- 3802
		local pyr = y0 -- 3803
		local t = 1 -- 3804
		do -- 3804
			t = 1 -- 3805
			while t <= 12 do -- 3805
				local tt = t / 12 * T -- 3806
				local nx = x0 + vx * tt -- 3807
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 3808
				draw:drawSegment( -- 3809
					Vec2( -- 3809
						self:sx(pxr, w), -- 3809
						self:sy(pyr, h) -- 3809
					), -- 3809
					Vec2( -- 3809
						self:sx(nx, w), -- 3809
						self:sy(ny, h) -- 3809
					), -- 3809
					self:px(1) / 2, -- 3809
					BOTTLE -- 3809
				) -- 3809
				pxr = nx -- 3810
				pyr = ny -- 3811
				t = t + 1 -- 3805
			end -- 3805
		end -- 3805
		draw:drawCircle( -- 3813
			Vec2( -- 3813
				self:sx(____end.x, w), -- 3813
				self:sy(____end.y + 2, h) -- 3813
			), -- 3813
			self:px(2), -- 3813
			BOTTLE -- 3813
		) -- 3813
	end -- 3813
end -- 3778
return ____exports -- 3778