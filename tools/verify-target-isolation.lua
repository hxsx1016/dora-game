-- 四端目标严格输入隔离与运行时性能基线验收脚本（Dora SSR 无头真跑）：
-- 覆盖：
-- 1. windows  ：纯键鼠（0 触控、0 手柄、0 竖屏、5 行声音设置、单页键鼠说明）；
-- 2. android  ：纯触屏（0 键鼠、0 手柄、横竖屏自适应、36-Label 轻量池、9 行触控+声音设置、单页触屏说明）；
-- 3. handheld ：安卓掌机触屏+手柄（0 键鼠、0 竖屏、36-Label 轻量池、自动/手柄/触屏循环、双页说明、手柄态隐藏零空转）；
-- 4. web      ：全包含三模（键鼠+触屏+手柄+竖屏、不可退出、可全屏、需音频解锁、3 页说明、12 行设置）；
-- 5. 600 帧输入循环（syncFrame + update + renderOverlay）微基准耗时采样。

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

local new = require("lualib_bundle").__TS__New
local targetMod = require("Script.watch.target")
local platform = require("Script.watch.platform")
local controlsCfg = require("Script.watch.controls_config")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local rooms = require("Script.watch.rooms")
local playMod = require("Script.watch.play")

local pass, fail = 0, 0
local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS iso: %-52s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL iso: %-52s %s", tag, detail or ""))
	end
end

local function switchTarget(id)
	package.loaded["watch.target"] = id
	targetMod.resetActiveTarget()
	return targetMod.getActiveTarget()
end

local function benchTarget(label, input, fe, p, vp, frames)
	local t0 = Dora.App.runningTime
	for _ = 1, frames do
		input:syncFrame({
			viewport = vp,
			mode = 1,
			screen = "play",
			play = p,
			run = nil,
			cam = fe.cam,
			input = input,
			assistHintsEnabled = false,
			isMuted = false,
			isFullscreen = false,
			storyTalentBoxes = {},
			dt = 1 / 60,
		})
		input:update()
		input:renderOverlay()
		input:consumeEdges()
	end
	local ms = (Dora.App.runningTime - t0) * 1000
	print(string.format("BENCH %-26s %d frames = %.2f ms (%.1f us/frame)", label, frames, ms, (ms * 1000) / frames))
	return ms
end

