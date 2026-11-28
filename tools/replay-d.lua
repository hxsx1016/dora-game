-- D 整合回放：从正式标题入口（app 钩子 startStory，等价标题「开始游戏」菜单项）
-- 进入 official 新局，然后按输入逐拍推进：
--   序章递针套 → 街口 → 检查点推车 → 城门守点 → 送别/数数/牵手
--   → 高石阶背起 → 五段护送（含换弹盘） → 北塔结局
-- 两条路线各跑一遍：带伤 2/3 → 城外、空村、密林、北塔留灯；满血 3/3 → 护送团圆。
-- 分线前沿用街道/检查站的短回放夹具，守点快进。小满分线后的切房必须由输入触发。
--
-- 入口方式（脚本放仓库根，输出进引擎日志）：
--   Dora cli run -p . --entry tmp-replay-d.lua
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
		elseif e.name == "cartDocked" then
			detail = "axle=" .. tostring(data.axle)
		elseif e.name == "segmentDone" then
			detail = tostring(data.key) .. " next=" .. tostring(data.next)
		elseif e.name == "benchCraft" then
			detail = tostring(data.recipe) .. " " .. tostring(data.weapon)
		elseif e.name == "endingReached" then
			detail = "ending=" .. tostring(data.ending) .. " official=" .. tostring(data.official) .. " source=" .. tostring(data.source)
		elseif e.name == "artifactFound" then
			detail = "x=" .. tostring(data.x) .. " once=" .. tostring(data.once)
		elseif e.name == "museumStep" or e.name == "museumDone" then
			detail = tostring(data.step) .. " seen=" .. tostring(data.museumSeen)
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
	drain(prev)
	return room(tag, key, run)
end

local function toDepth(p, i, target, maxTicks)
	rel(i)
	for n = 1, maxTicks or 90 do
		local d = p.player.depth
		
		if math.abs(d - target) <= 6 then
			i.moveY = 0
			step(p, i)
			return true
		end
		i.moveY = d < target and -1 or 1
		step(p, i)
		if n == 3 and target == 0 then
			for _, b in ipairs(p.boxes) do
				if b.x0 <= p.player.x + 15 and b.x1 >= p.player.x - 15 then
					local fp = b.depth
					print(string.format("   ovl x=%s-%s y=%s-%s fp=%s pass=%s", tostring(b.x0), tostring(b.x1), tostring(b.y0), tostring(b.y1), fp and (tostring(fp.min) .. ".." .. tostring(fp.max)) or "nil", tostring(b.passable)))
				end
			end
		end
	end
	i.moveY = 0
	return false
end

local function walkTo(p, i, worldX, maxTicks)
	i.moveX = 0
	local lastX = p.player.x
	local stuck = 0
	for _ = 1, maxTicks or 900 do
		local dx = worldX - p.player.x
		if math.abs(dx) <= 6 then
			i.moveX = 0
			step(p, i)
			return true
		end
		i.moveX = dx > 0 and 1 or -1
		if p.player.onGround then
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

-- 真实走位击发：把房间里的活人清掉（夹具），只验证路线可达与出口。
-- 传送带式的战斗另见 verify-b2 / replay-b2；这里 D 线只核对切房与操控权。
local function clearFoes(p)
	p.enemies = {}
	p.dogState = "gone"
end

-- 正式入口：标题「开始游戏」调用的同一入口函数 watch.fe.startStory()
-- 回放全程用隔离档案：绝不读写玩家 watch-save/archive.txt。
do
	local wf = package.loaded["watch.fe"]
	if wf ~= nil and wf.useTestSave ~= nil then
		wf.useTestSave("watch-save/test-replay-d.txt")
	end
end

local function officialEntry(tag)
	local wf = package.loaded["watch.fe"]
	if wf == nil or wf.startStory == nil then
		error("watch.fe.startStory 不可用（需先在引擎跑 init.lua）")
	end
	local p = wf.startStory()
	print(string.format("[D 入口] %s · app.startStory → room=%s source=%s seed=%s screen=%s",
		tag, p.room.key, p.run.source, tostring(p.run.seed), tostring(wf.getFrontend().screen)))
	return p
end

