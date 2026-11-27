-- 《向西守望》全分镜纯 Live 演出实机回归脚本（禁用 enterRehearsal / setMock*）
-- 覆盖：
--  1. 选章入口上下文（序章 P01 起播、女主四房低模、男主护送背负+工台材料、北塔双结局分列）
--  2. 续读存档保真（序章 P01/P02 存档恢复不跳过、护送背负兜底、标题存档章名）
--  3. 共同序章 P01 -> P02 -> P03(180 拍) -> P04(跨房单次) + D30–D34/D01–D02 实机可见 + 低引导 flashSet 拆句
--  4. S1 战后对白（D40/D41）与 C1 候检院对白（C1A/C1B/C1C）
--  5. 城门 P05(gate-farewell) -> G01(gate-count) 零叠字叠音 + G05(gate-wait) D48 可见
--  6. 北塔 door_open 推门提灯过渡、无误弹横幅、D14->D16 节拍、低模值夜室与 M03 尾声 D55 可见

local Dora = require("Dora")
local lualib = require("lualib_bundle")
local new = lualib.__TS__New

local rooms = require("Script.watch.rooms")
local playmod = require("Script.watch.play")
local runmod = require("Script.watch.run")
local inputmod = require("Script.watch.input")
local Frontend = require("Script.watch.fe.frontend").WatchFrontend

local pass, fail = 0, 0
local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS live-staging: %-46s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL live-staging: %-46s %s", tag, detail or ""))
	end
end

local function makeInput()
	local i = new(inputmod.Input)
	i.moveX = 0; i.moveY = 0; i.inside = true; i.mx = 640; i.my = 360
	i.uiInside = false; i.uiPressed = false; i.uiReleased = false; i.uiHeld = false
	i.inputMode = "kbm"; i.gamepadLayout = "xbox"
	return i
end

