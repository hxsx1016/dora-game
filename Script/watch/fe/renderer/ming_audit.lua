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
	escort3 = "bgFar_forest", -- 74
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
	local ground = cam.groundScreenY -- 370
	local artW = math.max(w, h * 16 / 9) + w * 0.12 -- 371
	local artH = artW * 9 / 16 -- 372
	local sceneY = math.min((h - artH) * 0.5, ground - artH * 0.24) -- 374
	if backdropArt:tryPlace( -- 374
		slot, -- 376
		"ming_fallback_scene", -- 376
		w * (0.5 - progress * 0.09), -- 376
		sceneY, -- 376
		artW, -- 376
		artH -- 376
	) then -- 376
		self.fallbackInterceptCount = self.fallbackInterceptCount + 1 -- 377
		local theme = themeOf(roomKey) -- 378
		local dressSlot = slot == "bgFar_outside" and "pine" or "eaves" -- 379
		backdropArt:tryPlace( -- 380
			dressSlot, -- 381
			"ming_fallback_mid", -- 382
			w * (0.74 - progress * 0.25), -- 383
			ground - cam:len(10), -- 384
			cam:len(dressSlot == "pine" and 124 or 186), -- 385
			cam:len(dressSlot == "pine" and 138 or 104), -- 386
			{layer = 1, opacity = 0.46} -- 387
		) -- 387
		fillVGradRect( -- 389
			bgDraw, -- 389
			0, -- 389
			0, -- 389
			w, -- 389
			h, -- 389
			toColor(PALETTE.voidDark), -- 389
			toColor(theme.skyMid) -- 389
		) -- 389
		fillVGradRect( -- 390
			bgGlow, -- 390
			0, -- 390
			ground - 1, -- 390
			w, -- 390
			h * 0.14, -- 390
			Color(43, 49, 63, 15), -- 390
			Color(43, 49, 63, 0) -- 390
		) -- 390
		return true -- 391
	end -- 391
	return false -- 393
end -- 349
function MingArtAuditPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 397
	local p = ctx.p -- 403
	local cam = ctx.cam -- 404
	local isPixelStyle = ctx.view.visualMode == "pixel" or ctx.view.visualMode == "transition" -- 405
	if isPixelStyle and p.room.key == "village" then -- 405
		self:drawVillageGrayscaleSurfaces(fgDraw, worldArt, p, cam) -- 409
	end -- 409
	if isPixelStyle and p.room.key == "forest" then -- 409
		self:drawForestSilhouetteSeparation(fgDraw, p, cam) -- 414
	end -- 414
	if isPixelStyle and (p.room.key == "checkpoint" or p.room.key == "outside") and p.room.cart.bodyW > 0 then -- 414
		self:drawLeftEndRedClothAccent(worldArt, p, cam) -- 419
	end -- 419
	local i = 0 -- 423
	do -- 423
		i = 0 -- 424
		while i < #self.scorches do -- 424
			local sc = self.scorches[i + 1] -- 425
			fgDraw:drawEllipse( -- 426
				Vec2( -- 426
					cam:sx(sc.x), -- 426
					cam:sy(sc.y) + 2 -- 426
				), -- 426
				cam:len(sc.rx), -- 426
				cam:len(2.4), -- 426
				Color(16, 14, 15, 165) -- 426
			) -- 426
			i = i + 1 -- 424
		end -- 424
	end -- 424
	do -- 424
		i = 0 -- 430
		while i < #self.chips do -- 430
			local c = self.chips[i + 1] -- 431
			local k = c.life / c.maxLife -- 432
			local sx = cam:sx(c.x) -- 433
			local sy = cam:sy(c.y) -- 434
			local sw = math.max( -- 435
				2, -- 435
				cam:len(c.w) -- 435
			) -- 435
			local sh = math.max( -- 436
				1.5, -- 436
				cam:len(c.h) -- 436
			) -- 436
			if c.isWood then -- 436
				fgDraw:drawRect( -- 438
					Rect(sx - sw * 0.5, sy - sh * 0.5, sw, sh), -- 438
					Color( -- 438
						128, -- 438
						86, -- 438
						54, -- 438
						math.floor(235 * k + 0.5) -- 438
					) -- 438
				) -- 438
				fgDraw:drawSegment( -- 439
					Vec2(sx - sw * 0.5, sy + sh * 0.5), -- 439
					Vec2(sx + sw * 0.5, sy + sh * 0.5), -- 439
					0.9, -- 439
					Color( -- 439
						196, -- 439
						162, -- 439
						118, -- 439
						math.floor(180 * k + 0.5) -- 439
					) -- 439
				) -- 439
			else -- 439
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
			i = i + 1 -- 430
		end -- 430
	end -- 430
	do -- 430
		i = 0 -- 447
		while i < #self.puffs do -- 447
			local pf = self.puffs[i + 1] -- 448
			local k = pf.life / pf.maxLife -- 449
			local sx = cam:sx(pf.x) -- 450
			local sy = cam:sy(pf.y) -- 451
			local sz = math.max( -- 452
				8, -- 452
				cam:len(pf.r * 3.4) -- 452
			) -- 452
			if not worldArt:tryPlace( -- 452
				"fe_vfx_smoke", -- 453
				"ming_puff_" .. tostring(i), -- 453
				sx, -- 453
				sy, -- 453
				sz, -- 453
				sz, -- 453
				{ -- 453
					frame = math.min( -- 454
						3, -- 454
						math.floor((1 - k) * 4) -- 454
					), -- 454
					opacity = 0.72 * k, -- 455
					layer = 8 -- 456
				} -- 456
			) then -- 456
				local r = math.max( -- 458
					2, -- 458
					cam:len(pf.r) -- 458
				) -- 458
				fgDraw:drawCircle( -- 459
					Vec2(sx, sy), -- 459
					r, -- 459
					Color( -- 459
						196, -- 459
						198, -- 459
						200, -- 459
						math.floor(92 * k + 0.5) -- 459
					) -- 459
				) -- 459
				fgGlow:drawCircle( -- 460
					Vec2(sx, sy), -- 460
					r * 0.62, -- 460
					Color( -- 460
						224, -- 460
						222, -- 460
						214, -- 460
						math.floor(48 * k + 0.5) -- 460
					) -- 460
				) -- 460
			end -- 460
			i = i + 1 -- 447
		end -- 447
	end -- 447
