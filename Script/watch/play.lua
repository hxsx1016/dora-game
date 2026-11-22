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
function makeActor(room, index) -- 2319
	local sp = room.spawns -- 2320
	if index < 0 or index >= #sp then -- 2320
		return { -- 2322
			x = 0, -- 2322
			y = 0, -- 2322
			vx = 0, -- 2322
			vy = 0, -- 2322
			w = CHILD_W, -- 2322
			h = CHILD_H, -- 2322
			onGround = true, -- 2322
			facing = 1, -- 2322
			crouch = false, -- 2322
			rollT = 0, -- 2322
			covered = false, -- 2322
			alive = false -- 2322
		} -- 2322
	end -- 2322
	local s = sp[index + 1] -- 2324
	local child = s.h <= CHILD_H -- 2325
	return { -- 2326
		x = s.x, -- 2327
		y = s.y, -- 2327
		vx = 0, -- 2327
		vy = 0, -- 2327
		w = child and CHILD_W or SOLDIER_W, -- 2328
		h = child and CHILD_H or SOLDIER_H, -- 2329
		onGround = true, -- 2330
		facing = 1, -- 2330
		crouch = false, -- 2330
		rollT = 0, -- 2330
		covered = false, -- 2330
		alive = true -- 2330
	} -- 2330
end -- 2330
function drawFigure(draw, play, w, h, a, body, head) -- 2334
	if not a.alive then -- 2334
		return -- 2336
	end -- 2336
	local x0 = a.x - a.w / 2 -- 2338
	local x1 = a.x + a.w / 2 -- 2339
	local y0 = a.y -- 2340
	local y1 = a.y + a.h -- 2341
	play:drawBox( -- 2342
		draw, -- 2342
		w, -- 2342
		h, -- 2342
		x0, -- 2342
		x1, -- 2342
		y0, -- 2342
		y1 - a.h * 0.26, -- 2342
		body -- 2342
	) -- 2342
	play:drawBox( -- 2343
		draw, -- 2343
		w, -- 2343
		h, -- 2343
		x0 + 2, -- 2343
		x1 - 2, -- 2343
		y1 - a.h * 0.26, -- 2343
		y1, -- 2343
		head -- 2343
	) -- 2343
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 2345
	play:drawBox( -- 2346
		draw, -- 2346
		w, -- 2346
		h, -- 2346
		eyeX, -- 2346
		eyeX + 4, -- 2346
		y1 - a.h * 0.14, -- 2346
		y1 - a.h * 0.08, -- 2346
		INK -- 2346
	) -- 2346
end -- 2346
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 2350
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 2351
end -- 2350
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 2358
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 2359
end -- 2358
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 2366
	local tmin = 0 -- 2367
	local tmax = 99999 -- 2368
	if dx == 0 then -- 2368
		if ox < x0 or ox > x1 then -- 2368
			return -1 -- 2371
		end -- 2371
	else -- 2371
		local t1 = (x0 - ox) / dx -- 2374
		local t2 = (x1 - ox) / dx -- 2375
		local lo = t1 < t2 and t1 or t2 -- 2376
		local hi = t1 < t2 and t2 or t1 -- 2377
		if lo > tmin then -- 2377
			tmin = lo -- 2379
		end -- 2379
		if hi < tmax then -- 2379
			tmax = hi -- 2382
		end -- 2382
	end -- 2382
	if dy == 0 then -- 2382
		if oy < y0 or oy > y1 then -- 2382
			return -1 -- 2387
		end -- 2387
	else -- 2387
		local t1 = (y0 - oy) / dy -- 2390
		local t2 = (y1 - oy) / dy -- 2391
		local lo = t1 < t2 and t1 or t2 -- 2392
		local hi = t1 < t2 and t2 or t1 -- 2393
		if lo > tmin then -- 2393
			tmin = lo -- 2395
		end -- 2395
		if hi < tmax then -- 2395
			tmax = hi -- 2398
		end -- 2398
	end -- 2398
	return tmax >= tmin and tmin or -1 -- 2401
end -- 2401
function drawCartShape(draw, play, w, h, c, axleX) -- 2404
	local half = c.bodyW / 2 -- 2405
	local x0 = axleX - half -- 2406
	local x1 = axleX + half -- 2407
	play:drawBox( -- 2408
		draw, -- 2408
		w, -- 2408
		h, -- 2408
		x0, -- 2408
		x1, -- 2408
		c.baseY + c.wheelR, -- 2408
		c.baseY + c.wheelR + c.bodyH, -- 2408
		CART_FILL -- 2408
	) -- 2408
	draw:drawCircle( -- 2409
		Vec2( -- 2409
			play:sx(x0 + c.bodyW * 0.28, w), -- 2409
			play:sy(c.baseY + c.wheelR, h) -- 2409
		), -- 2409
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2409
		Color(52, 50, 48, 255) -- 2409
	) -- 2409
	draw:drawCircle( -- 2410
		Vec2( -- 2410
			play:sx(x1 - c.bodyW * 0.28, w), -- 2410
			play:sy(c.baseY + c.wheelR, h) -- 2410
		), -- 2410
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2410
		Color(52, 50, 48, 255) -- 2410
	) -- 2410
	local cx = c.clothSide < 0 and x0 or x1 -- 2411
	play:drawBox( -- 2412
		draw, -- 2412
		w, -- 2412
		h, -- 2412
		cx - 10, -- 2412
		cx + 10, -- 2412
		c.baseY + c.wheelR + c.bodyH, -- 2412
		c.baseY + c.wheelR + c.bodyH + 18, -- 2412
		CLOTH -- 2412
	) -- 2412
end -- 2412
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
function Play.prototype.____constructor(self, room, resume) -- 302
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
	self.bottleLandT = 0 -- 242
	self.aimHold = 0 -- 244
	self.scavX = 0 -- 246
	self.scavDir = 1 -- 247
	self.scavState = "patrol" -- 248
	self.scavT = 0 -- 249
	self.scavTargetX = 0 -- 250
	self.passed = false -- 252
	self.childMode = false -- 256
	self.phase = "" -- 258
	self.phaseTick = 0 -- 260
	self.gateTick = 0 -- 262
	self.countTick = 0 -- 264
	self.countArmed = false -- 266
	self.caughtT = 0 -- 268
	self.hp = 3 -- 270
	self.maxHp = 3 -- 271
	self.coveredFlash = 0 -- 273
	self.dogX = 0 -- 275
	self.dogDir = 1 -- 276
	self.dogState = "patrol" -- 277
	self.dogT = 0 -- 278
	self.dogTargetX = 0 -- 279
	self.scavSee = 0 -- 281
	self.scavChase = false -- 282
	self.gateSpawned = 0 -- 284
	self.gateFailCount = 0 -- 286
	self.paused = false -- 288
	self.ticks = 0 -- 290
	self.view = {zoom = 1, ox = 0, oy = 0} -- 292
	self.ox = 0 -- 294
	self.aimX = 0 -- 296
	self.aimY = 0 -- 297
	self.viewW = 0 -- 299
	self.viewH = 0 -- 300
	self.ox = room.originX -- 304
	self.room = withOrigin(room) -- 305
	local wr = self.room -- 306
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 307
	self:buildWorld() -- 308
	self.childMode = wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower" -- 310
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 311
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 312
	self.player = makeActor(wr, playerIdx) -- 313
	self.partner = makeActor(wr, partnerIdx) -- 314
	self.phase = phaseOf(wr.key) -- 315
	if wr.story ~= nil then -- 315
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 317
	end -- 317
	self.cam.x = self.player.x -- 319
	self.cam.y = self.player.y + CAM_LOOK_UP -- 320
	self.cartAxle = wr.cart.startX -- 321
	self.escort = __TS__New( -- 322
		Escort, -- 322
		safeAnchorX(wr.marks) -- 322
	) -- 322
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 323
	self:buildEnemies() -- 324
	if resume ~= nil and resume.checkpoint > 0 then -- 324
		self.checkpoint = resume.checkpoint -- 327
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 327
			self.cartAxle = self.room.cart.endX -- 329
			self.cartDocked = true -- 330
			self.player.x = self.ox + 380 -- 333
			self.player.y = 0 -- 334
			self.player.vy = 0 -- 335
			self.player.onGround = true -- 336
			self.cam.x = self.player.x -- 337
			self.cam.y = self.player.y + CAM_LOOK_UP -- 338
		end -- 338
	end -- 338
end -- 302
function Play.prototype.buildWorld(self) -- 344
	local room = self.room -- 345
	self.boxes = {} -- 346
	self.floors = {} -- 347
	local i = 0 -- 348
	do -- 348
		i = 0 -- 349
		while i < #room.floors do -- 349
			local f = room.floors[i + 1] -- 350
			local ____self_floors_0 = self.floors -- 350
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 351
			i = i + 1 -- 349
		end -- 349
	end -- 349
	do -- 349
		i = 0 -- 353
		while i < #room.solids do -- 353
			local s = room.solids[i + 1] -- 354
			local ____self_boxes_1 = self.boxes -- 354
			____self_boxes_1[#____self_boxes_1 + 1] = { -- 355
				x0 = s.x, -- 355
				x1 = s.x + s.w, -- 355
				y0 = s.y, -- 355
				y1 = s.y + s.h, -- 355
				passable = s.passable == true -- 355
			} -- 355
			i = i + 1 -- 353
		end -- 353
	end -- 353
	do -- 353
		i = 0 -- 357
		while i < #room.stairs do -- 357
			local st = room.stairs[i + 1] -- 358
			local n = st.steps + 1 -- 359
			local stepW = (st.x1 - st.x0) / n -- 360
			local k = 0 -- 361
			do -- 361
				k = 0 -- 362
				while k < n do -- 362
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 363
					local x0 = st.x0 + stepW * k -- 364
					local ____self_boxes_2 = self.boxes -- 364
					____self_boxes_2[#____self_boxes_2 + 1] = { -- 366
						x0 = x0, -- 366
						x1 = x0 + stepW, -- 366
						y0 = -8, -- 366
						y1 = y, -- 366
						passable = true -- 366
					} -- 366
					k = k + 1 -- 362
				end -- 362
			end -- 362
			i = i + 1 -- 357
		end -- 357
	end -- 357
end -- 344
function Play.prototype.buildEnemies(self) -- 371
	self.enemies = {} -- 372
	if self.room.key == "checkpoint" then -- 372
		local ____self_enemies_3 = self.enemies -- 372
		____self_enemies_3[#____self_enemies_3 + 1] = { -- 374
			x = self.ox + 430, -- 374
			y = 0, -- 374
			w = 26, -- 374
			h = 84, -- 374
			alive = true, -- 374
			hitT = 0, -- 374
			warnT = 0, -- 374
			fireCd = 0 -- 374
		} -- 374
		local ____self_enemies_4 = self.enemies -- 374
		____self_enemies_4[#____self_enemies_4 + 1] = { -- 375
			x = self.ox + 505, -- 375
			y = 0, -- 375
			w = 26, -- 375
			h = 84, -- 375
			alive = true, -- 375
			hitT = 0, -- 375
			warnT = 0, -- 375
			fireCd = 0 -- 375
		} -- 375
		return -- 376
	end -- 376
	if self.room.key == "street" then -- 376
		local ____self_enemies_5 = self.enemies -- 376
		____self_enemies_5[#____self_enemies_5 + 1] = { -- 380
			x = self.ox + 340, -- 380
			y = 0, -- 380
			w = 26, -- 380
			h = 84, -- 380
			alive = true, -- 380
			hitT = 0, -- 380
			warnT = 0, -- 380
			fireCd = 0 -- 380
		} -- 380
		local ____self_enemies_6 = self.enemies -- 380
		____self_enemies_6[#____self_enemies_6 + 1] = { -- 381
			x = self.ox + 560, -- 381
			y = 0, -- 381
			w = 26, -- 381
			h = 84, -- 381
			alive = true, -- 381
			hitT = 0, -- 381
			warnT = 0, -- 381
			fireCd = 0 -- 381
		} -- 381
	end -- 381