-- 序章 → 街口：真实按方向键绕过石柱，走近小满按 E 递针套，再跟到门口。
local function prologueOut(p, i, tag)
	print(string.format("[%s 序章] phase=%s 控=%s", tag, p.phase, p.childMode and "小满" or "周戍"))
	-- P01 叫醒 4s + P02 墙影 2s：演出锁控，等它自己过去。
	if p.phase == "prologue-wake" or p.phase == "prologue-shadow" then
		local guard = 0
		while (p.phase == "prologue-wake" or p.phase == "prologue-shadow") and guard < 420 do
			step(p, i); guard = guard + 1
		end
		print(string.format("  [序章] 演出后 phase=%s", p.phase))
	end
	-- 限时逃柜：控制权已交给门口的小满，按右跑到倒柜左缘。
	if p.phase == "prologue-escape" then
		toDepth(p, i, 32, 40)        -- 贴里道绕石柱（110-148 高 84 只挡 lower/middle）
		i.moveX = 1
		local guard = 0
		while p.phase == "prologue-escape" and guard < 480 do
			step(p, i); guard = guard + 1
		end
		i.moveX = 0
		print(string.format("  [序章] 逃柜后 phase=%s x=%.1f 剩=%.1f 重试=%d",
			p.phase, p.player.x, p.escapeRemaining, p.escapeRetryCount))
	end
	if p.phase == "prologue-hide" then
		steps(p, i, 60)            -- 0.85s 收红晕/脚步，随后切回周戍
		print(string.format("  [序章] 入柜后 phase=%s 控=%s 小满=%.1f",
			p.phase, p.childMode and "小满" or "周戍", p.partner.x))
	end
	if p.phase == "prologue-wait" then
		walkTo(p, i, p.ox + 285, 120)
		toDepth(p, i, 0, 40)
		print(string.format("  [序章] 交互前 x=%.1f 小满=%.1f depth=%.1f/%.1f",
			p.player.x, p.partner.x, p.player.depth, p.partner.depth))
		tap(i.interact)
		step(p, i)
		rel(i.interact)
		steps(p, i, 190)           -- PR #22 prologue-give 180 拍（3s 拂瓷递针套）后转 follow
		print(string.format("[%s 序章] 递针套后 phase=%s", tag, p.phase))
	end
	toDepth(p, i, 32, 40)        -- 绕开 x=344 中下道石柱，沿上道前行
	walkTo(p, i, p.ox + 420, 220)
	toDepth(p, i, 0, 40)         -- 切回中道穿出 x=648 门洞
	walkTo(p, i, p.ox + 700, 400)
	steps(p, i, 30)
	if p.wantRoom ~= "" then
		return switchRoom(p, "street", p.run, tag .. " 街口")
	end
	return p
end

local function streetOut(p, i, tag)
	walkTo(p, i, p.ox + 940, 400)
	steps(p, i, 40)
	if p.wantRoom ~= "" then
		return switchRoom(p, "checkpoint", p.run, tag .. " 检查点")
	end
	return p
end

local function checkpointOut(p, i, tag)
	clearFoes(p)
	walkTo(p, i, p.room.cart.startX + p.room.cart.handleOffset, 500)
	tap(i.interact)
	step(p, i)
	print(string.format("[%s 检查点] gripping=%s axle=%.1f", tag, tostring(p.gripping), p.cartAxle))
	i.moveX = 1
	local guard = 0
	while p.wantRoom == "" and guard < 600 do
		step(p, i)
		guard = guard + 1
		if guard % 40 == 0 then
			print(string.format("   push g=%d guard=%d cart=%.1f grip=%s docked=%s x=%.1f", 0, guard, p.cartAxle, tostring(p.gripping), tostring(p.cartDocked), p.player.x))
		end
	end
	i.moveX = 0
	i.interact.held = false
	walkTo(p, i, p.ox + 900, 300)
	i.moveX = 1
	steps(p, i, 5)
	i.moveX = 0
	steps(p, i, 220)
	print(string.format("[%s 检查点] 门口 gateOpen=%s 周戍=%.1f 小满=%.1f escort=%s facing=%d", tag, tostring(p.gateOpen), p.player.x, p.partner.x, tostring(p.escort.state), p.player.facing))
	if p.wantRoom ~= "" then
		return switchRoom(p, "gate", p.run, tag .. " 城门")
	end
	return p
end

