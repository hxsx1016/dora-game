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
}, childRows = { -- 71
	{"WASD / 方向键", "前后左右纵深潜行"}, -- 74
	{"按住 SHIFT", "轻步慢走（压低脚步声）"}, -- 75
	{"按住 C / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 76
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
}, childRows = { -- 91
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
}, childRows = { -- 111
	{"摇杆内圈 / 轻步", "轻推内圈或点轻步压低脚步声"}, -- 114
	{"蹲伏开关", "点按蹲下钻桌穿拱，点跳顺滑起身"}, -- 115
	{"跳跃钮", "攀上石阶、红布车与矮台"}, -- 116
	{"投瓶拖瞄", "按住投瓶拖向砖地，拖回取消圈放弃"}, -- 117
	{"交互 / 拉车", "拾瓶、敲塔门、点拉车锁定握柄"}, -- 118
	{"右上暂歇 / 竖屏", "顶栏随时暂歇，竖屏自动展掌机台"} -- 119
}} -- 119
local function keyTagWeb(action, mode, layout) -- 123
	if mode == "gamepad" then -- 123
		local confirmBtn = layout == "nintendo" and "B" or "A" -- 125
		local backBtn = layout == "nintendo" and "A" or "B" -- 126
		if action == "interact" then -- 126
			return "Y / RB" -- 127
		end -- 127
		if action == "jump" then -- 127
			return "A" -- 128
		end -- 128
		if action == "crouch" then -- 128
			return "B" -- 129
		end -- 129
		if action == "cover" then -- 129
			return "LT / LB" -- 130
		end -- 130
		if action == "fire" then -- 130
			return "RT / X" -- 131
		end -- 131
		if action == "aim" then -- 131
			return "RT / X" -- 132
		end -- 132
		if action == "pause" then -- 132
			return "START" -- 133
		end -- 133
		if action == "retry" then -- 133
			return "长按 BACK" -- 134
		end -- 134
		if action == "confirm" then -- 134
			return confirmBtn -- 135
		end -- 135
		if action == "back" then -- 135
			return backBtn -- 136
		end -- 136
		return "L3" -- 137
	end -- 137
	if mode == "touch" then -- 137
		if action == "interact" then -- 137
			return "点按" -- 140
		end -- 140
		if action == "jump" then -- 140
			return "跳/滚" -- 141
		end -- 141
		if action == "crouch" then -- 141
			return "蹲伏" -- 142
		end -- 142
		if action == "cover" then -- 142
			return "掩体" -- 143
		end -- 143
		if action == "fire" then -- 143
			return "开火" -- 144
		end -- 144
		if action == "aim" then -- 144
			return "拖投瓶" -- 145
		end -- 145
		if action == "pause" then -- 145
			return "暂歇" -- 146
		end -- 146
		if action == "retry" then -- 146
			return "重试" -- 147
		end -- 147
		if action == "confirm" then -- 147
			return "点选" -- 148
		end -- 148
		if action == "back" then -- 148
			return "返回" -- 149
		end -- 149
		return "穿梭" -- 150
	end -- 150
	if action == "interact" then -- 150
		return "E" -- 152
	end -- 152
	if action == "jump" then -- 152
		return "SPACE" -- 153
	end -- 153
	if action == "crouch" then -- 153
		return "CTRL" -- 154
	end -- 154
	if action == "cover" then -- 154
		return "SHIFT" -- 155
	end -- 155
	if action == "fire" then -- 155
		return "左键" -- 156
	end -- 156
	if action == "aim" then -- 156
		return "F" -- 157
	end -- 157
	if action == "pause" then -- 157
		return "ESC" -- 158
	end -- 158
	if action == "retry" then -- 158
		return "R" -- 159
	end -- 159
	if action == "confirm" then -- 159
		return "ENTER" -- 160
	end -- 160
	if action == "back" then -- 160
		return "ESC" -- 161
	end -- 161
	return "T" -- 162
