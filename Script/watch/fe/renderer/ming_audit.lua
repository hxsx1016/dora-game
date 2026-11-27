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
	if direct ~= nil then -- 194
		return direct -- 195
	end -- 195
	local mapped = ____exports.FALLBACK_MING_BACKDROPS[roomKey] -- 197
	if mapped ~= nil then -- 198
		return mapped -- 199
	end -- 199
	return "bgFar_street" -- 201
end -- 192
function ____exports.isWoodCoverLabel(art, label) -- 204
	if art == "cover_wood" or art == "thin_wood" or art == "board" or art == "fence" or art == "basket_wall" then -- 205
		return true -- 206
	end -- 206
	if art == "cover_stone" or art == "wall" or art == "gate_post" or art == "well" then -- 208
		return false -- 209
	end -- 209
	if label ~= nil then -- 211
		if (string.find(label, "柜", nil, true) or 0) - 1 >= 0 or (string.find(label, "木", nil, true) or 0) - 1 >= 0 or (string.find(label, "桌", nil, true) or 0) - 1 >= 0 or (string.find(label, "货", nil, true) or 0) - 1 >= 0 or (string.find(label, "棚", nil, true) or 0) - 1 >= 0 or (string.find(label, "栏", nil, true) or 0) - 1 >= 0 then -- 213
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
	if p.room.cart.bodyW > 0 and p.room.cart.clothSide >= 0 then -- 254
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
	if loaded == nil then -- 263
		return -- 264
	end -- 264
	local rawFe = loaded["watch.fe"] -- 266
	if rawFe ~= nil and type(rawFe) == "table" then -- 267
		local watchFe = rawFe -- 268
		if watchFe.mingAudit ~= self then -- 269
			watchFe.mingAudit = self -- 270
		end -- 270
	end -- 270
end -- 260
function MingArtAuditPlugin.prototype.update(self, ctx) -- 275
	self:syncRuntimeHook() -- 276
	local p = ctx.p -- 277
	if self.lastRoomKey ~= "" and self.lastRoomKey ~= p.room.key then -- 279
		self:onBindPlay(p, ctx.view) -- 280
	end -- 280
	if p.room.cart.bodyW > 0 and p.room.cart.clothSide >= 0 then -- 282
		self.cartLeftInvariantOk = false -- 283
	end -- 283
	if ctx.paused or ctx.worldDt <= 0 then -- 286
		return -- 287
	end -- 287
	local dt = ctx.worldDt -- 290
	self.animTime = self.animTime + dt -- 291
	if ctx.events.coverDeflect then -- 294
		self:spawnCoverMaterialDebris(p) -- 295
	end -- 295
	if ctx.events.shotFired and ctx.events.shotTrace ~= nil then -- 299
		local tr = ctx.events.shotTrace -- 300
		self:spawnMatchlockSmoke(tr.x0, tr.y0, tr.x1 >= tr.x0 and 1 or -1) -- 301
		if not tr.hit and tr.y1 <= 42 then -- 302
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
			if c.life > 0 then -- 313
				c.vy = c.vy - (c.isWood and 360 or 210) * dt -- 314
				c.x = c.x + c.vx * dt -- 315
				c.y = c.y + c.vy * dt -- 316
				if c.y < 0 then -- 317
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
	__TS__ArraySetLength(self.chips, w) -- 326
	w = 0 -- 329
	do -- 329
		i = 0 -- 330
		while i < #self.puffs do -- 330
			local pf = self.puffs[i + 1] -- 331
			pf.life = pf.life - dt -- 332
			if pf.life > 0 then -- 333
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
	__TS__ArraySetLength(self.puffs, w) -- 342
