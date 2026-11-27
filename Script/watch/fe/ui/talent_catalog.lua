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
	category = "护身", -- 121
	accent = PALETTE.emerald, -- 122
	accentCore = PALETTE.moonPale, -- 123
	whisper = "「挨了这一记，步子不能乱。」", -- 124
	absorbTarget = "shoulder", -- 125
	shortEffect = function(____, snap) return ((("护身 " .. tostring(snap.invulnTicksNow)) .. " → ") .. tostring(snap.invulnTicksNow + 15)) .. " 拍" end, -- 126
	subEffect = function() return "受击多得喘息窗 (+15 拍) · 翻滚避近战" end, -- 127
	ledgerLine = function(____, snap, rank) return ((("受击保护 " .. tostring(snap.invulnTicksNow)) .. " 拍（加 ") .. tostring(rank * 15)) .. " 拍）" end -- 128
}) -- 128
____exports.registerTalentVisual({ -- 131
	id = "stride", -- 132
	title = "疾步", -- 133
	category = "护身", -- 134
	accent = PALETTE.cyan, -- 135
	accentCore = PALETTE.cyanCore, -- 136
	whisper = "「步子稳且快，早些见着北塔灯。」", -- 137
	absorbTarget = "shoulder", -- 138
	shortEffect = function(____, _snap, curRank) return ("背负步速 +" .. tostring((curRank + 1) * 10)) .. "%" end, -- 139
	subEffect = function() return "翻滚突围更疾 · 与回声铳相合" end, -- 140
	ledgerLine = function(____, _snap, rank) return ((("背负步速 +" .. tostring(rank * 10)) .. "% · 翻滚 +") .. tostring(rank * 8)) .. "%" end -- 141
}) -- 141
____exports.registerTalentVisual({ -- 144
	id = "focus", -- 145
	title = "凝神", -- 146
	category = "枪机", -- 147
	accent = PALETTE.amber, -- 148
	accentCore = PALETTE.amberCore, -- 149
	whisper = "「稳住气息，慢时连线从容不迫。」", -- 150
	absorbTarget = "gun", -- 151
	shortEffect = function(____, _snap, curRank) return ("慢时换弹线盘 +" .. tostring(curRank + 1)) .. " 秒" end, -- 152
	subEffect = function() return "连线窗口 +60 拍 · 与引路灯铳相合" end, -- 153
	ledgerLine = function(____, _snap, rank) return ((("换弹连线窗口 +" .. tostring(rank)) .. " 秒（+") .. tostring(rank * 60)) .. " 拍）" end -- 154
}) -- 154
____exports.registerTalentVisual({ -- 157
	id = "push_force", -- 158
	title = "劲推", -- 159
	category = "枪机", -- 160
	accent = PALETTE.rouge, -- 161
	accentCore = PALETTE.amberCore, -- 162
	whisper = "「一铳破盾，逼退围拢之敌。」", -- 163
	absorbTarget = "gun", -- 164
	shortEffect = function(____, _snap, curRank) return ("破盾加伤 · 邻近震退（" .. ____exports.rankChinese(curRank + 1)) .. "重）" end, -- 165
	subEffect = function() return "推退连线重挫盾面并压缓举铳" end, -- 166
	ledgerLine = function(____, _snap, rank) return ("推退破盾与震退强化（" .. ____exports.rankChinese(rank)) .. "阶）" end -- 167
}) -- 167
____exports.registerTalentVisual({ -- 170
	id = "echo_wide", -- 171
	title = "广音", -- 172
	category = "枪机", -- 173
	accent = PALETTE.cyan, -- 174
	accentCore = PALETTE.cyanCore, -- 175
	whisper = "「铜铃传巷远，群寇皆回首。」", -- 176
	absorbTarget = "gun", -- 177
	shortEffect = function(____, _snap, curRank) return ("回声多惊 +" .. tostring(curRank + 1)) .. " 敌 · 延后开火" end, -- 178
	subEffect = function() return "铃纹连线扩域 · 与回声铳共鸣" end, -- 179
	ledgerLine = function(____, _snap, rank) return ((("回声多惊 +" .. tostring(rank)) .. " 敌 · 延缓举铳 +") .. tostring(rank * 30)) .. " 拍" end -- 180
}) -- 180
____exports.registerTalentVisual({ -- 183
	id = "lantern_pierce", -- 184
	title = "明灯", -- 185
	category = "工巧", -- 186
	accent = PALETTE.amberCore, -- 187
	accentCore = PALETTE.textBright, -- 188
	whisper = "「灯火一明，夜巷尽收眼底。」", -- 189
	absorbTarget = "gun", -- 190
	shortEffect = function(____, _snap, curRank) return "灯纹必起光晕 · 照域 +" .. tostring((curRank + 1) * 50) end, -- 191
	subEffect = function() return "镇住旁侧敌兵 · 与引路灯铳共鸣" end, -- 192
	ledgerLine = function(____, _snap, rank) return "灯纹光晕镇敌 · 半径 +" .. tostring(rank * 50) end -- 193
}) -- 193
____exports.registerTalentVisual({ -- 196
	id = "salvage", -- 197
	title = "拾料", -- 198
	category = "工巧", -- 199
	accent = PALETTE.amber, -- 200
	accentCore = PALETTE.amberCore, -- 201
	whisper = "「沿途收齐筹料，盾楔多撑一记。」", -- 202
	absorbTarget = "satchel", -- 203
	shortEffect = function() return "即得紧缺筹料 +1 · 盾楔加厚" end, -- 204
	subEffect = function() return "便携残盾与野战木楔耐受增强" end, -- 205
	ledgerLine = function(____, _snap, rank) return ("拾料补筹 · 架盾与立楔多承 +" .. tostring(rank)) .. " 击" end -- 206
}) -- 206
____exports.registerTalentVisual({ -- 209
	id = "craft", -- 210
	title = "巧手", -- 211
	category = "机巧", -- 212
	accent = PALETTE.amber, -- 213
	accentCore = PALETTE.amberCore, -- 214
	whisper = "「爹教的楔法，倒派上用场。」", -- 215
	absorbTarget = "satchel", -- 216
	shortEffect = function(____, snap) -- 217
		local next = math.max(6, snap.craftTicksNow - 6) -- 218
		return ((("制楔 " .. tostring(snap.craftTicksNow)) .. " → ") .. tostring(next)) .. " 拍" -- 219
	end, -- 217
	subEffect = function() return "顺手减装填 3 拍" end, -- 221
	ledgerLine = function(____, snap, rank) return ((("制楔 " .. tostring(snap.craftTicksNow)) .. " 拍 · 装填另减 ") .. tostring(rank * 3)) .. " 拍" end -- 222
}) -- 222
--- 解析任意本领 ID 的视觉元数据；未知未来 ID 自动回退至明代军筹通用模板。
function ____exports.resolveTalentVisual(id, snap) -- 226
	local reg = TALENT_REGISTRY[id] -- 227
	if reg ~= nil then -- 228
		return reg -- 229
	end -- 229
	local hint = snap ~= nil and snap.talentLabelHints[id] or nil or talentNames[id] or id -- 231
	local dotIdx = (string.find(hint, "·", nil, true) or 0) - 1 -- 234
	local parsedTitle = dotIdx > 0 and __TS__StringSlice(hint, 0, dotIdx) or hint -- 235
	local parsedDesc = dotIdx > 0 and __TS__StringSlice(hint, dotIdx + 1) or "行军备策 · 增益一阶" -- 236
	return { -- 237
		id = id, -- 238
		title = parsedTitle ~= "" and parsedTitle or "军筹", -- 239
		category = "军筹", -- 240
		accent = PALETTE.jadeMist, -- 241
		accentCore = PALETTE.textBright, -- 242
		whisper = "「夜路漫漫，多备一筹总安心。」", -- 243
		absorbTarget = "crest", -- 244
		shortEffect = function() return parsedDesc end, -- 245
		subEffect = function(____, _s, curRank) return ((("现 " .. ____exports.rankChinese(curRank)) .. " → ") .. ____exports.rankChinese(curRank + 1)) .. " 阶" end, -- 246
		ledgerLine = function(____, _s, rank) return ((parsedDesc .. "（") .. ____exports.rankChinese(rank)) .. " 阶）" end -- 247
	} -- 247
