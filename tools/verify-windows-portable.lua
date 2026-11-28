-- Windows 便携版存档目录（saves/）、多槽位存取、设置全持久化与标题/暂停菜单回归验收。
-- 使用隔离目录，绝不碰玩家正式档案。

local Dora = require("Dora")
local Content = Dora.Content
local Path = Dora.Path
local new = require("lualib_bundle").__TS__New

local save = require("Script.watch.save")
local controls = require("Script.watch.controls_config")
local rooms = require("Script.watch.rooms")
local runmod = require("Script.watch.run")
local play = require("Script.watch.play")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local targetMod = require("Script.watch.target")

local PASS, FAIL = 0, 0
local function check(tag, cond, detail)
	if cond then
		PASS = PASS + 1
		print("PASS win-portable: " .. tag)
	else
		FAIL = FAIL + 1
		print("FAIL win-portable: " .. tag .. (detail and (" | " .. tostring(detail)) or ""))
	end
end

local origWritable = Content.writablePath
local origRelease = package.loaded["watch.release"]
local origTarget = package.loaded["watch.target"]

local testRoot = Path(origWritable, "_test_win_portable_saves")
if Content:exist(testRoot) then
	Content:remove(testRoot)
end
Content:mkdir(testRoot)

local okRun, errRun = xpcall(function()
	-- 1. 模拟 Windows 便携模式（saveLayout = "portable"，writablePath 直接指向 saves/）
	Content.writablePath = testRoot
	package.loaded["watch.target"] = "windows"
	package.loaded["watch.release"] = {
		isRelease = true,
		version = "verify-portable",
		target = "windows",
		portableSave = true,
		saveLayout = "portable",
	}
	targetMod.resetActiveTarget()
	save.setSaveFile("")
	save.setSessionFile("")
	controls.setControlSettingsFile("")

	-- 1a. 全局档案写到 profile.sav，备份落到 backups/profile.sav.prev
	local st1 = save.emptySave()
	st1.childCleared = true
	check("1.1 portable profile path is profile.sav", save.getSaveFile() == "profile.sav", save.getSaveFile())
	check("1.2 first profile save succeeds", save.saveSave(st1) == true)
	check("1.3 profile.sav created directly under saves root", Content:exist(Path(testRoot, "profile.sav")))
	check("1.4 no nested watch-save dir created", not Content:exist(Path(testRoot, "watch-save")))

	local st2 = save.emptySave()
	st2.childCleared = true
	st2.soldierCleared = true
	check("1.5 second profile save creates backup in backups/", save.saveSave(st2) == true)
	check("1.6 backups/profile.sav.prev exists", Content:exist(Path(testRoot, "backups", "profile.sav.prev")))
	check("1.7 no .prev pollutes saves root", not Content:exist(Path(testRoot, "profile.sav.prev")))

	local loadedProfile = save.loadSave()
	check("1.8 reload portable profile ok", loadedProfile.status == "ok" and loadedProfile.state.soldierCleared == true)

	-- 1b. 自动存档 + 3 手动槽位（autosave.sav + slots/slot_1..3.sav）
	local officialRun = runmod.createRun(20261128, "official", save.emptySave())
	local p = new(play.Play, rooms.OUTSIDE_ROOM, nil, officialRun)
	local snapAuto = p:exportSession()
	snapAuto.route = "child"
	snapAuto.hp = 2
	snapAuto.maxHp = 3
	snapAuto.playSeconds = 125
	check("2.1 saveSession writes autosave.sav", save.saveSession(snapAuto) == true and Content:exist(Path(testRoot, "autosave.sav")))

	local snapSlot1 = p:exportSession()
	snapSlot1.roomKey = "gate"
	snapSlot1.route = "soldier"
	snapSlot1.hp = 3
	snapSlot1.maxHp = 3
	snapSlot1.playSeconds = 420
	check("2.2 saveSlot(1) writes slots/slot_1.sav", save.saveSlot(1, snapSlot1) == true and Content:exist(Path(testRoot, "slots", "slot_1.sav")))

	local snapSlot1v2 = p:exportSession()
	snapSlot1v2.roomKey = "escort2"
	snapSlot1v2.route = "soldier"
	snapSlot1v2.hp = 2
	snapSlot1v2.maxHp = 4
	snapSlot1v2.playSeconds = 610
	check("2.3 overwrite slot 1 puts backup in backups/slot_1.sav.prev",
		save.saveSlot(1, snapSlot1v2) == true and Content:exist(Path(testRoot, "backups", "slot_1.sav.prev")))

	local slots = save.listSaveSlots()
	check("2.4 listSaveSlots returns 4 entries (auto + 1..3)", #slots == 4 and slots[1].id == "auto" and slots[2].id == 1 and slots[3].id == 2 and slots[4].id == 3)
	check("2.5 auto slot metadata preserved", slots[1].exists == true and slots[1].roomKey == "outside" and slots[1].playSeconds == 125)
	check("2.6 slot 1 metadata updated after overwrite", slots[2].exists == true and slots[2].roomKey == "escort2" and slots[2].hp == 2 and slots[2].maxHp == 4 and slots[2].playSeconds == 610)
	check("2.7 empty slots 2 & 3 report exists=false", slots[3].exists == false and slots[4].exists == false)

	local loadedSlot1 = save.loadSlot(1)
	check("2.8 loadSlot(1) restores exact state", loadedSlot1.status == "ok" and loadedSlot1.state ~= nil and loadedSlot1.state.roomKey == "escort2" and loadedSlot1.state.playSeconds == 610)

	check("2.9 deleteSlot(1) clears slot 1 cleanly", save.deleteSlot(1) == true and save.hasSlotSave(1) == false)

	-- 1c. 设置全持久化（settings.ini：四通道音量 + fullscreen + winWidth/winHeight + muted + assistHints）
	local cfg = controls.defaultControlSettings()
	cfg.masterVol = 0.7
	cfg.bgmVol = 0.5
	cfg.sfxVol = 0.6
	cfg.voiceVol = 0.9
	cfg.fullscreen = true
	cfg.winWidth = 1600
	cfg.winHeight = 900
	cfg.muted = true
	cfg.assistHints = true
	controls.saveControlSettings(cfg)
	check("3.1 settings saved to settings.ini", Content:exist(Path(testRoot, "settings.ini")))
	local cfgBack = controls.loadControlSettings()
	check("3.2 settings round-trip all display/audio/assist fields",
		math.abs(cfgBack.masterVol - 0.7) < 0.01
		and math.abs(cfgBack.bgmVol - 0.5) < 0.01
		and cfgBack.fullscreen == true
		and cfgBack.winWidth == 1600
		and cfgBack.winHeight == 900
		and cfgBack.muted == true
		and cfgBack.assistHints == true)

	-- 2. 菜单交互验收：新游戏覆盖确认 + 标题页读档/设置 + 暂停页多槽位存取
	local root = Dora.Node()
	local fe = new(Frontend, root)
	local input = new(Input)
	input.inside = false
	fe.screen = "title"
	fe.menus.hasSession = true
	fe.menus:setSessionRoomKey("outside")
	fe.menus:refreshSaveSlots()

	-- 2a. 有自动存档时，点选「开始游戏」(index 1) 弹出二次确认，默认选中「取消返回」
	fe.menus.selected = 1
	fe.menus:onKeyEvent("Return")
	local actConfirmOpen = fe:renderMenu(1 / 60, input, 1280, 720)
	check("4.1 clicking Start with autosave opens confirmation dialog",
		actConfirmOpen.type == "none" and fe.menus:isShowingTitleConfirm() == true)

	fe.menus:onKeyEvent("Return")
	local actCancel = fe:renderMenu(1 / 60, input, 1280, 720)
	check("4.2 default selection cancels safely without wiping autosave",
		actCancel.type == "none" and fe.menus:isShowingTitleConfirm() == false)

	fe.menus:onKeyEvent("Return")
	fe:renderMenu(1 / 60, input, 1280, 720)
	fe.menus:onKeyEvent("Left")
	fe:renderMenu(1 / 60, input, 1280, 720)
	fe.menus:onKeyEvent("Return")
	local actStartOk = fe:renderMenu(1 / 60, input, 1280, 720)
	check("4.3 confirming new game emits start", actStartOk.type == "start")

	-- 2b. 标题页「读取存档」与「游戏设置」页渲染零报错
	fe.menus.hasSession = false
	fe.menus.selected = 3
	fe.menus:onKeyEvent("Return")
	local actOpenSaves = fe:renderMenu(1 / 60, input, 1280, 720)
	check("4.4 title index 3 emits openSaves", actOpenSaves.type == "openSaves")
	fe.screen = "saves"
	fe:renderMenu(1 / 60, input, 1280, 720)

	fe.screen = "title"
	fe.menus.selected = 4
	fe.menus:onKeyEvent("Return")
	local actOpenSettings = fe:renderMenu(1 / 60, input, 1280, 720)
	check("4.5 title index 4 emits openSettings", actOpenSettings.type == "openSettings")
	fe.screen = "settings"
	fe:renderMenu(1 / 60, input, 1280, 720)

	-- 2c. 暂停页末项「存取档案」打开并存入空槽位 1
	fe:bindPlay(p, 1280, 720)
	fe.screen = "play"
	p.paused = true
	fe.menus:openPause()
	fe.menus.pauseSelected = 9
	fe.menus:onKeyEvent("Return")
	fe:renderPlay(1 / 60, p, input, 1280, 720)
	check("4.6 pause last item opens in-place saves panel", fe.menus:isShowingPauseSaves() == true)

	-- 默认聚焦槽位 1（空档），按回车立即返回 saveSlot(1)
	fe.menus:onKeyEvent("Return")
	local saveSlotAct = fe:renderPlay(1 / 60, p, input, 1280, 720)
	check("4.7 empty slot 1 triggers saveSlot(1)", saveSlotAct.type == "saveSlot" and saveSlotAct.slot == 1)

	root:cleanup()
end, debug.traceback)

-- 还原环境与清理临时目录
Content.writablePath = origWritable
package.loaded["watch.release"] = origRelease
package.loaded["watch.target"] = origTarget
targetMod.resetActiveTarget()
save.setSaveFile("")
save.setSessionFile("")
controls.setControlSettingsFile("")
if Content:exist(testRoot) then
	Content:remove(testRoot)
end

if not okRun then
	error(errRun)
end
print(string.format("WIN PORTABLE VERIFY PASS %d / FAIL %d", PASS, FAIL))
assert(FAIL == 0, "verify-windows-portable failed")
