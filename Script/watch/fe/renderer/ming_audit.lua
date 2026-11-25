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
local ____depth = require("watch.depth") -- 21
local ACTOR_DEPTH_HALF = ____depth.ACTOR_DEPTH_HALF -- 21
local overlapsDepth = ____depth.overlapsDepth -- 21
local ____assets = require("watch.fe.assets") -- 22
local ASSET_SLOTS = ____assets.ASSET_SLOTS -- 22
local ____theme = require("watch.fe.theme") -- 25
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
--- 非八房战役/护送段到明朝像素底图的映射表（杜绝探照灯与工业钢架退化）
____exports.FALLBACK_MING_BACKDROPS = { -- 65
	["s1-crossroad"] = "bgFar_street", -- 66
	["s2-drygoods"] = "bgFar_street", -- 67
	["s3-archway"] = "bgFar_street", -- 68
	["c1-yard"] = "bgFar_checkpoint", -- 69
	["c2-granary"] = "bgFar_checkpoint", -- 70
	gatepath = "bgFar_outside", -- 71
	escort1 = "bgFar_outside" -- 72
} -- 72
--- 检出的 6 处既有热点渲染文件赛博/全息遗留（方案 A：记录清单，不修改热点文件，交 M1 / fe-07 收口）
____exports.MING_LEGACY_FINDINGS = { -- 88
	{ -- 89
		id = "MING-01", -- 90
		file = "Script/watch/fe/theme.ts & Script/watch/fe/renderer/stage.ts", -- 91
		lines = "theme.ts:160,189,218,247; stage.ts:166-274,329-508", -- 92
		severity = "high", -- 93
		summary = "showSearchlights=true 与无 bgFar 退化路径包含扫射探照灯、屋顶天线、工业钢桁架、垂落电缆及破损电灯", -- 94
		mitigationInFe03 = "MingArtAuditPlugin.drawBackdrop 拦截全部非八房房间并映射至明朝像素底图，运行期 0 触发探照灯", -- 95
		targetFixPhase = "M1 / fe-07" -- 96
	}, -- 96
	{ -- 98
		id = "MING-02", -- 99
		file = "Script/watch/fe/renderer/stage.ts", -- 100
		lines = "stage.ts:844-857", -- 101
		severity = "high", -- 102
		summary = "drawCoverBlock 在贴靠掩体时绘制冰青全息护盾竖条与大面积荧光蓝光晕", -- 103
		mitigationInFe03 = "审计报告标注待改为木沿/砖沿低饱和描边，本分支不改动 stage.ts 保持零冲突", -- 104
		targetFixPhase = "M1 / fe-07" -- 105
	}, -- 105
	{ -- 107
		id = "MING-03", -- 108
		file = "Script/watch/fe/renderer/stage.ts", -- 109
		lines = "stage.ts:860-891", -- 110
		severity = "medium", -- 111
		summary = "drawWinch 在 prop_winch 下层仍绘倒角钢箱与闪烁冰青/琥珀电子状态灯", -- 112
		mitigationInFe03 = "待改为纯木铁绞盘实体与绳链张力表现", -- 113
		targetFixPhase = "M1 / fe-07" -- 114
	}, -- 114
	{ -- 116
		id = "MING-04", -- 117
		file = "Script/watch/fe/renderer/stage.ts", -- 118
		lines = "stage.ts:1047-1059", -- 119
		severity = "medium", -- 120
		summary = "drawArch 城外矮拱绘制亮银矩形外框与冰蓝发光竖渐变，与周边明代灰砖质感割裂", -- 121
		mitigationInFe03 = "fe-04 低模城外将接管城外舞台；像素线待在 fe-07 改为石拱券砖沿", -- 122
		targetFixPhase = "fe-04 / fe-07" -- 123
	}, -- 123
	{ -- 125
		id = "MING-05", -- 126
		file = "Script/watch/fe/renderer/props.ts", -- 127
		lines = "props.ts:78-83,100-153,242-245,307", -- 128
		severity = "high", -- 129
		summary = "存在危险区红激光扫描线、全息检查点菱柱、车柄发光黄球、钢杆灯柱及村口瓶架贴图纵拉变形", -- 130
		mitigationInFe03 = "ming_audit.ts 补强村口砖缝/软土灰度纹样与左端红布校验；全息标与黄球留待 fe-07 清理", -- 131
		targetFixPhase = "fe-07" -- 132
	}, -- 132
	{ -- 134
		id = "MING-06", -- 135
		file = "Script/watch/fe/renderer/actors.ts", -- 136
		lines = "actors.ts:66-83,145-171", -- 137
		severity = "medium", -- 138
		summary = "周戍翻滚仍生成 ICEY 冰青残影，不符合明代守卒写实基调且与 fe-06 穿梭器残影彩蛋语义重叠", -- 139
		mitigationInFe03 = "审计报告标注待改为扬尘步烟，残影视觉专属留给 fe-06 穿梭器彩蛋", -- 140
		targetFixPhase = "M2 / fe-07" -- 141
	} -- 141
} -- 141
function ____exports.resolveMingBackdropSlot(roomKey) -- 188
	local direct = ____exports.CORE_MING_BACKDROPS[roomKey] -- 189
	if direct ~= nil then -- 189
		return direct -- 191
	end -- 191
	local mapped = ____exports.FALLBACK_MING_BACKDROPS[roomKey] -- 193
	if mapped ~= nil then -- 193
		return mapped -- 195
	end -- 195
	return "bgFar_street" -- 197
