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
function makeActor(room, index) -- 2371
	local sp = room.spawns -- 2372
	if index < 0 or index >= #sp then -- 2372
		return { -- 2374
			x = 0, -- 2374
			y = 0, -- 2374
			vx = 0, -- 2374
			vy = 0, -- 2374
			w = CHILD_W, -- 2374
			h = CHILD_H, -- 2374
			onGround = true, -- 2374
			facing = 1, -- 2374
			crouch = false, -- 2374
			rollT = 0, -- 2374
			covered = false, -- 2374
			alive = false -- 2374
		} -- 2374
	end -- 2374
	local s = sp[index + 1] -- 2376
	local child = s.h <= CHILD_H -- 2377
	return { -- 2378
		x = s.x, -- 2379
		y = s.y, -- 2379
		vx = 0, -- 2379
		vy = 0, -- 2379
		w = child and CHILD_W or SOLDIER_W, -- 2380
		h = child and CHILD_H or SOLDIER_H, -- 2381
		onGround = true, -- 2382
		facing = 1, -- 2382
		crouch = false, -- 2382
		rollT = 0, -- 2382
		covered = false, -- 2382
		alive = true -- 2382
	} -- 2382
end -- 2382
function drawFigure(draw, play, w, h, a, body, head) -- 2386
	if not a.alive then -- 2386
		return -- 2388
	end -- 2388
	local x0 = a.x - a.w / 2 -- 2390
	local x1 = a.x + a.w / 2 -- 2391
	local y0 = a.y -- 2392
	local y1 = a.y + a.h -- 2393
	play:drawBox( -- 2394
		draw, -- 2394
		w, -- 2394
		h, -- 2394
		x0, -- 2394
		x1, -- 2394
		y0, -- 2394
		y1 - a.h * 0.26, -- 2394
		body -- 2394
	) -- 2394
	play:drawBox( -- 2395
		draw, -- 2395
		w, -- 2395
		h, -- 2395
		x0 + 2, -- 2395
		x1 - 2, -- 2395
		y1 - a.h * 0.26, -- 2395
		y1, -- 2395
		head -- 2395
	) -- 2395
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 2397
	play:drawBox( -- 2398
		draw, -- 2398
		w, -- 2398
		h, -- 2398
		eyeX, -- 2398
		eyeX + 4, -- 2398
		y1 - a.h * 0.14, -- 2398
		y1 - a.h * 0.08, -- 2398
		INK -- 2398
	) -- 2398
end -- 2398
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 2402
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 2403
end -- 2402
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 2410
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 2411
end -- 2410
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 2418
	local tmin = 0 -- 2419
	local tmax = 99999 -- 2420
	if dx == 0 then -- 2420
		if ox < x0 or ox > x1 then -- 2420
			return -1 -- 2423
		end -- 2423
	else -- 2423
		local t1 = (x0 - ox) / dx -- 2426
		local t2 = (x1 - ox) / dx -- 2427
		local lo = t1 < t2 and t1 or t2 -- 2428
		local hi = t1 < t2 and t2 or t1 -- 2429
		if lo > tmin then -- 2429
			tmin = lo -- 2431
		end -- 2431
		if hi < tmax then -- 2431
			tmax = hi -- 2434
		end -- 2434
	end -- 2434
	if dy == 0 then -- 2434
		if oy < y0 or oy > y1 then -- 2434
			return -1 -- 2439
		end -- 2439
	else -- 2439
		local t1 = (y0 - oy) / dy -- 2442
		local t2 = (y1 - oy) / dy -- 2443
		local lo = t1 < t2 and t1 or t2 -- 2444
		local hi = t1 < t2 and t2 or t1 -- 2445
		if lo > tmin then -- 2445
			tmin = lo -- 2447
		end -- 2447
		if hi < tmax then -- 2447
			tmax = hi -- 2450
		end -- 2450
	end -- 2450
	return tmax >= tmin and tmin or -1 -- 2453
end -- 2453
function drawCartShape(draw, play, w, h, c, axleX) -- 2456
	local half = c.bodyW / 2 -- 2457
	local x0 = axleX - half -- 2458
	local x1 = axleX + half -- 2459
	play:drawBox( -- 2460
		draw, -- 2460
		w, -- 2460
		h, -- 2460
		x0, -- 2460
		x1, -- 2460
		c.baseY + c.wheelR, -- 2460
		c.baseY + c.wheelR + c.bodyH, -- 2460
		CART_FILL -- 2460
	) -- 2460
	draw:drawCircle( -- 2461
		Vec2( -- 2461
			play:sx(x0 + c.bodyW * 0.28, w), -- 2461
			play:sy(c.baseY + c.wheelR, h) -- 2461
		), -- 2461
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2461
		Color(52, 50, 48, 255) -- 2461
	) -- 2461
	draw:drawCircle( -- 2462
		Vec2( -- 2462
			play:sx(x1 - c.bodyW * 0.28, w), -- 2462
			play:sy(c.baseY + c.wheelR, h) -- 2462
		), -- 2462
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2462
		Color(52, 50, 48, 255) -- 2462
	) -- 2462
	local cx = c.clothSide < 0 and x0 or x1 -- 2463
	play:drawBox( -- 2464
		draw, -- 2464
		w, -- 2464
		h, -- 2464
		cx - 10, -- 2464
		cx + 10, -- 2464
		c.baseY + c.wheelR + c.bodyH, -- 2464
		c.baseY + c.wheelR + c.bodyH + 18, -- 2464
		CLOTH -- 2464
	) -- 2464
end -- 2464
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
function Play.prototype.____constructor(self, room, resume) -- 306
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
	self.dogX = 0 -- 279
	self.dogDir = 1 -- 280
	self.dogState = "patrol" -- 281
	self.dogT = 0 -- 282
	self.dogTargetX = 0 -- 283
	self.scavSee = 0 -- 285
	self.scavChase = false -- 286
	self.gateSpawned = 0 -- 288
	self.gateFailCount = 0 -- 290
	self.paused = false -- 292
	self.ticks = 0 -- 294
	self.view = {zoom = 1, ox = 0, oy = 0} -- 296
	self.ox = 0 -- 298
	self.aimX = 0 -- 300
	self.aimY = 0 -- 301
	self.viewW = 0 -- 303
	self.viewH = 0 -- 304
	self.ox = room.originX -- 308
	self.room = withOrigin(room) -- 309
	local wr = self.room -- 310
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 311
	self:buildWorld() -- 312
	self.childMode = wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower" -- 314
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 315
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 316
	self.player = makeActor(wr, playerIdx) -- 317
	self.partner = makeActor(wr, partnerIdx) -- 318
	self.phase = phaseOf(wr.key) -- 319
	if wr.story ~= nil then -- 319
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 321
	end -- 321
	self.cam.x = self.player.x -- 323
	self.cam.y = self.player.y + CAM_LOOK_UP -- 324
	self.cartAxle = wr.cart.startX -- 325
	self.escort = __TS__New( -- 326
		Escort, -- 326
		safeAnchorX(wr.marks) -- 326
	) -- 326
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 327
	self:buildEnemies() -- 328
	if resume ~= nil and resume.checkpoint > 0 then -- 328
		self.checkpoint = resume.checkpoint -- 331
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 331
			self.cartAxle = self.room.cart.endX -- 333
			self.cartDocked = true -- 334
			self.player.x = self.ox + 380 -- 337
			self.player.y = 0 -- 338
			self.player.vy = 0 -- 339
			self.player.onGround = true -- 340
			self.cam.x = self.player.x -- 341
			self.cam.y = self.player.y + CAM_LOOK_UP -- 342
		end -- 342
	end -- 342
end -- 306
function Play.prototype.buildWorld(self) -- 348
	local room = self.room -- 349
	self.boxes = {} -- 350
	self.floors = {} -- 351
	local i = 0 -- 352
	do -- 352
		i = 0 -- 353
		while i < #room.floors do -- 353
			local f = room.floors[i + 1] -- 354
			local ____self_floors_0 = self.floors -- 354
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 355
			i = i + 1 -- 353
		end -- 353
	end -- 353
	do -- 353
		i = 0 -- 357
		while i < #room.solids do -- 357
			local s = room.solids[i + 1] -- 358
			local ____self_boxes_1 = self.boxes -- 358
			____self_boxes_1[#____self_boxes_1 + 1] = { -- 359
				x0 = s.x, -- 359
				x1 = s.x + s.w, -- 359
				y0 = s.y, -- 359
				y1 = s.y + s.h, -- 359
				passable = s.passable == true -- 359
			} -- 359
			i = i + 1 -- 357
		end -- 357
	end -- 357
	do -- 357
		i = 0 -- 361
		while i < #room.stairs do -- 361
			local st = room.stairs[i + 1] -- 362
			local n = st.steps + 1 -- 363
			local stepW = (st.x1 - st.x0) / n -- 364
			local k = 0 -- 365
			do -- 365
				k = 0 -- 366
				while k < n do -- 366
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 367
					local x0 = st.x0 + stepW * k -- 368
					local ____self_boxes_2 = self.boxes -- 368
					____self_boxes_2[#____self_boxes_2 + 1] = { -- 370
						x0 = x0, -- 370
						x1 = x0 + stepW, -- 370
						y0 = -8, -- 370
						y1 = y, -- 370
						passable = true -- 370
					} -- 370
					k = k + 1 -- 366
				end -- 366
			end -- 366
			i = i + 1 -- 361
		end -- 361
	end -- 361
end -- 348
function Play.prototype.buildEnemies(self) -- 375
	self.enemies = {} -- 376
	if self.room.key == "checkpoint" then -- 376
		local ____self_enemies_3 = self.enemies -- 376
		____self_enemies_3[#____self_enemies_3 + 1] = { -- 378
			x = self.ox + 430, -- 378
			y = 0, -- 378
			w = 26, -- 378
			h = 84, -- 378
			alive = true, -- 378
			hitT = 0, -- 378
			warnT = 0, -- 378
			fireCd = 0 -- 378
		} -- 378
		local ____self_enemies_4 = self.enemies -- 378
		____self_enemies_4[#____self_enemies_4 + 1] = { -- 379
			x = self.ox + 505, -- 379
			y = 0, -- 379
			w = 26, -- 379
			h = 84, -- 379
			alive = true, -- 379
			hitT = 0, -- 379
			warnT = 0, -- 379
			fireCd = 0 -- 379
		} -- 379
		return -- 380
	end -- 380
	if self.room.key == "street" then -- 380
		local ____self_enemies_5 = self.enemies -- 380
		____self_enemies_5[#____self_enemies_5 + 1] = { -- 384
			x = self.ox + 340, -- 384
			y = 0, -- 384
			w = 26, -- 384
			h = 84, -- 384
			alive = true, -- 384
			hitT = 0, -- 384
			warnT = 0, -- 384
			fireCd = 0 -- 384
		} -- 384
		local ____self_enemies_6 = self.enemies -- 384
		____self_enemies_6[#____self_enemies_6 + 1] = { -- 385
			x = self.ox + 560, -- 385
			y = 0, -- 385
			w = 26, -- 385
			h = 84, -- 385
			alive = true, -- 385
			hitT = 0, -- 385
			warnT = 0, -- 385
			fireCd = 0 -- 385
		} -- 385
	end -- 385
end -- 375
function Play.prototype.update(self, dt, input) -- 391
	if input.pause.pressed then -- 391
		self.paused = not self.paused -- 393
	end -- 393
	if self.flashT > 0 then -- 393
		self.flashT = self.flashT - dt -- 396
		if self.flashT <= 0 then -- 396
			self.flash = "" -- 398
		end -- 398
	end -- 398
	if self.traceT > 0 then -- 398
		self.traceT = self.traceT - dt -- 402
		if self.traceT <= 0 then -- 402
			self.trace = nil -- 404
		end -- 404
	end -- 404
	if self.paused then -- 404
		self:updateCamera(dt) -- 408
		return -- 409
	end -- 409
	self.ticks = self.ticks + 1 -- 412
	local p = self.player -- 413
	self:stepPlayer(p, dt, input) -- 414
	self:stepEnemies(dt, input) -- 416
	self:stepStory(dt, input) -- 417
	self:stepEscort(dt, input) -- 418
	self:stepVillage(dt, input) -- 419
	self:stepChase(dt, input) -- 420
	self:stepInteract(dt, input) -- 421
	self:updateGate() -- 422
	self:updateCamera(dt) -- 423
