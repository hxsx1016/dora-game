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
	self.kbm:attach(parent, hooks, {latchTouchEvents = false, disableIme = false}) -- 274
	self.touchRouter:attach(parent) -- 278
	self.gamepadRouter:attach(parent) -- 279
	if self.touchControls == nil then -- 279
		self.touchControls = __TS__New(TouchControls, parent, PORTRAIT_TOUCH_DELEGATE) -- 281
	end -- 281
end -- 273
function WebInputDriver.prototype.syncFrame(self, ctx) -- 285
	local vp = ctx.viewport -- 286
	local p = ctx.play -- 287
	local isPlayMode = ctx.mode == 1 and ctx.screen == "play" and p ~= nil -- 288
	local gameplayActive = isPlayMode -- 289
	local modal = not gameplayActive or p == nil or p.paused or p.reloadOpen or p.craftBench.active or p.escortFailed or p.talentModalActive or ctx.ledgerOpen == true -- 290
	local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 292
	local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 293
	local talentOfferCount = #ctx.storyTalentBoxes -- 294
	local ____temp_0 -- 295
	if isPlayMode and p ~= nil then -- 295
		____temp_0 = isCutsceneBlockingPlay(p) -- 295
	else -- 295
		____temp_0 = false -- 295
	end -- 295
	local cutsceneBlocking = ____temp_0 -- 295
	local allowDepth = p ~= nil and p.room.depth ~= nil -- 296
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 297
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and p.escort.state ~= "calming" -- 298
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 300
	local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 302
	local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 305
	local enemyTargets = canShoot and self.settings.aimAssist and p ~= nil and collectAimTargets(p, ctx.cam, vp.stageW, vp.stageH) or ({}) -- 308
	if self.touchControls ~= nil then -- 308
		local pref = self.settings.modePref -- 313
		self.touchControls:syncContext({ -- 314
			viewport = vp, -- 315
			mode = ctx.mode, -- 316
			screen = ctx.screen, -- 317
			play = p, -- 318
			run = ctx.run, -- 319
			cam = ctx.cam, -- 320
			router = self.touchRouter, -- 321
			overlayActive = self:shouldShowTouchControls(ctx.input, vp), -- 322
			allowAutoGameplayTouch = pref == "auto" or pref == "touch", -- 323
			allowMouseOnOverlay = vp.isPortrait or pref == "touch", -- 324
			showWebTopPills = true, -- 325
			canToggleFullscreen = true, -- 326
			assistHintsEnabled = ctx.assistHintsEnabled, -- 327
			isMuted = ctx.isMuted, -- 328
			isFullscreen = ctx.isFullscreen, -- 329
			storyTalentBoxes = ctx.storyTalentBoxes, -- 330
			escortDeathBoxes = ctx.escortDeathBoxes, -- 331
			ledgerOpen = ctx.ledgerOpen, -- 332
			ledgerBox = ctx.ledgerBox, -- 333
			enemyTargets = enemyTargets, -- 334
			dt = ctx.dt -- 335
		}) -- 335
	end -- 335
	local muzzle = p ~= nil and projectMuzzle(p, ctx.cam) or nil -- 339
	local playerScreenX = muzzle and muzzle.x or vp.stageW * 0.5 -- 340
	local playerScreenY = muzzle and muzzle.y or vp.stageH * 0.38 -- 341
	local gpCtx = { -- 343
		stageW = vp.stageW, -- 344
		stageH = vp.stageH, -- 345
		uiScale = vp.uiScale, -- 346
		modal = modal, -- 347
		gameplayActive = gameplayActive, -- 348
		reloadActive = reloadActive, -- 349
		craftActive = craftActive, -- 350
		talentOfferCount = talentOfferCount, -- 351
		childMode = p ~= nil and p.childMode, -- 352
		allowDepth = allowDepth, -- 353
		canShoot = canShoot, -- 354
		canBottleAim = canBottleAim, -- 355
		playerRolling = p ~= nil and p.player.rollT > 0, -- 356
		inLowArch = inLowArch, -- 357
		inTowerEnd = inTowerEnd, -- 358
		playerFacing = p ~= nil and p.player.facing or 1, -- 359
		playerScreenX = playerScreenX, -- 360
		playerScreenY = playerScreenY, -- 361
		enemyTargets = enemyTargets -- 362
	} -- 362
	self.gamepadRouter:setFrameContext(gpCtx, ctx.dt) -- 364
