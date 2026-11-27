-- [ts]: talent_catalog.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 14
local Color = ____Dora.Color -- 14
local Rect = ____Dora.Rect -- 14
local Vec2 = ____Dora.Vec2 -- 14
local ____run = require("Script.watch.run") -- 15
local ALL_TALENTS = ____run.ALL_TALENTS -- 15
local TALENT_CATALOG = ____run.TALENT_CATALOG -- 15
local talentNames = ____run.talentNames -- 15
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 17
local drawReloadPatternGlyph = ____reload_wheel.drawReloadPatternGlyph -- 17
local ____theme = require("Script.watch.fe.theme") -- 18
local PALETTE = ____theme.PALETTE -- 19
local drawDiamond = ____theme.drawDiamond -- 21
local fillRadialGlow = ____theme.fillRadialGlow -- 22
local toColor = ____theme.toColor -- 23
local RANK_NUMERALS = { -- 67
	"零", -- 67
	"壹", -- 67
	"贰", -- 67
	"叁", -- 67
	"肆", -- 67
	"伍", -- 67
	"陆", -- 67
	"柒", -- 67
	"捌", -- 67
	"玖", -- 67
	"拾" -- 67
} -- 67
--- 将本领阶位转为传统中文大写（全覆盖正文字库，无缺失罗马数字）。
function ____exports.rankChinese(rank) -- 70
	local r = math.max( -- 71
		0, -- 71
		math.floor(rank) -- 71
	) -- 71
	if r < #RANK_NUMERALS then -- 71
		return RANK_NUMERALS[r + 1] -- 73
	end -- 73
	return "" .. tostring(r) -- 75
end -- 70
local TALENT_REGISTRY = {} -- 78
--- 注册或扩展自定义本领视觉定义（表驱动，方便后续并行扩展新本领）。
function ____exports.registerTalentVisual(meta) -- 81
	TALENT_REGISTRY[meta.id] = meta -- 82
end -- 81
for ____, id in ipairs(ALL_TALENTS) do -- 85
	local meta = TALENT_CATALOG[id] -- 86
	local body = meta.branch == "body" -- 87
	____exports.registerTalentVisual({ -- 88
		id = id, -- 89
		title = meta.title, -- 89
		category = meta.branchZh, -- 89
		accent = body and PALETTE.cyan or PALETTE.amber, -- 90
		accentCore = body and PALETTE.moonPale or PALETTE.amberCore, -- 91
		whisper = meta.detailDesc, -- 92
		absorbTarget = id == "vitality" and "hp" or (body and "shoulder" or (meta.branch == "wheel" and "gun" or "satchel")), -- 93
		shortEffect = function() return meta.shortDesc end, -- 94
		subEffect = function(____, _snap, rank) return ((____exports.rankChinese(rank) .. " → ") .. ____exports.rankChinese(rank + 1)) .. " 阶" end, -- 95
		ledgerLine = function(____, _snap, rank) return ((meta.shortDesc .. "（") .. ____exports.rankChinese(rank)) .. " 阶）" end -- 96
	}) -- 96
end -- 96
--- 解析任意本领 ID 的视觉元数据；未知未来 ID 自动回退至明代军筹通用模板。
function ____exports.resolveTalentVisual(id, snap) -- 101
	local reg = TALENT_REGISTRY[id] -- 102
	if reg ~= nil then -- 102
		return reg -- 104
	end -- 104
	local hint = snap ~= nil and snap.talentLabelHints[id] or nil or talentNames[id] or id -- 106
	local dotIdx = (string.find(hint, "·", nil, true) or 0) - 1 -- 109
	local parsedTitle = dotIdx > 0 and __TS__StringSlice(hint, 0, dotIdx) or hint -- 110
	local parsedDesc = dotIdx > 0 and __TS__StringSlice(hint, dotIdx + 1) or "行军备策 · 增益一阶" -- 111
	return { -- 112
		id = id, -- 113
		title = parsedTitle ~= "" and parsedTitle or "军筹", -- 114
		category = "军筹", -- 115
		accent = PALETTE.jadeMist, -- 116
		accentCore = PALETTE.textBright, -- 117
		whisper = "「夜路漫漫，多备一筹总安心。」", -- 118
		absorbTarget = "crest", -- 119
		shortEffect = function() return parsedDesc end, -- 120
		subEffect = function(____, _s, curRank) return ((("现 " .. ____exports.rankChinese(curRank)) .. " → ") .. ____exports.rankChinese(curRank + 1)) .. " 阶" end, -- 121
		ledgerLine = function(____, _s, rank) return ((parsedDesc .. "（") .. ____exports.rankChinese(rank)) .. " 阶）" end -- 122
	} -- 122
