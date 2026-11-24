-- Native Dora regression for ground-depth movement, interaction and occlusion.
local Dora = require("Dora")
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local gameplay = require("Script.watch.play")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local derivePrompt = require("Script.watch.fe.adapter").deriveWorldPrompt
local Occlusion = require("Script.watch.fe.occlusion").DepthOcclusion

local passed = 0
local function check(label, ok)
    assert(ok, "DEPTH FAIL: " .. label)
    passed = passed + 1
    print("DEPTH PASS: " .. label)
end

local function advance(play, input, frames)
    for _ = 1, frames do play:update(gameplay.STEP, input) end
end

local function near(a, b)
    return math.abs(a - b) < 0.001
end

for _, room in ipairs({rooms.PROLOGUE_ROOM, rooms.STREET_ROOM, rooms.CHECKPOINT_ROOM, rooms.GATE_ROOM}) do
    local play = new(gameplay.Play, room)
    local input = new(Input)
    local birthX = play.player.x
    input.moveY = -1
    advance(play, input, 60)
    check(room.key .. " moves toward the back on the ground",
        near(play.player.depth, room.depth.max) and near(play.player.x, birthX) and near(play.player.y, 0))
    input.moveY = 1
    advance(play, input, 70)
    check(room.key .. " respects the front edge", near(play.player.depth, room.depth.min))
end

do
    local room = rooms.PROLOGUE_ROOM
    local play = new(gameplay.Play, room)
    local input = new(Input)
    input.moveX = 1
    advance(play, input, 40)
    check("foreground decoration admits passage, cabinet blocks its own lane",
        near(play.player.x, room.solids[1].x - play.player.w / 2))

    input.moveX, input.moveY = 0, -1
    advance(play, input, 18)
    input.moveX, input.moveY = 1, 0
    advance(play, input, 44)
    check("walk around cabinet on the back lane", play.player.x > 280 and near(play.player.y, 0))
    check("prologue prompt respects depth", derivePrompt(play) == nil)
    input.moveX, input.interact.pressed = 0, true
    advance(play, input, 1)
    check("interact cannot reach across the road", play.phase == "prologue-wait")
    play.player.depth = 0
    check("prompt reappears beside the child", derivePrompt(play).keyTag == "E")
    advance(play, input, 1)
    check("interact works within depth reach", play.phase == "prologue-give")

    play = new(gameplay.Play, room)
    play.player.x, play.player.depth = 195, 40
    input.interact.pressed, input.moveY = false, 1
    advance(play, input, 40)
    check("solid blocks entry across its back edge", play.player.depth >= room.solids[1].depth.max and near(play.player.y, 0))
    play.player.y, play.player.depth, play.player.onGround = room.solids[1].h, 0, true
    input.moveY = -1
    advance(play, input, 40)
    check("step off the cabinet in depth and fall", near(play.player.depth, room.depth.max) and near(play.player.y, 0))
end

do
    local play = new(gameplay.Play, rooms.STREET_ROOM)
    local input = new(Input)
    input.moveY = -1
    advance(play, input, 45)
    check("companion follows a change in depth", near(play.partner.depth, play.player.depth))
end

do
    local play = new(gameplay.Play, rooms.GATE_ROOM)
    local input = new(Input)
    local gate = play.room.story.gate
    play.player.x, play.player.depth, play.partner.x = gate.winchX, play.room.depth.max, gate.waitX
    advance(play, input, 1)
    check("winch cannot start from the back lane", play.phase == "gate-idle")
    play.player.depth = 0
    advance(play, input, 2)
    check("winch starts when the guard is near its depth", play.phase == "gate-hold")

    play.player.x, play.player.depth = 505, play.room.depth.max
    input.cover.held = true
    advance(play, input, 1)
    check("a street barrier in a different lane cannot be used as cover", not play.coverHug)
    play.player.depth = 0
    advance(play, input, 1)
    check("the same street barrier guards the correct lane and side", play.coverHug and play.coverBlocking)
