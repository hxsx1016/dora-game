-- 守望 D7 · 三处已复现逻辑问题的回归
--
-- 用法（引擎内）：dofile("tools/verify-d7.lua")
--
-- 1. 掩体：按移动后身体边缘 + 垂直重叠定贴靠实体，再按实体是否挡在来向结算。
--    490 / 505 都该挡下；130 / 300 都该掉血。130 会「贴住绞盘」但背向火力。
-- 2. 倒地同拍：2699 拍、1 血、敌兵 warnT=1，致命那拍按 E。倒地当拍停在 gate-idle；
--    按住 E 不重开，松开后再按才进 gate-hold。另留「最后一拍活下来进 gate-send」对照。
-- 3. 垂直投瓶：x=142 拾瓶，按住 F 10 拍，瞄 152 / 132。松手首拍不落地；
--    瓶子下降、t 到固定飞行时长才触地并只发一次声音事件。补测 7 拍保瓶、8 拍可投。
--
-- 事件接口同时验收：coverBlocked / actorHit / gateFailed / gateRestart / bottleThrown /
-- bottleLanded / knock / roomChange，seq 与 tick 由模拟步填写。

local rooms = require("Script.watch.rooms")
-- 引擎里 require 有缓存：重新构建后先丢掉旧 play 模块，回放才测到本轮代码。
package.loaded["Script.watch.play"] = nil
local play = require("Script.watch.play")
local input = require("Script.watch.input")
local lualib = require("lualib_bundle")

local STEP = play.STEP
local pass = 0
local fail = 0

local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS  %-28s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL  %-28s %s", tag, detail or ""))
	end
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

-- 回放里每拍只更新一次模拟；边沿由脚本自己控制，step 之后清掉「本拍按下」。
local function step(p, i)
	p:update(STEP, i)
	i.interact.pressed = false
	i.interact.released = false
	i.fire.pressed = false
	i.aim.released = false
	i.jump.pressed = false
end

local function gateHold(hp)
	local p = lualib.__TS__New(play.Play, rooms.GATE_ROOM)
	local i = newInput()
	p.phase = "gate-hold"
	p.gateTick = 1
	p.gateSpawned = 4 -- 本组测试自己放敌兵，不跑四批入场
	p.hp = hp or 3
	return p, i
end

local function putEnemy(p, x, warnT)
	local e = { x = x, y = 0, w = 26, h = 84, alive = true, hitT = 0, warnT = warnT or 0, fireCd = 0 }
	table.insert(p.enemies, e)
	return e
end

local function eventOf(p, name)
	local found = nil
	for _, e in ipairs(p.events) do
		if e.name == name then
			found = e
		end
	end
	return found
end

local function eventCount(p, name)
	local n = 0
	for _, e in ipairs(p.events) do
		if e.name == name then
			n = n + 1
		end
	end
	return n
end

print("==== D7 三处逻辑修复回归 ====")

-- ---------------------------------------------------------------- 1. 掩体
-- 敌人固定在右侧 620、下一拍开火；周戍按住 Shift，只改站位。
local function coverCase(tag, x, expectBlocked)
	local p, i = gateHold(3)
	p.player.x = p.ox + x
	p.player.y = 0
	putEnemy(p, 620, 1)
	i.cover.held = true
	p:drainEvents()
	step(p, i)
	local blocked = eventOf(p, "coverBlocked")
	local hit = eventOf(p, "actorHit")
	local got = blocked ~= nil
	local detail = string.format(
		"x=%d 贴靠=%q hug=%s 挡来向=%s 实体=%s 结果=%s 血=%d 事件=%s",
		x, p.coverEntity, tostring(p.coverHug), tostring(p.coverBlocking),
		p.coverEntity, got and "挡下" or "掉血", p.hp,
		blocked ~= nil and "coverBlocked" or (hit ~= nil and "actorHit" or "无"))
	check(tag, got == expectBlocked, detail)
	if expectBlocked then
		check(tag .. " 事件字段", blocked ~= nil and blocked.data.hp == 3 and math.abs(blocked.data.enemyX - 620) < 1,
			blocked ~= nil and string.format("seq=%d tick=%d entity=%s hp=%d", blocked.seq, blocked.tick, blocked.data.entity, blocked.data.hp) or "无 coverBlocked")
	else
		check(tag .. " 事件字段", hit ~= nil and hit.data.hp == 2 and hit.data.amount == 1,
			hit ~= nil and string.format("seq=%d tick=%d amount=%d hp=%d", hit.seq, hit.tick, hit.data.amount, hit.data.hp) or "无 actorHit")
	end
end

coverCase("A1 x=490 街垒边缘挡下", 490, true)
coverCase("A2 x=505 贴住街垒挡下", 505, true)
coverCase("A3 x=130 贴绞盘但背向", 130, false)
coverCase("A4 x=300 空地掉血", 300, false)

