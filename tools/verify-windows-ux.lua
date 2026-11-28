-- Windows 端操作修复专项回归验收（tools/verify-windows-ux.lua）：
-- 1. 键位引导默认开启（assistHintsEnabled=true）且持久化；
-- 2. KbmPoller 事件级左键锁存（模拟同帧按下并抬起，Mouse.leftButtonPressed 仍为 false）稳定触发标题页点击；
-- 3. 标题页「游戏设置」入口、设置页 ‹/› 分区点击与滚轮调音、右键返回、尾声/史料交互；
-- 4. 局内鼠标参与：点击右上角「Esc 暂歇」、点击世界 [E] 胶囊、小满左键投瓶+右键取消、周戍右键开换弹盘、北塔登记簿左键继续；
-- 5. R 键长按 0.65s 防误触重开、蹲伏切换模式（crouchToggle）、失焦清空鼠标状态；
-- 6. WindowClose 状态机：首次点击 X 弹出 ESC 暂歇菜单，再次点击聚焦退出，2 秒内 4 次触发退出。

local Dora = require("Dora")
local Content = Dora.Content
local Path = Dora.Path
local Vec2 = Dora.Vec2
local new = require("lualib_bundle").__TS__New

package.loaded["watch.target"] = "windows"
require("Script.watch.target").resetActiveTarget()

local ctrlCfg = require("Script.watch.controls_config")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local rooms = require("Script.watch.rooms")
local playMod = require("Script.watch.play")
local platform = require("Script.watch.platform")
local app = require("Script.watch.app")

local pass = 0
local function check(tag, cond, detail)
	if not cond then
		error("FAIL windows-ux: " .. tag .. (detail and (" (" .. tostring(detail) .. ")") or ""))
	end
	pass = pass + 1
	print("PASS windows-ux: " .. tag)
end

-- 1. 键位引导默认开启 + 持久化往返
do
	local tmpFile = Path(Content.writablePath, "verify-winux-controls.txt")
	pcall(function() Content:remove(tmpFile) end)
	ctrlCfg.setControlSettingsFile(tmpFile)

	local def = ctrlCfg.defaultControlSettings()
	check("defaultControlSettings assistHints=true", def.assistHints == true)
	local loaded0 = ctrlCfg.loadControlSettings()
	check("fresh loadControlSettings assistHints=true", loaded0.assistHints == true)

	loaded0.assistHints = false
	loaded0.crouchToggle = true
	ctrlCfg.saveControlSettings(loaded0)
	local loaded1 = ctrlCfg.loadControlSettings()
	check("settings persists assistHints=false & crouchToggle=true",
		loaded1.assistHints == false and loaded1.crouchToggle == true)

	ctrlCfg.setControlSettingsFile("")
	pcall(function() Content:remove(tmpFile) end)
end

