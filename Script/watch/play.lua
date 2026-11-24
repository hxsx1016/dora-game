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
function makeActor(room, index) -- 2815
	local sp = room.spawns -- 2816
	if index < 0 or index >= #sp then -- 2816
		return { -- 2818
			x = 0, -- 2818
			y = 0, -- 2818
			depth = 0, -- 2818
			depthSpeed = 0, -- 2818
			vx = 0, -- 2818
			vy = 0, -- 2818
			w = CHILD_W, -- 2818
			h = CHILD_H, -- 2818
			onGround = true, -- 2818
			facing = 1, -- 2818
			crouch = false, -- 2818
			rollT = 0, -- 2818
			covered = false, -- 2818
			alive = false -- 2818
		} -- 2818
	end -- 2818
	local s = sp[index + 1] -- 2820
	local child = s.h <= CHILD_H -- 2821
	local ground = room.depth -- 2822
	local depth = ground == nil and 0 or math.max( -- 2823
		ground.min, -- 2823
		math.min(ground.max, s.depth or 0) -- 2823
	) -- 2823
	return { -- 2824
		x = s.x, -- 2825
		y = s.y, -- 2825
		depth = depth, -- 2825
		depthSpeed = 0, -- 2825
		vx = 0, -- 2825
		vy = 0, -- 2825
		w = child and CHILD_W or SOLDIER_W, -- 2826
		h = child and CHILD_H or SOLDIER_H, -- 2827
		onGround = true, -- 2828
		facing = 1, -- 2828
		crouch = false, -- 2828
		rollT = 0, -- 2828
		covered = false, -- 2828
		alive = true -- 2828
	} -- 2828
end -- 2828
function drawFigure(draw, play, w, h, a, body, head) -- 2832
	if not a.alive then -- 2832
		return -- 2834
	end -- 2834
	local x0 = a.x - a.w / 2 -- 2836
	local x1 = a.x + a.w / 2 -- 2837
	local y0 = a.y + a.depth -- 2838
	local y1 = y0 + a.h -- 2839
	play:drawBox( -- 2840
		draw, -- 2840
		w, -- 2840
		h, -- 2840
		x0, -- 2840
		x1, -- 2840
		y0, -- 2840
		y1 - a.h * 0.26, -- 2840
		body -- 2840
	) -- 2840
	play:drawBox( -- 2841
		draw, -- 2841
		w, -- 2841
		h, -- 2841
		x0 + 2, -- 2841
		x1 - 2, -- 2841
		y1 - a.h * 0.26, -- 2841
		y1, -- 2841
		head -- 2841
	) -- 2841
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 2843
	play:drawBox( -- 2844
		draw, -- 2844
		w, -- 2844
		h, -- 2844
		eyeX, -- 2844
		eyeX + 4, -- 2844
		y1 - a.h * 0.14, -- 2844
		y1 - a.h * 0.08, -- 2844
		INK -- 2844
	) -- 2844
end -- 2844
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 2848
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 2849
end -- 2848
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 2856
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 2857
end -- 2856
function rayInterval(origin, direction, min, max) -- 2864
	if direction == 0 then -- 2864
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 2866
	end -- 2866
	local a = (min - origin) / direction -- 2868
	local b = (max - origin) / direction -- 2869
	return { -- 2870
		min = math.min(a, b), -- 2870
		max = math.max(a, b) -- 2870
	} -- 2870
end -- 2870
function hitBox(ray, box) -- 2874
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 2875
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 2876
	local enter = math.max(0, x.min, y.min) -- 2877
	local leave = math.min(99999, x.max, y.max) -- 2878
	if box.depth ~= nil then -- 2878
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 2880
		enter = math.max(enter, depth.min) -- 2881
		leave = math.min(leave, depth.max) -- 2882
	end -- 2882
	return leave >= enter and enter or -1 -- 2884
end -- 2884
function drawCartShape(draw, play, w, h, c, axleX) -- 2887
	local half = c.bodyW / 2 -- 2888
	local x0 = axleX - half -- 2889
	local x1 = axleX + half -- 2890
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 2891
	play:drawBox( -- 2892
		draw, -- 2892
		w, -- 2892
		h, -- 2892
		x0, -- 2892
		x1, -- 2892
		axleY, -- 2892
		axleY + c.bodyH, -- 2892
		CART_FILL -- 2892
	) -- 2892
	draw:drawCircle( -- 2893
		Vec2( -- 2893
			play:sx(x0 + c.bodyW * 0.28, w), -- 2893
			play:sy(axleY, h) -- 2893
		), -- 2893
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2893
		Color(52, 50, 48, 255) -- 2893
	) -- 2893
	draw:drawCircle( -- 2894
		Vec2( -- 2894
			play:sx(x1 - c.bodyW * 0.28, w), -- 2894
			play:sy(axleY, h) -- 2894
		), -- 2894
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2894
		Color(52, 50, 48, 255) -- 2894
	) -- 2894
	local cx = c.clothSide < 0 and x0 or x1 -- 2895
	play:drawBox( -- 2896
		draw, -- 2896
		w, -- 2896
		h, -- 2896
		cx - 10, -- 2896
		cx + 10, -- 2896
		axleY + c.bodyH, -- 2896
		axleY + c.bodyH + 18, -- 2896
		CLOTH -- 2896
	) -- 2896
end -- 2896
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
	local previousDepth = a.depth -- 770
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 771
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 772
	self:slideX(a, a.vx * dt) -- 773
	self:fallY(a, dt) -- 774
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 774
		self:shoot(a) -- 778
	end -- 778
end -- 682
function Play.prototype.stepPartner(self, p, dt) -- 783
	local a = self.partner -- 784
	if not a.alive then -- 784
		return -- 786
	end -- 786
	a.crouch = false -- 788
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 789
	a.vx = 0 -- 790
	a.depthSpeed = 0 -- 791
	self:fallY(a, dt) -- 792
end -- 783
function Play.prototype.stepEscort(self, dt, input) -- 799
	local a = self.partner -- 800
	a.depthSpeed = 0 -- 801
	if not a.alive then -- 801
		return -- 803
	end -- 803
	if not self:escortOn() then -- 803
		a.vx = 0 -- 806
		self:fallY(a, dt) -- 807
		return -- 808
	end -- 808
	local p = self.player -- 810
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 811
	local hadKnock1 = self.escort.knock1 -- 812
	local hadKnock2 = self.escort.knock2 -- 813
	self.calmConsumed = self.escort:update( -- 814
		input, -- 814
		p.x, -- 814
		p.facing, -- 814
		a.x, -- 814
		dist -- 814
	) -- 814
	if not hadKnock1 and self.escort.knock1 then -- 814
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 817
	end -- 817
	if not hadKnock2 and self.escort.knock2 then -- 817
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 820
	end -- 820
	a.crouch = self.escort.crouchPose -- 822
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 823
	if not self.escort.stopped then -- 823
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 825
		local previousDepth = a.depth -- 826
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 827
		local distance = math.max( -- 828
			-travel, -- 828
			math.min(travel, targetDepth - previousDepth) -- 828
		) -- 828
		self:slideDepth(a, distance) -- 829
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 830
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 830
			a.vy = CHILD_JUMP -- 832
			a.onGround = false -- 833
		end -- 833
	end -- 833
	local dir = self.escort:moveDir(a.x) -- 836
	a.vx = dir * CHILD_SPEED -- 837
	if dir ~= 0 then -- 837
		a.facing = dir -- 839
		local before = a.x -- 840
		self:slideX(a, dir * CHILD_SPEED * dt) -- 841
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 841
			a.vy = CHILD_JUMP -- 844
			a.onGround = false -- 845
		end -- 845
	end -- 845
	self:fallY(a, dt) -- 848
end -- 799
function Play.prototype.escortOn(self) -- 852
	if self.room.key == "checkpoint" then -- 852
		return true -- 854
	end -- 854
	if self.room.key == "prologue" then -- 854
		return self.phase == "prologue-follow" -- 857
	end -- 857
	return self.room.key == "street" -- 859
end -- 852
function Play.prototype.storyLocked(self) -- 863
	if self.caughtT > 0 then -- 863
		return true -- 865
	end -- 865
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 865
		return true -- 868
	end -- 868
	if self.room.key == "gate" and self.phase == "gate-count" then -- 868
		return true -- 871
	end -- 871
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 871
		return true -- 874
	end -- 874
	return false -- 876
end -- 863
function Play.prototype.swapToChild(self, x) -- 880
	local tmp = self.player -- 881
	self.player = self.partner -- 882
	self.partner = tmp -- 883
	self.childMode = true -- 884
	self.player.alive = true -- 885
	self.player.x = self.ox + x -- 886
	self.player.y = 0 -- 887
	self.player.depth = 0 -- 888
	self.player.depthSpeed = 0 -- 889
	self.player.vy = 0 -- 890
	self.player.vx = 0 -- 891
	self.player.onGround = true -- 892
	self.player.crouch = false -- 893
	self.player.h = CHILD_H -- 894
	self.player.facing = 1 -- 895
	self.partner.alive = true -- 896
	self.cam.x = self.player.x -- 897
end -- 880
function Play.prototype.stepStory(self, dt, input) -- 901
	if self.room.key == "prologue" then -- 901
		self:stepPrologue(dt, input) -- 903
	elseif self.room.key == "street" then -- 903
		self:stepStreet(dt, input) -- 905
	elseif self.room.key == "gate" then -- 905
		self:stepGate(dt, input) -- 907
	elseif self.room.key == "tower" then -- 907
		self:stepTower(dt, input) -- 909
	end -- 909
end -- 901
function Play.prototype.stepPrologue(self, dt, input) -- 914
	local child = self.partner -- 915
	if self.phase == "prologue-wait" then -- 915
		child.crouch = true -- 917
		child.h = CHILD_CROUCH_H -- 918
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 919
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 921
		if near and input.interact.pressed then -- 921
			self.phase = "prologue-give" -- 923
			self.phaseTick = 0 -- 924
			self:flashSet("递出针套", 1) -- 925
		end -- 925
		return -- 927
	end -- 927
	if self.phase == "prologue-give" then -- 927
		self.phaseTick = self.phaseTick + 1 -- 930
		if self.phaseTick == 12 then -- 930
			self:flashSet("针套递过去", 0.7) -- 932
		elseif self.phaseTick == 36 then -- 932
			self:flashSet("纸条塞进针套", 0.9) -- 934
		elseif self.phaseTick >= 60 then -- 934
			self.phase = "prologue-follow" -- 936
			self.phaseTick = 0 -- 937
			child.crouch = false -- 938
			child.h = CHILD_H -- 939
			self:flashSet("她跟上了", 1.2) -- 940
		end -- 940
		return -- 942
	end -- 942
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 942
		self:requestRoom("street", "序章跟到门口") -- 946
		self:flashSet("进街道", 1.2) -- 947
	end -- 947
end -- 914
function Play.prototype.stepStreet(self, dt, input) -- 952
	local p = self.player -- 953
	local c = self.partner -- 954
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 954
		self:requestRoom("checkpoint", "两人都到街尾") -- 956
		self:flashSet("到检查站", 1.2) -- 957
	end -- 957
