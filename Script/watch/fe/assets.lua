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
local function backdrop(name, smooth) -- 158
	if smooth == nil then -- 158
		smooth = false -- 158
	end -- 158
	return smooth and ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false, smooth = true}) or ({paths = {("assets/art/" .. name) .. ".png"}, anchorY = 0, preserveAspect = false}) -- 159
end -- 158
local function clip(names, anchorY, preserveAspect, anchorX) -- 164
	if anchorY == nil then -- 164
		anchorY = 0 -- 166
	end -- 166
	if preserveAspect == nil then -- 166
		preserveAspect = false -- 167
	end -- 167
	local frames = type(names) == "string" and ({names}) or names -- 170
	return { -- 171
		paths = __TS__ArrayMap( -- 171
			frames, -- 171
			function(____, name) return "assets/art/sprites.clip|" .. name end -- 171
		), -- 171
		anchorX = anchorX, -- 171
		anchorY = anchorY, -- 171
		preserveAspect = preserveAspect -- 171
	} -- 171
end -- 164
local function inkClip(name, preserveAspect) -- 174
	if preserveAspect == nil then -- 174
		preserveAspect = false -- 174
	end -- 174
	return {paths = {"assets/art/ui_ink.clip|" .. name}, anchorY = 0.5, preserveAspect = preserveAspect, smooth = true} -- 175
end -- 174
local function actor(names, anchorX) -- 178
	return clip(names, 0, true, anchorX) -- 179
end -- 178
local function slide(name) -- 182
	return {paths = {("assets/art/slides/" .. name) .. ".png"}, anchorY = 0.5, preserveAspect = false} -- 183
end -- 182
local function comicCutscene(rel) -- 186
	return {paths = {("assets/art/cutscenes/" .. rel) .. ".png"}, anchorY = 0.5, preserveAspect = false, smooth = true} -- 187
end -- 186
local function feClip(names, anchorY, preserveAspect, anchorX) -- 190
	if anchorY == nil then -- 190
		anchorY = 0.5 -- 192
	end -- 192
	if preserveAspect == nil then -- 192
		preserveAspect = true -- 193
	end -- 193
	local frames = type(names) == "string" and ({names}) or names -- 196
	return { -- 197
		paths = __TS__ArrayMap( -- 197
			frames, -- 197
			function(____, name) return "assets/art/sprites_fe.clip|" .. name end -- 197
		), -- 197
		anchorX = anchorX, -- 197
		anchorY = anchorY, -- 197
		preserveAspect = preserveAspect -- 197
	} -- 197
end -- 190
local function character(names) -- 200
	local frames = type(names) == "string" and ({names}) or names -- 201
	return { -- 202
		paths = __TS__ArrayMap( -- 202
			frames, -- 202
			function(____, name) return "assets/art/actors-hd.clip|" .. name end -- 202
		), -- 202
		anchorY = 0, -- 202
		preserveAspect = true -- 202
	} -- 202
