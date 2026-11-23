-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local makeActor, drawFigure, hitBox, drawCartShape, CHILD_W, CHILD_H, SOLDIER_W, SOLDIER_H, INK, CART_FILL, CLOTH -- 1
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
function makeActor(room, index) -- 2466
	local sp = room.spawns -- 2467
	if index < 0 or index >= #sp then -- 2467
		return { -- 2469
			x = 0, -- 2469
			y = 0, -- 2469
			vx = 0, -- 2469
			vy = 0, -- 2469
			w = CHILD_W, -- 2469
			h = CHILD_H, -- 2469
			onGround = true, -- 2469
			facing = 1, -- 2469
			crouch = false, -- 2469
			rollT = 0, -- 2469
			covered = false, -- 2469
			alive = false -- 2469
		} -- 2469
	end -- 2469
	local s = sp[index + 1] -- 2471
	local child = s.h <= CHILD_H -- 2472
	return { -- 2473
		x = s.x, -- 2474
		y = s.y, -- 2474
		vx = 0, -- 2474
		vy = 0, -- 2474
		w = child and CHILD_W or SOLDIER_W, -- 2475
		h = child and CHILD_H or SOLDIER_H, -- 2476
		onGround = true, -- 2477
		facing = 1, -- 2477
		crouch = false, -- 2477
		rollT = 0, -- 2477
		covered = false, -- 2477
		alive = true -- 2477
	} -- 2477
end -- 2477
function drawFigure(draw, play, w, h, a, body, head) -- 2481
	if not a.alive then -- 2481
		return -- 2483
	end -- 2483
	local x0 = a.x - a.w / 2 -- 2485
	local x1 = a.x + a.w / 2 -- 2486
	local y0 = a.y -- 2487
	local y1 = a.y + a.h -- 2488
	play:drawBox( -- 2489
		draw, -- 2489
		w, -- 2489
		h, -- 2489
		x0, -- 2489
		x1, -- 2489
		y0, -- 2489
		y1 - a.h * 0.26, -- 2489
		body -- 2489
	) -- 2489
	play:drawBox( -- 2490
		draw, -- 2490
		w, -- 2490
		h, -- 2490
		x0 + 2, -- 2490
		x1 - 2, -- 2490
		y1 - a.h * 0.26, -- 2490
		y1, -- 2490
		head -- 2490
	) -- 2490
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 2492
	play:drawBox( -- 2493
		draw, -- 2493
		w, -- 2493
		h, -- 2493
		eyeX, -- 2493
		eyeX + 4, -- 2493
		y1 - a.h * 0.14, -- 2493
		y1 - a.h * 0.08, -- 2493
		INK -- 2493
	) -- 2493
end -- 2493
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 2497
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 2498
end -- 2497
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 2505
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 2506
end -- 2505
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 2513
	local tmin = 0 -- 2514
	local tmax = 99999 -- 2515
	if dx == 0 then -- 2515
		if ox < x0 or ox > x1 then -- 2515
			return -1 -- 2518
		end -- 2518
	else -- 2518
		local t1 = (x0 - ox) / dx -- 2521
		local t2 = (x1 - ox) / dx -- 2522
		local lo = t1 < t2 and t1 or t2 -- 2523
		local hi = t1 < t2 and t2 or t1 -- 2524
		if lo > tmin then -- 2524
			tmin = lo -- 2526
		end -- 2526
		if hi < tmax then -- 2526
			tmax = hi -- 2529
		end -- 2529
	end -- 2529
	if dy == 0 then -- 2529
		if oy < y0 or oy > y1 then -- 2529
			return -1 -- 2534
		end -- 2534
	else -- 2534
		local t1 = (y0 - oy) / dy -- 2537
		local t2 = (y1 - oy) / dy -- 2538
		local lo = t1 < t2 and t1 or t2 -- 2539
		local hi = t1 < t2 and t2 or t1 -- 2540
		if lo > tmin then -- 2540
			tmin = lo -- 2542
		end -- 2542
		if hi < tmax then -- 2542
			tmax = hi -- 2545
		end -- 2545
	end -- 2545
	return tmax >= tmin and tmin or -1 -- 2548
end -- 2548
function drawCartShape(draw, play, w, h, c, axleX) -- 2551
	local half = c.bodyW / 2 -- 2552
	local x0 = axleX - half -- 2553
	local x1 = axleX + half -- 2554
	play:drawBox( -- 2555
		draw, -- 2555
		w, -- 2555
		h, -- 2555
		x0, -- 2555
		x1, -- 2555
		c.baseY + c.wheelR, -- 2555
		c.baseY + c.wheelR + c.bodyH, -- 2555
		CART_FILL -- 2555
	) -- 2555
	draw:drawCircle( -- 2556
		Vec2( -- 2556
			play:sx(x0 + c.bodyW * 0.28, w), -- 2556
			play:sy(c.baseY + c.wheelR, h) -- 2556
		), -- 2556
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2556
		Color(52, 50, 48, 255) -- 2556
	) -- 2556
	draw:drawCircle( -- 2557
		Vec2( -- 2557
			play:sx(x1 - c.bodyW * 0.28, w), -- 2557
			play:sy(c.baseY + c.wheelR, h) -- 2557
		), -- 2557
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2557
		Color(52, 50, 48, 255) -- 2557
	) -- 2557
	local cx = c.clothSide < 0 and x0 or x1 -- 2558
	play:drawBox( -- 2559
		draw, -- 2559
		w, -- 2559
		h, -- 2559
		cx - 10, -- 2559
		cx + 10, -- 2559
		c.baseY + c.wheelR + c.bodyH, -- 2559
		c.baseY + c.wheelR + c.bodyH + 18, -- 2559
		CLOTH -- 2559
	) -- 2559
end -- 2559
____exports.STEP = STEP -- 19
local GRAVITY = 1000 -- 20
CHILD_W = 28 -- 23
CHILD_H = 64 -- 24
local CHILD_CROUCH_H = 36 -- 25
local CHILD_SPEED = 160 -- 26
local CHILD_SLOW = 80 -- 27
local CHILD_JUMP = 320 -- 28
SOLDIER_W = 30 -- 31
SOLDIER_H = 88 -- 32
local SOLDIER_SPEED = 264 -- 33
local ROLL_TIME = 0.35 -- 34
local ROLL_SPEED = 280 -- 35
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 37
local LEDGE_RISE = 60 -- 38
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 41
____exports.LOGIC_H = 180 -- 42
____exports.UNITS_PER_PX = 2 -- 43
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 45
local CAM_FOLLOW = 9 -- 46
local CAM_LOOK_UP = 46 -- 47
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 50
--- 握把触发半径。
local CART_REACH = 70 -- 52
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 54
local CART_CLEAR = 44 -- 55
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 57
local FIRE_COOLDOWN = 150 -- 58
local ENEMY_RANGE = 760 -- 59
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 61
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 63
INK = Color(232, 232, 228, 255) -- 65
local INK_DIM = Color(150, 152, 150, 255) -- 66
local BG_VOID = Color(8, 9, 10, 255) -- 67
local BG_FAR = Color(24, 26, 28, 255) -- 68
local BG_MID = Color(31, 34, 37, 255) -- 69
local GROUND = Color(112, 114, 112, 255) -- 70
local FLOOR_DECK = Color(66, 70, 72, 255) -- 71
local SOLID_FILL = Color(84, 86, 84, 255) -- 72
local SOLID_EDGE = Color(126, 130, 126, 255) -- 73
CART_FILL = Color(122, 78, 56, 255) -- 74
CLOTH = Color(178, 52, 46, 255) -- 75
local DANGER = Color(150, 54, 48, 46) -- 76
local DANGER_LINE = Color(178, 78, 64, 200) -- 77
local HOLE_FILL = Color(10, 11, 12, 255) -- 78
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 79
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 80
local CHILD_BODY = Color(214, 168, 96, 255) -- 81
local CHILD_HEAD = Color(232, 214, 186, 255) -- 82
local ENEMY_BODY = Color(176, 92, 84, 255) -- 83
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 84
local CHECK = Color(96, 186, 122, 255) -- 85
local STAND = Color(226, 186, 84, 255) -- 86
local AIM = Color(236, 236, 232, 230) -- 87
local AIM_HIT = Color(236, 96, 84, 255) -- 88
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 90
local SOFT_LINE = Color(140, 112, 80, 190) -- 91
local BRICK = Color(126, 118, 110, 70) -- 92
local BRICK_LINE = Color(160, 152, 142, 200) -- 93
local PASS = Color(96, 186, 122, 40) -- 94
local PASS_LINE = Color(96, 186, 122, 200) -- 95
local BOTTLE = Color(120, 186, 160, 255) -- 96
local SCAV_BODY = Color(128, 118, 96, 255) -- 97
local SCAV_HEAD = Color(196, 182, 158, 255) -- 98
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 151
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 152
	if zoom < 1 then -- 152
		zoom = 1 -- 154
	end -- 154
	return { -- 156
		zoom = zoom, -- 157
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 158
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 159
	} -- 159
end -- 151
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 173
	if key == "prologue" then -- 173
		return "prologue-wait" -- 175
	end -- 175
	if key == "street" then -- 175
		return "street-run" -- 178
	end -- 178
	if key == "gate" then -- 178
		return "gate-idle" -- 181
	end -- 181
	if key == "forest" then -- 181
		return "forest-run" -- 184
	end -- 184
	if key == "tower" then -- 184
		return "tower-wait" -- 187
	end -- 187
	return "run" -- 189
end -- 173
____exports.Play = __TS__Class() -- 192
local Play = ____exports.Play -- 192
Play.name = "Play" -- 192
function Play.prototype.____constructor(self, room, resume) -- 317
	self.enemies = {} -- 197
	self.boxes = {} -- 198
	self.floors = {} -- 199
	self.checkpoint = -1 -- 201
	self.flash = "" -- 203
	self.flashT = 0 -- 204
	self.traceT = 0 -- 207
	self.focusCart = false -- 209
	self.knocks = 0 -- 211
	self.knockT = 0 -- 212
	self.cartAxle = 0 -- 216
	self.cartDocked = false -- 218
	self.gripping = false -- 220
	self.gateOpen = false -- 222
	self.calmConsumed = false -- 224
	self.nextDangerId = 1 -- 226
	self.wantRoom = "" -- 228
	self.carryCartAxle = -1 -- 230
	self.carryCartDocked = false -- 231
	self.checkpointCartAxle = -1 -- 233
	self.hasBottle = false -- 237
	self.bottleLandX = -1 -- 241
	self.bottleTargetX = -1 -- 242
	self.bottleTargetY = 0 -- 243
	self.bottleLandT = 0 -- 244
	self.aimHold = 0 -- 246
	self.scavX = 0 -- 248
	self.scavDir = 1 -- 249
	self.scavState = "patrol" -- 250
	self.scavT = 0 -- 251
	self.scavTargetX = 0 -- 252
	self.passed = false -- 254
	self.childMode = false -- 258
	self.phase = "" -- 260
	self.phaseTick = 0 -- 262
	self.gateTick = 0 -- 264
	self.countTick = 0 -- 266
	self.countArmed = false -- 268
	self.countPrevMove = 0 -- 270
	self.caughtT = 0 -- 272
	self.hp = 3 -- 274
	self.maxHp = 3 -- 275
	self.coveredFlash = 0 -- 277
	self.coverHug = false -- 279
	self.coverNear = false -- 281
	self.gateNeedConfirm = false -- 283
	self.bottleAimX = -1 -- 285
	self.bottleAimY = 0 -- 286
	self.dogX = 0 -- 288
	self.dogDir = 1 -- 289
	self.dogState = "patrol" -- 290
	self.dogT = 0 -- 291
	self.dogTargetX = 0 -- 292
	self.scavSee = 0 -- 294
	self.scavChase = false -- 295
	self.gateSpawned = 0 -- 297
	self.gateFailCount = 0 -- 299
	self.paused = false -- 301
	self.ticks = 0 -- 303
	self.view = {zoom = 1, ox = 0, oy = 0} -- 305
	self.ox = 0 -- 307
	self.aimX = 0 -- 309
	self.aimY = 0 -- 310
	self.viewW = 0 -- 312
	self.viewH = 0 -- 313
	self.ox = room.originX -- 319
	self.room = withOrigin(room) -- 320
	local wr = self.room -- 321
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 322
	self:buildWorld() -- 323
	self.childMode = wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower" -- 325
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 326
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 327
	self.player = makeActor(wr, playerIdx) -- 328
	self.partner = makeActor(wr, partnerIdx) -- 329
	self.phase = phaseOf(wr.key) -- 330
	if wr.story ~= nil then -- 330
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 332
	end -- 332
	self.cam.x = self.player.x -- 334
	self.cam.y = self.player.y + CAM_LOOK_UP -- 335
	self.cartAxle = wr.cart.startX -- 336
	self.escort = __TS__New( -- 337
		Escort, -- 337
		safeAnchorX(wr.marks) -- 337
	) -- 337
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 338
	self:buildEnemies() -- 339
	if resume ~= nil and resume.checkpoint > 0 then -- 339
		self.checkpoint = resume.checkpoint -- 342
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 342
			self.cartAxle = self.room.cart.endX -- 344
			self.cartDocked = true -- 345
			self.player.x = self.ox + 380 -- 348
			self.player.y = 0 -- 349
			self.player.vy = 0 -- 350
			self.player.onGround = true -- 351
			self.cam.x = self.player.x -- 352
			self.cam.y = self.player.y + CAM_LOOK_UP -- 353
		end -- 353
	end -- 353
