-- 两路灰盒试玩驱动（手写 Lua，只用于验收计时，不参与 TS 编译）
-- 用法：local T = require("Script.watch.testdrive"); T.run("outer")
-- 每条路线从 S1 走到 C2，用固定 1/60 步推进，记录每房有效玩法帧数。

local R = require("Script.watch.rooms")
local P = require("Script.watch.play")
local Run = require("Script.watch.run")
local I = require("Script.watch.input")

local function newSim(room, run)
    local sim = setmetatable({}, P.Play.prototype)
    P.Play.prototype.____constructor(sim, room, nil, run)
    return sim
end

local function newInput()
    local inp = setmetatable({}, I.Input.prototype)
    I.Input.prototype.____constructor(inp)
    return inp
end

-- 每房的目标纵深：返回该段内坐标 x 对应的档位（-32 / 0 / 32）。
-- 表按 [x0, x1) 分段，越界用末尾档。
local LANES = {
    ["s1-crossroad"] = {
        { 0, 290, 0 }, { 290, 545, 32 }, { 545, 1100, 0 }, { 1100, 1250, 32 },
        { 1250, 1390, 0 }, { 1390, 1520, 0 }, { 1520, 9999, 0 },
    },
    ["s2-drygoods-dry"] = {
        { 0, 560, -32 }, { 560, 600, 32 }, { 600, 680, -32 }, { 680, 9999, 0 },
    },
    ["s2-drygoods"] = {
        { 0, 300, 32 }, { 300, 455, 0 }, { 455, 690, 0 }, { 690, 835, 32 }, { 835, 9999, 0 },
    },
    ["s3-archway"] = {
        { 0, 200, 0 }, { 200, 560, 0 }, { 560, 720, 32 }, { 720, 9999, 0 },
    },
    ["c1-yard"] = {
        { 0, 280, 0 }, { 280, 640, 32 }, { 640, 820, 0 }, { 820, 1020, -32 },
        { 1020, 1350, 32 }, { 1350, 1850, 32 }, { 1850, 9999, 0 },
    },
    ["c2-granary"] = {
        { 0, 600, 0 }, { 600, 900, -32 }, { 900, 1040, 32 }, { 1040, 1090, 0 },
        { 1090, 1240, 0 }, { 1240, 1400, 0 }, { 1400, 1530, 32 }, { 1530, 1600, 0 },
        { 1600, 9999, 0 },
    },
}

local function wantLane(key, local_x, route)
    local segs = LANES[key]
    if segs == nil then
        return 0
    end
    for _, s in ipairs(segs) do
        if local_x >= s[1] and local_x < s[2] then
            return s[3]
        end
    end
    return 0
end

-- 路线专属的破障目标：薄木挡（外檐线）或窗板机关（布行线）。
local function propTarget(sim, key, local_x, route)
    if key == "s2-drygoods" then
        if route == "outer" and local_x >= 430 and local_x < 525 then
            return "s2_wood"
        end
        if route == "drygoods" and local_x >= 560 and not sim.run.joined then
            return "s2_board"
        end
    end
    return nil
end

-- 前方同档是否已有挡路实体；用于提前换档，别等撞上再退。
local function forwardBlocked(sim, p, look)
    for _, b in ipairs(sim.boxes) do
        if b.passable ~= true and b.broken ~= true and b.hidden ~= true and b.soft ~= true
            and b.x0 > p.x + p.w / 2 and b.x0 < p.x + p.w / 2 + look
            and b.y0 < p.y + p.h and b.y1 > p.y then
            local d = b.depth
            if d == nil then
                return true
            end
            if p.depth + 7 > d.min and p.depth - 7 < d.max then
                return true
            end
        end
    end
    return false
end

local function findBox(sim, id)
    for _, b in ipairs(sim.boxes) do
        if b.id == id then
            return b
        end
    end
    return nil
end

-- 在 E 能到达的机关前按一次；返回是否按了。
local function pressInteract(sim, inp)
    inp.interact.pressed = true
end


