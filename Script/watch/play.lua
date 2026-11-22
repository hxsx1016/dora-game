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
function makeActor(room, index) -- 1440
	local sp = room.spawns -- 1441
	if index < 0 or index >= #sp then -- 1441
		return { -- 1443
			x = 0, -- 1443
			y = 0, -- 1443
			vx = 0, -- 1443
			vy = 0, -- 1443
			w = CHILD_W, -- 1443
			h = CHILD_H, -- 1443
			onGround = true, -- 1443
			facing = 1, -- 1443
			crouch = false, -- 1443
			rollT = 0, -- 1443
			covered = false, -- 1443
			alive = false -- 1443
		} -- 1443
	end -- 1443
	local s = sp[index + 1] -- 1445
	local child = s.h <= CHILD_H -- 1446
	return { -- 1447
		x = s.x, -- 1448
		y = s.y, -- 1448
		vx = 0, -- 1448
		vy = 0, -- 1448
		w = child and CHILD_W or SOLDIER_W, -- 1449
		h = child and CHILD_H or SOLDIER_H, -- 1450
		onGround = true, -- 1451
		facing = 1, -- 1451
		crouch = false, -- 1451
		rollT = 0, -- 1451
		covered = false, -- 1451
		alive = true -- 1451
	} -- 1451
end -- 1451
function drawFigure(draw, play, w, h, a, body, head) -- 1455
	if not a.alive then -- 1455
		return -- 1457
	end -- 1457
	local x0 = a.x - a.w / 2 -- 1459
	local x1 = a.x + a.w / 2 -- 1460
	local y0 = a.y -- 1461
	local y1 = a.y + a.h -- 1462
	play:drawBox( -- 1463
		draw, -- 1463
		w, -- 1463
		h, -- 1463
		x0, -- 1463
		x1, -- 1463
		y0, -- 1463
		y1 - a.h * 0.26, -- 1463
		body -- 1463
	) -- 1463
	play:drawBox( -- 1464
		draw, -- 1464
		w, -- 1464
		h, -- 1464
		x0 + 2, -- 1464
		x1 - 2, -- 1464
		y1 - a.h * 0.26, -- 1464
		y1, -- 1464
		head -- 1464
	) -- 1464
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 1466
	play:drawBox( -- 1467
		draw, -- 1467
		w, -- 1467
		h, -- 1467
		eyeX, -- 1467
		eyeX + 4, -- 1467
		y1 - a.h * 0.14, -- 1467
		y1 - a.h * 0.08, -- 1467
		INK -- 1467
	) -- 1467
end -- 1467
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 1471
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 1472
end -- 1471
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 1479
	local tmin = 0 -- 1480
	local tmax = 99999 -- 1481
	if dx == 0 then -- 1481
		if ox < x0 or ox > x1 then -- 1481
			return -1 -- 1484
		end -- 1484
	else -- 1484
		local t1 = (x0 - ox) / dx -- 1487
		local t2 = (x1 - ox) / dx -- 1488
		local lo = t1 < t2 and t1 or t2 -- 1489
		local hi = t1 < t2 and t2 or t1 -- 1490
		if lo > tmin then -- 1490
			tmin = lo -- 1492
		end -- 1492
		if hi < tmax then -- 1492
			tmax = hi -- 1495
		end -- 1495
	end -- 1495
	if dy == 0 then -- 1495
		if oy < y0 or oy > y1 then -- 1495
			return -1 -- 1500
		end -- 1500
	else -- 1500
		local t1 = (y0 - oy) / dy -- 1503
		local t2 = (y1 - oy) / dy -- 1504
		local lo = t1 < t2 and t1 or t2 -- 1505
		local hi = t1 < t2 and t2 or t1 -- 1506
		if lo > tmin then -- 1506
			tmin = lo -- 1508
		end -- 1508
		if hi < tmax then -- 1508
			tmax = hi -- 1511
		end -- 1511
	end -- 1511
	return tmax >= tmin and tmin or -1 -- 1514
end -- 1514
function drawCartShape(draw, play, w, h, c, axleX) -- 1517
	local half = c.bodyW / 2 -- 1518
	local x0 = axleX - half -- 1519
	local x1 = axleX + half -- 1520
	play:drawBox( -- 1521
		draw, -- 1521
		w, -- 1521
		h, -- 1521
		x0, -- 1521
		x1, -- 1521
		c.baseY + c.wheelR, -- 1521
		c.baseY + c.wheelR + c.bodyH, -- 1521
		CART_FILL -- 1521
	) -- 1521
	draw:drawCircle( -- 1522
		Vec2( -- 1522
			play:sx(x0 + c.bodyW * 0.28, w), -- 1522
			play:sy(c.baseY + c.wheelR, h) -- 1522
		), -- 1522
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 1522
		Color(52, 50, 48, 255) -- 1522
	) -- 1522
	draw:drawCircle( -- 1523
		Vec2( -- 1523
			play:sx(x1 - c.bodyW * 0.28, w), -- 1523
			play:sy(c.baseY + c.wheelR, h) -- 1523
		), -- 1523
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 1523
		Color(52, 50, 48, 255) -- 1523
	) -- 1523
	local cx = c.clothSide < 0 and x0 or x1 -- 1524
	play:drawBox( -- 1525
		draw, -- 1525
		w, -- 1525
		h, -- 1525
		cx - 10, -- 1525
		cx + 10, -- 1525
		c.baseY + c.wheelR + c.bodyH, -- 1525
		c.baseY + c.wheelR + c.bodyH + 18, -- 1525
		CLOTH -- 1525
	) -- 1525
end -- 1525
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
function ____exports.computeViewport(w, h) -- 137
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 138
	if zoom < 1 then -- 138
		zoom = 1 -- 140
	end -- 140
	return { -- 142
		zoom = zoom, -- 143
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 144
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 145
	} -- 145
end -- 137
____exports.Play = __TS__Class() -- 158
local Play = ____exports.Play -- 158
Play.name = "Play" -- 158
function Play.prototype.____constructor(self, room, resume) -- 231
	self.enemies = {} -- 163
	self.boxes = {} -- 164
	self.floors = {} -- 165
	self.checkpoint = -1 -- 167
	self.flash = "" -- 169
	self.flashT = 0 -- 170
	self.traceT = 0 -- 173
	self.focusCart = false -- 175
	self.knocks = 0 -- 177
	self.knockT = 0 -- 178
	self.cartAxle = 0 -- 182
	self.cartDocked = false -- 184
	self.gripping = false -- 186
	self.gateOpen = false -- 188
	self.calmConsumed = false -- 190
	self.nextDangerId = 1 -- 192
	self.wantRoom = "" -- 194
	self.carryCartAxle = -1 -- 196
	self.carryCartDocked = false -- 197
	self.checkpointCartAxle = -1 -- 199
	self.hasBottle = false -- 203
	self.bottleLandX = -1 -- 207
	self.bottleLandT = 0 -- 208
	self.aimHold = 0 -- 210
	self.scavX = 0 -- 212
	self.scavDir = 1 -- 213
	self.scavState = "patrol" -- 214
	self.scavT = 0 -- 215
	self.scavTargetX = 0 -- 216
	self.passed = false -- 218
	self.paused = false -- 219
	self.ticks = 0 -- 221
	self.view = {zoom = 1, ox = 0, oy = 0} -- 223
	self.aimX = 0 -- 225
	self.aimY = 0 -- 226
	self.viewW = 0 -- 228
	self.viewH = 0 -- 229
	self.room = room -- 232
	self.cam = {x = (room.minX + room.maxX) / 2, y = room.height / 2} -- 233
	self:buildWorld() -- 234
	self.player = makeActor(room, room.key == "checkpoint" and 1 or 0) -- 235
	self.partner = makeActor(room, room.key == "checkpoint" and 0 or -1) -- 236
	self.cam.x = self.player.x -- 237
	self.cam.y = self.player.y + CAM_LOOK_UP -- 238
	self.cartAxle = room.cart.startX -- 239
	self.escort = __TS__New( -- 240
		Escort, -- 240
		safeAnchorX(room.marks) -- 240
	) -- 240
	self.scavX = room.scavenger ~= nil and room.scavenger.x0 or 0 -- 241
	self:buildEnemies() -- 242
	if resume ~= nil and resume.checkpoint > 0 then -- 242
		self.checkpoint = resume.checkpoint -- 245
		if room.key == "outside" and resume.checkpoint >= 380 then -- 245
			self.cartAxle = room.cart.endX -- 247
			self.cartDocked = true -- 248
			self.player.x = 390 -- 249
			self.cam.x = self.player.x -- 250
		end -- 250
	end -- 250
