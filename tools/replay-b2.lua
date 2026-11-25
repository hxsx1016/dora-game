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
-- 门房 → 同行段 → escort1
local function throughGate(p, i, tag)
	local g = p.room.story.gate
	p.player.x = p.ox + g.doorX
	p.partner.x = p.ox + g.doorX + 30
	tap(i.interact)
	step(p, i)
	rel(i.interact)
	drain(p)
	print(string.format("   送别 phase=%s route=%s", tostring(p.phase), tostring(p.storyRoute)))
	for _ = 1, play.GATE_COUNT_END do
		step(p, i)
		if p.phase ~= "gate-count" then
			break
		end
	end
	drain(p)
	print(string.format("   数满 phase=%s count=%d route=%s", tostring(p.phase), p.countTick, tostring(p.storyRoute)))
	if p.phase == "gate-count" then
		i.moveX = 1
		step(p, i)
		step(p, i)
		rel(i)
		i.moveX = 0
		drain(p)
	else
		-- 男主线：两下轻叩后长按交互 36 拍。
		for _ = 1, 60 do
			step(p, i)
			if p.phase == "gate-wait" and p.phaseTick >= 12 then
				break
			end
		end
		i.interact.held = true
		i.interact.pressed = true
		local held = 0
		for _ = 1, 40 do
			step(p, i)
			held = held + 1
			if p.phase == "gate-hand" then
				break
			end
			i.interact.pressed = false
		end
		i.interact.held = false
		drain(p)
		print(string.format("   牵手 phase=%s handTicks=%d held=%d", tostring(p.phase), p.handTicks, held))
		steps(p, i, 100)
		drain(p)
	end
	local run = p.run
	if p.wantRoom == "" then
		-- 女主线：数满后要走出门洞。
		local okA = walkTo(p, i, p.ox + g.exitX + 4, 900)
		drain(p)
		print(string.format("   女主迈步 ok=%s x=%.1f phase=%s want=%s", tostring(okA), p.player.x,
			tostring(p.phase), tostring(p.wantRoom)))
	end
	if p.wantRoom ~= "" then
		p = switchRoom(p, p.wantRoom, run, tag .. " 同行")
	end
	return p
end

local function toEscort1(p, i, tag)
	p = throughGate(p, i, tag)
	if p.room.key == "outside" then
		print("   女主线直接进 outside")
		return p
	end
	p = switchRoom(p, "gatepath", p.run, tag .. " 同行段")
	drain(p)
	local gp = p.room.story.gatepath
	walkTo(p, i, p.ox + 845, 900)
	drain(p)
	print(string.format("   高石阶 carry=%s phase=%s", tostring(p.carryOn), tostring(p.phase)))
	walkTo(p, i, p.ox + gp.exitX + 4, 600)
	drain(p)
	if p.wantRoom ~= "" then
		p = switchRoom(p, p.wantRoom, p.run, tag .. " 首战")
	else
		print("   !! 同行段没交出 escort1: " .. tostring(p.phase))
	end
	return p
end

