-- Native Dora regression for ground-depth movement, interaction and occlusion.
local Dora = require("Dora")
local new = require("Script.Lib.lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local gameplay = require("Script.watch.play")
local Input = require("Script.watch.input").Input
local depth = require("Script.watch.depth")
local lanes = depth.LANE_DEPTH
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local derivePrompt = require("Script.watch.fe.adapter").deriveWorldPrompt
local occlusionModule = require("Script.watch.fe.occlusion")
local obscuredOpacity = occlusionModule.OCCLUDED_OPACITY

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
    advance(play, input, 4)
    local partialDepth = play.player.depth
    check(room.key .. " moves through intermediate depths on the ground",
        partialDepth > lanes.middle and partialDepth < lanes.upper and near(play.player.x, birthX) and near(play.player.y, 0))
    input.moveY = 0
    advance(play, input, 20)
    check(room.key .. " releasing movement stops at the current depth",
        near(play.player.depth, partialDepth) and near(play.player.depthSpeed, 0))
    input.moveY = 1
    advance(play, input, 1)
    check(room.key .. " reverses immediately from an intermediate depth",
        play.player.depth < partialDepth and play.player.depth > lanes.middle)
    input.moveY = -1
    advance(play, input, 60)
    check(room.key .. " holding up continues all the way to the back edge", near(play.player.depth, room.depth.max))
    input.moveY = 1
    advance(play, input, 60)
    check(room.key .. " one hold moves across the entire road", near(play.player.depth, room.depth.min))
end

do
    local room = rooms.PROLOGUE_ROOM
    local play = new(gameplay.Play, room)
    local input = new(Input)
    input.moveX = 1
    advance(play, input, 40)
    local stoneEdge = 110 - play.player.w / 2
    check("stone is solid on the middle lane", near(play.player.x, stoneEdge))

    input.moveY = -1
    advance(play, input, 5)
    check("a stone only blocks the movement component into its face",
        near(play.player.x, stoneEdge) and play.player.depth > lanes.middle and play.player.depth < lanes.upper)
    advance(play, input, 15)
    check("holding diagonal walks around the corner as soon as it clears", play.player.x > stoneEdge + 16)
    input.moveY = 0
    advance(play, input, 37)
    check("cabinet can be walked around without jumping", play.player.x > 280 and near(play.player.y, 0))
    check("prologue prompt respects depth", derivePrompt(play) == nil)
    input.moveX, input.interact.pressed = 0, true
    advance(play, input, 1)
    check("interact cannot reach across the road", play.phase == "prologue-wait")
    input.interact.pressed, input.moveY = false, 1
    advance(play, input, 10)
    check("prompt reappears at an off-center depth beside the child",
        play.player.depth > lanes.middle and derivePrompt(play).keyTag == "E")
    input.moveY = 0
    input.interact.pressed = true
    advance(play, input, 1)
    check("interact works within depth reach", play.phase == "prologue-give")

    play = new(gameplay.Play, room)
    play.player.depth = lanes.lower
    input.moveX, input.moveY, input.interact.pressed = 1, 0, false
    advance(play, input, 40)
    check("stone still blocks on the side nearest the screen", near(play.player.x, stoneEdge))

    play.player.x, play.player.depth = 128, lanes.upper
    input.moveX, input.moveY = 0, 1
    advance(play, input, 40)
    local stone = play.room.solids[#play.room.solids]
    local depthEdge = stone.depth.max + depth.ACTOR_DEPTH_HALF
    check("depth movement stops at the actual stone edge", near(play.player.depth, depthEdge))
    input.moveX = 1
    advance(play, input, 24)
    check("the actor slides along the obstacle while pressing into it",
        play.player.x > 190 and near(play.player.depth, depthEdge))
    advance(play, input, 31)
    check("depth movement resumes beyond the footprint without a new press",
        play.player.x > 265 and play.player.depth < depthEdge and near(play.player.y, 0))

    play.player.x = 195
    local cabinet = room.solids[1]
    play.player.y, play.player.depth, play.player.onGround = cabinet.h, lanes.middle, true
    input.moveX, input.moveY = 0, -1
    advance(play, input, 40)
    check("step off the cabinet in depth and fall", near(play.player.depth, room.depth.max) and near(play.player.y, 0))
end

do
    for _, side in ipairs({"upper", "lower"}) do
        local play = new(gameplay.Play, rooms.PROLOGUE_ROOM)
        local input = new(Input)
        play.phase = "prologue-follow"
        play.player.x, play.player.depth, play.partner.x = 610, lanes[side], 650
        input.moveX = 1
        advance(play, input, 26)
        check(side .. " door post blocks movement and scene transition",
            near(play.player.x, 648 - play.player.w / 2) and play.wantRoom == "")
        input.moveY = side == "upper" and 1 or -1
        advance(play, input, 14)
        local doorDepth = play.player.depth
        input.moveY = 0
        advance(play, input, 15)
        check("the doorway is traversable off center from the " .. side .. " side",
            math.abs(doorDepth) > 3 and near(play.player.depth, doorDepth) and play.wantRoom == "street")
    end
end

do
    local play = new(gameplay.Play, rooms.STREET_ROOM)
    local input = new(Input)
    input.moveY = -1
    advance(play, input, 5)
    input.moveY = 0
    advance(play, input, 45)
    check("companion follows the actor to an intermediate depth",
        play.player.depth > lanes.middle and play.player.depth < lanes.upper and near(play.partner.depth, play.player.depth))
end

do
    local play = new(gameplay.Play, rooms.GATE_ROOM)
    local input = new(Input)
    local gate = play.room.story.gate
    play.player.x, play.player.depth, play.partner.x = gate.winchX, lanes.upper, gate.waitX
    advance(play, input, 1)
    check("winch cannot start from the back lane", play.phase == "gate-idle")
    play.player.depth = 0
    advance(play, input, 2)
    check("winch starts when the guard is near its depth", play.phase == "gate-hold")

    play.player.x, play.player.depth = 505, lanes.lower
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
    play.player.x, play.player.depth = play.cartAxle + cart.handleOffset, lanes.upper
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
    local stoneSpec = play.room.solids[#play.room.solids]
    local blocker = {x0=stoneSpec.x, x1=stoneSpec.x + stoneSpec.w, y0=0, y1=stoneSpec.h, depth=stoneSpec.depth}
    local occlusion = new(occlusionModule.DepthOcclusion)
    local input = new(Input)
    play.player.x, play.player.depth = 128, 28.5
    local alpha = occlusion:update("prop", blocker, play, 1 / 60)
    check("occluder fades gradually", alpha < 1 and alpha > obscuredOpacity)
    check("occluder retains a darker silhouette", near(occlusion:update("prop", blocker, play, .2), obscuredOpacity) and obscuredOpacity > .24)
    check("paused fade holds", near(occlusion:update("prop", blocker, play, 0), obscuredOpacity))
    play.player.x = 95
    check("occluder recovers opacity when overlap ends", near(occlusion:update("prop", blocker, play, .3), 1))

    play.player.x = 128
    frontend:bindPlay(play, 1280, 720)
    frontend.screen = "play"
    for _ = 1, 14 do frontend:renderPlay(1 / 60, play, input, 1280, 720) end
    local stone = frontend.worldArt.visibleLastFrame["depth_solid_110_-44:assets/art/sprites.clip|wall"]
    local actor = frontend.worldArt.visibleLastFrame["actor_soldier:assets/art/sprites.clip|soldier_idle"]
    check("actual stone sprite is sorted, darkened and faded",
        stone and actor and stone.order > actor.order and near(stone.opacity, obscuredOpacity) and stone.color.r < 150)
    play.player.x = 95
    for _ = 1, 20 do frontend:renderPlay(1 / 60, play, input, 1280, 720) end
    check("stone sprite recovers opacity and tint after the actor leaves", near(stone.opacity, 1) and stone.color.r > 160)

    play.player.x, play.player.depth = 660, lanes.middle
    frontend:bindPlay(play, 1280, 720)
    for _ = 1, 14 do frontend:renderPlay(1 / 60, play, input, 1280, 720) end
    local nearPost = frontend.worldArt.visibleLastFrame["depth_solid_648_-44:assets/art/sprites.clip|wall"]
    local farPost = frontend.worldArt.visibleLastFrame["depth_solid_648_20:assets/art/sprites.clip|wall"]
    local sill = frontend.worldArt.visibleLastFrame["gate_sill_648:assets/art/sprites.clip|slab"]
    actor = frontend.worldArt.visibleLastFrame["actor_soldier:assets/art/sprites.clip|soldier_idle"]
    check("door passage draws the actor between the posts",
        nearPost and farPost and actor and sill and nearPost.order > actor.order and actor.order > farPost.order and
        near(nearPost.opacity, obscuredOpacity) and near(farPost.opacity, 1))
end

root:cleanup()
print("DEPTH PASS " .. passed .. " / FAIL 0")
