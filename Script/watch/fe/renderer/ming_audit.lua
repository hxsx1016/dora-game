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
	if direct ~= nil then -- 194
		return direct -- 196
	end -- 196
	local mapped = ____exports.FALLBACK_MING_BACKDROPS[roomKey] -- 198
	if mapped ~= nil then -- 198
		return mapped -- 200
	end -- 200
	return "bgFar_street" -- 202
end -- 193
function ____exports.isWoodCoverLabel(art, label) -- 205
	if art == "cover_wood" or art == "thin_wood" or art == "board" or art == "fence" or art == "basket_wall" then -- 205
		return true -- 207
	end -- 207
	if art == "cover_stone" or art == "wall" or art == "gate_post" or art == "well" then -- 207
		return false -- 210
	end -- 210
	if label ~= nil then -- 210
		if (string.find(label, "柜", nil, true) or 0) - 1 >= 0 or (string.find(label, "木", nil, true) or 0) - 1 >= 0 or (string.find(label, "桌", nil, true) or 0) - 1 >= 0 or (string.find(label, "货", nil, true) or 0) - 1 >= 0 or (string.find(label, "棚", nil, true) or 0) - 1 >= 0 or (string.find(label, "栏", nil, true) or 0) - 1 >= 0 then -- 210
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
	if p.room.cart.bodyW > 0 and p.room.cart.clothSide >= 0 then -- 254
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
	if loaded == nil then -- 263
		return -- 265
	end -- 265
	local rawFe = loaded["watch.fe"] -- 267
	if rawFe ~= nil and type(rawFe) == "table" then -- 267
		local watchFe = rawFe -- 269
		if watchFe.mingAudit ~= self then -- 269
			watchFe.mingAudit = self -- 271
		end -- 271
	end -- 271
end -- 261
function MingArtAuditPlugin.prototype.update(self, ctx) -- 276
	self:syncRuntimeHook() -- 277
	local p = ctx.p -- 278
	if self.lastRoomKey ~= "" and self.lastRoomKey ~= p.room.key then -- 278
		self:onBindPlay(p, ctx.view) -- 281
	end -- 281
	if p.room.cart.bodyW > 0 and p.room.cart.clothSide >= 0 then -- 281
		self.cartLeftInvariantOk = false -- 284
	end -- 284
	if ctx.paused or ctx.worldDt <= 0 then -- 284
		return -- 288
	end -- 288
	local dt = ctx.worldDt -- 291
	self.animTime = self.animTime + dt -- 292
	if ctx.events.coverDeflect then -- 292
		self:spawnCoverMaterialDebris(p) -- 296
	end -- 296
	if ctx.events.shotFired and ctx.events.shotTrace ~= nil then -- 296
		local tr = ctx.events.shotTrace -- 301
		self:spawnMatchlockSmoke(tr.x0, tr.y0, tr.x1 >= tr.x0 and 1 or -1) -- 302
		if not tr.hit and tr.y1 <= 42 then -- 302
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
			if c.life > 0 then -- 313
				c.vy = c.vy - (c.isWood and 360 or 210) * dt -- 315
				c.x = c.x + c.vx * dt -- 316
				c.y = c.y + c.vy * dt -- 317
				if c.y < 0 then -- 317
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
	__TS__ArraySetLength(self.chips, w) -- 311
	w = 0 -- 330
	do -- 330
		i = 0 -- 331
		while i < #self.puffs do -- 331
			local pf = self.puffs[i + 1] -- 332
			pf.life = pf.life - dt -- 333
			if pf.life > 0 then -- 333
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
	__TS__ArraySetLength(self.puffs, w) -- 331
