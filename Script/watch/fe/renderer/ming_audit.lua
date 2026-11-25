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
--- 非八房战役/护送段到明朝像素底图的映射表（杜绝探照灯与工业钢架退化；已覆盖 B2 escort2-5）
____exports.FALLBACK_MING_BACKDROPS = { -- 65
	["s1-crossroad"] = "bgFar_street", -- 66
	["s2-drygoods"] = "bgFar_street", -- 67
	["s3-archway"] = "bgFar_street", -- 68
	["c1-yard"] = "bgFar_checkpoint", -- 69
	["c2-granary"] = "bgFar_checkpoint", -- 70
	gatepath = "bgFar_outside", -- 71
	escort1 = "bgFar_outside", -- 72
	escort2 = "bgFar_checkpoint", -- 73
	escort3 = "bgFar_checkpoint", -- 74
	escort4 = "bgFar_forest", -- 75
	escort5 = "bgFar_tower" -- 76
} -- 76
--- 检出的 6 处既有热点渲染文件赛博/全息遗留（方案 A：记录清单，不修改热点文件，交 M1 / fe-07 收口）
____exports.MING_LEGACY_FINDINGS = { -- 92
	{ -- 93
		id = "MING-01", -- 94
		file = "Script/watch/fe/theme.ts & Script/watch/fe/renderer/stage.ts", -- 95
		lines = "theme.ts:160,189,218,247; stage.ts:166-274,329-508", -- 96
		severity = "high", -- 97
		summary = "showSearchlights=true 与无 bgFar 退化路径包含扫射探照灯、屋顶天线、工业钢桁架、垂落电缆及破损电灯", -- 98
		mitigationInFe03 = "MingArtAuditPlugin.drawBackdrop 拦截全部非八房房间并映射至明朝像素底图，运行期 0 触发探照灯", -- 99
		targetFixPhase = "M1 / fe-07" -- 100
	}, -- 100
	{ -- 102
		id = "MING-02", -- 103
		file = "Script/watch/fe/renderer/stage.ts", -- 104
		lines = "stage.ts:844-857", -- 105
		severity = "high", -- 106
		summary = "drawCoverBlock 在贴靠掩体时绘制冰青全息护盾竖条与大面积荧光蓝光晕", -- 107
		mitigationInFe03 = "审计报告标注待改为木沿/砖沿低饱和描边，本分支不改动 stage.ts 保持零冲突", -- 108
		targetFixPhase = "M1 / fe-07" -- 109
	}, -- 109
	{ -- 111
		id = "MING-03", -- 112
		file = "Script/watch/fe/renderer/stage.ts", -- 113
		lines = "stage.ts:860-891", -- 114
		severity = "medium", -- 115
		summary = "drawWinch 在 prop_winch 下层仍绘倒角钢箱与闪烁冰青/琥珀电子状态灯", -- 116
		mitigationInFe03 = "待改为纯木铁绞盘实体与绳链张力表现", -- 117
		targetFixPhase = "M1 / fe-07" -- 118
	}, -- 118
	{ -- 120
		id = "MING-04", -- 121
		file = "Script/watch/fe/renderer/stage.ts", -- 122
		lines = "stage.ts:1047-1059", -- 123
		severity = "medium", -- 124
		summary = "drawArch 城外矮拱绘制亮银矩形外框与冰蓝发光竖渐变，与周边明代灰砖质感割裂", -- 125
		mitigationInFe03 = "fe-04 低模城外将接管城外舞台；像素线待在 fe-07 改为石拱券砖沿", -- 126
		targetFixPhase = "fe-04 / fe-07" -- 127
	}, -- 127
	{ -- 129
		id = "MING-05", -- 130
		file = "Script/watch/fe/renderer/props.ts", -- 131
		lines = "props.ts:78-83,100-153,242-245,307", -- 132
		severity = "high", -- 133
		summary = "存在危险区红激光扫描线、全息检查点菱柱、车柄发光黄球、钢杆灯柱及村口瓶架贴图纵拉变形", -- 134
		mitigationInFe03 = "ming_audit.ts 补强村口砖缝/软土灰度纹样与左端红布校验；全息标与黄球留待 fe-07 清理", -- 135
		targetFixPhase = "fe-07" -- 136
	}, -- 136
	{ -- 138
		id = "MING-06", -- 139
		file = "Script/watch/fe/renderer/actors.ts", -- 140
		lines = "actors.ts:66-83,145-171", -- 141
		severity = "medium", -- 142
		summary = "周戍翻滚仍生成 ICEY 冰青残影，不符合明代守卒写实基调且与 fe-06 穿梭器残影彩蛋语义重叠", -- 143
		mitigationInFe03 = "审计报告标注待改为扬尘步烟，残影视觉专属留给 fe-06 穿梭器彩蛋", -- 144
		targetFixPhase = "M2 / fe-07" -- 145
	} -- 145
} -- 145
function ____exports.resolveMingBackdropSlot(roomKey) -- 192
	local direct = ____exports.CORE_MING_BACKDROPS[roomKey] -- 193
	if direct ~= nil then -- 193
		return direct -- 195
	end -- 195
	local mapped = ____exports.FALLBACK_MING_BACKDROPS[roomKey] -- 197
	if mapped ~= nil then -- 197
		return mapped -- 199
	end -- 199
	return "bgFar_street" -- 201