end -- 101
local WEAPON_META = {standard_gun = { -- 126
	id = "standard_gun", -- 128
	name = "标准鸟铳", -- 129
	shortName = "鸟铳", -- 130
	effect = "normal", -- 131
	accent = PALETTE.silkLine, -- 132
	desc = "九宫连线蓄推退、铃纹、灯纹" -- 133
}, guide_lantern_gun = { -- 133
	id = "guide_lantern_gun", -- 136
	name = "引路灯铳", -- 137
	shortName = "灯铳", -- 138
	effect = "light", -- 139
	accent = PALETTE.amberCore, -- 140
	desc = "强化灯纹破夜光晕镇敌" -- 141
}, echo_gun = { -- 141
	id = "echo_gun", -- 144
	name = "回声铜铃铳", -- 145
	shortName = "回声铳", -- 146
	effect = "echo", -- 147
	accent = PALETTE.cyanCore, -- 148
	desc = "强化铃纹双响回声诱敌" -- 149
}, time_shuttler = { -- 149
	id = "time_shuttler", -- 152
	name = "时间穿梭器", -- 153
	shortName = "穿梭器", -- 154
	effect = "knockback", -- 155
	accent = PALETTE.amberCore, -- 156
	desc = "双线归档旧物，冷白残影" -- 157
}} -- 157
function ____exports.weaponMetaOf(weaponId) -- 161
	return WEAPON_META[weaponId] or WEAPON_META.standard_gun -- 162
end -- 161
____exports.PICKUP_ORDER = { -- 165
	"wood", -- 166
	"bell", -- 167
	"shield", -- 168
	"wedge", -- 169
	"ammo", -- 170
	"scrap", -- 171
	"pass", -- 172
	"quickbelt" -- 173
} -- 173
local PICKUP_META = { -- 176
	wood = { -- 177
		kind = "wood", -- 177
		name = "木纹筹", -- 177
		shortName = "木筹", -- 177
		accent = PALETTE.amber, -- 177
		accentCore = PALETTE.amberCore, -- 177
		category = "material" -- 177
	}, -- 177
	bell = { -- 178
		kind = "bell", -- 178
		name = "铃纹筹", -- 178
		shortName = "铃筹", -- 178
		accent = PALETTE.amberCore, -- 178
		accentCore = PALETTE.amberCore, -- 178
		category = "material" -- 178
	}, -- 178
	shield = { -- 179
		kind = "shield", -- 179
		name = "残盾", -- 179
		shortName = "残盾", -- 179
		accent = PALETTE.cyan, -- 179
		accentCore = PALETTE.cyanCore, -- 179
		category = "gear" -- 179
	}, -- 179
	wedge = { -- 180
		kind = "wedge", -- 180
		name = "木楔", -- 180
		shortName = "木楔", -- 180
		accent = PALETTE.emerald, -- 180
		accentCore = PALETTE.moonPale, -- 180
		category = "gear" -- 180
	}, -- 180
	ammo = { -- 181
		kind = "ammo", -- 181
		name = "备用弹包", -- 181
		shortName = "弹包", -- 181
		accent = PALETTE.rouge, -- 181
		accentCore = PALETTE.crimsonCore, -- 181
		category = "gear" -- 181
	}, -- 181
	scrap = { -- 182
		kind = "scrap", -- 182
		name = "废木料", -- 182
		shortName = "木料", -- 182
		accent = PALETTE.amberDim, -- 182
		accentCore = PALETTE.amber, -- 182
		category = "material" -- 182
	}, -- 182
	pass = { -- 183
		kind = "pass", -- 183
		name = "护送号牌", -- 183
		shortName = "号牌", -- 183
		accent = PALETTE.jadeMist, -- 183
		accentCore = PALETTE.textBright, -- 183
		category = "gear" -- 183
	}, -- 183
	quickbelt = { -- 184
		kind = "quickbelt", -- 184
		name = "快装带", -- 184
		shortName = "装带", -- 184
		accent = PALETTE.amber, -- 184
		accentCore = PALETTE.amberCore, -- 184
		category = "gear" -- 184
	} -- 184
} -- 184
function ____exports.pickupMetaOf(kind) -- 187
	return PICKUP_META[kind] or ({ -- 188
		kind = kind, -- 189
		name = kind, -- 190
		shortName = kind, -- 191
		accent = PALETTE.silkLine, -- 192
		accentCore = PALETTE.textBright, -- 193
		category = "gear" -- 194
	}) -- 194
