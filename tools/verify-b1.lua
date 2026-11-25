-- B1 回归：守点末拍取血 / 门洞送别锁线 / 背负进首战 / 慢时连线换弹 / 安全出口。
--
-- 夹具用脚本设阈值血量并推进到守点末拍、送别、高石阶与护送房；
-- 覆盖 79/100 与 80/100、守满未锁线、送别前与送别后的 R 恢复、
-- 背负姿态与操控者、三种连线、240 作答拍 = 60 世界拍、超时、暂停冻结、
-- 无效重画、首发消费一次、第二发普通，以及 escort1 → outside 交接。
--
-- 入口方式（脚本放仓库根，输出进引擎日志）：
--   Dora cli run -p . --entry tmp-verify-b1.lua
--   Dora cli log -n 200

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
local reloadmod = require("Script.watch.reload")
local lualib = require("lualib_bundle")

local GATE = rooms.GATE_ROOM
local G = GATE.story.gate
local STEP = play.STEP
local PASS_TICKS = reloadmod.RELOAD_ANSWER_TICKS

local pass, fail = 0, 0
local function say(s)
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
	for _, k in ipairs({ "interact", "jump", "crouch", "cover", "aim", "fire", "pause", "retry" }) do
		i[k].pressed = false
		i[k].released = false
	end
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

local function countEvent(bag, name)
	local n = 0
	for _, e in ipairs(bag) do
		if e.name == name then
			n = n + 1
		end
	end
	return n
end

local function storyRun(hp, maxHp)
	local r = runmod.createRun()
	r.story.hp = hp
	r.story.maxHp = maxHp
	return r
end

-- 守点末拍：敌兵已出齐，下一拍进入送别（只取血，不锁线）。
local function atGateSend(hp, maxHp)
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

-- 门洞按 E 送别：锁线并转入数数。
local function lockAtDoor(p, i)
	p.player.x = p.ox + G.doorX
	p.partner.x = p.ox + G.doorX + 30
	step(p, i)
	i.interact.held = true
	i.interact.pressed = true
	step(p, i)
	i.interact.held = false
	step(p, i)
end

-- 护送房夹具：背负状态、空敌、从段起点。
local function escortPlay(r)
	local p = lualib.__TS__New(play.Play, rooms.ESCORT1_ROOM, nil, r)
	p.enemies = {}
	return p
end

-- 用实际开火动作触发一次换弹（打空也会进装填并开盘）。
local function fireOnce(p)
	p:shoot(p.player)
end

local function openPuzzle(p)
	p.reloadOpen = true
	p.reloadAnswerTicks = 0
	p.reloadWorldTicks = 0
	p.reloadPath = { 0 }
	p.reloadPendingEffect = ""
	p.reloadTryCount = p.reloadTryCount + 1
end

local function tapPath(p, path)
	for k = 2, #path do
		p:reloadTapNode(path[k])
	end
end

say("== 1. 守满只取血，门洞送别才锁线 ==")
do
	local p, r = atGateSend(2, 3)
	local i = newInput()
	local bag = {}
	step(p, i)
	drainInto(p, bag)
	check("守满转送别", p.phase == "gate-send", "phase=" .. tostring(p.phase))
	check("守满未锁线", p.storyRoute == "" and hasEvent(bag, "storyRouteLocked") == nil,
		"route=" .. tostring(p.storyRoute))
	check("守满已取血", p.hpAtGate == 2 and p.maxHpAtGate == 3,
		"hpAtGate=" .. tostring(p.hpAtGate) .. "/" .. tostring(p.maxHpAtGate))

	local r2 = storyRun(2, 3)
	local p2 = lualib.__TS__New(play.Play, GATE, nil, r2)
	p2.phase = "gate-hold"
	p2.gateTick = G.holdTicks - 1
	p2.gateSpawned = 4
	p2.enemies = {}
	p2.player.x = p2.ox + G.winchX
	p2.partner.x = p2.ox + G.waitX
	step(p2, newInput())
	check("送别前快照存 gate-send", r2.story.phase == "gate-send", "phase=" .. tostring(r2.story.phase))
	local p3 = lualib.__TS__New(play.Play, GATE, nil, r2)
	check("送别前 R 恢复待送别", p3.phase == "gate-send" and p3.storyRoute == "",
		"phase=" .. tostring(p3.phase) .. " route=" .. tostring(p3.storyRoute))