end -- 276
function MingArtAuditPlugin.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 350
	local roomKey = ctx.p.room.key -- 356
	if ____exports.CORE_MING_BACKDROPS[roomKey] ~= nil then -- 356
		return false -- 358
	end -- 358
	if ctx.view.visualMode == "lowpoly" or ctx.view.visualMode == "museum" then -- 358
		return false -- 362
	end -- 362
	local slot = ____exports.resolveMingBackdropSlot(roomKey) -- 365
	local cam = ctx.cam -- 366
	local w = cam.viewW -- 367
	local h = cam.viewH -- 368
	local span = math.max(1, ctx.p.room.maxX - ctx.p.room.minX) -- 369
	local progress = (cam.x - ctx.p.room.minX) / span - 0.5 -- 370
	local ground = cam.groundScreenY -- 371
	local artW = math.max(w, h * 16 / 9) + w * 0.12 -- 372
	local artH = artW * 9 / 16 -- 373
	local sceneY = math.min((h - artH) * 0.5, ground - artH * 0.24) -- 375
	if backdropArt:tryPlace( -- 375
		slot, -- 377
		"ming_fallback_scene", -- 377
		w * (0.5 - progress * 0.09), -- 377
		sceneY, -- 377
		artW, -- 377
		artH -- 377
	) then -- 377
		self.fallbackInterceptCount = self.fallbackInterceptCount + 1 -- 378
		local theme = themeOf(roomKey) -- 379
		local outdoorRidge = slot == "bgFar_outside" or slot == "bgFar_escort_ridge" or slot == "bgFar_forest" -- 380
		if outdoorRidge then -- 380
			backdropArt:tryPlace( -- 382
				"pine", -- 383
				"ming_fallback_mid", -- 384
				w * (0.76 - progress * 0.22), -- 385
				ground - cam:len(8), -- 386
				cam:len(122), -- 387
				cam:len(107), -- 388
				{layer = 1, opacity = 0.42} -- 389
			) -- 389
		elseif slot ~= "bgFar_granary" and slot ~= "bgFar_crossroad_drygoods" and slot ~= "bgFar_archway_yard" then -- 389
			backdropArt:tryPlace( -- 392
				"eaves", -- 393
				"ming_fallback_mid", -- 394
				w * (0.74 - progress * 0.25), -- 395
				ground - cam:len(10), -- 396
				cam:len(176), -- 397
				cam:len(96), -- 398
				{layer = 1, opacity = 0.44} -- 399
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
			ground - 1, -- 403
			w, -- 403
			h * 0.14, -- 403
			Color(43, 49, 63, 15), -- 403
			Color(43, 49, 63, 0) -- 403
		) -- 403
		return true -- 404
	end -- 404
	return false -- 406
end -- 350
function MingArtAuditPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 410
	local p = ctx.p -- 416
	local cam = ctx.cam -- 417
	local isPixelStyle = ctx.view.visualMode == "pixel" or ctx.view.visualMode == "transition" -- 418
	if isPixelStyle and p.room.key == "village" then -- 418
		self:drawVillageGrayscaleSurfaces(fgDraw, p, cam) -- 422
	end -- 422
	if isPixelStyle and p.room.key == "forest" then -- 422
		self:drawForestSilhouetteSeparation(fgDraw, p, cam) -- 427
	end -- 427
	if isPixelStyle and (p.room.key == "checkpoint" or p.room.key == "outside") and p.room.cart.bodyW > 0 then -- 427
		self:drawLeftEndRedClothAccent(fgDraw, p, cam) -- 432
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
			if c.isWood then -- 449
				fgDraw:drawRect( -- 452
					Rect(sx - sw * 0.5, sy - sh * 0.5, sw, sh), -- 452
					Color( -- 452
						128, -- 452
						86, -- 452
						54, -- 452
						math.floor(235 * k + 0.5) -- 452
					) -- 452
				) -- 452
				fgDraw:drawSegment( -- 453
					Vec2(sx - sw * 0.5, sy + sh * 0.5), -- 453
					Vec2(sx + sw * 0.5, sy + sh * 0.5), -- 453
					0.9, -- 453
					Color( -- 453
						196, -- 453
						162, -- 453
						118, -- 453
						math.floor(180 * k + 0.5) -- 453
					) -- 453
				) -- 453
			else -- 453
				fgDraw:drawCircle( -- 456
					Vec2(sx, sy), -- 456
					sw * 0.65, -- 456
					Color( -- 456
						164, -- 456
						168, -- 456
						172, -- 456
						math.floor(175 * k + 0.5) -- 456
					) -- 456
				) -- 456
				fgDraw:drawDot( -- 457
					Vec2(sx + 1, sy + 1), -- 457
					math.max(1.2, sw * 0.32), -- 457
					Color( -- 457
						218, -- 457
						220, -- 457
						224, -- 457
						math.floor(210 * k + 0.5) -- 457
					) -- 457
				) -- 457
			end -- 457
			i = i + 1 -- 443
		end -- 443
	end -- 443
	do -- 443
		i = 0 -- 462
		while i < #self.puffs do -- 462
			local pf = self.puffs[i + 1] -- 463
			local k = pf.life / pf.maxLife -- 464
			local sx = cam:sx(pf.x) -- 465
			local sy = cam:sy(pf.y) -- 466
			local r = math.max( -- 467
				2, -- 467
				cam:len(pf.r) -- 467
			) -- 467
			fgDraw:drawCircle( -- 468
				Vec2(sx, sy), -- 468
				r, -- 468
				Color( -- 468
					196, -- 468
					198, -- 468
					200, -- 468
					math.floor(92 * k + 0.5) -- 468
				) -- 468
			) -- 468
			fgGlow:drawCircle( -- 469
				Vec2(sx, sy), -- 469
				r * 0.62, -- 469
				Color( -- 469
					224, -- 469
					222, -- 469
					214, -- 469
					math.floor(48 * k + 0.5) -- 469
				) -- 469
			) -- 469
			i = i + 1 -- 462
		end -- 462
	end -- 462