end -- 952
function Play.prototype.stepGate(self, dt, input) -- 962
	local ____temp_14 -- 963
	if self.room.story == nil then -- 963
		____temp_14 = nil -- 963
	else -- 963
		____temp_14 = self.room.story.gate -- 963
	end -- 963
	local g = ____temp_14 -- 963
	if g == nil then -- 963
		return -- 965
	end -- 965
	local p = self.player -- 967
	if self.phase == "gate-idle" then -- 967
		local a = self.partner -- 970
		local gap = g.waitX - a.x -- 971
		if math.abs(gap) > 3 then -- 971
			a.facing = gap > 0 and 1 or -1 -- 973
			a.vx = a.facing * CHILD_SPEED -- 974
			local beforeX = a.x -- 975
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 976
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 976
				a.vy = CHILD_JUMP -- 978
				a.onGround = false -- 979
			end -- 979
			self:fallY(a, dt) -- 981
		else -- 981
			a.vx = 0 -- 983
			a.x = g.waitX -- 984
		end -- 984
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 987
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 988
		if self.gateNeedConfirm then -- 988
			if not input.interact.held then -- 988
				self.gateRestartArmed = true -- 993
			end -- 993
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 993
				self.gateNeedConfirm = false -- 996
				self.gateRestartArmed = true -- 997
				self.phase = "gate-hold" -- 998
				self.gateTick = 0 -- 999
				self.gateSpawned = 0 -- 1000
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1001
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1002
			end -- 1002
			return -- 1004
		end -- 1004
		if atWinch and atWait then -- 1004
			self.phase = "gate-hold" -- 1007
			self.gateTick = 0 -- 1008
			self.gateSpawned = 0 -- 1009
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1010
		end -- 1010
		return -- 1012
	end -- 1012
	if self.phase == "gate-hold" then -- 1012
		self.gateTick = self.gateTick + 1 -- 1015
		local marks = {0, 540, 900, 1500} -- 1017
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1017
			local idx = self.gateSpawned -- 1019
			local ____self_enemies_15 = self.enemies -- 1019
			____self_enemies_15[#____self_enemies_15 + 1] = { -- 1020
				x = self.ox + 620 + idx * 62, -- 1021
				y = 0, -- 1021
				w = 26, -- 1021
				h = 84, -- 1021
				alive = true, -- 1022
				hitT = 0, -- 1022
				warnT = 0, -- 1022
				fireCd = 90 + idx * 45 -- 1022
			} -- 1022
			self.gateSpawned = self.gateSpawned + 1 -- 1024
			self:flashSet( -- 1025
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1025
				0.9 -- 1025
			) -- 1025
		end -- 1025
		if self.gateTick == 900 then -- 1025
			self:flashSet("灯灭了", 1) -- 1028
		elseif self.gateTick == 2100 then -- 1028
			self:flashSet("门底压下来了", 1) -- 1030
		end -- 1030
		if self.gateTick >= g.holdTicks then -- 1030
			self.phase = "gate-send" -- 1033
			self.phaseTick = 0 -- 1034
			self.enemies = {} -- 1036
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1037
		end -- 1037
		return -- 1039
	end -- 1039
	if self.phase == "gate-send" then -- 1039
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1042
		if near and input.interact.pressed then -- 1042
			self:swapToChild(g.doorX + 30) -- 1044
			self.phase = "gate-count" -- 1045
			self.countTick = 0 -- 1046
			self.countArmed = false -- 1048
			self.countPrevMove = input.moveX -- 1049
			self:flashSet("门开了 · 送她出去", 1.8) -- 1050
		end -- 1050
		return -- 1052
	end -- 1052
	if self.phase == "gate-count" then -- 1052
		self.countTick = self.countTick + 1 -- 1055
		if self.countTick == 360 then -- 1055
			self:flashSet("门关上", 0.9) -- 1057
		elseif self.countTick == 1020 then -- 1057
			self:flashSet("数到一百", 2.2) -- 1059
		end -- 1059
		local prevMove = self.countPrevMove -- 1063
		self.countPrevMove = input.moveX -- 1064
		if self.countTick >= 1440 then -- 1064
			if prevMove <= 0 and input.moveX > 0 then -- 1064
				self.countArmed = true -- 1067
			end -- 1067
			if self.countArmed and input.moveX > 0 then -- 1067
				self.phase = "gate-walk" -- 1070
				self.phaseTick = 0 -- 1071
				self:flashSet("她迈出第一步", 1.4) -- 1072
			end -- 1072
		end -- 1072
		return -- 1075
	end -- 1075
	if self.player.x >= g.exitX then -- 1075
		self:requestRoom("outside", "走出城门") -- 1079
		self:flashSet("出城门 · 城外", 1.4) -- 1080
	end -- 1080
end -- 962
function Play.prototype.stepTower(self, dt, input) -- 1085
	local ____temp_16 -- 1086
	if self.room.story == nil then -- 1086
		____temp_16 = nil -- 1086
	else -- 1086
		____temp_16 = self.room.story.tower -- 1086
	end -- 1086
	local t = ____temp_16 -- 1086
	if t == nil then -- 1086
		return -- 1088
	end -- 1088
	if self.phase == "tower-wait" then -- 1088
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1091
		if near and input.interact.pressed then -- 1091
			self.phase = "tower-knock" -- 1093
			self.phaseTick = 0 -- 1094
			self.knocks = 1 -- 1095
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1096
			self:flashSet("敲一下", 0.6) -- 1097
		end -- 1097
		return -- 1099
	end -- 1099
	if self.phase == "tower-knock" then -- 1099
		self.phaseTick = self.phaseTick + 1 -- 1102
		if self.phaseTick == 12 then -- 1102
			self.knocks = 2 -- 1104
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1105
			self:flashSet("敲两下 · 第二声", 1) -- 1106
		elseif self.phaseTick >= t.knockTicks then -- 1106
			self.phase = "tower-given" -- 1108
			self.phaseTick = 0 -- 1109
			self:flashSet("门开了 · 提灯", 1.4) -- 1110
		end -- 1110
		return -- 1112
	end -- 1112
	if self.phase == "tower-given" then -- 1112
		self.phaseTick = self.phaseTick + 1 -- 1115
		if self.phaseTick == 60 then -- 1115
			self:flashSet("她递出针套和纸条", 1.6) -- 1117
		elseif self.phaseTick == 120 then -- 1117
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1119
		elseif self.phaseTick >= 180 then -- 1119
			self.phase = "tower-end" -- 1121
			self.phaseTick = 0 -- 1122
			self:flashSet("片尾 · E 再玩一次", 3) -- 1123
		end -- 1123
		return -- 1125
	end -- 1125
	if input.interact.pressed or input.retry.pressed then -- 1125
		self:requestRoom("prologue", "片尾再玩") -- 1128
		self:flashSet("回到序章", 1.4) -- 1129
	end -- 1129
end -- 1085
function Play.prototype.stepChase(self, dt, input) -- 1134
	if self.caughtT > 0 then -- 1134
		self.caughtT = self.caughtT - dt -- 1136
		if self.caughtT <= 0 then -- 1136
			self:recoverFromCaught() -- 1138
		end -- 1138
		return -- 1140
	end -- 1140
	if self.room.key == "village" then -- 1140
		self:stepScavChase() -- 1143
	elseif self.room.key == "forest" then -- 1143
		self:stepDog(dt) -- 1145
		if self.player.x >= self.ox + 1450 then -- 1145
			self:requestRoom("tower", "到林缘北塔") -- 1148
			self:flashSet("林缘 · 北塔", 1.4) -- 1149
		end -- 1149
	end -- 1149
end -- 1134
function Play.prototype.stepScavChase(self) -- 1155
	local s = self.room.scavenger -- 1156
	if s == nil then -- 1156
		return -- 1158
	end -- 1158
	local p = self.player -- 1160
	if self.passed and p.x > self.ox + 440 then -- 1160
		if self.scavChase then -- 1160
			self.scavChase = false -- 1164
			self.scavState = "back" -- 1165
			self.scavT = 0 -- 1166
		end -- 1166
		return -- 1168
	end -- 1168
	local dx = p.x - self.scavX -- 1170
	local dist = math.abs(dx) -- 1171
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1172
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1173
	if not self.scavChase then -- 1173
		if visible then -- 1173
			self.scavSee = self.scavSee + 1 -- 1176
			if self.scavSee >= 24 then -- 1176
				self.scavChase = true -- 1178
				self.scavState = "chase" -- 1179
				self.scavTargetX = p.x -- 1180
				self:flashSet("他看见你了", 1.2) -- 1181
			end -- 1181
		else -- 1181
			self.scavSee = 0 -- 1184
		end -- 1184
		return -- 1186
	end -- 1186
	local dir = p.x > self.scavX and 1 or -1 -- 1189
	self.scavX = self.scavX + dir * 96 / 60 -- 1190
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1190
		self:caught() -- 1192
		return -- 1193
	end -- 1193
	if hidden then -- 1193
		self.scavSee = 0 -- 1197
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1198
		self.scavT = self.scavT - 1 -- 1199
		if self.scavT <= 0 then -- 1199
			self.scavChase = false -- 1201
			self.scavState = "patrol" -- 1202
			self:flashSet("他失去了目标", 1) -- 1203
		end -- 1203
	end -- 1203
end -- 1155
function Play.prototype.stepDog(self, dt) -- 1209
	local ____temp_17 -- 1210
	if self.room.story == nil then -- 1210
		____temp_17 = nil -- 1210
	else -- 1210
		____temp_17 = self.room.story.dog -- 1210
	end -- 1210
	local dog = ____temp_17 -- 1210
	if dog == nil then -- 1210
		return -- 1212
	end -- 1212
	local p = self.player -- 1214
	local dist = math.abs(p.x - self.dogX) -- 1215
	if self.dogState == "patrol" then -- 1215
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1217
		if self.dogX < dog.x0 then -- 1217
			self.dogX = dog.x0 -- 1219
			self.dogDir = 1 -- 1220
		elseif self.dogX > dog.x1 then -- 1220
			self.dogX = dog.x1 -- 1222
			self.dogDir = -1 -- 1223
		end -- 1223
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1225
		if not p.crouch and moving and dist < dog.range then -- 1225
			self.dogState = "ear" -- 1227
			self.dogT = 18 -- 1228
			self.dogTargetX = p.x -- 1229
			self:flashSet("狗转耳朵", 0.8) -- 1230
		end -- 1230
		return -- 1232
	end -- 1232
	if self.dogState == "ear" then -- 1232
		self.dogT = self.dogT - 1 -- 1235
		if self.dogT <= 0 then -- 1235
			self.dogState = "chase" -- 1237
			self.dogTargetX = p.x -- 1238
			self:flashSet("狗追来了", 1.4) -- 1239
		end -- 1239
		return -- 1241
	end -- 1241
	if self.dogState == "chase" then -- 1241
		local dir = p.x > self.dogX and 1 or -1 -- 1244
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1245
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1245
			self:caught() -- 1247
			self.dogState = "sniff" -- 1248
			self.dogT = 60 -- 1249
		elseif dist > dog.range * 1.5 or p.crouch then -- 1249
			self.dogState = "sniff" -- 1251
			self.dogT = 60 -- 1252
			self:flashSet("狗停下了", 0.9) -- 1253
		end -- 1253
		return -- 1255
	end -- 1255
	if self.dogState == "sniff" then -- 1255
		self.dogT = self.dogT - 1 -- 1258
		if self.dogT <= 0 then -- 1258
			self.dogState = "back" -- 1260
		end -- 1260
		return -- 1262
	end -- 1262
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1265
	self.dogX = self.dogX + dir * dog.speed * dt -- 1266
	if math.abs(self.dogX - dog.x0) < 2 then -- 1266
		self.dogX = dog.x0 -- 1268
		self.dogState = "patrol" -- 1269
	end -- 1269
