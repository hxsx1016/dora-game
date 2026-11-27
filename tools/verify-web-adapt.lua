-- Web 全包含端（target = "web"）横竖屏布局、三模偏好切换与假鼠标保护专项回归验收：
-- 1. 横竖屏视口算法（横屏全屏 / 竖屏上半 16:9 画面 + 下半宋明水墨掌机区）与坐标逆变换；
-- 2. 键鼠/触屏/手柄三模偏好循环（auto -> kbm -> touch -> gamepad -> auto）与显隐判定；
-- 3. SDL 合成假鼠标 250ms 保护窗开启与冷却释放；
-- 4. 竖屏掌机菜单、男主线（2.5D 摇杆、快点开火锁存、贴掩体切换、3x3 换弹盘触屏划屏与「重画」钮）、
--    女主线（慢走/蹲伏切换、板车单点锁柄、投瓶拖瞄）；
-- 5. 音频全局静音切换与首手势解锁幂等性；
-- 6. 暂停菜单保持桌面 0..7 既有索引，第 8 项打开原地「操控设置」二级页并支持全三模切换。

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

package.loaded["watch.target"] = "web"
local targetMod = require("Script.watch.target")
targetMod.resetActiveTarget()

local new = require("lualib_bundle").__TS__New
local platform = require("Script.watch.platform")
local controlsCfg = require("Script.watch.controls_config")
local Input = require("Script.watch.input").Input
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local Frontend = require("Script.watch.fe.frontend").WatchFrontend

local pass = 0
local function check(tag, cond)
	assert(cond, "FAIL web-adapt: " .. tag)
	pass = pass + 1
	print("PASS web-adapt: " .. tag)
end

local function hasId(list, target)
	for _, v in ipairs(list) do
		if v == target then
			return true
		end
	end
	return false
end

local function findBtn(ctx, id)
	for i = 1, #ctx.buttons do
		if ctx.buttons[i].id == id then
			return ctx.buttons[i]
		end
	end
	return nil
end

-- 1. 平台与横竖屏视口几何 + viewToStage
local vpLand = platform.computeStageViewport(1280, 720)
check("landscape viewport fills screen", not vpLand.isPortrait and vpLand.stageX == 0 and vpLand.stageY == 0 and vpLand.stageW == 1280 and vpLand.stageH == 720 and vpLand.deckH == 0)

local vpPort = platform.computeStageViewport(720, 1280)
check("portrait viewport enables handheld deck", vpPort.isPortrait and vpPort.deckH >= 168 and vpPort.topBarH >= 38)
check("portrait stage keeps 16:9 full width", vpPort.stageW == 720 and math.abs(vpPort.stageH - 405) <= 2)
check("portrait stage fits cleanly between top bar and deck", vpPort.stageY == vpPort.deckH and vpPort.stageY + vpPort.stageH + vpPort.topBarH <= vpPort.fullH)

local mapped = platform.viewToStage(360, vpPort.stageY + 200, vpPort)
check("viewToStage maps portrait stage center accurately", mapped.inside and math.abs(mapped.x - 360) < 0.5 and math.abs(mapped.y - 200) < 0.5)
local mappedDeck = platform.viewToStage(360, 100, vpPort)
check("viewToStage marks portrait lower deck outside stage", not mappedDeck.inside)

local vpPhone = platform.computeStageViewport(390, 844)
check("mobile portrait 390x844 preserves 16:9", vpPhone.isPortrait and vpPhone.stageW == 390 and math.abs(vpPhone.stageH - 219) <= 2 and vpPhone.deckH >= 280)

-- 2. Web 三模偏好循环与虚拟触控显隐逻辑
local root = Dora.Node()
local fe = new(Frontend, root)
local inp = new(Input)
inp:attach(root, {})
local router = inp:getTouchRouter()
local ctrl = inp:getTouchControls()
check("web target attaches all 3 drivers with 36-Label TouchControls",
	router ~= nil and inp:getGamepadRouter() ~= nil and ctrl ~= nil and ctrl:getAllocatedLabelCount() == 36)

