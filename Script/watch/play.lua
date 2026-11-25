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
function makeActor(room, index) -- 3837
	local sp = room.spawns -- 3838
	if index < 0 or index >= #sp then -- 3838
		return { -- 3840
			x = 0, -- 3840
			y = 0, -- 3840
			depth = 0, -- 3840
			depthSpeed = 0, -- 3840
			vx = 0, -- 3840
			vy = 0, -- 3840
			w = CHILD_W, -- 3840
			h = CHILD_H, -- 3840
			onGround = true, -- 3840
			facing = 1, -- 3840
			crouch = false, -- 3840
			rollT = 0, -- 3840
			covered = false, -- 3840
			alive = false -- 3840
		} -- 3840
	end -- 3840
	local s = sp[index + 1] -- 3842
	local child = s.h <= CHILD_H -- 3843
	local ground = room.depth -- 3844
	local depth = ground == nil and 0 or math.max( -- 3845
		ground.min, -- 3845
		math.min(ground.max, s.depth or 0) -- 3845
	) -- 3845
	return { -- 3846
		x = s.x, -- 3847
		y = s.y, -- 3847
		depth = depth, -- 3847
		depthSpeed = 0, -- 3847
		vx = 0, -- 3847
		vy = 0, -- 3847
		w = child and CHILD_W or SOLDIER_W, -- 3848
		h = child and CHILD_H or SOLDIER_H, -- 3849
		onGround = true, -- 3850
		facing = 1, -- 3850
		crouch = false, -- 3850
		rollT = 0, -- 3850
		covered = false, -- 3850
		alive = true -- 3850
	} -- 3850
end -- 3850
function drawFigure(draw, play, w, h, a, body, head) -- 3854
	if not a.alive then -- 3854
		return -- 3856
	end -- 3856
	local x0 = a.x - a.w / 2 -- 3858
	local x1 = a.x + a.w / 2 -- 3859
	local y0 = a.y + a.depth -- 3860
	local y1 = y0 + a.h -- 3861
	play:drawBox( -- 3862
		draw, -- 3862
		w, -- 3862
		h, -- 3862
		x0, -- 3862
		x1, -- 3862
		y0, -- 3862
		y1 - a.h * 0.26, -- 3862
		body -- 3862
	) -- 3862
	play:drawBox( -- 3863
		draw, -- 3863
		w, -- 3863
		h, -- 3863
		x0 + 2, -- 3863
		x1 - 2, -- 3863
		y1 - a.h * 0.26, -- 3863
		y1, -- 3863
		head -- 3863
	) -- 3863
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 3865
	play:drawBox( -- 3866
		draw, -- 3866
		w, -- 3866
		h, -- 3866
		eyeX, -- 3866
		eyeX + 4, -- 3866
		y1 - a.h * 0.14, -- 3866
		y1 - a.h * 0.08, -- 3866
		INK -- 3866
	) -- 3866
end -- 3866
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 3870
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 3871
end -- 3870
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 3878
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 3879
end -- 3878
function rayInterval(origin, direction, min, max) -- 3886
	if direction == 0 then -- 3886
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 3888
	end -- 3888
	local a = (min - origin) / direction -- 3890
	local b = (max - origin) / direction -- 3891
	return { -- 3892
		min = math.min(a, b), -- 3892
		max = math.max(a, b) -- 3892
	} -- 3892
end -- 3892
function hitBox(ray, box) -- 3896
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 3897
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 3898
	local enter = math.max(0, x.min, y.min) -- 3899
	local leave = math.min(99999, x.max, y.max) -- 3900
	if box.depth ~= nil then -- 3900
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 3902
		enter = math.max(enter, depth.min) -- 3903
		leave = math.min(leave, depth.max) -- 3904
	end -- 3904
	return leave >= enter and enter or -1 -- 3906
end -- 3906
function drawCartShape(draw, play, w, h, c, axleX) -- 3909
	local half = c.bodyW / 2 -- 3910
	local x0 = axleX - half -- 3911
	local x1 = axleX + half -- 3912
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 3913
	play:drawBox( -- 3914
		draw, -- 3914
		w, -- 3914
		h, -- 3914
		x0, -- 3914
		x1, -- 3914
		axleY, -- 3914
		axleY + c.bodyH, -- 3914
		CART_FILL -- 3914
	) -- 3914
	draw:drawCircle( -- 3915
		Vec2( -- 3915
			play:sx(x0 + c.bodyW * 0.28, w), -- 3915
			play:sy(axleY, h) -- 3915
		), -- 3915
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 3915
		Color(52, 50, 48, 255) -- 3915
	) -- 3915
	draw:drawCircle( -- 3916
		Vec2( -- 3916
			play:sx(x1 - c.bodyW * 0.28, w), -- 3916
			play:sy(axleY, h) -- 3916
		), -- 3916
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 3916
		Color(52, 50, 48, 255) -- 3916
	) -- 3916
	local cx = c.clothSide < 0 and x0 or x1 -- 3917
	play:drawBox( -- 3918
		draw, -- 3918
		w, -- 3918
		h, -- 3918
		cx - 10, -- 3918
		cx + 10, -- 3918
		axleY + c.bodyH, -- 3918
		axleY + c.bodyH + 18, -- 3918
		CLOTH -- 3918
	) -- 3918
end -- 3918
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
	if self.flashT > 0 then -- 706
		self.flashT = self.flashT - dt -- 709
		if self.flashT <= 0 then -- 709
			self.flash = "" -- 711
		end -- 711
	end -- 711
	if self.traceT > 0 then -- 711
		self.traceT = self.traceT - dt -- 715
		if self.traceT <= 0 then -- 715
			self.trace = nil -- 717
		end -- 717
	end -- 717
	if self.paused then -- 717
		self:updateCamera(dt) -- 721
		return -- 722
	end -- 722
	self.ticks = self.ticks + 1 -- 725
	if self.invulnT > 0 then -- 725
		self.invulnT = self.invulnT - 1 -- 729
	end -- 729
	if self.isCampaign then -- 729
		local ____self_run_24, ____ticks_25 = self.run, "ticks" -- 729
		____self_run_24[____ticks_25] = ____self_run_24[____ticks_25] + 1 -- 732
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 733
	end -- 733
	local p = self.player -- 735
	self:stepPlayer(p, dt, input) -- 736
	self:refreshCover(p, input) -- 738
	if self.isCampaign then -- 738
		self:stepCampaign(dt, input) -- 740
		self:stepCampaignPartner(dt) -- 741
	end -- 741
	self:stepEnemies(dt, input) -- 744
	if not self.isCampaign then -- 744
		self:stepStory(dt, input) -- 746
		self:stepEscort(dt, input) -- 747
		self:stepVillage(dt, input) -- 748
		self:stepChase(dt, input) -- 749
		self:stepInteract(dt, input) -- 750
	end -- 750
	self:updateGate() -- 752
	self:updateCamera(dt) -- 753
end -- 704
function Play.prototype.underLowArch(self, a) -- 760
	local arch = self.room.arch -- 761
	if arch.h <= 0 then -- 761
		return false -- 763
	end -- 763
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 763
		return false -- 766
	end -- 766
	local top = arch.y + arch.h -- 768
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 769
end -- 760
function Play.prototype.coverAt(self, a) -- 776
	local best = nil -- 777
	local bestGap = 24 -- 778
	local half = a.w / 2 -- 779
	local i = 0 -- 780
	do -- 780
		i = 0 -- 781
		while i < #self.boxes do -- 781
			do -- 781
				local b = self.boxes[i + 1] -- 782
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 782
					goto __continue78 -- 784
				end -- 784
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 784
					goto __continue78 -- 787
				end -- 787
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 789
				if gap < bestGap then -- 789
					bestGap = gap -- 791
					best = b -- 792
				end -- 792
			end -- 792
			::__continue78:: -- 792
			i = i + 1 -- 781
		end -- 781
	end -- 781
	return best -- 795
end -- 776
function Play.prototype.nearCover(self, a) -- 798
	return self:coverAt(a) ~= nil -- 799
end -- 798
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 803
	if enemy == nil then -- 803
		return false -- 805
	end -- 805
	local fromRight = enemy.x >= a.x -- 807
	local edge = fromRight and b.x0 or b.x1 -- 808
	local ____fromRight_26 -- 809
	if fromRight then -- 809
		____fromRight_26 = edge >= a.x - 0.001 and edge <= enemy.x -- 809
	else -- 809
		____fromRight_26 = edge <= a.x + 0.001 and edge >= enemy.x -- 810
	end -- 810
	local between = ____fromRight_26 -- 809
	local separation = enemy.x - a.x -- 811
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 812
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 813
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 814
end -- 803
function Play.prototype.nearestEnemy(self, a) -- 817
	local best -- 818
	local bestD = 1000000000 -- 819
	local i = 0 -- 820
	do -- 820
		i = 0 -- 821
		while i < #self.enemies do -- 821
			do -- 821
				local e = self.enemies[i + 1] -- 822
				if not e.alive then -- 822
					goto __continue87 -- 824
				end -- 824
				local d = math.abs(e.x - a.x) -- 826
				if d < bestD then -- 826
					bestD = d -- 828
					best = e -- 829
				end -- 829
			end -- 829
			::__continue87:: -- 829
			i = i + 1 -- 821
		end -- 821
	end -- 821
	return best -- 832
end -- 817
function Play.prototype.refreshCover(self, a, input) -- 836
	if self.childMode then -- 836
		self.coverNear = false -- 838
		self.coverHug = false -- 839
		self.coverEntity = "" -- 840
		self.coverBlocking = false -- 841
		a.covered = false -- 842
		return -- 843
	end -- 843
	local b = self:coverAt(a) -- 845
	self.coverNear = b ~= nil -- 846
	a.covered = self.coverNear and input.cover.held -- 847
	self.coverHug = a.covered -- 848
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 849
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 850
		b, -- 850
		a, -- 850
		self:nearestEnemy(a) -- 850
	) -- 850
end -- 836
function Play.prototype.cartHandleInReach(self, a) -- 854
	if a == nil then -- 854
		a = self.player -- 854
	end -- 854
	local c = self.room.cart -- 855
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 855
		return false -- 857
	end -- 857
	local handleX = self.cartAxle + c.handleOffset -- 859
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 860
end -- 854
function Play.prototype.nearLowLedge(self, a) -- 865
	local reach = 26 -- 866
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 867
	local x1 = x0 + reach -- 868
	local i = 0 -- 869
	do -- 869
		i = 0 -- 870
		while i < #self.boxes do -- 870
			do -- 870
				local b = self.boxes[i + 1] -- 871
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 871
					goto __continue96 -- 873
				end -- 873
				local rise = b.y1 - a.y -- 875
				if rise > 0 and rise <= LEDGE_RISE then -- 875
					return true -- 877
				end -- 877
			end -- 877
			::__continue96:: -- 877
			i = i + 1 -- 870
		end -- 870
	end -- 870
	return false -- 880
end -- 865
function Play.prototype.stepPlayer(self, a, dt, input) -- 883
	a.depthSpeed = 0 -- 884
	if not a.alive then -- 884
		return -- 886
	end -- 886
	local isChild = self.childMode -- 888
	local lowArch = isChild and self:underLowArch(a) -- 890
	if self:storyLocked() then -- 890
		a.vx = 0 -- 893
		a.crouch = isChild and lowArch -- 894
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 895
		self:fallY(a, dt) -- 896
		return -- 897
	end -- 897
	if not isChild and self.escort.state == "calming" then -- 897
		a.crouch = false -- 901
		a.h = SOLDIER_H -- 902
		a.vx = 0 -- 903
		self:fallY(a, dt) -- 904
		return -- 905
	end -- 905
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 907
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 908
	local nearCover = not isChild and self:nearCover(a) -- 909
	a.covered = nearCover and input.cover.held -- 910
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 912
	if a.rollT > 0 then -- 912
		a.rollT = a.rollT - dt -- 916
		a.vx = a.facing * ROLL_SPEED -- 917
		self:slideX(a, a.vx * dt) -- 918
		self:fallY(a, dt) -- 919
		if a.rollT <= 0 then -- 919
			self:flashSet("翻滚结束", 0.5) -- 921
		end -- 921
		return -- 923
	end -- 923
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 923
		if input.moveX ~= 0 then -- 923
			a.facing = input.moveX > 0 and 1 or -1 -- 928
		end -- 928
		if self:nearLowLedge(a) then -- 928
			a.vy = SOLDIER_JUMP -- 932
			a.onGround = false -- 933
			self:flashSet("翻上去", 0.3) -- 934
			return -- 935
		end -- 935
		a.rollT = ROLL_TIME -- 937
		self:flashSet("翻滚", 0.3) -- 938
		return -- 939
	end -- 939
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 942
	if isChild then -- 942
		if input.cover.held then -- 942
			speed = CHILD_SLOW -- 945
		end -- 945
		if a.crouch then -- 945
			speed = CHILD_SLOW -- 948
		end -- 948
	elseif a.covered then -- 948
		speed = SOLDIER_SPEED * 0.45 -- 951
	end -- 951
	local handsBusy = self.gripping or gripIntent -- 955
	local dir = self.gripping and 0 or input.moveX -- 956
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 957
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 958
	if dir ~= 0 then -- 958
		a.facing = dir > 0 and 1 or -1 -- 960
	end -- 960
	a.vx = dir * speed * diagonal -- 962
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 962
		a.vy = CHILD_JUMP -- 966
		a.onGround = false -- 967
		self:flashSet("跳", 0.25) -- 968
	end -- 968
	local previousDepth = a.depth -- 972
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 973
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 974
	self:slideX(a, a.vx * dt) -- 975
	self:fallY(a, dt) -- 976
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 976
		self:shoot(a) -- 980
	end -- 980
end -- 883
function Play.prototype.stepPartner(self, p, dt) -- 985
	local a = self.partner -- 986
	if not a.alive then -- 986
		return -- 988
	end -- 988
	a.crouch = false -- 990
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 991
	a.vx = 0 -- 992
	a.depthSpeed = 0 -- 993
	self:fallY(a, dt) -- 994
end -- 985
function Play.prototype.stepEscort(self, dt, input) -- 1001
	local a = self.partner -- 1002
	a.depthSpeed = 0 -- 1003
	if not a.alive then -- 1003
		return -- 1005
	end -- 1005
	if not self:escortOn() then -- 1005
		a.vx = 0 -- 1008
		self:fallY(a, dt) -- 1009
		return -- 1010
	end -- 1010
	local p = self.player -- 1012
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1013
	local hadKnock1 = self.escort.knock1 -- 1014
	local hadKnock2 = self.escort.knock2 -- 1015
	self.calmConsumed = self.escort:update( -- 1016
		input, -- 1016
		p.x, -- 1016
		p.facing, -- 1016
		a.x, -- 1016
		dist -- 1016
	) -- 1016
	if not hadKnock1 and self.escort.knock1 then -- 1016
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1019
	end -- 1019
	if not hadKnock2 and self.escort.knock2 then -- 1019
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1022
	end -- 1022
	a.crouch = self.escort.crouchPose -- 1024
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1025
	if not self.escort.stopped then -- 1025
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1027
		local previousDepth = a.depth -- 1028
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1029
		local distance = math.max( -- 1030
			-travel, -- 1030
			math.min(travel, targetDepth - previousDepth) -- 1030
		) -- 1030
		self:slideDepth(a, distance) -- 1031
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1032
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1032
			a.vy = CHILD_JUMP -- 1034
			a.onGround = false -- 1035
		end -- 1035
	end -- 1035
	local dir = self.escort:moveDir(a.x) -- 1038
	a.vx = dir * CHILD_SPEED -- 1039
	if dir ~= 0 then -- 1039
		a.facing = dir -- 1041
		local before = a.x -- 1042
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1043
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1043
			a.vy = CHILD_JUMP -- 1046
			a.onGround = false -- 1047
		end -- 1047
	end -- 1047
	self:fallY(a, dt) -- 1050
end -- 1001
function Play.prototype.escortOn(self) -- 1054
	if self.room.key == "checkpoint" then -- 1054
		return true -- 1056
	end -- 1056
	if self.room.key == "prologue" then -- 1056
		return self.phase == "prologue-follow" -- 1059
	end -- 1059
	return self.room.key == "street" -- 1061