end -- 231
function Play.prototype.buildWorld(self) -- 256
	local room = self.room -- 257
	self.boxes = {} -- 258
	self.floors = {} -- 259
	local i = 0 -- 260
	do -- 260
		i = 0 -- 261
		while i < #room.floors do -- 261
			local f = room.floors[i + 1] -- 262
			local ____self_floors_0 = self.floors -- 262
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 263
			i = i + 1 -- 261
		end -- 261
	end -- 261
	do -- 261
		i = 0 -- 265
		while i < #room.solids do -- 265
			local s = room.solids[i + 1] -- 266
			local ____self_boxes_1 = self.boxes -- 266
			____self_boxes_1[#____self_boxes_1 + 1] = {x0 = s.x, x1 = s.x + s.w, y0 = s.y, y1 = s.y + s.h} -- 267
			i = i + 1 -- 265
		end -- 265
	end -- 265
	do -- 265
		i = 0 -- 269
		while i < #room.stairs do -- 269
			local st = room.stairs[i + 1] -- 270
			local n = st.steps + 1 -- 271
			local stepW = (st.x1 - st.x0) / n -- 272
			local k = 0 -- 273
			do -- 273
				k = 0 -- 274
				while k < n do -- 274
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 275
					local x0 = st.x0 + stepW * k -- 276
					local ____self_boxes_2 = self.boxes -- 276
					____self_boxes_2[#____self_boxes_2 + 1] = {x0 = x0, x1 = x0 + stepW, y0 = -8, y1 = y} -- 277
					k = k + 1 -- 274
				end -- 274
			end -- 274
			i = i + 1 -- 269
		end -- 269
	end -- 269
end -- 256
function Play.prototype.buildEnemies(self) -- 282
	self.enemies = {} -- 283
	if self.room.key ~= "checkpoint" then -- 283
		return -- 285
	end -- 285
	local ____self_enemies_3 = self.enemies -- 285
	____self_enemies_3[#____self_enemies_3 + 1] = { -- 287
		x = 430, -- 287
		y = 0, -- 287
		w = 26, -- 287
		h = 84, -- 287
		alive = true, -- 287
		hitT = 0 -- 287
	} -- 287
	local ____self_enemies_4 = self.enemies -- 287
	____self_enemies_4[#____self_enemies_4 + 1] = { -- 288
		x = 505, -- 288
		y = 0, -- 288
		w = 26, -- 288
		h = 84, -- 288
		alive = true, -- 288
		hitT = 0 -- 288
	} -- 288
end -- 282
function Play.prototype.update(self, dt, input) -- 292
	if input.pause.pressed then -- 292
		self.paused = not self.paused -- 294
	end -- 294
	if self.flashT > 0 then -- 294
		self.flashT = self.flashT - dt -- 297
		if self.flashT <= 0 then -- 297
			self.flash = "" -- 299
		end -- 299
	end -- 299
	if self.traceT > 0 then -- 299
		self.traceT = self.traceT - dt -- 303
		if self.traceT <= 0 then -- 303
			self.trace = nil -- 305
		end -- 305
	end -- 305
	if self.paused then -- 305
		self:updateCamera(dt) -- 309
		return -- 310
	end -- 310
	self.ticks = self.ticks + 1 -- 313
	local p = self.player -- 314
	self:stepPlayer(p, dt, input) -- 315
	self:stepEscort(dt, input) -- 316
	self:stepEnemies(dt) -- 317
	self:stepVillage(dt, input) -- 318
	self:stepInteract(dt, input) -- 319
	self:updateGate() -- 320
	self:updateCamera(dt) -- 321
end -- 292
function Play.prototype.nearLowLedge(self, a) -- 325
	local reach = 26 -- 326
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 327
	local x1 = x0 + reach -- 328
	local i = 0 -- 329
	do -- 329
		i = 0 -- 330
		while i < #self.boxes do -- 330
			do -- 330
				local b = self.boxes[i + 1] -- 331
				if b.x1 <= x0 or b.x0 >= x1 then -- 331
					goto __continue27 -- 333
				end -- 333
				local rise = b.y1 - a.y -- 335
				if rise > 0 and rise <= LEDGE_RISE then -- 335
					return true -- 337
				end -- 337
			end -- 337
			::__continue27:: -- 337
			i = i + 1 -- 330
		end -- 330
	end -- 330
	return false -- 340
end -- 325
function Play.prototype.stepPlayer(self, a, dt, input) -- 343
	if not a.alive then -- 343
		return -- 345
	end -- 345
	local isChild = self.room.key ~= "checkpoint" -- 347
	if not isChild and self.escort.state == "calming" then -- 347
		a.crouch = false -- 350
		a.h = SOLDIER_H -- 351
		a.vx = 0 -- 352
		self:fallY(a, dt) -- 353
		return -- 354
	end -- 354
	a.crouch = isChild and input.crouch.held and a.onGround -- 356
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 357
	a.covered = not isChild and input.cover.held -- 358
	if a.rollT > 0 then -- 358
		a.rollT = a.rollT - dt -- 362
		a.vx = a.facing * ROLL_SPEED -- 363
		self:slideX(a, a.vx * dt) -- 364
		self:fallY(a, dt) -- 365
		if a.rollT <= 0 then -- 365
			self:flashSet("翻滚结束", 0.5) -- 367
		end -- 367
		return -- 369
	end -- 369
	if not isChild and input.jump.pressed and a.onGround then -- 369
		if input.moveX ~= 0 then -- 369
			a.facing = input.moveX > 0 and 1 or -1 -- 374
		end -- 374
		if self:nearLowLedge(a) then -- 374
			a.vy = SOLDIER_JUMP -- 378
			a.onGround = false -- 379
			self:flashSet("翻上去", 0.3) -- 380
			return -- 381
		end -- 381
		a.rollT = ROLL_TIME -- 383
		self:flashSet("翻滚", 0.3) -- 384
		return -- 385
	end -- 385
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 388
	if isChild then -- 388
		if input.cover.held then -- 388
			speed = CHILD_SLOW -- 391
		end -- 391
		if a.crouch then -- 391
			speed = CHILD_SLOW -- 394
		end -- 394
	elseif a.covered then -- 394
		speed = SOLDIER_SPEED * 0.45 -- 397
	end -- 397
	local dir = self.gripping and 0 or input.moveX -- 401
	if dir ~= 0 then -- 401
		a.facing = dir > 0 and 1 or -1 -- 403
	end -- 403
	a.vx = dir * speed -- 405
	if isChild and input.jump.pressed and a.onGround and not a.crouch then -- 405
		a.vy = CHILD_JUMP -- 409
		a.onGround = false -- 410
		self:flashSet("跳", 0.25) -- 411
	end -- 411
	self:slideX(a, a.vx * dt) -- 414
	self:fallY(a, dt) -- 415
	if not isChild and input.fire.pressed then -- 415
		self:shoot(a) -- 419
	end -- 419
end -- 343
function Play.prototype.stepPartner(self, p, dt) -- 424
	local a = self.partner -- 425
	if not a.alive then -- 425
		return -- 427
	end -- 427
	a.crouch = false -- 429
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 430
	a.vx = 0 -- 431
	self:fallY(a, dt) -- 432
end -- 424
function Play.prototype.stepEscort(self, dt, input) -- 439
	local a = self.partner -- 440
	if not a.alive then -- 440
		return -- 442
	end -- 442
	if self.room.key ~= "checkpoint" then -- 442
		a.vx = 0 -- 445
		self:fallY(a, dt) -- 446
		return -- 447
	end -- 447
	local p = self.player -- 449
	local dist = math.abs(p.x - a.x) -- 450
	self.calmConsumed = self.escort:update( -- 451
		input, -- 451
		p.x, -- 451
		p.facing, -- 451
		a.x, -- 451
		dist -- 451
	) -- 451
	a.crouch = self.escort.crouchPose -- 452
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 453
	local dir = self.escort:moveDir(a.x) -- 454
	a.vx = dir * CHILD_SPEED -- 455
	if dir ~= 0 then -- 455
		a.facing = dir -- 457
		local before = a.x -- 458
		self:slideX(a, dir * CHILD_SPEED * dt) -- 459
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 459
			a.vy = CHILD_JUMP -- 462
			a.onGround = false -- 463
		end -- 463
	end -- 463
	self:fallY(a, dt) -- 466
end -- 439
function Play.prototype.updateGate(self) -- 469
	if self.room.key ~= "checkpoint" then -- 469
		self.gateOpen = false -- 471
		return -- 472
	end -- 472
	local function inZone(x) -- 474
		return x >= 792 and x <= 928 -- 474
	end -- 474
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 475
end -- 469
function Play.prototype.stepEnemies(self, dt) -- 478
	local i = 0 -- 479
	do -- 479
		i = 0 -- 480
		while i < #self.enemies do -- 480
			local e = self.enemies[i + 1] -- 481
			if e.hitT > 0 then -- 481
				e.hitT = e.hitT - dt -- 483
			end -- 483
			i = i + 1 -- 480
		end -- 480
	end -- 480
end -- 478
function Play.prototype.stepInteract(self, dt, input) -- 488
	local p = self.player -- 489
	local calmUsed = self.calmConsumed -- 490
	self.calmConsumed = false -- 491
	self.focusCart = false -- 492
	if self.room.key == "outside" then -- 492
		local c = self.room.cart -- 494
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 495
		local dy = p.y - c.baseY -- 496
		self.focusCart = dx * dx + dy * dy < CART_REACH * CART_REACH -- 497
	end -- 497
	self:stepCart(dt, input) -- 499
	if calmUsed then -- 499
		self:flashSet("安抚 · 敲两下", 0.8) -- 503
	elseif input.interact.pressed and not self.gripping and self.room.key ~= "village" then -- 503
		if self.knockT > 0 then -- 503
			self.knocks = self.knocks + 1 -- 506
		else -- 506
			self.knocks = 1 -- 508
		end -- 508
		self.knockT = 1.2 -- 510
		if self.knocks >= 2 then -- 510
			self:flashSet("敲两下", 0.8) -- 512
			self.knocks = 0 -- 513
		else -- 513
			self:flashSet("敲一下", 0.5) -- 515
		end -- 515
	elseif self.knockT > 0 then -- 515
		self.knockT = self.knockT - dt -- 518
		if self.knockT <= 0 then -- 518
			self.knocks = 0 -- 520
		end -- 520
	end -- 520
	local i = 0 -- 525
	do -- 525
		i = 0 -- 526
		while i < #self.room.marks do -- 526
			do -- 526
				local m = self.room.marks[i + 1] -- 527
				if m.kind ~= 0 then -- 527
					goto __continue70 -- 529
				end -- 529
				local subjects = {self.partner, self.player} -- 531
				local k = 0 -- 532
				do -- 532
					k = 0 -- 533
					while k < #subjects do -- 533
						do -- 533
							local s = subjects[k + 1] -- 534
							if not s.alive then -- 534
								goto __continue73 -- 536
							end -- 536
							local dx = s.x - m.x -- 538
							local dy = s.y - m.y -- 539
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 539
								self.checkpoint = m.x -- 541
								self.checkpointCartAxle = self.cartAxle -- 542
								if self.cartDocked then -- 542
									self:flashSet("检查点 · 车已落窝", 1) -- 544
								else -- 544
									self:flashSet("检查点 · 车还没到位", 1) -- 546
								end -- 546
							end -- 546
						end -- 546
						::__continue73:: -- 546
						k = k + 1 -- 533
					end -- 533
				end -- 533
			end -- 533
			::__continue70:: -- 533
			i = i + 1 -- 526
		end -- 526
	end -- 526
	self:checkCarryGate() -- 552
end -- 488
function Play.prototype.stepVillage(self, dt, input) -- 556
	if self.room.key ~= "village" then -- 556
		return -- 558
	end -- 558
	local p = self.player -- 560
	local bottle = self.room.bottle -- 561
	local scav = self.room.scavenger -- 562
	if not self.hasBottle and bottle ~= nil then -- 562
		local dx = p.x - bottle.x -- 566
		local dy = p.y + p.h * 0.5 - bottle.y -- 567
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 567
			self.hasBottle = true -- 569
			self:flashSet("拾起瓶子", 0.8) -- 570
		end -- 570
	end -- 570
	if self.hasBottle then -- 570
		if input.aim.held then -- 570
			self.aimHold = self.aimHold + dt -- 577
			if self.aimHold > 1.2 then -- 577
				self.aimHold = 1.2 -- 579
			end -- 579
		elseif input.aim.released then -- 579
			local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 582
			self:throwBottle(aim.x, aim.y) -- 583
			self.aimHold = 0 -- 584
		end -- 584
	else -- 584
		self.aimHold = 0 -- 587
	end -- 587
	local fly = self.bottleFly -- 591
	if fly ~= nil then -- 591
		fly.vy = fly.vy - GRAVITY * dt -- 593
		fly.x = fly.x + fly.vx * dt -- 594
		fly.y = fly.y + fly.vy * dt -- 595
		local g = self:groundAt(fly.x, fly.y + 4, 3) -- 596
		if fly.y <= g then -- 596
			self.bottleFly = nil -- 598
			self.bottleLandX = fly.x -- 599
			self.bottleLandT = 0.9 -- 600
			self:hearBottle(fly.x) -- 601
		end -- 601
	end -- 601
	if self.bottleLandT > 0 then -- 601
		self.bottleLandT = self.bottleLandT - dt -- 605
	end -- 605
	if scav ~= nil then -- 605
		self:stepScav(dt, scav) -- 609
	end -- 609
	local line = self.room.passLine -- 612
	if line ~= nil and not self.passed and p.x >= line then -- 612
		self.passed = true -- 614
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 615
	end -- 615
end -- 556
function Play.prototype.throwBottle(self, tx, ty) -- 620
	local p = self.player -- 621
	local x0 = p.x + p.facing * 10 -- 622
	local y0 = p.y + p.h * 0.7 -- 623
	local T = 0.62 -- 624
	local vx = (tx - x0) / T -- 625
	local vy = (ty - y0 + 0.5 * GRAVITY * T * T) / T -- 626
	self.bottleFly = {x = x0, y = y0, vx = vx, vy = vy} -- 627
	self.hasBottle = false -- 628
	self:flashSet("投出", 0.4) -- 629
end -- 620
function Play.prototype.hearBottle(self, x) -- 633
	local s = self.room.scavenger -- 634
	if s == nil then -- 634
		return -- 636
	end -- 636
	if math.abs(x - self.scavX) > s.range then -- 636
		self:flashSet("落地 · 他没听见", 0.6) -- 639
		return -- 640
	end -- 640
	self.scavState = "turn" -- 642
	self.scavT = s.hearTicks -- 643
	self.scavTargetX = x -- 644
	self:flashSet("砖地一响 · 他转头", 0.9) -- 645
end -- 633
function Play.prototype.stepScav(self, dt, s) -- 649
	if self.scavState == "turn" then -- 649
		self.scavT = self.scavT - 1 -- 651
		if self.scavT <= 0 then -- 651
			self.scavState = "walk" -- 653
		end -- 653
		return -- 655
	end -- 655
	if self.scavState == "walk" then -- 655
		local d = self.scavTargetX - self.scavX -- 658
		if math.abs(d) < 4 then -- 658
			self.scavState = "stall" -- 660
			self.scavT = s.stallTicks -- 661
			return -- 662
		end -- 662
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 664
		return -- 665
	end -- 665
	if self.scavState == "stall" then -- 665
		self.scavT = self.scavT - 1 -- 668
		if self.scavT <= 0 then -- 668
			self.scavState = "back" -- 670
		end -- 670
		return -- 672
	end -- 672
	if self.scavState == "back" then -- 672
		local home = math.max( -- 675
			s.x0, -- 675
			math.min(s.x1, self.scavX) -- 675
		) -- 675
		if math.abs(home - self.scavX) < 2 then -- 675
			self.scavState = "patrol" -- 677
			return -- 678
		end -- 678
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 680
		return -- 681
	end -- 681
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 683
	if self.scavX >= s.x1 then -- 683
		self.scavX = s.x1 -- 685
		self.scavDir = -1 -- 686
	elseif self.scavX <= s.x0 then -- 686
		self.scavX = s.x0 -- 688
		self.scavDir = 1 -- 689
	end -- 689
end -- 649
function Play.prototype.stepCart(self, dt, input) -- 697
	local p = self.player -- 698
	local c = self.room.cart -- 699
	local handleX = self.cartAxle + c.handleOffset -- 700
	if self.gripping then -- 700
		if not input.interact.held then -- 700
			self.gripping = false -- 704
			self:flashSet("松开车把", 0.4) -- 705
			return -- 706
		end -- 706
	else -- 706
		if not input.interact.pressed then -- 706
			return -- 710
		end -- 710
		if math.abs(p.x - handleX) > CART_REACH or math.abs(p.y - c.baseY) > 40 then -- 710
			return -- 713
		end -- 713
		self.gripping = true -- 715
		self:flashSet("握住车把", 0.4) -- 716
		return -- 717
	end -- 717
	if self.cartDocked then -- 717
		return -- 721
	end -- 721
	local dir = input.moveX -- 723
	if dir == 0 then -- 723
		return -- 725
	end -- 725
	local lo = math.min(c.startX, c.endX) -- 727
	local hi = math.max(c.startX, c.endX) -- 728
	local next = self.cartAxle + dir * CART_SPEED * dt -- 729
	if next < lo then -- 729
		next = lo -- 731
	end -- 731
	if next > hi then -- 731
		next = hi -- 734
	end -- 734
	local delta = next - self.cartAxle -- 736
	if delta == 0 then -- 736
		return -- 738
	end -- 738
	self.cartAxle = next -- 740
	p.x = p.x + delta -- 741
	p.facing = dir > 0 and 1 or -1 -- 742
	self:slideX(p, 0) -- 743
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > CART_REACH then -- 743
		self.gripping = false -- 745
		self:flashSet("跟不上了，脱手", 0.6) -- 746
		return -- 747
	end -- 747
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 747
		self.cartDocked = true -- 750
		self.gripping = false -- 751
		self:flashSet("车轮落窝", 1.2) -- 752
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 752
		self:flashSet("车轮回到起点", 0.5) -- 754
	end -- 754
end -- 697
function Play.prototype.checkCarryGate(self) -- 762
	if self.room.key == "checkpoint" then -- 762
		if self.gateOpen and self.player.x >= 900 then -- 762
			self.carryCartAxle = self.cartAxle -- 765
			self.carryCartDocked = self.cartDocked -- 766
			self.wantRoom = "outside" -- 767
			self:flashSet("过城门 · 城外", 1.2) -- 768
		end -- 768
		return -- 770
	end -- 770
	if self.room.key == "outside" then -- 770
		if self.checkpoint >= 380 and self.player.x >= 388 then -- 770
			self.carryCartAxle = self.cartAxle -- 775
			self.carryCartDocked = self.cartDocked -- 776
			self.wantRoom = "village" -- 777
			self:flashSet("洞后 · 墙根小路", 1.2) -- 778
		end -- 778
	end -- 778
end -- 762
function Play.prototype.shoot(self, a) -- 784
	local ox = a.x + a.facing * 8 -- 785
	local oy = a.y + a.h * 0.72 -- 786
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 788
	local dx = aim.x - ox -- 789
	local dy = aim.y - oy -- 790
	local len = math.sqrt(dx * dx + dy * dy) -- 791
	if len < 0.001 then -- 791
		dx = a.facing -- 793
		dy = 0 -- 794
	else -- 794
		dx = dx / len -- 796
		dy = dy / len -- 797
	end -- 797
	if dx ~= 0 then -- 797
		a.facing = dx > 0 and 1 or -1 -- 800
	end -- 800
	local hitEnemy = self:raycast( -- 803
		ox, -- 803
		oy, -- 803
		dx, -- 803
		dy, -- 803
		true -- 803
	) -- 803
	local hitWall = self:raycast( -- 804
		ox, -- 804
		oy, -- 804
		dx, -- 804
		dy, -- 804
		false -- 804
	) -- 804
	local tEnemy = hitEnemy.t -- 805
	local tWall = hitWall.t -- 806
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 807
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 808
	self.trace = { -- 810
		x0 = ox, -- 810
		y0 = oy, -- 810
		x1 = ox + dx * t, -- 810
		y1 = oy + dy * t, -- 810
		hit = hit -- 810
	} -- 810
	self.traceT = 0.12 -- 811
	self:applyFireDanger(ox) -- 812
	if hit then -- 812
		local i = hitEnemy.index -- 814
		local e = self.enemies[i + 1] -- 815
		e.alive = false -- 816
		e.hitT = 0.4 -- 817
		self:flashSet("命中", 0.6) -- 818
	else -- 818
		self:flashSet("打空", 0.35) -- 820
	end -- 820
end -- 784
function Play.prototype.applyFireDanger(self, shotX) -- 825
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 825
		return -- 827
	end -- 827
	local dangerX = shotX -- 829
	local best = -1 -- 830
	local bestD = 1000000000 -- 831
	local i = 0 -- 832
	do -- 832
		i = 0 -- 833
		while i < #self.enemies do -- 833
			do -- 833
				local e = self.enemies[i + 1] -- 834
				if not e.alive then -- 834
					goto __continue135 -- 836
				end -- 836
				local d = math.abs(e.x - self.partner.x) -- 838
				if d < bestD then -- 838
					bestD = d -- 840
					best = i -- 841
				end -- 841
			end -- 841
			::__continue135:: -- 841
			i = i + 1 -- 833
		end -- 833
	end -- 833
	if best >= 0 then -- 833
		dangerX = self.enemies[best + 1].x -- 845
	end -- 845
	local exposed = self:childExposed(dangerX) -- 847
	local before = self.escort.fear -- 848
	local after = self.escort:applyDanger(self.nextDangerId, exposed, self.partner.x) -- 849
	self.nextDangerId = self.nextDangerId + 1 -- 850
	if after > before then -- 850
		self:flashSet( -- 852
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 852
			1 -- 852
		) -- 852
	elseif not exposed then -- 852
		self:flashSet("枪声没够到她", 0.5) -- 854
	end -- 854
end -- 825
function Play.prototype.childExposed(self, dangerX) -- 859
	local c = self.partner -- 860
	if not c.alive then -- 860
		return false -- 862
	end -- 862
	if c.x > 240 and c.x < 340 then -- 862
		return false -- 865
	end -- 865
	if c.x < 380 or c.x > 560 then -- 865
		return false -- 868
	end -- 868
	local toDanger = dangerX - c.x -- 870
	local toPlayer = self.player.x - c.x -- 871
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) then -- 871
		return false -- 873
	end -- 873
	return true -- 875
end -- 859
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 879
	local best = -1 -- 880
	local bestI = -1 -- 881
	local i = 0 -- 882
	if enemies then -- 882
		do -- 882
			i = 0 -- 884
			while i < #self.enemies do -- 884
				do -- 884
					local e = self.enemies[i + 1] -- 885
					if not e.alive then -- 885
						goto __continue149 -- 887
					end -- 887
					local t = hitBox( -- 889
						ox, -- 889
						oy, -- 889
						dx, -- 889
						dy, -- 889
						e.x - e.w / 2, -- 889
						e.x + e.w / 2, -- 889
						e.y, -- 889
						e.y + e.h -- 889
					) -- 889
					if t >= 0 and (best < 0 or t < best) then -- 889
						best = t -- 891
						bestI = i -- 892
					end -- 892
				end -- 892
				::__continue149:: -- 892
				i = i + 1 -- 884
			end -- 884
		end -- 884
		return {t = best, index = bestI} -- 895
	end -- 895
	do -- 895
		i = 0 -- 897
		while i < #self.boxes do -- 897
			local b = self.boxes[i + 1] -- 898
			local t = hitBox( -- 899
				ox, -- 899
				oy, -- 899
				dx, -- 899
				dy, -- 899
				b.x0, -- 899
				b.x1, -- 899
				b.y0, -- 899
				b.y1 -- 899
			) -- 899
			if t >= 0 and (best < 0 or t < best) then -- 899
				best = t -- 901
			end -- 901
			i = i + 1 -- 897
		end -- 897
	end -- 897
	if dy < 0 then -- 897
		local t = (0 - oy) / dy -- 906
		if t >= 0 and (best < 0 or t < best) then -- 906
			best = t -- 908
		end -- 908
	end -- 908
	return {t = best, index = -1} -- 911
end -- 879
function Play.prototype.slideX(self, a, dx) -- 915
	local nx = a.x + dx -- 916
	local half = a.w / 2 -- 917
	local room = self.room -- 918
	nx = math.max( -- 919
		room.minX + half, -- 919
		math.min(room.maxX - half, nx) -- 919
	) -- 919
	local i = 0 -- 920
	do -- 920
		i = 0 -- 921
		while i < #self.boxes do -- 921
			do -- 921
				local b = self.boxes[i + 1] -- 922
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 922
					goto __continue159 -- 924
				end -- 924
				if nx + half > b.x0 and nx - half < b.x1 then -- 924
					if a.x <= b.x0 then -- 924
						nx = b.x0 - half -- 928
					elseif a.x >= b.x1 then -- 928
						nx = b.x1 + half -- 930
					else -- 930
						nx = a.x -- 932
					end -- 932
				end -- 932
			end -- 932
			::__continue159:: -- 932
			i = i + 1 -- 921
		end -- 921
	end -- 921
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 921
		local bx0 = self.cartAxle - CART_HALF -- 938
		local bx1 = self.cartAxle + CART_HALF -- 939
		if nx + half > bx0 and nx - half < bx1 then -- 939
			if a.x <= bx0 then -- 939
				nx = bx0 - half -- 942
			elseif a.x >= bx1 then -- 942
				nx = bx1 + half -- 944
			else -- 944
				nx = a.x -- 946
			end -- 946
		end -- 946
	end -- 946
	local arch = room.arch -- 953
	if arch.h > 0 and a.y + a.h > arch.y + arch.h + 0.001 then -- 953
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 955
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 955
			if a.x <= arch.x0 then -- 955
				nx = arch.x0 - half -- 958
			elseif a.x >= arch.x1 then -- 958
				nx = arch.x1 + half -- 960
			end -- 960
		end -- 960
	end -- 960
	a.x = nx -- 964
end -- 915
function Play.prototype.fallY(self, a, dt) -- 968
	a.vy = a.vy - GRAVITY * dt -- 969
	if a.vy < -900 then -- 969
		a.vy = -900 -- 971
	end -- 971
	local ny = a.y + a.vy * dt -- 973
	local half = a.w / 2 -- 974
	if a.vy <= 0 then -- 974
		local ground = self:groundAt(a.x, a.y + 0.5, half) -- 976
		if ny <= ground then -- 976
			ny = ground -- 978
			a.vy = 0 -- 979
			a.onGround = true -- 980
		else -- 980
			a.onGround = false -- 982
		end -- 982
	else -- 982
		a.onGround = false -- 985
		local i = 0 -- 986
		do -- 986
			i = 0 -- 987
			while i < #self.boxes do -- 987
				do -- 987
					local b = self.boxes[i + 1] -- 988
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 988
						goto __continue181 -- 990
					end -- 990
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 990
						ny = b.y0 - a.h -- 993
						a.vy = 0 -- 994
					end -- 994
				end -- 994
				::__continue181:: -- 994
				i = i + 1 -- 987
			end -- 987
		end -- 987
	end -- 987
	a.y = ny -- 998
end -- 968
function Play.prototype.groundAt(self, x, ceiling, half) -- 1002
	local g = -9999 -- 1003
	local i = 0 -- 1004
	do -- 1004
		i = 0 -- 1005
		while i < #self.floors do -- 1005
			local f = self.floors[i + 1] -- 1006
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 1006
				g = f.y1 -- 1008
			end -- 1008
			i = i + 1 -- 1005
		end -- 1005
	end -- 1005
	do -- 1005
		i = 0 -- 1011
		while i < #self.boxes do -- 1011
			local b = self.boxes[i + 1] -- 1012
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 1012
				g = b.y1 -- 1014
			end -- 1014
			i = i + 1 -- 1011
		end -- 1011
	end -- 1011
	return g -- 1017
end -- 1002
function Play.prototype.updateCamera(self, dt) -- 1020
	local p = self.player -- 1021
	local tx = p.x + p.facing * 30 -- 1022
	local ty = p.y + CAM_LOOK_UP -- 1023
	local k = math.min(1, CAM_FOLLOW * dt) -- 1024
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 1025
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 1026
end -- 1020
function Play.prototype.clampCamera(self, w, h) -- 1030
	local room = self.room -- 1031
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 1032
	local spanX = room.maxX - room.minX -- 1033
	if spanX <= halfW * 2 then -- 1033
		self.cam.x = (room.minX + room.maxX) / 2 -- 1035
	else -- 1035
		self.cam.x = math.max( -- 1037
			room.minX + halfW, -- 1037
			math.min(room.maxX - halfW, self.cam.x) -- 1037
		) -- 1037
	end -- 1037
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 1040
	local spanY = room.height -- 1041
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 1042
	if spanY <= halfH * 2 then -- 1042
		self.cam.y = camY -- 1044
	else -- 1044
		self.cam.y = math.max( -- 1046
			camY, -- 1046
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 1046
		) -- 1046
	end -- 1046
end -- 1030
function Play.prototype.flashSet(self, text, t) -- 1050
	self.flash = text -- 1051
	self.flashT = t -- 1052
end -- 1050
function Play.prototype.statusText(self) -- 1056
	local p = self.player -- 1057
	local parts = {} -- 1058
	if self.room.key == "village" then -- 1058
		parts[#parts + 1] = (("小满 x=" .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 1060
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1061
		if self.hasBottle then -- 1061
			parts[#parts + 1] = "有瓶" -- 1063
		elseif self.bottleFly ~= nil then -- 1063
			parts[#parts + 1] = "瓶在飞" -- 1065
		else -- 1065
			parts[#parts + 1] = "空手" -- 1067
		end -- 1067
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 1069
		if self.passed then -- 1069
			parts[#parts + 1] = "已过通行线" -- 1071
		end -- 1071
		if self.paused then -- 1071
			parts[#parts + 1] = "已暂停" -- 1074
		end -- 1074
		return table.concat(parts, " · ") -- 1076
	end -- 1076
	local isChild = self.room.key ~= "checkpoint" -- 1079
	local who = isChild and "小满" or "周戍" -- 1080
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 1081
	if isChild then -- 1081
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1083
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 1084
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1085
	else -- 1085
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 1087
		if p.rollT > 0 then -- 1087
			parts[#parts + 1] = "翻滚中" -- 1089
		end -- 1089
		local alive = 0 -- 1091
		local i = 0 -- 1092
		do -- 1092
			i = 0 -- 1093
			while i < #self.enemies do -- 1093
				if self.enemies[i + 1].alive then -- 1093
					alive = alive + 1 -- 1095
				end -- 1095
				i = i + 1 -- 1093
			end -- 1093
		end -- 1093
		parts[#parts + 1] = (("敌 " .. tostring(alive)) .. "/") .. tostring(#self.enemies) -- 1098
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1099
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 1100
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 1101
	end -- 1101
	if self.checkpoint >= 0 then -- 1101
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 1104
	end -- 1104
	if self.paused then -- 1104
		parts[#parts + 1] = "已暂停" -- 1107
	end -- 1107
	return table.concat(parts, " · ") -- 1109
end -- 1056
function Play.prototype.scavLabel(self) -- 1113
	if self.scavState == "turn" then -- 1113
		return "转头" -- 1115
	end -- 1115
	if self.scavState == "walk" then -- 1115
		return "赶来" -- 1118
	end -- 1118
	if self.scavState == "stall" then -- 1118
		return "停住" -- 1121
	end -- 1121
	if self.scavState == "back" then -- 1121
		return "回位" -- 1124
	end -- 1124
	return "巡逻" -- 1126
end -- 1113
function Play.prototype.hintText(self) -- 1130
	if self.paused then -- 1130
		return "Esc 继续 · R 重置" -- 1132
	end -- 1132
	if self.flash ~= "" then -- 1132
		return self.flash -- 1135
	end -- 1135
	if self.room.key == "village" then -- 1135
		if self.bottleFly ~= nil then -- 1135
			return "等瓶子落地 · 触地才发声" -- 1139
		end -- 1139
		if self.hasBottle then -- 1139
			return "按住 F 瞄，松手投 · 往右投到砖地 608，他才会走开" -- 1142
		end -- 1142
		if self.passed then -- 1142
			return "已过第一院 · R 重置可再来一遍" -- 1145
		end -- 1145
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 1147
	end -- 1147
	if self.room.key == "outside" then -- 1147
		if self.focusCart then -- 1147
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 1151
		end -- 1151
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 1153
	end -- 1153
	if self.escort.state == "frozen" then -- 1153
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 1153
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 1157
		end -- 1157
		return "小满吓住了 · 走过去，靠近再点 E" -- 1159
	end -- 1159
	if self.escort.state == "calming" then -- 1159
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 1162
	end -- 1162
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 1164
end -- 1130
function Play.prototype.draw(self, draw, w, h) -- 1169
	self.viewW = w -- 1170
	self.viewH = h -- 1171
	self.view = ____exports.computeViewport(w, h) -- 1172
	self:clampCamera(w, h) -- 1173
	draw:clear() -- 1174
	draw:drawRect( -- 1176
		Rect(0, 0, w, h), -- 1176
		BG_VOID -- 1176
	) -- 1176
	local box = self:canvasRect(w, h) -- 1177
	draw:drawRect(box, BG_FAR) -- 1178
	draw:drawRect( -- 1179
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 1179
		BG_MID -- 1179
	) -- 1179
	self:drawFloors(draw, w, h) -- 1181
	self:drawSolids(draw, w, h) -- 1182
	self:drawZones(draw, w, h) -- 1183
	self:drawArch(draw, w, h) -- 1184
	self:drawCart(draw, w, h) -- 1185
	self:drawActors(draw, w, h) -- 1186
	self:drawTrace(draw, w, h) -- 1187
	self:drawAim(draw, w, h) -- 1188
end -- 1169
function Play.prototype.canvasRect(self, w, h) -- 1192
	local v = self.view -- 1193
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 1194
end -- 1192
function Play.prototype.px(self, n) -- 1198
	return n * self.view.zoom -- 1199
end -- 1198
function Play.prototype.sx(self, wx, w) -- 1203
	local v = self.view -- 1204
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 1205
	return v.ox + lx * v.zoom -- 1206
end -- 1203
function Play.prototype.sy(self, wy, h) -- 1210
	local v = self.view -- 1211
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 1212
	return v.oy + ly * v.zoom -- 1213
end -- 1210
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 1216
	local px0 = self:sx(x0, w) -- 1217
	local px1 = self:sx(x1, w) -- 1218
	local py0 = self:sy(y0, h) -- 1219
	local py1 = self:sy(y1, h) -- 1220
	if px1 <= px0 or py1 <= py0 then -- 1220
		return -- 1222
	end -- 1222
	draw:drawRect( -- 1224
		Rect(px0, py0, px1 - px0, py1 - py0), -- 1224
		color -- 1224
	) -- 1224
end -- 1216
function Play.prototype.drawFloors(self, draw, w, h) -- 1227
	local i = 0 -- 1228
	do -- 1228
		i = 0 -- 1229
		while i < #self.room.floors do -- 1229
			local f = self.room.floors[i + 1] -- 1230
			local y = self:sy(f.y, h) -- 1231
			local x0 = self:sx(f.x0, w) -- 1232
			local x1 = self:sx(f.x1, w) -- 1233
			local deck = self:px(5) -- 1234
			draw:drawRect( -- 1235
				Rect(x0, y - deck, x1 - x0, deck), -- 1235
				FLOOR_DECK -- 1235
			) -- 1235
			draw:drawSegment( -- 1236
				Vec2(x0, y), -- 1236
				Vec2(x1, y), -- 1236
				self:px(1), -- 1236
				GROUND -- 1236
			) -- 1236
			i = i + 1 -- 1229
		end -- 1229
	end -- 1229
end -- 1227
function Play.prototype.drawSolids(self, draw, w, h) -- 1240
	local i = 0 -- 1241
	do -- 1241
		i = 0 -- 1242
		while i < #self.boxes do -- 1242
			do -- 1242
				local b = self.boxes[i + 1] -- 1243
				if b.y0 < -4 and b.y1 <= 96 then -- 1243
					draw:drawSegment( -- 1246
						Vec2( -- 1246
							self:sx(b.x0, w), -- 1246
							self:sy(b.y1, h) -- 1246
						), -- 1246
						Vec2( -- 1246
							self:sx(b.x1, w), -- 1246
							self:sy(b.y1, h) -- 1246
						), -- 1246
						self:px(1), -- 1246
						GROUND -- 1246
					) -- 1246
					goto __continue242 -- 1247
				end -- 1247
				self:drawBox( -- 1249
					draw, -- 1249
					w, -- 1249
					h, -- 1249
					b.x0, -- 1249
					b.x1, -- 1249
					b.y0, -- 1249
					b.y1, -- 1249
					SOLID_FILL -- 1249
				) -- 1249
				draw:drawSegment( -- 1250
					Vec2( -- 1250
						self:sx(b.x0, w), -- 1250
						self:sy(b.y1, h) -- 1250
					), -- 1250
					Vec2( -- 1250
						self:sx(b.x1, w), -- 1250
						self:sy(b.y1, h) -- 1250
					), -- 1250
					self:px(1), -- 1250
					SOLID_EDGE -- 1250
				) -- 1250
			end -- 1250
			::__continue242:: -- 1250
			i = i + 1 -- 1242
		end -- 1242
	end -- 1242
end -- 1240
function Play.prototype.drawZones(self, draw, w, h) -- 1254
	local i = 0 -- 1255
	do -- 1255
		i = 0 -- 1256
		while i < #self.room.zones do -- 1256
			local z = self.room.zones[i + 1] -- 1257
			local fill = DANGER -- 1258
			local line = DANGER_LINE -- 1259
			if z.tint == 2 then -- 1259
				fill = SOFT -- 1261
				line = SOFT_LINE -- 1262
			elseif z.tint == 3 then -- 1262
				fill = BRICK -- 1264
				line = BRICK_LINE -- 1265
			elseif z.tint == 4 then -- 1265
				fill = PASS -- 1267
				line = PASS_LINE -- 1268
			end -- 1268
			self:drawBox( -- 1270
				draw, -- 1270
				w, -- 1270
				h, -- 1270
				z.x0, -- 1270
				z.x1, -- 1270
				z.y, -- 1270
				z.y + z.h, -- 1270
				fill -- 1270
			) -- 1270
			draw:drawSegment( -- 1271
				Vec2( -- 1271
					self:sx(z.x0, w), -- 1271
					self:sy(z.y, h) -- 1271
				), -- 1271
				Vec2( -- 1271
					self:sx(z.x0, w), -- 1271
					self:sy(z.y + z.h, h) -- 1271
				), -- 1271
				self:px(1), -- 1271
				line -- 1271
			) -- 1271
			draw:drawSegment( -- 1272
				Vec2( -- 1272
					self:sx(z.x1, w), -- 1272
					self:sy(z.y, h) -- 1272
				), -- 1272
				Vec2( -- 1272
					self:sx(z.x1, w), -- 1272
					self:sy(z.y + z.h, h) -- 1272
				), -- 1272
				self:px(1), -- 1272
				line -- 1272
			) -- 1272
			i = i + 1 -- 1256
		end -- 1256
	end -- 1256
end -- 1254
function Play.prototype.drawArch(self, draw, w, h) -- 1276
	local a = self.room.arch -- 1277
	if a.h <= 0 then -- 1277
		return -- 1279
	end -- 1279
	self:drawBox( -- 1281
		draw, -- 1281
		w, -- 1281
		h, -- 1281
		a.x0, -- 1281
		a.x1, -- 1281
		a.y, -- 1281
		a.y + a.h, -- 1281
		HOLE_FILL -- 1281
	) -- 1281
	draw:drawSegment( -- 1282
		Vec2( -- 1282
			self:sx(a.x0, w), -- 1282
			self:sy(a.y + a.h, h) -- 1282
		), -- 1282
		Vec2( -- 1282
			self:sx(a.x1, w), -- 1282
			self:sy(a.y + a.h, h) -- 1282
		), -- 1282
		self:px(1), -- 1282
		SOLID_EDGE -- 1282
	) -- 1282
	draw:drawSegment( -- 1283
		Vec2( -- 1283
			self:sx(a.x0, w), -- 1283
			self:sy(a.y, h) -- 1283
		), -- 1283
		Vec2( -- 1283
			self:sx(a.x0, w), -- 1283
			self:sy(a.y + a.h, h) -- 1283
		), -- 1283
		self:px(1), -- 1283
		SOLID_EDGE -- 1283
	) -- 1283
	draw:drawSegment( -- 1284
		Vec2( -- 1284
			self:sx(a.x1, w), -- 1284
			self:sy(a.y, h) -- 1284
		), -- 1284
		Vec2( -- 1284
			self:sx(a.x1, w), -- 1284
			self:sy(a.y + a.h, h) -- 1284
		), -- 1284
		self:px(1), -- 1284
		SOLID_EDGE -- 1284
	) -- 1284
end -- 1276
function Play.prototype.drawCart(self, draw, w, h) -- 1287
	local c = self.room.cart -- 1288
	if c.bodyW <= 0 then -- 1288
		return -- 1290
	end -- 1290
	drawCartShape( -- 1292
		draw, -- 1292
		self, -- 1292
		w, -- 1292
		h, -- 1292
		c, -- 1292
		self.cartAxle -- 1292
	) -- 1292
	draw:drawRect( -- 1293
		Rect( -- 1293
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 1293
			self:sy(c.baseY + 40, h), -- 1293
			self:px(2), -- 1293
			self:px(40) -- 1293
		), -- 1293
		STAND -- 1293
	) -- 1293
end -- 1287
function Play.prototype.drawActors(self, draw, w, h) -- 1296
	local p = self.player -- 1297
	local isChild = self.room.key ~= "checkpoint" -- 1298
	drawFigure( -- 1299
		draw, -- 1299
		self, -- 1299
		w, -- 1299
		h, -- 1299
		p, -- 1299
		isChild and CHILD_BODY or SOLDIER_BODY, -- 1299
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 1299
	) -- 1299
	local q = self.partner -- 1300
	if q.alive then -- 1300
		local childPartner = q.w == CHILD_W -- 1302
		drawFigure( -- 1303
			draw, -- 1303
			self, -- 1303
			w, -- 1303
			h, -- 1303
			q, -- 1303
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 1303
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 1303
		) -- 1303
	end -- 1303
	local i = 0 -- 1305
	do -- 1305
		i = 0 -- 1306
		while i < #self.enemies do -- 1306
			local e = self.enemies[i + 1] -- 1307
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 1308
			self:drawBox( -- 1309
				draw, -- 1309
				w, -- 1309
				h, -- 1309
				e.x - e.w / 2, -- 1309
				e.x + e.w / 2, -- 1309
				e.y, -- 1309
				e.y + e.h, -- 1309
				col -- 1309
			) -- 1309
			i = i + 1 -- 1306
		end -- 1306
	end -- 1306
	local k = 0 -- 1312
	do -- 1312
		k = 0 -- 1313
		while k < #self.room.marks do -- 1313
			do -- 1313
				local m = self.room.marks[k + 1] -- 1314
				if m.kind ~= 0 then -- 1314
					goto __continue259 -- 1316
				end -- 1316
				local on = self.checkpoint == m.x -- 1318
				local x = self:sx(m.x, w) -- 1319
				local y = self:sy(m.y, h) -- 1320
				draw:drawSegment( -- 1321
					Vec2(x, y), -- 1321
					Vec2( -- 1321
						x, -- 1321
						y + self:px(35) -- 1321
					), -- 1321
					self:px(1), -- 1321
					on and CHECK or INK_DIM -- 1321
				) -- 1321
				draw:drawDot( -- 1322
					Vec2( -- 1322
						x, -- 1322
						y + self:px(35) -- 1322
					), -- 1322
					self:px(2), -- 1322
					on and CHECK or INK_DIM -- 1322
				) -- 1322
			end -- 1322
			::__continue259:: -- 1322
			k = k + 1 -- 1313
		end -- 1313
	end -- 1313
	local j = 0 -- 1326
	do -- 1326
		j = 0 -- 1327
		while j < #self.room.marks do -- 1327
			do -- 1327
				local m = self.room.marks[j + 1] -- 1328
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 1328
					goto __continue262 -- 1330
				end -- 1330
				if m.kind == 1 and self.room.key ~= "checkpoint" then -- 1330
					goto __continue262 -- 1333
				end -- 1333
				local col = STAND -- 1335
				if m.kind == 4 then -- 1335
					col = PASS_LINE -- 1337
				elseif m.kind == 5 then -- 1337
					col = BRICK_LINE -- 1339
				end -- 1339
				local mx = self:sx(m.x, w) -- 1341
				local my = self:sy(m.y, h) -- 1342
				draw:drawSegment( -- 1343
					Vec2(mx, my), -- 1343
					Vec2( -- 1343
						mx, -- 1343
						my + self:px(24) -- 1343
					), -- 1343
					self:px(1), -- 1343
					col -- 1343
				) -- 1343
			end -- 1343
			::__continue262:: -- 1343
			j = j + 1 -- 1327
		end -- 1327
	end -- 1327
	if self.room.key == "village" then -- 1327
		self:drawVillage(draw, w, h) -- 1346
	end -- 1346
end -- 1296
function Play.prototype.drawVillage(self, draw, w, h) -- 1351
	local bottle = self.room.bottle -- 1352
	if bottle ~= nil then -- 1352
		self:drawBox( -- 1354
			draw, -- 1354
			w, -- 1354
			h, -- 1354
			bottle.x - 14, -- 1354
			bottle.x + 14, -- 1354
			0, -- 1354
			64, -- 1354
			SOLID_FILL -- 1354
		) -- 1354
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 1354
			self:drawBottle( -- 1356
				draw, -- 1356
				w, -- 1356
				h, -- 1356
				bottle.x, -- 1356
				64 -- 1356
			) -- 1356
		end -- 1356
	end -- 1356
	self:drawBox( -- 1360
		draw, -- 1360
		w, -- 1360
		h, -- 1360
		300, -- 1360
		420, -- 1360
		44, -- 1360
		50, -- 1360
		FLOOR_DECK -- 1360
	) -- 1360
	self:drawBox( -- 1361
		draw, -- 1361
		w, -- 1361
		h, -- 1361
		300, -- 1361
		306, -- 1361
		0, -- 1361
		44, -- 1361
		FLOOR_DECK -- 1361
	) -- 1361
	self:drawBox( -- 1362
		draw, -- 1362
		w, -- 1362
		h, -- 1362
		414, -- 1362
		420, -- 1362
		0, -- 1362
		44, -- 1362
		FLOOR_DECK -- 1362
	) -- 1362
	local s = self.room.scavenger -- 1364
	if s ~= nil then -- 1364
		local sx0 = self.scavX -- 1366
		self:drawBox( -- 1367
			draw, -- 1367
			w, -- 1367
			h, -- 1367
			sx0 - 12, -- 1367
			sx0 + 12, -- 1367
			0, -- 1367
			s.h - 14, -- 1367
			SCAV_BODY -- 1367
		) -- 1367
		self:drawBox( -- 1368
			draw, -- 1368
			w, -- 1368
			h, -- 1368
			sx0 - 7, -- 1368
			sx0 + 7, -- 1368
			s.h - 14, -- 1368
			s.h, -- 1368
			SCAV_HEAD -- 1368
		) -- 1368
		if self.scavState == "turn" then -- 1368
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 1370
			draw:drawSegment( -- 1371
				Vec2( -- 1371
					self:sx(sx0, w), -- 1371
					self:sy(s.h - 6, h) -- 1371
				), -- 1371
				Vec2( -- 1371
					self:sx(fx, w), -- 1371
					self:sy(s.h - 6, h) -- 1371
				), -- 1371
				self:px(1), -- 1371
				INK -- 1371
			) -- 1371
		end -- 1371
	end -- 1371
	if self.hasBottle then -- 1371
		local p = self.player -- 1376
		self:drawBottle( -- 1377
			draw, -- 1377
			w, -- 1377
			h, -- 1377
			p.x + p.facing * 10, -- 1377
			p.y + p.h * 0.62 -- 1377
		) -- 1377
	end -- 1377
	if self.bottleFly ~= nil then -- 1377
		self:drawBottle( -- 1380
			draw, -- 1380
			w, -- 1380
			h, -- 1380
			self.bottleFly.x, -- 1380
			self.bottleFly.y -- 1380
		) -- 1380
	end -- 1380
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 1380
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 1383
		draw:drawCircle( -- 1384
			Vec2( -- 1384
				self:sx(self.bottleLandX, w), -- 1384
				self:sy(0, h) -- 1384
			), -- 1384
			self:px(r / ____exports.UNITS_PER_PX), -- 1384
			BRICK_LINE -- 1384
		) -- 1384
	end -- 1384
end -- 1351
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 1388
	self:drawBox( -- 1389
		draw, -- 1389
		w, -- 1389
		h, -- 1389
		x - 3, -- 1389
		x + 3, -- 1389
		y - 10, -- 1389
		y, -- 1389
		BOTTLE -- 1389
	) -- 1389
end -- 1388
function Play.prototype.drawTrace(self, draw, w, h) -- 1392
	local t = self.trace -- 1393
	if t == nil or self.traceT <= 0 then -- 1393
		return -- 1395
	end -- 1395
	draw:drawSegment( -- 1397
		Vec2( -- 1398
			self:sx(t.x0, w), -- 1398
			self:sy(t.y0, h) -- 1398
		), -- 1398
		Vec2( -- 1399
			self:sx(t.x1, w), -- 1399
			self:sy(t.y1, h) -- 1399
		), -- 1399
		self:px(1), -- 1400
		t.hit and AIM_HIT or INK_DIM -- 1400
	) -- 1400
end -- 1392
function Play.prototype.drawAim(self, draw, w, h) -- 1403
	local v = self.view -- 1405
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 1406
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 1407
	local dot = self:px(1) -- 1408
	local arm = self:px(3) -- 1409
	local gap = self:px(1) -- 1410
	draw:drawSegment( -- 1411
		Vec2(gx - arm - gap, gy), -- 1411
		Vec2(gx - gap, gy), -- 1411
		dot / 2, -- 1411
		AIM -- 1411
	) -- 1411
	draw:drawSegment( -- 1412
		Vec2(gx + gap, gy), -- 1412
		Vec2(gx + arm + gap, gy), -- 1412
		dot / 2, -- 1412
		AIM -- 1412
	) -- 1412
	draw:drawSegment( -- 1413
		Vec2(gx, gy - arm - gap), -- 1413
		Vec2(gx, gy - gap), -- 1413
		dot / 2, -- 1413
		AIM -- 1413
	) -- 1413
	draw:drawSegment( -- 1414
		Vec2(gx, gy + gap), -- 1414
		Vec2(gx, gy + arm + gap), -- 1414
		dot / 2, -- 1414
		AIM -- 1414
	) -- 1414
	if self.room.key == "village" and self.hasBottle then -- 1414
		local p = self.player -- 1418
		local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1419
		local x0 = p.x + p.facing * 10 -- 1420
		local y0 = p.y + p.h * 0.7 -- 1421
		local T = 0.62 -- 1422
		local vx = (aim.x - x0) / T -- 1423
		local vy = (aim.y - y0 + 0.5 * GRAVITY * T * T) / T -- 1424
		local pxr = x0 -- 1425
		local pyr = y0 -- 1426
		local t = 1 -- 1427
		do -- 1427
			t = 1 -- 1428
			while t <= 12 do -- 1428
				local tt = t / 12 * T -- 1429
				local nx = x0 + vx * tt -- 1430
				local ny = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 1431
				draw:drawSegment( -- 1432
					Vec2( -- 1432
						self:sx(pxr, w), -- 1432
						self:sy(pyr, h) -- 1432
					), -- 1432
					Vec2( -- 1432
						self:sx(nx, w), -- 1432
						self:sy(ny, h) -- 1432
					), -- 1432
					self:px(1) / 2, -- 1432
					BOTTLE -- 1432
				) -- 1432
				pxr = nx -- 1433
				pyr = ny -- 1434
				t = t + 1 -- 1428
			end -- 1428
		end -- 1428
	end -- 1428
end -- 1403
return ____exports -- 1403