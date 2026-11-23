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
	p.player.h = 64
	p.player.onGround = true
	p:drainEvents()

	-- 不按蹲键，仍应保持蹲姿。
	step(p, i)
	check("C1 桌下松蹲键仍蹲", p.player.crouch == true and p.player.h == 36,
		string.format("crouch=%s h=%.0f", tostring(p.player.crouch), p.player.h))

	-- 走到桌外，下一拍恢复站姿。
	p.player.x = 450
	p.player.onGround = true
	step(p, i)
	check("C2 出拱后恢复站立", p.player.crouch == false and p.player.h == 64,
		string.format("crouch=%s h=%.0f", tostring(p.player.crouch), p.player.h))
end

print(string.format("==== 结果：PASS %d / FAIL %d ====", pass, fail))
assert(fail == 0, "verify-d9 有失败项")
