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
function makeActor(room, index) -- 3831
	local sp = room.spawns -- 3832
	if index < 0 or index >= #sp then -- 3832
		return { -- 3834
			x = 0, -- 3834
			y = 0, -- 3834
			depth = 0, -- 3834
			depthSpeed = 0, -- 3834
			vx = 0, -- 3834
			vy = 0, -- 3834
			w = CHILD_W, -- 3834
			h = CHILD_H, -- 3834
			onGround = true, -- 3834
			facing = 1, -- 3834
			crouch = false, -- 3834
			rollT = 0, -- 3834
			covered = false, -- 3834
			alive = false -- 3834
		} -- 3834
	end -- 3834
	local s = sp[index + 1] -- 3836
	local child = s.h <= CHILD_H -- 3837
	local ground = room.depth -- 3838
	local depth = ground == nil and 0 or math.max( -- 3839
		ground.min, -- 3839
		math.min(ground.max, s.depth or 0) -- 3839
	) -- 3839
	return { -- 3840
		x = s.x, -- 3841
		y = s.y, -- 3841
		depth = depth, -- 3841
		depthSpeed = 0, -- 3841
		vx = 0, -- 3841
		vy = 0, -- 3841
		w = child and CHILD_W or SOLDIER_W, -- 3842
		h = child and CHILD_H or SOLDIER_H, -- 3843
		onGround = true, -- 3844
		facing = 1, -- 3844
		crouch = false, -- 3844
		rollT = 0, -- 3844
		covered = false, -- 3844
		alive = true -- 3844
	} -- 3844
end -- 3844
function drawFigure(draw, play, w, h, a, body, head) -- 3848
	if not a.alive then -- 3848
		return -- 3850
	end -- 3850
	local x0 = a.x - a.w / 2 -- 3852
	local x1 = a.x + a.w / 2 -- 3853
	local y0 = a.y + a.depth -- 3854
	local y1 = y0 + a.h -- 3855
	play:drawBox( -- 3856
		draw, -- 3856
		w, -- 3856
		h, -- 3856
		x0, -- 3856
		x1, -- 3856
		y0, -- 3856
		y1 - a.h * 0.26, -- 3856
		body -- 3856
	) -- 3856
	play:drawBox( -- 3857
		draw, -- 3857
		w, -- 3857
		h, -- 3857
		x0 + 2, -- 3857
		x1 - 2, -- 3857
		y1 - a.h * 0.26, -- 3857
		y1, -- 3857
		head -- 3857
	) -- 3857
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 3859
	play:drawBox( -- 3860
		draw, -- 3860
		w, -- 3860
		h, -- 3860
		eyeX, -- 3860
		eyeX + 4, -- 3860
		y1 - a.h * 0.14, -- 3860
		y1 - a.h * 0.08, -- 3860
		INK -- 3860
	) -- 3860
end -- 3860
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 3864
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 3865
end -- 3864
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 3872
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 3873
end -- 3872
function rayInterval(origin, direction, min, max) -- 3880
	if direction == 0 then -- 3880
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 3882
	end -- 3882
	local a = (min - origin) / direction -- 3884
	local b = (max - origin) / direction -- 3885
	return { -- 3886
		min = math.min(a, b), -- 3886
		max = math.max(a, b) -- 3886
	} -- 3886
end -- 3886
function hitBox(ray, box) -- 3890
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 3891
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 3892
	local enter = math.max(0, x.min, y.min) -- 3893
	local leave = math.min(99999, x.max, y.max) -- 3894
	if box.depth ~= nil then -- 3894
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 3896
		enter = math.max(enter, depth.min) -- 3897
		leave = math.min(leave, depth.max) -- 3898
	end -- 3898
	return leave >= enter and enter or -1 -- 3900
end -- 3900
function drawCartShape(draw, play, w, h, c, axleX) -- 3903
	local half = c.bodyW / 2 -- 3904
	local x0 = axleX - half -- 3905
	local x1 = axleX + half -- 3906
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 3907
	play:drawBox( -- 3908
		draw, -- 3908
		w, -- 3908
		h, -- 3908
		x0, -- 3908
		x1, -- 3908
		axleY, -- 3908
		axleY + c.bodyH, -- 3908
		CART_FILL -- 3908
	) -- 3908
	draw:drawCircle( -- 3909
		Vec2( -- 3909
			play:sx(x0 + c.bodyW * 0.28, w), -- 3909
			play:sy(axleY, h) -- 3909
		), -- 3909
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 3909
		Color(52, 50, 48, 255) -- 3909
	) -- 3909
	draw:drawCircle( -- 3910
		Vec2( -- 3910
			play:sx(x1 - c.bodyW * 0.28, w), -- 3910
			play:sy(axleY, h) -- 3910
		), -- 3910
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 3910
		Color(52, 50, 48, 255) -- 3910
	) -- 3910
	local cx = c.clothSide < 0 and x0 or x1 -- 3911
	play:drawBox( -- 3912
		draw, -- 3912
		w, -- 3912
		h, -- 3912
		cx - 10, -- 3912
		cx + 10, -- 3912
		axleY + c.bodyH, -- 3912
		axleY + c.bodyH + 18, -- 3912
		CLOTH -- 3912
	) -- 3912
end -- 3912
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
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 98
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 100
local FIRE_COOLDOWN = 150 -- 101
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 103
local ENEMY_RANGE = 760 -- 104
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 106
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 108
local DEPTH_SPEED_RATIO = 0.55 -- 109
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 110
INK = Color(232, 232, 228, 255) -- 112
local INK_DIM = Color(150, 152, 150, 255) -- 113
local BG_VOID = Color(8, 9, 10, 255) -- 114
local BG_FAR = Color(24, 26, 28, 255) -- 115
local BG_MID = Color(31, 34, 37, 255) -- 116
local GROUND = Color(112, 114, 112, 255) -- 117
local FLOOR_DECK = Color(66, 70, 72, 255) -- 118
local SOLID_FILL = Color(84, 86, 84, 255) -- 119
local SOLID_EDGE = Color(126, 130, 126, 255) -- 120
CART_FILL = Color(122, 78, 56, 255) -- 121
CLOTH = Color(178, 52, 46, 255) -- 122
local DANGER = Color(150, 54, 48, 46) -- 123
local DANGER_LINE = Color(178, 78, 64, 200) -- 124
local HOLE_FILL = Color(10, 11, 12, 255) -- 125
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 126
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 127
local CHILD_BODY = Color(214, 168, 96, 255) -- 128
local CHILD_HEAD = Color(232, 214, 186, 255) -- 129
local ENEMY_BODY = Color(176, 92, 84, 255) -- 130
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 131
local CHECK = Color(96, 186, 122, 255) -- 132
local STAND = Color(226, 186, 84, 255) -- 133
local AIM = Color(236, 236, 232, 230) -- 134
local AIM_HIT = Color(236, 96, 84, 255) -- 135
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 137
local SOFT_LINE = Color(140, 112, 80, 190) -- 138
local BRICK = Color(126, 118, 110, 70) -- 139
local BRICK_LINE = Color(160, 152, 142, 200) -- 140
local PASS = Color(96, 186, 122, 40) -- 141
local PASS_LINE = Color(96, 186, 122, 200) -- 142
local BOTTLE = Color(120, 186, 160, 255) -- 143
local SCAV_BODY = Color(128, 118, 96, 255) -- 144
local SCAV_HEAD = Color(196, 182, 158, 255) -- 145
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 232
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 233
	if zoom < 1 then -- 233
		zoom = 1 -- 235
	end -- 235
	return { -- 237
		zoom = zoom, -- 238
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 239
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 240
	} -- 240
end -- 232
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 263
	if key == "prologue" then -- 263
		return "prologue-wait" -- 265
	end -- 265
	if key == "street" then -- 265
		return "street-run" -- 268
	end -- 268
	if key == "gate" then -- 268
		return "gate-idle" -- 271
	end -- 271
	if key == "forest" then -- 271
		return "forest-run" -- 274
	end -- 274
	if key == "tower" then -- 274
		return "tower-wait" -- 277
	end -- 277
	return "run" -- 279
end -- 263
____exports.Play = __TS__Class() -- 282
local Play = ____exports.Play -- 282
Play.name = "Play" -- 282
function Play.prototype.____constructor(self, room, resume, run) -- 453
	self.enemies = {} -- 287
	self.boxes = {} -- 288
	self.floors = {} -- 289
	self.checkpoint = -1 -- 291
	self.flash = "" -- 293
	self.flashT = 0 -- 294
	self.traceT = 0 -- 297
	self.focusCart = false -- 299
	self.knocks = 0 -- 301
	self.knockT = 0 -- 302
	self.cartAxle = 0 -- 306
	self.cartDocked = false -- 308
	self.gripping = false -- 310
	self.gateOpen = false -- 312
	self.calmConsumed = false -- 314
	self.nextDangerId = 1 -- 316
	self.wantRoom = "" -- 318
	self.carryCartAxle = -1 -- 320
	self.carryCartDocked = false -- 321
	self.checkpointCartAxle = -1 -- 323
	self.hasBottle = false -- 327
	self.bottleLandX = -1 -- 331
	self.bottleTargetX = -1 -- 332
	self.bottleTargetY = 0 -- 333
	self.bottleLandT = 0 -- 334
	self.aimHold = 0 -- 336
	self.scavX = 0 -- 338
	self.scavDir = 1 -- 339
	self.scavState = "patrol" -- 340
	self.scavT = 0 -- 341
	self.scavTargetX = 0 -- 342
	self.passed = false -- 344
	self.childMode = false -- 348
	self.phase = "" -- 350
	self.phaseTick = 0 -- 352
	self.gateTick = 0 -- 354
	self.countTick = 0 -- 356
	self.countArmed = false -- 358
	self.countPrevMove = 0 -- 360
	self.caughtT = 0 -- 362
	self.hp = 3 -- 364
	self.maxHp = 3 -- 365
	self.invulnT = 0 -- 371
	self.partnerStuck = 0 -- 373
	self.partnerLaneIdx = 0 -- 375
	self.partnerLaneHold = 0 -- 376
	self.coveredFlash = 0 -- 378
	self.coverHug = false -- 380
	self.coverNear = false -- 382
	self.coverEntity = "" -- 384
	self.coverBlocking = false -- 386
	self.gateNeedConfirm = false -- 388
	self.gateRestartArmed = true -- 390
	self.bottleAimX = -1 -- 392
	self.bottleAimY = 0 -- 393
	self.bottleSurfaceY = -1 -- 395
	self.bottleLandY = 0 -- 397
	self.events = {} -- 399
	self.eventSeq = 0 -- 401
	self.dogX = 0 -- 403
	self.dogDir = 1 -- 404
	self.dogState = "patrol" -- 405
	self.dogT = 0 -- 406
	self.dogTargetX = 0 -- 407
	self.scavSee = 0 -- 409
	self.scavChase = false -- 410
	self.gateSpawned = 0 -- 412
	self.gateFailCount = 0 -- 414
	self.isCampaign = false -- 418
	self.pickups = {} -- 422
	self.reloadT = 0 -- 424
	self.objectiveDone = false -- 428
	self.hint = "" -- 430
	self.roomStartTick = 0 -- 432
	self.cartHitT = 0 -- 434
	self.cartExposed = false -- 435
	self.paused = false -- 437
	self.ticks = 0 -- 439
	self.view = {zoom = 1, ox = 0, oy = 0} -- 441
	self.ox = 0 -- 443
	self.aimX = 0 -- 445
	self.aimY = 0 -- 446
	self.viewW = 0 -- 448
	self.viewH = 0 -- 449
	self.ox = room.originX -- 455
	self.room = withOrigin(room) -- 456
	local wr = self.room -- 457
	self.run = run or createRun() -- 458
	self.isCampaign = wr.campaign ~= nil -- 459
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 460
	self:buildWorld() -- 461
	self.childMode = wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower" -- 463
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 464
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 465
	self.player = makeActor(wr, playerIdx) -- 466
	self.partner = makeActor(wr, partnerIdx) -- 467
	self.phase = phaseOf(wr.key) -- 468
	if wr.story ~= nil then -- 468
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 470
	end -- 470
	self.cam.x = self.player.x -- 472
	self.cam.y = self.player.y + CAM_LOOK_UP -- 473
	self.cartAxle = wr.cart.startX -- 474
	self.escort = __TS__New( -- 475
		Escort, -- 475
		safeAnchorX(wr.marks) -- 475
	) -- 475
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 476
	if self.isCampaign then -- 476
		self:setupCampaign() -- 478
	else -- 478
		self:buildEnemies() -- 480
	end -- 480
	if resume ~= nil and resume.checkpoint > 0 then -- 480
		self.checkpoint = resume.checkpoint -- 484
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 484
			self.cartAxle = self.room.cart.endX -- 486
			self.cartDocked = true -- 487
			self.player.x = self.ox + 380 -- 490
			self.player.y = 0 -- 491
			self.player.vy = 0 -- 492
			self.player.onGround = true -- 493
			self.cam.x = self.player.x -- 494
			self.cam.y = self.player.y + CAM_LOOK_UP -- 495
		end -- 495
	end -- 495
end -- 453
function Play.prototype.buildWorld(self) -- 501
	local room = self.room -- 502
	self.boxes = {} -- 503
	self.floors = {} -- 504
	local i = 0 -- 505
	do -- 505
		i = 0 -- 506
		while i < #room.floors do -- 506
			local f = room.floors[i + 1] -- 507
			local ____self_floors_0 = self.floors -- 507
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 508
			i = i + 1 -- 506
		end -- 506
	end -- 506
	do -- 506
		i = 0 -- 510
		while i < #room.solids do -- 510
			local s = room.solids[i + 1] -- 511
			if not s.decorative then -- 511
				local ____self_boxes_12 = self.boxes -- 517
				local ____s_x_3 = s.x -- 518
				local ____temp_4 = s.x + s.w -- 518
				local ____s_y_5 = s.y -- 518
				local ____temp_6 = s.y + s.h -- 518
				local ____temp_1 -- 519
				if room.depth == nil then -- 519
					____temp_1 = nil -- 519
				else -- 519
					____temp_1 = s.depth -- 519
				end -- 519
				local ____temp_7 = s.passable == true -- 520
				local ____s_label_8 = s.label -- 520
				local ____s_id_9 = s.id -- 521
				local ____temp_10 = s.soft == true -- 521
				local ____temp_11 = s.hidden == true -- 521
				local ____temp_2 -- 522
				if s.breakable == nil then -- 522
					____temp_2 = nil -- 522
				else -- 522
					____temp_2 = __TS__ObjectAssign({}, s.breakable) -- 522
				end -- 522
				____self_boxes_12[#____self_boxes_12 + 1] = { -- 517
					x0 = ____s_x_3, -- 518
					x1 = ____temp_4, -- 518
					y0 = ____s_y_5, -- 518
					y1 = ____temp_6, -- 518
					depth = ____temp_1, -- 519
					passable = ____temp_7, -- 520
					label = ____s_label_8, -- 520
					id = ____s_id_9, -- 521
					soft = ____temp_10, -- 521
					hidden = ____temp_11, -- 521
					breakable = ____temp_2, -- 522
					interact = s.interact -- 523
				} -- 523
			end -- 523
			i = i + 1 -- 510
		end -- 510
	end -- 510
	do -- 510
		i = 0 -- 527
		while i < #room.stairs do -- 527
			local st = room.stairs[i + 1] -- 528
			local n = st.steps + 1 -- 529
			local stepW = (st.x1 - st.x0) / n -- 530
			local k = 0 -- 531
			do -- 531
				k = 0 -- 532
				while k < n do -- 532
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 533
					local x0 = st.x0 + stepW * k -- 534
					local ____self_boxes_13 = self.boxes -- 534
					____self_boxes_13[#____self_boxes_13 + 1] = { -- 536
						x0 = x0, -- 536
						x1 = x0 + stepW, -- 536
						y0 = -8, -- 536
						y1 = y, -- 536
						passable = true -- 536
					} -- 536
					k = k + 1 -- 532
				end -- 532
			end -- 532
			i = i + 1 -- 527
		end -- 527
	end -- 527
