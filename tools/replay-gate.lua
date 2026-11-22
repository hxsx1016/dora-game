-- 守望 D6 · 城门守点失败与成功各一次
--
-- 用途：验证敌兵举枪预警、开火命中、掩体挡枪、被击倒回绞盘的完整闭环。
-- 失败一局：站着不动，让三发子弹打空血。
-- 成功一局：用 Input.fire + 准星（aimAt）主动打掉敌兵，守满 2700 拍。
--
-- 用法（引擎内）：dofile("tools/replay-gate.lua")

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

local function show(tag, p)
	local g = p.room.story.gate
	print(string.format(
		"%-16s phase=%-10s tick=%4d/2700 血=%d/%d 倒=%d 敌=%d/%-2d x=%6.1f 小满=%6.1f",
		tag, tostring(p.phase), p.gateTick, p.hp, p.maxHp, p.gateFailCount,
		p:aliveEnemies(), #p.enemies, p.player.x, p.partner.x))
end

-- 一、失败：站着不动，等三发打空血
local i = newInput()
local p = lualib.__TS__New(play.Play, rooms.GATE_ROOM)
print("==== 城门守点 · 失败一局（不动、不躲、不开枪） ====")
show("G0 进房", p)

-- 小满自己走到 960；周戍要走到绞盘（winchX=70）附近，站位对了才进 gate-hold
local winch = p.room.story.gate.winchX
i.moveX = (p.player.x > winch) and -1 or 1
local guard = 0
while p.phase ~= "gate-hold" and guard < 900 do
	if math.abs(p.player.x - winch) <= 6 then
		i.moveX = 0
	end
	p:update(STEP, i)
	guard = guard + 1
end
i.moveX = 0
show("G1 就位", p)

local lastHp = p.hp
local lastFail = p.gateFailCount
local hitAt, failAt = {}, nil
guard = 0
while p.gateFailCount == 0 and guard < 3000 do
	p:update(STEP, i)
	guard = guard + 1
	if p.hp < lastHp then
		hitAt[#hitAt + 1] = string.format("%d拍 血%d tick%d", guard, p.hp, p.gateTick)
		lastHp = p.hp
	end
	if p.gateFailCount > lastFail and failAt == nil then
		failAt = guard
	end
end
print("G2 中弹 " .. table.concat(hitAt, " / "))
print(string.format("G3 被击倒 第%d拍 tick=%d 倒=%d 敌=%d 血=%d x=%.1f 小满=%.1f phase=%s",
	guard, p.gateTick, p.gateFailCount, #p.enemies, p.hp, p.player.x, p.partner.x, tostring(p.phase)))

-- 二、成功：同一局从重置状态继续，用准星与 fire 打掉敌兵
print("==== 城门守点 · 成功一局（贴街垒 + 准星 + F 射击） ====")
-- 绞盘 130 的射界被街垒 520–600 挡死；守点必须前出到街垒左侧 512 才有射线
i.moveX = 1
guard = 0
while p.player.x < 510 and guard < 300 do
	p:update(STEP, i)
	guard = guard + 1
end
i.moveX = 0
print(string.format("G4a 前出到街垒 x=%.1f 血=%d", p.player.x, p.hp))
local shots = 0
local kills = 0
local seen = 0
guard = 0
while p.phase ~= "gate-send" and guard < 3600 do
	-- 每 12 拍找最近的活敌兵打一枪；aimAt 只做世界→准星换算，开火仍走 Input.fire
	if guard % 12 == 0 then
		local best, bestD = nil, 1e9
		for idx = 1, #p.enemies do
			local e = p.enemies[idx]
			if e.alive then
				local d = math.abs(e.x - p.player.x)
				if d < bestD then
					best, bestD = e, d
				end
			end
		end
		if best ~= nil then
			p:aimAt(best.x, best.y + best.h * 0.5)
			tap(i.fire)
			local before = p:aliveEnemies()
			p:update(STEP, i)
			rel(i.fire)
			shots = shots + 1
			if p:aliveEnemies() < before then
				kills = kills + 1
			end
			guard = guard + 1
		else
			p:update(STEP, i)
			guard = guard + 1
		end
	else
		p:update(STEP, i)
		guard = guard + 1
	end
	if p.gateSpawned > seen then
		seen = p.gateSpawned
		print(string.format("G4 第%d批出场 tick=%d 敌=%d", seen, p.gateTick, p:aliveEnemies()))
	end
end
print(string.format("G5 守满 tick=%d 开枪=%d 击毙=%d 血=%d/3 倒=%d 敌=%d phase=%s",
	p.gateTick, shots, kills, p.hp, p.gateFailCount, p:aliveEnemies(), tostring(p.phase)))

-- 三、送别与交权（沿用主回放路径）
local g = p.room.story.gate
i.moveX = 1
guard = 0
local stuck = 0
local lastX = p.player.x
while p.phase == "gate-send" and guard < 900 do
	-- 街垒 520–600 挡路：贴上去就跳，翻过再走
	if p.player.onGround and p.player.x < 620 then
		stuck = stuck + 1
		if stuck >= 4 then
			tap(i.jump)
			stuck = 0
		end
	else
		stuck = 0
	end
	if math.abs(p.player.x - g.doorX) <= 60 then
		i.moveX = 0
		tap(i.interact)
	end
	p:update(STEP, i)
	rel(i.interact)
	rel(i.jump)
	guard = guard + 1
end
i.moveX = 0
print(string.format("G6 送别 phase=%s x=%.1f armed=%s", tostring(p.phase), p.player.x, tostring(p.countArmed)))
i.moveX = 0
for _ = 1, 1500 do
	p:update(STEP, i)
end
print(string.format("G7 数完 tick=%d phase=%s x=%.1f armed=%s", p.countTick, tostring(p.phase), p.player.x, tostring(p.countArmed)))
i.moveX = 1
p:update(STEP, i)
print(string.format("G8 新按D phase=%s x=%.1f", tostring(p.phase), p.player.x))
for _ = 1, 900 do
	p:update(STEP, i)
	if p.wantRoom ~= "" then
		break
	end
end
i.moveX = 0
print(string.format("G9 出门 x=%.1f want=%s", p.player.x, tostring(p.wantRoom)))

-- 四、掩体挡枪：贴街垒 520 时不该掉血
local p2 = lualib.__TS__New(play.Play, rooms.GATE_ROOM)
local j = newInput()
p2.phase = "gate-hold"
p2.gateTick = 500
p2.player.x = 512
p2.player.y = 0
p2.partner.x = 900
for _ = 1, 600 do
	p2:update(STEP, j)
end
print(string.format("H1 贴街垒512 血=%d/3 tick=%d 敌=%d", p2.hp, p2.gateTick, p2:aliveEnemies()))

local p3 = lualib.__TS__New(play.Play, rooms.GATE_ROOM)
local k = newInput()
p3.phase = "gate-hold"
p3.gateTick = 500
p3.player.x = 130
p3.partner.x = 900
k.cover.held = true
for _ = 1, 600 do
	p3:update(STEP, k)
end
print(string.format("H2 绞盘按Shift 血=%d/3 tick=%d", p3.hp, p3.gateTick))

local p4 = lualib.__TS__New(play.Play, rooms.GATE_ROOM)
local m = newInput()
p4.phase = "gate-hold"
p4.gateTick = 500
p4.player.x = 130
p4.partner.x = 900
for _ = 1, 600 do
	p4:update(STEP, m)
end
print(string.format("H3 绞盘空手站 血=%d/3 tick=%d", p4.hp, p4.gateTick))
print("==== 回放结束 ====")