end -- 275
function MingArtAuditPlugin.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 349
	local roomKey = ctx.p.room.key -- 355
	if ____exports.CORE_MING_BACKDROPS[roomKey] ~= nil then -- 356
		return false -- 357
	end -- 357
	if ctx.view.visualMode == "lowpoly" or ctx.view.visualMode == "museum" then -- 360
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
	if backdropArt:tryPlace( -- 376
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
function MingArtAuditPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 397
	local p = ctx.p -- 403
	local cam = ctx.cam -- 404
	local isPixelStyle = ctx.view.visualMode == "pixel" or ctx.view.visualMode == "transition" -- 405
	if isPixelStyle and p.room.key == "village" then -- 408
		self:drawVillageGrayscaleSurfaces(fgDraw, p, cam) -- 409
	end -- 409
	if isPixelStyle and p.room.key == "forest" then -- 413
		self:drawForestSilhouetteSeparation(fgDraw, p, cam) -- 414
	end -- 414
	if isPixelStyle and (p.room.key == "checkpoint" or p.room.key == "outside") and p.room.cart.bodyW > 0 then -- 418
		self:drawLeftEndRedClothAccent(fgDraw, p, cam) -- 419
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
			if c.isWood then -- 437
				fgDraw:drawRect( -- 439
					Rect(sx - sw * 0.5, sy - sh * 0.5, sw, sh), -- 439
					Color( -- 439
						128, -- 439
						86, -- 439
						54, -- 439
						math.floor(235 * k + 0.5) -- 439
					) -- 439
				) -- 439
				fgDraw:drawSegment( -- 440
					Vec2(sx - sw * 0.5, sy + sh * 0.5), -- 440
					Vec2(sx + sw * 0.5, sy + sh * 0.5), -- 440
					0.9, -- 440
					Color( -- 440
						196, -- 440
						162, -- 440
						118, -- 440
						math.floor(180 * k + 0.5) -- 440
					) -- 440
				) -- 440
			else -- 440
				fgDraw:drawCircle( -- 443
					Vec2(sx, sy), -- 443
					sw * 0.65, -- 443
					Color( -- 443
						164, -- 443
						168, -- 443
						172, -- 443
						math.floor(175 * k + 0.5) -- 443
					) -- 443
				) -- 443
				fgDraw:drawDot( -- 444
					Vec2(sx + 1, sy + 1), -- 444
					math.max(1.2, sw * 0.32), -- 444
					Color( -- 444
						218, -- 444
						220, -- 444
						224, -- 444
						math.floor(210 * k + 0.5) -- 444
					) -- 444
				) -- 444
			end -- 444
			i = i + 1 -- 430
		end -- 430
	end -- 430
	do -- 430
		i = 0 -- 449
		while i < #self.puffs do -- 449
			local pf = self.puffs[i + 1] -- 450
			local k = pf.life / pf.maxLife -- 451
			local sx = cam:sx(pf.x) -- 452
			local sy = cam:sy(pf.y) -- 453
			local r = math.max( -- 454
				2, -- 454
				cam:len(pf.r) -- 454
			) -- 454
			fgDraw:drawCircle( -- 455
				Vec2(sx, sy), -- 455
				r, -- 455
				Color( -- 455
					196, -- 455
					198, -- 455
					200, -- 455
					math.floor(92 * k + 0.5) -- 455
				) -- 455
			) -- 455
			fgGlow:drawCircle( -- 456
				Vec2(sx, sy), -- 456
				r * 0.62, -- 456
				Color( -- 456
					224, -- 456
					222, -- 456
					214, -- 456
					math.floor(48 * k + 0.5) -- 456
				) -- 456
			) -- 456
			i = i + 1 -- 449
		end -- 449
	end -- 449
end -- 397
function MingArtAuditPlugin.prototype.spawnCoverMaterialDebris(self, p) -- 460
	local hitX = p.player.x + p.player.facing * 16 -- 461
	local hitY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.5 -- 462
	local isWood = false -- 463
	local nearest = 56 -- 464
	local i = 0 -- 465
	do -- 465
		i = 0 -- 466
		while i < #p.room.solids do -- 466
			do -- 466
				local s = p.room.solids[i + 1] -- 467
				if s.passable or s.decorative or s.y > p.player.y + 4 or s.h > 72 then -- 468
					goto __continue50 -- 469
				end -- 469
				if not overlapsDepth(p.player.depth, s.depth, ACTOR_DEPTH_HALF) then -- 471
					goto __continue50 -- 472
				end -- 472
				local edge = p.player.x < s.x and s.x or s.x + s.w -- 474
				local gap = math.abs(p.player.x - edge) -- 475
				if gap < nearest then -- 476
					nearest = gap -- 477
					hitX = edge -- 478
					local ____s_y_3 = s.y -- 479
					local ____opt_1 = s.depth -- 479
					hitY = ____s_y_3 + (____opt_1 and ____opt_1.min or 0) * DEPTH_Y_SCALE + s.h * 0.85 -- 479
					isWood = ____exports.isWoodCoverLabel(s.art, s.label) -- 480
				end -- 480
			end -- 480
			::__continue50:: -- 480
			i = i + 1 -- 466
		end -- 466
	end -- 466
	if isWood then -- 484
		self.woodDebrisCount = self.woodDebrisCount + 1 -- 485
	else -- 485
		self.brickDebrisCount = self.brickDebrisCount + 1 -- 487
	end -- 487
	local count = isWood and 9 or 10 -- 490
	do -- 490
		i = 0 -- 491
		while i < count do -- 491
			local ang = (self:rand() - 0.5) * math.pi * 1.15 -- 492
			local spd = (isWood and 85 or 58) * (0.45 + self:rand() * 0.75) -- 493
			local life = (isWood and 0.34 or 0.42) + self:rand() * 0.16 -- 494
			local ____self_chips_4 = self.chips -- 495
			____self_chips_4[#____self_chips_4 + 1] = { -- 495
				x = hitX, -- 496
				y = hitY, -- 497
				vx = -p.player.facing * math.abs(math.cos(ang)) * spd + (self:rand() - 0.5) * 35, -- 498
				vy = math.abs(math.sin(ang)) * spd + (isWood and 55 or 28), -- 499
				w = isWood and 4.5 + self:rand() * 3.5 or 2.6 + self:rand() * 2.8, -- 500
				h = isWood and 1.8 + self:rand() * 1.4 or 2.6 + self:rand() * 2.8, -- 501
				life = life, -- 502
				maxLife = life, -- 503
				isWood = isWood -- 504
			} -- 504
			i = i + 1 -- 491
		end -- 491
	end -- 491
end -- 460
function MingArtAuditPlugin.prototype.spawnMatchlockSmoke(self, wx, wy, dir) -- 509
	self.powderSmokeCount = self.powderSmokeCount + 1 -- 510
	local i = 0 -- 511
	do -- 511
		i = 0 -- 512
		while i < 5 do -- 512
			local life = 0.24 + self:rand() * 0.18 -- 513
			local ____self_puffs_5 = self.puffs -- 514
			____self_puffs_5[#____self_puffs_5 + 1] = { -- 514
				x = wx + dir * (4 + i * 3.5), -- 515
				y = wy + (self:rand() - 0.4) * 5, -- 516
				vx = dir * (28 + self:rand() * 44), -- 517
				vy = 14 + self:rand() * 22, -- 518
				r = 3 + self:rand() * 2.4, -- 519
				life = life, -- 520
				maxLife = life -- 521
			} -- 521
			i = i + 1 -- 512
		end -- 512
	end -- 512
end -- 509
function MingArtAuditPlugin.prototype.addScorch(self, wx, wy) -- 526
	local ____self_scorches_6 = self.scorches -- 527
	____self_scorches_6[#____self_scorches_6 + 1] = { -- 527
		x = wx, -- 527
		y = wy, -- 527
		rx = 5.5 + self:rand() * 3 -- 527
	} -- 527
	if #self.scorches > 16 then -- 528
		table.remove(self.scorches, 1) -- 529
	end -- 529
end -- 526
function MingArtAuditPlugin.prototype.drawVillageGrayscaleSurfaces(self, fgDraw, p, cam) -- 533
	local y0 = cam:sy(0) -- 534
	if p.room.brickX ~= nil then -- 537
		local bx0 = cam:sx(p.room.brickX - 18) -- 538
		local bx1 = cam:sx(p.room.brickX + 18) -- 539
		local bw = bx1 - bx0 -- 540
		local bh = math.max( -- 541
			7, -- 541
			cam:len(4.5) -- 541
		) -- 541
		fgDraw:drawRect( -- 542
			Rect(bx0, y0 - bh * 0.4, bw, bh), -- 542
			Color(142, 146, 150, 235), -- 542
			1, -- 542
			Color(216, 220, 224, 220) -- 542
		) -- 542
		fgDraw:drawSegment( -- 544
			Vec2(bx0 + 1, y0 + bh * 0.1), -- 544
			Vec2(bx1 - 1, y0 + bh * 0.1), -- 544
			1, -- 544
			Color(42, 44, 48, 225) -- 544
		) -- 544
		local k = 1 -- 545
		do -- 545
			k = 1 -- 546
			while k <= 3 do -- 546
				local jx = bx0 + bw * k / 4 -- 547
				fgDraw:drawSegment( -- 548
					Vec2(jx, y0 - bh * 0.4), -- 548
					Vec2(jx, y0 + bh * 0.1), -- 548
					1, -- 548
					Color(42, 44, 48, 225) -- 548
				) -- 548
				k = k + 1 -- 546
			end -- 546
		end -- 546
		do -- 546
			k = 1 -- 550
			while k <= 2 do -- 550
				local jx = bx0 + bw * (k + 0.35) / 3 -- 551
				fgDraw:drawSegment( -- 552
					Vec2(jx, y0 + bh * 0.1), -- 552
					Vec2(jx, y0 + bh * 0.6), -- 552
					1, -- 552
					Color(42, 44, 48, 225) -- 552
				) -- 552
				k = k + 1 -- 550
			end -- 550
		end -- 550
		fgDraw:drawSegment( -- 555
			Vec2(bx0, y0 + bh * 0.6), -- 555
			Vec2(bx1, y0 + bh * 0.6), -- 555
			1.6, -- 555
			Color(232, 234, 236, 230) -- 555
		) -- 555
	end -- 555
	if p.room.softX ~= nil then -- 559
		local sx0 = cam:sx(p.room.softX - 18) -- 560
		local sx1 = cam:sx(p.room.softX + 18) -- 561
		local sw = sx1 - sx0 -- 562
		fgDraw:drawRect( -- 563
			Rect(sx0, y0 - 3, sw, 6), -- 563
			Color(54, 44, 36, 225) -- 563
		) -- 563
		local dotOffsets = { -- 565
			0.1, -- 565
			0.24, -- 565
			0.37, -- 565
			0.51, -- 565
			0.68, -- 565
			0.81, -- 565
			0.92 -- 565
		} -- 565
		local d = 0 -- 566
		do -- 566
			d = 0 -- 567
			while d < #dotOffsets do -- 567
				local dx = sx0 + sw * dotOffsets[d + 1] -- 568
				local dy = y0 + (d & 1 == 0 and 1.5 or -1.2) -- 569
				fgDraw:drawDot( -- 570
					Vec2(dx, dy), -- 570
					1.5, -- 570
					Color(96, 82, 68, 215) -- 570
				) -- 570
				d = d + 1 -- 567
			end -- 567
		end -- 567
		local fp = 0 -- 573
		do -- 573
			fp = 0 -- 574
			while fp < 3 do -- 574
				local fx = sx0 + sw * (0.22 + fp * 0.28) -- 575
				fgDraw:drawEllipse( -- 576
					Vec2(fx, y0 + 1.2), -- 576
					math.max( -- 576
						3, -- 576
						cam:len(2.4) -- 576
					), -- 576
					1.6, -- 576
					Color(34, 28, 24, 210) -- 576
				) -- 576
				fp = fp + 1 -- 574
			end -- 574
		end -- 574
	end -- 574
end -- 533
function MingArtAuditPlugin.prototype.drawForestSilhouetteSeparation(self, fgDraw, p, cam) -- 581
	local childInGrass = false -- 583
	local dogInGrass = false -- 584
	local i = 0 -- 585
	do -- 585
		i = 0 -- 586
		while i < #p.room.solids do -- 586
			do -- 586
				local s = p.room.solids[i + 1] -- 587
				if s.passable ~= true then -- 588
					goto __continue76 -- 589
				end -- 589
				if p.player.x >= s.x - 16 and p.player.x <= s.x + s.w + 16 then -- 591
					childInGrass = true -- 592
				end -- 592
				if p.dogX >= s.x - 24 and p.dogX <= s.x + s.w + 24 then -- 594
					dogInGrass = true -- 595
				end -- 595
			end -- 595
			::__continue76:: -- 595
			i = i + 1 -- 586
		end -- 586
	end -- 586
	if childInGrass and p.player.alive then -- 599
		local cx = cam:sx(p.player.x) -- 600
		local topY = cam:sy(p.player.y + p.player.h) -- 601
		local halfW = cam:len(11) -- 602
		fgDraw:drawArc( -- 604
			Vec2( -- 604
				cx, -- 604
				topY - cam:len(7) -- 604
			), -- 604
			halfW, -- 604
			25, -- 604
			155, -- 604
			1.5, -- 604
			Color(214, 224, 230, 175) -- 604
		) -- 604
	end -- 604
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 607
		local alert = p.dogState == "ear" or p.dogState == "chase" -- 608
		if dogInGrass or alert then -- 609
			local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 610
			local dx = cam:sx(p.dogX + f * 12) -- 611
			local dy = cam:sy(24) -- 612
			local earH = cam:len(alert and 7.5 or 5) -- 613
			local earCol = alert and Color(238, 232, 222, 225) or Color(196, 206, 212, 175) -- 614
			fgDraw:drawSegment( -- 616
				Vec2(dx - f * 3, dy), -- 616
				Vec2(dx - f * 1, dy + earH), -- 616
				1.6, -- 616
				earCol -- 616
			) -- 616
			fgDraw:drawSegment( -- 617
				Vec2(dx - f * 1, dy + earH), -- 617
				Vec2(dx + f * 3, dy + 1), -- 617
				1.5, -- 617
				earCol -- 617
			) -- 617
		end -- 617
	end -- 617
end -- 581
function MingArtAuditPlugin.prototype.drawLeftEndRedClothAccent(self, fgDraw, p, cam) -- 622
	local c = p.room.cart -- 623
	local depth = c.depth or 0 -- 624
	local leftEdgeWorldX = p.cartAxle - c.bodyW * 0.56 -- 626
	local anchorX = cam:sx(leftEdgeWorldX) -- 627
	local anchorY = cam:sy(c.baseY + c.wheelR + c.bodyH * 0.85, depth) -- 628
	local sway = math.sin(self.animTime * 3.1) * cam:len(3.5) -- 629
	local len = cam:len(13) -- 630
	local drop = cam:len(15) -- 631
	fgDraw:drawPolygon( -- 633
		{ -- 633
			Vec2(anchorX, anchorY), -- 634
			Vec2(anchorX - len * 0.45, anchorY - drop * 0.42), -- 635
			Vec2(anchorX - len + sway, anchorY - drop), -- 636
			Vec2(anchorX - len * 0.55 + sway * 0.6, anchorY - drop * 0.86), -- 637
			Vec2( -- 638
				anchorX + cam:len(2), -- 638
				anchorY - drop * 0.25 -- 638
			) -- 638
		}, -- 638
		toColor(PALETTE.clothRed, 220) -- 639
	) -- 639
	fgDraw:drawSegment( -- 640
		Vec2(anchorX, anchorY), -- 641
		Vec2(anchorX - len + sway, anchorY - drop), -- 642
		1.2, -- 643
		toColor(PALETTE.clothRedHighlight, 200) -- 644
	) -- 644
end -- 622
function MingArtAuditPlugin.prototype.runAudit(self, host) -- 649
	local missingBackdrops = {} -- 650
	for roomKey in pairs(____exports.CORE_MING_BACKDROPS) do -- 651
		local slotKey = ____exports.CORE_MING_BACKDROPS[roomKey] -- 652
		local cfg = ASSET_SLOTS[slotKey] -- 653
		local path = cfg ~= nil and #cfg.paths > 0 and cfg.paths[1] or "" -- 654
		if path == "" or not Content:exist(path) then -- 655
			missingBackdrops[#missingBackdrops + 1] = (roomKey .. ":") .. path -- 656
		end -- 656
	end -- 656
	local missingSpriteClips = {} -- 660
	local i = 0 -- 661
	do -- 661
		i = 0 -- 662
		while i < #____exports.MING_PRESERVED_SPRITE_CLIPS do -- 662
			local clipName = ____exports.MING_PRESERVED_SPRITE_CLIPS[i + 1] -- 663
			local path = "assets/art/sprites.clip|" .. clipName -- 664
			if host ~= nil then -- 665
				local ok = host:tryPlacePath( -- 666
					path, -- 666
					"audit_spr_" .. clipName, -- 666
					-9999, -- 666
					-9999, -- 666
					16, -- 666
					16 -- 666
				) -- 666
				if not ok then -- 667
					missingSpriteClips[#missingSpriteClips + 1] = clipName -- 668
				end -- 668
			elseif not Content:exist("assets/art/sprites.clip") then -- 670
				missingSpriteClips[#missingSpriteClips + 1] = clipName -- 671
			end -- 671
			i = i + 1 -- 662
		end -- 662
	end -- 662
	local missingUiClips = {} -- 675
	do -- 675
		i = 0 -- 676
		while i < #____exports.MING_PRESERVED_UI_CLIPS do -- 676
			local uiName = ____exports.MING_PRESERVED_UI_CLIPS[i + 1] -- 677
			local path = "assets/art/ui_ink.clip|" .. uiName -- 678
			if host ~= nil then -- 679
				local ok = host:tryPlacePath( -- 680
					path, -- 680
					"audit_ui_" .. uiName, -- 680
					-9999, -- 680
					-9999, -- 680
					16, -- 680
					16 -- 680
				) -- 680
				if not ok then -- 681
					missingUiClips[#missingUiClips + 1] = uiName -- 682
				end -- 682
			elseif not Content:exist("assets/art/ui_ink.clip") then -- 684
				missingUiClips[#missingUiClips + 1] = uiName -- 685
			end -- 685
			i = i + 1 -- 676
		end -- 676
	end -- 676
	return { -- 689
		coreBackdropsOk = #missingBackdrops == 0, -- 690
		missingBackdrops = missingBackdrops, -- 691
		preservedSpriteClipsCount = #____exports.MING_PRESERVED_SPRITE_CLIPS - #missingSpriteClips, -- 692
		missingSpriteClips = missingSpriteClips, -- 693
		preservedUiClipsCount = #____exports.MING_PRESERVED_UI_CLIPS - #missingUiClips, -- 694
		missingUiClips = missingUiClips, -- 695
		cartClothLeftInvariantOk = self.cartLeftInvariantOk, -- 696
		fallbackInterceptCount = self.fallbackInterceptCount, -- 697
		woodDebrisTriggered = self.woodDebrisCount, -- 698
		brickDebrisTriggered = self.brickDebrisCount, -- 699
		powderSmokeTriggered = self.powderSmokeCount, -- 700
		legacyFindingsCount = #____exports.MING_LEGACY_FINDINGS -- 701
	} -- 701
end -- 649
return ____exports -- 649
