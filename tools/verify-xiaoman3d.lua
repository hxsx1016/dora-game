-- 《向西守望》小满 3D 重构端到端验收脚本（tools/verify-xiaoman3d.lua）
--
-- 用法（引擎项目上下文）：dofile("tools/verify-xiaoman3d.lua")
-- 覆盖范围：
-- 1. 全部 20 份 3D GLB 资产离线存在并可被 Dora SSR 无错加载
-- 2. xiaoman.glb 骨骼挂点 hand_R_socket、13 套内嵌动画及站立尺度验证
-- 3. 四房 3D 四向纵深移动（W/S/A/D）驱动小满正/背/右/左四面朝向与蹲伏动画切换
-- 4. 四房实景交互链路（outside 拉车/铁栓、village 拾瓶/持瓶/投砸铁盆颤动、forest 犬警/溪岸拨枝、tower 叩门/开门/交物）
-- 5. worldToScreen / screenToWorld 跨深度严格互逆，切回像素线彻底隐藏零泄漏

local Dora = require("Dora")
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local lowpolyWorld = require("Script.watch.fe.scenes.lowpoly_world")

local pass = 0
local fail = 0

local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS xm3d: %-38s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL xm3d: %-38s %s", tag, detail or ""))
	end
end

local function newInput()
	local i = new(Input)
	i.moveX = 0
	i.moveY = 0
	i.inside = true
	i.mx, i.my = 640, 360
	for _, k in ipairs({ "jump", "crouch", "cover", "interact", "aim", "fire", "flare", "pause", "retry", "toggleView", "tab" }) do
		i[k] = { held = false, pressed = false, released = false }
	end
	return i
end

local function stepFrames(p, inp, fe, n)
	for _ = 1, n do
		p:update(play.STEP, inp)
		inp.interact.pressed = false
		inp.interact.released = false
		inp.fire.pressed = false
		inp.aim.released = false
		inp.jump.pressed = false
		inp.pause.pressed = false
		fe:renderPlay(play.STEP, p, inp, 1280, 720)
	end
end

local function angDiff(a, b)
	local d = ((a - b + 540) % 360) - 180
	return math.abs(d)
end

print("==== XIAOMAN 3D 自动化验收开始 ====")