inp:setStageViewport(vpLand)
inp:setModePref("auto")
inp:markKeyboardActivity()
check("kbm hides touch controls on landscape auto", inp.inputMode == "kbm" and not inp:shouldShowTouchControls())
inp:setInputMode("touch")
check("touch shows controls immediately on auto", inp.inputMode == "touch" and inp:shouldShowTouchControls())
check("modePref cycles auto -> kbm -> touch -> gamepad -> auto",
	inp:cycleModePref(1) == "kbm"
	and inp:cycleModePref(1) == "touch"
	and inp:cycleModePref(1) == "gamepad"
	and inp:cycleModePref(1) == "auto")
inp:setModePref("kbm")
check("locked kbm hides touch on landscape", not inp:shouldShowTouchControls())
inp:setStageViewport(vpPort)
check("portrait always shows handheld deck even when kbm active", inp:shouldShowTouchControls())
inp:setModePref("auto")

local function sync(vp, screen, p, modeNum)
	return ctrl:syncContext({
		viewport = vp,
		mode = modeNum or 1,
		screen = screen,
		play = p,
		run = nil,
		cam = (modeNum or 1) == 1 and fe.cam or nil,
		router = router,
		overlayActive = inp:shouldShowTouchControls(),
		allowAutoGameplayTouch = inp.settings.modePref == "auto" or inp.settings.modePref == "touch",
		allowMouseOnOverlay = vp.isPortrait or inp.settings.modePref == "touch",
		showWebTopPills = true,
		canToggleFullscreen = true,
		assistHintsEnabled = false,
		isMuted = fe.audio:isAllMuted(),
		isFullscreen = false,
		storyTalentBoxes = {},
		dt = 1 / 60,
	})
end

-- 3a. 竖屏标题菜单：掌机方向键 + 顶部静音栏 + 渲染不报错
inp:setStageViewport(vpPort)
fe:setStagePlacement(vpPort)
local ctxTitle = sync(vpPort, "title", nil, 1)
ctrl:render(router)
local titleSummary = ctrl:getLayoutSummary(router)
check("portrait menu exposes handheld D-pad, confirm, back & mute",
	titleSummary.isPortrait
	and hasId(titleSummary.buttonIds, "nav_up")
	and hasId(titleSummary.buttonIds, "nav_down")
	and hasId(titleSummary.buttonIds, "nav_confirm")
	and hasId(titleSummary.buttonIds, "nav_back")
	and hasId(titleSummary.buttonIds, "mute"))

-- 竖屏掌机「下」钮可驱动 navDown
local navDownBtn = findBtn(ctxTitle, "nav_down")
router:injectTouch("began", 1, navDownBtn.x, navDownBtn.y, false)
router:injectTouch("ended", 1, navDownBtn.x, navDownBtn.y, false)
inp:update()
check("portrait handheld D-pad down emits navDown", inp.navDown)
inp:consumeEdges()

-- 3b. 横屏男主线（长街）：摇杆 2.5D + 250ms 假鼠标隔离 + 快点开火锁存 + 3x3 换弹盘划屏与重画钮
inp:setStageViewport(vpLand)
fe:setStagePlacement(vpLand)
inp:setInputMode("touch")
local soldierPlay = new(play.Play, rooms.STREET_ROOM)
fe:bindPlay(soldierPlay, vpLand.stageW, vpLand.stageH)
fe.screen = "play"
sync(vpLand, "play", soldierPlay, 1)
local sSummary = ctrl:getLayoutSummary(router)
check("soldier touch layout has fire/jump/interact/cover (and no dead flare)",
	hasId(sSummary.buttonIds, "fire")
	and hasId(sSummary.buttonIds, "jump")
	and hasId(sSummary.buttonIds, "interact")
	and hasId(sSummary.buttonIds, "cover")
	and not hasId(sSummary.buttonIds, "flare"))

