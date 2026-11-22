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
local ____clock = require("Script.watch.clock") -- 15
local STEP = ____clock.STEP -- 15
local ____escort = require("Script.watch.escort") -- 16
local CALM_REACH = ____escort.CALM_REACH -- 16
local Escort = ____escort.Escort -- 16
local FEAR_MAX = ____escort.FEAR_MAX -- 16
local safeAnchorX = ____escort.safeAnchorX -- 16
function makeActor(room, index) -- 1456
	local sp = room.spawns -- 1457
	if index < 0 or index >= #sp then -- 1457
		return { -- 1459
			x = 0, -- 1459
			y = 0, -- 1459
			vx = 0, -- 1459
			vy = 0, -- 1459
			w = CHILD_W, -- 1459
			h = CHILD_H, -- 1459
			onGround = true, -- 1459
			facing = 1, -- 1459
			crouch = false, -- 1459
			rollT = 0, -- 1459
			covered = false, -- 1459
			alive = false -- 1459
		} -- 1459
	end -- 1459
	local s = sp[index + 1] -- 1461
	local child = s.h <= CHILD_H -- 1462
	return { -- 1463
		x = s.x, -- 1464
		y = s.y, -- 1464
		vx = 0, -- 1464
		vy = 0, -- 1464
		w = child and CHILD_W or SOLDIER_W, -- 1465
		h = child and CHILD_H or SOLDIER_H, -- 1466
		onGround = true, -- 1467
		facing = 1, -- 1467
		crouch = false, -- 1467
		rollT = 0, -- 1467
		covered = false, -- 1467
		alive = true -- 1467
	} -- 1467
end -- 1467
function drawFigure(draw, play, w, h, a, body, head) -- 1471
	if not a.alive then -- 1471
		return -- 1473
	end -- 1473
	local x0 = a.x - a.w / 2 -- 1475
	local x1 = a.x + a.w / 2 -- 1476
	local y0 = a.y -- 1477
	local y1 = a.y + a.h -- 1478
	play:drawBox( -- 1479
		draw, -- 1479
		w, -- 1479
		h, -- 1479
		x0, -- 1479
		x1, -- 1479
		y0, -- 1479
		y1 - a.h * 0.26, -- 1479
		body -- 1479
	) -- 1479
	play:drawBox( -- 1480
		draw, -- 1480
		w, -- 1480
		h, -- 1480
		x0 + 2, -- 1480
		x1 - 2, -- 1480
		y1 - a.h * 0.26, -- 1480
		y1, -- 1480
		head -- 1480
	) -- 1480
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 1482
	play:drawBox( -- 1483
		draw, -- 1483
		w, -- 1483
		h, -- 1483
		eyeX, -- 1483
		eyeX + 4, -- 1483
		y1 - a.h * 0.14, -- 1483
		y1 - a.h * 0.08, -- 1483
		INK -- 1483
	) -- 1483
end -- 1483
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 1487
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 1488
end -- 1487
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 1495
	local tmin = 0 -- 1496
	local tmax = 99999 -- 1497
	if dx == 0 then -- 1497
		if ox < x0 or ox > x1 then -- 1497
			return -1 -- 1500
		end -- 1500
	else -- 1500
		local t1 = (x0 - ox) / dx -- 1503
		local t2 = (x1 - ox) / dx -- 1504
		local lo = t1 < t2 and t1 or t2 -- 1505
		local hi = t1 < t2 and t2 or t1 -- 1506
		if lo > tmin then -- 1506
			tmin = lo -- 1508
		end -- 1508
		if hi < tmax then -- 1508
			tmax = hi -- 1511
		end -- 1511
	end -- 1511
	if dy == 0 then -- 1511
		if oy < y0 or oy > y1 then -- 1511
			return -1 -- 1516
		end -- 1516
	else -- 1516
		local t1 = (y0 - oy) / dy -- 1519
		local t2 = (y1 - oy) / dy -- 1520
		local lo = t1 < t2 and t1 or t2 -- 1521
		local hi = t1 < t2 and t2 or t1 -- 1522
		if lo > tmin then -- 1522
			tmin = lo -- 1524
		end -- 1524
		if hi < tmax then -- 1524
			tmax = hi -- 1527
		end -- 1527
	end -- 1527
	return tmax >= tmin and tmin or -1 -- 1530
end -- 1530
function drawCartShape(draw, play, w, h, c, axleX) -- 1533
	local half = c.bodyW / 2 -- 1534
	local x0 = axleX - half -- 1535
	local x1 = axleX + half -- 1536
	play:drawBox( -- 1537
		draw, -- 1537
		w, -- 1537
		h, -- 1537
		x0, -- 1537
		x1, -- 1537
		c.baseY + c.wheelR, -- 1537
		c.baseY + c.wheelR + c.bodyH, -- 1537
		CART_FILL -- 1537
	) -- 1537
	draw:drawCircle( -- 1538
		Vec2( -- 1538
			play:sx(x0 + c.bodyW * 0.28, w), -- 1538
			play:sy(c.baseY + c.wheelR, h) -- 1538
		), -- 1538
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 1538
		Color(52, 50, 48, 255) -- 1538
	) -- 1538
	draw:drawCircle( -- 1539
		Vec2( -- 1539
			play:sx(x1 - c.bodyW * 0.28, w), -- 1539
			play:sy(c.baseY + c.wheelR, h) -- 1539
		), -- 1539
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 1539
		Color(52, 50, 48, 255) -- 1539
	) -- 1539
	local cx = c.clothSide < 0 and x0 or x1 -- 1540
	play:drawBox( -- 1541
		draw, -- 1541
		w, -- 1541
		h, -- 1541
		cx - 10, -- 1541
		cx + 10, -- 1541
		c.baseY + c.wheelR + c.bodyH, -- 1541
		c.baseY + c.wheelR + c.bodyH + 18, -- 1541
		CLOTH -- 1541
	) -- 1541
end -- 1541
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
INK = Color(232, 232, 228, 255) -- 57
local INK_DIM = Color(150, 152, 150, 255) -- 58
local BG_VOID = Color(8, 9, 10, 255) -- 59
local BG_FAR = Color(24, 26, 28, 255) -- 60
local BG_MID = Color(31, 34, 37, 255) -- 61
local GROUND = Color(112, 114, 112, 255) -- 62
local FLOOR_DECK = Color(66, 70, 72, 255) -- 63
local SOLID_FILL = Color(84, 86, 84, 255) -- 64
local SOLID_EDGE = Color(126, 130, 126, 255) -- 65
CART_FILL = Color(122, 78, 56, 255) -- 66
CLOTH = Color(178, 52, 46, 255) -- 67
local DANGER = Color(150, 54, 48, 46) -- 68
local DANGER_LINE = Color(178, 78, 64, 200) -- 69
local HOLE_FILL = Color(10, 11, 12, 255) -- 70
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 71
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 72
local CHILD_BODY = Color(214, 168, 96, 255) -- 73
local CHILD_HEAD = Color(232, 214, 186, 255) -- 74
local ENEMY_BODY = Color(176, 92, 84, 255) -- 75
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 76
local CHECK = Color(96, 186, 122, 255) -- 77
local STAND = Color(226, 186, 84, 255) -- 78
local AIM = Color(236, 236, 232, 230) -- 79
local AIM_HIT = Color(236, 96, 84, 255) -- 80
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 82
local SOFT_LINE = Color(140, 112, 80, 190) -- 83
local BRICK = Color(126, 118, 110, 70) -- 84
local BRICK_LINE = Color(160, 152, 142, 200) -- 85
local PASS = Color(96, 186, 122, 40) -- 86
local PASS_LINE = Color(96, 186, 122, 200) -- 87
local BOTTLE = Color(120, 186, 160, 255) -- 88
local SCAV_BODY = Color(128, 118, 96, 255) -- 89
local SCAV_HEAD = Color(196, 182, 158, 255) -- 90
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 139
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 140
	if zoom < 1 then -- 140
		zoom = 1 -- 142
	end -- 142
	return { -- 144
		zoom = zoom, -- 145
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 146
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 147
	} -- 147