end -- 285
function WebInputDriver.prototype.renderOverlay(self) -- 367
	local ____opt_5 = self.touchControls -- 367
	if ____opt_5 ~= nil then -- 367
		____opt_5:render(self.touchRouter) -- 368
	end -- 368
end -- 367
function WebInputDriver.prototype.clearTransient(self, keepTouchToggles) -- 371
	self.kbm:clearTransient() -- 372
	self.touchRouter:releaseAll(keepTouchToggles) -- 373
	self.gamepadRouter:clearTransient() -- 374
end -- 371
function WebInputDriver.prototype.vibrate(self, seconds) -- 377
	self.touchRouter:vibrate(seconds) -- 378
end -- 377
function WebInputDriver.prototype.onInputModeChanged(self, mode) -- 381
	if mode ~= "touch" then -- 381
		self.touchRouter:releaseAll(false) -- 383
	end -- 383
end -- 381
function WebInputDriver.prototype.shouldShowTouchControls(self, input, vp) -- 387
	if vp.isPortrait then -- 387
		return true -- 388
	end -- 388
	if self.settings.modePref == "touch" then -- 388
		return true -- 389
	end -- 389
	if self.settings.modePref == "kbm" or self.settings.modePref == "gamepad" then -- 389
		return false -- 390
	end -- 390
	return input.inputMode == "touch" -- 391
end -- 387
function WebInputDriver.prototype.getTouchRouter(self) -- 394
	return self.touchRouter -- 395
end -- 394
function WebInputDriver.prototype.getGamepadRouter(self) -- 398
	return self.gamepadRouter -- 399
end -- 398
function WebInputDriver.prototype.getTouchControls(self) -- 402
	return self.touchControls -- 403
end -- 402
function WebInputDriver.prototype.injectTouch(self, phase, id, x, y, fromMouse) -- 406
	self.touchRouter:injectTouch( -- 407
		phase, -- 407
		id, -- 407
		x, -- 407
		y, -- 407
		fromMouse == true -- 407
	) -- 407
end -- 406
function WebInputDriver.prototype.setGamepadSim(self, state) -- 410
	self.gamepadRouter:setSimulatedState(state) -- 411
