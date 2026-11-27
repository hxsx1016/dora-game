-- [ts]: talent_catalog.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 18
local Color = ____Dora.Color -- 18
local Rect = ____Dora.Rect -- 18
local Vec2 = ____Dora.Vec2 -- 18
local ____run = require("Script.watch.run") -- 19
local talentNames = ____run.talentNames -- 19
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 21
local drawReloadPatternGlyph = ____reload_wheel.drawReloadPatternGlyph -- 21
local ____theme = require("Script.watch.fe.theme") -- 22
local PALETTE = ____theme.PALETTE -- 23
local drawDiamond = ____theme.drawDiamond -- 25
local fillRadialGlow = ____theme.fillRadialGlow -- 26
local toColor = ____theme.toColor -- 27
local RANK_NUMERALS = { -- 71
	"零", -- 71
	"壹", -- 71
	"贰", -- 71
	"叁", -- 71
	"肆", -- 71
	"伍", -- 71
	"陆", -- 71
	"柒", -- 71
	"捌", -- 71
	"玖", -- 71
	"拾" -- 71
} -- 71
--- 将本领阶位转为传统中文大写（全覆盖正文字库，无缺失罗马数字）。
function ____exports.rankChinese(rank) -- 74
	local r = math.max( -- 75
		0, -- 75
		math.floor(rank) -- 75
	) -- 75
	if r < #RANK_NUMERALS then -- 76
		return RANK_NUMERALS[r + 1] -- 77
	end -- 77
	return "" .. tostring(r) -- 79
end -- 74
local TALENT_REGISTRY = {} -- 82
--- 注册或扩展自定义本领视觉定义（表驱动，方便后续并行扩展新本领）。
function ____exports.registerTalentVisual(meta) -- 85
	TALENT_REGISTRY[meta.id] = meta -- 86
end -- 85
____exports.registerTalentVisual({ -- 89
	id = "vitality", -- 90
	title = "厚甲", -- 91
	category = "固守", -- 92
	accent = PALETTE.cyan, -- 93
	accentCore = PALETTE.moonPale, -- 94
	whisper = "「再重些，背上的人便稳些。」", -- 95
	absorbTarget = "hp", -- 96
	shortEffect = function(____, snap) return (("体力上限 " .. tostring(snap.maxHp)) .. " → ") .. tostring(snap.maxHp + 1) end, -- 97
	subEffect = function() return "并即刻回气 +1" end, -- 98
	ledgerLine = function(____, snap, rank) return ((((("体力上限 +" .. tostring(rank)) .. "（现 ") .. tostring(snap.hp)) .. "/") .. tostring(snap.maxHp)) .. "）" end -- 99
}) -- 99
____exports.registerTalentVisual({ -- 102
	id = "reload", -- 103
	title = "熟铳", -- 104
	category = "火器", -- 105
	accent = PALETTE.amber, -- 106
	accentCore = PALETTE.amberCore, -- 107
	whisper = "「火绳趁手，莫叫她久等。」", -- 108
	absorbTarget = "gun", -- 109
	shortEffect = function(____, snap) -- 110
		local next = math.max(6, snap.reloadTicksNow - 6) -- 111
		return ((("装填 " .. tostring(snap.reloadTicksNow)) .. " → ") .. tostring(next)) .. " 拍" -- 112
	end, -- 110
	subEffect = function() return "更快复位鸟铳 (-6 拍)" end, -- 114
	ledgerLine = function(____, snap, rank) return ((("装填耗时 " .. tostring(snap.reloadTicksNow)) .. " 拍（减 ") .. tostring(rank * 6)) .. " 拍）" end -- 115
}) -- 115
____exports.registerTalentVisual({ -- 118
	id = "guard", -- 119
	title = "护身", -- 120
	category = "身法", -- 121
	accent = PALETTE.emerald, -- 122
	accentCore = PALETTE.moonPale, -- 123
	whisper = "「挨了这一记，步子不能乱。」", -- 124
	absorbTarget = "shoulder", -- 125
	shortEffect = function(____, snap) return ((("护身 " .. tostring(snap.invulnTicksNow)) .. " → ") .. tostring(snap.invulnTicksNow + 12)) .. " 拍" end, -- 126
	subEffect = function() return "受击多得喘息窗 (+12 拍)" end, -- 127
	ledgerLine = function(____, snap, rank) return ((("受击保护 " .. tostring(snap.invulnTicksNow)) .. " 拍（加 ") .. tostring(rank * 12)) .. " 拍）" end -- 128
}) -- 128
____exports.registerTalentVisual({ -- 131
	id = "craft", -- 132
	title = "巧手", -- 133
	category = "机巧", -- 134
	accent = PALETTE.amber, -- 135
	accentCore = PALETTE.amberCore, -- 136
	whisper = "「爹教的楔法，倒派上用场。」", -- 137
	absorbTarget = "satchel", -- 138
	shortEffect = function(____, snap) -- 139
		local next = math.max(6, snap.craftTicksNow - 6) -- 140
		return ((("制楔 " .. tostring(snap.craftTicksNow)) .. " → ") .. tostring(next)) .. " 拍" -- 141
	end, -- 139
	subEffect = function() return "顺手减装填 3 拍" end, -- 143
	ledgerLine = function(____, snap, rank) return ((("制楔 " .. tostring(snap.craftTicksNow)) .. " 拍 · 装填另减 ") .. tostring(rank * 3)) .. " 拍" end -- 144
}) -- 144
--- 解析任意本领 ID 的视觉元数据；未知未来 ID 自动回退至明代军筹通用模板。
function ____exports.resolveTalentVisual(id, snap) -- 148
	local reg = TALENT_REGISTRY[id] -- 149
	if reg ~= nil then -- 150
		return reg -- 151
	end -- 151
	local hint = snap ~= nil and snap.talentLabelHints[id] or nil or talentNames[id] or id -- 153
	local dotIdx = (string.find(hint, "·", nil, true) or 0) - 1 -- 156
	local parsedTitle = dotIdx > 0 and __TS__StringSlice(hint, 0, dotIdx) or hint -- 157
	local parsedDesc = dotIdx > 0 and __TS__StringSlice(hint, dotIdx + 1) or "行军备策 · 增益一阶" -- 158
	return { -- 159
		id = id, -- 160
		title = parsedTitle ~= "" and parsedTitle or "军筹", -- 161
		category = "军筹", -- 162
		accent = PALETTE.jadeMist, -- 163
		accentCore = PALETTE.textBright, -- 164
		whisper = "「夜路漫漫，多备一筹总安心。」", -- 165
		absorbTarget = "crest", -- 166
		shortEffect = function() return parsedDesc end, -- 167
		subEffect = function(____, _s, curRank) return ((("现 " .. ____exports.rankChinese(curRank)) .. " → ") .. ____exports.rankChinese(curRank + 1)) .. " 阶" end, -- 168
		ledgerLine = function(____, _s, rank) return ((parsedDesc .. "（") .. ____exports.rankChinese(rank)) .. " 阶）" end -- 169
	} -- 169