end -- 123
local function adaptWorldKeyTagWeb(rawKeyTag, mode) -- 165
	if mode == "kbm" then -- 165
		return rawKeyTag -- 166
	end -- 166
	if mode == "gamepad" then -- 166
		if rawKeyTag == "E" then -- 166
			return "Y" -- 168
		end -- 168
		if rawKeyTag == "按住 E" then -- 168
			return "按住 Y" -- 169
		end -- 169
		if rawKeyTag == "松开再按住 E" then -- 169
			return "松开再按 Y" -- 170
		end -- 170
		if rawKeyTag == "按住 E + D" then -- 170
			return "按住 Y + 右" -- 171
		end -- 171
		if rawKeyTag == "E 握柄 + D" then -- 171
			return "Y 握柄 + 右" -- 172
		end -- 172
		if rawKeyTag == "F" or rawKeyTag == "左键" then -- 172
			return "RT / X" -- 173
		end -- 173
		if rawKeyTag == "按住 F" then -- 173
			return "按住 RT" -- 174
		end -- 174
		if rawKeyTag == "松开 F" then -- 174
			return "松开 RT" -- 175
		end -- 175
		if rawKeyTag == "按住 Ctrl" then -- 175
			return "按住 B" -- 176
		end -- 176
		if rawKeyTag == "按住 Shift" then -- 176
			return "按住 LT" -- 177
		end -- 177
		if rawKeyTag == "连线" then -- 177
			return "摇杆/触屏连线" -- 178
		end -- 178
		if rawKeyTag == "→" then -- 178
			return "右推摇杆" -- 179
		end -- 179
		return rawKeyTag -- 180
	end -- 180
	if rawKeyTag == "E" then -- 180
		return "轻触" -- 182
	end -- 182
	if rawKeyTag == "按住 E" then -- 182
		return "长按交互" -- 183
	end -- 183
	if rawKeyTag == "松开再按住 E" then -- 183
		return "松开再长按" -- 184
	end -- 184
	if rawKeyTag == "按住 E + D" or rawKeyTag == "E 握柄 + D" then -- 184
		return "点推车+摇杆" -- 185
	end -- 185
	if rawKeyTag == "F" or rawKeyTag == "左键" then -- 185
		return "开火" -- 186
	end -- 186
	if rawKeyTag == "按住 F" then -- 186
		return "拖投瓶" -- 187
	end -- 187
	if rawKeyTag == "松开 F" then -- 187
		return "松手投" -- 188
	end -- 188
	if rawKeyTag == "按住 Ctrl" then -- 188
		return "点蹲伏" -- 189
	end -- 189
	if rawKeyTag == "按住 Shift" then -- 189
		return "点掩体" -- 190
	end -- 190
	if rawKeyTag == "连线" then -- 190
		return "一笔划连" -- 191
	end -- 191
	return rawKeyTag -- 192
end -- 165
local function adaptHintSentenceWeb(text, mode, layout) -- 195
	if mode == "kbm" or text == "" then -- 195
		return text -- 196
	end -- 196
	if mode == "gamepad" then -- 196
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
	if self.touchControls == nil then -- 276
		self.touchControls = __TS__New(TouchControls, parent, PORTRAIT_TOUCH_DELEGATE) -- 278
	end -- 278
end -- 273
function WebInputDriver.prototype.syncFrame(self, ctx) -- 282
	local vp = ctx.viewport -- 283
	local p = ctx.play -- 284
	local isPlayMode = ctx.mode == 1 and ctx.screen == "play" and p ~= nil -- 285
	local gameplayActive = isPlayMode -- 286
	local modal = not gameplayActive or p == nil or p.paused or p.reloadOpen or p.craftBench.active or p.escortFailed or p.talentModalActive or ctx.ledgerOpen == true -- 287
	local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 289
	local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 290
	local talentOfferCount = #ctx.storyTalentBoxes -- 291
	local ____temp_0 -- 292
	if isPlayMode and p ~= nil then -- 292
		____temp_0 = isCutsceneBlockingPlay(p) -- 292
	else -- 292
		____temp_0 = false -- 292
	end -- 292
	local cutsceneBlocking = ____temp_0 -- 292
	local allowDepth = p ~= nil and p.room.depth ~= nil -- 293
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 294
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and p.escort.state ~= "calming" -- 295
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 297
	local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 299
	local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 302
	local enemyTargets = canShoot and self.settings.aimAssist and p ~= nil and collectAimTargets(p, ctx.cam, vp.stageW, vp.stageH) or ({}) -- 305
	if self.touchControls ~= nil then -- 305
		local pref = self.settings.modePref -- 310
		self.touchControls:syncContext({ -- 311
			viewport = vp, -- 312
			mode = ctx.mode, -- 313
			screen = ctx.screen, -- 314
			play = p, -- 315
			run = ctx.run, -- 316
			cam = ctx.cam, -- 317
			router = self.touchRouter, -- 318
			overlayActive = self:shouldShowTouchControls(ctx.input, vp), -- 319
			allowAutoGameplayTouch = pref == "auto" or pref == "touch", -- 320
			allowMouseOnOverlay = vp.isPortrait or pref == "touch", -- 321
			showWebTopPills = true, -- 322
			canToggleFullscreen = true, -- 323
			assistHintsEnabled = ctx.assistHintsEnabled, -- 324
			isMuted = ctx.isMuted, -- 325
			isFullscreen = ctx.isFullscreen, -- 326
			storyTalentBoxes = ctx.storyTalentBoxes, -- 327
			escortDeathBoxes = ctx.escortDeathBoxes, -- 328
			ledgerOpen = ctx.ledgerOpen, -- 329
			ledgerBox = ctx.ledgerBox, -- 330
			enemyTargets = enemyTargets, -- 331
			dt = ctx.dt -- 332
		}) -- 332
	end -- 332
	local muzzle = p ~= nil and projectMuzzle(p, ctx.cam) or nil -- 336
	local playerScreenX = muzzle and muzzle.x or vp.stageW * 0.5 -- 337
	local playerScreenY = muzzle and muzzle.y or vp.stageH * 0.38 -- 338
	local gpCtx = { -- 340
		stageW = vp.stageW, -- 341
		stageH = vp.stageH, -- 342
		uiScale = vp.uiScale, -- 343
		modal = modal, -- 344
		gameplayActive = gameplayActive, -- 345
		reloadActive = reloadActive, -- 346
		craftActive = craftActive, -- 347
		talentOfferCount = talentOfferCount, -- 348
		childMode = p ~= nil and p.childMode, -- 349
		allowDepth = allowDepth, -- 350
		canShoot = canShoot, -- 351
		canBottleAim = canBottleAim, -- 352
		playerRolling = p ~= nil and p.player.rollT > 0, -- 353
		inLowArch = inLowArch, -- 354
		inTowerEnd = inTowerEnd, -- 355
		playerFacing = p ~= nil and p.player.facing or 1, -- 356
		playerScreenX = playerScreenX, -- 357
		playerScreenY = playerScreenY, -- 358
		enemyTargets = enemyTargets -- 359
	} -- 359
	self.gamepadRouter:setFrameContext(gpCtx, ctx.dt) -- 361