-- 城门前半段：真实走到绞盘，守点快进到末拍（标注快进）。
local function gateUpToHold(p, i, tag, hp)
	clearFoes(p)
	walkTo(p, i, p.ox + 118, 300)
	steps(p, i, 340)
	if p.phase ~= "gate-hold" then
		print(string.format("[%s 城门] 未进守点 phase=%s x=%.1f 小满=%.1f", tag, p.phase, p.player.x, p.partner.x))
		return p
	end
	print(string.format("[%s 城门] 守点开始 hp=%d/%d", tag, p.hp, p.maxHp))
	-- 快进：守点 2700 拍太长，直接到末拍前；敌兵与掩体逻辑见 verify-d6。
	p.gateTick = p.room.story.gate.holdTicks - 1
	p.gateSpawned = 4
	p.enemies = {}
	steps(p, i, 2)
	print(string.format("[%s 城门] 守满 phase=%s hp=%d/%d 血锁=%s/%s", tag, p.phase, p.hp, p.maxHp,
		tostring(p.hpAtGate), tostring(p.maxHpAtGate)))
	return p
end

local function gateSend(p, i, tag)
	clearFoes(p)
	if p.phase == "gate-hold" then
		p.gateTick = p.room.story.gate.holdTicks - 1
		p.gateSpawned = 4
		p.enemies = {}
		steps(p, i, 2)
	end
	walkTo(p, i, p.ox + p.room.story.gate.doorX - 30, 260)
	steps(p, i, 10)
	tap(i.interact)
	step(p, i)
	rel(i.interact)
	steps(p, i, 230)               -- PR #22 gate-farewell 220 拍（P05 城门送别）后进入 gate-count
	print(string.format("[%s 门洞] phase=%s 控=%s route=%s", tag, p.phase, p.childMode and "小满" or "周戍", tostring(p.storyRoute)))
	return p
end

-- 女主线：数满 1440 拍，等新方向输入迈步出城。
local function childCountAndWalk(p, i, tag)
	steps(p, i, 1450)
	print(string.format("[%s 数数] countTick=%d route=%s", tag, p.countTick, tostring(p.storyRoute)))
	i.moveX = 1
	step(p, i)
	steps(p, i, 120)
	i.moveX = 0
	print(string.format("[%s 迈步] phase=%s x=%.1f want=%s", tag, p.phase, p.player.x, p.wantRoom))
	if p.wantRoom ~= "" then
		return switchRoom(p, "outside", p.run, tag .. " 城外")
	end
	return p
end

-- 男主线：数满转 gate-wait，两下轻叩，按住 E 满 36 拍牵手。
local function soldierHand(p, i, tag)
	steps(p, i, 1450)
	print(string.format("[%s 数满] phase=%s route=%s knocks=%d", tag, p.phase, tostring(p.storyRoute), p.knocks))
	steps(p, i, 14)
	print(string.format("[%s 轻叩] knocks=%d handArmed=%s", tag, p.knocks, tostring(p.handArmed)))
	i.interact.held = true
	i.interact.pressed = true
	local guard = 0
	while p.phase ~= "gate-hand" and guard < 60 do
		step(p, i)
		guard = guard + 1
	end
	print(string.format("[%s 牵手] phase=%s handTicks=%d/%d tied=%s", tag, p.phase, p.handTicks, p.handNeedTicks, tostring(p.tied)))
	i.interact.held = false
	i.interact.pressed = false
	steps(p, i, 100)
	print(string.format("[%s 出门] x=%.1f want=%s", tag, p.player.x, p.wantRoom))
	if p.wantRoom ~= "" then
		return switchRoom(p, "gatepath", p.run, tag .. " 同行段")
	end
	return p
end

local function gatepathOut(p, i, tag, nextKey)
	clearFoes(p)
	walkTo(p, i, p.ox + 850, 320)
	print(string.format("[%s 高石阶] phase=%s carry=%s 小满=(%.1f,%.1f) 周戍=(%.1f,%.1f)",
		tag, p.phase, tostring(p.carryOn), p.partner.x, p.partner.y, p.player.x, p.player.y))
	walkTo(p, i, p.ox + 990, 320)
	if p.wantRoom ~= "" then
		return switchRoom(p, nextKey, p.run, tag .. " 护送一")
	end
	return p
end

-- 护送段：真实走到出口（清敌为走位夹具，战斗判定见 verify-b2）。

