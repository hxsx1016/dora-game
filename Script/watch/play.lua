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
function makeActor(room, index) -- 2460
	local sp = room.spawns -- 2461
	if index < 0 or index >= #sp then -- 2461
		return { -- 2463
			x = 0, -- 2463
			y = 0, -- 2463
			vx = 0, -- 2463
			vy = 0, -- 2463
			w = CHILD_W, -- 2463
			h = CHILD_H, -- 2463
			onGround = true, -- 2463
			facing = 1, -- 2463
			crouch = false, -- 2463
			rollT = 0, -- 2463
			covered = false, -- 2463
			alive = false -- 2463
		} -- 2463
	end -- 2463
	local s = sp[index + 1] -- 2465
	local child = s.h <= CHILD_H -- 2466
	return { -- 2467
		x = s.x, -- 2468
		y = s.y, -- 2468
		vx = 0, -- 2468
		vy = 0, -- 2468
		w = child and CHILD_W or SOLDIER_W, -- 2469
		h = child and CHILD_H or SOLDIER_H, -- 2470
		onGround = true, -- 2471
		facing = 1, -- 2471
		crouch = false, -- 2471
		rollT = 0, -- 2471
		covered = false, -- 2471
		alive = true -- 2471
	} -- 2471
end -- 2471
function drawFigure(draw, play, w, h, a, body, head) -- 2475
	if not a.alive then -- 2475
		return -- 2477
	end -- 2477
	local x0 = a.x - a.w / 2 -- 2479
	local x1 = a.x + a.w / 2 -- 2480
	local y0 = a.y -- 2481
	local y1 = a.y + a.h -- 2482
	play:drawBox( -- 2483
		draw, -- 2483
		w, -- 2483
		h, -- 2483
		x0, -- 2483
		x1, -- 2483
		y0, -- 2483
		y1 - a.h * 0.26, -- 2483
		body -- 2483
	) -- 2483
	play:drawBox( -- 2484
		draw, -- 2484
		w, -- 2484
		h, -- 2484
		x0 + 2, -- 2484
		x1 - 2, -- 2484
		y1 - a.h * 0.26, -- 2484
		y1, -- 2484
		head -- 2484
	) -- 2484
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 2486
	play:drawBox( -- 2487
		draw, -- 2487
		w, -- 2487
		h, -- 2487
		eyeX, -- 2487
		eyeX + 4, -- 2487
		y1 - a.h * 0.14, -- 2487
		y1 - a.h * 0.08, -- 2487
		INK -- 2487
	) -- 2487
end -- 2487
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 2491
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 2492
end -- 2491
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 2499
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 2500
end -- 2499
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 2507
	local tmin = 0 -- 2508
	local tmax = 99999 -- 2509
	if dx == 0 then -- 2509
		if ox < x0 or ox > x1 then -- 2509
			return -1 -- 2512
		end -- 2512
	else -- 2512
		local t1 = (x0 - ox) / dx -- 2515
		local t2 = (x1 - ox) / dx -- 2516
		local lo = t1 < t2 and t1 or t2 -- 2517
		local hi = t1 < t2 and t2 or t1 -- 2518
		if lo > tmin then -- 2518
			tmin = lo -- 2520
		end -- 2520
		if hi < tmax then -- 2520
			tmax = hi -- 2523
		end -- 2523
	end -- 2523
	if dy == 0 then -- 2523
		if oy < y0 or oy > y1 then -- 2523
			return -1 -- 2528
		end -- 2528
	else -- 2528
		local t1 = (y0 - oy) / dy -- 2531
		local t2 = (y1 - oy) / dy -- 2532
		local lo = t1 < t2 and t1 or t2 -- 2533
		local hi = t1 < t2 and t2 or t1 -- 2534
		if lo > tmin then -- 2534
			tmin = lo -- 2536
		end -- 2536
		if hi < tmax then -- 2536
			tmax = hi -- 2539
		end -- 2539
	end -- 2539
	return tmax >= tmin and tmin or -1 -- 2542
end -- 2542
function drawCartShape(draw, play, w, h, c, axleX) -- 2545
	local half = c.bodyW / 2 -- 2546
	local x0 = axleX - half -- 2547
	local x1 = axleX + half -- 2548
	play:drawBox( -- 2549
		draw, -- 2549
		w, -- 2549
		h, -- 2549
		x0, -- 2549
		x1, -- 2549
		c.baseY + c.wheelR, -- 2549
		c.baseY + c.wheelR + c.bodyH, -- 2549
		CART_FILL -- 2549
	) -- 2549
	draw:drawCircle( -- 2550
		Vec2( -- 2550
			play:sx(x0 + c.bodyW * 0.28, w), -- 2550
			play:sy(c.baseY + c.wheelR, h) -- 2550
		), -- 2550
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2550
		Color(52, 50, 48, 255) -- 2550
	) -- 2550
	draw:drawCircle( -- 2551
		Vec2( -- 2551
			play:sx(x1 - c.bodyW * 0.28, w), -- 2551
			play:sy(c.baseY + c.wheelR, h) -- 2551
		), -- 2551
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2551
		Color(52, 50, 48, 255) -- 2551
	) -- 2551
	local cx = c.clothSide < 0 and x0 or x1 -- 2552
	play:drawBox( -- 2553
		draw, -- 2553
		w, -- 2553
		h, -- 2553
		cx - 10, -- 2553
		cx + 10, -- 2553
		c.baseY + c.wheelR + c.bodyH, -- 2553
		c.baseY + c.wheelR + c.bodyH + 18, -- 2553
		CLOTH -- 2553
	) -- 2553
end -- 2553
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
function Play.prototype.____constructor(self, room, resume) -- 315
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
	self.ox = room.originX -- 317
	self.room = withOrigin(room) -- 318
	local wr = self.room -- 319
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 320
	self:buildWorld() -- 321
	self.childMode = wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower" -- 323
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 324
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 325
	self.player = makeActor(wr, playerIdx) -- 326
	self.partner = makeActor(wr, partnerIdx) -- 327
	self.phase = phaseOf(wr.key) -- 328
	if wr.story ~= nil then -- 328
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 330
	end -- 330
	self.cam.x = self.player.x -- 332
	self.cam.y = self.player.y + CAM_LOOK_UP -- 333
	self.cartAxle = wr.cart.startX -- 334
	self.escort = __TS__New( -- 335
		Escort, -- 335
		safeAnchorX(wr.marks) -- 335
	) -- 335
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 336
	self:buildEnemies() -- 337
	if resume ~= nil and resume.checkpoint > 0 then -- 337
		self.checkpoint = resume.checkpoint -- 340
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 340
			self.cartAxle = self.room.cart.endX -- 342
			self.cartDocked = true -- 343
			self.player.x = self.ox + 380 -- 346
			self.player.y = 0 -- 347
			self.player.vy = 0 -- 348
			self.player.onGround = true -- 349
			self.cam.x = self.player.x -- 350
			self.cam.y = self.player.y + CAM_LOOK_UP -- 351
		end -- 351
	end -- 351
end -- 315
function Play.prototype.buildWorld(self) -- 357
	local room = self.room -- 358
	self.boxes = {} -- 359
	self.floors = {} -- 360
	local i = 0 -- 361
	do -- 361
		i = 0 -- 362
		while i < #room.floors do -- 362
			local f = room.floors[i + 1] -- 363
			local ____self_floors_0 = self.floors -- 363
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 364
			i = i + 1 -- 362
		end -- 362
	end -- 362
	do -- 362
		i = 0 -- 366
		while i < #room.solids do -- 366
			local s = room.solids[i + 1] -- 367
			local ____self_boxes_1 = self.boxes -- 367
			____self_boxes_1[#____self_boxes_1 + 1] = { -- 368
				x0 = s.x, -- 368
				x1 = s.x + s.w, -- 368
				y0 = s.y, -- 368
				y1 = s.y + s.h, -- 368
				passable = s.passable == true -- 368
			} -- 368
			i = i + 1 -- 366
		end -- 366
	end -- 366
	do -- 366
		i = 0 -- 370
		while i < #room.stairs do -- 370
			local st = room.stairs[i + 1] -- 371
			local n = st.steps + 1 -- 372
			local stepW = (st.x1 - st.x0) / n -- 373
			local k = 0 -- 374
			do -- 374
				k = 0 -- 375
				while k < n do -- 375
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 376
					local x0 = st.x0 + stepW * k -- 377
					local ____self_boxes_2 = self.boxes -- 377
					____self_boxes_2[#____self_boxes_2 + 1] = { -- 379
						x0 = x0, -- 379
						x1 = x0 + stepW, -- 379
						y0 = -8, -- 379
						y1 = y, -- 379
						passable = true -- 379
					} -- 379
					k = k + 1 -- 375
				end -- 375
			end -- 375
			i = i + 1 -- 370
		end -- 370
	end -- 370
end -- 357
function Play.prototype.buildEnemies(self) -- 384
	self.enemies = {} -- 385
	if self.room.key == "checkpoint" then -- 385
		local ____self_enemies_3 = self.enemies -- 385
		____self_enemies_3[#____self_enemies_3 + 1] = { -- 387
			x = self.ox + 430, -- 387
			y = 0, -- 387
			w = 26, -- 387
			h = 84, -- 387
			alive = true, -- 387
			hitT = 0, -- 387
			warnT = 0, -- 387
			fireCd = 0 -- 387
		} -- 387
		local ____self_enemies_4 = self.enemies -- 387
		____self_enemies_4[#____self_enemies_4 + 1] = { -- 388
			x = self.ox + 505, -- 388
			y = 0, -- 388
			w = 26, -- 388
			h = 84, -- 388
			alive = true, -- 388
			hitT = 0, -- 388
			warnT = 0, -- 388
			fireCd = 0 -- 388
		} -- 388
		return -- 389
	end -- 389
	if self.room.key == "street" then -- 389
		local ____self_enemies_5 = self.enemies -- 389
		____self_enemies_5[#____self_enemies_5 + 1] = { -- 393
			x = self.ox + 340, -- 393
			y = 0, -- 393
			w = 26, -- 393
			h = 84, -- 393
			alive = true, -- 393
			hitT = 0, -- 393
			warnT = 0, -- 393
			fireCd = 0 -- 393
		} -- 393
		local ____self_enemies_6 = self.enemies -- 393
		____self_enemies_6[#____self_enemies_6 + 1] = { -- 394
			x = self.ox + 560, -- 394
			y = 0, -- 394
			w = 26, -- 394
			h = 84, -- 394
			alive = true, -- 394
			hitT = 0, -- 394
			warnT = 0, -- 394
			fireCd = 0 -- 394
		} -- 394
	end -- 394
end -- 384
function Play.prototype.update(self, dt, input) -- 400
	if input.pause.pressed then -- 400
		self.paused = not self.paused -- 402
	end -- 402
	if self.flashT > 0 then -- 402
		self.flashT = self.flashT - dt -- 405
		if self.flashT <= 0 then -- 405
			self.flash = "" -- 407
		end -- 407
	end -- 407
	if self.traceT > 0 then -- 407
		self.traceT = self.traceT - dt -- 411
		if self.traceT <= 0 then -- 411
			self.trace = nil -- 413
		end -- 413
	end -- 413
	if self.paused then -- 413
		self:updateCamera(dt) -- 417
		return -- 418
	end -- 418
	self.ticks = self.ticks + 1 -- 421
	local p = self.player -- 422
	self:stepPlayer(p, dt, input) -- 423
	self:stepEnemies(dt, input) -- 425
	self:stepStory(dt, input) -- 426
	self:stepEscort(dt, input) -- 427
	self:stepVillage(dt, input) -- 428
	self:stepChase(dt, input) -- 429
	self:stepInteract(dt, input) -- 430
	self:updateGate() -- 431
	self:updateCamera(dt) -- 432
end -- 400
function Play.prototype.nearCover(self, a) -- 436
	local i = 0 -- 437
	do -- 437
		i = 0 -- 438
		while i < #self.boxes do -- 438
			do -- 438
				local b = self.boxes[i + 1] -- 439
				if b.passable == true or b.y1 - b.y0 < 44 then -- 439
					goto __continue35 -- 441
				end -- 441
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 441
					goto __continue35 -- 444
				end -- 444
				local half = a.w / 2 -- 446
				if math.min( -- 446
					math.abs(a.x + half - b.x0), -- 447
					math.abs(a.x - half - b.x1) -- 447
				) < 24 then -- 447
					return true -- 448
				end -- 448
			end -- 448
			::__continue35:: -- 448
			i = i + 1 -- 438
		end -- 438
	end -- 438
	return false -- 451