end -- 317
function Play.prototype.buildWorld(self) -- 359
	local room = self.room -- 360
	self.boxes = {} -- 361
	self.floors = {} -- 362
	local i = 0 -- 363
	do -- 363
		i = 0 -- 364
		while i < #room.floors do -- 364
			local f = room.floors[i + 1] -- 365
			local ____self_floors_0 = self.floors -- 365
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 366
			i = i + 1 -- 364
		end -- 364
	end -- 364
	do -- 364
		i = 0 -- 368
		while i < #room.solids do -- 368
			local s = room.solids[i + 1] -- 369
			local ____self_boxes_1 = self.boxes -- 369
			____self_boxes_1[#____self_boxes_1 + 1] = { -- 370
				x0 = s.x, -- 370
				x1 = s.x + s.w, -- 370
				y0 = s.y, -- 370
				y1 = s.y + s.h, -- 370
				passable = s.passable == true -- 370
			} -- 370
			i = i + 1 -- 368
		end -- 368
	end -- 368
	do -- 368
		i = 0 -- 372
		while i < #room.stairs do -- 372
			local st = room.stairs[i + 1] -- 373
			local n = st.steps + 1 -- 374
			local stepW = (st.x1 - st.x0) / n -- 375
			local k = 0 -- 376
			do -- 376
				k = 0 -- 377
				while k < n do -- 377
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 378
					local x0 = st.x0 + stepW * k -- 379
					local ____self_boxes_2 = self.boxes -- 379
					____self_boxes_2[#____self_boxes_2 + 1] = { -- 381
						x0 = x0, -- 381
						x1 = x0 + stepW, -- 381
						y0 = -8, -- 381
						y1 = y, -- 381
						passable = true -- 381
					} -- 381
					k = k + 1 -- 377
				end -- 377
			end -- 377
			i = i + 1 -- 372
		end -- 372
	end -- 372
end -- 359
function Play.prototype.buildEnemies(self) -- 386
	self.enemies = {} -- 387
	if self.room.key == "checkpoint" then -- 387
		local ____self_enemies_3 = self.enemies -- 387
		____self_enemies_3[#____self_enemies_3 + 1] = { -- 389
			x = self.ox + 430, -- 389
			y = 0, -- 389
			w = 26, -- 389
			h = 84, -- 389
			alive = true, -- 389
			hitT = 0, -- 389
			warnT = 0, -- 389
			fireCd = 0 -- 389
		} -- 389
		local ____self_enemies_4 = self.enemies -- 389
		____self_enemies_4[#____self_enemies_4 + 1] = { -- 390
			x = self.ox + 505, -- 390
			y = 0, -- 390
			w = 26, -- 390
			h = 84, -- 390
			alive = true, -- 390
			hitT = 0, -- 390
			warnT = 0, -- 390
			fireCd = 0 -- 390
		} -- 390
		return -- 391
	end -- 391
	if self.room.key == "street" then -- 391
		local ____self_enemies_5 = self.enemies -- 391
		____self_enemies_5[#____self_enemies_5 + 1] = { -- 395
			x = self.ox + 340, -- 395
			y = 0, -- 395
			w = 26, -- 395
			h = 84, -- 395
			alive = true, -- 395
			hitT = 0, -- 395
			warnT = 0, -- 395
			fireCd = 0 -- 395
		} -- 395
		local ____self_enemies_6 = self.enemies -- 395
		____self_enemies_6[#____self_enemies_6 + 1] = { -- 396
			x = self.ox + 560, -- 396
			y = 0, -- 396
			w = 26, -- 396
			h = 84, -- 396
			alive = true, -- 396
			hitT = 0, -- 396
			warnT = 0, -- 396
			fireCd = 0 -- 396
		} -- 396
	end -- 396
end -- 386
function Play.prototype.update(self, dt, input) -- 402
	if input.pause.pressed then -- 402
		self.paused = not self.paused -- 404
	end -- 404
	if self.flashT > 0 then -- 404
		self.flashT = self.flashT - dt -- 407
		if self.flashT <= 0 then -- 407
			self.flash = "" -- 409
		end -- 409
	end -- 409
	if self.traceT > 0 then -- 409
		self.traceT = self.traceT - dt -- 413
		if self.traceT <= 0 then -- 413
			self.trace = nil -- 415
		end -- 415
	end -- 415
	if self.paused then -- 415
		self:updateCamera(dt) -- 419
		return -- 420
	end -- 420
	self.ticks = self.ticks + 1 -- 423
	local p = self.player -- 424
	self:stepPlayer(p, dt, input) -- 425
	self:stepEnemies(dt, input) -- 427
	self:stepStory(dt, input) -- 428
	self:stepEscort(dt, input) -- 429
	self:stepVillage(dt, input) -- 430
	self:stepChase(dt, input) -- 431
	self:stepInteract(dt, input) -- 432
	self:updateGate() -- 433
	self:updateCamera(dt) -- 434
end -- 402
function Play.prototype.nearCover(self, a) -- 438
	local i = 0 -- 439
	do -- 439
		i = 0 -- 440
		while i < #self.boxes do -- 440
			do -- 440
				local b = self.boxes[i + 1] -- 441
				if b.passable == true or b.y1 - b.y0 < 44 then -- 441
					goto __continue35 -- 443
				end -- 443
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 443
					goto __continue35 -- 446
				end -- 446
				local half = a.w / 2 -- 448
				if math.min( -- 448
					math.abs(a.x + half - b.x0), -- 449
					math.abs(a.x - half - b.x1) -- 449
				) < 24 then -- 449
					return true -- 450
				end -- 450
			end -- 450
			::__continue35:: -- 450
			i = i + 1 -- 440
		end -- 440
	end -- 440
	return false -- 453
end -- 438
function Play.prototype.nearLowLedge(self, a) -- 457
	local reach = 26 -- 458
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 459
	local x1 = x0 + reach -- 460
	local i = 0 -- 461
	do -- 461
		i = 0 -- 462
		while i < #self.boxes do -- 462
			do -- 462
				local b = self.boxes[i + 1] -- 463
				if b.x1 <= x0 or b.x0 >= x1 then -- 463
					goto __continue41 -- 465
				end -- 465
				local rise = b.y1 - a.y -- 467
				if rise > 0 and rise <= LEDGE_RISE then -- 467
					return true -- 469
				end -- 469
			end -- 469
			::__continue41:: -- 469
			i = i + 1 -- 462
		end -- 462
	end -- 462
	return false -- 472
end -- 457
function Play.prototype.stepPlayer(self, a, dt, input) -- 475
	if not a.alive then -- 475
		return -- 477
	end -- 477
	local isChild = self.childMode -- 479
	if self:storyLocked() then -- 479
		a.vx = 0 -- 482
		a.crouch = false -- 483
		a.h = isChild and CHILD_H or SOLDIER_H -- 484
		self:fallY(a, dt) -- 485
		return -- 486
	end -- 486
	if not isChild and self.escort.state == "calming" then -- 486
		a.crouch = false -- 490
		a.h = SOLDIER_H -- 491
		a.vx = 0 -- 492
		self:fallY(a, dt) -- 493
		return -- 494
	end -- 494
	a.crouch = isChild and input.crouch.held and a.onGround -- 496
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 497
	local nearCover = not isChild and self:nearCover(a) -- 498
	a.covered = nearCover and input.cover.held -- 499
	if not isChild then -- 499
		self.coverHug = a.covered -- 501
		self.coverNear = nearCover -- 502
	end -- 502
	if a.rollT > 0 then -- 502
		a.rollT = a.rollT - dt -- 507
		a.vx = a.facing * ROLL_SPEED -- 508
		self:slideX(a, a.vx * dt) -- 509
		self:fallY(a, dt) -- 510
		if a.rollT <= 0 then -- 510
			self:flashSet("翻滚结束", 0.5) -- 512
		end -- 512
		return -- 514
	end -- 514
	if not isChild and input.jump.pressed and a.onGround then -- 514
		if input.moveX ~= 0 then -- 514
			a.facing = input.moveX > 0 and 1 or -1 -- 519
		end -- 519
		if self:nearLowLedge(a) then -- 519
			a.vy = SOLDIER_JUMP -- 523
			a.onGround = false -- 524
			self:flashSet("翻上去", 0.3) -- 525
			return -- 526
		end -- 526
		a.rollT = ROLL_TIME -- 528
		self:flashSet("翻滚", 0.3) -- 529
		return -- 530
	end -- 530
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 533
	if isChild then -- 533
		if input.cover.held then -- 533
			speed = CHILD_SLOW -- 536
		end -- 536
		if a.crouch then -- 536
			speed = CHILD_SLOW -- 539
		end -- 539
	elseif a.covered then -- 539
		speed = SOLDIER_SPEED * 0.45 -- 542
	end -- 542
	local dir = self.gripping and 0 or input.moveX -- 546
	if dir ~= 0 then -- 546
		a.facing = dir > 0 and 1 or -1 -- 548
	end -- 548
	a.vx = dir * speed -- 550
	if isChild and input.jump.pressed and a.onGround and not a.crouch then -- 550
		a.vy = CHILD_JUMP -- 554
		a.onGround = false -- 555
		self:flashSet("跳", 0.25) -- 556
	end -- 556
	self:slideX(a, a.vx * dt) -- 559
	self:fallY(a, dt) -- 560
	if not isChild and input.fire.pressed then -- 560
		self:shoot(a) -- 564
	end -- 564
end -- 475
function Play.prototype.stepPartner(self, p, dt) -- 569
	local a = self.partner -- 570
	if not a.alive then -- 570
		return -- 572
	end -- 572
	a.crouch = false -- 574
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 575
	a.vx = 0 -- 576
	self:fallY(a, dt) -- 577
end -- 569
function Play.prototype.stepEscort(self, dt, input) -- 584
	local a = self.partner -- 585
	if not a.alive then -- 585
		return -- 587
	end -- 587
	if not self:escortOn() then -- 587
		a.vx = 0 -- 590
		self:fallY(a, dt) -- 591
		return -- 592
	end -- 592
	local p = self.player -- 594
	local dist = math.abs(p.x - a.x) -- 595
	self.calmConsumed = self.escort:update( -- 596
		input, -- 596
		p.x, -- 596
		p.facing, -- 596
		a.x, -- 596
		dist -- 596
	) -- 596
	a.crouch = self.escort.crouchPose -- 597
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 598
	local dir = self.escort:moveDir(a.x) -- 599
	a.vx = dir * CHILD_SPEED -- 600
	if dir ~= 0 then -- 600
		a.facing = dir -- 602
		local before = a.x -- 603
		self:slideX(a, dir * CHILD_SPEED * dt) -- 604
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 604
			a.vy = CHILD_JUMP -- 607
			a.onGround = false -- 608
		end -- 608
	end -- 608
	self:fallY(a, dt) -- 611
end -- 584
function Play.prototype.escortOn(self) -- 615
	if self.room.key == "checkpoint" then -- 615
		return true -- 617
	end -- 617
	if self.room.key == "prologue" then -- 617
		return self.phase == "prologue-follow" -- 620
	end -- 620
	return self.room.key == "street" -- 622
end -- 615
function Play.prototype.storyLocked(self) -- 626
	if self.caughtT > 0 then -- 626
		return true -- 628
	end -- 628
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 628
		return true -- 631
	end -- 631
	if self.room.key == "gate" and self.phase == "gate-count" then -- 631
		return true -- 634
	end -- 634
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 634
		return true -- 637
	end -- 637
	return false -- 639
end -- 626
function Play.prototype.swapToChild(self, x) -- 643
	local tmp = self.player -- 644
	self.player = self.partner -- 645
	self.partner = tmp -- 646
	self.childMode = true -- 647
	self.player.alive = true -- 648
	self.player.x = self.ox + x -- 649
	self.player.y = 0 -- 650
	self.player.vy = 0 -- 651
	self.player.vx = 0 -- 652
	self.player.onGround = true -- 653
	self.player.crouch = false -- 654
	self.player.h = CHILD_H -- 655
	self.player.facing = 1 -- 656
	self.partner.alive = true -- 657
	self.cam.x = self.player.x -- 658
end -- 643
function Play.prototype.stepStory(self, dt, input) -- 662
	if self.room.key == "prologue" then -- 662
		self:stepPrologue(dt, input) -- 664
	elseif self.room.key == "street" then -- 664
		self:stepStreet(dt, input) -- 666
	elseif self.room.key == "gate" then -- 666
		self:stepGate(dt, input) -- 668
	elseif self.room.key == "tower" then -- 668
		self:stepTower(dt, input) -- 670
	end -- 670