end

do
    local play = new(gameplay.Play, rooms.CHECKPOINT_ROOM)
    local input = new(Input)
    local cart = play.room.cart
    play.player.x, play.player.depth = play.cartAxle + cart.handleOffset, play.room.depth.max
    input.interact.pressed, input.interact.held = true, true
    advance(play, input, 1)
    check("distant cart handle cannot be grabbed or prompted", not play.gripping and derivePrompt(play) == nil)
    play.player.depth = 0
    advance(play, input, 1)
    check("cart grip seats the actor on its own track", play.gripping and near(play.player.depth, cart.depth))
    input.moveX, input.moveY, input.interact.pressed = 1, -1, false
    advance(play, input, 30)
    check("cart travels while grip locks depth", play.cartAxle > cart.startX and near(play.player.depth, cart.depth))
end

do
    local play = new(gameplay.Play, rooms.OUTSIDE_ROOM)
    local input = new(Input)
    input.moveY, input.crouch.held = 1, true
    advance(play, input, 20)
    check("child chapter still uses the crouch input", play.player.crouch and near(play.player.depth, 0))
end

local root = Dora.Node()
local frontend = new(Frontend, root)
do
    local play = new(gameplay.Play, rooms.STREET_ROOM)
    local input = new(Input)
    play.player.x, play.player.depth = 200, 38
    play.enemies = {{x=440, y=0, depth=0, w=26, h=84, alive=true, hitT=0, warnT=0, fireCd=0}}
    play.boxes = {{x0=295, x1=345, y0=0, y1=95, depth={min=-7, max=10}}}
    frontend:bindPlay(play, 1440, 900)
    play.aimX, play.aimY = frontend.cam:sx(440), frontend.cam:sy(45)
    input.fire.pressed = true
    advance(play, input, 1)
    check("aim hits across depths past a solid's footprint",
        play.trace.hit and not play.enemies[1].alive and near(play.trace.y0, 38 + play.player.h * .72))
    play.boxes[1].depth.max = 40
    play.enemies[1].alive = true
    advance(play, input, 1)
    check("same aim is blocked when the ray crosses the footprint",
        not play.trace.hit and play.enemies[1].alive and play.trace.x1 < 345)
end

do
    local play = new(gameplay.Play, rooms.PROLOGUE_ROOM)
    local blocker = {x0=110, x1=154, y0=0, y1=62, depth={min=-25, max=-15}, passThrough=true}
    local occlusion = new(Occlusion)
    local input = new(Input)
    play.player.x = 128
    local alpha = occlusion:update("prop", blocker, play, 1 / 60)
    check("occluder fades gradually", alpha < 1 and alpha > .24)
    check("occluder reaches readable transparency", near(occlusion:update("prop", blocker, play, .2), .24))
    check("paused fade holds", near(occlusion:update("prop", blocker, play, 0), .24))
    play.player.x = 95
    check("occluder recovers opacity when overlap ends", near(occlusion:update("prop", blocker, play, .3), 1))

    play.player.x = 128
    frontend:bindPlay(play, 1280, 720)
    frontend.screen = "play"
    for _ = 1, 14 do frontend:renderPlay(1 / 60, play, input, 1280, 720) end
    local stone = frontend.worldArt.visibleLastFrame["depth_solid_110_-25:assets/art/sprites.clip|cover_stone"]
    local actor = frontend.worldArt.visibleLastFrame["actor_soldier:assets/art/sprites.clip|soldier_idle"]
    check("actual foreground sprite is sorted and faded", stone and actor and stone.order > actor.order and near(stone.opacity, .24))
    play.player.depth = -28
    for _ = 1, 20 do frontend:renderPlay(1 / 60, play, input, 1280, 720) end
    check("actor on the front side is drawn in front", actor.order > stone.order)
end

root:cleanup()
print("DEPTH PASS " .. passed .. " / FAIL 0")