end -- 436
function Play.prototype.nearLowLedge(self, a) -- 455
	local reach = 26 -- 456
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 457
	local x1 = x0 + reach -- 458
	local i = 0 -- 459
	do -- 459
		i = 0 -- 460
		while i < #self.boxes do -- 460
			do -- 460
				local b = self.boxes[i + 1] -- 461
				if b.x1 <= x0 or b.x0 >= x1 then -- 461
					goto __continue41 -- 463
				end -- 463
				local rise = b.y1 - a.y -- 465
				if rise > 0 and rise <= LEDGE_RISE then -- 465
					return true -- 467
				end -- 467
			end -- 467
			::__continue41:: -- 467
			i = i + 1 -- 460
		end -- 460
	end -- 460
	return false -- 470
end -- 455
function Play.prototype.stepPlayer(self, a, dt, input) -- 473
	if not a.alive then -- 473
		return -- 475
	end -- 475
	local isChild = self.childMode -- 477
	if self:storyLocked() then -- 477
		a.vx = 0 -- 480
		a.crouch = false -- 481
		a.h = isChild and CHILD_H or SOLDIER_H -- 482
		self:fallY(a, dt) -- 483
		return -- 484
	end -- 484
	if not isChild and self.escort.state == "calming" then -- 484
		a.crouch = false -- 488
		a.h = SOLDIER_H -- 489
		a.vx = 0 -- 490
		self:fallY(a, dt) -- 491
		return -- 492
	end -- 492
	a.crouch = isChild and input.crouch.held and a.onGround -- 494
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 495
	local nearCover = not isChild and self:nearCover(a) -- 496
	a.covered = nearCover and input.cover.held -- 497
	if not isChild then -- 497
		self.coverHug = a.covered -- 499
		self.coverNear = nearCover -- 500
	end -- 500
	if a.rollT > 0 then -- 500
		a.rollT = a.rollT - dt -- 505
		a.vx = a.facing * ROLL_SPEED -- 506
		self:slideX(a, a.vx * dt) -- 507
		self:fallY(a, dt) -- 508
		if a.rollT <= 0 then -- 508
			self:flashSet("翻滚结束", 0.5) -- 510
		end -- 510
		return -- 512
	end -- 512
	if not isChild and input.jump.pressed and a.onGround then -- 512
		if input.moveX ~= 0 then -- 512
			a.facing = input.moveX > 0 and 1 or -1 -- 517
		end -- 517
		if self:nearLowLedge(a) then -- 517
			a.vy = SOLDIER_JUMP -- 521
			a.onGround = false -- 522
			self:flashSet("翻上去", 0.3) -- 523
			return -- 524
		end -- 524
		a.rollT = ROLL_TIME -- 526
		self:flashSet("翻滚", 0.3) -- 527
		return -- 528
	end -- 528
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 531
	if isChild then -- 531
		if input.cover.held then -- 531
			speed = CHILD_SLOW -- 534
		end -- 534
		if a.crouch then -- 534
			speed = CHILD_SLOW -- 537
		end -- 537
	elseif a.covered then -- 537
		speed = SOLDIER_SPEED * 0.45 -- 540
	end -- 540
	local dir = self.gripping and 0 or input.moveX -- 544
	if dir ~= 0 then -- 544
		a.facing = dir > 0 and 1 or -1 -- 546
	end -- 546
	a.vx = dir * speed -- 548
	if isChild and input.jump.pressed and a.onGround and not a.crouch then -- 548
		a.vy = CHILD_JUMP -- 552
		a.onGround = false -- 553
		self:flashSet("跳", 0.25) -- 554
	end -- 554
	self:slideX(a, a.vx * dt) -- 557
	self:fallY(a, dt) -- 558
	if not isChild and input.fire.pressed then -- 558
		self:shoot(a) -- 562
	end -- 562
end -- 473
function Play.prototype.stepPartner(self, p, dt) -- 567
	local a = self.partner -- 568
	if not a.alive then -- 568
		return -- 570
	end -- 570
	a.crouch = false -- 572
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 573
	a.vx = 0 -- 574
	self:fallY(a, dt) -- 575
end -- 567
function Play.prototype.stepEscort(self, dt, input) -- 582
	local a = self.partner -- 583
	if not a.alive then -- 583
		return -- 585
	end -- 585
	if not self:escortOn() then -- 585
		a.vx = 0 -- 588
		self:fallY(a, dt) -- 589
		return -- 590
	end -- 590
	local p = self.player -- 592
	local dist = math.abs(p.x - a.x) -- 593
	self.calmConsumed = self.escort:update( -- 594
		input, -- 594
		p.x, -- 594
		p.facing, -- 594
		a.x, -- 594
		dist -- 594
	) -- 594
	a.crouch = self.escort.crouchPose -- 595
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 596
	local dir = self.escort:moveDir(a.x) -- 597
	a.vx = dir * CHILD_SPEED -- 598
	if dir ~= 0 then -- 598
		a.facing = dir -- 600
		local before = a.x -- 601
		self:slideX(a, dir * CHILD_SPEED * dt) -- 602
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 602
			a.vy = CHILD_JUMP -- 605
			a.onGround = false -- 606
		end -- 606
	end -- 606
	self:fallY(a, dt) -- 609
end -- 582
function Play.prototype.escortOn(self) -- 613
	if self.room.key == "checkpoint" then -- 613
		return true -- 615
	end -- 615
	if self.room.key == "prologue" then -- 615
		return self.phase == "prologue-follow" -- 618
	end -- 618
	return self.room.key == "street" -- 620
end -- 613
function Play.prototype.storyLocked(self) -- 624
	if self.caughtT > 0 then -- 624
		return true -- 626
	end -- 626
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 626
		return true -- 629
	end -- 629
	if self.room.key == "gate" and self.phase == "gate-count" then -- 629
		return true -- 632
	end -- 632
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 632
		return true -- 635
	end -- 635
	return false -- 637
end -- 624
function Play.prototype.swapToChild(self, x) -- 641
	local tmp = self.player -- 642
	self.player = self.partner -- 643
	self.partner = tmp -- 644
	self.childMode = true -- 645
	self.player.alive = true -- 646
	self.player.x = self.ox + x -- 647
	self.player.y = 0 -- 648
	self.player.vy = 0 -- 649
	self.player.vx = 0 -- 650
	self.player.onGround = true -- 651
	self.player.crouch = false -- 652
	self.player.h = CHILD_H -- 653
	self.player.facing = 1 -- 654
	self.partner.alive = true -- 655
	self.cam.x = self.player.x -- 656
end -- 641
function Play.prototype.stepStory(self, dt, input) -- 660
	if self.room.key == "prologue" then -- 660
		self:stepPrologue(dt, input) -- 662
	elseif self.room.key == "street" then -- 662
		self:stepStreet(dt, input) -- 664
	elseif self.room.key == "gate" then -- 664
		self:stepGate(dt, input) -- 666
	elseif self.room.key == "tower" then -- 666
		self:stepTower(dt, input) -- 668
	end -- 668
end -- 660
function Play.prototype.stepPrologue(self, dt, input) -- 673
	local child = self.partner -- 674
	if self.phase == "prologue-wait" then -- 674
		child.crouch = true -- 676
		child.h = CHILD_CROUCH_H -- 677
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 678
		local near = math.abs(self.player.x - child.x) <= reach -- 680
		if near and input.interact.pressed then -- 680
			self.phase = "prologue-give" -- 682
			self.phaseTick = 0 -- 683
			self:flashSet("递出针套", 1) -- 684
		end -- 684
		return -- 686
	end -- 686
	if self.phase == "prologue-give" then -- 686
		self.phaseTick = self.phaseTick + 1 -- 689
		if self.phaseTick == 12 then -- 689
			self:flashSet("针套递过去", 0.7) -- 691
		elseif self.phaseTick == 36 then -- 691
			self:flashSet("纸条塞进针套", 0.9) -- 693
		elseif self.phaseTick >= 60 then -- 693
			self.phase = "prologue-follow" -- 695
			self.phaseTick = 0 -- 696
			child.crouch = false -- 697
			child.h = CHILD_H -- 698
			self:flashSet("她跟上了", 1.2) -- 699
		end -- 699
		return -- 701
	end -- 701
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 701
		self.wantRoom = "street" -- 705
		self:flashSet("进街道", 1.2) -- 706
	end -- 706
end -- 673
function Play.prototype.stepStreet(self, dt, input) -- 711
	local p = self.player -- 712
	local c = self.partner -- 713
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 713
		self.wantRoom = "checkpoint" -- 715
		self:flashSet("到检查站", 1.2) -- 716
	end -- 716
end -- 711
function Play.prototype.stepGate(self, dt, input) -- 721
	local ____temp_7 -- 722
	if self.room.story == nil then -- 722
		____temp_7 = nil -- 722
	else -- 722
		____temp_7 = self.room.story.gate -- 722
	end -- 722
	local g = ____temp_7 -- 722
	if g == nil then -- 722
		return -- 724
	end -- 724
	local p = self.player -- 726
	if self.phase == "gate-idle" then -- 726
		local a = self.partner -- 729
		local gap = g.waitX - a.x -- 730
		if math.abs(gap) > 3 then -- 730
			a.facing = gap > 0 and 1 or -1 -- 732
			a.vx = a.facing * CHILD_SPEED -- 733
			local beforeX = a.x -- 734
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 735
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 735
				a.vy = CHILD_JUMP -- 737
				a.onGround = false -- 738
			end -- 738
			self:fallY(a, dt) -- 740
		else -- 740
			a.vx = 0 -- 742
			a.x = g.waitX -- 743
		end -- 743
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 -- 746
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 747
		if self.gateNeedConfirm then -- 747
			if atWinch and atWait and input.interact.pressed then -- 747
				self.gateNeedConfirm = false -- 751
				self.phase = "gate-hold" -- 752
				self.gateTick = 0 -- 753
				self.gateSpawned = 0 -- 754
				self:flashSet("重新就位 · 守点开始", 1.4) -- 755
			end -- 755
			return -- 757
		end -- 757
		if atWinch and atWait then -- 757
			self.phase = "gate-hold" -- 760
			self.gateTick = 0 -- 761
			self.gateSpawned = 0 -- 762
			self:flashSet("两人就位 · 守点开始", 1.4) -- 763
		end -- 763
		return -- 765
	end -- 765
	if self.phase == "gate-hold" then -- 765
		self.gateTick = self.gateTick + 1 -- 768
		local marks = {0, 540, 900, 1500} -- 770
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 770
			local idx = self.gateSpawned -- 772
			local ____self_enemies_8 = self.enemies -- 772
			____self_enemies_8[#____self_enemies_8 + 1] = { -- 773
				x = self.ox + 620 + idx * 62, -- 774
				y = 0, -- 774
				w = 26, -- 774
				h = 84, -- 774
				alive = true, -- 775
				hitT = 0, -- 775
				warnT = 0, -- 775
				fireCd = 90 + idx * 45 -- 775
			} -- 775
			self.gateSpawned = self.gateSpawned + 1 -- 777
			self:flashSet( -- 778
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 778
				0.9 -- 778
			) -- 778
		end -- 778
		if self.gateTick == 900 then -- 778
			self:flashSet("灯灭了", 1) -- 781
		elseif self.gateTick == 2100 then -- 781
			self:flashSet("门底压下来了", 1) -- 783
		end -- 783
		if self.gateTick >= g.holdTicks then -- 783
			self.phase = "gate-send" -- 786
			self.phaseTick = 0 -- 787
			self.enemies = {} -- 789
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 790
		end -- 790
		return -- 792
	end -- 792
	if self.phase == "gate-send" then -- 792
		local near = math.abs(p.x - g.doorX) <= 60 -- 795
		if near and input.interact.pressed then -- 795
			self:swapToChild(g.doorX + 30) -- 797
			self.phase = "gate-count" -- 798
			self.countTick = 0 -- 799
			self.countArmed = false -- 801
			self.countPrevMove = input.moveX -- 802
			self:flashSet("门开了 · 送她出去", 1.8) -- 803
		end -- 803
		return -- 805
	end -- 805
	if self.phase == "gate-count" then -- 805
		self.countTick = self.countTick + 1 -- 808
		if self.countTick == 360 then -- 808
			self:flashSet("门关上", 0.9) -- 810
		elseif self.countTick == 1020 then -- 810
			self:flashSet("数到一百", 2.2) -- 812
		end -- 812
		local prevMove = self.countPrevMove -- 816
		self.countPrevMove = input.moveX -- 817
		if self.countTick >= 1440 then -- 817
			if prevMove <= 0 and input.moveX > 0 then -- 817
				self.countArmed = true -- 820
			end -- 820
			if self.countArmed and input.moveX > 0 then -- 820
				self.phase = "gate-walk" -- 823
				self.phaseTick = 0 -- 824
				self:flashSet("她迈出第一步", 1.4) -- 825
			end -- 825
		end -- 825
		return -- 828
	end -- 828
	if self.player.x >= g.exitX then -- 828
		self.wantRoom = "outside" -- 832
		self:flashSet("出城门 · 城外", 1.4) -- 833
	end -- 833
