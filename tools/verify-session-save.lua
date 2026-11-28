-- PR 3 验收（2/2）：局中存档（session.txt）原子落盘、跨重启续读、损坏隔离、来源隔离与通关清理
local Dora = require("Dora")
local Content = Dora.Content
local new = require("lualib_bundle").__TS__New
local app = require("Script.watch.app")
local rooms = require("Script.watch.rooms")
local playmod = require("Script.watch.play")
local runmod = require("Script.watch.run")
local savemod = require("Script.watch.save")
local inputmod = require("Script.watch.input")

local pass, fail = 0, 0
local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS session: %-44s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL session: %-44s %s", tag, detail or ""))
	end
end

local function absOf(rel)
	return Content.writablePath .. "/" .. rel
end

local origSave = savemod.getSaveFile()
local origSess = savemod.getSessionFile()
local TEST_ARCHIVE = "watch-save/test-pr3-archive.txt"
local TEST_SESSION = "watch-save/test-pr3-session.txt"

local function cleanupFiles()
	for _, rel in ipairs({
		TEST_ARCHIVE, TEST_ARCHIVE .. ".tmp", TEST_ARCHIVE .. ".prev",
		TEST_SESSION, TEST_SESSION .. ".tmp", TEST_SESSION .. ".prev",
		TEST_SESSION .. ".corrupt", TEST_SESSION .. ".unsupported",
	}) do
		local p = absOf(rel)
		if Content:exist(p) then Content:remove(p) end
	end
end

cleanupFiles()
savemod.setSaveFile(TEST_ARCHIVE)
savemod.setSessionFile(TEST_SESSION)

-- 1. 空状态无局中存档
check("1.1 初始无局中存档", savemod.hasSessionSave() == false)
local emptyRes = savemod.loadSession()
check("1.2 读取缺失局中存档返回 missing", emptyRes.status == "missing" and emptyRes.state == nil)

-- 2. 风台数数中段（countTick=720）落盘并读回
do
	local r = runmod.createRun(20261124, "official", runmod.createArchive())
	r.story.route = "child"; r.story.settled = true
	r.story.hp = 2; r.story.maxHp = 3; r.story.hpAtGate = 2; r.story.maxHpAtGate = 3
	r.story.phase = "gate-count"; r.story.countTick = 720
	local p = new(playmod.Play, rooms.GATE_ROOM, nil, r)
	local snap = p:exportSession()
	check("2.1 导出风台局中快照字段完整",
		snap.roomKey == "gate" and snap.route == "child" and snap.countTick == 720 and snap.hp == 2 and snap.hpAtGate == 2)
	check("2.2 saveSession 原子落盘成功", savemod.saveSession(snap) == true and savemod.hasSessionSave() == true)
	local loaded = savemod.loadSession()
	check("2.3 loadSession 精确读回同一拍与锁存血量",
		loaded.status == "ok" and loaded.state ~= nil
		and loaded.state.roomKey == "gate"
		and loaded.state.countTick == 720
		and loaded.state.hpAtGate == 2 and loaded.state.settled == true)
end

-- 3. 完整 app.start + continueStory() 续读：恢复工台改制武器、背包材料与已拾取记录
do
	local appRoot = Dora.Node()
	app.start(appRoot, 1, "title")
	local wf = package.loaded["watch.fe"]
	wf.useTestSave(TEST_ARCHIVE)
	wf.useTestSession(TEST_SESSION)

	-- 构造一笔 escort3 制后快照并落盘
	local arch = { childCleared = true, soldierCleared = true, artifactOwned = true, museumPhase = "done", museumSeen = true }
	savemod.saveSave(arch)
	wf.useTestSave(TEST_ARCHIVE)
	wf.useTestSession(TEST_SESSION)

	local r = runmod.createRun(20261124, "official", arch)
	r.story.route = "soldier"; r.story.settled = true
	r.story.hp = 3; r.story.maxHp = 3; r.story.hpAtGate = 3; r.story.maxHpAtGate = 3
	r.story.carry = true; r.story.craftedWeapon = "guide_lantern_gun"; r.story.equippedWeapon = "time_shuttler"
	r.story.segments["escort1"] = true; r.story.segments["escort2"] = true
	r.inventory.wood = 1; r.inventory.bell = 2
	r.taken["e2_wood_a"] = true
	local p3 = new(playmod.Play, rooms.ESCORT3_ROOM, { checkpoint = 960 }, r)
	savemod.saveSession(p3:exportSession())

	check("3.1 存在局中存档时 hasSessionSave 为真", wf.hasSessionSave() == true)
	local resumed = wf.continueStory()
	check("3.2 continueStory 精确恢复房间、检查点、材料、武器与已拾取项",
		resumed ~= nil
		and resumed.room.key == "escort3"
		and resumed.checkpoint == 960
		and resumed.equippedWeapon == "time_shuttler"
		and resumed.run.story.craftedWeapon == "guide_lantern_gun"
		and resumed.inventory.wood == 1 and resumed.inventory.bell == 2
		and resumed.run.taken["e2_wood_a"] == true
		and resumed.run.story.segments["escort2"] == true,
		resumed and string.format("room=%s cp=%d eq=%s wood=%d bell=%d",
			resumed.room.key, resumed.checkpoint, resumed.equippedWeapon, resumed.inventory.wood, resumed.inventory.bell) or "nil")

	-- 4. 章节预览不覆盖正式局中档
	local beforeText = Content:load(absOf(TEST_SESSION))
	wf.previewChapter(2)
	check("4.1 章节预览调用 saveSessionNow 被拒绝且不改正式局中档",
		wf.saveSessionNow() == false and Content:load(absOf(TEST_SESSION)) == beforeText)

	-- 5. 清除局中档后标题不再显示继续游戏
	check("5.1 clearSessionNow 清除成功", wf.clearSessionNow() == true and wf.hasSessionSave() == false)
	check("5.2 标题菜单 hasSession 同步关闭", wf.getFrontend().menus.hasSession == false)

	appRoot:cleanup()