end -- 192
function ____exports.isWoodCoverLabel(art, label) -- 204
	if art == "cover_wood" or art == "thin_wood" or art == "board" or art == "fence" or art == "basket_wall" then -- 204
		return true -- 206
	end -- 206
	if art == "cover_stone" or art == "wall" or art == "gate_post" or art == "well" then -- 206
		return false -- 209
	end -- 209
	if label ~= nil then -- 209
		if (string.find(label, "柜", nil, true) or 0) - 1 >= 0 or (string.find(label, "木", nil, true) or 0) - 1 >= 0 or (string.find(label, "桌", nil, true) or 0) - 1 >= 0 or (string.find(label, "货", nil, true) or 0) - 1 >= 0 or (string.find(label, "棚", nil, true) or 0) - 1 >= 0 or (string.find(label, "栏", nil, true) or 0) - 1 >= 0 then -- 209
			return true -- 220
		end -- 220
	end -- 220
	return false -- 223
end -- 204
____exports.MingArtAuditPlugin = __TS__Class() -- 226
local MingArtAuditPlugin = ____exports.MingArtAuditPlugin -- 226
MingArtAuditPlugin.name = "MingArtAuditPlugin" -- 226
function MingArtAuditPlugin.prototype.____constructor(self) -- 226
	self.id = "fe03-ming-audit" -- 227
	self.chips = {} -- 229
	self.puffs = {} -- 230
	self.scorches = {} -- 231
	self.animTime = 0 -- 232
	self.rng = 4099 -- 233
	self.fallbackInterceptCount = 0 -- 236
	self.woodDebrisCount = 0 -- 237
	self.brickDebrisCount = 0 -- 238
	self.powderSmokeCount = 0 -- 239
	self.cartLeftInvariantOk = true -- 240
	self.lastRoomKey = "" -- 241
end -- 226
function MingArtAuditPlugin.prototype.rand(self) -- 243
	self.rng = (self.rng * 1664525 + 1013904223) % 4294967296 -- 244
	return self.rng / 4294967296 -- 245
end -- 243
function MingArtAuditPlugin.prototype.onBindPlay(self, p, _view) -- 248
	self.chips = {} -- 249
	self.puffs = {} -- 250
	self.scorches = {} -- 251
	self.animTime = 0 -- 252
	self.lastRoomKey = p.room.key -- 253
	if p.room.cart.bodyW > 0 and p.room.cart.clothSide >= 0 then -- 253
		self.cartLeftInvariantOk = false -- 255
	end -- 255
	self:syncRuntimeHook() -- 257
end -- 248
function MingArtAuditPlugin.prototype.syncRuntimeHook(self) -- 260
	local g = _G -- 261
	local ____temp_0 -- 262
	if g.package ~= nil then -- 262
		____temp_0 = g.package.loaded -- 262
	else -- 262
		____temp_0 = nil -- 262
	end -- 262
	local loaded = ____temp_0 -- 262
	if loaded == nil then -- 262
		return -- 264
	end -- 264
	local rawFe = loaded["watch.fe"] -- 266
	if rawFe ~= nil and type(rawFe) == "table" then -- 266
		local watchFe = rawFe -- 268
		if watchFe.mingAudit ~= self then -- 268
			watchFe.mingAudit = self -- 270
		end -- 270
	end -- 270