end

say("== 2. 阈值与重复锁线 ==")
do
	local cases = { { 79, 100, "child" }, { 80, 100, "soldier" }, { 2, 3, "child" }, { 3, 3, "soldier" } }
	for _, c in ipairs(cases) do
		local p, r = atGateSend(c[1], c[2])
		local i = newInput()
		local bag = {}
		step(p, i)
		drainInto(p, bag)
		lockAtDoor(p, i)
		drainInto(p, bag)
		local locked = hasEvent(bag, "storyRouteLocked")
		check(string.format("%d/%d 锁线 %s", c[1], c[2], c[3]), p.storyRoute == c[3] and locked ~= nil,
			"route=" .. tostring(p.storyRoute) .. " hpAtGate=" .. tostring(p.hpAtGate))
		check(string.format("%d/%d 快照落库", c[1], c[2]), r.story.settled == true and r.story.route == c[3],
			"settled=" .. tostring(r.story.settled) .. " route=" .. tostring(r.story.route))
		-- 重复交互：再按一次 E 不得产生第二条锁线事件。
		local again = {}
		i.interact.held = true
		i.interact.pressed = true
		step(p, i)
		drainInto(p, again)
		check(string.format("%d/%d 重复交互不再锁", c[1], c[2]), countEvent(again, "storyRouteLocked") == 0,
			"events=" .. tostring(countEvent(again, "storyRouteLocked")))
	end

	-- 送别后 R：恢复已锁路线，不重打守点。
	local p, r = atGateSend(3, 3)
	local i = newInput()
	step(p, i)
	lockAtDoor(p, i)
	local p2 = lualib.__TS__New(play.Play, GATE, nil, r)
	check("送别后 R 恢复已锁路线", p2.storyRoute == "soldier" and p2.storySettled == true
		and p2.phase == "gate-count", "route=" .. tostring(p2.storyRoute) .. " phase=" .. tostring(p2.phase))
end

say("== 3. 高石阶背起小满，切进首场护送 ==")
do
	local r = storyRun(2, 3)
	r.story.route = "soldier"
	r.story.settled = true
	r.story.tied = true
	r.story.handDone = true
	local path = lualib.__TS__New(play.Play, rooms.GATE_PATH_ROOM, nil, r)
	path.tied = true
	path.player.x = path.ox + 860
	path.player.y = 48
	path.player.onGround = true
	local i = newInput()
	local bag = {}
	step(path, i)
	drainInto(path, bag)
	check("高石阶一次背起", path.carryOn == true and path.phase == "gatepath-carry",
		"carryOn=" .. tostring(path.carryOn) .. " phase=" .. tostring(path.phase))
	check("背起事件", hasEvent(bag, "carryStart") ~= nil and hasEvent(bag, "gatePathEnd") ~= nil,
		"carryStart=" .. tostring(hasEvent(bag, "carryStart") ~= nil))
	step(path, i)
	check("小满贴背侧", math.abs(path.partner.x - (path.player.x - path.player.facing * 12)) <= 2
		and math.abs(path.partner.y - (path.player.y + 26)) <= 2,
		string.format("partner=%.0f,%.0f player=%.0f,%.0f", path.partner.x, path.partner.y, path.player.x, path.player.y))

	path.player.x = path.ox + 1005
	path.player.onGround = true
	for _ = 1, 20 do
		step(path, i)
		drainInto(path, bag)
	end
	check("同行段交首场护送", path.wantRoom == "escort1", "wantRoom=" .. tostring(path.wantRoom))

	local esc = escortPlay(r)
	check("护送房控周戍", esc.childMode == false, "childMode=" .. tostring(esc.childMode))
	check("护送房仍背着小满", esc.carryOn == true, "carryOn=" .. tostring(esc.carryOn))
	check("护送房继承 2/3", esc.hp == 2 and esc.maxHp == 3, "hp=" .. esc.hp .. "/" .. esc.maxHp)
	check("护送房继承种子", esc.run.seed == r.seed, "seed=" .. tostring(esc.run.seed))
	step(esc, i)
	check("背负位置随转身", math.abs(esc.partner.x - (esc.player.x - esc.player.facing * 12)) <= 2,
		string.format("partner=%.0f player=%.0f", esc.partner.x, esc.player.x))
end

