-- [ts]: dark_pixel_assets.ts
local ____exports = {} -- 1
local ____assets = require("Script.watch.fe.assets") -- 8
local registerDynamicSlot = ____assets.registerDynamicSlot -- 8
____exports.DARK_PIXEL_SLOTS = { -- 10
	dp_road_upper = {paths = {"assets/art/scene_dark_pixel.clip|dp_road_upper"}, anchorY = 0, preserveAspect = false}, -- 12
	dp_road_mid = {paths = {"assets/art/scene_dark_pixel.clip|dp_road_mid"}, anchorY = 0, preserveAspect = false}, -- 13
	dp_road_lower = {paths = {"assets/art/scene_dark_pixel.clip|dp_road_lower"}, anchorY = 0, preserveAspect = false}, -- 14
	dp_road_curb = {paths = {"assets/art/scene_dark_pixel.clip|dp_road_curb"}, anchorY = 0, preserveAspect = false}, -- 15
	dp_wall_top = {paths = {"assets/art/scene_dark_pixel.clip|dp_wall_top"}, anchorY = 0, preserveAspect = false}, -- 18
	dp_wall_side = {paths = {"assets/art/scene_dark_pixel.clip|dp_wall_side"}, anchorY = 0, preserveAspect = false}, -- 19
	dp_wood_top = {paths = {"assets/art/scene_dark_pixel.clip|dp_wood_top"}, anchorY = 0, preserveAspect = false}, -- 20
	dp_wood_side = {paths = {"assets/art/scene_dark_pixel.clip|dp_wood_side"}, anchorY = 0, preserveAspect = false}, -- 21
	dp_stone_top = {paths = {"assets/art/scene_dark_pixel.clip|dp_stone_top"}, anchorY = 0, preserveAspect = false}, -- 22
	dp_stone_side = {paths = {"assets/art/scene_dark_pixel.clip|dp_stone_side"}, anchorY = 0, preserveAspect = false}, -- 23
	dp_stair_step = {paths = {"assets/art/scene_dark_pixel.clip|dp_stair_step"}, anchorY = 0, preserveAspect = false}, -- 26
	dp_latch = {paths = {"assets/art/scene_dark_pixel.clip|dp_latch"}, anchorY = 0, preserveAspect = true}, -- 27
	dp_gate_arch_beam = {paths = {"assets/art/scene_dark_pixel.clip|dp_gate_arch_beam"}, anchorY = 0, preserveAspect = false}, -- 28
	dp_red_cart = {paths = {"assets/art/scene_dark_pixel.clip|dp_red_cart"}, anchorY = 0, preserveAspect = true}, -- 29
	dp_brazier = {paths = {"assets/art/scene_dark_pixel.clip|dp_brazier"}, anchorY = 0, preserveAspect = true}, -- 30
	dp_scorch_zone = {paths = {"assets/art/scene_dark_pixel.clip|dp_scorch_zone"}, anchorY = 0, preserveAspect = false}, -- 31
	dp_stove_hearth = {paths = {"assets/art/scene_dark_pixel.clip|dp_stove_hearth"}, anchorY = 0, preserveAspect = true}, -- 32
	dp_boundary_barricade = {paths = {"assets/art/scene_dark_pixel.clip|dp_boundary_barricade"}, anchorY = 0, preserveAspect = false}, -- 33
	dp_ruin_house_a = {paths = {"assets/art/scene_dark_pixel.clip|dp_ruin_house_a"}, anchorY = 0, preserveAspect = true}, -- 36
	dp_ruin_house_b = {paths = {"assets/art/scene_dark_pixel.clip|dp_ruin_house_b"}, anchorY = 0, preserveAspect = true}, -- 37
	dp_granary_pillar = {paths = {"assets/art/scene_dark_pixel.clip|dp_granary_pillar"}, anchorY = 0, preserveAspect = false}, -- 38
	dp_cliff_rock = {paths = {"assets/art/scene_dark_pixel.clip|dp_cliff_rock"}, anchorY = 0, preserveAspect = true}, -- 39
	dp_fg_rock = {paths = {"assets/art/scene_dark_pixel.clip|dp_fg_rock"}, anchorY = 0, preserveAspect = false}, -- 40
	dp_shadow_contact = {paths = {"assets/art/scene_dark_pixel.clip|dp_shadow_contact"}, anchorY = 0.5, preserveAspect = false}, -- 43
	dp_shadow_air = {paths = {"assets/art/scene_dark_pixel.clip|dp_shadow_air"}, anchorY = 0.5, preserveAspect = false} -- 44
} -- 44
local registered = false -- 47
function ____exports.ensureDarkPixelAssetsRegistered() -- 49
	if registered then -- 49
		return -- 51
	end -- 51
	registered = true -- 53
	for key in pairs(____exports.DARK_PIXEL_SLOTS) do -- 54
		registerDynamicSlot(key, ____exports.DARK_PIXEL_SLOTS[key]) -- 55
	end -- 55
end -- 49
return ____exports -- 49