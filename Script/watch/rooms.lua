-- [ts]: rooms.ts
local ____exports = {} -- 1
____exports.ROOM_CHECKPOINT = { -- 84
	id = "checkpoint", -- 85
	name = "检查站 · 灰盒", -- 86
	caption = "点射 → 小满躲柜台 → 恐惧三格 → E 敲两下安抚 → 按住 E 推车到装卸台 → 门洞交接", -- 87
	minX = 0, -- 88
	maxX = 33, -- 89
	height = 6, -- 90
	spawns = {{x = 1, label = "小满出生"}, {x = 2.6, label = "周戍出生"}}, -- 91
	solids = {{x = 8, w = 2.4, h = 1, label = "柜台 1.0m"}, {x = 19.2, w = 1.2, h = 0.9, label = "矮墙 0.9m"}, {x = 30.6, w = 1.4, h = 4, label = "城门墙"}}, -- 95
	zones = {{ -- 100
		x0 = 13, -- 101
		x1 = 17, -- 101
		h = 3, -- 101
		label = "敌人触发区", -- 101
		tint = 1 -- 101
	}, { -- 101
		x0 = 26.4, -- 102
		x1 = 29.4, -- 102
		h = 0.12, -- 102
		label = "装卸台", -- 102
		tint = 2 -- 102
	}}, -- 102
	cart = { -- 104
		startX = 23, -- 104
		endX = 27.5, -- 104
		bodyW = 1.6, -- 104
		bodyH = 0.55, -- 104
		wheelR = 0.25, -- 104
		handleH = 0.95 -- 104
	}, -- 104
	hole = {x = 0, w = 0, h = 0, label = ""}, -- 105
	gates = {{x = 29.5, w = 2.2, h = 3.2, label = "城门洞 2.2m"}}, -- 106
	marks = {{x = 21, label = "检查点", kind = 0}, {x = 29, label = "周戍侧", kind = 1}, {x = 30.8, label = "小满侧", kind = 1}, {x = 31.9, label = "双人出口", kind = 2}}, -- 107
	dims = {{x0 = 8, x1 = 10.4, text = "柜台 2.4m / 高 1.0m"}, {x0 = 23, x1 = 27.5, text = "推车 4.5m（按住 E + D）"}, {x0 = 27.5, x1 = 29.5, text = "车心距门 2.0m"}} -- 113
} -- 113
____exports.ROOM_OUTSIDE = { -- 120
	id = "outside", -- 121
	name = "城墙外 · 灰盒", -- 122
	caption = "认出左端红布 → 按住 E 拉车 1.0m → 车轮落窝 → S/Ctrl 蹲下钻低洞 → 洞后检查点", -- 123
	minX = -2.2, -- 124
	maxX = 26, -- 125
	height = 6, -- 126
	spawns = {{x = 1.4, label = "小满出生（刚接过控制权）"}}, -- 127
	solids = {}, -- 128
	zones = {{ -- 129
		x0 = -0.2, -- 130
		x1 = 5, -- 130
		h = 0.12, -- 130
		label = "装卸台", -- 130
		tint = 2 -- 130
	}, { -- 130
		x0 = 8, -- 131
		x1 = 12, -- 131
		h = 0.12, -- 131
		label = "北路口", -- 131
		tint = 2 -- 131
	}}, -- 131
	cart = { -- 133
		startX = 2.4, -- 133
		endX = 1.4, -- 133
		bodyW = 1.6, -- 133
		bodyH = 0.55, -- 133
		wheelR = 0.25, -- 133
		handleH = 0.95 -- 133
	}, -- 133
	hole = {x = 2.8, w = 1.1, h = 0.78, label = "低洞 0.78m"}, -- 134
	gates = {{x = -0.4, w = 2, h = 3.2, label = "大门（已落下）"}}, -- 135
	marks = {{x = 5.2, label = "洞后检查点", kind = 0}, {x = 11, label = "塔灯方向", kind = 3}}, -- 136
	dims = {{x0 = 1.6, x1 = 3.2, text = "车体 1.6m（起点挡住半个洞）"}, {x0 = 1.4, x1 = 2.4, text = "拉车 1.0m / 约 2.0s"}, {x0 = 2.8, x1 = 3.9, text = "洞宽 1.1m / 高 0.78m"}} -- 140
} -- 140
____exports.ROOMS = {____exports.ROOM_CHECKPOINT, ____exports.ROOM_OUTSIDE} -- 147
return ____exports -- 147