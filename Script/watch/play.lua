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
function makeActor(room, index) -- 1405
	local sp = room.spawns -- 1406
	if index < 0 or index >= #sp then -- 1406
		return { -- 1408
			x = 0, -- 1408
			y = 0, -- 1408
			vx = 0, -- 1408
			vy = 0, -- 1408
			w = CHILD_W, -- 1408
			h = CHILD_H, -- 1408
			onGround = true, -- 1408
			facing = 1, -- 1408
			crouch = false, -- 1408
			rollT = 0, -- 1408
			covered = false, -- 1408
			alive = false -- 1408
		} -- 1408
	end -- 1408
	local s = sp[index + 1] -- 1410
	local child = s.h <= CHILD_H -- 1411
	return { -- 1412
		x = s.x, -- 1413
		y = s.y, -- 1413
		vx = 0, -- 1413
		vy = 0, -- 1413
		w = child and CHILD_W or SOLDIER_W, -- 1414
		h = child and CHILD_H or SOLDIER_H, -- 1415
		onGround = true, -- 1416
		facing = 1, -- 1416
		crouch = false, -- 1416
		rollT = 0, -- 1416
		covered = false, -- 1416
		alive = true -- 1416
	} -- 1416
end -- 1416
function drawFigure(draw, play, w, h, a, body, head) -- 1420
	if not a.alive then -- 1420
		return -- 1422
	end -- 1422
	local x0 = a.x - a.w / 2 -- 1424
	local x1 = a.x + a.w / 2 -- 1425
	local y0 = a.y -- 1426
	local y1 = a.y + a.h -- 1427
	play:drawBox( -- 1428
		draw, -- 1428
		w, -- 1428
		h, -- 1428
		x0, -- 1428
		x1, -- 1428
		y0, -- 1428
		y1 - a.h * 0.26, -- 1428
		body -- 1428
	) -- 1428
	play:drawBox( -- 1429
		draw, -- 1429
		w, -- 1429
		h, -- 1429
		x0 + 2, -- 1429
		x1 - 2, -- 1429
		y1 - a.h * 0.26, -- 1429
		y1, -- 1429
		head -- 1429
	) -- 1429
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 1431
	play:drawBox( -- 1432
		draw, -- 1432
		w, -- 1432
		h, -- 1432
		eyeX, -- 1432
		eyeX + 4, -- 1432
		y1 - a.h * 0.14, -- 1432
		y1 - a.h * 0.08, -- 1432
		INK -- 1432
	) -- 1432
end -- 1432
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 1436
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 1437
end -- 1436
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 1444
	local tmin = 0 -- 1445
	local tmax = 99999 -- 1446
	if dx == 0 then -- 1446
		if ox < x0 or ox > x1 then -- 1446
			return -1 -- 1449
		end -- 1449
	else -- 1449
		local t1 = (x0 - ox) / dx -- 1452
		local t2 = (x1 - ox) / dx -- 1453
		local lo = t1 < t2 and t1 or t2 -- 1454
		local hi = t1 < t2 and t2 or t1 -- 1455
		if lo > tmin then -- 1455
			tmin = lo -- 1457
		end -- 1457
		if hi < tmax then -- 1457
			tmax = hi -- 1460
		end -- 1460
	end -- 1460
	if dy == 0 then -- 1460
		if oy < y0 or oy > y1 then -- 1460
			return -1 -- 1465
		end -- 1465
	else -- 1465
		local t1 = (y0 - oy) / dy -- 1468
		local t2 = (y1 - oy) / dy -- 1469
		local lo = t1 < t2 and t1 or t2 -- 1470
		local hi = t1 < t2 and t2 or t1 -- 1471
		if lo > tmin then -- 1471
			tmin = lo -- 1473
		end -- 1473
		if hi < tmax then -- 1473
			tmax = hi -- 1476
		end -- 1476
	end -- 1476
	return tmax >= tmin and tmin or -1 -- 1479
end -- 1479
function drawCartShape(draw, play, w, h, c, axleX) -- 1482
	local half = c.bodyW / 2 -- 1483
	local x0 = axleX - half -- 1484
	local x1 = axleX + half -- 1485
	play:drawBox( -- 1486
		draw, -- 1486
		w, -- 1486
		h, -- 1486
		x0, -- 1486
		x1, -- 1486
		c.baseY + c.wheelR, -- 1486
		c.baseY + c.wheelR + c.bodyH, -- 1486
		CART_FILL -- 1486
	) -- 1486
	draw:drawCircle( -- 1487
		Vec2( -- 1487
			play:sx(x0 + c.bodyW * 0.28, w), -- 1487
			play:sy(c.baseY + c.wheelR, h) -- 1487
		), -- 1487
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 1487
		Color(52, 50, 48, 255) -- 1487
	) -- 1487
	draw:drawCircle( -- 1488
		Vec2( -- 1488
			play:sx(x1 - c.bodyW * 0.28, w), -- 1488
			play:sy(c.baseY + c.wheelR, h) -- 1488
		), -- 1488
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 1488
		Color(52, 50, 48, 255) -- 1488
	) -- 1488
	local cx = c.clothSide < 0 and x0 or x1 -- 1489
	play:drawBox( -- 1490
		draw, -- 1490
		w, -- 1490
		h, -- 1490
		cx - 10, -- 1490
		cx + 10, -- 1490
		c.baseY + c.wheelR + c.bodyH, -- 1490
		c.baseY + c.wheelR + c.bodyH + 18, -- 1490
		CLOTH -- 1490
	) -- 1490
end -- 1490
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
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 38
____exports.LOGIC_H = 180 -- 39
____exports.UNITS_PER_PX = 2 -- 40
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 42
local CAM_FOLLOW = 9 -- 43
local CAM_LOOK_UP = 46 -- 44
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 47
--- 握把触发半径。
local CART_REACH = 70 -- 49
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 51
local CART_CLEAR = 44 -- 52
INK = Color(232, 232, 228, 255) -- 54
local INK_DIM = Color(150, 152, 150, 255) -- 55
local BG_VOID = Color(8, 9, 10, 255) -- 56
local BG_FAR = Color(24, 26, 28, 255) -- 57
local BG_MID = Color(31, 34, 37, 255) -- 58
local GROUND = Color(112, 114, 112, 255) -- 59
local FLOOR_DECK = Color(66, 70, 72, 255) -- 60
local SOLID_FILL = Color(84, 86, 84, 255) -- 61
local SOLID_EDGE = Color(126, 130, 126, 255) -- 62
CART_FILL = Color(122, 78, 56, 255) -- 63
CLOTH = Color(178, 52, 46, 255) -- 64
local DANGER = Color(150, 54, 48, 46) -- 65
local DANGER_LINE = Color(178, 78, 64, 200) -- 66
local HOLE_FILL = Color(10, 11, 12, 255) -- 67
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 68
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 69
local CHILD_BODY = Color(214, 168, 96, 255) -- 70
local CHILD_HEAD = Color(232, 214, 186, 255) -- 71
local ENEMY_BODY = Color(176, 92, 84, 255) -- 72
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 73
local CHECK = Color(96, 186, 122, 255) -- 74
local STAND = Color(226, 186, 84, 255) -- 75
local AIM = Color(236, 236, 232, 230) -- 76
local AIM_HIT = Color(236, 96, 84, 255) -- 77
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 79
local SOFT_LINE = Color(140, 112, 80, 190) -- 80
local BRICK = Color(126, 118, 110, 70) -- 81
local BRICK_LINE = Color(160, 152, 142, 200) -- 82
local PASS = Color(96, 186, 122, 40) -- 83
local PASS_LINE = Color(96, 186, 122, 200) -- 84
local BOTTLE = Color(120, 186, 160, 255) -- 85
local SCAV_BODY = Color(128, 118, 96, 255) -- 86
local SCAV_HEAD = Color(196, 182, 158, 255) -- 87
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 134
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 135
	if zoom < 1 then -- 135
		zoom = 1 -- 137
	end -- 137
	return { -- 139
		zoom = zoom, -- 140
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 141
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 142
	} -- 142