router:injectTouch("began", 11, 120, 120, false)
router:injectTouch("moved", 11, 182, 182, false)
inp:update()
check("soldier touch joystick drives 2.5D movement", inp.moveX == 1 and inp.moveY == -1)
check("active finger suppresses synthetic mouse on web", router:isSuppressingSyntheticMouse())
router:injectTouch("ended", 11, 182, 182, false)
inp:update()
inp:consumeEdges()

for _ = 1, 20 do
	sync(vpLand, "play", soldierPlay, 1)
	inp:update()
end
check("synthetic mouse suppression clears after 0.25s cooldown on web", not router:isSuppressingSyntheticMouse())

-- 单帧快点舞台（同帧 began + ended）不丢开火边沿
router:injectTouch("began", 12, 640, 320, false)
router:injectTouch("ended", 12, 640, 320, false)
inp:update()
check("fast single-frame stage tap triggers fire", inp.fire.pressed and inp.mx > 500)
inp:consumeEdges()
inp:update()
check("latched tap releases cleanly on next frame", not inp.fire.held)

-- 3x3 换弹盘：触屏拖线完整连出回声路径 0->1->4->5->8 + 顶部「重画」钮清线
local escortPlay = new(play.Play, rooms.ESCORT1_ROOM)
fe:bindPlay(escortPlay, vpLand.stageW, vpLand.stageH)
fe.screen = "play"
fe.contract:submitIntent(escortPlay, { kind = "reloadOpen" })
sync(vpLand, "play", escortPlay, 1)
fe:renderPlay(1 / 60, escortPlay, inp, 1280, 720)
local rw = fe:getPlugin("fe-02-reload-wheel")
check("escort reload wheel opens for touch test", rw:getState().active)

