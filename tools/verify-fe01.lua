-- 守望 Wave 1 fe-01（feature/fe-01-gate-cuff-lowpoly）自动化验收断言
--
-- 用法（引擎项目上下文）：dofile("tools/verify-fe01.lua")
-- 覆盖范围：
-- 1. lowpoly.ts 2.5D 透视投影数学不变量（wz=0 与 worldToScreen/screenToWorld 0 误差，morph 0..1 连续性）
-- 2. M1 城外栈台侧移验证（木板 wz<0 相对走面与后排石阶 wz>0 真视差遮挡 + 车柄 worldMapper 0 误差）
-- 3. 风台 24s 转景 0 / 6 / 12 / 18 / 21 / 24 秒（0 / 360 / 720 / 1080 / 1260 / 1440 拍）双对齐点 0 跳动
-- 4. 声音/字幕/手势单次触发、暂停同拍冻结与恢复防重播
-- 5. 双出口：G04 女主线预按不走/松手重按迈步；G05 男主线两下轻叩/0.6s 长按/中途松手平滑退回重试/切回像素风一次台词
-- 6. 补线袖口三镜（P03 / P05 / G05）、全量 30 个分轨 WAV 文件离线可读与切房清理

local Dora = require("Dora")
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local lowpoly = require("Script.watch.fe.renderer.lowpoly")
local cuffShots = require("Script.watch.fe.cutscenes.cuff_shots")

local pass = 0
local fail = 0

local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS  %-34s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL  %-34s %s", tag, detail or ""))
	end
end

local function newInput()
	local i = new(Input)
	i.moveX = 0
	i.moveY = 0
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

local function stepOne(p, input, fe, w, h)
	p:update(play.STEP, input)
	input.interact.pressed = false
	input.interact.released = false
	input.fire.pressed = false
	input.aim.released = false
	input.jump.pressed = false
	input.pause.pressed = false
	fe:renderPlay(play.STEP, p, input, w or 1280, h or 720)
end

local function countCue(audio, cueId)
	local log = audio:getPlayLog()
	local n = 0
	local backend = 0
	for _, entry in ipairs(log) do
		if entry.cueId == cueId then
			n = n + 1
			if entry.playedBackend then
				backend = backend + 1
			end
		end
	end
	return n, backend
end

local root = Dora.Node()
local fe = new(Frontend, root)
fe.screen = "play"
local plugins = cuffShots.registerFe01Plugins(fe)
local gatePl = plugins.gateTransition
local cuffPl = plugins.cuffShots

print("==== FE-01 自动化验收开始 ====")

