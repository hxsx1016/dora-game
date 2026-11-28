-- [ts]: ming_audit.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 19
local Color = ____Dora.Color -- 19
local Content = ____Dora.Content -- 19
local Rect = ____Dora.Rect -- 19
local Vec2 = ____Dora.Vec2 -- 19
local ____depth = require("Script.watch.depth") -- 21
local ACTOR_DEPTH_HALF = ____depth.ACTOR_DEPTH_HALF -- 21
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 21
local overlapsDepth = ____depth.overlapsDepth -- 21
local ____assets = require("Script.watch.fe.assets") -- 22
local ASSET_SLOTS = ____assets.ASSET_SLOTS -- 22
local ____theme = require("Script.watch.fe.theme") -- 25
local PALETTE = ____theme.PALETTE -- 25
local fillVGradRect = ____theme.fillVGradRect -- 25
local themeOf = ____theme.themeOf -- 25
local toColor = ____theme.toColor -- 25
--- 既有 58 个 sprites.clip 帧键名（fe-03 严格保持 100% 向后兼容）
____exports.MING_PRESERVED_SPRITE_CLIPS = { -- 28
	"soldier_idle", -- 29
	"soldier_run", -- 29
	"soldier_roll", -- 29
	"child_idle", -- 29
	"child_run", -- 29
	"child_fear", -- 29
	"enemy_idle", -- 30
	"enemy_aim", -- 30
	"enemy_down", -- 30
	"enemy_hit", -- 30
	"scavenger_idle", -- 31
	"scavenger_walk", -- 31
	"scavenger_turn", -- 31
	"scavenger_run", -- 31
	"soldier_cover", -- 32
	"soldier_step", -- 32
	"soldier_push", -- 32
	"soldier_hold", -- 32
	"soldier_offer", -- 33
	"soldier_knock", -- 33
	"soldier_hit", -- 33
	"soldier_fire", -- 33
	"child_crouch", -- 34
	"child_step", -- 34
	"child_peek", -- 34
	"child_pull", -- 34
	"child_aim", -- 35
	"child_throw", -- 35
	"child_knock", -- 35
	"child_offer", -- 35
	"soldier_push_step", -- 36
	"child_pull_step", -- 36
	"child_crouch_step", -- 36
	"cart", -- 37
	"bottle", -- 37
	"door", -- 37
	"lantern", -- 37
	"dog_idle", -- 38
	"dog_alert", -- 38
	"dog_run", -- 38
	"dog_sniff", -- 38
	"table", -- 39
	"compass", -- 39
	"grass", -- 39
	"stone_chips", -- 39
	"ui_corner", -- 39
	"paper", -- 39
	"cover_wood", -- 40
	"cover_stone", -- 40
	"fence", -- 40
	"wall", -- 40
	"slab", -- 40
	"eaves", -- 40
	"pine", -- 40
	"winch", -- 40
	"grass_low", -- 41
	"soldier_fire_run", -- 41
	"soldier_fire_run_step" -- 41
} -- 41
--- 既有 15 个 ui_ink.clip 帧键名
____exports.MING_PRESERVED_UI_CLIPS = { -- 45
	"ink_ribbon_sweep", -- 46
	"ink_mist_curve", -- 46
	"ink_veil_strip", -- 46
	"ink_hairline", -- 46
	"ink_bamboo_slip", -- 47
	"ink_bamboo_slot", -- 47
	"ink_frame_mask", -- 47
	"ink_vstream", -- 47
	"ink_knot_ornament", -- 48
	"ink_corner_fine", -- 48
	"ink_seal_slender", -- 48
	"ink_blossom_dot", -- 48
	"ink_enso_fine", -- 49
	"ink_petal_mist", -- 49
	"ink_song_paper" -- 49
} -- 49
--- 八大核心房间的官方明朝像素背景键
____exports.CORE_MING_BACKDROPS = { -- 53
	prologue = "bgFar_prologue", -- 54
	street = "bgFar_street", -- 55
	checkpoint = "bgFar_checkpoint", -- 56
	gate = "bgFar_gate", -- 57
	outside = "bgFar_outside", -- 58
	village = "bgFar_village", -- 59
	forest = "bgFar_forest", -- 60
	tower = "bgFar_tower" -- 61
} -- 61
--- 非八房战役/护送段到明朝像素底图的映射表（Phase 3 接入十字街布行 / 牌楼候检院 / 军粮棚 / 城外山脊四幅专属明代底图）
____exports.FALLBACK_MING_BACKDROPS = { -- 65
	["s1-crossroad"] = "bgFar_crossroad_drygoods", -- 66
	["s2-drygoods"] = "bgFar_crossroad_drygoods", -- 67
	["s3-archway"] = "bgFar_archway_yard", -- 68
	["c1-yard"] = "bgFar_archway_yard", -- 69
	["c2-granary"] = "bgFar_granary", -- 70
	gatepath = "bgFar_escort_ridge", -- 71
	escort1 = "bgFar_escort_ridge", -- 72
	escort2 = "bgFar_granary", -- 73
	escort3 = "bgFar_forest", -- 74
	escort4 = "bgFar_escort_ridge", -- 75
	escort5 = "bgFar_tower", -- 76
	museum = "bgFar_museum" -- 77
} -- 77
--- 检出的 6 处既有热点渲染文件赛博/全息遗留（方案 A：记录清单，不修改热点文件，交 M1 / fe-07 收口）
____exports.MING_LEGACY_FINDINGS = { -- 93
	{ -- 94
		id = "MING-01", -- 95
		file = "Script/watch/fe/theme.ts & Script/watch/fe/renderer/stage.ts", -- 96
		lines = "theme.ts:160,189,218,247; stage.ts:166-274,329-508", -- 97
		severity = "high", -- 98
		summary = "showSearchlights=true 与无 bgFar 退化路径包含扫射探照灯、屋顶天线、工业钢桁架、垂落电缆及破损电灯", -- 99
		mitigationInFe03 = "MingArtAuditPlugin.drawBackdrop 拦截全部非八房房间并映射至明朝像素底图，运行期 0 触发探照灯", -- 100
		targetFixPhase = "M1 / fe-07" -- 101
	}, -- 101
	{ -- 103
		id = "MING-02", -- 104
		file = "Script/watch/fe/renderer/stage.ts", -- 105
		lines = "stage.ts:844-857", -- 106
		severity = "high", -- 107
		summary = "drawCoverBlock 在贴靠掩体时绘制冰青全息护盾竖条与大面积荧光蓝光晕", -- 108
		mitigationInFe03 = "审计报告标注待改为木沿/砖沿低饱和描边，本分支不改动 stage.ts 保持零冲突", -- 109
		targetFixPhase = "M1 / fe-07" -- 110
	}, -- 110
	{ -- 112
		id = "MING-03", -- 113
		file = "Script/watch/fe/renderer/stage.ts", -- 114
		lines = "stage.ts:860-891", -- 115
		severity = "medium", -- 116
		summary = "drawWinch 在 prop_winch 下层仍绘倒角钢箱与闪烁冰青/琥珀电子状态灯", -- 117
		mitigationInFe03 = "待改为纯木铁绞盘实体与绳链张力表现", -- 118
		targetFixPhase = "M1 / fe-07" -- 119
	}, -- 119
	{ -- 121
		id = "MING-04", -- 122
		file = "Script/watch/fe/renderer/stage.ts", -- 123
		lines = "stage.ts:1047-1059", -- 124
		severity = "medium", -- 125
		summary = "drawArch 城外矮拱绘制亮银矩形外框与冰蓝发光竖渐变，与周边明代灰砖质感割裂", -- 126
		mitigationInFe03 = "fe-04 低模城外将接管城外舞台；像素线待在 fe-07 改为石拱券砖沿", -- 127
		targetFixPhase = "fe-04 / fe-07" -- 128
	}, -- 128
	{ -- 130
		id = "MING-05", -- 131
		file = "Script/watch/fe/renderer/props.ts", -- 132
		lines = "props.ts:78-83,100-153,242-245,307", -- 133
		severity = "high", -- 134
		summary = "存在危险区红激光扫描线、全息检查点菱柱、车柄发光黄球、钢杆灯柱及村口瓶架贴图纵拉变形", -- 135
		mitigationInFe03 = "ming_audit.ts 补强村口砖缝/软土灰度纹样与左端红布校验；全息标与黄球留待 fe-07 清理", -- 136
		targetFixPhase = "fe-07" -- 137
	}, -- 137
	{ -- 139
		id = "MING-06", -- 140
		file = "Script/watch/fe/renderer/actors.ts", -- 141
		lines = "actors.ts:66-83,145-171", -- 142
		severity = "medium", -- 143
		summary = "周戍翻滚仍生成 ICEY 冰青残影，不符合明代守卒写实基调且与 fe-06 穿梭器残影彩蛋语义重叠", -- 144
		mitigationInFe03 = "审计报告标注待改为扬尘步烟，残影视觉专属留给 fe-06 穿梭器彩蛋", -- 145
		targetFixPhase = "M2 / fe-07" -- 146
	} -- 146
} -- 146
function ____exports.resolveMingBackdropSlot(roomKey) -- 193
	local direct = ____exports.CORE_MING_BACKDROPS[roomKey] -- 194
	if direct ~= nil then -- 195
		return direct -- 196
	end -- 196
	local mapped = ____exports.FALLBACK_MING_BACKDROPS[roomKey] -- 198
	if mapped ~= nil then -- 199
		return mapped -- 200
	end -- 200
	return "bgFar_street" -- 202