end -- 226
local WEAPON_META = {standard_gun = { -- 251
	id = "standard_gun", -- 253
	name = "标准鸟铳", -- 254
	shortName = "鸟铳", -- 255
	effect = "normal", -- 256
	accent = PALETTE.silkLine, -- 257
	desc = "九宫连线蓄推退、铃纹、灯纹" -- 258
}, guide_lantern_gun = { -- 260
	id = "guide_lantern_gun", -- 261
	name = "引路灯铳", -- 262
	shortName = "灯铳", -- 263
	effect = "light", -- 264
	accent = PALETTE.amberCore, -- 265
	desc = "强化灯纹破夜光晕镇敌" -- 266
}, echo_gun = { -- 268
	id = "echo_gun", -- 269
	name = "回声铜铃铳", -- 270
	shortName = "回声铳", -- 271
	effect = "echo", -- 272
	accent = PALETTE.cyanCore, -- 273
	desc = "强化铃纹双响回声诱敌" -- 274
}, time_shuttler = { -- 276
	id = "time_shuttler", -- 277
	name = "时间穿梭器", -- 278
	shortName = "穿梭器", -- 279
	effect = "knockback", -- 280
	accent = PALETTE.amberCore, -- 281
	desc = "双线归档旧物，冷白残影" -- 282
}} -- 282
function ____exports.weaponMetaOf(weaponId) -- 286
	return WEAPON_META[weaponId] or WEAPON_META.standard_gun -- 287
end -- 286
____exports.PICKUP_ORDER = { -- 290
	"wood", -- 291
	"bell", -- 292
	"shield", -- 293
	"wedge", -- 294
	"ammo", -- 295
	"scrap", -- 296
	"pass", -- 297
	"quickbelt" -- 298
} -- 298
local PICKUP_META = { -- 301
	wood = { -- 302
		kind = "wood", -- 302
		name = "木纹筹", -- 302
		shortName = "木筹", -- 302
		accent = PALETTE.amber, -- 302
		accentCore = PALETTE.amberCore, -- 302
		category = "material" -- 302
	}, -- 302
	bell = { -- 303
		kind = "bell", -- 303
		name = "铃纹筹", -- 303
		shortName = "铃筹", -- 303
		accent = PALETTE.amberCore, -- 303
		accentCore = PALETTE.amberCore, -- 303
		category = "material" -- 303
	}, -- 303
	shield = { -- 304
		kind = "shield", -- 304
		name = "残盾", -- 304
		shortName = "残盾", -- 304
		accent = PALETTE.cyan, -- 304
		accentCore = PALETTE.cyanCore, -- 304
		category = "gear" -- 304
	}, -- 304
	wedge = { -- 305
		kind = "wedge", -- 305
		name = "木楔", -- 305
		shortName = "木楔", -- 305
		accent = PALETTE.emerald, -- 305
		accentCore = PALETTE.moonPale, -- 305
		category = "gear" -- 305
	}, -- 305
	ammo = { -- 306
		kind = "ammo", -- 306
		name = "备用弹包", -- 306
		shortName = "弹包", -- 306
		accent = PALETTE.rouge, -- 306
		accentCore = PALETTE.crimsonCore, -- 306
		category = "gear" -- 306
	}, -- 306
	scrap = { -- 307
		kind = "scrap", -- 307
		name = "废木料", -- 307
		shortName = "木料", -- 307
		accent = PALETTE.amberDim, -- 307
		accentCore = PALETTE.amber, -- 307
		category = "material" -- 307
	}, -- 307
	pass = { -- 308
		kind = "pass", -- 308
		name = "护送号牌", -- 308
		shortName = "号牌", -- 308
		accent = PALETTE.jadeMist, -- 308
		accentCore = PALETTE.textBright, -- 308
		category = "gear" -- 308
	}, -- 308
	quickbelt = { -- 309
		kind = "quickbelt", -- 309
		name = "快装带", -- 309
		shortName = "装带", -- 309
		accent = PALETTE.amber, -- 309
		accentCore = PALETTE.amberCore, -- 309
		category = "gear" -- 309
	} -- 309
} -- 309
function ____exports.pickupMetaOf(kind) -- 312
	return PICKUP_META[kind] or ({ -- 313
		kind = kind, -- 314
		name = kind, -- 315
		shortName = kind, -- 316
		accent = PALETTE.silkLine, -- 317
		accentCore = PALETTE.textBright, -- 318
		category = "gear" -- 319
	}) -- 319
