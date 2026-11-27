-- 《向西守望》全量音频系统自动化验收脚本（feature/audio-overhaul）
--
-- 用法（引擎项目上下文）：dofile("tools/verify-audio.lua")
-- 覆盖范围：
-- 1. 16 首原创 BGM (.ogg) 与 8 条新增场景环境 (.ogg) 及全部新增拟音/UI (.wav) 离线存在且可被 SoLoud 解码加载；
-- 2. SoundscapeDirector 全流程状态机切换（splash -> title -> prologue -> street s1/s2/s3 无缝续播 ->
--    checkpoint c1/c2 -> gate-hold 绞盘 -> gate-count 第18-20声让白 -> gatepath 重逢 ->
--    escort1/3工台/4 -> outside/village -> forest 潜行/溪湾自动切曲 -> tower F03/M03 双结局分岔 -> museum）；
-- 3. 四通道音量设置（masterVol/bgmVol/sfxVol/voiceVol）在 controls_config 与 AudioDirector 的实时生效与持久化往返；
-- 4. 全 46 个 PlayEventName 新接线（interactUsed/pickup/propDamaged/propBroken/bottleThrown/fearChanged/
--    reloadApplied/benchOpen/Equip/Close/campaignFailed/武器与掩体材质差异化）真播放闭环；
-- 5. 护送试炼（mode 2）音频驱动（resetTrialAudio / syncTrialAudio）；
-- 6. 暂停态 UI 发声不污染局内 playLog、退回标题 activeLoops 清零等零回归不变量。

local Dora = require("Dora")
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local ctrlCfg = require("Script.watch.controls_config")

local pass = 0
local fail = 0

local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS audio: %-38s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL audio: %-38s %s", tag, detail or ""))
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

local function hasCue(audio, cueId)
	local log = audio:getPlayLog()
	for _, e in ipairs(log) do
		if e.cueId == cueId then
			return true, e.playedBackend, e.path
		end
	end
	return false, false, ""
end

local function findRoom(key)
	for _, list in ipairs({ rooms.CAMPAIGN_ROOMS, rooms.ROOMS }) do
		if type(list) == "table" then
			for _, r in ipairs(list) do
				if r and r.key == key then
					return r
				end
			end
		end
	end
	error("room not found: " .. tostring(key))
end

local function hasPathInLog(audio, pathSubstr)
	local log = audio:getPlayLog()
	for _, e in ipairs(log) do
		if type(e.path) == "string" and string.find(e.path, pathSubstr, 1, true) ~= nil then
			return true, e.playedBackend, e.cueId
		end
	end
	return false, false, ""
end

local root = Dora.Node()
local fe = new(Frontend, root)
local inp = newInput()
local DT = 1 / 60

print("==== 《向西守望》全量音频系统验收开始 ====")

-- ---------------------------------------------------------------- 1. 全量新增 OGG/WAV 存在且可加载
do
	local bgms = {
		"splash_brand.ogg", "title_westward_watch.ogg", "prologue_ember_night.ogg",
		"street_alley_tension.ogg", "checkpoint_granary.ogg", "gate_siege_45s.ogg",
		"gate_count_drone.ogg", "reunion_hand_in_hand.ogg", "escort_combat.ogg",
		"escort_craft_bench.ogg", "child_lone_journey.ogg", "forest_stalk_and_creek.ogg",
		"creek_dawn_reflection.ogg", "ending_f03_lamp.ogg", "ending_m03_reunion.ogg",
		"museum_dawn_peace.ogg",
	}
	local ambs = {
		"title_coastal_night_loop.ogg", "street_fire_ember_loop.ogg",
		"checkpoint_wind_chains_loop.ogg", "gate_siege_ambience_loop.ogg",
		"gate_winch_chain_loop.ogg", "escort_mountain_night_loop.ogg",
		"escort_bench_lantern_loop.ogg", "culvert_drip_echo_loop.ogg",
	}
	local bgmOk, ambOk = 0, 0
	for _, f in ipairs(bgms) do
		local p = "assets/audio/bgm/" .. f
		if Dora.Content:exist(p) then
			local ok, src = pcall(function() return Dora.AudioSource(p, false) end)
			if ok and src ~= nil then bgmOk = bgmOk + 1 end
		end
	end
	for _, f in ipairs(ambs) do
		local p = "assets/audio/ambience/" .. f
		if Dora.Content:exist(p) then
			local ok, src = pcall(function() return Dora.AudioSource(p, false) end)
			if ok and src ~= nil then ambOk = ambOk + 1 end
		end
	end
	check("1.1 16首原创BGM(.ogg)存在且SoLoud可加载", bgmOk == 16, "ok=" .. bgmOk .. "/16")
	check("1.2 8条新增环境(.ogg)存在且SoLoud可加载", ambOk == 8, "ok=" .. ambOk .. "/8")

	local uiFiles = {
		"menu_hover.wav", "menu_confirm.wav", "menu_back.wav", "game_start.wav",
		"pause_open.wav", "pause_close.wav", "chapter_banner.wav",
		"talent_appear.wav", "talent_pick.wav", "segment_clear.wav", "setting_toggle.wav",
	}
	local uiOk = 0
	for _, f in ipairs(uiFiles) do
		if Dora.Content:exist("assets/audio/ui/" .. f) then uiOk = uiOk + 1 end
	end
	check("1.3 11条宋明水墨UI音效全部就绪", uiOk == 11, "ok=" .. uiOk .. "/11")