end -- 193
function ____exports.isWoodCoverLabel(art, label) -- 205
	if art == "cover_wood" or art == "thin_wood" or art == "board" or art == "fence" or art == "basket_wall" then -- 206
		return true -- 207
	end -- 207
	if art == "cover_stone" or art == "wall" or art == "gate_post" or art == "well" then -- 209
		return false -- 210
	end -- 210
	if label ~= nil then -- 212
		if (string.find(label, "柜", nil, true) or 0) - 1 >= 0 or (string.find(label, "木", nil, true) or 0) - 1 >= 0 or (string.find(label, "桌", nil, true) or 0) - 1 >= 0 or (string.find(label, "货", nil, true) or 0) - 1 >= 0 or (string.find(label, "棚", nil, true) or 0) - 1 >= 0 or (string.find(label, "栏", nil, true) or 0) - 1 >= 0 then -- 214
			return true -- 221
		end -- 221
	end -- 221
	return false -- 224
end -- 205
____exports.MingArtAuditPlugin = __TS__Class() -- 227
local MingArtAuditPlugin = ____exports.MingArtAuditPlugin -- 227
MingArtAuditPlugin.name = "MingArtAuditPlugin" -- 227
function MingArtAuditPlugin.prototype.____constructor(self) -- 227
	self.id = "fe03-ming-audit" -- 228
	self.chips = {} -- 230
	self.puffs = {} -- 231
	self.scorches = {} -- 232
	self.animTime = 0 -- 233
	self.rng = 4099 -- 234
	self.fallbackInterceptCount = 0 -- 237
	self.woodDebrisCount = 0 -- 238
	self.brickDebrisCount = 0 -- 239
	self.powderSmokeCount = 0 -- 240
	self.cartLeftInvariantOk = true -- 241
	self.lastRoomKey = "" -- 242