end -- 134
____exports.Play = __TS__Class() -- 155
local Play = ____exports.Play -- 155
Play.name = "Play" -- 155
function Play.prototype.____constructor(self, room, resume) -- 228
	self.enemies = {} -- 160
	self.boxes = {} -- 161
	self.floors = {} -- 162
	self.checkpoint = -1 -- 164
	self.flash = "" -- 166
	self.flashT = 0 -- 167
	self.traceT = 0 -- 170
	self.focusCart = false -- 172
	self.knocks = 0 -- 174
	self.knockT = 0 -- 175
	self.cartAxle = 0 -- 179
	self.cartDocked = false -- 181
	self.gripping = false -- 183
	self.gateOpen = false -- 185
	self.calmConsumed = false -- 187
	self.nextDangerId = 1 -- 189
	self.wantRoom = "" -- 191
	self.carryCartAxle = -1 -- 193
	self.carryCartDocked = false -- 194
	self.checkpointCartAxle = -1 -- 196
	self.hasBottle = false -- 200
	self.bottleLandX = -1 -- 204
	self.bottleLandT = 0 -- 205
	self.aimHold = 0 -- 207
	self.scavX = 0 -- 209
	self.scavDir = 1 -- 210
	self.scavState = "patrol" -- 211
	self.scavT = 0 -- 212
	self.scavTargetX = 0 -- 213
	self.passed = false -- 215
	self.paused = false -- 216
	self.ticks = 0 -- 218
	self.view = {zoom = 1, ox = 0, oy = 0} -- 220
	self.aimX = 0 -- 222
	self.aimY = 0 -- 223
	self.viewW = 0 -- 225
	self.viewH = 0 -- 226
	self.room = room -- 229
	self.cam = {x = (room.minX + room.maxX) / 2, y = room.height / 2} -- 230
	self:buildWorld() -- 231
	self.player = makeActor(room, room.key == "checkpoint" and 1 or 0) -- 232
	self.partner = makeActor(room, room.key == "checkpoint" and 0 or -1) -- 233
	self.cam.x = self.player.x -- 234
	self.cam.y = self.player.y + CAM_LOOK_UP -- 235
	self.cartAxle = room.cart.startX -- 236
	self.escort = __TS__New( -- 237
		Escort, -- 237
		safeAnchorX(room.marks) -- 237
	) -- 237
	self.scavX = room.scavenger ~= nil and room.scavenger.x0 or 0 -- 238
	self:buildEnemies() -- 239
	if resume ~= nil and resume.checkpoint > 0 then -- 239
		self.checkpoint = resume.checkpoint -- 242
		if room.key == "outside" and resume.checkpoint >= 380 then -- 242
			self.cartAxle = room.cart.endX -- 244
			self.cartDocked = true -- 245
			self.player.x = 390 -- 246
			self.cam.x = self.player.x -- 247
		end -- 247
	end -- 247
