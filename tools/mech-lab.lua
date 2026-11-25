-- 无剧情机制试验台（离线驱动正式玩法逻辑）
--
-- 用法：lua tools/mech-lab.lua        （系统 lua 5.5，不需要引擎，不打扰任何人）
--      MECH_WORKTREE=/path lua tools/mech-lab.lua
--
-- 设计约束：
--  * 只加载仓库里的 Script/watch/*.lua（正式构建产物），不复制、不模拟它们。
--  * 只 stub 绘制绑定（Color/Rect/Vec2）：update/stepPlayer/shoot/stepEnemies 不绘制。
--  * 所有对照都从同一构造函数入口走，玩家输入走 Input + Play:update。

local scriptPath = debug.getinfo(1, "S").source
if string.sub(scriptPath, 1, 1) == "@" then
    scriptPath = string.sub(scriptPath, 2)
end
local WORKTREE = os.getenv("MECH_WORKTREE")
if WORKTREE == nil or WORKTREE == "" then
    -- 以「本文件所在目录的上一级」为根；用相对路径调用时正则是空串，退回当前目录。
    local root = string.match(scriptPath, "^(.*)/tools/[^/]+$")
    WORKTREE = (root ~= nil and root ~= "") and root or "."
end
if not io.open(WORKTREE .. "/Script/watch/play.lua", "r") then
    error("工作树根目录不正确（缺 Script/watch/play.lua）：" .. WORKTREE .. "，请设置 MECH_WORKTREE")
end

local LUALIB = WORKTREE .. "/.download/win/Script/Lib"
if not io.open(LUALIB .. "/lualib_bundle.lua", "r") then
    LUALIB = WORKTREE .. "/../../dora-game/.download/win/Script/Lib"
    if not io.open(LUALIB .. "/lualib_bundle.lua", "r") then
        error("找不到 lualib_bundle.lua")
    end
end

package.path = WORKTREE .. "/?.lua;" .. LUALIB .. "/?.lua;" .. package.path

-- ── 引擎绑定 stub：只有绘制/数学值类型 ─────────────────────────────────────
local function Color(r, g, b, a)
    if type(r) == "table" then
        return { r = r.r, g = r.g, b = r.b, a = r.a }
    end
    return { r = r, g = g, b = b, a = a or 255 }
end
local function Vec2(x, y)
    if type(x) == "table" then
        return { x = x.x, y = x.y }
    end
    return { x = x, y = y }
end
local function Rect(x, y, w, h)
    if type(x) == "table" then
        return { x = x.x, y = x.x, width = x.w, height = x.h }
    end
    return { x = x, y = y, width = w, height = h }
end
local DoraStub = { Color = Color, Vec2 = Vec2, Rect = Rect }
package.preload["Dora"] = function()
    return DoraStub
end
Dora = DoraStub

local bundle = require("lualib_bundle")
local ____TS__New = bundle.__TS__New
local game = require("Script.watch.play")
local inputmod = require("Script.watch.input")
local escortmod = require("Script.watch.escort")
local rooms = require("Script.watch.rooms")
local runmod = require("Script.watch.run")
local clock = require("Script.watch.clock")

local STEP = clock.STEP
local C2 = rooms.CAMPAIGN_ROOMS[5]

-- ── 构造与安置 ─────────────────────────────────────────────────────────────
local function freshSim(seed)
    local run = runmod.createRun(seed or 20261124)
    local sim = ____TS__New(game.Play, C2, nil, run)
    return sim
end

local function newInput()
    return ____TS__New(inputmod.Input)
end

local function baseX(sim)
    return sim.room.minX
end

-- 清空房间实体，只保留一块可站立地面（可选再放一件挡弹实体）。
local function buildStage(sim, groundX0, groundX1, blocker)
    sim.boxes = {}
    sim.boxes[1] = {
        x0 = 0, x1 = 0,
        y0 = -60, y1 = 0,
        passable = true,
        label = "试验地面",
    }
    sim.boxes[1].x0 = groundX0
    sim.boxes[1].x1 = groundX1
    if blocker then
        local ox = sim.room.minX
        sim.boxes[#sim.boxes + 1] = {
            x0 = ox + blocker.x0, x1 = ox + blocker.x1,
            y0 = 0, y1 = 140,
            depth = { min = blocker.depth - 7, max = blocker.depth + 7 },
            label = blocker.label or "试验挡物",
            id = blocker.id or "lab_blocker",
        }
    end
end

local function placePlayer(sim, x, depth, facing)
    local p = sim.player
    p.x = x
    p.y = 0
    p.depth = depth or 0
    p.facing = facing or 1
    p.alive = true
    sim.hp = sim.maxHp
    sim.invulnT = 0
    sim.reloadT = 0
    sim.bracedShield = nil
    sim.coverHug = false
    sim.events = {}
    sim.eventSeq = 0
    sim.isCampaign = true
end

local function gunner(sim, x, depth, opts)
    opts = opts or {}
    return {
        x = x, y = 0, depth = depth or 0,
        w = 26, h = 84,
        alive = true, hitT = 0, warnT = 0, fireCd = 240,
        kind = opts.kind or "gunner",
        awake = true,
        shieldHp = opts.shieldHp, shieldHpMax = opts.shieldHp,
    }
end

local function drain(sim)
    local out = {}
    for i = 1, #sim.events do
        out[i] = sim.events[i]
    end
    sim.events = {}
    sim.eventSeq = 0
    return out
end

local function firstEvent(list, name, pred)
    for i = 1, #list do
        local ev = list[i]
        if ev.name == name and (pred == nil or pred(ev.data)) then
            return ev
        end
    end
    return nil
end

-- 玩家开火：走 Input.fire 边沿 + Play:update，与真人按键同一条路径。
local function playerShotOnce(sim, aimWorldX, aimWorldY)
    sim.worldMapper = function()
        return { x = aimWorldX, y = aimWorldY }
    end
    local inp = newInput()
    inp.fire.pressed = true
    sim:update(STEP, inp)
end

local function enemyShotOnce(sim, enemy, playerDepth)
    sim.worldMapper = function()
        return { x = enemy.x, y = (enemy.depth or 0) + enemy.h * 0.55 }
    end
    local inp = newInput()
    sim:update(STEP, inp)
end

-- ── 结果收集 ───────────────────────────────────────────────────────────────
local results = {}
local failures = 0

local function record(group, name, expect, actual, detail)
    local pass = (expect == actual)
    if not pass then
        failures = failures + 1
    end
    results[#results + 1] = {
        group = group, name = name, expect = expect, actual = actual,
        pass = pass, detail = detail or "",
    }
    local mark = pass and "PASS" or "FAIL"
    print(string.format("[%s] %-4s %-38s 期望=%-8s 实测=%-8s %s",
        mark, group, name, tostring(expect), tostring(actual), detail or ""))
    return pass
end

-- ── A 组：玩家射击敌人（三点对照：同档 / 纵深错开 / 远端档真实相交）───────
local A = {
    enemyX = 1500, enemyDepth0 = 0, enemyDepth32 = 32,
    blockerNear = { x0 = 1360, x1 = 1400 },   -- 玩家与敌人之间
    blockerFar  = { x0 = 1470, x1 = 1490 },   -- 紧贴敌人，射线末端才进该档
}

local function trialPlayerShot(label, enemyDepth, blocker)
    local sim = freshSim()
    local ox = baseX(sim)
    local px = ox + 1300
    local ex = ox + A.enemyX
    buildStage(sim, ox + 1200, ox + 1600, blocker)
    placePlayer(sim, px, 0, 1)
    local e = gunner(sim, ex, enemyDepth)
    sim.enemies = { e }
    -- 准星指向敌人本体：屏幕投影固定到敌人世界位置（纵深参与投影）
    playerShotOnce(sim, ex, (enemyDepth or 0) + e.h * 0.55)
    local evs = drain(sim)
    local resolved = firstEvent(evs, "shotResolved")
    local hit = resolved ~= nil and resolved.data.hit == true
    local alive = sim.enemies[1].alive
    local impactX = resolved and resolved.data.impactX
    return {
        hit = hit, alive = alive, impactX = impactX,
        blockerX0 = blocker and (ox + blocker.x0) or nil,
        enemyX = ex,
        detail = string.format("hit=%s alive=%s impactX=%s blockerX0=%s enemyX=%s",
            tostring(hit), tostring(alive), tostring(impactX),
            tostring(blocker and (ox + blocker.x0)), tostring(ex)),
    }
end

local function main()
print("")
print("=== A 组：玩家射击（射线真实相交 vs 画面重叠纵深错开）===")

-- A1 同档：敌人 depth 0，挡物 depth 0 且位于两者之间 → 必须被挡
local a1 = trialPlayerShot("A1", A.enemyDepth0, { x0 = A.blockerNear.x0, x1 = A.blockerNear.x1, depth = 0 })
record("A", "A1 同档挡物挡下", false, a1.hit, a1.detail)
record("A", "A1 敌人未倒下", true, a1.alive, a1.detail)

-- A2 画面重叠、纵深错开：敌人 depth 32，挡物 depth 0 → 必须命中身体
local a2 = trialPlayerShot("A2", A.enemyDepth32, { x0 = A.blockerNear.x0, x1 = A.blockerNear.x1, depth = 0 })
record("A", "A2 纵深错开命中身体", true, a2.hit, a2.detail)
record("A", "A2 敌人倒下", false, a2.alive, a2.detail)

-- A3 远端档真实相交：敌人 depth 32，挡物 depth 32 紧贴敌人 → 必须被挡
local a3 = trialPlayerShot("A3", A.enemyDepth32, { x0 = A.blockerFar.x0, x1 = A.blockerFar.x1, depth = 32 })
record("A", "A3 远端档挡物挡下", false, a3.hit, a3.detail)
record("A", "A3 敌人未倒下", true, a3.alive, a3.detail)

-- ── B 组：敌人射击玩家（同一 blockedShot / campaignEnemyFire）────────────
local function trialEnemyShot(label, playerDepth, blocker)
    local sim = freshSim()
    local ox = baseX(sim)
    local px = ox + 1300
    local ex = ox + 1580
    buildStage(sim, ox + 1200, ox + 1700, blocker)
    placePlayer(sim, px, playerDepth, 1)
    local e = gunner(sim, ex, 0)
    e.fireCd = 1
    sim.enemies = { e }

    local hits, blocks = {}, {}
    local guard = 0
    while #hits + #blocks == 0 and guard < 60 do
        guard = guard + 1
        local inp = newInput()
        sim:update(STEP, inp)
        local evs = drain(sim)
        local h = firstEvent(evs, "actorHit", function(d) return d.target == "player" end)
        local b = firstEvent(evs, "coverBlocked")
        if h then hits[#hits + 1] = h end
        if b then blocks[#blocks + 1] = b end
    end
    return {
        hp = sim.hp, maxHp = sim.maxHp,
        hitCount = #hits, blockCount = #blocks,
        blockEntity = blocks[1] and blocks[1].data.entity or nil,
        detail = string.format("hp=%d/%d actorHit=%d coverBlocked=%d entity=%s",
            sim.hp, sim.maxHp, #hits, #blocks,
            tostring(blocks[1] and blocks[1].data.entity)),
    }
end

print("")
print("=== B 组：敌人射击（同一挡弹判定的反向对照）===")

local b1 = trialEnemyShot("B1", 0, { x0 = A.blockerNear.x0, x1 = A.blockerNear.x1, depth = 0 })
record("B", "B1 同档挡物挡下", 3, b1.hp, b1.detail)
record("B", "B1 未产生 actorHit", 0, b1.hitCount, b1.detail)

local b2 = trialEnemyShot("B2", 32, { x0 = A.blockerNear.x0, x1 = A.blockerNear.x1, depth = 0 })
record("B", "B2 纵深错开命中身体", 2, b2.hp, b2.detail)
record("B", "B2 产生 actorHit", 1, b2.hitCount, b2.detail)

local b3 = trialEnemyShot("B3", 32, { x0 = 1295, x1 = 1315, depth = 32 })
record("B", "B3 远端档挡物挡下", 3, b3.hp, b3.detail)
record("B", "B3 未产生 actorHit", 0, b3.hitCount, b3.detail)

-- ── HP 组：保护边界（同一正式 campaignEnemyFire，第二次开火间隔 41 / 42 拍）
local function hpTrial(gap)
    local sim = freshSim()
    local ox = baseX(sim)
    local px = ox + 1300
    local ex = ox + 1580
    buildStage(sim, ox + 1200, ox + 1700, nil)
    placePlayer(sim, px, 0, 1)
    local e = gunner(sim, ex, 0)
    e.fireCd = 1
    sim.enemies = { e }

    local hitTicks = {}
    local blockCount = 0
    local scheduled = false
    local guard = 0
    while #hitTicks < 2 and guard < gap + 120 do
        guard = guard + 1
        local inp = newInput()
        sim:update(STEP, inp)
        local evs = drain(sim)
        for i = 1, #evs do
            local ev = evs[i]
            if ev.name == "actorHit" and ev.data.target == "player" then
                hitTicks[#hitTicks + 1] = ev.tick
            elseif ev.name == "coverBlocked" then
                blockCount = blockCount + 1
            end
        end
        -- 首发结算后，把装填压到「间隔 = 36 拍预警 + gap - 36」
        if #hitTicks == 1 and not scheduled then
            scheduled = true
            e.fireCd = gap - 36
        end
        if #hitTicks == 1 and sim.hp <= 0 then
            break
        end
    end

    local rel = nil
    if #hitTicks >= 2 then
        rel = hitTicks[2] - hitTicks[1]
    end
    return {
        hp = sim.hp, hitCount = #hitTicks, hitTicks = hitTicks, rel = rel,
        blockCount = blockCount,
        detail = string.format("hp=%d hits=%d ticks=[%s] rel=%s",
            sim.hp, #hitTicks, table.concat(hitTicks, ","), tostring(rel)),
    }
end

print("")
print("=== HP 组：受击保护边界（第 41 拍仍保护 / 第 42 拍可再扣血）===")

local hp41 = hpTrial(41)
record("HP", "HP-01a gap=41 只受一次伤", 1, hp41.hitCount, hp41.detail)
record("HP", "HP-01a gap=41 血量 2", 2, hp41.hp, hp41.detail)

local hp42 = hpTrial(42)
record("HP", "HP-01b gap=42 受两次伤", 2, hp42.hitCount, hp42.detail)
record("HP", "HP-01b gap=42 血量 1", 1, hp42.hp, hp42.detail)
record("HP", "HP-01b gap=42 两次间隔 42 拍", 42, hp42.rel, hp42.detail)

-- ── ACT 组：动作承诺与输入不囤积 ──────────────────────────────────────────
local function countEvent(evs, name)
    local n = 0
    for i = 1, #evs do
        if evs[i].name == name then
            n = n + 1
        end
    end
    return n
end

local function quietStage()
    local sim = freshSim()
    local ox = baseX(sim)
    buildStage(sim, ox + 1200, ox + 1700, nil)
    placePlayer(sim, ox + 1300, 0, 1)
    sim.enemies = { gunner(sim, ox + 1500, 0) }
    return sim, ox
end

print("")
print("=== ACT 组：动作承诺（握持 / 只按一次 / 纵深与姿态独立）===")

local simA1, oxA1 = quietStage()
simA1.gripping = true
do
    local inp = newInput()
    inp.fire.pressed = true
    simA1:update(STEP, inp)
end
record("ACT", "ACT-01 握柄时开火被拒", 0, countEvent(drain(simA1), "shotResolved"), "gripping=true 且按下开火")

local simA2 = quietStage()
do
    local inp = newInput()
    inp.fire.pressed = false
    inp.fire.held = true
    simA2:update(STEP, inp)
end
record("ACT", "ACT-02 只按住不新按下不开火", 0, countEvent(drain(simA2), "shotResolved"), "held=true pressed=false")

local simA3 = quietStage()
local depth0 = simA3.player.depth
local crouch0 = simA3.player.crouch
local inpA3 = newInput()
inpA3.moveY = 1
for i = 1, 8 do
    simA3:update(STEP, inpA3)
end
record("ACT", "ACT-03 纵向输入改变纵深", true, simA3.player.depth ~= depth0,
    string.format("depth %s -> %s", tostring(depth0), tostring(simA3.player.depth)))
record("ACT", "ACT-03 纵向输入不改姿态", crouch0, simA3.player.crouch,
    "crouch=" .. tostring(simA3.player.crouch))

print("")
print("=== HP 组补充：残血反制与暂停冻结保护 ===")

local simH, oxH = quietStage()
simH.hp = 1
playerShotOnce(simH, oxH + 1500, 46.2)
record("HP", "HP-02 1HP 仍能反制开火", 1, countEvent(drain(simH), "shotResolved"), "hp=1")

local simP = quietStage()
simP.invulnT = 10
simP.paused = true
local inpP = newInput()
for i = 1, 30 do
    simP:update(STEP, inpP)
end
record("HP", "HP-03 暂停不消耗剩余保护", 10, simP.invulnT, "暂停中推进 30 拍")

print("")
print("=== HIT-04：翻滚不是全方向免疫 ===")

local function rollTrial(front)
    local sim, ox = quietStage()
    local sh = gunner(sim, ox + 1300 + (front and 40 or -40), 0, { kind = "shield", shieldHp = 2 })
    sim.enemies = { sh }
    local hits = 0
    for i = 1, 8 do
        sim.player.rollT = 0.5
        local inp = newInput()
        sim:update(STEP, inp)
        if firstEvent(drain(sim), "actorHit", function(d)
                return d.target == "player"
            end) then
            hits = hits + 1
        end
    end
    return { hits = hits, hp = sim.hp }
end

local rollFront = rollTrial(true)
local rollBack = rollTrial(false)
record("HIT", "HIT-04 翻滚抵消正面来击", 0, rollFront.hits, "盾手在前 + 持续翻滚")
record("HIT", "HIT-04 翻滚不抵消背后来击", 1, rollBack.hits, "盾手在后 + 持续翻滚")


-- ── ESC 组：同伴恐惧不叠加、满恐惧可救 ────────────────────────────────────
print("")
print("=== ESC 组：同一危险不叠加 / 满恐惧可救 ===")

local function newEscort()
    return ____TS__New(escortmod.Escort, 500, 30)
end

local esc1 = newEscort()
for i = 1, 3 do
    esc1:applyDanger(7, true, 100)
end
record("ESC", "ESC-01 同一危险三次只到 1", 1, esc1.fear, "dangerId=7 派发三次")

local esc2 = newEscort()
record("ESC", "ESC-01 未暴露的危险不结算", 0, esc2:applyDanger(7, false, 100), "exposed=false")

local esc3 = newEscort()
esc3:applyDanger(1, true, 100)
esc3:applyDanger(2, true, 100)
esc3:applyDanger(3, true, 100)
record("ESC", "ESC-02 三格进入冻结", "frozen", esc3.state, "fear=" .. tostring(esc3.fear))

local calmIn = newInput()
calmIn.interact.pressed = true
esc3:update(calmIn, 0, 1, 100, 65)
record("ESC", "ESC-02 距离 65 不开安抚", "frozen", esc3.state, "distance=65 reach=64")

esc3:update(calmIn, 0, 1, 100, 64)
record("ESC", "ESC-02 距离 64 开始安抚", "calming", esc3.state, "distance=64")

local tickIn = newInput()
local fearAt36 = nil
for i = 1, 36 do
    esc3:update(tickIn, 0, 1, 100, 64)
    if i == 36 then
        fearAt36 = esc3.fear
    end
end
record("ESC", "ESC-02 第 36 拍恐惧降到 1", 1, fearAt36, "calmTick=36")
for i = 37, 60 do
    esc3:update(tickIn, 0, 1, 100, 64)
end
record("ESC", "ESC-02 第 60 拍起身跟随", "follow", esc3.state, "calmTick=60")

-- ── AI 组：错深度近战不命中，同深度才命中 ─────────────────────────────────
print("")
print("=== AI 组：近战纵深一致（同档命中 / 错档不命中）===")

local function shieldMeleeTrial(shieldDepth)
    local sim, ox = quietStage()
    local sh = gunner(sim, ox + 1300 + 40, shieldDepth, { kind = "shield", shieldHp = 2 })
    sim.enemies = { sh }
    local hits = 0
    for i = 1, 8 do
        local inp = newInput()
        sim:update(STEP, inp)
        if firstEvent(drain(sim), "actorHit", function(d)
                return d.target == "player"
            end) then
            hits = hits + 1
        end
    end
    return { hits = hits, hp = sim.hp }
end

local meleeSame = shieldMeleeTrial(0)
local meleeCross = shieldMeleeTrial(32)
record("AI", "AI-02 同深度近战命中", 1, meleeSame.hits, "盾手 depth=0 / 玩家 depth=0")
record("AI", "AI-02 错深度近战不命中", 0, meleeCross.hits, "盾手 depth=32 / 玩家 depth=0")
record("AI", "AI-05 错层不捕获", 0, meleeCross.hits, "同上，纵深差 32 超过同档阈值")


-- ── CRA / INV 组：制作闭环、加固多承一击、满包不吞物 ─────────────────────
print("")
print("=== CRA 组：废木料 → 木楔 → 加固 → 多承一击 ===")

local function addWood(sim, ox, hp)
    local b = {
        x0 = ox + 1400, x1 = ox + 1440, y0 = 0, y1 = 140,
        depth = { min = -7, max = 7 },
        breakable = { kind = "thin_wood", hp = hp, wedgeHp = 1, wedgeable = true },
        label = "试验薄木挡", id = "lab_wood"
    }
    sim.boxes[#sim.boxes + 1] = b
    return b
end

-- 无楔：2 耐久，两下普通破坏就碎
local simA, oxA = quietStage()
local woodA = addWood(simA, oxA, 2)
simA:damageProp(woodA, 1)
record("CRA", "CRA-03 无楔第一击未碎", false, woodA.broken == true, "hp=" .. tostring(woodA.breakable.hp))
simA:damageProp(woodA, 1)
record("CRA", "CRA-03 无楔第二击碎", true, woodA.broken, "hp=" .. tostring(woodA.breakable.hp))

-- 有楔：钉一件木楔后 2 → 3 耐久，第三下才碎
local simB, oxB = quietStage()
local woodB = addWood(simB, oxB, 2)
placePlayer(simB, oxB + 1390, 0, 1)
simB.run.inventory.wedge = 1
local wedgeIn = newInput()
wedgeIn.interact.pressed = true
simB:update(STEP, wedgeIn)
record("CRA", "CRA-03 钉楔后耐久 3", 3, woodB.breakable.hp, "2 + wedgeHp 1")
record("CRA", "CRA-03 钉楔消耗一件", 0, simB.run.inventory.wedge, "wedge 1 -> 0")
simB:damageProp(woodB, 1)
simB:damageProp(woodB, 1)
record("CRA", "CRA-03 有楔第二击未碎", false, woodB.broken == true, "hp=" .. tostring(woodB.breakable.hp))
simB:damageProp(woodB, 1)
record("CRA", "CRA-03 有楔第三击碎", true, woodB.broken, "hp=" .. tostring(woodB.breakable.hp))

print("")
print("=== CRA-01：按住 45 拍成一次，松手取消不产出 ===")

local simC, oxC = quietStage()
placePlayer(simC, oxC + 1300, 0, 1)
simC.run.inventory.scrap = 1
simC.run.inventory.wedge = 0
local pressC = newInput()
pressC.interact.pressed = true
pressC.interact.held = true
simC:update(STEP, pressC)
record("CRA", "CRA-01 按下开始制作", 1, simC.craftT, "craftT=1")
local holdC = newInput()
holdC.interact.held = true
for i = 2, 45 do
    simC:update(STEP, holdC)
end
record("CRA", "CRA-01 45 拍制得木楔", 1, simC.run.inventory.wedge, "wedge=" .. simC.run.inventory.wedge)
record("CRA", "CRA-01 原料被消耗", 0, simC.run.inventory.scrap, "scrap=" .. simC.run.inventory.scrap)
for i = 1, 10 do
    simC:update(STEP, newInput())
end
record("CRA", "CRA-01 完成后不复制", 1, simC.run.inventory.wedge, "再推 10 拍")

local simD, oxD = quietStage()
placePlayer(simD, oxD + 1300, 0, 1)
simD.run.inventory.scrap = 1
simD.run.inventory.wedge = 0
local pressD = newInput()
pressD.interact.pressed = true
pressD.interact.held = true
simD:update(STEP, pressD)
local holdD = newInput()
holdD.interact.held = true
for i = 2, 20 do
    simD:update(STEP, holdD)
end
simD:update(STEP, newInput())
record("CRA", "CRA-01 松手取消不产出", 0, simD.run.inventory.wedge, "craftT=" .. tostring(simD.craftT))
record("CRA", "CRA-01 取消后原料还在", 1, simD.run.inventory.scrap, "scrap=" .. simD.run.inventory.scrap)

print("")
print("=== INV-01：满包不吞物 ===")

local simE, oxE = quietStage()
placePlayer(simE, oxE + 1300, 0, 1)
simE.run.inventory.wedge = 1
simE.run.taken = {}
simE.pickups = {
    { id = "lab_wedge", kind = "wedge", x = oxE + 1300, y = 0, depth = 0, label = "试验木楔" }
}
simE:update(STEP, newInput())
local evE = drain(simE)
record("INV", "INV-01 满包不标记拾取", false, simE.run.taken["lab_wedge"] == true, "taken 应保持空")
record("INV", "INV-01 满包数量不变", 1, simE.run.inventory.wedge, "wedge 仍 1")
record("INV", "INV-01 满包发出拒绝事件", 1, countEvent(evE, "pickupRejected"), "pickupRejected")

simE.run.inventory.wedge = 0
simE:update(STEP, newInput())
record("INV", "INV-01 腾出格位后能再捡", 1, simE.run.inventory.wedge, "wedge 0 -> 1")


-- ── 汇总 ───────────────────────────────────────────────────────────────────
print("")
print(string.format("总计 %d 项，失败 %d 项", #results, failures))
if failures > 0 then
    for i = 1, #results do
        local r = results[i]
        if not r.pass then
            print(string.format("  未通过：%s %s —— 期望 %s，实测 %s（%s）",
                r.group, r.name, tostring(r.expect), tostring(r.actual), r.detail))
        end
    end
end

end

if os.getenv("MECH_NO_RUN") == nil then
    main()
end

return {
    results = results, failures = failures, run = main,
    freshSim = freshSim, newInput = newInput,
    buildStage = buildStage, placePlayer = placePlayer,
}
