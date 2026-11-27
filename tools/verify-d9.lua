-- 守望 D9 · 三项后续：握车双手占用、安抚优先 E、低拱禁止起身
--
-- 用法（引擎内）：dofile("tools/verify-d9.lua")
--
-- 1. 周戍在检查站车把旁，冻结后按 E：安抚先消费这只 E，不能同拍抓车。
-- 2. 先抓住车把，再按左键/空格：握车期间两只手都被占用，不能射击、翻滚。
-- 3. 小满在村口桌下松掉蹲键：低拱下仍保持蹲姿，走出拱才站起。

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

-- 检查站：车把在世界 1240，小满放在 1220，E 同拍既够安抚也够车把。
local function checkpointAtCart()
	local p = lualib.__TS__New(play.Play, rooms.CHECKPOINT_ROOM)
	p.cartAxle = 1280
	p.player.x = 1240
	p.partner.x = 1220
	p.player.y = 0
	p.partner.y = 0
	p.player.onGround = true
	p.partner.onGround = true
	p:drainEvents()
	return p
end

-- ---------------------------------------------------------------- 1. 安抚优先 E
do
	local p = checkpointAtCart()
	local i = newInput()
	p.escort:applyDanger(1, true, p.partner.x)
	p.escort:applyDanger(2, true, p.partner.x)
	p.escort:applyDanger(3, true, p.partner.x)

	tap(i.interact)
	step(p, i)
	rel(i.interact)

	check("A1 同拍 E 进安抚", p.escort.state == "calming",
		string.format("state=%s calmTick=%d fear=%d", p.escort.state, p.escort.calmTick, p.escort.fear))
	check("A2 安抚同拍不抓车", p.gripping == false and p.cartAxle == 1280,
		string.format("gripping=%s axle=%.1f", tostring(p.gripping), p.cartAxle))
	check("A3 车把焦点不抢 E", p.focusCart == false, string.format("focusCart=%s", tostring(p.focusCart)))

	local t = 0
	while t < 60 do
		step(p, i)
		t = t + 1
	end
	check("A4 60 拍后仍回到 follow", p.escort.state == "follow",
		string.format("state=%s calmTick=%d", p.escort.state, p.escort.calmTick))
end

-- ---------------------------------------------------------------- 2. 握车锁双手
do
	local p = checkpointAtCart()
	local i = newInput()

	tap(i.interact)
	step(p, i)
	check("B1 E 抓住车把", p.gripping == true,
		string.format("gripping=%s axle=%.1f", tostring(p.gripping), p.cartAxle))

	-- 保持 E，按左键：握车时不能射击。
	p:drainEvents()
	i.fire.held = true
	i.fire.pressed = true
	step(p, i)
	check("B2 握车时左键不开枪", countEvent(p, "shotResolved") == 0 and p.gripping == true,
		string.format("shotResolved=%d gripping=%s", countEvent(p, "shotResolved"), tostring(p.gripping)))

	-- 按空格：握车时不能翻滚/翻越。
	i.jump.held = true
	i.jump.pressed = true
	step(p, i)
	check("B3 握车时空格不翻滚", p.player.rollT == 0 and p.gripping == true,
		string.format("rollT=%.2f gripping=%s", p.player.rollT, tostring(p.gripping)))

	-- 松开 E：当拍脱手，下一拍才允许射击。
	rel(i.interact)
	step(p, i)
	check("B4 松开 E 当拍脱手", p.gripping == false,
		string.format("gripping=%s axle=%.1f", tostring(p.gripping), p.cartAxle))

	p:drainEvents()
	i.fire.pressed = true
	step(p, i)
	check("B5 脱手后可射击", countEvent(p, "shotResolved") == 1,
		string.format("shotResolved=%d", countEvent(p, "shotResolved")))
end