end -- 260
function MingArtAuditPlugin.prototype.update(self, ctx) -- 275
	self:syncRuntimeHook() -- 276
	local p = ctx.p -- 277
	if self.lastRoomKey ~= "" and self.lastRoomKey ~= p.room.key then -- 277
		self:onBindPlay(p, ctx.view) -- 280
	end -- 280
	if p.room.cart.bodyW > 0 and p.room.cart.clothSide >= 0 then -- 280
		self.cartLeftInvariantOk = false -- 283
	end -- 283
	if ctx.paused or ctx.worldDt <= 0 then -- 283
		return -- 287
	end -- 287
	local dt = ctx.worldDt -- 290
	self.animTime = self.animTime + dt -- 291
	if ctx.events.coverDeflect then -- 291
		self:spawnCoverMaterialDebris(p) -- 295
	end -- 295
	if ctx.events.shotFired and ctx.events.shotTrace ~= nil then -- 295
		local tr = ctx.events.shotTrace -- 300
		self:spawnMatchlockSmoke(tr.x0, tr.y0, tr.x1 >= tr.x0 and 1 or -1) -- 301
		if not tr.hit and tr.y1 <= 42 then -- 301
			self:addScorch( -- 303
				tr.x1, -- 303
				math.max(0, tr.y1) -- 303
			) -- 303
		end -- 303
	end -- 303
	local w = 0 -- 308
	local i = 0 -- 309
	do -- 309
		i = 0 -- 310
		while i < #self.chips do -- 310
			local c = self.chips[i + 1] -- 311
			c.life = c.life - dt -- 312
			if c.life > 0 then -- 312
				c.vy = c.vy - (c.isWood and 360 or 210) * dt -- 314
				c.x = c.x + c.vx * dt -- 315
				c.y = c.y + c.vy * dt -- 316
				if c.y < 0 then -- 316
					c.y = 0 -- 318
					c.vy = -c.vy * 0.25 -- 319
					c.vx = c.vx * 0.65 -- 320
				end -- 320
				self.chips[w + 1] = c -- 322
				w = w + 1 -- 323
			end -- 323
			i = i + 1 -- 310
		end -- 310
	end -- 310
	__TS__ArraySetLength(self.chips, w) -- 310
	w = 0 -- 329
	do -- 329
		i = 0 -- 330
		while i < #self.puffs do -- 330
			local pf = self.puffs[i + 1] -- 331
			pf.life = pf.life - dt -- 332
			if pf.life > 0 then -- 332
				pf.x = pf.x + pf.vx * dt -- 334
				pf.y = pf.y + pf.vy * dt -- 335
				pf.vx = pf.vx * math.max(0, 1 - dt * 3.4) -- 336
				pf.r = pf.r + dt * 14 -- 337
				self.puffs[w + 1] = pf -- 338
				w = w + 1 -- 339
			end -- 339
			i = i + 1 -- 330
		end -- 330
	end -- 330
	__TS__ArraySetLength(self.puffs, w) -- 330
end -- 275
function MingArtAuditPlugin.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 349
	local roomKey = ctx.p.room.key -- 355
	if ____exports.CORE_MING_BACKDROPS[roomKey] ~= nil then -- 355
		return false -- 357
	end -- 357
	if ctx.view.visualMode == "lowpoly" or ctx.view.visualMode == "museum" then -- 357
		return false -- 361
	end -- 361
	local slot = ____exports.resolveMingBackdropSlot(roomKey) -- 364
	local cam = ctx.cam -- 365
	local w = cam.viewW -- 366
	local h = cam.viewH -- 367
	local span = math.max(1, ctx.p.room.maxX - ctx.p.room.minX) -- 368
	local progress = (cam.x - ctx.p.room.minX) / span - 0.5 -- 369
	local artW = math.max(w, h * 16 / 9) + w * 0.12 -- 370
	local artH = artW * 9 / 16 -- 371
	if backdropArt:tryPlace( -- 371
		slot, -- 373
		"ming_fallback_scene", -- 373
		w * (0.5 - progress * 0.09), -- 373
		(h - artH) * 0.5, -- 373
		artW, -- 373
		artH -- 373
	) then -- 373
		self.fallbackInterceptCount = self.fallbackInterceptCount + 1 -- 374
		local theme = themeOf(roomKey) -- 375
		local ground = cam.groundScreenY -- 376
		local dressSlot = slot == "bgFar_outside" and "pine" or "eaves" -- 377
		backdropArt:tryPlace( -- 378
			dressSlot, -- 379
			"ming_fallback_mid", -- 380
			w * (0.74 - progress * 0.25), -- 381
			ground - cam:len(10), -- 382
			cam:len(dressSlot == "pine" and 124 or 186), -- 383
			cam:len(dressSlot == "pine" and 138 or 104), -- 384
			{layer = 1, opacity = 0.46} -- 385
		) -- 385
		fillVGradRect( -- 387
			bgDraw, -- 387
			0, -- 387
			0, -- 387
			w, -- 387
			h, -- 387
			toColor(PALETTE.voidDark), -- 387
			toColor(theme.skyMid) -- 387
		) -- 387
		fillVGradRect( -- 388
			bgGlow, -- 388
			0, -- 388
			ground - 1, -- 388
			w, -- 388
			h * 0.14, -- 388
			Color(43, 49, 63, 15), -- 388
			Color(43, 49, 63, 0) -- 388
		) -- 388
		return true -- 389
	end -- 389
	return false -- 391