end -- 228
function Play.prototype.buildWorld(self) -- 253
	local room = self.room -- 254
	self.boxes = {} -- 255
	self.floors = {} -- 256
	local i = 0 -- 257
	do -- 257
		i = 0 -- 258
		while i < #room.floors do -- 258
			local f = room.floors[i + 1] -- 259
			local ____self_floors_0 = self.floors -- 259
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 260
			i = i + 1 -- 258
		end -- 258
	end -- 258
	do -- 258
		i = 0 -- 262
		while i < #room.solids do -- 262
			local s = room.solids[i + 1] -- 263
			local ____self_boxes_1 = self.boxes -- 263
			____self_boxes_1[#____self_boxes_1 + 1] = {x0 = s.x, x1 = s.x + s.w, y0 = s.y, y1 = s.y + s.h} -- 264
			i = i + 1 -- 262
		end -- 262
	end -- 262
	do -- 262
		i = 0 -- 266
		while i < #room.stairs do -- 266
			local st = room.stairs[i + 1] -- 267
			local n = st.steps + 1 -- 268
			local stepW = (st.x1 - st.x0) / n -- 269
			local k = 0 -- 270
			do -- 270
				k = 0 -- 271
				while k < n do -- 271
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 272
					local x0 = st.x0 + stepW * k -- 273
					local ____self_boxes_2 = self.boxes -- 273
					____self_boxes_2[#____self_boxes_2 + 1] = {x0 = x0, x1 = x0 + stepW, y0 = -8, y1 = y} -- 274
					k = k + 1 -- 271
				end -- 271
			end -- 271
			i = i + 1 -- 266
		end -- 266
	end -- 266
end -- 253
function Play.prototype.buildEnemies(self) -- 279
	self.enemies = {} -- 280
	if self.room.key ~= "checkpoint" then -- 280
		return -- 282
	end -- 282
	local ____self_enemies_3 = self.enemies -- 282
	____self_enemies_3[#____self_enemies_3 + 1] = { -- 284
		x = 430, -- 284
		y = 0, -- 284
		w = 26, -- 284
		h = 84, -- 284
		alive = true, -- 284
		hitT = 0 -- 284
	} -- 284
	local ____self_enemies_4 = self.enemies -- 284
	____self_enemies_4[#____self_enemies_4 + 1] = { -- 285
		x = 505, -- 285
		y = 0, -- 285
		w = 26, -- 285
		h = 84, -- 285
		alive = true, -- 285
		hitT = 0 -- 285
	} -- 285
end -- 279
function Play.prototype.update(self, dt, input) -- 289
	if input.pause.pressed then -- 289
		self.paused = not self.paused -- 291
	end -- 291
	if self.flashT > 0 then -- 291
		self.flashT = self.flashT - dt -- 294
		if self.flashT <= 0 then -- 294
			self.flash = "" -- 296
		end -- 296
	end -- 296
	if self.traceT > 0 then -- 296
		self.traceT = self.traceT - dt -- 300
		if self.traceT <= 0 then -- 300
			self.trace = nil -- 302
		end -- 302
	end -- 302
	if self.paused then -- 302
		self:updateCamera(dt) -- 306
		return -- 307
	end -- 307
	self.ticks = self.ticks + 1 -- 310
	local p = self.player -- 311
	self:stepPlayer(p, dt, input) -- 312
	self:stepEscort(dt, input) -- 313
	self:stepEnemies(dt) -- 314
	self:stepVillage(dt, input) -- 315
	self:stepInteract(dt, input) -- 316
	self:updateGate() -- 317
	self:updateCamera(dt) -- 318
end -- 289
function Play.prototype.stepPlayer(self, a, dt, input) -- 321
	if not a.alive then -- 321
		return -- 323
	end -- 323
	local isChild = self.room.key ~= "checkpoint" -- 325
	if not isChild and self.escort.state == "calming" then -- 325
		a.crouch = false -- 328
		a.h = SOLDIER_H -- 329
		a.vx = 0 -- 330
		self:fallY(a, dt) -- 331
		return -- 332
	end -- 332
	a.crouch = isChild and input.crouch.held and a.onGround -- 334
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 335
	a.covered = not isChild and input.cover.held -- 336
	if a.rollT > 0 then -- 336
		a.rollT = a.rollT - dt -- 340
		a.vx = a.facing * ROLL_SPEED -- 341
		self:slideX(a, a.vx * dt) -- 342
		self:fallY(a, dt) -- 343
		if a.rollT <= 0 then -- 343
			self:flashSet("翻滚结束", 0.5) -- 345
		end -- 345
		return -- 347
	end -- 347
	if not isChild and input.jump.pressed and a.onGround then -- 347
		a.rollT = ROLL_TIME -- 351
		if input.moveX ~= 0 then -- 351
			a.facing = input.moveX > 0 and 1 or -1 -- 353
		end -- 353
		self:flashSet("翻滚", 0.3) -- 355
		return -- 356
	end -- 356
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 359
	if isChild then -- 359
		if input.cover.held then -- 359
			speed = CHILD_SLOW -- 362
		end -- 362
		if a.crouch then -- 362
			speed = CHILD_SLOW -- 365
		end -- 365
	elseif a.covered then -- 365
		speed = SOLDIER_SPEED * 0.45 -- 368
	end -- 368
	local dir = self.gripping and 0 or input.moveX -- 372
	if dir ~= 0 then -- 372
		a.facing = dir > 0 and 1 or -1 -- 374
	end -- 374
	a.vx = dir * speed -- 376
	if isChild and input.jump.pressed and a.onGround and not a.crouch then -- 376
		a.vy = CHILD_JUMP -- 380
		a.onGround = false -- 381
		self:flashSet("跳", 0.25) -- 382
	end -- 382
	self:slideX(a, a.vx * dt) -- 385
	self:fallY(a, dt) -- 386
	if not isChild and input.fire.pressed then -- 386
		self:shoot(a) -- 390
	end -- 390
end -- 321
function Play.prototype.stepPartner(self, p, dt) -- 395
	local a = self.partner -- 396
	if not a.alive then -- 396
		return -- 398
	end -- 398
	a.crouch = false -- 400
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 401
	a.vx = 0 -- 402
	self:fallY(a, dt) -- 403
end -- 395
function Play.prototype.stepEscort(self, dt, input) -- 410
	local a = self.partner -- 411
	if not a.alive then -- 411
		return -- 413
	end -- 413
	if self.room.key ~= "checkpoint" then -- 413
		a.vx = 0 -- 416
		self:fallY(a, dt) -- 417
		return -- 418
	end -- 418
	local p = self.player -- 420
	local dist = math.abs(p.x - a.x) -- 421
	self.calmConsumed = self.escort:update( -- 422
		input, -- 422
		p.x, -- 422
		p.facing, -- 422
		a.x, -- 422
		dist -- 422
	) -- 422
	a.crouch = self.escort.crouchPose -- 423
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 424
	local dir = self.escort:moveDir(a.x) -- 425
	a.vx = dir * CHILD_SPEED -- 426
	if dir ~= 0 then -- 426
		a.facing = dir -- 428
		self:slideX(a, dir * CHILD_SPEED * dt) -- 429
	end -- 429
	self:fallY(a, dt) -- 431
end -- 410
function Play.prototype.updateGate(self) -- 434
	if self.room.key ~= "checkpoint" then -- 434
		self.gateOpen = false -- 436
		return -- 437
	end -- 437
	local function inZone(x) -- 439
		return x >= 792 and x <= 928 -- 439
	end -- 439
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 440
end -- 434
function Play.prototype.stepEnemies(self, dt) -- 443
	local i = 0 -- 444
	do -- 444
		i = 0 -- 445
		while i < #self.enemies do -- 445
			local e = self.enemies[i + 1] -- 446
			if e.hitT > 0 then -- 446
				e.hitT = e.hitT - dt -- 448
			end -- 448
			i = i + 1 -- 445
		end -- 445
	end -- 445
end -- 443
function Play.prototype.stepInteract(self, dt, input) -- 453
	local p = self.player -- 454
	local calmUsed = self.calmConsumed -- 455
	self.calmConsumed = false -- 456
	self.focusCart = false -- 457
	if self.room.key == "outside" then -- 457
		local c = self.room.cart -- 459
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 460
		local dy = p.y - c.baseY -- 461
		self.focusCart = dx * dx + dy * dy < CART_REACH * CART_REACH -- 462
	end -- 462
	self:stepCart(dt, input) -- 464
	if calmUsed then -- 464
		self:flashSet("安抚 · 敲两下", 0.8) -- 468
	elseif input.interact.pressed and not self.gripping and self.room.key ~= "village" then -- 468
		if self.knockT > 0 then -- 468
			self.knocks = self.knocks + 1 -- 471
		else -- 471
			self.knocks = 1 -- 473
		end -- 473
		self.knockT = 1.2 -- 475
		if self.knocks >= 2 then -- 475
			self:flashSet("敲两下", 0.8) -- 477
			self.knocks = 0 -- 478
		else -- 478
			self:flashSet("敲一下", 0.5) -- 480
		end -- 480
	elseif self.knockT > 0 then -- 480
		self.knockT = self.knockT - dt -- 483
		if self.knockT <= 0 then -- 483
			self.knocks = 0 -- 485
		end -- 485
	end -- 485
	local i = 0 -- 490
	do -- 490
		i = 0 -- 491
		while i < #self.room.marks do -- 491
			do -- 491
				local m = self.room.marks[i + 1] -- 492
				if m.kind ~= 0 then -- 492
					goto __continue63 -- 494
				end -- 494
				local subjects = {self.partner, self.player} -- 496
				local k = 0 -- 497
				do -- 497
					k = 0 -- 498
					while k < #subjects do -- 498
						do -- 498
							local s = subjects[k + 1] -- 499
							if not s.alive then -- 499
								goto __continue66 -- 501
							end -- 501
							local dx = s.x - m.x -- 503
							local dy = s.y - m.y -- 504
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 504
								self.checkpoint = m.x -- 506
								self.checkpointCartAxle = self.cartAxle -- 507
								if self.cartDocked then -- 507
									self:flashSet("检查点 · 车已落窝", 1) -- 509
								else -- 509
									self:flashSet("检查点 · 车还没到位", 1) -- 511
								end -- 511
							end -- 511
						end -- 511
						::__continue66:: -- 511
						k = k + 1 -- 498
					end -- 498
				end -- 498
			end -- 498
			::__continue63:: -- 498
			i = i + 1 -- 491
		end -- 491
	end -- 491
	self:checkCarryGate() -- 517
end -- 453
function Play.prototype.stepVillage(self, dt, input) -- 521
	if self.room.key ~= "village" then -- 521
		return -- 523
	end -- 523
	local p = self.player -- 525
	local bottle = self.room.bottle -- 526
	local scav = self.room.scavenger -- 527
	if not self.hasBottle and bottle ~= nil then -- 527
		local dx = p.x - bottle.x -- 531
		local dy = p.y + p.h * 0.5 - bottle.y -- 532
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 532
			self.hasBottle = true -- 534
			self:flashSet("拾起瓶子", 0.8) -- 535
		end -- 535
	end -- 535
	if self.hasBottle then -- 535
		if input.aim.held then -- 535
			self.aimHold = self.aimHold + dt -- 542
			if self.aimHold > 1.2 then -- 542
				self.aimHold = 1.2 -- 544
			end -- 544
		elseif input.aim.released then -- 544
			local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 547
			self:throwBottle(aim.x, aim.y) -- 548
			self.aimHold = 0 -- 549
		end -- 549
	else -- 549
		self.aimHold = 0 -- 552
	end -- 552
	local fly = self.bottleFly -- 556
	if fly ~= nil then -- 556
		fly.vy = fly.vy - GRAVITY * dt -- 558
		fly.x = fly.x + fly.vx * dt -- 559
		fly.y = fly.y + fly.vy * dt -- 560
		local g = self:groundAt(fly.x, fly.y + 4, 3) -- 561
		if fly.y <= g then -- 561
			self.bottleFly = nil -- 563
			self.bottleLandX = fly.x -- 564
			self.bottleLandT = 0.9 -- 565
			self:hearBottle(fly.x) -- 566
		end -- 566
	end -- 566
	if self.bottleLandT > 0 then -- 566
		self.bottleLandT = self.bottleLandT - dt -- 570
	end -- 570
	if scav ~= nil then -- 570
		self:stepScav(dt, scav) -- 574
	end -- 574
	local line = self.room.passLine -- 577
	if line ~= nil and not self.passed and p.x >= line then -- 577
		self.passed = true -- 579
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 580
	end -- 580
end -- 521
function Play.prototype.throwBottle(self, tx, ty) -- 585
	local p = self.player -- 586
	local x0 = p.x + p.facing * 10 -- 587
	local y0 = p.y + p.h * 0.7 -- 588
	local T = 0.62 -- 589
	local vx = (tx - x0) / T -- 590
	local vy = (ty - y0 + 0.5 * GRAVITY * T * T) / T -- 591
	self.bottleFly = {x = x0, y = y0, vx = vx, vy = vy} -- 592
	self.hasBottle = false -- 593
	self:flashSet("投出", 0.4) -- 594
end -- 585
function Play.prototype.hearBottle(self, x) -- 598
	local s = self.room.scavenger -- 599
	if s == nil then -- 599
		return -- 601
	end -- 601
	if math.abs(x - self.scavX) > s.range then -- 601
		self:flashSet("落地 · 他没听见", 0.6) -- 604
		return -- 605
	end -- 605
	self.scavState = "turn" -- 607
	self.scavT = s.hearTicks -- 608
	self.scavTargetX = x -- 609
	self:flashSet("砖地一响 · 他转头", 0.9) -- 610
end -- 598
function Play.prototype.stepScav(self, dt, s) -- 614
	if self.scavState == "turn" then -- 614
		self.scavT = self.scavT - 1 -- 616
		if self.scavT <= 0 then -- 616
			self.scavState = "walk" -- 618
		end -- 618
		return -- 620
	end -- 620
	if self.scavState == "walk" then -- 620
		local d = self.scavTargetX - self.scavX -- 623
		if math.abs(d) < 4 then -- 623
			self.scavState = "stall" -- 625
			self.scavT = s.stallTicks -- 626
			return -- 627
		end -- 627
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 629
		return -- 630
	end -- 630
	if self.scavState == "stall" then -- 630
		self.scavT = self.scavT - 1 -- 633
		if self.scavT <= 0 then -- 633
			self.scavState = "back" -- 635
		end -- 635
		return -- 637
	end -- 637
	if self.scavState == "back" then -- 637
		local home = math.max( -- 640
			s.x0, -- 640
			math.min(s.x1, self.scavX) -- 640
		) -- 640
		if math.abs(home - self.scavX) < 2 then -- 640
			self.scavState = "patrol" -- 642
			return -- 643
		end -- 643
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 645
		return -- 646
	end -- 646
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 648
	if self.scavX >= s.x1 then -- 648
		self.scavX = s.x1 -- 650
		self.scavDir = -1 -- 651
	elseif self.scavX <= s.x0 then -- 651
		self.scavX = s.x0 -- 653
		self.scavDir = 1 -- 654
	end -- 654
end -- 614
function Play.prototype.stepCart(self, dt, input) -- 662
	local p = self.player -- 663
	local c = self.room.cart -- 664
	local handleX = self.cartAxle + c.handleOffset -- 665
	if self.gripping then -- 665
		if not input.interact.held then -- 665
			self.gripping = false -- 669
			self:flashSet("松开车把", 0.4) -- 670
			return -- 671
		end -- 671
	else -- 671
		if not input.interact.pressed then -- 671
			return -- 675
		end -- 675
		if math.abs(p.x - handleX) > CART_REACH or math.abs(p.y - c.baseY) > 40 then -- 675
			return -- 678
		end -- 678
		self.gripping = true -- 680
		self:flashSet("握住车把", 0.4) -- 681
		return -- 682
	end -- 682
	if self.cartDocked then -- 682
		return -- 686
	end -- 686
	local dir = input.moveX -- 688
	if dir == 0 then -- 688
		return -- 690
	end -- 690
	local lo = math.min(c.startX, c.endX) -- 692
	local hi = math.max(c.startX, c.endX) -- 693
	local next = self.cartAxle + dir * CART_SPEED * dt -- 694
	if next < lo then -- 694
		next = lo -- 696
	end -- 696
	if next > hi then -- 696
		next = hi -- 699
	end -- 699
	local delta = next - self.cartAxle -- 701
	if delta == 0 then -- 701
		return -- 703
	end -- 703
	self.cartAxle = next -- 705
	p.x = p.x + delta -- 706
	p.facing = dir > 0 and 1 or -1 -- 707
	self:slideX(p, 0) -- 708
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > CART_REACH then -- 708
		self.gripping = false -- 710
		self:flashSet("跟不上了，脱手", 0.6) -- 711
		return -- 712
	end -- 712
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 712
		self.cartDocked = true -- 715
		self.gripping = false -- 716
		self:flashSet("车轮落窝", 1.2) -- 717
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 717
		self:flashSet("车轮回到起点", 0.5) -- 719
	end -- 719
end -- 662
function Play.prototype.checkCarryGate(self) -- 727
	if self.room.key == "checkpoint" then -- 727
		if self.gateOpen and self.player.x >= 900 then -- 727
			self.carryCartAxle = self.cartAxle -- 730
			self.carryCartDocked = self.cartDocked -- 731
			self.wantRoom = "outside" -- 732
			self:flashSet("过城门 · 城外", 1.2) -- 733
		end -- 733
		return -- 735
	end -- 735
	if self.room.key == "outside" then -- 735
		if self.checkpoint >= 380 and self.player.x >= 388 then -- 735
			self.carryCartAxle = self.cartAxle -- 740
			self.carryCartDocked = self.cartDocked -- 741
			self.wantRoom = "village" -- 742
			self:flashSet("洞后 · 墙根小路", 1.2) -- 743
		end -- 743
	end -- 743
end -- 727
function Play.prototype.shoot(self, a) -- 749
	local ox = a.x + a.facing * 8 -- 750
	local oy = a.y + a.h * 0.72 -- 751
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 753
	local dx = aim.x - ox -- 754
	local dy = aim.y - oy -- 755
	local len = math.sqrt(dx * dx + dy * dy) -- 756
	if len < 0.001 then -- 756
		dx = a.facing -- 758
		dy = 0 -- 759
	else -- 759
		dx = dx / len -- 761
		dy = dy / len -- 762
	end -- 762
	if dx ~= 0 then -- 762
		a.facing = dx > 0 and 1 or -1 -- 765
	end -- 765
	local hitEnemy = self:raycast( -- 768
		ox, -- 768
		oy, -- 768
		dx, -- 768
		dy, -- 768
		true -- 768
	) -- 768
	local hitWall = self:raycast( -- 769
		ox, -- 769
		oy, -- 769
		dx, -- 769
		dy, -- 769
		false -- 769
	) -- 769
	local tEnemy = hitEnemy.t -- 770
	local tWall = hitWall.t -- 771
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 772
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 773
	self.trace = { -- 775
		x0 = ox, -- 775
		y0 = oy, -- 775
		x1 = ox + dx * t, -- 775
		y1 = oy + dy * t, -- 775
		hit = hit -- 775
	} -- 775
	self.traceT = 0.12 -- 776
	self:applyFireDanger(ox) -- 777
	if hit then -- 777
		local i = hitEnemy.index -- 779
		local e = self.enemies[i + 1] -- 780
		e.alive = false -- 781
		e.hitT = 0.4 -- 782
		self:flashSet("命中", 0.6) -- 783
	else -- 783
		self:flashSet("打空", 0.35) -- 785
	end -- 785
end -- 749
function Play.prototype.applyFireDanger(self, shotX) -- 790
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 790
		return -- 792
	end -- 792
	local dangerX = shotX -- 794
	local best = -1 -- 795
	local bestD = 1000000000 -- 796
	local i = 0 -- 797
	do -- 797
		i = 0 -- 798
		while i < #self.enemies do -- 798
			do -- 798
				local e = self.enemies[i + 1] -- 799
				if not e.alive then -- 799
					goto __continue128 -- 801
				end -- 801
				local d = math.abs(e.x - self.partner.x) -- 803
				if d < bestD then -- 803
					bestD = d -- 805
					best = i -- 806
				end -- 806
			end -- 806
			::__continue128:: -- 806
			i = i + 1 -- 798
		end -- 798
	end -- 798
	if best >= 0 then -- 798
		dangerX = self.enemies[best + 1].x -- 810
	end -- 810
	local exposed = self:childExposed(dangerX) -- 812
	local before = self.escort.fear -- 813
	local after = self.escort:applyDanger(self.nextDangerId, exposed, self.partner.x) -- 814
	self.nextDangerId = self.nextDangerId + 1 -- 815
	if after > before then -- 815
		self:flashSet( -- 817
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 817
			1 -- 817
		) -- 817
	elseif not exposed then -- 817
		self:flashSet("枪声没够到她", 0.5) -- 819
	end -- 819
end -- 790
function Play.prototype.childExposed(self, dangerX) -- 824
	local c = self.partner -- 825
	if not c.alive then -- 825
		return false -- 827
	end -- 827
	if c.x > 240 and c.x < 340 then -- 827
		return false -- 830
	end -- 830
	if c.x < 380 or c.x > 560 then -- 830
		return false -- 833
	end -- 833
	local toDanger = dangerX - c.x -- 835
	local toPlayer = self.player.x - c.x -- 836
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) then -- 836
		return false -- 838
	end -- 838
	return true -- 840
end -- 824
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 844
	local best = -1 -- 845
	local bestI = -1 -- 846
	local i = 0 -- 847
	if enemies then -- 847
		do -- 847
			i = 0 -- 849
			while i < #self.enemies do -- 849
				do -- 849
					local e = self.enemies[i + 1] -- 850
					if not e.alive then -- 850
						goto __continue142 -- 852
					end -- 852
					local t = hitBox( -- 854
						ox, -- 854
						oy, -- 854
						dx, -- 854
						dy, -- 854
						e.x - e.w / 2, -- 854
						e.x + e.w / 2, -- 854
						e.y, -- 854
						e.y + e.h -- 854
					) -- 854
					if t >= 0 and (best < 0 or t < best) then -- 854
						best = t -- 856
						bestI = i -- 857
					end -- 857
				end -- 857
				::__continue142:: -- 857
				i = i + 1 -- 849
			end -- 849
		end -- 849
		return {t = best, index = bestI} -- 860
	end -- 860
	do -- 860
		i = 0 -- 862
		while i < #self.boxes do -- 862
			local b = self.boxes[i + 1] -- 863
			local t = hitBox( -- 864
				ox, -- 864
				oy, -- 864
				dx, -- 864
				dy, -- 864
				b.x0, -- 864
				b.x1, -- 864
				b.y0, -- 864
				b.y1 -- 864
			) -- 864
			if t >= 0 and (best < 0 or t < best) then -- 864
				best = t -- 866
			end -- 866
			i = i + 1 -- 862
		end -- 862
	end -- 862
	if dy < 0 then -- 862
		local t = (0 - oy) / dy -- 871
		if t >= 0 and (best < 0 or t < best) then -- 871
			best = t -- 873
		end -- 873
	end -- 873
	return {t = best, index = -1} -- 876
end -- 844
function Play.prototype.slideX(self, a, dx) -- 880
	local nx = a.x + dx -- 881
	local half = a.w / 2 -- 882
	local room = self.room -- 883
	nx = math.max( -- 884
		room.minX + half, -- 884
		math.min(room.maxX - half, nx) -- 884
	) -- 884
	local i = 0 -- 885
	do -- 885
		i = 0 -- 886
		while i < #self.boxes do -- 886
			do -- 886
				local b = self.boxes[i + 1] -- 887
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 887
					goto __continue152 -- 889
				end -- 889
				if nx + half > b.x0 and nx - half < b.x1 then -- 889
					if a.x <= b.x0 then -- 889
						nx = b.x0 - half -- 893
					elseif a.x >= b.x1 then -- 893
						nx = b.x1 + half -- 895
					else -- 895
						nx = a.x -- 897
					end -- 897
				end -- 897
			end -- 897
			::__continue152:: -- 897
			i = i + 1 -- 886
		end -- 886
	end -- 886
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 886
		local bx0 = self.cartAxle - CART_HALF -- 903
		local bx1 = self.cartAxle + CART_HALF -- 904
		if nx + half > bx0 and nx - half < bx1 then -- 904
			if a.x <= bx0 then -- 904
				nx = bx0 - half -- 907
			elseif a.x >= bx1 then -- 907
				nx = bx1 + half -- 909
			else -- 909
				nx = a.x -- 911
			end -- 911
		end -- 911
	end -- 911
	local arch = room.arch -- 918
	if arch.h > 0 and a.y + a.h > arch.y + arch.h + 0.001 then -- 918
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 920
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 920
			if a.x <= arch.x0 then -- 920
				nx = arch.x0 - half -- 923
			elseif a.x >= arch.x1 then -- 923
				nx = arch.x1 + half -- 925
			end -- 925
		end -- 925
	end -- 925
	a.x = nx -- 929
end -- 880
function Play.prototype.fallY(self, a, dt) -- 933
	a.vy = a.vy - GRAVITY * dt -- 934
	if a.vy < -900 then -- 934
		a.vy = -900 -- 936
	end -- 936
	local ny = a.y + a.vy * dt -- 938
	local half = a.w / 2 -- 939
	if a.vy <= 0 then -- 939
		local ground = self:groundAt(a.x, a.y + 0.5, half) -- 941
		if ny <= ground then -- 941
			ny = ground -- 943
			a.vy = 0 -- 944
			a.onGround = true -- 945
		else -- 945
			a.onGround = false -- 947
		end -- 947
	else -- 947
		a.onGround = false -- 950
		local i = 0 -- 951
		do -- 951
			i = 0 -- 952
			while i < #self.boxes do -- 952
				do -- 952
					local b = self.boxes[i + 1] -- 953
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 953
						goto __continue174 -- 955
					end -- 955
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 955
						ny = b.y0 - a.h -- 958
						a.vy = 0 -- 959
					end -- 959
				end -- 959
				::__continue174:: -- 959
				i = i + 1 -- 952
			end -- 952
		end -- 952
	end -- 952
	a.y = ny -- 963
end -- 933
function Play.prototype.groundAt(self, x, ceiling, half) -- 967
	local g = -9999 -- 968
	local i = 0 -- 969
	do -- 969
		i = 0 -- 970
		while i < #self.floors do -- 970
			local f = self.floors[i + 1] -- 971
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 971
				g = f.y1 -- 973
			end -- 973
			i = i + 1 -- 970
		end -- 970
	end -- 970
	do -- 970
		i = 0 -- 976
		while i < #self.boxes do -- 976
			local b = self.boxes[i + 1] -- 977
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 977
				g = b.y1 -- 979
			end -- 979
			i = i + 1 -- 976
		end -- 976
	end -- 976
	return g -- 982
end -- 967
function Play.prototype.updateCamera(self, dt) -- 985
	local p = self.player -- 986
	local tx = p.x + p.facing * 30 -- 987
	local ty = p.y + CAM_LOOK_UP -- 988
	local k = math.min(1, CAM_FOLLOW * dt) -- 989
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 990
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 991
end -- 985
function Play.prototype.clampCamera(self, w, h) -- 995
	local room = self.room -- 996
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 997
	local spanX = room.maxX - room.minX -- 998
	if spanX <= halfW * 2 then -- 998
		self.cam.x = (room.minX + room.maxX) / 2 -- 1000
	else -- 1000
		self.cam.x = math.max( -- 1002
			room.minX + halfW, -- 1002
			math.min(room.maxX - halfW, self.cam.x) -- 1002
		) -- 1002
	end -- 1002
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 1005
	local spanY = room.height -- 1006
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 1007
	if spanY <= halfH * 2 then -- 1007
		self.cam.y = camY -- 1009
	else -- 1009
		self.cam.y = math.max( -- 1011
			camY, -- 1011
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 1011
		) -- 1011
	end -- 1011
end -- 995
function Play.prototype.flashSet(self, text, t) -- 1015
	self.flash = text -- 1016
	self.flashT = t -- 1017
end -- 1015
function Play.prototype.statusText(self) -- 1021
	local p = self.player -- 1022
	local parts = {} -- 1023
	if self.room.key == "village" then -- 1023
		parts[#parts + 1] = (("小满 x=" .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 1025
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1026
		if self.hasBottle then -- 1026
			parts[#parts + 1] = "有瓶" -- 1028
		elseif self.bottleFly ~= nil then -- 1028
			parts[#parts + 1] = "瓶在飞" -- 1030
		else -- 1030
			parts[#parts + 1] = "空手" -- 1032
		end -- 1032
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 1034
		if self.passed then -- 1034
			parts[#parts + 1] = "已过通行线" -- 1036
		end -- 1036
		if self.paused then -- 1036
			parts[#parts + 1] = "已暂停" -- 1039
		end -- 1039
		return table.concat(parts, " · ") -- 1041
	end -- 1041
	local isChild = self.room.key ~= "checkpoint" -- 1044
	local who = isChild and "小满" or "周戍" -- 1045
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 1046
	if isChild then -- 1046
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1048
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 1049
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1050
	else -- 1050
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 1052
		if p.rollT > 0 then -- 1052
			parts[#parts + 1] = "翻滚中" -- 1054
		end -- 1054
		local alive = 0 -- 1056
		local i = 0 -- 1057
		do -- 1057
			i = 0 -- 1058
			while i < #self.enemies do -- 1058
				if self.enemies[i + 1].alive then -- 1058
					alive = alive + 1 -- 1060
				end -- 1060
				i = i + 1 -- 1058
			end -- 1058
		end -- 1058
		parts[#parts + 1] = (("敌 " .. tostring(alive)) .. "/") .. tostring(#self.enemies) -- 1063
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1064
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 1065
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 1066
	end -- 1066
	if self.checkpoint >= 0 then -- 1066
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 1069
	end -- 1069
	if self.paused then -- 1069
		parts[#parts + 1] = "已暂停" -- 1072
	end -- 1072
	return table.concat(parts, " · ") -- 1074
end -- 1021
function Play.prototype.scavLabel(self) -- 1078
	if self.scavState == "turn" then -- 1078
		return "转头" -- 1080
	end -- 1080
	if self.scavState == "walk" then -- 1080
		return "赶来" -- 1083
	end -- 1083
	if self.scavState == "stall" then -- 1083
		return "停住" -- 1086
	end -- 1086
	if self.scavState == "back" then -- 1086
		return "回位" -- 1089
	end -- 1089
	return "巡逻" -- 1091
end -- 1078
function Play.prototype.hintText(self) -- 1095
	if self.paused then -- 1095
		return "Esc 继续 · R 重置" -- 1097
	end -- 1097
	if self.flash ~= "" then -- 1097
		return self.flash -- 1100
	end -- 1100
	if self.room.key == "village" then -- 1100
		if self.bottleFly ~= nil then -- 1100
			return "等瓶子落地 · 触地才发声" -- 1104
		end -- 1104
		if self.hasBottle then -- 1104
			return "按住 F 瞄，松手投 · 往右投到砖地 608，他才会走开" -- 1107
		end -- 1107
		if self.passed then -- 1107
			return "已过第一院 · R 重置可再来一遍" -- 1110
		end -- 1110
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 1112
	end -- 1112
	if self.room.key == "outside" then -- 1112
		if self.focusCart then -- 1112
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 1116
		end -- 1116
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 1118
	end -- 1118
	if self.escort.state == "frozen" then -- 1118
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 1118
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 1122
		end -- 1122
		return "小满吓住了 · 走过去，靠近再点 E" -- 1124
	end -- 1124
	if self.escort.state == "calming" then -- 1124
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 1127
	end -- 1127
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 1129
end -- 1095
function Play.prototype.draw(self, draw, w, h) -- 1134
	self.viewW = w -- 1135
	self.viewH = h -- 1136
	self.view = ____exports.computeViewport(w, h) -- 1137
	self:clampCamera(w, h) -- 1138
	draw:clear() -- 1139
	draw:drawRect( -- 1141
		Rect(0, 0, w, h), -- 1141
		BG_VOID -- 1141
	) -- 1141
	local box = self:canvasRect(w, h) -- 1142
	draw:drawRect(box, BG_FAR) -- 1143
	draw:drawRect( -- 1144
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 1144
		BG_MID -- 1144
	) -- 1144
	self:drawFloors(draw, w, h) -- 1146
	self:drawSolids(draw, w, h) -- 1147
	self:drawZones(draw, w, h) -- 1148
	self:drawArch(draw, w, h) -- 1149
	self:drawCart(draw, w, h) -- 1150
	self:drawActors(draw, w, h) -- 1151
	self:drawTrace(draw, w, h) -- 1152
	self:drawAim(draw, w, h) -- 1153
end -- 1134
function Play.prototype.canvasRect(self, w, h) -- 1157
	local v = self.view -- 1158
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 1159
end -- 1157
function Play.prototype.px(self, n) -- 1163
	return n * self.view.zoom -- 1164
end -- 1163
function Play.prototype.sx(self, wx, w) -- 1168
	local v = self.view -- 1169
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 1170
	return v.ox + lx * v.zoom -- 1171
end -- 1168
function Play.prototype.sy(self, wy, h) -- 1175
	local v = self.view -- 1176
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 1177
	return v.oy + ly * v.zoom -- 1178
end -- 1175
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 1181
	local px0 = self:sx(x0, w) -- 1182
	local px1 = self:sx(x1, w) -- 1183
	local py0 = self:sy(y0, h) -- 1184
	local py1 = self:sy(y1, h) -- 1185
	if px1 <= px0 or py1 <= py0 then -- 1185
		return -- 1187
	end -- 1187
	draw:drawRect( -- 1189
		Rect(px0, py0, px1 - px0, py1 - py0), -- 1189
		color -- 1189
	) -- 1189
end -- 1181
function Play.prototype.drawFloors(self, draw, w, h) -- 1192
	local i = 0 -- 1193
	do -- 1193
		i = 0 -- 1194
		while i < #self.room.floors do -- 1194
			local f = self.room.floors[i + 1] -- 1195
			local y = self:sy(f.y, h) -- 1196
			local x0 = self:sx(f.x0, w) -- 1197
			local x1 = self:sx(f.x1, w) -- 1198
			local deck = self:px(5) -- 1199
			draw:drawRect( -- 1200
				Rect(x0, y - deck, x1 - x0, deck), -- 1200
				FLOOR_DECK -- 1200
			) -- 1200
			draw:drawSegment( -- 1201
				Vec2(x0, y), -- 1201
				Vec2(x1, y), -- 1201
				self:px(1), -- 1201
				GROUND -- 1201
			) -- 1201
			i = i + 1 -- 1194
		end -- 1194
	end -- 1194
end -- 1192
function Play.prototype.drawSolids(self, draw, w, h) -- 1205
	local i = 0 -- 1206
	do -- 1206
		i = 0 -- 1207
		while i < #self.boxes do -- 1207
			do -- 1207
				local b = self.boxes[i + 1] -- 1208
				if b.y0 < -4 and b.y1 <= 96 then -- 1208
					draw:drawSegment( -- 1211
						Vec2( -- 1211
							self:sx(b.x0, w), -- 1211
							self:sy(b.y1, h) -- 1211
						), -- 1211
						Vec2( -- 1211
							self:sx(b.x1, w), -- 1211
							self:sy(b.y1, h) -- 1211
						), -- 1211
						self:px(1), -- 1211
						GROUND -- 1211
					) -- 1211
					goto __continue235 -- 1212
				end -- 1212
				self:drawBox( -- 1214
					draw, -- 1214
					w, -- 1214
					h, -- 1214
					b.x0, -- 1214
					b.x1, -- 1214
					b.y0, -- 1214
					b.y1, -- 1214
					SOLID_FILL -- 1214
				) -- 1214
				draw:drawSegment( -- 1215
					Vec2( -- 1215
						self:sx(b.x0, w), -- 1215
						self:sy(b.y1, h) -- 1215
					), -- 1215
					Vec2( -- 1215
						self:sx(b.x1, w), -- 1215
						self:sy(b.y1, h) -- 1215
					), -- 1215
					self:px(1), -- 1215
					SOLID_EDGE -- 1215
				) -- 1215
			end -- 1215
			::__continue235:: -- 1215
			i = i + 1 -- 1207
		end -- 1207
	end -- 1207
end -- 1205
function Play.prototype.drawZones(self, draw, w, h) -- 1219
	local i = 0 -- 1220
	do -- 1220
		i = 0 -- 1221
		while i < #self.room.zones do -- 1221
			local z = self.room.zones[i + 1] -- 1222
			local fill = DANGER -- 1223
			local line = DANGER_LINE -- 1224
			if z.tint == 2 then -- 1224
				fill = SOFT -- 1226
				line = SOFT_LINE -- 1227
			elseif z.tint == 3 then -- 1227
				fill = BRICK -- 1229
				line = BRICK_LINE -- 1230
			elseif z.tint == 4 then -- 1230
				fill = PASS -- 1232
				line = PASS_LINE -- 1233
			end -- 1233
			self:drawBox( -- 1235
				draw, -- 1235
				w, -- 1235
				h, -- 1235
				z.x0, -- 1235
				z.x1, -- 1235
				z.y, -- 1235
				z.y + z.h, -- 1235
				fill -- 1235
			) -- 1235
			draw:drawSegment( -- 1236
				Vec2( -- 1236
					self:sx(z.x0, w), -- 1236
					self:sy(z.y, h) -- 1236
				), -- 1236
				Vec2( -- 1236
					self:sx(z.x0, w), -- 1236
					self:sy(z.y + z.h, h) -- 1236
				), -- 1236
				self:px(1), -- 1236
				line -- 1236
			) -- 1236
			draw:drawSegment( -- 1237
				Vec2( -- 1237
					self:sx(z.x1, w), -- 1237
					self:sy(z.y, h) -- 1237
				), -- 1237
				Vec2( -- 1237
					self:sx(z.x1, w), -- 1237
					self:sy(z.y + z.h, h) -- 1237
				), -- 1237
				self:px(1), -- 1237
				line -- 1237
			) -- 1237
			i = i + 1 -- 1221
		end -- 1221
	end -- 1221
end -- 1219
function Play.prototype.drawArch(self, draw, w, h) -- 1241
	local a = self.room.arch -- 1242
	if a.h <= 0 then -- 1242
		return -- 1244
	end -- 1244
	self:drawBox( -- 1246
		draw, -- 1246
		w, -- 1246
		h, -- 1246
		a.x0, -- 1246
		a.x1, -- 1246
		a.y, -- 1246
		a.y + a.h, -- 1246
		HOLE_FILL -- 1246
	) -- 1246
	draw:drawSegment( -- 1247
		Vec2( -- 1247
			self:sx(a.x0, w), -- 1247
			self:sy(a.y + a.h, h) -- 1247
		), -- 1247
		Vec2( -- 1247
			self:sx(a.x1, w), -- 1247
			self:sy(a.y + a.h, h) -- 1247
		), -- 1247
		self:px(1), -- 1247
		SOLID_EDGE -- 1247
	) -- 1247
	draw:drawSegment( -- 1248
		Vec2( -- 1248
			self:sx(a.x0, w), -- 1248
			self:sy(a.y, h) -- 1248
		), -- 1248
		Vec2( -- 1248
			self:sx(a.x0, w), -- 1248
			self:sy(a.y + a.h, h) -- 1248
		), -- 1248
		self:px(1), -- 1248
		SOLID_EDGE -- 1248
	) -- 1248
	draw:drawSegment( -- 1249
		Vec2( -- 1249
			self:sx(a.x1, w), -- 1249
			self:sy(a.y, h) -- 1249
		), -- 1249
		Vec2( -- 1249
			self:sx(a.x1, w), -- 1249
			self:sy(a.y + a.h, h) -- 1249
		), -- 1249
		self:px(1), -- 1249
		SOLID_EDGE -- 1249
	) -- 1249
end -- 1241
function Play.prototype.drawCart(self, draw, w, h) -- 1252
	local c = self.room.cart -- 1253
	if c.bodyW <= 0 then -- 1253
		return -- 1255
	end -- 1255
	drawCartShape( -- 1257
		draw, -- 1257
		self, -- 1257
		w, -- 1257
		h, -- 1257
		c, -- 1257
		self.cartAxle -- 1257
	) -- 1257
	draw:drawRect( -- 1258
		Rect( -- 1258
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 1258
			self:sy(c.baseY + 40, h), -- 1258
			self:px(2), -- 1258
			self:px(40) -- 1258
		), -- 1258
		STAND -- 1258
	) -- 1258
end -- 1252
function Play.prototype.drawActors(self, draw, w, h) -- 1261
	local p = self.player -- 1262
	local isChild = self.room.key ~= "checkpoint" -- 1263
	drawFigure( -- 1264
		draw, -- 1264
		self, -- 1264
		w, -- 1264
		h, -- 1264
		p, -- 1264
		isChild and CHILD_BODY or SOLDIER_BODY, -- 1264
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 1264
	) -- 1264
	local q = self.partner -- 1265
	if q.alive then -- 1265
		local childPartner = q.w == CHILD_W -- 1267
		drawFigure( -- 1268
			draw, -- 1268
			self, -- 1268
			w, -- 1268
			h, -- 1268
			q, -- 1268
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 1268
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 1268
		) -- 1268
	end -- 1268
	local i = 0 -- 1270
	do -- 1270
		i = 0 -- 1271
		while i < #self.enemies do -- 1271
			local e = self.enemies[i + 1] -- 1272
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 1273
			self:drawBox( -- 1274
				draw, -- 1274
				w, -- 1274
				h, -- 1274
				e.x - e.w / 2, -- 1274
				e.x + e.w / 2, -- 1274
				e.y, -- 1274
				e.y + e.h, -- 1274
				col -- 1274
			) -- 1274
			i = i + 1 -- 1271
		end -- 1271
	end -- 1271
	local k = 0 -- 1277
	do -- 1277
		k = 0 -- 1278
		while k < #self.room.marks do -- 1278
			do -- 1278
				local m = self.room.marks[k + 1] -- 1279
				if m.kind ~= 0 then -- 1279
					goto __continue252 -- 1281
				end -- 1281
				local on = self.checkpoint == m.x -- 1283
				local x = self:sx(m.x, w) -- 1284
				local y = self:sy(m.y, h) -- 1285
				draw:drawSegment( -- 1286
					Vec2(x, y), -- 1286
					Vec2( -- 1286
						x, -- 1286
						y + self:px(35) -- 1286
					), -- 1286
					self:px(1), -- 1286
					on and CHECK or INK_DIM -- 1286
				) -- 1286
				draw:drawDot( -- 1287
					Vec2( -- 1287
						x, -- 1287
						y + self:px(35) -- 1287
					), -- 1287
					self:px(2), -- 1287
					on and CHECK or INK_DIM -- 1287
				) -- 1287
			end -- 1287
			::__continue252:: -- 1287
			k = k + 1 -- 1278
		end -- 1278
	end -- 1278
	local j = 0 -- 1291
	do -- 1291
		j = 0 -- 1292
		while j < #self.room.marks do -- 1292
			do -- 1292
				local m = self.room.marks[j + 1] -- 1293
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 1293
					goto __continue255 -- 1295
				end -- 1295
				if m.kind == 1 and self.room.key ~= "checkpoint" then -- 1295
					goto __continue255 -- 1298
				end -- 1298
				local col = STAND -- 1300
				if m.kind == 4 then -- 1300
					col = PASS_LINE -- 1302
				elseif m.kind == 5 then -- 1302
					col = BRICK_LINE -- 1304
				end -- 1304
				local mx = self:sx(m.x, w) -- 1306
				local my = self:sy(m.y, h) -- 1307
				draw:drawSegment( -- 1308
					Vec2(mx, my), -- 1308
					Vec2( -- 1308
						mx, -- 1308
						my + self:px(24) -- 1308
					), -- 1308
					self:px(1), -- 1308
					col -- 1308
				) -- 1308
			end -- 1308
			::__continue255:: -- 1308
			j = j + 1 -- 1292
		end -- 1292
	end -- 1292
	if self.room.key == "village" then -- 1292
		self:drawVillage(draw, w, h) -- 1311
	end -- 1311
end -- 1261
function Play.prototype.drawVillage(self, draw, w, h) -- 1316
	local bottle = self.room.bottle -- 1317
	if bottle ~= nil then -- 1317
		self:drawBox( -- 1319
			draw, -- 1319
			w, -- 1319
			h, -- 1319
			bottle.x - 14, -- 1319
			bottle.x + 14, -- 1319
			0, -- 1319
			64, -- 1319
			SOLID_FILL -- 1319
		) -- 1319
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 1319
			self:drawBottle( -- 1321
				draw, -- 1321
				w, -- 1321
				h, -- 1321
				bottle.x, -- 1321
				64 -- 1321
			) -- 1321
		end -- 1321
	end -- 1321
	self:drawBox( -- 1325
		draw, -- 1325
		w, -- 1325
		h, -- 1325
		300, -- 1325
		420, -- 1325
		44, -- 1325
		50, -- 1325
		FLOOR_DECK -- 1325
	) -- 1325
	self:drawBox( -- 1326
		draw, -- 1326
		w, -- 1326
		h, -- 1326
		300, -- 1326
		306, -- 1326
		0, -- 1326
		44, -- 1326
		FLOOR_DECK -- 1326
	) -- 1326
	self:drawBox( -- 1327
		draw, -- 1327
		w, -- 1327
		h, -- 1327
		414, -- 1327
		420, -- 1327
		0, -- 1327
		44, -- 1327
		FLOOR_DECK -- 1327
	) -- 1327
	local s = self.room.scavenger -- 1329
	if s ~= nil then -- 1329
		local sx0 = self.scavX -- 1331
		self:drawBox( -- 1332
			draw, -- 1332
			w, -- 1332
			h, -- 1332
			sx0 - 12, -- 1332
			sx0 + 12, -- 1332
			0, -- 1332
			s.h - 14, -- 1332
			SCAV_BODY -- 1332
		) -- 1332
		self:drawBox( -- 1333
			draw, -- 1333
			w, -- 1333
			h, -- 1333
			sx0 - 7, -- 1333
			sx0 + 7, -- 1333
			s.h - 14, -- 1333
			s.h, -- 1333
			SCAV_HEAD -- 1333
		) -- 1333
		if self.scavState == "turn" then -- 1333
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 1335
			draw:drawSegment( -- 1336
				Vec2( -- 1336
					self:sx(sx0, w), -- 1336
					self:sy(s.h - 6, h) -- 1336
				), -- 1336
				Vec2( -- 1336
					self:sx(fx, w), -- 1336
					self:sy(s.h - 6, h) -- 1336
				), -- 1336
				self:px(1), -- 1336
				INK -- 1336
			) -- 1336
		end -- 1336
	end -- 1336
	if self.hasBottle then -- 1336
		local p = self.player -- 1341
		self:drawBottle( -- 1342
			draw, -- 1342
			w, -- 1342
			h, -- 1342
			p.x + p.facing * 10, -- 1342
			p.y + p.h * 0.62 -- 1342
		) -- 1342
	end -- 1342
	if self.bottleFly ~= nil then -- 1342
		self:drawBottle( -- 1345
			draw, -- 1345
			w, -- 1345
			h, -- 1345
			self.bottleFly.x, -- 1345
			self.bottleFly.y -- 1345
		) -- 1345
	end -- 1345
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 1345
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 1348
		draw:drawCircle( -- 1349
			Vec2( -- 1349
				self:sx(self.bottleLandX, w), -- 1349
				self:sy(0, h) -- 1349
			), -- 1349
			self:px(r / ____exports.UNITS_PER_PX), -- 1349
			BRICK_LINE -- 1349
		) -- 1349
	end -- 1349
end -- 1316
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 1353
	self:drawBox( -- 1354
		draw, -- 1354
		w, -- 1354
		h, -- 1354
		x - 3, -- 1354
		x + 3, -- 1354
		y - 10, -- 1354
		y, -- 1354
		BOTTLE -- 1354
	) -- 1354
end -- 1353
function Play.prototype.drawTrace(self, draw, w, h) -- 1357
	local t = self.trace -- 1358
	if t == nil or self.traceT <= 0 then -- 1358
		return -- 1360
	end -- 1360
	draw:drawSegment( -- 1362
		Vec2( -- 1363
			self:sx(t.x0, w), -- 1363
			self:sy(t.y0, h) -- 1363
		), -- 1363
		Vec2( -- 1364
			self:sx(t.x1, w), -- 1364
			self:sy(t.y1, h) -- 1364
		), -- 1364
		self:px(1), -- 1365
		t.hit and AIM_HIT or INK_DIM -- 1365
	) -- 1365
end -- 1357
function Play.prototype.drawAim(self, draw, w, h) -- 1368
	local v = self.view -- 1370
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 1371
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 1372
	local dot = self:px(1) -- 1373
	local arm = self:px(3) -- 1374
	local gap = self:px(1) -- 1375
	draw:drawSegment( -- 1376
		Vec2(gx - arm - gap, gy), -- 1376
		Vec2(gx - gap, gy), -- 1376
		dot / 2, -- 1376
		AIM -- 1376
	) -- 1376
	draw:drawSegment( -- 1377
		Vec2(gx + gap, gy), -- 1377
		Vec2(gx + arm + gap, gy), -- 1377
		dot / 2, -- 1377
		AIM -- 1377
	) -- 1377
	draw:drawSegment( -- 1378
		Vec2(gx, gy - arm - gap), -- 1378
		Vec2(gx, gy - gap), -- 1378
		dot / 2, -- 1378
		AIM -- 1378
	) -- 1378
	draw:drawSegment( -- 1379
		Vec2(gx, gy + gap), -- 1379
		Vec2(gx, gy + arm + gap), -- 1379
		dot / 2, -- 1379
		AIM -- 1379
	) -- 1379
	if self.room.key == "village" and self.hasBottle then -- 1379
		local p = self.player -- 1383
		local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1384
		local x0 = p.x + p.facing * 10 -- 1385
		local y0 = p.y + p.h * 0.7 -- 1386
		local T = 0.62 -- 1387
		local vx = (aim.x - x0) / T -- 1388
		local vy = (aim.y - y0 + 0.5 * GRAVITY * T * T) / T -- 1389
		local pxr = x0 -- 1390
		local pyr = y0 -- 1391
		local t = 1 -- 1392
		do -- 1392
			t = 1 -- 1393
			while t <= 12 do -- 1393
				local tt = t / 12 * T -- 1394
				local nx = x0 + vx * tt -- 1395
				local ny = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 1396
				draw:drawSegment( -- 1397
					Vec2( -- 1397
						self:sx(pxr, w), -- 1397
						self:sy(pyr, h) -- 1397
					), -- 1397
					Vec2( -- 1397
						self:sx(nx, w), -- 1397
						self:sy(ny, h) -- 1397
					), -- 1397
					self:px(1) / 2, -- 1397
					BOTTLE -- 1397
				) -- 1397
				pxr = nx -- 1398
				pyr = ny -- 1399
				t = t + 1 -- 1393
			end -- 1393
		end -- 1393
	end -- 1393
end -- 1368
return ____exports -- 1368