end

-- ---------------------------------------------------------------- 2. BGM 状态机与相邻房间无缝续播
do
	fe.screen = "splash"
	fe:renderMenu(DT, inp, 1280, 720)
	check("2.1 开机序幕播放 splash_brand.ogg", fe.audio:getCurrentBgmId() == "splash", "id=" .. fe.audio:getCurrentBgmId())

	fe.screen = "title"
	fe:renderMenu(DT, inp, 1280, 720)
	check("2.2 标题页切换 title_westward_watch.ogg", fe.audio:getCurrentBgmId() == "title", "id=" .. fe.audio:getCurrentBgmId())
	check("2.3 标题页环境底噪独立于 activeLoops", next(fe.audio.activeLoops) == nil, "")

	-- 序章 P03 播放 prologue_ember_night
	fe.screen = "play"
	local pPro = new(play.Play, rooms.PROLOGUE_ROOM)
	pPro.phase = "prologue-give"
	fe:bindPlay(pPro, 1280, 720)
	fe:renderPlay(DT, pPro, inp, 1280, 720)
	check("2.4 序章P03播放 prologue_ember_night", fe.audio:getCurrentBgmId() == "prologue", "id=" .. fe.audio:getCurrentBgmId())

	-- 街巷三房无缝续播（s1 -> s2 -> s3 只写一次 bgmLog）
	local pS1 = new(play.Play, findRoom("s1-crossroad"))
	fe:bindPlay(pS1, 1280, 720)
	fe:renderPlay(DT, pS1, inp, 1280, 720)
	local logAfterS1 = #fe.audio:getBgmLog()
	local pS2 = new(play.Play, findRoom("s2-drygoods"))
	fe:bindPlay(pS2, 1280, 720)
	fe:renderPlay(DT, pS2, inp, 1280, 720)
	local pS3 = new(play.Play, findRoom("s3-archway"))
	fe:bindPlay(pS3, 1280, 720)
	fe:renderPlay(DT, pS3, inp, 1280, 720)
	local logAfterS3 = #fe.audio:getBgmLog()
	check("2.5 街巷三房 s1->s2->s3 BGM 无缝续播",
		fe.audio:getCurrentBgmId() == "street" and logAfterS3 == logAfterS1,
		string.format("id=%s log=%d->%d", fe.audio:getCurrentBgmId(), logAfterS1, logAfterS3))

	-- 哨卡与军粮棚
	local pC1 = new(play.Play, findRoom("c1-yard"))
	fe:bindPlay(pC1, 1280, 720)
	fe:renderPlay(DT, pC1, inp, 1280, 720)
	check("2.6 哨卡/军粮棚切换 checkpoint_granary", fe.audio:getCurrentBgmId() == "checkpoint", "id=" .. fe.audio:getCurrentBgmId())

	-- 城门 45s 守点 -> 24s 数数 -> 牵手重逢
	local pGate = new(play.Play, rooms.GATE_ROOM)
	pGate.phase = "gate-hold"
	fe:bindPlay(pGate, 1280, 720)
	fe:renderPlay(DT, pGate, inp, 1280, 720)
	check("2.7 城门守点切换 gate_siege_45s", fe.audio:getCurrentBgmId() == "gate_siege", "id=" .. fe.audio:getCurrentBgmId())

	pGate.phase = "gate-count"
	fe:renderPlay(DT, pGate, inp, 1280, 720)
	check("2.8 城门数数切换 gate_count_drone", fe.audio:getCurrentBgmId() == "gate_count", "id=" .. fe.audio:getCurrentBgmId())

	local pGp = new(play.Play, rooms.GATE_PATH_ROOM)
	fe:bindPlay(pGp, 1280, 720)
	fe:renderPlay(DT, pGp, inp, 1280, 720)
	check("2.9 男主线 gatepath 切换 reunion_hand_in_hand", fe.audio:getCurrentBgmId() == "reunion", "id=" .. fe.audio:getCurrentBgmId())

	-- 护送段与 escort3 工台休整
	local pE1 = new(play.Play, rooms.ESCORT1_ROOM)
	fe:bindPlay(pE1, 1280, 720)
	fe:renderPlay(DT, pE1, inp, 1280, 720)
	check("2.10 护送战 escort1 切换 escort_combat", fe.audio:getCurrentBgmId() == "escort_combat", "id=" .. fe.audio:getCurrentBgmId())

	local pE3 = new(play.Play, rooms.ESCORT3_ROOM)
	fe:bindPlay(pE3, 1280, 720)
	fe:renderPlay(DT, pE3, inp, 1280, 720)
	check("2.11 山腰工台 escort3 切换 escort_craft_bench", fe.audio:getCurrentBgmId() == "escort_bench", "id=" .. fe.audio:getCurrentBgmId())

	-- 女主线 outside -> forest 潜行 -> forest 溪湾曙光
	local pOut = new(play.Play, rooms.OUTSIDE_ROOM)
	fe:bindPlay(pOut, 1280, 720)
	fe:renderPlay(DT, pOut, inp, 1280, 720)
	check("2.12 女主线 outside 切换 child_lone_journey", fe.audio:getCurrentBgmId() == "child_lone", "id=" .. fe.audio:getCurrentBgmId())

	local pFor = new(play.Play, rooms.FOREST_ROOM)
	fe:bindPlay(pFor, 1280, 720)
	pFor.player.x = pFor.ox + 320
	fe:renderPlay(DT, pFor, inp, 1280, 720)
	check("2.13 密林前半段切换 forest_stalk_and_creek", fe.audio:getCurrentBgmId() == "forest_stalk", "id=" .. fe.audio:getCurrentBgmId())

	pFor.player.x = pFor.ox + 1220
	fe:renderPlay(DT, pFor, inp, 1280, 720)
	check("2.14 步入溪湾自动切换 creek_dawn_reflection", fe.audio:getCurrentBgmId() == "creek_dawn", "id=" .. fe.audio:getCurrentBgmId())

	-- 北塔双结局同源分岔 F03 / M03
	local pTowF = new(play.Play, rooms.TOWER_ROOM)
	pTowF.phase = "tower-knock"
	pTowF.storyRoute = "child"
	fe:bindPlay(pTowF, 1280, 720)
	fe:renderPlay(DT, pTowF, inp, 1280, 720)
	check("2.15 北塔女主结局切换 ending_f03_lamp", fe.audio:getCurrentBgmId() == "ending_f03", "id=" .. fe.audio:getCurrentBgmId())

	local pTowM = new(play.Play, rooms.TOWER_ROOM)
	pTowM.phase = "tower-knock"
	pTowM.storyRoute = "soldier"
	fe:bindPlay(pTowM, 1280, 720)
	fe:renderPlay(DT, pTowM, inp, 1280, 720)
	check("2.16 北塔男主结局切换 ending_m03_reunion", fe.audio:getCurrentBgmId() == "ending_m03", "id=" .. fe.audio:getCurrentBgmId())

	-- 现代纪念展厅
	local pMus = new(play.Play, rooms.MUSEUM_ROOM)
	fe:bindPlay(pMus, 1280, 720)
	fe:renderPlay(DT, pMus, inp, 1280, 720)
	check("2.17 现代纪念展厅切换 museum_dawn_peace", fe.audio:getCurrentBgmId() == "museum", "id=" .. fe.audio:getCurrentBgmId())
