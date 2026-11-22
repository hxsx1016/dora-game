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
function makeActor(room, index) -- 2162
	local sp = room.spawns -- 2163
	if index < 0 or index >= #sp then -- 2163
		return { -- 2165
			x = 0, -- 2165
			y = 0, -- 2165
			vx = 0, -- 2165
			vy = 0, -- 2165
			w = CHILD_W, -- 2165
			h = CHILD_H, -- 2165
			onGround = true, -- 2165
			facing = 1, -- 2165
			crouch = false, -- 2165
			rollT = 0, -- 2165
			covered = false, -- 2165
			alive = false -- 2165
		} -- 2165
	end -- 2165
	local s = sp[index + 1] -- 2167
	local child = s.h <= CHILD_H -- 2168
	return { -- 2169
		x = s.x, -- 2170
		y = s.y, -- 2170
		vx = 0, -- 2170
		vy = 0, -- 2170
		w = child and CHILD_W or SOLDIER_W, -- 2171
		h = child and CHILD_H or SOLDIER_H, -- 2172
		onGround = true, -- 2173
		facing = 1, -- 2173
		crouch = false, -- 2173
		rollT = 0, -- 2173
		covered = false, -- 2173
		alive = true -- 2173
	} -- 2173
end -- 2173
function drawFigure(draw, play, w, h, a, body, head) -- 2177
	if not a.alive then -- 2177
		return -- 2179
	end -- 2179
	local x0 = a.x - a.w / 2 -- 2181
	local x1 = a.x + a.w / 2 -- 2182
	local y0 = a.y -- 2183
	local y1 = a.y + a.h -- 2184
	play:drawBox( -- 2185
		draw, -- 2185
		w, -- 2185
		h, -- 2185
		x0, -- 2185
		x1, -- 2185
		y0, -- 2185
		y1 - a.h * 0.26, -- 2185
		body -- 2185
	) -- 2185
	play:drawBox( -- 2186
		draw, -- 2186
		w, -- 2186
		h, -- 2186
		x0 + 2, -- 2186
		x1 - 2, -- 2186
		y1 - a.h * 0.26, -- 2186
		y1, -- 2186
		head -- 2186
	) -- 2186
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 2188
	play:drawBox( -- 2189
		draw, -- 2189
		w, -- 2189
		h, -- 2189
		eyeX, -- 2189
		eyeX + 4, -- 2189
		y1 - a.h * 0.14, -- 2189
		y1 - a.h * 0.08, -- 2189
		INK -- 2189
	) -- 2189
end -- 2189
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 2193
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 2194
end -- 2193
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 2201
	local tmin = 0 -- 2202
	local tmax = 99999 -- 2203
	if dx == 0 then -- 2203
		if ox < x0 or ox > x1 then -- 2203
			return -1 -- 2206
		end -- 2206
	else -- 2206
		local t1 = (x0 - ox) / dx -- 2209
		local t2 = (x1 - ox) / dx -- 2210
		local lo = t1 < t2 and t1 or t2 -- 2211
		local hi = t1 < t2 and t2 or t1 -- 2212
		if lo > tmin then -- 2212
			tmin = lo -- 2214
		end -- 2214
		if hi < tmax then -- 2214
			tmax = hi -- 2217
		end -- 2217
	end -- 2217
	if dy == 0 then -- 2217
		if oy < y0 or oy > y1 then -- 2217
			return -1 -- 2222
		end -- 2222
	else -- 2222
		local t1 = (y0 - oy) / dy -- 2225
		local t2 = (y1 - oy) / dy -- 2226
		local lo = t1 < t2 and t1 or t2 -- 2227
		local hi = t1 < t2 and t2 or t1 -- 2228
		if lo > tmin then -- 2228
			tmin = lo -- 2230
		end -- 2230
		if hi < tmax then -- 2230
			tmax = hi -- 2233
		end -- 2233
	end -- 2233
	return tmax >= tmin and tmin or -1 -- 2236
end -- 2236
function drawCartShape(draw, play, w, h, c, axleX) -- 2239
	local half = c.bodyW / 2 -- 2240
	local x0 = axleX - half -- 2241
	local x1 = axleX + half -- 2242
	play:drawBox( -- 2243
		draw, -- 2243
		w, -- 2243
		h, -- 2243
		x0, -- 2243
		x1, -- 2243
		c.baseY + c.wheelR, -- 2243
		c.baseY + c.wheelR + c.bodyH, -- 2243
		CART_FILL -- 2243
	) -- 2243
	draw:drawCircle( -- 2244
		Vec2( -- 2244
			play:sx(x0 + c.bodyW * 0.28, w), -- 2244
			play:sy(c.baseY + c.wheelR, h) -- 2244
		), -- 2244
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2244
		Color(52, 50, 48, 255) -- 2244
	) -- 2244
	draw:drawCircle( -- 2245
		Vec2( -- 2245
			play:sx(x1 - c.bodyW * 0.28, w), -- 2245
			play:sy(c.baseY + c.wheelR, h) -- 2245
		), -- 2245
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2245
		Color(52, 50, 48, 255) -- 2245
	) -- 2245
	local cx = c.clothSide < 0 and x0 or x1 -- 2246
	play:drawBox( -- 2247
		draw, -- 2247
		w, -- 2247
		h, -- 2247
		cx - 10, -- 2247
		cx + 10, -- 2247
		c.baseY + c.wheelR + c.bodyH, -- 2247
		c.baseY + c.wheelR + c.bodyH + 18, -- 2247
		CLOTH -- 2247
	) -- 2247
end -- 2247
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
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 165
	if key == "prologue" then -- 165
		return "prologue-wait" -- 167
	end -- 167
	if key == "street" then -- 167
		return "street-run" -- 170
	end -- 170
	if key == "gate" then -- 170
		return "gate-idle" -- 173
	end -- 173
	if key == "forest" then -- 173
		return "forest-run" -- 176
	end -- 176
	if key == "tower" then -- 176
		return "tower-wait" -- 179
	end -- 179
	return "run" -- 181
end -- 165
____exports.Play = __TS__Class() -- 184
local Play = ____exports.Play -- 184
Play.name = "Play" -- 184
function Play.prototype.____constructor(self, room, resume) -- 287
	self.enemies = {} -- 189
	self.boxes = {} -- 190
	self.floors = {} -- 191
	self.checkpoint = -1 -- 193
	self.flash = "" -- 195
	self.flashT = 0 -- 196
	self.traceT = 0 -- 199
	self.focusCart = false -- 201
	self.knocks = 0 -- 203
	self.knockT = 0 -- 204
	self.cartAxle = 0 -- 208
	self.cartDocked = false -- 210
	self.gripping = false -- 212
	self.gateOpen = false -- 214
	self.calmConsumed = false -- 216
	self.nextDangerId = 1 -- 218
	self.wantRoom = "" -- 220
	self.carryCartAxle = -1 -- 222
	self.carryCartDocked = false -- 223
	self.checkpointCartAxle = -1 -- 225
	self.hasBottle = false -- 229
	self.bottleLandX = -1 -- 233
	self.bottleLandT = 0 -- 234
	self.aimHold = 0 -- 236
	self.scavX = 0 -- 238
	self.scavDir = 1 -- 239
	self.scavState = "patrol" -- 240
	self.scavT = 0 -- 241
	self.scavTargetX = 0 -- 242
	self.passed = false -- 244
	self.childMode = false -- 248
	self.phase = "" -- 250
	self.phaseTick = 0 -- 252
	self.gateTick = 0 -- 254
	self.countTick = 0 -- 256
	self.countArmed = false -- 258
	self.caughtT = 0 -- 260
	self.dogX = 0 -- 262
	self.dogDir = 1 -- 263
	self.dogState = "patrol" -- 264
	self.dogT = 0 -- 265
	self.dogTargetX = 0 -- 266
	self.scavSee = 0 -- 268
	self.scavChase = false -- 269
	self.gateSpawned = 0 -- 271
	self.paused = false -- 273
	self.ticks = 0 -- 275
	self.view = {zoom = 1, ox = 0, oy = 0} -- 277
	self.ox = 0 -- 279
	self.aimX = 0 -- 281
	self.aimY = 0 -- 282
	self.viewW = 0 -- 284
	self.viewH = 0 -- 285
	self.ox = room.originX -- 289
	self.room = withOrigin(room) -- 290
	local wr = self.room -- 291
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 292
	self:buildWorld() -- 293
	self.childMode = wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower" -- 295
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 296
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 297
	self.player = makeActor(wr, playerIdx) -- 298
	self.partner = makeActor(wr, partnerIdx) -- 299
	self.phase = phaseOf(wr.key) -- 300
	if wr.story ~= nil then -- 300
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 302
	end -- 302
	self.cam.x = self.player.x -- 304
	self.cam.y = self.player.y + CAM_LOOK_UP -- 305
	self.cartAxle = wr.cart.startX -- 306
	self.escort = __TS__New( -- 307
		Escort, -- 307
		safeAnchorX(wr.marks) -- 307
	) -- 307
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 308
	self:buildEnemies() -- 309
	if resume ~= nil and resume.checkpoint > 0 then -- 309
		self.checkpoint = resume.checkpoint -- 312
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 312
			self.cartAxle = self.room.cart.endX -- 314
			self.cartDocked = true -- 315
			self.player.x = self.ox + 380 -- 318
			self.player.y = 0 -- 319
			self.player.vy = 0 -- 320
			self.player.onGround = true -- 321
			self.cam.x = self.player.x -- 322
			self.cam.y = self.player.y + CAM_LOOK_UP -- 323
		end -- 323
	end -- 323
end -- 287
function Play.prototype.buildWorld(self) -- 329
	local room = self.room -- 330
	self.boxes = {} -- 331
	self.floors = {} -- 332
	local i = 0 -- 333
	do -- 333
		i = 0 -- 334
		while i < #room.floors do -- 334
			local f = room.floors[i + 1] -- 335
			local ____self_floors_0 = self.floors -- 335
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 336
			i = i + 1 -- 334
		end -- 334
	end -- 334
	do -- 334
		i = 0 -- 338
		while i < #room.solids do -- 338
			local s = room.solids[i + 1] -- 339
			local ____self_boxes_1 = self.boxes -- 339
			____self_boxes_1[#____self_boxes_1 + 1] = { -- 340
				x0 = s.x, -- 340
				x1 = s.x + s.w, -- 340
				y0 = s.y, -- 340
				y1 = s.y + s.h, -- 340
				passable = s.passable == true -- 340
			} -- 340
			i = i + 1 -- 338
		end -- 338
	end -- 338
	do -- 338
		i = 0 -- 342
		while i < #room.stairs do -- 342
			local st = room.stairs[i + 1] -- 343
			local n = st.steps + 1 -- 344
			local stepW = (st.x1 - st.x0) / n -- 345
			local k = 0 -- 346
			do -- 346
				k = 0 -- 347
				while k < n do -- 347
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 348
					local x0 = st.x0 + stepW * k -- 349
					local ____self_boxes_2 = self.boxes -- 349
					____self_boxes_2[#____self_boxes_2 + 1] = { -- 351
						x0 = x0, -- 351
						x1 = x0 + stepW, -- 351
						y0 = -8, -- 351
						y1 = y, -- 351
						passable = true -- 351
					} -- 351
					k = k + 1 -- 347
				end -- 347
			end -- 347
			i = i + 1 -- 342
		end -- 342
	end -- 342