end -- 371
function Play.prototype.update(self, dt, input) -- 387
	if input.pause.pressed then -- 387
		self.paused = not self.paused -- 389
	end -- 389
	if self.flashT > 0 then -- 389
		self.flashT = self.flashT - dt -- 392
		if self.flashT <= 0 then -- 392
			self.flash = "" -- 394
		end -- 394
	end -- 394
	if self.traceT > 0 then -- 394
		self.traceT = self.traceT - dt -- 398
		if self.traceT <= 0 then -- 398
			self.trace = nil -- 400
		end -- 400
	end -- 400
	if self.paused then -- 400
		self:updateCamera(dt) -- 404
		return -- 405
	end -- 405
	self.ticks = self.ticks + 1 -- 408
	local p = self.player -- 409
	self:stepPlayer(p, dt, input) -- 410
	self:stepStory(dt, input) -- 411
	self:stepEscort(dt, input) -- 412
	self:stepEnemies(dt, input) -- 413
	self:stepVillage(dt, input) -- 414
	self:stepChase(dt, input) -- 415
	self:stepInteract(dt, input) -- 416
	self:updateGate() -- 417
	self:updateCamera(dt) -- 418
end -- 387
function Play.prototype.nearLowLedge(self, a) -- 422
	local reach = 26 -- 423
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 424
	local x1 = x0 + reach -- 425
	local i = 0 -- 426
	do -- 426
		i = 0 -- 427
		while i < #self.boxes do -- 427
			do -- 427
				local b = self.boxes[i + 1] -- 428
				if b.x1 <= x0 or b.x0 >= x1 then -- 428
					goto __continue35 -- 430
				end -- 430
				local rise = b.y1 - a.y -- 432
				if rise > 0 and rise <= LEDGE_RISE then -- 432
					return true -- 434
				end -- 434
			end -- 434
			::__continue35:: -- 434
			i = i + 1 -- 427
		end -- 427
	end -- 427
	return false -- 437
end -- 422
function Play.prototype.stepPlayer(self, a, dt, input) -- 440
	if not a.alive then -- 440
		return -- 442
	end -- 442
	local isChild = self.childMode -- 444
	if self:storyLocked() then -- 444
		a.vx = 0 -- 447
		a.crouch = false -- 448
		a.h = isChild and CHILD_H or SOLDIER_H -- 449
		self:fallY(a, dt) -- 450
		return -- 451
	end -- 451
	if not isChild and self.escort.state == "calming" then -- 451
		a.crouch = false -- 455
		a.h = SOLDIER_H -- 456
		a.vx = 0 -- 457
		self:fallY(a, dt) -- 458
		return -- 459
	end -- 459
	a.crouch = isChild and input.crouch.held and a.onGround -- 461
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 462
	a.covered = not isChild and input.cover.held -- 463
	if a.rollT > 0 then -- 463
		a.rollT = a.rollT - dt -- 467
		a.vx = a.facing * ROLL_SPEED -- 468
		self:slideX(a, a.vx * dt) -- 469
		self:fallY(a, dt) -- 470
		if a.rollT <= 0 then -- 470
			self:flashSet("翻滚结束", 0.5) -- 472
		end -- 472
		return -- 474
	end -- 474
	if not isChild and input.jump.pressed and a.onGround then -- 474
		if input.moveX ~= 0 then -- 474
			a.facing = input.moveX > 0 and 1 or -1 -- 479
		end -- 479
		if self:nearLowLedge(a) then -- 479
			a.vy = SOLDIER_JUMP -- 483
			a.onGround = false -- 484
			self:flashSet("翻上去", 0.3) -- 485
			return -- 486
		end -- 486
		a.rollT = ROLL_TIME -- 488
		self:flashSet("翻滚", 0.3) -- 489
		return -- 490
	end -- 490
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 493
	if isChild then -- 493
		if input.cover.held then -- 493
			speed = CHILD_SLOW -- 496
		end -- 496
		if a.crouch then -- 496
			speed = CHILD_SLOW -- 499
		end -- 499
	elseif a.covered then -- 499
		speed = SOLDIER_SPEED * 0.45 -- 502
	end -- 502
	local dir = self.gripping and 0 or input.moveX -- 506
	if dir ~= 0 then -- 506
		a.facing = dir > 0 and 1 or -1 -- 508
	end -- 508
	a.vx = dir * speed -- 510
	if isChild and input.jump.pressed and a.onGround and not a.crouch then -- 510
		a.vy = CHILD_JUMP -- 514
		a.onGround = false -- 515
		self:flashSet("跳", 0.25) -- 516
	end -- 516
	self:slideX(a, a.vx * dt) -- 519
	self:fallY(a, dt) -- 520
	if not isChild and input.fire.pressed then -- 520
		self:shoot(a) -- 524
	end -- 524
end -- 440
function Play.prototype.stepPartner(self, p, dt) -- 529
	local a = self.partner -- 530
	if not a.alive then -- 530
		return -- 532
	end -- 532
	a.crouch = false -- 534
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 535
	a.vx = 0 -- 536
	self:fallY(a, dt) -- 537
end -- 529
function Play.prototype.stepEscort(self, dt, input) -- 544
	local a = self.partner -- 545
	if not a.alive then -- 545
		return -- 547
	end -- 547
	if not self:escortOn() then -- 547
		a.vx = 0 -- 550
		self:fallY(a, dt) -- 551
		return -- 552
	end -- 552
	local p = self.player -- 554
	local dist = math.abs(p.x - a.x) -- 555
	self.calmConsumed = self.escort:update( -- 556
		input, -- 556
		p.x, -- 556
		p.facing, -- 556
		a.x, -- 556
		dist -- 556
	) -- 556
	a.crouch = self.escort.crouchPose -- 557
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 558
	local dir = self.escort:moveDir(a.x) -- 559
	a.vx = dir * CHILD_SPEED -- 560
	if dir ~= 0 then -- 560
		a.facing = dir -- 562
		local before = a.x -- 563
		self:slideX(a, dir * CHILD_SPEED * dt) -- 564
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 564
			a.vy = CHILD_JUMP -- 567
			a.onGround = false -- 568
		end -- 568
	end -- 568
	self:fallY(a, dt) -- 571
end -- 544
function Play.prototype.escortOn(self) -- 575
	if self.room.key == "checkpoint" then -- 575
		return true -- 577
	end -- 577
	if self.room.key == "prologue" then -- 577
		return self.phase == "prologue-follow" -- 580
	end -- 580
	return self.room.key == "street" -- 582
end -- 575
function Play.prototype.storyLocked(self) -- 586
	if self.caughtT > 0 then -- 586
		return true -- 588
	end -- 588
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 588
		return true -- 591
	end -- 591
	if self.room.key == "gate" and self.phase == "gate-count" then -- 591
		return true -- 594
	end -- 594
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 594
		return true -- 597
	end -- 597
	return false -- 599
end -- 586
function Play.prototype.swapToChild(self, x) -- 603
	local tmp = self.player -- 604
	self.player = self.partner -- 605
	self.partner = tmp -- 606
	self.childMode = true -- 607
	self.player.alive = true -- 608
	self.player.x = self.ox + x -- 609
	self.player.y = 0 -- 610
	self.player.vy = 0 -- 611
	self.player.vx = 0 -- 612
	self.player.onGround = true -- 613
	self.player.crouch = false -- 614
	self.player.h = CHILD_H -- 615
	self.player.facing = 1 -- 616
	self.partner.alive = true -- 617
	self.cam.x = self.player.x -- 618
end -- 603
function Play.prototype.stepStory(self, dt, input) -- 622
	if self.room.key == "prologue" then -- 622
		self:stepPrologue(dt, input) -- 624
	elseif self.room.key == "street" then -- 624
		self:stepStreet(dt, input) -- 626
	elseif self.room.key == "gate" then -- 626
		self:stepGate(dt, input) -- 628
	elseif self.room.key == "tower" then -- 628
		self:stepTower(dt, input) -- 630
	end -- 630
end -- 622
function Play.prototype.stepPrologue(self, dt, input) -- 635
	local child = self.partner -- 636
	if self.phase == "prologue-wait" then -- 636
		child.crouch = true -- 638
		child.h = CHILD_CROUCH_H -- 639
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 640
		local near = math.abs(self.player.x - child.x) <= reach -- 642
		if near and input.interact.pressed then -- 642
			self.phase = "prologue-give" -- 644
			self.phaseTick = 0 -- 645
			self:flashSet("递出针套", 1) -- 646
		end -- 646
		return -- 648
	end -- 648
	if self.phase == "prologue-give" then -- 648
		self.phaseTick = self.phaseTick + 1 -- 651
		if self.phaseTick == 12 then -- 651
			self:flashSet("针套递过去", 0.7) -- 653
		elseif self.phaseTick == 36 then -- 653
			self:flashSet("纸条塞进针套", 0.9) -- 655
		elseif self.phaseTick >= 60 then -- 655
			self.phase = "prologue-follow" -- 657
			self.phaseTick = 0 -- 658
			child.crouch = false -- 659
			child.h = CHILD_H -- 660
			self:flashSet("她跟上了", 1.2) -- 661
		end -- 661
		return -- 663
	end -- 663
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 663
		self.wantRoom = "street" -- 667
		self:flashSet("进街道", 1.2) -- 668
	end -- 668
end -- 635
function Play.prototype.stepStreet(self, dt, input) -- 673
	local p = self.player -- 674
	local c = self.partner -- 675
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 675
		self.wantRoom = "checkpoint" -- 677
		self:flashSet("到检查站", 1.2) -- 678
	end -- 678