end -- 721
function Play.prototype.stepTower(self, dt, input) -- 838
	local ____temp_9 -- 839
	if self.room.story == nil then -- 839
		____temp_9 = nil -- 839
	else -- 839
		____temp_9 = self.room.story.tower -- 839
	end -- 839
	local t = ____temp_9 -- 839
	if t == nil then -- 839
		return -- 841
	end -- 841
	if self.phase == "tower-wait" then -- 841
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 844
		if near and input.interact.pressed then -- 844
			self.phase = "tower-knock" -- 846
			self.phaseTick = 0 -- 847
			self.knocks = 1 -- 848
			self:flashSet("敲一下", 0.6) -- 849
		end -- 849
		return -- 851
	end -- 851
	if self.phase == "tower-knock" then -- 851
		self.phaseTick = self.phaseTick + 1 -- 854
		if self.phaseTick == 12 then -- 854
			self.knocks = 2 -- 856
			self:flashSet("敲两下 · 第二声", 1) -- 857
		elseif self.phaseTick >= t.knockTicks then -- 857
			self.phase = "tower-given" -- 859
			self.phaseTick = 0 -- 860
			self:flashSet("门开了 · 提灯", 1.4) -- 861
		end -- 861
		return -- 863
	end -- 863
	if self.phase == "tower-given" then -- 863
		self.phaseTick = self.phaseTick + 1 -- 866
		if self.phaseTick == 60 then -- 866
			self:flashSet("她递出针套和纸条", 1.6) -- 868
		elseif self.phaseTick == 120 then -- 868
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 870
		elseif self.phaseTick >= 180 then -- 870
			self.phase = "tower-end" -- 872
			self.phaseTick = 0 -- 873
			self:flashSet("片尾 · E 再玩一次", 3) -- 874
		end -- 874
		return -- 876
	end -- 876
	if input.interact.pressed or input.retry.pressed then -- 876
		self.wantRoom = "prologue" -- 879
		self:flashSet("回到序章", 1.4) -- 880
	end -- 880
end -- 838
function Play.prototype.stepChase(self, dt, input) -- 885
	if self.caughtT > 0 then -- 885
		self.caughtT = self.caughtT - dt -- 887
		if self.caughtT <= 0 then -- 887
			self:recoverFromCaught() -- 889
		end -- 889
		return -- 891
	end -- 891
	if self.room.key == "village" then -- 891
		self:stepScavChase() -- 894
	elseif self.room.key == "forest" then -- 894
		self:stepDog(dt) -- 896
		if self.player.x >= self.ox + 1450 then -- 896
			self.wantRoom = "tower" -- 899
			self:flashSet("林缘 · 北塔", 1.4) -- 900
		end -- 900
	end -- 900
end -- 885
function Play.prototype.stepScavChase(self) -- 906
	local s = self.room.scavenger -- 907
	if s == nil then -- 907
		return -- 909
	end -- 909
	local p = self.player -- 911
	if self.passed and p.x > self.ox + 440 then -- 911
		if self.scavChase then -- 911
			self.scavChase = false -- 915
			self.scavState = "back" -- 916
			self.scavT = 0 -- 917
		end -- 917
		return -- 919
	end -- 919
	local dx = p.x - self.scavX -- 921
	local dist = math.abs(dx) -- 922
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 923
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 924
	if not self.scavChase then -- 924
		if visible then -- 924
			self.scavSee = self.scavSee + 1 -- 927
			if self.scavSee >= 24 then -- 927
				self.scavChase = true -- 929
				self.scavState = "chase" -- 930
				self.scavTargetX = p.x -- 931
				self:flashSet("他看见你了", 1.2) -- 932
			end -- 932
		else -- 932
			self.scavSee = 0 -- 935
		end -- 935
		return -- 937
	end -- 937
	local dir = p.x > self.scavX and 1 or -1 -- 940
	self.scavX = self.scavX + dir * 96 / 60 -- 941
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 941
		self:caught() -- 943
		return -- 944
	end -- 944
	if hidden then -- 944
		self.scavSee = 0 -- 948
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 949
		self.scavT = self.scavT - 1 -- 950
		if self.scavT <= 0 then -- 950
			self.scavChase = false -- 952
			self.scavState = "patrol" -- 953
			self:flashSet("他失去了目标", 1) -- 954
		end -- 954
	end -- 954
end -- 906
function Play.prototype.stepDog(self, dt) -- 960
	local ____temp_10 -- 961
	if self.room.story == nil then -- 961
		____temp_10 = nil -- 961
	else -- 961
		____temp_10 = self.room.story.dog -- 961
	end -- 961
	local dog = ____temp_10 -- 961
	if dog == nil then -- 961
		return -- 963
	end -- 963
	local p = self.player -- 965
	local dist = math.abs(p.x - self.dogX) -- 966
	if self.dogState == "patrol" then -- 966
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 968
		if self.dogX < dog.x0 then -- 968
			self.dogX = dog.x0 -- 970
			self.dogDir = 1 -- 971
		elseif self.dogX > dog.x1 then -- 971
			self.dogX = dog.x1 -- 973
			self.dogDir = -1 -- 974
		end -- 974
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 976
		if not p.crouch and moving and dist < dog.range then -- 976
			self.dogState = "ear" -- 978
			self.dogT = 18 -- 979
			self.dogTargetX = p.x -- 980
			self:flashSet("狗转耳朵", 0.8) -- 981
		end -- 981
		return -- 983
	end -- 983
	if self.dogState == "ear" then -- 983
		self.dogT = self.dogT - 1 -- 986
		if self.dogT <= 0 then -- 986
			self.dogState = "chase" -- 988
			self.dogTargetX = p.x -- 989
			self:flashSet("狗追来了", 1.4) -- 990
		end -- 990
		return -- 992
	end -- 992
	if self.dogState == "chase" then -- 992
		local dir = p.x > self.dogX and 1 or -1 -- 995
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 996
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 996
			self:caught() -- 998
			self.dogState = "sniff" -- 999
			self.dogT = 60 -- 1000
		elseif dist > dog.range * 1.5 or p.crouch then -- 1000
			self.dogState = "sniff" -- 1002
			self.dogT = 60 -- 1003
			self:flashSet("狗停下了", 0.9) -- 1004
		end -- 1004
		return -- 1006
	end -- 1006
	if self.dogState == "sniff" then -- 1006
		self.dogT = self.dogT - 1 -- 1009
		if self.dogT <= 0 then -- 1009
			self.dogState = "back" -- 1011
		end -- 1011
		return -- 1013
	end -- 1013
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1016
	self.dogX = self.dogX + dir * dog.speed * dt -- 1017
	if math.abs(self.dogX - dog.x0) < 2 then -- 1017
		self.dogX = dog.x0 -- 1019
		self.dogState = "patrol" -- 1020
	end -- 1020
end -- 960
function Play.prototype.caught(self) -- 1024
	self.caughtT = 1 -- 1025
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1026
end -- 1024
function Play.prototype.recoverFromCaught(self) -- 1030
	local p = self.player -- 1031
	p.x = self.ox + 140 -- 1032
	p.y = 0 -- 1033
	p.vy = 0 -- 1034
	p.vx = 0 -- 1035
	p.onGround = true -- 1036
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1036
		self.scavX = self.room.scavenger.x0 -- 1038
		self.scavState = "patrol" -- 1039
		self.scavSee = 0 -- 1040
		self.scavChase = false -- 1041
		self.scavT = 0 -- 1042
	end -- 1042
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1042
		self.dogX = self.room.story.dog.x0 -- 1045
		self.dogState = "patrol" -- 1046
		self.dogT = 0 -- 1047
	end -- 1047
	self.cam.x = p.x -- 1049
	self.cam.y = p.y + CAM_LOOK_UP -- 1050
	self:flashSet("回到安全点", 1.2) -- 1051
end -- 1030
function Play.prototype.updateGate(self) -- 1055
	if self.room.key ~= "checkpoint" then -- 1055
		self.gateOpen = false -- 1057
		return -- 1058
	end -- 1058
	local function inZone(x) -- 1060
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1060
	end -- 1060
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1061
end -- 1055
function Play.prototype.stepEnemies(self, dt, input) -- 1064
	local i = 0 -- 1065
	do -- 1065
		i = 0 -- 1066
		while i < #self.enemies do -- 1066
			local e = self.enemies[i + 1] -- 1067
			if e.hitT > 0 then -- 1067
				e.hitT = e.hitT - dt -- 1069
			end -- 1069
			i = i + 1 -- 1066
		end -- 1066
	end -- 1066
	if self.coveredFlash > 0 then -- 1066
		self.coveredFlash = self.coveredFlash - dt -- 1073
	end -- 1073
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 1073
		return -- 1077
	end -- 1077
	do -- 1077
		i = 0 -- 1079
		while i < #self.enemies do -- 1079
			do -- 1079
				local e = self.enemies[i + 1] -- 1080
				if not e.alive then -- 1080
					goto __continue172 -- 1082
				end -- 1082
				if e.warnT > 0 then -- 1082
					e.warnT = e.warnT - 1 -- 1085
					if e.warnT <= 0 then -- 1085
						self:enemyFire(e, input) -- 1087
					end -- 1087
					goto __continue172 -- 1089
				end -- 1089
				if e.fireCd > 0 then -- 1089
					e.fireCd = e.fireCd - 1 -- 1092
					if e.fireCd <= 0 then -- 1092
						e.warnT = WARN_TICKS -- 1094
					end -- 1094
				else -- 1094
					e.warnT = WARN_TICKS -- 1098
				end -- 1098
			end -- 1098
			::__continue172:: -- 1098
			i = i + 1 -- 1079
		end -- 1079
	end -- 1079
end -- 1064
function Play.prototype.enemyFire(self, e, input) -- 1104
	local p = self.player -- 1105
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 1105
		self:flashSet("枪声响在远处", 0.4) -- 1107
		e.fireCd = FIRE_COOLDOWN -- 1108
		return -- 1109
	end -- 1109
	local hugging = self:blockedByCover(e.x, p.x) -- 1112
	local covered = hugging and input.cover.held -- 1113
	if covered then -- 1113
		self.coveredFlash = 0.5 -- 1115
		self:flashSet("掩体挡下", 0.5) -- 1116
		e.fireCd = FIRE_COOLDOWN -- 1117
		return -- 1118
	end -- 1118
	self.hp = self.hp - 1 -- 1120
	self:flashSet( -- 1121
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 1121
		0.7 -- 1121
	) -- 1121
	e.fireCd = FIRE_COOLDOWN -- 1122
	if self.hp <= 0 then -- 1122
		self:gateFailed() -- 1124
	end -- 1124
