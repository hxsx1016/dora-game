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
function makeActor(room, index) -- 1483
	local sp = room.spawns -- 1484
	if index < 0 or index >= #sp then -- 1484
		return { -- 1486
			x = 0, -- 1486
			y = 0, -- 1486
			vx = 0, -- 1486
			vy = 0, -- 1486
			w = CHILD_W, -- 1486
			h = CHILD_H, -- 1486
			onGround = true, -- 1486
			facing = 1, -- 1486
			crouch = false, -- 1486
			rollT = 0, -- 1486
			covered = false, -- 1486
			alive = false -- 1486
		} -- 1486
	end -- 1486
	local s = sp[index + 1] -- 1488
	local child = s.h <= CHILD_H -- 1489
	return { -- 1490
		x = s.x, -- 1491
		y = s.y, -- 1491
		vx = 0, -- 1491
		vy = 0, -- 1491
		w = child and CHILD_W or SOLDIER_W, -- 1492
		h = child and CHILD_H or SOLDIER_H, -- 1493
		onGround = true, -- 1494
		facing = 1, -- 1494
		crouch = false, -- 1494
		rollT = 0, -- 1494
		covered = false, -- 1494
		alive = true -- 1494
	} -- 1494
end -- 1494
function drawFigure(draw, play, w, h, a, body, head) -- 1498
	if not a.alive then -- 1498
		return -- 1500
	end -- 1500
	local x0 = a.x - a.w / 2 -- 1502
	local x1 = a.x + a.w / 2 -- 1503
	local y0 = a.y -- 1504
	local y1 = a.y + a.h -- 1505
	play:drawBox( -- 1506
		draw, -- 1506
		w, -- 1506
		h, -- 1506
		x0, -- 1506
		x1, -- 1506
		y0, -- 1506
		y1 - a.h * 0.26, -- 1506
		body -- 1506
	) -- 1506
	play:drawBox( -- 1507
		draw, -- 1507
		w, -- 1507
		h, -- 1507
		x0 + 2, -- 1507
		x1 - 2, -- 1507
		y1 - a.h * 0.26, -- 1507
		y1, -- 1507
		head -- 1507
	) -- 1507
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 1509
	play:drawBox( -- 1510
		draw, -- 1510
		w, -- 1510
		h, -- 1510
		eyeX, -- 1510
		eyeX + 4, -- 1510
		y1 - a.h * 0.14, -- 1510
		y1 - a.h * 0.08, -- 1510
		INK -- 1510
	) -- 1510
end -- 1510
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 1514
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 1515
end -- 1514
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 1522
	local tmin = 0 -- 1523
	local tmax = 99999 -- 1524
	if dx == 0 then -- 1524
		if ox < x0 or ox > x1 then -- 1524
			return -1 -- 1527
		end -- 1527
	else -- 1527
		local t1 = (x0 - ox) / dx -- 1530
		local t2 = (x1 - ox) / dx -- 1531
		local lo = t1 < t2 and t1 or t2 -- 1532
		local hi = t1 < t2 and t2 or t1 -- 1533
		if lo > tmin then -- 1533
			tmin = lo -- 1535
		end -- 1535
		if hi < tmax then -- 1535
			tmax = hi -- 1538
		end -- 1538
	end -- 1538
	if dy == 0 then -- 1538
		if oy < y0 or oy > y1 then -- 1538
			return -1 -- 1543
		end -- 1543
	else -- 1543
		local t1 = (y0 - oy) / dy -- 1546
		local t2 = (y1 - oy) / dy -- 1547
		local lo = t1 < t2 and t1 or t2 -- 1548
		local hi = t1 < t2 and t2 or t1 -- 1549
		if lo > tmin then -- 1549
			tmin = lo -- 1551
		end -- 1551
		if hi < tmax then -- 1551
			tmax = hi -- 1554
		end -- 1554
	end -- 1554
	return tmax >= tmin and tmin or -1 -- 1557
end -- 1557
function drawCartShape(draw, play, w, h, c, axleX) -- 1560
	local half = c.bodyW / 2 -- 1561
	local x0 = axleX - half -- 1562
	local x1 = axleX + half -- 1563
	play:drawBox( -- 1564
		draw, -- 1564
		w, -- 1564
		h, -- 1564
		x0, -- 1564
		x1, -- 1564
		c.baseY + c.wheelR, -- 1564
		c.baseY + c.wheelR + c.bodyH, -- 1564
		CART_FILL -- 1564
	) -- 1564
	draw:drawCircle( -- 1565
		Vec2( -- 1565
			play:sx(x0 + c.bodyW * 0.28, w), -- 1565
			play:sy(c.baseY + c.wheelR, h) -- 1565
		), -- 1565
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 1565
		Color(52, 50, 48, 255) -- 1565
	) -- 1565
	draw:drawCircle( -- 1566
		Vec2( -- 1566
			play:sx(x1 - c.bodyW * 0.28, w), -- 1566
			play:sy(c.baseY + c.wheelR, h) -- 1566
		), -- 1566
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 1566
		Color(52, 50, 48, 255) -- 1566
	) -- 1566
	local cx = c.clothSide < 0 and x0 or x1 -- 1567
	play:drawBox( -- 1568
		draw, -- 1568
		w, -- 1568
		h, -- 1568
		cx - 10, -- 1568
		cx + 10, -- 1568
		c.baseY + c.wheelR + c.bodyH, -- 1568
		c.baseY + c.wheelR + c.bodyH + 18, -- 1568
		CLOTH -- 1568
	) -- 1568
end -- 1568
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
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 57
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 59
INK = Color(232, 232, 228, 255) -- 61
local INK_DIM = Color(150, 152, 150, 255) -- 62
local BG_VOID = Color(8, 9, 10, 255) -- 63
local BG_FAR = Color(24, 26, 28, 255) -- 64
local BG_MID = Color(31, 34, 37, 255) -- 65
local GROUND = Color(112, 114, 112, 255) -- 66
local FLOOR_DECK = Color(66, 70, 72, 255) -- 67
local SOLID_FILL = Color(84, 86, 84, 255) -- 68
local SOLID_EDGE = Color(126, 130, 126, 255) -- 69
CART_FILL = Color(122, 78, 56, 255) -- 70
CLOTH = Color(178, 52, 46, 255) -- 71
local DANGER = Color(150, 54, 48, 46) -- 72
local DANGER_LINE = Color(178, 78, 64, 200) -- 73
local HOLE_FILL = Color(10, 11, 12, 255) -- 74
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 75
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 76
local CHILD_BODY = Color(214, 168, 96, 255) -- 77
local CHILD_HEAD = Color(232, 214, 186, 255) -- 78
local ENEMY_BODY = Color(176, 92, 84, 255) -- 79
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 80
local CHECK = Color(96, 186, 122, 255) -- 81
local STAND = Color(226, 186, 84, 255) -- 82
local AIM = Color(236, 236, 232, 230) -- 83
local AIM_HIT = Color(236, 96, 84, 255) -- 84
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 86
local SOFT_LINE = Color(140, 112, 80, 190) -- 87
local BRICK = Color(126, 118, 110, 70) -- 88
local BRICK_LINE = Color(160, 152, 142, 200) -- 89
local PASS = Color(96, 186, 122, 40) -- 90
local PASS_LINE = Color(96, 186, 122, 200) -- 91
local BOTTLE = Color(120, 186, 160, 255) -- 92
local SCAV_BODY = Color(128, 118, 96, 255) -- 93
local SCAV_HEAD = Color(196, 182, 158, 255) -- 94
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 143
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 144
	if zoom < 1 then -- 144
		zoom = 1 -- 146
	end -- 146
	return { -- 148
		zoom = zoom, -- 149
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 150
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 151
	} -- 151
