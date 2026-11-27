-- [ts]: second_half_assets.ts
local ____exports = {} -- 1
local ____assets = require("Script.watch.fe.assets") -- 7
local registerDynamicSlot = ____assets.registerDynamicSlot -- 7
____exports.SECOND_HALF_SLOTS = { -- 9
	sh_grain_sacks = {paths = {"assets/art/props_second_half.clip|grain_sacks"}, anchorY = 0, preserveAspect = true}, -- 11
	sh_craft_workbench = {paths = {"assets/art/props_second_half.clip|craft_workbench"}, anchorY = 0, preserveAspect = true}, -- 12
	sh_old_watchman = {paths = {"assets/art/props_second_half.clip|old_watchman"}, anchorY = 0, preserveAspect = true}, -- 13
	sh_root_burrow = {paths = {"assets/art/props_second_half.clip|root_burrow"}, anchorY = 0, preserveAspect = true}, -- 14
	sh_salt_hut = {paths = {"assets/art/props_second_half.clip|salt_hut"}, anchorY = 0, preserveAspect = true}, -- 15
	sh_gong_target = {paths = {"assets/art/props_second_half.clip|gong_target"}, anchorY = 0, preserveAspect = true}, -- 16
	sh_iron_basin = {paths = {"assets/art/props_second_half.clip|iron_basin"}, anchorY = 0, preserveAspect = true}, -- 17
	sh_wood_tally = {paths = {"assets/art/props_second_half.clip|wood_tally"}, anchorY = 0.15, preserveAspect = true}, -- 18
	sh_bell_tally = {paths = {"assets/art/props_second_half.clip|bell_tally"}, anchorY = 0.15, preserveAspect = true}, -- 19
	sh_guard_desk = {paths = {"assets/art/props_second_half.clip|guard_desk"}, anchorY = 0, preserveAspect = true}, -- 20
	sh_straw_mat = {paths = {"assets/art/props_second_half.clip|straw_mat"}, anchorY = 0, preserveAspect = true}, -- 21
	sh_stele_banner = {paths = {"assets/art/props_second_half.clip|stele_banner"}, anchorY = 0, preserveAspect = true}, -- 22
	sh_museum_plate_wall = {paths = {"assets/art/props_second_half.clip|museum_plate_wall"}, anchorY = 0.5, preserveAspect = false, smooth = true}, -- 25
	sh_museum_plate_lamp = {paths = {"assets/art/props_second_half.clip|museum_plate_lamp"}, anchorY = 0.5, preserveAspect = false, smooth = true}, -- 26
	sh_museum_compass_relic = {paths = {"assets/art/props_second_half.clip|museum_compass_relic"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 27
	sh_ending_cuff_hand = {paths = {"assets/art/props_second_half.clip|ending_cuff_hand"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 28
	sh_ending_bowl_hands = {paths = {"assets/art/props_second_half.clip|ending_bowl_hands"}, anchorY = 0.5, preserveAspect = true, smooth = true} -- 29
} -- 29
local registered = false -- 32
function ____exports.ensureSecondHalfAssetsRegistered() -- 34
	if registered then -- 34
		return -- 36
	end -- 36
	registered = true -- 38
	for key in pairs(____exports.SECOND_HALF_SLOTS) do -- 39
		registerDynamicSlot(key, ____exports.SECOND_HALF_SLOTS[key]) -- 40
	end -- 40
end -- 34
return ____exports -- 34