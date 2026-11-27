-- Integration regression: HD aim mapping, menu input, assets and event queue.
local Dora = require("Dora")
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local Adapter = require("Script.watch.fe.adapter").PlayAdapter
local assets = require("Script.watch.fe.assets")

local pass = 0
local function check(tag, condition)
    assert(condition, "FAIL integration: " .. tag)
    pass = pass + 1
    print("PASS integration: " .. tag)
end
local function eventOf(p, name)
    for _, event in ipairs(p.events) do
        if event.name == name then return event end
    end
end

local root = Dora.Node()
local fe = new(Frontend, root)
local input = new(Input)
input.inside = true
input.mx, input.my, input.mdx, input.mdy = 130, 290, 0, 0

-- A stationary mouse must not steal keyboard selection; clicking still works.
fe.menus:onKeyEvent("Down")
fe:renderMenu(1 / 60, input, 1280, 720)
check("keyboard selection survives stationary mouse", fe.menus.selected == 1)
fe.menus:onKeyEvent("Return")
local action = fe:renderMenu(1 / 60, input, 1280, 720)
check("keyboard confirms selected chapter button", action.type == "openChapters")
fe.menus:resetInput()
input.fire.pressed = true
action = fe:renderMenu(1 / 60, input, 1280, 720)
check("click uses visible title button", action.type == "start")
input.fire.pressed = false

local p = new(play.Play, rooms.CHECKPOINT_ROOM)
p.paused = true
fe.screen = "play"
fe.menus:openPause()
fe.menus:onKeyEvent("Escape")
check("Escape resumes pause menu", fe:renderPlay(1 / 60, p, input, 1280, 720).type == "resume")
fe.menus:openChapters(2)
fe.screen = "chapters"
fe.menus:onKeyEvent("Escape")
check("chapter back returns to paused game", fe:renderMenu(1 / 60, input, 1280, 720).type == "backPause")
fe.screen = "controls"
check("ink controls page renders", fe:renderMenu(1 / 60, input, 1280, 720).type == "none")

-- The HD camera projection feeds both shooting and bottle aiming.
p = new(play.Play, rooms.STREET_ROOM)
fe:bindPlay(p, 1920, 1080)
p.aimX, p.aimY = fe.cam:sx(580), fe.cam:sy(70)
input.fire.pressed = true
p:update(play.STEP, input)
input.fire.pressed = false
local shot = eventOf(p, "shotResolved")
check("HD shot maps both axes", shot and math.abs(shot.data.aimX - 580) < 0.001 and math.abs(shot.data.aimY - 70) < 0.001)

p = new(play.Play, rooms.VILLAGE_ROOM)
p.hasBottle = true
fe:bindPlay(p, 1920, 1080)
p.aimX, p.aimY = fe.cam:sx(608), fe.cam:sy(0)
input.aim.held = true
for _ = 1, 10 do p:update(play.STEP, input) end
check("HD bottle preview maps target", math.abs(p.bottleAimX - 608) < 0.001)
input.aim.held, input.aim.released = false, true
p:update(play.STEP, input)
input.aim.released = false
local thrown = eventOf(p, "bottleThrown")
check("HD bottle throw shares preview target", thrown and math.abs(thrown.data.targetX - 608) < 0.001)
for _ = 1, 40 do p:update(play.STEP, input) end
check("HD bottle lands at preview", math.abs(p.bottleLandX - 608) < 0.001)

-- Every asset slot and animation frame must load, including new actors and ink UI.
local host = new(assets.AssetSlotHost, root, 0)
local frames = 0
for key, cfg in pairs(assets.ASSET_SLOTS) do
    for frame = 0, #cfg.paths - 1 do
        assert(host:tryPlace(key, key .. frame, 0, 0, 32, 32, {frame = frame}), "Missing asset " .. cfg.paths[frame + 1])
        frames = frames + 1
    end
end
check("all asset frames load (" .. frames .. ")", frames > 80)

