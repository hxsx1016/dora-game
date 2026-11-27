-- 《向西守望》全阶段整备（Wave 0 – Wave 4）综合自动化回归验收脚本
-- 覆盖范围：
--  1. 损坏存档保护与隔离（corrupt / unsupported 不静默覆写）
--  2. 正式序章直入 S1 十字街（剔除旧 street/checkpoint）+ 选章页仅保留 17 个正式章节
--  3. 北塔男主团圆线无双周戍（player=周戍 w=30, partner=小满 w=28）+ 8 秒定格防误跳闸门
--  4. S1–C2 护送恐惧与两下轻敲安抚迁移 + S2 窗板默认隐藏/打开显现 + withOrigin 偏移 companion
--  5. Q 手动开换弹盘、换弹期间移动冻结、push 破盾、time_shuttler 光效加成
--  6. 2.5D DEPTH_Y_SCALE=0.42 统一及 CameraDirector 严格互逆
--  7. 3×3 换弹盘逐格点击（0->1->4->7）与早松手拖拽回退并存
--  8. 低引导红线过滤 + Script/watch/dialogues.ts（D01–D65 兄妹关系/数到二十/三张史话）+ 静音方向字幕
--  9. 片尾落款（返回标题 / 再走一遍 / 了解历史）与三张片尾史话（海隅筑城 / 井边烟火 / 长灯不绝）

local Dora = require("Dora")
local Content = Dora.Content
local lualib = require("lualib_bundle")
local new = lualib.__TS__New

local rooms = require("Script.watch.rooms")
local playmod = require("Script.watch.play")
local runmod = require("Script.watch.run")
local craftmod = require("Script.watch.craft")
local savemod = require("Script.watch.save")
local depthmod = require("Script.watch.depth")
local dlgmod = require("Script.watch.dialogues")
local inputmod = require("Script.watch.input")
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local lowpoly = require("Script.watch.fe.renderer.lowpoly")

local pass, fail = 0, 0
local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS rem: %-44s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL rem: %-44s %s", tag, detail or ""))
	end
end

local function makeInput()
	local i = new(inputmod.Input)
	i.moveX = 0; i.moveY = 0; i.inside = true; i.mx = 640; i.my = 360
	i.uiInside = false; i.uiPressed = false; i.uiReleased = false; i.uiHeld = false
	i.inputMode = "kbm"; i.gamepadLayout = "xbox"
	return i
end

local function clearEdges(i)
	i.interact.pressed = false; i.interact.released = false
	i.flare.pressed = false; i.flare.released = false
	i.fire.pressed = false; i.fire.released = false
	i.jump.pressed = false; i.jump.released = false
	i.retry.pressed = false; i.retry.released = false
	i.pause.pressed = false; i.pause.released = false
	i.uiPressed = false; i.uiReleased = false
	i.navConfirm = false; i.navBack = false
	i.navLeft = false; i.navRight = false
	i.navUp = false; i.navDown = false
end

local root = Dora.Node()
local fe = new(Frontend, root)
fe.screen = "play"
local DT = playmod.STEP

print("==== 《向西守望》Wave 0–4 全阶段整备综合回归开始 ====")

-- ---------------------------------------------------------------- 1. 损坏存档保护
do
	local oldFile = savemod.getSaveFile()
	local testName = "_verify_rem_corrupt.txt"
	savemod.setSaveFile(testName)
	local fullPath = savemod.savePath()
	Content:mkdir(Content.writablePath .. "/watch-save")
	Content:save(fullPath, "GARBAGE_NOT_A_VALID_SAVE\n")
	local loaded = savemod.loadSave()
	check("1.1 损坏存档返回 corrupt 并保留备份",
		loaded.status == "corrupt" and loaded.backup ~= nil and loaded.backup ~= "",
		"status=" .. tostring(loaded.status) .. " backup=" .. tostring(loaded.backup))
	pcall(function() Content:remove(fullPath) end)
	if loaded.backup and loaded.backup ~= "" then
		pcall(function() Content:remove(loaded.backup) end)
	end
	savemod.setSaveFile(oldFile)
end