end -- 139
____exports.Play = __TS__Class() -- 160
local Play = ____exports.Play -- 160
Play.name = "Play" -- 160
function Play.prototype.____constructor(self, room, resume) -- 233
	self.enemies = {} -- 165
	self.boxes = {} -- 166
	self.floors = {} -- 167
	self.checkpoint = -1 -- 169
	self.flash = "" -- 171
	self.flashT = 0 -- 172
	self.traceT = 0 -- 175
	self.focusCart = false -- 177
	self.knocks = 0 -- 179
	self.knockT = 0 -- 180
	self.cartAxle = 0 -- 184
	self.cartDocked = false -- 186
	self.gripping = false -- 188
	self.gateOpen = false -- 190
	self.calmConsumed = false -- 192
	self.nextDangerId = 1 -- 194
	self.wantRoom = "" -- 196
	self.carryCartAxle = -1 -- 198
	self.carryCartDocked = false -- 199
	self.checkpointCartAxle = -1 -- 201
	self.hasBottle = false -- 205
	self.bottleLandX = -1 -- 209
	self.bottleLandT = 0 -- 210
	self.aimHold = 0 -- 212
	self.scavX = 0 -- 214
	self.scavDir = 1 -- 215
	self.scavState = "patrol" -- 216
	self.scavT = 0 -- 217
	self.scavTargetX = 0 -- 218
	self.passed = false -- 220
	self.paused = false -- 221
	self.ticks = 0 -- 223
	self.view = {zoom = 1, ox = 0, oy = 0} -- 225
	self.aimX = 0 -- 227
	self.aimY = 0 -- 228
	self.viewW = 0 -- 230
	self.viewH = 0 -- 231
	self.room = room -- 234
	self.cam = {x = (room.minX + room.maxX) / 2, y = room.height / 2} -- 235
	self:buildWorld() -- 236
	self.player = makeActor(room, room.key == "checkpoint" and 1 or 0) -- 237
	self.partner = makeActor(room, room.key == "checkpoint" and 0 or -1) -- 238
	self.cam.x = self.player.x -- 239
	self.cam.y = self.player.y + CAM_LOOK_UP -- 240
	self.cartAxle = room.cart.startX -- 241
	self.escort = __TS__New( -- 242
		Escort, -- 242
		safeAnchorX(room.marks) -- 242
	) -- 242
	self.scavX = room.scavenger ~= nil and room.scavenger.x0 or 0 -- 243
	self:buildEnemies() -- 244
	if resume ~= nil and resume.checkpoint > 0 then -- 244
		self.checkpoint = resume.checkpoint -- 247
		if room.key == "outside" and resume.checkpoint >= 380 then -- 247
			self.cartAxle = room.cart.endX -- 249
			self.cartDocked = true -- 250
			self.player.x = 380 -- 253
			self.player.y = 0 -- 254
			self.player.vy = 0 -- 255
			self.player.onGround = true -- 256
			self.cam.x = self.player.x -- 257
			self.cam.y = self.player.y + CAM_LOOK_UP -- 258
		end -- 258
	end -- 258