end -- 227
function MingArtAuditPlugin.prototype.rand(self) -- 244
	self.rng = (self.rng * 1664525 + 1013904223) % 4294967296 -- 245
	return self.rng / 4294967296 -- 246
end -- 244
function MingArtAuditPlugin.prototype.onBindPlay(self, p, _view) -- 249
	self.chips = {} -- 250
	self.puffs = {} -- 251
	self.scorches = {} -- 252
	self.animTime = 0 -- 253
	self.lastRoomKey = p.room.key -- 254
	if p.room.cart.bodyW > 0 and p.room.cart.clothSide >= 0 then -- 255
		self.cartLeftInvariantOk = false -- 256
	end -- 256
	self:syncRuntimeHook() -- 258
end -- 249
function MingArtAuditPlugin.prototype.syncRuntimeHook(self) -- 261
	local g = _G -- 262
	local ____temp_0 -- 263
	if g.package ~= nil then -- 263
		____temp_0 = g.package.loaded -- 263
	else -- 263
		____temp_0 = nil -- 263
	end -- 263
	local loaded = ____temp_0 -- 263
	if loaded == nil then -- 264
		return -- 265
	end -- 265
	local rawFe = loaded["watch.fe"] -- 267
	if rawFe ~= nil and type(rawFe) == "table" then -- 268
		local watchFe = rawFe -- 269
		if watchFe.mingAudit ~= self then -- 270
			watchFe.mingAudit = self -- 271
		end -- 271
	end -- 271