end -- 143
____exports.Play = __TS__Class() -- 164
local Play = ____exports.Play -- 164
Play.name = "Play" -- 164
function Play.prototype.____constructor(self, room, resume) -- 239
	self.enemies = {} -- 169
	self.boxes = {} -- 170
	self.floors = {} -- 171
	self.checkpoint = -1 -- 173
	self.flash = "" -- 175
	self.flashT = 0 -- 176
	self.traceT = 0 -- 179
	self.focusCart = false -- 181
	self.knocks = 0 -- 183
	self.knockT = 0 -- 184
	self.cartAxle = 0 -- 188
	self.cartDocked = false -- 190
	self.gripping = false -- 192
	self.gateOpen = false -- 194
	self.calmConsumed = false -- 196
	self.nextDangerId = 1 -- 198
	self.wantRoom = "" -- 200
	self.carryCartAxle = -1 -- 202
	self.carryCartDocked = false -- 203
	self.checkpointCartAxle = -1 -- 205
	self.hasBottle = false -- 209
	self.bottleLandX = -1 -- 213
	self.bottleLandT = 0 -- 214
	self.aimHold = 0 -- 216
	self.scavX = 0 -- 218
	self.scavDir = 1 -- 219
	self.scavState = "patrol" -- 220
	self.scavT = 0 -- 221
	self.scavTargetX = 0 -- 222
	self.passed = false -- 224
	self.paused = false -- 225
	self.ticks = 0 -- 227
	self.view = {zoom = 1, ox = 0, oy = 0} -- 229
	self.ox = 0 -- 231
	self.aimX = 0 -- 233
	self.aimY = 0 -- 234
	self.viewW = 0 -- 236
	self.viewH = 0 -- 237
	self.ox = room.originX -- 241
	self.room = withOrigin(room) -- 242
	local wr = self.room -- 243
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 244
	self:buildWorld() -- 245
	self.player = makeActor(wr, wr.key == "checkpoint" and 1 or 0) -- 246
	self.partner = makeActor(wr, wr.key == "checkpoint" and 0 or -1) -- 247
	self.cam.x = self.player.x -- 248
	self.cam.y = self.player.y + CAM_LOOK_UP -- 249
	self.cartAxle = wr.cart.startX -- 250
	self.escort = __TS__New( -- 251
		Escort, -- 251
		safeAnchorX(wr.marks) -- 251
	) -- 251
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 252
	self:buildEnemies() -- 253
	if resume ~= nil and resume.checkpoint > 0 then -- 253
		self.checkpoint = resume.checkpoint -- 256
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 256
			self.cartAxle = self.room.cart.endX -- 258
			self.cartDocked = true -- 259
			self.player.x = self.ox + 380 -- 262
			self.player.y = 0 -- 263
			self.player.vy = 0 -- 264
			self.player.onGround = true -- 265
			self.cam.x = self.player.x -- 266
			self.cam.y = self.player.y + CAM_LOOK_UP -- 267
		end -- 267
	end -- 267