end -- 662
function Play.prototype.stepPrologue(self, dt, input) -- 675
	local child = self.partner -- 676
	if self.phase == "prologue-wait" then -- 676
		child.crouch = true -- 678
		child.h = CHILD_CROUCH_H -- 679
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 680
		local near = math.abs(self.player.x - child.x) <= reach -- 682
		if near and input.interact.pressed then -- 682
			self.phase = "prologue-give" -- 684
			self.phaseTick = 0 -- 685
			self:flashSet("递出针套", 1) -- 686
		end -- 686
		return -- 688
	end -- 688
	if self.phase == "prologue-give" then -- 688
		self.phaseTick = self.phaseTick + 1 -- 691
		if self.phaseTick == 12 then -- 691
			self:flashSet("针套递过去", 0.7) -- 693
		elseif self.phaseTick == 36 then -- 693
			self:flashSet("纸条塞进针套", 0.9) -- 695
		elseif self.phaseTick >= 60 then -- 695
			self.phase = "prologue-follow" -- 697
			self.phaseTick = 0 -- 698
			child.crouch = false -- 699
			child.h = CHILD_H -- 700
			self:flashSet("她跟上了", 1.2) -- 701
		end -- 701
		return -- 703
	end -- 703
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 703
		self.wantRoom = "street" -- 707
		self:flashSet("进街道", 1.2) -- 708
	end -- 708
end -- 675
function Play.prototype.stepStreet(self, dt, input) -- 713
	local p = self.player -- 714
	local c = self.partner -- 715
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 715
		self.wantRoom = "checkpoint" -- 717
		self:flashSet("到检查站", 1.2) -- 718
	end -- 718
end -- 713
function Play.prototype.stepGate(self, dt, input) -- 723
	local ____temp_7 -- 724
	if self.room.story == nil then -- 724
		____temp_7 = nil -- 724
	else -- 724
		____temp_7 = self.room.story.gate -- 724
	end -- 724
	local g = ____temp_7 -- 724
	if g == nil then -- 724
		return -- 726
	end -- 726
	local p = self.player -- 728
	if self.phase == "gate-idle" then -- 728
		local a = self.partner -- 731
		local gap = g.waitX - a.x -- 732
		if math.abs(gap) > 3 then -- 732
			a.facing = gap > 0 and 1 or -1 -- 734
			a.vx = a.facing * CHILD_SPEED -- 735
			local beforeX = a.x -- 736
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 737
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 737
				a.vy = CHILD_JUMP -- 739
				a.onGround = false -- 740
			end -- 740
			self:fallY(a, dt) -- 742
		else -- 742
			a.vx = 0 -- 744
			a.x = g.waitX -- 745
		end -- 745
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 -- 748
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 749
		if self.gateNeedConfirm then -- 749
			if atWinch and atWait and input.interact.pressed then -- 749
				self.gateNeedConfirm = false -- 753
				self.phase = "gate-hold" -- 754
				self.gateTick = 0 -- 755
				self.gateSpawned = 0 -- 756
				self:flashSet("重新就位 · 守点开始", 1.4) -- 757
			end -- 757
			return -- 759
		end -- 759
		if atWinch and atWait then -- 759
			self.phase = "gate-hold" -- 762
			self.gateTick = 0 -- 763
			self.gateSpawned = 0 -- 764
			self:flashSet("两人就位 · 守点开始", 1.4) -- 765
		end -- 765
		return -- 767
	end -- 767
	if self.phase == "gate-hold" then -- 767
		self.gateTick = self.gateTick + 1 -- 770
		local marks = {0, 540, 900, 1500} -- 772
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 772
			local idx = self.gateSpawned -- 774
			local ____self_enemies_8 = self.enemies -- 774
			____self_enemies_8[#____self_enemies_8 + 1] = { -- 775
				x = self.ox + 620 + idx * 62, -- 776
				y = 0, -- 776
				w = 26, -- 776
				h = 84, -- 776
				alive = true, -- 777
				hitT = 0, -- 777
				warnT = 0, -- 777
				fireCd = 90 + idx * 45 -- 777
			} -- 777
			self.gateSpawned = self.gateSpawned + 1 -- 779
			self:flashSet( -- 780
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 780
				0.9 -- 780
			) -- 780
		end -- 780
		if self.gateTick == 900 then -- 780
			self:flashSet("灯灭了", 1) -- 783
		elseif self.gateTick == 2100 then -- 783
			self:flashSet("门底压下来了", 1) -- 785
		end -- 785
		if self.gateTick >= g.holdTicks then -- 785
			self.phase = "gate-send" -- 788
			self.phaseTick = 0 -- 789
			self.enemies = {} -- 791
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 792
		end -- 792
		return -- 794
	end -- 794
	if self.phase == "gate-send" then -- 794
		local near = math.abs(p.x - g.doorX) <= 60 -- 797
		if near and input.interact.pressed then -- 797
			self:swapToChild(g.doorX + 30) -- 799
			self.phase = "gate-count" -- 800
			self.countTick = 0 -- 801
			self.countArmed = false -- 803
			self.countPrevMove = input.moveX -- 804
			self:flashSet("门开了 · 送她出去", 1.8) -- 805
		end -- 805
		return -- 807
	end -- 807
	if self.phase == "gate-count" then -- 807
		self.countTick = self.countTick + 1 -- 810
		if self.countTick == 360 then -- 810
			self:flashSet("门关上", 0.9) -- 812
		elseif self.countTick == 1020 then -- 812
			self:flashSet("数到一百", 2.2) -- 814
		end -- 814
		local prevMove = self.countPrevMove -- 818
		self.countPrevMove = input.moveX -- 819
		if self.countTick >= 1440 then -- 819
			if prevMove <= 0 and input.moveX > 0 then -- 819
				self.countArmed = true -- 822
			end -- 822
			if self.countArmed and input.moveX > 0 then -- 822
				self.phase = "gate-walk" -- 825
				self.phaseTick = 0 -- 826
				self:flashSet("她迈出第一步", 1.4) -- 827
			end -- 827
		end -- 827
		return -- 830
	end -- 830
	if self.player.x >= g.exitX then -- 830
		self.wantRoom = "outside" -- 834
		self:flashSet("出城门 · 城外", 1.4) -- 835
	end -- 835
end -- 723
function Play.prototype.stepTower(self, dt, input) -- 840
	local ____temp_9 -- 841
	if self.room.story == nil then -- 841
		____temp_9 = nil -- 841
	else -- 841
		____temp_9 = self.room.story.tower -- 841
	end -- 841
	local t = ____temp_9 -- 841
	if t == nil then -- 841
		return -- 843
	end -- 843
	if self.phase == "tower-wait" then -- 843
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 846
		if near and input.interact.pressed then -- 846
			self.phase = "tower-knock" -- 848
			self.phaseTick = 0 -- 849
			self.knocks = 1 -- 850
			self:flashSet("敲一下", 0.6) -- 851
		end -- 851
		return -- 853
	end -- 853
	if self.phase == "tower-knock" then -- 853
		self.phaseTick = self.phaseTick + 1 -- 856
		if self.phaseTick == 12 then -- 856
			self.knocks = 2 -- 858
			self:flashSet("敲两下 · 第二声", 1) -- 859
		elseif self.phaseTick >= t.knockTicks then -- 859
			self.phase = "tower-given" -- 861
			self.phaseTick = 0 -- 862
			self:flashSet("门开了 · 提灯", 1.4) -- 863
		end -- 863
		return -- 865
	end -- 865
	if self.phase == "tower-given" then -- 865
		self.phaseTick = self.phaseTick + 1 -- 868
		if self.phaseTick == 60 then -- 868
			self:flashSet("她递出针套和纸条", 1.6) -- 870
		elseif self.phaseTick == 120 then -- 870
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 872
		elseif self.phaseTick >= 180 then -- 872
			self.phase = "tower-end" -- 874
			self.phaseTick = 0 -- 875
			self:flashSet("片尾 · E 再玩一次", 3) -- 876
		end -- 876
		return -- 878
	end -- 878
	if input.interact.pressed or input.retry.pressed then -- 878
		self.wantRoom = "prologue" -- 881
		self:flashSet("回到序章", 1.4) -- 882
	end -- 882
end -- 840
function Play.prototype.stepChase(self, dt, input) -- 887
	if self.caughtT > 0 then -- 887
		self.caughtT = self.caughtT - dt -- 889
		if self.caughtT <= 0 then -- 889
			self:recoverFromCaught() -- 891
		end -- 891
		return -- 893
	end -- 893
	if self.room.key == "village" then -- 893
		self:stepScavChase() -- 896
	elseif self.room.key == "forest" then -- 896
		self:stepDog(dt) -- 898
		if self.player.x >= self.ox + 1450 then -- 898
			self.wantRoom = "tower" -- 901
			self:flashSet("林缘 · 北塔", 1.4) -- 902
		end -- 902
	end -- 902
end -- 887
function Play.prototype.stepScavChase(self) -- 908
	local s = self.room.scavenger -- 909
	if s == nil then -- 909
		return -- 911
	end -- 911
	local p = self.player -- 913
	if self.passed and p.x > self.ox + 440 then -- 913
		if self.scavChase then -- 913
			self.scavChase = false -- 917
			self.scavState = "back" -- 918
			self.scavT = 0 -- 919
		end -- 919
		return -- 921
	end -- 921
	local dx = p.x - self.scavX -- 923
	local dist = math.abs(dx) -- 924
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 925
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 926
	if not self.scavChase then -- 926
		if visible then -- 926
			self.scavSee = self.scavSee + 1 -- 929
			if self.scavSee >= 24 then -- 929
				self.scavChase = true -- 931
				self.scavState = "chase" -- 932
				self.scavTargetX = p.x -- 933
				self:flashSet("他看见你了", 1.2) -- 934
			end -- 934
		else -- 934
			self.scavSee = 0 -- 937
		end -- 937
		return -- 939
	end -- 939
	local dir = p.x > self.scavX and 1 or -1 -- 942
	self.scavX = self.scavX + dir * 96 / 60 -- 943
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 943
		self:caught() -- 945
		return -- 946
	end -- 946
	if hidden then -- 946
		self.scavSee = 0 -- 950
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 951
		self.scavT = self.scavT - 1 -- 952
		if self.scavT <= 0 then -- 952
			self.scavChase = false -- 954
			self.scavState = "patrol" -- 955
			self:flashSet("他失去了目标", 1) -- 956
		end -- 956
	end -- 956
end -- 908
function Play.prototype.stepDog(self, dt) -- 962
	local ____temp_10 -- 963
	if self.room.story == nil then -- 963
		____temp_10 = nil -- 963
	else -- 963
		____temp_10 = self.room.story.dog -- 963
	end -- 963
	local dog = ____temp_10 -- 963
	if dog == nil then -- 963
		return -- 965
	end -- 965
	local p = self.player -- 967
	local dist = math.abs(p.x - self.dogX) -- 968
	if self.dogState == "patrol" then -- 968
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 970
		if self.dogX < dog.x0 then -- 970
			self.dogX = dog.x0 -- 972
			self.dogDir = 1 -- 973
		elseif self.dogX > dog.x1 then -- 973
			self.dogX = dog.x1 -- 975
			self.dogDir = -1 -- 976
		end -- 976
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 978
		if not p.crouch and moving and dist < dog.range then -- 978
			self.dogState = "ear" -- 980
			self.dogT = 18 -- 981
			self.dogTargetX = p.x -- 982
			self:flashSet("狗转耳朵", 0.8) -- 983
		end -- 983
		return -- 985
	end -- 985
	if self.dogState == "ear" then -- 985
		self.dogT = self.dogT - 1 -- 988
		if self.dogT <= 0 then -- 988
			self.dogState = "chase" -- 990
			self.dogTargetX = p.x -- 991
			self:flashSet("狗追来了", 1.4) -- 992
		end -- 992
		return -- 994
	end -- 994
	if self.dogState == "chase" then -- 994
		local dir = p.x > self.dogX and 1 or -1 -- 997
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 998
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 998
			self:caught() -- 1000
			self.dogState = "sniff" -- 1001
			self.dogT = 60 -- 1002
		elseif dist > dog.range * 1.5 or p.crouch then -- 1002
			self.dogState = "sniff" -- 1004
			self.dogT = 60 -- 1005
			self:flashSet("狗停下了", 0.9) -- 1006
		end -- 1006
		return -- 1008
	end -- 1008
	if self.dogState == "sniff" then -- 1008
		self.dogT = self.dogT - 1 -- 1011
		if self.dogT <= 0 then -- 1011
			self.dogState = "back" -- 1013
		end -- 1013
		return -- 1015
	end -- 1015
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1018
	self.dogX = self.dogX + dir * dog.speed * dt -- 1019
	if math.abs(self.dogX - dog.x0) < 2 then -- 1019
		self.dogX = dog.x0 -- 1021
		self.dogState = "patrol" -- 1022
	end -- 1022