local function reloadDemo(p, i, tag)
	clearFoes(p)
	p:shoot(p.player)
	step(p, i)
	if not p.reloadOpen then
		print(string.format("[%s 换弹] 未开盘 hp=%d/%d", tag, p.hp, p.maxHp))
		return
	end
	print(string.format("[%s 换弹] 开盘 answer=%d world=%d try=%d", tag, p.reloadAnswerTicks, p.reloadWorldTicks, p.reloadTryCount))
	for _, node in ipairs({ 1, 2, 5, 8 }) do
		p:reloadTapNode(node)
		steps(p, i, 8)
	end
	print(string.format("[%s 换弹] 画完 open=%s effect=%s answer=%d world=%d", tag, tostring(p.reloadOpen), tostring(p.reloadPendingEffect), p.reloadAnswerTicks, p.reloadWorldTicks))
	steps(p, i, 80)
	p:shoot(p.player)
	step(p, i)
	print(string.format("[%s 换弹] 消费后 open=%s effect=%s", tag, tostring(p.reloadOpen), tostring(p.reloadPendingEffect)))
end

local function segmentOut(p, i, tag, key)
	clearFoes(p)
	local campaign = p.room.campaign
	if campaign == nil then
		return p
	end
	walkTo(p, i, p.ox + campaign.exitX + 12, 900)
	steps(p, i, 80)
	print(string.format("[%s %s] objective=%s x=%.1f partner=%.1f want=%s",
		tag, key, tostring(p.objectiveDone), p.player.x, p.partner.x, p.wantRoom))
	if p.wantRoom ~= "" then
		return switchRoom(p, campaign.next, p.run, tag .. " " .. campaign.next)
	end
	return p
end

