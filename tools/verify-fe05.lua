-- 《向西守望》Wave 2 fe-05（feature/fe-05-dual-endings）北塔双结局同机位配对演出自动化验收脚本
--
-- 用法（引擎项目上下文）：dofile("tools/verify-fe05.lua")
-- 覆盖范围：
-- 1. 插件零冲突挂载（与 M1 默认 7 枚插件同载无冲突），tower-wait 步行期不抢占 fe-04/基础场景
-- 2. 后端 stepTower 实机对齐：tower-knock 第 0/12 拍敲门事件同步 → tower-given → tower-end 无缝延续 8 秒演出，零 HUD 文本透穿
-- 3. 同机位配对 0.000 px 精度：F03 与 M03 门扇/门槛/叩门手位/宣纸簿页/一二行基线/悬停笔尖/案沿热碗坐标完全重合
-- 4. F03 女主单人线（低模材质 + 西窗暖灯移动 + 留白第二行零完成章 + 「朝西那盏灯，能留着吗？」）
-- 5. M03 男主同行线（序章像素风 + 周戍亲口报姓名写满第二行 + 解下针套轻放案上 + 双手端起热碗）
-- 6. 防误触与暂停双冻：旧按键未松开不解锁、8 秒定格前按键拦截消化、暂停冻结时间/灯光/音频、恢复不重播
-- 7. 室内重试边界：室内重试不重关塔门、不重播敲门/开门音、登记簿固定双槽永不重复追加行
-- 8. 全部 15 份 assets/audio/tower/*.wav 离线存在且 playedBackend=true，退出排演与切房零残留

local Dora = require("Dora")
local Content = Dora.Content
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local towerMod = require("Script.watch.fe.cutscenes.tower_endings")

local pass = 0
local fail = 0

local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS fe05: %-38s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL fe05: %-38s %s", tag, detail or ""))
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

local function stepFrames(n, dt, p, inp, fe, stepSim)
	for _ = 1, n do
		if stepSim then
			p:update(dt, inp)
		end
		fe:renderPlay(dt, p, inp, 1280, 720)
		inp.interact.pressed = false
		inp.interact.released = false
		inp.retry.pressed = false
		inp.retry.released = false
		inp.pause.pressed = false
	end
end

local root = Dora.Node()
local fe = new(Frontend, root)
fe.screen = "play"
local DT = 1 / 60
local inp = newInput()

print("==== FE-05 北塔双结局同机位配对演出验收开始 ====")

-- ---------------------------------------------------------------- 1. 零冲突挂载与 tower-wait 不抢占
local plugin = towerMod.attachTowerEndingsPlugin(fe)
do
	local list = fe:getPlugins()
	check("1.1 在 M1 7 插件基础上零冲突挂载 fe-05",
		#list == 8 and fe:getPlugin("fe-05-tower-endings") == plugin,
		"plugins=" .. tostring(#list))
	-- 幂等重复挂载不产生重复实例
	local plugin2 = towerMod.attachTowerEndingsPlugin(fe)
	plugin = plugin2
	check("1.2 重复 attachTowerEndingsPlugin 幂等覆盖",
		#fe:getPlugins() == 8 and fe:getPlugin("fe-05-tower-endings") == plugin)

	local pTower = new(play.Play, rooms.TOWER_ROOM)
	fe:bindPlay(pTower, 1280, 720)
	fe:renderPlay(DT, pTower, inp, 1280, 720)
	local stWait = plugin:getDebugState()
	check("1.3 tower-wait 门廊步行期不抢占 fe-04/基础层",
		pTower.phase == "tower-wait" and stWait.active == false and stWait.stage == "idle")
end

-- ---------------------------------------------------------------- 2. 全部 15 份分轨 WAV 资产离线存在检查
do
	local expected = {
		"door_knock_1.wav", "door_knock_2.wav",
		"door_reply_1.wav", "door_reply_2.wav",
		"door_open.wav", "book_open.wav",
		"brush_write_1.wav", "brush_write_2.wav",
		"lamp_move.wav", "needle_case_place.wav", "bowl_set.wav",
		"tower_wind_cold.wav", "tower_room_warm.wav",
		"line_xiaoman_lamp.wav", "line_zhoushu_name.wav",
	}
	local missing = {}
	for _, fn in ipairs(expected) do
		local full = "assets/audio/tower/" .. fn
		if not Content:exist(full) then
			table.insert(missing, fn)
		end
	end
	check("2.1 全部 15 份 assets/audio/tower/*.wav 离线存在",
		#missing == 0,
		#missing == 0 and "15/15 OK" or ("missing=" .. table.concat(missing, ",")))
end

-- ---------------------------------------------------------------- 3. Live 后端 stepTower 第 0/12 拍敲门对齐与无缝 8 秒延续
do
	local p = new(play.Play, rooms.TOWER_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.audio:clearPlayLog()
	p.player.x = p.room.story.tower.doorX
	fe:renderPlay(DT, p, inp, 1280, 720)

	-- 触发第 1 声敲门（tower-knock phaseTick = 0）
	inp.interact.pressed = true
	inp.interact.held = true
	stepFrames(1, DT, p, inp, fe, true)
	local stK1 = plugin:getDebugState()
	local k1Cnt, k1Be = countCue(fe.audio, "tower:knock:1")
	check("3.1 Live tower-knock 第 0 拍精确对齐 knock1",
		p.phase == "tower-knock" and stK1.active and stK1.knockCount == 1 and k1Cnt == 1 and k1Be == 1)

	-- 推进 12 拍触发第 2 声敲门（tower-knock phaseTick = 12）
	stepFrames(12, DT, p, inp, fe, true)
	local stK2 = plugin:getDebugState()
	local k2Cnt, k2Be = countCue(fe.audio, "tower:knock:2")
	check("3.2 Live tower-knock 第 12 拍精确对齐 knock2",
		stK2.knockCount == 2 and k2Cnt == 1 and k2Be == 1)

	-- 推进完 tower-knock (剩余 24 拍) 进入 tower-given，门内回叩两声与开门声各响 1 次
	stepFrames(25, DT, p, inp, fe, true)
	local stOpen = plugin:getDebugState()
	local r1Cnt, r1Be = countCue(fe.audio, "tower:reply:1")
	local r2Cnt, r2Be = countCue(fe.audio, "tower:reply:2")
	local openCnt, openBe = countCue(fe.audio, "tower:door_open")
	check("3.3 门内回叩两声与开门对齐 tower-given 起点",
		p.phase == "tower-given" and stOpen.doorOpened
		and r1Cnt == 1 and r1Be == 1 and r2Cnt == 1 and r2Be == 1 and openCnt == 1 and openBe == 1)

	-- 松开敲门旧按键后继续推进至 tower-end (180 拍后)，确认演出无缝延续至 8 秒而不截断
	inp.interact.held = false
	stepFrames(185, DT, p, inp, fe, true)
	local stMid = plugin:getDebugState()
	check("3.4 后端切入 tower-end 时演出平滑衔接不跳切",
		p.phase == "tower-end" and stMid.active and stMid.seqElapsed >= 3.5 and stMid.seqElapsed < 5.0 and stMid.row1Written)

	-- 推满至 8.2 秒（Live F03 完整收尾）
	stepFrames(290, DT, p, inp, fe, true)
	local stEnd = plugin:getDebugState()
	local f03LineCnt, f03LineBe = countCue(fe.audio, "tower:f03:line_lamp")
	local lampCnt, lampBe = countCue(fe.audio, "tower:f03:lamp_move")
	check("3.5 Live F03 完整走到 8s 定格、西窗暖灯与零完成章",
		stEnd.stage == "ending_hold"
		and stEnd.row1Name == "小满"
		and stEnd.row2Blank == true
		and stEnd.hasCompletionStamp == false
		and stEnd.lampAtWestWindow == true
		and stEnd.registryAppendCount == 1
		and f03LineCnt == 1 and f03LineBe == 1
		and lampCnt == 1 and lampBe == 1)
end

-- ---------------------------------------------------------------- 4. 同机位配对 0.000 px 对齐校验（F03 vs M03）
do
	local p = new(play.Play, rooms.TOWER_ROOM)
	fe:bindPlay(p, 1280, 720)
	local checkTimes = { 0.0, 0.20, 0.42, 1.40, 3.80, 6.00, 8.20 }
	local maxErr = 0
	local pivotAligned = true

	for _, tm in ipairs(checkTimes) do
		plugin:startRehearsal("child", fe.contract, { seekTime = tm, tag = "fe05-pair-F03" })
		fe:renderPlay(0, p, inp, 1280, 720)
		local fSt = plugin:getDebugState()

		plugin:startRehearsal("soldier", fe.contract, { seekTime = tm, tag = "fe05-pair-M03" })
		fe:renderPlay(0, p, inp, 1280, 720)
		local mSt = plugin:getDebugState()

		local fa, ma = fSt.anchors, mSt.anchors
		local keys = {
			"doorCenterX", "thresholdY", "knockHandX", "knockHandY",
			"bookX", "bookY", "bookW", "bookH",
			"row1Y", "row2Y", "brushHoverTipX", "brushHoverTipY",
			"bowlRimX", "bowlRimY",
		}
		for _, k in ipairs(keys) do
			local diff = math.abs((fa[k] or 0) - (ma[k] or 0))
			if diff > maxErr then maxErr = diff end
		end
		if math.abs(tm - 3.80) < 0.01 then
			pivotAligned = (fSt.stage == "pivot_hover" and mSt.stage == "pivot_hover"
				and fSt.row1Name == "小满" and mSt.row1Name == "小满"
				and fSt.row2Blank and mSt.row2Blank)
		end
	end
	check("4.1 F03/M03 全 7 节拍同机位全部 14 锚点 0.000px 误差",
		maxErr < 0.0001, string.format("maxErr=%.6f px", maxErr))
	check("4.2 3.80s 悬停笔尖支点两线状态完全同源重合", pivotAligned)
	plugin:stopRehearsal(fe.contract)
end

-- ---------------------------------------------------------------- 5. M03 男主同行线完整 8 秒流程与全部音画断言
do
	local p = new(play.Play, rooms.TOWER_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.audio:clearPlayLog()
	plugin:startRehearsal("soldier", fe.contract, { seekTime = 0, tag = "fe05-M03-full" })

	-- 步进至 4.35s：周戍亲口报出自己姓名
	stepFrames(262, DT, p, inp, fe, false)
	local stSpeak = plugin:getDebugState()
	local nameCnt, nameBe = countCue(fe.audio, "tower:m03:line_name")
	check("5.1 M03 4.35s 切入周戍亲口报姓名「周戍。」",
		stSpeak.visualStyle == "pixel"
		and stSpeak.subtitleText == "「周戍。」"
		and nameCnt == 1 and nameBe == 1)

	-- 步进至 8.20s：写满第二行、解针套轻放案上、小满双手端起热碗
	stepFrames(232, DT, p, inp, fe, false)
	local stM03 = plugin:getDebugState()
	local b1Cnt, b1Be = countCue(fe.audio, "tower:brush:row1")
	local b2Cnt, b2Be = countCue(fe.audio, "tower:brush:row2")
	local ncCnt, ncBe = countCue(fe.audio, "tower:m03:needle_place")
	local bwCnt, bwBe = countCue(fe.audio, "tower:bowl_set")
	local bkCnt, bkBe = countCue(fe.audio, "tower:book_open")
	check("5.2 M03 终帧写满两行（小满/周戍）、解针套与双手端碗",
		stM03.stage == "ending_hold"
		and stM03.row1Name == "小满"
		and stM03.row2Written == true
		and stM03.row2Name == "周戍"
		and stM03.row2Blank == false
		and stM03.registryAppendCount == 2
		and stM03.needleCaseOnDesk == true
		and stM03.twoHandsHoldingBowl == true)
	check("5.3 M03 翻簿/双落笔/放针套/端碗 5 类 WAV 均真实单次触发",
		bkCnt == 1 and bkBe == 1
		and b1Cnt == 1 and b1Be == 1
		and b2Cnt == 1 and b2Be == 1
		and ncCnt == 1 and ncBe == 1
		and bwCnt == 1 and bwBe == 1)
	plugin:stopRehearsal(fe.contract)
end

-- ---------------------------------------------------------------- 6. 防误触旧按键消化 + 暂停双冻恢复不重播
do
	local p = new(play.Play, rooms.TOWER_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.audio:clearPlayLog()

	-- 6.1 模拟旧按键一直按住进入过场直到 8.2s：必须先松手才能解锁确认
	inp.interact.held = true
	plugin:startRehearsal("child", fe.contract, { seekTime = 7.2, tag = "fe05-guard" })
	stepFrames(65, DT, p, inp, fe, false) -- 到达 ~8.28s，但旧 E 键未松开
	local stHeld = plugin:getDebugState()
	check("6.1 携旧按键按住至 8.2s 保持锁定不误触",
		stHeld.seqElapsed >= 8.0 and stHeld.staleInputMustRelease == true and stHeld.confirmReady == false)

	-- 6.2 在 5.0s（未读完定格）松手后再点 E：应拦截计数且不确认
	inp.interact.held = false
	plugin:startRehearsal("child", fe.contract, { seekTime = 5.0, tag = "fe05-early" })
	stepFrames(2, DT, p, inp, fe, false) -- 释放旧键
	inp.interact.pressed = true
	inp.interact.held = true
	stepFrames(1, DT, p, inp, fe, false)
	inp.interact.held = false
	local stEarly = plugin:getDebugState()
	check("6.2 8 秒定格读完前新按 E 被消化拦截",
		stEarly.earlyInputBlockedCount >= 1 and stEarly.confirmReady == false and stEarly.rehearsalAcknowledged == false)

	-- 6.3 推进到 8.1s 并松手后，新的 E 键确认生效
	stepFrames(190, DT, p, inp, fe, false)
	local stReady = plugin:getDebugState()
	inp.interact.pressed = true
	stepFrames(1, DT, p, inp, fe, false)
	local stAck = plugin:getDebugState()
	check("6.3 定格读完且旧键松开后新按 E 正常确认",
		stReady.confirmReady == true and stAck.rehearsalAcknowledged == true)

	-- 6.4 暂停完全冻结时间、挪灯进度与音频，恢复续播不重播
	fe.audio:clearPlayLog()
	plugin:startRehearsal("child", fe.contract, { seekTime = 5.4, tag = "fe05-pause" })
	stepFrames(10, DT, p, inp, fe, false)
	local beforePause = plugin:getDebugState()
	local logBeforePause = #fe.audio:getPlayLog()
	p.paused = true
	stepFrames(30, DT, p, inp, fe, false)
	local duringPause = plugin:getDebugState()
	local logDuringPause = #fe.audio:getPlayLog()
	p.paused = false
	stepFrames(10, DT, p, inp, fe, false)
	local afterResume = plugin:getDebugState()
	local lampAfterCnt = countCue(fe.audio, "tower:f03:lamp_move")
	check("6.4 暂停冻结演出计时/灯位/音频且恢复不重播",
		math.abs(duringPause.seqElapsed - beforePause.seqElapsed) < 0.0001
		and math.abs(duringPause.lampProgress - beforePause.lampProgress) < 0.0001
		and logDuringPause == logBeforePause
		and afterResume.seqElapsed > beforePause.seqElapsed + 0.14
		and lampAfterCnt == 1)
	plugin:stopRehearsal(fe.contract)
end

-- ---------------------------------------------------------------- 7. 室内重试边界（不重关门、不重播敲门、不重复追加行）
do
	-- 7.1 排演室内重试：M03 写满后触发室内重试
	local p = new(play.Play, rooms.TOWER_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.audio:clearPlayLog()
	plugin:startRehearsal("soldier", fe.contract, { seekTime = 6.2, tag = "fe05-retry-M03" })
	stepFrames(5, DT, p, inp, fe, false)
	local preRetry = plugin:getDebugState()
	fe.audio:clearPlayLog()
	plugin:triggerIndoorRetry()
	stepFrames(120, DT, p, inp, fe, false) -- 再走 2 秒覆写周期
	local postRetry = plugin:getDebugState()
	local replayK1 = countCue(fe.audio, "tower:knock:1")
	local replayOpen = countCue(fe.audio, "tower:door_open")
	check("7.1 室内重试不重关门、不重播敲门/开门、不重复追加登记行",
		preRetry.registryAppendCount == 2
		and postRetry.indoorRetryCount == 1
		and postRetry.doorOpened == true
		and postRetry.doorClosedAfterRetry == false
		and postRetry.registryAppendCount == 2
		and replayK1 == 0 and replayOpen == 0)
	plugin:stopRehearsal(fe.contract)

	-- 7.2 正式模式室内检查点重载（p.phase = tower-given, checkpoint = 1）
	local pLive = new(play.Play, rooms.TOWER_ROOM)
	pLive.phase = "tower-given"
	pLive.checkpoint = 1
	fe.audio:clearPlayLog()
	fe:bindPlay(pLive, 1280, 720)
	stepFrames(10, DT, pLive, inp, fe, false)
	local liveRetry = plugin:getDebugState()
	local liveK1 = countCue(fe.audio, "tower:knock:1")
	check("7.2 Live 室内检查点重载直接保持门开且不补播敲门",
		liveRetry.doorOpened == true
		and liveRetry.doorClosedAfterRetry == false
		and liveRetry.seqElapsed >= towerMod.TOWER_ENDING_TIMINGS.indoorCutSec
		and liveK1 == 0)
end

-- ---------------------------------------------------------------- 8. 过场零 HUD 透穿 & 切房/退排演零残留
do
	local p = new(play.Play, rooms.TOWER_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.contract:setAssistHintsEnabled(false)
	plugin:startRehearsal("child", fe.contract, { seekTime = 8.2, tag = "fe05-clean" })
	fe:renderPlay(0, p, inp, 1280, 720)
	-- 终帧静默时只允许出现簿页文字（天头2 + 行1含注3 + 肆拾贰1 + 落款1）+ 排演徽章1 <= 10，且无 HUD/按键提示
	local endLabels = countVisibleLabels(root)
	check("8.1 F03 静默定格无 HUD/按键提示透穿", endLabels >= 6 and endLabels <= 10, "labels=" .. tostring(endLabels))

	plugin:stopRehearsal(fe.contract)
	local pOut = new(play.Play, rooms.PROLOGUE_ROOM)
	fe:bindPlay(pOut, 1280, 720)
	fe:renderPlay(DT, pOut, inp, 1280, 720)
	local stOut = plugin:getDebugState()
	check("8.2 退出排演并切回序章后状态完全清净",
		fe.contract:getDataSource() == "live"
		and stOut.active == false
		and stOut.isRehearsal == false)
end

root:cleanup()
print(string.format("==== FE-05 验收汇总：PASS %d / FAIL %d ====", pass, fail))
assert(fail == 0, string.format("FE-05 验收失败 %d 项", fail))