end -- 188
function ____exports.isWoodCoverLabel(art, label) -- 200
	if art == "cover_wood" or art == "thin_wood" or art == "board" or art == "fence" or art == "basket_wall" then -- 200
		return true -- 202
	end -- 202
	if art == "cover_stone" or art == "wall" or art == "gate_post" or art == "well" then -- 202
		return false -- 205
	end -- 205
	if label ~= nil then -- 205
		if (string.find(label, "柜", nil, true) or 0) - 1 >= 0 or (string.find(label, "木", nil, true) or 0) - 1 >= 0 or (string.find(label, "桌", nil, true) or 0) - 1 >= 0 or (string.find(label, "货", nil, true) or 0) - 1 >= 0 or (string.find(label, "棚", nil, true) or 0) - 1 >= 0 or (string.find(label, "栏", nil, true) or 0) - 1 >= 0 then -- 205
			return true -- 216
		end -- 216
	end -- 216
	return false -- 219
end -- 200
____exports.MingArtAuditPlugin = __TS__Class() -- 222
local MingArtAuditPlugin = ____exports.MingArtAuditPlugin -- 222
MingArtAuditPlugin.name = "MingArtAuditPlugin" -- 222
function MingArtAuditPlugin.prototype.____constructor(self) -- 222
	self.id = "fe03-ming-audit" -- 223
	self.chips = {} -- 225
	self.puffs = {} -- 226
	self.scorches = {} -- 227
	self.animTime = 0 -- 228
	self.rng = 4099 -- 229
	self.fallbackInterceptCount = 0 -- 232
	self.woodDebrisCount = 0 -- 233
	self.brickDebrisCount = 0 -- 234
	self.powderSmokeCount = 0 -- 235
	self.cartLeftInvariantOk = true -- 236
	self.lastRoomKey = "" -- 237
end -- 222
function MingArtAuditPlugin.prototype.rand(self) -- 239
	self.rng = (self.rng * 1664525 + 1013904223) % 4294967296 -- 240
	return self.rng / 4294967296 -- 241
end -- 239
function MingArtAuditPlugin.prototype.onBindPlay(self, p, _view) -- 244
	self.chips = {} -- 245
	self.puffs = {} -- 246
	self.scorches = {} -- 247
	self.animTime = 0 -- 248
	self.lastRoomKey = p.room.key -- 249
	if p.room.cart.bodyW > 0 and p.room.cart.clothSide >= 0 then -- 249
		self.cartLeftInvariantOk = false -- 251
	end -- 251
	self:syncRuntimeHook() -- 253
end -- 244
function MingArtAuditPlugin.prototype.syncRuntimeHook(self) -- 256
	local g = _G -- 257
	local ____temp_0 -- 258
	if g.package ~= nil then -- 258
		____temp_0 = g.package.loaded -- 258
	else -- 258
		____temp_0 = nil -- 258
	end -- 258
	local loaded = ____temp_0 -- 258
	if loaded == nil then -- 258
		return -- 260
	end -- 260
	local rawFe = loaded["watch.fe"] -- 262
	if rawFe ~= nil and type(rawFe) == "table" then -- 262
		local watchFe = rawFe -- 264
		if watchFe.mingAudit ~= self then -- 264
			watchFe.mingAudit = self -- 266
		end -- 266
	end -- 266