-- ---------------------------------------------------------------- 3. 低拱禁止起身
do
	local p = lualib.__TS__New(play.Play, rooms.VILLAGE_ROOM)
	local i = newInput()
	p.player.x = 360
	p.player.y = 0
	p.player.crouch = false
	p.player.h = 56
	p.player.onGround = true
	p:drainEvents()

	-- 不按蹲键，仍应保持蹲姿。
	step(p, i)
	check("C1 桌下松蹲键仍蹲", p.player.crouch == true and p.player.h == 34,
		string.format("crouch=%s h=%.0f", tostring(p.player.crouch), p.player.h))

	-- 走到桌外，下一拍恢复站姿。
	p.player.x = 450
	p.player.onGround = true
	step(p, i)
	check("C2 出拱后恢复站立", p.player.crouch == false and p.player.h == 56,
		string.format("crouch=%s h=%.0f", tostring(p.player.crouch), p.player.h))
end

-- ---------------------------------------------------------------- 4. 同拍 E + 动作：有效握柄优先
do
	local p = checkpointAtCart()
	local i = newInput()
	tap(i.interact)
	tap(i.fire)
	local x0 = p.player.x
	step(p, i)
	check("D1 E+左键先握柄不开枪", p.gripping == true and countEvent(p, "shotResolved") == 0 and p.player.x == x0,
		string.format("gripping=%s shotResolved=%d x=%.1f", tostring(p.gripping), countEvent(p, "shotResolved"), p.player.x))

	local p2 = checkpointAtCart()
	local i2 = newInput()
	tap(i2.interact)
	tap(i2.jump)
	local x2 = p2.player.x
	step(p2, i2)
	check("D2 E+空格先握柄不翻滚", p2.gripping == true and p2.player.rollT == 0 and p2.player.y == 0 and p2.player.x == x2,
		string.format("gripping=%s rollT=%.2f y=%.1f", tostring(p2.gripping), p2.player.rollT, p2.player.y))

	-- 远离车柄时，点射和翻滚仍应正常。
	local p3 = checkpointAtCart()
	p3.player.x = 900
	p3.partner.x = 880
	p3:drainEvents()
	local i3 = newInput()
	tap(i3.fire)
	step(p3, i3)
	check("D3 远离车柄点射正常", countEvent(p3, "shotResolved") == 1 and p3.gripping == false,
		string.format("shotResolved=%d gripping=%s", countEvent(p3, "shotResolved"), tostring(p3.gripping)))

	local p4 = checkpointAtCart()
	p4.player.x = 600
	p4.partner.x = 580
	local i4 = newInput()
	tap(i4.jump)
	step(p4, i4)
	check("D4 远离车柄翻滚正常", p4.player.rollT > 0 and p4.gripping == false,
		string.format("rollT=%.2f gripping=%s", p4.player.rollT, tostring(p4.gripping)))
end

-- ---------------------------------------------------------------- 5. 安抚 1–59 拍占用动作（车把旁 / 远离车把）
local function enterCalm(p)
	p.escort:applyDanger(1, true, p.partner.x)
	p.escort:applyDanger(2, true, p.partner.x)
	p.escort:applyDanger(3, true, p.partner.x)
	local i = newInput()
	tap(i.interact)
	step(p, i)
	rel(i.interact)
	step(p, i) -- calmTick=1
	return i
end

local function runCalm(p, i, keepHands)
	local knocks = {}
	local x0 = p.player.x
	local axle0 = p.cartAxle
	local function collect()
		for _, e in ipairs(p:drainEvents()) do
			if e.name == "knock" then
				table.insert(knocks, { tick = e.tick, calm = p.escort.calmTick })
			end
		end
	end
	collect()

	-- 第 2 拍重新按 E+D；旧实现在这里会抓车/推车，或远离车把时发通用 knock。
	i.moveX = 1
	tap(i.interact)
	step(p, i)
	collect()

	while p.escort.calmTick < 59 do
		step(p, i)
		collect()
	end
	rel(i.interact)
	i.moveX = 0
	step(p, i) -- 第 60 拍：回 follow
	collect()
	return knocks, x0, axle0