end -- 391
function Play.prototype.nearCover(self, a) -- 427
	local i = 0 -- 428
	do -- 428
		i = 0 -- 429
		while i < #self.boxes do -- 429
			do -- 429
				local b = self.boxes[i + 1] -- 430
				if b.passable == true or b.y1 - b.y0 < 44 then -- 430
					goto __continue35 -- 432
				end -- 432
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 432
					goto __continue35 -- 435
				end -- 435
				local half = a.w / 2 -- 437
				if math.min( -- 437
					math.abs(a.x + half - b.x0), -- 438
					math.abs(a.x - half - b.x1) -- 438
				) < 24 then -- 438
					return true -- 439
				end -- 439
			end -- 439
			::__continue35:: -- 439
			i = i + 1 -- 429
		end -- 429
	end -- 429
	return false -- 442
end -- 427
function Play.prototype.nearLowLedge(self, a) -- 446
	local reach = 26 -- 447
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 448
	local x1 = x0 + reach -- 449
	local i = 0 -- 450
	do -- 450
		i = 0 -- 451
		while i < #self.boxes do -- 451
			do -- 451
				local b = self.boxes[i + 1] -- 452
				if b.x1 <= x0 or b.x0 >= x1 then -- 452
					goto __continue41 -- 454
				end -- 454
				local rise = b.y1 - a.y -- 456
				if rise > 0 and rise <= LEDGE_RISE then -- 456
					return true -- 458
				end -- 458
			end -- 458
			::__continue41:: -- 458
			i = i + 1 -- 451
		end -- 451
	end -- 451
	return false -- 461
end -- 446
function Play.prototype.stepPlayer(self, a, dt, input) -- 464
	if not a.alive then -- 464
		return -- 466
	end -- 466
	local isChild = self.childMode -- 468
	if self:storyLocked() then -- 468
		a.vx = 0 -- 471
		a.crouch = false -- 472
		a.h = isChild and CHILD_H or SOLDIER_H -- 473
		self:fallY(a, dt) -- 474
		return -- 475
	end -- 475
	if not isChild and self.escort.state == "calming" then -- 475
		a.crouch = false -- 479
		a.h = SOLDIER_H -- 480
		a.vx = 0 -- 481
		self:fallY(a, dt) -- 482
		return -- 483
	end -- 483
	a.crouch = isChild and input.crouch.held and a.onGround -- 485
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 486
	a.covered = not isChild and input.cover.held and self:nearCover(a) -- 487
	if a.rollT > 0 then -- 487
		a.rollT = a.rollT - dt -- 491
		a.vx = a.facing * ROLL_SPEED -- 492
		self:slideX(a, a.vx * dt) -- 493
		self:fallY(a, dt) -- 494
		if a.rollT <= 0 then -- 494
			self:flashSet("翻滚结束", 0.5) -- 496
		end -- 496
		return -- 498
	end -- 498
	if not isChild and input.jump.pressed and a.onGround then -- 498
		if input.moveX ~= 0 then -- 498
			a.facing = input.moveX > 0 and 1 or -1 -- 503
		end -- 503
		if self:nearLowLedge(a) then -- 503
			a.vy = SOLDIER_JUMP -- 507
			a.onGround = false -- 508
			self:flashSet("翻上去", 0.3) -- 509
			return -- 510
		end -- 510
		a.rollT = ROLL_TIME -- 512
		self:flashSet("翻滚", 0.3) -- 513
		return -- 514
	end -- 514
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 517
	if isChild then -- 517
		if input.cover.held then -- 517
			speed = CHILD_SLOW -- 520
		end -- 520
		if a.crouch then -- 520
			speed = CHILD_SLOW -- 523
		end -- 523
	elseif a.covered then -- 523
		speed = SOLDIER_SPEED * 0.45 -- 526
	end -- 526
	local dir = self.gripping and 0 or input.moveX -- 530
	if dir ~= 0 then -- 530
		a.facing = dir > 0 and 1 or -1 -- 532
	end -- 532
	a.vx = dir * speed -- 534
	if isChild and input.jump.pressed and a.onGround and not a.crouch then -- 534
		a.vy = CHILD_JUMP -- 538
		a.onGround = false -- 539
		self:flashSet("跳", 0.25) -- 540
	end -- 540
	self:slideX(a, a.vx * dt) -- 543
	self:fallY(a, dt) -- 544
	if not isChild and input.fire.pressed then -- 544
		self:shoot(a) -- 548
	end -- 548
end -- 464
function Play.prototype.stepPartner(self, p, dt) -- 553
	local a = self.partner -- 554
	if not a.alive then -- 554
		return -- 556
	end -- 556
	a.crouch = false -- 558
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 559
	a.vx = 0 -- 560
	self:fallY(a, dt) -- 561
end -- 553
function Play.prototype.stepEscort(self, dt, input) -- 568
	local a = self.partner -- 569
	if not a.alive then -- 569
		return -- 571
	end -- 571
	if not self:escortOn() then -- 571
		a.vx = 0 -- 574
		self:fallY(a, dt) -- 575
		return -- 576
	end -- 576
	local p = self.player -- 578
	local dist = math.abs(p.x - a.x) -- 579
	self.calmConsumed = self.escort:update( -- 580
		input, -- 580
		p.x, -- 580
		p.facing, -- 580
		a.x, -- 580
		dist -- 580
	) -- 580
	a.crouch = self.escort.crouchPose -- 581
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 582
	local dir = self.escort:moveDir(a.x) -- 583
	a.vx = dir * CHILD_SPEED -- 584
	if dir ~= 0 then -- 584
		a.facing = dir -- 586
		local before = a.x -- 587
		self:slideX(a, dir * CHILD_SPEED * dt) -- 588
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 588
			a.vy = CHILD_JUMP -- 591
			a.onGround = false -- 592
		end -- 592
	end -- 592
	self:fallY(a, dt) -- 595
end -- 568
function Play.prototype.escortOn(self) -- 599
	if self.room.key == "checkpoint" then -- 599
		return true -- 601
	end -- 601
	if self.room.key == "prologue" then -- 601
		return self.phase == "prologue-follow" -- 604
	end -- 604
	return self.room.key == "street" -- 606
end -- 599
function Play.prototype.storyLocked(self) -- 610
	if self.caughtT > 0 then -- 610
		return true -- 612
	end -- 612
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 612
		return true -- 615
	end -- 615
	if self.room.key == "gate" and self.phase == "gate-count" then -- 615
		return true -- 618
	end -- 618
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 618
		return true -- 621
	end -- 621
	return false -- 623
end -- 610
function Play.prototype.swapToChild(self, x) -- 627
	local tmp = self.player -- 628
	self.player = self.partner -- 629
	self.partner = tmp -- 630
	self.childMode = true -- 631
	self.player.alive = true -- 632
	self.player.x = self.ox + x -- 633
	self.player.y = 0 -- 634
	self.player.vy = 0 -- 635
	self.player.vx = 0 -- 636
	self.player.onGround = true -- 637
	self.player.crouch = false -- 638
	self.player.h = CHILD_H -- 639
	self.player.facing = 1 -- 640
	self.partner.alive = true -- 641
	self.cam.x = self.player.x -- 642
end -- 627
function Play.prototype.stepStory(self, dt, input) -- 646
	if self.room.key == "prologue" then -- 646
		self:stepPrologue(dt, input) -- 648
	elseif self.room.key == "street" then -- 648
		self:stepStreet(dt, input) -- 650
	elseif self.room.key == "gate" then -- 650
		self:stepGate(dt, input) -- 652
	elseif self.room.key == "tower" then -- 652
		self:stepTower(dt, input) -- 654
	end -- 654
end -- 646
function Play.prototype.stepPrologue(self, dt, input) -- 659
	local child = self.partner -- 660
	if self.phase == "prologue-wait" then -- 660
		child.crouch = true -- 662
		child.h = CHILD_CROUCH_H -- 663
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 664
		local near = math.abs(self.player.x - child.x) <= reach -- 666
		if near and input.interact.pressed then -- 666
			self.phase = "prologue-give" -- 668
			self.phaseTick = 0 -- 669
			self:flashSet("递出针套", 1) -- 670
		end -- 670
		return -- 672
	end -- 672
	if self.phase == "prologue-give" then -- 672
		self.phaseTick = self.phaseTick + 1 -- 675
		if self.phaseTick == 12 then -- 675
			self:flashSet("针套递过去", 0.7) -- 677
		elseif self.phaseTick == 36 then -- 677
			self:flashSet("纸条塞进针套", 0.9) -- 679
		elseif self.phaseTick >= 60 then -- 679
			self.phase = "prologue-follow" -- 681
			self.phaseTick = 0 -- 682
			child.crouch = false -- 683
			child.h = CHILD_H -- 684
			self:flashSet("她跟上了", 1.2) -- 685
		end -- 685
		return -- 687
	end -- 687
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 687
		self.wantRoom = "street" -- 691
		self:flashSet("进街道", 1.2) -- 692
	end -- 692
end -- 659
function Play.prototype.stepStreet(self, dt, input) -- 697
	local p = self.player -- 698
	local c = self.partner -- 699
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 699
		self.wantRoom = "checkpoint" -- 701
		self:flashSet("到检查站", 1.2) -- 702
	end -- 702
end -- 697
function Play.prototype.stepGate(self, dt, input) -- 707
	local ____temp_7 -- 708
	if self.room.story == nil then -- 708
		____temp_7 = nil -- 708
	else -- 708
		____temp_7 = self.room.story.gate -- 708
	end -- 708
	local g = ____temp_7 -- 708
	if g == nil then -- 708
		return -- 710
	end -- 710
	local p = self.player -- 712
	if self.phase == "gate-idle" then -- 712
		local a = self.partner -- 715
		local gap = g.waitX - a.x -- 716
		if math.abs(gap) > 3 then -- 716
			a.facing = gap > 0 and 1 or -1 -- 718
			a.vx = a.facing * CHILD_SPEED -- 719
			local beforeX = a.x -- 720
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 721
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 721
				a.vy = CHILD_JUMP -- 723
				a.onGround = false -- 724
			end -- 724
			self:fallY(a, dt) -- 726
		else -- 726
			a.vx = 0 -- 728
			a.x = g.waitX -- 729
		end -- 729
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 -- 732
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 733
		if atWinch and atWait then -- 733
			self.phase = "gate-hold" -- 735
			self.gateTick = 0 -- 736
			self.gateSpawned = 0 -- 737
			self:flashSet("两人就位 · 守点开始", 1.4) -- 738
		end -- 738
		return -- 740
	end -- 740
	if self.phase == "gate-hold" then -- 740
		self.gateTick = self.gateTick + 1 -- 743
		local marks = {0, 540, 900, 1500} -- 745
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 745
			local idx = self.gateSpawned -- 747
			local ____self_enemies_8 = self.enemies -- 747
			____self_enemies_8[#____self_enemies_8 + 1] = { -- 748
				x = self.ox + 620 + idx * 62, -- 749
				y = 0, -- 749
				w = 26, -- 749
				h = 84, -- 749
				alive = true, -- 750
				hitT = 0, -- 750
				warnT = 0, -- 750
				fireCd = 90 + idx * 45 -- 750
			} -- 750
			self.gateSpawned = self.gateSpawned + 1 -- 752
			self:flashSet( -- 753
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 753
				0.9 -- 753
			) -- 753
		end -- 753
		if self.gateTick == 900 then -- 753
			self:flashSet("灯灭了", 1) -- 756
		elseif self.gateTick == 2100 then -- 756
			self:flashSet("门底压下来了", 1) -- 758
		end -- 758
		if self.gateTick >= g.holdTicks then -- 758
			self.phase = "gate-send" -- 761
			self.phaseTick = 0 -- 762
			self.enemies = {} -- 764
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 765
		end -- 765
		return -- 767
	end -- 767
	if self.phase == "gate-send" then -- 767
		local near = math.abs(p.x - g.doorX) <= 60 -- 770
		if near and input.interact.pressed then -- 770
			self:swapToChild(g.doorX + 30) -- 772
			self.phase = "gate-count" -- 773
			self.countTick = 0 -- 774
			self.countArmed = false -- 776
			self.countPrevMove = input.moveX -- 777
			self:flashSet("门开了 · 送她出去", 1.8) -- 778
		end -- 778
		return -- 780
	end -- 780
	if self.phase == "gate-count" then -- 780
		self.countTick = self.countTick + 1 -- 783
		if self.countTick == 360 then -- 783
			self:flashSet("门关上", 0.9) -- 785
		elseif self.countTick == 1020 then -- 785
			self:flashSet("数到一百", 2.2) -- 787
		end -- 787
		local prevMove = self.countPrevMove -- 791
		self.countPrevMove = input.moveX -- 792
		if self.countTick >= 1440 then -- 792
			if prevMove <= 0 and input.moveX > 0 then -- 792
				self.countArmed = true -- 795
			end -- 795
			if self.countArmed and input.moveX > 0 then -- 795
				self.phase = "gate-walk" -- 798
				self.phaseTick = 0 -- 799
				self:flashSet("她迈出第一步", 1.4) -- 800
			end -- 800
		end -- 800
		return -- 803
	end -- 803
	if self.player.x >= g.exitX then -- 803
		self.wantRoom = "outside" -- 807
		self:flashSet("出城门 · 城外", 1.4) -- 808
	end -- 808