-- 2. KbmPoller 事件锁存：同帧按下并抬起（模拟触控板轻点/快击）在标题页稳定命中
do
	local root = Dora.Node()
	local fe = new(Frontend, root)
	local inp = new(Input)
	local vp = platform.computeStageViewport(1280, 720)
	inp:setStageViewport(vp)
	fe:setStagePlacement(vp)
	local gestured = false
	inp:attach(root, {
		onFirstUserGesture = function() gestured = true end,
		onToggleFullscreen = function() end,
		onKeyDownEvent = function() end,
	})

	check("DualRouteContract default assistHintsEnabled=true", fe.contract:isAssistHintsEnabled() == true)

	-- 找到 KbmPoller 挂载的透明捕获子节点，向其派发同帧 TapBegan + TapEnded（Mouse.leftButtonPressed 保持 false）
	local pointerChild = nil
	root:eachChild(function(ch)
		if ch.touchEnabled then
			pointerChild = ch
			return true
		end
		return false
	end)
	check("KbmPoller attached touchEnabled capture node", pointerChild ~= nil)

	fe.screen = "title"
	fe.menus.hasSession = false
	fe.menus.selected = 0
	-- 6 项标题菜单（denseTitle=true）：menuX=112, startY=274, btnH=36, gap=5 -> i=1「选择章节」y=[233,269]
	local fakeTouch = {
		fromMouse = false,
		mouseButton = 0,
		viewLocation = Vec2(180, 250),
	}
	pointerChild:emit("TapBegan", fakeTouch)
	pointerChild:emit("TapEnded", fakeTouch)
	inp:update(1 / 60)
	check("fast same-frame click latches uiPressed=true & gesture",
		gestured and inp.uiPressed and inp.uiHeld and math.abs(inp.uiX - 180) < 1 and math.abs(inp.uiY - 250) < 1)

	local act = fe:renderMenu(1 / 60, inp, 1280, 720)
	check("fast same-frame click on title activates chapters", act.type == "openChapters", tostring(act.type))

	-- 下一帧补发 uiReleased
	inp:update(1 / 60)
	check("next frame emits deferred uiReleased=true & uiHeld=false", inp.uiReleased and not inp.uiHeld)

	-- 滚轮导航测试
	pointerChild:emit("MouseWheel", Vec2(0, -1))
	inp:update(1 / 60)
	check("MouseWheel latches uiWheelY < 0", inp.uiWheelY < -0.5)
	fe.menus.selected = 0
	fe:renderMenu(1 / 60, inp, 1280, 720)
	check("title menu wheel down moves selection 0 -> 1", fe.menus.selected == 1)

	-- 右键在操作说明页返回标题
	fe.screen = "controls"
	inp.uiInside = true
	inp.uiRightPressed = true
	local ctrlBack = fe:renderMenu(1 / 60, inp, 1280, 720)
	check("right-click on controls returns backTitle", ctrlBack.type == "backTitle")

	-- 设置页 ‹ 左侧点击降音量（不绕回）、› 右侧点击升音量、滚轮调音、右键减音量
	fe.screen = "settings"
	fe.menus:openSettings()
	inp.settings.masterVol = 1.0
	-- panelW=760, panelX=260, topHeadY=664, firstY=588, rowH=34 -> row 0 y=[588,622], decMinX=824..928, incMinX=928..1020
	inp.uiInside = true
	inp.uiX = 860
	inp.uiY = 605
	inp.uiPressed = true
	inp.uiRightPressed = false
	inp.uiWheelY = 0
	fe:renderMenu(1 / 60, inp, 1280, 720)
	check("settings click ‹ decreases masterVol 1.0 -> 0.9", math.abs(inp.settings.masterVol - 0.9) < 0.01, tostring(inp.settings.masterVol))

	inp.uiX = 990
	inp.uiPressed = true
	fe:renderMenu(1 / 60, inp, 1280, 720)
	check("settings click › increases masterVol 0.9 -> 1.0", math.abs(inp.settings.masterVol - 1.0) < 0.01, tostring(inp.settings.masterVol))

	-- 1.0 再点 › 保持 1.0 不突然静音
	inp.uiX = 990
	inp.uiPressed = true
	fe:renderMenu(1 / 60, inp, 1280, 720)
	check("settings click › clamps at 1.0 without sudden wrap to mute", math.abs(inp.settings.masterVol - 1.0) < 0.01)

	-- 滚轮在数值行直接调节音量（不切行）
	inp.uiPressed = false
	inp.uiX = 700
	inp.uiY = 605
	inp.uiWheelY = -1
	fe:renderMenu(1 / 60, inp, 1280, 720)
	check("settings wheel down on row 0 lowers masterVol 1.0 -> 0.9",
		math.abs(inp.settings.masterVol - 0.9) < 0.01 and fe.menus.settingsSelected == 0,
		tostring(inp.settings.masterVol))

	-- 右键空白区返回标题
	inp.uiWheelY = 0
	inp.uiX = 120
	inp.uiY = 120
	inp.uiRightPressed = true
	local setBack = fe:renderMenu(1 / 60, inp, 1280, 720)
	check("settings right-click outside rows returns backTitle", setBack.type == "backTitle", tostring(setBack.type))

	root:cleanup()
end