-- Sample both complete cycles using the same node from the first to the last cel.
for _, runner in ipairs({
    { kind = "soldier", file = "zhoushu-run.png", w = 180, h = 200 },
    { kind = "child", file = "xiaoman-run.png", w = 144, h = 164 },
}) do
    local key = "runner:assets/art/" .. runner.file
    local original
    local valid = assets.RUN_FRAME_COUNT == 160
    for index = 0, assets.RUN_FRAME_COUNT - 1 do
        host:beginFrame()
        assert(host:tryPlaceRun(runner.kind, "runner", 164.25, 120, 38, 90, (index + 0.5) / assets.RUN_FRAME_COUNT))
        host:endFrame()
        local sprite = host.visibleLastFrame[key]
        original = original or sprite
        local rect = sprite.textureRect
        valid = valid and sprite == original
            and rect.x == 2 + (index % 10) * (runner.w + 4)
            and rect.y == 2 + math.floor(index / 10) * (runner.h + 4)
            and sprite.width == runner.w and sprite.height == runner.h
    end
    check(runner.kind .. " loads all 160 frames without allocating a node per cel", valid)
    host:beginFrame()
    host:tryPlaceRun(runner.kind, "runner", 164.25, 120, 38, 90, 1, {facing = -1})
    host:endFrame()
    check(runner.kind .. " wraps back to the first cel with the same ground anchor",
        original.textureRect.x == 2 and original.textureRect.y == 2
        and original.position.x == 164.25 and original.position.y == 120 and original.scaleX < 0)
end

do
    local mover = new(play.Play, rooms.PROLOGUE_ROOM)
    local i = new(Input)
    mover.player.onGround = true
    fe:bindPlay(mover, 1280, 720)
    fe.screen = "play"
    mover.ticks = mover.ticks + 1
    mover.player.x = mover.player.x + 4
    fe:renderPlay(play.STEP, mover, i, 1280, 720)
    local running = fe.worldArt.visibleLastFrame["actor_soldier:assets/art/zhoushu-run.png"]
    check("actual movement activates the dense running atlas", running ~= nil and running.visible)
    local rect = running.textureRect
    mover.paused = true
    fe:renderPlay(play.STEP, mover, i, 1280, 720)
    check("pause freezes the running pose", running.textureRect.x == rect.x and running.textureRect.y == rect.y)
    mover.paused = false
    mover.ticks = mover.ticks + 1
    fe:renderPlay(play.STEP, mover, i, 1280, 720)
    check("stopping does not leave the running pose visible", not running.visible)

    local phases = true
    for index, remaining in ipairs({0.35, 0.27, 0.11, 0.045}) do
        mover.player.rollT = remaining
        mover.ticks = mover.ticks + 1
        mover.player.x = mover.player.x + 4
        fe:renderPlay(play.STEP, mover, i, 1280, 720)
        local sprite = fe.worldArt.visibleLastFrame["actor_soldier:assets/art/actors-hd.clip|soldier_slide_" .. (index - 1)]
        phases = phases and sprite ~= nil and sprite.visible
    end
    check("slide enters, grounds the heel, tucks, and rises on the existing timer", phases)
end

-- The presentation adapter consumes queued events once and sees migrated room changes.
local adapter = new(Adapter)
p = new(play.Play, rooms.TOWER_ROOM)
p.player.x = 445
p.player.y = 0
p:drainEvents()
adapter:reset(p)
input.interact.pressed = true
p:update(play.STEP, input)
input.interact.pressed = false
check("adapter consumes knock queue once", adapter:sample(p).knockPulse and #p.events == 0)
check("empty frame does not repeat knock", not adapter:sample(p).knockPulse)
p:adoptEvents({{name = "roomChange", seq = 0, tick = 1, data = {from = "prologue", to = "street"}}})
check("adapter sees migrated room event", adapter:sample(p).roomChanged)

for index, room in ipairs(rooms.ROOMS) do
    p = new(play.Play, room)
    fe:bindPlay(p, 1280, 720)
    fe.screen = "play"
    fe:renderPlay(1 / 60, p, input, 1280, 720)
    p.paused = true
    fe:renderPlay(1 / 60, p, input, 1280, 720)
    check("room and ink pause render " .. index .. ": " .. room.key, true)
end

root:cleanup()
print("INTEGRATION PASS " .. pass .. " / FAIL 0")
