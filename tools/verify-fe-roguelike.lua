-- 《向西守望》肉鸽前端《行军筹签记》（fe-roguelike-ui）专项验收脚本
-- 覆盖：双态木简选筹 + 0.25x 表现层轻慢时不阻模拟 + 触屏单击直选与竖屏下台三筹 +
-- 朱砂落印与墨芒归身 + escort 战备行囊修复 + 行军札记与动态雅号 + 2.5D 世界层反馈 +
-- 险段告破与折筹重整跨 bindPlay 留痕 + 未来新天赋兜底 + 暂停冻结。

local Dora = require("Dora")
local Content = Dora.Content
Content:addSearchPath(Content.assetPath .. "/Script")
Content:addSearchPath(Content.assetPath .. "/Script/Lib")
Content:addSearchPath(Content.assetPath)
package.path = package.path .. ";" .. Content.assetPath .. "/?.lua"

local new = require("Script.Lib.lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local playmod = require("Script.watch.play")
local runmod = require("Script.watch.run")
local inputmod = require("Script.watch.input")
local touchmod = require("Script.watch.touch")
local platform = require("Script.watch.platform")
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local TouchControls = require("Script.watch.fe.ui.touch_controls").TouchControls
local catalog = require("Script.watch.fe.ui.talent_catalog")

local PASS, FAIL = 0, 0
local function check(tag, cond, detail)
	if cond then
		PASS = PASS + 1
		print("PASS fe-rg: " .. tag .. (detail and (" | " .. detail) or ""))
	else
		FAIL = FAIL + 1
		print("FAIL fe-rg: " .. tag .. (detail and (" | " .. detail) or ""))
	end
end

local function approx(a, b, eps)
	return math.abs(a - b) <= (eps or 0.03)
end

local function newInput()
	local i = new(inputmod.Input)
	i.moveX = 0
	i.moveY = 0
	i.inside = true
	i.mx, i.my = 640, 360
	for _, k in ipairs({ "jump", "crouch", "cover", "interact", "aim", "fire", "retry", "pause" }) do
		i[k] = { held = false, pressed = false, released = false }
	end
	return i
end

local root = Dora.Node()
local fe = new(Frontend, root)
local prevWatchFe = package.loaded["watch.fe"]
package.loaded["watch.fe"] = { fe = fe }

local rgPlugin = fe:getPlugin("fe-roguelike-ui")
check("1.1 RoguelikeUiPlugin 挂载并保留 M2 11 枚分层插件零回归",
	rgPlugin ~= nil and fe.roguelikeUi == rgPlugin and #fe:getPlugins() == 11,
	"plugins=" .. tostring(#fe:getPlugins()))

-- ==================== 2. 真实男主线 escort1：展卷 0.25x 轻慢时、非阻塞走位自动收束、停步复展 ====================
do
	local r = runmod.createRun(20261127, "official")
	r.story.route = "soldier"
	r.story.settled = true
	r.inventory.wood = 2
	r.inventory.bell = 1
	r.inventory.wedge = 1
	local p = new(playmod.Play, rooms.ESCORT1_ROOM, nil, r)
	local inp = newInput()
	fe.screen = "play"
	fe:bindPlay(p, 1280, 720)

	-- 静止入段：应自动进入展卷态，并平滑压低前端 focusTimeScale 至 0.25
	for _ = 1, 20 do
		fe:renderPlay(1 / 60, p, inp, 1280, 720)
	end
	local stExp = rgPlugin:getState()
	local snapExp = fe.contract:getLastSnapshot()
	check("2.1 入段安全区自动展卷三筹并平滑进入 0.25x 表现层轻慢时聚焦",
		stExp.drawerState == "expanded" and #stExp.offers == 3
		and approx(stExp.focusTimeScale, 0.25, 0.04)
		and approx(snapExp.timeScale, 0.25, 0.04),
		string.format("state=%s scale=%.2f offers=%d", stExp.drawerState, snapExp.timeScale, #stExp.offers))

	-- 关键回归防护：展卷轻慢时仅作用于前端表现层，不阻塞 Play.update 模拟步；向右移动自动收束并恢复 1.0x
	local tBefore = p.ticks
	inp.moveX = 1
	for _ = 1, 12 do
		p:update(playmod.STEP, inp)
		fe:renderPlay(1 / 60, p, inp, 1280, 720)
	end
	local stCmp = rgPlugin:getState()
	local snapCmp = fe.contract:getLastSnapshot()
	check("2.2 移动时 Play.update 零阻塞，同时三筹自动柔顺收束并恢复 1.0x 常速",
		p.ticks == tBefore + 12 and stCmp.drawerState == "compact"
		and approx(stCmp.focusTimeScale, 1.0, 0.04)
		and approx(snapCmp.timeScale, 1.0, 0.04),
		string.format("ticks=%d state=%s scale=%.2f", p.ticks, stCmp.drawerState, snapCmp.timeScale))

	-- 随身战备行囊修复校验：escort1 同时展示 wood/bell/wedge，不再被 ranks 互斥屏蔽
	local hasWood, hasBell, hasWedge = false, false, false
	for _, k in ipairs(stCmp.suppliesShown) do
		if k == "wood" then hasWood = true end
		if k == "bell" then hasBell = true end
		if k == "wedge" then hasWedge = true end
	end
	check("2.3 修复 escort 随身战备 HUD 盲区（木纹筹/铃纹筹/木楔实时入栏）",
		hasWood and hasBell and hasWedge,
		"supplies=" .. table.concat(stCmp.suppliesShown, ","))

	-- 停步 1.3s 后自动复展
	inp.moveX = 0
	for _ = 1, 82 do
		fe:renderPlay(1 / 60, p, inp, 1280, 720)
	end
	check("2.4 停步观察超过 1.25s 自动复展为三筹木简",
		rgPlugin:getState().drawerState == "expanded",
		"state=" .. rgPlugin:getState().drawerState)

	-- 点击第 2 枚筹签：触发朱砂落印(sealing) -> 流墨归身(absorbing) -> 归净(hidden)
	local rects = fe.hud:talentCardRects(1280, 720, 3)
	inp.mx = rects[2].x + rects[2].width * 0.5
	inp.my = rects[2].y + rects[2].height * 0.5
	inp.fire.pressed = true
	rgPlugin:openLedger()
	check("札记盖住筹签时原坐标、触屏热区和选筹意图均不可用",
		not fe:tryPickTalentAtPointer(p, inp, 1280, 720)
		and #fe:getStoryTalentBoxes(p, 1280, 720, true) == 0
		and not fe.contract:submitIntent(p, { kind = "chooseTalent", slot = 1 })
		and #p:getStoryTalentOffers() == 3)
	rgPlugin:closeLedger()
	local picked = fe:tryPickTalentAtPointer(p, inp, 1280, 720)
	inp.fire.pressed = false
	fe:renderPlay(1 / 60, p, inp, 1280, 720)
	local stSeal = rgPlugin:getState()
	for _ = 1, 16 do
		fe:renderPlay(1 / 60, p, inp, 1280, 720)
	end
	local stAbsorb = rgPlugin:getState()
	for _ = 1, 25 do
		fe:renderPlay(1 / 60, p, inp, 1280, 720)
	end
	local stDone = rgPlugin:getState()
	check("2.5 选筹后完整走完「朱砂落印 -> 贝塞尔流墨归身 -> 收净」三段演出并回常速",
		picked == true and stSeal.sealingActive and stAbsorb.absorbingActive
		and stDone.drawerState == "hidden" and approx(stDone.focusTimeScale, 1.0, 0.03),
		string.format("seal=%s absorb=%s end=%s scale=%.2f",
			tostring(stSeal.sealingActive), tostring(stAbsorb.absorbingActive), stDone.drawerState, stDone.focusTimeScale))
end

-- ==================== 3. 触屏单击直选 + 竖屏掌机下台三筹 + 暂停菜单索引 8/9 兼容 ====================
do
	local r = runmod.createRun(20261127, "official")
	r.story.route = "soldier"
	r.story.settled = true
	local p = new(playmod.Play, rooms.ESCORT2_ROOM, nil, r)
	local inp = newInput()
	local router = new(touchmod.TouchRouter)
	inp:bindTouch(router)
	inp:setModePref("touch")
	local ctrl = new(TouchControls, root)

	local vpPort = platform.computeStageViewport(430, 932)
	inp:setStageViewport(vpPort)
	fe:setStagePlacement(vpPort)
	fe:bindPlay(p, vpPort.stageW, vpPort.stageH)
	fe:renderPlay(1 / 60, p, inp, vpPort.stageW, vpPort.stageH)

	local boxes = fe:getStoryTalentBoxes(p, vpPort.stageW, vpPort.stageH, true)
	local tctx = ctrl:syncContext({
		viewport = vpPort, mode = 1, screen = "play", play = p, run = r, cam = fe.cam,
		input = inp, router = router, assistHintsEnabled = false, isMuted = false,
		isFullscreen = false, storyTalentBoxes = boxes, dt = 1 / 60,
	})
	ctrl:render(router)

	-- 查找下半屏掌机台上的 talent:1 热区（y < vpPort.deckH）
	local lowerZone = nil
	for _, z in ipairs(tctx.rectZones) do
		if z.id == "talent:1" and z.rect.y < vpPort.deckH then
			lowerZone = z
			break
		end
	end
	local tapZoneOk = false
	if lowerZone ~= nil then
		router:injectTouch("began", 21, lowerZone.rect.x + 12, lowerZone.rect.y + 12, false)
		router:injectTouch("ended", 21, lowerZone.rect.x + 12, lowerZone.rect.y + 12, false)
		inp:update()
		tapZoneOk = (inp.touchZoneTap == "talent:1")
	end
	check("3.1 竖屏掌机台下半屏生成三筹快键且单击直出 talent:1（无二次确认）",
		lowerZone ~= nil and tapZoneOk,
		"zoneTap=" .. tostring(inp.touchZoneTap))

	-- 暂停菜单：索引 8 仍为操控设置，索引 9 为「行军札记」且选定后退出暂停并直接展开札记
	local vpLand = platform.computeStageViewport(1280, 720)
	inp:setStageViewport(vpLand)
	fe:setStagePlacement(vpLand)
	inp:setModePref("kbm")
	p.paused = true
	fe.menus:openPause()
	fe.menus.pauseSelected = 8
	inp.navConfirm = true
	fe:renderPlay(1 / 60, p, inp, 1280, 720)
	local idx8IsSettings = fe.menus:isShowingPauseSettings()
	inp.navConfirm = false

	fe.menus:openPause()
	fe.menus.pauseSelected = 9
	inp.navConfirm = true
	local act = fe:renderPlay(1 / 60, p, inp, 1280, 720)
	inp.navConfirm = false
	p.paused = false
	fe:renderPlay(1 / 60, p, inp, 1280, 720)
	check("3.2 暂停菜单索引 8 保持操控设置零回归，索引 9「行军札记」恢复并展开宣纸构筑页",
		idx8IsSettings == true and act.type == "resume" and rgPlugin:isLedgerOpen() == true,
		string.format("idx8=%s act=%s ledger=%s", tostring(idx8IsSettings), tostring(act.type), tostring(rgPlugin:isLedgerOpen())))
	rgPlugin:closeLedger()
end

-- ==================== 4. 排演态验证：世界层反馈 / 动态行军雅号 / 未来新天赋兜底 ====================
do
	local p = new(playmod.Play, rooms.ESCORT3_ROOM)
	local inp = newInput()
	fe:bindPlay(p, 1280, 720)
	fe.contract:enterRehearsal("fe-rg-qa")

	-- 4.1 护身弧 / 装填弧 / 巧手环世界层激活
	fe.contract:setMockRoguelike({
		active = true,
		showRouteTrack = true,
		roomKey = "escort3",
		seed = 20261127,
		ticks = 7200,
		offers = {},
		ranks = { vitality = 2, guard = 2, reload = 1, craft = 1 },
		equippedWeapon = "guide_lantern_gun",
		supplies = { wood = 2, bell = 1, wedge = 1, shield = 1 },
		activeInvulnTicks = 28,
		activeReloadTicks = 22,
		activeCraftTicks = 18,
	})
	fe:renderPlay(1 / 60, p, inp, 1280, 720)
	local stW = rgPlugin:getState()
	check("4.1 2.5D 世界层护身青玉弧 / 火绳装填弧 / 巧手木工环全量激活且派生「铁壁断后」",
		stW.activeGuardArc and stW.activeReloadArc and stW.activeCraftRing
		and stW.marchTitle == "铁壁断后",
		string.format("guard=%s reload=%s craft=%s title=%s",
			tostring(stW.activeGuardArc), tostring(stW.activeReloadArc), tostring(stW.activeCraftRing), stW.marchTitle))

	-- 4.2 多流派「行军雅号」派生校验
	local tLamp = catalog.deriveMarchTitle({
		ranks = { reload = 2 }, totalRanks = 2, equippedWeapon = "guide_lantern_gun", supplies = {},
	})
	local tEcho = catalog.deriveMarchTitle({
		ranks = { reload = 2 }, totalRanks = 2, equippedWeapon = "echo_gun", supplies = {},
	})
	local tCraft = catalog.deriveMarchTitle({
		ranks = { craft = 2 }, totalRanks = 2, equippedWeapon = "standard_gun", supplies = { wedge = 1 },
	})
	check("4.2 动态行军雅号覆盖多流派（明火疾铳 / 惊铃连响 / 巧楔筑垒）",
		tLamp.title == "明火疾铳" and tEcho.title == "惊铃连响" and tCraft.title == "巧楔筑垒",
		tLamp.title .. "/" .. tEcho.title .. "/" .. tCraft.title)

	-- 4.3 未知未来天赋 ID 兜底零崩溃 + submitIntent(chooseTalent) 闭环
	fe.contract:setMockRoguelike({
		active = true,
		offers = { "vitality", "night_watch", "craft" },
		talentLabelHints = { night_watch = "夜哨·视野延展" },
	})
	fe:renderPlay(1 / 60, p, inp, 1280, 720)
	local accepted = fe.contract:submitIntent(p, { kind = "chooseTalent", slot = 1 })
	fe:renderPlay(1 / 60, p, inp, 1280, 720)
	local snapAfter = fe.contract:getLastSnapshot()
	check("4.3 未知新天赋 ID 优雅兜底渲染且经 submitIntent(chooseTalent) 闭环晋阶",
		accepted == true and #snapAfter.roguelike.offers == 0 and snapAfter.roguelike.ranks["night_watch"] == 1,
		"rank=" .. tostring(snapAfter.roguelike.ranks["night_watch"]))

	fe.contract:exitRehearsal()
end

-- ==================== 5. 轮回情绪演出跨 bindPlay 保留 + 暂停双冻 ====================
do
	local r = runmod.createRun(20261127, "official")
	r.story.route = "soldier"
	r.story.settled = true
	r.story.talents.ranks.vitality = 1
	r.story.talents.ranks.reload = 1
	local p4 = new(playmod.Play, rooms.ESCORT4_ROOM, nil, r)
	local inp = newInput()
	fe:bindPlay(p4, 1280, 720)
	fe:renderPlay(1 / 60, p4, inp, 1280, 720)

	-- 模拟过段事件后立即切房
	rgPlugin:triggerTestSegmentBanner("escort4", "escort5")
	local p5 = new(playmod.Play, rooms.ESCORT5_ROOM, nil, r)
	fe:bindPlay(p5, 1280, 720)
	fe:renderPlay(1 / 60, p5, inp, 1280, 720)
	check("5.1 「肆程告破」里程流带跨 bindPlay 切房完整保留",
		rgPlugin:getState().segmentBannerActive == true)

	-- 模拟男主线 escort4 战死触发 campaignFailed(reset:true) 并切回 escort1
	fe:bindPlay(p4, 1280, 720)
	fe:renderPlay(1 / 60, p4, inp, 1280, 720)
	p4.equippedWeapon = "echo_gun"
	p4.run.story.talents.ranks.guard = 2
	p4.hp = 0
	p4:campaignFailed()
	local leaving = p4:drainEvents()
	local p1 = new(playmod.Play, rooms.ESCORT1_ROOM, nil, r)
	fe:bindPlay(p1, 1280, 720)
	p1:adoptEvents(leaving)
	fe:renderPlay(1 / 60, p1, inp, 1280, 720)
	local stRecap = rgPlugin:getState()
	check("5.2 战死重置触发「折筹重整 · 残筹散墨」复盘幕，重绑首房后仍显示最后一拍的武器和本领",
		stRecap.deathRecapActive == true and stRecap.deathRecapRoom == "escort4" and stRecap.deathRecapCount == 4
		and rgPlugin.deathRecapSnap.ranks.guard == 2 and rgPlugin.deathRecapSnap.weaponId == "echo_gun"
		and rgPlugin.deathRecapSnap.seed == r.seed and p1.equippedWeapon == "standard_gun",
		string.format("active=%s room=%s count=%d", tostring(stRecap.deathRecapActive), stRecap.deathRecapRoom, stRecap.deathRecapCount))

	-- 暂停期间冻结演出计时
	p1.paused = true
	for _ = 1, 150 do
		fe:renderPlay(1 / 60, p1, inp, 1280, 720)
	end
	check("5.3 暂停态严格冻结折筹重整演出计时（2.5 秒不消退）",
		rgPlugin:getState().deathRecapActive == true)
	p1.paused = false
end

root:cleanup()
package.loaded["watch.fe"] = prevWatchFe
print(string.format("FE ROGUELIKE VERIFY PASS %d / FAIL %d", PASS, FAIL))
assert(FAIL == 0, string.format("肉鸽前端验收失败 %d 项", FAIL))
