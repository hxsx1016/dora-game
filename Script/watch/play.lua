-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local makeActor, drawFigure, hitBox, drawCartShape, CHILD_W, CHILD_H, SOLDIER_W, SOLDIER_H, CAM_ZOOM, CART_FILL, CLOTH -- 1
local ____Dora = require("Dora") -- 12
local Color = ____Dora.Color -- 12
local Rect = ____Dora.Rect -- 12
local Vec2 = ____Dora.Vec2 -- 12
function makeActor(room, index) -- 745
	local sp = room.spawns -- 746
	if index < 0 or index >= #sp then -- 746
		return { -- 748
			x = 0, -- 748
			y = 0, -- 748
			vx = 0, -- 748
			vy = 0, -- 748
			w = CHILD_W, -- 748
			h = CHILD_H, -- 748
			onGround = true, -- 748
			facing = 1, -- 748
			crouch = false, -- 748
			rollT = 0, -- 748
			covered = false, -- 748
			alive = false -- 748
		} -- 748
	end -- 748
	local s = sp[index + 1] -- 750
	local child = s.h <= CHILD_H -- 751
	return { -- 752
		x = s.x, -- 753
		y = s.y, -- 753
		vx = 0, -- 753
		vy = 0, -- 753
		w = child and CHILD_W or SOLDIER_W, -- 754
		h = child and CHILD_H or SOLDIER_H, -- 755
		onGround = true, -- 756
		facing = 1, -- 756
		crouch = false, -- 756
		rollT = 0, -- 756
		covered = false, -- 756
		alive = true -- 756
	} -- 756
end -- 756
function drawFigure(draw, play, w, h, a, body, head) -- 760
	if not a.alive then -- 760
		return -- 762
	end -- 762
	local x0 = a.x - a.w / 2 -- 764
	local x1 = a.x + a.w / 2 -- 765
	local y0 = a.y -- 766
	local y1 = a.y + a.h -- 767
	play:drawBox( -- 768
		draw, -- 768
		w, -- 768
		h, -- 768
		x0, -- 768
		x1, -- 768
		y0, -- 768
		y1 - a.h * 0.26, -- 768
		body -- 768
	) -- 768
	play:drawBox( -- 769
		draw, -- 769
		w, -- 769
		h, -- 769
		x0 + 2, -- 769
		x1 - 2, -- 769
		y1 - a.h * 0.26, -- 769
		y1, -- 769
		head -- 769
	) -- 769
end -- 769
--- 屏幕（局部、左下原点）→ 世界。
function ____exports.screenToWorld(sx, sy, cam, w, h) -- 773
	return {x = (sx - w / 2) / CAM_ZOOM + cam.x, y = (sy - h / 2) / CAM_ZOOM + cam.y} -- 774
end -- 773
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 778
	local tmin = 0 -- 779
	local tmax = 99999 -- 780
	if dx == 0 then -- 780
		if ox < x0 or ox > x1 then -- 780
			return -1 -- 783
		end -- 783
	else -- 783
		local t1 = (x0 - ox) / dx -- 786
		local t2 = (x1 - ox) / dx -- 787
		local lo = t1 < t2 and t1 or t2 -- 788
		local hi = t1 < t2 and t2 or t1 -- 789
		if lo > tmin then -- 789
			tmin = lo -- 791
		end -- 791
		if hi < tmax then -- 791
			tmax = hi -- 794
		end -- 794
	end -- 794
	if dy == 0 then -- 794
		if oy < y0 or oy > y1 then -- 794
			return -1 -- 799
		end -- 799
	else -- 799
		local t1 = (y0 - oy) / dy -- 802
		local t2 = (y1 - oy) / dy -- 803
		local lo = t1 < t2 and t1 or t2 -- 804
		local hi = t1 < t2 and t2 or t1 -- 805
		if lo > tmin then -- 805
			tmin = lo -- 807
		end -- 807
		if hi < tmax then -- 807
			tmax = hi -- 810
		end -- 810
	end -- 810
	return tmax >= tmin and tmin or -1 -- 813
end -- 813
function drawCartShape(draw, play, w, h, c, axleX) -- 816
	local half = c.bodyW / 2 -- 817
	local x0 = axleX - half -- 818
	local x1 = axleX + half -- 819
	play:drawBox( -- 820
		draw, -- 820
		w, -- 820
		h, -- 820
		x0, -- 820
		x1, -- 820
		c.baseY + c.wheelR, -- 820
		c.baseY + c.wheelR + c.bodyH, -- 820
		CART_FILL -- 820
	) -- 820
	draw:drawCircle( -- 821
		Vec2( -- 821
			play:sx(x0 + c.bodyW * 0.28, w), -- 821
			play:sy(c.baseY + c.wheelR, h) -- 821
		), -- 821
		c.wheelR * CAM_ZOOM, -- 821
		Color(52, 50, 48, 255) -- 821
	) -- 821
	draw:drawCircle( -- 822
		Vec2( -- 822
			play:sx(x1 - c.bodyW * 0.28, w), -- 822
			play:sy(c.baseY + c.wheelR, h) -- 822
		), -- 822
		c.wheelR * CAM_ZOOM, -- 822
		Color(52, 50, 48, 255) -- 822
	) -- 822
	local cx = c.clothSide < 0 and x0 or x1 -- 823
	play:drawBox( -- 824
		draw, -- 824
		w, -- 824
		h, -- 824
		cx - 10, -- 824
		cx + 10, -- 824
		c.baseY + c.wheelR + c.bodyH, -- 824
		c.baseY + c.wheelR + c.bodyH + 18, -- 824
		CLOTH -- 824
	) -- 824
