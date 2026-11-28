-- FE-02 专项回归与排演验收脚本（背负姿态 + 3x3 慢时连线换弹 + 第三段安全工台）
local Dora = require("Dora")
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local carryMod = require("Script.watch.fe.renderer.carry_pose")
local reloadMod = require("Script.watch.fe.ui.reload_wheel")
local craftMod = require("Script.watch.fe.ui.craft_bench")

local pass = 0
local function check(tag, condition)
	assert(condition, "FAIL fe02: " .. tag)
	pass = pass + 1
	print("PASS fe02: " .. tag)
end

local function approx(a, b, eps)
	return math.abs(a - b) <= (eps or 0.05)
end

-- 1. 音频资源离线可读核验（全部 11 份战斗/换弹/工台 WAV）
local audioFiles = {
	"assets/audio/combat/carry_start.wav",
	"assets/audio/combat/reload_open.wav",
	"assets/audio/combat/reload_node.wav",
	"assets/audio/combat/reload_invalid.wav",
	"assets/audio/combat/reload_solved.wav",
	"assets/audio/combat/reload_solved_knockback.wav",
	"assets/audio/combat/reload_solved_echo.wav",
	"assets/audio/combat/reload_solved_light.wav",
	"assets/audio/combat/reload_timeout.wav",
	"assets/audio/combat/craft_done.wav",
	"assets/audio/combat/craft_insufficient.wav",
}
for _, path in ipairs(audioFiles) do
	check("audio asset exists: " .. path, Dora.Content:exist(path))
end

-- 2. 3x3 拓扑纯函数断言（对齐后端 Script/watch/reload.ts）
check("adjacent orthogonal (0,1)", reloadMod.isAdjacentNode(0, 1))
check("adjacent diagonal (0,4)", reloadMod.isAdjacentNode(0, 4))
check("adjacent self rejected (4,4)", not reloadMod.isAdjacentNode(4, 4))
check("adjacent jump rejected (0,8)", not reloadMod.isAdjacentNode(0, 8))
check("adjacent jump rejected (0,2)", not reloadMod.isAdjacentNode(0, 2))
check("path push valid 0->3->6->7->8", reloadMod.validateReloadPath({0, 3, 6, 7, 8}))
check("path echo valid 0->1->4->5->8", reloadMod.validateReloadPath({0, 1, 4, 5, 8}))
check("path light valid 0->1->2->5->8", reloadMod.validateReloadPath({0, 1, 2, 5, 8}))
check("path duplicate rejected", not reloadMod.validateReloadPath({0, 1, 4, 1, 5, 8}))
check("path missing end rejected", not reloadMod.validateReloadPath({0, 1, 4, 5}))
check("effect push -> knockback", reloadMod.deriveEffectFromGrid({0, 3, 6, 7, 8}) == "knockback")
check("effect bell -> echo", reloadMod.deriveEffectFromGrid({0, 1, 4, 5, 8}) == "echo")
check("effect lamp -> light", reloadMod.deriveEffectFromGrid({0, 1, 2, 5, 8}) == "light")
check("effect bell priority over lamp", reloadMod.deriveEffectFromGrid({0, 1, 2, 4, 8}) == "echo")

-- 3. 装配 WatchFrontend 与三大 FE-02 插件（零改动 frontend.ts）
local root = Dora.Node()
local fe = new(Frontend, root)
local carryPlugin = carryMod.createCarryPosePlugin()
local reloadPlugin = reloadMod.createReloadWheelPlugin(fe.contract)
local craftPlugin = craftMod.createCraftBenchPlugin(fe.contract)

fe:registerPlugin(carryPlugin)
fe:registerPlugin(reloadPlugin)
fe:registerPlugin(craftPlugin)
local hasCarry, hasReload, hasCraft = false, false, false
for _, pl in ipairs(fe:getPlugins()) do
	if pl.id == "fe-02-carry-pose" then hasCarry = true end
	if pl.id == "fe-02-reload-wheel" then hasReload = true end
	if pl.id == "fe-02-craft-bench" then hasCraft = true end