end -- 187
--- 按当前已习本领、所持火铳与战备派生纯前端「行军雅号」（零后端侵入）。
function ____exports.deriveMarchTitle(snap) -- 199
	local vit = snap.ranks.vitality or 0 -- 200
	local rel = snap.ranks.focus or 0 -- 201
	local grd = snap.ranks.guard or 0 -- 202
	local crf = snap.ranks.salvage or 0 -- 203
	local total = snap.totalRanks -- 204
	local weapon = snap.equippedWeapon -- 205
	local wedge = snap.supplies.wedge or 0 -- 206
	if total <= 0 then -- 206
		return { -- 209
			title = "初启北行", -- 209
			sealTop = "守", -- 209
			sealBot = "望", -- 209
			subtitle = "行囊初整，孤灯在前", -- 209
			accent = PALETTE.silkLine -- 209
		} -- 209
	end -- 209
	if rel >= 2 and weapon == "guide_lantern_gun" then -- 209
		return { -- 212
			title = "明火疾铳", -- 212
			sealTop = "明", -- 212
			sealBot = "火", -- 212
			subtitle = "灯影破夜，火绳如电", -- 212
			accent = PALETTE.amberCore -- 212
		} -- 212
	end -- 212
	if rel >= 2 and weapon == "echo_gun" then -- 212
		return { -- 215
			title = "惊铃连响", -- 215
			sealTop = "惊", -- 215
			sealBot = "铃", -- 215
			subtitle = "铜铃惑敌，连发不断", -- 215
			accent = PALETTE.cyanCore -- 215
		} -- 215
	end -- 215
	if vit + grd >= 3 and vit >= 1 and grd >= 1 then -- 215
		return { -- 218
			title = "铁壁断后", -- 218
			sealTop = "铁", -- 218
			sealBot = "壁", -- 218
			subtitle = "重甲护身，步履不乱", -- 218
			accent = PALETTE.cyan -- 218
		} -- 218
	end -- 218
	if crf >= 2 or crf >= 1 and wedge >= 1 then -- 218
		return { -- 221
			title = "巧楔筑垒", -- 221
			sealTop = "巧", -- 221
			sealBot = "楔", -- 221
			subtitle = "削木固掩，以巧破险", -- 221
			accent = PALETTE.emerald -- 221
		} -- 221
	end -- 221
	if rel >= 2 then -- 221
		return { -- 224
			title = "疾火连铳", -- 224
			sealTop = "疾", -- 224
			sealBot = "铳", -- 224
			subtitle = "熟手快装，火线不绝", -- 224
			accent = PALETTE.amber -- 224
		} -- 224
	end -- 224
	if vit >= 2 then -- 224
		return { -- 227
			title = "重甲负行", -- 227
			sealTop = "重", -- 227
			sealBot = "甲", -- 227
			subtitle = "铁衣加身，稳背同行", -- 227
			accent = PALETTE.cyan -- 227
		} -- 227
	end -- 227
	if grd >= 2 then -- 227
		return { -- 230
			title = "稳步护势", -- 230
			sealTop = "护", -- 230
			sealBot = "身", -- 230
			subtitle = "身法从容，危中留隙", -- 230
			accent = PALETTE.emerald -- 230
		} -- 230
	end -- 230
	return { -- 232
		title = "孤城守望", -- 232
		sealTop = "守", -- 232
		sealBot = "望", -- 232
		subtitle = "诸筹兼备，护她北归", -- 232
		accent = PALETTE.rouge -- 232
	} -- 232
end -- 199
--- 内部工具：用短折线绘制清秀明式弧线（兼容所有缩放与灰度）。
function ____exports.drawBrushArc(draw, cx, cy, rx, ry, startRad, endRad, thickness, color, segments) -- 236
	if segments == nil then -- 236
		segments = 14 -- 246
	end -- 246
	local n = math.max(4, segments) -- 248
	local prevX = cx + math.cos(startRad) * rx -- 249
	local prevY = cy + math.sin(startRad) * ry -- 250
	local i = 1 -- 251
	do -- 251
		i = 1 -- 252
		while i <= n do -- 252
			local a = startRad + (endRad - startRad) * i / n -- 253
			local nx = cx + math.cos(a) * rx -- 254
			local ny = cy + math.sin(a) * ry -- 255
			draw:drawSegment( -- 256
				Vec2(prevX, prevY), -- 256
				Vec2(nx, ny), -- 256
				thickness, -- 256
				color -- 256
			) -- 256
			prevX = nx -- 257
			prevY = ny -- 258
			i = i + 1 -- 252
		end -- 252
	end -- 252