end -- 148
local WEAPON_META = {standard_gun = { -- 173
	id = "standard_gun", -- 175
	name = "标准鸟铳", -- 176
	shortName = "鸟铳", -- 177
	effect = "normal", -- 178
	accent = PALETTE.silkLine, -- 179
	desc = "九宫连线蓄推退、铃纹、灯纹" -- 180
}, guide_lantern_gun = { -- 182
	id = "guide_lantern_gun", -- 183
	name = "引路灯铳", -- 184
	shortName = "灯铳", -- 185
	effect = "light", -- 186
	accent = PALETTE.amberCore, -- 187
	desc = "强化灯纹破夜光晕镇敌" -- 188
}, echo_gun = { -- 190
	id = "echo_gun", -- 191
	name = "回声铜铃铳", -- 192
	shortName = "回声铳", -- 193
	effect = "echo", -- 194
	accent = PALETTE.cyanCore, -- 195
	desc = "强化铃纹双响回声诱敌" -- 196
}, time_shuttler = { -- 198
	id = "time_shuttler", -- 199
	name = "时间穿梭器", -- 200
	shortName = "穿梭器", -- 201
	effect = "knockback", -- 202
	accent = PALETTE.amberCore, -- 203
	desc = "双线归档旧物，冷白残影" -- 204
}} -- 204
function ____exports.weaponMetaOf(weaponId) -- 208
	return WEAPON_META[weaponId] or WEAPON_META.standard_gun -- 209
end -- 208
____exports.PICKUP_ORDER = { -- 212
	"wood", -- 213
	"bell", -- 214
	"shield", -- 215
	"wedge", -- 216
	"ammo", -- 217
	"scrap", -- 218
	"pass", -- 219
	"quickbelt" -- 220
} -- 220
local PICKUP_META = { -- 223
	wood = { -- 224
		kind = "wood", -- 224
		name = "木纹筹", -- 224
		shortName = "木筹", -- 224
		accent = PALETTE.amber, -- 224
		accentCore = PALETTE.amberCore, -- 224
		category = "material" -- 224
	}, -- 224
	bell = { -- 225
		kind = "bell", -- 225
		name = "铃纹筹", -- 225
		shortName = "铃筹", -- 225
		accent = PALETTE.amberCore, -- 225
		accentCore = PALETTE.amberCore, -- 225
		category = "material" -- 225
	}, -- 225
	shield = { -- 226
		kind = "shield", -- 226
		name = "残盾", -- 226
		shortName = "残盾", -- 226
		accent = PALETTE.cyan, -- 226
		accentCore = PALETTE.cyanCore, -- 226
		category = "gear" -- 226
	}, -- 226
	wedge = { -- 227
		kind = "wedge", -- 227
		name = "木楔", -- 227
		shortName = "木楔", -- 227
		accent = PALETTE.emerald, -- 227
		accentCore = PALETTE.moonPale, -- 227
		category = "gear" -- 227
	}, -- 227
	ammo = { -- 228
		kind = "ammo", -- 228
		name = "备用弹包", -- 228
		shortName = "弹包", -- 228
		accent = PALETTE.rouge, -- 228
		accentCore = PALETTE.crimsonCore, -- 228
		category = "gear" -- 228
	}, -- 228
	scrap = { -- 229
		kind = "scrap", -- 229
		name = "废木料", -- 229
		shortName = "木料", -- 229
		accent = PALETTE.amberDim, -- 229
		accentCore = PALETTE.amber, -- 229
		category = "material" -- 229
	}, -- 229
	pass = { -- 230
		kind = "pass", -- 230
		name = "护送号牌", -- 230
		shortName = "号牌", -- 230
		accent = PALETTE.jadeMist, -- 230
		accentCore = PALETTE.textBright, -- 230
		category = "gear" -- 230
	}, -- 230
	quickbelt = { -- 231
		kind = "quickbelt", -- 231
		name = "快装带", -- 231
		shortName = "装带", -- 231
		accent = PALETTE.amber, -- 231
		accentCore = PALETTE.amberCore, -- 231
		category = "gear" -- 231
	} -- 231
} -- 231
function ____exports.pickupMetaOf(kind) -- 234
	return PICKUP_META[kind] or ({ -- 235
		kind = kind, -- 236
		name = kind, -- 237
		shortName = kind, -- 238
		accent = PALETTE.silkLine, -- 239
		accentCore = PALETTE.textBright, -- 240
		category = "gear" -- 241
	}) -- 241