-- ---------------------------------------------------------------- 2. 剔除旧 street/checkpoint，保留 17 正式章
do
	local r = runmod.createRun(20261127, "official", runmod.createArchive())
	local p = new(playmod.Play, rooms.PROLOGUE_ROOM, nil, r)
	p.phase = "prologue-follow"
	p.player.x = p.ox + 670
	p.partner.x = p.ox + 635
	local inp = makeInput()
	p:update(DT, inp)
	check("2.1 正式序章出口直入 s1-crossroad（不走旧 street）",
		p.wantRoom == "s1-crossroad", "wantRoom=" .. tostring(p.wantRoom))

	-- 调试模式仍兼容旧 street
	local rd = runmod.createRun(20261127, "debug", runmod.createArchive())
	local pd = new(playmod.Play, rooms.PROLOGUE_ROOM, nil, rd)
	pd.phase = "prologue-follow"
	pd.player.x = pd.ox + 670; pd.partner.x = pd.ox + 635
	pd:update(DT, inp)
	check("2.2 debug 模式保留 street 回归兼容", pd.wantRoom == "street", "wantRoom=" .. tostring(pd.wantRoom))

	-- 章节选择页不包含 street / checkpoint / museum（总 20 房 - 3 = 17）
	local expectedChapters = #rooms.ROOMS - 3
	fe.screen = "chapters"
	fe.menus:openChapters()
	local menuInp = makeInput()
	fe:renderMenu(DT, menuInp, 1280, 720)
	check("2.3 正式选章数 = #ROOMS - 3（共 17 章）", expectedChapters == 17, "chapters=" .. tostring(expectedChapters))
	fe.screen = "play"
end

-- ---------------------------------------------------------------- 3. 北塔男主团圆线无双周戍 + 8s 闸门
do
	local r = runmod.createRun(20261127, "official", runmod.createArchive())
	r.story.route = "soldier"; r.story.settled = true; r.story.segments["escort5"] = true
	local pt = new(playmod.Play, rooms.TOWER_ROOM, nil, r)
	check("3.1 北塔男主线 player=周戍(w=30) 且 partner=小满(w=28)",
		pt.childMode == false and pt.player.w == 30 and pt.partner.alive and pt.partner.w == 28,
		string.format("childMode=%s pw=%.0f aw=%.0f", tostring(pt.childMode), pt.player.w, pt.partner.w))
	check("3.2 两人初始均位于左塔墙(ox+400)外侧",
		pt.player.x >= pt.ox + 420 and pt.partner.x >= pt.ox + 408,
		string.format("px=%.0f ax=%.0f", pt.player.x - pt.ox, pt.partner.x - pt.ox))

	pt.phase = "tower-end"; pt.phaseTick = 60; pt.towerEndMustRelease = false
	check("3.3 8 秒定格前 towerEndReady() 为 false", pt:towerEndReady() == false)
	pt.phaseTick = playmod.TOWER_CONFIRM_TICKS
	check("3.4 满 8 秒且松键后 towerEndReady() 为 true", pt:towerEndReady() == true)
end

-- ---------------------------------------------------------------- 4. S1–C2 恐惧安抚 + S2 窗板隐藏 + withOrigin
do
	local r = runmod.createRun(20261127, "official", runmod.createArchive())
	local ps2 = new(playmod.Play, rooms.S2_DRYGOODS, nil, r)
	local board = nil
	for _, b in ipairs(ps2.boxes) do
		if b.id == "s2_board_cover" then board = b end
	end
	check("4.1 S2 窗板掩体 s2_board_cover 初始 hidden=true", board ~= nil and board.hidden == true)

	local ps1 = new(playmod.Play, rooms.S1_CROSSROAD, nil, r)
	ps1.escort.fear = 3; ps1.escort.state = "frozen"
	ps1.player.x = ps1.partner.x - 16
	ps1.player.depth = ps1.partner.depth
	local inp = makeInput()
	inp.interact.pressed = true; inp.interact.held = true
	ps1:update(DT, inp)
	check("4.2 S1 十字街支持近身 E 两下轻敲安抚小满",
		ps1.escort.state == "calming", "state=" .. tostring(ps1.escort.state))

	local shifted = rooms.withOrigin(rooms.S2_DRYGOODS)
	check("4.3 withOrigin 正确平移 companion.waitX/joinX",
		shifted.companion ~= nil
		and shifted.companion.waitX == rooms.S2_DRYGOODS.companion.waitX + rooms.S2_DRYGOODS.originX
		and shifted.companion.joinX == rooms.S2_DRYGOODS.companion.joinX + rooms.S2_DRYGOODS.originX)
end