end

-- 6. 损坏局中档能自动从 .prev 恢复，无 .prev 时隔离备份并报 corrupt
do
	local r = runmod.createRun(20261124, "official", runmod.createArchive())
	r.story.route = "child"; r.story.settled = true
	local p = new(playmod.Play, rooms.VILLAGE_ROOM, nil, r)
	savemod.saveSession(p:exportSession())
	-- 写第二次生成 .prev
	r.story.segments["outside_cart"] = true
	savemod.saveSession(p:exportSession())
	-- 破坏主文件，应自动从 .prev 恢复
	Content:save(absOf(TEST_SESSION), "corrupted-garbage\n")
	local rec = savemod.loadSession()
	check("6.1 主局中档损坏时自动从 .prev 恢复",
		rec.status == "ok" and rec.recovered == true and rec.state ~= nil and rec.state.roomKey == "village",
		"status=" .. rec.status .. " rec=" .. tostring(rec.recovered))

	-- 同时删 .prev 并破坏主文件，报 corrupt 且保留备份
	Content:remove(absOf(TEST_SESSION .. ".prev"))
	Content:save(absOf(TEST_SESSION), "broken-without-prev\n")
	local bad = savemod.loadSession()
	check("6.2 无 .prev 损坏时报告 corrupt 并隔离备份",
		bad.status == "corrupt" and bad.backup ~= "" and Content:exist(bad.backup) == true)
end

-- 7. 自动档与手动档共用的跨版本、恢复和删除边界。槽位跟随隔离测试路径。
do
	local slot = 1
	local path = absOf(savemod.getSlotFile(slot))
	local lf = "version=1\nroomKey=gate\nroute=child\nhp=2\nmaxHp=3\n"
	local future = "version=9\nroomKey=future-room\n"
	local snap = assert(savemod.parseSession(lf).state)
	local function write(target, text) assert(Content:save(target, text)) end
	local function intercept(copy, remove)
		savemod.setFileOpsForTest({
			exist = function(_, p) return Content:exist(p) end,
			load = function(_, p) return Content:load(p) end,
			save = function(_, p, text) return Content:save(p, text) end,
			copy = function(_, a, b) return copy(a, b) end,
			remove = function(_, p) return remove(p) end,
			isdir = function(_, p) return Content:isdir(p) end,
			mkdir = function(_, p) return Content:mkdir(p) end,
		})
	end
	local function realCopy(a, b) return Content:copy(a, b) end
	local function realRemove(p) return Content:remove(p) end
	local crlf = lf:gsub("\n", "\r\n")
	local parsed = savemod.parseSession(crlf .. "roomKey=duplicate\r\n")
	check("7.1 CRLF 与重复键按旧格式读取", parsed.ok and parsed.state.roomKey == "gate" and parsed.state.hp == 2)

	write(path, future)
	write(path .. ".prev", lf)
	write(path .. ".tmp", lf)
	local summary = savemod.listSaveSlots()[2]
	check("7.2 新版主文件不因旧备份而显示可读", summary.status == "unsupported" and not summary.exists and not savemod.hasSlotSave(slot))
	check("7.3 未先读档也保护新版及其恢复候选", not savemod.saveSlot(slot, snap)
		and Content:load(path) == future and Content:load(path .. ".tmp") == lf and Content:load(path .. ".prev") == lf)
	local archivePath = absOf(TEST_ARCHIVE)
	write(archivePath, future)
	check("7.4 主档案直接写入也保护新版", not savemod.saveSave(savemod.emptySave()) and Content:load(archivePath) == future)

	write(path, "broken")
	write(path .. ".tmp", lf)
	intercept(function(a, b)
		if b:find(".corrupt", 1, true) then return false end
		return realCopy(a, b)
	end, realRemove)
	local failedRead = savemod.loadSlot(slot)
	local failedWrite = savemod.saveSlot(slot, snap)
	savemod.setFileOpsForTest(nil)
	check("7.5 隔离失败保留损坏原件与恢复候选", failedRead.status == "corrupt" and not failedRead.recovered
		and not failedWrite and Content:load(path) == "broken" and Content:load(path .. ".tmp") == lf)

	write(path, lf)
	write(path .. ".prev", lf)
	intercept(realCopy, function(p)
		if p == path .. ".prev" then return false end
		return realRemove(p)
	end)
	local deleted = savemod.deleteSlot(slot)
	savemod.setFileOpsForTest(nil)
	check("7.6 备份删除失败保留当前进度并返回失败", not deleted and Content:load(path) == lf)
	check("7.7 重试删除后槽位保持为空", savemod.deleteSlot(slot) and not savemod.hasSlotSave(slot) and savemod.loadSlot(slot).status == "missing")

	write(path .. ".tmp", lf)
	intercept(function(a, b)
		if b == path then return false end
		return realCopy(a, b)
	end, realRemove)
	local saved = savemod.saveSlot(slot, snap)
	savemod.setFileOpsForTest(nil)
	check("7.8 写入失败保留唯一的旧临时档", not saved and Content:load(path .. ".tmp") == lf)
	savemod.deleteSlot(slot)
end

cleanupFiles()
savemod.setSaveFile(origSave)
savemod.setSessionFile(origSess)
print(string.format("SESSION SAVE VERIFY PASS %d / FAIL %d", pass, fail))
assert(fail == 0, "session save verification failed")