end -- 1104
function Play.prototype.blockedByCover(self, ex, px) -- 1129
	local lo = math.min(ex, px) -- 1130
	local hi = math.max(ex, px) -- 1131
	local i = 0 -- 1132
	do -- 1132
		i = 0 -- 1133
		while i < #self.boxes do -- 1133
			do -- 1133
				local b = self.boxes[i + 1] -- 1134
				if b.passable == true or b.y1 - b.y0 < 44 then -- 1134
					goto __continue185 -- 1136
				end -- 1136
				local cx = (b.x0 + b.x1) / 2 -- 1138
				if cx <= lo + 8 or cx >= hi - 8 then -- 1138
					goto __continue185 -- 1140
				end -- 1140
				local hug = math.min( -- 1142
					math.abs(px - b.x0), -- 1142
					math.abs(px - b.x1) -- 1142
				) < 24 -- 1142
				if hug then -- 1142
					return true -- 1144
				end -- 1144
			end -- 1144
			::__continue185:: -- 1144
			i = i + 1 -- 1133
		end -- 1133
	end -- 1133
	return false -- 1147
end -- 1129
function Play.prototype.gateFailed(self) -- 1151
	local ____temp_11 -- 1152
	if self.room.story == nil then -- 1152
		____temp_11 = nil -- 1152
	else -- 1152
		____temp_11 = self.room.story.gate -- 1152
	end -- 1152
	local g = ____temp_11 -- 1152
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 1153
	self.hp = self.maxHp -- 1154
	self.gateTick = 0 -- 1155
	self.gateSpawned = 0 -- 1156
	self.enemies = {} -- 1157
	self.gateFailCount = self.gateFailCount + 1 -- 1158
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 1160
	self.player.y = 0 -- 1161
	self.player.vy = 0 -- 1162
	self.player.onGround = true -- 1163
	self.player.crouch = false -- 1164
	self.player.h = SOLDIER_H -- 1165
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 1166
	self.partner.y = 0 -- 1167
	self.partner.vy = 0 -- 1168
	self.partner.onGround = true -- 1169
	self.cam.x = self.player.x -- 1170
	self.phase = "gate-idle" -- 1171
	self.phaseTick = 0 -- 1172
	self.coverHug = false -- 1173
	self.gateNeedConfirm = true -- 1174
end -- 1151
function Play.prototype.stepInteract(self, dt, input) -- 1177
	local p = self.player -- 1178
	local calmUsed = self.calmConsumed -- 1179
	self.calmConsumed = false -- 1180
	self.focusCart = false -- 1181
	if self.room.key == "outside" then -- 1181
		local c = self.room.cart -- 1183
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 1184
		local dy = p.y - c.baseY -- 1185
		self.focusCart = dx * dx + dy * dy < CART_REACH * CART_REACH -- 1186
	end -- 1186
	self:stepCart(dt, input) -- 1188
	if calmUsed then -- 1188
		self:flashSet("安抚 · 敲两下", 0.8) -- 1192
	elseif input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" then -- 1192
		if self.knockT > 0 then -- 1192
			self.knocks = self.knocks + 1 -- 1196
		else -- 1196
			self.knocks = 1 -- 1198
		end -- 1198
		self.knockT = 1.2 -- 1200
		if self.knocks >= 2 then -- 1200
			self:flashSet("敲两下", 0.8) -- 1202
			self.knocks = 0 -- 1203
		else -- 1203
			self:flashSet("敲一下", 0.5) -- 1205
		end -- 1205
	elseif self.knockT > 0 then -- 1205
		self.knockT = self.knockT - dt -- 1208
		if self.knockT <= 0 then -- 1208
			self.knocks = 0 -- 1210
		end -- 1210
	end -- 1210
	local i = 0 -- 1215
	do -- 1215
		i = 0 -- 1216
		while i < #self.room.marks do -- 1216
			do -- 1216
				local m = self.room.marks[i + 1] -- 1217
				if m.kind ~= 0 then -- 1217
					goto __continue201 -- 1219
				end -- 1219
				local subjects = {self.partner, self.player} -- 1221
				local k = 0 -- 1222
				do -- 1222
					k = 0 -- 1223
					while k < #subjects do -- 1223
						do -- 1223
							local s = subjects[k + 1] -- 1224
							if not s.alive then -- 1224
								goto __continue204 -- 1226
							end -- 1226
							local dx = s.x - m.x -- 1228
							local dy = s.y - m.y -- 1229
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 1229
								self.checkpoint = m.x -- 1231
								self.checkpointCartAxle = self.cartAxle -- 1232
								if self.cartDocked then -- 1232
									self:flashSet("检查点 · 车已落窝", 1) -- 1234
								else -- 1234
									self:flashSet("检查点 · 车还没到位", 1) -- 1236
								end -- 1236
							end -- 1236
						end -- 1236
						::__continue204:: -- 1236
						k = k + 1 -- 1223
					end -- 1223
				end -- 1223
			end -- 1223
			::__continue201:: -- 1223
			i = i + 1 -- 1216
		end -- 1216
	end -- 1216
	self:checkCarryGate() -- 1242
end -- 1177
function Play.prototype.stepVillage(self, dt, input) -- 1246
	if self.room.key ~= "village" then -- 1246
		return -- 1248
	end -- 1248
	local p = self.player -- 1250
	local bottle = self.room.bottle -- 1251
	local scav = self.room.scavenger -- 1252
	if not self.hasBottle and bottle ~= nil then -- 1252
		local dx = p.x - bottle.x -- 1256
		local dy = p.y + p.h * 0.5 - bottle.y -- 1257
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 1257
			self.hasBottle = true -- 1259
			self:flashSet("拾起瓶子", 0.8) -- 1260
		end -- 1260
	end -- 1260
	if self.hasBottle then -- 1260
		if input.aim.held then -- 1260
			self.aimHold = self.aimHold + dt -- 1267
			if self.aimHold > 1.2 then -- 1267
				self.aimHold = 1.2 -- 1269
			end -- 1269
			local cached = self:bottleEnd() -- 1272
			self.bottleAimX = cached.x -- 1273
			self.bottleAimY = cached.y -- 1274
		elseif input.aim.released then -- 1274
			if self.aimHold < 0.12 then -- 1274
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 1278
				self.aimHold = 0 -- 1279
			else -- 1279
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 1281
				self:throwBottle(____end.x, ____end.y) -- 1282
				self.aimHold = 0 -- 1283
			end -- 1283
		end -- 1283
	else -- 1283
		self.aimHold = 0 -- 1287
		self.bottleAimX = -1 -- 1288
	end -- 1288
	local fly = self.bottleFly -- 1292
	if fly ~= nil then -- 1292
		fly.vy = fly.vy - GRAVITY * dt -- 1294
		fly.x = fly.x + fly.vx * dt -- 1295
		fly.y = fly.y + fly.vy * dt -- 1296
		local g = self:groundAt(fly.x, fly.y + 4, 3) -- 1297
		local ____temp_13 = self.bottleTargetX >= 0 -- 1298
		if ____temp_13 then -- 1298
			local ____temp_12 -- 1298
			if fly.vx >= 0 then -- 1298
				____temp_12 = fly.x >= self.bottleTargetX -- 1298
			else -- 1298
				____temp_12 = fly.x <= self.bottleTargetX -- 1298
			end -- 1298
			____temp_13 = ____temp_12 -- 1298
		end -- 1298
		local reached = ____temp_13 -- 1298
		if fly.y <= g or reached then -- 1298
			local landX = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 1300
			self.bottleFly = nil -- 1301
			self.bottleLandX = landX -- 1302
			self.bottleLandT = 0.9 -- 1303
			self:hearBottle(landX) -- 1304
		end -- 1304
	end -- 1304
	if self.bottleLandT > 0 then -- 1304
		self.bottleLandT = self.bottleLandT - dt -- 1308
	end -- 1308
	if scav ~= nil then -- 1308
		self:stepScav(dt, scav) -- 1312
	end -- 1312
	local line = self.room.passLine -- 1315
	if line ~= nil and not self.passed and p.x >= line then -- 1315
		self.passed = true -- 1317
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 1318
	end -- 1318
	if self.passed and p.x >= self.ox + 640 then -- 1318
		self.wantRoom = "forest" -- 1322
		self:flashSet("出院 · 北塔森林", 1.4) -- 1323
	end -- 1323
end -- 1246
function Play.prototype.bottleEnd(self) -- 1328
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1329
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 1330
	return {x = aim.x, y = g} -- 1331
end -- 1328
function Play.prototype.throwBottle(self, tx, ty) -- 1335
	local p = self.player -- 1336
	local dir = tx >= p.x and 1 or -1 -- 1338
	p.facing = dir -- 1339
	local x0 = p.x + dir * 10 -- 1340
	local y0 = p.y + p.h * 0.7 -- 1341
	local T = 0.62 -- 1342
	self.bottleTargetX = tx -- 1343
	self.bottleTargetY = ty -- 1344
	local vx = (tx - x0) / T -- 1345
	local vy = (ty - y0 + 0.5 * GRAVITY * T * T) / T -- 1346
	self.bottleFly = {x = x0, y = y0, vx = vx, vy = vy} -- 1347
	self.hasBottle = false -- 1348
	self:flashSet("投出", 0.4) -- 1349
end -- 1335
function Play.prototype.hearBottle(self, x) -- 1353
	local s = self.room.scavenger -- 1354
	if s == nil then -- 1354
		return -- 1356
	end -- 1356
	if math.abs(x - self.scavX) > s.range then -- 1356
		self:flashSet("落地 · 他没听见", 0.6) -- 1359
		return -- 1360
	end -- 1360
	self.scavState = "turn" -- 1362
	self.scavT = s.hearTicks -- 1363
	self.scavTargetX = x -- 1364
	self:flashSet("砖地一响 · 他转头", 0.9) -- 1365
end -- 1353
function Play.prototype.stepScav(self, dt, s) -- 1369
	if self.scavState == "chase" then -- 1369
		return -- 1372
	end -- 1372
	if self.scavState == "turn" then -- 1372
		self.scavT = self.scavT - 1 -- 1375
		if self.scavT <= 0 then -- 1375
			self.scavState = "walk" -- 1377
		end -- 1377
		return -- 1379
	end -- 1379
	if self.scavState == "walk" then -- 1379
		local d = self.scavTargetX - self.scavX -- 1382
		if math.abs(d) < 4 then -- 1382
			self.scavState = "stall" -- 1384
			self.scavT = s.stallTicks -- 1385
			return -- 1386
		end -- 1386
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 1388
		return -- 1389
	end -- 1389
	if self.scavState == "stall" then -- 1389
		self.scavT = self.scavT - 1 -- 1392
		if self.scavT <= 0 then -- 1392
			self.scavState = "back" -- 1394
		end -- 1394
		return -- 1396
	end -- 1396
	if self.scavState == "back" then -- 1396
		local home = math.max( -- 1399
			s.x0, -- 1399
			math.min(s.x1, self.scavX) -- 1399
		) -- 1399
		if math.abs(home - self.scavX) < 2 then -- 1399
			self.scavState = "patrol" -- 1401
			return -- 1402
		end -- 1402
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 1404
		return -- 1405
	end -- 1405
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 1407
	if self.scavX >= s.x1 then -- 1407
		self.scavX = s.x1 -- 1409
		self.scavDir = -1 -- 1410
	elseif self.scavX <= s.x0 then -- 1410
		self.scavX = s.x0 -- 1412
		self.scavDir = 1 -- 1413
	end -- 1413
end -- 1369
function Play.prototype.stepCart(self, dt, input) -- 1421
	local p = self.player -- 1422
	local c = self.room.cart -- 1423
	local handleX = self.cartAxle + c.handleOffset -- 1424
	if self.gripping then -- 1424
		if not input.interact.held then -- 1424
			self.gripping = false -- 1428
			self:flashSet("松开车把", 0.4) -- 1429
			return -- 1430
		end -- 1430
	else -- 1430
		if not input.interact.pressed then -- 1430
			return -- 1434
		end -- 1434
		if math.abs(p.x - handleX) > CART_REACH or math.abs(p.y - c.baseY) > 40 then -- 1434
			return -- 1437
		end -- 1437
		self.gripping = true -- 1439
		self:flashSet("握住车把", 0.4) -- 1440
		return -- 1441
	end -- 1441
	if self.cartDocked then -- 1441
		return -- 1445
	end -- 1445
	local dir = input.moveX -- 1447
	if dir == 0 then -- 1447
		return -- 1449
	end -- 1449
	local lo = math.min(c.startX, c.endX) -- 1451
	local hi = math.max(c.startX, c.endX) -- 1452
	local next = self.cartAxle + dir * CART_SPEED * dt -- 1453
	if next < lo then -- 1453
		next = lo -- 1455
	end -- 1455
	if next > hi then -- 1455
		next = hi -- 1458
	end -- 1458
	local delta = next - self.cartAxle -- 1460
	if delta == 0 then -- 1460
		return -- 1462
	end -- 1462
	self.cartAxle = next -- 1464
	p.x = p.x + delta -- 1465
	p.facing = dir > 0 and 1 or -1 -- 1466
	self:slideX(p, 0) -- 1467
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > CART_REACH then -- 1467
		self.gripping = false -- 1469
		self:flashSet("跟不上了，脱手", 0.6) -- 1470
		return -- 1471
	end -- 1471
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 1471
		self.cartDocked = true -- 1474
		self.gripping = false -- 1475
		self:flashSet("车轮落窝", 1.2) -- 1476
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 1476
		self:flashSet("车轮回到起点", 0.5) -- 1478
	end -- 1478
