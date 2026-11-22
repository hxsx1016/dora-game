-- 守望 D4 整链逐拍回放
--
-- 用途：画面通道不可用时，用固定步长逐拍喂输入，从默认出生点跑到村口第一院，
-- 打印每段关键坐标与车轴读数，供和真实键鼠连玩对照。
--
-- 用法（引擎内）：dofile("tools/replay-d4.lua")
-- 前提：Script/watch/*.lua 已随 TS 构建同步；改完 TS 要先重启项目。
--
-- 说明：每“拍”就是一个固定模拟步（1/60 秒），输入表按下文逐拍给出；
-- 与 app.ts 的输入锁存一致——按下只在这一拍有效，持续态每拍可读。

local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local input = require("Script.watch.input")
local lualib = require("lualib_bundle")
local STEP = play.STEP

local function newInput()
	local i = lualib.__TS__New(input.Input)
	i.moveX = 0
	i.moveY = 0
	i.jump = { held = false, pressed = false, released = false }
	i.crouch = { held = false, pressed = false, released = false }
	i.cover = { held = false, pressed = false, released = false }
	i.interact = { held = false, pressed = false, released = false }
	i.aim = { held = false, pressed = false, released = false }
	i.fire = { held = false, pressed = false, released = false }
	i.pause = { held = false, pressed = false, released = false }
	return i
end

local function tap(k)
	k.held = true
	k.pressed = true
	k.released = false
end

local function rel(k)
	k.held = false
	k.pressed = false
	k.released = false
end

local function step(p, i, n)
	local k = 1
	while k <= n do
		p:update(STEP, i)
		k = k + 1
	end
end

local function show(tag, p)
	local pt = p.partner
	print(
		string.format(
			"%-16s p=%6.1f/%5.1f pt=%6.1f/%5.1f axle=%6.1f dock=%-5s gate=%-5s cp=%-4s want=%s",
			tag,
			p.player.x,
			p.player.y,
			pt and pt.x or -1,
			pt and pt.y or -1,
			p.cartAxle,
			tostring(p.cartDocked),
			tostring(p.gateOpen),
			tostring(p.checkpoint),
			p.wantRoom
		)
	)
end

print("== 检查站 · 队栏 → 柜台 → 车队 → 双人出口 ==")
local i = newInput()
local p = lualib.__TS__New(play.Play, rooms.CHECKPOINT_ROOM)
show("K0 出生", p)

-- 1) 右走到队栏前
i.moveX = 1
local guard = 0
while p.player.x < 205 and guard < 300 do
	p:update(STEP, i)
	guard = guard + 1
end
show("K1 队栏前", p)

-- 2) 空格翻队栏（28 高，周戍贴矮台改跳）
tap(i.jump)
	p:update(STEP, i)
	rel(i.jump)
	step(p, i, 120)
	show("K2 翻过队栏", p)

	-- 3) 右走到柜台前
	guard = 0
	while p.player.x < 870 and guard < 400 do
		p:update(STEP, i)
		guard = guard + 1
	end
	show("K3 柜台前", p)

	-- 4) 翻柜台（44 高）
	tap(i.jump)
	p:update(STEP, i)
	rel(i.jump)
	step(p, i, 90)
	show("K4 翻过柜台", p)

	-- 5) 走到左柄（车轴 1280 − 40 = 1240）
	guard = 0
	while p.player.x < 1243 and guard < 400 do
		p:update(STEP, i)
		guard = guard + 1
	end
	show("K5 车柄旁", p)

	-- 6) E 抓手 → 按住 D 推到落窝
	tap(i.interact)
	p:update(STEP, i)
	i.interact = { held = true, pressed = false, released = false }
	i.moveX = 1
	guard = 0
	while not p.cartDocked and guard < 400 do
		p:update(STEP, i)
		guard = guard + 1
	end
	i.moveX = 0
	rel(i.interact)
	show("K6 车轮落窝", p)

	-- 7) 两人进双人出口（792+640=1432 … 928+640=1568）
	guard = 0
	while p.wantRoom == "" and p.player.x < 1540 and guard < 500 do
		i.moveX = 1
		p:update(STEP, i)
		guard = guard + 1
	end
	show("K7 双人出口", p)

	print("")
	print("== 城外 · 拉车 → 下阶 → 蹲过拱洞 → 墙根小路 ==")
	local j = newInput()
	local q = lualib.__TS__New(play.Play, rooms.OUTSIDE_ROOM)
	show("O0 出生", q)

	-- 1) 站在上层走到右柄（304 + 40 = 344）；拱顶不再拦 96 高的脚底
	guard = 0
	while q.player.x < 344 and guard < 300 do
		j.moveX = 1
		q:update(STEP, j)
		guard = guard + 1
	end
	show("O1 右柄旁", q)

	-- 2) E 抓手 → 按住 D 拉到 432 落窝
	tap(j.interact)
	q:update(STEP, j)
	j.interact = { held = true, pressed = false, released = false }
	j.moveX = 1
	guard = 0
	while not q.cartDocked and guard < 400 do
		q:update(STEP, j)
		guard = guard + 1
	end
	j.moveX = 0
	rel(j.interact)
	show("O2 车轮落窝", q)

	-- 3) 向左走下石阶（128→40，三级）
	guard = 0
	while not (q.player.y == 0 and q.player.x < 60) and guard < 400 do
		j.moveX = -1
		q:update(STEP, j)
		guard = guard + 1
	end
	show("O3 落到地面", q)

	-- 4) 蹲下穿 44 矮拱，洞后提交检查点 380
	j.crouch = { held = true, pressed = false, released = false }
	guard = 0
	while q.player.x < 396 and guard < 400 do
		j.moveX = 1
		q:update(STEP, j)
		guard = guard + 1
	end
	show("O4 钻过拱洞", q)

	-- 5) 蹲着钻过落窝车身（408–456）
	guard = 0
	while q.player.x < 475 and guard < 300 do
		j.moveX = 1
		q:update(STEP, j)
		guard = guard + 1
	end
	show("O5 钻过车底", q)

	-- 6) 站起，走墙根小路；石阶自动抬脚（0→21→43→64），940 后落回地面
	j.crouch = { held = false, pressed = false, released = false }
	guard = 0
	while q.wantRoom == "" and q.player.x < 1170 and guard < 800 do
		j.moveX = 1
		q:update(STEP, j)
		guard = guard + 1
	end
	show("O6 墙根尽头", q)

	print("")
	print("== 城外 · 洞后按 R 重试 ==")
	local r = lualib.__TS__New(play.Play, rooms.OUTSIDE_ROOM, { checkpoint = 380 })
	local ri = newInput()
	show("R1 重试恢复", r)
	step(r, ri, 60)
	show("R2 松键 60 拍", r)
	ri.moveX = 1
	step(r, ri, 20)
	show("R3 跨过 388", r)
	ri.crouch = { held = true, pressed = false, released = false }
	guard = 0
	while r.wantRoom == "" and r.player.x < 1170 and guard < 800 do
		r:update(STEP, ri)
		guard = guard + 1
	end
	show("R4 墙根尽头", r)

	print("")
	print("== 村口 · 拾瓶 → 松 F 投砖地 → 趁转头钻桌 ==")
	local v = lualib.__TS__New(play.Play, rooms.VILLAGE_ROOM)
	v.view = { zoom = 1, ox = 0, oy = 0 }
	local vi = newInput()
	print(string.format("V0 出生          p=%6.1f/%5.1f scav=%.1f/%s", v.player.x, v.player.y, v.scavX, v.scavState))

	-- 1) 走到瓶架旁拾瓶
	guard = 0
	while v.player.x > 130 and guard < 120 do
		vi.moveX = -1
		v:update(STEP, vi)
		guard = guard + 1
	end
	tap(vi.interact)
	v:update(STEP, vi)
	rel(vi.interact)
	print(string.format("V1 拾起瓶子      p=%6.1f hasBottle=%s", v.player.x, tostring(v.hasBottle)))

	-- 2) 按住 F 瞄砖地 608，松手投
	local function aimAt(wx, wy)
		v.aimX = (wx - v.cam.x) / 2 + 160
		v.aimY = (wy - v.cam.y) / 2 + 90
	end
	aimAt(608, 0)
	vi.aim = { held = true, pressed = true, released = false }
	v:update(STEP, vi)
	vi.aim = { held = true, pressed = false, released = false }
	v:update(STEP, vi)
	aimAt(608, 0)
	vi.aim = { held = false, pressed = false, released = true }
	v:update(STEP, vi)
	print(string.format("V2 松手投出      fly=%s scav=%.1f/%s", tostring(v.bottleFly ~= nil), v.scavX, v.scavState))

	-- 3) 等瓶子落地（触地才发声）
	guard = 0
	while v.bottleFly ~= nil and guard < 90 do
		vi.aim = { held = false, pressed = false, released = false }
		v:update(STEP, vi)
		guard = guard + 1
	end
	print(string.format("V3 瓶子触地      landX=%.1f scav=%.1f/%s", v.bottleLandX, v.scavX, v.scavState))

	-- 4) 蹲下往右钻桌（304–416，净高 44）
	vi.crouch = { held = true, pressed = false, released = false }
	vi.moveX = 1
	step(v, vi, 260)
	print(
		string.format(
			"V4 钻过桌下      p=%6.1f crouch=%s passed=%s scav=%.1f/%s",
			v.player.x,
			tostring(v.player.crouch),
			tostring(v.passed),
			v.scavX,
			v.scavState
		)
	)

	-- 5) 站起走完第一院
	vi.crouch = { held = false, pressed = false, released = false }
	guard = 0
	while v.player.x < 500 and guard < 200 do
		v:update(STEP, vi)
		guard = guard + 1
	end
	print(string.format("V5 第一院        p=%6.1f passed=%s scav=%.1f/%s", v.player.x, tostring(v.passed), v.scavX, v.scavState))
