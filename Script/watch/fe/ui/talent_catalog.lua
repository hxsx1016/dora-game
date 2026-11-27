-- [ts]: talent_catalog.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 14
local Color = ____Dora.Color -- 14
local Rect = ____Dora.Rect -- 14
local Vec2 = ____Dora.Vec2 -- 14
local ____run = require("Script.watch.run") -- 15
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
____exports.registerTalentVisual({ -- 85
	id = "vitality", -- 86
	title = TALENT_CATALOG.vitality.title, -- 87
	category = TALENT_CATALOG.vitality.branchZh, -- 88
	accent = PALETTE.cyan, -- 89
	accentCore = PALETTE.moonPale, -- 90
	whisper = "「再重些，背上的人便稳些。」", -- 91
	absorbTarget = "hp", -- 92
	shortEffect = function(____, snap) return (("体力上限 " .. tostring(snap.maxHp)) .. " → ") .. tostring(snap.maxHp + 1) end, -- 93
	subEffect = function() return "并即刻回气 +1" end, -- 94
	ledgerLine = function(____, snap, rank) return ((((("体力上限 +" .. tostring(rank)) .. "（现 ") .. tostring(snap.hp)) .. "/") .. tostring(snap.maxHp)) .. "）" end -- 95
}) -- 95
____exports.registerTalentVisual({ -- 98
	id = "guard", -- 99
	title = TALENT_CATALOG.guard.title, -- 100
	category = TALENT_CATALOG.guard.branchZh, -- 101
	accent = PALETTE.emerald, -- 102
	accentCore = PALETTE.moonPale, -- 103
	whisper = "「挨了这一记，步子不能乱。」", -- 104
	absorbTarget = "shoulder", -- 105
	shortEffect = function(____, snap) return ((("护身 " .. tostring(snap.invulnTicksNow)) .. " → ") .. tostring(snap.invulnTicksNow + 15)) .. " 拍" end, -- 106
	subEffect = function() return "受击多得喘息窗 (+15 拍) · 翻滚避近战" end, -- 107
	ledgerLine = function(____, snap, rank) return ((("受击保护 " .. tostring(snap.invulnTicksNow)) .. " 拍（加 ") .. tostring(rank * 15)) .. " 拍）" end -- 108
}) -- 108
____exports.registerTalentVisual({ -- 111
	id = "stride", -- 112
	title = TALENT_CATALOG.stride.title, -- 113
	category = TALENT_CATALOG.stride.branchZh, -- 114
	accent = PALETTE.cyan, -- 115
	accentCore = PALETTE.cyanCore, -- 116
	whisper = "「步子稳且快，早些见着北塔灯。」", -- 117
	absorbTarget = "shoulder", -- 118
	shortEffect = function(____, _snap, curRank) return ("背负步速 +" .. tostring((curRank + 1) * 10)) .. "%" end, -- 119
	subEffect = function() return "翻滚突围更疾 · 与回声铳相合" end, -- 120
	ledgerLine = function(____, _snap, rank) return ((("背负步速 +" .. tostring(rank * 10)) .. "% · 翻滚 +") .. tostring(rank * 8)) .. "%" end -- 121
}) -- 121
____exports.registerTalentVisual({ -- 124
	id = "focus", -- 125
	title = TALENT_CATALOG.focus.title, -- 126
	category = TALENT_CATALOG.focus.branchZh, -- 127
	accent = PALETTE.amber, -- 128
	accentCore = PALETTE.amberCore, -- 129
	whisper = "「稳住气息，慢时连线从容不迫。」", -- 130
	absorbTarget = "gun", -- 131
	shortEffect = function(____, _snap, curRank) return ("慢时换弹线盘 +" .. tostring(curRank + 1)) .. " 秒" end, -- 132
	subEffect = function() return "连线窗口 +60 拍 · 与引路灯铳相合" end, -- 133
	ledgerLine = function(____, _snap, rank) return ((("换弹连线窗口 +" .. tostring(rank)) .. " 秒（+") .. tostring(rank * 60)) .. " 拍）" end -- 134
}) -- 134
____exports.registerTalentVisual({ -- 137
	id = "push_force", -- 138
	title = TALENT_CATALOG.push_force.title, -- 139
	category = TALENT_CATALOG.push_force.branchZh, -- 140
	accent = PALETTE.rouge, -- 141
	accentCore = PALETTE.amberCore, -- 142
	whisper = "「一铳破盾，逼退围拢之敌。」", -- 143
	absorbTarget = "gun", -- 144
	shortEffect = function(____, _snap, curRank) return ("破盾加伤 · 邻近震退（" .. ____exports.rankChinese(curRank + 1)) .. "重）" end, -- 145
	subEffect = function() return "推退连线重挫盾面并压缓举铳" end, -- 146
	ledgerLine = function(____, _snap, rank) return ("推退破盾与震退强化（" .. ____exports.rankChinese(rank)) .. "阶）" end -- 147
}) -- 147
____exports.registerTalentVisual({ -- 150
	id = "echo_wide", -- 151
	title = TALENT_CATALOG.echo_wide.title, -- 152
	category = TALENT_CATALOG.echo_wide.branchZh, -- 153
	accent = PALETTE.cyan, -- 154
	accentCore = PALETTE.cyanCore, -- 155
	whisper = "「铜铃传巷远，群寇皆回首。」", -- 156
	absorbTarget = "gun", -- 157
	shortEffect = function(____, _snap, curRank) return ("回声多惊 +" .. tostring(curRank + 1)) .. " 敌 · 延后开火" end, -- 158
	subEffect = function() return "铃纹连线扩域 · 与回声铳共鸣" end, -- 159
	ledgerLine = function(____, _snap, rank) return ((("回声多惊 +" .. tostring(rank)) .. " 敌 · 延缓举铳 +") .. tostring(rank * 30)) .. " 拍" end -- 160
}) -- 160
____exports.registerTalentVisual({ -- 163
	id = "lantern_pierce", -- 164
	title = TALENT_CATALOG.lantern_pierce.title, -- 165
	category = TALENT_CATALOG.lantern_pierce.branchZh, -- 166
	accent = PALETTE.amberCore, -- 167
	accentCore = PALETTE.textBright, -- 168
	whisper = "「灯火一明，夜巷尽收眼底。」", -- 169
	absorbTarget = "gun", -- 170
	shortEffect = function(____, _snap, curRank) return "灯纹必起光晕 · 照域 +" .. tostring((curRank + 1) * 50) end, -- 171
	subEffect = function() return "镇住旁侧敌兵 · 与引路灯铳共鸣" end, -- 172
	ledgerLine = function(____, _snap, rank) return "灯纹光晕镇敌 · 半径 +" .. tostring(rank * 50) end -- 173
}) -- 173
____exports.registerTalentVisual({ -- 176
	id = "salvage", -- 177
	title = TALENT_CATALOG.salvage.title, -- 178
	category = TALENT_CATALOG.salvage.branchZh, -- 179
	accent = PALETTE.amber, -- 180
	accentCore = PALETTE.amberCore, -- 181
	whisper = "「沿途收齐筹料，盾楔多撑一记。」", -- 182
	absorbTarget = "satchel", -- 183
	shortEffect = function() return "即得紧缺筹料 +1 · 盾楔加厚" end, -- 184
	subEffect = function() return "便携残盾与野战木楔耐受增强" end, -- 185
	ledgerLine = function(____, _snap, rank) return ("拾料补筹 · 架盾与立楔多承 +" .. tostring(rank)) .. " 击" end -- 186
}) -- 186
function ____exports.resolveTalentVisual(id, snap) -- 189
	local reg = TALENT_REGISTRY[id] -- 190
	if reg ~= nil then -- 190
		return reg -- 192
	end -- 192
	local hint = snap ~= nil and snap.talentLabelHints[id] or nil or talentNames[id] or id -- 194
	local dotIdx = (string.find(hint, "·", nil, true) or 0) - 1 -- 197
	local parsedTitle = dotIdx > 0 and __TS__StringSlice(hint, 0, dotIdx) or hint -- 198
	local parsedDesc = dotIdx > 0 and __TS__StringSlice(hint, dotIdx + 1) or "行军备策 · 增益一阶" -- 199
	return { -- 200
		id = id, -- 201
		title = parsedTitle ~= "" and parsedTitle or "军筹", -- 202
		category = "军筹", -- 203
		accent = PALETTE.jadeMist, -- 204
		accentCore = PALETTE.textBright, -- 205
		whisper = "「夜路漫漫，多备一筹总安心。」", -- 206
		absorbTarget = "crest", -- 207
		shortEffect = function() return parsedDesc end, -- 208
		subEffect = function(____, _s, curRank) return ((("现 " .. ____exports.rankChinese(curRank)) .. " → ") .. ____exports.rankChinese(curRank + 1)) .. " 阶" end, -- 209
		ledgerLine = function(____, _s, rank) return ((parsedDesc .. "（") .. ____exports.rankChinese(rank)) .. " 阶）" end -- 210
	} -- 210
