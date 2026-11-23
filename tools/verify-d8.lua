-- 守望 D8 · 复核补测：切房事件去重与安抚两次接触
--
-- 用法（引擎内）：dofile("tools/verify-d8.lua")
--
-- 1. 街道出口条件连续两步都成立：同一次切房只发一条 roomChange；
--    换实例前 drain 旧队列，再 adopt 到新实例，下一帧仍只有这一条。
-- 2. 检查站安抚：第 12 / 36 拍各一条 knock，共两条；第 60 拍回 follow。
-- 3. 塔门仍走自己的 0 / 12 拍，两条 knock，不受安抚事件影响。

local rooms = require("Script.watch.rooms")
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
		print(string.format("PASS  %-30s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL  %-30s %s", tag, detail or ""))
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

local function step(p, i)
	p:update(STEP, i)
	i.interact.pressed = false
	i.interact.released = false
	i.fire.pressed = false
	i.aim.released = false
	i.jump.pressed = false
end

local function countEvent(p, name)
	local n = 0
	for _, e in ipairs(p.events) do
		if e.name == name then
			n = n + 1
		end
	end
	return n
end

local function knockEvents(list)
	local out = {}
	for _, e in ipairs(list) do
		if e.name == "knock" then
			table.insert(out, e)
		end
	end
	return out
end

-- ---------------------------------------------------------------- 1. 切房去重
do
	local p = lualib.__TS__New(play.Play, rooms.STREET_ROOM)
	local i = newInput()
	p.player.x = 900
	p.partner.x = 860
	p:drainEvents()

	step(p, i)
	step(p, i)

	check("A1 两步只一条 roomChange", countEvent(p, "roomChange") == 1 and p.wantRoom == "checkpoint",
		string.format("roomChange=%d wantRoom=%s tick=%d", countEvent(p, "roomChange"), p.wantRoom, p.ticks))

	local roomEvent = nil
	for _, e in ipairs(p.events) do
		if e.name == "roomChange" then
			roomEvent = e
		end
	end
	check("A2 切房事件落在第一拍", roomEvent ~= nil and roomEvent.tick == 1
		and roomEvent.data.to == "checkpoint",
		roomEvent ~= nil and string.format("seq=%d tick=%d to=%s", roomEvent.seq, roomEvent.tick, roomEvent.data.to) or "无")

	-- 模拟 app：换实例前先取走旧队列，再接到新实例队首。
	local leaving = p:drainEvents()
	local fresh = lualib.__TS__New(play.Play, rooms.CHECKPOINT_ROOM)
	fresh:adoptEvents(leaving)
	local kept = fresh:drainEvents()
	check("A3 换实例后不丢不重", #kept == 1 and kept[1].name == "roomChange"
		and kept[1].data.to == "checkpoint" and kept[1].seq == 0,
		#kept == 1 and string.format("kept=%d seq=%d tick=%d to=%s", #kept, kept[1].seq, kept[1].tick, kept[1].data.to)
			or string.format("kept=%d", #kept))
end

-- ---------------------------------------------------------------- 2. 检查站安抚
do
	local p = lualib.__TS__New(play.Play, rooms.CHECKPOINT_ROOM)
	local i = newInput()
	p.escort:applyDanger(1, true, p.partner.x)
	p.escort:applyDanger(2, true, p.partner.x)
	p.escort:applyDanger(3, true, p.partner.x)
	p.player.x = p.partner.x - 20
	p:drainEvents()

	tap(i.interact)
	step(p, i)
	rel(i.interact)
	check("B1 E 进安抚", p.escort.state == "calming" and p.escort.calmTick == 0,
		string.format("state=%s calmTick=%d fear=%d", p.escort.state, p.escort.calmTick, p.escort.fear))

	local t = 0
	while t < 60 do
		step(p, i)
		t = t + 1
	end

	local ev = knockEvents(p:drainEvents())
	local k1 = nil
	local k2 = nil
	for _, e in ipairs(ev) do
		if e.data.count == 1 then
			k1 = e
		elseif e.data.count == 2 then
			k2 = e
		end
	end
	check("B2 安抚恰好两条 knock", #ev == 2 and k1 ~= nil and k2 ~= nil,
		string.format("总数=%d count1=%s count2=%s", #ev, tostring(k1 ~= nil), tostring(k2 ~= nil)))
	check("B3 两次接触相隔 24 拍", k1 ~= nil and k2 ~= nil and k2.tick - k1.tick == 24,
		k1 ~= nil and k2 ~= nil and string.format("tick=%d / %d 差=%d", k1.tick, k2.tick, k2.tick - k1.tick) or "缺事件")
	check("B4 60 拍回 follow", p.escort.state == "follow" and p.escort.calmTick == 60,
		string.format("state=%s calmTick=%d", p.escort.state, p.escort.calmTick))
end

-- ---------------------------------------------------------------- 3. 塔门 0 / 12 拍
do
	local p = lualib.__TS__New(play.Play, rooms.TOWER_ROOM)
	local i = newInput()
	p.player.x = 445
	p:drainEvents()

	tap(i.interact)
	step(p, i)
	rel(i.interact)
	check("C1 塔门第一声在按 E 当拍", p.phase == "tower-knock" and p.knocks == 1
		and countEvent(p, "knock") == 1,
		string.format("phase=%s knocks=%d tick=%d", p.phase, p.knocks, p.ticks))

	local t = 0
	while t < 12 do
		step(p, i)
		t = t + 1
	end

	local ev = knockEvents(p.events)
	check("C2 塔门第二声在第 12 拍", #ev == 2 and ev[1].data.count == 1 and ev[2].data.count == 2
		and ev[2].tick - ev[1].tick == 12,
		#ev == 2 and string.format("count=%d@tick%d count=%d@tick%d", ev[1].data.count, ev[1].tick, ev[2].data.count, ev[2].tick)
			or string.format("总数=%d", #ev))
end

print(string.format("==== 结果：PASS %d / FAIL %d ====", pass, fail))
assert(fail == 0, string.format("D8 补测失败 %d 项", fail))