end -- 256
function MingArtAuditPlugin.prototype.update(self, ctx) -- 271
	self:syncRuntimeHook() -- 272
	local p = ctx.p -- 273
	if self.lastRoomKey ~= "" and self.lastRoomKey ~= p.room.key then -- 273
		self:onBindPlay(p, ctx.view) -- 276
	end -- 276
	if p.room.cart.bodyW > 0 and p.room.cart.clothSide >= 0 then -- 276
		self.cartLeftInvariantOk = false -- 279
	end -- 279
	if ctx.paused or ctx.worldDt <= 0 then -- 279
		return -- 283
	end -- 283
	local dt = ctx.worldDt -- 286
	self.animTime = self.animTime + dt -- 287
	if ctx.events.coverDeflect then -- 287
		self:spawnCoverMaterialDebris(p) -- 291
	end -- 291
	if ctx.events.shotFired and ctx.events.shotTrace ~= nil then -- 291
		local tr = ctx.events.shotTrace -- 296
		self:spawnMatchlockSmoke(tr.x0, tr.y0, tr.x1 >= tr.x0 and 1 or -1) -- 297
		if not tr.hit and tr.y1 <= 42 then -- 297
			self:addScorch( -- 299
				tr.x1, -- 299
				math.max(0, tr.y1) -- 299
			) -- 299
		end -- 299
	end -- 299
	local w = 0 -- 304
	local i = 0 -- 305
	do -- 305
		i = 0 -- 306
		while i < #self.chips do -- 306
			local c = self.chips[i + 1] -- 307
			c.life = c.life - dt -- 308
			if c.life > 0 then -- 308
				c.vy = c.vy - (c.isWood and 360 or 210) * dt -- 310
				c.x = c.x + c.vx * dt -- 311
				c.y = c.y + c.vy * dt -- 312
				if c.y < 0 then -- 312
					c.y = 0 -- 314
					c.vy = -c.vy * 0.25 -- 315
					c.vx = c.vx * 0.65 -- 316
				end -- 316
				self.chips[w + 1] = c -- 318
				w = w + 1 -- 319
			end -- 319
			i = i + 1 -- 306
		end -- 306
	end -- 306
	__TS__ArraySetLength(self.chips, w) -- 306
	w = 0 -- 325
	do -- 325
		i = 0 -- 326
		while i < #self.puffs do -- 326
			local pf = self.puffs[i + 1] -- 327
			pf.life = pf.life - dt -- 328
			if pf.life > 0 then -- 328
				pf.x = pf.x + pf.vx * dt -- 330
				pf.y = pf.y + pf.vy * dt -- 331
				pf.vx = pf.vx * math.max(0, 1 - dt * 3.4) -- 332
				pf.r = pf.r + dt * 14 -- 333
				self.puffs[w + 1] = pf -- 334
				w = w + 1 -- 335
			end -- 335
			i = i + 1 -- 326
		end -- 326
	end -- 326
	__TS__ArraySetLength(self.puffs, w) -- 326
end -- 271
function MingArtAuditPlugin.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 345
	local roomKey = ctx.p.room.key -- 351
	if ____exports.CORE_MING_BACKDROPS[roomKey] ~= nil then -- 351
		return false -- 353
	end -- 353
	if ctx.view.visualMode == "lowpoly" or ctx.view.visualMode == "museum" then -- 353
		return false -- 357
	end -- 357
	local slot = ____exports.resolveMingBackdropSlot(roomKey) -- 360
	local cam = ctx.cam -- 361
	local w = cam.viewW -- 362
	local h = cam.viewH -- 363
	local span = math.max(1, ctx.p.room.maxX - ctx.p.room.minX) -- 364
	local progress = (cam.x - ctx.p.room.minX) / span - 0.5 -- 365
	local artW = math.max(w, h * 16 / 9) + w * 0.12 -- 366
	local artH = artW * 9 / 16 -- 367
	if backdropArt:tryPlace( -- 367
		slot, -- 369
		"ming_fallback_scene", -- 369
		w * (0.5 - progress * 0.09), -- 369
		(h - artH) * 0.5, -- 369
		artW, -- 369
		artH -- 369
	) then -- 369
		self.fallbackInterceptCount = self.fallbackInterceptCount + 1 -- 370
		local theme = themeOf(roomKey) -- 371
		local ground = cam.groundScreenY -- 372
		local dressSlot = slot == "bgFar_outside" and "pine" or "eaves" -- 373
		backdropArt:tryPlace( -- 374
			dressSlot, -- 375
			"ming_fallback_mid", -- 376
			w * (0.74 - progress * 0.25), -- 377
			ground - cam:len(10), -- 378
			cam:len(dressSlot == "pine" and 124 or 186), -- 379
			cam:len(dressSlot == "pine" and 138 or 104), -- 380
			{layer = 1, opacity = 0.46} -- 381
		) -- 381
		fillVGradRect( -- 383
			bgDraw, -- 383
			0, -- 383
			0, -- 383
			w, -- 383
			h, -- 383
			toColor(PALETTE.voidDark), -- 383
			toColor(theme.skyMid) -- 383
		) -- 383
		fillVGradRect( -- 384
			bgGlow, -- 384
			0, -- 384
			ground - 1, -- 384
			w, -- 384
			h * 0.14, -- 384
			Color(43, 49, 63, 15), -- 384
			Color(43, 49, 63, 0) -- 384
		) -- 384
		return true -- 385
	end -- 385
	return false -- 387
