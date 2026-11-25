-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local makeActor, drawFigure, rayInterval, hitBox, drawCartShape, CHILD_W, CHILD_H, SOLDIER_W, SOLDIER_H, INK, CART_FILL, CLOTH -- 1
local ____Dora = require("Dora") -- 12
local Color = ____Dora.Color -- 12
local Rect = ____Dora.Rect -- 12
local Vec2 = ____Dora.Vec2 -- 12
local ____rooms = require("Script.watch.rooms") -- 13
local withOrigin = ____rooms.withOrigin -- 13
local ____clock = require("Script.watch.clock") -- 15
local STEP = ____clock.STEP -- 15
local ____escort = require("Script.watch.escort") -- 16
local CALM_REACH = ____escort.CALM_REACH -- 16
local Escort = ____escort.Escort -- 16
local FEAR_MAX = ____escort.FEAR_MAX -- 16
local safeAnchorX = ____escort.safeAnchorX -- 16
local ____depth = require("Script.watch.depth") -- 17
local ACTOR_DEPTH_HALF = ____depth.ACTOR_DEPTH_HALF -- 17
local inReachDepth = ____depth.inReachDepth -- 17
local overlapsDepth = ____depth.overlapsDepth -- 17
function makeActor(room, index) -- 2820
	local sp = room.spawns -- 2821
	if index < 0 or index >= #sp then -- 2821
		return { -- 2823
			x = 0, -- 2823
			y = 0, -- 2823
			depth = 0, -- 2823
			depthSpeed = 0, -- 2823
			vx = 0, -- 2823
			vy = 0, -- 2823
			w = CHILD_W, -- 2823
			h = CHILD_H, -- 2823
			onGround = true, -- 2823
			facing = 1, -- 2823
			crouch = false, -- 2823
			rollT = 0, -- 2823
			covered = false, -- 2823
			alive = false -- 2823
		} -- 2823
	end -- 2823
	local s = sp[index + 1] -- 2825
	local child = s.h <= CHILD_H -- 2826
	local ground = room.depth -- 2827
	local depth = ground == nil and 0 or math.max( -- 2828
		ground.min, -- 2828
		math.min(ground.max, s.depth or 0) -- 2828
	) -- 2828
	return { -- 2829
		x = s.x, -- 2830
		y = s.y, -- 2830
		depth = depth, -- 2830
		depthSpeed = 0, -- 2830
		vx = 0, -- 2830
		vy = 0, -- 2830
		w = child and CHILD_W or SOLDIER_W, -- 2831
		h = child and CHILD_H or SOLDIER_H, -- 2832
		onGround = true, -- 2833
		facing = 1, -- 2833
		crouch = false, -- 2833
		rollT = 0, -- 2833
		covered = false, -- 2833
		alive = true -- 2833
	} -- 2833
end -- 2833
function drawFigure(draw, play, w, h, a, body, head) -- 2837
	if not a.alive then -- 2837
		return -- 2839
	end -- 2839
	local x0 = a.x - a.w / 2 -- 2841
	local x1 = a.x + a.w / 2 -- 2842
	local y0 = a.y + a.depth -- 2843
	local y1 = y0 + a.h -- 2844
	play:drawBox( -- 2845
		draw, -- 2845
		w, -- 2845
		h, -- 2845
		x0, -- 2845
		x1, -- 2845
		y0, -- 2845
		y1 - a.h * 0.26, -- 2845
		body -- 2845
	) -- 2845
	play:drawBox( -- 2846
		draw, -- 2846
		w, -- 2846
		h, -- 2846
		x0 + 2, -- 2846
		x1 - 2, -- 2846
		y1 - a.h * 0.26, -- 2846
		y1, -- 2846
		head -- 2846
	) -- 2846
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 2848
	play:drawBox( -- 2849
		draw, -- 2849
		w, -- 2849
		h, -- 2849
		eyeX, -- 2849
		eyeX + 4, -- 2849
		y1 - a.h * 0.14, -- 2849
		y1 - a.h * 0.08, -- 2849
		INK -- 2849
	) -- 2849
end -- 2849
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 2853
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 2854
end -- 2853
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 2861
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 2862
end -- 2861
function rayInterval(origin, direction, min, max) -- 2869
	if direction == 0 then -- 2869
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 2871
	end -- 2871
	local a = (min - origin) / direction -- 2873
	local b = (max - origin) / direction -- 2874
	return { -- 2875
		min = math.min(a, b), -- 2875
		max = math.max(a, b) -- 2875
	} -- 2875
end -- 2875
function hitBox(ray, box) -- 2879
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 2880
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 2881
	local enter = math.max(0, x.min, y.min) -- 2882
	local leave = math.min(99999, x.max, y.max) -- 2883
	if box.depth ~= nil then -- 2883
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 2885
		enter = math.max(enter, depth.min) -- 2886
		leave = math.min(leave, depth.max) -- 2887
	end -- 2887
	return leave >= enter and enter or -1 -- 2889
end -- 2889
function drawCartShape(draw, play, w, h, c, axleX) -- 2892
	local half = c.bodyW / 2 -- 2893
	local x0 = axleX - half -- 2894
	local x1 = axleX + half -- 2895
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 2896
	play:drawBox( -- 2897
		draw, -- 2897
		w, -- 2897
		h, -- 2897
		x0, -- 2897
		x1, -- 2897
		axleY, -- 2897
		axleY + c.bodyH, -- 2897
		CART_FILL -- 2897
	) -- 2897
	draw:drawCircle( -- 2898
		Vec2( -- 2898
			play:sx(x0 + c.bodyW * 0.28, w), -- 2898
			play:sy(axleY, h) -- 2898
		), -- 2898
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2898
		Color(52, 50, 48, 255) -- 2898
	) -- 2898
	draw:drawCircle( -- 2899
		Vec2( -- 2899
			play:sx(x1 - c.bodyW * 0.28, w), -- 2899
			play:sy(axleY, h) -- 2899
		), -- 2899
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2899
		Color(52, 50, 48, 255) -- 2899
	) -- 2899
	local cx = c.clothSide < 0 and x0 or x1 -- 2900
	play:drawBox( -- 2901
		draw, -- 2901
		w, -- 2901
		h, -- 2901
		cx - 10, -- 2901
		cx + 10, -- 2901
		axleY + c.bodyH, -- 2901
		axleY + c.bodyH + 18, -- 2901
		CLOTH -- 2901
	) -- 2901
end -- 2901
____exports.STEP = STEP -- 20
____exports.GRAVITY = 1000 -- 21
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 23
CHILD_W = 28 -- 53
CHILD_H = 64 -- 54
local CHILD_CROUCH_H = 36 -- 55
local CHILD_SPEED = 160 -- 56
local CHILD_SLOW = 80 -- 57
local CHILD_JUMP = 320 -- 58
SOLDIER_W = 30 -- 61
SOLDIER_H = 88 -- 62
local SOLDIER_SPEED = 264 -- 63
local ROLL_TIME = 0.35 -- 64
local ROLL_SPEED = 280 -- 65
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 67
local LEDGE_RISE = 60 -- 68
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 71
____exports.LOGIC_H = 180 -- 72
____exports.UNITS_PER_PX = 2 -- 73
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 75
local CAM_FOLLOW = 9 -- 76
local CAM_LOOK_UP = 46 -- 77
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 80
--- 握把触发半径。
____exports.CART_REACH = 70 -- 82
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 84
local CART_CLEAR = 44 -- 85
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 87
local FIRE_COOLDOWN = 150 -- 88
local ENEMY_RANGE = 760 -- 89
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 91
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 93
local DEPTH_SPEED_RATIO = 0.55 -- 94
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 95
INK = Color(232, 232, 228, 255) -- 97
local INK_DIM = Color(150, 152, 150, 255) -- 98
local BG_VOID = Color(8, 9, 10, 255) -- 99
local BG_FAR = Color(24, 26, 28, 255) -- 100
local BG_MID = Color(31, 34, 37, 255) -- 101
local GROUND = Color(112, 114, 112, 255) -- 102
local FLOOR_DECK = Color(66, 70, 72, 255) -- 103
local SOLID_FILL = Color(84, 86, 84, 255) -- 104
local SOLID_EDGE = Color(126, 130, 126, 255) -- 105
CART_FILL = Color(122, 78, 56, 255) -- 106
CLOTH = Color(178, 52, 46, 255) -- 107
local DANGER = Color(150, 54, 48, 46) -- 108
local DANGER_LINE = Color(178, 78, 64, 200) -- 109
local HOLE_FILL = Color(10, 11, 12, 255) -- 110
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 111
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 112
local CHILD_BODY = Color(214, 168, 96, 255) -- 113
local CHILD_HEAD = Color(232, 214, 186, 255) -- 114
local ENEMY_BODY = Color(176, 92, 84, 255) -- 115
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 116
local CHECK = Color(96, 186, 122, 255) -- 117
local STAND = Color(226, 186, 84, 255) -- 118
local AIM = Color(236, 236, 232, 230) -- 119
local AIM_HIT = Color(236, 96, 84, 255) -- 120
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 122
local SOFT_LINE = Color(140, 112, 80, 190) -- 123
local BRICK = Color(126, 118, 110, 70) -- 124
local BRICK_LINE = Color(160, 152, 142, 200) -- 125
local PASS = Color(96, 186, 122, 40) -- 126
local PASS_LINE = Color(96, 186, 122, 200) -- 127
local BOTTLE = Color(120, 186, 160, 255) -- 128
local SCAV_BODY = Color(128, 118, 96, 255) -- 129
local SCAV_HEAD = Color(196, 182, 158, 255) -- 130
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 190
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 191
	if zoom < 1 then -- 191
		zoom = 1 -- 193
	end -- 193
	return { -- 195
		zoom = zoom, -- 196
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 197
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 198
	} -- 198
end -- 190
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 221
	if key == "prologue" then -- 221
		return "prologue-wait" -- 223
	end -- 223
	if key == "street" then -- 223
		return "street-run" -- 226
	end -- 226
	if key == "gate" then -- 226
		return "gate-idle" -- 229
	end -- 229
	if key == "forest" then -- 229
		return "forest-run" -- 232
	end -- 232
	if key == "tower" then -- 232
		return "tower-wait" -- 235
	end -- 235
	return "run" -- 237
end -- 221
____exports.Play = __TS__Class() -- 240
local Play = ____exports.Play -- 240
Play.name = "Play" -- 240
function Play.prototype.____constructor(self, room, resume) -- 379
	self.enemies = {} -- 245
	self.boxes = {} -- 246
	self.floors = {} -- 247
	self.checkpoint = -1 -- 249
	self.flash = "" -- 251
	self.flashT = 0 -- 252
	self.traceT = 0 -- 255
	self.focusCart = false -- 257
	self.knocks = 0 -- 259
	self.knockT = 0 -- 260
	self.cartAxle = 0 -- 264
	self.cartDocked = false -- 266
	self.gripping = false -- 268
	self.gateOpen = false -- 270
	self.calmConsumed = false -- 272
	self.nextDangerId = 1 -- 274
	self.wantRoom = "" -- 276
	self.carryCartAxle = -1 -- 278
	self.carryCartDocked = false -- 279
	self.checkpointCartAxle = -1 -- 281
	self.hasBottle = false -- 285
	self.bottleLandX = -1 -- 289
	self.bottleTargetX = -1 -- 290
	self.bottleTargetY = 0 -- 291
	self.bottleLandT = 0 -- 292
	self.aimHold = 0 -- 294
	self.scavX = 0 -- 296
	self.scavDir = 1 -- 297
	self.scavState = "patrol" -- 298
	self.scavT = 0 -- 299
	self.scavTargetX = 0 -- 300
	self.passed = false -- 302
	self.childMode = false -- 306
	self.phase = "" -- 308
	self.phaseTick = 0 -- 310
	self.gateTick = 0 -- 312
	self.countTick = 0 -- 314
	self.countArmed = false -- 316
	self.countPrevMove = 0 -- 318
	self.caughtT = 0 -- 320
	self.hp = 3 -- 322
	self.maxHp = 3 -- 323
	self.coveredFlash = 0 -- 325
	self.coverHug = false -- 327
	self.coverNear = false -- 329
	self.coverEntity = "" -- 331
	self.coverBlocking = false -- 333
	self.gateNeedConfirm = false -- 335
	self.gateRestartArmed = true -- 337
	self.bottleAimX = -1 -- 339
	self.bottleAimY = 0 -- 340
	self.bottleSurfaceY = -1 -- 342
	self.bottleLandY = 0 -- 344
	self.events = {} -- 346
	self.eventSeq = 0 -- 348
	self.dogX = 0 -- 350
	self.dogDir = 1 -- 351
	self.dogState = "patrol" -- 352
	self.dogT = 0 -- 353
	self.dogTargetX = 0 -- 354
	self.scavSee = 0 -- 356
	self.scavChase = false -- 357
	self.gateSpawned = 0 -- 359
	self.gateFailCount = 0 -- 361
	self.paused = false -- 363
	self.ticks = 0 -- 365
	self.view = {zoom = 1, ox = 0, oy = 0} -- 367
	self.ox = 0 -- 369
	self.aimX = 0 -- 371
	self.aimY = 0 -- 372
	self.viewW = 0 -- 374
	self.viewH = 0 -- 375
	self.ox = room.originX -- 381
	self.room = withOrigin(room) -- 382
	local wr = self.room -- 383
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 384
	self:buildWorld() -- 385
	self.childMode = wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower" -- 387
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 388
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 389
	self.player = makeActor(wr, playerIdx) -- 390
	self.partner = makeActor(wr, partnerIdx) -- 391
	self.phase = phaseOf(wr.key) -- 392
	if wr.story ~= nil then -- 392
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 394
	end -- 394
	self.cam.x = self.player.x -- 396
	self.cam.y = self.player.y + CAM_LOOK_UP -- 397
	self.cartAxle = wr.cart.startX -- 398
	self.escort = __TS__New( -- 399
		Escort, -- 399
		safeAnchorX(wr.marks) -- 399
	) -- 399
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 400
	self:buildEnemies() -- 401
	if resume ~= nil and resume.checkpoint > 0 then -- 401
		self.checkpoint = resume.checkpoint -- 404
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 404
			self.cartAxle = self.room.cart.endX -- 406
			self.cartDocked = true -- 407
			self.player.x = self.ox + 380 -- 410
			self.player.y = 0 -- 411
			self.player.vy = 0 -- 412
			self.player.onGround = true -- 413
			self.cam.x = self.player.x -- 414
			self.cam.y = self.player.y + CAM_LOOK_UP -- 415
		end -- 415
	end -- 415