end -- 962
function Play.prototype.caught(self) -- 1026
	self.caughtT = 1 -- 1027
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1028
end -- 1026
function Play.prototype.recoverFromCaught(self) -- 1032
	local p = self.player -- 1033
	p.x = self.ox + 140 -- 1034
	p.y = 0 -- 1035
	p.vy = 0 -- 1036
	p.vx = 0 -- 1037
	p.onGround = true -- 1038
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1038
		self.scavX = self.room.scavenger.x0 -- 1040
		self.scavState = "patrol" -- 1041
		self.scavSee = 0 -- 1042
		self.scavChase = false -- 1043
		self.scavT = 0 -- 1044
	end -- 1044
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1044
		self.dogX = self.room.story.dog.x0 -- 1047
		self.dogState = "patrol" -- 1048
		self.dogT = 0 -- 1049
	end -- 1049
	self.cam.x = p.x -- 1051
	self.cam.y = p.y + CAM_LOOK_UP -- 1052
	self:flashSet("回到安全点", 1.2) -- 1053
end -- 1032
function Play.prototype.updateGate(self) -- 1057
	if self.room.key ~= "checkpoint" then -- 1057
		self.gateOpen = false -- 1059
		return -- 1060
	end -- 1060
	local function inZone(x) -- 1062
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1062
	end -- 1062
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1063
end -- 1057
function Play.prototype.stepEnemies(self, dt, input) -- 1066
	local i = 0 -- 1067
	do -- 1067
		i = 0 -- 1068
		while i < #self.enemies do -- 1068
			local e = self.enemies[i + 1] -- 1069
			if e.hitT > 0 then -- 1069
				e.hitT = e.hitT - dt -- 1071
			end -- 1071
			i = i + 1 -- 1068
		end -- 1068
	end -- 1068
	if self.coveredFlash > 0 then -- 1068
		self.coveredFlash = self.coveredFlash - dt -- 1075
	end -- 1075
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 1075
		return -- 1079
	end -- 1079
	do -- 1079
		i = 0 -- 1081
		while i < #self.enemies do -- 1081
			do -- 1081
				local e = self.enemies[i + 1] -- 1082
				if not e.alive then -- 1082
					goto __continue172 -- 1084
				end -- 1084
				if e.warnT > 0 then -- 1084
					e.warnT = e.warnT - 1 -- 1087
					if e.warnT <= 0 then -- 1087
						self:enemyFire(e, input) -- 1089
					end -- 1089
					goto __continue172 -- 1091
				end -- 1091
				if e.fireCd > 0 then -- 1091
					e.fireCd = e.fireCd - 1 -- 1094
					if e.fireCd <= 0 then -- 1094
						e.warnT = WARN_TICKS -- 1096
					end -- 1096
				else -- 1096
					e.warnT = WARN_TICKS -- 1100
				end -- 1100
			end -- 1100
			::__continue172:: -- 1100
			i = i + 1 -- 1081
		end -- 1081
	end -- 1081
end -- 1066
function Play.prototype.enemyFire(self, e, input) -- 1106
	local p = self.player -- 1107
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 1107
		self:flashSet("枪声响在远处", 0.4) -- 1109
		e.fireCd = FIRE_COOLDOWN -- 1110
		return -- 1111
	end -- 1111
	local hugging = self:blockedByCover(e.x, p.x) -- 1114
	local covered = hugging and input.cover.held -- 1115
	if covered then -- 1115
		self.coveredFlash = 0.5 -- 1117
		self:flashSet("掩体挡下", 0.5) -- 1118
		e.fireCd = FIRE_COOLDOWN -- 1119
		return -- 1120
	end -- 1120
	self.hp = self.hp - 1 -- 1122
	self:flashSet( -- 1123
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 1123
		0.7 -- 1123
	) -- 1123
	e.fireCd = FIRE_COOLDOWN -- 1124
	if self.hp <= 0 then -- 1124
		self:gateFailed() -- 1126
	end -- 1126
end -- 1106
function Play.prototype.blockedByCover(self, ex, px) -- 1131
	local lo = math.min(ex, px) -- 1132
	local hi = math.max(ex, px) -- 1133
	local i = 0 -- 1134
	do -- 1134
		i = 0 -- 1135
		while i < #self.boxes do -- 1135
			do -- 1135
				local b = self.boxes[i + 1] -- 1136
				if b.passable == true or b.y1 - b.y0 < 44 then -- 1136
					goto __continue185 -- 1138
				end -- 1138
				local cx = (b.x0 + b.x1) / 2 -- 1140
				if cx <= lo + 8 or cx >= hi - 8 then -- 1140
					goto __continue185 -- 1142
				end -- 1142
				local hug = math.min( -- 1144
					math.abs(px - b.x0), -- 1144
					math.abs(px - b.x1) -- 1144
				) < 24 -- 1144
				if hug then -- 1144
					return true -- 1146
				end -- 1146
			end -- 1146
			::__continue185:: -- 1146
			i = i + 1 -- 1135
		end -- 1135
	end -- 1135
	return false -- 1149
end -- 1131
function Play.prototype.gateFailed(self) -- 1153
	local ____temp_11 -- 1154
	if self.room.story == nil then -- 1154
		____temp_11 = nil -- 1154
	else -- 1154
		____temp_11 = self.room.story.gate -- 1154
	end -- 1154
	local g = ____temp_11 -- 1154
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 1155
	self.hp = self.maxHp -- 1156
	self.gateTick = 0 -- 1157
	self.gateSpawned = 0 -- 1158
	self.enemies = {} -- 1159
	self.gateFailCount = self.gateFailCount + 1 -- 1160
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 1162
	self.player.y = 0 -- 1163
	self.player.vy = 0 -- 1164
	self.player.onGround = true -- 1165
	self.player.crouch = false -- 1166
	self.player.h = SOLDIER_H -- 1167
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 1168
	self.partner.y = 0 -- 1169
	self.partner.vy = 0 -- 1170
	self.partner.onGround = true -- 1171
	self.cam.x = self.player.x -- 1172
	self.phase = "gate-idle" -- 1173
	self.phaseTick = 0 -- 1174
	self.coverHug = false -- 1175
	self.gateNeedConfirm = true -- 1176
end -- 1153
function Play.prototype.stepInteract(self, dt, input) -- 1179
	local p = self.player -- 1180
	local calmUsed = self.calmConsumed -- 1181
	self.calmConsumed = false -- 1182
	self.focusCart = false -- 1183
	if self.room.key == "outside" then -- 1183
		local c = self.room.cart -- 1185
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 1186
		local dy = p.y - c.baseY -- 1187
		self.focusCart = dx * dx + dy * dy < CART_REACH * CART_REACH -- 1188
	end -- 1188
	self:stepCart(dt, input) -- 1190
	if calmUsed then -- 1190
		self:flashSet("安抚 · 敲两下", 0.8) -- 1194
	elseif input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" then -- 1194
		if self.knockT > 0 then -- 1194
			self.knocks = self.knocks + 1 -- 1198
		else -- 1198
			self.knocks = 1 -- 1200
		end -- 1200
		self.knockT = 1.2 -- 1202
		if self.knocks >= 2 then -- 1202
			self:flashSet("敲两下", 0.8) -- 1204
			self.knocks = 0 -- 1205
		else -- 1205
			self:flashSet("敲一下", 0.5) -- 1207
		end -- 1207
	elseif self.knockT > 0 then -- 1207
		self.knockT = self.knockT - dt -- 1210
		if self.knockT <= 0 then -- 1210
			self.knocks = 0 -- 1212
		end -- 1212
	end -- 1212
	local i = 0 -- 1217
	do -- 1217
		i = 0 -- 1218
		while i < #self.room.marks do -- 1218
			do -- 1218
				local m = self.room.marks[i + 1] -- 1219
				if m.kind ~= 0 then -- 1219
					goto __continue201 -- 1221
				end -- 1221
				local subjects = {self.partner, self.player} -- 1223
				local k = 0 -- 1224
				do -- 1224
					k = 0 -- 1225
					while k < #subjects do -- 1225
						do -- 1225
							local s = subjects[k + 1] -- 1226
							if not s.alive then -- 1226
								goto __continue204 -- 1228
							end -- 1228
							local dx = s.x - m.x -- 1230
							local dy = s.y - m.y -- 1231
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 1231
								self.checkpoint = m.x -- 1233
								self.checkpointCartAxle = self.cartAxle -- 1234
								if self.cartDocked then -- 1234
									self:flashSet("检查点 · 车已落窝", 1) -- 1236
								else -- 1236
									self:flashSet("检查点 · 车还没到位", 1) -- 1238
								end -- 1238
							end -- 1238
						end -- 1238
						::__continue204:: -- 1238
						k = k + 1 -- 1225
					end -- 1225
				end -- 1225
			end -- 1225
			::__continue201:: -- 1225
			i = i + 1 -- 1218
		end -- 1218
	end -- 1218
	self:checkCarryGate() -- 1244
end -- 1179
function Play.prototype.stepVillage(self, dt, input) -- 1248
	if self.room.key ~= "village" then -- 1248
		return -- 1250
	end -- 1250
	local p = self.player -- 1252
	local bottle = self.room.bottle -- 1253
	local scav = self.room.scavenger -- 1254
	if not self.hasBottle and bottle ~= nil then -- 1254
		local dx = p.x - bottle.x -- 1258
		local dy = p.y + p.h * 0.5 - bottle.y -- 1259
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 1259
			self.hasBottle = true -- 1261
			self:flashSet("拾起瓶子", 0.8) -- 1262
		end -- 1262
	end -- 1262
	if self.hasBottle then -- 1262
		if input.aim.held then -- 1262
			self.aimHold = self.aimHold + dt -- 1269
			if self.aimHold > 1.2 then -- 1269
				self.aimHold = 1.2 -- 1271
			end -- 1271
			local cached = self:bottleEnd() -- 1274
			self.bottleAimX = cached.x -- 1275
			self.bottleAimY = cached.y -- 1276
		elseif input.aim.released then -- 1276
			if self.aimHold < 0.12 then -- 1276
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 1280
				self.aimHold = 0 -- 1281
			else -- 1281
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 1283
				self:throwBottle(____end.x, ____end.y) -- 1284
				self.aimHold = 0 -- 1285
			end -- 1285
		end -- 1285
	else -- 1285
		self.aimHold = 0 -- 1289
		self.bottleAimX = -1 -- 1290
	end -- 1290
	local fly = self.bottleFly -- 1294
	if fly ~= nil then -- 1294
		fly.vy = fly.vy - GRAVITY * dt -- 1296
		fly.x = fly.x + fly.vx * dt -- 1297
		fly.y = fly.y + fly.vy * dt -- 1298
		local g = self:groundAt(fly.x, fly.y + 4, 3) -- 1299
		local ____temp_13 = self.bottleTargetX >= 0 -- 1300
		if ____temp_13 then -- 1300
			local ____temp_12 -- 1300
			if fly.vx >= 0 then -- 1300
				____temp_12 = fly.x >= self.bottleTargetX -- 1300
			else -- 1300
				____temp_12 = fly.x <= self.bottleTargetX -- 1300
			end -- 1300
			____temp_13 = ____temp_12 -- 1300
		end -- 1300
		local reached = ____temp_13 -- 1300
		if fly.y <= g or reached then -- 1300
			local landX = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 1302
			self.bottleFly = nil -- 1303
			self.bottleLandX = landX -- 1304
			self.bottleLandT = 0.9 -- 1305
			self:hearBottle(landX) -- 1306
		end -- 1306
	end -- 1306
	if self.bottleLandT > 0 then -- 1306
		self.bottleLandT = self.bottleLandT - dt -- 1310
	end -- 1310
	if scav ~= nil then -- 1310
		self:stepScav(dt, scav) -- 1314
	end -- 1314
	local line = self.room.passLine -- 1317
	if line ~= nil and not self.passed and p.x >= line then -- 1317
		self.passed = true -- 1319
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 1320
	end -- 1320
	if self.passed and p.x >= self.ox + 640 then -- 1320
		self.wantRoom = "forest" -- 1324
		self:flashSet("出院 · 北塔森林", 1.4) -- 1325
	end -- 1325
end -- 1248
function Play.prototype.bottleEnd(self) -- 1330
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1331
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 1334
	return {x = aim.x, y = g} -- 1335
end -- 1330
function Play.prototype.throwBottle(self, tx, ty) -- 1339
	local p = self.player -- 1340
	local dir = tx >= p.x and 1 or -1 -- 1342
	p.facing = dir -- 1343
	local x0 = p.x + dir * 10 -- 1344
	local y0 = p.y + p.h * 0.7 -- 1345
	local T = 0.62 -- 1346
	self.bottleTargetX = tx -- 1347
	self.bottleTargetY = ty -- 1348
	local vx = (tx - x0) / T -- 1349
	local vy = (ty - y0 + 0.5 * GRAVITY * T * T) / T -- 1350
	self.bottleFly = {x = x0, y = y0, vx = vx, vy = vy} -- 1351
	self.hasBottle = false -- 1352
	self:flashSet("投出", 0.4) -- 1353