end -- 189
local WEAPON_META = {standard_gun = { -- 214
	id = "standard_gun", -- 216
	name = "标准鸟铳", -- 217
	shortName = "鸟铳", -- 218
	effect = "normal", -- 219
	accent = PALETTE.silkLine, -- 220
	desc = "九宫连线蓄推退、铃纹、灯纹" -- 221
}, guide_lantern_gun = { -- 221
	id = "guide_lantern_gun", -- 224
	name = "引路灯铳", -- 225
	shortName = "灯铳", -- 226
	effect = "light", -- 227
	accent = PALETTE.amberCore, -- 228
	desc = "强化灯纹破夜光晕镇敌" -- 229
}, echo_gun = { -- 229
	id = "echo_gun", -- 232
	name = "回声铜铃铳", -- 233
	shortName = "回声铳", -- 234
	effect = "echo", -- 235
	accent = PALETTE.cyanCore, -- 236
	desc = "强化铃纹双响回声诱敌" -- 237
}, time_shuttler = { -- 237
	id = "time_shuttler", -- 240
	name = "时间穿梭器", -- 241
	shortName = "穿梭器", -- 242
	effect = "knockback", -- 243
	accent = PALETTE.amberCore, -- 244
	desc = "双线归档旧物，冷白残影" -- 245
}} -- 245
function ____exports.weaponMetaOf(weaponId) -- 249
	return WEAPON_META[weaponId] or WEAPON_META.standard_gun -- 250
end -- 249
____exports.PICKUP_ORDER = { -- 253
	"wood", -- 254
	"bell", -- 255
	"shield", -- 256
	"wedge", -- 257
	"ammo", -- 258
	"scrap", -- 259
	"pass", -- 260
	"quickbelt" -- 261
} -- 261
local PICKUP_META = { -- 264
	wood = { -- 265
		kind = "wood", -- 265
		name = "木纹筹", -- 265
		shortName = "木筹", -- 265
		accent = PALETTE.amber, -- 265
		accentCore = PALETTE.amberCore, -- 265
		category = "material" -- 265
	}, -- 265
	bell = { -- 266
		kind = "bell", -- 266
		name = "铃纹筹", -- 266
		shortName = "铃筹", -- 266
		accent = PALETTE.amberCore, -- 266
		accentCore = PALETTE.amberCore, -- 266
		category = "material" -- 266
	}, -- 266
	shield = { -- 267
		kind = "shield", -- 267
		name = "残盾", -- 267
		shortName = "残盾", -- 267
		accent = PALETTE.cyan, -- 267
		accentCore = PALETTE.cyanCore, -- 267
		category = "gear" -- 267
	}, -- 267
	wedge = { -- 268
		kind = "wedge", -- 268
		name = "木楔", -- 268
		shortName = "木楔", -- 268
		accent = PALETTE.emerald, -- 268
		accentCore = PALETTE.moonPale, -- 268
		category = "gear" -- 268
	}, -- 268
	ammo = { -- 269
		kind = "ammo", -- 269
		name = "备用弹包", -- 269
		shortName = "弹包", -- 269
		accent = PALETTE.rouge, -- 269
		accentCore = PALETTE.crimsonCore, -- 269
		category = "gear" -- 269
	}, -- 269
	scrap = { -- 270
		kind = "scrap", -- 270
		name = "废木料", -- 270
		shortName = "木料", -- 270
		accent = PALETTE.amberDim, -- 270
		accentCore = PALETTE.amber, -- 270
		category = "material" -- 270
	}, -- 270
	pass = { -- 271
		kind = "pass", -- 271
		name = "护送号牌", -- 271
		shortName = "号牌", -- 271
		accent = PALETTE.jadeMist, -- 271
		accentCore = PALETTE.textBright, -- 271
		category = "gear" -- 271
	}, -- 271
	quickbelt = { -- 272
		kind = "quickbelt", -- 272
		name = "快装带", -- 272
		shortName = "装带", -- 272
		accent = PALETTE.amber, -- 272
		accentCore = PALETTE.amberCore, -- 272
		category = "gear" -- 272
	} -- 272
} -- 272
function ____exports.pickupMetaOf(kind) -- 275
	return PICKUP_META[kind] or ({ -- 276
		kind = kind, -- 277
		name = kind, -- 278
		shortName = kind, -- 279
		accent = PALETTE.silkLine, -- 280
		accentCore = PALETTE.textBright, -- 281
		category = "gear" -- 282
	}) -- 282
