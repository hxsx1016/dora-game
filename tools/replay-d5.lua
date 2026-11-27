-- 守望 D5 整链逐拍回放
--
-- 用途：画面通道不可用时，用固定步长逐拍喂输入，从默认入口（序章倒柜后）
-- 沿实际切场一路跑到塔门尾声，打印每段关键坐标、车轴、守点拍数与交权输入。
--
-- 用法（引擎内）：dofile("tools/replay-d5.lua")
-- 前提：Script/watch/*.lua 已随 TS 构建同步；改完 TS 要先重启项目。

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
	i.retry = { held = false, pressed = false, released = false }
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

local function roomOf(key)
	local r = nil
	for _, v in ipairs(rooms.ROOMS) do
		if v.key == key then
			r = v
		end
	end
	return r
end

local function hop(p)
	local key = p.wantRoom
	if key == nil or key == "" then
		return p
	end
	p.wantRoom = ""
	local r = roomOf(key)
	if r == nil then
		print("!! 找不到房间 " .. tostring(key))
		return p
	end
	return lualib.__TS__New(play.Play, r)
end

-- 一直向右走，卡住就自动起跳，直到 cond 成立或超步数。
local function push(p, i, cond, limit)
	i.moveX = 1
	local guard = 0
	local last = p.player.x
	local stall = 0
	while not cond() and guard < (limit or 1600) do
		if p.player.x - last < 0.4 then
			stall = stall + 1
		else
			stall = 0
		end
		last = p.player.x
		if stall >= 3 and p.player.onGround and not i.crouch.held then
			tap(i.jump)
			p:update(STEP, i)
			rel(i.jump)
			stall = 0
		else
			p:update(STEP, i)
		end
		guard = guard + 1
	end
	i.moveX = 0
	return guard
end

local function walkTo(p, i, x, limit)
	i.moveX = x > p.player.x and 1 or -1
	local guard = 0
	while math.abs(p.player.x - x) > 2 and guard < (limit or 1200) do
		p:update(STEP, i)
		guard = guard + 1
	end
	i.moveX = 0
	return guard
end

local function show(tag, p)
	local pt = p.partner
	print(string.format(
		"%-14s p=%6.1f/%5.1f pt=%6.1f/%5.1f axle=%6.1f phase=%-12s want=%s",
		tag, p.player.x, p.player.y,
		pt and pt.x or -1, pt and pt.y or -1,
		p.cartAxle, tostring(p.phase), tostring(p.wantRoom)))
end

print("==== D5 整链回放 · 从序章默认入口开始 ====")
local i = newInput()
local p = lualib.__TS__New(play.Play, rooms.PROLOGUE_ROOM)
show("P0 出生", p)

-- 1) 序章：绕过石柱和倒柜，靠近小满递针套，两人出门
i.moveY = -1
for _ = 1, 16 do
	p:update(STEP, i)
end
i.moveY = 0
walkTo(p, i, 270, 400)
i.moveY = 1
for _ = 1, 12 do
	p:update(STEP, i)
end
i.moveY = 0
show("P1 走近", p)
tap(i.interact)
p:update(STEP, i)
rel(i.interact)
print(string.format("P2 递物 phase=%s tick=%s", tostring(p.phase), tostring(p.phaseTick)))
assert(p.phase == "prologue-give", "绕过石柱并在纵深上靠近以后应当能递针套")
for _ = 1, 62 do
	p:update(STEP, i)
end
print(string.format("P3 递完 phase=%s 小满crouch=%s", p.phase, tostring(p.partner.crouch)))
i.moveX = 1
local guard = 0
while p.wantRoom == "" and guard < 900 do
	p:update(STEP, i)
	guard = guard + 1
end
i.moveX = 0
show("P4 到门口", p)
p = hop(p)
show("S0 街道", p)

-- 2) 街道：走到有射界的位置，用 Input.fire + 准星（aimAt）逐枪清敌
walkTo(p, i, 240, 400)
p.view = { zoom = 1, ox = 0, oy = 0 }
p.viewW = 320
p.viewH = 180
local shootGuard = 0
while p:aliveEnemies() > 0 and shootGuard < 16 do
	local target = nil
	for _, e in ipairs(p.enemies) do
		if e.alive then
			target = e
		end
	end
	if target == nil then
		break
	end
	-- aimAt 只把世界坐标换成准星坐标；真正的开枪走 stepPlayer 里的 fire.pressed
	p:aimAt(target.x, target.y + 42)
	tap(i.fire)
	p:update(STEP, i)
	rel(i.fire)
	shootGuard = shootGuard + 1
end
print(string.format("S1 清敌 alive=%d 枪=%d", p:aliveEnemies(), shootGuard))
guard = push(p, i, function() return p.wantRoom ~= "" end, 1200)
show("S2 到入口", p)
p = hop(p)
show("K0 检查站", p)

-- 3) 检查站：队栏 → 翻柜 → 推车 → 双人出口
guard = push(p, i, function() return p.player.x >= 1235 end, 1400)
show("K1 过柜", p)
show("K2 到车", p)
tap(i.interact)
p:update(STEP, i)
i.interact.pressed = false -- 保持按住 E
i.moveX = 1
guard = 0
while not p.cartDocked and guard < 600 do
	p:update(STEP, i)
	guard = guard + 1
end
i.interact.held = false
i.moveX = 0
show("K3 车落窝", p)
-- 两人到出口区
guard = push(p, i, function() return p.player.x >= 1500 end, 900)
-- 玩家停住，等小满走进出口区
for _ = 1, 300 do
	p:update(STEP, i)
end
print(string.format("K4 gate=%s 两人=%.1f/%.1f", tostring(p.gateOpen), p.player.x, p.partner.x))
guard = push(p, i, function() return p.wantRoom ~= "" end, 500)
show("K5 出门", p)
p = hop(p)

-- 4) 城门：小满自动到门洞，周戍回绞盘，守 45 秒
show("G0 城门", p)
guard = push(p, i, function() return p.player.x >= 118 end, 400) -- 绞盘右侧就位
print(string.format("G1 周戍到绞盘 x=%.1f 小满=%.1f phase=%s", p.player.x, p.partner.x, p.phase))
guard = 0
while p.phase == "gate-idle" and guard < 1400 do
	p:update(STEP, i)
	guard = guard + 1
end
print(string.format("G2 就位 phase=%s gateTick=%d 小满=%.1f", p.phase, p.gateTick, p.partner.x))

-- 绞盘 130 的射界被街垒挡死，得前出到 505 才有射线；守点期间还得压制四批敌兵
i.moveX = 1
guard = 0
while p.player.x < 505 and guard < 400 do
	p:update(STEP, i)
	guard = guard + 1
end
i.moveX = 0
print(string.format("G2b 前出街垒 x=%.1f 血=%d", p.player.x, p.hp))

-- 守到 44 秒（2640 拍），途中用准星 + fire 清敌，暂停 5 秒再恢复
guard = 0
while p.gateTick < 2640 and guard < 5000 do
	if guard % 12 == 0 then
		local target = nil
		for _, e in ipairs(p.enemies) do
			if e.alive then
				target = e
				break
			end
		end
		if target ~= nil then
			p:aimAt(target.x, target.y + 42)
			tap(i.fire)
			p:update(STEP, i)
			rel(i.fire)
		else
			p:update(STEP, i)
		end
	else
		p:update(STEP, i)
	end
	guard = guard + 1
end
print(string.format("G3 44秒 gateTick=%d 敌=%d 血=%d 倒=%d", p.gateTick, p:aliveEnemies(), p.hp, p.gateFailCount))
tap(i.pause)
p:update(STEP, i)
rel(i.pause)
print(string.format("G4 暂停 paused=%s gateTick=%d", tostring(p.paused), p.gateTick))
for _ = 1, 300 do
	p:update(STEP, i)
end
print(string.format("G5 暂停5秒后 gateTick=%d", p.gateTick))
tap(i.pause)
p:update(STEP, i)
rel(i.pause)
print(string.format("G6 恢复 paused=%s gateTick=%d 还差=%d", tostring(p.paused), p.gateTick, 2700 - p.gateTick))
guard = 0
while p.gateTick < 2700 and guard < 200 do
	p:update(STEP, i)
	guard = guard + 1
end
print(string.format("G7 守满 phase=%s gateTick=%d", p.phase, p.gateTick))

-- 送别：按住 D 走到门边（途中翻街垒），按 E（此时 D 仍按着，测交权）
i.moveX = 1
guard = 0
local stuckG = 0
while p.player.x < 855 and guard < 1500 do
	if p.player.onGround and p.player.x < 640 then
		stuckG = stuckG + 1
		if stuckG >= 4 then
			tap(i.jump)
			stuckG = 0
		end
	else
		stuckG = 0
	end
	p:update(STEP, i)
	rel(i.jump)
	guard = guard + 1
end
i.moveX = 0
print(string.format("G8 到门边 x=%.1f", p.player.x))
tap(i.interact)
p:update(STEP, i)
rel(i.interact)
print(string.format("G9 交换 phase=%s 小满=%.1f armed=%s", p.phase, p.player.x, tostring(p.countArmed)))

-- 数数：D 一直按着，到 24 秒也不该迈步
guard = 0
while p.countTick < 1500 and guard < 1600 do
	p:update(STEP, i)
	guard = guard + 1
end
print(string.format("C0 按住D到1500拍 phase=%s x=%.1f armed=%s", p.phase, p.player.x, tostring(p.countArmed)))
i.moveX = 0
p:update(STEP, i)
print(string.format("C1 松开一拍 phase=%s armed=%s", p.phase, tostring(p.countArmed)))
i.moveX = 1
for _ = 1, 6 do
	p:update(STEP, i)
end
print(string.format("C2 新按D phase=%s x=%.1f", p.phase, p.player.x))
guard = push(p, i, function() return p.wantRoom ~= "" end, 700)
show("C3 出城门", p)
p = hop(p)

-- 5) 城外：拉车、蹲过拱、走到墙根尽头
show("O0 城外", p)
guard = push(p, i, function() return p.player.x >= 340 end, 500)
tap(i.interact)
p:update(STEP, i)
i.interact.pressed = false -- 保持按住 E
print(string.format("O1 抓车把 grip=%s axle=%.1f", tostring(p.gripping), p.cartAxle))
i.moveX = 1
guard = 0
while not p.cartDocked and guard < 600 do
	p:update(STEP, i)
	guard = guard + 1
end
i.interact.held = false
i.moveX = 0
show("O2 落窝", p)
-- 下阶：先回台面左端再下去
walkTo(p, i, 150, 600)
walkTo(p, i, 54, 600)
print(string.format("O3 下阶 p=%.1f/%.1f", p.player.x, p.player.y))
i.crouch.held = true
walkTo(p, i, 392, 900)
i.crouch.held = false
print(string.format("O4 蹲穿拱 p=%.1f/%.1f cp=%s", p.player.x, p.player.y, tostring(p.checkpoint)))
guard = push(p, i, function() return p.wantRoom ~= "" end, 1600)
show("O5 进村", p)
p = hop(p)

-- 6) 村口：先站着靠近，测一次被抓重试；再蹲行通过
show("V0 村口", p)
-- 先站着走到 430 停住，让他看见并追上来（跑是跑得掉的，但他要够近才抓得到）
guard = push(p, i, function() return p.player.x >= 430 end, 400)
guard = 0
while p.caughtT <= 0 and guard < 500 do
	p:update(STEP, i)
	guard = guard + 1
end
print(string.format("V1 被抓 caughtT=%.2f x=%.1f 拾荒者=%s@%.1f see=%d chase=%s passed=%s",
	p.caughtT, p.player.x, tostring(p.scavState), p.scavX, p.scavSee, tostring(p.scavChase), tostring(p.passed)))
for _ = 1, 70 do
	p:update(STEP, i)
end
print(string.format("V2 复位 x=%.1f 拾荒者=%.1f", p.player.x, p.scavX))
-- 拾瓶：复位点 142 在瓶架 112 右边，往左走几步
i.moveX = -1
for _ = 1, 24 do
	p:update(STEP, i)
end
i.moveX = 0
tap(i.interact)
p:update(STEP, i)
rel(i.interact)
print(string.format("V3 拾瓶 has=%s", tostring(p.hasBottle)))
-- 按住 F 瞄向砖地 608，攒到 40 拍再松手投
p:aimAt(p.brickX or 608, 34)
i.aim.held = true
for _ = 1, 40 do
	p:update(STEP, i)
end
print(string.format("V4 瞄住 aimHold=%.2f 有瓶=%s", p.aimHold, tostring(p.hasBottle)))
i.aim.held = false
i.aim.released = true
p:update(STEP, i)
rel(i.aim)
print(string.format("V5 出手 飞行=%s 拾荒者=%s@%.1f", tostring(p.bottleFly ~= nil), tostring(p.scavState), p.scavX))
-- 等瓶子触地发声
guard = 0
while p.bottleLandX < 0 and guard < 300 do
	p:update(STEP, i)
	guard = guard + 1
end
print(string.format("V6 落地 landX=%.1f 拾荒者=%s@%.1f", p.bottleLandX, tostring(p.scavState), p.scavX))
-- 等他真正转头走开（walk → stall 后走远），再钻桌
guard = 0
while p.scavState ~= "walk" and p.scavState ~= "stall" and guard < 600 do
	p:update(STEP, i)
	guard = guard + 1
end
print(string.format("V7 他走了 状态=%s@%.1f 等=%d拍", tostring(p.scavState), p.scavX, guard))
guard = 0
while p.scavX < 580 and guard < 600 do
	p:update(STEP, i)
	guard = guard + 1
end
print(string.format("V8 让开桌下 拾荒者=%.1f 等=%d拍", p.scavX, guard))
-- 蹲行穿过桌下到 460
i.crouch.held = true
walkTo(p, i, 460, 900)
i.crouch.held = false
print(string.format("V9 过桌 x=%.1f passed=%s", p.player.x, tostring(p.passed)))
-- 钻出桌后立刻冲向 640 切线；被追就贴着地面跑，别停
guard = push(p, i, function() return p.wantRoom ~= "" end, 800)
print(string.format("V9b 冲线 x=%.1f caught=%.2f 拾荒者=%s@%.1f want=%s",
	p.player.x, p.caughtT, tostring(p.scavState), p.scavX, tostring(p.wantRoom)))
show("V5 出村", p)
p = hop(p)

-- 7) 森林：狗先抓一次；再蹲行到林缘
show("F0 森林", p)
local guardF = push(p, i, function() return p.caughtT > 0 end, 900)
print(string.format("F1 被狗抓 拍=%d caughtT=%.2f dogX=%.1f dogState=%s x=%.1f",
	guardF, p.caughtT, p.dogX, tostring(p.dogState), p.player.x))
for _ = 1, 70 do
	p:update(STEP, i)
end
print(string.format("F2 复位 x=%.1f dog=%.1f", p.player.x, p.dogX))
i.crouch.held = true
guard = push(p, i, function() return p.wantRoom ~= "" end, 2200)
i.crouch.held = false
show("F3 到林缘", p)
p = hop(p)

-- 8) 塔门：一次 E 敲两下，递交，空行，片尾再玩
show("T0 塔门", p)
guard = push(p, i, function() return math.abs(p.player.x - 445) <= 3 end, 800)
tap(i.interact)
p:update(STEP, i)
rel(i.interact)
print(string.format("T1 敲一下 phase=%s knocks=%d", p.phase, p.knocks))
for _ = 1, 40 do
	p:update(STEP, i)
end
print(string.format("T2 两声后 phase=%s knocks=%d", p.phase, p.knocks))
for _ = 1, 200 do
	p:update(STEP, i)
end
print(string.format("T3 片尾 phase=%s", p.phase))
for _ = 241, play.TOWER_CONFIRM_TICKS do p:update(STEP, i) end
tap(i.interact)
p:update(STEP, i)
rel(i.interact)
print(string.format("T4 再玩 want=%s", p.wantRoom))
p = hop(p)
show("T5 回序章", p)
print("==== 回放结束 ====")