-- C2 专用推进：B 线先放帘再回来推车；A 线先架盾再推车。
local function c2Step(sim, inp, route, maxNs)
    local p = sim.player
    local minX = sim.room.minX
    local cd = 0
    local phase = route == "drygoods" and "curtain" or "brace"
    if route == "drygoods" and sim.run.props["c2_curtain"] ~= nil then
        phase = "cart"
    end
    for i = 1, maxNs do
        local lx = p.x - minX
        p = sim.player
        lx = p.x - minX
        inp.moveX = 0
        inp.moveY = 0
        inp.fire.pressed = false
        inp.interact.pressed = false
        inp.jump.pressed = false
        if cd > 0 then cd = cd - 1 end

        if phase == "curtain" then
            inp.moveX = lx < 1180 and 1 or 0
            inp.moveY = p.depth < 30 and -1 or (p.depth > 34 and 1 or 0)
            if lx >= 1152 and math.abs(p.depth - 32) < 12 and cd == 0 then
                pressInteract(sim, inp); cd = 16
            end
            if sim.run.props["c2_curtain"] ~= nil then
                phase = "cart"; cd = 0
            end
        elseif phase == "brace" then
            if (sim.run.inventory.shield or 0) > 0 and sim.bracedShield == nil then
                inp.moveX = lx < 1088 and 1 or 0
                inp.moveY = (lx < 1026 and (p.depth < 30 and -1 or 0)) or (p.depth > 4 and 1 or 0)
                if lx >= 1088 and cd == 0 then pressInteract(sim, inp); cd = 16 end
                if sim.bracedShield ~= nil then phase = "cart"; cd = 0 end
            else
                phase = "cart"
            end
        elseif phase == "cart" then
            local axle = sim.cartAxle
            local handle = axle - 50
            if sim.gripping then
                inp.moveX = sim.cartDocked and 0 or 1
                if sim.cartDocked then phase = "latch" end
            elseif sim.cartDocked then
                phase = "latch"
            else
                local want = (lx < 1064) and 30 or 0
                local nearLane = math.abs(p.depth - want) <= 8
                inp.moveX = (not nearLane) and 0 or (p.x < handle - 6 and 1 or (p.x > handle + 6 and -1 or 0))
                inp.moveY = p.depth < want - 6 and -1 or (p.depth > want + 6 and 1 or 0)
                if math.abs(p.x - handle) < 40 and math.abs(p.depth) < 16 and cd == 0 then
                    pressInteract(sim, inp); cd = 16
                end
            end
        elseif phase == "latch" then
            if sim.run.props["c2_latch"] ~= nil then
                phase = "exit"
            else
                local want = (lx < 1530) and 30 or 0
                inp.moveX = lx < 1530 and 1 or 0
                inp.moveY = p.depth < want - 6 and -1 or (p.depth > want + 6 and 1 or 0)
                if lx >= 1524 and math.abs(p.depth) < 16 and cd == 0 then
                    pressInteract(sim, inp); cd = 16
                end
            end
        elseif phase == "exit" then
            inp.moveX = lx < 1712 and 1 or 0
            inp.moveY = (lx < 1026) and (p.depth < 24 and -1 or 0) or (p.depth > 4 and 1 or 0)
        end

        -- 同档敌人靠近时先还击，别被顶着打进循环。
        local foe = nil
        for _, e in ipairs(sim.enemies) do
            if e.alive and math.abs(e.depth - sim.player.depth) <= 44 and math.abs(e.x - sim.player.x) < 260 then
                foe = e
            end
        end
        if foe ~= nil and sim.reloadT <= 0 and not sim.gripping then
            sim:aimAt(foe.x, foe.y + foe.depth + foe.h * 0.6)
            inp.fire.pressed = true
            inp.moveX = 0
        end

        sim:update(1 / 60, inp)
        if sim.wantRoom ~= "" or sim.run.finished then
            return { ok = true, frames = i }
        end
        if (i % 600) == 0 then
            print(string.format("[c2] %s %d lx=%.0f d=%.0f hp=%d grip=%s axle=%.0f", phase, i, sim.player.x - minX, sim.player.depth, sim.hp, tostring(sim.gripping), sim.cartAxle))
        end
    end
    return { ok = false, frames = maxNs }
