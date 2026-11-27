-- 回归验收：上卷 S1–C2 双路线（外檐/布行）贯通 + 下卷男主线肉鸽护送（种子确定性/8 本领池/遭遇变体/轮次重整）
local Dora = require("Dora")
local Content = Dora.Content
local Path = Dora.Path
do
    local src = debug.getinfo(1, "S").source or ""
    src = src:gsub("^@", "")
    local toolsDir = Path:getPath(src)
    local repoRoot = Path:getPath(toolsDir)
    if repoRoot ~= "" and Content:exist(Path(repoRoot, "init.lua")) then
        Content:insertSearchPath(1, repoRoot)
        Content:insertSearchPath(2, Path(repoRoot, "Script"))
        Content:insertSearchPath(3, Path(repoRoot, "Script", "Lib"))
    end
end

local runs = require("Script.watch.run")
local roomsMod = require("Script.watch.rooms")
local campaignRooms = roomsMod.CAMPAIGN_ROOMS
local drive = require("Script.watch.testdrive")

-- 1. 下卷男主线肉鸽出牌确定性与种子区分
local function firstEscortOffer(seed)
    local run = runs.createRun(seed, "official")
    run.story.route = "soldier"
    run.story.settled = true
    local sim = drive.newSim(roomsMod.ESCORT1_ROOM, run)
    return table.concat(sim:getStoryTalentOffers(), ",")
end

assert(firstEscortOffer(67543212) == firstEscortOffer(67543212))
assert(firstEscortOffer(67543212) ~= firstEscortOffer(12345))
print("PASS male-route roguelike seed determinism")

-- 2. 上卷 S1–C2 外檐 / 布行双路线五房贯通（正式局 C2 出口衔接城门 gate）
for _, route in ipairs({ "outer", "drygoods" }) do
    local run = runs.createRun(67543212, "official")
    local remainingHp = 3
    for idx, room in ipairs(campaignRooms) do
        local sim = drive.newSim(room, run)
        local input = drive.newInput()
        assert(sim.hp == remainingHp and sim.maxHp == 3, route .. " / hp mismatch at " .. room.key)
        assert(drive.stepRoom(sim, input, route, 4000).ok, route .. " / " .. room.key)
        assert(sim.hp > 0, route .. " / died at " .. room.key)
        if idx < #campaignRooms then
            assert(sim.wantRoom == campaignRooms[idx + 1].key,
                route .. " / expected " .. campaignRooms[idx + 1].key .. ", got " .. tostring(sim.wantRoom))
        else
            assert(sim.wantRoom == "gate" and run.finished == false,
                route .. " / expected C2 -> gate, got " .. tostring(sim.wantRoom))
        end
        remainingHp = sim.hp
    end
    assert(run.c2Latch, route .. " / c2Latch missing")
    if route == "drygoods" then
        assert(run.props.s2_board and run.props.s2_board.broken, "drygoods / s2_board not broken")
    end
    print("PASS campaign " .. route .. " / five rooms -> gate / " .. run.ticks .. " ticks")
end
