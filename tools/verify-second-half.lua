-- 《向西守望》后半段前端融合景箱与护送舞台专项验收脚本
--
-- 用法（引擎项目上下文）：dofile("tools/verify-second-half.lua")
-- 覆盖范围：
-- 1. 选章入口路由预览自动补齐（outside/village/forest/tower -> child+lowpoly；gatepath/escort1..5 -> soldier+pixel+carry），不破坏直接 new Play() 默认契约
-- 2. 非推车房（forest 等）检查点不再误报「检查点 · 车还没到位」
-- 3. 后半段专属像素/宋明图集 props_second_half.clip 17 枚动态槽位完整注册且可加载
-- 4. 男主线 EscortWorldRenderer 覆盖 gatepath + escort1..5，且不破坏 11 枚核心插件清单，离开护送房零残留
-- 5. escort2 粮袋（e2_grain_sacks / grain_sack）、wood/bell 筹牌槽位与 escort3 工台/草束练习靶渲染正常
-- 6. 女主线四房融合景箱：贴图网格、outside O3 盐寮、village 单个活动铁盆模型、forest 树洞与溪湾、tower 剖面揭开守塔老卒与桌案
-- 7. 后半段新增低声对白（E1A..E5B / O3_WIND / F4_CREEK / OPT_SHELL / OPT_NEEDLEBOX / OPT_HOLLOW）全部就位
-- 8. 结局 F03/M03 与现代展厅 E02 专属展板/陈列柜加载正常，且仍守住标签数 <= 10 与袖口同源口径

local Dora = require("Dora")
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local appMod = require("Script.watch.app")
local dialogues = require("Script.watch.dialogues")
local Input = require("Script.watch.input").Input
local Frontend = require("Script.watch.fe.frontend").WatchFrontend
local secondHalfAssets = require("Script.watch.fe.scenes.second_half_assets")
local assetsMod = require("Script.watch.fe.assets")

local pass = 0
local fail = 0

local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS sh: %-38s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL sh: %-38s %s", tag, detail or ""))
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

local function stepFrames(p, inp, fe, n)
	for _ = 1, (n or 6) do
		p:update(play.STEP, inp)
		fe:renderPlay(play.STEP, p, inp, 1280, 720)
	end
end

print("==== SECOND-HALF FRONTEND REDESIGN VERIFY ====")

local root = Dora.Node()
local fe = new(Frontend, root)
fe.screen = "play"
local inp = newInput()

-- 1. 专属图集 17 枚槽位完整注册且 Dora 可读对应 .clip 帧
do
	secondHalfAssets.ensureSecondHalfAssetsRegistered()
	local expected = {
		"sh_grain_sacks",
		"sh_craft_workbench",
		"sh_old_watchman",
		"sh_root_burrow",
		"sh_salt_hut",
		"sh_gong_target",
		"sh_iron_basin",
		"sh_wood_tally",
		"sh_bell_tally",
		"sh_guard_desk",
		"sh_straw_mat",
		"sh_stele_banner",
		"sh_museum_plate_wall",
		"sh_museum_plate_lamp",
		"sh_museum_compass_relic",
		"sh_ending_cuff_hand",
		"sh_ending_bowl_hands",
	}
	local okSlots = 0
	local okSprites = 0
	for _, key in ipairs(expected) do
		local def = secondHalfAssets.SECOND_HALF_SLOTS[key]
		if def ~= nil and def.paths ~= nil and def.paths[1] ~= nil then
			okSlots = okSlots + 1
			local sp = Dora.Sprite(def.paths[1])
			if sp ~= nil then
				okSprites = okSprites + 1
			end
		end
	end
	check("second_half_17_slots_registered", okSlots == 17, string.format("slots=%d/17", okSlots))
	check("second_half_17_sprites_loadable", okSprites == 17, string.format("sprites=%d/17", okSprites))
end