end -- 707
function Play.prototype.stepTower(self, dt, input) -- 813
	local ____temp_9 -- 814
	if self.room.story == nil then -- 814
		____temp_9 = nil -- 814
	else -- 814
		____temp_9 = self.room.story.tower -- 814
	end -- 814
	local t = ____temp_9 -- 814
	if t == nil then -- 814
		return -- 816
	end -- 816
	if self.phase == "tower-wait" then -- 816
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 819
		if near and input.interact.pressed then -- 819
			self.phase = "tower-knock" -- 821
			self.phaseTick = 0 -- 822
			self.knocks = 1 -- 823
			self:flashSet("敲一下", 0.6) -- 824
		end -- 824
		return -- 826
	end -- 826
	if self.phase == "tower-knock" then -- 826
		self.phaseTick = self.phaseTick + 1 -- 829
		if self.phaseTick == 12 then -- 829
			self.knocks = 2 -- 831
			self:flashSet("敲两下 · 第二声", 1) -- 832
		elseif self.phaseTick >= t.knockTicks then -- 832
			self.phase = "tower-given" -- 834
			self.phaseTick = 0 -- 835
			self:flashSet("门开了 · 提灯", 1.4) -- 836
		end -- 836
		return -- 838
	end -- 838
	if self.phase == "tower-given" then -- 838
		self.phaseTick = self.phaseTick + 1 -- 841
		if self.phaseTick == 60 then -- 841
			self:flashSet("她递出针套和纸条", 1.6) -- 843
		elseif self.phaseTick == 120 then -- 843
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 845
		elseif self.phaseTick >= 180 then -- 845
			self.phase = "tower-end" -- 847
			self.phaseTick = 0 -- 848
			self:flashSet("片尾 · E 再玩一次", 3) -- 849
		end -- 849
		return -- 851
	end -- 851
	if input.interact.pressed or input.retry.pressed then -- 851
		self.wantRoom = "prologue" -- 854
		self:flashSet("回到序章", 1.4) -- 855
	end -- 855
end -- 813
function Play.prototype.stepChase(self, dt, input) -- 860
	if self.caughtT > 0 then -- 860
		self.caughtT = self.caughtT - dt -- 862
		if self.caughtT <= 0 then -- 862
			self:recoverFromCaught() -- 864
		end -- 864
		return -- 866
	end -- 866
	if self.room.key == "village" then -- 866
		self:stepScavChase() -- 869
	elseif self.room.key == "forest" then -- 869
		self:stepDog(dt) -- 871
		if self.player.x >= self.ox + 1450 then -- 871
			self.wantRoom = "tower" -- 874
			self:flashSet("林缘 · 北塔", 1.4) -- 875
		end -- 875
	end -- 875
end -- 860
function Play.prototype.stepScavChase(self) -- 881
	local s = self.room.scavenger -- 882
	if s == nil then -- 882
		return -- 884
	end -- 884
	local p = self.player -- 886
	if self.passed and p.x > self.ox + 440 then -- 886
		if self.scavChase then -- 886
			self.scavChase = false -- 890
			self.scavState = "back" -- 891
			self.scavT = 0 -- 892
		end -- 892
		return -- 894
	end -- 894
	local dx = p.x - self.scavX -- 896
	local dist = math.abs(dx) -- 897
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 898
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 899
	if not self.scavChase then -- 899
		if visible then -- 899
			self.scavSee = self.scavSee + 1 -- 902
			if self.scavSee >= 24 then -- 902
				self.scavChase = true -- 904
				self.scavState = "chase" -- 905
				self.scavTargetX = p.x -- 906
				self:flashSet("他看见你了", 1.2) -- 907
			end -- 907
		else -- 907
			self.scavSee = 0 -- 910
		end -- 910
		return -- 912
	end -- 912
	local dir = p.x > self.scavX and 1 or -1 -- 915
	self.scavX = self.scavX + dir * 96 / 60 -- 916
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 916
		self:caught() -- 918
		return -- 919
	end -- 919
	if hidden then -- 919
		self.scavSee = 0 -- 923
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 924
		self.scavT = self.scavT - 1 -- 925
		if self.scavT <= 0 then -- 925
			self.scavChase = false -- 927
			self.scavState = "patrol" -- 928
			self:flashSet("他失去了目标", 1) -- 929
		end -- 929
	end -- 929
end -- 881
function Play.prototype.stepDog(self, dt) -- 935
	local ____temp_10 -- 936
	if self.room.story == nil then -- 936
		____temp_10 = nil -- 936
	else -- 936
		____temp_10 = self.room.story.dog -- 936
	end -- 936
	local dog = ____temp_10 -- 936
	if dog == nil then -- 936
		return -- 938
	end -- 938
	local p = self.player -- 940
	local dist = math.abs(p.x - self.dogX) -- 941
	if self.dogState == "patrol" then -- 941
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 943
		if self.dogX < dog.x0 then -- 943
			self.dogX = dog.x0 -- 945
			self.dogDir = 1 -- 946
		elseif self.dogX > dog.x1 then -- 946
			self.dogX = dog.x1 -- 948
			self.dogDir = -1 -- 949
		end -- 949
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 951
		if not p.crouch and moving and dist < dog.range then -- 951
			self.dogState = "ear" -- 953
			self.dogT = 18 -- 954
			self.dogTargetX = p.x -- 955
			self:flashSet("狗转耳朵", 0.8) -- 956
		end -- 956
		return -- 958
	end -- 958
	if self.dogState == "ear" then -- 958
		self.dogT = self.dogT - 1 -- 961
		if self.dogT <= 0 then -- 961
			self.dogState = "chase" -- 963
			self.dogTargetX = p.x -- 964
			self:flashSet("狗追来了", 1.4) -- 965
		end -- 965
		return -- 967
	end -- 967
	if self.dogState == "chase" then -- 967
		local dir = p.x > self.dogX and 1 or -1 -- 970
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 971
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 971
			self:caught() -- 973
			self.dogState = "sniff" -- 974
			self.dogT = 60 -- 975
		elseif dist > dog.range * 1.5 or p.crouch then -- 975
			self.dogState = "sniff" -- 977
			self.dogT = 60 -- 978
			self:flashSet("狗停下了", 0.9) -- 979
		end -- 979
		return -- 981
	end -- 981
	if self.dogState == "sniff" then -- 981
		self.dogT = self.dogT - 1 -- 984
		if self.dogT <= 0 then -- 984
			self.dogState = "back" -- 986
		end -- 986
		return -- 988
	end -- 988
	local dir = dog.x0 > self.dogX and 1 or -1 -- 991
	self.dogX = self.dogX + dir * dog.speed * dt -- 992
	if math.abs(self.dogX - dog.x0) < 2 then -- 992
		self.dogX = dog.x0 -- 994
		self.dogState = "patrol" -- 995
	end -- 995
end -- 935
function Play.prototype.caught(self) -- 999
	self.caughtT = 1 -- 1000
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1001
end -- 999
function Play.prototype.recoverFromCaught(self) -- 1005
	local p = self.player -- 1006
	p.x = self.ox + 140 -- 1007
	p.y = 0 -- 1008
	p.vy = 0 -- 1009
	p.vx = 0 -- 1010
	p.onGround = true -- 1011
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1011
		self.scavX = self.room.scavenger.x0 -- 1013
		self.scavState = "patrol" -- 1014
		self.scavSee = 0 -- 1015
		self.scavChase = false -- 1016
		self.scavT = 0 -- 1017
	end -- 1017
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1017
		self.dogX = self.room.story.dog.x0 -- 1020
		self.dogState = "patrol" -- 1021
		self.dogT = 0 -- 1022
	end -- 1022
	self.cam.x = p.x -- 1024
	self.cam.y = p.y + CAM_LOOK_UP -- 1025
	self:flashSet("回到安全点", 1.2) -- 1026
end -- 1005
function Play.prototype.updateGate(self) -- 1030
	if self.room.key ~= "checkpoint" then -- 1030
		self.gateOpen = false -- 1032
		return -- 1033
	end -- 1033
	local function inZone(x) -- 1035
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1035
	end -- 1035
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1036
end -- 1030
function Play.prototype.stepEnemies(self, dt, input) -- 1039
	local i = 0 -- 1040
	do -- 1040
		i = 0 -- 1041
		while i < #self.enemies do -- 1041
			local e = self.enemies[i + 1] -- 1042
			if e.hitT > 0 then -- 1042
				e.hitT = e.hitT - dt -- 1044
			end -- 1044
			i = i + 1 -- 1041
		end -- 1041
	end -- 1041
	if self.coveredFlash > 0 then -- 1041
		self.coveredFlash = self.coveredFlash - dt -- 1048
	end -- 1048
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 1048
		return -- 1052
	end -- 1052
	do -- 1052
		i = 0 -- 1054
		while i < #self.enemies do -- 1054
			do -- 1054
				local e = self.enemies[i + 1] -- 1055
				if not e.alive then -- 1055
					goto __continue169 -- 1057
				end -- 1057
				if e.warnT > 0 then -- 1057
					e.warnT = e.warnT - 1 -- 1060
					if e.warnT <= 0 then -- 1060
						self:enemyFire(e, input) -- 1062
					end -- 1062
					goto __continue169 -- 1064
				end -- 1064
				if e.fireCd > 0 then -- 1064
					e.fireCd = e.fireCd - 1 -- 1067
					if e.fireCd <= 0 then -- 1067
						e.warnT = WARN_TICKS -- 1069
					end -- 1069
				else -- 1069
					e.warnT = WARN_TICKS -- 1073
				end -- 1073
			end -- 1073
			::__continue169:: -- 1073
			i = i + 1 -- 1054
		end -- 1054
	end -- 1054