local function throughSegments(p, i, tag)
	-- escort1 → escort2
	p = switchRoom(p, "escort2", p.run, tag .. " 粮棚")
	drain(p)
	local inv = p.run.inventory
	p.player.x = 380; p.player.y = 0
	step(p, i)
	drain(p)
	p.player.x = 560
	step(p, i)
	drain(p)
	p.player.x = 820; p.player.y = 64; p.player.depth = -24; p.player.onGround = true; p.player.vy = 0
	step(p, i)
	drain(p)
	print(string.format("   粮棚取材 wood=%d bell=%d", inv.wood, inv.bell))
	p.player.x = p.room.campaign.exitX + 4
	p.partner.x = p.player.x - 20
	step(p, i)
	drain(p)
	if p.wantRoom ~= "" then
		p = switchRoom(p, p.wantRoom, p.run, tag .. " 工台")
	else
		error("粮棚出口未触发")
	end

	-- escort3：开面板、做灯铳、试射
	drain(p)
	p.player.x = 640; p.player.y = 0
	tap(i.interact)
	step(p, i)
	rel(i.interact)
	drain(p)
	print(string.format("   工台 open=%s recipes=%d wood=%d bell=%d equipped=%s",
		tostring(p.craftBench.active), #p.craftBench.recipes, p.run.inventory.wood,
		p.run.inventory.bell, tostring(p.equippedWeapon)))
	p:craftAtBench("guide_lantern_gun", "replay-light")
	drain(p)
	print("   改制灯铳 装备=" .. tostring(p.equippedWeapon) .. " wood=" .. p.run.inventory.wood)
	p:closeCraftBench()
	step(p, i)
	drain(p)
	print("   离站背起 carry=" .. tostring(p.carryOn))
	p.reloadPendingEffect = "light"
	p:aimAt(820, 60)
	p:shoot(p.player)
	drain(p)
	p:closeReloadPuzzle()
	for _ = 1, 60 do step(p, i) end
	p.player.x = p.room.campaign.exitX + 4
	p.partner.x = p.player.x - 20
	step(p, i)
	drain(p)
	if p.wantRoom ~= "" then
		p = switchRoom(p, p.wantRoom, p.run, tag .. " 山道四")
	else
		print(string.format("   !! 工台出口 x=%.1f exitX=%s obj=%s joined=%s partner=%.1f",
			p.player.x, tostring(p.room.campaign.exitX), tostring(p.objectiveDone),
			tostring(p.run.joined), p.partner.x))
		error("工台出口未触发")
	end

	-- escort4：开换弹盘 + 滚身脱出
	drain(p)
	p.player.x = 200
	p:beginReload()
	drain(p)
	print("   山道四 换弹盘 open=" .. tostring(p.reloadOpen) .. " effect=" .. tostring(p.reloadPendingEffect))
	p:reloadTapNode(4)
	p:reloadTapNode(5)
	p:reloadTapNode(8)
	drain(p)
	print("   连线完成 pending=" .. tostring(p.reloadPendingEffect))
	p:closeReloadPuzzle()
	p.player.x = p.room.campaign.exitX + 4
	p.partner.x = p.player.x - 20
	step(p, i)
	drain(p)
	if p.wantRoom ~= "" then
		p = switchRoom(p, p.wantRoom, p.run, tag .. " 山道五")
	else
		error("山道四出口未触发")
	end

	-- escort5 → tower
	drain(p)
	p.player.x = p.room.campaign.exitX + 4
	p.partner.x = p.player.x - 20
	step(p, i)
	drain(p)
	if p.wantRoom ~= "" then
		p = switchRoom(p, p.wantRoom, p.run, tag .. " 北塔")
	else
		error("山道五出口未触发")
	end
	return p
end

local function towerEnding(p, i, tag)
	drain(p)
	local t = p.room.story.tower
	p.player.x = p.ox + t.doorX
	tap(i.interact)
	step(p, i)
	rel(i.interact)
	steps(p, i, 40)
	drain(p)
	print("   敲门两下 完成 phase=" .. tostring(p.phase) .. " knocks=" .. tostring(p.knocks))
	steps(p, i, 200)
	drain(p)
	print(string.format("   结局 phase=%s ending=%s archive soldier=%s child=%s artifact=%s carry=%s",
		tostring(p.phase), tostring(p.run.story.ending),
		tostring(p.run.archive.soldierCleared), tostring(p.run.archive.childCleared),
		tostring(p.run.archive.artifactOwned), tostring(p.carryOn)))
	print(string.format("   存档读数 血=%d/%d 种子=%d 装备=%s 木=%d 铃=%d",
		p.hp, p.maxHp, p.run.seed, tostring(p.equippedWeapon),
		p.run.inventory.wood, p.run.inventory.bell))
	tap(i.interact)
	step(p, i)
	drain(p)
	print("   再玩 want=" .. tostring(p.wantRoom))
	return p
end

print("########## 路线 B：男主团圆 ##########")
local rb = runmod.createRun(20261125)
local pb, ib = toGate(rb, "B", 3)
pb = toEscort1(pb, ib, "B")
if pb.room.key == "escort1" then
	pb = throughSegments(pb, ib, "B")
	pb = towerEnding(pb, ib, "B")
end

print("########## 路线 A：女主留灯（对照） ##########")
local ra = runmod.createRun(20261125)
local pa, ia = toGate(ra, "A", 2)
pa = throughGate(pa, ia, "A")
print(string.format("   A 出口 room=%s phase=%s route=%s 控=%s", pa.room.key, tostring(pa.phase),
	tostring(pa.storyRoute), pa.childMode and "小满" or "周戍"))
-- 女主线：村口、林缘是 A 单已验证的旧路，这里按预设快进直接切到塔前看留灯。
pa = switchRoom(pa, "village", pa.run, "A 村口")
pa = switchRoom(pa, "forest", pa.run, "A 林缘")
pa = switchRoom(pa, "tower", pa.run, "A 北塔")
pa = towerEnding(pa, ia, "A")
