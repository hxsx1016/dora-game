-- [ts]: dialogues.ts
local ____exports = {} -- 1
--- 针套内折纸手书原词（T3 值夜室交物与片尾可辨读）
____exports.NEEDLE_NOTE_LINES = {"女童小满，托北塔收留。", "周戍"} -- 29
--- 全篇定稿对白表（D01–D65 + G06，兄妹关系 + 数到二十统一口径）
____exports.SCRIPT_DIALOGUES = { -- 35
	D30 = {id = "D30", who = "母亲", text = "小满，别点灯。听娘的话，起来。", duration = 2.8}, -- 37
	D31 = { -- 38
		id = "D31", -- 38
		who = "父亲", -- 38
		text = "把门顶上！小满——后屋，快走！", -- 38
		duration = 2.6, -- 38
		urgent = true -- 38
	}, -- 38
	D32 = {id = "D32", who = "小满", text = "爹？娘？", duration = 1.8}, -- 39
	D33 = { -- 40
		id = "D33", -- 40
		who = "袭城者", -- 40
		text = "里头还有喘气的。搜干净。", -- 40
		duration = 2.4, -- 40
		urgent = true -- 40
	}, -- 40
	D34 = {id = "D34", who = "小满", text = "……娘。", duration = 1.8}, -- 41
	D35 = {id = "D35", who = "周戍", text = "小满？小满，应一声。是哥。", duration = 2.8}, -- 44
	D36 = {id = "D36", who = "小满", text = "……哥？", duration = 1.8}, -- 45
	D01 = {id = "D01", who = "周戍", text = "是我，别怕。……这个沉，替我揣怀里。", duration = 3}, -- 48
	D02 = {id = "D02", who = "小满", text = "……你不走么？", duration = 2}, -- 49
	D03 = {id = "D03", who = "周戍", text = "我只有你了。起来，一道走。", duration = 2.8}, -- 50
	D37 = {id = "D37", who = "小满", text = "我听见娘叫我跑。", duration = 2.2}, -- 51
	D38 = {id = "D38", who = "周戍", text = "她叫得对。", duration = 2}, -- 52
	D57 = {id = "D57", who = "小满", text = "爹说过，这城墙是汤公带人筑的。", duration = 2.8}, -- 53
	D58 = {id = "D58", who = "周戍", text = "墙是死的，得有人守。", duration = 2.4}, -- 54
	D21 = {id = "D21", who = "小满", text = "……这是娘用的桶。早起才补的箍，还漏水呢。", duration = 3.2}, -- 57
	D22 = {id = "D22", who = "周戍", text = "认得。娘系桶，一直用红绳。", duration = 2.6}, -- 58
	D39 = {id = "D39", who = "周戍", text = "洗把手。哥在门口等你。", duration = 2.4}, -- 59
	D23 = { -- 62
		id = "D23", -- 62
		who = "袭城者", -- 62
		text = "外城都砸开了，剩你一个，还占着街口做甚？", -- 62
		duration = 3, -- 62
		urgent = true -- 62
	}, -- 62
	D24 = {id = "D24", who = "周戍", text = "里头还有人没走。", duration = 2.4}, -- 63
	D40 = {id = "D40", who = "小满", text = "哥，你手上有血。", duration = 2.2}, -- 64
	D41 = {id = "D41", who = "周戍", text = "不是我的。", duration = 2}, -- 65
	D04 = {id = "D04", who = "周戍", text = "瞧我。……好了，跟上。", duration = 2.4}, -- 66
	D05 = {id = "D05", who = "小满", text = "窗上那块木板……好像能落下来。", duration = 2.8}, -- 69
	D42 = {id = "D42", who = "周戍", text = "别听外头。跟着我走。", duration = 2.4}, -- 70
	D06 = {id = "D06", who = "小满", text = "没落下。", duration = 2}, -- 73
	C1A = {id = "C1A", who = "小满", text = "哥，这院子堵死了……", duration = 2.4}, -- 76
	C1B = {id = "C1B", who = "周戍", text = "绕栏后走。横闩在门背，我替你掀开。", duration = 2.8}, -- 77
	C1C = {id = "C1C", who = "周戍", text = "闩开了，紧跟我进粮棚。", duration = 2.2}, -- 78
	D07 = {id = "D07", who = "小满", text = "车轮压过这儿——你看，石槽磨亮了。", duration = 3}, -- 81
	D43 = {id = "D43", who = "周戍", text = "抓紧我衣角。车轮响，也别松手。", duration = 2.8}, -- 82
	D08 = {id = "D08", who = "周戍", text = "眼尖。走，闩起了。", duration = 2.4}, -- 83
	D09 = {id = "D09", who = "周戍", text = "站那根大柱后头去。门响了，也先莫探头。", duration = 3}, -- 86
	D44 = {id = "D44", who = "小满", text = "哥，门开了你先走。", duration = 2.2}, -- 87
	D45 = {id = "D45", who = "周戍", text = "门开了，你先走。", duration = 2.2}, -- 88
	D59 = {id = "D59", who = "小满", text = "这绞盘，爹也修过？", duration = 2.4}, -- 89
	D60 = {id = "D60", who = "周戍", text = "嗯。他教过我。", duration = 2.2}, -- 90
	D10 = {id = "D10", who = "小满", text = "你也出来呀。", duration = 2}, -- 93
	D11 = {id = "D11", who = "周戍", text = "门栓在里头，得有人落。小满，慢慢数到二十。哥要是还没出来，你就往北塔走。", duration = 4.2}, -- 94
	D25 = {id = "D25", who = "小满", text = "……要是中间数岔了呢？", duration = 2.2}, -- 95
	D26 = {id = "D26", who = "周戍", text = "顺着往下数，不许重头来。", duration = 2.4}, -- 96
	D12 = {id = "D12", who = "周戍", text = "到了塔下，敲两下门。把里头的字递进去。", duration = 3}, -- 97
	D46 = {id = "D46", who = "小满", text = "那你快点。", duration = 2}, -- 98
	D47 = {id = "D47", who = "周戍", text = "数慢一点。", duration = 2}, -- 99
	D61 = {id = "D61", who = "小满", text = "汤公把城筑得这么牢……", duration = 2.4}, -- 100
	D62 = {id = "D62", who = "周戍", text = "他筑的是墙。我守的是你。", duration = 2.8}, -- 101
	D13 = {id = "D13", who = "小满", text = "……二十了。我往北去了。", duration = 3.2}, -- 104
	D48 = {id = "D48", who = "周戍", text = "小满——别数了。", duration = 2.2}, -- 105
	D49 = {id = "D49", who = "小满", text = "哥！", duration = 1.6}, -- 106
	D50 = {id = "D50", who = "周戍", text = "走。一起往北。", duration = 2.4}, -- 107
	D51 = {id = "D51", who = "小满", text = "你的手在抖。", duration = 2.2}, -- 108
	D52 = {id = "D52", who = "周戍", text = "留着路上再抖。", duration = 2.4}, -- 109
	G06A = {id = "G06A", who = "小满", text = "去哪儿？", duration = 1.8}, -- 112
	G06B = {id = "G06B", who = "周戍", text = "北塔。你看，灯还亮着。", duration = 3}, -- 113
	D27 = {id = "D27", who = "拾荒者", text = "沟底下藏了谁？方才是你摔的瓦罐？", duration = 3}, -- 116
	D28 = {id = "D28", who = "小满", text = "你……见着我哥么？守城的，穿着青色号衣。", duration = 3}, -- 117
	D29 = {id = "D29", who = "拾荒者", text = "没见着。我进村那会儿，灶早就凉透了。", duration = 3.2}, -- 118
	D14 = {id = "D14", who = "守卒", text = "外头何人？", duration = 2}, -- 121
	D15 = {id = "D15", who = "小满", text = "我……城里出来的。", duration = 2.2}, -- 122
	D16 = {id = "D16", who = "守卒", text = "叫什么名？", duration = 2}, -- 123
	D17 = {id = "D17", who = "小满", text = "小满。", duration = 1.8}, -- 124
	D63 = {id = "D63", who = "守卒", text = "周？当年跟着信国公筑城的周家？", duration = 3}, -- 125
	D64 = {id = "D64", who = "小满", text = "我爹给他搬过石头。", duration = 2.4}, -- 126
	D18 = {id = "D18", who = "守卒", text = "送你出城那人呢？", duration = 2.2}, -- 127
	D19 = {id = "D19", who = "小满", text = "周戍。还在城门那头。", duration = 2.6}, -- 128
	D53 = {id = "D53", who = "守卒", text = "门外还有一位？", duration = 2.2}, -- 129
	D54 = {id = "D54", who = "小满", text = "我哥。门是他放下的。", duration = 2.6}, -- 130
	D20 = {id = "D20", who = "小满", text = "西窗上那盏灯……能留着么？", duration = 3.2}, -- 131
	D55 = {id = "D55", who = "小满", text = "哥，灯还亮着。", duration = 2.4}, -- 132
	D56 = {id = "D56", who = "周戍", text = "亮着。走过来就看得见。", duration = 2.6}, -- 133
	D65 = {id = "D65", who = "守卒", text = "信国公老了还往海边赶。你们走吧，灯我替你们看着。", duration = 3.8}, -- 134
	E1A = {id = "E1A", who = "小满", text = "哥，你的背好热。火铳声响的时候，我把脸埋进去就好。", duration = 3}, -- 137
	E1B = {id = "E1B", who = "周戍", text = "抱紧领口，莫松手。过了前头残坊就安静些。", duration = 2.8}, -- 138
	E2A = {id = "E2A", who = "小满", text = "粮棚里这铜铃声，听着像城门口挂的那一只。", duration = 2.8}, -- 139
	E2B = {id = "E2B", who = "周戍", text = "顺手收着。到山腰工台，哥替你把火铳再修稳些。", duration = 3}, -- 140
	E3A = {id = "E3A", who = "周戍", text = "先在干草席上坐会儿。风灯暖着，你歇一歇。", duration = 3}, -- 141
	E3B = {id = "E3B", who = "小满", text = "我不累。哥，你手上的灰我都看得见，慢些修。", duration = 2.8}, -- 142
	E3C = {id = "E3C", who = "小满", text = "响得好清亮！这回隔着远也能听见。", duration = 2.6}, -- 143
	E4A = {id = "E4A", who = "小满", text = "山风好大……北塔的屋檐我都看清楚了。", duration = 2.8}, -- 144
	E4B = {id = "E4B", who = "周戍", text = "快翻过这道窄崖了。抓牢，哥带你冲过去。", duration = 2.8}, -- 145
	E5A = {id = "E5A", who = "小满", text = "哥，天边泛白了——北塔的灯真的还亮着！", duration = 3}, -- 146
	E5B = {id = "E5B", who = "周戍", text = "亮着。穿过这道坡，咱们就能敲门了。", duration = 2.8}, -- 147
	O3_WIND = {id = "O3_WIND", who = "小满", text = "盐埂的风好冷……指南针还指着北，灯就在那头。", duration = 3.2}, -- 150
	F4_CREEK = {id = "F4_CREEK", who = "小满", text = "水里的那一点灯，和山坡上的是同一盏。", duration = 3.2}, -- 151
	OPT_PINWHEEL = {id = "OPT_PINWHEEL", who = "", text = "缺了一角的纸风车在墙影里旋成完整一圈，她伸指虚追半下便快步跟回兄长身侧。", duration = 3.4}, -- 154
	OPT_SHADOWDISC = {id = "OPT_SHADOWDISC", who = "", text = "影戏盘轻轻一转，墙上原本错开的两道人影缓缓合到了一处，并肩而立。", duration = 3.4}, -- 155
	OPT_SHELL = {id = "OPT_SHELL", who = "", text = "盐棚檐角的贝壳风铃随海风轻碰出两声脆响，像极了城门那两下暗号。", duration = 3.4}, -- 156
	OPT_NEEDLEBOX = {id = "OPT_NEEDLEBOX", who = "", text = "织房半开的窗台下放着旧针线匣，油灯暖黄的火苗静静照着半匹未织完的麻布。", duration = 3.4}, -- 157
	OPT_HOLLOW = {id = "OPT_HOLLOW", who = "", text = "拨开老松树洞口的干叶，里头安稳蜷着几枚干松果，风声在这里轻了一半。", duration = 3.2}, -- 158
	OPT_LANTERN = {id = "OPT_LANTERN", who = "", text = "扶正被晓风吹斜的旧风灯，灯焰稳了下来，她拢手在灯罩边暖了一瞬。", duration = 3.2} -- 159
} -- 159
--- 静音游玩方向性声效字幕（与实体动作/材质反馈互证）
____exports.MUTE_SFX_CAPTIONS = { -- 163
	knockTwo = "[两下轻敲]", -- 164
	knockReply = "[门内回叩]", -- 165
	brickClink = "[砖地脆响]", -- 166
	basinRing = "[铁盆余响]", -- 167
	twigSnap = "[枯枝脆响]", -- 168
	cartDock = "[车轮落窝]", -- 169
	boardDrop = "[窗板闷震]", -- 170
	latchOpen = "[横闩脱开]" -- 171
} -- 171
--- 片尾三张可选史话卡片（与 docs/向西守望-剧情与剧本.md 严格一致）
____exports.HISTORY_CARDS = {{ -- 175
	id = "fortress", -- 177
	indexZh = "其一", -- 178
	title = "海隅筑城", -- 179
	subtitle = "洪武海防 · 宁村所与信国公汤和", -- 180
	paragraphs = {"洪武年间，信国公汤和（1326—1395）以花甲之年奉诏经略东南海防。据《明史》载，他偕熟谙海事的方鸣谦勘察形胜，沿海筑卫所城五十有九、选兵戍守、立烽台候望，使戍卒长驻海滨。", "浙东温州海畔的宁村所便是其中一座。城外是他勘定的潮汐形胜，门里住的是奉诏安顿下的军户人家——一座座石头城墙落在潮声里，守的是江海，也护着墙内一户户寻常灶火。"}, -- 181
	footnote = "正史依据：《明史》卷一百二十六《汤和传》；地方建置记述：洪武十九至二十年（1386—1387）。" -- 185
}, { -- 185
	id = "hearth", -- 188
	indexZh = "其二", -- 189
	title = "井边烟火", -- 190
	subtitle = "浙东宁村所 · 十字街、古井与军户日常", -- 191
	paragraphs = {"浙东宁村所旧志里，记着十字街、老古井、兵房、水门与环城护城河，也记着一代代军户在墙内安家落户、垦田补网、白日晒网补桶、入夜登城望海的寻常日月。", "风浪与兵火起落有时，留在地名与残碑里的，往往是一口打水的井、一只补过箍的红绳木桶、一辆系着旧红布的木车，以及一件灯下还没缝完的粗布衣。"}, -- 192
	footnote = "本作人物周戍与小满为虚构军户兄妹，借海防器物与生活细部起兴，并非复原某一特定史事战例。" -- 196
}, { -- 196
	id = "lanterns", -- 199
	indexZh = "其三", -- 200
	title = "长灯不绝", -- 201
	subtitle = "温州汤和信俗 · 国家级非物质文化遗产", -- 202
	paragraphs = {"至嘉靖年间，沿海乡民已为汤和立庙奉祀；地方记述称宁村汤和庙始建于嘉靖七年（1528 年）。数百年来，祭祀、巡游、拦街福与拼字龙灯在龙湾一带代代相传。", "2008 年，「民间信俗（汤和信俗）」列入第二批国家级非物质文化遗产代表性项目名录（编号 X-85）。至今逢年过节，长龙在夜色里蜿蜒成「天下太平」四字——千灯照见的，仍是海边人家对一夜安稳最朴素的盼望。"}, -- 203
	footnote = "愿每一扇向西敞开的窗台，都能等到归来的人。" -- 207
}} -- 207
function ____exports.dialogueById(id) -- 211
	return ____exports.SCRIPT_DIALOGUES[id] -- 212
end -- 211
return ____exports -- 211