end -- 345
function MingArtAuditPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 391
	local p = ctx.p -- 397
	local cam = ctx.cam -- 398
	local isPixelStyle = ctx.view.visualMode == "pixel" or ctx.view.visualMode == "transition" -- 399
	if isPixelStyle and p.room.key == "village" then -- 399
		self:drawVillageGrayscaleSurfaces(fgDraw, p, cam) -- 403
	end -- 403
	if isPixelStyle and p.room.key == "forest" then -- 403
		self:drawForestSilhouetteSeparation(fgDraw, p, cam) -- 408
	end -- 408
	if isPixelStyle and (p.room.key == "checkpoint" or p.room.key == "outside") and p.room.cart.bodyW > 0 then -- 408
		self:drawLeftEndRedClothAccent(fgDraw, p, cam) -- 413
	end -- 413
	local i = 0 -- 417
	do -- 417
		i = 0 -- 418
		while i < #self.scorches do -- 418
			local sc = self.scorches[i + 1] -- 419
			fgDraw:drawEllipse( -- 420
				Vec2( -- 420
					cam:sx(sc.x), -- 420
					cam:sy(sc.y) + 2 -- 420
				), -- 420
				cam:len(sc.rx), -- 420
				cam:len(2.4), -- 420
				Color(16, 14, 15, 165) -- 420
			) -- 420
			i = i + 1 -- 418
		end -- 418
	end -- 418
	do -- 418
		i = 0 -- 424
		while i < #self.chips do -- 424
			local c = self.chips[i + 1] -- 425
			local k = c.life / c.maxLife -- 426
			local sx = cam:sx(c.x) -- 427
			local sy = cam:sy(c.y) -- 428
			local sw = math.max( -- 429
				2, -- 429
				cam:len(c.w) -- 429
			) -- 429
			local sh = math.max( -- 430
				1.5, -- 430
				cam:len(c.h) -- 430
			) -- 430
			if c.isWood then -- 430
				fgDraw:drawRect( -- 433
					Rect(sx - sw * 0.5, sy - sh * 0.5, sw, sh), -- 433
					Color( -- 433
						128, -- 433
						86, -- 433
						54, -- 433
						math.floor(235 * k + 0.5) -- 433
					) -- 433
				) -- 433
				fgDraw:drawSegment( -- 434
					Vec2(sx - sw * 0.5, sy + sh * 0.5), -- 434
					Vec2(sx + sw * 0.5, sy + sh * 0.5), -- 434
					0.9, -- 434
					Color( -- 434
						196, -- 434
						162, -- 434
						118, -- 434
						math.floor(180 * k + 0.5) -- 434
					) -- 434
				) -- 434
			else -- 434
				fgDraw:drawCircle( -- 437
					Vec2(sx, sy), -- 437
					sw * 0.65, -- 437
					Color( -- 437
						164, -- 437
						168, -- 437
						172, -- 437
						math.floor(175 * k + 0.5) -- 437
					) -- 437
				) -- 437
				fgDraw:drawDot( -- 438
					Vec2(sx + 1, sy + 1), -- 438
					math.max(1.2, sw * 0.32), -- 438
					Color( -- 438
						218, -- 438
						220, -- 438
						224, -- 438
						math.floor(210 * k + 0.5) -- 438
					) -- 438
				) -- 438
			end -- 438
			i = i + 1 -- 424
		end -- 424
	end -- 424
	do -- 424
		i = 0 -- 443
		while i < #self.puffs do -- 443
			local pf = self.puffs[i + 1] -- 444
			local k = pf.life / pf.maxLife -- 445
			local sx = cam:sx(pf.x) -- 446
			local sy = cam:sy(pf.y) -- 447
			local r = math.max( -- 448
				2, -- 448
				cam:len(pf.r) -- 448
			) -- 448
			fgDraw:drawCircle( -- 449
				Vec2(sx, sy), -- 449
				r, -- 449
				Color( -- 449
					196, -- 449
					198, -- 449
					200, -- 449
					math.floor(92 * k + 0.5) -- 449
				) -- 449
			) -- 449
			fgGlow:drawCircle( -- 450
				Vec2(sx, sy), -- 450
				r * 0.62, -- 450
				Color( -- 450
					224, -- 450
					222, -- 450
					214, -- 450
					math.floor(48 * k + 0.5) -- 450
				) -- 450
			) -- 450
			i = i + 1 -- 443
		end -- 443
	end -- 443
