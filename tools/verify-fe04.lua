-- 守望 Wave 2 fe-04（feature/fe-04-child-lowpoly）自动化验收断言
--
-- 用法（引擎项目上下文）：dofile("tools/verify-fe04.lua")
-- 覆盖范围：
-- 1. 全部 14 份 assets/audio/child/*.wav 离线可读
-- 2. visualMode === "lowpoly" 严格隔离（undecided / soldier 像素线绝不激活，child 四房完整接管）
-- 3. 四房关键走面/车柄/投瓶落点/暗渠/塔门 wz = 0 跨分辨率（1280×720、1920×1080）与 screenToWorld 0.00 px 误差
-- 4. outside 城外栈台：左端红布绝不随小满转向翻面；首次握车柄 0.54s 缝布回忆触发一次且不断档持续拉车输入；暂停冻结
-- 5. village 空村桌下：硬砖(608)脆响+鞋尖微顿 vs 铁盆(548)盆沿颤动+金属余振+鞋底转向 vs 软土(272)消音；不限制钻出时机
-- 6. forest 密林与溪湾：踩枯枝/犬耳触发枯枝声与小满侧耳听声（不锁移动）；停步水面涟漪持续流动、暂停冻结；步上溪岸拨枝见真灯
-- 7. tower 北塔低模外景壳体 + drawCutsceneOverlay 返回 false 礼让 fe-05 + 切房/重试彻底清理

local Dora = require("Dora")
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local platform = require("Script.watch.platform")
local lowpolyWorld = require("Script.watch.fe.scenes.lowpoly_world")

local pass = 0
local fail = 0

local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS fe04: %-34s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL fe04: %-34s %s", tag, detail or ""))
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

local function stepOne(p, input, fe, w, h)
	p.aimX, p.aimY = input.mx, input.my
	p:update(play.STEP, input)
	input.interact.pressed = false
	input.interact.released = false
	input.fire.pressed = false
	input.aim.released = false
	input.jump.pressed = false
	input.pause.pressed = false
	fe:renderPlay(play.STEP, p, input, w or fe.cam.viewW, h or fe.cam.viewH)
end

-- 用正在渲染的 Dora Camera3D 位姿和 View 视场角作独立参考；舞台坐标为左下原点。
local function cameraPixel(camera, vp, x, y, depth)
	local eye, target = camera.position, camera.target
	local fy, fz = target.y - eye.y, target.z - eye.z
	local length = math.sqrt(fy * fy + fz * fz)
	fy, fz = fy / length, fz / length
	local dy, dz = y / 100 - eye.y, -depth / 100 - eye.z
	local view = Dora.View.size
	local scale = view.height / (2 * math.tan(math.rad(Dora.View.fieldOfView / 2)) * (fy * dy + fz * dz))
	return view.width / 2 - vp.stageX + (x / 100 - eye.x) * scale,
		view.height / 2 - vp.stageY + (-fz * dy + fy * dz) * scale
end

local function throwAt(p, inp, fe, x, y, depth)
	inp.aim.held = true
	for _ = 1, 10 do
		inp.mx, inp.my = cameraPixel(fe.xiaoman3d.camera, fe.stageVp, x, y, depth)
		stepOne(p, inp, fe)
	end
	local preview = {x = p.bottleAimX, y = p.bottleAimY, depth = p.bottleAimDepth}
	inp.aim.held, inp.aim.released = false, true
	stepOne(p, inp, fe)
	return preview
end

local function countCue(audio, cueId)
	local log = audio:getPlayLog()
	local n = 0
	local backend = 0
	for _, entry in ipairs(log) do
		if entry.cueId == cueId then
			n = n + 1
			if entry.playedBackend then
				backend = backend + 1
			end
		end
	end
	return n, backend
end

local root = Dora.Node()
local fe = new(Frontend, root)
fe.screen = "play"
local reg = lowpolyWorld.registerFe04Plugins(fe)
local lpPl = reg.lowpolyWorld

print("==== FE-04 自动化验收开始 ====")

-- ---------------------------------------------------------------- 1. 全部 14 份分轨 WAV 资产存在检查
do
	local required = {
		"cart_wheel_loop.wav", "cart_dock.wav", "sewing_memory.wav",
		"bottle_brick.wav", "bottle_iron.wav", "bottle_iron_ring.wav", "bottle_soft.wav",
		"twig_snap.wav", "dog_step.wav", "dog_alert.wav", "creek_loop.wav",
		"wind_outside_loop.wav", "village_night_loop.wav", "forest_wind_loop.wav",
	}
	local missing = 0
	for _, fname in ipairs(required) do
		if not Dora.Content:exist("assets/audio/child/" .. fname) then
			missing = missing + 1
			print("MISSING AUDIO: assets/audio/child/" .. fname)
		end
	end
	check("1.1 分轨音频 14 份 WAV 离线可读", missing == 0, "total=" .. #required .. " missing=" .. missing)
end

-- ---------------------------------------------------------------- 2. visualMode === "lowpoly" 严格隔离
do
	local inp = newInput()
	local pV = new(play.Play, rooms.VILLAGE_ROOM)
	fe:bindPlay(pV, 1280, 720)
	-- 正式模式（storyRoute = undecided -> visualMode = pixel）：fe-04 不应激活
	fe:renderPlay(play.STEP, pV, inp, 1280, 720)
	check("2.1 正式 undecided 态 fe-04 严格不激活",
		lpPl:getDebugState(pV).active == false and fe.cam:getAnchorLock() == nil)

	-- 男主线（storyRoute = soldier -> visualMode = pixel）：北塔与城外绝不激活低模
	fe.contract:enterRehearsal("fe04-isolation")
	fe.contract:setMockRoute("soldier")
	local pT = new(play.Play, rooms.TOWER_ROOM)
	fe:bindPlay(pT, 1280, 720)
	fe:renderPlay(play.STEP, pT, inp, 1280, 720)
	check("2.2 男主线 soldier 北塔保持像素风零接管", lpPl:getDebugState(pT).active == false)

	-- 女主线（storyRoute = child -> visualMode = lowpoly）：四房均激活
	fe.contract:setMockRoute("child")
	local childRooms = { rooms.OUTSIDE_ROOM, rooms.VILLAGE_ROOM, rooms.FOREST_ROOM, rooms.TOWER_ROOM }
	local allActive = true
	for _, rm in ipairs(childRooms) do
		local pr = new(play.Play, rm)
		fe:bindPlay(pr, 1280, 720)
		fe:renderPlay(play.STEP, pr, inp, 1280, 720)
		local st = lpPl:getDebugState(pr)
		if not st.active or st.roomKey ~= rm.key then
			allActive = false
		end
	end
	check("2.3 女主线 child 四房全部激活低模渲染", allActive)
	fe.contract:exitRehearsal()
end

-- ---------------------------------------------------------------- 3. 四房 wz=0 跨分辨率与 screenToWorld 零误差
do
	local inp = newInput()
	fe.contract:enterRehearsal("fe04-align")
	fe.contract:setMockRoute("child")
	local cases = {
		{ room = rooms.OUTSIDE_ROOM, pts = { { 344, 96 }, { 432, 96 }, { 320, 0 }, { 760, 32 } } },
		{ room = rooms.VILLAGE_ROOM, pts = { { 112, 48 }, { 272, 0 }, { 360, 0 }, { 440, 0 }, { 548, 0 }, { 608, 0 } } },
		{ room = rooms.FOREST_ROOM, pts = { { 340, 0 }, { 580, 22 }, { 1040, 22 }, { 1450, 0 } } },
		{ room = rooms.TOWER_ROOM, pts = { { 418, 0 }, { 445, 0 } } },
	}
	local resolutions = { { 1280, 720 }, { 1920, 1080 } }
	local maxFwd, maxInv = 0, 0
	for _, res in ipairs(resolutions) do
		local vp = platform.computeStageViewport(res[1], res[2])
		fe:setStagePlacement(vp)
		for _, c in ipairs(cases) do
			local pr = new(play.Play, c.room)
			fe:bindPlay(pr, res[1], res[2])
			fe:renderPlay(play.STEP, pr, inp, res[1], res[2])
			assert(fe.cam.projection == fe.xiaoman3d and Dora.Director.currentCamera == fe.xiaoman3d.camera)
			for _, pt in ipairs(c.pts) do
				local sx, sy = cameraPixel(Dora.Director.currentCamera, vp, pt[1], pt[2], 0)
				local forward = fe.cam:worldToScreen(pt[1], pt[2], 0)
				local inv = pr.worldMapper(sx, sy)
				maxFwd = math.max(maxFwd, math.abs(forward.x - sx), math.abs(forward.y - sy))
				maxInv = math.max(maxInv, math.abs(inv.x - pt[1]), math.abs(inv.y - pt[2]))
			end
		end
	end
	fe:setStagePlacement(platform.computeStageViewport(1280, 720))
	check("3.1 四房全部关键点 wz=0 跨分辨率零误差", maxFwd < 0.001 and maxInv < 0.001,
		string.format("fwd=%.6f inv=%.6f", maxFwd, maxInv))
	fe.contract:exitRehearsal()
end

-- ---------------------------------------------------------------- 4. outside 城外栈台：左端红布不变式 + 0.54s 回忆不打断拉车
do
	local inp = newInput()
	fe.contract:enterRehearsal("fe04-outside")
	fe.contract:setMockRoute("child")
	local p = new(play.Play, rooms.OUTSIDE_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.audio:clearPlayLog()

	-- 小满走到右柄（cartAxle=304, handleOffset=40 -> 344），分别测试朝左与朝右红布均锚定左端
	p.player.x = 344
	p.player.y = 96
	p.player.facing = -1
	fe:renderPlay(play.STEP, p, inp, 1280, 720)
	local stL = lpPl:getDebugState(p).outside
	p.player.facing = 1
	fe:renderPlay(play.STEP, p, inp, 1280, 720)
	local stR = lpPl:getDebugState(p).outside
	check("4.1 红布固定车身左端不随小满转向翻面",
		stL.cartClothLeftInvariantOk and stR.cartClothLeftInvariantOk
		and stL.cartClothWorldX < stL.cartAxleWorldX
		and math.abs(stL.cartClothWorldX - stR.cartClothWorldX) < 0.001,
		string.format("clothX=%.1f axleX=%.1f", stR.cartClothWorldX, stR.cartAxleWorldX))

	-- 首次握车柄（E + D 持续拉车）：触发一次 0.54s 回忆且拉车位移不断档
	local startAxle = p.cartAxle
	inp.interact.pressed = true
	inp.interact.held = true
	inp.moveX = 1
	stepOne(p, inp, fe)
	local memStart = lpPl:getDebugState(p).outside
	for _ = 1, 16 do
		stepOne(p, inp, fe)
	end
	local memMid = lpPl:getDebugState(p).outside
	local midAxle = p.cartAxle
	-- 暂停冻结回忆进度
	p.paused = true
	for _ = 1, 12 do
		fe:renderPlay(play.STEP, p, inp, 1280, 720)
	end
	local memPaused = lpPl:getDebugState(p).outside
	p.paused = false
	for _ = 1, 28 do
		stepOne(p, inp, fe)
	end
	local memEnd = lpPl:getDebugState(p).outside
	local sewCnt, sewBe = countCue(fe.audio, "fe04:outside:sewing_memory")
	check("4.2 首次握柄触发一次 0.54s 缝布回忆与音效",
		memStart.memoryTriggeredCount == 1 and memMid.memoryActive == true
		and memEnd.memoryActive == false and sewCnt == 1 and sewBe == 1,
		string.format("midProg=%.2f sewCnt=%d", memMid.memoryProgress, sewCnt))
	check("4.3 回忆期间持续拉车输入不断档且暂停冻结",
		midAxle > startAxle + 10 and p.cartAxle > midAxle + 15
		and math.abs(memPaused.memoryProgress - memMid.memoryProgress) < 0.001,
		string.format("axle %.1f -> %.1f -> %.1f", startAxle, midAxle, p.cartAxle))

	-- 松手后再握柄不再重复触发回忆
	inp.interact.held = false
	inp.moveX = 0
	stepOne(p, inp, fe)
	inp.interact.pressed = true
	inp.interact.held = true
	stepOne(p, inp, fe)
	check("4.4 再次握车柄不重复触发缝布回忆", lpPl:getDebugState(p).outside.memoryTriggeredCount == 1)
	fe.contract:exitRehearsal()
end

-- ---------------------------------------------------------------- 5. village 空村桌下：砖面 vs 铁盆双反馈 + 自由钻出
do
	local inp = newInput()
	fe.contract:enterRehearsal("fe04-village")
	fe.contract:setMockRoute("child")
	local p = new(play.Play, rooms.VILLAGE_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.audio:clearPlayLog()

	-- 走至瓶架(112)点 E 拾瓶
	p.player.x = 112
	p.player.y = 0
	inp.interact.pressed = true
	stepOne(p, inp, fe)
	check("5.1 空村拾起陶瓶成功", p.hasBottle == true)

	-- 走到桌下蹲伏观察位(332)，瞄准硬砖(608)按住 F 蓄力后松手投出
	p.player.x = 332
	inp.crouch.held = true
	stepOne(p, inp, fe)
	throwAt(p, inp, fe, 608, 2, 0)
	-- 推进 60 拍等待落地(37 拍) + 转头(18 拍) -> 进入 walk
	local brickToePaused = false
	for _ = 1, 60 do
		stepOne(p, inp, fe)
		local vst = lpPl:getDebugState(p).village
		if vst.brickHits == 1 and vst.shoeToePauseTimer > 0 then
			brickToePaused = true
		end
	end
	local vstBrick = lpPl:getDebugState(p).village
	local brickAudioCnt, brickAudioBe = countCue(fe.audio, "bottle:brick")
	check("5.2 砸硬砖(608)触发脆响与拾荒者鞋尖微顿再转向",
		vstBrick.lastSurface == "brick" and vstBrick.brickHits == 1
		and brickToePaused and brickAudioCnt == 1 and brickAudioBe == 1
		and math.abs(p.scavTargetX - 608) < 2.0 and p.scavState == "walk",
		string.format("targetX=%.1f scavState=%s audio=%d", p.scavTargetX, p.scavState, brickAudioCnt))

	-- 第二投：给回瓶子，瞄准铁盆(548)投出 -> 盆沿颤动 + 金属余振 + 拾荒者跟往铁盆方向
	p.hasBottle = true
	throwAt(p, inp, fe, 548, 20.7, 18)
	local basinShook = false
	for _ = 1, 56 do
		stepOne(p, inp, fe)
		local vst = lpPl:getDebugState(p).village
		if vst.ironHits == 1 and vst.basinShakeTimer > 0.5 then
			basinShook = true
		end
	end
	local vstIron = lpPl:getDebugState(p).village
	local ironRingCnt, ironRingBe = countCue(fe.audio, "fe04:bottle:iron_ring")
	check("5.3 砸铁盆(548)触发盆沿颤动、金属余振与鞋底随音转向",
		vstIron.lastSurface == "iron" and vstIron.ironHits == 1
		and basinShook and ironRingCnt == 1 and ironRingBe == 1
		and math.abs(p.scavTargetX - 548) < 2.0,
		string.format("targetX=%.1f shakeT=%.2f ringAudio=%d", p.scavTargetX, vstIron.basinShakeTimer, ironRingCnt))

	-- 第三投：软土(272)消音判定验证
	p.hasBottle = true
	throwAt(p, inp, fe, 272, 0, 0)
	for _ = 1, 42 do
		stepOne(p, inp, fe)
	end
	local vstSoft = lpPl:getDebugState(p).village
	local softCnt, softBe = countCue(fe.audio, "bottle:soft")
	local softFbCnt, softFbBe = countCue(fe.audio, "fe04:bottle:soft_thud")
	local totalSoft = softCnt + softFbCnt
	local totalSoftBe = softBe + softFbBe
	local brickAfterSoft = countCue(fe.audio, "bottle:brick")
	check("5.4 砸软土(272)触发消音浮尘与音频(不误播砖响)",
		vstSoft.lastSurface == "soft" and vstSoft.softHits == 1
		and totalSoft == 1 and totalSoftBe == 1 and brickAfterSoft == 1,
		string.format("softHits=%d softAudio=%d brickAfter=%d", vstSoft.softHits, totalSoft, brickAfterSoft))

	-- 验证玩家在余振期间可自由蹲伏钻出桌下过暗渠通行线(440)，绝不受动画锁控
	inp.crouch.held = true
	inp.moveX = 1
	for _ = 1, 95 do
		stepOne(p, inp, fe)
		if p.passed then break end
	end
	check("5.5 投瓶反馈不限制玩家钻出桌下过暗渠通行线", p.passed == true and p.player.x >= 440,
		string.format("x=%.1f passed=%s", p.player.x, tostring(p.passed)))
	fe.contract:exitRehearsal()
end

-- 三个站位各瞄同一中线砖边、偏纵深砖面和可见盆口；移动出手后的角色不能拖走瓶身。
do
	local view = Dora.View.size
	local vp = platform.computeStageViewport(view.width, view.height)
	fe:setStagePlacement(vp)
	fe.contract:enterRehearsal("fe04-depth")
	fe.contract:setMockRoute("child")
	for _, depth in ipairs({-30, 0, 30}) do
		for _, target in ipairs({{608, 0, 0, "brick"}, {618, 2, -22, "brick"},
			{548, 20.7, 18, "iron"}, {548, 0, -37, "brick"}}) do
			local p, inp = new(play.Play, rooms.VILLAGE_ROOM), newInput()
			fe:bindPlay(p, vp.stageW, vp.stageH)
			p.player.x, p.player.depth, p.hasBottle, inp.crouch.held = 332, depth, true, true
			for _ = 1, 150 do fe:renderPlay(play.STEP, p, inp, vp.stageW, vp.stageH) end
			local x, y, d = target[1], target[2], target[3]
			local preview = throwAt(p, inp, fe, x, y, d)
			local fly = assert(p.bottleFly)
			p.player.depth = -depth
			stepOne(p, inp, fe)
			local model = fe.xiaoman3d.entities.airBottle
			local z = -(depth + (d - depth) * fly.t / play.BOTTLE_FLY_TIME)
			local flightErr = math.max(math.abs(model.z * 100 - z), math.abs(fly.target.x - x), math.abs(fly.target.y - y))
			for _ = 1, 40 do stepOne(p, inp, fe) end
			local err = math.max(flightErr, math.abs(preview.x - x), math.abs(preview.y - y),
				math.abs(preview.depth - d), math.abs(p.bottleLandX - x), math.abs(p.bottleLandY - y),
				math.abs(p.bottleLandDepth - d))
			check("5.6 跨纵深预览、飞行与落点", err < 0.001 and p.bottleLandSurface == target[4],
				string.format("站位=%d 目标=(%g,%g,%g) 落点=(%.4f,%.4f,%.4f) 误差=%.6f 材质=%s",
					depth, x, y, d, p.bottleLandX, p.bottleLandY, p.bottleLandDepth, err, p.bottleLandSurface))
		end
	end
	fe.contract:exitRehearsal()
	fe:setStagePlacement(platform.computeStageViewport(1280, 720))
end

-- ---------------------------------------------------------------- 6. forest 密林枯枝、林犬、溪湾持续涟漪与拨枝见真灯
do
	local inp = newInput()
	fe.contract:enterRehearsal("fe04-forest")
	fe.contract:setMockRoute("child")
	local p = new(play.Play, rooms.FOREST_ROOM)
	fe:bindPlay(p, 1280, 720)
	fe.audio:clearPlayLog()

	-- 非蹲伏踩过枯枝点(235) -> 触发枯枝响与小满侧耳听声，同时小满持续前行不被锁控
	p.player.x = 215
	inp.moveX = 1
	local snapped = false
	for _ = 1, 18 do
		stepOne(p, inp, fe)
		local fst = lpPl:getDebugState(p).forest
		if fst.twigSnapCount >= 1 and fst.xiaomanListenTimer > 0 then
			snapped = true
		end
	end
	local twigCnt, twigBe = countCue(fe.audio, "fe04:forest:twig_snap")
	check("6.1 踩中枯枝触发脆裂声与小满侧耳动作且不锁步",
		snapped and p.player.x > 245 and twigCnt >= 1 and twigBe >= 1,
		string.format("x=%.1f twigCnt=%d", p.player.x, twigCnt))

	-- 溪湾验证：初入溪湾(x=1300)先见水中碎灯倒影、真灯尚被枝叶遮挡；走上溪岸(x=1430)拨枝显露真灯
	inp.moveX = 0
	p.player.x = 1300
	p.player.vx = 0
	fe:renderPlay(play.STEP, p, inp, 1280, 720)
	local fstEntry = lpPl:getDebugState(p).forest
	-- 停步 30 帧：水面涟漪持续流动
	for _ = 1, 30 do
		fe:renderPlay(play.STEP, p, inp, 1280, 720)
	end
	local fstIdle = lpPl:getDebugState(p).forest
	-- 暂停 15 帧：水面涟漪冻结
	p.paused = true
	for _ = 1, 15 do
		fe:renderPlay(play.STEP, p, inp, 1280, 720)
	end
	local fstPaused = lpPl:getDebugState(p).forest
	p.paused = false

	-- 步上溪岸（1300 -> 1435）
	p.player.x = 1435
	fe:renderPlay(play.STEP, p, inp, 1280, 720)
	local fstBank = lpPl:getDebugState(p).forest
	check("6.2 溪湾初见水面碎灯先显、停步涟漪续流、暂停冻结",
		fstEntry.reflectionVisible == true and fstEntry.trueLampVisible == false
		and fstIdle.ripplePhase > fstEntry.ripplePhase + 0.8
		and math.abs(fstPaused.ripplePhase - fstIdle.ripplePhase) < 0.0001,
		string.format("r0=%.2f rIdle=%.2f rPause=%.2f", fstEntry.ripplePhase, fstIdle.ripplePhase, fstPaused.ripplePhase))
	check("6.3 步行上溪岸前景枝叶让开并显露真正北塔灯火",
		fstEntry.creekReveal < 0.05 and fstBank.creekReveal > 0.95 and fstBank.trueLampVisible == true,
		string.format("reveal %.2f -> %.2f waterVol=%.2f", fstEntry.creekReveal, fstBank.creekReveal, fstBank.creekWaterVol))
	fe.contract:exitRehearsal()
end

-- ---------------------------------------------------------------- 7. tower 北塔低模壳体（不截断 fe-05）与切房清理
do
	local inp = newInput()
	fe.contract:enterRehearsal("fe04-tower")
	fe.contract:setMockRoute("child")
	local pT = new(play.Play, rooms.TOWER_ROOM)
	fe:bindPlay(pT, 1280, 720)
	fe:renderPlay(play.STEP, pT, inp, 1280, 720)
	local stT = lpPl:getDebugState(pT)
	-- 切回序章（pixel 模式）验证 anchorLock 与瞬时态完全清零
	fe.contract:exitRehearsal()
	local pP = new(play.Play, rooms.PROLOGUE_ROOM)
	fe:bindPlay(pP, 1280, 720)
	fe:renderPlay(play.STEP, pP, inp, 1280, 720)
	local stP = lpPl:getDebugState(pP)
	check("7.1 北塔低模壳体激活且切房后彻底清净零残留",
		stT.active == true and stT.roomKey == "tower"
		and stP.active == false and fe.cam:getAnchorLock() == nil)
end

root:cleanup()
print(string.format("==== FE-04 验收汇总：PASS %d / FAIL %d ====", pass, fail))
assert(fail == 0, string.format("FE-04 回归失败 %d 项", fail))