end -- 329
function Play.prototype.buildEnemies(self) -- 356
	self.enemies = {} -- 357
	if self.room.key == "checkpoint" then -- 357
		local ____self_enemies_3 = self.enemies -- 357
		____self_enemies_3[#____self_enemies_3 + 1] = { -- 359
			x = self.ox + 430, -- 359
			y = 0, -- 359
			w = 26, -- 359
			h = 84, -- 359
			alive = true, -- 359
			hitT = 0 -- 359
		} -- 359
		local ____self_enemies_4 = self.enemies -- 359
		____self_enemies_4[#____self_enemies_4 + 1] = { -- 360
			x = self.ox + 505, -- 360
			y = 0, -- 360
			w = 26, -- 360
			h = 84, -- 360
			alive = true, -- 360
			hitT = 0 -- 360
		} -- 360
		return -- 361
	end -- 361
	if self.room.key == "street" then -- 361
		local ____self_enemies_5 = self.enemies -- 361
		____self_enemies_5[#____self_enemies_5 + 1] = { -- 365
			x = self.ox + 340, -- 365
			y = 0, -- 365
			w = 26, -- 365
			h = 84, -- 365
			alive = true, -- 365
			hitT = 0 -- 365
		} -- 365
		local ____self_enemies_6 = self.enemies -- 365
		____self_enemies_6[#____self_enemies_6 + 1] = { -- 366
			x = self.ox + 560, -- 366
			y = 0, -- 366
			w = 26, -- 366
			h = 84, -- 366
			alive = true, -- 366
			hitT = 0 -- 366
		} -- 366
	end -- 366
end -- 356
function Play.prototype.update(self, dt, input) -- 372
	if input.pause.pressed then -- 372
		self.paused = not self.paused -- 374
	end -- 374
	if self.flashT > 0 then -- 374
		self.flashT = self.flashT - dt -- 377
		if self.flashT <= 0 then -- 377
			self.flash = "" -- 379
		end -- 379
	end -- 379
	if self.traceT > 0 then -- 379
		self.traceT = self.traceT - dt -- 383
		if self.traceT <= 0 then -- 383
			self.trace = nil -- 385
		end -- 385
	end -- 385
	if self.paused then -- 385
		self:updateCamera(dt) -- 389
		return -- 390
	end -- 390
	self.ticks = self.ticks + 1 -- 393
	local p = self.player -- 394
	self:stepPlayer(p, dt, input) -- 395
	self:stepStory(dt, input) -- 396
	self:stepEscort(dt, input) -- 397
	self:stepEnemies(dt) -- 398
	self:stepVillage(dt, input) -- 399
	self:stepChase(dt, input) -- 400
	self:stepInteract(dt, input) -- 401
	self:updateGate() -- 402
	self:updateCamera(dt) -- 403
end -- 372
function Play.prototype.nearLowLedge(self, a) -- 407
	local reach = 26 -- 408
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 409
	local x1 = x0 + reach -- 410
	local i = 0 -- 411
	do -- 411
		i = 0 -- 412
		while i < #self.boxes do -- 412
			do -- 412
				local b = self.boxes[i + 1] -- 413
				if b.x1 <= x0 or b.x0 >= x1 then -- 413
					goto __continue35 -- 415
				end -- 415
				local rise = b.y1 - a.y -- 417
				if rise > 0 and rise <= LEDGE_RISE then -- 417
					return true -- 419
				end -- 419
			end -- 419
			::__continue35:: -- 419
			i = i + 1 -- 412
		end -- 412
	end -- 412
	return false -- 422
end -- 407
function Play.prototype.stepPlayer(self, a, dt, input) -- 425
	if not a.alive then -- 425
		return -- 427
	end -- 427
	local isChild = self.childMode -- 429
	if self:storyLocked() then -- 429
		a.vx = 0 -- 432
		a.crouch = false -- 433
		a.h = isChild and CHILD_H or SOLDIER_H -- 434
		self:fallY(a, dt) -- 435
		return -- 436
	end -- 436
	if not isChild and self.escort.state == "calming" then -- 436
		a.crouch = false -- 440
		a.h = SOLDIER_H -- 441
		a.vx = 0 -- 442
		self:fallY(a, dt) -- 443
		return -- 444
	end -- 444
	a.crouch = isChild and input.crouch.held and a.onGround -- 446
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 447
	a.covered = not isChild and input.cover.held -- 448
	if a.rollT > 0 then -- 448
		a.rollT = a.rollT - dt -- 452
		a.vx = a.facing * ROLL_SPEED -- 453
		self:slideX(a, a.vx * dt) -- 454
		self:fallY(a, dt) -- 455
		if a.rollT <= 0 then -- 455
			self:flashSet("翻滚结束", 0.5) -- 457
		end -- 457
		return -- 459
	end -- 459
	if not isChild and input.jump.pressed and a.onGround then -- 459
		if input.moveX ~= 0 then -- 459
			a.facing = input.moveX > 0 and 1 or -1 -- 464
		end -- 464
		if self:nearLowLedge(a) then -- 464
			a.vy = SOLDIER_JUMP -- 468
			a.onGround = false -- 469
			self:flashSet("翻上去", 0.3) -- 470
			return -- 471
		end -- 471
		a.rollT = ROLL_TIME -- 473
		self:flashSet("翻滚", 0.3) -- 474
		return -- 475
	end -- 475
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 478
	if isChild then -- 478
		if input.cover.held then -- 478
			speed = CHILD_SLOW -- 481
		end -- 481
		if a.crouch then -- 481
			speed = CHILD_SLOW -- 484
		end -- 484
	elseif a.covered then -- 484
		speed = SOLDIER_SPEED * 0.45 -- 487
	end -- 487
	local dir = self.gripping and 0 or input.moveX -- 491
	if dir ~= 0 then -- 491
		a.facing = dir > 0 and 1 or -1 -- 493
	end -- 493
	a.vx = dir * speed -- 495
	if isChild and input.jump.pressed and a.onGround and not a.crouch then -- 495
		a.vy = CHILD_JUMP -- 499
		a.onGround = false -- 500
		self:flashSet("跳", 0.25) -- 501
	end -- 501
	self:slideX(a, a.vx * dt) -- 504
	self:fallY(a, dt) -- 505
	if not isChild and input.fire.pressed then -- 505
		self:shoot(a) -- 509
	end -- 509
end -- 425
function Play.prototype.stepPartner(self, p, dt) -- 514
	local a = self.partner -- 515
	if not a.alive then -- 515
		return -- 517
	end -- 517
	a.crouch = false -- 519
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 520
	a.vx = 0 -- 521
	self:fallY(a, dt) -- 522
end -- 514
function Play.prototype.stepEscort(self, dt, input) -- 529
	local a = self.partner -- 530
	if not a.alive then -- 530
		return -- 532
	end -- 532
	if not self:escortOn() then -- 532
		a.vx = 0 -- 535
		self:fallY(a, dt) -- 536
		return -- 537
	end -- 537
	local p = self.player -- 539
	local dist = math.abs(p.x - a.x) -- 540
	self.calmConsumed = self.escort:update( -- 541
		input, -- 541
		p.x, -- 541
		p.facing, -- 541
		a.x, -- 541
		dist -- 541
	) -- 541
	a.crouch = self.escort.crouchPose -- 542
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 543
	local dir = self.escort:moveDir(a.x) -- 544
	a.vx = dir * CHILD_SPEED -- 545
	if dir ~= 0 then -- 545
		a.facing = dir -- 547
		local before = a.x -- 548
		self:slideX(a, dir * CHILD_SPEED * dt) -- 549
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 549
			a.vy = CHILD_JUMP -- 552
			a.onGround = false -- 553
		end -- 553
	end -- 553
	self:fallY(a, dt) -- 556
end -- 529
function Play.prototype.escortOn(self) -- 560
	if self.room.key == "checkpoint" then -- 560
		return true -- 562
	end -- 562
	if self.room.key == "prologue" then -- 562
		return self.phase == "prologue-follow" -- 565
	end -- 565
	return self.room.key == "street" -- 567
end -- 560
function Play.prototype.storyLocked(self) -- 571
	if self.caughtT > 0 then -- 571
		return true -- 573
	end -- 573
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 573
		return true -- 576
	end -- 576
	if self.room.key == "gate" and self.phase == "gate-count" then -- 576
		return true -- 579
	end -- 579
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 579
		return true -- 582
	end -- 582
	return false -- 584
end -- 571
function Play.prototype.swapToChild(self, x) -- 588
	local tmp = self.player -- 589
	self.player = self.partner -- 590
	self.partner = tmp -- 591
	self.childMode = true -- 592
	self.player.alive = true -- 593
	self.player.x = self.ox + x -- 594
	self.player.y = 0 -- 595
	self.player.vy = 0 -- 596
	self.player.vx = 0 -- 597
	self.player.onGround = true -- 598
	self.player.crouch = false -- 599
	self.player.h = CHILD_H -- 600
	self.player.facing = 1 -- 601
	self.partner.alive = true -- 602
	self.cam.x = self.player.x -- 603
end -- 588
function Play.prototype.stepStory(self, dt, input) -- 607
	if self.room.key == "prologue" then -- 607
		self:stepPrologue(dt, input) -- 609
	elseif self.room.key == "street" then -- 609
		self:stepStreet(dt, input) -- 611
	elseif self.room.key == "gate" then -- 611
		self:stepGate(dt, input) -- 613
	elseif self.room.key == "tower" then -- 613
		self:stepTower(dt, input) -- 615
	end -- 615
end -- 607
function Play.prototype.stepPrologue(self, dt, input) -- 620
	local child = self.partner -- 621
	if self.phase == "prologue-wait" then -- 621
		child.crouch = true -- 623
		child.h = CHILD_CROUCH_H -- 624
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 625
		local near = math.abs(self.player.x - child.x) <= reach -- 627
		if near and input.interact.pressed then -- 627
			self.phase = "prologue-give" -- 629
			self.phaseTick = 0 -- 630
			self:flashSet("递出针套", 1) -- 631
		end -- 631
		return -- 633
	end -- 633
	if self.phase == "prologue-give" then -- 633
		self.phaseTick = self.phaseTick + 1 -- 636
		if self.phaseTick == 12 then -- 636
			self:flashSet("针套递过去", 0.7) -- 638
		elseif self.phaseTick == 36 then -- 638
			self:flashSet("纸条塞进针套", 0.9) -- 640
		elseif self.phaseTick >= 60 then -- 640
			self.phase = "prologue-follow" -- 642
			self.phaseTick = 0 -- 643
			child.crouch = false -- 644
			child.h = CHILD_H -- 645
			self:flashSet("她跟上了", 1.2) -- 646
		end -- 646
		return -- 648
	end -- 648
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 648
		self.wantRoom = "street" -- 652
		self:flashSet("进街道", 1.2) -- 653
	end -- 653