end -- 261
function MingArtAuditPlugin.prototype.update(self, ctx) -- 276
	self:syncRuntimeHook() -- 277
	local p = ctx.p -- 278
	if self.lastRoomKey ~= "" and self.lastRoomKey ~= p.room.key then -- 280
		self:onBindPlay(p, ctx.view) -- 281
	end -- 281
	if p.room.cart.bodyW > 0 and p.room.cart.clothSide >= 0 then -- 283
		self.cartLeftInvariantOk = false -- 284
	end -- 284
	if ctx.paused or ctx.worldDt <= 0 then -- 287
		return -- 288
	end -- 288
	local dt = ctx.worldDt -- 291
	self.animTime = self.animTime + dt -- 292
	if ctx.events.coverDeflect then -- 295
		self:spawnCoverMaterialDebris(p) -- 296
	end -- 296
	if ctx.events.shotFired and ctx.events.shotTrace ~= nil then -- 300
		local tr = ctx.events.shotTrace -- 301
		self:spawnMatchlockSmoke(tr.x0, tr.y0, tr.x1 >= tr.x0 and 1 or -1) -- 302
		if not tr.hit and tr.y1 <= 42 then -- 303
			self:addScorch( -- 304
				tr.x1, -- 304
				math.max(0, tr.y1) -- 304
			) -- 304
		end -- 304
	end -- 304
	local w = 0 -- 309
	local i = 0 -- 310
	do -- 310
		i = 0 -- 311
		while i < #self.chips do -- 311
			local c = self.chips[i + 1] -- 312
			c.life = c.life - dt -- 313
			if c.life > 0 then -- 314
				c.vy = c.vy - (c.isWood and 360 or 210) * dt -- 315
				c.x = c.x + c.vx * dt -- 316
				c.y = c.y + c.vy * dt -- 317
				if c.y < 0 then -- 318
					c.y = 0 -- 319
					c.vy = -c.vy * 0.25 -- 320
					c.vx = c.vx * 0.65 -- 321
				end -- 321
				self.chips[w + 1] = c -- 323
				w = w + 1 -- 324
			end -- 324
			i = i + 1 -- 311
		end -- 311
	end -- 311
	__TS__ArraySetLength(self.chips, w) -- 327
	w = 0 -- 330
	do -- 330
		i = 0 -- 331
		while i < #self.puffs do -- 331
			local pf = self.puffs[i + 1] -- 332
			pf.life = pf.life - dt -- 333
			if pf.life > 0 then -- 334
				pf.x = pf.x + pf.vx * dt -- 335
				pf.y = pf.y + pf.vy * dt -- 336
				pf.vx = pf.vx * math.max(0, 1 - dt * 3.4) -- 337
				pf.r = pf.r + dt * 14 -- 338
				self.puffs[w + 1] = pf -- 339
				w = w + 1 -- 340
			end -- 340
			i = i + 1 -- 331
		end -- 331
	end -- 331
	__TS__ArraySetLength(self.puffs, w) -- 343
end -- 276
function MingArtAuditPlugin.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 350
	local roomKey = ctx.p.room.key -- 356
	if ____exports.CORE_MING_BACKDROPS[roomKey] ~= nil then -- 357
		return false -- 358
	end -- 358
	if ctx.view.visualMode == "lowpoly" or ctx.view.visualMode == "museum" then -- 361
		return false -- 362
	end -- 362
	local slot = ____exports.resolveMingBackdropSlot(roomKey) -- 365
	local cam = ctx.cam -- 366
	local w = cam.viewW -- 367
	local h = cam.viewH -- 368
	local span = math.max(1, ctx.p.room.maxX - ctx.p.room.minX) -- 369
	local progress = (cam.x - ctx.p.room.minX) / span - 0.5 -- 370
	local backRoadY = cam:sy(0, ctx.p.room.depth ~= nil and ctx.p.room.depth.max or 0) -- 371
	local artW = math.max(w, h * 16 / 9) * 1.1 -- 372
	local artH = artW * 9 / 16 -- 373
	local sceneY = math.min( -- 375
		0, -- 375
		math.max(h - artH, backRoadY - artH * 0.25) -- 375
	) -- 375
	if backdropArt:tryPlace( -- 377
		slot, -- 377
		"ming_fallback_scene", -- 377
		w * (0.5 - progress * 0.08), -- 377
		sceneY, -- 377
		artW, -- 377
		artH -- 377
	) then -- 377
		self.fallbackInterceptCount = self.fallbackInterceptCount + 1 -- 378
		local theme = themeOf(roomKey) -- 379
		local outdoorRidge = slot == "bgFar_outside" or slot == "bgFar_escort_ridge" or slot == "bgFar_forest" -- 380
		if outdoorRidge then -- 381
			backdropArt:tryPlace( -- 382
				"pine", -- 383
				"ming_fallback_mid", -- 384
				w * (0.76 - progress * 0.24), -- 385
				backRoadY - cam:len(4), -- 386
				cam:len(118), -- 387
				cam:len(104), -- 388
				{layer = 1, opacity = 0.46} -- 389
			) -- 389
		elseif slot ~= "bgFar_granary" and slot ~= "bgFar_crossroad_drygoods" and slot ~= "bgFar_archway_yard" and slot ~= "bgFar_tower" then -- 391
			backdropArt:tryPlace( -- 392
				"eaves", -- 393
				"ming_fallback_mid", -- 394
				w * (0.74 - progress * 0.24), -- 395
				backRoadY - cam:len(4), -- 396
				cam:len(172), -- 397
				cam:len(94), -- 398
				{layer = 1, opacity = 0.46} -- 399
			) -- 399
		end -- 399
		fillVGradRect( -- 402
			bgDraw, -- 402
			0, -- 402
			0, -- 402
			w, -- 402
			h, -- 402
			toColor(PALETTE.voidDark), -- 402
			toColor(theme.skyMid) -- 402
		) -- 402
		fillVGradRect( -- 403
			bgGlow, -- 403
			0, -- 403
			backRoadY - 2, -- 403
			w, -- 403
			h * 0.13, -- 403
			Color(43, 52, 68, 18), -- 403
			Color(43, 52, 68, 0) -- 403
		) -- 403
		return true -- 404
	end -- 404
	return false -- 406