end -- 410
function MingArtAuditPlugin.prototype.spawnCoverMaterialDebris(self, p) -- 473
	local hitX = p.player.x + p.player.facing * 16 -- 474
	local hitY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.5 -- 475
	local isWood = false -- 476
	local nearest = 56 -- 477
	local i = 0 -- 478
	do -- 478
		i = 0 -- 479
		while i < #p.room.solids do -- 479
			do -- 479
				local s = p.room.solids[i + 1] -- 480
				if s.passable or s.decorative or s.y > p.player.y + 4 or s.h > 72 then -- 480
					goto __continue52 -- 482
				end -- 482
				if not overlapsDepth(p.player.depth, s.depth, ACTOR_DEPTH_HALF) then -- 482
					goto __continue52 -- 485
				end -- 485
				local edge = p.player.x < s.x and s.x or s.x + s.w -- 487
				local gap = math.abs(p.player.x - edge) -- 488
				if gap < nearest then -- 488
					nearest = gap -- 490
					hitX = edge -- 491
					local ____s_y_3 = s.y -- 492
					local ____opt_1 = s.depth -- 492
					hitY = ____s_y_3 + (____opt_1 and ____opt_1.min or 0) * DEPTH_Y_SCALE + s.h * 0.85 -- 492
					isWood = ____exports.isWoodCoverLabel(s.art, s.label) -- 493
				end -- 493
			end -- 493
			::__continue52:: -- 493
			i = i + 1 -- 479
		end -- 479
	end -- 479
	if isWood then -- 479
		self.woodDebrisCount = self.woodDebrisCount + 1 -- 498
	else -- 498
		self.brickDebrisCount = self.brickDebrisCount + 1 -- 500
	end -- 500
	local count = isWood and 9 or 10 -- 503
	do -- 503
		i = 0 -- 504
		while i < count do -- 504
			local ang = (self:rand() - 0.5) * math.pi * 1.15 -- 505
			local spd = (isWood and 85 or 58) * (0.45 + self:rand() * 0.75) -- 506
			local life = (isWood and 0.34 or 0.42) + self:rand() * 0.16 -- 507
			local ____self_chips_4 = self.chips -- 507
			____self_chips_4[#____self_chips_4 + 1] = { -- 508
				x = hitX, -- 509
				y = hitY, -- 510
				vx = -p.player.facing * math.abs(math.cos(ang)) * spd + (self:rand() - 0.5) * 35, -- 511
				vy = math.abs(math.sin(ang)) * spd + (isWood and 55 or 28), -- 512
				w = isWood and 4.5 + self:rand() * 3.5 or 2.6 + self:rand() * 2.8, -- 513
				h = isWood and 1.8 + self:rand() * 1.4 or 2.6 + self:rand() * 2.8, -- 514
				life = life, -- 515
				maxLife = life, -- 516
				isWood = isWood -- 517
			} -- 517
			i = i + 1 -- 504
		end -- 504
	end -- 504
