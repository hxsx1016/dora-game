-- 全游戏地图设计、空气墙与比例自动化巡检回归脚本（verify-map-audit.lua）
local Dora = require("Dora")
local Content = Dora.Content
Content:addSearchPath(Content.assetPath .. "/Script")
Content:addSearchPath(Content.assetPath .. "/Script/Lib")
Content:addSearchPath(Content.assetPath)
package.path = package.path .. ";" .. Content.assetPath .. "/?.lua"

local new = require("Script.Lib.lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local playmod = require("Script.watch.play")
local inputmod = require("Script.watch.input")
local depthmod = require("Script.watch.depth")
local runmod = require("Script.watch.run")
local Frontend = require("Script.watch.fe.frontend").WatchFrontend

local PASS, FAIL = 0, 0
local function check(tag, cond, detail)
	if cond then
		PASS = PASS + 1
		print("  PASS " .. tag)
	else
		FAIL = FAIL + 1
		print("  FAIL " .. tag .. " | " .. tostring(detail or ""))
	end
end

local function step(p, inp, n)
	for _ = 1, (n or 1) do
		p:update(playmod.STEP, inp)
		inp.jump.pressed = false
		inp.interact.pressed = false
	end
end

print("== 1. 全 20 房间 2.5D 深度实体与楼梯完整性检查 ==")
local allRooms = {}
for _, r in ipairs(rooms.ROOMS) do allRooms[#allRooms + 1] = r end
for _, r in ipairs(rooms.CAMPAIGN_ROOMS) do allRooms[#allRooms + 1] = r end

local missingSolidDepth = {}
local missingStairDepth = {}
local hiddenArch25D = {}
for _, raw in ipairs(allRooms) do
	local r = rooms.withOrigin(raw)
	if r.depth ~= nil then
		for _, s in ipairs(r.solids) do
			if not s.decorative and s.depth == nil then
				missingSolidDepth[#missingSolidDepth + 1] = r.key .. ":" .. s.label
			end
		end
		for _, st in ipairs(r.stairs) do
			if st.depth == nil then
				missingStairDepth[#missingStairDepth + 1] = r.key .. ":" .. st.label
			end
		end
		if r.arch ~= nil and r.arch.h > 0 then
			hiddenArch25D[#hiddenArch25D + 1] = r.key .. ":" .. r.arch.label
		end
	end
end
check("1.1 全部 2.5D 房间无缺失 depth 的实体（零全路宽错位空气墙）", #missingSolidDepth == 0, table.concat(missingSolidDepth, ", "))
check("1.2 全部 2.5D 房间无缺失 depth 的楼梯（零空道悬空梯）", #missingStairDepth == 0, table.concat(missingStairDepth, ", "))
check("1.3 全部 2.5D 房间无不可见的 depth-less arch（消除 ESCORT4 断口空气墙）", #hiddenArch25D == 0, table.concat(hiddenArch25D, ", "))

print("== 2. 重点空气墙定点实测（禁用自动跳） ==")
-- 2.1 PROLOGUE：后院矮墙 470..510 不再堵死中/上道；出生点 80 前方宽敞
do
	local p = new(playmod.Play, rooms.PROLOGUE_ROOM)
	local inp = new(inputmod.Input)
	p.phase = "prologue-follow"
	p.player.x, p.player.depth = 420, 0
	p.partner.x, p.partner.depth = 400, 0
	inp.moveX = 1
	step(p, inp, 45)
	check("2.1 序章中道直穿后院 470..510 无空气墙", p.player.x > 540, "x=" .. tostring(p.player.x))
end

-- 2.2 MUSEUM：平地直线走完全程（0 -> 1320），零 2.5D 隐形空气墙
do
	local arch = { childCleared = true, soldierCleared = true, artifactOwned = true, museumPhase = "hall_walk", museumSeen = false }
	local r = runmod.createRun(20261125, "official", arch)
	local p = new(playmod.Play, rooms.MUSEUM_ROOM, nil, r)
	local inp = new(inputmod.Input)
	inp.moveX = 1
	step(p, inp, 320)
	check("2.2 展厅无纵深直行至末厅西窗（越过 180/540/1180 零空气墙）",
		p.room.depth == nil and p.player.x > 1250,
		string.format("depth=%s x=%.1f", tostring(p.room.depth), p.player.x))
end

-- 2.3 ESCORT4：上道（depth=+32）直行越过 900..960 零空气墙
do
	local r = runmod.createRun(20261125, "official")
	r.story.route = "soldier"; r.story.settled = true
	local p = new(playmod.Play, rooms.ESCORT4_ROOM, nil, r)
	p.enemies = {}
	p.player.x, p.player.depth = 840, depthmod.LANE_DEPTH.upper
	local inp = new(inputmod.Input)
	inp.moveX = 1
	step(p, inp, 55)
	check("2.3 第四段山道上道空路直穿 900..960 零空气墙", p.player.x > 990 and p.player.y == 0,
		string.format("x=%.1f y=%.1f", p.player.x, p.player.y))
end

-- 2.4 ESCORT2：棚架梁 300..900 y=64 下方低道畅通（无胸口空气墙）
do
	local r = runmod.createRun(20261125, "official")
	r.story.route = "soldier"; r.story.settled = true
	local p = new(playmod.Play, rooms.ESCORT2_ROOM, nil, r)
	p.enemies = {}
	-- 从棚架梁 300..900 左侧中-下交界（避开 x=300 处下道支柱）直穿棚架下方
	p.player.x, p.player.depth = 240, -10
	local inp = new(inputmod.Input)
	inp.moveX = 1
	step(p, inp, 60)
	check("2.4 第二段粮棚棚架梁下方畅通（x=300..900 无胸口空气墙）", p.player.x > 400, "x=" .. tostring(p.player.x))
end

-- 2.5 OUTSIDE：板车入窝后底层 408..456 站姿直穿零空气墙 + 左侧石阶无需跳直走上二层
do
	local p = new(playmod.Play, rooms.OUTSIDE_ROOM)
	p.cartAxle = p.room.cart.endX
	p.cartDocked = true
	p.player.x, p.player.y = 370, 0
	local inp = new(inputmod.Input)
	inp.moveX = 1
	step(p, inp, 60)
	check("2.5a 城外板车入窝后底层 x=408..456 站姿直行无空气墙", p.player.x > 480, "x=" .. tostring(p.player.x))

	-- 先拉开红布车（与正式流程一致），再测石阶顺滑直上 y=96 台面
	for _, b in ipairs(p.boxes) do
		if b.id == "outside_red_cart" then b.x0, b.x1 = 430, 474 end
	end
	p.player.x, p.player.y, p.player.onGround = 46, 0, true
	inp.moveX = 1
	step(p, inp, 60)
	check("2.5b 城外左侧石阶无需跳跃顺滑直上 y=96 台面", p.player.y >= 95.5 and p.player.x > 130,
		string.format("x=%.1f y=%.1f", p.player.x, p.player.y))
end

-- 2.6 2D 房间支持 S 键下蹲穿桌底/低拱（与帮助面板一致）
do
	local p = new(playmod.Play, rooms.VILLAGE_ROOM)
	p.scavState = "gone"
	p.player.x = 270
	local inp = new(inputmod.Input)
	inp.moveX = 1
	inp.moveY = 1 -- 模拟按住 S
	step(p, inp, 130)
	check("2.6 空村按住 S 下蹲可顺畅穿过桌底（304..416）", p.player.x > 430, "x=" .. tostring(p.player.x))
end

-- 2.7 FOREST：矮台 520..640 起点即抬至 y=22，与低模视觉 1:1 吻合无穿模
do
	local p = new(playmod.Play, rooms.FOREST_ROOM)
	p.player.x, p.player.y, p.player.onGround = 500, 0, true
	local inp = new(inputmod.Input)
	inp.moveX = 1
	step(p, inp, 18)
	check("2.7 森林矮台左半段 520..580 实时抬至 y=22 无穿模", p.player.x >= 530 and p.player.x <= 580 and p.player.y >= 21.5,
		string.format("x=%.1f y=%.1f", p.player.x, p.player.y))
end

-- 2.8 C1 侧门全路封堵 + 抬闩后真实开门
do
	local r = runmod.createRun(20261125, "official")
	local p = new(playmod.Play, rooms.C1_YARD, nil, r)
	p.enemies = {}
	p.player.x, p.player.depth = p.ox + 1740, depthmod.LANE_DEPTH.upper
	local inp = new(inputmod.Input)
	inp.moveX = 1
	step(p, inp, 30)
	check("2.8a C1 侧门未抬闩时上道同样阻挡（不可绕空穿门）", p.player.x < p.ox + 1780, "x=" .. tostring(p.player.x - p.ox))
end

print("== 3. 全角色身高与 2.5D 透视比例验收 ==")
do
	local pS = new(playmod.Play, rooms.PROLOGUE_ROOM)
	local pV = new(playmod.Play, rooms.VILLAGE_ROOM)
	local soldierH = pS.player.h
	local childH = pV.player.h
	local scavH = pV.room.scavenger.h
	check("3.1 身高比例链严格成立（周戍 88 >= 拾荒者 82 > 小满 56 > 桌高 44 > 蹲高 34）",
		soldierH == 88 and scavH == 82 and childH == 56 and pV.room.arch.h == 44,
		string.format("soldier=%d scav=%d child=%d arch=%d", soldierH, scavH, childH, pV.room.arch.h))
	check("3.2 2.5D 纵深压扁系数合理（0.35 <= DEPTH_Y_SCALE <= 0.50）",
		depthmod.DEPTH_Y_SCALE >= 0.35 and depthmod.DEPTH_Y_SCALE <= 0.50,
		"DEPTH_Y_SCALE=" .. tostring(depthmod.DEPTH_Y_SCALE))
end

print("== 4. 渲染层冒烟：破碎墙消失 + 空村单桌正常绘制 ==")
do
	local root = Dora.Node()
	local fe = new(Frontend, root)
	fe.screen = "play"
	local inp = new(inputmod.Input)

	-- 4.1 2.5D 顶盖高度验证：序章倒柜 visual height < 周戍身高
	local pP = new(playmod.Play, rooms.PROLOGUE_ROOM)
	fe:bindPlay(pP, 1280, 720)
	fe:renderPlay(playmod.STEP, pP, inp, 1280, 720)
	local cab = pP.room.solids[1]
	local cabVisualPx = fe.cam:sy(cab.y + cab.h, cab.depth.max) - fe.cam:sy(cab.y, cab.depth.min)
	local soldierPx = fe.cam:len(pP.player.h)
	check("4.1 序章倒柜 2.5D 视觉总高显著低于周戍身高（杜绝矮柜变巨柜）",
		cabVisualPx < soldierPx * 0.72,
		string.format("cabPx=%.1f soldierPx=%.1f ratio=%.2f", cabVisualPx, soldierPx, cabVisualPx / soldierPx))

	-- 4.2 C2 空筐打碎后前端同步撤下不再绘制
	local rC2 = runmod.createRun(20261125, "official")
	local pC2 = new(playmod.Play, rooms.C2_GRANARY, nil, rC2)
	for _, b in ipairs(pC2.boxes) do
		if b.id == "c2_basket" then b.broken = true end
	end
	fe:bindPlay(pC2, 1280, 720)
	fe:renderPlay(playmod.STEP, pC2, inp, 1280, 720)
	local ghost = nil
	for k, sp in pairs(fe.worldArt.visibleLastFrame) do
		if k:find("depth_solid_7600") and sp.visible then ghost = k end
	end
	check("4.2 打碎的可破坏掩体前端不再残留假墙", ghost == nil, "found=" .. tostring(ghost))

	-- 4.3 渲染分层与脚底接触影防吞没断言 + 非小满线实体显式 art 防灰模断言
	check("4.3a 地表层严格位于世界实体层之下（接触影不被地面吞没）",
		fe.groundArt ~= nil and fe.groundArt.container.order < fe.worldArt.container.order,
		string.format("groundArt=%s worldArt=%s",
			tostring(fe.groundArt and fe.groundArt.container.order),
			tostring(fe.worldArt and fe.worldArt.container.order)))

	fe:bindPlay(pP, 1280, 720)
	fe:renderPlay(playmod.STEP, pP, inp, 1280, 720)
	local solShadow = fe.worldArt.visibleLastFrame["shadow_soldier:assets/art/scene_dark_pixel.clip|dp_shadow_contact"]
	local solSprite = fe.worldArt.visibleLastFrame["actor_soldier:assets/art/actors-hd.clip|soldier_idle"]
	check("4.3b 主角脚底接触影与角色同属 worldArt 且紧贴脚下（shadow.order < actor.order）",
		solShadow ~= nil and solSprite ~= nil and solShadow.order < solSprite.order,
		string.format("shadow=%s actor=%s",
			tostring(solShadow and solShadow.order), tostring(solSprite and solSprite.order)))

	local missingArt = {}
	local childKeys = { outside = true, village = true, forest = true, tower = true, museum = true }
	for _, raw in ipairs(allRooms) do
		if not childKeys[raw.key] then
			for _, s in ipairs(raw.solids) do
				if not s.decorative and (s.art == nil or s.art == "") then
					missingArt[#missingArt + 1] = raw.key .. ":" .. s.label
				end
			end
		end
	end
	check("4.4 序章与男主线全部非装饰实体均已显式绑定 art（零隐式灰块退化）", #missingArt == 0, table.concat(missingArt, ", "))

	-- 4.5 GATEPATH 升级 2.5D 窄巷 + ESCORT3 工台消除下道空气墙 + S1 前道清空窗柱
	check("4.5a gatepath 已升级为 2.5D 窄巷（消除 gate->gatepath->escort1 维度锁死）",
		rooms.GATE_PATH_ROOM.depth ~= nil and rooms.GATE_PATH_ROOM.depth.min < 0 and rooms.GATE_PATH_ROOM.depth.max > 0)

	local rE3 = runmod.createRun(20261125, "official")
	rE3.story.route = "soldier"; rE3.story.settled = true
	local pE3 = new(playmod.Play, rooms.ESCORT3_ROOM, nil, rE3)
	pE3.player.x, pE3.player.depth = 500, depthmod.LANE_DEPTH.lower
	inp.moveX = 1
	step(pE3, inp, 90)
	check("4.5b escort3 工台移至中上道与工棚 1:1 对齐，下道无透明空气墙",
		pE3.player.x > 690, "x=" .. tostring(pE3.player.x))

	local pS1 = new(playmod.Play, rooms.S1_CROSSROAD)
	pS1.enemies = {}
	pS1.player.x, pS1.player.depth = 1080, depthmod.LANE_DEPTH.lower
	inp.moveX = 1
	step(pS1, inp, 90)
	check("4.5c s1 窗柱已移靠后侧建筑立面，前道畅通无遮挡",
		pS1.player.x > 1270, "x=" .. tostring(pS1.player.x))

	root:cleanup()
end

print(string.format("MAP AUDIT SUMMARY: %d PASS / %d FAIL", PASS, FAIL))
assert(FAIL == 0, string.format("MAP AUDIT FAIL: %d checks failed", FAIL))