-- 第三段工台：开面板、做引路灯铳、关面板，再走出出口。
local function benchCraft(p, i, tag)
	clearFoes(p)
	walkTo(p, i, p.ox + 600, 300)
	steps(p, i, 10)
	tap(i.interact)
	step(p, i)
	rel(i.interact)
	steps(p, i, 6)
	print(string.format("[%s 工台] active=%s equipped=%s wood=%d bell=%d",
		tag, tostring(p.craftBench.active), tostring(p.equippedWeapon), p.inventory.wood, p.inventory.bell))
	-- 走前端意图通道（与前端 craftSubmit 同一入口）
	p:submitFeIntent({ kind = "craftSubmit", recipeId = "guide_lantern_gun", requestId = "d-run-1" })
	steps(p, i, 4)
	print(string.format("[%s 工台] crafted=%s equipped=%s wood=%d bell=%d recipes=%d",
		tag, tostring(p.craftBench.firstCraftDone), tostring(p.equippedWeapon), p.inventory.wood, p.inventory.bell, #p.craftBench.recipes))
	p:submitFeIntent({ kind = "craftClose" })
	steps(p, i, 4)
	print(string.format("[%s 工台] 关闭 active=%s carry=%s", tag, tostring(p.craftBench.active), tostring(p.carryOn)))
end

local function towerEnd(p, i, tag)
	clearFoes(p)
	walkTo(p, i, p.ox + 430, 500)
	steps(p, i, 8)
	tap(i.interact)
	step(p, i)
	rel(i.interact)
	-- 等 36 拍守卒回叩开门（进入 tower-enter），跨过门槛到值夜桌前长按 E 交物（36 拍）
	steps(p, i, 42)
	walkTo(p, i, p.ox + 545, 240)
	i.interact.held = true
	steps(p, i, 38)
	i.interact.held = false
	steps(p, i, 200)
	print(string.format("[%s 北塔] phase=%s ending=%s officialLines=%s/%s archive={child=%s soldier=%s artifact=%s}",
		tag, p.phase, tostring(p.run.story.ending), tostring(p.endingLines[1]), tostring(p.endingLines[2]),
		tostring(p.archive.childCleared), tostring(p.archive.soldierCleared), tostring(p.archive.artifactOwned)))
	steps(p, i, 20)
	if p.wantRoom ~= "" then
		return switchRoom(p, "prologue", p.run, tag .. " 片尾")
	end
	return p
end

-- ===== 路线 B：满血 → 男主线 → 团圆 =====
local function runSoldier()
	print("######## D 路线 B · 正式入口 → 男主线 ########")
	local p = officialEntry("B")
	local i = newInput()
	p = prologueOut(p, i, "B")
	p = streetOut(p, i, "B")
	p = checkpointOut(p, i, "B")
	p = gateUpToHold(p, i, "B", 3)
	p = gateSend(p, i, "B")
	p = soldierHand(p, i, "B")
	p = gatepathOut(p, i, "B", "escort1")
	p = segmentOut(p, i, "B", "escort1")
	reloadDemo(p, i, "B")
	p = segmentOut(p, i, "B", "escort2")
	benchCraft(p, i, "B")
	p = segmentOut(p, i, "B", "escort3")
	p = segmentOut(p, i, "B", "escort4")
	p = segmentOut(p, i, "B", "escort5")
	p = segmentOut(p, i, "B", "escort5")
	p = towerEnd(p, i, "B")
	print(string.format("[D-B 存档] route=%s ending=%s source=%s hp=%d/%d seed=%s equip=%s wood=%d bell=%d",
		tostring(p.run.story.route), tostring(p.run.story.ending), p.run.source, p.hp, p.maxHp,
		tostring(p.run.seed), tostring(p.equippedWeapon), p.inventory.wood, p.inventory.bell))
end

-- ===== 路线 A：带伤 2/3 → 女主线 → 城外留灯 =====
local function runChild()
	print("######## D 路线 A · 正式入口 → 女主线 ########")
	local p = officialEntry("A")
	p.hp = 2
	p.maxHp = 3
	local i = newInput()
	p = prologueOut(p, i, "A")
	p = streetOut(p, i, "A")
	p = checkpointOut(p, i, "A")
	p = gateUpToHold(p, i, "A", 2)
	p = gateSend(p, i, "A")
	p = childCountAndWalk(p, i, "A")
	print(string.format("[D-A 存档] route=%s hp=%d/%d seed=%s want(outside后)=%s",
		tostring(p.run.story.route), p.hp, p.maxHp, tostring(p.run.seed), tostring(p.wantRoom)))
	assert(p.room.key == "outside" and p.storyRoute == "child", "带伤送别后应进入小满城外线")
	assert(walkTo(p, i, p.cartAxle + p.room.cart.handleOffset), "未到城外右柄")
	tap(i.interact)
	step(p, i)
	i.moveX = 1
	for _ = 1, 200 do
		step(p, i)
		if p.cartDocked then break end
	end
	i.moveX = 0
	rel(i.interact)
	assert(p.cartDocked and p.run.story.segments.outside_memory, "红布车未入窝")
	walkTo(p, i, 54)
	steps(p, i, 30)
	i.crouch.held = true
	walkTo(p, i, 400)
	assert(p.checkpoint == 380, "未从下层蹲过矮拱")
	i.crouch.held = false
	walkTo(p, i, 1160)
	assert(p.wantRoom == "village", "墙根尽头未进空村")
	p = switchRoom(p, p.wantRoom, p.run, "A 村口")
	walkTo(p, i, p.room.bottle.x)
	tap(i.interact)
	step(p, i)
	rel(i.interact)
	assert(p.hasBottle, "空村未拾瓶")
	p:aimAt(p.room.brickX, 34)
	i.aim.held = true
	steps(p, i, 40)
	i.aim.held, i.aim.released = false, true
	step(p, i)
	i.aim.released = false
	i.crouch.held = true
	walkTo(p, i, p.ox + 610)
	assert(p.wantRoom == "forest", "未蹲入空村暗渠")
	p = switchRoom(p, p.wantRoom, p.run, "A 林缘")
	walkTo(p, i, p.ox + 1460, 1800)
	i.crouch.held = false
	assert(p.wantRoom == "tower" and p.waterSeen, "未越过溪湾抵达北塔")
	p = switchRoom(p, p.wantRoom, p.run, "A 塔前")
	p = towerEnd(p, i, "A")
	assert(p.phase == "tower-end" and p.towerHanded and p.run.story.ending == "lamp"
		and p.archive.childCleared, "北塔交物后未达正式留灯结局")
	print(string.format("[D-A 结局] ending=%s child=%s artifact=%s",
		tostring(p.run.story.ending), tostring(p.archive.childCleared), tostring(p.archive.artifactOwned)))
end

runSoldier()
runChild()
print("D 整合回放完成")