end -- 236
--- 绘制明初器物工笔本领纹样（纯 DrawNode 矢量，静音与灰度下轮廓 100% 互异）：
-- - vitality：明式叠鳞札甲 + 居中圆形护心镜
-- - reload：明式鸟铳龙头火绳弯钩 + 药池微星
-- - guard：明式云肩披膊 + 双向卸力偏锋弧
-- - craft：削木短刀 + 梯形木楔契口
-- - fallback：明代卫所竖式军筹木简
function ____exports.drawTalentGlyph(draw, cx, cy, radius, talentId, col, alpha, coreCol) -- 270
	if alpha == nil then -- 270
		alpha = 1 -- 277
	end -- 277
	local r = math.max(5, radius) -- 280
	local lw = math.max(1, r * 0.085) -- 281
	local stroke = toColor(col, 240 * alpha) -- 282
	local core = toColor(coreCol or PALETTE.textBright, 245 * alpha) -- 283
	local faint = toColor(col, 125 * alpha) -- 284
	local fill = toColor(col, 38 * alpha) -- 285
	if talentId == "vitality" then -- 285
		draw:drawPolygon( -- 289
			{ -- 289
				Vec2(cx - r * 0.72, cy + r * 0.66), -- 290
				Vec2(cx - r * 0.28, cy + r * 0.82), -- 291
				Vec2(cx + r * 0.28, cy + r * 0.82), -- 292
				Vec2(cx + r * 0.72, cy + r * 0.66), -- 293
				Vec2(cx + r * 0.64, cy - r * 0.26), -- 294
				Vec2(cx, cy - r * 0.84), -- 295
				Vec2(cx - r * 0.64, cy - r * 0.26) -- 296
			}, -- 296
			fill, -- 297
			lw * 1.1, -- 297
			stroke -- 297
		) -- 297
		draw:drawSegment( -- 299
			Vec2(cx - r * 0.62, cy + r * 0.22), -- 299
			Vec2(cx + r * 0.62, cy + r * 0.22), -- 299
			lw * 0.8, -- 299
			faint -- 299
		) -- 299
		draw:drawSegment( -- 300
			Vec2(cx - r * 0.56, cy - r * 0.24), -- 300
			Vec2(cx + r * 0.56, cy - r * 0.24), -- 300
			lw * 0.8, -- 300
			faint -- 300
		) -- 300
		draw:drawSegment( -- 302
			Vec2(cx - r * 0.3, cy - r * 0.52), -- 302
			Vec2(cx - r * 0.34, cy + r * 0.68), -- 302
			lw * 0.7, -- 302
			faint -- 302
		) -- 302
		draw:drawSegment( -- 303
			Vec2(cx + r * 0.3, cy - r * 0.52), -- 303
			Vec2(cx + r * 0.34, cy + r * 0.68), -- 303
			lw * 0.7, -- 303
			faint -- 303
		) -- 303
		draw:drawCircle( -- 305
			Vec2(cx, cy + r * 0.04), -- 305
			r * 0.32, -- 305
			toColor(PALETTE.panelBgDeep, 210 * alpha) -- 305
		) -- 305
		draw:drawRing( -- 306
			Vec2(cx, cy + r * 0.04), -- 306
			r * 0.26, -- 306
			r * 0.34, -- 306
			Color(0, 0, 0, 0), -- 306
			lw, -- 306
			core -- 306
		) -- 306
		draw:drawDot( -- 307
			Vec2(cx, cy + r * 0.04), -- 307
			math.max(1.4, r * 0.11), -- 307
			core -- 307
		) -- 307
		return -- 308
	end -- 308
	if talentId == "focus" then -- 308
		draw:drawSegment( -- 313
			Vec2(cx - r * 0.82, cy - r * 0.54), -- 313
			Vec2(cx + r * 0.82, cy + r * 0.34), -- 313
			lw * 1.45, -- 313
			stroke -- 313
		) -- 313
		draw:drawSegment( -- 314
			Vec2(cx - r * 0.76, cy - r * 0.68), -- 314
			Vec2(cx + r * 0.22, cy - r * 0.14), -- 314
			lw * 1, -- 314
			faint -- 314
		) -- 314
		draw:drawSegment( -- 316
			Vec2(cx - r * 0.16, cy - r * 0.2), -- 316
			Vec2(cx - r * 0.26, cy + r * 0.32), -- 316
			lw * 1.15, -- 316
			core -- 316
		) -- 316
		draw:drawSegment( -- 317
			Vec2(cx - r * 0.26, cy + r * 0.32), -- 317
			Vec2(cx + r * 0.16, cy + r * 0.56), -- 317
			lw * 1.15, -- 317
			core -- 317
		) -- 317
		draw:drawSegment( -- 318
			Vec2(cx + r * 0.16, cy + r * 0.56), -- 318
			Vec2(cx + r * 0.38, cy + r * 0.36), -- 318
			lw * 1.05, -- 318
			core -- 318
		) -- 318
		local sx = cx + r * 0.44 -- 320
		local sy = cy + r * 0.34 -- 321
		drawDiamond( -- 322
			draw, -- 322
			sx, -- 322
			sy, -- 322
			r * 0.17, -- 322
			r * 0.17, -- 322
			core -- 322
		) -- 322
		draw:drawSegment( -- 323
			Vec2(sx - r * 0.28, sy), -- 323
			Vec2(sx + r * 0.28, sy), -- 323
			lw * 0.75, -- 323
			core -- 323
		) -- 323
		draw:drawSegment( -- 324
			Vec2(sx, sy - r * 0.28), -- 324
			Vec2(sx, sy + r * 0.28), -- 324
			lw * 0.75, -- 324
			core -- 324
		) -- 324
		draw:drawSegment( -- 326
			Vec2(cx - r * 0.82, cy - r * 0.54), -- 326
			Vec2(cx - r * 0.9, cy - r * 0.76), -- 326
			lw * 1.2, -- 326
			stroke -- 326
		) -- 326
		return -- 327
	end -- 327
	if talentId == "guard" then -- 327
		____exports.drawBrushArc( -- 332
			draw, -- 332
			cx, -- 332
			cy - r * 0.1, -- 332
			r * 0.78, -- 332
			r * 0.62, -- 332
			math.pi * 0.12, -- 332
			math.pi * 0.88, -- 332
			lw * 1.35, -- 332
			stroke, -- 332
			12 -- 332
		) -- 332
		____exports.drawBrushArc( -- 333
			draw, -- 333
			cx, -- 333
			cy - r * 0.26, -- 333
			r * 0.58, -- 333
			r * 0.44, -- 333
			math.pi * 0.16, -- 333
			math.pi * 0.84, -- 333
			lw * 0.95, -- 333
			faint, -- 333
			10 -- 333
		) -- 333
		____exports.drawBrushArc( -- 335
			draw, -- 335
			cx - r * 0.22, -- 335
			cy - r * 0.04, -- 335
			r * 0.62, -- 335
			r * 0.62, -- 335
			math.pi * 0.72, -- 335
			math.pi * 1.32, -- 335
			lw * 1.1, -- 335
			core, -- 335
			10 -- 335
		) -- 335
		____exports.drawBrushArc( -- 336
			draw, -- 336
			cx + r * 0.22, -- 336
			cy - r * 0.04, -- 336
			r * 0.62, -- 336
			r * 0.62, -- 336
			-math.pi * 0.32, -- 336
			math.pi * 0.28, -- 336
			lw * 1.1, -- 336
			core, -- 336
			10 -- 336
		) -- 336
		drawDiamond( -- 338
			draw, -- 338
			cx, -- 338
			cy - r * 0.02, -- 338
			r * 0.22, -- 338
			r * 0.28, -- 338
			fill, -- 338
			lw, -- 338
			core -- 338
		) -- 338
		draw:drawSegment( -- 339
			Vec2(cx, cy - r * 0.36), -- 339
			Vec2(cx, cy - r * 0.76), -- 339
			lw * 0.95, -- 339
			faint -- 339
		) -- 339
		draw:drawDot( -- 340
			Vec2(cx, cy - r * 0.02), -- 340
			math.max(1.3, r * 0.09), -- 340
			core -- 340
		) -- 340
		return -- 341
	end -- 341
	if talentId == "salvage" then -- 341
		draw:drawPolygon( -- 346
			{ -- 346
				Vec2(cx - r * 0.68, cy - r * 0.56), -- 347
				Vec2(cx + r * 0.36, cy - r * 0.56), -- 348
				Vec2(cx + r * 0.14, cy + r * 0.32), -- 349
				Vec2(cx - r * 0.44, cy + r * 0.32) -- 350
			}, -- 350
			fill, -- 351
			lw * 1.1, -- 351
			stroke -- 351
		) -- 351
		draw:drawSegment( -- 353
			Vec2(cx - r * 0.34, cy - r * 0.54), -- 353
			Vec2(cx - r * 0.14, cy + r * 0.3), -- 353
			lw * 0.8, -- 353
			faint -- 353
		) -- 353
		draw:drawSegment( -- 354
			Vec2(cx - r * 0.52, cy - r * 0.14), -- 354
			Vec2(cx + r * 0.24, cy - r * 0.14), -- 354
			lw * 0.75, -- 354
			faint -- 354
		) -- 354
		draw:drawPolygon( -- 356
			{ -- 356
				Vec2(cx - r * 0.42, cy + r * 0.14), -- 357
				Vec2(cx + r * 0.44, cy + r * 0.76), -- 358
				Vec2(cx + r * 0.62, cy + r * 0.58), -- 359
				Vec2(cx - r * 0.18, cy - r * 0.06) -- 360
			}, -- 360
			toColor(coreCol or PALETTE.amberCore, 52 * alpha), -- 361
			lw * 1.05, -- 361
			core -- 361
		) -- 361
		draw:drawSegment( -- 363
			Vec2(cx + r * 0.48, cy + r * 0.64), -- 363
			Vec2(cx + r * 0.8, cy + r * 0.84), -- 363
			lw * 1.65, -- 363
			stroke -- 363
		) -- 363
		draw:drawSegment( -- 365
			Vec2(cx - r * 0.66, cy + r * 0.52), -- 365
			Vec2(cx - r * 0.48, cy + r * 0.64), -- 365
			lw * 0.85, -- 365
			core -- 365
		) -- 365
		draw:drawSegment( -- 366
			Vec2(cx - r * 0.76, cy + r * 0.26), -- 366
			Vec2(cx - r * 0.6, cy + r * 0.34), -- 366
			lw * 0.75, -- 366
			faint -- 366
		) -- 366
		return -- 367
	end -- 367
	draw:drawPolygon( -- 371
		{ -- 371
			Vec2(cx - r * 0.34, cy + r * 0.76), -- 372
			Vec2(cx + r * 0.34, cy + r * 0.76), -- 373
			Vec2(cx + r * 0.34, cy - r * 0.46), -- 374
			Vec2(cx, cy - r * 0.84), -- 375
			Vec2(cx - r * 0.34, cy - r * 0.46) -- 376
		}, -- 376
		fill, -- 377
		lw * 1.1, -- 377
		stroke -- 377
	) -- 377
	draw:drawCircle( -- 378
		Vec2(cx, cy + r * 0.5), -- 378
		r * 0.11, -- 378
		toColor(PALETTE.panelBgDeep, 220 * alpha) -- 378
	) -- 378
	draw:drawRing( -- 379
		Vec2(cx, cy + r * 0.5), -- 379
		r * 0.08, -- 379
		r * 0.14, -- 379
		Color(0, 0, 0, 0), -- 379
		lw * 0.8, -- 379
		core -- 379
	) -- 379
	draw:drawSegment( -- 380
		Vec2(cx - r * 0.22, cy + r * 0.14), -- 380
		Vec2(cx + r * 0.22, cy + r * 0.14), -- 380
		lw * 0.9, -- 380
		core -- 380
	) -- 380
	draw:drawSegment( -- 381
		Vec2(cx - r * 0.22, cy - r * 0.12), -- 381
		Vec2(cx + r * 0.22, cy - r * 0.12), -- 381
		lw * 0.9, -- 381
		faint -- 381
	) -- 381
	draw:drawSegment( -- 382
		Vec2(cx - r * 0.16, cy - r * 0.36), -- 382
		Vec2(cx + r * 0.16, cy - r * 0.36), -- 382
		lw * 0.8, -- 382
		faint -- 382
	) -- 382
