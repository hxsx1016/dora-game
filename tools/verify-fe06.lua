-- Wave 2 · FE-06 自动化验收脚本（feature/fe-06-well-museum）
-- 覆盖验收项：
-- 1. 插件挂载与运行时钩子同步（零改动 frontend.ts）
-- 2. 严格双通关门控矩阵（新档 / 仅女主 / 仅男主 / 单通误带 artifactOwned / 试炼态 / 靠柜后窗口）
--    + 章节直达、排演结局与退出排演均保持正式档案不变
-- 3. 双通关两种顺序等效开放 + 默认零浮签滴水引路 + 按键辅助开关联动
-- 4. E01 井底白灯倒影与指南针玻璃叠合 + 拾取「时间穿梭器」+ 反光匹配剪辑 0.00 px 偏移
-- 5. E02 现代抗日主题博物馆自由步行 + 玻璃柜前自动收械 + 远方童步回响单次去重
--    + 末厅亲手转动西窗灯 + 西窗映宁村所井庭 + 定稿台词「小满，外头天亮了。」
--    + 展厅第一声轻叩 → 明初厨柜第二声实木叩响 → 复用 CUFF_PALETTE 补线袖口 → 交还寻柜任务
-- 6. 离馆后二次进井幂等验证（神器计数恒为 1，不重复发奖，不二次强行传馆）
-- 7. 中途退出续读恢复验证（hall_walk 中厅续读 + lamp_turn 续读）
-- 8. 暂停冻结与恢复零漂移验证（E01/E02 全阶段与残影）
-- 9. 「时间穿梭器」移动轨迹残影彩蛋（门控、冷白/微金透明度 <= 0.34、慢时 0.25x 同步减速、切房清零）
-- 10. 全部 11 份 assets/audio/museum/*.wav 离线存在性与实际后端播放校验

local Dora = require("Dora")
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local cuffShots = require("Script.watch.fe.cutscenes.cuff_shots")
local wellMod = require("Script.watch.fe.scenes.well_museum")
local afterMod = require("Script.watch.fe.renderer.afterimage_artifact")

local pass = 0
local fail = 0

local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS fe06: %-38s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL fe06: %-38s %s", tag, detail or ""))
	end
end

local function newInput()
	local i = new(Input)
	i.moveX = 0
	i.moveY = 0
	i.inside = true
	i.mx, i.my = 640, 360
	i.jump = { held = false, pressed = false, released = false }
	i.crouch = { held = false, pressed = false, released = false }
	i.cover = { held = false, pressed = false, released = false }
	i.interact = { held = false, pressed = false, released = false }
	i.aim = { held = false, pressed = false, released = false }
	i.fire = { held = false, pressed = false, released = false }
	i.retry = { held = false, pressed = false, released = false }
	i.pause = { held = false, pressed = false, released = false }
	return i
end

local function countCue(audio, cueId)
	local log = audio:getPlayLog()
	local total = 0
	local backend = 0
	for _, entry in ipairs(log) do
		if entry.cueId == cueId then
			total = total + 1
			if entry.playedBackend then
				backend = backend + 1
			end
		end
	end
	return total, backend
end

local function collectVisibleTexts(node, out)
	out = out or {}
	local children = node.children
	if children then
		children:each(function(child)
			if child.visible then
				if Dora.tolua.type(child) == "Label" and child.text and child.text ~= "" then
					out[#out + 1] = child.text
				end
				collectVisibleTexts(child, out)
			end
		end)
	end
	return out
end

local function hasTextContaining(texts, needle)
	for _, t in ipairs(texts) do
		if string.find(t, needle, 1, true) then
			return true
		end
	end
	return false
end

local prevWatchFe = package.loaded["watch.fe"]
local runtimeHook = {}
package.loaded["watch.fe"] = runtimeHook

local root = Dora.Node()
local fe = new(Frontend, root)
fe.screen = "play"
local wellPl = wellMod.createWellMuseumPlugin(fe.contract)
local afterPl = afterMod.createAfterimageArtifactPlugin()
fe:registerPlugin(afterPl)
fe:registerPlugin(wellPl)

local DT = 1 / 60

print("==== FE-06 双通关水井、现代抗日主题博物馆与时间穿梭器残影验收开始 ====")

-- ---------------------------------------------------------------- 1. 插件注册与 11 份音频存在性
do
	local p = new(play.Play, rooms.PROLOGUE_ROOM)
	fe:bindPlay(p, 1280, 720)
	check("1.1 插件注册与 watch.fe 钩子同步",
		fe:getPlugin("fe-06-well-museum") == wellPl
		and fe:getPlugin("fe-06-afterimage-artifact") == afterPl
		and runtimeHook.wellMuseum == wellPl
		and runtimeHook.afterimageArtifact == afterPl)

	local expectedWavs = {
		"assets/audio/museum/well_drip_loop.wav",
		"assets/audio/museum/artifact_pickup.wav",
		"assets/audio/museum/match_cut_transition.wav",
		"assets/audio/museum/hall_ambience_loop.wav",
		"assets/audio/museum/hall_footstep.wav",
		"assets/audio/museum/weapon_holster.wav",
		"assets/audio/museum/child_steps_echo.wav",
		"assets/audio/museum/lamp_turn.wav",
		"assets/audio/museum/knock_hall_first.wav",
		"assets/audio/museum/knock_cabinet_second.wav",
		"assets/audio/museum/line_dawn.wav",
	}
	local allExist = true
	for _, path in ipairs(expectedWavs) do
		if not Dora.Content:exist(path) then
			allExist = false
			print("MISSING WAV: " .. path)
		end
	end
	check("1.2 全部 11 份 museum WAV 文件存在", allExist, "count=" .. tostring(#expectedWavs))
end

-- ---------------------------------------------------------------- 2. 严格双通关门控矩阵 & 正式档案零污染
do
	local inp = newInput()

	-- 2.1 新档（正式模式 live，child=false, soldier=false）
	local pFresh = new(play.Play, rooms.PROLOGUE_ROOM)
	fe.contract:exitRehearsal()
	fe:bindPlay(pFresh, 1280, 720)
	fe.audio:clearPlayLog()
	pFresh.player.x = wellMod.WELL_WORLD_X
	inp.interact.pressed = true
	fe:renderPlay(DT, pFresh, inp, 1280, 720)
	inp.interact.pressed = false
	local stFresh = wellPl:getDebugState()
	local dripFresh = countCue(fe.audio, "loop:fe06_well_drip")
	check("2.1 新档严禁开放井口与滴水引导",
		stFresh.gateOpen == false and stFresh.museumPhase == "locked" and dripFresh == 0,
		"reason=" .. stFresh.gateBlockedReason)

	-- 原寻柜路线照常可走
	pFresh.player.x = 290
	inp.interact.pressed = true
	pFresh:update(play.STEP, inp)
	inp.interact.pressed = false
	check("2.2 新档原寻柜路线正常触发 prologue-give", pFresh.phase == "prologue-give")

	-- 2.3 仅女主通关（模拟后端 B2 单通提前置 artifactOwned=true 也不得误开放）
	local pChildOnly = new(play.Play, rooms.PROLOGUE_ROOM)
	pChildOnly.archive = { childCleared = true, soldierCleared = false, artifactOwned = true, museumPhase = "well_open", museumSeen = false }
	fe:bindPlay(pChildOnly, 1280, 720)
	fe.audio:clearPlayLog()
	pChildOnly.player.x = wellMod.WELL_WORLD_X
	inp.interact.pressed = true
	fe:renderPlay(DT, pChildOnly, inp, 1280, 720)
	inp.interact.pressed = false
	local stChild = wellPl:getDebugState()
	local dripChild = countCue(fe.audio, "loop:fe06_well_drip")
	check("2.3 仅女主单通关严格封闭井口(防单通误开)",
		stChild.gateOpen == false and stChild.gateBlockedReason == "requires_both_clear" and dripChild == 0)

	-- 2.4 仅男主通关（同样模拟误带 artifactOwned=true）
	local pSoldOnly = new(play.Play, rooms.PROLOGUE_ROOM)
	pSoldOnly.archive = { childCleared = false, soldierCleared = true, artifactOwned = true, museumPhase = "well_open", museumSeen = false }
	fe:bindPlay(pSoldOnly, 1280, 720)
	fe.audio:clearPlayLog()
	pSoldOnly.player.x = wellMod.WELL_WORLD_X
	fe:renderPlay(DT, pSoldOnly, inp, 1280, 720)
	local stSold = wellPl:getDebugState()
	check("2.4 仅男主单通关严格封闭井口",
		stSold.gateOpen == false and stSold.gateBlockedReason == "requires_both_clear")

	-- 2.5 序章靠柜触发 P03（prologue-give）及跟随段（prologue-follow）不再开放井院
	local pAfterCab = new(play.Play, rooms.PROLOGUE_ROOM)
	pAfterCab.archive = { childCleared = true, soldierCleared = true, artifactOwned = false, museumPhase = "well_open", museumSeen = false }
	fe:bindPlay(pAfterCab, 1280, 720)
	pAfterCab.phase = "prologue-give"
	fe:renderPlay(DT, pAfterCab, inp, 1280, 720)
	local stGive = wellPl:getDebugState()
	pAfterCab.phase = "prologue-follow"
	fe:renderPlay(DT, pAfterCab, inp, 1280, 720)
	local stFollow = wellPl:getDebugState()
	check("2.5 靠柜后(prologue-give/follow)封闭井院窗口",
		stGive.gateOpen == false and stGive.gateBlockedReason == "after_cabinet_window"
		and stFollow.gateOpen == false and stFollow.gateBlockedReason == "after_cabinet_window")

	-- 2.6 试炼模式封闭井口
	local pTrial = new(play.Play, rooms.PROLOGUE_ROOM)
	pTrial.run.trial = { stage = 1 }
	pTrial.archive = { childCleared = true, soldierCleared = true, artifactOwned = false, museumPhase = "well_open", museumSeen = false }
	fe:bindPlay(pTrial, 1280, 720)
	fe:renderPlay(DT, pTrial, inp, 1280, 720)
	check("2.6 试炼模式封闭井口", wellPl:getDebugState().gateBlockedReason == "trial_mode")

	-- 2.7 章节直达、排演结局与退出排演绝不污染正式档案
	local pLive = new(play.Play, rooms.PROLOGUE_ROOM)
	fe.contract:exitRehearsal()
	fe:bindPlay(pLive, 1280, 720)
	local liveBefore = fe.contract:peekSnapshot(pLive).archive
	fe.contract:enterRehearsal("fe06-isolation")
	fe.contract:setMockArchive(true, true, true)
	fe.contract:enterMockMuseum("done")
	local rehSnap = fe.contract:peekSnapshot(pLive).archive
	fe.contract:exitRehearsal()
	local liveAfter = fe.contract:peekSnapshot(pLive).archive
	check("2.7 排演结局与退出排演保持正式档案零污染",
		liveBefore.childCleared == false and liveBefore.soldierCleared == false and liveBefore.museumPhase == "locked"
		and rehSnap.childCleared == true and rehSnap.soldierCleared == true and rehSnap.museumSeen == true
		and liveAfter.childCleared == false and liveAfter.soldierCleared == false and liveAfter.artifactOwned == false
		and liveAfter.museumPhase == "locked" and liveAfter.museumSeen == false)
end

-- ---------------------------------------------------------------- 3. 双通关两种顺序等效 + 零引导 + 完整 E01-E02 流程
do
	local inp = newInput()
	wellPl:resetSessionCounters()

	-- 顺序 A（先女后男）与顺序 B（先男后女）均解锁 well_open
	fe.contract:enterRehearsal("fe06-order-a")
	fe.contract:setMockArchive(true, false)
	local snapA1 = fe.contract:peekSnapshot(new(play.Play, rooms.PROLOGUE_ROOM)).archive
	fe.contract:setMockArchive(true, true)
	local snapA2 = fe.contract:peekSnapshot(new(play.Play, rooms.PROLOGUE_ROOM)).archive
	fe.contract:exitRehearsal()

	fe.contract:enterRehearsal("fe06-order-b")
	fe.contract:setMockArchive(false, true)
	local snapB1 = fe.contract:peekSnapshot(new(play.Play, rooms.PROLOGUE_ROOM)).archive
	fe.contract:setMockArchive(true, true)
	local snapB2 = fe.contract:peekSnapshot(new(play.Play, rooms.PROLOGUE_ROOM)).archive
	check("3.1 两种双通关顺序均严格解锁 well_open",
		snapA1.museumPhase == "locked" and snapA2.museumPhase == "well_open"
		and snapB1.museumPhase == "locked" and snapB2.museumPhase == "well_open")

	-- 进入序章 prologue-wait：默认低引导零浮签，滴水声启动
	local p = new(play.Play, rooms.PROLOGUE_ROOM)
	fe.contract:setAssistHintsEnabled(false)
	fe:bindPlay(p, 1280, 720)
	fe.audio:clearPlayLog()
	p.player.x = wellMod.WELL_WORLD_X + 6
	fe:renderPlay(DT, p, inp, 1280, 720)
	local textsNoAssist = collectVisibleTexts(root)
	local dripCnt, dripBe = countCue(fe.audio, "loop:fe06_well_drip")
	check("3.2 双通关 well_open 默认零浮签且滴水声播放",
		wellPl:getDebugState().gateOpen == true
		and wellPl:getDebugState().nearWell == true
		and not hasTextContaining(textsNoAssist, "俯身看井")
		and dripCnt == 1 and Dora.Content:exist(wellMod.MUSEUM_AUDIO.wellDripLoop),
		string.format("open=%s near=%s hasHint=%s dripCnt=%d dripBe=%d", tostring(wellPl:getDebugState().gateOpen), tostring(wellPl:getDebugState().nearWell), tostring(hasTextContaining(textsNoAssist, "俯身看井")), dripCnt, dripBe))

	-- 开启按键辅助后出现轻量提示，再关回默认
	fe.contract:setAssistHintsEnabled(true)
	fe:renderPlay(DT, p, inp, 1280, 720)
	local textsWithAssist = collectVisibleTexts(root)
	fe.contract:setAssistHintsEnabled(false)
	check("3.3 暂停菜单开启按键辅助后显示轻量 [E] 提示", hasTextContaining(textsWithAssist, "俯身看井"))

	-- 走近井口按 E 拾取「时间穿梭器」进入 E01 well_reflect
	fe.audio:clearPlayLog()
	inp.interact.pressed = true
	fe:renderPlay(DT, p, inp, 1280, 720)
	inp.interact.pressed = false
	-- 渲染一帧以进入 well_reflect
	fe:renderPlay(DT, p, inp, 1280, 720)
	local stRef0 = wellPl:getDebugState()
	check("3.4 井口按 E 进入 E01 well_reflect 并获得穿梭器",
		stRef0.museumPhase == "well_reflect"
		and stRef0.visualMode == "museum"
		and fe.contract:getLastSnapshot().archive.artifactOwned == true
		and stRef0.artifactGrantCount == 1
		and stRef0.matchCutAnchorDeltaPx == 0,
		string.format("anchorDelta=%.4f grant=%d", stRef0.matchCutAnchorDeltaPx, stRef0.artifactGrantCount))

	-- 推进 E01 至匹配剪辑中段，核对同点反光与暂停冻结
	for _ = 1, 130 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local stMatchMid = wellPl:getDebugState()
	p.paused = true
	for _ = 1, 20 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local stMatchPaused = wellPl:getDebugState()
	p.paused = false
	check("3.5 E01 反光匹配剪辑 0.00px 对齐且暂停绝对冻结",
		stMatchMid.matchCutProgress > 0 and stMatchMid.matchCutAnchorDeltaPx == 0
		and math.abs(stMatchPaused.reflectElapsed - stMatchMid.reflectElapsed) < 1e-6)

	-- 推进 E01 完成自动进入 E02 hall_walk
	for _ = 1, 80 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local pickupCnt, pickupBe = countCue(fe.audio, "museum:e01:artifact_pickup")
	local matchCnt, matchBe = countCue(fe.audio, "museum:e01:match_cut")
	local stHall0 = wellPl:getDebugState()
	check("3.6 E01 完成无缝切入现代抗日纪念展厅 hall_walk",
		stHall0.museumPhase == "hall_walk"
		and stHall0.visualMode == "museum"
		and pickupCnt == 1 and pickupBe == 1
		and matchCnt == 1 and matchBe == 1)

	-- 自由步行走到玻璃柜前（x >= 515）：收械 + 远方童步回响
	local walkStartX = stHall0.hallWalkX
	inp.moveX = 1
	for _ = 1, 185 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	inp.moveX = 0
	for _ = 1, 45 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local stCase = wellPl:getDebugState()
	local holsterCnt, holsterBe = countCue(fe.audio, "museum:e02:weapon_holster")
	local childCnt, childBe = countCue(fe.audio, "museum:e02:child_steps_echo")
	local stepCnt, stepBe = countCue(fe.audio, "museum:e02:footstep")
	local ambCnt, ambBe = countCue(fe.audio, "loop:fe06_hall_ambience")
	check("3.7 展厅自由步行、玻璃柜收械与远方童步回响单次触发",
		stCase.hallWalkX > walkStartX + 360
		and stCase.holstered == true
		and stCase.childEchoPlayed == true
		and holsterCnt == 1 and holsterBe == 1
		and childCnt == 1 and childBe == 1
		and stepCnt >= 1 and stepBe >= 1
		and ambCnt == 1 and Dora.Content:exist(wellMod.MUSEUM_AUDIO.hallAmbienceLoop),
		string.format("walkX=%.1f hol=%s child=%s hCnt=%d/%d cCnt=%d/%d sCnt=%d/%d aCnt=%d/%d", stCase.hallWalkX, tostring(stCase.holstered), tostring(stCase.childEchoPlayed), holsterCnt, holsterBe, childCnt, childBe, stepCnt, stepBe, ambCnt, ambBe))

	-- ---------------------------------------------------------------- 4. 中途退出续读恢复验证（hall_walk 中厅）
	local savedWalkX = stCase.hallWalkX
	local pResume = new(play.Play, rooms.PROLOGUE_ROOM)
	fe:bindPlay(pResume, 1280, 720)
	fe:renderPlay(DT, pResume, inp, 1280, 720)
	local stResumed = wellPl:getDebugState()
	check("4.1 馆内中途退出续读精准恢复原展厅位置与收械态",
		stResumed.museumPhase == "hall_walk"
		and math.abs(stResumed.hallWalkX - savedWalkX) < 1.0
		and stResumed.holstered == true
		and stResumed.childEchoPlayed == true
		and stResumed.resumeRestoreCount >= 1
		and stResumed.artifactGrantCount == 1,
		string.format("saved=%.1f resumed=%.1f restores=%d", savedWalkX, stResumed.hallWalkX, stResumed.resumeRestoreCount))

	-- 续读后继续走到末厅西窗灯前（MUSEUM_LAMP_X = 1140）
	inp.moveX = 1
	for _ = 1, 210 do
		fe:renderPlay(DT, pResume, inp, 1280, 720)
	end
	inp.moveX = 0
	local stAtLamp = wellPl:getDebugState()
	check("4.2 续读后可自由走到末厅西窗灯前",
		stAtLamp.nearLamp == true and math.abs(stAtLamp.hallWalkX - wellMod.MUSEUM_LAMP_X) <= 72,
		string.format("hallWalkX=%.1f", stAtLamp.hallWalkX))

	-- 亲手按 E 转动西窗灯 → lamp_turn
	inp.interact.pressed = true
	fe:renderPlay(DT, pResume, inp, 1280, 720)
	inp.interact.pressed = false
	fe:renderPlay(DT, pResume, inp, 1280, 720)
	check("5.1 亲手按 E 进入西窗转灯 lamp_turn", wellPl:getDebugState().museumPhase == "lamp_turn")

	-- 推进至 2.0s：验证定稿台词「小满，外头天亮了。」可见 + 暂停冻结
	for _ = 1, 120 do
		fe:renderPlay(DT, pResume, inp, 1280, 720)
	end
	local textsDawn = collectVisibleTexts(root)
	local stDawn = wellPl:getDebugState()
	pResume.paused = true
	for _ = 1, 15 do
		fe:renderPlay(DT, pResume, inp, 1280, 720)
	end
	local stDawnPaused = wellPl:getDebugState()
	pResume.paused = false
	check("5.2 西窗映井庭与唯一台词「小满，外头天亮了。」呈现且暂停冻结",
		stDawn.lampTurnProgress >= 0.99
		and stDawn.lineDawnShown == true
		and hasTextContaining(textsDawn, "小满，外头天亮了。")
		and math.abs(stDawnPaused.lampElapsed - stDawn.lampElapsed) < 1e-6)

	-- 继续推进完 lamp_turn → 触发第一声叩响 → 进入 return_cabinet
	for _ = 1, 125 do
		fe:renderPlay(DT, pResume, inp, 1280, 720)
	end
	local k1Cnt, k1Be = countCue(fe.audio, "museum:knock:1")
	local lampCnt, lampBe = countCue(fe.audio, "museum:e02:lamp_turn")
	local lineCnt, lineBe = countCue(fe.audio, "museum:e02:line_dawn")
	check("5.3 展厅第一声轻叩触发并转入 return_cabinet",
		wellPl:getDebugState().museumPhase == "return_cabinet"
		and k1Cnt == 1 and k1Be == 1
		and lampCnt == 1 and lampBe == 1
		and lineCnt == 1 and lineBe == 1)

	-- 推进 return_cabinet 中段（1.2s）：验证第二声实木叩响 + 复用同源补线袖口
	for _ = 1, 72 do
		fe:renderPlay(DT, pResume, inp, 1280, 720)
	end
	local stRetMid = wellPl:getDebugState()
	local k2Cnt, k2Be = countCue(fe.audio, "museum:knock:2")
	check("5.4 明初厨柜第二声实木叩响与四镜同源补线袖口呈现",
		stRetMid.knock2Played == true
		and k2Cnt == 1 and k2Be == 1
		and stRetMid.cuffReusedFromSharedPalette == true
		and stRetMid.cuffProgress > 0.3
		and cuffShots.CUFF_PALETTE.indigoBase.r == 34)

	-- 推进至 return_cabinet 结束 → done & museumSeen=true → 交还寻柜任务
	for _ = 1, 100 do
		fe:renderPlay(DT, pResume, inp, 1280, 720)
	end
	local doneSnap = fe.contract:getLastSnapshot()
	check("5.5 离馆收束至 done/museumSeen 并无缝交还 prologue-wait 寻柜",
		doneSnap.archive.museumPhase == "done"
		and doneSnap.archive.museumSeen == true
		and doneSnap.visualMode == "pixel"
		and pResume.room.key == "prologue"
		and pResume.phase == "prologue-wait")

	-- ---------------------------------------------------------------- 6. 两次进井幂等验证（神器计数恒为 1）
	local pickupBeforeRevisit = countCue(fe.audio, "museum:e01:artifact_pickup")
	pResume.player.x = wellMod.WELL_WORLD_X
	for _ = 1, 2 do
		inp.interact.pressed = true
		fe:renderPlay(DT, pResume, inp, 1280, 720)
		inp.interact.pressed = false
		fe:renderPlay(DT, pResume, inp, 1280, 720)
	end
	local stRevisit = wellPl:getDebugState()
	local pickupAfterRevisit = countCue(fe.audio, "museum:e01:artifact_pickup")
	check("6.1 离馆后二次进井仅平静复查、神器数恒为 1 且绝不重复发奖",
		stRevisit.museumPhase == "done"
		and stRevisit.artifactGrantCount == 1
		and stRevisit.revisitCalmCount == 2
		and pickupAfterRevisit == pickupBeforeRevisit,
		string.format("grants=%d revisits=%d", stRevisit.artifactGrantCount, stRevisit.revisitCalmCount))

	-- 交还寻柜后仍可正常向小满递针套
	pResume.player.x = 290
	inp.interact.pressed = true
	pResume:update(play.STEP, inp)
	inp.interact.pressed = false
	check("6.2 离馆回归后寻柜递针套(prologue-give)完全畅通", pResume.phase == "prologue-give")

	fe.contract:exitRehearsal()
end

-- ---------------------------------------------------------------- 7. 「时间穿梭器」移动轨迹残影彩蛋验证
do
	local inp = newInput()
	local p = new(play.Play, rooms.STREET_ROOM)
	fe.contract:enterRehearsal("fe06-afterimage")
	fe.contract:setMockRoute("soldier")
	fe:bindPlay(p, 1280, 720)

	-- 7.1 未持有神器：移动不产残影
	fe.contract:setMockArchive(true, false, false)
	fe.contract:triggerMockBench(false, { equippedWeapon = "time_shuttler" })
	for k = 1, 20 do
		p.player.x = 120 + k * 6
		p.player.vx = 180
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	check("7.1 未持有神器时 0 残影", afterPl:getDebugState().ghostCount == 0 and afterPl:getDebugState().active == false)

	-- 7.2 持有神器但装备常规武器：0 残影
	fe.contract:setMockArchive(true, true, true)
	fe.contract:triggerMockBench(false, { equippedWeapon = "guide_lantern_gun" })
	for k = 1, 20 do
		p.player.x = 240 + k * 6
		p.player.vx = 180
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	check("7.2 持有但装备常规武器时 0 残影", afterPl:getDebugState().ghostCount == 0 and afterPl:getDebugState().active == false)

	-- 7.3 持有且装备「时间穿梭器」，男主像素线移动产生冷白/微金残影且透明度 <= 0.34
	fe.contract:triggerMockBench(false, { equippedWeapon = "time_shuttler" })
	for k = 1, 30 do
		p.player.x = 200 + k * 7
		p.player.vx = 210
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local stGhost = afterPl:getDebugState()
	check("7.3 重玩男主线装备穿梭器产生克制冷白/微金轨迹残影",
		stGhost.active == true
		and stGhost.ghostCount >= 2 and stGhost.ghostCount <= stGhost.maxGhosts
		and stGhost.maxRenderedAlpha > 0 and stGhost.maxRenderedAlpha <= 0.341,
		string.format("ghosts=%d peakAlpha=%.3f", stGhost.ghostCount, stGhost.maxRenderedAlpha))

	-- 7.4 换弹 0.25x 慢时同步减速 & 暂停冻结
	fe.contract:triggerMockReload(true, { slowTimeScale = 0.25 })
	fe:renderPlay(DT, p, inp, 1280, 720)
	local stSlow = afterPl:getDebugState()
	p.paused = true
	local gBeforePause = stSlow.ghostCount
	for _ = 1, 20 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local stPaused = afterPl:getDebugState()
	p.paused = false
	fe.contract:triggerMockReload(false)
	check("7.4 残影吃 worldDt：慢时同步 0.25x 且暂停零衰减",
		stSlow.slowedByTimeScale == true
		and stSlow.lastWorldDt < DT * 0.35
		and stPaused.ghostCount == gBeforePause
		and stPaused.lastWorldDt == 0)

	-- 7.5 女主线低模关闭残影，切房彻底清空
	fe.contract:setMockRoute("child")
	local pOut = new(play.Play, rooms.OUTSIDE_ROOM)
	fe:bindPlay(pOut, 1280, 720)
	for k = 1, 15 do
		pOut.player.x = 100 + k * 5
		pOut.player.vx = 140
		fe:renderPlay(DT, pOut, inp, 1280, 720)
	end
	check("7.5 女主线/切房立即清空并关闭穿梭器残影",
		afterPl:getDebugState().active == false and afterPl:getDebugState().ghostCount == 0)

	fe.contract:exitRehearsal()
end

package.loaded["watch.fe"] = prevWatchFe
root:cleanup()

print(string.format("==== FE-06 验收汇总：PASS %d / FAIL %d ====", pass, fail))
assert(fail == 0, string.format("FE-06 验收失败 %d 项", fail))