end -- 239
function Play.prototype.buildWorld(self) -- 273
	local room = self.room -- 274
	self.boxes = {} -- 275
	self.floors = {} -- 276
	local i = 0 -- 277
	do -- 277
		i = 0 -- 278
		while i < #room.floors do -- 278
			local f = room.floors[i + 1] -- 279
			local ____self_floors_0 = self.floors -- 279
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 280
			i = i + 1 -- 278
		end -- 278
	end -- 278
	do -- 278
		i = 0 -- 282
		while i < #room.solids do -- 282
			local s = room.solids[i + 1] -- 283
			local ____self_boxes_1 = self.boxes -- 283
			____self_boxes_1[#____self_boxes_1 + 1] = {x0 = s.x, x1 = s.x + s.w, y0 = s.y, y1 = s.y + s.h} -- 284
			i = i + 1 -- 282
		end -- 282
	end -- 282
	do -- 282
		i = 0 -- 286
		while i < #room.stairs do -- 286
			local st = room.stairs[i + 1] -- 287
			local n = st.steps + 1 -- 288
			local stepW = (st.x1 - st.x0) / n -- 289
			local k = 0 -- 290
			do -- 290
				k = 0 -- 291
				while k < n do -- 291
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 292
					local x0 = st.x0 + stepW * k -- 293
					local ____self_boxes_2 = self.boxes -- 293
					____self_boxes_2[#____self_boxes_2 + 1] = { -- 295
						x0 = x0, -- 295
						x1 = x0 + stepW, -- 295
						y0 = -8, -- 295
						y1 = y, -- 295
						passable = true -- 295
					} -- 295
					k = k + 1 -- 291
				end -- 291
			end -- 291
			i = i + 1 -- 286
		end -- 286
	end -- 286
end -- 273
function Play.prototype.buildEnemies(self) -- 300
	self.enemies = {} -- 301
	if self.room.key ~= "checkpoint" then -- 301
		return -- 303
	end -- 303
	local ____self_enemies_3 = self.enemies -- 303
	____self_enemies_3[#____self_enemies_3 + 1] = { -- 305
		x = self.ox + 430, -- 305
		y = 0, -- 305
		w = 26, -- 305
		h = 84, -- 305
		alive = true, -- 305
		hitT = 0 -- 305
	} -- 305
	local ____self_enemies_4 = self.enemies -- 305
	____self_enemies_4[#____self_enemies_4 + 1] = { -- 306
		x = self.ox + 505, -- 306
		y = 0, -- 306
		w = 26, -- 306
		h = 84, -- 306
		alive = true, -- 306
		hitT = 0 -- 306
	} -- 306
end -- 300
function Play.prototype.update(self, dt, input) -- 310
	if input.pause.pressed then -- 310
		self.paused = not self.paused -- 312
	end -- 312
	if self.flashT > 0 then -- 312
		self.flashT = self.flashT - dt -- 315
		if self.flashT <= 0 then -- 315
			self.flash = "" -- 317
		end -- 317
	end -- 317
	if self.traceT > 0 then -- 317
		self.traceT = self.traceT - dt -- 321
		if self.traceT <= 0 then -- 321
			self.trace = nil -- 323
		end -- 323
	end -- 323
	if self.paused then -- 323
		self:updateCamera(dt) -- 327
		return -- 328
	end -- 328
	self.ticks = self.ticks + 1 -- 331
	local p = self.player -- 332
	self:stepPlayer(p, dt, input) -- 333
	self:stepEscort(dt, input) -- 334
	self:stepEnemies(dt) -- 335
	self:stepVillage(dt, input) -- 336
	self:stepInteract(dt, input) -- 337
	self:updateGate() -- 338
	self:updateCamera(dt) -- 339
end -- 310
function Play.prototype.nearLowLedge(self, a) -- 343
	local reach = 26 -- 344
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 345
	local x1 = x0 + reach -- 346
	local i = 0 -- 347
	do -- 347
		i = 0 -- 348
		while i < #self.boxes do -- 348
			do -- 348
				local b = self.boxes[i + 1] -- 349
				if b.x1 <= x0 or b.x0 >= x1 then -- 349
					goto __continue27 -- 351
				end -- 351
				local rise = b.y1 - a.y -- 353
				if rise > 0 and rise <= LEDGE_RISE then -- 353
					return true -- 355
				end -- 355
			end -- 355
			::__continue27:: -- 355
			i = i + 1 -- 348
		end -- 348
	end -- 348
	return false -- 358
end -- 343
function Play.prototype.stepPlayer(self, a, dt, input) -- 361
	if not a.alive then -- 361
		return -- 363
	end -- 363
	local isChild = self.room.key ~= "checkpoint" -- 365
	if not isChild and self.escort.state == "calming" then -- 365
		a.crouch = false -- 368
		a.h = SOLDIER_H -- 369
		a.vx = 0 -- 370
		self:fallY(a, dt) -- 371
		return -- 372
	end -- 372
	a.crouch = isChild and input.crouch.held and a.onGround -- 374
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 375
	a.covered = not isChild and input.cover.held -- 376
	if a.rollT > 0 then -- 376
		a.rollT = a.rollT - dt -- 380
		a.vx = a.facing * ROLL_SPEED -- 381
		self:slideX(a, a.vx * dt) -- 382
		self:fallY(a, dt) -- 383
		if a.rollT <= 0 then -- 383
			self:flashSet("翻滚结束", 0.5) -- 385
		end -- 385
		return -- 387
	end -- 387
	if not isChild and input.jump.pressed and a.onGround then -- 387
		if input.moveX ~= 0 then -- 387
			a.facing = input.moveX > 0 and 1 or -1 -- 392
		end -- 392
		if self:nearLowLedge(a) then -- 392
			a.vy = SOLDIER_JUMP -- 396
			a.onGround = false -- 397
			self:flashSet("翻上去", 0.3) -- 398
			return -- 399
		end -- 399
		a.rollT = ROLL_TIME -- 401
		self:flashSet("翻滚", 0.3) -- 402
		return -- 403
	end -- 403
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 406
	if isChild then -- 406
		if input.cover.held then -- 406
			speed = CHILD_SLOW -- 409
		end -- 409
		if a.crouch then -- 409
			speed = CHILD_SLOW -- 412
		end -- 412
	elseif a.covered then -- 412
		speed = SOLDIER_SPEED * 0.45 -- 415
	end -- 415
	local dir = self.gripping and 0 or input.moveX -- 419
	if dir ~= 0 then -- 419
		a.facing = dir > 0 and 1 or -1 -- 421
	end -- 421
	a.vx = dir * speed -- 423
	if isChild and input.jump.pressed and a.onGround and not a.crouch then -- 423
		a.vy = CHILD_JUMP -- 427
		a.onGround = false -- 428
		self:flashSet("跳", 0.25) -- 429
	end -- 429
	self:slideX(a, a.vx * dt) -- 432
	self:fallY(a, dt) -- 433
	if not isChild and input.fire.pressed then -- 433
		self:shoot(a) -- 437
	end -- 437
end -- 361
function Play.prototype.stepPartner(self, p, dt) -- 442
	local a = self.partner -- 443
	if not a.alive then -- 443
		return -- 445
	end -- 445
	a.crouch = false -- 447
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 448
	a.vx = 0 -- 449
	self:fallY(a, dt) -- 450
end -- 442
function Play.prototype.stepEscort(self, dt, input) -- 457
	local a = self.partner -- 458
	if not a.alive then -- 458
		return -- 460
	end -- 460
	if self.room.key ~= "checkpoint" then -- 460
		a.vx = 0 -- 463
		self:fallY(a, dt) -- 464
		return -- 465
	end -- 465
	local p = self.player -- 467
	local dist = math.abs(p.x - a.x) -- 468
	self.calmConsumed = self.escort:update( -- 469
		input, -- 469
		p.x, -- 469
		p.facing, -- 469
		a.x, -- 469
		dist -- 469
	) -- 469
	a.crouch = self.escort.crouchPose -- 470
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 471
	local dir = self.escort:moveDir(a.x) -- 472
	a.vx = dir * CHILD_SPEED -- 473
	if dir ~= 0 then -- 473
		a.facing = dir -- 475
		local before = a.x -- 476
		self:slideX(a, dir * CHILD_SPEED * dt) -- 477
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 477
			a.vy = CHILD_JUMP -- 480
			a.onGround = false -- 481
		end -- 481
	end -- 481
	self:fallY(a, dt) -- 484
end -- 457
function Play.prototype.updateGate(self) -- 487
	if self.room.key ~= "checkpoint" then -- 487
		self.gateOpen = false -- 489
		return -- 490
	end -- 490
	local function inZone(x) -- 492
		return x >= self.ox + 792 and x <= self.ox + 928 -- 492
	end -- 492
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 493
end -- 487
function Play.prototype.stepEnemies(self, dt) -- 496
	local i = 0 -- 497
	do -- 497
		i = 0 -- 498
		while i < #self.enemies do -- 498
			local e = self.enemies[i + 1] -- 499
			if e.hitT > 0 then -- 499
				e.hitT = e.hitT - dt -- 501
			end -- 501
			i = i + 1 -- 498
		end -- 498
	end -- 498
end -- 496
function Play.prototype.stepInteract(self, dt, input) -- 506
	local p = self.player -- 507
	local calmUsed = self.calmConsumed -- 508
	self.calmConsumed = false -- 509
	self.focusCart = false -- 510
	if self.room.key == "outside" then -- 510
		local c = self.room.cart -- 512
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 513
		local dy = p.y - c.baseY -- 514
		self.focusCart = dx * dx + dy * dy < CART_REACH * CART_REACH -- 515
	end -- 515
	self:stepCart(dt, input) -- 517
	if calmUsed then -- 517
		self:flashSet("安抚 · 敲两下", 0.8) -- 521
	elseif input.interact.pressed and not self.gripping and self.room.key ~= "village" then -- 521
		if self.knockT > 0 then -- 521
			self.knocks = self.knocks + 1 -- 524
		else -- 524
			self.knocks = 1 -- 526
		end -- 526
		self.knockT = 1.2 -- 528
		if self.knocks >= 2 then -- 528
			self:flashSet("敲两下", 0.8) -- 530
			self.knocks = 0 -- 531
		else -- 531
			self:flashSet("敲一下", 0.5) -- 533
		end -- 533
	elseif self.knockT > 0 then -- 533
		self.knockT = self.knockT - dt -- 536
		if self.knockT <= 0 then -- 536
			self.knocks = 0 -- 538
		end -- 538
	end -- 538
	local i = 0 -- 543
	do -- 543
		i = 0 -- 544
		while i < #self.room.marks do -- 544
			do -- 544
				local m = self.room.marks[i + 1] -- 545
				if m.kind ~= 0 then -- 545
					goto __continue70 -- 547
				end -- 547
				local subjects = {self.partner, self.player} -- 549
				local k = 0 -- 550
				do -- 550
					k = 0 -- 551
					while k < #subjects do -- 551
						do -- 551
							local s = subjects[k + 1] -- 552
							if not s.alive then -- 552
								goto __continue73 -- 554
							end -- 554
							local dx = s.x - m.x -- 556
							local dy = s.y - m.y -- 557
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 557
								self.checkpoint = m.x -- 559
								self.checkpointCartAxle = self.cartAxle -- 560
								if self.cartDocked then -- 560
									self:flashSet("检查点 · 车已落窝", 1) -- 562
								else -- 562
									self:flashSet("检查点 · 车还没到位", 1) -- 564
								end -- 564
							end -- 564
						end -- 564
						::__continue73:: -- 564
						k = k + 1 -- 551
					end -- 551
				end -- 551
			end -- 551
			::__continue70:: -- 551
			i = i + 1 -- 544
		end -- 544
	end -- 544
	self:checkCarryGate() -- 570
end -- 506
function Play.prototype.stepVillage(self, dt, input) -- 574
	if self.room.key ~= "village" then -- 574
		return -- 576
	end -- 576
	local p = self.player -- 578
	local bottle = self.room.bottle -- 579
	local scav = self.room.scavenger -- 580
	if not self.hasBottle and bottle ~= nil then -- 580
		local dx = p.x - bottle.x -- 584
		local dy = p.y + p.h * 0.5 - bottle.y -- 585
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 585
			self.hasBottle = true -- 587
			self:flashSet("拾起瓶子", 0.8) -- 588
		end -- 588
	end -- 588
	if self.hasBottle then -- 588
		if input.aim.held then -- 588
			self.aimHold = self.aimHold + dt -- 595
			if self.aimHold > 1.2 then -- 595
				self.aimHold = 1.2 -- 597
			end -- 597
		elseif input.aim.released then -- 597
			local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 600
			self:throwBottle(aim.x, aim.y) -- 601
			self.aimHold = 0 -- 602
		end -- 602
	else -- 602
		self.aimHold = 0 -- 605
	end -- 605
	local fly = self.bottleFly -- 609
	if fly ~= nil then -- 609
		fly.vy = fly.vy - GRAVITY * dt -- 611
		fly.x = fly.x + fly.vx * dt -- 612
		fly.y = fly.y + fly.vy * dt -- 613
		local g = self:groundAt(fly.x, fly.y + 4, 3) -- 614
		if fly.y <= g then -- 614
			self.bottleFly = nil -- 616
			self.bottleLandX = fly.x -- 617
			self.bottleLandT = 0.9 -- 618
			self:hearBottle(fly.x) -- 619
		end -- 619
	end -- 619
	if self.bottleLandT > 0 then -- 619
		self.bottleLandT = self.bottleLandT - dt -- 623
	end -- 623
	if scav ~= nil then -- 623
		self:stepScav(dt, scav) -- 627
	end -- 627
	local line = self.room.passLine -- 630
	if line ~= nil and not self.passed and p.x >= line then -- 630
		self.passed = true -- 632
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 633
	end -- 633
end -- 574
function Play.prototype.throwBottle(self, tx, ty) -- 638
	local p = self.player -- 639
	local x0 = p.x + p.facing * 10 -- 640
	local y0 = p.y + p.h * 0.7 -- 641
	local T = 0.62 -- 642
	local vx = (tx - x0) / T -- 643
	local vy = (ty - y0 + 0.5 * GRAVITY * T * T) / T -- 644
	self.bottleFly = {x = x0, y = y0, vx = vx, vy = vy} -- 645
	self.hasBottle = false -- 646
	self:flashSet("投出", 0.4) -- 647
end -- 638
function Play.prototype.hearBottle(self, x) -- 651
	local s = self.room.scavenger -- 652
	if s == nil then -- 652
		return -- 654
	end -- 654
	if math.abs(x - self.scavX) > s.range then -- 654
		self:flashSet("落地 · 他没听见", 0.6) -- 657
		return -- 658
	end -- 658
	self.scavState = "turn" -- 660
	self.scavT = s.hearTicks -- 661
	self.scavTargetX = x -- 662
	self:flashSet("砖地一响 · 他转头", 0.9) -- 663
end -- 651
function Play.prototype.stepScav(self, dt, s) -- 667
	if self.scavState == "turn" then -- 667
		self.scavT = self.scavT - 1 -- 669
		if self.scavT <= 0 then -- 669
			self.scavState = "walk" -- 671
		end -- 671
		return -- 673
	end -- 673
	if self.scavState == "walk" then -- 673
		local d = self.scavTargetX - self.scavX -- 676
		if math.abs(d) < 4 then -- 676
			self.scavState = "stall" -- 678
			self.scavT = s.stallTicks -- 679
			return -- 680
		end -- 680
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 682
		return -- 683
	end -- 683
	if self.scavState == "stall" then -- 683
		self.scavT = self.scavT - 1 -- 686
		if self.scavT <= 0 then -- 686
			self.scavState = "back" -- 688
		end -- 688
		return -- 690
	end -- 690
	if self.scavState == "back" then -- 690
		local home = math.max( -- 693
			s.x0, -- 693
			math.min(s.x1, self.scavX) -- 693
		) -- 693
		if math.abs(home - self.scavX) < 2 then -- 693
			self.scavState = "patrol" -- 695
			return -- 696
		end -- 696
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 698
		return -- 699
	end -- 699
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 701
	if self.scavX >= s.x1 then -- 701
		self.scavX = s.x1 -- 703
		self.scavDir = -1 -- 704
	elseif self.scavX <= s.x0 then -- 704
		self.scavX = s.x0 -- 706
		self.scavDir = 1 -- 707
	end -- 707
end -- 667
function Play.prototype.stepCart(self, dt, input) -- 715
	local p = self.player -- 716
	local c = self.room.cart -- 717
	local handleX = self.cartAxle + c.handleOffset -- 718
	if self.gripping then -- 718
		if not input.interact.held then -- 718
			self.gripping = false -- 722
			self:flashSet("松开车把", 0.4) -- 723
			return -- 724
		end -- 724
	else -- 724
		if not input.interact.pressed then -- 724
			return -- 728
		end -- 728
		if math.abs(p.x - handleX) > CART_REACH or math.abs(p.y - c.baseY) > 40 then -- 728
			return -- 731
		end -- 731
		self.gripping = true -- 733
		self:flashSet("握住车把", 0.4) -- 734
		return -- 735
	end -- 735
	if self.cartDocked then -- 735
		return -- 739
	end -- 739
	local dir = input.moveX -- 741
	if dir == 0 then -- 741
		return -- 743
	end -- 743
	local lo = math.min(c.startX, c.endX) -- 745
	local hi = math.max(c.startX, c.endX) -- 746
	local next = self.cartAxle + dir * CART_SPEED * dt -- 747
	if next < lo then -- 747
		next = lo -- 749
	end -- 749
	if next > hi then -- 749
		next = hi -- 752
	end -- 752
	local delta = next - self.cartAxle -- 754
	if delta == 0 then -- 754
		return -- 756
	end -- 756
	self.cartAxle = next -- 758
	p.x = p.x + delta -- 759
	p.facing = dir > 0 and 1 or -1 -- 760
	self:slideX(p, 0) -- 761
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > CART_REACH then -- 761
		self.gripping = false -- 763
		self:flashSet("跟不上了，脱手", 0.6) -- 764
		return -- 765
	end -- 765
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 765
		self.cartDocked = true -- 768
		self.gripping = false -- 769
		self:flashSet("车轮落窝", 1.2) -- 770
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 770
		self:flashSet("车轮回到起点", 0.5) -- 772
	end -- 772
end -- 715
function Play.prototype.checkCarryGate(self) -- 780
	if self.room.key == "checkpoint" then -- 780
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 780
			self.carryCartAxle = self.cartAxle -- 783
			self.carryCartDocked = self.cartDocked -- 784
			self.wantRoom = "outside" -- 785
			self:flashSet("过城门 · 城外", 1.2) -- 786
		end -- 786
		return -- 788
	end -- 788
	if self.room.key == "outside" then -- 788
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 788
			self.carryCartAxle = self.cartAxle -- 794
			self.carryCartDocked = self.cartDocked -- 795
			self.wantRoom = "village" -- 796
			self:flashSet("墙根走完 · 进村口", 1.2) -- 797
		end -- 797
	end -- 797
end -- 780
function Play.prototype.shoot(self, a) -- 803
	local ox = a.x + a.facing * 8 -- 804
	local oy = a.y + a.h * 0.72 -- 805
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 807
	local dx = aim.x - ox -- 808
	local dy = aim.y - oy -- 809
	local len = math.sqrt(dx * dx + dy * dy) -- 810
	if len < 0.001 then -- 810
		dx = a.facing -- 812
		dy = 0 -- 813
	else -- 813
		dx = dx / len -- 815
		dy = dy / len -- 816
	end -- 816
	if dx ~= 0 then -- 816
		a.facing = dx > 0 and 1 or -1 -- 819
	end -- 819
	local hitEnemy = self:raycast( -- 822
		ox, -- 822
		oy, -- 822
		dx, -- 822
		dy, -- 822
		true -- 822
	) -- 822
	local hitWall = self:raycast( -- 823
		ox, -- 823
		oy, -- 823
		dx, -- 823
		dy, -- 823
		false -- 823
	) -- 823
	local tEnemy = hitEnemy.t -- 824
	local tWall = hitWall.t -- 825
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 826
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 827
	self.trace = { -- 829
		x0 = ox, -- 829
		y0 = oy, -- 829
		x1 = ox + dx * t, -- 829
		y1 = oy + dy * t, -- 829
		hit = hit -- 829
	} -- 829
	self.traceT = 0.12 -- 830
	self:applyFireDanger(ox) -- 831
	if hit then -- 831
		local i = hitEnemy.index -- 833
		local e = self.enemies[i + 1] -- 834
		e.alive = false -- 835
		e.hitT = 0.4 -- 836
		self:flashSet("命中", 0.6) -- 837
	else -- 837
		self:flashSet("打空", 0.35) -- 839
	end -- 839
end -- 803
function Play.prototype.applyFireDanger(self, shotX) -- 844
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 844
		return -- 846
	end -- 846
	local dangerX = shotX -- 848
	local best = -1 -- 849
	local bestD = 1000000000 -- 850
	local i = 0 -- 851
	do -- 851
		i = 0 -- 852
		while i < #self.enemies do -- 852
			do -- 852
				local e = self.enemies[i + 1] -- 853
				if not e.alive then -- 853
					goto __continue135 -- 855
				end -- 855
				local d = math.abs(e.x - self.partner.x) -- 857
				if d < bestD then -- 857
					bestD = d -- 859
					best = i -- 860
				end -- 860
			end -- 860
			::__continue135:: -- 860
			i = i + 1 -- 852
		end -- 852
	end -- 852
	if best >= 0 then -- 852
		dangerX = self.enemies[best + 1].x -- 864
	end -- 864
	local exposed = self:childExposed(dangerX) -- 866
	local before = self.escort.fear -- 867
	local after = self.escort:applyDanger(self.nextDangerId, exposed, self.partner.x) -- 868
	self.nextDangerId = self.nextDangerId + 1 -- 869
	if after > before then -- 869
		self:flashSet( -- 871
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 871
			1 -- 871
		) -- 871
	elseif not exposed then -- 871
		self:flashSet("枪声没够到她", 0.5) -- 873
	end -- 873
end -- 844
function Play.prototype.childExposed(self, dangerX) -- 878
	local c = self.partner -- 879
	if not c.alive then -- 879
		return false -- 881
	end -- 881
	if c.x > self.ox + 240 and c.x < self.ox + 340 then -- 881
		return false -- 884
	end -- 884
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 884
		return false -- 887
	end -- 887
	local toDanger = dangerX - c.x -- 889
	local toPlayer = self.player.x - c.x -- 890
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) then -- 890
		return false -- 892
	end -- 892
	return true -- 894