local function visibleTexts(fe)
	local out = {}
	local buckets = { "xs", "sm", "md", "lg", "banner", "title" }
	for _, b in ipairs(buckets) do
		local pool = fe.texts.pools and fe.texts.pools[b]
		if pool ~= nil then
			for _, lb in ipairs(pool) do
				if lb.visible and lb.text ~= nil and lb.text ~= "" then
					out[#out + 1] = lb.text
				end
			end
		end
	end
	return out
end

local function hasVisibleSubstr(fe, needle)
	for _, t in ipairs(visibleTexts(fe)) do
		if t:find(needle, 1, true) then
			return true
		end
	end
	return false
end

local function findRoomIdx(key)
	for idx, r in ipairs(rooms.ROOMS) do
		if r.key == key then
			return idx - 1
		end
	end
	return -1
end

local DT = playmod.STEP

print("==== 《向西守望》全分镜纯 Live 演出回归开始 ====")

-- ---------------------------------------------------------------- 1. 入口层（app.ts start/previewChapter/continueStory）
do
	local appRoot = Dora.Node()
	local app = require("Script.watch.app")
	app.start(appRoot, 1, "title")
	local wf = package.loaded["watch.fe"]
	local fe = wf.getFrontend()
	wf.useTestSave("_verify_staging_live_profile")
	wf.clearSessionNow()

	-- 1.1 选章 -> 序章：默认从 P01（prologue-wake）完整起播
	local pPro = wf.previewChapter(findRoomIdx("prologue"))
	local inp = makeInput()
	fe:renderPlay(DT, pPro, inp, 1280, 720)
	local proPl = fe:getPlugin("fe03-prologue-intro")
	check("1.1 选章序章从 P01(prologue-wake) 完整起播",
		pPro.phase == "prologue-wake" and proPl:getSnapshot().stage == "p01_wake",
		string.format("phase=%s stage=%s", tostring(pPro.phase), tostring(proPl:getSnapshot().stage)))

	-- 1.2 选章 -> 城外/空村/森林：自动注入 child 路线并激活 LowpolyWorldPlugin
	local lowpolyPl = fe:getPlugin("fe-04-child-lowpoly")
	for _, rk in ipairs({ "outside", "village", "forest" }) do
		local pChild = wf.previewChapter(findRoomIdx(rk))
		fe:renderPlay(DT, pChild, inp, 1280, 720)
		local lpSt = lowpolyPl:getDebugState()
		check("1.2 选章 " .. rk .. " 激活低模世界",
			pChild.storyRoute == "child" and lpSt.active == true and lpSt.roomKey == rk,
			string.format("route=%s lpActive=%s", tostring(pChild.storyRoute), tostring(lpSt.active)))
	end

	-- 1.3 选章 -> 护送 2 / 护送 3：自动注入 soldier + carryOn=true + 工台材料
	local carryPl = fe:getPlugin("fe-02-carry-pose")
	local pEsc2 = wf.previewChapter(findRoomIdx("escort2"))
	fe:renderPlay(DT, pEsc2, inp, 1280, 720)
	check("1.3a 选章 escort2 激活背负姿态",
		pEsc2.storyRoute == "soldier" and pEsc2.carryOn == true and carryPl:getPoseState().mode == "carrying",
		string.format("route=%s carry=%s mode=%s", tostring(pEsc2.storyRoute), tostring(pEsc2.carryOn), tostring(carryPl:getPoseState().mode)))

	local pEsc3 = wf.previewChapter(findRoomIdx("escort3"))
	fe:renderPlay(DT, pEsc3, inp, 1280, 720)
	check("1.3b 选章 escort3 预置工台材料可试握",
		pEsc3.storyRoute == "soldier" and pEsc3.carryOn == true and pEsc3.run.inventory.wood >= 2 and pEsc3.run.inventory.scrap >= 2,
		string.format("wood=%d scrap=%d", pEsc3.run.inventory.wood, pEsc3.run.inventory.scrap))

	-- 1.4 选章 -> 北塔双线（留灯低模 vs 团圆像素）
	local towerIdx = findRoomIdx("tower")
	local pTowChild = wf.previewChapter(towerIdx, "child")
	fe:renderPlay(DT, pTowChild, inp, 1280, 720)
	check("1.4a 选章北塔·留灯激活小满低模线",
		pTowChild.storyRoute == "child" and lowpolyPl:getDebugState().active == true,
		string.format("route=%s lpActive=%s", tostring(pTowChild.storyRoute), tostring(lowpolyPl:getDebugState().active)))

	local pTowSol = wf.previewChapter(towerIdx, "soldier")
	fe:renderPlay(DT, pTowSol, inp, 1280, 720)
	check("1.4b 选章北塔·团圆激活周戍同行像素线",
		pTowSol.storyRoute == "soldier" and pTowSol.childMode == false and pTowSol.partner.alive == true and lowpolyPl:getDebugState().active == false,
		string.format("route=%s childMode=%s partner=%s", tostring(pTowSol.storyRoute), tostring(pTowSol.childMode), tostring(pTowSol.partner.alive)))

	-- 1.5 续读存档保真：P01 期间落盘续读仍重播 prologue-wake；标题显示存档章节短名
	local pOff = wf.startStory()
	check("1.5a 正式新局首帧在 prologue-wake", pOff.phase == "prologue-wake", "phase=" .. tostring(pOff.phase))
	wf.saveSessionNow()
	check("1.5b 标题页显示续读章节短名", fe.menus.hasSession == true and fe.menus.sessionLabel ~= "",
		"label=" .. tostring(fe.menus.sessionLabel))
	local pResumed = wf.continueStory()
	check("1.5c 续读序章 P01 存档不跳过 prologue-wake",
		pResumed ~= nil and pResumed.room.key == "prologue" and pResumed.phase == "prologue-wake",
		"phase=" .. tostring(pResumed and pResumed.phase))

	wf.clearSessionNow()
	wf.useTestSave("")
	appRoot:cleanup()
end

-- ---------------------------------------------------------------- 2. 序章 P01->P02->P03(180拍)->P04(跨房单次) + S1/C1 对白
do
	local root = Dora.Node()
	local fe = new(Frontend, root)
	fe.screen = "play"
	local inp = makeInput()
	local r = runmod.createRun(20261127, "official", runmod.createArchive())
	local p = new(playmod.Play, rooms.PROLOGUE_ROOM, nil, r)
	p.phase = "prologue-wake"
	fe:bindPlay(p, 1280, 720)
	local proPl = fe:getPlugin("fe03-prologue-intro")
	local cuffPl = fe:getPlugin("fe-01-cuff-shots")

	-- P01 前半(D30) + 后半(D31) 实机可见，且无硬编码「小满。」重复
	for _ = 1, 30 do
		p:update(DT, inp)
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	check("2.1a P01 实机可见 D30(母亲对白) 且无硬编码叠字",
		hasVisibleSubstr(fe, "别点灯") and not hasVisibleSubstr(fe, "「小满。」"),
		"vis=" .. table.concat(visibleTexts(fe), " | "))

	for _ = 1, 130 do
		p:update(DT, inp)
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	check("2.1b P01 后半实机可见 D31(父亲对白)",
		p.phase == "prologue-wake" and hasVisibleSubstr(fe, "把门顶上"),
		"vis=" .. table.concat(visibleTexts(fe), " | "))

	-- 走完 P01(240 拍) 进 P02 压影(D32/D33) -> 逃柜(D34)
	for _ = 1, 90 do
		p:update(DT, inp)
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	check("2.2a P02 压影实机可见 D32(小满)",
		p.phase == "prologue-shadow" and hasVisibleSubstr(fe, "爹？娘？"),
		"phase=" .. p.phase .. " vis=" .. table.concat(visibleTexts(fe), " | "))

	for _ = 1, 125 do
		p:update(DT, inp)
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	check("2.2b P02 逃柜实机可见对白(D33/D34) 不再空屏",
		p.phase == "prologue-escape" and (hasVisibleSubstr(fe, "搜干净") or hasVisibleSubstr(fe, "……娘。")),
		"phase=" .. p.phase .. " vis=" .. table.concat(visibleTexts(fe), " | "))

	-- 跑到倒柜入柜 -> 等 51 拍进入 prologue-wait
	p.player.x = p.ox + playmod.PROLOGUE_CABINET_X + 2
	for _ = 1, 55 do
		p:update(DT, inp)
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	check("2.2c 入柜后切回周戍 prologue-wait 且低引导拆句保留叙事",
		p.phase == "prologue-wait" and fe.contract:isAssistHintsEnabled() == false
		and not hasVisibleSubstr(fe, "点 E"),
		"phase=" .. p.phase .. " vis=" .. table.concat(visibleTexts(fe), " | "))

	-- 直接测试低引导 flashSet 拆句（清 activeLine 后验证复合句保留纯叙事段、剔除按键段）
	fe.narrative:onEnterRoom("prologue")
	p.flash = "周戍蹲到柜边 · 点 E 递针套"
	p.flashT = 1.6
	p.phase = "prologue-wait"
	fe.narrative.triggeredBeats["p1_call"] = true
	fe:renderPlay(DT, p, inp, 1280, 720)
	check("2.2d 低引导拆分复合 flashSet 保留「周戍蹲到柜边」去「点 E」",
		hasVisibleSubstr(fe, "周戍蹲到柜边") and not hasVisibleSubstr(fe, "点 E"),
		"vis=" .. table.concat(visibleTexts(fe), " | "))

	-- P03：180 拍（3.0s），期间 D01 实机可见且无重复，60 拍不提前切出
	p.player.x = p.partner.x - 10
	p.player.depth = p.partner.depth
	inp.interact.pressed = true; inp.interact.held = true
	p:update(DT, inp)
	inp.interact.pressed = false; inp.interact.held = false
	fe:renderPlay(DT, p, inp, 1280, 720)
	for _ = 1, 70 do
		p:update(DT, inp)
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	check("2.3a P03 在第 70 拍仍保持特写且 D01 实机可见",
		p.phase == "prologue-give" and cuffPl:getDebugState().activeShot == "P03"
		and hasVisibleSubstr(fe, "替我揣怀里"),
		string.format("phase=%s tick=%d vis=%s", p.phase, p.phaseTick, table.concat(visibleTexts(fe), " | ")))

	for _ = 1, 115 do
		p:update(DT, inp)
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	check("2.3b P03 满 180 拍切入 prologue-follow 并续播 D02（不重复 D01）",
		p.phase == "prologue-follow" and fe.narrative:getActiveDialogue().id == "D02",
		"phase=" .. p.phase .. " dlg=" .. tostring(fe.narrative:getActiveDialogue().id))

	-- P04 跨房单次去重：序章触发一次，进 S1 不再重复触发
	p.player.x = p.ox + 520
	fe:renderPlay(DT, p, inp, 1280, 720)
	check("2.4a P04 在序章井庭墙根触发并持久记入 segments",
		proPl:getSnapshot().p04TriggeredOnce == true and r.story.segments["p04_wall_flash"] == true)

	local ps1 = new(playmod.Play, rooms.S1_CROSSROAD, nil, r)
	fe:bindPlay(ps1, 1280, 720)
	ps1.player.x = ps1.ox + 220
	fe:renderPlay(DT, ps1, inp, 1280, 720)
	check("2.4b 进入 S1 十字街不再重复触发 P04",
		proPl:getSnapshot().p04TriggeredOnce == false and proPl:getSnapshot().p04Active == false)

	-- S1 战后 D40 + C1 候检院对白 C1A/C1C
	ps1.player.x = ps1.ox + 960
	fe:renderPlay(DT, ps1, inp, 1280, 720)
	check("2.5a S1 战后(x>=920) 触发 D40/D41 对白",
		fe.narrative:getActiveDialogue().id == "D40" or hasVisibleSubstr(fe, "手上有血"),
		"dlg=" .. tostring(fe.narrative:getActiveDialogue().id))

	local pc1 = new(playmod.Play, rooms.C1_YARD, nil, r)
	fe:bindPlay(pc1, 1280, 720)
	pc1.player.x = pc1.ox + 320
	fe:renderPlay(DT, pc1, inp, 1280, 720)
	check("2.5b C1 候检院触发 C1A/C1B 对白",
		fe.narrative:getActiveDialogue().id == "C1A" and hasVisibleSubstr(fe, "院子堵死了"),
		"dlg=" .. tostring(fe.narrative:getActiveDialogue().id))

	root:cleanup()
end

-- ---------------------------------------------------------------- 3. 城门 P05(gate-farewell) -> G01(gate-count) 零撞车 + G05 D48 可见
do
	local root = Dora.Node()
	local fe = new(Frontend, root)
	fe.screen = "play"
	local inp = makeInput()
	local r = runmod.createRun(20261127, "official", runmod.createArchive())
	r.story.hp = 3; r.story.maxHp = 3; r.story.hpAtGate = 3; r.story.maxHpAtGate = 3
	local pg = new(playmod.Play, rooms.GATE_ROOM, nil, r)
	local g = pg.room.story.gate
	pg.hp = 3; pg.maxHp = 3; pg.hpAtGate = 3; pg.maxHpAtGate = 3
	pg.phase = "gate-send"
	pg.player.x = g.doorX
	pg.partner.x = g.doorX + 30
	fe:bindPlay(pg, 1280, 720)
	local gatePl = fe:getPlugin("fe-01-gate-transition")
	local cuffPl = fe:getPlugin("fe-01-cuff-shots")

	fe:renderPlay(DT, pg, inp, 1280, 720)
	inp.interact.pressed = true; inp.interact.held = true
	pg:update(DT, inp)
	inp.interact.pressed = false; inp.interact.held = false
	for _ = 1, 70 do
		pg:update(DT, inp)
		fe:renderPlay(DT, pg, inp, 1280, 720)
	end
	check("3.1 城门送别进入独立 gate-farewell，P05 独播且与 G01 零叠字",
		pg.phase == "gate-farewell"
		and cuffPl:getDebugState().activeShot == "P05"
		and gatePl:getDebugState().active == false
		and hasVisibleSubstr(fe, "慢慢数到二十")
		and not hasVisibleSubstr(fe, "「一……」"),
		string.format("phase=%s shot=%s vis=%s", pg.phase, tostring(cuffPl:getDebugState().activeShot), table.concat(visibleTexts(fe), " | ")))

	-- 走完 gate-farewell 220 拍切入 gate-count 第 1 拍
	for _ = 1, 160 do
		pg:update(DT, inp)
		fe:renderPlay(DT, pg, inp, 1280, 720)
	end
	check("3.2 P05 演完无缝切入 gate-count，G01 独播且无 P05 残留叠字",
		pg.phase == "gate-count"
		and cuffPl:getDebugState().activeShot == ""
		and gatePl:getDebugState().active == true
		and hasVisibleSubstr(fe, "「一……」")
		and not hasVisibleSubstr(fe, "慢慢数到二十"),
		string.format("phase=%s tick=%d vis=%s", pg.phase, pg.countTick, table.concat(visibleTexts(fe), " | ")))

	-- 推进到 1440 拍进入男主线 gate-wait（G05）：D48 实机可见
	pg.countTick = playmod.GATE_COUNT_END - 2
	for _ = 1, 10 do
		pg:update(DT, inp)
		fe:renderPlay(DT, pg, inp, 1280, 720)
	end
	check("3.3 男主线 gate-wait(G05) 实机可见 D48(「小满——别数了。」)",
		pg.phase == "gate-wait" and hasVisibleSubstr(fe, "别数了"),
		string.format("phase=%s vis=%s", pg.phase, table.concat(visibleTexts(fe), " | ")))

	root:cleanup()
end

-- ---------------------------------------------------------------- 4. 北塔 door_open 过渡、无横幅重弹、D14->D16 与 M03 尾声 D55
do
	local root = Dora.Node()
	local fe = new(Frontend, root)
	fe.screen = "play"
	local inp = makeInput()

	-- 4A: 小满线低模北塔
	local rc = runmod.createRun(20261127, "official", runmod.createArchive())
	rc.story.route = "child"; rc.story.settled = true; rc.story.countTick = playmod.GATE_COUNT_END
	local ptc = new(playmod.Play, rooms.TOWER_ROOM, nil, rc)
	fe:bindPlay(ptc, 1280, 720)
	local twPl = fe:getPlugin("fe-05-tower-endings")
	local lpPl = fe:getPlugin("fe-04-child-lowpoly")

	ptc.player.x = ptc.ox + 445
	inp.interact.pressed = true; inp.interact.held = true
	ptc:update(DT, inp)
	fe:renderPlay(DT, ptc, inp, 1280, 720)
	inp.interact.pressed = false; inp.interact.held = false
	for _ = 1, 38 do
		ptc:update(DT, inp)
		fe:renderPlay(DT, ptc, inp, 1280, 720)
	end
	local stEnter = twPl:getDebugState()
	check("4.1 北塔门开：非阻塞提灯过渡可见、active=false、无章名横幅、先播 D14",
		ptc.phase == "tower-enter"
		and stEnter.doorOpened == true
		and stEnter.active == false
		and fe.narrative.bannerT == 0
		and lpPl:getDebugState().active == true
		and hasVisibleSubstr(fe, "推门提灯")
		and hasVisibleSubstr(fe, "外头何人")
		and not hasVisibleSubstr(fe, "叫什么名"),
		"vis=" .. table.concat(visibleTexts(fe), " | "))

	-- 跨门槛到桌前进入 tower-desk：再触发 D16(「叫什么名？」)
	ptc.player.x = ptc.ox + 560
	for _ = 1, 6 do
		ptc:update(DT, inp)
		fe:renderPlay(DT, ptc, inp, 1280, 720)
	end
	check("4.2 抵桌进 tower-desk 后再触发 D16(「叫什么名？」)",
		ptc.phase == "tower-desk" and hasVisibleSubstr(fe, "叫什么名"),
		"phase=" .. ptc.phase .. " vis=" .. table.concat(visibleTexts(fe), " | "))

	-- 4B: 男主团圆线 M03 尾声：phaseTick >= 200 后实机可见 D55(「哥，灯还亮着。」)
	local rs = runmod.createRun(20261127, "official", runmod.createArchive())
	rs.story.route = "soldier"; rs.story.settled = true; rs.story.segments["escort5"] = true
	local pts = new(playmod.Play, rooms.TOWER_ROOM, nil, rs)
	fe:bindPlay(pts, 1280, 720)
	pts.phase = "tower-end"
	pts.phaseTick = 202
	fe:renderPlay(DT, pts, inp, 1280, 720)
	check("4.3 男主团圆线尾声满 6.9s 后实机可见 D55(「哥，灯还亮着。」) 且无笔尖叠字",
		hasVisibleSubstr(fe, "灯还亮着") and not hasVisibleSubstr(fe, "笔尖停在第二行上方"),
		"vis=" .. table.concat(visibleTexts(fe), " | "))

	root:cleanup()
end

print(string.format("==== LIVE STAGING VERIFY PASS %d / FAIL %d ====", pass, fail))
assert(fail == 0, string.format("live staging verification failed (%d)", fail))