-- ---------------------------------------------------------------- 2. 倒地同拍重开
do
	local p, i = gateHold(1)
	p.player.x = p.ox + p.room.story.gate.winchX
	p.partner.x = p.room.story.gate.waitX
	p.gateTick = 2699
	putEnemy(p, 620, 1)
	p:drainEvents()
	-- 致命受击与 E 是同一拍：E 在 stepGate 里被读到时，人已经被打倒。
	tap(i.interact)
	step(p, i)
	local fell = eventOf(p, "gateFailed")
	local wait = eventOf(p, "gateRestart")
	check("B1 倒地当拍停住", p.phase == "gate-idle" and p.gateTick == 0 and #p.enemies == 0
		and p.hp == p.maxHp and p.gateNeedConfirm == true and p.gateRestartArmed == false,
		string.format("phase=%s tick=%d 敌=%d 血=%d 待确认=%s 可重按=%s x=%.1f",
			tostring(p.phase), p.gateTick, #p.enemies, p.hp, tostring(p.gateNeedConfirm), tostring(p.gateRestartArmed), p.player.x))
	check("B2 倒地事件", fell ~= nil and fell.data.hp == 0 and fell.data.failCount == 1,
		fell ~= nil and string.format("seq=%d tick=%d fail=%d", fell.seq, fell.tick, fell.data.failCount) or "无 gateFailed")
	check("B3 同拍 E 不重开", wait == nil and p.phase == "gate-idle",
		wait == nil and "无 gateRestart" or string.format("seq=%d tick=%d", wait.seq, wait.tick))

	-- 继续按住 E 30 拍：维持等待，计时与敌兵都不动。
	local held = 0
	while held < 30 do
		i.interact.held = true
		step(p, i)
		held = held + 1
	end
	check("B4 按住 E 维持等待", p.phase == "gate-idle" and p.gateTick == 0 and #p.enemies == 0 and p.gateRestartArmed == false,
		string.format("phase=%s tick=%d 敌=%d 可重按=%s", tostring(p.phase), p.gateTick, #p.enemies, tostring(p.gateRestartArmed)))

	-- 松开：只把「新按」许可打开，不自动开始。
	rel(i.interact)
	step(p, i)
	check("B5 松开不开局", p.phase == "gate-idle" and p.gateRestartArmed == true,
		string.format("phase=%s 可重按=%s", tostring(p.phase), tostring(p.gateRestartArmed)))

	-- 新按才进 gate-hold。
	tap(i.interact)
	step(p, i)
	local restart = eventOf(p, "gateRestart")
	check("B6 新按才进 gate-hold", p.phase == "gate-hold" and p.gateTick == 0 and p.gateNeedConfirm == false,
		string.format("phase=%s tick=%d 待确认=%s", tostring(p.phase), p.gateTick, tostring(p.gateNeedConfirm)))
	check("B7 重开事件", restart ~= nil and restart.data.failCount == 1,
		restart ~= nil and string.format("seq=%d tick=%d", restart.seq, restart.tick) or "无 gateRestart")
end

-- 对照：最后一拍有掩体、活下来，照常进入 gate-send。
do
	local p, i = gateHold(1)
	p.player.x = p.ox + 512
	p.player.y = 0
	p.gateTick = 2699
	putEnemy(p, 620, 1)
	i.cover.held = true
	step(p, i)
	check("B8 末拍存活进 gate-send", p.phase == "gate-send" and p.gateTick == 2700 and p.gateFailCount == 0
		and p.hp == 1 and #p.enemies == 0,
		string.format("phase=%s tick=%d 血=%d 倒=%d 敌=%d", tostring(p.phase), p.gateTick, p.hp, p.gateFailCount, #p.enemies))
end

-- ---------------------------------------------------------------- 3. 垂直投瓶
-- 相机先站到稳定位置：p.x=142、facing=1 → cam 目标 172/46。
-- 这样 aimAt(152,0) 与 bottleEnd() 用同一个 cam，预览才会正好是 152。
local function settleCam(p)
	p.cam.x = p.player.x + 30
	p.cam.y = p.player.y + 46
end

local function throwVertical(tag, targetX)
	local p = lualib.__TS__New(play.Play, rooms.VILLAGE_ROOM)
	local i = newInput()
	p.player.x = 142
	p.player.y = 0
	p.hasBottle = true
	settleCam(p)
	p:aimAt(targetX, 0)
	p:drainEvents()

	-- 按住 F 10 拍；缓存点就是屏幕上的预览。
	i.aim.held = true
	local hold = 0
	while hold < 10 do
		step(p, i)
		hold = hold + 1
	end
	check(tag .. " 预览", math.abs(p.bottleAimX - targetX) <= 1 and math.abs(p.bottleAimY) <= 1,
		string.format("预览=(%.1f,%.1f) 目标=%d", p.bottleAimX, p.bottleAimY, targetX))

	-- 松手首拍：瓶子刚出手，绝不能已经落地或已经惊动拾荒者。
	i.aim.held = false
	i.aim.released = true
	step(p, i)
	local thrown = eventOf(p, "bottleThrown")
	local firstY = p.bottleFly ~= nil and p.bottleFly.y or -1
	check(tag .. " 松手首拍", p.bottleFly ~= nil and p.bottleLandX < 0 and p.bottleLandT == 0
		and p.scavState == "patrol" and eventCount(p, "bottleLanded") == 0,
		string.format("fly=%s 首拍瓶高=%.1f landX=%.1f 拾荒者=%s",
			tostring(p.bottleFly ~= nil), firstY, p.bottleLandX, p.scavState))
	check(tag .. " 出手事件", thrown ~= nil and math.abs(thrown.data.targetX - targetX) <= 1 and thrown.data.flightTicks == 37,
		thrown ~= nil and string.format("seq=%d targetX=%.1f flightTicks=%d", thrown.seq, thrown.data.targetX, thrown.data.flightTicks) or "无 bottleThrown")

	-- 逐拍飞到触地：记录触地前一拍瓶高，检查只在触地拍发一次声音。
	local steps = 0
	local prevY = -1
	while p.bottleFly ~= nil and steps < 200 do
		prevY = p.bottleFly.y
		step(p, i)
		steps = steps + 1
	end
	local landed = eventOf(p, "bottleLanded")
	check(tag .. " 触地", p.bottleLandX >= 0 and math.abs(p.bottleLandX - targetX) <= 1
		and p.bottleLandY == 0 and steps >= 30 and steps <= 45,
		string.format("步=%d 触地前一拍瓶高=%.1f 触地拍瓶高=%.1f landX=%.1f landY=%.1f",
			steps, prevY, p.bottleFly ~= nil and p.bottleFly.y or 0, p.bottleLandX, p.bottleLandY))
	check(tag .. " 一次声音", eventCount(p, "bottleLanded") == 1 and landed ~= nil
		and math.abs(landed.data.x - targetX) <= 1 and landed.data.heard == true,
		landed ~= nil and string.format("seq=%d x=%.1f y=%.1f heard=%s", landed.seq, landed.data.x, landed.data.y, tostring(landed.data.heard)) or "无 bottleLanded")
	check(tag .. " 拾荒者转头", p.scavState == "turn" and p.scavT >= 17 and p.scavT <= 18,
		string.format("state=%s t=%d target=%.1f", p.scavState, p.scavT, p.scavTargetX))
end

throwVertical("C1 右手正下方", 152)
throwVertical("C2 左手正下方", 132)

-- 7 拍保瓶 / 8 拍可投：判定沿用 0.12 秒。
local function holdCase(tag, holdTicks, expectThrow)
	local p = lualib.__TS__New(play.Play, rooms.VILLAGE_ROOM)
	local i = newInput()
	p.player.x = 142
	p.player.y = 0
	p.hasBottle = true
	settleCam(p)
	p:aimAt(152, 0)
	p:drainEvents()
	i.aim.held = true
	local hold = 0
	while hold < holdTicks do
		step(p, i)
		hold = hold + 1
	end
	i.aim.held = false
	i.aim.released = true
	step(p, i)
	local threw = p.bottleFly ~= nil
	check(tag, threw == expectThrow,
		string.format("按住=%d 拍 aimHold=%.4f hasBottle=%s 飞行=%s 事件=%s",
			holdTicks, p.aimHold, tostring(p.hasBottle), tostring(p.bottleFly ~= nil),
			eventCount(p, "bottleThrown") > 0 and "bottleThrown" or "无"))
end

holdCase("C3 按住 7 拍保瓶", 7, false)
holdCase("C4 按住 8 拍可投", 8, true)

-- ---------------------------------------------------------------- 4. 事件接口
-- 街道木板：连续两次 E 给出 knock count 1、2；drainEvents 后队列清空且 seq 不复用。
do
	local p = lualib.__TS__New(play.Play, rooms.STREET_ROOM)
	local i = newInput()
	p:drainEvents()
	tap(i.interact)
	step(p, i)
	local k1 = eventOf(p, "knock")
	rel(i.interact)
	step(p, i)
	tap(i.interact)
	step(p, i)
	local k2 = nil
	for _, e in ipairs(p.events) do
		if e.name == "knock" and e.data.count == 2 then
			k2 = e
		end
	end
	check("D1 敲击第几声", k1 ~= nil and k2 ~= nil and k1.data.count == 1 and k2.data.count == 2,
		k1 ~= nil and k2 ~= nil and string.format("count=%d@tick%d count=%d@tick%d", k1.data.count, k1.tick, k2.data.count, k2.tick) or "缺 knock")
	local drained = p:drainEvents()
	check("D2 事件出队即清空", #drained >= 2 and #p.events == 0,
		string.format("取出=%d 剩余=%d", #drained, #p.events))
end

print(string.format("==== 结果：PASS %d / FAIL %d ====", pass, fail))
assert(fail == 0, string.format("D7 回归失败 %d 项", fail))