end -- 233
function Play.prototype.buildWorld(self) -- 264
	local room = self.room -- 265
	self.boxes = {} -- 266
	self.floors = {} -- 267
	local i = 0 -- 268
	do -- 268
		i = 0 -- 269
		while i < #room.floors do -- 269
			local f = room.floors[i + 1] -- 270
			local ____self_floors_0 = self.floors -- 270
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 271
			i = i + 1 -- 269
		end -- 269
	end -- 269
	do -- 269
		i = 0 -- 273
		while i < #room.solids do -- 273
			local s = room.solids[i + 1] -- 274
			local ____self_boxes_1 = self.boxes -- 274
			____self_boxes_1[#____self_boxes_1 + 1] = {x0 = s.x, x1 = s.x + s.w, y0 = s.y, y1 = s.y + s.h} -- 275
			i = i + 1 -- 273
		end -- 273
	end -- 273
	do -- 273
		i = 0 -- 277
		while i < #room.stairs do -- 277
			local st = room.stairs[i + 1] -- 278
			local n = st.steps + 1 -- 279
			local stepW = (st.x1 - st.x0) / n -- 280
			local k = 0 -- 281
			do -- 281
				k = 0 -- 282
				while k < n do -- 282
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 283
					local x0 = st.x0 + stepW * k -- 284
					local ____self_boxes_2 = self.boxes -- 284
					____self_boxes_2[#____self_boxes_2 + 1] = { -- 286
						x0 = x0, -- 286
						x1 = x0 + stepW, -- 286
						y0 = -8, -- 286
						y1 = y, -- 286
						passable = true -- 286
					} -- 286
					k = k + 1 -- 282
				end -- 282
			end -- 282
			i = i + 1 -- 277
		end -- 277
	end -- 277
end -- 264
function Play.prototype.buildEnemies(self) -- 291
	self.enemies = {} -- 292
	if self.room.key ~= "checkpoint" then -- 292
		return -- 294
	end -- 294
	local ____self_enemies_3 = self.enemies -- 294
	____self_enemies_3[#____self_enemies_3 + 1] = { -- 296
		x = 430, -- 296
		y = 0, -- 296
		w = 26, -- 296
		h = 84, -- 296
		alive = true, -- 296
		hitT = 0 -- 296
	} -- 296
	local ____self_enemies_4 = self.enemies -- 296
	____self_enemies_4[#____self_enemies_4 + 1] = { -- 297
		x = 505, -- 297
		y = 0, -- 297
		w = 26, -- 297
		h = 84, -- 297
		alive = true, -- 297
		hitT = 0 -- 297
	} -- 297
end -- 291
function Play.prototype.update(self, dt, input) -- 301
	if input.pause.pressed then -- 301
		self.paused = not self.paused -- 303
	end -- 303
	if self.flashT > 0 then -- 303
		self.flashT = self.flashT - dt -- 306
		if self.flashT <= 0 then -- 306
			self.flash = "" -- 308
		end -- 308
	end -- 308
	if self.traceT > 0 then -- 308
		self.traceT = self.traceT - dt -- 312
		if self.traceT <= 0 then -- 312
			self.trace = nil -- 314
		end -- 314
	end -- 314
	if self.paused then -- 314
		self:updateCamera(dt) -- 318
		return -- 319
	end -- 319
	self.ticks = self.ticks + 1 -- 322
	local p = self.player -- 323
	self:stepPlayer(p, dt, input) -- 324
	self:stepEscort(dt, input) -- 325
	self:stepEnemies(dt) -- 326
	self:stepVillage(dt, input) -- 327
	self:stepInteract(dt, input) -- 328
	self:updateGate() -- 329
	self:updateCamera(dt) -- 330
end -- 301
function Play.prototype.nearLowLedge(self, a) -- 334
	local reach = 26 -- 335
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 336
	local x1 = x0 + reach -- 337
	local i = 0 -- 338
	do -- 338
		i = 0 -- 339
		while i < #self.boxes do -- 339
			do -- 339
				local b = self.boxes[i + 1] -- 340
				if b.x1 <= x0 or b.x0 >= x1 then -- 340
					goto __continue27 -- 342
				end -- 342
				local rise = b.y1 - a.y -- 344
				if rise > 0 and rise <= LEDGE_RISE then -- 344
					return true -- 346
				end -- 346
			end -- 346
			::__continue27:: -- 346
			i = i + 1 -- 339
		end -- 339
	end -- 339
	return false -- 349
end -- 334
function Play.prototype.stepPlayer(self, a, dt, input) -- 352
	if not a.alive then -- 352
		return -- 354
	end -- 354
	local isChild = self.room.key ~= "checkpoint" -- 356
	if not isChild and self.escort.state == "calming" then -- 356
		a.crouch = false -- 359
		a.h = SOLDIER_H -- 360
		a.vx = 0 -- 361
		self:fallY(a, dt) -- 362
		return -- 363
	end -- 363
	a.crouch = isChild and input.crouch.held and a.onGround -- 365
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 366
	a.covered = not isChild and input.cover.held -- 367
	if a.rollT > 0 then -- 367
		a.rollT = a.rollT - dt -- 371
		a.vx = a.facing * ROLL_SPEED -- 372
		self:slideX(a, a.vx * dt) -- 373
		self:fallY(a, dt) -- 374
		if a.rollT <= 0 then -- 374
			self:flashSet("翻滚结束", 0.5) -- 376
		end -- 376
		return -- 378
	end -- 378
	if not isChild and input.jump.pressed and a.onGround then -- 378
		if input.moveX ~= 0 then -- 378
			a.facing = input.moveX > 0 and 1 or -1 -- 383
		end -- 383
		if self:nearLowLedge(a) then -- 383
			a.vy = SOLDIER_JUMP -- 387
			a.onGround = false -- 388
			self:flashSet("翻上去", 0.3) -- 389
			return -- 390
		end -- 390
		a.rollT = ROLL_TIME -- 392
		self:flashSet("翻滚", 0.3) -- 393
		return -- 394
	end -- 394
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 397
	if isChild then -- 397
		if input.cover.held then -- 397
			speed = CHILD_SLOW -- 400
		end -- 400
		if a.crouch then -- 400
			speed = CHILD_SLOW -- 403
		end -- 403
	elseif a.covered then -- 403
		speed = SOLDIER_SPEED * 0.45 -- 406
	end -- 406
	local dir = self.gripping and 0 or input.moveX -- 410
	if dir ~= 0 then -- 410
		a.facing = dir > 0 and 1 or -1 -- 412
	end -- 412
	a.vx = dir * speed -- 414
	if isChild and input.jump.pressed and a.onGround and not a.crouch then -- 414
		a.vy = CHILD_JUMP -- 418
		a.onGround = false -- 419
		self:flashSet("跳", 0.25) -- 420
	end -- 420
	self:slideX(a, a.vx * dt) -- 423
	self:fallY(a, dt) -- 424
	if not isChild and input.fire.pressed then -- 424
		self:shoot(a) -- 428
	end -- 428
end -- 352
function Play.prototype.stepPartner(self, p, dt) -- 433
	local a = self.partner -- 434
	if not a.alive then -- 434
		return -- 436
	end -- 436
	a.crouch = false -- 438
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 439
	a.vx = 0 -- 440
	self:fallY(a, dt) -- 441
end -- 433
function Play.prototype.stepEscort(self, dt, input) -- 448
	local a = self.partner -- 449
	if not a.alive then -- 449
		return -- 451
	end -- 451
	if self.room.key ~= "checkpoint" then -- 451
		a.vx = 0 -- 454
		self:fallY(a, dt) -- 455
		return -- 456
	end -- 456
	local p = self.player -- 458
	local dist = math.abs(p.x - a.x) -- 459
	self.calmConsumed = self.escort:update( -- 460
		input, -- 460
		p.x, -- 460
		p.facing, -- 460
		a.x, -- 460
		dist -- 460
	) -- 460
	a.crouch = self.escort.crouchPose -- 461
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 462
	local dir = self.escort:moveDir(a.x) -- 463
	a.vx = dir * CHILD_SPEED -- 464
	if dir ~= 0 then -- 464
		a.facing = dir -- 466
		local before = a.x -- 467
		self:slideX(a, dir * CHILD_SPEED * dt) -- 468
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 468
			a.vy = CHILD_JUMP -- 471
			a.onGround = false -- 472
		end -- 472
	end -- 472
	self:fallY(a, dt) -- 475
end -- 448
function Play.prototype.updateGate(self) -- 478
	if self.room.key ~= "checkpoint" then -- 478
		self.gateOpen = false -- 480
		return -- 481
	end -- 481
	local function inZone(x) -- 483
		return x >= 792 and x <= 928 -- 483
	end -- 483
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 484
end -- 478
function Play.prototype.stepEnemies(self, dt) -- 487
	local i = 0 -- 488
	do -- 488
		i = 0 -- 489
		while i < #self.enemies do -- 489
			local e = self.enemies[i + 1] -- 490
			if e.hitT > 0 then -- 490
				e.hitT = e.hitT - dt -- 492
			end -- 492
			i = i + 1 -- 489
		end -- 489
	end -- 489
end -- 487
function Play.prototype.stepInteract(self, dt, input) -- 497
	local p = self.player -- 498
	local calmUsed = self.calmConsumed -- 499
	self.calmConsumed = false -- 500
	self.focusCart = false -- 501
	if self.room.key == "outside" then -- 501
		local c = self.room.cart -- 503
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 504
		local dy = p.y - c.baseY -- 505
		self.focusCart = dx * dx + dy * dy < CART_REACH * CART_REACH -- 506
	end -- 506
	self:stepCart(dt, input) -- 508
	if calmUsed then -- 508
		self:flashSet("安抚 · 敲两下", 0.8) -- 512
	elseif input.interact.pressed and not self.gripping and self.room.key ~= "village" then -- 512
		if self.knockT > 0 then -- 512
			self.knocks = self.knocks + 1 -- 515
		else -- 515
			self.knocks = 1 -- 517
		end -- 517
		self.knockT = 1.2 -- 519
		if self.knocks >= 2 then -- 519
			self:flashSet("敲两下", 0.8) -- 521
			self.knocks = 0 -- 522
		else -- 522
			self:flashSet("敲一下", 0.5) -- 524
		end -- 524
	elseif self.knockT > 0 then -- 524
		self.knockT = self.knockT - dt -- 527
		if self.knockT <= 0 then -- 527
			self.knocks = 0 -- 529
		end -- 529
	end -- 529
	local i = 0 -- 534
	do -- 534
		i = 0 -- 535
		while i < #self.room.marks do -- 535
			do -- 535
				local m = self.room.marks[i + 1] -- 536
				if m.kind ~= 0 then -- 536
					goto __continue70 -- 538
				end -- 538
				local subjects = {self.partner, self.player} -- 540
				local k = 0 -- 541
				do -- 541
					k = 0 -- 542
					while k < #subjects do -- 542
						do -- 542
							local s = subjects[k + 1] -- 543
							if not s.alive then -- 543
								goto __continue73 -- 545
							end -- 545
							local dx = s.x - m.x -- 547
							local dy = s.y - m.y -- 548
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 548
								self.checkpoint = m.x -- 550
								self.checkpointCartAxle = self.cartAxle -- 551
								if self.cartDocked then -- 551
									self:flashSet("检查点 · 车已落窝", 1) -- 553
								else -- 553
									self:flashSet("检查点 · 车还没到位", 1) -- 555
								end -- 555
							end -- 555
						end -- 555
						::__continue73:: -- 555
						k = k + 1 -- 542
					end -- 542
				end -- 542
			end -- 542
			::__continue70:: -- 542
			i = i + 1 -- 535
		end -- 535
	end -- 535
	self:checkCarryGate() -- 561
end -- 497
function Play.prototype.stepVillage(self, dt, input) -- 565
	if self.room.key ~= "village" then -- 565
		return -- 567
	end -- 567
	local p = self.player -- 569
	local bottle = self.room.bottle -- 570
	local scav = self.room.scavenger -- 571
	if not self.hasBottle and bottle ~= nil then -- 571
		local dx = p.x - bottle.x -- 575
		local dy = p.y + p.h * 0.5 - bottle.y -- 576
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 576
			self.hasBottle = true -- 578
			self:flashSet("拾起瓶子", 0.8) -- 579
		end -- 579
	end -- 579
	if self.hasBottle then -- 579
		if input.aim.held then -- 579
			self.aimHold = self.aimHold + dt -- 586
			if self.aimHold > 1.2 then -- 586
				self.aimHold = 1.2 -- 588
			end -- 588
		elseif input.aim.released then -- 588
			local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 591
			self:throwBottle(aim.x, aim.y) -- 592
			self.aimHold = 0 -- 593
		end -- 593
	else -- 593
		self.aimHold = 0 -- 596
	end -- 596
	local fly = self.bottleFly -- 600
	if fly ~= nil then -- 600
		fly.vy = fly.vy - GRAVITY * dt -- 602
		fly.x = fly.x + fly.vx * dt -- 603
		fly.y = fly.y + fly.vy * dt -- 604
		local g = self:groundAt(fly.x, fly.y + 4, 3) -- 605
		if fly.y <= g then -- 605
			self.bottleFly = nil -- 607
			self.bottleLandX = fly.x -- 608
			self.bottleLandT = 0.9 -- 609
			self:hearBottle(fly.x) -- 610
		end -- 610
	end -- 610
	if self.bottleLandT > 0 then -- 610
		self.bottleLandT = self.bottleLandT - dt -- 614
	end -- 614
	if scav ~= nil then -- 614
		self:stepScav(dt, scav) -- 618
	end -- 618
	local line = self.room.passLine -- 621
	if line ~= nil and not self.passed and p.x >= line then -- 621
		self.passed = true -- 623
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 624
	end -- 624
end -- 565
function Play.prototype.throwBottle(self, tx, ty) -- 629
	local p = self.player -- 630
	local x0 = p.x + p.facing * 10 -- 631
	local y0 = p.y + p.h * 0.7 -- 632
	local T = 0.62 -- 633
	local vx = (tx - x0) / T -- 634
	local vy = (ty - y0 + 0.5 * GRAVITY * T * T) / T -- 635
	self.bottleFly = {x = x0, y = y0, vx = vx, vy = vy} -- 636
	self.hasBottle = false -- 637
	self:flashSet("投出", 0.4) -- 638
end -- 629
function Play.prototype.hearBottle(self, x) -- 642
	local s = self.room.scavenger -- 643
	if s == nil then -- 643
		return -- 645
	end -- 645
	if math.abs(x - self.scavX) > s.range then -- 645
		self:flashSet("落地 · 他没听见", 0.6) -- 648
		return -- 649
	end -- 649
	self.scavState = "turn" -- 651
	self.scavT = s.hearTicks -- 652
	self.scavTargetX = x -- 653
	self:flashSet("砖地一响 · 他转头", 0.9) -- 654
end -- 642
function Play.prototype.stepScav(self, dt, s) -- 658
	if self.scavState == "turn" then -- 658
		self.scavT = self.scavT - 1 -- 660
		if self.scavT <= 0 then -- 660
			self.scavState = "walk" -- 662
		end -- 662
		return -- 664
	end -- 664
	if self.scavState == "walk" then -- 664
		local d = self.scavTargetX - self.scavX -- 667
		if math.abs(d) < 4 then -- 667
			self.scavState = "stall" -- 669
			self.scavT = s.stallTicks -- 670
			return -- 671
		end -- 671
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 673
		return -- 674
	end -- 674
	if self.scavState == "stall" then -- 674
		self.scavT = self.scavT - 1 -- 677
		if self.scavT <= 0 then -- 677
			self.scavState = "back" -- 679
		end -- 679
		return -- 681
	end -- 681
	if self.scavState == "back" then -- 681
		local home = math.max( -- 684
			s.x0, -- 684
			math.min(s.x1, self.scavX) -- 684
		) -- 684
		if math.abs(home - self.scavX) < 2 then -- 684
			self.scavState = "patrol" -- 686
			return -- 687
		end -- 687
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 689
		return -- 690
	end -- 690
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 692
	if self.scavX >= s.x1 then -- 692
		self.scavX = s.x1 -- 694
		self.scavDir = -1 -- 695
	elseif self.scavX <= s.x0 then -- 695
		self.scavX = s.x0 -- 697
		self.scavDir = 1 -- 698
	end -- 698
end -- 658
function Play.prototype.stepCart(self, dt, input) -- 706
	local p = self.player -- 707
	local c = self.room.cart -- 708
	local handleX = self.cartAxle + c.handleOffset -- 709
	if self.gripping then -- 709
		if not input.interact.held then -- 709
			self.gripping = false -- 713
			self:flashSet("松开车把", 0.4) -- 714
			return -- 715
		end -- 715
	else -- 715
		if not input.interact.pressed then -- 715
			return -- 719
		end -- 719
		if math.abs(p.x - handleX) > CART_REACH or math.abs(p.y - c.baseY) > 40 then -- 719
			return -- 722
		end -- 722
		self.gripping = true -- 724
		self:flashSet("握住车把", 0.4) -- 725
		return -- 726
	end -- 726
	if self.cartDocked then -- 726
		return -- 730
	end -- 730
	local dir = input.moveX -- 732
	if dir == 0 then -- 732
		return -- 734
	end -- 734
	local lo = math.min(c.startX, c.endX) -- 736
	local hi = math.max(c.startX, c.endX) -- 737
	local next = self.cartAxle + dir * CART_SPEED * dt -- 738
	if next < lo then -- 738
		next = lo -- 740
	end -- 740
	if next > hi then -- 740
		next = hi -- 743
	end -- 743
	local delta = next - self.cartAxle -- 745
	if delta == 0 then -- 745
		return -- 747
	end -- 747
	self.cartAxle = next -- 749
	p.x = p.x + delta -- 750
	p.facing = dir > 0 and 1 or -1 -- 751
	self:slideX(p, 0) -- 752
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > CART_REACH then -- 752
		self.gripping = false -- 754
		self:flashSet("跟不上了，脱手", 0.6) -- 755
		return -- 756
	end -- 756
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 756
		self.cartDocked = true -- 759
		self.gripping = false -- 760
		self:flashSet("车轮落窝", 1.2) -- 761
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 761
		self:flashSet("车轮回到起点", 0.5) -- 763
	end -- 763
end -- 706
function Play.prototype.checkCarryGate(self) -- 771
	if self.room.key == "checkpoint" then -- 771
		if self.gateOpen and self.player.x >= 900 then -- 771
			self.carryCartAxle = self.cartAxle -- 774
			self.carryCartDocked = self.cartDocked -- 775
			self.wantRoom = "outside" -- 776
			self:flashSet("过城门 · 城外", 1.2) -- 777
		end -- 777
		return -- 779
	end -- 779
	if self.room.key == "outside" then -- 779
		if self.checkpoint >= 380 and self.player.x >= 388 then -- 779
			self.carryCartAxle = self.cartAxle -- 784
			self.carryCartDocked = self.cartDocked -- 785
			self.wantRoom = "village" -- 786
			self:flashSet("洞后 · 墙根小路", 1.2) -- 787
		end -- 787
	end -- 787
end -- 771
function Play.prototype.shoot(self, a) -- 793
	local ox = a.x + a.facing * 8 -- 794
	local oy = a.y + a.h * 0.72 -- 795
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 797
	local dx = aim.x - ox -- 798
	local dy = aim.y - oy -- 799
	local len = math.sqrt(dx * dx + dy * dy) -- 800
	if len < 0.001 then -- 800
		dx = a.facing -- 802
		dy = 0 -- 803
	else -- 803
		dx = dx / len -- 805
		dy = dy / len -- 806
	end -- 806
	if dx ~= 0 then -- 806
		a.facing = dx > 0 and 1 or -1 -- 809
	end -- 809
	local hitEnemy = self:raycast( -- 812
		ox, -- 812
		oy, -- 812
		dx, -- 812
		dy, -- 812
		true -- 812
	) -- 812
	local hitWall = self:raycast( -- 813
		ox, -- 813
		oy, -- 813
		dx, -- 813
		dy, -- 813
		false -- 813
	) -- 813
	local tEnemy = hitEnemy.t -- 814
	local tWall = hitWall.t -- 815
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 816
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 817
	self.trace = { -- 819
		x0 = ox, -- 819
		y0 = oy, -- 819
		x1 = ox + dx * t, -- 819
		y1 = oy + dy * t, -- 819
		hit = hit -- 819
	} -- 819
	self.traceT = 0.12 -- 820
	self:applyFireDanger(ox) -- 821
	if hit then -- 821
		local i = hitEnemy.index -- 823
		local e = self.enemies[i + 1] -- 824
		e.alive = false -- 825
		e.hitT = 0.4 -- 826
		self:flashSet("命中", 0.6) -- 827
	else -- 827
		self:flashSet("打空", 0.35) -- 829
	end -- 829
end -- 793
function Play.prototype.applyFireDanger(self, shotX) -- 834
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 834
		return -- 836
	end -- 836
	local dangerX = shotX -- 838
	local best = -1 -- 839
	local bestD = 1000000000 -- 840
	local i = 0 -- 841
	do -- 841
		i = 0 -- 842
		while i < #self.enemies do -- 842
			do -- 842
				local e = self.enemies[i + 1] -- 843
				if not e.alive then -- 843
					goto __continue135 -- 845
				end -- 845
				local d = math.abs(e.x - self.partner.x) -- 847
				if d < bestD then -- 847
					bestD = d -- 849
					best = i -- 850
				end -- 850
			end -- 850
			::__continue135:: -- 850
			i = i + 1 -- 842
		end -- 842
	end -- 842
	if best >= 0 then -- 842
		dangerX = self.enemies[best + 1].x -- 854
	end -- 854
	local exposed = self:childExposed(dangerX) -- 856
	local before = self.escort.fear -- 857
	local after = self.escort:applyDanger(self.nextDangerId, exposed, self.partner.x) -- 858
	self.nextDangerId = self.nextDangerId + 1 -- 859
	if after > before then -- 859
		self:flashSet( -- 861
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 861
			1 -- 861
		) -- 861
	elseif not exposed then -- 861
		self:flashSet("枪声没够到她", 0.5) -- 863
	end -- 863
end -- 834
function Play.prototype.childExposed(self, dangerX) -- 868
	local c = self.partner -- 869
	if not c.alive then -- 869
		return false -- 871
	end -- 871
	if c.x > 240 and c.x < 340 then -- 871
		return false -- 874
	end -- 874
	if c.x < 380 or c.x > 560 then -- 874
		return false -- 877
	end -- 877
	local toDanger = dangerX - c.x -- 879
	local toPlayer = self.player.x - c.x -- 880
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) then -- 880
		return false -- 882
	end -- 882
	return true -- 884