end -- 1054
function Play.prototype.storyLocked(self) -- 1065
	if self.caughtT > 0 then -- 1065
		return true -- 1067
	end -- 1067
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1067
		return true -- 1070
	end -- 1070
	if self.room.key == "gate" and self.phase == "gate-count" then -- 1070
		return true -- 1073
	end -- 1073
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1073
		return true -- 1076
	end -- 1076
	return false -- 1078
end -- 1065
function Play.prototype.swapToChild(self, x) -- 1082
	local tmp = self.player -- 1083
	self.player = self.partner -- 1084
	self.partner = tmp -- 1085
	self.childMode = true -- 1086
	self.player.alive = true -- 1087
	self.player.x = self.ox + x -- 1088
	self.player.y = 0 -- 1089
	self.player.depth = 0 -- 1090
	self.player.depthSpeed = 0 -- 1091
	self.player.vy = 0 -- 1092
	self.player.vx = 0 -- 1093
	self.player.onGround = true -- 1094
	self.player.crouch = false -- 1095
	self.player.h = CHILD_H -- 1096
	self.player.facing = 1 -- 1097
	self.partner.alive = true -- 1098
	self.cam.x = self.player.x -- 1099
end -- 1082
function Play.prototype.stepStory(self, dt, input) -- 1103
	if self.room.key == "prologue" then -- 1103
		self:stepPrologue(dt, input) -- 1105
	elseif self.room.key == "street" then -- 1105
		self:stepStreet(dt, input) -- 1107
	elseif self.room.key == "gate" then -- 1107
		self:stepGate(dt, input) -- 1109
	elseif self.room.key == "tower" then -- 1109
		self:stepTower(dt, input) -- 1111
	end -- 1111
end -- 1103
function Play.prototype.stepPrologue(self, dt, input) -- 1116
	local child = self.partner -- 1117
	if self.phase == "prologue-wait" then -- 1117
		child.crouch = true -- 1119
		child.h = CHILD_CROUCH_H -- 1120
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1121
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1123
		if near and input.interact.pressed then -- 1123
			self.phase = "prologue-give" -- 1125
			self.phaseTick = 0 -- 1126
			self:flashSet("递出针套", 1) -- 1127
		end -- 1127
		return -- 1129
	end -- 1129
	if self.phase == "prologue-give" then -- 1129
		self.phaseTick = self.phaseTick + 1 -- 1132
		if self.phaseTick == 12 then -- 1132
			self:flashSet("针套递过去", 0.7) -- 1134
		elseif self.phaseTick == 36 then -- 1134
			self:flashSet("纸条塞进针套", 0.9) -- 1136
		elseif self.phaseTick >= 60 then -- 1136
			self.phase = "prologue-follow" -- 1138
			self.phaseTick = 0 -- 1139
			child.crouch = false -- 1140
			child.h = CHILD_H -- 1141
			self:flashSet("她跟上了", 1.2) -- 1142
		end -- 1142
		return -- 1144
	end -- 1144
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1144
		self:requestRoom("street", "序章跟到门口") -- 1148
		self:flashSet("进街道", 1.2) -- 1149
	end -- 1149
end -- 1116
function Play.prototype.stepStreet(self, dt, input) -- 1154
	local p = self.player -- 1155
	local c = self.partner -- 1156
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1156
		self:requestRoom("checkpoint", "两人都到街尾") -- 1158
		self:flashSet("到检查站", 1.2) -- 1159
	end -- 1159
end -- 1154
function Play.prototype.stepGate(self, dt, input) -- 1164
	local ____temp_27 -- 1165
	if self.room.story == nil then -- 1165
		____temp_27 = nil -- 1165
	else -- 1165
		____temp_27 = self.room.story.gate -- 1165
	end -- 1165
	local g = ____temp_27 -- 1165
	if g == nil then -- 1165
		return -- 1167
	end -- 1167
	local p = self.player -- 1169
	if self.phase == "gate-idle" then -- 1169
		local a = self.partner -- 1172
		local gap = g.waitX - a.x -- 1173
		if math.abs(gap) > 3 then -- 1173
			a.facing = gap > 0 and 1 or -1 -- 1175
			a.vx = a.facing * CHILD_SPEED -- 1176
			local beforeX = a.x -- 1177
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1178
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1178
				a.vy = CHILD_JUMP -- 1180
				a.onGround = false -- 1181
			end -- 1181
			self:fallY(a, dt) -- 1183
		else -- 1183
			a.vx = 0 -- 1185
			a.x = g.waitX -- 1186
		end -- 1186
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1189
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1190
		if self.gateNeedConfirm then -- 1190
			if not input.interact.held then -- 1190
				self.gateRestartArmed = true -- 1195
			end -- 1195
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1195
				self.gateNeedConfirm = false -- 1198
				self.gateRestartArmed = true -- 1199
				self.phase = "gate-hold" -- 1200
				self.gateTick = 0 -- 1201
				self.gateSpawned = 0 -- 1202
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1203
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1204
			end -- 1204
			return -- 1206
		end -- 1206
		if atWinch and atWait then -- 1206
			self.phase = "gate-hold" -- 1209
			self.gateTick = 0 -- 1210
			self.gateSpawned = 0 -- 1211
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1212
		end -- 1212
		return -- 1214
	end -- 1214
	if self.phase == "gate-hold" then -- 1214
		self.gateTick = self.gateTick + 1 -- 1217
		local marks = {0, 540, 900, 1500} -- 1219
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1219
			local idx = self.gateSpawned -- 1221
			local ____self_enemies_28 = self.enemies -- 1221
			____self_enemies_28[#____self_enemies_28 + 1] = { -- 1222
				x = self.ox + 620 + idx * 62, -- 1223
				y = 0, -- 1223
				w = 26, -- 1223
				h = 84, -- 1223
				alive = true, -- 1224
				hitT = 0, -- 1224
				warnT = 0, -- 1224
				fireCd = 90 + idx * 45 -- 1224
			} -- 1224
			self.gateSpawned = self.gateSpawned + 1 -- 1226
			self:flashSet( -- 1227
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1227
				0.9 -- 1227
			) -- 1227
		end -- 1227
		if self.gateTick == 900 then -- 1227
			self:flashSet("灯灭了", 1) -- 1230
		elseif self.gateTick == 2100 then -- 1230
			self:flashSet("门底压下来了", 1) -- 1232
		end -- 1232
		if self.gateTick >= g.holdTicks then -- 1232
			self.phase = "gate-send" -- 1235
			self.phaseTick = 0 -- 1236
			self.enemies = {} -- 1238
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1239
		end -- 1239
		return -- 1241
	end -- 1241
	if self.phase == "gate-send" then -- 1241
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1244
		if near and input.interact.pressed then -- 1244
			self:swapToChild(g.doorX + 30) -- 1246
			self.phase = "gate-count" -- 1247
			self.countTick = 0 -- 1248
			self.countArmed = false -- 1250
			self.countPrevMove = input.moveX -- 1251
			self:flashSet("门开了 · 送她出去", 1.8) -- 1252
		end -- 1252
		return -- 1254
	end -- 1254
	if self.phase == "gate-count" then -- 1254
		self.countTick = self.countTick + 1 -- 1257
		if self.countTick == 360 then -- 1257
			self:flashSet("门关上", 0.9) -- 1259
		elseif self.countTick == 1020 then -- 1259
			self:flashSet("数到一百", 2.2) -- 1261
		end -- 1261
		local prevMove = self.countPrevMove -- 1265
		self.countPrevMove = input.moveX -- 1266
		if self.countTick >= 1440 then -- 1266
			if prevMove <= 0 and input.moveX > 0 then -- 1266
				self.countArmed = true -- 1269
			end -- 1269
			if self.countArmed and input.moveX > 0 then -- 1269
				self.phase = "gate-walk" -- 1272
				self.phaseTick = 0 -- 1273
				self:flashSet("她迈出第一步", 1.4) -- 1274
			end -- 1274
		end -- 1274
		return -- 1277
	end -- 1277
	if self.player.x >= g.exitX then -- 1277
		self:requestRoom("outside", "走出城门") -- 1281
		self:flashSet("出城门 · 城外", 1.4) -- 1282
	end -- 1282
end -- 1164
function Play.prototype.stepTower(self, dt, input) -- 1287
	local ____temp_29 -- 1288
	if self.room.story == nil then -- 1288
		____temp_29 = nil -- 1288
	else -- 1288
		____temp_29 = self.room.story.tower -- 1288
	end -- 1288
	local t = ____temp_29 -- 1288
	if t == nil then -- 1288
		return -- 1290
	end -- 1290
	if self.phase == "tower-wait" then -- 1290
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1293
		if near and input.interact.pressed then -- 1293
			self.phase = "tower-knock" -- 1295
			self.phaseTick = 0 -- 1296
			self.knocks = 1 -- 1297
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1298
			self:flashSet("敲一下", 0.6) -- 1299
		end -- 1299
		return -- 1301
	end -- 1301
	if self.phase == "tower-knock" then -- 1301
		self.phaseTick = self.phaseTick + 1 -- 1304
		if self.phaseTick == 12 then -- 1304
			self.knocks = 2 -- 1306
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1307
			self:flashSet("敲两下 · 第二声", 1) -- 1308
		elseif self.phaseTick >= t.knockTicks then -- 1308
			self.phase = "tower-given" -- 1310
			self.phaseTick = 0 -- 1311
			self:flashSet("门开了 · 提灯", 1.4) -- 1312
		end -- 1312
		return -- 1314
	end -- 1314
	if self.phase == "tower-given" then -- 1314
		self.phaseTick = self.phaseTick + 1 -- 1317
		if self.phaseTick == 60 then -- 1317
			self:flashSet("她递出针套和纸条", 1.6) -- 1319
		elseif self.phaseTick == 120 then -- 1319
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1321
		elseif self.phaseTick >= 180 then -- 1321
			self.phase = "tower-end" -- 1323
			self.phaseTick = 0 -- 1324
			self:flashSet("片尾 · E 再玩一次", 3) -- 1325
		end -- 1325
		return -- 1327
	end -- 1327
	if input.interact.pressed or input.retry.pressed then -- 1327
		self:requestRoom("prologue", "片尾再玩") -- 1330
		self:flashSet("回到序章", 1.4) -- 1331
	end -- 1331
end -- 1287
function Play.prototype.stepChase(self, dt, input) -- 1336
	if self.caughtT > 0 then -- 1336
		self.caughtT = self.caughtT - dt -- 1338
		if self.caughtT <= 0 then -- 1338
			self:recoverFromCaught() -- 1340
		end -- 1340
		return -- 1342
	end -- 1342
	if self.room.key == "village" then -- 1342
		self:stepScavChase() -- 1345
	elseif self.room.key == "forest" then -- 1345
		self:stepDog(dt) -- 1347
		if self.player.x >= self.ox + 1450 then -- 1347
			self:requestRoom("tower", "到林缘北塔") -- 1350
			self:flashSet("林缘 · 北塔", 1.4) -- 1351
		end -- 1351
	end -- 1351
end -- 1336
function Play.prototype.stepScavChase(self) -- 1357
	local s = self.room.scavenger -- 1358
	if s == nil then -- 1358
		return -- 1360
	end -- 1360
	local p = self.player -- 1362
	if self.passed and p.x > self.ox + 440 then -- 1362
		if self.scavChase then -- 1362
			self.scavChase = false -- 1366
			self.scavState = "back" -- 1367
			self.scavT = 0 -- 1368
		end -- 1368
		return -- 1370
	end -- 1370
	local dx = p.x - self.scavX -- 1372
	local dist = math.abs(dx) -- 1373
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1374
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1375
	if not self.scavChase then -- 1375
		if visible then -- 1375
			self.scavSee = self.scavSee + 1 -- 1378
			if self.scavSee >= 24 then -- 1378
				self.scavChase = true -- 1380
				self.scavState = "chase" -- 1381
				self.scavTargetX = p.x -- 1382
				self:flashSet("他看见你了", 1.2) -- 1383
			end -- 1383
		else -- 1383
			self.scavSee = 0 -- 1386
		end -- 1386
		return -- 1388
	end -- 1388
	local dir = p.x > self.scavX and 1 or -1 -- 1391
	self.scavX = self.scavX + dir * 96 / 60 -- 1392
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1392
		self:caught() -- 1394
		return -- 1395
	end -- 1395
	if hidden then -- 1395
		self.scavSee = 0 -- 1399
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1400
		self.scavT = self.scavT - 1 -- 1401
		if self.scavT <= 0 then -- 1401
			self.scavChase = false -- 1403
			self.scavState = "patrol" -- 1404
			self:flashSet("他失去了目标", 1) -- 1405
		end -- 1405
	end -- 1405
end -- 1357
function Play.prototype.stepDog(self, dt) -- 1411
	local ____temp_30 -- 1412
	if self.room.story == nil then -- 1412
		____temp_30 = nil -- 1412
	else -- 1412
		____temp_30 = self.room.story.dog -- 1412
	end -- 1412
	local dog = ____temp_30 -- 1412
	if dog == nil then -- 1412
		return -- 1414
	end -- 1414
	local p = self.player -- 1416
	local dist = math.abs(p.x - self.dogX) -- 1417
	if self.dogState == "patrol" then -- 1417
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1419
		if self.dogX < dog.x0 then -- 1419
			self.dogX = dog.x0 -- 1421
			self.dogDir = 1 -- 1422
		elseif self.dogX > dog.x1 then -- 1422
			self.dogX = dog.x1 -- 1424
			self.dogDir = -1 -- 1425
		end -- 1425
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1427
		if not p.crouch and moving and dist < dog.range then -- 1427
			self.dogState = "ear" -- 1429
			self.dogT = 18 -- 1430
			self.dogTargetX = p.x -- 1431
			self:flashSet("狗转耳朵", 0.8) -- 1432
		end -- 1432
		return -- 1434
	end -- 1434
	if self.dogState == "ear" then -- 1434
		self.dogT = self.dogT - 1 -- 1437
		if self.dogT <= 0 then -- 1437
			self.dogState = "chase" -- 1439
			self.dogTargetX = p.x -- 1440
			self:flashSet("狗追来了", 1.4) -- 1441
		end -- 1441
		return -- 1443
	end -- 1443
	if self.dogState == "chase" then -- 1443
		local dir = p.x > self.dogX and 1 or -1 -- 1446
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1447
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1447
			self:caught() -- 1449
			self.dogState = "sniff" -- 1450
			self.dogT = 60 -- 1451
		elseif dist > dog.range * 1.5 or p.crouch then -- 1451
			self.dogState = "sniff" -- 1453
			self.dogT = 60 -- 1454
			self:flashSet("狗停下了", 0.9) -- 1455
		end -- 1455
		return -- 1457
	end -- 1457
	if self.dogState == "sniff" then -- 1457
		self.dogT = self.dogT - 1 -- 1460
		if self.dogT <= 0 then -- 1460
			self.dogState = "back" -- 1462
		end -- 1462
		return -- 1464
	end -- 1464
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1467
	self.dogX = self.dogX + dir * dog.speed * dt -- 1468
	if math.abs(self.dogX - dog.x0) < 2 then -- 1468
		self.dogX = dog.x0 -- 1470
		self.dogState = "patrol" -- 1471
	end -- 1471
end -- 1411
function Play.prototype.caught(self) -- 1475
	self.caughtT = 1 -- 1476
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1477
end -- 1475
function Play.prototype.recoverFromCaught(self) -- 1481
	local p = self.player -- 1482
	p.x = self.ox + 140 -- 1483
	p.y = 0 -- 1484
	p.vy = 0 -- 1485
	p.vx = 0 -- 1486
	p.onGround = true -- 1487
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1487
		self.scavX = self.room.scavenger.x0 -- 1489
		self.scavState = "patrol" -- 1490
		self.scavSee = 0 -- 1491
		self.scavChase = false -- 1492
		self.scavT = 0 -- 1493
	end -- 1493
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1493
		self.dogX = self.room.story.dog.x0 -- 1496
		self.dogState = "patrol" -- 1497
		self.dogT = 0 -- 1498
	end -- 1498
	self.cam.x = p.x -- 1500
	self.cam.y = p.y + CAM_LOOK_UP -- 1501
	self:flashSet("回到安全点", 1.2) -- 1502