end -- 282
function WebInputDriver.prototype.renderOverlay(self) -- 364
	local ____opt_5 = self.touchControls -- 364
	if ____opt_5 ~= nil then -- 364
		____opt_5:render(self.touchRouter) -- 365
	end -- 365
end -- 364
function WebInputDriver.prototype.clearTransient(self, keepTouchToggles) -- 368
	self.touchRouter:releaseAll(keepTouchToggles) -- 369
	self.gamepadRouter:clearTransient() -- 370
end -- 368
function WebInputDriver.prototype.vibrate(self, seconds) -- 373
	self.touchRouter:vibrate(seconds) -- 374
end -- 373
function WebInputDriver.prototype.onInputModeChanged(self, mode) -- 377
	if mode ~= "touch" then -- 377
		self.touchRouter:releaseAll(false) -- 379
	end -- 379
end -- 377
function WebInputDriver.prototype.shouldShowTouchControls(self, input, vp) -- 383
	if vp.isPortrait then -- 383
		return true -- 384
	end -- 384
	if self.settings.modePref == "touch" then -- 384
		return true -- 385
	end -- 385
	if self.settings.modePref == "kbm" or self.settings.modePref == "gamepad" then -- 385
		return false -- 386
	end -- 386
	return input.inputMode == "touch" -- 387
end -- 383
function WebInputDriver.prototype.getTouchRouter(self) -- 390
	return self.touchRouter -- 391
end -- 390
function WebInputDriver.prototype.getGamepadRouter(self) -- 394
	return self.gamepadRouter -- 395
end -- 394
function WebInputDriver.prototype.getTouchControls(self) -- 398
	return self.touchControls -- 399
end -- 398
function WebInputDriver.prototype.injectTouch(self, phase, id, x, y, fromMouse) -- 402
	self.touchRouter:injectTouch( -- 403
		phase, -- 403
		id, -- 403
		x, -- 403
		y, -- 403
		fromMouse == true -- 403
	) -- 403
end -- 402
function WebInputDriver.prototype.setGamepadSim(self, state) -- 406
	self.gamepadRouter:setSimulatedState(state) -- 407