end -- 397
function MingArtAuditPlugin.prototype.spawnCoverMaterialDebris(self, p) -- 465
	local hitX = p.player.x + p.player.facing * 16 -- 466
	local hitY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.5 -- 467
	local isWood = false -- 468
	local nearest = 56 -- 469
	local i = 0 -- 470
	do -- 470
		i = 0 -- 471
		while i < #p.room.solids do -- 471
			do -- 471
				local s = p.room.solids[i + 1] -- 472
				if s.passable or s.decorative or s.y > p.player.y + 4 or s.h > 72 then -- 472
					goto __continue51 -- 474
				end -- 474
				if not overlapsDepth(p.player.depth, s.depth, ACTOR_DEPTH_HALF) then -- 474
					goto __continue51 -- 477
				end -- 477
				local edge = p.player.x < s.x and s.x or s.x + s.w -- 479
				local gap = math.abs(p.player.x - edge) -- 480
				if gap < nearest then -- 480
					nearest = gap -- 482
					hitX = edge -- 483
					local ____s_y_3 = s.y -- 484
					local ____opt_1 = s.depth -- 484
					hitY = ____s_y_3 + (____opt_1 and ____opt_1.min or 0) * DEPTH_Y_SCALE + s.h * 0.85 -- 484
					isWood = ____exports.isWoodCoverLabel(s.art, s.label) -- 485
				end -- 485
			end -- 485
			::__continue51:: -- 485
			i = i + 1 -- 471
		end -- 471
	end -- 471
	if isWood then -- 471
		self.woodDebrisCount = self.woodDebrisCount + 1 -- 490
	else -- 490
		self.brickDebrisCount = self.brickDebrisCount + 1 -- 492
	end -- 492
	local count = isWood and 9 or 10 -- 495
	do -- 495
		i = 0 -- 496
		while i < count do -- 496
			local ang = (self:rand() - 0.5) * math.pi * 1.15 -- 497
			local spd = (isWood and 85 or 58) * (0.45 + self:rand() * 0.75) -- 498
			local life = (isWood and 0.34 or 0.42) + self:rand() * 0.16 -- 499
			local ____self_chips_4 = self.chips -- 499
			____self_chips_4[#____self_chips_4 + 1] = { -- 500
				x = hitX, -- 501
				y = hitY, -- 502
				vx = -p.player.facing * math.abs(math.cos(ang)) * spd + (self:rand() - 0.5) * 35, -- 503
				vy = math.abs(math.sin(ang)) * spd + (isWood and 55 or 28), -- 504
				w = isWood and 4.5 + self:rand() * 3.5 or 2.6 + self:rand() * 2.8, -- 505
				h = isWood and 1.8 + self:rand() * 1.4 or 2.6 + self:rand() * 2.8, -- 506
				life = life, -- 507
				maxLife = life, -- 508
				isWood = isWood -- 509
			} -- 509
			i = i + 1 -- 496
		end -- 496
	end -- 496