end -- 1039
function Play.prototype.enemyFire(self, e, input) -- 1079
	local p = self.player -- 1080
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 1080
		self:flashSet("枪声响在远处", 0.4) -- 1082
		e.fireCd = FIRE_COOLDOWN -- 1083
		return -- 1084
	end -- 1084
	local hugging = self:blockedByCover(e.x, p.x) -- 1087
	local covered = hugging and input.cover.held -- 1088
	if covered then -- 1088
		self.coveredFlash = 0.5 -- 1090
		self:flashSet("掩体挡下", 0.5) -- 1091
		e.fireCd = FIRE_COOLDOWN -- 1092
		return -- 1093
	end -- 1093
	self.hp = self.hp - 1 -- 1095
	self:flashSet( -- 1096
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 1096
		0.7 -- 1096
	) -- 1096
	e.fireCd = FIRE_COOLDOWN -- 1097
	if self.hp <= 0 then -- 1097
		self:gateFailed() -- 1099
	end -- 1099
end -- 1079
function Play.prototype.blockedByCover(self, ex, px) -- 1104
	local lo = math.min(ex, px) -- 1105
	local hi = math.max(ex, px) -- 1106
	local i = 0 -- 1107
	do -- 1107
		i = 0 -- 1108
		while i < #self.boxes do -- 1108
			do -- 1108
				local b = self.boxes[i + 1] -- 1109
				if b.passable == true or b.y1 - b.y0 < 44 then -- 1109
					goto __continue182 -- 1111
				end -- 1111
				local cx = (b.x0 + b.x1) / 2 -- 1113
				if cx <= lo + 8 or cx >= hi - 8 then -- 1113
					goto __continue182 -- 1115
				end -- 1115
				local hug = math.min( -- 1117
					math.abs(px - b.x0), -- 1117
					math.abs(px - b.x1) -- 1117
				) < 24 -- 1117
				if hug then -- 1117
					return true -- 1119
				end -- 1119
			end -- 1119
			::__continue182:: -- 1119
			i = i + 1 -- 1108
		end -- 1108
	end -- 1108
	return false -- 1122
end -- 1104
function Play.prototype.gateFailed(self) -- 1126
	local ____temp_11 -- 1127
	if self.room.story == nil then -- 1127
		____temp_11 = nil -- 1127
	else -- 1127
		____temp_11 = self.room.story.gate -- 1127
	end -- 1127
	local g = ____temp_11 -- 1127
	self:flashSet("被击倒 · 回绞盘重来", 2) -- 1128
	self.hp = self.maxHp -- 1129
	self.gateTick = 0 -- 1130
	self.gateSpawned = 0 -- 1131
	self.enemies = {} -- 1132
	self.gateFailCount = self.gateFailCount + 1 -- 1133
	self.player.x = self.ox + (g == nil and 130 or 130) -- 1134
	self.player.y = 0 -- 1135
	self.player.vy = 0 -- 1136
	self.player.onGround = true -- 1137
	self.player.crouch = false -- 1138
	self.player.h = SOLDIER_H -- 1139
	self.partner.x = self.ox + (g == nil and 900 or 900) -- 1140
	self.partner.y = 0 -- 1141
	self.partner.vy = 0 -- 1142
	self.partner.onGround = true -- 1143
	self.cam.x = self.player.x -- 1144
	self.phase = "gate-hold" -- 1145
	self.phaseTick = 0 -- 1146
end -- 1126
function Play.prototype.stepInteract(self, dt, input) -- 1149
	local p = self.player -- 1150
	local calmUsed = self.calmConsumed -- 1151
	self.calmConsumed = false -- 1152
	self.focusCart = false -- 1153
	if self.room.key == "outside" then -- 1153
		local c = self.room.cart -- 1155
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 1156
		local dy = p.y - c.baseY -- 1157
		self.focusCart = dx * dx + dy * dy < CART_REACH * CART_REACH -- 1158
	end -- 1158
	self:stepCart(dt, input) -- 1160
	if calmUsed then -- 1160
		self:flashSet("安抚 · 敲两下", 0.8) -- 1164
	elseif input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" then -- 1164
		if self.knockT > 0 then -- 1164
			self.knocks = self.knocks + 1 -- 1168
		else -- 1168
			self.knocks = 1 -- 1170
		end -- 1170
		self.knockT = 1.2 -- 1172
		if self.knocks >= 2 then -- 1172
			self:flashSet("敲两下", 0.8) -- 1174
			self.knocks = 0 -- 1175
		else -- 1175
			self:flashSet("敲一下", 0.5) -- 1177
		end -- 1177
	elseif self.knockT > 0 then -- 1177
		self.knockT = self.knockT - dt -- 1180
		if self.knockT <= 0 then -- 1180
			self.knocks = 0 -- 1182
		end -- 1182
	end -- 1182
	local i = 0 -- 1187
	do -- 1187
		i = 0 -- 1188
		while i < #self.room.marks do -- 1188
			do -- 1188
				local m = self.room.marks[i + 1] -- 1189
				if m.kind ~= 0 then -- 1189
					goto __continue198 -- 1191
				end -- 1191
				local subjects = {self.partner, self.player} -- 1193
				local k = 0 -- 1194
				do -- 1194
					k = 0 -- 1195
					while k < #subjects do -- 1195
						do -- 1195
							local s = subjects[k + 1] -- 1196
							if not s.alive then -- 1196
								goto __continue201 -- 1198
							end -- 1198
							local dx = s.x - m.x -- 1200
							local dy = s.y - m.y -- 1201
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 1201
								self.checkpoint = m.x -- 1203
								self.checkpointCartAxle = self.cartAxle -- 1204
								if self.cartDocked then -- 1204
									self:flashSet("检查点 · 车已落窝", 1) -- 1206
								else -- 1206
									self:flashSet("检查点 · 车还没到位", 1) -- 1208
								end -- 1208
							end -- 1208
						end -- 1208
						::__continue201:: -- 1208
						k = k + 1 -- 1195
					end -- 1195
				end -- 1195
			end -- 1195
			::__continue198:: -- 1195
			i = i + 1 -- 1188
		end -- 1188
	end -- 1188
	self:checkCarryGate() -- 1214
end -- 1149
function Play.prototype.stepVillage(self, dt, input) -- 1218
	if self.room.key ~= "village" then -- 1218
		return -- 1220
	end -- 1220
	local p = self.player -- 1222
	local bottle = self.room.bottle -- 1223
	local scav = self.room.scavenger -- 1224
	if not self.hasBottle and bottle ~= nil then -- 1224
		local dx = p.x - bottle.x -- 1228
		local dy = p.y + p.h * 0.5 - bottle.y -- 1229
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 1229
			self.hasBottle = true -- 1231
			self:flashSet("拾起瓶子", 0.8) -- 1232
		end -- 1232
	end -- 1232
	if self.hasBottle then -- 1232
		if input.aim.held then -- 1232
			self.aimHold = self.aimHold + dt -- 1239
			if self.aimHold > 1.2 then -- 1239
				self.aimHold = 1.2 -- 1241
			end -- 1241
		elseif input.aim.released then -- 1241
			local ____end = self:bottleEnd() -- 1244
			self:throwBottle(____end.x, ____end.y) -- 1245
			self.aimHold = 0 -- 1246
		end -- 1246
	else -- 1246
		self.aimHold = 0 -- 1249
	end -- 1249
	local fly = self.bottleFly -- 1253
	if fly ~= nil then -- 1253
		fly.vy = fly.vy - GRAVITY * dt -- 1255
		fly.x = fly.x + fly.vx * dt -- 1256
		fly.y = fly.y + fly.vy * dt -- 1257
		local g = self:groundAt(fly.x, fly.y + 4, 3) -- 1258
		local ____temp_13 = self.bottleTargetX >= 0 -- 1259
		if ____temp_13 then -- 1259
			local ____temp_12 -- 1259
			if fly.vx >= 0 then -- 1259
				____temp_12 = fly.x >= self.bottleTargetX -- 1259
			else -- 1259
				____temp_12 = fly.x <= self.bottleTargetX -- 1259
			end -- 1259
			____temp_13 = ____temp_12 -- 1259
		end -- 1259
		local reached = ____temp_13 -- 1259
		if fly.y <= g or reached then -- 1259
			local landX = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 1261
			self.bottleFly = nil -- 1262
			self.bottleLandX = landX -- 1263
			self.bottleLandT = 0.9 -- 1264
			self:hearBottle(landX) -- 1265
		end -- 1265
	end -- 1265
	if self.bottleLandT > 0 then -- 1265
		self.bottleLandT = self.bottleLandT - dt -- 1269
	end -- 1269
	if scav ~= nil then -- 1269
		self:stepScav(dt, scav) -- 1273
	end -- 1273
	local line = self.room.passLine -- 1276
	if line ~= nil and not self.passed and p.x >= line then -- 1276
		self.passed = true -- 1278
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 1279
	end -- 1279
	if self.passed and p.x >= self.ox + 640 then -- 1279
		self.wantRoom = "forest" -- 1283
		self:flashSet("出院 · 北塔森林", 1.4) -- 1284
	end -- 1284
end -- 1218
function Play.prototype.bottleEnd(self) -- 1289
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1290
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 1291
	return {x = aim.x, y = g} -- 1292
end -- 1289
function Play.prototype.throwBottle(self, tx, ty) -- 1296
	local p = self.player -- 1297
	local x0 = p.x + p.facing * 10 -- 1298
	local y0 = p.y + p.h * 0.7 -- 1299
	local T = 0.62 -- 1300
	self.bottleTargetX = tx -- 1301
	self.bottleTargetY = ty -- 1302
	local vx = (tx - x0) / T -- 1303
	local vy = (ty - y0 + 0.5 * GRAVITY * T * T) / T -- 1304
	self.bottleFly = {x = x0, y = y0, vx = vx, vy = vy} -- 1305
	self.hasBottle = false -- 1306
	self:flashSet("投出", 0.4) -- 1307
end -- 1296
function Play.prototype.hearBottle(self, x) -- 1311
	local s = self.room.scavenger -- 1312
	if s == nil then -- 1312
		return -- 1314
	end -- 1314
	if math.abs(x - self.scavX) > s.range then -- 1314
		self:flashSet("落地 · 他没听见", 0.6) -- 1317
		return -- 1318
	end -- 1318
	self.scavState = "turn" -- 1320
	self.scavT = s.hearTicks -- 1321
	self.scavTargetX = x -- 1322
	self:flashSet("砖地一响 · 他转头", 0.9) -- 1323
end -- 1311
function Play.prototype.stepScav(self, dt, s) -- 1327
	if self.scavState == "chase" then -- 1327
		return -- 1330
	end -- 1330
	if self.scavState == "turn" then -- 1330
		self.scavT = self.scavT - 1 -- 1333
		if self.scavT <= 0 then -- 1333
			self.scavState = "walk" -- 1335
		end -- 1335
		return -- 1337
	end -- 1337
	if self.scavState == "walk" then -- 1337
		local d = self.scavTargetX - self.scavX -- 1340
		if math.abs(d) < 4 then -- 1340
			self.scavState = "stall" -- 1342
			self.scavT = s.stallTicks -- 1343
			return -- 1344
		end -- 1344
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 1346
		return -- 1347
	end -- 1347
	if self.scavState == "stall" then -- 1347
		self.scavT = self.scavT - 1 -- 1350
		if self.scavT <= 0 then -- 1350
			self.scavState = "back" -- 1352
		end -- 1352
		return -- 1354
	end -- 1354
	if self.scavState == "back" then -- 1354
		local home = math.max( -- 1357
			s.x0, -- 1357
			math.min(s.x1, self.scavX) -- 1357
		) -- 1357
		if math.abs(home - self.scavX) < 2 then -- 1357
			self.scavState = "patrol" -- 1359
			return -- 1360
		end -- 1360
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 1362
		return -- 1363
	end -- 1363
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 1365
	if self.scavX >= s.x1 then -- 1365
		self.scavX = s.x1 -- 1367
		self.scavDir = -1 -- 1368
	elseif self.scavX <= s.x0 then -- 1368
		self.scavX = s.x0 -- 1370
		self.scavDir = 1 -- 1371
	end -- 1371