end -- 349
function MingArtAuditPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 395
	local p = ctx.p -- 401
	local cam = ctx.cam -- 402
	local isPixelStyle = ctx.view.visualMode == "pixel" or ctx.view.visualMode == "transition" -- 403
	if isPixelStyle and p.room.key == "village" then -- 403
		self:drawVillageGrayscaleSurfaces(fgDraw, p, cam) -- 407
	end -- 407
	if isPixelStyle and p.room.key == "forest" then -- 407
		self:drawForestSilhouetteSeparation(fgDraw, p, cam) -- 412
	end -- 412
	if isPixelStyle and (p.room.key == "checkpoint" or p.room.key == "outside") and p.room.cart.bodyW > 0 then -- 412
		self:drawLeftEndRedClothAccent(fgDraw, p, cam) -- 417
	end -- 417
	local i = 0 -- 421
	do -- 421
		i = 0 -- 422
		while i < #self.scorches do -- 422
			local sc = self.scorches[i + 1] -- 423
			fgDraw:drawEllipse( -- 424
				Vec2( -- 424
					cam:sx(sc.x), -- 424
					cam:sy(sc.y) + 2 -- 424
				), -- 424
				cam:len(sc.rx), -- 424
				cam:len(2.4), -- 424
				Color(16, 14, 15, 165) -- 424
			) -- 424
			i = i + 1 -- 422
		end -- 422
	end -- 422
	do -- 422
		i = 0 -- 428
		while i < #self.chips do -- 428
			local c = self.chips[i + 1] -- 429
			local k = c.life / c.maxLife -- 430
			local sx = cam:sx(c.x) -- 431
			local sy = cam:sy(c.y) -- 432
			local sw = math.max( -- 433
				2, -- 433
				cam:len(c.w) -- 433
			) -- 433
			local sh = math.max( -- 434
				1.5, -- 434
				cam:len(c.h) -- 434
			) -- 434
			if c.isWood then -- 434
				fgDraw:drawRect( -- 437
					Rect(sx - sw * 0.5, sy - sh * 0.5, sw, sh), -- 437
					Color( -- 437
						128, -- 437
						86, -- 437
						54, -- 437
						math.floor(235 * k + 0.5) -- 437
					) -- 437
				) -- 437
				fgDraw:drawSegment( -- 438
					Vec2(sx - sw * 0.5, sy + sh * 0.5), -- 438
					Vec2(sx + sw * 0.5, sy + sh * 0.5), -- 438
					0.9, -- 438
					Color( -- 438
						196, -- 438
						162, -- 438
						118, -- 438
						math.floor(180 * k + 0.5) -- 438
					) -- 438
				) -- 438
			else -- 438
				fgDraw:drawCircle( -- 441
					Vec2(sx, sy), -- 441
					sw * 0.65, -- 441
					Color( -- 441
						164, -- 441
						168, -- 441
						172, -- 441
						math.floor(175 * k + 0.5) -- 441
					) -- 441
				) -- 441
				fgDraw:drawDot( -- 442
					Vec2(sx + 1, sy + 1), -- 442
					math.max(1.2, sw * 0.32), -- 442
					Color( -- 442
						218, -- 442
						220, -- 442
						224, -- 442
						math.floor(210 * k + 0.5) -- 442
					) -- 442
				) -- 442
			end -- 442
			i = i + 1 -- 428
		end -- 428
	end -- 428
	do -- 428
		i = 0 -- 447
		while i < #self.puffs do -- 447
			local pf = self.puffs[i + 1] -- 448
			local k = pf.life / pf.maxLife -- 449
			local sx = cam:sx(pf.x) -- 450
			local sy = cam:sy(pf.y) -- 451
			local r = math.max( -- 452
				2, -- 452
				cam:len(pf.r) -- 452
			) -- 452
			fgDraw:drawCircle( -- 453
				Vec2(sx, sy), -- 453
				r, -- 453
				Color( -- 453
					196, -- 453
					198, -- 453
					200, -- 453
					math.floor(92 * k + 0.5) -- 453
				) -- 453
			) -- 453
			fgGlow:drawCircle( -- 454
				Vec2(sx, sy), -- 454
				r * 0.62, -- 454
				Color( -- 454
					224, -- 454
					222, -- 454
					214, -- 454
					math.floor(48 * k + 0.5) -- 454
				) -- 454
			) -- 454
			i = i + 1 -- 447
		end -- 447
	end -- 447
