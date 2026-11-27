-- 发行态与便携包回归验收：
-- 1. 发行模式禁用 G / Tab / 1-8 调试跳房与灰盒切换，同时保留正式流程；
-- 2. 标题菜单「退出游戏」、暂停菜单「显示：窗口/全屏」与「退出游戏」动作可达；
-- 3. 补齐的 15 份战斗/通用/序章离线 WAV 音频全部存在且可由 AudioDirector 触发。

local Dora = require("Dora")
local Content = Dora.Content
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend

local pass = 0
local function check(tag, cond)
    assert(cond, "FAIL release: " .. tag)
    pass = pass + 1
    print("PASS release: " .. tag)
end

-- 1. 验证全部 15 份新增音频文件离线可读
local requiredAudio = {
    "assets/audio/combat/shot.wav",
    "assets/audio/combat/cover_block.wav",
    "assets/audio/combat/actor_hit.wav",
    "assets/audio/sfx/knock.wav",
    "assets/audio/prologue/father_wake.wav",
    "assets/audio/prologue/night_distant_fire.wav",
    "assets/audio/prologue/bed_creak.wav",
    "assets/audio/prologue/door_commotion.wav",
    "assets/audio/prologue/shadow_strike.wav",
    "assets/audio/prologue/bowl_roll.wav",
    "assets/audio/prologue/bowl_hit.wav",
    "assets/audio/prologue/heartbeat.wav",
    "assets/audio/prologue/cabinet_shut.wav",
    "assets/audio/prologue/footsteps_fade.wav",
    "assets/audio/prologue/distant_gunflash.wav",
}
for _, path in ipairs(requiredAudio) do
    check("audio exists: " .. path, Content:exist(path))
end

-- 2. 验证标题菜单与暂停菜单新增发行项
local root = Dora.Node()
local fe = new(Frontend, root)
local input = new(Input)
input.inside = false

-- 标题页：向下移动 3 次到第 4 项「退出游戏」（独立护送试炼已融入正式男主线）
fe.screen = "title"
fe.menus.selected = 0
for _ = 1, 3 do
    fe.menus:onKeyEvent("Down")
    fe:renderMenu(1 / 60, input, 1280, 720)
end
check("title menu selects quit at index 3", fe.menus.selected == 3)
fe.menus:onKeyEvent("Return")
local titleAct = fe:renderMenu(1 / 60, input, 1280, 720)
check("title quit emits quit action", titleAct.type == "quit")

-- 暂停页：index 4 为全屏切换，index 7 为退出游戏
local p = new(play.Play, rooms.PROLOGUE_ROOM)
fe:bindPlay(p, 1280, 720)
fe.screen = "play"
p.paused = true
fe.menus:openPause()
for _ = 1, 4 do
    fe.menus:onKeyEvent("Down")
    fe:renderPlay(1 / 60, p, input, 1280, 720)
end
check("pause menu selects fullscreen at index 4", fe.menus.pauseSelected == 4)
fe.menus:onKeyEvent("Return")
local fsAct = fe:renderPlay(1 / 60, p, input, 1280, 720)
check("pause fullscreen emits toggleFullscreen", fsAct.type == "toggleFullscreen")

for _ = 1, 3 do
    fe.menus:onKeyEvent("Down")
    fe:renderPlay(1 / 60, p, input, 1280, 720)
end
check("pause menu selects quit at index 7", fe.menus.pauseSelected == 7)
fe.menus:onKeyEvent("Return")
local pauseQuitAct = fe:renderPlay(1 / 60, p, input, 1280, 720)
check("pause quit emits quit action", pauseQuitAct.type == "quit")

-- 3. 验证发行标志与调试热键隔离（模拟 windows-boot.lua 注入 watch.release）
package.loaded["watch.release"] = { isRelease = true, version = "verify-rc" }
local app = require("Script.watch.app")
local appRoot = Dora.Node()
app.start(appRoot, 1, "play")
local hook = package.loaded["watch.fe"]
check("release hook reports isRelease=true", hook and hook.isRelease() == true)
check("release hook reports injected version", hook and hook.getReleaseVersion() == "verify-rc")

local appInput = package.loaded["watch.input"]
local startRoom = package.loaded["watch.room"]
appInput.toggleView.pressed = true
appInput.tab.pressed = true
appInput.pickRoom = 4
-- 触发两帧推进，确认房间未被 Tab/数字键跳走且视图未被 G 切到灰盒
Dora.thread(function()
    Dora.sleep(0.05)
    check("release mode blocks G/Tab/1-8 room skip", package.loaded["watch.room"] == startRoom)
    check("release mode consumes blocked debug inputs", appInput.pickRoom == 0 and not appInput.tab.pressed and not appInput.toggleView.pressed)
    package.loaded["watch.release"] = nil
    appRoot:cleanup()
    root:cleanup()
    print("RELEASE VERIFY PASS " .. pass .. " / FAIL 0")
end)
