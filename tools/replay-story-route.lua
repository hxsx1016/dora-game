-- 正式剧情双出口回放：从序章入口一路真实切房到城门，再分两条线各出一次城。
--
-- 这不是断言脚本，是把玩家路线逐拍打印出来，便于对照交付读数。
-- 切房与 app.ts 的 ensurePlay 同构：wantRoom 登记后新建 Play，run 跨房继承。
-- 守点战斗本身另见 replay-gate.lua，这里把 gateTick 推到最后一拍，只验证
-- 「锁线 → 送别 → 数数 → 两条出口」这一段。
--
-- 用法（引擎内）：dofile("tools/replay-story-route.lua")
-- 入口方式（输出进引擎日志）：
--   Dora cli run -p . --entry tools/replay-story-route.lua（从仓库根运行）

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
	i.pause.released = false
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
			detail = "route=" .. tostring(data.route) .. " hp=" .. tostring(data.hp) .. "/" .. tostring(data.maxHp)
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
		elseif e.name == "gatePathEnd" then
			detail = "x=" .. tostring(data.x)
		elseif e.name == "cartDocked" then
			detail = "axle=" .. tostring(data.axle)
		end
		print(string.format("  [t%4d] %-18s %s", e.tick, e.name, detail))
	end
	return bag
end

local function room(tag, key, run)
	for idx, r in ipairs(rooms.ROOMS) do
		if r.key == key then
			local p = lualib.__TS__New(play.Play, rooms.ROOMS[idx], nil, run)
			print(string.format("== %s · %s (%s) ox=%.0f 周戍=%.0f 小满=%.0f 血=%d/%d route=%s",
				tag, key, r.name, p.ox, p.player.x, p.partner.x, p.hp, p.maxHp, tostring(p.storyRoute)))
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
			print(string.format("   切房事件 seq=%d tick=%d %s→%s", e.seq, e.tick, tostring(e.data.from), tostring(e.data.to)))
		end
	end
	next:adoptEvents(leaving)
	return next
end

-- 走到目标 x：每拍纠偏，容差 6px。
local function walkTo(p, i, worldX, maxTicks)
	i.moveX = 0
	local lastX = p.player.x
	local stuck = 0
	for _ = 1, maxTicks or 600 do
		local dx = worldX - p.player.x
		if math.abs(dx) <= 6 then
			i.moveX = 0
			step(p, i)
			return true
		end
		i.moveX = dx > 0 and 1 or -1
		-- 同行段有一块倒石：贴着走不动就跳过去，模拟玩家按空格。
		if p.room.key == "gatepath" and p.player.onGround then
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

local function countToEnd(p, i)
	for _ = 1, play.GATE_COUNT_END do
		step(p, i)
		if p.phase ~= "gate-count" then
			break
		end
	end
end

print("############ 路线 A：带伤送别 → 小满数完迈步出城 ############")
local runA = runmod.createRun()
local p = room("A1 序章", "prologue", runA)
local i = newInput()
p.player.x = p.partner.x + 20
p.player.depth = p.partner.depth
p.player.y = p.partner.y
tap(i.interact)
step(p, i)
rel(i.interact)
drain(p)
print(string.format("   序章递针套 phase=%s", tostring(p.phase)))
steps(p, i, 70)
print(string.format("   序章 follow phase=%s x=%.0f 小满=%.0f", tostring(p.phase), p.player.x - p.ox, p.partner.x - p.ox))
p.player.x = p.ox + 660
p.partner.x = p.ox + 620
step(p, i)
drain(p)
p = switchRoom(p, "street", runA, "A2 街口")
drain(p)
p.player.x = p.ox + 900
p.partner.x = p.ox + 860
step(p, i)
drain(p)
p = switchRoom(p, "checkpoint", runA, "A3 城门检查点")
drain(p)

-- 车把在 axle-40；先握把，再按住 D 把车推到 endX=768。
local cart = p.room.cart
i = newInput()
p.player.x = cart.startX + cart.handleOffset
p.player.depth = cart.depth or 0
p.player.y = 0
tap(i.interact)
step(p, i)
rel(i.interact)
print(string.format("   握把 gripping=%s axle=%.0f", tostring(p.gripping), p.cartAxle))
i.moveX = 1
i.interact.held = true
for _ = 1, 400 do
	step(p, i)
	if p.cartDocked then
		break
	end
end
i.moveX = 0
rel(i.interact)
drain(p)
print(string.format("   推车 cartDocked=%s axle=%.0f 周戍=%.0f", tostring(p.cartDocked), p.cartAxle, p.player.x - p.ox))
p.player.x = p.ox + 850
p.partner.x = p.ox + 850
step(p, i)
print(string.format("   门开 gateOpen=%s", tostring(p.gateOpen)))
p.player.x = p.ox + 900
step(p, i)
drain(p)
p = switchRoom(p, "gate", runA, "A4 城门")
drain(p)