end -- 465
function MingArtAuditPlugin.prototype.spawnMatchlockSmoke(self, wx, wy, dir) -- 514
	self.powderSmokeCount = self.powderSmokeCount + 1 -- 515
	local i = 0 -- 516
	do -- 516
		i = 0 -- 517
		while i < 5 do -- 517
			local life = 0.24 + self:rand() * 0.18 -- 518
			local ____self_puffs_5 = self.puffs -- 518
			____self_puffs_5[#____self_puffs_5 + 1] = { -- 519
				x = wx + dir * (4 + i * 3.5), -- 520
				y = wy + (self:rand() - 0.4) * 5, -- 521
				vx = dir * (28 + self:rand() * 44), -- 522
				vy = 14 + self:rand() * 22, -- 523
				r = 3 + self:rand() * 2.4, -- 524
				life = life, -- 525
				maxLife = life -- 526
			} -- 526
			i = i + 1 -- 517
		end -- 517
	end -- 517
end -- 514
function MingArtAuditPlugin.prototype.addScorch(self, wx, wy) -- 531
	local ____self_scorches_6 = self.scorches -- 531
	____self_scorches_6[#____self_scorches_6 + 1] = { -- 532
		x = wx, -- 532
		y = wy, -- 532
		rx = 5.5 + self:rand() * 3 -- 532
	} -- 532
	if #self.scorches > 16 then -- 532
		table.remove(self.scorches, 1) -- 534
	end -- 534
end -- 531
function MingArtAuditPlugin.prototype.drawVillageGrayscaleSurfaces(self, fgDraw, worldArt, p, cam) -- 538
	local y0 = cam:sy(0) -- 544
	if p.room.brickX ~= nil then -- 544
		local bx = cam:sx(p.room.brickX) -- 547
		if not worldArt:tryPlace( -- 547
			"fe_ground_brick", -- 548
			"ming_vil_brick", -- 548
			bx, -- 548
			y0 - cam:len(4), -- 548
			cam:len(44), -- 548
			cam:len(14), -- 548
			{layer = 2} -- 548
		) then -- 548
			fgDraw:drawRect( -- 549
				Rect( -- 549
					bx - cam:len(18), -- 549
					y0 - 4, -- 549
					cam:len(36), -- 549
					8 -- 549
				), -- 549
				Color(142, 146, 150, 235) -- 549
			) -- 549
		end -- 549
		fgDraw:drawSegment( -- 551
			Vec2( -- 551
				bx - cam:len(20), -- 551
				y0 + 2 -- 551
			), -- 551
			Vec2( -- 551
				bx + cam:len(20), -- 551
				y0 + 2 -- 551
			), -- 551
			1.3, -- 551
			Color(228, 232, 238, 170) -- 551
		) -- 551
	end -- 551
	if p.room.softX ~= nil then -- 551
		local sx = cam:sx(p.room.softX) -- 555
		if not worldArt:tryPlace( -- 555
			"fe_ground_soft", -- 556
			"ming_vil_soft", -- 556
			sx, -- 556
			y0 - cam:len(4), -- 556
			cam:len(44), -- 556
			cam:len(14), -- 556
			{layer = 2} -- 556
		) then -- 556
			fgDraw:drawRect( -- 557
				Rect( -- 557
					sx - cam:len(18), -- 557
					y0 - 3, -- 557
					cam:len(36), -- 557
					6 -- 557
				), -- 557
				Color(54, 44, 36, 225) -- 557
			) -- 557
		end -- 557
	end -- 557
end -- 538
function MingArtAuditPlugin.prototype.drawForestSilhouetteSeparation(self, fgDraw, p, cam) -- 562
	local childInGrass = false -- 564
	local i = 0 -- 565
	do -- 565
		i = 0 -- 566
		while i < #p.room.solids do -- 566
			local s = p.room.solids[i + 1] -- 567
			if s.passable == true and p.player.x >= s.x - 16 and p.player.x <= s.x + s.w + 16 then -- 567
				childInGrass = true -- 569
			end -- 569
			i = i + 1 -- 566
		end -- 566
	end -- 566
	if childInGrass and p.player.alive then -- 566
		local cx = cam:sx(p.player.x) -- 573
		local topY = cam:sy(p.player.y + p.player.h) -- 574
		fgDraw:drawArc( -- 575
			Vec2( -- 575
				cx, -- 575
				topY - cam:len(7) -- 575
			), -- 575
			cam:len(11), -- 575
			25, -- 575
			155, -- 575
			1.4, -- 575
			Color(214, 224, 230, 165) -- 575
		) -- 575
	end -- 575
