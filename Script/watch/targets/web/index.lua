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
	local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 293
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 295
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and p.escort.state ~= "calming" -- 296
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 298
	local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 300
	local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 303
	local enemyTargets = canShoot and self.settings.aimAssist and p ~= nil and collectAimTargets(p, ctx.cam, vp.stageW, vp.stageH) or ({}) -- 306
	if self.touchControls ~= nil then -- 306
		local pref = self.settings.modePref -- 311
		self.touchControls:syncContext({ -- 312
			viewport = vp, -- 313
			mode = ctx.mode, -- 314
			screen = ctx.screen, -- 315
			play = p, -- 316
			run = ctx.run, -- 317
			cam = ctx.cam, -- 318
			router = self.touchRouter, -- 319
			overlayActive = self:shouldShowTouchControls(ctx.input, vp), -- 320
			allowAutoGameplayTouch = pref == "auto" or pref == "touch", -- 321
			allowMouseOnOverlay = vp.isPortrait or pref == "touch", -- 322
			showWebTopPills = true, -- 323
			canToggleFullscreen = true, -- 324
			assistHintsEnabled = ctx.assistHintsEnabled, -- 325
			isMuted = ctx.isMuted, -- 326
			isFullscreen = ctx.isFullscreen, -- 327
			storyTalentBoxes = ctx.storyTalentBoxes, -- 328
			escortDeathBoxes = ctx.escortDeathBoxes, -- 329
			ledgerOpen = ctx.ledgerOpen, -- 330
			ledgerBox = ctx.ledgerBox, -- 331
			enemyTargets = enemyTargets, -- 332
			dt = ctx.dt -- 333
		}) -- 333
	end -- 333
	local muzzle = p ~= nil and projectMuzzle(p, ctx.cam) or nil -- 337
	local playerScreenX = muzzle and muzzle.x or vp.stageW * 0.5 -- 338
	local playerScreenY = muzzle and muzzle.y or vp.stageH * 0.38 -- 339
	local gpCtx = { -- 341
		stageW = vp.stageW, -- 342
		stageH = vp.stageH, -- 343
		uiScale = vp.uiScale, -- 344
		modal = modal, -- 345
		gameplayActive = gameplayActive, -- 346
		reloadActive = reloadActive, -- 347
		craftActive = craftActive, -- 348
		talentOfferCount = talentOfferCount, -- 349
		childMode = p ~= nil and p.childMode, -- 350
		allowDepth = allowDepth, -- 351
		canShoot = canShoot, -- 352
		canBottleAim = canBottleAim, -- 353
		playerRolling = p ~= nil and p.player.rollT > 0, -- 354
		inLowArch = inLowArch, -- 355
		inTowerEnd = inTowerEnd, -- 356
		playerFacing = p ~= nil and p.player.facing or 1, -- 357
		playerScreenX = playerScreenX, -- 358
		playerScreenY = playerScreenY, -- 359
		enemyTargets = enemyTargets -- 360
	} -- 360
	self.gamepadRouter:setFrameContext(gpCtx, ctx.dt) -- 362
end -- 282
function WebInputDriver.prototype.renderOverlay(self) -- 365
	local ____opt_5 = self.touchControls -- 365
	if ____opt_5 ~= nil then -- 365
		____opt_5:render(self.touchRouter) -- 366
	end -- 366
end -- 365
function WebInputDriver.prototype.clearTransient(self, keepTouchToggles) -- 369
	self.touchRouter:releaseAll(keepTouchToggles) -- 370
	self.gamepadRouter:clearTransient() -- 371
end -- 369
function WebInputDriver.prototype.vibrate(self, seconds) -- 374
	self.touchRouter:vibrate(seconds) -- 375
end -- 374
function WebInputDriver.prototype.onInputModeChanged(self, mode) -- 378
	if mode ~= "touch" then -- 378
		self.touchRouter:releaseAll(false) -- 380
	end -- 380
end -- 378
function WebInputDriver.prototype.shouldShowTouchControls(self, input, vp) -- 384
	if vp.isPortrait then -- 384
		return true -- 385
	end -- 385
	if self.settings.modePref == "touch" then -- 385
		return true -- 386
	end -- 386
	if self.settings.modePref == "kbm" or self.settings.modePref == "gamepad" then -- 386
		return false -- 387
	end -- 387
	return input.inputMode == "touch" -- 388
