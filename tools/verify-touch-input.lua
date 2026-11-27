-- 统一触屏多指路由、复杂交互、Android 独立包退出策略与生命周期专项验收：
-- 覆盖：多指并发与动态假鼠标隔离、2.5D 纵深与小满内圈慢走/防误蹲、推拉车握柄锁定、
-- 空村投瓶拖拽与取消圈、3x3 换弹盘触控滑连与重画钮、选章两段确认、
-- 时间穿梭器按钮、护送试炼触控、Android BackButton 状态机与切后台防卡键。

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
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local platform = require("Script.watch.platform")
local controlsCfg = require("Script.watch.controls_config")
local Input = require("Script.watch.input").Input
local TouchRouter = require("Script.watch.touch").TouchRouter
local TouchControls = require("Script.watch.fe.ui.touch_controls").TouchControls
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local createRun = require("Script.watch.run").createRun
local createTrial = require("Script.watch.run").createTrial

local pass = 0
local function check(tag, cond)
	assert(cond, "FAIL touch: " .. tag)
	pass = pass + 1
	print("PASS touch: " .. tag)
end

local function findBtn(ctx, id)
	for i = 1, #ctx.buttons do
		if ctx.buttons[i].id == id then
			return ctx.buttons[i]
		end
	end
	return nil
end

local function findZone(ctx, id)
	for i = 1, #ctx.rectZones do
		if ctx.rectZones[i].id == id then
			return ctx.rectZones[i]
		end
	end
	return nil
end

local root = Dora.Node()
local fe = new(Frontend, root)
local input = new(Input)
local router = new(TouchRouter, input.settings)
router:attach(root)
input:bindTouch(router)
local ctrl = new(TouchControls, root)

local W, H = 1280, 720
local vp = platform.computeStageViewport(W, H)
input:setStageViewport(vp)
fe:setStagePlacement(vp)
input:setModePref("auto")
input:setInputMode("touch")
input.settings.haptics = false

local function syncTouch(screen, p, modeNum, runObj, talentBoxes)
	return ctrl:syncContext({
		viewport = vp,
		mode = modeNum or 1,
		screen = screen,
		play = p,
		run = runObj,
		cam = fe.cam,
		input = input,
		router = router,
		assistHintsEnabled = false,
		isMuted = false,
		isFullscreen = false,
		storyTalentBoxes = talentBoxes or {},
		dt = 1 / 60,
	})
end

-- 1. 周戍街道：多指并发（左手摇杆右推 + 右屏点射互不串触，2.5D 上下纵深有效 + 动态假鼠标屏蔽）
local streetRun = createRun(20261124, "debug")
local pStreet = new(play.Play, rooms.STREET_ROOM, nil, streetRun)
fe.screen = "play"
fe:bindPlay(pStreet, W, H)
syncTouch("play", pStreet, 1, streetRun)

router:injectTouch("began", 1, 150, 150, false)
router:injectTouch("moved", 1, 208, 195, false)
input:update()
check("stick moves right without false shot", input.moveX == 1 and input.moveY == -1 and not input.fire.pressed)
check("active finger suppresses synthetic mouse", router:isSuppressingSyntheticMouse())

router:injectTouch("began", 2, 860, 260, false)
input:update()
check("second finger shoots while stick stays right", input.moveX == 1 and input.fire.pressed and input.mx > 500)
router:injectTouch("ended", 2, 860, 260, false)
router:injectTouch("ended", 1, 208, 195, false)
input:update()
check("releasing fingers zeroes stick", input.moveX == 0 and input.moveY == 0)

-- 冷却 0.30s 后允许外接物理鼠标恢复工作（不锁死安卓平板外接键鼠）
for _ = 1, 20 do
	syncTouch("play", pStreet, 1, streetRun)
	input:update()
end
check("synthetic mouse suppression clears after cooldown", not router:isSuppressingSyntheticMouse())

-- 2. 小满空村：非纵深房下推摇杆不误蹲 + 内圈慢走 + 蹲伏切跳顺滑起身
local pVillage = new(play.Play, rooms.VILLAGE_ROOM)
fe:bindPlay(pVillage, W, H)
syncTouch("play", pVillage, 1)

