-- 《向西守望》前端 M1 合流全链路联调验收脚本（默认 7 插件自动装配 + 跨分支冲突回归）
--
-- 用法（引擎项目上下文）：dofile("tools/verify-m1.lua")
-- 覆盖范围：
-- 1. WatchFrontend 默认构造自动注册全部 7 枚 Wave 1 插件，顺序严格满足分层优先级且零手动接线
-- 2. package.loaded["watch.fe"] 自动挂接全部 7 枚插件实例及 getPlugin/contract/audio 钩子
-- 3. 补线袖口色板单一真源一致（fe-01 cuff_shots / fe-03 prologue_intro 100% 对齐）
-- 4. 过场接管（P01/P02/P03/G05）严格压隐 HUD 文本与准星，彻底消除 TextPool 透穿黑屏
-- 5. 序章 P01→P02→P03→P04 跨 fe-03/fe-01 顺序衔接无互斥冲突
-- 6. 明朝红线 M1 清理（全房 showSearchlights=false、B2 escort2-5 明朝底图映射、木/砖材质反馈）
-- 7. 城门 P05→G01-G03 0/6/12/18/21/24s 双对齐零跳动 + G05 重逢切回像素风与 fe-02 无冲突交接
-- 8. 背负/3×3 慢时连线换弹/工台联调 + B2 后端 benchCraft/benchRejected 音频与 atBench 契约对齐

local Dora = require("Dora")
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local theme = require("Script.watch.fe.theme")
local cuffShots = require("Script.watch.fe.cutscenes.cuff_shots")
local prologueMod = require("Script.watch.fe.cutscenes.prologue_intro")
local mingMod = require("Script.watch.fe.renderer.ming_audit")

local pass = 0
local fail = 0

local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS m1: %-34s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL m1: %-34s %s", tag, detail or ""))
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

local prevWatchFe = package.loaded["watch.fe"]
local runtimeHook = {}
package.loaded["watch.fe"] = runtimeHook

local root = Dora.Node()
-- 严格使用默认构造：验证 M1 接线后无需手动 registerPlugin 即可完整驱动全部 7 枚插件
local fe = new(Frontend, root)
fe.screen = "play"
local DT = 1 / 60
local inp = newInput()

print("==== M1 前端合流全链路联调验收开始 ====")

