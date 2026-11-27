-- [ts]: assets.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local FALLBACK_DYNAMIC_SLOTS -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 1
local Content = ____Dora.Content -- 1
local Node = ____Dora.Node -- 1
local Rect = ____Dora.Rect -- 1
local Size = ____Dora.Size -- 1
local Sprite = ____Dora.Sprite -- 1
local Vec2 = ____Dora.Vec2 -- 1
local function backdrop(name, smooth) -- 96
	if smooth == nil then -- 96
		smooth = false -- 96
	end -- 96
	return smooth and ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false, smooth = true}) or ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false}) -- 97
end -- 96
local function clip(names, anchorY, preserveAspect, anchorX) -- 102
	if anchorY == nil then -- 102
		anchorY = 0 -- 104
	end -- 104
	if preserveAspect == nil then -- 104
		preserveAspect = false -- 105
	end -- 105
	local frames = type(names) == "string" and ({names}) or names -- 108
	return { -- 109
		paths = __TS__ArrayMap( -- 109
			frames, -- 109
			function(____, name) return "assets/art/sprites.clip|" .. name end -- 109
		), -- 109
		anchorX = anchorX, -- 109
		anchorY = anchorY, -- 109
		preserveAspect = preserveAspect -- 109
	} -- 109
end -- 102
local function inkClip(name, preserveAspect) -- 112
	if preserveAspect == nil then -- 112
		preserveAspect = false -- 112
	end -- 112
	return {paths = {"assets/art/ui_ink.clip|" .. name}, anchorY = 0.5, preserveAspect = preserveAspect, smooth = true} -- 113
end -- 112
local function actor(names, anchorX) -- 116
	return clip(names, 0, true, anchorX) -- 117
end -- 116
local function slide(name) -- 120
	return {paths = {("assets/art/slides/" .. name) .. ".png"}, anchorY = 0.5, preserveAspect = false} -- 121
end -- 120
local function comicCutscene(rel) -- 124
	return {paths = {("assets/art/cutscenes/" .. rel) .. ".png"}, anchorY = 0.5, preserveAspect = false, smooth = true} -- 125
end -- 124
local function feClip(names, anchorY, preserveAspect, anchorX) -- 128
	if anchorY == nil then -- 128
		anchorY = 0.5 -- 130
	end -- 130
	if preserveAspect == nil then -- 130
		preserveAspect = true -- 131
	end -- 131
	local frames = type(names) == "string" and ({names}) or names -- 134
	return { -- 135
		paths = __TS__ArrayMap( -- 135
			frames, -- 135
			function(____, name) return "assets/art/sprites_fe.clip|" .. name end -- 135
		), -- 135
		anchorX = anchorX, -- 135
		anchorY = anchorY, -- 135
		preserveAspect = preserveAspect -- 135
	} -- 135
end -- 128
local function character(names) -- 138
	local frames = type(names) == "string" and ({names}) or names -- 139
	return { -- 140
		paths = __TS__ArrayMap( -- 140
			frames, -- 140
			function(____, name) return "assets/art/actors-hd.clip|" .. name end -- 140
		), -- 140
		anchorY = 0, -- 140
		preserveAspect = true -- 140
	} -- 140