end -- 200
____exports.RUN_FRAME_COUNT = 160 -- 205
____exports.RUN_TRANSITION_PHASES = 8 -- 206
____exports.RUN_TRANSITION_LEVELS = 12 -- 207
____exports.SLIDE_FRAME_COUNT = 64 -- 208
local ATLAS_GUTTER = 2 -- 209
local RUN_ATLASES = {soldier = {path = "assets/art/zhoushu-run.png", width = 180, height = 200, columns = 10}, child = {path = "assets/art/xiaoman-run.png", width = 144, height = 164, columns = 10}} -- 218
local RUN_TRANSITIONS = { -- 222
	soldier = __TS__ObjectAssign({}, RUN_ATLASES.soldier, {path = "assets/art/zhoushu-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}), -- 223
	child = __TS__ObjectAssign({}, RUN_ATLASES.child, {path = "assets/art/xiaoman-run-transition.png", columns = ____exports.RUN_TRANSITION_PHASES}) -- 224
} -- 224
local SLIDE_ATLAS = {path = "assets/art/zhoushu-slide.png", width = 300, height = 198, columns = 8} -- 226
____exports.ASSET_SLOTS = { -- 230
	bgFar_prologue = backdrop("prologue"), -- 231
	bgFar_street = backdrop("street"), -- 232
	bgFar_checkpoint = backdrop("checkpoint"), -- 233
	bgFar_gate = backdrop("gate"), -- 234
	bgFar_outside = backdrop("outside"), -- 235
	bgFar_village = backdrop("village"), -- 236
	bgFar_forest = backdrop("forest"), -- 237
	bgFar_tower = backdrop("tower"), -- 238
	bgFar_crossroad_drygoods = backdrop("bg_crossroad_drygoods"), -- 239
	bgFar_archway_yard = backdrop("bg_archway_yard"), -- 240
	bgFar_granary = backdrop("bg_granary"), -- 241
	bgFar_escort_ridge = backdrop("bg_escort_ridge"), -- 242
	bgFar_museum = backdrop("bg_museum_hall", true), -- 243
	title_backdrop = backdrop("title"), -- 244
	soldier_idle = character("soldier_idle"), -- 245
	soldier_run = character({"soldier_run", "soldier_step"}), -- 246
	soldier_roll = character("soldier_roll"), -- 247
	soldier_slide = character({"soldier_slide_0", "soldier_slide_1", "soldier_slide_2", "soldier_slide_3"}), -- 248
	soldier_cover = character("soldier_cover"), -- 249
	soldier_push = character({"soldier_push", "soldier_push_step"}), -- 250
	soldier_hold = character("soldier_hold"), -- 251
	soldier_offer = character("soldier_offer"), -- 252
	soldier_knock = character({"soldier_cover", "soldier_knock"}), -- 253
	soldier_hit = character("soldier_hit"), -- 254
	soldier_fire = character("soldier_fire"), -- 255
	soldier_fire_move = character({"soldier_fire_run", "soldier_fire", "soldier_fire_run_step", "soldier_fire"}), -- 256
	child_idle = character("child_idle"), -- 257
	child_run = character({"child_run", "child_step"}), -- 258
	child_crouch = character({"child_crouch", "child_crouch_step"}), -- 259
	child_fear = character("child_fear"), -- 260
	child_peek = character("child_peek"), -- 261
	child_pull = character({"child_pull", "child_pull_step"}), -- 262
	child_aim = character("child_aim"), -- 263
	child_throw = character("child_throw"), -- 264
	child_knock = character("child_knock"), -- 265
	child_offer = character("child_offer"), -- 266
	enemy_idle = actor("enemy_idle", 0.5), -- 267
	enemy_aim = actor("enemy_aim", 0.51), -- 268
	enemy_down = actor("enemy_down"), -- 269
	enemy_hit = actor("enemy_hit", 0.48), -- 270
	scavenger = actor({"scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run"}, {0.52, 0.52, 0.48, 0.52}), -- 271
	dog = actor({"dog_idle", "dog_alert", "dog_run", "dog_sniff"}, {0.5, 0.5, 0.54, 0.58}), -- 272
	prop_cart = clip("cart", 0, false, 0.44), -- 273
	prop_bottle = clip("bottle", 0.5, true), -- 274
	prop_tower_door = clip("door"), -- 275
	prop_lantern = clip("lantern", 0.5, true), -- 276
	prop_table = clip("table"), -- 277
	prop_compass = clip("compass", 0.5, true), -- 278
	prop_winch = clip("winch", 0.5, true), -- 279
	wall = clip("wall"), -- 280
	cover_wood = clip("cover_wood"), -- 281
	cover_stone = clip("cover_stone"), -- 282
	fence = clip("fence"), -- 283
	slab = clip("slab"), -- 284
	eaves = clip("eaves"), -- 285
	pine = clip("pine"), -- 286
	grass = clip("grass"), -- 287
	grass_low = clip("grass_low"), -- 288
	stone_chips = clip("stone_chips", 0.5, true), -- 289
	ui_corner = clip("ui_corner"), -- 290
	ui_corner_c = clip("ui_corner", 0.5, false), -- 291
	ui_paper = clip("paper", 0.5), -- 292
	ink_ribbon_sweep = inkClip("ink_ribbon_sweep"), -- 293
	ink_mist_curve = inkClip("ink_mist_curve"), -- 294
	ink_veil_strip = inkClip("ink_veil_strip"), -- 295
	ink_hairline = inkClip("ink_hairline"), -- 296
	ink_bamboo_slip = inkClip("ink_bamboo_slip"), -- 297
	ink_bamboo_slot = inkClip("ink_bamboo_slot"), -- 298
	ink_frame_mask = inkClip("ink_frame_mask"), -- 299
	ink_vstream = inkClip("ink_vstream"), -- 300
	ink_knot_ornament = inkClip("ink_knot_ornament"), -- 301
	ink_corner_fine = inkClip("ink_corner_fine"), -- 302
	ink_seal_slender = inkClip("ink_seal_slender"), -- 303
	ink_blossom_dot = inkClip("ink_blossom_dot"), -- 304
	ink_enso_fine = inkClip("ink_enso_fine"), -- 305
	ink_petal_mist = inkClip("ink_petal_mist"), -- 306
	ink_song_paper = inkClip("ink_song_paper"), -- 307
	brand_game_logo_h = {paths = {"assets/art/brand/game_logo_h.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 308
	brand_game_logo_v = {paths = {"assets/art/brand/game_logo_v.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 309
	brand_team_logo = {paths = {"assets/art/brand/team_logo_dark.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 310
	brand_team_badge = {paths = {"assets/art/brand/team_badge.png"}, anchorY = 0.5, preserveAspect = true, smooth = true}, -- 311
	slide_p01_01 = slide("p01_01_curtain"), -- 313
	slide_p01_02 = slide("p01_02_hand"), -- 314
	slide_p01_03 = slide("p01_03_door"), -- 315
	slide_p02_01 = slide("p02_01_shadows"), -- 316
	slide_p02_02 = slide("p02_02_cut"), -- 317
	slide_p02_03 = slide("p02_03_bowl_roll"), -- 318
	slide_p02_04 = slide("p02_04_bowl_stop"), -- 319
	slide_p02_05 = slide("p02_05_cabinet"), -- 320
	slide_cuff_p03_01 = slide("cuff_p03_01"), -- 321
	slide_cuff_p03_02 = slide("cuff_p03_02"), -- 322
	slide_cuff_p03_03 = slide("cuff_p03_03"), -- 323
	slide_cuff_p03_04 = slide("cuff_p03_04"), -- 324
	slide_cuff_p05_01 = slide("cuff_p05_01"), -- 325
	slide_cuff_p05_02 = slide("cuff_p05_02"), -- 326
	slide_cuff_p05_03 = slide("cuff_p05_03"), -- 327
	slide_cuff_p05_04 = slide("cuff_p05_04"), -- 328
	slide_cuff_g05_01 = slide("cuff_g05_01"), -- 329
	slide_cuff_g05_02 = slide("cuff_g05_02"), -- 330
	slide_cuff_g05_03 = slide("cuff_g05_03"), -- 331
	slide_cuff_g05_04 = slide("cuff_g05_04"), -- 332
	slide_gate_01 = {paths = {"assets/art/slides/gate_stage_01.png"}, anchorY = 0, preserveAspect = false}, -- 333
	slide_gate_02 = {paths = {"assets/art/slides/gate_stage_02.png"}, anchorY = 0, preserveAspect = false}, -- 334
	slide_gate_03 = {paths = {"assets/art/slides/gate_stage_03.png"}, anchorY = 0, preserveAspect = false}, -- 335
	slide_gate_04 = {paths = {"assets/art/slides/gate_stage_04.png"}, anchorY = 0, preserveAspect = false}, -- 336
	slide_tower_porch_f03_closed = slide("tower_porch_f03_closed"), -- 337
	slide_tower_porch_f03_open = slide("tower_porch_f03_open"), -- 338
	slide_tower_porch_m03_closed = slide("tower_porch_m03_closed"), -- 339
	slide_tower_porch_m03_open = slide("tower_porch_m03_open"), -- 340
	slide_tower_room_f03_cold = slide("tower_room_f03_cold"), -- 341
	slide_tower_room_f03_lit = slide("tower_room_f03_lit"), -- 342
	slide_tower_room_m03_warm = slide("tower_room_m03_warm"), -- 343
	slide_tower_interior_live = {paths = {"assets/art/slides/tower_interior_live.png"}, anchorY = 0, preserveAspect = false}, -- 344
	slide_e01_well = slide("e01_01_well"), -- 345
	slide_e01_compass = slide("e01_02_compass"), -- 346
	slide_e01_vitrine = slide("e01_03_vitrine"), -- 347
	slide_e02_museum_hall = {paths = {"assets/art/slides/e02_museum_hall.png"}, anchorY = 0, preserveAspect = false}, -- 348
	slide_e02_window_dawn = slide("e02_window_dawn"), -- 349
	slide_e02_return_cabinet = slide("e02_return_cabinet"), -- 350
	slide_f01_sewing = slide("f01_sewing_memory"), -- 351
	slide_m02_lantern_gun = slide("m02_handover_lantern"), -- 352
	slide_m02_echo_gun = slide("m02_handover_echo"), -- 353
	comic_p01_01_curtain_dark = comicCutscene("p01/p01_01_curtain_dark"), -- 355
	comic_p01_02_curtain_glow = comicCutscene("p01/p01_02_curtain_glow"), -- 356
	comic_p01_03_hand_bedrail = comicCutscene("p01/p01_03_hand_bedrail"), -- 357
	comic_p01_04_look_door = comicCutscene("p01/p01_04_look_door"), -- 358
	comic_p01_f01 = comicCutscene("p01/p01_f01"), -- 359
	comic_p01_f02 = comicCutscene("p01/p01_f02"), -- 360
	comic_p01_f03 = comicCutscene("p01/p01_f03"), -- 361
	comic_p01_f04 = comicCutscene("p01/p01_f04"), -- 362
	comic_p01_f05 = comicCutscene("p01/p01_f05"), -- 363
	comic_p01_f06 = comicCutscene("p01/p01_f06"), -- 364
	comic_p01_f07 = comicCutscene("p01/p01_f07"), -- 365
	comic_p01_f08 = comicCutscene("p01/p01_f08"), -- 366
	comic_p01_f09 = comicCutscene("p01/p01_f09"), -- 367
	comic_p01_f10 = comicCutscene("p01/p01_f10"), -- 368
	comic_p01_f11 = comicCutscene("p01/p01_f11"), -- 369
	comic_p01_f12 = comicCutscene("p01/p01_f12"), -- 370
	comic_p01_f13 = comicCutscene("p01/p01_f13"), -- 371
	comic_p01_f14 = comicCutscene("p01/p01_f14"), -- 372
	comic_p01_f15 = comicCutscene("p01/p01_f15"), -- 373
	comic_p01_f16 = comicCutscene("p01/p01_f16"), -- 374
	comic_p01_f17 = comicCutscene("p01/p01_f17"), -- 375
	comic_p01_f18 = comicCutscene("p01/p01_f18"), -- 376
	comic_p01_f19 = comicCutscene("p01/p01_f19"), -- 377
	comic_p01_f20 = comicCutscene("p01/p01_f20"), -- 378
	comic_p01_f21 = comicCutscene("p01/p01_f21"), -- 379
	comic_p01_f22 = comicCutscene("p01/p01_f22"), -- 380
	comic_p02_01_shadows = comicCutscene("p02/p02_01_shadows"), -- 381
	comic_p02_02a_door_intrude = comicCutscene("p02/p02_02a_door_intrude"), -- 382
	comic_p02_03_impact_cut = comicCutscene("p02/p02_03_impact_cut"), -- 383
	comic_p02_04_shadows_fall = comicCutscene("p02/p02_04_shadows_fall"), -- 384
	comic_p02_05_bowl_roll1 = comicCutscene("p02/p02_05_bowl_roll1"), -- 385
	comic_p02_06_bowl_roll2 = comicCutscene("p02/p02_06_bowl_roll2"), -- 386
	comic_p02_07_bowl_smash = comicCutscene("p02/p02_07_bowl_smash"), -- 387
	comic_p02_08a_cabinet_slit = comicCutscene("p02/p02_08a_cabinet_slit"), -- 388
	comic_p02_08m_cabinet_narrowing = comicCutscene("p02/p02_08m_cabinet_narrowing"), -- 389
	comic_p02_08b_cabinet_shut = comicCutscene("p02/p02_08b_cabinet_shut"), -- 390
	comic_p02_f01 = comicCutscene("p02/p02_f01"), -- 391
	comic_p02_f02 = comicCutscene("p02/p02_f02"), -- 392
	comic_p02_f03 = comicCutscene("p02/p02_f03"), -- 393
	comic_p02_f04 = comicCutscene("p02/p02_f04"), -- 394
	comic_p02_f05 = comicCutscene("p02/p02_f05"), -- 395
	comic_p02_f06 = comicCutscene("p02/p02_f06"), -- 396
	comic_p02_f07 = comicCutscene("p02/p02_f07"), -- 397
	comic_p02_f08 = comicCutscene("p02/p02_f08"), -- 398
	comic_p02_f09 = comicCutscene("p02/p02_f09"), -- 399
	comic_p02_f10 = comicCutscene("p02/p02_f10"), -- 400
	comic_p02_f11 = comicCutscene("p02/p02_f11"), -- 401
	comic_p02_f12 = comicCutscene("p02/p02_f12"), -- 402
	comic_p02_f13 = comicCutscene("p02/p02_f13"), -- 403
	comic_p02_f14 = comicCutscene("p02/p02_f14"), -- 404
	comic_p02_f15 = comicCutscene("p02/p02_f15"), -- 405
	comic_p02_f16 = comicCutscene("p02/p02_f16"), -- 406
	comic_p02_f17 = comicCutscene("p02/p02_f17"), -- 407
	comic_p02_f18 = comicCutscene("p02/p02_f18"), -- 408
	comic_p02_f19 = comicCutscene("p02/p02_f19"), -- 409
	comic_p02_f20 = comicCutscene("p02/p02_f20"), -- 410
	comic_p02_f21 = comicCutscene("p02/p02_f21"), -- 411
	comic_p02_f22 = comicCutscene("p02/p02_f22"), -- 412
	comic_p02_f23 = comicCutscene("p02/p02_f23"), -- 413
	comic_p02_f24 = comicCutscene("p02/p02_f24"), -- 414
	comic_p02_f25 = comicCutscene("p02/p02_f25"), -- 415
	comic_p02_f26 = comicCutscene("p02/p02_f26"), -- 416
	comic_p02_f27 = comicCutscene("p02/p02_f27"), -- 417
	comic_p02_f28 = comicCutscene("p02/p02_f28"), -- 418
	comic_p02_f29 = comicCutscene("p02/p02_f29"), -- 419
	comic_p02_f30 = comicCutscene("p02/p02_f30"), -- 420
	comic_p02_f31 = comicCutscene("p02/p02_f31"), -- 421
	comic_p02_f32 = comicCutscene("p02/p02_f32"), -- 422
	comic_p02_f33 = comicCutscene("p02/p02_f33"), -- 423
	comic_p03_01_two_fingers = comicCutscene("p03/p03_01_two_fingers"), -- 424
	comic_p03_02_cuff_enter = comicCutscene("p03/p03_02_cuff_enter"), -- 425
	comic_p03_03_cuff_wipe = comicCutscene("p03/p03_03_cuff_wipe"), -- 426
	comic_p03_04_hand_meet = comicCutscene("p03/p03_04_hand_meet"), -- 427
	comic_p03_f01 = comicCutscene("p03/p03_f01"), -- 428
	comic_p03_f02 = comicCutscene("p03/p03_f02"), -- 429
	comic_p03_f03 = comicCutscene("p03/p03_f03"), -- 430
	comic_p03_f04 = comicCutscene("p03/p03_f04"), -- 431
	comic_p03_f05 = comicCutscene("p03/p03_f05"), -- 432
	comic_p03_f06 = comicCutscene("p03/p03_f06"), -- 433
	comic_p03_f07 = comicCutscene("p03/p03_f07"), -- 434
	comic_p03_f08 = comicCutscene("p03/p03_f08"), -- 435
	comic_p03_f09 = comicCutscene("p03/p03_f09"), -- 436
	comic_p03_f10 = comicCutscene("p03/p03_f10"), -- 437
	comic_p03_f11 = comicCutscene("p03/p03_f11"), -- 438
	comic_p03_f12 = comicCutscene("p03/p03_f12"), -- 439
	comic_p03_f13 = comicCutscene("p03/p03_f13"), -- 440
	comic_p03_f14 = comicCutscene("p03/p03_f14"), -- 441
	comic_p03_f15 = comicCutscene("p03/p03_f15"), -- 442
	comic_p03_f16 = comicCutscene("p03/p03_f16"), -- 443
	comic_p03_f17 = comicCutscene("p03/p03_f17"), -- 444
	comic_p03_f18 = comicCutscene("p03/p03_f18"), -- 445
	comic_p03_f19 = comicCutscene("p03/p03_f19"), -- 446
	comic_p03_f20 = comicCutscene("p03/p03_f20"), -- 447
	comic_p03_f21 = comicCutscene("p03/p03_f21"), -- 448
	comic_p03_f22 = comicCutscene("p03/p03_f22"), -- 449
	comic_p03_f23 = comicCutscene("p03/p03_f23"), -- 450
	comic_p03_f24 = comicCutscene("p03/p03_f24"), -- 451
	comic_p05_01_clutch_cuff = comicCutscene("p05/p05_01_clutch_cuff"), -- 452
	comic_p05_02_brother_pinch = comicCutscene("p05/p05_02_brother_pinch"), -- 453
	comic_p05_03_sleeve_pull = comicCutscene("p05/p05_03_sleeve_pull"), -- 454
	comic_p05_04_gate_drop = comicCutscene("p05/p05_04_gate_drop"), -- 455
	comic_p05_05_gate_slam_impact = comicCutscene("p05/p05_05_gate_slam_impact"), -- 456
	comic_p05_06_open_fingers = comicCutscene("p05/p05_06_open_fingers"), -- 457
	comic_p05_f01 = comicCutscene("p05/p05_f01"), -- 458
	comic_p05_f02 = comicCutscene("p05/p05_f02"), -- 459
	comic_p05_f03 = comicCutscene("p05/p05_f03"), -- 460
	comic_p05_f04 = comicCutscene("p05/p05_f04"), -- 461
	comic_p05_f05 = comicCutscene("p05/p05_f05"), -- 462
	comic_p05_f06 = comicCutscene("p05/p05_f06"), -- 463
	comic_p05_f07 = comicCutscene("p05/p05_f07"), -- 464
	comic_p05_f08 = comicCutscene("p05/p05_f08"), -- 465
	comic_p05_f09 = comicCutscene("p05/p05_f09"), -- 466
	comic_p05_f10 = comicCutscene("p05/p05_f10"), -- 467
	comic_p05_f11 = comicCutscene("p05/p05_f11"), -- 468
	comic_p05_f12 = comicCutscene("p05/p05_f12"), -- 469
	comic_p05_f13 = comicCutscene("p05/p05_f13"), -- 470
	comic_p05_f14 = comicCutscene("p05/p05_f14"), -- 471
	comic_p05_f15 = comicCutscene("p05/p05_f15"), -- 472
	comic_p05_f16 = comicCutscene("p05/p05_f16"), -- 473
	comic_p05_f17 = comicCutscene("p05/p05_f17"), -- 474
	comic_g05_01_cuff_peek = comicCutscene("g05/g05_01_cuff_peek"), -- 475
	comic_g05_02_cuff_extend = comicCutscene("g05/g05_02_cuff_extend"), -- 476
	comic_g05_03_hands_meet = comicCutscene("g05/g05_03_hands_meet"), -- 477
	comic_g05_04_hands_clasp = comicCutscene("g05/g05_04_hands_clasp"), -- 478
	comic_g05_05_tilt_arm = comicCutscene("g05/g05_05_tilt_arm"), -- 479
	comic_g05_06_tilt_shoulder = comicCutscene("g05/g05_06_tilt_shoulder"), -- 480
	comic_g05_07_zhoushu_reveal = comicCutscene("g05/g05_07_zhoushu_reveal"), -- 481
	comic_g05_08_zhoushu_warm = comicCutscene("g05/g05_08_zhoushu_warm"), -- 482
	comic_g05_f01 = comicCutscene("g05/g05_f01"), -- 483
	comic_g05_f02 = comicCutscene("g05/g05_f02"), -- 484
	comic_g05_f03 = comicCutscene("g05/g05_f03"), -- 485
	comic_g05_f04 = comicCutscene("g05/g05_f04"), -- 486
	comic_g05_f05 = comicCutscene("g05/g05_f05"), -- 487
	comic_g05_f06 = comicCutscene("g05/g05_f06"), -- 488
	comic_g05_f07 = comicCutscene("g05/g05_f07"), -- 489
	comic_g05_f08 = comicCutscene("g05/g05_f08"), -- 490
	comic_g05_f09 = comicCutscene("g05/g05_f09"), -- 491
	comic_g05_f10 = comicCutscene("g05/g05_f10"), -- 492
	comic_g05_f11 = comicCutscene("g05/g05_f11"), -- 493
	comic_g05_f12 = comicCutscene("g05/g05_f12"), -- 494
	comic_g05_f13 = comicCutscene("g05/g05_f13"), -- 495
	comic_g05_f14 = comicCutscene("g05/g05_f14"), -- 496
	comic_g05_f15 = comicCutscene("g05/g05_f15"), -- 497
	comic_g05_f16 = comicCutscene("g05/g05_f16"), -- 498
	comic_g05_f17 = comicCutscene("g05/g05_f17"), -- 499
	comic_g05_f18 = comicCutscene("g05/g05_f18"), -- 500
	comic_g05_f19 = comicCutscene("g05/g05_f19"), -- 501
	comic_g05_f20 = comicCutscene("g05/g05_f20"), -- 502
	comic_gate_01_beam = {paths = {"assets/art/cutscenes/gate/gate_01_beam.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 503
	comic_gate_02_dock = {paths = {"assets/art/cutscenes/gate/gate_02_dock.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 504
	comic_gate_03_fog = {paths = {"assets/art/cutscenes/gate/gate_03_fog.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 505
	comic_gate_04_terrace = {paths = {"assets/art/cutscenes/gate/gate_04_terrace.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 506
	comic_gate_f01 = {paths = {"assets/art/cutscenes/gate/gate_f01.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 507
	comic_gate_f02 = {paths = {"assets/art/cutscenes/gate/gate_f02.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 508
	comic_gate_f03 = {paths = {"assets/art/cutscenes/gate/gate_f03.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 509
	comic_gate_f04 = {paths = {"assets/art/cutscenes/gate/gate_f04.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 510
	comic_gate_f05 = {paths = {"assets/art/cutscenes/gate/gate_f05.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 511
	comic_gate_f06 = {paths = {"assets/art/cutscenes/gate/gate_f06.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 512
	comic_gate_f07 = {paths = {"assets/art/cutscenes/gate/gate_f07.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 513
	comic_gate_f08 = {paths = {"assets/art/cutscenes/gate/gate_f08.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 514
	comic_gate_f09 = {paths = {"assets/art/cutscenes/gate/gate_f09.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 515
	comic_gate_f10 = {paths = {"assets/art/cutscenes/gate/gate_f10.png"}, anchorY = 0, preserveAspect = false, smooth = true}, -- 516
	comic_f01_01_thumb_cloth = comicCutscene("f01/f01_01_thumb_cloth"), -- 517
	comic_f01_02_needle_pierce = comicCutscene("f01/f01_02_needle_pierce"), -- 518
	comic_f01_03_thread_pull = comicCutscene("f01/f01_03_thread_pull"), -- 519
	comic_f01_04_stitch_smooth = comicCutscene("f01/f01_04_stitch_smooth"), -- 520
	comic_f01_f01 = comicCutscene("f01/f01_f01"), -- 521
	comic_f01_f02 = comicCutscene("f01/f01_f02"), -- 522
	comic_f01_f03 = comicCutscene("f01/f01_f03"), -- 523
	comic_f01_f04 = comicCutscene("f01/f01_f04"), -- 524
	comic_f01_f05 = comicCutscene("f01/f01_f05"), -- 525
	comic_f01_f06 = comicCutscene("f01/f01_f06"), -- 526
	comic_f01_f07 = comicCutscene("f01/f01_f07"), -- 527
	comic_f01_f08 = comicCutscene("f01/f01_f08"), -- 528
	comic_f01_f09 = comicCutscene("f01/f01_f09"), -- 529
	comic_f01_f10 = comicCutscene("f01/f01_f10"), -- 530
	comic_f01_f11 = comicCutscene("f01/f01_f11"), -- 531
	comic_f01_f12 = comicCutscene("f01/f01_f12"), -- 532
	comic_m02_lantern_01_offer = comicCutscene("m02/m02_lantern_01_offer"), -- 533
	comic_m02_lantern_02_grip = comicCutscene("m02/m02_lantern_02_grip"), -- 534
	comic_m02_lantern_03_heft = comicCutscene("m02/m02_lantern_03_heft"), -- 535
	comic_m02_lantern_04_ready = comicCutscene("m02/m02_lantern_04_ready"), -- 536
	comic_m02_lantern_f01 = comicCutscene("m02/m02_lantern_f01"), -- 537
	comic_m02_lantern_f02 = comicCutscene("m02/m02_lantern_f02"), -- 538
	comic_m02_lantern_f03 = comicCutscene("m02/m02_lantern_f03"), -- 539
	comic_m02_lantern_f04 = comicCutscene("m02/m02_lantern_f04"), -- 540
	comic_m02_lantern_f05 = comicCutscene("m02/m02_lantern_f05"), -- 541
	comic_m02_lantern_f06 = comicCutscene("m02/m02_lantern_f06"), -- 542
	comic_m02_lantern_f07 = comicCutscene("m02/m02_lantern_f07"), -- 543
	comic_m02_lantern_f08 = comicCutscene("m02/m02_lantern_f08"), -- 544
	comic_m02_lantern_f09 = comicCutscene("m02/m02_lantern_f09"), -- 545
	comic_m02_lantern_f10 = comicCutscene("m02/m02_lantern_f10"), -- 546
	comic_m02_lantern_f11 = comicCutscene("m02/m02_lantern_f11"), -- 547
	comic_m02_lantern_f12 = comicCutscene("m02/m02_lantern_f12"), -- 548
	comic_m02_echo_01_offer = comicCutscene("m02/m02_echo_01_offer"), -- 549
	comic_m02_echo_02_grip = comicCutscene("m02/m02_echo_02_grip"), -- 550
	comic_m02_echo_03_heft = comicCutscene("m02/m02_echo_03_heft"), -- 551
	comic_m02_echo_04_ready = comicCutscene("m02/m02_echo_04_ready"), -- 552
	comic_m02_echo_f01 = comicCutscene("m02/m02_echo_f01"), -- 553
	comic_m02_echo_f02 = comicCutscene("m02/m02_echo_f02"), -- 554
	comic_m02_echo_f03 = comicCutscene("m02/m02_echo_f03"), -- 555
	comic_m02_echo_f04 = comicCutscene("m02/m02_echo_f04"), -- 556
	comic_m02_echo_f05 = comicCutscene("m02/m02_echo_f05"), -- 557
	comic_m02_echo_f06 = comicCutscene("m02/m02_echo_f06"), -- 558
	comic_m02_echo_f07 = comicCutscene("m02/m02_echo_f07"), -- 559
	comic_m02_echo_f08 = comicCutscene("m02/m02_echo_f08"), -- 560
	comic_m02_echo_f09 = comicCutscene("m02/m02_echo_f09"), -- 561
	comic_m02_echo_f10 = comicCutscene("m02/m02_echo_f10"), -- 562
	comic_m02_echo_f11 = comicCutscene("m02/m02_echo_f11"), -- 563
	comic_tower_f03_porch_01_knock = comicCutscene("tower/f03_porch_01_knock"), -- 564
	comic_tower_f03_porch_02_open = comicCutscene("tower/f03_porch_02_open"), -- 565
	comic_tower_m03_porch_01_knock = comicCutscene("tower/m03_porch_01_knock"), -- 566
	comic_tower_m03_porch_02_open = comicCutscene("tower/m03_porch_02_open"), -- 567
	comic_tower_f03_room_01_cold = comicCutscene("tower/f03_room_01_cold"), -- 568
	comic_tower_f03_room_02_hover = comicCutscene("tower/f03_room_02_hover"), -- 569
	comic_tower_f03_room_03_move_lamp = comicCutscene("tower/f03_room_03_move_lamp"), -- 570
	comic_tower_f03_room_04_lit_bowl = comicCutscene("tower/f03_room_04_lit_bowl"), -- 571
	comic_tower_m03_room_01_warm = comicCutscene("tower/m03_room_01_warm"), -- 572
	comic_tower_m03_room_02_speak = comicCutscene("tower/m03_room_02_speak"), -- 573
	comic_tower_m03_room_03_pouch = comicCutscene("tower/m03_room_03_pouch"), -- 574
	comic_tower_m03_room_04_bowl = comicCutscene("tower/m03_room_04_bowl"), -- 575
	comic_f03_f01 = comicCutscene("tower/f03_f01"), -- 576
	comic_f03_f02 = comicCutscene("tower/f03_f02"), -- 577
	comic_f03_f03 = comicCutscene("tower/f03_f03"), -- 578
	comic_f03_f04 = comicCutscene("tower/f03_f04"), -- 579
	comic_f03_f05 = comicCutscene("tower/f03_f05"), -- 580
	comic_f03_f06 = comicCutscene("tower/f03_f06"), -- 581
	comic_f03_f07 = comicCutscene("tower/f03_f07"), -- 582
	comic_f03_f08 = comicCutscene("tower/f03_f08"), -- 583
	comic_f03_f09 = comicCutscene("tower/f03_f09"), -- 584
	comic_f03_f10 = comicCutscene("tower/f03_f10"), -- 585
	comic_f03_f11 = comicCutscene("tower/f03_f11"), -- 586
	comic_f03_f12 = comicCutscene("tower/f03_f12"), -- 587
	comic_f03_f13 = comicCutscene("tower/f03_f13"), -- 588
	comic_f03_f14 = comicCutscene("tower/f03_f14"), -- 589
	comic_f03_f15 = comicCutscene("tower/f03_f15"), -- 590
	comic_f03_f16 = comicCutscene("tower/f03_f16"), -- 591
	comic_f03_f17 = comicCutscene("tower/f03_f17"), -- 592
	comic_f03_f18 = comicCutscene("tower/f03_f18"), -- 593
	comic_f03_f19 = comicCutscene("tower/f03_f19"), -- 594
	comic_f03_f20 = comicCutscene("tower/f03_f20"), -- 595
	comic_m03_f01 = comicCutscene("tower/m03_f01"), -- 596
	comic_m03_f02 = comicCutscene("tower/m03_f02"), -- 597
	comic_m03_f03 = comicCutscene("tower/m03_f03"), -- 598
	comic_m03_f04 = comicCutscene("tower/m03_f04"), -- 599
	comic_m03_f05 = comicCutscene("tower/m03_f05"), -- 600
	comic_m03_f06 = comicCutscene("tower/m03_f06"), -- 601
	comic_m03_f07 = comicCutscene("tower/m03_f07"), -- 602
	comic_m03_f08 = comicCutscene("tower/m03_f08"), -- 603
	comic_m03_f09 = comicCutscene("tower/m03_f09"), -- 604
	comic_m03_f10 = comicCutscene("tower/m03_f10"), -- 605
	comic_m03_f11 = comicCutscene("tower/m03_f11"), -- 606
	comic_m03_f12 = comicCutscene("tower/m03_f12"), -- 607
	comic_m03_f13 = comicCutscene("tower/m03_f13"), -- 608
	comic_m03_f14 = comicCutscene("tower/m03_f14"), -- 609
	comic_m03_f15 = comicCutscene("tower/m03_f15"), -- 610
	comic_m03_f16 = comicCutscene("tower/m03_f16"), -- 611
	comic_m03_f17 = comicCutscene("tower/m03_f17"), -- 612
	comic_m03_f18 = comicCutscene("tower/m03_f18"), -- 613
	comic_m03_f19 = comicCutscene("tower/m03_f19"), -- 614
	comic_m03_f20 = comicCutscene("tower/m03_f20"), -- 615
	comic_museum_e01_01_well_water = comicCutscene("museum/e01_01_well_water"), -- 616
	comic_museum_e01_02_compass_align = comicCutscene("museum/e01_02_compass_align"), -- 617
	comic_museum_e01_03_match_flash = comicCutscene("museum/e01_03_match_flash"), -- 618
	comic_museum_e01_04_vitrine_emerge = comicCutscene("museum/e01_04_vitrine_emerge"), -- 619
	comic_e01_f01 = comicCutscene("museum/e01_f01"), -- 620
	comic_e01_f02 = comicCutscene("museum/e01_f02"), -- 621
	comic_e01_f03 = comicCutscene("museum/e01_f03"), -- 622
	comic_e01_f04 = comicCutscene("museum/e01_f04"), -- 623
	comic_e01_f05 = comicCutscene("museum/e01_f05"), -- 624
	comic_e01_f06 = comicCutscene("museum/e01_f06"), -- 625
	comic_e01_f07 = comicCutscene("museum/e01_f07"), -- 626
	comic_e01_f08 = comicCutscene("museum/e01_f08"), -- 627
	comic_e01_f09 = comicCutscene("museum/e01_f09"), -- 628
	comic_e01_f10 = comicCutscene("museum/e01_f10"), -- 629
	comic_e01_f11 = comicCutscene("museum/e01_f11"), -- 630
	comic_e01_f12 = comicCutscene("museum/e01_f12"), -- 631
	comic_e01_f13 = comicCutscene("museum/e01_f13"), -- 632
	comic_e01_f14 = comicCutscene("museum/e01_f14"), -- 633
	comic_e01_f15 = comicCutscene("museum/e01_f15"), -- 634
	comic_e01_f16 = comicCutscene("museum/e01_f16"), -- 635
	comic_museum_e02_01_west_window = comicCutscene("museum/e02_01_west_window"), -- 636
	comic_museum_e02_02_lamp_turn = comicCutscene("museum/e02_02_lamp_turn"), -- 637
	comic_museum_e02_03_dawn_well_reflect = comicCutscene("museum/e02_03_dawn_well_reflect"), -- 638
	comic_museum_e02_04_cabinet_cuff_return = comicCutscene("museum/e02_04_cabinet_cuff_return"), -- 639
	comic_e02_f01 = comicCutscene("museum/e02_f01"), -- 640
	comic_e02_f02 = comicCutscene("museum/e02_f02"), -- 641
	comic_e02_f03 = comicCutscene("museum/e02_f03"), -- 642
	comic_e02_f04 = comicCutscene("museum/e02_f04"), -- 643
	comic_e02_f05 = comicCutscene("museum/e02_f05"), -- 644
	comic_e02_f06 = comicCutscene("museum/e02_f06"), -- 645
	comic_e02_f07 = comicCutscene("museum/e02_f07"), -- 646
	comic_e02_f08 = comicCutscene("museum/e02_f08"), -- 647
	comic_e02_f09 = comicCutscene("museum/e02_f09"), -- 648
	comic_e02_f10 = comicCutscene("museum/e02_f10"), -- 649
	comic_e02_f11 = comicCutscene("museum/e02_f11"), -- 650
	comic_e02_f12 = comicCutscene("museum/e02_f12"), -- 651
	comic_e02_f13 = comicCutscene("museum/e02_f13"), -- 652
	comic_e02_f14 = comicCutscene("museum/e02_f14"), -- 653
	comic_e02_f15 = comicCutscene("museum/e02_f15"), -- 654
	comic_e02_f16 = comicCutscene("museum/e02_f16"), -- 655
	comic_e02_f17 = comicCutscene("museum/e02_f17"), -- 656
	comic_e02_f18 = comicCutscene("museum/e02_f18"), -- 657
	comic_e02_f19 = comicCutscene("museum/e02_f19"), -- 658
	comic_e02_f20 = comicCutscene("museum/e02_f20"), -- 659
	fe_carry_idle = feClip("carry_idle", 0, true, 0.5), -- 661
	fe_carry_walk = feClip({"carry_walk_a", "carry_idle", "carry_walk_b", "carry_idle"}, 0, true, {0.5, 0.5, 0.5, 0.5}), -- 662
	fe_carry_reload = feClip("carry_reload", 0, true, 0.48), -- 663
	fe_soldier_kneel_mount = feClip("soldier_kneel_mount", 0, true, 0.5), -- 664
	fe_child_listen_door = feClip("child_listen_door", 0, true, 0.5), -- 665
	fe_soldier_hand_hold = feClip("soldier_hand_hold", 0, true, 0.5), -- 666
	fe_tower_guard_lantern = feClip("tower_guard_lantern", 0, true, 0.5), -- 667
	fe_tower_brush_hand = feClip("tower_brush_hand", 0.08, true, 0.06), -- 668
	fe_reload_hand_tap = feClip("reload_hand_tap", 0.9, true, 0.14), -- 669
	fe_reload_hand_trace = feClip("reload_hand_trace", 0.58, true, 0.92), -- 670
	fe_tower_cuff_rest = feClip("tower_cuff_rest", 0.5, true, 0.05), -- 671
	fe_tower_bowl_solo = feClip("tower_bowl_solo", 0.25, true, 0.5), -- 672
	fe_tower_bowl_hands = feClip("tower_bowl_hands", 0.4, true, 0.5), -- 673
	fe_tower_pouch_note = feClip("tower_pouch_note", 0.42, true, 0.5), -- 674
	fe_tower_lantern_detail = feClip("tower_lantern_detail", 0.14, true, 0.5), -- 675
	fe_basin_flat = feClip("prop_basin_flat", 0, true, 0.5), -- 676
	fe_basin_tilt = feClip("prop_basin_tilt", 0, true, 0.5), -- 677
	fe_well_rim = feClip("prop_well_rim", 0, true, 0.5), -- 678
	fe_outside_arch = feClip("prop_outside_arch", 0, false, 0.5), -- 679
	fe_straw_target = feClip("prop_straw_target", 0, true, 0.5), -- 680
	fe_workbench = feClip("prop_workbench", 0, false, 0.5), -- 681
	fe_bottle_rack = feClip("prop_bottle_rack", 0, true, 0.5), -- 682
	fe_braced_shield = feClip("prop_braced_shield", 0, true, 0.5), -- 683
	fe_weapon_lantern_gun = feClip("weapon_lantern_gun", 0.5, true, 0.5), -- 684
	fe_weapon_echo_gun = feClip("weapon_echo_gun", 0.5, true, 0.5), -- 685
	fe_lamp_bracket = feClip("prop_lamp_bracket", 0, true, 0.5), -- 686
	fe_icon_wood_tally = feClip("icon_wood_tally", 0.5, true, 0.5), -- 687
	fe_icon_bell_tally = feClip("icon_bell_tally", 0.5, true, 0.5), -- 688
	fe_gear_rattan_shield = feClip("gear_rattan_shield", 0.5, true, 0.5), -- 689
	fe_root_arch = feClip("prop_root_arch", 0, false, 0.5), -- 690
	fe_culvert_grate = feClip("prop_culvert_grate", 0, false, 0.5), -- 691
	fe_red_cloth = feClip({"prop_red_cloth_01", "prop_red_cloth_02", "prop_red_cloth_03"}, 0.5, true, 0.9), -- 692
	fe_vfx_muzzle = feClip({"vfx_muzzle_01", "vfx_muzzle_02", "vfx_muzzle_03"}, 0.5, true, 0.12), -- 693
	fe_vfx_hit_spark = feClip({"vfx_hit_spark_01", "vfx_hit_spark_02", "vfx_hit_spark_03"}, 0.5, true, 0.5), -- 694
	fe_vfx_smoke = feClip({"vfx_smoke_01", "vfx_smoke_02", "vfx_smoke_03", "vfx_smoke_04"}, 0.5, true, 0.5), -- 695
	fe_vfx_steam = feClip({"vfx_steam_01", "vfx_steam_02", "vfx_steam_03"}, 0, true, 0.5), -- 696
	fe_vfx_creek_reflect = feClip({"vfx_creek_reflect_01", "vfx_creek_reflect_02", "vfx_creek_reflect_03"}, 0.5, false, 0.5), -- 697
	fe_glyph_bell = feClip("glyph_bell", 0.5, true, 0.5), -- 698
	fe_glyph_lamp = feClip("glyph_lamp", 0.5, true, 0.5), -- 699
	fe_glyph_push = feClip("glyph_push", 0.5, true, 0.5), -- 700
	fe_ground_brick = feClip("ground_brick_patch", 0, false, 0.5), -- 701
	fe_ground_soft = feClip("ground_soft_patch", 0, false, 0.5), -- 702
	fe_pillar_wood = feClip("pillar_wood", 0, false, 0.5), -- 703
	fe_beam_wood = feClip("beam_wood", 0, false, 0.5), -- 704
	fe_road_stone = feClip("road_stone", 0, false, 0.5), -- 705
	fe_fg_table_top = feClip("fg_table_top", 1, false, 0.5), -- 706
	fe_fg_table_leg = feClip("fg_table_leg", 1, false, 0.5), -- 707
	fe_fg_pine_bough = feClip("fg_pine_bough", 1, false, 1) -- 708
} -- 708
local WHITE = Color(255, 255, 255, 255) -- 711
--- 并行分支动态注册资源槽（与静态 ASSET_SLOTS 隔离，不破坏 verify-integration 全量槽位断言）。
-- 挂在 package.loaded 共享表上，避免不同 Dora 编译版本以 "Script.watch.*" 与 "watch.*" 双路径加载时产生双份表。
local function sharedDynamicSlots() -- 717
	local g = _G -- 718
	local ____temp_0 -- 719
	if g.package ~= nil then -- 719
		____temp_0 = g.package.loaded -- 719
	else -- 719
		____temp_0 = nil -- 719
	end -- 719
	local loaded = ____temp_0 -- 719
	if loaded ~= nil then -- 719
		local existing = loaded["watch.fe.dynamic_slots"] -- 721
		if existing ~= nil and type(existing) == "table" then -- 721
			return existing -- 723
		end -- 723
		local created = {} -- 725
		loaded["watch.fe.dynamic_slots"] = created -- 726
		return created -- 727
	end -- 727
	return FALLBACK_DYNAMIC_SLOTS -- 729
end -- 717
FALLBACK_DYNAMIC_SLOTS = {} -- 732
--- 全局动态注册贴图/图集槽位，供 Wave 1/2 插件零冲突挂载新资源
function ____exports.registerDynamicSlot(key, cfg) -- 735
	sharedDynamicSlots()[key] = cfg -- 736
end -- 735
function ____exports.unregisterDynamicSlot(key) -- 739
	__TS__Delete( -- 740
		sharedDynamicSlots(), -- 740
		key -- 740
	) -- 740
end -- 739
____exports.AssetSlotHost = __TS__Class() -- 743
local AssetSlotHost = ____exports.AssetSlotHost -- 743
AssetSlotHost.name = "AssetSlotHost" -- 743
function AssetSlotHost.prototype.____constructor(self, parent, order, placeInScene) -- 752
	self.placeInScene = placeInScene -- 752
	self.sprites = {} -- 745
	self.unavailable = {} -- 746
	self.lastPlacement = {} -- 747
	self.visibleLastFrame = {} -- 748
	self.visibleThisFrame = {} -- 749
	self.localSlots = {} -- 750
	self.container = Node() -- 753
	self.container.order = order -- 754
	self.container:addTo(parent) -- 755
end -- 752
function AssetSlotHost.prototype.registerDynamicSlot(self, key, cfg) -- 759
	self.localSlots[key] = cfg -- 760
end -- 759
function AssetSlotHost.prototype.currentSprite(self, instanceKey, path) -- 764
	return self.visibleThisFrame[(instanceKey .. ":") .. path] -- 765
end -- 764
function AssetSlotHost.prototype.hideLastPlacement(self, instanceKey) -- 769
	local sprite = self.lastPlacement[instanceKey] -- 770
	if sprite ~= nil then -- 770
		sprite.visible = false -- 772
	end -- 772
end -- 769
function AssetSlotHost.prototype.beginFrame(self) -- 776
	self.visibleThisFrame = {} -- 777
end -- 776
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, options) -- 780
	if options == nil then -- 780
		options = {} -- 784
	end -- 784
	local staticSlots = ____exports.ASSET_SLOTS -- 786
	local cfg = staticSlots[slotKey] or self.localSlots[slotKey] or sharedDynamicSlots()[slotKey] -- 787
	if cfg == nil or #cfg.paths == 0 or targetW <= 0 or targetH <= 0 then -- 787
		return false -- 789
	end -- 789
	local frame = math.abs(math.floor(options.frame or 0)) % #cfg.paths -- 791
	local path = cfg.paths[frame + 1] -- 792
	local anchorX = type(cfg.anchorX) == "number" and cfg.anchorX or (cfg.anchorX ~= nil and (cfg.anchorX[frame + 1] or 0.5) or 0.5) -- 793
	return self:placeResolvedPath( -- 796
		path, -- 796
		anchorX, -- 796
		cfg.anchorY, -- 796
		cfg.preserveAspect, -- 796
		cfg.smooth == true, -- 796
		instanceKey, -- 796
		x, -- 796
		y, -- 796
		targetW, -- 796
		targetH, -- 796
		options -- 796
	) -- 796
end -- 780
function AssetSlotHost.prototype.tryPlaceRun(self, actor, instanceKey, x, y, targetW, targetH, cycles, options, effort) -- 801
	if options == nil then -- 801
		options = {} -- 806
	end -- 806
	if effort == nil then -- 806
		effort = 1 -- 807
	end -- 807
	if effort < 1 and self:tryPlaceRunTransition( -- 807
		actor, -- 809
		instanceKey, -- 809
		x, -- 809
		y, -- 809
		targetW, -- 809
		targetH, -- 809
		cycles, -- 809
		effort, -- 809
		options -- 809
	) then -- 809
		return true -- 810
	end -- 810
	local frame = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_FRAME_COUNT) -- 812
	return self:tryPlaceMotionFrame( -- 813
		RUN_ATLASES[actor], -- 813
		frame, -- 813
		instanceKey, -- 813
		x, -- 813
		y, -- 813
		targetW, -- 813
		targetH, -- 813
		options -- 813
	) -- 813
end -- 801
function AssetSlotHost.prototype.tryPlaceRunTransition(self, actor, instanceKey, x, y, targetW, targetH, cycles, effort, options) -- 817
	if options == nil then -- 817
		options = {} -- 822
	end -- 822
	local phase = math.floor((cycles - math.floor(cycles)) * ____exports.RUN_TRANSITION_PHASES + 0.5) % ____exports.RUN_TRANSITION_PHASES -- 824
	local level = math.max( -- 825
		0, -- 825
		math.min( -- 825
			____exports.RUN_TRANSITION_LEVELS - 1, -- 825
			math.floor(effort * (____exports.RUN_TRANSITION_LEVELS + 1) + 0.5) - 1 -- 825
		) -- 825
	) -- 825
	return self:tryPlaceMotionFrame( -- 826
		RUN_TRANSITIONS[actor], -- 826
		level * ____exports.RUN_TRANSITION_PHASES + phase, -- 826
		instanceKey, -- 827
		x, -- 827
		y, -- 827
		targetW, -- 827
		targetH, -- 827
		options -- 827
	) -- 827
end -- 817
function AssetSlotHost.prototype.tryPlaceSlide(self, instanceKey, x, y, targetW, targetH, progress, options) -- 830
	if options == nil then -- 830
		options = {} -- 834
	end -- 834
	local frame = math.max( -- 836
		0, -- 836
		math.min( -- 836
			____exports.SLIDE_FRAME_COUNT - 1, -- 836
			math.floor(progress * ____exports.SLIDE_FRAME_COUNT) -- 836
		) -- 836
	) -- 836
	return self:tryPlaceMotionFrame( -- 837
		SLIDE_ATLAS, -- 837
		frame, -- 837
		instanceKey, -- 837
		x, -- 837
		y, -- 837
		targetW, -- 837
		targetH, -- 837
		options -- 837
	) -- 837
end -- 830
function AssetSlotHost.prototype.tryPlaceMotionFrame(self, atlas, frame, instanceKey, x, y, targetW, targetH, options) -- 840
	if targetW <= 0 or targetH <= 0 then -- 840
		return false -- 848
	end -- 848
	local ____atlas_1 = atlas -- 850
	local path = ____atlas_1.path -- 850
	local width = ____atlas_1.width -- 850
	local height = ____atlas_1.height -- 850
	local columns = ____atlas_1.columns -- 850
	local col = frame % columns -- 851
	local row = math.floor(frame / columns) -- 852
	local rect = Rect(col * (width + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, row * (height + 2 * ATLAS_GUTTER) + ATLAS_GUTTER, width, height) -- 853
	return self:placeResolvedPath( -- 855
		path, -- 855
		0.5, -- 855
		0, -- 855
		true, -- 855
		false, -- 855
		instanceKey, -- 855
		x, -- 855
		y, -- 855
		targetW, -- 855
		targetH, -- 855
		options, -- 855
		rect -- 855
	) -- 855
end -- 840
function AssetSlotHost.prototype.tryPlacePath(self, path, instanceKey, x, y, targetW, targetH, options) -- 859
	if options == nil then -- 859
		options = {} -- 863
	end -- 863
	if path == "" or targetW <= 0 or targetH <= 0 then -- 863
		return false -- 866
	end -- 866
	local ____self_placeResolvedPath_4 = self.placeResolvedPath -- 868
	local ____array_3 = __TS__SparseArrayNew(path, options.anchorX or 0.5, options.anchorY or 0.5) -- 868
	local ____options_preserveAspect_2 = options.preserveAspect -- 872
	if ____options_preserveAspect_2 == nil then -- 872
		____options_preserveAspect_2 = false -- 872
	end -- 872
	__TS__SparseArrayPush( -- 872
		____array_3, -- 872
		____options_preserveAspect_2, -- 872
		options.smooth == true, -- 873
		instanceKey, -- 874
		x, -- 875
		y, -- 876
		targetW, -- 877
		targetH, -- 878
		options -- 879
	) -- 879
	return ____self_placeResolvedPath_4( -- 868
		self, -- 868
		__TS__SparseArraySpread(____array_3) -- 868
	) -- 868
end -- 859
function AssetSlotHost.prototype.placeResolvedPath(self, path, anchorX, anchorY, preserveAspect, smooth, instanceKey, x, y, targetW, targetH, options, textureRect) -- 883
	local key = (instanceKey .. ":") .. path -- 894
	local sprite = self.sprites[key] -- 895
	if sprite == nil then -- 895
		if self.unavailable[path] then -- 895
			return false -- 898
		end -- 898
		local divider = (string.find(path, "|", nil, true) or 0) - 1 -- 900
		local file = divider < 0 and path or __TS__StringSlice(path, 0, divider) -- 901
		local ____Content_exist_result_5 -- 902
		if Content:exist(file) then -- 902
			____Content_exist_result_5 = Sprite(path) -- 902
		else -- 902
			____Content_exist_result_5 = nil -- 902
		end -- 902
		local loaded = ____Content_exist_result_5 -- 902
		if loaded == nil then -- 902
			self.unavailable[path] = true -- 904
			return false -- 905
		end -- 905
		if textureRect ~= nil then -- 905
			loaded.size = Size(textureRect.width, textureRect.height) -- 909
		end -- 909
		loaded.filter = smooth and "Anisotropic" or "Point" -- 912
		loaded:addTo(self.container) -- 913
		self.sprites[key] = loaded -- 914
		sprite = loaded -- 915
	end -- 915
	if textureRect ~= nil then -- 915
		sprite.textureRect = textureRect -- 919
	end -- 919
	local baseScaleY = targetH / math.max(1, textureRect and textureRect.height or sprite.height) -- 921
	local baseScaleX = preserveAspect and baseScaleY or targetW / math.max(1, sprite.width) -- 922
	local scaleX = baseScaleX * (options.scaleXMul or 1) -- 923
	local scaleY = baseScaleY * (options.scaleYMul or 1) -- 924
	sprite.anchor = Vec2(anchorX, anchorY) -- 925
	sprite.position = textureRect == nil and Vec2( -- 926
		math.floor(x + 0.5), -- 926
		math.floor(y + 0.5) -- 926
	) or Vec2(x, y) -- 926
	sprite.scaleX = (options.facing or 1) < 0 and -scaleX or scaleX -- 927
	sprite.scaleY = options.flipY and -scaleY or scaleY -- 928
	sprite.angle = options.angle or 0 -- 929
	sprite.order = options.layer or 0 -- 930
	local col = options.color or WHITE -- 931
	sprite.color = col -- 932
	local baseA = col.a / 255 -- 933
	local op = options.opacity or 1 -- 934
	sprite.opacity = math.max( -- 935
		0, -- 935
		math.min(1, baseA * op) -- 935
	) -- 935
	sprite.visible = true -- 936
	self.visibleThisFrame[key] = sprite -- 937
	self.lastPlacement[instanceKey] = sprite -- 938
	if self.placeInScene ~= nil then -- 938
		self.placeInScene( -- 940
			sprite, -- 940
			key, -- 940
			instanceKey, -- 940
			x, -- 940
			y -- 940
		) -- 940
	end -- 940
	return true -- 942
end -- 883
function AssetSlotHost.prototype.endFrame(self) -- 945
	for key in pairs(self.visibleLastFrame) do -- 946
		if self.visibleThisFrame[key] == nil then -- 946
			self.visibleLastFrame[key].visible = false -- 948
		end -- 948
	end -- 948
	self.visibleLastFrame = self.visibleThisFrame -- 951
end -- 945
return ____exports -- 945