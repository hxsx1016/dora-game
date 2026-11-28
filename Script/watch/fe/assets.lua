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
local function backdrop(name, smooth) -- 155
	if smooth == nil then -- 155
		smooth = false -- 155
	end -- 155
	return smooth and ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false, smooth = true}) or ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false}) -- 156
end -- 155
local function clip(names, anchorY, preserveAspect, anchorX) -- 161
	if anchorY == nil then -- 161
		anchorY = 0 -- 163
	end -- 163
	if preserveAspect == nil then -- 163
		preserveAspect = false -- 164
	end -- 164
	local frames = type(names) == "string" and ({names}) or names -- 167
	return { -- 168
		paths = __TS__ArrayMap( -- 168
			frames, -- 168
			function(____, name) return "assets/art/sprites.clip|" .. name end -- 168
		), -- 168
		anchorX = anchorX, -- 168
		anchorY = anchorY, -- 168
		preserveAspect = preserveAspect -- 168
	} -- 168
end -- 161
local function inkClip(name, preserveAspect) -- 171
	if preserveAspect == nil then -- 171
		preserveAspect = false -- 171
	end -- 171
	return {paths = {"assets/art/ui_ink.clip|" .. name}, anchorY = 0.5, preserveAspect = preserveAspect, smooth = true} -- 172
end -- 171
local function actor(names, anchorX) -- 175
	return clip(names, 0, true, anchorX) -- 176
end -- 175
local function slide(name) -- 179
	return {paths = {("assets/art/slides/" .. name) .. ".png"}, anchorY = 0.5, preserveAspect = false} -- 180
end -- 179
local function comicCutscene(rel) -- 183
	return {paths = {("assets/art/cutscenes/" .. rel) .. ".png"}, anchorY = 0.5, preserveAspect = false, smooth = true} -- 184
end -- 183
local function feClip(names, anchorY, preserveAspect, anchorX) -- 187
	if anchorY == nil then -- 187
		anchorY = 0.5 -- 189
	end -- 189
	if preserveAspect == nil then -- 189
		preserveAspect = true -- 190
	end -- 190
	local frames = type(names) == "string" and ({names}) or names -- 193
	return { -- 194
		paths = __TS__ArrayMap( -- 194
			frames, -- 194
			function(____, name) return "assets/art/sprites_fe.clip|" .. name end -- 194
		), -- 194
		anchorX = anchorX, -- 194
		anchorY = anchorY, -- 194
		preserveAspect = preserveAspect -- 194
	} -- 194
end -- 187
local function character(names) -- 197
	local frames = type(names) == "string" and ({names}) or names -- 198
	return { -- 199
		paths = __TS__ArrayMap( -- 199
			frames, -- 199
			function(____, name) return "assets/art/actors-hd.clip|" .. name end -- 199
		), -- 199
		anchorY = 0, -- 199
		preserveAspect = true -- 199
	} -- 199