local n0 = rw:getNodeUiPos(0)
local n1 = rw:getNodeUiPos(1)
local n4 = rw:getNodeUiPos(4)
local n5 = rw:getNodeUiPos(5)
local n8 = rw:getNodeUiPos(8)
router:injectTouch("began", 21, n0.x, n0.y, false)
inp:update()
fe:renderPlay(1 / 60, escortPlay, inp, 1280, 720)
router:injectTouch("moved", 21, n1.x, n1.y, false)
inp:update()
fe:renderPlay(1 / 60, escortPlay, inp, 1280, 720)
check("touch drag connects 3x3 reload nodes", #rw:getState().path >= 2)
for _, pt in ipairs({ n4, n5, n8 }) do
	router:injectTouch("moved", 21, pt.x, pt.y, false)
	inp:update()
	fe:renderPlay(1 / 60, escortPlay, inp, 1280, 720)
end
router:injectTouch("ended", 21, n8.x, n8.y, false)
inp:update()
fe:renderPlay(1 / 60, escortPlay, inp, 1280, 720)
check("touch drag solves full 3x3 echo pattern", not rw:getState().active and rw:getState().nextEffect == "echo")

-- 重开盘、步进到 [0,1] 后点击顶部「重画」钮清空回 [0]
fe.contract:submitIntent(escortPlay, { kind = "reloadOpen" })
sync(vpLand, "play", escortPlay, 1)
fe:renderPlay(1 / 60, escortPlay, inp, 1280, 720)
fe.contract:submitIntent(escortPlay, { kind = "reloadTapNode", node = 1 })
fe:renderPlay(1 / 60, escortPlay, inp, 1280, 720)
local st2 = rw:getState()
check("reload path stepped to [0,1] before redraw", #st2.path == 2)
local rx = st2.panelCenterX + 92
local ry = st2.panelCenterY + 158 - 32
router:injectTouch("began", 22, rx, ry, false)
inp:update()
fe:renderPlay(1 / 60, escortPlay, inp, 1280, 720)
router:injectTouch("ended", 22, rx, ry, false)
inp:update()
fe:renderPlay(1 / 60, escortPlay, inp, 1280, 720)
check("touch redraw button clears reload path without right-click", #rw:getState().path == 1)
router:releaseAll(false)

-- 3c. 女主线竖屏掌机台：蹲伏/轻步/跳跃/交互/投瓶全部就位
inp:setStageViewport(vpPort)
fe:setStagePlacement(vpPort)
local childPlay = new(play.Play, rooms.VILLAGE_ROOM)
childPlay.hasBottle = true
fe:bindPlay(childPlay, vpPort.stageW, vpPort.stageH)
sync(vpPort, "play", childPlay, 1)
ctrl:render(router)
local cSummary = ctrl:getLayoutSummary(router)
check("child portrait deck exposes crouch/cover(slow)/jump/interact/bottle",
	hasId(cSummary.buttonIds, "crouch")
	and hasId(cSummary.buttonIds, "cover")
	and hasId(cSummary.buttonIds, "jump")
	and hasId(cSummary.buttonIds, "interact")
	and hasId(cSummary.buttonIds, "bottle"))

-- 4. 音频全局静音与首手势解锁幂等
check("audio starts unmuted", not fe.audio:isAllMuted())
check("toggleAllMuted mutes all tracks", fe.audio:toggleAllMuted() == true and fe.audio:isAllMuted())
check("toggleAllMuted restores all tracks", fe.audio:toggleAllMuted() == false and not fe.audio:isAllMuted())
fe.audio:unlockAndResyncAfterGesture()
check("unlockAndResyncAfterGesture runs cleanly", true)

-- 5. Web 端暂停菜单过滤「退出游戏」（共 8 项 0..7），末项索引 7 打开「操控设置」原地二级页
inp:setStageViewport(vpLand)
fe:setStagePlacement(vpLand)
inp:markKeyboardActivity()
inp.inside = false
inp.uiInside = false
soldierPlay.paused = true
fe.screen = "play"
fe.menus:openPause()
for _ = 1, 7 do
	fe.menus:onKeyEvent("Down")
	fe:renderPlay(1 / 60, soldierPlay, inp, 1280, 720)
end
check("web pause menu selects settings at index 7 (quit omitted)", fe.menus.pauseSelected == 7)
fe.menus:onKeyEvent("Return")
fe:renderPlay(1 / 60, soldierPlay, inp, 1280, 720)
check("web pause index 7 opens in-place 操控设置 sub-panel", fe.menus:isShowingPauseSettings())
-- 第 0 行「操作模式」按右切为 kbm -> 再切 touch
fe.menus:onKeyEvent("Right")
fe:renderPlay(1 / 60, soldierPlay, inp, 1280, 720)
check("settings row 0 switches modePref to kbm", inp.settings.modePref == "kbm" and inp.inputMode == "kbm")
fe.menus:onKeyEvent("Right")
fe:renderPlay(1 / 60, soldierPlay, inp, 1280, 720)
check("settings row 0 switches modePref to touch on web too", inp.settings.modePref == "touch" and inp.inputMode == "touch" and inp:shouldShowTouchControls())
-- Esc 返回暂歇主菜单
fe.menus:onKeyEvent("Escape")
fe:renderPlay(1 / 60, soldierPlay, inp, 1280, 720)
check("Esc exits 操控设置 sub-panel cleanly", not fe.menus:isShowingPauseSettings())

-- 6. 校验触屏操作说明页面渲染无异常
fe.screen = "controls"
fe:renderMenu(1 / 60, inp, 1280, 720)
check("touch controls guide page renders cleanly", true)

controlsCfg.saveControlSettings(controlsCfg.defaultControlSettings())
package.loaded["watch.target"] = nil
targetMod.resetActiveTarget()
root:cleanup()
print("WEB ADAPT VERIFY PASS " .. pass .. " / FAIL 0")