end -- 673
function Play.prototype.stepGate(self, dt, input) -- 683
	local ____temp_7 -- 684
	if self.room.story == nil then -- 684
		____temp_7 = nil -- 684
	else -- 684
		____temp_7 = self.room.story.gate -- 684
	end -- 684
	local g = ____temp_7 -- 684
	if g == nil then -- 684
		return -- 686
	end -- 686
	local p = self.player -- 688
	if self.phase == "gate-idle" then -- 688
		local a = self.partner -- 691
		local gap = g.waitX - a.x -- 692
		if math.abs(gap) > 3 then -- 692
			a.facing = gap > 0 and 1 or -1 -- 694
			a.vx = a.facing * CHILD_SPEED -- 695
			local beforeX = a.x -- 696
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 697
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 697
				a.vy = CHILD_JUMP -- 699
				a.onGround = false -- 700
			end -- 700
			self:fallY(a, dt) -- 702
		else -- 702
			a.vx = 0 -- 704
			a.x = g.waitX -- 705
		end -- 705
		local atWinch = math.abs(p.x - g.winchX) <= 60 and p.y < 20 -- 707
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 708
		if atWinch and atWait then -- 708
			self.phase = "gate-hold" -- 710
			self.gateTick = 0 -- 711
			self.gateSpawned = 0 -- 712
			self:flashSet("两人就位 · 守点开始", 1.4) -- 713
		end -- 713
		return -- 715
	end -- 715
	if self.phase == "gate-hold" then -- 715
		self.gateTick = self.gateTick + 1 -- 718
		local marks = {0, 540, 900, 1500} -- 720
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 720
			local idx = self.gateSpawned -- 722
			local ____self_enemies_8 = self.enemies -- 722
			____self_enemies_8[#____self_enemies_8 + 1] = { -- 723
				x = self.ox + 620 + idx * 62, -- 724
				y = 0, -- 724
				w = 26, -- 724
				h = 84, -- 724
				alive = true, -- 725
				hitT = 0, -- 725
				warnT = 0, -- 725
				fireCd = 90 + idx * 45 -- 725
			} -- 725
			self.gateSpawned = self.gateSpawned + 1 -- 727
			self:flashSet( -- 728
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 728
				0.9 -- 728
			) -- 728
		end -- 728
		if self.gateTick == 900 then -- 728
			self:flashSet("灯灭了", 1) -- 731
		elseif self.gateTick == 2100 then -- 731
			self:flashSet("门底压下来了", 1) -- 733
		end -- 733
		if self.gateTick >= g.holdTicks then -- 733
			self.phase = "gate-send" -- 736
			self.phaseTick = 0 -- 737
			self.enemies = {} -- 739
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 740
		end -- 740
		return -- 742
	end -- 742
	if self.phase == "gate-send" then -- 742
		local near = math.abs(p.x - g.doorX) <= 60 -- 745
		if near and input.interact.pressed then -- 745
			self:swapToChild(g.doorX + 30) -- 747
			self.phase = "gate-count" -- 748
			self.countTick = 0 -- 749
			self.countArmed = input.moveX == 0 -- 751
			self:flashSet("门开了 · 送她出去", 1.8) -- 752
		end -- 752
		return -- 754
	end -- 754
	if self.phase == "gate-count" then -- 754
		self.countTick = self.countTick + 1 -- 757
		if self.countTick == 360 then -- 757
			self:flashSet("门关上", 0.9) -- 759
		elseif self.countTick == 1020 then -- 759
			self:flashSet("数到一百", 2.2) -- 761
		end -- 761
		if self.countTick >= 1440 then -- 761
			if input.moveX == 0 then -- 761
				self.countArmed = true -- 765
			end -- 765
			if self.countArmed and input.moveX > 0 then -- 765
				self.phase = "gate-walk" -- 768
				self.phaseTick = 0 -- 769
				self:flashSet("她迈出第一步", 1.4) -- 770
			end -- 770
		end -- 770
		return -- 773
	end -- 773
	if self.player.x >= g.exitX then -- 773
		self.wantRoom = "outside" -- 777
		self:flashSet("出城门 · 城外", 1.4) -- 778
	end -- 778
end -- 683
function Play.prototype.stepTower(self, dt, input) -- 783
	local ____temp_9 -- 784
	if self.room.story == nil then -- 784
		____temp_9 = nil -- 784
	else -- 784
		____temp_9 = self.room.story.tower -- 784
	end -- 784
	local t = ____temp_9 -- 784
	if t == nil then -- 784
		return -- 786
	end -- 786
	if self.phase == "tower-wait" then -- 786
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 789
		if near and input.interact.pressed then -- 789
			self.phase = "tower-knock" -- 791
			self.phaseTick = 0 -- 792
			self.knocks = 1 -- 793
			self:flashSet("敲一下", 0.6) -- 794
		end -- 794
		return -- 796
	end -- 796
	if self.phase == "tower-knock" then -- 796
		self.phaseTick = self.phaseTick + 1 -- 799
		if self.phaseTick == 12 then -- 799
			self.knocks = 2 -- 801
			self:flashSet("敲两下 · 第二声", 1) -- 802
		elseif self.phaseTick >= t.knockTicks then -- 802
			self.phase = "tower-given" -- 804
			self.phaseTick = 0 -- 805
			self:flashSet("门开了 · 提灯", 1.4) -- 806
		end -- 806
		return -- 808
	end -- 808
	if self.phase == "tower-given" then -- 808
		self.phaseTick = self.phaseTick + 1 -- 811
		if self.phaseTick == 60 then -- 811
			self:flashSet("她递出针套和纸条", 1.6) -- 813
		elseif self.phaseTick == 120 then -- 813
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 815
		elseif self.phaseTick >= 180 then -- 815
			self.phase = "tower-end" -- 817
			self.phaseTick = 0 -- 818
			self:flashSet("片尾 · E 再玩一次", 3) -- 819
		end -- 819
		return -- 821
	end -- 821
	if input.interact.pressed or input.retry.pressed then -- 821
		self.wantRoom = "prologue" -- 824
		self:flashSet("回到序章", 1.4) -- 825
	end -- 825
end -- 783
function Play.prototype.stepChase(self, dt, input) -- 830
	if self.caughtT > 0 then -- 830
		self.caughtT = self.caughtT - dt -- 832
		if self.caughtT <= 0 then -- 832
			self:recoverFromCaught() -- 834
		end -- 834
		return -- 836
	end -- 836
	if self.room.key == "village" then -- 836
		self:stepScavChase() -- 839
	elseif self.room.key == "forest" then -- 839
		self:stepDog(dt) -- 841
		if self.player.x >= self.ox + 1450 then -- 841
			self.wantRoom = "tower" -- 844
			self:flashSet("林缘 · 北塔", 1.4) -- 845
		end -- 845
	end -- 845
end -- 830
function Play.prototype.stepScavChase(self) -- 851
	local s = self.room.scavenger -- 852
	if s == nil then -- 852
		return -- 854
	end -- 854
	local p = self.player -- 856
	if self.passed and p.x > self.ox + 440 then -- 856
		if self.scavChase then -- 856
			self.scavChase = false -- 860
			self.scavState = "back" -- 861
			self.scavT = 0 -- 862
		end -- 862
		return -- 864
	end -- 864
	local dx = p.x - self.scavX -- 866
	local dist = math.abs(dx) -- 867
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 868
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 869
	if not self.scavChase then -- 869
		if visible then -- 869
			self.scavSee = self.scavSee + 1 -- 872
			if self.scavSee >= 24 then -- 872
				self.scavChase = true -- 874
				self.scavState = "chase" -- 875
				self.scavTargetX = p.x -- 876
				self:flashSet("他看见你了", 1.2) -- 877
			end -- 877
		else -- 877
			self.scavSee = 0 -- 880
		end -- 880
		return -- 882
	end -- 882
	local dir = p.x > self.scavX and 1 or -1 -- 885
	self.scavX = self.scavX + dir * 96 / 60 -- 886
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 886
		self:caught() -- 888
		return -- 889
	end -- 889
	if hidden then -- 889
		self.scavSee = 0 -- 893
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 894
		self.scavT = self.scavT - 1 -- 895
		if self.scavT <= 0 then -- 895
			self.scavChase = false -- 897
			self.scavState = "patrol" -- 898
			self:flashSet("他失去了目标", 1) -- 899
		end -- 899
	end -- 899
end -- 851
function Play.prototype.stepDog(self, dt) -- 905
	local ____temp_10 -- 906
	if self.room.story == nil then -- 906
		____temp_10 = nil -- 906
	else -- 906
		____temp_10 = self.room.story.dog -- 906
	end -- 906
	local dog = ____temp_10 -- 906
	if dog == nil then -- 906
		return -- 908
	end -- 908
	local p = self.player -- 910
	local dist = math.abs(p.x - self.dogX) -- 911
	if self.dogState == "patrol" then -- 911
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 913
		if self.dogX < dog.x0 then -- 913
			self.dogX = dog.x0 -- 915
			self.dogDir = 1 -- 916
		elseif self.dogX > dog.x1 then -- 916
			self.dogX = dog.x1 -- 918
			self.dogDir = -1 -- 919
		end -- 919
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 921
		if not p.crouch and moving and dist < dog.range then -- 921
			self.dogState = "ear" -- 923
			self.dogT = 18 -- 924
			self.dogTargetX = p.x -- 925
			self:flashSet("狗转耳朵", 0.8) -- 926
		end -- 926
		return -- 928
	end -- 928
	if self.dogState == "ear" then -- 928
		self.dogT = self.dogT - 1 -- 931
		if self.dogT <= 0 then -- 931
			self.dogState = "chase" -- 933
			self.dogTargetX = p.x -- 934
			self:flashSet("狗追来了", 1.4) -- 935
		end -- 935
		return -- 937
	end -- 937
	if self.dogState == "chase" then -- 937
		local dir = p.x > self.dogX and 1 or -1 -- 940
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 941
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 941
			self:caught() -- 943
			self.dogState = "sniff" -- 944
			self.dogT = 60 -- 945
		elseif dist > dog.range * 1.5 or p.crouch then -- 945
			self.dogState = "sniff" -- 947
			self.dogT = 60 -- 948
			self:flashSet("狗停下了", 0.9) -- 949
		end -- 949
		return -- 951
	end -- 951
	if self.dogState == "sniff" then -- 951
		self.dogT = self.dogT - 1 -- 954
		if self.dogT <= 0 then -- 954
			self.dogState = "back" -- 956
		end -- 956
		return -- 958
	end -- 958
	local dir = dog.x0 > self.dogX and 1 or -1 -- 961
	self.dogX = self.dogX + dir * dog.speed * dt -- 962
	if math.abs(self.dogX - dog.x0) < 2 then -- 962
		self.dogX = dog.x0 -- 964
		self.dogState = "patrol" -- 965
	end -- 965
end -- 905
function Play.prototype.caught(self) -- 969
	self.caughtT = 1 -- 970
	self:flashSet("被抓 · 回到安全点", 1.6) -- 971
end -- 969
function Play.prototype.recoverFromCaught(self) -- 975
	local p = self.player -- 976
	p.x = self.ox + 140 -- 977
	p.y = 0 -- 978
	p.vy = 0 -- 979
	p.vx = 0 -- 980
	p.onGround = true -- 981
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 981
		self.scavX = self.room.scavenger.x0 -- 983
		self.scavState = "patrol" -- 984
		self.scavSee = 0 -- 985
		self.scavChase = false -- 986
		self.scavT = 0 -- 987
	end -- 987
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 987
		self.dogX = self.room.story.dog.x0 -- 990
		self.dogState = "patrol" -- 991
		self.dogT = 0 -- 992
	end -- 992
	self.cam.x = p.x -- 994
	self.cam.y = p.y + CAM_LOOK_UP -- 995
	self:flashSet("回到安全点", 1.2) -- 996
end -- 975
function Play.prototype.updateGate(self) -- 1000
	if self.room.key ~= "checkpoint" then -- 1000
		self.gateOpen = false -- 1002
		return -- 1003
	end -- 1003
	local function inZone(x) -- 1005
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1005
	end -- 1005
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1006
end -- 1000
function Play.prototype.stepEnemies(self, dt, input) -- 1009
	local i = 0 -- 1010
	do -- 1010
		i = 0 -- 1011
		while i < #self.enemies do -- 1011
			local e = self.enemies[i + 1] -- 1012
			if e.hitT > 0 then -- 1012
				e.hitT = e.hitT - dt -- 1014
			end -- 1014
			i = i + 1 -- 1011
		end -- 1011
	end -- 1011
	if self.coveredFlash > 0 then -- 1011
		self.coveredFlash = self.coveredFlash - dt -- 1018
	end -- 1018
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 1018
		return -- 1022
	end -- 1022
	do -- 1022
		i = 0 -- 1024
		while i < #self.enemies do -- 1024
			do -- 1024
				local e = self.enemies[i + 1] -- 1025
				if not e.alive then -- 1025
					goto __continue163 -- 1027
				end -- 1027
				if e.warnT > 0 then -- 1027
					e.warnT = e.warnT - 1 -- 1030
					if e.warnT <= 0 then -- 1030
						self:enemyFire(e, input) -- 1032
					end -- 1032
					goto __continue163 -- 1034
				end -- 1034
				if e.fireCd > 0 then -- 1034
					e.fireCd = e.fireCd - 1 -- 1037
					if e.fireCd <= 0 then -- 1037
						e.warnT = WARN_TICKS -- 1039
					end -- 1039
				end -- 1039
			end -- 1039
			::__continue163:: -- 1039
			i = i + 1 -- 1024
		end -- 1024
	end -- 1024