end -- 501
function Play.prototype.setupCampaign(self) -- 545
	local wr = self.room -- 546
	local c = wr.campaign -- 547
	if c == nil then -- 547
		return -- 549
	end -- 549
	self.roomStartTick = self.run.ticks -- 551
	if wr.key == "s1-crossroad" then -- 551
		self.run.joined = true -- 554
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 554
		local ____self_run_15 = self.run -- 557
		local ____temp_14 -- 557
		if wr.key == "s2-drygoods" then -- 557
			____temp_14 = self.run.route ~= "drygoods" -- 557
		else -- 557
			____temp_14 = false -- 557
		end -- 557
		____self_run_15.joined = ____temp_14 -- 557
	end -- 557
	local x = wr.minX + 60 -- 559
	local y = 0 -- 560
	local depth = 0 -- 561
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 561
		x = wr.minX + 210 -- 563
		depth = -32 -- 564
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 564
		x = wr.minX + 40 -- 566
		y = 32 -- 567
		depth = 32 -- 568
	end -- 568
	self.player = { -- 570
		x = x, -- 571
		y = y, -- 571
		depth = depth, -- 571
		depthSpeed = 0, -- 571
		vx = 0, -- 571
		vy = 0, -- 571
		w = SOLDIER_W, -- 572
		h = SOLDIER_H, -- 572
		onGround = y <= 0, -- 572
		facing = 1, -- 572
		crouch = false, -- 572
		rollT = 0, -- 572
		covered = false, -- 572
		alive = true -- 572
	} -- 572
	self.partner = { -- 574
		x = x + 60, -- 575
		y = y, -- 575
		depth = depth, -- 575
		depthSpeed = 0, -- 575
		vx = 0, -- 575
		vy = 0, -- 575
		w = CHILD_W, -- 576
		h = CHILD_H, -- 576
		onGround = y <= 0, -- 576
		facing = 1, -- 576
		crouch = false, -- 576
		rollT = 0, -- 576
		covered = false, -- 576
		alive = true -- 576
	} -- 576
	self.cam.x = x -- 578
	self.cam.y = y + CAM_LOOK_UP -- 579
	self.phase = "run" -- 580
	self.hp = self.maxHp -- 581
	self:buildEnemies() -- 582
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 583
	local i = 0 -- 584
	do -- 584
		i = 0 -- 585
		while i < #self.boxes do -- 585
			do -- 585
				local b = self.boxes[i + 1] -- 586
				if b.id == nil then -- 586
					goto __continue33 -- 588
				end -- 588
				local st = self.run.props[b.id] -- 590
				if st ~= nil then -- 590
					b.broken = st.broken -- 592
					local ____temp_16 -- 593
					if b.breakable == nil then -- 593
						____temp_16 = nil -- 593
					else -- 593
						____temp_16 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 593
					end -- 593
					b.breakable = ____temp_16 -- 593
					b.hidden = b.hidden == true and st.revealed ~= true -- 594
					if b.hidden then -- 594
						b.broken = true -- 596
					end -- 596
				elseif b.hidden == true then -- 596
					b.broken = true -- 600
				end -- 600
			end -- 600
			::__continue33:: -- 600
			i = i + 1 -- 585
		end -- 585
	end -- 585
	if wr.cart.bodyW > 0 then -- 585
		self.cartAxle = wr.cart.startX -- 604
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 604
			self.cartAxle = wr.cart.endX -- 606
			self.cartDocked = true -- 607
		end -- 607
	end -- 607
	do -- 607
		i = 0 -- 610
		while i < #self.pickups do -- 610
			local pk = self.pickups[i + 1] -- 611
			if self.run.taken[pk.id] == true then -- 611
				pk.id = "" -- 613
			end -- 613
			i = i + 1 -- 610
		end -- 610
	end -- 610
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 616
end -- 545
function Play.prototype.log(self, line) -- 619
	local ____self_run_log_17 = self.run.log -- 619
	____self_run_log_17[#____self_run_log_17 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 620
	if #self.run.log > 120 then -- 620
		table.remove(self.run.log, 1) -- 622
	end -- 622
end -- 619
function Play.prototype.buildEnemies(self) -- 626
	self.enemies = {} -- 627
	if self.isCampaign then -- 627
		local i = 0 -- 629
		do -- 629
			i = 0 -- 630
			while i < #self.room.spawns do -- 630
				local sp = self.room.spawns[i + 1] -- 631
				local kind = sp.kind or "gunner" -- 632
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 633
				local ____self_enemies_18 = self.enemies -- 633
				____self_enemies_18[#____self_enemies_18 + 1] = { -- 634
					x = sp.x, -- 635
					y = sp.y, -- 635
					depth = sp.depth, -- 635
					w = 26, -- 635
					h = sp.h, -- 635
					alive = true, -- 635
					hitT = 0, -- 635
					warnT = 0, -- 635
					fireCd = 40, -- 635
					kind = kind, -- 636
					shieldHp = hp, -- 636
					shieldHpMax = hp, -- 636
					drop = sp.drop or "none", -- 636
					homeX = sp.x, -- 637
					swingT = 0, -- 637
					awake = false, -- 637
					squad = i -- 637
				} -- 637
				i = i + 1 -- 630
			end -- 630
		end -- 630
		return -- 640
	end -- 640
	if self.room.key == "checkpoint" then -- 640
		local ____self_enemies_19 = self.enemies -- 640
		____self_enemies_19[#____self_enemies_19 + 1] = { -- 643
			x = self.ox + 430, -- 643
			y = 0, -- 643
			w = 26, -- 643
			h = 84, -- 643
			alive = true, -- 643
			hitT = 0, -- 643
			warnT = 0, -- 643
			fireCd = 0 -- 643
		} -- 643
		local ____self_enemies_20 = self.enemies -- 643
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 644
			x = self.ox + 505, -- 644
			y = 0, -- 644
			w = 26, -- 644
			h = 84, -- 644
			alive = true, -- 644
			hitT = 0, -- 644
			warnT = 0, -- 644
			fireCd = 0 -- 644
		} -- 644
		return -- 645
	end -- 645
	if self.room.key == "street" then -- 645
		local ____self_enemies_21 = self.enemies -- 645
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 649
			x = self.ox + 340, -- 649
			y = 0, -- 649
			w = 26, -- 649
			h = 84, -- 649
			alive = true, -- 649
			hitT = 0, -- 649
			warnT = 0, -- 649
			fireCd = 0 -- 649
		} -- 649
		local ____self_enemies_22 = self.enemies -- 649
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 650
			x = self.ox + 560, -- 650
			y = 0, -- 650
			w = 26, -- 650
			h = 84, -- 650
			alive = true, -- 650
			hitT = 0, -- 650
			warnT = 0, -- 650
			fireCd = 0 -- 650
		} -- 650
	end -- 650