end -- 473
function MingArtAuditPlugin.prototype.spawnMatchlockSmoke(self, wx, wy, dir) -- 522
	self.powderSmokeCount = self.powderSmokeCount + 1 -- 523
	local i = 0 -- 524
	do -- 524
		i = 0 -- 525
		while i < 5 do -- 525
			local life = 0.24 + self:rand() * 0.18 -- 526
			local ____self_puffs_5 = self.puffs -- 526
			____self_puffs_5[#____self_puffs_5 + 1] = { -- 527
				x = wx + dir * (4 + i * 3.5), -- 528
				y = wy + (self:rand() - 0.4) * 5, -- 529
				vx = dir * (28 + self:rand() * 44), -- 530
				vy = 14 + self:rand() * 22, -- 531
				r = 3 + self:rand() * 2.4, -- 532
				life = life, -- 533
				maxLife = life -- 534
			} -- 534
			i = i + 1 -- 525
		end -- 525
	end -- 525
end -- 522
function MingArtAuditPlugin.prototype.addScorch(self, wx, wy) -- 539
	local ____self_scorches_6 = self.scorches -- 539
	____self_scorches_6[#____self_scorches_6 + 1] = { -- 540
		x = wx, -- 540
		y = wy, -- 540
		rx = 5.5 + self:rand() * 3 -- 540
	} -- 540
	if #self.scorches > 16 then -- 540
		table.remove(self.scorches, 1) -- 542
	end -- 542
end -- 539
function MingArtAuditPlugin.prototype.drawVillageGrayscaleSurfaces(self, fgDraw, p, cam) -- 546
	local y0 = cam:sy(0) -- 547
	if p.room.brickX ~= nil then -- 547
		local bx0 = cam:sx(p.room.brickX - 18) -- 551
		local bx1 = cam:sx(p.room.brickX + 18) -- 552
		local bw = bx1 - bx0 -- 553
		local bh = math.max( -- 554
			7, -- 554
			cam:len(4.5) -- 554
		) -- 554
		fgDraw:drawRect( -- 555
			Rect(bx0, y0 - bh * 0.4, bw, bh), -- 555
			Color(142, 146, 150, 235), -- 555
			1, -- 555
			Color(216, 220, 224, 220) -- 555
		) -- 555
		fgDraw:drawSegment( -- 557
			Vec2(bx0 + 1, y0 + bh * 0.1), -- 557
			Vec2(bx1 - 1, y0 + bh * 0.1), -- 557
			1, -- 557
			Color(42, 44, 48, 225) -- 557
		) -- 557
		local k = 1 -- 558
		do -- 558
			k = 1 -- 559
			while k <= 3 do -- 559
				local jx = bx0 + bw * k / 4 -- 560
				fgDraw:drawSegment( -- 561
					Vec2(jx, y0 - bh * 0.4), -- 561
					Vec2(jx, y0 + bh * 0.1), -- 561
					1, -- 561
					Color(42, 44, 48, 225) -- 561
				) -- 561
				k = k + 1 -- 559
			end -- 559
		end -- 559
		do -- 559
			k = 1 -- 563
			while k <= 2 do -- 563
				local jx = bx0 + bw * (k + 0.35) / 3 -- 564
				fgDraw:drawSegment( -- 565
					Vec2(jx, y0 + bh * 0.1), -- 565
					Vec2(jx, y0 + bh * 0.6), -- 565
					1, -- 565
					Color(42, 44, 48, 225) -- 565
				) -- 565
				k = k + 1 -- 563
			end -- 563
		end -- 563
		fgDraw:drawSegment( -- 568
			Vec2(bx0, y0 + bh * 0.6), -- 568
			Vec2(bx1, y0 + bh * 0.6), -- 568
			1.6, -- 568
			Color(232, 234, 236, 230) -- 568
		) -- 568
	end -- 568
	if p.room.softX ~= nil then -- 568
		local sx0 = cam:sx(p.room.softX - 18) -- 573
		local sx1 = cam:sx(p.room.softX + 18) -- 574
		local sw = sx1 - sx0 -- 575
		fgDraw:drawRect( -- 576
			Rect(sx0, y0 - 3, sw, 6), -- 576
			Color(54, 44, 36, 225) -- 576
		) -- 576
		local dotOffsets = { -- 578
			0.1, -- 578
			0.24, -- 578
			0.37, -- 578
			0.51, -- 578
			0.68, -- 578
			0.81, -- 578
			0.92 -- 578
		} -- 578
		local d = 0 -- 579
		do -- 579
			d = 0 -- 580
			while d < #dotOffsets do -- 580
				local dx = sx0 + sw * dotOffsets[d + 1] -- 581
				local dy = y0 + (d & 1 == 0 and 1.5 or -1.2) -- 582
				fgDraw:drawDot( -- 583
					Vec2(dx, dy), -- 583
					1.5, -- 583
					Color(96, 82, 68, 215) -- 583
				) -- 583
				d = d + 1 -- 580
			end -- 580
		end -- 580
		local fp = 0 -- 586
		do -- 586
			fp = 0 -- 587
			while fp < 3 do -- 587
				local fx = sx0 + sw * (0.22 + fp * 0.28) -- 588
				fgDraw:drawEllipse( -- 589
					Vec2(fx, y0 + 1.2), -- 589
					math.max( -- 589
						3, -- 589
						cam:len(2.4) -- 589
					), -- 589
					1.6, -- 589
					Color(34, 28, 24, 210) -- 589
				) -- 589
				fp = fp + 1 -- 587
			end -- 587
		end -- 587
	end -- 587
