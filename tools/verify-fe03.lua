-- Wave 1 fe-03 自动化回归验证脚本：
-- 覆盖共同序章 P01 / P02 / P04 状态机、暂停冻结、逃柜重试零残留、音频去重、
-- P04 不锁控制，以及明朝全局美术红线体检（底图拦截、木/砖材质区分、红布左端、58+15 帧键完整性）。
--
-- 用法（引擎内，复制到仓库根或通过项目上下文运行）：
--   dofile("tools/verify-fe03.lua")

local Dora = require("Dora")
local lualib = require("lualib_bundle")
local new = lualib.__TS__New

local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local assets = require("Script.watch.fe.assets")
local prologueMod = require("Script.watch.fe.cutscenes.prologue_intro")
local mingMod = require("Script.watch.fe.renderer.ming_audit")

local pass = 0
local fail = 0

local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS fe03: %-28s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL fe03: %-28s %s", tag, detail or ""))
	end
end

local function newInput()
	local inp = new(Input)
	inp.moveX = 0
	inp.moveY = 0
	inp.inside = true
	inp.mx, inp.my = 640, 360
	inp.interact = { held = false, pressed = false, released = false }
	inp.fire = { held = false, pressed = false, released = false }
	inp.aim = { held = false, pressed = false, released = false }
	inp.cover = { held = false, pressed = false, released = false }
	inp.crouch = { held = false, pressed = false, released = false }
	inp.jump = { held = false, pressed = false, released = false }
	inp.retry = { held = false, pressed = false, released = false }
	inp.pause = { held = false, pressed = false, released = false }
	return inp
end