end -- 197
____exports.RUN_FRAME_COUNT = 160 -- 202
____exports.RUN_TRANSITION_PHASES = 8 -- 203
____exports.RUN_TRANSITION_LEVELS = 12 -- 204
____exports.SLIDE_FRAME_COUNT = 64 -- 205
local ATLAS_GUTTER = 2 -- 206
local RUN_ATLASES = {soldier = {path = "assets/art/zhoushu-run.png", width = 180, height = 200, columns = 10}, child = {path = "assets/art/xiaoman-run.png", width = 144, height = 164, columns = 10}} -- 215
local RUN_TRANSITIONS = { -- 219
	soldier = __TS__ObjectAssign({}, RUN_ATLASES.soldier, {path = "assets/art/zhoushu-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}), -- 220
	child = __TS__ObjectAssign({}, RUN_ATLASES.child, {path = "assets/art/xiaoman-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}) -- 221
} -- 221
local SLIDE_ATLAS = {path = "assets/art/zhoushu-slide.png", width = 300, height = 198, columns = 8} -- 223
____exports.ASSET_SLOTS = { -- 227
	bgFar_prologue = backdrop("prologue"), -- 228
	bgFar_street = backdrop("street"), -- 229
	bgFar_checkpoint = backdrop("checkpoint"), -- 230
	bgFar_gate = backdrop("gate"), -- 231
	bgFar_outside = backdrop("outside"), -- 232
	bgFar_village = backdrop("village"), -- 233
	bgFar_forest = backdrop("forest"), -- 234
	bgFar_tower = backdrop("tower"), -- 235
	bgFar_crossroad_drygoods = backdrop("bg_crossroad_drygoods"), -- 236
	bgFar_archway_yard = backdrop("bg_archway_yard"), -- 237
	bgFar_granary = backdrop("bg_granary"), -- 238
	bgFar_escort_ridge = backdrop("bg_escort_ridge"), -- 239
	bgFar_museum = backdrop("bg_museum_hall", true), -- 240
	title_backdrop = backdrop("title"), -- 241
	soldier_idle = character("soldier_idle"), -- 242
	soldier_run = character({"soldier_run", "soldier_step"}), -- 243
	soldier_roll = character("soldier_roll"), -- 244
	soldier_slide = character({"soldier_slide_0", "soldier_slide_1", "soldier_slide_2", "soldier_slide_3"}), -- 245
	soldier_cover = character("soldier_cover"), -- 246
	soldier_push = character({"soldier_push", "soldier_push_step"}), -- 247
	soldier_hold = character("soldier_hold"), -- 248
	soldier_offer = character("soldier_offer"), -- 249
	soldier_knock = character({"soldier_cover", "soldier_knock"}), -- 250
	soldier_hit = character("soldier_hit"), -- 251
	soldier_fire = character("soldier_fire"), -- 252
	soldier_fire_move = character({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}), -- 253
	child_idle = character("child_idle"), -- 254
	child_run = character({"child_run", "child_step"}), -- 255
	child_crouch = character({"child_crouch", "child_crouch_step"}), -- 256
	child_fear = character("child_fear"), -- 257
	child_peek = character("child_peek"), -- 258
	child_pull = character({"child_pull", "child_pull_step"}), -- 259
	child_aim = character("child_aim"), -- 260
	child_throw = character("child_throw"), -- 261
	child_knock = character("child_knock"), -- 262
	child_offer = character("child_offer"), -- 263
	enemy_idle = actor("enemy_idle", 0.5), -- 264
	enemy_aim = actor("enemy_aim", 0.51), -- 265
	enemy_down = actor("enemy_down"), -- 266
	enemy_hit = actor("enemy_hit", 0.48), -- 267
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}, {0.52, 0.52, 0.48, 0.52}), -- 268
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}, {0.5, 0.5, 0.54, 0.58}), -- 269
	prop_cart = clip("cart", 0, false, 0.44), -- 270
	prop_bottle = clip("bottle", 0.5, true), -- 271
	prop_tower_door = clip("door"), -- 272
	prop_lantern = clip("lantern", 0.5, true), -- 273
	prop_table = clip("table"), -- 274
	prop_compass = clip("compass", 0.5, true), -- 275
	prop_winch = clip("winch", 0.5, true), -- 276
	wall = clip("wall"), -- 277
	cover_wood = clip("cover_wood"), -- 278
	cover_stone = clip("cover_stone"), -- 279
	fence = clip("fence"), -- 280
	slab = clip("slab"), -- 281
	eaves = clip("eaves"), -- 282
	pine = clip("pine"), -- 283
	grass = clip("grass"), -- 284
	grass_low = clip("grass_low"), -- 285
	stone_chips = clip("stone_chips", 0.5, true), -- 286
	ui_corner = clip("ui_corner"), -- 287
	ui_corner_c = clip("ui_corner", 0.5, false), -- 288
	ui_paper = clip("paper", 0.5), -- 289
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 290
	ink_mist_curve = inkClip("ink_mist_curve"), -- 291
	ink_veil_strip = inkClip("ink_veil_strip"), -- 292
	ink_hairline = inkClip("ink_hairline"), -- 293
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 294
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 295
	ink_frame_mask = inkClip("ink_frame_mask"), -- 296
	ink_vstream = inkClip("ink_vstream"), -- 297
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 298
	ink_corner_fine = inkClip("ink_corner_fine"), -- 299
	ink_seal_slender = inkClip("ink_seal_slender"), -- 300
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 301
	ink_enso_fine = inkClip("ink_enso_fine"), -- 302
	ink_petal_mist = inkClip("ink_petal_mist"), -- 303
	ink_song_paper = inkClip("ink_song_paper"), -- 304
	brand_game_logo_h = {paths = {"assets/art/brand/game_logo_h.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 305
	brand_game_logo_v = {paths = {"assets/art/brand/game_logo_v.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 306
	brand_team_logo = {paths = {"assets/art/brand/team_logo_dark.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 307
	brand_team_badge = {paths = {"assets/art/brand/team_badge.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 308
	slide_p01_01 = slide("p01_01_curtain"), -- 310
	slide_p01_02 = slide("p01_02_hand"), -- 311
	slide_p01_03 = slide("p01_03_door"), -- 312
	slide_p02_01 = slide("p02_01_shadows"), -- 313
	slide_p02_02 = slide("p02_02_cut"), -- 314
	slide_p02_03 = slide("p02_03_bowl_roll"), -- 315
	slide_p02_04 = slide("p02_04_bowl_stop"), -- 316
	slide_p02_05 = slide("p02_05_cabinet"), -- 317
	slide_cuff_p03_01 = slide("cuff_p03_01"), -- 318
	slide_cuff_p03_02 = slide("cuff_p03_02"), -- 319
	slide_cuff_p03_03 = slide("cuff_p03_03"), -- 320
	slide_cuff_p03_04 = slide("cuff_p03_04"), -- 321
	slide_cuff_p05_01 = slide("cuff_p05_01"), -- 322
	slide_cuff_p05_02 = slide("cuff_p05_02"), -- 323
	slide_cuff_p05_03 = slide("cuff_p05_03"), -- 324
	slide_cuff_p05_04 = slide("cuff_p05_04"), -- 325
	slide_cuff_g05_01 = slide("cuff_g05_01"), -- 326
	slide_cuff_g05_02 = slide("cuff_g05_02"), -- 327
	slide_cuff_g05_03 = slide("cuff_g05_03"), -- 328
	slide_cuff_g05_04 = slide("cuff_g05_04"), -- 329
	slide_gate_01 = {paths = {"assets/art/slides/gate_stage_01.png"}, anchorY = 0, preserveAspect = false}, -- 330
	slide_gate_02 = {paths = {"assets/art/slides/gate_stage_02.png"}, anchorY = 0, preserveAspect = false}, -- 331
	slide_gate_03 = {paths = {"assets/art/slides/gate_stage_03.png"}, anchorY = 0, preserveAspect = false}, -- 332
	slide_gate_04 = {paths = {"assets/art/slides/gate_stage_04.png"}, anchorY = 0, preserveAspect = false}, -- 333
	slide_tower_porch_f03_closed = slide("tower_porch_f03_closed"), -- 334
	slide_tower_porch_f03_open = slide("tower_porch_f03_open"), -- 335
	slide_tower_porch_m03_closed = slide("tower_porch_m03_closed"), -- 336
	slide_tower_porch_m03_open = slide("tower_porch_m03_open"), -- 337
	slide_tower_room_f03_cold = slide("tower_room_f03_cold"), -- 338
	slide_tower_room_f03_lit = slide("tower_room_f03_lit"), -- 339
	slide_tower_room_m03_warm = slide("tower_room_m03_warm"), -- 340
	slide_tower_interior_live = {paths = {"assets/art/slides/tower_interior_live.png"}, anchorY = 0, preserveAspect = false}, -- 341
	slide_e01_well = slide("e01_01_well"), -- 342
	slide_e01_compass = slide("e01_02_compass"), -- 343
	slide_e01_vitrine = slide("e01_03_vitrine"), -- 344
	slide_e02_museum_hall = {paths = {"assets/art/slides/e02_museum_hall.png"}, anchorY = 0, preserveAspect = false}, -- 345
	slide_e02_window_dawn = slide("e02_window_dawn"), -- 346
	slide_e02_return_cabinet = slide("e02_return_cabinet"), -- 347
	slide_f01_sewing = slide("f01_sewing_memory"), -- 348
	slide_m02_lantern_gun = slide("m02_handover_lantern"), -- 349
	slide_m02_echo_gun = slide("m02_handover_echo"), -- 350
	comic_p01_01_curtain_dark = comicCutscene("p01/p01_01_curtain_dark"), -- 352
	comic_p01_02_curtain_glow = comicCutscene("p01/p01_02_curtain_glow"), -- 353
	comic_p01_03_hand_bedrail = comicCutscene("p01/p01_03_hand_bedrail"), -- 354
	comic_p01_04_look_door = comicCutscene("p01/p01_04_look_door"), -- 355
	comic_p01_f01 = comicCutscene("p01/p01_f01"), -- 356
	comic_p01_f02 = comicCutscene("p01/p01_f02"), -- 357
	comic_p01_f03 = comicCutscene("p01/p01_f03"), -- 358
	comic_p01_f04 = comicCutscene("p01/p01_f04"), -- 359
	comic_p01_f05 = comicCutscene("p01/p01_f05"), -- 360
	comic_p01_f06 = comicCutscene("p01/p01_f06"), -- 361
	comic_p01_f07 = comicCutscene("p01/p01_f07"), -- 362
	comic_p01_f08 = comicCutscene("p01/p01_f08"), -- 363
	comic_p01_f09 = comicCutscene("p01/p01_f09"), -- 364
	comic_p01_f10 = comicCutscene("p01/p01_f10"), -- 365
	comic_p01_f11 = comicCutscene("p01/p01_f11"), -- 366
	comic_p01_f12 = comicCutscene("p01/p01_f12"), -- 367
	comic_p01_f13 = comicCutscene("p01/p01_f13"), -- 368
	comic_p01_f14 = comicCutscene("p01/p01_f14"), -- 369
	comic_p01_f15 = comicCutscene("p01/p01_f15"), -- 370
	comic_p01_f16 = comicCutscene("p01/p01_f16"), -- 371
	comic_p01_f17 = comicCutscene("p01/p01_f17"), -- 372
	comic_p01_f18 = comicCutscene("p01/p01_f18"), -- 373
	comic_p01_f19 = comicCutscene("p01/p01_f19"), -- 374
	comic_p01_f20 = comicCutscene("p01/p01_f20"), -- 375
	comic_p01_f21 = comicCutscene("p01/p01_f21"), -- 376
	comic_p01_f22 = comicCutscene("p01/p01_f22"), -- 377
	comic_p02_01_shadows = comicCutscene("p02/p02_01_shadows"), -- 378
	comic_p02_02a_door_intrude = comicCutscene("p02/p02_02a_door_intrude"), -- 379
	comic_p02_03_impact_cut = comicCutscene("p02/p02_03_impact_cut"), -- 380
	comic_p02_04_shadows_fall = comicCutscene("p02/p02_04_shadows_fall"), -- 381
	comic_p02_05_bowl_roll1 = comicCutscene("p02/p02_05_bowl_roll1"), -- 382
	comic_p02_06_bowl_roll2 = comicCutscene("p02/p02_06_bowl_roll2"), -- 383
	comic_p02_07_bowl_smash = comicCutscene("p02/p02_07_bowl_smash"), -- 384
	comic_p02_08a_cabinet_slit = comicCutscene("p02/p02_08a_cabinet_slit"), -- 385
	comic_p02_08m_cabinet_narrowing = comicCutscene("p02/p02_08m_cabinet_narrowing"), -- 386
	comic_p02_08b_cabinet_shut = comicCutscene("p02/p02_08b_cabinet_shut"), -- 387
	comic_p02_f01 = comicCutscene("p02/p02_f01"), -- 388
	comic_p02_f02 = comicCutscene("p02/p02_f02"), -- 389
	comic_p02_f03 = comicCutscene("p02/p02_f03"), -- 390
	comic_p02_f04 = comicCutscene("p02/p02_f04"), -- 391
	comic_p02_f05 = comicCutscene("p02/p02_f05"), -- 392
	comic_p02_f06 = comicCutscene("p02/p02_f06"), -- 393
	comic_p02_f07 = comicCutscene("p02/p02_f07"), -- 394
	comic_p02_f08 = comicCutscene("p02/p02_f08"), -- 395
	comic_p02_f09 = comicCutscene("p02/p02_f09"), -- 396
	comic_p02_f10 = comicCutscene("p02/p02_f10"), -- 397
	comic_p02_f11 = comicCutscene("p02/p02_f11"), -- 398
	comic_p02_f12 = comicCutscene("p02/p02_f12"), -- 399
	comic_p02_f13 = comicCutscene("p02/p02_f13"), -- 400
	comic_p02_f14 = comicCutscene("p02/p02_f14"), -- 401
	comic_p02_f15 = comicCutscene("p02/p02_f15"), -- 402
	comic_p02_f16 = comicCutscene("p02/p02_f16"), -- 403
	comic_p02_f17 = comicCutscene("p02/p02_f17"), -- 404
	comic_p02_f18 = comicCutscene("p02/p02_f18"), -- 405
	comic_p02_f19 = comicCutscene("p02/p02_f19"), -- 406
	comic_p02_f20 = comicCutscene("p02/p02_f20"), -- 407
	comic_p02_f21 = comicCutscene("p02/p02_f21"), -- 408
	comic_p02_f22 = comicCutscene("p02/p02_f22"), -- 409
	comic_p02_f23 = comicCutscene("p02/p02_f23"), -- 410
	comic_p02_f24 = comicCutscene("p02/p02_f24"), -- 411
	comic_p02_f25 = comicCutscene("p02/p02_f25"), -- 412
	comic_p02_f26 = comicCutscene("p02/p02_f26"), -- 413
	comic_p02_f27 = comicCutscene("p02/p02_f27"), -- 414
	comic_p02_f28 = comicCutscene("p02/p02_f28"), -- 415
	comic_p02_f29 = comicCutscene("p02/p02_f29"), -- 416
	comic_p02_f30 = comicCutscene("p02/p02_f30"), -- 417
	comic_p02_f31 = comicCutscene("p02/p02_f31"), -- 418
	comic_p02_f32 = comicCutscene("p02/p02_f32"), -- 419
	comic_p02_f33 = comicCutscene("p02/p02_f33"), -- 420
	comic_p03_01_two_fingers = comicCutscene("p03/p03_01_two_fingers"), -- 421
	comic_p03_02_cuff_enter = comicCutscene("p03/p03_02_cuff_enter"), -- 422
	comic_p03_03_cuff_wipe = comicCutscene("p03/p03_03_cuff_wipe"), -- 423
	comic_p03_04_hand_meet = comicCutscene("p03/p03_04_hand_meet"), -- 424
	comic_p03_f01 = comicCutscene("p03/p03_f01"), -- 425
	comic_p03_f02 = comicCutscene("p03/p03_f02"), -- 426
	comic_p03_f03 = comicCutscene("p03/p03_f03"), -- 427
	comic_p03_f04 = comicCutscene("p03/p03_f04"), -- 428
	comic_p03_f05 = comicCutscene("p03/p03_f05"), -- 429
	comic_p03_f06 = comicCutscene("p03/p03_f06"), -- 430
	comic_p03_f07 = comicCutscene("p03/p03_f07"), -- 431
	comic_p03_f08 = comicCutscene("p03/p03_f08"), -- 432
	comic_p03_f09 = comicCutscene("p03/p03_f09"), -- 433
	comic_p03_f10 = comicCutscene("p03/p03_f10"), -- 434
	comic_p03_f11 = comicCutscene("p03/p03_f11"), -- 435
	comic_p03_f12 = comicCutscene("p03/p03_f12"), -- 436
	comic_p03_f13 = comicCutscene("p03/p03_f13"), -- 437
	comic_p03_f14 = comicCutscene("p03/p03_f14"), -- 438
	comic_p03_f15 = comicCutscene("p03/p03_f15"), -- 439
	comic_p03_f16 = comicCutscene("p03/p03_f16"), -- 440
	comic_p03_f17 = comicCutscene("p03/p03_f17"), -- 441
	comic_p03_f18 = comicCutscene("p03/p03_f18"), -- 442
	comic_p03_f19 = comicCutscene("p03/p03_f19"), -- 443
	comic_p03_f20 = comicCutscene("p03/p03_f20"), -- 444
	comic_p03_f21 = comicCutscene("p03/p03_f21"), -- 445
	comic_p03_f22 = comicCutscene("p03/p03_f22"), -- 446
	comic_p03_f23 = comicCutscene("p03/p03_f23"), -- 447
	comic_p03_f24 = comicCutscene("p03/p03_f24"), -- 448
	comic_p05_01_clutch_cuff = comicCutscene("p05/p05_01_clutch_cuff"), -- 449
	comic_p05_02_brother_pinch = comicCutscene("p05/p05_02_brother_pinch"), -- 450
	comic_p05_03_sleeve_pull = comicCutscene("p05/p05_03_sleeve_pull"), -- 451
	comic_p05_04_gate_drop = comicCutscene("p05/p05_04_gate_drop"), -- 452
	comic_p05_05_gate_slam_impact = comicCutscene("p05/p05_05_gate_slam_impact"), -- 453
	comic_p05_06_open_fingers = comicCutscene("p05/p05_06_open_fingers"), -- 454
	comic_p05_f01 = comicCutscene("p05/p05_f01"), -- 455
	comic_p05_f02 = comicCutscene("p05/p05_f02"), -- 456
	comic_p05_f03 = comicCutscene("p05/p05_f03"), -- 457
	comic_p05_f04 = comicCutscene("p05/p05_f04"), -- 458
	comic_p05_f05 = comicCutscene("p05/p05_f05"), -- 459
	comic_p05_f06 = comicCutscene("p05/p05_f06"), -- 460
	comic_p05_f07 = comicCutscene("p05/p05_f07"), -- 461
	comic_p05_f08 = comicCutscene("p05/p05_f08"), -- 462
	comic_p05_f09 = comicCutscene("p05/p05_f09"), -- 463
	comic_p05_f10 = comicCutscene("p05/p05_f10"), -- 464
	comic_p05_f11 = comicCutscene("p05/p05_f11"), -- 465
	comic_p05_f12 = comicCutscene("p05/p05_f12"), -- 466
	comic_p05_f13 = comicCutscene("p05/p05_f13"), -- 467
	comic_p05_f14 = comicCutscene("p05/p05_f14"), -- 468
	comic_p05_f15 = comicCutscene("p05/p05_f15"), -- 469
	comic_p05_f16 = comicCutscene("p05/p05_f16"), -- 470
	comic_p05_f17 = comicCutscene("p05/p05_f17"), -- 471
	comic_g05_01_cuff_peek = comicCutscene("g05/g05_01_cuff_peek"), -- 472
	comic_g05_02_cuff_extend = comicCutscene("g05/g05_02_cuff_extend"), -- 473
	comic_g05_03_hands_meet = comicCutscene("g05/g05_03_hands_meet"), -- 474
	comic_g05_04_hands_clasp = comicCutscene("g05/g05_04_hands_clasp"), -- 475
	comic_g05_05_tilt_arm = comicCutscene("g05/g05_05_tilt_arm"), -- 476
	comic_g05_06_tilt_shoulder = comicCutscene("g05/g05_06_tilt_shoulder"), -- 477
	comic_g05_07_zhoushu_reveal = comicCutscene("g05/g05_07_zhoushu_reveal"), -- 478
	comic_g05_08_zhoushu_warm = comicCutscene("g05/g05_08_zhoushu_warm"), -- 479
	comic_g05_f01 = comicCutscene("g05/g05_f01"), -- 480
	comic_g05_f02 = comicCutscene("g05/g05_f02"), -- 481
	comic_g05_f03 = comicCutscene("g05/g05_f03"), -- 482
	comic_g05_f04 = comicCutscene("g05/g05_f04"), -- 483
	comic_g05_f05 = comicCutscene("g05/g05_f05"), -- 484
	comic_g05_f06 = comicCutscene("g05/g05_f06"), -- 485
	comic_g05_f07 = comicCutscene("g05/g05_f07"), -- 486
	comic_g05_f08 = comicCutscene("g05/g05_f08"), -- 487
	comic_g05_f09 = comicCutscene("g05/g05_f09"), -- 488
	comic_g05_f10 = comicCutscene("g05/g05_f10"), -- 489
	comic_g05_f11 = comicCutscene("g05/g05_f11"), -- 490
	comic_g05_f12 = comicCutscene("g05/g05_f12"), -- 491
	comic_g05_f13 = comicCutscene("g05/g05_f13"), -- 492
	comic_g05_f14 = comicCutscene("g05/g05_f14"), -- 493
	comic_g05_f15 = comicCutscene("g05/g05_f15"), -- 494
	comic_g05_f16 = comicCutscene("g05/g05_f16"), -- 495
	comic_g05_f17 = comicCutscene("g05/g05_f17"), -- 496
	comic_g05_f18 = comicCutscene("g05/g05_f18"), -- 497
	comic_g05_f19 = comicCutscene("g05/g05_f19"), -- 498
	comic_g05_f20 = comicCutscene("g05/g05_f20"), -- 499
	comic_gate_01_beam = {paths = {"assets/art/cutscenes/gate/gate_01_beam.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 500
	comic_gate_02_dock = {paths = {"assets/art/cutscenes/gate/gate_02_dock.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 501
	comic_gate_03_fog = {paths = {"assets/art/cutscenes/gate/gate_03_fog.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 502
	comic_gate_04_terrace = {paths = {"assets/art/cutscenes/gate/gate_04_terrace.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 503
	comic_gate_f01 = {paths = {"assets/art/cutscenes/gate/gate_f01.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 504
	comic_gate_f02 = {paths = {"assets/art/cutscenes/gate/gate_f02.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 505
	comic_gate_f03 = {paths = {"assets/art/cutscenes/gate/gate_f03.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 506
	comic_gate_f04 = {paths = {"assets/art/cutscenes/gate/gate_f04.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 507
	comic_gate_f05 = {paths = {"assets/art/cutscenes/gate/gate_f05.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 508
	comic_gate_f06 = {paths = {"assets/art/cutscenes/gate/gate_f06.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 509
	comic_gate_f07 = {paths = {"assets/art/cutscenes/gate/gate_f07.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 510
	comic_gate_f08 = {paths = {"assets/art/cutscenes/gate/gate_f08.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 511
	comic_gate_f09 = {paths = {"assets/art/cutscenes/gate/gate_f09.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 512
	comic_gate_f10 = {paths = {"assets/art/cutscenes/gate/gate_f10.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 513
	comic_f01_01_thumb_cloth = comicCutscene("f01/f01_01_thumb_cloth"), -- 514
	comic_f01_02_needle_pierce = comicCutscene("f01/f01_02_needle_pierce"), -- 515
	comic_f01_03_thread_pull = comicCutscene("f01/f01_03_thread_pull"), -- 516
	comic_f01_04_stitch_smooth = comicCutscene("f01/f01_04_stitch_smooth"), -- 517
	comic_f01_f01 = comicCutscene("f01/f01_f01"), -- 518
	comic_f01_f02 = comicCutscene("f01/f01_f02"), -- 519
	comic_f01_f03 = comicCutscene("f01/f01_f03"), -- 520
	comic_f01_f04 = comicCutscene("f01/f01_f04"), -- 521
	comic_f01_f05 = comicCutscene("f01/f01_f05"), -- 522
	comic_f01_f06 = comicCutscene("f01/f01_f06"), -- 523
	comic_f01_f07 = comicCutscene("f01/f01_f07"), -- 524
	comic_f01_f08 = comicCutscene("f01/f01_f08"), -- 525
	comic_f01_f09 = comicCutscene("f01/f01_f09"), -- 526
	comic_f01_f10 = comicCutscene("f01/f01_f10"), -- 527
	comic_f01_f11 = comicCutscene("f01/f01_f11"), -- 528
	comic_f01_f12 = comicCutscene("f01/f01_f12"), -- 529
	comic_m02_lantern_01_offer = comicCutscene("m02/m02_lantern_01_offer"), -- 530
	comic_m02_lantern_02_grip = comicCutscene("m02/m02_lantern_02_grip"), -- 531
	comic_m02_lantern_03_heft = comicCutscene("m02/m02_lantern_03_heft"), -- 532
	comic_m02_lantern_04_ready = comicCutscene("m02/m02_lantern_04_ready"), -- 533
	comic_m02_lantern_f01 = comicCutscene("m02/m02_lantern_f01"), -- 534
	comic_m02_lantern_f02 = comicCutscene("m02/m02_lantern_f02"), -- 535
	comic_m02_lantern_f03 = comicCutscene("m02/m02_lantern_f03"), -- 536
	comic_m02_lantern_f04 = comicCutscene("m02/m02_lantern_f04"), -- 537
	comic_m02_lantern_f05 = comicCutscene("m02/m02_lantern_f05"), -- 538
	comic_m02_lantern_f06 = comicCutscene("m02/m02_lantern_f06"), -- 539
	comic_m02_lantern_f07 = comicCutscene("m02/m02_lantern_f07"), -- 540
	comic_m02_lantern_f08 = comicCutscene("m02/m02_lantern_f08"), -- 541
	comic_m02_lantern_f09 = comicCutscene("m02/m02_lantern_f09"), -- 542
	comic_m02_lantern_f10 = comicCutscene("m02/m02_lantern_f10"), -- 543
	comic_m02_lantern_f11 = comicCutscene("m02/m02_lantern_f11"), -- 544
	comic_m02_lantern_f12 = comicCutscene("m02/m02_lantern_f12"), -- 545
	comic_m02_echo_01_offer = comicCutscene("m02/m02_echo_01_offer"), -- 546
	comic_m02_echo_02_grip = comicCutscene("m02/m02_echo_02_grip"), -- 547
	comic_m02_echo_03_heft = comicCutscene("m02/m02_echo_03_heft"), -- 548
	comic_m02_echo_04_ready = comicCutscene("m02/m02_echo_04_ready"), -- 549
	comic_m02_echo_f01 = comicCutscene("m02/m02_echo_f01"), -- 550
	comic_m02_echo_f02 = comicCutscene("m02/m02_echo_f02"), -- 551
	comic_m02_echo_f03 = comicCutscene("m02/m02_echo_f03"), -- 552
	comic_m02_echo_f04 = comicCutscene("m02/m02_echo_f04"), -- 553
	comic_m02_echo_f05 = comicCutscene("m02/m02_echo_f05"), -- 554
	comic_m02_echo_f06 = comicCutscene("m02/m02_echo_f06"), -- 555
	comic_m02_echo_f07 = comicCutscene("m02/m02_echo_f07"), -- 556
	comic_m02_echo_f08 = comicCutscene("m02/m02_echo_f08"), -- 557
	comic_m02_echo_f09 = comicCutscene("m02/m02_echo_f09"), -- 558
	comic_m02_echo_f10 = comicCutscene("m02/m02_echo_f10"), -- 559
	comic_m02_echo_f11 = comicCutscene("m02/m02_echo_f11"), -- 560
	comic_tower_f03_porch_01_knock = comicCutscene("tower/f03_porch_01_knock"), -- 561
	comic_tower_f03_porch_02_open = comicCutscene("tower/f03_porch_02_open"), -- 562
	comic_tower_m03_porch_01_knock = comicCutscene("tower/m03_porch_01_knock"), -- 563
	comic_tower_m03_porch_02_open = comicCutscene("tower/m03_porch_02_open"), -- 564
	comic_tower_f03_room_01_cold = comicCutscene("tower/f03_room_01_cold"), -- 565
	comic_tower_f03_room_02_hover = comicCutscene("tower/f03_room_02_hover"), -- 566
	comic_tower_f03_room_03_move_lamp = comicCutscene("tower/f03_room_03_move_lamp"), -- 567
	comic_tower_f03_room_04_lit_bowl = comicCutscene("tower/f03_room_04_lit_bowl"), -- 568
	comic_tower_m03_room_01_warm = comicCutscene("tower/m03_room_01_warm"), -- 569
	comic_tower_m03_room_02_speak = comicCutscene("tower/m03_room_02_speak"), -- 570
	comic_tower_m03_room_03_pouch = comicCutscene("tower/m03_room_03_pouch"), -- 571
	comic_tower_m03_room_04_bowl = comicCutscene("tower/m03_room_04_bowl"), -- 572
	comic_f03_f01 = comicCutscene("tower/f03_f01"), -- 573
	comic_f03_f02 = comicCutscene("tower/f03_f02"), -- 574
	comic_f03_f03 = comicCutscene("tower/f03_f03"), -- 575
	comic_f03_f04 = comicCutscene("tower/f03_f04"), -- 576
	comic_f03_f05 = comicCutscene("tower/f03_f05"), -- 577
	comic_f03_f06 = comicCutscene("tower/f03_f06"), -- 578
	comic_f03_f07 = comicCutscene("tower/f03_f07"), -- 579
	comic_f03_f08 = comicCutscene("tower/f03_f08"), -- 580
	comic_f03_f09 = comicCutscene("tower/f03_f09"), -- 581
	comic_f03_f10 = comicCutscene("tower/f03_f10"), -- 582
	comic_f03_f11 = comicCutscene("tower/f03_f11"), -- 583
	comic_f03_f12 = comicCutscene("tower/f03_f12"), -- 584
	comic_f03_f13 = comicCutscene("tower/f03_f13"), -- 585
	comic_f03_f14 = comicCutscene("tower/f03_f14"), -- 586
	comic_f03_f15 = comicCutscene("tower/f03_f15"), -- 587
	comic_f03_f16 = comicCutscene("tower/f03_f16"), -- 588
	comic_f03_f17 = comicCutscene("tower/f03_f17"), -- 589
	comic_f03_f18 = comicCutscene("tower/f03_f18"), -- 590
	comic_f03_f19 = comicCutscene("tower/f03_f19"), -- 591
	comic_f03_f20 = comicCutscene("tower/f03_f20"), -- 592
	comic_m03_f01 = comicCutscene("tower/m03_f01"), -- 593
	comic_m03_f02 = comicCutscene("tower/m03_f02"), -- 594
	comic_m03_f03 = comicCutscene("tower/m03_f03"), -- 595
	comic_m03_f04 = comicCutscene("tower/m03_f04"), -- 596
	comic_m03_f05 = comicCutscene("tower/m03_f05"), -- 597
	comic_m03_f06 = comicCutscene("tower/m03_f06"), -- 598
	comic_m03_f07 = comicCutscene("tower/m03_f07"), -- 599
	comic_m03_f08 = comicCutscene("tower/m03_f08"), -- 600
	comic_m03_f09 = comicCutscene("tower/m03_f09"), -- 601
	comic_m03_f10 = comicCutscene("tower/m03_f10"), -- 602
	comic_m03_f11 = comicCutscene("tower/m03_f11"), -- 603
	comic_m03_f12 = comicCutscene("tower/m03_f12"), -- 604
	comic_m03_f13 = comicCutscene("tower/m03_f13"), -- 605
	comic_m03_f14 = comicCutscene("tower/m03_f14"), -- 606
	comic_m03_f15 = comicCutscene("tower/m03_f15"), -- 607
	comic_m03_f16 = comicCutscene("tower/m03_f16"), -- 608
	comic_m03_f17 = comicCutscene("tower/m03_f17"), -- 609
	comic_m03_f18 = comicCutscene("tower/m03_f18"), -- 610
	comic_m03_f19 = comicCutscene("tower/m03_f19"), -- 611
	comic_m03_f20 = comicCutscene("tower/m03_f20"), -- 612
	comic_museum_e01_01_well_water = comicCutscene("museum/e01_01_well_water"), -- 613
	comic_museum_e01_02_compass_align = comicCutscene("museum/e01_02_compass_align"), -- 614
	comic_museum_e01_03_match_flash = comicCutscene("museum/e01_03_match_flash"), -- 615
	comic_museum_e01_04_vitrine_emerge = comicCutscene("museum/e01_04_vitrine_emerge"), -- 616
	comic_e01_f01 = comicCutscene("museum/e01_f01"), -- 617
	comic_e01_f02 = comicCutscene("museum/e01_f02"), -- 618
	comic_e01_f03 = comicCutscene("museum/e01_f03"), -- 619
	comic_e01_f04 = comicCutscene("museum/e01_f04"), -- 620
	comic_e01_f05 = comicCutscene("museum/e01_f05"), -- 621
	comic_e01_f06 = comicCutscene("museum/e01_f06"), -- 622
	comic_e01_f07 = comicCutscene("museum/e01_f07"), -- 623
	comic_e01_f08 = comicCutscene("museum/e01_f08"), -- 624
	comic_e01_f09 = comicCutscene("museum/e01_f09"), -- 625
	comic_e01_f10 = comicCutscene("museum/e01_f10"), -- 626
	comic_e01_f11 = comicCutscene("museum/e01_f11"), -- 627
	comic_e01_f12 = comicCutscene("museum/e01_f12"), -- 628
	comic_e01_f13 = comicCutscene("museum/e01_f13"), -- 629
	comic_e01_f14 = comicCutscene("museum/e01_f14"), -- 630
	comic_e01_f15 = comicCutscene("museum/e01_f15"), -- 631
	comic_e01_f16 = comicCutscene("museum/e01_f16"), -- 632
	comic_museum_e02_01_west_window = comicCutscene("museum/e02_01_west_window"), -- 633
	comic_museum_e02_02_lamp_turn = comicCutscene("museum/e02_02_lamp_turn"), -- 634
	comic_museum_e02_03_dawn_well_reflect = comicCutscene("museum/e02_03_dawn_well_reflect"), -- 635
	comic_museum_e02_04_cabinet_cuff_return = comicCutscene("museum/e02_04_cabinet_cuff_return"), -- 636
	comic_e02_f01 = comicCutscene("museum/e02_f01"), -- 637
	comic_e02_f02 = comicCutscene("museum/e02_f02"), -- 638
	comic_e02_f03 = comicCutscene("museum/e02_f03"), -- 639
	comic_e02_f04 = comicCutscene("museum/e02_f04"), -- 640
	comic_e02_f05 = comicCutscene("museum/e02_f05"), -- 641
	comic_e02_f06 = comicCutscene("museum/e02_f06"), -- 642
	comic_e02_f07 = comicCutscene("museum/e02_f07"), -- 643
	comic_e02_f08 = comicCutscene("museum/e02_f08"), -- 644
	comic_e02_f09 = comicCutscene("museum/e02_f09"), -- 645
	comic_e02_f10 = comicCutscene("museum/e02_f10"), -- 646
	comic_e02_f11 = comicCutscene("museum/e02_f11"), -- 647
	comic_e02_f12 = comicCutscene("museum/e02_f12"), -- 648
	comic_e02_f13 = comicCutscene("museum/e02_f13"), -- 649
	comic_e02_f14 = comicCutscene("museum/e02_f14"), -- 650
	comic_e02_f15 = comicCutscene("museum/e02_f15"), -- 651
	comic_e02_f16 = comicCutscene("museum/e02_f16"), -- 652
	comic_e02_f17 = comicCutscene("museum/e02_f17"), -- 653
	comic_e02_f18 = comicCutscene("museum/e02_f18"), -- 654
	comic_e02_f19 = comicCutscene("museum/e02_f19"), -- 655
	comic_e02_f20 = comicCutscene("museum/e02_f20"), -- 656
	fe_carry_idle = feClip("carry_idle", 0, true, 0.5), -- 658
	fe_carry_walk = feClip({"carry_walk_a", "carry_idle", "carry_walk_b", "carry_idle"}, 0, true, {0.5, 0.5, 0.5, 0.5}), -- 659
	fe_carry_reload = feClip("carry_reload", 0, true, 0.48), -- 660
	fe_soldier_kneel_mount = feClip("soldier_kneel_mount", 0, true, 0.5), -- 661
	fe_child_listen_door = feClip("child_listen_door", 0, true, 0.5), -- 662
	fe_soldier_hand_hold = feClip("soldier_hand_hold", 0, true, 0.5), -- 663
	fe_tower_guard_lantern = feClip("tower_guard_lantern", 0, true, 0.5), -- 664
	fe_tower_brush_hand = feClip("tower_brush_hand", 0.08, true, 0.06), -- 665
	fe_reload_hand_tap = feClip("reload_hand_tap", 0.9, true, 0.14), -- 666
	fe_reload_hand_trace = feClip("reload_hand_trace", 0.58, true, 0.92), -- 667
	fe_tower_cuff_rest = feClip("tower_cuff_rest", 0.5, true, 0.05), -- 668
	fe_tower_bowl_solo = feClip("tower_bowl_solo", 0.25, true, 0.5), -- 669
	fe_tower_bowl_hands = feClip("tower_bowl_hands", 0.4, true, 0.5), -- 670
	fe_tower_pouch_note = feClip("tower_pouch_note", 0.42, true, 0.5), -- 671
	fe_tower_lantern_detail = feClip("tower_lantern_detail", 0.14, true, 0.5), -- 672
	fe_basin_flat = feClip("prop_basin_flat", 0, true, 0.5), -- 673
	fe_basin_tilt = feClip("prop_basin_tilt", 0, true, 0.5), -- 674
	fe_well_rim = feClip("prop_well_rim", 0, true, 0.5), -- 675
	fe_outside_arch = feClip("prop_outside_arch", 0, false, 0.5), -- 676
	fe_straw_target = feClip("prop_straw_target", 0, true, 0.5), -- 677
	fe_workbench = feClip("prop_workbench", 0, false, 0.5), -- 678
	fe_bottle_rack = feClip("prop_bottle_rack", 0, true, 0.5), -- 679
	fe_braced_shield = feClip("prop_braced_shield", 0, true, 0.5), -- 680
	fe_weapon_lantern_gun = feClip("weapon_lantern_gun", 0.5, true, 0.5), -- 681
	fe_weapon_echo_gun = feClip("weapon_echo_gun", 0.5, true, 0.5), -- 682
	fe_lamp_bracket = feClip("prop_lamp_bracket", 0, true, 0.5), -- 683
	fe_icon_wood_tally = feClip("icon_wood_tally", 0.5, true, 0.5), -- 684
	fe_icon_bell_tally = feClip("icon_bell_tally", 0.5, true, 0.5), -- 685
	fe_gear_rattan_shield = feClip("gear_rattan_shield", 0.5, true, 0.5), -- 686
	fe_root_arch = feClip("prop_root_arch", 0, false, 0.5), -- 687
	fe_culvert_grate = feClip("prop_culvert_grate", 0, false, 0.5), -- 688
	fe_red_cloth = feClip({"prop_red_cloth_01", "prop_red_cloth_02", "prop_red_cloth_03"}, 0.5, true, 0.9), -- 689
	fe_vfx_muzzle = feClip({"vfx_muzzle_01", "vfx_muzzle_02", "vfx_muzzle_03"}, 0.5, true, 0.12), -- 690
	fe_vfx_hit_spark = feClip({"vfx_hit_spark_01", "vfx_hit_spark_02", "vfx_hit_spark_03"}, 0.5, true, 0.5), -- 691
	fe_vfx_smoke = feClip({"vfx_smoke_01", "vfx_smoke_02", "vfx_smoke_03", "vfx_smoke_04"}, 0.5, true, 0.5), -- 692
	fe_vfx_steam = feClip({"vfx_steam_01", "vfx_steam_02", "vfx_steam_03"}, 0, true, 0.5), -- 693
	fe_vfx_creek_reflect = feClip({"vfx_creek_reflect_01", "vfx_creek_reflect_02", "vfx_creek_reflect_03"}, 0.5, false, 0.5), -- 694
	fe_glyph_bell = feClip("glyph_bell", 0.5, true, 0.5), -- 695
	fe_glyph_lamp = feClip("glyph_lamp", 0.5, true, 0.5), -- 696
	fe_glyph_push = feClip("glyph_push", 0.5, true, 0.5), -- 697
	fe_ground_brick = feClip("ground_brick_patch", 0, false, 0.5), -- 698
	fe_ground_soft = feClip("ground_soft_patch", 0, false, 0.5), -- 699
	fe_pillar_wood = feClip("pillar_wood", 0, false, 0.5), -- 700
	fe_beam_wood = feClip("beam_wood", 0, false, 0.5), -- 701
	fe_road_stone = feClip("road_stone", 0, false, 0.5), -- 702
	fe_fg_table_top = feClip("fg_table_top", 1, false, 0.5), -- 703
	fe_fg_table_leg = feClip("fg_table_leg", 1, false, 0.5), -- 704
	fe_fg_pine_bough = feClip("fg_pine_bough", 1, false, 1) -- 705
} -- 705
local WHITE = Color(255, 255, 255, 255) -- 708
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 714
	local g = _G -- 715
	local ____temp_0 -- 716
	if g.package ~= nil then -- 716
		____temp_0 = g.package.loaded -- 716
	else -- 716
		____temp_0 = nil -- 716
	end -- 716
	local loaded = ____temp_0 -- 716
	if loaded ~= nil then -- 716
		local existing = loaded["watch.fe.dynamic_slots"] -- 718
		if existing ~= nil and type(existing) == "table" then -- 718
			return existing -- 720
		end -- 720
		local created = {} -- 722
		loaded["watch.fe.dynamic_slots"] = created -- 723
		return created -- 724
	end -- 724
	return FALLBACK_DYNAMIC_SLOTS -- 726
end -- 714
FALLBACK_DYNAMIC_SLOTS = {} -- 729
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 732
	sharedDynamicSlots()[key] = cfg -- 733
end -- 732
function ____exports.unregisterDynamicSlot(key) -- 736
	__TS__Delete( -- 737
		sharedDynamicSlots(), -- 737
		key -- 737
	) -- 737
end -- 736
____exports.AssetSlotHost = __TS__Class() -- 740
local AssetSlotHost = ____exports.AssetSlotHost -- 740
AssetSlotHost.name = "AssetSlotHost" -- 740
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 749
	self.sprites = {} -- 742
	self.unavailable = {} -- 743
	self.lastPlacement = {} -- 744
	self.visibleLastFrame = {} -- 745
	self.visibleThisFrame = {} -- 746
	self.localSlots = {} -- 747
	self.container = Node() -- 750
	self.container.order = order -- 751
	self.container:addTo(parent) -- 752
end -- 749
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 756
	self.localSlots[key] = cfg -- 757
end -- 756
function AssetSlotHost.prototype.currentSprite(self, instanceKey, path) -- 761
	return self.visibleThisFrame[(instanceKey .. ":") .. path] -- 762
end -- 761
function AssetSlotHost.prototype.hideLastPlacement(self, instanceKey) -- 766
	local sprite = self.lastPlacement[instanceKey] -- 767
	if sprite ~= nil then -- 767
		sprite.visible = false -- 769
	end -- 769
end -- 766
function AssetSlotHost.prototype.beginFrame(self) -- 773
	self.visibleThisFrame = {} -- 774
end -- 773
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 777
	if options == nil then -- 777
		options = {} -- 781
	end -- 781
	local staticSlots = ____exports.ASSET_SLOTS -- 783
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 784
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 784
		return false -- 786
	end -- 786
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 788
	local path = cfg.paths[frame + 1] -- 789
	local anchorX = type(cfg.anchorX) == "number" and cfg.anchorX or (cfg.anchorX ~= nil and (cfg.anchorX[frame + 1] or 0.5) or 0.5) -- 790
	return self:placeResolvedPath( -- 793
		path, -- 793
		anchorX, -- 793
		cfg.anchorY, -- 793
		cfg.preserveAspect, -- 793
		cfg.smooth == true, -- 793
		instanceKey, -- 793
		x, -- 793
		y, -- 793
		targetW, -- 793
		targetH, -- 793
		options -- 793
	) -- 793
end -- 777
function AssetSlotHost.prototype.tryPlaceRun(self, actor, instanceKey, x, y, targetW, targetH, cycles, options, effort) -- 798
	if options == nil then -- 798
		options = {} -- 803
	end -- 803
	if effort == nil then -- 803
		effort = 1 -- 804
	end -- 804
	if effort < 1 and self:tryPlaceRunTransition( -- 804
		actor, -- 806
		instanceKey, -- 806
		x, -- 806
		y, -- 806
		targetW, -- 806
		targetH, -- 806
		cycles, -- 806
		effort, -- 806
		options -- 806
	) then -- 806
		return true -- 807
	end -- 807
	local frame = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_FRAME_COUNT) -- 809
	return self:tryPlaceMotionFrame( -- 810
		RUN_ATLASES[actor], -- 810
		frame, -- 810
		instanceKey, -- 810
		x, -- 810
		y, -- 810
		targetW, -- 810
		targetH, -- 810
		options -- 810
	) -- 810
end -- 798
function AssetSlotHost.prototype.tryPlaceRunTransition(self, actor, instanceKey, x, y, targetW, targetH, cycles, effort, options) -- 814
	if options == nil then -- 814
		options = {} -- 819
	end -- 819
	local phase = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_TRANSITION_PHASES + 0.5) % ____exports.RUN_TRANSITION_PHASES -- 821
	local level = math.max( -- 822
		0, -- 822
		math.min( -- 822
			____exports.RUN_TRANSITION_LEVELS - 1, -- 822
			math.floor(effort * (____exports.RUN_TRANSITION_LEVELS + 1) + 0.5) - 1 -- 822
		) -- 822
	) -- 822
	return self:tryPlaceMotionFrame( -- 823
		RUN_TRANSITIONS[actor], -- 823
		level * ____exports.RUN_TRANSITION_PHASES + phase, -- 823
		instanceKey, -- 824
		x, -- 824
		y, -- 824
		targetW, -- 824
		targetH, -- 824
		options -- 824
	) -- 824
end -- 814
function AssetSlotHost.prototype.tryPlaceSlide(self, instanceKey, x, y, targetW, targetH, progress, options) -- 827
	if options == nil then -- 827
		options = {} -- 831
	end -- 831
	local frame = math.max( -- 833
		0, -- 833
		math.min( -- 833
			____exports.SLIDE_FRAME_COUNT - 1, -- 833
			math.floor(progress * ____exports.SLIDE_FRAME_COUNT) -- 833
		) -- 833
	) -- 833
	return self:tryPlaceMotionFrame( -- 834
		SLIDE_ATLAS, -- 834
		frame, -- 834
		instanceKey, -- 834
		x, -- 834
		y, -- 834
		targetW, -- 834
		targetH, -- 834
		options -- 834
	) -- 834
end -- 827
function AssetSlotHost.prototype.tryPlaceMotionFrame(self, atlas, frame, instanceKey, x, y, targetW, targetH, options) -- 837
	if targetW <= 0 or targetH <= 0 then -- 837
		return false -- 845
	end -- 845
	local ____atlas_1 = atlas -- 847
	local path = ____atlas_1.path -- 847
	local width = ____atlas_1.width -- 847
	local height = ____atlas_1.height -- 847
	local columns = ____atlas_1.columns -- 847
	local col = frame % columns -- 848
	local row = math.floor(frame / columns) -- 849
	local rect = Rect(col * (width + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, row * (height + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, width, height) -- 850
	return self:placeResolvedPath( -- 852
		path, -- 852
		0.5, -- 852
		0, -- 852
		true, -- 852
		false, -- 852
		instanceKey, -- 852
		x, -- 852
		y, -- 852
		targetW, -- 852
		targetH, -- 852
		options, -- 852
		rect -- 852
	) -- 852
end -- 837
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 856
	if options == nil then -- 856
		options = {} -- 860
	end -- 860
	if path == "" or targetW <= 0 or targetH <= 0 then -- 860
		return false -- 863
	end -- 863
	local ____self_placeResolvedPath_4 = self.placeResolvedPath -- 865
	local ____array_3 = __TS__SparseArrayNew(path, options.anchorX or 0.5, options.anchorY or 0.5) -- 865
	local ____options_preserveAspect_2 = options.preserveAspect -- 869
	if ____options_preserveAspect_2 == nil then -- 869
		____options_preserveAspect_2 = false -- 869
	end -- 869
	__TS__SparseArrayPush( -- 869
		____array_3, -- 869
		____options_preserveAspect_2, -- 869
		options.smooth == true, -- 870
		instanceKey, -- 871
		x, -- 872
		y, -- 873
		targetW, -- 874
		targetH, -- 875
		options -- 876
	) -- 876
	return ____self_placeResolvedPath_4( -- 865
		self, -- 865
		__TS__SparseArraySpread(____array_3) -- 865
	) -- 865
end -- 856
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorX, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options, textureRect) -- 880
	local key = (instanceKey .. ":") .. path -- 891
	local sprite = self.sprites[key] -- 892
	if sprite == nil then -- 892
		if self.unavailable[path] then -- 892
			return false -- 895
		end -- 895
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 897
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 898
		local ____Content_exist_result_5 -- 899
		if Content:exist(file) then -- 899
			____Content_exist_result_5 = Sprite(path) -- 899
		else -- 899
			____Content_exist_result_5 = nil -- 899
		end -- 899
		local loaded = ____Content_exist_result_5 -- 899
		if loaded == nil then -- 899
			self.unavailable[path] = true -- 901
			return false -- 902
		end -- 902
		if textureRect ~= nil then -- 902
			loaded.size = Size(textureRect.width, textureRect.height) -- 906
		end -- 906
		loaded.filter = smooth and "Anisotropic" or "Point" -- 909
		loaded:addTo(self.container) -- 910
		self.sprites[key] = loaded -- 911
		sprite = loaded -- 912
	end -- 912
	if textureRect ~= nil then -- 912
		sprite.textureRect = textureRect -- 916
	end -- 916
	local scaleY = targetH / math.max(1, textureRect and textureRect.height or sprite.height) -- 918
	local scaleX = preserveAspect and scaleY or targetW / math.max(1, sprite.width) -- 919
	sprite.anchor = Vec2(anchorX, anchorY) -- 920
	sprite.position = textureRect == nil and Vec2( -- 921
		math.floor(x + 0.5), -- 921
		math.floor(y + 0.5) -- 921
	) or Vec2(x, y) -- 921
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 922
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 923
	sprite.angle = options.angle or 0 -- 924
	sprite.order = options.layer or 0 -- 925
	local col = options.color or WHITE -- 926
	sprite.color = col -- 927
	local baseA = col.a / 255 -- 928
	local op = options.opacity or 1 -- 929
	sprite.opacity = math.max( -- 930
		0, -- 930
		math.min(1, baseA * op) -- 930
	) -- 930
	sprite.visible = true -- 931
	self.visibleThisFrame[key] = sprite -- 932
	self.lastPlacement[instanceKey] = sprite -- 933
	return true -- 934
end -- 880
function AssetSlotHost.prototype.endFrame(self) -- 937
	for key in pairs(self.visibleLastFrame) do -- 938
		if self.visibleThisFrame[key] == nil then -- 938
			self.visibleLastFrame[key].visible = false -- 940
		end -- 940
	end -- 940
	self.visibleLastFrame = self.visibleThisFrame -- 943
end -- 937
return ____exports -- 937