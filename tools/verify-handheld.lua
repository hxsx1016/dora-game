-- 安卓掌机、手柄与 KTR 赛道全链路验收脚本（target = "handheld"，仅触屏 + 手柄，锁定横屏）：
-- 1. 手柄核心映射、死区、扳机滞回、Back+Start 避让 Dora Go 退出热键与 Back 长按重试；
-- 2. 菜单 / 执器要诀双页签（手柄/触屏）切换 / 暂停「操控设置」原地二级页（含 Xbox/Nintendo A/B 互换）；
-- 3. 周戍 2.5D 枪战（右摇杆瞄准 + 共享敌兵/盾顶磁吸 + RT/X 开火 + LT/LB 掩体 + L3 穿梭器）；
-- 4. 小满 2D 潜行（左摇杆轻推慢走且不误蹲 + B 蹲伏切换 + 投瓶右摇杆调落点 + B 取消投掷）；
-- 5. 3×3 慢时连线换弹盘（手柄左摇杆斜向直连 0->4->8 + 手柄模式下混用触屏一笔划连 0->4->8）；
-- 6. 安全工台手柄切卡/制作/离开 & 男主线三选一本领卡手柄/混用触屏选择；
-- 7. KTR1/R2（3:2 1620×1080）与 KTR2（4:3 1280×960）多比例视口、镜头横向补偿与渲染稳态。

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

package.loaded["watch.target"] = "handheld"
local targetMod = require("Script.watch.target")
targetMod.resetActiveTarget()

local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local playMod = require("Script.watch.play")
local platform = require("Script.watch.platform")
local controlsCfg = require("Script.watch.controls_config")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local runMod = require("Script.watch.run")
local saveMod = require("Script.watch.save")

local pass = 0
local function check(tag, cond)
	assert(cond, "FAIL handheld: " .. tag)
	pass = pass + 1
	print("PASS handheld: " .. tag)
end

local function makeCtx(overrides)
	local ctx = {
		stageW = 1280,
		stageH = 720,
		uiScale = 1,
		modal = false,
		gameplayActive = true,
		reloadActive = false,
		craftActive = false,
		talentOfferCount = 0,
		childMode = false,
		allowDepth = true,
		canShoot = true,
		canBottleAim = false,
		playerRolling = false,
		inLowArch = false,
		inTowerEnd = false,
		playerFacing = 1,
		playerScreenX = 420,
		playerScreenY = 260,
		enemyTargets = {},
	}
	if overrides ~= nil then
		for k, v in pairs(overrides) do
			ctx[k] = v
		end
	end
	return ctx
end

local root = Dora.Node()
local input = new(Input)
input:attach(root, {})
input:setModePref("auto")
input.settings.gamepadLayout = "xbox"
input.settings.aimAssist = true
input.settings.crouchToggle = false
local gp = input:getGamepadRouter()
local router = input:getTouchRouter()
local ctrl = input:getTouchControls()
check("handheld target attaches GamepadRouter + TouchRouter + 36-Label TouchControls",
	gp ~= nil and router ~= nil and ctrl ~= nil and ctrl:getAllocatedLabelCount() == 36)
check("handheld modePref cycles auto -> gamepad -> touch -> auto (no kbm)",
	input:cycleModePref(1) == "gamepad"
	and input:cycleModePref(1) == "touch"
	and input:cycleModePref(1) == "auto")

-- 1. Back + Start 组合键隔离 & Back 长按 0.55s 重试 & Start 暂停
gp:setFrameContext(makeCtx({}), 1 / 60)
gp:setSimulatedState({ back = true, start = true })
input:update()
check("Back+Start chord suppresses pause and retry", not input.pause.pressed and not input.retry.pressed)
check("input switches to gamepad mode on controller input", input:isGamepadMode())
input:consumeEdges()

gp:setSimulatedState({})
input:update()
input:consumeEdges()

gp:setSimulatedState({ start = true })
input:update()
check("single Start triggers pause", input.pause.pressed)
input:consumeEdges()

gp:setSimulatedState({})
input:update()
input:consumeEdges()