end -- 1421
function Play.prototype.checkCarryGate(self) -- 1486
	if self.room.key == "checkpoint" then -- 1486
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 1486
			self.carryCartAxle = self.cartAxle -- 1489
			self.carryCartDocked = self.cartDocked -- 1490
			self.wantRoom = "gate" -- 1491
			self:flashSet("出检查站 · 城门", 1.2) -- 1492
		end -- 1492
		return -- 1494
	end -- 1494
	if self.room.key == "outside" then -- 1494
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 1494
			self.carryCartAxle = self.cartAxle -- 1500
			self.carryCartDocked = self.cartDocked -- 1501
			self.wantRoom = "village" -- 1502
			self:flashSet("墙根走完 · 进村口", 1.2) -- 1503
		end -- 1503
	end -- 1503
end -- 1486
function Play.prototype.aimAt(self, wx, wy) -- 1510
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 1511
	self.aimX = s.x -- 1512
	self.aimY = s.y -- 1513
end -- 1510
function Play.prototype.shoot(self, a) -- 1516
	local ox = a.x + a.facing * 8 -- 1517
	local oy = a.y + a.h * 0.72 -- 1518
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1520
	local dx = aim.x - ox -- 1521
	local dy = aim.y - oy -- 1522
	local len = math.sqrt(dx * dx + dy * dy) -- 1523
	if len < 0.001 then -- 1523
		dx = a.facing -- 1525
		dy = 0 -- 1526
	else -- 1526
		dx = dx / len -- 1528
		dy = dy / len -- 1529
	end -- 1529
	if dx ~= 0 then -- 1529
		a.facing = dx > 0 and 1 or -1 -- 1532
	end -- 1532
	local hitEnemy = self:raycast( -- 1535
		ox, -- 1535
		oy, -- 1535
		dx, -- 1535
		dy, -- 1535
		true -- 1535
	) -- 1535
	local hitWall = self:raycast( -- 1536
		ox, -- 1536
		oy, -- 1536
		dx, -- 1536
		dy, -- 1536
		false -- 1536
	) -- 1536
	local tEnemy = hitEnemy.t -- 1537
	local tWall = hitWall.t -- 1538
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 1539
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 1540
	self.trace = { -- 1542
		x0 = ox, -- 1542
		y0 = oy, -- 1542
		x1 = ox + dx * t, -- 1542
		y1 = oy + dy * t, -- 1542
		hit = hit -- 1542
	} -- 1542
	self.traceT = 0.12 -- 1543
	self:applyFireDanger(ox) -- 1544
	if hit then -- 1544
		local i = hitEnemy.index -- 1546
		local e = self.enemies[i + 1] -- 1547
		e.alive = false -- 1548
		e.hitT = 0.4 -- 1549
		self:flashSet("命中", 0.6) -- 1550
	else -- 1550
		self:flashSet("打空", 0.35) -- 1552
	end -- 1552
end -- 1516
function Play.prototype.applyFireDanger(self, shotX) -- 1557
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 1557
		return -- 1559
	end -- 1559
	local dangerX = shotX -- 1561
	local best = -1 -- 1562
	local bestD = 1000000000 -- 1563
	local i = 0 -- 1564
	do -- 1564
		i = 0 -- 1565
		while i < #self.enemies do -- 1565
			do -- 1565
				local e = self.enemies[i + 1] -- 1566
				if not e.alive then -- 1566
					goto __continue272 -- 1568
				end -- 1568
				local d = math.abs(e.x - self.partner.x) -- 1570
				if d < bestD then -- 1570
					bestD = d -- 1572
					best = i -- 1573
				end -- 1573
			end -- 1573
			::__continue272:: -- 1573
			i = i + 1 -- 1565
		end -- 1565
	end -- 1565
	if best >= 0 then -- 1565
		dangerX = self.enemies[best + 1].x -- 1577
	end -- 1577
	local exposed = self:childExposed(dangerX) -- 1579
	local before = self.escort.fear -- 1580
	local after = self.escort:applyDanger(self.nextDangerId, exposed, self.partner.x) -- 1581
	self.nextDangerId = self.nextDangerId + 1 -- 1582
	if after > before then -- 1582
		self:flashSet( -- 1584
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 1584
			1 -- 1584
		) -- 1584
	elseif not exposed then -- 1584
		self:flashSet("枪声没够到她", 0.5) -- 1586
	end -- 1586
end -- 1557
function Play.prototype.childExposed(self, dangerX) -- 1591
	local c = self.partner -- 1592
	if not c.alive then -- 1592
		return false -- 1594
	end -- 1594
	if c.x > self.ox + 240 and c.x < self.ox + 340 then -- 1594
		return false -- 1597
	end -- 1597
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 1597
		return false -- 1600
	end -- 1600
	local toDanger = dangerX - c.x -- 1602
	local toPlayer = self.player.x - c.x -- 1603
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) then -- 1603
		return false -- 1605
	end -- 1605
	return true -- 1607
end -- 1591
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 1611
	local best = -1 -- 1612
	local bestI = -1 -- 1613
	local i = 0 -- 1614
	if enemies then -- 1614
		do -- 1614
			i = 0 -- 1616
			while i < #self.enemies do -- 1616
				do -- 1616
					local e = self.enemies[i + 1] -- 1617
					if not e.alive then -- 1617
						goto __continue286 -- 1619
					end -- 1619
					local t = hitBox( -- 1621
						ox, -- 1621
						oy, -- 1621
						dx, -- 1621
						dy, -- 1621
						e.x - e.w / 2, -- 1621
						e.x + e.w / 2, -- 1621
						e.y, -- 1621
						e.y + e.h -- 1621
					) -- 1621
					if t >= 0 and (best < 0 or t < best) then -- 1621
						best = t -- 1623
						bestI = i -- 1624
					end -- 1624
				end -- 1624
				::__continue286:: -- 1624
				i = i + 1 -- 1616
			end -- 1616
		end -- 1616
		return {t = best, index = bestI} -- 1627
	end -- 1627
	do -- 1627
		i = 0 -- 1629
		while i < #self.boxes do -- 1629
			local b = self.boxes[i + 1] -- 1630
			local t = hitBox( -- 1631
				ox, -- 1631
				oy, -- 1631
				dx, -- 1631
				dy, -- 1631
				b.x0, -- 1631
				b.x1, -- 1631
				b.y0, -- 1631
				b.y1 -- 1631
			) -- 1631
			if t >= 0 and (best < 0 or t < best) then -- 1631
				best = t -- 1633
			end -- 1633
			i = i + 1 -- 1629
		end -- 1629
	end -- 1629
	if dy < 0 then -- 1629
		local t = (0 - oy) / dy -- 1638
		if t >= 0 and (best < 0 or t < best) then -- 1638
			best = t -- 1640
		end -- 1640
	end -- 1640
	return {t = best, index = -1} -- 1643
end -- 1611
function Play.prototype.slideX(self, a, dx) -- 1647
	local nx = a.x + dx -- 1648
	local half = a.w / 2 -- 1649
	local room = self.room -- 1650
	nx = math.max( -- 1651
		room.minX + half, -- 1651
		math.min(room.maxX - half, nx) -- 1651
	) -- 1651
	local i = 0 -- 1652
	do -- 1652
		i = 0 -- 1653
		while i < #self.boxes do -- 1653
			do -- 1653
				local b = self.boxes[i + 1] -- 1654
				if b.passable == true then -- 1654
					goto __continue296 -- 1656
				end -- 1656
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1656
					goto __continue296 -- 1659
				end -- 1659
				if nx + half > b.x0 and nx - half < b.x1 then -- 1659
					if a.x <= b.x0 then -- 1659
						nx = b.x0 - half -- 1663
					elseif a.x >= b.x1 then -- 1663
						nx = b.x1 + half -- 1665
					else -- 1665
						nx = a.x -- 1667
					end -- 1667
				end -- 1667
			end -- 1667
			::__continue296:: -- 1667
			i = i + 1 -- 1653
		end -- 1653
	end -- 1653
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 1653
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 1675
		local bx0 = self.cartAxle - CART_HALF -- 1676
		local bx1 = self.cartAxle + CART_HALF -- 1677
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 1677
			if a.x <= bx0 then -- 1677
				nx = bx0 - half -- 1680
			elseif a.x >= bx1 then -- 1680
				nx = bx1 + half -- 1682
			else -- 1682
				nx = a.x -- 1684
			end -- 1684
		end -- 1684
	end -- 1684
	local arch = room.arch -- 1692
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 1692
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 1694
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 1694
			if a.x <= arch.x0 then -- 1694
				nx = arch.x0 - half -- 1697
			elseif a.x >= arch.x1 then -- 1697
				nx = arch.x1 + half -- 1699
			end -- 1699
		end -- 1699
	end -- 1699
	a.x = nx -- 1703
end -- 1647
function Play.prototype.fallY(self, a, dt) -- 1707
	a.vy = a.vy - GRAVITY * dt -- 1708
	if a.vy < -900 then -- 1708
		a.vy = -900 -- 1710
	end -- 1710
	local ny = a.y + a.vy * dt -- 1712
	local half = a.w / 2 -- 1713
	if a.vy <= 0 then -- 1713
		local reach = a.onGround and STEP_UP or 0 -- 1716
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half) -- 1717
		if ny <= ground then -- 1717
			ny = ground -- 1719
			a.vy = 0 -- 1720
			a.onGround = true -- 1721
		else -- 1721
			a.onGround = false -- 1723
		end -- 1723
	else -- 1723
		a.onGround = false -- 1726
		local i = 0 -- 1727
		do -- 1727
			i = 0 -- 1728
			while i < #self.boxes do -- 1728
				do -- 1728
					local b = self.boxes[i + 1] -- 1729
					if b.passable == true then -- 1729
						goto __continue319 -- 1731
					end -- 1731
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 1731
						goto __continue319 -- 1734
					end -- 1734
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 1734
						ny = b.y0 - a.h -- 1737
						a.vy = 0 -- 1738
					end -- 1738
				end -- 1738
				::__continue319:: -- 1738
				i = i + 1 -- 1728
			end -- 1728
		end -- 1728
	end -- 1728
	a.y = ny -- 1742
end -- 1707
function Play.prototype.groundAt(self, x, ceiling, half) -- 1746
	local g = -9999 -- 1747
	local i = 0 -- 1748
	do -- 1748
		i = 0 -- 1749
		while i < #self.floors do -- 1749
			local f = self.floors[i + 1] -- 1750
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 1750
				g = f.y1 -- 1752
			end -- 1752
			i = i + 1 -- 1749
		end -- 1749
	end -- 1749
	do -- 1749
		i = 0 -- 1755
		while i < #self.boxes do -- 1755
			local b = self.boxes[i + 1] -- 1756
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 1756
				g = b.y1 -- 1758
			end -- 1758
			i = i + 1 -- 1755
		end -- 1755
	end -- 1755
	return g -- 1761
