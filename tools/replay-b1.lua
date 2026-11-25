-- B1 端到端回放：从序章入口真实切房到城门，再走两条线。
--   路线 A（女主对照）：带伤送别 → 数满迈步 → outside
--   路线 B（男主）：守满送别 → 数完轻叩 → 长按牵手 → 高石阶背起 → escort1
--                    → 三种连线换弹 → 安全出口 → outside
--
-- 入口方式（脚本放仓库根，输出进引擎日志）：
--   Dora cli run -p . --entry tmp-replay-b1.lua
--   Dora cli log -n 400

local Content = require("Dora").Content
local assetPath = Content.assetPath
Content:addSearchPath(assetPath .. "/Script")
Content:addSearchPath(assetPath .. "/Script/Lib")
Content:addSearchPath(assetPath)
package.path = package.path
	.. ";" .. assetPath .. "/?.lua"
	.. ";" .. assetPath .. "/Script/?.lua"

local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local input = require("Script.watch.input")
local runmod = require("Script.watch.run")
local lualib = require("lualib_bundle")
local STEP = play.STEP

local function newInput()
	local i = lualib.__TS__New(input.Input)
	i.moveX = 0
	i.moveY = 0
	for _, k in ipairs({ "jump", "crouch", "cover", "interact", "aim", "fire", "retry", "pause" }) do
		i[k] = { held = false, pressed = false, released = false }
	end
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
	i.jump.pressed = false
	i.jump.released = false
	i.pause.pressed = false
end

local function steps(p, i, n)
	for _ = 1, n do
		step(p, i)
	end
end

local function drain(p)
	local bag = p:drainEvents()
	for _, e in ipairs(bag) do
		local data = e.data or {}
		local detail = ""
		if e.name == "roomChange" then
			detail = tostring(data.from) .. "→" .. tostring(data.to) .. " (" .. tostring(data.reason) .. ")"
		elseif e.name == "storyRouteLocked" then
			detail = "route=" .. tostring(data.route) .. " hp=" .. tostring(data.hpAtGate) .. "/" .. tostring(data.maxHpAtGate)
		elseif e.name == "gateCountDone" then
			detail = "route=" .. tostring(data.route) .. " tick=" .. tostring(data.countTick)
		elseif e.name == "knock" then
			detail = "count=" .. tostring(data.count)
		elseif e.name == "handHeld" or e.name == "handRelease" then
			detail = "handTicks=" .. tostring(data.handTicks)
		elseif e.name == "storyLine" then
			detail = tostring(data.who) .. "：" .. tostring(data.text)
		elseif e.name == "storyExit" then
			detail = "route=" .. tostring(data.route) .. " via=" .. tostring(data.via)
		elseif e.name == "gatePathEnd" or e.name == "carryStart" then
			detail = "x=" .. tostring(data.x) .. " tied=" .. tostring(data.tied)
		elseif e.name == "reloadOpen" then
			detail = "try=" .. tostring(data.tryCount) .. " need=" .. tostring(data.needTicks)
		elseif e.name == "reloadSolved" then
			detail = "effect=" .. tostring(data.effect) .. " answer=" .. tostring(data.answerTicks)
		elseif e.name == "reloadApplied" then
			detail = "effect=" .. tostring(data.effect)
		elseif e.name == "reloadTimeout" then
			detail = "answer=" .. tostring(data.answerTicks)
		end
		print(string.format("  [t%4d] %-16s %s", e.tick, e.name, detail))
	end
	return bag
end

local function room(tag, key, run)
	for idx, r in ipairs(rooms.ROOMS) do
		if r.key == key then
			local p = lualib.__TS__New(play.Play, rooms.ROOMS[idx], nil, run)
			print(string.format("== %s · %-9s ox=%.0f 周戍=%.0f 小满=%.0f 血=%d/%d route=%s carry=%s 控=%s",
				tag, key, p.ox, p.player.x, p.partner.x, p.hp, p.maxHp, tostring(p.storyRoute),
				tostring(p.carryOn), p.childMode and "小满" or "周戍"))
			return p
		end
	end
	error("no room " .. key)
end

local function switchRoom(prev, key, run, tag)
	local leaving = drain(prev)
	local next = room(tag, key, run)
	for _, e in ipairs(leaving) do
		if e.name == "roomChange" then
			print(string.format("   切房 seq=%d tick=%d %s→%s", e.seq, e.tick, tostring(e.data.from), tostring(e.data.to)))
		end
	end
	next:adoptEvents(leaving)
	return next