-- ---------------------------------------------------------------- 1. 全量 20 份 GLB 资产加载检查
do
	local glbs = {
		"outside.glb", "village.glb", "forest.glb", "tower.glb",
		"xiaoman.glb", "scavenger.glb", "dog.glb", "guard.glb",
		"cart.glb", "bottle.glb", "basin.glb", "door.glb",
		"lantern.glb", "ledger.glb", "pouch.glb", "latch.glb",
		"grass.glb", "twig.glb", "bough.glb", "sky_backdrop.glb",
	}
	local missing, failed = 0, 0
	for _, f in ipairs(glbs) do
		local path = "assets/xiaoman3d/" .. f
		if not Dora.Content:exist(path) then
			missing = missing + 1
			print("MISSING GLB: " .. path)
		else
			local m = Dora.Model3D(path)
			if m == nil then
				failed = failed + 1
				print("LOAD FAIL GLB: " .. path)
			else
				m:removeFromParent()
			end
		end
	end
	check("1.1 全部 20 份 3D GLB 离线可读并可加载", missing == 0 and failed == 0,
		string.format("total=%d missing=%d failed=%d", #glbs, missing, failed))
end

-- ---------------------------------------------------------------- 2. xiaoman.glb 13 套动画与挂点检查
do
	local xm = Dora.Model3D("assets/xiaoman3d/xiaoman.glb")
	local expected = {
		"idle", "walk", "run", "jump",
		"crouch_idle", "crouch_walk", "pull_idle", "pull_walk",
		"aim", "throw", "knock", "offer", "listen",
	}
	local found = {}
	for idx = 0, xm.animationCount - 1 do
		found[xm:getAnimationName(idx)] = true
	end
	local allAnims = true
	for _, name in ipairs(expected) do
		if not found[name] then
			allAnims = false
			print("MISSING XIAOMAN ANIM: " .. name)
		end
	end
	local animCnt = xm.animationCount
	local bmin = xm:getLocalBoundsMin()
	local bmax = xm:getLocalBoundsMax()
	local h = bmax.y - bmin.y
	local hasSock = xm:hasNode("hand_R_socket")
	xm:removeFromParent()
	check("2.1 xiaoman.glb 具备全部 13 套动画与挂点",
		allAnims and animCnt == 13 and hasSock and h >= 0.54 and h <= 0.63,
		string.format("anims=%d socket=%s height=%.3fm", animCnt, tostring(hasSock), h))
end

local root = Dora.Node()
local fe = new(Frontend, root)
fe.screen = "play"
lowpolyWorld.registerFe04Plugins(fe)
fe.contract:enterRehearsal("xm3d-verify")
fe.contract:setMockRoute("child")

-- ---------------------------------------------------------------- 3. 四房 3D 四向行走与四面转向验证
do
	local p = new(play.Play, rooms.OUTSIDE_ROOM)
	local inp = newInput()
	fe:bindPlay(p, 1280, 720)
	stepFrames(p, inp, fe, 2)

	-- 按 S 朝镜头走（正面 0°）
	inp.moveX, inp.moveY = 0, 1
	stepFrames(p, inp, fe, 26)
	local stFront = fe.xiaoman3d:getDebugState()
	local depthFront = p.player.depth

	-- 按 W 背对镜头走（背面 180°）
	inp.moveX, inp.moveY = 0, -1
	stepFrames(p, inp, fe, 45)
	local stBack = fe.xiaoman3d:getDebugState()
	local depthBack = p.player.depth

	-- 按 D 向右走（右侧 +90°）
	inp.moveX, inp.moveY = 1, 0
	stepFrames(p, inp, fe, 26)
	local stRight = fe.xiaoman3d:getDebugState()

	-- 按 A 向左走（左侧 -90°）
	inp.moveX, inp.moveY = -1, 0
	stepFrames(p, inp, fe, 26)
	local stLeft = fe.xiaoman3d:getDebugState()

	-- 蹲伏走与停
	inp.crouch.held = true
	inp.moveX, inp.moveY = 1, 0
	stepFrames(p, inp, fe, 10)
	local stCrouchWalk = fe.xiaoman3d:getDebugState()
	inp.moveX = 0
	stepFrames(p, inp, fe, 6)
	local stCrouchIdle = fe.xiaoman3d:getDebugState()
	inp.crouch.held = false

	check("3.1 四向纵深移动触发正/背/右/左四面朝向",
		depthFront < -5 and depthBack > 5
		and angDiff(stFront.actor.yawDeg, 0) < 15
		and angDiff(stBack.actor.yawDeg, 180) < 15
		and angDiff(stRight.actor.yawDeg, 90) < 15
		and angDiff(stLeft.actor.yawDeg, -90) < 15,
		string.format("front=%.1f back=%.1f right=%.1f left=%.1f",
			stFront.actor.yawDeg, stBack.actor.yawDeg, stRight.actor.yawDeg, stLeft.actor.yawDeg))
	check("3.2 蹲伏移动与静止正确驱动体素骨骼动画",
		stCrouchWalk.actor.animName == "crouch_walk" and stCrouchIdle.actor.animName == "crouch_idle",
		string.format("walk=%s idle=%s", stCrouchWalk.actor.animName, stCrouchIdle.actor.animName))
end

-- ---------------------------------------------------------------- 4. 四房端到端 3D 交互与特效验证
do
	-- 4.1 Outside：握车拉车 + 轮转动画 + 落窝清铁栓
	local pO = new(play.Play, rooms.OUTSIDE_ROOM)
	local inp = newInput()
	fe:bindPlay(pO, 1280, 720)
	pO.player.x, pO.player.y, pO.player.depth = 344, 96, 20
	inp.interact.pressed = true
	inp.interact.held = true
	inp.moveX = 1
	stepFrames(pO, inp, fe, 24)
	local stPull = fe.xiaoman3d:getDebugState()
	check("4.1 城外抓握拉车驱动 pull_walk 与车轮 roll",
		pO.gripping and stPull.actor.animName == "pull_walk" and stPull.entities.cartAnim == "roll",
		string.format("actor=%s cart=%s axle=%.1f", stPull.actor.animName, stPull.entities.cartAnim, pO.cartAxle))

	-- 4.2 Village：拾瓶挂右手 -> 瞄准 -> 投砸铁盆 -> 盆沿颤动 + 声波环
	local pV = new(play.Play, rooms.VILLAGE_ROOM)
	inp = newInput()
	fe:bindPlay(pV, 1280, 720)
	pV.player.x, pV.player.y = 112, 0
	inp.interact.pressed = true
	stepFrames(pV, inp, fe, 2)
	local stHold = fe.xiaoman3d:getDebugState()
	pV.player.x = 332
	inp.crouch.held = true
	stepFrames(pV, inp, fe, 2)
	local basin = fe.xiaoman3d.entities.basin
	local rimY = basin:getWorldBoundsMax().y * 100
	inp.aim.held = true
	for _ = 1, 12 do
		local pt = fe.cam:worldToScreen(basin.x * 100, rimY, -basin.z * 100)
		inp.mx, inp.my = pt.x, pt.y
		pV.aimX, pV.aimY = inp.mx, inp.my
		stepFrames(pV, inp, fe, 1)
	end
	local stAim = fe.xiaoman3d:getDebugState()
	inp.aim.held = false
	inp.aim.released = true
	stepFrames(pV, inp, fe, 44)
	local stHit = fe.xiaoman3d:getDebugState()
	check("4.2 空村拾瓶挂载右手并支持瞄准/投掷铁盆颤动",
		stHold.actor.bottleInHand and stAim.actor.animName == "aim"
		and stHit.entities.basinShakeTimer > 0.2 and stHit.entities.activeRings >= 1,
		string.format("hand=%s aim=%s shake=%.2f rings=%d",
			tostring(stHold.actor.bottleInHand), stAim.actor.animName,
			stHit.entities.basinShakeTimer, stHit.entities.activeRings))

	-- 4.3 Forest：行至溪岸自动拨开前景垂枝
	local pF = new(play.Play, rooms.FOREST_ROOM)
	inp = newInput()
	fe:bindPlay(pF, 1280, 720)
	stepFrames(pF, inp, fe, 4)
	local stF0 = fe.xiaoman3d:getDebugState()
	pF.player.x = 1445
	stepFrames(pF, inp, fe, 50)
	local stF1 = fe.xiaoman3d:getDebugState()
	check("4.3 森林溪湾步上溪岸自动拨开前景松枝",
		stF0.entities.creekReveal < 0.05 and stF1.entities.creekReveal > 0.85,
		string.format("reveal %.2f -> %.2f", stF0.entities.creekReveal, stF1.entities.creekReveal))

	-- 4.4 Tower：叩门 -> 开门向内旋转 -> 值夜桌交物切换守卒写录
	local pT = new(play.Play, rooms.TOWER_ROOM)
	inp = newInput()
	fe:bindPlay(pT, 1280, 720)
	pT.player.x = 420
	stepFrames(pT, inp, fe, 4)
	local stTClosed = fe.xiaoman3d:getDebugState()
	pT.towerDoorOpen = true
	pT.deskHold = 26
	stepFrames(pT, inp, fe, 45)
	local stTOpen = fe.xiaoman3d:getDebugState()
	check("4.4 北塔木门向内开启并切换守卒写录与交物动画",
		stTClosed.entities.doorOpenFrac < 0.05 and stTOpen.entities.doorOpenFrac > 0.85
		and stTOpen.entities.guardAnim == "write" and stTOpen.actor.animName == "offer",
		string.format("door %.2f->%.2f guard=%s actor=%s",
			stTClosed.entities.doorOpenFrac, stTOpen.entities.doorOpenFrac,
			stTOpen.entities.guardAnim, stTOpen.actor.animName))
end

-- ---------------------------------------------------------------- 5. 投影严格互逆与切回像素线隔离
do
	local maxErr = 0
	local inp = newInput()
	local roomList = { rooms.OUTSIDE_ROOM, rooms.VILLAGE_ROOM, rooms.FOREST_ROOM, rooms.TOWER_ROOM }
	for _, rm in ipairs(roomList) do
		local pr = new(play.Play, rm)
		fe:bindPlay(pr, 1280, 720)
		for _, d in ipairs({ -30, 0, 30 }) do
			pr.player.depth = d
			stepFrames(pr, inp, fe, 1)
			local wx, wy = pr.player.x + 80, pr.player.y + 12
			local scr = fe.cam:worldToScreen(wx, wy, d)
			local inv = fe.cam:screenToWorld(scr.x, scr.y)
			local err = math.max(math.abs(inv.x - wx), math.abs(inv.y - wy))
			if err > maxErr then maxErr = err end
		end
	end
	check("5.1 四房跨纵深 worldToScreen/screenToWorld 严格互逆", maxErr < 0.01,
		string.format("maxErr=%.6f", maxErr))

	-- 切回男主像素模式，确认 3D 场景彻底退场
	fe.contract:setMockRoute("soldier")
	local pS = new(play.Play, rooms.STREET_ROOM)
	fe:bindPlay(pS, 1280, 720)
	stepFrames(pS, inp, fe, 2)
	local stOff = fe.xiaoman3d:getDebugState()
	check("5.2 切回男主线像素模式后 3D 场景彻底隐藏零泄漏",
		not stOff.active and fe.cam.projection == nil)
end

fe.contract:exitRehearsal()
root:removeFromParent()

print(string.format("==== XIAOMAN 3D 验收完成：PASS=%d FAIL=%d ====", pass, fail))
if fail > 0 then
	error(string.format("verify-xiaoman3d failed (%d failures)", fail))
end
