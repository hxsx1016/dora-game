-- D 补丁验收：粮棚拾取跨局/回访/死亡重开
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local input = require("Script.watch.input")
local runmod = require("Script.watch.run")
local lualib = require("Script.Lib.lualib_bundle")
local wf = package.loaded["watch.fe"]

local pass, fail = 0, 0
local function check(tag, cond, detail)
    if cond then pass = pass + 1; print("PASS " .. tag .. (detail and ("  " .. detail) or ""))
    else fail = fail + 1; print("FAIL " .. tag .. (detail and ("  " .. detail) or "")) end
end
local function newInput()
    local i = lualib.__TS__New(input.Input)
    return i
end
local function step(p, i)
    p:update(play.STEP, i)
    i.jump.pressed = false; i.jump.released = false
    i.crouch.pressed = false; i.crouch.released = false
    i.cover.pressed = false; i.cover.released = false
    i.interact.pressed = false; i.interact.released = false
    i.aim.pressed = false; i.aim.released = false
    i.fire.pressed = false; i.fire.released = false
    i.retry.pressed = false; i.retry.released = false
    i.pause.pressed = false; i.pause.released = false
end
local function steps(p, i, n)
    for _ = 1, n do step(p, i) end
end
local function escort2(run)
    local idx = 0
    for k, r in ipairs(rooms.ROOMS) do if r.key == "escort2" then idx = k - 1 end end
    return lualib.__TS__New(play.Play, rooms.ROOMS[idx], nil, run)
end
local function gather(p, i, tag)
    for _, pk in ipairs(p.pickups) do
        p.player.x = pk.x
        p.player.y = pk.y + (pk.depth or 0)
        p.player.depth = pk.depth or 0
        steps(p, i, 6)
    end
    print(string.format("[%s] wood=%d bell=%d taken=%d", tag, p.inventory.wood, p.inventory.bell,
        (function() local n = 0; for _ in pairs(p.run.taken) do n = n + 1 end; return n end)()))
end

wf.useTestSave("test-d-take.txt")
local i = newInput()

-- 第一局：文本入口
local p1 = wf.startStory()
check("第一局入口在序章", p1.room.key == "prologue", "room=" .. p1.room.key .. " source=" .. p1.run.source)
local e1 = escort2(p1.run)
e1.run.joined = true
gather(e1, i, "1")

-- 第二局：同进程再次从标题开局
local p2 = wf.startStory()
check("第二局入口在序章", p2.room.key == "prologue", "room=" .. p2.room.key .. " source=" .. p2.run.source)
check("新局 taken 为空", (function() for _ in pairs(p2.run.taken) do return false end; return true end)())
local e2 = escort2(p2.run)
e2.run.joined = true
gather(e2, i, "2")

-- 同局回访：同一 run 再建一次粮棚
local e2b = escort2(p2.run)
e2b.run.joined = true
gather(e2b, i, "2回访")

-- 死亡重开：男主线在护送房阵亡后应能重新取材
e2.hp = 0
e2:campaignFailed()
steps(e2, i, 30)
local e3 = escort2(p2.run)
e3.run.joined = true
gather(e3, i, "死亡重开")

print(string.format("D-TAKE  wynik：%d 通过 / %d 失败", pass, fail))
assert(fail == 0, "D-TAKE 粮棚拾取回归失败")
