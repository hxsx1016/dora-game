-- PR 5 专项验收：S1..C2 正式剧情接入 + 男主线 escort1..5 肉鸽三选一天赋 + 局中存档持久化
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
local app = require("Script.watch.app")
local Frontend = require("Script.watch.fe.frontend").WatchFrontend

local PASS, FAIL = 0, 0
local function check(tag, cond, detail)
	if cond then
		PASS = PASS + 1
		print("PASS pr5: " .. tag .. (detail and (" | " .. detail) or ""))
	else
		FAIL = FAIL + 1
		print("FAIL pr5: " .. tag .. (detail and (" | " .. detail) or ""))
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

print("== 1. ROOMS 20 房清单与 S1..C2 正式剧情流转 ==")
do
	local found = {}
	for _, r in ipairs(rooms.ROOMS) do
		found[r.key] = true
	end
	check("1.1 ROOMS 包含完整 20 房（含 S1..C2）",
		#rooms.ROOMS == 20 and found["s1-crossroad"] and found["s2-drygoods"]
		and found["s3-archway"] and found["c1-yard"] and found["c2-granary"],
		"count=" .. tostring(#rooms.ROOMS))

	-- 正式局 STREET 出口进入 s1-crossroad；调试单房仍去 checkpoint（保 verify-d8 兼容）
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

	-- 正式局 S1 -> S2 -> S3 -> C1 -> C2 -> gate 贯通，且 S2 掉血 1 点继承到 gate
	local pS1 = new(playmod.Play, rooms.S1_CROSSROAD, nil, rOff)
	pS1.enemies = {}
	pS1.player.x = pS1.room.campaign.exitX + 10
	pS1.partner.x = pS1.player.x - 40
	step(pS1, inp, 2)
	check("1.4 正式局 S1 出口衔接 S2", pS1.wantRoom == "s2-drygoods", "want=" .. tostring(pS1.wantRoom))

	local pS2 = new(playmod.Play, rooms.S2_DRYGOODS, nil, rOff)
	pS2.enemies = {}
	pS2.hp = 2 -- 模拟 S2 战损 1 点血
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

	-- 对照：独立试炼跑完 C2 仍按 finished=true 结算
	local rTrial = runmod.createTrial(67543212)
	local pTrialC2 = new(playmod.Play, rooms.C2_GRANARY, nil, rTrial)
	pTrialC2:chooseTalent(0)
	pTrialC2.enemies = {}
	pTrialC2.cartDocked = true
	pTrialC2.run.c2Latch = true
	pTrialC2.run.joined = true
	pTrialC2.player.x = pTrialC2.room.campaign.exitX + 10
	pTrialC2.partner.x = pTrialC2.player.x - 40
	step(pTrialC2, inp, 2)
	check("1.8 独立试炼模式 C2 仍正常结束试炼（不跳城门）",
		rTrial.finished == true and pTrialC2.wantRoom == "",
		string.format("fin=%s want=%s", tostring(rTrial.finished), tostring(pTrialC2.wantRoom)))
end

print("== 2. 男主线 escort1..5 肉鸽三选一天赋（确定性/非阻塞/四项实效/死亡重置） ==")
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
	check("2.1 男主线进 escort1 确定性抽出 3 张互异本领卡",
		#offA == 3 and offA[1] ~= offA[2] and offA[2] ~= offA[3] and offA[1] ~= offA[3]
		and table.concat(offA, ",") == table.concat(offB, ",")
		and table.concat(offA, ",") ~= table.concat(offC, ","),
		"offers=" .. table.concat(offA, ","))

	-- 非阻塞校验：未选天赋也能正常推进模拟拍与行走
	local inp = newInput()
	inp.moveX = 1
	local tBefore = pA.ticks
	step(pA, inp, 5)
	inp.moveX = 0
	check("2.2 正式男主线本领卡为非阻塞 HUD，不冻结既有行走与脚本",
		pA.ticks == tBefore + 5 and pA.player.x > 60,
		string.format("ticks=%d x=%.1f", pA.ticks, pA.player.x))

	-- 前端渲染 + 鼠标点击选卡测试
	local root = Dora.Node()
	local fe = new(Frontend, root)
	fe.screen = "play"
	fe:bindPlay(pA, 1280, 720)
	fe.audio:clearPlayLog()
	fe:renderPlay(playmod.STEP, pA, inp, 1280, 720)
	local rects = fe.hud:talentCardRects(1280, 720, #offA)
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
	check("2.3 鼠标点击 HUD 本领卡生效、清空候选并触发音效",
		clicked == true and #pA:getStoryTalentOffers() == 0
		and pA:getStoryTalentRanks()[pickedTalent] == 1 and pickedAudio == true,
		string.format("picked=%s audio=%s", tostring(pickedTalent), tostring(pickedAudio)))

	-- 同房重试不重复发卡；切到 escort2 发出新一轮 3 选 1
	local pA_retry = new(playmod.Play, rooms.ESCORT1_ROOM, nil, pA.run)
	local retryCount = #pA_retry:getStoryTalentOffers()
	local pE2 = new(playmod.Play, rooms.ESCORT2_ROOM, nil, pA.run)
	check("2.4 同房重试不刷卡，进 escort2 正常发新 3 选 1 且保留已习得等级",
		retryCount == 0 and #pA_retry:getStoryTalentOffers() == 0 and #pE2:getStoryTalentOffers() == 3
		and pE2:getStoryTalentRanks()[pickedTalent] == 1,
		string.format("retry=%d e2=%d", retryCount, #pE2:getStoryTalentOffers()))

	-- 四项天赋真实数值效果验证 + submitFeIntent(chooseTalent)
	local rEff = runmod.createRun(20261127, "official")
	rEff.story.route = "soldier"
	rEff.story.settled = true
	local pEff = new(playmod.Play, rooms.ESCORT2_ROOM, nil, rEff)
	pEff.enemies = {}
	-- 分别测试 vitality / reload / guard / craft
	rEff.story.talents.offers = { "vitality", "reload", "guard" }
	local okVit = pEff:submitFeIntent({ kind = "chooseTalent", slot = 0 })
	local hpAfterVit, maxHpAfterVit = pEff.hp, pEff.maxHp

	rEff.story.talents.offers = { "reload", "guard", "craft" }
	pEff:chooseTalent(0)
	local reloadWithRank1 = pEff:reloadTicks()

	rEff.story.talents.offers = { "guard", "craft", "vitality" }
	pEff:chooseTalent(0)
	rEff.story.talents.offers = { "craft", "vitality", "reload" }
	pEff:chooseTalent(0)

	-- 触发 craft 制楔（39 拍完成而非 45 拍）
	rEff.inventory.scrap = 1
	rEff.inventory.wedge = 0
	inp.interact.held = true
	inp.interact.pressed = true
	step(pEff, inp, 1)
	step(pEff, inp, 38)
	inp.interact.held = false
	local craftedAt39 = (rEff.inventory.wedge == 1)

	-- 跨房进北塔，验证厚甲血量上限保留；在 escort2 死亡回 escort1，验证天赋与厚甲上限重置
	local pTower = new(playmod.Play, rooms.TOWER_ROOM, nil, rEff)
	local towerMaxHp = pTower.maxHp
	pEff.hp = 0
	pEff:campaignFailed()
	local resetRanks = rEff.story.talents.ranks
	check("2.5 四项天赋实效成立（厚甲4/4、熟铳48拍、巧手39拍、死亡清零复位）",
		okVit and hpAfterVit == 4 and maxHpAfterVit == 4 and towerMaxHp == 4
		and reloadWithRank1 == 48 and craftedAt39 == true
		and pEff.wantRoom == "escort1" and rEff.story.maxHp == 3
		and resetRanks.vitality == 0 and resetRanks.reload == 0 and resetRanks.guard == 0 and resetRanks.craft == 0,
		string.format("vit=%d/%d towerMax=%d reload=%d craft39=%s resetMax=%d",
			hpAfterVit, maxHpAfterVit, towerMaxHp, reloadWithRank1, tostring(craftedAt39), rEff.story.maxHp))

	root:cleanup()
end

print("== 3. 扩展局中存档（S1..C2 状态 + 男主线肉鸽天赋跨重启续读） ==")
do
	local appRoot = Dora.Node()
	app.start(appRoot, 1, "title")
	local hook = package.loaded["watch.fe"]
	local TEST_SAVE = "watch-save/test-pr5-archive.txt"
	hook.useTestSave(TEST_SAVE)
	hook.clearSessionNow()

	local p0 = hook.startStory()
	local r = hook.getStoryRun()
	r.route = "drygoods"
	r.joined = true
	r.c1Latch = true
	r.c2Latch = true
	r.story.route = "soldier"
	r.story.settled = true
	r.story.hp = 4
	r.story.maxHp = 4
	r.story.talents.ranks.vitality = 1
	r.story.talents.ranks.reload = 2
	r.story.talents.room = "escort2"
	r.story.talents.offers = { "guard", "craft", "reload" }

	-- 切到 escort2 并落盘局中存档
	local e2Idx = 0
	for idx, rm in ipairs(rooms.ROOMS) do
		if rm.key == "escort2" then e2Idx = idx - 1 end
	end
	hook.jumpRoom("escort2")
	r.source = "official"
	local savedOk = hook.saveSessionNow()

	-- 模拟重启后点「继续游戏」
	local pCont = hook.continueStory()
	local rCont = hook.getStoryRun()
	check("3.1 局中存档完整保存并续读 S1..C2 进度与男主线肉鸽天赋",
		savedOk == true and pCont ~= nil and pCont.room.key == "escort2"
		and rCont.route == "drygoods" and rCont.joined == true and rCont.c1Latch == true and rCont.c2Latch == true
		and pCont.hp == 4 and pCont.maxHp == 4
		and rCont.story.talents.ranks.vitality == 1 and rCont.story.talents.ranks.reload == 2
		and #pCont:getStoryTalentOffers() == 3 and pCont:getStoryTalentOffers()[1] == "guard",
		string.format("saved=%s room=%s hp=%d/%d vit=%d rel=%d offers=%d",
			tostring(savedOk), pCont and pCont.room.key or "nil",
			pCont and pCont.hp or -1, pCont and pCont.maxHp or -1,
			rCont and rCont.story.talents.ranks.vitality or -1,
			rCont and rCont.story.talents.ranks.reload or -1,
			pCont and #pCont:getStoryTalentOffers() or -1))

	hook.clearSessionNow()
	hook.useTestSave("")
	appRoot:cleanup()
end

print(string.format("PR5 STORY & ROGUELIKE VERIFY PASS %d / FAIL %d", PASS, FAIL))
assert(FAIL == 0, string.format("PR5 验收失败 %d 项", FAIL))