end -- 312
--- 按当前已习本领、所持火铳与战备派生纯前端「行军雅号」（兼容 PR #25 八本领与旧四本领）。
function ____exports.deriveMarchTitle(snap) -- 324
	local vit = snap.ranks.vitality or 0 -- 325
	local rel = (snap.ranks.reload or 0) + (snap.ranks.focus or 0) -- 326
	local grd = snap.ranks.guard or 0 -- 327
	local str = snap.ranks.stride or 0 -- 328
	local psh = snap.ranks.push_force or 0 -- 329
	local ech = snap.ranks.echo_wide or 0 -- 330
	local lnt = snap.ranks.lantern_pierce or 0 -- 331
	local crf = (snap.ranks.craft or 0) + (snap.ranks.salvage or 0) -- 332
	local total = snap.totalRanks -- 333
	local weapon = snap.equippedWeapon -- 334
	local wedge = snap.supplies.wedge or 0 -- 335
	if total <= 0 then -- 337
		return { -- 338
			title = "初启北行", -- 338
			sealTop = "守", -- 338
			sealBot = "望", -- 338
			subtitle = "行囊初整，孤灯在前", -- 338
			accent = PALETTE.silkLine -- 338
		} -- 338
	end -- 338
	if (rel >= 2 or lnt >= 2) and weapon == "guide_lantern_gun" then -- 340
		return { -- 341
			title = "明火疾铳", -- 341
			sealTop = "明", -- 341
			sealBot = "火", -- 341
			subtitle = "灯影破夜，火绳如电", -- 341
			accent = PALETTE.amberCore -- 341
		} -- 341
	end -- 341
	if (rel >= 2 or ech >= 2) and weapon == "echo_gun" then -- 343
		return { -- 344
			title = "惊铃连响", -- 344
			sealTop = "惊", -- 344
			sealBot = "铃", -- 344
			subtitle = "铜铃惑敌，连发不断", -- 344
			accent = PALETTE.cyanCore -- 344
		} -- 344
	end -- 344
	if vit + grd >= 3 and vit >= 1 and grd >= 1 then -- 346
		return { -- 347
			title = "铁壁断后", -- 347
			sealTop = "铁", -- 347
			sealBot = "壁", -- 347
			subtitle = "重甲护身，步履不乱", -- 347
			accent = PALETTE.cyan -- 347
		} -- 347
	end -- 347
	if crf >= 2 or crf >= 1 and wedge >= 1 then -- 349
		return { -- 350
			title = "巧楔筑垒", -- 350
			sealTop = "巧", -- 350
			sealBot = "楔", -- 350
			subtitle = "削木固掩，以巧破险", -- 350
			accent = PALETTE.emerald -- 350
		} -- 350
	end -- 350
	if lnt >= 2 then -- 352
		return { -- 353
			title = "镇雾孤灯", -- 353
			sealTop = "明", -- 353
			sealBot = "灯", -- 353
			subtitle = "余明破暗，镇敌于前", -- 353
			accent = PALETTE.amberCore -- 353
		} -- 353
	end -- 353
	if psh >= 2 then -- 355
		return { -- 356
			title = "破盾劲铳", -- 356
			sealTop = "劲", -- 356
			sealBot = "推", -- 356
			subtitle = "一铳撼盾，寸步不让", -- 356
			accent = PALETTE.rouge -- 356
		} -- 356
	end -- 356
	if ech >= 2 then -- 358
		return { -- 359
			title = "广音惑寇", -- 359
			sealTop = "广", -- 359
			sealBot = "音", -- 359
			subtitle = "铃声远扬，步步生机", -- 359
			accent = PALETTE.cyanCore -- 359
		} -- 359
	end -- 359
	if str >= 2 then -- 361
		return { -- 362
			title = "踏风负行", -- 362
			sealTop = "疾", -- 362
			sealBot = "步", -- 362
			subtitle = "肩背疾行，直趋北塔", -- 362
			accent = PALETTE.cyan -- 362
		} -- 362
	end -- 362
	if rel >= 2 then -- 364
		return { -- 365
			title = "疾火连铳", -- 365
			sealTop = "疾", -- 365
			sealBot = "铳", -- 365
			subtitle = "熟手快装，火线不绝", -- 365
			accent = PALETTE.amber -- 365
		} -- 365
	end -- 365
	if vit >= 2 then -- 367
		return { -- 368
			title = "重甲负行", -- 368
			sealTop = "重", -- 368
			sealBot = "甲", -- 368
			subtitle = "铁衣加身，稳背同行", -- 368
			accent = PALETTE.cyan -- 368
		} -- 368
	end -- 368
	if grd >= 2 then -- 370
		return { -- 371
			title = "稳步护势", -- 371
			sealTop = "护", -- 371
			sealBot = "身", -- 371
			subtitle = "身法从容，危中留隙", -- 371
			accent = PALETTE.emerald -- 371
		} -- 371
	end -- 371
	return { -- 373
		title = "孤城守望", -- 373
		sealTop = "守", -- 373
		sealBot = "望", -- 373
		subtitle = "诸筹兼备，护她北归", -- 373
		accent = PALETTE.rouge -- 373
	} -- 373
