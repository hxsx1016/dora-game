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
local function backdrop(name, smooth) -- 102
	if smooth == nil then -- 102
		smooth = false -- 102
	end -- 102
	return smooth and ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false, smooth = true}) or ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false}) -- 103
end -- 102
local function clip(names, anchorY, preserveAspect, anchorX) -- 108
	if anchorY == nil then -- 108
		anchorY = 0 -- 110
	end -- 110
	if preserveAspect == nil then -- 110
		preserveAspect = false -- 111
	end -- 111
	local frames = type(names) == "string" and ({names}) or names -- 114
	return { -- 115
		paths = __TS__ArrayMap( -- 115
			frames, -- 115
			function(____, name) return "assets/art/sprites.clip|" .. name end -- 115
		), -- 115
		anchorX = anchorX, -- 115
		anchorY = anchorY, -- 115
		preserveAspect = preserveAspect -- 115
	} -- 115
end -- 108
local function inkClip(name, preserveAspect) -- 118
	if preserveAspect == nil then -- 118
		preserveAspect = false -- 118
	end -- 118
	return {paths = {"assets/art/ui_ink.clip|" .. name}, anchorY = 0.5, preserveAspect = preserveAspect, smooth = true} -- 119
end -- 118
local function actor(names, anchorX) -- 122
	return clip(names, 0, true, anchorX) -- 123
end -- 122
local function slide(name) -- 126
	return {paths = {("assets/art/slides/" .. name) .. ".png"}, anchorY = 0.5, preserveAspect = false} -- 127
end -- 126
local function comicCutscene(rel) -- 130
	return {paths = {("assets/art/cutscenes/" .. rel) .. ".png"}, anchorY = 0.5, preserveAspect = false, smooth = true} -- 131
end -- 130
local function feClip(names, anchorY, preserveAspect, anchorX) -- 134
	if anchorY == nil then -- 134
		anchorY = 0.5 -- 136
	end -- 136
	if preserveAspect == nil then -- 136
		preserveAspect = true -- 137
	end -- 137
	local frames = type(names) == "string" and ({names}) or names -- 140
	return { -- 141
		paths = __TS__ArrayMap( -- 141
			frames, -- 141
			function(____, name) return "assets/art/sprites_fe.clip|" .. name end -- 141
		), -- 141
		anchorX = anchorX, -- 141
		anchorY = anchorY, -- 141
		preserveAspect = preserveAspect -- 141
	} -- 141
end -- 134
local function character(names) -- 144
	local frames = type(names) == "string" and ({names}) or names -- 145
	return { -- 146
		paths = __TS__ArrayMap( -- 146
			frames, -- 146
			function(____, name) return "assets/art/actors-hd.clip|" .. name end -- 146
		), -- 146
		anchorY = 0, -- 146
		preserveAspect = true -- 146
	} -- 146
