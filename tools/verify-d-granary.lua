-- D 粮棚回归。与主持端复现一致，坐标是夹具，每个材料点走一拍玩法更新。
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local input = require("Script.watch.input")
local runmod = require("Script.watch.run")
local new = require("Script.Lib.lualib_bundle").__TS__New
local controls = new(input.Input)

local function enter(run, room)
    return new(play.Play, room, nil, run)
end

local function at(p, x)
    p.player.x, p.player.y, p.player.depth = x, 0, 0
    p.player.vy, p.player.onGround = 0, true
    p:update(play.STEP, controls)
end

local function checkMaterials(p, label, wood, bell)
    local inv = p.run.inventory
    assert(inv.wood == wood and inv.bell == bell,
        string.format("%s：预期木 %d 铃 %d，实际木 %d 铃 %d", label, wood, bell, inv.wood, inv.bell))
end

local function visitSpots(p, label, expectedEvents)
    for _, x in ipairs({380, 560, 820}) do at(p, x) end
    local count = 0
    for _, event in ipairs(p:drainEvents()) do
        if event.name == "pickup" then count = count + 1 end
    end
    checkMaterials(p, label, 2, 1)
    assert(count == expectedEvents, label .. "：拾取事件数 " .. count)
end

local function freshGranary()
    local run = runmod.createRun(20261125, "official")
    run.story.route, run.story.carry = "soldier", true
    return enter(run, rooms.ESCORT2_ROOM)
end

local first = freshGranary()
visitSpots(first, "第一局", 3)
local second = freshGranary()
visitSpots(second, "同种子第二局", 3)

local revisit = enter(second.run, rooms.ESCORT2_ROOM)
visitSpots(revisit, "同局回房", 0)
local ids = {"e2_wood_a", "e2_bell", "e2_wood_b"}
for index, id in ipairs(ids) do
    assert(rooms.ESCORT2_ROOM.pickups[index].id == id, "模板材料 ID 改变：" .. id)
    assert(revisit.run.taken[id] == true, "同局缺少拾取记录：" .. id)
end

revisit.hp, revisit.invulnT = 1, 0
local gunner = revisit.enemies[1]
gunner.awake, gunner.warnT = true, 1
at(revisit, 500)
assert(revisit.wantRoom == "escort1", "致死一击后应回男主入口")
checkMaterials(revisit, "死亡重开", 0, 0)
for _, id in ipairs(ids) do
    assert(revisit.run.taken[id] == nil, "重开仍有拾取记录：" .. id)
    assert(first.run.taken[id] == true, "重开改动了第一局的拾取记录：" .. id)
end

local entrance = enter(revisit.run, rooms.ESCORT1_ROOM)
local exitX = entrance.room.campaign.exitX
entrance.partner.x = exitX - 50
at(entrance, exitX)
assert(entrance.wantRoom == "escort2", "重开首段的出口应通往粮棚")
visitSpots(enter(entrance.run, rooms.ESCORT2_ROOM), "死亡重开后取材", 3)
print("PASS D 粮棚：连续新局各两木一铃，同局回房零次拾取，死亡重开后再次取齐")
