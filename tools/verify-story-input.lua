-- Run the scheduled app frame with each target's real input adapter.
local Dora = require("Dora")
local app = require("Script.watch.app")
local target = require("Script.watch.target")
local controls = require("Script.watch.controls_config")
local rooms = require("Script.watch.rooms").ROOMS
local escortIndex
for i, room in ipairs(rooms) do
    if room.key == "escort1" then escortIndex = i - 1 end
end
assert(escortIndex)
controls.setControlSettingsFile("watch-save/qa-unified-input.controls")

for _, id in ipairs({"windows", "handheld", "android", "web"}) do
    package.loaded["watch.target"] = id
    target.resetActiveTarget()
    local root, scheduler = Dora.Node(), Dora.Scheduler()
    root.scheduler = scheduler
    Dora.Director.entry:addChild(root)
    app.start(root)
    local h = package.loaded["watch.fe"]
    h.useTestSave("watch-save/qa-unified-input")
    local p = h.previewChapter(escortIndex, "soldier", 2711)
    local fe = h.getFrontend()
    local vp = h.applyViewportForTest(1280, 720)
    local function frame()
        scheduler:update(1 / 60)
    end
    local function tap(box)
        local x = vp.stageX + (box.x + box.width / 2) * vp.uiScale
        local y = vp.stageY + (box.y + box.height / 2) * vp.uiScale
        h.injectTouch("began", 1, x, y, false)
        h.injectTouch("ended", 1, x, y, false)
        frame()
    end
    local touch = id == "android" or id == "web"
    h.setModePref(touch and "touch" or (id == "handheld" and "gamepad" or "kbm"))
    frame()
    local offered = p:getStoryTalentOffers()
    assert(#offered == 3 and p.run.seed == 2711, id .. " preview")
    local wanted = offered[2]
    if id == "windows" then
        fe.roguelikeUi:openLedger()
        root:emit("KeyDown", "2")
        frame()
        assert(#p:getStoryTalentOffers() == 3, "ledger leaked a keyboard pick")
        fe.roguelikeUi:closeLedger()
        root:emit("KeyDown", "2")
        frame()
    elseif id == "handheld" then
        h.setGamepadSim({right = true})
        frame()
        assert(fe.hud.talentSelected == 1, "D-pad must move the displayed cursor once")
        h.setGamepadSim({a = true})
        frame()
        h.setGamepadSim({})
    else
        tap(fe:getStoryTalentBoxes(p, vp.stageW, vp.stageH, true)[2])
    end
    assert(#p:getStoryTalentOffers() == 0 and p.run.story.talents.ranks[wanted] == 1, id .. " pick")

    local attempt = p.run.story.talents.attempt
    p:campaignFailed()
    for _ = 1, 36 do frame() end
    assert(p.escortSummary.ranks[wanted] == 1 and fe.roguelikeUi:getState().deathRecapActive, id .. " recap")
    if touch then
        local buttons = fe:getEscortDeathBoxes(p, vp.stageW, vp.stageH)
        tap(id == "android" and buttons.retry or buttons.title)
    elseif id == "handheld" then
        h.setGamepadSim({a = true})
        frame()
    else
        root:emit("KeyDown", "Escape")
        frame()
    end
    if id == "handheld" or id == "android" then
        local nextPlay = h.getPlay()
        assert(nextPlay ~= p and nextPlay.room.key == "escort1" and nextPlay.run.story.talents.attempt == attempt + 1
            and #nextPlay:getStoryTalentOffers() == 3, id .. " restart")
    else
        assert(fe.screen == "title" and p.run.story.talents.attempt == attempt + 1, id .. " return to title")
    end
    root:removeFromParent()
    print("PASS unified story input " .. id)
end
package.loaded["watch.target"] = nil
target.resetActiveTarget()
controls.setControlSettingsFile("")