end -- 410
function WebInputDriver.prototype.pollInto(self, input, dt) -- 414
	if dt == nil then -- 414
		dt = 1 / 60 -- 414
	end -- 414
	input.gamepadLayout = self.settings.gamepadLayout -- 415
	local touch = self.touchRouter:consumeSnapshot() -- 416
	local gp = self.gamepadRouter:consumeSnapshot() -- 417
	local kbm = self.kbm:sample( -- 418
		input:getStageViewport(), -- 418
		dt -- 418
	) -- 418
	local suppressMouse = touch.suppressSyntheticMouse or touch.mouseConsumedByOverlay -- 420
	local realMouseActive = not suppressMouse and (kbm.mouseMoved or kbm.mouseClicked and kbm.mouseInsideStage) -- 421
	if kbm.anyKb or realMouseActive or gp.hadGamepadInput or touch.hadRealTouch then -- 421
		input.userInteracted = true -- 424
	end -- 424
	if self.settings.modePref ~= "auto" then -- 424
		input:setInputMode(self.settings.modePref) -- 428
	elseif gp.hadGamepadInput then -- 428
		input:setInputMode("gamepad") -- 430
	elseif touch.hadGameplayTouch then -- 430
		input:setInputMode("touch") -- 432
	elseif kbm.anyKb or realMouseActive then -- 432
		input:setInputMode("kbm") -- 434
	elseif touch.hadUiTouch and input.inputMode == "kbm" then -- 434
		input:setInputMode("touch") -- 436
	end -- 436
	input.moveX = kbm.moveX ~= 0 and kbm.moveX or (gp.moveX ~= 0 and gp.moveX or touch.moveX) -- 439
	input.moveY = kbm.moveY ~= 0 and kbm.moveY or (gp.moveY ~= 0 and gp.moveY or touch.moveY) -- 440
	local allowMouseFire = not suppressMouse and input.inputMode == "kbm" and kbm.mouseInsideStage -- 442
	local rawFireHeld = allowMouseFire and kbm.mouseLeft or gp.fireHeld or touch.fireHeld -- 443
	input:applyKeyHeld( -- 445
		kbm.jump or gp.jumpHeld or touch.jumpHeld, -- 446
		kbm.crouch or gp.crouchHeld or touch.crouchHeld, -- 447
		kbm.cover or gp.coverHeld or touch.coverHeld, -- 448
		kbm.interact or gp.interactHeld or touch.interactHeld, -- 449
		kbm.aim or gp.aimHeld or touch.aimHeld, -- 450
		rawFireHeld, -- 451
		kbm.flare or gp.flareHeld, -- 452
		kbm.pause, -- 453
		kbm.retry, -- 454
		kbm.toggleView, -- 455
		kbm.tab -- 456
	) -- 456
	input:resetFrameSignals() -- 459
	input.uiWheelY = kbm.mouseWheelY -- 460
	input.ledgerTogglePressed = kbm.ledgerTogglePressed -- 461
	input.retryTapPressed = kbm.retryTapPressed -- 462
	if kbm.pausePressed then -- 462
		input.pause.pressed = true -- 463
	end -- 463
	input.navUp = kbm.navUp -- 466
	input.navDown = kbm.navDown -- 467
	input.navLeft = kbm.navLeft -- 468
	input.navRight = kbm.navRight -- 469
	input.navConfirm = kbm.navConfirm -- 470
	input.craftConfirm = kbm.uiConfirmWithE -- 471
	input.craftCancel = kbm.uiBackSpace -- 472
	local kCol = (kbm.navRight and 1 or 0) - (kbm.navLeft and 1 or 0) -- 473
	local kRow = (kbm.navUp and 1 or 0) - (kbm.navDown and 1 or 0) -- 474
	if kCol ~= 0 or kRow ~= 0 then -- 474
		input.reloadDirCol = kCol -- 476
		input.reloadDirRow = kRow -- 477
		input.reloadStepEdge = true -- 478
		input.reloadAutoStep = false -- 479
	end -- 479
	input.reloadConfirm = kbm.uiConfirmWithE -- 481
	input.reloadReset = kbm.uiBackSpace -- 482
	if gp.jumpPressed then -- 482
		input.jump.pressed = true -- 484
	end -- 484
	if gp.crouchPressed then -- 484
		input.crouch.pressed = true -- 485
	end -- 485
	if gp.interactPressed then -- 485
		input.interact.pressed = true -- 486
	end -- 486
	if gp.aimPressed then -- 486
		input.aim.pressed = true -- 487
	end -- 487
	if gp.firePressed then -- 487
		input.fire.pressed = true -- 488
	end -- 488
	if gp.flarePressed then -- 488
		input.flare.pressed = true -- 489
	end -- 489
	if gp.pausePressed then -- 489
		input.pause.pressed = true -- 490
	end -- 490
	if gp.retryPressed then -- 490
		input.retry.pressed = true -- 491
	end -- 491
	if gp.artifactPressed then -- 491
		input.artifactTogglePressed = true -- 492
	end -- 492
	if gp.anyButtonPressed then -- 492
		input.splashSkipPressed = true -- 493
	end -- 493
	if gp.bottleCanceled then -- 493
		input.bottleCanceled = true -- 495
		input.aim.held = false -- 496
		input.aim.pressed = false -- 497
		input.aim.released = false -- 498
	end -- 498
	if gp.navUp then -- 498
		input.navUp = true -- 500
	end -- 500
	if gp.navDown then -- 500
		input.navDown = true -- 501
	end -- 501
	if gp.navLeft then -- 501
		input.navLeft = true -- 502
	end -- 502
	if gp.navRight then -- 502
		input.navRight = true -- 503
	end -- 503
	if gp.navConfirm then -- 503
		input.navConfirm = true -- 505
		input.craftConfirm = true -- 506
	end -- 506
	if gp.navBack then -- 506
		input.navBack = true -- 509
		input.craftCancel = true -- 510
	end -- 510
	input.navPrevTab = gp.navPrevTab -- 512
	input.navNextTab = gp.navNextTab -- 513
	if gp.reloadStepEdge then -- 513
		input.reloadDirCol = gp.reloadDirCol -- 515
		input.reloadDirRow = gp.reloadDirRow -- 516
		input.reloadStepEdge = true -- 517
		input.reloadAutoStep = gp.reloadAutoStep -- 518
	end -- 518
	if gp.reloadConfirm then -- 518
		input.reloadConfirm = true -- 520
	end -- 520
	if gp.reloadReset then -- 520
		input.reloadReset = true -- 521
	end -- 521
	input.talentDelta = gp.talentDelta -- 522
	input.talentConfirm = gp.talentConfirm -- 523
	input.retryHoldProgress = gp.retryHoldProgress -- 524
	if touch.jumpPressed then -- 524
		input.jump.pressed = true -- 526
	end -- 526
	if touch.interactPressed then -- 526
		input.interact.pressed = true -- 527
	end -- 527
	if touch.firePressed then -- 527
		input.fire.pressed = true -- 528
	end -- 528
	if touch.pausePressed then -- 528
		input.pause.pressed = true -- 529
	end -- 529
	if touch.retryPressed then -- 529
		input.retry.pressed = true -- 530
	end -- 530
	if touch.artifactPressed then -- 530
		input.artifactTogglePressed = true -- 531
	end -- 531
	if touch.mutePressed then -- 531
		input.muteTogglePressed = true -- 532
	end -- 532
	if touch.fullscreenPressed then -- 532
		input.fullscreenTogglePressed = true -- 533
	end -- 533
	if touch.anyTapBegan then -- 533
		input.splashSkipPressed = true -- 534
	end -- 534
	if touch.zoneTap ~= "" then -- 534
		input.touchZoneTap = touch.zoneTap -- 535
	end -- 535
	if touch.navUp then -- 535
		input.navUp = true -- 536
	end -- 536
	if touch.navDown then -- 536
		input.navDown = true -- 537
	end -- 537
	if touch.navLeft then -- 537
		input.navLeft = true -- 538
	end -- 538
	if touch.navRight then -- 538
		input.navRight = true -- 539
	end -- 539
	if touch.navConfirm then -- 539
		input.navConfirm = true -- 541
		input.craftConfirm = true -- 542
	end -- 542
	if touch.navBack then -- 542
		input.navBack = true -- 545
		input.craftCancel = true -- 546
	end -- 546
	if touch.bottleCanceled then -- 546
		input.bottleCanceled = true -- 549
		input.aim.held = false -- 550
		input.aim.pressed = false -- 551
		input.aim.released = false -- 552
	end -- 552
	if not suppressMouse and input.inputMode == "kbm" and input.aim.held and kbm.mouseRightPressed then -- 552
		input.bottleCanceled = true -- 556
		input.aim.held = false -- 557
		input.aim.pressed = false -- 558
		input.aim.released = false -- 559
	end -- 559
	input:applyPickRoom(kbm.pick) -- 562
	input.frameInteractPressed = input.interact.pressed -- 563
	if touch.uiHeld or touch.uiPressed or touch.uiReleased or touch.uiInside then -- 563
		input.uiX = touch.uiX -- 566
		input.uiY = touch.uiY -- 567
		input.uiDx = touch.uiDx -- 568
		input.uiDy = touch.uiDy -- 569
		input.uiInside = touch.uiInside -- 570
		input.uiHeld = touch.uiHeld -- 571
		input.uiPressed = touch.uiPressed -- 572
		input.uiReleased = touch.uiReleased -- 573
		input.uiRightPressed = false -- 574
		if touch.uiHeld or touch.uiPressed then -- 574
			input.mdx = touch.uiDx -- 576
			input.mdy = touch.uiDy -- 577
			input.mx = touch.uiX -- 578
			input.my = touch.uiY -- 579
			input.inside = true -- 580
		elseif touch.hasAim then -- 580
			input.mdx = touch.aimX - input.mx -- 582
			input.mdy = touch.aimY - input.my -- 583
			input.mx = touch.aimX -- 584
			input.my = touch.aimY -- 585
			input.inside = true -- 586
		else -- 586
			input.mdx = 0 -- 588
			input.mdy = 0 -- 589
			input.inside = touch.uiInside -- 590
		end -- 590
		return -- 592
	end -- 592
	if input.inputMode == "gamepad" then -- 592
		if gp.hasAim then -- 592
			input.mdx = gp.aimX - input.mx -- 597
			input.mdy = gp.aimY - input.my -- 598
			input.mx = gp.aimX -- 599
			input.my = gp.aimY -- 600
			input.inside = true -- 601
		else -- 601
			input.mdx = 0 -- 603
			input.mdy = 0 -- 604
			input.inside = false -- 605
		end -- 605
		if not suppressMouse and kbm.mouseInsideStage and (kbm.mouseLeft or kbm.mouseLeftPressed or kbm.mouseLeftReleased) then -- 605
			input.uiDx = kbm.mouseStageX - input.uiX -- 608
			input.uiDy = kbm.mouseStageY - input.uiY -- 609
			input.uiX = kbm.mouseStageX -- 610
			input.uiY = kbm.mouseStageY -- 611
			input.uiInside = true -- 612
			input.uiHeld = kbm.mouseLeft -- 613
			input.uiPressed = kbm.mouseLeftPressed -- 614
			input.uiReleased = kbm.mouseLeftReleased -- 615
			input.uiRightPressed = kbm.mouseRightPressed -- 616
		else -- 616
			input.uiX = input.mx -- 618
			input.uiY = input.my -- 619
			input.uiDx = 0 -- 620
			input.uiDy = 0 -- 621
			input.uiInside = false -- 622
			input.uiHeld = false -- 623
			input.uiPressed = false -- 624
			input.uiReleased = false -- 625
			input.uiRightPressed = false -- 626
		end -- 626
		return -- 628
	end -- 628
	if input.inputMode == "touch" then -- 628
		if touch.hasAim then -- 628
			input.mdx = touch.aimX - input.mx -- 633
			input.mdy = touch.aimY - input.my -- 634
			input.mx = touch.aimX -- 635
			input.my = touch.aimY -- 636
			input.inside = true -- 637
		else -- 637
			input.mdx = 0 -- 639
			input.mdy = 0 -- 640
			input.inside = false -- 641
		end -- 641
		if not suppressMouse and kbm.mouseInsideStage and (kbm.mouseLeft or kbm.mouseLeftPressed or kbm.mouseLeftReleased) then -- 641
			input.uiDx = kbm.mouseStageX - input.uiX -- 644
			input.uiDy = kbm.mouseStageY - input.uiY -- 645
			input.uiX = kbm.mouseStageX -- 646
			input.uiY = kbm.mouseStageY -- 647
			input.uiInside = true -- 648
			input.uiHeld = kbm.mouseLeft -- 649
			input.uiPressed = kbm.mouseLeftPressed -- 650
			input.uiReleased = kbm.mouseLeftReleased -- 651
			input.uiRightPressed = kbm.mouseRightPressed -- 652
		else -- 652
			input.uiDx = 0 -- 654
			input.uiDy = 0 -- 655
			input.uiInside = false -- 656
			input.uiHeld = false -- 657
			input.uiPressed = false -- 658
			input.uiReleased = false -- 659
			input.uiRightPressed = false -- 660
		end -- 660
		return -- 662
	end -- 662
	input.mdx = kbm.mouseStageX - input.mx -- 665
	input.mdy = kbm.mouseStageY - input.my -- 666
	input.mx = kbm.mouseStageX -- 667
	input.my = kbm.mouseStageY -- 668
	input.inside = kbm.mouseInsideStage -- 669
	input.uiX = kbm.mouseStageX -- 671
	input.uiY = kbm.mouseStageY -- 672
	input.uiDx = input.mdx -- 673
	input.uiDy = input.mdy -- 674
	input.uiInside = kbm.mouseInsideStage -- 675
	input.uiHeld = not suppressMouse and kbm.mouseLeft and kbm.mouseInsideStage -- 676
	input.uiPressed = not suppressMouse and kbm.mouseLeftPressed and kbm.mouseInsideStage -- 677
	input.uiReleased = not suppressMouse and kbm.mouseLeftReleased -- 678
	input.uiRightPressed = not suppressMouse and kbm.mouseRightPressed and kbm.mouseInsideStage -- 679