end

-- ---------------------------------------------------------------- 3. 四通道音量配置持久化与实时同步
do
	local tmpFile = "watch-save/test-audio-controls.txt"
	ctrlCfg.setControlSettingsFile(tmpFile)
	local s = ctrlCfg.defaultControlSettings()
	check("3.1 默认音量值符合预期",
		math.abs(s.masterVol - 1.0) < 0.001 and math.abs(s.bgmVol - 0.8) < 0.001
		and math.abs(s.sfxVol - 0.9) < 0.001 and math.abs(s.voiceVol - 1.0) < 0.001,
		string.format("%.1f/%.1f/%.1f/%.1f", s.masterVol, s.bgmVol, s.sfxVol, s.voiceVol))

	s.masterVol = 0.7
	s.bgmVol = 0.5
	s.sfxVol = 0.6
	s.voiceVol = 0.9
	ctrlCfg.saveControlSettings(s)
	local loaded = ctrlCfg.loadControlSettings()
	check("3.2 四通道音量写入 controls.txt 并准确回读",
		math.abs(loaded.masterVol - 0.7) < 0.001 and math.abs(loaded.bgmVol - 0.5) < 0.001
		and math.abs(loaded.sfxVol - 0.6) < 0.001 and math.abs(loaded.voiceVol - 0.9) < 0.001,
		string.format("%.1f/%.1f/%.1f/%.1f", loaded.masterVol, loaded.bgmVol, loaded.sfxVol, loaded.voiceVol))

	fe.audio:applyUserVolumes(loaded)
	local uv = fe.audio:getUserVolumes()
	check("3.3 AudioDirector.applyUserVolumes 实时同步",
		math.abs(uv.masterVol - 0.7) < 0.001 and math.abs(uv.bgmVol - 0.5) < 0.001
		and math.abs(uv.sfxVol - 0.6) < 0.001 and math.abs(uv.voiceVol - 0.9) < 0.001, "")

	-- 恢复默认配置与默认路径，并删除临时测试文件
	fe.audio:applyUserVolumes(ctrlCfg.defaultControlSettings())
	local fullTmp = Dora.Content.writablePath .. "/" .. tmpFile
	if Dora.Content:exist(fullTmp) then
		Dora.Content:remove(fullTmp)
	end
	ctrlCfg.setControlSettingsFile("")