end -- 324
--- 内部工具：用短折线绘制清秀明式弧线（兼容所有缩放与灰度）。
function ____exports.drawBrushArc(draw, cx, cy, rx, ry, startRad, endRad, thickness, color, segments) -- 377
	if segments == nil then -- 387
		segments = 14 -- 387
	end -- 387
	local n = math.max(4, segments) -- 389
	local prevX = cx + math.cos(startRad) * rx -- 390
	local prevY = cy + math.sin(startRad) * ry -- 391
	local i = 1 -- 392
	do -- 392
		i = 1 -- 393
		while i <= n do -- 393
			local a = startRad + (endRad - startRad) * i / n -- 394
			local nx = cx + math.cos(a) * rx -- 395
			local ny = cy + math.sin(a) * ry -- 396
			draw:drawSegment( -- 397
				Vec2(prevX, prevY), -- 397
				Vec2(nx, ny), -- 397
				thickness, -- 397
				color -- 397
			) -- 397
			prevX = nx -- 398
			prevY = ny -- 399
			i = i + 1 -- 393
		end -- 393
	end -- 393
end -- 377
--- 绘制明初器物工笔本领纹样（纯 DrawNode 矢量，静音与灰度下轮廓 100% 互异）：
-- - vitality：明式叠鳞札甲 + 居中圆形护心镜
-- - reload：明式鸟铳龙头火绳弯钩 + 药池微星
-- - guard：明式云肩披膊 + 双向卸力偏锋弧
-- - craft：削木短刀 + 梯形木楔契口
-- - fallback：明代卫所竖式军筹木简
function ____exports.drawTalentGlyph(draw, cx, cy, radius, talentId, col, alpha, coreCol) -- 411
	if alpha == nil then -- 418
		alpha = 1 -- 418
	end -- 418
	local r = math.max(5, radius) -- 421
	local lw = math.max(1, r * 0.085) -- 422
	local stroke = toColor(col, 240 * alpha) -- 423
	local core = toColor(coreCol or PALETTE.textBright, 245 * alpha) -- 424
	local faint = toColor(col, 125 * alpha) -- 425
	local fill = toColor(col, 38 * alpha) -- 426
	if talentId == "vitality" then -- 428
		draw:drawPolygon( -- 430
			{ -- 430
				Vec2(cx - r * 0.72, cy + r * 0.66), -- 431
				Vec2(cx - r * 0.28, cy + r * 0.82), -- 432
				Vec2(cx + r * 0.28, cy + r * 0.82), -- 433
				Vec2(cx + r * 0.72, cy + r * 0.66), -- 434
				Vec2(cx + r * 0.64, cy - r * 0.26), -- 435
				Vec2(cx, cy - r * 0.84), -- 436
				Vec2(cx - r * 0.64, cy - r * 0.26) -- 437
			}, -- 437
			fill, -- 438
			lw * 1.1, -- 438
			stroke -- 438
		) -- 438
		draw:drawSegment( -- 440
			Vec2(cx - r * 0.62, cy + r * 0.22), -- 440
			Vec2(cx + r * 0.62, cy + r * 0.22), -- 440
			lw * 0.8, -- 440
			faint -- 440
		) -- 440
		draw:drawSegment( -- 441
			Vec2(cx - r * 0.56, cy - r * 0.24), -- 441
			Vec2(cx + r * 0.56, cy - r * 0.24), -- 441
			lw * 0.8, -- 441
			faint -- 441
		) -- 441
		draw:drawSegment( -- 443
			Vec2(cx - r * 0.3, cy - r * 0.52), -- 443
			Vec2(cx - r * 0.34, cy + r * 0.68), -- 443
			lw * 0.7, -- 443
			faint -- 443
		) -- 443
		draw:drawSegment( -- 444
			Vec2(cx + r * 0.3, cy - r * 0.52), -- 444
			Vec2(cx + r * 0.34, cy + r * 0.68), -- 444
			lw * 0.7, -- 444
			faint -- 444
		) -- 444
		draw:drawCircle( -- 446
			Vec2(cx, cy + r * 0.04), -- 446
			r * 0.32, -- 446
			toColor(PALETTE.panelBgDeep, 210 * alpha) -- 446
		) -- 446
		draw:drawRing( -- 447
			Vec2(cx, cy + r * 0.04), -- 447
			r * 0.26, -- 447
			r * 0.34, -- 447
			Color(0, 0, 0, 0), -- 447
			lw, -- 447
			core -- 447
		) -- 447
		draw:drawDot( -- 448
			Vec2(cx, cy + r * 0.04), -- 448
			math.max(1.4, r * 0.11), -- 448
			core -- 448
		) -- 448
		return -- 449
	end -- 449
	if talentId == "reload" or talentId == "focus" then -- 452
		draw:drawSegment( -- 454
			Vec2(cx - r * 0.82, cy - r * 0.54), -- 454
			Vec2(cx + r * 0.82, cy + r * 0.34), -- 454
			lw * 1.45, -- 454
			stroke -- 454
		) -- 454
		draw:drawSegment( -- 455
			Vec2(cx - r * 0.76, cy - r * 0.68), -- 455
			Vec2(cx + r * 0.22, cy - r * 0.14), -- 455
			lw * 1, -- 455
			faint -- 455
		) -- 455
		draw:drawSegment( -- 456
			Vec2(cx - r * 0.16, cy - r * 0.2), -- 456
			Vec2(cx - r * 0.26, cy + r * 0.32), -- 456
			lw * 1.15, -- 456
			core -- 456
		) -- 456
		draw:drawSegment( -- 457
			Vec2(cx - r * 0.26, cy + r * 0.32), -- 457
			Vec2(cx + r * 0.16, cy + r * 0.56), -- 457
			lw * 1.15, -- 457
			core -- 457
		) -- 457
		draw:drawSegment( -- 458
			Vec2(cx + r * 0.16, cy + r * 0.56), -- 458
			Vec2(cx + r * 0.38, cy + r * 0.36), -- 458
			lw * 1.05, -- 458
			core -- 458
		) -- 458
		local sx = cx + r * 0.44 -- 459
		local sy = cy + r * 0.34 -- 460
		drawDiamond( -- 461
			draw, -- 461
			sx, -- 461
			sy, -- 461
			r * 0.17, -- 461
			r * 0.17, -- 461
			core -- 461
		) -- 461
		draw:drawSegment( -- 462
			Vec2(sx - r * 0.28, sy), -- 462
			Vec2(sx + r * 0.28, sy), -- 462
			lw * 0.75, -- 462
			core -- 462
		) -- 462
		draw:drawSegment( -- 463
			Vec2(sx, sy - r * 0.28), -- 463
			Vec2(sx, sy + r * 0.28), -- 463
			lw * 0.75, -- 463
			core -- 463
		) -- 463
		draw:drawSegment( -- 464
			Vec2(cx - r * 0.82, cy - r * 0.54), -- 464
			Vec2(cx - r * 0.9, cy - r * 0.76), -- 464
			lw * 1.2, -- 464
			stroke -- 464
		) -- 464
		return -- 465
	end -- 465
	if talentId == "stride" then -- 468
		draw:drawSegment( -- 470
			Vec2(cx - r * 0.78, cy + r * 0.38), -- 470
			Vec2(cx + r * 0.24, cy + r * 0.38), -- 470
			lw * 1.35, -- 470
			stroke -- 470
		) -- 470
		draw:drawSegment( -- 471
			Vec2(cx - r * 0.18, cy + r * 0.7), -- 471
			Vec2(cx + r * 0.32, cy + r * 0.38), -- 471
			lw * 1.25, -- 471
			core -- 471
		) -- 471
		draw:drawSegment( -- 472
			Vec2(cx - r * 0.48, cy - r * 0.12), -- 472
			Vec2(cx + r * 0.78, cy - r * 0.12), -- 472
			lw * 1.45, -- 472
			stroke -- 472
		) -- 472
		draw:drawSegment( -- 473
			Vec2(cx + r * 0.24, cy + r * 0.2), -- 473
			Vec2(cx + r * 0.8, cy - r * 0.12), -- 473
			lw * 1.3, -- 473
			core -- 473
		) -- 473
		draw:drawSegment( -- 474
			Vec2(cx + r * 0.24, cy - r * 0.44), -- 474
			Vec2(cx + r * 0.8, cy - r * 0.12), -- 474
			lw * 1.3, -- 474
			core -- 474
		) -- 474
		draw:drawSegment( -- 475
			Vec2(cx - r * 0.76, cy - r * 0.48), -- 475
			Vec2(cx - r * 0.08, cy - r * 0.48), -- 475
			lw * 0.9, -- 475
			faint -- 475
		) -- 475
		return -- 476
	end -- 476
	if talentId == "push_force" then -- 479
		drawReloadPatternGlyph( -- 481
			draw, -- 481
			cx, -- 481
			cy, -- 481
			r * 0.95, -- 481
			"knockback", -- 481
			col, -- 481
			alpha -- 481
		) -- 481
		____exports.drawBrushArc( -- 482
			draw, -- 482
			cx - r * 0.1, -- 482
			cy, -- 482
			r * 0.72, -- 482
			r * 0.68, -- 482
			-math.pi * 0.36, -- 482
			math.pi * 0.36, -- 482
			lw * 1.15, -- 482
			core, -- 482
			10 -- 482
		) -- 482
		return -- 483
	end -- 483
	if talentId == "echo_wide" then -- 486
		drawReloadPatternGlyph( -- 488
			draw, -- 488
			cx, -- 488
			cy, -- 488
			r * 0.95, -- 488
			"echo", -- 488
			col, -- 488
			alpha -- 488
		) -- 488
		____exports.drawBrushArc( -- 489
			draw, -- 489
			cx, -- 489
			cy, -- 489
			r * 0.82, -- 489
			r * 0.82, -- 489
			-math.pi * 0.22, -- 489
			math.pi * 0.22, -- 489
			lw * 0.95, -- 489
			core, -- 489
			8 -- 489
		) -- 489
		____exports.drawBrushArc( -- 490
			draw, -- 490
			cx, -- 490
			cy, -- 490
			r * 0.82, -- 490
			r * 0.82, -- 490
			math.pi * 0.78, -- 490
			math.pi * 1.22, -- 490
			lw * 0.95, -- 490
			core, -- 490
			8 -- 490
		) -- 490
		return -- 491
	end -- 491
	if talentId == "lantern_pierce" then -- 494
		drawReloadPatternGlyph( -- 496
			draw, -- 496
			cx, -- 496
			cy, -- 496
			r * 0.95, -- 496
			"light", -- 496
			col, -- 496
			alpha -- 496
		) -- 496
		draw:drawRing( -- 497
			Vec2(cx, cy), -- 497
			r * 0.74, -- 497
			r * 0.82, -- 497
			Color(0, 0, 0, 0), -- 497
			lw * 0.85, -- 497
			core -- 497
		) -- 497
		return -- 498
	end -- 498
	if talentId == "guard" then -- 501
		____exports.drawBrushArc( -- 503
			draw, -- 503
			cx, -- 503
			cy - r * 0.1, -- 503
			r * 0.78, -- 503
			r * 0.62, -- 503
			math.pi * 0.12, -- 503
			math.pi * 0.88, -- 503
			lw * 1.35, -- 503
			stroke, -- 503
			12 -- 503
		) -- 503
		____exports.drawBrushArc( -- 504
			draw, -- 504
			cx, -- 504
			cy - r * 0.26, -- 504
			r * 0.58, -- 504
			r * 0.44, -- 504
			math.pi * 0.16, -- 504
			math.pi * 0.84, -- 504
			lw * 0.95, -- 504
			faint, -- 504
			10 -- 504
		) -- 504
		____exports.drawBrushArc( -- 506
			draw, -- 506
			cx - r * 0.22, -- 506
			cy - r * 0.04, -- 506
			r * 0.62, -- 506
			r * 0.62, -- 506
			math.pi * 0.72, -- 506
			math.pi * 1.32, -- 506
			lw * 1.1, -- 506
			core, -- 506
			10 -- 506
		) -- 506
		____exports.drawBrushArc( -- 507
			draw, -- 507
			cx + r * 0.22, -- 507
			cy - r * 0.04, -- 507
			r * 0.62, -- 507
			r * 0.62, -- 507
			-math.pi * 0.32, -- 507
			math.pi * 0.28, -- 507
			lw * 1.1, -- 507
			core, -- 507
			10 -- 507
		) -- 507
		drawDiamond( -- 509
			draw, -- 509
			cx, -- 509
			cy - r * 0.02, -- 509
			r * 0.22, -- 509
			r * 0.28, -- 509
			fill, -- 509
			lw, -- 509
			core -- 509
		) -- 509
		draw:drawSegment( -- 510
			Vec2(cx, cy - r * 0.36), -- 510
			Vec2(cx, cy - r * 0.76), -- 510
			lw * 0.95, -- 510
			faint -- 510
		) -- 510
		draw:drawDot( -- 511
			Vec2(cx, cy - r * 0.02), -- 511
			math.max(1.3, r * 0.09), -- 511
			core -- 511
		) -- 511
		return -- 512
	end -- 512
	if talentId == "craft" or talentId == "salvage" then -- 515
		draw:drawPolygon( -- 517
			{ -- 517
				Vec2(cx - r * 0.68, cy - r * 0.56), -- 518
				Vec2(cx + r * 0.36, cy - r * 0.56), -- 519
				Vec2(cx + r * 0.14, cy + r * 0.32), -- 520
				Vec2(cx - r * 0.44, cy + r * 0.32) -- 521
			}, -- 521
			fill, -- 522
			lw * 1.1, -- 522
			stroke -- 522
		) -- 522
		draw:drawSegment( -- 524
			Vec2(cx - r * 0.34, cy - r * 0.54), -- 524
			Vec2(cx - r * 0.14, cy + r * 0.3), -- 524
			lw * 0.8, -- 524
			faint -- 524
		) -- 524
		draw:drawSegment( -- 525
			Vec2(cx - r * 0.52, cy - r * 0.14), -- 525
			Vec2(cx + r * 0.24, cy - r * 0.14), -- 525
			lw * 0.75, -- 525
			faint -- 525
		) -- 525
		draw:drawPolygon( -- 527
			{ -- 527
				Vec2(cx - r * 0.42, cy + r * 0.14), -- 528
				Vec2(cx + r * 0.44, cy + r * 0.76), -- 529
				Vec2(cx + r * 0.62, cy + r * 0.58), -- 530
				Vec2(cx - r * 0.18, cy - r * 0.06) -- 531
			}, -- 531
			toColor(coreCol or PALETTE.amberCore, 52 * alpha), -- 532
			lw * 1.05, -- 532
			core -- 532
		) -- 532
		draw:drawSegment( -- 534
			Vec2(cx + r * 0.48, cy + r * 0.64), -- 534
			Vec2(cx + r * 0.8, cy + r * 0.84), -- 534
			lw * 1.65, -- 534
			stroke -- 534
		) -- 534
		draw:drawSegment( -- 536
			Vec2(cx - r * 0.66, cy + r * 0.52), -- 536
			Vec2(cx - r * 0.48, cy + r * 0.64), -- 536
			lw * 0.85, -- 536
			core -- 536
		) -- 536
		draw:drawSegment( -- 537
			Vec2(cx - r * 0.76, cy + r * 0.26), -- 537
			Vec2(cx - r * 0.6, cy + r * 0.34), -- 537
			lw * 0.75, -- 537
			faint -- 537
		) -- 537
		return -- 538
	end -- 538
	draw:drawPolygon( -- 542
		{ -- 542
			Vec2(cx - r * 0.34, cy + r * 0.76), -- 543
			Vec2(cx + r * 0.34, cy + r * 0.76), -- 544
			Vec2(cx + r * 0.34, cy - r * 0.46), -- 545
			Vec2(cx, cy - r * 0.84), -- 546
			Vec2(cx - r * 0.34, cy - r * 0.46) -- 547
		}, -- 547
		fill, -- 548
		lw * 1.1, -- 548
		stroke -- 548
	) -- 548
	draw:drawCircle( -- 549
		Vec2(cx, cy + r * 0.5), -- 549
		r * 0.11, -- 549
		toColor(PALETTE.panelBgDeep, 220 * alpha) -- 549
	) -- 549
	draw:drawRing( -- 550
		Vec2(cx, cy + r * 0.5), -- 550
		r * 0.08, -- 550
		r * 0.14, -- 550
		Color(0, 0, 0, 0), -- 550
		lw * 0.8, -- 550
		core -- 550
	) -- 550
	draw:drawSegment( -- 551
		Vec2(cx - r * 0.22, cy + r * 0.14), -- 551
		Vec2(cx + r * 0.22, cy + r * 0.14), -- 551
		lw * 0.9, -- 551
		core -- 551
	) -- 551
	draw:drawSegment( -- 552
		Vec2(cx - r * 0.22, cy - r * 0.12), -- 552
		Vec2(cx + r * 0.22, cy - r * 0.12), -- 552
		lw * 0.9, -- 552
		faint -- 552
	) -- 552
	draw:drawSegment( -- 553
		Vec2(cx - r * 0.16, cy - r * 0.36), -- 553
		Vec2(cx + r * 0.16, cy - r * 0.36), -- 553
		lw * 0.8, -- 553
		faint -- 553
	) -- 553
