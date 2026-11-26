-- 《向西守望》北塔门廊与值夜室：叩门 → 守卒回叩开门 → 跨门槛 → 桌前长按 E 交物 → 名簿留白/留灯
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local runmod = require("Script.watch.run")
local Input = require("Script.watch.input").Input

local pass, fail = 0, 0
local function check(tag, cond, detail)
	if cond then pass = pass + 1; print(string.format("PASS tower: %-44s %s", tag, detail or ""))
	else fail = fail + 1; print(string.format("FAIL tower: %-44s %s", tag, detail or "")) end
end

local function newInput()
	local i = new(Input)
	i.moveX, i.moveY = 0, 0
	for _, k in ipairs({ "jump", "crouch", "cover", "interact", "aim", "fire", "flare", "pause", "retry", "toggleView", "tab" }) do
		i[k] = { held = false, pressed = false, released = false }
	end
	return i
end
local function tap(i, k) i[k].held = true; i[k].pressed = true end
local function rel(i, k) i[k].held = false; i[k].pressed = false; i[k].released = true end
local function step(p, i, n)
	for _ = 1, (n or 1) do
		p:update(play.STEP, i)
		for _, k in ipairs({ "jump", "crouch", "interact", "aim", "fire" }) do i[k].pressed = false; i[k].released = false end
		i.moveX = 0
	end
end
local function moveTo(p, i, goalX, maxSteps)
	local guard = 0
	while math.abs(p.player.x - goalX) > 8 and guard < (maxSteps or 500) do
		i.moveX = p.player.x < goalX and 1 or -1
		p:update(play.STEP, i)
		for _, k in ipairs({ "jump", "crouch", "interact", "aim", "fire" }) do i[k].pressed = false; i[k].released = false end
		guard = guard + 1
	end
	i.moveX = 0
	return guard
end
local function drainBeats(p)
	local list, beats = p:drainEvents(), {}
	for _, e in ipairs(list) do
		if e.name == "storyBeat" then beats[#beats + 1] = e.data.beat end
	end
	return beats
end
local function doorHidden(p)
	for _, b in ipairs(p.boxes) do
		if b.id == "tower_door" then return b.hidden == true end
	end
	return false
end
local function makeRun(route, hp, maxHp)
	local r = runmod.createRun(20261124, "official", runmod.createArchive())
	r.story.route, r.story.settled = route, true
	r.story.hp, r.story.maxHp = hp, maxHp
	r.story.hpAtGate, r.story.maxHpAtGate = hp, maxHp
	r.story.countTick = 1440
	r.story.segments["escort5"] = true
	r.joined = true
	return r
end

-- 1) 女主线：门外叩门，守卒回叩，门开
local r = makeRun("child", 2, 3)
local p = new(play.Play, rooms.TOWER_ROOM, nil, r)
local i = newInput()
moveTo(p, i, 400, 80)
p:update(play.STEP, i)
check("1.1 站到门外", p.phase == "tower-wait" and math.abs(p.player.x - 445) <= 50,
	string.format("x=%.1f phase=%s", p.player.x, p.phase))
tap(i, "interact"); step(p, i, 1)
check("1.2 叩第一下", p.phase == "tower-knock" and p.knocks == 1,
	string.format("phase=%s knocks=%d", p.phase, p.knocks))
rel(i, "interact")
step(p, i, 12)
check("1.3 守卒回叩两下", p.knocks == 2, "knocks=" .. tostring(p.knocks))
step(p, i, 24)
check("1.4 门开、让出门板", p.phase == "tower-enter" and p.towerDoorOpen and doorHidden(p),
	string.format("phase=%s open=%s hidden=%s", p.phase, tostring(p.towerDoorOpen), tostring(doorHidden(p))))
local b15 = table.concat(drainBeats(p), ",")
check("1.5 开门事件", b15 == "tower_door", b15)

-- 2) 跨过门槛
moveTo(p, i, 520, 200)
p:update(play.STEP, i)
check("2.1 跨过门槛", p.phase == "tower-desk" and p.player.x >= 500,
	string.format("phase=%s x=%.1f", p.phase, p.player.x))
local b22 = table.concat(drainBeats(p), ",")
check("2.2 跨门槛事件", b22 == "tower_threshold", b22)

-- 3) 桌前长按 E：35 拍不结算，松手清零，36 拍交物
moveTo(p, i, 605, 160)
p:update(play.STEP, i)
i.interact.held = true
step(p, i, 35)
check("3.1 长按 35 拍未结算", p.phase == "tower-desk" and p.deskHold == 35 and not p.towerHanded,
	string.format("hold=%d phase=%s", p.deskHold, p.phase))
rel(i, "interact"); step(p, i, 1)
check("3.2 松手清零", p.deskHold == 0 and p.phase == "tower-desk", "hold=" .. tostring(p.deskHold))
i.interact.held = true
step(p, i, 36)
check("3.3 满 36 拍交物", p.phase == "tower-given" and p.towerHanded and r.story.segments["tower_handover"] == true,
	string.format("phase=%s handed=%s seg=%s", p.phase, tostring(p.towerHanded), tostring(r.story.segments["tower_handover"])))
rel(i, "interact")
local beats = drainBeats(p)
check("3.4 交物事件带三样", beats[#beats] == "tower_handover", table.concat(beats, ","))
check("3.5 针套/指南针/纸条", p.towerHanded and p.towerDoorOpen, "handed")

-- 4) 名簿留白 → 西窗留灯
step(p, i, 60)
check("4.1 登记簿第一行小满", p.endingLines[1] == "小满" and p.endingLines[2] == "",
	string.format("lines=%s/%s", p.endingLines[1], p.endingLines[2]))
step(p, i, 120)
check("4.2 单人线留灯落幕", p.phase == "tower-end" and p.run.finished and r.story.ending == "lamp" and r.archive.childCleared,
	string.format("phase=%s ending=%s child=%s", p.phase, r.story.ending, tostring(r.archive.childCleared)))

-- 5) 中途续读：交物后换新实例，门开与值夜室阶段恢复
r.story.phase = "tower-given"
local p2 = new(play.Play, rooms.TOWER_ROOM, nil, r)
local i2 = newInput()
step(p2, i2, 1)
check("5.1 续读门仍开", p2.towerDoorOpen and doorHidden(p2), tostring(doorHidden(p2)))
check("5.2 续读桌前", p2.phase == "tower-given" and p2.player.x >= 590,
	string.format("phase=%s x=%.1f", p2.phase, p2.player.x))
check("5.3 续读已交物", p2.towerHanded, tostring(p2.towerHanded))

-- 6) 男主线对照：同一门廊/桌前流程，登记簿两行
local rs = makeRun("soldier", 3, 3)
rs.story.segments["escort5"] = true
rs.story.phase = "tower-given"
local ps = new(play.Play, rooms.TOWER_ROOM, nil, rs)
ps.player.x, ps.player.y = 605, 0
local is = newInput()
step(ps, is, 180)
check("6.1 团圆线两行姓名", ps.endingLines[1] == "小满" and ps.endingLines[2] == "周戍",
	string.format("lines=%s/%s", ps.endingLines[1], ps.endingLines[2]))
check("6.2 团圆结局", ps.phase == "tower-end" and rs.story.ending == "reunion" and rs.archive.soldierCleared,
	string.format("ending=%s soldier=%s", rs.story.ending, tostring(rs.archive.soldierCleared)))

print(string.format("北塔门廊与值夜室：%d 通过 / %d 失败", pass, fail))
assert(fail == 0, "北塔门廊与值夜室回归失败")