end -- 350
function MingArtAuditPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 410
	local p = ctx.p -- 416
	local cam = ctx.cam -- 417
	local isPixelStyle = ctx.view.visualMode == "pixel" or ctx.view.visualMode == "transition" -- 418
	if isPixelStyle and p.room.key == "village" then -- 421
		self:drawVillageGrayscaleSurfaces(fgDraw, worldArt, p, cam) -- 422
	end -- 422
	if isPixelStyle and p.room.key == "forest" then -- 426
		self:drawForestSilhouetteSeparation(fgDraw, p, cam) -- 427
	end -- 427
	if isPixelStyle and (p.room.key == "checkpoint" or p.room.key == "outside") and p.room.cart.bodyW > 0 then -- 431
		self:drawLeftEndRedClothAccent(worldArt, p, cam) -- 432
	end -- 432
	local i = 0 -- 436
	do -- 436
		i = 0 -- 437
		while i < #self.scorches do -- 437
			local sc = self.scorches[i + 1] -- 438
			fgDraw:drawEllipse( -- 439
				Vec2( -- 439
					cam:sx(sc.x), -- 439
					cam:sy(sc.y) + 2 -- 439
				), -- 439
				cam:len(sc.rx), -- 439
				cam:len(2.4), -- 439
				Color(16, 14, 15, 165) -- 439
			) -- 439
			i = i + 1 -- 437
		end -- 437
	end -- 437
	do -- 437
		i = 0 -- 443
		while i < #self.chips do -- 443
			local c = self.chips[i + 1] -- 444
			local k = c.life / c.maxLife -- 445
			local sx = cam:sx(c.x) -- 446
			local sy = cam:sy(c.y) -- 447
			local sw = math.max( -- 448
				2, -- 448
				cam:len(c.w) -- 448
			) -- 448
			local sh = math.max( -- 449
				1.5, -- 449
				cam:len(c.h) -- 449
			) -- 449
			if c.isWood then -- 450
				fgDraw:drawRect( -- 451
					Rect(sx - sw * 0.5, sy - sh * 0.5, sw, sh), -- 451
					Color( -- 451
						128, -- 451
						86, -- 451
						54, -- 451
						math.floor(235 * k + 0.5) -- 451
					) -- 451
				) -- 451
				fgDraw:drawSegment( -- 452
					Vec2(sx - sw * 0.5, sy + sh * 0.5), -- 452
					Vec2(sx + sw * 0.5, sy + sh * 0.5), -- 452
					0.9, -- 452
					Color( -- 452
						196, -- 452
						162, -- 452
						118, -- 452
						math.floor(180 * k + 0.5) -- 452
					) -- 452
				) -- 452
			else -- 452
				fgDraw:drawCircle( -- 454
					Vec2(sx, sy), -- 454
					sw * 0.65, -- 454
					Color( -- 454
						164, -- 454
						168, -- 454
						172, -- 454
						math.floor(175 * k + 0.5) -- 454
					) -- 454
				) -- 454
				fgDraw:drawDot( -- 455
					Vec2(sx + 1, sy + 1), -- 455
					math.max(1.2, sw * 0.32), -- 455
					Color( -- 455
						218, -- 455
						220, -- 455
						224, -- 455
						math.floor(210 * k + 0.5) -- 455
					) -- 455
				) -- 455
			end -- 455
			i = i + 1 -- 443
		end -- 443
	end -- 443
	do -- 443
		i = 0 -- 460
		while i < #self.puffs do -- 460
			local pf = self.puffs[i + 1] -- 461
			local k = pf.life / pf.maxLife -- 462
			local sx = cam:sx(pf.x) -- 463
			local sy = cam:sy(pf.y) -- 464
			local sz = math.max( -- 465
				8, -- 465
				cam:len(pf.r * 3.4) -- 465
			) -- 465
			if not worldArt:tryPlace( -- 466
				"fe_vfx_smoke", -- 466
				"ming_puff_" .. tostring(i), -- 466
				sx, -- 466
				sy, -- 466
				sz, -- 466
				sz, -- 466
				{ -- 466
					frame = math.min( -- 467
						3, -- 467
						math.floor((1 - k) * 4) -- 467
					), -- 467
					opacity = 0.72 * k, -- 468
					layer = 8 -- 469
				} -- 469
			) then -- 469
				local r = math.max( -- 471
					2, -- 471
					cam:len(pf.r) -- 471
				) -- 471
				fgDraw:drawCircle( -- 472
					Vec2(sx, sy), -- 472
					r, -- 472
					Color( -- 472
						196, -- 472
						198, -- 472
						200, -- 472
						math.floor(92 * k + 0.5) -- 472
					) -- 472
				) -- 472
				fgGlow:drawCircle( -- 473
					Vec2(sx, sy), -- 473
					r * 0.62, -- 473
					Color( -- 473
						224, -- 473
						222, -- 473
						214, -- 473
						math.floor(48 * k + 0.5) -- 473
					) -- 473
				) -- 473
			end -- 473
			i = i + 1 -- 460
		end -- 460
	end -- 460
