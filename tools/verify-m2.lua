-- 《向西守望》前端 M2 合流全链路联合验收脚本（默认 11 插件自动装配 + 跨分支冲突与后端 C/D 对齐验收）
--
-- 用法（引擎项目上下文）：dofile("tools/verify-m2.lua")
-- 覆盖范围：
-- 1. WatchFrontend 默认构造按严格分层优先级自动注册全部 11 枚插件（M1 7 枚 + Wave 2 4 枚），零手动接线
-- 2. package.loaded["watch.fe"] 自动同步全部 11 枚插件实例及 contract / audio / getPlugin 钩子
-- 3. AudioDirector 五轨 AudioBus + AudioSource 真播放校验（playOnce 与 playLoop 均 playedBackend=true，含 gate/child/tower/museum 循环轨与 0.25x 慢时）
-- 4. 女主线全链路低模贯通（gate 24s -> outside -> village 硬砖/铁盆/软土零串音 -> forest 溪湾 -> tower 低模外景礼让 fe-05 F03 空行留白，零 HUD 透穿）
-- 5. 男主线全链路贯通（gate G05 像素回切 -> escort 背负/换弹慢时/工台 + 时间穿梭器冷白残影 + MING-06 翻滚无冰青冲突 -> tower M03 满行双手端碗）
-- 6. 四镜同源补线青布袖口一致性校验（P03 / P05 / G05 / E02 + M03 共用 CUFF_PALETTE 与 6 针口径）
-- 7. 双通关水井与现代博物馆闭环（严防单通误开、P01/P02 序章隔离、0px 反光匹配剪辑、hall_walk 中途续读、lamp_turn 定稿台词、return_cabinet 接回 prologue-give P03）
-- 8. 后端 C 单（story-c-archive）live 契约前向对齐：wellOpen/wellX/prologue-well、submitFeIntent wellPick 兜底、独立 MUSEUM_ROOM、artifactFound/museumStep 音频分轨
-- 9. 跨插件冲突隔离：AfterimageArtifact 在 lowpoly/museum 清零、LowpolyWorld 在 pixel/museum 静默、切房与退排演零残留

local Dora = require("Dora")
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local cuffShots = require("Script.watch.fe.cutscenes.cuff_shots")
local prologueMod = require("Script.watch.fe.cutscenes.prologue_intro")
local wellMod = require("Script.watch.fe.scenes.well_museum")
local theme = require("Script.watch.fe.theme")

local pass = 0
local fail = 0

local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS m2: %-38s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL m2: %-38s %s", tag, detail or ""))
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

local function countVisibleLabels(node)
	local count = 0
	local children = node.children
	if children then
		children:each(function(child)
			if child.visible then
				if Dora.tolua.type(child) == "Label" then
					count = count + 1
				end
				count = count + countVisibleLabels(child)
			end
		end)
	end
	return count
end

local prevWatchFe = package.loaded["watch.fe"]
local runtimeHook = {}
package.loaded["watch.fe"] = runtimeHook

local root = Dora.Node()
-- 严格使用默认构造：验证 M2 合流接线后无需任何手动 registerPlugin 即可完整驱动全部 11 枚插件
local fe = new(Frontend, root)
fe.screen = "play"
local DT = 1 / 60
local inp = newInput()

print("==== M2 前端合流全链路联合验收开始 ====")

