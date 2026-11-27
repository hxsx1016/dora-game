-- 男主线肉鸽主线整合专项验收：
-- 1. 上卷 S1..C2 正式剧情流转 + 独立试炼下线验证；
-- 2. 下卷男主线（escort1..5）肉鸽系统：
--    - 确定性 8 本领池三选一 + 宋明折笺轻暂停 + 武器加权（escort3 延后至工台离台后）；
--    - 遭遇变体轮换（ESCORT_VARIANTS）；
--    - 全部 8 项本领真实战斗效果（厚甲/护身/疾步/凝神/震推/广响/明焰/拾荒）+ 便携盾/随地布楔；
--    - 「折返山道」轮回小结 + 轮次推进派生新种子 + 掉落/木楔彻底清零；
--    - 正式男主线 R/暂停重开防 S/L 机制 + 章节直达自动建线；
-- 3. 局中存档新旧格式持久化与旧 4 本领字段平滑迁移。
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

local new = require("Script.Lib.lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local playmod = require("Script.watch.play")
local runmod = require("Script.watch.run")
local savemod = require("Script.watch.save")
local inputmod = require("Script.watch.input")
local app = require("Script.watch.app")
local Frontend = require("Script.watch.fe.frontend").WatchFrontend

local PASS, FAIL = 0, 0
local function check(tag, cond, detail)
	if cond then
		PASS = PASS + 1
		print("PASS roguelike: " .. tag .. (detail and (" | " .. detail) or ""))
	else
		FAIL = FAIL + 1
		print("FAIL roguelike: " .. tag .. (detail and (" | " .. detail) or ""))
	end
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

local function step(p, inp, n)
	for _ = 1, (n or 1) do
		p:update(playmod.STEP, inp)
		inp.interact.pressed = false
		inp.jump.pressed = false
		inp.fire.pressed = false
		inp.pause.pressed = false
	end
end

print("== 1. ROOMS 20 房清单、S1..C2 正式剧情流转与独立试炼下线 ==")
do
	local found = {}
	for _, r in ipairs(rooms.ROOMS) do
		found[r.key] = true
	end
	check("1.1 ROOMS 包含完整 20 房（含 S1..C2）",
		#rooms.ROOMS == 20 and found["s1-crossroad"] and found["s2-drygoods"]
		and found["s3-archway"] and found["c1-yard"] and found["c2-granary"],
		"count=" .. tostring(#rooms.ROOMS))

	local rOff = runmod.createRun(20261127, "official")
	local pStreetOff = new(playmod.Play, rooms.STREET_ROOM, nil, rOff)
	local inp = newInput()
	pStreetOff.player.x = 920
	pStreetOff.partner.x = 880
	step(pStreetOff, inp, 2)
	check("1.2 正式局街道出口衔接 S1 十字街", pStreetOff.wantRoom == "s1-crossroad", "want=" .. tostring(pStreetOff.wantRoom))

	local pStreetDbg = new(playmod.Play, rooms.STREET_ROOM)
	pStreetDbg.player.x = 920
	pStreetDbg.partner.x = 880
	step(pStreetDbg, inp, 2)
	check("1.3 调试单房街道出口保持兼容 checkpoint", pStreetDbg.wantRoom == "checkpoint", "want=" .. tostring(pStreetDbg.wantRoom))

	local pS1 = new(playmod.Play, rooms.S1_CROSSROAD, nil, rOff)
	pS1.enemies = {}
	pS1.player.x = pS1.room.campaign.exitX + 10
	pS1.partner.x = pS1.player.x - 40
	step(pS1, inp, 2)
	check("1.4 正式局 S1 出口衔接 S2", pS1.wantRoom == "s2-drygoods", "want=" .. tostring(pS1.wantRoom))

	local pS2 = new(playmod.Play, rooms.S2_DRYGOODS, nil, rOff)
	pS2.enemies = {}
	pS2.hp = 2
	pS2.run.route = "drygoods"
	pS2.run.joined = true
	pS2.player.x = pS2.room.campaign.exitX + 10
	pS2.partner.x = pS2.player.x - 40
	step(pS2, inp, 2)
	check("1.5 正式局 S2 战损血量与路线写回并接 S3",
		pS2.wantRoom == "s3-archway" and rOff.story.hp == 2 and rOff.route == "drygoods",
		string.format("want=%s hp=%d route=%s", tostring(pS2.wantRoom), rOff.story.hp, tostring(rOff.route)))

	local pC1 = new(playmod.Play, rooms.C1_YARD, nil, rOff)
	pC1.enemies = {}
	pC1.run.c1Latch = true
	pC1.run.joined = true
	pC1.objectiveDone = true
	pC1.player.x = pC1.room.campaign.exitX + 10
	pC1.partner.x = pC1.player.x - 40
	step(pC1, inp, 2)
	check("1.6 正式局 C1 抬闩后出口接 C2 且继承 2/3 血",
		pC1.wantRoom == "c2-granary" and pC1.hp == 2,
		string.format("want=%s hp=%d", tostring(pC1.wantRoom), pC1.hp))

	local pC2 = new(playmod.Play, rooms.C2_GRANARY, nil, rOff)
	pC2.enemies = {}
	pC2.cartDocked = true
	pC2.run.c2Latch = true
	pC2.run.joined = true
	pC2.player.x = pC2.room.campaign.exitX + 10
	pC2.partner.x = pC2.player.x - 40
	step(pC2, inp, 2)
	check("1.7 正式局 C2 完结自动转入城门 gate 且不提前置 finished",
		pC2.wantRoom == "gate" and rOff.finished == false and rOff.story.hp == 2,
		string.format("want=%s fin=%s hp=%d", tostring(pC2.wantRoom), tostring(rOff.finished), rOff.story.hp))

	check("1.8 独立试炼管线已下线（无 createTrial，8 项男主线本领就绪）",
		runmod.createTrial == nil and #runmod.ALL_TALENTS == 8,
		"talents=" .. tostring(#runmod.ALL_TALENTS))
end

print("== 2. 男主线 escort1..5 肉鸽闭环（折笺轻暂停/工台后选卡/遭遇变体/8本领实效/折返山道） ==")
do
	local function draftFor(seed)
		local r = runmod.createRun(seed, "official")
		r.story.route = "soldier"
		r.story.settled = true
		local p = new(playmod.Play, rooms.ESCORT1_ROOM, nil, r)
		return p, p:getStoryTalentOffers()
	end
	local pA, offA = draftFor(20261127)
	local _, offB = draftFor(20261127)
	local _, offC = draftFor(998877)
	check("2.1 男主线进 escort1 确定性从 8 本领池抽出 3 张互异卡",
		#offA == 3 and offA[1] ~= offA[2] and offA[2] ~= offA[3] and offA[1] ~= offA[3]
		and table.concat(offA, ",") == table.concat(offB, ",")
		and table.concat(offA, ",") ~= table.concat(offC, ","),
		"offers=" .. table.concat(offA, ","))

	-- 遭遇变体轮换校验：不同种子/轮次可在 3 套预校验阵型间切换，debug 恒为变体 0
	local seenVariants = {}
	for s = 1, 18 do
		local v = runmod.pickEscortVariant(s * 1009, 1, "escort1", 3)
		seenVariants[v] = true
	end
	local vCount = 0
	for _ in pairs(seenVariants) do vCount = vCount + 1 end
	local rDbg = runmod.createRun(99991, "debug")
	rDbg.story.route = "soldier"
	rDbg.story.settled = true
	local pDbg = new(playmod.Play, rooms.ESCORT1_ROOM, nil, rDbg)
	check("2.1b 遭遇变体按种子覆盖全部 3 套阵型，debug 保持默认阵型 0",
		vCount == 3 and rDbg.story.talents.variant == 0 and #pDbg.enemies == #rooms.ESCORT1_ROOM.spawns,
		string.format("variants=%d dbgVar=%d", vCount, rDbg.story.talents.variant))

	-- 2.2 独立 new Play 保持非阻塞兼容无头脚本；bindPlay 后启用折笺轻暂停并在选毕恢复
	local inp = newInput()
	inp.moveX = 1
	local tHeadless = pA.ticks
	step(pA, inp, 4)
	inp.moveX = 0
	check("2.2a 无头 Play 未 bindPlay 时不锁模拟拍（兼容存量测试）",
		pA.talentModalActive == false and pA.ticks == tHeadless + 4,
		string.format("modal=%s ticks=%d", tostring(pA.talentModalActive), pA.ticks))

	local root = Dora.Node()
	local fe = new(Frontend, root)
	fe.screen = "play"
	fe:bindPlay(pA, 1280, 720)
	local tModalBefore = pA.ticks
	inp.moveX = 1
	step(pA, inp, 4)
	inp.moveX = 0
	check("2.2b 前端绑定后展开宋明折笺轻暂停，选卡前冻结世界拍",
		pA.talentModalActive == true and pA.ticks == tModalBefore,
		string.format("modal=%s ticks=%d/%d", tostring(pA.talentModalActive), pA.ticks, tModalBefore))

	-- 2.3 点击居中宋明折笺卡习得本领、解除轻暂停并播音效
	fe.audio:clearPlayLog()
	fe:renderPlay(playmod.STEP, pA, inp, 1280, 720)
	local rects = fe:getStoryTalentBoxes(pA, 1280, 720, false)
	local pickedTalent = offA[2]
	inp.inside = true
	inp.mx = rects[2].x + rects[2].width * 0.5
	inp.my = rects[2].y + rects[2].height * 0.5
	inp.fire.pressed = true
	local clicked = fe:tryPickTalentAtPointer(pA, inp, 1280, 720)
	inp.fire.pressed = false
	fe:renderPlay(playmod.STEP, pA, inp, 1280, 720)
	local pickedAudio = false
	for _, entry in ipairs(fe.audio:getPlayLog()) do
		if entry.cueId == "story:talent_picked" then pickedAudio = true end
	end
	local tAfterPick = pA.ticks
	step(pA, inp, 2)
	check("2.3 点击居中折笺生效、解除轻暂停、推进世界并触发音效",
		clicked == true and #pA:getStoryTalentOffers() == 0
		and pA.talentModalActive == false and pA.ticks == tAfterPick + 2
		and pA:getStoryTalentRanks()[pickedTalent] == 1 and pickedAudio == true,
		string.format("picked=%s audio=%s", tostring(pickedTalent), tostring(pickedAudio)))

	-- 2.4 同房重试不刷卡；escort2 立即发卡；escort3 延后至工台离台后并受已佩武器加权
	local pA_retry = new(playmod.Play, rooms.ESCORT1_ROOM, nil, pA.run)
	local pE2 = new(playmod.Play, rooms.ESCORT2_ROOM, nil, pA.run)
	pE2:chooseTalent(0)
	pA.run.inventory.wood = 2
	pA.run.inventory.bell = 1
	local pE3 = new(playmod.Play, rooms.ESCORT3_ROOM, nil, pA.run)
	fe:bindPlay(pE3, 1280, 720)
	local deferredAtEntry = (#pE3:getStoryTalentOffers() == 0 and pA.run.story.talents.deferred == true and not pE3.talentModalActive)
	pE3:openCraftBench()
	pE3:craftAtBench("echo_gun", "req-verify-e3-1")
	pE3:closeCraftBench()
	local offersAfterBench = pE3:getStoryTalentOffers()
	check("2.4 同房不刷卡，escort3 入段延后选卡并在工台离台后自动弹出 3 选 1 折笺",
		#pA_retry:getStoryTalentOffers() == 0 and deferredAtEntry == true
		and #offersAfterBench == 3 and pE3.talentModalActive == true and pA.run.story.talents.deferred == false,
		"e3Offers=" .. table.concat(offersAfterBench, ","))

	-- 2.5 全部 8 项本领真实战斗效果验证 + 便携木盾/随地布楔
	local rEff = runmod.createRun(20261127, "official")
	rEff.story.route = "soldier"
	rEff.story.settled = true
	local pEff = new(playmod.Play, rooms.ESCORT2_ROOM, nil, rEff)
	pEff.enemies = {}

	-- (a) vitality 厚甲：+1/+1 HP 且跨房保留至北塔
	rEff.story.talents.offers = { "vitality", "guard", "stride" }
	local okVit = pEff:submitFeIntent({ kind = "chooseTalent", slot = 0 })
	local hpVit, maxHpVit = pEff.hp, pEff.maxHp

	-- (b) focus 凝神：3x3 换弹窗从 240 拍延长至 300 拍
	local baseNeed = pEff:reloadNeedTicks()
	rEff.story.talents.offers = { "focus", "guard", "stride" }
	pEff:chooseTalent(0)
	local focusNeed = pEff:reloadNeedTicks()

	-- (c) stride 疾步：护送态移动步距提升
	local x0 = pEff.player.x
	inp.moveX = 1
	step(pEff, inp, 10)
	local distBase = pEff.player.x - x0
	rEff.story.talents.offers = { "stride", "guard", "push_force" }
	pEff:chooseTalent(0)
	local x1 = pEff.player.x
	step(pEff, inp, 10)
	local distStride = pEff.player.x - x1
	inp.moveX = 0

	-- (d) guard 护身：护送战受击无敌延长（42 -> 57）
	rEff.story.talents.offers = { "guard", "push_force", "echo_wide" }
	pEff:chooseTalent(0)
	pEff.invulnT = 0
	pEff.coverHug = false
	pEff:campaignEnemyFire({ x = pEff.player.x + 120, y = 0, depth = pEff.player.depth, alive = true, h = 56 })
	local invulnGuard = pEff.invulnT

	-- (e) salvage 拾荒：立刻智能补 1 枚紧缺工台材料（木/铃），且男主线架盾（耐受=1+rank）与随地立木楔掩体可用
	local woodBefore, bellBefore = rEff.inventory.wood, rEff.inventory.bell
	rEff.story.talents.offers = { "salvage", "push_force", "lantern_pierce" }
	pEff:chooseTalent(0)
	local salvageGained = ((rEff.inventory.wood + rEff.inventory.bell) == (woodBefore + bellBefore + 1))
	pEff.player.x = pEff.ox + 180
	pEff.player.depth = 0
	rEff.inventory.wedge = 0
	rEff.inventory.shield = 1
	inp.interact.pressed = true
	step(pEff, inp, 1)
	local bracedOk = (pEff.bracedShield ~= nil)
	local shieldHp = pEff.bracedShield and pEff.bracedShield.hp or 0
	rEff.inventory.wedge = 1
	local boxesBeforeWedge = #pEff.boxes
	inp.interact.pressed = true
	step(pEff, inp, 1)
	local wedgeAdded = (#pEff.boxes == boxesBeforeWedge + 1 and rEff.inventory.wedge == 0)

	-- (f) lantern_pierce 明焰：即使持标准鸟铳，装填 light 也能盲化射线上邻近敌人（fireCd=150, warnT=0）
	rEff.story.talents.offers = { "lantern_pierce", "push_force", "echo_wide" }
	pEff:chooseTalent(0)
	local pShot = new(playmod.Play, rooms.ESCORT2_ROOM, nil, rEff)
	pShot.equippedWeapon = "standard_gun"
	pShot.reloadPendingEffect = "light"
	pShot.reloadT = 0
	pShot.boxes = {}
	pShot.player.x = pShot.ox + 120
	pShot.player.depth = 0
	pShot.player.facing = 1
	pShot.worldMapper = function(sx, sy) return { x = sx, y = sy } end
	local targetE = pShot.enemies[1]
	local neighborE = pShot.enemies[2]
	targetE.alive = true; targetE.x = pShot.player.x + 150; targetE.y = 0; targetE.depth = 0; targetE.shieldHp = 0
	neighborE.alive = true; neighborE.x = targetE.x + 120; neighborE.y = 0; neighborE.depth = 0; neighborE.warnT = 20; neighborE.fireCd = 10
	pShot.aimX = targetE.x
	pShot.aimY = targetE.y + targetE.h * 0.6
	inp.fire.pressed = true
	step(pShot, inp, 1)
	local blindedOnStandard = (not targetE.alive and neighborE.fireCd >= 145 and neighborE.warnT == 0)

	-- (g) push_force 震推 + echo_wide 广响：升级记录与北塔血量继承
	rEff.story.talents.offers = { "push_force", "echo_wide", "vitality" }
	pEff:chooseTalent(0)
	rEff.story.talents.offers = { "echo_wide", "vitality", "guard" }
	pEff:chooseTalent(0)
	local pTower = new(playmod.Play, rooms.TOWER_ROOM, nil, rEff)

	check("2.5 全部 8 项本领真实战斗效果与便携盾/野战木楔成立",
		okVit and hpVit == 4 and maxHpVit == 4 and pTower.maxHp == 4
		and baseNeed == 240 and focusNeed == 300
		and distStride > distBase
		and invulnGuard == 57
		and salvageGained and bracedOk and shieldHp >= 2 and wedgeAdded
		and blindedOnStandard
		and rEff.story.talents.ranks.push_force == 1 and rEff.story.talents.ranks.echo_wide == 1,
		string.format("vit=%d/%d need=%d->%d stride=%.1f>%.1f inv=%d shHp=%d wedge=%s blind=%s",
			hpVit, maxHpVit, baseNeed, focusNeed, distStride, distBase, invulnGuard, shieldHp, tostring(wedgeAdded), tostring(blindedOnStandard)))

	-- 2.6 「折返山道」轮回小结 + 确认重整：推进轮次、派生新种子、清空本领/拾取/木楔
	fe:bindPlay(pEff, 1280, 720)
	rEff.taken["escort2_drop_0"] = true
	rEff.taken["s1_keepsake"] = true
	local seedBefore = rEff.story.talents.randomState
	local attemptBefore = rEff.story.talents.attempt
	pEff.hp = 0
	pEff:campaignFailed()
	local summaryShown = (pEff.escortFailed == true and pEff.escortSummary ~= nil and pEff.wantRoom == "")
	fe:renderPlay(playmod.STEP, pEff, inp, 1280, 720)
	pEff:confirmEscortRestart()
	local resetRanks = rEff.story.talents.ranks
	check("2.6 折返山道小结延迟重开，确认后推进轮次、派生新种子并清净本轮掉落与本领",
		summaryShown == true and pEff.wantRoom == "escort1"
		and rEff.story.talents.attempt == attemptBefore + 1
		and rEff.story.talents.randomState ~= seedBefore
		and rEff.story.maxHp == 3 and resetRanks.vitality == 0 and resetRanks.focus == 0 and resetRanks.salvage == 0
		and rEff.taken["escort2_drop_0"] == nil and rEff.taken["s1_keepsake"] == true
		and rEff.props["field_wedge_escort2"] == nil,
		string.format("attempt=%d->%d seedChanged=%s want=%s",
			attemptBefore, rEff.story.talents.attempt, tostring(rEff.story.talents.randomState ~= seedBefore), tostring(pEff.wantRoom)))

	root:cleanup()
end

print("== 3. 正式入口统一、防 S/L、章节直达自动建线与扩展局中存档 ==")
do
	local appRoot = Dora.Node()
	app.start(appRoot, 1, "title")
	local hook = package.loaded["watch.fe"]
	local TEST_SAVE = "watch-save/test-pr5-archive.txt"
	hook.useTestSave(TEST_SAVE)
	hook.clearSessionNow()

	check("3.1 app 验收钩子不再暴露独立 startTrial", hook.startTrial == nil, "")

	-- 章节直达 escort1 自动初始化男主背负路线并给出 3 选 1 折笺
	local e1Idx = 0
	for idx, rm in ipairs(rooms.ROOMS) do
		if rm.key == "escort1" then e1Idx = idx - 1 end
	end
	local pChap = hook.previewChapter(e1Idx, 13579)
	check("3.2 章节直达 escort1 自动建立男主背负线并展开折笺",
		pChap ~= nil and pChap.storyRoute == "soldier" and pChap.run.story.carry == true
		and #pChap:getStoryTalentOffers() == 3 and pChap.talentModalActive == true,
		string.format("route=%s offers=%d", pChap and pChap.storyRoute or "nil", pChap and #pChap:getStoryTalentOffers() or -1))

	-- 正式局局中存档：写入 8 本领新格式、轮次与变体，重启后精确恢复
	hook.startStory(24680)
	local r = hook.getStoryRun()
	r.route = "drygoods"
	r.joined = true
	r.c1Latch = true
	r.c2Latch = true
	r.story.route = "soldier"
	r.story.settled = true
	r.story.hp = 4
	r.story.maxHp = 4
	r.story.talents.attempt = 3
	r.story.talents.variant = 2
	r.story.talents.ranks.vitality = 1
	r.story.talents.ranks.focus = 2
	r.story.talents.ranks.salvage = 1
	r.story.talents.room = "escort2"
	r.story.talents.offers = { "guard", "push_force", "lantern_pierce" }

	hook.jumpRoom("escort2")
	r.source = "official"
	local savedOk = hook.saveSessionNow()

	local pCont = hook.continueStory()
	local rCont = hook.getStoryRun()
	check("3.3 局中存档完整保存并续读 8 本领重数、轮次、变体与 S1..C2 进度",
		savedOk == true and pCont ~= nil and pCont.room.key == "escort2"
		and rCont.route == "drygoods" and rCont.joined == true and rCont.c1Latch == true and rCont.c2Latch == true
		and pCont.hp == 4 and pCont.maxHp == 4
		and rCont.story.talents.attempt == 3 and rCont.story.talents.variant == 2
		and rCont.story.talents.ranks.vitality == 1 and rCont.story.talents.ranks.focus == 2 and rCont.story.talents.ranks.salvage == 1
		and #pCont:getStoryTalentOffers() == 3 and pCont:getStoryTalentOffers()[2] == "push_force",
		string.format("saved=%s attempt=%d var=%d foc=%d sal=%d",
			tostring(savedOk), rCont and rCont.story.talents.attempt or -1,
			rCont and rCont.story.talents.variant or -1,
			rCont and rCont.story.talents.ranks.focus or -1,
			rCont and rCont.story.talents.ranks.salvage or -1))

	-- 正式男主线防 S/L 重开：调用 restartEscortRun 推进轮次并回第一段
	local attBeforeReset = rCont.story.talents.attempt
	pCont:restartEscortRun()
	check("3.4 正式男主线重开推进轮次并回第一段（关闭单段 S/L）",
		pCont.wantRoom == "escort1" and rCont.story.talents.attempt == attBeforeReset + 1
		and rCont.story.talents.ranks.focus == 0 and rCont.story.maxHp == 3,
		string.format("want=%s attempt=%d", tostring(pCont.wantRoom), rCont.story.talents.attempt))

	-- 旧版 4 本领字段兼容迁移（talentReload -> focus，talentCraft -> salvage）
	local legacyText = savemod.formatSession({
		version = 1, seed = 9999, roomKey = "escort2", checkpoint = 0,
		route = "soldier", hp = 3, maxHp = 3, hpAtGate = 3, maxHpAtGate = 3,
		settled = true, phase = "escort", countTick = 0, phaseTick = 0,
		handTicks = 0, handDone = true, lineSaid = true, tied = true, carry = true, escortDone = false,
		craftedWeapon = "standard", equippedWeapon = "standard",
		wood = 1, bell = 0, scrap = 0, wedge = 0, ammo = 0, shield = 0, pass = 0, quickbelt = 0,
		cartAxle = 0, cartDocked = false, taken = {}, segments = {},
		talentRoom = "escort2", talentVitality = 1, talentReload = 2, talentGuard = 1, talentCraft = 3,
		talentOffers = { "reload", "craft", "guard" },
	})
	local parsedLegacy = savemod.parseSession(legacyText)
	check("3.5 旧版 4 本领存档可解析且可平滑映射至新本领体系",
		parsedLegacy.status == "ok" and parsedLegacy.state ~= nil
		and parsedLegacy.state.talentReload == 2 and parsedLegacy.state.talentCraft == 3
		and runmod.normalizeLegacyTalent("reload") == "focus"
		and runmod.normalizeLegacyTalent("craft") == "salvage",
		"status=" .. tostring(parsedLegacy.status))

	hook.clearSessionNow()
	hook.useTestSave("")
	appRoot:cleanup()
end

print(string.format("ROGUELIKE STORY INTEGRATION VERIFY PASS %d / FAIL %d", PASS, FAIL))
assert(FAIL == 0, string.format("男主线肉鸽整合验收失败 %d 项", FAIL))