end -- 1481
function Play.prototype.updateGate(self) -- 1506
	if self.room.key ~= "checkpoint" then -- 1506
		self.gateOpen = false -- 1508
		return -- 1509
	end -- 1509
	local function inZone(x) -- 1511
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1511
	end -- 1511
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1512
end -- 1506
function Play.prototype.addItem(self, kind) -- 1518
	local inv = self.run.inventory -- 1519
	if kind == "shield" then -- 1519
		inv.shield = inv.shield + 1 -- 1521
	elseif kind == "wedge" then -- 1521
		inv.wedge = inv.wedge + 1 -- 1523
	elseif kind == "ammo" then -- 1523
		inv.ammo = inv.ammo + 1 -- 1525
	elseif kind == "pass" then -- 1525
		inv.pass = inv.pass + 1 -- 1527
	elseif kind == "quickbelt" then -- 1527
		inv.quickbelt = inv.quickbelt + 1 -- 1529
	end -- 1529
end -- 1518
function Play.prototype.findBox(self, id) -- 1533
	local i = 0 -- 1534
	do -- 1534
		i = 0 -- 1535
		while i < #self.boxes do -- 1535
			if self.boxes[i + 1].id == id then -- 1535
				return self.boxes[i + 1] -- 1537
			end -- 1537
			i = i + 1 -- 1535
		end -- 1535
	end -- 1535
	return nil -- 1540
end -- 1533
function Play.prototype.nearBox(self, b, reach) -- 1543
	local p = self.player -- 1544
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 1545
end -- 1543
function Play.prototype.findInteract(self) -- 1551
	local p = self.player -- 1552
	local best = nil -- 1553
	local bestD = 1000000000 -- 1554
	local i = 0 -- 1555
	do -- 1555
		i = 0 -- 1556
		while i < #self.boxes do -- 1556
			do -- 1556
				local b = self.boxes[i + 1] -- 1557
				if b.interact == nil or b.broken == true then -- 1557
					goto __continue237 -- 1559
				end -- 1559
				if not self:nearBox(b, b.interact.reach or 27) then -- 1559
					goto __continue237 -- 1562
				end -- 1562
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 1564
				if d < bestD then -- 1564
					bestD = d -- 1566
					best = b -- 1567
				end -- 1567
			end -- 1567
			::__continue237:: -- 1567
			i = i + 1 -- 1556
		end -- 1556
	end -- 1556
	return best -- 1570
end -- 1551
function Play.prototype.stepCampaign(self, dt, input) -- 1574
	local wr = self.room -- 1575
	local p = self.player -- 1576
	if self.reloadT > 0 then -- 1576
		self.reloadT = self.reloadT - 1 -- 1578
	end -- 1578
	if self.bracedShield ~= nil then -- 1578
		self.bracedShield.x = p.x + p.facing * 26 -- 1582
		self.bracedShield.y = p.y -- 1583
		local shBox = __TS__ArrayFind( -- 1584
			self.boxes, -- 1584
			function(____, b) return b.id == "braced_shield" end -- 1584
		) -- 1584
		if shBox ~= nil then -- 1584
			shBox.x0 = self.bracedShield.x - 15 -- 1586
			shBox.x1 = self.bracedShield.x + 15 -- 1587
			shBox.y0 = self.bracedShield.y -- 1588
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 1589
		end -- 1589
	end -- 1589
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 1589
		self.run.route = "drygoods" -- 1595
		self.run.joined = false -- 1596
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 1597
		self:log("转布行线") -- 1598
	end -- 1598
	local i = 0 -- 1601
	do -- 1601
		i = 0 -- 1602
		while i < #self.pickups do -- 1602
			do -- 1602
				local pk = self.pickups[i + 1] -- 1603
				if pk.id == "" or self.run.taken[pk.id] == true then -- 1603
					goto __continue248 -- 1605
				end -- 1605
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 1607
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 1608
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 1608
					self.run.taken[pk.id] = true -- 1610
					self:addItem(pk.kind) -- 1611
					pk.id = "" -- 1612
					self:flashSet("拾取 " .. pk.label, 1) -- 1613
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 1614
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 1615
				end -- 1615
			end -- 1615
			::__continue248:: -- 1615
			i = i + 1 -- 1602
		end -- 1602
	end -- 1602
	if input.interact.pressed then -- 1602
		self:campaignInteract() -- 1619
	end -- 1619
	self:stepCampaignCart(dt, input) -- 1621
	self:stepCampaignGoal() -- 1622
