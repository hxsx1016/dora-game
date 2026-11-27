-- D-C1 跨局档案与井口：隔离存档、两种通关顺序、重启读回、窗口与一次发放。
-- 跑法：复制到仓库根后
--   ~/Applications/Dora.app/Contents/MacOS/Dora cli run -p . --entry tmp-verify-c1.lua
--   ~/Applications/Dora.app/Contents/MacOS/Dora cli log -n 80
local Dora = require("Dora")
local Content = Dora.Content
Content:addSearchPath(Content.assetPath .. "/Script")
Content:addSearchPath(Content.assetPath .. "/Script/Lib")
Content:addSearchPath(Content.assetPath)
package.path = package.path .. ";" .. Content.assetPath .. "/?.lua"

local app = require("Script.watch.app")
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local input = require("Script.watch.input")
local runmod = require("Script.watch.run")
local save = require("Script.watch.save")
local lualib = package.loaded["Script.Lib.lualib_bundle"] or require("Script.Lib.lualib_bundle")

local PASS, FAIL = 0, 0
local function towerFinish(p, i)
	p.player.x = p.ox + 445
	i.interact.held = true; i.interact.pressed = true
	p:update(play.STEP, i); i.interact.pressed = false; i.interact.held = false
	for _ = 1, 40 do p:update(play.STEP, i) end
	p.player.x = p.ox + 605; p.player.y = 0
	i.interact.held = true
	for _ = 1, 40 do p:update(play.STEP, i); i.interact.pressed = false end
	i.interact.held = false
	for _ = 1, 200 do p:update(play.STEP, i); i.interact.pressed = false end
end
local function say(s) print(s) end
local function check(tag, cond, detail)
	if cond then PASS = PASS + 1; say("  PASS " .. tag)
	else FAIL = FAIL + 1; say("  FAIL " .. tag .. " | " .. tostring(detail or "")) end
end

-- 正式档案不参与本轮：先记下来，收尾核对它没被动过。
local formalFile = save.getSaveFile()
local function absOf(p) if string.sub(p, 1, 1) == "/" then return p end return Content.writablePath .. "/" .. p end
local formalText = Content:exist(absOf(formalFile)) and Content:load(absOf(formalFile)) or nil

local TEST_A = "watch-save/test-c1-a.txt"
local TEST_B = "watch-save/test-c1-b.txt"
local function drop(p)
    Content:remove(absOf(p))
    for _, sfx in ipairs({ ".tmp", ".prev", ".corrupt", ".reset", ".unsupported" }) do
        Content:remove(absOf(p .. sfx))
        for n = 2, 12 do Content:remove(absOf(p .. sfx .. "." .. n)) end
    end
end
drop(TEST_A); drop(TEST_B)

say("== C1-1. 新档：缺文件按空档案起局 ==")
save.setSaveFile(TEST_A)
local miss = save.loadSave()
check("缺文件报告 missing", miss.status == "missing", "status=" .. miss.status)
check("新档三项皆空", miss.state.childCleared == false and miss.state.soldierCleared == false
	and miss.state.artifactOwned == false, "archive=" .. tostring(miss.state.childCleared))

say("== C1-2. 单女通关：只记小满线，不发神器 ==")
local r1 = runmod.createRun(20261125, "official", miss.state)
r1.story.route = "child"
r1.story.settled = true
r1.story.countTick = 1440
local tower1 = lualib.__TS__New(play.Play, rooms.TOWER_ROOM, nil, r1)
tower1.storyRoute = "child"
tower1.storySettled = true
local i1 = lualib.__TS__New(input.Input)
local function tap(i, k) local ks = i[k]; ks.held = true; ks.pressed = true end
local function rel(i, k) local ks = i[k]; ks.held = false; ks.pressed = false; ks.released = false end
towerFinish(tower1, i1)
check("单女通关记 child", miss.state.childCleared == true, "child=" .. tostring(miss.state.childCleared))
check("单女不发神器", miss.state.artifactOwned == false, "artifact=" .. tostring(miss.state.artifactOwned))
check("结局标脏待落盘", tower1.archiveDirty == true, "dirty=" .. tostring(tower1.archiveDirty))
check("单女保存成功", save.saveSave(miss.state) == true)
local after1 = save.loadSave()
check("单女重启读回 child", after1.state.childCleared == true and after1.state.soldierCleared == false,
	"child=" .. tostring(after1.state.childCleared) .. " soldier=" .. tostring(after1.state.soldierCleared))