end -- 1339
function Play.prototype.hearBottle(self, x) -- 1357
	local s = self.room.scavenger -- 1358
	if s == nil then -- 1358
		return -- 1360
	end -- 1360
	if math.abs(x - self.scavX) > s.range then -- 1360
		self:flashSet("落地 · 他没听见", 0.6) -- 1363
		return -- 1364
	end -- 1364
	self.scavState = "turn" -- 1366
	self.scavT = s.hearTicks -- 1367
	self.scavTargetX = x -- 1368
	self:flashSet("砖地一响 · 他转头", 0.9) -- 1369
end -- 1357
function Play.prototype.stepScav(self, dt, s) -- 1373
	if self.scavState == "chase" then -- 1373
		return -- 1376
	end -- 1376
	if self.scavState == "turn" then -- 1376
		self.scavT = self.scavT - 1 -- 1379
		if self.scavT <= 0 then -- 1379
			self.scavState = "walk" -- 1381
		end -- 1381
		return -- 1383
	end -- 1383
	if self.scavState == "walk" then -- 1383
		local d = self.scavTargetX - self.scavX -- 1386
		if math.abs(d) < 4 then -- 1386
			self.scavState = "stall" -- 1388
			self.scavT = s.stallTicks -- 1389
			return -- 1390
		end -- 1390
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 1392
		return -- 1393
	end -- 1393
	if self.scavState == "stall" then -- 1393
		self.scavT = self.scavT - 1 -- 1396
		if self.scavT <= 0 then -- 1396
			self.scavState = "back" -- 1398
		end -- 1398
		return -- 1400
	end -- 1400
	if self.scavState == "back" then -- 1400
		local home = math.max( -- 1403
			s.x0, -- 1403
			math.min(s.x1, self.scavX) -- 1403
		) -- 1403
		if math.abs(home - self.scavX) < 2 then -- 1403
			self.scavState = "patrol" -- 1405
			return -- 1406
		end -- 1406
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 1408
		return -- 1409
	end -- 1409
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 1411
	if self.scavX >= s.x1 then -- 1411
		self.scavX = s.x1 -- 1413
		self.scavDir = -1 -- 1414
	elseif self.scavX <= s.x0 then -- 1414
		self.scavX = s.x0 -- 1416
		self.scavDir = 1 -- 1417
	end -- 1417
end -- 1373
function Play.prototype.stepCart(self, dt, input) -- 1425
	local p = self.player -- 1426
	local c = self.room.cart -- 1427
	local handleX = self.cartAxle + c.handleOffset -- 1428
	if self.gripping then -- 1428
		if not input.interact.held then -- 1428
			self.gripping = false -- 1432
			self:flashSet("松开车把", 0.4) -- 1433
			return -- 1434
		end -- 1434
	else -- 1434
		if not input.interact.pressed then -- 1434
			return -- 1438
		end -- 1438
		if math.abs(p.x - handleX) > CART_REACH or math.abs(p.y - c.baseY) > 40 then -- 1438
			return -- 1441
		end -- 1441
		self.gripping = true -- 1443
		self:flashSet("握住车把", 0.4) -- 1444
		return -- 1445
	end -- 1445
	if self.cartDocked then -- 1445
		return -- 1449
	end -- 1449
	local dir = input.moveX -- 1451
	if dir == 0 then -- 1451
		return -- 1453
	end -- 1453
	local lo = math.min(c.startX, c.endX) -- 1455
	local hi = math.max(c.startX, c.endX) -- 1456
	local next = self.cartAxle + dir * CART_SPEED * dt -- 1457
	if next < lo then -- 1457
		next = lo -- 1459
	end -- 1459
	if next > hi then -- 1459
		next = hi -- 1462
	end -- 1462
	local delta = next - self.cartAxle -- 1464
	if delta == 0 then -- 1464
		return -- 1466
	end -- 1466
	self.cartAxle = next -- 1468
	p.x = p.x + delta -- 1469
	p.facing = dir > 0 and 1 or -1 -- 1470
	self:slideX(p, 0) -- 1471
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > CART_REACH then -- 1471
		self.gripping = false -- 1473
		self:flashSet("跟不上了，脱手", 0.6) -- 1474
		return -- 1475
	end -- 1475
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 1475
		self.cartDocked = true -- 1478
		self.gripping = false -- 1479
		self:flashSet("车轮落窝", 1.2) -- 1480
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 1480
		self:flashSet("车轮回到起点", 0.5) -- 1482
	end -- 1482
end -- 1425
function Play.prototype.checkCarryGate(self) -- 1490
	if self.room.key == "checkpoint" then -- 1490
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 1490
			self.carryCartAxle = self.cartAxle -- 1493
			self.carryCartDocked = self.cartDocked -- 1494
			self.wantRoom = "gate" -- 1495
			self:flashSet("出检查站 · 城门", 1.2) -- 1496
		end -- 1496
		return -- 1498
	end -- 1498
	if self.room.key == "outside" then -- 1498
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 1498
			self.carryCartAxle = self.cartAxle -- 1504
			self.carryCartDocked = self.cartDocked -- 1505
			self.wantRoom = "village" -- 1506
			self:flashSet("墙根走完 · 进村口", 1.2) -- 1507
		end -- 1507
	end -- 1507
end -- 1490
function Play.prototype.aimAt(self, wx, wy) -- 1514
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 1515
	self.aimX = s.x -- 1516
	self.aimY = s.y -- 1517
end -- 1514
function Play.prototype.shoot(self, a) -- 1520
	local ox = a.x + a.facing * 8 -- 1521
	local oy = a.y + a.h * 0.72 -- 1522
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1524
	local dx = aim.x - ox -- 1527
	local dy = aim.y - oy -- 1528
	local len = math.sqrt(dx * dx + dy * dy) -- 1529
	if len < 0.001 then -- 1529
		dx = a.facing -- 1531
		dy = 0 -- 1532
	else -- 1532
		dx = dx / len -- 1534
		dy = dy / len -- 1535
	end -- 1535
	if dx ~= 0 then -- 1535
		a.facing = dx > 0 and 1 or -1 -- 1538
	end -- 1538
	local hitEnemy = self:raycast( -- 1541
		ox, -- 1541
		oy, -- 1541
		dx, -- 1541
		dy, -- 1541
		true -- 1541
	) -- 1541
	local hitWall = self:raycast( -- 1542
		ox, -- 1542
		oy, -- 1542
		dx, -- 1542
		dy, -- 1542
		false -- 1542
	) -- 1542
	local tEnemy = hitEnemy.t -- 1543
	local tWall = hitWall.t -- 1544
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 1545
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 1546
	self.trace = { -- 1548
		x0 = ox, -- 1548
		y0 = oy, -- 1548
		x1 = ox + dx * t, -- 1548
		y1 = oy + dy * t, -- 1548
		hit = hit -- 1548
	} -- 1548
	self.traceT = 0.12 -- 1549
	self:applyFireDanger(ox) -- 1550
	if hit then -- 1550
		local i = hitEnemy.index -- 1552
		local e = self.enemies[i + 1] -- 1553
		e.alive = false -- 1554
		e.hitT = 0.4 -- 1555
		self:flashSet("命中", 0.6) -- 1556
	else -- 1556
		self:flashSet("打空", 0.35) -- 1558
	end -- 1558
end -- 1520
function Play.prototype.applyFireDanger(self, shotX) -- 1563
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 1563
		return -- 1565
	end -- 1565
	local dangerX = shotX -- 1567
	local best = -1 -- 1568
	local bestD = 1000000000 -- 1569
	local i = 0 -- 1570
	do -- 1570
		i = 0 -- 1571
		while i < #self.enemies do -- 1571
			do -- 1571
				local e = self.enemies[i + 1] -- 1572
				if not e.alive then -- 1572
					goto __continue272 -- 1574
				end -- 1574
				local d = math.abs(e.x - self.partner.x) -- 1576
				if d < bestD then -- 1576
					bestD = d -- 1578
					best = i -- 1579
				end -- 1579
			end -- 1579
			::__continue272:: -- 1579
			i = i + 1 -- 1571
		end -- 1571
	end -- 1571
	if best >= 0 then -- 1571
		dangerX = self.enemies[best + 1].x -- 1583
	end -- 1583
	local exposed = self:childExposed(dangerX) -- 1585
	local before = self.escort.fear -- 1586
	local after = self.escort:applyDanger(self.nextDangerId, exposed, self.partner.x) -- 1587
	self.nextDangerId = self.nextDangerId + 1 -- 1588
	if after > before then -- 1588
		self:flashSet( -- 1590
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 1590
			1 -- 1590
		) -- 1590
	elseif not exposed then -- 1590
		self:flashSet("枪声没够到她", 0.5) -- 1592
	end -- 1592
end -- 1563
function Play.prototype.childExposed(self, dangerX) -- 1597
	local c = self.partner -- 1598
	if not c.alive then -- 1598
		return false -- 1600
	end -- 1600
	if c.x > self.ox + 240 and c.x < self.ox + 340 then -- 1600
		return false -- 1603
	end -- 1603
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 1603
		return false -- 1606
	end -- 1606
	local toDanger = dangerX - c.x -- 1608
	local toPlayer = self.player.x - c.x -- 1609
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) then -- 1609
		return false -- 1611
	end -- 1611
	return true -- 1613
end -- 1597
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 1617
	local best = -1 -- 1618
	local bestI = -1 -- 1619
	local i = 0 -- 1620
	if enemies then -- 1620
		do -- 1620
			i = 0 -- 1622
			while i < #self.enemies do -- 1622
				do -- 1622
					local e = self.enemies[i + 1] -- 1623
					if not e.alive then -- 1623
						goto __continue286 -- 1625
					end -- 1625
					local t = hitBox( -- 1627
						ox, -- 1627
						oy, -- 1627
						dx, -- 1627
						dy, -- 1627
						e.x - e.w / 2, -- 1627
						e.x + e.w / 2, -- 1627
						e.y, -- 1627
						e.y + e.h -- 1627
					) -- 1627
					if t >= 0 and (best < 0 or t < best) then -- 1627
						best = t -- 1629
						bestI = i -- 1630
					end -- 1630
				end -- 1630
				::__continue286:: -- 1630
				i = i + 1 -- 1622
			end -- 1622
		end -- 1622
		return {t = best, index = bestI} -- 1633
	end -- 1633
	do -- 1633
		i = 0 -- 1635
		while i < #self.boxes do -- 1635
			local b = self.boxes[i + 1] -- 1636
			local t = hitBox( -- 1637
				ox, -- 1637
				oy, -- 1637
				dx, -- 1637
				dy, -- 1637
				b.x0, -- 1637
				b.x1, -- 1637
				b.y0, -- 1637
				b.y1 -- 1637
			) -- 1637
			if t >= 0 and (best < 0 or t < best) then -- 1637
				best = t -- 1639
			end -- 1639
			i = i + 1 -- 1635
		end -- 1635
	end -- 1635
	if dy < 0 then -- 1635
		local t = (0 - oy) / dy -- 1644
		if t >= 0 and (best < 0 or t < best) then -- 1644
			best = t -- 1646
		end -- 1646
	end -- 1646
	return {t = best, index = -1} -- 1649
end -- 1617
function Play.prototype.slideX(self, a, dx) -- 1653
	local nx = a.x + dx -- 1654
	local half = a.w / 2 -- 1655
	local room = self.room -- 1656
	nx = math.max( -- 1657
		room.minX + half, -- 1657
		math.min(room.maxX - half, nx) -- 1657
	) -- 1657
	local i = 0 -- 1658
	do -- 1658
		i = 0 -- 1659
		while i < #self.boxes do -- 1659
			do -- 1659
				local b = self.boxes[i + 1] -- 1660
				if b.passable == true then -- 1660
					goto __continue296 -- 1662
				end -- 1662
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1662
					goto __continue296 -- 1665
				end -- 1665
				if nx + half > b.x0 and nx - half < b.x1 then -- 1665
					if a.x <= b.x0 then -- 1665
						nx = b.x0 - half -- 1669
					elseif a.x >= b.x1 then -- 1669
						nx = b.x1 + half -- 1671
					else -- 1671
						nx = a.x -- 1673
					end -- 1673
				end -- 1673
			end -- 1673
			::__continue296:: -- 1673
			i = i + 1 -- 1659
		end -- 1659
	end -- 1659
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 1659
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 1681
		local bx0 = self.cartAxle - CART_HALF -- 1682
		local bx1 = self.cartAxle + CART_HALF -- 1683
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 1683
			if a.x <= bx0 then -- 1683
				nx = bx0 - half -- 1686
			elseif a.x >= bx1 then -- 1686
				nx = bx1 + half -- 1688
			else -- 1688
				nx = a.x -- 1690
			end -- 1690
		end -- 1690
	end -- 1690
	local arch = room.arch -- 1698
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 1698
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 1700
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 1700
			if a.x <= arch.x0 then -- 1700
				nx = arch.x0 - half -- 1703
			elseif a.x >= arch.x1 then -- 1703
				nx = arch.x1 + half -- 1705
			end -- 1705
		end -- 1705
	end -- 1705
	a.x = nx -- 1709