end -- 234
--- 按当前已习本领、所持火铳与战备派生纯前端「行军雅号」（零后端侵入）。
function ____exports.deriveMarchTitle(snap) -- 246
	local vit = snap.ranks.vitality or 0 -- 247
	local rel = snap.ranks.reload or 0 -- 248
	local grd = snap.ranks.guard or 0 -- 249
	local crf = snap.ranks.craft or 0 -- 250
	local total = snap.totalRanks -- 251
	local weapon = snap.equippedWeapon -- 252
	local wedge = snap.supplies.wedge or 0 -- 253
	if total <= 0 then -- 255
		return { -- 256
			title = "初启北行", -- 256
			sealTop = "守", -- 256
			sealBot = "望", -- 256
			subtitle = "行囊初整，孤灯在前", -- 256
			accent = PALETTE.silkLine -- 256
		} -- 256
	end -- 256
	if rel >= 2 and weapon == "guide_lantern_gun" then -- 258
		return { -- 259
			title = "明火疾铳", -- 259
			sealTop = "明", -- 259
			sealBot = "火", -- 259
			subtitle = "灯影破夜，火绳如电", -- 259
			accent = PALETTE.amberCore -- 259
		} -- 259
	end -- 259
	if rel >= 2 and weapon == "echo_gun" then -- 261
		return { -- 262
			title = "惊铃连响", -- 262
			sealTop = "惊", -- 262
			sealBot = "铃", -- 262
			subtitle = "铜铃惑敌，连发不断", -- 262
			accent = PALETTE.cyanCore -- 262
		} -- 262
	end -- 262
	if vit + grd >= 3 and vit >= 1 and grd >= 1 then -- 264
		return { -- 265
			title = "铁壁断后", -- 265
			sealTop = "铁", -- 265
			sealBot = "壁", -- 265
			subtitle = "重甲护身，步履不乱", -- 265
			accent = PALETTE.cyan -- 265
		} -- 265
	end -- 265
	if crf >= 2 or crf >= 1 and wedge >= 1 then -- 267
		return { -- 268
			title = "巧楔筑垒", -- 268
			sealTop = "巧", -- 268
			sealBot = "楔", -- 268
			subtitle = "削木固掩，以巧破险", -- 268
			accent = PALETTE.emerald -- 268
		} -- 268
	end -- 268
	if rel >= 2 then -- 270
		return { -- 271
			title = "疾火连铳", -- 271
			sealTop = "疾", -- 271
			sealBot = "铳", -- 271
			subtitle = "熟手快装，火线不绝", -- 271
			accent = PALETTE.amber -- 271
		} -- 271
	end -- 271
	if vit >= 2 then -- 273
		return { -- 274
			title = "重甲负行", -- 274
			sealTop = "重", -- 274
			sealBot = "甲", -- 274
			subtitle = "铁衣加身，稳背同行", -- 274
			accent = PALETTE.cyan -- 274
		} -- 274
	end -- 274
	if grd >= 2 then -- 276
		return { -- 277
			title = "稳步护势", -- 277
			sealTop = "护", -- 277
			sealBot = "身", -- 277
			subtitle = "身法从容，危中留隙", -- 277
			accent = PALETTE.emerald -- 277
		} -- 277
	end -- 277
	return { -- 279
		title = "孤城守望", -- 279
		sealTop = "守", -- 279
		sealBot = "望", -- 279
		subtitle = "诸筹兼备，护她北归", -- 279
		accent = PALETTE.rouge -- 279
	} -- 279
end -- 246
--- 内部工具：用短折线绘制清秀明式弧线（兼容所有缩放与灰度）。
function ____exports.drawBrushArc(draw, cx, cy, rx, ry, startRad, endRad, thickness, color, segments) -- 283
	if segments == nil then -- 293
		segments = 14 -- 293
	end -- 293
	local n = math.max(4, segments) -- 295
	local prevX = cx + math.cos(startRad) * rx -- 296
	local prevY = cy + math.sin(startRad) * ry -- 297
	local i = 1 -- 298
	do -- 298
		i = 1 -- 299
		while i <= n do -- 299
			local a = startRad + (endRad - startRad) * i / n -- 300
			local nx = cx + math.cos(a) * rx -- 301
			local ny = cy + math.sin(a) * ry -- 302
			draw:drawSegment( -- 303
				Vec2(prevX, prevY), -- 303
				Vec2(nx, ny), -- 303
				thickness, -- 303
				color -- 303
			) -- 303
			prevX = nx -- 304
			prevY = ny -- 305
			i = i + 1 -- 299
		end -- 299
	end -- 299