end

do
	local p = checkpointAtCart()
	local i = enterCalm(p)
	local knocks, x0, axle0 = runCalm(p, i, true)
	check("E1 安抚中车把旁不抓车", p.gripping == false and p.player.x == x0 and p.cartAxle == axle0,
		string.format("gripping=%s x=%.1f/%.1f axle=%.1f/%.1f", tostring(p.gripping), p.player.x, x0, p.cartAxle, axle0))
	check("E2 安抚中车把旁不移动", p.player.x == x0 and p.cartAxle == axle0,
		string.format("x=%.1f/%.1f axle=%.1f/%.1f", p.player.x, x0, p.cartAxle, axle0))
	check("E3 安抚敲击恰两条且在第12/36拍", #knocks == 2 and knocks[1].calm == 12 and knocks[2].calm == 36,
		string.format("knocks=%d calm=%s/%s tick=%s/%s", #knocks,
			tostring(knocks[1] and knocks[1].calm), tostring(knocks[2] and knocks[2].calm),
			tostring(knocks[1] and knocks[1].tick), tostring(knocks[2] and knocks[2].tick)))
	check("E4 第60拍回 follow", p.escort.state == "follow" and p.escort.calmTick == 60,
		string.format("state=%s calmTick=%d", p.escort.state, p.escort.calmTick))
end

do
	local p = checkpointAtCart()
	p.player.x = 900
	p.partner.x = 880
	local i = enterCalm(p)
	local knocks, x0, axle0 = runCalm(p, i, false)
	check("E5 安抚中远离车把不移动", p.player.x == x0 and p.cartAxle == axle0,
		string.format("x=%.1f/%.1f axle=%.1f/%.1f", p.player.x, x0, p.cartAxle, axle0))
	check("E6 安抚中远离车把不发通用knock", #knocks == 2,
		string.format("knocks=%d", #knocks))
	check("E7 远离车把安抚敲击仍为12/36", #knocks == 2 and knocks[1].calm == 12 and knocks[2].calm == 36,
		string.format("calm=%s/%s", tostring(knocks[1] and knocks[1].calm), tostring(knocks[2] and knocks[2].calm)))
end

-- ---------------------------------------------------------------- 6. 城外握右柄时空格不跳
do
	local p = lualib.__TS__New(play.Play, rooms.OUTSIDE_ROOM)
	local i = newInput()
	p.player.x = 344
	p.player.y = 96
	p.player.onGround = true
	p.player.crouch = false
	p.cartAxle = 304
	p:drainEvents()

	tap(i.interact)
	step(p, i)
	check("F1 城外握住右柄", p.gripping == true,
		string.format("gripping=%s axle=%.1f", tostring(p.gripping), p.cartAxle))

	i.moveX = 1
	tap(i.jump)
	local axle0 = p.cartAxle
	step(p, i)
	check("F2 握车空格不起跳", p.player.y == 96 and p.player.onGround == true,
		string.format("y=%.1f onGround=%s", p.player.y, tostring(p.player.onGround)))
	check("F3 握车时D仍拉车", p.cartAxle > axle0 and p.gripping == true,
		string.format("axle=%.1f/%.1f gripping=%s", p.cartAxle, axle0, tostring(p.gripping)))

	rel(i.jump)
	rel(i.interact)
	step(p, i)
	check("F4 松E当拍脱手", p.gripping == false,
		string.format("gripping=%s", tostring(p.gripping)))

	tap(i.jump)
	step(p, i)
	check("F5 脱手后空格可跳", p.player.y > 96 or p.player.onGround == false,
		string.format("y=%.1f onGround=%s vy=%.1f", p.player.y, tostring(p.player.onGround), p.player.vy))
end

print(string.format("==== 结果：PASS %d / FAIL %d ====", pass, fail))
assert(fail == 0, "verify-d9 有失败项")