router:injectTouch("began", 3, 150, 150, false)
router:injectTouch("moved", 3, 150, 95, false)
input:update()
check("child non-depth room ignores downward stick for crouch", input.moveY == 0 and not input.crouch.held)

router:injectTouch("moved", 3, 174, 150, false)
input:update()
check("child inner stick ring triggers slow walk", input.moveX == 1 and input.cover.held)

router:injectTouch("moved", 3, 210, 150, false)
input:update()
check("child outer stick ring exits slow walk", input.moveX == 1 and not input.cover.held)
router:injectTouch("ended", 3, 210, 150, false)
input:update()

local ctxV = syncTouch("play", pVillage, 1)
local crouchBtn = findBtn(ctxV, "crouch")
local jumpBtn = findBtn(ctxV, "jump")
check("child layout has crouch and jump buttons", crouchBtn ~= nil and jumpBtn ~= nil)
router:injectTouch("began", 4, crouchBtn.x, crouchBtn.y, false)
router:injectTouch("ended", 4, crouchBtn.x, crouchBtn.y, false)
input:update()
check("tapping crouch toggles crouch ON", input.crouch.held)
router:injectTouch("began", 5, jumpBtn.x, jumpBtn.y, false)
router:injectTouch("ended", 5, jumpBtn.x, jumpBtn.y, false)
input:update()
check("tapping jump auto-clears crouch toggle and emits jump", not input.crouch.held and input.jump.pressed)

-- 3. 空村投瓶：按住投瓶拖拽预览 -> 拖回取消圈放弃不误投 -> 拖向砖地松手精准投出
pVillage.hasBottle = true
local ctxBottle = syncTouch("play", pVillage, 1)
local bottleBtn = findBtn(ctxBottle, "bottle")
check("bottle button appears when holding bottle", bottleBtn ~= nil)

router:injectTouch("began", 10, bottleBtn.x, bottleBtn.y, false)
for _ = 1, 12 do
	syncTouch("play", pVillage, 1)
	router:injectTouch("moved", 10, 740, 220, false)
	input:update()
	pVillage.aimX = input.mx
	pVillage.aimY = input.my
	input:beginStep(true)
	pVillage:update(1 / 60, input)
	input:endStep()
end
check("bottle aim builds aimHold while dragging", pVillage.aimHold >= 0.12 and pVillage.hasBottle)
local cancelC = ctxBottle.bottleCancelCenter
router:injectTouch("moved", 10, cancelC.x, cancelC.y, false)
input:update()
check("hovering cancel ring does not prematurely throw", pVillage.hasBottle and pVillage.bottleFly == nil)
router:injectTouch("ended", 10, cancelC.x, cancelC.y, false)
input:update()
check("releasing in cancel ring flags bottleCanceled", input.bottleCanceled and not input.aim.released)
pVillage.aimHold = 0
pVillage.bottleAimX = -1
input:beginStep(true)
pVillage:update(1 / 60, input)
input:endStep()
check("canceled bottle remains in hand", pVillage.hasBottle and pVillage.bottleFly == nil)

router:injectTouch("began", 11, bottleBtn.x, bottleBtn.y, false)
for _ = 1, 12 do
	syncTouch("play", pVillage, 1)
	router:injectTouch("moved", 11, 760, 220, false)
	input:update()
	pVillage.aimX = input.mx
	pVillage.aimY = input.my
	input:beginStep(true)
	pVillage:update(1 / 60, input)
	input:endStep()
end
router:injectTouch("ended", 11, 760, 220, false)
input:update()
check("releasing outside cancel emits aim.released", input.aim.released and not input.bottleCanceled)
input:beginStep(true)
pVillage:update(1 / 60, input)
input:endStep()
check("bottle is thrown cleanly on release", (not pVillage.hasBottle) and pVillage.bottleFly ~= nil)