end -- 283
--- 绘制明初器物工笔本领纹样（纯 DrawNode 矢量，静音与灰度下轮廓 100% 互异）：
-- - vitality：明式叠鳞札甲 + 居中圆形护心镜
-- - reload：明式鸟铳龙头火绳弯钩 + 药池微星
-- - guard：明式云肩披膊 + 双向卸力偏锋弧
-- - craft：削木短刀 + 梯形木楔契口
-- - fallback：明代卫所竖式军筹木简
function ____exports.drawTalentGlyph(draw, cx, cy, radius, talentId, col, alpha, coreCol) -- 317
	if alpha == nil then -- 324
		alpha = 1 -- 324
	end -- 324
	local r = math.max(5, radius) -- 327
	local lw = math.max(1, r * 0.085) -- 328
	local stroke = toColor(col, 240 * alpha) -- 329
	local core = toColor(coreCol or PALETTE.textBright, 245 * alpha) -- 330
	local faint = toColor(col, 125 * alpha) -- 331
	local fill = toColor(col, 38 * alpha) -- 332
	if talentId == "vitality" then -- 334
		draw:drawPolygon( -- 336
			{ -- 336
				Vec2(cx - r * 0.72, cy + r * 0.66), -- 337
				Vec2(cx - r * 0.28, cy + r * 0.82), -- 338
				Vec2(cx + r * 0.28, cy + r * 0.82), -- 339
				Vec2(cx + r * 0.72, cy + r * 0.66), -- 340
				Vec2(cx + r * 0.64, cy - r * 0.26), -- 341
				Vec2(cx, cy - r * 0.84), -- 342
				Vec2(cx - r * 0.64, cy - r * 0.26) -- 343
			}, -- 343
			fill, -- 344
			lw * 1.1, -- 344
			stroke -- 344
		) -- 344
		draw:drawSegment( -- 346
			Vec2(cx - r * 0.62, cy + r * 0.22), -- 346
			Vec2(cx + r * 0.62, cy + r * 0.22), -- 346
			lw * 0.8, -- 346
			faint -- 346
		) -- 346
		draw:drawSegment( -- 347
			Vec2(cx - r * 0.56, cy - r * 0.24), -- 347
			Vec2(cx + r * 0.56, cy - r * 0.24), -- 347
			lw * 0.8, -- 347
			faint -- 347
		) -- 347
		draw:drawSegment( -- 349
			Vec2(cx - r * 0.3, cy - r * 0.52), -- 349
			Vec2(cx - r * 0.34, cy + r * 0.68), -- 349
			lw * 0.7, -- 349
			faint -- 349
		) -- 349
		draw:drawSegment( -- 350
			Vec2(cx + r * 0.3, cy - r * 0.52), -- 350
			Vec2(cx + r * 0.34, cy + r * 0.68), -- 350
			lw * 0.7, -- 350
			faint -- 350
		) -- 350
		draw:drawCircle( -- 352
			Vec2(cx, cy + r * 0.04), -- 352
			r * 0.32, -- 352
			toColor(PALETTE.panelBgDeep, 210 * alpha) -- 352
		) -- 352
		draw:drawRing( -- 353
			Vec2(cx, cy + r * 0.04), -- 353
			r * 0.26, -- 353
			r * 0.34, -- 353
			Color(0, 0, 0, 0), -- 353
			lw, -- 353
			core -- 353
		) -- 353
		draw:drawDot( -- 354
			Vec2(cx, cy + r * 0.04), -- 354
			math.max(1.4, r * 0.11), -- 354
			core -- 354
		) -- 354
		return -- 355
	end -- 355
	if talentId == "reload" then -- 358
		draw:drawSegment( -- 360
			Vec2(cx - r * 0.82, cy - r * 0.54), -- 360
			Vec2(cx + r * 0.82, cy + r * 0.34), -- 360
			lw * 1.45, -- 360
			stroke -- 360
		) -- 360
		draw:drawSegment( -- 361
			Vec2(cx - r * 0.76, cy - r * 0.68), -- 361
			Vec2(cx + r * 0.22, cy - r * 0.14), -- 361
			lw * 1, -- 361
			faint -- 361
		) -- 361
		draw:drawSegment( -- 363
			Vec2(cx - r * 0.16, cy - r * 0.2), -- 363
			Vec2(cx - r * 0.26, cy + r * 0.32), -- 363
			lw * 1.15, -- 363
			core -- 363
		) -- 363
		draw:drawSegment( -- 364
			Vec2(cx - r * 0.26, cy + r * 0.32), -- 364
			Vec2(cx + r * 0.16, cy + r * 0.56), -- 364
			lw * 1.15, -- 364
			core -- 364
		) -- 364
		draw:drawSegment( -- 365
			Vec2(cx + r * 0.16, cy + r * 0.56), -- 365
			Vec2(cx + r * 0.38, cy + r * 0.36), -- 365
			lw * 1.05, -- 365
			core -- 365
		) -- 365
		local sx = cx + r * 0.44 -- 367
		local sy = cy + r * 0.34 -- 368
		drawDiamond( -- 369
			draw, -- 369
			sx, -- 369
			sy, -- 369
			r * 0.17, -- 369
			r * 0.17, -- 369
			core -- 369
		) -- 369
		draw:drawSegment( -- 370
			Vec2(sx - r * 0.28, sy), -- 370
			Vec2(sx + r * 0.28, sy), -- 370
			lw * 0.75, -- 370
			core -- 370
		) -- 370
		draw:drawSegment( -- 371
			Vec2(sx, sy - r * 0.28), -- 371
			Vec2(sx, sy + r * 0.28), -- 371
			lw * 0.75, -- 371
			core -- 371
		) -- 371
		draw:drawSegment( -- 373
			Vec2(cx - r * 0.82, cy - r * 0.54), -- 373
			Vec2(cx - r * 0.9, cy - r * 0.76), -- 373
			lw * 1.2, -- 373
			stroke -- 373
		) -- 373
		return -- 374
	end -- 374
	if talentId == "guard" then -- 377
		____exports.drawBrushArc( -- 379
			draw, -- 379
			cx, -- 379
			cy - r * 0.1, -- 379
			r * 0.78, -- 379
			r * 0.62, -- 379
			math.pi * 0.12, -- 379
			math.pi * 0.88, -- 379
			lw * 1.35, -- 379
			stroke, -- 379
			12 -- 379
		) -- 379
		____exports.drawBrushArc( -- 380
			draw, -- 380
			cx, -- 380
			cy - r * 0.26, -- 380
			r * 0.58, -- 380
			r * 0.44, -- 380
			math.pi * 0.16, -- 380
			math.pi * 0.84, -- 380
			lw * 0.95, -- 380
			faint, -- 380
			10 -- 380
		) -- 380
		____exports.drawBrushArc( -- 382
			draw, -- 382
			cx - r * 0.22, -- 382
			cy - r * 0.04, -- 382
			r * 0.62, -- 382
			r * 0.62, -- 382
			math.pi * 0.72, -- 382
			math.pi * 1.32, -- 382
			lw * 1.1, -- 382
			core, -- 382
			10 -- 382
		) -- 382
		____exports.drawBrushArc( -- 383
			draw, -- 383
			cx + r * 0.22, -- 383
			cy - r * 0.04, -- 383
			r * 0.62, -- 383
			r * 0.62, -- 383
			-math.pi * 0.32, -- 383
			math.pi * 0.28, -- 383
			lw * 1.1, -- 383
			core, -- 383
			10 -- 383
		) -- 383
		drawDiamond( -- 385
			draw, -- 385
			cx, -- 385
			cy - r * 0.02, -- 385
			r * 0.22, -- 385
			r * 0.28, -- 385
			fill, -- 385
			lw, -- 385
			core -- 385
		) -- 385
		draw:drawSegment( -- 386
			Vec2(cx, cy - r * 0.36), -- 386
			Vec2(cx, cy - r * 0.76), -- 386
			lw * 0.95, -- 386
			faint -- 386
		) -- 386
		draw:drawDot( -- 387
			Vec2(cx, cy - r * 0.02), -- 387
			math.max(1.3, r * 0.09), -- 387
			core -- 387
		) -- 387
		return -- 388
	end -- 388
	if talentId == "craft" then -- 391
		draw:drawPolygon( -- 393
			{ -- 393
				Vec2(cx - r * 0.68, cy - r * 0.56), -- 394
				Vec2(cx + r * 0.36, cy - r * 0.56), -- 395
				Vec2(cx + r * 0.14, cy + r * 0.32), -- 396
				Vec2(cx - r * 0.44, cy + r * 0.32) -- 397
			}, -- 397
			fill, -- 398
			lw * 1.1, -- 398
			stroke -- 398
		) -- 398
		draw:drawSegment( -- 400
			Vec2(cx - r * 0.34, cy - r * 0.54), -- 400
			Vec2(cx - r * 0.14, cy + r * 0.3), -- 400
			lw * 0.8, -- 400
			faint -- 400
		) -- 400
		draw:drawSegment( -- 401
			Vec2(cx - r * 0.52, cy - r * 0.14), -- 401
			Vec2(cx + r * 0.24, cy - r * 0.14), -- 401
			lw * 0.75, -- 401
			faint -- 401
		) -- 401
		draw:drawPolygon( -- 403
			{ -- 403
				Vec2(cx - r * 0.42, cy + r * 0.14), -- 404
				Vec2(cx + r * 0.44, cy + r * 0.76), -- 405
				Vec2(cx + r * 0.62, cy + r * 0.58), -- 406
				Vec2(cx - r * 0.18, cy - r * 0.06) -- 407
			}, -- 407
			toColor(coreCol or PALETTE.amberCore, 52 * alpha), -- 408
			lw * 1.05, -- 408
			core -- 408
		) -- 408
		draw:drawSegment( -- 410
			Vec2(cx + r * 0.48, cy + r * 0.64), -- 410
			Vec2(cx + r * 0.8, cy + r * 0.84), -- 410
			lw * 1.65, -- 410
			stroke -- 410
		) -- 410
		draw:drawSegment( -- 412
			Vec2(cx - r * 0.66, cy + r * 0.52), -- 412
			Vec2(cx - r * 0.48, cy + r * 0.64), -- 412
			lw * 0.85, -- 412
			core -- 412
		) -- 412
		draw:drawSegment( -- 413
			Vec2(cx - r * 0.76, cy + r * 0.26), -- 413
			Vec2(cx - r * 0.6, cy + r * 0.34), -- 413
			lw * 0.75, -- 413
			faint -- 413
		) -- 413
		return -- 414
	end -- 414
	draw:drawPolygon( -- 418
		{ -- 418
			Vec2(cx - r * 0.34, cy + r * 0.76), -- 419
			Vec2(cx + r * 0.34, cy + r * 0.76), -- 420
			Vec2(cx + r * 0.34, cy - r * 0.46), -- 421
			Vec2(cx, cy - r * 0.84), -- 422
			Vec2(cx - r * 0.34, cy - r * 0.46) -- 423
		}, -- 423
		fill, -- 424
		lw * 1.1, -- 424
		stroke -- 424
	) -- 424
	draw:drawCircle( -- 425
		Vec2(cx, cy + r * 0.5), -- 425
		r * 0.11, -- 425
		toColor(PALETTE.panelBgDeep, 220 * alpha) -- 425
	) -- 425
	draw:drawRing( -- 426
		Vec2(cx, cy + r * 0.5), -- 426
		r * 0.08, -- 426
		r * 0.14, -- 426
		Color(0, 0, 0, 0), -- 426
		lw * 0.8, -- 426
		core -- 426
	) -- 426
	draw:drawSegment( -- 427
		Vec2(cx - r * 0.22, cy + r * 0.14), -- 427
		Vec2(cx + r * 0.22, cy + r * 0.14), -- 427
		lw * 0.9, -- 427
		core -- 427
	) -- 427
	draw:drawSegment( -- 428
		Vec2(cx - r * 0.22, cy - r * 0.12), -- 428
		Vec2(cx + r * 0.22, cy - r * 0.12), -- 428
		lw * 0.9, -- 428
		faint -- 428
	) -- 428
	draw:drawSegment( -- 429
		Vec2(cx - r * 0.16, cy - r * 0.36), -- 429
		Vec2(cx + r * 0.16, cy - r * 0.36), -- 429
		lw * 0.8, -- 429
		faint -- 429
	) -- 429