end -- 391
function MingArtAuditPlugin.prototype.spawnCoverMaterialDebris(self, p) -- 454
	local hitX = p.player.x + p.player.facing * 16 -- 455
	local hitY = p.player.y + p.player.depth + p.player.h * 0.5 -- 456
	local isWood = false -- 457
	local nearest = 56 -- 458
	local i = 0 -- 459
	do -- 459
		i = 0 -- 460
		while i < #p.room.solids do -- 460
			do -- 460
				local s = p.room.solids[i + 1] -- 461
				if s.passable or s.decorative or s.y > p.player.y + 4 or s.h > 72 then -- 461
					goto __continue50 -- 463
				end -- 463
				if not overlapsDepth(p.player.depth, s.depth, ACTOR_DEPTH_HALF) then -- 463
					goto __continue50 -- 466
				end -- 466
				local edge = p.player.x < s.x and s.x or s.x + s.w -- 468
				local gap = math.abs(p.player.x - edge) -- 469
				if gap < nearest then -- 469
					nearest = gap -- 471
					hitX = edge -- 472
					local ____s_y_3 = s.y -- 473
					local ____opt_1 = s.depth -- 473
					hitY = ____s_y_3 + (____opt_1 and ____opt_1.min or 0) + s.h * 0.85 -- 473
					isWood = ____exports.isWoodCoverLabel(s.art, s.label) -- 474
				end -- 474
			end -- 474
			::__continue50:: -- 474
			i = i + 1 -- 460
		end -- 460
	end -- 460
	if isWood then -- 460
		self.woodDebrisCount = self.woodDebrisCount + 1 -- 479
	else -- 479
		self.brickDebrisCount = self.brickDebrisCount + 1 -- 481
	end -- 481
	local count = isWood and 9 or 10 -- 484
	do -- 484
		i = 0 -- 485
		while i < count do -- 485
			local ang = (self:rand() - 0.5) * math.pi * 1.15 -- 486
			local spd = (isWood and 85 or 58) * (0.45 + self:rand() * 0.75) -- 487
			local life = (isWood and 0.34 or 0.42) + self:rand() * 0.16 -- 488
			local ____self_chips_4 = self.chips -- 488
			____self_chips_4[#____self_chips_4 + 1] = { -- 489
				x = hitX, -- 490
				y = hitY, -- 491
				vx = -p.player.facing * math.abs(math.cos(ang)) * spd + (self:rand() - 0.5) * 35, -- 492
				vy = math.abs(math.sin(ang)) * spd + (isWood and 55 or 28), -- 493
				w = isWood and 4.5 + self:rand() * 3.5 or 2.6 + self:rand() * 2.8, -- 494
				h = isWood and 1.8 + self:rand() * 1.4 or 2.6 + self:rand() * 2.8, -- 495
				life = life, -- 496
				maxLife = life, -- 497
				isWood = isWood -- 498
			} -- 498
			i = i + 1 -- 485
		end -- 485
	end -- 485