end -- 546
function MingArtAuditPlugin.prototype.drawForestSilhouetteSeparation(self, fgDraw, p, cam) -- 594
	local childInGrass = false -- 596
	local dogInGrass = false -- 597
	local i = 0 -- 598
	do -- 598
		i = 0 -- 599
		while i < #p.room.solids do -- 599
			do -- 599
				local s = p.room.solids[i + 1] -- 600
				if s.passable ~= true then -- 600
					goto __continue78 -- 602
				end -- 602
				if p.player.x >= s.x - 16 and p.player.x <= s.x + s.w + 16 then -- 602
					childInGrass = true -- 605
				end -- 605
				if p.dogX >= s.x - 24 and p.dogX <= s.x + s.w + 24 then -- 605
					dogInGrass = true -- 608
				end -- 608
			end -- 608
			::__continue78:: -- 608
			i = i + 1 -- 599
		end -- 599
	end -- 599
	if childInGrass and p.player.alive then -- 599
		local cx = cam:sx(p.player.x) -- 613
		local topY = cam:sy(p.player.y + p.player.h) -- 614
		local halfW = cam:len(11) -- 615
		fgDraw:drawArc( -- 617
			Vec2( -- 617
				cx, -- 617
				topY - cam:len(7) -- 617
			), -- 617
			halfW, -- 617
			25, -- 617
			155, -- 617
			1.5, -- 617
			Color(214, 224, 230, 175) -- 617
		) -- 617
	end -- 617
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 617
		local alert = p.dogState == "ear" or p.dogState == "chase" -- 621
		if dogInGrass or alert then -- 621
			local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 623
			local dx = cam:sx(p.dogX + f * 12) -- 624
			local dy = cam:sy(24) -- 625
			local earH = cam:len(alert and 7.5 or 5) -- 626
			local earCol = alert and Color(238, 232, 222, 225) or Color(196, 206, 212, 175) -- 627
			fgDraw:drawSegment( -- 629
				Vec2(dx - f * 3, dy), -- 629
				Vec2(dx - f * 1, dy + earH), -- 629
				1.6, -- 629
				earCol -- 629
			) -- 629
			fgDraw:drawSegment( -- 630
				Vec2(dx - f * 1, dy + earH), -- 630
				Vec2(dx + f * 3, dy + 1), -- 630
				1.5, -- 630
				earCol -- 630
			) -- 630
		end -- 630
	end -- 630
end -- 594
function MingArtAuditPlugin.prototype.drawLeftEndRedClothAccent(self, fgDraw, p, cam) -- 635
	local c = p.room.cart -- 636
	local depth = c.depth or 0 -- 637
	local leftEdgeWorldX = p.cartAxle - c.bodyW * 0.56 -- 639
	local anchorX = cam:sx(leftEdgeWorldX) -- 640
	local anchorY = cam:sy(c.baseY + c.wheelR + c.bodyH * 0.85, depth) -- 641
	local sway = math.sin(self.animTime * 3.1) * cam:len(3.5) -- 642
	local len = cam:len(13) -- 643
	local drop = cam:len(15) -- 644
	fgDraw:drawPolygon( -- 646
		{ -- 646
			Vec2(anchorX, anchorY), -- 647
			Vec2(anchorX - len * 0.45, anchorY - drop * 0.42), -- 648
			Vec2(anchorX - len + sway, anchorY - drop), -- 649
			Vec2(anchorX - len * 0.55 + sway * 0.6, anchorY - drop * 0.86), -- 650
			Vec2( -- 651
				anchorX + cam:len(2), -- 651
				anchorY - drop * 0.25 -- 651
			) -- 651
		}, -- 651
		toColor(PALETTE.clothRed, 220) -- 652
	) -- 652
	fgDraw:drawSegment( -- 653
		Vec2(anchorX, anchorY), -- 654
		Vec2(anchorX - len + sway, anchorY - drop), -- 655
		1.2, -- 656
		toColor(PALETTE.clothRedHighlight, 200) -- 657
	) -- 657