-- 4. 城外推/拉车握柄锁定（点一次锁定 -> 抬手后左手推摇杆拉车 -> 再点松手）
local pOutside = new(play.Play, rooms.OUTSIDE_ROOM)
fe:bindPlay(pOutside, W, H)
router:clearRoomStates()
pOutside.player.x = pOutside.cartAxle + pOutside.room.cart.handleOffset
pOutside.player.y = pOutside.room.cart.baseY
local startAxle = pOutside.cartAxle
local ctxCart = syncTouch("play", pOutside, 1)
local interBtn = findBtn(ctxCart, "interact")
check("outside cart interact button labeled 拉车", interBtn ~= nil and interBtn.label == "拉车")
router:injectTouch("began", 12, interBtn.x, interBtn.y, false)
router:injectTouch("ended", 12, interBtn.x, interBtn.y, false)
input:update()
input:beginStep(true)
pOutside:update(1 / 60, input)
input:endStep()
check("cart grip latched engages gripping even after finger lift", router.cartGripLatched and pOutside.gripping)

router:injectTouch("began", 13, 150, 150, false)
router:injectTouch("moved", 13, 210, 150, false)
for _ = 1, 10 do
	syncTouch("play", pOutside, 1)
	input:update()
	input:beginStep(true)
	pOutside:update(1 / 60, input)
	input:endStep()
end
check("cart moves smoothly with hands-free grip latch", pOutside.cartAxle > startAxle + 2 and pOutside.gripping)
router:injectTouch("ended", 13, 210, 150, false)

local ctxCart2 = syncTouch("play", pOutside, 1)
local releaseBtn = findBtn(ctxCart2, "interact")
check("latched cart button shows 松手", releaseBtn ~= nil and releaseBtn.label == "松手")
router:injectTouch("began", 14, releaseBtn.x, releaseBtn.y, false)
router:injectTouch("ended", 14, releaseBtn.x, releaseBtn.y, false)
input:update()
input:beginStep(true)
pOutside:update(1 / 60, input)
input:endStep()
check("second tap cleanly ungrips cart", (not router.cartGripLatched) and (not pOutside.gripping))

-- 5. 男主线 escort1：3x3 换弹盘触控一笔滑连 + 时间穿梭器钮 + 三选一天赋卡点击
local escRun = createRun(20261124, "official", { childCleared = true, soldierCleared = true, artifactOwned = true, museumPhase = "done", museumSeen = true })
escRun.story.route = "soldier"
escRun.story.settled = true
local pEsc = new(play.Play, rooms.ESCORT1_ROOM, nil, escRun)
fe:bindPlay(pEsc, W, H)
router:clearRoomStates()
local tBoxes = fe:getStoryTalentBoxes(pEsc, W, H, true)
local ctxEsc = syncTouch("play", pEsc, 1, escRun, tBoxes)
local artBtn = findBtn(ctxEsc, "artifact")
check("artifact button appears when artifactOwned=true", artBtn ~= nil)
check("no dead flare button in soldier touch layout", findBtn(ctxEsc, "flare") == nil)
router:injectTouch("began", 15, artBtn.x, artBtn.y, false)
router:injectTouch("ended", 15, artBtn.x, artBtn.y, false)
input:update()
check("artifact tap emits artifactTogglePressed", input.artifactTogglePressed)
check("toggleArtifactWeapon equips time_shuttler", pEsc:toggleArtifactWeapon() and pEsc.equippedWeapon == "time_shuttler")

local tZone0 = findZone(ctxEsc, "talent:0")
check("talent:0 rectZone registered", tZone0 ~= nil)
router:injectTouch("began", 16, tZone0.rect.x + 20, tZone0.rect.y + 20, false)
router:injectTouch("ended", 16, tZone0.rect.x + 20, tZone0.rect.y + 20, false)
input:update()
check("tapping talent card emits zoneTap without firing", input.touchZoneTap == "talent:0" and not input.fire.pressed)

-- 触发 3x3 换弹并一笔触控滑连 0 -> 4 -> 8
pEsc:submitFeIntent({ kind = "reloadOpen" })
syncTouch("play", pEsc, 1, escRun)
fe:renderPlay(1 / 60, pEsc, input, W, H)
local rw = fe:getPlugin("fe-02-reload-wheel")
check("reload wheel active", pEsc.reloadOpen and rw ~= nil)
local n0 = rw:getNodeUiPos(0)
local n4 = rw:getNodeUiPos(4)
local n8 = rw:getNodeUiPos(8)
router:injectTouch("began", 17, n0.x, n0.y, false)
input:update()
fe:renderPlay(1 / 60, pEsc, input, W, H)
router:injectTouch("moved", 17, n4.x, n4.y, false)
input:update()
fe:renderPlay(1 / 60, pEsc, input, W, H)
router:injectTouch("moved", 17, n8.x, n8.y, false)
input:update()
fe:renderPlay(1 / 60, pEsc, input, W, H)
router:injectTouch("ended", 17, n8.x, n8.y, false)
input:update()
check("touch pattern swipe 0->4->8 solves echo reload", (not pEsc.reloadOpen) and pEsc.reloadPendingEffect == "echo")