end -- 1009
function Play.prototype.enemyFire(self, e, input) -- 1046
	local p = self.player -- 1047
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 1047
		self:flashSet("枪声响在远处", 0.4) -- 1049
		e.fireCd = FIRE_COOLDOWN -- 1050
		return -- 1051
	end -- 1051
	local covered = p.crouch or input.cover.held or self:blockedByCover(e.x, p.x) -- 1053
	if covered then -- 1053
		self.coveredFlash = 0.5 -- 1055
		self:flashSet("掩体挡下", 0.5) -- 1056
		e.fireCd = FIRE_COOLDOWN -- 1057
		return -- 1058
	end -- 1058
	self.hp = self.hp - 1 -- 1060
	self:flashSet( -- 1061
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 1061
		0.7 -- 1061
	) -- 1061
	e.fireCd = FIRE_COOLDOWN -- 1062
	if self.hp <= 0 then -- 1062
		self:gateFailed() -- 1064
	end -- 1064
end -- 1046
function Play.prototype.blockedByCover(self, ex, px) -- 1069
	local lo = math.min(ex, px) -- 1070
	local hi = math.max(ex, px) -- 1071
	local i = 0 -- 1072
	do -- 1072
		i = 0 -- 1073
		while i < #self.boxes do -- 1073
			do -- 1073
				local b = self.boxes[i + 1] -- 1074
				if b.passable == true or b.y1 - b.y0 < 44 then -- 1074
					goto __continue175 -- 1076
				end -- 1076
				local cx = (b.x0 + b.x1) / 2 -- 1078
				if cx <= lo + 8 or cx >= hi - 8 then -- 1078
					goto __continue175 -- 1080
				end -- 1080
				local hug = math.min( -- 1082
					math.abs(px - b.x0), -- 1082
					math.abs(px - b.x1) -- 1082
				) < 24 -- 1082
				if hug then -- 1082
					return true -- 1084
				end -- 1084
			end -- 1084
			::__continue175:: -- 1084
			i = i + 1 -- 1073
		end -- 1073
	end -- 1073
	return false -- 1087
end -- 1069
function Play.prototype.gateFailed(self) -- 1091
	local ____temp_11 -- 1092
	if self.room.story == nil then -- 1092
		____temp_11 = nil -- 1092
	else -- 1092
		____temp_11 = self.room.story.gate -- 1092
	end -- 1092
	local g = ____temp_11 -- 1092
	self:flashSet("被击倒 · 回绞盘重来", 2) -- 1093
	self.hp = self.maxHp -- 1094
	self.gateTick = 0 -- 1095
	self.gateSpawned = 0 -- 1096
	self.enemies = {} -- 1097
	self.gateFailCount = self.gateFailCount + 1 -- 1098
	self.player.x = self.ox + (g == nil and 130 or 130) -- 1099
	self.player.y = 0 -- 1100
	self.player.vy = 0 -- 1101
	self.player.onGround = true -- 1102
	self.player.crouch = false -- 1103
	self.player.h = SOLDIER_H -- 1104
	self.partner.x = self.ox + (g == nil and 900 or 900) -- 1105
	self.partner.y = 0 -- 1106
	self.partner.vy = 0 -- 1107
	self.partner.onGround = true -- 1108
	self.cam.x = self.player.x -- 1109
	self.phase = "gate-hold" -- 1110
	self.phaseTick = 0 -- 1111
end -- 1091
function Play.prototype.stepInteract(self, dt, input) -- 1114
	local p = self.player -- 1115
	local calmUsed = self.calmConsumed -- 1116
	self.calmConsumed = false -- 1117
	self.focusCart = false -- 1118
	if self.room.key == "outside" then -- 1118
		local c = self.room.cart -- 1120
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 1121
		local dy = p.y - c.baseY -- 1122
		self.focusCart = dx * dx + dy * dy < CART_REACH * CART_REACH -- 1123
	end -- 1123
	self:stepCart(dt, input) -- 1125
	if calmUsed then -- 1125
		self:flashSet("安抚 · 敲两下", 0.8) -- 1129
	elseif input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" then -- 1129
		if self.knockT > 0 then -- 1129
			self.knocks = self.knocks + 1 -- 1133
		else -- 1133
			self.knocks = 1 -- 1135
		end -- 1135
		self.knockT = 1.2 -- 1137
		if self.knocks >= 2 then -- 1137
			self:flashSet("敲两下", 0.8) -- 1139
			self.knocks = 0 -- 1140
		else -- 1140
			self:flashSet("敲一下", 0.5) -- 1142
		end -- 1142
	elseif self.knockT > 0 then -- 1142
		self.knockT = self.knockT - dt -- 1145
		if self.knockT <= 0 then -- 1145
			self.knocks = 0 -- 1147
		end -- 1147
	end -- 1147
	local i = 0 -- 1152
	do -- 1152
		i = 0 -- 1153
		while i < #self.room.marks do -- 1153
			do -- 1153
				local m = self.room.marks[i + 1] -- 1154
				if m.kind ~= 0 then -- 1154
					goto __continue191 -- 1156
				end -- 1156
				local subjects = {self.partner, self.player} -- 1158
				local k = 0 -- 1159
				do -- 1159
					k = 0 -- 1160
					while k < #subjects do -- 1160
						do -- 1160
							local s = subjects[k + 1] -- 1161
							if not s.alive then -- 1161
								goto __continue194 -- 1163
							end -- 1163
							local dx = s.x - m.x -- 1165
							local dy = s.y - m.y -- 1166
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 1166
								self.checkpoint = m.x -- 1168
								self.checkpointCartAxle = self.cartAxle -- 1169
								if self.cartDocked then -- 1169
									self:flashSet("检查点 · 车已落窝", 1) -- 1171
								else -- 1171
									self:flashSet("检查点 · 车还没到位", 1) -- 1173
								end -- 1173
							end -- 1173
						end -- 1173
						::__continue194:: -- 1173
						k = k + 1 -- 1160
					end -- 1160
				end -- 1160
			end -- 1160
			::__continue191:: -- 1160
			i = i + 1 -- 1153
		end -- 1153
	end -- 1153
	self:checkCarryGate() -- 1179
end -- 1114
function Play.prototype.stepVillage(self, dt, input) -- 1183
	if self.room.key ~= "village" then -- 1183
		return -- 1185
	end -- 1185
	local p = self.player -- 1187
	local bottle = self.room.bottle -- 1188
	local scav = self.room.scavenger -- 1189
	if not self.hasBottle and bottle ~= nil then -- 1189
		local dx = p.x - bottle.x -- 1193
		local dy = p.y + p.h * 0.5 - bottle.y -- 1194
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 1194
			self.hasBottle = true -- 1196
			self:flashSet("拾起瓶子", 0.8) -- 1197
		end -- 1197
	end -- 1197
	if self.hasBottle then -- 1197
		if input.aim.held then -- 1197
			self.aimHold = self.aimHold + dt -- 1204
			if self.aimHold > 1.2 then -- 1204
				self.aimHold = 1.2 -- 1206
			end -- 1206
		elseif input.aim.released then -- 1206
			local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1209
			self:throwBottle(aim.x, aim.y) -- 1210
			self.aimHold = 0 -- 1211
		end -- 1211
	else -- 1211
		self.aimHold = 0 -- 1214
	end -- 1214
	local fly = self.bottleFly -- 1218
	if fly ~= nil then -- 1218
		fly.vy = fly.vy - GRAVITY * dt -- 1220
		fly.x = fly.x + fly.vx * dt -- 1221
		fly.y = fly.y + fly.vy * dt -- 1222
		local g = self:groundAt(fly.x, fly.y + 4, 3) -- 1223
		if fly.y <= g then -- 1223
			self.bottleFly = nil -- 1225
			self.bottleLandX = fly.x -- 1226
			self.bottleLandT = 0.9 -- 1227
			self:hearBottle(fly.x) -- 1228
		end -- 1228
	end -- 1228
	if self.bottleLandT > 0 then -- 1228
		self.bottleLandT = self.bottleLandT - dt -- 1232
	end -- 1232
	if scav ~= nil then -- 1232
		self:stepScav(dt, scav) -- 1236
	end -- 1236
	local line = self.room.passLine -- 1239
	if line ~= nil and not self.passed and p.x >= line then -- 1239
		self.passed = true -- 1241
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 1242
	end -- 1242
	if self.passed and p.x >= self.ox + 640 then -- 1242
		self.wantRoom = "forest" -- 1246
		self:flashSet("出院 · 北塔森林", 1.4) -- 1247
	end -- 1247
end -- 1183
function Play.prototype.throwBottle(self, tx, ty) -- 1252
	local p = self.player -- 1253
	local x0 = p.x + p.facing * 10 -- 1254
	local y0 = p.y + p.h * 0.7 -- 1255
	local T = 0.62 -- 1256
	local vx = (tx - x0) / T -- 1257
	local vy = (ty - y0 + 0.5 * GRAVITY * T * T) / T -- 1258
	self.bottleFly = {x = x0, y = y0, vx = vx, vy = vy} -- 1259
	self.hasBottle = false -- 1260
	self:flashSet("投出", 0.4) -- 1261
end -- 1252
function Play.prototype.hearBottle(self, x) -- 1265
	local s = self.room.scavenger -- 1266
	if s == nil then -- 1266
		return -- 1268
	end -- 1268
	if math.abs(x - self.scavX) > s.range then -- 1268
		self:flashSet("落地 · 他没听见", 0.6) -- 1271
		return -- 1272
	end -- 1272
	self.scavState = "turn" -- 1274
	self.scavT = s.hearTicks -- 1275
	self.scavTargetX = x -- 1276
	self:flashSet("砖地一响 · 他转头", 0.9) -- 1277
end -- 1265
function Play.prototype.stepScav(self, dt, s) -- 1281
	if self.scavState == "chase" then -- 1281
		return -- 1284
	end -- 1284
	if self.scavState == "turn" then -- 1284
		self.scavT = self.scavT - 1 -- 1287
		if self.scavT <= 0 then -- 1287
			self.scavState = "walk" -- 1289
		end -- 1289
		return -- 1291
	end -- 1291
	if self.scavState == "walk" then -- 1291
		local d = self.scavTargetX - self.scavX -- 1294
		if math.abs(d) < 4 then -- 1294
			self.scavState = "stall" -- 1296
			self.scavT = s.stallTicks -- 1297
			return -- 1298
		end -- 1298
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 1300
		return -- 1301
	end -- 1301
	if self.scavState == "stall" then -- 1301
		self.scavT = self.scavT - 1 -- 1304
		if self.scavT <= 0 then -- 1304
			self.scavState = "back" -- 1306
		end -- 1306
		return -- 1308
	end -- 1308
	if self.scavState == "back" then -- 1308
		local home = math.max( -- 1311
			s.x0, -- 1311
			math.min(s.x1, self.scavX) -- 1311
		) -- 1311
		if math.abs(home - self.scavX) < 2 then -- 1311
			self.scavState = "patrol" -- 1313
			return -- 1314
		end -- 1314
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 1316
		return -- 1317
	end -- 1317
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 1319
	if self.scavX >= s.x1 then -- 1319
		self.scavX = s.x1 -- 1321
		self.scavDir = -1 -- 1322
	elseif self.scavX <= s.x0 then -- 1322
		self.scavX = s.x0 -- 1324
		self.scavDir = 1 -- 1325
	end -- 1325