end -- 454
function MingArtAuditPlugin.prototype.spawnMatchlockSmoke(self, wx, wy, dir) -- 503
	self.powderSmokeCount = self.powderSmokeCount + 1 -- 504
	local i = 0 -- 505
	do -- 505
		i = 0 -- 506
		while i < 5 do -- 506
			local life = 0.24 + self:rand() * 0.18 -- 507
			local ____self_puffs_5 = self.puffs -- 507
			____self_puffs_5[#____self_puffs_5 + 1] = { -- 508
				x = wx + dir * (4 + i * 3.5), -- 509
				y = wy + (self:rand() - 0.4) * 5, -- 510
				vx = dir * (28 + self:rand() * 44), -- 511
				vy = 14 + self:rand() * 22, -- 512
				r = 3 + self:rand() * 2.4, -- 513
				life = life, -- 514
				maxLife = life -- 515
			} -- 515
			i = i + 1 -- 506
		end -- 506
	end -- 506
end -- 503
function MingArtAuditPlugin.prototype.addScorch(self, wx, wy) -- 520
	local ____self_scorches_6 = self.scorches -- 520
	____self_scorches_6[#____self_scorches_6 + 1] = { -- 521
		x = wx, -- 521
		y = wy, -- 521
		rx = 5.5 + self:rand() * 3 -- 521
	} -- 521
	if #self.scorches > 16 then -- 521
		table.remove(self.scorches, 1) -- 523
	end -- 523
end -- 520
function MingArtAuditPlugin.prototype.drawVillageGrayscaleSurfaces(self, fgDraw, p, cam) -- 527
	local y0 = cam:sy(0) -- 528
	if p.room.brickX ~= nil then -- 528
		local bx0 = cam:sx(p.room.brickX - 18) -- 532
		local bx1 = cam:sx(p.room.brickX + 18) -- 533
		local bw = bx1 - bx0 -- 534
		local bh = math.max( -- 535
			7, -- 535
			cam:len(4.5) -- 535
		) -- 535
		fgDraw:drawRect( -- 536
			Rect(bx0, y0 - bh * 0.4, bw, bh), -- 536
			Color(142, 146, 150, 235), -- 536
			1, -- 536
			Color(216, 220, 224, 220) -- 536
		) -- 536
		fgDraw:drawSegment( -- 538
			Vec2(bx0 + 1, y0 + bh * 0.1), -- 538
			Vec2(bx1 - 1, y0 + bh * 0.1), -- 538
			1, -- 538
			Color(42, 44, 48, 225) -- 538
		) -- 538
		local k = 1 -- 539
		do -- 539
			k = 1 -- 540
			while k <= 3 do -- 540
				local jx = bx0 + bw * k / 4 -- 541
				fgDraw:drawSegment( -- 542
					Vec2(jx, y0 - bh * 0.4), -- 542
					Vec2(jx, y0 + bh * 0.1), -- 542
					1, -- 542
					Color(42, 44, 48, 225) -- 542
				) -- 542
				k = k + 1 -- 540
			end -- 540
		end -- 540
		do -- 540
			k = 1 -- 544
			while k <= 2 do -- 544
				local jx = bx0 + bw * (k + 0.35) / 3 -- 545
				fgDraw:drawSegment( -- 546
					Vec2(jx, y0 + bh * 0.1), -- 546
					Vec2(jx, y0 + bh * 0.6), -- 546
					1, -- 546
					Color(42, 44, 48, 225) -- 546
				) -- 546
				k = k + 1 -- 544
			end -- 544
		end -- 544
		fgDraw:drawSegment( -- 549
			Vec2(bx0, y0 + bh * 0.6), -- 549
			Vec2(bx1, y0 + bh * 0.6), -- 549
			1.6, -- 549
			Color(232, 234, 236, 230) -- 549
		) -- 549
	end -- 549
	if p.room.softX ~= nil then -- 549
		local sx0 = cam:sx(p.room.softX - 18) -- 554
		local sx1 = cam:sx(p.room.softX + 18) -- 555
		local sw = sx1 - sx0 -- 556
		fgDraw:drawRect( -- 557
			Rect(sx0, y0 - 3, sw, 6), -- 557
			Color(54, 44, 36, 225) -- 557
		) -- 557
		local dotOffsets = { -- 559
			0.1, -- 559
			0.24, -- 559
			0.37, -- 559
			0.51, -- 559
			0.68, -- 559
			0.81, -- 559
			0.92 -- 559
		} -- 559
		local d = 0 -- 560
		do -- 560
			d = 0 -- 561
			while d < #dotOffsets do -- 561
				local dx = sx0 + sw * dotOffsets[d + 1] -- 562
				local dy = y0 + (d & 1 == 0 and 1.5 or -1.2) -- 563
				fgDraw:drawDot( -- 564
					Vec2(dx, dy), -- 564
					1.5, -- 564
					Color(96, 82, 68, 215) -- 564
				) -- 564
				d = d + 1 -- 561
			end -- 561
		end -- 561
		local fp = 0 -- 567
		do -- 567
			fp = 0 -- 568
			while fp < 3 do -- 568
				local fx = sx0 + sw * (0.22 + fp * 0.28) -- 569
				fgDraw:drawEllipse( -- 570
					Vec2(fx, y0 + 1.2), -- 570
					math.max( -- 570
						3, -- 570
						cam:len(2.4) -- 570
					), -- 570
					1.6, -- 570
					Color(34, 28, 24, 210) -- 570
				) -- 570
				fp = fp + 1 -- 568
			end -- 568
		end -- 568
	end -- 568