-- 守点末拍：小满先到 950，周戍贴住绞盘；敌人已出齐，最后一拍伤害之后结算血量。
i = newInput()
p.partner.x = p.ox + 950
p.player.x = p.ox + 118
p.player.y = 0
p.player.depth = 0
p.phase = "gate-hold"
p.gateTick = p.room.story.gate.holdTicks - 1
p.gateSpawned = 4
p.enemies = {}
p.hp = 2
step(p, i)
drain(p)
print(string.format("== 守点末拍 phase=%s hp=%d/%d", tostring(p.phase), p.hp, p.maxHp))
step(p, i)
drain(p)
print(string.format("== 锁线 phase=%s route=%s hpAtGate=%d/%d", tostring(p.phase), tostring(p.storyRoute), p.hpAtGate, p.maxHpAtGate))
p.player.x = p.ox + 860
tap(i.interact)
step(p, i)
rel(i.interact)
print(string.format("== 送别 phase=%s countTick=%d 控小满=%s", tostring(p.phase), p.countTick, tostring(p.childMode)))
countToEnd(p, i)
drain(p)
print(string.format("== 数到二十 phase=%s countTick=%d route=%s", tostring(p.phase), p.countTick, tostring(p.storyRoute)))
i.moveX = 0
step(p, i)
i.moveX = 1
step(p, i)
print(string.format("== 新按 D phase=%s x=%.0f", tostring(p.phase), p.player.x - p.ox))
steps(p, i, 80)
drain(p)
print(string.format("== 走出门洞 phase=%s x=%.0f want=%s", tostring(p.phase), p.player.x - p.ox, p.wantRoom))
p = switchRoom(p, "outside", runA, "A5 城外")
drain(p)
print(string.format("== 城外 hp=%d/%d route=%s phase=%s x=%.0f", p.hp, p.maxHp, tostring(p.storyRoute), tostring(p.phase), p.player.x))

print("")
print("############ 路线 B：80% 门槛 → 小满长按牵起哥哥 → 同行段 ############")
local runB = runmod.createRun()
local q = room("B1 城门（直接从城门起，血量 3/3）", "gate", runB)
i = newInput()
q.partner.x = q.ox + 950
q.player.x = q.ox + 118
q.player.y = 0
q.player.depth = 0
q.phase = "gate-hold"
q.gateTick = q.room.story.gate.holdTicks - 1
q.gateSpawned = 4
q.enemies = {}
q.hp = 3
step(q, i)
drain(q)
step(q, i)
drain(q)
print(string.format("== 锁线 route=%s hpAtGate=%d/%d（3/3 ≥ 80%%）", tostring(q.storyRoute), q.hpAtGate, q.maxHpAtGate))
q.player.x = q.ox + 860
tap(i.interact)
step(q, i)
rel(i.interact)
countToEnd(q, i)
drain(q)
print(string.format("== 数到二十 phase=%s countTick=%d route=%s", tostring(q.phase), q.countTick, tostring(q.storyRoute)))
-- 待机两下轻叩：第 12 拍第二下。
steps(q, i, 20)
drain(q)
print(string.format("== 待机 phase=%s knocks=%d handTicks=%d", tostring(q.phase), q.knocks, q.handTicks))
-- 按住 E 到 36 拍牵手；先跑到 35 拍读数，再补一拍。
tap(i.interact)
step(q, i)
drain(q)
steps(q, i, 34)
print(string.format("== 按住 35 拍 phase=%s handTicks=%d", tostring(q.phase), q.handTicks))
step(q, i)
drain(q)
print(string.format("== 36 拍 phase=%s handTicks=%d tied=%s", tostring(q.phase), q.handTicks, tostring(q.tied)))
rel(i.interact)
steps(q, i, 90)
drain(q)
print(string.format("== 演出后 want=%s", q.wantRoom))
q = switchRoom(q, "gatepath", runB, "B2 同行段")
drain(q)
i = newInput()
walkTo(q, i, q.ox + 850, 400)
drain(q)
print(string.format("== 高石阶 phase=%s x=%.0f", tostring(q.phase), q.player.x - q.ox))
steps(q, i, 40)
drain(q)
print(string.format("== 同行段收尾 want=%s", q.wantRoom))
q = switchRoom(q, "outside", runB, "B3 城外")
drain(q)
print(string.format("== 城外 hp=%d/%d route=%s tied=%s x=%.0f", q.hp, q.maxHp, tostring(q.storyRoute), tostring(q.tied), q.player.x))

print("")
print("############ 回放小结 ############")
print(string.format("A 带伤送别：hpAtGate=%d/%d route=%s", runA.story.hpAtGate, runA.story.maxHpAtGate, tostring(runA.story.route)))
print(string.format("B 门槛达标：hpAtGate=%d/%d route=%s", runB.story.hpAtGate, runB.story.maxHpAtGate, tostring(runB.story.route)))
