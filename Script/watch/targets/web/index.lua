-- [ts]: index.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____aim_assist = require("Script.watch.input.aim_assist") -- 9
local collectAimTargets = ____aim_assist.collectAimTargets -- 9
local projectMuzzle = ____aim_assist.projectMuzzle -- 9
local ____gamepad_core = require("Script.watch.input.gamepad_core") -- 10
local GamepadRouter = ____gamepad_core.GamepadRouter -- 10
local ____kbm_core = require("Script.watch.input.kbm_core") -- 11
local KbmPoller = ____kbm_core.KbmPoller -- 11
local ____touch_core = require("Script.watch.input.touch_core") -- 12
local TouchRouter = ____touch_core.TouchRouter -- 12
local ____touch_hud_landscape = require("Script.watch.input.touch_hud_landscape") -- 13
local TouchControls = ____touch_hud_landscape.TouchControls -- 13
local ____touch_hud_portrait = require("Script.watch.input.touch_hud_portrait") -- 14
local PORTRAIT_TOUCH_DELEGATE = ____touch_hud_portrait.PORTRAIT_TOUCH_DELEGATE -- 14
local ____play_prompts = require("Script.watch.fe.ui.play_prompts") -- 15
local isCutsceneBlockingPlay = ____play_prompts.isCutsceneBlockingPlay -- 15
local ____platform_mobile = require("Script.watch.platform_mobile") -- 16
local computeAdaptiveViewport = ____platform_mobile.computeAdaptiveViewport -- 16
local triggerMobileHaptics = ____platform_mobile.triggerMobileHaptics -- 16
local ____controls_config = require("Script.watch.controls_config") -- 17
local MODE_PREF_ORDER = ____controls_config.MODE_PREF_ORDER -- 18
local TOUCH_OPACITY_STEPS = ____controls_config.TOUCH_OPACITY_STEPS -- 19
local TOUCH_SCALE_STEPS = ____controls_config.TOUCH_SCALE_STEPS -- 20
local applyVolumeSetting = ____controls_config.applyVolumeSetting -- 21
local inputModeLabelOf = ____controls_config.inputModeLabelOf -- 22
local layoutLabelOf = ____controls_config.layoutLabelOf -- 23
local modePrefLabelOf = ____controls_config.modePrefLabelOf -- 24
local nextStepValue = ____controls_config.nextStepValue -- 25
local opacityLabelOf = ____controls_config.opacityLabelOf -- 26
local saveControlSettings = ____controls_config.saveControlSettings -- 27
local scaleLabelOf = ____controls_config.scaleLabelOf -- 28
local volumeSettingText = ____controls_config.volumeSettingText -- 29
local ____target_types = require("Script.watch.target_types") -- 32
local getReleaseConfig = ____target_types.getReleaseConfig -- 45
local WEB_SETTINGS_ROWS = { -- 48
	{id = "modePref", title = "操作模式"}, -- 49
	{id = "aimAssist", title = "瞄准磁吸"}, -- 50
	{id = "gpLayout", title = "手柄确认键"}, -- 51
	{id = "crouchMode", title = "手柄蹲伏方式"}, -- 52
	{id = "touchOpacity", title = "触控按键透度"}, -- 53
	{id = "touchScale", title = "触控按键大小"}, -- 54
	{id = "haptics", title = "触觉震动反馈"}, -- 55
	{id = "masterVol", title = "主音量"}, -- 56
	{id = "bgmVol", title = "音乐音量"}, -- 57
	{id = "sfxVol", title = "音效与环境"}, -- 58
	{id = "voiceVol", title = "人声音量"}, -- 59
	{id = "back", title = "返回暂歇菜单"} -- 60
} -- 60
local GUIDE_KBM = {subtitle = "键鼠操作说明 · 全平台通用", soldierRows = { -- 63
	{"WASD / 方向键", "左右、前后纵深自由移动"}, -- 66
	{"鼠标 + 左键 / Q", "瞄准发射火铳 · Q 随时开换弹盘"}, -- 67
	{"按住 SHIFT / SPACE", "贴靠掩体挡弹 · 平地翻滚或翻越"}, -- 68
	{"E / 1·2·3", "交互推车工台 · 数字键选护送本领"}, -- 69
	{"拖线 / 方向+回车", "慢时 3×3 换弹盘 · 右键/退格重画"}, -- 70
	{"ESC / R / T", "暂歇菜单 / 重试检查点 / 切神器"} -- 71
}, childRows = { -- 73
	{"A / D · ← / →", "左右潜行"}, -- 74
	{"按住 SHIFT", "轻步慢走（压低脚步声）"}, -- 75
	{"按住 S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 76
	{"SPACE", "跳跃攀上石阶与矮台"}, -- 77
	{"E", "拾瓶 / 敲塔门 / 按住+D 拉车"}, -- 78
	{"F 按住→松开", "瞄准砖地/铁盆投瓶 · 右键取消"} -- 79
}} -- 79
local GUIDE_GAMEPAD = {subtitle = "手柄操作说明 · 全平台通用", soldierRows = { -- 83
	{"左摇杆 / 十字键", "左右、前后纵深移动"}, -- 86
	{"右摇杆 + RT / X", "360° 瞄准与发射火铳（含轻磁吸）"}, -- 87
	{"按住 LT / LB", "贴靠柜台 / 街垒挡下铅丸"}, -- 88
	{"A 键", "平地翻滚 / 靠近矮柜翻越"}, -- 89
	{"Y / RB 键", "递物 / 轻敲安抚 / 按住推车"}, -- 90
	{"摇杆直推 / 触屏", "慢时连线换弹 · B 键清空重画"} -- 91
}, childRows = { -- 93
	{"左摇杆轻推", "内圈轻步慢走（LT/LB 亦可）"}, -- 94
	{"B 键", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 95
	{"A 键", "跳跃攀上石阶与矮台"}, -- 96
	{"Y / RB 键", "拾瓶 / 敲塔门 / 握柄拉车"}, -- 97
	{"RT/X 按住→松开", "右摇杆调落点投瓶 · B 取消"}, -- 98
	{"START / BACK", "暂歇 / 长按重试 · L3 切神器"} -- 99
}} -- 99
local GUIDE_TOUCH = {subtitle = "触屏操作说明 · 横屏全屏 / 竖屏掌机台", soldierRows = { -- 103
	{"左水墨摇杆", "全向走位与里外道切线"}, -- 106
	{"点屏 / 开火钮", "直点射击或拖住开火钮 360° 精瞄"}, -- 107
	{"掩体开关", "轻点贴靠掩体，再点或翻滚离掩"}, -- 108
	{"翻滚 / 翻越", "平地翻滚，贴近矮柜自动翻越"}, -- 109
	{"交互 / 推车", "点推车自动锁握柄，长按牵手交物"}, -- 110
	{"换弹九宫格", "单指一笔滑连至右上，点重画清空"} -- 111
}, childRows = { -- 113
	{"摇杆内圈 / 轻步", "轻推内圈或点轻步压低脚步声"}, -- 114
	{"蹲伏开关", "点按蹲下钻桌穿拱，点跳顺滑起身"}, -- 115
	{"跳跃钮", "攀上石阶、红布车与矮台"}, -- 116
	{"投瓶拖瞄", "按住投瓶拖向砖地，拖回取消圈放弃"}, -- 117
	{"交互 / 拉车", "拾瓶、敲塔门、点拉车锁定握柄"}, -- 118
	{"右上暂歇 / 竖屏", "顶栏随时暂歇，竖屏自动展掌机台"} -- 119
}} -- 119
local function keyTagWeb(action, mode, layout) -- 123
	if mode == "gamepad" then -- 124
		local confirmBtn = layout == "nintendo" and "B" or "A" -- 125
		local backBtn = layout == "nintendo" and "A" or "B" -- 126
		if action == "interact" then -- 127
			return "Y / RB" -- 127
		end -- 127
		if action == "jump" then -- 128
			return "A" -- 128
		end -- 128
		if action == "crouch" then -- 129
			return "B" -- 129
		end -- 129
		if action == "cover" then -- 130
			return "LT / LB" -- 130
		end -- 130
		if action == "fire" then -- 131
			return "RT / X" -- 131
		end -- 131
		if action == "aim" then -- 132
			return "RT / X" -- 132
		end -- 132
		if action == "pause" then -- 133
			return "START" -- 133
		end -- 133
		if action == "retry" then -- 134
			return "长按 BACK" -- 134
		end -- 134
		if action == "confirm" then -- 135
			return confirmBtn -- 135
		end -- 135
		if action == "back" then -- 136
			return backBtn -- 136
		end -- 136
		return "L3" -- 137
	end -- 137
	if mode == "touch" then -- 139
		if action == "interact" then -- 140
			return "点按" -- 140
		end -- 140
		if action == "jump" then -- 141
			return "跳/滚" -- 141
		end -- 141
		if action == "crouch" then -- 142
			return "蹲伏" -- 142
		end -- 142
		if action == "cover" then -- 143
			return "掩体" -- 143
		end -- 143
		if action == "fire" then -- 144
			return "开火" -- 144
		end -- 144
		if action == "aim" then -- 145
			return "拖投瓶" -- 145
		end -- 145
		if action == "pause" then -- 146
			return "暂歇" -- 146
		end -- 146
		if action == "retry" then -- 147
			return "重试" -- 147
		end -- 147
		if action == "confirm" then -- 148
			return "点选" -- 148
		end -- 148
		if action == "back" then -- 149
			return "返回" -- 149
		end -- 149
		return "穿梭" -- 150
	end -- 150
	if action == "interact" then -- 152
		return "E" -- 152
	end -- 152
	if action == "jump" then -- 153
		return "SPACE" -- 153
	end -- 153
	if action == "crouch" then -- 154
		return "CTRL" -- 154
	end -- 154
	if action == "cover" then -- 155
		return "SHIFT" -- 155
	end -- 155
	if action == "fire" then -- 156
		return "左键" -- 156
	end -- 156
	if action == "aim" then -- 157
		return "F" -- 157
	end -- 157
	if action == "pause" then -- 158
		return "ESC" -- 158
	end -- 158
	if action == "retry" then -- 159
		return "R" -- 159
	end -- 159
	if action == "confirm" then -- 160
		return "ENTER" -- 160
	end -- 160
	if action == "back" then -- 161
		return "ESC" -- 161
	end -- 161
	return "T" -- 162
end -- 123
local function adaptWorldKeyTagWeb(rawKeyTag, mode) -- 165
	if mode == "kbm" then -- 166
		return rawKeyTag -- 166
	end -- 166
	if mode == "gamepad" then -- 167
		if rawKeyTag == "E" then -- 168
			return "Y" -- 168
		end -- 168
		if rawKeyTag == "按住 E" then -- 169
			return "按住 Y" -- 169
		end -- 169
		if rawKeyTag == "松开再按住 E" then -- 170
			return "松开再按 Y" -- 170
		end -- 170
		if rawKeyTag == "按住 E + D" then -- 171
			return "按住 Y + 右" -- 171
		end -- 171
		if rawKeyTag == "E 握柄 + D" then -- 172
			return "Y 握柄 + 右" -- 172
		end -- 172
		if rawKeyTag == "F" or rawKeyTag == "左键" then -- 173
			return "RT / X" -- 173
		end -- 173
		if rawKeyTag == "按住 F" then -- 174
			return "按住 RT" -- 174
		end -- 174
		if rawKeyTag == "松开 F" then -- 175
			return "松开 RT" -- 175
		end -- 175
		if rawKeyTag == "按住 Ctrl" then -- 176
			return "按住 B" -- 176
		end -- 176
		if rawKeyTag == "按住 Shift" then -- 177
			return "按住 LT" -- 177
		end -- 177
		if rawKeyTag == "连线" then -- 178
			return "摇杆/触屏连线" -- 178
		end -- 178
		if rawKeyTag == "→" then -- 179
			return "右推摇杆" -- 179
		end -- 179
		return rawKeyTag -- 180
	end -- 180
	if rawKeyTag == "E" then -- 182
		return "轻触" -- 182
	end -- 182
	if rawKeyTag == "按住 E" then -- 183
		return "长按交互" -- 183
	end -- 183
	if rawKeyTag == "松开再按住 E" then -- 184
		return "松开再长按" -- 184
	end -- 184
	if rawKeyTag == "按住 E + D" or rawKeyTag == "E 握柄 + D" then -- 185
		return "点推车+摇杆" -- 185
	end -- 185
	if rawKeyTag == "F" or rawKeyTag == "左键" then -- 186
		return "开火" -- 186
	end -- 186
	if rawKeyTag == "按住 F" then -- 187
		return "拖投瓶" -- 187
	end -- 187
	if rawKeyTag == "松开 F" then -- 188
		return "松手投" -- 188
	end -- 188
	if rawKeyTag == "按住 Ctrl" then -- 189
		return "点蹲伏" -- 189
	end -- 189
	if rawKeyTag == "按住 Shift" then -- 190
		return "点掩体" -- 190
	end -- 190
	if rawKeyTag == "连线" then -- 191
		return "一笔划连" -- 191
	end -- 191
	return rawKeyTag -- 192
end -- 165
local function adaptHintSentenceWeb(text, mode, layout) -- 195
	if mode == "kbm" or text == "" then -- 196
		return text -- 196
	end -- 196
	if mode == "gamepad" then -- 197
		local backBtn = layout == "nintendo" and "A" or "B" -- 198
		return table.concat( -- 199
			__TS__StringSplit( -- 199
				table.concat( -- 199
					__TS__StringSplit( -- 199
						table.concat( -- 199
							__TS__StringSplit( -- 199
								table.concat( -- 199
									__TS__StringSplit( -- 199
										table.concat( -- 199
											__TS__StringSplit( -- 199
												table.concat( -- 199
													__TS__StringSplit( -- 199
														table.concat( -- 199
															__TS__StringSplit( -- 199
																table.concat( -- 199
																	__TS__StringSplit( -- 199
																		table.concat( -- 199
																			__TS__StringSplit( -- 199
																				table.concat( -- 199
																					__TS__StringSplit( -- 199
																						table.concat( -- 199
																							__TS__StringSplit( -- 199
																								table.concat( -- 199
																									__TS__StringSplit( -- 199
																										table.concat( -- 199
																											__TS__StringSplit( -- 199
																												table.concat( -- 199
																													__TS__StringSplit( -- 199
																														table.concat( -- 199
																															__TS__StringSplit( -- 199
																																table.concat( -- 199
																																	__TS__StringSplit( -- 199
																																		table.concat( -- 199
																																			__TS__StringSplit( -- 199
																																				table.concat( -- 199
																																					__TS__StringSplit( -- 199
																																						table.concat( -- 199
																																							__TS__StringSplit( -- 199
																																								table.concat( -- 199
																																									__TS__StringSplit( -- 199
																																										table.concat( -- 199
																																											__TS__StringSplit(text, "[SHIFT]"), -- 199
																																											"[LT/LB]" -- 200
																																										), -- 200
																																										"[CTRL]" -- 201
																																									), -- 201
																																									"[B]" -- 201
																																								), -- 201
																																								"[E]+[D]" -- 202
																																							), -- 202
																																							"[Y]+右推" -- 202
																																						), -- 202
																																						"[E]" -- 203
																																					), -- 203
																																					"[Y]" -- 203
																																				), -- 203
																																				"[F]" -- 204
																																			), -- 204
																																			"[RT/X]" -- 204
																																		), -- 204
																																		"[SPACE]" -- 205
																																	), -- 205
																																	"[A]" -- 205
																																), -- 205
																																"[W/S]" -- 206
																															), -- 206
																															"左摇杆上下" -- 206
																														), -- 206
																														"[A/D]" -- 207
																													), -- 207
																													"左摇杆左右" -- 207
																												), -- 207
																												"[W]" -- 208
																											), -- 208
																											"左摇杆向上" -- 208
																										), -- 208
																										"[S]" -- 209
																									), -- 209
																									"左摇杆向下" -- 209
																								), -- 209
																								"[ESC]" -- 210
																							), -- 210
																							"[START]" -- 210
																						), -- 210
																						"[R]" -- 211
																					), -- 211
																					"长按 [BACK]" -- 211
																				), -- 211
																				"鼠标瞄准，左键发射火铳" -- 212
																			), -- 212
																			"右摇杆瞄准，按 [RT/X] 发射火铳" -- 212
																		), -- 212
																		"左键先手击倒" -- 213
																	), -- 213
																	"按 [RT/X] 先手击倒" -- 213
																), -- 213
																"左键发射火铳" -- 214
															), -- 214
															"按 [RT/X] 发射火铳" -- 214
														), -- 214
														"左键发铳" -- 215
													), -- 215
													"按 [RT/X] 发铳" -- 215
												), -- 215
												"按 E 再次启程" -- 216
											), -- 216
											"按 Y 再次启程" -- 216
										), -- 216
										"按住 E" -- 217
									), -- 217
									"按住 Y" -- 217
								), -- 217
								"方向键" -- 218
							), -- 218
							"左摇杆" -- 218
						), -- 218
						"Esc 暂歇" -- 219
					), -- 219
					"START 暂歇" -- 219
				), -- 219
				"返回" -- 220
			), -- 220
			("按 " .. backBtn) .. " 返回" or "," -- 220
		) -- 220
	end -- 220
	return table.concat( -- 222
		__TS__StringSplit( -- 222
			table.concat( -- 222
				__TS__StringSplit( -- 222
					table.concat( -- 222
						__TS__StringSplit( -- 222
							table.concat( -- 222
								__TS__StringSplit( -- 222
									table.concat( -- 222
										__TS__StringSplit( -- 222
											table.concat( -- 222
												__TS__StringSplit( -- 222
													table.concat( -- 222
														__TS__StringSplit( -- 222
															table.concat( -- 222
																__TS__StringSplit( -- 222
																	table.concat( -- 222
																		__TS__StringSplit( -- 222
																			table.concat( -- 222
																				__TS__StringSplit( -- 222
																					table.concat( -- 222
																						__TS__StringSplit( -- 222
																							table.concat( -- 222
																								__TS__StringSplit( -- 222
																									table.concat( -- 222
																										__TS__StringSplit( -- 222
																											table.concat( -- 222
																												__TS__StringSplit( -- 222
																													table.concat( -- 222
																														__TS__StringSplit( -- 222
																															table.concat( -- 222
																																__TS__StringSplit( -- 222
																																	table.concat( -- 222
																																		__TS__StringSplit( -- 222
																																			table.concat( -- 222
																																				__TS__StringSplit( -- 222
																																					table.concat( -- 222
																																						__TS__StringSplit( -- 222
																																							table.concat( -- 222
																																								__TS__StringSplit( -- 222
																																									table.concat( -- 222
																																										__TS__StringSplit( -- 222
																																											table.concat( -- 222
																																												__TS__StringSplit( -- 222
																																													table.concat( -- 222
																																														__TS__StringSplit( -- 222
																																															table.concat( -- 222
																																																__TS__StringSplit( -- 222
																																																	table.concat( -- 222
																																																		__TS__StringSplit( -- 222
																																																			table.concat( -- 222
																																																				__TS__StringSplit( -- 222
																																																					table.concat( -- 222
																																																						__TS__StringSplit( -- 222
																																																							table.concat( -- 222
																																																								__TS__StringSplit( -- 222
																																																									table.concat( -- 222
																																																										__TS__StringSplit( -- 222
																																																											table.concat( -- 222
																																																												__TS__StringSplit( -- 222
																																																													table.concat( -- 222
																																																														__TS__StringSplit(text, "按住 [E]+[D]"), -- 222
																																																														"点按推/拉车并推摇杆" -- 223
																																																													), -- 223
																																																													"[E]+[D]" -- 224
																																																												), -- 224
																																																												"推/拉车并推摇杆" -- 224
																																																											), -- 224
																																																											"速按 [CTRL]" -- 225
																																																										), -- 225
																																																										"点按「蹲伏」" -- 225
																																																									), -- 225
																																																									"按住 [CTRL]" -- 226
																																																								), -- 226
																																																								"点按「蹲伏」" -- 226
																																																							), -- 226
																																																							"按 [CTRL]" -- 227
																																																						), -- 227
																																																						"点按「蹲伏」" -- 227
																																																					), -- 227
																																																					"[CTRL]" -- 228
																																																				), -- 228
																																																				"「蹲伏」" -- 228
																																																			), -- 228
																																																			"按住 [SHIFT]" -- 229
																																																		), -- 229
																																																		"点按「轻步/掩体」" -- 229
																																																	), -- 229
																																																	"[SHIFT]" -- 230
																																																), -- 230
																																																"「轻步/掩体」" -- 230
																																															), -- 230
																																															"按住 [F]" -- 231
																																														), -- 231
																																														"按住「投瓶」拖拽" -- 231
																																													), -- 231
																																													"[F]" -- 232
																																												), -- 232
																																												"「投瓶」" -- 232
																																											), -- 232
																																											"按住 E" -- 233
																																										), -- 233
																																										"长按「交互」" -- 233
																																									), -- 233
																																									"按 [E]" -- 234
																																								), -- 234
																																								"点按「交互」" -- 234
																																							), -- 234
																																							"[E]" -- 235
																																						), -- 235
																																						"「交互」" -- 235
																																					), -- 235
																																					"方向键" -- 236
																																				), -- 236
																																				"左下摇杆" -- 236
																																			), -- 236
																																			"按 [ESC]" -- 237
																																		), -- 237
																																		"轻触右上「暂歇」" -- 237
																																	), -- 237
																																	"[ESC]" -- 238
																																), -- 238
																																"右上「暂歇」" -- 238
																															), -- 238
																															"按 [SPACE]" -- 239
																														), -- 239
																														"点按「翻滚/跳跃」" -- 239
																													), -- 239
																													"[SPACE]" -- 240
																												), -- 240
																												"「翻滚/跳跃」" -- 240
																											), -- 240
																											"按 [R]" -- 241
																										), -- 241
																										"在暂歇菜单重试" -- 241
																									), -- 241
																									"[A/D]" -- 242
																								), -- 242
																								"左下摇杆" -- 242
																							), -- 242
																							"[W/S]" -- 243
																						), -- 243
																						"摇杆上下" -- 243
																					), -- 243
																					"[W]" -- 244
																				), -- 244
																				"摇杆向上" -- 244
																			), -- 244
																			"[S]" -- 245
																		), -- 245
																		"摇杆向下" -- 245
																	), -- 245
																	"鼠标瞄准，左键发射火铳" -- 246
																), -- 246
																"点屏或拖「开火」发射火铳" -- 246
															), -- 246
															"左键先手击倒" -- 247
														), -- 247
														"点屏或「开火」先手击倒" -- 247
													), -- 247
													"左键发射火铳" -- 248
												), -- 248
												"点屏或「开火」发射火铳" -- 248
											), -- 248
											"左键发铳" -- 249
										), -- 249
										"点屏或「开火」发铳" -- 249
									), -- 249
									"左键" -- 250
								), -- 250
								"点屏或「开火」" -- 250
							), -- 250
							"鼠标" -- 251
						), -- 251
						"触屏" -- 251
					), -- 251
					"按 E 再次启程" -- 252
				), -- 252
				"轻触屏幕再次启程" -- 252
			), -- 252
			"Esc 暂歇" -- 253
		), -- 253
		"轻触右上暂歇" -- 253
	) -- 253
end -- 195
local WebInputDriver = __TS__Class() -- 256
WebInputDriver.name = "WebInputDriver" -- 256
function WebInputDriver.prototype.____constructor(self, settings) -- 264
	self.defaultMode = "kbm" -- 257
	self.kbm = __TS__New(KbmPoller) -- 258
	self.settings = settings -- 265
	self.touchRouter = __TS__New(TouchRouter, settings, {enableMouseCompat = true, enablePortrait = true}) -- 266
	self.gamepadRouter = __TS__New(GamepadRouter, settings) -- 270
end -- 264
function WebInputDriver.prototype.attach(self, parent, hooks) -- 273
	self.kbm:attach(parent, hooks) -- 274
	self.touchRouter:attach(parent) -- 275
	self.gamepadRouter:attach(parent) -- 276
	if self.touchControls == nil then -- 277
		self.touchControls = __TS__New(TouchControls, parent, PORTRAIT_TOUCH_DELEGATE) -- 278
	end -- 278
end -- 273
function WebInputDriver.prototype.syncFrame(self, ctx) -- 282
	local vp = ctx.viewport -- 283
	local p = ctx.play -- 284
	local isPlayMode = ctx.mode == 1 and ctx.screen == "play" and p ~= nil -- 285
	local gameplayActive = isPlayMode -- 286
	local talentModalOpen = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and p.talentModalActive and #p:getStoryTalentOffers() > 0 -- 287
	local escortSummaryOpen = isPlayMode and p ~= nil and not p.paused and p.escortFailed -- 289
	local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active or talentModalOpen or escortSummaryOpen) -- 291
	local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 293
	local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 294
	local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and (#ctx.storyTalentBoxes > 0 and #ctx.storyTalentBoxes or #p:getStoryTalentOffers()) or 0 -- 295
	local ____temp_0 -- 298
	if isPlayMode and p ~= nil then -- 298
		____temp_0 = isCutsceneBlockingPlay(p) -- 298
	else -- 298
		____temp_0 = false -- 298
	end -- 298
	local cutsceneBlocking = ____temp_0 -- 298
	local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 299
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 301
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and p.escort.state ~= "calming" -- 302
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 304
	local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 306
	local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 309
	local enemyTargets = canShoot and self.settings.aimAssist and p ~= nil and collectAimTargets(p, ctx.cam, vp.stageW, vp.stageH) or ({}) -- 312
	if self.touchControls ~= nil then -- 316
		local pref = self.settings.modePref -- 317
		self.touchControls:syncContext({ -- 318
			viewport = vp, -- 319
			mode = ctx.mode, -- 320
			screen = ctx.screen, -- 321
			play = p, -- 322
			run = ctx.run, -- 323
			cam = ctx.cam, -- 324
			router = self.touchRouter, -- 325
			overlayActive = self:shouldShowTouchControls(ctx.input, vp), -- 326
			allowAutoGameplayTouch = pref == "auto" or pref == "touch", -- 327
			allowMouseOnOverlay = vp.isPortrait or pref == "touch", -- 328
			showWebTopPills = true, -- 329
			canToggleFullscreen = true, -- 330
			assistHintsEnabled = ctx.assistHintsEnabled, -- 331
			isMuted = ctx.isMuted, -- 332
			isFullscreen = ctx.isFullscreen, -- 333
			storyTalentBoxes = ctx.storyTalentBoxes, -- 334
			escortDeathBoxes = ctx.escortDeathBoxes, -- 335
			ledgerButtonBox = ctx.ledgerButtonBox, -- 336
			enemyTargets = enemyTargets, -- 337
			dt = ctx.dt -- 338
		}) -- 338
	end -- 338
	local muzzle = p ~= nil and projectMuzzle(p, ctx.cam) or nil -- 342
	local playerScreenX = muzzle and muzzle.x or vp.stageW * 0.5 -- 343
	local playerScreenY = muzzle and muzzle.y or vp.stageH * 0.38 -- 344
	local gpCtx = { -- 346
		stageW = vp.stageW, -- 347
		stageH = vp.stageH, -- 348
		uiScale = vp.uiScale, -- 349
		modal = modal, -- 350
		gameplayActive = gameplayActive, -- 351
		reloadActive = reloadActive, -- 352
		craftActive = craftActive, -- 353
		talentOfferCount = talentOfferCount, -- 354
		childMode = p ~= nil and p.childMode, -- 355
		allowDepth = allowDepth, -- 356
		canShoot = canShoot, -- 357
		canBottleAim = canBottleAim, -- 358
		playerRolling = p ~= nil and p.player.rollT > 0, -- 359
		inLowArch = inLowArch, -- 360
		inTowerEnd = inTowerEnd, -- 361
		playerFacing = p ~= nil and p.player.facing or 1, -- 362
		playerScreenX = playerScreenX, -- 363
		playerScreenY = playerScreenY, -- 364
		enemyTargets = enemyTargets -- 365
	} -- 365
	self.gamepadRouter:setFrameContext(gpCtx, ctx.dt) -- 367
end -- 282
function WebInputDriver.prototype.renderOverlay(self) -- 370
	local ____opt_5 = self.touchControls -- 371
	if ____opt_5 ~= nil then -- 371
		____opt_5:render(self.touchRouter) -- 371
	end -- 371
end -- 370
function WebInputDriver.prototype.clearTransient(self, keepTouchToggles) -- 374
	self.touchRouter:releaseAll(keepTouchToggles) -- 375
	self.gamepadRouter:clearTransient() -- 376
end -- 374
function WebInputDriver.prototype.vibrate(self, seconds) -- 379
	self.touchRouter:vibrate(seconds) -- 380
end -- 379
function WebInputDriver.prototype.onInputModeChanged(self, mode) -- 383
	if mode ~= "touch" then -- 384
		self.touchRouter:releaseAll(false) -- 385
	end -- 385
end -- 383
function WebInputDriver.prototype.shouldShowTouchControls(self, input, vp) -- 389
	if vp.isPortrait then -- 390
		return true -- 390
	end -- 390
	if self.settings.modePref == "touch" then -- 391
		return true -- 391
	end -- 391
	if self.settings.modePref == "kbm" or self.settings.modePref == "gamepad" then -- 392
		return false -- 392
	end -- 392
	return input.inputMode == "touch" -- 393
end -- 389
function WebInputDriver.prototype.getTouchRouter(self) -- 396
	return self.touchRouter -- 397
end -- 396
function WebInputDriver.prototype.getGamepadRouter(self) -- 400
	return self.gamepadRouter -- 401
end -- 400
function WebInputDriver.prototype.getTouchControls(self) -- 404
	return self.touchControls -- 405
end -- 404
function WebInputDriver.prototype.injectTouch(self, phase, id, x, y, fromMouse) -- 408
	self.touchRouter:injectTouch( -- 409
		phase, -- 409
		id, -- 409
		x, -- 409
		y, -- 409
		fromMouse == true -- 409
	) -- 409
end -- 408
function WebInputDriver.prototype.setGamepadSim(self, state) -- 412
	self.gamepadRouter:setSimulatedState(state) -- 413
end -- 412
function WebInputDriver.prototype.pollInto(self, input) -- 416
	input.gamepadLayout = self.settings.gamepadLayout -- 417
	local touch = self.touchRouter:consumeSnapshot() -- 418
	local gp = self.gamepadRouter:consumeSnapshot() -- 419
	local kbm = self.kbm:sample(input:getStageViewport()) -- 420
	local suppressMouse = touch.suppressSyntheticMouse or touch.mouseConsumedByOverlay -- 422
	local realMouseActive = not suppressMouse and (kbm.mouseMoved or kbm.mouseClicked and kbm.mouseInsideStage) -- 423
	if kbm.anyKb or realMouseActive or gp.hadGamepadInput or touch.hadRealTouch then -- 425
		input.userInteracted = true -- 426
	end -- 426
	if self.settings.modePref ~= "auto" then -- 429
		input:setInputMode(self.settings.modePref) -- 430
	elseif gp.hadGamepadInput then -- 431
		input:setInputMode("gamepad") -- 432
	elseif touch.hadGameplayTouch then -- 433
		input:setInputMode("touch") -- 434
	elseif kbm.anyKb or realMouseActive then -- 435
		input:setInputMode("kbm") -- 436
	elseif touch.hadUiTouch and input.inputMode == "kbm" then -- 437
		input:setInputMode("touch") -- 438
	end -- 438
	input.moveX = kbm.moveX ~= 0 and kbm.moveX or (gp.moveX ~= 0 and gp.moveX or touch.moveX) -- 441
	input.moveY = kbm.moveY ~= 0 and kbm.moveY or (gp.moveY ~= 0 and gp.moveY or touch.moveY) -- 442
	local allowMouseFire = not suppressMouse and input.inputMode == "kbm" and kbm.mouseInsideStage -- 444
	local rawFireHeld = allowMouseFire and kbm.mouseLeft or gp.fireHeld or touch.fireHeld -- 445
	input:applyKeyHeld( -- 447
		kbm.jump or gp.jumpHeld or touch.jumpHeld, -- 448
		kbm.crouch or gp.crouchHeld or touch.crouchHeld, -- 449
		kbm.cover or gp.coverHeld or touch.coverHeld, -- 450
		kbm.interact or gp.interactHeld or touch.interactHeld, -- 451
		kbm.aim or gp.aimHeld or touch.aimHeld, -- 452
		rawFireHeld, -- 453
		kbm.flare or gp.flareHeld, -- 454
		kbm.pause, -- 455
		kbm.retry, -- 456
		kbm.toggleView, -- 457
		kbm.tab -- 458
	) -- 458
	input:resetFrameSignals() -- 461
	input.navUp = kbm.navUp -- 464
	input.navDown = kbm.navDown -- 465
	input.navLeft = kbm.navLeft -- 466
	input.navRight = kbm.navRight -- 467
	input.navConfirm = kbm.navConfirm -- 468
	input.craftConfirm = kbm.uiConfirmWithE -- 469
	input.craftCancel = kbm.uiBackSpace -- 470
	local kCol = (kbm.navRight and 1 or 0) - (kbm.navLeft and 1 or 0) -- 471
	local kRow = (kbm.navUp and 1 or 0) - (kbm.navDown and 1 or 0) -- 472
	if kCol ~= 0 or kRow ~= 0 then -- 473
		input.reloadDirCol = kCol -- 474
		input.reloadDirRow = kRow -- 475
		input.reloadStepEdge = true -- 476
		input.reloadAutoStep = false -- 477
	end -- 477
	input.reloadConfirm = kbm.uiConfirmWithE -- 479
	input.reloadReset = kbm.uiBackSpace -- 480
	if gp.jumpPressed then -- 482
		input.jump.pressed = true -- 482
	end -- 482
	if gp.crouchPressed then -- 483
		input.crouch.pressed = true -- 483
	end -- 483
	if gp.interactPressed then -- 484
		input.interact.pressed = true -- 484
	end -- 484
	if gp.aimPressed then -- 485
		input.aim.pressed = true -- 485
	end -- 485
	if gp.firePressed then -- 486
		input.fire.pressed = true -- 486
	end -- 486
	if gp.flarePressed then -- 487
		input.flare.pressed = true -- 487
	end -- 487
	if gp.pausePressed then -- 488
		input.pause.pressed = true -- 488
	end -- 488
	if gp.retryPressed then -- 489
		input.retry.pressed = true -- 489
	end -- 489
	if gp.artifactPressed then -- 490
		input.artifactTogglePressed = true -- 490
	end -- 490
	if gp.anyButtonPressed then -- 491
		input.splashSkipPressed = true -- 491
	end -- 491
	if gp.bottleCanceled then -- 492
		input.bottleCanceled = true -- 493
		input.aim.held = false -- 494
		input.aim.pressed = false -- 495
		input.aim.released = false -- 496
	end -- 496
	if gp.navUp then -- 498
		input.navUp = true -- 498
	end -- 498
	if gp.navDown then -- 499
		input.navDown = true -- 499
	end -- 499
	if gp.navLeft then -- 500
		input.navLeft = true -- 500
	end -- 500
	if gp.navRight then -- 501
		input.navRight = true -- 501
	end -- 501
	if gp.navConfirm then -- 502
		input.navConfirm = true -- 503
		input.craftConfirm = true -- 504
	end -- 504
	if gp.navBack then -- 506
		input.navBack = true -- 507
		input.craftCancel = true -- 508
	end -- 508
	input.navPrevTab = gp.navPrevTab -- 510
	input.navNextTab = gp.navNextTab -- 511
	if gp.reloadStepEdge then -- 512
		input.reloadDirCol = gp.reloadDirCol -- 513
		input.reloadDirRow = gp.reloadDirRow -- 514
		input.reloadStepEdge = true -- 515
		input.reloadAutoStep = gp.reloadAutoStep -- 516
	end -- 516
	if gp.reloadConfirm then -- 518
		input.reloadConfirm = true -- 518
	end -- 518
	if gp.reloadReset then -- 519
		input.reloadReset = true -- 519
	end -- 519
	input.talentDelta = gp.talentDelta -- 520
	input.talentConfirm = gp.talentConfirm -- 521
	input.retryHoldProgress = gp.retryHoldProgress -- 522
	if touch.jumpPressed then -- 524
		input.jump.pressed = true -- 524
	end -- 524
	if touch.interactPressed then -- 525
		input.interact.pressed = true -- 525
	end -- 525
	if touch.firePressed then -- 526
		input.fire.pressed = true -- 526
	end -- 526
	if touch.pausePressed then -- 527
		input.pause.pressed = true -- 527
	end -- 527
	if touch.retryPressed then -- 528
		input.retry.pressed = true -- 528
	end -- 528
	if touch.artifactPressed then -- 529
		input.artifactTogglePressed = true -- 529
	end -- 529
	if touch.mutePressed then -- 530
		input.muteTogglePressed = true -- 530
	end -- 530
	if touch.fullscreenPressed then -- 531
		input.fullscreenTogglePressed = true -- 531
	end -- 531
	if touch.anyTapBegan then -- 532
		input.splashSkipPressed = true -- 532
	end -- 532
	if touch.zoneTap ~= "" then -- 533
		input.touchZoneTap = touch.zoneTap -- 533
	end -- 533
	if touch.navUp then -- 534
		input.navUp = true -- 534
	end -- 534
	if touch.navDown then -- 535
		input.navDown = true -- 535
	end -- 535
	if touch.navLeft then -- 536
		input.navLeft = true -- 536
	end -- 536
	if touch.navRight then -- 537
		input.navRight = true -- 537
	end -- 537
	if touch.navConfirm then -- 538
		input.navConfirm = true -- 539
		input.craftConfirm = true -- 540
	end -- 540
	if touch.navBack then -- 542
		input.navBack = true -- 543
		input.craftCancel = true -- 544
	end -- 544
	if touch.bottleCanceled then -- 546
		input.bottleCanceled = true -- 547
		input.aim.held = false -- 548
		input.aim.pressed = false -- 549
		input.aim.released = false -- 550
	end -- 550
	if not suppressMouse and input.inputMode == "kbm" and input.aim.held and kbm.mouseRightPressed then -- 553
		input.bottleCanceled = true -- 554
		input.aim.held = false -- 555
		input.aim.pressed = false -- 556
		input.aim.released = false -- 557
	end -- 557
	input:applyPickRoom(kbm.pick) -- 560
	input.frameInteractPressed = input.interact.pressed -- 561
	if touch.uiHeld or touch.uiPressed or touch.uiReleased or touch.uiInside then -- 563
		input.uiX = touch.uiX -- 564
		input.uiY = touch.uiY -- 565
		input.uiDx = touch.uiDx -- 566
		input.uiDy = touch.uiDy -- 567
		input.uiInside = touch.uiInside -- 568
		input.uiHeld = touch.uiHeld -- 569
		input.uiPressed = touch.uiPressed -- 570
		input.uiReleased = touch.uiReleased -- 571
		input.uiRightPressed = false -- 572
		if touch.uiHeld or touch.uiPressed then -- 573
			input.mdx = touch.uiDx -- 574
			input.mdy = touch.uiDy -- 575
			input.mx = touch.uiX -- 576
			input.my = touch.uiY -- 577
			input.inside = true -- 578
		elseif touch.hasAim then -- 579
			input.mdx = touch.aimX - input.mx -- 580
			input.mdy = touch.aimY - input.my -- 581
			input.mx = touch.aimX -- 582
			input.my = touch.aimY -- 583
			input.inside = true -- 584
		else -- 584
			input.mdx = 0 -- 586
			input.mdy = 0 -- 587
			input.inside = touch.uiInside -- 588
		end -- 588
		return -- 590
	end -- 590
	if input.inputMode == "gamepad" then -- 593
		if gp.hasAim then -- 594
			input.mdx = gp.aimX - input.mx -- 595
			input.mdy = gp.aimY - input.my -- 596
			input.mx = gp.aimX -- 597
			input.my = gp.aimY -- 598
			input.inside = true -- 599
		else -- 599
			input.mdx = 0 -- 601
			input.mdy = 0 -- 602
			input.inside = false -- 603
		end -- 603
		if not suppressMouse and kbm.mouseInsideStage and (kbm.mouseLeft or kbm.mouseLeftPressed or kbm.mouseLeftReleased) then -- 605
			input.uiDx = kbm.mouseStageX - input.uiX -- 606
			input.uiDy = kbm.mouseStageY - input.uiY -- 607
			input.uiX = kbm.mouseStageX -- 608
			input.uiY = kbm.mouseStageY -- 609
			input.uiInside = true -- 610
			input.uiHeld = kbm.mouseLeft -- 611
			input.uiPressed = kbm.mouseLeftPressed -- 612
			input.uiReleased = kbm.mouseLeftReleased -- 613
			input.uiRightPressed = kbm.mouseRightPressed -- 614
		else -- 614
			input.uiX = input.mx -- 616
			input.uiY = input.my -- 617
			input.uiDx = 0 -- 618
			input.uiDy = 0 -- 619
			input.uiInside = false -- 620
			input.uiHeld = false -- 621
			input.uiPressed = false -- 622
			input.uiReleased = false -- 623
			input.uiRightPressed = false -- 624
		end -- 624
		return -- 626
	end -- 626
	if input.inputMode == "touch" then -- 629
		if touch.hasAim then -- 630
			input.mdx = touch.aimX - input.mx -- 631
			input.mdy = touch.aimY - input.my -- 632
			input.mx = touch.aimX -- 633
			input.my = touch.aimY -- 634
			input.inside = true -- 635
		else -- 635
			input.mdx = 0 -- 637
			input.mdy = 0 -- 638
			input.inside = false -- 639
		end -- 639
		if not suppressMouse and kbm.mouseInsideStage and (kbm.mouseLeft or kbm.mouseLeftPressed or kbm.mouseLeftReleased) then -- 641
			input.uiDx = kbm.mouseStageX - input.uiX -- 642
			input.uiDy = kbm.mouseStageY - input.uiY -- 643
			input.uiX = kbm.mouseStageX -- 644
			input.uiY = kbm.mouseStageY -- 645
			input.uiInside = true -- 646
			input.uiHeld = kbm.mouseLeft -- 647
			input.uiPressed = kbm.mouseLeftPressed -- 648
			input.uiReleased = kbm.mouseLeftReleased -- 649
			input.uiRightPressed = kbm.mouseRightPressed -- 650
		else -- 650
			input.uiDx = 0 -- 652
			input.uiDy = 0 -- 653
			input.uiInside = false -- 654
			input.uiHeld = false -- 655
			input.uiPressed = false -- 656
			input.uiReleased = false -- 657
			input.uiRightPressed = false -- 658
		end -- 658
		return -- 660
	end -- 660
	input.mdx = kbm.mouseStageX - input.mx -- 663
	input.mdy = kbm.mouseStageY - input.my -- 664
	input.mx = kbm.mouseStageX -- 665
	input.my = kbm.mouseStageY -- 666
	input.inside = kbm.mouseInsideStage -- 667
	input.uiX = kbm.mouseStageX -- 669
	input.uiY = kbm.mouseStageY -- 670
	input.uiDx = input.mdx -- 671
	input.uiDy = input.mdy -- 672
	input.uiInside = kbm.mouseInsideStage -- 673
	input.uiHeld = not suppressMouse and kbm.mouseLeft and kbm.mouseInsideStage -- 674
	input.uiPressed = not suppressMouse and kbm.mouseLeftPressed and kbm.mouseInsideStage -- 675
	input.uiReleased = not suppressMouse and kbm.mouseLeftReleased -- 676
	input.uiRightPressed = not suppressMouse and kbm.mouseRightPressed and kbm.mouseInsideStage -- 677
end -- 416
____exports.TARGET = { -- 681
	id = "web", -- 682
	supportsKbm = true, -- 683
	supportsTouch = true, -- 684
	supportsGamepad = true, -- 685
	supportsPortrait = true, -- 686
	defaultInputMode = "kbm", -- 687
	supportedModes = {"kbm", "touch", "gamepad"}, -- 688
	modePrefOrder = MODE_PREF_ORDER, -- 689
	controlsGuideTabs = {{mode = "kbm", label = "键鼠"}, {mode = "gamepad", label = "手柄"}, {mode = "touch", label = "触屏"}}, -- 690
	getPlatformCaps = function(self) -- 696
		local cfg = getReleaseConfig() -- 697
		local ____temp_7 -- 710
		if cfg ~= nil and cfg.isRelease ~= nil then -- 710
			____temp_7 = cfg.isRelease == true -- 710
		else -- 710
			____temp_7 = true -- 710
		end -- 710
		return { -- 698
			kind = "web", -- 699
			target = "web", -- 700
			isDesktop = false, -- 701
			isMobile = false, -- 702
			isWeb = true, -- 703
			isStandaloneAndroidApk = false, -- 704
			canToggleFullscreen = true, -- 705
			canQuit = false, -- 706
			hasBackButton = false, -- 707
			supportsHaptics = false, -- 708
			needsAudioUnlock = true, -- 709
			isRelease = ____temp_7, -- 710
			defaultInputMode = "kbm" -- 711
		} -- 711
	end, -- 696
	canToggleFullscreen = function(self) -- 715
		return true -- 716
	end, -- 715
	canQuitApp = function(self) -- 719
		return false -- 720
	end, -- 719
	isReleaseMode = function(self) -- 723
		local cfg = getReleaseConfig() -- 724
		if cfg ~= nil and cfg.isRelease ~= nil then -- 725
			return cfg.isRelease == true -- 726
		end -- 726
		return true -- 728
	end, -- 723
	computeStageViewport = function(self, fullW, fullH) -- 731
		return computeAdaptiveViewport(fullW, fullH) -- 732
	end, -- 731
	triggerHaptics = function(self, seconds, enabled) -- 735
		triggerMobileHaptics(seconds, enabled) -- 736
	end, -- 735
	keyTagFor = function(self, action, mode, layout) -- 739
		return keyTagWeb(action, mode, layout) -- 740
	end, -- 739
	adaptWorldKeyTag = function(self, rawKeyTag, mode, _layout) -- 743
		return adaptWorldKeyTagWeb(rawKeyTag, mode) -- 744
	end, -- 743
	adaptHintSentence = function(self, text, mode, layout) -- 747
		return adaptHintSentenceWeb(text, mode, layout) -- 748
	end, -- 747
	controlsGuideRows = function(self, tab) -- 751
		if tab == "gamepad" then -- 752
			return GUIDE_GAMEPAD -- 752
		end -- 752
		if tab == "touch" then -- 753
			return GUIDE_TOUCH -- 753
		end -- 753
		return GUIDE_KBM -- 754
	end, -- 751
	splashSkipHint = function(self, mode, layout) -- 757
		if mode == "touch" then -- 758
			return "轻触跳过" -- 758
		end -- 758
		if mode == "gamepad" then -- 759
			return keyTagWeb("confirm", "gamepad", layout) .. " / START  跳过" -- 759
		end -- 759
		return "ESC / SPACE  SKIP" -- 760
	end, -- 757
	titleFooterHint = function(self, mode, layout) -- 763
		if mode == "gamepad" then -- 764
			return ("左摇杆 / 十字键择项   ·   " .. keyTagWeb("confirm", "gamepad", layout)) .. " 或点选启程" -- 765
		end -- 765
		if mode == "touch" then -- 767
			return "轻触择项启程   ·   支持键鼠与手柄" -- 767
		end -- 767
		return "上下择项   ·   回车或点选启程" -- 768
	end, -- 763
	chapterFooterHint = function(self, mode, confirmTag) -- 771
		if mode == "gamepad" then -- 772
			return ("摇杆/十字键选择   ·   " .. confirmTag) .. " 或点选进入" -- 772
		end -- 772
		if mode == "touch" then -- 773
			return "轻触驿站预览   ·   再点或轻触入此卷章" -- 773
		end -- 773
		return "方向键选择   ·   回车或点击进入" -- 774
	end, -- 771
	pauseFooterHint = function(self, mode, layout) -- 777
		if mode == "gamepad" then -- 778
			return ((keyTagWeb("back", "gamepad", layout) .. " / START 续行   ·   ") .. keyTagWeb("confirm", "gamepad", layout)) .. " 确认" -- 779
		end -- 779
		if mode == "touch" then -- 781
			return "轻触确认   ·   点「继续游戏」续行" -- 781
		end -- 781
		return "Esc 续行   ·   Enter 或点击确认" -- 782
	end, -- 777
	settingsFooterHint = function(self, mode, layout) -- 785
		if mode == "gamepad" then -- 786
			return ((("左右或 " .. keyTagWeb("confirm", "gamepad", layout)) .. " 切换   ·   ") .. keyTagWeb("back", "gamepad", layout)) .. " 返回暂停" -- 787
		end -- 787
		if mode == "touch" then -- 789
			return "轻触任意条目切换   ·   设置自动保存" -- 789
		end -- 789
		return "←/→ 或回车/点击切换   ·   Esc 返回暂停" -- 790
	end, -- 785
	controlsFooterRightHint = function(self, mode) -- 793
		if mode == "gamepad" then -- 794
			return "LB / RB 或左右切换键位图" -- 794
		end -- 794
		if mode == "touch" then -- 795
			return "轻触右上页签切图 · 暂歇菜单可调操控设置" -- 795
		end -- 795
		return "←/→ 切页   ·   F11 / Alt+Enter 全屏" -- 796
	end, -- 793
	epilogueFooterHint = function(self, mode, layout) -- 799
		if mode == "gamepad" then -- 800
			return ((keyTagWeb("confirm", "gamepad", layout) .. " 确认   ·   ") .. keyTagWeb("back", "gamepad", layout)) .. " 返回标题" -- 801
		end -- 801
		if mode == "touch" then -- 803
			return "轻触任一入口继续" -- 803
		end -- 803
		return "↑/↓ 选择   ·   Enter / 点击确认   ·   Esc 返回标题" -- 804
	end, -- 799
	trialSubHint = function(self, mode, ended, seed) -- 807
		if mode == "gamepad" then -- 808
			return ("种子 " .. tostring(seed)) .. (ended and " · A 再开一局 · START 返回标题" or " · START 继续 · 长按BACK 重开 · Y 返回标题") -- 809
		end -- 809
		if mode == "touch" then -- 811
			return ("种子 " .. tostring(seed)) .. (ended and " · 点下方按钮再开或返回标题" or " · 点下方按钮继续/重开/返回标题") -- 812
		end -- 812
		return ("种子 " .. tostring(seed)) .. (ended and " · R 再开一局 · Esc 返回标题" or " · Esc 继续 · R 重新开局 · E 返回标题") -- 814
	end, -- 807
	settingsRows = function(self) -- 817
		return WEB_SETTINGS_ROWS -- 818
	end, -- 817
	settingsPauseLabel = function(self, settings) -- 821
		return "操控设置 · " .. modePrefLabelOf(settings.modePref) -- 822
	end, -- 821
	settingsHeaderTitle = function(self) -- 825
		return "操控与声音" -- 826
	end, -- 825
	settingsHeaderSummary = function(self, activeMode) -- 829
		return ("当前模式：" .. inputModeLabelOf(activeMode)) .. " · 操控与四通道音量实时生效" -- 830
	end, -- 829
	settingsValueText = function(self, rowId, settings, activeMode) -- 833
		if rowId == "modePref" then -- 834
			return settings.modePref == "auto" and ("自动切换（" .. inputModeLabelOf(activeMode)) .. "）" or "锁定 · " .. modePrefLabelOf(settings.modePref) -- 835
		end -- 835
		if rowId == "aimAssist" then -- 839
			return settings.aimAssist and "开（触屏与手柄共用）" or "关" -- 839
		end -- 839
		if rowId == "gpLayout" then -- 840
			return layoutLabelOf(settings.gamepadLayout) -- 840
		end -- 840
		if rowId == "crouchMode" then -- 841
			return settings.crouchToggle and "点按切换" or "持续按住" -- 841
		end -- 841
		if rowId == "touchOpacity" then -- 842
			return opacityLabelOf(settings.touchOpacity) -- 842
		end -- 842
		if rowId == "touchScale" then -- 843
			return scaleLabelOf(settings.touchScale) -- 843
		end -- 843
		if rowId == "haptics" then -- 844
			return settings.haptics and "开（仅移动端生效）" or "关" -- 844
		end -- 844
		return volumeSettingText(rowId, settings) -- 845
	end, -- 833
	applySettingsDelta = function(self, rowId, delta, settings, input) -- 848
		if rowId == "back" then -- 849
			return "back" -- 849
		end -- 849
		if rowId == "modePref" then -- 850
			input:cycleModePref(delta) -- 851
			return "control" -- 852
		end -- 852
		if rowId == "aimAssist" then -- 854
			settings.aimAssist = not settings.aimAssist -- 855
			saveControlSettings(settings) -- 856
			return "control" -- 857
		end -- 857
		if rowId == "gpLayout" then -- 859
			settings.gamepadLayout = settings.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 860
			input.gamepadLayout = settings.gamepadLayout -- 861
			saveControlSettings(settings) -- 862
			return "control" -- 863
		end -- 863
		if rowId == "crouchMode" then -- 865
			settings.crouchToggle = not settings.crouchToggle -- 866
			saveControlSettings(settings) -- 867
			return "control" -- 868
		end -- 868
		if rowId == "touchOpacity" then -- 870
			settings.touchOpacity = nextStepValue(settings.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 871
			saveControlSettings(settings) -- 872
			return "control" -- 873
		end -- 873
		if rowId == "touchScale" then -- 875
			settings.touchScale = nextStepValue(settings.touchScale, TOUCH_SCALE_STEPS, delta) -- 876
			saveControlSettings(settings) -- 877
			return "control" -- 878
		end -- 878
		if rowId == "haptics" then -- 880
			settings.haptics = not settings.haptics -- 881
			saveControlSettings(settings) -- 882
			return "control" -- 883
		end -- 883
		if applyVolumeSetting(rowId, delta, settings) then -- 885
			return "audio" -- 885
		end -- 885
		return "none" -- 886
	end, -- 848
	createDriver = function(self, settings) -- 889
		return __TS__New(WebInputDriver, settings) -- 890
	end -- 889
} -- 889
return ____exports -- 889