end -- 868
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 888
	local best = -1 -- 889
	local bestI = -1 -- 890
	local i = 0 -- 891
	if enemies then -- 891
		do -- 891
			i = 0 -- 893
			while i < #self.enemies do -- 893
				do -- 893
					local e = self.enemies[i + 1] -- 894
					if not e.alive then -- 894
						goto __continue149 -- 896
					end -- 896
					local t = hitBox( -- 898
						ox, -- 898
						oy, -- 898
						dx, -- 898
						dy, -- 898
						e.x - e.w / 2, -- 898
						e.x + e.w / 2, -- 898
						e.y, -- 898
						e.y + e.h -- 898
					) -- 898
					if t >= 0 and (best < 0 or t < best) then -- 898
						best = t -- 900
						bestI = i -- 901
					end -- 901
				end -- 901
				::__continue149:: -- 901
				i = i + 1 -- 893
			end -- 893
		end -- 893
		return {t = best, index = bestI} -- 904
	end -- 904
	do -- 904
		i = 0 -- 906
		while i < #self.boxes do -- 906
			local b = self.boxes[i + 1] -- 907
			local t = hitBox( -- 908
				ox, -- 908
				oy, -- 908
				dx, -- 908
				dy, -- 908
				b.x0, -- 908
				b.x1, -- 908
				b.y0, -- 908
				b.y1 -- 908
			) -- 908
			if t >= 0 and (best < 0 or t < best) then -- 908
				best = t -- 910
			end -- 910
			i = i + 1 -- 906
		end -- 906
	end -- 906
	if dy < 0 then -- 906
		local t = (0 - oy) / dy -- 915
		if t >= 0 and (best < 0 or t < best) then -- 915
			best = t -- 917
		end -- 917
	end -- 917
	return {t = best, index = -1} -- 920
