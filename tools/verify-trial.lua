local runs = require("Script.watch.run")
local rooms = require("Script.watch.rooms").CAMPAIGN_ROOMS
local drive = require("Script.watch.testdrive")

local function firstOffer(seed)
    local run = runs.createTrial(seed)
    drive.newSim(rooms[1], run)
    return table.concat(run.trial.offers, ",")
end

assert(firstOffer(67543212) == firstOffer(67543212))
assert(firstOffer(67543212) ~= firstOffer(12345))

for _, route in ipairs({"outer", "drygoods"}) do
    local run = runs.createTrial(67543212)
    local remainingHp = 3
    for _, room in ipairs(rooms) do
        local sim = drive.newSim(room, run)
        local input = drive.newInput()
        local offers = run.trial.offers
        assert(#offers == 3 and offers[1] ~= offers[2] and offers[2] ~= offers[3] and offers[1] ~= offers[3])
        assert(sim.hp == remainingHp and sim.maxHp == 3 + run.trial.ranks.vitality)
        local before = run.ticks
        sim:update(1 / 60, input)
        assert(run.ticks == before)
        local talent = offers[1]
        local rank = run.trial.ranks[talent]
        sim:chooseTalent(0)
        sim:chooseTalent(0)
        assert(run.trial.ranks[talent] == rank + 1 and #run.trial.offers == 0)
        assert(drive.stepRoom(sim, input, route, 4000).ok, route .. " / " .. room.key)
        assert(not run.trial.lost and run.trial.hp == sim.hp)
        remainingHp = sim.hp
        if run.finished then
            local finishTick = run.ticks
            sim:update(1 / 60, input)
            assert(run.ticks == finishTick)
        end
    end
    assert(run.finished and run.c2Latch)
    if route == "drygoods" then assert(run.props.s2_board and run.props.s2_board.broken) end
    print("PASS trial " .. route .. " / five rooms / " .. run.ticks .. " ticks")
end