end -- 275
--- 按当前已习本领、所持火铳与战备派生纯前端「行军雅号」（零后端侵入）。
function ____exports.deriveMarchTitle(snap) -- 287
	local vit = snap.ranks.vitality or 0 -- 288
	local rel = (snap.ranks.reload or 0) + (snap.ranks.focus or 0) -- 289
	local grd = snap.ranks.guard or 0 -- 290
	local str = snap.ranks.stride or 0 -- 291
	local psh = snap.ranks.push_force or 0 -- 292
	local ech = snap.ranks.echo_wide or 0 -- 293
	local lnt = snap.ranks.lantern_pierce or 0 -- 294
	local crf = (snap.ranks.craft or 0) + (snap.ranks.salvage or 0) -- 295
	local total = snap.totalRanks -- 296
	local weapon = snap.equippedWeapon -- 297
	local wedge = snap.supplies.wedge or 0 -- 298
	if total <= 0 then -- 298
		return { -- 301
			title = "初启北行", -- 301
			sealTop = "守", -- 301
			sealBot = "望", -- 301
			subtitle = "行囊初整，孤灯在前", -- 301
			accent = PALETTE.silkLine -- 301
		} -- 301
	end -- 301
	if (rel >= 2 or lnt >= 2) and weapon == "guide_lantern_gun" then -- 301
		return { -- 304
			title = "明火疾铳", -- 304
			sealTop = "明", -- 304
			sealBot = "火", -- 304
			subtitle = "灯影破夜，火绳如电", -- 304
			accent = PALETTE.amberCore -- 304
		} -- 304
	end -- 304
	if (rel >= 2 or ech >= 2) and weapon == "echo_gun" then -- 304
		return { -- 307
			title = "惊铃连响", -- 307
			sealTop = "惊", -- 307
			sealBot = "铃", -- 307
			subtitle = "铜铃惑敌，连发不断", -- 307
			accent = PALETTE.cyanCore -- 307
		} -- 307
	end -- 307
	if vit + grd >= 3 and vit >= 1 and grd >= 1 then -- 307
		return { -- 310
			title = "铁壁断后", -- 310
			sealTop = "铁", -- 310
			sealBot = "壁", -- 310
			subtitle = "重甲护身，步履不乱", -- 310
			accent = PALETTE.cyan -- 310
		} -- 310
	end -- 310
	if crf >= 2 or crf >= 1 and wedge >= 1 then -- 310
		return { -- 313
			title = "巧楔筑垒", -- 313
			sealTop = "巧", -- 313
			sealBot = "楔", -- 313
			subtitle = "削木固掩，以巧破险", -- 313
			accent = PALETTE.emerald -- 313
		} -- 313
	end -- 313
	if lnt >= 2 then -- 313
		return { -- 316
			title = "镇雾孤灯", -- 316
			sealTop = "明", -- 316
			sealBot = "灯", -- 316
			subtitle = "余明破暗，镇敌于前", -- 316
			accent = PALETTE.amberCore -- 316
		} -- 316
	end -- 316
	if psh >= 2 then -- 316
		return { -- 319
			title = "破盾劲铳", -- 319
			sealTop = "劲", -- 319
			sealBot = "推", -- 319
			subtitle = "一铳撼盾，寸步不让", -- 319
			accent = PALETTE.rouge -- 319
		} -- 319
	end -- 319
	if ech >= 2 then -- 319
		return { -- 322
			title = "广音惑寇", -- 322
			sealTop = "广", -- 322
			sealBot = "音", -- 322
			subtitle = "铃声远扬，步步生机", -- 322
			accent = PALETTE.cyanCore -- 322
		} -- 322
	end -- 322
	if str >= 2 then -- 322
		return { -- 325
			title = "踏风负行", -- 325
			sealTop = "疾", -- 325
			sealBot = "步", -- 325
			subtitle = "肩背疾行，直趋北塔", -- 325
			accent = PALETTE.cyan -- 325
		} -- 325
	end -- 325
	if rel >= 2 then -- 325
		return { -- 328
			title = "疾火连铳", -- 328
			sealTop = "疾", -- 328
			sealBot = "铳", -- 328
			subtitle = "熟手快装，火线不绝", -- 328
			accent = PALETTE.amber -- 328
		} -- 328
	end -- 328
	if vit >= 2 then -- 328
		return { -- 331
			title = "重甲负行", -- 331
			sealTop = "重", -- 331
			sealBot = "甲", -- 331
			subtitle = "铁衣加身，稳背同行", -- 331
			accent = PALETTE.cyan -- 331
		} -- 331
	end -- 331
	if grd >= 2 then -- 331
		return { -- 334
			title = "稳步护势", -- 334
			sealTop = "护", -- 334
			sealBot = "身", -- 334
			subtitle = "身法从容，危中留隙", -- 334
			accent = PALETTE.emerald -- 334
		} -- 334
	end -- 334
	return { -- 336
		title = "孤城守望", -- 336
		sealTop = "守", -- 336
		sealBot = "望", -- 336
		subtitle = "诸筹兼备，护她北归", -- 336
		accent = PALETTE.rouge -- 336
	} -- 336