local function countCue(audio, prefix)
	local log = audio:getPlayLog()
	local n = 0
	for i = 1, #log do
		local entry = log[i]
		if entry and entry.cueId and string.sub(entry.cueId, 1, #prefix) == prefix then
			n = n + 1
		end
	end
	return n
end

local root = Dora.Node()
local fe = new(Frontend, root)
local mingPlugin = new(mingMod.MingArtAuditPlugin)
local prologuePlugin = new(prologueMod.PrologueIntroPlugin)
fe:registerPlugin(mingPlugin)
fe:registerPlugin(prologuePlugin)

local inp = newInput()
local DT = 1 / 60

print("==== FE-03 共同序章 P01-P04 与明朝全局美术体检验证 ====")

-- ---------------------------------------------------------------- 1. 正式序章无误触发阻断
do
	local p = new(play.Play, rooms.PROLOGUE_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.screen = "play"
	fe:renderPlay(DT, p, inp, 1280, 720)
	local snap = prologuePlugin:getSnapshot()
	check("正式 prologue-wait 不强锁首帧", snap.stage == "idle" and not snap.blocksPlayerControl,
		"stage=" .. tostring(snap.stage))
	check("正式态默认低引导关闭", not fe.contract:isAssistHintsEnabled() and not fe.contract:isRehearsal())
end

-- ---------------------------------------------------------------- 2. P01 4 秒睁眼唤醒与单次去重
do
	local p = new(play.Play, rooms.PROLOGUE_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.audio:clearPlayLog()
	prologuePlugin:startRehearsal("sequence", 4.0, fe.contract)
	check("排演启动自动打排演标注", fe.contract:isRehearsal() == true)

	-- 推进至 0.5s：应已播父亲唤声且仅播一次
	for _ = 1, 30 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local s05 = prologuePlugin:getSnapshot()
	check("P01 0.5s 处于唤醒阶段", s05.stage == "p01_wake" and s05.stageElapsed >= 0.45 and s05.blocksPlayerControl,
		string.format("t=%.2f", s05.stageElapsed))
	check("P01 父亲唤声仅触发一次", countCue(fe.audio, "prologue:p01_call") == 1,
		"count=" .. tostring(countCue(fe.audio, "prologue:p01_call")))

	-- 暂停冻结同拍验证
	local frozenT = s05.stageElapsed
	p.paused = true
	for _ = 1, 15 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local sPaused = prologuePlugin:getSnapshot()
	check("P01 暂停严格冻结拍点", math.abs(sPaused.stageElapsed - frozenT) < 0.0001,
		string.format("before=%.4f after=%.4f", frozenT, sPaused.stageElapsed))
	p.paused = false

	-- 推进完 P01 剩余 3.5s（210 拍 + 2 拍余量）自动衔接 P02 墙影
	for _ = 1, 215 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local sP02 = prologuePlugin:getSnapshot()
	check("P01 4s 结束自动接 P02 墙影", sP02.stage == "p02_shadow", "stage=" .. tostring(sP02.stage))
	check("P01 手撑床沿音仅播一次", countCue(fe.audio, "prologue:p01_bed_press") == 1)

	-- ---------------------------------------------------------------- 3. P02 2 秒墙影滚碗 → 限时逃柜
	for _ = 1, 125 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local sEsc0 = prologuePlugin:getSnapshot()
	check("P02 2s 碗停切入限时逃柜", sEsc0.stage == "p02_escape" and not sEsc0.blocksPlayerControl,
		"stage=" .. tostring(sEsc0.stage))
	check("P02 瓷碗滚动与撞坎各响一次",
		countCue(fe.audio, "prologue:p02_bowl_roll") == 1 and countCue(fe.audio, "prologue:p02_bowl_hit") == 1)

	-- 跑动前半段（约 0.8s）记录早期心跳与红晕
	for _ = 1, 48 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local sEarly = prologuePlugin:getSnapshot()

	-- 推进到后半段（再跑 2.2s，剩余时间大幅减少）验证心跳加快与红晕抬升
	for _ = 1, 132 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local sLate = prologuePlugin:getSnapshot()
	check("逃柜心跳随剩余时间加快", sLate.heartbeatHz > sEarly.heartbeatHz + 0.5,
		string.format("early=%.2fHz late=%.2fHz", sEarly.heartbeatHz, sLate.heartbeatHz))
	check("逃柜屏边红晕随紧迫度增强", sLate.vignetteAlpha > sEarly.vignetteAlpha,
		string.format("early=%.2f late=%.2f", sEarly.vignetteAlpha, sLate.vignetteAlpha))
	check("逃柜已触发真实心跳音频节拍", sLate.heartbeatBeatCount >= 2,
		"beats=" .. tostring(sLate.heartbeatBeatCount))

	-- 暂停冻结逃柜计时、红晕与心跳
	local remBefore = sLate.escapeRemaining
	local beatsBefore = sLate.heartbeatBeatCount
	p.paused = true
	for _ = 1, 30 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local sEscPaused = prologuePlugin:getSnapshot()
	check("逃柜暂停冻结剩余时间与心跳",
		math.abs(sEscPaused.escapeRemaining - remBefore) < 0.0001 and sEscPaused.heartbeatBeatCount == beatsBefore)
	p.paused = false

	-- ---------------------------------------------------------------- 4. 逃柜重试：门口起步且零红晕/心跳残留
	prologuePlugin:retryEscape()
	local sRetry = prologuePlugin:getSnapshot()
	check("重试直接回门口可玩姿态",
		sRetry.stage == "p02_escape" and sRetry.escapePlayerX == 0 and sRetry.escapeRetryCount == 1,
		string.format("stage=%s x=%.2f retries=%d", tostring(sRetry.stage), sRetry.escapePlayerX, sRetry.escapeRetryCount))
	check("重试瞬间零红晕零心跳残留",
		sRetry.vignetteAlpha == 0 and sRetry.heartbeatHz == 0 and sRetry.heartbeatBeatCount == 0 and sRetry.heartbeatPulse == 0)

	-- ---------------------------------------------------------------- 5. 入柜收净红晕 + 半拍远去脚步
	for _ = 1, 60 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	prologuePlugin:triggerCabinetEnter()
	-- 推进 0.35s（> 0.28s 淡出，>= 0.30s 脚步触发）
	for _ = 1, 24 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local sHidden = prologuePlugin:getSnapshot()
	check("入柜后红晕彻底收净归零",
		sHidden.stage == "p02_hidden" and sHidden.vignetteAlpha == 0 and sHidden.heartbeatHz == 0,
		string.format("stage=%s vig=%.3f hb=%.2f", tostring(sHidden.stage), sHidden.vignetteAlpha, sHidden.heartbeatHz))
	check("入柜留半拍柜外渐远脚步声",
		countCue(fe.audio, "prologue:p02_cabinet_shut") == 1 and countCue(fe.audio, "prologue:p02_footsteps_fade") == 1)

	-- 退出排演恢复正式数据源且无残留
	prologuePlugin:stopRehearsal()
	local sStop = prologuePlugin:getSnapshot()
	check("退出排演清空状态并恢复正式源",
		sStop.stage == "idle" and sStop.vignetteAlpha == 0 and not fe.contract:isRehearsal())
end

-- ---------------------------------------------------------------- 6. P04 正式模式井庭墙根触发且不锁控
do
	local p = new(play.Play, rooms.PROLOGUE_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.audio:clearPlayLog()
	p.phase = "prologue-follow"
	p.player.x = 500
	p.partner.x = 468
	fe:renderPlay(DT, p, inp, 1280, 720)
	local s0 = prologuePlugin:getSnapshot()
	check("P04 在序章井庭墙根自然触发", s0.p04Active and s0.p04TriggeredOnce and not s0.blocksPlayerControl)
	check("P04 枪火声单次触发", countCue(fe.audio, "prologue:p04_gunflash") == 1)

	-- 走满 1.0s（65 拍），验证光灭后磨亮窗板下沿与石槽磨痕仍保留可见余明
	for _ = 1, 65 do
		fe:renderPlay(DT, p, inp, 1280, 720)
	end
	local s1 = prologuePlugin:getSnapshot()
	check("P04 1s 光灭后窗板/石槽磨痕仍可辨认",
		(not s1.p04Active) and s1.p04FlashIntensity == 0 and s1.p04PostHintAlpha >= 0.35 and not s1.blocksPlayerControl,
		string.format("postHint=%.2f", s1.p04PostHintAlpha))

	-- 重试/重新 bindPlay 彻底清零 P04 状态
	local p2 = new(play.Play, rooms.PROLOGUE_ROOM)
	fe:bindPlay(p2, 1280, 720)
	local sReset = prologuePlugin:getSnapshot()
	check("切房重试清空 P04 状态", (not sReset.p04Active) and sReset.p04PostHintAlpha == 0 and not sReset.p04TriggeredOnce)
end

-- ---------------------------------------------------------------- 7. 明朝全局美术红线体检
do
	-- 7a. 非八房战役段落（s1-crossroad / c1-yard）被明朝像素底图拦截，杜绝探照灯退化
	local pS1 = new(play.Play, rooms.S1_CROSSROAD)
	fe:bindPlay(pS1, 1280, 720)
	fe:renderPlay(DT, pS1, inp, 1280, 720)
	local pC1 = new(play.Play, rooms.C1_YARD)
	fe:bindPlay(pC1, 1280, 720)
	fe:renderPlay(DT, pC1, inp, 1280, 720)
	local repMid = mingPlugin:runAudit()
	check("非八房关卡被明朝底图拦截（零探照灯）", repMid.fallbackInterceptCount >= 2,
		"intercepts=" .. tostring(repMid.fallbackInterceptCount))

	-- 7b. 街道木柜挡下 vs 城门砖街垒挡下 + 鸟铳硝烟
	local pStreet = new(play.Play, rooms.STREET_ROOM)
	fe:bindPlay(pStreet, 1280, 720)
	pStreet.player.x = 290
	pStreet.coveredFlash = 0.5
	pStreet.trace = { x0 = 300, y0 = 56, x1 = 560, y1 = 56, hit = true }
	fe:renderPlay(DT, pStreet, inp, 1280, 720)

	local pGate = new(play.Play, rooms.GATE_ROOM)
	fe:bindPlay(pGate, 1280, 720)
	pGate.player.x = 510
	pGate.coveredFlash = 0.5
	fe:renderPlay(DT, pGate, inp, 1280, 720)

	local repMat = mingPlugin:runAudit()
	check("挡下区分木柜木屑与砖沿砖灰",
		repMat.woodDebrisTriggered >= 1 and repMat.brickDebrisTriggered >= 1,
		string.format("wood=%d brick=%d", repMat.woodDebrisTriggered, repMat.brickDebrisTriggered))
	check("鸟铳开火触发灰白火药烟", repMat.powderSmokeTriggered >= 1,
		"smoke=" .. tostring(repMat.powderSmokeTriggered))

	-- 7c. 村口灰度双地表 + 森林草后轮廓 + 城门内外红布固定左端不变式
	local pChk = new(play.Play, rooms.CHECKPOINT_ROOM)
	fe:bindPlay(pChk, 1280, 720)
	fe:renderPlay(DT, pChk, inp, 1280, 720)
	local pOut = new(play.Play, rooms.OUTSIDE_ROOM)
	fe:bindPlay(pOut, 1280, 720)
	fe:renderPlay(DT, pOut, inp, 1280, 720)
	local pVil = new(play.Play, rooms.VILLAGE_ROOM)
	fe:bindPlay(pVil, 1280, 720)
	fe:renderPlay(DT, pVil, inp, 1280, 720)
	local pFor = new(play.Play, rooms.FOREST_ROOM)
	fe:bindPlay(pFor, 1280, 720)
	pFor.player.x = 340
	pFor.dogX = 740
	pFor.dogState = "ear"
	fe:renderPlay(DT, pFor, inp, 1280, 720)

	check("城门内外板车红布恒定在左端",
		rooms.CHECKPOINT_ROOM.cart.clothSide == -1 and rooms.OUTSIDE_ROOM.cart.clothSide == -1)

	-- 7d. 全量 8 房底图 + 58 帧 sprites.clip + 15 帧 ui_ink.clip 零缺失校验
	local auditHost = new(assets.AssetSlotHost, root, 0)
	auditHost:beginFrame()
	local report = mingPlugin:runAudit(auditHost)
	auditHost:endFrame()

	check("八房明朝底图全部存在", report.coreBackdropsOk, "missing=" .. tostring(#report.missingBackdrops))
	check("既有 58 个 sprites.clip 键 100% 兼容",
		report.preservedSpriteClipsCount == 58 and #report.missingSpriteClips == 0,
		string.format("loaded=%d/58", report.preservedSpriteClipsCount))
	check("既有 15 个 ui_ink.clip 键 100% 兼容",
		report.preservedUiClipsCount == 15 and #report.missingUiClips == 0,
		string.format("loaded=%d/15", report.preservedUiClipsCount))
	check("红布左端运行态不变式通过", report.cartClothLeftInvariantOk)
	check("6 处旧热点赛博遗留已登记清单", report.legacyFindingsCount == 6,
		"findings=" .. tostring(report.legacyFindingsCount))
end

root:cleanup()
print(string.format("==== FE-03 结果：PASS %d / FAIL %d ====", pass, fail))
assert(fail == 0, string.format("FE-03 回归失败 %d 项", fail))