end -- 411
--- 绘制明初器物级战备/掉落物纹样（HUD 行囊条与 2.5D 世界掉落物 100% 同源）：
-- 8 类物资轮廓完全互异，取代原 props.ts 的「万物皆指南针」。
function ____exports.drawPickupGlyph(draw, cx, cy, radius, kind, alpha, overrideCol) -- 560
	if alpha == nil then -- 566
		alpha = 1 -- 566
	end -- 566
	local meta = ____exports.pickupMetaOf(kind) -- 569
	local col = overrideCol or meta.accent -- 570
	local core = overrideCol or meta.accentCore -- 571
	local r = math.max(4.5, radius) -- 572
	local lw = math.max(0.95, r * 0.12) -- 573
	local stroke = toColor(col, 240 * alpha) -- 574
	local hi = toColor(core, 248 * alpha) -- 575
	local fill = toColor(col, 68 * alpha) -- 576
	local darkFill = Color( -- 577
		20, -- 577
		18, -- 577
		22, -- 577
		math.floor(185 * alpha + 0.5) -- 577
	) -- 577
	if kind == "wood" then -- 579
		draw:drawPolygon( -- 581
			{ -- 581
				Vec2(cx - r * 0.36, cy + r * 0.82), -- 582
				Vec2(cx + r * 0.36, cy + r * 0.82), -- 583
				Vec2(cx + r * 0.36, cy - r * 0.64), -- 584
				Vec2(cx, cy - r * 0.9), -- 585
				Vec2(cx - r * 0.36, cy - r * 0.64) -- 586
			}, -- 586
			fill, -- 587
			lw * 1.1, -- 587
			hi -- 587
		) -- 587
		draw:drawDot( -- 588
			Vec2(cx, cy + r * 0.54), -- 588
			math.max(1.2, r * 0.12), -- 588
			darkFill -- 588
		) -- 588
		draw:drawSegment( -- 589
			Vec2(cx - r * 0.22, cy + r * 0.16), -- 589
			Vec2(cx + r * 0.22, cy + r * 0.16), -- 589
			lw * 0.9, -- 589
			hi -- 589
		) -- 589
		draw:drawSegment( -- 590
			Vec2(cx - r * 0.22, cy - r * 0.14), -- 590
			Vec2(cx + r * 0.22, cy - r * 0.14), -- 590
			lw * 0.9, -- 590
			stroke -- 590
		) -- 590
		draw:drawSegment( -- 591
			Vec2(cx - r * 0.14, cy - r * 0.42), -- 591
			Vec2(cx + r * 0.14, cy - r * 0.42), -- 591
			lw * 0.8, -- 591
			stroke -- 591
		) -- 591
		return -- 592
	end -- 592
	if kind == "bell" then -- 595
		drawReloadPatternGlyph( -- 597
			draw, -- 597
			cx, -- 597
			cy, -- 597
			r * 1.05, -- 597
			"echo", -- 597
			core, -- 597
			alpha -- 597
		) -- 597
		return -- 598
	end -- 598
	if kind == "shield" then -- 601
		draw:drawPolygon( -- 603
			{ -- 603
				Vec2(cx - r * 0.64, cy + r * 0.72), -- 604
				Vec2(cx + r * 0.64, cy + r * 0.72), -- 605
				Vec2(cx + r * 0.58, cy - r * 0.36), -- 606
				Vec2(cx, cy - r * 0.82), -- 607
				Vec2(cx - r * 0.58, cy - r * 0.36) -- 608
			}, -- 608
			fill, -- 609
			lw * 1.15, -- 609
			hi -- 609
		) -- 609
		draw:drawCircle( -- 610
			Vec2(cx, cy + r * 0.08), -- 610
			r * 0.2, -- 610
			hi -- 610
		) -- 610
		draw:drawSegment( -- 611
			Vec2(cx - r * 0.54, cy + r * 0.44), -- 611
			Vec2(cx - r * 0.2, cy + r * 0.22), -- 611
			lw * 0.8, -- 611
			darkFill -- 611
		) -- 611
		return -- 612
	end -- 612
	if kind == "wedge" then -- 615
		draw:drawPolygon( -- 617
			{ -- 617
				Vec2(cx - r * 0.78, cy - r * 0.46), -- 618
				Vec2(cx + r * 0.78, cy - r * 0.46), -- 619
				Vec2(cx + r * 0.44, cy + r * 0.52), -- 620
				Vec2(cx - r * 0.24, cy + r * 0.52) -- 621
			}, -- 621
			fill, -- 622
			lw * 1.15, -- 622
			hi -- 622
		) -- 622
		draw:drawSegment( -- 623
			Vec2(cx - r * 0.24, cy + r * 0.52), -- 623
			Vec2(cx - r * 0.12, cy - r * 0.46), -- 623
			lw * 0.9, -- 623
			hi -- 623
		) -- 623
		draw:drawSegment( -- 624
			Vec2(cx + r * 0.16, cy + r * 0.1), -- 624
			Vec2(cx + r * 0.46, cy + r * 0.1), -- 624
			lw * 0.75, -- 624
			stroke -- 624
		) -- 624
		return -- 625
	end -- 625
	if kind == "ammo" then -- 628
		draw:drawPolygon( -- 630
			{ -- 630
				Vec2(cx - r * 0.28, cy + r * 0.42), -- 631
				Vec2(cx + r * 0.28, cy + r * 0.42), -- 632
				Vec2(cx + r * 0.66, cy - r * 0.24), -- 633
				Vec2(cx + r * 0.44, cy - r * 0.76), -- 634
				Vec2(cx - r * 0.44, cy - r * 0.76), -- 635
				Vec2(cx - r * 0.66, cy - r * 0.24) -- 636
			}, -- 636
			fill, -- 637
			lw * 1.1, -- 637
			hi -- 637
		) -- 637
		draw:drawSegment( -- 639
			Vec2(cx - r * 0.38, cy + r * 0.4), -- 639
			Vec2(cx + r * 0.38, cy + r * 0.4), -- 639
			lw * 1.25, -- 639
			hi -- 639
		) -- 639
		draw:drawSegment( -- 640
			Vec2(cx - r * 0.22, cy + r * 0.42), -- 640
			Vec2(cx - r * 0.36, cy + r * 0.78), -- 640
			lw, -- 640
			stroke -- 640
		) -- 640
		draw:drawSegment( -- 641
			Vec2(cx + r * 0.22, cy + r * 0.42), -- 641
			Vec2(cx + r * 0.36, cy + r * 0.78), -- 641
			lw, -- 641
			stroke -- 641
		) -- 641
		draw:drawDot( -- 642
			Vec2(cx, cy - r * 0.22), -- 642
			math.max(1.4, r * 0.18), -- 642
			hi -- 642
		) -- 642
		return -- 643
	end -- 643
	if kind == "scrap" then -- 646
		draw:drawSegment( -- 648
			Vec2(cx - r * 0.74, cy - r * 0.48), -- 648
			Vec2(cx + r * 0.74, cy + r * 0.48), -- 648
			lw * 2.1, -- 648
			stroke -- 648
		) -- 648
		draw:drawSegment( -- 649
			Vec2(cx - r * 0.74, cy - r * 0.48), -- 649
			Vec2(cx + r * 0.74, cy + r * 0.48), -- 649
			lw * 0.9, -- 649
			hi -- 649
		) -- 649
		draw:drawSegment( -- 650
			Vec2(cx - r * 0.64, cy + r * 0.52), -- 650
			Vec2(cx + r * 0.64, cy - r * 0.52), -- 650
			lw * 2, -- 650
			stroke -- 650
		) -- 650
		draw:drawSegment( -- 651
			Vec2(cx - r * 0.64, cy + r * 0.52), -- 651
			Vec2(cx + r * 0.64, cy - r * 0.52), -- 651
			lw * 0.85, -- 651
			hi -- 651
		) -- 651
		return -- 652
	end -- 652
	if kind == "pass" then -- 655
		draw:drawPolygon( -- 657
			{ -- 657
				Vec2(cx - r * 0.46, cy + r * 0.42), -- 658
				Vec2(cx, cy + r * 0.82), -- 659
				Vec2(cx + r * 0.46, cy + r * 0.42), -- 660
				Vec2(cx + r * 0.46, cy - r * 0.46), -- 661
				Vec2(cx - r * 0.46, cy - r * 0.46) -- 662
			}, -- 662
			fill, -- 663
			lw * 1.1, -- 663
			hi -- 663
		) -- 663
		draw:drawSegment( -- 664
			Vec2(cx, cy - r * 0.46), -- 664
			Vec2(cx, cy - r * 0.88), -- 664
			lw, -- 664
			hi -- 664
		) -- 664
		draw:drawSegment( -- 665
			Vec2(cx - r * 0.16, cy - r * 0.66), -- 665
			Vec2(cx - r * 0.22, cy - r * 0.88), -- 665
			lw * 0.75, -- 665
			stroke -- 665
		) -- 665
		draw:drawSegment( -- 666
			Vec2(cx + r * 0.16, cy - r * 0.66), -- 666
			Vec2(cx + r * 0.22, cy - r * 0.88), -- 666
			lw * 0.75, -- 666
			stroke -- 666
		) -- 666
		drawDiamond( -- 667
			draw, -- 667
			cx, -- 667
			cy + r * 0.04, -- 667
			r * 0.16, -- 667
			r * 0.22, -- 667
			hi -- 667
		) -- 667
		return -- 668
	end -- 668
	if kind == "quickbelt" then -- 671
		draw:drawSegment( -- 673
			Vec2(cx - r * 0.78, cy - r * 0.66), -- 673
			Vec2(cx + r * 0.78, cy + r * 0.66), -- 673
			lw * 1.5, -- 673
			stroke -- 673
		) -- 673
		local k = -1 -- 674
		do -- 674
			k = -1 -- 675
			while k <= 1 do -- 675
				local tx = cx + k * r * 0.36 -- 676
				local ty = cy + k * r * 0.3 -- 677
				draw:drawRect( -- 678
					Rect(tx - r * 0.14, ty - r * 0.24, r * 0.28, r * 0.48), -- 678
					fill, -- 678
					lw * 0.9, -- 678
					hi -- 678
				) -- 678
				k = k + 1 -- 675
			end -- 675
		end -- 675
		return -- 680
	end -- 680
	drawDiamond( -- 683
		draw, -- 683
		cx, -- 683
		cy, -- 683
		r * 0.56, -- 683
		r * 0.56, -- 683
		fill, -- 683
		lw, -- 683
		hi -- 683
	) -- 683
