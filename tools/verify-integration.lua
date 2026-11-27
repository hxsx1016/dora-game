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

    local transitionKey = "runner:assets/art/" .. runner.file:gsub("%.png$", "-transition.png")
    local transitionNode
    local distinct = assets.RUN_TRANSITION_PHASES == 8 and assets.RUN_TRANSITION_LEVELS == 12
    for level = 1, assets.RUN_TRANSITION_LEVELS do
        for phase = 0, assets.RUN_TRANSITION_PHASES - 1 do
            host:beginFrame()
            assert(host:tryPlaceRun(runner.kind, "runner", 164.25, 120, 38, 90,
                phase / assets.RUN_TRANSITION_PHASES, {facing = -1}, level / (assets.RUN_TRANSITION_LEVELS + 1)))
            host:endFrame()
            local sprite = host.visibleLastFrame[transitionKey]
            transitionNode = transitionNode or sprite
            local rect = sprite.textureRect
            distinct = distinct and sprite == transitionNode and sprite.scaleX < 0 and sprite.position.y == 120
                and rect.x == 2 + phase * (runner.w + 4)
                and rect.y == 2 + (level - 1) * (runner.h + 4)
        end
    end
    check(runner.kind .. " loads all 96 start and stop cels on one anchored node", distinct)
end

do
    local node
    local valid = assets.SLIDE_FRAME_COUNT == 64
    for frame = 0, assets.SLIDE_FRAME_COUNT - 1 do
        host:beginFrame()
        assert(host:tryPlaceSlide("slider", 162.5, 120, 34, 90, (frame + 0.5) / assets.SLIDE_FRAME_COUNT))
        host:endFrame()
        local sprite = host.visibleLastFrame["slider:assets/art/zhoushu-slide.png"]
        node = node or sprite
        local rect = sprite.textureRect
        valid = valid and sprite == node and sprite.position.y == 120
            and rect.x == 2 + (frame % 8) * 304 and rect.y == 2 + math.floor(frame / 8) * 202
    end
    check("64 slide cels share the same sprite and ground anchor", valid)
end

do
    local mover = new(play.Play, rooms.PROLOGUE_ROOM)
    local i = new(Input)
    mover.player.onGround = true
    fe:bindPlay(mover, 1280, 720)
    fe.screen = "play"
    local function renderTick(dx)
        mover.ticks = mover.ticks + 1
        mover.player.x = mover.player.x + dx
        fe:renderPlay(play.STEP, mover, i, 1280, 720)
    end
    local transitionPath = "actor_soldier:assets/art/zhoushu-run-transition.png"
    renderTick(4)
    local start = fe.worldArt.visibleLastFrame[transitionPath]
    check("initial movement renders a short first stride", start ~= nil and start.visible)
    for _ = 1, 7 do renderTick(4) end
    local running = fe.worldArt.visibleLastFrame["actor_soldier:assets/art/zhoushu-run.png"]
    check("continuous movement reaches the full running cycle", running ~= nil and running.visible and not start.visible)
    local gait = fe.actors.playerStride
    local before = gait.cycle
    mover.ticks = mover.ticks + 4
    mover.player.x = mover.player.x + 16
    fe:renderPlay(4 * play.STEP, mover, i, 1280, 720)
    local expected = (before + 16 / (mover.player.h * 1.32)) % 1
    check("four simulation steps advance the gait by the measured distance", math.abs(gait.cycle - expected) < 1e-8)
    local rect = running.textureRect
    mover.paused = true
    fe:renderPlay(play.STEP, mover, i, 1280, 720)
    check("pause freezes the running pose", running.textureRect.x == rect.x and running.textureRect.y == rect.y)
    mover.paused = false
    renderTick(0)
    local braking = fe.worldArt.visibleLastFrame[transitionPath]
    check("stopping switches from running to a planted recovery", braking ~= nil and not running.visible)
    local plant = braking.textureRect
    renderTick(0)
    check("braking reduces the stride without advancing the step", braking.textureRect.x == plant.x
        and braking.textureRect.y < plant.y)
    for _ = 1, 8 do renderTick(0) end
    check("recovery ends at the standing pose", not braking.visible
        and fe.worldArt.visibleLastFrame["actor_soldier:assets/art/actors-hd.clip|soldier_idle"] ~= nil)

    local slidePath = "actor_soldier:assets/art/zhoushu-slide.png"
    local frames, last = 0, -1
    mover.player.depth = 32
    for frame = 0, 41 do
        if frame % 2 == 0 then
            mover.player.rollT = 0.35 - frame * play.STEP / 2
            mover.ticks = mover.ticks + 1
            mover.player.x = mover.player.x + 4
        end
        fe:renderPlay(play.STEP / 2, mover, i, 1280, 720)
        local sprite = fe.worldArt.visibleLastFrame[slidePath]
        local sample = sprite.textureRect
        local cel = (sample.x - 2) / 304 + 8 * (sample.y - 2) / 202
        if cel > last then frames = frames + 1 end
        last = cel
        if frame == 20 then
            local dust = fe.actors.slideDust[1]
            check("dust keeps ground height and lane depth for camera projection", dust ~= nil
                and dust.y == mover.player.y and dust.depth == mover.player.depth)
            mover.paused = true
            fe:renderPlay(0.12, mover, i, 1280, 720)
            check("pause freezes the interpolated slide pose", sprite.textureRect.x == sample.x
                and sprite.textureRect.y == sample.y)
            mover.paused = false
        end
    end
    check("at 120 Hz the slide advances on all 42 renders across 21 play ticks", frames == 42 and last >= 61)
    mover.player.rollT = 0
    renderTick(0)
    check("the slide finishes on the original play tick", fe.worldArt.visibleLastFrame[slidePath] == nil)
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