end -- 144
____exports.RUN_FRAME_COUNT = 160 -- 149
____exports.RUN_TRANSITION_PHASES = 8 -- 150
____exports.RUN_TRANSITION_LEVELS = 12 -- 151
____exports.SLIDE_FRAME_COUNT = 64 -- 152
local ATLAS_GUTTER = 2 -- 153
local RUN_ATLASES = {soldier = {path = "assets/art/zhoushu-run.png", width = 180, height = 200, columns = 10}, child = {path = "assets/art/xiaoman-run.png", width = 144, height = 164, columns = 10}} -- 162
local RUN_TRANSITIONS = { -- 166
	soldier = __TS__ObjectAssign({}, RUN_ATLASES.soldier, {path = "assets/art/zhoushu-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}), -- 167
	child = __TS__ObjectAssign({}, RUN_ATLASES.child, {path = "assets/art/xiaoman-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}) -- 168
} -- 168
local SLIDE_ATLAS = {path = "assets/art/zhoushu-slide.png", width = 300, height = 198, columns = 8} -- 170
____exports.ASSET_SLOTS = { -- 174
	bgFar_prologue = backdrop("prologue"), -- 175
	bgFar_street = backdrop("street"), -- 176
	bgFar_checkpoint = backdrop("checkpoint"), -- 177
	bgFar_gate = backdrop("gate"), -- 178
	bgFar_outside = backdrop("outside"), -- 179
	bgFar_village = backdrop("village"), -- 180
	bgFar_forest = backdrop("forest"), -- 181
	bgFar_tower = backdrop("tower"), -- 182
	bgFar_crossroad_drygoods = backdrop("bg_crossroad_drygoods"), -- 183
	bgFar_archway_yard = backdrop("bg_archway_yard"), -- 184
	bgFar_granary = backdrop("bg_granary"), -- 185
	bgFar_escort_ridge = backdrop("bg_escort_ridge"), -- 186
	bgFar_museum = backdrop("bg_museum_hall", true), -- 187
	title_backdrop = backdrop("title"), -- 188
	soldier_idle = character("soldier_idle"), -- 189
	soldier_run = character({"soldier_run", "soldier_step"}), -- 190
	soldier_roll = character("soldier_roll"), -- 191
	soldier_slide = character({"soldier_slide_0", "soldier_slide_1", "soldier_slide_2", "soldier_slide_3"}), -- 192
	soldier_cover = character("soldier_cover"), -- 193
	soldier_push = character({"soldier_push", "soldier_push_step"}), -- 194
	soldier_hold = character("soldier_hold"), -- 195
	soldier_offer = character("soldier_offer"), -- 196
	soldier_knock = character({"soldier_cover", "soldier_knock"}), -- 197
	soldier_hit = character("soldier_hit"), -- 198
	soldier_fire = character("soldier_fire"), -- 199
	soldier_fire_move = character({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}), -- 200
	child_idle = character("child_idle"), -- 201
	child_run = character({"child_run", "child_step"}), -- 202
	child_crouch = character({"child_crouch", "child_crouch_step"}), -- 203
	child_fear = character("child_fear"), -- 204
	child_peek = character("child_peek"), -- 205
	child_pull = character({"child_pull", "child_pull_step"}), -- 206
	child_aim = character("child_aim"), -- 207
	child_throw = character("child_throw"), -- 208
	child_knock = character("child_knock"), -- 209
	child_offer = character("child_offer"), -- 210
	enemy_idle = actor("enemy_idle", 0.5), -- 211
	enemy_aim = actor("enemy_aim", 0.51), -- 212
	enemy_down = actor("enemy_down"), -- 213
	enemy_hit = actor("enemy_hit", 0.48), -- 214
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}, {0.52, 0.52, 0.48, 0.52}), -- 215
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}, {0.5, 0.5, 0.54, 0.58}), -- 216
	prop_cart = clip("cart", 0, false, 0.44), -- 217
	prop_bottle = clip("bottle", 0.5, true), -- 218
	prop_tower_door = clip("door"), -- 219
	prop_lantern = clip("lantern", 0.5, true), -- 220
	prop_table = clip("table"), -- 221
	prop_compass = clip("compass", 0.5, true), -- 222
	prop_winch = clip("winch", 0.5, true), -- 223
	wall = clip("wall"), -- 224
	cover_wood = clip("cover_wood"), -- 225
	cover_stone = clip("cover_stone"), -- 226
	fence = clip("fence"), -- 227
	slab = clip("slab"), -- 228
	eaves = clip("eaves"), -- 229
	pine = clip("pine"), -- 230
	grass = clip("grass"), -- 231
	grass_low = clip("grass_low"), -- 232
	stone_chips = clip("stone_chips", 0.5, true), -- 233
	ui_corner = clip("ui_corner"), -- 234
	ui_corner_c = clip("ui_corner", 0.5, false), -- 235
	ui_paper = clip("paper", 0.5), -- 236
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 237
	ink_mist_curve = inkClip("ink_mist_curve"), -- 238
	ink_veil_strip = inkClip("ink_veil_strip"), -- 239
	ink_hairline = inkClip("ink_hairline"), -- 240
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 241
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 242
	ink_frame_mask = inkClip("ink_frame_mask"), -- 243
	ink_vstream = inkClip("ink_vstream"), -- 244
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 245
	ink_corner_fine = inkClip("ink_corner_fine"), -- 246
	ink_seal_slender = inkClip("ink_seal_slender"), -- 247
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 248
	ink_enso_fine = inkClip("ink_enso_fine"), -- 249
	ink_petal_mist = inkClip("ink_petal_mist"), -- 250
	ink_song_paper = inkClip("ink_song_paper"), -- 251
	brand_game_logo_h = {paths = {"assets/art/brand/game_logo_h.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 252
	brand_game_logo_v = {paths = {"assets/art/brand/game_logo_v.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 253
	brand_team_logo = {paths = {"assets/art/brand/team_logo_dark.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 254
	brand_team_badge = {paths = {"assets/art/brand/team_badge.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 255
	slide_p01_01 = slide("p01_01_curtain"), -- 257
	slide_p01_02 = slide("p01_02_hand"), -- 258
	slide_p01_03 = slide("p01_03_door"), -- 259
	slide_p02_01 = slide("p02_01_shadows"), -- 260
	slide_p02_02 = slide("p02_02_cut"), -- 261
	slide_p02_03 = slide("p02_03_bowl_roll"), -- 262
	slide_p02_04 = slide("p02_04_bowl_stop"), -- 263
	slide_p02_05 = slide("p02_05_cabinet"), -- 264
	slide_cuff_p03_01 = slide("cuff_p03_01"), -- 265
	slide_cuff_p03_02 = slide("cuff_p03_02"), -- 266
	slide_cuff_p03_03 = slide("cuff_p03_03"), -- 267
	slide_cuff_p03_04 = slide("cuff_p03_04"), -- 268
	slide_cuff_p05_01 = slide("cuff_p05_01"), -- 269
	slide_cuff_p05_02 = slide("cuff_p05_02"), -- 270
	slide_cuff_p05_03 = slide("cuff_p05_03"), -- 271
	slide_cuff_p05_04 = slide("cuff_p05_04"), -- 272
	slide_cuff_g05_01 = slide("cuff_g05_01"), -- 273
	slide_cuff_g05_02 = slide("cuff_g05_02"), -- 274
	slide_cuff_g05_03 = slide("cuff_g05_03"), -- 275
	slide_cuff_g05_04 = slide("cuff_g05_04"), -- 276
	slide_gate_01 = {paths = {"assets/art/slides/gate_stage_01.png"}, anchorY = 0, preserveAspect = false}, -- 277
	slide_gate_02 = {paths = {"assets/art/slides/gate_stage_02.png"}, anchorY = 0, preserveAspect = false}, -- 278
	slide_gate_03 = {paths = {"assets/art/slides/gate_stage_03.png"}, anchorY = 0, preserveAspect = false}, -- 279
	slide_gate_04 = {paths = {"assets/art/slides/gate_stage_04.png"}, anchorY = 0, preserveAspect = false}, -- 280
	slide_tower_porch_f03_closed = slide("tower_porch_f03_closed"), -- 281
	slide_tower_porch_f03_open = slide("tower_porch_f03_open"), -- 282
	slide_tower_porch_m03_closed = slide("tower_porch_m03_closed"), -- 283
	slide_tower_porch_m03_open = slide("tower_porch_m03_open"), -- 284
	slide_tower_room_f03_cold = slide("tower_room_f03_cold"), -- 285
	slide_tower_room_f03_lit = slide("tower_room_f03_lit"), -- 286
	slide_tower_room_m03_warm = slide("tower_room_m03_warm"), -- 287
	slide_tower_interior_live = {paths = {"assets/art/slides/tower_interior_live.png"}, anchorY = 0, preserveAspect = false}, -- 288
	slide_e01_well = slide("e01_01_well"), -- 289
	slide_e01_compass = slide("e01_02_compass"), -- 290
	slide_e01_vitrine = slide("e01_03_vitrine"), -- 291
	slide_e02_museum_hall = {paths = {"assets/art/slides/e02_museum_hall.png"}, anchorY = 0, preserveAspect = false}, -- 292
	slide_e02_window_dawn = slide("e02_window_dawn"), -- 293
	slide_e02_return_cabinet = slide("e02_return_cabinet"), -- 294
	slide_f01_sewing = slide("f01_sewing_memory"), -- 295
	slide_m02_lantern_gun = slide("m02_handover_lantern"), -- 296
	slide_m02_echo_gun = slide("m02_handover_echo"), -- 297
	comic_p01_01_curtain_dark = comicCutscene("p01/p01_01_curtain_dark"), -- 299
	comic_p01_02_curtain_glow = comicCutscene("p01/p01_02_curtain_glow"), -- 300
	comic_p01_03_hand_bedrail = comicCutscene("p01/p01_03_hand_bedrail"), -- 301
	comic_p01_04_look_door = comicCutscene("p01/p01_04_look_door"), -- 302
	comic_p02_01_shadows = comicCutscene("p02/p02_01_shadows"), -- 303
	comic_p02_02a_door_intrude = comicCutscene("p02/p02_02a_door_intrude"), -- 304
	comic_p02_03_impact_cut = comicCutscene("p02/p02_03_impact_cut"), -- 305
	comic_p02_04_shadows_fall = comicCutscene("p02/p02_04_shadows_fall"), -- 306
	comic_p02_05_bowl_roll1 = comicCutscene("p02/p02_05_bowl_roll1"), -- 307
	comic_p02_06_bowl_roll2 = comicCutscene("p02/p02_06_bowl_roll2"), -- 308
	comic_p02_07_bowl_smash = comicCutscene("p02/p02_07_bowl_smash"), -- 309
	comic_p02_08a_cabinet_slit = comicCutscene("p02/p02_08a_cabinet_slit"), -- 310
	comic_p02_08m_cabinet_narrowing = comicCutscene("p02/p02_08m_cabinet_narrowing"), -- 311
	comic_p02_08b_cabinet_shut = comicCutscene("p02/p02_08b_cabinet_shut"), -- 312
	comic_p03_01_two_fingers = comicCutscene("p03/p03_01_two_fingers"), -- 313
	comic_p03_02_cuff_enter = comicCutscene("p03/p03_02_cuff_enter"), -- 314
	comic_p03_03_cuff_wipe = comicCutscene("p03/p03_03_cuff_wipe"), -- 315
	comic_p03_04_hand_meet = comicCutscene("p03/p03_04_hand_meet"), -- 316
	comic_p03_f01 = comicCutscene("p03/p03_f01"), -- 317
	comic_p03_f02 = comicCutscene("p03/p03_f02"), -- 318
	comic_p03_f03 = comicCutscene("p03/p03_f03"), -- 319
	comic_p03_f04 = comicCutscene("p03/p03_f04"), -- 320
	comic_p03_f05 = comicCutscene("p03/p03_f05"), -- 321
	comic_p03_f06 = comicCutscene("p03/p03_f06"), -- 322
	comic_p03_f07 = comicCutscene("p03/p03_f07"), -- 323
	comic_p03_f08 = comicCutscene("p03/p03_f08"), -- 324
	comic_p03_f09 = comicCutscene("p03/p03_f09"), -- 325
	comic_p03_f10 = comicCutscene("p03/p03_f10"), -- 326
	comic_p03_f11 = comicCutscene("p03/p03_f11"), -- 327
	comic_p03_f12 = comicCutscene("p03/p03_f12"), -- 328
	comic_p03_f13 = comicCutscene("p03/p03_f13"), -- 329
	comic_p03_f14 = comicCutscene("p03/p03_f14"), -- 330
	comic_p03_f15 = comicCutscene("p03/p03_f15"), -- 331
	comic_p03_f16 = comicCutscene("p03/p03_f16"), -- 332
	comic_p03_f17 = comicCutscene("p03/p03_f17"), -- 333
	comic_p03_f18 = comicCutscene("p03/p03_f18"), -- 334
	comic_p03_f19 = comicCutscene("p03/p03_f19"), -- 335
	comic_p03_f20 = comicCutscene("p03/p03_f20"), -- 336
	comic_p03_f21 = comicCutscene("p03/p03_f21"), -- 337
	comic_p03_f22 = comicCutscene("p03/p03_f22"), -- 338
	comic_p03_f23 = comicCutscene("p03/p03_f23"), -- 339
	comic_p03_f24 = comicCutscene("p03/p03_f24"), -- 340
	comic_p05_01_clutch_cuff = comicCutscene("p05/p05_01_clutch_cuff"), -- 341
	comic_p05_02_brother_pinch = comicCutscene("p05/p05_02_brother_pinch"), -- 342
	comic_p05_03_sleeve_pull = comicCutscene("p05/p05_03_sleeve_pull"), -- 343
	comic_p05_04_gate_drop = comicCutscene("p05/p05_04_gate_drop"), -- 344
	comic_p05_05_gate_slam_impact = comicCutscene("p05/p05_05_gate_slam_impact"), -- 345
	comic_p05_06_open_fingers = comicCutscene("p05/p05_06_open_fingers"), -- 346
	comic_g05_01_cuff_peek = comicCutscene("g05/g05_01_cuff_peek"), -- 347
	comic_g05_02_cuff_extend = comicCutscene("g05/g05_02_cuff_extend"), -- 348
	comic_g05_03_hands_meet = comicCutscene("g05/g05_03_hands_meet"), -- 349
	comic_g05_04_hands_clasp = comicCutscene("g05/g05_04_hands_clasp"), -- 350
	comic_g05_05_tilt_arm = comicCutscene("g05/g05_05_tilt_arm"), -- 351
	comic_g05_06_tilt_shoulder = comicCutscene("g05/g05_06_tilt_shoulder"), -- 352
	comic_g05_07_zhoushu_reveal = comicCutscene("g05/g05_07_zhoushu_reveal"), -- 353
	comic_g05_08_zhoushu_warm = comicCutscene("g05/g05_08_zhoushu_warm"), -- 354
	comic_gate_01_beam = {paths = {"assets/art/cutscenes/gate/gate_01_beam.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 355
	comic_gate_02_dock = {paths = {"assets/art/cutscenes/gate/gate_02_dock.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 356
	comic_gate_03_fog = {paths = {"assets/art/cutscenes/gate/gate_03_fog.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 357
	comic_gate_04_terrace = {paths = {"assets/art/cutscenes/gate/gate_04_terrace.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 358
	comic_f01_01_thumb_cloth = comicCutscene("f01/f01_01_thumb_cloth"), -- 359
	comic_f01_02_needle_pierce = comicCutscene("f01/f01_02_needle_pierce"), -- 360
	comic_f01_03_thread_pull = comicCutscene("f01/f01_03_thread_pull"), -- 361
	comic_f01_04_stitch_smooth = comicCutscene("f01/f01_04_stitch_smooth"), -- 362
	comic_m02_lantern_01_offer = comicCutscene("m02/m02_lantern_01_offer"), -- 363
	comic_m02_lantern_02_grip = comicCutscene("m02/m02_lantern_02_grip"), -- 364
	comic_m02_lantern_03_heft = comicCutscene("m02/m02_lantern_03_heft"), -- 365
	comic_m02_lantern_04_ready = comicCutscene("m02/m02_lantern_04_ready"), -- 366
	comic_m02_echo_01_offer = comicCutscene("m02/m02_echo_01_offer"), -- 367
	comic_m02_echo_02_grip = comicCutscene("m02/m02_echo_02_grip"), -- 368
	comic_m02_echo_03_heft = comicCutscene("m02/m02_echo_03_heft"), -- 369
	comic_m02_echo_04_ready = comicCutscene("m02/m02_echo_04_ready"), -- 370
	comic_tower_f03_porch_01_knock = comicCutscene("tower/f03_porch_01_knock"), -- 371
	comic_tower_f03_porch_02_open = comicCutscene("tower/f03_porch_02_open"), -- 372
	comic_tower_m03_porch_01_knock = comicCutscene("tower/m03_porch_01_knock"), -- 373
	comic_tower_m03_porch_02_open = comicCutscene("tower/m03_porch_02_open"), -- 374
	comic_tower_f03_room_01_cold = comicCutscene("tower/f03_room_01_cold"), -- 375
	comic_tower_f03_room_02_hover = comicCutscene("tower/f03_room_02_hover"), -- 376
	comic_tower_f03_room_03_move_lamp = comicCutscene("tower/f03_room_03_move_lamp"), -- 377
	comic_tower_f03_room_04_lit_bowl = comicCutscene("tower/f03_room_04_lit_bowl"), -- 378
	comic_tower_m03_room_01_warm = comicCutscene("tower/m03_room_01_warm"), -- 379
	comic_tower_m03_room_02_speak = comicCutscene("tower/m03_room_02_speak"), -- 380
	comic_tower_m03_room_03_pouch = comicCutscene("tower/m03_room_03_pouch"), -- 381
	comic_tower_m03_room_04_bowl = comicCutscene("tower/m03_room_04_bowl"), -- 382
	comic_museum_e01_01_well_water = comicCutscene("museum/e01_01_well_water"), -- 383
	comic_museum_e01_02_compass_align = comicCutscene("museum/e01_02_compass_align"), -- 384
	comic_museum_e01_03_match_flash = comicCutscene("museum/e01_03_match_flash"), -- 385
	comic_museum_e01_04_vitrine_emerge = comicCutscene("museum/e01_04_vitrine_emerge"), -- 386
	comic_museum_e02_01_west_window = comicCutscene("museum/e02_01_west_window"), -- 387
	comic_museum_e02_02_lamp_turn = comicCutscene("museum/e02_02_lamp_turn"), -- 388
	comic_museum_e02_03_dawn_well_reflect = comicCutscene("museum/e02_03_dawn_well_reflect"), -- 389
	comic_museum_e02_04_cabinet_cuff_return = comicCutscene("museum/e02_04_cabinet_cuff_return"), -- 390
	fe_carry_idle = feClip("carry_idle", 0, true, 0.5), -- 392
	fe_carry_walk = feClip({"carry_walk_a", "carry_idle", "carry_walk_b", "carry_idle"}, 0, true, {0.5, 0.5, 0.5, 0.5}), -- 393
	fe_carry_reload = feClip("carry_reload", 0, true, 0.48), -- 394
	fe_soldier_kneel_mount = feClip("soldier_kneel_mount", 0, true, 0.5), -- 395
	fe_child_listen_door = feClip("child_listen_door", 0, true, 0.5), -- 396
	fe_soldier_hand_hold = feClip("soldier_hand_hold", 0, true, 0.5), -- 397
	fe_tower_guard_lantern = feClip("tower_guard_lantern", 0, true, 0.5), -- 398
	fe_tower_brush_hand = feClip("tower_brush_hand", 0.08, true, 0.06), -- 399
	fe_reload_hand_tap = feClip("reload_hand_tap", 0.9, true, 0.14), -- 400
	fe_reload_hand_trace = feClip("reload_hand_trace", 0.58, true, 0.92), -- 401
	fe_tower_cuff_rest = feClip("tower_cuff_rest", 0.5, true, 0.05), -- 402
	fe_tower_bowl_solo = feClip("tower_bowl_solo", 0.25, true, 0.5), -- 403
	fe_tower_bowl_hands = feClip("tower_bowl_hands", 0.4, true, 0.5), -- 404
	fe_tower_pouch_note = feClip("tower_pouch_note", 0.42, true, 0.5), -- 405
	fe_tower_lantern_detail = feClip("tower_lantern_detail", 0.14, true, 0.5), -- 406
	fe_basin_flat = feClip("prop_basin_flat", 0, true, 0.5), -- 407
	fe_basin_tilt = feClip("prop_basin_tilt", 0, true, 0.5), -- 408
	fe_well_rim = feClip("prop_well_rim", 0, true, 0.5), -- 409
	fe_outside_arch = feClip("prop_outside_arch", 0, false, 0.5), -- 410
	fe_straw_target = feClip("prop_straw_target", 0, true, 0.5), -- 411
	fe_workbench = feClip("prop_workbench", 0, false, 0.5), -- 412
	fe_bottle_rack = feClip("prop_bottle_rack", 0, true, 0.5), -- 413
	fe_braced_shield = feClip("prop_braced_shield", 0, true, 0.5), -- 414
	fe_weapon_lantern_gun = feClip("weapon_lantern_gun", 0.5, true, 0.5), -- 415
	fe_weapon_echo_gun = feClip("weapon_echo_gun", 0.5, true, 0.5), -- 416
	fe_lamp_bracket = feClip("prop_lamp_bracket", 0, true, 0.5), -- 417
	fe_icon_wood_tally = feClip("icon_wood_tally", 0.5, true, 0.5), -- 418
	fe_icon_bell_tally = feClip("icon_bell_tally", 0.5, true, 0.5), -- 419
	fe_gear_rattan_shield = feClip("gear_rattan_shield", 0.5, true, 0.5), -- 420
	fe_root_arch = feClip("prop_root_arch", 0, false, 0.5), -- 421
	fe_culvert_grate = feClip("prop_culvert_grate", 0, false, 0.5), -- 422
	fe_red_cloth = feClip({"prop_red_cloth_01", "prop_red_cloth_02", "prop_red_cloth_03"}, 0.5, true, 0.9), -- 423
	fe_vfx_muzzle = feClip({"vfx_muzzle_01", "vfx_muzzle_02", "vfx_muzzle_03"}, 0.5, true, 0.12), -- 424
	fe_vfx_hit_spark = feClip({"vfx_hit_spark_01", "vfx_hit_spark_02", "vfx_hit_spark_03"}, 0.5, true, 0.5), -- 425
	fe_vfx_smoke = feClip({"vfx_smoke_01", "vfx_smoke_02", "vfx_smoke_03", "vfx_smoke_04"}, 0.5, true, 0.5), -- 426
	fe_vfx_steam = feClip({"vfx_steam_01", "vfx_steam_02", "vfx_steam_03"}, 0, true, 0.5), -- 427
	fe_vfx_creek_reflect = feClip({"vfx_creek_reflect_01", "vfx_creek_reflect_02", "vfx_creek_reflect_03"}, 0.5, false, 0.5), -- 428
	fe_glyph_bell = feClip("glyph_bell", 0.5, true, 0.5), -- 429
	fe_glyph_lamp = feClip("glyph_lamp", 0.5, true, 0.5), -- 430
	fe_glyph_push = feClip("glyph_push", 0.5, true, 0.5), -- 431
	fe_ground_brick = feClip("ground_brick_patch", 0, false, 0.5), -- 432
	fe_ground_soft = feClip("ground_soft_patch", 0, false, 0.5), -- 433
	fe_pillar_wood = feClip("pillar_wood", 0, false, 0.5), -- 434
	fe_beam_wood = feClip("beam_wood", 0, false, 0.5), -- 435
	fe_road_stone = feClip("road_stone", 0, false, 0.5), -- 436
	fe_fg_table_top = feClip("fg_table_top", 1, false, 0.5), -- 437
	fe_fg_table_leg = feClip("fg_table_leg", 1, false, 0.5), -- 438
	fe_fg_pine_bough = feClip("fg_pine_bough", 1, false, 1) -- 439
} -- 439
local WHITE = Color(255, 255, 255, 255) -- 442
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 448
	local g = _G -- 449
	local ____temp_0 -- 450
	if g.package ~= nil then -- 450
		____temp_0 = g.package.loaded -- 450
	else -- 450
		____temp_0 = nil -- 450
	end -- 450
	local loaded = ____temp_0 -- 450
	if loaded ~= nil then -- 450
		local existing = loaded["watch.fe.dynamic_slots"] -- 452
		if existing ~= nil and type(existing) == "table" then -- 452
			return existing -- 454
		end -- 454
		local created = {} -- 456
		loaded["watch.fe.dynamic_slots"] = created -- 457
		return created -- 458
	end -- 458
	return FALLBACK_DYNAMIC_SLOTS -- 460
end -- 448
FALLBACK_DYNAMIC_SLOTS = {} -- 463
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 466
	sharedDynamicSlots()[key] = cfg -- 467
end -- 466
function ____exports.unregisterDynamicSlot(key) -- 470
	__TS__Delete( -- 471
		sharedDynamicSlots(), -- 471
		key -- 471
	) -- 471
end -- 470
____exports.AssetSlotHost = __TS__Class() -- 474
local AssetSlotHost = ____exports.AssetSlotHost -- 474
AssetSlotHost.name = "AssetSlotHost" -- 474
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 483
	self.sprites = {} -- 476
	self.unavailable = {} -- 477
	self.lastPlacement = {} -- 478
	self.visibleLastFrame = {} -- 479
	self.visibleThisFrame = {} -- 480
	self.localSlots = {} -- 481
	self.container = Node() -- 484
	self.container.order = order -- 485
	self.container:addTo(parent) -- 486
end -- 483
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 490
	self.localSlots[key] = cfg -- 491
end -- 490
function AssetSlotHost.prototype.currentSprite(self, instanceKey, path) -- 495
	return self.visibleThisFrame[(instanceKey .. ":") .. path] -- 496
end -- 495
function AssetSlotHost.prototype.hideLastPlacement(self, instanceKey) -- 500
	local sprite = self.lastPlacement[instanceKey] -- 501
	if sprite ~= nil then -- 501
		sprite.visible = false -- 503
	end -- 503
end -- 500
function AssetSlotHost.prototype.beginFrame(self) -- 507
	self.visibleThisFrame = {} -- 508
end -- 507
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 511
	if options == nil then -- 511
		options = {} -- 515
	end -- 515
	local staticSlots = ____exports.ASSET_SLOTS -- 517
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 518
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 518
		return false -- 520
	end -- 520
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 522
	local path = cfg.paths[frame + 1] -- 523
	local anchorX = type(cfg.anchorX) == "number" and cfg.anchorX or (cfg.anchorX ~= nil and (cfg.anchorX[frame + 1] or 0.5) or 0.5) -- 524
	return self:placeResolvedPath( -- 527
		path, -- 527
		anchorX, -- 527
		cfg.anchorY, -- 527
		cfg.preserveAspect, -- 527
		cfg.smooth == true, -- 527
		instanceKey, -- 527
		x, -- 527
		y, -- 527
		targetW, -- 527
		targetH, -- 527
		options -- 527
	) -- 527
end -- 511
function AssetSlotHost.prototype.tryPlaceRun(self, actor, instanceKey, x, y, targetW, targetH, cycles, options, effort) -- 532
	if options == nil then -- 532
		options = {} -- 537
	end -- 537
	if effort == nil then -- 537
		effort = 1 -- 538
	end -- 538
	if effort < 1 and self:tryPlaceRunTransition( -- 538
		actor, -- 540
		instanceKey, -- 540
		x, -- 540
		y, -- 540
		targetW, -- 540
		targetH, -- 540
		cycles, -- 540
		effort, -- 540
		options -- 540
	) then -- 540
		return true -- 541
	end -- 541
	local frame = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_FRAME_COUNT) -- 543
	return self:tryPlaceMotionFrame( -- 544
		RUN_ATLASES[actor], -- 544
		frame, -- 544
		instanceKey, -- 544
		x, -- 544
		y, -- 544
		targetW, -- 544
		targetH, -- 544
		options -- 544
	) -- 544
end -- 532
function AssetSlotHost.prototype.tryPlaceRunTransition(self, actor, instanceKey, x, y, targetW, targetH, cycles, effort, options) -- 548
	if options == nil then -- 548
		options = {} -- 553
	end -- 553
	local phase = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_TRANSITION_PHASES + 0.5) % ____exports.RUN_TRANSITION_PHASES -- 555
	local level = math.max( -- 556
		0, -- 556
		math.min( -- 556
			____exports.RUN_TRANSITION_LEVELS - 1, -- 556
			math.floor(effort * (____exports.RUN_TRANSITION_LEVELS + 1) + 0.5) - 1 -- 556
		) -- 556
	) -- 556
	return self:tryPlaceMotionFrame( -- 557
		RUN_TRANSITIONS[actor], -- 557
		level * ____exports.RUN_TRANSITION_PHASES + phase, -- 557
		instanceKey, -- 558
		x, -- 558
		y, -- 558
		targetW, -- 558
		targetH, -- 558
		options -- 558
	) -- 558
end -- 548
function AssetSlotHost.prototype.tryPlaceSlide(self, instanceKey, x, y, targetW, targetH, progress, options) -- 561
	if options == nil then -- 561
		options = {} -- 565
	end -- 565
	local frame = math.max( -- 567
		0, -- 567
		math.min( -- 567
			____exports.SLIDE_FRAME_COUNT - 1, -- 567
			math.floor(progress * ____exports.SLIDE_FRAME_COUNT) -- 567
		) -- 567
	) -- 567
	return self:tryPlaceMotionFrame( -- 568
		SLIDE_ATLAS, -- 568
		frame, -- 568
		instanceKey, -- 568
		x, -- 568
		y, -- 568
		targetW, -- 568
		targetH, -- 568
		options -- 568
	) -- 568
end -- 561
function AssetSlotHost.prototype.tryPlaceMotionFrame(self, atlas, frame, instanceKey, x, y, targetW, targetH, options) -- 571
	if targetW <= 0 or targetH <= 0 then -- 571
		return false -- 579
	end -- 579
	local ____atlas_1 = atlas -- 581
	local path = ____atlas_1.path -- 581
	local width = ____atlas_1.width -- 581
	local height = ____atlas_1.height -- 581
	local columns = ____atlas_1.columns -- 581
	local col = frame % columns -- 582
	local row = math.floor(frame / columns) -- 583
	local rect = Rect(col * (width + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, row * (height + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, width, height) -- 584
	return self:placeResolvedPath( -- 586
		path, -- 586
		0.5, -- 586
		0, -- 586
		true, -- 586
		false, -- 586
		instanceKey, -- 586
		x, -- 586
		y, -- 586
		targetW, -- 586
		targetH, -- 586
		options, -- 586
		rect -- 586
	) -- 586
end -- 571
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 590
	if options == nil then -- 590
		options = {} -- 594
	end -- 594
	if path == "" or targetW <= 0 or targetH <= 0 then -- 594
		return false -- 597
	end -- 597
	local ____self_placeResolvedPath_4 = self.placeResolvedPath -- 599
	local ____array_3 = __TS__SparseArrayNew(path, options.anchorX or 0.5, options.anchorY or 0.5) -- 599
	local ____options_preserveAspect_2 = options.preserveAspect -- 603
	if ____options_preserveAspect_2 == nil then -- 603
		____options_preserveAspect_2 = false -- 603
	end -- 603
	__TS__SparseArrayPush( -- 603
		____array_3, -- 603
		____options_preserveAspect_2, -- 603
		options.smooth == true, -- 604
		instanceKey, -- 605
		x, -- 606
		y, -- 607
		targetW, -- 608
		targetH, -- 609
		options -- 610
	) -- 610
	return ____self_placeResolvedPath_4( -- 599
		self, -- 599
		__TS__SparseArraySpread(____array_3) -- 599
	) -- 599
end -- 590
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorX, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options, textureRect) -- 614
	local key = (instanceKey .. ":") .. path -- 625
	local sprite = self.sprites[key] -- 626
	if sprite == nil then -- 626
		if self.unavailable[path] then -- 626
			return false -- 629
		end -- 629
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 631
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 632
		local ____Content_exist_result_5 -- 633
		if Content:exist(file) then -- 633
			____Content_exist_result_5 = Sprite(path) -- 633
		else -- 633
			____Content_exist_result_5 = nil -- 633
		end -- 633
		local loaded = ____Content_exist_result_5 -- 633
		if loaded == nil then -- 633
			self.unavailable[path] = true -- 635
			return false -- 636
		end -- 636
		if textureRect ~= nil then -- 636
			loaded.size = Size(textureRect.width, textureRect.height) -- 640
		end -- 640
		loaded.filter = smooth and "Anisotropic" or "Point" -- 643
		loaded:addTo(self.container) -- 644
		self.sprites[key] = loaded -- 645
		sprite = loaded -- 646
	end -- 646
	if textureRect ~= nil then -- 646
		sprite.textureRect = textureRect -- 650
	end -- 650
	local scaleY = targetH / math.max(1, textureRect and textureRect.height or sprite.height) -- 652
	local scaleX = preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 653
	sprite.anchor = Vec2(anchorX, anchorY) -- 654
	sprite.position = textureRect == nil and Vec2( -- 655
		math.floor(x + 0.5), -- 655
		math.floor(y + 0.5) -- 655
	) or Vec2(x, y) -- 655
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 656
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 657
	sprite.angle = options.angle or 0 -- 658
	sprite.order = options.layer or 0 -- 659
	local col = options.color or WHITE -- 660
	sprite.color = col -- 661
	local baseA = col.a / 255 -- 662
	local op = options.opacity or 1 -- 663
	sprite.opacity = math.max( -- 664
		0, -- 664
		math.min(1, baseA * op) -- 664
	) -- 664
	sprite.visible = true -- 665
	self.visibleThisFrame[key] = sprite -- 666
	self.lastPlacement[instanceKey] = sprite -- 667
	return true -- 668
end -- 614
function AssetSlotHost.prototype.endFrame(self) -- 671
	for key in pairs(self.visibleLastFrame) do -- 672
		if self.visibleThisFrame[key] == nil then -- 672
			self.visibleLastFrame[key].visible = false -- 674
		end -- 674
	end -- 674
	self.visibleLastFrame = self.visibleThisFrame -- 677
end -- 671
return ____exports -- 671