end -- 1209
function Play.prototype.caught(self) -- 1273
	self.caughtT = 1 -- 1274
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1275
end -- 1273
function Play.prototype.recoverFromCaught(self) -- 1279
	local p = self.player -- 1280
	p.x = self.ox + 140 -- 1281
	p.y = 0 -- 1282
	p.vy = 0 -- 1283
	p.vx = 0 -- 1284
	p.onGround = true -- 1285
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1285
		self.scavX = self.room.scavenger.x0 -- 1287
		self.scavState = "patrol" -- 1288
		self.scavSee = 0 -- 1289
		self.scavChase = false -- 1290
		self.scavT = 0 -- 1291
	end -- 1291
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1291
		self.dogX = self.room.story.dog.x0 -- 1294
		self.dogState = "patrol" -- 1295
		self.dogT = 0 -- 1296
	end -- 1296
	self.cam.x = p.x -- 1298
	self.cam.y = p.y + CAM_LOOK_UP -- 1299
	self:flashSet("回到安全点", 1.2) -- 1300
end -- 1279
function Play.prototype.updateGate(self) -- 1304
	if self.room.key ~= "checkpoint" then -- 1304
		self.gateOpen = false -- 1306
		return -- 1307
	end -- 1307
	local function inZone(x) -- 1309
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1309
	end -- 1309
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1310
end -- 1304
function Play.prototype.stepEnemies(self, dt, input) -- 1313
	local i = 0 -- 1314
	do -- 1314
		i = 0 -- 1315
		while i < #self.enemies do -- 1315
			local e = self.enemies[i + 1] -- 1316
			if e.hitT > 0 then -- 1316
				e.hitT = e.hitT - dt -- 1318
			end -- 1318
			i = i + 1 -- 1315
		end -- 1315
	end -- 1315
	if self.coveredFlash > 0 then -- 1315
		self.coveredFlash = self.coveredFlash - dt -- 1322
	end -- 1322
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 1322
		return -- 1326
	end -- 1326
	do -- 1326
		i = 0 -- 1328
		while i < #self.enemies do -- 1328
			do -- 1328
				local e = self.enemies[i + 1] -- 1329
				if not e.alive then -- 1329
					goto __continue203 -- 1331
				end -- 1331
				if e.warnT > 0 then -- 1331
					e.warnT = e.warnT - 1 -- 1334
					if e.warnT <= 0 then -- 1334
						self:enemyFire(e, input) -- 1336
					end -- 1336
					goto __continue203 -- 1338
				end -- 1338
				if e.fireCd > 0 then -- 1338
					e.fireCd = e.fireCd - 1 -- 1341
					if e.fireCd <= 0 then -- 1341
						e.warnT = WARN_TICKS -- 1343
					end -- 1343
				else -- 1343
					e.warnT = WARN_TICKS -- 1347
				end -- 1347
			end -- 1347
			::__continue203:: -- 1347
			i = i + 1 -- 1328
		end -- 1328
	end -- 1328
end -- 1313
function Play.prototype.enemyFire(self, e, input) -- 1353
	local p = self.player -- 1354
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 1354
		self:flashSet("枪声响在远处", 0.4) -- 1356
		e.fireCd = FIRE_COOLDOWN -- 1357
		return -- 1358
	end -- 1358
	local cover = self:blockedByCover(e, p) -- 1361
	local hugging = cover ~= nil -- 1362
	self.coverBlocking = hugging -- 1363
	local covered = hugging and input.cover.held -- 1364
	if covered then -- 1364
		self.coveredFlash = 0.5 -- 1366
		self:flashSet("掩体挡下", 0.5) -- 1367
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 1368
		e.fireCd = FIRE_COOLDOWN -- 1373
		return -- 1374
	end -- 1374
	self.hp = self.hp - 1 -- 1376
	self:emit("actorHit", { -- 1377
		target = "player", -- 1377
		amount = 1, -- 1377
		hp = self.hp, -- 1377
		maxHp = self.maxHp, -- 1377
		enemyX = e.x -- 1377
	}) -- 1377
	self:flashSet( -- 1378
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 1378
		0.7 -- 1378
	) -- 1378
	e.fireCd = FIRE_COOLDOWN -- 1379
	if self.hp <= 0 then -- 1379
		self:gateFailed() -- 1381
	end -- 1381
end -- 1353
function Play.prototype.blockedByCover(self, enemy, p) -- 1386
	local b = self:coverAt(p) -- 1387
	if b == nil then -- 1387
		return nil -- 1389
	end -- 1389
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 1391
end -- 1386
function Play.prototype.gateFailed(self) -- 1395
	local ____temp_18 -- 1396
	if self.room.story == nil then -- 1396
		____temp_18 = nil -- 1396
	else -- 1396
		____temp_18 = self.room.story.gate -- 1396
	end -- 1396
	local g = ____temp_18 -- 1396
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 1397
	self.hp = self.maxHp -- 1398
	self.gateTick = 0 -- 1399
	self.gateSpawned = 0 -- 1400
	self.enemies = {} -- 1401
	self.gateFailCount = self.gateFailCount + 1 -- 1402
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 1404
	self.player.y = 0 -- 1405
	self.player.vy = 0 -- 1406
	self.player.depth = 0 -- 1407
	self.player.depthSpeed = 0 -- 1408
	self.player.onGround = true -- 1409
	self.player.crouch = false -- 1410
	self.player.h = SOLDIER_H -- 1411
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 1412
	self.partner.y = 0 -- 1413
	self.partner.vy = 0 -- 1414
	self.partner.depth = 0 -- 1415
	self.partner.depthSpeed = 0 -- 1416
	self.partner.onGround = true -- 1417
	self.cam.x = self.player.x -- 1418
	self.phase = "gate-idle" -- 1419
	self.phaseTick = 0 -- 1420
	self.coverHug = false -- 1421
	self.coverBlocking = false -- 1422
	self.coverEntity = "" -- 1423
	self.gateNeedConfirm = true -- 1424
	self.gateRestartArmed = false -- 1425
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 1426
end -- 1395
function Play.prototype.stepInteract(self, dt, input) -- 1429
	local p = self.player -- 1430
	local calmUsed = self.calmConsumed -- 1431
	self.calmConsumed = false -- 1432
	local calming = self.escort.state == "calming" -- 1434
	self.focusCart = false -- 1435
	if self.room.key == "outside" then -- 1435
		local c = self.room.cart -- 1437
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 1438
		local dy = p.y - c.baseY -- 1439
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 1440
	end -- 1440
	if not calmUsed and not calming then -- 1440
		self:stepCart(dt, input) -- 1444
	end -- 1444
	if calmUsed then -- 1444
		self:flashSet("安抚 · 敲两下", 0.8) -- 1449
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 1449
		if self.knockT > 0 then -- 1449
			self.knocks = self.knocks + 1 -- 1453
		else -- 1453
			self.knocks = 1 -- 1455
		end -- 1455
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 1457
		self.knockT = 1.2 -- 1458
		if self.knocks >= 2 then -- 1458
			self:flashSet("敲两下", 0.8) -- 1460
			self.knocks = 0 -- 1461
		else -- 1461
			self:flashSet("敲一下", 0.5) -- 1463
		end -- 1463
	elseif self.knockT > 0 then -- 1463
		self.knockT = self.knockT - dt -- 1466
		if self.knockT <= 0 then -- 1466
			self.knocks = 0 -- 1468
		end -- 1468
	end -- 1468
	local i = 0 -- 1473
	do -- 1473
		i = 0 -- 1474
		while i < #self.room.marks do -- 1474
			do -- 1474
				local m = self.room.marks[i + 1] -- 1475
				if m.kind ~= 0 then -- 1475
					goto __continue229 -- 1477
				end -- 1477
				local subjects = {self.partner, self.player} -- 1479
				local k = 0 -- 1480
				do -- 1480
					k = 0 -- 1481
					while k < #subjects do -- 1481
						do -- 1481
							local s = subjects[k + 1] -- 1482
							if not s.alive then -- 1482
								goto __continue232 -- 1484
							end -- 1484
							local dx = s.x - m.x -- 1486
							local dy = s.y - m.y -- 1487
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 1487
								self.checkpoint = m.x -- 1489
								self.checkpointCartAxle = self.cartAxle -- 1490
								if self.cartDocked then -- 1490
									self:flashSet("检查点 · 车已落窝", 1) -- 1492
								else -- 1492
									self:flashSet("检查点 · 车还没到位", 1) -- 1494
								end -- 1494
							end -- 1494
						end -- 1494
						::__continue232:: -- 1494
						k = k + 1 -- 1481
					end -- 1481
				end -- 1481
			end -- 1481
			::__continue229:: -- 1481
			i = i + 1 -- 1474
		end -- 1474
	end -- 1474
	self:checkCarryGate() -- 1500
end -- 1429
function Play.prototype.stepVillage(self, dt, input) -- 1504
	if self.room.key ~= "village" then -- 1504
		return -- 1506
	end -- 1506
	local p = self.player -- 1508
	local bottle = self.room.bottle -- 1509
	local scav = self.room.scavenger -- 1510
	if not self.hasBottle and bottle ~= nil then -- 1510
		local dx = p.x - bottle.x -- 1514
		local dy = p.y + p.h * 0.5 - bottle.y -- 1515
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 1515
			self.hasBottle = true -- 1517
			self:flashSet("拾起瓶子", 0.8) -- 1518
		end -- 1518
	end -- 1518
	if self.hasBottle then -- 1518
		if input.aim.held then -- 1518
			self.aimHold = self.aimHold + dt -- 1525
			if self.aimHold > 1.2 then -- 1525
				self.aimHold = 1.2 -- 1527
			end -- 1527
			local cached = self:bottleEnd() -- 1530
			self.bottleAimX = cached.x -- 1531
			self.bottleAimY = cached.y -- 1532
		elseif input.aim.released then -- 1532
			if self.aimHold < 0.12 then -- 1532
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 1536
				self.aimHold = 0 -- 1537
			else -- 1537
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 1539
				self:throwBottle(____end.x, ____end.y) -- 1540
				self.aimHold = 0 -- 1541
			end -- 1541
		end -- 1541
	else -- 1541
		self.aimHold = 0 -- 1545
		self.bottleAimX = -1 -- 1546
	end -- 1546
	local fly = self.bottleFly -- 1551
	if fly ~= nil then -- 1551
		fly.t = fly.t + dt -- 1553
		fly.x = fly.x0 + fly.vx * fly.t -- 1554
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 1555
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 1556
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 1556
			self:landBottle(fly) -- 1558
		end -- 1558
	end -- 1558
	if self.bottleLandT > 0 then -- 1558
		self.bottleLandT = self.bottleLandT - dt -- 1562
	end -- 1562
	if scav ~= nil then -- 1562
		self:stepScav(dt, scav) -- 1566
	end -- 1566
	local line = self.room.passLine -- 1569
	if line ~= nil and not self.passed and p.x >= line then -- 1569
		self.passed = true -- 1571
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 1572
	end -- 1572
	if self.passed and p.x >= self.ox + 640 then -- 1572
		self:requestRoom("forest", "过第一院出院") -- 1576
		self:flashSet("出院 · 北塔森林", 1.4) -- 1577
	end -- 1577