end -- 878
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 898
	local best = -1 -- 899
	local bestI = -1 -- 900
	local i = 0 -- 901
	if enemies then -- 901
		do -- 901
			i = 0 -- 903
			while i < #self.enemies do -- 903
				do -- 903
					local e = self.enemies[i + 1] -- 904
					if not e.alive then -- 904
						goto __continue149 -- 906
					end -- 906
					local t = hitBox( -- 908
						ox, -- 908
						oy, -- 908
						dx, -- 908
						dy, -- 908
						e.x - e.w / 2, -- 908
						e.x + e.w / 2, -- 908
						e.y, -- 908
						e.y + e.h -- 908
					) -- 908
					if t >= 0 and (best < 0 or t < best) then -- 908
						best = t -- 910
						bestI = i -- 911
					end -- 911
				end -- 911
				::__continue149:: -- 911
				i = i + 1 -- 903
			end -- 903
		end -- 903
		return {t = best, index = bestI} -- 914
	end -- 914
	do -- 914
		i = 0 -- 916
		while i < #self.boxes do -- 916
			local b = self.boxes[i + 1] -- 917
			local t = hitBox( -- 918
				ox, -- 918
				oy, -- 918
				dx, -- 918
				dy, -- 918
				b.x0, -- 918
				b.x1, -- 918
				b.y0, -- 918
				b.y1 -- 918
			) -- 918
			if t >= 0 and (best < 0 or t < best) then -- 918
				best = t -- 920
			end -- 920
			i = i + 1 -- 916
		end -- 916
	end -- 916
	if dy < 0 then -- 916
		local t = (0 - oy) / dy -- 925
		if t >= 0 and (best < 0 or t < best) then -- 925
			best = t -- 927
		end -- 927
	end -- 927
	return {t = best, index = -1} -- 930