-- ---------------------------------------------------------------- 1. 默认 11 插件优先级与运行时钩子
do
	local list = fe:getPlugins()
	local expectedIds = {
		"fe03-ming-audit",
		"fe-01-gate-transition",
		"fe-04-child-lowpoly",
		"fe-06-afterimage-artifact",
		"fe-02-carry-pose",
		"fe03-prologue-intro",
		"fe-01-cuff-shots",
		"fe-05-tower-endings",
		"fe-06-well-museum",
		"fe-02-reload-wheel",
		"fe-02-craft-bench",
	}
	local orderOk = (#list == #expectedIds)
	if orderOk then
		for idx, eid in ipairs(expectedIds) do
			if list[idx].id ~= eid then
				orderOk = false
				break
			end
		end
	end
	check("1.1 默认构造按分层优先级注册全部 11 枚插件", orderOk, "count=" .. tostring(#list))

	local p = new(play.Play, rooms.PROLOGUE_ROOM)
	fe:bindPlay(p, 1280, 720)
	check("1.2 watch.fe 自动同步全部 11 枚插件与底座钩子",
		runtimeHook.contract == fe.contract
		and runtimeHook.audio == fe.audio
		and runtimeHook.mingAudit == fe:getPlugin("fe03-ming-audit")
		and runtimeHook.gateTransition == fe:getPlugin("fe-01-gate-transition")
		and runtimeHook.lowpolyWorld == fe:getPlugin("fe-04-child-lowpoly")
		and runtimeHook.afterimageArtifact == fe:getPlugin("fe-06-afterimage-artifact")
		and runtimeHook.carryPose == fe:getPlugin("fe-02-carry-pose")
		and runtimeHook.prologue == fe:getPlugin("fe03-prologue-intro")
		and runtimeHook.cuffShots == fe:getPlugin("fe-01-cuff-shots")
		and runtimeHook.towerEndings == fe:getPlugin("fe-05-tower-endings")
		and runtimeHook.wellMuseum == fe:getPlugin("fe-06-well-museum")
		and runtimeHook.reloadWheel == fe:getPlugin("fe-02-reload-wheel")
		and runtimeHook.craftBench == fe:getPlugin("fe-02-craft-bench"))

	-- 全部 81 份离线音频资产目录可达（gate 30 + combat 11 + child 14 + tower 15 + museum 11）
	local sampleLoops = {
		"assets/audio/gate/wind_loop.wav",
		"assets/audio/child/wind_outside_loop.wav",
		"assets/audio/child/creek_loop.wav",
		"assets/audio/tower/tower_wind_cold.wav",
		"assets/audio/museum/well_drip_loop.wav",
		"assets/audio/museum/hall_ambience_loop.wav",
	}
	local loopOk = true
	fe.audio:clearPlayLog()
	for idx, path in ipairs(sampleLoops) do
		local id = "m2_loop_" .. tostring(idx)
		fe.audio:playLoop(id, "ambience", path, 0.35, idx)
		local cnt, be = countCue(fe.audio, "loop:" .. id)
		if cnt ~= 1 or be ~= 1 then
			loopOk = false
		end
		fe.audio:stopLoop(id, 0)
	end
	fe.audio:setWorldPlaySpeed(0.25)
	fe.audio:setWorldPlaySpeed(1.0)
	check("1.3 AudioBus/AudioSource 循环音轨真实后端发声", loopOk)
end

-- ---------------------------------------------------------------- 2. 女主线全链路：低模四房 + 软土/铁盆无串音 + F03 礼让接管
do
	local lpPl = fe:getPlugin("fe-04-child-lowpoly")
	local towerPl = fe:getPlugin("fe-05-tower-endings")
	local afterPl = fe:getPlugin("fe-06-afterimage-artifact")

	fe.contract:enterRehearsal("m2-child-chain")
	fe.contract:setMockRoute("child")
	-- 即使档案已有神器且装备穿梭器，女主线低模下残影必须保持静默零激活
	fe.contract:setMockArchive(true, true, true)
	fe.contract:triggerMockBench(false, { equippedWeapon = "time_shuttler" })

	-- 2.1 空村：砸硬砖/铁盆/软土三发，验证 audio.ts 不再误播砖响且循环夜风真实发声
	local pV = new(play.Play, rooms.VILLAGE_ROOM)
	fe:bindPlay(pV, 1280, 720)
	fe.audio:clearPlayLog()
	fe:renderPlay(DT, pV, inp, 1280, 720)
	local nightCnt, nightBe = countCue(fe.audio, "loop:fe04_village_night")

	-- 直接通过后端一次性事件验证三材质分轨零串音
	pV:adoptEvents({
		{ name = "bottleLanded", seq = 201, tick = pV.ticks + 1, data = { x = 608, y = 0, heard = true } },
		{ name = "bottleLanded", seq = 202, tick = pV.ticks + 2, data = { x = 548, y = 0, heard = true } },
		{ name = "bottleLanded", seq = 203, tick = pV.ticks + 3, data = { x = 272, y = 0, heard = false } },
	})
	fe:renderPlay(DT, pV, inp, 1280, 720)
	local bCnt, bBe = countCue(fe.audio, "bottle:brick")
	local iCnt, iBe = countCue(fe.audio, "bottle:iron")
	local irCnt, irBe = countCue(fe.audio, "fe04:bottle:iron_ring")
	local sCnt, sBe = countCue(fe.audio, "bottle:soft")
	local sDup = countCue(fe.audio, "fe04:bottle:soft_thud")
	check("2.1 空村夜风真循环与砖/铁/软三材质分轨零串音",
		nightCnt == 1 and nightBe == 1
		and bCnt == 1 and bBe == 1
		and iCnt == 1 and iBe == 1
		and irCnt == 1 and irBe == 1
		and sCnt == 1 and sBe == 1
		and sDup == 0
		and afterPl:getDebugState().active == false,
		string.format("night=%d/%d brick=%d iron=%d ring=%d soft=%d dup=%d", nightCnt, nightBe, bCnt, iCnt, irCnt, sCnt, sDup))

	-- 2.2 北塔：tower-wait 由 fe-04 渲染低模塔外景，敲门后无缝交权给 fe-05 F03 空行留白且零 HUD 透穿
	local pT = new(play.Play, rooms.TOWER_ROOM)
	fe:bindPlay(pT, 1280, 720)
	fe.audio:clearPlayLog()
	pT.player.x = pT.room.story.tower.doorX
	fe:renderPlay(DT, pT, inp, 1280, 720)
	local waitLp = lpPl:getDebugState(pT).active
	local waitTw = towerPl:getDebugState().active

	inp.interact.pressed = true
	pT:update(DT, inp)
	inp.interact.pressed = false
	fe:renderPlay(DT, pT, inp, 1280, 720)
	for _ = 1, 38 do
		pT:update(DT, inp)
		fe:renderPlay(DT, pT, inp, 1280, 720)
	end
	pT.player.x = pT.ox + 605
	pT.player.y = 0
	inp.interact.held = true
	for _ = 1, 38 do
		pT:update(DT, inp)
		fe:renderPlay(DT, pT, inp, 1280, 720)
	end
	inp.interact.held = false
	for _ = 1, 460 do
		pT:update(DT, inp)
		fe:renderPlay(DT, pT, inp, 1280, 720)
	end
	local stF03 = towerPl:getDebugState()
	local windCnt, windBe = countCue(fe.audio, "loop:tower_wind_cold")
	local warmCnt, warmBe = countCue(fe.audio, "loop:tower_room_warm")
	local labelsF03 = countVisibleLabels(root)
	check("2.2 北塔 fe-04 礼让 fe-05 完成 F03 空行定格与双循环音",
		waitLp == true and waitTw == false
		and stF03.active == true and stF03.route == "child" and stF03.visualStyle == "lowpoly"
		and stF03.stage == "ending_hold" and stF03.row1Name == "小满" and stF03.row2Blank == true
		and stF03.hasCompletionStamp == false and stF03.lampAtWestWindow == true
		and windCnt == 1 and windBe == 1 and warmCnt == 1 and warmBe == 1
		and labelsF03 <= 10,
		string.format("labels=%d wind=%d/%d warm=%d/%d", labelsF03, windCnt, windBe, warmCnt, warmBe))

	fe.contract:exitRehearsal()
end

-- ---------------------------------------------------------------- 3. 男主线全链路：穿梭器残影 + 换弹慢时 + M03 团圆 + 四镜同袖
do
	local lpPl = fe:getPlugin("fe-04-child-lowpoly")
	local towerPl = fe:getPlugin("fe-05-tower-endings")
	local afterPl = fe:getPlugin("fe-06-afterimage-artifact")
	local carryPl = fe:getPlugin("fe-02-carry-pose")
	local wellPl = fe:getPlugin("fe-06-well-museum")

	fe.contract:enterRehearsal("m2-soldier-chain")
	fe.contract:setMockRoute("soldier")
	fe.contract:setMockArchive(true, true, true)
	fe.contract:setMockBackCarry({ active = true })
	fe.contract:triggerMockBench(false, { equippedWeapon = "time_shuttler" })

	local pS = new(play.Play, rooms.STREET_ROOM)
	fe:bindPlay(pS, 1280, 720)
	for k = 1, 24 do
		pS.player.x = 140 + k * 7
		pS.player.vx = 200
		fe:renderPlay(DT, pS, inp, 1280, 720)
	end
	local stAfter = afterPl:getDebugState()
	check("3.1 男主线背负与时间穿梭器残影同开零冲突",
		stAfter.active == true and stAfter.ghostCount >= 2 and stAfter.maxRenderedAlpha <= 0.341
		and carryPl:getPoseState().mode == "carrying"
		and lpPl:getDebugState(pS).active == false,
		string.format("ghosts=%d alpha=%.3f", stAfter.ghostCount, stAfter.maxRenderedAlpha))

	-- 北塔 M03 男主团圆线：fe-04 保持关闭，fe-05 以像素风写满两行并双手端碗
	local pT = new(play.Play, rooms.TOWER_ROOM)
	fe:bindPlay(pT, 1280, 720)
	pT.player.x = pT.room.story.tower.doorX
	inp.interact.pressed = true
	pT:update(DT, inp)
	inp.interact.pressed = false
	for _ = 1, 38 do
		pT:update(DT, inp)
		fe:renderPlay(DT, pT, inp, 1280, 720)
	end
	pT.player.x = pT.ox + 605
	pT.player.y = 0
	inp.interact.held = true
	for _ = 1, 38 do
		pT:update(DT, inp)
		fe:renderPlay(DT, pT, inp, 1280, 720)
	end
	inp.interact.held = false
	for _ = 1, 460 do
		pT:update(DT, inp)
		fe:renderPlay(DT, pT, inp, 1280, 720)
	end
	local stM03 = towerPl:getDebugState()
	check("3.2 男主线北塔 M03 保持像素风写满两行与双手端碗",
		lpPl:getDebugState(pT).active == false
		and stM03.route == "soldier" and stM03.visualStyle == "pixel"
		and stM03.row1Name == "小满" and stM03.row2Name == "周戍"
		and stM03.needleCaseOnDesk == true and stM03.twoHandsHoldingBowl == true)

	-- 四镜补线袖口单一真源校验（P03/P05/G05 + fe-03 + fe-06 E02）
	local base = cuffShots.CUFF_PALETTE.indigoBase
	local spec = prologueMod.CUFF_SHARED_SPEC
	check("3.3 四镜补线青布袖口共享 CUFF_PALETTE 单一真源",
		base.r == 34 and base.g == 52 and base.b == 74
		and spec.indigoCloth.r == base.r and spec.stitchCount == 6
		and wellPl:getDebugState().cuffReusedFromSharedPalette == true)

	fe.contract:exitRehearsal()
end

-- ---------------------------------------------------------------- 4. 双通关水井 + 序章 P01/P02 隔离 + E01-E02 到 P03 无缝交接
do
	local prologuePl = fe:getPlugin("fe03-prologue-intro")
	local cuffPl = fe:getPlugin("fe-01-cuff-shots")
	local wellPl = fe:getPlugin("fe-06-well-museum")
	local afterPl = fe:getPlugin("fe-06-afterimage-artifact")
	wellPl:resetSessionCounters()

	fe.contract:enterRehearsal("m2-museum-handoff")
	fe.contract:setMockArchive(true, true, false)
	fe.contract:triggerMockBench(false, { equippedWeapon = "time_shuttler" })

	local pP = new(play.Play, rooms.PROLOGUE_ROOM)
	pP.wellX = 430 -- 模拟已接入正式井口坐标的玩法版本。
	fe:bindPlay(pP, 1280, 720)
	-- 4.1 序章 P02 逃柜进行中必须压制井院入口，避免提前暴露周戍侧灶深井
	prologuePl:startRehearsal("p02_escape", 6.0)
	fe:renderPlay(DT, pP, inp, 1280, 720)
	local blockedInP02 = wellPl:getDebugState().gateOpen == false
	prologuePl:stopRehearsal()

	-- 恢复排演双通关档位，进入 well_open 并走完 E01 -> hall_walk -> lamp_turn -> return_cabinet -> done
	fe.contract:enterRehearsal("m2-museum-handoff")
	fe.contract:setMockArchive(true, true, false)
	fe.contract:triggerMockBench(false, { equippedWeapon = "time_shuttler" })
	fe:bindPlay(pP, 1280, 720)
	fe.audio:clearPlayLog()
	-- 排练态若绑定真实 Play，井位仍取 Play.wellX=430（与 fe06 一致）；无 Play 数据时才回落 WELL_WORLD_X。
	pP.player.x = pP.ox + 430 + 6
	fe:renderPlay(DT, pP, inp, 1280, 720)
	local dripCnt, dripBe = countCue(fe.audio, "loop:fe06_well_drip")

	-- 触发 well_pickup -> E01 well_reflect -> hall_walk
	inp.interact.pressed = true
	fe:renderPlay(DT, pP, inp, 1280, 720)
	inp.interact.pressed = false
	for _ = 1, 210 do
		fe:renderPlay(DT, pP, inp, 1280, 720)
	end
	local stHall = wellPl:getDebugState()
	local hallAmbCnt, hallAmbBe = countCue(fe.audio, "loop:fe06_hall_ambience")
	local afterHiddenInMuseum = afterPl:getDebugState().active == false

	-- 走到末厅西窗灯前转灯 -> return_cabinet -> done
	wellPl:setHallWalkPosition(wellMod.MUSEUM_LAMP_X, true)
	fe:renderPlay(DT, pP, inp, 1280, 720)
	inp.interact.pressed = true
	fe:renderPlay(DT, pP, inp, 1280, 720)
	inp.interact.pressed = false
	for _ = 1, 430 do
		fe:renderPlay(DT, pP, inp, 1280, 720)
	end
	local doneSnap = fe.contract:getLastSnapshot()

	-- 检查 intentLog 中全部 5 步 museumInteract 均为 accepted=true
	local acceptedIntents = 0
	for _, entry in ipairs(fe.contract:getIntentLog()) do
		if entry.intent.kind == "museumInteract" and entry.accepted then
			acceptedIntents = acceptedIntents + 1
		end
	end

	-- 离馆交还寻柜后，走近小满按 E 触发 prologue-give -> fe-01 P03 袖口特写无缝衔接
	pP.player.x = 290
	inp.interact.pressed = true
	pP:update(DT, inp)
	inp.interact.pressed = false
	for _ = 1, 20 do
		pP:update(DT, inp)
		fe:renderPlay(DT, pP, inp, 1280, 720)
	end

	check("4.1 序章 P02 严格隔离井口且双通关井口滴水真循环",
		blockedInP02 and dripCnt == 1 and dripBe == 1)
	check("4.2 E01-E02 闭环、展厅底噪真循环、残影零漏入且意图全受",
		stHall.museumPhase == "hall_walk"
		and hallAmbCnt == 1 and hallAmbBe == 1
		and afterHiddenInMuseum
		and doneSnap.archive.museumPhase == "done" and doneSnap.archive.museumSeen == true
		and acceptedIntents >= 5,
		string.format("amb=%d/%d intents=%d", hallAmbCnt, hallAmbBe, acceptedIntents))
	check("4.3 离馆归还序章后无缝衔接 fe-01 P03 补线袖口",
		pP.phase == "prologue-give" and cuffPl:getDebugState().activeShot == "P03")

	fe.contract:exitRehearsal()
end

-- ---------------------------------------------------------------- 5. 后端 C 单（story-c-archive）live 契约前向对齐
do
	local wellPl = fe:getPlugin("fe-06-well-museum")
	local lpPl = fe:getPlugin("fe-04-child-lowpoly")
	local pC = new(play.Play, rooms.PROLOGUE_ROOM)
	-- 模拟后端 C 单 live 快照：archive.museumPhase 仍为 "locked"，但 p.wellOpen=true, p.wellX=430
	pC.archive = { childCleared = true, soldierCleared = true, artifactOwned = false, museumPhase = "locked", museumSeen = false }
	pC.wellOpen = true
	pC.wellX = 430
	local wellPickCalled = false
	pC.submitFeIntent = function(_, req)
		if req.kind == "wellPick" then
			wellPickCalled = true
			return true
		end
		return false
	end

	fe.contract:exitRehearsal()
	fe:bindPlay(pC, 1280, 720)
	pC.player.x = 430
	inp.interact.pressed = true
	fe:renderPlay(DT, pC, inp, 1280, 720)
	inp.interact.pressed = false
	local snapC = fe.contract:getLastSnapshot()
	local stC = wellPl:getDebugState()
	check("5.1 后端 C 单 live wellOpen/wellX=430 自动开放井口并转译 wellPick",
		snapC.dataSource == "live"
		and snapC.archive.museumPhase == "well_open"
		and stC.gateOpen == true
		and math.abs(stC.wellWorldX - 430) < 0.01
		and wellPickCalled == true)

	-- 模拟后端 C 单独立 MUSEUM_ROOM（room.key = "museum"）与 artifactFound / museumStep 事件
	local pM = new(play.Play, rooms.MUSEUM_ROOM)
	pM.phase = "museum-hall"
	pM.player.x = 640
	pM.archive = { childCleared = true, soldierCleared = true, artifactOwned = true, museumPhase = "hall_walk", museumSeen = false }
	fe:bindPlay(pM, 1280, 720)
	fe.audio:clearPlayLog()
	pM:adoptEvents({
		{ name = "artifactFound", seq = 301, tick = 10, data = { x = 430, y = 0, room = "prologue" } },
		{ name = "museumStep", seq = 302, tick = 11, data = { step = "cabinet", x = 200 } },
		{ name = "museumStep", seq = 303, tick = 12, data = { step = "hall", x = 900 } },
		{ name = "museumStep", seq = 304, tick = 13, data = { step = "lamp", x = 1250 } },
		{ name = "museumStep", seq = 305, tick = 14, data = { step = "knock", count = 1 } },
		{ name = "museumStep", seq = 306, tick = 15, data = { step = "knock", count = 2 } },
	})
	fe:renderPlay(DT, pM, inp, 1280, 720)
	local snapM = fe.contract:getLastSnapshot()
	local stM = wellPl:getDebugState()
	local afCnt, afBe = countCue(fe.audio, "museum:artifact_found")
	local cabCnt, cabBe = countCue(fe.audio, "museum:step:cabinet")
	local hCnt, hBe = countCue(fe.audio, "museum:step:hall")
	local lCnt, lBe = countCue(fe.audio, "museum:step:lamp")
	local k1Cnt, k1Be = countCue(fe.audio, "museum:step:knock:1")
	local k2Cnt, k2Be = countCue(fe.audio, "museum:step:knock:2")
	check("5.2 后端 C 单独立 MUSEUM_ROOM 视角/坐标与 6 项事件音频对齐",
		snapM.visualMode == "museum"
		and math.abs(stM.hallWalkX - 640) < 1.0
		and lpPl:getDebugState(pM).active == false
		and afCnt == 1 and afBe == 1
		and cabCnt == 1 and cabBe == 1
		and hCnt == 1 and hBe == 1
		and lCnt == 1 and lBe == 1
		and k1Cnt == 1 and k1Be == 1
		and k2Cnt == 1 and k2Be == 1)

	-- 切回普通街道后彻底清净
	pM.phase = "museum-lamp"
	pM.player.x = wellPl.lampX + pM.ox
	fe:renderPlay(DT, pM, inp, 1280, 720)
	check("正式灯位显示交互提示", wellPl:getDebugState().nearLamp)
	inp.interact.pressed = true
	pM:update(play.STEP, inp)
	check("在绘制的灯位转灯", pM.phase == "museum-return")
	pM.player.x = wellPl.caseX + pM.ox
	pM:update(play.STEP, inp)
	inp.interact.pressed = false
	check("在绘制的玻璃柜回柜", pM.phase == "museum-knock")
	local pClean = new(play.Play, rooms.STREET_ROOM)
	pClean.archive.museumPhase = "hall_walk"
	fe:bindPlay(pClean, 1280, 720)
	fe:renderPlay(DT, pClean, inp, 1280, 720)
	check("5.3 退出排演并切回普通像素房间后全部 11 插件零残留",
		fe.contract:getDataSource() == "live"
		and fe.contract:getLastSnapshot().visualMode == "pixel"
		and fe.cam:getAnchorLock() == nil
		and lpPl:getDebugState(pClean).active == false
		and fe:getPlugin("fe-05-tower-endings"):getDebugState().active == false
		and fe:getPlugin("fe-06-afterimage-artifact"):getDebugState().active == false)
end

-- 回主界面要停掉本房音频，包括暂停中的循环声。
do
	local p = new(play.Play, rooms.GATE_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.audio:playLoop("m2-title-audio-check", "wind", "assets/audio/gate/wind_loop.wav")
	fe.audio:setPaused(true)
	fe.screen = "title"
	fe:renderMenu(DT, inp, 1280, 720)
	check("7.1 返回主界面停止房间循环并解除暂停", next(fe.audio.activeLoops) == nil and not fe.audio:isPaused())
end

-- 正式整合会增加章节，选章始终返回原房间索引，且井后隐藏关不在列表内。
do
	local publicRooms = {}
	for index, room in ipairs(rooms.ROOMS) do
		if room.key ~= "museum" then publicRooms[#publicRooms + 1] = index - 1 end
	end
	fe.screen = "chapters"
	fe.menus:openChapters()
	fe.menus:onKeyEvent("Left")
	fe.menus:onKeyEvent("Return")
	local last = fe:renderMenu(DT, inp, 1280, 720)
	check("7.2 选章循环跳过隐藏展厅", last.type == "jump" and last.roomIndex == publicRooms[#publicRooms])
	if #publicRooms > 8 then
		fe.menus:openChapters()
		fe.menus:onKeyEvent("Down")
		fe.menus:onKeyEvent("Return")
		local lower = fe:renderMenu(DT, inp, 1280, 720)
		check("7.3 下移一行保留原房间索引", lower.type == "jump"
			and lower.roomIndex == publicRooms[math.ceil(#publicRooms / 2) + 1])
	end
	check("7.4 粮棚与工台使用各自标题和场景",
		theme.themeOf("escort2").shortNameZh == "粮棚取材"
		and theme.themeOf("escort3").shortNameZh == "山腰工台"
		and theme.themeOf("escort3").backdropKey == "forest")
end

do
	local p = new(play.Play, rooms.ESCORT2_ROOM or rooms.CHECKPOINT_ROOM)
	p.pickups = {
		{ id = "qa_wood", kind = "wood", x = 380, y = 0, label = "木纹筹" },
		{ id = "qa_bell", kind = "bell", x = 560, y = 0, label = "铃纹筹" },
	}
	fe.screen = "play"
	fe:bindPlay(p, 1280, 720)
	fe:renderPlay(DT, p, inp, 1280, 720)
	local wood = fe.worldArt.visibleLastFrame["pickup_qa_wood:assets/art/ui_ink.clip|ink_bamboo_slip"]
	local bell = fe.worldArt.visibleLastFrame["pickup_qa_bell:assets/art/sprites.clip|compass"]
	p.player.x, p.player.y, p.player.depth = 380, 0, 0
	p:update(play.STEP, inp)
	fe:renderPlay(DT, p, inp, 1280, 720)
	check("7.5 粮棚材料可见，拾取后从场景撤下",
		p.run.taken.qa_wood and wood and bell and not wood.visible and bell.visible)
end

root:cleanup()
package.loaded["watch.fe"] = prevWatchFe
print(string.format("==== M2 联合验收汇总：PASS %d / FAIL %d ====", pass, fail))
assert(fail == 0, string.format("M2 联合验收失败 %d 项", fail))