end -- 1504
function Play.prototype.bottleEnd(self) -- 1582
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1583
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 1586
	return {x = aim.x, y = g} -- 1587
end -- 1582
function Play.prototype.throwBottle(self, tx, ty) -- 1591
	local p = self.player -- 1592
	local dir = tx >= p.x and 1 or -1 -- 1594
	p.facing = dir -- 1595
	local x0 = p.x + dir * 10 -- 1596
	local y0 = p.y + p.h * 0.7 -- 1597
	self.bottleTargetX = tx -- 1598
	self.bottleTargetY = ty -- 1599
	self.bottleSurfaceY = ty -- 1600
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 1601
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 1602
	self.bottleFly = { -- 1603
		x = x0, -- 1603
		y = y0, -- 1603
		x0 = x0, -- 1603
		y0 = y0, -- 1603
		vx = vx, -- 1603
		vy = vy, -- 1603
		t = 0 -- 1603
	} -- 1603
	self.hasBottle = false -- 1604
	self:flashSet("投出", 0.4) -- 1605
	self:emit( -- 1606
		"bottleThrown", -- 1606
		{ -- 1606
			fromX = x0, -- 1607
			fromY = y0, -- 1608
			targetX = tx, -- 1609
			targetY = ty, -- 1610
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 1611
		} -- 1611
	) -- 1611
end -- 1591
function Play.prototype.landBottle(self, fly) -- 1616
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 1617
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 1618
	local s = self.room.scavenger -- 1619
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 1620
	self.bottleFly = nil -- 1621
	self.bottleTargetX = -1 -- 1622
	self.bottleTargetY = 0 -- 1623
	self.bottleSurfaceY = -1 -- 1624
	self.bottleLandX = x -- 1625
	self.bottleLandY = y -- 1626
	self.bottleLandT = 0.9 -- 1627
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 1628
	self:hearBottle(x) -- 1629
end -- 1616
function Play.prototype.hearBottle(self, x) -- 1633
	local s = self.room.scavenger -- 1634
	if s == nil then -- 1634
		return -- 1636
	end -- 1636
	if math.abs(x - self.scavX) > s.range then -- 1636
		self:flashSet("落地 · 他没听见", 0.6) -- 1639
		return -- 1640
	end -- 1640
	self.scavState = "turn" -- 1642
	self.scavT = s.hearTicks -- 1643
	self.scavTargetX = x -- 1644
	self:flashSet("砖地一响 · 他转头", 0.9) -- 1645
end -- 1633
function Play.prototype.stepScav(self, dt, s) -- 1649
	if self.scavState == "chase" then -- 1649
		return -- 1652
	end -- 1652
	if self.scavState == "turn" then -- 1652
		self.scavT = self.scavT - 1 -- 1655
		if self.scavT <= 0 then -- 1655
			self.scavState = "walk" -- 1657
		end -- 1657
		return -- 1659
	end -- 1659
	if self.scavState == "walk" then -- 1659
		local d = self.scavTargetX - self.scavX -- 1662
		if math.abs(d) < 4 then -- 1662
			self.scavState = "stall" -- 1664
			self.scavT = s.stallTicks -- 1665
			return -- 1666
		end -- 1666
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 1668
		return -- 1669
	end -- 1669
	if self.scavState == "stall" then -- 1669
		self.scavT = self.scavT - 1 -- 1672
		if self.scavT <= 0 then -- 1672
			self.scavState = "back" -- 1674
		end -- 1674
		return -- 1676
	end -- 1676
	if self.scavState == "back" then -- 1676
		local home = math.max( -- 1679
			s.x0, -- 1679
			math.min(s.x1, self.scavX) -- 1679
		) -- 1679
		if math.abs(home - self.scavX) < 2 then -- 1679
			self.scavState = "patrol" -- 1681
			return -- 1682
		end -- 1682
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 1684
		return -- 1685
	end -- 1685
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 1687
	if self.scavX >= s.x1 then -- 1687
		self.scavX = s.x1 -- 1689
		self.scavDir = -1 -- 1690
	elseif self.scavX <= s.x0 then -- 1690
		self.scavX = s.x0 -- 1692
		self.scavDir = 1 -- 1693
	end -- 1693
end -- 1649
function Play.prototype.stepCart(self, dt, input) -- 1701
	local p = self.player -- 1702
	local c = self.room.cart -- 1703
	if self.gripping then -- 1703
		if not input.interact.held then -- 1703
			self.gripping = false -- 1707
			self:flashSet("松开车把", 0.4) -- 1708
			return -- 1709
		end -- 1709
	else -- 1709
		if not input.interact.pressed then -- 1709
			return -- 1713
		end -- 1713
		if not self:cartHandleInReach(p) then -- 1713
			return -- 1716
		end -- 1716
		local track = c.depth or 0 -- 1718
		self:slideDepth(p, track - p.depth) -- 1719
		if math.abs(p.depth - track) > 0.001 then -- 1719
			return -- 1721
		end -- 1721
		p.depthSpeed = 0 -- 1723
		self.gripping = true -- 1724
		self:flashSet("握住车把", 0.4) -- 1725
		return -- 1726
	end -- 1726
	if self.cartDocked then -- 1726
		return -- 1730
	end -- 1730
	local dir = input.moveX -- 1732
	if dir == 0 then -- 1732
		return -- 1734
	end -- 1734
	local lo = math.min(c.startX, c.endX) -- 1736
	local hi = math.max(c.startX, c.endX) -- 1737
	local next = self.cartAxle + dir * CART_SPEED * dt -- 1738
	if next < lo then -- 1738
		next = lo -- 1740
	end -- 1740
	if next > hi then -- 1740
		next = hi -- 1743
	end -- 1743
	local delta = next - self.cartAxle -- 1745
	if delta == 0 then -- 1745
		return -- 1747
	end -- 1747
	self.cartAxle = next -- 1749
	p.x = p.x + delta -- 1750
	p.facing = dir > 0 and 1 or -1 -- 1751
	self:slideX(p, 0) -- 1752
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 1752
		self.gripping = false -- 1754
		self:flashSet("跟不上了，脱手", 0.6) -- 1755
		return -- 1756
	end -- 1756
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 1756
		self.cartDocked = true -- 1759
		self.gripping = false -- 1760
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 1761
		self:flashSet("车轮落窝", 1.2) -- 1762
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 1762
		self:flashSet("车轮回到起点", 0.5) -- 1764
	end -- 1764
end -- 1701
function Play.prototype.requestRoom(self, key, reason) -- 1772
	if self.wantRoom ~= "" then -- 1772
		return -- 1776
	end -- 1776
	self.wantRoom = key -- 1778
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 1779
end -- 1772
function Play.prototype.checkCarryGate(self) -- 1786
	if self.room.key == "checkpoint" then -- 1786
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 1786
			self.carryCartAxle = self.cartAxle -- 1789
			self.carryCartDocked = self.cartDocked -- 1790
			self:requestRoom("gate", "检查站出口") -- 1791
			self:flashSet("出检查站 · 城门", 1.2) -- 1792
		end -- 1792
		return -- 1794
	end -- 1794
	if self.room.key == "outside" then -- 1794
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 1794
			self.carryCartAxle = self.cartAxle -- 1800
			self.carryCartDocked = self.cartDocked -- 1801
			self:requestRoom("village", "墙根走完") -- 1802
			self:flashSet("墙根走完 · 进村口", 1.2) -- 1803
		end -- 1803
	end -- 1803
end -- 1786
function Play.prototype.aimAt(self, wx, wy) -- 1810
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 1811
	self.aimX = s.x -- 1812
	self.aimY = s.y -- 1813
end -- 1810
function Play.prototype.shoot(self, a) -- 1816
	local ox = a.x + a.facing * 8 -- 1817
	local muzzleY = a.y + a.h * 0.72 -- 1818
	local oy = muzzleY + a.depth -- 1819
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1821
	local dx = aim.x - ox -- 1824
	local dy = aim.y - oy -- 1825
	local len = math.sqrt(dx * dx + dy * dy) -- 1826
	if len < 0.001 then -- 1826
		dx = a.facing -- 1828
		dy = 0 -- 1829
	else -- 1829
		dx = dx / len -- 1831
		dy = dy / len -- 1832
	end -- 1832
	if dx ~= 0 then -- 1832
		a.facing = dx > 0 and 1 or -1 -- 1835
	end -- 1835
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 1838
	local hitEnemy = self:raycastEnemies(ray) -- 1839
	local tEnemy = hitEnemy.t -- 1840
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 1841
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 1842
	local tWall = self:raycastWorld(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 1843
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 1844
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 1845
	self.trace = { -- 1847
		x0 = ox, -- 1847
		y0 = oy, -- 1847
		x1 = ox + dx * t, -- 1847
		y1 = oy + dy * t, -- 1847
		hit = hit -- 1847
	} -- 1847
	self.traceT = 0.12 -- 1848
	self:applyFireDanger(ox) -- 1849
	if hit then -- 1849
		local i = hitEnemy.index -- 1851
		local e = self.enemies[i + 1] -- 1852
		e.alive = false -- 1853
		e.hitT = 0.4 -- 1854
		self:flashSet("命中", 0.6) -- 1855
	else -- 1855
		self:flashSet("打空", 0.35) -- 1857
	end -- 1857
	self:emit("shotResolved", { -- 1859
		hit = hit, -- 1860
		enemyIndex = hit and hitEnemy.index or -1, -- 1861
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 1862
		aimX = aim.x, -- 1863
		aimY = aim.y, -- 1864
		impactX = ox + dx * t, -- 1865
		impactY = oy + dy * t -- 1866
	}) -- 1866
end -- 1816
function Play.prototype.applyFireDanger(self, shotX) -- 1871
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 1871
		return -- 1873
	end -- 1873
	local dangerX = shotX -- 1875
	local best = -1 -- 1876
	local bestD = 1000000000 -- 1877
	local i = 0 -- 1878
	do -- 1878
		i = 0 -- 1879
		while i < #self.enemies do -- 1879
			do -- 1879
				local e = self.enemies[i + 1] -- 1880
				if not e.alive then -- 1880
					goto __continue304 -- 1882
				end -- 1882
				local d = math.abs(e.x - self.partner.x) -- 1884
				if d < bestD then -- 1884
					bestD = d -- 1886
					best = i -- 1887
				end -- 1887
			end -- 1887
			::__continue304:: -- 1887
			i = i + 1 -- 1879
		end -- 1879
	end -- 1879
	if best >= 0 then -- 1879
		dangerX = self.enemies[best + 1].x -- 1891
	end -- 1891
	local exposed = self:childExposed(dangerX) -- 1893
	local before = self.escort.fear -- 1894
	local dangerId = self.nextDangerId -- 1895
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 1896
	self.nextDangerId = self.nextDangerId + 1 -- 1897
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 1898
	if after > before then -- 1898
		self:flashSet( -- 1900
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 1900
			1 -- 1900
		) -- 1900
	elseif not exposed then -- 1900
		self:flashSet("枪声没够到她", 0.5) -- 1902
	end -- 1902
end -- 1871
function Play.prototype.childExposed(self, dangerX) -- 1907
	local c = self.partner -- 1908
	if not c.alive then -- 1908
		return false -- 1910
	end -- 1910
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 1910
		self.boxes, -- 1913
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 1913
	) then -- 1913
		return false -- 1914
	end -- 1914
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 1914
		return false -- 1917
	end -- 1917
	local toDanger = dangerX - c.x -- 1919
	local toPlayer = self.player.x - c.x -- 1920
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 1920
		return false -- 1923
	end -- 1923
	return true -- 1925