end -- 1574
function Play.prototype.campaignInteract(self) -- 1626
	local b = self:findInteract() -- 1627
	if b ~= nil then -- 1627
		self:useInteract(b) -- 1629
		return -- 1630
	end -- 1630
	local inv = self.run.inventory -- 1632
	if inv.wedge > 0 then -- 1632
		local w = self:findBox("s2_wood") -- 1634
		if w ~= nil and w.broken ~= true and self:nearBox(w, 26) then -- 1634
			if w.breakable ~= nil then -- 1634
				local ____w_breakable_31, ____hp_32 = w.breakable, "hp" -- 1634
				____w_breakable_31[____hp_32] = ____w_breakable_31[____hp_32] + (w.breakable.wedgeHp or 1) -- 1637
			end -- 1637
			inv.wedge = inv.wedge - 1 -- 1639
			self.run.props.s2_wood = {broken = false, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 1640
			self:flashSet("钉木楔 · 薄木挡多承一次", 1.2) -- 1641
			self:log("加固薄木挡") -- 1642
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 1643
			return -- 1644
		end -- 1644
	end -- 1644
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 1644
		local p = self.player -- 1649
		self.bracedShield = { -- 1650
			x = p.x + p.facing * 26, -- 1650
			y = p.y, -- 1650
			w = 30, -- 1650
			h = 64, -- 1650
			hp = 1 -- 1650
		} -- 1650
		local ____self_boxes_33 = self.boxes -- 1650
		____self_boxes_33[#____self_boxes_33 + 1] = { -- 1651
			x0 = self.bracedShield.x - 15, -- 1652
			x1 = self.bracedShield.x + 15, -- 1652
			y0 = p.y, -- 1653
			y1 = p.y + 64, -- 1653
			depth = {min = -46, max = 46}, -- 1653
			label = "架起的残盾", -- 1653
			id = "braced_shield", -- 1653
			soft = true -- 1654
		} -- 1654
		inv.shield = inv.shield - 1 -- 1657
		self:flashSet("架残盾 · 挡一发", 1.2) -- 1658
		self:log("架残盾") -- 1659
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 1660
		return -- 1661
	end -- 1661
	if inv.pass > 0 and self.run.joined == false then -- 1661
		inv.pass = inv.pass - 1 -- 1664
		self.run.joined = true -- 1665
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 1666
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 1667
		return -- 1668
	end -- 1668
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 1670
end -- 1626
function Play.prototype.useInteract(self, b) -- 1673
	local kind = b.interact == nil and "" or b.interact.kind -- 1674
	local wr = self.room -- 1675
	if kind == "open_board" then -- 1675
		b.broken = true -- 1677
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 1678
		for ____, cover in ipairs(self.boxes) do -- 1679
			if cover.id == "s2_board_cover" then -- 1679
				cover.broken = false -- 1681
				cover.hidden = false -- 1682
			end -- 1682
		end -- 1682
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 1685
		self.run.joined = true -- 1686
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 1687
		self:log("放下窗板") -- 1688
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 1689
		return -- 1690
	end -- 1690
	if kind == "lower_curtain" then -- 1690
		for ____, curtain in ipairs(self.boxes) do -- 1693
			if curtain.id == "c2_curtain" then -- 1693
				curtain.broken = false -- 1695
				curtain.hidden = false -- 1696
			end -- 1696
		end -- 1696
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 1699
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 1700
		self:log("放下木帘") -- 1701
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 1702
		return -- 1703
	end -- 1703
	if kind == "raise_latch" then -- 1703
		if wr.key == "c2-granary" and not self.cartDocked then -- 1703
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 1707
			return -- 1708
		end -- 1708
		b.broken = true -- 1710
		self.objectiveDone = true -- 1711
		if wr.key == "c1-yard" then -- 1711
			self.run.c1Latch = true -- 1714
			self.run.joined = true -- 1715
		else -- 1715
			self.run.c2Latch = true -- 1717
			self.run.joined = true -- 1718
		end -- 1718
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 1720
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 1721
		self:log("抬闩") -- 1722
		self:flashSet("抬闩 · 通路打开", 1.4) -- 1723
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 1724
	end -- 1724
end -- 1673
function Play.prototype.stepCampaignCart(self, dt, input) -- 1729
	local wr = self.room -- 1730
	local c = wr.cart -- 1731
	if c.bodyW <= 0 then -- 1731
		return -- 1733
	end -- 1733
	local p = self.player -- 1735
	local handleX = self.cartAxle + c.handleOffset -- 1736
	if not self.gripping then -- 1736
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 1736
			self.gripping = true -- 1740
			self:flashSet("握住车柄 · A/D 推", 1) -- 1741
		end -- 1741
		return -- 1743
	end -- 1743
	if input.interact.pressed then -- 1743
		self.gripping = false -- 1746
		self:flashSet("松手", 0.5) -- 1747
		return -- 1748
	end -- 1748
	if not self.cartDocked then -- 1748
		if input.moveX ~= 0 and not self:stuckCart() then -- 1748
			self.cartAxle = math.max( -- 1752
				c.startX, -- 1752
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 1752
			) -- 1752
		end -- 1752
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 1752
			self.cartExposed = true -- 1757
			local gun = nil -- 1758
			local gi = 0 -- 1759
			do -- 1759
				gi = 0 -- 1760
				while gi < #self.enemies do -- 1760
					local e = self.enemies[gi + 1] -- 1761
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 1761
						gun = e -- 1763
						break -- 1764
					end -- 1764
					gi = gi + 1 -- 1760
				end -- 1760
			end -- 1760
			if gun ~= nil then -- 1760
				self:campaignEnemyFire(gun) -- 1768
			end -- 1768
		end -- 1768
		p.x = self.cartAxle + c.handleOffset -- 1771
		p.y = c.baseY + (c.depth or 0) -- 1772
		p.vx = 0 -- 1773
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 1773
			self.cartAxle = c.endX -- 1775
			self.cartDocked = true -- 1776
			self.gripping = false -- 1777
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 1778
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 1779
			self:flashSet("车轮入窝", 1.2) -- 1780
			self:log("车轮入窝") -- 1781
		end -- 1781
	end -- 1781
end -- 1729
function Play.prototype.stuckCart(self) -- 1787
	local i = 0 -- 1788
	do -- 1788
		i = 0 -- 1789
		while i < #self.boxes do -- 1789
			do -- 1789
				local b = self.boxes[i + 1] -- 1790
				if b.broken == true or b.breakable == nil or b.soft == true then -- 1790
					goto __continue287 -- 1792
				end -- 1792
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 1794
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 1794
					return true -- 1796
				end -- 1796
			end -- 1796
			::__continue287:: -- 1796
			i = i + 1 -- 1789
		end -- 1789
	end -- 1789
	return false -- 1799
end -- 1787
function Play.prototype.stepCampaignGoal(self) -- 1803
	local wr = self.room -- 1804
	local c = wr.campaign -- 1805
	if c == nil then -- 1805
		return -- 1807
	end -- 1807
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 1807
		self.objectiveDone = true -- 1810
	end -- 1810
	if c.goal == "reach_exit" then -- 1810
		self.objectiveDone = true -- 1813
	end -- 1813
	if not self.objectiveDone then -- 1813
		return -- 1816
	end -- 1816
	local p = self.player -- 1818
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 1819
	if p.x < c.exitX or not partnerOk then -- 1819
		return -- 1821
	end -- 1821
	if c.next ~= nil and c.next ~= "" then -- 1821
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 1824
		self:flashSet("过关 · " .. c.next, 1.2) -- 1825
	elseif not self.run.finished then -- 1825
		self.run.finished = true -- 1827
		self:flashSet( -- 1828
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 1828
			2 -- 1828
		) -- 1828
		self:log("C2 灰盒完成") -- 1829
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 1830
	end -- 1830
end -- 1803
function Play.prototype.stepCampaignPartner(self, dt) -- 1835
	local a = self.partner -- 1836
	local wr = self.room -- 1837
	local cp = wr.companion -- 1838
	if not a.alive then -- 1838
		return -- 1840
	end -- 1840
	local p = self.player -- 1842
	local wait = false -- 1843
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 1844
	local targetDepth = p.depth -- 1845
	if self.run.joined == false then -- 1845
		wait = true -- 1847
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1848
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1849
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 1849
		wait = true -- 1851
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1852
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1853
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 1853
		wait = true -- 1855
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1856
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1857
	end -- 1857
	if self.partnerStuck > 0.3 then -- 1857
		a.x = a.x - a.facing * 30 -- 1861
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 1862
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 1863
		self.partnerLaneHold = 1.1 -- 1864
		self.partnerStuck = 0 -- 1865
	end -- 1865
	if self.partnerLaneHold > 0 then -- 1865
		self.partnerLaneHold = self.partnerLaneHold - dt -- 1868
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 1869
	end -- 1869
	local dx = targetX - a.x -- 1871
	if not wait and math.abs(dx) > 74 then -- 1871
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 1873
		local before = a.x -- 1874
		a.vx = dx > 0 and speed or -speed -- 1875
		a.facing = dx > 0 and 1 or -1 -- 1876
		self:slideX(a, a.vx * dt) -- 1877
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 1877
			a.vy = CHILD_JUMP -- 1880
			a.onGround = false -- 1881
		end -- 1881
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 1883
	else -- 1883
		a.vx = 0 -- 1885
		self.partnerStuck = 0 -- 1886
	end -- 1886
	local dz = targetDepth - a.depth -- 1888
	if math.abs(dz) > 6 then -- 1888
		local step = math.max( -- 1890
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 1890
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 1890
		) -- 1890
		a.depth = a.depth + step -- 1891
	end -- 1891
	a.depthSpeed = 0 -- 1893
	a.h = CHILD_H -- 1894
	a.crouch = false -- 1895
	self:fallY(a, dt) -- 1896
end -- 1835
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 1900
	local p = self.player -- 1901
	local i = 0 -- 1902
	do -- 1902
		i = 0 -- 1903
		while i < #self.enemies do -- 1903
			do -- 1903
				local e = self.enemies[i + 1] -- 1904
				if not e.alive then -- 1904
					goto __continue311 -- 1906
				end -- 1906
				if e.hitT > 0 then -- 1906
					e.hitT = e.hitT - dt -- 1909
				end -- 1909
				if e.kind == "breaker" then -- 1909
					self:stepBreaker(e, dt) -- 1912
					goto __continue311 -- 1913
				end -- 1913
				if e.kind == "shield" then -- 1913
					self:stepShield(e, dt, input) -- 1916
					goto __continue311 -- 1917
				end -- 1917
				local dx = e.x - p.x -- 1920
				if not e.awake then -- 1920
					if math.abs(dx) > 520 then -- 1920
						goto __continue311 -- 1923
					end -- 1923
					e.awake = true -- 1925
					e.fireCd = 48 -- 1926
					goto __continue311 -- 1927
				end -- 1927
				if math.abs(dx) > ENEMY_RANGE then -- 1927
					goto __continue311 -- 1930
				end -- 1930
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 1930
					goto __continue311 -- 1935
				end -- 1935
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 1935
					goto __continue311 -- 1938
				end -- 1938
				if self:blockedShot(e, p) then -- 1938
					if e.warnT > 0 then -- 1938
						e.warnT = 0 -- 1944
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 1945
					end -- 1945
					goto __continue311 -- 1947
				end -- 1947
				if e.warnT > 0 then -- 1947
					e.warnT = e.warnT - 1 -- 1950
					if e.warnT <= 0 then -- 1950
						self:campaignEnemyFire(e) -- 1952
					end -- 1952
				elseif e.fireCd > 0 then -- 1952
					e.fireCd = e.fireCd - 1 -- 1955
					if e.fireCd <= 0 then -- 1955
						e.warnT = WARN_TICKS -- 1957
					end -- 1957
				else -- 1957
					e.fireCd = 40 -- 1960
				end -- 1960
			end -- 1960
			::__continue311:: -- 1960
			i = i + 1 -- 1903
		end -- 1903
	end -- 1903
end -- 1900
function Play.prototype.blockedShot(self, e, p) -- 1966
	local eDepth = e.depth or 0 -- 1967
	local ex = e.x -- 1968
	local ey = e.y + e.h * 0.62 -- 1970
	local px = p.x -- 1971
	local py = p.y + p.h * 0.55 -- 1972
	local dx = px - ex -- 1973
	local dyScreen = py + p.depth - (ey + eDepth) -- 1974
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 1975
	if len < 0.01 then -- 1975
		return false -- 1977
	end -- 1977
	local ray = { -- 1981
		x = ex, -- 1982
		y = ey, -- 1982
		dx = dx / len, -- 1983
		dy = (py - ey) / len, -- 1983
		depth = eDepth, -- 1984
		dDepth = (p.depth - eDepth) / len -- 1984
	} -- 1984
	local best = -1 -- 1986
	local j = 0 -- 1987
	do -- 1987
		j = 0 -- 1988
		while j < #self.boxes do -- 1988
			do -- 1988
				local b = self.boxes[j + 1] -- 1989
				if b.broken == true or b.passable == true then -- 1989
					goto __continue331 -- 1991
				end -- 1991
				if b.id == "braced_shield" then -- 1991
					goto __continue331 -- 1996
				end -- 1996
				local t = hitBox(ray, b) -- 1998
				if t >= 0 and t < len - 2 and (best < 0 or t < best) then -- 1998
					best = t -- 2000
				end -- 2000
			end -- 2000
			::__continue331:: -- 2000
			j = j + 1 -- 1988
		end -- 1988
	end -- 1988
	return best >= 0 -- 2003
end -- 1966
function Play.prototype.campaignEnemyFire(self, e) -- 2006
	local p = self.player -- 2007
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2008
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 2008
		local ____self_bracedShield_34, ____hp_35 = self.bracedShield, "hp" -- 2008
		____self_bracedShield_34[____hp_35] = ____self_bracedShield_34[____hp_35] - 1 -- 2010
		self.boxes = __TS__ArrayFilter( -- 2011
			self.boxes, -- 2011
			function(____, b) return b.id ~= "braced_shield" end -- 2011
		) -- 2011
		self.bracedShield = nil -- 2012
		self:flashSet("残盾碎 · 挡下一发", 1) -- 2013
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 2014
		return -- 2015
	end -- 2015
	if self:blockedShot(e, p) then -- 2015
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 2018
		return -- 2019
	end -- 2019
	local cover = self:blockedByCover(e, p) -- 2021
	if cover ~= nil and self.coverHug then -- 2021
		self.coveredFlash = 0.5 -- 2023
		self:flashSet("掩体挡下", 0.6) -- 2024
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2025
		return -- 2030
	end -- 2030
	if self.invulnT > 0 then -- 2030
		return -- 2033
	end -- 2033
	self.invulnT = INVULN_HIT_TICKS -- 2035
	self.hp = self.hp - 1 -- 2036
	self:emit("actorHit", { -- 2037
		target = "player", -- 2037
		amount = 1, -- 2037
		hp = self.hp, -- 2037
		maxHp = self.maxHp, -- 2037
		enemyX = e.x -- 2037
	}) -- 2037
	self:flashSet( -- 2038
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2038
		0.8 -- 2038
	) -- 2038
	if self.hp <= 0 then -- 2038
		self:campaignFailed() -- 2040
	end -- 2040
end -- 2006
function Play.prototype.stepShield(self, e, dt, input) -- 2045
	local p = self.player -- 2046
	local dx = p.x - e.x -- 2047
	local adx = math.abs(dx) -- 2048
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 2051
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 2052
	if adx > 150 then -- 2052
		local before = e.x -- 2054
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 2055
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 2055
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2058
		end -- 2058
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 2058
		local fromFront = (e.x - p.x) * p.facing > 0 -- 2063
		local rollDodges = p.rollT > 0 and fromFront -- 2064
		if not rollDodges and self.invulnT <= 0 then -- 2064
			self.invulnT = INVULN_HIT_TICKS -- 2066
			self.hp = self.hp - 1 -- 2067
			self:emit("actorHit", { -- 2068
				target = "player", -- 2068
				amount = 1, -- 2068
				hp = self.hp, -- 2068
				maxHp = self.maxHp, -- 2068
				enemyX = e.x -- 2068
			}) -- 2068
			self:flashSet( -- 2069
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2069
				0.8 -- 2069
			) -- 2069
			if self.hp <= 0 then -- 2069
				self:campaignFailed() -- 2071
				return -- 2072
			end -- 2072
		end -- 2072
		e.swingT = 70 -- 2075
	end -- 2075
	if (e.swingT or 0) > 0 then -- 2075
		e.swingT = (e.swingT or 0) - 1 -- 2078
	end -- 2078
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 2078
		local dd = p.depth - (e.depth or 0) -- 2081
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 2082
	end -- 2082
end -- 2045
function Play.prototype.stepBreaker(self, e, dt) -- 2087
	local p = self.player -- 2088
	if e.awake ~= true then -- 2088
		if math.abs(p.x - e.x) < 560 then -- 2088
			e.awake = true -- 2091
		else -- 2091
			return -- 2093
		end -- 2093
	end -- 2093
	local target = nil -- 2096
	local bestD = 1000000000 -- 2097
	local i = 0 -- 2098
	do -- 2098
		i = 0 -- 2099
		while i < #self.boxes do -- 2099
			do -- 2099
				local b = self.boxes[i + 1] -- 2100
				if b.breakable == nil or b.broken == true then -- 2100
					goto __continue355 -- 2102
				end -- 2102
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 2104
				if d < bestD then -- 2104
					bestD = d -- 2106
					target = b -- 2107
				end -- 2107
			end -- 2107
			::__continue355:: -- 2107
			i = i + 1 -- 2099
		end -- 2099
	end -- 2099
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 2110
	local dx = tx - e.x -- 2111
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 2112
	if math.abs(dx) > reach then -- 2112
		local before = e.x -- 2114
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 2115
		if math.abs(e.x - before) < 0.3 then -- 2115
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2117
		end -- 2117
	elseif (e.swingT or 0) <= 0 then -- 2117
		e.swingT = 64 -- 2120
		if target ~= nil then -- 2120
			self:damageProp(target, 2) -- 2122
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 2122
			self.invulnT = INVULN_HIT_TICKS -- 2124
			self.hp = self.hp - 1 -- 2125
			self:emit("actorHit", { -- 2126
				target = "player", -- 2126
				amount = 1, -- 2126
				hp = self.hp, -- 2126
				maxHp = self.maxHp, -- 2126
				enemyX = e.x -- 2126
			}) -- 2126
			self:flashSet("破障手近身", 0.8) -- 2127
			if self.hp <= 0 then -- 2127
				self:campaignFailed() -- 2129
				return -- 2130
			end -- 2130
		end -- 2130
	end -- 2130
	if (e.swingT or 0) > 0 then -- 2130
		e.swingT = (e.swingT or 0) - 1 -- 2135
	end -- 2135
end -- 2087
function Play.prototype.campaignFailed(self) -- 2139
	local p = self.player -- 2140
	self.hp = self.maxHp -- 2141
	self.invulnT = INVULN_RESPAWN_TICKS -- 2142
	self.reloadT = 0 -- 2143
	self.gripping = false -- 2144
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 2145
	self:log("被击倒") -- 2146
	p.x = self.room.minX + 90 -- 2147
	p.y = 0 -- 2148
	p.depth = 0 -- 2149
	p.vx = 0 -- 2150
	p.vy = 0 -- 2151
	p.onGround = true -- 2152
	p.rollT = 0 -- 2153
	self.partner.x = p.x - 50 -- 2154
	self.partner.y = 0 -- 2155
	self.partner.depth = 0 -- 2156
	self.cam.x = p.x -- 2157
	local i = 0 -- 2158
	do -- 2158
		i = 0 -- 2159
		while i < #self.enemies do -- 2159
			do -- 2159
				local e = self.enemies[i + 1] -- 2160
				if not e.alive then -- 2160
					goto __continue367 -- 2162
				end -- 2162
				e.x = e.homeX == nil and e.x or e.homeX -- 2164
				e.warnT = 0 -- 2165
				e.fireCd = 40 -- 2166
				e.swingT = 0 -- 2167
				e.awake = false -- 2168
			end -- 2168
			::__continue367:: -- 2168
			i = i + 1 -- 2159
		end -- 2159
	end -- 2159
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 2170
end -- 2139
function Play.prototype.stepEnemies(self, dt, input) -- 2173
	local i = 0 -- 2174
	do -- 2174
		i = 0 -- 2175
		while i < #self.enemies do -- 2175
			local e = self.enemies[i + 1] -- 2176
			if e.hitT > 0 then -- 2176
				e.hitT = e.hitT - dt -- 2178
			end -- 2178
			i = i + 1 -- 2175
		end -- 2175
	end -- 2175
	if self.coveredFlash > 0 then -- 2175
		self.coveredFlash = self.coveredFlash - dt -- 2182
	end -- 2182
	if self.isCampaign then -- 2182
		self:stepCampaignEnemies(dt, input) -- 2185
		return -- 2186
	end -- 2186
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 2186
		return -- 2190
	end -- 2190
	do -- 2190
		i = 0 -- 2192
		while i < #self.enemies do -- 2192
			do -- 2192
				local e = self.enemies[i + 1] -- 2193
				if not e.alive then -- 2193
					goto __continue377 -- 2195
				end -- 2195
				if e.warnT > 0 then -- 2195
					e.warnT = e.warnT - 1 -- 2198
					if e.warnT <= 0 then -- 2198
						self:enemyFire(e, input) -- 2200
					end -- 2200
					goto __continue377 -- 2202
				end -- 2202
				if e.fireCd > 0 then -- 2202
					e.fireCd = e.fireCd - 1 -- 2205
					if e.fireCd <= 0 then -- 2205
						e.warnT = WARN_TICKS -- 2207
					end -- 2207
				else -- 2207
					e.warnT = WARN_TICKS -- 2211
				end -- 2211
			end -- 2211
			::__continue377:: -- 2211
			i = i + 1 -- 2192
		end -- 2192
	end -- 2192
end -- 2173
function Play.prototype.enemyFire(self, e, input) -- 2217
	local p = self.player -- 2218
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 2218
		self:flashSet("枪声响在远处", 0.4) -- 2220
		e.fireCd = FIRE_COOLDOWN -- 2221
		return -- 2222
	end -- 2222
	local cover = self:blockedByCover(e, p) -- 2225
	local hugging = cover ~= nil -- 2226
	self.coverBlocking = hugging -- 2227
	local covered = hugging and input.cover.held -- 2228
	if covered then -- 2228
		self.coveredFlash = 0.5 -- 2230
		self:flashSet("掩体挡下", 0.5) -- 2231
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2232
		e.fireCd = FIRE_COOLDOWN -- 2237
		return -- 2238
	end -- 2238
	self.hp = self.hp - 1 -- 2240
	self:emit("actorHit", { -- 2241
		target = "player", -- 2241
		amount = 1, -- 2241
		hp = self.hp, -- 2241
		maxHp = self.maxHp, -- 2241
		enemyX = e.x -- 2241
	}) -- 2241
	self:flashSet( -- 2242
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2242
		0.7 -- 2242
	) -- 2242
	e.fireCd = FIRE_COOLDOWN -- 2243
	if self.hp <= 0 then -- 2243
		self:gateFailed() -- 2245
	end -- 2245
end -- 2217
function Play.prototype.blockedByCover(self, enemy, p) -- 2250
	local b = self:coverAt(p) -- 2251
	if b == nil then -- 2251
		return nil -- 2253
	end -- 2253
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 2255
end -- 2250
function Play.prototype.gateFailed(self) -- 2259
	local ____temp_36 -- 2260
	if self.room.story == nil then -- 2260
		____temp_36 = nil -- 2260
	else -- 2260
		____temp_36 = self.room.story.gate -- 2260
	end -- 2260
	local g = ____temp_36 -- 2260
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 2261
	self.hp = self.maxHp -- 2262
	self.gateTick = 0 -- 2263
	self.gateSpawned = 0 -- 2264
	self.enemies = {} -- 2265
	self.gateFailCount = self.gateFailCount + 1 -- 2266
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 2268
	self.player.y = 0 -- 2269
	self.player.vy = 0 -- 2270
	self.player.depth = 0 -- 2271
	self.player.depthSpeed = 0 -- 2272
	self.player.onGround = true -- 2273
	self.player.crouch = false -- 2274
	self.player.h = SOLDIER_H -- 2275
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 2276
	self.partner.y = 0 -- 2277
	self.partner.vy = 0 -- 2278
	self.partner.depth = 0 -- 2279
	self.partner.depthSpeed = 0 -- 2280
	self.partner.onGround = true -- 2281
	self.cam.x = self.player.x -- 2282
	self.phase = "gate-idle" -- 2283
	self.phaseTick = 0 -- 2284
	self.coverHug = false -- 2285
	self.coverBlocking = false -- 2286
	self.coverEntity = "" -- 2287
	self.gateNeedConfirm = true -- 2288
	self.gateRestartArmed = false -- 2289
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 2290
end -- 2259
function Play.prototype.stepInteract(self, dt, input) -- 2293
	local p = self.player -- 2294
	local calmUsed = self.calmConsumed -- 2295
	self.calmConsumed = false -- 2296
	local calming = self.escort.state == "calming" -- 2298
	self.focusCart = false -- 2299
	if self.room.key == "outside" then -- 2299
		local c = self.room.cart -- 2301
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 2302
		local dy = p.y - c.baseY -- 2303
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 2304
	end -- 2304
	if not calmUsed and not calming then -- 2304
		self:stepCart(dt, input) -- 2308
	end -- 2308
	if calmUsed then -- 2308
		self:flashSet("安抚 · 敲两下", 0.8) -- 2313
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 2313
		if self.knockT > 0 then -- 2313
			self.knocks = self.knocks + 1 -- 2317
		else -- 2317
			self.knocks = 1 -- 2319
		end -- 2319
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 2321
		self.knockT = 1.2 -- 2322
		if self.knocks >= 2 then -- 2322
			self:flashSet("敲两下", 0.8) -- 2324
			self.knocks = 0 -- 2325
		else -- 2325
			self:flashSet("敲一下", 0.5) -- 2327
		end -- 2327
	elseif self.knockT > 0 then -- 2327
		self.knockT = self.knockT - dt -- 2330
		if self.knockT <= 0 then -- 2330
			self.knocks = 0 -- 2332
		end -- 2332
	end -- 2332
	local i = 0 -- 2337
	do -- 2337
		i = 0 -- 2338
		while i < #self.room.marks do -- 2338
			do -- 2338
				local m = self.room.marks[i + 1] -- 2339
				if m.kind ~= 0 then -- 2339
					goto __continue403 -- 2341
				end -- 2341
				local subjects = {self.partner, self.player} -- 2343
				local k = 0 -- 2344
				do -- 2344
					k = 0 -- 2345
					while k < #subjects do -- 2345
						do -- 2345
							local s = subjects[k + 1] -- 2346
							if not s.alive then -- 2346
								goto __continue406 -- 2348
							end -- 2348
							local dx = s.x - m.x -- 2350
							local dy = s.y - m.y -- 2351
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2351
								self.checkpoint = m.x -- 2353
								self.checkpointCartAxle = self.cartAxle -- 2354
								if self.cartDocked then -- 2354
									self:flashSet("检查点 · 车已落窝", 1) -- 2356
								else -- 2356
									self:flashSet("检查点 · 车还没到位", 1) -- 2358
								end -- 2358
							end -- 2358
						end -- 2358
						::__continue406:: -- 2358
						k = k + 1 -- 2345
					end -- 2345
				end -- 2345
			end -- 2345
			::__continue403:: -- 2345
			i = i + 1 -- 2338
		end -- 2338
	end -- 2338
	self:checkCarryGate() -- 2364
end -- 2293
function Play.prototype.stepVillage(self, dt, input) -- 2368
	if self.room.key ~= "village" then -- 2368
		return -- 2370
	end -- 2370
	local p = self.player -- 2372
	local bottle = self.room.bottle -- 2373
	local scav = self.room.scavenger -- 2374
	if not self.hasBottle and bottle ~= nil then -- 2374
		local dx = p.x - bottle.x -- 2378
		local dy = p.y + p.h * 0.5 - bottle.y -- 2379
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 2379
			self.hasBottle = true -- 2381
			self:flashSet("拾起瓶子", 0.8) -- 2382
		end -- 2382
	end -- 2382
	if self.hasBottle then -- 2382
		if input.aim.held then -- 2382
			self.aimHold = self.aimHold + dt -- 2389
			if self.aimHold > 1.2 then -- 2389
				self.aimHold = 1.2 -- 2391
			end -- 2391
			local cached = self:bottleEnd() -- 2394
			self.bottleAimX = cached.x -- 2395
			self.bottleAimY = cached.y -- 2396
		elseif input.aim.released then -- 2396
			if self.aimHold < 0.12 then -- 2396
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 2400
				self.aimHold = 0 -- 2401
			else -- 2401
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2403
				self:throwBottle(____end.x, ____end.y) -- 2404
				self.aimHold = 0 -- 2405
			end -- 2405
		end -- 2405
	else -- 2405
		self.aimHold = 0 -- 2409
		self.bottleAimX = -1 -- 2410
	end -- 2410
	local fly = self.bottleFly -- 2415
	if fly ~= nil then -- 2415
		fly.t = fly.t + dt -- 2417
		fly.x = fly.x0 + fly.vx * fly.t -- 2418
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 2419
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 2420
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 2420
			self:landBottle(fly) -- 2422
		end -- 2422
	end -- 2422
	if self.bottleLandT > 0 then -- 2422
		self.bottleLandT = self.bottleLandT - dt -- 2426
	end -- 2426
	if scav ~= nil then -- 2426
		self:stepScav(dt, scav) -- 2430
	end -- 2430
	local line = self.room.passLine -- 2433
	if line ~= nil and not self.passed and p.x >= line then -- 2433
		self.passed = true -- 2435
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 2436
	end -- 2436
	if self.passed and p.x >= self.ox + 640 then -- 2436
		self:requestRoom("forest", "过第一院出院") -- 2440
		self:flashSet("出院 · 北塔森林", 1.4) -- 2441
	end -- 2441
end -- 2368
function Play.prototype.bottleEnd(self) -- 2446
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2447
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 2450
	return {x = aim.x, y = g} -- 2451
end -- 2446
function Play.prototype.throwBottle(self, tx, ty) -- 2455
	local p = self.player -- 2456
	local dir = tx >= p.x and 1 or -1 -- 2458
	p.facing = dir -- 2459
	local x0 = p.x + dir * 10 -- 2460
	local y0 = p.y + p.h * 0.7 -- 2461
	self.bottleTargetX = tx -- 2462
	self.bottleTargetY = ty -- 2463
	self.bottleSurfaceY = ty -- 2464
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 2465
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 2466
	self.bottleFly = { -- 2467
		x = x0, -- 2467
		y = y0, -- 2467
		x0 = x0, -- 2467
		y0 = y0, -- 2467
		vx = vx, -- 2467
		vy = vy, -- 2467
		t = 0 -- 2467
	} -- 2467
	self.hasBottle = false -- 2468
	self:flashSet("投出", 0.4) -- 2469
	self:emit( -- 2470
		"bottleThrown", -- 2470
		{ -- 2470
			fromX = x0, -- 2471
			fromY = y0, -- 2472
			targetX = tx, -- 2473
			targetY = ty, -- 2474
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 2475
		} -- 2475
	) -- 2475
end -- 2455
function Play.prototype.landBottle(self, fly) -- 2480
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 2481
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 2482
	local s = self.room.scavenger -- 2483
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 2484
	self.bottleFly = nil -- 2485
	self.bottleTargetX = -1 -- 2486
	self.bottleTargetY = 0 -- 2487
	self.bottleSurfaceY = -1 -- 2488
	self.bottleLandX = x -- 2489
	self.bottleLandY = y -- 2490
	self.bottleLandT = 0.9 -- 2491
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 2492
	self:hearBottle(x) -- 2493
end -- 2480
function Play.prototype.hearBottle(self, x) -- 2497
	local s = self.room.scavenger -- 2498
	if s == nil then -- 2498
		return -- 2500
	end -- 2500
	if math.abs(x - self.scavX) > s.range then -- 2500
		self:flashSet("落地 · 他没听见", 0.6) -- 2503
		return -- 2504
	end -- 2504
	self.scavState = "turn" -- 2506
	self.scavT = s.hearTicks -- 2507
	self.scavTargetX = x -- 2508
	self:flashSet("砖地一响 · 他转头", 0.9) -- 2509
end -- 2497
function Play.prototype.stepScav(self, dt, s) -- 2513
	if self.scavState == "chase" then -- 2513
		return -- 2516
	end -- 2516
	if self.scavState == "turn" then -- 2516
		self.scavT = self.scavT - 1 -- 2519
		if self.scavT <= 0 then -- 2519
			self.scavState = "walk" -- 2521
		end -- 2521
		return -- 2523
	end -- 2523
	if self.scavState == "walk" then -- 2523
		local d = self.scavTargetX - self.scavX -- 2526
		if math.abs(d) < 4 then -- 2526
			self.scavState = "stall" -- 2528
			self.scavT = s.stallTicks -- 2529
			return -- 2530
		end -- 2530
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 2532
		return -- 2533
	end -- 2533
	if self.scavState == "stall" then -- 2533
		self.scavT = self.scavT - 1 -- 2536
		if self.scavT <= 0 then -- 2536
			self.scavState = "back" -- 2538
		end -- 2538
		return -- 2540
	end -- 2540
	if self.scavState == "back" then -- 2540
		local home = math.max( -- 2543
			s.x0, -- 2543
			math.min(s.x1, self.scavX) -- 2543
		) -- 2543
		if math.abs(home - self.scavX) < 2 then -- 2543
			self.scavState = "patrol" -- 2545
			return -- 2546
		end -- 2546
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 2548
		return -- 2549
	end -- 2549
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 2551
	if self.scavX >= s.x1 then -- 2551
		self.scavX = s.x1 -- 2553
		self.scavDir = -1 -- 2554
	elseif self.scavX <= s.x0 then -- 2554
		self.scavX = s.x0 -- 2556
		self.scavDir = 1 -- 2557
	end -- 2557
end -- 2513
function Play.prototype.stepCart(self, dt, input) -- 2565
	local p = self.player -- 2566
	local c = self.room.cart -- 2567
	if self.gripping then -- 2567
		if not input.interact.held then -- 2567
			self.gripping = false -- 2571
			self:flashSet("松开车把", 0.4) -- 2572
			return -- 2573
		end -- 2573
	else -- 2573
		if not input.interact.pressed then -- 2573
			return -- 2577
		end -- 2577
		if not self:cartHandleInReach(p) then -- 2577
			return -- 2580
		end -- 2580
		local track = c.depth or 0 -- 2582
		if self:limitDepth(p, track) ~= track then -- 2582
			return -- 2584
		end -- 2584
		p.depth = track -- 2586
		p.depthSpeed = 0 -- 2587
		self.gripping = true -- 2588
		self:flashSet("握住车把", 0.4) -- 2589
		return -- 2590
	end -- 2590
	if self.cartDocked then -- 2590
		return -- 2594
	end -- 2594
	local dir = input.moveX -- 2596
	if dir == 0 then -- 2596
		return -- 2598
	end -- 2598
	local lo = math.min(c.startX, c.endX) -- 2600
	local hi = math.max(c.startX, c.endX) -- 2601
	local next = self.cartAxle + dir * CART_SPEED * dt -- 2602
	if next < lo then -- 2602
		next = lo -- 2604
	end -- 2604
	if next > hi then -- 2604
		next = hi -- 2607
	end -- 2607
	local delta = next - self.cartAxle -- 2609
	if delta == 0 then -- 2609
		return -- 2611
	end -- 2611
	self.cartAxle = next -- 2613
	p.x = p.x + delta -- 2614
	p.facing = dir > 0 and 1 or -1 -- 2615
	self:slideX(p, 0) -- 2616
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 2616
		self.gripping = false -- 2618
		self:flashSet("跟不上了，脱手", 0.6) -- 2619
		return -- 2620
	end -- 2620
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 2620
		self.cartDocked = true -- 2623
		self.gripping = false -- 2624
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 2625
		self:flashSet("车轮落窝", 1.2) -- 2626
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 2626
		self:flashSet("车轮回到起点", 0.5) -- 2628
	end -- 2628
end -- 2565
function Play.prototype.requestRoom(self, key, reason) -- 2636
	if self.wantRoom ~= "" then -- 2636
		return -- 2640
	end -- 2640
	self.wantRoom = key -- 2642
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 2643
end -- 2636
function Play.prototype.checkCarryGate(self) -- 2650
	if self.room.key == "checkpoint" then -- 2650
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 2650
			self.carryCartAxle = self.cartAxle -- 2653
			self.carryCartDocked = self.cartDocked -- 2654
			self:requestRoom("gate", "检查站出口") -- 2655
			self:flashSet("出检查站 · 城门", 1.2) -- 2656
		end -- 2656
		return -- 2658
	end -- 2658
	if self.room.key == "outside" then -- 2658
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 2658
			self.carryCartAxle = self.cartAxle -- 2664
			self.carryCartDocked = self.cartDocked -- 2665
			self:requestRoom("village", "墙根走完") -- 2666
			self:flashSet("墙根走完 · 进村口", 1.2) -- 2667
		end -- 2667
	end -- 2667
end -- 2650
function Play.prototype.aimAt(self, wx, wy) -- 2674
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 2675
	self.aimX = s.x -- 2676
	self.aimY = s.y -- 2677
end -- 2674
function Play.prototype.shoot(self, a) -- 2680
	if self.isCampaign and self.reloadT > 0 then -- 2680
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 2682
		return -- 2683
	end -- 2683
	local ox = a.x + a.facing * 8 -- 2685
	local muzzleY = a.y + a.h * 0.72 -- 2686
	local oy = muzzleY + a.depth -- 2687
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2689
	local dx = aim.x - ox -- 2692
	local dy = aim.y - oy -- 2693
	local len = math.sqrt(dx * dx + dy * dy) -- 2694
	if len < 0.001 then -- 2694
		dx = a.facing -- 2696
		dy = 0 -- 2697
	else -- 2697
		dx = dx / len -- 2699
		dy = dy / len -- 2700
	end -- 2700
	if dx ~= 0 then -- 2700
		a.facing = dx > 0 and 1 or -1 -- 2703
	end -- 2703
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 2706
	local hitEnemy = self:raycastEnemies(ray) -- 2707
	local tEnemy = hitEnemy.t -- 2708
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 2709
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 2710
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 2711
	local tWall = solid.t -- 2712
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 2713
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 2714
	self.trace = { -- 2716
		x0 = ox, -- 2716
		y0 = oy, -- 2716
		x1 = ox + dx * t, -- 2716
		y1 = oy + dy * t, -- 2716
		hit = hit -- 2716
	} -- 2716
	self.traceT = 0.12 -- 2717
	self:applyFireDanger(ox) -- 2718
	local killed = false -- 2719
	if hit then -- 2719
		local i = hitEnemy.index -- 2721
		local e = self.enemies[i + 1] -- 2722
		local impactY = oy + dy * tEnemy -- 2723
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 2724
		local shieldTop = e.y + (e.depth or 0) + 64 -- 2725
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 2725
			e.shieldHp = (e.shieldHp or 0) - 1 -- 2727
			e.hitT = 0.3 -- 2728
			self:flashSet( -- 2729
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 2729
				0.8 -- 2729
			) -- 2729
			self:emit("shotResolved", { -- 2730
				hit = true, -- 2731
				enemyIndex = i, -- 2731
				enemyX = e.x, -- 2731
				aimX = aim.x, -- 2731
				aimY = aim.y, -- 2731
				impactX = ox + dx * t, -- 2732
				impactY = oy + dy * t, -- 2732
				shield = true -- 2732
			}) -- 2732
			self.reloadT = self.run.inventory.quickbelt > 0 and 36 or 54 -- 2734
			return -- 2735
		end -- 2735
		e.alive = false -- 2737
		e.hitT = 0.4 -- 2738
		killed = true -- 2739
		self:flashSet("命中", 0.6) -- 2740
		self:dropFor(e) -- 2741
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 2741
		self:damageProp(solid.box, 1) -- 2743
	else -- 2743
		self:flashSet("打空", 0.35) -- 2745
	end -- 2745
	if self.isCampaign then -- 2745
		self.reloadT = self.run.inventory.quickbelt > 0 and 36 or 54 -- 2748
	end -- 2748
	self:emit("shotResolved", { -- 2750
		hit = hit, -- 2751
		enemyIndex = hit and hitEnemy.index or -1, -- 2752
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 2753
		aimX = aim.x, -- 2754
		aimY = aim.y, -- 2755
		impactX = ox + dx * t, -- 2756
		impactY = oy + dy * t -- 2757
	}) -- 2757
end -- 2680
function Play.prototype.applyFireDanger(self, shotX) -- 2762
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 2762
		return -- 2764
	end -- 2764
	local dangerX = shotX -- 2766
	local best = -1 -- 2767
	local bestD = 1000000000 -- 2768
	local i = 0 -- 2769
	do -- 2769
		i = 0 -- 2770
		while i < #self.enemies do -- 2770
			do -- 2770
				local e = self.enemies[i + 1] -- 2771
				if not e.alive then -- 2771
					goto __continue482 -- 2773
				end -- 2773
				local d = math.abs(e.x - self.partner.x) -- 2775
				if d < bestD then -- 2775
					bestD = d -- 2777
					best = i -- 2778
				end -- 2778
			end -- 2778
			::__continue482:: -- 2778
			i = i + 1 -- 2770
		end -- 2770
	end -- 2770
	if best >= 0 then -- 2770
		dangerX = self.enemies[best + 1].x -- 2782
	end -- 2782
	local exposed = self:childExposed(dangerX) -- 2784
	local before = self.escort.fear -- 2785
	local dangerId = self.nextDangerId -- 2786
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 2787
	self.nextDangerId = self.nextDangerId + 1 -- 2788
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 2789
	if after > before then -- 2789
		self:flashSet( -- 2791
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 2791
			1 -- 2791
		) -- 2791
	elseif not exposed then -- 2791
		self:flashSet("枪声没够到她", 0.5) -- 2793
	end -- 2793
end -- 2762
function Play.prototype.childExposed(self, dangerX) -- 2798
	local c = self.partner -- 2799
	if not c.alive then -- 2799
		return false -- 2801
	end -- 2801
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 2801
		self.boxes, -- 2804
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 2804
	) then -- 2804
		return false -- 2805
	end -- 2805
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 2805
		return false -- 2808
	end -- 2808
	local toDanger = dangerX - c.x -- 2810
	local toPlayer = self.player.x - c.x -- 2811
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 2811
		return false -- 2814
	end -- 2814
	return true -- 2816