end -- 1653
function Play.prototype.fallY(self, a, dt) -- 1713
	a.vy = a.vy - GRAVITY * dt -- 1714
	if a.vy < -900 then -- 1714
		a.vy = -900 -- 1716
	end -- 1716
	local ny = a.y + a.vy * dt -- 1718
	local half = a.w / 2 -- 1719
	if a.vy <= 0 then -- 1719
		local reach = a.onGround and STEP_UP or 0 -- 1722
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half) -- 1723
		if ny <= ground then -- 1723
			ny = ground -- 1725
			a.vy = 0 -- 1726
			a.onGround = true -- 1727
		else -- 1727
			a.onGround = false -- 1729
		end -- 1729
	else -- 1729
		a.onGround = false -- 1732
		local i = 0 -- 1733
		do -- 1733
			i = 0 -- 1734
			while i < #self.boxes do -- 1734
				do -- 1734
					local b = self.boxes[i + 1] -- 1735
					if b.passable == true then -- 1735
						goto __continue319 -- 1737
					end -- 1737
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 1737
						goto __continue319 -- 1740
					end -- 1740
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 1740
						ny = b.y0 - a.h -- 1743
						a.vy = 0 -- 1744
					end -- 1744
				end -- 1744
				::__continue319:: -- 1744
				i = i + 1 -- 1734
			end -- 1734
		end -- 1734
	end -- 1734
	a.y = ny -- 1748
end -- 1713
function Play.prototype.groundAt(self, x, ceiling, half) -- 1752
	local g = -9999 -- 1753
	local i = 0 -- 1754
	do -- 1754
		i = 0 -- 1755
		while i < #self.floors do -- 1755
			local f = self.floors[i + 1] -- 1756
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 1756
				g = f.y1 -- 1758
			end -- 1758
			i = i + 1 -- 1755
		end -- 1755
	end -- 1755
	do -- 1755
		i = 0 -- 1761
		while i < #self.boxes do -- 1761
			local b = self.boxes[i + 1] -- 1762
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 1762
				g = b.y1 -- 1764
			end -- 1764
			i = i + 1 -- 1761
		end -- 1761
	end -- 1761
	return g -- 1767
end -- 1752
function Play.prototype.updateCamera(self, dt) -- 1770
	local p = self.player -- 1771
	local tx = p.x + p.facing * 30 -- 1772
	local ty = p.y + CAM_LOOK_UP -- 1773
	local k = math.min(1, CAM_FOLLOW * dt) -- 1774
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 1775
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 1776
end -- 1770
function Play.prototype.clampCamera(self, w, h) -- 1780
	local room = self.room -- 1781
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 1782
	local spanX = room.maxX - room.minX -- 1783
	if spanX <= halfW * 2 then -- 1783
		self.cam.x = (room.minX + room.maxX) / 2 -- 1785
	else -- 1785
		self.cam.x = math.max( -- 1787
			room.minX + halfW, -- 1787
			math.min(room.maxX - halfW, self.cam.x) -- 1787
		) -- 1787
	end -- 1787
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 1790
	local spanY = room.height -- 1791
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 1792
	if spanY <= halfH * 2 then -- 1792
		self.cam.y = camY -- 1794
	else -- 1794
		self.cam.y = math.max( -- 1796
			camY, -- 1796
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 1796
		) -- 1796
	end -- 1796
end -- 1780
function Play.prototype.flashSet(self, text, t) -- 1800
	self.flash = text -- 1801
	self.flashT = t -- 1802