end
check("registered 3 fe-02 plugins", #fe:getPlugins() >= 3 and hasCarry and hasReload and hasCraft)
check("default guidance assistHintsEnabled=true", fe.contract:isAssistHintsEnabled())

local input = new(Input)
input.inside = true
local p = new(play.Play, rooms.STREET_ROOM)
fe.screen = "play"
fe:bindPlay(p, 1280, 720)

local function stepFrame(dt)
	fe:renderPlay(dt or (1 / 60), p, input, 1280, 720)
end

-- ==================== A. 背负姿态（牵手 / 蹲背攀爬 / 背负转身 / 探手 / 工台放下） ====================
fe.contract:enterRehearsal("fe02-carry")
fe.contract:setMockRoute("soldier")

-- A1. 牵手平路
fe.contract:setMockBackCarry({ handInHand = true, active = false, mounting = false, atBench = false })
stepFrame(1 / 60)
check("carry mode handInHand", carryPlugin:getPoseState().mode == "handInHand")

-- A2. 高石阶蹲背攀爬 + 暂停冻结
fe.contract:setMockBackCarry({ handInHand = false, active = false, mounting = true, atBench = false })
for _ = 1, 10 do stepFrame(1 / 60) end
local mountMid = carryPlugin:getPoseState().mountT
check("mounting advances mountT", mountMid > 0.2 and mountMid < 0.8)
p.paused = true
for _ = 1, 15 do stepFrame(1 / 60) end
check("mounting freezes on pause", approx(carryPlugin:getPoseState().mountT, mountMid, 0.0001))
p.paused = false
for _ = 1, 30 do stepFrame(1 / 60) end
check("mounting reaches 1.0", carryPlugin:getPoseState().mountT >= 0.99)

-- A3. 背负常规移动与平滑转身（无瞬移闪跳）
fe.contract:setMockBackCarry({ handInHand = false, active = true, mounting = false, atBench = false })
p.player.facing = 1
for _ = 1, 20 do stepFrame(1 / 60) end
local fRight = carryPlugin:getPoseState().smoothedFacing
check("carrying faces right", fRight > 0.9)
p.player.facing = -1
stepFrame(1 / 60)
local fTurnStep1 = carryPlugin:getPoseState().smoothedFacing
check("carrying turn is smooth (not instant jump)", fTurnStep1 < fRight and fTurnStep1 > -0.8)
for _ = 1, 45 do stepFrame(1 / 60) end
check("carrying finishes turn to left", carryPlugin:getPoseState().smoothedFacing < -0.95)
check("carry audio logged", #fe.audio:getPlayLog() > 0)

-- A4. 工台放下与离开重新背起
fe.contract:setMockBackCarry({ active = true, atBench = true })
for _ = 1, 30 do stepFrame(1 / 60) end
check("atBench mode and benchDropT", carryPlugin:getPoseState().mode == "atBench" and carryPlugin:getPoseState().benchDropT > 0.85)
fe.contract:setMockBackCarry({ active = true, atBench = false })
for _ = 1, 30 do stepFrame(1 / 60) end
check("leaving bench resumes carrying", carryPlugin:getPoseState().mode == "carrying" and carryPlugin:getPoseState().benchDropT < 0.15)

-- ==================== B. 3×3 慢时连线换弹（三路径 + 双输入 + 无效重画 + 超时 + 暂停 + 240:60） ====================
fe.contract:enterRehearsal("fe02-reload")
fe.contract:setMockRoute("soldier")
fe.contract:setMockBackCarry({ active = true, atBench = false })

-- B1. 鼠标拖线：推退 0 -> 3 -> 6 -> 7 -> 8
fe.contract:triggerMockReload(true, { firstTime = true, duration = 4.0, slowTimeScale = 0.25 })
stepFrame(1 / 60)
check("reload active & timeScale 0.25", reloadPlugin:getState().active and approx(fe.contract:getLastSnapshot().timeScale, 0.25, 0.01))
check("carry reachT begins extending on reload", carryPlugin:getPoseState().reachT > 0)

local function dragNode(nodeId, hold)
	local pos = reloadPlugin:getNodeUiPos(nodeId)
	reloadPlugin:injectInputForTest({ pointerX = pos.x, pointerY = pos.y, leftHeld = hold })
	stepFrame(1 / 60)
end

dragNode(0, true)
dragNode(3, true)
dragNode(6, true)
dragNode(7, true)
check("preview push path before end", reloadPlugin:getState().previewEffect == "knockback")
dragNode(8, true)
stepFrame(1 / 60)
check("mouse drag knockback solved", not reloadPlugin:getState().active and fe.contract:getLastSnapshot().reloadSession.nextEffect == "knockback")
check("timeScale restored to 1 after solve", approx(fe.contract:getLastSnapshot().timeScale, 1.0, 0.01))
check("retract finger animation active after solve", reloadPlugin:getState().retracting)

-- B2. 键盘相邻选点：回声 0 -> 1 -> 4 -> 5 -> 8
fe.contract:triggerMockReload(true, { firstTime = false, duration = 4.0, slowTimeScale = 0.25 })
stepFrame(1 / 60)
local function keyStep(dCol, dRow, confirm, reset)
	reloadPlugin:injectInputForTest({ moveCol = dCol, moveRow = dRow, confirm = confirm, reset = reset })
	stepFrame(1 / 60)
end
keyStep(1, 0, true, false) -- 0 -> 1
keyStep(0, 1, true, false) -- 1 -> 4 (bell)
stepFrame(1 / 60)
check("keyboard bell node previews echo", fe.contract:getLastSnapshot().reloadSession.previewEffect == "echo")
keyStep(1, 0, true, false) -- 4 -> 5
keyStep(0, 1, true, false) -- 5 -> 8
stepFrame(1 / 60)
check("keyboard echo solved", not reloadPlugin:getState().active and fe.contract:getLastSnapshot().reloadSession.nextEffect == "echo")

-- B3. 照明路径 0 -> 1 -> 2 -> 5 -> 8（按住鼠标停顿在 2 上看预览，再继续拖至 5 -> 8）
fe.contract:triggerMockReload(true, { firstTime = false, duration = 4.0, slowTimeScale = 0.25 })
stepFrame(1 / 60)
dragNode(0, true)
dragNode(1, true)
dragNode(2, true)
dragNode(2, true)
check("lamp node previews light", fe.contract:getLastSnapshot().reloadSession.previewEffect == "light")
dragNode(5, true)
dragNode(8, true)
stepFrame(1 / 60)
check("light path solved", not reloadPlugin:getState().active and fe.contract:getLastSnapshot().reloadSession.nextEffect == "light")

-- B4. 无效跳点 & 半途松手清回 [0] 且不重计 4 秒
fe.contract:triggerMockReload(true, { firstTime = false, duration = 4.0, slowTimeScale = 0.25 })
for _ = 1, 60 do stepFrame(1 / 60) end -- 推进 1.0s
local elapsedBeforeInvalid = fe.contract:getLastSnapshot().reloadSession.elapsed
check("elapsed ~1.0s before invalid", elapsedBeforeInvalid >= 0.95)
dragNode(0, true)
dragNode(1, true)
-- 跳点直戳 8（非法不相邻）
dragNode(8, true)
stepFrame(1 / 60)
local snapAfterJump = fe.contract:getLastSnapshot().reloadSession
check("jump node resets path to [0] and flashes invalid", #snapAfterJump.path == 1 and snapAfterJump.path[1] == 0 and reloadPlugin:getState().invalidFlash > 0)
check("invalid jump preserves elapsed timer", snapAfterJump.elapsed >= elapsedBeforeInvalid)
-- 半途松手（0 -> 3 后松开）
dragNode(0, true)
dragNode(3, true)
dragNode(3, false)
stepFrame(1 / 60)
local snapAfterDrop = fe.contract:getLastSnapshot().reloadSession
check("early mouse release resets path to [0]", #snapAfterDrop.path == 1 and snapAfterDrop.path[1] == 0)
check("early release preserves elapsed timer", snapAfterDrop.elapsed >= elapsedBeforeInvalid)

-- B5. 暂停冻结双时钟与路径，恢复续答并校验 240:60 比例
dragNode(0, true)
dragNode(4, true)
dragNode(4, true)
local elapsedBeforePause = fe.contract:getLastSnapshot().reloadSession.elapsed
local pathLenBeforePause = #fe.contract:getLastSnapshot().reloadSession.path
check("paused path holds [0,4]", pathLenBeforePause == 2)
p.paused = true
for _ = 1, 30 do stepFrame(1 / 60) end
check("pause freezes reload elapsed & path", approx(fe.contract:getLastSnapshot().reloadSession.elapsed, elapsedBeforePause, 0.0001) and #fe.contract:getLastSnapshot().reloadSession.path == pathLenBeforePause)
p.paused = false
dragNode(8, true)
stepFrame(1 / 60)
check("resume finishes paused path to echo", not reloadPlugin:getState().active and fe.contract:getLastSnapshot().reloadSession.nextEffect == "echo")

-- B6. 完整 240 作答拍 = 60 世界拍超时校验（收为 normal）
fe.contract:triggerMockReload(true, { firstTime = false, duration = 4.0, slowTimeScale = 0.25 })
local lastActiveClock = nil
for _ = 1, 245 do
	stepFrame(1 / 60)
	local clk = reloadPlugin:getClockReadings()
	if clk.active then
		lastActiveClock = clk
	end
end
check("timeout closes reload & yields normal", not reloadPlugin:getState().active and fe.contract:getLastSnapshot().reloadSession.nextEffect == "normal")
check("clock ratio 240:60 verified", lastActiveClock ~= nil and lastActiveClock.answerTicks >= 238 and lastActiveClock.worldTicks >= 58 and lastActiveClock.worldTicks <= 62)

-- ==================== C. 第三段安全工台与首次试握（缺料 / 取消 / 首制1s / 幂等 / 二制短动作 / 读档） ====================
fe.contract:enterRehearsal("fe02-bench")
fe.contract:setMockRoute("soldier")

-- C1. 缺料高亮，不发请求、不扣料
fe.contract:triggerMockBench(true, { inventory = { wood_tally = 1, bell_tally = 0 }, equippedWeapon = "standard_gun" })
stepFrame(1 / 60)
craftPlugin:injectInputForTest({ confirm = true })
stepFrame(1 / 60)
local stLack = craftPlugin:getState()
check("insufficient materials blocks craft & highlights wood_tally", stLack.missingFlashT > 0 and #stLack.missingMaterials == 1 and stLack.missingMaterials[1] == "wood_tally")
check("insufficient keeps inventory intact", stLack.inventory.wood_tally == 1 and #stLack.craftedIds == 0)

-- C2. 取消工台完整保留材料
craftPlugin:injectInputForTest({ cancel = true })
stepFrame(1 / 60)
stepFrame(1 / 60)
check("cancel closes bench and preserves materials", not fe.contract:getLastSnapshot().craftBench.active and fe.contract:getLastSnapshot().craftBench.inventory.wood_tally == 1)

-- C3. 首次制成：扣料 + 1.0 秒试握 + 重复确认幂等 + 立即装备
fe.contract:triggerMockBench(true, { inventory = { wood_tally = 2, bell_tally = 1 }, equippedWeapon = "standard_gun" })
stepFrame(1 / 60)
craftPlugin:injectInputForTest({ confirm = true })
stepFrame(1 / 60)
-- 紧接着立即重复确认，验证幂等不重复扣料/不重发
craftPlugin:injectInputForTest({ confirm = true })
stepFrame(1 / 60)
local stFirst = craftPlugin:getState()
check("first craft deducts cost once (idempotent)", stFirst.inventory.wood_tally == 0 and stFirst.inventory.bell_tally == 1)
check("first craft equips guide_lantern_gun", stFirst.equippedWeapon == "guide_lantern_gun")
check("first craft plays ~1.0s handover animation", stFirst.handoverActive and approx(stFirst.handoverDuration, 1.0, 0.05))
-- 暂停冻结试握动画
local remBeforePause = stFirst.handoverRemaining
p.paused = true
for _ = 1, 20 do stepFrame(1 / 60) end
check("pause freezes craft handover timer", approx(craftPlugin:getState().handoverRemaining, remBeforePause, 0.0001))
p.paused = false
for _ = 1, 70 do stepFrame(1 / 60) end
check("first handover finishes cleanly", not craftPlugin:getState().handoverActive)

-- C4. 第二次制作：回声铳（0.45 秒短递交动作）
fe.contract:triggerMockBench(true, { inventory = { wood_tally = 1, bell_tally = 1 } })
stepFrame(1 / 60)
craftPlugin:injectInputForTest({ move = 1, confirm = true })
stepFrame(1 / 60)
stepFrame(1 / 60)
local stSecond = craftPlugin:getState()
check("second craft builds echo_gun & equips", stSecond.equippedWeapon == "echo_gun" and stSecond.inventory.wood_tally == 0 and stSecond.inventory.bell_tally == 0)
check("repeat craft uses short 0.45s handover", stSecond.handoverActive and approx(stSecond.handoverDuration, 0.45, 0.05))
for _ = 1, 35 do stepFrame(1 / 60) end

-- C5. 已制成武器自由切换装备
craftPlugin:injectInputForTest({ move = -1, confirm = true })
stepFrame(1 / 60)
stepFrame(1 / 60)
check("switch equipped crafted weapon", craftPlugin:getState().equippedWeapon == "guide_lantern_gun")

-- C6. 切房/读档重置本地锁并按快照恢复
local pNext = new(play.Play, rooms.CHECKPOINT_ROOM)
fe:bindPlay(pNext, 1280, 720)
stepFrame(1 / 60)
check("rebind resets bench active & preserves archive/inventory snapshot", not craftPlugin:getState().active and craftPlugin:getState().pendingRecipeId == "")

-- D. 退出排演彻底清内存并恢复正式数据源
fe.contract:exitRehearsal()
stepFrame(1 / 60)
check("exitRehearsal restores live data source", fe.contract:getDataSource() == "live" and not fe.contract:isRehearsal())

root:cleanup()
print("FE02 PASS " .. pass .. " / FAIL 0")