end -- 1907
function Play.prototype.raycastEnemies(self, ray) -- 1929
	local best = -1 -- 1930
	local bestI = -1 -- 1931
	do -- 1931
		local i = 0 -- 1932
		while i < #self.enemies do -- 1932
			do -- 1932
				local e = self.enemies[i + 1] -- 1933
				if not e.alive then -- 1933
					goto __continue318 -- 1935
				end -- 1935
				local y = e.y + (e.depth or 0) -- 1937
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 1938
				if t >= 0 and (best < 0 or t < best) then -- 1938
					best = t -- 1940
					bestI = i -- 1941
				end -- 1941
			end -- 1941
			::__continue318:: -- 1941
			i = i + 1 -- 1932
		end -- 1932
	end -- 1932
	return {t = best, index = bestI} -- 1944
end -- 1929
function Play.prototype.raycastWorld(self, ray) -- 1947
	local best = -1 -- 1948
	for ____, box in ipairs(self.boxes) do -- 1949
		local t = hitBox(ray, box) -- 1950
		if t >= 0 and (best < 0 or t < best) then -- 1950
			best = t -- 1952
		end -- 1952
	end -- 1952
	if ray.dy < 0 then -- 1952
		local t = -ray.y / ray.dy -- 1956
		if t >= 0 and (best < 0 or t < best) then -- 1956
			best = t -- 1958
		end -- 1958
	end -- 1958
	return best -- 1961
end -- 1947
function Play.prototype.slideDepth(self, a, distance) -- 1965
	local road = self.room.depth -- 1966
	if road == nil or distance == 0 then -- 1966
		return -- 1968
	end -- 1968
	local next = math.max( -- 1970
		road.min, -- 1970
		math.min(road.max, a.depth + distance) -- 1970
	) -- 1970
	local half = a.w / 2 -- 1971
	for ____, b in ipairs(self.boxes) do -- 1972
		do -- 1972
			local footprint = b.depth -- 1973
			if footprint == nil or b.passable == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1973
				goto __continue329 -- 1977
			end -- 1977
			local front = footprint.min - ACTOR_DEPTH_HALF -- 1979
			local back = footprint.max + ACTOR_DEPTH_HALF -- 1980
			if a.depth <= front and next > front then -- 1980
				next = front -- 1982
			elseif a.depth >= back and next < back then -- 1982
				next = back -- 1984
			end -- 1984
		end -- 1984
		::__continue329:: -- 1984
	end -- 1984
	a.depth = next -- 1987
end -- 1965
function Play.prototype.slideX(self, a, dx) -- 1991
	local nx = a.x + dx -- 1992
	local half = a.w / 2 -- 1993
	local room = self.room -- 1994
	nx = math.max( -- 1995
		room.minX + half, -- 1995
		math.min(room.maxX - half, nx) -- 1995
	) -- 1995
	local i = 0 -- 1996
	do -- 1996
		i = 0 -- 1997
		while i < #self.boxes do -- 1997
			do -- 1997
				local b = self.boxes[i + 1] -- 1998
				if b.passable == true or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1998
					goto __continue336 -- 2000
				end -- 2000
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 2000
					goto __continue336 -- 2003
				end -- 2003
				if nx + half > b.x0 and nx - half < b.x1 then -- 2003
					if a.x <= b.x0 then -- 2003
						nx = b.x0 - half -- 2007
					elseif a.x >= b.x1 then -- 2007
						nx = b.x1 + half -- 2009
					else -- 2009
						nx = a.x -- 2011
					end -- 2011
				end -- 2011
			end -- 2011
			::__continue336:: -- 2011
			i = i + 1 -- 1997
		end -- 1997
	end -- 1997
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 1997
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 2019
		local bx0 = self.cartAxle - CART_HALF -- 2020
		local bx1 = self.cartAxle + CART_HALF -- 2021
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 2021
			if a.x <= bx0 then -- 2021
				nx = bx0 - half -- 2024
			elseif a.x >= bx1 then -- 2024
				nx = bx1 + half -- 2026
			else -- 2026
				nx = a.x -- 2028
			end -- 2028
		end -- 2028
	end -- 2028
	local arch = room.arch -- 2036
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 2036
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 2038
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 2038
			if a.x <= arch.x0 then -- 2038
				nx = arch.x0 - half -- 2041
			elseif a.x >= arch.x1 then -- 2041
				nx = arch.x1 + half -- 2043
			end -- 2043
		end -- 2043
	end -- 2043
	a.x = nx -- 2047
end -- 1991
function Play.prototype.fallY(self, a, dt) -- 2051
	a.vy = a.vy - ____exports.GRAVITY * dt -- 2052
	if a.vy < -900 then -- 2052
		a.vy = -900 -- 2054
	end -- 2054
	local ny = a.y + a.vy * dt -- 2056
	local half = a.w / 2 -- 2057
	if a.vy <= 0 then -- 2057
		local reach = a.onGround and STEP_UP or 0 -- 2060
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 2061
		if ny <= ground then -- 2061
			ny = ground -- 2063
			a.vy = 0 -- 2064
			a.onGround = true -- 2065
		else -- 2065
			a.onGround = false -- 2067
		end -- 2067
	else -- 2067
		a.onGround = false -- 2070
		local i = 0 -- 2071
		do -- 2071
			i = 0 -- 2072
			while i < #self.boxes do -- 2072
				do -- 2072
					local b = self.boxes[i + 1] -- 2073
					if b.passable == true or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2073
						goto __continue359 -- 2075
					end -- 2075
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 2075
						goto __continue359 -- 2078
					end -- 2078
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 2078
						ny = b.y0 - a.h -- 2081
						a.vy = 0 -- 2082
					end -- 2082
				end -- 2082
				::__continue359:: -- 2082
				i = i + 1 -- 2072
			end -- 2072
		end -- 2072
	end -- 2072
	a.y = ny -- 2086
end -- 2051
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 2090
	if depth == nil then -- 2090
		depth = 0 -- 2090
	end -- 2090
	local g = -9999 -- 2091
	local i = 0 -- 2092
	do -- 2092
		i = 0 -- 2093
		while i < #self.floors do -- 2093
			local f = self.floors[i + 1] -- 2094
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 2094
				g = f.y1 -- 2096
			end -- 2096
			i = i + 1 -- 2093
		end -- 2093
	end -- 2093
	do -- 2093
		i = 0 -- 2099
		while i < #self.boxes do -- 2099
			local b = self.boxes[i + 1] -- 2100
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 2100
				g = b.y1 -- 2103
			end -- 2103
			i = i + 1 -- 2099
		end -- 2099
	end -- 2099
	return g -- 2106
end -- 2090
function Play.prototype.updateCamera(self, dt) -- 2109
	local p = self.player -- 2110
	local tx = p.x + p.facing * 30 -- 2111
	local ty = p.y + CAM_LOOK_UP -- 2112
	local k = math.min(1, CAM_FOLLOW * dt) -- 2113
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 2114
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 2115
end -- 2109
function Play.prototype.clampCamera(self, w, h) -- 2119
	local room = self.room -- 2120
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 2121
	local spanX = room.maxX - room.minX -- 2122
	if spanX <= halfW * 2 then -- 2122
		self.cam.x = (room.minX + room.maxX) / 2 -- 2124
	else -- 2124
		self.cam.x = math.max( -- 2126
			room.minX + halfW, -- 2126
			math.min(room.maxX - halfW, self.cam.x) -- 2126
		) -- 2126
	end -- 2126
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 2129
	local spanY = room.height -- 2130
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 2131
	if spanY <= halfH * 2 then -- 2131
		self.cam.y = camY -- 2133
	else -- 2133
		self.cam.y = math.max( -- 2135
			camY, -- 2135
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 2135
		) -- 2135
	end -- 2135
end -- 2119
function Play.prototype.flashSet(self, text, t) -- 2139
	self.flash = text -- 2140
	self.flashT = t -- 2141