end -- 414
____exports.TARGET = { -- 683
	id = "web", -- 684
	supportsKbm = true, -- 685
	supportsTouch = true, -- 686
	supportsGamepad = true, -- 687
	supportsPortrait = true, -- 688
	defaultInputMode = "kbm", -- 689
	supportedModes = {"kbm", "touch", "gamepad"}, -- 690
	modePrefOrder = MODE_PREF_ORDER, -- 691
	controlsGuideTabs = {{mode = "kbm", label = "键鼠"}, {mode = "gamepad", label = "手柄"}, {mode = "touch", label = "触屏"}}, -- 692
	getPlatformCaps = function(self) -- 698
		local cfg = getReleaseConfig() -- 699
		local ____temp_7 -- 712
		if cfg ~= nil and cfg.isRelease ~= nil then -- 712
			____temp_7 = cfg.isRelease == true -- 712
		else -- 712
			____temp_7 = true -- 712
		end -- 712
		return { -- 700
			kind = "web", -- 701
			target = "web", -- 702
			isDesktop = false, -- 703
			isMobile = false, -- 704
			isWeb = true, -- 705
			isStandaloneAndroidApk = false, -- 706
			canToggleFullscreen = true, -- 707
			canQuit = false, -- 708
			hasBackButton = false, -- 709
			supportsHaptics = false, -- 710
			needsAudioUnlock = true, -- 711
			isRelease = ____temp_7, -- 712
			defaultInputMode = "kbm" -- 713
		} -- 713
	end, -- 698
	canToggleFullscreen = function(self) -- 717
		return true -- 718
	end, -- 717
	canQuitApp = function(self) -- 721
		return false -- 722
	end, -- 721
	isReleaseMode = function(self) -- 725
		local cfg = getReleaseConfig() -- 726
		if cfg ~= nil and cfg.isRelease ~= nil then -- 726
			return cfg.isRelease == true -- 728
		end -- 728
		return true -- 730
	end, -- 725
	computeStageViewport = function(self, fullW, fullH) -- 733
		return computeAdaptiveViewport(fullW, fullH) -- 734
	end, -- 733
	triggerHaptics = function(self, seconds, enabled) -- 737
		triggerMobileHaptics(seconds, enabled) -- 738
	end, -- 737
	keyTagFor = function(self, action, mode, layout) -- 741
		return keyTagWeb(action, mode, layout) -- 742
	end, -- 741
	adaptWorldKeyTag = function(self, rawKeyTag, mode, _layout) -- 745
		return adaptWorldKeyTagWeb(rawKeyTag, mode) -- 746
	end, -- 745
	adaptHintSentence = function(self, text, mode, layout) -- 749
		return adaptHintSentenceWeb(text, mode, layout) -- 750
	end, -- 749
	controlsGuideRows = function(self, tab) -- 753
		if tab == "gamepad" then -- 753
			return GUIDE_GAMEPAD -- 754
		end -- 754
		if tab == "touch" then -- 754
			return GUIDE_TOUCH -- 755
		end -- 755
		return GUIDE_KBM -- 756
	end, -- 753
	splashSkipHint = function(self, mode, layout) -- 759
		if mode == "touch" then -- 759
			return "轻触跳过" -- 760
		end -- 760
		if mode == "gamepad" then -- 760
			return keyTagWeb("confirm", "gamepad", layout) .. " / START  跳过" -- 761
		end -- 761
		return "ESC / SPACE  SKIP" -- 762
	end, -- 759
	titleFooterHint = function(self, mode, layout) -- 765
		if mode == "gamepad" then -- 765
			return ("左摇杆 / 十字键择项   ·   " .. keyTagWeb("confirm", "gamepad", layout)) .. " 或点选启程" -- 767
		end -- 767
		if mode == "touch" then -- 767
			return "轻触择项启程   ·   支持键鼠与手柄" -- 769
		end -- 769
		return "上下择项   ·   回车或点选启程" -- 770
	end, -- 765
	chapterFooterHint = function(self, mode, confirmTag) -- 773
		if mode == "gamepad" then -- 773
			return ("摇杆/十字键选择   ·   " .. confirmTag) .. " 或点选进入" -- 774
		end -- 774
		if mode == "touch" then -- 774
			return "轻触驿站预览   ·   再点或轻触入此卷章" -- 775
		end -- 775
		return "方向键选择   ·   回车或点击进入" -- 776
	end, -- 773
	pauseFooterHint = function(self, mode, layout) -- 779
		if mode == "gamepad" then -- 779
			return ((keyTagWeb("back", "gamepad", layout) .. " / START 续行   ·   ") .. keyTagWeb("confirm", "gamepad", layout)) .. " 确认" -- 781
		end -- 781
		if mode == "touch" then -- 781
			return "轻触确认   ·   点「继续游戏」续行" -- 783
		end -- 783
		return "Esc 续行   ·   Enter 或点击确认" -- 784
	end, -- 779
	settingsFooterHint = function(self, mode, layout) -- 787
		if mode == "gamepad" then -- 787
			return ((("左右或 " .. keyTagWeb("confirm", "gamepad", layout)) .. " 切换   ·   ") .. keyTagWeb("back", "gamepad", layout)) .. " 返回暂停" -- 789
		end -- 789
		if mode == "touch" then -- 789
			return "轻触任意条目切换   ·   设置自动保存" -- 791
		end -- 791
		return "←/→ 或回车/点击切换   ·   Esc 返回暂停" -- 792
	end, -- 787
	controlsFooterRightHint = function(self, mode) -- 795
		if mode == "gamepad" then -- 795
			return "LB / RB 或左右切换键位图" -- 796
		end -- 796
		if mode == "touch" then -- 796
			return "轻触右上页签切图 · 暂歇菜单可调操控设置" -- 797
		end -- 797
		return "←/→ 切页   ·   F11 / Alt+Enter 全屏" -- 798
	end, -- 795
	epilogueFooterHint = function(self, mode, layout) -- 801
		if mode == "gamepad" then -- 801
			return ((keyTagWeb("confirm", "gamepad", layout) .. " 确认   ·   ") .. keyTagWeb("back", "gamepad", layout)) .. " 返回标题" -- 803
		end -- 803
		if mode == "touch" then -- 803
			return "轻触任一入口继续" -- 805
		end -- 805
		return "↑/↓ 选择   ·   Enter / 点击确认   ·   Esc 返回标题" -- 806
	end, -- 801
	settingsRows = function(self) -- 809
		return WEB_SETTINGS_ROWS -- 810
	end, -- 809
	settingsPauseLabel = function(self, settings) -- 813
		return "操控设置 · " .. modePrefLabelOf(settings.modePref) -- 814
	end, -- 813
	settingsHeaderTitle = function(self) -- 817
		return "操控与声音" -- 818
	end, -- 817
	settingsHeaderSummary = function(self, activeMode) -- 821
		return ("当前模式：" .. inputModeLabelOf(activeMode)) .. " · 操控与四通道音量实时生效" -- 822
	end, -- 821
	settingsValueText = function(self, rowId, settings, activeMode) -- 825
		if rowId == "modePref" then -- 825
			return settings.modePref == "auto" and ("自动切换（" .. inputModeLabelOf(activeMode)) .. "）" or "锁定 · " .. modePrefLabelOf(settings.modePref) -- 827
		end -- 827
		if rowId == "aimAssist" then -- 827
			return settings.aimAssist and "开（触屏与手柄共用）" or "关" -- 831
		end -- 831
		if rowId == "gpLayout" then -- 831
			return layoutLabelOf(settings.gamepadLayout) -- 832
		end -- 832
		if rowId == "crouchMode" then -- 832
			return settings.crouchToggle and "点按切换" or "持续按住" -- 833
		end -- 833
		if rowId == "touchOpacity" then -- 833
			return opacityLabelOf(settings.touchOpacity) -- 834
		end -- 834
		if rowId == "touchScale" then -- 834
			return scaleLabelOf(settings.touchScale) -- 835
		end -- 835
		if rowId == "haptics" then -- 835
			return settings.haptics and "开（仅移动端生效）" or "关" -- 836
		end -- 836
		return volumeSettingText(rowId, settings) -- 837
	end, -- 825
	applySettingsDelta = function(self, rowId, delta, settings, input) -- 840
		if rowId == "back" then -- 840
			return "back" -- 841
		end -- 841
		if rowId == "modePref" then -- 841
			input:cycleModePref(delta) -- 843
			return "control" -- 844
		end -- 844
		if rowId == "aimAssist" then -- 844
			settings.aimAssist = not settings.aimAssist -- 847
			saveControlSettings(settings) -- 848
			return "control" -- 849
		end -- 849
		if rowId == "gpLayout" then -- 849
			settings.gamepadLayout = settings.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 852
			input.gamepadLayout = settings.gamepadLayout -- 853
			saveControlSettings(settings) -- 854
			return "control" -- 855
		end -- 855
		if rowId == "crouchMode" then -- 855
			settings.crouchToggle = not settings.crouchToggle -- 858
			saveControlSettings(settings) -- 859
			return "control" -- 860
		end -- 860
		if rowId == "touchOpacity" then -- 860
			settings.touchOpacity = nextStepValue(settings.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 863
			saveControlSettings(settings) -- 864
			return "control" -- 865
		end -- 865
		if rowId == "touchScale" then -- 865
			settings.touchScale = nextStepValue(settings.touchScale, TOUCH_SCALE_STEPS, delta) -- 868
			saveControlSettings(settings) -- 869
			return "control" -- 870
		end -- 870
		if rowId == "haptics" then -- 870
			settings.haptics = not settings.haptics -- 873
			saveControlSettings(settings) -- 874
			return "control" -- 875
		end -- 875
		if applyVolumeSetting(rowId, delta, settings) then -- 875
			return "audio" -- 877
		end -- 877
		return "none" -- 878
	end, -- 840
	createDriver = function(self, settings) -- 881
		return __TS__New(WebInputDriver, settings) -- 882
	end -- 881
} -- 881
return ____exports -- 881