end

local function walkTo(p, i, worldX, maxTicks)
	i.moveX = 0
	local lastX = p.player.x
	local stuck = 0
	for _ = 1, maxTicks or 800 do
		local dx = worldX - p.player.x
		if math.abs(dx) <= 6 then
			i.moveX = 0
			step(p, i)
			return true
		end
		i.moveX = dx > 0 and 1 or -1
		if (p.room.key == "gatepath" or p.room.key == "escort1") and p.player.onGround then
			if math.abs(p.player.x - lastX) < 0.3 then
				stuck = stuck + 1
				if stuck >= 3 then
					tap(i.jump)
					stuck = 0
				end
			else
				stuck = 0
			end
		end
		lastX = p.player.x
		step(p, i)
		if p.wantRoom ~= "" then
			i.moveX = 0
			return true
		end
	end
	i.moveX = 0
	return false
end

-- 前半段：序章 → 街口 → 检查点 → 城门。返回门房与输入。
local function toGate(run, tag, hp)
	local p = room(tag .. " 序章", "prologue", run)
	local i = newInput()
	p.player.x = p.partner.x + 20
	p.player.depth = p.partner.depth
	p.player.y = p.partner.y
	tap(i.interact)
	step(p, i)
	rel(i.interact)
	drain(p)
	steps(p, i, 70)
	p.player.x = p.ox + 660
	p.partner.x = p.ox + 620
	step(p, i)
	drain(p)
	p = switchRoom(p, "street", run, tag .. " 街口")
	drain(p)
	p.player.x = p.ox + 900
	p.partner.x = p.ox + 860
	step(p, i)
	drain(p)
	p = switchRoom(p, "checkpoint", run, tag .. " 检查点")
	drain(p)

	i = newInput()
	local cart = p.room.cart
	p.player.x = cart.startX + cart.handleOffset
	p.player.depth = cart.depth or 0
	p.player.y = 0
	tap(i.interact)
	step(p, i)
	rel(i.interact)
	i.moveX = 1
	for _ = 1, 400 do
		step(p, i)
		if p.cartDocked then
			break
		end
	end
	i.moveX = 0
	rel(i.interact)
	drain(p)
	p.player.x = p.ox + 900
	p.partner.x = p.ox + 860
	step(p, i)
	drain(p)
	p = switchRoom(p, "gate", run, tag .. " 城门")
	drain(p)

	-- 守点快进到末拍：真实守满 2700 拍另见 replay-gate.lua。
	local g = p.room.story.gate
	p.phase = "gate-hold"
	p.gateTick = g.holdTicks - 1
	p.gateSpawned = 4
	p.enemies = {}
	p.hp = hp
	p.player.x = p.ox + g.winchX
	p.partner.x = p.ox + g.waitX
	step(p, i)
	drain(p)
	print(string.format("   守满 phase=%s 取血=%s/%s route=%s", tostring(p.phase),
		tostring(p.hpAtGate), tostring(p.maxHpAtGate), tostring(p.storyRoute)))
	return p, i
end

-- 门洞送别并数到二十。
local function bidFarewell(p, i)
	local g = p.room.story.gate
	p.player.x = p.ox + g.doorX
	p.partner.x = p.ox + g.doorX + 30
	tap(i.interact)
	step(p, i)
	rel(i.interact)
	drain(p)
	print(string.format("   送别 phase=%s route=%s 控=%s", tostring(p.phase),
		tostring(p.storyRoute), p.childMode and "小满" or "周戍"))
	for _ = 1, play.GATE_COUNT_END do
		step(p, i)
		if p.phase ~= "gate-count" then
			break
		end
	end
	drain(p)
	print(string.format("   数满 phase=%s countTick=%d", tostring(p.phase), p.countTick))
end

print("############ 路线 A：带伤送别 → 小满数完迈步出城（对照） ############")
do
	local run = runmod.createRun()
	local p, i = toGate(run, "A", 2)
	bidFarewell(p, i)
	-- 数数期间一直按着 D 的旧键不算；先松开，再重新按。
	i.moveX = 0
	steps(p, i, 4)
	i.moveX = 1
	step(p, i)
	drain(p)
	walkTo(p, i, p.ox + p.room.story.gate.exitX + 30, 400)
	drain(p)
	p = switchRoom(p, "outside", run, "A 城外")
	print(string.format("   女主城外 hp=%d/%d route=%s carry=%s 控=%s", p.hp, p.maxHp,
		tostring(p.storyRoute), tostring(p.carryOn), p.childMode and "小满" or "周戍"))