end -- 1281
function Play.prototype.stepCart(self, dt, input) -- 1333
	local p = self.player -- 1334
	local c = self.room.cart -- 1335
	local handleX = self.cartAxle + c.handleOffset -- 1336
	if self.gripping then -- 1336
		if not input.interact.held then -- 1336
			self.gripping = false -- 1340
			self:flashSet("松开车把", 0.4) -- 1341
			return -- 1342
		end -- 1342
	else -- 1342
		if not input.interact.pressed then -- 1342
			return -- 1346
		end -- 1346
		if math.abs(p.x - handleX) > CART_REACH or math.abs(p.y - c.baseY) > 40 then -- 1346
			return -- 1349
		end -- 1349
		self.gripping = true -- 1351
		self:flashSet("握住车把", 0.4) -- 1352
		return -- 1353
	end -- 1353
	if self.cartDocked then -- 1353
		return -- 1357
	end -- 1357
	local dir = input.moveX -- 1359
	if dir == 0 then -- 1359
		return -- 1361
	end -- 1361
	local lo = math.min(c.startX, c.endX) -- 1363
	local hi = math.max(c.startX, c.endX) -- 1364
	local next = self.cartAxle + dir * CART_SPEED * dt -- 1365
	if next < lo then -- 1365
		next = lo -- 1367
	end -- 1367
	if next > hi then -- 1367
		next = hi -- 1370
	end -- 1370
	local delta = next - self.cartAxle -- 1372
	if delta == 0 then -- 1372
		return -- 1374
	end -- 1374
	self.cartAxle = next -- 1376
	p.x = p.x + delta -- 1377
	p.facing = dir > 0 and 1 or -1 -- 1378
	self:slideX(p, 0) -- 1379
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > CART_REACH then -- 1379
		self.gripping = false -- 1381
		self:flashSet("跟不上了，脱手", 0.6) -- 1382
		return -- 1383
	end -- 1383
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 1383
		self.cartDocked = true -- 1386
		self.gripping = false -- 1387
		self:flashSet("车轮落窝", 1.2) -- 1388
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 1388
		self:flashSet("车轮回到起点", 0.5) -- 1390
	end -- 1390
end -- 1333
function Play.prototype.checkCarryGate(self) -- 1398
	if self.room.key == "checkpoint" then -- 1398
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 1398
			self.carryCartAxle = self.cartAxle -- 1401
			self.carryCartDocked = self.cartDocked -- 1402
			self.wantRoom = "gate" -- 1403
			self:flashSet("出检查站 · 城门", 1.2) -- 1404
		end -- 1404
		return -- 1406
	end -- 1406
	if self.room.key == "outside" then -- 1406
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 1406
			self.carryCartAxle = self.cartAxle -- 1412
			self.carryCartDocked = self.cartDocked -- 1413
			self.wantRoom = "village" -- 1414
			self:flashSet("墙根走完 · 进村口", 1.2) -- 1415
		end -- 1415
	end -- 1415
end -- 1398
function Play.prototype.aimAt(self, wx, wy) -- 1422
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 1423
	self.aimX = s.x -- 1424
	self.aimY = s.y -- 1425
end -- 1422
function Play.prototype.shoot(self, a) -- 1428
	local ox = a.x + a.facing * 8 -- 1429
	local oy = a.y + a.h * 0.72 -- 1430
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1432
	local dx = aim.x - ox -- 1433
	local dy = aim.y - oy -- 1434
	local len = math.sqrt(dx * dx + dy * dy) -- 1435
	if len < 0.001 then -- 1435
		dx = a.facing -- 1437
		dy = 0 -- 1438
	else -- 1438
		dx = dx / len -- 1440
		dy = dy / len -- 1441
	end -- 1441
	if dx ~= 0 then -- 1441
		a.facing = dx > 0 and 1 or -1 -- 1444
	end -- 1444
	local hitEnemy = self:raycast( -- 1447
		ox, -- 1447
		oy, -- 1447
		dx, -- 1447
		dy, -- 1447
		true -- 1447
	) -- 1447
	local hitWall = self:raycast( -- 1448
		ox, -- 1448
		oy, -- 1448
		dx, -- 1448
		dy, -- 1448
		false -- 1448
	) -- 1448
	local tEnemy = hitEnemy.t -- 1449
	local tWall = hitWall.t -- 1450
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 1451
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 1452
	self.trace = { -- 1454
		x0 = ox, -- 1454
		y0 = oy, -- 1454
		x1 = ox + dx * t, -- 1454
		y1 = oy + dy * t, -- 1454
		hit = hit -- 1454
	} -- 1454
	self.traceT = 0.12 -- 1455
	self:applyFireDanger(ox) -- 1456
	if hit then -- 1456
		local i = hitEnemy.index -- 1458
		local e = self.enemies[i + 1] -- 1459
		e.alive = false -- 1460
		e.hitT = 0.4 -- 1461
		self:flashSet("命中", 0.6) -- 1462
	else -- 1462
		self:flashSet("打空", 0.35) -- 1464
	end -- 1464
end -- 1428
function Play.prototype.applyFireDanger(self, shotX) -- 1469
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 1469
		return -- 1471
	end -- 1471
	local dangerX = shotX -- 1473
	local best = -1 -- 1474
	local bestD = 1000000000 -- 1475
	local i = 0 -- 1476
	do -- 1476
		i = 0 -- 1477
		while i < #self.enemies do -- 1477
			do -- 1477
				local e = self.enemies[i + 1] -- 1478
				if not e.alive then -- 1478
					goto __continue259 -- 1480
				end -- 1480
				local d = math.abs(e.x - self.partner.x) -- 1482
				if d < bestD then -- 1482
					bestD = d -- 1484
					best = i -- 1485
				end -- 1485
			end -- 1485
			::__continue259:: -- 1485
			i = i + 1 -- 1477
		end -- 1477
	end -- 1477
	if best >= 0 then -- 1477
		dangerX = self.enemies[best + 1].x -- 1489
	end -- 1489
	local exposed = self:childExposed(dangerX) -- 1491
	local before = self.escort.fear -- 1492
	local after = self.escort:applyDanger(self.nextDangerId, exposed, self.partner.x) -- 1493
	self.nextDangerId = self.nextDangerId + 1 -- 1494
	if after > before then -- 1494
		self:flashSet( -- 1496
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 1496
			1 -- 1496
		) -- 1496
	elseif not exposed then -- 1496
		self:flashSet("枪声没够到她", 0.5) -- 1498
	end -- 1498
end -- 1469
function Play.prototype.childExposed(self, dangerX) -- 1503
	local c = self.partner -- 1504
	if not c.alive then -- 1504
		return false -- 1506
	end -- 1506
	if c.x > self.ox + 240 and c.x < self.ox + 340 then -- 1506
		return false -- 1509
	end -- 1509
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 1509
		return false -- 1512
	end -- 1512
	local toDanger = dangerX - c.x -- 1514
	local toPlayer = self.player.x - c.x -- 1515
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) then -- 1515
		return false -- 1517
	end -- 1517
	return true -- 1519
end -- 1503
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 1523
	local best = -1 -- 1524
	local bestI = -1 -- 1525
	local i = 0 -- 1526
	if enemies then -- 1526
		do -- 1526
			i = 0 -- 1528
			while i < #self.enemies do -- 1528
				do -- 1528
					local e = self.enemies[i + 1] -- 1529
					if not e.alive then -- 1529
						goto __continue273 -- 1531
					end -- 1531
					local t = hitBox( -- 1533
						ox, -- 1533
						oy, -- 1533
						dx, -- 1533
						dy, -- 1533
						e.x - e.w / 2, -- 1533
						e.x + e.w / 2, -- 1533
						e.y, -- 1533
						e.y + e.h -- 1533
					) -- 1533
					if t >= 0 and (best < 0 or t < best) then -- 1533
						best = t -- 1535
						bestI = i -- 1536
					end -- 1536
				end -- 1536
				::__continue273:: -- 1536
				i = i + 1 -- 1528
			end -- 1528
		end -- 1528
		return {t = best, index = bestI} -- 1539
	end -- 1539
	do -- 1539
		i = 0 -- 1541
		while i < #self.boxes do -- 1541
			local b = self.boxes[i + 1] -- 1542
			local t = hitBox( -- 1543
				ox, -- 1543
				oy, -- 1543
				dx, -- 1543
				dy, -- 1543
				b.x0, -- 1543
				b.x1, -- 1543
				b.y0, -- 1543
				b.y1 -- 1543
			) -- 1543
			if t >= 0 and (best < 0 or t < best) then -- 1543
				best = t -- 1545
			end -- 1545
			i = i + 1 -- 1541
		end -- 1541
	end -- 1541
	if dy < 0 then -- 1541
		local t = (0 - oy) / dy -- 1550
		if t >= 0 and (best < 0 or t < best) then -- 1550
			best = t -- 1552
		end -- 1552
	end -- 1552
	return {t = best, index = -1} -- 1555
end -- 1523
function Play.prototype.slideX(self, a, dx) -- 1559
	local nx = a.x + dx -- 1560
	local half = a.w / 2 -- 1561
	local room = self.room -- 1562
	nx = math.max( -- 1563
		room.minX + half, -- 1563
		math.min(room.maxX - half, nx) -- 1563
	) -- 1563
	local i = 0 -- 1564
	do -- 1564
		i = 0 -- 1565
		while i < #self.boxes do -- 1565
			do -- 1565
				local b = self.boxes[i + 1] -- 1566
				if b.passable == true then -- 1566
					goto __continue283 -- 1568
				end -- 1568
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1568
					goto __continue283 -- 1571
				end -- 1571
				if nx + half > b.x0 and nx - half < b.x1 then -- 1571
					if a.x <= b.x0 then -- 1571
						nx = b.x0 - half -- 1575
					elseif a.x >= b.x1 then -- 1575
						nx = b.x1 + half -- 1577
					else -- 1577
						nx = a.x -- 1579
					end -- 1579
				end -- 1579
			end -- 1579
			::__continue283:: -- 1579
			i = i + 1 -- 1565
		end -- 1565
	end -- 1565
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 1565
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 1587
		local bx0 = self.cartAxle - CART_HALF -- 1588
		local bx1 = self.cartAxle + CART_HALF -- 1589
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 1589
			if a.x <= bx0 then -- 1589
				nx = bx0 - half -- 1592
			elseif a.x >= bx1 then -- 1592
				nx = bx1 + half -- 1594
			else -- 1594
				nx = a.x -- 1596
			end -- 1596
		end -- 1596
	end -- 1596
	local arch = room.arch -- 1604
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 1604
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 1606
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 1606
			if a.x <= arch.x0 then -- 1606
				nx = arch.x0 - half -- 1609
			elseif a.x >= arch.x1 then -- 1609
				nx = arch.x1 + half -- 1611
			end -- 1611
		end -- 1611
	end -- 1611
	a.x = nx -- 1615
end -- 1559
function Play.prototype.fallY(self, a, dt) -- 1619
	a.vy = a.vy - GRAVITY * dt -- 1620
	if a.vy < -900 then -- 1620
		a.vy = -900 -- 1622
	end -- 1622
	local ny = a.y + a.vy * dt -- 1624
	local half = a.w / 2 -- 1625
	if a.vy <= 0 then -- 1625
		local reach = a.onGround and STEP_UP or 0 -- 1628
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half) -- 1629
		if ny <= ground then -- 1629
			ny = ground -- 1631
			a.vy = 0 -- 1632
			a.onGround = true -- 1633
		else -- 1633
			a.onGround = false -- 1635
		end -- 1635
	else -- 1635
		a.onGround = false -- 1638
		local i = 0 -- 1639
		do -- 1639
			i = 0 -- 1640
			while i < #self.boxes do -- 1640
				do -- 1640
					local b = self.boxes[i + 1] -- 1641
					if b.passable == true then -- 1641
						goto __continue306 -- 1643
					end -- 1643
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 1643
						goto __continue306 -- 1646
					end -- 1646
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 1646
						ny = b.y0 - a.h -- 1649
						a.vy = 0 -- 1650
					end -- 1650
				end -- 1650
				::__continue306:: -- 1650
				i = i + 1 -- 1640
			end -- 1640
		end -- 1640
	end -- 1640
	a.y = ny -- 1654