end -- 395
function MingArtAuditPlugin.prototype.spawnCoverMaterialDebris(self, p) -- 458
	local hitX = p.player.x + p.player.facing * 16 -- 459
	local hitY = p.player.y + p.player.depth + p.player.h * 0.5 -- 460
	local isWood = false -- 461
	local nearest = 56 -- 462
	local i = 0 -- 463
	do -- 463
		i = 0 -- 464
		while i < #p.room.solids do -- 464
			do -- 464
				local s = p.room.solids[i + 1] -- 465
				if s.passable or s.decorative or s.y > p.player.y + 4 or s.h > 72 then -- 465
					goto __continue50 -- 467
				end -- 467
				if not overlapsDepth(p.player.depth, s.depth, ACTOR_DEPTH_HALF) then -- 467
					goto __continue50 -- 470
				end -- 470
				local edge = p.player.x < s.x and s.x or s.x + s.w -- 472
				local gap = math.abs(p.player.x - edge) -- 473
				if gap < nearest then -- 473
					nearest = gap -- 475
					hitX = edge -- 476
					local ____s_y_3 = s.y -- 477
					local ____opt_1 = s.depth -- 477
					hitY = ____s_y_3 + (____opt_1 and ____opt_1.min or 0) + s.h * 0.85 -- 477
					isWood = ____exports.isWoodCoverLabel(s.art, s.label) -- 478
				end -- 478
			end -- 478
			::__continue50:: -- 478
			i = i + 1 -- 464
		end -- 464
	end -- 464
	if isWood then -- 464
		self.woodDebrisCount = self.woodDebrisCount + 1 -- 483
	else -- 483
		self.brickDebrisCount = self.brickDebrisCount + 1 -- 485
	end -- 485
	local count = isWood and 9 or 10 -- 488
	do -- 488
		i = 0 -- 489
		while i < count do -- 489
			local ang = (self:rand() - 0.5) * math.pi * 1.15 -- 490
			local spd = (isWood and 85 or 58) * (0.45 + self:rand() * 0.75) -- 491
			local life = (isWood and 0.34 or 0.42) + self:rand() * 0.16 -- 492
			local ____self_chips_4 = self.chips -- 492
			____self_chips_4[#____self_chips_4 + 1] = { -- 493
				x = hitX, -- 494
				y = hitY, -- 495
				vx = -p.player.facing * math.abs(math.cos(ang)) * spd + (self:rand() - 0.5) * 35, -- 496
				vy = math.abs(math.sin(ang)) * spd + (isWood and 55 or 28), -- 497
				w = isWood and 4.5 + self:rand() * 3.5 or 2.6 + self:rand() * 2.8, -- 498
				h = isWood and 1.8 + self:rand() * 1.4 or 2.6 + self:rand() * 2.8, -- 499
				life = life, -- 500
				maxLife = life, -- 501
				isWood = isWood -- 502
			} -- 502
			i = i + 1 -- 489
		end -- 489
	end -- 489
