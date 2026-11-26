-- D-B2W 逐段真实走位：从每段入口由输入走到目标与出口，不用直接 switchRoom 代替可达性。
local Dora = require("Dora")
local Content = Dora.Content
Content:addSearchPath(Content.assetPath .. "/Script")
Content:addSearchPath(Content.assetPath .. "/Script/Lib")
Content:addSearchPath(Content.assetPath)
package.path = package.path .. ";" .. Content.assetPath .. "/?.lua"

local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local input = require("Script.watch.input")
local runmod = require("Script.watch.run")
local lualib = package.loaded["Script.Lib.lualib_bundle"] or require("Script.Lib.lualib_bundle")

local PASS, FAIL = 0, 0
local function say(s) print(s) end
local function check(tag, cond, detail)
	if cond then PASS = PASS + 1; say("  PASS " .. tag)
	else FAIL = FAIL + 1; say("  FAIL " .. tag .. " | " .. tostring(detail or "")) end
end

local function newInput()
	return lualib.__TS__New(input.Input)
end
local function tap(i, k) local ks = i[k]; ks.held = true; ks.pressed = true end
local function rel(i, k) local ks = i[k]; ks.held = false; ks.pressed = false; ks.released = false end
local function step(p, i)
	p:update(play.STEP, i)
	i.jump.pressed = false; i.interact.pressed = false; i.retry.pressed = false; i.pause.pressed = false
	i.jump.released = false; i.interact.released = false