end -- 384
function WebInputDriver.prototype.getTouchRouter(self) -- 391
	return self.touchRouter -- 392
end -- 391
function WebInputDriver.prototype.getGamepadRouter(self) -- 395
	return self.gamepadRouter -- 396
end -- 395
function WebInputDriver.prototype.getTouchControls(self) -- 399
	return self.touchControls -- 400
end -- 399
function WebInputDriver.prototype.injectTouch(self, phase, id, x, y, fromMouse) -- 403
	self.touchRouter:injectTouch( -- 404
		phase, -- 404
		id, -- 404
		x, -- 404
		y, -- 404
		fromMouse == true -- 404
	) -- 404
end -- 403
function WebInputDriver.prototype.setGamepadSim(self, state) -- 407
	self.gamepadRouter:setSimulatedState(state) -- 408
end -- 407
function WebInputDriver.prototype.pollInto(self, input) -- 411
	input.gamepadLayout = self.settings.gamepadLayout -- 412
	local touch = self.touchRouter:consumeSnapshot() -- 413
	local gp = self.gamepadRouter:consumeSnapshot() -- 414
	local kbm = self.kbm:sample(input:getStageViewport()) -- 415
	local suppressMouse = touch.suppressSyntheticMouse or touch.mouseConsumedByOverlay -- 417
	local realMouseActive = not suppressMouse and (kbm.mouseMoved or kbm.mouseClicked and kbm.mouseInsideStage) -- 418
	if kbm.anyKb or realMouseActive or gp.hadGamepadInput or touch.hadRealTouch then -- 418
		input.userInteracted = true -- 421
	end -- 421
	if self.settings.modePref ~= "auto" then -- 421
		input:setInputMode(self.settings.modePref) -- 425
	elseif gp.hadGamepadInput then -- 425
		input:setInputMode("gamepad") -- 427
	elseif touch.hadGameplayTouch then -- 427
		input:setInputMode("touch") -- 429
	elseif kbm.anyKb or realMouseActive then -- 429
		input:setInputMode("kbm") -- 431
	elseif touch.hadUiTouch and input.inputMode == "kbm" then -- 431
		input:setInputMode("touch") -- 433
	end -- 433
	input.moveX = kbm.moveX ~= 0 and kbm.moveX or (gp.moveX ~= 0 and gp.moveX or touch.moveX) -- 436
	input.moveY = kbm.moveY ~= 0 and kbm.moveY or (gp.moveY ~= 0 and gp.moveY or touch.moveY) -- 437
	local allowMouseFire = not suppressMouse and input.inputMode == "kbm" and kbm.mouseInsideStage -- 439
	local rawFireHeld = allowMouseFire and kbm.mouseLeft or gp.fireHeld or touch.fireHeld -- 440
	input:applyKeyHeld( -- 442
		kbm.jump or gp.jumpHeld or touch.jumpHeld, -- 443
		kbm.crouch or gp.crouchHeld or touch.crouchHeld, -- 444
		kbm.cover or gp.coverHeld or touch.coverHeld, -- 445
		kbm.interact or gp.interactHeld or touch.interactHeld, -- 446
		kbm.aim or gp.aimHeld or touch.aimHeld, -- 447
		rawFireHeld, -- 448
		kbm.flare or gp.flareHeld, -- 449
		kbm.pause, -- 450
		kbm.retry, -- 451
		kbm.toggleView, -- 452
		kbm.tab -- 453
	) -- 453
	input:resetFrameSignals() -- 456
	input.navUp = kbm.navUp -- 459
	input.navDown = kbm.navDown -- 460
	input.navLeft = kbm.navLeft -- 461
	input.navRight = kbm.navRight -- 462
	input.navConfirm = kbm.navConfirm -- 463
	input.craftConfirm = kbm.uiConfirmWithE -- 464
	input.craftCancel = kbm.uiBackSpace -- 465
	local kCol = (kbm.navRight and 1 or 0) - (kbm.navLeft and 1 or 0) -- 466
	local kRow = (kbm.navUp and 1 or 0) - (kbm.navDown and 1 or 0) -- 467
	if kCol ~= 0 or kRow ~= 0 then -- 467
		input.reloadDirCol = kCol -- 469
		input.reloadDirRow = kRow -- 470
		input.reloadStepEdge = true -- 471
		input.reloadAutoStep = false -- 472
	end -- 472
	input.reloadConfirm = kbm.uiConfirmWithE -- 474
	input.reloadReset = kbm.uiBackSpace -- 475
	if gp.jumpPressed then -- 475
		input.jump.pressed = true -- 477
	end -- 477
	if gp.crouchPressed then -- 477
		input.crouch.pressed = true -- 478
	end -- 478
	if gp.interactPressed then -- 478
		input.interact.pressed = true -- 479
	end -- 479
	if gp.aimPressed then -- 479
		input.aim.pressed = true -- 480
	end -- 480
	if gp.firePressed then -- 480
		input.fire.pressed = true -- 481
	end -- 481
	if gp.flarePressed then -- 481
		input.flare.pressed = true -- 482
	end -- 482
	if gp.pausePressed then -- 482
		input.pause.pressed = true -- 483
	end -- 483
	if gp.retryPressed then -- 483
		input.retry.pressed = true -- 484
	end -- 484
	if gp.artifactPressed then -- 484
		input.artifactTogglePressed = true -- 485
	end -- 485
	if gp.anyButtonPressed then -- 485
		input.splashSkipPressed = true -- 486
	end -- 486
	if gp.bottleCanceled then -- 486
		input.bottleCanceled = true -- 488
		input.aim.held = false -- 489
		input.aim.pressed = false -- 490
		input.aim.released = false -- 491
	end -- 491
	if gp.navUp then -- 491
		input.navUp = true -- 493
	end -- 493
	if gp.navDown then -- 493
		input.navDown = true -- 494
	end -- 494
	if gp.navLeft then -- 494
		input.navLeft = true -- 495
	end -- 495
	if gp.navRight then -- 495
		input.navRight = true -- 496
	end -- 496
	if gp.navConfirm then -- 496
		input.navConfirm = true -- 498
		input.craftConfirm = true -- 499
	end -- 499
	if gp.navBack then -- 499
		input.navBack = true -- 502
		input.craftCancel = true -- 503
	end -- 503
	input.navPrevTab = gp.navPrevTab -- 505
	input.navNextTab = gp.navNextTab -- 506
	if gp.reloadStepEdge then -- 506
		input.reloadDirCol = gp.reloadDirCol -- 508
		input.reloadDirRow = gp.reloadDirRow -- 509
		input.reloadStepEdge = true -- 510
		input.reloadAutoStep = gp.reloadAutoStep -- 511
	end -- 511
	if gp.reloadConfirm then -- 511
		input.reloadConfirm = true -- 513
	end -- 513
	if gp.reloadReset then -- 513
		input.reloadReset = true -- 514
	end -- 514
	input.talentDelta = gp.talentDelta -- 515
	input.talentConfirm = gp.talentConfirm -- 516
	input.retryHoldProgress = gp.retryHoldProgress -- 517
	if touch.jumpPressed then -- 517
		input.jump.pressed = true -- 519
	end -- 519
	if touch.interactPressed then -- 519
		input.interact.pressed = true -- 520
	end -- 520
	if touch.firePressed then -- 520
		input.fire.pressed = true -- 521
	end -- 521
	if touch.pausePressed then -- 521
		input.pause.pressed = true -- 522
	end -- 522
	if touch.retryPressed then -- 522
		input.retry.pressed = true -- 523
	end -- 523
	if touch.artifactPressed then -- 523
		input.artifactTogglePressed = true -- 524
	end -- 524
	if touch.mutePressed then -- 524
		input.muteTogglePressed = true -- 525
	end -- 525
	if touch.fullscreenPressed then -- 525
		input.fullscreenTogglePressed = true -- 526
	end -- 526
	if touch.anyTapBegan then -- 526
		input.splashSkipPressed = true -- 527
	end -- 527
	if touch.zoneTap ~= "" then -- 527
		input.touchZoneTap = touch.zoneTap -- 528
	end -- 528
	if touch.navUp then -- 528
		input.navUp = true -- 529
	end -- 529
	if touch.navDown then -- 529
		input.navDown = true -- 530
	end -- 530
	if touch.navLeft then -- 530
		input.navLeft = true -- 531
	end -- 531
	if touch.navRight then -- 531
		input.navRight = true -- 532
	end -- 532
	if touch.navConfirm then -- 532
		input.navConfirm = true -- 534
		input.craftConfirm = true -- 535
	end -- 535
	if touch.navBack then -- 535
		input.navBack = true -- 538
		input.craftCancel = true -- 539
	end -- 539
	if touch.bottleCanceled then -- 539
		input.bottleCanceled = true -- 542
		input.aim.held = false -- 543
		input.aim.pressed = false -- 544
		input.aim.released = false -- 545
	end -- 545
	if not suppressMouse and input.inputMode == "kbm" and input.aim.held and kbm.mouseRightPressed then -- 545
		input.bottleCanceled = true -- 549
		input.aim.held = false -- 550
		input.aim.pressed = false -- 551
		input.aim.released = false -- 552
	end -- 552
	input:applyPickRoom(kbm.pick) -- 555
	input.frameInteractPressed = input.interact.pressed -- 556
	if touch.uiHeld or touch.uiPressed or touch.uiReleased or touch.uiInside then -- 556
		input.uiX = touch.uiX -- 559
		input.uiY = touch.uiY -- 560
		input.uiDx = touch.uiDx -- 561
		input.uiDy = touch.uiDy -- 562
		input.uiInside = touch.uiInside -- 563
		input.uiHeld = touch.uiHeld -- 564
		input.uiPressed = touch.uiPressed -- 565
		input.uiReleased = touch.uiReleased -- 566
		input.uiRightPressed = false -- 567
		if touch.uiHeld or touch.uiPressed then -- 567
			input.mdx = touch.uiDx -- 569
			input.mdy = touch.uiDy -- 570
			input.mx = touch.uiX -- 571
			input.my = touch.uiY -- 572
			input.inside = true -- 573
		elseif touch.hasAim then -- 573
			input.mdx = touch.aimX - input.mx -- 575
			input.mdy = touch.aimY - input.my -- 576
			input.mx = touch.aimX -- 577
			input.my = touch.aimY -- 578
			input.inside = true -- 579
		else -- 579
			input.mdx = 0 -- 581
			input.mdy = 0 -- 582
			input.inside = touch.uiInside -- 583
		end -- 583
		return -- 585
	end -- 585
	if input.inputMode == "gamepad" then -- 585
		if gp.hasAim then -- 585
			input.mdx = gp.aimX - input.mx -- 590
			input.mdy = gp.aimY - input.my -- 591
			input.mx = gp.aimX -- 592
			input.my = gp.aimY -- 593
			input.inside = true -- 594
		else -- 594
			input.mdx = 0 -- 596
			input.mdy = 0 -- 597
			input.inside = false -- 598
		end -- 598
		if not suppressMouse and kbm.mouseInsideStage and (kbm.mouseLeft or kbm.mouseLeftPressed or kbm.mouseLeftReleased) then -- 598
			input.uiDx = kbm.mouseStageX - input.uiX -- 601
			input.uiDy = kbm.mouseStageY - input.uiY -- 602
			input.uiX = kbm.mouseStageX -- 603
			input.uiY = kbm.mouseStageY -- 604
			input.uiInside = true -- 605
			input.uiHeld = kbm.mouseLeft -- 606
			input.uiPressed = kbm.mouseLeftPressed -- 607
			input.uiReleased = kbm.mouseLeftReleased -- 608
			input.uiRightPressed = kbm.mouseRightPressed -- 609
		else -- 609
			input.uiX = input.mx -- 611
			input.uiY = input.my -- 612
			input.uiDx = 0 -- 613
			input.uiDy = 0 -- 614
			input.uiInside = false -- 615
			input.uiHeld = false -- 616
			input.uiPressed = false -- 617
			input.uiReleased = false -- 618
			input.uiRightPressed = false -- 619
		end -- 619
		return -- 621
	end -- 621
	if input.inputMode == "touch" then -- 621
		if touch.hasAim then -- 621
			input.mdx = touch.aimX - input.mx -- 626
			input.mdy = touch.aimY - input.my -- 627
			input.mx = touch.aimX -- 628
			input.my = touch.aimY -- 629
			input.inside = true -- 630
		else -- 630
			input.mdx = 0 -- 632
			input.mdy = 0 -- 633
			input.inside = false -- 634
		end -- 634
		if not suppressMouse and kbm.mouseInsideStage and (kbm.mouseLeft or kbm.mouseLeftPressed or kbm.mouseLeftReleased) then -- 634
			input.uiDx = kbm.mouseStageX - input.uiX -- 637
			input.uiDy = kbm.mouseStageY - input.uiY -- 638
			input.uiX = kbm.mouseStageX -- 639
			input.uiY = kbm.mouseStageY -- 640
			input.uiInside = true -- 641
			input.uiHeld = kbm.mouseLeft -- 642
			input.uiPressed = kbm.mouseLeftPressed -- 643
			input.uiReleased = kbm.mouseLeftReleased -- 644
			input.uiRightPressed = kbm.mouseRightPressed -- 645
		else -- 645
			input.uiDx = 0 -- 647
			input.uiDy = 0 -- 648
			input.uiInside = false -- 649
			input.uiHeld = false -- 650
			input.uiPressed = false -- 651
			input.uiReleased = false -- 652
			input.uiRightPressed = false -- 653
		end -- 653
		return -- 655
	end -- 655
	input.mdx = kbm.mouseStageX - input.mx -- 658
	input.mdy = kbm.mouseStageY - input.my -- 659
	input.mx = kbm.mouseStageX -- 660
	input.my = kbm.mouseStageY -- 661
	input.inside = kbm.mouseInsideStage -- 662
	input.uiX = kbm.mouseStageX -- 664
	input.uiY = kbm.mouseStageY -- 665
	input.uiDx = input.mdx -- 666
	input.uiDy = input.mdy -- 667
	input.uiInside = kbm.mouseInsideStage -- 668
	input.uiHeld = not suppressMouse and kbm.mouseLeft and kbm.mouseInsideStage -- 669
	input.uiPressed = not suppressMouse and kbm.mouseLeftPressed and kbm.mouseInsideStage -- 670
	input.uiReleased = not suppressMouse and kbm.mouseLeftReleased -- 671
	input.uiRightPressed = not suppressMouse and kbm.mouseRightPressed and kbm.mouseInsideStage -- 672