end -- 1327
function Play.prototype.stepCart(self, dt, input) -- 1379
	local p = self.player -- 1380
	local c = self.room.cart -- 1381
	local handleX = self.cartAxle + c.handleOffset -- 1382
	if self.gripping then -- 1382
		if not input.interact.held then -- 1382
			self.gripping = false -- 1386
			self:flashSet("松开车把", 0.4) -- 1387
			return -- 1388
		end -- 1388
	else -- 1388
		if not input.interact.pressed then -- 1388
			return -- 1392
		end -- 1392
		if math.abs(p.x - handleX) > CART_REACH or math.abs(p.y - c.baseY) > 40 then -- 1392
			return -- 1395
		end -- 1395
		self.gripping = true -- 1397
		self:flashSet("握住车把", 0.4) -- 1398
		return -- 1399
	end -- 1399
	if self.cartDocked then -- 1399
		return -- 1403
	end -- 1403
	local dir = input.moveX -- 1405
	if dir == 0 then -- 1405
		return -- 1407
	end -- 1407
	local lo = math.min(c.startX, c.endX) -- 1409
	local hi = math.max(c.startX, c.endX) -- 1410
	local next = self.cartAxle + dir * CART_SPEED * dt -- 1411
	if next < lo then -- 1411
		next = lo -- 1413
	end -- 1413
	if next > hi then -- 1413
		next = hi -- 1416
	end -- 1416
	local delta = next - self.cartAxle -- 1418
	if delta == 0 then -- 1418
		return -- 1420
	end -- 1420
	self.cartAxle = next -- 1422
	p.x = p.x + delta -- 1423
	p.facing = dir > 0 and 1 or -1 -- 1424
	self:slideX(p, 0) -- 1425
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > CART_REACH then -- 1425
		self.gripping = false -- 1427
		self:flashSet("跟不上了，脱手", 0.6) -- 1428
		return -- 1429
	end -- 1429
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 1429
		self.cartDocked = true -- 1432
		self.gripping = false -- 1433
		self:flashSet("车轮落窝", 1.2) -- 1434
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 1434
		self:flashSet("车轮回到起点", 0.5) -- 1436
	end -- 1436
end -- 1379
function Play.prototype.checkCarryGate(self) -- 1444
	if self.room.key == "checkpoint" then -- 1444
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 1444
			self.carryCartAxle = self.cartAxle -- 1447
			self.carryCartDocked = self.cartDocked -- 1448
			self.wantRoom = "gate" -- 1449
			self:flashSet("出检查站 · 城门", 1.2) -- 1450
		end -- 1450
		return -- 1452
	end -- 1452
	if self.room.key == "outside" then -- 1452
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 1452
			self.carryCartAxle = self.cartAxle -- 1458
			self.carryCartDocked = self.cartDocked -- 1459
			self.wantRoom = "village" -- 1460
			self:flashSet("墙根走完 · 进村口", 1.2) -- 1461
		end -- 1461
	end -- 1461
end -- 1444
function Play.prototype.aimAt(self, wx, wy) -- 1468
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 1469
	self.aimX = s.x -- 1470
	self.aimY = s.y -- 1471
end -- 1468
function Play.prototype.shoot(self, a) -- 1474
	local ox = a.x + a.facing * 8 -- 1475
	local oy = a.y + a.h * 0.72 -- 1476
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1478
	local dx = aim.x - ox -- 1479
	local dy = aim.y - oy -- 1480
	local len = math.sqrt(dx * dx + dy * dy) -- 1481
	if len < 0.001 then -- 1481
		dx = a.facing -- 1483
		dy = 0 -- 1484
	else -- 1484
		dx = dx / len -- 1486
		dy = dy / len -- 1487
	end -- 1487
	if dx ~= 0 then -- 1487
		a.facing = dx > 0 and 1 or -1 -- 1490
	end -- 1490
	local hitEnemy = self:raycast( -- 1493
		ox, -- 1493
		oy, -- 1493
		dx, -- 1493
		dy, -- 1493
		true -- 1493
	) -- 1493
	local hitWall = self:raycast( -- 1494
		ox, -- 1494
		oy, -- 1494
		dx, -- 1494
		dy, -- 1494
		false -- 1494
	) -- 1494
	local tEnemy = hitEnemy.t -- 1495
	local tWall = hitWall.t -- 1496
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 1497
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 1498
	self.trace = { -- 1500
		x0 = ox, -- 1500
		y0 = oy, -- 1500
		x1 = ox + dx * t, -- 1500
		y1 = oy + dy * t, -- 1500
		hit = hit -- 1500
	} -- 1500
	self.traceT = 0.12 -- 1501
	self:applyFireDanger(ox) -- 1502
	if hit then -- 1502
		local i = hitEnemy.index -- 1504
		local e = self.enemies[i + 1] -- 1505
		e.alive = false -- 1506
		e.hitT = 0.4 -- 1507
		self:flashSet("命中", 0.6) -- 1508
	else -- 1508
		self:flashSet("打空", 0.35) -- 1510
	end -- 1510
end -- 1474
function Play.prototype.applyFireDanger(self, shotX) -- 1515
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 1515
		return -- 1517
	end -- 1517
	local dangerX = shotX -- 1519
	local best = -1 -- 1520
	local bestD = 1000000000 -- 1521
	local i = 0 -- 1522
	do -- 1522
		i = 0 -- 1523
		while i < #self.enemies do -- 1523
			do -- 1523
				local e = self.enemies[i + 1] -- 1524
				if not e.alive then -- 1524
					goto __continue267 -- 1526
				end -- 1526
				local d = math.abs(e.x - self.partner.x) -- 1528
				if d < bestD then -- 1528
					bestD = d -- 1530
					best = i -- 1531
				end -- 1531
			end -- 1531
			::__continue267:: -- 1531
			i = i + 1 -- 1523
		end -- 1523
	end -- 1523
	if best >= 0 then -- 1523
		dangerX = self.enemies[best + 1].x -- 1535
	end -- 1535
	local exposed = self:childExposed(dangerX) -- 1537
	local before = self.escort.fear -- 1538
	local after = self.escort:applyDanger(self.nextDangerId, exposed, self.partner.x) -- 1539
	self.nextDangerId = self.nextDangerId + 1 -- 1540
	if after > before then -- 1540
		self:flashSet( -- 1542
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 1542
			1 -- 1542
		) -- 1542
	elseif not exposed then -- 1542
		self:flashSet("枪声没够到她", 0.5) -- 1544
	end -- 1544
end -- 1515
function Play.prototype.childExposed(self, dangerX) -- 1549
	local c = self.partner -- 1550
	if not c.alive then -- 1550
		return false -- 1552
	end -- 1552
	if c.x > self.ox + 240 and c.x < self.ox + 340 then -- 1552
		return false -- 1555
	end -- 1555
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 1555
		return false -- 1558
	end -- 1558
	local toDanger = dangerX - c.x -- 1560
	local toPlayer = self.player.x - c.x -- 1561
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) then -- 1561
		return false -- 1563
	end -- 1563
	return true -- 1565
end -- 1549
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 1569
	local best = -1 -- 1570
	local bestI = -1 -- 1571
	local i = 0 -- 1572
	if enemies then -- 1572
		do -- 1572
			i = 0 -- 1574
			while i < #self.enemies do -- 1574
				do -- 1574
					local e = self.enemies[i + 1] -- 1575
					if not e.alive then -- 1575
						goto __continue281 -- 1577
					end -- 1577
					local t = hitBox( -- 1579
						ox, -- 1579
						oy, -- 1579
						dx, -- 1579
						dy, -- 1579
						e.x - e.w / 2, -- 1579
						e.x + e.w / 2, -- 1579
						e.y, -- 1579
						e.y + e.h -- 1579
					) -- 1579
					if t >= 0 and (best < 0 or t < best) then -- 1579
						best = t -- 1581
						bestI = i -- 1582
					end -- 1582
				end -- 1582
				::__continue281:: -- 1582
				i = i + 1 -- 1574
			end -- 1574
		end -- 1574
		return {t = best, index = bestI} -- 1585
	end -- 1585
	do -- 1585
		i = 0 -- 1587
		while i < #self.boxes do -- 1587
			local b = self.boxes[i + 1] -- 1588
			local t = hitBox( -- 1589
				ox, -- 1589
				oy, -- 1589
				dx, -- 1589
				dy, -- 1589
				b.x0, -- 1589
				b.x1, -- 1589
				b.y0, -- 1589
				b.y1 -- 1589
			) -- 1589
			if t >= 0 and (best < 0 or t < best) then -- 1589
				best = t -- 1591
			end -- 1591
			i = i + 1 -- 1587
		end -- 1587
	end -- 1587
	if dy < 0 then -- 1587
		local t = (0 - oy) / dy -- 1596
		if t >= 0 and (best < 0 or t < best) then -- 1596
			best = t -- 1598
		end -- 1598
	end -- 1598
	return {t = best, index = -1} -- 1601
end -- 1569
function Play.prototype.slideX(self, a, dx) -- 1605
	local nx = a.x + dx -- 1606
	local half = a.w / 2 -- 1607
	local room = self.room -- 1608
	nx = math.max( -- 1609
		room.minX + half, -- 1609
		math.min(room.maxX - half, nx) -- 1609
	) -- 1609
	local i = 0 -- 1610
	do -- 1610
		i = 0 -- 1611
		while i < #self.boxes do -- 1611
			do -- 1611
				local b = self.boxes[i + 1] -- 1612
				if b.passable == true then -- 1612
					goto __continue291 -- 1614
				end -- 1614
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1614
					goto __continue291 -- 1617
				end -- 1617
				if nx + half > b.x0 and nx - half < b.x1 then -- 1617
					if a.x <= b.x0 then -- 1617
						nx = b.x0 - half -- 1621
					elseif a.x >= b.x1 then -- 1621
						nx = b.x1 + half -- 1623
					else -- 1623
						nx = a.x -- 1625
					end -- 1625
				end -- 1625
			end -- 1625
			::__continue291:: -- 1625
			i = i + 1 -- 1611
		end -- 1611
	end -- 1611
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 1611
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 1633
		local bx0 = self.cartAxle - CART_HALF -- 1634
		local bx1 = self.cartAxle + CART_HALF -- 1635
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 1635
			if a.x <= bx0 then -- 1635
				nx = bx0 - half -- 1638
			elseif a.x >= bx1 then -- 1638
				nx = bx1 + half -- 1640
			else -- 1640
				nx = a.x -- 1642
			end -- 1642
		end -- 1642
	end -- 1642
	local arch = room.arch -- 1650
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 1650
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 1652
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 1652
			if a.x <= arch.x0 then -- 1652
				nx = arch.x0 - half -- 1655
			elseif a.x >= arch.x1 then -- 1655
				nx = arch.x1 + half -- 1657
			end -- 1657
		end -- 1657
	end -- 1657
	a.x = nx -- 1661
end -- 1605
function Play.prototype.fallY(self, a, dt) -- 1665
	a.vy = a.vy - GRAVITY * dt -- 1666
	if a.vy < -900 then -- 1666
		a.vy = -900 -- 1668
	end -- 1668
	local ny = a.y + a.vy * dt -- 1670
	local half = a.w / 2 -- 1671
	if a.vy <= 0 then -- 1671
		local reach = a.onGround and STEP_UP or 0 -- 1674
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half) -- 1675
		if ny <= ground then -- 1675
			ny = ground -- 1677
			a.vy = 0 -- 1678
			a.onGround = true -- 1679
		else -- 1679
			a.onGround = false -- 1681
		end -- 1681
	else -- 1681
		a.onGround = false -- 1684
		local i = 0 -- 1685
		do -- 1685
			i = 0 -- 1686
			while i < #self.boxes do -- 1686
				do -- 1686
					local b = self.boxes[i + 1] -- 1687
					if b.passable == true then -- 1687
						goto __continue314 -- 1689
					end -- 1689
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 1689
						goto __continue314 -- 1692
					end -- 1692
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 1692
						ny = b.y0 - a.h -- 1695
						a.vy = 0 -- 1696
					end -- 1696
				end -- 1696
				::__continue314:: -- 1696
				i = i + 1 -- 1686
			end -- 1686
		end -- 1686
	end -- 1686
	a.y = ny -- 1700
