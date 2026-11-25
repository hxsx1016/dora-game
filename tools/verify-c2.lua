-- D-C2 博物馆：进馆、四步单边沿、两下轻叩、暂停冻结、重启续读、回柜边。
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
local function check(tag, cond, detail)
	if cond then PASS = PASS + 1; print("  PASS " .. tag)
	else FAIL = FAIL + 1; print("  FAIL " .. tag .. " | " .. tostring(detail or "")) end
end
local function tap(i, k) local ks = i[k]; ks.held = true; ks.pressed = true end
local function rel(i, k) local ks = i[k]; ks.held = false; ks.pressed = false; ks.released = false end
local function press(p, i, k)
	tap(i, k); p:update(play.STEP, i); rel(i, k)
end
local function step0(p, i, n)
	for _ = 1, n or 1 do p:update(play.STEP, i); i.interact.pressed = false; i.interact.held = false end
end
local function bag(p) return p:drainEvents() end
local function hasEvent(events, name)
	for _, e in ipairs(events) do if e.name == name then return e end end
	return nil
end

local archive = { childCleared = true, soldierCleared = true, artifactOwned = true, museumPhase = "well_reflect", museumSeen = false }
local i = lualib.__TS__New(input.Input)

print("== C2-1. 井沿第二次按 E 才进馆 ==")
local r0 = runmod.createRun(20261125, "official", archive)
local pro = lualib.__TS__New(play.Play, rooms.PROLOGUE_ROOM, nil, r0)
pro.player.x = 430
press(pro, i, "interact")
check("井沿进馆请求", pro.wantRoom == "museum", "want=" .. pro.wantRoom)
check("进馆记相位 well_reflect", archive.museumPhase == "well_reflect", "phase=" .. archive.museumPhase)
check("进馆标脏", pro.archiveDirty == true)
local noArt = { childCleared = true, soldierCleared = true, artifactOwned = false, museumPhase = "locked", museumSeen = false }
local rNo = runmod.createRun(20261125, "official", noArt)
local proNo = lualib.__TS__New(play.Play, rooms.PROLOGUE_ROOM, nil, rNo)
proNo.player.x = 430
press(proNo, i, "interact")
check("未拿到穿梭器不进馆", proNo.wantRoom == "", "want=" .. proNo.wantRoom)

print("== C2-2. 馆内四步：每步一次边沿 ==")
local r1 = runmod.createRun(20261125, "official", archive)
local mu = lualib.__TS__New(play.Play, rooms.MUSEUM_ROOM, nil, r1)
step0(mu, i, 1)
check("柜前开局", mu.phase == "museum-cabinet", "phase=" .. mu.phase)
check("馆内单人", mu.partner.alive == false)
press(mu, i, "interact")
check("柜前收枪 → 走廊", mu.phase == "museum-hall", "phase=" .. mu.phase)
check("档案步 hall_walk", archive.museumPhase == "hall_walk")
check("柜前事件一次", (function() local ev = bag(mu); local n = 0; for _, e in ipairs(ev) do if e.name == "museumStep" and e.data.step == "cabinet" then n = n + 1 end end; return n end)() == 1)
-- 走廊走 900
mu.player.x = 900
press(mu, i, "interact")
check("走廊听脚步 → 末厅", mu.phase == "museum-lamp", "phase=" .. mu.phase)
check("档案步 lamp_turn", archive.museumPhase == "lamp_turn")
mu.player.x = 1250
press(mu, i, "interact")
check("末厅转灯 → 回柜", mu.phase == "museum-return", "phase=" .. mu.phase)
check("档案步 return_cabinet", archive.museumPhase == "return_cabinet")
mu.player.x = 240
press(mu, i, "interact")
check("柜前第一下轻叩", mu.phase == "museum-knock", "phase=" .. mu.phase)
step0(mu, i, 7)
check("第七拍还没有第二下", mu.phase == "museum-knock", "phase=" .. mu.phase)
step0(mu, i, 1)
check("第八拍第二下", (function() local ev = bag(mu); local e = nil; for _, x in ipairs(ev) do if x.name == "museumStep" and x.data.count == 2 then e = x end end; return e ~= nil end)())
step0(mu, i, 28)
check("叩完落幕", mu.phase == "museum-done", "phase=" .. mu.phase)
check("档案记完成", archive.museumSeen == true and archive.museumPhase == "done",
	"seen=" .. tostring(archive.museumSeen) .. " phase=" .. tostring(archive.museumPhase))