end -- 317
--- 绘制明初器物级战备/掉落物纹样（HUD 行囊条与 2.5D 世界掉落物 100% 同源）：
-- 8 类物资轮廓完全互异，取代原 props.ts 的「万物皆指南针」。
function ____exports.drawPickupGlyph(draw, cx, cy, radius, kind, alpha, overrideCol) -- 436
	if alpha == nil then -- 442
		alpha = 1 -- 442
	end -- 442
	local meta = ____exports.pickupMetaOf(kind) -- 445
	local col = overrideCol or meta.accent -- 446
	local core = overrideCol or meta.accentCore -- 447
	local r = math.max(4.5, radius) -- 448
	local lw = math.max(0.95, r * 0.12) -- 449
	local stroke = toColor(col, 240 * alpha) -- 450
	local hi = toColor(core, 248 * alpha) -- 451
	local fill = toColor(col, 68 * alpha) -- 452
	local darkFill = Color( -- 453
		20, -- 453
		18, -- 453
		22, -- 453
		math.floor(185 * alpha + 0.5) -- 453
	) -- 453
	if kind == "wood" then -- 455
		draw:drawPolygon( -- 457
			{ -- 457
				Vec2(cx - r * 0.36, cy + r * 0.82), -- 458
				Vec2(cx + r * 0.36, cy + r * 0.82), -- 459
				Vec2(cx + r * 0.36, cy - r * 0.64), -- 460
				Vec2(cx, cy - r * 0.9), -- 461
				Vec2(cx - r * 0.36, cy - r * 0.64) -- 462
			}, -- 462
			fill, -- 463
			lw * 1.1, -- 463
			hi -- 463
		) -- 463
		draw:drawDot( -- 464
			Vec2(cx, cy + r * 0.54), -- 464
			math.max(1.2, r * 0.12), -- 464
			darkFill -- 464
		) -- 464
		draw:drawSegment( -- 465
			Vec2(cx - r * 0.22, cy + r * 0.16), -- 465
			Vec2(cx + r * 0.22, cy + r * 0.16), -- 465
			lw * 0.9, -- 465
			hi -- 465
		) -- 465
		draw:drawSegment( -- 466
			Vec2(cx - r * 0.22, cy - r * 0.14), -- 466
			Vec2(cx + r * 0.22, cy - r * 0.14), -- 466
			lw * 0.9, -- 466
			stroke -- 466
		) -- 466
		draw:drawSegment( -- 467
			Vec2(cx - r * 0.14, cy - r * 0.42), -- 467
			Vec2(cx + r * 0.14, cy - r * 0.42), -- 467
			lw * 0.8, -- 467
			stroke -- 467
		) -- 467
		return -- 468
	end -- 468
	if kind == "bell" then -- 471
		drawReloadPatternGlyph( -- 473
			draw, -- 473
			cx, -- 473
			cy, -- 473
			r * 1.05, -- 473
			"echo", -- 473
			core, -- 473
			alpha -- 473
		) -- 473
		return -- 474
	end -- 474
	if kind == "shield" then -- 477
		draw:drawPolygon( -- 479
			{ -- 479
				Vec2(cx - r * 0.64, cy + r * 0.72), -- 480
				Vec2(cx + r * 0.64, cy + r * 0.72), -- 481
				Vec2(cx + r * 0.58, cy - r * 0.36), -- 482
				Vec2(cx, cy - r * 0.82), -- 483
				Vec2(cx - r * 0.58, cy - r * 0.36) -- 484
			}, -- 484
			fill, -- 485
			lw * 1.15, -- 485
			hi -- 485
		) -- 485
		draw:drawCircle( -- 486
			Vec2(cx, cy + r * 0.08), -- 486
			r * 0.2, -- 486
			hi -- 486
		) -- 486
		draw:drawSegment( -- 487
			Vec2(cx - r * 0.54, cy + r * 0.44), -- 487
			Vec2(cx - r * 0.2, cy + r * 0.22), -- 487
			lw * 0.8, -- 487
			darkFill -- 487
		) -- 487
		return -- 488
	end -- 488
	if kind == "wedge" then -- 491
		draw:drawPolygon( -- 493
			{ -- 493
				Vec2(cx - r * 0.78, cy - r * 0.46), -- 494
				Vec2(cx + r * 0.78, cy - r * 0.46), -- 495
				Vec2(cx + r * 0.44, cy + r * 0.52), -- 496
				Vec2(cx - r * 0.24, cy + r * 0.52) -- 497
			}, -- 497
			fill, -- 498
			lw * 1.15, -- 498
			hi -- 498
		) -- 498
		draw:drawSegment( -- 499
			Vec2(cx - r * 0.24, cy + r * 0.52), -- 499
			Vec2(cx - r * 0.12, cy - r * 0.46), -- 499
			lw * 0.9, -- 499
			hi -- 499
		) -- 499
		draw:drawSegment( -- 500
			Vec2(cx + r * 0.16, cy + r * 0.1), -- 500
			Vec2(cx + r * 0.46, cy + r * 0.1), -- 500
			lw * 0.75, -- 500
			stroke -- 500
		) -- 500
		return -- 501
	end -- 501
	if kind == "ammo" then -- 504
		draw:drawPolygon( -- 506
			{ -- 506
				Vec2(cx - r * 0.28, cy + r * 0.42), -- 507
				Vec2(cx + r * 0.28, cy + r * 0.42), -- 508
				Vec2(cx + r * 0.66, cy - r * 0.24), -- 509
				Vec2(cx + r * 0.44, cy - r * 0.76), -- 510
				Vec2(cx - r * 0.44, cy - r * 0.76), -- 511
				Vec2(cx - r * 0.66, cy - r * 0.24) -- 512
			}, -- 512
			fill, -- 513
			lw * 1.1, -- 513
			hi -- 513
		) -- 513
		draw:drawSegment( -- 515
			Vec2(cx - r * 0.38, cy + r * 0.4), -- 515
			Vec2(cx + r * 0.38, cy + r * 0.4), -- 515
			lw * 1.25, -- 515
			hi -- 515
		) -- 515
		draw:drawSegment( -- 516
			Vec2(cx - r * 0.22, cy + r * 0.42), -- 516
			Vec2(cx - r * 0.36, cy + r * 0.78), -- 516
			lw, -- 516
			stroke -- 516
		) -- 516
		draw:drawSegment( -- 517
			Vec2(cx + r * 0.22, cy + r * 0.42), -- 517
			Vec2(cx + r * 0.36, cy + r * 0.78), -- 517
			lw, -- 517
			stroke -- 517
		) -- 517
		draw:drawDot( -- 518
			Vec2(cx, cy - r * 0.22), -- 518
			math.max(1.4, r * 0.18), -- 518
			hi -- 518
		) -- 518
		return -- 519
	end -- 519
	if kind == "scrap" then -- 522
		draw:drawSegment( -- 524
			Vec2(cx - r * 0.74, cy - r * 0.48), -- 524
			Vec2(cx + r * 0.74, cy + r * 0.48), -- 524
			lw * 2.1, -- 524
			stroke -- 524
		) -- 524
		draw:drawSegment( -- 525
			Vec2(cx - r * 0.74, cy - r * 0.48), -- 525
			Vec2(cx + r * 0.74, cy + r * 0.48), -- 525
			lw * 0.9, -- 525
			hi -- 525
		) -- 525
		draw:drawSegment( -- 526
			Vec2(cx - r * 0.64, cy + r * 0.52), -- 526
			Vec2(cx + r * 0.64, cy - r * 0.52), -- 526
			lw * 2, -- 526
			stroke -- 526
		) -- 526
		draw:drawSegment( -- 527
			Vec2(cx - r * 0.64, cy + r * 0.52), -- 527
			Vec2(cx + r * 0.64, cy - r * 0.52), -- 527
			lw * 0.85, -- 527
			hi -- 527
		) -- 527
		return -- 528
	end -- 528
	if kind == "pass" then -- 531
		draw:drawPolygon( -- 533
			{ -- 533
				Vec2(cx - r * 0.46, cy + r * 0.42), -- 534
				Vec2(cx, cy + r * 0.82), -- 535
				Vec2(cx + r * 0.46, cy + r * 0.42), -- 536
				Vec2(cx + r * 0.46, cy - r * 0.46), -- 537
				Vec2(cx - r * 0.46, cy - r * 0.46) -- 538
			}, -- 538
			fill, -- 539
			lw * 1.1, -- 539
			hi -- 539
		) -- 539
		draw:drawSegment( -- 540
			Vec2(cx, cy - r * 0.46), -- 540
			Vec2(cx, cy - r * 0.88), -- 540
			lw, -- 540
			hi -- 540
		) -- 540
		draw:drawSegment( -- 541
			Vec2(cx - r * 0.16, cy - r * 0.66), -- 541
			Vec2(cx - r * 0.22, cy - r * 0.88), -- 541
			lw * 0.75, -- 541
			stroke -- 541
		) -- 541
		draw:drawSegment( -- 542
			Vec2(cx + r * 0.16, cy - r * 0.66), -- 542
			Vec2(cx + r * 0.22, cy - r * 0.88), -- 542
			lw * 0.75, -- 542
			stroke -- 542
		) -- 542
		drawDiamond( -- 543
			draw, -- 543
			cx, -- 543
			cy + r * 0.04, -- 543
			r * 0.16, -- 543
			r * 0.22, -- 543
			hi -- 543
		) -- 543
		return -- 544
	end -- 544
	if kind == "quickbelt" then -- 547
		draw:drawSegment( -- 549
			Vec2(cx - r * 0.78, cy - r * 0.66), -- 549
			Vec2(cx + r * 0.78, cy + r * 0.66), -- 549
			lw * 1.5, -- 549
			stroke -- 549
		) -- 549
		local k = -1 -- 550
		do -- 550
			k = -1 -- 551
			while k <= 1 do -- 551
				local tx = cx + k * r * 0.36 -- 552
				local ty = cy + k * r * 0.3 -- 553
				draw:drawRect( -- 554
					Rect(tx - r * 0.14, ty - r * 0.24, r * 0.28, r * 0.48), -- 554
					fill, -- 554
					lw * 0.9, -- 554
					hi -- 554
				) -- 554
				k = k + 1 -- 551
			end -- 551
		end -- 551
		return -- 556
	end -- 556
	drawDiamond( -- 559
		draw, -- 559
		cx, -- 559
		cy, -- 559
		r * 0.56, -- 559
		r * 0.56, -- 559
		fill, -- 559
		lw, -- 559
		hi -- 559
	) -- 559