end -- 379
function Play.prototype.buildWorld(self) -- 421
	local room = self.room -- 422
	self.boxes = {} -- 423
	self.floors = {} -- 424
	local i = 0 -- 425
	do -- 425
		i = 0 -- 426
		while i < #room.floors do -- 426
			local f = room.floors[i + 1] -- 427
			local ____self_floors_0 = self.floors -- 427
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 428
			i = i + 1 -- 426
		end -- 426
	end -- 426
	do -- 426
		i = 0 -- 430
		while i < #room.solids do -- 430
			local s = room.solids[i + 1] -- 431
			if not s.decorative then -- 431
				local ____self_boxes_6 = self.boxes -- 433
				local ____s_x_2 = s.x -- 434
				local ____temp_3 = s.x + s.w -- 434
				local ____s_y_4 = s.y -- 434
				local ____temp_5 = s.y + s.h -- 434
				local ____temp_1 -- 435
				if room.depth == nil then -- 435
					____temp_1 = nil -- 435
				else -- 435
					____temp_1 = s.depth -- 435
				end -- 435
				____self_boxes_6[#____self_boxes_6 + 1] = { -- 433
					x0 = ____s_x_2, -- 434
					x1 = ____temp_3, -- 434
					y0 = ____s_y_4, -- 434
					y1 = ____temp_5, -- 434
					depth = ____temp_1, -- 435
					passable = s.passable == true, -- 436
					label = s.label -- 436
				} -- 436
			end -- 436
			i = i + 1 -- 430
		end -- 430
	end -- 430
	do -- 430
		i = 0 -- 440
		while i < #room.stairs do -- 440
			local st = room.stairs[i + 1] -- 441
			local n = st.steps + 1 -- 442
			local stepW = (st.x1 - st.x0) / n -- 443
			local k = 0 -- 444
			do -- 444
				k = 0 -- 445
				while k < n do -- 445
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 446
					local x0 = st.x0 + stepW * k -- 447
					local ____self_boxes_7 = self.boxes -- 447
					____self_boxes_7[#____self_boxes_7 + 1] = { -- 449
						x0 = x0, -- 449
						x1 = x0 + stepW, -- 449
						y0 = -8, -- 449
						y1 = y, -- 449
						passable = true -- 449
					} -- 449
					k = k + 1 -- 445
				end -- 445
			end -- 445
			i = i + 1 -- 440
		end -- 440
	end -- 440
end -- 421
function Play.prototype.buildEnemies(self) -- 454
	self.enemies = {} -- 455
	if self.room.key == "checkpoint" then -- 455
		local ____self_enemies_8 = self.enemies -- 455
		____self_enemies_8[#____self_enemies_8 + 1] = { -- 457
			x = self.ox + 430, -- 457
			y = 0, -- 457
			w = 26, -- 457
			h = 84, -- 457
			alive = true, -- 457
			hitT = 0, -- 457
			warnT = 0, -- 457
			fireCd = 0 -- 457
		} -- 457
		local ____self_enemies_9 = self.enemies -- 457
		____self_enemies_9[#____self_enemies_9 + 1] = { -- 458
			x = self.ox + 505, -- 458
			y = 0, -- 458
			w = 26, -- 458
			h = 84, -- 458
			alive = true, -- 458
			hitT = 0, -- 458
			warnT = 0, -- 458
			fireCd = 0 -- 458
		} -- 458
		return -- 459
	end -- 459
	if self.room.key == "street" then -- 459
		local ____self_enemies_10 = self.enemies -- 459
		____self_enemies_10[#____self_enemies_10 + 1] = { -- 463
			x = self.ox + 340, -- 463
			y = 0, -- 463
			w = 26, -- 463
			h = 84, -- 463
			alive = true, -- 463
			hitT = 0, -- 463
			warnT = 0, -- 463
			fireCd = 0 -- 463
		} -- 463
		local ____self_enemies_11 = self.enemies -- 463
		____self_enemies_11[#____self_enemies_11 + 1] = { -- 464
			x = self.ox + 560, -- 464
			y = 0, -- 464
			w = 26, -- 464
			h = 84, -- 464
			alive = true, -- 464
			hitT = 0, -- 464
			warnT = 0, -- 464
			fireCd = 0 -- 464
		} -- 464
	end -- 464