end -- 888
function Play.prototype.slideX(self, a, dx) -- 924
	local nx = a.x + dx -- 925
	local half = a.w / 2 -- 926
	local room = self.room -- 927
	nx = math.max( -- 928
		room.minX + half, -- 928
		math.min(room.maxX - half, nx) -- 928
	) -- 928
	local i = 0 -- 929
	do -- 929
		i = 0 -- 930
		while i < #self.boxes do -- 930
			do -- 930
				local b = self.boxes[i + 1] -- 931
				if b.passable == true then -- 931
					goto __continue159 -- 933
				end -- 933
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 933
					goto __continue159 -- 936
				end -- 936
				if nx + half > b.x0 and nx - half < b.x1 then -- 936
					if a.x <= b.x0 then -- 936
						nx = b.x0 - half -- 940
					elseif a.x >= b.x1 then -- 940
						nx = b.x1 + half -- 942
					else -- 942
						nx = a.x -- 944
					end -- 944
				end -- 944
			end -- 944
			::__continue159:: -- 944
			i = i + 1 -- 930
		end -- 930
	end -- 930
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 930
		local bx0 = self.cartAxle - CART_HALF -- 950
		local bx1 = self.cartAxle + CART_HALF -- 951
		if nx + half > bx0 and nx - half < bx1 then -- 951
			if a.x <= bx0 then -- 951
				nx = bx0 - half -- 954
			elseif a.x >= bx1 then -- 954
				nx = bx1 + half -- 956
			else -- 956
				nx = a.x -- 958
			end -- 958
		end -- 958
	end -- 958
	local arch = room.arch -- 966
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 966
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 968
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 968
			if a.x <= arch.x0 then -- 968
				nx = arch.x0 - half -- 971
			elseif a.x >= arch.x1 then -- 971
				nx = arch.x1 + half -- 973
			end -- 973
		end -- 973
	end -- 973
	a.x = nx -- 977
end -- 924
function Play.prototype.fallY(self, a, dt) -- 981
	a.vy = a.vy - GRAVITY * dt -- 982
	if a.vy < -900 then -- 982
		a.vy = -900 -- 984
	end -- 984
	local ny = a.y + a.vy * dt -- 986
	local half = a.w / 2 -- 987
	if a.vy <= 0 then -- 987
		local ground = self:groundAt(a.x, a.y + 0.5, half) -- 989
		if ny <= ground then -- 989
			ny = ground -- 991
			a.vy = 0 -- 992
			a.onGround = true -- 993
		else -- 993
			a.onGround = false -- 995
		end -- 995
	else -- 995
		a.onGround = false -- 998
		local i = 0 -- 999
		do -- 999
			i = 0 -- 1000
			while i < #self.boxes do -- 1000
				do -- 1000
					local b = self.boxes[i + 1] -- 1001
					if b.passable == true then -- 1001
						goto __continue182 -- 1003
					end -- 1003
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 1003
						goto __continue182 -- 1006
					end -- 1006
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 1006
						ny = b.y0 - a.h -- 1009
						a.vy = 0 -- 1010
					end -- 1010
				end -- 1010
				::__continue182:: -- 1010
				i = i + 1 -- 1000
			end -- 1000
		end -- 1000
	end -- 1000
	a.y = ny -- 1014
end -- 981
function Play.prototype.groundAt(self, x, ceiling, half) -- 1018
	local g = -9999 -- 1019
	local i = 0 -- 1020
	do -- 1020
		i = 0 -- 1021
		while i < #self.floors do -- 1021
			local f = self.floors[i + 1] -- 1022
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 1022
				g = f.y1 -- 1024
			end -- 1024
			i = i + 1 -- 1021
		end -- 1021
	end -- 1021
	do -- 1021
		i = 0 -- 1027
		while i < #self.boxes do -- 1027
			local b = self.boxes[i + 1] -- 1028
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 1028
				g = b.y1 -- 1030
			end -- 1030
			i = i + 1 -- 1027
		end -- 1027
	end -- 1027
	return g -- 1033
end -- 1018
function Play.prototype.updateCamera(self, dt) -- 1036
	local p = self.player -- 1037
	local tx = p.x + p.facing * 30 -- 1038
	local ty = p.y + CAM_LOOK_UP -- 1039
	local k = math.min(1, CAM_FOLLOW * dt) -- 1040
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 1041
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 1042
end -- 1036
function Play.prototype.clampCamera(self, w, h) -- 1046
	local room = self.room -- 1047
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 1048
	local spanX = room.maxX - room.minX -- 1049
	if spanX <= halfW * 2 then -- 1049
		self.cam.x = (room.minX + room.maxX) / 2 -- 1051
	else -- 1051
		self.cam.x = math.max( -- 1053
			room.minX + halfW, -- 1053
			math.min(room.maxX - halfW, self.cam.x) -- 1053
		) -- 1053
	end -- 1053
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 1056
	local spanY = room.height -- 1057
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 1058
	if spanY <= halfH * 2 then -- 1058
		self.cam.y = camY -- 1060
	else -- 1060
		self.cam.y = math.max( -- 1062
			camY, -- 1062
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 1062
		) -- 1062
	end -- 1062