end
local function steps(p, i, n) for _ = 1, n do step(p, i) end end
local function drain(p) local out = {}; for _, e in ipairs(p:drainEvents()) do out[#out+1] = e end; return out end

local ROOM_BY_KEY = {}
for idx, r in ipairs(rooms.ROOMS) do ROOM_BY_KEY[r.key] = idx end

local function switchRoom(p, key, tag)
	local events = drain(p)
	local idx = ROOM_BY_KEY[key]
	assert(idx ~= nil, "no room " .. key)
	local fresh = lualib.__TS__New(play.Play, rooms.ROOMS[idx], nil, p.run)
	fresh:adoptEvents(events)
	say(string.format("  [切房] %s → %s", p.room.key, key))
	return fresh
end

local function walkTo(p, i, targetX, maxTicks, opts)
	local beforeMove = 0
	local stuck = 0
	local lastX = p.player.x
	local ticks = 0
	while ticks < (maxTicks or 900) do
		local dx = targetX - p.player.x
		if math.abs(dx) <= 8 then
			i.moveX = 0
			break
		end
		i.moveX = dx > 0 and 1 or -1
		if opts and opts.crouch then i.crouch.held = true end
		step(p, i)
		ticks = ticks + 1
		if p.wantRoom ~= "" then
			break
		end
		if math.abs(p.player.x - lastX) < 0.6 then
			stuck = stuck + 1
			if stuck >= 3 then
				i.jump.pressed = true
				i.jump.held = true
				for _ = 1, 10 do step(p, i) end
				i.jump.held = false
				stuck = 0
			end
		else
			stuck = 0
		end
		lastX = p.player.x
	end
	i.moveX = 0
	i.crouch.held = false
	return ticks
end

local function fireAt(p, i, x, y)
	p:aimAt(x, y)
	i.fire.pressed = true; i.fire.held = true
	step(p, i)
	i.fire.pressed = false; i.fire.held = false
end

say("== W1. 第一段：从入口走到出口 ==")
local r1 = runmod.createRun(20261125, "official")
r1.story.route = "soldier"
r1.story.settled = true
local p1 = lualib.__TS__New(play.Play, rooms.ESCORT1_ROOM, nil, r1)
p1.storyRoute = "soldier"
p1.storySettled = true
p1.enemies = {}
local i1 = newInput()
walkTo(p1, i1, 300, 500)
check("一段入口到街垒", p1.player.x >= 280, "x=" .. string.format("%.1f", p1.player.x))
walkTo(p1, i1, 1515, 1200)
steps(p1, i1, 120)
check("一段走到出口", p1.wantRoom == "escort2", "want=" .. tostring(p1.wantRoom) .. " x=" .. string.format("%.1f", p1.player.x) .. " 小满=" .. string.format("%.1f", p1.partner.x))

say("== W2. 第二段：粮棚取材后走到出口 ==")
local r2 = runmod.createRun(20261125, "official")
r2.story.route = "soldier"
r2.story.settled = true
local p2 = lualib.__TS__New(play.Play, rooms.ESCORT2_ROOM, nil, r2)
p2.storyRoute = "soldier"
p2.storySettled = true
p2.enemies = {}
local i2 = newInput()
walkTo(p2, i2, 380, 400)
check("二段拾到木纹筹 380", p2.run.inventory.wood == 1, "wood=" .. p2.run.inventory.wood)
walkTo(p2, i2, 560, 300)
check("二段拾到铃纹筹 560", p2.run.inventory.bell == 1, "bell=" .. p2.run.inventory.bell)
-- 走到 820 拾第二根木筹（棚架后地面）
walkTo(p2, i2, 900, 400)
check("二段上到粮台", p2.player.y >= 54, "y=" .. string.format("%.1f", p2.player.y))
walkTo(p2, i2, 820, 300)
check("二段拾到高台木筹 820", p2.run.inventory.wood == 2, "wood=" .. p2.run.inventory.wood)
walkTo(p2, i2, 1415, 700)
steps(p2, i2, 120)
check("二段走到出口", p2.wantRoom == "escort3", "want=" .. tostring(p2.wantRoom) .. " x=" .. string.format("%.1f", p2.player.x))

say("== W3. 第三段：工台开关后走到出口 ==")
local r3 = runmod.createRun(20261125, "official")
r3.story.route = "soldier"
r3.story.settled = true
local p3 = lualib.__TS__New(play.Play, rooms.ESCORT3_ROOM, nil, r3)
p3.storyRoute = "soldier"
p3.storySettled = true
p3.enemies = {}
local i3 = newInput()
walkTo(p3, i3, 560, 500)
tap(i3, "interact"); step(p3, i3); rel(i3, "interact")
check("三段按 E 打开工台", p3.craftBench.active == true, "active=" .. tostring(p3.craftBench.active) .. " key=" .. p3.room.key .. " x=" .. string.format("%.1f", p3.player.x) .. " y=" .. string.format("%.1f", p3.player.y))
tap(i3, "interact"); step(p3, i3); rel(i3, "interact")
check("三段 E 留给面板确认", p3.craftBench.active == true)
tap(i3, "pause"); step(p3, i3); rel(i3, "pause")
check("三段 Esc 收起工台", not p3.craftBench.active and not p3.paused)
walkTo(p3, i3, 1165, 700)
steps(p3, i3, 120)
check("三段走到出口", p3.wantRoom == "escort4", "want=" .. tostring(p3.wantRoom) .. " x=" .. string.format("%.1f", p3.player.x))

say("== W4. 第四段：从入口走到断口与出口 ==")
local r4 = runmod.createRun(20261125, "official")
r4.story.route = "soldier"
r4.story.settled = true
local p4 = lualib.__TS__New(play.Play, rooms.ESCORT4_ROOM, nil, r4)
p4.storyRoute = "soldier"
p4.storySettled = true
p4.enemies = {}  -- 几何走位证据：敌兵用夹具清空，实际战斗另有断言。
local i4 = newInput()
walkTo(p4, i4, 300, 500)
check("四段入口可走", p4.player.x > 260, "x=" .. string.format("%.1f", p4.player.x))
walkTo(p4, i4, 880, 700)
check("四段走到断口前", p4.player.x >= 860, "x=" .. string.format("%.1f", p4.player.x))
walkTo(p4, i4, 1320, 900)
steps(p4, i4, 120)  -- 等小满跟上（exitX-220 的同行条件）
check("四段跨断口到出口", p4.wantRoom == "escort5", "want=" .. tostring(p4.wantRoom) .. " x=" .. string.format("%.1f", p4.player.x) .. " 小满=" .. string.format("%.1f", p4.partner.x))

say("== W2. 第五段：从入口走到塔门 ==")
local r5 = runmod.createRun(20261125, "official")
r5.story.route = "soldier"
r5.story.settled = true
local p5 = lualib.__TS__New(play.Play, rooms.ESCORT5_ROOM, nil, r5)
p5.storyRoute = "soldier"
p5.storySettled = true
p5.enemies = {}
local i5 = newInput()
walkTo(p5, i5, 900, 800)
check("五段跨石台", p5.player.x >= 880, "x=" .. string.format("%.1f", p5.player.x))
walkTo(p5, i5, 1340, 700)
steps(p5, i5, 120)  -- 等小满跟上
check("五段到塔门", p5.wantRoom == "tower", "want=" .. tostring(p5.wantRoom) .. " 小满=" .. string.format("%.1f", p5.partner.x))
check("五段段结算一次", p5.run.story.segments["escort5"] == true, "seg=" .. tostring(p5.run.story.segments["escort5"]))

say("== W5. 女主线：城外走到村口 ==")
local c1 = runmod.createRun(20261125, "official")
c1.story.route = "child"
c1.story.settled = true
c1.story.ending = ""
local pc1 = lualib.__TS__New(play.Play, rooms.OUTSIDE_ROOM, { checkpoint = 380 }, c1)
pc1.enemies = {}
local ic1 = newInput()
walkTo(pc1, ic1, 1165, 1400)
steps(pc1, ic1, 60)
check("女主城外走到村口", pc1.wantRoom == "village", "want=" .. tostring(pc1.wantRoom) .. " x=" .. string.format("%.1f", pc1.player.x))

say("== W6. 女主线：村口蹲过拱洞到林缘 ==")
local c2 = runmod.createRun(20261125, "official")
c2.story.route = "child"
c2.story.settled = true
local pc2 = lualib.__TS__New(play.Play, rooms.VILLAGE_ROOM, nil, c2)
pc2.scavState = "gone"
local ic2 = newInput()
walkTo(pc2, ic2, 350, 500, { crouch = false })
check("村口能到拱洞前", pc2.player.x >= 320, "x=" .. string.format("%.1f", pc2.player.x))
walkTo(pc2, ic2, 720, 700, { crouch = true })
steps(pc2, ic2, 60)
check("村口蹲过拱洞到林缘", pc2.wantRoom == "forest", "want=" .. tostring(pc2.wantRoom) .. " x=" .. string.format("%.1f", pc2.player.x))

say("== W7. 女主线：森林跑到塔门 ==")
local c3 = runmod.createRun(20261125, "official")
c3.story.route = "child"
c3.story.settled = true
local pc3w = lualib.__TS__New(play.Play, rooms.FOREST_ROOM, nil, c3)
pc3w.dogState = "gone"
pc3w.dogX = 2000
local ic3 = newInput()
walkTo(pc3w, ic3, 1460, 1800)
steps(pc3w, ic3, 60)
check("森林跑到塔门", pc3w.wantRoom == "tower", "want=" .. tostring(pc3w.wantRoom) .. " x=" .. string.format("%.1f", pc3w.player.x))

say("== W8. 女主线：塔门留灯落幕 ==")
local c4 = runmod.createRun(20261125, "official")
c4.story.route = "child"
c4.story.settled = true
c4.story.countTick = 1440
local pc4 = lualib.__TS__New(play.Play, rooms.TOWER_ROOM, nil, c4)
local ic4 = newInput()
walkTo(pc4, ic4, 445, 300)
tap(ic4, "interact"); step(pc4, ic4); rel(ic4, "interact")
for _ = 1, 40 do step(pc4, ic4) end
walkTo(pc4, ic4, 545, 200)
ic4.interact.held = true
for _ = 1, 40 do step(pc4, ic4) end
ic4.interact.held = false
local evtC = {}
for _ = 1, 220 do
 step(pc4, ic4)
 for _, e in ipairs(pc4:drainEvents()) do evtC[e.name] = e end
end
check("女主塔门落幕", pc4.run.finished == true and pc4.run.story.ending == "lamp", "ending=" .. tostring(pc4.run.story.ending))
check("女主姓名第一行小满", pc4.endingLines[1] == "小满" and pc4.endingLines[2] == "", "lines=" .. tostring(pc4.endingLines[1]) .. "/" .. tostring(pc4.endingLines[2]))
check("女主正式记档 child", c4.archive.childCleared == true and c4.archive.soldierCleared == false,
 "child=" .. tostring(c4.archive.childCleared) .. " soldier=" .. tostring(c4.archive.soldierCleared))

say(string.format("D-B2W 逐段走位：%d 通过 / %d 失败", PASS, FAIL))
assert(FAIL == 0, "D-B2W 失败")