end -- 1746
function Play.prototype.updateCamera(self, dt) -- 1764
	local p = self.player -- 1765
	local tx = p.x + p.facing * 30 -- 1766
	local ty = p.y + CAM_LOOK_UP -- 1767
	local k = math.min(1, CAM_FOLLOW * dt) -- 1768
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 1769
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 1770
end -- 1764
function Play.prototype.clampCamera(self, w, h) -- 1774
	local room = self.room -- 1775
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 1776
	local spanX = room.maxX - room.minX -- 1777
	if spanX <= halfW * 2 then -- 1777
		self.cam.x = (room.minX + room.maxX) / 2 -- 1779
	else -- 1779
		self.cam.x = math.max( -- 1781
			room.minX + halfW, -- 1781
			math.min(room.maxX - halfW, self.cam.x) -- 1781
		) -- 1781
	end -- 1781
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 1784
	local spanY = room.height -- 1785
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 1786
	if spanY <= halfH * 2 then -- 1786
		self.cam.y = camY -- 1788
	else -- 1788
		self.cam.y = math.max( -- 1790
			camY, -- 1790
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 1790
		) -- 1790
	end -- 1790
end -- 1774
function Play.prototype.flashSet(self, text, t) -- 1794
	self.flash = text -- 1795
	self.flashT = t -- 1796