end -- 287
--- 内部工具：用短折线绘制清秀明式弧线（兼容所有缩放与灰度）。
function ____exports.drawBrushArc(draw, cx, cy, rx, ry, startRad, endRad, thickness, color, segments) -- 340
	if segments == nil then -- 340
		segments = 14 -- 350
	end -- 350
	local n = math.max(4, segments) -- 352
	local prevX = cx + math.cos(startRad) * rx -- 353
	local prevY = cy + math.sin(startRad) * ry -- 354
	local i = 1 -- 355
	do -- 355
		i = 1 -- 356
		while i <= n do -- 356
			local a = startRad + (endRad - startRad) * i / n -- 357
			local nx = cx + math.cos(a) * rx -- 358
			local ny = cy + math.sin(a) * ry -- 359
			draw:drawSegment( -- 360
				Vec2(prevX, prevY), -- 360
				Vec2(nx, ny), -- 360
				thickness, -- 360
				color -- 360
			) -- 360
			prevX = nx -- 361
			prevY = ny -- 362
			i = i + 1 -- 356
		end -- 356
	end -- 356
end -- 340
--- 绘制明初器物工笔本领纹样（纯 DrawNode 矢量，静音与灰度下轮廓 100% 互异）：
-- - vitality：明式叠鳞札甲 + 居中圆形护心镜
-- - reload：明式鸟铳龙头火绳弯钩 + 药池微星
-- - guard：明式云肩披膊 + 双向卸力偏锋弧
-- - craft：削木短刀 + 梯形木楔契口
-- - fallback：明代卫所竖式军筹木简
function ____exports.drawTalentGlyph(draw, cx, cy, radius, talentId, col, alpha, coreCol) -- 374
	if alpha == nil then -- 374
		alpha = 1 -- 381
	end -- 381
	local r = math.max(5, radius) -- 384
	local lw = math.max(1, r * 0.085) -- 385
	local stroke = toColor(col, 240 * alpha) -- 386
	local core = toColor(coreCol or PALETTE.textBright, 245 * alpha) -- 387
	local faint = toColor(col, 125 * alpha) -- 388
	local fill = toColor(col, 38 * alpha) -- 389
	if talentId == "vitality" then -- 389
		draw:drawPolygon( -- 393
			{ -- 393
				Vec2(cx - r * 0.72, cy + r * 0.66), -- 394
				Vec2(cx - r * 0.28, cy + r * 0.82), -- 395
				Vec2(cx + r * 0.28, cy + r * 0.82), -- 396
				Vec2(cx + r * 0.72, cy + r * 0.66), -- 397
				Vec2(cx + r * 0.64, cy - r * 0.26), -- 398
				Vec2(cx, cy - r * 0.84), -- 399
				Vec2(cx - r * 0.64, cy - r * 0.26) -- 400
			}, -- 400
			fill, -- 401
			lw * 1.1, -- 401
			stroke -- 401
		) -- 401
		draw:drawSegment( -- 403
			Vec2(cx - r * 0.62, cy + r * 0.22), -- 403
			Vec2(cx + r * 0.62, cy + r * 0.22), -- 403
			lw * 0.8, -- 403
			faint -- 403
		) -- 403
		draw:drawSegment( -- 404
			Vec2(cx - r * 0.56, cy - r * 0.24), -- 404
			Vec2(cx + r * 0.56, cy - r * 0.24), -- 404
			lw * 0.8, -- 404
			faint -- 404
		) -- 404
		draw:drawSegment( -- 406
			Vec2(cx - r * 0.3, cy - r * 0.52), -- 406
			Vec2(cx - r * 0.34, cy + r * 0.68), -- 406
			lw * 0.7, -- 406
			faint -- 406
		) -- 406
		draw:drawSegment( -- 407
			Vec2(cx + r * 0.3, cy - r * 0.52), -- 407
			Vec2(cx + r * 0.34, cy + r * 0.68), -- 407
			lw * 0.7, -- 407
			faint -- 407
		) -- 407
		draw:drawCircle( -- 409
			Vec2(cx, cy + r * 0.04), -- 409
			r * 0.32, -- 409
			toColor(PALETTE.panelBgDeep, 210 * alpha) -- 409
		) -- 409
		draw:drawRing( -- 410
			Vec2(cx, cy + r * 0.04), -- 410
			r * 0.26, -- 410
			r * 0.34, -- 410
			Color(0, 0, 0, 0), -- 410
			lw, -- 410
			core -- 410
		) -- 410
		draw:drawDot( -- 411
			Vec2(cx, cy + r * 0.04), -- 411
			math.max(1.4, r * 0.11), -- 411
			core -- 411
		) -- 411
		return -- 412
	end -- 412
	if talentId == "reload" or talentId == "focus" then -- 412
		draw:drawSegment( -- 417
			Vec2(cx - r * 0.82, cy - r * 0.54), -- 417
			Vec2(cx + r * 0.82, cy + r * 0.34), -- 417
			lw * 1.45, -- 417
			stroke -- 417
		) -- 417
		draw:drawSegment( -- 418
			Vec2(cx - r * 0.76, cy - r * 0.68), -- 418
			Vec2(cx + r * 0.22, cy - r * 0.14), -- 418
			lw * 1, -- 418
			faint -- 418
		) -- 418
		draw:drawSegment( -- 419
			Vec2(cx - r * 0.16, cy - r * 0.2), -- 419
			Vec2(cx - r * 0.26, cy + r * 0.32), -- 419
			lw * 1.15, -- 419
			core -- 419
		) -- 419
		draw:drawSegment( -- 420
			Vec2(cx - r * 0.26, cy + r * 0.32), -- 420
			Vec2(cx + r * 0.16, cy + r * 0.56), -- 420
			lw * 1.15, -- 420
			core -- 420
		) -- 420
		draw:drawSegment( -- 421
			Vec2(cx + r * 0.16, cy + r * 0.56), -- 421
			Vec2(cx + r * 0.38, cy + r * 0.36), -- 421
			lw * 1.05, -- 421
			core -- 421
		) -- 421
		local sx = cx + r * 0.44 -- 422
		local sy = cy + r * 0.34 -- 423
		drawDiamond( -- 424
			draw, -- 424
			sx, -- 424
			sy, -- 424
			r * 0.17, -- 424
			r * 0.17, -- 424
			core -- 424
		) -- 424
		draw:drawSegment( -- 425
			Vec2(sx - r * 0.28, sy), -- 425
			Vec2(sx + r * 0.28, sy), -- 425
			lw * 0.75, -- 425
			core -- 425
		) -- 425
		draw:drawSegment( -- 426
			Vec2(sx, sy - r * 0.28), -- 426
			Vec2(sx, sy + r * 0.28), -- 426
			lw * 0.75, -- 426
			core -- 426
		) -- 426
		draw:drawSegment( -- 427
			Vec2(cx - r * 0.82, cy - r * 0.54), -- 427
			Vec2(cx - r * 0.9, cy - r * 0.76), -- 427
			lw * 1.2, -- 427
			stroke -- 427
		) -- 427
		return -- 428
	end -- 428
	if talentId == "stride" then -- 428
		draw:drawSegment( -- 433
			Vec2(cx - r * 0.78, cy + r * 0.38), -- 433
			Vec2(cx + r * 0.24, cy + r * 0.38), -- 433
			lw * 1.35, -- 433
			stroke -- 433
		) -- 433
		draw:drawSegment( -- 434
			Vec2(cx - r * 0.18, cy + r * 0.7), -- 434
			Vec2(cx + r * 0.32, cy + r * 0.38), -- 434
			lw * 1.25, -- 434
			core -- 434
		) -- 434
		draw:drawSegment( -- 435
			Vec2(cx - r * 0.48, cy - r * 0.12), -- 435
			Vec2(cx + r * 0.78, cy - r * 0.12), -- 435
			lw * 1.45, -- 435
			stroke -- 435
		) -- 435
		draw:drawSegment( -- 436
			Vec2(cx + r * 0.24, cy + r * 0.2), -- 436
			Vec2(cx + r * 0.8, cy - r * 0.12), -- 436
			lw * 1.3, -- 436
			core -- 436
		) -- 436
		draw:drawSegment( -- 437
			Vec2(cx + r * 0.24, cy - r * 0.44), -- 437
			Vec2(cx + r * 0.8, cy - r * 0.12), -- 437
			lw * 1.3, -- 437
			core -- 437
		) -- 437
		draw:drawSegment( -- 438
			Vec2(cx - r * 0.76, cy - r * 0.48), -- 438
			Vec2(cx - r * 0.08, cy - r * 0.48), -- 438
			lw * 0.9, -- 438
			faint -- 438
		) -- 438
		return -- 439
	end -- 439
	if talentId == "push_force" then -- 439
		drawReloadPatternGlyph( -- 444
			draw, -- 444
			cx, -- 444
			cy, -- 444
			r * 0.95, -- 444
			"knockback", -- 444
			col, -- 444
			alpha -- 444
		) -- 444
		____exports.drawBrushArc( -- 445
			draw, -- 445
			cx - r * 0.1, -- 445
			cy, -- 445
			r * 0.72, -- 445
			r * 0.68, -- 445
			-math.pi * 0.36, -- 445
			math.pi * 0.36, -- 445
			lw * 1.15, -- 445
			core, -- 445
			10 -- 445
		) -- 445
		return -- 446
	end -- 446
	if talentId == "echo_wide" then -- 446
		drawReloadPatternGlyph( -- 451
			draw, -- 451
			cx, -- 451
			cy, -- 451
			r * 0.95, -- 451
			"echo", -- 451
			col, -- 451
			alpha -- 451
		) -- 451
		____exports.drawBrushArc( -- 452
			draw, -- 452
			cx, -- 452
			cy, -- 452
			r * 0.82, -- 452
			r * 0.82, -- 452
			-math.pi * 0.22, -- 452
			math.pi * 0.22, -- 452
			lw * 0.95, -- 452
			core, -- 452
			8 -- 452
		) -- 452
		____exports.drawBrushArc( -- 453
			draw, -- 453
			cx, -- 453
			cy, -- 453
			r * 0.82, -- 453
			r * 0.82, -- 453
			math.pi * 0.78, -- 453
			math.pi * 1.22, -- 453
			lw * 0.95, -- 453
			core, -- 453
			8 -- 453
		) -- 453
		return -- 454
	end -- 454
	if talentId == "lantern_pierce" then -- 454
		drawReloadPatternGlyph( -- 459
			draw, -- 459
			cx, -- 459
			cy, -- 459
			r * 0.95, -- 459
			"light", -- 459
			col, -- 459
			alpha -- 459
		) -- 459
		draw:drawRing( -- 460
			Vec2(cx, cy), -- 460
			r * 0.74, -- 460
			r * 0.82, -- 460
			Color(0, 0, 0, 0), -- 460
			lw * 0.85, -- 460
			core -- 460
		) -- 460
		return -- 461
	end -- 461
	if talentId == "guard" then -- 461
		____exports.drawBrushArc( -- 466
			draw, -- 466
			cx, -- 466
			cy - r * 0.1, -- 466
			r * 0.78, -- 466
			r * 0.62, -- 466
			math.pi * 0.12, -- 466
			math.pi * 0.88, -- 466
			lw * 1.35, -- 466
			stroke, -- 466
			12 -- 466
		) -- 466
		____exports.drawBrushArc( -- 467
			draw, -- 467
			cx, -- 467
			cy - r * 0.26, -- 467
			r * 0.58, -- 467
			r * 0.44, -- 467
			math.pi * 0.16, -- 467
			math.pi * 0.84, -- 467
			lw * 0.95, -- 467
			faint, -- 467
			10 -- 467
		) -- 467
		____exports.drawBrushArc( -- 469
			draw, -- 469
			cx - r * 0.22, -- 469
			cy - r * 0.04, -- 469
			r * 0.62, -- 469
			r * 0.62, -- 469
			math.pi * 0.72, -- 469
			math.pi * 1.32, -- 469
			lw * 1.1, -- 469
			core, -- 469
			10 -- 469
		) -- 469
		____exports.drawBrushArc( -- 470
			draw, -- 470
			cx + r * 0.22, -- 470
			cy - r * 0.04, -- 470
			r * 0.62, -- 470
			r * 0.62, -- 470
			-math.pi * 0.32, -- 470
			math.pi * 0.28, -- 470
			lw * 1.1, -- 470
			core, -- 470
			10 -- 470
		) -- 470
		drawDiamond( -- 472
			draw, -- 472
			cx, -- 472
			cy - r * 0.02, -- 472
			r * 0.22, -- 472
			r * 0.28, -- 472
			fill, -- 472
			lw, -- 472
			core -- 472
		) -- 472
		draw:drawSegment( -- 473
			Vec2(cx, cy - r * 0.36), -- 473
			Vec2(cx, cy - r * 0.76), -- 473
			lw * 0.95, -- 473
			faint -- 473
		) -- 473
		draw:drawDot( -- 474
			Vec2(cx, cy - r * 0.02), -- 474
			math.max(1.3, r * 0.09), -- 474
			core -- 474
		) -- 474
		return -- 475
	end -- 475
	if talentId == "craft" or talentId == "salvage" then -- 475
		draw:drawPolygon( -- 480
			{ -- 480
				Vec2(cx - r * 0.68, cy - r * 0.56), -- 481
				Vec2(cx + r * 0.36, cy - r * 0.56), -- 482
				Vec2(cx + r * 0.14, cy + r * 0.32), -- 483
				Vec2(cx - r * 0.44, cy + r * 0.32) -- 484
			}, -- 484
			fill, -- 485
			lw * 1.1, -- 485
			stroke -- 485
		) -- 485
		draw:drawSegment( -- 487
			Vec2(cx - r * 0.34, cy - r * 0.54), -- 487
			Vec2(cx - r * 0.14, cy + r * 0.3), -- 487
			lw * 0.8, -- 487
			faint -- 487
		) -- 487
		draw:drawSegment( -- 488
			Vec2(cx - r * 0.52, cy - r * 0.14), -- 488
			Vec2(cx + r * 0.24, cy - r * 0.14), -- 488
			lw * 0.75, -- 488
			faint -- 488
		) -- 488
		draw:drawPolygon( -- 490
			{ -- 490
				Vec2(cx - r * 0.42, cy + r * 0.14), -- 491
				Vec2(cx + r * 0.44, cy + r * 0.76), -- 492
				Vec2(cx + r * 0.62, cy + r * 0.58), -- 493
				Vec2(cx - r * 0.18, cy - r * 0.06) -- 494
			}, -- 494
			toColor(coreCol or PALETTE.amberCore, 52 * alpha), -- 495
			lw * 1.05, -- 495
			core -- 495
		) -- 495
		draw:drawSegment( -- 497
			Vec2(cx + r * 0.48, cy + r * 0.64), -- 497
			Vec2(cx + r * 0.8, cy + r * 0.84), -- 497
			lw * 1.65, -- 497
			stroke -- 497
		) -- 497
		draw:drawSegment( -- 499
			Vec2(cx - r * 0.66, cy + r * 0.52), -- 499
			Vec2(cx - r * 0.48, cy + r * 0.64), -- 499
			lw * 0.85, -- 499
			core -- 499
		) -- 499
		draw:drawSegment( -- 500
			Vec2(cx - r * 0.76, cy + r * 0.26), -- 500
			Vec2(cx - r * 0.6, cy + r * 0.34), -- 500
			lw * 0.75, -- 500
			faint -- 500
		) -- 500
		return -- 501
	end -- 501
	draw:drawPolygon( -- 505
		{ -- 505
			Vec2(cx - r * 0.34, cy + r * 0.76), -- 506
			Vec2(cx + r * 0.34, cy + r * 0.76), -- 507
			Vec2(cx + r * 0.34, cy - r * 0.46), -- 508
			Vec2(cx, cy - r * 0.84), -- 509
			Vec2(cx - r * 0.34, cy - r * 0.46) -- 510
		}, -- 510
		fill, -- 511
		lw * 1.1, -- 511
		stroke -- 511
	) -- 511
	draw:drawCircle( -- 512
		Vec2(cx, cy + r * 0.5), -- 512
		r * 0.11, -- 512
		toColor(PALETTE.panelBgDeep, 220 * alpha) -- 512
	) -- 512
	draw:drawRing( -- 513
		Vec2(cx, cy + r * 0.5), -- 513
		r * 0.08, -- 513
		r * 0.14, -- 513
		Color(0, 0, 0, 0), -- 513
		lw * 0.8, -- 513
		core -- 513
	) -- 513
	draw:drawSegment( -- 514
		Vec2(cx - r * 0.22, cy + r * 0.14), -- 514
		Vec2(cx + r * 0.22, cy + r * 0.14), -- 514
		lw * 0.9, -- 514
		core -- 514
	) -- 514
	draw:drawSegment( -- 515
		Vec2(cx - r * 0.22, cy - r * 0.12), -- 515
		Vec2(cx + r * 0.22, cy - r * 0.12), -- 515
		lw * 0.9, -- 515
		faint -- 515
	) -- 515
	draw:drawSegment( -- 516
		Vec2(cx - r * 0.16, cy - r * 0.36), -- 516
		Vec2(cx + r * 0.16, cy - r * 0.36), -- 516
		lw * 0.8, -- 516
		faint -- 516
	) -- 516