end -- 626
function Play.prototype.emit(self, name, data) -- 656
	local ____self_events_23 = self.events -- 656
	____self_events_23[#____self_events_23 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 657
	self.eventSeq = self.eventSeq + 1 -- 658
	if #self.events > 256 then -- 658
		table.remove(self.events, 1) -- 660
	end -- 660
end -- 656
function Play.prototype.drainEvents(self) -- 668
	local out = self.events -- 669
	self.events = {} -- 670
	return out -- 671
end -- 668
function Play.prototype.adoptEvents(self, events) -- 680
	if #events == 0 then -- 680
		return -- 682
	end -- 682
	local keep = {} -- 684
	local i = 0 -- 685
	do -- 685
		i = 0 -- 686
		while i < #events do -- 686
			do -- 686
				local e = events[i + 1] -- 687
				if e.name == "knock" and e.data.room ~= self.room.key then -- 687
					goto __continue57 -- 689
				end -- 689
				keep[#keep + 1] = e -- 691
			end -- 691
			::__continue57:: -- 691
			i = i + 1 -- 686
		end -- 686
	end -- 686
	if #keep == 0 then -- 686
		return -- 694
	end -- 694
	self.events = __TS__ArrayConcat(keep, self.events) -- 696
	do -- 696
		i = 0 -- 697
		while i < #self.events do -- 697
			self.events[i + 1].seq = i -- 698
			i = i + 1 -- 697
		end -- 697
	end -- 697
	self.eventSeq = #self.events -- 700
end -- 680
function Play.prototype.update(self, dt, input) -- 704
	if input.pause.pressed then -- 704
		self.paused = not self.paused -- 706
	end -- 706
	if self.invulnT > 0 then -- 706
		self.invulnT = self.invulnT - 1 -- 709
	end -- 709
	if self.flashT > 0 then -- 709
		self.flashT = self.flashT - dt -- 712
		if self.flashT <= 0 then -- 712
			self.flash = "" -- 714
		end -- 714
	end -- 714
	if self.traceT > 0 then -- 714
		self.traceT = self.traceT - dt -- 718
		if self.traceT <= 0 then -- 718
			self.trace = nil -- 720
		end -- 720
	end -- 720
	if self.paused then -- 720
		self:updateCamera(dt) -- 724
		return -- 725
	end -- 725
	self.ticks = self.ticks + 1 -- 728
	if self.isCampaign then -- 728
		local ____self_run_24, ____ticks_25 = self.run, "ticks" -- 728
		____self_run_24[____ticks_25] = ____self_run_24[____ticks_25] + 1 -- 730
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 731
	end -- 731
	local p = self.player -- 733
	self:stepPlayer(p, dt, input) -- 734
	self:refreshCover(p, input) -- 736
	if self.isCampaign then -- 736
		self:stepCampaign(dt, input) -- 738
		self:stepCampaignPartner(dt) -- 739
	end -- 739
	self:stepEnemies(dt, input) -- 742
	if not self.isCampaign then -- 742
		self:stepStory(dt, input) -- 744
		self:stepEscort(dt, input) -- 745
		self:stepVillage(dt, input) -- 746
		self:stepChase(dt, input) -- 747
		self:stepInteract(dt, input) -- 748
	end -- 748
	self:updateGate() -- 750
	self:updateCamera(dt) -- 751
end -- 704
function Play.prototype.underLowArch(self, a) -- 758
	local arch = self.room.arch -- 759
	if arch.h <= 0 then -- 759
		return false -- 761
	end -- 761
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 761
		return false -- 764
	end -- 764
	local top = arch.y + arch.h -- 766
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 767
end -- 758
function Play.prototype.coverAt(self, a) -- 774
	local best = nil -- 775
	local bestGap = 24 -- 776
	local half = a.w / 2 -- 777
	local i = 0 -- 778
	do -- 778
		i = 0 -- 779
		while i < #self.boxes do -- 779
			do -- 779
				local b = self.boxes[i + 1] -- 780
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 780
					goto __continue78 -- 782
				end -- 782
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 782
					goto __continue78 -- 785
				end -- 785
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 787
				if gap < bestGap then -- 787
					bestGap = gap -- 789
					best = b -- 790
				end -- 790
			end -- 790
			::__continue78:: -- 790
			i = i + 1 -- 779
		end -- 779
	end -- 779
	return best -- 793
end -- 774
function Play.prototype.nearCover(self, a) -- 796
	return self:coverAt(a) ~= nil -- 797
end -- 796
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 801
	if enemy == nil then -- 801
		return false -- 803
	end -- 803
	local fromRight = enemy.x >= a.x -- 805
	local edge = fromRight and b.x0 or b.x1 -- 806
	local ____fromRight_26 -- 807
	if fromRight then -- 807
		____fromRight_26 = edge >= a.x - 0.001 and edge <= enemy.x -- 807
	else -- 807
		____fromRight_26 = edge <= a.x + 0.001 and edge >= enemy.x -- 808
	end -- 808
	local between = ____fromRight_26 -- 807
	local separation = enemy.x - a.x -- 809
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 810
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 811
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 812
end -- 801
function Play.prototype.nearestEnemy(self, a) -- 815
	local best -- 816
	local bestD = 1000000000 -- 817
	local i = 0 -- 818
	do -- 818
		i = 0 -- 819
		while i < #self.enemies do -- 819
			do -- 819
				local e = self.enemies[i + 1] -- 820
				if not e.alive then -- 820
					goto __continue87 -- 822
				end -- 822
				local d = math.abs(e.x - a.x) -- 824
				if d < bestD then -- 824
					bestD = d -- 826
					best = e -- 827
				end -- 827
			end -- 827
			::__continue87:: -- 827
			i = i + 1 -- 819
		end -- 819
	end -- 819
	return best -- 830
end -- 815
function Play.prototype.refreshCover(self, a, input) -- 834
	if self.childMode then -- 834
		self.coverNear = false -- 836
		self.coverHug = false -- 837
		self.coverEntity = "" -- 838
		self.coverBlocking = false -- 839
		a.covered = false -- 840
		return -- 841
	end -- 841
	local b = self:coverAt(a) -- 843
	self.coverNear = b ~= nil -- 844
	a.covered = self.coverNear and input.cover.held -- 845
	self.coverHug = a.covered -- 846
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 847
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 848
		b, -- 848
		a, -- 848
		self:nearestEnemy(a) -- 848
	) -- 848
end -- 834
function Play.prototype.cartHandleInReach(self, a) -- 852
	if a == nil then -- 852
		a = self.player -- 852
	end -- 852
	local c = self.room.cart -- 853
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 853
		return false -- 855
	end -- 855
	local handleX = self.cartAxle + c.handleOffset -- 857
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 858
end -- 852
function Play.prototype.nearLowLedge(self, a) -- 863
	local reach = 26 -- 864
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 865
	local x1 = x0 + reach -- 866
	local i = 0 -- 867
	do -- 867
		i = 0 -- 868
		while i < #self.boxes do -- 868
			do -- 868
				local b = self.boxes[i + 1] -- 869
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 869
					goto __continue96 -- 871
				end -- 871
				local rise = b.y1 - a.y -- 873
				if rise > 0 and rise <= LEDGE_RISE then -- 873
					return true -- 875
				end -- 875
			end -- 875
			::__continue96:: -- 875
			i = i + 1 -- 868
		end -- 868
	end -- 868
	return false -- 878
end -- 863
function Play.prototype.stepPlayer(self, a, dt, input) -- 881
	a.depthSpeed = 0 -- 882
	if not a.alive then -- 882
		return -- 884
	end -- 884
	local isChild = self.childMode -- 886
	local lowArch = isChild and self:underLowArch(a) -- 888
	if self:storyLocked() then -- 888
		a.vx = 0 -- 891
		a.crouch = isChild and lowArch -- 892
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 893
		self:fallY(a, dt) -- 894
		return -- 895
	end -- 895
	if not isChild and self.escort.state == "calming" then -- 895
		a.crouch = false -- 899
		a.h = SOLDIER_H -- 900
		a.vx = 0 -- 901
		self:fallY(a, dt) -- 902
		return -- 903
	end -- 903
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 905
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 906
	local nearCover = not isChild and self:nearCover(a) -- 907
	a.covered = nearCover and input.cover.held -- 908
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 910
	if a.rollT > 0 then -- 910
		a.rollT = a.rollT - dt -- 914
		a.vx = a.facing * ROLL_SPEED -- 915
		self:slideX(a, a.vx * dt) -- 916
		self:fallY(a, dt) -- 917
		if a.rollT <= 0 then -- 917
			self:flashSet("翻滚结束", 0.5) -- 919
		end -- 919
		return -- 921
	end -- 921
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 921
		if input.moveX ~= 0 then -- 921
			a.facing = input.moveX > 0 and 1 or -1 -- 926
		end -- 926
		if self:nearLowLedge(a) then -- 926
			a.vy = SOLDIER_JUMP -- 930
			a.onGround = false -- 931
			self:flashSet("翻上去", 0.3) -- 932
			return -- 933
		end -- 933
		a.rollT = ROLL_TIME -- 935
		self:flashSet("翻滚", 0.3) -- 936
		return -- 937
	end -- 937
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 940
	if isChild then -- 940
		if input.cover.held then -- 940
			speed = CHILD_SLOW -- 943
		end -- 943
		if a.crouch then -- 943
			speed = CHILD_SLOW -- 946
		end -- 946
	elseif a.covered then -- 946
		speed = SOLDIER_SPEED * 0.45 -- 949
	end -- 949
	local handsBusy = self.gripping or gripIntent -- 953
	local dir = self.gripping and 0 or input.moveX -- 954
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 955
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 956
	if dir ~= 0 then -- 956
		a.facing = dir > 0 and 1 or -1 -- 958
	end -- 958
	a.vx = dir * speed * diagonal -- 960
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 960
		a.vy = CHILD_JUMP -- 964
		a.onGround = false -- 965
		self:flashSet("跳", 0.25) -- 966
	end -- 966
	local previousDepth = a.depth -- 970
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 971
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 972
	self:slideX(a, a.vx * dt) -- 973
	self:fallY(a, dt) -- 974
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 974
		self:shoot(a) -- 978
	end -- 978
end -- 881
function Play.prototype.stepPartner(self, p, dt) -- 983
	local a = self.partner -- 984
	if not a.alive then -- 984
		return -- 986
	end -- 986
	a.crouch = false -- 988
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 989
	a.vx = 0 -- 990
	a.depthSpeed = 0 -- 991
	self:fallY(a, dt) -- 992
end -- 983
function Play.prototype.stepEscort(self, dt, input) -- 999
	local a = self.partner -- 1000
	a.depthSpeed = 0 -- 1001
	if not a.alive then -- 1001
		return -- 1003
	end -- 1003
	if not self:escortOn() then -- 1003
		a.vx = 0 -- 1006
		self:fallY(a, dt) -- 1007
		return -- 1008
	end -- 1008
	local p = self.player -- 1010
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1011
	local hadKnock1 = self.escort.knock1 -- 1012
	local hadKnock2 = self.escort.knock2 -- 1013
	self.calmConsumed = self.escort:update( -- 1014
		input, -- 1014
		p.x, -- 1014
		p.facing, -- 1014
		a.x, -- 1014
		dist -- 1014
	) -- 1014
	if not hadKnock1 and self.escort.knock1 then -- 1014
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1017
	end -- 1017
	if not hadKnock2 and self.escort.knock2 then -- 1017
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1020
	end -- 1020
	a.crouch = self.escort.crouchPose -- 1022
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1023
	if not self.escort.stopped then -- 1023
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1025
		local previousDepth = a.depth -- 1026
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1027
		local distance = math.max( -- 1028
			-travel, -- 1028
			math.min(travel, targetDepth - previousDepth) -- 1028
		) -- 1028
		self:slideDepth(a, distance) -- 1029
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1030
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1030
			a.vy = CHILD_JUMP -- 1032
			a.onGround = false -- 1033
		end -- 1033
	end -- 1033
	local dir = self.escort:moveDir(a.x) -- 1036
	a.vx = dir * CHILD_SPEED -- 1037
	if dir ~= 0 then -- 1037
		a.facing = dir -- 1039
		local before = a.x -- 1040
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1041
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1041
			a.vy = CHILD_JUMP -- 1044
			a.onGround = false -- 1045
		end -- 1045
	end -- 1045
	self:fallY(a, dt) -- 1048
end -- 999
function Play.prototype.escortOn(self) -- 1052
	if self.room.key == "checkpoint" then -- 1052
		return true -- 1054
	end -- 1054
	if self.room.key == "prologue" then -- 1054
		return self.phase == "prologue-follow" -- 1057
	end -- 1057
	return self.room.key == "street" -- 1059
end -- 1052
function Play.prototype.storyLocked(self) -- 1063
	if self.caughtT > 0 then -- 1063
		return true -- 1065
	end -- 1065
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1065
		return true -- 1068
	end -- 1068
	if self.room.key == "gate" and self.phase == "gate-count" then -- 1068
		return true -- 1071
	end -- 1071
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1071
		return true -- 1074
	end -- 1074
	return false -- 1076
end -- 1063
function Play.prototype.swapToChild(self, x) -- 1080
	local tmp = self.player -- 1081
	self.player = self.partner -- 1082
	self.partner = tmp -- 1083
	self.childMode = true -- 1084
	self.player.alive = true -- 1085
	self.player.x = self.ox + x -- 1086
	self.player.y = 0 -- 1087
	self.player.depth = 0 -- 1088
	self.player.depthSpeed = 0 -- 1089
	self.player.vy = 0 -- 1090
	self.player.vx = 0 -- 1091
	self.player.onGround = true -- 1092
	self.player.crouch = false -- 1093
	self.player.h = CHILD_H -- 1094
	self.player.facing = 1 -- 1095
	self.partner.alive = true -- 1096
	self.cam.x = self.player.x -- 1097
end -- 1080
function Play.prototype.stepStory(self, dt, input) -- 1101
	if self.room.key == "prologue" then -- 1101
		self:stepPrologue(dt, input) -- 1103
	elseif self.room.key == "street" then -- 1103
		self:stepStreet(dt, input) -- 1105
	elseif self.room.key == "gate" then -- 1105
		self:stepGate(dt, input) -- 1107
	elseif self.room.key == "tower" then -- 1107
		self:stepTower(dt, input) -- 1109
	end -- 1109
end -- 1101
function Play.prototype.stepPrologue(self, dt, input) -- 1114
	local child = self.partner -- 1115
	if self.phase == "prologue-wait" then -- 1115
		child.crouch = true -- 1117
		child.h = CHILD_CROUCH_H -- 1118
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1119
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1121
		if near and input.interact.pressed then -- 1121
			self.phase = "prologue-give" -- 1123
			self.phaseTick = 0 -- 1124
			self:flashSet("递出针套", 1) -- 1125
		end -- 1125
		return -- 1127
	end -- 1127
	if self.phase == "prologue-give" then -- 1127
		self.phaseTick = self.phaseTick + 1 -- 1130
		if self.phaseTick == 12 then -- 1130
			self:flashSet("针套递过去", 0.7) -- 1132
		elseif self.phaseTick == 36 then -- 1132
			self:flashSet("纸条塞进针套", 0.9) -- 1134
		elseif self.phaseTick >= 60 then -- 1134
			self.phase = "prologue-follow" -- 1136
			self.phaseTick = 0 -- 1137
			child.crouch = false -- 1138
			child.h = CHILD_H -- 1139
			self:flashSet("她跟上了", 1.2) -- 1140
		end -- 1140
		return -- 1142
	end -- 1142
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1142
		self:requestRoom("street", "序章跟到门口") -- 1146
		self:flashSet("进街道", 1.2) -- 1147
	end -- 1147
end -- 1114
function Play.prototype.stepStreet(self, dt, input) -- 1152
	local p = self.player -- 1153
	local c = self.partner -- 1154
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1154
		self:requestRoom("checkpoint", "两人都到街尾") -- 1156
		self:flashSet("到检查站", 1.2) -- 1157
	end -- 1157
end -- 1152
function Play.prototype.stepGate(self, dt, input) -- 1162
	local ____temp_27 -- 1163
	if self.room.story == nil then -- 1163
		____temp_27 = nil -- 1163
	else -- 1163
		____temp_27 = self.room.story.gate -- 1163
	end -- 1163
	local g = ____temp_27 -- 1163
	if g == nil then -- 1163
		return -- 1165
	end -- 1165
	local p = self.player -- 1167
	if self.phase == "gate-idle" then -- 1167
		local a = self.partner -- 1170
		local gap = g.waitX - a.x -- 1171
		if math.abs(gap) > 3 then -- 1171
			a.facing = gap > 0 and 1 or -1 -- 1173
			a.vx = a.facing * CHILD_SPEED -- 1174
			local beforeX = a.x -- 1175
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1176
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1176
				a.vy = CHILD_JUMP -- 1178
				a.onGround = false -- 1179
			end -- 1179
			self:fallY(a, dt) -- 1181
		else -- 1181
			a.vx = 0 -- 1183
			a.x = g.waitX -- 1184
		end -- 1184
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1187
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1188
		if self.gateNeedConfirm then -- 1188
			if not input.interact.held then -- 1188
				self.gateRestartArmed = true -- 1193
			end -- 1193
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1193
				self.gateNeedConfirm = false -- 1196
				self.gateRestartArmed = true -- 1197
				self.phase = "gate-hold" -- 1198
				self.gateTick = 0 -- 1199
				self.gateSpawned = 0 -- 1200
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1201
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1202
			end -- 1202
			return -- 1204
		end -- 1204
		if atWinch and atWait then -- 1204
			self.phase = "gate-hold" -- 1207
			self.gateTick = 0 -- 1208
			self.gateSpawned = 0 -- 1209
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1210
		end -- 1210
		return -- 1212
	end -- 1212
	if self.phase == "gate-hold" then -- 1212
		self.gateTick = self.gateTick + 1 -- 1215
		local marks = {0, 540, 900, 1500} -- 1217
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1217
			local idx = self.gateSpawned -- 1219
			local ____self_enemies_28 = self.enemies -- 1219
			____self_enemies_28[#____self_enemies_28 + 1] = { -- 1220
				x = self.ox + 620 + idx * 62, -- 1221
				y = 0, -- 1221
				w = 26, -- 1221
				h = 84, -- 1221
				alive = true, -- 1222
				hitT = 0, -- 1222
				warnT = 0, -- 1222
				fireCd = 90 + idx * 45 -- 1222
			} -- 1222
			self.gateSpawned = self.gateSpawned + 1 -- 1224
			self:flashSet( -- 1225
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1225
				0.9 -- 1225
			) -- 1225
		end -- 1225
		if self.gateTick == 900 then -- 1225
			self:flashSet("灯灭了", 1) -- 1228
		elseif self.gateTick == 2100 then -- 1228
			self:flashSet("门底压下来了", 1) -- 1230
		end -- 1230
		if self.gateTick >= g.holdTicks then -- 1230
			self.phase = "gate-send" -- 1233
			self.phaseTick = 0 -- 1234
			self.enemies = {} -- 1236
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1237
		end -- 1237
		return -- 1239
	end -- 1239
	if self.phase == "gate-send" then -- 1239
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1242
		if near and input.interact.pressed then -- 1242
			self:swapToChild(g.doorX + 30) -- 1244
			self.phase = "gate-count" -- 1245
			self.countTick = 0 -- 1246
			self.countArmed = false -- 1248
			self.countPrevMove = input.moveX -- 1249
			self:flashSet("门开了 · 送她出去", 1.8) -- 1250
		end -- 1250
		return -- 1252
	end -- 1252
	if self.phase == "gate-count" then -- 1252
		self.countTick = self.countTick + 1 -- 1255
		if self.countTick == 360 then -- 1255
			self:flashSet("门关上", 0.9) -- 1257
		elseif self.countTick == 1020 then -- 1257
			self:flashSet("数到一百", 2.2) -- 1259
		end -- 1259
		local prevMove = self.countPrevMove -- 1263
		self.countPrevMove = input.moveX -- 1264
		if self.countTick >= 1440 then -- 1264
			if prevMove <= 0 and input.moveX > 0 then -- 1264
				self.countArmed = true -- 1267
			end -- 1267
			if self.countArmed and input.moveX > 0 then -- 1267
				self.phase = "gate-walk" -- 1270
				self.phaseTick = 0 -- 1271
				self:flashSet("她迈出第一步", 1.4) -- 1272
			end -- 1272
		end -- 1272
		return -- 1275
	end -- 1275
	if self.player.x >= g.exitX then -- 1275
		self:requestRoom("outside", "走出城门") -- 1279
		self:flashSet("出城门 · 城外", 1.4) -- 1280
	end -- 1280
end -- 1162
function Play.prototype.stepTower(self, dt, input) -- 1285
	local ____temp_29 -- 1286
	if self.room.story == nil then -- 1286
		____temp_29 = nil -- 1286
	else -- 1286
		____temp_29 = self.room.story.tower -- 1286
	end -- 1286
	local t = ____temp_29 -- 1286
	if t == nil then -- 1286
		return -- 1288
	end -- 1288
	if self.phase == "tower-wait" then -- 1288
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1291
		if near and input.interact.pressed then -- 1291
			self.phase = "tower-knock" -- 1293
			self.phaseTick = 0 -- 1294
			self.knocks = 1 -- 1295
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1296
			self:flashSet("敲一下", 0.6) -- 1297
		end -- 1297
		return -- 1299
	end -- 1299
	if self.phase == "tower-knock" then -- 1299
		self.phaseTick = self.phaseTick + 1 -- 1302
		if self.phaseTick == 12 then -- 1302
			self.knocks = 2 -- 1304
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1305
			self:flashSet("敲两下 · 第二声", 1) -- 1306
		elseif self.phaseTick >= t.knockTicks then -- 1306
			self.phase = "tower-given" -- 1308
			self.phaseTick = 0 -- 1309
			self:flashSet("门开了 · 提灯", 1.4) -- 1310
		end -- 1310
		return -- 1312
	end -- 1312
	if self.phase == "tower-given" then -- 1312
		self.phaseTick = self.phaseTick + 1 -- 1315
		if self.phaseTick == 60 then -- 1315
			self:flashSet("她递出针套和纸条", 1.6) -- 1317
		elseif self.phaseTick == 120 then -- 1317
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1319
		elseif self.phaseTick >= 180 then -- 1319
			self.phase = "tower-end" -- 1321
			self.phaseTick = 0 -- 1322
			self:flashSet("片尾 · E 再玩一次", 3) -- 1323
		end -- 1323
		return -- 1325
	end -- 1325
	if input.interact.pressed or input.retry.pressed then -- 1325
		self:requestRoom("prologue", "片尾再玩") -- 1328
		self:flashSet("回到序章", 1.4) -- 1329
	end -- 1329
end -- 1285
function Play.prototype.stepChase(self, dt, input) -- 1334
	if self.caughtT > 0 then -- 1334
		self.caughtT = self.caughtT - dt -- 1336
		if self.caughtT <= 0 then -- 1336
			self:recoverFromCaught() -- 1338
		end -- 1338
		return -- 1340
	end -- 1340
	if self.room.key == "village" then -- 1340
		self:stepScavChase() -- 1343
	elseif self.room.key == "forest" then -- 1343
		self:stepDog(dt) -- 1345
		if self.player.x >= self.ox + 1450 then -- 1345
			self:requestRoom("tower", "到林缘北塔") -- 1348
			self:flashSet("林缘 · 北塔", 1.4) -- 1349
		end -- 1349
	end -- 1349
end -- 1334
function Play.prototype.stepScavChase(self) -- 1355
	local s = self.room.scavenger -- 1356
	if s == nil then -- 1356
		return -- 1358
	end -- 1358
	local p = self.player -- 1360
	if self.passed and p.x > self.ox + 440 then -- 1360
		if self.scavChase then -- 1360
			self.scavChase = false -- 1364
			self.scavState = "back" -- 1365
			self.scavT = 0 -- 1366
		end -- 1366
		return -- 1368
	end -- 1368
	local dx = p.x - self.scavX -- 1370
	local dist = math.abs(dx) -- 1371
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1372
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1373
	if not self.scavChase then -- 1373
		if visible then -- 1373
			self.scavSee = self.scavSee + 1 -- 1376
			if self.scavSee >= 24 then -- 1376
				self.scavChase = true -- 1378
				self.scavState = "chase" -- 1379
				self.scavTargetX = p.x -- 1380
				self:flashSet("他看见你了", 1.2) -- 1381
			end -- 1381
		else -- 1381
			self.scavSee = 0 -- 1384
		end -- 1384
		return -- 1386
	end -- 1386
	local dir = p.x > self.scavX and 1 or -1 -- 1389
	self.scavX = self.scavX + dir * 96 / 60 -- 1390
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1390
		self:caught() -- 1392
		return -- 1393
	end -- 1393
	if hidden then -- 1393
		self.scavSee = 0 -- 1397
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1398
		self.scavT = self.scavT - 1 -- 1399
		if self.scavT <= 0 then -- 1399
			self.scavChase = false -- 1401
			self.scavState = "patrol" -- 1402
			self:flashSet("他失去了目标", 1) -- 1403
		end -- 1403
	end -- 1403
end -- 1355
function Play.prototype.stepDog(self, dt) -- 1409
	local ____temp_30 -- 1410
	if self.room.story == nil then -- 1410
		____temp_30 = nil -- 1410
	else -- 1410
		____temp_30 = self.room.story.dog -- 1410
	end -- 1410
	local dog = ____temp_30 -- 1410
	if dog == nil then -- 1410
		return -- 1412
	end -- 1412
	local p = self.player -- 1414
	local dist = math.abs(p.x - self.dogX) -- 1415
	if self.dogState == "patrol" then -- 1415
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1417
		if self.dogX < dog.x0 then -- 1417
			self.dogX = dog.x0 -- 1419
			self.dogDir = 1 -- 1420
		elseif self.dogX > dog.x1 then -- 1420
			self.dogX = dog.x1 -- 1422
			self.dogDir = -1 -- 1423
		end -- 1423
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1425
		if not p.crouch and moving and dist < dog.range then -- 1425
			self.dogState = "ear" -- 1427
			self.dogT = 18 -- 1428
			self.dogTargetX = p.x -- 1429
			self:flashSet("狗转耳朵", 0.8) -- 1430
		end -- 1430
		return -- 1432
	end -- 1432
	if self.dogState == "ear" then -- 1432
		self.dogT = self.dogT - 1 -- 1435
		if self.dogT <= 0 then -- 1435
			self.dogState = "chase" -- 1437
			self.dogTargetX = p.x -- 1438
			self:flashSet("狗追来了", 1.4) -- 1439
		end -- 1439
		return -- 1441
	end -- 1441
	if self.dogState == "chase" then -- 1441
		local dir = p.x > self.dogX and 1 or -1 -- 1444
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1445
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1445
			self:caught() -- 1447
			self.dogState = "sniff" -- 1448
			self.dogT = 60 -- 1449
		elseif dist > dog.range * 1.5 or p.crouch then -- 1449
			self.dogState = "sniff" -- 1451
			self.dogT = 60 -- 1452
			self:flashSet("狗停下了", 0.9) -- 1453
		end -- 1453
		return -- 1455
	end -- 1455
	if self.dogState == "sniff" then -- 1455
		self.dogT = self.dogT - 1 -- 1458
		if self.dogT <= 0 then -- 1458
			self.dogState = "back" -- 1460
		end -- 1460
		return -- 1462
	end -- 1462
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1465
	self.dogX = self.dogX + dir * dog.speed * dt -- 1466
	if math.abs(self.dogX - dog.x0) < 2 then -- 1466
		self.dogX = dog.x0 -- 1468
		self.dogState = "patrol" -- 1469
	end -- 1469
end -- 1409
function Play.prototype.caught(self) -- 1473
	self.caughtT = 1 -- 1474
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1475
end -- 1473
function Play.prototype.recoverFromCaught(self) -- 1479
	local p = self.player -- 1480
	p.x = self.ox + 140 -- 1481
	p.y = 0 -- 1482
	p.vy = 0 -- 1483
	p.vx = 0 -- 1484
	p.onGround = true -- 1485
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1485
		self.scavX = self.room.scavenger.x0 -- 1487
		self.scavState = "patrol" -- 1488
		self.scavSee = 0 -- 1489
		self.scavChase = false -- 1490
		self.scavT = 0 -- 1491
	end -- 1491
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1491
		self.dogX = self.room.story.dog.x0 -- 1494
		self.dogState = "patrol" -- 1495
		self.dogT = 0 -- 1496
	end -- 1496
	self.cam.x = p.x -- 1498
	self.cam.y = p.y + CAM_LOOK_UP -- 1499
	self:flashSet("回到安全点", 1.2) -- 1500
end -- 1479
function Play.prototype.updateGate(self) -- 1504
	if self.room.key ~= "checkpoint" then -- 1504
		self.gateOpen = false -- 1506
		return -- 1507
	end -- 1507
	local function inZone(x) -- 1509
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1509
	end -- 1509
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1510
end -- 1504
function Play.prototype.addItem(self, kind) -- 1516
	local inv = self.run.inventory -- 1517
	if kind == "shield" then -- 1517
		inv.shield = inv.shield + 1 -- 1519
	elseif kind == "wedge" then -- 1519
		inv.wedge = inv.wedge + 1 -- 1521
	elseif kind == "ammo" then -- 1521
		inv.ammo = inv.ammo + 1 -- 1523
	elseif kind == "pass" then -- 1523
		inv.pass = inv.pass + 1 -- 1525
	elseif kind == "quickbelt" then -- 1525
		inv.quickbelt = inv.quickbelt + 1 -- 1527
	end -- 1527
end -- 1516
function Play.prototype.findBox(self, id) -- 1531
	local i = 0 -- 1532
	do -- 1532
		i = 0 -- 1533
		while i < #self.boxes do -- 1533
			if self.boxes[i + 1].id == id then -- 1533
				return self.boxes[i + 1] -- 1535
			end -- 1535
			i = i + 1 -- 1533
		end -- 1533
	end -- 1533
	return nil -- 1538
end -- 1531
function Play.prototype.nearBox(self, b, reach) -- 1541
	local p = self.player -- 1542
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 1543
end -- 1541
function Play.prototype.findInteract(self) -- 1549
	local p = self.player -- 1550
	local best = nil -- 1551
	local bestD = 1000000000 -- 1552
	local i = 0 -- 1553
	do -- 1553
		i = 0 -- 1554
		while i < #self.boxes do -- 1554
			do -- 1554
				local b = self.boxes[i + 1] -- 1555
				if b.interact == nil or b.broken == true then -- 1555
					goto __continue237 -- 1557
				end -- 1557
				if not self:nearBox(b, b.interact.reach or 27) then -- 1557
					goto __continue237 -- 1560
				end -- 1560
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 1562
				if d < bestD then -- 1562
					bestD = d -- 1564
					best = b -- 1565
				end -- 1565
			end -- 1565
			::__continue237:: -- 1565
			i = i + 1 -- 1554
		end -- 1554
	end -- 1554
	return best -- 1568
end -- 1549
function Play.prototype.stepCampaign(self, dt, input) -- 1572
	local wr = self.room -- 1573
	local p = self.player -- 1574
	if self.reloadT > 0 then -- 1574
		self.reloadT = self.reloadT - 1 -- 1576
	end -- 1576
	if self.bracedShield ~= nil then -- 1576
		self.bracedShield.x = p.x + p.facing * 26 -- 1580
		self.bracedShield.y = p.y -- 1581
		local shBox = __TS__ArrayFind( -- 1582
			self.boxes, -- 1582
			function(____, b) return b.id == "braced_shield" end -- 1582
		) -- 1582
		if shBox ~= nil then -- 1582
			shBox.x0 = self.bracedShield.x - 15 -- 1584
			shBox.x1 = self.bracedShield.x + 15 -- 1585
			shBox.y0 = self.bracedShield.y -- 1586
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 1587
		end -- 1587
	end -- 1587
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 1587
		self.run.route = "drygoods" -- 1593
		self.run.joined = false -- 1594
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 1595
		self:log("转布行线") -- 1596
	end -- 1596
	local i = 0 -- 1599
	do -- 1599
		i = 0 -- 1600
		while i < #self.pickups do -- 1600
			do -- 1600
				local pk = self.pickups[i + 1] -- 1601
				if pk.id == "" or self.run.taken[pk.id] == true then -- 1601
					goto __continue248 -- 1603
				end -- 1603
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 1605
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 1606
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 1606
					self.run.taken[pk.id] = true -- 1608
					self:addItem(pk.kind) -- 1609
					pk.id = "" -- 1610
					self:flashSet("拾取 " .. pk.label, 1) -- 1611
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 1612
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 1613
				end -- 1613
			end -- 1613
			::__continue248:: -- 1613
			i = i + 1 -- 1600
		end -- 1600
	end -- 1600
	if input.interact.pressed then -- 1600
		self:campaignInteract() -- 1617
	end -- 1617
	self:stepCampaignCart(dt, input) -- 1619
	self:stepCampaignGoal() -- 1620
end -- 1572
function Play.prototype.campaignInteract(self) -- 1624
	local b = self:findInteract() -- 1625
	if b ~= nil then -- 1625
		self:useInteract(b) -- 1627
		return -- 1628
	end -- 1628
	local inv = self.run.inventory -- 1630
	if inv.wedge > 0 then -- 1630
		local w = self:findBox("s2_wood") -- 1632
		if w ~= nil and w.broken ~= true and self:nearBox(w, 26) then -- 1632
			if w.breakable ~= nil then -- 1632
				local ____w_breakable_31, ____hp_32 = w.breakable, "hp" -- 1632
				____w_breakable_31[____hp_32] = ____w_breakable_31[____hp_32] + (w.breakable.wedgeHp or 1) -- 1635
			end -- 1635
			inv.wedge = inv.wedge - 1 -- 1637
			self.run.props.s2_wood = {broken = false, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 1638
			self:flashSet("钉木楔 · 薄木挡多承一次", 1.2) -- 1639
			self:log("加固薄木挡") -- 1640
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 1641
			return -- 1642
		end -- 1642
	end -- 1642
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 1642
		local p = self.player -- 1647
		self.bracedShield = { -- 1648
			x = p.x + p.facing * 26, -- 1648
			y = p.y, -- 1648
			w = 30, -- 1648
			h = 64, -- 1648
			hp = 1 -- 1648
		} -- 1648
		local ____self_boxes_33 = self.boxes -- 1648
		____self_boxes_33[#____self_boxes_33 + 1] = { -- 1649
			x0 = self.bracedShield.x - 15, -- 1650
			x1 = self.bracedShield.x + 15, -- 1650
			y0 = p.y, -- 1651
			y1 = p.y + 64, -- 1651
			depth = {min = -46, max = 46}, -- 1651
			label = "架起的残盾", -- 1651
			id = "braced_shield", -- 1651
			soft = true -- 1652
		} -- 1652
		inv.shield = inv.shield - 1 -- 1655
		self:flashSet("架残盾 · 挡一发", 1.2) -- 1656
		self:log("架残盾") -- 1657
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 1658
		return -- 1659
	end -- 1659
	if inv.pass > 0 and self.run.joined == false then -- 1659
		inv.pass = inv.pass - 1 -- 1662
		self.run.joined = true -- 1663
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 1664
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 1665
		return -- 1666
	end -- 1666
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 1668
end -- 1624
function Play.prototype.useInteract(self, b) -- 1671
	local kind = b.interact == nil and "" or b.interact.kind -- 1672
	local wr = self.room -- 1673
	if kind == "open_board" then -- 1673
		b.broken = true -- 1675
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 1676
		for ____, cover in ipairs(self.boxes) do -- 1677
			if cover.id == "s2_board_cover" then -- 1677
				cover.broken = false -- 1679
				cover.hidden = false -- 1680
			end -- 1680
		end -- 1680
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 1683
		self.run.joined = true -- 1684
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 1685
		self:log("放下窗板") -- 1686
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 1687
		return -- 1688
	end -- 1688
	if kind == "lower_curtain" then -- 1688
		for ____, curtain in ipairs(self.boxes) do -- 1691
			if curtain.id == "c2_curtain" then -- 1691
				curtain.broken = false -- 1693
				curtain.hidden = false -- 1694
			end -- 1694
		end -- 1694
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 1697
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 1698
		self:log("放下木帘") -- 1699
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 1700
		return -- 1701
	end -- 1701
	if kind == "raise_latch" then -- 1701
		if wr.key == "c2-granary" and not self.cartDocked then -- 1701
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 1705
			return -- 1706
		end -- 1706
		b.broken = true -- 1708
		self.objectiveDone = true -- 1709
		if wr.key == "c1-yard" then -- 1709
			self.run.c1Latch = true -- 1712
			self.run.joined = true -- 1713
		else -- 1713
			self.run.c2Latch = true -- 1715
			self.run.joined = true -- 1716
		end -- 1716
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 1718
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 1719
		self:log("抬闩") -- 1720
		self:flashSet("抬闩 · 通路打开", 1.4) -- 1721
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 1722
	end -- 1722
end -- 1671
function Play.prototype.stepCampaignCart(self, dt, input) -- 1727
	local wr = self.room -- 1728
	local c = wr.cart -- 1729
	if c.bodyW <= 0 then -- 1729
		return -- 1731
	end -- 1731
	local p = self.player -- 1733
	local handleX = self.cartAxle + c.handleOffset -- 1734
	if not self.gripping then -- 1734
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 1734
			self.gripping = true -- 1738
			self:flashSet("握住车柄 · A/D 推", 1) -- 1739
		end -- 1739
		return -- 1741
	end -- 1741
	if input.interact.pressed then -- 1741
		self.gripping = false -- 1744
		self:flashSet("松手", 0.5) -- 1745
		return -- 1746
	end -- 1746
	if not self.cartDocked then -- 1746
		if input.moveX ~= 0 and not self:stuckCart() then -- 1746
			self.cartAxle = math.max( -- 1750
				c.startX, -- 1750
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 1750
			) -- 1750
		end -- 1750
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 1750
			self.cartExposed = true -- 1755
			local gun = nil -- 1756
			local gi = 0 -- 1757
			do -- 1757
				gi = 0 -- 1758
				while gi < #self.enemies do -- 1758
					local e = self.enemies[gi + 1] -- 1759
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 1759
						gun = e -- 1761
						break -- 1762
					end -- 1762
					gi = gi + 1 -- 1758
				end -- 1758
			end -- 1758
			if gun ~= nil then -- 1758
				self:campaignEnemyFire(gun) -- 1766
			end -- 1766
		end -- 1766
		p.x = self.cartAxle + c.handleOffset -- 1769
		p.y = c.baseY + (c.depth or 0) -- 1770
		p.vx = 0 -- 1771
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 1771
			self.cartAxle = c.endX -- 1773
			self.cartDocked = true -- 1774
			self.gripping = false -- 1775
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 1776
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 1777
			self:flashSet("车轮入窝", 1.2) -- 1778
			self:log("车轮入窝") -- 1779
		end -- 1779
	end -- 1779
end -- 1727
function Play.prototype.stuckCart(self) -- 1785
	local i = 0 -- 1786
	do -- 1786
		i = 0 -- 1787
		while i < #self.boxes do -- 1787
			do -- 1787
				local b = self.boxes[i + 1] -- 1788
				if b.broken == true or b.breakable == nil or b.soft == true then -- 1788
					goto __continue287 -- 1790
				end -- 1790
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 1792
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 1792
					return true -- 1794
				end -- 1794
			end -- 1794
			::__continue287:: -- 1794
			i = i + 1 -- 1787
		end -- 1787
	end -- 1787
	return false -- 1797
end -- 1785
function Play.prototype.stepCampaignGoal(self) -- 1801
	local wr = self.room -- 1802
	local c = wr.campaign -- 1803
	if c == nil then -- 1803
		return -- 1805
	end -- 1805
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 1805
		self.objectiveDone = true -- 1808
	end -- 1808
	if c.goal == "reach_exit" then -- 1808
		self.objectiveDone = true -- 1811
	end -- 1811
	if not self.objectiveDone then -- 1811
		return -- 1814
	end -- 1814
	local p = self.player -- 1816
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 1817
	if p.x < c.exitX or not partnerOk then -- 1817
		return -- 1819
	end -- 1819
	if c.next ~= nil and c.next ~= "" then -- 1819
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 1822
		self:flashSet("过关 · " .. c.next, 1.2) -- 1823
	elseif not self.run.finished then -- 1823
		self.run.finished = true -- 1825
		self:flashSet( -- 1826
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 1826
			2 -- 1826
		) -- 1826
		self:log("C2 灰盒完成") -- 1827
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 1828
	end -- 1828
end -- 1801
function Play.prototype.stepCampaignPartner(self, dt) -- 1833
	local a = self.partner -- 1834
	local wr = self.room -- 1835
	local cp = wr.companion -- 1836
	if not a.alive then -- 1836
		return -- 1838
	end -- 1838
	local p = self.player -- 1840
	local wait = false -- 1841
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 1842
	local targetDepth = p.depth -- 1843
	if self.run.joined == false then -- 1843
		wait = true -- 1845
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1846
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1847
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 1847
		wait = true -- 1849
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1850
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1851
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 1851
		wait = true -- 1853
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1854
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1855
	end -- 1855
	if self.partnerStuck > 0.3 then -- 1855
		a.x = a.x - a.facing * 30 -- 1859
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 1860
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 1861
		self.partnerLaneHold = 1.1 -- 1862
		self.partnerStuck = 0 -- 1863
	end -- 1863
	if self.partnerLaneHold > 0 then -- 1863
		self.partnerLaneHold = self.partnerLaneHold - dt -- 1866
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 1867
	end -- 1867
	local dx = targetX - a.x -- 1869
	if not wait and math.abs(dx) > 74 then -- 1869
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 1871
		local before = a.x -- 1872
		a.vx = dx > 0 and speed or -speed -- 1873
		a.facing = dx > 0 and 1 or -1 -- 1874
		self:slideX(a, a.vx * dt) -- 1875
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 1875
			a.vy = CHILD_JUMP -- 1878
			a.onGround = false -- 1879
		end -- 1879
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 1881
	else -- 1881
		a.vx = 0 -- 1883
		self.partnerStuck = 0 -- 1884
	end -- 1884
	local dz = targetDepth - a.depth -- 1886
	if math.abs(dz) > 6 then -- 1886
		local step = math.max( -- 1888
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 1888
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 1888
		) -- 1888
		a.depth = a.depth + step -- 1889
	end -- 1889
	a.depthSpeed = 0 -- 1891
	a.h = CHILD_H -- 1892
	a.crouch = false -- 1893
	self:fallY(a, dt) -- 1894
end -- 1833
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 1898
	local p = self.player -- 1899
	local i = 0 -- 1900
	do -- 1900
		i = 0 -- 1901
		while i < #self.enemies do -- 1901
			do -- 1901
				local e = self.enemies[i + 1] -- 1902
				if not e.alive then -- 1902
					goto __continue311 -- 1904
				end -- 1904
				if e.hitT > 0 then -- 1904
					e.hitT = e.hitT - dt -- 1907
				end -- 1907
				if e.kind == "breaker" then -- 1907
					self:stepBreaker(e, dt) -- 1910
					goto __continue311 -- 1911
				end -- 1911
				if e.kind == "shield" then -- 1911
					self:stepShield(e, dt, input) -- 1914
					goto __continue311 -- 1915
				end -- 1915
				local dx = e.x - p.x -- 1918
				if not e.awake then -- 1918
					if math.abs(dx) > 520 then -- 1918
						goto __continue311 -- 1921
					end -- 1921
					e.awake = true -- 1923
					e.fireCd = 48 -- 1924
					goto __continue311 -- 1925
				end -- 1925
				if math.abs(dx) > ENEMY_RANGE then -- 1925
					goto __continue311 -- 1928
				end -- 1928
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 1928
					goto __continue311 -- 1933
				end -- 1933
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 1933
					goto __continue311 -- 1936
				end -- 1936
				if self:blockedShot(e, p) then -- 1936
					if e.warnT > 0 then -- 1936
						e.warnT = 0 -- 1942
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 1943
					end -- 1943
					goto __continue311 -- 1945
				end -- 1945
				if e.warnT > 0 then -- 1945
					e.warnT = e.warnT - 1 -- 1948
					if e.warnT <= 0 then -- 1948
						self:campaignEnemyFire(e) -- 1950
					end -- 1950
				elseif e.fireCd > 0 then -- 1950
					e.fireCd = e.fireCd - 1 -- 1953
					if e.fireCd <= 0 then -- 1953
						e.warnT = WARN_TICKS -- 1955
					end -- 1955
				else -- 1955
					e.fireCd = 40 -- 1958
				end -- 1958
			end -- 1958
			::__continue311:: -- 1958
			i = i + 1 -- 1901
		end -- 1901
	end -- 1901
end -- 1898
function Play.prototype.blockedShot(self, e, p) -- 1964
	local eDepth = e.depth or 0 -- 1965
	local ex = e.x -- 1966
	local ey = e.y + e.h * 0.62 -- 1968
	local px = p.x -- 1969
	local py = p.y + p.h * 0.55 -- 1970
	local dx = px - ex -- 1971
	local dyScreen = py + p.depth - (ey + eDepth) -- 1972
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 1973
	if len < 0.01 then -- 1973
		return false -- 1975
	end -- 1975
	local ray = { -- 1979
		x = ex, -- 1980
		y = ey, -- 1980
		dx = dx / len, -- 1981
		dy = (py - ey) / len, -- 1981
		depth = eDepth, -- 1982
		dDepth = (p.depth - eDepth) / len -- 1982
	} -- 1982
	local best = -1 -- 1984
	local j = 0 -- 1985
	do -- 1985
		j = 0 -- 1986
		while j < #self.boxes do -- 1986
			do -- 1986
				local b = self.boxes[j + 1] -- 1987
				if b.broken == true or b.passable == true then -- 1987
					goto __continue331 -- 1989
				end -- 1989
				if b.id == "braced_shield" then -- 1989
					goto __continue331 -- 1994
				end -- 1994
				local t = hitBox(ray, b) -- 1996
				if t >= 0 and t < len - 2 and (best < 0 or t < best) then -- 1996
					best = t -- 1998
				end -- 1998
			end -- 1998
			::__continue331:: -- 1998
			j = j + 1 -- 1986
		end -- 1986
	end -- 1986
	return best >= 0 -- 2001
end -- 1964
function Play.prototype.campaignEnemyFire(self, e) -- 2004
	local p = self.player -- 2005
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2006
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 2006
		local ____self_bracedShield_34, ____hp_35 = self.bracedShield, "hp" -- 2006
		____self_bracedShield_34[____hp_35] = ____self_bracedShield_34[____hp_35] - 1 -- 2008
		self.boxes = __TS__ArrayFilter( -- 2009
			self.boxes, -- 2009
			function(____, b) return b.id ~= "braced_shield" end -- 2009
		) -- 2009
		self.bracedShield = nil -- 2010
		self:flashSet("残盾碎 · 挡下一发", 1) -- 2011
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 2012
		return -- 2013
	end -- 2013
	if self:blockedShot(e, p) then -- 2013
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 2016
		return -- 2017
	end -- 2017
	local cover = self:blockedByCover(e, p) -- 2019
	if cover ~= nil and self.coverHug then -- 2019
		self.coveredFlash = 0.5 -- 2021
		self:flashSet("掩体挡下", 0.6) -- 2022
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2023
		return -- 2028
	end -- 2028
	if self.invulnT > 0 then -- 2028
		return -- 2031
	end -- 2031
	self.invulnT = INVULN_HIT_TICKS -- 2033
	self.hp = self.hp - 1 -- 2034
	self:emit("actorHit", { -- 2035
		target = "player", -- 2035
		amount = 1, -- 2035
		hp = self.hp, -- 2035
		maxHp = self.maxHp, -- 2035
		enemyX = e.x -- 2035
	}) -- 2035
	self:flashSet( -- 2036
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2036
		0.8 -- 2036
	) -- 2036
	if self.hp <= 0 then -- 2036
		self:campaignFailed() -- 2038
	end -- 2038
end -- 2004
function Play.prototype.stepShield(self, e, dt, input) -- 2043
	local p = self.player -- 2044
	local dx = p.x - e.x -- 2045
	local adx = math.abs(dx) -- 2046
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 2049
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 2050
	if adx > 150 then -- 2050
		local before = e.x -- 2052
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 2053
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 2053
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2056
		end -- 2056
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 2056
		if p.rollT <= 0 and self.invulnT <= 0 then -- 2056
			self.invulnT = INVULN_HIT_TICKS -- 2060
			self.hp = self.hp - 1 -- 2061
			self:emit("actorHit", { -- 2062
				target = "player", -- 2062
				amount = 1, -- 2062
				hp = self.hp, -- 2062
				maxHp = self.maxHp, -- 2062
				enemyX = e.x -- 2062
			}) -- 2062
			self:flashSet( -- 2063
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2063
				0.8 -- 2063
			) -- 2063
			if self.hp <= 0 then -- 2063
				self:campaignFailed() -- 2065
				return -- 2066
			end -- 2066
		end -- 2066
		e.swingT = 70 -- 2069
	end -- 2069
	if (e.swingT or 0) > 0 then -- 2069
		e.swingT = (e.swingT or 0) - 1 -- 2072
	end -- 2072
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 2072
		local dd = p.depth - (e.depth or 0) -- 2075
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 2076
	end -- 2076
end -- 2043
function Play.prototype.stepBreaker(self, e, dt) -- 2081
	local p = self.player -- 2082
	if e.awake ~= true then -- 2082
		if math.abs(p.x - e.x) < 560 then -- 2082
			e.awake = true -- 2085
		else -- 2085
			return -- 2087
		end -- 2087
	end -- 2087
	local target = nil -- 2090
	local bestD = 1000000000 -- 2091
	local i = 0 -- 2092
	do -- 2092
		i = 0 -- 2093
		while i < #self.boxes do -- 2093
			do -- 2093
				local b = self.boxes[i + 1] -- 2094
				if b.breakable == nil or b.broken == true then -- 2094
					goto __continue355 -- 2096
				end -- 2096
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 2098
				if d < bestD then -- 2098
					bestD = d -- 2100
					target = b -- 2101
				end -- 2101
			end -- 2101
			::__continue355:: -- 2101
			i = i + 1 -- 2093
		end -- 2093
	end -- 2093
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 2104
	local dx = tx - e.x -- 2105
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 2106
	if math.abs(dx) > reach then -- 2106
		local before = e.x -- 2108
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 2109
		if math.abs(e.x - before) < 0.3 then -- 2109
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2111
		end -- 2111
	elseif (e.swingT or 0) <= 0 then -- 2111
		e.swingT = 64 -- 2114
		if target ~= nil then -- 2114
			self:damageProp(target, 2) -- 2116
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 2116
			self.invulnT = INVULN_HIT_TICKS -- 2118
			self.hp = self.hp - 1 -- 2119
			self:emit("actorHit", { -- 2120
				target = "player", -- 2120
				amount = 1, -- 2120
				hp = self.hp, -- 2120
				maxHp = self.maxHp, -- 2120
				enemyX = e.x -- 2120
			}) -- 2120
			self:flashSet("破障手近身", 0.8) -- 2121
			if self.hp <= 0 then -- 2121
				self:campaignFailed() -- 2123
				return -- 2124
			end -- 2124
		end -- 2124
	end -- 2124
	if (e.swingT or 0) > 0 then -- 2124
		e.swingT = (e.swingT or 0) - 1 -- 2129
	end -- 2129
end -- 2081
function Play.prototype.campaignFailed(self) -- 2133
	local p = self.player -- 2134
	self.hp = self.maxHp -- 2135
	self.invulnT = INVULN_RESPAWN_TICKS -- 2136
	self.reloadT = 0 -- 2137
	self.gripping = false -- 2138
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 2139
	self:log("被击倒") -- 2140
	p.x = self.room.minX + 90 -- 2141
	p.y = 0 -- 2142
	p.depth = 0 -- 2143
	p.vx = 0 -- 2144
	p.vy = 0 -- 2145
	p.onGround = true -- 2146
	p.rollT = 0 -- 2147
	self.partner.x = p.x - 50 -- 2148
	self.partner.y = 0 -- 2149
	self.partner.depth = 0 -- 2150
	self.cam.x = p.x -- 2151
	local i = 0 -- 2152
	do -- 2152
		i = 0 -- 2153
		while i < #self.enemies do -- 2153
			do -- 2153
				local e = self.enemies[i + 1] -- 2154
				if not e.alive then -- 2154
					goto __continue367 -- 2156
				end -- 2156
				e.x = e.homeX == nil and e.x or e.homeX -- 2158
				e.warnT = 0 -- 2159
				e.fireCd = 40 -- 2160
				e.swingT = 0 -- 2161
				e.awake = false -- 2162
			end -- 2162
			::__continue367:: -- 2162
			i = i + 1 -- 2153
		end -- 2153
	end -- 2153
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 2164
end -- 2133
function Play.prototype.stepEnemies(self, dt, input) -- 2167
	local i = 0 -- 2168
	do -- 2168
		i = 0 -- 2169
		while i < #self.enemies do -- 2169
			local e = self.enemies[i + 1] -- 2170
			if e.hitT > 0 then -- 2170
				e.hitT = e.hitT - dt -- 2172
			end -- 2172
			i = i + 1 -- 2169
		end -- 2169
	end -- 2169
	if self.coveredFlash > 0 then -- 2169
		self.coveredFlash = self.coveredFlash - dt -- 2176
	end -- 2176
	if self.isCampaign then -- 2176
		self:stepCampaignEnemies(dt, input) -- 2179
		return -- 2180
	end -- 2180
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 2180
		return -- 2184
	end -- 2184
	do -- 2184
		i = 0 -- 2186
		while i < #self.enemies do -- 2186
			do -- 2186
				local e = self.enemies[i + 1] -- 2187
				if not e.alive then -- 2187
					goto __continue377 -- 2189
				end -- 2189
				if e.warnT > 0 then -- 2189
					e.warnT = e.warnT - 1 -- 2192
					if e.warnT <= 0 then -- 2192
						self:enemyFire(e, input) -- 2194
					end -- 2194
					goto __continue377 -- 2196
				end -- 2196
				if e.fireCd > 0 then -- 2196
					e.fireCd = e.fireCd - 1 -- 2199
					if e.fireCd <= 0 then -- 2199
						e.warnT = WARN_TICKS -- 2201
					end -- 2201
				else -- 2201
					e.warnT = WARN_TICKS -- 2205
				end -- 2205
			end -- 2205
			::__continue377:: -- 2205
			i = i + 1 -- 2186
		end -- 2186
	end -- 2186
end -- 2167
function Play.prototype.enemyFire(self, e, input) -- 2211
	local p = self.player -- 2212
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 2212
		self:flashSet("枪声响在远处", 0.4) -- 2214
		e.fireCd = FIRE_COOLDOWN -- 2215
		return -- 2216
	end -- 2216
	local cover = self:blockedByCover(e, p) -- 2219
	local hugging = cover ~= nil -- 2220
	self.coverBlocking = hugging -- 2221
	local covered = hugging and input.cover.held -- 2222
	if covered then -- 2222
		self.coveredFlash = 0.5 -- 2224
		self:flashSet("掩体挡下", 0.5) -- 2225
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2226
		e.fireCd = FIRE_COOLDOWN -- 2231
		return -- 2232
	end -- 2232
	self.hp = self.hp - 1 -- 2234
	self:emit("actorHit", { -- 2235
		target = "player", -- 2235
		amount = 1, -- 2235
		hp = self.hp, -- 2235
		maxHp = self.maxHp, -- 2235
		enemyX = e.x -- 2235
	}) -- 2235
	self:flashSet( -- 2236
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2236
		0.7 -- 2236
	) -- 2236
	e.fireCd = FIRE_COOLDOWN -- 2237
	if self.hp <= 0 then -- 2237
		self:gateFailed() -- 2239
	end -- 2239
end -- 2211
function Play.prototype.blockedByCover(self, enemy, p) -- 2244
	local b = self:coverAt(p) -- 2245
	if b == nil then -- 2245
		return nil -- 2247
	end -- 2247
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 2249
end -- 2244
function Play.prototype.gateFailed(self) -- 2253
	local ____temp_36 -- 2254
	if self.room.story == nil then -- 2254
		____temp_36 = nil -- 2254
	else -- 2254
		____temp_36 = self.room.story.gate -- 2254
	end -- 2254
	local g = ____temp_36 -- 2254
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 2255
	self.hp = self.maxHp -- 2256
	self.gateTick = 0 -- 2257
	self.gateSpawned = 0 -- 2258
	self.enemies = {} -- 2259
	self.gateFailCount = self.gateFailCount + 1 -- 2260
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 2262
	self.player.y = 0 -- 2263
	self.player.vy = 0 -- 2264
	self.player.depth = 0 -- 2265
	self.player.depthSpeed = 0 -- 2266
	self.player.onGround = true -- 2267
	self.player.crouch = false -- 2268
	self.player.h = SOLDIER_H -- 2269
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 2270
	self.partner.y = 0 -- 2271
	self.partner.vy = 0 -- 2272
	self.partner.depth = 0 -- 2273
	self.partner.depthSpeed = 0 -- 2274
	self.partner.onGround = true -- 2275
	self.cam.x = self.player.x -- 2276
	self.phase = "gate-idle" -- 2277
	self.phaseTick = 0 -- 2278
	self.coverHug = false -- 2279
	self.coverBlocking = false -- 2280
	self.coverEntity = "" -- 2281
	self.gateNeedConfirm = true -- 2282
	self.gateRestartArmed = false -- 2283
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 2284
end -- 2253
function Play.prototype.stepInteract(self, dt, input) -- 2287
	local p = self.player -- 2288
	local calmUsed = self.calmConsumed -- 2289
	self.calmConsumed = false -- 2290
	local calming = self.escort.state == "calming" -- 2292
	self.focusCart = false -- 2293
	if self.room.key == "outside" then -- 2293
		local c = self.room.cart -- 2295
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 2296
		local dy = p.y - c.baseY -- 2297
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 2298
	end -- 2298
	if not calmUsed and not calming then -- 2298
		self:stepCart(dt, input) -- 2302
	end -- 2302
	if calmUsed then -- 2302
		self:flashSet("安抚 · 敲两下", 0.8) -- 2307
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 2307
		if self.knockT > 0 then -- 2307
			self.knocks = self.knocks + 1 -- 2311
		else -- 2311
			self.knocks = 1 -- 2313
		end -- 2313
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 2315
		self.knockT = 1.2 -- 2316
		if self.knocks >= 2 then -- 2316
			self:flashSet("敲两下", 0.8) -- 2318
			self.knocks = 0 -- 2319
		else -- 2319
			self:flashSet("敲一下", 0.5) -- 2321
		end -- 2321
	elseif self.knockT > 0 then -- 2321
		self.knockT = self.knockT - dt -- 2324
		if self.knockT <= 0 then -- 2324
			self.knocks = 0 -- 2326
		end -- 2326
	end -- 2326
	local i = 0 -- 2331
	do -- 2331
		i = 0 -- 2332
		while i < #self.room.marks do -- 2332
			do -- 2332
				local m = self.room.marks[i + 1] -- 2333
				if m.kind ~= 0 then -- 2333
					goto __continue403 -- 2335
				end -- 2335
				local subjects = {self.partner, self.player} -- 2337
				local k = 0 -- 2338
				do -- 2338
					k = 0 -- 2339
					while k < #subjects do -- 2339
						do -- 2339
							local s = subjects[k + 1] -- 2340
							if not s.alive then -- 2340
								goto __continue406 -- 2342
							end -- 2342
							local dx = s.x - m.x -- 2344
							local dy = s.y - m.y -- 2345
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2345
								self.checkpoint = m.x -- 2347
								self.checkpointCartAxle = self.cartAxle -- 2348
								if self.cartDocked then -- 2348
									self:flashSet("检查点 · 车已落窝", 1) -- 2350
								else -- 2350
									self:flashSet("检查点 · 车还没到位", 1) -- 2352
								end -- 2352
							end -- 2352
						end -- 2352
						::__continue406:: -- 2352
						k = k + 1 -- 2339
					end -- 2339
				end -- 2339
			end -- 2339
			::__continue403:: -- 2339
			i = i + 1 -- 2332
		end -- 2332
	end -- 2332
	self:checkCarryGate() -- 2358
end -- 2287
function Play.prototype.stepVillage(self, dt, input) -- 2362
	if self.room.key ~= "village" then -- 2362
		return -- 2364
	end -- 2364
	local p = self.player -- 2366
	local bottle = self.room.bottle -- 2367
	local scav = self.room.scavenger -- 2368
	if not self.hasBottle and bottle ~= nil then -- 2368
		local dx = p.x - bottle.x -- 2372
		local dy = p.y + p.h * 0.5 - bottle.y -- 2373
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 2373
			self.hasBottle = true -- 2375
			self:flashSet("拾起瓶子", 0.8) -- 2376
		end -- 2376
	end -- 2376
	if self.hasBottle then -- 2376
		if input.aim.held then -- 2376
			self.aimHold = self.aimHold + dt -- 2383
			if self.aimHold > 1.2 then -- 2383
				self.aimHold = 1.2 -- 2385
			end -- 2385
			local cached = self:bottleEnd() -- 2388
			self.bottleAimX = cached.x -- 2389
			self.bottleAimY = cached.y -- 2390
		elseif input.aim.released then -- 2390
			if self.aimHold < 0.12 then -- 2390
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 2394
				self.aimHold = 0 -- 2395
			else -- 2395
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2397
				self:throwBottle(____end.x, ____end.y) -- 2398
				self.aimHold = 0 -- 2399
			end -- 2399
		end -- 2399
	else -- 2399
		self.aimHold = 0 -- 2403
		self.bottleAimX = -1 -- 2404
	end -- 2404
	local fly = self.bottleFly -- 2409
	if fly ~= nil then -- 2409
		fly.t = fly.t + dt -- 2411
		fly.x = fly.x0 + fly.vx * fly.t -- 2412
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 2413
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 2414
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 2414
			self:landBottle(fly) -- 2416
		end -- 2416
	end -- 2416
	if self.bottleLandT > 0 then -- 2416
		self.bottleLandT = self.bottleLandT - dt -- 2420
	end -- 2420
	if scav ~= nil then -- 2420
		self:stepScav(dt, scav) -- 2424
	end -- 2424
	local line = self.room.passLine -- 2427
	if line ~= nil and not self.passed and p.x >= line then -- 2427
		self.passed = true -- 2429
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 2430
	end -- 2430
	if self.passed and p.x >= self.ox + 640 then -- 2430
		self:requestRoom("forest", "过第一院出院") -- 2434
		self:flashSet("出院 · 北塔森林", 1.4) -- 2435
	end -- 2435
end -- 2362
function Play.prototype.bottleEnd(self) -- 2440
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2441
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 2444
	return {x = aim.x, y = g} -- 2445
end -- 2440
function Play.prototype.throwBottle(self, tx, ty) -- 2449
	local p = self.player -- 2450
	local dir = tx >= p.x and 1 or -1 -- 2452
	p.facing = dir -- 2453
	local x0 = p.x + dir * 10 -- 2454
	local y0 = p.y + p.h * 0.7 -- 2455
	self.bottleTargetX = tx -- 2456
	self.bottleTargetY = ty -- 2457
	self.bottleSurfaceY = ty -- 2458
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 2459
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 2460
	self.bottleFly = { -- 2461
		x = x0, -- 2461
		y = y0, -- 2461
		x0 = x0, -- 2461
		y0 = y0, -- 2461
		vx = vx, -- 2461
		vy = vy, -- 2461
		t = 0 -- 2461
	} -- 2461
	self.hasBottle = false -- 2462
	self:flashSet("投出", 0.4) -- 2463
	self:emit( -- 2464
		"bottleThrown", -- 2464
		{ -- 2464
			fromX = x0, -- 2465
			fromY = y0, -- 2466
			targetX = tx, -- 2467
			targetY = ty, -- 2468
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 2469
		} -- 2469
	) -- 2469
end -- 2449
function Play.prototype.landBottle(self, fly) -- 2474
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 2475
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 2476
	local s = self.room.scavenger -- 2477
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 2478
	self.bottleFly = nil -- 2479
	self.bottleTargetX = -1 -- 2480
	self.bottleTargetY = 0 -- 2481
	self.bottleSurfaceY = -1 -- 2482
	self.bottleLandX = x -- 2483
	self.bottleLandY = y -- 2484
	self.bottleLandT = 0.9 -- 2485
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 2486
	self:hearBottle(x) -- 2487
end -- 2474
function Play.prototype.hearBottle(self, x) -- 2491
	local s = self.room.scavenger -- 2492
	if s == nil then -- 2492
		return -- 2494
	end -- 2494
	if math.abs(x - self.scavX) > s.range then -- 2494
		self:flashSet("落地 · 他没听见", 0.6) -- 2497
		return -- 2498
	end -- 2498
	self.scavState = "turn" -- 2500
	self.scavT = s.hearTicks -- 2501
	self.scavTargetX = x -- 2502
	self:flashSet("砖地一响 · 他转头", 0.9) -- 2503
end -- 2491
function Play.prototype.stepScav(self, dt, s) -- 2507
	if self.scavState == "chase" then -- 2507
		return -- 2510
	end -- 2510
	if self.scavState == "turn" then -- 2510
		self.scavT = self.scavT - 1 -- 2513
		if self.scavT <= 0 then -- 2513
			self.scavState = "walk" -- 2515
		end -- 2515
		return -- 2517
	end -- 2517
	if self.scavState == "walk" then -- 2517
		local d = self.scavTargetX - self.scavX -- 2520
		if math.abs(d) < 4 then -- 2520
			self.scavState = "stall" -- 2522
			self.scavT = s.stallTicks -- 2523
			return -- 2524
		end -- 2524
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 2526
		return -- 2527
	end -- 2527
	if self.scavState == "stall" then -- 2527
		self.scavT = self.scavT - 1 -- 2530
		if self.scavT <= 0 then -- 2530
			self.scavState = "back" -- 2532
		end -- 2532
		return -- 2534
	end -- 2534
	if self.scavState == "back" then -- 2534
		local home = math.max( -- 2537
			s.x0, -- 2537
			math.min(s.x1, self.scavX) -- 2537
		) -- 2537
		if math.abs(home - self.scavX) < 2 then -- 2537
			self.scavState = "patrol" -- 2539
			return -- 2540
		end -- 2540
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 2542
		return -- 2543
	end -- 2543
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 2545
	if self.scavX >= s.x1 then -- 2545
		self.scavX = s.x1 -- 2547
		self.scavDir = -1 -- 2548
	elseif self.scavX <= s.x0 then -- 2548
		self.scavX = s.x0 -- 2550
		self.scavDir = 1 -- 2551
	end -- 2551
end -- 2507
function Play.prototype.stepCart(self, dt, input) -- 2559
	local p = self.player -- 2560
	local c = self.room.cart -- 2561
	if self.gripping then -- 2561
		if not input.interact.held then -- 2561
			self.gripping = false -- 2565
			self:flashSet("松开车把", 0.4) -- 2566
			return -- 2567
		end -- 2567
	else -- 2567
		if not input.interact.pressed then -- 2567
			return -- 2571
		end -- 2571
		if not self:cartHandleInReach(p) then -- 2571
			return -- 2574
		end -- 2574
		local track = c.depth or 0 -- 2576
		if self:limitDepth(p, track) ~= track then -- 2576
			return -- 2578
		end -- 2578
		p.depth = track -- 2580
		p.depthSpeed = 0 -- 2581
		self.gripping = true -- 2582
		self:flashSet("握住车把", 0.4) -- 2583
		return -- 2584
	end -- 2584
	if self.cartDocked then -- 2584
		return -- 2588
	end -- 2588
	local dir = input.moveX -- 2590
	if dir == 0 then -- 2590
		return -- 2592
	end -- 2592
	local lo = math.min(c.startX, c.endX) -- 2594
	local hi = math.max(c.startX, c.endX) -- 2595
	local next = self.cartAxle + dir * CART_SPEED * dt -- 2596
	if next < lo then -- 2596
		next = lo -- 2598
	end -- 2598
	if next > hi then -- 2598
		next = hi -- 2601
	end -- 2601
	local delta = next - self.cartAxle -- 2603
	if delta == 0 then -- 2603
		return -- 2605
	end -- 2605
	self.cartAxle = next -- 2607
	p.x = p.x + delta -- 2608
	p.facing = dir > 0 and 1 or -1 -- 2609
	self:slideX(p, 0) -- 2610
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 2610
		self.gripping = false -- 2612
		self:flashSet("跟不上了，脱手", 0.6) -- 2613
		return -- 2614
	end -- 2614
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 2614
		self.cartDocked = true -- 2617
		self.gripping = false -- 2618
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 2619
		self:flashSet("车轮落窝", 1.2) -- 2620
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 2620
		self:flashSet("车轮回到起点", 0.5) -- 2622
	end -- 2622
end -- 2559
function Play.prototype.requestRoom(self, key, reason) -- 2630
	if self.wantRoom ~= "" then -- 2630
		return -- 2634
	end -- 2634
	self.wantRoom = key -- 2636
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 2637
end -- 2630
function Play.prototype.checkCarryGate(self) -- 2644
	if self.room.key == "checkpoint" then -- 2644
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 2644
			self.carryCartAxle = self.cartAxle -- 2647
			self.carryCartDocked = self.cartDocked -- 2648
			self:requestRoom("gate", "检查站出口") -- 2649
			self:flashSet("出检查站 · 城门", 1.2) -- 2650
		end -- 2650
		return -- 2652
	end -- 2652
	if self.room.key == "outside" then -- 2652
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 2652
			self.carryCartAxle = self.cartAxle -- 2658
			self.carryCartDocked = self.cartDocked -- 2659
			self:requestRoom("village", "墙根走完") -- 2660
			self:flashSet("墙根走完 · 进村口", 1.2) -- 2661
		end -- 2661
	end -- 2661
end -- 2644
function Play.prototype.aimAt(self, wx, wy) -- 2668
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 2669
	self.aimX = s.x -- 2670
	self.aimY = s.y -- 2671
end -- 2668
function Play.prototype.shoot(self, a) -- 2674
	if self.isCampaign and self.reloadT > 0 then -- 2674
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 2676
		return -- 2677
	end -- 2677
	local ox = a.x + a.facing * 8 -- 2679
	local muzzleY = a.y + a.h * 0.72 -- 2680
	local oy = muzzleY + a.depth -- 2681
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2683
	local dx = aim.x - ox -- 2686
	local dy = aim.y - oy -- 2687
	local len = math.sqrt(dx * dx + dy * dy) -- 2688
	if len < 0.001 then -- 2688
		dx = a.facing -- 2690
		dy = 0 -- 2691
	else -- 2691
		dx = dx / len -- 2693
		dy = dy / len -- 2694
	end -- 2694
	if dx ~= 0 then -- 2694
		a.facing = dx > 0 and 1 or -1 -- 2697
	end -- 2697
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 2700
	local hitEnemy = self:raycastEnemies(ray) -- 2701
	local tEnemy = hitEnemy.t -- 2702
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 2703
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 2704
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 2705
	local tWall = solid.t -- 2706
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 2707
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 2708
	self.trace = { -- 2710
		x0 = ox, -- 2710
		y0 = oy, -- 2710
		x1 = ox + dx * t, -- 2710
		y1 = oy + dy * t, -- 2710
		hit = hit -- 2710
	} -- 2710
	self.traceT = 0.12 -- 2711
	self:applyFireDanger(ox) -- 2712
	local killed = false -- 2713
	if hit then -- 2713
		local i = hitEnemy.index -- 2715
		local e = self.enemies[i + 1] -- 2716
		local impactY = oy + dy * tEnemy -- 2717
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 2718
		local shieldTop = e.y + (e.depth or 0) + 64 -- 2719
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 2719
			e.shieldHp = (e.shieldHp or 0) - 1 -- 2721
			e.hitT = 0.3 -- 2722
			self:flashSet( -- 2723
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 2723
				0.8 -- 2723
			) -- 2723
			self:emit("shotResolved", { -- 2724
				hit = true, -- 2725
				enemyIndex = i, -- 2725
				enemyX = e.x, -- 2725
				aimX = aim.x, -- 2725
				aimY = aim.y, -- 2725
				impactX = ox + dx * t, -- 2726
				impactY = oy + dy * t, -- 2726
				shield = true -- 2726
			}) -- 2726
			self.reloadT = self.run.inventory.quickbelt > 0 and 36 or 54 -- 2728
			return -- 2729
		end -- 2729
		e.alive = false -- 2731
		e.hitT = 0.4 -- 2732
		killed = true -- 2733
		self:flashSet("命中", 0.6) -- 2734
		self:dropFor(e) -- 2735
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 2735
		self:damageProp(solid.box, 1) -- 2737
	else -- 2737
		self:flashSet("打空", 0.35) -- 2739
	end -- 2739
	if self.isCampaign then -- 2739
		self.reloadT = self.run.inventory.quickbelt > 0 and 36 or 54 -- 2742
	end -- 2742
	self:emit("shotResolved", { -- 2744
		hit = hit, -- 2745
		enemyIndex = hit and hitEnemy.index or -1, -- 2746
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 2747
		aimX = aim.x, -- 2748
		aimY = aim.y, -- 2749
		impactX = ox + dx * t, -- 2750
		impactY = oy + dy * t -- 2751
	}) -- 2751
end -- 2674
function Play.prototype.applyFireDanger(self, shotX) -- 2756
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 2756
		return -- 2758
	end -- 2758
	local dangerX = shotX -- 2760
	local best = -1 -- 2761
	local bestD = 1000000000 -- 2762
	local i = 0 -- 2763
	do -- 2763
		i = 0 -- 2764
		while i < #self.enemies do -- 2764
			do -- 2764
				local e = self.enemies[i + 1] -- 2765
				if not e.alive then -- 2765
					goto __continue482 -- 2767
				end -- 2767
				local d = math.abs(e.x - self.partner.x) -- 2769
				if d < bestD then -- 2769
					bestD = d -- 2771
					best = i -- 2772
				end -- 2772
			end -- 2772
			::__continue482:: -- 2772
			i = i + 1 -- 2764
		end -- 2764
	end -- 2764
	if best >= 0 then -- 2764
		dangerX = self.enemies[best + 1].x -- 2776
	end -- 2776
	local exposed = self:childExposed(dangerX) -- 2778
	local before = self.escort.fear -- 2779
	local dangerId = self.nextDangerId -- 2780
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 2781
	self.nextDangerId = self.nextDangerId + 1 -- 2782
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 2783
	if after > before then -- 2783
		self:flashSet( -- 2785
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 2785
			1 -- 2785
		) -- 2785
	elseif not exposed then -- 2785
		self:flashSet("枪声没够到她", 0.5) -- 2787
	end -- 2787
end -- 2756
function Play.prototype.childExposed(self, dangerX) -- 2792
	local c = self.partner -- 2793
	if not c.alive then -- 2793
		return false -- 2795
	end -- 2795
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 2795
		self.boxes, -- 2798
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 2798
	) then -- 2798
		return false -- 2799
	end -- 2799
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 2799
		return false -- 2802
	end -- 2802
	local toDanger = dangerX - c.x -- 2804
	local toPlayer = self.player.x - c.x -- 2805
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 2805
		return false -- 2808
	end -- 2808
	return true -- 2810
end -- 2792
function Play.prototype.raycastEnemies(self, ray) -- 2814
	local best = -1 -- 2815
	local bestI = -1 -- 2816
	do -- 2816
		local i = 0 -- 2817
		while i < #self.enemies do -- 2817
			do -- 2817
				local e = self.enemies[i + 1] -- 2818
				if not e.alive then -- 2818
					goto __continue496 -- 2820
				end -- 2820
				local y = e.y + (e.depth or 0) -- 2822
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 2823
				if t >= 0 and (best < 0 or t < best) then -- 2823
					best = t -- 2825
					bestI = i -- 2826
				end -- 2826
			end -- 2826
			::__continue496:: -- 2826
			i = i + 1 -- 2817
		end -- 2817
	end -- 2817
	return {t = best, index = bestI} -- 2829
end -- 2814
function Play.prototype.raycastWorld(self, ray) -- 2832
	return self:raycastSolid(ray).t -- 2833
end -- 2832
function Play.prototype.raycastSolid(self, ray) -- 2837
	local best = -1 -- 2838
	local bestBox = nil -- 2839
	for ____, box in ipairs(self.boxes) do -- 2840
		do -- 2840
			if box.broken == true or box.hidden == true then -- 2840
				goto __continue501 -- 2842
			end -- 2842
			local t = hitBox(ray, box) -- 2847
			if t >= 0 and (best < 0 or t < best) then -- 2847
				best = t -- 2849
				bestBox = box -- 2850
			end -- 2850
		end -- 2850
		::__continue501:: -- 2850
	end -- 2850
	if ray.dy < 0 then -- 2850
		local t = -ray.y / ray.dy -- 2854
		if t >= 0 and (best < 0 or t < best) then -- 2854
			best = t -- 2856
			bestBox = nil -- 2857
		end -- 2857
	end -- 2857
	return {t = best, box = bestBox} -- 2860
end -- 2837
function Play.prototype.dropFor(self, e) -- 2864
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 2864
		return -- 2866
	end -- 2866
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 2866
		return -- 2869
	end -- 2869
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 2871
	local ____self_pickups_37 = self.pickups -- 2871
	____self_pickups_37[#____self_pickups_37 + 1] = { -- 2872
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 2873
		kind = e.drop, -- 2873
		x = e.x, -- 2873
		y = e.y, -- 2873
		depth = e.depth, -- 2874
		label = label .. " ×1" -- 2874
	} -- 2874
	self:log("掉落 " .. label) -- 2876
end -- 2864
function Play.prototype.damageProp(self, b, amount) -- 2880
	if b.breakable == nil or b.broken == true then -- 2880
		return -- 2882
	end -- 2882
	local ____b_breakable_38, ____hp_39 = b.breakable, "hp" -- 2882
	____b_breakable_38[____hp_39] = ____b_breakable_38[____hp_39] - amount -- 2884
	if b.breakable.hp > 0 then -- 2884
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 2886
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 2887
		return -- 2888
	end -- 2888
	b.broken = true -- 2890
	for ____, other in ipairs(self.boxes) do -- 2891
		if other.id ~= nil and other.id == b.id then -- 2891
			other.broken = true -- 2893
		end -- 2893
	end -- 2893
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 2896
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 2897
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 2898
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 2899
end -- 2880
function Play.prototype.slideDepth(self, a, distance) -- 2903
	a.depth = self:limitDepth(a, a.depth + distance) -- 2904
end -- 2903
function Play.prototype.limitDepth(self, a, target) -- 2907
	local road = self.room.depth -- 2908
	if road == nil or target == a.depth then -- 2908
		return a.depth -- 2910
	end -- 2910
	local next = math.max( -- 2912
		road.min, -- 2912
		math.min(road.max, target) -- 2912
	) -- 2912
	local half = a.w / 2 -- 2913
	for ____, b in ipairs(self.boxes) do -- 2914
		do -- 2914
			local footprint = b.depth -- 2915
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 2915
				goto __continue519 -- 2920
			end -- 2920
			local front = footprint.min - ACTOR_DEPTH_HALF -- 2922
			local back = footprint.max + ACTOR_DEPTH_HALF -- 2923
			if a.depth <= front and next > front then -- 2923
				next = front -- 2925
			elseif a.depth >= back and next < back then -- 2925
				next = back -- 2927
			end -- 2927
		end -- 2927
		::__continue519:: -- 2927
	end -- 2927
	return next -- 2930
end -- 2907
function Play.prototype.slideX(self, a, dx) -- 2934
	local nx = a.x + dx -- 2935
	local half = a.w / 2 -- 2936
	local room = self.room -- 2937
	nx = math.max( -- 2938
		room.minX + half, -- 2938
		math.min(room.maxX - half, nx) -- 2938
	) -- 2938
	local i = 0 -- 2939
	do -- 2939
		i = 0 -- 2940
		while i < #self.boxes do -- 2940
			do -- 2940
				local b = self.boxes[i + 1] -- 2941
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 2941
					goto __continue526 -- 2943
				end -- 2943
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2943
					goto __continue526 -- 2946
				end -- 2946
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 2946
					goto __continue526 -- 2949
				end -- 2949
				if nx + half > b.x0 and nx - half < b.x1 then -- 2949
					if a.x <= b.x0 then -- 2949
						nx = b.x0 - half -- 2953
					elseif a.x >= b.x1 then -- 2953
						nx = b.x1 + half -- 2955
					else -- 2955
						nx = a.x -- 2957
					end -- 2957
				end -- 2957
			end -- 2957
			::__continue526:: -- 2957
			i = i + 1 -- 2940
		end -- 2940
	end -- 2940
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 2940
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 2965
		local bx0 = self.cartAxle - CART_HALF -- 2966
		local bx1 = self.cartAxle + CART_HALF -- 2967
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 2967
			if a.x <= bx0 then -- 2967
				nx = bx0 - half -- 2970
			elseif a.x >= bx1 then -- 2970
				nx = bx1 + half -- 2972
			else -- 2972
				nx = a.x -- 2974
			end -- 2974
		end -- 2974
	end -- 2974
	local arch = room.arch -- 2982
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 2982
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 2984
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 2984
			if a.x <= arch.x0 then -- 2984
				nx = arch.x0 - half -- 2987
			elseif a.x >= arch.x1 then -- 2987
				nx = arch.x1 + half -- 2989
			end -- 2989
		end -- 2989
	end -- 2989
	a.x = nx -- 2993
end -- 2934
function Play.prototype.fallY(self, a, dt) -- 2997
	a.vy = a.vy - ____exports.GRAVITY * dt -- 2998
	if a.vy < -900 then -- 2998
		a.vy = -900 -- 3000
	end -- 3000
	local ny = a.y + a.vy * dt -- 3002
	local half = a.w / 2 -- 3003
	if a.vy <= 0 then -- 3003
		local reach = a.onGround and STEP_UP or 0 -- 3006
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 3007
		if ny <= ground then -- 3007
			ny = ground -- 3009
			a.vy = 0 -- 3010
			a.onGround = true -- 3011
		else -- 3011
			a.onGround = false -- 3013
		end -- 3013
	else -- 3013
		a.onGround = false -- 3016
		local i = 0 -- 3017
		do -- 3017
			i = 0 -- 3018
			while i < #self.boxes do -- 3018
				do -- 3018
					local b = self.boxes[i + 1] -- 3019
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3019
						goto __continue550 -- 3021
					end -- 3021
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3021
						goto __continue550 -- 3024
					end -- 3024
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 3024
						goto __continue550 -- 3027
					end -- 3027
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 3027
						ny = b.y0 - a.h -- 3030
						a.vy = 0 -- 3031
					end -- 3031
				end -- 3031
				::__continue550:: -- 3031
				i = i + 1 -- 3018
			end -- 3018
		end -- 3018
	end -- 3018
	a.y = ny -- 3035
end -- 2997
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 3039
	if depth == nil then -- 3039
		depth = 0 -- 3039
	end -- 3039
	local g = -9999 -- 3040
	local i = 0 -- 3041
	do -- 3041
		i = 0 -- 3042
		while i < #self.floors do -- 3042
			local f = self.floors[i + 1] -- 3043
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 3043
				g = f.y1 -- 3045
			end -- 3045
			i = i + 1 -- 3042
		end -- 3042
	end -- 3042
	do -- 3042
		i = 0 -- 3048
		while i < #self.boxes do -- 3048
			do -- 3048
				local b = self.boxes[i + 1] -- 3049
				if b.broken == true or b.hidden == true or b.soft == true then -- 3049
					goto __continue560 -- 3051
				end -- 3051
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 3051
					g = b.y1 -- 3055
				end -- 3055
			end -- 3055
			::__continue560:: -- 3055
			i = i + 1 -- 3048
		end -- 3048
	end -- 3048
	return g -- 3058
end -- 3039
function Play.prototype.updateCamera(self, dt) -- 3061
	local p = self.player -- 3062
	local tx = p.x + p.facing * 30 -- 3063
	local ty = p.y + CAM_LOOK_UP -- 3064
	local k = math.min(1, CAM_FOLLOW * dt) -- 3065
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 3066
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 3067
end -- 3061
function Play.prototype.clampCamera(self, w, h) -- 3071
	local room = self.room -- 3072
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 3073
	local spanX = room.maxX - room.minX -- 3074
	if spanX <= halfW * 2 then -- 3074
		self.cam.x = (room.minX + room.maxX) / 2 -- 3076
	else -- 3076
		self.cam.x = math.max( -- 3078
			room.minX + halfW, -- 3078
			math.min(room.maxX - halfW, self.cam.x) -- 3078
		) -- 3078
	end -- 3078
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 3081
	local spanY = room.height -- 3082
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 3083
	if spanY <= halfH * 2 then -- 3083
		self.cam.y = camY -- 3085
	else -- 3085
		self.cam.y = math.max( -- 3087
			camY, -- 3087
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 3087
		) -- 3087
	end -- 3087
end -- 3071
function Play.prototype.flashSet(self, text, t) -- 3091
	self.flash = text -- 3092
	self.flashT = t -- 3093
end -- 3091
function Play.prototype.statusText(self) -- 3097
	local p = self.player -- 3098
	local parts = {} -- 3099
	local who = self.childMode and "小满" or "周戍" -- 3100
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 3101
	if self.room.key == "prologue" then -- 3101
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3104
		if self.phase == "prologue-wait" then -- 3104
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 3106
		elseif self.phase == "prologue-give" then -- 3106
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 3108
		else -- 3108
			parts[#parts + 1] = "跟随" -- 3110
		end -- 3110
		if self.paused then -- 3110
			parts[#parts + 1] = "已暂停" -- 3113
		end -- 3113
		return table.concat(parts, " · ") -- 3115
	end -- 3115
	if self.room.key == "street" then -- 3115
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3118
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3119
		if self.paused then -- 3119
			parts[#parts + 1] = "已暂停" -- 3121
		end -- 3121
		return table.concat(parts, " · ") -- 3123
	end -- 3123
	if self.room.key == "gate" then -- 3123
		local ____temp_40 -- 3126
		if self.room.story == nil then -- 3126
			____temp_40 = nil -- 3126
		else -- 3126
			____temp_40 = self.room.story.gate -- 3126
		end -- 3126
		local g = ____temp_40 -- 3126
		if g ~= nil then -- 3126
			parts[#parts + 1] = self:gateLabel() -- 3128
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 3129
				0, -- 3130
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 3130
			))) .. " 秒" -- 3130
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3131
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3132
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 3133
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 3134
			if self.gateFailCount > 0 then -- 3134
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 3136
			end -- 3136
			if self.flash ~= "" then -- 3136
				parts[#parts + 1] = self.flash -- 3139
			end -- 3139
		end -- 3139
		if self.paused then -- 3139
			parts[#parts + 1] = "已暂停" -- 3143
		end -- 3143
		return table.concat(parts, " · ") -- 3145
	end -- 3145
	if self.room.key == "forest" then -- 3145
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3148
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 3149
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 3150
		if self.caughtT > 0 then -- 3150
			parts[#parts + 1] = "复位中" -- 3152
		end -- 3152
		if self.paused then -- 3152
			parts[#parts + 1] = "已暂停" -- 3155
		end -- 3155
		return table.concat(parts, " · ") -- 3157
	end -- 3157
	if self.room.key == "tower" then -- 3157
		if self.phase == "tower-wait" then -- 3157
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 3161
		elseif self.phase == "tower-knock" then -- 3161
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 3163
		elseif self.phase == "tower-given" then -- 3163
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 3165
		else -- 3165
			parts[#parts + 1] = "片尾" -- 3167
		end -- 3167
		if self.paused then -- 3167
			parts[#parts + 1] = "已暂停" -- 3170
		end -- 3170
		return table.concat(parts, " · ") -- 3172
	end -- 3172
	if self.room.key == "village" then -- 3172
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3175
		if self.hasBottle then -- 3175
			parts[#parts + 1] = "有瓶" -- 3177
		elseif self.bottleFly ~= nil then -- 3177
			parts[#parts + 1] = "瓶在飞" -- 3179
		else -- 3179
			parts[#parts + 1] = "空手" -- 3181
		end -- 3181
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 3183
		if self.scavChase then -- 3183
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 3185
		end -- 3185
		if self.passed then -- 3185
			parts[#parts + 1] = "已过通行线" -- 3188
		end -- 3188
		if self.paused then -- 3188
			parts[#parts + 1] = "已暂停" -- 3191
		end -- 3191
		return table.concat(parts, " · ") -- 3193
	end -- 3193
	local isChild = self.childMode -- 3196
	if isChild then -- 3196
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3198
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 3199
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3200
	else -- 3200
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 3202
		if p.rollT > 0 then -- 3202
			parts[#parts + 1] = "翻滚中" -- 3204
		end -- 3204
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3206
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3207
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 3208
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 3209
	end -- 3209
	if self.checkpoint >= 0 then -- 3209
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 3212
	end -- 3212
	if self.paused then -- 3212
		parts[#parts + 1] = "已暂停" -- 3215
	end -- 3215
	return table.concat(parts, " · ") -- 3217
end -- 3097
function Play.prototype.aliveEnemies(self) -- 3221
	local n = 0 -- 3222
	local i = 0 -- 3223
	do -- 3223
		i = 0 -- 3224
		while i < #self.enemies do -- 3224
			if self.enemies[i + 1].alive then -- 3224
				n = n + 1 -- 3226
			end -- 3226
			i = i + 1 -- 3224
		end -- 3224
	end -- 3224
	return n -- 3229
end -- 3221
function Play.prototype.threatened(self) -- 3234
	do -- 3234
		local i = 0 -- 3235
		while i < #self.enemies do -- 3235
			local e = self.enemies[i + 1] -- 3236
			if e.alive and e.warnT > 0 then -- 3236
				return true -- 3238
			end -- 3238
			i = i + 1 -- 3235
		end -- 3235
	end -- 3235
	return false -- 3241
end -- 3234
function Play.prototype.gateSecondsLeft(self) -- 3244
	local ____temp_41 -- 3245
	if self.room.story == nil then -- 3245
		____temp_41 = nil -- 3245
	else -- 3245
		____temp_41 = self.room.story.gate -- 3245
	end -- 3245
	local g = ____temp_41 -- 3245
	if g == nil then -- 3245
		return 0 -- 3247
	end -- 3247
	return math.max( -- 3249
		0, -- 3249
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 3249
	) -- 3249
end -- 3244
function Play.prototype.gateLabel(self) -- 3252
	if self.phase == "gate-idle" then -- 3252
		return "待就位" -- 3254
	end -- 3254
	if self.phase == "gate-hold" then -- 3254
		return "守点中" -- 3257
	end -- 3257
	if self.phase == "gate-send" then -- 3257
		return "送别" -- 3260
	end -- 3260
	if self.phase == "gate-count" then -- 3260
		return "数数 " .. tostring(self.countTick) -- 3263
	end -- 3263
	return "她走" -- 3265
end -- 3252
function Play.prototype.dogLabel(self) -- 3269
	if self.dogState == "ear" then -- 3269
		return "转耳" -- 3271
	end -- 3271
	if self.dogState == "chase" then -- 3271
		return "追" -- 3274
	end -- 3274
	if self.dogState == "sniff" then -- 3274
		return "停" -- 3277
	end -- 3277
	if self.dogState == "back" then -- 3277
		return "回线" -- 3280
	end -- 3280
	return "巡逻" -- 3282
end -- 3269
function Play.prototype.doorXOf(self) -- 3285
	local ____temp_42 -- 3286
	if self.room.story == nil then -- 3286
		____temp_42 = nil -- 3286
	else -- 3286
		____temp_42 = self.room.story.tower -- 3286
	end -- 3286
	local t = ____temp_42 -- 3286
	return t == nil and 0 or t.doorX -- 3287
end -- 3285
function Play.prototype.scavLabel(self) -- 3291
	if self.scavState == "chase" then -- 3291
		return "追" -- 3293
	end -- 3293
	if self.scavState == "turn" then -- 3293
		return "转头" -- 3296
	end -- 3296
	if self.scavState == "walk" then -- 3296
		return "赶来" -- 3299
	end -- 3299
	if self.scavState == "stall" then -- 3299
		return "停住" -- 3302
	end -- 3302
	if self.scavState == "back" then -- 3302
		return "回位" -- 3305
	end -- 3305
	return "巡逻" -- 3307
end -- 3291
function Play.prototype.hintText(self) -- 3311
	if self.paused then -- 3311
		return "Esc 继续 · R 重置" -- 3313
	end -- 3313
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 3313
		if self:threatened() then -- 3313
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 3319
		end -- 3319
		if self.coverHug then -- 3319
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 3322
		end -- 3322
		if self.coverNear then -- 3322
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 3325
		end -- 3325
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 3327
	end -- 3327
	if self.flash ~= "" then -- 3327
		return self.flash -- 3330
	end -- 3330
	if self.room.key == "prologue" then -- 3330
		if self.phase == "prologue-wait" then -- 3330
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 3334
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 3335
		end -- 3335
		if self.phase == "prologue-give" then -- 3335
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 3338
		end -- 3338
		return "她跟着你了 · 两人一起走到门口 680" -- 3340
	end -- 3340
	if self.room.key == "street" then -- 3340
		if self:aliveEnemies() > 0 then -- 3340
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 3344
		end -- 3344
		return "清完了 · 两人一起走到右边检查站入口 900" -- 3346
	end -- 3346
	if self.room.key == "gate" then -- 3346
		local ____temp_43 -- 3349
		if self.room.story == nil then -- 3349
			____temp_43 = nil -- 3349
		else -- 3349
			____temp_43 = self.room.story.gate -- 3349
		end -- 3349
		local g = ____temp_43 -- 3349
		if g ~= nil then -- 3349
			if self.phase == "gate-idle" then -- 3349
				if self.gateNeedConfirm then -- 3349
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 3353
				end -- 3353
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 3355
			end -- 3355
			if self.phase == "gate-hold" then -- 3355
				if self.coveredFlash > 0 then -- 3355
					return "掩体挡下了这一枪 · 别露头" -- 3359
				end -- 3359
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 3361
			end -- 3361
			if self.phase == "gate-send" then -- 3361
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 3364
			end -- 3364
			if self.phase == "gate-count" then -- 3364
				if self.countTick >= 1440 then -- 3364
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 3368
				end -- 3368
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 3370
			end -- 3370
			return "她自己走 · 跟着出城门 1120" -- 3372
		end -- 3372
	end -- 3372
	if self.room.key == "forest" then -- 3372
		if self.dogState == "chase" then -- 3372
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 3377
		end -- 3377
		if self.dogState == "ear" then -- 3377
			return "狗转耳朵了 · 停下或蹲下别出声" -- 3380
		end -- 3380
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 3382
	end -- 3382
	if self.room.key == "tower" then -- 3382
		if self.phase == "tower-wait" then -- 3382
			return "走到门前 445 点一次 E 敲两下" -- 3386
		end -- 3386
		if self.phase == "tower-knock" then -- 3386
			return "敲两下 · 等门开" -- 3389
		end -- 3389
		if self.phase == "tower-given" then -- 3389
			return "递交针套和纸条 · 看登记簿最后一行" -- 3392
		end -- 3392
		return "片尾 · 点 E 再玩一次，回到序章" -- 3394
	end -- 3394
	if self.room.key == "village" then -- 3394
		if self.bottleFly ~= nil then -- 3394
			return "等瓶子落地 · 触地才发声" -- 3398
		end -- 3398
		if self.hasBottle then -- 3398
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 3401
		end -- 3401
		if self.passed then -- 3401
			return "已过第一院 · R 重置可再来一遍" -- 3404
		end -- 3404
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 3406
	end -- 3406
	if self.room.key == "outside" then -- 3406
		if self.focusCart then -- 3406
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 3410
		end -- 3410
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 3412
	end -- 3412
	if self.escort.state == "frozen" then -- 3412
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 3412
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 3416
		end -- 3416
		return "小满吓住了 · 走过去，靠近再点 E" -- 3418
	end -- 3418
	if self.escort.state == "calming" then -- 3418
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 3421
	end -- 3421
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 3423
end -- 3311
function Play.prototype.draw(self, draw, w, h) -- 3428
	self.viewW = w -- 3429
	self.viewH = h -- 3430
	self.view = ____exports.computeViewport(w, h) -- 3431
	self:clampCamera(w, h) -- 3432
	draw:clear() -- 3433
	draw:drawRect( -- 3435
		Rect(0, 0, w, h), -- 3435
		BG_VOID -- 3435
	) -- 3435
	local box = self:canvasRect(w, h) -- 3436
	draw:drawRect(box, BG_FAR) -- 3437
	draw:drawRect( -- 3438
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 3438
		BG_MID -- 3438
	) -- 3438
	self:drawFloors(draw, w, h) -- 3440
	self:drawSolids(draw, w, h) -- 3441
	self:drawZones(draw, w, h) -- 3442
	self:drawArch(draw, w, h) -- 3443
	self:drawCart(draw, w, h) -- 3444
	self:drawCampaignProps(draw, w, h) -- 3445
	self:drawActors(draw, w, h) -- 3446
	self:drawTrace(draw, w, h) -- 3447
	self:drawAim(draw, w, h) -- 3448
end -- 3428
function Play.prototype.canvasRect(self, w, h) -- 3452
	local v = self.view -- 3453
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 3454
end -- 3452
function Play.prototype.px(self, n) -- 3458
	return n * self.view.zoom -- 3459
end -- 3458
function Play.prototype.sx(self, wx, w) -- 3463
	local v = self.view -- 3464
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 3465
	return v.ox + lx * v.zoom -- 3466
end -- 3463
function Play.prototype.sy(self, wy, h) -- 3470
	local v = self.view -- 3471
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 3472
	return v.oy + ly * v.zoom -- 3473
end -- 3470
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 3476
	local px0 = self:sx(x0, w) -- 3477
	local px1 = self:sx(x1, w) -- 3478
	local py0 = self:sy(y0, h) -- 3479
	local py1 = self:sy(y1, h) -- 3480
	if px1 <= px0 or py1 <= py0 then -- 3480
		return -- 3482
	end -- 3482
	draw:drawRect( -- 3484
		Rect(px0, py0, px1 - px0, py1 - py0), -- 3484
		color -- 3484
	) -- 3484
end -- 3476
function Play.prototype.drawFloors(self, draw, w, h) -- 3487
	local i = 0 -- 3488
	do -- 3488
		i = 0 -- 3489
		while i < #self.room.floors do -- 3489
			local f = self.room.floors[i + 1] -- 3490
			local ____temp_44 -- 3491
			if f.y == 0 then -- 3491
				____temp_44 = self.room.depth -- 3491
			else -- 3491
				____temp_44 = nil -- 3491
			end -- 3491
			local road = ____temp_44 -- 3491
			local y = self:sy(f.y + (road and road.min or 0), h) -- 3492
			local x0 = self:sx(f.x0, w) -- 3493
			local x1 = self:sx(f.x1, w) -- 3494
			local deck = self:px(5) -- 3495
			if road ~= nil then -- 3495
				local back = self:sy(f.y + road.max, h) -- 3497
				draw:drawRect( -- 3498
					Rect(x0, y, x1 - x0, back - y), -- 3498
					FLOOR_DECK, -- 3498
					self:px(1), -- 3498
					SOLID_EDGE -- 3498
				) -- 3498
			end -- 3498
			draw:drawRect( -- 3500
				Rect(x0, y - deck, x1 - x0, deck), -- 3500
				FLOOR_DECK -- 3500
			) -- 3500
			draw:drawSegment( -- 3501
				Vec2(x0, y), -- 3501
				Vec2(x1, y), -- 3501
				self:px(1), -- 3501
				GROUND -- 3501
			) -- 3501
			i = i + 1 -- 3489
		end -- 3489
	end -- 3489
end -- 3487
function Play.prototype.drawSolids(self, draw, w, h) -- 3505
	local i = 0 -- 3506
	do -- 3506
		i = 0 -- 3507
		while i < #self.boxes do -- 3507
			do -- 3507
				local b = self.boxes[i + 1] -- 3508
				if b.id == "braced_shield" or b.hidden == true then -- 3508
					goto __continue681 -- 3510
				end -- 3510
				if b.broken == true then -- 3510
					if b.breakable ~= nil then -- 3510
						local gy = self:sy(b.y0, h) -- 3515
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 3516
						local k = 0 -- 3517
						do -- 3517
							k = 0 -- 3518
							while k < 3 do -- 3518
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 3519
								draw:drawSegment( -- 3520
									Vec2( -- 3520
										gx - self:px(4), -- 3520
										gy + self:px(k % 2) -- 3520
									), -- 3520
									Vec2( -- 3520
										gx + self:px(5), -- 3520
										gy + self:px(k % 2) -- 3520
									), -- 3520
									self:px(1), -- 3520
									rgb -- 3520
								) -- 3520
								k = k + 1 -- 3518
							end -- 3518
						end -- 3518
					end -- 3518
					goto __continue681 -- 3523
				end -- 3523
				local ____opt_47 = b.depth -- 3523
				local front = ____opt_47 and ____opt_47.min or 0 -- 3525
				local ____opt_49 = b.depth -- 3525
				local back = ____opt_49 and ____opt_49.max or 0 -- 3526
				local fill = SOLID_FILL -- 3527
				local line = SOLID_EDGE -- 3528
				if b.soft == true then -- 3528
					fill = SOFT -- 3530
					line = SOFT_LINE -- 3531
				elseif b.breakable ~= nil then -- 3531
					line = DANGER_LINE -- 3533
					fill = Color(0.3, 0.24, 0.16, 1) -- 3534
				elseif b.interact ~= nil then -- 3534
					line = PASS_LINE -- 3536
				end -- 3536
				self:drawBox( -- 3538
					draw, -- 3538
					w, -- 3538
					h, -- 3538
					b.x0, -- 3538
					b.x1, -- 3538
					b.y0 + front, -- 3538
					b.y1 + back, -- 3538
					fill -- 3538
				) -- 3538
				draw:drawSegment( -- 3539
					Vec2( -- 3539
						self:sx(b.x0, w), -- 3539
						self:sy(b.y1 + front, h) -- 3539
					), -- 3539
					Vec2( -- 3540
						self:sx(b.x1, w), -- 3540
						self:sy(b.y1 + front, h) -- 3540
					), -- 3540
					self:px(1), -- 3540
					line -- 3540
				) -- 3540
				if b.breakable ~= nil then -- 3540
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 3543
					local cyp = self:sy(b.y1 + front, h) -- 3544
					draw:drawSegment( -- 3545
						Vec2( -- 3545
							cxp - self:px(4), -- 3545
							cyp + self:px(1) -- 3545
						), -- 3545
						Vec2( -- 3545
							cxp + self:px(3), -- 3545
							cyp + self:px(5) -- 3545
						), -- 3545
						self:px(1), -- 3545
						line -- 3545
					) -- 3545
				end -- 3545
			end -- 3545
			::__continue681:: -- 3545
			i = i + 1 -- 3507
		end -- 3507
	end -- 3507
end -- 3505
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 3551
	local i = 0 -- 3552
	do -- 3552
		i = 0 -- 3553
		while i < #self.pickups do -- 3553
			do -- 3553
				local pk = self.pickups[i + 1] -- 3554
				if pk.id == "" then -- 3554
					goto __continue693 -- 3556
				end -- 3556
				local gy = pk.y + (pk.depth or 0) -- 3558
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 3559
				draw:drawRect( -- 3560
					Rect( -- 3560
						self:sx(pk.x - 5, w), -- 3560
						self:sy(gy + 12 + bob, h), -- 3560
						self:px(10), -- 3560
						self:px(10) -- 3560
					), -- 3560
					Color(0.84, 0.7, 0.3, 1) -- 3561
				) -- 3561
				draw:drawSegment( -- 3562
					Vec2( -- 3562
						self:sx(pk.x - 5, w), -- 3562
						self:sy(gy + 12 + bob, h) -- 3562
					), -- 3562
					Vec2( -- 3563
						self:sx(pk.x + 5, w), -- 3563
						self:sy(gy + 12 + bob, h) -- 3563
					), -- 3563
					self:px(1), -- 3563
					Color(0.95, 0.86, 0.52, 1) -- 3563
				) -- 3563
			end -- 3563
			::__continue693:: -- 3563
			i = i + 1 -- 3553
		end -- 3553
	end -- 3553
	if self.bracedShield ~= nil then -- 3553
		local sh = self.bracedShield -- 3566
		draw:drawRect( -- 3567
			Rect( -- 3567
				self:sx(sh.x - sh.w / 2, w), -- 3567
				self:sy(sh.y, h), -- 3567
				self:px(sh.w), -- 3567
				self:px(sh.h) -- 3567
			), -- 3567
			Color(0.42, 0.4, 0.34, 1) -- 3568
		) -- 3568
		draw:drawSegment( -- 3569
			Vec2( -- 3569
				self:sx(sh.x - sh.w / 2, w), -- 3569
				self:sy(sh.y + sh.h, h) -- 3569
			), -- 3569
			Vec2( -- 3570
				self:sx(sh.x + sh.w / 2, w), -- 3570
				self:sy(sh.y + sh.h, h) -- 3570
			), -- 3570
			self:px(1), -- 3570
			Color(0.74, 0.72, 0.62, 1) -- 3570
		) -- 3570
	end -- 3570
end -- 3551
function Play.prototype.drawZones(self, draw, w, h) -- 3574
	local i = 0 -- 3575
	do -- 3575
		i = 0 -- 3576
		while i < #self.room.zones do -- 3576
			local z = self.room.zones[i + 1] -- 3577
			local fill = DANGER -- 3578
			local line = DANGER_LINE -- 3579
			if z.tint == 2 then -- 3579
				fill = SOFT -- 3581
				line = SOFT_LINE -- 3582
			elseif z.tint == 3 then -- 3582
				fill = BRICK -- 3584
				line = BRICK_LINE -- 3585
			elseif z.tint == 4 then -- 3585
				fill = PASS -- 3587
				line = PASS_LINE -- 3588
			end -- 3588
			self:drawBox( -- 3590
				draw, -- 3590
				w, -- 3590
				h, -- 3590
				z.x0, -- 3590
				z.x1, -- 3590
				z.y, -- 3590
				z.y + z.h, -- 3590
				fill -- 3590
			) -- 3590
			draw:drawSegment( -- 3591
				Vec2( -- 3591
					self:sx(z.x0, w), -- 3591
					self:sy(z.y, h) -- 3591
				), -- 3591
				Vec2( -- 3591
					self:sx(z.x0, w), -- 3591
					self:sy(z.y + z.h, h) -- 3591
				), -- 3591
				self:px(1), -- 3591
				line -- 3591
			) -- 3591
			draw:drawSegment( -- 3592
				Vec2( -- 3592
					self:sx(z.x1, w), -- 3592
					self:sy(z.y, h) -- 3592
				), -- 3592
				Vec2( -- 3592
					self:sx(z.x1, w), -- 3592
					self:sy(z.y + z.h, h) -- 3592
				), -- 3592
				self:px(1), -- 3592
				line -- 3592
			) -- 3592
			i = i + 1 -- 3576
		end -- 3576
	end -- 3576
end -- 3574
function Play.prototype.drawArch(self, draw, w, h) -- 3596
	local a = self.room.arch -- 3597
	if a.h <= 0 then -- 3597
		return -- 3599
	end -- 3599
	self:drawBox( -- 3601
		draw, -- 3601
		w, -- 3601
		h, -- 3601
		a.x0, -- 3601
		a.x1, -- 3601
		a.y, -- 3601
		a.y + a.h, -- 3601
		HOLE_FILL -- 3601
	) -- 3601
	draw:drawSegment( -- 3602
		Vec2( -- 3602
			self:sx(a.x0, w), -- 3602
			self:sy(a.y + a.h, h) -- 3602
		), -- 3602
		Vec2( -- 3602
			self:sx(a.x1, w), -- 3602
			self:sy(a.y + a.h, h) -- 3602
		), -- 3602
		self:px(1), -- 3602
		SOLID_EDGE -- 3602
	) -- 3602
	draw:drawSegment( -- 3603
		Vec2( -- 3603
			self:sx(a.x0, w), -- 3603
			self:sy(a.y, h) -- 3603
		), -- 3603
		Vec2( -- 3603
			self:sx(a.x0, w), -- 3603
			self:sy(a.y + a.h, h) -- 3603
		), -- 3603
		self:px(1), -- 3603
		SOLID_EDGE -- 3603
	) -- 3603
	draw:drawSegment( -- 3604
		Vec2( -- 3604
			self:sx(a.x1, w), -- 3604
			self:sy(a.y, h) -- 3604
		), -- 3604
		Vec2( -- 3604
			self:sx(a.x1, w), -- 3604
			self:sy(a.y + a.h, h) -- 3604
		), -- 3604
		self:px(1), -- 3604
		SOLID_EDGE -- 3604
	) -- 3604
end -- 3596
function Play.prototype.drawCart(self, draw, w, h) -- 3607
	local c = self.room.cart -- 3608
	if c.bodyW <= 0 then -- 3608
		return -- 3610
	end -- 3610
	drawCartShape( -- 3612
		draw, -- 3612
		self, -- 3612
		w, -- 3612
		h, -- 3612
		c, -- 3612
		self.cartAxle -- 3612
	) -- 3612
	draw:drawRect( -- 3613
		Rect( -- 3613
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 3613
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 3613
			self:px(2), -- 3613
			self:px(40) -- 3613
		), -- 3613
		STAND -- 3613
	) -- 3613
end -- 3607
function Play.prototype.drawActors(self, draw, w, h) -- 3616
	local p = self.player -- 3617
	local isChild = self.childMode -- 3618
	local footY = p.y + p.depth -- 3619
	if p.covered then -- 3619
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 3622
		draw:drawSegment( -- 3623
			Vec2( -- 3623
				self:sx(edge, w), -- 3623
				self:sy(footY + 8, h) -- 3623
			), -- 3623
			Vec2( -- 3623
				self:sx(edge, w), -- 3623
				self:sy(footY + p.h * 0.62, h) -- 3623
			), -- 3623
			self:px(2), -- 3623
			STAND -- 3623
		) -- 3623
		draw:drawSegment( -- 3625
			Vec2( -- 3625
				self:sx(p.x - 8, w), -- 3625
				self:sy(footY + p.h + 3, h) -- 3625
			), -- 3625
			Vec2( -- 3625
				self:sx(p.x + 8, w), -- 3625
				self:sy(footY + p.h + 3, h) -- 3625
			), -- 3625
			self:px(2), -- 3625
			STAND -- 3625
		) -- 3625
	elseif self.coverNear and not isChild then -- 3625
		draw:drawRect( -- 3628
			Rect( -- 3628
				self:sx(p.x - 3, w), -- 3628
				self:sy(footY + 1, h), -- 3628
				self:px(3), -- 3628
				self:px(3) -- 3628
			), -- 3628
			STAND -- 3628
		) -- 3628
	end -- 3628
	drawFigure( -- 3630
		draw, -- 3630
		self, -- 3630
		w, -- 3630
		h, -- 3630
		p, -- 3630
		isChild and CHILD_BODY or SOLDIER_BODY, -- 3630
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 3630
	) -- 3630
	local q = self.partner -- 3631
	if q.alive then -- 3631
		local childPartner = q.w == CHILD_W -- 3633
		drawFigure( -- 3634
			draw, -- 3634
			self, -- 3634
			w, -- 3634
			h, -- 3634
			q, -- 3634
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 3634
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 3634
		) -- 3634
	end -- 3634
	local i = 0 -- 3636
	do -- 3636
		i = 0 -- 3637
		while i < #self.enemies do -- 3637
			local e = self.enemies[i + 1] -- 3638
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 3639
			local enemyY = e.y + (e.depth or 0) -- 3640
			self:drawBox( -- 3641
				draw, -- 3641
				w, -- 3641
				h, -- 3641
				e.x - e.w / 2, -- 3641
				e.x + e.w / 2, -- 3641
				enemyY, -- 3641
				enemyY + e.h, -- 3641
				col -- 3641
			) -- 3641
			if e.alive then -- 3641
				local ef = p.x >= e.x and 1 or -1 -- 3643
				if e.kind == "shield" then -- 3643
					local sh = (e.shieldHp or 0) > 0 -- 3645
					draw:drawRect( -- 3646
						Rect( -- 3646
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 3646
							self:sy(enemyY, h), -- 3646
							self:px(6), -- 3646
							self:px(64) -- 3646
						), -- 3646
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 3647
					) -- 3647
				elseif e.kind == "breaker" then -- 3647
					draw:drawSegment( -- 3649
						Vec2( -- 3649
							self:sx(e.x + ef * 12, w), -- 3649
							self:sy(enemyY + 8, h) -- 3649
						), -- 3649
						Vec2( -- 3650
							self:sx(e.x + ef * 22, w), -- 3650
							self:sy(enemyY + 46, h) -- 3650
						), -- 3650
						self:px(3), -- 3650
						Color(0.5, 0.36, 0.22, 1) -- 3650
					) -- 3650
				end -- 3650
			end -- 3650
			if e.alive and e.warnT > 0 then -- 3650
				local gunX = self:sx(e.x, w) -- 3655
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 3656
				local aimX = self:sx(p.x, w) -- 3657
				local aimY = self:sy(footY + p.h * 0.55, h) -- 3658
				local seg = 8 -- 3659
				local s = 0 -- 3660
				do -- 3660
					s = 0 -- 3661
					while s < seg do -- 3661
						local t0 = s / seg -- 3662
						local t1 = (s + 1) / seg -- 3663
						draw:drawSegment( -- 3664
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 3665
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 3666
							self:px(1), -- 3667
							DANGER -- 3667
						) -- 3667
						s = s + 2 -- 3661
					end -- 3661
				end -- 3661
			end -- 3661
			i = i + 1 -- 3637
		end -- 3637
	end -- 3637
	local k = 0 -- 3672
	do -- 3672
		k = 0 -- 3673
		while k < #self.room.marks do -- 3673
			do -- 3673
				local m = self.room.marks[k + 1] -- 3674
				if m.kind ~= 0 then -- 3674
					goto __continue719 -- 3676
				end -- 3676
				local on = self.checkpoint == m.x -- 3678
				local x = self:sx(m.x, w) -- 3679
				local y = self:sy(m.y, h) -- 3680
				draw:drawSegment( -- 3681
					Vec2(x, y), -- 3681
					Vec2( -- 3681
						x, -- 3681
						y + self:px(35) -- 3681
					), -- 3681
					self:px(1), -- 3681
					on and CHECK or INK_DIM -- 3681
				) -- 3681
				draw:drawDot( -- 3682
					Vec2( -- 3682
						x, -- 3682
						y + self:px(35) -- 3682
					), -- 3682
					self:px(2), -- 3682
					on and CHECK or INK_DIM -- 3682
				) -- 3682
			end -- 3682
			::__continue719:: -- 3682
			k = k + 1 -- 3673
		end -- 3673
	end -- 3673
	local j = 0 -- 3686
	do -- 3686
		j = 0 -- 3687
		while j < #self.room.marks do -- 3687
			do -- 3687
				local m = self.room.marks[j + 1] -- 3688
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 3688
					goto __continue722 -- 3690
				end -- 3690
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 3690
					goto __continue722 -- 3694
				end -- 3694
				local col = STAND -- 3696
				if m.kind == 4 then -- 3696
					col = PASS_LINE -- 3698
				elseif m.kind == 5 then -- 3698
					col = BRICK_LINE -- 3700
				end -- 3700
				local mx = self:sx(m.x, w) -- 3702
				local my = self:sy(m.y, h) -- 3703
				draw:drawSegment( -- 3704
					Vec2(mx, my), -- 3704
					Vec2( -- 3704
						mx, -- 3704
						my + self:px(24) -- 3704
					), -- 3704
					self:px(1), -- 3704
					col -- 3704
				) -- 3704
			end -- 3704
			::__continue722:: -- 3704
			j = j + 1 -- 3687
		end -- 3687
	end -- 3687
	local t = 0 -- 3707
	do -- 3707
		t = 0 -- 3708
		while t < #self.room.marks do -- 3708
			do -- 3708
				local m = self.room.marks[t + 1] -- 3709
				if m.kind ~= 6 then -- 3709
					goto __continue728 -- 3711
				end -- 3711
				local mx = self:sx(m.x, w) -- 3713
				local my = self:sy(m.y, h) -- 3714
				draw:drawSegment( -- 3715
					Vec2(mx, my), -- 3715
					Vec2( -- 3715
						mx, -- 3715
						my + self:px(30) -- 3715
					), -- 3715
					self:px(1), -- 3715
					INK_DIM -- 3715
				) -- 3715
				self:drawBox( -- 3716
					draw, -- 3716
					w, -- 3716
					h, -- 3716
					m.x - 5, -- 3716
					m.x + 5, -- 3716
					m.y + 30, -- 3716
					m.y + 40, -- 3716
					CHECK -- 3716
				) -- 3716
			end -- 3716
			::__continue728:: -- 3716
			t = t + 1 -- 3708
		end -- 3708
	end -- 3708
	if self.room.key == "village" then -- 3708
		self:drawVillage(draw, w, h) -- 3719
	end -- 3719
	if self.room.key == "forest" then -- 3719
		self:drawDog(draw, w, h) -- 3722
	end -- 3722
end -- 3616
function Play.prototype.drawDog(self, draw, w, h) -- 3727
	local x = self.dogX -- 3728
	self:drawBox( -- 3729
		draw, -- 3729
		w, -- 3729
		h, -- 3729
		x - 14, -- 3729
		x + 14, -- 3729
		0, -- 3729
		20, -- 3729
		SCAV_BODY -- 3729
	) -- 3729
	self:drawBox( -- 3730
		draw, -- 3730
		w, -- 3730
		h, -- 3730
		x - 10, -- 3730
		x - 2, -- 3730
		20, -- 3730
		30, -- 3730
		SCAV_BODY -- 3730
	) -- 3730
	self:drawBox( -- 3731
		draw, -- 3731
		w, -- 3731
		h, -- 3731
		x + 2, -- 3731
		x + 10, -- 3731
		20, -- 3731
		30, -- 3731
		SCAV_HEAD -- 3731
	) -- 3731
	if self.dogState == "ear" or self.dogState == "chase" then -- 3731
		draw:drawSegment( -- 3733
			Vec2( -- 3733
				self:sx(x, w), -- 3733
				self:sy(30, h) -- 3733
			), -- 3733
			Vec2( -- 3734
				self:sx(x, w), -- 3734
				self:sy(40, h) -- 3734
			), -- 3734
			self:px(1), -- 3734
			DANGER -- 3734
		) -- 3734
	end -- 3734
end -- 3727
function Play.prototype.drawVillage(self, draw, w, h) -- 3739
	local bottle = self.room.bottle -- 3740
	if bottle ~= nil then -- 3740
		self:drawBox( -- 3742
			draw, -- 3742
			w, -- 3742
			h, -- 3742
			bottle.x - 14, -- 3742
			bottle.x + 14, -- 3742
			0, -- 3742
			64, -- 3742
			SOLID_FILL -- 3742
		) -- 3742
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 3742
			self:drawBottle( -- 3744
				draw, -- 3744
				w, -- 3744
				h, -- 3744
				bottle.x, -- 3744
				64 -- 3744
			) -- 3744
		end -- 3744
	end -- 3744
	self:drawBox( -- 3748
		draw, -- 3748
		w, -- 3748
		h, -- 3748
		300, -- 3748
		420, -- 3748
		44, -- 3748
		50, -- 3748
		FLOOR_DECK -- 3748
	) -- 3748
	self:drawBox( -- 3749
		draw, -- 3749
		w, -- 3749
		h, -- 3749
		300, -- 3749
		306, -- 3749
		0, -- 3749
		44, -- 3749
		FLOOR_DECK -- 3749
	) -- 3749
	self:drawBox( -- 3750
		draw, -- 3750
		w, -- 3750
		h, -- 3750
		414, -- 3750
		420, -- 3750
		0, -- 3750
		44, -- 3750
		FLOOR_DECK -- 3750
	) -- 3750
	local s = self.room.scavenger -- 3752
	if s ~= nil then -- 3752
		local sx0 = self.scavX -- 3754
		self:drawBox( -- 3755
			draw, -- 3755
			w, -- 3755
			h, -- 3755
			sx0 - 12, -- 3755
			sx0 + 12, -- 3755
			0, -- 3755
			s.h - 14, -- 3755
			SCAV_BODY -- 3755
		) -- 3755
		self:drawBox( -- 3756
			draw, -- 3756
			w, -- 3756
			h, -- 3756
			sx0 - 7, -- 3756
			sx0 + 7, -- 3756
			s.h - 14, -- 3756
			s.h, -- 3756
			SCAV_HEAD -- 3756
		) -- 3756
		if self.scavState == "turn" then -- 3756
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 3758
			draw:drawSegment( -- 3759
				Vec2( -- 3759
					self:sx(sx0, w), -- 3759
					self:sy(s.h - 6, h) -- 3759
				), -- 3759
				Vec2( -- 3759
					self:sx(fx, w), -- 3759
					self:sy(s.h - 6, h) -- 3759
				), -- 3759
				self:px(1), -- 3759
				INK -- 3759
			) -- 3759
		end -- 3759
	end -- 3759
	if self.hasBottle then -- 3759
		local p = self.player -- 3764
		self:drawBottle( -- 3765
			draw, -- 3765
			w, -- 3765
			h, -- 3765
			p.x + p.facing * 10, -- 3765
			p.y + p.h * 0.62 -- 3765
		) -- 3765
	end -- 3765
	if self.bottleFly ~= nil then -- 3765
		self:drawBottle( -- 3768
			draw, -- 3768
			w, -- 3768
			h, -- 3768
			self.bottleFly.x, -- 3768
			self.bottleFly.y -- 3768
		) -- 3768
	end -- 3768
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 3768
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 3771
		draw:drawCircle( -- 3772
			Vec2( -- 3772
				self:sx(self.bottleLandX, w), -- 3772
				self:sy(0, h) -- 3772
			), -- 3772
			self:px(r / ____exports.UNITS_PER_PX), -- 3772
			BRICK_LINE -- 3772
		) -- 3772
	end -- 3772
end -- 3739
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 3776
	self:drawBox( -- 3777
		draw, -- 3777
		w, -- 3777
		h, -- 3777
		x - 3, -- 3777
		x + 3, -- 3777
		y - 10, -- 3777
		y, -- 3777
		BOTTLE -- 3777
	) -- 3777
end -- 3776
function Play.prototype.drawTrace(self, draw, w, h) -- 3780
	local t = self.trace -- 3781
	if t == nil or self.traceT <= 0 then -- 3781
		return -- 3783
	end -- 3783
	draw:drawSegment( -- 3785
		Vec2( -- 3786
			self:sx(t.x0, w), -- 3786
			self:sy(t.y0, h) -- 3786
		), -- 3786
		Vec2( -- 3787
			self:sx(t.x1, w), -- 3787
			self:sy(t.y1, h) -- 3787
		), -- 3787
		self:px(1), -- 3788
		t.hit and AIM_HIT or INK_DIM -- 3788
	) -- 3788
end -- 3780
function Play.prototype.drawAim(self, draw, w, h) -- 3791
	local v = self.view -- 3793
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 3794
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 3795
	local dot = self:px(1) -- 3796
	local arm = self:px(3) -- 3797
	local gap = self:px(1) -- 3798
	draw:drawSegment( -- 3799
		Vec2(gx - arm - gap, gy), -- 3799
		Vec2(gx - gap, gy), -- 3799
		dot / 2, -- 3799
		AIM -- 3799
	) -- 3799
	draw:drawSegment( -- 3800
		Vec2(gx + gap, gy), -- 3800
		Vec2(gx + arm + gap, gy), -- 3800
		dot / 2, -- 3800
		AIM -- 3800
	) -- 3800
	draw:drawSegment( -- 3801
		Vec2(gx, gy - arm - gap), -- 3801
		Vec2(gx, gy - gap), -- 3801
		dot / 2, -- 3801
		AIM -- 3801
	) -- 3801
	draw:drawSegment( -- 3802
		Vec2(gx, gy + gap), -- 3802
		Vec2(gx, gy + arm + gap), -- 3802
		dot / 2, -- 3802
		AIM -- 3802
	) -- 3802
	if self.room.key == "village" and self.hasBottle then -- 3802
		local p = self.player -- 3806
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3808
		local dir = ____end.x >= p.x and 1 or -1 -- 3809
		local x0 = p.x + dir * 10 -- 3810
		local y0 = p.y + p.h * 0.7 -- 3811
		local T = BOTTLE_FLY_TIME -- 3812
		local vx = (____end.x - x0) / T -- 3813
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 3814
		local pxr = x0 -- 3815
		local pyr = y0 -- 3816
		local t = 1 -- 3817
		do -- 3817
			t = 1 -- 3818
			while t <= 12 do -- 3818
				local tt = t / 12 * T -- 3819
				local nx = x0 + vx * tt -- 3820
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 3821
				draw:drawSegment( -- 3822
					Vec2( -- 3822
						self:sx(pxr, w), -- 3822
						self:sy(pyr, h) -- 3822
					), -- 3822
					Vec2( -- 3822
						self:sx(nx, w), -- 3822
						self:sy(ny, h) -- 3822
					), -- 3822
					self:px(1) / 2, -- 3822
					BOTTLE -- 3822
				) -- 3822
				pxr = nx -- 3823
				pyr = ny -- 3824
				t = t + 1 -- 3818
			end -- 3818
		end -- 3818
		draw:drawCircle( -- 3826
			Vec2( -- 3826
				self:sx(____end.x, w), -- 3826
				self:sy(____end.y + 2, h) -- 3826
			), -- 3826
			self:px(2), -- 3826
			BOTTLE -- 3826
		) -- 3826
	end -- 3826
end -- 3791
return ____exports -- 3791