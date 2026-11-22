-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local makeActor, drawFigure, hitBox, drawCartShape, CHILD_W, CHILD_H, SOLDIER_W, SOLDIER_H, INK, CART_FILL, CLOTH -- 1
local ____Dora = require("Dora") -- 12
local Color = ____Dora.Color -- 12
local Rect = ____Dora.Rect -- 12
local Vec2 = ____Dora.Vec2 -- 12
function makeActor(room, index) -- 805
	local sp = room.spawns -- 806
	if index < 0 or index >= #sp then -- 806
		return { -- 808
			x = 0, -- 808
			y = 0, -- 808
			vx = 0, -- 808
			vy = 0, -- 808
			w = CHILD_W, -- 808
			h = CHILD_H, -- 808
			onGround = true, -- 808
			facing = 1, -- 808
			crouch = false, -- 808
			rollT = 0, -- 808
			covered = false, -- 808
			alive = false -- 808
		} -- 808
	end -- 808
	local s = sp[index + 1] -- 810
	local child = s.h <= CHILD_H -- 811
	return { -- 812
		x = s.x, -- 813
		y = s.y, -- 813
		vx = 0, -- 813
		vy = 0, -- 813
		w = child and CHILD_W or SOLDIER_W, -- 814
		h = child and CHILD_H or SOLDIER_H, -- 815
		onGround = true, -- 816
		facing = 1, -- 816
		crouch = false, -- 816
		rollT = 0, -- 816
		covered = false, -- 816
		alive = true -- 816
	} -- 816
end -- 816
function drawFigure(draw, play, w, h, a, body, head) -- 820
	if not a.alive then -- 820
		return -- 822
	end -- 822
	local x0 = a.x - a.w / 2 -- 824
	local x1 = a.x + a.w / 2 -- 825
	local y0 = a.y -- 826
	local y1 = a.y + a.h -- 827
	play:drawBox( -- 828
		draw, -- 828
		w, -- 828
		h, -- 828
		x0, -- 828
		x1, -- 828
		y0, -- 828
		y1 - a.h * 0.26, -- 828
		body -- 828
	) -- 828
	play:drawBox( -- 829
		draw, -- 829
		w, -- 829
		h, -- 829
		x0 + 2, -- 829
		x1 - 2, -- 829
		y1 - a.h * 0.26, -- 829
		y1, -- 829
		head -- 829
	) -- 829
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 831
	play:drawBox( -- 832
		draw, -- 832
		w, -- 832
		h, -- 832
		eyeX, -- 832
		eyeX + 4, -- 832
		y1 - a.h * 0.14, -- 832
		y1 - a.h * 0.08, -- 832
		INK -- 832
	) -- 832
end -- 832
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 836
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 837
end -- 836
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 844
	local tmin = 0 -- 845
	local tmax = 99999 -- 846
	if dx == 0 then -- 846
		if ox < x0 or ox > x1 then -- 846
			return -1 -- 849
		end -- 849
	else -- 849
		local t1 = (x0 - ox) / dx -- 852
		local t2 = (x1 - ox) / dx -- 853
		local lo = t1 < t2 and t1 or t2 -- 854
		local hi = t1 < t2 and t2 or t1 -- 855
		if lo > tmin then -- 855
			tmin = lo -- 857
		end -- 857
		if hi < tmax then -- 857
			tmax = hi -- 860
		end -- 860
	end -- 860
	if dy == 0 then -- 860
		if oy < y0 or oy > y1 then -- 860
			return -1 -- 865
		end -- 865
	else -- 865
		local t1 = (y0 - oy) / dy -- 868
		local t2 = (y1 - oy) / dy -- 869
		local lo = t1 < t2 and t1 or t2 -- 870
		local hi = t1 < t2 and t2 or t1 -- 871
		if lo > tmin then -- 871
			tmin = lo -- 873
		end -- 873
		if hi < tmax then -- 873
			tmax = hi -- 876
		end -- 876
	end -- 876
	return tmax >= tmin and tmin or -1 -- 879
end -- 879
function drawCartShape(draw, play, w, h, c, axleX) -- 882
	local half = c.bodyW / 2 -- 883
	local x0 = axleX - half -- 884
	local x1 = axleX + half -- 885
	play:drawBox( -- 886
		draw, -- 886
		w, -- 886
		h, -- 886
		x0, -- 886
		x1, -- 886
		c.baseY + c.wheelR, -- 886
		c.baseY + c.wheelR + c.bodyH, -- 886
		CART_FILL -- 886
	) -- 886
	draw:drawCircle( -- 887
		Vec2( -- 887
			play:sx(x0 + c.bodyW * 0.28, w), -- 887
			play:sy(c.baseY + c.wheelR, h) -- 887
		), -- 887
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 887
		Color(52, 50, 48, 255) -- 887
	) -- 887
	draw:drawCircle( -- 888
		Vec2( -- 888
			play:sx(x1 - c.bodyW * 0.28, w), -- 888
			play:sy(c.baseY + c.wheelR, h) -- 888
		), -- 888
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 888
		Color(52, 50, 48, 255) -- 888
	) -- 888
	local cx = c.clothSide < 0 and x0 or x1 -- 889
	play:drawBox( -- 890
		draw, -- 890
		w, -- 890
		h, -- 890
		cx - 10, -- 890
		cx + 10, -- 890
		c.baseY + c.wheelR + c.bodyH, -- 890
		c.baseY + c.wheelR + c.bodyH + 18, -- 890
		CLOTH -- 890
	) -- 890