end -- 824
____exports.STEP = 1 / 60 -- 16
local GRAVITY = 1000 -- 17
CHILD_W = 28 -- 20
CHILD_H = 64 -- 21
local CHILD_CROUCH_H = 36 -- 22
local CHILD_SPEED = 160 -- 23
local CHILD_SLOW = 80 -- 24
local CHILD_JUMP = 320 -- 25
SOLDIER_W = 30 -- 28
SOLDIER_H = 88 -- 29
local SOLDIER_SPEED = 264 -- 30
local ROLL_TIME = 0.35 -- 31
local ROLL_SPEED = 280 -- 32
CAM_ZOOM = 4 -- 35
local CAM_FOLLOW = 9 -- 36
local CAM_LOOK_UP = 46 -- 37
local INK = Color(232, 232, 228, 255) -- 39
local INK_DIM = Color(150, 152, 150, 255) -- 40
local BG_FAR = Color(24, 26, 28, 255) -- 41
local BG_MID = Color(31, 34, 37, 255) -- 42
local GROUND = Color(112, 114, 112, 255) -- 43
local FLOOR_DECK = Color(66, 70, 72, 255) -- 44
local SOLID_FILL = Color(84, 86, 84, 255) -- 45
local SOLID_EDGE = Color(126, 130, 126, 255) -- 46
CART_FILL = Color(122, 78, 56, 255) -- 47
CLOTH = Color(178, 52, 46, 255) -- 48
local DANGER = Color(150, 54, 48, 46) -- 49
local DANGER_LINE = Color(178, 78, 64, 200) -- 50
local HOLE_FILL = Color(10, 11, 12, 255) -- 51
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 52
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 53
local CHILD_BODY = Color(214, 168, 96, 255) -- 54
local CHILD_HEAD = Color(232, 214, 186, 255) -- 55
local ENEMY_BODY = Color(176, 92, 84, 255) -- 56
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 57
local CHECK = Color(96, 186, 122, 255) -- 58
local STAND = Color(226, 186, 84, 255) -- 59
local AIM = Color(236, 236, 232, 230) -- 60
local AIM_HIT = Color(236, 96, 84, 255) -- 61
____exports.Play = __TS__Class() -- 109
local Play = ____exports.Play -- 109
Play.name = "Play" -- 109
function Play.prototype.____constructor(self, room) -- 140
	self.enemies = {} -- 114
	self.boxes = {} -- 115
	self.floors = {} -- 116
	self.checkpoint = -1 -- 118
	self.flash = "" -- 120
	self.flashT = 0 -- 121
	self.traceT = 0 -- 124
	self.focusCart = false -- 126
	self.knocks = 0 -- 128
	self.knockT = 0 -- 129
	self.paused = false -- 130
	self.ticks = 0 -- 132
	self.aimX = 0 -- 134
	self.aimY = 0 -- 135
	self.viewW = 0 -- 137
	self.viewH = 0 -- 138
	self.room = room -- 141
	self.cam = {x = (room.minX + room.maxX) / 2, y = room.height / 2} -- 142
	self:buildWorld() -- 143
	self.player = makeActor(room, room.key == "checkpoint" and 1 or 0) -- 144
	self.partner = makeActor(room, room.key == "checkpoint" and 0 or -1) -- 145
	self.cam.x = self.player.x -- 146
	self.cam.y = self.player.y + CAM_LOOK_UP -- 147
	self:buildEnemies() -- 148