end -- 270
--- 绘制明初器物级战备/掉落物纹样（HUD 行囊条与 2.5D 世界掉落物 100% 同源）：
-- 8 类物资轮廓完全互异，取代原 props.ts 的「万物皆指南针」。
function ____exports.drawPickupGlyph(draw, cx, cy, radius, kind, alpha, overrideCol) -- 389
	if alpha == nil then -- 389
		alpha = 1 -- 395
	end -- 395
	local meta = ____exports.pickupMetaOf(kind) -- 398
	local col = overrideCol or meta.accent -- 399
	local core = overrideCol or meta.accentCore -- 400
	local r = math.max(4.5, radius) -- 401
	local lw = math.max(0.95, r * 0.12) -- 402
	local stroke = toColor(col, 240 * alpha) -- 403
	local hi = toColor(core, 248 * alpha) -- 404
	local fill = toColor(col, 68 * alpha) -- 405
	local darkFill = Color( -- 406
		20, -- 406
		18, -- 406
		22, -- 406
		math.floor(185 * alpha + 0.5) -- 406
	) -- 406
	if kind == "wood" then -- 406
		draw:drawPolygon( -- 410
			{ -- 410
				Vec2(cx - r * 0.36, cy + r * 0.82), -- 411
				Vec2(cx + r * 0.36, cy + r * 0.82), -- 412
				Vec2(cx + r * 0.36, cy - r * 0.64), -- 413
				Vec2(cx, cy - r * 0.9), -- 414
				Vec2(cx - r * 0.36, cy - r * 0.64) -- 415
			}, -- 415
			fill, -- 416
			lw * 1.1, -- 416
			hi -- 416
		) -- 416
		draw:drawDot( -- 417
			Vec2(cx, cy + r * 0.54), -- 417
			math.max(1.2, r * 0.12), -- 417
			darkFill -- 417
		) -- 417
		draw:drawSegment( -- 418
			Vec2(cx - r * 0.22, cy + r * 0.16), -- 418
			Vec2(cx + r * 0.22, cy + r * 0.16), -- 418
			lw * 0.9, -- 418
			hi -- 418
		) -- 418
		draw:drawSegment( -- 419
			Vec2(cx - r * 0.22, cy - r * 0.14), -- 419
			Vec2(cx + r * 0.22, cy - r * 0.14), -- 419
			lw * 0.9, -- 419
			stroke -- 419
		) -- 419
		draw:drawSegment( -- 420
			Vec2(cx - r * 0.14, cy - r * 0.42), -- 420
			Vec2(cx + r * 0.14, cy - r * 0.42), -- 420
			lw * 0.8, -- 420
			stroke -- 420
		) -- 420
		return -- 421
	end -- 421
	if kind == "bell" then -- 421
		drawReloadPatternGlyph( -- 426
			draw, -- 426
			cx, -- 426
			cy, -- 426
			r * 1.05, -- 426
			"echo", -- 426
			core, -- 426
			alpha -- 426
		) -- 426
		return -- 427
	end -- 427
	if kind == "shield" then -- 427
		draw:drawPolygon( -- 432
			{ -- 432
				Vec2(cx - r * 0.64, cy + r * 0.72), -- 433
				Vec2(cx + r * 0.64, cy + r * 0.72), -- 434
				Vec2(cx + r * 0.58, cy - r * 0.36), -- 435
				Vec2(cx, cy - r * 0.82), -- 436
				Vec2(cx - r * 0.58, cy - r * 0.36) -- 437
			}, -- 437
			fill, -- 438
			lw * 1.15, -- 438
			hi -- 438
		) -- 438
		draw:drawCircle( -- 439
			Vec2(cx, cy + r * 0.08), -- 439
			r * 0.2, -- 439
			hi -- 439
		) -- 439
		draw:drawSegment( -- 440
			Vec2(cx - r * 0.54, cy + r * 0.44), -- 440
			Vec2(cx - r * 0.2, cy + r * 0.22), -- 440
			lw * 0.8, -- 440
			darkFill -- 440
		) -- 440
		return -- 441
	end -- 441
	if kind == "wedge" then -- 441
		draw:drawPolygon( -- 446
			{ -- 446
				Vec2(cx - r * 0.78, cy - r * 0.46), -- 447
				Vec2(cx + r * 0.78, cy - r * 0.46), -- 448
				Vec2(cx + r * 0.44, cy + r * 0.52), -- 449
				Vec2(cx - r * 0.24, cy + r * 0.52) -- 450
			}, -- 450
			fill, -- 451
			lw * 1.15, -- 451
			hi -- 451
		) -- 451
		draw:drawSegment( -- 452
			Vec2(cx - r * 0.24, cy + r * 0.52), -- 452
			Vec2(cx - r * 0.12, cy - r * 0.46), -- 452
			lw * 0.9, -- 452
			hi -- 452
		) -- 452
		draw:drawSegment( -- 453
			Vec2(cx + r * 0.16, cy + r * 0.1), -- 453
			Vec2(cx + r * 0.46, cy + r * 0.1), -- 453
			lw * 0.75, -- 453
			stroke -- 453
		) -- 453
		return -- 454
	end -- 454
	if kind == "ammo" then -- 454
		draw:drawPolygon( -- 459
			{ -- 459
				Vec2(cx - r * 0.28, cy + r * 0.42), -- 460
				Vec2(cx + r * 0.28, cy + r * 0.42), -- 461
				Vec2(cx + r * 0.66, cy - r * 0.24), -- 462
				Vec2(cx + r * 0.44, cy - r * 0.76), -- 463
				Vec2(cx - r * 0.44, cy - r * 0.76), -- 464
				Vec2(cx - r * 0.66, cy - r * 0.24) -- 465
			}, -- 465
			fill, -- 466
			lw * 1.1, -- 466
			hi -- 466
		) -- 466
		draw:drawSegment( -- 468
			Vec2(cx - r * 0.38, cy + r * 0.4), -- 468
			Vec2(cx + r * 0.38, cy + r * 0.4), -- 468
			lw * 1.25, -- 468
			hi -- 468
		) -- 468
		draw:drawSegment( -- 469
			Vec2(cx - r * 0.22, cy + r * 0.42), -- 469
			Vec2(cx - r * 0.36, cy + r * 0.78), -- 469
			lw, -- 469
			stroke -- 469
		) -- 469
		draw:drawSegment( -- 470
			Vec2(cx + r * 0.22, cy + r * 0.42), -- 470
			Vec2(cx + r * 0.36, cy + r * 0.78), -- 470
			lw, -- 470
			stroke -- 470
		) -- 470
		draw:drawDot( -- 471
			Vec2(cx, cy - r * 0.22), -- 471
			math.max(1.4, r * 0.18), -- 471
			hi -- 471
		) -- 471
		return -- 472
	end -- 472
	if kind == "scrap" then -- 472
		draw:drawSegment( -- 477
			Vec2(cx - r * 0.74, cy - r * 0.48), -- 477
			Vec2(cx + r * 0.74, cy + r * 0.48), -- 477
			lw * 2.1, -- 477
			stroke -- 477
		) -- 477
		draw:drawSegment( -- 478
			Vec2(cx - r * 0.74, cy - r * 0.48), -- 478
			Vec2(cx + r * 0.74, cy + r * 0.48), -- 478
			lw * 0.9, -- 478
			hi -- 478
		) -- 478
		draw:drawSegment( -- 479
			Vec2(cx - r * 0.64, cy + r * 0.52), -- 479
			Vec2(cx + r * 0.64, cy - r * 0.52), -- 479
			lw * 2, -- 479
			stroke -- 479
		) -- 479
		draw:drawSegment( -- 480
			Vec2(cx - r * 0.64, cy + r * 0.52), -- 480
			Vec2(cx + r * 0.64, cy - r * 0.52), -- 480
			lw * 0.85, -- 480
			hi -- 480
		) -- 480
		return -- 481
	end -- 481
	if kind == "pass" then -- 481
		draw:drawPolygon( -- 486
			{ -- 486
				Vec2(cx - r * 0.46, cy + r * 0.42), -- 487
				Vec2(cx, cy + r * 0.82), -- 488
				Vec2(cx + r * 0.46, cy + r * 0.42), -- 489
				Vec2(cx + r * 0.46, cy - r * 0.46), -- 490
				Vec2(cx - r * 0.46, cy - r * 0.46) -- 491
			}, -- 491
			fill, -- 492
			lw * 1.1, -- 492
			hi -- 492
		) -- 492
		draw:drawSegment( -- 493
			Vec2(cx, cy - r * 0.46), -- 493
			Vec2(cx, cy - r * 0.88), -- 493
			lw, -- 493
			hi -- 493
		) -- 493
		draw:drawSegment( -- 494
			Vec2(cx - r * 0.16, cy - r * 0.66), -- 494
			Vec2(cx - r * 0.22, cy - r * 0.88), -- 494
			lw * 0.75, -- 494
			stroke -- 494
		) -- 494
		draw:drawSegment( -- 495
			Vec2(cx + r * 0.16, cy - r * 0.66), -- 495
			Vec2(cx + r * 0.22, cy - r * 0.88), -- 495
			lw * 0.75, -- 495
			stroke -- 495
		) -- 495
		drawDiamond( -- 496
			draw, -- 496
			cx, -- 496
			cy + r * 0.04, -- 496
			r * 0.16, -- 496
			r * 0.22, -- 496
			hi -- 496
		) -- 496
		return -- 497
	end -- 497
	if kind == "quickbelt" then -- 497
		draw:drawSegment( -- 502
			Vec2(cx - r * 0.78, cy - r * 0.66), -- 502
			Vec2(cx + r * 0.78, cy + r * 0.66), -- 502
			lw * 1.5, -- 502
			stroke -- 502
		) -- 502
		local k = -1 -- 503
		do -- 503
			k = -1 -- 504
			while k <= 1 do -- 504
				local tx = cx + k * r * 0.36 -- 505
				local ty = cy + k * r * 0.3 -- 506
				draw:drawRect( -- 507
					Rect(tx - r * 0.14, ty - r * 0.24, r * 0.28, r * 0.48), -- 507
					fill, -- 507
					lw * 0.9, -- 507
					hi -- 507
				) -- 507
				k = k + 1 -- 504
			end -- 504
		end -- 504
		return -- 509
	end -- 509
	drawDiamond( -- 512
		draw, -- 512
		cx, -- 512
		cy, -- 512
		r * 0.56, -- 512
		r * 0.56, -- 512
		fill, -- 512
		lw, -- 512
		hi -- 512
	) -- 512