end -- 1665
function Play.prototype.groundAt(self, x, ceiling, half) -- 1704
	local g = -9999 -- 1705
	local i = 0 -- 1706
	do -- 1706
		i = 0 -- 1707
		while i < #self.floors do -- 1707
			local f = self.floors[i + 1] -- 1708
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 1708
				g = f.y1 -- 1710
			end -- 1710
			i = i + 1 -- 1707
		end -- 1707
	end -- 1707
	do -- 1707
		i = 0 -- 1713
		while i < #self.boxes do -- 1713
			local b = self.boxes[i + 1] -- 1714
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 1714
				g = b.y1 -- 1716
			end -- 1716
			i = i + 1 -- 1713
		end -- 1713
	end -- 1713
	return g -- 1719
end -- 1704
function Play.prototype.updateCamera(self, dt) -- 1722
	local p = self.player -- 1723
	local tx = p.x + p.facing * 30 -- 1724
	local ty = p.y + CAM_LOOK_UP -- 1725
	local k = math.min(1, CAM_FOLLOW * dt) -- 1726
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 1727
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 1728
end -- 1722
function Play.prototype.clampCamera(self, w, h) -- 1732
	local room = self.room -- 1733
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 1734
	local spanX = room.maxX - room.minX -- 1735
	if spanX <= halfW * 2 then -- 1735
		self.cam.x = (room.minX + room.maxX) / 2 -- 1737
	else -- 1737
		self.cam.x = math.max( -- 1739
			room.minX + halfW, -- 1739
			math.min(room.maxX - halfW, self.cam.x) -- 1739
		) -- 1739
	end -- 1739
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 1742
	local spanY = room.height -- 1743
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 1744
	if spanY <= halfH * 2 then -- 1744
		self.cam.y = camY -- 1746
	else -- 1746
		self.cam.y = math.max( -- 1748
			camY, -- 1748
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 1748
		) -- 1748
	end -- 1748
end -- 1732
function Play.prototype.flashSet(self, text, t) -- 1752
	self.flash = text -- 1753
	self.flashT = t -- 1754