end -- 374
--- 绘制明初器物级战备/掉落物纹样（HUD 行囊条与 2.5D 世界掉落物 100% 同源）：
-- 8 类物资轮廓完全互异，取代原 props.ts 的「万物皆指南针」。
function ____exports.drawPickupGlyph(draw, cx, cy, radius, kind, alpha, overrideCol) -- 523
	if alpha == nil then -- 523
		alpha = 1 -- 529
	end -- 529
	local meta = ____exports.pickupMetaOf(kind) -- 532
	local col = overrideCol or meta.accent -- 533
	local core = overrideCol or meta.accentCore -- 534
	local r = math.max(4.5, radius) -- 535
	local lw = math.max(0.95, r * 0.12) -- 536
	local stroke = toColor(col, 240 * alpha) -- 537
	local hi = toColor(core, 248 * alpha) -- 538
	local fill = toColor(col, 68 * alpha) -- 539
	local darkFill = Color( -- 540
		20, -- 540
		18, -- 540
		22, -- 540
		math.floor(185 * alpha + 0.5) -- 540
	) -- 540
	if kind == "wood" then -- 540
		draw:drawPolygon( -- 544
			{ -- 544
				Vec2(cx - r * 0.36, cy + r * 0.82), -- 545
				Vec2(cx + r * 0.36, cy + r * 0.82), -- 546
				Vec2(cx + r * 0.36, cy - r * 0.64), -- 547
				Vec2(cx, cy - r * 0.9), -- 548
				Vec2(cx - r * 0.36, cy - r * 0.64) -- 549
			}, -- 549
			fill, -- 550
			lw * 1.1, -- 550
			hi -- 550
		) -- 550
		draw:drawDot( -- 551
			Vec2(cx, cy + r * 0.54), -- 551
			math.max(1.2, r * 0.12), -- 551
			darkFill -- 551
		) -- 551
		draw:drawSegment( -- 552
			Vec2(cx - r * 0.22, cy + r * 0.16), -- 552
			Vec2(cx + r * 0.22, cy + r * 0.16), -- 552
			lw * 0.9, -- 552
			hi -- 552
		) -- 552
		draw:drawSegment( -- 553
			Vec2(cx - r * 0.22, cy - r * 0.14), -- 553
			Vec2(cx + r * 0.22, cy - r * 0.14), -- 553
			lw * 0.9, -- 553
			stroke -- 553
		) -- 553
		draw:drawSegment( -- 554
			Vec2(cx - r * 0.14, cy - r * 0.42), -- 554
			Vec2(cx + r * 0.14, cy - r * 0.42), -- 554
			lw * 0.8, -- 554
			stroke -- 554
		) -- 554
		return -- 555
	end -- 555
	if kind == "bell" then -- 555
		drawReloadPatternGlyph( -- 560
			draw, -- 560
			cx, -- 560
			cy, -- 560
			r * 1.05, -- 560
			"echo", -- 560
			core, -- 560
			alpha -- 560
		) -- 560
		return -- 561
	end -- 561
	if kind == "shield" then -- 561
		draw:drawPolygon( -- 566
			{ -- 566
				Vec2(cx - r * 0.64, cy + r * 0.72), -- 567
				Vec2(cx + r * 0.64, cy + r * 0.72), -- 568
				Vec2(cx + r * 0.58, cy - r * 0.36), -- 569
				Vec2(cx, cy - r * 0.82), -- 570
				Vec2(cx - r * 0.58, cy - r * 0.36) -- 571
			}, -- 571
			fill, -- 572
			lw * 1.15, -- 572
			hi -- 572
		) -- 572
		draw:drawCircle( -- 573
			Vec2(cx, cy + r * 0.08), -- 573
			r * 0.2, -- 573
			hi -- 573
		) -- 573
		draw:drawSegment( -- 574
			Vec2(cx - r * 0.54, cy + r * 0.44), -- 574
			Vec2(cx - r * 0.2, cy + r * 0.22), -- 574
			lw * 0.8, -- 574
			darkFill -- 574
		) -- 574
		return -- 575
	end -- 575
	if kind == "wedge" then -- 575
		draw:drawPolygon( -- 580
			{ -- 580
				Vec2(cx - r * 0.78, cy - r * 0.46), -- 581
				Vec2(cx + r * 0.78, cy - r * 0.46), -- 582
				Vec2(cx + r * 0.44, cy + r * 0.52), -- 583
				Vec2(cx - r * 0.24, cy + r * 0.52) -- 584
			}, -- 584
			fill, -- 585
			lw * 1.15, -- 585
			hi -- 585
		) -- 585
		draw:drawSegment( -- 586
			Vec2(cx - r * 0.24, cy + r * 0.52), -- 586
			Vec2(cx - r * 0.12, cy - r * 0.46), -- 586
			lw * 0.9, -- 586
			hi -- 586
		) -- 586
		draw:drawSegment( -- 587
			Vec2(cx + r * 0.16, cy + r * 0.1), -- 587
			Vec2(cx + r * 0.46, cy + r * 0.1), -- 587
			lw * 0.75, -- 587
			stroke -- 587
		) -- 587
		return -- 588
	end -- 588
	if kind == "ammo" then -- 588
		draw:drawPolygon( -- 593
			{ -- 593
				Vec2(cx - r * 0.28, cy + r * 0.42), -- 594
				Vec2(cx + r * 0.28, cy + r * 0.42), -- 595
				Vec2(cx + r * 0.66, cy - r * 0.24), -- 596
				Vec2(cx + r * 0.44, cy - r * 0.76), -- 597
				Vec2(cx - r * 0.44, cy - r * 0.76), -- 598
				Vec2(cx - r * 0.66, cy - r * 0.24) -- 599
			}, -- 599
			fill, -- 600
			lw * 1.1, -- 600
			hi -- 600
		) -- 600
		draw:drawSegment( -- 602
			Vec2(cx - r * 0.38, cy + r * 0.4), -- 602
			Vec2(cx + r * 0.38, cy + r * 0.4), -- 602
			lw * 1.25, -- 602
			hi -- 602
		) -- 602
		draw:drawSegment( -- 603
			Vec2(cx - r * 0.22, cy + r * 0.42), -- 603
			Vec2(cx - r * 0.36, cy + r * 0.78), -- 603
			lw, -- 603
			stroke -- 603
		) -- 603
		draw:drawSegment( -- 604
			Vec2(cx + r * 0.22, cy + r * 0.42), -- 604
			Vec2(cx + r * 0.36, cy + r * 0.78), -- 604
			lw, -- 604
			stroke -- 604
		) -- 604
		draw:drawDot( -- 605
			Vec2(cx, cy - r * 0.22), -- 605
			math.max(1.4, r * 0.18), -- 605
			hi -- 605
		) -- 605
		return -- 606
	end -- 606
	if kind == "scrap" then -- 606
		draw:drawSegment( -- 611
			Vec2(cx - r * 0.74, cy - r * 0.48), -- 611
			Vec2(cx + r * 0.74, cy + r * 0.48), -- 611
			lw * 2.1, -- 611
			stroke -- 611
		) -- 611
		draw:drawSegment( -- 612
			Vec2(cx - r * 0.74, cy - r * 0.48), -- 612
			Vec2(cx + r * 0.74, cy + r * 0.48), -- 612
			lw * 0.9, -- 612
			hi -- 612
		) -- 612
		draw:drawSegment( -- 613
			Vec2(cx - r * 0.64, cy + r * 0.52), -- 613
			Vec2(cx + r * 0.64, cy - r * 0.52), -- 613
			lw * 2, -- 613
			stroke -- 613
		) -- 613
		draw:drawSegment( -- 614
			Vec2(cx - r * 0.64, cy + r * 0.52), -- 614
			Vec2(cx + r * 0.64, cy - r * 0.52), -- 614
			lw * 0.85, -- 614
			hi -- 614
		) -- 614
		return -- 615
	end -- 615
	if kind == "pass" then -- 615
		draw:drawPolygon( -- 620
			{ -- 620
				Vec2(cx - r * 0.46, cy + r * 0.42), -- 621
				Vec2(cx, cy + r * 0.82), -- 622
				Vec2(cx + r * 0.46, cy + r * 0.42), -- 623
				Vec2(cx + r * 0.46, cy - r * 0.46), -- 624
				Vec2(cx - r * 0.46, cy - r * 0.46) -- 625
			}, -- 625
			fill, -- 626
			lw * 1.1, -- 626
			hi -- 626
		) -- 626
		draw:drawSegment( -- 627
			Vec2(cx, cy - r * 0.46), -- 627
			Vec2(cx, cy - r * 0.88), -- 627
			lw, -- 627
			hi -- 627
		) -- 627
		draw:drawSegment( -- 628
			Vec2(cx - r * 0.16, cy - r * 0.66), -- 628
			Vec2(cx - r * 0.22, cy - r * 0.88), -- 628
			lw * 0.75, -- 628
			stroke -- 628
		) -- 628
		draw:drawSegment( -- 629
			Vec2(cx + r * 0.16, cy - r * 0.66), -- 629
			Vec2(cx + r * 0.22, cy - r * 0.88), -- 629
			lw * 0.75, -- 629
			stroke -- 629
		) -- 629
		drawDiamond( -- 630
			draw, -- 630
			cx, -- 630
			cy + r * 0.04, -- 630
			r * 0.16, -- 630
			r * 0.22, -- 630
			hi -- 630
		) -- 630
		return -- 631
	end -- 631
	if kind == "quickbelt" then -- 631
		draw:drawSegment( -- 636
			Vec2(cx - r * 0.78, cy - r * 0.66), -- 636
			Vec2(cx + r * 0.78, cy + r * 0.66), -- 636
			lw * 1.5, -- 636
			stroke -- 636
		) -- 636
		local k = -1 -- 637
		do -- 637
			k = -1 -- 638
			while k <= 1 do -- 638
				local tx = cx + k * r * 0.36 -- 639
				local ty = cy + k * r * 0.3 -- 640
				draw:drawRect( -- 641
					Rect(tx - r * 0.14, ty - r * 0.24, r * 0.28, r * 0.48), -- 641
					fill, -- 641
					lw * 0.9, -- 641
					hi -- 641
				) -- 641
				k = k + 1 -- 638
			end -- 638
		end -- 638
		return -- 643
	end -- 643
	drawDiamond( -- 646
		draw, -- 646
		cx, -- 646
		cy, -- 646
		r * 0.56, -- 646
		r * 0.56, -- 646
		fill, -- 646
		lw, -- 646
		hi -- 646
	) -- 646