end

local function stepRoom(sim, inp, route, maxNs)
    local key = sim.room.key
    if key == "c2-granary" then
        return c2Step(sim, inp, route, maxNs)
    end
    local laneKey = (route == "drygoods" and key == "s2-drygoods") and "s2-drygoods-dry" or key
    local minX = sim.room.minX
    local stuckX, stuck = sim.player.x, 0
    local pendingJump = false
    local interactCd = 0
    local logs = {}
    for i = 1, maxNs do
        local p = sim.player
        local local_x = p.x - minX
        local want = wantLane(laneKey, local_x, route)
        local prop = propTarget(sim, key, local_x, route)
        local box = prop and findBox(sim, prop)

        inp.interact.pressed = false
        inp.jump.pressed = pendingJump
        pendingJump = false
        inp.crouch.held = false
        inp.cover.held = false
        if interactCd > 0 then interactCd = interactCd - 1 end

        -- 破障：薄木挡打两枪；窗板走近后按 E 放下。
        if box ~= nil and box.broken ~= true then
            if prop == "s2_wood" then
                inp.moveX = 0
                sim:aimAt((box.x0 + box.x1) / 2, 26)
                inp.fire.pressed = sim.reloadT <= 0
            else
                if p.x > box.x0 - 16 then
                    inp.moveX = -1
                else
                    inp.moveX = p.x < box.x0 - 24 and 1 or 0
                end
                want = 32
                inp.fire.pressed = false
                if math.abs(p.x - box.x0) < 72 and math.abs(p.depth - 32) < 20 and interactCd == 0 then
                    pressInteract(sim, inp)
                    interactCd = 20
                end
            end
        else
            -- 交火：射程内同档敌人先停下打。
            local best, bd = nil, 1e9
            for _, e in ipairs(sim.enemies) do
                if e.alive then
                    local d = math.abs(e.x - p.x)
                    local sameLane = math.abs((e.depth or 0) - p.depth) <= 44
                    if sameLane and d < bd then
                        bd = d
                        best = e
                    end
                end
            end
            if best ~= nil and bd < 420 then
                inp.moveX = 0
                sim:aimAt(best.x, best.y + (best.depth or 0) + best.h * 0.6)
                inp.fire.pressed = sim.reloadT <= 0
            elseif math.abs(p.depth - want) > 6 then
                -- 换档同时继续走：贴着障碍侧面时原地换档会被限深卡死，先离开接触面。
                inp.moveX = forwardBlocked(sim, p, 60) and 0 or 1
                inp.fire.pressed = false
            elseif forwardBlocked(sim, p, 110) then
                inp.moveX = 0
                inp.fire.pressed = false
            else
                inp.moveX = 1
                inp.fire.pressed = false
            end
        end

        -- 车：走到车柄按 E 握柄，握上后用 A/D 推到轮窝。
        if key == "c2-granary" and sim.room.cart.bodyW > 0 then
            local axle = sim.cartAxle
            local handle = axle - 50
            if not sim.gripping then
                if not sim.cartDocked and math.abs(p.x - handle) < 70 and math.abs(p.depth) < 24 and interactCd == 0 then
                    pressInteract(sim, inp)
                    interactCd = 14
                elseif not sim.cartDocked then
                    inp.moveX = p.x < handle - 8 and 1 or 0
                else
                    -- 车入窝后绕车侧去连杆：车身占中档，从上档过。
                    inp.moveX = 1
                end
            else
                inp.moveX = 1
            end
        end

        -- 抬闩 / 放帘：走到机关位按 E。
        if key == "c1-yard" and local_x >= 1782 and local_x <= 1848 and math.abs(p.depth - 32) < 18 then
            if interactCd == 0 and sim.run.latchOpen ~= true then
                pressInteract(sim, inp)
                interactCd = 14
            end
        end
        if key == "c2-granary" and local_x >= 1150 and local_x <= 1300 and math.abs(p.depth - 32) < 18 then
            local post = findBox(sim, "c2_post")
            if post ~= nil and post.broken ~= true and interactCd == 0 then
                pressInteract(sim, inp)
                interactCd = 16
            end
        end
        if key == "c2-granary" and local_x >= 1530 and local_x <= 1600 and math.abs(p.depth) < 20 then
            local latch = findBox(sim, "c2_latch")
            if latch ~= nil and latch.broken ~= true and interactCd == 0 then
                pressInteract(sim, inp)
                interactCd = 14
            end
        end

        inp.moveY = p.depth < want - 4 and -1 or (p.depth > want + 4 and 1 or 0)
        if sim.gripping then
            inp.moveY = 0
        end

        sim:update(1 / 60, inp)

        if math.abs(sim.player.x - stuckX) < 0.4 then
            stuck = stuck + 1
        else
            stuck = 0
        end
        stuckX = sim.player.x
        if stuck >= 8 and sim.player.onGround and math.abs(sim.player.depth - want) < 6 then
            pendingJump = true
            stuck = 0
        end

        if sim.wantRoom ~= "" or sim.run.finished then
            return { ok = true, frames = i }
        end
        if (i % 600) == 0 then
            print(string.format("[%s] %d x=%.0f d=%.0f hp=%d partner=%.0f pd=%.0f joined=%s", key, i, sim.player.x, sim.player.depth, sim.hp, sim.partner.x, sim.partner.depth, tostring(sim.run.joined)))
        end
    end
    return { ok = false, frames = maxNs }