end -- 436
--- 在 2.5D 世界舞台上绘制具有接触影、轻浮呼吸与明初轮廓的地面掉落物（供 props.ts 调用）。
function ____exports.drawWorldPickupVisual(fgDraw, fgGlow, cx, groundY, scalePx, kind, time, seedPhase) -- 565
	local meta = ____exports.pickupMetaOf(kind) -- 575
	local bob = math.sin(time * 2.8 + seedPhase) * 2.1 -- 576
	local iconY = groundY + scalePx * 0.88 + bob -- 577
	local r = math.max(6.5, scalePx * 0.62) -- 578
	local shScale = 1 - bob * 0.025 -- 581
	fgDraw:drawEllipse( -- 582
		Vec2(cx, groundY + 1.5), -- 582
		r * 0.95 * shScale, -- 582
		math.max(2.2, r * 0.3 * shScale), -- 582
		Color(6, 8, 12, 155) -- 582
	) -- 582
	local isBenchMat = kind == "wood" or kind == "bell" -- 585
	local glowA = isBenchMat and 36 + math.sin(time * 3.6 + seedPhase) * 10 or 22 -- 586
	fillRadialGlow( -- 587
		fgGlow, -- 588
		cx, -- 589
		iconY, -- 590
		r * (isBenchMat and 2.1 or 1.65), -- 591
		r * (isBenchMat and 2.1 or 1.65), -- 592
		toColor(meta.accentCore, glowA), -- 593
		Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 594
		12 -- 595
	) -- 595
	fgDraw:drawCircle( -- 599
		Vec2(cx, iconY), -- 599
		r * 1.06, -- 599
		Color(10, 12, 18, 150) -- 599
	) -- 599
	fgDraw:drawRing( -- 600
		Vec2(cx, iconY), -- 600
		r * 1.02, -- 600
		r * 1.14, -- 600
		Color(0, 0, 0, 0), -- 600
		0.9, -- 600
		toColor(meta.accent, isBenchMat and 175 or 120) -- 600
	) -- 600
	____exports.drawPickupGlyph( -- 602
		fgDraw, -- 602
		cx, -- 602
		iconY, -- 602
		r * 0.84, -- 602
		kind, -- 602
		0.98 -- 602
	) -- 602
end -- 565
return ____exports -- 565