end -- 140
function Play.prototype.buildWorld(self) -- 152
	local room = self.room -- 153
	self.boxes = {} -- 154
	self.floors = {} -- 155
	local i = 0 -- 156
	do -- 156
		i = 0 -- 157
		while i < #room.floors do -- 157
			local f = room.floors[i + 1] -- 158
			local ____self_floors_0 = self.floors -- 158
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 159
			i = i + 1 -- 157
		end -- 157
	end -- 157
	do -- 157
		i = 0 -- 161
		while i < #room.solids do -- 161
			local s = room.solids[i + 1] -- 162
			local ____self_boxes_1 = self.boxes -- 162
			____self_boxes_1[#____self_boxes_1 + 1] = {x0 = s.x, x1 = s.x + s.w, y0 = s.y, y1 = s.y + s.h} -- 163
			i = i + 1 -- 161
		end -- 161
	end -- 161
	do -- 161
		i = 0 -- 165
		while i < #room.stairs do -- 165
			local st = room.stairs[i + 1] -- 166
			local n = st.steps + 1 -- 167
			local stepW = (st.x1 - st.x0) / n -- 168
			local k = 0 -- 169
			do -- 169
				k = 0 -- 170
				while k < n do -- 170
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 171
					local x0 = st.x0 + stepW * k -- 172
					local ____self_boxes_2 = self.boxes -- 172
					____self_boxes_2[#____self_boxes_2 + 1] = {x0 = x0, x1 = x0 + stepW, y0 = -8, y1 = y} -- 173
					k = k + 1 -- 170
				end -- 170
			end -- 170
			i = i + 1 -- 165
		end -- 165
	end -- 165
end -- 152
function Play.prototype.buildEnemies(self) -- 178
	self.enemies = {} -- 179
	if self.room.key ~= "checkpoint" then -- 179
		return -- 181
	end -- 181
	local ____self_enemies_3 = self.enemies -- 181
	____self_enemies_3[#____self_enemies_3 + 1] = { -- 183
		x = 430, -- 183
		y = 0, -- 183
		w = 26, -- 183
		h = 84, -- 183
		alive = true, -- 183
		hitT = 0 -- 183
	} -- 183
	local ____self_enemies_4 = self.enemies -- 183
	____self_enemies_4[#____self_enemies_4 + 1] = { -- 184
		x = 505, -- 184
		y = 0, -- 184
		w = 26, -- 184
		h = 84, -- 184
		alive = true, -- 184
		hitT = 0 -- 184
	} -- 184
end -- 178
function Play.prototype.update(self, dt, input) -- 188
	if input.pause.pressed then -- 188
		self.paused = not self.paused -- 190
	end -- 190
	if self.flashT > 0 then -- 190
		self.flashT = self.flashT - dt -- 193
		if self.flashT <= 0 then -- 193
			self.flash = "" -- 195
		end -- 195
	end -- 195
	if self.traceT > 0 then -- 195
		self.traceT = self.traceT - dt -- 199
		if self.traceT <= 0 then -- 199
			self.trace = nil -- 201
		end -- 201
	end -- 201
	if self.paused then -- 201
		self:updateCamera(dt) -- 205
		return -- 206
	end -- 206
	self.ticks = self.ticks + 1 -- 209
	local p = self.player -- 210
	self:stepPlayer(p, dt, input) -- 211
	self:stepPartner(p, dt) -- 212
	self:stepEnemies(dt) -- 213
	self:stepInteract(input) -- 214
	self:updateCamera(dt) -- 215
end -- 188
function Play.prototype.stepPlayer(self, a, dt, input) -- 218
	if not a.alive then -- 218
		return -- 220
	end -- 220
	local isChild = self.room.key ~= "checkpoint" -- 222
	a.crouch = isChild and input.crouch.held and a.onGround -- 223
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 224
	a.covered = not isChild and input.cover.held -- 225
	if a.rollT > 0 then -- 225
		a.rollT = a.rollT - dt -- 229
		a.vx = a.facing * ROLL_SPEED -- 230
		self:slideX(a, a.vx * dt) -- 231
		self:fallY(a, dt) -- 232
		if a.rollT <= 0 then -- 232
			self:flashSet("翻滚结束", 0.5) -- 234
		end -- 234
		return -- 236
	end -- 236
	if not isChild and input.jump.pressed and a.onGround then -- 236
		a.rollT = ROLL_TIME -- 240
		if input.moveX ~= 0 then -- 240
			a.facing = input.moveX > 0 and 1 or -1 -- 242
		end -- 242
		self:flashSet("翻滚", 0.3) -- 244
		return -- 245
	end -- 245
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 248
	if isChild then -- 248
		if input.cover.held then -- 248
			speed = CHILD_SLOW -- 251
		end -- 251
		if a.crouch then -- 251
			speed = CHILD_SLOW -- 254
		end -- 254
	elseif a.covered then -- 254
		speed = SOLDIER_SPEED * 0.45 -- 257
	end -- 257
	local dir = input.moveX -- 260
	if dir ~= 0 then -- 260
		a.facing = dir > 0 and 1 or -1 -- 262
	end -- 262
	a.vx = dir * speed -- 264
	if isChild and input.jump.pressed and a.onGround and not a.crouch then -- 264
		a.vy = CHILD_JUMP -- 268
		a.onGround = false -- 269
		self:flashSet("跳", 0.25) -- 270
	end -- 270
	self:slideX(a, a.vx * dt) -- 273
	self:fallY(a, dt) -- 274
	if not isChild and input.fire.pressed then -- 274
		self:shoot(a) -- 278
	end -- 278
end -- 218
function Play.prototype.stepPartner(self, p, dt) -- 283
	local a = self.partner -- 284
	if not a.alive then -- 284
		return -- 286
	end -- 286
	a.crouch = false -- 288
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 289
	a.vx = 0 -- 290
	self:fallY(a, dt) -- 291
end -- 283
function Play.prototype.stepEnemies(self, dt) -- 294
	local i = 0 -- 295
	do -- 295
		i = 0 -- 296
		while i < #self.enemies do -- 296
			local e = self.enemies[i + 1] -- 297
			if e.hitT > 0 then -- 297
				e.hitT = e.hitT - dt -- 299
			end -- 299
			i = i + 1 -- 296
		end -- 296
	end -- 296
end -- 294
function Play.prototype.stepInteract(self, input) -- 304
	local p = self.player -- 305
	self.focusCart = false -- 306
	if self.room.key == "outside" then -- 306
		local c = self.room.cart -- 308
		local dx = p.x - (c.startX + c.handleOffset) -- 309
		local dy = p.y - c.baseY -- 310
		if dx * dx + dy * dy < 70 * 70 then -- 310
			self.focusCart = true -- 312
		end -- 312
	end -- 312
	if input.interact.pressed then -- 312
		if self.knockT > 0 then -- 312
			self.knocks = self.knocks + 1 -- 318
		else -- 318
			self.knocks = 1 -- 320
		end -- 320
		self.knockT = 1.2 -- 322
		if self.knocks >= 2 then -- 322
			self:flashSet("敲两下", 0.8) -- 324
			self.knocks = 0 -- 325
		else -- 325
			self:flashSet("敲一下", 0.5) -- 327
		end -- 327
	elseif self.knockT > 0 then -- 327
		self.knockT = self.knockT - ____exports.STEP -- 330
		if self.knockT <= 0 then -- 330
			self.knocks = 0 -- 332
		end -- 332
	end -- 332
	local i = 0 -- 337
	do -- 337
		i = 0 -- 338
		while i < #self.room.marks do -- 338
			do -- 338
				local m = self.room.marks[i + 1] -- 339
				if m.kind ~= 0 then -- 339
					goto __continue51 -- 341
				end -- 341
				local dx = p.x - m.x -- 343
				local dy = p.y - m.y -- 344
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 344
					self.checkpoint = m.x -- 346
					self:flashSet("检查点", 1) -- 347
				end -- 347
			end -- 347
			::__continue51:: -- 347
			i = i + 1 -- 338
		end -- 338
	end -- 338
end -- 304
function Play.prototype.shoot(self, a) -- 353
	local ox = a.x + a.facing * 8 -- 354
	local oy = a.y + a.h * 0.72 -- 355
	local aim = ____exports.screenToWorld( -- 357
		self.aimX, -- 357
		self.aimY, -- 357
		self.cam, -- 357
		self.viewW, -- 357
		self.viewH -- 357
	) -- 357
	local dx = aim.x - ox -- 358
	local dy = aim.y - oy -- 359
	local len = math.sqrt(dx * dx + dy * dy) -- 360
	if len < 0.001 then -- 360
		dx = a.facing -- 362
		dy = 0 -- 363
	else -- 363
		dx = dx / len -- 365
		dy = dy / len -- 366
	end -- 366
	if dx ~= 0 then -- 366
		a.facing = dx > 0 and 1 or -1 -- 369
	end -- 369
	local hitEnemy = self:raycast( -- 372
		ox, -- 372
		oy, -- 372
		dx, -- 372
		dy, -- 372
		true -- 372
	) -- 372
	local hitWall = self:raycast( -- 373
		ox, -- 373
		oy, -- 373
		dx, -- 373
		dy, -- 373
		false -- 373
	) -- 373
	local tEnemy = hitEnemy.t -- 374
	local tWall = hitWall.t -- 375
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 376
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 377
	self.trace = { -- 379
		x0 = ox, -- 379
		y0 = oy, -- 379
		x1 = ox + dx * t, -- 379
		y1 = oy + dy * t, -- 379
		hit = hit -- 379
	} -- 379
	self.traceT = 0.12 -- 380
	if hit then -- 380
		local i = hitEnemy.index -- 382
		local e = self.enemies[i + 1] -- 383
		e.alive = false -- 384
		e.hitT = 0.4 -- 385
		self:flashSet("命中", 0.6) -- 386
	else -- 386
		self:flashSet("打空", 0.35) -- 388
	end -- 388
end -- 353
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 393
	local best = -1 -- 394
	local bestI = -1 -- 395
	local i = 0 -- 396
	if enemies then -- 396
		do -- 396
			i = 0 -- 398
			while i < #self.enemies do -- 398
				do -- 398
					local e = self.enemies[i + 1] -- 399
					if not e.alive then -- 399
						goto __continue63 -- 401
					end -- 401
					local t = hitBox( -- 403
						ox, -- 403
						oy, -- 403
						dx, -- 403
						dy, -- 403
						e.x - e.w / 2, -- 403
						e.x + e.w / 2, -- 403
						e.y, -- 403
						e.y + e.h -- 403
					) -- 403
					if t >= 0 and (best < 0 or t < best) then -- 403
						best = t -- 405
						bestI = i -- 406
					end -- 406
				end -- 406
				::__continue63:: -- 406
				i = i + 1 -- 398
			end -- 398
		end -- 398
		return {t = best, index = bestI} -- 409
	end -- 409
	do -- 409
		i = 0 -- 411
		while i < #self.boxes do -- 411
			local b = self.boxes[i + 1] -- 412
			local t = hitBox( -- 413
				ox, -- 413
				oy, -- 413
				dx, -- 413
				dy, -- 413
				b.x0, -- 413
				b.x1, -- 413
				b.y0, -- 413
				b.y1 -- 413
			) -- 413
			if t >= 0 and (best < 0 or t < best) then -- 413
				best = t -- 415
			end -- 415
			i = i + 1 -- 411
		end -- 411
	end -- 411
	if dy < 0 then -- 411
		local t = (0 - oy) / dy -- 420
		if t >= 0 and (best < 0 or t < best) then -- 420
			best = t -- 422
		end -- 422
	end -- 422
	return {t = best, index = -1} -- 425
end -- 393
function Play.prototype.slideX(self, a, dx) -- 429
	local nx = a.x + dx -- 430
	local half = a.w / 2 -- 431
	local room = self.room -- 432
	nx = math.max( -- 433
		room.minX + half, -- 433
		math.min(room.maxX - half, nx) -- 433
	) -- 433
	local i = 0 -- 434
	do -- 434
		i = 0 -- 435
		while i < #self.boxes do -- 435
			do -- 435
				local b = self.boxes[i + 1] -- 436
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 436
					goto __continue73 -- 438
				end -- 438
				if nx + half > b.x0 and nx - half < b.x1 then -- 438
					if a.x <= b.x0 then -- 438
						nx = b.x0 - half -- 442
					elseif a.x >= b.x1 then -- 442
						nx = b.x1 + half -- 444
					else -- 444
						nx = a.x -- 446
					end -- 446
				end -- 446
			end -- 446
			::__continue73:: -- 446
			i = i + 1 -- 435
		end -- 435
	end -- 435
	local arch = room.arch -- 453
	if arch.h > 0 and a.y + a.h > arch.y + arch.h + 0.001 then -- 453
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 455
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 455
			if a.x <= arch.x0 then -- 455
				nx = arch.x0 - half -- 458
			elseif a.x >= arch.x1 then -- 458
				nx = arch.x1 + half -- 460
			end -- 460
		end -- 460
	end -- 460
	a.x = nx -- 464
end -- 429
function Play.prototype.fallY(self, a, dt) -- 468
	a.vy = a.vy - GRAVITY * dt -- 469
	if a.vy < -900 then -- 469
		a.vy = -900 -- 471
	end -- 471
	local ny = a.y + a.vy * dt -- 473
	local half = a.w / 2 -- 474
	if a.vy <= 0 then -- 474
		local ground = self:groundAt(a.x, a.y + 0.5, half) -- 476
		if ny <= ground then -- 476
			ny = ground -- 478
			a.vy = 0 -- 479
			a.onGround = true -- 480
		else -- 480
			a.onGround = false -- 482
		end -- 482
	else -- 482
		a.onGround = false -- 485
		local i = 0 -- 486
		do -- 486
			i = 0 -- 487
			while i < #self.boxes do -- 487
				do -- 487
					local b = self.boxes[i + 1] -- 488
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 488
						goto __continue90 -- 490
					end -- 490
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 490
						ny = b.y0 - a.h -- 493
						a.vy = 0 -- 494
					end -- 494
				end -- 494
				::__continue90:: -- 494
				i = i + 1 -- 487
			end -- 487
		end -- 487
	end -- 487
	a.y = ny -- 498
end -- 468
function Play.prototype.groundAt(self, x, ceiling, half) -- 502
	local g = -9999 -- 503
	local i = 0 -- 504
	do -- 504
		i = 0 -- 505
		while i < #self.floors do -- 505
			local f = self.floors[i + 1] -- 506
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 506
				g = f.y1 -- 508
			end -- 508
			i = i + 1 -- 505
		end -- 505
	end -- 505
	do -- 505
		i = 0 -- 511
		while i < #self.boxes do -- 511
			local b = self.boxes[i + 1] -- 512
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 512
				g = b.y1 -- 514
			end -- 514
			i = i + 1 -- 511
		end -- 511
	end -- 511
	return g -- 517
end -- 502
function Play.prototype.updateCamera(self, dt) -- 520
	local p = self.player -- 521
	local tx = p.x + p.facing * 30 -- 522
	local ty = p.y + CAM_LOOK_UP -- 523
	local k = math.min(1, CAM_FOLLOW * dt) -- 524
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 525
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 526
end -- 520
function Play.prototype.clampCamera(self, w, h) -- 530
	local room = self.room -- 531
	local halfW = w / 2 / CAM_ZOOM -- 532
	local halfH = h / 2 / CAM_ZOOM -- 533
	local spanX = room.maxX - room.minX -- 534
	if spanX <= halfW * 2 then -- 534
		self.cam.x = (room.minX + room.maxX) / 2 -- 536
	else -- 536
		self.cam.x = math.max( -- 538
			room.minX + halfW, -- 538
			math.min(room.maxX - halfW, self.cam.x) -- 538
		) -- 538
	end -- 538
	local spanY = room.height -- 540
	if spanY <= halfH * 2 then -- 540
		self.cam.y = spanY / 2 -- 542
	else -- 542
		self.cam.y = math.max( -- 544
			halfH, -- 544
			math.min(spanY - halfH, self.cam.y) -- 544
		) -- 544
	end -- 544
end -- 530
function Play.prototype.flashSet(self, text, t) -- 548
	self.flash = text -- 549
	self.flashT = t -- 550
end -- 548
function Play.prototype.statusText(self) -- 554
	local p = self.player -- 555
	local isChild = self.room.key ~= "checkpoint" -- 556
	local who = isChild and "小满" or "周戍" -- 557
	local cx = math.floor(p.x + 0.5) -- 558
	local cy = math.floor(p.y + 0.5) -- 559
	local parts = {} -- 560
	parts[#parts + 1] = (((who .. " x=") .. tostring(cx)) .. " y=") .. tostring(cy) -- 561
	if isChild then -- 561
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 563
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 564
	else -- 564
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 566
		if p.rollT > 0 then -- 566
			parts[#parts + 1] = "翻滚中" -- 568
		end -- 568
		local alive = 0 -- 570
		local i = 0 -- 571
		do -- 571
			i = 0 -- 572
			while i < #self.enemies do -- 572
				if self.enemies[i + 1].alive then -- 572
					alive = alive + 1 -- 574
				end -- 574
				i = i + 1 -- 572
			end -- 572
		end -- 572
		parts[#parts + 1] = (("敌 " .. tostring(alive)) .. "/") .. tostring(#self.enemies) -- 577
	end -- 577
	if self.checkpoint >= 0 then -- 577
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 580
	end -- 580
	if self.paused then -- 580
		parts[#parts + 1] = "已暂停" -- 583
	end -- 583
	return table.concat(parts, " · ") -- 585
end -- 554
function Play.prototype.hintText(self) -- 589
	if self.paused then -- 589
		return "Esc 继续 · R 重置" -- 591
	end -- 591
	if self.flash ~= "" then -- 591
		return self.flash -- 594
	end -- 594
	local isChild = self.room.key ~= "checkpoint" -- 596
	if isChild then -- 596
		if self.focusCart then -- 596
			return "按住 E + A/D 拉车（D3 接）" -- 599
		end -- 599
		return "A / D 走 · Shift 慢走 · 空格跳 · S 或 Ctrl 蹲下钻过拱洞" -- 601
	end -- 601
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下" -- 603
end -- 589
function Play.prototype.draw(self, draw, w, h) -- 608
	self.viewW = w -- 609
	self.viewH = h -- 610
	self:clampCamera(w, h) -- 611
	draw:clear() -- 612
	draw:drawRect( -- 613
		Rect(0, 0, w, h), -- 613
		BG_FAR -- 613
	) -- 613
	draw:drawRect( -- 614
		Rect(0, 0, w, h * 0.62), -- 614
		BG_MID -- 614
	) -- 614
	self:drawFloors(draw, w, h) -- 616
	self:drawSolids(draw, w, h) -- 617
	self:drawZones(draw, w, h) -- 618
	self:drawArch(draw, w, h) -- 619
	self:drawCart(draw, w, h) -- 620
	self:drawActors(draw, w, h) -- 621
	self:drawTrace(draw, w, h) -- 622
	self:drawAim(draw, w, h) -- 623
end -- 608
function Play.prototype.sx(self, wx, w) -- 626
	return (wx - self.cam.x) * CAM_ZOOM + w / 2 -- 627
end -- 626
function Play.prototype.sy(self, wy, h) -- 630
	return (wy - self.cam.y) * CAM_ZOOM + h / 2 -- 631
end -- 630
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 634
	local px = self:sx(x0, w) -- 635
	local py = self:sy(y0, h) -- 636
	draw:drawRect( -- 637
		Rect(px, py, (x1 - x0) * CAM_ZOOM, (y1 - y0) * CAM_ZOOM), -- 637
		color -- 637
	) -- 637
end -- 634
function Play.prototype.drawFloors(self, draw, w, h) -- 640
	local i = 0 -- 641
	do -- 641
		i = 0 -- 642
		while i < #self.room.floors do -- 642
			local f = self.room.floors[i + 1] -- 643
			local y = self:sy(f.y, h) -- 644
			local x0 = self:sx(f.x0, w) -- 645
			local x1 = self:sx(f.x1, w) -- 646
			draw:drawRect( -- 647
				Rect(x0, y - 10 * 2, x1 - x0, 10 * 2), -- 647
				FLOOR_DECK -- 647
			) -- 647
			draw:drawSegment( -- 648
				Vec2(x0, y), -- 648
				Vec2(x1, y), -- 648
				3, -- 648
				GROUND -- 648
			) -- 648
			i = i + 1 -- 642
		end -- 642
	end -- 642
end -- 640
function Play.prototype.drawSolids(self, draw, w, h) -- 652
	local i = 0 -- 653
	do -- 653
		i = 0 -- 654
		while i < #self.boxes do -- 654
			do -- 654
				local b = self.boxes[i + 1] -- 655
				if b.y0 < -4 and b.y1 <= 96 then -- 655
					draw:drawSegment( -- 658
						Vec2( -- 658
							self:sx(b.x0, w), -- 658
							self:sy(b.y1, h) -- 658
						), -- 658
						Vec2( -- 658
							self:sx(b.x1, w), -- 658
							self:sy(b.y1, h) -- 658
						), -- 658
						3, -- 658
						GROUND -- 658
					) -- 658
					goto __continue130 -- 659
				end -- 659
				self:drawBox( -- 661
					draw, -- 661
					w, -- 661
					h, -- 661
					b.x0, -- 661
					b.x1, -- 661
					b.y0, -- 661
					b.y1, -- 661
					SOLID_FILL -- 661
				) -- 661
				draw:drawSegment( -- 662
					Vec2( -- 662
						self:sx(b.x0, w), -- 662
						self:sy(b.y1, h) -- 662
					), -- 662
					Vec2( -- 662
						self:sx(b.x1, w), -- 662
						self:sy(b.y1, h) -- 662
					), -- 662
					2, -- 662
					SOLID_EDGE -- 662
				) -- 662
			end -- 662
			::__continue130:: -- 662
			i = i + 1 -- 654
		end -- 654
	end -- 654
end -- 652
function Play.prototype.drawZones(self, draw, w, h) -- 666
	local i = 0 -- 667
	do -- 667
		i = 0 -- 668
		while i < #self.room.zones do -- 668
			local z = self.room.zones[i + 1] -- 669
			self:drawBox( -- 670
				draw, -- 670
				w, -- 670
				h, -- 670
				z.x0, -- 670
				z.x1, -- 670
				z.y, -- 670
				z.y + z.h, -- 670
				DANGER -- 670
			) -- 670
			draw:drawSegment( -- 671
				Vec2( -- 671
					self:sx(z.x0, w), -- 671
					self:sy(z.y, h) -- 671
				), -- 671
				Vec2( -- 671
					self:sx(z.x0, w), -- 671
					self:sy(z.y + z.h, h) -- 671
				), -- 671
				2, -- 671
				DANGER_LINE -- 671
			) -- 671
			draw:drawSegment( -- 672
				Vec2( -- 672
					self:sx(z.x1, w), -- 672
					self:sy(z.y, h) -- 672
				), -- 672
				Vec2( -- 672
					self:sx(z.x1, w), -- 672
					self:sy(z.y + z.h, h) -- 672
				), -- 672
				2, -- 672
				DANGER_LINE -- 672
			) -- 672
			i = i + 1 -- 668
		end -- 668
	end -- 668
end -- 666
function Play.prototype.drawArch(self, draw, w, h) -- 676
	local a = self.room.arch -- 677
	if a.h <= 0 then -- 677
		return -- 679
	end -- 679
	self:drawBox( -- 681
		draw, -- 681
		w, -- 681
		h, -- 681
		a.x0, -- 681
		a.x1, -- 681
		a.y, -- 681
		a.y + a.h, -- 681
		HOLE_FILL -- 681
	) -- 681
	draw:drawSegment( -- 682
		Vec2( -- 682
			self:sx(a.x0, w), -- 682
			self:sy(a.y + a.h, h) -- 682
		), -- 682
		Vec2( -- 682
			self:sx(a.x1, w), -- 682
			self:sy(a.y + a.h, h) -- 682
		), -- 682
		3, -- 682
		SOLID_EDGE -- 682
	) -- 682
	draw:drawSegment( -- 683
		Vec2( -- 683
			self:sx(a.x0, w), -- 683
			self:sy(a.y, h) -- 683
		), -- 683
		Vec2( -- 683
			self:sx(a.x0, w), -- 683
			self:sy(a.y + a.h, h) -- 683
		), -- 683
		2, -- 683
		SOLID_EDGE -- 683
	) -- 683
	draw:drawSegment( -- 684
		Vec2( -- 684
			self:sx(a.x1, w), -- 684
			self:sy(a.y, h) -- 684
		), -- 684
		Vec2( -- 684
			self:sx(a.x1, w), -- 684
			self:sy(a.y + a.h, h) -- 684
		), -- 684
		2, -- 684
		SOLID_EDGE -- 684
	) -- 684
end -- 676
function Play.prototype.drawCart(self, draw, w, h) -- 687
	local c = self.room.cart -- 688
	drawCartShape( -- 689
		draw, -- 689
		self, -- 689
		w, -- 689
		h, -- 689
		c, -- 689
		c.startX -- 689
	) -- 689
	draw:drawRect( -- 690
		Rect( -- 690
			self:sx(c.startX + c.handleOffset, w) - 3, -- 690
			self:sy(c.baseY + 40, h), -- 690
			6, -- 690
			80 -- 690
		), -- 690
		STAND -- 690
	) -- 690
end -- 687
function Play.prototype.drawActors(self, draw, w, h) -- 693
	local p = self.player -- 694
	local isChild = self.room.key ~= "checkpoint" -- 695
	drawFigure( -- 696
		draw, -- 696
		self, -- 696
		w, -- 696
		h, -- 696
		p, -- 696
		isChild and CHILD_BODY or SOLDIER_BODY, -- 696
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 696
	) -- 696
	local q = self.partner -- 697
	if q.alive then -- 697
		local childPartner = q.w == CHILD_W -- 699
		drawFigure( -- 700
			draw, -- 700
			self, -- 700
			w, -- 700
			h, -- 700
			q, -- 700
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 700
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 700
		) -- 700
	end -- 700
	local i = 0 -- 702
	do -- 702
		i = 0 -- 703
		while i < #self.enemies do -- 703
			local e = self.enemies[i + 1] -- 704
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 705
			self:drawBox( -- 706
				draw, -- 706
				w, -- 706
				h, -- 706
				e.x - e.w / 2, -- 706
				e.x + e.w / 2, -- 706
				e.y, -- 706
				e.y + e.h, -- 706
				col -- 706
			) -- 706
			i = i + 1 -- 703
		end -- 703
	end -- 703
	local k = 0 -- 709
	do -- 709
		k = 0 -- 710
		while k < #self.room.marks do -- 710
			do -- 710
				local m = self.room.marks[k + 1] -- 711
				if m.kind ~= 0 then -- 711
					goto __continue143 -- 713
				end -- 713
				local on = self.checkpoint == m.x -- 715
				local x = self:sx(m.x, w) -- 716
				local y = self:sy(m.y, h) -- 717
				draw:drawSegment( -- 718
					Vec2(x, y), -- 718
					Vec2(x, y + 70), -- 718
					2, -- 718
					on and CHECK or INK_DIM -- 718
				) -- 718
				draw:drawDot( -- 719
					Vec2(x, y + 70), -- 719
					5, -- 719
					on and CHECK or INK_DIM -- 719
				) -- 719
			end -- 719
			::__continue143:: -- 719
			k = k + 1 -- 710
		end -- 710
	end -- 710
end -- 693
function Play.prototype.drawTrace(self, draw, w, h) -- 723
	local t = self.trace -- 724
	if t == nil or self.traceT <= 0 then -- 724
		return -- 726
	end -- 726
	draw:drawSegment( -- 728
		Vec2( -- 729
			self:sx(t.x0, w), -- 729
			self:sy(t.y0, h) -- 729
		), -- 729
		Vec2( -- 730
			self:sx(t.x1, w), -- 730
			self:sy(t.y1, h) -- 730
		), -- 730
		2, -- 731
		t.hit and AIM_HIT or INK_DIM -- 731
	) -- 731
end -- 723
function Play.prototype.drawAim(self, draw, w, h) -- 734
	local x = self.aimX -- 735
	local y = self.aimY -- 736
	draw:drawRing( -- 737
		Vec2(x, y), -- 737
		7, -- 737
		9, -- 737
		Color(0, 0, 0, 0), -- 737
		1, -- 737
		AIM -- 737
	) -- 737
	draw:drawSegment( -- 738
		Vec2(x - 14, y), -- 738
		Vec2(x - 4, y), -- 738
		1, -- 738
		AIM -- 738
	) -- 738
	draw:drawSegment( -- 739
		Vec2(x + 4, y), -- 739
		Vec2(x + 14, y), -- 739
		1, -- 739
		AIM -- 739
	) -- 739
	draw:drawSegment( -- 740
		Vec2(x, y - 14), -- 740
		Vec2(x, y - 4), -- 740
		1, -- 740
		AIM -- 740
	) -- 740
	draw:drawSegment( -- 741
		Vec2(x, y + 4), -- 741
		Vec2(x, y + 14), -- 741
		1, -- 741
		AIM -- 741
	) -- 741
end -- 734
return ____exports -- 734