end -- 620
function Play.prototype.stepStreet(self, dt, input) -- 658
	local p = self.player -- 659
	local c = self.partner -- 660
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 660
		self.wantRoom = "checkpoint" -- 662
		self:flashSet("到检查站", 1.2) -- 663
	end -- 663
end -- 658
function Play.prototype.stepGate(self, dt, input) -- 668
	local ____temp_7 -- 669
	if self.room.story == nil then -- 669
		____temp_7 = nil -- 669
	else -- 669
		____temp_7 = self.room.story.gate -- 669
	end -- 669
	local g = ____temp_7 -- 669
	if g == nil then -- 669
		return -- 671
	end -- 671
	local p = self.player -- 673
	if self.phase == "gate-idle" then -- 673
		local a = self.partner -- 676
		local gap = g.waitX - a.x -- 677
		if math.abs(gap) > 3 then -- 677
			a.facing = gap > 0 and 1 or -1 -- 679
			a.vx = a.facing * CHILD_SPEED -- 680
			local beforeX = a.x -- 681
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 682
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 682
				a.vy = CHILD_JUMP -- 684
				a.onGround = false -- 685
			end -- 685
			self:fallY(a, dt) -- 687
		else -- 687
			a.vx = 0 -- 689
			a.x = g.waitX -- 690
		end -- 690
		local atWinch = math.abs(p.x - g.winchX) <= 60 and p.y < 20 -- 692
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 693
		if atWinch and atWait then -- 693
			self.phase = "gate-hold" -- 695
			self.gateTick = 0 -- 696
			self.gateSpawned = 0 -- 697
			self:flashSet("两人就位 · 守点开始", 1.4) -- 698
		end -- 698
		return -- 700
	end -- 700
	if self.phase == "gate-hold" then -- 700
		self.gateTick = self.gateTick + 1 -- 703
		local marks = {0, 540, 900, 1500} -- 705
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 705
			local idx = self.gateSpawned -- 707
			local ____self_enemies_8 = self.enemies -- 707
			____self_enemies_8[#____self_enemies_8 + 1] = { -- 708
				x = self.ox + 620 + idx * 62, -- 708
				y = 0, -- 708
				w = 26, -- 708
				h = 84, -- 708
				alive = true, -- 708
				hitT = 0 -- 708
			} -- 708
			self.gateSpawned = self.gateSpawned + 1 -- 709
			self:flashSet( -- 710
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 710
				0.9 -- 710
			) -- 710
		end -- 710
		if self.gateTick == 900 then -- 710
			self:flashSet("灯灭了", 1) -- 713
		elseif self.gateTick == 2100 then -- 713
			self:flashSet("门底压下来了", 1) -- 715
		end -- 715
		if self.gateTick >= g.holdTicks then -- 715
			self.phase = "gate-send" -- 718
			self.phaseTick = 0 -- 719
			self.enemies = {} -- 721
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 722
		end -- 722
		return -- 724
	end -- 724
	if self.phase == "gate-send" then -- 724
		local near = math.abs(p.x - g.doorX) <= 60 -- 727
		if near and input.interact.pressed then -- 727
			self:swapToChild(g.doorX + 30) -- 729
			self.phase = "gate-count" -- 730
			self.countTick = 0 -- 731
			self.countArmed = input.moveX == 0 -- 733
			self:flashSet("门开了 · 送她出去", 1.8) -- 734
		end -- 734
		return -- 736
	end -- 736
	if self.phase == "gate-count" then -- 736
		self.countTick = self.countTick + 1 -- 739
		if self.countTick == 360 then -- 739
			self:flashSet("门关上", 0.9) -- 741
		elseif self.countTick == 1020 then -- 741
			self:flashSet("数到一百", 2.2) -- 743
		end -- 743
		if self.countTick >= 1440 then -- 743
			if input.moveX == 0 then -- 743
				self.countArmed = true -- 747
			end -- 747
			if self.countArmed and input.moveX > 0 then -- 747
				self.phase = "gate-walk" -- 750
				self.phaseTick = 0 -- 751
				self:flashSet("她迈出第一步", 1.4) -- 752
			end -- 752
		end -- 752
		return -- 755
	end -- 755
	if self.player.x >= g.exitX then -- 755
		self.wantRoom = "outside" -- 759
		self:flashSet("出城门 · 城外", 1.4) -- 760
	end -- 760
end -- 668
function Play.prototype.stepTower(self, dt, input) -- 765
	local ____temp_9 -- 766
	if self.room.story == nil then -- 766
		____temp_9 = nil -- 766
	else -- 766
		____temp_9 = self.room.story.tower -- 766
	end -- 766
	local t = ____temp_9 -- 766
	if t == nil then -- 766
		return -- 768
	end -- 768
	if self.phase == "tower-wait" then -- 768
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 771
		if near and input.interact.pressed then -- 771
			self.phase = "tower-knock" -- 773
			self.phaseTick = 0 -- 774
			self.knocks = 1 -- 775
			self:flashSet("敲一下", 0.6) -- 776
		end -- 776
		return -- 778
	end -- 778
	if self.phase == "tower-knock" then -- 778
		self.phaseTick = self.phaseTick + 1 -- 781
		if self.phaseTick == 12 then -- 781
			self.knocks = 2 -- 783
			self:flashSet("敲两下 · 第二声", 1) -- 784
		elseif self.phaseTick >= t.knockTicks then -- 784
			self.phase = "tower-given" -- 786
			self.phaseTick = 0 -- 787
			self:flashSet("门开了 · 提灯", 1.4) -- 788
		end -- 788
		return -- 790
	end -- 790
	if self.phase == "tower-given" then -- 790
		self.phaseTick = self.phaseTick + 1 -- 793
		if self.phaseTick == 60 then -- 793
			self:flashSet("她递出针套和纸条", 1.6) -- 795
		elseif self.phaseTick == 120 then -- 795
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 797
		elseif self.phaseTick >= 180 then -- 797
			self.phase = "tower-end" -- 799
			self.phaseTick = 0 -- 800
			self:flashSet("片尾 · E 再玩一次", 3) -- 801
		end -- 801
		return -- 803
	end -- 803
	if input.interact.pressed or input.retry.pressed then -- 803
		self.wantRoom = "prologue" -- 806
		self:flashSet("回到序章", 1.4) -- 807
	end -- 807
end -- 765
function Play.prototype.stepChase(self, dt, input) -- 812
	if self.caughtT > 0 then -- 812
		self.caughtT = self.caughtT - dt -- 814
		if self.caughtT <= 0 then -- 814
			self:recoverFromCaught() -- 816
		end -- 816
		return -- 818
	end -- 818
	if self.room.key == "village" then -- 818
		self:stepScavChase() -- 821
	elseif self.room.key == "forest" then -- 821
		self:stepDog(dt) -- 823
		if self.player.x >= self.ox + 1450 then -- 823
			self.wantRoom = "tower" -- 826
			self:flashSet("林缘 · 北塔", 1.4) -- 827
		end -- 827
	end -- 827
end -- 812
function Play.prototype.stepScavChase(self) -- 833
	local s = self.room.scavenger -- 834
	if s == nil then -- 834
		return -- 836
	end -- 836
	local p = self.player -- 838
	local dx = p.x - self.scavX -- 839
	local dist = math.abs(dx) -- 840
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 841
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 842
	if not self.scavChase then -- 842
		if visible then -- 842
			self.scavSee = self.scavSee + 1 -- 845
			if self.scavSee >= 24 then -- 845
				self.scavChase = true -- 847
				self.scavState = "chase" -- 848
				self.scavTargetX = p.x -- 849
				self:flashSet("他看见你了", 1.2) -- 850
			end -- 850
		else -- 850
			self.scavSee = 0 -- 853
		end -- 853
		return -- 855
	end -- 855
	local dir = p.x > self.scavX and 1 or -1 -- 858
	self.scavX = self.scavX + dir * 96 / 60 -- 859
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 859
		self:caught() -- 861
		return -- 862
	end -- 862
	if hidden then -- 862
		self.scavSee = 0 -- 866
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 867
		self.scavT = self.scavT - 1 -- 868
		if self.scavT <= 0 then -- 868
			self.scavChase = false -- 870
			self.scavState = "patrol" -- 871
			self:flashSet("他失去了目标", 1) -- 872
		end -- 872
	end -- 872
end -- 833
function Play.prototype.stepDog(self, dt) -- 878
	local ____temp_10 -- 879
	if self.room.story == nil then -- 879
		____temp_10 = nil -- 879
	else -- 879
		____temp_10 = self.room.story.dog -- 879
	end -- 879
	local dog = ____temp_10 -- 879
	if dog == nil then -- 879
		return -- 881
	end -- 881
	local p = self.player -- 883
	local dist = math.abs(p.x - self.dogX) -- 884
	if self.dogState == "patrol" then -- 884
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 886
		if self.dogX < dog.x0 then -- 886
			self.dogX = dog.x0 -- 888
			self.dogDir = 1 -- 889
		elseif self.dogX > dog.x1 then -- 889
			self.dogX = dog.x1 -- 891
			self.dogDir = -1 -- 892
		end -- 892
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 894
		if not p.crouch and moving and dist < dog.range then -- 894
			self.dogState = "ear" -- 896
			self.dogT = 18 -- 897
			self.dogTargetX = p.x -- 898
			self:flashSet("狗转耳朵", 0.8) -- 899
		end -- 899
		return -- 901
	end -- 901
	if self.dogState == "ear" then -- 901
		self.dogT = self.dogT - 1 -- 904
		if self.dogT <= 0 then -- 904
			self.dogState = "chase" -- 906
			self.dogTargetX = p.x -- 907
			self:flashSet("狗追来了", 1.4) -- 908
		end -- 908
		return -- 910
	end -- 910
	if self.dogState == "chase" then -- 910
		local dir = p.x > self.dogX and 1 or -1 -- 913
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 914
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 914
			self:caught() -- 916
			self.dogState = "sniff" -- 917
			self.dogT = 60 -- 918
		elseif dist > dog.range * 1.5 or p.crouch then -- 918
			self.dogState = "sniff" -- 920
			self.dogT = 60 -- 921
			self:flashSet("狗停下了", 0.9) -- 922
		end -- 922
		return -- 924
	end -- 924
	if self.dogState == "sniff" then -- 924
		self.dogT = self.dogT - 1 -- 927
		if self.dogT <= 0 then -- 927
			self.dogState = "back" -- 929
		end -- 929
		return -- 931
	end -- 931
	local dir = dog.x0 > self.dogX and 1 or -1 -- 934
	self.dogX = self.dogX + dir * dog.speed * dt -- 935
	if math.abs(self.dogX - dog.x0) < 2 then -- 935
		self.dogX = dog.x0 -- 937
		self.dogState = "patrol" -- 938
	end -- 938
end -- 878
function Play.prototype.caught(self) -- 942
	self.caughtT = 1 -- 943
	self:flashSet("被抓 · 回到安全点", 1.6) -- 944
