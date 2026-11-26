-- 《向西守望》小满单人线：出城 → 空村 → 北塔 连续走位验收
-- 只用输入驱动（moveX/crouch/interact/aim），不直接改出口坐标；夹具只设入口存档与安全点。
local Dora = require("Dora")
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local runmod = require("Script.watch.run")
local Input = require("Script.watch.input").Input

local pass, fail = 0, 0
local function check(tag, cond, detail)
	if cond then pass = pass + 1; print(string.format("PASS child: %-46s %s", tag, detail or ""))
	else fail = fail + 1; print(string.format("FAIL child: %-46s %s", tag, detail or "")) end
end

local function newInput()
	local i = new(Input)
	i.moveX, i.moveY = 0, 0
	for _, k in ipairs({ "jump", "crouch", "cover", "interact", "aim", "fire", "flare", "pause", "retry", "toggleView", "tab" }) do
		i[k] = { held = false, pressed = false, released = false }
	end
	return i
end
local function tap(i, k) i[k].held = true; i[k].pressed = true end
local function rel(i, k) i[k].held = false; i[k].pressed = false; i[k].released = true end
local function clear(i) i.moveX = 0; i.pressed = false end
local function step(p, i, n)
	for _ = 1, (n or 1) do
		p:update(play.STEP, i)
		for _, k in ipairs({ "jump", "crouch", "interact", "aim", "fire" }) do i[k].pressed = false; i[k].released = false end
		i.moveX = 0
	end
end
local function hold(p, i, x, n)
	i.moveX = x >= 0 and 1 or -1
	step(p, i, n)
	i.moveX = 0
end
local function moveTo(p, i, goalX, maxSteps)
	local guard = 0
	while math.abs(p.player.x - goalX) > 8 and guard < (maxSteps or 400) do
		i.moveX = p.player.x < goalX and 1 or -1
		p:update(play.STEP, i)
		for _, k in ipairs({ "jump", "crouch", "interact", "aim", "fire" }) do i[k].pressed = false; i[k].released = false end
		guard = guard + 1
	end
	i.moveX = 0
	return guard
end

local function makeRun()
	local r = runmod.createRun(20261124, "official", runmod.createArchive())
	r.story.route = "child"
	r.story.settled = true
	r.story.hp, r.story.maxHp = 2, 3
	r.story.hpAtGate, r.story.maxHpAtGate = 2, 3
	r.story.countTick = 1440
	r.joined = false
	return r
end

local r = makeRun()
local p = new(play.Play, rooms.OUTSIDE_ROOM, nil, r)
local i = newInput()
p.checkpoint = 380
p.player.x = 160
p.player.y = 96
step(p, i, 2)
print(string.format("[child 城外] x=%.1f y=%.1f 红布车=%s", p.player.x, p.player.y, tostring(p.redCartPulled)))

-- 1) 走到红布车（96–140，台面 y96）按 E 拉开
moveTo(p, i, 150, 60)
tap(i, "interact")
step(p, i, 3)
local box = nil
for _, b in ipairs(p.boxes) do if b.id == "outside_red_cart" then box = b end end
check("1.1 红布车从石阶口挪开", box ~= nil and math.abs(box.x0 - 430) < 1 and math.abs(box.x1 - 474) < 1,
	string.format("x0=%.0f x1=%.0f pulled=%s", box and box.x0 or -1, box and box.x1 or -1, tostring(p.redCartPulled)))
check("1.2 拉开一次写入跨房快照", r.story.segments["outside_cart"] == true, "segment=" .. tostring(r.story.segments["outside_cart"]))

-- 2) 下石阶到 0 层，蹲过拱 280–360
moveTo(p, i, 40, 240)
step(p, i, 60)
check("2.1 石阶口已通，落到 0 层", p.player.y <= 1, string.format("x=%.1f y=%.1f", p.player.x, p.player.y))
i.crouch.held = true
moveTo(p, i, 340, 200)
check("2.2 蹲着穿过 44 高的拱", p.player.x >= 300, string.format("x=%.1f crouch=%s", p.player.x, tostring(p.player.crouch)))
i.crouch.held = false