-- ============================================================================
-- 1. Windows 纯键鼠目标隔离验证
-- ============================================================================
do
	local t = switchTarget("windows")
	local root = Dora.Node()
	local fe = new(Frontend, root)
	local inp = new(Input)
	inp:attach(root, {})

	check("windows: id and capability flags",
		t.id == "windows" and t.supportsKbm and not t.supportsTouch and not t.supportsGamepad and not t.supportsPortrait)
	check("windows: zero touch/gamepad driver instances",
		inp:getTouchRouter() == nil and inp:getGamepadRouter() == nil and inp:getTouchControls() == nil)
	check("windows: default mode is kbm", inp:isKbmMode())

	inp:setInputMode("touch")
	inp:setInputMode("gamepad")
	check("windows: ignores touch/gamepad mode switch", inp:isKbmMode())
	inp:setModePref("touch")
	check("windows: cycleModePref locked to kbm", inp:cycleModePref(1) == "kbm")

	local vpNarrow = platform.computeStageViewport(390, 844)
	check("windows: portrait viewport disabled even on 390x844",
		not vpNarrow.isPortrait and vpNarrow.deckH == 0 and not inp:shouldShowTouchControls())

	check("windows: settings has 8 rows (4 volumes + display + assist + crouchToggle + back)", #t:settingsRows() == 8 and t:settingsHeaderTitle() == "游戏设置")
	check("windows: controls guide has single kbm page", #t.controlsGuideTabs == 1 and t.controlsGuideTabs[1].mode == "kbm")
	check("windows: adaptHintSentence is zero-allocation passthrough",
		t:adaptHintSentence("按 [E] 交互，左键发铳", "kbm", "xbox") == "按 [E] 交互，左键发铳")

	-- 渲染标题、单页操作说明、战斗、暂停、声音设置零报错
	local vp = platform.computeStageViewport(1280, 720)
	inp:setStageViewport(vp)
	fe:setStagePlacement(vp)
	fe.screen = "title"
	fe:renderMenu(1 / 60, inp, 1280, 720)
	fe.screen = "controls"
	fe:renderMenu(1 / 60, inp, 1280, 720)
	local p = new(playMod.Play, rooms.STREET_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.screen = "play"
	fe:renderPlay(1 / 60, p, inp, 1280, 720)
	p.paused = true
	fe.menus:openPause()
	fe.menus.pauseSelected = 8
	fe.menus:onKeyEvent("Return")
	fe:renderPlay(1 / 60, p, inp, 1280, 720)
	check("windows: pause index 8 opens 声音设置 sub-panel", fe.menus:isShowingPauseSettings())
	p.paused = false

	benchTarget("windows (kbm-only)", inp, fe, p, vp, 600)
	root:cleanup()
end

-- ============================================================================
-- 2. Android 手机纯触屏目标隔离验证
-- ============================================================================
do
	local t = switchTarget("android")
	local root = Dora.Node()
	local fe = new(Frontend, root)
	local inp = new(Input)
	inp:attach(root, {})

	check("android: id and capability flags",
		t.id == "android" and not t.supportsKbm and t.supportsTouch and not t.supportsGamepad and t.supportsPortrait)
	check("android: touch attached, gamepad nil, 36-Label pool",
		inp:getTouchRouter() ~= nil and inp:getGamepadRouter() == nil
		and inp:getTouchControls() ~= nil and inp:getTouchControls():getAllocatedLabelCount() == 36)
	check("android: default mode is touch", inp:isTouchMode())

	inp:setInputMode("kbm")
	inp:setInputMode("gamepad")
	inp:markKeyboardActivity()
	check("android: ignores kbm/gamepad switch and keyboard activity", inp:isTouchMode())
	check("android: shouldShowTouchControls always true", inp:shouldShowTouchControls())

	local vpPort = platform.computeStageViewport(390, 844)
	check("android: enables portrait 16:9 deck on 390x844",
		vpPort.isPortrait and vpPort.stageW == 390 and vpPort.deckH >= 280)

	check("android: settings has 9 rows (touch + 4 volumes + back)", #t:settingsRows() == 9 and t:settingsHeaderTitle() == "触控与声音")
	check("android: controls guide has single touch page", #t.controlsGuideTabs == 1 and t.controlsGuideTabs[1].mode == "touch")

	local vpLand = platform.computeStageViewport(1280, 720)
	inp:setStageViewport(vpLand)
	fe:setStagePlacement(vpLand)
	local p = new(playMod.Play, rooms.STREET_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.screen = "controls"
	fe:renderMenu(1 / 60, inp, 1280, 720)
	fe.screen = "play"
	fe:renderPlay(1 / 60, p, inp, 1280, 720)
	benchTarget("android (touch-only)", inp, fe, p, vpLand, 600)
	root:cleanup()
end

-- ============================================================================
-- 3. Android 掌机（KT-R1/R2）触屏 + 手柄横屏锁定隔离验证
-- ============================================================================
do
	local t = switchTarget("handheld")
	local root = Dora.Node()
	local fe = new(Frontend, root)
	local prefFile = Path(Content.writablePath, "verify-handheld-legacy-mode.txt")
	assert(Content:save(prefFile, "modePref=kbm\n"))
	controlsCfg.setControlSettingsFile(prefFile)
	local inp = new(Input)
	controlsCfg.setControlSettingsFile("")
	Content:remove(prefFile)
	check("handheld: saved keyboard preference falls back to auto", inp.settings.modePref == "auto")
	inp:attach(root, {})

	check("handheld: id and capability flags",
		t.id == "handheld" and not t.supportsKbm and t.supportsTouch and t.supportsGamepad and not t.supportsPortrait)
	check("handheld: touch+gamepad attached, 36-Label pool",
		inp:getTouchRouter() ~= nil and inp:getGamepadRouter() ~= nil
		and inp:getTouchControls() ~= nil and inp:getTouchControls():getAllocatedLabelCount() == 36)
	check("handheld: default mode is gamepad", inp:isGamepadMode())

	inp:setInputMode("kbm")
	inp:markKeyboardActivity()
	check("handheld: ignores kbm mode switch", inp:isGamepadMode())
	check("handheld: modePrefOrder excludes kbm", #t.modePrefOrder == 3 and t.modePrefOrder[1] == "auto" and t.modePrefOrder[2] == "gamepad" and t.modePrefOrder[3] == "touch")
	check("handheld: controls guide has 2 tabs (gamepad, touch)", #t.controlsGuideTabs == 2 and t.controlsGuideTabs[1].mode == "gamepad" and t.controlsGuideTabs[2].mode == "touch")
	check("handheld: settings has 12 rows", #t:settingsRows() == 12)

	local vpNarrow = platform.computeStageViewport(390, 844)
	check("handheld: portrait deck physically disabled (locked landscape)",
		not vpNarrow.isPortrait and vpNarrow.deckH == 0)

	local vp32 = platform.computeStageViewport(1620, 1080)
	inp:setStageViewport(vp32)
	fe:setStagePlacement(vp32)
	local p = new(playMod.Play, rooms.STREET_ROOM)
	fe:bindPlay(p, 1620, 1080)
	local aim = require("Script.watch.input.aim_assist")
	local actor = p.player
	actor.depth = 32
	local mx, my = actor.x + actor.facing * 8, actor.y + actor.h * 0.72
	local gray = playMod.worldToScreen(mx, my + actor.depth * require("Script.watch.depth").DEPTH_Y_SCALE, p.cam, p.view)
	local fallbackMuzzle, storyMuzzle = aim.projectMuzzle(p, nil), aim.projectMuzzle(p, fe.cam)
	check("muzzle without a sprite camera follows the play viewport", fallbackMuzzle.x == gray.x and fallbackMuzzle.y == gray.y)
	check("story muzzle follows sprite camera", storyMuzzle.x == fe.cam:sx(mx) and storyMuzzle.y == fe.cam:sy(my, actor.depth))
	fe.screen = "play"
	inp:setModePref("auto")
	inp:setInputMode("gamepad")
	check("handheld: gamepad mode hides touch overlay", not inp:shouldShowTouchControls())
	benchTarget("handheld (gamepad hidden)", inp, fe, p, vp32, 600)

	inp:setInputMode("touch")
	check("handheld: touch mode shows touch overlay", inp:shouldShowTouchControls())
	benchTarget("handheld (touch visible)", inp, fe, p, vp32, 600)
	root:cleanup()
end

-- ============================================================================
-- 4. Web 全包含目标验证
-- ============================================================================
do
	local t = switchTarget("web")
	local root = Dora.Node()
	local fe = new(Frontend, root)
	local inp = new(Input)
	inp:attach(root, {})
	local caps = platform.getPlatformCaps()

	check("web: id and full 3-mode + portrait capabilities",
		t.id == "web" and t.supportsKbm and t.supportsTouch and t.supportsGamepad and t.supportsPortrait)
	check("web: caps disallow quit, allow fullscreen, need audio unlock",
		caps.isWeb and not caps.canQuit and caps.canToggleFullscreen and caps.needsAudioUnlock)
	check("web: 36-Label TouchControls pool", inp:getTouchControls():getAllocatedLabelCount() == 36)
	check("web: 3 controls guide tabs and 12 settings rows",
		#t.controlsGuideTabs == 3 and #t:settingsRows() == 12)
	check("web: portrait deck active on 390x844", platform.computeStageViewport(390, 844).isPortrait)

	local vp = platform.computeStageViewport(1280, 720)
	inp:setStageViewport(vp)
	fe:setStagePlacement(vp)
	local p = new(playMod.Play, rooms.STREET_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.screen = "play"
	inp:setModePref("auto")
	inp:setInputMode("kbm")
	benchTarget("web (kbm hidden overlay)", inp, fe, p, vp, 600)
	root:cleanup()
end

controlsCfg.saveControlSettings(controlsCfg.defaultControlSettings())
package.loaded["watch.target"] = nil
targetMod.resetActiveTarget()
print(string.format("TARGET ISOLATION VERIFY PASS %d / FAIL %d", pass, fail))
assert(fail == 0, "target isolation verification failed")