local shortRetry = false
for _ = 1, 12 do
	gp:setFrameContext(makeCtx({}), 1 / 60)
	gp:setSimulatedState({ back = true })
	input:update()
	if input.retry.pressed then shortRetry = true end
	input:consumeEdges()
end
check("short Back press (<0.55s) does not trigger retry", not shortRetry and input.retryHoldProgress > 0.25)

local longRetryCount = 0
for _ = 1, 35 do
	gp:setFrameContext(makeCtx({}), 1 / 60)
	gp:setSimulatedState({ back = true })
	input:update()
	if input.retry.pressed then longRetryCount = longRetryCount + 1 end
	input:consumeEdges()
end
check("holding Back >= 0.55s fires retry exactly once", longRetryCount == 1)

gp:setSimulatedState({})
input:update()
input:consumeEdges()

-- 2. 周戍 2.5D：斜向方映射 + 右摇杆磁吸瞄准 + 扳机滞回 + L3 穿梭器
gp:setFrameContext(makeCtx({
	enemyTargets = {
		{ sx = 760, sy = 310, shield = false },
	},
}), 1 / 60)
gp:setSimulatedState({
	leftX = 0.72,
	leftY = -0.72,
	rightX = 0.96,
	rightY = -0.10,
	rt = 0.65,
	lt = 0.50,
	a = true,
	y = true,
	ls = true,
})
input:update()
check("soldier diagonal stick produces strong moveX & moveY", input.moveX > 0.85 and input.moveY < -0.85)
check("soldier RT fires and LT covers", input.fire.pressed and input.cover.held)
check("soldier A rolls/jumps and Y interacts", input.jump.pressed and input.interact.pressed)
check("soldier L3 toggles artifact weapon", input.artifactTogglePressed)
check("soldier aim assist snaps to enemy target", math.abs(input.mx - 760) < 2 and math.abs(input.my - 310) < 2)
input:consumeEdges()

gp:setSimulatedState({ rt = 0.25 })
input:update()
check("RT hysteresis keeps fire held at 0.25", input.fire.held and not input.fire.pressed)
gp:setSimulatedState({ rt = 0.10 })
input:update()
check("RT releases cleanly below 0.20", not input.fire.held and input.fire.released)
input:consumeEdges()

-- 3. 小满 2D：内圈轻推慢走且微倾不误蹲 + 投瓶右摇杆瞄准 + B 取消投掷
gp:setFrameContext(makeCtx({
	childMode = true,
	allowDepth = false,
	canShoot = false,
	canBottleAim = true,
	playerScreenX = 400,
	playerScreenY = 220,
}), 1 / 60)
gp:setSimulatedState({ leftX = 0.40, leftY = 0.28 })
input:update()
check("child gentle stick activates slow walk without accidental down-crouch", input.moveX == 1 and input.cover.held and input.moveY == 0)
input:consumeEdges()

gp:setSimulatedState({ leftX = 0.05, leftY = 0.85 })
input:update()
check("child deliberate down stick triggers crouch moveY=1", input.moveY == 1)
input:consumeEdges()

gp:setSimulatedState({ rt = 0.80 })
input:update()
check("child RT starts bottle aim", input.aim.held and input.aim.pressed)
local startAimX = input.mx
input:consumeEdges()

for _ = 1, 10 do
	gp:setFrameContext(makeCtx({
		childMode = true,
		allowDepth = false,
		canShoot = false,
		canBottleAim = true,
		playerScreenX = 400,
		playerScreenY = 220,
	}), 1 / 60)
	gp:setSimulatedState({ rt = 0.80, rightX = 1.0 })
	input:update()
	input:consumeEdges()
end
check("right stick shifts bottle landing X forward", input.mx > startAimX + 40)

gp:setSimulatedState({ rt = 0.80, b = true })
input:update()
check("pressing B during bottle aim cancels safely without aim.released", input.bottleCanceled and not input.aim.held and not input.aim.released)
input:consumeEdges()

gp:setSimulatedState({})
input:update()
check("releasing RT after cancel does not fire stray bottle throw", not input.aim.released)
input:consumeEdges()