end -- 562
function MingArtAuditPlugin.prototype.drawLeftEndRedClothAccent(self, worldArt, p, cam) -- 579
	local c = p.room.cart -- 580
	local depth = c.depth or 0 -- 581
	local leftEdgeWorldX = p.cartAxle - c.bodyW * 0.54 -- 583
	local anchorX = cam:sx(leftEdgeWorldX) -- 584
	local anchorY = cam:sy(c.baseY + c.wheelR + c.bodyH * 0.86, depth) -- 585
	local frame = math.floor(self.animTime * 4.4) % 3 -- 586
	worldArt:tryPlace( -- 587
		"fe_red_cloth", -- 587
		"ming_cart_red_cloth", -- 587
		anchorX, -- 587
		anchorY, -- 587
		cam:len(22), -- 587
		cam:len(22), -- 587
		{frame = frame, layer = 6} -- 587
	) -- 587
end -- 579
function MingArtAuditPlugin.prototype.runAudit(self, host) -- 594
	local missingBackdrops = {} -- 595
	for roomKey in pairs(____exports.CORE_MING_BACKDROPS) do -- 596
		local slotKey = ____exports.CORE_MING_BACKDROPS[roomKey] -- 597
		local cfg = ASSET_SLOTS[slotKey] -- 598
		local path = cfg ~= nil and #cfg.paths > 0 and cfg.paths[1] or "" -- 599
		if path == "" or not Content:exist(path) then -- 599
			missingBackdrops[#missingBackdrops + 1] = (roomKey .. ":") .. path -- 601
		end -- 601
	end -- 601
	local missingSpriteClips = {} -- 605
	local i = 0 -- 606
	do -- 606
		i = 0 -- 607
		while i < #____exports.MING_PRESERVED_SPRITE_CLIPS do -- 607
			local clipName = ____exports.MING_PRESERVED_SPRITE_CLIPS[i + 1] -- 608
			local path = "assets/art/sprites.clip|" .. clipName -- 609
			if host ~= nil then -- 609
				local ok = host:tryPlacePath( -- 611
					path, -- 611
					"audit_spr_" .. clipName, -- 611
					-9999, -- 611
					-9999, -- 611
					16, -- 611
					16 -- 611
				) -- 611
				if not ok then -- 611
					missingSpriteClips[#missingSpriteClips + 1] = clipName -- 613
				end -- 613
			elseif not Content:exist("assets/art/sprites.clip") then -- 613
				missingSpriteClips[#missingSpriteClips + 1] = clipName -- 616
			end -- 616
			i = i + 1 -- 607
		end -- 607
	end -- 607
	local missingUiClips = {} -- 620
	do -- 620
		i = 0 -- 621
		while i < #____exports.MING_PRESERVED_UI_CLIPS do -- 621
			local uiName = ____exports.MING_PRESERVED_UI_CLIPS[i + 1] -- 622
			local path = "assets/art/ui_ink.clip|" .. uiName -- 623
			if host ~= nil then -- 623
				local ok = host:tryPlacePath( -- 625
					path, -- 625
					"audit_ui_" .. uiName, -- 625
					-9999, -- 625
					-9999, -- 625
					16, -- 625
					16 -- 625
				) -- 625
				if not ok then -- 625
					missingUiClips[#missingUiClips + 1] = uiName -- 627
				end -- 627
			elseif not Content:exist("assets/art/ui_ink.clip") then -- 627
				missingUiClips[#missingUiClips + 1] = uiName -- 630
			end -- 630
			i = i + 1 -- 621
		end -- 621
	end -- 621
	return { -- 634
		coreBackdropsOk = #missingBackdrops == 0, -- 635
		missingBackdrops = missingBackdrops, -- 636
		preservedSpriteClipsCount = #____exports.MING_PRESERVED_SPRITE_CLIPS - #missingSpriteClips, -- 637
		missingSpriteClips = missingSpriteClips, -- 638
		preservedUiClipsCount = #____exports.MING_PRESERVED_UI_CLIPS - #missingUiClips, -- 639
		missingUiClips = missingUiClips, -- 640
		cartClothLeftInvariantOk = self.cartLeftInvariantOk, -- 641
		fallbackInterceptCount = self.fallbackInterceptCount, -- 642
		woodDebrisTriggered = self.woodDebrisCount, -- 643
		brickDebrisTriggered = self.brickDebrisCount, -- 644
		powderSmokeTriggered = self.powderSmokeCount, -- 645
		legacyFindingsCount = #____exports.MING_LEGACY_FINDINGS -- 646
	} -- 646
end -- 594
return ____exports -- 594