end -- 898
function Play.prototype.slideX(self, a, dx) -- 934
	local nx = a.x + dx -- 935
	local half = a.w / 2 -- 936
	local room = self.room -- 937
	nx = math.max( -- 938
		room.minX + half, -- 938
		math.min(room.maxX - half, nx) -- 938
	) -- 938
	local i = 0 -- 939
	do -- 939
		i = 0 -- 940
		while i < #self.boxes do -- 940
			do -- 940
				local b = self.boxes[i + 1] -- 941
				if b.passable == true then -- 941
					goto __continue159 -- 943
				end -- 943
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 943
					goto __continue159 -- 946
				end -- 946
				if nx + half > b.x0 and nx - half < b.x1 then -- 946
					if a.x <= b.x0 then -- 946
						nx = b.x0 - half -- 950
					elseif a.x >= b.x1 then -- 950
						nx = b.x1 + half -- 952
					else -- 952
						nx = a.x -- 954
					end -- 954
				end -- 954
			end -- 954
			::__continue159:: -- 954
			i = i + 1 -- 940
		end -- 940
	end -- 940
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 940
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 962
		local bx0 = self.cartAxle - CART_HALF -- 963
		local bx1 = self.cartAxle + CART_HALF -- 964
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 964
			if a.x <= bx0 then -- 964
				nx = bx0 - half -- 967
			elseif a.x >= bx1 then -- 967
				nx = bx1 + half -- 969
			else -- 969
				nx = a.x -- 971
			end -- 971
		end -- 971
	end -- 971
	local arch = room.arch -- 979
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 979
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 981
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 981
			if a.x <= arch.x0 then -- 981
				nx = arch.x0 - half -- 984
			elseif a.x >= arch.x1 then -- 984
				nx = arch.x1 + half -- 986
			end -- 986
		end -- 986
	end -- 986
	a.x = nx -- 990
end -- 934
function Play.prototype.fallY(self, a, dt) -- 994
	a.vy = a.vy - GRAVITY * dt -- 995
	if a.vy < -900 then -- 995
		a.vy = -900 -- 997
	end -- 997
	local ny = a.y + a.vy * dt -- 999
	local half = a.w / 2 -- 1000
	if a.vy <= 0 then -- 1000
		local reach = a.onGround and STEP_UP or 0 -- 1003
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half) -- 1004
		if ny <= ground then -- 1004
			ny = ground -- 1006
			a.vy = 0 -- 1007
			a.onGround = true -- 1008
		else -- 1008
			a.onGround = false -- 1010
		end -- 1010
	else -- 1010
		a.onGround = false -- 1013
		local i = 0 -- 1014
		do -- 1014
			i = 0 -- 1015
			while i < #self.boxes do -- 1015
				do -- 1015
					local b = self.boxes[i + 1] -- 1016
					if b.passable == true then -- 1016
						goto __continue182 -- 1018
					end -- 1018
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 1018
						goto __continue182 -- 1021
					end -- 1021
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 1021
						ny = b.y0 - a.h -- 1024
						a.vy = 0 -- 1025
					end -- 1025
				end -- 1025
				::__continue182:: -- 1025
				i = i + 1 -- 1015
			end -- 1015
		end -- 1015
	end -- 1015
	a.y = ny -- 1029
end -- 994
function Play.prototype.groundAt(self, x, ceiling, half) -- 1033
	local g = -9999 -- 1034
	local i = 0 -- 1035
	do -- 1035
		i = 0 -- 1036
		while i < #self.floors do -- 1036
			local f = self.floors[i + 1] -- 1037
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 1037
				g = f.y1 -- 1039
			end -- 1039
			i = i + 1 -- 1036
		end -- 1036
	end -- 1036
	do -- 1036
		i = 0 -- 1042
		while i < #self.boxes do -- 1042
			local b = self.boxes[i + 1] -- 1043
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 1043
				g = b.y1 -- 1045
			end -- 1045
			i = i + 1 -- 1042
		end -- 1042
	end -- 1042
	return g -- 1048
end -- 1033
function Play.prototype.updateCamera(self, dt) -- 1051
	local p = self.player -- 1052
	local tx = p.x + p.facing * 30 -- 1053
	local ty = p.y + CAM_LOOK_UP -- 1054
	local k = math.min(1, CAM_FOLLOW * dt) -- 1055
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 1056
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 1057
end -- 1051
function Play.prototype.clampCamera(self, w, h) -- 1061
	local room = self.room -- 1062
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 1063
	local spanX = room.maxX - room.minX -- 1064
	if spanX <= halfW * 2 then -- 1064
		self.cam.x = (room.minX + room.maxX) / 2 -- 1066
	else -- 1066
		self.cam.x = math.max( -- 1068
			room.minX + halfW, -- 1068
			math.min(room.maxX - halfW, self.cam.x) -- 1068
		) -- 1068
	end -- 1068
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 1071
	local spanY = room.height -- 1072
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 1073
	if spanY <= halfH * 2 then -- 1073
		self.cam.y = camY -- 1075
	else -- 1075
		self.cam.y = math.max( -- 1077
			camY, -- 1077
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 1077
		) -- 1077
	end -- 1077
end -- 1061
function Play.prototype.flashSet(self, text, t) -- 1081
	self.flash = text -- 1082
	self.flashT = t -- 1083