-- 6. 选章页触控防误触：首点未选驿站仅预览，二次点击才跳转
fe.screen = "chapters"
fe.menus:openChapters()
syncTouch("chapters", nil, 1)
fe:renderMenu(1 / 60, input, W, H)
local marginX = 96
local perRow = math.ceil((#rooms.ROOMS - 3) / 2)
local stepX = ((W - marginX - 34) - (marginX + 34)) / math.max(1, perRow - 1)
local st2x = (marginX + 34) + 2 * stepX
local st2y = 210
router:injectTouch("began", 18, st2x, st2y, false)
input:update()
local act1 = fe:renderMenu(1 / 60, input, W, H)
router:injectTouch("ended", 18, st2x, st2y, false)
input:update()
check("first touch on unselected chapter previews without jumping", act1.type == "none" and fe.menus.chapterSelected == 2)
router:injectTouch("began", 19, st2x, st2y, false)
input:update()
local act2 = fe:renderMenu(1 / 60, input, W, H)
router:injectTouch("ended", 19, st2x, st2y, false)
input:update()
check("second touch on same chapter confirms jump", act2.type == "jump")

-- 7. 护送试炼（mode === 2）触控上下文：天赋卡 + 暂停/结算按钮
local trialRun = createTrial(42)
local pTrial = new(play.Play, rooms.CAMPAIGN_ROOMS[1], nil, trialRun)
local ctxTrialOffers = syncTouch("play", pTrial, 2, trialRun)
check("trial mode offers expose clickable talent:0 zone", findZone(ctxTrialOffers, "talent:0") ~= nil)
pTrial.paused = true
local ctxTrialPaused = syncTouch("play", pTrial, 2, trialRun)
check("trial mode pause exposes resume/retry/title zones",
	findZone(ctxTrialPaused, "trial:resume") ~= nil
	and findZone(ctxTrialPaused, "trial:retry") ~= nil
	and findZone(ctxTrialPaused, "trial:title") ~= nil)

-- 8. 触控配置切换与 BackButton 状态机（依托 app.start 完整钩子）
local origOpacity = router.settings.touchOpacity
router:cycleOpacity()
check("touch opacity cycles cleanly", router.settings.touchOpacity ~= origOpacity)
router:cycleScale()
router:toggleAimAssist()
router:toggleAimAssist()
check("touch aimAssist toggles cleanly", router.settings.aimAssist == true)

local app = require("Script.watch.app")
local appRoot = Dora.Node()
app.start(appRoot, 1, "play")
local hook = package.loaded["watch.fe"]
local appTouch = package.loaded["watch.touch"]
check("app exposes watch.touch hook", appTouch ~= nil)
local appPlay = hook.getPlay()
check("app play starts unpaused", appPlay ~= nil and not appPlay.paused)
hook.handleBackButton()
check("BackButton during play pauses game", appPlay.paused == true)
hook.handleBackButton()
local appFe = hook.getFrontend()
local appInput = package.loaded["watch.input"]
local resumeAct = appFe:renderPlay(1 / 60, appPlay, appInput, W, H)
check("BackButton during pause emits resume", resumeAct.type == "resume")

-- 模拟切后台释放全部触点
hook.setInputMode("touch")
hook.injectTouch("began", 30, 150, 150, false)
hook.injectTouch("moved", 30, 200, 150, false)
appTouch:releaseAll(true)
appInput:update()
check("background releaseAll clears stick completely", appInput.moveX == 0 and appInput.moveY == 0)

-- 还原默认配置，避免污染用户存档
controlsCfg.saveControlSettings(controlsCfg.defaultControlSettings())
appRoot:cleanup()
root:cleanup()
print("TOUCH INPUT VERIFY PASS " .. pass .. " / FAIL 0")