end -- 560
--- 在 2.5D 世界舞台上绘制具有接触影、轻浮呼吸与明初轮廓的地面掉落物（供 props.ts 调用）。
function ____exports.drawWorldPickupVisual(fgDraw, fgGlow, cx, groundY, scalePx, kind, time, seedPhase) -- 689
	local meta = ____exports.pickupMetaOf(kind) -- 699
	local bob = math.sin(time * 2.8 + seedPhase) * 2.1 -- 700
	local iconY = groundY + scalePx * 0.88 + bob -- 701
	local r = math.max(6.5, scalePx * 0.62) -- 702
	local shScale = 1 - bob * 0.025 -- 705
	fgDraw:drawEllipse( -- 706
		Vec2(cx, groundY + 1.5), -- 706
		r * 0.95 * shScale, -- 706
		math.max(2.2, r * 0.3 * shScale), -- 706
		Color(6, 8, 12, 155) -- 706
	) -- 706
	local isBenchMat = kind == "wood" or kind == "bell" -- 709
	local glowA = isBenchMat and 36 + math.sin(time * 3.6 + seedPhase) * 10 or 22 -- 710
	fillRadialGlow( -- 711
		fgGlow, -- 712
		cx, -- 713
		iconY, -- 714
		r * (isBenchMat and 2.1 or 1.65), -- 715
		r * (isBenchMat and 2.1 or 1.65), -- 716
		toColor(meta.accentCore, glowA), -- 717
		Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 718
		12 -- 719
	) -- 719
	fgDraw:drawCircle( -- 723
		Vec2(cx, iconY), -- 723
		r * 1.06, -- 723
		Color(10, 12, 18, 150) -- 723
	) -- 723
	fgDraw:drawRing( -- 724
		Vec2(cx, iconY), -- 724
		r * 1.02, -- 724
		r * 1.14, -- 724
		Color(0, 0, 0, 0), -- 724
		0.9, -- 724
		toColor(meta.accent, isBenchMat and 175 or 120) -- 724
	) -- 724
	____exports.drawPickupGlyph( -- 726
		fgDraw, -- 726
		cx, -- 726
		iconY, -- 726
		r * 0.84, -- 726
		kind, -- 726
		0.98 -- 726
	) -- 726
end -- 689
return ____exports -- 689