end -- 890
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
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 35
____exports.LOGIC_H = 180 -- 36
____exports.UNITS_PER_PX = 2 -- 37
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 39
local CAM_FOLLOW = 9 -- 40
local CAM_LOOK_UP = 46 -- 41
INK = Color(232, 232, 228, 255) -- 43
local INK_DIM = Color(150, 152, 150, 255) -- 44
local BG_VOID = Color(8, 9, 10, 255) -- 45
local BG_FAR = Color(24, 26, 28, 255) -- 46
local BG_MID = Color(31, 34, 37, 255) -- 47
local GROUND = Color(112, 114, 112, 255) -- 48
local FLOOR_DECK = Color(66, 70, 72, 255) -- 49
local SOLID_FILL = Color(84, 86, 84, 255) -- 50
local SOLID_EDGE = Color(126, 130, 126, 255) -- 51
CART_FILL = Color(122, 78, 56, 255) -- 52
CLOTH = Color(178, 52, 46, 255) -- 53
local DANGER = Color(150, 54, 48, 46) -- 54
local DANGER_LINE = Color(178, 78, 64, 200) -- 55
local HOLE_FILL = Color(10, 11, 12, 255) -- 56
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 57
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 58
local CHILD_BODY = Color(214, 168, 96, 255) -- 59
local CHILD_HEAD = Color(232, 214, 186, 255) -- 60
local ENEMY_BODY = Color(176, 92, 84, 255) -- 61
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 62
local CHECK = Color(96, 186, 122, 255) -- 63
local STAND = Color(226, 186, 84, 255) -- 64
local AIM = Color(236, 236, 232, 230) -- 65
local AIM_HIT = Color(236, 96, 84, 255) -- 66
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 113
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 114
	if zoom < 1 then -- 114
		zoom = 1 -- 116
	end -- 116
	return { -- 118
		zoom = zoom, -- 119
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 120
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 121
	} -- 121
end -- 113
____exports.Play = __TS__Class() -- 134
local Play = ____exports.Play -- 134
Play.name = "Play" -- 134
function Play.prototype.____constructor(self, room) -- 167
	self.enemies = {} -- 139
	self.boxes = {} -- 140
	self.floors = {} -- 141
	self.checkpoint = -1 -- 143
	self.flash = "" -- 145
	self.flashT = 0 -- 146
	self.traceT = 0 -- 149
	self.focusCart = false -- 151
	self.knocks = 0 -- 153
	self.knockT = 0 -- 154
	self.paused = false -- 155
	self.ticks = 0 -- 157
	self.view = {zoom = 1, ox = 0, oy = 0} -- 159
	self.aimX = 0 -- 161
	self.aimY = 0 -- 162
	self.viewW = 0 -- 164
	self.viewH = 0 -- 165
	self.room = room -- 168
	self.cam = {x = (room.minX + room.maxX) / 2, y = room.height / 2} -- 169
	self:buildWorld() -- 170
	self.player = makeActor(room, room.key == "checkpoint" and 1 or 0) -- 171
	self.partner = makeActor(room, room.key == "checkpoint" and 0 or -1) -- 172
	self.cam.x = self.player.x -- 173
	self.cam.y = self.player.y + CAM_LOOK_UP -- 174
	self:buildEnemies() -- 175