end -- 454
function Play.prototype.emit(self, name, data) -- 470
	local ____self_events_12 = self.events -- 470
	____self_events_12[#____self_events_12 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 471
	self.eventSeq = self.eventSeq + 1 -- 472
	if #self.events > 256 then -- 472
		table.remove(self.events, 1) -- 474
	end -- 474
end -- 470
function Play.prototype.drainEvents(self) -- 482
	local out = self.events -- 483
	self.events = {} -- 484
	return out -- 485
end -- 482
function Play.prototype.adoptEvents(self, events) -- 494
	if #events == 0 then -- 494
		return -- 496
	end -- 496
	local keep = {} -- 498
	local i = 0 -- 499
	do -- 499
		i = 0 -- 500
		while i < #events do -- 500
			do -- 500
				local e = events[i + 1] -- 501
				if e.name == "knock" and e.data.room ~= self.room.key then -- 501
					goto __continue33 -- 503
				end -- 503
				keep[#keep + 1] = e -- 505
			end -- 505
			::__continue33:: -- 505
			i = i + 1 -- 500
		end -- 500
	end -- 500
	if #keep == 0 then -- 500
		return -- 508
	end -- 508
	self.events = __TS__ArrayConcat(keep, self.events) -- 510
	do -- 510
		i = 0 -- 511
		while i < #self.events do -- 511
			self.events[i + 1].seq = i -- 512
			i = i + 1 -- 511
		end -- 511
	end -- 511
	self.eventSeq = #self.events -- 514
end -- 494
function Play.prototype.update(self, dt, input) -- 518
	if input.pause.pressed then -- 518
		self.paused = not self.paused -- 520
	end -- 520
	if self.flashT > 0 then -- 520
		self.flashT = self.flashT - dt -- 523
		if self.flashT <= 0 then -- 523
			self.flash = "" -- 525
		end -- 525
	end -- 525
	if self.traceT > 0 then -- 525
		self.traceT = self.traceT - dt -- 529
		if self.traceT <= 0 then -- 529
			self.trace = nil -- 531
		end -- 531
	end -- 531
	if self.paused then -- 531
		self:updateCamera(dt) -- 535
		return -- 536
	end -- 536
	self.ticks = self.ticks + 1 -- 539
	local p = self.player -- 540
	self:stepPlayer(p, dt, input) -- 541
	self:refreshCover(p, input) -- 543
	self:stepEnemies(dt, input) -- 545
	self:stepStory(dt, input) -- 546
	self:stepEscort(dt, input) -- 547
	self:stepVillage(dt, input) -- 548
	self:stepChase(dt, input) -- 549
	self:stepInteract(dt, input) -- 550
	self:updateGate() -- 551
	self:updateCamera(dt) -- 552
end -- 518
function Play.prototype.underLowArch(self, a) -- 559
	local arch = self.room.arch -- 560
	if arch.h <= 0 then -- 560
		return false -- 562
	end -- 562
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 562
		return false -- 565
	end -- 565
	local top = arch.y + arch.h -- 567
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 568
end -- 559
function Play.prototype.coverAt(self, a) -- 575
	local best = nil -- 576
	local bestGap = 24 -- 577
	local half = a.w / 2 -- 578
	local i = 0 -- 579
	do -- 579
		i = 0 -- 580
		while i < #self.boxes do -- 580
			do -- 580
				local b = self.boxes[i + 1] -- 581
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 581
					goto __continue50 -- 583
				end -- 583
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 583
					goto __continue50 -- 586
				end -- 586
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 588
				if gap < bestGap then -- 588
					bestGap = gap -- 590
					best = b -- 591
				end -- 591
			end -- 591
			::__continue50:: -- 591
			i = i + 1 -- 580
		end -- 580
	end -- 580
	return best -- 594
end -- 575
function Play.prototype.nearCover(self, a) -- 597
	return self:coverAt(a) ~= nil -- 598
end -- 597
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 602
	if enemy == nil then -- 602
		return false -- 604
	end -- 604
	local fromRight = enemy.x >= a.x -- 606
	local edge = fromRight and b.x0 or b.x1 -- 607
	local ____fromRight_13 -- 608
	if fromRight then -- 608
		____fromRight_13 = edge >= a.x - 0.001 and edge <= enemy.x -- 608
	else -- 608
		____fromRight_13 = edge <= a.x + 0.001 and edge >= enemy.x -- 609
	end -- 609
	local between = ____fromRight_13 -- 608
	local separation = enemy.x - a.x -- 610
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 611
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 612
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 613
end -- 602
function Play.prototype.nearestEnemy(self, a) -- 616
	local best -- 617
	local bestD = 1000000000 -- 618
	local i = 0 -- 619
	do -- 619
		i = 0 -- 620
		while i < #self.enemies do -- 620
			do -- 620
				local e = self.enemies[i + 1] -- 621
				if not e.alive then -- 621
					goto __continue59 -- 623
				end -- 623
				local d = math.abs(e.x - a.x) -- 625
				if d < bestD then -- 625
					bestD = d -- 627
					best = e -- 628
				end -- 628
			end -- 628
			::__continue59:: -- 628
			i = i + 1 -- 620
		end -- 620
	end -- 620
	return best -- 631
end -- 616
function Play.prototype.refreshCover(self, a, input) -- 635
	if self.childMode then -- 635
		self.coverNear = false -- 637
		self.coverHug = false -- 638
		self.coverEntity = "" -- 639
		self.coverBlocking = false -- 640
		a.covered = false -- 641
		return -- 642
	end -- 642
	local b = self:coverAt(a) -- 644
	self.coverNear = b ~= nil -- 645
	a.covered = self.coverNear and input.cover.held -- 646
	self.coverHug = a.covered -- 647
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 648
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 649
		b, -- 649
		a, -- 649
		self:nearestEnemy(a) -- 649
	) -- 649
end -- 635
function Play.prototype.cartHandleInReach(self, a) -- 653
	if a == nil then -- 653
		a = self.player -- 653
	end -- 653
	local c = self.room.cart -- 654
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 654
		return false -- 656
	end -- 656
	local handleX = self.cartAxle + c.handleOffset -- 658
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 659
end -- 653
function Play.prototype.nearLowLedge(self, a) -- 664
	local reach = 26 -- 665
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 666
	local x1 = x0 + reach -- 667
	local i = 0 -- 668
	do -- 668
		i = 0 -- 669
		while i < #self.boxes do -- 669
			do -- 669
				local b = self.boxes[i + 1] -- 670
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 670
					goto __continue68 -- 672
				end -- 672
				local rise = b.y1 - a.y -- 674
				if rise > 0 and rise <= LEDGE_RISE then -- 674
					return true -- 676
				end -- 676
			end -- 676
			::__continue68:: -- 676
			i = i + 1 -- 669
		end -- 669
	end -- 669
	return false -- 679
end -- 664
function Play.prototype.stepPlayer(self, a, dt, input) -- 682
	a.depthSpeed = 0 -- 683
	if not a.alive then -- 683
		return -- 685
	end -- 685
	local isChild = self.childMode -- 687
	local lowArch = isChild and self:underLowArch(a) -- 689
	if self:storyLocked() then -- 689
		a.vx = 0 -- 692
		a.crouch = isChild and lowArch -- 693
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 694
		self:fallY(a, dt) -- 695
		return -- 696
	end -- 696
	if not isChild and self.escort.state == "calming" then -- 696
		a.crouch = false -- 700
		a.h = SOLDIER_H -- 701
		a.vx = 0 -- 702
		self:fallY(a, dt) -- 703
		return -- 704
	end -- 704
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 706
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 707
	local nearCover = not isChild and self:nearCover(a) -- 708
	a.covered = nearCover and input.cover.held -- 709
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 711
	if a.rollT > 0 then -- 711
		a.rollT = a.rollT - dt -- 715
		a.vx = a.facing * ROLL_SPEED -- 716
		self:slideX(a, a.vx * dt) -- 717
		self:fallY(a, dt) -- 718
		if a.rollT <= 0 then -- 718
			self:flashSet("翻滚结束", 0.5) -- 720
		end -- 720
		return -- 722
	end -- 722
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 722
		if input.moveX ~= 0 then -- 722
			a.facing = input.moveX > 0 and 1 or -1 -- 727
		end -- 727
		if self:nearLowLedge(a) then -- 727
			a.vy = SOLDIER_JUMP -- 731
			a.onGround = false -- 732
			self:flashSet("翻上去", 0.3) -- 733
			return -- 734
		end -- 734
		a.rollT = ROLL_TIME -- 736
		self:flashSet("翻滚", 0.3) -- 737
		return -- 738
	end -- 738
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 741
	if isChild then -- 741
		if input.cover.held then -- 741
			speed = CHILD_SLOW -- 744
		end -- 744
		if a.crouch then -- 744
			speed = CHILD_SLOW -- 747
		end -- 747
	elseif a.covered then -- 747
		speed = SOLDIER_SPEED * 0.45 -- 750
	end -- 750
	local handsBusy = self.gripping or gripIntent -- 754
	local dir = self.gripping and 0 or input.moveX -- 755
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 756
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 757
	if dir ~= 0 then -- 757
		a.facing = dir > 0 and 1 or -1 -- 759
	end -- 759
	a.vx = dir * speed * diagonal -- 761
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 761
		a.vy = CHILD_JUMP -- 765
		a.onGround = false -- 766
		self:flashSet("跳", 0.25) -- 767
	end -- 767
	local previousDepth = a.depth -- 771
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 772
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 773
	self:slideX(a, a.vx * dt) -- 774
	self:fallY(a, dt) -- 775
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 775
		self:shoot(a) -- 779
	end -- 779
end -- 682
function Play.prototype.stepPartner(self, p, dt) -- 784
	local a = self.partner -- 785
	if not a.alive then -- 785
		return -- 787
	end -- 787
	a.crouch = false -- 789
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 790
	a.vx = 0 -- 791
	a.depthSpeed = 0 -- 792
	self:fallY(a, dt) -- 793
end -- 784
function Play.prototype.stepEscort(self, dt, input) -- 800
	local a = self.partner -- 801
	a.depthSpeed = 0 -- 802
	if not a.alive then -- 802
		return -- 804
	end -- 804
	if not self:escortOn() then -- 804
		a.vx = 0 -- 807
		self:fallY(a, dt) -- 808
		return -- 809
	end -- 809
	local p = self.player -- 811
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 812
	local hadKnock1 = self.escort.knock1 -- 813
	local hadKnock2 = self.escort.knock2 -- 814
	self.calmConsumed = self.escort:update( -- 815
		input, -- 815
		p.x, -- 815
		p.facing, -- 815
		a.x, -- 815
		dist -- 815
	) -- 815
	if not hadKnock1 and self.escort.knock1 then -- 815
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 818
	end -- 818
	if not hadKnock2 and self.escort.knock2 then -- 818
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 821
	end -- 821
	a.crouch = self.escort.crouchPose -- 823
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 824
	if not self.escort.stopped then -- 824
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 826
		local previousDepth = a.depth -- 827
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 828
		local distance = math.max( -- 829
			-travel, -- 829
			math.min(travel, targetDepth - previousDepth) -- 829
		) -- 829
		self:slideDepth(a, distance) -- 830
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 831
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 831
			a.vy = CHILD_JUMP -- 833
			a.onGround = false -- 834
		end -- 834
	end -- 834
	local dir = self.escort:moveDir(a.x) -- 837
	a.vx = dir * CHILD_SPEED -- 838
	if dir ~= 0 then -- 838
		a.facing = dir -- 840
		local before = a.x -- 841
		self:slideX(a, dir * CHILD_SPEED * dt) -- 842
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 842
			a.vy = CHILD_JUMP -- 845
			a.onGround = false -- 846
		end -- 846
	end -- 846
	self:fallY(a, dt) -- 849
end -- 800
function Play.prototype.escortOn(self) -- 853
	if self.room.key == "checkpoint" then -- 853
		return true -- 855
	end -- 855
	if self.room.key == "prologue" then -- 855
		return self.phase == "prologue-follow" -- 858
	end -- 858
	return self.room.key == "street" -- 860
end -- 853
function Play.prototype.storyLocked(self) -- 864
	if self.caughtT > 0 then -- 864
		return true -- 866
	end -- 866
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 866
		return true -- 869
	end -- 869
	if self.room.key == "gate" and self.phase == "gate-count" then -- 869
		return true -- 872
	end -- 872
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 872
		return true -- 875
	end -- 875
	return false -- 877
end -- 864
function Play.prototype.swapToChild(self, x) -- 881
	local tmp = self.player -- 882
	self.player = self.partner -- 883
	self.partner = tmp -- 884
	self.childMode = true -- 885
	self.player.alive = true -- 886
	self.player.x = self.ox + x -- 887
	self.player.y = 0 -- 888
	self.player.depth = 0 -- 889
	self.player.depthSpeed = 0 -- 890
	self.player.vy = 0 -- 891
	self.player.vx = 0 -- 892
	self.player.onGround = true -- 893
	self.player.crouch = false -- 894
	self.player.h = CHILD_H -- 895
	self.player.facing = 1 -- 896
	self.partner.alive = true -- 897
	self.cam.x = self.player.x -- 898
end -- 881
function Play.prototype.stepStory(self, dt, input) -- 902
	if self.room.key == "prologue" then -- 902
		self:stepPrologue(dt, input) -- 904
	elseif self.room.key == "street" then -- 904
		self:stepStreet(dt, input) -- 906
	elseif self.room.key == "gate" then -- 906
		self:stepGate(dt, input) -- 908
	elseif self.room.key == "tower" then -- 908
		self:stepTower(dt, input) -- 910
	end -- 910
end -- 902
function Play.prototype.stepPrologue(self, dt, input) -- 915
	local child = self.partner -- 916
	if self.phase == "prologue-wait" then -- 916
		child.crouch = true -- 918
		child.h = CHILD_CROUCH_H -- 919
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 920
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 922
		if near and input.interact.pressed then -- 922
			self.phase = "prologue-give" -- 924
			self.phaseTick = 0 -- 925
			self:flashSet("递出针套", 1) -- 926
		end -- 926
		return -- 928
	end -- 928
	if self.phase == "prologue-give" then -- 928
		self.phaseTick = self.phaseTick + 1 -- 931
		if self.phaseTick == 12 then -- 931
			self:flashSet("针套递过去", 0.7) -- 933
		elseif self.phaseTick == 36 then -- 933
			self:flashSet("纸条塞进针套", 0.9) -- 935
		elseif self.phaseTick >= 60 then -- 935
			self.phase = "prologue-follow" -- 937
			self.phaseTick = 0 -- 938
			child.crouch = false -- 939
			child.h = CHILD_H -- 940
			self:flashSet("她跟上了", 1.2) -- 941
		end -- 941
		return -- 943
	end -- 943
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 943
		self:requestRoom("street", "序章跟到门口") -- 947
		self:flashSet("进街道", 1.2) -- 948
	end -- 948
end -- 915
function Play.prototype.stepStreet(self, dt, input) -- 953
	local p = self.player -- 954
	local c = self.partner -- 955
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 955
		self:requestRoom("checkpoint", "两人都到街尾") -- 957
		self:flashSet("到检查站", 1.2) -- 958
	end -- 958
end -- 953
function Play.prototype.stepGate(self, dt, input) -- 963
	local ____temp_14 -- 964
	if self.room.story == nil then -- 964
		____temp_14 = nil -- 964
	else -- 964
		____temp_14 = self.room.story.gate -- 964
	end -- 964
	local g = ____temp_14 -- 964
	if g == nil then -- 964
		return -- 966
	end -- 966
	local p = self.player -- 968
	if self.phase == "gate-idle" then -- 968
		local a = self.partner -- 971
		local gap = g.waitX - a.x -- 972
		if math.abs(gap) > 3 then -- 972
			a.facing = gap > 0 and 1 or -1 -- 974
			a.vx = a.facing * CHILD_SPEED -- 975
			local beforeX = a.x -- 976
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 977
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 977
				a.vy = CHILD_JUMP -- 979
				a.onGround = false -- 980
			end -- 980
			self:fallY(a, dt) -- 982
		else -- 982
			a.vx = 0 -- 984
			a.x = g.waitX -- 985
		end -- 985
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 988
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 989
		if self.gateNeedConfirm then -- 989
			if not input.interact.held then -- 989
				self.gateRestartArmed = true -- 994
			end -- 994
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 994
				self.gateNeedConfirm = false -- 997
				self.gateRestartArmed = true -- 998
				self.phase = "gate-hold" -- 999
				self.gateTick = 0 -- 1000
				self.gateSpawned = 0 -- 1001
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1002
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1003
			end -- 1003
			return -- 1005
		end -- 1005
		if atWinch and atWait then -- 1005
			self.phase = "gate-hold" -- 1008
			self.gateTick = 0 -- 1009
			self.gateSpawned = 0 -- 1010
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1011
		end -- 1011
		return -- 1013
	end -- 1013
	if self.phase == "gate-hold" then -- 1013
		self.gateTick = self.gateTick + 1 -- 1016
		local marks = {0, 540, 900, 1500} -- 1018
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1018
			local idx = self.gateSpawned -- 1020
			local ____self_enemies_15 = self.enemies -- 1020
			____self_enemies_15[#____self_enemies_15 + 1] = { -- 1021
				x = self.ox + 620 + idx * 62, -- 1022
				y = 0, -- 1022
				w = 26, -- 1022
				h = 84, -- 1022
				alive = true, -- 1023
				hitT = 0, -- 1023
				warnT = 0, -- 1023
				fireCd = 90 + idx * 45 -- 1023
			} -- 1023
			self.gateSpawned = self.gateSpawned + 1 -- 1025
			self:flashSet( -- 1026
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1026
				0.9 -- 1026
			) -- 1026
		end -- 1026
		if self.gateTick == 900 then -- 1026
			self:flashSet("灯灭了", 1) -- 1029
		elseif self.gateTick == 2100 then -- 1029
			self:flashSet("门底压下来了", 1) -- 1031
		end -- 1031
		if self.gateTick >= g.holdTicks then -- 1031
			self.phase = "gate-send" -- 1034
			self.phaseTick = 0 -- 1035
			self.enemies = {} -- 1037
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1038
		end -- 1038
		return -- 1040
	end -- 1040
	if self.phase == "gate-send" then -- 1040
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1043
		if near and input.interact.pressed then -- 1043
			self:swapToChild(g.doorX + 30) -- 1045
			self.phase = "gate-count" -- 1046
			self.countTick = 0 -- 1047
			self.countArmed = false -- 1049
			self.countPrevMove = input.moveX -- 1050
			self:flashSet("门开了 · 送她出去", 1.8) -- 1051
		end -- 1051
		return -- 1053
	end -- 1053
	if self.phase == "gate-count" then -- 1053
		self.countTick = self.countTick + 1 -- 1056
		if self.countTick == 360 then -- 1056
			self:flashSet("门关上", 0.9) -- 1058
		elseif self.countTick == 1020 then -- 1058
			self:flashSet("数到一百", 2.2) -- 1060
		end -- 1060
		local prevMove = self.countPrevMove -- 1064
		self.countPrevMove = input.moveX -- 1065
		if self.countTick >= 1440 then -- 1065
			if prevMove <= 0 and input.moveX > 0 then -- 1065
				self.countArmed = true -- 1068
			end -- 1068
			if self.countArmed and input.moveX > 0 then -- 1068
				self.phase = "gate-walk" -- 1071
				self.phaseTick = 0 -- 1072
				self:flashSet("她迈出第一步", 1.4) -- 1073
			end -- 1073
		end -- 1073
		return -- 1076
	end -- 1076
	if self.player.x >= g.exitX then -- 1076
		self:requestRoom("outside", "走出城门") -- 1080
		self:flashSet("出城门 · 城外", 1.4) -- 1081
	end -- 1081
end -- 963
function Play.prototype.stepTower(self, dt, input) -- 1086
	local ____temp_16 -- 1087
	if self.room.story == nil then -- 1087
		____temp_16 = nil -- 1087
	else -- 1087
		____temp_16 = self.room.story.tower -- 1087
	end -- 1087
	local t = ____temp_16 -- 1087
	if t == nil then -- 1087
		return -- 1089
	end -- 1089
	if self.phase == "tower-wait" then -- 1089
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1092
		if near and input.interact.pressed then -- 1092
			self.phase = "tower-knock" -- 1094
			self.phaseTick = 0 -- 1095
			self.knocks = 1 -- 1096
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1097
			self:flashSet("敲一下", 0.6) -- 1098
		end -- 1098
		return -- 1100
	end -- 1100
	if self.phase == "tower-knock" then -- 1100
		self.phaseTick = self.phaseTick + 1 -- 1103
		if self.phaseTick == 12 then -- 1103
			self.knocks = 2 -- 1105
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1106
			self:flashSet("敲两下 · 第二声", 1) -- 1107
		elseif self.phaseTick >= t.knockTicks then -- 1107
			self.phase = "tower-given" -- 1109
			self.phaseTick = 0 -- 1110
			self:flashSet("门开了 · 提灯", 1.4) -- 1111
		end -- 1111
		return -- 1113
	end -- 1113
	if self.phase == "tower-given" then -- 1113
		self.phaseTick = self.phaseTick + 1 -- 1116
		if self.phaseTick == 60 then -- 1116
			self:flashSet("她递出针套和纸条", 1.6) -- 1118
		elseif self.phaseTick == 120 then -- 1118
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1120
		elseif self.phaseTick >= 180 then -- 1120
			self.phase = "tower-end" -- 1122
			self.phaseTick = 0 -- 1123
			self:flashSet("片尾 · E 再玩一次", 3) -- 1124
		end -- 1124
		return -- 1126
	end -- 1126
	if input.interact.pressed or input.retry.pressed then -- 1126
		self:requestRoom("prologue", "片尾再玩") -- 1129
		self:flashSet("回到序章", 1.4) -- 1130
	end -- 1130
end -- 1086
function Play.prototype.stepChase(self, dt, input) -- 1135
	if self.caughtT > 0 then -- 1135
		self.caughtT = self.caughtT - dt -- 1137
		if self.caughtT <= 0 then -- 1137
			self:recoverFromCaught() -- 1139
		end -- 1139
		return -- 1141
	end -- 1141
	if self.room.key == "village" then -- 1141
		self:stepScavChase() -- 1144
	elseif self.room.key == "forest" then -- 1144
		self:stepDog(dt) -- 1146
		if self.player.x >= self.ox + 1450 then -- 1146
			self:requestRoom("tower", "到林缘北塔") -- 1149
			self:flashSet("林缘 · 北塔", 1.4) -- 1150
		end -- 1150
	end -- 1150
end -- 1135
function Play.prototype.stepScavChase(self) -- 1156
	local s = self.room.scavenger -- 1157
	if s == nil then -- 1157
		return -- 1159
	end -- 1159
	local p = self.player -- 1161
	if self.passed and p.x > self.ox + 440 then -- 1161
		if self.scavChase then -- 1161
			self.scavChase = false -- 1165
			self.scavState = "back" -- 1166
			self.scavT = 0 -- 1167
		end -- 1167
		return -- 1169
	end -- 1169
	local dx = p.x - self.scavX -- 1171
	local dist = math.abs(dx) -- 1172
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1173
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1174
	if not self.scavChase then -- 1174
		if visible then -- 1174
			self.scavSee = self.scavSee + 1 -- 1177
			if self.scavSee >= 24 then -- 1177
				self.scavChase = true -- 1179
				self.scavState = "chase" -- 1180
				self.scavTargetX = p.x -- 1181
				self:flashSet("他看见你了", 1.2) -- 1182
			end -- 1182
		else -- 1182
			self.scavSee = 0 -- 1185
		end -- 1185
		return -- 1187
	end -- 1187
	local dir = p.x > self.scavX and 1 or -1 -- 1190
	self.scavX = self.scavX + dir * 96 / 60 -- 1191
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1191
		self:caught() -- 1193
		return -- 1194
	end -- 1194
	if hidden then -- 1194
		self.scavSee = 0 -- 1198
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1199
		self.scavT = self.scavT - 1 -- 1200
		if self.scavT <= 0 then -- 1200
			self.scavChase = false -- 1202
			self.scavState = "patrol" -- 1203
			self:flashSet("他失去了目标", 1) -- 1204
		end -- 1204
	end -- 1204
end -- 1156
function Play.prototype.stepDog(self, dt) -- 1210
	local ____temp_17 -- 1211
	if self.room.story == nil then -- 1211
		____temp_17 = nil -- 1211
	else -- 1211
		____temp_17 = self.room.story.dog -- 1211
	end -- 1211
	local dog = ____temp_17 -- 1211
	if dog == nil then -- 1211
		return -- 1213
	end -- 1213
	local p = self.player -- 1215
	local dist = math.abs(p.x - self.dogX) -- 1216
	if self.dogState == "patrol" then -- 1216
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1218
		if self.dogX < dog.x0 then -- 1218
			self.dogX = dog.x0 -- 1220
			self.dogDir = 1 -- 1221
		elseif self.dogX > dog.x1 then -- 1221
			self.dogX = dog.x1 -- 1223
			self.dogDir = -1 -- 1224
		end -- 1224
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1226
		if not p.crouch and moving and dist < dog.range then -- 1226
			self.dogState = "ear" -- 1228
			self.dogT = 18 -- 1229
			self.dogTargetX = p.x -- 1230
			self:flashSet("狗转耳朵", 0.8) -- 1231
		end -- 1231
		return -- 1233
	end -- 1233
	if self.dogState == "ear" then -- 1233
		self.dogT = self.dogT - 1 -- 1236
		if self.dogT <= 0 then -- 1236
			self.dogState = "chase" -- 1238
			self.dogTargetX = p.x -- 1239
			self:flashSet("狗追来了", 1.4) -- 1240
		end -- 1240
		return -- 1242
	end -- 1242
	if self.dogState == "chase" then -- 1242
		local dir = p.x > self.dogX and 1 or -1 -- 1245
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1246
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1246
			self:caught() -- 1248
			self.dogState = "sniff" -- 1249
			self.dogT = 60 -- 1250
		elseif dist > dog.range * 1.5 or p.crouch then -- 1250
			self.dogState = "sniff" -- 1252
			self.dogT = 60 -- 1253
			self:flashSet("狗停下了", 0.9) -- 1254
		end -- 1254
		return -- 1256
	end -- 1256
	if self.dogState == "sniff" then -- 1256
		self.dogT = self.dogT - 1 -- 1259
		if self.dogT <= 0 then -- 1259
			self.dogState = "back" -- 1261
		end -- 1261
		return -- 1263
	end -- 1263
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1266
	self.dogX = self.dogX + dir * dog.speed * dt -- 1267
	if math.abs(self.dogX - dog.x0) < 2 then -- 1267
		self.dogX = dog.x0 -- 1269
		self.dogState = "patrol" -- 1270
	end -- 1270
end -- 1210
function Play.prototype.caught(self) -- 1274
	self.caughtT = 1 -- 1275
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1276
end -- 1274
function Play.prototype.recoverFromCaught(self) -- 1280
	local p = self.player -- 1281
	p.x = self.ox + 140 -- 1282
	p.y = 0 -- 1283
	p.vy = 0 -- 1284
	p.vx = 0 -- 1285
	p.onGround = true -- 1286
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1286
		self.scavX = self.room.scavenger.x0 -- 1288
		self.scavState = "patrol" -- 1289
		self.scavSee = 0 -- 1290
		self.scavChase = false -- 1291
		self.scavT = 0 -- 1292
	end -- 1292
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1292
		self.dogX = self.room.story.dog.x0 -- 1295
		self.dogState = "patrol" -- 1296
		self.dogT = 0 -- 1297
	end -- 1297
	self.cam.x = p.x -- 1299
	self.cam.y = p.y + CAM_LOOK_UP -- 1300
	self:flashSet("回到安全点", 1.2) -- 1301
end -- 1280
function Play.prototype.updateGate(self) -- 1305
	if self.room.key ~= "checkpoint" then -- 1305
		self.gateOpen = false -- 1307
		return -- 1308
	end -- 1308
	local function inZone(x) -- 1310
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1310
	end -- 1310
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1311
end -- 1305
function Play.prototype.stepEnemies(self, dt, input) -- 1314
	local i = 0 -- 1315
	do -- 1315
		i = 0 -- 1316
		while i < #self.enemies do -- 1316
			local e = self.enemies[i + 1] -- 1317
			if e.hitT > 0 then -- 1317
				e.hitT = e.hitT - dt -- 1319
			end -- 1319
			i = i + 1 -- 1316
		end -- 1316
	end -- 1316
	if self.coveredFlash > 0 then -- 1316
		self.coveredFlash = self.coveredFlash - dt -- 1323
	end -- 1323
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 1323
		return -- 1327
	end -- 1327
	do -- 1327
		i = 0 -- 1329
		while i < #self.enemies do -- 1329
			do -- 1329
				local e = self.enemies[i + 1] -- 1330
				if not e.alive then -- 1330
					goto __continue203 -- 1332
				end -- 1332
				if e.warnT > 0 then -- 1332
					e.warnT = e.warnT - 1 -- 1335
					if e.warnT <= 0 then -- 1335
						self:enemyFire(e, input) -- 1337
					end -- 1337
					goto __continue203 -- 1339
				end -- 1339
				if e.fireCd > 0 then -- 1339
					e.fireCd = e.fireCd - 1 -- 1342
					if e.fireCd <= 0 then -- 1342
						e.warnT = WARN_TICKS -- 1344
					end -- 1344
				else -- 1344
					e.warnT = WARN_TICKS -- 1348
				end -- 1348
			end -- 1348
			::__continue203:: -- 1348
			i = i + 1 -- 1329
		end -- 1329
	end -- 1329
end -- 1314
function Play.prototype.enemyFire(self, e, input) -- 1354
	local p = self.player -- 1355
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 1355
		self:flashSet("枪声响在远处", 0.4) -- 1357
		e.fireCd = FIRE_COOLDOWN -- 1358
		return -- 1359
	end -- 1359
	local cover = self:blockedByCover(e, p) -- 1362
	local hugging = cover ~= nil -- 1363
	self.coverBlocking = hugging -- 1364
	local covered = hugging and input.cover.held -- 1365
	if covered then -- 1365
		self.coveredFlash = 0.5 -- 1367
		self:flashSet("掩体挡下", 0.5) -- 1368
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 1369
		e.fireCd = FIRE_COOLDOWN -- 1374
		return -- 1375
	end -- 1375
	self.hp = self.hp - 1 -- 1377
	self:emit("actorHit", { -- 1378
		target = "player", -- 1378
		amount = 1, -- 1378
		hp = self.hp, -- 1378
		maxHp = self.maxHp, -- 1378
		enemyX = e.x -- 1378
	}) -- 1378
	self:flashSet( -- 1379
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 1379
		0.7 -- 1379
	) -- 1379
	e.fireCd = FIRE_COOLDOWN -- 1380
	if self.hp <= 0 then -- 1380
		self:gateFailed() -- 1382
	end -- 1382
end -- 1354
function Play.prototype.blockedByCover(self, enemy, p) -- 1387
	local b = self:coverAt(p) -- 1388
	if b == nil then -- 1388
		return nil -- 1390
	end -- 1390
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 1392
end -- 1387
function Play.prototype.gateFailed(self) -- 1396
	local ____temp_18 -- 1397
	if self.room.story == nil then -- 1397
		____temp_18 = nil -- 1397
	else -- 1397
		____temp_18 = self.room.story.gate -- 1397
	end -- 1397
	local g = ____temp_18 -- 1397
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 1398
	self.hp = self.maxHp -- 1399
	self.gateTick = 0 -- 1400
	self.gateSpawned = 0 -- 1401
	self.enemies = {} -- 1402
	self.gateFailCount = self.gateFailCount + 1 -- 1403
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 1405
	self.player.y = 0 -- 1406
	self.player.vy = 0 -- 1407
	self.player.depth = 0 -- 1408
	self.player.depthSpeed = 0 -- 1409
	self.player.onGround = true -- 1410
	self.player.crouch = false -- 1411
	self.player.h = SOLDIER_H -- 1412
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 1413
	self.partner.y = 0 -- 1414
	self.partner.vy = 0 -- 1415
	self.partner.depth = 0 -- 1416
	self.partner.depthSpeed = 0 -- 1417
	self.partner.onGround = true -- 1418
	self.cam.x = self.player.x -- 1419
	self.phase = "gate-idle" -- 1420
	self.phaseTick = 0 -- 1421
	self.coverHug = false -- 1422
	self.coverBlocking = false -- 1423
	self.coverEntity = "" -- 1424
	self.gateNeedConfirm = true -- 1425
	self.gateRestartArmed = false -- 1426
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 1427
end -- 1396
function Play.prototype.stepInteract(self, dt, input) -- 1430
	local p = self.player -- 1431
	local calmUsed = self.calmConsumed -- 1432
	self.calmConsumed = false -- 1433
	local calming = self.escort.state == "calming" -- 1435
	self.focusCart = false -- 1436
	if self.room.key == "outside" then -- 1436
		local c = self.room.cart -- 1438
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 1439
		local dy = p.y - c.baseY -- 1440
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 1441
	end -- 1441
	if not calmUsed and not calming then -- 1441
		self:stepCart(dt, input) -- 1445
	end -- 1445
	if calmUsed then -- 1445
		self:flashSet("安抚 · 敲两下", 0.8) -- 1450
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 1450
		if self.knockT > 0 then -- 1450
			self.knocks = self.knocks + 1 -- 1454
		else -- 1454
			self.knocks = 1 -- 1456
		end -- 1456
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 1458
		self.knockT = 1.2 -- 1459
		if self.knocks >= 2 then -- 1459
			self:flashSet("敲两下", 0.8) -- 1461
			self.knocks = 0 -- 1462
		else -- 1462
			self:flashSet("敲一下", 0.5) -- 1464
		end -- 1464
	elseif self.knockT > 0 then -- 1464
		self.knockT = self.knockT - dt -- 1467
		if self.knockT <= 0 then -- 1467
			self.knocks = 0 -- 1469
		end -- 1469
	end -- 1469
	local i = 0 -- 1474
	do -- 1474
		i = 0 -- 1475
		while i < #self.room.marks do -- 1475
			do -- 1475
				local m = self.room.marks[i + 1] -- 1476
				if m.kind ~= 0 then -- 1476
					goto __continue229 -- 1478
				end -- 1478
				local subjects = {self.partner, self.player} -- 1480
				local k = 0 -- 1481
				do -- 1481
					k = 0 -- 1482
					while k < #subjects do -- 1482
						do -- 1482
							local s = subjects[k + 1] -- 1483
							if not s.alive then -- 1483
								goto __continue232 -- 1485
							end -- 1485
							local dx = s.x - m.x -- 1487
							local dy = s.y - m.y -- 1488
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 1488
								self.checkpoint = m.x -- 1490
								self.checkpointCartAxle = self.cartAxle -- 1491
								if self.cartDocked then -- 1491
									self:flashSet("检查点 · 车已落窝", 1) -- 1493
								else -- 1493
									self:flashSet("检查点 · 车还没到位", 1) -- 1495
								end -- 1495
							end -- 1495
						end -- 1495
						::__continue232:: -- 1495
						k = k + 1 -- 1482
					end -- 1482
				end -- 1482
			end -- 1482
			::__continue229:: -- 1482
			i = i + 1 -- 1475
		end -- 1475
	end -- 1475
	self:checkCarryGate() -- 1501
end -- 1430
function Play.prototype.stepVillage(self, dt, input) -- 1505
	if self.room.key ~= "village" then -- 1505
		return -- 1507
	end -- 1507
	local p = self.player -- 1509
	local bottle = self.room.bottle -- 1510
	local scav = self.room.scavenger -- 1511
	if not self.hasBottle and bottle ~= nil then -- 1511
		local dx = p.x - bottle.x -- 1515
		local dy = p.y + p.h * 0.5 - bottle.y -- 1516
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 1516
			self.hasBottle = true -- 1518
			self:flashSet("拾起瓶子", 0.8) -- 1519
		end -- 1519
	end -- 1519
	if self.hasBottle then -- 1519
		if input.aim.held then -- 1519
			self.aimHold = self.aimHold + dt -- 1526
			if self.aimHold > 1.2 then -- 1526
				self.aimHold = 1.2 -- 1528
			end -- 1528
			local cached = self:bottleEnd() -- 1531
			self.bottleAimX = cached.x -- 1532
			self.bottleAimY = cached.y -- 1533
		elseif input.aim.released then -- 1533
			if self.aimHold < 0.12 then -- 1533
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 1537
				self.aimHold = 0 -- 1538
			else -- 1538
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 1540
				self:throwBottle(____end.x, ____end.y) -- 1541
				self.aimHold = 0 -- 1542
			end -- 1542
		end -- 1542
	else -- 1542
		self.aimHold = 0 -- 1546
		self.bottleAimX = -1 -- 1547
	end -- 1547
	local fly = self.bottleFly -- 1552
	if fly ~= nil then -- 1552
		fly.t = fly.t + dt -- 1554
		fly.x = fly.x0 + fly.vx * fly.t -- 1555
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 1556
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 1557
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 1557
			self:landBottle(fly) -- 1559
		end -- 1559
	end -- 1559
	if self.bottleLandT > 0 then -- 1559
		self.bottleLandT = self.bottleLandT - dt -- 1563
	end -- 1563
	if scav ~= nil then -- 1563
		self:stepScav(dt, scav) -- 1567
	end -- 1567
	local line = self.room.passLine -- 1570
	if line ~= nil and not self.passed and p.x >= line then -- 1570
		self.passed = true -- 1572
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 1573
	end -- 1573
	if self.passed and p.x >= self.ox + 640 then -- 1573
		self:requestRoom("forest", "过第一院出院") -- 1577
		self:flashSet("出院 · 北塔森林", 1.4) -- 1578
	end -- 1578
end -- 1505
function Play.prototype.bottleEnd(self) -- 1583
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1584
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 1587
	return {x = aim.x, y = g} -- 1588
end -- 1583
function Play.prototype.throwBottle(self, tx, ty) -- 1592
	local p = self.player -- 1593
	local dir = tx >= p.x and 1 or -1 -- 1595
	p.facing = dir -- 1596
	local x0 = p.x + dir * 10 -- 1597
	local y0 = p.y + p.h * 0.7 -- 1598
	self.bottleTargetX = tx -- 1599
	self.bottleTargetY = ty -- 1600
	self.bottleSurfaceY = ty -- 1601
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 1602
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 1603
	self.bottleFly = { -- 1604
		x = x0, -- 1604
		y = y0, -- 1604
		x0 = x0, -- 1604
		y0 = y0, -- 1604
		vx = vx, -- 1604
		vy = vy, -- 1604
		t = 0 -- 1604
	} -- 1604
	self.hasBottle = false -- 1605
	self:flashSet("投出", 0.4) -- 1606
	self:emit( -- 1607
		"bottleThrown", -- 1607
		{ -- 1607
			fromX = x0, -- 1608
			fromY = y0, -- 1609
			targetX = tx, -- 1610
			targetY = ty, -- 1611
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 1612
		} -- 1612
	) -- 1612
end -- 1592
function Play.prototype.landBottle(self, fly) -- 1617
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 1618
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 1619
	local s = self.room.scavenger -- 1620
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 1621
	self.bottleFly = nil -- 1622
	self.bottleTargetX = -1 -- 1623
	self.bottleTargetY = 0 -- 1624
	self.bottleSurfaceY = -1 -- 1625
	self.bottleLandX = x -- 1626
	self.bottleLandY = y -- 1627
	self.bottleLandT = 0.9 -- 1628
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 1629
	self:hearBottle(x) -- 1630
end -- 1617
function Play.prototype.hearBottle(self, x) -- 1634
	local s = self.room.scavenger -- 1635
	if s == nil then -- 1635
		return -- 1637
	end -- 1637
	if math.abs(x - self.scavX) > s.range then -- 1637
		self:flashSet("落地 · 他没听见", 0.6) -- 1640
		return -- 1641
	end -- 1641
	self.scavState = "turn" -- 1643
	self.scavT = s.hearTicks -- 1644
	self.scavTargetX = x -- 1645
	self:flashSet("砖地一响 · 他转头", 0.9) -- 1646
end -- 1634
function Play.prototype.stepScav(self, dt, s) -- 1650
	if self.scavState == "chase" then -- 1650
		return -- 1653
	end -- 1653
	if self.scavState == "turn" then -- 1653
		self.scavT = self.scavT - 1 -- 1656
		if self.scavT <= 0 then -- 1656
			self.scavState = "walk" -- 1658
		end -- 1658
		return -- 1660
	end -- 1660
	if self.scavState == "walk" then -- 1660
		local d = self.scavTargetX - self.scavX -- 1663
		if math.abs(d) < 4 then -- 1663
			self.scavState = "stall" -- 1665
			self.scavT = s.stallTicks -- 1666
			return -- 1667
		end -- 1667
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 1669
		return -- 1670
	end -- 1670
	if self.scavState == "stall" then -- 1670
		self.scavT = self.scavT - 1 -- 1673
		if self.scavT <= 0 then -- 1673
			self.scavState = "back" -- 1675
		end -- 1675
		return -- 1677
	end -- 1677
	if self.scavState == "back" then -- 1677
		local home = math.max( -- 1680
			s.x0, -- 1680
			math.min(s.x1, self.scavX) -- 1680
		) -- 1680
		if math.abs(home - self.scavX) < 2 then -- 1680
			self.scavState = "patrol" -- 1682
			return -- 1683
		end -- 1683
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 1685
		return -- 1686
	end -- 1686
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 1688
	if self.scavX >= s.x1 then -- 1688
		self.scavX = s.x1 -- 1690
		self.scavDir = -1 -- 1691
	elseif self.scavX <= s.x0 then -- 1691
		self.scavX = s.x0 -- 1693
		self.scavDir = 1 -- 1694
	end -- 1694
end -- 1650
function Play.prototype.stepCart(self, dt, input) -- 1702
	local p = self.player -- 1703
	local c = self.room.cart -- 1704
	if self.gripping then -- 1704
		if not input.interact.held then -- 1704
			self.gripping = false -- 1708
			self:flashSet("松开车把", 0.4) -- 1709
			return -- 1710
		end -- 1710
	else -- 1710
		if not input.interact.pressed then -- 1710
			return -- 1714
		end -- 1714
		if not self:cartHandleInReach(p) then -- 1714
			return -- 1717
		end -- 1717
		local track = c.depth or 0 -- 1719
		if self:limitDepth(p, track) ~= track then -- 1719
			return -- 1721
		end -- 1721
		p.depth = track -- 1723
		p.depthSpeed = 0 -- 1724
		self.gripping = true -- 1725
		self:flashSet("握住车把", 0.4) -- 1726
		return -- 1727
	end -- 1727
	if self.cartDocked then -- 1727
		return -- 1731
	end -- 1731
	local dir = input.moveX -- 1733
	if dir == 0 then -- 1733
		return -- 1735
	end -- 1735
	local lo = math.min(c.startX, c.endX) -- 1737
	local hi = math.max(c.startX, c.endX) -- 1738
	local next = self.cartAxle + dir * CART_SPEED * dt -- 1739
	if next < lo then -- 1739
		next = lo -- 1741
	end -- 1741
	if next > hi then -- 1741
		next = hi -- 1744
	end -- 1744
	local delta = next - self.cartAxle -- 1746
	if delta == 0 then -- 1746
		return -- 1748
	end -- 1748
	self.cartAxle = next -- 1750
	p.x = p.x + delta -- 1751
	p.facing = dir > 0 and 1 or -1 -- 1752
	self:slideX(p, 0) -- 1753
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 1753
		self.gripping = false -- 1755
		self:flashSet("跟不上了，脱手", 0.6) -- 1756
		return -- 1757
	end -- 1757
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 1757
		self.cartDocked = true -- 1760
		self.gripping = false -- 1761
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 1762
		self:flashSet("车轮落窝", 1.2) -- 1763
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 1763
		self:flashSet("车轮回到起点", 0.5) -- 1765
	end -- 1765
end -- 1702
function Play.prototype.requestRoom(self, key, reason) -- 1773
	if self.wantRoom ~= "" then -- 1773
		return -- 1777
	end -- 1777
	self.wantRoom = key -- 1779
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 1780
end -- 1773
function Play.prototype.checkCarryGate(self) -- 1787
	if self.room.key == "checkpoint" then -- 1787
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 1787
			self.carryCartAxle = self.cartAxle -- 1790
			self.carryCartDocked = self.cartDocked -- 1791
			self:requestRoom("gate", "检查站出口") -- 1792
			self:flashSet("出检查站 · 城门", 1.2) -- 1793
		end -- 1793
		return -- 1795
	end -- 1795
	if self.room.key == "outside" then -- 1795
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 1795
			self.carryCartAxle = self.cartAxle -- 1801
			self.carryCartDocked = self.cartDocked -- 1802
			self:requestRoom("village", "墙根走完") -- 1803
			self:flashSet("墙根走完 · 进村口", 1.2) -- 1804
		end -- 1804
	end -- 1804
end -- 1787
function Play.prototype.aimAt(self, wx, wy) -- 1811
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 1812
	self.aimX = s.x -- 1813
	self.aimY = s.y -- 1814
end -- 1811
function Play.prototype.shoot(self, a) -- 1817
	local ox = a.x + a.facing * 8 -- 1818
	local muzzleY = a.y + a.h * 0.72 -- 1819
	local oy = muzzleY + a.depth -- 1820
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1822
	local dx = aim.x - ox -- 1825
	local dy = aim.y - oy -- 1826
	local len = math.sqrt(dx * dx + dy * dy) -- 1827
	if len < 0.001 then -- 1827
		dx = a.facing -- 1829
		dy = 0 -- 1830
	else -- 1830
		dx = dx / len -- 1832
		dy = dy / len -- 1833
	end -- 1833
	if dx ~= 0 then -- 1833
		a.facing = dx > 0 and 1 or -1 -- 1836
	end -- 1836
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 1839
	local hitEnemy = self:raycastEnemies(ray) -- 1840
	local tEnemy = hitEnemy.t -- 1841
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 1842
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 1843
	local tWall = self:raycastWorld(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 1844
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 1845
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 1846
	self.trace = { -- 1848
		x0 = ox, -- 1848
		y0 = oy, -- 1848
		x1 = ox + dx * t, -- 1848
		y1 = oy + dy * t, -- 1848
		hit = hit -- 1848
	} -- 1848
	self.traceT = 0.12 -- 1849
	self:applyFireDanger(ox) -- 1850
	if hit then -- 1850
		local i = hitEnemy.index -- 1852
		local e = self.enemies[i + 1] -- 1853
		e.alive = false -- 1854
		e.hitT = 0.4 -- 1855
		self:flashSet("命中", 0.6) -- 1856
	else -- 1856
		self:flashSet("打空", 0.35) -- 1858
	end -- 1858
	self:emit("shotResolved", { -- 1860
		hit = hit, -- 1861
		enemyIndex = hit and hitEnemy.index or -1, -- 1862
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 1863
		aimX = aim.x, -- 1864
		aimY = aim.y, -- 1865
		impactX = ox + dx * t, -- 1866
		impactY = oy + dy * t -- 1867
	}) -- 1867
end -- 1817
function Play.prototype.applyFireDanger(self, shotX) -- 1872
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 1872
		return -- 1874
	end -- 1874
	local dangerX = shotX -- 1876
	local best = -1 -- 1877
	local bestD = 1000000000 -- 1878
	local i = 0 -- 1879
	do -- 1879
		i = 0 -- 1880
		while i < #self.enemies do -- 1880
			do -- 1880
				local e = self.enemies[i + 1] -- 1881
				if not e.alive then -- 1881
					goto __continue304 -- 1883
				end -- 1883
				local d = math.abs(e.x - self.partner.x) -- 1885
				if d < bestD then -- 1885
					bestD = d -- 1887
					best = i -- 1888
				end -- 1888
			end -- 1888
			::__continue304:: -- 1888
			i = i + 1 -- 1880
		end -- 1880
	end -- 1880
	if best >= 0 then -- 1880
		dangerX = self.enemies[best + 1].x -- 1892
	end -- 1892
	local exposed = self:childExposed(dangerX) -- 1894
	local before = self.escort.fear -- 1895
	local dangerId = self.nextDangerId -- 1896
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 1897
	self.nextDangerId = self.nextDangerId + 1 -- 1898
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 1899
	if after > before then -- 1899
		self:flashSet( -- 1901
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 1901
			1 -- 1901
		) -- 1901
	elseif not exposed then -- 1901
		self:flashSet("枪声没够到她", 0.5) -- 1903
	end -- 1903
end -- 1872
function Play.prototype.childExposed(self, dangerX) -- 1908
	local c = self.partner -- 1909
	if not c.alive then -- 1909
		return false -- 1911
	end -- 1911
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 1911
		self.boxes, -- 1914
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 1914
	) then -- 1914
		return false -- 1915
	end -- 1915
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 1915
		return false -- 1918
	end -- 1918
	local toDanger = dangerX - c.x -- 1920
	local toPlayer = self.player.x - c.x -- 1921
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 1921
		return false -- 1924
	end -- 1924
	return true -- 1926
end -- 1908
function Play.prototype.raycastEnemies(self, ray) -- 1930
	local best = -1 -- 1931
	local bestI = -1 -- 1932
	do -- 1932
		local i = 0 -- 1933
		while i < #self.enemies do -- 1933
			do -- 1933
				local e = self.enemies[i + 1] -- 1934
				if not e.alive then -- 1934
					goto __continue318 -- 1936
				end -- 1936
				local y = e.y + (e.depth or 0) -- 1938
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 1939
				if t >= 0 and (best < 0 or t < best) then -- 1939
					best = t -- 1941
					bestI = i -- 1942
				end -- 1942
			end -- 1942
			::__continue318:: -- 1942
			i = i + 1 -- 1933
		end -- 1933
	end -- 1933
	return {t = best, index = bestI} -- 1945
end -- 1930
function Play.prototype.raycastWorld(self, ray) -- 1948
	local best = -1 -- 1949
	for ____, box in ipairs(self.boxes) do -- 1950
		local t = hitBox(ray, box) -- 1951
		if t >= 0 and (best < 0 or t < best) then -- 1951
			best = t -- 1953
		end -- 1953
	end -- 1953
	if ray.dy < 0 then -- 1953
		local t = -ray.y / ray.dy -- 1957
		if t >= 0 and (best < 0 or t < best) then -- 1957
			best = t -- 1959
		end -- 1959
	end -- 1959
	return best -- 1962
end -- 1948
function Play.prototype.slideDepth(self, a, distance) -- 1966
	a.depth = self:limitDepth(a, a.depth + distance) -- 1967
end -- 1966
function Play.prototype.limitDepth(self, a, target) -- 1970
	local road = self.room.depth -- 1971
	if road == nil or target == a.depth then -- 1971
		return a.depth -- 1973
	end -- 1973
	local next = math.max( -- 1975
		road.min, -- 1975
		math.min(road.max, target) -- 1975
	) -- 1975
	local half = a.w / 2 -- 1976
	for ____, b in ipairs(self.boxes) do -- 1977
		do -- 1977
			local footprint = b.depth -- 1978
			if footprint == nil or b.passable == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1978
				goto __continue330 -- 1982
			end -- 1982
			local front = footprint.min - ACTOR_DEPTH_HALF -- 1984
			local back = footprint.max + ACTOR_DEPTH_HALF -- 1985
			if a.depth <= front and next > front then -- 1985
				next = front -- 1987
			elseif a.depth >= back and next < back then -- 1987
				next = back -- 1989
			end -- 1989
		end -- 1989
		::__continue330:: -- 1989
	end -- 1989
	return next -- 1992
end -- 1970
function Play.prototype.slideX(self, a, dx) -- 1996
	local nx = a.x + dx -- 1997
	local half = a.w / 2 -- 1998
	local room = self.room -- 1999
	nx = math.max( -- 2000
		room.minX + half, -- 2000
		math.min(room.maxX - half, nx) -- 2000
	) -- 2000
	local i = 0 -- 2001
	do -- 2001
		i = 0 -- 2002
		while i < #self.boxes do -- 2002
			do -- 2002
				local b = self.boxes[i + 1] -- 2003
				if b.passable == true or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2003
					goto __continue337 -- 2005
				end -- 2005
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 2005
					goto __continue337 -- 2008
				end -- 2008
				if nx + half > b.x0 and nx - half < b.x1 then -- 2008
					if a.x <= b.x0 then -- 2008
						nx = b.x0 - half -- 2012
					elseif a.x >= b.x1 then -- 2012
						nx = b.x1 + half -- 2014
					else -- 2014
						nx = a.x -- 2016
					end -- 2016
				end -- 2016
			end -- 2016
			::__continue337:: -- 2016
			i = i + 1 -- 2002
		end -- 2002
	end -- 2002
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 2002
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 2024
		local bx0 = self.cartAxle - CART_HALF -- 2025
		local bx1 = self.cartAxle + CART_HALF -- 2026
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 2026
			if a.x <= bx0 then -- 2026
				nx = bx0 - half -- 2029
			elseif a.x >= bx1 then -- 2029
				nx = bx1 + half -- 2031
			else -- 2031
				nx = a.x -- 2033
			end -- 2033
		end -- 2033
	end -- 2033
	local arch = room.arch -- 2041
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 2041
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 2043
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 2043
			if a.x <= arch.x0 then -- 2043
				nx = arch.x0 - half -- 2046
			elseif a.x >= arch.x1 then -- 2046
				nx = arch.x1 + half -- 2048
			end -- 2048
		end -- 2048
	end -- 2048
	a.x = nx -- 2052
end -- 1996
function Play.prototype.fallY(self, a, dt) -- 2056
	a.vy = a.vy - ____exports.GRAVITY * dt -- 2057
	if a.vy < -900 then -- 2057
		a.vy = -900 -- 2059
	end -- 2059
	local ny = a.y + a.vy * dt -- 2061
	local half = a.w / 2 -- 2062
	if a.vy <= 0 then -- 2062
		local reach = a.onGround and STEP_UP or 0 -- 2065
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 2066
		if ny <= ground then -- 2066
			ny = ground -- 2068
			a.vy = 0 -- 2069
			a.onGround = true -- 2070
		else -- 2070
			a.onGround = false -- 2072
		end -- 2072
	else -- 2072
		a.onGround = false -- 2075
		local i = 0 -- 2076
		do -- 2076
			i = 0 -- 2077
			while i < #self.boxes do -- 2077
				do -- 2077
					local b = self.boxes[i + 1] -- 2078
					if b.passable == true or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2078
						goto __continue360 -- 2080
					end -- 2080
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 2080
						goto __continue360 -- 2083
					end -- 2083
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 2083
						ny = b.y0 - a.h -- 2086
						a.vy = 0 -- 2087
					end -- 2087
				end -- 2087
				::__continue360:: -- 2087
				i = i + 1 -- 2077
			end -- 2077
		end -- 2077
	end -- 2077
	a.y = ny -- 2091
end -- 2056
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 2095
	if depth == nil then -- 2095
		depth = 0 -- 2095
	end -- 2095
	local g = -9999 -- 2096
	local i = 0 -- 2097
	do -- 2097
		i = 0 -- 2098
		while i < #self.floors do -- 2098
			local f = self.floors[i + 1] -- 2099
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 2099
				g = f.y1 -- 2101
			end -- 2101
			i = i + 1 -- 2098
		end -- 2098
	end -- 2098
	do -- 2098
		i = 0 -- 2104
		while i < #self.boxes do -- 2104
			local b = self.boxes[i + 1] -- 2105
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 2105
				g = b.y1 -- 2108
			end -- 2108
			i = i + 1 -- 2104
		end -- 2104
	end -- 2104
	return g -- 2111
end -- 2095
function Play.prototype.updateCamera(self, dt) -- 2114
	local p = self.player -- 2115
	local tx = p.x + p.facing * 30 -- 2116
	local ty = p.y + CAM_LOOK_UP -- 2117
	local k = math.min(1, CAM_FOLLOW * dt) -- 2118
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 2119
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 2120
end -- 2114
function Play.prototype.clampCamera(self, w, h) -- 2124
	local room = self.room -- 2125
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 2126
	local spanX = room.maxX - room.minX -- 2127
	if spanX <= halfW * 2 then -- 2127
		self.cam.x = (room.minX + room.maxX) / 2 -- 2129
	else -- 2129
		self.cam.x = math.max( -- 2131
			room.minX + halfW, -- 2131
			math.min(room.maxX - halfW, self.cam.x) -- 2131
		) -- 2131
	end -- 2131
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 2134
	local spanY = room.height -- 2135
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 2136
	if spanY <= halfH * 2 then -- 2136
		self.cam.y = camY -- 2138
	else -- 2138
		self.cam.y = math.max( -- 2140
			camY, -- 2140
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 2140
		) -- 2140
	end -- 2140
end -- 2124
function Play.prototype.flashSet(self, text, t) -- 2144
	self.flash = text -- 2145
	self.flashT = t -- 2146
end -- 2144
function Play.prototype.statusText(self) -- 2150
	local p = self.player -- 2151
	local parts = {} -- 2152
	local who = self.childMode and "小满" or "周戍" -- 2153
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 2154
	if self.room.key == "prologue" then -- 2154
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2157
		if self.phase == "prologue-wait" then -- 2157
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 2159
		elseif self.phase == "prologue-give" then -- 2159
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 2161
		else -- 2161
			parts[#parts + 1] = "跟随" -- 2163
		end -- 2163
		if self.paused then -- 2163
			parts[#parts + 1] = "已暂停" -- 2166
		end -- 2166
		return table.concat(parts, " · ") -- 2168
	end -- 2168
	if self.room.key == "street" then -- 2168
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2171
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2172
		if self.paused then -- 2172
			parts[#parts + 1] = "已暂停" -- 2174
		end -- 2174
		return table.concat(parts, " · ") -- 2176
	end -- 2176
	if self.room.key == "gate" then -- 2176
		local ____temp_19 -- 2179
		if self.room.story == nil then -- 2179
			____temp_19 = nil -- 2179
		else -- 2179
			____temp_19 = self.room.story.gate -- 2179
		end -- 2179
		local g = ____temp_19 -- 2179
		if g ~= nil then -- 2179
			parts[#parts + 1] = self:gateLabel() -- 2181
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 2182
				0, -- 2183
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 2183
			))) .. " 秒" -- 2183
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2184
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2185
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 2186
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 2187
			if self.gateFailCount > 0 then -- 2187
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 2189
			end -- 2189
			if self.flash ~= "" then -- 2189
				parts[#parts + 1] = self.flash -- 2192
			end -- 2192
		end -- 2192
		if self.paused then -- 2192
			parts[#parts + 1] = "已暂停" -- 2196
		end -- 2196
		return table.concat(parts, " · ") -- 2198
	end -- 2198
	if self.room.key == "forest" then -- 2198
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2201
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 2202
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 2203
		if self.caughtT > 0 then -- 2203
			parts[#parts + 1] = "复位中" -- 2205
		end -- 2205
		if self.paused then -- 2205
			parts[#parts + 1] = "已暂停" -- 2208
		end -- 2208
		return table.concat(parts, " · ") -- 2210
	end -- 2210
	if self.room.key == "tower" then -- 2210
		if self.phase == "tower-wait" then -- 2210
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 2214
		elseif self.phase == "tower-knock" then -- 2214
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 2216
		elseif self.phase == "tower-given" then -- 2216
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 2218
		else -- 2218
			parts[#parts + 1] = "片尾" -- 2220
		end -- 2220
		if self.paused then -- 2220
			parts[#parts + 1] = "已暂停" -- 2223
		end -- 2223
		return table.concat(parts, " · ") -- 2225
	end -- 2225
	if self.room.key == "village" then -- 2225
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2228
		if self.hasBottle then -- 2228
			parts[#parts + 1] = "有瓶" -- 2230
		elseif self.bottleFly ~= nil then -- 2230
			parts[#parts + 1] = "瓶在飞" -- 2232
		else -- 2232
			parts[#parts + 1] = "空手" -- 2234
		end -- 2234
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 2236
		if self.scavChase then -- 2236
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 2238
		end -- 2238
		if self.passed then -- 2238
			parts[#parts + 1] = "已过通行线" -- 2241
		end -- 2241
		if self.paused then -- 2241
			parts[#parts + 1] = "已暂停" -- 2244
		end -- 2244
		return table.concat(parts, " · ") -- 2246
	end -- 2246
	local isChild = self.childMode -- 2249
	if isChild then -- 2249
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2251
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 2252
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2253
	else -- 2253
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 2255
		if p.rollT > 0 then -- 2255
			parts[#parts + 1] = "翻滚中" -- 2257
		end -- 2257
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2259
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2260
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 2261
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 2262
	end -- 2262
	if self.checkpoint >= 0 then -- 2262
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 2265
	end -- 2265
	if self.paused then -- 2265
		parts[#parts + 1] = "已暂停" -- 2268
	end -- 2268
	return table.concat(parts, " · ") -- 2270
end -- 2150
function Play.prototype.aliveEnemies(self) -- 2274
	local n = 0 -- 2275
	local i = 0 -- 2276
	do -- 2276
		i = 0 -- 2277
		while i < #self.enemies do -- 2277
			if self.enemies[i + 1].alive then -- 2277
				n = n + 1 -- 2279
			end -- 2279
			i = i + 1 -- 2277
		end -- 2277
	end -- 2277
	return n -- 2282
end -- 2274
function Play.prototype.threatened(self) -- 2287
	do -- 2287
		local i = 0 -- 2288
		while i < #self.enemies do -- 2288
			local e = self.enemies[i + 1] -- 2289
			if e.alive and e.warnT > 0 then -- 2289
				return true -- 2291
			end -- 2291
			i = i + 1 -- 2288
		end -- 2288
	end -- 2288
	return false -- 2294
end -- 2287
function Play.prototype.gateSecondsLeft(self) -- 2297
	local ____temp_20 -- 2298
	if self.room.story == nil then -- 2298
		____temp_20 = nil -- 2298
	else -- 2298
		____temp_20 = self.room.story.gate -- 2298
	end -- 2298
	local g = ____temp_20 -- 2298
	if g == nil then -- 2298
		return 0 -- 2300
	end -- 2300
	return math.max( -- 2302
		0, -- 2302
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 2302
	) -- 2302
end -- 2297
function Play.prototype.gateLabel(self) -- 2305
	if self.phase == "gate-idle" then -- 2305
		return "待就位" -- 2307
	end -- 2307
	if self.phase == "gate-hold" then -- 2307
		return "守点中" -- 2310
	end -- 2310
	if self.phase == "gate-send" then -- 2310
		return "送别" -- 2313
	end -- 2313
	if self.phase == "gate-count" then -- 2313
		return "数数 " .. tostring(self.countTick) -- 2316
	end -- 2316
	return "她走" -- 2318
end -- 2305
function Play.prototype.dogLabel(self) -- 2322
	if self.dogState == "ear" then -- 2322
		return "转耳" -- 2324
	end -- 2324
	if self.dogState == "chase" then -- 2324
		return "追" -- 2327
	end -- 2327
	if self.dogState == "sniff" then -- 2327
		return "停" -- 2330
	end -- 2330
	if self.dogState == "back" then -- 2330
		return "回线" -- 2333
	end -- 2333
	return "巡逻" -- 2335
end -- 2322
function Play.prototype.doorXOf(self) -- 2338
	local ____temp_21 -- 2339
	if self.room.story == nil then -- 2339
		____temp_21 = nil -- 2339
	else -- 2339
		____temp_21 = self.room.story.tower -- 2339
	end -- 2339
	local t = ____temp_21 -- 2339
	return t == nil and 0 or t.doorX -- 2340
end -- 2338
function Play.prototype.scavLabel(self) -- 2344
	if self.scavState == "chase" then -- 2344
		return "追" -- 2346
	end -- 2346
	if self.scavState == "turn" then -- 2346
		return "转头" -- 2349
	end -- 2349
	if self.scavState == "walk" then -- 2349
		return "赶来" -- 2352
	end -- 2352
	if self.scavState == "stall" then -- 2352
		return "停住" -- 2355
	end -- 2355
	if self.scavState == "back" then -- 2355
		return "回位" -- 2358
	end -- 2358
	return "巡逻" -- 2360
end -- 2344
function Play.prototype.hintText(self) -- 2364
	if self.paused then -- 2364
		return "Esc 继续 · R 重置" -- 2366
	end -- 2366
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 2366
		if self:threatened() then -- 2366
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 2372
		end -- 2372
		if self.coverHug then -- 2372
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 2375
		end -- 2375
		if self.coverNear then -- 2375
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 2378
		end -- 2378
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 2380
	end -- 2380
	if self.flash ~= "" then -- 2380
		return self.flash -- 2383
	end -- 2383
	if self.room.key == "prologue" then -- 2383
		if self.phase == "prologue-wait" then -- 2383
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 2387
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 2388
		end -- 2388
		if self.phase == "prologue-give" then -- 2388
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 2391
		end -- 2391
		return "她跟着你了 · 两人一起走到门口 680" -- 2393
	end -- 2393
	if self.room.key == "street" then -- 2393
		if self:aliveEnemies() > 0 then -- 2393
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 2397
		end -- 2397
		return "清完了 · 两人一起走到右边检查站入口 900" -- 2399
	end -- 2399
	if self.room.key == "gate" then -- 2399
		local ____temp_22 -- 2402
		if self.room.story == nil then -- 2402
			____temp_22 = nil -- 2402
		else -- 2402
			____temp_22 = self.room.story.gate -- 2402
		end -- 2402
		local g = ____temp_22 -- 2402
		if g ~= nil then -- 2402
			if self.phase == "gate-idle" then -- 2402
				if self.gateNeedConfirm then -- 2402
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 2406
				end -- 2406
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 2408
			end -- 2408
			if self.phase == "gate-hold" then -- 2408
				if self.coveredFlash > 0 then -- 2408
					return "掩体挡下了这一枪 · 别露头" -- 2412
				end -- 2412
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 2414
			end -- 2414
			if self.phase == "gate-send" then -- 2414
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 2417
			end -- 2417
			if self.phase == "gate-count" then -- 2417
				if self.countTick >= 1440 then -- 2417
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 2421
				end -- 2421
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 2423
			end -- 2423
			return "她自己走 · 跟着出城门 1120" -- 2425
		end -- 2425
	end -- 2425
	if self.room.key == "forest" then -- 2425
		if self.dogState == "chase" then -- 2425
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 2430
		end -- 2430
		if self.dogState == "ear" then -- 2430
			return "狗转耳朵了 · 停下或蹲下别出声" -- 2433
		end -- 2433
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 2435
	end -- 2435
	if self.room.key == "tower" then -- 2435
		if self.phase == "tower-wait" then -- 2435
			return "走到门前 445 点一次 E 敲两下" -- 2439
		end -- 2439
		if self.phase == "tower-knock" then -- 2439
			return "敲两下 · 等门开" -- 2442
		end -- 2442
		if self.phase == "tower-given" then -- 2442
			return "递交针套和纸条 · 看登记簿最后一行" -- 2445
		end -- 2445
		return "片尾 · 点 E 再玩一次，回到序章" -- 2447
	end -- 2447
	if self.room.key == "village" then -- 2447
		if self.bottleFly ~= nil then -- 2447
			return "等瓶子落地 · 触地才发声" -- 2451
		end -- 2451
		if self.hasBottle then -- 2451
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 2454
		end -- 2454
		if self.passed then -- 2454
			return "已过第一院 · R 重置可再来一遍" -- 2457
		end -- 2457
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 2459
	end -- 2459
	if self.room.key == "outside" then -- 2459
		if self.focusCart then -- 2459
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 2463
		end -- 2463
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 2465
	end -- 2465
	if self.escort.state == "frozen" then -- 2465
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 2465
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 2469
		end -- 2469
		return "小满吓住了 · 走过去，靠近再点 E" -- 2471
	end -- 2471
	if self.escort.state == "calming" then -- 2471
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 2474
	end -- 2474
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 2476
end -- 2364
function Play.prototype.draw(self, draw, w, h) -- 2481
	self.viewW = w -- 2482
	self.viewH = h -- 2483
	self.view = ____exports.computeViewport(w, h) -- 2484
	self:clampCamera(w, h) -- 2485
	draw:clear() -- 2486
	draw:drawRect( -- 2488
		Rect(0, 0, w, h), -- 2488
		BG_VOID -- 2488
	) -- 2488
	local box = self:canvasRect(w, h) -- 2489
	draw:drawRect(box, BG_FAR) -- 2490
	draw:drawRect( -- 2491
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 2491
		BG_MID -- 2491
	) -- 2491
	self:drawFloors(draw, w, h) -- 2493
	self:drawSolids(draw, w, h) -- 2494
	self:drawZones(draw, w, h) -- 2495
	self:drawArch(draw, w, h) -- 2496
	self:drawCart(draw, w, h) -- 2497
	self:drawActors(draw, w, h) -- 2498
	self:drawTrace(draw, w, h) -- 2499
	self:drawAim(draw, w, h) -- 2500
end -- 2481
function Play.prototype.canvasRect(self, w, h) -- 2504
	local v = self.view -- 2505
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 2506
end -- 2504
function Play.prototype.px(self, n) -- 2510
	return n * self.view.zoom -- 2511
end -- 2510
function Play.prototype.sx(self, wx, w) -- 2515
	local v = self.view -- 2516
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 2517
	return v.ox + lx * v.zoom -- 2518
end -- 2515
function Play.prototype.sy(self, wy, h) -- 2522
	local v = self.view -- 2523
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 2524
	return v.oy + ly * v.zoom -- 2525
end -- 2522
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 2528
	local px0 = self:sx(x0, w) -- 2529
	local px1 = self:sx(x1, w) -- 2530
	local py0 = self:sy(y0, h) -- 2531
	local py1 = self:sy(y1, h) -- 2532
	if px1 <= px0 or py1 <= py0 then -- 2532
		return -- 2534
	end -- 2534
	draw:drawRect( -- 2536
		Rect(px0, py0, px1 - px0, py1 - py0), -- 2536
		color -- 2536
	) -- 2536
end -- 2528
function Play.prototype.drawFloors(self, draw, w, h) -- 2539
	local i = 0 -- 2540
	do -- 2540
		i = 0 -- 2541
		while i < #self.room.floors do -- 2541
			local f = self.room.floors[i + 1] -- 2542
			local ____temp_23 -- 2543
			if f.y == 0 then -- 2543
				____temp_23 = self.room.depth -- 2543
			else -- 2543
				____temp_23 = nil -- 2543
			end -- 2543
			local road = ____temp_23 -- 2543
			local y = self:sy(f.y + (road and road.min or 0), h) -- 2544
			local x0 = self:sx(f.x0, w) -- 2545
			local x1 = self:sx(f.x1, w) -- 2546
			local deck = self:px(5) -- 2547
			if road ~= nil then -- 2547
				local back = self:sy(f.y + road.max, h) -- 2549
				draw:drawRect( -- 2550
					Rect(x0, y, x1 - x0, back - y), -- 2550
					FLOOR_DECK, -- 2550
					self:px(1), -- 2550
					SOLID_EDGE -- 2550
				) -- 2550
			end -- 2550
			draw:drawRect( -- 2552
				Rect(x0, y - deck, x1 - x0, deck), -- 2552
				FLOOR_DECK -- 2552
			) -- 2552
			draw:drawSegment( -- 2553
				Vec2(x0, y), -- 2553
				Vec2(x1, y), -- 2553
				self:px(1), -- 2553
				GROUND -- 2553
			) -- 2553
			i = i + 1 -- 2541
		end -- 2541
	end -- 2541
end -- 2539
function Play.prototype.drawSolids(self, draw, w, h) -- 2557
	local i = 0 -- 2558
	do -- 2558
		i = 0 -- 2559
		while i < #self.boxes do -- 2559
			do -- 2559
				local b = self.boxes[i + 1] -- 2560
				if b.y0 < -4 and b.y1 <= 96 then -- 2560
					draw:drawSegment( -- 2563
						Vec2( -- 2563
							self:sx(b.x0, w), -- 2563
							self:sy(b.y1, h) -- 2563
						), -- 2563
						Vec2( -- 2563
							self:sx(b.x1, w), -- 2563
							self:sy(b.y1, h) -- 2563
						), -- 2563
						self:px(1), -- 2563
						GROUND -- 2563
					) -- 2563
					goto __continue489 -- 2564
				end -- 2564
				local ____opt_26 = b.depth -- 2564
				local front = ____opt_26 and ____opt_26.min or 0 -- 2566
				local ____opt_28 = b.depth -- 2566
				local back = ____opt_28 and ____opt_28.max or 0 -- 2567
				self:drawBox( -- 2568
					draw, -- 2568
					w, -- 2568
					h, -- 2568
					b.x0, -- 2568
					b.x1, -- 2568
					b.y0 + front, -- 2568
					b.y1 + back, -- 2568
					SOLID_FILL -- 2568
				) -- 2568
				draw:drawSegment( -- 2569
					Vec2( -- 2569
						self:sx(b.x0, w), -- 2569
						self:sy(b.y1 + front, h) -- 2569
					), -- 2569
					Vec2( -- 2570
						self:sx(b.x1, w), -- 2570
						self:sy(b.y1 + front, h) -- 2570
					), -- 2570
					self:px(1), -- 2570
					SOLID_EDGE -- 2570
				) -- 2570
			end -- 2570
			::__continue489:: -- 2570
			i = i + 1 -- 2559
		end -- 2559
	end -- 2559
end -- 2557
function Play.prototype.drawZones(self, draw, w, h) -- 2574
	local i = 0 -- 2575
	do -- 2575
		i = 0 -- 2576
		while i < #self.room.zones do -- 2576
			local z = self.room.zones[i + 1] -- 2577
			local fill = DANGER -- 2578
			local line = DANGER_LINE -- 2579
			if z.tint == 2 then -- 2579
				fill = SOFT -- 2581
				line = SOFT_LINE -- 2582
			elseif z.tint == 3 then -- 2582
				fill = BRICK -- 2584
				line = BRICK_LINE -- 2585
			elseif z.tint == 4 then -- 2585
				fill = PASS -- 2587
				line = PASS_LINE -- 2588
			end -- 2588
			self:drawBox( -- 2590
				draw, -- 2590
				w, -- 2590
				h, -- 2590
				z.x0, -- 2590
				z.x1, -- 2590
				z.y, -- 2590
				z.y + z.h, -- 2590
				fill -- 2590
			) -- 2590
			draw:drawSegment( -- 2591
				Vec2( -- 2591
					self:sx(z.x0, w), -- 2591
					self:sy(z.y, h) -- 2591
				), -- 2591
				Vec2( -- 2591
					self:sx(z.x0, w), -- 2591
					self:sy(z.y + z.h, h) -- 2591
				), -- 2591
				self:px(1), -- 2591
				line -- 2591
			) -- 2591
			draw:drawSegment( -- 2592
				Vec2( -- 2592
					self:sx(z.x1, w), -- 2592
					self:sy(z.y, h) -- 2592
				), -- 2592
				Vec2( -- 2592
					self:sx(z.x1, w), -- 2592
					self:sy(z.y + z.h, h) -- 2592
				), -- 2592
				self:px(1), -- 2592
				line -- 2592
			) -- 2592
			i = i + 1 -- 2576
		end -- 2576
	end -- 2576
end -- 2574
function Play.prototype.drawArch(self, draw, w, h) -- 2596
	local a = self.room.arch -- 2597
	if a.h <= 0 then -- 2597
		return -- 2599
	end -- 2599
	self:drawBox( -- 2601
		draw, -- 2601
		w, -- 2601
		h, -- 2601
		a.x0, -- 2601
		a.x1, -- 2601
		a.y, -- 2601
		a.y + a.h, -- 2601
		HOLE_FILL -- 2601
	) -- 2601
	draw:drawSegment( -- 2602
		Vec2( -- 2602
			self:sx(a.x0, w), -- 2602
			self:sy(a.y + a.h, h) -- 2602
		), -- 2602
		Vec2( -- 2602
			self:sx(a.x1, w), -- 2602
			self:sy(a.y + a.h, h) -- 2602
		), -- 2602
		self:px(1), -- 2602
		SOLID_EDGE -- 2602
	) -- 2602
	draw:drawSegment( -- 2603
		Vec2( -- 2603
			self:sx(a.x0, w), -- 2603
			self:sy(a.y, h) -- 2603
		), -- 2603
		Vec2( -- 2603
			self:sx(a.x0, w), -- 2603
			self:sy(a.y + a.h, h) -- 2603
		), -- 2603
		self:px(1), -- 2603
		SOLID_EDGE -- 2603
	) -- 2603
	draw:drawSegment( -- 2604
		Vec2( -- 2604
			self:sx(a.x1, w), -- 2604
			self:sy(a.y, h) -- 2604
		), -- 2604
		Vec2( -- 2604
			self:sx(a.x1, w), -- 2604
			self:sy(a.y + a.h, h) -- 2604
		), -- 2604
		self:px(1), -- 2604
		SOLID_EDGE -- 2604
	) -- 2604
end -- 2596
function Play.prototype.drawCart(self, draw, w, h) -- 2607
	local c = self.room.cart -- 2608
	if c.bodyW <= 0 then -- 2608
		return -- 2610
	end -- 2610
	drawCartShape( -- 2612
		draw, -- 2612
		self, -- 2612
		w, -- 2612
		h, -- 2612
		c, -- 2612
		self.cartAxle -- 2612
	) -- 2612
	draw:drawRect( -- 2613
		Rect( -- 2613
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 2613
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 2613
			self:px(2), -- 2613
			self:px(40) -- 2613
		), -- 2613
		STAND -- 2613
	) -- 2613
end -- 2607
function Play.prototype.drawActors(self, draw, w, h) -- 2616
	local p = self.player -- 2617
	local isChild = self.childMode -- 2618
	local footY = p.y + p.depth -- 2619
	if p.covered then -- 2619
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 2622
		draw:drawSegment( -- 2623
			Vec2( -- 2623
				self:sx(edge, w), -- 2623
				self:sy(footY + 8, h) -- 2623
			), -- 2623
			Vec2( -- 2623
				self:sx(edge, w), -- 2623
				self:sy(footY + p.h * 0.62, h) -- 2623
			), -- 2623
			self:px(2), -- 2623
			STAND -- 2623
		) -- 2623
		draw:drawSegment( -- 2625
			Vec2( -- 2625
				self:sx(p.x - 8, w), -- 2625
				self:sy(footY + p.h + 3, h) -- 2625
			), -- 2625
			Vec2( -- 2625
				self:sx(p.x + 8, w), -- 2625
				self:sy(footY + p.h + 3, h) -- 2625
			), -- 2625
			self:px(2), -- 2625
			STAND -- 2625
		) -- 2625
	elseif self.coverNear and not isChild then -- 2625
		draw:drawRect( -- 2628
			Rect( -- 2628
				self:sx(p.x - 3, w), -- 2628
				self:sy(footY + 1, h), -- 2628
				self:px(3), -- 2628
				self:px(3) -- 2628
			), -- 2628
			STAND -- 2628
		) -- 2628
	end -- 2628
	drawFigure( -- 2630
		draw, -- 2630
		self, -- 2630
		w, -- 2630
		h, -- 2630
		p, -- 2630
		isChild and CHILD_BODY or SOLDIER_BODY, -- 2630
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 2630
	) -- 2630
	local q = self.partner -- 2631
	if q.alive then -- 2631
		local childPartner = q.w == CHILD_W -- 2633
		drawFigure( -- 2634
			draw, -- 2634
			self, -- 2634
			w, -- 2634
			h, -- 2634
			q, -- 2634
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 2634
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 2634
		) -- 2634
	end -- 2634
	local i = 0 -- 2636
	do -- 2636
		i = 0 -- 2637
		while i < #self.enemies do -- 2637
			local e = self.enemies[i + 1] -- 2638
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 2639
			local enemyY = e.y + (e.depth or 0) -- 2640
			self:drawBox( -- 2641
				draw, -- 2641
				w, -- 2641
				h, -- 2641
				e.x - e.w / 2, -- 2641
				e.x + e.w / 2, -- 2641
				enemyY, -- 2641
				enemyY + e.h, -- 2641
				col -- 2641
			) -- 2641
			if e.alive and e.warnT > 0 then -- 2641
				local gunX = self:sx(e.x, w) -- 2644
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 2645
				local aimX = self:sx(p.x, w) -- 2646
				local aimY = self:sy(footY + p.h * 0.55, h) -- 2647
				local seg = 8 -- 2648
				local s = 0 -- 2649
				do -- 2649
					s = 0 -- 2650
					while s < seg do -- 2650
						local t0 = s / seg -- 2651
						local t1 = (s + 1) / seg -- 2652
						draw:drawSegment( -- 2653
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 2654
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 2655
							self:px(1), -- 2656
							DANGER -- 2656
						) -- 2656
						s = s + 2 -- 2650
					end -- 2650
				end -- 2650
			end -- 2650
			i = i + 1 -- 2637
		end -- 2637
	end -- 2637
	local k = 0 -- 2661
	do -- 2661
		k = 0 -- 2662
		while k < #self.room.marks do -- 2662
			do -- 2662
				local m = self.room.marks[k + 1] -- 2663
				if m.kind ~= 0 then -- 2663
					goto __continue511 -- 2665
				end -- 2665
				local on = self.checkpoint == m.x -- 2667
				local x = self:sx(m.x, w) -- 2668
				local y = self:sy(m.y, h) -- 2669
				draw:drawSegment( -- 2670
					Vec2(x, y), -- 2670
					Vec2( -- 2670
						x, -- 2670
						y + self:px(35) -- 2670
					), -- 2670
					self:px(1), -- 2670
					on and CHECK or INK_DIM -- 2670
				) -- 2670
				draw:drawDot( -- 2671
					Vec2( -- 2671
						x, -- 2671
						y + self:px(35) -- 2671
					), -- 2671
					self:px(2), -- 2671
					on and CHECK or INK_DIM -- 2671
				) -- 2671
			end -- 2671
			::__continue511:: -- 2671
			k = k + 1 -- 2662
		end -- 2662
	end -- 2662
	local j = 0 -- 2675
	do -- 2675
		j = 0 -- 2676
		while j < #self.room.marks do -- 2676
			do -- 2676
				local m = self.room.marks[j + 1] -- 2677
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 2677
					goto __continue514 -- 2679
				end -- 2679
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 2679
					goto __continue514 -- 2683
				end -- 2683
				local col = STAND -- 2685
				if m.kind == 4 then -- 2685
					col = PASS_LINE -- 2687
				elseif m.kind == 5 then -- 2687
					col = BRICK_LINE -- 2689
				end -- 2689
				local mx = self:sx(m.x, w) -- 2691
				local my = self:sy(m.y, h) -- 2692
				draw:drawSegment( -- 2693
					Vec2(mx, my), -- 2693
					Vec2( -- 2693
						mx, -- 2693
						my + self:px(24) -- 2693
					), -- 2693
					self:px(1), -- 2693
					col -- 2693
				) -- 2693
			end -- 2693
			::__continue514:: -- 2693
			j = j + 1 -- 2676
		end -- 2676
	end -- 2676
	local t = 0 -- 2696
	do -- 2696
		t = 0 -- 2697
		while t < #self.room.marks do -- 2697
			do -- 2697
				local m = self.room.marks[t + 1] -- 2698
				if m.kind ~= 6 then -- 2698
					goto __continue520 -- 2700
				end -- 2700
				local mx = self:sx(m.x, w) -- 2702
				local my = self:sy(m.y, h) -- 2703
				draw:drawSegment( -- 2704
					Vec2(mx, my), -- 2704
					Vec2( -- 2704
						mx, -- 2704
						my + self:px(30) -- 2704
					), -- 2704
					self:px(1), -- 2704
					INK_DIM -- 2704
				) -- 2704
				self:drawBox( -- 2705
					draw, -- 2705
					w, -- 2705
					h, -- 2705
					m.x - 5, -- 2705
					m.x + 5, -- 2705
					m.y + 30, -- 2705
					m.y + 40, -- 2705
					CHECK -- 2705
				) -- 2705
			end -- 2705
			::__continue520:: -- 2705
			t = t + 1 -- 2697
		end -- 2697
	end -- 2697
	if self.room.key == "village" then -- 2697
		self:drawVillage(draw, w, h) -- 2708
	end -- 2708
	if self.room.key == "forest" then -- 2708
		self:drawDog(draw, w, h) -- 2711
	end -- 2711
end -- 2616
function Play.prototype.drawDog(self, draw, w, h) -- 2716
	local x = self.dogX -- 2717
	self:drawBox( -- 2718
		draw, -- 2718
		w, -- 2718
		h, -- 2718
		x - 14, -- 2718
		x + 14, -- 2718
		0, -- 2718
		20, -- 2718
		SCAV_BODY -- 2718
	) -- 2718
	self:drawBox( -- 2719
		draw, -- 2719
		w, -- 2719
		h, -- 2719
		x - 10, -- 2719
		x - 2, -- 2719
		20, -- 2719
		30, -- 2719
		SCAV_BODY -- 2719
	) -- 2719
	self:drawBox( -- 2720
		draw, -- 2720
		w, -- 2720
		h, -- 2720
		x + 2, -- 2720
		x + 10, -- 2720
		20, -- 2720
		30, -- 2720
		SCAV_HEAD -- 2720
	) -- 2720
	if self.dogState == "ear" or self.dogState == "chase" then -- 2720
		draw:drawSegment( -- 2722
			Vec2( -- 2722
				self:sx(x, w), -- 2722
				self:sy(30, h) -- 2722
			), -- 2722
			Vec2( -- 2723
				self:sx(x, w), -- 2723
				self:sy(40, h) -- 2723
			), -- 2723
			self:px(1), -- 2723
			DANGER -- 2723
		) -- 2723
	end -- 2723
end -- 2716
function Play.prototype.drawVillage(self, draw, w, h) -- 2728
	local bottle = self.room.bottle -- 2729
	if bottle ~= nil then -- 2729
		self:drawBox( -- 2731
			draw, -- 2731
			w, -- 2731
			h, -- 2731
			bottle.x - 14, -- 2731
			bottle.x + 14, -- 2731
			0, -- 2731
			64, -- 2731
			SOLID_FILL -- 2731
		) -- 2731
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 2731
			self:drawBottle( -- 2733
				draw, -- 2733
				w, -- 2733
				h, -- 2733
				bottle.x, -- 2733
				64 -- 2733
			) -- 2733
		end -- 2733
	end -- 2733
	self:drawBox( -- 2737
		draw, -- 2737
		w, -- 2737
		h, -- 2737
		300, -- 2737
		420, -- 2737
		44, -- 2737
		50, -- 2737
		FLOOR_DECK -- 2737
	) -- 2737
	self:drawBox( -- 2738
		draw, -- 2738
		w, -- 2738
		h, -- 2738
		300, -- 2738
		306, -- 2738
		0, -- 2738
		44, -- 2738
		FLOOR_DECK -- 2738
	) -- 2738
	self:drawBox( -- 2739
		draw, -- 2739
		w, -- 2739
		h, -- 2739
		414, -- 2739
		420, -- 2739
		0, -- 2739
		44, -- 2739
		FLOOR_DECK -- 2739
	) -- 2739
	local s = self.room.scavenger -- 2741
	if s ~= nil then -- 2741
		local sx0 = self.scavX -- 2743
		self:drawBox( -- 2744
			draw, -- 2744
			w, -- 2744
			h, -- 2744
			sx0 - 12, -- 2744
			sx0 + 12, -- 2744
			0, -- 2744
			s.h - 14, -- 2744
			SCAV_BODY -- 2744
		) -- 2744
		self:drawBox( -- 2745
			draw, -- 2745
			w, -- 2745
			h, -- 2745
			sx0 - 7, -- 2745
			sx0 + 7, -- 2745
			s.h - 14, -- 2745
			s.h, -- 2745
			SCAV_HEAD -- 2745
		) -- 2745
		if self.scavState == "turn" then -- 2745
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 2747
			draw:drawSegment( -- 2748
				Vec2( -- 2748
					self:sx(sx0, w), -- 2748
					self:sy(s.h - 6, h) -- 2748
				), -- 2748
				Vec2( -- 2748
					self:sx(fx, w), -- 2748
					self:sy(s.h - 6, h) -- 2748
				), -- 2748
				self:px(1), -- 2748
				INK -- 2748
			) -- 2748
		end -- 2748
	end -- 2748
	if self.hasBottle then -- 2748
		local p = self.player -- 2753
		self:drawBottle( -- 2754
			draw, -- 2754
			w, -- 2754
			h, -- 2754
			p.x + p.facing * 10, -- 2754
			p.y + p.h * 0.62 -- 2754
		) -- 2754
	end -- 2754
	if self.bottleFly ~= nil then -- 2754
		self:drawBottle( -- 2757
			draw, -- 2757
			w, -- 2757
			h, -- 2757
			self.bottleFly.x, -- 2757
			self.bottleFly.y -- 2757
		) -- 2757
	end -- 2757
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 2757
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 2760
		draw:drawCircle( -- 2761
			Vec2( -- 2761
				self:sx(self.bottleLandX, w), -- 2761
				self:sy(0, h) -- 2761
			), -- 2761
			self:px(r / ____exports.UNITS_PER_PX), -- 2761
			BRICK_LINE -- 2761
		) -- 2761
	end -- 2761
end -- 2728
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 2765
	self:drawBox( -- 2766
		draw, -- 2766
		w, -- 2766
		h, -- 2766
		x - 3, -- 2766
		x + 3, -- 2766
		y - 10, -- 2766
		y, -- 2766
		BOTTLE -- 2766
	) -- 2766
end -- 2765
function Play.prototype.drawTrace(self, draw, w, h) -- 2769
	local t = self.trace -- 2770
	if t == nil or self.traceT <= 0 then -- 2770
		return -- 2772
	end -- 2772
	draw:drawSegment( -- 2774
		Vec2( -- 2775
			self:sx(t.x0, w), -- 2775
			self:sy(t.y0, h) -- 2775
		), -- 2775
		Vec2( -- 2776
			self:sx(t.x1, w), -- 2776
			self:sy(t.y1, h) -- 2776
		), -- 2776
		self:px(1), -- 2777
		t.hit and AIM_HIT or INK_DIM -- 2777
	) -- 2777
end -- 2769
function Play.prototype.drawAim(self, draw, w, h) -- 2780
	local v = self.view -- 2782
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 2783
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 2784
	local dot = self:px(1) -- 2785
	local arm = self:px(3) -- 2786
	local gap = self:px(1) -- 2787
	draw:drawSegment( -- 2788
		Vec2(gx - arm - gap, gy), -- 2788
		Vec2(gx - gap, gy), -- 2788
		dot / 2, -- 2788
		AIM -- 2788
	) -- 2788
	draw:drawSegment( -- 2789
		Vec2(gx + gap, gy), -- 2789
		Vec2(gx + arm + gap, gy), -- 2789
		dot / 2, -- 2789
		AIM -- 2789
	) -- 2789
	draw:drawSegment( -- 2790
		Vec2(gx, gy - arm - gap), -- 2790
		Vec2(gx, gy - gap), -- 2790
		dot / 2, -- 2790
		AIM -- 2790
	) -- 2790
	draw:drawSegment( -- 2791
		Vec2(gx, gy + gap), -- 2791
		Vec2(gx, gy + arm + gap), -- 2791
		dot / 2, -- 2791
		AIM -- 2791
	) -- 2791
	if self.room.key == "village" and self.hasBottle then -- 2791
		local p = self.player -- 2795
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2797
		local dir = ____end.x >= p.x and 1 or -1 -- 2798
		local x0 = p.x + dir * 10 -- 2799
		local y0 = p.y + p.h * 0.7 -- 2800
		local T = BOTTLE_FLY_TIME -- 2801
		local vx = (____end.x - x0) / T -- 2802
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 2803
		local pxr = x0 -- 2804
		local pyr = y0 -- 2805
		local t = 1 -- 2806
		do -- 2806
			t = 1 -- 2807
			while t <= 12 do -- 2807
				local tt = t / 12 * T -- 2808
				local nx = x0 + vx * tt -- 2809
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 2810
				draw:drawSegment( -- 2811
					Vec2( -- 2811
						self:sx(pxr, w), -- 2811
						self:sy(pyr, h) -- 2811
					), -- 2811
					Vec2( -- 2811
						self:sx(nx, w), -- 2811
						self:sy(ny, h) -- 2811
					), -- 2811
					self:px(1) / 2, -- 2811
					BOTTLE -- 2811
				) -- 2811
				pxr = nx -- 2812
				pyr = ny -- 2813
				t = t + 1 -- 2807
			end -- 2807
		end -- 2807
		draw:drawCircle( -- 2815
			Vec2( -- 2815
				self:sx(____end.x, w), -- 2815
				self:sy(____end.y + 2, h) -- 2815
			), -- 2815
			self:px(2), -- 2815
			BOTTLE -- 2815
		) -- 2815
	end -- 2815
end -- 2780
return ____exports -- 2780