end -- 523
--- 在 2.5D 世界舞台上绘制具有接触影、轻浮呼吸与明初轮廓的地面掉落物（供 props.ts 调用）。
function ____exports.drawWorldPickupVisual(fgDraw, fgGlow, cx, groundY, scalePx, kind, time, seedPhase) -- 652
	local meta = ____exports.pickupMetaOf(kind) -- 662
	local bob = math.sin(time * 2.8 + seedPhase) * 2.1 -- 663
	local iconY = groundY + scalePx * 0.88 + bob -- 664
	local r = math.max(6.5, scalePx * 0.62) -- 665
	local shScale = 1 - bob * 0.025 -- 668
	fgDraw:drawEllipse( -- 669
		Vec2(cx, groundY + 1.5), -- 669
		r * 0.95 * shScale, -- 669
		math.max(2.2, r * 0.3 * shScale), -- 669
		Color(6, 8, 12, 155) -- 669
	) -- 669
	local isBenchMat = kind == "wood" or kind == "bell" -- 672
	local glowA = isBenchMat and 36 + math.sin(time * 3.6 + seedPhase) * 10 or 22 -- 673
	fillRadialGlow( -- 674
		fgGlow, -- 675
		cx, -- 676
		iconY, -- 677
		r * (isBenchMat and 2.1 or 1.65), -- 678
		r * (isBenchMat and 2.1 or 1.65), -- 679
		toColor(meta.accentCore, glowA), -- 680
		Color(meta.accent.r, meta.accent.g, meta.accent.b, 0), -- 681
		12 -- 682
	) -- 682
	fgDraw:drawCircle( -- 686
		Vec2(cx, iconY), -- 686
		r * 1.06, -- 686
		Color(10, 12, 18, 150) -- 686
	) -- 686
	fgDraw:drawRing( -- 687
		Vec2(cx, iconY), -- 687
		r * 1.02, -- 687
		r * 1.14, -- 687
		Color(0, 0, 0, 0), -- 687
		0.9, -- 687
		toColor(meta.accent, isBenchMat and 175 or 120) -- 687
	) -- 687
	____exports.drawPickupGlyph( -- 689
		fgDraw, -- 689
		cx, -- 689
		iconY, -- 689
		r * 0.84, -- 689
		kind, -- 689
		0.98 -- 689
	) -- 689
end -- 652
return ____exports -- 652