end -- 635
function MingArtAuditPlugin.prototype.runAudit(self, host) -- 662
	local missingBackdrops = {} -- 663
	for roomKey in pairs(____exports.CORE_MING_BACKDROPS) do -- 664
		local slotKey = ____exports.CORE_MING_BACKDROPS[roomKey] -- 665
		local cfg = ASSET_SLOTS[slotKey] -- 666
		local path = cfg ~= nil and #cfg.paths > 0 and cfg.paths[1] or "" -- 667
		if path == "" or not Content:exist(path) then -- 667
			missingBackdrops[#missingBackdrops + 1] = (roomKey .. ":") .. path -- 669
		end -- 669
	end -- 669
	local missingSpriteClips = {} -- 673
	local i = 0 -- 674
	do -- 674
		i = 0 -- 675
		while i < #____exports.MING_PRESERVED_SPRITE_CLIPS do -- 675
			local clipName = ____exports.MING_PRESERVED_SPRITE_CLIPS[i + 1] -- 676
			local path = "assets/art/sprites.clip|" .. clipName -- 677
			if host ~= nil then -- 677
				local ok = host:tryPlacePath( -- 679
					path, -- 679
					"audit_spr_" .. clipName, -- 679
					-9999, -- 679
					-9999, -- 679
					16, -- 679
					16 -- 679
				) -- 679
				if not ok then -- 679
					missingSpriteClips[#missingSpriteClips + 1] = clipName -- 681
				end -- 681
			elseif not Content:exist("assets/art/sprites.clip") then -- 681
				missingSpriteClips[#missingSpriteClips + 1] = clipName -- 684
			end -- 684
			i = i + 1 -- 675
		end -- 675
	end -- 675
	local missingUiClips = {} -- 688
	do -- 688
		i = 0 -- 689
		while i < #____exports.MING_PRESERVED_UI_CLIPS do -- 689
			local uiName = ____exports.MING_PRESERVED_UI_CLIPS[i + 1] -- 690
			local path = "assets/art/ui_ink.clip|" .. uiName -- 691
			if host ~= nil then -- 691
				local ok = host:tryPlacePath( -- 693
					path, -- 693
					"audit_ui_" .. uiName, -- 693
					-9999, -- 693
					-9999, -- 693
					16, -- 693
					16 -- 693
				) -- 693
				if not ok then -- 693
					missingUiClips[#missingUiClips + 1] = uiName -- 695
				end -- 695
			elseif not Content:exist("assets/art/ui_ink.clip") then -- 695
				missingUiClips[#missingUiClips + 1] = uiName -- 698
			end -- 698
			i = i + 1 -- 689
		end -- 689
	end -- 689
	return { -- 702
		coreBackdropsOk = #missingBackdrops == 0, -- 703
		missingBackdrops = missingBackdrops, -- 704
		preservedSpriteClipsCount = #____exports.MING_PRESERVED_SPRITE_CLIPS - #missingSpriteClips, -- 705
		missingSpriteClips = missingSpriteClips, -- 706
		preservedUiClipsCount = #____exports.MING_PRESERVED_UI_CLIPS - #missingUiClips, -- 707
		missingUiClips = missingUiClips, -- 708
		cartClothLeftInvariantOk = self.cartLeftInvariantOk, -- 709
		fallbackInterceptCount = self.fallbackInterceptCount, -- 710
		woodDebrisTriggered = self.woodDebrisCount, -- 711
		brickDebrisTriggered = self.brickDebrisCount, -- 712
		powderSmokeTriggered = self.powderSmokeCount, -- 713
		legacyFindingsCount = #____exports.MING_LEGACY_FINDINGS -- 714
	} -- 714
end -- 662
return ____exports -- 662