end -- 2798
function Play.prototype.raycastEnemies(self, ray) -- 2820
	local best = -1 -- 2821
	local bestI = -1 -- 2822
	do -- 2822
		local i = 0 -- 2823
		while i < #self.enemies do -- 2823
			do -- 2823
				local e = self.enemies[i + 1] -- 2824
				if not e.alive then -- 2824
					goto __continue496 -- 2826
				end -- 2826
				local y = e.y + (e.depth or 0) -- 2828
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 2829
				if t >= 0 and (best < 0 or t < best) then -- 2829
					best = t -- 2831
					bestI = i -- 2832
				end -- 2832
			end -- 2832
			::__continue496:: -- 2832
			i = i + 1 -- 2823
		end -- 2823
	end -- 2823
	return {t = best, index = bestI} -- 2835
end -- 2820
function Play.prototype.raycastWorld(self, ray) -- 2838
	return self:raycastSolid(ray).t -- 2839
end -- 2838
function Play.prototype.raycastSolid(self, ray) -- 2843
	local best = -1 -- 2844
	local bestBox = nil -- 2845
	for ____, box in ipairs(self.boxes) do -- 2846
		do -- 2846
			if box.broken == true or box.hidden == true then -- 2846
				goto __continue501 -- 2848
			end -- 2848
			local t = hitBox(ray, box) -- 2853
			if t >= 0 and (best < 0 or t < best) then -- 2853
				best = t -- 2855
				bestBox = box -- 2856
			end -- 2856
		end -- 2856
		::__continue501:: -- 2856
	end -- 2856
	if ray.dy < 0 then -- 2856
		local t = -ray.y / ray.dy -- 2860
		if t >= 0 and (best < 0 or t < best) then -- 2860
			best = t -- 2862
			bestBox = nil -- 2863
		end -- 2863
	end -- 2863
	return {t = best, box = bestBox} -- 2866