say("== C1-3. 单通未双通：序章井口不出现 ==")
local pro1 = lualib.__TS__New(play.Play, rooms.PROLOGUE_ROOM, nil, r1)
local ip1 = lualib.__TS__New(input.Input)
pro1:update(play.STEP, ip1)
check("单通井口关闭", pro1.wellOpen == false, "wellOpen=" .. tostring(pro1.wellOpen))
check("单通 pickWell 被拒", pro1:pickWell() == false)

say("== C1-4. 女后男：第二次通关补上男主线 ==")
local r2 = runmod.createRun(20261125, "official", after1.state)
r2.story.route = "soldier"
r2.story.settled = true
r2.story.segments["escort5"] = true
local tower2 = lualib.__TS__New(play.Play, rooms.TOWER_ROOM, nil, r2)
tower2.storyRoute = "soldier"
tower2.storySettled = true
towerFinish(tower2, i1)
check("女后男双通", after1.state.childCleared == true and after1.state.soldierCleared == true,
	"child=" .. tostring(after1.state.childCleared) .. " soldier=" .. tostring(after1.state.soldierCleared))
check("双通仍不发神器", after1.state.artifactOwned == false)
check("双通保存", save.saveSave(after1.state) == true)
local after2 = save.loadSave()
check("双通重启读回两线", after2.state.childCleared == true and after2.state.soldierCleared == true)