end -- 138
____exports.RUN_FRAME_COUNT = 160 -- 143
____exports.RUN_TRANSITION_PHASES = 8 -- 144
____exports.RUN_TRANSITION_LEVELS = 12 -- 145
____exports.SLIDE_FRAME_COUNT = 64 -- 146
local ATLAS_GUTTER = 2 -- 147
local RUN_ATLASES = {soldier = {path = "assets/art/zhoushu-run.png", width = 180, height = 200, columns = 10}, child = {path = "assets/art/xiaoman-run.png", width = 144, height = 164, columns = 10}} -- 156
local RUN_TRANSITIONS = { -- 160
	soldier = __TS__ObjectAssign({}, RUN_ATLASES.soldier, {path = "assets/art/zhoushu-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}), -- 161
	child = __TS__ObjectAssign({}, RUN_ATLASES.child, {path = "assets/art/xiaoman-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}) -- 162
} -- 162
local SLIDE_ATLAS = {path = "assets/art/zhoushu-slide.png", width = 300, height = 198, columns = 8} -- 164
____exports.ASSET_SLOTS = { -- 168
	bgFar_prologue = backdrop("prologue"), -- 169
	bgFar_street = backdrop("street"), -- 170
	bgFar_checkpoint = backdrop("checkpoint"), -- 171
	bgFar_gate = backdrop("gate"), -- 172
	bgFar_outside = backdrop("outside"), -- 173
	bgFar_village = backdrop("village"), -- 174
	bgFar_forest = backdrop("forest"), -- 175
	bgFar_tower = backdrop("tower"), -- 176
	bgFar_crossroad_drygoods = backdrop("bg_crossroad_drygoods"), -- 177
	bgFar_archway_yard = backdrop("bg_archway_yard"), -- 178
	bgFar_granary = backdrop("bg_granary"), -- 179
	bgFar_escort_ridge = backdrop("bg_escort_ridge"), -- 180
	bgFar_museum = backdrop("bg_museum_hall", true), -- 181
	title_backdrop = backdrop("title"), -- 182
	soldier_idle = character("soldier_idle"), -- 183
	soldier_run = character({"soldier_run", "soldier_step"}), -- 184
	soldier_roll = character("soldier_roll"), -- 185
	soldier_slide = character({"soldier_slide_0", "soldier_slide_1", "soldier_slide_2", "soldier_slide_3"}), -- 186
	soldier_cover = character("soldier_cover"), -- 187
	soldier_push = character({"soldier_push", "soldier_push_step"}), -- 188
	soldier_hold = character("soldier_hold"), -- 189
	soldier_offer = character("soldier_offer"), -- 190
	soldier_knock = character({"soldier_cover", "soldier_knock"}), -- 191
	soldier_hit = character("soldier_hit"), -- 192
	soldier_fire = character("soldier_fire"), -- 193
	soldier_fire_move = character({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}), -- 194
	child_idle = character("child_idle"), -- 195
	child_run = character({"child_run", "child_step"}), -- 196
	child_crouch = character({"child_crouch", "child_crouch_step"}), -- 197
	child_fear = character("child_fear"), -- 198
	child_peek = character("child_peek"), -- 199
	child_pull = character({"child_pull", "child_pull_step"}), -- 200
	child_aim = character("child_aim"), -- 201
	child_throw = character("child_throw"), -- 202
	child_knock = character("child_knock"), -- 203
	child_offer = character("child_offer"), -- 204
	enemy_idle = actor("enemy_idle", 0.5), -- 205
	enemy_aim = actor("enemy_aim", 0.51), -- 206
	enemy_down = actor("enemy_down"), -- 207
	enemy_hit = actor("enemy_hit", 0.48), -- 208
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}, {0.52, 0.52, 0.48, 0.52}), -- 209
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}, {0.5, 0.5, 0.54, 0.58}), -- 210
	prop_cart = clip("cart", 0, false, 0.44), -- 211
	prop_bottle = clip("bottle", 0.5, true), -- 212
	prop_tower_door = clip("door"), -- 213
	prop_lantern = clip("lantern", 0.5, true), -- 214
	prop_table = clip("table"), -- 215
	prop_compass = clip("compass", 0.5, true), -- 216
	prop_winch = clip("winch", 0.5, true), -- 217
	wall = clip("wall"), -- 218
	cover_wood = clip("cover_wood"), -- 219
	cover_stone = clip("cover_stone"), -- 220
	fence = clip("fence"), -- 221
	slab = clip("slab"), -- 222
	eaves = clip("eaves"), -- 223
	pine = clip("pine"), -- 224
	grass = clip("grass"), -- 225
	grass_low = clip("grass_low"), -- 226
	stone_chips = clip("stone_chips", 0.5, true), -- 227
	ui_corner = clip("ui_corner"), -- 228
	ui_corner_c = clip("ui_corner", 0.5, false), -- 229
	ui_paper = clip("paper", 0.5), -- 230
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 231
	ink_mist_curve = inkClip("ink_mist_curve"), -- 232
	ink_veil_strip = inkClip("ink_veil_strip"), -- 233
	ink_hairline = inkClip("ink_hairline"), -- 234
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 235
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 236
	ink_frame_mask = inkClip("ink_frame_mask"), -- 237
	ink_vstream = inkClip("ink_vstream"), -- 238
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 239
	ink_corner_fine = inkClip("ink_corner_fine"), -- 240
	ink_seal_slender = inkClip("ink_seal_slender"), -- 241
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 242
	ink_enso_fine = inkClip("ink_enso_fine"), -- 243
	ink_petal_mist = inkClip("ink_petal_mist"), -- 244
	ink_song_paper = inkClip("ink_song_paper"), -- 245
	brand_game_logo_h = {paths = {"assets/art/brand/game_logo_h.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 246
	brand_game_logo_v = {paths = {"assets/art/brand/game_logo_v.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 247
	brand_team_logo = {paths = {"assets/art/brand/team_logo_dark.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 248
	brand_team_badge = {paths = {"assets/art/brand/team_badge.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 249
	slide_p01_01 = slide("p01_01_curtain"), -- 251
	slide_p01_02 = slide("p01_02_hand"), -- 252
	slide_p01_03 = slide("p01_03_door"), -- 253
	slide_p02_01 = slide("p02_01_shadows"), -- 254
	slide_p02_02 = slide("p02_02_cut"), -- 255
	slide_p02_03 = slide("p02_03_bowl_roll"), -- 256
	slide_p02_04 = slide("p02_04_bowl_stop"), -- 257
	slide_p02_05 = slide("p02_05_cabinet"), -- 258
	slide_cuff_p03_01 = slide("cuff_p03_01"), -- 259
	slide_cuff_p03_02 = slide("cuff_p03_02"), -- 260
	slide_cuff_p03_03 = slide("cuff_p03_03"), -- 261
	slide_cuff_p03_04 = slide("cuff_p03_04"), -- 262
	slide_cuff_p05_01 = slide("cuff_p05_01"), -- 263
	slide_cuff_p05_02 = slide("cuff_p05_02"), -- 264
	slide_cuff_p05_03 = slide("cuff_p05_03"), -- 265
	slide_cuff_p05_04 = slide("cuff_p05_04"), -- 266
	slide_cuff_g05_01 = slide("cuff_g05_01"), -- 267
	slide_cuff_g05_02 = slide("cuff_g05_02"), -- 268
	slide_cuff_g05_03 = slide("cuff_g05_03"), -- 269
	slide_cuff_g05_04 = slide("cuff_g05_04"), -- 270
	slide_gate_01 = {paths = {"assets/art/slides/gate_stage_01.png"}, anchorY = 0, preserveAspect = false}, -- 271
	slide_gate_02 = {paths = {"assets/art/slides/gate_stage_02.png"}, anchorY = 0, preserveAspect = false}, -- 272
	slide_gate_03 = {paths = {"assets/art/slides/gate_stage_03.png"}, anchorY = 0, preserveAspect = false}, -- 273
	slide_gate_04 = {paths = {"assets/art/slides/gate_stage_04.png"}, anchorY = 0, preserveAspect = false}, -- 274
	slide_tower_porch_f03_closed = slide("tower_porch_f03_closed"), -- 275
	slide_tower_porch_f03_open = slide("tower_porch_f03_open"), -- 276
	slide_tower_porch_m03_closed = slide("tower_porch_m03_closed"), -- 277
	slide_tower_porch_m03_open = slide("tower_porch_m03_open"), -- 278
	slide_tower_room_f03_cold = slide("tower_room_f03_cold"), -- 279
	slide_tower_room_f03_lit = slide("tower_room_f03_lit"), -- 280
	slide_tower_room_m03_warm = slide("tower_room_m03_warm"), -- 281
	slide_tower_interior_live = {paths = {"assets/art/slides/tower_interior_live.png"}, anchorY = 0, preserveAspect = false}, -- 282
	slide_e01_well = slide("e01_01_well"), -- 283
	slide_e01_compass = slide("e01_02_compass"), -- 284
	slide_e01_vitrine = slide("e01_03_vitrine"), -- 285
	slide_e02_museum_hall = {paths = {"assets/art/slides/e02_museum_hall.png"}, anchorY = 0, preserveAspect = false}, -- 286
	slide_e02_window_dawn = slide("e02_window_dawn"), -- 287
	slide_e02_return_cabinet = slide("e02_return_cabinet"), -- 288
	slide_f01_sewing = slide("f01_sewing_memory"), -- 289
	slide_m02_lantern_gun = slide("m02_handover_lantern"), -- 290
	slide_m02_echo_gun = slide("m02_handover_echo"), -- 291
	comic_p01_01_curtain_dark = comicCutscene("p01/p01_01_curtain_dark"), -- 293
	comic_p01_02_curtain_glow = comicCutscene("p01/p01_02_curtain_glow"), -- 294
	comic_p01_03_hand_bedrail = comicCutscene("p01/p01_03_hand_bedrail"), -- 295
	comic_p01_04_look_door = comicCutscene("p01/p01_04_look_door"), -- 296
	comic_p02_01_shadows = comicCutscene("p02/p02_01_shadows"), -- 297
	comic_p02_02a_door_intrude = comicCutscene("p02/p02_02a_door_intrude"), -- 298
	comic_p02_03_impact_cut = comicCutscene("p02/p02_03_impact_cut"), -- 299
	comic_p02_04_shadows_fall = comicCutscene("p02/p02_04_shadows_fall"), -- 300
	comic_p02_05_bowl_roll1 = comicCutscene("p02/p02_05_bowl_roll1"), -- 301
	comic_p02_06_bowl_roll2 = comicCutscene("p02/p02_06_bowl_roll2"), -- 302
	comic_p02_07_bowl_smash = comicCutscene("p02/p02_07_bowl_smash"), -- 303
	comic_p02_08a_cabinet_slit = comicCutscene("p02/p02_08a_cabinet_slit"), -- 304
	comic_p02_08m_cabinet_narrowing = comicCutscene("p02/p02_08m_cabinet_narrowing"), -- 305
	comic_p02_08b_cabinet_shut = comicCutscene("p02/p02_08b_cabinet_shut"), -- 306
	comic_p03_01_two_fingers = comicCutscene("p03/p03_01_two_fingers"), -- 307
	comic_p03_02_cuff_enter = comicCutscene("p03/p03_02_cuff_enter"), -- 308
	comic_p03_03_cuff_wipe = comicCutscene("p03/p03_03_cuff_wipe"), -- 309
	comic_p03_04_hand_meet = comicCutscene("p03/p03_04_hand_meet"), -- 310
	comic_p05_01_clutch_cuff = comicCutscene("p05/p05_01_clutch_cuff"), -- 311
	comic_p05_02_brother_pinch = comicCutscene("p05/p05_02_brother_pinch"), -- 312
	comic_p05_03_sleeve_pull = comicCutscene("p05/p05_03_sleeve_pull"), -- 313
	comic_p05_04_gate_drop = comicCutscene("p05/p05_04_gate_drop"), -- 314
	comic_p05_05_gate_slam_impact = comicCutscene("p05/p05_05_gate_slam_impact"), -- 315
	comic_p05_06_open_fingers = comicCutscene("p05/p05_06_open_fingers"), -- 316
	comic_g05_01_cuff_peek = comicCutscene("g05/g05_01_cuff_peek"), -- 317
	comic_g05_02_cuff_extend = comicCutscene("g05/g05_02_cuff_extend"), -- 318
	comic_g05_03_hands_meet = comicCutscene("g05/g05_03_hands_meet"), -- 319
	comic_g05_04_hands_clasp = comicCutscene("g05/g05_04_hands_clasp"), -- 320
	comic_g05_05_tilt_arm = comicCutscene("g05/g05_05_tilt_arm"), -- 321
	comic_g05_06_tilt_shoulder = comicCutscene("g05/g05_06_tilt_shoulder"), -- 322
	comic_g05_07_zhoushu_reveal = comicCutscene("g05/g05_07_zhoushu_reveal"), -- 323
	comic_g05_08_zhoushu_warm = comicCutscene("g05/g05_08_zhoushu_warm"), -- 324
	comic_gate_01_beam = {paths = {"assets/art/cutscenes/gate/gate_01_beam.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 325
	comic_gate_02_dock = {paths = {"assets/art/cutscenes/gate/gate_02_dock.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 326
	comic_gate_03_fog = {paths = {"assets/art/cutscenes/gate/gate_03_fog.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 327
	comic_gate_04_terrace = {paths = {"assets/art/cutscenes/gate/gate_04_terrace.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 328
	comic_f01_01_thumb_cloth = comicCutscene("f01/f01_01_thumb_cloth"), -- 329
	comic_f01_02_needle_pierce = comicCutscene("f01/f01_02_needle_pierce"), -- 330
	comic_f01_03_thread_pull = comicCutscene("f01/f01_03_thread_pull"), -- 331
	comic_f01_04_stitch_smooth = comicCutscene("f01/f01_04_stitch_smooth"), -- 332
	comic_m02_lantern_01_offer = comicCutscene("m02/m02_lantern_01_offer"), -- 333
	comic_m02_lantern_02_grip = comicCutscene("m02/m02_lantern_02_grip"), -- 334
	comic_m02_lantern_03_heft = comicCutscene("m02/m02_lantern_03_heft"), -- 335
	comic_m02_lantern_04_ready = comicCutscene("m02/m02_lantern_04_ready"), -- 336
	comic_m02_echo_01_offer = comicCutscene("m02/m02_echo_01_offer"), -- 337
	comic_m02_echo_02_grip = comicCutscene("m02/m02_echo_02_grip"), -- 338
	comic_m02_echo_03_heft = comicCutscene("m02/m02_echo_03_heft"), -- 339
	comic_m02_echo_04_ready = comicCutscene("m02/m02_echo_04_ready"), -- 340
	comic_tower_f03_porch_01_knock = comicCutscene("tower/f03_porch_01_knock"), -- 341
	comic_tower_f03_porch_02_open = comicCutscene("tower/f03_porch_02_open"), -- 342
	comic_tower_m03_porch_01_knock = comicCutscene("tower/m03_porch_01_knock"), -- 343
	comic_tower_m03_porch_02_open = comicCutscene("tower/m03_porch_02_open"), -- 344
	comic_tower_f03_room_01_cold = comicCutscene("tower/f03_room_01_cold"), -- 345
	comic_tower_f03_room_02_hover = comicCutscene("tower/f03_room_02_hover"), -- 346
	comic_tower_f03_room_03_move_lamp = comicCutscene("tower/f03_room_03_move_lamp"), -- 347
	comic_tower_f03_room_04_lit_bowl = comicCutscene("tower/f03_room_04_lit_bowl"), -- 348
	comic_tower_m03_room_01_warm = comicCutscene("tower/m03_room_01_warm"), -- 349
	comic_tower_m03_room_02_speak = comicCutscene("tower/m03_room_02_speak"), -- 350
	comic_tower_m03_room_03_pouch = comicCutscene("tower/m03_room_03_pouch"), -- 351
	comic_tower_m03_room_04_bowl = comicCutscene("tower/m03_room_04_bowl"), -- 352
	comic_museum_e01_01_well_water = comicCutscene("museum/e01_01_well_water"), -- 353
	comic_museum_e01_02_compass_align = comicCutscene("museum/e01_02_compass_align"), -- 354
	comic_museum_e01_03_match_flash = comicCutscene("museum/e01_03_match_flash"), -- 355
	comic_museum_e01_04_vitrine_emerge = comicCutscene("museum/e01_04_vitrine_emerge"), -- 356
	comic_museum_e02_01_west_window = comicCutscene("museum/e02_01_west_window"), -- 357
	comic_museum_e02_02_lamp_turn = comicCutscene("museum/e02_02_lamp_turn"), -- 358
	comic_museum_e02_03_dawn_well_reflect = comicCutscene("museum/e02_03_dawn_well_reflect"), -- 359
	comic_museum_e02_04_cabinet_cuff_return = comicCutscene("museum/e02_04_cabinet_cuff_return"), -- 360
	fe_carry_idle = feClip("carry_idle", 0, true, 0.5), -- 362
	fe_carry_walk = feClip({"carry_walk_a", "carry_idle", "carry_walk_b", "carry_idle"}, 0, true, {0.5, 0.5, 0.5, 0.5}), -- 363
	fe_carry_reload = feClip("carry_reload", 0, true, 0.48), -- 364
	fe_soldier_kneel_mount = feClip("soldier_kneel_mount", 0, true, 0.5), -- 365
	fe_child_listen_door = feClip("child_listen_door", 0, true, 0.5), -- 366
	fe_soldier_hand_hold = feClip("soldier_hand_hold", 0, true, 0.5), -- 367
	fe_tower_guard_lantern = feClip("tower_guard_lantern", 0, true, 0.5), -- 368
	fe_tower_brush_hand = feClip("tower_brush_hand", 0.08, true, 0.06), -- 369
	fe_reload_hand_tap = feClip("reload_hand_tap", 0.9, true, 0.14), -- 370
	fe_reload_hand_trace = feClip("reload_hand_trace", 0.58, true, 0.92), -- 371
	fe_tower_cuff_rest = feClip("tower_cuff_rest", 0.5, true, 0.05), -- 372
	fe_tower_bowl_solo = feClip("tower_bowl_solo", 0.25, true, 0.5), -- 373
	fe_tower_bowl_hands = feClip("tower_bowl_hands", 0.4, true, 0.5), -- 374
	fe_tower_pouch_note = feClip("tower_pouch_note", 0.42, true, 0.5), -- 375
	fe_tower_lantern_detail = feClip("tower_lantern_detail", 0.14, true, 0.5), -- 376
	fe_basin_flat = feClip("prop_basin_flat", 0, true, 0.5), -- 377
	fe_basin_tilt = feClip("prop_basin_tilt", 0, true, 0.5), -- 378
	fe_well_rim = feClip("prop_well_rim", 0, true, 0.5), -- 379
	fe_outside_arch = feClip("prop_outside_arch", 0, false, 0.5), -- 380
	fe_straw_target = feClip("prop_straw_target", 0, true, 0.5), -- 381
	fe_workbench = feClip("prop_workbench", 0, false, 0.5), -- 382
	fe_bottle_rack = feClip("prop_bottle_rack", 0, true, 0.5), -- 383
	fe_braced_shield = feClip("prop_braced_shield", 0, true, 0.5), -- 384
	fe_weapon_lantern_gun = feClip("weapon_lantern_gun", 0.5, true, 0.5), -- 385
	fe_weapon_echo_gun = feClip("weapon_echo_gun", 0.5, true, 0.5), -- 386
	fe_lamp_bracket = feClip("prop_lamp_bracket", 0, true, 0.5), -- 387
	fe_icon_wood_tally = feClip("icon_wood_tally", 0.5, true, 0.5), -- 388
	fe_icon_bell_tally = feClip("icon_bell_tally", 0.5, true, 0.5), -- 389
	fe_gear_rattan_shield = feClip("gear_rattan_shield", 0.5, true, 0.5), -- 390
	fe_root_arch = feClip("prop_root_arch", 0, false, 0.5), -- 391
	fe_culvert_grate = feClip("prop_culvert_grate", 0, false, 0.5), -- 392
	fe_red_cloth = feClip({"prop_red_cloth_01", "prop_red_cloth_02", "prop_red_cloth_03"}, 0.5, true, 0.9), -- 393
	fe_vfx_muzzle = feClip({"vfx_muzzle_01", "vfx_muzzle_02", "vfx_muzzle_03"}, 0.5, true, 0.12), -- 394
	fe_vfx_hit_spark = feClip({"vfx_hit_spark_01", "vfx_hit_spark_02", "vfx_hit_spark_03"}, 0.5, true, 0.5), -- 395
	fe_vfx_smoke = feClip({"vfx_smoke_01", "vfx_smoke_02", "vfx_smoke_03", "vfx_smoke_04"}, 0.5, true, 0.5), -- 396
	fe_vfx_steam = feClip({"vfx_steam_01", "vfx_steam_02", "vfx_steam_03"}, 0, true, 0.5), -- 397
	fe_vfx_creek_reflect = feClip({"vfx_creek_reflect_01", "vfx_creek_reflect_02", "vfx_creek_reflect_03"}, 0.5, false, 0.5), -- 398
	fe_glyph_bell = feClip("glyph_bell", 0.5, true, 0.5), -- 399
	fe_glyph_lamp = feClip("glyph_lamp", 0.5, true, 0.5), -- 400
	fe_glyph_push = feClip("glyph_push", 0.5, true, 0.5), -- 401
	fe_ground_brick = feClip("ground_brick_patch", 0, false, 0.5), -- 402
	fe_ground_soft = feClip("ground_soft_patch", 0, false, 0.5), -- 403
	fe_pillar_wood = feClip("pillar_wood", 0, false, 0.5), -- 404
	fe_beam_wood = feClip("beam_wood", 0, false, 0.5), -- 405
	fe_road_stone = feClip("road_stone", 0, false, 0.5), -- 406
	fe_fg_table_top = feClip("fg_table_top", 1, false, 0.5), -- 407
	fe_fg_table_leg = feClip("fg_table_leg", 1, false, 0.5), -- 408
	fe_fg_pine_bough = feClip("fg_pine_bough", 1, false, 1) -- 409
} -- 409
local WHITE = Color(255, 255, 255, 255) -- 412
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 418
	local g = _G -- 419
	local ____temp_0 -- 420
	if g.package ~= nil then -- 420
		____temp_0 = g.package.loaded -- 420
	else -- 420
		____temp_0 = nil -- 420
	end -- 420
	local loaded = ____temp_0 -- 420
	if loaded ~= nil then -- 420
		local existing = loaded["watch.fe.dynamic_slots"] -- 422
		if existing ~= nil and type(existing) == "table" then -- 422
			return existing -- 424
		end -- 424
		local created = {} -- 426
		loaded["watch.fe.dynamic_slots"] = created -- 427
		return created -- 428
	end -- 428
	return FALLBACK_DYNAMIC_SLOTS -- 430
end -- 418
FALLBACK_DYNAMIC_SLOTS = {} -- 433
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 436
	sharedDynamicSlots()[key] = cfg -- 437
end -- 436
function ____exports.unregisterDynamicSlot(key) -- 440
	__TS__Delete( -- 441
		sharedDynamicSlots(), -- 441
		key -- 441
	) -- 441
end -- 440
____exports.AssetSlotHost = __TS__Class() -- 444
local AssetSlotHost = ____exports.AssetSlotHost -- 444
AssetSlotHost.name = "AssetSlotHost" -- 444
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 453
	self.sprites = {} -- 446
	self.unavailable = {} -- 447
	self.lastPlacement = {} -- 448
	self.visibleLastFrame = {} -- 449
	self.visibleThisFrame = {} -- 450
	self.localSlots = {} -- 451
	self.container = Node() -- 454
	self.container.order = order -- 455
	self.container:addTo(parent) -- 456
end -- 453
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 460
	self.localSlots[key] = cfg -- 461
end -- 460
function AssetSlotHost.prototype.currentSprite(self, instanceKey, path) -- 465
	return self.visibleThisFrame[(instanceKey .. ":") .. path] -- 466
end -- 465
function AssetSlotHost.prototype.hideLastPlacement(self, instanceKey) -- 470
	local sprite = self.lastPlacement[instanceKey] -- 471
	if sprite ~= nil then -- 471
		sprite.visible = false -- 473
	end -- 473
end -- 470
function AssetSlotHost.prototype.beginFrame(self) -- 477
	self.visibleThisFrame = {} -- 478
end -- 477
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 481
	if options == nil then -- 481
		options = {} -- 485
	end -- 485
	local staticSlots = ____exports.ASSET_SLOTS -- 487
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 488
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 488
		return false -- 490
	end -- 490
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 492
	local path = cfg.paths[frame + 1] -- 493
	local anchorX = type(cfg.anchorX) == "number" and cfg.anchorX or (cfg.anchorX ~= nil and (cfg.anchorX[frame + 1] or 0.5) or 0.5) -- 494
	return self:placeResolvedPath( -- 497
		path, -- 497
		anchorX, -- 497
		cfg.anchorY, -- 497
		cfg.preserveAspect, -- 497
		cfg.smooth == true, -- 497
		instanceKey, -- 497
		x, -- 497
		y, -- 497
		targetW, -- 497
		targetH, -- 497
		options -- 497
	) -- 497
end -- 481
function AssetSlotHost.prototype.tryPlaceRun(self, actor, instanceKey, x, y, targetW, targetH, cycles, options, effort) -- 502
	if options == nil then -- 502
		options = {} -- 507
	end -- 507
	if effort == nil then -- 507
		effort = 1 -- 508
	end -- 508
	if effort < 1 and self:tryPlaceRunTransition( -- 508
		actor, -- 510
		instanceKey, -- 510
		x, -- 510
		y, -- 510
		targetW, -- 510
		targetH, -- 510
		cycles, -- 510
		effort, -- 510
		options -- 510
	) then -- 510
		return true -- 511
	end -- 511
	local frame = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_FRAME_COUNT) -- 513
	return self:tryPlaceMotionFrame( -- 514
		RUN_ATLASES[actor], -- 514
		frame, -- 514
		instanceKey, -- 514
		x, -- 514
		y, -- 514
		targetW, -- 514
		targetH, -- 514
		options -- 514
	) -- 514
end -- 502
function AssetSlotHost.prototype.tryPlaceRunTransition(self, actor, instanceKey, x, y, targetW, targetH, cycles, effort, options) -- 518
	if options == nil then -- 518
		options = {} -- 523
	end -- 523
	local phase = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_TRANSITION_PHASES + 0.5) % ____exports.RUN_TRANSITION_PHASES -- 525
	local level = math.max( -- 526
		0, -- 526
		math.min( -- 526
			____exports.RUN_TRANSITION_LEVELS - 1, -- 526
			math.floor(effort * (____exports.RUN_TRANSITION_LEVELS + 1) + 0.5) - 1 -- 526
		) -- 526
	) -- 526
	return self:tryPlaceMotionFrame( -- 527
		RUN_TRANSITIONS[actor], -- 527
		level * ____exports.RUN_TRANSITION_PHASES + phase, -- 527
		instanceKey, -- 528
		x, -- 528
		y, -- 528
		targetW, -- 528
		targetH, -- 528
		options -- 528
	) -- 528
end -- 518
function AssetSlotHost.prototype.tryPlaceSlide(self, instanceKey, x, y, targetW, targetH, progress, options) -- 531
	if options == nil then -- 531
		options = {} -- 535
	end -- 535
	local frame = math.max( -- 537
		0, -- 537
		math.min( -- 537
			____exports.SLIDE_FRAME_COUNT - 1, -- 537
			math.floor(progress * ____exports.SLIDE_FRAME_COUNT) -- 537
		) -- 537
	) -- 537
	return self:tryPlaceMotionFrame( -- 538
		SLIDE_ATLAS, -- 538
		frame, -- 538
		instanceKey, -- 538
		x, -- 538
		y, -- 538
		targetW, -- 538
		targetH, -- 538
		options -- 538
	) -- 538
end -- 531
function AssetSlotHost.prototype.tryPlaceMotionFrame(self, atlas, frame, instanceKey, x, y, targetW, targetH, options) -- 541
	if targetW <= 0 or targetH <= 0 then -- 541
		return false -- 549
	end -- 549
	local ____atlas_1 = atlas -- 551
	local path = ____atlas_1.path -- 551
	local width = ____atlas_1.width -- 551
	local height = ____atlas_1.height -- 551
	local columns = ____atlas_1.columns -- 551
	local col = frame % columns -- 552
	local row = math.floor(frame / columns) -- 553
	local rect = Rect(col * (width + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, row * (height + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, width, height) -- 554
	return self:placeResolvedPath( -- 556
		path, -- 556
		0.5, -- 556
		0, -- 556
		true, -- 556
		false, -- 556
		instanceKey, -- 556
		x, -- 556
		y, -- 556
		targetW, -- 556
		targetH, -- 556
		options, -- 556
		rect -- 556
	) -- 556
end -- 541
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 560
	if options == nil then -- 560
		options = {} -- 564
	end -- 564
	if path == "" or targetW <= 0 or targetH <= 0 then -- 564
		return false -- 567
	end -- 567
	local ____self_placeResolvedPath_4 = self.placeResolvedPath -- 569
	local ____array_3 = __TS__SparseArrayNew(path, options.anchorX or 0.5, options.anchorY or 0.5) -- 569
	local ____options_preserveAspect_2 = options.preserveAspect -- 573
	if ____options_preserveAspect_2 == nil then -- 573
		____options_preserveAspect_2 = false -- 573
	end -- 573
	__TS__SparseArrayPush( -- 573
		____array_3, -- 573
		____options_preserveAspect_2, -- 573
		options.smooth == true, -- 574
		instanceKey, -- 575
		x, -- 576
		y, -- 577
		targetW, -- 578
		targetH, -- 579
		options -- 580
	) -- 580
	return ____self_placeResolvedPath_4( -- 569
		self, -- 569
		__TS__SparseArraySpread(____array_3) -- 569
	) -- 569
end -- 560
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorX, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options, textureRect) -- 584
	local key = (instanceKey .. ":") .. path -- 595
	local sprite = self.sprites[key] -- 596
	if sprite == nil then -- 596
		if self.unavailable[path] then -- 596
			return false -- 599
		end -- 599
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 601
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 602
		local ____Content_exist_result_5 -- 603
		if Content:exist(file) then -- 603
			____Content_exist_result_5 = Sprite(path) -- 603
		else -- 603
			____Content_exist_result_5 = nil -- 603
		end -- 603
		local loaded = ____Content_exist_result_5 -- 603
		if loaded == nil then -- 603
			self.unavailable[path] = true -- 605
			return false -- 606
		end -- 606
		if textureRect ~= nil then -- 606
			loaded.size = Size(textureRect.width, textureRect.height) -- 610
		end -- 610
		loaded.filter = smooth and "Anisotropic" or "Point" -- 613
		loaded:addTo(self.container) -- 614
		self.sprites[key] = loaded -- 615
		sprite = loaded -- 616
	end -- 616
	if textureRect ~= nil then -- 616
		sprite.textureRect = textureRect -- 620
	end -- 620
	local scaleY = targetH / math.max(1, textureRect and textureRect.height or sprite.height) -- 622
	local scaleX = preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 623
	sprite.anchor = Vec2(anchorX, anchorY) -- 624
	sprite.position = textureRect == nil and Vec2( -- 625
		math.floor(x + 0.5), -- 625
		math.floor(y + 0.5) -- 625
	) or Vec2(x, y) -- 625
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 626
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 627
	sprite.angle = options.angle or 0 -- 628
	sprite.order = options.layer or 0 -- 629
	local col = options.color or WHITE -- 630
	sprite.color = col -- 631
	local baseA = col.a / 255 -- 632
	local op = options.opacity or 1 -- 633
	sprite.opacity = math.max( -- 634
		0, -- 634
		math.min(1, baseA * op) -- 634
	) -- 634
	sprite.visible = true -- 635
	self.visibleThisFrame[key] = sprite -- 636
	self.lastPlacement[instanceKey] = sprite -- 637
	return true -- 638
end -- 584
function AssetSlotHost.prototype.endFrame(self) -- 641
	for key in pairs(self.visibleLastFrame) do -- 642
		if self.visibleThisFrame[key] == nil then -- 642
			self.visibleLastFrame[key].visible = false -- 644
		end -- 644
	end -- 644
	self.visibleLastFrame = self.visibleThisFrame -- 647
end -- 641
return ____exports -- 641