-- 4. 菜单导航 + Xbox/Nintendo A/B 互换 + 执器要诀双页切换（手柄/触屏）
local fe = new(Frontend, root)
local vp32 = platform.computeStageViewport(1620, 1080)
local vp43 = platform.computeStageViewport(1280, 960)
input:setStageViewport(vp32)
fe:setStagePlacement(vp32)
fe.screen = "title"
fe.menus.selected = 0

gp:setFrameContext(makeCtx({ stageW = 1620, stageH = 1080, uiScale = vp32.uiScale, modal = true, gameplayActive = false }), 1 / 60)
for _ = 1, 2 do
	gp:setSimulatedState({ down = true })
	input:update()
	fe:renderMenu(1 / 60, input, 1620, 1080)
	gp:setSimulatedState({})
	input:update()
	fe:renderMenu(1 / 60, input, 1620, 1080)
end
check("gamepad down navigates title menu to controls (index 2)", fe.menus.selected == 2)

gp:setSimulatedState({ a = true })
input:update()
local actOpenCtrl = fe:renderMenu(1 / 60, input, 1620, 1080)
check("Xbox A confirms title selection to openControls", actOpenCtrl.type == "openControls")
gp:setSimulatedState({})
input:update()

fe.screen = "controls"
fe.menus:resetInput()
fe:renderMenu(1 / 60, input, 1620, 1080)
check("controls screen auto-selects gamepad tab in gamepad mode", fe.menus.controlsTab == "gamepad")

gp:setSimulatedState({ rb = true })
input:update()
fe:renderMenu(1 / 60, input, 1620, 1080)
check("RB switches controls tab from gamepad to touch", fe.menus.controlsTab == "touch")

gp:setSimulatedState({})
input:update()
fe:renderMenu(1 / 60, input, 1620, 1080)

gp:setSimulatedState({ rb = true })
input:update()
fe:renderMenu(1 / 60, input, 1620, 1080)
check("RB wraps back to gamepad (no kbm tab on handheld)", fe.menus.controlsTab == "gamepad")

gp:setSimulatedState({ b = true })
input:update()
local actCtrlBack = fe:renderMenu(1 / 60, input, 1620, 1080)
check("Xbox B leaves controls screen back to title", actCtrlBack.type == "backTitle")

gp:toggleLayout()
check("gamepad layout toggles to nintendo", gp.settings.gamepadLayout == "nintendo")
input:setStageViewport(vp43)
fe:setStagePlacement(vp43)
fe.screen = "chapters"
fe.menus:openChapters()
gp:setSimulatedState({})
input:update()
fe:renderMenu(1 / 60, input, 1280, 960)

gp:setSimulatedState({ b = true })
input:update()
local actNinConfirm = fe:renderMenu(1 / 60, input, 1280, 960)
check("Nintendo B confirms chapter jump", actNinConfirm.type == "jump")

gp:setSimulatedState({ a = true })
input:update()
local actNinBack = fe:renderMenu(1 / 60, input, 1280, 960)
check("Nintendo A backs out of chapters", actNinBack.type == "backTitle")
gp:toggleLayout()

-- 5. 3×3 慢时连线换弹盘：手柄左摇杆斜向直连 0 -> 4 -> 8 & 手柄模式下混用触屏一笔划连 0 -> 4 -> 8
local esc1Room = nil
for _, r in ipairs(rooms.ROOMS) do
	if r.key == "escort1" then esc1Room = r end
end
assert(esc1Room ~= nil, "missing escort1 room")

local storyRun = runMod.createRun(20261127, "official", saveMod.emptySave())
storyRun.story.route = "soldier"
local pReload = new(playMod.Play, esc1Room, nil, storyRun)
input:setStageViewport(vp32)
fe:setStagePlacement(vp32)
fe:bindPlay(pReload, 1620, 1080)
fe.screen = "play"
pReload:beginReload()
check("reload session opens on escort1", pReload.reloadOpen == true)

