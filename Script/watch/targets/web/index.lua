-- [ts]: index.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____depth = require("Script.watch.depth") -- 9
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 9
local ____aim_assist = require("Script.watch.input.aim_assist") -- 10
local collectPlayAimTargets = ____aim_assist.collectPlayAimTargets -- 10
local collectTrialAimTargets = ____aim_assist.collectTrialAimTargets -- 10
local ____gamepad_core = require("Script.watch.input.gamepad_core") -- 11
local GamepadRouter = ____gamepad_core.GamepadRouter -- 11
local ____kbm_core = require("Script.watch.input.kbm_core") -- 12
local KbmPoller = ____kbm_core.KbmPoller -- 12
local ____touch_core = require("Script.watch.input.touch_core") -- 13
local TouchRouter = ____touch_core.TouchRouter -- 13
local ____touch_hud_landscape = require("Script.watch.input.touch_hud_landscape") -- 14
local TouchControls = ____touch_hud_landscape.TouchControls -- 14
local ____touch_hud_portrait = require("Script.watch.input.touch_hud_portrait") -- 15
local PORTRAIT_TOUCH_DELEGATE = ____touch_hud_portrait.PORTRAIT_TOUCH_DELEGATE -- 15
local ____play_prompts = require("Script.watch.fe.ui.play_prompts") -- 16
local isCutsceneBlockingPlay = ____play_prompts.isCutsceneBlockingPlay -- 16
local ____platform_mobile = require("Script.watch.platform_mobile") -- 17
local computeAdaptiveViewport = ____platform_mobile.computeAdaptiveViewport -- 17
local triggerMobileHaptics = ____platform_mobile.triggerMobileHaptics -- 17
local ____controls_config = require("Script.watch.controls_config") -- 18
local MODE_PREF_ORDER = ____controls_config.MODE_PREF_ORDER -- 19
local TOUCH_OPACITY_STEPS = ____controls_config.TOUCH_OPACITY_STEPS -- 20
local TOUCH_SCALE_STEPS = ____controls_config.TOUCH_SCALE_STEPS -- 21
local applyVolumeSetting = ____controls_config.applyVolumeSetting -- 22
local inputModeLabelOf = ____controls_config.inputModeLabelOf -- 23
local layoutLabelOf = ____controls_config.layoutLabelOf -- 24
local modePrefLabelOf = ____controls_config.modePrefLabelOf -- 25
local nextStepValue = ____controls_config.nextStepValue -- 26
local opacityLabelOf = ____controls_config.opacityLabelOf -- 27
local saveControlSettings = ____controls_config.saveControlSettings -- 28
local scaleLabelOf = ____controls_config.scaleLabelOf -- 29
local volumeSettingText = ____controls_config.volumeSettingText -- 30
local ____target_types = require("Script.watch.target_types") -- 33
local getReleaseConfig = ____target_types.getReleaseConfig -- 46
local WEB_SETTINGS_ROWS = { -- 49
	{id = "modePref", title = "操作模式"}, -- 50
	{id = "aimAssist", title = "瞄准磁吸"}, -- 51
	{id = "gpLayout", title = "手柄确认键"}, -- 52
	{id = "crouchMode", title = "手柄蹲伏方式"}, -- 53
	{id = "touchOpacity", title = "触控按键透度"}, -- 54
	{id = "touchScale", title = "触控按键大小"}, -- 55
	{id = "haptics", title = "触觉震动反馈"}, -- 56
	{id = "masterVol", title = "主音量"}, -- 57
	{id = "bgmVol", title = "音乐音量"}, -- 58
	{id = "sfxVol", title = "音效与环境"}, -- 59
	{id = "voiceVol", title = "人声音量"}, -- 60
	{id = "back", title = "返回暂歇菜单"} -- 61
} -- 61
local GUIDE_KBM = {subtitle = "键鼠操作说明 · 全平台通用", soldierRows = { -- 64
	{"WASD / 方向键", "左右、前后纵深自由移动"}, -- 67
	{"鼠标 + 左键 / Q", "瞄准发射火铳 · Q 随时开换弹盘"}, -- 68
	{"按住 SHIFT / SPACE", "贴靠掩体挡弹 · 平地翻滚或翻越"}, -- 69
	{"E / 1·2·3", "交互推车工台 · 数字键选护送本领"}, -- 70
	{"拖线 / 方向+回车", "慢时 3×3 换弹盘 · 右键/退格重画"}, -- 71
	{"ESC / R / T", "暂歇菜单 / 重试检查点 / 切神器"} -- 72
}, childRows = { -- 74
	{"A / D · ← / →", "左右潜行"}, -- 75
	{"按住 SHIFT", "轻步慢走（压低脚步声）"}, -- 76
	{"按住 S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 77
	{"SPACE", "跳跃攀上石阶与矮台"}, -- 78
	{"E", "拾瓶 / 敲塔门 / 按住+D 拉车"}, -- 79
	{"F 按住→松开", "瞄准砖地/铁盆投瓶 · 右键取消"} -- 80
}} -- 80
local GUIDE_GAMEPAD = {subtitle = "手柄操作说明 · 全平台通用", soldierRows = { -- 84
	{"左摇杆 / 十字键", "左右、前后纵深移动"}, -- 87
	{"右摇杆 + RT / X", "360° 瞄准与发射火铳（含轻磁吸）"}, -- 88
	{"按住 LT / LB", "贴靠柜台 / 街垒挡下铅丸"}, -- 89
	{"A 键", "平地翻滚 / 靠近矮柜翻越"}, -- 90
	{"Y / RB 键", "递物 / 轻敲安抚 / 按住推车"}, -- 91
	{"摇杆直推 / 触屏", "慢时连线换弹 · B 键清空重画"} -- 92
}, childRows = { -- 94
	{"左摇杆轻推", "内圈轻步慢走（LT/LB 亦可）"}, -- 95
	{"B 键", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 96
	{"A 键", "跳跃攀上石阶与矮台"}, -- 97
	{"Y / RB 键", "拾瓶 / 敲塔门 / 握柄拉车"}, -- 98
	{"RT/X 按住→松开", "右摇杆调落点投瓶 · B 取消"}, -- 99
	{"START / BACK", "暂歇 / 长按重试 · L3 切神器"} -- 100
}} -- 100
local GUIDE_TOUCH = {subtitle = "触屏操作说明 · 横屏全屏 / 竖屏掌机台", soldierRows = { -- 104
	{"左水墨摇杆", "全向走位与里外道切线"}, -- 107
	{"点屏 / 开火钮", "直点射击或拖住开火钮 360° 精瞄"}, -- 108
	{"掩体开关", "轻点贴靠掩体，再点或翻滚离掩"}, -- 109
	{"翻滚 / 翻越", "平地翻滚，贴近矮柜自动翻越"}, -- 110
	{"交互 / 推车", "点推车自动锁握柄，长按牵手交物"}, -- 111
	{"换弹九宫格", "单指一笔滑连至右上，点重画清空"} -- 112
}, childRows = { -- 114
	{"摇杆内圈 / 轻步", "轻推内圈或点轻步压低脚步声"}, -- 115
	{"蹲伏开关", "点按蹲下钻桌穿拱，点跳顺滑起身"}, -- 116
	{"跳跃钮", "攀上石阶、红布车与矮台"}, -- 117
	{"投瓶拖瞄", "按住投瓶拖向砖地，拖回取消圈放弃"}, -- 118
	{"交互 / 拉车", "拾瓶、敲塔门、点拉车锁定握柄"}, -- 119
	{"右上暂歇 / 竖屏", "顶栏随时暂歇，竖屏自动展掌机台"} -- 120
}} -- 120
local function keyTagWeb(action, mode, layout) -- 124
	if mode == "gamepad" then -- 125
		local confirmBtn = layout == "nintendo" and "B" or "A" -- 126
		local backBtn = layout == "nintendo" and "A" or "B" -- 127
		if action == "interact" then -- 128
			return "Y / RB" -- 128
		end -- 128
		if action == "jump" then -- 129
			return "A" -- 129
		end -- 129
		if action == "crouch" then -- 130
			return "B" -- 130
		end -- 130
		if action == "cover" then -- 131
			return "LT / LB" -- 131
		end -- 131
		if action == "fire" then -- 132
			return "RT / X" -- 132
		end -- 132
		if action == "aim" then -- 133
			return "RT / X" -- 133
		end -- 133
		if action == "pause" then -- 134
			return "START" -- 134
		end -- 134
		if action == "retry" then -- 135
			return "长按 BACK" -- 135
		end -- 135
		if action == "confirm" then -- 136
			return confirmBtn -- 136
		end -- 136
		if action == "back" then -- 137
			return backBtn -- 137
		end -- 137
		return "L3" -- 138
	end -- 138
	if mode == "touch" then -- 140
		if action == "interact" then -- 141
			return "点按" -- 141
		end -- 141
		if action == "jump" then -- 142
			return "跳/滚" -- 142
		end -- 142
		if action == "crouch" then -- 143
			return "蹲伏" -- 143
		end -- 143
		if action == "cover" then -- 144
			return "掩体" -- 144
		end -- 144
		if action == "fire" then -- 145
			return "开火" -- 145
		end -- 145
		if action == "aim" then -- 146
			return "拖投瓶" -- 146
		end -- 146
		if action == "pause" then -- 147
			return "暂歇" -- 147
		end -- 147
		if action == "retry" then -- 148
			return "重试" -- 148
		end -- 148
		if action == "confirm" then -- 149
			return "点选" -- 149
		end -- 149
		if action == "back" then -- 150
			return "返回" -- 150
		end -- 150
		return "穿梭" -- 151
	end -- 151
	if action == "interact" then -- 153
		return "E" -- 153
	end -- 153
	if action == "jump" then -- 154
		return "SPACE" -- 154
	end -- 154
	if action == "crouch" then -- 155
		return "CTRL" -- 155
	end -- 155
	if action == "cover" then -- 156
		return "SHIFT" -- 156
	end -- 156
	if action == "fire" then -- 157
		return "左键" -- 157
	end -- 157
	if action == "aim" then -- 158
		return "F" -- 158
	end -- 158
	if action == "pause" then -- 159
		return "ESC" -- 159
	end -- 159
	if action == "retry" then -- 160
		return "R" -- 160
	end -- 160
	if action == "confirm" then -- 161
		return "ENTER" -- 161
	end -- 161
	if action == "back" then -- 162
		return "ESC" -- 162
	end -- 162
	return "T" -- 163
end -- 124
local function adaptWorldKeyTagWeb(rawKeyTag, mode) -- 166
	if mode == "kbm" then -- 167
		return rawKeyTag -- 167
	end -- 167
	if mode == "gamepad" then -- 168
		if rawKeyTag == "E" then -- 169
			return "Y" -- 169
		end -- 169
		if rawKeyTag == "按住 E" then -- 170
			return "按住 Y" -- 170
		end -- 170
		if rawKeyTag == "松开再按住 E" then -- 171
			return "松开再按 Y" -- 171
		end -- 171
		if rawKeyTag == "按住 E + D" then -- 172
			return "按住 Y + 右" -- 172
		end -- 172
		if rawKeyTag == "E 握柄 + D" then -- 173
			return "Y 握柄 + 右" -- 173
		end -- 173
		if rawKeyTag == "F" or rawKeyTag == "左键" then -- 174
			return "RT / X" -- 174
		end -- 174
		if rawKeyTag == "按住 F" then -- 175
			return "按住 RT" -- 175
		end -- 175
		if rawKeyTag == "松开 F" then -- 176
			return "松开 RT" -- 176
		end -- 176
		if rawKeyTag == "按住 Ctrl" then -- 177
			return "按住 B" -- 177
		end -- 177
		if rawKeyTag == "按住 Shift" then -- 178
			return "按住 LT" -- 178
		end -- 178
		if rawKeyTag == "连线" then -- 179
			return "摇杆/触屏连线" -- 179
		end -- 179
		if rawKeyTag == "→" then -- 180
			return "右推摇杆" -- 180
		end -- 180
		return rawKeyTag -- 181
	end -- 181
	if rawKeyTag == "E" then -- 183
		return "轻触" -- 183
	end -- 183
	if rawKeyTag == "按住 E" then -- 184
		return "长按交互" -- 184
	end -- 184
	if rawKeyTag == "松开再按住 E" then -- 185
		return "松开再长按" -- 185
	end -- 185
	if rawKeyTag == "按住 E + D" or rawKeyTag == "E 握柄 + D" then -- 186
		return "点推车+摇杆" -- 186
	end -- 186
	if rawKeyTag == "F" or rawKeyTag == "左键" then -- 187
		return "开火" -- 187
	end -- 187
	if rawKeyTag == "按住 F" then -- 188
		return "拖投瓶" -- 188
	end -- 188
	if rawKeyTag == "松开 F" then -- 189
		return "松手投" -- 189
	end -- 189
	if rawKeyTag == "按住 Ctrl" then -- 190
		return "点蹲伏" -- 190
	end -- 190
	if rawKeyTag == "按住 Shift" then -- 191
		return "点掩体" -- 191
	end -- 191
	if rawKeyTag == "连线" then -- 192
		return "一笔划连" -- 192
	end -- 192
	return rawKeyTag -- 193
end -- 166
local function adaptHintSentenceWeb(text, mode, layout) -- 196
	if mode == "kbm" or text == "" then -- 197
		return text -- 197
	end -- 197
	if mode == "gamepad" then -- 198
		local backBtn = layout == "nintendo" and "A" or "B" -- 199
		return table.concat( -- 200
			__TS__StringSplit( -- 200
				table.concat( -- 200
					__TS__StringSplit( -- 200
						table.concat( -- 200
							__TS__StringSplit( -- 200
								table.concat( -- 200
									__TS__StringSplit( -- 200
										table.concat( -- 200
											__TS__StringSplit( -- 200
												table.concat( -- 200
													__TS__StringSplit( -- 200
														table.concat( -- 200
															__TS__StringSplit( -- 200
																table.concat( -- 200
																	__TS__StringSplit( -- 200
																		table.concat( -- 200
																			__TS__StringSplit( -- 200
																				table.concat( -- 200
																					__TS__StringSplit( -- 200
																						table.concat( -- 200
																							__TS__StringSplit( -- 200
																								table.concat( -- 200
																									__TS__StringSplit( -- 200
																										table.concat( -- 200
																											__TS__StringSplit( -- 200
																												table.concat( -- 200
																													__TS__StringSplit( -- 200
																														table.concat( -- 200
																															__TS__StringSplit( -- 200
																																table.concat( -- 200
																																	__TS__StringSplit( -- 200
																																		table.concat( -- 200
																																			__TS__StringSplit( -- 200
																																				table.concat( -- 200
																																					__TS__StringSplit( -- 200
																																						table.concat( -- 200
																																							__TS__StringSplit( -- 200
																																								table.concat( -- 200
																																									__TS__StringSplit( -- 200
																																										table.concat( -- 200
																																											__TS__StringSplit(text, "[SHIFT]"), -- 200
																																											"[LT/LB]" -- 201
																																										), -- 201
																																										"[CTRL]" -- 202
																																									), -- 202
																																									"[B]" -- 202
																																								), -- 202
																																								"[E]+[D]" -- 203
																																							), -- 203
																																							"[Y]+右推" -- 203
																																						), -- 203
																																						"[E]" -- 204
																																					), -- 204
																																					"[Y]" -- 204
																																				), -- 204
																																				"[F]" -- 205
																																			), -- 205
																																			"[RT/X]" -- 205
																																		), -- 205
																																		"[SPACE]" -- 206
																																	), -- 206
																																	"[A]" -- 206
																																), -- 206
																																"[W/S]" -- 207
																															), -- 207
																															"左摇杆上下" -- 207
																														), -- 207
																														"[A/D]" -- 208
																													), -- 208
																													"左摇杆左右" -- 208
																												), -- 208
																												"[W]" -- 209
																											), -- 209
																											"左摇杆向上" -- 209
																										), -- 209
																										"[S]" -- 210
																									), -- 210
																									"左摇杆向下" -- 210
																								), -- 210
																								"[ESC]" -- 211
																							), -- 211
																							"[START]" -- 211
																						), -- 211
																						"[R]" -- 212
																					), -- 212
																					"长按 [BACK]" -- 212
																				), -- 212
																				"鼠标瞄准，左键发射火铳" -- 213
																			), -- 213
																			"右摇杆瞄准，按 [RT/X] 发射火铳" -- 213
																		), -- 213
																		"左键先手击倒" -- 214
																	), -- 214
																	"按 [RT/X] 先手击倒" -- 214
																), -- 214
																"左键发射火铳" -- 215
															), -- 215
															"按 [RT/X] 发射火铳" -- 215
														), -- 215
														"左键发铳" -- 216
													), -- 216
													"按 [RT/X] 发铳" -- 216
												), -- 216
												"按 E 再次启程" -- 217
											), -- 217
											"按 Y 再次启程" -- 217
										), -- 217
										"按住 E" -- 218
									), -- 218
									"按住 Y" -- 218
								), -- 218
								"方向键" -- 219
							), -- 219
							"左摇杆" -- 219
						), -- 219
						"Esc 暂歇" -- 220
					), -- 220
					"START 暂歇" -- 220
				), -- 220
				"返回" -- 221
			), -- 221
			("按 " .. backBtn) .. " 返回" or "," -- 221
		) -- 221
	end -- 221
	return table.concat( -- 223
		__TS__StringSplit( -- 223
			table.concat( -- 223
				__TS__StringSplit( -- 223
					table.concat( -- 223
						__TS__StringSplit( -- 223
							table.concat( -- 223
								__TS__StringSplit( -- 223
									table.concat( -- 223
										__TS__StringSplit( -- 223
											table.concat( -- 223
												__TS__StringSplit( -- 223
													table.concat( -- 223
														__TS__StringSplit( -- 223
															table.concat( -- 223
																__TS__StringSplit( -- 223
																	table.concat( -- 223
																		__TS__StringSplit( -- 223
																			table.concat( -- 223
																				__TS__StringSplit( -- 223
																					table.concat( -- 223
																						__TS__StringSplit( -- 223
																							table.concat( -- 223
																								__TS__StringSplit( -- 223
																									table.concat( -- 223
																										__TS__StringSplit( -- 223
																											table.concat( -- 223
																												__TS__StringSplit( -- 223
																													table.concat( -- 223
																														__TS__StringSplit( -- 223
																															table.concat( -- 223
																																__TS__StringSplit( -- 223
																																	table.concat( -- 223
																																		__TS__StringSplit( -- 223
																																			table.concat( -- 223
																																				__TS__StringSplit( -- 223
																																					table.concat( -- 223
																																						__TS__StringSplit( -- 223
																																							table.concat( -- 223
																																								__TS__StringSplit( -- 223
																																									table.concat( -- 223
																																										__TS__StringSplit( -- 223
																																											table.concat( -- 223
																																												__TS__StringSplit( -- 223
																																													table.concat( -- 223
																																														__TS__StringSplit( -- 223
																																															table.concat( -- 223
																																																__TS__StringSplit( -- 223
																																																	table.concat( -- 223
																																																		__TS__StringSplit( -- 223
																																																			table.concat( -- 223
																																																				__TS__StringSplit( -- 223
																																																					table.concat( -- 223
																																																						__TS__StringSplit( -- 223
																																																							table.concat( -- 223
																																																								__TS__StringSplit( -- 223
																																																									table.concat( -- 223
																																																										__TS__StringSplit( -- 223
																																																											table.concat( -- 223
																																																												__TS__StringSplit( -- 223
																																																													table.concat( -- 223
																																																														__TS__StringSplit(text, "按住 [E]+[D]"), -- 223
																																																														"点按推/拉车并推摇杆" -- 224
																																																													), -- 224
																																																													"[E]+[D]" -- 225
																																																												), -- 225
																																																												"推/拉车并推摇杆" -- 225
																																																											), -- 225
																																																											"速按 [CTRL]" -- 226
																																																										), -- 226
																																																										"点按「蹲伏」" -- 226
																																																									), -- 226
																																																									"按住 [CTRL]" -- 227
																																																								), -- 227
																																																								"点按「蹲伏」" -- 227
																																																							), -- 227
																																																							"按 [CTRL]" -- 228
																																																						), -- 228
																																																						"点按「蹲伏」" -- 228
																																																					), -- 228
																																																					"[CTRL]" -- 229
																																																				), -- 229
																																																				"「蹲伏」" -- 229
																																																			), -- 229
																																																			"按住 [SHIFT]" -- 230
																																																		), -- 230
																																																		"点按「轻步/掩体」" -- 230
																																																	), -- 230
																																																	"[SHIFT]" -- 231
																																																), -- 231
																																																"「轻步/掩体」" -- 231
																																															), -- 231
																																															"按住 [F]" -- 232
																																														), -- 232
																																														"按住「投瓶」拖拽" -- 232
																																													), -- 232
																																													"[F]" -- 233
																																												), -- 233
																																												"「投瓶」" -- 233
																																											), -- 233
																																											"按住 E" -- 234
																																										), -- 234
																																										"长按「交互」" -- 234
																																									), -- 234
																																									"按 [E]" -- 235
																																								), -- 235
																																								"点按「交互」" -- 235
																																							), -- 235
																																							"[E]" -- 236
																																						), -- 236
																																						"「交互」" -- 236
																																					), -- 236
																																					"方向键" -- 237
																																				), -- 237
																																				"左下摇杆" -- 237
																																			), -- 237
																																			"按 [ESC]" -- 238
																																		), -- 238
																																		"轻触右上「暂歇」" -- 238
																																	), -- 238
																																	"[ESC]" -- 239
																																), -- 239
																																"右上「暂歇」" -- 239
																															), -- 239
																															"按 [SPACE]" -- 240
																														), -- 240
																														"点按「翻滚/跳跃」" -- 240
																													), -- 240
																													"[SPACE]" -- 241
																												), -- 241
																												"「翻滚/跳跃」" -- 241
																											), -- 241
																											"按 [R]" -- 242
																										), -- 242
																										"在暂歇菜单重试" -- 242
																									), -- 242
																									"[A/D]" -- 243
																								), -- 243
																								"左下摇杆" -- 243
																							), -- 243
																							"[W/S]" -- 244
																						), -- 244
																						"摇杆上下" -- 244
																					), -- 244
																					"[W]" -- 245
																				), -- 245
																				"摇杆向上" -- 245
																			), -- 245
																			"[S]" -- 246
																		), -- 246
																		"摇杆向下" -- 246
																	), -- 246
																	"鼠标瞄准，左键发射火铳" -- 247
																), -- 247
																"点屏或拖「开火」发射火铳" -- 247
															), -- 247
															"左键先手击倒" -- 248
														), -- 248
														"点屏或「开火」先手击倒" -- 248
													), -- 248
													"左键发射火铳" -- 249
												), -- 249
												"点屏或「开火」发射火铳" -- 249
											), -- 249
											"左键发铳" -- 250
										), -- 250
										"点屏或「开火」发铳" -- 250
									), -- 250
									"左键" -- 251
								), -- 251
								"点屏或「开火」" -- 251
							), -- 251
							"鼠标" -- 252
						), -- 252
						"触屏" -- 252
					), -- 252
					"按 E 再次启程" -- 253
				), -- 253
				"轻触屏幕再次启程" -- 253
			), -- 253
			"Esc 暂歇" -- 254
		), -- 254
		"轻触右上暂歇" -- 254
	) -- 254
end -- 196
local WebInputDriver = __TS__Class() -- 257
WebInputDriver.name = "WebInputDriver" -- 257
function WebInputDriver.prototype.____constructor(self, settings) -- 265
	self.defaultMode = "kbm" -- 258
	self.kbm = __TS__New(KbmPoller) -- 259
	self.settings = settings -- 266
	self.touchRouter = __TS__New(TouchRouter, settings, {enableMouseCompat = true, enablePortrait = true}) -- 267
	self.gamepadRouter = __TS__New(GamepadRouter, settings) -- 271
end -- 265
function WebInputDriver.prototype.attach(self, parent, hooks) -- 274
	self.kbm:attach(parent, hooks) -- 275
	self.touchRouter:attach(parent) -- 276
	self.gamepadRouter:attach(parent) -- 277
	if self.touchControls == nil then -- 278
		self.touchControls = __TS__New(TouchControls, parent, PORTRAIT_TOUCH_DELEGATE) -- 279
	end -- 279
end -- 274
function WebInputDriver.prototype.syncFrame(self, ctx) -- 283
	local vp = ctx.viewport -- 284
	local p = ctx.play -- 285
	local isPlayMode = ctx.mode == 1 and ctx.screen == "play" and p ~= nil -- 286
	local isTrialMode = ctx.mode == 2 and p ~= nil -- 287
	local gameplayActive = isPlayMode or isTrialMode -- 288
	local ____opt_0 = ctx.run -- 290
	local trial = ____opt_0 and ____opt_0.trial -- 290
	local ____temp_5 = isTrialMode and trial ~= nil -- 291
	if ____temp_5 then -- 291
		local ____trial_lost_4 = trial.lost -- 291
		if not ____trial_lost_4 then -- 291
			local ____opt_2 = ctx.run -- 291
			____trial_lost_4 = (____opt_2 and ____opt_2.finished) == true -- 291
		end -- 291
		____temp_5 = ____trial_lost_4 -- 291
	end -- 291
	local trialEnded = ____temp_5 -- 291
	local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 292
	local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) or isTrialMode and p ~= nil and (p.paused or trialEnded) -- 293
	local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 296
	local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 297
	local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and #p:getStoryTalentOffers() or (trialHasOffers and trial ~= nil and #trial.offers or 0) -- 298
	local ____temp_6 -- 301
	if isPlayMode and p ~= nil then -- 301
		____temp_6 = isCutsceneBlockingPlay(p) -- 301
	else -- 301
		____temp_6 = false -- 301
	end -- 301
	local cutsceneBlocking = ____temp_6 -- 301
	local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 302
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 304
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and not trialHasOffers and p.escort.state ~= "calming" -- 305
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 307
	local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 309
	local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 312
	local enemyTargets = canShoot and self.settings.aimAssist and p ~= nil and (isPlayMode and ctx.cam ~= nil and collectPlayAimTargets(p, ctx.cam, vp.stageW, vp.stageH) or collectTrialAimTargets(p, vp.stageW, vp.stageH)) or ({}) -- 315
	if self.touchControls ~= nil then -- 321
		local pref = self.settings.modePref -- 322
		self.touchControls:syncContext({ -- 323
			viewport = vp, -- 324
			mode = ctx.mode, -- 325
			screen = ctx.screen, -- 326
			play = p, -- 327
			run = ctx.run, -- 328
			cam = ctx.cam, -- 329
			router = self.touchRouter, -- 330
			overlayActive = self:shouldShowTouchControls(ctx.input, vp), -- 331
			allowAutoGameplayTouch = pref == "auto" or pref == "touch", -- 332
			allowMouseOnOverlay = vp.isPortrait or pref == "touch", -- 333
			showWebTopPills = true, -- 334
			canToggleFullscreen = true, -- 335
			assistHintsEnabled = ctx.assistHintsEnabled, -- 336
			isMuted = ctx.isMuted, -- 337
			isFullscreen = ctx.isFullscreen, -- 338
			storyTalentBoxes = ctx.storyTalentBoxes, -- 339
			enemyTargets = enemyTargets, -- 340
			dt = ctx.dt -- 341
		}) -- 341
	end -- 341
	local playerScreenX = vp.stageW * 0.5 -- 345
	local playerScreenY = vp.stageH * 0.38 -- 346
	if p ~= nil then -- 347
		if isPlayMode and ctx.cam ~= nil then -- 348
			playerScreenX = ctx.cam:sx(p.player.x + p.player.facing * 8) -- 349
			playerScreenY = ctx.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 350
		else -- 350
			local vz = p.view.zoom > 0 and p.view.zoom or 1 -- 352
			playerScreenX = vp.stageW * 0.5 + (p.player.x + p.player.facing * 8 - p.cam.x) * vz -- 353
			playerScreenY = vp.stageH * 0.5 + (p.player.y + p.player.h * 0.72 + p.player.depth * DEPTH_Y_SCALE - p.cam.y) * vz -- 354
		end -- 354
	end -- 354
	local gpCtx = { -- 358
		stageW = vp.stageW, -- 359
		stageH = vp.stageH, -- 360
		uiScale = vp.uiScale, -- 361
		modal = modal, -- 362
		gameplayActive = gameplayActive, -- 363
		reloadActive = reloadActive, -- 364
		craftActive = craftActive, -- 365
		talentOfferCount = talentOfferCount, -- 366
		childMode = p ~= nil and p.childMode, -- 367
		allowDepth = allowDepth, -- 368
		canShoot = canShoot, -- 369
		canBottleAim = canBottleAim, -- 370
		playerRolling = p ~= nil and p.player.rollT > 0, -- 371
		inLowArch = inLowArch, -- 372
		inTowerEnd = inTowerEnd, -- 373
		playerFacing = p ~= nil and p.player.facing or 1, -- 374
		playerScreenX = playerScreenX, -- 375
		playerScreenY = playerScreenY, -- 376
		enemyTargets = enemyTargets -- 377
	} -- 377
	self.gamepadRouter:setFrameContext(gpCtx, ctx.dt) -- 379
end -- 283
function WebInputDriver.prototype.renderOverlay(self) -- 382
	local ____opt_7 = self.touchControls -- 383
	if ____opt_7 ~= nil then -- 383
		____opt_7:render(self.touchRouter) -- 383
	end -- 383
end -- 382
function WebInputDriver.prototype.clearTransient(self, keepTouchToggles) -- 386
	self.touchRouter:releaseAll(keepTouchToggles) -- 387
	self.gamepadRouter:clearTransient() -- 388
end -- 386
function WebInputDriver.prototype.vibrate(self, seconds) -- 391
	self.touchRouter:vibrate(seconds) -- 392
end -- 391
function WebInputDriver.prototype.onInputModeChanged(self, mode) -- 395
	if mode ~= "touch" then -- 396
		self.touchRouter:releaseAll(false) -- 397
	end -- 397
end -- 395
function WebInputDriver.prototype.shouldShowTouchControls(self, input, vp) -- 401
	if vp.isPortrait then -- 402
		return true -- 402
	end -- 402
	if self.settings.modePref == "touch" then -- 403
		return true -- 403
	end -- 403
	if self.settings.modePref == "kbm" or self.settings.modePref == "gamepad" then -- 404
		return false -- 404
	end -- 404
	return input.inputMode == "touch" -- 405
end -- 401
function WebInputDriver.prototype.getTouchRouter(self) -- 408
	return self.touchRouter -- 409
end -- 408
function WebInputDriver.prototype.getGamepadRouter(self) -- 412
	return self.gamepadRouter -- 413
end -- 412
function WebInputDriver.prototype.getTouchControls(self) -- 416
	return self.touchControls -- 417
end -- 416
function WebInputDriver.prototype.injectTouch(self, phase, id, x, y, fromMouse) -- 420
	self.touchRouter:injectTouch( -- 421
		phase, -- 421
		id, -- 421
		x, -- 421
		y, -- 421
		fromMouse == true -- 421
	) -- 421
end -- 420
function WebInputDriver.prototype.setGamepadSim(self, state) -- 424
	self.gamepadRouter:setSimulatedState(state) -- 425
end -- 424
function WebInputDriver.prototype.pollInto(self, input) -- 428
	input.gamepadLayout = self.settings.gamepadLayout -- 429
	local touch = self.touchRouter:consumeSnapshot() -- 430
	local gp = self.gamepadRouter:consumeSnapshot() -- 431
	local kbm = self.kbm:sample(input:getStageViewport()) -- 432
	local suppressMouse = touch.suppressSyntheticMouse or touch.mouseConsumedByOverlay -- 434
	local realMouseActive = not suppressMouse and (kbm.mouseMoved or kbm.mouseClicked and kbm.mouseInsideStage) -- 435
	if kbm.anyKb or realMouseActive or gp.hadGamepadInput or touch.hadRealTouch then -- 437
		input.userInteracted = true -- 438
	end -- 438
	if self.settings.modePref ~= "auto" then -- 441
		input:setInputMode(self.settings.modePref) -- 442
	elseif gp.hadGamepadInput then -- 443
		input:setInputMode("gamepad") -- 444
	elseif touch.hadGameplayTouch then -- 445
		input:setInputMode("touch") -- 446
	elseif kbm.anyKb or realMouseActive then -- 447
		input:setInputMode("kbm") -- 448
	elseif touch.hadUiTouch and input.inputMode == "kbm" then -- 449
		input:setInputMode("touch") -- 450
	end -- 450
	input.moveX = kbm.moveX ~= 0 and kbm.moveX or (gp.moveX ~= 0 and gp.moveX or touch.moveX) -- 453
	input.moveY = kbm.moveY ~= 0 and kbm.moveY or (gp.moveY ~= 0 and gp.moveY or touch.moveY) -- 454
	local allowMouseFire = not suppressMouse and input.inputMode == "kbm" and kbm.mouseInsideStage -- 456
	local rawFireHeld = allowMouseFire and kbm.mouseLeft or gp.fireHeld or touch.fireHeld -- 457
	input:applyKeyHeld( -- 459
		kbm.jump or gp.jumpHeld or touch.jumpHeld, -- 460
		kbm.crouch or gp.crouchHeld or touch.crouchHeld, -- 461
		kbm.cover or gp.coverHeld or touch.coverHeld, -- 462
		kbm.interact or gp.interactHeld or touch.interactHeld, -- 463
		kbm.aim or gp.aimHeld or touch.aimHeld, -- 464
		rawFireHeld, -- 465
		kbm.flare or gp.flareHeld, -- 466
		kbm.pause, -- 467
		kbm.retry, -- 468
		kbm.toggleView, -- 469
		kbm.tab -- 470
	) -- 470
	input:resetFrameSignals() -- 473
	input.navUp = kbm.navUp -- 476
	input.navDown = kbm.navDown -- 477
	input.navLeft = kbm.navLeft -- 478
	input.navRight = kbm.navRight -- 479
	input.navConfirm = kbm.navConfirm -- 480
	input.craftConfirm = kbm.uiConfirmWithE -- 481
	input.craftCancel = kbm.uiBackSpace -- 482
	local kCol = (kbm.navRight and 1 or 0) - (kbm.navLeft and 1 or 0) -- 483
	local kRow = (kbm.navUp and 1 or 0) - (kbm.navDown and 1 or 0) -- 484
	if kCol ~= 0 or kRow ~= 0 then -- 485
		input.reloadDirCol = kCol -- 486
		input.reloadDirRow = kRow -- 487
		input.reloadStepEdge = true -- 488
		input.reloadAutoStep = false -- 489
	end -- 489
	input.reloadConfirm = kbm.uiConfirmWithE -- 491
	input.reloadReset = kbm.uiBackSpace -- 492
	if gp.jumpPressed then -- 494
		input.jump.pressed = true -- 494
	end -- 494
	if gp.crouchPressed then -- 495
		input.crouch.pressed = true -- 495
	end -- 495
	if gp.interactPressed then -- 496
		input.interact.pressed = true -- 496
	end -- 496
	if gp.aimPressed then -- 497
		input.aim.pressed = true -- 497
	end -- 497
	if gp.firePressed then -- 498
		input.fire.pressed = true -- 498
	end -- 498
	if gp.flarePressed then -- 499
		input.flare.pressed = true -- 499
	end -- 499
	if gp.pausePressed then -- 500
		input.pause.pressed = true -- 500
	end -- 500
	if gp.retryPressed then -- 501
		input.retry.pressed = true -- 501
	end -- 501
	if gp.artifactPressed then -- 502
		input.artifactTogglePressed = true -- 502
	end -- 502
	if gp.anyButtonPressed then -- 503
		input.splashSkipPressed = true -- 503
	end -- 503
	if gp.bottleCanceled then -- 504
		input.bottleCanceled = true -- 505
		input.aim.held = false -- 506
		input.aim.pressed = false -- 507
		input.aim.released = false -- 508
	end -- 508
	if gp.navUp then -- 510
		input.navUp = true -- 510
	end -- 510
	if gp.navDown then -- 511
		input.navDown = true -- 511
	end -- 511
	if gp.navLeft then -- 512
		input.navLeft = true -- 512
	end -- 512
	if gp.navRight then -- 513
		input.navRight = true -- 513
	end -- 513
	if gp.navConfirm then -- 514
		input.navConfirm = true -- 515
		input.craftConfirm = true -- 516
	end -- 516
	if gp.navBack then -- 518
		input.navBack = true -- 519
		input.craftCancel = true -- 520
	end -- 520
	input.navPrevTab = gp.navPrevTab -- 522
	input.navNextTab = gp.navNextTab -- 523
	if gp.reloadStepEdge then -- 524
		input.reloadDirCol = gp.reloadDirCol -- 525
		input.reloadDirRow = gp.reloadDirRow -- 526
		input.reloadStepEdge = true -- 527
		input.reloadAutoStep = gp.reloadAutoStep -- 528
	end -- 528
	if gp.reloadConfirm then -- 530
		input.reloadConfirm = true -- 530
	end -- 530
	if gp.reloadReset then -- 531
		input.reloadReset = true -- 531
	end -- 531
	input.talentDelta = gp.talentDelta -- 532
	input.talentConfirm = gp.talentConfirm -- 533
	input.retryHoldProgress = gp.retryHoldProgress -- 534
	if touch.jumpPressed then -- 536
		input.jump.pressed = true -- 536
	end -- 536
	if touch.interactPressed then -- 537
		input.interact.pressed = true -- 537
	end -- 537
	if touch.firePressed then -- 538
		input.fire.pressed = true -- 538
	end -- 538
	if touch.pausePressed then -- 539
		input.pause.pressed = true -- 539
	end -- 539
	if touch.retryPressed then -- 540
		input.retry.pressed = true -- 540
	end -- 540
	if touch.artifactPressed then -- 541
		input.artifactTogglePressed = true -- 541
	end -- 541
	if touch.mutePressed then -- 542
		input.muteTogglePressed = true -- 542
	end -- 542
	if touch.fullscreenPressed then -- 543
		input.fullscreenTogglePressed = true -- 543
	end -- 543
	if touch.anyTapBegan then -- 544
		input.splashSkipPressed = true -- 544
	end -- 544
	if touch.zoneTap ~= "" then -- 545
		input.touchZoneTap = touch.zoneTap -- 545
	end -- 545
	if touch.navUp then -- 546
		input.navUp = true -- 546
	end -- 546
	if touch.navDown then -- 547
		input.navDown = true -- 547
	end -- 547
	if touch.navLeft then -- 548
		input.navLeft = true -- 548
	end -- 548
	if touch.navRight then -- 549
		input.navRight = true -- 549
	end -- 549
	if touch.navConfirm then -- 550
		input.navConfirm = true -- 551
		input.craftConfirm = true -- 552
	end -- 552
	if touch.navBack then -- 554
		input.navBack = true -- 555
		input.craftCancel = true -- 556
	end -- 556
	if touch.bottleCanceled then -- 558
		input.bottleCanceled = true -- 559
		input.aim.held = false -- 560
		input.aim.pressed = false -- 561
		input.aim.released = false -- 562
	end -- 562
	if not suppressMouse and input.inputMode == "kbm" and input.aim.held and kbm.mouseRightPressed then -- 565
		input.bottleCanceled = true -- 566
		input.aim.held = false -- 567
		input.aim.pressed = false -- 568
		input.aim.released = false -- 569
	end -- 569
	input:applyPickRoom(kbm.pick) -- 572
	input.frameInteractPressed = input.interact.pressed -- 573
	if touch.uiHeld or touch.uiPressed or touch.uiReleased or touch.uiInside then -- 575
		input.uiX = touch.uiX -- 576
		input.uiY = touch.uiY -- 577
		input.uiDx = touch.uiDx -- 578
		input.uiDy = touch.uiDy -- 579
		input.uiInside = touch.uiInside -- 580
		input.uiHeld = touch.uiHeld -- 581
		input.uiPressed = touch.uiPressed -- 582
		input.uiReleased = touch.uiReleased -- 583
		input.uiRightPressed = false -- 584
		if touch.uiHeld or touch.uiPressed then -- 585
			input.mdx = touch.uiDx -- 586
			input.mdy = touch.uiDy -- 587
			input.mx = touch.uiX -- 588
			input.my = touch.uiY -- 589
			input.inside = true -- 590
		elseif touch.hasAim then -- 591
			input.mdx = touch.aimX - input.mx -- 592
			input.mdy = touch.aimY - input.my -- 593
			input.mx = touch.aimX -- 594
			input.my = touch.aimY -- 595
			input.inside = true -- 596
		else -- 596
			input.mdx = 0 -- 598
			input.mdy = 0 -- 599
			input.inside = touch.uiInside -- 600
		end -- 600
		return -- 602
	end -- 602
	if input.inputMode == "gamepad" then -- 605
		if gp.hasAim then -- 606
			input.mdx = gp.aimX - input.mx -- 607
			input.mdy = gp.aimY - input.my -- 608
			input.mx = gp.aimX -- 609
			input.my = gp.aimY -- 610
			input.inside = true -- 611
		else -- 611
			input.mdx = 0 -- 613
			input.mdy = 0 -- 614
			input.inside = false -- 615
		end -- 615
		if not suppressMouse and kbm.mouseInsideStage and (kbm.mouseLeft or kbm.mouseLeftPressed or kbm.mouseLeftReleased) then -- 617
			input.uiDx = kbm.mouseStageX - input.uiX -- 618
			input.uiDy = kbm.mouseStageY - input.uiY -- 619
			input.uiX = kbm.mouseStageX -- 620
			input.uiY = kbm.mouseStageY -- 621
			input.uiInside = true -- 622
			input.uiHeld = kbm.mouseLeft -- 623
			input.uiPressed = kbm.mouseLeftPressed -- 624
			input.uiReleased = kbm.mouseLeftReleased -- 625
			input.uiRightPressed = kbm.mouseRightPressed -- 626
		else -- 626
			input.uiX = input.mx -- 628
			input.uiY = input.my -- 629
			input.uiDx = 0 -- 630
			input.uiDy = 0 -- 631
			input.uiInside = false -- 632
			input.uiHeld = false -- 633
			input.uiPressed = false -- 634
			input.uiReleased = false -- 635
			input.uiRightPressed = false -- 636
		end -- 636
		return -- 638
	end -- 638
	if input.inputMode == "touch" then -- 641
		if touch.hasAim then -- 642
			input.mdx = touch.aimX - input.mx -- 643
			input.mdy = touch.aimY - input.my -- 644
			input.mx = touch.aimX -- 645
			input.my = touch.aimY -- 646
			input.inside = true -- 647
		else -- 647
			input.mdx = 0 -- 649
			input.mdy = 0 -- 650
			input.inside = false -- 651
		end -- 651
		if not suppressMouse and kbm.mouseInsideStage and (kbm.mouseLeft or kbm.mouseLeftPressed or kbm.mouseLeftReleased) then -- 653
			input.uiDx = kbm.mouseStageX - input.uiX -- 654
			input.uiDy = kbm.mouseStageY - input.uiY -- 655
			input.uiX = kbm.mouseStageX -- 656
			input.uiY = kbm.mouseStageY -- 657
			input.uiInside = true -- 658
			input.uiHeld = kbm.mouseLeft -- 659
			input.uiPressed = kbm.mouseLeftPressed -- 660
			input.uiReleased = kbm.mouseLeftReleased -- 661
			input.uiRightPressed = kbm.mouseRightPressed -- 662
		else -- 662
			input.uiDx = 0 -- 664
			input.uiDy = 0 -- 665
			input.uiInside = false -- 666
			input.uiHeld = false -- 667
			input.uiPressed = false -- 668
			input.uiReleased = false -- 669
			input.uiRightPressed = false -- 670
		end -- 670
		return -- 672
	end -- 672
	input.mdx = kbm.mouseStageX - input.mx -- 675
	input.mdy = kbm.mouseStageY - input.my -- 676
	input.mx = kbm.mouseStageX -- 677
	input.my = kbm.mouseStageY -- 678
	input.inside = kbm.mouseInsideStage -- 679
	input.uiX = kbm.mouseStageX -- 681
	input.uiY = kbm.mouseStageY -- 682
	input.uiDx = input.mdx -- 683
	input.uiDy = input.mdy -- 684
	input.uiInside = kbm.mouseInsideStage -- 685
	input.uiHeld = not suppressMouse and kbm.mouseLeft and kbm.mouseInsideStage -- 686
	input.uiPressed = not suppressMouse and kbm.mouseLeftPressed and kbm.mouseInsideStage -- 687
	input.uiReleased = not suppressMouse and kbm.mouseLeftReleased -- 688
	input.uiRightPressed = not suppressMouse and kbm.mouseRightPressed and kbm.mouseInsideStage -- 689
end -- 428
____exports.TARGET = { -- 693
	id = "web", -- 694
	supportsKbm = true, -- 695
	supportsTouch = true, -- 696
	supportsGamepad = true, -- 697
	supportsPortrait = true, -- 698
	defaultInputMode = "kbm", -- 699
	supportedModes = {"kbm", "touch", "gamepad"}, -- 700
	modePrefOrder = MODE_PREF_ORDER, -- 701
	controlsGuideTabs = {{mode = "kbm", label = "键鼠"}, {mode = "gamepad", label = "手柄"}, {mode = "touch", label = "触屏"}}, -- 702
	getPlatformCaps = function(self) -- 708
		local cfg = getReleaseConfig() -- 709
		local ____temp_9 -- 722
		if cfg ~= nil and cfg.isRelease ~= nil then -- 722
			____temp_9 = cfg.isRelease == true -- 722
		else -- 722
			____temp_9 = true -- 722
		end -- 722
		return { -- 710
			kind = "web", -- 711
			target = "web", -- 712
			isDesktop = false, -- 713
			isMobile = false, -- 714
			isWeb = true, -- 715
			isStandaloneAndroidApk = false, -- 716
			canToggleFullscreen = true, -- 717
			canQuit = false, -- 718
			hasBackButton = false, -- 719
			supportsHaptics = false, -- 720
			needsAudioUnlock = true, -- 721
			isRelease = ____temp_9, -- 722
			defaultInputMode = "kbm" -- 723
		} -- 723
	end, -- 708
	canToggleFullscreen = function(self) -- 727
		return true -- 728
	end, -- 727
	canQuitApp = function(self) -- 731
		return false -- 732
	end, -- 731
	isReleaseMode = function(self) -- 735
		local cfg = getReleaseConfig() -- 736
		if cfg ~= nil and cfg.isRelease ~= nil then -- 737
			return cfg.isRelease == true -- 738
		end -- 738
		return true -- 740
	end, -- 735
	computeStageViewport = function(self, fullW, fullH) -- 743
		return computeAdaptiveViewport(fullW, fullH) -- 744
	end, -- 743
	triggerHaptics = function(self, seconds, enabled) -- 747
		triggerMobileHaptics(seconds, enabled) -- 748
	end, -- 747
	keyTagFor = function(self, action, mode, layout) -- 751
		return keyTagWeb(action, mode, layout) -- 752
	end, -- 751
	adaptWorldKeyTag = function(self, rawKeyTag, mode, _layout) -- 755
		return adaptWorldKeyTagWeb(rawKeyTag, mode) -- 756
	end, -- 755
	adaptHintSentence = function(self, text, mode, layout) -- 759
		return adaptHintSentenceWeb(text, mode, layout) -- 760
	end, -- 759
	controlsGuideRows = function(self, tab) -- 763
		if tab == "gamepad" then -- 764
			return GUIDE_GAMEPAD -- 764
		end -- 764
		if tab == "touch" then -- 765
			return GUIDE_TOUCH -- 765
		end -- 765
		return GUIDE_KBM -- 766
	end, -- 763
	splashSkipHint = function(self, mode, layout) -- 769
		if mode == "touch" then -- 770
			return "轻触跳过" -- 770
		end -- 770
		if mode == "gamepad" then -- 771
			return keyTagWeb("confirm", "gamepad", layout) .. " / START  跳过" -- 771
		end -- 771
		return "ESC / SPACE  SKIP" -- 772
	end, -- 769
	titleFooterHint = function(self, mode, layout) -- 775
		if mode == "gamepad" then -- 776
			return ("左摇杆 / 十字键择项   ·   " .. keyTagWeb("confirm", "gamepad", layout)) .. " 或点选启程" -- 777
		end -- 777
		if mode == "touch" then -- 779
			return "轻触择项启程   ·   支持键鼠与手柄" -- 779
		end -- 779
		return "上下择项   ·   回车或点选启程" -- 780
	end, -- 775
	chapterFooterHint = function(self, mode, confirmTag) -- 783
		if mode == "gamepad" then -- 784
			return ("摇杆/十字键选择   ·   " .. confirmTag) .. " 或点选进入" -- 784
		end -- 784
		if mode == "touch" then -- 785
			return "轻触驿站预览   ·   再点或轻触入此卷章" -- 785
		end -- 785
		return "方向键选择   ·   回车或点击进入" -- 786
	end, -- 783
	pauseFooterHint = function(self, mode, layout) -- 789
		if mode == "gamepad" then -- 790
			return ((keyTagWeb("back", "gamepad", layout) .. " / START 续行   ·   ") .. keyTagWeb("confirm", "gamepad", layout)) .. " 确认" -- 791
		end -- 791
		if mode == "touch" then -- 793
			return "轻触确认   ·   点「继续游戏」续行" -- 793
		end -- 793
		return "Esc 续行   ·   Enter 或点击确认" -- 794
	end, -- 789
	settingsFooterHint = function(self, mode, layout) -- 797
		if mode == "gamepad" then -- 798
			return ((("左右或 " .. keyTagWeb("confirm", "gamepad", layout)) .. " 切换   ·   ") .. keyTagWeb("back", "gamepad", layout)) .. " 返回暂停" -- 799
		end -- 799
		if mode == "touch" then -- 801
			return "轻触任意条目切换   ·   设置自动保存" -- 801
		end -- 801
		return "←/→ 或回车/点击切换   ·   Esc 返回暂停" -- 802
	end, -- 797
	controlsFooterRightHint = function(self, mode) -- 805
		if mode == "gamepad" then -- 806
			return "LB / RB 或左右切换键位图" -- 806
		end -- 806
		if mode == "touch" then -- 807
			return "轻触右上页签切图 · 暂歇菜单可调操控设置" -- 807
		end -- 807
		return "←/→ 切页   ·   F11 / Alt+Enter 全屏" -- 808
	end, -- 805
	epilogueFooterHint = function(self, mode, layout) -- 811
		if mode == "gamepad" then -- 812
			return ((keyTagWeb("confirm", "gamepad", layout) .. " 确认   ·   ") .. keyTagWeb("back", "gamepad", layout)) .. " 返回标题" -- 813
		end -- 813
		if mode == "touch" then -- 815
			return "轻触任一入口继续" -- 815
		end -- 815
		return "↑/↓ 选择   ·   Enter / 点击确认   ·   Esc 返回标题" -- 816
	end, -- 811
	trialSubHint = function(self, mode, ended, seed) -- 819
		if mode == "gamepad" then -- 820
			return ("种子 " .. tostring(seed)) .. (ended and " · A 再开一局 · START 返回标题" or " · START 继续 · 长按BACK 重开 · Y 返回标题") -- 821
		end -- 821
		if mode == "touch" then -- 823
			return ("种子 " .. tostring(seed)) .. (ended and " · 点下方按钮再开或返回标题" or " · 点下方按钮继续/重开/返回标题") -- 824
		end -- 824
		return ("种子 " .. tostring(seed)) .. (ended and " · R 再开一局 · Esc 返回标题" or " · Esc 继续 · R 重新开局 · E 返回标题") -- 826
	end, -- 819
	settingsRows = function(self) -- 829
		return WEB_SETTINGS_ROWS -- 830
	end, -- 829
	settingsPauseLabel = function(self, settings) -- 833
		return "操控设置 · " .. modePrefLabelOf(settings.modePref) -- 834
	end, -- 833
	settingsHeaderTitle = function(self) -- 837
		return "操控与声音" -- 838
	end, -- 837
	settingsHeaderSummary = function(self, activeMode) -- 841
		return ("当前模式：" .. inputModeLabelOf(activeMode)) .. " · 操控与四通道音量实时生效" -- 842
	end, -- 841
	settingsValueText = function(self, rowId, settings, activeMode) -- 845
		if rowId == "modePref" then -- 846
			return settings.modePref == "auto" and ("自动切换（" .. inputModeLabelOf(activeMode)) .. "）" or "锁定 · " .. modePrefLabelOf(settings.modePref) -- 847
		end -- 847
		if rowId == "aimAssist" then -- 851
			return settings.aimAssist and "开（触屏与手柄共用）" or "关" -- 851
		end -- 851
		if rowId == "gpLayout" then -- 852
			return layoutLabelOf(settings.gamepadLayout) -- 852
		end -- 852
		if rowId == "crouchMode" then -- 853
			return settings.crouchToggle and "点按切换" or "持续按住" -- 853
		end -- 853
		if rowId == "touchOpacity" then -- 854
			return opacityLabelOf(settings.touchOpacity) -- 854
		end -- 854
		if rowId == "touchScale" then -- 855
			return scaleLabelOf(settings.touchScale) -- 855
		end -- 855
		if rowId == "haptics" then -- 856
			return settings.haptics and "开（仅移动端生效）" or "关" -- 856
		end -- 856
		return volumeSettingText(rowId, settings) -- 857
	end, -- 845
	applySettingsDelta = function(self, rowId, delta, settings, input) -- 860
		if rowId == "back" then -- 861
			return "back" -- 861
		end -- 861
		if rowId == "modePref" then -- 862
			input:cycleModePref(delta) -- 863
			return "control" -- 864
		end -- 864
		if rowId == "aimAssist" then -- 866
			settings.aimAssist = not settings.aimAssist -- 867
			saveControlSettings(settings) -- 868
			return "control" -- 869
		end -- 869
		if rowId == "gpLayout" then -- 871
			settings.gamepadLayout = settings.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 872
			input.gamepadLayout = settings.gamepadLayout -- 873
			saveControlSettings(settings) -- 874
			return "control" -- 875
		end -- 875
		if rowId == "crouchMode" then -- 877
			settings.crouchToggle = not settings.crouchToggle -- 878
			saveControlSettings(settings) -- 879
			return "control" -- 880
		end -- 880
		if rowId == "touchOpacity" then -- 882
			settings.touchOpacity = nextStepValue(settings.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 883
			saveControlSettings(settings) -- 884
			return "control" -- 885
		end -- 885
		if rowId == "touchScale" then -- 887
			settings.touchScale = nextStepValue(settings.touchScale, TOUCH_SCALE_STEPS, delta) -- 888
			saveControlSettings(settings) -- 889
			return "control" -- 890
		end -- 890
		if rowId == "haptics" then -- 892
			settings.haptics = not settings.haptics -- 893
			saveControlSettings(settings) -- 894
			return "control" -- 895
		end -- 895
		if applyVolumeSetting(rowId, delta, settings) then -- 897
			return "audio" -- 897
		end -- 897
		return "none" -- 898
	end, -- 860
	createDriver = function(self, settings) -- 901
		return __TS__New(WebInputDriver, settings) -- 902
	end -- 901
} -- 901
return ____exports -- 901