end -- 942
function Play.prototype.recoverFromCaught(self) -- 948
	local p = self.player -- 949
	p.x = self.ox + 140 -- 950
	p.y = 0 -- 951
	p.vy = 0 -- 952
	p.vx = 0 -- 953
	p.onGround = true -- 954
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 954
		self.scavX = self.room.scavenger.x0 -- 956
		self.scavState = "patrol" -- 957
		self.scavSee = 0 -- 958
		self.scavChase = false -- 959
		self.scavT = 0 -- 960
	end -- 960
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 960
		self.dogX = self.room.story.dog.x0 -- 963
		self.dogState = "patrol" -- 964
		self.dogT = 0 -- 965
	end -- 965
	self.cam.x = p.x -- 967
	self.cam.y = p.y + CAM_LOOK_UP -- 968
	self:flashSet("回到安全点", 1.2) -- 969
end -- 948
function Play.prototype.updateGate(self) -- 973
	if self.room.key ~= "checkpoint" then -- 973
		self.gateOpen = false -- 975
		return -- 976
	end -- 976
	local function inZone(x) -- 978
		return x >= self.ox + 792 and x <= self.ox + 928 -- 978
	end -- 978
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 979
end -- 973
function Play.prototype.stepEnemies(self, dt) -- 982
	local i = 0 -- 983
	do -- 983
		i = 0 -- 984
		while i < #self.enemies do -- 984
			local e = self.enemies[i + 1] -- 985
			if e.hitT > 0 then -- 985
				e.hitT = e.hitT - dt -- 987
			end -- 987
			i = i + 1 -- 984
		end -- 984
	end -- 984
end -- 982
function Play.prototype.stepInteract(self, dt, input) -- 992
	local p = self.player -- 993
	local calmUsed = self.calmConsumed -- 994
	self.calmConsumed = false -- 995
	self.focusCart = false -- 996
	if self.room.key == "outside" then -- 996
		local c = self.room.cart -- 998
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 999
		local dy = p.y - c.baseY -- 1000
		self.focusCart = dx * dx + dy * dy < CART_REACH * CART_REACH -- 1001
	end -- 1001
	self:stepCart(dt, input) -- 1003
	if calmUsed then -- 1003
		self:flashSet("安抚 · 敲两下", 0.8) -- 1007
	elseif input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" then -- 1007
		if self.knockT > 0 then -- 1007
			self.knocks = self.knocks + 1 -- 1011
		else -- 1011
			self.knocks = 1 -- 1013
		end -- 1013
		self.knockT = 1.2 -- 1015
		if self.knocks >= 2 then -- 1015
			self:flashSet("敲两下", 0.8) -- 1017
			self.knocks = 0 -- 1018
		else -- 1018
			self:flashSet("敲一下", 0.5) -- 1020
		end -- 1020
	elseif self.knockT > 0 then -- 1020
		self.knockT = self.knockT - dt -- 1023
		if self.knockT <= 0 then -- 1023
			self.knocks = 0 -- 1025
		end -- 1025
	end -- 1025
	local i = 0 -- 1030
	do -- 1030
		i = 0 -- 1031
		while i < #self.room.marks do -- 1031
			do -- 1031
				local m = self.room.marks[i + 1] -- 1032
				if m.kind ~= 0 then -- 1032
					goto __continue169 -- 1034
				end -- 1034
				local subjects = {self.partner, self.player} -- 1036
				local k = 0 -- 1037
				do -- 1037
					k = 0 -- 1038
					while k < #subjects do -- 1038
						do -- 1038
							local s = subjects[k + 1] -- 1039
							if not s.alive then -- 1039
								goto __continue172 -- 1041
							end -- 1041
							local dx = s.x - m.x -- 1043
							local dy = s.y - m.y -- 1044
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 1044
								self.checkpoint = m.x -- 1046
								self.checkpointCartAxle = self.cartAxle -- 1047
								if self.cartDocked then -- 1047
									self:flashSet("检查点 · 车已落窝", 1) -- 1049
								else -- 1049
									self:flashSet("检查点 · 车还没到位", 1) -- 1051
								end -- 1051
							end -- 1051
						end -- 1051
						::__continue172:: -- 1051
						k = k + 1 -- 1038
					end -- 1038
				end -- 1038
			end -- 1038
			::__continue169:: -- 1038
			i = i + 1 -- 1031
		end -- 1031
	end -- 1031
	self:checkCarryGate() -- 1057
end -- 992
function Play.prototype.stepVillage(self, dt, input) -- 1061
	if self.room.key ~= "village" then -- 1061
		return -- 1063
	end -- 1063
	local p = self.player -- 1065
	local bottle = self.room.bottle -- 1066
	local scav = self.room.scavenger -- 1067
	if not self.hasBottle and bottle ~= nil then -- 1067
		local dx = p.x - bottle.x -- 1071
		local dy = p.y + p.h * 0.5 - bottle.y -- 1072
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 1072
			self.hasBottle = true -- 1074
			self:flashSet("拾起瓶子", 0.8) -- 1075
		end -- 1075
	end -- 1075
	if self.hasBottle then -- 1075
		if input.aim.held then -- 1075
			self.aimHold = self.aimHold + dt -- 1082
			if self.aimHold > 1.2 then -- 1082
				self.aimHold = 1.2 -- 1084
			end -- 1084
		elseif input.aim.released then -- 1084
			local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1087
			self:throwBottle(aim.x, aim.y) -- 1088
			self.aimHold = 0 -- 1089
		end -- 1089
	else -- 1089
		self.aimHold = 0 -- 1092
	end -- 1092
	local fly = self.bottleFly -- 1096
	if fly ~= nil then -- 1096
		fly.vy = fly.vy - GRAVITY * dt -- 1098
		fly.x = fly.x + fly.vx * dt -- 1099
		fly.y = fly.y + fly.vy * dt -- 1100
		local g = self:groundAt(fly.x, fly.y + 4, 3) -- 1101
		if fly.y <= g then -- 1101
			self.bottleFly = nil -- 1103
			self.bottleLandX = fly.x -- 1104
			self.bottleLandT = 0.9 -- 1105
			self:hearBottle(fly.x) -- 1106
		end -- 1106
	end -- 1106
	if self.bottleLandT > 0 then -- 1106
		self.bottleLandT = self.bottleLandT - dt -- 1110
	end -- 1110
	if scav ~= nil then -- 1110
		self:stepScav(dt, scav) -- 1114
	end -- 1114
	local line = self.room.passLine -- 1117
	if line ~= nil and not self.passed and p.x >= line then -- 1117
		self.passed = true -- 1119
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 1120
	end -- 1120
	if self.passed and p.x >= self.ox + 640 then -- 1120
		self.wantRoom = "forest" -- 1124
		self:flashSet("出院 · 北塔森林", 1.4) -- 1125
	end -- 1125
end -- 1061
function Play.prototype.throwBottle(self, tx, ty) -- 1130
	local p = self.player -- 1131
	local x0 = p.x + p.facing * 10 -- 1132
	local y0 = p.y + p.h * 0.7 -- 1133
	local T = 0.62 -- 1134
	local vx = (tx - x0) / T -- 1135
	local vy = (ty - y0 + 0.5 * GRAVITY * T * T) / T -- 1136
	self.bottleFly = {x = x0, y = y0, vx = vx, vy = vy} -- 1137
	self.hasBottle = false -- 1138
	self:flashSet("投出", 0.4) -- 1139
end -- 1130
function Play.prototype.hearBottle(self, x) -- 1143
	local s = self.room.scavenger -- 1144
	if s == nil then -- 1144
		return -- 1146
	end -- 1146
	if math.abs(x - self.scavX) > s.range then -- 1146
		self:flashSet("落地 · 他没听见", 0.6) -- 1149
		return -- 1150
	end -- 1150
	self.scavState = "turn" -- 1152
	self.scavT = s.hearTicks -- 1153
	self.scavTargetX = x -- 1154
	self:flashSet("砖地一响 · 他转头", 0.9) -- 1155
end -- 1143
function Play.prototype.stepScav(self, dt, s) -- 1159
	if self.scavState == "turn" then -- 1159
		self.scavT = self.scavT - 1 -- 1161
		if self.scavT <= 0 then -- 1161
			self.scavState = "walk" -- 1163
		end -- 1163
		return -- 1165
	end -- 1165
	if self.scavState == "walk" then -- 1165
		local d = self.scavTargetX - self.scavX -- 1168
		if math.abs(d) < 4 then -- 1168
			self.scavState = "stall" -- 1170
			self.scavT = s.stallTicks -- 1171
			return -- 1172
		end -- 1172
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 1174
		return -- 1175
	end -- 1175
	if self.scavState == "stall" then -- 1175
		self.scavT = self.scavT - 1 -- 1178
		if self.scavT <= 0 then -- 1178
			self.scavState = "back" -- 1180
		end -- 1180
		return -- 1182
	end -- 1182
	if self.scavState == "back" then -- 1182
		local home = math.max( -- 1185
			s.x0, -- 1185
			math.min(s.x1, self.scavX) -- 1185
		) -- 1185
		if math.abs(home - self.scavX) < 2 then -- 1185
			self.scavState = "patrol" -- 1187
			return -- 1188
		end -- 1188
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 1190
		return -- 1191
	end -- 1191
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 1193
	if self.scavX >= s.x1 then -- 1193
		self.scavX = s.x1 -- 1195
		self.scavDir = -1 -- 1196
	elseif self.scavX <= s.x0 then -- 1196
		self.scavX = s.x0 -- 1198
		self.scavDir = 1 -- 1199
	end -- 1199
end -- 1159
function Play.prototype.stepCart(self, dt, input) -- 1207
	local p = self.player -- 1208
	local c = self.room.cart -- 1209
	local handleX = self.cartAxle + c.handleOffset -- 1210
	if self.gripping then -- 1210
		if not input.interact.held then -- 1210
			self.gripping = false -- 1214
			self:flashSet("松开车把", 0.4) -- 1215
			return -- 1216
		end -- 1216
	else -- 1216
		if not input.interact.pressed then -- 1216
			return -- 1220
		end -- 1220
		if math.abs(p.x - handleX) > CART_REACH or math.abs(p.y - c.baseY) > 40 then -- 1220
			return -- 1223
		end -- 1223
		self.gripping = true -- 1225
		self:flashSet("握住车把", 0.4) -- 1226
		return -- 1227
	end -- 1227
	if self.cartDocked then -- 1227
		return -- 1231
	end -- 1231
	local dir = input.moveX -- 1233
	if dir == 0 then -- 1233
		return -- 1235
	end -- 1235
	local lo = math.min(c.startX, c.endX) -- 1237
	local hi = math.max(c.startX, c.endX) -- 1238
	local next = self.cartAxle + dir * CART_SPEED * dt -- 1239
	if next < lo then -- 1239
		next = lo -- 1241
	end -- 1241
	if next > hi then -- 1241
		next = hi -- 1244
	end -- 1244
	local delta = next - self.cartAxle -- 1246
	if delta == 0 then -- 1246
		return -- 1248
	end -- 1248
	self.cartAxle = next -- 1250
	p.x = p.x + delta -- 1251
	p.facing = dir > 0 and 1 or -1 -- 1252
	self:slideX(p, 0) -- 1253
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > CART_REACH then -- 1253
		self.gripping = false -- 1255
		self:flashSet("跟不上了，脱手", 0.6) -- 1256
		return -- 1257
	end -- 1257
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 1257
		self.cartDocked = true -- 1260
		self.gripping = false -- 1261
		self:flashSet("车轮落窝", 1.2) -- 1262
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 1262
		self:flashSet("车轮回到起点", 0.5) -- 1264
	end -- 1264