end -- 1794
function Play.prototype.statusText(self) -- 1800
	local p = self.player -- 1801
	local parts = {} -- 1802
	local who = self.childMode and "小满" or "周戍" -- 1803
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 1804
	if self.room.key == "prologue" then -- 1804
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1807
		if self.phase == "prologue-wait" then -- 1807
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 1809
		elseif self.phase == "prologue-give" then -- 1809
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 1811
		else -- 1811
			parts[#parts + 1] = "跟随" -- 1813
		end -- 1813
		if self.paused then -- 1813
			parts[#parts + 1] = "已暂停" -- 1816
		end -- 1816
		return table.concat(parts, " · ") -- 1818
	end -- 1818
	if self.room.key == "street" then -- 1818
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1821
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1822
		if self.paused then -- 1822
			parts[#parts + 1] = "已暂停" -- 1824
		end -- 1824
		return table.concat(parts, " · ") -- 1826
	end -- 1826
	if self.room.key == "gate" then -- 1826
		local ____temp_14 -- 1829
		if self.room.story == nil then -- 1829
			____temp_14 = nil -- 1829
		else -- 1829
			____temp_14 = self.room.story.gate -- 1829
		end -- 1829
		local g = ____temp_14 -- 1829
		if g ~= nil then -- 1829
			parts[#parts + 1] = self:gateLabel() -- 1831
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 1832
				0, -- 1833
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 1833
			))) .. " 秒" -- 1833
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1834
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1835
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 1836
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 1837
			if self.gateFailCount > 0 then -- 1837
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 1839
			end -- 1839
			if self.flash ~= "" then -- 1839
				parts[#parts + 1] = self.flash -- 1842
			end -- 1842
		end -- 1842
		if self.paused then -- 1842
			parts[#parts + 1] = "已暂停" -- 1846
		end -- 1846
		return table.concat(parts, " · ") -- 1848
	end -- 1848
	if self.room.key == "forest" then -- 1848
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1851
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 1852
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 1853
		if self.caughtT > 0 then -- 1853
			parts[#parts + 1] = "复位中" -- 1855
		end -- 1855
		if self.paused then -- 1855
			parts[#parts + 1] = "已暂停" -- 1858
		end -- 1858
		return table.concat(parts, " · ") -- 1860
	end -- 1860
	if self.room.key == "tower" then -- 1860
		if self.phase == "tower-wait" then -- 1860
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 1864
		elseif self.phase == "tower-knock" then -- 1864
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 1866
		elseif self.phase == "tower-given" then -- 1866
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 1868
		else -- 1868
			parts[#parts + 1] = "片尾" -- 1870
		end -- 1870
		if self.paused then -- 1870
			parts[#parts + 1] = "已暂停" -- 1873
		end -- 1873
		return table.concat(parts, " · ") -- 1875
	end -- 1875
	if self.room.key == "village" then -- 1875
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1878
		if self.hasBottle then -- 1878
			parts[#parts + 1] = "有瓶" -- 1880
		elseif self.bottleFly ~= nil then -- 1880
			parts[#parts + 1] = "瓶在飞" -- 1882
		else -- 1882
			parts[#parts + 1] = "空手" -- 1884
		end -- 1884
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 1886
		if self.scavChase then -- 1886
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 1888
		end -- 1888
		if self.passed then -- 1888
			parts[#parts + 1] = "已过通行线" -- 1891
		end -- 1891
		if self.paused then -- 1891
			parts[#parts + 1] = "已暂停" -- 1894
		end -- 1894
		return table.concat(parts, " · ") -- 1896
	end -- 1896
	local isChild = self.childMode -- 1899
	if isChild then -- 1899
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1901
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 1902
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1903
	else -- 1903
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 1905
		if p.rollT > 0 then -- 1905
			parts[#parts + 1] = "翻滚中" -- 1907
		end -- 1907
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1909
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1910
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 1911
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 1912
	end -- 1912
	if self.checkpoint >= 0 then -- 1912
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 1915
	end -- 1915
	if self.paused then -- 1915
		parts[#parts + 1] = "已暂停" -- 1918
	end -- 1918
	return table.concat(parts, " · ") -- 1920
end -- 1800
function Play.prototype.aliveEnemies(self) -- 1924
	local n = 0 -- 1925
	local i = 0 -- 1926
	do -- 1926
		i = 0 -- 1927
		while i < #self.enemies do -- 1927
			if self.enemies[i + 1].alive then -- 1927
				n = n + 1 -- 1929
			end -- 1929
			i = i + 1 -- 1927
		end -- 1927
	end -- 1927
	return n -- 1932
end -- 1924
function Play.prototype.threatened(self) -- 1937
	do -- 1937
		local i = 0 -- 1938
		while i < #self.enemies do -- 1938
			local e = self.enemies[i + 1] -- 1939
			if e.alive and e.warnT > 0 then -- 1939
				return true -- 1941
			end -- 1941
			i = i + 1 -- 1938
		end -- 1938
	end -- 1938
	return false -- 1944
end -- 1937
function Play.prototype.gateSecondsLeft(self) -- 1947
	local ____temp_15 -- 1948
	if self.room.story == nil then -- 1948
		____temp_15 = nil -- 1948
	else -- 1948
		____temp_15 = self.room.story.gate -- 1948
	end -- 1948
	local g = ____temp_15 -- 1948
	if g == nil then -- 1948
		return 0 -- 1950
	end -- 1950
	return math.max( -- 1952
		0, -- 1952
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 1952
	) -- 1952
end -- 1947
function Play.prototype.gateLabel(self) -- 1955
	if self.phase == "gate-idle" then -- 1955
		return "待就位" -- 1957
	end -- 1957
	if self.phase == "gate-hold" then -- 1957
		return "守点中" -- 1960
	end -- 1960
	if self.phase == "gate-send" then -- 1960
		return "送别" -- 1963
	end -- 1963
	if self.phase == "gate-count" then -- 1963
		return "数数 " .. tostring(self.countTick) -- 1966
	end -- 1966
	return "她走" -- 1968
end -- 1955
function Play.prototype.dogLabel(self) -- 1972
	if self.dogState == "ear" then -- 1972
		return "转耳" -- 1974
	end -- 1974
	if self.dogState == "chase" then -- 1974
		return "追" -- 1977
	end -- 1977
	if self.dogState == "sniff" then -- 1977
		return "停" -- 1980
	end -- 1980
	if self.dogState == "back" then -- 1980
		return "回线" -- 1983
	end -- 1983
	return "巡逻" -- 1985
end -- 1972
function Play.prototype.doorXOf(self) -- 1988
	local ____temp_16 -- 1989
	if self.room.story == nil then -- 1989
		____temp_16 = nil -- 1989
	else -- 1989
		____temp_16 = self.room.story.tower -- 1989
	end -- 1989
	local t = ____temp_16 -- 1989
	return t == nil and 0 or t.doorX -- 1990
end -- 1988
function Play.prototype.scavLabel(self) -- 1994
	if self.scavState == "chase" then -- 1994
		return "追" -- 1996
	end -- 1996
	if self.scavState == "turn" then -- 1996
		return "转头" -- 1999
	end -- 1999
	if self.scavState == "walk" then -- 1999
		return "赶来" -- 2002
	end -- 2002
	if self.scavState == "stall" then -- 2002
		return "停住" -- 2005
	end -- 2005
	if self.scavState == "back" then -- 2005
		return "回位" -- 2008
	end -- 2008
	return "巡逻" -- 2010
end -- 1994
function Play.prototype.hintText(self) -- 2014
	if self.paused then -- 2014
		return "Esc 继续 · R 重置" -- 2016
	end -- 2016
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 2016
		if self:threatened() then -- 2016
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 2022
		end -- 2022
		if self.coverHug then -- 2022
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 2025
		end -- 2025
		if self.coverNear then -- 2025
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 2028
		end -- 2028
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 2030
	end -- 2030
	if self.flash ~= "" then -- 2030
		return self.flash -- 2033
	end -- 2033
	if self.room.key == "prologue" then -- 2033
		if self.phase == "prologue-wait" then -- 2033
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 2037
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 2038
		end -- 2038
		if self.phase == "prologue-give" then -- 2038
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 2041
		end -- 2041
		return "她跟着你了 · 两人一起走到门口 680" -- 2043
	end -- 2043
	if self.room.key == "street" then -- 2043
		if self:aliveEnemies() > 0 then -- 2043
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 2047
		end -- 2047
		return "清完了 · 两人一起走到右边检查站入口 900" -- 2049
	end -- 2049
	if self.room.key == "gate" then -- 2049
		local ____temp_17 -- 2052
		if self.room.story == nil then -- 2052
			____temp_17 = nil -- 2052
		else -- 2052
			____temp_17 = self.room.story.gate -- 2052
		end -- 2052
		local g = ____temp_17 -- 2052
		if g ~= nil then -- 2052
			if self.phase == "gate-idle" then -- 2052
				if self.gateNeedConfirm then -- 2052
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 2056
				end -- 2056
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 2058
			end -- 2058
			if self.phase == "gate-hold" then -- 2058
				if self.coveredFlash > 0 then -- 2058
					return "掩体挡下了这一枪 · 别露头" -- 2062
				end -- 2062
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 2064
			end -- 2064
			if self.phase == "gate-send" then -- 2064
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 2067
			end -- 2067
			if self.phase == "gate-count" then -- 2067
				if self.countTick >= 1440 then -- 2067
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 2071
				end -- 2071
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 2073
			end -- 2073
			return "她自己走 · 跟着出城门 1120" -- 2075
		end -- 2075
	end -- 2075
	if self.room.key == "forest" then -- 2075
		if self.dogState == "chase" then -- 2075
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 2080
		end -- 2080
		if self.dogState == "ear" then -- 2080
			return "狗转耳朵了 · 停下或蹲下别出声" -- 2083
		end -- 2083
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 2085
	end -- 2085
	if self.room.key == "tower" then -- 2085
		if self.phase == "tower-wait" then -- 2085
			return "走到门前 445 点一次 E 敲两下" -- 2089
		end -- 2089
		if self.phase == "tower-knock" then -- 2089
			return "敲两下 · 等门开" -- 2092
		end -- 2092
		if self.phase == "tower-given" then -- 2092
			return "递交针套和纸条 · 看登记簿最后一行" -- 2095
		end -- 2095
		return "片尾 · 点 E 再玩一次，回到序章" -- 2097
	end -- 2097
	if self.room.key == "village" then -- 2097
		if self.bottleFly ~= nil then -- 2097
			return "等瓶子落地 · 触地才发声" -- 2101
		end -- 2101
		if self.hasBottle then -- 2101
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 2104
		end -- 2104
		if self.passed then -- 2104
			return "已过第一院 · R 重置可再来一遍" -- 2107
		end -- 2107
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 2109
	end -- 2109
	if self.room.key == "outside" then -- 2109
		if self.focusCart then -- 2109
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 2113
		end -- 2113
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 2115
	end -- 2115
	if self.escort.state == "frozen" then -- 2115
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 2115
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 2119
		end -- 2119
		return "小满吓住了 · 走过去，靠近再点 E" -- 2121
	end -- 2121
	if self.escort.state == "calming" then -- 2121
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 2124
	end -- 2124
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 2126
end -- 2014
function Play.prototype.draw(self, draw, w, h) -- 2131
	self.viewW = w -- 2132
	self.viewH = h -- 2133
	self.view = ____exports.computeViewport(w, h) -- 2134
	self:clampCamera(w, h) -- 2135
	draw:clear() -- 2136
	draw:drawRect( -- 2138
		Rect(0, 0, w, h), -- 2138
		BG_VOID -- 2138
	) -- 2138
	local box = self:canvasRect(w, h) -- 2139
	draw:drawRect(box, BG_FAR) -- 2140
	draw:drawRect( -- 2141
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 2141
		BG_MID -- 2141
	) -- 2141
	self:drawFloors(draw, w, h) -- 2143
	self:drawSolids(draw, w, h) -- 2144
	self:drawZones(draw, w, h) -- 2145
	self:drawArch(draw, w, h) -- 2146
	self:drawCart(draw, w, h) -- 2147
	self:drawActors(draw, w, h) -- 2148
	self:drawTrace(draw, w, h) -- 2149
	self:drawAim(draw, w, h) -- 2150
end -- 2131
function Play.prototype.canvasRect(self, w, h) -- 2154
	local v = self.view -- 2155
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 2156
end -- 2154
function Play.prototype.px(self, n) -- 2160
	return n * self.view.zoom -- 2161
end -- 2160
function Play.prototype.sx(self, wx, w) -- 2165
	local v = self.view -- 2166
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 2167
	return v.ox + lx * v.zoom -- 2168
end -- 2165
function Play.prototype.sy(self, wy, h) -- 2172
	local v = self.view -- 2173
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 2174
	return v.oy + ly * v.zoom -- 2175
end -- 2172
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 2178
	local px0 = self:sx(x0, w) -- 2179
	local px1 = self:sx(x1, w) -- 2180
	local py0 = self:sy(y0, h) -- 2181
	local py1 = self:sy(y1, h) -- 2182
	if px1 <= px0 or py1 <= py0 then -- 2182
		return -- 2184
	end -- 2184
	draw:drawRect( -- 2186
		Rect(px0, py0, px1 - px0, py1 - py0), -- 2186
		color -- 2186
	) -- 2186
end -- 2178
function Play.prototype.drawFloors(self, draw, w, h) -- 2189
	local i = 0 -- 2190
	do -- 2190
		i = 0 -- 2191
		while i < #self.room.floors do -- 2191
			local f = self.room.floors[i + 1] -- 2192
			local y = self:sy(f.y, h) -- 2193
			local x0 = self:sx(f.x0, w) -- 2194
			local x1 = self:sx(f.x1, w) -- 2195
			local deck = self:px(5) -- 2196
			draw:drawRect( -- 2197
				Rect(x0, y - deck, x1 - x0, deck), -- 2197
				FLOOR_DECK -- 2197
			) -- 2197
			draw:drawSegment( -- 2198
				Vec2(x0, y), -- 2198
				Vec2(x1, y), -- 2198
				self:px(1), -- 2198
				GROUND -- 2198
			) -- 2198
			i = i + 1 -- 2191
		end -- 2191
	end -- 2191
end -- 2189
function Play.prototype.drawSolids(self, draw, w, h) -- 2202
	local i = 0 -- 2203
	do -- 2203
		i = 0 -- 2204
		while i < #self.boxes do -- 2204
			do -- 2204
				local b = self.boxes[i + 1] -- 2205
				if b.y0 < -4 and b.y1 <= 96 then -- 2205
					draw:drawSegment( -- 2208
						Vec2( -- 2208
							self:sx(b.x0, w), -- 2208
							self:sy(b.y1, h) -- 2208
						), -- 2208
						Vec2( -- 2208
							self:sx(b.x1, w), -- 2208
							self:sy(b.y1, h) -- 2208
						), -- 2208
						self:px(1), -- 2208
						GROUND -- 2208
					) -- 2208
					goto __continue447 -- 2209
				end -- 2209
				self:drawBox( -- 2211
					draw, -- 2211
					w, -- 2211
					h, -- 2211
					b.x0, -- 2211
					b.x1, -- 2211
					b.y0, -- 2211
					b.y1, -- 2211
					SOLID_FILL -- 2211
				) -- 2211
				draw:drawSegment( -- 2212
					Vec2( -- 2212
						self:sx(b.x0, w), -- 2212
						self:sy(b.y1, h) -- 2212
					), -- 2212
					Vec2( -- 2212
						self:sx(b.x1, w), -- 2212
						self:sy(b.y1, h) -- 2212
					), -- 2212
					self:px(1), -- 2212
					SOLID_EDGE -- 2212
				) -- 2212
			end -- 2212
			::__continue447:: -- 2212
			i = i + 1 -- 2204
		end -- 2204
	end -- 2204
end -- 2202
function Play.prototype.drawZones(self, draw, w, h) -- 2216
	local i = 0 -- 2217
	do -- 2217
		i = 0 -- 2218
		while i < #self.room.zones do -- 2218
			local z = self.room.zones[i + 1] -- 2219
			local fill = DANGER -- 2220
			local line = DANGER_LINE -- 2221
			if z.tint == 2 then -- 2221
				fill = SOFT -- 2223
				line = SOFT_LINE -- 2224
			elseif z.tint == 3 then -- 2224
				fill = BRICK -- 2226
				line = BRICK_LINE -- 2227
			elseif z.tint == 4 then -- 2227
				fill = PASS -- 2229
				line = PASS_LINE -- 2230
			end -- 2230
			self:drawBox( -- 2232
				draw, -- 2232
				w, -- 2232
				h, -- 2232
				z.x0, -- 2232
				z.x1, -- 2232
				z.y, -- 2232
				z.y + z.h, -- 2232
				fill -- 2232
			) -- 2232
			draw:drawSegment( -- 2233
				Vec2( -- 2233
					self:sx(z.x0, w), -- 2233
					self:sy(z.y, h) -- 2233
				), -- 2233
				Vec2( -- 2233
					self:sx(z.x0, w), -- 2233
					self:sy(z.y + z.h, h) -- 2233
				), -- 2233
				self:px(1), -- 2233
				line -- 2233
			) -- 2233
			draw:drawSegment( -- 2234
				Vec2( -- 2234
					self:sx(z.x1, w), -- 2234
					self:sy(z.y, h) -- 2234
				), -- 2234
				Vec2( -- 2234
					self:sx(z.x1, w), -- 2234
					self:sy(z.y + z.h, h) -- 2234
				), -- 2234
				self:px(1), -- 2234
				line -- 2234
			) -- 2234
			i = i + 1 -- 2218
		end -- 2218
	end -- 2218
end -- 2216
function Play.prototype.drawArch(self, draw, w, h) -- 2238
	local a = self.room.arch -- 2239
	if a.h <= 0 then -- 2239
		return -- 2241
	end -- 2241
	self:drawBox( -- 2243
		draw, -- 2243
		w, -- 2243
		h, -- 2243
		a.x0, -- 2243
		a.x1, -- 2243
		a.y, -- 2243
		a.y + a.h, -- 2243
		HOLE_FILL -- 2243
	) -- 2243
	draw:drawSegment( -- 2244
		Vec2( -- 2244
			self:sx(a.x0, w), -- 2244
			self:sy(a.y + a.h, h) -- 2244
		), -- 2244
		Vec2( -- 2244
			self:sx(a.x1, w), -- 2244
			self:sy(a.y + a.h, h) -- 2244
		), -- 2244
		self:px(1), -- 2244
		SOLID_EDGE -- 2244
	) -- 2244
	draw:drawSegment( -- 2245
		Vec2( -- 2245
			self:sx(a.x0, w), -- 2245
			self:sy(a.y, h) -- 2245
		), -- 2245
		Vec2( -- 2245
			self:sx(a.x0, w), -- 2245
			self:sy(a.y + a.h, h) -- 2245
		), -- 2245
		self:px(1), -- 2245
		SOLID_EDGE -- 2245
	) -- 2245
	draw:drawSegment( -- 2246
		Vec2( -- 2246
			self:sx(a.x1, w), -- 2246
			self:sy(a.y, h) -- 2246
		), -- 2246
		Vec2( -- 2246
			self:sx(a.x1, w), -- 2246
			self:sy(a.y + a.h, h) -- 2246
		), -- 2246
		self:px(1), -- 2246
		SOLID_EDGE -- 2246
	) -- 2246
end -- 2238
function Play.prototype.drawCart(self, draw, w, h) -- 2249
	local c = self.room.cart -- 2250
	if c.bodyW <= 0 then -- 2250
		return -- 2252
	end -- 2252
	drawCartShape( -- 2254
		draw, -- 2254
		self, -- 2254
		w, -- 2254
		h, -- 2254
		c, -- 2254
		self.cartAxle -- 2254
	) -- 2254
	draw:drawRect( -- 2255
		Rect( -- 2255
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 2255
			self:sy(c.baseY + 40, h), -- 2255
			self:px(2), -- 2255
			self:px(40) -- 2255
		), -- 2255
		STAND -- 2255
	) -- 2255
end -- 2249
function Play.prototype.drawActors(self, draw, w, h) -- 2258
	local p = self.player -- 2259
	local isChild = self.childMode -- 2260
	if p.covered then -- 2260
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 2263
		draw:drawSegment( -- 2264
			Vec2( -- 2264
				self:sx(edge, w), -- 2264
				self:sy(p.y + 8, h) -- 2264
			), -- 2264
			Vec2( -- 2264
				self:sx(edge, w), -- 2264
				self:sy(p.y + p.h * 0.62, h) -- 2264
			), -- 2264
			self:px(2), -- 2264
			STAND -- 2264
		) -- 2264
		draw:drawSegment( -- 2266
			Vec2( -- 2266
				self:sx(p.x - 8, w), -- 2266
				self:sy(p.y + p.h + 3, h) -- 2266
			), -- 2266
			Vec2( -- 2266
				self:sx(p.x + 8, w), -- 2266
				self:sy(p.y + p.h + 3, h) -- 2266
			), -- 2266
			self:px(2), -- 2266
			STAND -- 2266
		) -- 2266
	elseif self.coverNear and not isChild then -- 2266
		draw:drawRect( -- 2269
			Rect( -- 2269
				self:sx(p.x - 3, w), -- 2269
				self:sy(p.y + 1, h), -- 2269
				self:px(3), -- 2269
				self:px(3) -- 2269
			), -- 2269
			STAND -- 2269
		) -- 2269
	end -- 2269
	drawFigure( -- 2271
		draw, -- 2271
		self, -- 2271
		w, -- 2271
		h, -- 2271
		p, -- 2271
		isChild and CHILD_BODY or SOLDIER_BODY, -- 2271
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 2271
	) -- 2271
	local q = self.partner -- 2272
	if q.alive then -- 2272
		local childPartner = q.w == CHILD_W -- 2274
		drawFigure( -- 2275
			draw, -- 2275
			self, -- 2275
			w, -- 2275
			h, -- 2275
			q, -- 2275
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 2275
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 2275
		) -- 2275
	end -- 2275
	local i = 0 -- 2277
	do -- 2277
		i = 0 -- 2278
		while i < #self.enemies do -- 2278
			local e = self.enemies[i + 1] -- 2279
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 2280
			self:drawBox( -- 2281
				draw, -- 2281
				w, -- 2281
				h, -- 2281
				e.x - e.w / 2, -- 2281
				e.x + e.w / 2, -- 2281
				e.y, -- 2281
				e.y + e.h, -- 2281
				col -- 2281
			) -- 2281
			if e.alive and e.warnT > 0 then -- 2281
				local gunX = self:sx(e.x, w) -- 2284
				local gunY = self:sy(e.y + e.h * 0.72, h) -- 2285
				local aimX = self:sx(p.x, w) -- 2286
				local aimY = self:sy(p.y + p.h * 0.55, h) -- 2287
				local seg = 8 -- 2288
				local s = 0 -- 2289
				do -- 2289
					s = 0 -- 2290
					while s < seg do -- 2290
						local t0 = s / seg -- 2291
						local t1 = (s + 1) / seg -- 2292
						draw:drawSegment( -- 2293
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 2294
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 2295
							self:px(1), -- 2296
							DANGER -- 2296
						) -- 2296
						s = s + 2 -- 2290
					end -- 2290
				end -- 2290
			end -- 2290
			i = i + 1 -- 2278
		end -- 2278
	end -- 2278
	local k = 0 -- 2301
	do -- 2301
		k = 0 -- 2302
		while k < #self.room.marks do -- 2302
			do -- 2302
				local m = self.room.marks[k + 1] -- 2303
				if m.kind ~= 0 then -- 2303
					goto __continue469 -- 2305
				end -- 2305
				local on = self.checkpoint == m.x -- 2307
				local x = self:sx(m.x, w) -- 2308
				local y = self:sy(m.y, h) -- 2309
				draw:drawSegment( -- 2310
					Vec2(x, y), -- 2310
					Vec2( -- 2310
						x, -- 2310
						y + self:px(35) -- 2310
					), -- 2310
					self:px(1), -- 2310
					on and CHECK or INK_DIM -- 2310
				) -- 2310
				draw:drawDot( -- 2311
					Vec2( -- 2311
						x, -- 2311
						y + self:px(35) -- 2311
					), -- 2311
					self:px(2), -- 2311
					on and CHECK or INK_DIM -- 2311
				) -- 2311
			end -- 2311
			::__continue469:: -- 2311
			k = k + 1 -- 2302
		end -- 2302
	end -- 2302
	local j = 0 -- 2315
	do -- 2315
		j = 0 -- 2316
		while j < #self.room.marks do -- 2316
			do -- 2316
				local m = self.room.marks[j + 1] -- 2317
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 2317
					goto __continue472 -- 2319
				end -- 2319
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 2319
					goto __continue472 -- 2323
				end -- 2323
				local col = STAND -- 2325
				if m.kind == 4 then -- 2325
					col = PASS_LINE -- 2327
				elseif m.kind == 5 then -- 2327
					col = BRICK_LINE -- 2329
				end -- 2329
				local mx = self:sx(m.x, w) -- 2331
				local my = self:sy(m.y, h) -- 2332
				draw:drawSegment( -- 2333
					Vec2(mx, my), -- 2333
					Vec2( -- 2333
						mx, -- 2333
						my + self:px(24) -- 2333
					), -- 2333
					self:px(1), -- 2333
					col -- 2333
				) -- 2333
			end -- 2333
			::__continue472:: -- 2333
			j = j + 1 -- 2316
		end -- 2316
	end -- 2316
	local t = 0 -- 2336
	do -- 2336
		t = 0 -- 2337
		while t < #self.room.marks do -- 2337
			do -- 2337
				local m = self.room.marks[t + 1] -- 2338
				if m.kind ~= 6 then -- 2338
					goto __continue478 -- 2340
				end -- 2340
				local mx = self:sx(m.x, w) -- 2342
				local my = self:sy(m.y, h) -- 2343
				draw:drawSegment( -- 2344
					Vec2(mx, my), -- 2344
					Vec2( -- 2344
						mx, -- 2344
						my + self:px(30) -- 2344
					), -- 2344
					self:px(1), -- 2344
					INK_DIM -- 2344
				) -- 2344
				self:drawBox( -- 2345
					draw, -- 2345
					w, -- 2345
					h, -- 2345
					m.x - 5, -- 2345
					m.x + 5, -- 2345
					m.y + 30, -- 2345
					m.y + 40, -- 2345
					CHECK -- 2345
				) -- 2345
			end -- 2345
			::__continue478:: -- 2345
			t = t + 1 -- 2337
		end -- 2337
	end -- 2337
	if self.room.key == "village" then -- 2337
		self:drawVillage(draw, w, h) -- 2348
	end -- 2348
	if self.room.key == "forest" then -- 2348
		self:drawDog(draw, w, h) -- 2351
	end -- 2351
end -- 2258
function Play.prototype.drawDog(self, draw, w, h) -- 2356
	local x = self.dogX -- 2357
	self:drawBox( -- 2358
		draw, -- 2358
		w, -- 2358
		h, -- 2358
		x - 14, -- 2358
		x + 14, -- 2358
		0, -- 2358
		20, -- 2358
		SCAV_BODY -- 2358
	) -- 2358
	self:drawBox( -- 2359
		draw, -- 2359
		w, -- 2359
		h, -- 2359
		x - 10, -- 2359
		x - 2, -- 2359
		20, -- 2359
		30, -- 2359
		SCAV_BODY -- 2359
	) -- 2359
	self:drawBox( -- 2360
		draw, -- 2360
		w, -- 2360
		h, -- 2360
		x + 2, -- 2360
		x + 10, -- 2360
		20, -- 2360
		30, -- 2360
		SCAV_HEAD -- 2360
	) -- 2360
	if self.dogState == "ear" or self.dogState == "chase" then -- 2360
		draw:drawSegment( -- 2362
			Vec2( -- 2362
				self:sx(x, w), -- 2362
				self:sy(30, h) -- 2362
			), -- 2362
			Vec2( -- 2363
				self:sx(x, w), -- 2363
				self:sy(40, h) -- 2363
			), -- 2363
			self:px(1), -- 2363
			DANGER -- 2363
		) -- 2363
	end -- 2363
end -- 2356
function Play.prototype.drawVillage(self, draw, w, h) -- 2368
	local bottle = self.room.bottle -- 2369
	if bottle ~= nil then -- 2369
		self:drawBox( -- 2371
			draw, -- 2371
			w, -- 2371
			h, -- 2371
			bottle.x - 14, -- 2371
			bottle.x + 14, -- 2371
			0, -- 2371
			64, -- 2371
			SOLID_FILL -- 2371
		) -- 2371
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 2371
			self:drawBottle( -- 2373
				draw, -- 2373
				w, -- 2373
				h, -- 2373
				bottle.x, -- 2373
				64 -- 2373
			) -- 2373
		end -- 2373
	end -- 2373
	self:drawBox( -- 2377
		draw, -- 2377
		w, -- 2377
		h, -- 2377
		300, -- 2377
		420, -- 2377
		44, -- 2377
		50, -- 2377
		FLOOR_DECK -- 2377
	) -- 2377
	self:drawBox( -- 2378
		draw, -- 2378
		w, -- 2378
		h, -- 2378
		300, -- 2378
		306, -- 2378
		0, -- 2378
		44, -- 2378
		FLOOR_DECK -- 2378
	) -- 2378
	self:drawBox( -- 2379
		draw, -- 2379
		w, -- 2379
		h, -- 2379
		414, -- 2379
		420, -- 2379
		0, -- 2379
		44, -- 2379
		FLOOR_DECK -- 2379
	) -- 2379
	local s = self.room.scavenger -- 2381
	if s ~= nil then -- 2381
		local sx0 = self.scavX -- 2383
		self:drawBox( -- 2384
			draw, -- 2384
			w, -- 2384
			h, -- 2384
			sx0 - 12, -- 2384
			sx0 + 12, -- 2384
			0, -- 2384
			s.h - 14, -- 2384
			SCAV_BODY -- 2384
		) -- 2384
		self:drawBox( -- 2385
			draw, -- 2385
			w, -- 2385
			h, -- 2385
			sx0 - 7, -- 2385
			sx0 + 7, -- 2385
			s.h - 14, -- 2385
			s.h, -- 2385
			SCAV_HEAD -- 2385
		) -- 2385
		if self.scavState == "turn" then -- 2385
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 2387
			draw:drawSegment( -- 2388
				Vec2( -- 2388
					self:sx(sx0, w), -- 2388
					self:sy(s.h - 6, h) -- 2388
				), -- 2388
				Vec2( -- 2388
					self:sx(fx, w), -- 2388
					self:sy(s.h - 6, h) -- 2388
				), -- 2388
				self:px(1), -- 2388
				INK -- 2388
			) -- 2388
		end -- 2388
	end -- 2388
	if self.hasBottle then -- 2388
		local p = self.player -- 2393
		self:drawBottle( -- 2394
			draw, -- 2394
			w, -- 2394
			h, -- 2394
			p.x + p.facing * 10, -- 2394
			p.y + p.h * 0.62 -- 2394
		) -- 2394
	end -- 2394
	if self.bottleFly ~= nil then -- 2394
		self:drawBottle( -- 2397
			draw, -- 2397
			w, -- 2397
			h, -- 2397
			self.bottleFly.x, -- 2397
			self.bottleFly.y -- 2397
		) -- 2397
	end -- 2397
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 2397
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 2400
		draw:drawCircle( -- 2401
			Vec2( -- 2401
				self:sx(self.bottleLandX, w), -- 2401
				self:sy(0, h) -- 2401
			), -- 2401
			self:px(r / ____exports.UNITS_PER_PX), -- 2401
			BRICK_LINE -- 2401
		) -- 2401
	end -- 2401
end -- 2368
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 2405
	self:drawBox( -- 2406
		draw, -- 2406
		w, -- 2406
		h, -- 2406
		x - 3, -- 2406
		x + 3, -- 2406
		y - 10, -- 2406
		y, -- 2406
		BOTTLE -- 2406
	) -- 2406
end -- 2405
function Play.prototype.drawTrace(self, draw, w, h) -- 2409
	local t = self.trace -- 2410
	if t == nil or self.traceT <= 0 then -- 2410
		return -- 2412
	end -- 2412
	draw:drawSegment( -- 2414
		Vec2( -- 2415
			self:sx(t.x0, w), -- 2415
			self:sy(t.y0, h) -- 2415
		), -- 2415
		Vec2( -- 2416
			self:sx(t.x1, w), -- 2416
			self:sy(t.y1, h) -- 2416
		), -- 2416
		self:px(1), -- 2417
		t.hit and AIM_HIT or INK_DIM -- 2417
	) -- 2417
end -- 2409
function Play.prototype.drawAim(self, draw, w, h) -- 2420
	local v = self.view -- 2422
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 2423
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 2424
	local dot = self:px(1) -- 2425
	local arm = self:px(3) -- 2426
	local gap = self:px(1) -- 2427
	draw:drawSegment( -- 2428
		Vec2(gx - arm - gap, gy), -- 2428
		Vec2(gx - gap, gy), -- 2428
		dot / 2, -- 2428
		AIM -- 2428
	) -- 2428
	draw:drawSegment( -- 2429
		Vec2(gx + gap, gy), -- 2429
		Vec2(gx + arm + gap, gy), -- 2429
		dot / 2, -- 2429
		AIM -- 2429
	) -- 2429
	draw:drawSegment( -- 2430
		Vec2(gx, gy - arm - gap), -- 2430
		Vec2(gx, gy - gap), -- 2430
		dot / 2, -- 2430
		AIM -- 2430
	) -- 2430
	draw:drawSegment( -- 2431
		Vec2(gx, gy + gap), -- 2431
		Vec2(gx, gy + arm + gap), -- 2431
		dot / 2, -- 2431
		AIM -- 2431
	) -- 2431
	if self.room.key == "village" and self.hasBottle then -- 2431
		local p = self.player -- 2435
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2437
		local dir = ____end.x >= p.x and 1 or -1 -- 2438
		local x0 = p.x + dir * 10 -- 2439
		local y0 = p.y + p.h * 0.7 -- 2440
		local T = 0.62 -- 2441
		local vx = (____end.x - x0) / T -- 2442
		local vy = (____end.y - y0 + 0.5 * GRAVITY * T * T) / T -- 2443
		local pxr = x0 -- 2444
		local pyr = y0 -- 2445
		local t = 1 -- 2446
		do -- 2446
			t = 1 -- 2447
			while t <= 12 do -- 2447
				local tt = t / 12 * T -- 2448
				local nx = x0 + vx * tt -- 2449
				local ny = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 2450
				draw:drawSegment( -- 2451
					Vec2( -- 2451
						self:sx(pxr, w), -- 2451
						self:sy(pyr, h) -- 2451
					), -- 2451
					Vec2( -- 2451
						self:sx(nx, w), -- 2451
						self:sy(ny, h) -- 2451
					), -- 2451
					self:px(1) / 2, -- 2451
					BOTTLE -- 2451
				) -- 2451
				pxr = nx -- 2452
				pyr = ny -- 2453
				t = t + 1 -- 2447
			end -- 2447
		end -- 2447
		draw:drawCircle( -- 2455
			Vec2( -- 2455
				self:sx(____end.x, w), -- 2455
				self:sy(____end.y + 2, h) -- 2455
			), -- 2455
			self:px(2), -- 2455
			BOTTLE -- 2455
		) -- 2455
	end -- 2455
end -- 2420
return ____exports -- 2420