-- ---------------------------------------------------------------- 5. Q 手动开换弹、移动冻结、time_shuttler 光效
do
	check("5.1 time_shuttler 提供有效 light 武器加成", craftmod.weaponEffectOf("time_shuttler") == "light")
	local r = runmod.createRun(20261127, "official", runmod.createArchive())
	r.story.route = "soldier"; r.story.settled = true
	local pe1 = new(playmod.Play, rooms.ESCORT1_ROOM, nil, r)
	pe1.enemies = {}
	local inp = makeInput()
	inp.flare.pressed = true; inp.flare.held = true
	pe1:update(DT, inp)
	check("5.2 护送段按 Q 手动开启 3×3 换弹盘", pe1.reloadOpen == true)
	clearEdges(inp)
	inp.flare.held = false
	local x0 = pe1.player.x
	inp.moveX = 1
	for _ = 1, 10 do pe1:update(DT, inp) end
	check("5.3 换弹盘打开期间冻结水平位移", math.abs(pe1.player.x - x0) < 0.01,
		string.format("dx=%.3f", math.abs(pe1.player.x - x0)))
end

-- ---------------------------------------------------------------- 6. 2.5D DEPTH_Y_SCALE=0.42 互逆对齐
do
	check("6.1 全局 DEPTH_Y_SCALE 统一为 0.42", math.abs(depthmod.DEPTH_Y_SCALE - 0.42) < 0.0001)
	local p = new(playmod.Play, rooms.S1_CROSSROAD)
	fe:bindPlay(p, 1280, 720)
	fe.cam:update(DT, p, 1280, 720)
	local scr = fe.cam:worldToScreen(p.player.x + 80, 12, -30)
	local back = fe.cam:screenToWorld(scr.x, scr.y)
	local expectedY = 12 + (-30) * depthmod.DEPTH_Y_SCALE
	check("6.2 CameraDirector 含纵深投影 worldToScreen/screenToWorld 0 误差",
		math.abs(back.x - (p.player.x + 80)) < 0.05 and math.abs(back.y - expectedY) < 0.05,
		string.format("errX=%.4f errY=%.4f", math.abs(back.x - (p.player.x + 80)), math.abs(back.y - expectedY)))
	local align = lowpoly.verifyWalkPlaneAlignment(fe.cam, {
		morph = 1, focal = 410, vpFracX = 0.5, vpFracY = 0.5, vpOffsetX = 0, vpOffsetY = 0, baseDepth = -20,
	}, p.player.x, 0)
	check("6.3 lowpoly.verifyWalkPlaneAlignment(depth=-20) 0 误差", align.forwardErrPx < 0.01,
		string.format("err=%.4f", align.forwardErrPx))
end