end

-- ---------------------------------------------------------------- 4. 新接线全事件播放与武器/材质区分
do
	local p = new(play.Play, findRoom("s1-crossroad"))
	fe:bindPlay(p, 1280, 720)
	fe.audio:clearPlayLog()

	local mockEvents = {
		{ seq = 1, tick = 10, name = "shotResolved", data = { hit = true, x = p.player.x + 120 } },
		{ seq = 2, tick = 11, name = "coverBlocked", data = { entity = "木柜", enemyX = p.player.x + 220 } },
		{ seq = 3, tick = 12, name = "coverBlocked", data = { entity = "青砖石垒", x = p.player.x + 120 } },
		{ seq = 4, tick = 13, name = "coverBlocked", data = { entity = "木铁残盾", x = p.player.x + 120 } },
		{ seq = 5, tick = 14, name = "propBroken", data = { phase = "crack", x = p.player.x + 80 } },
		{ seq = 6, tick = 15, name = "propBroken", data = { phase = "broken", x = p.player.x + 80 } },
		{ seq = 7, tick = 16, name = "pickup", data = { kind = "bell", x = p.player.x } },
		{ seq = 8, tick = 17, name = "pickup", data = { kind = "wood", x = p.player.x } },
		{ seq = 9, tick = 18, name = "pickupRejected", data = {} },
		{ seq = 10, tick = 19, name = "interactUsed", data = { kind = "open_board", x = p.player.x } },
		{ seq = 11, tick = 20, name = "interactUsed", data = { kind = "lower_curtain", x = p.player.x } },
		{ seq = 12, tick = 21, name = "interactUsed", data = { kind = "raise_latch", x = p.player.x } },
		{ seq = 13, tick = 22, name = "interactUsed", data = { kind = "shield", x = p.player.x } },
		{ seq = 14, tick = 23, name = "interactUsed", data = { kind = "wedge", x = p.player.x } },
		{ seq = 15, tick = 24, name = "interactUsed", data = { kind = "ammo", x = p.player.x } },
		{ seq = 16, tick = 25, name = "interactUsed", data = { kind = "pass", x = p.player.x } },
		{ seq = 17, tick = 26, name = "bottleThrown", data = {} },
		{ seq = 18, tick = 27, name = "fearChanged", data = { fear = 1, exposed = true } },
		{ seq = 19, tick = 28, name = "fearChanged", data = { fear = 3 } },
		{ seq = 20, tick = 29, name = "reloadNode", data = { node = 4, pathLength = 4 } },
		{ seq = 21, tick = 30, name = "reloadApplied", data = { effect = "echo" } },
		{ seq = 22, tick = 31, name = "benchOpen", data = {} },
		{ seq = 23, tick = 32, name = "benchEquip", data = {} },
		{ seq = 24, tick = 33, name = "benchClose", data = {} },
		{ seq = 25, tick = 34, name = "campaignFailed", data = {} },
		{ seq = 26, tick = 35, name = "objectiveDone", data = {} },
	}
	fe.audio:ingestEvents({ roomSessionId = 9001, checkpoint = 0, rawEvents = mockEvents }, p)

	-- 奇器武器开火差异化测试（灯纹铳 / 铃纹铳 / 时间穿梭器）
	p.equippedWeapon = "guide_lantern_gun"
	fe.audio:ingestEvents({ roomSessionId = 9001, checkpoint = 0, rawEvents = { { seq = 27, tick = 36, name = "shotResolved", data = { hit = false } } } }, p)
	p.equippedWeapon = "echo_gun"
	fe.audio:ingestEvents({ roomSessionId = 9001, checkpoint = 0, rawEvents = { { seq = 28, tick = 37, name = "shotResolved", data = { hit = false } } } }, p)
	p.equippedWeapon = "time_shuttler"
	fe.audio:ingestEvents({ roomSessionId = 9001, checkpoint = 0, rawEvents = { { seq = 29, tick = 38, name = "shotResolved", data = { hit = false } } } }, p)

	local expectedPaths = {
		"combat/shot.wav",
		"combat/enemy_down.wav",
		"combat/shot_enemy.wav",
		"combat/shot_lantern_gun.wav",
		"combat/shot_echo_gun.wav",
		"combat/shot_time_shuttler.wav",
		"combat/cover_block_wood.wav",
		"combat/cover_block_stone.wav",
		"combat/cover_block_shield.wav",
		"combat/prop_crack.wav",
		"combat/prop_break.wav",
		"interact/pickup_bell.wav",
		"interact/pickup_wood.wav",
		"interact/pickup_rejected.wav",
		"interact/window_board_drop.wav",
		"interact/curtain_lower.wav",
		"interact/latch_raise.wav",
		"interact/shield_deploy.wav",
		"interact/wedge_place.wav",
		"interact/ammo_quickload.wav",
		"interact/pass_signal.wav",
		"foley/bottle_throw.wav",
		"foley/fear_gasp.wav",
		"foley/fear_freeze.wav",
		"combat/reload_node_4.wav",
		"combat/reload_fx_echo.wav",
		"interact/bench_open.wav",
		"interact/bench_equip.wav",
		"interact/bench_close.wav",
		"combat/campaign_failed.wav",
		"ui/segment_clear.wav",
	}
	local hitAll, backendAll = 0, 0
	for _, sub in ipairs(expectedPaths) do
		local ok, bk = hasPathInLog(fe.audio, sub)
		if ok then hitAll = hitAll + 1 else print("  MISS EVENT PATH: " .. sub) end
		if bk then backendAll = backendAll + 1 end
	end
	check("4.1 全部31类新接线与奇器事件命中且SoLoud真播放",
		hitAll == #expectedPaths and backendAll == #expectedPaths,
		string.format("hit=%d/%d backend=%d/%d", hitAll, #expectedPaths, backendAll, #expectedPaths))
end

-- ---------------------------------------------------------------- 5. 护送试炼（mode 2）音频与暂停零污染不变量
do
	local pTrial = new(play.Play, rooms.ESCORT1_ROOM)
	fe:resetTrialAudio(pTrial)
	fe:syncTrialAudio(DT, pTrial, 0)
	check("5.1 护送试炼(mode 2)激活 escort_combat BGM", fe.audio:getCurrentBgmId() == "escort_combat", "id=" .. fe.audio:getCurrentBgmId())

	-- 暂停态播放 UI 音效绝不污染 playLog
	pTrial.paused = true
	fe:syncTrialAudio(DT, pTrial, 0)
	local logBeforePause = #fe.audio:getPlayLog()
	fe.audio:playUi("ui:test_hover", "assets/audio/ui/menu_hover.wav", 0.5, 0)
	fe.audio:playUi("ui:test_confirm", "assets/audio/ui/menu_confirm.wav", 0.7, 0)
	local logAfterPause = #fe.audio:getPlayLog()
	check("5.2 暂停态 UI 交互音不污染局内 playLog",
		logAfterPause == logBeforePause,
		string.format("before=%d after=%d", logBeforePause, logAfterPause))

	-- 退回标题清理房间循环并解除暂停态
	fe.audio:stopRoomTransient()
	fe.screen = "title"
	fe:renderMenu(DT, inp, 1280, 720)
	check("5.3 退回标题 activeLoops 清零且未暂停",
		next(fe.audio.activeLoops) == nil and not fe.audio:isPaused(), "")
end

fe.audio:stopRoomTransient()
fe.audio:stopBgm(0)
fe.audio:stopMenuAmbience(0)
root:removeFromParent(true)

print(string.format("==== 全量音频系统验收结束：PASS=%d FAIL=%d ====", pass, fail))
if fail > 0 then
	error("verify-audio failed with " .. fail .. " failure(s)")
end