say("== C1-5. 双通后序章井口：只在等待段、只在井沿 ==")
local r3 = runmod.createRun(20261125, "official", after2.state)
local pro3 = lualib.__TS__New(play.Play, rooms.PROLOGUE_ROOM, nil, r3)
local ip3 = lualib.__TS__New(input.Input)
pro3:update(play.STEP, ip3)
check("双通等待段井口可见", pro3.wellOpen == true, "wellOpen=" .. tostring(pro3.wellOpen))
check("远处点井被拒", pro3:pickWell() == false)
pro3.player.x = 430
check("井沿点井成立", pro3:pickWell() == true)
check("进入拾取演出", pro3.phase == "prologue-well", "phase=" .. pro3.phase)
for _ = 1, 30 do pro3:update(play.STEP, ip3) end
check("取到穿梭器", pro3.run.archive.artifactOwned == true, "artifact=" .. tostring(pro3.run.archive.artifactOwned))
check("井口随即关闭", pro3.wellOpen == false and pro3.wellTaken == true)
check("回等待段继续找小满", pro3.phase == "prologue-wait", "phase=" .. pro3.phase)
local bags = {}
for _, e in ipairs(pro3:drainEvents()) do
	if e.name == "artifactFound" then bags[#bags + 1] = e end
end
check("只发一次 artifactFound", #bags == 1, "count=" .. tostring(#bags))
check("拾取后 pickWell 不再成立", pro3:pickWell() == false)

say("== C1-6. 拾取落盘与重启读回 ==")
check("拾取标脏", pro3.archiveDirty == true)
check("拾取保存", save.saveSave(after2.state) == true)
local after3 = save.loadSave()
check("重启读回 artifactOwned", after3.state.artifactOwned == true, "artifact=" .. tostring(after3.state.artifactOwned))
local r4 = runmod.createRun(20261125, "official", after3.state)
local pro4 = lualib.__TS__New(play.Play, rooms.PROLOGUE_ROOM, nil, r4)
local ip4 = lualib.__TS__New(input.Input)
pro4:update(play.STEP, ip4)
check("已取过则井口不再出现", pro4.wellOpen == false and pro4.wellTaken == false)

say("== C1-7. 窗口前后：递针套之后井口关闭 ==")
local r5 = runmod.createRun(20261125, "official", after3.state)
local pro5 = lualib.__TS__New(play.Play, rooms.PROLOGUE_ROOM, nil, r5)
local ip5 = lualib.__TS__New(input.Input)
pro5.player.x = 300
tap(ip5, "interact"); pro5:update(play.STEP, ip5); ip5.interact.pressed = false; ip5.interact.held = false
check("进入递针套", pro5.phase == "prologue-give", "phase=" .. pro5.phase)
check("窗口后井口关闭", pro5.wellOpen == false)

say("== C1-8. 两份 RunState 共享档案、局内各自清零 ==")
local shared = after3.state
local ra = runmod.createRun(20261125, "official", shared)
local rb = runmod.createRun(20261126, "official", shared)
ra.inventory.wood = 3; ra.story.route = "soldier"; ra.story.settled = true
check("档案是同一对象", ra.archive == rb.archive)
check("局内状态互不影响", rb.inventory.wood == 0 and rb.story.route == "" and rb.story.settled == false)
check("档案共享生效", rb.archive.artifactOwned == true)

say("== C1-9. 正式新局清局内、片尾再玩重开 ==")
local r6 = runmod.createRun(20261125, "official", after3.state)
r6.story.route = "child"; r6.story.settled = true; r6.story.carry = true
r6.story.cp = { id = 0 }
r6.inventory.wood = 2; r6.taken["e2_wood_a"] = true; r6.finished = true
local towerEnd = lualib.__TS__New(play.Play, rooms.TOWER_ROOM, nil, r6)
towerEnd.phase = "tower-end"
towerEnd.phaseTick = 0
tap(i1, "interact"); towerEnd:update(play.STEP, i1); i1.interact.pressed = false
check("片尾满 8 秒前 E 不误跳", towerEnd.wantRoom == "", "want=" .. tostring(towerEnd.wantRoom))
for _ = 1, play.TOWER_CONFIRM_TICKS do towerEnd:update(play.STEP, i1) end
check("片尾长按不自动再玩", towerEnd.wantRoom == "", "want=" .. tostring(towerEnd.wantRoom))
i1.interact.held = false
towerEnd:update(play.STEP, i1)
tap(i1, "interact"); towerEnd:update(play.STEP, i1); i1.interact.pressed = false; i1.interact.held = false
check("片尾满 8 秒后新按 E 请求回序章", towerEnd.wantRoom == "prologue", "want=" .. towerEnd.wantRoom)
check("片尾标记重开局内", towerEnd.restartStory == true)

say("== C1-10. 调试直达不写正式通关 ==")
local dbg = runmod.createRun(20261125, "debug", after3.state)
dbg.story.route = "soldier"; dbg.story.settled = true; dbg.story.segments["escort5"] = true
local towerDbg = lualib.__TS__New(play.Play, rooms.TOWER_ROOM, nil, dbg)
towerDbg.storyRoute = "soldier"; towerDbg.storySettled = true
towerFinish(towerDbg, i1)
check("调试直达仍落幕", dbg.story.ending == "reunion", "ending=" .. tostring(dbg.story.ending))
check("调试直达不标脏", towerDbg.archiveDirty == false)

say("== C1-11. 损坏与不支持版本：保留原文件并报告 ==")
Content:save(absOf(TEST_B), "garbage-not-a-save\n")
save.setSaveFile(TEST_B)
local bad = save.loadSave()
check("损坏报告 corrupt", bad.status == "corrupt", "status=" .. bad.status)
check("损坏回空档案", bad.state.childCleared == false)
check("损坏保留备份", bad.backup ~= "" and Content:exist(bad.backup) == true, "backup=" .. tostring(bad.backup))
Content:save(absOf(TEST_B), "version=9\nchildCleared=true\n")
local future = save.loadSave()
check("高版本报告 unsupported", future.status == "unsupported", "status=" .. future.status)
check("高版本原文件仍在", Content:load(absOf(TEST_B)) == "version=9\nchildCleared=true\n")
save.setSaveFile(formalFile)

say("== C1-12. 正式档案未被测试碰过 ==")
local finalFormal = save.getSaveFile()
check("测试后已切回正式文件", finalFormal == formalFile, "file=" .. finalFormal)
check("正式档案内容未变", (Content:exist(absOf(formalFile)) and Content:load(absOf(formalFile)) or nil) == formalText)

say(string.format("D-C1 跨局档案与井口：%d 通过 / %d 失败", PASS, FAIL))
assert(FAIL == 0, "D-C1 失败")