end -- 410
function MingArtAuditPlugin.prototype.spawnCoverMaterialDebris(self, p) -- 478
	local hitX = p.player.x + p.player.facing * 16 -- 479
	local hitY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.5 -- 480
	local isWood = false -- 481
	local nearest = 56 -- 482
	local i = 0 -- 483
	do -- 483
		i = 0 -- 484
		while i < #p.room.solids do -- 484
			do -- 484
				local s = p.room.solids[i + 1] -- 485
				if s.passable or s.decorative or s.y > p.player.y + 4 or s.h > 72 then -- 486
					goto __continue53 -- 487
				end -- 487
				if not overlapsDepth(p.player.depth, s.depth, ACTOR_DEPTH_HALF) then -- 489
					goto __continue53 -- 490
				end -- 490
				local edge = p.player.x < s.x and s.x or s.x + s.w -- 492
				local gap = math.abs(p.player.x - edge) -- 493
				if gap < nearest then -- 494
					nearest = gap -- 495
					hitX = edge -- 496
					local ____s_y_3 = s.y -- 497
					local ____opt_1 = s.depth -- 497
					hitY = ____s_y_3 + (____opt_1 and ____opt_1.min or 0) * DEPTH_Y_SCALE + s.h * 0.85 -- 497
					isWood = ____exports.isWoodCoverLabel(s.art, s.label) -- 498
				end -- 498
			end -- 498
			::__continue53:: -- 498
			i = i + 1 -- 484
		end -- 484
	end -- 484
	if isWood then -- 502
		self.woodDebrisCount = self.woodDebrisCount + 1 -- 503
	else -- 503
		self.brickDebrisCount = self.brickDebrisCount + 1 -- 505
	end -- 505
	local count = isWood and 9 or 10 -- 508
	do -- 508
		i = 0 -- 509
		while i < count do -- 509
			local ang = (self:rand() - 0.5) * math.pi * 1.15 -- 510
			local spd = (isWood and 85 or 58) * (0.45 + self:rand() * 0.75) -- 511
			local life = (isWood and 0.34 or 0.42) + self:rand() * 0.16 -- 512
			local ____self_chips_4 = self.chips -- 513
			____self_chips_4[#____self_chips_4 + 1] = { -- 513
				x = hitX, -- 514
				y = hitY, -- 515
				vx = -p.player.facing * math.abs(math.cos(ang)) * spd + (self:rand() - 0.5) * 35, -- 516
				vy = math.abs(math.sin(ang)) * spd + (isWood and 55 or 28), -- 517
				w = isWood and 4.5 + self:rand() * 3.5 or 2.6 + self:rand() * 2.8, -- 518
				h = isWood and 1.8 + self:rand() * 1.4 or 2.6 + self:rand() * 2.8, -- 519
				life = life, -- 520
				maxLife = life, -- 521
				isWood = isWood -- 522
			} -- 522
			i = i + 1 -- 509
		end -- 509
	end -- 509