say("== 4. 慢时连线换弹：240 作答拍 = 60 世界拍 ==")
do
	local r = storyRun(2, 3)
	r.story.route = "soldier"
	r.story.carry = true
	local p = escortPlay(r)
	local i = newInput()
	fireOnce(p)
	check("开火后开盘", p.reloadOpen == true and p.reloadT > 0,
		"open=" .. tostring(p.reloadOpen) .. " reloadT=" .. tostring(p.reloadT))
	local bag = {}
	steps(p, i, PASS_TICKS)
	drainInto(p, bag)
	check("240 作答拍", p.reloadAnswerTicks == PASS_TICKS, "answerTicks=" .. tostring(p.reloadAnswerTicks))
	check("60 世界拍", p.reloadWorldTicks == 60, "worldTicks=" .. tostring(p.reloadWorldTicks))
	step(p, i)
	drainInto(p, bag)
	check("超时关盘", p.reloadOpen == false, "open=" .. tostring(p.reloadOpen))
	check("超时事件", hasEvent(bag, "reloadTimeout") ~= nil, "无 reloadTimeout")
	check("超时不带效果", p.reloadPendingEffect == "", "effect=" .. tostring(p.reloadPendingEffect))

	-- 暂停：两钟都停。
	local p2 = escortPlay(r)
	local i2 = newInput()
	fireOnce(p2)
	steps(p2, i2, 8)
	p2.paused = true
	local beforeA, beforeW = p2.reloadAnswerTicks, p2.reloadWorldTicks
	steps(p2, i2, 40)
	check("暂停冻结作答钟", p2.reloadAnswerTicks == beforeA, "answerTicks=" .. tostring(p2.reloadAnswerTicks))
	check("暂停冻结世界钟", p2.reloadWorldTicks == beforeW, "worldTicks=" .. tostring(p2.reloadWorldTicks))
	p2.paused = false
	steps(p2, i2, 8)
	check("恢复继续计数", p2.reloadAnswerTicks > beforeA, "answerTicks=" .. tostring(p2.reloadAnswerTicks))
end