end -- 1752
function Play.prototype.statusText(self) -- 1758
	local p = self.player -- 1759
	local parts = {} -- 1760
	local who = self.childMode and "小满" or "周戍" -- 1761
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 1762
	if self.room.key == "prologue" then -- 1762
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1765
		if self.phase == "prologue-wait" then -- 1765
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 1767
		elseif self.phase == "prologue-give" then -- 1767
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 1769
		else -- 1769
			parts[#parts + 1] = "跟随" -- 1771
		end -- 1771
		if self.paused then -- 1771
			parts[#parts + 1] = "已暂停" -- 1774
		end -- 1774
		return table.concat(parts, " · ") -- 1776
	end -- 1776
	if self.room.key == "street" then -- 1776
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1779
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1780
		if self.paused then -- 1780
			parts[#parts + 1] = "已暂停" -- 1782
		end -- 1782
		return table.concat(parts, " · ") -- 1784
	end -- 1784
	if self.room.key == "gate" then -- 1784
		local ____temp_14 -- 1787
		if self.room.story == nil then -- 1787
			____temp_14 = nil -- 1787
		else -- 1787
			____temp_14 = self.room.story.gate -- 1787
		end -- 1787
		local g = ____temp_14 -- 1787
		if g ~= nil then -- 1787
			parts[#parts + 1] = self:gateLabel() -- 1789
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 1790
				0, -- 1791
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 1791
			))) .. " 秒" -- 1791
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1792
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1793
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 1794
			if self.gateFailCount > 0 then -- 1794
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 1796
			end -- 1796
		end -- 1796
		if self.paused then -- 1796
			parts[#parts + 1] = "已暂停" -- 1800
		end -- 1800
		return table.concat(parts, " · ") -- 1802
	end -- 1802
	if self.room.key == "forest" then -- 1802
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1805
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 1806
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 1807
		if self.caughtT > 0 then -- 1807
			parts[#parts + 1] = "复位中" -- 1809
		end -- 1809
		if self.paused then -- 1809
			parts[#parts + 1] = "已暂停" -- 1812
		end -- 1812
		return table.concat(parts, " · ") -- 1814
	end -- 1814
	if self.room.key == "tower" then -- 1814
		if self.phase == "tower-wait" then -- 1814
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 1818
		elseif self.phase == "tower-knock" then -- 1818
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 1820
		elseif self.phase == "tower-given" then -- 1820
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 1822
		else -- 1822
			parts[#parts + 1] = "片尾" -- 1824
		end -- 1824
		if self.paused then -- 1824
			parts[#parts + 1] = "已暂停" -- 1827
		end -- 1827
		return table.concat(parts, " · ") -- 1829
	end -- 1829
	if self.room.key == "village" then -- 1829
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1832
		if self.hasBottle then -- 1832
			parts[#parts + 1] = "有瓶" -- 1834
		elseif self.bottleFly ~= nil then -- 1834
			parts[#parts + 1] = "瓶在飞" -- 1836
		else -- 1836
			parts[#parts + 1] = "空手" -- 1838
		end -- 1838
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 1840
		if self.scavChase then -- 1840
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 1842
		end -- 1842
		if self.passed then -- 1842
			parts[#parts + 1] = "已过通行线" -- 1845
		end -- 1845
		if self.paused then -- 1845
			parts[#parts + 1] = "已暂停" -- 1848
		end -- 1848
		return table.concat(parts, " · ") -- 1850
	end -- 1850
	local isChild = self.childMode -- 1853
	if isChild then -- 1853
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1855
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 1856
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1857
	else -- 1857
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 1859
		if p.rollT > 0 then -- 1859
			parts[#parts + 1] = "翻滚中" -- 1861
		end -- 1861
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1863
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1864
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 1865
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 1866
	end -- 1866
	if self.checkpoint >= 0 then -- 1866
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 1869
	end -- 1869
	if self.paused then -- 1869
		parts[#parts + 1] = "已暂停" -- 1872
	end -- 1872
	return table.concat(parts, " · ") -- 1874
end -- 1758
function Play.prototype.aliveEnemies(self) -- 1878
	local n = 0 -- 1879
	local i = 0 -- 1880
	do -- 1880
		i = 0 -- 1881
		while i < #self.enemies do -- 1881
			if self.enemies[i + 1].alive then -- 1881
				n = n + 1 -- 1883
			end -- 1883
			i = i + 1 -- 1881
		end -- 1881
	end -- 1881
	return n -- 1886
end -- 1878
function Play.prototype.gateLabel(self) -- 1890
	if self.phase == "gate-idle" then -- 1890
		return "待就位" -- 1892
	end -- 1892
	if self.phase == "gate-hold" then -- 1892
		return "守点中" -- 1895
	end -- 1895
	if self.phase == "gate-send" then -- 1895
		return "送别" -- 1898
	end -- 1898
	if self.phase == "gate-count" then -- 1898
		return "数数 " .. tostring(self.countTick) -- 1901
	end -- 1901
	return "她走" -- 1903
end -- 1890
function Play.prototype.dogLabel(self) -- 1907
	if self.dogState == "ear" then -- 1907
		return "转耳" -- 1909
	end -- 1909
	if self.dogState == "chase" then -- 1909
		return "追" -- 1912
	end -- 1912
	if self.dogState == "sniff" then -- 1912
		return "停" -- 1915
	end -- 1915
	if self.dogState == "back" then -- 1915
		return "回线" -- 1918
	end -- 1918
	return "巡逻" -- 1920
end -- 1907
function Play.prototype.doorXOf(self) -- 1923
	local ____temp_15 -- 1924
	if self.room.story == nil then -- 1924
		____temp_15 = nil -- 1924
	else -- 1924
		____temp_15 = self.room.story.tower -- 1924
	end -- 1924
	local t = ____temp_15 -- 1924
	return t == nil and 0 or t.doorX -- 1925
end -- 1923
function Play.prototype.scavLabel(self) -- 1929
	if self.scavState == "chase" then -- 1929
		return "追" -- 1931
	end -- 1931
	if self.scavState == "turn" then -- 1931
		return "转头" -- 1934
	end -- 1934
	if self.scavState == "walk" then -- 1934
		return "赶来" -- 1937
	end -- 1937
	if self.scavState == "stall" then -- 1937
		return "停住" -- 1940
	end -- 1940
	if self.scavState == "back" then -- 1940
		return "回位" -- 1943
	end -- 1943
	return "巡逻" -- 1945
end -- 1929
function Play.prototype.hintText(self) -- 1949
	if self.paused then -- 1949
		return "Esc 继续 · R 重置" -- 1951
	end -- 1951
	if self.flash ~= "" then -- 1951
		return self.flash -- 1954
	end -- 1954
	if self.room.key == "prologue" then -- 1954
		if self.phase == "prologue-wait" then -- 1954
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 1958
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 1959
		end -- 1959
		if self.phase == "prologue-give" then -- 1959
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 1962
		end -- 1962
		return "她跟着你了 · 两人一起走到门口 680" -- 1964
	end -- 1964
	if self.room.key == "street" then -- 1964
		if self:aliveEnemies() > 0 then -- 1964
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 1968
		end -- 1968
		return "清完了 · 两人一起走到右边检查站入口 900" -- 1970
	end -- 1970
	if self.room.key == "gate" then -- 1970
		local ____temp_16 -- 1973
		if self.room.story == nil then -- 1973
			____temp_16 = nil -- 1973
		else -- 1973
			____temp_16 = self.room.story.gate -- 1973
		end -- 1973
		local g = ____temp_16 -- 1973
		if g ~= nil then -- 1973
			if self.phase == "gate-idle" then -- 1973
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 1976
			end -- 1976
			if self.phase == "gate-hold" then -- 1976
				if self.coveredFlash > 0 then -- 1976
					return "掩体挡下了这一枪 · 别露头" -- 1980
				end -- 1980
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 1982
			end -- 1982
			if self.phase == "gate-send" then -- 1982
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 1985
			end -- 1985
			if self.phase == "gate-count" then -- 1985
				if self.countTick >= 1440 then -- 1985
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 1989
				end -- 1989
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 1991
			end -- 1991
			return "她自己走 · 跟着出城门 1120" -- 1993
		end -- 1993
	end -- 1993
	if self.room.key == "forest" then -- 1993
		if self.dogState == "chase" then -- 1993
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 1998
		end -- 1998
		if self.dogState == "ear" then -- 1998
			return "狗转耳朵了 · 停下或蹲下别出声" -- 2001
		end -- 2001
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 2003
	end -- 2003
	if self.room.key == "tower" then -- 2003
		if self.phase == "tower-wait" then -- 2003
			return "走到门前 445 点一次 E 敲两下" -- 2007
		end -- 2007
		if self.phase == "tower-knock" then -- 2007
			return "敲两下 · 等门开" -- 2010
		end -- 2010
		if self.phase == "tower-given" then -- 2010
			return "递交针套和纸条 · 看登记簿最后一行" -- 2013
		end -- 2013
		return "片尾 · 点 E 再玩一次，回到序章" -- 2015
	end -- 2015
	if self.room.key == "village" then -- 2015
		if self.bottleFly ~= nil then -- 2015
			return "等瓶子落地 · 触地才发声" -- 2019
		end -- 2019
		if self.hasBottle then -- 2019
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 2022
		end -- 2022
		if self.passed then -- 2022
			return "已过第一院 · R 重置可再来一遍" -- 2025
		end -- 2025
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 2027
	end -- 2027
	if self.room.key == "outside" then -- 2027
		if self.focusCart then -- 2027
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 2031
		end -- 2031
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 2033
	end -- 2033
	if self.escort.state == "frozen" then -- 2033
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 2033
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 2037
		end -- 2037
		return "小满吓住了 · 走过去，靠近再点 E" -- 2039
	end -- 2039
	if self.escort.state == "calming" then -- 2039
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 2042
	end -- 2042
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 2044
end -- 1949
function Play.prototype.draw(self, draw, w, h) -- 2049
	self.viewW = w -- 2050
	self.viewH = h -- 2051
	self.view = ____exports.computeViewport(w, h) -- 2052
	self:clampCamera(w, h) -- 2053
	draw:clear() -- 2054
	draw:drawRect( -- 2056
		Rect(0, 0, w, h), -- 2056
		BG_VOID -- 2056
	) -- 2056
	local box = self:canvasRect(w, h) -- 2057
	draw:drawRect(box, BG_FAR) -- 2058
	draw:drawRect( -- 2059
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 2059
		BG_MID -- 2059
	) -- 2059
	self:drawFloors(draw, w, h) -- 2061
	self:drawSolids(draw, w, h) -- 2062
	self:drawZones(draw, w, h) -- 2063
	self:drawArch(draw, w, h) -- 2064
	self:drawCart(draw, w, h) -- 2065
	self:drawActors(draw, w, h) -- 2066
	self:drawTrace(draw, w, h) -- 2067
	self:drawAim(draw, w, h) -- 2068
end -- 2049
function Play.prototype.canvasRect(self, w, h) -- 2072
	local v = self.view -- 2073
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 2074
end -- 2072
function Play.prototype.px(self, n) -- 2078
	return n * self.view.zoom -- 2079
end -- 2078
function Play.prototype.sx(self, wx, w) -- 2083
	local v = self.view -- 2084
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 2085
	return v.ox + lx * v.zoom -- 2086
end -- 2083
function Play.prototype.sy(self, wy, h) -- 2090
	local v = self.view -- 2091
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 2092
	return v.oy + ly * v.zoom -- 2093
end -- 2090
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 2096
	local px0 = self:sx(x0, w) -- 2097
	local px1 = self:sx(x1, w) -- 2098
	local py0 = self:sy(y0, h) -- 2099
	local py1 = self:sy(y1, h) -- 2100
	if px1 <= px0 or py1 <= py0 then -- 2100
		return -- 2102
	end -- 2102
	draw:drawRect( -- 2104
		Rect(px0, py0, px1 - px0, py1 - py0), -- 2104
		color -- 2104
	) -- 2104
end -- 2096
function Play.prototype.drawFloors(self, draw, w, h) -- 2107
	local i = 0 -- 2108
	do -- 2108
		i = 0 -- 2109
		while i < #self.room.floors do -- 2109
			local f = self.room.floors[i + 1] -- 2110
			local y = self:sy(f.y, h) -- 2111
			local x0 = self:sx(f.x0, w) -- 2112
			local x1 = self:sx(f.x1, w) -- 2113
			local deck = self:px(5) -- 2114
			draw:drawRect( -- 2115
				Rect(x0, y - deck, x1 - x0, deck), -- 2115
				FLOOR_DECK -- 2115
			) -- 2115
			draw:drawSegment( -- 2116
				Vec2(x0, y), -- 2116
				Vec2(x1, y), -- 2116
				self:px(1), -- 2116
				GROUND -- 2116
			) -- 2116
			i = i + 1 -- 2109
		end -- 2109
	end -- 2109
end -- 2107
function Play.prototype.drawSolids(self, draw, w, h) -- 2120
	local i = 0 -- 2121
	do -- 2121
		i = 0 -- 2122
		while i < #self.boxes do -- 2122
			do -- 2122
				local b = self.boxes[i + 1] -- 2123
				if b.y0 < -4 and b.y1 <= 96 then -- 2123
					draw:drawSegment( -- 2126
						Vec2( -- 2126
							self:sx(b.x0, w), -- 2126
							self:sy(b.y1, h) -- 2126
						), -- 2126
						Vec2( -- 2126
							self:sx(b.x1, w), -- 2126
							self:sy(b.y1, h) -- 2126
						), -- 2126
						self:px(1), -- 2126
						GROUND -- 2126
					) -- 2126
					goto __continue430 -- 2127
				end -- 2127
				self:drawBox( -- 2129
					draw, -- 2129
					w, -- 2129
					h, -- 2129
					b.x0, -- 2129
					b.x1, -- 2129
					b.y0, -- 2129
					b.y1, -- 2129
					SOLID_FILL -- 2129
				) -- 2129
				draw:drawSegment( -- 2130
					Vec2( -- 2130
						self:sx(b.x0, w), -- 2130
						self:sy(b.y1, h) -- 2130
					), -- 2130
					Vec2( -- 2130
						self:sx(b.x1, w), -- 2130
						self:sy(b.y1, h) -- 2130
					), -- 2130
					self:px(1), -- 2130
					SOLID_EDGE -- 2130
				) -- 2130
			end -- 2130
			::__continue430:: -- 2130
			i = i + 1 -- 2122
		end -- 2122
	end -- 2122
end -- 2120
function Play.prototype.drawZones(self, draw, w, h) -- 2134
	local i = 0 -- 2135
	do -- 2135
		i = 0 -- 2136
		while i < #self.room.zones do -- 2136
			local z = self.room.zones[i + 1] -- 2137
			local fill = DANGER -- 2138
			local line = DANGER_LINE -- 2139
			if z.tint == 2 then -- 2139
				fill = SOFT -- 2141
				line = SOFT_LINE -- 2142
			elseif z.tint == 3 then -- 2142
				fill = BRICK -- 2144
				line = BRICK_LINE -- 2145
			elseif z.tint == 4 then -- 2145
				fill = PASS -- 2147
				line = PASS_LINE -- 2148
			end -- 2148
			self:drawBox( -- 2150
				draw, -- 2150
				w, -- 2150
				h, -- 2150
				z.x0, -- 2150
				z.x1, -- 2150
				z.y, -- 2150
				z.y + z.h, -- 2150
				fill -- 2150
			) -- 2150
			draw:drawSegment( -- 2151
				Vec2( -- 2151
					self:sx(z.x0, w), -- 2151
					self:sy(z.y, h) -- 2151
				), -- 2151
				Vec2( -- 2151
					self:sx(z.x0, w), -- 2151
					self:sy(z.y + z.h, h) -- 2151
				), -- 2151
				self:px(1), -- 2151
				line -- 2151
			) -- 2151
			draw:drawSegment( -- 2152
				Vec2( -- 2152
					self:sx(z.x1, w), -- 2152
					self:sy(z.y, h) -- 2152
				), -- 2152
				Vec2( -- 2152
					self:sx(z.x1, w), -- 2152
					self:sy(z.y + z.h, h) -- 2152
				), -- 2152
				self:px(1), -- 2152
				line -- 2152
			) -- 2152
			i = i + 1 -- 2136
		end -- 2136
	end -- 2136
end -- 2134
function Play.prototype.drawArch(self, draw, w, h) -- 2156
	local a = self.room.arch -- 2157
	if a.h <= 0 then -- 2157
		return -- 2159
	end -- 2159
	self:drawBox( -- 2161
		draw, -- 2161
		w, -- 2161
		h, -- 2161
		a.x0, -- 2161
		a.x1, -- 2161
		a.y, -- 2161
		a.y + a.h, -- 2161
		HOLE_FILL -- 2161
	) -- 2161
	draw:drawSegment( -- 2162
		Vec2( -- 2162
			self:sx(a.x0, w), -- 2162
			self:sy(a.y + a.h, h) -- 2162
		), -- 2162
		Vec2( -- 2162
			self:sx(a.x1, w), -- 2162
			self:sy(a.y + a.h, h) -- 2162
		), -- 2162
		self:px(1), -- 2162
		SOLID_EDGE -- 2162
	) -- 2162
	draw:drawSegment( -- 2163
		Vec2( -- 2163
			self:sx(a.x0, w), -- 2163
			self:sy(a.y, h) -- 2163
		), -- 2163
		Vec2( -- 2163
			self:sx(a.x0, w), -- 2163
			self:sy(a.y + a.h, h) -- 2163
		), -- 2163
		self:px(1), -- 2163
		SOLID_EDGE -- 2163
	) -- 2163
	draw:drawSegment( -- 2164
		Vec2( -- 2164
			self:sx(a.x1, w), -- 2164
			self:sy(a.y, h) -- 2164
		), -- 2164
		Vec2( -- 2164
			self:sx(a.x1, w), -- 2164
			self:sy(a.y + a.h, h) -- 2164
		), -- 2164
		self:px(1), -- 2164
		SOLID_EDGE -- 2164
	) -- 2164
end -- 2156
function Play.prototype.drawCart(self, draw, w, h) -- 2167
	local c = self.room.cart -- 2168
	if c.bodyW <= 0 then -- 2168
		return -- 2170
	end -- 2170
	drawCartShape( -- 2172
		draw, -- 2172
		self, -- 2172
		w, -- 2172
		h, -- 2172
		c, -- 2172
		self.cartAxle -- 2172
	) -- 2172
	draw:drawRect( -- 2173
		Rect( -- 2173
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 2173
			self:sy(c.baseY + 40, h), -- 2173
			self:px(2), -- 2173
			self:px(40) -- 2173
		), -- 2173
		STAND -- 2173
	) -- 2173
end -- 2167
function Play.prototype.drawActors(self, draw, w, h) -- 2176
	local p = self.player -- 2177
	local isChild = self.childMode -- 2178
	if p.covered then -- 2178
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 2181
		draw:drawSegment( -- 2182
			Vec2( -- 2182
				self:sx(edge, w), -- 2182
				self:sy(p.y + 8, h) -- 2182
			), -- 2182
			Vec2( -- 2182
				self:sx(edge, w), -- 2182
				self:sy(p.y + p.h * 0.62, h) -- 2182
			), -- 2182
			self:px(2), -- 2182
			STAND -- 2182
		) -- 2182
	end -- 2182
	drawFigure( -- 2184
		draw, -- 2184
		self, -- 2184
		w, -- 2184
		h, -- 2184
		p, -- 2184
		isChild and CHILD_BODY or SOLDIER_BODY, -- 2184
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 2184
	) -- 2184
	local q = self.partner -- 2185
	if q.alive then -- 2185
		local childPartner = q.w == CHILD_W -- 2187
		drawFigure( -- 2188
			draw, -- 2188
			self, -- 2188
			w, -- 2188
			h, -- 2188
			q, -- 2188
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 2188
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 2188
		) -- 2188
	end -- 2188
	local i = 0 -- 2190
	do -- 2190
		i = 0 -- 2191
		while i < #self.enemies do -- 2191
			local e = self.enemies[i + 1] -- 2192
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 2193
			self:drawBox( -- 2194
				draw, -- 2194
				w, -- 2194
				h, -- 2194
				e.x - e.w / 2, -- 2194
				e.x + e.w / 2, -- 2194
				e.y, -- 2194
				e.y + e.h, -- 2194
				col -- 2194
			) -- 2194
			if e.alive and e.warnT > 0 then -- 2194
				local gunX = self:sx(e.x, w) -- 2197
				local gunY = self:sy(e.y + e.h * 0.72, h) -- 2198
				local aimX = self:sx(p.x, w) -- 2199
				local aimY = self:sy(p.y + p.h * 0.55, h) -- 2200
				local seg = 8 -- 2201
				local s = 0 -- 2202
				do -- 2202
					s = 0 -- 2203
					while s < seg do -- 2203
						local t0 = s / seg -- 2204
						local t1 = (s + 1) / seg -- 2205
						draw:drawSegment( -- 2206
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 2207
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 2208
							self:px(1), -- 2209
							DANGER -- 2209
						) -- 2209
						s = s + 2 -- 2203
					end -- 2203
				end -- 2203
			end -- 2203
			i = i + 1 -- 2191
		end -- 2191
	end -- 2191
	local k = 0 -- 2214
	do -- 2214
		k = 0 -- 2215
		while k < #self.room.marks do -- 2215
			do -- 2215
				local m = self.room.marks[k + 1] -- 2216
				if m.kind ~= 0 then -- 2216
					goto __continue451 -- 2218
				end -- 2218
				local on = self.checkpoint == m.x -- 2220
				local x = self:sx(m.x, w) -- 2221
				local y = self:sy(m.y, h) -- 2222
				draw:drawSegment( -- 2223
					Vec2(x, y), -- 2223
					Vec2( -- 2223
						x, -- 2223
						y + self:px(35) -- 2223
					), -- 2223
					self:px(1), -- 2223
					on and CHECK or INK_DIM -- 2223
				) -- 2223
				draw:drawDot( -- 2224
					Vec2( -- 2224
						x, -- 2224
						y + self:px(35) -- 2224
					), -- 2224
					self:px(2), -- 2224
					on and CHECK or INK_DIM -- 2224
				) -- 2224
			end -- 2224
			::__continue451:: -- 2224
			k = k + 1 -- 2215
		end -- 2215
	end -- 2215
	local j = 0 -- 2228
	do -- 2228
		j = 0 -- 2229
		while j < #self.room.marks do -- 2229
			do -- 2229
				local m = self.room.marks[j + 1] -- 2230
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 2230
					goto __continue454 -- 2232
				end -- 2232
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 2232
					goto __continue454 -- 2236
				end -- 2236
				local col = STAND -- 2238
				if m.kind == 4 then -- 2238
					col = PASS_LINE -- 2240
				elseif m.kind == 5 then -- 2240
					col = BRICK_LINE -- 2242
				end -- 2242
				local mx = self:sx(m.x, w) -- 2244
				local my = self:sy(m.y, h) -- 2245
				draw:drawSegment( -- 2246
					Vec2(mx, my), -- 2246
					Vec2( -- 2246
						mx, -- 2246
						my + self:px(24) -- 2246
					), -- 2246
					self:px(1), -- 2246
					col -- 2246
				) -- 2246
			end -- 2246
			::__continue454:: -- 2246
			j = j + 1 -- 2229
		end -- 2229
	end -- 2229
	local t = 0 -- 2249
	do -- 2249
		t = 0 -- 2250
		while t < #self.room.marks do -- 2250
			do -- 2250
				local m = self.room.marks[t + 1] -- 2251
				if m.kind ~= 6 then -- 2251
					goto __continue460 -- 2253
				end -- 2253
				local mx = self:sx(m.x, w) -- 2255
				local my = self:sy(m.y, h) -- 2256
				draw:drawSegment( -- 2257
					Vec2(mx, my), -- 2257
					Vec2( -- 2257
						mx, -- 2257
						my + self:px(30) -- 2257
					), -- 2257
					self:px(1), -- 2257
					INK_DIM -- 2257
				) -- 2257
				self:drawBox( -- 2258
					draw, -- 2258
					w, -- 2258
					h, -- 2258
					m.x - 5, -- 2258
					m.x + 5, -- 2258
					m.y + 30, -- 2258
					m.y + 40, -- 2258
					CHECK -- 2258
				) -- 2258
			end -- 2258
			::__continue460:: -- 2258
			t = t + 1 -- 2250
		end -- 2250
	end -- 2250
	if self.room.key == "village" then -- 2250
		self:drawVillage(draw, w, h) -- 2261
	end -- 2261
	if self.room.key == "forest" then -- 2261
		self:drawDog(draw, w, h) -- 2264
	end -- 2264
end -- 2176
function Play.prototype.drawDog(self, draw, w, h) -- 2269
	local x = self.dogX -- 2270
	self:drawBox( -- 2271
		draw, -- 2271
		w, -- 2271
		h, -- 2271
		x - 14, -- 2271
		x + 14, -- 2271
		0, -- 2271
		20, -- 2271
		SCAV_BODY -- 2271
	) -- 2271
	self:drawBox( -- 2272
		draw, -- 2272
		w, -- 2272
		h, -- 2272
		x - 10, -- 2272
		x - 2, -- 2272
		20, -- 2272
		30, -- 2272
		SCAV_BODY -- 2272
	) -- 2272
	self:drawBox( -- 2273
		draw, -- 2273
		w, -- 2273
		h, -- 2273
		x + 2, -- 2273
		x + 10, -- 2273
		20, -- 2273
		30, -- 2273
		SCAV_HEAD -- 2273
	) -- 2273
	if self.dogState == "ear" or self.dogState == "chase" then -- 2273
		draw:drawSegment( -- 2275
			Vec2( -- 2275
				self:sx(x, w), -- 2275
				self:sy(30, h) -- 2275
			), -- 2275
			Vec2( -- 2276
				self:sx(x, w), -- 2276
				self:sy(40, h) -- 2276
			), -- 2276
			self:px(1), -- 2276
			DANGER -- 2276
		) -- 2276
	end -- 2276
end -- 2269
function Play.prototype.drawVillage(self, draw, w, h) -- 2281
	local bottle = self.room.bottle -- 2282
	if bottle ~= nil then -- 2282
		self:drawBox( -- 2284
			draw, -- 2284
			w, -- 2284
			h, -- 2284
			bottle.x - 14, -- 2284
			bottle.x + 14, -- 2284
			0, -- 2284
			64, -- 2284
			SOLID_FILL -- 2284
		) -- 2284
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 2284
			self:drawBottle( -- 2286
				draw, -- 2286
				w, -- 2286
				h, -- 2286
				bottle.x, -- 2286
				64 -- 2286
			) -- 2286
		end -- 2286
	end -- 2286
	self:drawBox( -- 2290
		draw, -- 2290
		w, -- 2290
		h, -- 2290
		300, -- 2290
		420, -- 2290
		44, -- 2290
		50, -- 2290
		FLOOR_DECK -- 2290
	) -- 2290
	self:drawBox( -- 2291
		draw, -- 2291
		w, -- 2291
		h, -- 2291
		300, -- 2291
		306, -- 2291
		0, -- 2291
		44, -- 2291
		FLOOR_DECK -- 2291
	) -- 2291
	self:drawBox( -- 2292
		draw, -- 2292
		w, -- 2292
		h, -- 2292
		414, -- 2292
		420, -- 2292
		0, -- 2292
		44, -- 2292
		FLOOR_DECK -- 2292
	) -- 2292
	local s = self.room.scavenger -- 2294
	if s ~= nil then -- 2294
		local sx0 = self.scavX -- 2296
		self:drawBox( -- 2297
			draw, -- 2297
			w, -- 2297
			h, -- 2297
			sx0 - 12, -- 2297
			sx0 + 12, -- 2297
			0, -- 2297
			s.h - 14, -- 2297
			SCAV_BODY -- 2297
		) -- 2297
		self:drawBox( -- 2298
			draw, -- 2298
			w, -- 2298
			h, -- 2298
			sx0 - 7, -- 2298
			sx0 + 7, -- 2298
			s.h - 14, -- 2298
			s.h, -- 2298
			SCAV_HEAD -- 2298
		) -- 2298
		if self.scavState == "turn" then -- 2298
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 2300
			draw:drawSegment( -- 2301
				Vec2( -- 2301
					self:sx(sx0, w), -- 2301
					self:sy(s.h - 6, h) -- 2301
				), -- 2301
				Vec2( -- 2301
					self:sx(fx, w), -- 2301
					self:sy(s.h - 6, h) -- 2301
				), -- 2301
				self:px(1), -- 2301
				INK -- 2301
			) -- 2301
		end -- 2301
	end -- 2301
	if self.hasBottle then -- 2301
		local p = self.player -- 2306
		self:drawBottle( -- 2307
			draw, -- 2307
			w, -- 2307
			h, -- 2307
			p.x + p.facing * 10, -- 2307
			p.y + p.h * 0.62 -- 2307
		) -- 2307
	end -- 2307
	if self.bottleFly ~= nil then -- 2307
		self:drawBottle( -- 2310
			draw, -- 2310
			w, -- 2310
			h, -- 2310
			self.bottleFly.x, -- 2310
			self.bottleFly.y -- 2310
		) -- 2310
	end -- 2310
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 2310
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 2313
		draw:drawCircle( -- 2314
			Vec2( -- 2314
				self:sx(self.bottleLandX, w), -- 2314
				self:sy(0, h) -- 2314
			), -- 2314
			self:px(r / ____exports.UNITS_PER_PX), -- 2314
			BRICK_LINE -- 2314
		) -- 2314
	end -- 2314
end -- 2281
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 2318
	self:drawBox( -- 2319
		draw, -- 2319
		w, -- 2319
		h, -- 2319
		x - 3, -- 2319
		x + 3, -- 2319
		y - 10, -- 2319
		y, -- 2319
		BOTTLE -- 2319
	) -- 2319
end -- 2318
function Play.prototype.drawTrace(self, draw, w, h) -- 2322
	local t = self.trace -- 2323
	if t == nil or self.traceT <= 0 then -- 2323
		return -- 2325
	end -- 2325
	draw:drawSegment( -- 2327
		Vec2( -- 2328
			self:sx(t.x0, w), -- 2328
			self:sy(t.y0, h) -- 2328
		), -- 2328
		Vec2( -- 2329
			self:sx(t.x1, w), -- 2329
			self:sy(t.y1, h) -- 2329
		), -- 2329
		self:px(1), -- 2330
		t.hit and AIM_HIT or INK_DIM -- 2330
	) -- 2330
end -- 2322
function Play.prototype.drawAim(self, draw, w, h) -- 2333
	local v = self.view -- 2335
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 2336
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 2337
	local dot = self:px(1) -- 2338
	local arm = self:px(3) -- 2339
	local gap = self:px(1) -- 2340
	draw:drawSegment( -- 2341
		Vec2(gx - arm - gap, gy), -- 2341
		Vec2(gx - gap, gy), -- 2341
		dot / 2, -- 2341
		AIM -- 2341
	) -- 2341
	draw:drawSegment( -- 2342
		Vec2(gx + gap, gy), -- 2342
		Vec2(gx + arm + gap, gy), -- 2342
		dot / 2, -- 2342
		AIM -- 2342
	) -- 2342
	draw:drawSegment( -- 2343
		Vec2(gx, gy - arm - gap), -- 2343
		Vec2(gx, gy - gap), -- 2343
		dot / 2, -- 2343
		AIM -- 2343
	) -- 2343
	draw:drawSegment( -- 2344
		Vec2(gx, gy + gap), -- 2344
		Vec2(gx, gy + arm + gap), -- 2344
		dot / 2, -- 2344
		AIM -- 2344
	) -- 2344
	if self.room.key == "village" and self.hasBottle then -- 2344
		local p = self.player -- 2348
		local ____end = self:bottleEnd() -- 2349
		local x0 = p.x + p.facing * 10 -- 2350
		local y0 = p.y + p.h * 0.7 -- 2351
		local T = 0.62 -- 2352
		local vx = (____end.x - x0) / T -- 2353
		local vy = (____end.y - y0 + 0.5 * GRAVITY * T * T) / T -- 2354
		local pxr = x0 -- 2355
		local pyr = y0 -- 2356
		local t = 1 -- 2357
		do -- 2357
			t = 1 -- 2358
			while t <= 12 do -- 2358
				local tt = t / 12 * T -- 2359
				local nx = x0 + vx * tt -- 2360
				local ny = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 2361
				draw:drawSegment( -- 2362
					Vec2( -- 2362
						self:sx(pxr, w), -- 2362
						self:sy(pyr, h) -- 2362
					), -- 2362
					Vec2( -- 2362
						self:sx(nx, w), -- 2362
						self:sy(ny, h) -- 2362
					), -- 2362
					self:px(1) / 2, -- 2362
					BOTTLE -- 2362
				) -- 2362
				pxr = nx -- 2363
				pyr = ny -- 2364
				t = t + 1 -- 2358
			end -- 2358
		end -- 2358
		draw:drawCircle( -- 2366
			Vec2( -- 2366
				self:sx(____end.x, w), -- 2366
				self:sy(____end.y + 2, h) -- 2366
			), -- 2366
			self:px(2), -- 2366
			BOTTLE -- 2366
		) -- 2366
	end -- 2366
end -- 2333
return ____exports -- 2333