end -- 167
function Play.prototype.buildWorld(self) -- 179
	local room = self.room -- 180
	self.boxes = {} -- 181
	self.floors = {} -- 182
	local i = 0 -- 183
	do -- 183
		i = 0 -- 184
		while i < #room.floors do -- 184
			local f = room.floors[i + 1] -- 185
			local ____self_floors_0 = self.floors -- 185
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 186
			i = i + 1 -- 184
		end -- 184
	end -- 184
	do -- 184
		i = 0 -- 188
		while i < #room.solids do -- 188
			local s = room.solids[i + 1] -- 189
			local ____self_boxes_1 = self.boxes -- 189
			____self_boxes_1[#____self_boxes_1 + 1] = {x0 = s.x, x1 = s.x + s.w, y0 = s.y, y1 = s.y + s.h} -- 190
			i = i + 1 -- 188
		end -- 188
	end -- 188
	do -- 188
		i = 0 -- 192
		while i < #room.stairs do -- 192
			local st = room.stairs[i + 1] -- 193
			local n = st.steps + 1 -- 194
			local stepW = (st.x1 - st.x0) / n -- 195
			local k = 0 -- 196
			do -- 196
				k = 0 -- 197
				while k < n do -- 197
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 198
					local x0 = st.x0 + stepW * k -- 199
					local ____self_boxes_2 = self.boxes -- 199
					____self_boxes_2[#____self_boxes_2 + 1] = {x0 = x0, x1 = x0 + stepW, y0 = -8, y1 = y} -- 200
					k = k + 1 -- 197
				end -- 197
			end -- 197
			i = i + 1 -- 192
		end -- 192
	end -- 192
end -- 179
function Play.prototype.buildEnemies(self) -- 205
	self.enemies = {} -- 206
	if self.room.key ~= "checkpoint" then -- 206
		return -- 208
	end -- 208
	local ____self_enemies_3 = self.enemies -- 208
	____self_enemies_3[#____self_enemies_3 + 1] = { -- 210
		x = 430, -- 210
		y = 0, -- 210
		w = 26, -- 210
		h = 84, -- 210
		alive = true, -- 210
		hitT = 0 -- 210
	} -- 210
	local ____self_enemies_4 = self.enemies -- 210
	____self_enemies_4[#____self_enemies_4 + 1] = { -- 211
		x = 505, -- 211
		y = 0, -- 211
		w = 26, -- 211
		h = 84, -- 211
		alive = true, -- 211
		hitT = 0 -- 211
	} -- 211
end -- 205
function Play.prototype.update(self, dt, input) -- 215
	if input.pause.pressed then -- 215
		self.paused = not self.paused -- 217
	end -- 217
	if self.flashT > 0 then -- 217
		self.flashT = self.flashT - dt -- 220
		if self.flashT <= 0 then -- 220
			self.flash = "" -- 222
		end -- 222
	end -- 222
	if self.traceT > 0 then -- 222
		self.traceT = self.traceT - dt -- 226
		if self.traceT <= 0 then -- 226
			self.trace = nil -- 228
		end -- 228
	end -- 228
	if self.paused then -- 228
		self:updateCamera(dt) -- 232
		return -- 233
	end -- 233
	self.ticks = self.ticks + 1 -- 236
	local p = self.player -- 237
	self:stepPlayer(p, dt, input) -- 238
	self:stepPartner(p, dt) -- 239
	self:stepEnemies(dt) -- 240
	self:stepInteract(input) -- 241
	self:updateCamera(dt) -- 242
end -- 215
function Play.prototype.stepPlayer(self, a, dt, input) -- 245
	if not a.alive then -- 245
		return -- 247
	end -- 247
	local isChild = self.room.key ~= "checkpoint" -- 249
	a.crouch = isChild and input.crouch.held and a.onGround -- 250
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 251
	a.covered = not isChild and input.cover.held -- 252
	if a.rollT > 0 then -- 252
		a.rollT = a.rollT - dt -- 256
		a.vx = a.facing * ROLL_SPEED -- 257
		self:slideX(a, a.vx * dt) -- 258
		self:fallY(a, dt) -- 259
		if a.rollT <= 0 then -- 259
			self:flashSet("翻滚结束", 0.5) -- 261
		end -- 261
		return -- 263
	end -- 263
	if not isChild and input.jump.pressed and a.onGround then -- 263
		a.rollT = ROLL_TIME -- 267
		if input.moveX ~= 0 then -- 267
			a.facing = input.moveX > 0 and 1 or -1 -- 269
		end -- 269
		self:flashSet("翻滚", 0.3) -- 271
		return -- 272
	end -- 272
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 275
	if isChild then -- 275
		if input.cover.held then -- 275
			speed = CHILD_SLOW -- 278
		end -- 278
		if a.crouch then -- 278
			speed = CHILD_SLOW -- 281
		end -- 281
	elseif a.covered then -- 281
		speed = SOLDIER_SPEED * 0.45 -- 284
	end -- 284
	local dir = input.moveX -- 287
	if dir ~= 0 then -- 287
		a.facing = dir > 0 and 1 or -1 -- 289
	end -- 289
	a.vx = dir * speed -- 291
	if isChild and input.jump.pressed and a.onGround and not a.crouch then -- 291
		a.vy = CHILD_JUMP -- 295
		a.onGround = false -- 296
		self:flashSet("跳", 0.25) -- 297
	end -- 297
	self:slideX(a, a.vx * dt) -- 300
	self:fallY(a, dt) -- 301
	if not isChild and input.fire.pressed then -- 301
		self:shoot(a) -- 305
	end -- 305
end -- 245
function Play.prototype.stepPartner(self, p, dt) -- 310
	local a = self.partner -- 311
	if not a.alive then -- 311
		return -- 313
	end -- 313
	a.crouch = false -- 315
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 316
	a.vx = 0 -- 317
	self:fallY(a, dt) -- 318
end -- 310
function Play.prototype.stepEnemies(self, dt) -- 321
	local i = 0 -- 322
	do -- 322
		i = 0 -- 323
		while i < #self.enemies do -- 323
			local e = self.enemies[i + 1] -- 324
			if e.hitT > 0 then -- 324
				e.hitT = e.hitT - dt -- 326
			end -- 326
			i = i + 1 -- 323
		end -- 323
	end -- 323
end -- 321
function Play.prototype.stepInteract(self, input) -- 331
	local p = self.player -- 332
	self.focusCart = false -- 333
	if self.room.key == "outside" then -- 333
		local c = self.room.cart -- 335
		local dx = p.x - (c.startX + c.handleOffset) -- 336
		local dy = p.y - c.baseY -- 337
		if dx * dx + dy * dy < 70 * 70 then -- 337
			self.focusCart = true -- 339
		end -- 339
	end -- 339
	if input.interact.pressed then -- 339
		if self.knockT > 0 then -- 339
			self.knocks = self.knocks + 1 -- 345
		else -- 345
			self.knocks = 1 -- 347
		end -- 347
		self.knockT = 1.2 -- 349
		if self.knocks >= 2 then -- 349
			self:flashSet("敲两下", 0.8) -- 351
			self.knocks = 0 -- 352
		else -- 352
			self:flashSet("敲一下", 0.5) -- 354
		end -- 354
	elseif self.knockT > 0 then -- 354
		self.knockT = self.knockT - ____exports.STEP -- 357
		if self.knockT <= 0 then -- 357
			self.knocks = 0 -- 359
		end -- 359
	end -- 359
	local i = 0 -- 364
	do -- 364
		i = 0 -- 365
		while i < #self.room.marks do -- 365
			do -- 365
				local m = self.room.marks[i + 1] -- 366
				if m.kind ~= 0 then -- 366
					goto __continue53 -- 368
				end -- 368
				local dx = p.x - m.x -- 370
				local dy = p.y - m.y -- 371
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 371
					self.checkpoint = m.x -- 373
					self:flashSet("检查点", 1) -- 374
				end -- 374
			end -- 374
			::__continue53:: -- 374
			i = i + 1 -- 365
		end -- 365
	end -- 365
end -- 331
function Play.prototype.shoot(self, a) -- 380
	local ox = a.x + a.facing * 8 -- 381
	local oy = a.y + a.h * 0.72 -- 382
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 384
	local dx = aim.x - ox -- 385
	local dy = aim.y - oy -- 386
	local len = math.sqrt(dx * dx + dy * dy) -- 387
	if len < 0.001 then -- 387
		dx = a.facing -- 389
		dy = 0 -- 390
	else -- 390
		dx = dx / len -- 392
		dy = dy / len -- 393
	end -- 393
	if dx ~= 0 then -- 393
		a.facing = dx > 0 and 1 or -1 -- 396
	end -- 396
	local hitEnemy = self:raycast( -- 399
		ox, -- 399
		oy, -- 399
		dx, -- 399
		dy, -- 399
		true -- 399
	) -- 399
	local hitWall = self:raycast( -- 400
		ox, -- 400
		oy, -- 400
		dx, -- 400
		dy, -- 400
		false -- 400
	) -- 400
	local tEnemy = hitEnemy.t -- 401
	local tWall = hitWall.t -- 402
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 403
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 404
	self.trace = { -- 406
		x0 = ox, -- 406
		y0 = oy, -- 406
		x1 = ox + dx * t, -- 406
		y1 = oy + dy * t, -- 406
		hit = hit -- 406
	} -- 406
	self.traceT = 0.12 -- 407
	if hit then -- 407
		local i = hitEnemy.index -- 409
		local e = self.enemies[i + 1] -- 410
		e.alive = false -- 411
		e.hitT = 0.4 -- 412
		self:flashSet("命中", 0.6) -- 413
	else -- 413
		self:flashSet("打空", 0.35) -- 415
	end -- 415
end -- 380
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 420
	local best = -1 -- 421
	local bestI = -1 -- 422
	local i = 0 -- 423
	if enemies then -- 423
		do -- 423
			i = 0 -- 425
			while i < #self.enemies do -- 425
				do -- 425
					local e = self.enemies[i + 1] -- 426
					if not e.alive then -- 426
						goto __continue65 -- 428
					end -- 428
					local t = hitBox( -- 430
						ox, -- 430
						oy, -- 430
						dx, -- 430
						dy, -- 430
						e.x - e.w / 2, -- 430
						e.x + e.w / 2, -- 430
						e.y, -- 430
						e.y + e.h -- 430
					) -- 430
					if t >= 0 and (best < 0 or t < best) then -- 430
						best = t -- 432
						bestI = i -- 433
					end -- 433
				end -- 433
				::__continue65:: -- 433
				i = i + 1 -- 425
			end -- 425
		end -- 425
		return {t = best, index = bestI} -- 436
	end -- 436
	do -- 436
		i = 0 -- 438
		while i < #self.boxes do -- 438
			local b = self.boxes[i + 1] -- 439
			local t = hitBox( -- 440
				ox, -- 440
				oy, -- 440
				dx, -- 440
				dy, -- 440
				b.x0, -- 440
				b.x1, -- 440
				b.y0, -- 440
				b.y1 -- 440
			) -- 440
			if t >= 0 and (best < 0 or t < best) then -- 440
				best = t -- 442
			end -- 442
			i = i + 1 -- 438
		end -- 438
	end -- 438
	if dy < 0 then -- 438
		local t = (0 - oy) / dy -- 447
		if t >= 0 and (best < 0 or t < best) then -- 447
			best = t -- 449
		end -- 449
	end -- 449
	return {t = best, index = -1} -- 452
end -- 420
function Play.prototype.slideX(self, a, dx) -- 456
	local nx = a.x + dx -- 457
	local half = a.w / 2 -- 458
	local room = self.room -- 459
	nx = math.max( -- 460
		room.minX + half, -- 460
		math.min(room.maxX - half, nx) -- 460
	) -- 460
	local i = 0 -- 461
	do -- 461
		i = 0 -- 462
		while i < #self.boxes do -- 462
			do -- 462
				local b = self.boxes[i + 1] -- 463
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 463
					goto __continue75 -- 465
				end -- 465
				if nx + half > b.x0 and nx - half < b.x1 then -- 465
					if a.x <= b.x0 then -- 465
						nx = b.x0 - half -- 469
					elseif a.x >= b.x1 then -- 469
						nx = b.x1 + half -- 471
					else -- 471
						nx = a.x -- 473
					end -- 473
				end -- 473
			end -- 473
			::__continue75:: -- 473
			i = i + 1 -- 462
		end -- 462
	end -- 462
	local arch = room.arch -- 480
	if arch.h > 0 and a.y + a.h > arch.y + arch.h + 0.001 then -- 480
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 482
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 482
			if a.x <= arch.x0 then -- 482
				nx = arch.x0 - half -- 485
			elseif a.x >= arch.x1 then -- 485
				nx = arch.x1 + half -- 487
			end -- 487
		end -- 487
	end -- 487
	a.x = nx -- 491
end -- 456
function Play.prototype.fallY(self, a, dt) -- 495
	a.vy = a.vy - GRAVITY * dt -- 496
	if a.vy < -900 then -- 496
		a.vy = -900 -- 498
	end -- 498
	local ny = a.y + a.vy * dt -- 500
	local half = a.w / 2 -- 501
	if a.vy <= 0 then -- 501
		local ground = self:groundAt(a.x, a.y + 0.5, half) -- 503
		if ny <= ground then -- 503
			ny = ground -- 505
			a.vy = 0 -- 506
			a.onGround = true -- 507
		else -- 507
			a.onGround = false -- 509
		end -- 509
	else -- 509
		a.onGround = false -- 512
		local i = 0 -- 513
		do -- 513
			i = 0 -- 514
			while i < #self.boxes do -- 514
				do -- 514
					local b = self.boxes[i + 1] -- 515
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 515
						goto __continue92 -- 517
					end -- 517
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 517
						ny = b.y0 - a.h -- 520
						a.vy = 0 -- 521
					end -- 521
				end -- 521
				::__continue92:: -- 521
				i = i + 1 -- 514
			end -- 514
		end -- 514
	end -- 514
	a.y = ny -- 525
end -- 495
function Play.prototype.groundAt(self, x, ceiling, half) -- 529
	local g = -9999 -- 530
	local i = 0 -- 531
	do -- 531
		i = 0 -- 532
		while i < #self.floors do -- 532
			local f = self.floors[i + 1] -- 533
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 533
				g = f.y1 -- 535
			end -- 535
			i = i + 1 -- 532
		end -- 532
	end -- 532
	do -- 532
		i = 0 -- 538
		while i < #self.boxes do -- 538
			local b = self.boxes[i + 1] -- 539
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 539
				g = b.y1 -- 541
			end -- 541
			i = i + 1 -- 538
		end -- 538
	end -- 538
	return g -- 544
end -- 529
function Play.prototype.updateCamera(self, dt) -- 547
	local p = self.player -- 548
	local tx = p.x + p.facing * 30 -- 549
	local ty = p.y + CAM_LOOK_UP -- 550
	local k = math.min(1, CAM_FOLLOW * dt) -- 551
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 552
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 553
end -- 547
function Play.prototype.clampCamera(self, w, h) -- 557
	local room = self.room -- 558
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 559
	local spanX = room.maxX - room.minX -- 560
	if spanX <= halfW * 2 then -- 560
		self.cam.x = (room.minX + room.maxX) / 2 -- 562
	else -- 562
		self.cam.x = math.max( -- 564
			room.minX + halfW, -- 564
			math.min(room.maxX - halfW, self.cam.x) -- 564
		) -- 564
	end -- 564
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 567
	local spanY = room.height -- 568
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 569
	if spanY <= halfH * 2 then -- 569
		self.cam.y = camY -- 571
	else -- 571
		self.cam.y = math.max( -- 573
			camY, -- 573
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 573
		) -- 573
	end -- 573
end -- 557
function Play.prototype.flashSet(self, text, t) -- 577
	self.flash = text -- 578
	self.flashT = t -- 579
end -- 577
function Play.prototype.statusText(self) -- 583
	local p = self.player -- 584
	local isChild = self.room.key ~= "checkpoint" -- 585
	local who = isChild and "小满" or "周戍" -- 586
	local cx = math.floor(p.x + 0.5) -- 587
	local cy = math.floor(p.y + 0.5) -- 588
	local parts = {} -- 589
	parts[#parts + 1] = (((who .. " x=") .. tostring(cx)) .. " y=") .. tostring(cy) -- 590
	if isChild then -- 590
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 592
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 593
	else -- 593
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 595
		if p.rollT > 0 then -- 595
			parts[#parts + 1] = "翻滚中" -- 597
		end -- 597
		local alive = 0 -- 599
		local i = 0 -- 600
		do -- 600
			i = 0 -- 601
			while i < #self.enemies do -- 601
				if self.enemies[i + 1].alive then -- 601
					alive = alive + 1 -- 603
				end -- 603
				i = i + 1 -- 601
			end -- 601
		end -- 601
		parts[#parts + 1] = (("敌 " .. tostring(alive)) .. "/") .. tostring(#self.enemies) -- 606
	end -- 606
	if self.checkpoint >= 0 then -- 606
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 609
	end -- 609
	if self.paused then -- 609
		parts[#parts + 1] = "已暂停" -- 612
	end -- 612
	return table.concat(parts, " · ") -- 614
end -- 583
function Play.prototype.hintText(self) -- 618
	if self.paused then -- 618
		return "Esc 继续 · R 重置" -- 620
	end -- 620
	if self.flash ~= "" then -- 620
		return self.flash -- 623
	end -- 623
	local isChild = self.room.key ~= "checkpoint" -- 625
	if isChild then -- 625
		if self.focusCart then -- 625
			return "按住 E + A/D 拉车（D3 接）" -- 628
		end -- 628
		return "A / D 走 · Shift 慢走 · 空格跳 · S 或 Ctrl 蹲下钻过拱洞" -- 630
	end -- 630
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下" -- 632
end -- 618
function Play.prototype.draw(self, draw, w, h) -- 637
	self.viewW = w -- 638
	self.viewH = h -- 639
	self.view = ____exports.computeViewport(w, h) -- 640
	self:clampCamera(w, h) -- 641
	draw:clear() -- 642
	draw:drawRect( -- 644
		Rect(0, 0, w, h), -- 644
		BG_VOID -- 644
	) -- 644
	local box = self:canvasRect(w, h) -- 645
	draw:drawRect(box, BG_FAR) -- 646
	draw:drawRect( -- 647
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 647
		BG_MID -- 647
	) -- 647
	self:drawFloors(draw, w, h) -- 649
	self:drawSolids(draw, w, h) -- 650
	self:drawZones(draw, w, h) -- 651
	self:drawArch(draw, w, h) -- 652
	self:drawCart(draw, w, h) -- 653
	self:drawActors(draw, w, h) -- 654
	self:drawTrace(draw, w, h) -- 655
	self:drawAim(draw, w, h) -- 656
end -- 637
function Play.prototype.canvasRect(self, w, h) -- 660
	local v = self.view -- 661
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 662
end -- 660
function Play.prototype.px(self, n) -- 666
	return n * self.view.zoom -- 667
end -- 666
function Play.prototype.sx(self, wx, w) -- 671
	local v = self.view -- 672
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 673
	return v.ox + lx * v.zoom -- 674
end -- 671
function Play.prototype.sy(self, wy, h) -- 678
	local v = self.view -- 679
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 680
	return v.oy + ly * v.zoom -- 681
end -- 678
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 684
	local px0 = self:sx(x0, w) -- 685
	local px1 = self:sx(x1, w) -- 686
	local py0 = self:sy(y0, h) -- 687
	local py1 = self:sy(y1, h) -- 688
	if px1 <= px0 or py1 <= py0 then -- 688
		return -- 690
	end -- 690
	draw:drawRect( -- 692
		Rect(px0, py0, px1 - px0, py1 - py0), -- 692
		color -- 692
	) -- 692
end -- 684
function Play.prototype.drawFloors(self, draw, w, h) -- 695
	local i = 0 -- 696
	do -- 696
		i = 0 -- 697
		while i < #self.room.floors do -- 697
			local f = self.room.floors[i + 1] -- 698
			local y = self:sy(f.y, h) -- 699
			local x0 = self:sx(f.x0, w) -- 700
			local x1 = self:sx(f.x1, w) -- 701
			local deck = self:px(5) -- 702
			draw:drawRect( -- 703
				Rect(x0, y - deck, x1 - x0, deck), -- 703
				FLOOR_DECK -- 703
			) -- 703
			draw:drawSegment( -- 704
				Vec2(x0, y), -- 704
				Vec2(x1, y), -- 704
				self:px(1), -- 704
				GROUND -- 704
			) -- 704
			i = i + 1 -- 697
		end -- 697
	end -- 697
end -- 695
function Play.prototype.drawSolids(self, draw, w, h) -- 708
	local i = 0 -- 709
	do -- 709
		i = 0 -- 710
		while i < #self.boxes do -- 710
			do -- 710
				local b = self.boxes[i + 1] -- 711
				if b.y0 < -4 and b.y1 <= 96 then -- 711
					draw:drawSegment( -- 714
						Vec2( -- 714
							self:sx(b.x0, w), -- 714
							self:sy(b.y1, h) -- 714
						), -- 714
						Vec2( -- 714
							self:sx(b.x1, w), -- 714
							self:sy(b.y1, h) -- 714
						), -- 714
						self:px(1), -- 714
						GROUND -- 714
					) -- 714
					goto __continue135 -- 715
				end -- 715
				self:drawBox( -- 717
					draw, -- 717
					w, -- 717
					h, -- 717
					b.x0, -- 717
					b.x1, -- 717
					b.y0, -- 717
					b.y1, -- 717
					SOLID_FILL -- 717
				) -- 717
				draw:drawSegment( -- 718
					Vec2( -- 718
						self:sx(b.x0, w), -- 718
						self:sy(b.y1, h) -- 718
					), -- 718
					Vec2( -- 718
						self:sx(b.x1, w), -- 718
						self:sy(b.y1, h) -- 718
					), -- 718
					self:px(1), -- 718
					SOLID_EDGE -- 718
				) -- 718
			end -- 718
			::__continue135:: -- 718
			i = i + 1 -- 710
		end -- 710
	end -- 710
end -- 708
function Play.prototype.drawZones(self, draw, w, h) -- 722
	local i = 0 -- 723
	do -- 723
		i = 0 -- 724
		while i < #self.room.zones do -- 724
			local z = self.room.zones[i + 1] -- 725
			self:drawBox( -- 726
				draw, -- 726
				w, -- 726
				h, -- 726
				z.x0, -- 726
				z.x1, -- 726
				z.y, -- 726
				z.y + z.h, -- 726
				DANGER -- 726
			) -- 726
			draw:drawSegment( -- 727
				Vec2( -- 727
					self:sx(z.x0, w), -- 727
					self:sy(z.y, h) -- 727
				), -- 727
				Vec2( -- 727
					self:sx(z.x0, w), -- 727
					self:sy(z.y + z.h, h) -- 727
				), -- 727
				self:px(1), -- 727
				DANGER_LINE -- 727
			) -- 727
			draw:drawSegment( -- 728
				Vec2( -- 728
					self:sx(z.x1, w), -- 728
					self:sy(z.y, h) -- 728
				), -- 728
				Vec2( -- 728
					self:sx(z.x1, w), -- 728
					self:sy(z.y + z.h, h) -- 728
				), -- 728
				self:px(1), -- 728
				DANGER_LINE -- 728
			) -- 728
			i = i + 1 -- 724
		end -- 724
	end -- 724
end -- 722
function Play.prototype.drawArch(self, draw, w, h) -- 732
	local a = self.room.arch -- 733
	if a.h <= 0 then -- 733
		return -- 735
	end -- 735
	self:drawBox( -- 737
		draw, -- 737
		w, -- 737
		h, -- 737
		a.x0, -- 737
		a.x1, -- 737
		a.y, -- 737
		a.y + a.h, -- 737
		HOLE_FILL -- 737
	) -- 737
	draw:drawSegment( -- 738
		Vec2( -- 738
			self:sx(a.x0, w), -- 738
			self:sy(a.y + a.h, h) -- 738
		), -- 738
		Vec2( -- 738
			self:sx(a.x1, w), -- 738
			self:sy(a.y + a.h, h) -- 738
		), -- 738
		self:px(1), -- 738
		SOLID_EDGE -- 738
	) -- 738
	draw:drawSegment( -- 739
		Vec2( -- 739
			self:sx(a.x0, w), -- 739
			self:sy(a.y, h) -- 739
		), -- 739
		Vec2( -- 739
			self:sx(a.x0, w), -- 739
			self:sy(a.y + a.h, h) -- 739
		), -- 739
		self:px(1), -- 739
		SOLID_EDGE -- 739
	) -- 739
	draw:drawSegment( -- 740
		Vec2( -- 740
			self:sx(a.x1, w), -- 740
			self:sy(a.y, h) -- 740
		), -- 740
		Vec2( -- 740
			self:sx(a.x1, w), -- 740
			self:sy(a.y + a.h, h) -- 740
		), -- 740
		self:px(1), -- 740
		SOLID_EDGE -- 740
	) -- 740
end -- 732
function Play.prototype.drawCart(self, draw, w, h) -- 743
	local c = self.room.cart -- 744
	drawCartShape( -- 745
		draw, -- 745
		self, -- 745
		w, -- 745
		h, -- 745
		c, -- 745
		c.startX -- 745
	) -- 745
	draw:drawRect( -- 746
		Rect( -- 746
			self:sx(c.startX + c.handleOffset, w) - self:px(1), -- 746
			self:sy(c.baseY + 40, h), -- 746
			self:px(2), -- 746
			self:px(40) -- 746
		), -- 746
		STAND -- 746
	) -- 746
end -- 743
function Play.prototype.drawActors(self, draw, w, h) -- 749
	local p = self.player -- 750
	local isChild = self.room.key ~= "checkpoint" -- 751
	drawFigure( -- 752
		draw, -- 752
		self, -- 752
		w, -- 752
		h, -- 752
		p, -- 752
		isChild and CHILD_BODY or SOLDIER_BODY, -- 752
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 752
	) -- 752
	local q = self.partner -- 753
	if q.alive then -- 753
		local childPartner = q.w == CHILD_W -- 755
		drawFigure( -- 756
			draw, -- 756
			self, -- 756
			w, -- 756
			h, -- 756
			q, -- 756
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 756
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 756
		) -- 756
	end -- 756
	local i = 0 -- 758
	do -- 758
		i = 0 -- 759
		while i < #self.enemies do -- 759
			local e = self.enemies[i + 1] -- 760
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 761
			self:drawBox( -- 762
				draw, -- 762
				w, -- 762
				h, -- 762
				e.x - e.w / 2, -- 762
				e.x + e.w / 2, -- 762
				e.y, -- 762
				e.y + e.h, -- 762
				col -- 762
			) -- 762
			i = i + 1 -- 759
		end -- 759
	end -- 759
	local k = 0 -- 765
	do -- 765
		k = 0 -- 766
		while k < #self.room.marks do -- 766
			do -- 766
				local m = self.room.marks[k + 1] -- 767
				if m.kind ~= 0 then -- 767
					goto __continue148 -- 769
				end -- 769
				local on = self.checkpoint == m.x -- 771
				local x = self:sx(m.x, w) -- 772
				local y = self:sy(m.y, h) -- 773
				draw:drawSegment( -- 774
					Vec2(x, y), -- 774
					Vec2( -- 774
						x, -- 774
						y + self:px(35) -- 774
					), -- 774
					self:px(1), -- 774
					on and CHECK or INK_DIM -- 774
				) -- 774
				draw:drawDot( -- 775
					Vec2( -- 775
						x, -- 775
						y + self:px(35) -- 775
					), -- 775
					self:px(2), -- 775
					on and CHECK or INK_DIM -- 775
				) -- 775
			end -- 775
			::__continue148:: -- 775
			k = k + 1 -- 766
		end -- 766
	end -- 766
end -- 749
function Play.prototype.drawTrace(self, draw, w, h) -- 779
	local t = self.trace -- 780
	if t == nil or self.traceT <= 0 then -- 780
		return -- 782
	end -- 782
	draw:drawSegment( -- 784
		Vec2( -- 785
			self:sx(t.x0, w), -- 785
			self:sy(t.y0, h) -- 785
		), -- 785
		Vec2( -- 786
			self:sx(t.x1, w), -- 786
			self:sy(t.y1, h) -- 786
		), -- 786
		self:px(1), -- 787
		t.hit and AIM_HIT or INK_DIM -- 787
	) -- 787
end -- 779
function Play.prototype.drawAim(self, draw, w, h) -- 790
	local v = self.view -- 792
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 793
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 794
	local dot = self:px(1) -- 795
	local arm = self:px(3) -- 796
	local gap = self:px(1) -- 797
	draw:drawSegment( -- 798
		Vec2(gx - arm - gap, gy), -- 798
		Vec2(gx - gap, gy), -- 798
		dot / 2, -- 798
		AIM -- 798
	) -- 798
	draw:drawSegment( -- 799
		Vec2(gx + gap, gy), -- 799
		Vec2(gx + arm + gap, gy), -- 799
		dot / 2, -- 799
		AIM -- 799
	) -- 799
	draw:drawSegment( -- 800
		Vec2(gx, gy - arm - gap), -- 800
		Vec2(gx, gy - gap), -- 800
		dot / 2, -- 800
		AIM -- 800
	) -- 800
	draw:drawSegment( -- 801
		Vec2(gx, gy + gap), -- 801
		Vec2(gx, gy + arm + gap), -- 801
		dot / 2, -- 801
		AIM -- 801
	) -- 801
end -- 790
return ____exports -- 790