say("== 5. 三种连线与效果消费 ==")
do
	local r = storyRun(3, 3)
	r.story.route = "soldier"
	r.story.carry = true

	-- 无效重画：不跳格、不重复，只清回起点。
	local p = escortPlay(r)
	openPuzzle(p)
	local bag = {}
	p:reloadTapNode(5)
	drainInto(p, bag)
	check("无效连线重画", #p.reloadPath == 1 and p.reloadPath[1] == 0 and hasEvent(bag, "reloadInvalid") ~= nil,
		"path=" .. tostring(#p.reloadPath))
	check("重画不重计时", p.reloadAnswerTicks == 0, "answerTicks=" .. tostring(p.reloadAnswerTicks))

	-- 推退：0→3→6→7→8。
	local p2 = escortPlay(r)
	openPuzzle(p2)
	tapPath(p2, { 0, 3, 6, 7, 8 })
	check("直连推退", p2.reloadPendingEffect == "push", "effect=" .. tostring(p2.reloadPendingEffect))
	check("推退事件", #p2.reloadPath == 5, "pathLength=" .. tostring(#p2.reloadPath))

	-- 回声：0→1→4→5→8，经过中心铃纹。
	local p3 = escortPlay(r)
	openPuzzle(p3)
	tapPath(p3, { 0, 1, 4, 5, 8 })
	check("经铃纹回声", p3.reloadPendingEffect == "echo", "effect=" .. tostring(p3.reloadPendingEffect))

	-- 照明：0→1→2→5→8，经过右上灯纹。
	local p4 = escortPlay(r)
	openPuzzle(p4)
	tapPath(p4, { 0, 1, 2, 5, 8 })
	check("经灯纹照明", p4.reloadPendingEffect == "light", "effect=" .. tostring(p4.reloadPendingEffect))

	-- 首发消费一次，第二发普通。
	local p5 = escortPlay(r)
	openPuzzle(p5)
	tapPath(p5, { 0, 3, 6, 7, 8 })
	p5.enemies = {
		{ x = p5.player.x + 90, y = 0, depth = 0, w = 26, h = 84, alive = true, hitT = 0, warnT = 0,
			kind = "gunner", shieldHp = 0, drop = "none", awake = true, fireCd = 0 },
	}
	p5:aimAt(p5.enemies[1].x, p5.enemies[1].y + 60)
	p5:shoot(p5.player)
	local bag5 = {}
	drainInto(p5, bag5)
	check("首发消费效果", p5.reloadPendingEffect == "", "effect=" .. tostring(p5.reloadPendingEffect))
	check("推退已结算", hasEvent(bag5, "reloadApplied") ~= nil, "无 reloadApplied")
	p5.enemies = {}
	p5:shoot(p5.player)
	local bag6 = {}
	drainInto(p5, bag6)
	check("第二发普通", countEvent(bag6, "reloadApplied") == 0,
		"events=" .. tostring(countEvent(bag6, "reloadApplied")))
end

say("== 6. 回声与照明的实际效果 ==")
do
	local r = storyRun(3, 3)
	r.story.route = "soldier"
	r.story.carry = true
	local p = escortPlay(r)
	openPuzzle(p)
	tapPath(p, { 0, 1, 4, 5, 8 })
	p.enemies = {
		{ x = p.player.x + 80, y = 0, depth = 0, w = 26, h = 84, alive = true, hitT = 0, warnT = 0,
			kind = "gunner", shieldHp = 0, drop = "none", awake = true, fireCd = 10 },
		{ x = p.player.x + 260, y = 0, depth = 0, w = 26, h = 84, alive = true, hitT = 0, warnT = 0,
			kind = "gunner", shieldHp = 0, drop = "none", awake = false, fireCd = 10 },
	}
	p:aimAt(p.enemies[1].x, p.enemies[1].y + 60)
	p:shoot(p.player)
	local aliveNear = p.enemies[2]
	check("回声惊动声源", aliveNear.awake == true and aliveNear.fireCd >= 60,
		"awake=" .. tostring(aliveNear.awake) .. " fireCd=" .. tostring(aliveNear.fireCd))

	-- 照明：门柱 1300–1340 挡住枪线；普通一枪打不到，照明这一枪照透遮蔽。
	local p2 = escortPlay(r)
	p2.player.x = 1250
	p2.player.y = 0
	p2.player.onGround = true
	openPuzzle(p2)
	tapPath(p2, { 0, 1, 2, 5, 8 })
	p2.enemies = {
		{ x = 1350, y = 0, depth = 0, w = 26, h = 84, alive = true, hitT = 0, warnT = 0,
			kind = "gunner", shieldHp = 0, drop = "none", awake = true, fireCd = 0 },
	}
	p2:aimAt(1350, 60)
	p2:shoot(p2.player)
	check("照明打穿遮蔽", p2.enemies[1].alive == false, "alive=" .. tostring(p2.enemies[1].alive))
end

say("== 7. 安全出口与下一段交接 ==")
do
	local r = storyRun(2, 3)
	r.story.route = "soldier"
	r.story.carry = true
	local p = escortPlay(r)
	p.run.joined = true
	p.player.x = p.room.campaign.exitX + 4
	p.partner.x = p.player.x - 12
	local i = newInput()
	step(p, i)
	check("护送房达成目标", p.objectiveDone == true, "objectiveDone=" .. tostring(p.objectiveDone))
	-- B2 分段后 escort1 出口接第二段粮棚；城外由 escort5 出口接回，另在 verify-b2 覆盖。
	check("交第二段粮棚", p.wantRoom == "escort2", "wantRoom=" .. tostring(p.wantRoom))

	local out = lualib.__TS__New(play.Play, rooms.OUTSIDE_ROOM, nil, r)
	check("城外仍控周戍", out.childMode == false, "childMode=" .. tostring(out.childMode))
	check("城外仍背着小满", out.carryOn == true, "carryOn=" .. tostring(out.carryOn))
	check("城外继承血量", out.hp == 2 and out.maxHp == 3, "hp=" .. out.hp .. "/" .. out.maxHp)

	local rc = storyRun(2, 3)
	rc.story.route = "child"
	rc.story.settled = true
	local out2 = lualib.__TS__New(play.Play, rooms.OUTSIDE_ROOM, nil, rc)
	check("女主线城外控小满", out2.childMode == true and out2.carryOn == false,
		"childMode=" .. tostring(out2.childMode) .. " carryOn=" .. tostring(out2.carryOn))
end

say("")
say(string.format("D-B1 背负与慢时换弹回归：%d 通过 / %d 失败", pass, fail))
assert(fail == 0, "D-B1 回归失败")
print(string.format("D-B1 背负与慢时换弹回归：%d 通过 / %d 失败", pass, fail))
