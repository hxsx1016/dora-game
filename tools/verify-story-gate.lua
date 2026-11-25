-- 城门双出口回归：跨房血量、过门锁线、数数边沿、牵手长按与恢复。
--
-- 夹具直接构造门房 Play 并推到「守点末拍」，用脚本设阈值血量，
-- 覆盖 79/100 与 80/100、2/3 与 3/3、1439/1440 旧键与新按、
-- 牵手 35/36 拍、中途松手、暂停冻结、锁线后重试/续读。
--
-- 运行：引擎内 dofile("tools/verify-story-gate.lua")，
-- 或用入口方式（输出进引擎日志）：
--   Dora cli run -p . --entry tools/verify-story-gate.lua
-- 入口方式从 tools/ 目录解析 require，先把项目搜索路径补上。

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

local GATE = rooms.GATE_ROOM
local G = GATE.story.gate
local STEP = play.STEP

local pass, fail = 0, 0

-- 命令桥一次只回少量行，这里同时攒一份日志，末尾挂到全局供外层打印。
local LOG = {}
local function say(s)
	LOG[#LOG + 1] = s
	print(s)
end

local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		say("PASS  " .. tag .. (detail and ("  | " .. detail) or ""))
	else
		fail = fail + 1
		say("FAIL  " .. tag .. (detail and ("  | " .. detail) or ""))
	end
end

local function key()
	return { held = false, pressed = false, released = false }
end

local function newInput()
	local i = lualib.__TS__New(input.Input)
	i.moveX = 0
	i.moveY = 0
	i.jump = key()
	i.crouch = key()
	i.cover = key()
	i.interact = key()
	i.aim = key()
	i.fire = key()
	i.flare = key()
	i.pause = key()
	i.retry = key()
	i.toggleView = key()
	i.tab = key()
	i.pickRoom = 0
	i.mx = 0
	i.my = 0
	i.mdx = 0
	i.mdy = 0
	i.inside = true
	return i
end

local function clearEdges(i)
	i.interact.pressed = false
	i.interact.released = false
	i.jump.pressed = false
	i.jump.released = false
	i.crouch.pressed = false
	i.crouch.released = false
	i.cover.pressed = false
	i.cover.released = false
	i.aim.pressed = false
	i.aim.released = false
	i.fire.pressed = false
	i.fire.released = false
	i.pause.pressed = false
	i.pause.released = false
	i.retry.pressed = false
	i.retry.released = false
end

local function step(p, i)
	p:update(STEP, i)
	clearEdges(i)
end

local function steps(p, i, n)
	for _ = 1, n do
		step(p, i)
	end
end

local function drainInto(p, bag)
	for _, e in ipairs(p:drainEvents()) do
		bag[#bag + 1] = e
	end
end

local function hasEvent(bag, name)
	for _, e in ipairs(bag) do
		if e.name == name then
			return e
		end
	end
	return nil
end

local function storyRun(hp, maxHp)
	local r = runmod.createRun()
	r.story.hp = hp
	r.story.maxHp = maxHp
	return r
end

-- 守点末拍：敌兵已出齐、最后一拍的伤害已结进 hp，下一拍就进送别。
local function atHoldLastTick(hp, maxHp)
	local r = storyRun(hp, maxHp)
	local p = lualib.__TS__New(play.Play, GATE, nil, r)
	p.phase = "gate-hold"
	p.gateTick = G.holdTicks - 1
	p.gateSpawned = 4
	p.enemies = {}
	p.player.x = p.ox + G.winchX
	p.partner.x = p.ox + G.waitX
	return p, r
end

-- 送别数数：按一下 E 交控制权，然后松开等 24 秒。
local function toCount(p, i)
	p.phase = "gate-send"
	p.player.x = p.ox + G.doorX
	p.partner.x = p.ox + G.doorX + 30
	step(p, i)
	i.interact.held = true
	i.interact.pressed = true
	step(p, i)
	i.interact.held = false
	step(p, i)
end

-- 数满 1440 拍；数数期间不给任何输入。
local function countToEnd(p, i, bag)
	for n = 1, play.GATE_COUNT_END do
		step(p, i)
		if bag ~= nil then
			drainInto(p, bag)
		end
	end
end

local function routeCase(tag, hp, maxHp, want)
	local p, r = atHoldLastTick(hp, maxHp)
	local i = newInput()
	local bag = {}
	step(p, i)
	drainInto(p, bag)
	local locked = hasEvent(bag, "storyRouteLocked")
	check(tag, p.storyRoute == want,
		"hp=" .. hp .. "/" .. maxHp .. " route=" .. tostring(p.storyRoute)
		.. " hpAtGate=" .. tostring(p.hpAtGate) .. " maxHpAtGate=" .. tostring(p.maxHpAtGate)
		.. " phase=" .. tostring(p.phase))
	check(tag .. " 锁线事件", locked ~= nil and locked.data.route == want,
		locked ~= nil and ("route=" .. tostring(locked.data.route)) or "无 storyRouteLocked")
	check(tag .. " 快照落库", r.story.settled == true and r.story.route == want,
		"settled=" .. tostring(r.story.settled) .. " route=" .. tostring(r.story.route))
	return p, r, i
end

say("== 1. 80% 门槛与默认 3 格血 ==")
routeCase("79/100 走女主线", 79, 100, "child")
routeCase("80/100 走男主线", 80, 100, "soldier")
routeCase("2/3 走女主线", 2, 3, "child")
routeCase("3/3 走男主线", 3, 3, "soldier")

say("== 2. 男主线：数完、两下轻叩、长按 36 拍 ==")
do
	local p, r = atHoldLastTick(3, 3)
	local i = newInput()
	local bag = {}
	step(p, i)
	drainInto(p, bag)
	toCount(p, i)
	check("送别后进入数数", p.phase == "gate-count" and p.countTick <= 1,
		"phase=" .. tostring(p.phase) .. " countTick=" .. tostring(p.countTick))
	drainInto(p, bag)
	countToEnd(p, i, bag)
	check("1440 拍后转风台待机", p.phase == "gate-wait", "phase=" .. tostring(p.phase))
	local done = hasEvent(bag, "gateCountDone")
	check("数到二十事件", done ~= nil and done.data.route == "soldier",
		done ~= nil and ("route=" .. tostring(done.data.route)) or "无 gateCountDone")
	local knock1 = hasEvent(bag, "knock")
	-- knock 有两条：count=1 在数满当拍，count=2 在待机第 12 拍。
	local knock2 = nil
	steps(p, i, 12)
	drainInto(p, bag)
	for _, e in ipairs(bag) do
		if e.name == "knock" and e.data.count == 2 then
			knock2 = e
		end
	end
	check("两下轻叩", knock1 ~= nil and knock1.data.count == 1 and knock2 ~= nil,
		"knock1=" .. tostring(knock1 ~= nil) .. " knock2=" .. tostring(knock2 ~= nil))
	check("待机不改血量", p.hp == 3 and p.maxHp == 3, "hp=" .. p.hp .. "/" .. p.maxHp)

	-- 35 拍：还在等；第 36 拍才牵上。
	i.interact.held = true
	i.interact.pressed = true
	step(p, i)
	steps(p, i, 34)
	check("牵手 35 拍未完成", p.handTicks == 35 and p.phase == "gate-wait",
		"handTicks=" .. tostring(p.handTicks) .. " phase=" .. tostring(p.phase))
	step(p, i)
	drainInto(p, bag)
	check("牵手 36 拍完成", p.phase == "gate-hand" and p.handDone and p.tied,
		"phase=" .. tostring(p.phase) .. " handTicks=" .. tostring(p.handTicks) .. " tied=" .. tostring(p.tied))
	local held = hasEvent(bag, "handHeld")
	check("牵手事件", held ~= nil and held.data.handTicks == 36,
		held ~= nil and ("handTicks=" .. tostring(held.data.handTicks)) or "无 handHeld")
	local line = hasEvent(bag, "storyLine")
	check("台词只一次", line ~= nil and line.data.text == "我们走吧。",
		line ~= nil and tostring(line.data.text) or "无 storyLine")
	i.interact.held = false
	local more = {}
	for _ = 1, 120 do
		step(p, i)
		drainInto(p, more)
	end
	check("台词不重复", hasEvent(more, "storyLine") == nil, "多余 storyLine=" .. tostring(hasEvent(more, "storyLine") ~= nil))
	check("牵手演出后进同行段", p.wantRoom == "gatepath", "wantRoom=" .. tostring(p.wantRoom))
	local exit = hasEvent(more, "storyExit")
	check("男主线出口事件", exit ~= nil and exit.data.route == "soldier",
		exit ~= nil and ("route=" .. tostring(exit.data.route)) or "无 storyExit")
	check("演出快照同步", r.story.phase == "gate-hand" or r.story.phase == "gate-wait",
		"story.phase=" .. tostring(r.story.phase) .. " handDone=" .. tostring(r.story.handDone))
end

say("== 3. 牵手中途松手可重试 ==")
do
	local p = atHoldLastTick(3, 3)
	local i = newInput()
	local bag = {}
	step(p, i)
	toCount(p, i)
	countToEnd(p, i, bag)
	check("待机起点", p.phase == "gate-wait", "phase=" .. tostring(p.phase))
	i.interact.held = true
	i.interact.pressed = true
	step(p, i)
	steps(p, i, 19)
	check("按 20 拍进度 20", p.handTicks == 20, "handTicks=" .. tostring(p.handTicks))
	i.interact.held = false
	step(p, i)
	drainInto(p, bag)
	check("松手清进度", p.handTicks == 0, "handTicks=" .. tostring(p.handTicks))
	local rel = hasEvent(bag, "handRelease")
	check("松手事件", rel ~= nil and rel.data.handTicks == 20,
		rel ~= nil and ("handTicks=" .. tostring(rel.data.handTicks)) or "无 handRelease")
	i.interact.held = true
	i.interact.pressed = true
	step(p, i)
	steps(p, i, 35)
	check("重试 36 拍完成", p.phase == "gate-hand", "phase=" .. tostring(p.phase) .. " handTicks=" .. tostring(p.handTicks))
end

say("== 4. 暂停冻结牵手进度 ==")
do
	local p = atHoldLastTick(3, 3)
	local i = newInput()
	local bag = {}
	step(p, i)
	toCount(p, i)
	countToEnd(p, i, bag)
	i.interact.held = true
	i.interact.pressed = true
	step(p, i)
	steps(p, i, 9)
	check("按 10 拍进度 10", p.handTicks == 10, "handTicks=" .. tostring(p.handTicks))
	p.paused = true
	steps(p, i, 10)
	check("暂停期间进度不动", p.handTicks == 10, "handTicks=" .. tostring(p.handTicks))
	p.paused = false
	steps(p, i, 26)
	check("恢复后第 36 拍完成", p.phase == "gate-hand" and p.handTicks == 36,
		"phase=" .. tostring(p.phase) .. " handTicks=" .. tostring(p.handTicks))
end

say("== 5. 锁线后重试 / 续读从快照恢复 ==")
do
	local p, r, i = routeCase("恢复用男主线", 3, 3, "soldier")
	local bag = {}
	toCount(p, i)
	countToEnd(p, i, bag)
	i.interact.held = true
	i.interact.pressed = true
	step(p, i)
	steps(p, i, 35)
	check("恢复用例已牵上", p.phase == "gate-hand", "phase=" .. tostring(p.phase))
	step(p, i)
	local p2 = lualib.__TS__New(play.Play, GATE, nil, r)
	check("R 重试恢复路线", p2.storyRoute == "soldier" and p2.storySettled == true,
		"route=" .. tostring(p2.storyRoute) .. " settled=" .. tostring(p2.storySettled))
	check("R 重试不重算血量", p2.hp == 3 and p2.hpAtGate == 3, "hp=" .. p2.hp .. " hpAtGate=" .. tostring(p2.hpAtGate))
	check("R 重试恢复演出", p2.phase == "gate-wait" or p2.phase == "gate-hand", "phase=" .. tostring(p2.phase))
	-- 再按 36 拍仍能牵上，不需要重打 45 秒守点。
	local j = newInput()
	j.interact.held = true
	j.interact.pressed = true
	step(p2, j)
	steps(p2, j, 35)
	check("恢复后再牵 36 拍", p2.phase == "gate-hand", "phase=" .. tostring(p2.phase) .. " handTicks=" .. tostring(p2.handTicks))
end

say("== 6. 女主线：数满等新方向输入、旧键不算 ==")
do
	local p, r = atHoldLastTick(2, 3)
	local i = newInput()
	local bag = {}
	step(p, i)
	drainInto(p, bag)
	toCount(p, i)
	check("女主线进入数数", p.phase == "gate-count", "phase=" .. tostring(p.phase))
	-- 送别前就按住 D（旧键），数满后一直按着不算新按。
	i.moveX = 1
	countToEnd(p, i, bag)
	check("女主线数满仍等输入", p.phase == "gate-count" and p.countTick >= play.GATE_COUNT_END,
		"phase=" .. tostring(p.phase) .. " countTick=" .. tostring(p.countTick))
	steps(p, i, 60)
	check("旧键按住 60 拍不走", p.phase == "gate-count",
		"phase=" .. tostring(p.phase) .. " x=" .. tostring(p.player.x - p.ox))
	-- 1439/1440：数满前一拍才按下，是上升沿，算新按。
	local p2 = atHoldLastTick(2, 3)
	local i2 = newInput()
	step(p2, i2)
	toCount(p2, i2)
	i2.moveX = 0
	for _ = 1, play.GATE_COUNT_END do
		if p2.countTick == play.GATE_COUNT_END - 1 then
			i2.moveX = 1
		end
		step(p2, i2)
	end
	check("1439 拍按下的上升沿", p2.phase == "gate-walk",
		"phase=" .. tostring(p2.phase) .. " countTick=" .. tostring(p2.countTick))
	-- 迈步后走到出口，切城外。
	i2.moveX = 1
	p2.player.x = p2.ox + G.exitX + 2
	step(p2, i2)
	drainInto(p2, bag)
	local exit = hasEvent(bag, "storyExit")
	check("女主线出口事件", exit ~= nil and exit.data.route == "child",
		exit ~= nil and ("route=" .. tostring(exit.data.route)) or "无 storyExit")
	check("女主线出门切城外", p2.wantRoom == "outside", "wantRoom=" .. tostring(p2.wantRoom))
	check("女主线快照", r.story.settled == true and r.story.route == "child",
		"route=" .. tostring(r.story.route))
end

say("== 7. 数数边沿（保持 D6 既有语义） ==")
do
	local p = atHoldLastTick(2, 3)
	local i = newInput()
	step(p, i)
	toCount(p, i)
	i.moveX = 1
	for _ = 1, 1500 do
		step(p, i)
	end
	check("1500 拍按住旧键仍不走", p.phase == "gate-count", "phase=" .. tostring(p.phase))
	i.moveX = 0
	step(p, i)
	check("松开一拍照旧不走", p.phase == "gate-count", "phase=" .. tostring(p.phase))
	i.moveX = 1
	step(p, i)
	check("新按下才迈步", p.phase == "gate-walk", "phase=" .. tostring(p.phase))
end

say("== 8. 跨房血量继承（城外 / 同行段） ==")
do
	local r = storyRun(2, 3)
	local out = lualib.__TS__New(play.Play, rooms.OUTSIDE_ROOM, nil, r)
	check("城外继承 2/3", out.hp == 2 and out.maxHp == 3, "hp=" .. out.hp .. "/" .. out.maxHp)
	local path = lualib.__TS__New(play.Play, rooms.GATE_PATH_ROOM, nil, r)
	check("同行段继承 2/3", path.hp == 2 and path.maxHp == 3, "hp=" .. path.hp .. "/" .. path.maxHp)
	path.tied = true
	path.player.x = path.ox + 860
	path.player.y = 48
	path.player.onGround = true
	local bag = {}
	path:update(STEP, newInput())
	drainInto(path, bag)
	for _ = 1, 30 do
		path:update(STEP, newInput())
		drainInto(path, bag)
	end
	check("同行段到高石阶交下一段", path.wantRoom == "outside", "wantRoom=" .. tostring(path.wantRoom))
	local ev = hasEvent(bag, "gatePathEnd")
	check("同行段收尾事件", ev ~= nil, ev ~= nil and ("x=" .. tostring(ev.data.x)) or "无 gatePathEnd")
end

say("")
say(string.format("D-A 城门双出口回归：%d 通过 / %d 失败", pass, fail))
-- 引擎禁止脚本创建全局变量，读数直接进引擎日志；dofile 调用返回累计日志。
assert(fail == 0, "D-A 城门双出口回归失败")
print(string.format("D-A 城门双出口回归：%d 通过 / %d 失败", pass, fail))