end -- 1081
function Play.prototype.statusText(self) -- 1087
	local p = self.player -- 1088
	local parts = {} -- 1089
	if self.room.key == "village" then -- 1089
		parts[#parts + 1] = (("小满 x=" .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 1091
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1092
		if self.hasBottle then -- 1092
			parts[#parts + 1] = "有瓶" -- 1094
		elseif self.bottleFly ~= nil then -- 1094
			parts[#parts + 1] = "瓶在飞" -- 1096
		else -- 1096
			parts[#parts + 1] = "空手" -- 1098
		end -- 1098
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 1100
		if self.passed then -- 1100
			parts[#parts + 1] = "已过通行线" -- 1102
		end -- 1102
		if self.paused then -- 1102
			parts[#parts + 1] = "已暂停" -- 1105
		end -- 1105
		return table.concat(parts, " · ") -- 1107
	end -- 1107
	local isChild = self.room.key ~= "checkpoint" -- 1110
	local who = isChild and "小满" or "周戍" -- 1111
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 1112
	if isChild then -- 1112
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1114
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 1115
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1116
	else -- 1116
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 1118
		if p.rollT > 0 then -- 1118
			parts[#parts + 1] = "翻滚中" -- 1120
		end -- 1120
		local alive = 0 -- 1122
		local i = 0 -- 1123
		do -- 1123
			i = 0 -- 1124
			while i < #self.enemies do -- 1124
				if self.enemies[i + 1].alive then -- 1124
					alive = alive + 1 -- 1126
				end -- 1126
				i = i + 1 -- 1124
			end -- 1124
		end -- 1124
		parts[#parts + 1] = (("敌 " .. tostring(alive)) .. "/") .. tostring(#self.enemies) -- 1129
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1130
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 1131
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 1132
	end -- 1132
	if self.checkpoint >= 0 then -- 1132
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 1135
	end -- 1135
	if self.paused then -- 1135
		parts[#parts + 1] = "已暂停" -- 1138
	end -- 1138
	return table.concat(parts, " · ") -- 1140
end -- 1087
function Play.prototype.scavLabel(self) -- 1144
	if self.scavState == "turn" then -- 1144
		return "转头" -- 1146
	end -- 1146
	if self.scavState == "walk" then -- 1146
		return "赶来" -- 1149
	end -- 1149
	if self.scavState == "stall" then -- 1149
		return "停住" -- 1152
	end -- 1152
	if self.scavState == "back" then -- 1152
		return "回位" -- 1155
	end -- 1155
	return "巡逻" -- 1157
end -- 1144
function Play.prototype.hintText(self) -- 1161
	if self.paused then -- 1161
		return "Esc 继续 · R 重置" -- 1163
	end -- 1163
	if self.flash ~= "" then -- 1163
		return self.flash -- 1166
	end -- 1166
	if self.room.key == "village" then -- 1166
		if self.bottleFly ~= nil then -- 1166
			return "等瓶子落地 · 触地才发声" -- 1170
		end -- 1170
		if self.hasBottle then -- 1170
			return "按住 F 瞄，松手投 · 往右投到砖地 608，他才会走开" -- 1173
		end -- 1173
		if self.passed then -- 1173
			return "已过第一院 · R 重置可再来一遍" -- 1176
		end -- 1176
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 1178
	end -- 1178
	if self.room.key == "outside" then -- 1178
		if self.focusCart then -- 1178
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 1182
		end -- 1182
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 1184
	end -- 1184
	if self.escort.state == "frozen" then -- 1184
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 1184
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 1188
		end -- 1188
		return "小满吓住了 · 走过去，靠近再点 E" -- 1190
	end -- 1190
	if self.escort.state == "calming" then -- 1190
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 1193
	end -- 1193
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 1195
end -- 1161
function Play.prototype.draw(self, draw, w, h) -- 1200
	self.viewW = w -- 1201
	self.viewH = h -- 1202
	self.view = ____exports.computeViewport(w, h) -- 1203
	self:clampCamera(w, h) -- 1204
	draw:clear() -- 1205
	draw:drawRect( -- 1207
		Rect(0, 0, w, h), -- 1207
		BG_VOID -- 1207
	) -- 1207
	local box = self:canvasRect(w, h) -- 1208
	draw:drawRect(box, BG_FAR) -- 1209
	draw:drawRect( -- 1210
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 1210
		BG_MID -- 1210
	) -- 1210
	self:drawFloors(draw, w, h) -- 1212
	self:drawSolids(draw, w, h) -- 1213
	self:drawZones(draw, w, h) -- 1214
	self:drawArch(draw, w, h) -- 1215
	self:drawCart(draw, w, h) -- 1216
	self:drawActors(draw, w, h) -- 1217
	self:drawTrace(draw, w, h) -- 1218
	self:drawAim(draw, w, h) -- 1219
end -- 1200
function Play.prototype.canvasRect(self, w, h) -- 1223
	local v = self.view -- 1224
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 1225
end -- 1223
function Play.prototype.px(self, n) -- 1229
	return n * self.view.zoom -- 1230
end -- 1229
function Play.prototype.sx(self, wx, w) -- 1234
	local v = self.view -- 1235
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 1236
	return v.ox + lx * v.zoom -- 1237
end -- 1234
function Play.prototype.sy(self, wy, h) -- 1241
	local v = self.view -- 1242
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 1243
	return v.oy + ly * v.zoom -- 1244
end -- 1241
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 1247
	local px0 = self:sx(x0, w) -- 1248
	local px1 = self:sx(x1, w) -- 1249
	local py0 = self:sy(y0, h) -- 1250
	local py1 = self:sy(y1, h) -- 1251
	if px1 <= px0 or py1 <= py0 then -- 1251
		return -- 1253
	end -- 1253
	draw:drawRect( -- 1255
		Rect(px0, py0, px1 - px0, py1 - py0), -- 1255
		color -- 1255
	) -- 1255
end -- 1247
function Play.prototype.drawFloors(self, draw, w, h) -- 1258
	local i = 0 -- 1259
	do -- 1259
		i = 0 -- 1260
		while i < #self.room.floors do -- 1260
			local f = self.room.floors[i + 1] -- 1261
			local y = self:sy(f.y, h) -- 1262
			local x0 = self:sx(f.x0, w) -- 1263
			local x1 = self:sx(f.x1, w) -- 1264
			local deck = self:px(5) -- 1265
			draw:drawRect( -- 1266
				Rect(x0, y - deck, x1 - x0, deck), -- 1266
				FLOOR_DECK -- 1266
			) -- 1266
			draw:drawSegment( -- 1267
				Vec2(x0, y), -- 1267
				Vec2(x1, y), -- 1267
				self:px(1), -- 1267
				GROUND -- 1267
			) -- 1267
			i = i + 1 -- 1260
		end -- 1260
	end -- 1260
end -- 1258
function Play.prototype.drawSolids(self, draw, w, h) -- 1271
	local i = 0 -- 1272
	do -- 1272
		i = 0 -- 1273
		while i < #self.boxes do -- 1273
			do -- 1273
				local b = self.boxes[i + 1] -- 1274
				if b.y0 < -4 and b.y1 <= 96 then -- 1274
					draw:drawSegment( -- 1277
						Vec2( -- 1277
							self:sx(b.x0, w), -- 1277
							self:sy(b.y1, h) -- 1277
						), -- 1277
						Vec2( -- 1277
							self:sx(b.x1, w), -- 1277
							self:sy(b.y1, h) -- 1277
						), -- 1277
						self:px(1), -- 1277
						GROUND -- 1277
					) -- 1277
					goto __continue244 -- 1278
				end -- 1278
				self:drawBox( -- 1280
					draw, -- 1280
					w, -- 1280
					h, -- 1280
					b.x0, -- 1280
					b.x1, -- 1280
					b.y0, -- 1280
					b.y1, -- 1280
					SOLID_FILL -- 1280
				) -- 1280
				draw:drawSegment( -- 1281
					Vec2( -- 1281
						self:sx(b.x0, w), -- 1281
						self:sy(b.y1, h) -- 1281
					), -- 1281
					Vec2( -- 1281
						self:sx(b.x1, w), -- 1281
						self:sy(b.y1, h) -- 1281
					), -- 1281
					self:px(1), -- 1281
					SOLID_EDGE -- 1281
				) -- 1281
			end -- 1281
			::__continue244:: -- 1281
			i = i + 1 -- 1273
		end -- 1273
	end -- 1273
end -- 1271
function Play.prototype.drawZones(self, draw, w, h) -- 1285
	local i = 0 -- 1286
	do -- 1286
		i = 0 -- 1287
		while i < #self.room.zones do -- 1287
			local z = self.room.zones[i + 1] -- 1288
			local fill = DANGER -- 1289
			local line = DANGER_LINE -- 1290
			if z.tint == 2 then -- 1290
				fill = SOFT -- 1292
				line = SOFT_LINE -- 1293
			elseif z.tint == 3 then -- 1293
				fill = BRICK -- 1295
				line = BRICK_LINE -- 1296
			elseif z.tint == 4 then -- 1296
				fill = PASS -- 1298
				line = PASS_LINE -- 1299
			end -- 1299
			self:drawBox( -- 1301
				draw, -- 1301
				w, -- 1301
				h, -- 1301
				z.x0, -- 1301
				z.x1, -- 1301
				z.y, -- 1301
				z.y + z.h, -- 1301
				fill -- 1301
			) -- 1301
			draw:drawSegment( -- 1302
				Vec2( -- 1302
					self:sx(z.x0, w), -- 1302
					self:sy(z.y, h) -- 1302
				), -- 1302
				Vec2( -- 1302
					self:sx(z.x0, w), -- 1302
					self:sy(z.y + z.h, h) -- 1302
				), -- 1302
				self:px(1), -- 1302
				line -- 1302
			) -- 1302
			draw:drawSegment( -- 1303
				Vec2( -- 1303
					self:sx(z.x1, w), -- 1303
					self:sy(z.y, h) -- 1303
				), -- 1303
				Vec2( -- 1303
					self:sx(z.x1, w), -- 1303
					self:sy(z.y + z.h, h) -- 1303
				), -- 1303
				self:px(1), -- 1303
				line -- 1303
			) -- 1303
			i = i + 1 -- 1287
		end -- 1287
	end -- 1287
end -- 1285
function Play.prototype.drawArch(self, draw, w, h) -- 1307
	local a = self.room.arch -- 1308
	if a.h <= 0 then -- 1308
		return -- 1310
	end -- 1310
	self:drawBox( -- 1312
		draw, -- 1312
		w, -- 1312
		h, -- 1312
		a.x0, -- 1312
		a.x1, -- 1312
		a.y, -- 1312
		a.y + a.h, -- 1312
		HOLE_FILL -- 1312
	) -- 1312
	draw:drawSegment( -- 1313
		Vec2( -- 1313
			self:sx(a.x0, w), -- 1313
			self:sy(a.y + a.h, h) -- 1313
		), -- 1313
		Vec2( -- 1313
			self:sx(a.x1, w), -- 1313
			self:sy(a.y + a.h, h) -- 1313
		), -- 1313
		self:px(1), -- 1313
		SOLID_EDGE -- 1313
	) -- 1313
	draw:drawSegment( -- 1314
		Vec2( -- 1314
			self:sx(a.x0, w), -- 1314
			self:sy(a.y, h) -- 1314
		), -- 1314
		Vec2( -- 1314
			self:sx(a.x0, w), -- 1314
			self:sy(a.y + a.h, h) -- 1314
		), -- 1314
		self:px(1), -- 1314
		SOLID_EDGE -- 1314
	) -- 1314
	draw:drawSegment( -- 1315
		Vec2( -- 1315
			self:sx(a.x1, w), -- 1315
			self:sy(a.y, h) -- 1315
		), -- 1315
		Vec2( -- 1315
			self:sx(a.x1, w), -- 1315
			self:sy(a.y + a.h, h) -- 1315
		), -- 1315
		self:px(1), -- 1315
		SOLID_EDGE -- 1315
	) -- 1315
end -- 1307
function Play.prototype.drawCart(self, draw, w, h) -- 1318
	local c = self.room.cart -- 1319
	if c.bodyW <= 0 then -- 1319
		return -- 1321
	end -- 1321
	drawCartShape( -- 1323
		draw, -- 1323
		self, -- 1323
		w, -- 1323
		h, -- 1323
		c, -- 1323
		self.cartAxle -- 1323
	) -- 1323
	draw:drawRect( -- 1324
		Rect( -- 1324
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 1324
			self:sy(c.baseY + 40, h), -- 1324
			self:px(2), -- 1324
			self:px(40) -- 1324
		), -- 1324
		STAND -- 1324
	) -- 1324
end -- 1318
function Play.prototype.drawActors(self, draw, w, h) -- 1327
	local p = self.player -- 1328
	local isChild = self.room.key ~= "checkpoint" -- 1329
	drawFigure( -- 1330
		draw, -- 1330
		self, -- 1330
		w, -- 1330
		h, -- 1330
		p, -- 1330
		isChild and CHILD_BODY or SOLDIER_BODY, -- 1330
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 1330
	) -- 1330
	local q = self.partner -- 1331
	if q.alive then -- 1331
		local childPartner = q.w == CHILD_W -- 1333
		drawFigure( -- 1334
			draw, -- 1334
			self, -- 1334
			w, -- 1334
			h, -- 1334
			q, -- 1334
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 1334
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 1334
		) -- 1334
	end -- 1334
	local i = 0 -- 1336
	do -- 1336
		i = 0 -- 1337
		while i < #self.enemies do -- 1337
			local e = self.enemies[i + 1] -- 1338
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 1339
			self:drawBox( -- 1340
				draw, -- 1340
				w, -- 1340
				h, -- 1340
				e.x - e.w / 2, -- 1340
				e.x + e.w / 2, -- 1340
				e.y, -- 1340
				e.y + e.h, -- 1340
				col -- 1340
			) -- 1340
			i = i + 1 -- 1337
		end -- 1337
	end -- 1337
	local k = 0 -- 1343
	do -- 1343
		k = 0 -- 1344
		while k < #self.room.marks do -- 1344
			do -- 1344
				local m = self.room.marks[k + 1] -- 1345
				if m.kind ~= 0 then -- 1345
					goto __continue261 -- 1347
				end -- 1347
				local on = self.checkpoint == m.x -- 1349
				local x = self:sx(m.x, w) -- 1350
				local y = self:sy(m.y, h) -- 1351
				draw:drawSegment( -- 1352
					Vec2(x, y), -- 1352
					Vec2( -- 1352
						x, -- 1352
						y + self:px(35) -- 1352
					), -- 1352
					self:px(1), -- 1352
					on and CHECK or INK_DIM -- 1352
				) -- 1352
				draw:drawDot( -- 1353
					Vec2( -- 1353
						x, -- 1353
						y + self:px(35) -- 1353
					), -- 1353
					self:px(2), -- 1353
					on and CHECK or INK_DIM -- 1353
				) -- 1353
			end -- 1353
			::__continue261:: -- 1353
			k = k + 1 -- 1344
		end -- 1344
	end -- 1344
	local j = 0 -- 1357
	do -- 1357
		j = 0 -- 1358
		while j < #self.room.marks do -- 1358
			do -- 1358
				local m = self.room.marks[j + 1] -- 1359
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 1359
					goto __continue264 -- 1361
				end -- 1361
				if m.kind == 1 and self.room.key ~= "checkpoint" then -- 1361
					goto __continue264 -- 1364
				end -- 1364
				local col = STAND -- 1366
				if m.kind == 4 then -- 1366
					col = PASS_LINE -- 1368
				elseif m.kind == 5 then -- 1368
					col = BRICK_LINE -- 1370
				end -- 1370
				local mx = self:sx(m.x, w) -- 1372
				local my = self:sy(m.y, h) -- 1373
				draw:drawSegment( -- 1374
					Vec2(mx, my), -- 1374
					Vec2( -- 1374
						mx, -- 1374
						my + self:px(24) -- 1374
					), -- 1374
					self:px(1), -- 1374
					col -- 1374
				) -- 1374
			end -- 1374
			::__continue264:: -- 1374
			j = j + 1 -- 1358
		end -- 1358
	end -- 1358
	local t = 0 -- 1377
	do -- 1377
		t = 0 -- 1378
		while t < #self.room.marks do -- 1378
			do -- 1378
				local m = self.room.marks[t + 1] -- 1379
				if m.kind ~= 6 then -- 1379
					goto __continue270 -- 1381
				end -- 1381
				local mx = self:sx(m.x, w) -- 1383
				local my = self:sy(m.y, h) -- 1384
				draw:drawSegment( -- 1385
					Vec2(mx, my), -- 1385
					Vec2( -- 1385
						mx, -- 1385
						my + self:px(30) -- 1385
					), -- 1385
					self:px(1), -- 1385
					INK_DIM -- 1385
				) -- 1385
				self:drawBox( -- 1386
					draw, -- 1386
					w, -- 1386
					h, -- 1386
					m.x - 5, -- 1386
					m.x + 5, -- 1386
					m.y + 30, -- 1386
					m.y + 40, -- 1386
					CHECK -- 1386
				) -- 1386
			end -- 1386
			::__continue270:: -- 1386
			t = t + 1 -- 1378
		end -- 1378
	end -- 1378
	if self.room.key == "village" then -- 1378
		self:drawVillage(draw, w, h) -- 1389
	end -- 1389
end -- 1327
function Play.prototype.drawVillage(self, draw, w, h) -- 1394
	local bottle = self.room.bottle -- 1395
	if bottle ~= nil then -- 1395
		self:drawBox( -- 1397
			draw, -- 1397
			w, -- 1397
			h, -- 1397
			bottle.x - 14, -- 1397
			bottle.x + 14, -- 1397
			0, -- 1397
			64, -- 1397
			SOLID_FILL -- 1397
		) -- 1397
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 1397
			self:drawBottle( -- 1399
				draw, -- 1399
				w, -- 1399
				h, -- 1399
				bottle.x, -- 1399
				64 -- 1399
			) -- 1399
		end -- 1399
	end -- 1399
	self:drawBox( -- 1403
		draw, -- 1403
		w, -- 1403
		h, -- 1403
		300, -- 1403
		420, -- 1403
		44, -- 1403
		50, -- 1403
		FLOOR_DECK -- 1403
	) -- 1403
	self:drawBox( -- 1404
		draw, -- 1404
		w, -- 1404
		h, -- 1404
		300, -- 1404
		306, -- 1404
		0, -- 1404
		44, -- 1404
		FLOOR_DECK -- 1404
	) -- 1404
	self:drawBox( -- 1405
		draw, -- 1405
		w, -- 1405
		h, -- 1405
		414, -- 1405
		420, -- 1405
		0, -- 1405
		44, -- 1405
		FLOOR_DECK -- 1405
	) -- 1405
	local s = self.room.scavenger -- 1407
	if s ~= nil then -- 1407
		local sx0 = self.scavX -- 1409
		self:drawBox( -- 1410
			draw, -- 1410
			w, -- 1410
			h, -- 1410
			sx0 - 12, -- 1410
			sx0 + 12, -- 1410
			0, -- 1410
			s.h - 14, -- 1410
			SCAV_BODY -- 1410
		) -- 1410
		self:drawBox( -- 1411
			draw, -- 1411
			w, -- 1411
			h, -- 1411
			sx0 - 7, -- 1411
			sx0 + 7, -- 1411
			s.h - 14, -- 1411
			s.h, -- 1411
			SCAV_HEAD -- 1411
		) -- 1411
		if self.scavState == "turn" then -- 1411
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 1413
			draw:drawSegment( -- 1414
				Vec2( -- 1414
					self:sx(sx0, w), -- 1414
					self:sy(s.h - 6, h) -- 1414
				), -- 1414
				Vec2( -- 1414
					self:sx(fx, w), -- 1414
					self:sy(s.h - 6, h) -- 1414
				), -- 1414
				self:px(1), -- 1414
				INK -- 1414
			) -- 1414
		end -- 1414
	end -- 1414
	if self.hasBottle then -- 1414
		local p = self.player -- 1419
		self:drawBottle( -- 1420
			draw, -- 1420
			w, -- 1420
			h, -- 1420
			p.x + p.facing * 10, -- 1420
			p.y + p.h * 0.62 -- 1420
		) -- 1420
	end -- 1420
	if self.bottleFly ~= nil then -- 1420
		self:drawBottle( -- 1423
			draw, -- 1423
			w, -- 1423
			h, -- 1423
			self.bottleFly.x, -- 1423
			self.bottleFly.y -- 1423
		) -- 1423
	end -- 1423
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 1423
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 1426
		draw:drawCircle( -- 1427
			Vec2( -- 1427
				self:sx(self.bottleLandX, w), -- 1427
				self:sy(0, h) -- 1427
			), -- 1427
			self:px(r / ____exports.UNITS_PER_PX), -- 1427
			BRICK_LINE -- 1427
		) -- 1427
	end -- 1427
end -- 1394
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 1431
	self:drawBox( -- 1432
		draw, -- 1432
		w, -- 1432
		h, -- 1432
		x - 3, -- 1432
		x + 3, -- 1432
		y - 10, -- 1432
		y, -- 1432
		BOTTLE -- 1432
	) -- 1432
end -- 1431
function Play.prototype.drawTrace(self, draw, w, h) -- 1435
	local t = self.trace -- 1436
	if t == nil or self.traceT <= 0 then -- 1436
		return -- 1438
	end -- 1438
	draw:drawSegment( -- 1440
		Vec2( -- 1441
			self:sx(t.x0, w), -- 1441
			self:sy(t.y0, h) -- 1441
		), -- 1441
		Vec2( -- 1442
			self:sx(t.x1, w), -- 1442
			self:sy(t.y1, h) -- 1442
		), -- 1442
		self:px(1), -- 1443
		t.hit and AIM_HIT or INK_DIM -- 1443
	) -- 1443
end -- 1435
function Play.prototype.drawAim(self, draw, w, h) -- 1446
	local v = self.view -- 1448
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 1449
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 1450
	local dot = self:px(1) -- 1451
	local arm = self:px(3) -- 1452
	local gap = self:px(1) -- 1453
	draw:drawSegment( -- 1454
		Vec2(gx - arm - gap, gy), -- 1454
		Vec2(gx - gap, gy), -- 1454
		dot / 2, -- 1454
		AIM -- 1454
	) -- 1454
	draw:drawSegment( -- 1455
		Vec2(gx + gap, gy), -- 1455
		Vec2(gx + arm + gap, gy), -- 1455
		dot / 2, -- 1455
		AIM -- 1455
	) -- 1455
	draw:drawSegment( -- 1456
		Vec2(gx, gy - arm - gap), -- 1456
		Vec2(gx, gy - gap), -- 1456
		dot / 2, -- 1456
		AIM -- 1456
	) -- 1456
	draw:drawSegment( -- 1457
		Vec2(gx, gy + gap), -- 1457
		Vec2(gx, gy + arm + gap), -- 1457
		dot / 2, -- 1457
		AIM -- 1457
	) -- 1457
	if self.room.key == "village" and self.hasBottle then -- 1457
		local p = self.player -- 1461
		local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1462
		local x0 = p.x + p.facing * 10 -- 1463
		local y0 = p.y + p.h * 0.7 -- 1464
		local T = 0.62 -- 1465
		local vx = (aim.x - x0) / T -- 1466
		local vy = (aim.y - y0 + 0.5 * GRAVITY * T * T) / T -- 1467
		local pxr = x0 -- 1468
		local pyr = y0 -- 1469
		local t = 1 -- 1470
		do -- 1470
			t = 1 -- 1471
			while t <= 12 do -- 1471
				local tt = t / 12 * T -- 1472
				local nx = x0 + vx * tt -- 1473
				local ny = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 1474
				draw:drawSegment( -- 1475
					Vec2( -- 1475
						self:sx(pxr, w), -- 1475
						self:sy(pyr, h) -- 1475
					), -- 1475
					Vec2( -- 1475
						self:sx(nx, w), -- 1475
						self:sy(ny, h) -- 1475
					), -- 1475
					self:px(1) / 2, -- 1475
					BOTTLE -- 1475
				) -- 1475
				pxr = nx -- 1476
				pyr = ny -- 1477
				t = t + 1 -- 1471
			end -- 1471
		end -- 1471
	end -- 1471
end -- 1446
return ____exports -- 1446