check("落幕事件一次", (function() local ev = bag(mu); local e = hasEvent(ev, "museumDone"); return e ~= nil end)())

print("== C2-3. 暂停冻结叩门计数 ==")
local r2 = runmod.createRun(20261125, "official", archive)
local mu2 = lualib.__TS__New(play.Play, rooms.MUSEUM_ROOM, nil, r2)
mu2.phase = "museum-knock"
mu2.phaseTick = 0
mu2.paused = true
step0(mu2, i, 10)
check("暂停时不走拍", mu2.phaseTick == 0, "tick=" .. mu2.phaseTick)
mu2.paused = false
step0(mu2, i, 8)
check("恢复后继续走拍", mu2.phaseTick == 8, "tick=" .. mu2.phaseTick)

print("== C2-4. 重启从同一步续读 ==")
local archiveRoad = { childCleared = true, soldierCleared = true, artifactOwned = true, museumPhase = "hall_walk", museumSeen = false }
local r3 = runmod.createRun(20261125, "official", archiveRoad)
local mu3 = lualib.__TS__New(play.Play, rooms.MUSEUM_ROOM, nil, r3)
check("续读直接到走廊", mu3.phase == "museum-hall", "phase=" .. mu3.phase)
local archiveLamp = { childCleared = true, soldierCleared = true, artifactOwned = true, museumPhase = "lamp_turn", museumSeen = false }
local r4 = runmod.createRun(20261125, "official", archiveLamp)
local mu4 = lualib.__TS__New(play.Play, rooms.MUSEUM_ROOM, nil, r4)
check("续读到末厅", mu4.phase == "museum-lamp", "phase=" .. mu4.phase)
check("续读不回柜前", mu4.phase ~= "museum-cabinet")

print("== C2-5. 回柜边：不跳过寻柜、不重复发神器 ==")
local r5 = runmod.createRun(20261125, "official", archive)
local mu5 = lualib.__TS__New(play.Play, rooms.MUSEUM_ROOM, nil, r5)
mu5.phase = "museum-done"
press(mu5, i, "interact")
check("出馆回序章", mu5.wantRoom == "prologue", "want=" .. mu5.wantRoom)
check("带回程标记", r5.story.museumReturn == true)
local pro5 = lualib.__TS__New(play.Play, rooms.PROLOGUE_ROOM, nil, r5)
step0(pro5, i, 1)
-- 修正单第 5 项：从馆里回来应站回柜边（序章等待段递针套的位置），不是井沿。
check("回程站回柜边", math.abs(pro5.player.x - 260) <= 2, "x=" .. pro5.player.x)
check("回程仍在等待段", pro5.phase == "prologue-wait", "phase=" .. pro5.phase)
check("回程标记已消费", r5.story.museumReturn == false)
local ev5 = bag(pro5)
check("回程不重复发神器", hasEvent(ev5, "artifactFound") == nil)
local again = {}
for _, e in ipairs(ev5) do again[#again + 1] = e.name end
check("回程无额外切房", pro5.wantRoom == "", "want=" .. pro5.wantRoom)

print("== C2-6. 四步完成后不再进馆 ==")
local r6 = runmod.createRun(20261125, "official", archive)
local pro6 = lualib.__TS__New(play.Play, rooms.PROLOGUE_ROOM, nil, r6)
pro6.player.x = 430
press(pro6, i, "interact")
check("已看过馆则井沿不再进馆", pro6.wantRoom == "", "want=" .. pro6.wantRoom)

print(string.format("D-C2 博物馆返场：%d 通过 / %d 失败", PASS, FAIL))
assert(FAIL == 0, "D-C2 失败")