-- ---------------------------------------------------------------- 1. 全部 30 个分轨 WAV 资产存在检查
do
	local required = {
		"wind_loop.wav", "water_moat_loop.wav", "cloth_wipe_wood.wav", "gate_slam.wav",
		"knock_wall.wav", "reunion_hold.wav", "reunion_release.wav", "breath_soft.wav",
		"line_farewell.wav", "line_reunion.wav",
	}
	for n = 1, 20 do
		table.insert(required, string.format("count_%02d.wav", n))
	end
	local missing = 0
	for _, fname in ipairs(required) do
		if not Dora.Content:exist("assets/audio/gate/" .. fname) then
			missing = missing + 1
			print("MISSING AUDIO: assets/audio/gate/" .. fname)
		end
	end
	check("1.1 分轨音频 30 个 WAV 离线可读", missing == 0, "total=" .. #required .. " missing=" .. missing)
end

-- ---------------------------------------------------------------- 2. lowpoly.ts 数学不变量与多分辨率验证
do
	local p = new(play.Play, rooms.OUTSIDE_ROOM)
	local resolutions = { { 1280, 720 }, { 1920, 1080 }, { 1680, 720 } }
	local morphs = { 0, 0.25, 0.5, 0.75, 1.0 }
	local maxFwdErr = 0
	local maxInvErr = 0
	for _, res in ipairs(resolutions) do
		fe:bindPlay(p, res[1], res[2])
		for _, m in ipairs(morphs) do
			local proj = { morph = m, focal = 410, vpFracX = 0.55, vpFracY = 0.54, vpOffsetX = 4, vpOffsetY = -3, baseDepth = 0 }
			local chk = lowpoly.verifyWalkPlaneAlignment(fe.cam, proj, 344, 96)
			if chk.forwardErrPx > maxFwdErr then maxFwdErr = chk.forwardErrPx end
			if chk.inverseErrWorld > maxInvErr then maxInvErr = chk.inverseErrWorld end
		end
	end
	check("2.1 wz=0 跨分辨率与形变零误差", maxFwdErr < 0.001 and maxInvErr < 0.001,
		string.format("fwd=%.6f inv=%.6f", maxFwdErr, maxInvErr))

	fe:bindPlay(p, 1280, 720)
	local proj0 = { morph = 0, focal = 410, vpFracX = 0.55, vpFracY = 0.54, baseDepth = 0 }
	local proj1 = { morph = 1, focal = 410, vpFracX = 0.55, vpFracY = 0.54, baseDepth = 0 }
	local orthoOff = lowpoly.projectWorld3D(420, 96, 80, fe.cam, proj0)
	local base2D = fe.cam:worldToScreen(420, 96, 0)
	local farPt = lowpoly.projectWorld3D(420, 96, 120, fe.cam, proj1)
	local nearPt = lowpoly.projectWorld3D(420, 96, -48, fe.cam, proj1)
	check("2.2 morph=0 严格退化正交平面",
		math.abs(orthoOff.x - base2D.x) < 0.001 and math.abs(orthoOff.y - base2D.y) < 0.001 and orthoOff.scale == 1)
	check("2.3 morph=1 远景缩放<1 前景缩放>1",
		farPt.scale < 0.85 and nearPt.scale > 1.10,
		string.format("farScale=%.3f nearScale=%.3f", farPt.scale, nearPt.scale))
end

-- ---------------------------------------------------------------- 3. M1 城外栈台侧移：真视差遮挡 + 车柄点选落点
do
	local p = new(play.Play, rooms.OUTSIDE_ROOM)
	fe:bindPlay(p, 1280, 720)
	local proj = { morph = 1.0, focal = 410, vpFracX = 0.52, vpFracY = 0.54, baseDepth = 0 }
	local handleWorldX = p.cartAxle + p.room.cart.handleOffset
	local handleWorldY = p.room.cart.baseY

	fe.cam.x = 260
	local nearA = lowpoly.projectWorld3D(300, 96, -24, fe.cam, proj)
	local deckA = lowpoly.projectWorld3D(300, 96, 0, fe.cam, proj)
	local stepA = lowpoly.projectWorld3D(300, 96, 48, fe.cam, proj)
	local hScA = lowpoly.projectWorld3D(handleWorldX, handleWorldY, 0, fe.cam, proj)
	local hMapA = p.worldMapper(hScA.x, hScA.y)

	local drawTest = Dora.DrawNode()
	local glowTest = Dora.DrawNode()
	local scene = new(lowpoly.LowpolyScene, fe.cam, proj, lowpoly.OUTSIDE_JETTY_LIGHT)
	lowpoly.buildOutsideJettyLowpoly(scene, p.room, p.player.x, p.player.y, p.cartAxle, 1.0)
	local faceCount = scene:getFaceCount()
	scene:flush(drawTest, glowTest)

	fe.cam.x = 380
	local nearB = lowpoly.projectWorld3D(300, 96, -24, fe.cam, proj)
	local deckB = lowpoly.projectWorld3D(300, 96, 0, fe.cam, proj)
	local stepB = lowpoly.projectWorld3D(300, 96, 48, fe.cam, proj)
	local hScB = lowpoly.projectWorld3D(handleWorldX, handleWorldY, 0, fe.cam, proj)
	local hMapB = p.worldMapper(hScB.x, hScB.y)

	local shiftNear = math.abs(nearB.x - nearA.x)
	local shiftDeck = math.abs(deckB.x - deckA.x)
	local shiftStep = math.abs(stepB.x - stepA.x)
	local errA = math.abs(hMapA.x - handleWorldX) + math.abs(hMapA.y - handleWorldY)
	local errB = math.abs(hMapB.x - handleWorldX) + math.abs(hMapB.y - handleWorldY)

	check("3.1 栈台低模几何面生成并刷出", faceCount >= 25, "faces=" .. faceCount)
	check("3.2 侧移真视差：近木板 > 走面 > 后石阶",
		shiftNear > shiftDeck + 5 and shiftDeck > shiftStep + 5,
		string.format("near=%.1f deck=%.1f step=%.1f", shiftNear, shiftDeck, shiftStep))
	check("3.3 侧移前后车柄 worldMapper 零误差",
		errA < 0.01 and errB < 0.01,
		string.format("errA=%.5f errB=%.5f", errA, errB))
end

-- ---------------------------------------------------------------- 4. 风台 24s 五帧双对齐点零跳动与节拍验证
do
	local p = new(play.Play, rooms.GATE_ROOM)
	local input = newInput()
	fe:bindPlay(p, 1280, 720)
	-- 进入 gate-send 并按 E 进 gate-count
	local g = p.room.story.gate
	p.phase = "gate-send"
	p.player.x = g.doorX
	p.partner.x = g.doorX + 30
	stepOne(p, input, fe)
	input.interact.pressed = true
	input.interact.held = true
	stepOne(p, input, fe)
	input.interact.held = false
	stepOne(p, input, fe)
	check("4.1 成功从 gate-send 进入 gate-count", p.phase == "gate-count" and p.childMode == true)

	fe.contract:enterRehearsal("fe01-keyframes")
	fe.contract:setMockRoute("child")
	local ticks = { 0, 360, 720, 1080, 1260, 1440 }
	local baseFootX, baseFootY, baseThX, baseThY
	local maxFootDrift = 0
	local maxThDrift = 0
	local morphOk = true
	for idx, tk in ipairs(ticks) do
		fe.contract:setMockCountTick(tk, 1440)
		fe:renderPlay(play.STEP, p, input, 1280, 720)
		local st = gatePl:getDebugState()
		local expectedMorph = tk / 1440
		if math.abs(st.morph - expectedMorph) > 0.002 then
			morphOk = false
		end
		local foot = fe.cam:worldToScreen(p.player.x, p.player.y, p.player.depth)
		local th = fe.cam:worldToScreen(st.thresholdWorldX, 0, p.player.depth)
		if idx == 1 then
			baseFootX, baseFootY = foot.x, foot.y
			baseThX, baseThY = th.x, th.y
		else
			local fd = math.abs(foot.x - baseFootX) + math.abs(foot.y - baseFootY)
			local td = math.abs(th.x - baseThX) + math.abs(th.y - baseThY)
			if fd > maxFootDrift then maxFootDrift = fd end
			if td > maxThDrift then maxThDrift = td end
		end
		if tk == 1080 then
			check("4.2 第 1080 拍（18s）数十八贴耳", st.countNumber == 18 and st.earToDoor == true)
		elseif tk == 1260 then
			check("4.3 第 1260 拍（21s）数十九呼吸停顿", st.countNumber == 19 and st.breathPause == true)
		end
	end
	check("4.4 0/6/12/18/21/24s 进度曲线准确", morphOk)
	check("4.5 五帧小满脚底+门槛像素 0 跳动",
		maxFootDrift < 0.001 and maxThDrift < 0.001,
		string.format("footDrift=%.6f thDrift=%.6f", maxFootDrift, maxThDrift))
	fe.contract:exitRehearsal()
end

-- ---------------------------------------------------------------- 5. 连续 1440 拍单次播音 + 中段暂停续播 + G04 女主迈步
do
	local p = new(play.Play, rooms.GATE_ROOM)
	local input = newInput()
	fe:bindPlay(p, 1280, 720)
	fe.audio:clearPlayLog()
	local g = p.room.story.gate
	p.phase = "gate-send"
	p.player.x = g.doorX
	p.partner.x = g.doorX + 30
	stepOne(p, input, fe)
	input.interact.pressed = true
	stepOne(p, input, fe)

	-- 跑到第 720 拍（12s）后暂停 30 帧，核对不推进、不重播
	while p.countTick < 720 do
		stepOne(p, input, fe)
	end
	local logBeforePause = #fe.audio:getPlayLog()
	local morphBeforePause = gatePl:getDebugState().morph
	p.paused = true
	for _ = 1, 30 do
		fe:renderPlay(play.STEP, p, input, 1280, 720)
	end
	check("5.1 暂停冻结同拍、morph 与音频",
		p.countTick == 720
		and math.abs(gatePl:getDebugState().morph - morphBeforePause) < 0.0001
		and #fe.audio:getPlayLog() == logBeforePause
		and fe.audio:isPaused() == true,
		string.format("tick=%d log=%d/%d", p.countTick, #fe.audio:getPlayLog(), logBeforePause))
	p.paused = false
	fe:renderPlay(play.STEP, p, input, 1280, 720)
	local c13AfterResume = countCue(fe.audio, "gate:count:13")
	check("5.2 恢复续播不重播当前数", c13AfterResume == 1 and fe.audio:isPaused() == false)

	-- 继续跑到 1439 拍并故意按住 D 到 1445（验证不自动迈步）
	while p.countTick < 1438 do
		stepOne(p, input, fe)
	end
	input.moveX = 1
	for _ = 1, 8 do
		stepOne(p, input, fe)
	end
	check("5.3 G04 1439 预按住 D 不自动迈步",
		p.phase == "gate-count" and p.countTick >= 1440 and gatePl:getDebugState().g04Idle == true)

	-- 核对 1..20 二十声配音全部精确触发一次
	local allOnce = true
	for n = 1, 20 do
		local cnt, be = countCue(fe.audio, "gate:count:" .. n)
		if cnt ~= 1 or be ~= 1 then
			allOnce = false
			print("BAD COUNT CUE:", n, cnt, be)
		end
	end
	local breathCnt = countCue(fe.audio, "gate:breath_19")
	check("5.4 1..20 数声与 19 拍呼吸各精确响一次", allOnce and breathCnt == 1)

	-- 松开再按 D 迈步进入 gate-walk 并解除锚定锁
	input.moveX = 0
	stepOne(p, input, fe)
	input.moveX = 1
	stepOne(p, input, fe)
	check("5.5 G04 松开重按 D 进入 gate-walk 并解锁镜头",
		p.phase == "gate-walk" and fe.cam:getAnchorLock() == nil)
end

-- ---------------------------------------------------------------- 6. G05 男主线风台重逢：两叩、松手平滑退回重试、0.6s 满握切回像素风一次台词
do
	local p = new(play.Play, rooms.GATE_ROOM)
	local input = newInput()
	fe:bindPlay(p, 1280, 720)
	fe.audio:clearPlayLog()
	local g = p.room.story.gate
	p.phase = "gate-send"
	p.player.x = g.doorX
	p.partner.x = g.doorX + 30
	stepOne(p, input, fe)
	input.interact.pressed = true
	stepOne(p, input, fe)

	fe.contract:enterRehearsal("fe01-soldier-reunion")
	fe.contract:setMockRoute("soldier")
	fe.contract:setMockCountTick(1440, 1440)

	-- 走 16 拍等待两下轻叩触发
	for _ = 1, 16 do
		fe:renderPlay(play.STEP, p, input, 1280, 720)
	end
	local k1 = countCue(fe.audio, "knock:gate:1")
	local k2 = countCue(fe.audio, "knock:gate:2")
	check("6.1 G05 排演态两下轻叩各触发一次", k1 == 1 and k2 == 1)

	-- 长按 E 约 0.3s（18 帧）：袖口伸入画面，未完成
	input.interact.held = true
	for _ = 1, 18 do
		fe:renderPlay(play.STEP, p, input, 1280, 720)
	end
	local midExtend = cuffPl:getDebugState().g05SleeveExtend
	check("6.2 G05 长按 0.3s 袖口伸入且未提前完成",
		midExtend > 0.42 and midExtend < 0.60 and not fe.contract:getLastSnapshot().gateReunion.completed,
		string.format("extend=%.3f", midExtend))

	-- 中途松手：holdProgress 归零，袖口应平滑退回画边（而非瞬移或卡死）
	input.interact.held = false
	fe:renderPlay(play.STEP, p, input, 1280, 720)
	local after1 = cuffPl:getDebugState().g05SleeveExtend
	for _ = 1, 18 do
		fe:renderPlay(play.STEP, p, input, 1280, 720)
	end
	local afterRetract = cuffPl:getDebugState().g05SleeveExtend
	check("6.3 G05 中途松手袖口平滑退回画边可重试",
		after1 > 0.25 and after1 < midExtend and afterRetract < 0.05
		and fe.contract:getLastSnapshot().gateReunion.releasedAbortCount == 1,
		string.format("mid=%.3f after1=%.3f retracted=%.3f", midExtend, after1, afterRetract))

	-- 重新长按满 0.6s（40 帧）→ 触发重逢完成，继续渲染 90 帧观察切回像素风与单次台词
	input.interact.held = true
	for _ = 1, 40 do
		fe:renderPlay(play.STEP, p, input, 1280, 720)
	end
	input.interact.held = false
	check("6.4 G05 重按满 0.6s 触发重逢锁定",
		fe.contract:getLastSnapshot().gateReunion.completed == true)

	for _ = 1, 90 do
		fe:renderPlay(play.STEP, p, input, 1280, 720)
	end
	local gateSt = gatePl:getDebugState()
	local cuffSt = cuffPl:getDebugState()
	local lineCnt, lineBe = countCue(fe.audio, "cuff:g05:line_reunion")
	check("6.5 G05 沿臂抬镜切回像素风且台词仅触发一次",
		gateSt.reunionPixelReturn >= 0.99 and gateSt.effectiveMorph <= 0.01
		and cuffSt.g05LineTriggered == true and lineCnt == 1 and lineBe == 1,
		string.format("pixelRet=%.2f effMorph=%.2f lineCnt=%d", gateSt.reunionPixelReturn, gateSt.effectiveMorph, lineCnt))
	fe.contract:exitRehearsal()
end

-- ---------------------------------------------------------------- 7. 补线袖口三镜（P03 / P05 / G05）与切房清理
do
	local p = new(play.Play, rooms.PROLOGUE_ROOM)
	local input = newInput()
	fe:bindPlay(p, 1280, 720)
	fe.audio:clearPlayLog()
	p.phase = "prologue-give"
	for _ = 1, 45 do
		stepOne(p, input, fe)
	end
	local wipeCnt, wipeBe = countCue(fe.audio, "cuff:p03:cloth_wipe_wood")
	check("7.1 P03 柜边相认触发布擦木音效一次", wipeCnt == 1 and wipeBe == 1)

	-- 排演 P03 / P05 / G05 三镜全流程渲染无报错
	fe.audio:clearPlayLog()
	cuffPl:rehearseShot("P03")
	for _ = 1, 185 do fe:renderPlay(play.STEP, p, input, 1280, 720) end
	cuffPl:rehearseShot("P05")
	for _ = 1, 245 do fe:renderPlay(play.STEP, p, input, 1280, 720) end
	cuffPl:rehearseShot("G05")
	for _ = 1, 245 do fe:renderPlay(play.STEP, p, input, 1280, 720) end
	cuffPl:stopRehearsalShot()
	local slamCnt = countCue(fe.audio, "cuff:p05:gate_slam")
	local farCnt = countCue(fe.audio, "cuff:p05:line_farewell")
	local reunCnt = countCue(fe.audio, "cuff:g05:line_reunion")
	check("7.2 三镜排演全链路音效与渲染通过", slamCnt == 1 and farCnt == 1 and reunCnt == 1)

	-- 切房后清理检查（无残留锚定与状态）
	local pNext = new(play.Play, rooms.OUTSIDE_ROOM)
	fe:bindPlay(pNext, 1280, 720)
	fe:renderPlay(play.STEP, pNext, input, 1280, 720)
	check("7.3 切房彻底清理镜头锁与袖口瞬时态",
		fe.cam:getAnchorLock() == nil
		and gatePl:getDebugState().active == false
		and cuffPl:getDebugState().g05SleeveExtend == 0)
end

root:cleanup()
print(string.format("==== FE-01 验收汇总：PASS %d / FAIL %d ====", pass, fail))
assert(fail == 0, string.format("FE-01 回归失败 %d 项", fail))