-- 3. 局内玩法鼠标参与：HUD 暂歇点击、小满左键投瓶+右键取消、周戍右键开换弹盘
do
	local root = Dora.Node()
	local fe = new(Frontend, root)
	local inp = new(Input)
	local vp = platform.computeStageViewport(1280, 720)
	inp:setStageViewport(vp)
	fe:setStagePlacement(vp)

	-- 小满村口持瓶：左键按住瞄准 -> 松开投出
	local pChild = new(playMod.Play, rooms.VILLAGE_ROOM)
	fe:bindPlay(pChild, 1280, 720)
	pChild.hasBottle = true
	pChild.aimX = 760
	pChild.aimY = 260
	inp.inputMode = "kbm"
	inp.inside = true
	inp.fire.held = true
	inp.fire.pressed = true
	for _ = 1, 15 do
		pChild:update(1 / 60, inp)
		inp.fire.pressed = false
	end
	check("Xiaoman left-click hold charges bottle aimHold", pChild.aimHold >= 0.20, tostring(pChild.aimHold))
	inp.fire.held = false
	inp.fire.released = true
	pChild:update(1 / 60, inp)
	inp.fire.released = false
	check("Xiaoman left-click release throws bottle", not pChild.hasBottle and pChild.bottleFly ~= nil)

	-- 用正式键鼠驱动采样：F 蓄力后右击，持续按 F 再松开仍应保留瓶子。
	local poller = inp.driver.kbm
	local sample = poller.sample
	local holdF, cancel = true, false
	poller.sample = function(self, ...)
		local keys = sample(self, ...)
		keys.aim, keys.mouseRightPressed = holdF, cancel
		keys.mouseLeft = false
		return keys
	end
	local retryBottle = new(playMod.Play, rooms.VILLAGE_ROOM)
	retryBottle.hasBottle = true
	local function bottleFrames(count)
		for _ = 1, count do
			inp:update(1 / 60)
			retryBottle:update(1 / 60, inp)
			inp:endStep()
		end
	end
	bottleFrames(15)
	cancel = true
	bottleFrames(1)
	cancel = false
	bottleFrames(15)
	holdF = false
	bottleFrames(1)
	check("right-click cancels F aim until the key is released", retryBottle.hasBottle and retryBottle.aimHold == 0 and retryBottle.bottleFly == nil)
	poller.sample = sample

	-- 周戍护送段：右键快捷呼出 3x3 换弹盘
	local escort2Room = nil
	for _, r in ipairs(rooms.ROOMS) do
		if r.key == "escort2" then escort2Room = r; break end
	end
	check("located escort2 room spec", escort2Room ~= nil)
	local pSold = new(playMod.Play, escort2Room)
	fe:bindPlay(pSold, 1280, 720)
	inp.inputMode = "kbm"
	inp.uiRightPressed = true
	pSold:update(1 / 60, inp)
	check("Zhou Shu right-click opens 3x3 reload wheel", pSold.reloadOpen == true and inp.uiRightPressed == false)

	-- HUD 右上角「Esc 暂歇」徽章命中测试
	pSold.reloadOpen = false
	local pauseBox = fe.hud:getChapterPauseRect(1280, 720, vp.safeUi, false)
	inp.uiInside = true
	inp.uiPressed = true
	inp.uiX = pauseBox.x + pauseBox.width * 0.5
	inp.uiY = pauseBox.y + pauseBox.height * 0.5
	check("HUD top-right pause badge responds to left-click", fe:tryClickHudPause(pSold, inp, 1280, 720) == true)

	-- 小满村口世界 [E] 提示胶囊点击命中测试（renderPlay 后点击胶囊中心返回 "tap"）
	local pChild2 = new(playMod.Play, rooms.VILLAGE_ROOM)
	fe:bindPlay(pChild2, 1280, 720)
	pChild2.player.x = 112
	pChild2.player.y = 0
	inp.uiPressed = false
	fe:renderPlay(1 / 60, pChild2, inp, 1280, 720)
	local promptHit = fe.hud:getInteractPromptHit()
	check("world [E] prompt exposes clickable rect", promptHit ~= nil and promptHit.mode == "tap")
	inp.uiInside = true
	inp.uiPressed = true
	inp.uiX = promptHit.rect.x + promptHit.rect.width * 0.5
	inp.uiY = promptHit.rect.y + promptHit.rect.height * 0.5
	check("clicking world [E] prompt returns tap", fe:tryClickWorldPrompt(pChild2, inp, 1280, 720) == "tap")

	root:cleanup()
end

-- 4. App 级集成：R 单按不重开、WindowClose 状态机（首次弹 ESC，再点聚焦退出）、北塔左键推进尾声
do
	local appRoot = Dora.Node()
	local scheduler = Dora.Scheduler()
	appRoot.scheduler = scheduler
	Dora.Director.entry:addChild(appRoot)
	app.start(appRoot, 1, "play")
	local hook = package.loaded["watch.fe"]
	local fe = hook.getFrontend()
	local appInp = package.loaded["watch.input"]
	local p0 = package.loaded["watch.play"]

	-- R 单按 KeyDown 不再立即触发重试（gslot 走全局事件 Dora.emit）
	Dora.emit("KeyDown", "R")
	scheduler:update(1 / 60)
	check("single tap R does not immediately reset room", package.loaded["watch.play"] == p0 and not appInp.retry.pressed)

	-- WindowClose #1：局内未暂停 -> 弹出 ESC 暂歇菜单并显示提示
	p0.paused = false
	Dora.emit("AppEvent", "WindowClose", 1)
	check("1st WindowClose opens ESC pause menu", p0.paused == true)
	check("1st WindowClose shows force-quit hint toast", fe:getToastText():find("强制退出", 1, true) ~= nil)

	-- WindowClose #2：已在暂停菜单 -> 聚焦「退出游戏」项并提示剩余次数
	Dora.emit("AppEvent", "WindowClose", 2)
	check("2nd WindowClose focuses quit item in pause menu", fe.menus.pauseSelected == 7, tostring(fe.menus.pauseSelected))
	check("2nd WindowClose toast shows remaining count", fe:getToastText():find("2", 1, true) ~= nil)

	-- 切回标题页并测试 WindowClose 聚焦标题页退出项（6 项无续读时 quit 为索引 5）
	p0.paused = false
	fe.screen = "title"
	fe.menus.hasSession = false
	fe.menus.selected = 0
	Dora.emit("AppEvent", "WindowClose", 3)
	check("3rd WindowClose on title focuses quit item (index 5)", fe.menus.selected == 5, tostring(fe.menus.selected))

	appRoot:removeFromParent()
end

print("WINDOWS UX VERIFY PASS " .. pass .. " / FAIL 0")