end -- 411
____exports.TARGET = { -- 676
	id = "web", -- 677
	supportsKbm = true, -- 678
	supportsTouch = true, -- 679
	supportsGamepad = true, -- 680
	supportsPortrait = true, -- 681
	defaultInputMode = "kbm", -- 682
	supportedModes = {"kbm", "touch", "gamepad"}, -- 683
	modePrefOrder = MODE_PREF_ORDER, -- 684
	controlsGuideTabs = {{mode = "kbm", label = "键鼠"}, {mode = "gamepad", label = "手柄"}, {mode = "touch", label = "触屏"}}, -- 685
	getPlatformCaps = function(self) -- 691
		local cfg = getReleaseConfig() -- 692
		local ____temp_7 -- 705
		if cfg ~= nil and cfg.isRelease ~= nil then -- 705
			____temp_7 = cfg.isRelease == true -- 705
		else -- 705
			____temp_7 = true -- 705
		end -- 705
		return { -- 693
			kind = "web", -- 694
			target = "web", -- 695
			isDesktop = false, -- 696
			isMobile = false, -- 697
			isWeb = true, -- 698
			isStandaloneAndroidApk = false, -- 699
			canToggleFullscreen = true, -- 700
			canQuit = false, -- 701
			hasBackButton = false, -- 702
			supportsHaptics = false, -- 703
			needsAudioUnlock = true, -- 704
			isRelease = ____temp_7, -- 705
			defaultInputMode = "kbm" -- 706
		} -- 706
	end, -- 691
	canToggleFullscreen = function(self) -- 710
		return true -- 711
	end, -- 710
	canQuitApp = function(self) -- 714
		return false -- 715
	end, -- 714
	isReleaseMode = function(self) -- 718
		local cfg = getReleaseConfig() -- 719
		if cfg ~= nil and cfg.isRelease ~= nil then -- 719
			return cfg.isRelease == true -- 721
		end -- 721
		return true -- 723
	end, -- 718
	computeStageViewport = function(self, fullW, fullH) -- 726
		return computeAdaptiveViewport(fullW, fullH) -- 727
	end, -- 726
	triggerHaptics = function(self, seconds, enabled) -- 730
		triggerMobileHaptics(seconds, enabled) -- 731
	end, -- 730
	keyTagFor = function(self, action, mode, layout) -- 734
		return keyTagWeb(action, mode, layout) -- 735
	end, -- 734
	adaptWorldKeyTag = function(self, rawKeyTag, mode, _layout) -- 738
		return adaptWorldKeyTagWeb(rawKeyTag, mode) -- 739
	end, -- 738
	adaptHintSentence = function(self, text, mode, layout) -- 742
		return adaptHintSentenceWeb(text, mode, layout) -- 743
	end, -- 742
	controlsGuideRows = function(self, tab) -- 746
		if tab == "gamepad" then -- 746
			return GUIDE_GAMEPAD -- 747
		end -- 747
		if tab == "touch" then -- 747
			return GUIDE_TOUCH -- 748
		end -- 748
		return GUIDE_KBM -- 749
	end, -- 746
	splashSkipHint = function(self, mode, layout) -- 752
		if mode == "touch" then -- 752
			return "轻触跳过" -- 753
		end -- 753
		if mode == "gamepad" then -- 753
			return keyTagWeb("confirm", "gamepad", layout) .. " / START  跳过" -- 754
		end -- 754
		return "ESC / SPACE  SKIP" -- 755
	end, -- 752
	titleFooterHint = function(self, mode, layout) -- 758
		if mode == "gamepad" then -- 758
			return ("左摇杆 / 十字键择项   ·   " .. keyTagWeb("confirm", "gamepad", layout)) .. " 或点选启程" -- 760
		end -- 760
		if mode == "touch" then -- 760
			return "轻触择项启程   ·   支持键鼠与手柄" -- 762
		end -- 762
		return "上下择项   ·   回车或点选启程" -- 763
	end, -- 758
	chapterFooterHint = function(self, mode, confirmTag) -- 766
		if mode == "gamepad" then -- 766
			return ("摇杆/十字键选择   ·   " .. confirmTag) .. " 或点选进入" -- 767
		end -- 767
		if mode == "touch" then -- 767
			return "轻触驿站预览   ·   再点或轻触入此卷章" -- 768
		end -- 768
		return "方向键选择   ·   回车或点击进入" -- 769
	end, -- 766
	pauseFooterHint = function(self, mode, layout) -- 772
		if mode == "gamepad" then -- 772
			return ((keyTagWeb("back", "gamepad", layout) .. " / START 续行   ·   ") .. keyTagWeb("confirm", "gamepad", layout)) .. " 确认" -- 774
		end -- 774
		if mode == "touch" then -- 774
			return "轻触确认   ·   点「继续游戏」续行" -- 776
		end -- 776
		return "Esc 续行   ·   Enter 或点击确认" -- 777
	end, -- 772
	settingsFooterHint = function(self, mode, layout) -- 780
		if mode == "gamepad" then -- 780
			return ((("左右或 " .. keyTagWeb("confirm", "gamepad", layout)) .. " 切换   ·   ") .. keyTagWeb("back", "gamepad", layout)) .. " 返回暂停" -- 782
		end -- 782
		if mode == "touch" then -- 782
			return "轻触任意条目切换   ·   设置自动保存" -- 784
		end -- 784
		return "←/→ 或回车/点击切换   ·   Esc 返回暂停" -- 785
	end, -- 780
	controlsFooterRightHint = function(self, mode) -- 788
		if mode == "gamepad" then -- 788
			return "LB / RB 或左右切换键位图" -- 789
		end -- 789
		if mode == "touch" then -- 789
			return "轻触右上页签切图 · 暂歇菜单可调操控设置" -- 790
		end -- 790
		return "←/→ 切页   ·   F11 / Alt+Enter 全屏" -- 791
	end, -- 788
	epilogueFooterHint = function(self, mode, layout) -- 794
		if mode == "gamepad" then -- 794
			return ((keyTagWeb("confirm", "gamepad", layout) .. " 确认   ·   ") .. keyTagWeb("back", "gamepad", layout)) .. " 返回标题" -- 796
		end -- 796
		if mode == "touch" then -- 796
			return "轻触任一入口继续" -- 798
		end -- 798
		return "↑/↓ 选择   ·   Enter / 点击确认   ·   Esc 返回标题" -- 799
	end, -- 794
	settingsRows = function(self) -- 802
		return WEB_SETTINGS_ROWS -- 803
	end, -- 802
	settingsPauseLabel = function(self, settings) -- 806
		return "操控设置 · " .. modePrefLabelOf(settings.modePref) -- 807
	end, -- 806
	settingsHeaderTitle = function(self) -- 810
		return "操控与声音" -- 811
	end, -- 810
	settingsHeaderSummary = function(self, activeMode) -- 814
		return ("当前模式：" .. inputModeLabelOf(activeMode)) .. " · 操控与四通道音量实时生效" -- 815
	end, -- 814
	settingsValueText = function(self, rowId, settings, activeMode) -- 818
		if rowId == "modePref" then -- 818
			return settings.modePref == "auto" and ("自动切换（" .. inputModeLabelOf(activeMode)) .. "）" or "锁定 · " .. modePrefLabelOf(settings.modePref) -- 820
		end -- 820
		if rowId == "aimAssist" then -- 820
			return settings.aimAssist and "开（触屏与手柄共用）" or "关" -- 824
		end -- 824
		if rowId == "gpLayout" then -- 824
			return layoutLabelOf(settings.gamepadLayout) -- 825
		end -- 825
		if rowId == "crouchMode" then -- 825
			return settings.crouchToggle and "点按切换" or "持续按住" -- 826
		end -- 826
		if rowId == "touchOpacity" then -- 826
			return opacityLabelOf(settings.touchOpacity) -- 827
		end -- 827
		if rowId == "touchScale" then -- 827
			return scaleLabelOf(settings.touchScale) -- 828
		end -- 828
		if rowId == "haptics" then -- 828
			return settings.haptics and "开（仅移动端生效）" or "关" -- 829
		end -- 829
		return volumeSettingText(rowId, settings) -- 830
	end, -- 818
	applySettingsDelta = function(self, rowId, delta, settings, input) -- 833
		if rowId == "back" then -- 833
			return "back" -- 834
		end -- 834
		if rowId == "modePref" then -- 834
			input:cycleModePref(delta) -- 836
			return "control" -- 837
		end -- 837
		if rowId == "aimAssist" then -- 837
			settings.aimAssist = not settings.aimAssist -- 840
			saveControlSettings(settings) -- 841
			return "control" -- 842
		end -- 842
		if rowId == "gpLayout" then -- 842
			settings.gamepadLayout = settings.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 845
			input.gamepadLayout = settings.gamepadLayout -- 846
			saveControlSettings(settings) -- 847
			return "control" -- 848
		end -- 848
		if rowId == "crouchMode" then -- 848
			settings.crouchToggle = not settings.crouchToggle -- 851
			saveControlSettings(settings) -- 852
			return "control" -- 853
		end -- 853
		if rowId == "touchOpacity" then -- 853
			settings.touchOpacity = nextStepValue(settings.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 856
			saveControlSettings(settings) -- 857
			return "control" -- 858
		end -- 858
		if rowId == "touchScale" then -- 858
			settings.touchScale = nextStepValue(settings.touchScale, TOUCH_SCALE_STEPS, delta) -- 861
			saveControlSettings(settings) -- 862
			return "control" -- 863
		end -- 863
		if rowId == "haptics" then -- 863
			settings.haptics = not settings.haptics -- 866
			saveControlSettings(settings) -- 867
			return "control" -- 868
		end -- 868
		if applyVolumeSetting(rowId, delta, settings) then -- 868
			return "audio" -- 870
		end -- 870
		return "none" -- 871
	end, -- 833
	createDriver = function(self, settings) -- 874
		return __TS__New(WebInputDriver, settings) -- 875
	end -- 874
} -- 874
return ____exports -- 874