end -- 406
function WebInputDriver.prototype.pollInto(self, input) -- 410
	input.gamepadLayout = self.settings.gamepadLayout -- 411
	local touch = self.touchRouter:consumeSnapshot() -- 412
	local gp = self.gamepadRouter:consumeSnapshot() -- 413
	local kbm = self.kbm:sample(input:getStageViewport()) -- 414
	local suppressMouse = touch.suppressSyntheticMouse or touch.mouseConsumedByOverlay -- 416
	local realMouseActive = not suppressMouse and (kbm.mouseMoved or kbm.mouseClicked and kbm.mouseInsideStage) -- 417
	if kbm.anyKb or realMouseActive or gp.hadGamepadInput or touch.hadRealTouch then -- 417
		input.userInteracted = true -- 420
	end -- 420
	if self.settings.modePref ~= "auto" then -- 420
		input:setInputMode(self.settings.modePref) -- 424
	elseif gp.hadGamepadInput then -- 424
		input:setInputMode("gamepad") -- 426
	elseif touch.hadGameplayTouch then -- 426
		input:setInputMode("touch") -- 428
	elseif kbm.anyKb or realMouseActive then -- 428
		input:setInputMode("kbm") -- 430
	elseif touch.hadUiTouch and input.inputMode == "kbm" then -- 430
		input:setInputMode("touch") -- 432
	end -- 432
	input.moveX = kbm.moveX ~= 0 and kbm.moveX or (gp.moveX ~= 0 and gp.moveX or touch.moveX) -- 435
	input.moveY = kbm.moveY ~= 0 and kbm.moveY or (gp.moveY ~= 0 and gp.moveY or touch.moveY) -- 436
	local allowMouseFire = not suppressMouse and input.inputMode == "kbm" and kbm.mouseInsideStage -- 438
	local rawFireHeld = allowMouseFire and kbm.mouseLeft or gp.fireHeld or touch.fireHeld -- 439
	input:applyKeyHeld( -- 441
		kbm.jump or gp.jumpHeld or touch.jumpHeld, -- 442
		kbm.crouch or gp.crouchHeld or touch.crouchHeld, -- 443
		kbm.cover or gp.coverHeld or touch.coverHeld, -- 444
		kbm.interact or gp.interactHeld or touch.interactHeld, -- 445
		kbm.aim or gp.aimHeld or touch.aimHeld, -- 446
		rawFireHeld, -- 447
		kbm.flare or gp.flareHeld, -- 448
		kbm.pause, -- 449
		kbm.retry, -- 450
		kbm.toggleView, -- 451
		kbm.tab -- 452
	) -- 452
	input:resetFrameSignals() -- 455
	input.navUp = kbm.navUp -- 458
	input.navDown = kbm.navDown -- 459
	input.navLeft = kbm.navLeft -- 460
	input.navRight = kbm.navRight -- 461
	input.navConfirm = kbm.navConfirm -- 462
	input.craftConfirm = kbm.uiConfirmWithE -- 463
	input.craftCancel = kbm.uiBackSpace -- 464
	local kCol = (kbm.navRight and 1 or 0) - (kbm.navLeft and 1 or 0) -- 465
	local kRow = (kbm.navUp and 1 or 0) - (kbm.navDown and 1 or 0) -- 466
	if kCol ~= 0 or kRow ~= 0 then -- 466
		input.reloadDirCol = kCol -- 468
		input.reloadDirRow = kRow -- 469
		input.reloadStepEdge = true -- 470
		input.reloadAutoStep = false -- 471
	end -- 471
	input.reloadConfirm = kbm.uiConfirmWithE -- 473
	input.reloadReset = kbm.uiBackSpace -- 474
	if gp.jumpPressed then -- 474
		input.jump.pressed = true -- 476
	end -- 476
	if gp.crouchPressed then -- 476
		input.crouch.pressed = true -- 477
	end -- 477
	if gp.interactPressed then -- 477
		input.interact.pressed = true -- 478
	end -- 478
	if gp.aimPressed then -- 478
		input.aim.pressed = true -- 479
	end -- 479
	if gp.firePressed then -- 479
		input.fire.pressed = true -- 480
	end -- 480
	if gp.flarePressed then -- 480
		input.flare.pressed = true -- 481
	end -- 481
	if gp.pausePressed then -- 481
		input.pause.pressed = true -- 482
	end -- 482
	if gp.retryPressed then -- 482
		input.retry.pressed = true -- 483
	end -- 483
	if gp.artifactPressed then -- 483
		input.artifactTogglePressed = true -- 484
	end -- 484
	if gp.anyButtonPressed then -- 484
		input.splashSkipPressed = true -- 485
	end -- 485
	if gp.bottleCanceled then -- 485
		input.bottleCanceled = true -- 487
		input.aim.held = false -- 488
		input.aim.pressed = false -- 489
		input.aim.released = false -- 490
	end -- 490
	if gp.navUp then -- 490
		input.navUp = true -- 492
	end -- 492
	if gp.navDown then -- 492
		input.navDown = true -- 493
	end -- 493
	if gp.navLeft then -- 493
		input.navLeft = true -- 494
	end -- 494
	if gp.navRight then -- 494
		input.navRight = true -- 495
	end -- 495
	if gp.navConfirm then -- 495
		input.navConfirm = true -- 497
		input.craftConfirm = true -- 498
	end -- 498
	if gp.navBack then -- 498
		input.navBack = true -- 501
		input.craftCancel = true -- 502
	end -- 502
	input.navPrevTab = gp.navPrevTab -- 504
	input.navNextTab = gp.navNextTab -- 505
	if gp.reloadStepEdge then -- 505
		input.reloadDirCol = gp.reloadDirCol -- 507
		input.reloadDirRow = gp.reloadDirRow -- 508
		input.reloadStepEdge = true -- 509
		input.reloadAutoStep = gp.reloadAutoStep -- 510
	end -- 510
	if gp.reloadConfirm then -- 510
		input.reloadConfirm = true -- 512
	end -- 512
	if gp.reloadReset then -- 512
		input.reloadReset = true -- 513
	end -- 513
	input.talentDelta = gp.talentDelta -- 514
	input.talentConfirm = gp.talentConfirm -- 515
	input.retryHoldProgress = gp.retryHoldProgress -- 516
	if touch.jumpPressed then -- 516
		input.jump.pressed = true -- 518
	end -- 518
	if touch.interactPressed then -- 518
		input.interact.pressed = true -- 519
	end -- 519
	if touch.firePressed then -- 519
		input.fire.pressed = true -- 520
	end -- 520
	if touch.pausePressed then -- 520
		input.pause.pressed = true -- 521
	end -- 521
	if touch.retryPressed then -- 521
		input.retry.pressed = true -- 522
	end -- 522
	if touch.artifactPressed then -- 522
		input.artifactTogglePressed = true -- 523
	end -- 523
	if touch.mutePressed then -- 523
		input.muteTogglePressed = true -- 524
	end -- 524
	if touch.fullscreenPressed then -- 524
		input.fullscreenTogglePressed = true -- 525
	end -- 525
	if touch.anyTapBegan then -- 525
		input.splashSkipPressed = true -- 526
	end -- 526
	if touch.zoneTap ~= "" then -- 526
		input.touchZoneTap = touch.zoneTap -- 527
	end -- 527
	if touch.navUp then -- 527
		input.navUp = true -- 528
	end -- 528
	if touch.navDown then -- 528
		input.navDown = true -- 529
	end -- 529
	if touch.navLeft then -- 529
		input.navLeft = true -- 530
	end -- 530
	if touch.navRight then -- 530
		input.navRight = true -- 531
	end -- 531
	if touch.navConfirm then -- 531
		input.navConfirm = true -- 533
		input.craftConfirm = true -- 534
	end -- 534
	if touch.navBack then -- 534
		input.navBack = true -- 537
		input.craftCancel = true -- 538
	end -- 538
	if touch.bottleCanceled then -- 538
		input.bottleCanceled = true -- 541
		input.aim.held = false -- 542
		input.aim.pressed = false -- 543
		input.aim.released = false -- 544
	end -- 544
	if not suppressMouse and input.inputMode == "kbm" and input.aim.held and kbm.mouseRightPressed then -- 544
		input.bottleCanceled = true -- 548
		input.aim.held = false -- 549
		input.aim.pressed = false -- 550
		input.aim.released = false -- 551
	end -- 551
	input:applyPickRoom(kbm.pick) -- 554
	input.frameInteractPressed = input.interact.pressed -- 555
	if touch.uiHeld or touch.uiPressed or touch.uiReleased or touch.uiInside then -- 555
		input.uiX = touch.uiX -- 558
		input.uiY = touch.uiY -- 559
		input.uiDx = touch.uiDx -- 560
		input.uiDy = touch.uiDy -- 561
		input.uiInside = touch.uiInside -- 562
		input.uiHeld = touch.uiHeld -- 563
		input.uiPressed = touch.uiPressed -- 564
		input.uiReleased = touch.uiReleased -- 565
		input.uiRightPressed = false -- 566
		if touch.uiHeld or touch.uiPressed then -- 566
			input.mdx = touch.uiDx -- 568
			input.mdy = touch.uiDy -- 569
			input.mx = touch.uiX -- 570
			input.my = touch.uiY -- 571
			input.inside = true -- 572
		elseif touch.hasAim then -- 572
			input.mdx = touch.aimX - input.mx -- 574
			input.mdy = touch.aimY - input.my -- 575
			input.mx = touch.aimX -- 576
			input.my = touch.aimY -- 577
			input.inside = true -- 578
		else -- 578
			input.mdx = 0 -- 580
			input.mdy = 0 -- 581
			input.inside = touch.uiInside -- 582
		end -- 582
		return -- 584
	end -- 584
	if input.inputMode == "gamepad" then -- 584
		if gp.hasAim then -- 584
			input.mdx = gp.aimX - input.mx -- 589
			input.mdy = gp.aimY - input.my -- 590
			input.mx = gp.aimX -- 591
			input.my = gp.aimY -- 592
			input.inside = true -- 593
		else -- 593
			input.mdx = 0 -- 595
			input.mdy = 0 -- 596
			input.inside = false -- 597
		end -- 597
		if not suppressMouse and kbm.mouseInsideStage and (kbm.mouseLeft or kbm.mouseLeftPressed or kbm.mouseLeftReleased) then -- 597
			input.uiDx = kbm.mouseStageX - input.uiX -- 600
			input.uiDy = kbm.mouseStageY - input.uiY -- 601
			input.uiX = kbm.mouseStageX -- 602
			input.uiY = kbm.mouseStageY -- 603
			input.uiInside = true -- 604
			input.uiHeld = kbm.mouseLeft -- 605
			input.uiPressed = kbm.mouseLeftPressed -- 606
			input.uiReleased = kbm.mouseLeftReleased -- 607
			input.uiRightPressed = kbm.mouseRightPressed -- 608
		else -- 608
			input.uiX = input.mx -- 610
			input.uiY = input.my -- 611
			input.uiDx = 0 -- 612
			input.uiDy = 0 -- 613
			input.uiInside = false -- 614
			input.uiHeld = false -- 615
			input.uiPressed = false -- 616
			input.uiReleased = false -- 617
			input.uiRightPressed = false -- 618
		end -- 618
		return -- 620
	end -- 620
	if input.inputMode == "touch" then -- 620
		if touch.hasAim then -- 620
			input.mdx = touch.aimX - input.mx -- 625
			input.mdy = touch.aimY - input.my -- 626
			input.mx = touch.aimX -- 627
			input.my = touch.aimY -- 628
			input.inside = true -- 629
		else -- 629
			input.mdx = 0 -- 631
			input.mdy = 0 -- 632
			input.inside = false -- 633
		end -- 633
		if not suppressMouse and kbm.mouseInsideStage and (kbm.mouseLeft or kbm.mouseLeftPressed or kbm.mouseLeftReleased) then -- 633
			input.uiDx = kbm.mouseStageX - input.uiX -- 636
			input.uiDy = kbm.mouseStageY - input.uiY -- 637
			input.uiX = kbm.mouseStageX -- 638
			input.uiY = kbm.mouseStageY -- 639
			input.uiInside = true -- 640
			input.uiHeld = kbm.mouseLeft -- 641
			input.uiPressed = kbm.mouseLeftPressed -- 642
			input.uiReleased = kbm.mouseLeftReleased -- 643
			input.uiRightPressed = kbm.mouseRightPressed -- 644
		else -- 644
			input.uiDx = 0 -- 646
			input.uiDy = 0 -- 647
			input.uiInside = false -- 648
			input.uiHeld = false -- 649
			input.uiPressed = false -- 650
			input.uiReleased = false -- 651
			input.uiRightPressed = false -- 652
		end -- 652
		return -- 654
	end -- 654
	input.mdx = kbm.mouseStageX - input.mx -- 657
	input.mdy = kbm.mouseStageY - input.my -- 658
	input.mx = kbm.mouseStageX -- 659
	input.my = kbm.mouseStageY -- 660
	input.inside = kbm.mouseInsideStage -- 661
	input.uiX = kbm.mouseStageX -- 663
	input.uiY = kbm.mouseStageY -- 664
	input.uiDx = input.mdx -- 665
	input.uiDy = input.mdy -- 666
	input.uiInside = kbm.mouseInsideStage -- 667
	input.uiHeld = not suppressMouse and kbm.mouseLeft and kbm.mouseInsideStage -- 668
	input.uiPressed = not suppressMouse and kbm.mouseLeftPressed and kbm.mouseInsideStage -- 669
	input.uiReleased = not suppressMouse and kbm.mouseLeftReleased -- 670
	input.uiRightPressed = not suppressMouse and kbm.mouseRightPressed and kbm.mouseInsideStage -- 671