end -- 1800
function Play.prototype.statusText(self) -- 1806
	local p = self.player -- 1807
	local parts = {} -- 1808
	local who = self.childMode and "小满" or "周戍" -- 1809
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 1810
	if self.room.key == "prologue" then -- 1810
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1813
		if self.phase == "prologue-wait" then -- 1813
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 1815
		elseif self.phase == "prologue-give" then -- 1815
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 1817
		else -- 1817
			parts[#parts + 1] = "跟随" -- 1819
		end -- 1819
		if self.paused then -- 1819
			parts[#parts + 1] = "已暂停" -- 1822
		end -- 1822
		return table.concat(parts, " · ") -- 1824
	end -- 1824
	if self.room.key == "street" then -- 1824
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1827
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1828
		if self.paused then -- 1828
			parts[#parts + 1] = "已暂停" -- 1830
		end -- 1830
		return table.concat(parts, " · ") -- 1832
	end -- 1832
	if self.room.key == "gate" then -- 1832
		local ____temp_14 -- 1835
		if self.room.story == nil then -- 1835
			____temp_14 = nil -- 1835
		else -- 1835
			____temp_14 = self.room.story.gate -- 1835
		end -- 1835
		local g = ____temp_14 -- 1835
		if g ~= nil then -- 1835
			parts[#parts + 1] = self:gateLabel() -- 1837
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 1838
				0, -- 1839
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 1839
			))) .. " 秒" -- 1839
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1840
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1841
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 1842
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 1843
			if self.gateFailCount > 0 then -- 1843
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 1845
			end -- 1845
			if self.flash ~= "" then -- 1845
				parts[#parts + 1] = self.flash -- 1848
			end -- 1848
		end -- 1848
		if self.paused then -- 1848
			parts[#parts + 1] = "已暂停" -- 1852
		end -- 1852
		return table.concat(parts, " · ") -- 1854
	end -- 1854
	if self.room.key == "forest" then -- 1854
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1857
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 1858
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 1859
		if self.caughtT > 0 then -- 1859
			parts[#parts + 1] = "复位中" -- 1861
		end -- 1861
		if self.paused then -- 1861
			parts[#parts + 1] = "已暂停" -- 1864
		end -- 1864
		return table.concat(parts, " · ") -- 1866
	end -- 1866
	if self.room.key == "tower" then -- 1866
		if self.phase == "tower-wait" then -- 1866
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 1870
		elseif self.phase == "tower-knock" then -- 1870
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 1872
		elseif self.phase == "tower-given" then -- 1872
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 1874
		else -- 1874
			parts[#parts + 1] = "片尾" -- 1876
		end -- 1876
		if self.paused then -- 1876
			parts[#parts + 1] = "已暂停" -- 1879
		end -- 1879
		return table.concat(parts, " · ") -- 1881
	end -- 1881
	if self.room.key == "village" then -- 1881
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1884
		if self.hasBottle then -- 1884
			parts[#parts + 1] = "有瓶" -- 1886
		elseif self.bottleFly ~= nil then -- 1886
			parts[#parts + 1] = "瓶在飞" -- 1888
		else -- 1888
			parts[#parts + 1] = "空手" -- 1890
		end -- 1890
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 1892
		if self.scavChase then -- 1892
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 1894
		end -- 1894
		if self.passed then -- 1894
			parts[#parts + 1] = "已过通行线" -- 1897
		end -- 1897
		if self.paused then -- 1897
			parts[#parts + 1] = "已暂停" -- 1900
		end -- 1900
		return table.concat(parts, " · ") -- 1902
	end -- 1902
	local isChild = self.childMode -- 1905
	if isChild then -- 1905
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1907
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 1908
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1909
	else -- 1909
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 1911
		if p.rollT > 0 then -- 1911
			parts[#parts + 1] = "翻滚中" -- 1913
		end -- 1913
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1915
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1916
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 1917
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 1918
	end -- 1918
	if self.checkpoint >= 0 then -- 1918
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 1921
	end -- 1921
	if self.paused then -- 1921
		parts[#parts + 1] = "已暂停" -- 1924
	end -- 1924
	return table.concat(parts, " · ") -- 1926
end -- 1806
function Play.prototype.aliveEnemies(self) -- 1930
	local n = 0 -- 1931
	local i = 0 -- 1932
	do -- 1932
		i = 0 -- 1933
		while i < #self.enemies do -- 1933
			if self.enemies[i + 1].alive then -- 1933
				n = n + 1 -- 1935
			end -- 1935
			i = i + 1 -- 1933
		end -- 1933
	end -- 1933
	return n -- 1938
end -- 1930
function Play.prototype.threatened(self) -- 1943
	do -- 1943
		local i = 0 -- 1944
		while i < #self.enemies do -- 1944
			local e = self.enemies[i + 1] -- 1945
			if e.alive and e.warnT > 0 then -- 1945
				return true -- 1947
			end -- 1947
			i = i + 1 -- 1944
		end -- 1944
	end -- 1944
	return false -- 1950
end -- 1943
function Play.prototype.gateSecondsLeft(self) -- 1953
	local ____temp_15 -- 1954
	if self.room.story == nil then -- 1954
		____temp_15 = nil -- 1954
	else -- 1954
		____temp_15 = self.room.story.gate -- 1954
	end -- 1954
	local g = ____temp_15 -- 1954
	if g == nil then -- 1954
		return 0 -- 1956
	end -- 1956
	return math.max( -- 1958
		0, -- 1958
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 1958
	) -- 1958
end -- 1953
function Play.prototype.gateLabel(self) -- 1961
	if self.phase == "gate-idle" then -- 1961
		return "待就位" -- 1963
	end -- 1963
	if self.phase == "gate-hold" then -- 1963
		return "守点中" -- 1966
	end -- 1966
	if self.phase == "gate-send" then -- 1966
		return "送别" -- 1969
	end -- 1969
	if self.phase == "gate-count" then -- 1969
		return "数数 " .. tostring(self.countTick) -- 1972
	end -- 1972
	return "她走" -- 1974
end -- 1961
function Play.prototype.dogLabel(self) -- 1978
	if self.dogState == "ear" then -- 1978
		return "转耳" -- 1980
	end -- 1980
	if self.dogState == "chase" then -- 1980
		return "追" -- 1983
	end -- 1983
	if self.dogState == "sniff" then -- 1983
		return "停" -- 1986
	end -- 1986
	if self.dogState == "back" then -- 1986
		return "回线" -- 1989
	end -- 1989
	return "巡逻" -- 1991
end -- 1978
function Play.prototype.doorXOf(self) -- 1994
	local ____temp_16 -- 1995
	if self.room.story == nil then -- 1995
		____temp_16 = nil -- 1995
	else -- 1995
		____temp_16 = self.room.story.tower -- 1995
	end -- 1995
	local t = ____temp_16 -- 1995
	return t == nil and 0 or t.doorX -- 1996
end -- 1994
function Play.prototype.scavLabel(self) -- 2000
	if self.scavState == "chase" then -- 2000
		return "追" -- 2002
	end -- 2002
	if self.scavState == "turn" then -- 2002
		return "转头" -- 2005
	end -- 2005
	if self.scavState == "walk" then -- 2005
		return "赶来" -- 2008
	end -- 2008
	if self.scavState == "stall" then -- 2008
		return "停住" -- 2011
	end -- 2011
	if self.scavState == "back" then -- 2011
		return "回位" -- 2014
	end -- 2014
	return "巡逻" -- 2016
end -- 2000
function Play.prototype.hintText(self) -- 2020
	if self.paused then -- 2020
		return "Esc 继续 · R 重置" -- 2022
	end -- 2022
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 2022
		if self:threatened() then -- 2022
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 2028
		end -- 2028
		if self.coverHug then -- 2028
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 2031
		end -- 2031
		if self.coverNear then -- 2031
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 2034
		end -- 2034
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 2036
	end -- 2036
	if self.flash ~= "" then -- 2036
		return self.flash -- 2039
	end -- 2039
	if self.room.key == "prologue" then -- 2039
		if self.phase == "prologue-wait" then -- 2039
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 2043
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 2044
		end -- 2044
		if self.phase == "prologue-give" then -- 2044
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 2047
		end -- 2047
		return "她跟着你了 · 两人一起走到门口 680" -- 2049
	end -- 2049
	if self.room.key == "street" then -- 2049
		if self:aliveEnemies() > 0 then -- 2049
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 2053
		end -- 2053
		return "清完了 · 两人一起走到右边检查站入口 900" -- 2055
	end -- 2055
	if self.room.key == "gate" then -- 2055
		local ____temp_17 -- 2058
		if self.room.story == nil then -- 2058
			____temp_17 = nil -- 2058
		else -- 2058
			____temp_17 = self.room.story.gate -- 2058
		end -- 2058
		local g = ____temp_17 -- 2058
		if g ~= nil then -- 2058
			if self.phase == "gate-idle" then -- 2058
				if self.gateNeedConfirm then -- 2058
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 2062
				end -- 2062
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 2064
			end -- 2064
			if self.phase == "gate-hold" then -- 2064
				if self.coveredFlash > 0 then -- 2064
					return "掩体挡下了这一枪 · 别露头" -- 2068
				end -- 2068
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 2070
			end -- 2070
			if self.phase == "gate-send" then -- 2070
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 2073
			end -- 2073
			if self.phase == "gate-count" then -- 2073
				if self.countTick >= 1440 then -- 2073
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 2077
				end -- 2077
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 2079
			end -- 2079
			return "她自己走 · 跟着出城门 1120" -- 2081
		end -- 2081
	end -- 2081
	if self.room.key == "forest" then -- 2081
		if self.dogState == "chase" then -- 2081
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 2086
		end -- 2086
		if self.dogState == "ear" then -- 2086
			return "狗转耳朵了 · 停下或蹲下别出声" -- 2089
		end -- 2089
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 2091
	end -- 2091
	if self.room.key == "tower" then -- 2091
		if self.phase == "tower-wait" then -- 2091
			return "走到门前 445 点一次 E 敲两下" -- 2095
		end -- 2095
		if self.phase == "tower-knock" then -- 2095
			return "敲两下 · 等门开" -- 2098
		end -- 2098
		if self.phase == "tower-given" then -- 2098
			return "递交针套和纸条 · 看登记簿最后一行" -- 2101
		end -- 2101
		return "片尾 · 点 E 再玩一次，回到序章" -- 2103
	end -- 2103
	if self.room.key == "village" then -- 2103
		if self.bottleFly ~= nil then -- 2103
			return "等瓶子落地 · 触地才发声" -- 2107
		end -- 2107
		if self.hasBottle then -- 2107
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 2110
		end -- 2110
		if self.passed then -- 2110
			return "已过第一院 · R 重置可再来一遍" -- 2113
		end -- 2113
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 2115
	end -- 2115
	if self.room.key == "outside" then -- 2115
		if self.focusCart then -- 2115
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 2119
		end -- 2119
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 2121
	end -- 2121
	if self.escort.state == "frozen" then -- 2121
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 2121
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 2125
		end -- 2125
		return "小满吓住了 · 走过去，靠近再点 E" -- 2127
	end -- 2127
	if self.escort.state == "calming" then -- 2127
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 2130
	end -- 2130
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 2132
end -- 2020
function Play.prototype.draw(self, draw, w, h) -- 2137
	self.viewW = w -- 2138
	self.viewH = h -- 2139
	self.view = ____exports.computeViewport(w, h) -- 2140
	self:clampCamera(w, h) -- 2141
	draw:clear() -- 2142
	draw:drawRect( -- 2144
		Rect(0, 0, w, h), -- 2144
		BG_VOID -- 2144
	) -- 2144
	local box = self:canvasRect(w, h) -- 2145
	draw:drawRect(box, BG_FAR) -- 2146
	draw:drawRect( -- 2147
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 2147
		BG_MID -- 2147
	) -- 2147
	self:drawFloors(draw, w, h) -- 2149
	self:drawSolids(draw, w, h) -- 2150
	self:drawZones(draw, w, h) -- 2151
	self:drawArch(draw, w, h) -- 2152
	self:drawCart(draw, w, h) -- 2153
	self:drawActors(draw, w, h) -- 2154
	self:drawTrace(draw, w, h) -- 2155
	self:drawAim(draw, w, h) -- 2156
end -- 2137
function Play.prototype.canvasRect(self, w, h) -- 2160
	local v = self.view -- 2161
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 2162
end -- 2160
function Play.prototype.px(self, n) -- 2166
	return n * self.view.zoom -- 2167
end -- 2166
function Play.prototype.sx(self, wx, w) -- 2171
	local v = self.view -- 2172
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 2173
	return v.ox + lx * v.zoom -- 2174
end -- 2171
function Play.prototype.sy(self, wy, h) -- 2178
	local v = self.view -- 2179
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 2180
	return v.oy + ly * v.zoom -- 2181
end -- 2178
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 2184
	local px0 = self:sx(x0, w) -- 2185
	local px1 = self:sx(x1, w) -- 2186
	local py0 = self:sy(y0, h) -- 2187
	local py1 = self:sy(y1, h) -- 2188
	if px1 <= px0 or py1 <= py0 then -- 2188
		return -- 2190
	end -- 2190
	draw:drawRect( -- 2192
		Rect(px0, py0, px1 - px0, py1 - py0), -- 2192
		color -- 2192
	) -- 2192
end -- 2184
function Play.prototype.drawFloors(self, draw, w, h) -- 2195
	local i = 0 -- 2196
	do -- 2196
		i = 0 -- 2197
		while i < #self.room.floors do -- 2197
			local f = self.room.floors[i + 1] -- 2198
			local y = self:sy(f.y, h) -- 2199
			local x0 = self:sx(f.x0, w) -- 2200
			local x1 = self:sx(f.x1, w) -- 2201
			local deck = self:px(5) -- 2202
			draw:drawRect( -- 2203
				Rect(x0, y - deck, x1 - x0, deck), -- 2203
				FLOOR_DECK -- 2203
			) -- 2203
			draw:drawSegment( -- 2204
				Vec2(x0, y), -- 2204
				Vec2(x1, y), -- 2204
				self:px(1), -- 2204
				GROUND -- 2204
			) -- 2204
			i = i + 1 -- 2197
		end -- 2197
	end -- 2197
end -- 2195
function Play.prototype.drawSolids(self, draw, w, h) -- 2208
	local i = 0 -- 2209
	do -- 2209
		i = 0 -- 2210
		while i < #self.boxes do -- 2210
			do -- 2210
				local b = self.boxes[i + 1] -- 2211
				if b.y0 < -4 and b.y1 <= 96 then -- 2211
					draw:drawSegment( -- 2214
						Vec2( -- 2214
							self:sx(b.x0, w), -- 2214
							self:sy(b.y1, h) -- 2214
						), -- 2214
						Vec2( -- 2214
							self:sx(b.x1, w), -- 2214
							self:sy(b.y1, h) -- 2214
						), -- 2214
						self:px(1), -- 2214
						GROUND -- 2214
					) -- 2214
					goto __continue447 -- 2215
				end -- 2215
				self:drawBox( -- 2217
					draw, -- 2217
					w, -- 2217
					h, -- 2217
					b.x0, -- 2217
					b.x1, -- 2217
					b.y0, -- 2217
					b.y1, -- 2217
					SOLID_FILL -- 2217
				) -- 2217
				draw:drawSegment( -- 2218
					Vec2( -- 2218
						self:sx(b.x0, w), -- 2218
						self:sy(b.y1, h) -- 2218
					), -- 2218
					Vec2( -- 2218
						self:sx(b.x1, w), -- 2218
						self:sy(b.y1, h) -- 2218
					), -- 2218
					self:px(1), -- 2218
					SOLID_EDGE -- 2218
				) -- 2218
			end -- 2218
			::__continue447:: -- 2218
			i = i + 1 -- 2210
		end -- 2210
	end -- 2210
end -- 2208
function Play.prototype.drawZones(self, draw, w, h) -- 2222
	local i = 0 -- 2223
	do -- 2223
		i = 0 -- 2224
		while i < #self.room.zones do -- 2224
			local z = self.room.zones[i + 1] -- 2225
			local fill = DANGER -- 2226
			local line = DANGER_LINE -- 2227
			if z.tint == 2 then -- 2227
				fill = SOFT -- 2229
				line = SOFT_LINE -- 2230
			elseif z.tint == 3 then -- 2230
				fill = BRICK -- 2232
				line = BRICK_LINE -- 2233
			elseif z.tint == 4 then -- 2233
				fill = PASS -- 2235
				line = PASS_LINE -- 2236
			end -- 2236
			self:drawBox( -- 2238
				draw, -- 2238
				w, -- 2238
				h, -- 2238
				z.x0, -- 2238
				z.x1, -- 2238
				z.y, -- 2238
				z.y + z.h, -- 2238
				fill -- 2238
			) -- 2238
			draw:drawSegment( -- 2239
				Vec2( -- 2239
					self:sx(z.x0, w), -- 2239
					self:sy(z.y, h) -- 2239
				), -- 2239
				Vec2( -- 2239
					self:sx(z.x0, w), -- 2239
					self:sy(z.y + z.h, h) -- 2239
				), -- 2239
				self:px(1), -- 2239
				line -- 2239
			) -- 2239
			draw:drawSegment( -- 2240
				Vec2( -- 2240
					self:sx(z.x1, w), -- 2240
					self:sy(z.y, h) -- 2240
				), -- 2240
				Vec2( -- 2240
					self:sx(z.x1, w), -- 2240
					self:sy(z.y + z.h, h) -- 2240
				), -- 2240
				self:px(1), -- 2240
				line -- 2240
			) -- 2240
			i = i + 1 -- 2224
		end -- 2224
	end -- 2224
end -- 2222
function Play.prototype.drawArch(self, draw, w, h) -- 2244
	local a = self.room.arch -- 2245
	if a.h <= 0 then -- 2245
		return -- 2247
	end -- 2247
	self:drawBox( -- 2249
		draw, -- 2249
		w, -- 2249
		h, -- 2249
		a.x0, -- 2249
		a.x1, -- 2249
		a.y, -- 2249
		a.y + a.h, -- 2249
		HOLE_FILL -- 2249
	) -- 2249
	draw:drawSegment( -- 2250
		Vec2( -- 2250
			self:sx(a.x0, w), -- 2250
			self:sy(a.y + a.h, h) -- 2250
		), -- 2250
		Vec2( -- 2250
			self:sx(a.x1, w), -- 2250
			self:sy(a.y + a.h, h) -- 2250
		), -- 2250
		self:px(1), -- 2250
		SOLID_EDGE -- 2250
	) -- 2250
	draw:drawSegment( -- 2251
		Vec2( -- 2251
			self:sx(a.x0, w), -- 2251
			self:sy(a.y, h) -- 2251
		), -- 2251
		Vec2( -- 2251
			self:sx(a.x0, w), -- 2251
			self:sy(a.y + a.h, h) -- 2251
		), -- 2251
		self:px(1), -- 2251
		SOLID_EDGE -- 2251
	) -- 2251
	draw:drawSegment( -- 2252
		Vec2( -- 2252
			self:sx(a.x1, w), -- 2252
			self:sy(a.y, h) -- 2252
		), -- 2252
		Vec2( -- 2252
			self:sx(a.x1, w), -- 2252
			self:sy(a.y + a.h, h) -- 2252
		), -- 2252
		self:px(1), -- 2252
		SOLID_EDGE -- 2252
	) -- 2252
end -- 2244
function Play.prototype.drawCart(self, draw, w, h) -- 2255
	local c = self.room.cart -- 2256
	if c.bodyW <= 0 then -- 2256
		return -- 2258
	end -- 2258
	drawCartShape( -- 2260
		draw, -- 2260
		self, -- 2260
		w, -- 2260
		h, -- 2260
		c, -- 2260
		self.cartAxle -- 2260
	) -- 2260
	draw:drawRect( -- 2261
		Rect( -- 2261
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 2261
			self:sy(c.baseY + 40, h), -- 2261
			self:px(2), -- 2261
			self:px(40) -- 2261
		), -- 2261
		STAND -- 2261
	) -- 2261
end -- 2255
function Play.prototype.drawActors(self, draw, w, h) -- 2264
	local p = self.player -- 2265
	local isChild = self.childMode -- 2266
	if p.covered then -- 2266
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 2269
		draw:drawSegment( -- 2270
			Vec2( -- 2270
				self:sx(edge, w), -- 2270
				self:sy(p.y + 8, h) -- 2270
			), -- 2270
			Vec2( -- 2270
				self:sx(edge, w), -- 2270
				self:sy(p.y + p.h * 0.62, h) -- 2270
			), -- 2270
			self:px(2), -- 2270
			STAND -- 2270
		) -- 2270
		draw:drawSegment( -- 2272
			Vec2( -- 2272
				self:sx(p.x - 8, w), -- 2272
				self:sy(p.y + p.h + 3, h) -- 2272
			), -- 2272
			Vec2( -- 2272
				self:sx(p.x + 8, w), -- 2272
				self:sy(p.y + p.h + 3, h) -- 2272
			), -- 2272
			self:px(2), -- 2272
			STAND -- 2272
		) -- 2272
	elseif self.coverNear and not isChild then -- 2272
		draw:drawRect( -- 2275
			Rect( -- 2275
				self:sx(p.x - 3, w), -- 2275
				self:sy(p.y + 1, h), -- 2275
				self:px(3), -- 2275
				self:px(3) -- 2275
			), -- 2275
			STAND -- 2275
		) -- 2275
	end -- 2275
	drawFigure( -- 2277
		draw, -- 2277
		self, -- 2277
		w, -- 2277
		h, -- 2277
		p, -- 2277
		isChild and CHILD_BODY or SOLDIER_BODY, -- 2277
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 2277
	) -- 2277
	local q = self.partner -- 2278
	if q.alive then -- 2278
		local childPartner = q.w == CHILD_W -- 2280
		drawFigure( -- 2281
			draw, -- 2281
			self, -- 2281
			w, -- 2281
			h, -- 2281
			q, -- 2281
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 2281
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 2281
		) -- 2281
	end -- 2281
	local i = 0 -- 2283
	do -- 2283
		i = 0 -- 2284
		while i < #self.enemies do -- 2284
			local e = self.enemies[i + 1] -- 2285
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 2286
			self:drawBox( -- 2287
				draw, -- 2287
				w, -- 2287
				h, -- 2287
				e.x - e.w / 2, -- 2287
				e.x + e.w / 2, -- 2287
				e.y, -- 2287
				e.y + e.h, -- 2287
				col -- 2287
			) -- 2287
			if e.alive and e.warnT > 0 then -- 2287
				local gunX = self:sx(e.x, w) -- 2290
				local gunY = self:sy(e.y + e.h * 0.72, h) -- 2291
				local aimX = self:sx(p.x, w) -- 2292
				local aimY = self:sy(p.y + p.h * 0.55, h) -- 2293
				local seg = 8 -- 2294
				local s = 0 -- 2295
				do -- 2295
					s = 0 -- 2296
					while s < seg do -- 2296
						local t0 = s / seg -- 2297
						local t1 = (s + 1) / seg -- 2298
						draw:drawSegment( -- 2299
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 2300
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 2301
							self:px(1), -- 2302
							DANGER -- 2302
						) -- 2302
						s = s + 2 -- 2296
					end -- 2296
				end -- 2296
			end -- 2296
			i = i + 1 -- 2284
		end -- 2284
	end -- 2284
	local k = 0 -- 2307
	do -- 2307
		k = 0 -- 2308
		while k < #self.room.marks do -- 2308
			do -- 2308
				local m = self.room.marks[k + 1] -- 2309
				if m.kind ~= 0 then -- 2309
					goto __continue469 -- 2311
				end -- 2311
				local on = self.checkpoint == m.x -- 2313
				local x = self:sx(m.x, w) -- 2314
				local y = self:sy(m.y, h) -- 2315
				draw:drawSegment( -- 2316
					Vec2(x, y), -- 2316
					Vec2( -- 2316
						x, -- 2316
						y + self:px(35) -- 2316
					), -- 2316
					self:px(1), -- 2316
					on and CHECK or INK_DIM -- 2316
				) -- 2316
				draw:drawDot( -- 2317
					Vec2( -- 2317
						x, -- 2317
						y + self:px(35) -- 2317
					), -- 2317
					self:px(2), -- 2317
					on and CHECK or INK_DIM -- 2317
				) -- 2317
			end -- 2317
			::__continue469:: -- 2317
			k = k + 1 -- 2308
		end -- 2308
	end -- 2308
	local j = 0 -- 2321
	do -- 2321
		j = 0 -- 2322
		while j < #self.room.marks do -- 2322
			do -- 2322
				local m = self.room.marks[j + 1] -- 2323
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 2323
					goto __continue472 -- 2325
				end -- 2325
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 2325
					goto __continue472 -- 2329
				end -- 2329
				local col = STAND -- 2331
				if m.kind == 4 then -- 2331
					col = PASS_LINE -- 2333
				elseif m.kind == 5 then -- 2333
					col = BRICK_LINE -- 2335
				end -- 2335
				local mx = self:sx(m.x, w) -- 2337
				local my = self:sy(m.y, h) -- 2338
				draw:drawSegment( -- 2339
					Vec2(mx, my), -- 2339
					Vec2( -- 2339
						mx, -- 2339
						my + self:px(24) -- 2339
					), -- 2339
					self:px(1), -- 2339
					col -- 2339
				) -- 2339
			end -- 2339
			::__continue472:: -- 2339
			j = j + 1 -- 2322
		end -- 2322
	end -- 2322
	local t = 0 -- 2342
	do -- 2342
		t = 0 -- 2343
		while t < #self.room.marks do -- 2343
			do -- 2343
				local m = self.room.marks[t + 1] -- 2344
				if m.kind ~= 6 then -- 2344
					goto __continue478 -- 2346
				end -- 2346
				local mx = self:sx(m.x, w) -- 2348
				local my = self:sy(m.y, h) -- 2349
				draw:drawSegment( -- 2350
					Vec2(mx, my), -- 2350
					Vec2( -- 2350
						mx, -- 2350
						my + self:px(30) -- 2350
					), -- 2350
					self:px(1), -- 2350
					INK_DIM -- 2350
				) -- 2350
				self:drawBox( -- 2351
					draw, -- 2351
					w, -- 2351
					h, -- 2351
					m.x - 5, -- 2351
					m.x + 5, -- 2351
					m.y + 30, -- 2351
					m.y + 40, -- 2351
					CHECK -- 2351
				) -- 2351
			end -- 2351
			::__continue478:: -- 2351
			t = t + 1 -- 2343
		end -- 2343
	end -- 2343
	if self.room.key == "village" then -- 2343
		self:drawVillage(draw, w, h) -- 2354
	end -- 2354
	if self.room.key == "forest" then -- 2354
		self:drawDog(draw, w, h) -- 2357
	end -- 2357
end -- 2264
function Play.prototype.drawDog(self, draw, w, h) -- 2362
	local x = self.dogX -- 2363
	self:drawBox( -- 2364
		draw, -- 2364
		w, -- 2364
		h, -- 2364
		x - 14, -- 2364
		x + 14, -- 2364
		0, -- 2364
		20, -- 2364
		SCAV_BODY -- 2364
	) -- 2364
	self:drawBox( -- 2365
		draw, -- 2365
		w, -- 2365
		h, -- 2365
		x - 10, -- 2365
		x - 2, -- 2365
		20, -- 2365
		30, -- 2365
		SCAV_BODY -- 2365
	) -- 2365
	self:drawBox( -- 2366
		draw, -- 2366
		w, -- 2366
		h, -- 2366
		x + 2, -- 2366
		x + 10, -- 2366
		20, -- 2366
		30, -- 2366
		SCAV_HEAD -- 2366
	) -- 2366
	if self.dogState == "ear" or self.dogState == "chase" then -- 2366
		draw:drawSegment( -- 2368
			Vec2( -- 2368
				self:sx(x, w), -- 2368
				self:sy(30, h) -- 2368
			), -- 2368
			Vec2( -- 2369
				self:sx(x, w), -- 2369
				self:sy(40, h) -- 2369
			), -- 2369
			self:px(1), -- 2369
			DANGER -- 2369
		) -- 2369
	end -- 2369
end -- 2362
function Play.prototype.drawVillage(self, draw, w, h) -- 2374
	local bottle = self.room.bottle -- 2375
	if bottle ~= nil then -- 2375
		self:drawBox( -- 2377
			draw, -- 2377
			w, -- 2377
			h, -- 2377
			bottle.x - 14, -- 2377
			bottle.x + 14, -- 2377
			0, -- 2377
			64, -- 2377
			SOLID_FILL -- 2377
		) -- 2377
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 2377
			self:drawBottle( -- 2379
				draw, -- 2379
				w, -- 2379
				h, -- 2379
				bottle.x, -- 2379
				64 -- 2379
			) -- 2379
		end -- 2379
	end -- 2379
	self:drawBox( -- 2383
		draw, -- 2383
		w, -- 2383
		h, -- 2383
		300, -- 2383
		420, -- 2383
		44, -- 2383
		50, -- 2383
		FLOOR_DECK -- 2383
	) -- 2383
	self:drawBox( -- 2384
		draw, -- 2384
		w, -- 2384
		h, -- 2384
		300, -- 2384
		306, -- 2384
		0, -- 2384
		44, -- 2384
		FLOOR_DECK -- 2384
	) -- 2384
	self:drawBox( -- 2385
		draw, -- 2385
		w, -- 2385
		h, -- 2385
		414, -- 2385
		420, -- 2385
		0, -- 2385
		44, -- 2385
		FLOOR_DECK -- 2385
	) -- 2385
	local s = self.room.scavenger -- 2387
	if s ~= nil then -- 2387
		local sx0 = self.scavX -- 2389
		self:drawBox( -- 2390
			draw, -- 2390
			w, -- 2390
			h, -- 2390
			sx0 - 12, -- 2390
			sx0 + 12, -- 2390
			0, -- 2390
			s.h - 14, -- 2390
			SCAV_BODY -- 2390
		) -- 2390
		self:drawBox( -- 2391
			draw, -- 2391
			w, -- 2391
			h, -- 2391
			sx0 - 7, -- 2391
			sx0 + 7, -- 2391
			s.h - 14, -- 2391
			s.h, -- 2391
			SCAV_HEAD -- 2391
		) -- 2391
		if self.scavState == "turn" then -- 2391
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 2393
			draw:drawSegment( -- 2394
				Vec2( -- 2394
					self:sx(sx0, w), -- 2394
					self:sy(s.h - 6, h) -- 2394
				), -- 2394
				Vec2( -- 2394
					self:sx(fx, w), -- 2394
					self:sy(s.h - 6, h) -- 2394
				), -- 2394
				self:px(1), -- 2394
				INK -- 2394
			) -- 2394
		end -- 2394
	end -- 2394
	if self.hasBottle then -- 2394
		local p = self.player -- 2399
		self:drawBottle( -- 2400
			draw, -- 2400
			w, -- 2400
			h, -- 2400
			p.x + p.facing * 10, -- 2400
			p.y + p.h * 0.62 -- 2400
		) -- 2400
	end -- 2400
	if self.bottleFly ~= nil then -- 2400
		self:drawBottle( -- 2403
			draw, -- 2403
			w, -- 2403
			h, -- 2403
			self.bottleFly.x, -- 2403
			self.bottleFly.y -- 2403
		) -- 2403
	end -- 2403
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 2403
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 2406
		draw:drawCircle( -- 2407
			Vec2( -- 2407
				self:sx(self.bottleLandX, w), -- 2407
				self:sy(0, h) -- 2407
			), -- 2407
			self:px(r / ____exports.UNITS_PER_PX), -- 2407
			BRICK_LINE -- 2407
		) -- 2407
	end -- 2407
end -- 2374
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 2411
	self:drawBox( -- 2412
		draw, -- 2412
		w, -- 2412
		h, -- 2412
		x - 3, -- 2412
		x + 3, -- 2412
		y - 10, -- 2412
		y, -- 2412
		BOTTLE -- 2412
	) -- 2412
end -- 2411
function Play.prototype.drawTrace(self, draw, w, h) -- 2415
	local t = self.trace -- 2416
	if t == nil or self.traceT <= 0 then -- 2416
		return -- 2418
	end -- 2418
	draw:drawSegment( -- 2420
		Vec2( -- 2421
			self:sx(t.x0, w), -- 2421
			self:sy(t.y0, h) -- 2421
		), -- 2421
		Vec2( -- 2422
			self:sx(t.x1, w), -- 2422
			self:sy(t.y1, h) -- 2422
		), -- 2422
		self:px(1), -- 2423
		t.hit and AIM_HIT or INK_DIM -- 2423
	) -- 2423
end -- 2415
function Play.prototype.drawAim(self, draw, w, h) -- 2426
	local v = self.view -- 2428
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 2429
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 2430
	local dot = self:px(1) -- 2431
	local arm = self:px(3) -- 2432
	local gap = self:px(1) -- 2433
	draw:drawSegment( -- 2434
		Vec2(gx - arm - gap, gy), -- 2434
		Vec2(gx - gap, gy), -- 2434
		dot / 2, -- 2434
		AIM -- 2434
	) -- 2434
	draw:drawSegment( -- 2435
		Vec2(gx + gap, gy), -- 2435
		Vec2(gx + arm + gap, gy), -- 2435
		dot / 2, -- 2435
		AIM -- 2435
	) -- 2435
	draw:drawSegment( -- 2436
		Vec2(gx, gy - arm - gap), -- 2436
		Vec2(gx, gy - gap), -- 2436
		dot / 2, -- 2436
		AIM -- 2436
	) -- 2436
	draw:drawSegment( -- 2437
		Vec2(gx, gy + gap), -- 2437
		Vec2(gx, gy + arm + gap), -- 2437
		dot / 2, -- 2437
		AIM -- 2437
	) -- 2437
	if self.room.key == "village" and self.hasBottle then -- 2437
		local p = self.player -- 2441
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2443
		local dir = ____end.x >= p.x and 1 or -1 -- 2444
		local x0 = p.x + dir * 10 -- 2445
		local y0 = p.y + p.h * 0.7 -- 2446
		local T = 0.62 -- 2447
		local vx = (____end.x - x0) / T -- 2448
		local vy = (____end.y - y0 + 0.5 * GRAVITY * T * T) / T -- 2449
		local pxr = x0 -- 2450
		local pyr = y0 -- 2451
		local t = 1 -- 2452
		do -- 2452
			t = 1 -- 2453
			while t <= 12 do -- 2453
				local tt = t / 12 * T -- 2454
				local nx = x0 + vx * tt -- 2455
				local ny = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 2456
				draw:drawSegment( -- 2457
					Vec2( -- 2457
						self:sx(pxr, w), -- 2457
						self:sy(pyr, h) -- 2457
					), -- 2457
					Vec2( -- 2457
						self:sx(nx, w), -- 2457
						self:sy(ny, h) -- 2457
					), -- 2457
					self:px(1) / 2, -- 2457
					BOTTLE -- 2457
				) -- 2457
				pxr = nx -- 2458
				pyr = ny -- 2459
				t = t + 1 -- 2453
			end -- 2453
		end -- 2453
		draw:drawCircle( -- 2461
			Vec2( -- 2461
				self:sx(____end.x, w), -- 2461
				self:sy(____end.y + 2, h) -- 2461
			), -- 2461
			self:px(2), -- 2461
			BOTTLE -- 2461
		) -- 2461
	end -- 2461
end -- 2426
return ____exports -- 2426