end -- 1207
function Play.prototype.checkCarryGate(self) -- 1272
	if self.room.key == "checkpoint" then -- 1272
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 1272
			self.carryCartAxle = self.cartAxle -- 1275
			self.carryCartDocked = self.cartDocked -- 1276
			self.wantRoom = "gate" -- 1277
			self:flashSet("出检查站 · 城门", 1.2) -- 1278
		end -- 1278
		return -- 1280
	end -- 1280
	if self.room.key == "outside" then -- 1280
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 1280
			self.carryCartAxle = self.cartAxle -- 1286
			self.carryCartDocked = self.cartDocked -- 1287
			self.wantRoom = "village" -- 1288
			self:flashSet("墙根走完 · 进村口", 1.2) -- 1289
		end -- 1289
	end -- 1289
end -- 1272
function Play.prototype.shoot(self, a) -- 1295
	local ox = a.x + a.facing * 8 -- 1296
	local oy = a.y + a.h * 0.72 -- 1297
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1299
	local dx = aim.x - ox -- 1300
	local dy = aim.y - oy -- 1301
	local len = math.sqrt(dx * dx + dy * dy) -- 1302
	if len < 0.001 then -- 1302
		dx = a.facing -- 1304
		dy = 0 -- 1305
	else -- 1305
		dx = dx / len -- 1307
		dy = dy / len -- 1308
	end -- 1308
	if dx ~= 0 then -- 1308
		a.facing = dx > 0 and 1 or -1 -- 1311
	end -- 1311
	local hitEnemy = self:raycast( -- 1314
		ox, -- 1314
		oy, -- 1314
		dx, -- 1314
		dy, -- 1314
		true -- 1314
	) -- 1314
	local hitWall = self:raycast( -- 1315
		ox, -- 1315
		oy, -- 1315
		dx, -- 1315
		dy, -- 1315
		false -- 1315
	) -- 1315
	local tEnemy = hitEnemy.t -- 1316
	local tWall = hitWall.t -- 1317
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 1318
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 1319
	self.trace = { -- 1321
		x0 = ox, -- 1321
		y0 = oy, -- 1321
		x1 = ox + dx * t, -- 1321
		y1 = oy + dy * t, -- 1321
		hit = hit -- 1321
	} -- 1321
	self.traceT = 0.12 -- 1322
	self:applyFireDanger(ox) -- 1323
	if hit then -- 1323
		local i = hitEnemy.index -- 1325
		local e = self.enemies[i + 1] -- 1326
		e.alive = false -- 1327
		e.hitT = 0.4 -- 1328
		self:flashSet("命中", 0.6) -- 1329
	else -- 1329
		self:flashSet("打空", 0.35) -- 1331
	end -- 1331
end -- 1295
function Play.prototype.applyFireDanger(self, shotX) -- 1336
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 1336
		return -- 1338
	end -- 1338
	local dangerX = shotX -- 1340
	local best = -1 -- 1341
	local bestD = 1000000000 -- 1342
	local i = 0 -- 1343
	do -- 1343
		i = 0 -- 1344
		while i < #self.enemies do -- 1344
			do -- 1344
				local e = self.enemies[i + 1] -- 1345
				if not e.alive then -- 1345
					goto __continue235 -- 1347
				end -- 1347
				local d = math.abs(e.x - self.partner.x) -- 1349
				if d < bestD then -- 1349
					bestD = d -- 1351
					best = i -- 1352
				end -- 1352
			end -- 1352
			::__continue235:: -- 1352
			i = i + 1 -- 1344
		end -- 1344
	end -- 1344
	if best >= 0 then -- 1344
		dangerX = self.enemies[best + 1].x -- 1356
	end -- 1356
	local exposed = self:childExposed(dangerX) -- 1358
	local before = self.escort.fear -- 1359
	local after = self.escort:applyDanger(self.nextDangerId, exposed, self.partner.x) -- 1360
	self.nextDangerId = self.nextDangerId + 1 -- 1361
	if after > before then -- 1361
		self:flashSet( -- 1363
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 1363
			1 -- 1363
		) -- 1363
	elseif not exposed then -- 1363
		self:flashSet("枪声没够到她", 0.5) -- 1365
	end -- 1365
end -- 1336
function Play.prototype.childExposed(self, dangerX) -- 1370
	local c = self.partner -- 1371
	if not c.alive then -- 1371
		return false -- 1373
	end -- 1373
	if c.x > self.ox + 240 and c.x < self.ox + 340 then -- 1373
		return false -- 1376
	end -- 1376
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 1376
		return false -- 1379
	end -- 1379
	local toDanger = dangerX - c.x -- 1381
	local toPlayer = self.player.x - c.x -- 1382
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) then -- 1382
		return false -- 1384
	end -- 1384
	return true -- 1386
end -- 1370
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 1390
	local best = -1 -- 1391
	local bestI = -1 -- 1392
	local i = 0 -- 1393
	if enemies then -- 1393
		do -- 1393
			i = 0 -- 1395
			while i < #self.enemies do -- 1395
				do -- 1395
					local e = self.enemies[i + 1] -- 1396
					if not e.alive then -- 1396
						goto __continue249 -- 1398
					end -- 1398
					local t = hitBox( -- 1400
						ox, -- 1400
						oy, -- 1400
						dx, -- 1400
						dy, -- 1400
						e.x - e.w / 2, -- 1400
						e.x + e.w / 2, -- 1400
						e.y, -- 1400
						e.y + e.h -- 1400
					) -- 1400
					if t >= 0 and (best < 0 or t < best) then -- 1400
						best = t -- 1402
						bestI = i -- 1403
					end -- 1403
				end -- 1403
				::__continue249:: -- 1403
				i = i + 1 -- 1395
			end -- 1395
		end -- 1395
		return {t = best, index = bestI} -- 1406
	end -- 1406
	do -- 1406
		i = 0 -- 1408
		while i < #self.boxes do -- 1408
			local b = self.boxes[i + 1] -- 1409
			local t = hitBox( -- 1410
				ox, -- 1410
				oy, -- 1410
				dx, -- 1410
				dy, -- 1410
				b.x0, -- 1410
				b.x1, -- 1410
				b.y0, -- 1410
				b.y1 -- 1410
			) -- 1410
			if t >= 0 and (best < 0 or t < best) then -- 1410
				best = t -- 1412
			end -- 1412
			i = i + 1 -- 1408
		end -- 1408
	end -- 1408
	if dy < 0 then -- 1408
		local t = (0 - oy) / dy -- 1417
		if t >= 0 and (best < 0 or t < best) then -- 1417
			best = t -- 1419
		end -- 1419
	end -- 1419
	return {t = best, index = -1} -- 1422
end -- 1390
function Play.prototype.slideX(self, a, dx) -- 1426
	local nx = a.x + dx -- 1427
	local half = a.w / 2 -- 1428
	local room = self.room -- 1429
	nx = math.max( -- 1430
		room.minX + half, -- 1430
		math.min(room.maxX - half, nx) -- 1430
	) -- 1430
	local i = 0 -- 1431
	do -- 1431
		i = 0 -- 1432
		while i < #self.boxes do -- 1432
			do -- 1432
				local b = self.boxes[i + 1] -- 1433
				if b.passable == true then -- 1433
					goto __continue259 -- 1435
				end -- 1435
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1435
					goto __continue259 -- 1438
				end -- 1438
				if nx + half > b.x0 and nx - half < b.x1 then -- 1438
					if a.x <= b.x0 then -- 1438
						nx = b.x0 - half -- 1442
					elseif a.x >= b.x1 then -- 1442
						nx = b.x1 + half -- 1444
					else -- 1444
						nx = a.x -- 1446
					end -- 1446
				end -- 1446
			end -- 1446
			::__continue259:: -- 1446
			i = i + 1 -- 1432
		end -- 1432
	end -- 1432
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 1432
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 1454
		local bx0 = self.cartAxle - CART_HALF -- 1455
		local bx1 = self.cartAxle + CART_HALF -- 1456
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 1456
			if a.x <= bx0 then -- 1456
				nx = bx0 - half -- 1459
			elseif a.x >= bx1 then -- 1459
				nx = bx1 + half -- 1461
			else -- 1461
				nx = a.x -- 1463
			end -- 1463
		end -- 1463
	end -- 1463
	local arch = room.arch -- 1471
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 1471
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 1473
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 1473
			if a.x <= arch.x0 then -- 1473
				nx = arch.x0 - half -- 1476
			elseif a.x >= arch.x1 then -- 1476
				nx = arch.x1 + half -- 1478
			end -- 1478
		end -- 1478
	end -- 1478
	a.x = nx -- 1482
end -- 1426
function Play.prototype.fallY(self, a, dt) -- 1486
	a.vy = a.vy - GRAVITY * dt -- 1487
	if a.vy < -900 then -- 1487
		a.vy = -900 -- 1489
	end -- 1489
	local ny = a.y + a.vy * dt -- 1491
	local half = a.w / 2 -- 1492
	if a.vy <= 0 then -- 1492
		local reach = a.onGround and STEP_UP or 0 -- 1495
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half) -- 1496
		if ny <= ground then -- 1496
			ny = ground -- 1498
			a.vy = 0 -- 1499
			a.onGround = true -- 1500
		else -- 1500
			a.onGround = false -- 1502
		end -- 1502
	else -- 1502
		a.onGround = false -- 1505
		local i = 0 -- 1506
		do -- 1506
			i = 0 -- 1507
			while i < #self.boxes do -- 1507
				do -- 1507
					local b = self.boxes[i + 1] -- 1508
					if b.passable == true then -- 1508
						goto __continue282 -- 1510
					end -- 1510
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 1510
						goto __continue282 -- 1513
					end -- 1513
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 1513
						ny = b.y0 - a.h -- 1516
						a.vy = 0 -- 1517
					end -- 1517
				end -- 1517
				::__continue282:: -- 1517
				i = i + 1 -- 1507
			end -- 1507
		end -- 1507
	end -- 1507
	a.y = ny -- 1521
end -- 1486
function Play.prototype.groundAt(self, x, ceiling, half) -- 1525
	local g = -9999 -- 1526
	local i = 0 -- 1527
	do -- 1527
		i = 0 -- 1528
		while i < #self.floors do -- 1528
			local f = self.floors[i + 1] -- 1529
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 1529
				g = f.y1 -- 1531
			end -- 1531
			i = i + 1 -- 1528
		end -- 1528
	end -- 1528
	do -- 1528
		i = 0 -- 1534
		while i < #self.boxes do -- 1534
			local b = self.boxes[i + 1] -- 1535
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 1535
				g = b.y1 -- 1537
			end -- 1537
			i = i + 1 -- 1534
		end -- 1534
	end -- 1534
	return g -- 1540