end -- 1619
function Play.prototype.groundAt(self, x, ceiling, half) -- 1658
	local g = -9999 -- 1659
	local i = 0 -- 1660
	do -- 1660
		i = 0 -- 1661
		while i < #self.floors do -- 1661
			local f = self.floors[i + 1] -- 1662
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 1662
				g = f.y1 -- 1664
			end -- 1664
			i = i + 1 -- 1661
		end -- 1661
	end -- 1661
	do -- 1661
		i = 0 -- 1667
		while i < #self.boxes do -- 1667
			local b = self.boxes[i + 1] -- 1668
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 1668
				g = b.y1 -- 1670
			end -- 1670
			i = i + 1 -- 1667
		end -- 1667
	end -- 1667
	return g -- 1673
end -- 1658
function Play.prototype.updateCamera(self, dt) -- 1676
	local p = self.player -- 1677
	local tx = p.x + p.facing * 30 -- 1678
	local ty = p.y + CAM_LOOK_UP -- 1679
	local k = math.min(1, CAM_FOLLOW * dt) -- 1680
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 1681
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 1682
end -- 1676
function Play.prototype.clampCamera(self, w, h) -- 1686
	local room = self.room -- 1687
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 1688
	local spanX = room.maxX - room.minX -- 1689
	if spanX <= halfW * 2 then -- 1689
		self.cam.x = (room.minX + room.maxX) / 2 -- 1691
	else -- 1691
		self.cam.x = math.max( -- 1693
			room.minX + halfW, -- 1693
			math.min(room.maxX - halfW, self.cam.x) -- 1693
		) -- 1693
	end -- 1693
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 1696
	local spanY = room.height -- 1697
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 1698
	if spanY <= halfH * 2 then -- 1698
		self.cam.y = camY -- 1700
	else -- 1700
		self.cam.y = math.max( -- 1702
			camY, -- 1702
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 1702
		) -- 1702
	end -- 1702
end -- 1686
function Play.prototype.flashSet(self, text, t) -- 1706
	self.flash = text -- 1707
	self.flashT = t -- 1708
