-- 守望 D6/D5 · 四项逻辑验收断言
--
-- 用法（引擎内）：dofile("tools/verify-d6.lua")
--
-- 1. 城门数数交权：只认 24 秒之后的「新按下」，1439 拍按住不放不算。
-- 2. 城门掩体：Shift 必须贴住街垒/柜台才挡枪，绞盘空地照吃。
-- 3. 守点第 2700 拍边界：最后一拍开火先于阶段切换结算。
-- 4. 投瓶：准星点就是实际落点，预览与触地同参数。

local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local input = require("Script.watch.input")
local lualib = require("lualib_bundle")

local pass = 0
local fail = 0

local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS  %-22s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL  %-22s %s", tag, detail or ""))
	end
end

do
	local previous = 1
	local continuous = true
	for tick = 0, play.GATE_COUNT_END do
		local current = play.gateCountAtTick(tick)
		continuous = continuous and current >= previous and current <= previous + 1
		previous = current
	end
	check("风台连续数到二十", continuous and play.gateCountAtTick(0) == 1 and previous == 20)
	check("十八贴门，十九停息", play.gateCountAtTick(1080) == 18 and play.gateCountAtTick(1260) == 19)
	check("末拍才到二十", play.gateCountAtTick(1439) == 19 and play.gateCountAtTick(1500) == 20)
end

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
	i.retry = { held = false, pressed = false, released = false }
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

local function step(p, i, dt)
	p:update(dt or play.STEP, i)
	i.interact.pressed = false
	i.interact.released = false
	i.fire.pressed = false
	i.aim.released = false
	i.jump.pressed = false
end

-- 把城门摆成「已就位、守点刚开始」的状态。
local function gateHold(hp)
	local p = lualib.__TS__New(play.Play, rooms.GATE_ROOM)
	local i = newInput()
	p.phase = "gate-hold"
	p.gateTick = 1
	p.gateSpawned = 4 -- 不再按秒数出场，测试自己放敌兵
	-- B1 默认 2/3：送别按 E 锁的是女主线，数数边沿用例保持原语义。
	p.hp = hp or 2
	p.maxHp = 3
	p.storyRoute = ""
	return p, i
end

local function putEnemy(p, x, warnT)
	local e = { x = x, y = 0, w = 26, h = 84, alive = true, hitT = 0, warnT = warnT or 0, fireCd = 0 }
	table.insert(p.enemies, e)
	return e
end

-- 走到送别并把控制权交给小满。
local function toCount(p, i)
	local g = p.room.story.gate
	-- B1：门洞送别按 E 才锁线。这组用例只测数数边沿，固定 2/3 血走女主线。
	p.hp = 2
	p.maxHp = 3
	p.phase = "gate-send"
	p.player.x = g.doorX
	p.player.y = 0
	p.partner.x = g.doorX + 30
	p.partner.y = 0
	step(p, i)
	tap(i.interact)
	step(p, i)
	rel(i.interact)
	step(p, i)
end

print("==== D6/D5 四项逻辑验收 ====")

-- ---------------------------------------------------------------- 1. 数数交权
-- 用例 A：送别时就按住 D，一直到 1500 拍都不该迈步；松开再按才走。
do
	local p, i = gateHold(2)
	p.partner.x = p.room.story.gate.doorX + 30
	-- 先按住 D，再进数数（模拟「送别前就按着」）
	i.moveX = 1
	p.phase = "gate-send"
	p.player.x = p.room.story.gate.doorX
	step(p, i)
	tap(i.interact)
	step(p, i)
	rel(i.interact)
	step(p, i)
	check("A1 进数数", p.phase == "gate-count", "phase=" .. tostring(p.phase))
	local held = 0
	while held < 1500 do
		i.moveX = 1
		step(p, i)
		held = held + 1
	end
	check("A2 一直按住不走", p.phase == "gate-count" and p.countTick >= 1500,
		string.format("phase=%s tick=%d x=%.1f", tostring(p.phase), p.countTick, p.player.x))
	i.moveX = 0
	step(p, i)
	check("A3 松开一拍仍不走", p.phase == "gate-count", "phase=" .. tostring(p.phase))
	i.moveX = 1
	step(p, i)
	check("A4 松开后再按才走", p.phase == "gate-walk", "phase=" .. tostring(p.phase))