end -- 1525
function Play.prototype.updateCamera(self, dt) -- 1543
	local p = self.player -- 1544
	local tx = p.x + p.facing * 30 -- 1545
	local ty = p.y + CAM_LOOK_UP -- 1546
	local k = math.min(1, CAM_FOLLOW * dt) -- 1547
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 1548
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 1549
end -- 1543
function Play.prototype.clampCamera(self, w, h) -- 1553
	local room = self.room -- 1554
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 1555
	local spanX = room.maxX - room.minX -- 1556
	if spanX <= halfW * 2 then -- 1556
		self.cam.x = (room.minX + room.maxX) / 2 -- 1558
	else -- 1558
		self.cam.x = math.max( -- 1560
			room.minX + halfW, -- 1560
			math.min(room.maxX - halfW, self.cam.x) -- 1560
		) -- 1560
	end -- 1560
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 1563
	local spanY = room.height -- 1564
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 1565
	if spanY <= halfH * 2 then -- 1565
		self.cam.y = camY -- 1567
	else -- 1567
		self.cam.y = math.max( -- 1569
			camY, -- 1569
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 1569
		) -- 1569
	end -- 1569
end -- 1553
function Play.prototype.flashSet(self, text, t) -- 1573
	self.flash = text -- 1574
	self.flashT = t -- 1575