end -- 410
____exports.TARGET = { -- 675
	id = "web", -- 676
	supportsKbm = true, -- 677
	supportsTouch = true, -- 678
	supportsGamepad = true, -- 679
	supportsPortrait = true, -- 680
	defaultInputMode = "kbm", -- 681
	supportedModes = {"kbm", "touch", "gamepad"}, -- 682
	modePrefOrder = MODE_PREF_ORDER, -- 683
	controlsGuideTabs = {{mode = "kbm", label = "键鼠"}, {mode = "gamepad", label = "手柄"}, {mode = "touch", label = "触屏"}}, -- 684
	getPlatformCaps = function(self) -- 690
		local cfg = getReleaseConfig() -- 691
		local ____temp_7 -- 704
		if cfg ~= nil and cfg.isRelease ~= nil then -- 704
			____temp_7 = cfg.isRelease == true -- 704
		else -- 704
			____temp_7 = true -- 704
		end -- 704
		return { -- 692
			kind = "web", -- 693
			target = "web", -- 694
			isDesktop = false, -- 695
			isMobile = false, -- 696
			isWeb = true, -- 697
			isStandaloneAndroidApk = false, -- 698
			canToggleFullscreen = true, -- 699
			canQuit = false, -- 700
			hasBackButton = false, -- 701
			supportsHaptics = false, -- 702
			needsAudioUnlock = true, -- 703
			isRelease = ____temp_7, -- 704
			defaultInputMode = "kbm" -- 705
		} -- 705
	end, -- 690
	canToggleFullscreen = function(self) -- 709
		return true -- 710
	end, -- 709
	canQuitApp = function(self) -- 713
		return false -- 714
	end, -- 713
	isReleaseMode = function(self) -- 717
		local cfg = getReleaseConfig() -- 718
		if cfg ~= nil and cfg.isRelease ~= nil then -- 718
			return cfg.isRelease == true -- 720
		end -- 720
		return true -- 722
	end, -- 717
	computeStageViewport = function(self, fullW, fullH) -- 725
		return computeAdaptiveViewport(fullW, fullH) -- 726
	end, -- 725
	triggerHaptics = function(self, seconds, enabled) -- 729
		triggerMobileHaptics(seconds, enabled) -- 730
	end, -- 729
	keyTagFor = function(self, action, mode, layout) -- 733
		return keyTagWeb(action, mode, layout) -- 734
	end, -- 733
	adaptWorldKeyTag = function(self, rawKeyTag, mode, _layout) -- 737
		return adaptWorldKeyTagWeb(rawKeyTag, mode) -- 738
	end, -- 737
	adaptHintSentence = function(self, text, mode, layout) -- 741
		return adaptHintSentenceWeb(text, mode, layout) -- 742
	end, -- 741
	controlsGuideRows = function(self, tab) -- 745
		if tab == "gamepad" then -- 745
			return GUIDE_GAMEPAD -- 746
		end -- 746
		if tab == "touch" then -- 746
			return GUIDE_TOUCH -- 747
		end -- 747
		return GUIDE_KBM -- 748
	end, -- 745
	splashSkipHint = function(self, mode, layout) -- 751
		if mode == "touch" then -- 751
			return "轻触跳过" -- 752
		end -- 752
		if mode == "gamepad" then -- 752
			return keyTagWeb("confirm", "gamepad", layout) .. " / START  跳过" -- 753
		end -- 753
		return "ESC / SPACE  SKIP" -- 754
	end, -- 751
	titleFooterHint = function(self, mode, layout) -- 757
		if mode == "gamepad" then -- 757
			return ("左摇杆 / 十字键择项   ·   " .. keyTagWeb("confirm", "gamepad", layout)) .. " 或点选启程" -- 759
		end -- 759
		if mode == "touch" then -- 759
			return "轻触择项启程   ·   支持键鼠与手柄" -- 761
		end -- 761
		return "上下择项   ·   回车或点选启程" -- 762
	end, -- 757
	chapterFooterHint = function(self, mode, confirmTag) -- 765
		if mode == "gamepad" then -- 765
			return ("摇杆/十字键选择   ·   " .. confirmTag) .. " 或点选进入" -- 766
		end -- 766
		if mode == "touch" then -- 766
			return "轻触驿站预览   ·   再点或轻触入此卷章" -- 767
		end -- 767
		return "方向键选择   ·   回车或点击进入" -- 768
	end, -- 765
	pauseFooterHint = function(self, mode, layout) -- 771
		if mode == "gamepad" then -- 771
			return ((keyTagWeb("back", "gamepad", layout) .. " / START 续行   ·   ") .. keyTagWeb("confirm", "gamepad", layout)) .. " 确认" -- 773
		end -- 773
		if mode == "touch" then -- 773
			return "轻触确认   ·   点「继续游戏」续行" -- 775
		end -- 775
		return "Esc 续行   ·   Enter 或点击确认" -- 776
	end, -- 771
	settingsFooterHint = function(self, mode, layout) -- 779
		if mode == "gamepad" then -- 779
			return ((("左右或 " .. keyTagWeb("confirm", "gamepad", layout)) .. " 切换   ·   ") .. keyTagWeb("back", "gamepad", layout)) .. " 返回暂停" -- 781
		end -- 781
		if mode == "touch" then -- 781
			return "轻触任意条目切换   ·   设置自动保存" -- 783
		end -- 783
		return "←/→ 或回车/点击切换   ·   Esc 返回暂停" -- 784
	end, -- 779
	controlsFooterRightHint = function(self, mode) -- 787
		if mode == "gamepad" then -- 787
			return "LB / RB 或左右切换键位图" -- 788
		end -- 788
		if mode == "touch" then -- 788
			return "轻触右上页签切图 · 暂歇菜单可调操控设置" -- 789
		end -- 789
		return "←/→ 切页   ·   F11 / Alt+Enter 全屏" -- 790
	end, -- 787
	epilogueFooterHint = function(self, mode, layout) -- 793
		if mode == "gamepad" then -- 793
			return ((keyTagWeb("confirm", "gamepad", layout) .. " 确认   ·   ") .. keyTagWeb("back", "gamepad", layout)) .. " 返回标题" -- 795
		end -- 795
		if mode == "touch" then -- 795
			return "轻触任一入口继续" -- 797
		end -- 797
		return "↑/↓ 选择   ·   Enter / 点击确认   ·   Esc 返回标题" -- 798
	end, -- 793
	settingsRows = function(self) -- 801
		return WEB_SETTINGS_ROWS -- 802
	end, -- 801
	settingsPauseLabel = function(self, settings) -- 805
		return "操控设置 · " .. modePrefLabelOf(settings.modePref) -- 806
	end, -- 805
	settingsHeaderTitle = function(self) -- 809
		return "操控与声音" -- 810
	end, -- 809
	settingsHeaderSummary = function(self, activeMode) -- 813
		return ("当前模式：" .. inputModeLabelOf(activeMode)) .. " · 操控与四通道音量实时生效" -- 814
	end, -- 813
	settingsValueText = function(self, rowId, settings, activeMode) -- 817
		if rowId == "modePref" then -- 817
			return settings.modePref == "auto" and ("自动切换（" .. inputModeLabelOf(activeMode)) .. "）" or "锁定 · " .. modePrefLabelOf(settings.modePref) -- 819
		end -- 819
		if rowId == "aimAssist" then -- 819
			return settings.aimAssist and "开（触屏与手柄共用）" or "关" -- 823
		end -- 823
		if rowId == "gpLayout" then -- 823
			return layoutLabelOf(settings.gamepadLayout) -- 824
		end -- 824
		if rowId == "crouchMode" then -- 824
			return settings.crouchToggle and "点按切换" or "持续按住" -- 825
		end -- 825
		if rowId == "touchOpacity" then -- 825
			return opacityLabelOf(settings.touchOpacity) -- 826
		end -- 826
		if rowId == "touchScale" then -- 826
			return scaleLabelOf(settings.touchScale) -- 827
		end -- 827
		if rowId == "haptics" then -- 827
			return settings.haptics and "开（仅移动端生效）" or "关" -- 828
		end -- 828
		return volumeSettingText(rowId, settings) -- 829
	end, -- 817
	applySettingsDelta = function(self, rowId, delta, settings, input) -- 832
		if rowId == "back" then -- 832
			return "back" -- 833
		end -- 833
		if rowId == "modePref" then -- 833
			input:cycleModePref(delta) -- 835
			return "control" -- 836
		end -- 836
		if rowId == "aimAssist" then -- 836
			settings.aimAssist = not settings.aimAssist -- 839
			saveControlSettings(settings) -- 840
			return "control" -- 841
		end -- 841
		if rowId == "gpLayout" then -- 841
			settings.gamepadLayout = settings.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 844
			input.gamepadLayout = settings.gamepadLayout -- 845
			saveControlSettings(settings) -- 846
			return "control" -- 847
		end -- 847
		if rowId == "crouchMode" then -- 847
			settings.crouchToggle = not settings.crouchToggle -- 850
			saveControlSettings(settings) -- 851
			return "control" -- 852
		end -- 852
		if rowId == "touchOpacity" then -- 852
			settings.touchOpacity = nextStepValue(settings.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 855
			saveControlSettings(settings) -- 856
			return "control" -- 857
		end -- 857
		if rowId == "touchScale" then -- 857
			settings.touchScale = nextStepValue(settings.touchScale, TOUCH_SCALE_STEPS, delta) -- 860
			saveControlSettings(settings) -- 861
			return "control" -- 862
		end -- 862
		if rowId == "haptics" then -- 862
			settings.haptics = not settings.haptics -- 865
			saveControlSettings(settings) -- 866
			return "control" -- 867
		end -- 867
		if applyVolumeSetting(rowId, delta, settings) then -- 867
			return "audio" -- 869
		end -- 869
		return "none" -- 870
	end, -- 832
	createDriver = function(self, settings) -- 873
		return __TS__New(WebInputDriver, settings) -- 874
	end -- 873
} -- 873
return ____exports -- 873