end -- 458
function MingArtAuditPlugin.prototype.spawnMatchlockSmoke(self, wx, wy, dir) -- 507
	self.powderSmokeCount = self.powderSmokeCount + 1 -- 508
	local i = 0 -- 509
	do -- 509
		i = 0 -- 510
		while i < 5 do -- 510
			local life = 0.24 + self:rand() * 0.18 -- 511
			local ____self_puffs_5 = self.puffs -- 511
			____self_puffs_5[#____self_puffs_5 + 1] = { -- 512
				x = wx + dir * (4 + i * 3.5), -- 513
				y = wy + (self:rand() - 0.4) * 5, -- 514
				vx = dir * (28 + self:rand() * 44), -- 515
				vy = 14 + self:rand() * 22, -- 516
				r = 3 + self:rand() * 2.4, -- 517
				life = life, -- 518
				maxLife = life -- 519
			} -- 519
			i = i + 1 -- 510
		end -- 510
	end -- 510
end -- 507
function MingArtAuditPlugin.prototype.addScorch(self, wx, wy) -- 524
	local ____self_scorches_6 = self.scorches -- 524
	____self_scorches_6[#____self_scorches_6 + 1] = { -- 525
		x = wx, -- 525
		y = wy, -- 525
		rx = 5.5 + self:rand() * 3 -- 525
	} -- 525
	if #self.scorches > 16 then -- 525
		table.remove(self.scorches, 1) -- 527
	end -- 527
end -- 524
function MingArtAuditPlugin.prototype.drawVillageGrayscaleSurfaces(self, fgDraw, p, cam) -- 531
	local y0 = cam:sy(0) -- 532
	if p.room.brickX ~= nil then -- 532
		local bx0 = cam:sx(p.room.brickX - 18) -- 536
		local bx1 = cam:sx(p.room.brickX + 18) -- 537
		local bw = bx1 - bx0 -- 538
		local bh = math.max( -- 539
			7, -- 539
			cam:len(4.5) -- 539
		) -- 539
		fgDraw:drawRect( -- 540
			Rect(bx0, y0 - bh * 0.4, bw, bh), -- 540
			Color(142, 146, 150, 235), -- 540
			1, -- 540
			Color(216, 220, 224, 220) -- 540
		) -- 540
		fgDraw:drawSegment( -- 542
			Vec2(bx0 + 1, y0 + bh * 0.1), -- 542
			Vec2(bx1 - 1, y0 + bh * 0.1), -- 542
			1, -- 542
			Color(42, 44, 48, 225) -- 542
		) -- 542
		local k = 1 -- 543
		do -- 543
			k = 1 -- 544
			while k <= 3 do -- 544
				local jx = bx0 + bw * k / 4 -- 545
				fgDraw:drawSegment( -- 546
					Vec2(jx, y0 - bh * 0.4), -- 546
					Vec2(jx, y0 + bh * 0.1), -- 546
					1, -- 546
					Color(42, 44, 48, 225) -- 546
				) -- 546
				k = k + 1 -- 544
			end -- 544
		end -- 544
		do -- 544
			k = 1 -- 548
			while k <= 2 do -- 548
				local jx = bx0 + bw * (k + 0.35) / 3 -- 549
				fgDraw:drawSegment( -- 550
					Vec2(jx, y0 + bh * 0.1), -- 550
					Vec2(jx, y0 + bh * 0.6), -- 550
					1, -- 550
					Color(42, 44, 48, 225) -- 550
				) -- 550
				k = k + 1 -- 548
			end -- 548
		end -- 548
		fgDraw:drawSegment( -- 553
			Vec2(bx0, y0 + bh * 0.6), -- 553
			Vec2(bx1, y0 + bh * 0.6), -- 553
			1.6, -- 553
			Color(232, 234, 236, 230) -- 553
		) -- 553
	end -- 553
	if p.room.softX ~= nil then -- 553
		local sx0 = cam:sx(p.room.softX - 18) -- 558
		local sx1 = cam:sx(p.room.softX + 18) -- 559
		local sw = sx1 - sx0 -- 560
		fgDraw:drawRect( -- 561
			Rect(sx0, y0 - 3, sw, 6), -- 561
			Color(54, 44, 36, 225) -- 561
		) -- 561
		local dotOffsets = { -- 563
			0.1, -- 563
			0.24, -- 563
			0.37, -- 563
			0.51, -- 563
			0.68, -- 563
			0.81, -- 563
			0.92 -- 563
		} -- 563
		local d = 0 -- 564
		do -- 564
			d = 0 -- 565
			while d < #dotOffsets do -- 565
				local dx = sx0 + sw * dotOffsets[d + 1] -- 566
				local dy = y0 + (d & 1 == 0 and 1.5 or -1.2) -- 567
				fgDraw:drawDot( -- 568
					Vec2(dx, dy), -- 568
					1.5, -- 568
					Color(96, 82, 68, 215) -- 568
				) -- 568
				d = d + 1 -- 565
			end -- 565
		end -- 565
		local fp = 0 -- 571
		do -- 571
			fp = 0 -- 572
			while fp < 3 do -- 572
				local fx = sx0 + sw * (0.22 + fp * 0.28) -- 573
				fgDraw:drawEllipse( -- 574
					Vec2(fx, y0 + 1.2), -- 574
					math.max( -- 574
						3, -- 574
						cam:len(2.4) -- 574
					), -- 574
					1.6, -- 574
					Color(34, 28, 24, 210) -- 574
				) -- 574
				fp = fp + 1 -- 572
			end -- 572
		end -- 572
	end -- 572