end -- 527
function MingArtAuditPlugin.prototype.drawForestSilhouetteSeparation(self, fgDraw, p, cam) -- 575
	local childInGrass = false -- 577
	local dogInGrass = false -- 578
	local i = 0 -- 579
	do -- 579
		i = 0 -- 580
		while i < #p.room.solids do -- 580
			do -- 580
				local s = p.room.solids[i + 1] -- 581
				if s.passable ~= true then -- 581
					goto __continue76 -- 583
				end -- 583
				if p.player.x >= s.x - 16 and p.player.x <= s.x + s.w + 16 then -- 583
					childInGrass = true -- 586
				end -- 586
				if p.dogX >= s.x - 24 and p.dogX <= s.x + s.w + 24 then -- 586
					dogInGrass = true -- 589
				end -- 589
			end -- 589
			::__continue76:: -- 589
			i = i + 1 -- 580
		end -- 580
	end -- 580
	if childInGrass and p.player.alive then -- 580
		local cx = cam:sx(p.player.x) -- 594
		local topY = cam:sy(p.player.y + p.player.h) -- 595
		local halfW = cam:len(11) -- 596
		fgDraw:drawArc( -- 598
			Vec2( -- 598
				cx, -- 598
				topY - cam:len(7) -- 598
			), -- 598
			halfW, -- 598
			25, -- 598
			155, -- 598
			1.5, -- 598
			Color(214, 224, 230, 175) -- 598
		) -- 598
	end -- 598
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 598
		local alert = p.dogState == "ear" or p.dogState == "chase" -- 602
		if dogInGrass or alert then -- 602
			local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 604
			local dx = cam:sx(p.dogX + f * 12) -- 605
			local dy = cam:sy(24) -- 606
			local earH = cam:len(alert and 7.5 or 5) -- 607
			local earCol = alert and Color(238, 232, 222, 225) or Color(196, 206, 212, 175) -- 608
			fgDraw:drawSegment( -- 610
				Vec2(dx - f * 3, dy), -- 610
				Vec2(dx - f * 1, dy + earH), -- 610
				1.6, -- 610
				earCol -- 610
			) -- 610
			fgDraw:drawSegment( -- 611
				Vec2(dx - f * 1, dy + earH), -- 611
				Vec2(dx + f * 3, dy + 1), -- 611
				1.5, -- 611
				earCol -- 611
			) -- 611
		end -- 611
	end -- 611
end -- 575
function MingArtAuditPlugin.prototype.drawLeftEndRedClothAccent(self, fgDraw, p, cam) -- 616
	local c = p.room.cart -- 617
	local depth = c.depth or 0 -- 618
	local leftEdgeWorldX = p.cartAxle - c.bodyW * 0.56 -- 620
	local anchorX = cam:sx(leftEdgeWorldX) -- 621
	local anchorY = cam:sy(c.baseY + c.wheelR + c.bodyH * 0.85, depth) -- 622
	local sway = math.sin(self.animTime * 3.1) * cam:len(3.5) -- 623
	local len = cam:len(13) -- 624
	local drop = cam:len(15) -- 625
	fgDraw:drawPolygon( -- 627
		{ -- 627
			Vec2(anchorX, anchorY), -- 628
			Vec2(anchorX - len * 0.45, anchorY - drop * 0.42), -- 629
			Vec2(anchorX - len + sway, anchorY - drop), -- 630
			Vec2(anchorX - len * 0.55 + sway * 0.6, anchorY - drop * 0.86), -- 631
			Vec2( -- 632
				anchorX + cam:len(2), -- 632
				anchorY - drop * 0.25 -- 632
			) -- 632
		}, -- 632
		toColor(PALETTE.clothRed, 220) -- 633
	) -- 633
	fgDraw:drawSegment( -- 634
		Vec2(anchorX, anchorY), -- 635
		Vec2(anchorX - len + sway, anchorY - drop), -- 636
		1.2, -- 637
		toColor(PALETTE.clothRedHighlight, 200) -- 638
	) -- 638