end

-- 用例 B：第 1439 拍按下并保持到 1440 —— 不算「24 秒后新按」。
do
	local p, i = gateHold(2)
	p.partner.x = p.room.story.gate.doorX + 30
	toCount(p, i)
	while p.countTick < 1438 do
		i.moveX = 0
		step(p, i)
	end
	-- 1439 拍按下
	i.moveX = 1
	step(p, i)
	check("B1 1439 按在数数里", p.countTick == 1439 and p.phase == "gate-count",
		string.format("tick=%d phase=%s", p.countTick, tostring(p.phase)))
	-- 保持到 1440、1450
	local k = 0
	while k < 12 do
		i.moveX = 1
		step(p, i)
		k = k + 1
	end
	check("B2 保持到 1440 不走", p.phase == "gate-count" and p.countTick >= 1440 and p.player.x < p.room.story.gate.doorX + 40,
		string.format("tick=%d phase=%s x=%.1f", p.countTick, tostring(p.phase), p.player.x))
	i.moveX = 0
	step(p, i)
	i.moveX = 1
	step(p, i)
	check("B3 松开再按才走", p.phase == "gate-walk", "phase=" .. tostring(p.phase))
end

-- 用例 C：空手等到 1440，第一次按 D 就是新按。
do
	local p, i = gateHold(2)
	p.partner.x = p.room.story.gate.doorX + 30
	toCount(p, i)
	while p.countTick < 1440 do
		i.moveX = 0
		step(p, i)
	end
	check("C1 空手到 1440", p.countTick >= 1440 and p.phase == "gate-count",
		string.format("tick=%d", p.countTick))
	i.moveX = 1
	step(p, i)
	check("C2 1440 后新按即走", p.phase == "gate-walk", "phase=" .. tostring(p.phase))
end

-- ---------------------------------------------------------------- 2. 掩体
-- 三站位：绞盘空地、街垒边缘（距左沿 15）、贴住街垒。
local function coverCase(name, x, holdShift, expectLoss)
	local p, i = gateHold(3)
	p.player.x = p.ox + x
	p.player.y = 0
	putEnemy(p, 620, 0)
	i.cover.held = holdShift
	local lost = 0
	local last = p.hp
	local k = 0
	while k < 200 do
		step(p, i)
		if p.hp < last then
			lost = lost + (last - p.hp)
			last = p.hp
		end
		k = k + 1
	end
	check(name, (lost > 0) == expectLoss,
		string.format("x=%d shift=%s 掉血=%d 血=%d 贴=%s", x, tostring(holdShift), lost, p.hp, tostring(p.player.covered)))
end

coverCase("D1 绞盘空地按 Shift", 130, true, true)
coverCase("D2 街垒边缘按 Shift", 505, true, false)
coverCase("D3 贴住街垒按 Shift", 512, true, false)
coverCase("D4 贴街垒不按 Shift", 512, false, true)