end -- 531
function MingArtAuditPlugin.prototype.drawForestSilhouetteSeparation(self, fgDraw, p, cam) -- 579
	local childInGrass = false -- 581
	local dogInGrass = false -- 582
	local i = 0 -- 583
	do -- 583
		i = 0 -- 584
		while i < #p.room.solids do -- 584
			do -- 584
				local s = p.room.solids[i + 1] -- 585
				if s.passable ~= true then -- 585
					goto __continue76 -- 587
				end -- 587
				if p.player.x >= s.x - 16 and p.player.x <= s.x + s.w + 16 then -- 587
					childInGrass = true -- 590
				end -- 590
				if p.dogX >= s.x - 24 and p.dogX <= s.x + s.w + 24 then -- 590
					dogInGrass = true -- 593
				end -- 593
			end -- 593
			::__continue76:: -- 593
			i = i + 1 -- 584
		end -- 584
	end -- 584
	if childInGrass and p.player.alive then -- 584
		local cx = cam:sx(p.player.x) -- 598
		local topY = cam:sy(p.player.y + p.player.h) -- 599
		local halfW = cam:len(11) -- 600
		fgDraw:drawArc( -- 602
			Vec2( -- 602
				cx, -- 602
				topY - cam:len(7) -- 602
			), -- 602
			halfW, -- 602
			25, -- 602
			155, -- 602
			1.5, -- 602
			Color(214, 224, 230, 175) -- 602
		) -- 602
	end -- 602
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 602
		local alert = p.dogState == "ear" or p.dogState == "chase" -- 606
		if dogInGrass or alert then -- 606
			local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 608
			local dx = cam:sx(p.dogX + f * 12) -- 609
			local dy = cam:sy(24) -- 610
			local earH = cam:len(alert and 7.5 or 5) -- 611
			local earCol = alert and Color(238, 232, 222, 225) or Color(196, 206, 212, 175) -- 612
			fgDraw:drawSegment( -- 614
				Vec2(dx - f * 3, dy), -- 614
				Vec2(dx - f * 1, dy + earH), -- 614
				1.6, -- 614
				earCol -- 614
			) -- 614
			fgDraw:drawSegment( -- 615
				Vec2(dx - f * 1, dy + earH), -- 615
				Vec2(dx + f * 3, dy + 1), -- 615
				1.5, -- 615
				earCol -- 615
			) -- 615
		end -- 615
	end -- 615
end -- 579
function MingArtAuditPlugin.prototype.drawLeftEndRedClothAccent(self, fgDraw, p, cam) -- 620
	local c = p.room.cart -- 621
	local depth = c.depth or 0 -- 622
	local leftEdgeWorldX = p.cartAxle - c.bodyW * 0.56 -- 624
	local anchorX = cam:sx(leftEdgeWorldX) -- 625
	local anchorY = cam:sy(c.baseY + c.wheelR + c.bodyH * 0.85, depth) -- 626
	local sway = math.sin(self.animTime * 3.1) * cam:len(3.5) -- 627
	local len = cam:len(13) -- 628
	local drop = cam:len(15) -- 629
	fgDraw:drawPolygon( -- 631
		{ -- 631
			Vec2(anchorX, anchorY), -- 632
			Vec2(anchorX - len * 0.45, anchorY - drop * 0.42), -- 633
			Vec2(anchorX - len + sway, anchorY - drop), -- 634
			Vec2(anchorX - len * 0.55 + sway * 0.6, anchorY - drop * 0.86), -- 635
			Vec2( -- 636
				anchorX + cam:len(2), -- 636
				anchorY - drop * 0.25 -- 636
			) -- 636
		}, -- 636
		toColor(PALETTE.clothRed, 220) -- 637
	) -- 637
	fgDraw:drawSegment( -- 638
		Vec2(anchorX, anchorY), -- 639
		Vec2(anchorX - len + sway, anchorY - drop), -- 640
		1.2, -- 641
		toColor(PALETTE.clothRedHighlight, 200) -- 642
	) -- 642