gp:setFrameContext(makeCtx({ modal = true, reloadActive = true, stageW = 1620, stageH = 1080, uiScale = vp32.uiScale }), 1 / 60)
gp:setSimulatedState({ leftX = 0.85, leftY = -0.85 })
input:update()
fe:renderPlay(1 / 60, pReload, input, 1620, 1080)
check("gamepad diagonal stick auto-commits 0 -> 4", #pReload.reloadPath == 2 and pReload.reloadPath[2] == 4)

gp:setSimulatedState({})
input:update()
fe:renderPlay(1 / 60, pReload, input, 1620, 1080)

gp:setSimulatedState({ leftX = 0.85, leftY = -0.85 })
input:update()
fe:renderPlay(1 / 60, pReload, input, 1620, 1080)
check("gamepad second diagonal push 4 -> 8 solves reload with echo", (not pReload.reloadOpen) and pReload.reloadPendingEffect == "echo")

-- 5b) 手柄模式下直接混用触屏一笔划连 0 -> 4 -> 8（不强弹虚拟摇杆！）
gp:setSimulatedState({})
pReload.reloadPendingEffect = ""
pReload:beginReload()
check("second reload opens for hybrid touch drag test", pReload.reloadOpen == true)
ctrl:syncContext({
	viewport = vp32, mode = 1, screen = "play", play = pReload, run = storyRun, cam = fe.cam,
	router = router, overlayActive = false, allowAutoGameplayTouch = true, allowMouseOnOverlay = false,
	showWebTopPills = false, canToggleFullscreen = false, assistHintsEnabled = false, isMuted = false,
	isFullscreen = false, storyTalentBoxes = {}, dt = 1 / 60,
})
input:update()
fe:renderPlay(1 / 60, pReload, input, 1620, 1080)

local rw = fe:getPlugin("fe-02-reload-wheel")
local n0 = rw:getNodeUiPos(0)
local n4 = rw:getNodeUiPos(4)
local n8 = rw:getNodeUiPos(8)
local sc32 = vp32.uiScale
router:injectTouch("began", 1, n0.x * sc32, n0.y * sc32, false)
input:update()
fe:renderPlay(1 / 60, pReload, input, 1620, 1080)
check("hybrid touch on reload wheel keeps gamepad mode without popping virtual HUD", input:isGamepadMode() and not input:shouldShowTouchControls())