end -- 616
function MingArtAuditPlugin.prototype.runAudit(self, host) -- 643
	local missingBackdrops = {} -- 644
	for roomKey in pairs(____exports.CORE_MING_BACKDROPS) do -- 645
		local slotKey = ____exports.CORE_MING_BACKDROPS[roomKey] -- 646
		local cfg = ASSET_SLOTS[slotKey] -- 647
		local path = cfg ~= nil and #cfg.paths > 0 and cfg.paths[1] or "" -- 648
		if path == "" or not Content:exist(path) then -- 648
			missingBackdrops[#missingBackdrops + 1] = (roomKey .. ":") .. path -- 650
		end -- 650
	end -- 650
	local missingSpriteClips = {} -- 654
	local i = 0 -- 655
	do -- 655
		i = 0 -- 656
		while i < #____exports.MING_PRESERVED_SPRITE_CLIPS do -- 656
			local clipName = ____exports.MING_PRESERVED_SPRITE_CLIPS[i + 1] -- 657
			local path = "assets/art/sprites.clip|" .. clipName -- 658
			if host ~= nil then -- 658
				local ok = host:tryPlacePath( -- 660
					path, -- 660
					"audit_spr_" .. clipName, -- 660
					-9999, -- 660
					-9999, -- 660
					16, -- 660
					16 -- 660
				) -- 660
				if not ok then -- 660
					missingSpriteClips[#missingSpriteClips + 1] = clipName -- 662
				end -- 662
			elseif not Content:exist("assets/art/sprites.clip") then -- 662
				missingSpriteClips[#missingSpriteClips + 1] = clipName -- 665
			end -- 665
			i = i + 1 -- 656
		end -- 656
	end -- 656
	local missingUiClips = {} -- 669
	do -- 669
		i = 0 -- 670
		while i < #____exports.MING_PRESERVED_UI_CLIPS do -- 670
			local uiName = ____exports.MING_PRESERVED_UI_CLIPS[i + 1] -- 671
			local path = "assets/art/ui_ink.clip|" .. uiName -- 672
			if host ~= nil then -- 672
				local ok = host:tryPlacePath( -- 674
					path, -- 674
					"audit_ui_" .. uiName, -- 674
					-9999, -- 674
					-9999, -- 674
					16, -- 674
					16 -- 674
				) -- 674
				if not ok then -- 674
					missingUiClips[#missingUiClips + 1] = uiName -- 676
				end -- 676
			elseif not Content:exist("assets/art/ui_ink.clip") then -- 676
				missingUiClips[#missingUiClips + 1] = uiName -- 679
			end -- 679
			i = i + 1 -- 670
		end -- 670
	end -- 670
	return { -- 683
		coreBackdropsOk = #missingBackdrops == 0, -- 684
		missingBackdrops = missingBackdrops, -- 685
		preservedSpriteClipsCount = #____exports.MING_PRESERVED_SPRITE_CLIPS - #missingSpriteClips, -- 686
		missingSpriteClips = missingSpriteClips, -- 687
		preservedUiClipsCount = #____exports.MING_PRESERVED_UI_CLIPS - #missingUiClips, -- 688
		missingUiClips = missingUiClips, -- 689
		cartClothLeftInvariantOk = self.cartLeftInvariantOk, -- 690
		fallbackInterceptCount = self.fallbackInterceptCount, -- 691
		woodDebrisTriggered = self.woodDebrisCount, -- 692
		brickDebrisTriggered = self.brickDebrisCount, -- 693
		powderSmokeTriggered = self.powderSmokeCount, -- 694
		legacyFindingsCount = #____exports.MING_LEGACY_FINDINGS -- 695
	} -- 695
end -- 643
return ____exports -- 643