end -- 2139
function Play.prototype.statusText(self) -- 2145
	local p = self.player -- 2146
	local parts = {} -- 2147
	local who = self.childMode and "小满" or "周戍" -- 2148
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 2149
	if self.room.key == "prologue" then -- 2149
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2152
		if self.phase == "prologue-wait" then -- 2152
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 2154
		elseif self.phase == "prologue-give" then -- 2154
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 2156
		else -- 2156
			parts[#parts + 1] = "跟随" -- 2158
		end -- 2158
		if self.paused then -- 2158
			parts[#parts + 1] = "已暂停" -- 2161
		end -- 2161
		return table.concat(parts, " · ") -- 2163
	end -- 2163
	if self.room.key == "street" then -- 2163
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2166
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2167
		if self.paused then -- 2167
			parts[#parts + 1] = "已暂停" -- 2169
		end -- 2169
		return table.concat(parts, " · ") -- 2171
	end -- 2171
	if self.room.key == "gate" then -- 2171
		local ____temp_19 -- 2174
		if self.room.story == nil then -- 2174
			____temp_19 = nil -- 2174
		else -- 2174
			____temp_19 = self.room.story.gate -- 2174
		end -- 2174
		local g = ____temp_19 -- 2174
		if g ~= nil then -- 2174
			parts[#parts + 1] = self:gateLabel() -- 2176
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 2177
				0, -- 2178
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 2178
			))) .. " 秒" -- 2178
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2179
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2180
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 2181
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 2182
			if self.gateFailCount > 0 then -- 2182
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 2184
			end -- 2184
			if self.flash ~= "" then -- 2184
				parts[#parts + 1] = self.flash -- 2187
			end -- 2187
		end -- 2187
		if self.paused then -- 2187
			parts[#parts + 1] = "已暂停" -- 2191
		end -- 2191
		return table.concat(parts, " · ") -- 2193
	end -- 2193
	if self.room.key == "forest" then -- 2193
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2196
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 2197
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 2198
		if self.caughtT > 0 then -- 2198
			parts[#parts + 1] = "复位中" -- 2200
		end -- 2200
		if self.paused then -- 2200
			parts[#parts + 1] = "已暂停" -- 2203
		end -- 2203
		return table.concat(parts, " · ") -- 2205
	end -- 2205
	if self.room.key == "tower" then -- 2205
		if self.phase == "tower-wait" then -- 2205
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 2209
		elseif self.phase == "tower-knock" then -- 2209
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 2211
		elseif self.phase == "tower-given" then -- 2211
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 2213
		else -- 2213
			parts[#parts + 1] = "片尾" -- 2215
		end -- 2215
		if self.paused then -- 2215
			parts[#parts + 1] = "已暂停" -- 2218
		end -- 2218
		return table.concat(parts, " · ") -- 2220
	end -- 2220
	if self.room.key == "village" then -- 2220
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2223
		if self.hasBottle then -- 2223
			parts[#parts + 1] = "有瓶" -- 2225
		elseif self.bottleFly ~= nil then -- 2225
			parts[#parts + 1] = "瓶在飞" -- 2227
		else -- 2227
			parts[#parts + 1] = "空手" -- 2229
		end -- 2229
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 2231
		if self.scavChase then -- 2231
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 2233
		end -- 2233
		if self.passed then -- 2233
			parts[#parts + 1] = "已过通行线" -- 2236
		end -- 2236
		if self.paused then -- 2236
			parts[#parts + 1] = "已暂停" -- 2239
		end -- 2239
		return table.concat(parts, " · ") -- 2241
	end -- 2241
	local isChild = self.childMode -- 2244
	if isChild then -- 2244
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2246
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 2247
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2248
	else -- 2248
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 2250
		if p.rollT > 0 then -- 2250
			parts[#parts + 1] = "翻滚中" -- 2252
		end -- 2252
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2254
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2255
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 2256
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 2257
	end -- 2257
	if self.checkpoint >= 0 then -- 2257
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 2260
	end -- 2260
	if self.paused then -- 2260
		parts[#parts + 1] = "已暂停" -- 2263
	end -- 2263
	return table.concat(parts, " · ") -- 2265
end -- 2145
function Play.prototype.aliveEnemies(self) -- 2269
	local n = 0 -- 2270
	local i = 0 -- 2271
	do -- 2271
		i = 0 -- 2272
		while i < #self.enemies do -- 2272
			if self.enemies[i + 1].alive then -- 2272
				n = n + 1 -- 2274
			end -- 2274
			i = i + 1 -- 2272
		end -- 2272
	end -- 2272
	return n -- 2277
end -- 2269
function Play.prototype.threatened(self) -- 2282
	do -- 2282
		local i = 0 -- 2283
		while i < #self.enemies do -- 2283
			local e = self.enemies[i + 1] -- 2284
			if e.alive and e.warnT > 0 then -- 2284
				return true -- 2286
			end -- 2286
			i = i + 1 -- 2283
		end -- 2283
	end -- 2283
	return false -- 2289
end -- 2282
function Play.prototype.gateSecondsLeft(self) -- 2292
	local ____temp_20 -- 2293
	if self.room.story == nil then -- 2293
		____temp_20 = nil -- 2293
	else -- 2293
		____temp_20 = self.room.story.gate -- 2293
	end -- 2293
	local g = ____temp_20 -- 2293
	if g == nil then -- 2293
		return 0 -- 2295
	end -- 2295
	return math.max( -- 2297
		0, -- 2297
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 2297
	) -- 2297
end -- 2292
function Play.prototype.gateLabel(self) -- 2300
	if self.phase == "gate-idle" then -- 2300
		return "待就位" -- 2302
	end -- 2302
	if self.phase == "gate-hold" then -- 2302
		return "守点中" -- 2305
	end -- 2305
	if self.phase == "gate-send" then -- 2305
		return "送别" -- 2308
	end -- 2308
	if self.phase == "gate-count" then -- 2308
		return "数数 " .. tostring(self.countTick) -- 2311
	end -- 2311
	return "她走" -- 2313
end -- 2300
function Play.prototype.dogLabel(self) -- 2317
	if self.dogState == "ear" then -- 2317
		return "转耳" -- 2319
	end -- 2319
	if self.dogState == "chase" then -- 2319
		return "追" -- 2322
	end -- 2322
	if self.dogState == "sniff" then -- 2322
		return "停" -- 2325
	end -- 2325
	if self.dogState == "back" then -- 2325
		return "回线" -- 2328
	end -- 2328
	return "巡逻" -- 2330
end -- 2317
function Play.prototype.doorXOf(self) -- 2333
	local ____temp_21 -- 2334
	if self.room.story == nil then -- 2334
		____temp_21 = nil -- 2334
	else -- 2334
		____temp_21 = self.room.story.tower -- 2334
	end -- 2334
	local t = ____temp_21 -- 2334
	return t == nil and 0 or t.doorX -- 2335
end -- 2333
function Play.prototype.scavLabel(self) -- 2339
	if self.scavState == "chase" then -- 2339
		return "追" -- 2341
	end -- 2341
	if self.scavState == "turn" then -- 2341
		return "转头" -- 2344
	end -- 2344
	if self.scavState == "walk" then -- 2344
		return "赶来" -- 2347
	end -- 2347
	if self.scavState == "stall" then -- 2347
		return "停住" -- 2350
	end -- 2350
	if self.scavState == "back" then -- 2350
		return "回位" -- 2353
	end -- 2353
	return "巡逻" -- 2355
end -- 2339
function Play.prototype.hintText(self) -- 2359
	if self.paused then -- 2359
		return "Esc 继续 · R 重置" -- 2361
	end -- 2361
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 2361
		if self:threatened() then -- 2361
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 2367
		end -- 2367
		if self.coverHug then -- 2367
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 2370
		end -- 2370
		if self.coverNear then -- 2370
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 2373
		end -- 2373
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 2375
	end -- 2375
	if self.flash ~= "" then -- 2375
		return self.flash -- 2378
	end -- 2378
	if self.room.key == "prologue" then -- 2378
		if self.phase == "prologue-wait" then -- 2378
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 2382
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 2383
		end -- 2383
		if self.phase == "prologue-give" then -- 2383
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 2386
		end -- 2386
		return "她跟着你了 · 两人一起走到门口 680" -- 2388
	end -- 2388
	if self.room.key == "street" then -- 2388
		if self:aliveEnemies() > 0 then -- 2388
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 2392
		end -- 2392
		return "清完了 · 两人一起走到右边检查站入口 900" -- 2394
	end -- 2394
	if self.room.key == "gate" then -- 2394
		local ____temp_22 -- 2397
		if self.room.story == nil then -- 2397
			____temp_22 = nil -- 2397
		else -- 2397
			____temp_22 = self.room.story.gate -- 2397
		end -- 2397
		local g = ____temp_22 -- 2397
		if g ~= nil then -- 2397
			if self.phase == "gate-idle" then -- 2397
				if self.gateNeedConfirm then -- 2397
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 2401
				end -- 2401
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 2403
			end -- 2403
			if self.phase == "gate-hold" then -- 2403
				if self.coveredFlash > 0 then -- 2403
					return "掩体挡下了这一枪 · 别露头" -- 2407
				end -- 2407
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 2409
			end -- 2409
			if self.phase == "gate-send" then -- 2409
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 2412
			end -- 2412
			if self.phase == "gate-count" then -- 2412
				if self.countTick >= 1440 then -- 2412
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 2416
				end -- 2416
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 2418
			end -- 2418
			return "她自己走 · 跟着出城门 1120" -- 2420
		end -- 2420
	end -- 2420
	if self.room.key == "forest" then -- 2420
		if self.dogState == "chase" then -- 2420
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 2425
		end -- 2425
		if self.dogState == "ear" then -- 2425
			return "狗转耳朵了 · 停下或蹲下别出声" -- 2428
		end -- 2428
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 2430
	end -- 2430
	if self.room.key == "tower" then -- 2430
		if self.phase == "tower-wait" then -- 2430
			return "走到门前 445 点一次 E 敲两下" -- 2434
		end -- 2434
		if self.phase == "tower-knock" then -- 2434
			return "敲两下 · 等门开" -- 2437
		end -- 2437
		if self.phase == "tower-given" then -- 2437
			return "递交针套和纸条 · 看登记簿最后一行" -- 2440
		end -- 2440
		return "片尾 · 点 E 再玩一次，回到序章" -- 2442
	end -- 2442
	if self.room.key == "village" then -- 2442
		if self.bottleFly ~= nil then -- 2442
			return "等瓶子落地 · 触地才发声" -- 2446
		end -- 2446
		if self.hasBottle then -- 2446
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 2449
		end -- 2449
		if self.passed then -- 2449
			return "已过第一院 · R 重置可再来一遍" -- 2452
		end -- 2452
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 2454
	end -- 2454
	if self.room.key == "outside" then -- 2454
		if self.focusCart then -- 2454
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 2458
		end -- 2458
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 2460
	end -- 2460
	if self.escort.state == "frozen" then -- 2460
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 2460
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 2464
		end -- 2464
		return "小满吓住了 · 走过去，靠近再点 E" -- 2466
	end -- 2466
	if self.escort.state == "calming" then -- 2466
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 2469
	end -- 2469
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 2471
end -- 2359
function Play.prototype.draw(self, draw, w, h) -- 2476
	self.viewW = w -- 2477
	self.viewH = h -- 2478
	self.view = ____exports.computeViewport(w, h) -- 2479
	self:clampCamera(w, h) -- 2480
	draw:clear() -- 2481
	draw:drawRect( -- 2483
		Rect(0, 0, w, h), -- 2483
		BG_VOID -- 2483
	) -- 2483
	local box = self:canvasRect(w, h) -- 2484
	draw:drawRect(box, BG_FAR) -- 2485
	draw:drawRect( -- 2486
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 2486
		BG_MID -- 2486
	) -- 2486
	self:drawFloors(draw, w, h) -- 2488
	self:drawSolids(draw, w, h) -- 2489
	self:drawZones(draw, w, h) -- 2490
	self:drawArch(draw, w, h) -- 2491
	self:drawCart(draw, w, h) -- 2492
	self:drawActors(draw, w, h) -- 2493
	self:drawTrace(draw, w, h) -- 2494
	self:drawAim(draw, w, h) -- 2495
end -- 2476
function Play.prototype.canvasRect(self, w, h) -- 2499
	local v = self.view -- 2500
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 2501
end -- 2499
function Play.prototype.px(self, n) -- 2505
	return n * self.view.zoom -- 2506
end -- 2505
function Play.prototype.sx(self, wx, w) -- 2510
	local v = self.view -- 2511
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 2512
	return v.ox + lx * v.zoom -- 2513
end -- 2510
function Play.prototype.sy(self, wy, h) -- 2517
	local v = self.view -- 2518
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 2519
	return v.oy + ly * v.zoom -- 2520
end -- 2517
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 2523
	local px0 = self:sx(x0, w) -- 2524
	local px1 = self:sx(x1, w) -- 2525
	local py0 = self:sy(y0, h) -- 2526
	local py1 = self:sy(y1, h) -- 2527
	if px1 <= px0 or py1 <= py0 then -- 2527
		return -- 2529
	end -- 2529
	draw:drawRect( -- 2531
		Rect(px0, py0, px1 - px0, py1 - py0), -- 2531
		color -- 2531
	) -- 2531
end -- 2523
function Play.prototype.drawFloors(self, draw, w, h) -- 2534
	local i = 0 -- 2535
	do -- 2535
		i = 0 -- 2536
		while i < #self.room.floors do -- 2536
			local f = self.room.floors[i + 1] -- 2537
			local ____temp_23 -- 2538
			if f.y == 0 then -- 2538
				____temp_23 = self.room.depth -- 2538
			else -- 2538
				____temp_23 = nil -- 2538
			end -- 2538
			local road = ____temp_23 -- 2538
			local y = self:sy(f.y + (road and road.min or 0), h) -- 2539
			local x0 = self:sx(f.x0, w) -- 2540
			local x1 = self:sx(f.x1, w) -- 2541
			local deck = self:px(5) -- 2542
			if road ~= nil then -- 2542
				local back = self:sy(f.y + road.max, h) -- 2544
				draw:drawRect( -- 2545
					Rect(x0, y, x1 - x0, back - y), -- 2545
					FLOOR_DECK, -- 2545
					self:px(1), -- 2545
					SOLID_EDGE -- 2545
				) -- 2545
			end -- 2545
			draw:drawRect( -- 2547
				Rect(x0, y - deck, x1 - x0, deck), -- 2547
				FLOOR_DECK -- 2547
			) -- 2547
			draw:drawSegment( -- 2548
				Vec2(x0, y), -- 2548
				Vec2(x1, y), -- 2548
				self:px(1), -- 2548
				GROUND -- 2548
			) -- 2548
			i = i + 1 -- 2536
		end -- 2536
	end -- 2536
end -- 2534
function Play.prototype.drawSolids(self, draw, w, h) -- 2552
	local i = 0 -- 2553
	do -- 2553
		i = 0 -- 2554
		while i < #self.boxes do -- 2554
			do -- 2554
				local b = self.boxes[i + 1] -- 2555
				if b.y0 < -4 and b.y1 <= 96 then -- 2555
					draw:drawSegment( -- 2558
						Vec2( -- 2558
							self:sx(b.x0, w), -- 2558
							self:sy(b.y1, h) -- 2558
						), -- 2558
						Vec2( -- 2558
							self:sx(b.x1, w), -- 2558
							self:sy(b.y1, h) -- 2558
						), -- 2558
						self:px(1), -- 2558
						GROUND -- 2558
					) -- 2558
					goto __continue488 -- 2559
				end -- 2559
				local ____opt_26 = b.depth -- 2559
				local front = ____opt_26 and ____opt_26.min or 0 -- 2561
				local ____opt_28 = b.depth -- 2561
				local back = ____opt_28 and ____opt_28.max or 0 -- 2562
				self:drawBox( -- 2563
					draw, -- 2563
					w, -- 2563
					h, -- 2563
					b.x0, -- 2563
					b.x1, -- 2563
					b.y0 + front, -- 2563
					b.y1 + back, -- 2563
					SOLID_FILL -- 2563
				) -- 2563
				draw:drawSegment( -- 2564
					Vec2( -- 2564
						self:sx(b.x0, w), -- 2564
						self:sy(b.y1 + front, h) -- 2564
					), -- 2564
					Vec2( -- 2565
						self:sx(b.x1, w), -- 2565
						self:sy(b.y1 + front, h) -- 2565
					), -- 2565
					self:px(1), -- 2565
					SOLID_EDGE -- 2565
				) -- 2565
			end -- 2565
			::__continue488:: -- 2565
			i = i + 1 -- 2554
		end -- 2554
	end -- 2554
end -- 2552
function Play.prototype.drawZones(self, draw, w, h) -- 2569
	local i = 0 -- 2570
	do -- 2570
		i = 0 -- 2571
		while i < #self.room.zones do -- 2571
			local z = self.room.zones[i + 1] -- 2572
			local fill = DANGER -- 2573
			local line = DANGER_LINE -- 2574
			if z.tint == 2 then -- 2574
				fill = SOFT -- 2576
				line = SOFT_LINE -- 2577
			elseif z.tint == 3 then -- 2577
				fill = BRICK -- 2579
				line = BRICK_LINE -- 2580
			elseif z.tint == 4 then -- 2580
				fill = PASS -- 2582
				line = PASS_LINE -- 2583
			end -- 2583
			self:drawBox( -- 2585
				draw, -- 2585
				w, -- 2585
				h, -- 2585
				z.x0, -- 2585
				z.x1, -- 2585
				z.y, -- 2585
				z.y + z.h, -- 2585
				fill -- 2585
			) -- 2585
			draw:drawSegment( -- 2586
				Vec2( -- 2586
					self:sx(z.x0, w), -- 2586
					self:sy(z.y, h) -- 2586
				), -- 2586
				Vec2( -- 2586
					self:sx(z.x0, w), -- 2586
					self:sy(z.y + z.h, h) -- 2586
				), -- 2586
				self:px(1), -- 2586
				line -- 2586
			) -- 2586
			draw:drawSegment( -- 2587
				Vec2( -- 2587
					self:sx(z.x1, w), -- 2587
					self:sy(z.y, h) -- 2587
				), -- 2587
				Vec2( -- 2587
					self:sx(z.x1, w), -- 2587
					self:sy(z.y + z.h, h) -- 2587
				), -- 2587
				self:px(1), -- 2587
				line -- 2587
			) -- 2587
			i = i + 1 -- 2571
		end -- 2571
	end -- 2571
end -- 2569
function Play.prototype.drawArch(self, draw, w, h) -- 2591
	local a = self.room.arch -- 2592
	if a.h <= 0 then -- 2592
		return -- 2594
	end -- 2594
	self:drawBox( -- 2596
		draw, -- 2596
		w, -- 2596
		h, -- 2596
		a.x0, -- 2596
		a.x1, -- 2596
		a.y, -- 2596
		a.y + a.h, -- 2596
		HOLE_FILL -- 2596
	) -- 2596
	draw:drawSegment( -- 2597
		Vec2( -- 2597
			self:sx(a.x0, w), -- 2597
			self:sy(a.y + a.h, h) -- 2597
		), -- 2597
		Vec2( -- 2597
			self:sx(a.x1, w), -- 2597
			self:sy(a.y + a.h, h) -- 2597
		), -- 2597
		self:px(1), -- 2597
		SOLID_EDGE -- 2597
	) -- 2597
	draw:drawSegment( -- 2598
		Vec2( -- 2598
			self:sx(a.x0, w), -- 2598
			self:sy(a.y, h) -- 2598
		), -- 2598
		Vec2( -- 2598
			self:sx(a.x0, w), -- 2598
			self:sy(a.y + a.h, h) -- 2598
		), -- 2598
		self:px(1), -- 2598
		SOLID_EDGE -- 2598
	) -- 2598
	draw:drawSegment( -- 2599
		Vec2( -- 2599
			self:sx(a.x1, w), -- 2599
			self:sy(a.y, h) -- 2599
		), -- 2599
		Vec2( -- 2599
			self:sx(a.x1, w), -- 2599
			self:sy(a.y + a.h, h) -- 2599
		), -- 2599
		self:px(1), -- 2599
		SOLID_EDGE -- 2599
	) -- 2599
end -- 2591
function Play.prototype.drawCart(self, draw, w, h) -- 2602
	local c = self.room.cart -- 2603
	if c.bodyW <= 0 then -- 2603
		return -- 2605
	end -- 2605
	drawCartShape( -- 2607
		draw, -- 2607
		self, -- 2607
		w, -- 2607
		h, -- 2607
		c, -- 2607
		self.cartAxle -- 2607
	) -- 2607
	draw:drawRect( -- 2608
		Rect( -- 2608
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 2608
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 2608
			self:px(2), -- 2608
			self:px(40) -- 2608
		), -- 2608
		STAND -- 2608
	) -- 2608
end -- 2602
function Play.prototype.drawActors(self, draw, w, h) -- 2611
	local p = self.player -- 2612
	local isChild = self.childMode -- 2613
	local footY = p.y + p.depth -- 2614
	if p.covered then -- 2614
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 2617
		draw:drawSegment( -- 2618
			Vec2( -- 2618
				self:sx(edge, w), -- 2618
				self:sy(footY + 8, h) -- 2618
			), -- 2618
			Vec2( -- 2618
				self:sx(edge, w), -- 2618
				self:sy(footY + p.h * 0.62, h) -- 2618
			), -- 2618
			self:px(2), -- 2618
			STAND -- 2618
		) -- 2618
		draw:drawSegment( -- 2620
			Vec2( -- 2620
				self:sx(p.x - 8, w), -- 2620
				self:sy(footY + p.h + 3, h) -- 2620
			), -- 2620
			Vec2( -- 2620
				self:sx(p.x + 8, w), -- 2620
				self:sy(footY + p.h + 3, h) -- 2620
			), -- 2620
			self:px(2), -- 2620
			STAND -- 2620
		) -- 2620
	elseif self.coverNear and not isChild then -- 2620
		draw:drawRect( -- 2623
			Rect( -- 2623
				self:sx(p.x - 3, w), -- 2623
				self:sy(footY + 1, h), -- 2623
				self:px(3), -- 2623
				self:px(3) -- 2623
			), -- 2623
			STAND -- 2623
		) -- 2623
	end -- 2623
	drawFigure( -- 2625
		draw, -- 2625
		self, -- 2625
		w, -- 2625
		h, -- 2625
		p, -- 2625
		isChild and CHILD_BODY or SOLDIER_BODY, -- 2625
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 2625
	) -- 2625
	local q = self.partner -- 2626
	if q.alive then -- 2626
		local childPartner = q.w == CHILD_W -- 2628
		drawFigure( -- 2629
			draw, -- 2629
			self, -- 2629
			w, -- 2629
			h, -- 2629
			q, -- 2629
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 2629
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 2629
		) -- 2629
	end -- 2629
	local i = 0 -- 2631
	do -- 2631
		i = 0 -- 2632
		while i < #self.enemies do -- 2632
			local e = self.enemies[i + 1] -- 2633
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 2634
			local enemyY = e.y + (e.depth or 0) -- 2635
			self:drawBox( -- 2636
				draw, -- 2636
				w, -- 2636
				h, -- 2636
				e.x - e.w / 2, -- 2636
				e.x + e.w / 2, -- 2636
				enemyY, -- 2636
				enemyY + e.h, -- 2636
				col -- 2636
			) -- 2636
			if e.alive and e.warnT > 0 then -- 2636
				local gunX = self:sx(e.x, w) -- 2639
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 2640
				local aimX = self:sx(p.x, w) -- 2641
				local aimY = self:sy(footY + p.h * 0.55, h) -- 2642
				local seg = 8 -- 2643
				local s = 0 -- 2644
				do -- 2644
					s = 0 -- 2645
					while s < seg do -- 2645
						local t0 = s / seg -- 2646
						local t1 = (s + 1) / seg -- 2647
						draw:drawSegment( -- 2648
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 2649
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 2650
							self:px(1), -- 2651
							DANGER -- 2651
						) -- 2651
						s = s + 2 -- 2645
					end -- 2645
				end -- 2645
			end -- 2645
			i = i + 1 -- 2632
		end -- 2632
	end -- 2632
	local k = 0 -- 2656
	do -- 2656
		k = 0 -- 2657
		while k < #self.room.marks do -- 2657
			do -- 2657
				local m = self.room.marks[k + 1] -- 2658
				if m.kind ~= 0 then -- 2658
					goto __continue510 -- 2660
				end -- 2660
				local on = self.checkpoint == m.x -- 2662
				local x = self:sx(m.x, w) -- 2663
				local y = self:sy(m.y, h) -- 2664
				draw:drawSegment( -- 2665
					Vec2(x, y), -- 2665
					Vec2( -- 2665
						x, -- 2665
						y + self:px(35) -- 2665
					), -- 2665
					self:px(1), -- 2665
					on and CHECK or INK_DIM -- 2665
				) -- 2665
				draw:drawDot( -- 2666
					Vec2( -- 2666
						x, -- 2666
						y + self:px(35) -- 2666
					), -- 2666
					self:px(2), -- 2666
					on and CHECK or INK_DIM -- 2666
				) -- 2666
			end -- 2666
			::__continue510:: -- 2666
			k = k + 1 -- 2657
		end -- 2657
	end -- 2657
	local j = 0 -- 2670
	do -- 2670
		j = 0 -- 2671
		while j < #self.room.marks do -- 2671
			do -- 2671
				local m = self.room.marks[j + 1] -- 2672
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 2672
					goto __continue513 -- 2674
				end -- 2674
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 2674
					goto __continue513 -- 2678
				end -- 2678
				local col = STAND -- 2680
				if m.kind == 4 then -- 2680
					col = PASS_LINE -- 2682
				elseif m.kind == 5 then -- 2682
					col = BRICK_LINE -- 2684
				end -- 2684
				local mx = self:sx(m.x, w) -- 2686
				local my = self:sy(m.y, h) -- 2687
				draw:drawSegment( -- 2688
					Vec2(mx, my), -- 2688
					Vec2( -- 2688
						mx, -- 2688
						my + self:px(24) -- 2688
					), -- 2688
					self:px(1), -- 2688
					col -- 2688
				) -- 2688
			end -- 2688
			::__continue513:: -- 2688
			j = j + 1 -- 2671
		end -- 2671
	end -- 2671
	local t = 0 -- 2691
	do -- 2691
		t = 0 -- 2692
		while t < #self.room.marks do -- 2692
			do -- 2692
				local m = self.room.marks[t + 1] -- 2693
				if m.kind ~= 6 then -- 2693
					goto __continue519 -- 2695
				end -- 2695
				local mx = self:sx(m.x, w) -- 2697
				local my = self:sy(m.y, h) -- 2698
				draw:drawSegment( -- 2699
					Vec2(mx, my), -- 2699
					Vec2( -- 2699
						mx, -- 2699
						my + self:px(30) -- 2699
					), -- 2699
					self:px(1), -- 2699
					INK_DIM -- 2699
				) -- 2699
				self:drawBox( -- 2700
					draw, -- 2700
					w, -- 2700
					h, -- 2700
					m.x - 5, -- 2700
					m.x + 5, -- 2700
					m.y + 30, -- 2700
					m.y + 40, -- 2700
					CHECK -- 2700
				) -- 2700
			end -- 2700
			::__continue519:: -- 2700
			t = t + 1 -- 2692
		end -- 2692
	end -- 2692
	if self.room.key == "village" then -- 2692
		self:drawVillage(draw, w, h) -- 2703
	end -- 2703
	if self.room.key == "forest" then -- 2703
		self:drawDog(draw, w, h) -- 2706
	end -- 2706
end -- 2611
function Play.prototype.drawDog(self, draw, w, h) -- 2711
	local x = self.dogX -- 2712
	self:drawBox( -- 2713
		draw, -- 2713
		w, -- 2713
		h, -- 2713
		x - 14, -- 2713
		x + 14, -- 2713
		0, -- 2713
		20, -- 2713
		SCAV_BODY -- 2713
	) -- 2713
	self:drawBox( -- 2714
		draw, -- 2714
		w, -- 2714
		h, -- 2714
		x - 10, -- 2714
		x - 2, -- 2714
		20, -- 2714
		30, -- 2714
		SCAV_BODY -- 2714
	) -- 2714
	self:drawBox( -- 2715
		draw, -- 2715
		w, -- 2715
		h, -- 2715
		x + 2, -- 2715
		x + 10, -- 2715
		20, -- 2715
		30, -- 2715
		SCAV_HEAD -- 2715
	) -- 2715
	if self.dogState == "ear" or self.dogState == "chase" then -- 2715
		draw:drawSegment( -- 2717
			Vec2( -- 2717
				self:sx(x, w), -- 2717
				self:sy(30, h) -- 2717
			), -- 2717
			Vec2( -- 2718
				self:sx(x, w), -- 2718
				self:sy(40, h) -- 2718
			), -- 2718
			self:px(1), -- 2718
			DANGER -- 2718
		) -- 2718
	end -- 2718
end -- 2711
function Play.prototype.drawVillage(self, draw, w, h) -- 2723
	local bottle = self.room.bottle -- 2724
	if bottle ~= nil then -- 2724
		self:drawBox( -- 2726
			draw, -- 2726
			w, -- 2726
			h, -- 2726
			bottle.x - 14, -- 2726
			bottle.x + 14, -- 2726
			0, -- 2726
			64, -- 2726
			SOLID_FILL -- 2726
		) -- 2726
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 2726
			self:drawBottle( -- 2728
				draw, -- 2728
				w, -- 2728
				h, -- 2728
				bottle.x, -- 2728
				64 -- 2728
			) -- 2728
		end -- 2728
	end -- 2728
	self:drawBox( -- 2732
		draw, -- 2732
		w, -- 2732
		h, -- 2732
		300, -- 2732
		420, -- 2732
		44, -- 2732
		50, -- 2732
		FLOOR_DECK -- 2732
	) -- 2732
	self:drawBox( -- 2733
		draw, -- 2733
		w, -- 2733
		h, -- 2733
		300, -- 2733
		306, -- 2733
		0, -- 2733
		44, -- 2733
		FLOOR_DECK -- 2733
	) -- 2733
	self:drawBox( -- 2734
		draw, -- 2734
		w, -- 2734
		h, -- 2734
		414, -- 2734
		420, -- 2734
		0, -- 2734
		44, -- 2734
		FLOOR_DECK -- 2734
	) -- 2734
	local s = self.room.scavenger -- 2736
	if s ~= nil then -- 2736
		local sx0 = self.scavX -- 2738
		self:drawBox( -- 2739
			draw, -- 2739
			w, -- 2739
			h, -- 2739
			sx0 - 12, -- 2739
			sx0 + 12, -- 2739
			0, -- 2739
			s.h - 14, -- 2739
			SCAV_BODY -- 2739
		) -- 2739
		self:drawBox( -- 2740
			draw, -- 2740
			w, -- 2740
			h, -- 2740
			sx0 - 7, -- 2740
			sx0 + 7, -- 2740
			s.h - 14, -- 2740
			s.h, -- 2740
			SCAV_HEAD -- 2740
		) -- 2740
		if self.scavState == "turn" then -- 2740
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 2742
			draw:drawSegment( -- 2743
				Vec2( -- 2743
					self:sx(sx0, w), -- 2743
					self:sy(s.h - 6, h) -- 2743
				), -- 2743
				Vec2( -- 2743
					self:sx(fx, w), -- 2743
					self:sy(s.h - 6, h) -- 2743
				), -- 2743
				self:px(1), -- 2743
				INK -- 2743
			) -- 2743
		end -- 2743
	end -- 2743
	if self.hasBottle then -- 2743
		local p = self.player -- 2748
		self:drawBottle( -- 2749
			draw, -- 2749
			w, -- 2749
			h, -- 2749
			p.x + p.facing * 10, -- 2749
			p.y + p.h * 0.62 -- 2749
		) -- 2749
	end -- 2749
	if self.bottleFly ~= nil then -- 2749
		self:drawBottle( -- 2752
			draw, -- 2752
			w, -- 2752
			h, -- 2752
			self.bottleFly.x, -- 2752
			self.bottleFly.y -- 2752
		) -- 2752
	end -- 2752
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 2752
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 2755
		draw:drawCircle( -- 2756
			Vec2( -- 2756
				self:sx(self.bottleLandX, w), -- 2756
				self:sy(0, h) -- 2756
			), -- 2756
			self:px(r / ____exports.UNITS_PER_PX), -- 2756
			BRICK_LINE -- 2756
		) -- 2756
	end -- 2756
end -- 2723
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 2760
	self:drawBox( -- 2761
		draw, -- 2761
		w, -- 2761
		h, -- 2761
		x - 3, -- 2761
		x + 3, -- 2761
		y - 10, -- 2761
		y, -- 2761
		BOTTLE -- 2761
	) -- 2761
end -- 2760
function Play.prototype.drawTrace(self, draw, w, h) -- 2764
	local t = self.trace -- 2765
	if t == nil or self.traceT <= 0 then -- 2765
		return -- 2767
	end -- 2767
	draw:drawSegment( -- 2769
		Vec2( -- 2770
			self:sx(t.x0, w), -- 2770
			self:sy(t.y0, h) -- 2770
		), -- 2770
		Vec2( -- 2771
			self:sx(t.x1, w), -- 2771
			self:sy(t.y1, h) -- 2771
		), -- 2771
		self:px(1), -- 2772
		t.hit and AIM_HIT or INK_DIM -- 2772
	) -- 2772
end -- 2764
function Play.prototype.drawAim(self, draw, w, h) -- 2775
	local v = self.view -- 2777
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 2778
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 2779
	local dot = self:px(1) -- 2780
	local arm = self:px(3) -- 2781
	local gap = self:px(1) -- 2782
	draw:drawSegment( -- 2783
		Vec2(gx - arm - gap, gy), -- 2783
		Vec2(gx - gap, gy), -- 2783
		dot / 2, -- 2783
		AIM -- 2783
	) -- 2783
	draw:drawSegment( -- 2784
		Vec2(gx + gap, gy), -- 2784
		Vec2(gx + arm + gap, gy), -- 2784
		dot / 2, -- 2784
		AIM -- 2784
	) -- 2784
	draw:drawSegment( -- 2785
		Vec2(gx, gy - arm - gap), -- 2785
		Vec2(gx, gy - gap), -- 2785
		dot / 2, -- 2785
		AIM -- 2785
	) -- 2785
	draw:drawSegment( -- 2786
		Vec2(gx, gy + gap), -- 2786
		Vec2(gx, gy + arm + gap), -- 2786
		dot / 2, -- 2786
		AIM -- 2786
	) -- 2786
	if self.room.key == "village" and self.hasBottle then -- 2786
		local p = self.player -- 2790
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2792
		local dir = ____end.x >= p.x and 1 or -1 -- 2793
		local x0 = p.x + dir * 10 -- 2794
		local y0 = p.y + p.h * 0.7 -- 2795
		local T = BOTTLE_FLY_TIME -- 2796
		local vx = (____end.x - x0) / T -- 2797
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 2798
		local pxr = x0 -- 2799
		local pyr = y0 -- 2800
		local t = 1 -- 2801
		do -- 2801
			t = 1 -- 2802
			while t <= 12 do -- 2802
				local tt = t / 12 * T -- 2803
				local nx = x0 + vx * tt -- 2804
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 2805
				draw:drawSegment( -- 2806
					Vec2( -- 2806
						self:sx(pxr, w), -- 2806
						self:sy(pyr, h) -- 2806
					), -- 2806
					Vec2( -- 2806
						self:sx(nx, w), -- 2806
						self:sy(ny, h) -- 2806
					), -- 2806
					self:px(1) / 2, -- 2806
					BOTTLE -- 2806
				) -- 2806
				pxr = nx -- 2807
				pyr = ny -- 2808
				t = t + 1 -- 2802
			end -- 2802
		end -- 2802
		draw:drawCircle( -- 2810
			Vec2( -- 2810
				self:sx(____end.x, w), -- 2810
				self:sy(____end.y + 2, h) -- 2810
			), -- 2810
			self:px(2), -- 2810
			BOTTLE -- 2810
		) -- 2810
	end -- 2810
end -- 2775
return ____exports -- 2775