end

print("############ 路线 B：守满 → 轻叩 → 牵手 → 背起 → 首场护送 → 慢时换弹 ############")
do
	local run = runmod.createRun()
	local p, i = toGate(run, "B", 3)
	bidFarewell(p, i)
	-- 两下轻叩：第 1 拍与第 12 拍。
	steps(p, i, 14)
	drain(p)
	-- 长按 E 36 拍牵手。
	i.interact.held = true
	local held = 0
	for _ = 1, 40 do
		step(p, i)
		held = held + 1
		if p.phase == "gate-hand" then
			break
		end
	end
	i.interact.held = false
	drain(p)
	print(string.format("   牵手 %d 拍 phase=%s handTicks=%d tied=%s", held, tostring(p.phase),
		p.handTicks, tostring(p.tied)))
	steps(p, i, 100)
	drain(p)
	p = switchRoom(p, "gatepath", run, "B 同行段")
	walkTo(p, i, p.ox + 850, 400)
	drain(p)
	print(string.format("   高石阶 carry=%s phase=%s", tostring(p.carryOn), tostring(p.phase)))
	walkTo(p, i, p.ox + 1005, 300)
	drain(p)
	p = switchRoom(p, "escort1", run, "B 首场护送")
	print(string.format("   操控=%s 背负=%s 血=%d/%d 同伴=(%.0f,%.0f) 周戍=(%.0f,%.0f)",
		p.childMode and "小满" or "周戍", tostring(p.carryOn), p.hp, p.maxHp,
		p.partner.x, p.partner.y, p.player.x, p.player.y))
	step(p, i)

	-- 慢时换弹：开火 → 3×3 盘 → 三种连线各演示一次。
	local function demo(effectTag, path, enemyX)
		-- 上一轮装填先走完，世界全速下 54 拍。
		p.enemies = {}
		steps(p, i, 60)
		drain(p)
		p:shoot(p.player)
		drain(p)
		print(string.format("   开火后开盘 open=%s reloadT=%d", tostring(p.reloadOpen), p.reloadT))
		for k = 2, #path do
			p:reloadTapNode(path[k])
		end
		drain(p)
		print(string.format("   %s 结算 effect=%s answer=%d world=%d path=%d",
			effectTag, tostring(p.reloadPendingEffect), p.reloadAnswerTicks,
			p.reloadWorldTicks, #p.reloadPath))
		-- 线盘结算后装填仍要走完，才能开下一枪。
		steps(p, i, 60)
		drain(p)
		p.enemies = {
			{ x = enemyX, y = 0, depth = 0, w = 26, h = 84, alive = true, hitT = 0, warnT = 0,
				kind = "gunner", shieldHp = 0, drop = "none", awake = true, fireCd = 0 },
		}
		p:aimAt(enemyX, 60)
		p:shoot(p.player)
		drain(p)
		print(string.format("   首发 %s 消费后待发=%s 敌存活=%s", effectTag,
			tostring(p.reloadPendingEffect), tostring(p.enemies[1].alive)))
		p.enemies = {}
	end

	demo("推退", { 0, 3, 6, 7, 8 }, p.player.x + 90)
	demo("回声", { 0, 1, 4, 5, 8 }, p.player.x + 120)
	demo("照明", { 0, 1, 2, 5, 8 }, p.player.x + 150)

	-- 安全出口：走到 exitX。
	p.enemies = {}
	p.run.joined = true
	p.player.x = p.room.campaign.exitX + 4
	p.partner.x = p.player.x - 12
	step(p, i)
	drain(p)
	print(string.format("   出口 want=%s objectiveDone=%s", tostring(p.wantRoom), tostring(p.objectiveDone)))
	p = switchRoom(p, "outside", run, "B 城外")
	print(string.format("   男主城外 hp=%d/%d route=%s carry=%s tied=%s 控=%s", p.hp, p.maxHp,
		tostring(p.storyRoute), tostring(p.carryOn), tostring(p.tied), p.childMode and "小满" or "周戍"))
end

print("############ B1 端到端回放结束 ############")