end -- 389
--- 在 2.5D 世界舞台上绘制具有接触影、轻浮呼吸与明初轮廓的地面掉落物（供 props.ts 调用）。
function ____exports.drawWorldPickupVisual(fgDraw, fgGlow, cx, groundY, scalePx, kind, time, seedPhase) -- 518
	local meta = ____exports.pickupMetaOf(kind) -- 528
	local bob = math.sin(time * 2.8 + seedPhase) * 2.1 -- 529
	local iconY = groundY + scalePx * 0.88 + bob -- 530
	local r = math.max(6.5, scalePx * 0.62) -- 531
	local shScale = 1 - bob * 0.025 -- 534
	fgDraw:drawEllipse( -- 535
		Vec2(cx, groundY + 1.5), -- 535
		r * 0.95 * shScale, -- 535
		math.max(2.2, r * 0.3 * shScale), -- 535
		Color(6, 8, 12, 155) -- 535
	) -- 535
	local isBenchMat = kind == "wood" or kind == "bell" -- 538
	local glowA = isBenchMat and 36 + math.sin(time * 3.6 + seedPhase) * 10 or 22 -- 539
	fillRadialGlow( -- 540
		fgGlow, -- 541
		cx, -- 542
		iconY, -- 543
		r * (isBenchMat and 2.1 or 1.65), -- 544
		r * (isBenchMat and 2.1 or 1.65), -- 545
		toColor(meta.accentCore, glowA), -- 546
		Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 547
		12 -- 548
	) -- 548
	fgDraw:drawCircle( -- 552
		Vec2(cx, iconY), -- 552
		r * 1.06, -- 552
		Color(10, 12, 18, 150) -- 552
	) -- 552
	fgDraw:drawRing( -- 553
		Vec2(cx, iconY), -- 553
		r * 1.02, -- 553
		r * 1.14, -- 553
		Color(0, 0, 0, 0), -- 553
		0.9, -- 553
		toColor(meta.accent, isBenchMat and 175 or 120) -- 553
	) -- 553
	____exports.drawPickupGlyph( -- 555
		fgDraw, -- 555
		cx, -- 555
		iconY, -- 555
		r * 0.84, -- 555
		kind, -- 555
		0.98 -- 555
	) -- 555
end -- 518
return ____exports -- 518