end -- 1706
function Play.prototype.statusText(self) -- 1712
	local p = self.player -- 1713
	local parts = {} -- 1714
	local who = self.childMode and "小满" or "周戍" -- 1715
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 1716
	if self.room.key == "prologue" then -- 1716
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1719
		if self.phase == "prologue-wait" then -- 1719
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 1721
		elseif self.phase == "prologue-give" then -- 1721
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 1723
		else -- 1723
			parts[#parts + 1] = "跟随" -- 1725
		end -- 1725
		if self.paused then -- 1725
			parts[#parts + 1] = "已暂停" -- 1728
		end -- 1728
		return table.concat(parts, " · ") -- 1730
	end -- 1730
	if self.room.key == "street" then -- 1730
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1733
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1734
		if self.paused then -- 1734
			parts[#parts + 1] = "已暂停" -- 1736
		end -- 1736
		return table.concat(parts, " · ") -- 1738
	end -- 1738
	if self.room.key == "gate" then -- 1738
		local ____temp_12 -- 1741
		if self.room.story == nil then -- 1741
			____temp_12 = nil -- 1741
		else -- 1741
			____temp_12 = self.room.story.gate -- 1741
		end -- 1741
		local g = ____temp_12 -- 1741
		if g ~= nil then -- 1741
			parts[#parts + 1] = self:gateLabel() -- 1743
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 1744
				0, -- 1745
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 1745
			))) .. " 秒" -- 1745
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1746
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1747
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 1748
			if self.gateFailCount > 0 then -- 1748
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 1750
			end -- 1750
		end -- 1750
		if self.paused then -- 1750
			parts[#parts + 1] = "已暂停" -- 1754
		end -- 1754
		return table.concat(parts, " · ") -- 1756
	end -- 1756
	if self.room.key == "forest" then -- 1756
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1759
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 1760
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 1761
		if self.caughtT > 0 then -- 1761
			parts[#parts + 1] = "复位中" -- 1763
		end -- 1763
		if self.paused then -- 1763
			parts[#parts + 1] = "已暂停" -- 1766
		end -- 1766
		return table.concat(parts, " · ") -- 1768
	end -- 1768
	if self.room.key == "tower" then -- 1768
		if self.phase == "tower-wait" then -- 1768
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 1772
		elseif self.phase == "tower-knock" then -- 1772
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 1774
		elseif self.phase == "tower-given" then -- 1774
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 1776
		else -- 1776
			parts[#parts + 1] = "片尾" -- 1778
		end -- 1778
		if self.paused then -- 1778
			parts[#parts + 1] = "已暂停" -- 1781
		end -- 1781
		return table.concat(parts, " · ") -- 1783
	end -- 1783
	if self.room.key == "village" then -- 1783
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1786
		if self.hasBottle then -- 1786
			parts[#parts + 1] = "有瓶" -- 1788
		elseif self.bottleFly ~= nil then -- 1788
			parts[#parts + 1] = "瓶在飞" -- 1790
		else -- 1790
			parts[#parts + 1] = "空手" -- 1792
		end -- 1792
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 1794
		if self.scavChase then -- 1794
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 1796
		end -- 1796
		if self.passed then -- 1796
			parts[#parts + 1] = "已过通行线" -- 1799
		end -- 1799
		if self.paused then -- 1799
			parts[#parts + 1] = "已暂停" -- 1802
		end -- 1802
		return table.concat(parts, " · ") -- 1804
	end -- 1804
	local isChild = self.childMode -- 1807
	if isChild then -- 1807
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1809
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 1810
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1811
	else -- 1811
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 1813
		if p.rollT > 0 then -- 1813
			parts[#parts + 1] = "翻滚中" -- 1815
		end -- 1815
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1817
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1818
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 1819
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 1820
	end -- 1820
	if self.checkpoint >= 0 then -- 1820
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 1823
	end -- 1823
	if self.paused then -- 1823
		parts[#parts + 1] = "已暂停" -- 1826
	end -- 1826
	return table.concat(parts, " · ") -- 1828
end -- 1712
function Play.prototype.aliveEnemies(self) -- 1832
	local n = 0 -- 1833
	local i = 0 -- 1834
	do -- 1834
		i = 0 -- 1835
		while i < #self.enemies do -- 1835
			if self.enemies[i + 1].alive then -- 1835
				n = n + 1 -- 1837
			end -- 1837
			i = i + 1 -- 1835
		end -- 1835
	end -- 1835
	return n -- 1840
end -- 1832
function Play.prototype.gateLabel(self) -- 1844
	if self.phase == "gate-idle" then -- 1844
		return "待就位" -- 1846
	end -- 1846
	if self.phase == "gate-hold" then -- 1846
		return "守点中" -- 1849
	end -- 1849
	if self.phase == "gate-send" then -- 1849
		return "送别" -- 1852
	end -- 1852
	if self.phase == "gate-count" then -- 1852
		return "数数 " .. tostring(self.countTick) -- 1855
	end -- 1855
	return "她走" -- 1857
end -- 1844
function Play.prototype.dogLabel(self) -- 1861
	if self.dogState == "ear" then -- 1861
		return "转耳" -- 1863
	end -- 1863
	if self.dogState == "chase" then -- 1863
		return "追" -- 1866
	end -- 1866
	if self.dogState == "sniff" then -- 1866
		return "停" -- 1869
	end -- 1869
	if self.dogState == "back" then -- 1869
		return "回线" -- 1872
	end -- 1872
	return "巡逻" -- 1874
end -- 1861
function Play.prototype.doorXOf(self) -- 1877
	local ____temp_13 -- 1878
	if self.room.story == nil then -- 1878
		____temp_13 = nil -- 1878
	else -- 1878
		____temp_13 = self.room.story.tower -- 1878
	end -- 1878
	local t = ____temp_13 -- 1878
	return t == nil and 0 or t.doorX -- 1879
end -- 1877
function Play.prototype.scavLabel(self) -- 1883
	if self.scavState == "chase" then -- 1883
		return "追" -- 1885
	end -- 1885
	if self.scavState == "turn" then -- 1885
		return "转头" -- 1888
	end -- 1888
	if self.scavState == "walk" then -- 1888
		return "赶来" -- 1891
	end -- 1891
	if self.scavState == "stall" then -- 1891
		return "停住" -- 1894
	end -- 1894
	if self.scavState == "back" then -- 1894
		return "回位" -- 1897
	end -- 1897
	return "巡逻" -- 1899
end -- 1883
function Play.prototype.hintText(self) -- 1903
	if self.paused then -- 1903
		return "Esc 继续 · R 重置" -- 1905
	end -- 1905
	if self.flash ~= "" then -- 1905
		return self.flash -- 1908
	end -- 1908
	if self.room.key == "prologue" then -- 1908
		if self.phase == "prologue-wait" then -- 1908
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 1912
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 1913
		end -- 1913
		if self.phase == "prologue-give" then -- 1913
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 1916
		end -- 1916
		return "她跟着你了 · 两人一起走到门口 680" -- 1918
	end -- 1918
	if self.room.key == "street" then -- 1918
		if self:aliveEnemies() > 0 then -- 1918
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 1922
		end -- 1922
		return "清完了 · 两人一起走到右边检查站入口 900" -- 1924
	end -- 1924
	if self.room.key == "gate" then -- 1924
		local ____temp_14 -- 1927
		if self.room.story == nil then -- 1927
			____temp_14 = nil -- 1927
		else -- 1927
			____temp_14 = self.room.story.gate -- 1927
		end -- 1927
		local g = ____temp_14 -- 1927
		if g ~= nil then -- 1927
			if self.phase == "gate-idle" then -- 1927
				return "小满到门洞 960、周戍回绞盘 195，两人就位才开始守点" -- 1930
			end -- 1930
			if self.phase == "gate-hold" then -- 1930
				if self.coveredFlash > 0 then -- 1930
					return "掩体挡下了这一枪 · 别露头" -- 1934
				end -- 1934
				return "红灯是预警 · 先贴街垒 520（Shift）再 F 射击 · 守满去门边 860 按 E" -- 1936
			end -- 1936
			if self.phase == "gate-send" then -- 1936
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 1939
			end -- 1939
			if self.phase == "gate-count" then -- 1939
				if self.countTick >= 1440 then -- 1939
					return self.countArmed and "新按 D · 让她迈出第一步" or "先松开方向键，再按 D" -- 1943
				end -- 1943
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 1945
			end -- 1945
			return "她自己走 · 跟着出城门 1120" -- 1947
		end -- 1947
	end -- 1947
	if self.room.key == "forest" then -- 1947
		if self.dogState == "chase" then -- 1947
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 1952
		end -- 1952
		if self.dogState == "ear" then -- 1952
			return "狗转耳朵了 · 停下或蹲下别出声" -- 1955
		end -- 1955
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 1957
	end -- 1957
	if self.room.key == "tower" then -- 1957
		if self.phase == "tower-wait" then -- 1957
			return "走到门前 445 点一次 E 敲两下" -- 1961
		end -- 1961
		if self.phase == "tower-knock" then -- 1961
			return "敲两下 · 等门开" -- 1964
		end -- 1964
		if self.phase == "tower-given" then -- 1964
			return "递交针套和纸条 · 看登记簿最后一行" -- 1967
		end -- 1967
		return "片尾 · 点 E 再玩一次，回到序章" -- 1969
	end -- 1969
	if self.room.key == "village" then -- 1969
		if self.bottleFly ~= nil then -- 1969
			return "等瓶子落地 · 触地才发声" -- 1973
		end -- 1973
		if self.hasBottle then -- 1973
			return "按住 F 瞄，松手投 · 往右投到砖地 608，他才会走开" -- 1976
		end -- 1976
		if self.passed then -- 1976
			return "已过第一院 · R 重置可再来一遍" -- 1979
		end -- 1979
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 1981
	end -- 1981
	if self.room.key == "outside" then -- 1981
		if self.focusCart then -- 1981
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 1985
		end -- 1985
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 1987
	end -- 1987
	if self.escort.state == "frozen" then -- 1987
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 1987
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 1991
		end -- 1991
		return "小满吓住了 · 走过去，靠近再点 E" -- 1993
	end -- 1993
	if self.escort.state == "calming" then -- 1993
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 1996
	end -- 1996
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 1998
end -- 1903
function Play.prototype.draw(self, draw, w, h) -- 2003
	self.viewW = w -- 2004
	self.viewH = h -- 2005
	self.view = ____exports.computeViewport(w, h) -- 2006
	self:clampCamera(w, h) -- 2007
	draw:clear() -- 2008
	draw:drawRect( -- 2010
		Rect(0, 0, w, h), -- 2010
		BG_VOID -- 2010
	) -- 2010
	local box = self:canvasRect(w, h) -- 2011
	draw:drawRect(box, BG_FAR) -- 2012
	draw:drawRect( -- 2013
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 2013
		BG_MID -- 2013
	) -- 2013
	self:drawFloors(draw, w, h) -- 2015
	self:drawSolids(draw, w, h) -- 2016
	self:drawZones(draw, w, h) -- 2017
	self:drawArch(draw, w, h) -- 2018
	self:drawCart(draw, w, h) -- 2019
	self:drawActors(draw, w, h) -- 2020
	self:drawTrace(draw, w, h) -- 2021
	self:drawAim(draw, w, h) -- 2022
end -- 2003
function Play.prototype.canvasRect(self, w, h) -- 2026
	local v = self.view -- 2027
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 2028
end -- 2026
function Play.prototype.px(self, n) -- 2032
	return n * self.view.zoom -- 2033
end -- 2032
function Play.prototype.sx(self, wx, w) -- 2037
	local v = self.view -- 2038
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 2039
	return v.ox + lx * v.zoom -- 2040
end -- 2037
function Play.prototype.sy(self, wy, h) -- 2044
	local v = self.view -- 2045
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 2046
	return v.oy + ly * v.zoom -- 2047
end -- 2044
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 2050
	local px0 = self:sx(x0, w) -- 2051
	local px1 = self:sx(x1, w) -- 2052
	local py0 = self:sy(y0, h) -- 2053
	local py1 = self:sy(y1, h) -- 2054
	if px1 <= px0 or py1 <= py0 then -- 2054
		return -- 2056
	end -- 2056
	draw:drawRect( -- 2058
		Rect(px0, py0, px1 - px0, py1 - py0), -- 2058
		color -- 2058
	) -- 2058
end -- 2050
function Play.prototype.drawFloors(self, draw, w, h) -- 2061
	local i = 0 -- 2062
	do -- 2062
		i = 0 -- 2063
		while i < #self.room.floors do -- 2063
			local f = self.room.floors[i + 1] -- 2064
			local y = self:sy(f.y, h) -- 2065
			local x0 = self:sx(f.x0, w) -- 2066
			local x1 = self:sx(f.x1, w) -- 2067
			local deck = self:px(5) -- 2068
			draw:drawRect( -- 2069
				Rect(x0, y - deck, x1 - x0, deck), -- 2069
				FLOOR_DECK -- 2069
			) -- 2069
			draw:drawSegment( -- 2070
				Vec2(x0, y), -- 2070
				Vec2(x1, y), -- 2070
				self:px(1), -- 2070
				GROUND -- 2070
			) -- 2070
			i = i + 1 -- 2063
		end -- 2063
	end -- 2063
end -- 2061
function Play.prototype.drawSolids(self, draw, w, h) -- 2074
	local i = 0 -- 2075
	do -- 2075
		i = 0 -- 2076
		while i < #self.boxes do -- 2076
			do -- 2076
				local b = self.boxes[i + 1] -- 2077
				if b.y0 < -4 and b.y1 <= 96 then -- 2077
					draw:drawSegment( -- 2080
						Vec2( -- 2080
							self:sx(b.x0, w), -- 2080
							self:sy(b.y1, h) -- 2080
						), -- 2080
						Vec2( -- 2080
							self:sx(b.x1, w), -- 2080
							self:sy(b.y1, h) -- 2080
						), -- 2080
						self:px(1), -- 2080
						GROUND -- 2080
					) -- 2080
					goto __continue422 -- 2081
				end -- 2081
				self:drawBox( -- 2083
					draw, -- 2083
					w, -- 2083
					h, -- 2083
					b.x0, -- 2083
					b.x1, -- 2083
					b.y0, -- 2083
					b.y1, -- 2083
					SOLID_FILL -- 2083
				) -- 2083
				draw:drawSegment( -- 2084
					Vec2( -- 2084
						self:sx(b.x0, w), -- 2084
						self:sy(b.y1, h) -- 2084
					), -- 2084
					Vec2( -- 2084
						self:sx(b.x1, w), -- 2084
						self:sy(b.y1, h) -- 2084
					), -- 2084
					self:px(1), -- 2084
					SOLID_EDGE -- 2084
				) -- 2084
			end -- 2084
			::__continue422:: -- 2084
			i = i + 1 -- 2076
		end -- 2076
	end -- 2076
end -- 2074
function Play.prototype.drawZones(self, draw, w, h) -- 2088
	local i = 0 -- 2089
	do -- 2089
		i = 0 -- 2090
		while i < #self.room.zones do -- 2090
			local z = self.room.zones[i + 1] -- 2091
			local fill = DANGER -- 2092
			local line = DANGER_LINE -- 2093
			if z.tint == 2 then -- 2093
				fill = SOFT -- 2095
				line = SOFT_LINE -- 2096
			elseif z.tint == 3 then -- 2096
				fill = BRICK -- 2098
				line = BRICK_LINE -- 2099
			elseif z.tint == 4 then -- 2099
				fill = PASS -- 2101
				line = PASS_LINE -- 2102
			end -- 2102
			self:drawBox( -- 2104
				draw, -- 2104
				w, -- 2104
				h, -- 2104
				z.x0, -- 2104
				z.x1, -- 2104
				z.y, -- 2104
				z.y + z.h, -- 2104
				fill -- 2104
			) -- 2104
			draw:drawSegment( -- 2105
				Vec2( -- 2105
					self:sx(z.x0, w), -- 2105
					self:sy(z.y, h) -- 2105
				), -- 2105
				Vec2( -- 2105
					self:sx(z.x0, w), -- 2105
					self:sy(z.y + z.h, h) -- 2105
				), -- 2105
				self:px(1), -- 2105
				line -- 2105
			) -- 2105
			draw:drawSegment( -- 2106
				Vec2( -- 2106
					self:sx(z.x1, w), -- 2106
					self:sy(z.y, h) -- 2106
				), -- 2106
				Vec2( -- 2106
					self:sx(z.x1, w), -- 2106
					self:sy(z.y + z.h, h) -- 2106
				), -- 2106
				self:px(1), -- 2106
				line -- 2106
			) -- 2106
			i = i + 1 -- 2090
		end -- 2090
	end -- 2090
end -- 2088
function Play.prototype.drawArch(self, draw, w, h) -- 2110
	local a = self.room.arch -- 2111
	if a.h <= 0 then -- 2111
		return -- 2113
	end -- 2113
	self:drawBox( -- 2115
		draw, -- 2115
		w, -- 2115
		h, -- 2115
		a.x0, -- 2115
		a.x1, -- 2115
		a.y, -- 2115
		a.y + a.h, -- 2115
		HOLE_FILL -- 2115
	) -- 2115
	draw:drawSegment( -- 2116
		Vec2( -- 2116
			self:sx(a.x0, w), -- 2116
			self:sy(a.y + a.h, h) -- 2116
		), -- 2116
		Vec2( -- 2116
			self:sx(a.x1, w), -- 2116
			self:sy(a.y + a.h, h) -- 2116
		), -- 2116
		self:px(1), -- 2116
		SOLID_EDGE -- 2116
	) -- 2116
	draw:drawSegment( -- 2117
		Vec2( -- 2117
			self:sx(a.x0, w), -- 2117
			self:sy(a.y, h) -- 2117
		), -- 2117
		Vec2( -- 2117
			self:sx(a.x0, w), -- 2117
			self:sy(a.y + a.h, h) -- 2117
		), -- 2117
		self:px(1), -- 2117
		SOLID_EDGE -- 2117
	) -- 2117
	draw:drawSegment( -- 2118
		Vec2( -- 2118
			self:sx(a.x1, w), -- 2118
			self:sy(a.y, h) -- 2118
		), -- 2118
		Vec2( -- 2118
			self:sx(a.x1, w), -- 2118
			self:sy(a.y + a.h, h) -- 2118
		), -- 2118
		self:px(1), -- 2118
		SOLID_EDGE -- 2118
	) -- 2118
end -- 2110
function Play.prototype.drawCart(self, draw, w, h) -- 2121
	local c = self.room.cart -- 2122
	if c.bodyW <= 0 then -- 2122
		return -- 2124
	end -- 2124
	drawCartShape( -- 2126
		draw, -- 2126
		self, -- 2126
		w, -- 2126
		h, -- 2126
		c, -- 2126
		self.cartAxle -- 2126
	) -- 2126
	draw:drawRect( -- 2127
		Rect( -- 2127
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 2127
			self:sy(c.baseY + 40, h), -- 2127
			self:px(2), -- 2127
			self:px(40) -- 2127
		), -- 2127
		STAND -- 2127
	) -- 2127
end -- 2121
function Play.prototype.drawActors(self, draw, w, h) -- 2130
	local p = self.player -- 2131
	local isChild = self.childMode -- 2132
	drawFigure( -- 2133
		draw, -- 2133
		self, -- 2133
		w, -- 2133
		h, -- 2133
		p, -- 2133
		isChild and CHILD_BODY or SOLDIER_BODY, -- 2133
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 2133
	) -- 2133
	local q = self.partner -- 2134
	if q.alive then -- 2134
		local childPartner = q.w == CHILD_W -- 2136
		drawFigure( -- 2137
			draw, -- 2137
			self, -- 2137
			w, -- 2137
			h, -- 2137
			q, -- 2137
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 2137
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 2137
		) -- 2137
	end -- 2137
	local i = 0 -- 2139
	do -- 2139
		i = 0 -- 2140
		while i < #self.enemies do -- 2140
			local e = self.enemies[i + 1] -- 2141
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 2142
			self:drawBox( -- 2143
				draw, -- 2143
				w, -- 2143
				h, -- 2143
				e.x - e.w / 2, -- 2143
				e.x + e.w / 2, -- 2143
				e.y, -- 2143
				e.y + e.h, -- 2143
				col -- 2143
			) -- 2143
			if e.alive and e.warnT > 0 then -- 2143
				local gunX = self:sx(e.x, w) -- 2146
				local gunY = self:sy(e.y + e.h * 0.72, h) -- 2147
				local aimX = self:sx(p.x, w) -- 2148
				local aimY = self:sy(p.y + p.h * 0.55, h) -- 2149
				local seg = 8 -- 2150
				local s = 0 -- 2151
				do -- 2151
					s = 0 -- 2152
					while s < seg do -- 2152
						local t0 = s / seg -- 2153
						local t1 = (s + 1) / seg -- 2154
						draw:drawSegment( -- 2155
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 2156
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 2157
							self:px(1), -- 2158
							DANGER -- 2158
						) -- 2158
						s = s + 2 -- 2152
					end -- 2152
				end -- 2152
			end -- 2152
			i = i + 1 -- 2140
		end -- 2140
	end -- 2140
	local k = 0 -- 2163
	do -- 2163
		k = 0 -- 2164
		while k < #self.room.marks do -- 2164
			do -- 2164
				local m = self.room.marks[k + 1] -- 2165
				if m.kind ~= 0 then -- 2165
					goto __continue442 -- 2167
				end -- 2167
				local on = self.checkpoint == m.x -- 2169
				local x = self:sx(m.x, w) -- 2170
				local y = self:sy(m.y, h) -- 2171
				draw:drawSegment( -- 2172
					Vec2(x, y), -- 2172
					Vec2( -- 2172
						x, -- 2172
						y + self:px(35) -- 2172
					), -- 2172
					self:px(1), -- 2172
					on and CHECK or INK_DIM -- 2172
				) -- 2172
				draw:drawDot( -- 2173
					Vec2( -- 2173
						x, -- 2173
						y + self:px(35) -- 2173
					), -- 2173
					self:px(2), -- 2173
					on and CHECK or INK_DIM -- 2173
				) -- 2173
			end -- 2173
			::__continue442:: -- 2173
			k = k + 1 -- 2164
		end -- 2164
	end -- 2164
	local j = 0 -- 2177
	do -- 2177
		j = 0 -- 2178
		while j < #self.room.marks do -- 2178
			do -- 2178
				local m = self.room.marks[j + 1] -- 2179
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 2179
					goto __continue445 -- 2181
				end -- 2181
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 2181
					goto __continue445 -- 2185
				end -- 2185
				local col = STAND -- 2187
				if m.kind == 4 then -- 2187
					col = PASS_LINE -- 2189
				elseif m.kind == 5 then -- 2189
					col = BRICK_LINE -- 2191
				end -- 2191
				local mx = self:sx(m.x, w) -- 2193
				local my = self:sy(m.y, h) -- 2194
				draw:drawSegment( -- 2195
					Vec2(mx, my), -- 2195
					Vec2( -- 2195
						mx, -- 2195
						my + self:px(24) -- 2195
					), -- 2195
					self:px(1), -- 2195
					col -- 2195
				) -- 2195
			end -- 2195
			::__continue445:: -- 2195
			j = j + 1 -- 2178
		end -- 2178
	end -- 2178
	local t = 0 -- 2198
	do -- 2198
		t = 0 -- 2199
		while t < #self.room.marks do -- 2199
			do -- 2199
				local m = self.room.marks[t + 1] -- 2200
				if m.kind ~= 6 then -- 2200
					goto __continue451 -- 2202
				end -- 2202
				local mx = self:sx(m.x, w) -- 2204
				local my = self:sy(m.y, h) -- 2205
				draw:drawSegment( -- 2206
					Vec2(mx, my), -- 2206
					Vec2( -- 2206
						mx, -- 2206
						my + self:px(30) -- 2206
					), -- 2206
					self:px(1), -- 2206
					INK_DIM -- 2206
				) -- 2206
				self:drawBox( -- 2207
					draw, -- 2207
					w, -- 2207
					h, -- 2207
					m.x - 5, -- 2207
					m.x + 5, -- 2207
					m.y + 30, -- 2207
					m.y + 40, -- 2207
					CHECK -- 2207
				) -- 2207
			end -- 2207
			::__continue451:: -- 2207
			t = t + 1 -- 2199
		end -- 2199
	end -- 2199
	if self.room.key == "village" then -- 2199
		self:drawVillage(draw, w, h) -- 2210
	end -- 2210
	if self.room.key == "forest" then -- 2210
		self:drawDog(draw, w, h) -- 2213
	end -- 2213
end -- 2130
function Play.prototype.drawDog(self, draw, w, h) -- 2218
	local x = self.dogX -- 2219
	self:drawBox( -- 2220
		draw, -- 2220
		w, -- 2220
		h, -- 2220
		x - 14, -- 2220
		x + 14, -- 2220
		0, -- 2220
		20, -- 2220
		SCAV_BODY -- 2220
	) -- 2220
	self:drawBox( -- 2221
		draw, -- 2221
		w, -- 2221
		h, -- 2221
		x - 10, -- 2221
		x - 2, -- 2221
		20, -- 2221
		30, -- 2221
		SCAV_BODY -- 2221
	) -- 2221
	self:drawBox( -- 2222
		draw, -- 2222
		w, -- 2222
		h, -- 2222
		x + 2, -- 2222
		x + 10, -- 2222
		20, -- 2222
		30, -- 2222
		SCAV_HEAD -- 2222
	) -- 2222
	if self.dogState == "ear" or self.dogState == "chase" then -- 2222
		draw:drawSegment( -- 2224
			Vec2( -- 2224
				self:sx(x, w), -- 2224
				self:sy(30, h) -- 2224
			), -- 2224
			Vec2( -- 2225
				self:sx(x, w), -- 2225
				self:sy(40, h) -- 2225
			), -- 2225
			self:px(1), -- 2225
			DANGER -- 2225
		) -- 2225
	end -- 2225
end -- 2218
function Play.prototype.drawVillage(self, draw, w, h) -- 2230
	local bottle = self.room.bottle -- 2231
	if bottle ~= nil then -- 2231
		self:drawBox( -- 2233
			draw, -- 2233
			w, -- 2233
			h, -- 2233
			bottle.x - 14, -- 2233
			bottle.x + 14, -- 2233
			0, -- 2233
			64, -- 2233
			SOLID_FILL -- 2233
		) -- 2233
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 2233
			self:drawBottle( -- 2235
				draw, -- 2235
				w, -- 2235
				h, -- 2235
				bottle.x, -- 2235
				64 -- 2235
			) -- 2235
		end -- 2235
	end -- 2235
	self:drawBox( -- 2239
		draw, -- 2239
		w, -- 2239
		h, -- 2239
		300, -- 2239
		420, -- 2239
		44, -- 2239
		50, -- 2239
		FLOOR_DECK -- 2239
	) -- 2239
	self:drawBox( -- 2240
		draw, -- 2240
		w, -- 2240
		h, -- 2240
		300, -- 2240
		306, -- 2240
		0, -- 2240
		44, -- 2240
		FLOOR_DECK -- 2240
	) -- 2240
	self:drawBox( -- 2241
		draw, -- 2241
		w, -- 2241
		h, -- 2241
		414, -- 2241
		420, -- 2241
		0, -- 2241
		44, -- 2241
		FLOOR_DECK -- 2241
	) -- 2241
	local s = self.room.scavenger -- 2243
	if s ~= nil then -- 2243
		local sx0 = self.scavX -- 2245
		self:drawBox( -- 2246
			draw, -- 2246
			w, -- 2246
			h, -- 2246
			sx0 - 12, -- 2246
			sx0 + 12, -- 2246
			0, -- 2246
			s.h - 14, -- 2246
			SCAV_BODY -- 2246
		) -- 2246
		self:drawBox( -- 2247
			draw, -- 2247
			w, -- 2247
			h, -- 2247
			sx0 - 7, -- 2247
			sx0 + 7, -- 2247
			s.h - 14, -- 2247
			s.h, -- 2247
			SCAV_HEAD -- 2247
		) -- 2247
		if self.scavState == "turn" then -- 2247
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 2249
			draw:drawSegment( -- 2250
				Vec2( -- 2250
					self:sx(sx0, w), -- 2250
					self:sy(s.h - 6, h) -- 2250
				), -- 2250
				Vec2( -- 2250
					self:sx(fx, w), -- 2250
					self:sy(s.h - 6, h) -- 2250
				), -- 2250
				self:px(1), -- 2250
				INK -- 2250
			) -- 2250
		end -- 2250
	end -- 2250
	if self.hasBottle then -- 2250
		local p = self.player -- 2255
		self:drawBottle( -- 2256
			draw, -- 2256
			w, -- 2256
			h, -- 2256
			p.x + p.facing * 10, -- 2256
			p.y + p.h * 0.62 -- 2256
		) -- 2256
	end -- 2256
	if self.bottleFly ~= nil then -- 2256
		self:drawBottle( -- 2259
			draw, -- 2259
			w, -- 2259
			h, -- 2259
			self.bottleFly.x, -- 2259
			self.bottleFly.y -- 2259
		) -- 2259
	end -- 2259
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 2259
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 2262
		draw:drawCircle( -- 2263
			Vec2( -- 2263
				self:sx(self.bottleLandX, w), -- 2263
				self:sy(0, h) -- 2263
			), -- 2263
			self:px(r / ____exports.UNITS_PER_PX), -- 2263
			BRICK_LINE -- 2263
		) -- 2263
	end -- 2263
end -- 2230
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 2267
	self:drawBox( -- 2268
		draw, -- 2268
		w, -- 2268
		h, -- 2268
		x - 3, -- 2268
		x + 3, -- 2268
		y - 10, -- 2268
		y, -- 2268
		BOTTLE -- 2268
	) -- 2268
end -- 2267
function Play.prototype.drawTrace(self, draw, w, h) -- 2271
	local t = self.trace -- 2272
	if t == nil or self.traceT <= 0 then -- 2272
		return -- 2274
	end -- 2274
	draw:drawSegment( -- 2276
		Vec2( -- 2277
			self:sx(t.x0, w), -- 2277
			self:sy(t.y0, h) -- 2277
		), -- 2277
		Vec2( -- 2278
			self:sx(t.x1, w), -- 2278
			self:sy(t.y1, h) -- 2278
		), -- 2278
		self:px(1), -- 2279
		t.hit and AIM_HIT or INK_DIM -- 2279
	) -- 2279
end -- 2271
function Play.prototype.drawAim(self, draw, w, h) -- 2282
	local v = self.view -- 2284
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 2285
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 2286
	local dot = self:px(1) -- 2287
	local arm = self:px(3) -- 2288
	local gap = self:px(1) -- 2289
	draw:drawSegment( -- 2290
		Vec2(gx - arm - gap, gy), -- 2290
		Vec2(gx - gap, gy), -- 2290
		dot / 2, -- 2290
		AIM -- 2290
	) -- 2290
	draw:drawSegment( -- 2291
		Vec2(gx + gap, gy), -- 2291
		Vec2(gx + arm + gap, gy), -- 2291
		dot / 2, -- 2291
		AIM -- 2291
	) -- 2291
	draw:drawSegment( -- 2292
		Vec2(gx, gy - arm - gap), -- 2292
		Vec2(gx, gy - gap), -- 2292
		dot / 2, -- 2292
		AIM -- 2292
	) -- 2292
	draw:drawSegment( -- 2293
		Vec2(gx, gy + gap), -- 2293
		Vec2(gx, gy + arm + gap), -- 2293
		dot / 2, -- 2293
		AIM -- 2293
	) -- 2293
	if self.room.key == "village" and self.hasBottle then -- 2293
		local p = self.player -- 2297
		local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2298
		local x0 = p.x + p.facing * 10 -- 2299
		local y0 = p.y + p.h * 0.7 -- 2300
		local T = 0.62 -- 2301
		local vx = (aim.x - x0) / T -- 2302
		local vy = (aim.y - y0 + 0.5 * GRAVITY * T * T) / T -- 2303
		local pxr = x0 -- 2304
		local pyr = y0 -- 2305
		local t = 1 -- 2306
		do -- 2306
			t = 1 -- 2307
			while t <= 12 do -- 2307
				local tt = t / 12 * T -- 2308
				local nx = x0 + vx * tt -- 2309
				local ny = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 2310
				draw:drawSegment( -- 2311
					Vec2( -- 2311
						self:sx(pxr, w), -- 2311
						self:sy(pyr, h) -- 2311
					), -- 2311
					Vec2( -- 2311
						self:sx(nx, w), -- 2311
						self:sy(ny, h) -- 2311
					), -- 2311
					self:px(1) / 2, -- 2311
					BOTTLE -- 2311
				) -- 2311
				pxr = nx -- 2312
				pyr = ny -- 2313
				t = t + 1 -- 2307
			end -- 2307
		end -- 2307
	end -- 2307
end -- 2282
return ____exports -- 2282