-- ---------------------------------------------------------------- 3. 2700 边界
-- 成功侧：最后一拍敌兵开火被掩体挡下，随后进送别。
do
	local p, i = gateHold(1)
	p.player.x = p.ox + 512
	p.player.y = 0
	p.gateTick = 2699
	putEnemy(p, 620, 1) -- 下一拍开火
	i.cover.held = true
	step(p, i)
	check("E1 最后一拍活下来并守满", p.phase == "gate-send" and p.gateFailCount == 0 and p.hp == 1,
		string.format("phase=%s tick=%d 血=%d 倒=%d 敌=%d", tostring(p.phase), p.gateTick, p.hp, p.gateFailCount, #p.enemies))
end

-- 失败侧：同一拍没掩体、1 格血，应当先被击倒，绝不进送别。
do
	local p, i = gateHold(1)
	p.player.x = p.ox + 130
	p.player.y = 0
	p.gateTick = 2699
	putEnemy(p, 620, 1)
	step(p, i)
	-- 失败后回 gate-idle：计时归零、敌兵清空，要玩家重新贴住绞盘才开始。
	check("E2 最后一拍被打倒优先", p.phase == "gate-idle" and p.gateFailCount == 1 and p.gateTick == 0 and #p.enemies == 0 and p.hp == p.maxHp,
		string.format("phase=%s tick=%d 倒=%d 敌=%d 血=%d", tostring(p.phase), p.gateTick, p.gateFailCount, #p.enemies, p.hp))
	check("E3 失败不切场", p.wantRoom == "", "want=" .. tostring(p.wantRoom))
	-- 回绞盘站位 118，玩家不动就不会自动开下一轮：这正是「倒地重开」要的停顿。
	local idleX = p.player.x
	for _ = 1, 30 do
		step(p, i)
	end
	check("E4 倒地后等玩家按 E", p.phase == "gate-idle" and p.gateTick == 0 and p.gateNeedConfirm == true and math.abs(p.player.x - (p.ox + 118)) < 1,
		string.format("phase=%s tick=%d 待确认=%s x=%.1f", tostring(p.phase), p.gateTick, tostring(p.gateNeedConfirm), p.player.x))
	-- 站对了但不按 E 就不开；按 E 才重新就位。
	i.interact.pressed = true
	step(p, i)
	check("E5 按 E 才重新就位", p.phase == "gate-hold" and p.gateTick <= 1 and p.gateNeedConfirm == false,
		string.format("phase=%s tick=%d 待确认=%s", tostring(p.phase), p.gateTick, tostring(p.gateNeedConfirm)))
end

-- ---------------------------------------------------------------- 4. 投瓶落点
local function throwCase(name, targetX, targetY)
	local p = lualib.__TS__New(play.Play, rooms.VILLAGE_ROOM)
	local i = newInput()
	-- 走到瓶架前拾瓶（瓶架 96–128，拾取半径 56）
	p.player.x = 130
	p.player.y = 0
	p.hasBottle = true
	p:aimAt(targetX, targetY)
	-- 先让相机站定，再在同一拍里取预览并投出：两者用同一 cam，才谈得上「一致」。
	local warm = 0
	while warm < 8 do
		step(p, i)
		warm = warm + 1
	end
	p.hasBottle = true
	p:aimAt(targetX, targetY)
	-- 按住一段时间（>0.12 秒）才算瞄准，松手才投。
	i.aim.held = true
	local hold = 0
	while hold < 10 do
		step(p, i)
		hold = hold + 1
	end
	-- 预览点取「按住 F 时缓存的那个数」，这才是玩家在屏幕上看到的终点。
	local prev = { x = p.bottleAimX, y = p.bottleAimY }
	i.aim.held = false
	i.aim.released = true
	step(p, i)
	local steps = 0
	while p.bottleFly ~= nil and steps < 200 do
		step(p, i)
		steps = steps + 1
	end
	local errX = math.abs(p.bottleLandX - prev.x)
	local errY = math.abs(p.bottleTargetY - prev.y)
	check(name .. " 落点误差", errX <= 1.0 and errY <= 1.0,
		string.format("目标=(%.0f,%.0f) 预览=(%.1f,%.1f) 真实=(%.1f,%.1f) 误差=(%.2f,%.2f) 步=%d",
			targetX, targetY, prev.x, prev.y, p.bottleLandX, p.bottleTargetY, errX, errY, steps))
	return p
end

throwCase("F1 砖地 608", 608, 0)
throwCase("F2 砖地瞄高空", 608, 120)
throwCase("F3 软土 272", 272, 0)

print(string.format("==== 结果：PASS %d / FAIL %d ====", pass, fail))
assert(fail == 0, string.format("D6 回归失败 %d 项", fail))