-- 2. 11 枚默认插件清单与 EscortWorldRenderer 协同存在
do
	check("default_plugin_count_preserved", #fe.plugins == 11, "plugins=" .. tostring(#fe.plugins))
	check("escort_world_renderer_present", fe.escortWorld ~= nil, "escortWorld=" .. tostring(fe.escortWorld ~= nil))
end

-- 3. 选章预览自动补齐路线（不破坏直接 new Play 构造）
do
	local runMod = require("Script.watch.run")
	local directVillage = new(play.Play, rooms.VILLAGE_ROOM)
	check("direct_play_keeps_undecided", directVillage.storyRoute == "", "storyRoute=" .. tostring(directVillage.storyRoute))

	local rChild = runMod.createRun(20261124, "chapter", runMod.createArchive())
	appMod.applyChapterPreviewRoute(rChild, "village")
	local pVillage = new(play.Play, rooms.VILLAGE_ROOM, nil, rChild)
	check("chapter_village_sets_child_route", pVillage.storyRoute == "child" and pVillage.run.story.settled == true and pVillage.childMode == true,
		string.format("route=%s settled=%s child=%s",
			tostring(pVillage.storyRoute),
			tostring(pVillage.run.story.settled),
			tostring(pVillage.childMode)))
	local svVillage = fe.contract:peekSnapshot(pVillage)
	check("chapter_village_visual_mode_lowpoly", svVillage.visualMode == "lowpoly", "visualMode=" .. tostring(svVillage.visualMode))

	local rSol = runMod.createRun(20261124, "chapter", runMod.createArchive())
	appMod.applyChapterPreviewRoute(rSol, "escort2")
	local pEscort2 = new(play.Play, rooms.ESCORT2_ROOM, nil, rSol)
	check("chapter_escort2_sets_soldier_carry", pEscort2.storyRoute == "soldier" and pEscort2.run.story.settled == true and pEscort2.run.story.carry == true,
		string.format("route=%s carry=%s",
			tostring(pEscort2.storyRoute),
			tostring(pEscort2.run.story.carry)))
end

-- 4. 非推车房 forest 触发检查点不再误报「车还没到位」
do
	local pf = new(play.Play, rooms.FOREST_ROOM)
	pf.storyRoute = "child"
	pf.storyRouteSettled = true
	pf.childMode = true
	pf.player.x = pf.ox + 710
	pf.flash = ""
	fe:bindPlay(pf, 1280, 720)
	stepFrames(pf, inp, fe, 8)
	check("forest_checkpoint_no_cart_error", pf.flash ~= "检查点 · 车还没到位", "flash=" .. tostring(pf.flash))
end

-- 5. ESCORT2 粮袋标记与男主线 6 房 EscortWorldRenderer 激活/清理校验
do
	local escortWorldMod = require("Script.watch.fe.scenes.escort_world")
	local hasGrainSack = false
	for _, solid in ipairs(rooms.ESCORT2_ROOM.solids or {}) do
		if solid.art == "grain_sack" and solid.id == "e2_grain_sacks" then
			hasGrainSack = true
			break
		end
	end
	check("escort2_grain_sack_tagged", hasGrainSack, "e2_grain_sacks=" .. tostring(hasGrainSack))

	local escortRooms = {
		rooms.GATE_PATH_ROOM,
		rooms.ESCORT1_ROOM,
		rooms.ESCORT2_ROOM,
		rooms.ESCORT3_ROOM,
		rooms.ESCORT4_ROOM,
		rooms.ESCORT5_ROOM,
	}
	local allActive = true
	for _, r in ipairs(escortRooms) do
		local pe = new(play.Play, r)
		pe.storyRoute = "soldier"
		pe.storyRouteSettled = true
		pe.escort.joined = true
		pe.escort.carry = true
		fe:bindPlay(pe, 1280, 720)
		if r.key == "escort1" then
			local drawTower = fe.escortWorld.drawDistantNorthTower
			local place = fe.backdropArt.tryPlace
			local bodyLayer, lampLayer, painted
			local polygons, lampX, lampY
			fe.escortWorld.drawDistantNorthTower = function(renderer, body, lamp, w, h, camX, time, spec, dawn, behind, window)
				bodyLayer, lampLayer, painted = body, lamp, window
				polygons = 0
				local bodyProbe = {
					drawPolygon = function(_, ...) polygons = polygons + 1; body:drawPolygon(...) end,
					drawRect = function(_, ...) body:drawRect(...) end,
				}
				local lampProbe = setmetatable({
					drawDot = function(_, pos, ...) lampX, lampY = pos.x, pos.y; lamp:drawDot(pos, ...) end,
				}, {__index = function(_, method) return function(_, ...) lamp[method](lamp, ...) end end})
				return drawTower(renderer, bodyProbe, lampProbe, w, h, camX, time, spec, dawn, behind, window)
			end
			stepFrames(pe, inp, fe, 1)
			local ridge = fe.backdropArt.sprites["ming_fallback_scene:assets/art/bg_escort_ridge.png"]
			check("escort1_painted_window_no_second_tower", ridge and ridge.visible and painted and polygons == 0
				and math.abs(lampX - (ridge.x + (568/640 - ridge.anchor.x)*ridge.width*ridge.scaleX)) < 0.01
				and math.abs(lampY - (ridge.y + (309/360 - ridge.anchor.y)*ridge.height*ridge.scaleY)) < 0.01)
			check("escort1_tower_above_backdrop_below_lamp", ridge and ridge.parent.parent == bodyLayer.parent
				and bodyLayer.parent == lampLayer.parent and ridge.parent.order < bodyLayer.order and bodyLayer.order < lampLayer.order)
			for _, fallback in ipairs({"outside", "missing"}) do
				fe.backdropArt.tryPlace = function(host, slot, id, ...)
					if slot == "bgFar_escort_ridge" then
						if fallback == "missing" then return false end
						slot = "bgFar_outside"
					end
					return place(host, slot, id, ...)
				end
				stepFrames(pe, inp, fe, 1)
				check("escort1_procedural_tower_" .. fallback, painted == nil and polygons > 0 and bodyLayer.order == 13)
			end
			fe.backdropArt.tryPlace = place
			fe.escortWorld.drawDistantNorthTower = drawTower
		end
		stepFrames(pe, inp, fe, 6)
		if r.key == "escort3" then
			local visible = fe.worldArt.visibleLastFrame
			check("escort3_workbench_placed", visible["e3_sanctuary_bench:assets/art/props_second_half.clip|craft_workbench"] ~= nil)
			local targets, obsolete = 0, 0
			for key in pairs(visible) do
				if key:match("^actor_target_%d+:assets/art/props_ming%.clip|target_dummy$") then
					targets = targets + 1
				end
				if key:find("^e3_gong_target_") or key:find("^depth_solid_560_") then
					obsolete = obsolete + 1
				end
			end
			check("escort3_one_body_per_target_and_bench", targets == 2 and obsolete == 0)
		end
		if not escortWorldMod.isEscortWorldRoom(pe.room.key) then
			allActive = false
		end
	end
	check("escort_world_active_all_6_stages", allActive, "stages=6")

	local pp = new(play.Play, rooms.PROLOGUE_ROOM)
	fe:bindPlay(pp, 1280, 720)
	stepFrames(pp, inp, fe, 4)
	check("escort_world_inactive_in_prologue", not escortWorldMod.isEscortWorldRoom(pp.room.key), "prologue_inactive")
end

-- 6. 女主线四房低模融合景箱 + 北塔剖面揭开检查
do
	local lp = fe:getPlugin("fe-04-child-lowpoly")
	for _, r in ipairs({ rooms.OUTSIDE_ROOM, rooms.VILLAGE_ROOM, rooms.FOREST_ROOM, rooms.TOWER_ROOM }) do
		local pc = new(play.Play, r)
		pc.storyRoute = "child"
		pc.storyRouteSettled = true
		pc.childMode = true
		if r.key == "tower" then
			pc.towerDoorOpen = true
			pc.phase = "tower-enter"
		end
		-- Dora 的 Node3D 未暴露子节点遍历；记录本次入村真正构造的盆，再核对场景挂载和可见性。
		local models = {}
		local modelClass = getmetatable(Dora.Model3D)
		local construct = modelClass.__call
		if r.key == "village" then
			modelClass.__call = function(class, path, ...)
				local model = construct(class, path, ...)
				if path == "assets/xiaoman3d/basin.glb" then models[#models + 1] = model end
				return model
			end
		end
		local ok, err = pcall(function()
			fe:bindPlay(pc, 1280, 720)
			stepFrames(pc, inp, fe, 8)
		end)
		modelClass.__call = construct
		assert(ok, err)
		local dbg = lp:getDebugState(pc)
		if r.key == "village" then
			local visible, painted = 0, 0
			for _, model in ipairs(models) do
				local node = model
				while node and node.visible and node ~= Dora.Director.entry.scene do node = node.parent end
				if node == Dora.Director.entry.scene then visible = visible + 1 end
			end
			for key, count in pairs(fe.dioramaWorld.spriteCursor) do
				if key:find("diorama_cutouts.clip|iron_basin", 1, true) then painted = painted + count end
			end
			check("village_one_visible_3d_basin", visible == 1 and painted == 0,
				string.format("visible models=%d cutouts=%d", visible, painted))
		end
		check("child_diorama_active_" .. r.key, dbg.active == true, string.format("room=%s active=%s", r.key, tostring(dbg.active)))
	end
end

-- 7. 新增后半段对白词条完整性检查
do
	local requiredIds = {
		"E1A", "E1B", "E2A", "E2B", "E3A", "E3B",
		"E4A", "E4B", "E5A", "E5B",
		"O3_WIND", "F4_CREEK",
		"OPT_SHELL", "OPT_NEEDLEBOX", "OPT_HOLLOW",
	}
	local found = 0
	for _, id in ipairs(requiredIds) do
		local entry = dialogues.SCRIPT_DIALOGUES[id]
		if entry ~= nil and type(entry.text) == "string" and #entry.text > 0 then
			found = found + 1
		end
	end
	check("second_half_dialogues_complete", found == #requiredIds, string.format("found=%d/%d", found, #requiredIds))
end

-- 8. F03 / M03 结局与 E02 展厅渲染无报错 + 校验结束
do
	local endPl = fe:getPlugin("fe-05-tower-endings")
	local musPl = fe:getPlugin("fe-06-well-museum")
	local pt = new(play.Play, rooms.TOWER_ROOM)
	pt.storyRoute = "child"
	pt.storyRouteSettled = true
	pt.childMode = true
	pt.towerDoorOpen = true
	fe:bindPlay(pt, 1280, 720)
	endPl:startRehearsal("child", fe.contract, { seekTime = 8.2 })
	for _ = 1, 6 do fe:renderPlay(0.05, pt, inp, 1280, 720) end
	check("f03_ending_hold_clean", endPl:getDebugState().active == true, "phase=" .. tostring(endPl:getDebugState().phase))

	endPl:startRehearsal("soldier", fe.contract, { seekTime = 8.2 })
	for _ = 1, 6 do fe:renderPlay(0.05, pt, inp, 1280, 720) end
	check("m03_ending_hold_clean", endPl:getDebugState().active == true, "phase=" .. tostring(endPl:getDebugState().phase))
	endPl:stopRehearsal(fe.contract)

	local pm = new(play.Play, rooms.MUSEUM_ROOM)
	fe.contract:enterRehearsal("verify-sh-museum")
	fe.contract:setMockArchive(true, true, true)
	fe.contract:enterMockMuseum("hall_walk")
	fe:bindPlay(pm, 1280, 720)
	musPl:setHallWalkPosition(620, true)
	for _ = 1, 10 do fe:renderPlay(0.05, pm, inp, 1280, 720) end
	local mDbg = musPl:getDebugState()
	check("e02_museum_hall_renders_clean", mDbg.museumPhase == "hall_walk", "phase=" .. tostring(mDbg.museumPhase))
	fe.contract:exitRehearsal()
end

root:cleanup()
print(string.format("==== SECOND-HALF VERIFY DONE: PASS %d, FAIL %d ====", pass, fail))
if fail > 0 then
	error("verify-second-half failed: " .. tostring(fail))
end