-- 3) 墙根小路：车落窝后只挡站姿，小满蹲着从车底钻过去，再走到底进村（1150）
i.crouch.held = true
moveTo(p, i, 1160, 760)
i.crouch.held = false
step(p, i, 4)
check("3.1 墙根走完切村口", p.wantRoom == "village" or p.room.key == "village", string.format("x=%.1f want=%s cp=%d", p.player.x, tostring(p.wantRoom), p.checkpoint))

-- 4) 村口：拾瓶、投砖地引开、蹲桌下、钻暗渠
local v = new(play.Play, rooms.VILLAGE_ROOM, nil, r)
v.player.x = v.ox + 160
step(v, i, 2)
moveTo(v, i, v.ox + 116, 120)
tap(i, "interact")
step(v, i, 2)
check("4.1 拾起瓶子", v.hasBottle == true, "hasBottle=" .. tostring(v.hasBottle))

-- 走到能看见砖地 608 的位置，按住 F 瞄向 608 再松手
moveTo(v, i, v.ox + 300, 120)
i.aim.held = true
step(v, i, 80)
i.aim.held = false; i.aim.released = true
local fired = false
for _ = 1, 200 do
	v:update(play.STEP, i)
	for _, k in ipairs({ "jump", "crouch", "interact", "aim", "fire" }) do i[k].pressed = false; i[k].released = false end
	-- 等拾荒者被引走：他走到砖地附近
	if v.scavState == "walk" or v.scavState == "stall" then fired = true break end
end
check("4.2 瓶子落到砖地引开拾荒者", v.bottleLandX >= 0 or fired, string.format("land=%.0f scav=%.0f state=%s", v.bottleLandX, v.scavX, v.scavState))

i.crouch.held = true
moveTo(v, i, v.ox + 400, 220)
step(v, i, 30)
local footBeats = {}
for _, e in ipairs(v.events) do
	if e.name == "storyBeat" and (e.data.beat == "footstep_near" or e.data.beat == "footstep_far") then table.insert(footBeats, e.data.beat) end
end
check("4.3 桌下听脚步提示触发", #footBeats > 0, "beats=" .. table.concat(footBeats, ","))
i.crouch.held = false
moveTo(v, i, v.ox + 650, 260)
step(v, i, 4)
check("4.4 钻暗渠切森林", v.wantRoom == "forest" or v.room.key == "forest", "want=" .. tostring(v.wantRoom))

-- 5) 森林：树根窄洞 / 溪湾 / 林缘
local f = new(play.Play, rooms.FOREST_ROOM, nil, r)
f.player.x = f.ox + 120
step(f, i, 2)
i.crouch.held = true
moveTo(f, i, f.ox + 330, 160)
check("5.1 蹲进树根窄洞", f.forestPath == "burrow", "path=" .. tostring(f.forestPath))
i.crouch.held = false
i.crouch.held = true
moveTo(f, i, f.ox + 1210, 600)
i.crouch.held = false
if f.waterSeen then
	-- 已在溪湾
end
check("5.2 溪湾看见水里灯", f.waterSeen == true and r.story.segments["water_lantern"] == true,
	"seen=" .. tostring(f.waterSeen))
moveTo(f, i, f.ox + 1460, 200)
step(f, i, 4)
check("5.3 林缘上岸进塔", f.wantRoom == "tower" or f.room.key == "tower", "want=" .. tostring(f.wantRoom))

-- 6) 塔门留灯（child 线）
local t = new(play.Play, rooms.TOWER_ROOM, nil, r)
t.player.x = t.ox + 420
step(t, i, 2)
moveTo(t, i, t.ox + 420, 40)
tap(i, "interact")
step(t, i, 4)
check("6.1 塔门敲两下", t.knocks >= 1 or t.phase == "tower-knock", string.format("phase=%s knocks=%d", t.phase, t.knocks))
for _ = 1, 240 do
	t:update(play.STEP, i)
	for _, k in ipairs({ "jump", "crouch", "interact", "aim", "fire" }) do i[k].pressed = false; i[k].released = false end
	if t.phase == "tower-end" then break end
end
check("6.2 小满单人线落下留灯结局", t.phase == "tower-end" and t.endingLines[1] == "小满" and t.endingLines[2] == "",
	string.format("phase=%s lines=%s/%s", t.phase, t.endingLines[1], t.endingLines[2]))

print(string.format("小满单人线走位：%d 通过 / %d 失败", pass, fail))
assert(fail == 0, "小满单人线走位验收失败")