end -- 2843
function Play.prototype.dropFor(self, e) -- 2870
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 2870
		return -- 2872
	end -- 2872
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 2872
		return -- 2875
	end -- 2875
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 2877
	local ____self_pickups_37 = self.pickups -- 2877
	____self_pickups_37[#____self_pickups_37 + 1] = { -- 2878
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 2879
		kind = e.drop, -- 2879
		x = e.x, -- 2879
		y = e.y, -- 2879
		depth = e.depth, -- 2880
		label = label .. " ×1" -- 2880
	} -- 2880
	self:log("掉落 " .. label) -- 2882
end -- 2870
function Play.prototype.damageProp(self, b, amount) -- 2886
	if b.breakable == nil or b.broken == true then -- 2886
		return -- 2888
	end -- 2888
	local ____b_breakable_38, ____hp_39 = b.breakable, "hp" -- 2888
	____b_breakable_38[____hp_39] = ____b_breakable_38[____hp_39] - amount -- 2890
	if b.breakable.hp > 0 then -- 2890
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 2892
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 2893
		return -- 2894
	end -- 2894
	b.broken = true -- 2896
	for ____, other in ipairs(self.boxes) do -- 2897
		if other.id ~= nil and other.id == b.id then -- 2897
			other.broken = true -- 2899
		end -- 2899
	end -- 2899
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 2902
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 2903
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 2904
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 2905
end -- 2886
function Play.prototype.slideDepth(self, a, distance) -- 2909
	a.depth = self:limitDepth(a, a.depth + distance) -- 2910
end -- 2909
function Play.prototype.limitDepth(self, a, target) -- 2913
	local road = self.room.depth -- 2914
	if road == nil or target == a.depth then -- 2914
		return a.depth -- 2916
	end -- 2916
	local next = math.max( -- 2918
		road.min, -- 2918
		math.min(road.max, target) -- 2918
	) -- 2918
	local half = a.w / 2 -- 2919
	for ____, b in ipairs(self.boxes) do -- 2920
		do -- 2920
			local footprint = b.depth -- 2921
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 2921
				goto __continue519 -- 2926
			end -- 2926
			local front = footprint.min - ACTOR_DEPTH_HALF -- 2928
			local back = footprint.max + ACTOR_DEPTH_HALF -- 2929
			if a.depth <= front and next > front then -- 2929
				next = front -- 2931
			elseif a.depth >= back and next < back then -- 2931
				next = back -- 2933
			end -- 2933
		end -- 2933
		::__continue519:: -- 2933
	end -- 2933
	return next -- 2936
end -- 2913
function Play.prototype.slideX(self, a, dx) -- 2940
	local nx = a.x + dx -- 2941
	local half = a.w / 2 -- 2942
	local room = self.room -- 2943
	nx = math.max( -- 2944
		room.minX + half, -- 2944
		math.min(room.maxX - half, nx) -- 2944
	) -- 2944
	local i = 0 -- 2945
	do -- 2945
		i = 0 -- 2946
		while i < #self.boxes do -- 2946
			do -- 2946
				local b = self.boxes[i + 1] -- 2947
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 2947
					goto __continue526 -- 2949
				end -- 2949
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2949
					goto __continue526 -- 2952
				end -- 2952
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 2952
					goto __continue526 -- 2955
				end -- 2955
				if nx + half > b.x0 and nx - half < b.x1 then -- 2955
					if a.x <= b.x0 then -- 2955
						nx = b.x0 - half -- 2959
					elseif a.x >= b.x1 then -- 2959
						nx = b.x1 + half -- 2961
					else -- 2961
						nx = a.x -- 2963
					end -- 2963
				end -- 2963
			end -- 2963
			::__continue526:: -- 2963
			i = i + 1 -- 2946
		end -- 2946
	end -- 2946
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 2946
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 2971
		local bx0 = self.cartAxle - CART_HALF -- 2972
		local bx1 = self.cartAxle + CART_HALF -- 2973
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 2973
			if a.x <= bx0 then -- 2973
				nx = bx0 - half -- 2976
			elseif a.x >= bx1 then -- 2976
				nx = bx1 + half -- 2978
			else -- 2978
				nx = a.x -- 2980
			end -- 2980
		end -- 2980
	end -- 2980
	local arch = room.arch -- 2988
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 2988
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 2990
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 2990
			if a.x <= arch.x0 then -- 2990
				nx = arch.x0 - half -- 2993
			elseif a.x >= arch.x1 then -- 2993
				nx = arch.x1 + half -- 2995
			end -- 2995
		end -- 2995
	end -- 2995
	a.x = nx -- 2999
end -- 2940
function Play.prototype.fallY(self, a, dt) -- 3003
	a.vy = a.vy - ____exports.GRAVITY * dt -- 3004
	if a.vy < -900 then -- 3004
		a.vy = -900 -- 3006
	end -- 3006
	local ny = a.y + a.vy * dt -- 3008
	local half = a.w / 2 -- 3009
	if a.vy <= 0 then -- 3009
		local reach = a.onGround and STEP_UP or 0 -- 3012
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 3013
		if ny <= ground then -- 3013
			ny = ground -- 3015
			a.vy = 0 -- 3016
			a.onGround = true -- 3017
		else -- 3017
			a.onGround = false -- 3019
		end -- 3019
	else -- 3019
		a.onGround = false -- 3022
		local i = 0 -- 3023
		do -- 3023
			i = 0 -- 3024
			while i < #self.boxes do -- 3024
				do -- 3024
					local b = self.boxes[i + 1] -- 3025
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3025
						goto __continue550 -- 3027
					end -- 3027
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3027
						goto __continue550 -- 3030
					end -- 3030
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 3030
						goto __continue550 -- 3033
					end -- 3033
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 3033
						ny = b.y0 - a.h -- 3036
						a.vy = 0 -- 3037
					end -- 3037
				end -- 3037
				::__continue550:: -- 3037
				i = i + 1 -- 3024
			end -- 3024
		end -- 3024
	end -- 3024
	a.y = ny -- 3041
end -- 3003
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 3045
	if depth == nil then -- 3045
		depth = 0 -- 3045
	end -- 3045
	local g = -9999 -- 3046
	local i = 0 -- 3047
	do -- 3047
		i = 0 -- 3048
		while i < #self.floors do -- 3048
			local f = self.floors[i + 1] -- 3049
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 3049
				g = f.y1 -- 3051
			end -- 3051
			i = i + 1 -- 3048
		end -- 3048
	end -- 3048
	do -- 3048
		i = 0 -- 3054
		while i < #self.boxes do -- 3054
			do -- 3054
				local b = self.boxes[i + 1] -- 3055
				if b.broken == true or b.hidden == true or b.soft == true then -- 3055
					goto __continue560 -- 3057
				end -- 3057
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 3057
					g = b.y1 -- 3061
				end -- 3061
			end -- 3061
			::__continue560:: -- 3061
			i = i + 1 -- 3054
		end -- 3054
	end -- 3054
	return g -- 3064
end -- 3045
function Play.prototype.updateCamera(self, dt) -- 3067
	local p = self.player -- 3068
	local tx = p.x + p.facing * 30 -- 3069
	local ty = p.y + CAM_LOOK_UP -- 3070
	local k = math.min(1, CAM_FOLLOW * dt) -- 3071
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 3072
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 3073
end -- 3067
function Play.prototype.clampCamera(self, w, h) -- 3077
	local room = self.room -- 3078
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 3079
	local spanX = room.maxX - room.minX -- 3080
	if spanX <= halfW * 2 then -- 3080
		self.cam.x = (room.minX + room.maxX) / 2 -- 3082
	else -- 3082
		self.cam.x = math.max( -- 3084
			room.minX + halfW, -- 3084
			math.min(room.maxX - halfW, self.cam.x) -- 3084
		) -- 3084
	end -- 3084
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 3087
	local spanY = room.height -- 3088
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 3089
	if spanY <= halfH * 2 then -- 3089
		self.cam.y = camY -- 3091
	else -- 3091
		self.cam.y = math.max( -- 3093
			camY, -- 3093
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 3093
		) -- 3093
	end -- 3093
end -- 3077
function Play.prototype.flashSet(self, text, t) -- 3097
	self.flash = text -- 3098
	self.flashT = t -- 3099