end -- 620
function MingArtAuditPlugin.prototype.runAudit(self, host) -- 647
	local missingBackdrops = {} -- 648
	for roomKey in pairs(____exports.CORE_MING_BACKDROPS) do -- 649
		local slotKey = ____exports.CORE_MING_BACKDROPS[roomKey] -- 650
		local cfg = ASSET_SLOTS[slotKey] -- 651
		local path = cfg ~= nil and #cfg.paths > 0 and cfg.paths[1] or "" -- 652
		if path == "" or not Content:exist(path) then -- 652
			missingBackdrops[#missingBackdrops + 1] = (roomKey .. ":") .. path -- 654
		end -- 654
	end -- 654
	local missingSpriteClips = {} -- 658
	local i = 0 -- 659
	do -- 659
		i = 0 -- 660
		while i < #____exports.MING_PRESERVED_SPRITE_CLIPS do -- 660
			local clipName = ____exports.MING_PRESERVED_SPRITE_CLIPS[i + 1] -- 661
			local path = "assets/art/sprites.clip|" .. clipName -- 662
			if host ~= nil then -- 662
				local ok = host:tryPlacePath( -- 664
					path, -- 664
					"audit_spr_" .. clipName, -- 664
					-9999, -- 664
					-9999, -- 664
					16, -- 664
					16 -- 664
				) -- 664
				if not ok then -- 664
					missingSpriteClips[#missingSpriteClips + 1] = clipName -- 666
				end -- 666
			elseif not Content:exist("assets/art/sprites.clip") then -- 666
				missingSpriteClips[#missingSpriteClips + 1] = clipName -- 669
			end -- 669
			i = i + 1 -- 660
		end -- 660
	end -- 660
	local missingUiClips = {} -- 673
	do -- 673
		i = 0 -- 674
		while i < #____exports.MING_PRESERVED_UI_CLIPS do -- 674
			local uiName = ____exports.MING_PRESERVED_UI_CLIPS[i + 1] -- 675
			local path = "assets/art/ui_ink.clip|" .. uiName -- 676
			if host ~= nil then -- 676
				local ok = host:tryPlacePath( -- 678
					path, -- 678
					"audit_ui_" .. uiName, -- 678
					-9999, -- 678
					-9999, -- 678
					16, -- 678
					16 -- 678
				) -- 678
				if not ok then -- 678
					missingUiClips[#missingUiClips + 1] = uiName -- 680
				end -- 680
			elseif not Content:exist("assets/art/ui_ink.clip") then -- 680
				missingUiClips[#missingUiClips + 1] = uiName -- 683
			end -- 683
			i = i + 1 -- 674
		end -- 674
	end -- 674
	return { -- 687
		coreBackdropsOk = #missingBackdrops == 0, -- 688
		missingBackdrops = missingBackdrops, -- 689
		preservedSpriteClipsCount = #____exports.MING_PRESERVED_SPRITE_CLIPS - #missingSpriteClips, -- 690
		missingSpriteClips = missingSpriteClips, -- 691
		preservedUiClipsCount = #____exports.MING_PRESERVED_UI_CLIPS - #missingUiClips, -- 692
		missingUiClips = missingUiClips, -- 693
		cartClothLeftInvariantOk = self.cartLeftInvariantOk, -- 694
		fallbackInterceptCount = self.fallbackInterceptCount, -- 695
		woodDebrisTriggered = self.woodDebrisCount, -- 696
		brickDebrisTriggered = self.brickDebrisCount, -- 697
		powderSmokeTriggered = self.powderSmokeCount, -- 698
		legacyFindingsCount = #____exports.MING_LEGACY_FINDINGS -- 699
	} -- 699
end -- 647
return ____exports -- 647