-- ---------------------------------------------------------------- 1. 默认 7 插件优先级与运行时钩子
do
	local list = fe:getPlugins()
	local expectedIds = {
		"fe03-ming-audit",
		"fe-01-gate-transition",
		"fe-02-carry-pose",
		"fe03-prologue-intro",
		"fe-01-cuff-shots",
		"fe-02-reload-wheel",
		"fe-02-craft-bench",
	}
	-- 兼容 M2+ 追加插件：验证全部 7 枚 M1 插件存在且严格保持原有分层相对顺序
	local cursor = 1
	for _, pl in ipairs(list) do
		if cursor <= #expectedIds and pl.id == expectedIds[cursor] then
			cursor = cursor + 1
		end
	end
	local orderOk = (#list >= #expectedIds and cursor == #expectedIds + 1)
	check("1.1 默认构造按优先级注册 7 枚 M1 插件", orderOk, "count=" .. tostring(#list))
	check("1.2 默认低引导关闭", not fe.contract:isAssistHintsEnabled() and not fe.contract:isRehearsal())

	local p = new(play.Play, rooms.PROLOGUE_ROOM)
	fe:bindPlay(p, 1280, 720)
	check("1.3 watch.fe 自动同步全部 7 枚插件钩子",
		runtimeHook.contract == fe.contract
		and runtimeHook.audio == fe.audio
		and runtimeHook.mingAudit == fe:getPlugin("fe03-ming-audit")
		and runtimeHook.gateTransition == fe:getPlugin("fe-01-gate-transition")
		and runtimeHook.carryPose == fe:getPlugin("fe-02-carry-pose")
		and runtimeHook.prologue == fe:getPlugin("fe03-prologue-intro")
		and runtimeHook.cuffShots == fe:getPlugin("fe-01-cuff-shots")
		and runtimeHook.reloadWheel == fe:getPlugin("fe-02-reload-wheel")
		and runtimeHook.craftBench == fe:getPlugin("fe-02-craft-bench"))
end

-- ---------------------------------------------------------------- 2. 补线袖口单一真源 & 明朝探照灯清零
do
	local base = cuffShots.CUFF_PALETTE.indigoBase
	local stitch = cuffShots.CUFF_PALETTE.stitchThread
	local spec = prologueMod.CUFF_SHARED_SPEC
	check("2.1 补线袖口跨分支色板与针数完全一致",
		spec.indigoCloth.r == base.r and spec.indigoCloth.g == base.g and spec.indigoCloth.b == base.b
		and spec.mendStitch.r == stitch.r and spec.mendStitch.g == stitch.g and spec.mendStitch.b == stitch.b
		and spec.stitchCount == 6)

	local anySearchlight = false
	for _, r in ipairs(rooms.ROOMS) do
		if theme.themeOf(r.key).showSearchlights then
			anySearchlight = true
		end
	end
	check("2.2 全 8 房关闭现代探照灯（MING-01）", not anySearchlight)

	check("2.3 B2 护送段 escort2-5 明朝底图映射就绪",
		mingMod.resolveMingBackdropSlot("gatepath") == "bgFar_outside"
		and mingMod.resolveMingBackdropSlot("escort1") == "bgFar_outside"
		and mingMod.resolveMingBackdropSlot("escort2") == "bgFar_checkpoint"
		and mingMod.resolveMingBackdropSlot("escort3") == "bgFar_forest"
		and mingMod.resolveMingBackdropSlot("escort4") == "bgFar_forest"
		and mingMod.resolveMingBackdropSlot("escort5") == "bgFar_tower")
end

-- ---------------------------------------------------------------- 3. 过场 HUD 文本压隐 + 序章 P01→P02→P03→P04 跨分支连贯
do
	local p = new(play.Play, rooms.PROLOGUE_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe:renderPlay(DT, p, inp, 1280, 720)
	local normalLabels = countVisibleLabels(root)
	check("3.1 常规序章正常渲染水墨 HUD 文本", normalLabels >= 3, "labels=" .. tostring(normalLabels))

	local prologuePl = fe:getPlugin("fe03-prologue-intro")
	local cuffPl = fe:getPlugin("fe-01-cuff-shots")
	prologuePl:startRehearsal("p01", 4.0, fe.contract)
	-- 第 1 帧（t=0.017s < 0.10s 字幕未起）应纯黑屏且零 HUD 文本透穿（排演徽章 1 条允许）
	fe:renderPlay(DT, p, inp, 1280, 720)
	local p01Labels = countVisibleLabels(root)
	check("3.2 P01 黑屏过场压隐 HUD 避免 TextPool 透穿", p01Labels <= 1, "labels=" .. tostring(p01Labels))
	prologuePl:stopRehearsal()

	-- P03（fe-01）与 P04（fe-03）在同一序章按相位先后自然衔接，零互斥冲突
	fe.audio:clearPlayLog()
	p.phase = "prologue-give"
	for _ = 1, 35 do
		p.phaseTick = p.phaseTick + 1
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local wipeCnt, wipeBe = countCue(fe.audio, "cuff:p03:cloth_wipe_wood")
	check("3.3 序章 P03（fe-01）自然触发且不与 fe-03 冲突",
		cuffPl:getDebugState().activeShot == "P03"
		and prologuePl:getSnapshot().stage == "idle"
		and wipeCnt == 1 and wipeBe == 1)

	p.phase = "prologue-follow"
	p.player.x = 510
	p.partner.x = 478
	fe:renderPlay(DT, p, inp, 1280, 720)
	check("3.4 序章 P04（fe-03）承接 P03 自然触发且不锁控",
		cuffPl:getDebugState().activeShot == ""
		and prologuePl:getSnapshot().p04Active == true
		and not prologuePl:getSnapshot().blocksPlayerControl)
end

-- ---------------------------------------------------------------- 4. 城门 24s 转景五帧对齐 + G05 重逢与 fe-02 无冲突交接
do
	local p = new(play.Play, rooms.GATE_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.audio:clearPlayLog()
	local g = p.room.story.gate
	p.phase = "gate-send"
	p.player.x = g.doorX
	p.partner.x = g.doorX + 30
	p:update(DT, inp)
	fe:renderPlay(DT, p, inp, 1280, 720)
	inp.interact.pressed = true
	inp.interact.held = true
	p:update(DT, inp)
	inp.interact.pressed = false
	inp.interact.held = false
	fe:renderPlay(DT, p, inp, 1280, 720)

	local gatePl = fe:getPlugin("fe-01-gate-transition")
	local cuffPl = fe:getPlugin("fe-01-cuff-shots")
	local carryPl = fe:getPlugin("fe-02-carry-pose")

	fe.contract:enterRehearsal("m1-gate-5frames")
	fe.contract:setMockRoute("child")
	local ticks = { 0, 360, 720, 1080, 1260, 1440 }
	local baseFx, baseFy, baseTx, baseTy
	local maxDrift = 0
	for idx, tk in ipairs(ticks) do
		fe.contract:setMockCountTick(tk, 1440)
		fe:renderPlay(DT, p, inp, 1280, 720)
		local st = gatePl:getDebugState()
		local fPt = fe.cam:worldToScreen(p.player.x, p.player.y, p.player.depth)
		local tPt = fe.cam:worldToScreen(st.thresholdWorldX, 0, p.player.depth)
		if idx == 1 then
			baseFx, baseFy, baseTx, baseTy = fPt.x, fPt.y, tPt.x, tPt.y
		else
			local d = math.abs(fPt.x - baseFx) + math.abs(fPt.y - baseFy) + math.abs(tPt.x - baseTx) + math.abs(tPt.y - baseTy)
			if d > maxDrift then maxDrift = d end
		end
	end
	check("4.1 7 插件同开下风台 6 关键拍双对齐 0 跳动", maxDrift < 0.001, string.format("drift=%.6f", maxDrift))

	-- 切到 G05 男主重逢：0.6s 满握后切回像素风并触发单次台词，且 CarryPose 在 childMode 不抢绘
	fe.contract:setMockRoute("soldier")
	fe.contract:setMockCountTick(1440, 1440)
	for _ = 1, 15 do fe:renderPlay(DT, p, inp, 1280, 720) end
	inp.interact.held = true
	for _ = 1, 42 do fe:renderPlay(DT, p, inp, 1280, 720) end
	inp.interact.held = false
	for _ = 1, 90 do fe:renderPlay(DT, p, inp, 1280, 720) end
	local lineCnt = countCue(fe.audio, "cuff:g05:line_reunion")
	check("4.2 G05 满握切回像素风且与 fe-02 无冲突",
		gatePl:getDebugState().reunionPixelReturn >= 0.99
		and cuffPl:getDebugState().g05LineTriggered == true
		and lineCnt == 1
		and carryPl:getPoseState().mode == "handInHand")
	fe.contract:exitRehearsal()
end

-- ---------------------------------------------------------------- 5. 背负 + 3×3 换弹 + 工台 + B2 契约/音频联调
do
	local p = new(play.Play, rooms.STREET_ROOM)
	fe:bindPlay(p, 1280, 720)
	local carryPl = fe:getPlugin("fe-02-carry-pose")
	local reloadPl = fe:getPlugin("fe-02-reload-wheel")
	local craftPl = fe:getPlugin("fe-02-craft-bench")

	-- 5.1 模拟 B2 后端 craftBench.active=true 且无独立 backCarry 字段 -> 契约自动推导 atBench=true
	p.craftBench = {
		active = true,
		firstCraftDone = false,
		justCraftedTimer = 0,
		inventory = { wood = 2, bell = 1 },
		recipes = {
			{ id = "guide_lantern_gun", name = "引路灯铳", desc = "", enhancedEffect = "light", cost = { wood = 2 }, crafted = false },
			{ id = "echo_gun", name = "回声铳", desc = "", enhancedEffect = "echo", cost = { wood = 1, bell = 1 }, crafted = false },
		},
		equippedWeapon = "standard_gun",
	}
	fe:renderPlay(DT, p, inp, 1280, 720)
	local liveSnap = fe.contract:getLastSnapshot()
	check("5.1 B2 live craftBench 自动同步 backCarry.atBench",
		liveSnap.dataSource == "live"
		and liveSnap.craftBench.active == true
		and liveSnap.backCarry.atBench == true
		and carryPl:getPoseState().mode == "atBench")

	-- 5.2 模拟 B2 后端 benchCraft / benchRejected 一次性事件 -> audio.ts 精准响起对应 WAV
	fe.audio:clearPlayLog()
	p:adoptEvents({
		{ name = "benchCraft", seq = 101, tick = p.ticks + 1, data = { recipeId = "guide_lantern_gun", wood = 0, bell = 1 } },
		{ name = "benchRejected", seq = 102, tick = p.ticks + 1, data = { recipeId = "echo_gun", reason = "materials" } },
	})
	fe:renderPlay(DT, p, inp, 1280, 720)
	local craftDoneCnt, craftDoneBe = countCue(fe.audio, "craft:done:guide_lantern_gun")
	local craftRejCnt, craftRejBe = countCue(fe.audio, "craft:insufficient:echo_gun")
	check("5.2 B2 benchCraft/benchRejected 音频分轨命中 WAV",
		craftDoneCnt == 1 and craftDoneBe == 1 and craftRejCnt == 1 and craftRejBe == 1)
	p.craftBench = nil

	-- 5.3 排演背负 + 3×3 换弹慢时（灯纹照明）+ 暂停双冻 + 收盘恢复 1x
	fe.contract:enterRehearsal("m1-reload-smoke")
	fe.contract:setMockRoute("soldier")
	fe.contract:setMockBackCarry({ active = true, atBench = false })
	fe.contract:triggerMockReload(true, { firstTime = true, duration = 4.0, slowTimeScale = 0.25 })
	fe:renderPlay(DT, p, inp, 1280, 720)
	local function drag(nid)
		local pos = reloadPl:getNodeUiPos(nid)
		reloadPl:injectInputForTest({ pointerX = pos.x, pointerY = pos.y, leftHeld = true })
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	drag(0)
	drag(1)
	drag(2)
	local midElapsed = fe.contract:getLastSnapshot().reloadSession.elapsed
	p.paused = true
	for _ = 1, 15 do fe:renderPlay(DT, p, inp, 1280, 720) end
	local frozenOk = math.abs(fe.contract:getLastSnapshot().reloadSession.elapsed - midElapsed) < 0.0001
	p.paused = false
	drag(5)
	drag(8)
	fe:renderPlay(DT, p, inp, 1280, 720)
	check("5.3 7 插件同开下 3×3 换弹慢时、暂停双冻与照明结算通过",
		frozenOk
		and not reloadPl:getState().active
		and fe.contract:getLastSnapshot().reloadSession.nextEffect == "light"
		and math.abs(fe.contract:getLastSnapshot().timeScale - 1.0) < 0.01)

	-- 5.4 退出排演 + 切房彻底清净
	fe.contract:exitRehearsal()
	local pOut = new(play.Play, rooms.OUTSIDE_ROOM)
	fe:bindPlay(pOut, 1280, 720)
	fe:renderPlay(DT, pOut, inp, 1280, 720)
	check("5.4 退出排演并切房后全状态零残留",
		fe.contract:getDataSource() == "live"
		and fe.cam:getAnchorLock() == nil
		and craftPl:getState().active == false
		and not reloadPl:getState().active)
end

root:cleanup()
package.loaded["watch.fe"] = prevWatchFe
print(string.format("==== M1 联调验收汇总：PASS %d / FAIL %d ====", pass, fail))
assert(fail == 0, string.format("M1 联调验收失败 %d 项", fail))