end -- 3097
function Play.prototype.statusText(self) -- 3103
	local p = self.player -- 3104
	local parts = {} -- 3105
	local who = self.childMode and "小满" or "周戍" -- 3106
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 3107
	if self.room.key == "prologue" then -- 3107
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3110
		if self.phase == "prologue-wait" then -- 3110
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 3112
		elseif self.phase == "prologue-give" then -- 3112
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 3114
		else -- 3114
			parts[#parts + 1] = "跟随" -- 3116
		end -- 3116
		if self.paused then -- 3116
			parts[#parts + 1] = "已暂停" -- 3119
		end -- 3119
		return table.concat(parts, " · ") -- 3121
	end -- 3121
	if self.room.key == "street" then -- 3121
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3124
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3125
		if self.paused then -- 3125
			parts[#parts + 1] = "已暂停" -- 3127
		end -- 3127
		return table.concat(parts, " · ") -- 3129
	end -- 3129
	if self.room.key == "gate" then -- 3129
		local ____temp_40 -- 3132
		if self.room.story == nil then -- 3132
			____temp_40 = nil -- 3132
		else -- 3132
			____temp_40 = self.room.story.gate -- 3132
		end -- 3132
		local g = ____temp_40 -- 3132
		if g ~= nil then -- 3132
			parts[#parts + 1] = self:gateLabel() -- 3134
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 3135
				0, -- 3136
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 3136
			))) .. " 秒" -- 3136
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3137
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3138
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 3139
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 3140
			if self.gateFailCount > 0 then -- 3140
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 3142
			end -- 3142
			if self.flash ~= "" then -- 3142
				parts[#parts + 1] = self.flash -- 3145
			end -- 3145
		end -- 3145
		if self.paused then -- 3145
			parts[#parts + 1] = "已暂停" -- 3149
		end -- 3149
		return table.concat(parts, " · ") -- 3151
	end -- 3151
	if self.room.key == "forest" then -- 3151
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3154
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 3155
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 3156
		if self.caughtT > 0 then -- 3156
			parts[#parts + 1] = "复位中" -- 3158
		end -- 3158
		if self.paused then -- 3158
			parts[#parts + 1] = "已暂停" -- 3161
		end -- 3161
		return table.concat(parts, " · ") -- 3163
	end -- 3163
	if self.room.key == "tower" then -- 3163
		if self.phase == "tower-wait" then -- 3163
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 3167
		elseif self.phase == "tower-knock" then -- 3167
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 3169
		elseif self.phase == "tower-given" then -- 3169
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 3171
		else -- 3171
			parts[#parts + 1] = "片尾" -- 3173
		end -- 3173
		if self.paused then -- 3173
			parts[#parts + 1] = "已暂停" -- 3176
		end -- 3176
		return table.concat(parts, " · ") -- 3178
	end -- 3178
	if self.room.key == "village" then -- 3178
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3181
		if self.hasBottle then -- 3181
			parts[#parts + 1] = "有瓶" -- 3183
		elseif self.bottleFly ~= nil then -- 3183
			parts[#parts + 1] = "瓶在飞" -- 3185
		else -- 3185
			parts[#parts + 1] = "空手" -- 3187
		end -- 3187
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 3189
		if self.scavChase then -- 3189
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 3191
		end -- 3191
		if self.passed then -- 3191
			parts[#parts + 1] = "已过通行线" -- 3194
		end -- 3194
		if self.paused then -- 3194
			parts[#parts + 1] = "已暂停" -- 3197
		end -- 3197
		return table.concat(parts, " · ") -- 3199
	end -- 3199
	local isChild = self.childMode -- 3202
	if isChild then -- 3202
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3204
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 3205
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3206
	else -- 3206
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 3208
		if p.rollT > 0 then -- 3208
			parts[#parts + 1] = "翻滚中" -- 3210
		end -- 3210
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3212
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3213
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 3214
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 3215
	end -- 3215
	if self.checkpoint >= 0 then -- 3215
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 3218
	end -- 3218
	if self.paused then -- 3218
		parts[#parts + 1] = "已暂停" -- 3221
	end -- 3221
	return table.concat(parts, " · ") -- 3223
end -- 3103
function Play.prototype.aliveEnemies(self) -- 3227
	local n = 0 -- 3228
	local i = 0 -- 3229
	do -- 3229
		i = 0 -- 3230
		while i < #self.enemies do -- 3230
			if self.enemies[i + 1].alive then -- 3230
				n = n + 1 -- 3232
			end -- 3232
			i = i + 1 -- 3230
		end -- 3230
	end -- 3230
	return n -- 3235
end -- 3227
function Play.prototype.threatened(self) -- 3240
	do -- 3240
		local i = 0 -- 3241
		while i < #self.enemies do -- 3241
			local e = self.enemies[i + 1] -- 3242
			if e.alive and e.warnT > 0 then -- 3242
				return true -- 3244
			end -- 3244
			i = i + 1 -- 3241
		end -- 3241
	end -- 3241
	return false -- 3247
end -- 3240
function Play.prototype.gateSecondsLeft(self) -- 3250
	local ____temp_41 -- 3251
	if self.room.story == nil then -- 3251
		____temp_41 = nil -- 3251
	else -- 3251
		____temp_41 = self.room.story.gate -- 3251
	end -- 3251
	local g = ____temp_41 -- 3251
	if g == nil then -- 3251
		return 0 -- 3253
	end -- 3253
	return math.max( -- 3255
		0, -- 3255
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 3255
	) -- 3255
end -- 3250
function Play.prototype.gateLabel(self) -- 3258
	if self.phase == "gate-idle" then -- 3258
		return "待就位" -- 3260
	end -- 3260
	if self.phase == "gate-hold" then -- 3260
		return "守点中" -- 3263
	end -- 3263
	if self.phase == "gate-send" then -- 3263
		return "送别" -- 3266
	end -- 3266
	if self.phase == "gate-count" then -- 3266
		return "数数 " .. tostring(self.countTick) -- 3269
	end -- 3269
	return "她走" -- 3271
end -- 3258
function Play.prototype.dogLabel(self) -- 3275
	if self.dogState == "ear" then -- 3275
		return "转耳" -- 3277
	end -- 3277
	if self.dogState == "chase" then -- 3277
		return "追" -- 3280
	end -- 3280
	if self.dogState == "sniff" then -- 3280
		return "停" -- 3283
	end -- 3283
	if self.dogState == "back" then -- 3283
		return "回线" -- 3286
	end -- 3286
	return "巡逻" -- 3288
end -- 3275
function Play.prototype.doorXOf(self) -- 3291
	local ____temp_42 -- 3292
	if self.room.story == nil then -- 3292
		____temp_42 = nil -- 3292
	else -- 3292
		____temp_42 = self.room.story.tower -- 3292
	end -- 3292
	local t = ____temp_42 -- 3292
	return t == nil and 0 or t.doorX -- 3293
end -- 3291
function Play.prototype.scavLabel(self) -- 3297
	if self.scavState == "chase" then -- 3297
		return "追" -- 3299
	end -- 3299
	if self.scavState == "turn" then -- 3299
		return "转头" -- 3302
	end -- 3302
	if self.scavState == "walk" then -- 3302
		return "赶来" -- 3305
	end -- 3305
	if self.scavState == "stall" then -- 3305
		return "停住" -- 3308
	end -- 3308
	if self.scavState == "back" then -- 3308
		return "回位" -- 3311
	end -- 3311
	return "巡逻" -- 3313
end -- 3297
function Play.prototype.hintText(self) -- 3317
	if self.paused then -- 3317
		return "Esc 继续 · R 重置" -- 3319
	end -- 3319
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 3319
		if self:threatened() then -- 3319
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 3325
		end -- 3325
		if self.coverHug then -- 3325
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 3328
		end -- 3328
		if self.coverNear then -- 3328
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 3331
		end -- 3331
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 3333
	end -- 3333
	if self.flash ~= "" then -- 3333
		return self.flash -- 3336
	end -- 3336
	if self.room.key == "prologue" then -- 3336
		if self.phase == "prologue-wait" then -- 3336
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 3340
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 3341
		end -- 3341
		if self.phase == "prologue-give" then -- 3341
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 3344
		end -- 3344
		return "她跟着你了 · 两人一起走到门口 680" -- 3346
	end -- 3346
	if self.room.key == "street" then -- 3346
		if self:aliveEnemies() > 0 then -- 3346
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 3350
		end -- 3350
		return "清完了 · 两人一起走到右边检查站入口 900" -- 3352
	end -- 3352
	if self.room.key == "gate" then -- 3352
		local ____temp_43 -- 3355
		if self.room.story == nil then -- 3355
			____temp_43 = nil -- 3355
		else -- 3355
			____temp_43 = self.room.story.gate -- 3355
		end -- 3355
		local g = ____temp_43 -- 3355
		if g ~= nil then -- 3355
			if self.phase == "gate-idle" then -- 3355
				if self.gateNeedConfirm then -- 3355
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 3359
				end -- 3359
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 3361
			end -- 3361
			if self.phase == "gate-hold" then -- 3361
				if self.coveredFlash > 0 then -- 3361
					return "掩体挡下了这一枪 · 别露头" -- 3365
				end -- 3365
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 3367
			end -- 3367
			if self.phase == "gate-send" then -- 3367
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 3370
			end -- 3370
			if self.phase == "gate-count" then -- 3370
				if self.countTick >= 1440 then -- 3370
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 3374
				end -- 3374
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 3376
			end -- 3376
			return "她自己走 · 跟着出城门 1120" -- 3378
		end -- 3378
	end -- 3378
	if self.room.key == "forest" then -- 3378
		if self.dogState == "chase" then -- 3378
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 3383
		end -- 3383
		if self.dogState == "ear" then -- 3383
			return "狗转耳朵了 · 停下或蹲下别出声" -- 3386
		end -- 3386
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 3388
	end -- 3388
	if self.room.key == "tower" then -- 3388
		if self.phase == "tower-wait" then -- 3388
			return "走到门前 445 点一次 E 敲两下" -- 3392
		end -- 3392
		if self.phase == "tower-knock" then -- 3392
			return "敲两下 · 等门开" -- 3395
		end -- 3395
		if self.phase == "tower-given" then -- 3395
			return "递交针套和纸条 · 看登记簿最后一行" -- 3398
		end -- 3398
		return "片尾 · 点 E 再玩一次，回到序章" -- 3400
	end -- 3400
	if self.room.key == "village" then -- 3400
		if self.bottleFly ~= nil then -- 3400
			return "等瓶子落地 · 触地才发声" -- 3404
		end -- 3404
		if self.hasBottle then -- 3404
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 3407
		end -- 3407
		if self.passed then -- 3407
			return "已过第一院 · R 重置可再来一遍" -- 3410
		end -- 3410
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 3412
	end -- 3412
	if self.room.key == "outside" then -- 3412
		if self.focusCart then -- 3412
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 3416
		end -- 3416
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 3418
	end -- 3418
	if self.escort.state == "frozen" then -- 3418
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 3418
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 3422
		end -- 3422
		return "小满吓住了 · 走过去，靠近再点 E" -- 3424
	end -- 3424
	if self.escort.state == "calming" then -- 3424
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 3427
	end -- 3427
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 3429
end -- 3317
function Play.prototype.draw(self, draw, w, h) -- 3434
	self.viewW = w -- 3435
	self.viewH = h -- 3436
	self.view = ____exports.computeViewport(w, h) -- 3437
	self:clampCamera(w, h) -- 3438
	draw:clear() -- 3439
	draw:drawRect( -- 3441
		Rect(0, 0, w, h), -- 3441
		BG_VOID -- 3441
	) -- 3441
	local box = self:canvasRect(w, h) -- 3442
	draw:drawRect(box, BG_FAR) -- 3443
	draw:drawRect( -- 3444
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 3444
		BG_MID -- 3444
	) -- 3444
	self:drawFloors(draw, w, h) -- 3446
	self:drawSolids(draw, w, h) -- 3447
	self:drawZones(draw, w, h) -- 3448
	self:drawArch(draw, w, h) -- 3449
	self:drawCart(draw, w, h) -- 3450
	self:drawCampaignProps(draw, w, h) -- 3451
	self:drawActors(draw, w, h) -- 3452
	self:drawTrace(draw, w, h) -- 3453
	self:drawAim(draw, w, h) -- 3454
end -- 3434
function Play.prototype.canvasRect(self, w, h) -- 3458
	local v = self.view -- 3459
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 3460
end -- 3458
function Play.prototype.px(self, n) -- 3464
	return n * self.view.zoom -- 3465
end -- 3464
function Play.prototype.sx(self, wx, w) -- 3469
	local v = self.view -- 3470
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 3471
	return v.ox + lx * v.zoom -- 3472
end -- 3469
function Play.prototype.sy(self, wy, h) -- 3476
	local v = self.view -- 3477
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 3478
	return v.oy + ly * v.zoom -- 3479
end -- 3476
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 3482
	local px0 = self:sx(x0, w) -- 3483
	local px1 = self:sx(x1, w) -- 3484
	local py0 = self:sy(y0, h) -- 3485
	local py1 = self:sy(y1, h) -- 3486
	if px1 <= px0 or py1 <= py0 then -- 3486
		return -- 3488
	end -- 3488
	draw:drawRect( -- 3490
		Rect(px0, py0, px1 - px0, py1 - py0), -- 3490
		color -- 3490
	) -- 3490
end -- 3482
function Play.prototype.drawFloors(self, draw, w, h) -- 3493
	local i = 0 -- 3494
	do -- 3494
		i = 0 -- 3495
		while i < #self.room.floors do -- 3495
			local f = self.room.floors[i + 1] -- 3496
			local ____temp_44 -- 3497
			if f.y == 0 then -- 3497
				____temp_44 = self.room.depth -- 3497
			else -- 3497
				____temp_44 = nil -- 3497
			end -- 3497
			local road = ____temp_44 -- 3497
			local y = self:sy(f.y + (road and road.min or 0), h) -- 3498
			local x0 = self:sx(f.x0, w) -- 3499
			local x1 = self:sx(f.x1, w) -- 3500
			local deck = self:px(5) -- 3501
			if road ~= nil then -- 3501
				local back = self:sy(f.y + road.max, h) -- 3503
				draw:drawRect( -- 3504
					Rect(x0, y, x1 - x0, back - y), -- 3504
					FLOOR_DECK, -- 3504
					self:px(1), -- 3504
					SOLID_EDGE -- 3504
				) -- 3504
			end -- 3504
			draw:drawRect( -- 3506
				Rect(x0, y - deck, x1 - x0, deck), -- 3506
				FLOOR_DECK -- 3506
			) -- 3506
			draw:drawSegment( -- 3507
				Vec2(x0, y), -- 3507
				Vec2(x1, y), -- 3507
				self:px(1), -- 3507
				GROUND -- 3507
			) -- 3507
			i = i + 1 -- 3495
		end -- 3495
	end -- 3495
end -- 3493
function Play.prototype.drawSolids(self, draw, w, h) -- 3511
	local i = 0 -- 3512
	do -- 3512
		i = 0 -- 3513
		while i < #self.boxes do -- 3513
			do -- 3513
				local b = self.boxes[i + 1] -- 3514
				if b.id == "braced_shield" or b.hidden == true then -- 3514
					goto __continue681 -- 3516
				end -- 3516
				if b.broken == true then -- 3516
					if b.breakable ~= nil then -- 3516
						local gy = self:sy(b.y0, h) -- 3521
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 3522
						local k = 0 -- 3523
						do -- 3523
							k = 0 -- 3524
							while k < 3 do -- 3524
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 3525
								draw:drawSegment( -- 3526
									Vec2( -- 3526
										gx - self:px(4), -- 3526
										gy + self:px(k % 2) -- 3526
									), -- 3526
									Vec2( -- 3526
										gx + self:px(5), -- 3526
										gy + self:px(k % 2) -- 3526
									), -- 3526
									self:px(1), -- 3526
									rgb -- 3526
								) -- 3526
								k = k + 1 -- 3524
							end -- 3524
						end -- 3524
					end -- 3524
					goto __continue681 -- 3529
				end -- 3529
				local ____opt_47 = b.depth -- 3529
				local front = ____opt_47 and ____opt_47.min or 0 -- 3531
				local ____opt_49 = b.depth -- 3531
				local back = ____opt_49 and ____opt_49.max or 0 -- 3532
				local fill = SOLID_FILL -- 3533
				local line = SOLID_EDGE -- 3534
				if b.soft == true then -- 3534
					fill = SOFT -- 3536
					line = SOFT_LINE -- 3537
				elseif b.breakable ~= nil then -- 3537
					line = DANGER_LINE -- 3539
					fill = Color(0.3, 0.24, 0.16, 1) -- 3540
				elseif b.interact ~= nil then -- 3540
					line = PASS_LINE -- 3542
				end -- 3542
				self:drawBox( -- 3544
					draw, -- 3544
					w, -- 3544
					h, -- 3544
					b.x0, -- 3544
					b.x1, -- 3544
					b.y0 + front, -- 3544
					b.y1 + back, -- 3544
					fill -- 3544
				) -- 3544
				draw:drawSegment( -- 3545
					Vec2( -- 3545
						self:sx(b.x0, w), -- 3545
						self:sy(b.y1 + front, h) -- 3545
					), -- 3545
					Vec2( -- 3546
						self:sx(b.x1, w), -- 3546
						self:sy(b.y1 + front, h) -- 3546
					), -- 3546
					self:px(1), -- 3546
					line -- 3546
				) -- 3546
				if b.breakable ~= nil then -- 3546
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 3549
					local cyp = self:sy(b.y1 + front, h) -- 3550
					draw:drawSegment( -- 3551
						Vec2( -- 3551
							cxp - self:px(4), -- 3551
							cyp + self:px(1) -- 3551
						), -- 3551
						Vec2( -- 3551
							cxp + self:px(3), -- 3551
							cyp + self:px(5) -- 3551
						), -- 3551
						self:px(1), -- 3551
						line -- 3551
					) -- 3551
				end -- 3551
			end -- 3551
			::__continue681:: -- 3551
			i = i + 1 -- 3513
		end -- 3513
	end -- 3513
end -- 3511
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 3557
	local i = 0 -- 3558
	do -- 3558
		i = 0 -- 3559
		while i < #self.pickups do -- 3559
			do -- 3559
				local pk = self.pickups[i + 1] -- 3560
				if pk.id == "" then -- 3560
					goto __continue693 -- 3562
				end -- 3562
				local gy = pk.y + (pk.depth or 0) -- 3564
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 3565
				draw:drawRect( -- 3566
					Rect( -- 3566
						self:sx(pk.x - 5, w), -- 3566
						self:sy(gy + 12 + bob, h), -- 3566
						self:px(10), -- 3566
						self:px(10) -- 3566
					), -- 3566
					Color(0.84, 0.7, 0.3, 1) -- 3567
				) -- 3567
				draw:drawSegment( -- 3568
					Vec2( -- 3568
						self:sx(pk.x - 5, w), -- 3568
						self:sy(gy + 12 + bob, h) -- 3568
					), -- 3568
					Vec2( -- 3569
						self:sx(pk.x + 5, w), -- 3569
						self:sy(gy + 12 + bob, h) -- 3569
					), -- 3569
					self:px(1), -- 3569
					Color(0.95, 0.86, 0.52, 1) -- 3569
				) -- 3569
			end -- 3569
			::__continue693:: -- 3569
			i = i + 1 -- 3559
		end -- 3559
	end -- 3559
	if self.bracedShield ~= nil then -- 3559
		local sh = self.bracedShield -- 3572
		draw:drawRect( -- 3573
			Rect( -- 3573
				self:sx(sh.x - sh.w / 2, w), -- 3573
				self:sy(sh.y, h), -- 3573
				self:px(sh.w), -- 3573
				self:px(sh.h) -- 3573
			), -- 3573
			Color(0.42, 0.4, 0.34, 1) -- 3574
		) -- 3574
		draw:drawSegment( -- 3575
			Vec2( -- 3575
				self:sx(sh.x - sh.w / 2, w), -- 3575
				self:sy(sh.y + sh.h, h) -- 3575
			), -- 3575
			Vec2( -- 3576
				self:sx(sh.x + sh.w / 2, w), -- 3576
				self:sy(sh.y + sh.h, h) -- 3576
			), -- 3576
			self:px(1), -- 3576
			Color(0.74, 0.72, 0.62, 1) -- 3576
		) -- 3576
	end -- 3576
end -- 3557
function Play.prototype.drawZones(self, draw, w, h) -- 3580
	local i = 0 -- 3581
	do -- 3581
		i = 0 -- 3582
		while i < #self.room.zones do -- 3582
			local z = self.room.zones[i + 1] -- 3583
			local fill = DANGER -- 3584
			local line = DANGER_LINE -- 3585
			if z.tint == 2 then -- 3585
				fill = SOFT -- 3587
				line = SOFT_LINE -- 3588
			elseif z.tint == 3 then -- 3588
				fill = BRICK -- 3590
				line = BRICK_LINE -- 3591
			elseif z.tint == 4 then -- 3591
				fill = PASS -- 3593
				line = PASS_LINE -- 3594
			end -- 3594
			self:drawBox( -- 3596
				draw, -- 3596
				w, -- 3596
				h, -- 3596
				z.x0, -- 3596
				z.x1, -- 3596
				z.y, -- 3596
				z.y + z.h, -- 3596
				fill -- 3596
			) -- 3596
			draw:drawSegment( -- 3597
				Vec2( -- 3597
					self:sx(z.x0, w), -- 3597
					self:sy(z.y, h) -- 3597
				), -- 3597
				Vec2( -- 3597
					self:sx(z.x0, w), -- 3597
					self:sy(z.y + z.h, h) -- 3597
				), -- 3597
				self:px(1), -- 3597
				line -- 3597
			) -- 3597
			draw:drawSegment( -- 3598
				Vec2( -- 3598
					self:sx(z.x1, w), -- 3598
					self:sy(z.y, h) -- 3598
				), -- 3598
				Vec2( -- 3598
					self:sx(z.x1, w), -- 3598
					self:sy(z.y + z.h, h) -- 3598
				), -- 3598
				self:px(1), -- 3598
				line -- 3598
			) -- 3598
			i = i + 1 -- 3582
		end -- 3582
	end -- 3582
end -- 3580
function Play.prototype.drawArch(self, draw, w, h) -- 3602
	local a = self.room.arch -- 3603
	if a.h <= 0 then -- 3603
		return -- 3605
	end -- 3605
	self:drawBox( -- 3607
		draw, -- 3607
		w, -- 3607
		h, -- 3607
		a.x0, -- 3607
		a.x1, -- 3607
		a.y, -- 3607
		a.y + a.h, -- 3607
		HOLE_FILL -- 3607
	) -- 3607
	draw:drawSegment( -- 3608
		Vec2( -- 3608
			self:sx(a.x0, w), -- 3608
			self:sy(a.y + a.h, h) -- 3608
		), -- 3608
		Vec2( -- 3608
			self:sx(a.x1, w), -- 3608
			self:sy(a.y + a.h, h) -- 3608
		), -- 3608
		self:px(1), -- 3608
		SOLID_EDGE -- 3608
	) -- 3608
	draw:drawSegment( -- 3609
		Vec2( -- 3609
			self:sx(a.x0, w), -- 3609
			self:sy(a.y, h) -- 3609
		), -- 3609
		Vec2( -- 3609
			self:sx(a.x0, w), -- 3609
			self:sy(a.y + a.h, h) -- 3609
		), -- 3609
		self:px(1), -- 3609
		SOLID_EDGE -- 3609
	) -- 3609
	draw:drawSegment( -- 3610
		Vec2( -- 3610
			self:sx(a.x1, w), -- 3610
			self:sy(a.y, h) -- 3610
		), -- 3610
		Vec2( -- 3610
			self:sx(a.x1, w), -- 3610
			self:sy(a.y + a.h, h) -- 3610
		), -- 3610
		self:px(1), -- 3610
		SOLID_EDGE -- 3610
	) -- 3610
end -- 3602
function Play.prototype.drawCart(self, draw, w, h) -- 3613
	local c = self.room.cart -- 3614
	if c.bodyW <= 0 then -- 3614
		return -- 3616
	end -- 3616
	drawCartShape( -- 3618
		draw, -- 3618
		self, -- 3618
		w, -- 3618
		h, -- 3618
		c, -- 3618
		self.cartAxle -- 3618
	) -- 3618
	draw:drawRect( -- 3619
		Rect( -- 3619
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 3619
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 3619
			self:px(2), -- 3619
			self:px(40) -- 3619
		), -- 3619
		STAND -- 3619
	) -- 3619
end -- 3613
function Play.prototype.drawActors(self, draw, w, h) -- 3622
	local p = self.player -- 3623
	local isChild = self.childMode -- 3624
	local footY = p.y + p.depth -- 3625
	if p.covered then -- 3625
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 3628
		draw:drawSegment( -- 3629
			Vec2( -- 3629
				self:sx(edge, w), -- 3629
				self:sy(footY + 8, h) -- 3629
			), -- 3629
			Vec2( -- 3629
				self:sx(edge, w), -- 3629
				self:sy(footY + p.h * 0.62, h) -- 3629
			), -- 3629
			self:px(2), -- 3629
			STAND -- 3629
		) -- 3629
		draw:drawSegment( -- 3631
			Vec2( -- 3631
				self:sx(p.x - 8, w), -- 3631
				self:sy(footY + p.h + 3, h) -- 3631
			), -- 3631
			Vec2( -- 3631
				self:sx(p.x + 8, w), -- 3631
				self:sy(footY + p.h + 3, h) -- 3631
			), -- 3631
			self:px(2), -- 3631
			STAND -- 3631
		) -- 3631
	elseif self.coverNear and not isChild then -- 3631
		draw:drawRect( -- 3634
			Rect( -- 3634
				self:sx(p.x - 3, w), -- 3634
				self:sy(footY + 1, h), -- 3634
				self:px(3), -- 3634
				self:px(3) -- 3634
			), -- 3634
			STAND -- 3634
		) -- 3634
	end -- 3634
	drawFigure( -- 3636
		draw, -- 3636
		self, -- 3636
		w, -- 3636
		h, -- 3636
		p, -- 3636
		isChild and CHILD_BODY or SOLDIER_BODY, -- 3636
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 3636
	) -- 3636
	local q = self.partner -- 3637
	if q.alive then -- 3637
		local childPartner = q.w == CHILD_W -- 3639
		drawFigure( -- 3640
			draw, -- 3640
			self, -- 3640
			w, -- 3640
			h, -- 3640
			q, -- 3640
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 3640
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 3640
		) -- 3640
	end -- 3640
	local i = 0 -- 3642
	do -- 3642
		i = 0 -- 3643
		while i < #self.enemies do -- 3643
			local e = self.enemies[i + 1] -- 3644
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 3645
			local enemyY = e.y + (e.depth or 0) -- 3646
			self:drawBox( -- 3647
				draw, -- 3647
				w, -- 3647
				h, -- 3647
				e.x - e.w / 2, -- 3647
				e.x + e.w / 2, -- 3647
				enemyY, -- 3647
				enemyY + e.h, -- 3647
				col -- 3647
			) -- 3647
			if e.alive then -- 3647
				local ef = p.x >= e.x and 1 or -1 -- 3649
				if e.kind == "shield" then -- 3649
					local sh = (e.shieldHp or 0) > 0 -- 3651
					draw:drawRect( -- 3652
						Rect( -- 3652
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 3652
							self:sy(enemyY, h), -- 3652
							self:px(6), -- 3652
							self:px(64) -- 3652
						), -- 3652
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 3653
					) -- 3653
				elseif e.kind == "breaker" then -- 3653
					draw:drawSegment( -- 3655
						Vec2( -- 3655
							self:sx(e.x + ef * 12, w), -- 3655
							self:sy(enemyY + 8, h) -- 3655
						), -- 3655
						Vec2( -- 3656
							self:sx(e.x + ef * 22, w), -- 3656
							self:sy(enemyY + 46, h) -- 3656
						), -- 3656
						self:px(3), -- 3656
						Color(0.5, 0.36, 0.22, 1) -- 3656
					) -- 3656
				end -- 3656
			end -- 3656
			if e.alive and e.warnT > 0 then -- 3656
				local gunX = self:sx(e.x, w) -- 3661
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 3662
				local aimX = self:sx(p.x, w) -- 3663
				local aimY = self:sy(footY + p.h * 0.55, h) -- 3664
				local seg = 8 -- 3665
				local s = 0 -- 3666
				do -- 3666
					s = 0 -- 3667
					while s < seg do -- 3667
						local t0 = s / seg -- 3668
						local t1 = (s + 1) / seg -- 3669
						draw:drawSegment( -- 3670
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 3671
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 3672
							self:px(1), -- 3673
							DANGER -- 3673
						) -- 3673
						s = s + 2 -- 3667
					end -- 3667
				end -- 3667
			end -- 3667
			i = i + 1 -- 3643
		end -- 3643
	end -- 3643
	local k = 0 -- 3678
	do -- 3678
		k = 0 -- 3679
		while k < #self.room.marks do -- 3679
			do -- 3679
				local m = self.room.marks[k + 1] -- 3680
				if m.kind ~= 0 then -- 3680
					goto __continue719 -- 3682
				end -- 3682
				local on = self.checkpoint == m.x -- 3684
				local x = self:sx(m.x, w) -- 3685
				local y = self:sy(m.y, h) -- 3686
				draw:drawSegment( -- 3687
					Vec2(x, y), -- 3687
					Vec2( -- 3687
						x, -- 3687
						y + self:px(35) -- 3687
					), -- 3687
					self:px(1), -- 3687
					on and CHECK or INK_DIM -- 3687
				) -- 3687
				draw:drawDot( -- 3688
					Vec2( -- 3688
						x, -- 3688
						y + self:px(35) -- 3688
					), -- 3688
					self:px(2), -- 3688
					on and CHECK or INK_DIM -- 3688
				) -- 3688
			end -- 3688
			::__continue719:: -- 3688
			k = k + 1 -- 3679
		end -- 3679
	end -- 3679
	local j = 0 -- 3692
	do -- 3692
		j = 0 -- 3693
		while j < #self.room.marks do -- 3693
			do -- 3693
				local m = self.room.marks[j + 1] -- 3694
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 3694
					goto __continue722 -- 3696
				end -- 3696
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 3696
					goto __continue722 -- 3700
				end -- 3700
				local col = STAND -- 3702
				if m.kind == 4 then -- 3702
					col = PASS_LINE -- 3704
				elseif m.kind == 5 then -- 3704
					col = BRICK_LINE -- 3706
				end -- 3706
				local mx = self:sx(m.x, w) -- 3708
				local my = self:sy(m.y, h) -- 3709
				draw:drawSegment( -- 3710
					Vec2(mx, my), -- 3710
					Vec2( -- 3710
						mx, -- 3710
						my + self:px(24) -- 3710
					), -- 3710
					self:px(1), -- 3710
					col -- 3710
				) -- 3710
			end -- 3710
			::__continue722:: -- 3710
			j = j + 1 -- 3693
		end -- 3693
	end -- 3693
	local t = 0 -- 3713
	do -- 3713
		t = 0 -- 3714
		while t < #self.room.marks do -- 3714
			do -- 3714
				local m = self.room.marks[t + 1] -- 3715
				if m.kind ~= 6 then -- 3715
					goto __continue728 -- 3717
				end -- 3717
				local mx = self:sx(m.x, w) -- 3719
				local my = self:sy(m.y, h) -- 3720
				draw:drawSegment( -- 3721
					Vec2(mx, my), -- 3721
					Vec2( -- 3721
						mx, -- 3721
						my + self:px(30) -- 3721
					), -- 3721
					self:px(1), -- 3721
					INK_DIM -- 3721
				) -- 3721
				self:drawBox( -- 3722
					draw, -- 3722
					w, -- 3722
					h, -- 3722
					m.x - 5, -- 3722
					m.x + 5, -- 3722
					m.y + 30, -- 3722
					m.y + 40, -- 3722
					CHECK -- 3722
				) -- 3722
			end -- 3722
			::__continue728:: -- 3722
			t = t + 1 -- 3714
		end -- 3714
	end -- 3714
	if self.room.key == "village" then -- 3714
		self:drawVillage(draw, w, h) -- 3725
	end -- 3725
	if self.room.key == "forest" then -- 3725
		self:drawDog(draw, w, h) -- 3728
	end -- 3728
end -- 3622
function Play.prototype.drawDog(self, draw, w, h) -- 3733
	local x = self.dogX -- 3734
	self:drawBox( -- 3735
		draw, -- 3735
		w, -- 3735
		h, -- 3735
		x - 14, -- 3735
		x + 14, -- 3735
		0, -- 3735
		20, -- 3735
		SCAV_BODY -- 3735
	) -- 3735
	self:drawBox( -- 3736
		draw, -- 3736
		w, -- 3736
		h, -- 3736
		x - 10, -- 3736
		x - 2, -- 3736
		20, -- 3736
		30, -- 3736
		SCAV_BODY -- 3736
	) -- 3736
	self:drawBox( -- 3737
		draw, -- 3737
		w, -- 3737
		h, -- 3737
		x + 2, -- 3737
		x + 10, -- 3737
		20, -- 3737
		30, -- 3737
		SCAV_HEAD -- 3737
	) -- 3737
	if self.dogState == "ear" or self.dogState == "chase" then -- 3737
		draw:drawSegment( -- 3739
			Vec2( -- 3739
				self:sx(x, w), -- 3739
				self:sy(30, h) -- 3739
			), -- 3739
			Vec2( -- 3740
				self:sx(x, w), -- 3740
				self:sy(40, h) -- 3740
			), -- 3740
			self:px(1), -- 3740
			DANGER -- 3740
		) -- 3740
	end -- 3740
end -- 3733
function Play.prototype.drawVillage(self, draw, w, h) -- 3745
	local bottle = self.room.bottle -- 3746
	if bottle ~= nil then -- 3746
		self:drawBox( -- 3748
			draw, -- 3748
			w, -- 3748
			h, -- 3748
			bottle.x - 14, -- 3748
			bottle.x + 14, -- 3748
			0, -- 3748
			64, -- 3748
			SOLID_FILL -- 3748
		) -- 3748
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 3748
			self:drawBottle( -- 3750
				draw, -- 3750
				w, -- 3750
				h, -- 3750
				bottle.x, -- 3750
				64 -- 3750
			) -- 3750
		end -- 3750
	end -- 3750
	self:drawBox( -- 3754
		draw, -- 3754
		w, -- 3754
		h, -- 3754
		300, -- 3754
		420, -- 3754
		44, -- 3754
		50, -- 3754
		FLOOR_DECK -- 3754
	) -- 3754
	self:drawBox( -- 3755
		draw, -- 3755
		w, -- 3755
		h, -- 3755
		300, -- 3755
		306, -- 3755
		0, -- 3755
		44, -- 3755
		FLOOR_DECK -- 3755
	) -- 3755
	self:drawBox( -- 3756
		draw, -- 3756
		w, -- 3756
		h, -- 3756
		414, -- 3756
		420, -- 3756
		0, -- 3756
		44, -- 3756
		FLOOR_DECK -- 3756
	) -- 3756
	local s = self.room.scavenger -- 3758
	if s ~= nil then -- 3758
		local sx0 = self.scavX -- 3760
		self:drawBox( -- 3761
			draw, -- 3761
			w, -- 3761
			h, -- 3761
			sx0 - 12, -- 3761
			sx0 + 12, -- 3761
			0, -- 3761
			s.h - 14, -- 3761
			SCAV_BODY -- 3761
		) -- 3761
		self:drawBox( -- 3762
			draw, -- 3762
			w, -- 3762
			h, -- 3762
			sx0 - 7, -- 3762
			sx0 + 7, -- 3762
			s.h - 14, -- 3762
			s.h, -- 3762
			SCAV_HEAD -- 3762
		) -- 3762
		if self.scavState == "turn" then -- 3762
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 3764
			draw:drawSegment( -- 3765
				Vec2( -- 3765
					self:sx(sx0, w), -- 3765
					self:sy(s.h - 6, h) -- 3765
				), -- 3765
				Vec2( -- 3765
					self:sx(fx, w), -- 3765
					self:sy(s.h - 6, h) -- 3765
				), -- 3765
				self:px(1), -- 3765
				INK -- 3765
			) -- 3765
		end -- 3765
	end -- 3765
	if self.hasBottle then -- 3765
		local p = self.player -- 3770
		self:drawBottle( -- 3771
			draw, -- 3771
			w, -- 3771
			h, -- 3771
			p.x + p.facing * 10, -- 3771
			p.y + p.h * 0.62 -- 3771
		) -- 3771
	end -- 3771
	if self.bottleFly ~= nil then -- 3771
		self:drawBottle( -- 3774
			draw, -- 3774
			w, -- 3774
			h, -- 3774
			self.bottleFly.x, -- 3774
			self.bottleFly.y -- 3774
		) -- 3774
	end -- 3774
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 3774
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 3777
		draw:drawCircle( -- 3778
			Vec2( -- 3778
				self:sx(self.bottleLandX, w), -- 3778
				self:sy(0, h) -- 3778
			), -- 3778
			self:px(r / ____exports.UNITS_PER_PX), -- 3778
			BRICK_LINE -- 3778
		) -- 3778
	end -- 3778
end -- 3745
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 3782
	self:drawBox( -- 3783
		draw, -- 3783
		w, -- 3783
		h, -- 3783
		x - 3, -- 3783
		x + 3, -- 3783
		y - 10, -- 3783
		y, -- 3783
		BOTTLE -- 3783
	) -- 3783
end -- 3782
function Play.prototype.drawTrace(self, draw, w, h) -- 3786
	local t = self.trace -- 3787
	if t == nil or self.traceT <= 0 then -- 3787
		return -- 3789
	end -- 3789
	draw:drawSegment( -- 3791
		Vec2( -- 3792
			self:sx(t.x0, w), -- 3792
			self:sy(t.y0, h) -- 3792
		), -- 3792
		Vec2( -- 3793
			self:sx(t.x1, w), -- 3793
			self:sy(t.y1, h) -- 3793
		), -- 3793
		self:px(1), -- 3794
		t.hit and AIM_HIT or INK_DIM -- 3794
	) -- 3794
end -- 3786
function Play.prototype.drawAim(self, draw, w, h) -- 3797
	local v = self.view -- 3799
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 3800
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 3801
	local dot = self:px(1) -- 3802
	local arm = self:px(3) -- 3803
	local gap = self:px(1) -- 3804
	draw:drawSegment( -- 3805
		Vec2(gx - arm - gap, gy), -- 3805
		Vec2(gx - gap, gy), -- 3805
		dot / 2, -- 3805
		AIM -- 3805
	) -- 3805
	draw:drawSegment( -- 3806
		Vec2(gx + gap, gy), -- 3806
		Vec2(gx + arm + gap, gy), -- 3806
		dot / 2, -- 3806
		AIM -- 3806
	) -- 3806
	draw:drawSegment( -- 3807
		Vec2(gx, gy - arm - gap), -- 3807
		Vec2(gx, gy - gap), -- 3807
		dot / 2, -- 3807
		AIM -- 3807
	) -- 3807
	draw:drawSegment( -- 3808
		Vec2(gx, gy + gap), -- 3808
		Vec2(gx, gy + arm + gap), -- 3808
		dot / 2, -- 3808
		AIM -- 3808
	) -- 3808
	if self.room.key == "village" and self.hasBottle then -- 3808
		local p = self.player -- 3812
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3814
		local dir = ____end.x >= p.x and 1 or -1 -- 3815
		local x0 = p.x + dir * 10 -- 3816
		local y0 = p.y + p.h * 0.7 -- 3817
		local T = BOTTLE_FLY_TIME -- 3818
		local vx = (____end.x - x0) / T -- 3819
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 3820
		local pxr = x0 -- 3821
		local pyr = y0 -- 3822
		local t = 1 -- 3823
		do -- 3823
			t = 1 -- 3824
			while t <= 12 do -- 3824
				local tt = t / 12 * T -- 3825
				local nx = x0 + vx * tt -- 3826
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 3827
				draw:drawSegment( -- 3828
					Vec2( -- 3828
						self:sx(pxr, w), -- 3828
						self:sy(pyr, h) -- 3828
					), -- 3828
					Vec2( -- 3828
						self:sx(nx, w), -- 3828
						self:sy(ny, h) -- 3828
					), -- 3828
					self:px(1) / 2, -- 3828
					BOTTLE -- 3828
				) -- 3828
				pxr = nx -- 3829
				pyr = ny -- 3830
				t = t + 1 -- 3824
			end -- 3824
		end -- 3824
		draw:drawCircle( -- 3832
			Vec2( -- 3832
				self:sx(____end.x, w), -- 3832
				self:sy(____end.y + 2, h) -- 3832
			), -- 3832
			self:px(2), -- 3832
			BOTTLE -- 3832
		) -- 3832
	end -- 3832
end -- 3797
return ____exports -- 3797