end -- 1046
function Play.prototype.flashSet(self, text, t) -- 1066
	self.flash = text -- 1067
	self.flashT = t -- 1068
end -- 1066
function Play.prototype.statusText(self) -- 1072
	local p = self.player -- 1073
	local parts = {} -- 1074
	if self.room.key == "village" then -- 1074
		parts[#parts + 1] = (("小满 x=" .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 1076
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1077
		if self.hasBottle then -- 1077
			parts[#parts + 1] = "有瓶" -- 1079
		elseif self.bottleFly ~= nil then -- 1079
			parts[#parts + 1] = "瓶在飞" -- 1081
		else -- 1081
			parts[#parts + 1] = "空手" -- 1083
		end -- 1083
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 1085
		if self.passed then -- 1085
			parts[#parts + 1] = "已过通行线" -- 1087
		end -- 1087
		if self.paused then -- 1087
			parts[#parts + 1] = "已暂停" -- 1090
		end -- 1090
		return table.concat(parts, " · ") -- 1092
	end -- 1092
	local isChild = self.room.key ~= "checkpoint" -- 1095
	local who = isChild and "小满" or "周戍" -- 1096
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 1097
	if isChild then -- 1097
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1099
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 1100
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1101
	else -- 1101
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 1103
		if p.rollT > 0 then -- 1103
			parts[#parts + 1] = "翻滚中" -- 1105
		end -- 1105
		local alive = 0 -- 1107
		local i = 0 -- 1108
		do -- 1108
			i = 0 -- 1109
			while i < #self.enemies do -- 1109
				if self.enemies[i + 1].alive then -- 1109
					alive = alive + 1 -- 1111
				end -- 1111
				i = i + 1 -- 1109
			end -- 1109
		end -- 1109
		parts[#parts + 1] = (("敌 " .. tostring(alive)) .. "/") .. tostring(#self.enemies) -- 1114
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1115
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 1116
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 1117
	end -- 1117
	if self.checkpoint >= 0 then -- 1117
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 1120
	end -- 1120
	if self.paused then -- 1120
		parts[#parts + 1] = "已暂停" -- 1123
	end -- 1123
	return table.concat(parts, " · ") -- 1125
end -- 1072
function Play.prototype.scavLabel(self) -- 1129
	if self.scavState == "turn" then -- 1129
		return "转头" -- 1131
	end -- 1131
	if self.scavState == "walk" then -- 1131
		return "赶来" -- 1134
	end -- 1134
	if self.scavState == "stall" then -- 1134
		return "停住" -- 1137
	end -- 1137
	if self.scavState == "back" then -- 1137
		return "回位" -- 1140
	end -- 1140
	return "巡逻" -- 1142
end -- 1129
function Play.prototype.hintText(self) -- 1146
	if self.paused then -- 1146
		return "Esc 继续 · R 重置" -- 1148
	end -- 1148
	if self.flash ~= "" then -- 1148
		return self.flash -- 1151
	end -- 1151
	if self.room.key == "village" then -- 1151
		if self.bottleFly ~= nil then -- 1151
			return "等瓶子落地 · 触地才发声" -- 1155
		end -- 1155
		if self.hasBottle then -- 1155
			return "按住 F 瞄，松手投 · 往右投到砖地 608，他才会走开" -- 1158
		end -- 1158
		if self.passed then -- 1158
			return "已过第一院 · R 重置可再来一遍" -- 1161
		end -- 1161
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 1163
	end -- 1163
	if self.room.key == "outside" then -- 1163
		if self.focusCart then -- 1163
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 1167
		end -- 1167
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 1169
	end -- 1169
	if self.escort.state == "frozen" then -- 1169
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 1169
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 1173
		end -- 1173
		return "小满吓住了 · 走过去，靠近再点 E" -- 1175
	end -- 1175
	if self.escort.state == "calming" then -- 1175
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 1178
	end -- 1178
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 1180
end -- 1146
function Play.prototype.draw(self, draw, w, h) -- 1185
	self.viewW = w -- 1186
	self.viewH = h -- 1187
	self.view = ____exports.computeViewport(w, h) -- 1188
	self:clampCamera(w, h) -- 1189
	draw:clear() -- 1190
	draw:drawRect( -- 1192
		Rect(0, 0, w, h), -- 1192
		BG_VOID -- 1192
	) -- 1192
	local box = self:canvasRect(w, h) -- 1193
	draw:drawRect(box, BG_FAR) -- 1194
	draw:drawRect( -- 1195
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 1195
		BG_MID -- 1195
	) -- 1195
	self:drawFloors(draw, w, h) -- 1197
	self:drawSolids(draw, w, h) -- 1198
	self:drawZones(draw, w, h) -- 1199
	self:drawArch(draw, w, h) -- 1200
	self:drawCart(draw, w, h) -- 1201
	self:drawActors(draw, w, h) -- 1202
	self:drawTrace(draw, w, h) -- 1203
	self:drawAim(draw, w, h) -- 1204
end -- 1185
function Play.prototype.canvasRect(self, w, h) -- 1208
	local v = self.view -- 1209
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 1210
end -- 1208
function Play.prototype.px(self, n) -- 1214
	return n * self.view.zoom -- 1215
end -- 1214
function Play.prototype.sx(self, wx, w) -- 1219
	local v = self.view -- 1220
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 1221
	return v.ox + lx * v.zoom -- 1222
end -- 1219
function Play.prototype.sy(self, wy, h) -- 1226
	local v = self.view -- 1227
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 1228
	return v.oy + ly * v.zoom -- 1229
end -- 1226
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 1232
	local px0 = self:sx(x0, w) -- 1233
	local px1 = self:sx(x1, w) -- 1234
	local py0 = self:sy(y0, h) -- 1235
	local py1 = self:sy(y1, h) -- 1236
	if px1 <= px0 or py1 <= py0 then -- 1236
		return -- 1238
	end -- 1238
	draw:drawRect( -- 1240
		Rect(px0, py0, px1 - px0, py1 - py0), -- 1240
		color -- 1240
	) -- 1240
end -- 1232
function Play.prototype.drawFloors(self, draw, w, h) -- 1243
	local i = 0 -- 1244
	do -- 1244
		i = 0 -- 1245
		while i < #self.room.floors do -- 1245
			local f = self.room.floors[i + 1] -- 1246
			local y = self:sy(f.y, h) -- 1247
			local x0 = self:sx(f.x0, w) -- 1248
			local x1 = self:sx(f.x1, w) -- 1249
			local deck = self:px(5) -- 1250
			draw:drawRect( -- 1251
				Rect(x0, y - deck, x1 - x0, deck), -- 1251
				FLOOR_DECK -- 1251
			) -- 1251
			draw:drawSegment( -- 1252
				Vec2(x0, y), -- 1252
				Vec2(x1, y), -- 1252
				self:px(1), -- 1252
				GROUND -- 1252
			) -- 1252
			i = i + 1 -- 1245
		end -- 1245
	end -- 1245
end -- 1243
function Play.prototype.drawSolids(self, draw, w, h) -- 1256
	local i = 0 -- 1257
	do -- 1257
		i = 0 -- 1258
		while i < #self.boxes do -- 1258
			do -- 1258
				local b = self.boxes[i + 1] -- 1259
				if b.y0 < -4 and b.y1 <= 96 then -- 1259
					draw:drawSegment( -- 1262
						Vec2( -- 1262
							self:sx(b.x0, w), -- 1262
							self:sy(b.y1, h) -- 1262
						), -- 1262
						Vec2( -- 1262
							self:sx(b.x1, w), -- 1262
							self:sy(b.y1, h) -- 1262
						), -- 1262
						self:px(1), -- 1262
						GROUND -- 1262
					) -- 1262
					goto __continue244 -- 1263
				end -- 1263
				self:drawBox( -- 1265
					draw, -- 1265
					w, -- 1265
					h, -- 1265
					b.x0, -- 1265
					b.x1, -- 1265
					b.y0, -- 1265
					b.y1, -- 1265
					SOLID_FILL -- 1265
				) -- 1265
				draw:drawSegment( -- 1266
					Vec2( -- 1266
						self:sx(b.x0, w), -- 1266
						self:sy(b.y1, h) -- 1266
					), -- 1266
					Vec2( -- 1266
						self:sx(b.x1, w), -- 1266
						self:sy(b.y1, h) -- 1266
					), -- 1266
					self:px(1), -- 1266
					SOLID_EDGE -- 1266
				) -- 1266
			end -- 1266
			::__continue244:: -- 1266
			i = i + 1 -- 1258
		end -- 1258
	end -- 1258
end -- 1256
function Play.prototype.drawZones(self, draw, w, h) -- 1270
	local i = 0 -- 1271
	do -- 1271
		i = 0 -- 1272
		while i < #self.room.zones do -- 1272
			local z = self.room.zones[i + 1] -- 1273
			local fill = DANGER -- 1274
			local line = DANGER_LINE -- 1275
			if z.tint == 2 then -- 1275
				fill = SOFT -- 1277
				line = SOFT_LINE -- 1278
			elseif z.tint == 3 then -- 1278
				fill = BRICK -- 1280
				line = BRICK_LINE -- 1281
			elseif z.tint == 4 then -- 1281
				fill = PASS -- 1283
				line = PASS_LINE -- 1284
			end -- 1284
			self:drawBox( -- 1286
				draw, -- 1286
				w, -- 1286
				h, -- 1286
				z.x0, -- 1286
				z.x1, -- 1286
				z.y, -- 1286
				z.y + z.h, -- 1286
				fill -- 1286
			) -- 1286
			draw:drawSegment( -- 1287
				Vec2( -- 1287
					self:sx(z.x0, w), -- 1287
					self:sy(z.y, h) -- 1287
				), -- 1287
				Vec2( -- 1287
					self:sx(z.x0, w), -- 1287
					self:sy(z.y + z.h, h) -- 1287
				), -- 1287
				self:px(1), -- 1287
				line -- 1287
			) -- 1287
			draw:drawSegment( -- 1288
				Vec2( -- 1288
					self:sx(z.x1, w), -- 1288
					self:sy(z.y, h) -- 1288
				), -- 1288
				Vec2( -- 1288
					self:sx(z.x1, w), -- 1288
					self:sy(z.y + z.h, h) -- 1288
				), -- 1288
				self:px(1), -- 1288
				line -- 1288
			) -- 1288
			i = i + 1 -- 1272
		end -- 1272
	end -- 1272
end -- 1270
function Play.prototype.drawArch(self, draw, w, h) -- 1292
	local a = self.room.arch -- 1293
	if a.h <= 0 then -- 1293
		return -- 1295
	end -- 1295
	self:drawBox( -- 1297
		draw, -- 1297
		w, -- 1297
		h, -- 1297
		a.x0, -- 1297
		a.x1, -- 1297
		a.y, -- 1297
		a.y + a.h, -- 1297
		HOLE_FILL -- 1297
	) -- 1297
	draw:drawSegment( -- 1298
		Vec2( -- 1298
			self:sx(a.x0, w), -- 1298
			self:sy(a.y + a.h, h) -- 1298
		), -- 1298
		Vec2( -- 1298
			self:sx(a.x1, w), -- 1298
			self:sy(a.y + a.h, h) -- 1298
		), -- 1298
		self:px(1), -- 1298
		SOLID_EDGE -- 1298
	) -- 1298
	draw:drawSegment( -- 1299
		Vec2( -- 1299
			self:sx(a.x0, w), -- 1299
			self:sy(a.y, h) -- 1299
		), -- 1299
		Vec2( -- 1299
			self:sx(a.x0, w), -- 1299
			self:sy(a.y + a.h, h) -- 1299
		), -- 1299
		self:px(1), -- 1299
		SOLID_EDGE -- 1299
	) -- 1299
	draw:drawSegment( -- 1300
		Vec2( -- 1300
			self:sx(a.x1, w), -- 1300
			self:sy(a.y, h) -- 1300
		), -- 1300
		Vec2( -- 1300
			self:sx(a.x1, w), -- 1300
			self:sy(a.y + a.h, h) -- 1300
		), -- 1300
		self:px(1), -- 1300
		SOLID_EDGE -- 1300
	) -- 1300
end -- 1292
function Play.prototype.drawCart(self, draw, w, h) -- 1303
	local c = self.room.cart -- 1304
	if c.bodyW <= 0 then -- 1304
		return -- 1306
	end -- 1306
	drawCartShape( -- 1308
		draw, -- 1308
		self, -- 1308
		w, -- 1308
		h, -- 1308
		c, -- 1308
		self.cartAxle -- 1308
	) -- 1308
	draw:drawRect( -- 1309
		Rect( -- 1309
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 1309
			self:sy(c.baseY + 40, h), -- 1309
			self:px(2), -- 1309
			self:px(40) -- 1309
		), -- 1309
		STAND -- 1309
	) -- 1309
end -- 1303
function Play.prototype.drawActors(self, draw, w, h) -- 1312
	local p = self.player -- 1313
	local isChild = self.room.key ~= "checkpoint" -- 1314
	drawFigure( -- 1315
		draw, -- 1315
		self, -- 1315
		w, -- 1315
		h, -- 1315
		p, -- 1315
		isChild and CHILD_BODY or SOLDIER_BODY, -- 1315
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 1315
	) -- 1315
	local q = self.partner -- 1316
	if q.alive then -- 1316
		local childPartner = q.w == CHILD_W -- 1318
		drawFigure( -- 1319
			draw, -- 1319
			self, -- 1319
			w, -- 1319
			h, -- 1319
			q, -- 1319
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 1319
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 1319
		) -- 1319
	end -- 1319
	local i = 0 -- 1321
	do -- 1321
		i = 0 -- 1322
		while i < #self.enemies do -- 1322
			local e = self.enemies[i + 1] -- 1323
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 1324
			self:drawBox( -- 1325
				draw, -- 1325
				w, -- 1325
				h, -- 1325
				e.x - e.w / 2, -- 1325
				e.x + e.w / 2, -- 1325
				e.y, -- 1325
				e.y + e.h, -- 1325
				col -- 1325
			) -- 1325
			i = i + 1 -- 1322
		end -- 1322
	end -- 1322
	local k = 0 -- 1328
	do -- 1328
		k = 0 -- 1329
		while k < #self.room.marks do -- 1329
			do -- 1329
				local m = self.room.marks[k + 1] -- 1330
				if m.kind ~= 0 then -- 1330
					goto __continue261 -- 1332
				end -- 1332
				local on = self.checkpoint == m.x -- 1334
				local x = self:sx(m.x, w) -- 1335
				local y = self:sy(m.y, h) -- 1336
				draw:drawSegment( -- 1337
					Vec2(x, y), -- 1337
					Vec2( -- 1337
						x, -- 1337
						y + self:px(35) -- 1337
					), -- 1337
					self:px(1), -- 1337
					on and CHECK or INK_DIM -- 1337
				) -- 1337
				draw:drawDot( -- 1338
					Vec2( -- 1338
						x, -- 1338
						y + self:px(35) -- 1338
					), -- 1338
					self:px(2), -- 1338
					on and CHECK or INK_DIM -- 1338
				) -- 1338
			end -- 1338
			::__continue261:: -- 1338
			k = k + 1 -- 1329
		end -- 1329
	end -- 1329
	local j = 0 -- 1342
	do -- 1342
		j = 0 -- 1343
		while j < #self.room.marks do -- 1343
			do -- 1343
				local m = self.room.marks[j + 1] -- 1344
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 1344
					goto __continue264 -- 1346
				end -- 1346
				if m.kind == 1 and self.room.key ~= "checkpoint" then -- 1346
					goto __continue264 -- 1349
				end -- 1349
				local col = STAND -- 1351
				if m.kind == 4 then -- 1351
					col = PASS_LINE -- 1353
				elseif m.kind == 5 then -- 1353
					col = BRICK_LINE -- 1355
				end -- 1355
				local mx = self:sx(m.x, w) -- 1357
				local my = self:sy(m.y, h) -- 1358
				draw:drawSegment( -- 1359
					Vec2(mx, my), -- 1359
					Vec2( -- 1359
						mx, -- 1359
						my + self:px(24) -- 1359
					), -- 1359
					self:px(1), -- 1359
					col -- 1359
				) -- 1359
			end -- 1359
			::__continue264:: -- 1359
			j = j + 1 -- 1343
		end -- 1343
	end -- 1343
	if self.room.key == "village" then -- 1343
		self:drawVillage(draw, w, h) -- 1362
	end -- 1362
end -- 1312
function Play.prototype.drawVillage(self, draw, w, h) -- 1367
	local bottle = self.room.bottle -- 1368
	if bottle ~= nil then -- 1368
		self:drawBox( -- 1370
			draw, -- 1370
			w, -- 1370
			h, -- 1370
			bottle.x - 14, -- 1370
			bottle.x + 14, -- 1370
			0, -- 1370
			64, -- 1370
			SOLID_FILL -- 1370
		) -- 1370
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 1370
			self:drawBottle( -- 1372
				draw, -- 1372
				w, -- 1372
				h, -- 1372
				bottle.x, -- 1372
				64 -- 1372
			) -- 1372
		end -- 1372
	end -- 1372
	self:drawBox( -- 1376
		draw, -- 1376
		w, -- 1376
		h, -- 1376
		300, -- 1376
		420, -- 1376
		44, -- 1376
		50, -- 1376
		FLOOR_DECK -- 1376
	) -- 1376
	self:drawBox( -- 1377
		draw, -- 1377
		w, -- 1377
		h, -- 1377
		300, -- 1377
		306, -- 1377
		0, -- 1377
		44, -- 1377
		FLOOR_DECK -- 1377
	) -- 1377
	self:drawBox( -- 1378
		draw, -- 1378
		w, -- 1378
		h, -- 1378
		414, -- 1378
		420, -- 1378
		0, -- 1378
		44, -- 1378
		FLOOR_DECK -- 1378
	) -- 1378
	local s = self.room.scavenger -- 1380
	if s ~= nil then -- 1380
		local sx0 = self.scavX -- 1382
		self:drawBox( -- 1383
			draw, -- 1383
			w, -- 1383
			h, -- 1383
			sx0 - 12, -- 1383
			sx0 + 12, -- 1383
			0, -- 1383
			s.h - 14, -- 1383
			SCAV_BODY -- 1383
		) -- 1383
		self:drawBox( -- 1384
			draw, -- 1384
			w, -- 1384
			h, -- 1384
			sx0 - 7, -- 1384
			sx0 + 7, -- 1384
			s.h - 14, -- 1384
			s.h, -- 1384
			SCAV_HEAD -- 1384
		) -- 1384
		if self.scavState == "turn" then -- 1384
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 1386
			draw:drawSegment( -- 1387
				Vec2( -- 1387
					self:sx(sx0, w), -- 1387
					self:sy(s.h - 6, h) -- 1387
				), -- 1387
				Vec2( -- 1387
					self:sx(fx, w), -- 1387
					self:sy(s.h - 6, h) -- 1387
				), -- 1387
				self:px(1), -- 1387
				INK -- 1387
			) -- 1387
		end -- 1387
	end -- 1387
	if self.hasBottle then -- 1387
		local p = self.player -- 1392
		self:drawBottle( -- 1393
			draw, -- 1393
			w, -- 1393
			h, -- 1393
			p.x + p.facing * 10, -- 1393
			p.y + p.h * 0.62 -- 1393
		) -- 1393
	end -- 1393
	if self.bottleFly ~= nil then -- 1393
		self:drawBottle( -- 1396
			draw, -- 1396
			w, -- 1396
			h, -- 1396
			self.bottleFly.x, -- 1396
			self.bottleFly.y -- 1396
		) -- 1396
	end -- 1396
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 1396
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 1399
		draw:drawCircle( -- 1400
			Vec2( -- 1400
				self:sx(self.bottleLandX, w), -- 1400
				self:sy(0, h) -- 1400
			), -- 1400
			self:px(r / ____exports.UNITS_PER_PX), -- 1400
			BRICK_LINE -- 1400
		) -- 1400
	end -- 1400
end -- 1367
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 1404
	self:drawBox( -- 1405
		draw, -- 1405
		w, -- 1405
		h, -- 1405
		x - 3, -- 1405
		x + 3, -- 1405
		y - 10, -- 1405
		y, -- 1405
		BOTTLE -- 1405
	) -- 1405
end -- 1404
function Play.prototype.drawTrace(self, draw, w, h) -- 1408
	local t = self.trace -- 1409
	if t == nil or self.traceT <= 0 then -- 1409
		return -- 1411
	end -- 1411
	draw:drawSegment( -- 1413
		Vec2( -- 1414
			self:sx(t.x0, w), -- 1414
			self:sy(t.y0, h) -- 1414
		), -- 1414
		Vec2( -- 1415
			self:sx(t.x1, w), -- 1415
			self:sy(t.y1, h) -- 1415
		), -- 1415
		self:px(1), -- 1416
		t.hit and AIM_HIT or INK_DIM -- 1416
	) -- 1416
end -- 1408
function Play.prototype.drawAim(self, draw, w, h) -- 1419
	local v = self.view -- 1421
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 1422
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 1423
	local dot = self:px(1) -- 1424
	local arm = self:px(3) -- 1425
	local gap = self:px(1) -- 1426
	draw:drawSegment( -- 1427
		Vec2(gx - arm - gap, gy), -- 1427
		Vec2(gx - gap, gy), -- 1427
		dot / 2, -- 1427
		AIM -- 1427
	) -- 1427
	draw:drawSegment( -- 1428
		Vec2(gx + gap, gy), -- 1428
		Vec2(gx + arm + gap, gy), -- 1428
		dot / 2, -- 1428
		AIM -- 1428
	) -- 1428
	draw:drawSegment( -- 1429
		Vec2(gx, gy - arm - gap), -- 1429
		Vec2(gx, gy - gap), -- 1429
		dot / 2, -- 1429
		AIM -- 1429
	) -- 1429
	draw:drawSegment( -- 1430
		Vec2(gx, gy + gap), -- 1430
		Vec2(gx, gy + arm + gap), -- 1430
		dot / 2, -- 1430
		AIM -- 1430
	) -- 1430
	if self.room.key == "village" and self.hasBottle then -- 1430
		local p = self.player -- 1434
		local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1435
		local x0 = p.x + p.facing * 10 -- 1436
		local y0 = p.y + p.h * 0.7 -- 1437
		local T = 0.62 -- 1438
		local vx = (aim.x - x0) / T -- 1439
		local vy = (aim.y - y0 + 0.5 * GRAVITY * T * T) / T -- 1440
		local pxr = x0 -- 1441
		local pyr = y0 -- 1442
		local t = 1 -- 1443
		do -- 1443
			t = 1 -- 1444
			while t <= 12 do -- 1444
				local tt = t / 12 * T -- 1445
				local nx = x0 + vx * tt -- 1446
				local ny = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 1447
				draw:drawSegment( -- 1448
					Vec2( -- 1448
						self:sx(pxr, w), -- 1448
						self:sy(pyr, h) -- 1448
					), -- 1448
					Vec2( -- 1448
						self:sx(nx, w), -- 1448
						self:sy(ny, h) -- 1448
					), -- 1448
					self:px(1) / 2, -- 1448
					BOTTLE -- 1448
				) -- 1448
				pxr = nx -- 1449
				pyr = ny -- 1450
				t = t + 1 -- 1444
			end -- 1444
		end -- 1444
	end -- 1444
end -- 1419
return ____exports -- 1419