end -- 478
function MingArtAuditPlugin.prototype.spawnMatchlockSmoke(self, wx, wy, dir) -- 527
	self.powderSmokeCount = self.powderSmokeCount + 1 -- 528
	local i = 0 -- 529
	do -- 529
		i = 0 -- 530
		while i < 5 do -- 530
			local life = 0.24 + self:rand() * 0.18 -- 531
			local ____self_puffs_5 = self.puffs -- 532
			____self_puffs_5[#____self_puffs_5 + 1] = { -- 532
				x = wx + dir * (4 + i * 3.5), -- 533
				y = wy + (self:rand() - 0.4) * 5, -- 534
				vx = dir * (28 + self:rand() * 44), -- 535
				vy = 14 + self:rand() * 22, -- 536
				r = 3 + self:rand() * 2.4, -- 537
				life = life, -- 538
				maxLife = life -- 539
			} -- 539
			i = i + 1 -- 530
		end -- 530
	end -- 530
end -- 527
function MingArtAuditPlugin.prototype.addScorch(self, wx, wy) -- 544
	local ____self_scorches_6 = self.scorches -- 545
	____self_scorches_6[#____self_scorches_6 + 1] = { -- 545
		x = wx, -- 545
		y = wy, -- 545
		rx = 5.5 + self:rand() * 3 -- 545
	} -- 545
	if #self.scorches > 16 then -- 546
		table.remove(self.scorches, 1) -- 547
	end -- 547
end -- 544
function MingArtAuditPlugin.prototype.drawVillageGrayscaleSurfaces(self, fgDraw, worldArt, p, cam) -- 551
	local y0 = cam:sy(0) -- 557
	if p.room.brickX ~= nil then -- 559
		local bx = cam:sx(p.room.brickX) -- 560
		if not worldArt:tryPlace( -- 561
			"fe_ground_brick", -- 561
			"ming_vil_brick", -- 561
			bx, -- 561
			y0 - cam:len(4), -- 561
			cam:len(44), -- 561
			cam:len(14), -- 561
			{layer = 2} -- 561
		) then -- 561
			fgDraw:drawRect( -- 562
				Rect( -- 562
					bx - cam:len(18), -- 562
					y0 - 4, -- 562
					cam:len(36), -- 562
					8 -- 562
				), -- 562
				Color(142, 146, 150, 235) -- 562
			) -- 562
		end -- 562
		fgDraw:drawSegment( -- 564
			Vec2( -- 564
				bx - cam:len(20), -- 564
				y0 + 2 -- 564
			), -- 564
			Vec2( -- 564
				bx + cam:len(20), -- 564
				y0 + 2 -- 564
			), -- 564
			1.3, -- 564
			Color(228, 232, 238, 170) -- 564
		) -- 564
	end -- 564
	if p.room.softX ~= nil then -- 567
		local sx = cam:sx(p.room.softX) -- 568
		if not worldArt:tryPlace( -- 569
			"fe_ground_soft", -- 569
			"ming_vil_soft", -- 569
			sx, -- 569
			y0 - cam:len(4), -- 569
			cam:len(44), -- 569
			cam:len(14), -- 569
			{layer = 2} -- 569
		) then -- 569
			fgDraw:drawRect( -- 570
				Rect( -- 570
					sx - cam:len(18), -- 570
					y0 - 3, -- 570
					cam:len(36), -- 570
					6 -- 570
				), -- 570
				Color(54, 44, 36, 225) -- 570
			) -- 570
		end -- 570
	end -- 570
end -- 551
function MingArtAuditPlugin.prototype.drawForestSilhouetteSeparation(self, fgDraw, p, cam) -- 575
	local childInGrass = false -- 577
	local i = 0 -- 578
	do -- 578
		i = 0 -- 579
		while i < #p.room.solids do -- 579
			local s = p.room.solids[i + 1] -- 580
			if s.passable == true and p.player.x >= s.x - 16 and p.player.x <= s.x + s.w + 16 then -- 581
				childInGrass = true -- 582
			end -- 582
			i = i + 1 -- 579
		end -- 579
	end -- 579
	if childInGrass and p.player.alive then -- 585
		local cx = cam:sx(p.player.x) -- 586
		local topY = cam:sy(p.player.y + p.player.h) -- 587
		fgDraw:drawArc( -- 588
			Vec2( -- 588
				cx, -- 588
				topY - cam:len(7) -- 588
			), -- 588
			cam:len(11), -- 588
			25, -- 588
			155, -- 588
			1.4, -- 588
			Color(214, 224, 230, 165) -- 588
		) -- 588
	end -- 588
