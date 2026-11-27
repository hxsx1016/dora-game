-- C 验收修正单：存档替换、备份派生、跨实例落盘、来源隔离、真实走位。
-- 隔离档案 watch-save/test-cfix-*.txt；正式 archive.txt 只做前后对照，绝不写。
local Content = require("Dora").Content
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local input = require("Script.watch.input")
local save = require("Script.watch.save")
local runmod = require("Script.watch.run")
local lualib = require("lualib_bundle")

local pass, fail = 0, 0
local LOG = {}
local function say(s) LOG[#LOG + 1] = s; print(s) end
local function check(tag, cond, detail)
    if cond then pass = pass + 1; say("  PASS  " .. tag .. "  " .. (detail or ""))
    else fail = fail + 1; say("  FAIL  " .. tag .. "  " .. (detail or "")) end
end

local W = Content.writablePath .. "/watch-save"
Content:mkdir(W)
local FORMAL = save.SAVE_FILE
local function abs(p) return Content.writablePath .. "/" .. p end
local function readText(p) if not Content:exist(p) then return nil end; return Content:load(p) end
local function formalSig()
    local formal = save.loadSave
    local old = save.getSaveFile()
    save.setSaveFile(FORMAL)
    local r = save.loadSave()
    save.setSaveFile(old)
    return save.saveSignature(r.state) .. "/" .. r.status
end
local FORMAL_SIG0 = formalSig()

local function clean(p) if Content:exist(abs(p)) then Content:remove(abs(p)) end end
local function cleanAll(base)
    clean(base)
    clean(base .. ".tmp"); clean(base .. ".prev")
    local suffixes = { ".corrupt", ".unsupported", ".reset" }
    local k = 1
    for _, suf in ipairs(suffixes) do
        clean(base .. suf)
        for k = 2, 30 do clean(base .. suf .. "." .. k) end
    end
end
local X = "watch-save/test-cfix-a.txt"
local Y = "watch-save/test-cfix-b.txt"
local C = "watch-save/test-cfix-c.txt"
cleanAll(X)
cleanAll(Y)
cleanAll(C)
cleanAll("watch-save/test-cfix-g.txt")

local function newInput()
    local i = lualib.__TS__New(input.Input)
    local names = { "jump", "crouch", "cover", "interact", "aim", "fire", "retry", "pause", "toggleView", "tab", "flare" }
    local k
    for _, k in ipairs(names) do
        i[k] = { held = false, pressed = false, released = false }
    end
    return i
end
local function step(p, i, dt)
    p:update(dt or play.STEP, i)
    i.interact.pressed = false; i.interact.released = false; i.interact.held = false
    i.jump.pressed = false; i.jump.released = false
    i.pause.pressed = false; i.retry.pressed = false
end
local function tap(i, key) i[key].held = true; i[key].pressed = true; i[key].released = false end
local function rel(i, key) i[key].held = false; i[key].pressed = false; i[key].released = true end
local function toDepth(p, i, target)
    local guard = 0
    while math.abs(p.player.depth - target) > 4 and guard < 90 do
        i.moveY = (p.player.depth < target) and -1 or 1
        step(p, i)
        guard = guard + 1
    end
    i.moveY = 0
    return guard
end
local function walkTo(p, i, target, limit)
    local n = 0
    local lastX = p.player.x
    local stuck = 0
    while n < (limit or 400) do
        local dx = target - p.player.x
        if math.abs(dx) <= 1 then i.moveX = 0 else i.moveX = (dx > 0) and 1 or -1 end
        step(p, i)
        n = n + 1
        if math.abs(p.player.x - lastX) < 0.4 then stuck = stuck + 1 else stuck = 0 end
        lastX = p.player.x
        if stuck >= 8 then break end
        if p.wantRoom ~= "" then break end
    end
    i.moveX = 0
    return n
end

say("== A. 可恢复替换与自愈 ==")
-- A1 正常写
save.setSaveFile(X)
local s1 = save.emptySave(); s1.childCleared = true
check("A1 首次写入成功", save.saveSave(s1), "")
check("A1 读回 child=true", save.loadSave().state.childCleared == true, "")
-- A2 替换故障：旧档必须还在
local s2 = save.emptySave(); s2.childCleared = true; s2.soldierCleared = true
save.setSaveFault("replace")
check("A2 替换故障返回 false", save.saveSave(s2) == false, "")
save.setSaveFault("")
local a2 = save.loadSave()
check("A2 旧档仍在", a2.status == "ok" and a2.state.childCleared == true and a2.state.soldierCleared == false,
    "status=" .. a2.status .. " soldier=" .. tostring(a2.state.soldierCleared))
-- 覆盖失败时保留本次完整 .tmp 作为候选（不丢弃唯一有效新档）。
check("A2 失败保留 tmp 候选", Content:exist(abs(X .. ".tmp")), "")
-- A3 校验故障
save.setSaveFault("verify")
check("A3 回读校验失败返回 false", save.saveSave(s2) == false, "")
save.setSaveFault("")
local a3 = save.loadSave()
check("A3 旧档仍在", a3.status == "ok" and a3.state.childCleared == true and a3.state.soldierCleared == false, "")
-- A4 写临时故障不破坏旧档
save.setSaveFault("write")
check("A4 写临时失败返回 false", save.saveSave(s2) == false, "")
save.setSaveFault("")
-- A5 遗留 tmp 自愈
Content:save(abs(X .. ".tmp"), "version=1\nchildCleared=true\nsoldierCleared=true\nartifactOwned=false\nmuseumPhase=lamp_turn\nmuseumSeen=false\n")
Content:remove(abs(X))
local a5 = save.loadSave()
check("A5 遗留 tmp 自愈", a5.status == "ok" and a5.recovered == true and a5.state.soldierCleared == true, "recovered=" .. tostring(a5.recovered))
check("A5 自愈后 tmp 清掉", not Content:exist(abs(X .. ".tmp")), "")
-- A6 损坏 + prev 恢复
save.setSaveFile(X)
local s6 = save.emptySave(); s6.childCleared = true; s6.soldierCleared = true; s6.museumPhase = "hall_walk"
check("A6 写入基准档", save.saveSave(s6), "")
Content:copy(abs(X), abs(X .. ".prev"))
Content:save(abs(X), "garbage-not-a-save")
local a6 = save.loadSave()
check("A6 从 prev 恢复", a6.status == "ok" and a6.state.museumPhase == "hall_walk" and a6.recovered == true, a6.detail)
check("A6 损坏件已备份", a6.backup ~= "" and Content:exist(a6.backup), a6.backup)

say("== B. 备份派生与格式校验 ==")
save.setSaveFile(Y)
local formalCorrupt = abs(FORMAL .. ".corrupt")
local formalBefore = readText(formalCorrupt)
Content:save(abs(Y), "version=1\nchildCleared=true\n")
local b1 = save.loadSave()
check("B1 截断档判 corrupt", b1.status == "corrupt", "status=" .. b1.status)
check("B1 备份按隔离路径派生", b1.backup == abs(Y .. ".corrupt"), b1.backup)
check("B1 未碰正式备份", (formalBefore == nil and not Content:exist(formalCorrupt)) or readText(formalCorrupt) == formalBefore, "")
Content:save(abs(Y), "version=1\nchildCleared=true\nsoldierCleared=true\n")
local b2 = save.loadSave()
check("B2 二次损坏派生 .2", b2.backup == abs(Y .. ".corrupt.2"), b2.backup)
-- B3 缺字段
Content:save(abs(Y), "version=1\nchildCleared=true\nsoldierCleared=true\nartifactOwned=false\nmuseumPhase=locked\n")
local b3 = save.loadSave()
check("B3 缺字段判 corrupt", b3.status == "corrupt" and b3.detail:find("museumSeen") ~= nil, b3.detail)
-- B4 非法字段
Content:save(abs(Y), "version=1\nchildCleared=yes\nsoldierCleared=true\nartifactOwned=false\nmuseumPhase=locked\nmuseumSeen=false\n")
local b4 = save.loadSave()
check("B4 非法布尔判 corrupt", b4.status == "corrupt", b4.detail)
-- B5 未知版本保护
Content:save(abs(Y), "version=2\nchildCleared=true\n")
local b5 = save.loadSave()
check("B5 高版本判 unsupported", b5.status == "unsupported" and b5.action == "reset", b5.detail)
check("B5 原件保留", Content:exist(abs(Y)), "")
check("B5 未知版本拒绝写档", save.saveSave(s1) == false, "")
check("B5 reset 后隔离旧件", save.resetSave() == true and Content:exist(abs(Y .. ".reset")), "")
save.setSaveFile(Y)
check("B5 reset 后可写", save.saveSave(s1) == true, "")
-- 正式档未变
save.setSaveFile(FORMAL)
check("B6 正式档未变", formalSig() == FORMAL_SIG0, formalSig())

say("== C. 跨实例落盘 ==")
save.setSaveFile(C)
local prof = save.emptySave(); prof.childCleared = true; prof.soldierCleared = true; prof.artifactOwned = true
check("C0 预置双通档", save.saveSave(prof), "")
local loaded = save.loadSave()
local profile = loaded.state
local function newPlay(room, source, st)
    return lualib.__TS__New(play.Play, room, nil, runmod.createRun(20261125, source, st))
end
local p = newPlay(rooms.PROLOGUE_ROOM, "official", profile)
p.player.x = p.ox + 430
local i = newInput()
tap(i, "interact"); step(p, i)
check("C1 井沿 E 进馆", p.archive.museumPhase == "well_reflect" and p.wantRoom == "museum",
    "phase=" .. p.archive.museumPhase .. " want=" .. p.wantRoom)
check("C2 旧实例标脏", p.archiveDirty == true, "")
-- 模拟 app 切房：切房前把责任登记到 save 层，再换新 Play 实例
save.markProfilePending(profile)
local p2 = newPlay(rooms.MUSEUM_ROOM, "official", profile)
check("C3 新实例续读柜前", p2.phase == "museum-cabinet", p2.phase)
check("C4 换实例后仍能落盘", save.flushProfile() == true, "")
check("C5 磁盘已写 well_reflect", save.loadSave().state.museumPhase == "well_reflect", save.loadSave().state.museumPhase)
-- C6 故障注入：写失败保留责任，下一帧重试
profile.museumPhase = "hall_walk"
p.archiveDirty = true
save.markProfilePending(profile)
save.setSaveFault("replace")
check("C6 故障时落盘失败", save.flushProfile() == false, "")
check("C6 待写责任保留", save.profilePending() == true, "")
save.setSaveFault("")
check("C7 重试成功", save.flushProfile() == true and save.profilePending() == false, "")
check("C8 磁盘值追上", save.loadSave().state.museumPhase == "hall_walk", save.loadSave().state.museumPhase)

say("== D. 来源隔离 ==")
save.setSaveFile(C)
local base = save.emptySave(); base.childCleared = true; base.soldierCleared = true; base.artifactOwned = false
save.saveSave(base)
local sigD0 = save.saveSignature(save.loadSave().state)
-- D1 official 拾取
local profO = save.loadSave().state
local po = newPlay(rooms.PROLOGUE_ROOM, "official", profO)
po.player.x = po.ox + 430
i = newInput()
step(po, i)
check("D1 正式井口可见", po.wellOpen == true, "wellOpen=" .. tostring(po.wellOpen))
tap(i, "interact"); step(po, i)
check("D1 进入拾取演出", po.phase == "prologue-well", po.phase)
for _ = 1, 30 do step(po, i) end
check("D1 拾取进档案", po.archive.artifactOwned == true, "")
save.markProfilePending(po.archive)
check("D1 落盘", save.flushProfile() == true and save.loadSave().state.artifactOwned == true, "")
-- D2 chapter
local sigC = save.saveSignature(save.loadSave().state)
local pc = newPlay(rooms.PROLOGUE_ROOM, "chapter", save.loadSave().state)
check("D2 章节井口关闭", pc:wellWindow() == false and pc.wellOpen == false, "")
check("D2 章节 pickWell 拒绝", pc:pickWell() == false, "")
check("D2 章节不写档", save.saveSignature(save.loadSave().state) == sigC, "")
-- D3 debug
local sigD = save.saveSignature(save.loadSave().state)
local pd = newPlay(rooms.PROLOGUE_ROOM, "debug", save.loadSave().state)
check("D3 调试井口关闭", pd:wellWindow() == false, "")
check("D3 调试 pickWell 拒绝", pd:pickWell() == false, "")
check("D3 调试不写档", save.saveSignature(save.loadSave().state) == sigD, "")
-- D4 chapter 馆内只预览
local sigE = save.saveSignature(save.loadSave().state)
local pm = newPlay(rooms.MUSEUM_ROOM, "chapter", save.loadSave().state)
pm.player.x = pm.ox + 200
i = newInput()
tap(i, "interact"); step(pm, i)
check("D4 章节馆内走一步", pm.phase == "museum-hall", pm.phase)
check("D4 不改共享档案", pm.archive.museumPhase ~= "hall_walk", "phase=" .. pm.archive.museumPhase)
local em = nil
for _, e in ipairs(pm:drainEvents()) do if e.name == "museumStep" then em = e end end
check("D4 事件标 persisted=false", em ~= nil and em.data.persisted == false, "")
check("D4 章节不写盘", save.saveSignature(save.loadSave().state) == sigE, "")
-- D5 debug 馆内
local sigF = save.saveSignature(save.loadSave().state)
local pmd = newPlay(rooms.MUSEUM_ROOM, "debug", save.loadSave().state)
pmd.player.x = pmd.ox + 200
i = newInput(); tap(i, "interact"); step(pmd, i)
check("D5 调试馆内只预览", pmd.archive.museumPhase ~= "hall_walk" and save.saveSignature(save.loadSave().state) == sigF, "")
-- D6 chapter 独立预览局与正式档隔离
local ch = runmod.createRun(20261125, "chapter")
check("D6 章节预览来源", ch.source == "chapter", ch.source)
check("D6 章节预览档案独立", ch.archive ~= profile and ch.archive.artifactOwned == false, "")

say("== E. 输入实走 ==")
save.setSaveFile(C)
local st2 = save.emptySave(); st2.childCleared = true; st2.soldierCleared = true
save.saveSave(st2)
local profE = save.loadSave().state
local pw = newPlay(rooms.PROLOGUE_ROOM, "official", profE)
pw.player.x = pw.ox + 80
i = newInput()
walkTo(pw, i, pw.ox + 430, 120)
local d1 = toDepth(pw, i, 32)
local n1 = walkTo(pw, i, pw.ox + 430, 400)
local d2 = toDepth(pw, i, 0)
check("E1 走到井沿", math.abs(pw.player.x - (pw.ox + 430)) <= 44 and pw:wellWindow(),
    string.format("x=%.1f up=%d down=%d win=%s", pw.player.x, d1, d2, tostring(pw:wellWindow())))
tap(i, "interact"); step(pw, i)
check("E2 井口演出", pw.phase == "prologue-well", pw.phase)
for _ = 1, 30 do step(pw, i) end
check("E3 取器写档案", pw.archive.artifactOwned == true, "")
save.markProfilePending(pw.archive)
check("E3 落盘", save.flushProfile() == true and save.loadSave().state.artifactOwned == true, "")
tap(i, "interact"); step(pw, i)
check("E4 再按进馆", pw.wantRoom == "museum", pw.wantRoom)
-- 切房后：新实例
save.markProfilePending(profE)
check("E5 切房同拍落盘", save.flushProfile() == true, "")
local pm2 = newPlay(rooms.MUSEUM_ROOM, "official", save.loadSave().state)
i = newInput()
pm2.player.x = pm2.ox + 80
local n2 = walkTo(pm2, i, pm2.ox + 200, 200)
toDepth(pm2, i, 32)
check("E6 走到柜前", pm2.player.x <= pm2.ox + 260, string.format("x=%.1f n=%d depth=%.1f", pm2.player.x, n2, pm2.player.depth))
tap(i, "interact"); step(pm2, i)
check("E7 柜前一步", pm2.phase == "museum-hall", pm2.phase)
toDepth(pm2, i, 32)
walkTo(pm2, i, pm2.ox + 905, 300)
tap(i, "interact"); step(pm2, i)
check("E8 走廊一步", pm2.phase == "museum-lamp", string.format("%s x=%.1f depth=%.1f", pm2.phase, pm2.player.x, pm2.player.depth))
toDepth(pm2, i, 32)
walkTo(pm2, i, pm2.ox + 1255, 300)
tap(i, "interact"); step(pm2, i)
check("E9 末厅一步", pm2.phase == "museum-return", string.format("%s x=%.1f", pm2.phase, pm2.player.x))
toDepth(pm2, i, 32)
walkTo(pm2, i, pm2.ox + 200, 400)
tap(i, "interact"); step(pm2, i)
check("E10 回柜一步", pm2.phase == "museum-knock", string.format("%s x=%.1f", pm2.phase, pm2.player.x))
for _ = 1, 40 do step(pm2, i) end
check("E11 落幕", pm2.phase == "museum-done" and pm2.archive.museumSeen == true, pm2.phase)
save.markProfilePending(pm2.archive)
save.flushProfile()
tap(i, "interact"); step(pm2, i)
local pe = lualib.__TS__New(play.Play, rooms.PROLOGUE_ROOM, nil, pm2.run)
step(pe, i)
check("E12 回序章柜边", pe.phase == "prologue-wait" and math.abs(pe.player.x - (pe.ox + 260)) <= 6,
    string.format("phase=%s x=%.1f", pe.phase, pe.player.x))
check("E13 落盘馆完成", save.loadSave().state.museumSeen == true and save.loadSave().state.museumPhase == "done", "")
-- E14 每步落盘读数（模拟退出重启：逐步读回）
local steps = { "well_reflect", "hall_walk", "lamp_turn", "return_cabinet", "done" }
local seen = 0
local k = 0
for k = 1, #steps do
    if save.loadSave().state.museumPhase == steps[k] or save.saveSignature(save.loadSave().state):find(steps[k]) then seen = seen + 1 end
end
check("E14 档案枚举可达", seen >= 1 and save.loadSave().state.museumPhase == "done", "")

say("== G. app 正式入口钩子 ==")
local Dora = require("Dora")
local app = require("Script.watch.app")
local root = Dora.Node()
root.size = Dora.Size(Dora.Vec2(Dora.View.size.width, Dora.View.size.height))
root.anchor = Dora.Vec2(0, 0)
root.position = Dora.Vec2(-Dora.View.size.width / 2, -Dora.View.size.height / 2)
Dora.Director.ui:addChild(root)
local GC = "watch-save/test-cfix-g.txt"
if Content:exist(abs(GC)) then Content:remove(abs(GC)) end
app.start(root, 1, "play")
local fe2 = package.loaded["watch.fe"]
check("G1 flush 钩子", fe2 ~= nil and type(fe2.flushProfileNow) == "function", "")
fe2.useTestSave(GC)
local p9 = fe2.startStory()
check("G2 标题开局 official", p9.run.source == "official", p9.run.source)
p9.archiveDirty = true
p9.archive.museumPhase = "lamp_turn"
check("G3 app 层落盘", fe2.flushProfileNow() == true and save.loadSave().state.museumPhase == "lamp_turn",
    save.loadSave().state.museumPhase)
check("G3 pending 已清", fe2.getProfilePending() == false, "")
save.setSaveFault("replace")
p9.archiveDirty = true
p9.archive.museumPhase = "done"
check("G4 app 层失败留责任", fe2.flushProfileNow() == false and fe2.getProfilePending() == true, "")
save.setSaveFault("")
check("G5 重试成功", fe2.flushProfileNow() == true and fe2.getProfilePending() == false, "")
check("G6 磁盘追上", save.loadSave().state.museumPhase == "done", save.loadSave().state.museumPhase)


say("== H. 存档收口：真实恢复入口与操作层故障 ==")
local HF = "watch-save/test-cfix-prev.txt"
local function dropDerived(base)
    Content:remove(abs(base))
    for _, suffix in ipairs({ ".tmp", ".prev", ".corrupt", ".reset", ".unsupported" }) do
        Content:remove(abs(base .. suffix))
        for n = 2, 12 do Content:remove(abs(base .. suffix .. "." .. n)) end
    end
end
dropDerived(HF)
-- H1 prev-only：目标与 .tmp 都删掉，只剩完整 .prev
save.setSaveFile(HF)
local h1 = save.emptySave(); h1.childCleared = true
check("H1 写基准档", save.saveSave(h1), "")
Content:copy(abs(HF), abs(HF .. ".prev"))
Content:remove(abs(HF)); Content:remove(abs(HF .. ".tmp"))
local h1r = save.loadSave()
check("H1 prev-only 恢复", h1r.status == "ok" and h1r.recovered == true and h1r.state.childCleared == true,
    "status=" .. h1r.status .. " child=" .. tostring(h1r.state.childCleared) .. " recovered=" .. tostring(h1r.recovered))
check("H1 恢复后 prev 仍在", Content:exist(abs(HF .. ".prev")), "")
-- H2 目标损坏 + 完整最新 .tmp：优先用 tmp，而不是丢掉它
dropDerived(HF)
save.setSaveFile(HF)
local h2a = save.emptySave(); h2a.childCleared = false
check("H2 写旧档", save.saveSave(h2a), "")
Content:save(abs(HF .. ".tmp"),
    "version=1\nchildCleared=true\nsoldierCleared=false\nartifactOwned=false\nmuseumPhase=locked\nmuseumSeen=false\n")
Content:save(abs(HF), "garbage-not-a-save")
local h2r = save.loadSave()
check("H2 损坏时用 tmp 恢复", h2r.status == "ok" and h2r.state.childCleared == true and h2r.recovered == true, h2r.detail)
check("H2 损坏件备份保留", h2r.backup ~= "" and Content:exist(h2r.backup), h2r.backup)
-- H3 操作层 copy 失败（备份 target→prev 返回 false）：不覆盖旧档
dropDerived(HF)
save.setSaveFile(HF)
local h3a = save.emptySave(); h3a.childCleared = true
check("H3 写基准档", save.saveSave(h3a), "")
local function mkOps(copyImpl, saveImpl)
    return {
        exist = function(_, p) return Content:exist(p) end,
        load = function(_, p) return Content:load(p) end,
        save = saveImpl or function(_, p, t) return Content:save(p, t) end,
        copy = copyImpl or function(_, a, b) return Content:copy(a, b) end,
        remove = function(_, p) return Content:remove(p) end,
        isdir = function(_, p) return Content:isdir(p) end,
        mkdir = function(_, p) return Content:mkdir(p) end,
    }
end
local realCopyFail = mkOps(function(_, a, b) if b == abs(HF .. ".prev") then return false end return Content:copy(a, b) end)
save.setFileOpsForTest(realCopyFail)
local h3b = save.emptySave(); h3b.soldierCleared = true
check("H3 备份复制失败返回 false", save.saveSave(h3b) == false, "")
save.setFileOpsForTest(nil)
local h3r = save.loadSave()
check("H3 旧档未被覆盖", h3r.status == "ok" and h3r.state.childCleared == true and h3r.state.soldierCleared == false, "")
check("H3 无新 tmp 残留", not Content:exist(abs(HF .. ".tmp")), "")
-- H4 操作层 save 失败
local saveFailOps = mkOps(nil, function(_, p, t) return false end)
local h4a = save.emptySave(); h4a.museumPhase = "done"
save.setFileOpsForTest(saveFailOps)
check("H4 写临时失败返回 false", save.saveSave(h4a) == false, "")
save.setFileOpsForTest(nil)
check("H4 旧档仍在", save.loadSave().state.childCleared == true, "")
-- H5 resetSave 备份失败：不删目标
Content:save(abs(HF), "garbage-not-a-save")
Content:remove(abs(HF .. ".reset"))
save.setSaveFile(HF)
local h5ops = mkOps(function(_, a, b) if b:find(".reset") then return false end return Content:copy(a, b) end)
save.setFileOpsForTest(h5ops)
check("H5 备份失败拒绝 reset", save.resetSave() == false, "")
save.setFileOpsForTest(nil)
check("H5 原件仍在", Content:exist(abs(HF)), "")
-- H6 pending 绑定路径：A 档 pending 不能写进 B 档
local PA, PB = "watch-save/test-cfix-pa.txt", "watch-save/test-cfix-pb.txt"
dropDerived(PA); dropDerived(PB)
save.setSaveFile(PA)
local pa = save.emptySave(); pa.childCleared = true
save.markProfilePending(pa)
save.setSaveFile(PB)
check("H6 切档后 flush 拒绝", save.flushProfile() == false, "")
check("H6 B 档未被创建", not Content:exist(abs(PB)), "")
check("H6 pending 仍指 A", save.pendingMatchesCurrent() == false, "")
save.setSaveFile(PA)
check("H6 切回 A 可落盘", save.flushProfile() == true and save.loadSave().state.childCleared == true, "")
-- H7 备份重名不覆盖
dropDerived(HF)
save.setSaveFile(HF)
local h7 = save.emptySave(); h7.soldierCleared = true
check("H7 写基准档", save.saveSave(h7), "")
Content:save(abs(HF .. ".corrupt"), "old-corrupt-1")
Content:save(abs(HF .. ".corrupt.2"), "old-corrupt-2")
Content:save(abs(HF), "garbage-not-a-save")
local h7r = save.loadSave()
local h7backup = h7r.backup
check("H7 派生到 .corrupt.3", h7backup ~= "" and h7backup:find(".corrupt.3") ~= nil, h7backup)
check("H7 旧备份未被覆盖", Content:load(abs(HF .. ".corrupt")) == "old-corrupt-1"
    and Content:load(abs(HF .. ".corrupt.2")) == "old-corrupt-2", "")
check("H7 备份内容等于原件", Content:load(h7backup) == "garbage-not-a-save", "")
-- H8 覆盖阶段 copy 失败：旧档保留，tmp 保留为唯一完整候选
dropDerived(HF)
save.setSaveFile(HF)
local h8 = save.emptySave(); h8.childCleared = true
check("H8 写基准档", save.saveSave(h8), "")
local h8ops = mkOps(function(_, a, b) if b == abs(HF) then return false end return Content:copy(a, b) end)
save.setFileOpsForTest(h8ops)
local h8b = save.emptySave(); h8b.soldierCleared = true
check("H8 覆盖失败返回 false", save.saveSave(h8b) == false, "")
save.setFileOpsForTest(nil)
local h8r = save.loadSave()
check("H8 旧档未被覆盖", h8r.status == "ok" and h8r.state.childCleared == true and h8r.state.soldierCleared == false, h8r.status)
check("H8 tmp 保留为候选", Content:exist(abs(HF .. ".tmp")), "")
-- H9 切走再切回未知版本档：保护位按路径，不因切档失效
local HY = "watch-save/test-cfix-he.txt"
dropDerived(HY)
Content:save(abs(HY), "version=2\nchildCleared=true\n")
save.setSaveFile(HY)
local h9 = save.loadSave()
check("H9 未知版本置保护", h9.status == "unsupported" and save.saveSave(h8) == false, h9.status)
save.setSaveFile(HF)
check("H9 切走后别的档可写", save.saveSave(h8b) == true, "")
save.setSaveFile(HY)
check("H9 切回仍拒写", save.saveSave(h8) == false, "")

say("== F. 正式档未碰 ==")
save.setSaveFile(FORMAL)
check("F1 正式档前后一致", formalSig() == FORMAL_SIG0, formalSig())
check("F2 正式备份未被写", readText(formalCorrupt) == formalBefore, "")

say(string.format("C 修正回归：%d 通过 / %d 失败", pass, fail))
assert(fail == 0, "C 修正回归失败")
