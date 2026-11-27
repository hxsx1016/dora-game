-- 品牌资产与开机 Splash 三模自动化验收：
-- 1. 全部 6 份运行时品牌 PNG 存在且可通过 AssetSlotHost 加载；
-- 2. WatchFrontend 默认构造仍落于 "title"（确保既有集成验收零回归）；
-- 3. 开机 Splash 按阶段播放并在 4.65s 后自然完成，且 0.25s 后键鼠 / 手柄 / 触屏均可无串键跳过；
-- 4. 多端统一图标母源文件（Windows ICO / Android 512 / Web 套件）齐全。

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
local Input = require("Script.watch.input").Input
local TouchRouter = require("Script.watch.touch").TouchRouter
local GamepadRouter = require("Script.watch.gamepad").GamepadRouter
local TouchControls = require("Script.watch.fe.ui.touch_controls").TouchControls
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local platform = require("Script.watch.platform")
local assets = require("Script.watch.fe.assets")

local pass, fail = 0, 0
local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS brand: %-44s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL brand: %-44s %s", tag, detail or ""))
	end
end

-- 1. 运行时品牌文件与多端图标母源文件存在性
for _, path in ipairs({
	"assets/art/brand/game_logo_h.png",
	"assets/art/brand/game_logo_v.png",
	"assets/art/brand/team_logo_dark.png",
	"assets/art/brand/team_logo_light.png",
	"assets/art/brand/team_badge.png",
	"assets/art/brand/app_icon.png",
	"art-source/brand/icons/WestwardWatch.ico",
	"art-source/brand/icons/android/ic_launcher_512.png",
	"art-source/brand/icons/web/favicon.ico",
	"art-source/brand/icons/web/favicon-32x32.png",
	"art-source/brand/icons/web/apple-touch-icon.png",
	"art-source/brand/icons/web/icon-192.png",
	"art-source/brand/icons/web/icon-512.png",
}) do
	check("asset exists: " .. path, Content:exist(path))
end

local root = Dora.Node()
local fe = new(Frontend, root)
local input = new(Input)
local router = new(TouchRouter, input.settings)
router:attach(root)
input:bindTouch(router)
local gp = new(GamepadRouter, input.settings)
gp:attach(root)
input:bindGamepad(gp)
local ctrl = new(TouchControls, root)
local vp = platform.computeStageViewport(1280, 720)
input:setStageViewport(vp)

-- 2. 默认兼容：直接构造 WatchFrontend 停在 title，且四个品牌槽位可加载
check("default frontend starts on title", fe.screen == "title")
local host = new(assets.AssetSlotHost, root, 0)
for _, slot in ipairs({"brand_game_logo_h", "brand_game_logo_v", "brand_team_logo", "brand_team_badge"}) do
	check("slot loads: " .. slot, host:tryPlace(slot, "test_" .. slot, 0, 0, 200, 120))
end

-- 3. Splash 完整自然播放流程（0 -> 4.65s）
fe.screen = "splash"
fe.menus:resetSplash()
local act = fe:renderMenu(0.05, input, 1280, 720)
check("splash stays active at 0.05s", act.type == "none")

-- 0.25s 内的误触不会提前跳过
fe.menus:onKeyEvent("Space")
act = fe:renderMenu(0.05, input, 1280, 720)
check("splash ignores early key before 0.25s", act.type == "none")

local doneAt = nil
for i = 1, 80 do
	act = fe:renderMenu(0.08, input, 1280, 720)
	if act.type == "splashDone" then
		doneAt = i
		break
	end
end
check("splash auto-completes with splashDone", doneAt ~= nil and doneAt > 50, "step=" .. tostring(doneAt))

-- 4. 0.25s 后键盘任意键立即跳过
fe.menus:resetSplash()
for _ = 1, 5 do
	fe:renderMenu(0.08, input, 1280, 720)
end
fe.menus:onKeyEvent("E")
act = fe:renderMenu(0.05, input, 1280, 720)
check("splash skips on any key after 0.25s", act.type == "splashDone")

-- 5. 0.25s 后鼠标点击立即跳过
fe.menus:resetSplash()
for _ = 1, 5 do
	fe:renderMenu(0.08, input, 1280, 720)
end
input.inside = true
input.fire.pressed = true
act = fe:renderMenu(0.05, input, 1280, 720)
input.fire.pressed = false
check("splash skips on mouse click after 0.25s", act.type == "splashDone")

-- 6. 0.25s 后手柄任意键立即跳过
fe.menus:resetSplash()
gp:setFrameContext({
	stageW = 1280, stageH = 720, uiScale = 1, modal = true, gameplayActive = false,
	reloadActive = false, craftActive = false, talentOfferCount = 0, childMode = false,
	allowDepth = false, canShoot = false, canBottleAim = false, playerRolling = false,
	inLowArch = false, inTowerEnd = false, playerFacing = 1, playerScreenX = 640,
	playerScreenY = 360, enemyTargets = {},
}, 0.08)
for _ = 1, 5 do
	gp:setSimulatedState({})
	input:update()
	fe:renderMenu(0.08, input, 1280, 720)
end
gp:setSimulatedState({ x = true })
input:update()
act = fe:renderMenu(0.05, input, 1280, 720)
gp:setSimulatedState({})
input:update()
check("splash skips on gamepad button after 0.25s", act.type == "splashDone")

-- 7. 0.25s 后触屏轻触立即跳过
fe.menus:resetSplash()
ctrl:syncContext({
	viewport = vp, mode = 1, screen = "splash", play = nil, run = nil, cam = fe.cam,
	input = input, router = router, assistHintsEnabled = false, isMuted = false,
	isFullscreen = false, storyTalentBoxes = {}, dt = 0.08,
})
for _ = 1, 5 do
	input:update()
	fe:renderMenu(0.08, input, 1280, 720)
end
router:injectTouch("began", 1, 640, 360, false)
input:update()
act = fe:renderMenu(0.05, input, 1280, 720)
router:injectTouch("ended", 1, 640, 360, false)
input:update()
check("splash skips on touch tap after 0.25s", act.type == "splashDone")

-- 8. 标题页含竖标与团队角标渲染正常
fe.screen = "title"
fe.menus:resetInput()
act = fe:renderMenu(1 / 60, input, 1280, 720)
check("title screen with brand logos renders", act.type == "none")

root:cleanup()
print(string.format("BRAND SPLASH VERIFY PASS %d / FAIL %d", pass, fail))
assert(fail == 0, "brand splash verification failed")