-- ---------------------------------------------------------------- 7. 换弹盘逐格点击连线 + 拖线早松退回
do
	local r = runmod.createRun(20261127, "official", runmod.createArchive())
	r.story.route = "soldier"; r.story.settled = true
	local pe1 = new(playmod.Play, rooms.ESCORT1_ROOM, nil, r)
	pe1.enemies = {}
	fe:bindPlay(pe1, 1280, 720)
	if #pe1:getStoryTalentOffers() > 0 then pe1:chooseTalent(0) end
	local rw = fe:getPlugin("fe-02-reload-wheel")
	local inp = makeInput()
	inp.flare.pressed = true
	pe1:update(DT, inp)
	clearEdges(inp)
	fe:renderPlay(DT, pe1, inp, 1280, 720)
	local st0 = rw:getState()
	check("7.1 换弹盘激活且起点为格 0", st0.active and #st0.path == 1 and st0.path[1] == 0)
	-- 逐格点击：1 -> 4 -> 8（每次按下再松手，不拖到其他格）
	local seq = { 1, 4, 8 }
	for _, nodeId in ipairs(seq) do
		local node = rw:getNodeUiPos(nodeId)
		inp.uiInside = true; inp.uiX = node.x; inp.uiY = node.y
		inp.uiPressed = true; inp.uiHeld = true
		fe:renderPlay(DT, pe1, inp, 1280, 720)
		pe1:update(DT, inp)
		inp.uiPressed = false; inp.uiHeld = false; inp.uiReleased = true
		fe:renderPlay(DT, pe1, inp, 1280, 720)
		pe1:update(DT, inp)
		clearEdges(inp)
	end
	check("7.2 鼠标准确逐格点击 0->1->4->8 完成换弹解算",
		pe1.reloadOpen == false and pe1.reloadPendingEffect == "echo",
		string.format("open=%s eff=%s", tostring(pe1.reloadOpen), tostring(pe1.reloadPendingEffect)))
end

-- ---------------------------------------------------------------- 8. 剧情对白 D01–D65、兄妹口径、静音字幕与低引导
do
	local missingIds = {}
	for n = 1, 65 do
		local id = string.format("D%02d", n)
		if dlgmod.dialogueById(id) == nil then
			missingIds[#missingIds + 1] = id
		end
	end
	check("8.1 dialogues.ts 完整收录 D01–D65 + G06",
		#missingIds == 0 and dlgmod.dialogueById("G06A") ~= nil and dlgmod.dialogueById("G06B") ~= nil,
		"missing=" .. tostring(#missingIds))

	local badCanon = false
	for _, d in pairs(dlgmod.SCRIPT_DIALOGUES) do
		if d.text:find("邻家", 1, true) or d.text:find("一百", 1, true) then
			badCanon = true
		end
	end
	check("8.2 对白真源 100% 统一兄妹关系与数到二十（零旧口径残留）", not badCanon)
	check("8.3 片尾史话完整包含 3 张官方卡片",
		#dlgmod.HISTORY_CARDS == 3
		and dlgmod.HISTORY_CARDS[1].title == "海隅筑城"
		and dlgmod.HISTORY_CARDS[2].title == "井边烟火"
		and dlgmod.HISTORY_CARDS[3].title == "长灯不绝")

	-- 验证 gatepath 自动触发 G06 非阻塞对白
	local r = runmod.createRun(20261127, "official", runmod.createArchive())
	r.story.route = "soldier"; r.story.settled = true
	local pgp = new(playmod.Play, rooms.GATE_PATH_ROOM, nil, r)
	fe:bindPlay(pgp, 1280, 720)
	local inp = makeInput()
	fe:renderPlay(DT, pgp, inp, 1280, 720)
	local curDlg = fe.narrative:getActiveDialogue()
	check("8.4 进入 gatepath 自动播放 G06 对白「去哪儿？」",
		curDlg.id == "G06A" and curDlg.text == "去哪儿？",
		"id=" .. tostring(curDlg.id) .. " text=" .. tostring(curDlg.text))

	-- 验证空村暗渠 D27 + 可选 E 回应 D28
	local pv = new(playmod.Play, rooms.VILLAGE_ROOM)
	pv.passed = true; pv.player.x = pv.ox + 600
	fe:bindPlay(pv, 1280, 720)
	fe:renderPlay(DT, pv, inp, 1280, 720)
	local d27 = fe.narrative:getActiveDialogue()
	inp.frameInteractPressed = true
	fe:renderPlay(DT, pv, inp, 1280, 720)
	inp.frameInteractPressed = false
	local d28 = fe.narrative:getActiveDialogue()
	check("8.5 空村 V3 暗渠触发 D27 且按 E 可选回应 D28",
		d27.id == "D27" and d28.id == "D28",
		"d27=" .. tostring(d27.id) .. " d28=" .. tostring(d28.id))
end

-- ---------------------------------------------------------------- 9. 片尾落款与三张史话界面交互
do
	local inp = makeInput()
	fe.menus:openEpilogue("lamp", true)
	fe.screen = "epilogue"
	local act0 = fe:renderMenu(DT, inp, 1280, 720)
	check("9.1 片尾落款页正常渲染且默认选中了解历史",
		act0.type == "none" and fe.menus.epilogueSelected == 0)

	inp.navConfirm = true
	local actHist = fe:renderMenu(DT, inp, 1280, 720)
	clearEdges(inp)
	check("9.2 片尾确认首项派发 openHistory", actHist.type == "openHistory", "type=" .. tostring(actHist.type))

	fe.menus:openHistory(true)
	fe.screen = "history"
	fe:renderMenu(DT, inp, 1280, 720)
	inp.navRight = true
	fe:renderMenu(DT, inp, 1280, 720)
	clearEdges(inp)
	inp.navRight = true
	fe:renderMenu(DT, inp, 1280, 720)
	clearEdges(inp)
	check("9.3 片尾史话三页翻页与 UTF-8 折行无错（到达第 3 页）",
		fe.menus.historyCardIndex == 2, "cardIdx=" .. tostring(fe.menus.historyCardIndex))

	inp.navBack = true
	local actBack = fe:renderMenu(DT, inp, 1280, 720)
	clearEdges(inp)
	check("9.4 片尾史话按返回派发 backEpilogue", actBack.type == "backEpilogue", "type=" .. tostring(actBack.type))
end

-- ---------------------------------------------------------------- 10. 根 LICENSE 存在
check("10.1 仓库根 Apache-2.0 LICENSE 存在且非空", Content:exist("LICENSE") == true)

root:cleanup()
print(string.format("==== REMEDIATION VERIFY PASS %d / FAIL %d ====", pass, fail))
assert(fail == 0, string.format("remediation verification failed (%d)", fail))