end -- 1573
function Play.prototype.statusText(self) -- 1579
	local p = self.player -- 1580
	local parts = {} -- 1581
	local who = self.childMode and "小满" or "周戍" -- 1582
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 1583
	if self.room.key == "prologue" then -- 1583
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1586
		if self.phase == "prologue-wait" then -- 1586
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 1588
		elseif self.phase == "prologue-give" then -- 1588
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 1590
		else -- 1590
			parts[#parts + 1] = "跟随" -- 1592
		end -- 1592
		if self.paused then -- 1592
			parts[#parts + 1] = "已暂停" -- 1595
		end -- 1595
		return table.concat(parts, " · ") -- 1597
	end -- 1597
	if self.room.key == "street" then -- 1597
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1600
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1601
		if self.paused then -- 1601
			parts[#parts + 1] = "已暂停" -- 1603
		end -- 1603
		return table.concat(parts, " · ") -- 1605
	end -- 1605
	if self.room.key == "gate" then -- 1605
		local ____temp_11 -- 1608
		if self.room.story == nil then -- 1608
			____temp_11 = nil -- 1608
		else -- 1608
			____temp_11 = self.room.story.gate -- 1608
		end -- 1608
		local g = ____temp_11 -- 1608
		if g ~= nil then -- 1608
			parts[#parts + 1] = self:gateLabel() -- 1610
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 1611
				0, -- 1612
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 1612
			))) .. " 秒" -- 1612
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1613
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1614
		end -- 1614
		if self.paused then -- 1614
			parts[#parts + 1] = "已暂停" -- 1617
		end -- 1617
		return table.concat(parts, " · ") -- 1619
	end -- 1619
	if self.room.key == "forest" then -- 1619
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1622
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 1623
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 1624
		if self.caughtT > 0 then -- 1624
			parts[#parts + 1] = "复位中" -- 1626
		end -- 1626
		if self.paused then -- 1626
			parts[#parts + 1] = "已暂停" -- 1629
		end -- 1629
		return table.concat(parts, " · ") -- 1631
	end -- 1631
	if self.room.key == "tower" then -- 1631
		if self.phase == "tower-wait" then -- 1631
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 1635
		elseif self.phase == "tower-knock" then -- 1635
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 1637
		elseif self.phase == "tower-given" then -- 1637
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 1639
		else -- 1639
			parts[#parts + 1] = "片尾" -- 1641
		end -- 1641
		if self.paused then -- 1641
			parts[#parts + 1] = "已暂停" -- 1644
		end -- 1644
		return table.concat(parts, " · ") -- 1646
	end -- 1646
	if self.room.key == "village" then -- 1646
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1649
		if self.hasBottle then -- 1649
			parts[#parts + 1] = "有瓶" -- 1651
		elseif self.bottleFly ~= nil then -- 1651
			parts[#parts + 1] = "瓶在飞" -- 1653
		else -- 1653
			parts[#parts + 1] = "空手" -- 1655
		end -- 1655
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 1657
		if self.scavChase then -- 1657
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 1659
		end -- 1659
		if self.passed then -- 1659
			parts[#parts + 1] = "已过通行线" -- 1662
		end -- 1662
		if self.paused then -- 1662
			parts[#parts + 1] = "已暂停" -- 1665
		end -- 1665
		return table.concat(parts, " · ") -- 1667
	end -- 1667
	local isChild = self.childMode -- 1670
	if isChild then -- 1670
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 1672
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 1673
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1674
	else -- 1674
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 1676
		if p.rollT > 0 then -- 1676
			parts[#parts + 1] = "翻滚中" -- 1678
		end -- 1678
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1680
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 1681
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 1682
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 1683
	end -- 1683
	if self.checkpoint >= 0 then -- 1683
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 1686
	end -- 1686
	if self.paused then -- 1686
		parts[#parts + 1] = "已暂停" -- 1689
	end -- 1689
	return table.concat(parts, " · ") -- 1691
end -- 1579
function Play.prototype.aliveEnemies(self) -- 1695
	local n = 0 -- 1696
	local i = 0 -- 1697
	do -- 1697
		i = 0 -- 1698
		while i < #self.enemies do -- 1698
			if self.enemies[i + 1].alive then -- 1698
				n = n + 1 -- 1700
			end -- 1700
			i = i + 1 -- 1698
		end -- 1698
	end -- 1698
	return n -- 1703
end -- 1695
function Play.prototype.gateLabel(self) -- 1707
	if self.phase == "gate-idle" then -- 1707
		return "待就位" -- 1709
	end -- 1709
	if self.phase == "gate-hold" then -- 1709
		return "守点中" -- 1712
	end -- 1712
	if self.phase == "gate-send" then -- 1712
		return "送别" -- 1715
	end -- 1715
	if self.phase == "gate-count" then -- 1715
		return "数数 " .. tostring(self.countTick) -- 1718
	end -- 1718
	return "她走" -- 1720
end -- 1707
function Play.prototype.dogLabel(self) -- 1724
	if self.dogState == "ear" then -- 1724
		return "转耳" -- 1726
	end -- 1726
	if self.dogState == "chase" then -- 1726
		return "追" -- 1729
	end -- 1729
	if self.dogState == "sniff" then -- 1729
		return "停" -- 1732
	end -- 1732
	if self.dogState == "back" then -- 1732
		return "回线" -- 1735
	end -- 1735
	return "巡逻" -- 1737
end -- 1724
function Play.prototype.doorXOf(self) -- 1740
	local ____temp_12 -- 1741
	if self.room.story == nil then -- 1741
		____temp_12 = nil -- 1741
	else -- 1741
		____temp_12 = self.room.story.tower -- 1741
	end -- 1741
	local t = ____temp_12 -- 1741
	return t == nil and 0 or t.doorX -- 1742
end -- 1740
function Play.prototype.scavLabel(self) -- 1746
	if self.scavState == "chase" then -- 1746
		return "追" -- 1748
	end -- 1748
	if self.scavState == "turn" then -- 1748
		return "转头" -- 1751
	end -- 1751
	if self.scavState == "walk" then -- 1751
		return "赶来" -- 1754
	end -- 1754
	if self.scavState == "stall" then -- 1754
		return "停住" -- 1757
	end -- 1757
	if self.scavState == "back" then -- 1757
		return "回位" -- 1760
	end -- 1760
	return "巡逻" -- 1762
end -- 1746
function Play.prototype.hintText(self) -- 1766
	if self.paused then -- 1766
		return "Esc 继续 · R 重置" -- 1768
	end -- 1768
	if self.flash ~= "" then -- 1768
		return self.flash -- 1771
	end -- 1771
	if self.room.key == "prologue" then -- 1771
		if self.phase == "prologue-wait" then -- 1771
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 1775
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 1776
		end -- 1776
		if self.phase == "prologue-give" then -- 1776
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 1779
		end -- 1779
		return "她跟着你了 · 两人一起走到门口 680" -- 1781
	end -- 1781
	if self.room.key == "street" then -- 1781
		if self:aliveEnemies() > 0 then -- 1781
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 1785
		end -- 1785
		return "清完了 · 两人一起走到右边检查站入口 900" -- 1787
	end -- 1787
	if self.room.key == "gate" then -- 1787
		local ____temp_13 -- 1790
		if self.room.story == nil then -- 1790
			____temp_13 = nil -- 1790
		else -- 1790
			____temp_13 = self.room.story.gate -- 1790
		end -- 1790
		local g = ____temp_13 -- 1790
		if g ~= nil then -- 1790
			if self.phase == "gate-idle" then -- 1790
				return "小满到门洞 960、周戍回绞盘 195，两人就位才开始守点" -- 1793
			end -- 1793
			if self.phase == "gate-hold" then -- 1793
				return "守 45 秒 · 左键点射 · 守满走到门边 860 按 E 送她" -- 1796
			end -- 1796
			if self.phase == "gate-send" then -- 1796
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 1799
			end -- 1799
			if self.phase == "gate-count" then -- 1799
				if self.countTick >= 1440 then -- 1799
					return self.countArmed and "新按 D · 让她迈出第一步" or "先松开方向键，再按 D" -- 1803
				end -- 1803
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 1805
			end -- 1805
			return "她自己走 · 跟着出城门 1120" -- 1807
		end -- 1807
	end -- 1807
	if self.room.key == "forest" then -- 1807
		if self.dogState == "chase" then -- 1807
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 1812
		end -- 1812
		if self.dogState == "ear" then -- 1812
			return "狗转耳朵了 · 停下或蹲下别出声" -- 1815
		end -- 1815
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 1817
	end -- 1817
	if self.room.key == "tower" then -- 1817
		if self.phase == "tower-wait" then -- 1817
			return "走到门前 445 点一次 E 敲两下" -- 1821
		end -- 1821
		if self.phase == "tower-knock" then -- 1821
			return "敲两下 · 等门开" -- 1824
		end -- 1824
		if self.phase == "tower-given" then -- 1824
			return "递交针套和纸条 · 看登记簿最后一行" -- 1827
		end -- 1827
		return "片尾 · 点 E 再玩一次，回到序章" -- 1829
	end -- 1829
	if self.room.key == "village" then -- 1829
		if self.bottleFly ~= nil then -- 1829
			return "等瓶子落地 · 触地才发声" -- 1833
		end -- 1833
		if self.hasBottle then -- 1833
			return "按住 F 瞄，松手投 · 往右投到砖地 608，他才会走开" -- 1836
		end -- 1836
		if self.passed then -- 1836
			return "已过第一院 · R 重置可再来一遍" -- 1839
		end -- 1839
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 1841
	end -- 1841
	if self.room.key == "outside" then -- 1841
		if self.focusCart then -- 1841
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 1845
		end -- 1845
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 1847
	end -- 1847
	if self.escort.state == "frozen" then -- 1847
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 1847
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 1851
		end -- 1851
		return "小满吓住了 · 走过去，靠近再点 E" -- 1853
	end -- 1853
	if self.escort.state == "calming" then -- 1853
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 1856
	end -- 1856
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 1858
end -- 1766
function Play.prototype.draw(self, draw, w, h) -- 1863
	self.viewW = w -- 1864
	self.viewH = h -- 1865
	self.view = ____exports.computeViewport(w, h) -- 1866
	self:clampCamera(w, h) -- 1867
	draw:clear() -- 1868
	draw:drawRect( -- 1870
		Rect(0, 0, w, h), -- 1870
		BG_VOID -- 1870
	) -- 1870
	local box = self:canvasRect(w, h) -- 1871
	draw:drawRect(box, BG_FAR) -- 1872
	draw:drawRect( -- 1873
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 1873
		BG_MID -- 1873
	) -- 1873
	self:drawFloors(draw, w, h) -- 1875
	self:drawSolids(draw, w, h) -- 1876
	self:drawZones(draw, w, h) -- 1877
	self:drawArch(draw, w, h) -- 1878
	self:drawCart(draw, w, h) -- 1879
	self:drawActors(draw, w, h) -- 1880
	self:drawTrace(draw, w, h) -- 1881
	self:drawAim(draw, w, h) -- 1882
end -- 1863
function Play.prototype.canvasRect(self, w, h) -- 1886
	local v = self.view -- 1887
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 1888
end -- 1886
function Play.prototype.px(self, n) -- 1892
	return n * self.view.zoom -- 1893
end -- 1892
function Play.prototype.sx(self, wx, w) -- 1897
	local v = self.view -- 1898
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 1899
	return v.ox + lx * v.zoom -- 1900
end -- 1897
function Play.prototype.sy(self, wy, h) -- 1904
	local v = self.view -- 1905
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 1906
	return v.oy + ly * v.zoom -- 1907
end -- 1904
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 1910
	local px0 = self:sx(x0, w) -- 1911
	local px1 = self:sx(x1, w) -- 1912
	local py0 = self:sy(y0, h) -- 1913
	local py1 = self:sy(y1, h) -- 1914
	if px1 <= px0 or py1 <= py0 then -- 1914
		return -- 1916
	end -- 1916
	draw:drawRect( -- 1918
		Rect(px0, py0, px1 - px0, py1 - py0), -- 1918
		color -- 1918
	) -- 1918
end -- 1910
function Play.prototype.drawFloors(self, draw, w, h) -- 1921
	local i = 0 -- 1922
	do -- 1922
		i = 0 -- 1923
		while i < #self.room.floors do -- 1923
			local f = self.room.floors[i + 1] -- 1924
			local y = self:sy(f.y, h) -- 1925
			local x0 = self:sx(f.x0, w) -- 1926
			local x1 = self:sx(f.x1, w) -- 1927
			local deck = self:px(5) -- 1928
			draw:drawRect( -- 1929
				Rect(x0, y - deck, x1 - x0, deck), -- 1929
				FLOOR_DECK -- 1929
			) -- 1929
			draw:drawSegment( -- 1930
				Vec2(x0, y), -- 1930
				Vec2(x1, y), -- 1930
				self:px(1), -- 1930
				GROUND -- 1930
			) -- 1930
			i = i + 1 -- 1923
		end -- 1923
	end -- 1923
end -- 1921
function Play.prototype.drawSolids(self, draw, w, h) -- 1934
	local i = 0 -- 1935
	do -- 1935
		i = 0 -- 1936
		while i < #self.boxes do -- 1936
			do -- 1936
				local b = self.boxes[i + 1] -- 1937
				if b.y0 < -4 and b.y1 <= 96 then -- 1937
					draw:drawSegment( -- 1940
						Vec2( -- 1940
							self:sx(b.x0, w), -- 1940
							self:sy(b.y1, h) -- 1940
						), -- 1940
						Vec2( -- 1940
							self:sx(b.x1, w), -- 1940
							self:sy(b.y1, h) -- 1940
						), -- 1940
						self:px(1), -- 1940
						GROUND -- 1940
					) -- 1940
					goto __continue396 -- 1941
				end -- 1941
				self:drawBox( -- 1943
					draw, -- 1943
					w, -- 1943
					h, -- 1943
					b.x0, -- 1943
					b.x1, -- 1943
					b.y0, -- 1943
					b.y1, -- 1943
					SOLID_FILL -- 1943
				) -- 1943
				draw:drawSegment( -- 1944
					Vec2( -- 1944
						self:sx(b.x0, w), -- 1944
						self:sy(b.y1, h) -- 1944
					), -- 1944
					Vec2( -- 1944
						self:sx(b.x1, w), -- 1944
						self:sy(b.y1, h) -- 1944
					), -- 1944
					self:px(1), -- 1944
					SOLID_EDGE -- 1944
				) -- 1944
			end -- 1944
			::__continue396:: -- 1944
			i = i + 1 -- 1936
		end -- 1936
	end -- 1936
end -- 1934
function Play.prototype.drawZones(self, draw, w, h) -- 1948
	local i = 0 -- 1949
	do -- 1949
		i = 0 -- 1950
		while i < #self.room.zones do -- 1950
			local z = self.room.zones[i + 1] -- 1951
			local fill = DANGER -- 1952
			local line = DANGER_LINE -- 1953
			if z.tint == 2 then -- 1953
				fill = SOFT -- 1955
				line = SOFT_LINE -- 1956
			elseif z.tint == 3 then -- 1956
				fill = BRICK -- 1958
				line = BRICK_LINE -- 1959
			elseif z.tint == 4 then -- 1959
				fill = PASS -- 1961
				line = PASS_LINE -- 1962
			end -- 1962
			self:drawBox( -- 1964
				draw, -- 1964
				w, -- 1964
				h, -- 1964
				z.x0, -- 1964
				z.x1, -- 1964
				z.y, -- 1964
				z.y + z.h, -- 1964
				fill -- 1964
			) -- 1964
			draw:drawSegment( -- 1965
				Vec2( -- 1965
					self:sx(z.x0, w), -- 1965
					self:sy(z.y, h) -- 1965
				), -- 1965
				Vec2( -- 1965
					self:sx(z.x0, w), -- 1965
					self:sy(z.y + z.h, h) -- 1965
				), -- 1965
				self:px(1), -- 1965
				line -- 1965
			) -- 1965
			draw:drawSegment( -- 1966
				Vec2( -- 1966
					self:sx(z.x1, w), -- 1966
					self:sy(z.y, h) -- 1966
				), -- 1966
				Vec2( -- 1966
					self:sx(z.x1, w), -- 1966
					self:sy(z.y + z.h, h) -- 1966
				), -- 1966
				self:px(1), -- 1966
				line -- 1966
			) -- 1966
			i = i + 1 -- 1950
		end -- 1950
	end -- 1950
end -- 1948
function Play.prototype.drawArch(self, draw, w, h) -- 1970
	local a = self.room.arch -- 1971
	if a.h <= 0 then -- 1971
		return -- 1973
	end -- 1973
	self:drawBox( -- 1975
		draw, -- 1975
		w, -- 1975
		h, -- 1975
		a.x0, -- 1975
		a.x1, -- 1975
		a.y, -- 1975
		a.y + a.h, -- 1975
		HOLE_FILL -- 1975
	) -- 1975
	draw:drawSegment( -- 1976
		Vec2( -- 1976
			self:sx(a.x0, w), -- 1976
			self:sy(a.y + a.h, h) -- 1976
		), -- 1976
		Vec2( -- 1976
			self:sx(a.x1, w), -- 1976
			self:sy(a.y + a.h, h) -- 1976
		), -- 1976
		self:px(1), -- 1976
		SOLID_EDGE -- 1976
	) -- 1976
	draw:drawSegment( -- 1977
		Vec2( -- 1977
			self:sx(a.x0, w), -- 1977
			self:sy(a.y, h) -- 1977
		), -- 1977
		Vec2( -- 1977
			self:sx(a.x0, w), -- 1977
			self:sy(a.y + a.h, h) -- 1977
		), -- 1977
		self:px(1), -- 1977
		SOLID_EDGE -- 1977
	) -- 1977
	draw:drawSegment( -- 1978
		Vec2( -- 1978
			self:sx(a.x1, w), -- 1978
			self:sy(a.y, h) -- 1978
		), -- 1978
		Vec2( -- 1978
			self:sx(a.x1, w), -- 1978
			self:sy(a.y + a.h, h) -- 1978
		), -- 1978
		self:px(1), -- 1978
		SOLID_EDGE -- 1978
	) -- 1978
end -- 1970
function Play.prototype.drawCart(self, draw, w, h) -- 1981
	local c = self.room.cart -- 1982
	if c.bodyW <= 0 then -- 1982
		return -- 1984
	end -- 1984
	drawCartShape( -- 1986
		draw, -- 1986
		self, -- 1986
		w, -- 1986
		h, -- 1986
		c, -- 1986
		self.cartAxle -- 1986
	) -- 1986
	draw:drawRect( -- 1987
		Rect( -- 1987
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 1987
			self:sy(c.baseY + 40, h), -- 1987
			self:px(2), -- 1987
			self:px(40) -- 1987
		), -- 1987
		STAND -- 1987
	) -- 1987
end -- 1981
function Play.prototype.drawActors(self, draw, w, h) -- 1990
	local p = self.player -- 1991
	local isChild = self.childMode -- 1992
	drawFigure( -- 1993
		draw, -- 1993
		self, -- 1993
		w, -- 1993
		h, -- 1993
		p, -- 1993
		isChild and CHILD_BODY or SOLDIER_BODY, -- 1993
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 1993
	) -- 1993
	local q = self.partner -- 1994
	if q.alive then -- 1994
		local childPartner = q.w == CHILD_W -- 1996
		drawFigure( -- 1997
			draw, -- 1997
			self, -- 1997
			w, -- 1997
			h, -- 1997
			q, -- 1997
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 1997
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 1997
		) -- 1997
	end -- 1997
	local i = 0 -- 1999
	do -- 1999
		i = 0 -- 2000
		while i < #self.enemies do -- 2000
			local e = self.enemies[i + 1] -- 2001
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 2002
			self:drawBox( -- 2003
				draw, -- 2003
				w, -- 2003
				h, -- 2003
				e.x - e.w / 2, -- 2003
				e.x + e.w / 2, -- 2003
				e.y, -- 2003
				e.y + e.h, -- 2003
				col -- 2003
			) -- 2003
			i = i + 1 -- 2000
		end -- 2000
	end -- 2000
	local k = 0 -- 2006
	do -- 2006
		k = 0 -- 2007
		while k < #self.room.marks do -- 2007
			do -- 2007
				local m = self.room.marks[k + 1] -- 2008
				if m.kind ~= 0 then -- 2008
					goto __continue413 -- 2010
				end -- 2010
				local on = self.checkpoint == m.x -- 2012
				local x = self:sx(m.x, w) -- 2013
				local y = self:sy(m.y, h) -- 2014
				draw:drawSegment( -- 2015
					Vec2(x, y), -- 2015
					Vec2( -- 2015
						x, -- 2015
						y + self:px(35) -- 2015
					), -- 2015
					self:px(1), -- 2015
					on and CHECK or INK_DIM -- 2015
				) -- 2015
				draw:drawDot( -- 2016
					Vec2( -- 2016
						x, -- 2016
						y + self:px(35) -- 2016
					), -- 2016
					self:px(2), -- 2016
					on and CHECK or INK_DIM -- 2016
				) -- 2016
			end -- 2016
			::__continue413:: -- 2016
			k = k + 1 -- 2007
		end -- 2007
	end -- 2007
	local j = 0 -- 2020
	do -- 2020
		j = 0 -- 2021
		while j < #self.room.marks do -- 2021
			do -- 2021
				local m = self.room.marks[j + 1] -- 2022
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 2022
					goto __continue416 -- 2024
				end -- 2024
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 2024
					goto __continue416 -- 2028
				end -- 2028
				local col = STAND -- 2030
				if m.kind == 4 then -- 2030
					col = PASS_LINE -- 2032
				elseif m.kind == 5 then -- 2032
					col = BRICK_LINE -- 2034
				end -- 2034
				local mx = self:sx(m.x, w) -- 2036
				local my = self:sy(m.y, h) -- 2037
				draw:drawSegment( -- 2038
					Vec2(mx, my), -- 2038
					Vec2( -- 2038
						mx, -- 2038
						my + self:px(24) -- 2038
					), -- 2038
					self:px(1), -- 2038
					col -- 2038
				) -- 2038
			end -- 2038
			::__continue416:: -- 2038
			j = j + 1 -- 2021
		end -- 2021
	end -- 2021
	local t = 0 -- 2041
	do -- 2041
		t = 0 -- 2042
		while t < #self.room.marks do -- 2042
			do -- 2042
				local m = self.room.marks[t + 1] -- 2043
				if m.kind ~= 6 then -- 2043
					goto __continue422 -- 2045
				end -- 2045
				local mx = self:sx(m.x, w) -- 2047
				local my = self:sy(m.y, h) -- 2048
				draw:drawSegment( -- 2049
					Vec2(mx, my), -- 2049
					Vec2( -- 2049
						mx, -- 2049
						my + self:px(30) -- 2049
					), -- 2049
					self:px(1), -- 2049
					INK_DIM -- 2049
				) -- 2049
				self:drawBox( -- 2050
					draw, -- 2050
					w, -- 2050
					h, -- 2050
					m.x - 5, -- 2050
					m.x + 5, -- 2050
					m.y + 30, -- 2050
					m.y + 40, -- 2050
					CHECK -- 2050
				) -- 2050
			end -- 2050
			::__continue422:: -- 2050
			t = t + 1 -- 2042
		end -- 2042
	end -- 2042
	if self.room.key == "village" then -- 2042
		self:drawVillage(draw, w, h) -- 2053
	end -- 2053
	if self.room.key == "forest" then -- 2053
		self:drawDog(draw, w, h) -- 2056
	end -- 2056
end -- 1990
function Play.prototype.drawDog(self, draw, w, h) -- 2061
	local x = self.dogX -- 2062
	self:drawBox( -- 2063
		draw, -- 2063
		w, -- 2063
		h, -- 2063
		x - 14, -- 2063
		x + 14, -- 2063
		0, -- 2063
		20, -- 2063
		SCAV_BODY -- 2063
	) -- 2063
	self:drawBox( -- 2064
		draw, -- 2064
		w, -- 2064
		h, -- 2064
		x - 10, -- 2064
		x - 2, -- 2064
		20, -- 2064
		30, -- 2064
		SCAV_BODY -- 2064
	) -- 2064
	self:drawBox( -- 2065
		draw, -- 2065
		w, -- 2065
		h, -- 2065
		x + 2, -- 2065
		x + 10, -- 2065
		20, -- 2065
		30, -- 2065
		SCAV_HEAD -- 2065
	) -- 2065
	if self.dogState == "ear" or self.dogState == "chase" then -- 2065
		draw:drawSegment( -- 2067
			Vec2( -- 2067
				self:sx(x, w), -- 2067
				self:sy(30, h) -- 2067
			), -- 2067
			Vec2( -- 2068
				self:sx(x, w), -- 2068
				self:sy(40, h) -- 2068
			), -- 2068
			self:px(1), -- 2068
			DANGER -- 2068
		) -- 2068
	end -- 2068
end -- 2061
function Play.prototype.drawVillage(self, draw, w, h) -- 2073
	local bottle = self.room.bottle -- 2074
	if bottle ~= nil then -- 2074
		self:drawBox( -- 2076
			draw, -- 2076
			w, -- 2076
			h, -- 2076
			bottle.x - 14, -- 2076
			bottle.x + 14, -- 2076
			0, -- 2076
			64, -- 2076
			SOLID_FILL -- 2076
		) -- 2076
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 2076
			self:drawBottle( -- 2078
				draw, -- 2078
				w, -- 2078
				h, -- 2078
				bottle.x, -- 2078
				64 -- 2078
			) -- 2078
		end -- 2078
	end -- 2078
	self:drawBox( -- 2082
		draw, -- 2082
		w, -- 2082
		h, -- 2082
		300, -- 2082
		420, -- 2082
		44, -- 2082
		50, -- 2082
		FLOOR_DECK -- 2082
	) -- 2082
	self:drawBox( -- 2083
		draw, -- 2083
		w, -- 2083
		h, -- 2083
		300, -- 2083
		306, -- 2083
		0, -- 2083
		44, -- 2083
		FLOOR_DECK -- 2083
	) -- 2083
	self:drawBox( -- 2084
		draw, -- 2084
		w, -- 2084
		h, -- 2084
		414, -- 2084
		420, -- 2084
		0, -- 2084
		44, -- 2084
		FLOOR_DECK -- 2084
	) -- 2084
	local s = self.room.scavenger -- 2086
	if s ~= nil then -- 2086
		local sx0 = self.scavX -- 2088
		self:drawBox( -- 2089
			draw, -- 2089
			w, -- 2089
			h, -- 2089
			sx0 - 12, -- 2089
			sx0 + 12, -- 2089
			0, -- 2089
			s.h - 14, -- 2089
			SCAV_BODY -- 2089
		) -- 2089
		self:drawBox( -- 2090
			draw, -- 2090
			w, -- 2090
			h, -- 2090
			sx0 - 7, -- 2090
			sx0 + 7, -- 2090
			s.h - 14, -- 2090
			s.h, -- 2090
			SCAV_HEAD -- 2090
		) -- 2090
		if self.scavState == "turn" then -- 2090
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 2092
			draw:drawSegment( -- 2093
				Vec2( -- 2093
					self:sx(sx0, w), -- 2093
					self:sy(s.h - 6, h) -- 2093
				), -- 2093
				Vec2( -- 2093
					self:sx(fx, w), -- 2093
					self:sy(s.h - 6, h) -- 2093
				), -- 2093
				self:px(1), -- 2093
				INK -- 2093
			) -- 2093
		end -- 2093
	end -- 2093
	if self.hasBottle then -- 2093
		local p = self.player -- 2098
		self:drawBottle( -- 2099
			draw, -- 2099
			w, -- 2099
			h, -- 2099
			p.x + p.facing * 10, -- 2099
			p.y + p.h * 0.62 -- 2099
		) -- 2099
	end -- 2099
	if self.bottleFly ~= nil then -- 2099
		self:drawBottle( -- 2102
			draw, -- 2102
			w, -- 2102
			h, -- 2102
			self.bottleFly.x, -- 2102
			self.bottleFly.y -- 2102
		) -- 2102
	end -- 2102
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 2102
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 2105
		draw:drawCircle( -- 2106
			Vec2( -- 2106
				self:sx(self.bottleLandX, w), -- 2106
				self:sy(0, h) -- 2106
			), -- 2106
			self:px(r / ____exports.UNITS_PER_PX), -- 2106
			BRICK_LINE -- 2106
		) -- 2106
	end -- 2106
end -- 2073
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 2110
	self:drawBox( -- 2111
		draw, -- 2111
		w, -- 2111
		h, -- 2111
		x - 3, -- 2111
		x + 3, -- 2111
		y - 10, -- 2111
		y, -- 2111
		BOTTLE -- 2111
	) -- 2111
end -- 2110
function Play.prototype.drawTrace(self, draw, w, h) -- 2114
	local t = self.trace -- 2115
	if t == nil or self.traceT <= 0 then -- 2115
		return -- 2117
	end -- 2117
	draw:drawSegment( -- 2119
		Vec2( -- 2120
			self:sx(t.x0, w), -- 2120
			self:sy(t.y0, h) -- 2120
		), -- 2120
		Vec2( -- 2121
			self:sx(t.x1, w), -- 2121
			self:sy(t.y1, h) -- 2121
		), -- 2121
		self:px(1), -- 2122
		t.hit and AIM_HIT or INK_DIM -- 2122
	) -- 2122
end -- 2114
function Play.prototype.drawAim(self, draw, w, h) -- 2125
	local v = self.view -- 2127
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 2128
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 2129
	local dot = self:px(1) -- 2130
	local arm = self:px(3) -- 2131
	local gap = self:px(1) -- 2132
	draw:drawSegment( -- 2133
		Vec2(gx - arm - gap, gy), -- 2133
		Vec2(gx - gap, gy), -- 2133
		dot / 2, -- 2133
		AIM -- 2133
	) -- 2133
	draw:drawSegment( -- 2134
		Vec2(gx + gap, gy), -- 2134
		Vec2(gx + arm + gap, gy), -- 2134
		dot / 2, -- 2134
		AIM -- 2134
	) -- 2134
	draw:drawSegment( -- 2135
		Vec2(gx, gy - arm - gap), -- 2135
		Vec2(gx, gy - gap), -- 2135
		dot / 2, -- 2135
		AIM -- 2135
	) -- 2135
	draw:drawSegment( -- 2136
		Vec2(gx, gy + gap), -- 2136
		Vec2(gx, gy + arm + gap), -- 2136
		dot / 2, -- 2136
		AIM -- 2136
	) -- 2136
	if self.room.key == "village" and self.hasBottle then -- 2136
		local p = self.player -- 2140
		local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2141
		local x0 = p.x + p.facing * 10 -- 2142
		local y0 = p.y + p.h * 0.7 -- 2143
		local T = 0.62 -- 2144
		local vx = (aim.x - x0) / T -- 2145
		local vy = (aim.y - y0 + 0.5 * GRAVITY * T * T) / T -- 2146
		local pxr = x0 -- 2147
		local pyr = y0 -- 2148
		local t = 1 -- 2149
		do -- 2149
			t = 1 -- 2150
			while t <= 12 do -- 2150
				local tt = t / 12 * T -- 2151
				local nx = x0 + vx * tt -- 2152
				local ny = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 2153
				draw:drawSegment( -- 2154
					Vec2( -- 2154
						self:sx(pxr, w), -- 2154
						self:sy(pyr, h) -- 2154
					), -- 2154
					Vec2( -- 2154
						self:sx(nx, w), -- 2154
						self:sy(ny, h) -- 2154
					), -- 2154
					self:px(1) / 2, -- 2154
					BOTTLE -- 2154
				) -- 2154
				pxr = nx -- 2155
				pyr = ny -- 2156
				t = t + 1 -- 2150
			end -- 2150
		end -- 2150
	end -- 2150
end -- 2125
return ____exports -- 2125