end

local ORDER = { "s1-crossroad", "s2-drygoods", "s3-archway", "c1-yard", "c2-granary" }

-- 跑整条路线，返回 { ok, frames = {房:帧}, total, hp, inv }。
local function run(route)
    local runState = Run.createRun(20261124)
    if route == "drygoods" then
        runState.route = "drygoods"
    end
    local results = {}
    local total = 0
    for idx = 1, 5 do
        local key = ORDER[idx]
        local room
        for _, r in ipairs(R.CAMPAIGN_ROOMS) do
            if r.key == key then
                room = r
            end
        end
        if room == nil then
            return { ok = false, reason = "no room " .. key }
        end
        local sim = newSim(room, runState)
        local inp = newInput()
        local beginFrames = runState.roomTicks[key] or 0
        local r = stepRoom(sim, inp, route, 60 * 600)
        total = total + r.frames
        results[key] = r.frames
        print(string.format("[%s] %s frames=%d total=%d hp=%d route=%s\n",
            key, tostring(r.ok), r.frames, total, sim.hp, tostring(runState.route)))
        if not r.ok then
            return { ok = false, frames = results, total = total, hp = sim.hp }
        end
    end
    return { ok = true, frames = results, total = total }
end

-- C2 单段实验：同一房间、同一入口，分别验证空手 / 先清火器手 / 架残盾 / 放木帘。
-- mode: "empty" | "clear" | "shield" | "curtain"
local function c2Trial(mode, seed)
    local runState = Run.createRun(seed or 20261125)
    runState.joined = true
    runState.route = (mode == "curtain") and "drygoods" or "outer"
    if mode == "shield" then
        runState.inventory.shield = 1
    end
    local sim = newSim(R.CAMPAIGN_ROOMS[5], runState)
    local inp = newInput()
    local minX = sim.room.minX
    local hits, frames, resets = 0, 0, 0
    local evCount = {}
    local lastHp = sim.hp
    local function tick(mx, my, tap)
        inp.moveX = mx or 0
        inp.moveY = my or 0
        inp.jump.pressed = false
        inp.interact.pressed = false
        inp.fire.pressed = false
        if tap ~= nil then
            tap()
        end
        sim:update(1/60, inp)
        frames = frames + 1
        if sim.events ~= nil then
            for _, ev in ipairs(sim.events) do
                evCount[ev.name] = (evCount[ev.name] or 0) + 1
            end
            sim.events = {}
        end
        if sim.hp < lastHp then
            hits = hits + 1
        elseif sim.hp > lastHp then
            resets = resets + 1
        end
        lastHp = sim.hp
    end
    local function lx()
        return sim.player.x - minX
    end
    local function gunner()
        for _, e in ipairs(sim.enemies) do
            if e.kind == "gunner" and e.alive then
                return e
            end
        end
        return nil
    end
    local function seek(x, guard)
        local n = 0
        while lx() < x and n < guard do
            tick(1, sim.player.depth < 30 and -1 or 0)
            n = n + 1
        end
        return n
    end
    local function lane(depth, guard)
        local n = 0
        while sim.player.depth > depth + 2 and n < guard do
            tick(0, 1)
            n = n + 1
        end
        while sim.player.depth < depth - 2 and n < guard do
            tick(0, -1)
            n = n + 1
        end
        return n
    end
    local function press(guard)
        local n = 0
        while n < guard do
            tick(0, 0, function() inp.interact.pressed = true end)
            n = n + 1
            if sim.gripping or runState.props["c2_latch"] ~= nil then
                return n
            end
        end
        return n
    end

    -- 先上档绕过粮袋与空筐。
    seek(1000, 900)
    if mode == "curtain" then
        -- 到远柱正面按 E 放帘。
        seek(1170, 300)
        press(60)
        -- 放帘后退回车柄：者已在 1170，不能只靠前进的 seek。
        local backCurtain = 0
        while lx() > 1092 and backCurtain < 200 do
            tick(-1, 0)
            backCurtain = backCurtain + 1
        end
        lane(2, 200)
    elseif mode == "clear" then
        -- 下到中档，站在暴露轨段前把棚尾火器手打掉。
        lane(2, 200)
        seek(1085, 300)
        local g = gunner()
        local n = 0
        while g ~= nil and g.alive and n < 900 do
            tick(0, 0, function()
                if sim.reloadT <= 0 then
                    sim:aimAt(g.x, g.y + (g.depth or 0) + g.h * 0.6)
                    inp.fire.pressed = true
                end
            end)
            n = n + 1
        end
    end
    -- 架盾要在车柄够不到的地方完成：站到 1000 按 E，避免同帧被车柄的握柄判定抢走。
    if mode == "shield" then
        seek(1000, 300)
        press(40)
        print(string.format("[c2] shield posed lx=%.1f d=%.1f braced=%s", lx(), sim.player.depth,
            tostring(sim.bracedShield ~= nil)))
        lane(2, 200)
        print(string.format("[c2] shield lane lx=%.1f d=%.1f", lx(), sim.player.depth))
        seek(1096, 300)
        print(string.format("[c2] shield seek lx=%.1f d=%.1f", lx(), sim.player.depth))
    end
    -- 走到车柄并握柄：连贯推到底，中途不停。
    if lx() < 1085 then
        seek(1085, 400)
    end
    lane(2, 300)
    seek(1096, 300)
    press(120)
    local n = 0
    while sim.cartAxle < sim.room.cart.endX - 1 and n < 600 do
        tick(1, 0)
        n = n + 1
    end
    lane(0, 300)
    local backN = 0
    while lx() < 1512 and backN < 400 do
        tick(1, 0)
        backN = backN + 1
    end
    press(120)
    print(string.format("[c2] %s latch=%s lx=%.1f d=%.1f docked=%s", mode,
        tostring(runState.props["c2_latch"] ~= nil), lx(), sim.player.depth, tostring(sim.cartDocked)))
    local exitN = 0
    while not runState.finished and exitN < 600 do
        tick(1, 0)
        exitN = exitN + 1
    end
    print(string.format("[c2] %s exit lx=%.1f joined=%s partner=%.1f finished=%s",
        mode, lx(), tostring(runState.joined), sim.partner.x - minX, tostring(runState.finished)))
    return {
        mode = mode,
        seed = runState.seed,
        ok = runState.finished,
        hp = sim.hp,
        hits = hits,
        resets = resets,
        frames = frames,
        docked = sim.cartDocked,
        latch = runState.props["c2_latch"] ~= nil,
        curtain = runState.props["c2_curtain"] ~= nil,
        events = evCount,
    }
end

return {
    run = run,
    stepRoom = stepRoom,
    c2Trial = c2Trial,
    newSim = newSim,
    newInput = newInput,
}