end -- 575
function MingArtAuditPlugin.prototype.drawLeftEndRedClothAccent(self, worldArt, p, cam) -- 592
	local c = p.room.cart -- 593
	local depth = c.depth or 0 -- 594
	local leftEdgeWorldX = p.cartAxle - c.bodyW * 0.54 -- 596
	local anchorX = cam:sx(leftEdgeWorldX) -- 597
	local anchorY = cam:sy(c.baseY + c.wheelR + c.bodyH * 0.86, depth) -- 598
	local frame = math.floor(self.animTime * 4.4) % 3 -- 599
	worldArt:tryPlace( -- 600
		"fe_red_cloth", -- 600
		"ming_cart_red_cloth", -- 600
		anchorX, -- 600
		anchorY, -- 600
		cam:len(22), -- 600
		cam:len(22), -- 600
		{frame = frame, layer = 6} -- 600
	) -- 600
end -- 592
function MingArtAuditPlugin.prototype.runAudit(self, host) -- 607
	local missingBackdrops = {} -- 608
	for roomKey in pairs(____exports.CORE_MING_BACKDROPS) do -- 609
		local slotKey = ____exports.CORE_MING_BACKDROPS[roomKey] -- 610
		local cfg = ASSET_SLOTS[slotKey] -- 611
		local path = cfg ~= nil and #cfg.paths > 0 and cfg.paths[1] or "" -- 612
		if path == "" or not Content:exist(path) then -- 613
			missingBackdrops[#missingBackdrops + 1] = (roomKey .. ":") .. path -- 614
		end -- 614
	end -- 614
	local missingSpriteClips = {} -- 618
	local i = 0 -- 619
	do -- 619
		i = 0 -- 620
		while i < #____exports.MING_PRESERVED_SPRITE_CLIPS do -- 620
			local clipName = ____exports.MING_PRESERVED_SPRITE_CLIPS[i + 1] -- 621
			local path = "assets/art/sprites.clip|" .. clipName -- 622
			if host ~= nil then -- 623
				local ok = host:tryPlacePath( -- 624
					path, -- 624
					"audit_spr_" .. clipName, -- 624
					-9999, -- 624
					-9999, -- 624
					16, -- 624
					16 -- 624
				) -- 624
				if not ok then -- 625
					missingSpriteClips[#missingSpriteClips + 1] = clipName -- 626
				end -- 626
			elseif not Content:exist("assets/art/sprites.clip") then -- 628
				missingSpriteClips[#missingSpriteClips + 1] = clipName -- 629
			end -- 629
			i = i + 1 -- 620
		end -- 620
	end -- 620
	local missingUiClips = {} -- 633
	do -- 633
		i = 0 -- 634
		while i < #____exports.MING_PRESERVED_UI_CLIPS do -- 634
			local uiName = ____exports.MING_PRESERVED_UI_CLIPS[i + 1] -- 635
			local path = "assets/art/ui_ink.clip|" .. uiName -- 636
			if host ~= nil then -- 637
				local ok = host:tryPlacePath( -- 638
					path, -- 638
					"audit_ui_" .. uiName, -- 638
					-9999, -- 638
					-9999, -- 638
					16, -- 638
					16 -- 638
				) -- 638
				if not ok then -- 639
					missingUiClips[#missingUiClips + 1] = uiName -- 640
				end -- 640
			elseif not Content:exist("assets/art/ui_ink.clip") then -- 642
				missingUiClips[#missingUiClips + 1] = uiName -- 643
			end -- 643
			i = i + 1 -- 634
		end -- 634
	end -- 634
	return { -- 647
		coreBackdropsOk = #missingBackdrops == 0, -- 648
		missingBackdrops = missingBackdrops, -- 649
		preservedSpriteClipsCount = #____exports.MING_PRESERVED_SPRITE_CLIPS - #missingSpriteClips, -- 650
		missingSpriteClips = missingSpriteClips, -- 651
		preservedUiClipsCount = #____exports.MING_PRESERVED_UI_CLIPS - #missingUiClips, -- 652
		missingUiClips = missingUiClips, -- 653
		cartClothLeftInvariantOk = self.cartLeftInvariantOk, -- 654
		fallbackInterceptCount = self.fallbackInterceptCount, -- 655
		woodDebrisTriggered = self.woodDebrisCount, -- 656
		brickDebrisTriggered = self.brickDebrisCount, -- 657
		powderSmokeTriggered = self.powderSmokeCount, -- 658
		legacyFindingsCount = #____exports.MING_LEGACY_FINDINGS -- 659
	} -- 659
end -- 607
return ____exports -- 607