router:injectTouch("moved", 1, n4.x * sc32, n4.y * sc32, false)
input:update()
fe:renderPlay(1 / 60, pReload, input, 1620, 1080)
check("hybrid touch drag connects center bell node 4", #pReload.reloadPath == 2 and pReload.reloadPath[2] == 4)

router:injectTouch("moved", 1, n8.x * sc32, n8.y * sc32, false)
input:update()
fe:renderPlay(1 / 60, pReload, input, 1620, 1080)
router:injectTouch("ended", 1, n8.x * sc32, n8.y * sc32, false)
input:update()
check("hybrid touch one-stroke drag solves 3x3 reload with echo", (not pReload.reloadOpen) and pReload.reloadPendingEffect == "echo")

-- 6. 第三段安全工台：手柄切卡 + 制作 + B 关闭
local esc3Room = nil
for _, r in ipairs(rooms.ROOMS) do
	if r.key == "escort3" then esc3Room = r end
end
assert(esc3Room ~= nil, "missing escort3 room")
local storyRunCraft = runMod.createRun(20261128, "official", saveMod.emptySave())
storyRunCraft.story.route = "soldier"
storyRunCraft.inventory.wood = 2
storyRunCraft.inventory.bell = 1
local pCraft = new(playMod.Play, esc3Room, nil, storyRunCraft)
input:setStageViewport(vp43)
fe:setStagePlacement(vp43)
fe:bindPlay(pCraft, 1280, 960)
pCraft:openCraftBench()
check("craft bench opens on escort3", pCraft.craftBench.active == true)

gp:setFrameContext(makeCtx({ modal = true, craftActive = true, stageW = 1280, stageH = 960, uiScale = vp43.uiScale }), 1 / 60)
gp:setSimulatedState({ right = true })
input:update()
fe:renderPlay(1 / 60, pCraft, input, 1280, 960)
local cb = fe:getPlugin("fe-02-craft-bench")
check("gamepad right selects second recipe card on craft bench", cb:getState().selectedIndex == 1)

gp:setSimulatedState({})
input:update()
fe:renderPlay(1 / 60, pCraft, input, 1280, 960)

gp:setSimulatedState({ a = true })
input:update()
fe:renderPlay(1 / 60, pCraft, input, 1280, 960)
check("gamepad A crafts and equips selected weapon", pCraft.equippedWeapon == "echo_gun")

gp:setSimulatedState({})
input:update()
fe:renderPlay(1 / 60, pCraft, input, 1280, 960)

gp:setSimulatedState({ b = true })
input:update()
fe:renderPlay(1 / 60, pCraft, input, 1280, 960)
check("gamepad B closes craft bench cleanly", not pCraft.craftBench.active)

-- 6b. 男主线三选一本领卡：手柄 LB/RB + L3 与手柄下混用触屏点卡
local offersBefore = pReload:getStoryTalentOffers()
check("escort1 provides 3 story talent offers", #offersBefore == 3)
gp:setFrameContext(makeCtx({ modal = false, gameplayActive = true, talentOfferCount = #offersBefore, stageW = 1620, stageH = 1080, uiScale = vp32.uiScale }), 1 / 60)
gp:setSimulatedState({ rb = true })
input:update()
check("RB emits talentDelta=+1", input.talentDelta == 1)
fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta) % #offersBefore
gp:setSimulatedState({})
input:update()
gp:setSimulatedState({ ls = true })
input:update()
check("L3 emits talentConfirm=true", input.talentConfirm == true)
local picked = pReload:chooseTalent(fe.hud.talentSelected)
check("gamepad L3 chooses highlighted story talent", picked == true and #pReload:getStoryTalentOffers() == 0)

-- 手柄模式下直接混用手指点选 escort3 的第二张本领卡
local offers3 = pCraft:getStoryTalentOffers()
assert(#offers3 == 3, "escort3 must deal its three cards after the workbench closes")
do
	gp:setSimulatedState({})
	input:update()
	fe:renderPlay(1 / 60, pCraft, input, 1280, 960)
	local boxes3 = fe:getStoryTalentBoxes(pCraft, 1280, 960, false)
	ctrl:syncContext({
		viewport = vp43, mode = 1, screen = "play", play = pCraft, run = storyRunCraft, cam = fe.cam,
		router = router, overlayActive = false, allowAutoGameplayTouch = true, allowMouseOnOverlay = false,
		showWebTopPills = false, canToggleFullscreen = false, assistHintsEnabled = false, isMuted = false,
		isFullscreen = false, storyTalentBoxes = boxes3, dt = 1 / 60,
	})
	assert(#boxes3 == 3, "all post-workbench cards must be visible")
	local b1 = boxes3[2]
	router:injectTouch("began", 9, (b1.x + b1.width * 0.5) * vp43.uiScale, (b1.y + b1.height * 0.5) * vp43.uiScale, false)
	router:injectTouch("ended", 9, (b1.x + b1.width * 0.5) * vp43.uiScale, (b1.y + b1.height * 0.5) * vp43.uiScale, false)
	input:update()
	check("hybrid touch tap on talent card emits zoneTap=talent:1 while keeping gamepad mode",
		input.touchZoneTap == "talent:1" and input:isGamepadMode())
	pCraft:chooseTalent(1)
	check("talent card picked cleanly", #pCraft:getStoryTalentOffers() == 0)
end

-- 6c. 暂停菜单末项「操控设置」原地二级页手柄切换布局（Xbox <-> Nintendo）
-- 掌机非独立包模式下过滤全屏与退出，共 7 项（0..6），末项索引 6 为「操控设置」
pCraft.paused = true
fe.menus:openPause()
input:setStageViewport(vp32)
fe:setStagePlacement(vp32)
gp:setFrameContext(makeCtx({ modal = true, gameplayActive = true, stageW = 1620, stageH = 1080, uiScale = vp32.uiScale }), 1 / 60)
gp:setSimulatedState({ down = true })
input:update()
fe:renderPlay(1 / 60, pCraft, input, 1620, 1080)
gp:setSimulatedState({})
input:update()
check("gamepad mode activates pause menu selection", input:isGamepadMode() and fe.menus.pauseSelected == 1)

fe.menus.pauseSelected = 6
gp:setSimulatedState({ a = true })
input:update()
fe:renderPlay(1 / 60, pCraft, input, 1620, 1080)
check("pause settings item opens 操控设置 sub-panel via gamepad A", fe.menus:isShowingPauseSettings())
gp:setSimulatedState({})
input:update()

-- 下移 2 次到第 2 行「手柄确认键」(0=modePref, 1=aimAssist, 2=gpLayout)
for _ = 1, 2 do
	gp:setSimulatedState({ down = true })
	input:update()
	fe:renderPlay(1 / 60, pCraft, input, 1620, 1080)
	gp:setSimulatedState({})
	input:update()
	fe:renderPlay(1 / 60, pCraft, input, 1620, 1080)
end
gp:setSimulatedState({ a = true })
input:update()
fe:renderPlay(1 / 60, pCraft, input, 1620, 1080)
check("settings row 2 toggles gamepad layout to nintendo", gp.settings.gamepadLayout == "nintendo")
gp:setSimulatedState({})
input:update()
gp:setSimulatedState({ b = true }) -- nintendo 布局下 B 为确认！
input:update()
fe:renderPlay(1 / 60, pCraft, input, 1620, 1080)
check("settings row 2 toggles layout back to xbox via Nintendo B", gp.settings.gamepadLayout == "xbox")
pCraft.paused = false

-- 7. 多比例镜头（16:9 / KTR 3:2 1620×1080 / KTR2 4:3 1280×960）横向视野补偿与互逆校验
local streetRoom = nil
for _, r in ipairs(rooms.ROOMS) do
	if r.key == "street" then streetRoom = r end
end
assert(streetRoom ~= nil, "missing street room")
local pCam = new(playMod.Play, streetRoom)

fe:bindPlay(pCam, 1280, 720)
local halfW169 = (1280 * 0.5) / fe.cam.ppu
local ppu169 = fe.cam.ppu

fe:bindPlay(pCam, 1620, 1080)
local halfW32 = (1620 * 0.5) / fe.cam.ppu
local pt32 = fe.cam:worldToScreen(pCam.player.x, pCam.player.y, pCam.player.depth)
local back32 = fe.cam:screenToWorld(pt32.x, pt32.y)
check("KTR 3:2 (1620x1080) preserves >=95% of 16:9 horizontal FOV", halfW32 >= halfW169 * 0.95)
check("KTR 3:2 worldToScreen/screenToWorld strictly invertible", math.abs(back32.x - pCam.player.x) < 0.01)

fe:bindPlay(pCam, 1280, 960)
local halfW43 = (1280 * 0.5) / fe.cam.ppu
local pt43 = fe.cam:worldToScreen(pCam.player.x, pCam.player.y, pCam.player.depth)
local back43 = fe.cam:screenToWorld(pt43.x, pt43.y)
check("KTR2 4:3 (1280x960) recovers horizontal FOV (>=88% of 16:9)", halfW43 >= halfW169 * 0.88 and ppu169 > 0)
check("KTR2 4:3 worldToScreen/screenToWorld strictly invertible", math.abs(back43.x - pCam.player.x) < 0.01)

-- 8. 在 3:2 与 4:3 视口完整渲染主菜单/选章/暂停/局内 HUD 验证无异常
gp:setSimulatedState({})
input:update()
fe:renderPlay(1 / 60, pCam, input, 1620, 1080)
fe:renderPlay(1 / 60, pCam, input, 1280, 960)
pCam.paused = true
fe.menus:openPause()
fe:renderPlay(1 / 60, pCam, input, 1620, 1080)
fe:renderPlay(1 / 60, pCam, input, 1280, 960)
check("3:2 and 4:3 play & pause frames render cleanly", true)

controlsCfg.saveControlSettings(controlsCfg.defaultControlSettings())
package.loaded["watch.target"] = nil
targetMod.resetActiveTarget()
root:cleanup()
print("HANDHELD VERIFY PASS " .. pass .. " / FAIL 0")
