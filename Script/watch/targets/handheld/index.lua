-- [ts]: index.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 12
local App = ____Dora.App -- 12
local ____depth = require("Script.watch.depth") -- 13
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 13
local ____aim_assist = require("Script.watch.input.aim_assist") -- 14
local collectPlayAimTargets = ____aim_assist.collectPlayAimTargets -- 14
local collectTrialAimTargets = ____aim_assist.collectTrialAimTargets -- 14
local ____gamepad_core = require("Script.watch.input.gamepad_core") -- 15
local GamepadRouter = ____gamepad_core.GamepadRouter -- 15
local ____touch_core = require("Script.watch.input.touch_core") -- 16
local TouchRouter = ____touch_core.TouchRouter -- 16
local ____touch_hud_landscape = require("Script.watch.input.touch_hud_landscape") -- 17
local TouchControls = ____touch_hud_landscape.TouchControls -- 17
local ____play_prompts = require("Script.watch.fe.ui.play_prompts") -- 18
local isCutsceneBlockingPlay = ____play_prompts.isCutsceneBlockingPlay -- 18
local ____platform_mobile = require("Script.watch.platform_mobile") -- 19
local computeLandscapeSafeViewport = ____platform_mobile.computeLandscapeSafeViewport -- 19
local triggerMobileHaptics = ____platform_mobile.triggerMobileHaptics -- 19
local ____controls_config = require("Script.watch.controls_config") -- 20
local TOUCH_OPACITY_STEPS = ____controls_config.TOUCH_OPACITY_STEPS -- 21
local TOUCH_SCALE_STEPS = ____controls_config.TOUCH_SCALE_STEPS -- 22
local applyVolumeSetting = ____controls_config.applyVolumeSetting -- 23
local inputModeLabelOf = ____controls_config.inputModeLabelOf -- 24
local layoutLabelOf = ____controls_config.layoutLabelOf -- 25
local modePrefLabelOf = ____controls_config.modePrefLabelOf -- 26
local nextStepValue = ____controls_config.nextStepValue -- 27
local opacityLabelOf = ____controls_config.opacityLabelOf -- 28
local saveControlSettings = ____controls_config.saveControlSettings -- 29
local scaleLabelOf = ____controls_config.scaleLabelOf -- 30
local volumeSettingText = ____controls_config.volumeSettingText -- 31
local ____target_types = require("Script.watch.target_types") -- 34
local getReleaseConfig = ____target_types.getReleaseConfig -- 48
local HANDHELD_MODE_PREFS = {"auto", "gamepad", "touch"} -- 51
local HANDHELD_SETTINGS_ROWS = { -- 53
	{id = "modePref", title = "操作模式"}, -- 54
	{id = "aimAssist", title = "瞄准磁吸"}, -- 55
	{id = "gpLayout", title = "手柄确认键"}, -- 56
	{id = "crouchMode", title = "手柄蹲伏方式"}, -- 57
	{id = "touchOpacity", title = "触控按键透度"}, -- 58
	{id = "touchScale", title = "触控按键大小"}, -- 59
	{id = "haptics", title = "触觉震动反馈"}, -- 60
	{id = "masterVol", title = "主音量"}, -- 61
	{id = "bgmVol", title = "音乐音量"}, -- 62
	{id = "sfxVol", title = "音效与环境"}, -- 63
	{id = "voiceVol", title = "人声音量"}, -- 64
	{id = "back", title = "返回暂歇菜单"} -- 65
} -- 65
local GUIDE_GAMEPAD = {subtitle = "手柄操作说明 · 掌机横屏", soldierRows = { -- 68
	{"左摇杆 / 十字键", "左右、前后纵深移动"}, -- 71
	{"右摇杆 + RT / X", "360° 瞄准与发射火铳（含轻磁吸）"}, -- 72
	{"按住 LT / LB", "贴靠柜台 / 街垒挡下铅丸"}, -- 73
	{"A 键", "平地翻滚 / 靠近矮柜翻越"}, -- 74
	{"Y / RB 键", "递物 / 轻敲安抚 / 按住推车"}, -- 75
	{"摇杆直推 / 触屏", "慢时连线换弹 · B 键清空重画"} -- 76
}, childRows = { -- 78
	{"左摇杆轻推", "内圈轻步慢走（LT/LB 亦可）"}, -- 79
	{"B 键", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 80
	{"A 键", "跳跃攀上石阶与矮台"}, -- 81
	{"Y / RB 键", "拾瓶 / 敲塔门 / 握柄拉车"}, -- 82
	{"RT/X 按住→松开", "右摇杆调落点投瓶 · B 取消"}, -- 83
	{"START / BACK", "暂歇 / 长按重试 · L3 切神器"} -- 84
}} -- 84
local GUIDE_TOUCH = {subtitle = "触屏操作说明 · 掌机横屏", soldierRows = { -- 88
	{"左水墨摇杆", "全向走位与里外道切线"}, -- 91
	{"点屏 / 开火钮", "直点射击或拖住开火钮 360° 精瞄"}, -- 92
	{"掩体开关", "轻点贴靠掩体，再点或翻滚离掩"}, -- 93
	{"翻滚 / 翻越", "平地翻滚，贴近矮柜自动翻越"}, -- 94
	{"交互 / 推车", "点推车自动锁握柄，长按牵手交物"}, -- 95
	{"换弹九宫格", "单指一笔滑连至右上，点重画清空"} -- 96
}, childRows = { -- 98
	{"摇杆内圈 / 轻步", "轻推内圈或点轻步压低脚步声"}, -- 99
	{"蹲伏开关", "点按蹲下钻桌穿拱，点跳顺滑起身"}, -- 100
	{"跳跃钮", "攀上石阶、红布车与矮台"}, -- 101
	{"投瓶拖瞄", "按住投瓶拖向砖地，拖回取消圈放弃"}, -- 102
	{"交互 / 拉车", "拾瓶、敲塔门、点拉车锁定握柄"}, -- 103
	{"右上暂歇", "顶栏随时暂歇，手柄与触屏可混用"} -- 104
}} -- 104
local function isStandaloneApk() -- 108
	local cfg = getReleaseConfig() -- 109
	return cfg ~= nil and cfg.platform == "Android" -- 110
end -- 108
local function keyTagHandheld(action, mode, layout) -- 113
	if mode == "touch" then -- 114
		if action == "interact" then -- 115
			return "点按" -- 115
		end -- 115
		if action == "jump" then -- 116
			return "跳/滚" -- 116
		end -- 116
		if action == "crouch" then -- 117
			return "蹲伏" -- 117
		end -- 117
		if action == "cover" then -- 118
			return "掩体" -- 118
		end -- 118
		if action == "fire" then -- 119
			return "开火" -- 119
		end -- 119
		if action == "aim" then -- 120
			return "拖投瓶" -- 120
		end -- 120
		if action == "pause" then -- 121
			return "暂歇" -- 121
		end -- 121
		if action == "retry" then -- 122
			return "重试" -- 122
		end -- 122
		if action == "confirm" then -- 123
			return "点选" -- 123
		end -- 123
		if action == "back" then -- 124
			return "返回" -- 124
		end -- 124
		return "穿梭" -- 125
	end -- 125
	local confirmBtn = layout == "nintendo" and "B" or "A" -- 127
	local backBtn = layout == "nintendo" and "A" or "B" -- 128
	if action == "interact" then -- 129
		return "Y / RB" -- 129
	end -- 129
	if action == "jump" then -- 130
		return "A" -- 130
	end -- 130
	if action == "crouch" then -- 131
		return "B" -- 131
	end -- 131
	if action == "cover" then -- 132
		return "LT / LB" -- 132
	end -- 132
	if action == "fire" then -- 133
		return "RT / X" -- 133
	end -- 133
	if action == "aim" then -- 134
		return "RT / X" -- 134
	end -- 134
	if action == "pause" then -- 135
		return "START" -- 135
	end -- 135
	if action == "retry" then -- 136
		return "长按 BACK" -- 136
	end -- 136
	if action == "confirm" then -- 137
		return confirmBtn -- 137
	end -- 137
	if action == "back" then -- 138
		return backBtn -- 138
	end -- 138
	return "L3" -- 139
end -- 113
local function adaptWorldKeyTagHandheld(rawKeyTag, mode) -- 142
	if mode == "touch" then -- 143
		if rawKeyTag == "E" then -- 144
			return "轻触" -- 144
		end -- 144
		if rawKeyTag == "按住 E" then -- 145
			return "长按交互" -- 145
		end -- 145
		if rawKeyTag == "松开再按住 E" then -- 146
			return "松开再长按" -- 146
		end -- 146
		if rawKeyTag == "按住 E + D" or rawKeyTag == "E 握柄 + D" then -- 147
			return "点推车+摇杆" -- 147
		end -- 147
		if rawKeyTag == "F" or rawKeyTag == "左键" then -- 148
			return "开火" -- 148
		end -- 148
		if rawKeyTag == "按住 F" then -- 149
			return "拖投瓶" -- 149
		end -- 149
		if rawKeyTag == "松开 F" then -- 150
			return "松手投" -- 150
		end -- 150
		if rawKeyTag == "按住 Ctrl" then -- 151
			return "点蹲伏" -- 151
		end -- 151
		if rawKeyTag == "按住 Shift" then -- 152
			return "点掩体" -- 152
		end -- 152
		if rawKeyTag == "连线" then -- 153
			return "一笔划连" -- 153
		end -- 153
		return rawKeyTag -- 154
	end -- 154
	if rawKeyTag == "E" then -- 156
		return "Y" -- 156
	end -- 156
	if rawKeyTag == "按住 E" then -- 157
		return "按住 Y" -- 157
	end -- 157
	if rawKeyTag == "松开再按住 E" then -- 158
		return "松开再按 Y" -- 158
	end -- 158
	if rawKeyTag == "按住 E + D" then -- 159
		return "按住 Y + 右" -- 159
	end -- 159
	if rawKeyTag == "E 握柄 + D" then -- 160
		return "Y 握柄 + 右" -- 160
	end -- 160
	if rawKeyTag == "F" or rawKeyTag == "左键" then -- 161
		return "RT / X" -- 161
	end -- 161
	if rawKeyTag == "按住 F" then -- 162
		return "按住 RT" -- 162
	end -- 162
	if rawKeyTag == "松开 F" then -- 163
		return "松开 RT" -- 163
	end -- 163
	if rawKeyTag == "按住 Ctrl" then -- 164
		return "按住 B" -- 164
	end -- 164
	if rawKeyTag == "按住 Shift" then -- 165
		return "按住 LT" -- 165
	end -- 165
	if rawKeyTag == "连线" then -- 166
		return "摇杆/触屏连线" -- 166
	end -- 166
	if rawKeyTag == "→" then -- 167
		return "右推摇杆" -- 167
	end -- 167
	return rawKeyTag -- 168
end -- 142
local function adaptHintSentenceHandheld(text, mode, layout) -- 171
	if text == "" then -- 172
		return text -- 172
	end -- 172
	if mode == "touch" then -- 173
		return table.concat( -- 174
			__TS__StringSplit( -- 174
				table.concat( -- 174
					__TS__StringSplit( -- 174
						table.concat( -- 174
							__TS__StringSplit( -- 174
								table.concat( -- 174
									__TS__StringSplit( -- 174
										table.concat( -- 174
											__TS__StringSplit( -- 174
												table.concat( -- 174
													__TS__StringSplit( -- 174
														table.concat( -- 174
															__TS__StringSplit( -- 174
																table.concat( -- 174
																	__TS__StringSplit( -- 174
																		table.concat( -- 174
																			__TS__StringSplit( -- 174
																				table.concat( -- 174
																					__TS__StringSplit( -- 174
																						table.concat( -- 174
																							__TS__StringSplit( -- 174
																								table.concat( -- 174
																									__TS__StringSplit( -- 174
																										table.concat( -- 174
																											__TS__StringSplit( -- 174
																												table.concat( -- 174
																													__TS__StringSplit( -- 174
																														table.concat( -- 174
																															__TS__StringSplit( -- 174
																																table.concat( -- 174
																																	__TS__StringSplit( -- 174
																																		table.concat( -- 174
																																			__TS__StringSplit( -- 174
																																				table.concat( -- 174
																																					__TS__StringSplit( -- 174
																																						table.concat( -- 174
																																							__TS__StringSplit( -- 174
																																								table.concat( -- 174
																																									__TS__StringSplit( -- 174
																																										table.concat( -- 174
																																											__TS__StringSplit( -- 174
																																												table.concat( -- 174
																																													__TS__StringSplit( -- 174
																																														table.concat( -- 174
																																															__TS__StringSplit( -- 174
																																																table.concat( -- 174
																																																	__TS__StringSplit( -- 174
																																																		table.concat( -- 174
																																																			__TS__StringSplit( -- 174
																																																				table.concat( -- 174
																																																					__TS__StringSplit( -- 174
																																																						table.concat( -- 174
																																																							__TS__StringSplit( -- 174
																																																								table.concat( -- 174
																																																									__TS__StringSplit( -- 174
																																																										table.concat( -- 174
																																																											__TS__StringSplit( -- 174
																																																												table.concat( -- 174
																																																													__TS__StringSplit( -- 174
																																																														table.concat( -- 174
																																																															__TS__StringSplit(text, "按住 [E]+[D]"), -- 174
																																																															"点按推/拉车并推摇杆" -- 175
																																																														), -- 175
																																																														"[E]+[D]" -- 176
																																																													), -- 176
																																																													"推/拉车并推摇杆" -- 176
																																																												), -- 176
																																																												"速按 [CTRL]" -- 177
																																																											), -- 177
																																																											"点按「蹲伏」" -- 177
																																																										), -- 177
																																																										"按住 [CTRL]" -- 178
																																																									), -- 178
																																																									"点按「蹲伏」" -- 178
																																																								), -- 178
																																																								"按 [CTRL]" -- 179
																																																							), -- 179
																																																							"点按「蹲伏」" -- 179
																																																						), -- 179
																																																						"[CTRL]" -- 180
																																																					), -- 180
																																																					"「蹲伏」" -- 180
																																																				), -- 180
																																																				"按住 [SHIFT]" -- 181
																																																			), -- 181
																																																			"点按「轻步/掩体」" -- 181
																																																		), -- 181
																																																		"[SHIFT]" -- 182
																																																	), -- 182
																																																	"「轻步/掩体」" -- 182
																																																), -- 182
																																																"按住 [F]" -- 183
																																															), -- 183
																																															"按住「投瓶」拖拽" -- 183
																																														), -- 183
																																														"[F]" -- 184
																																													), -- 184
																																													"「投瓶」" -- 184
																																												), -- 184
																																												"按住 E" -- 185
																																											), -- 185
																																											"长按「交互」" -- 185
																																										), -- 185
																																										"按 [E]" -- 186
																																									), -- 186
																																									"点按「交互」" -- 186
																																								), -- 186
																																								"[E]" -- 187
																																							), -- 187
																																							"「交互」" -- 187
																																						), -- 187
																																						"方向键" -- 188
																																					), -- 188
																																					"左下摇杆" -- 188
																																				), -- 188
																																				"按 [ESC]" -- 189
																																			), -- 189
																																			"轻触右上「暂歇」" -- 189
																																		), -- 189
																																		"[ESC]" -- 190
																																	), -- 190
																																	"右上「暂歇」" -- 190
																																), -- 190
																																"按 [SPACE]" -- 191
																															), -- 191
																															"点按「翻滚/跳跃」" -- 191
																														), -- 191
																														"[SPACE]" -- 192
																													), -- 192
																													"「翻滚/跳跃」" -- 192
																												), -- 192
																												"按 [R]" -- 193
																											), -- 193
																											"在暂歇菜单重试" -- 193
																										), -- 193
																										"[A/D]" -- 194
																									), -- 194
																									"左下摇杆" -- 194
																								), -- 194
																								"[W/S]" -- 195
																							), -- 195
																							"摇杆上下" -- 195
																						), -- 195
																						"[W]" -- 196
																					), -- 196
																					"摇杆向上" -- 196
																				), -- 196
																				"[S]" -- 197
																			), -- 197
																			"摇杆向下" -- 197
																		), -- 197
																		"鼠标瞄准，左键发射火铳" -- 198
																	), -- 198
																	"点屏或拖「开火」发射火铳" -- 198
																), -- 198
																"左键先手击倒" -- 199
															), -- 199
															"点屏或「开火」先手击倒" -- 199
														), -- 199
														"左键发射火铳" -- 200
													), -- 200
													"点屏或「开火」发射火铳" -- 200
												), -- 200
												"左键发铳" -- 201
											), -- 201
											"点屏或「开火」发铳" -- 201
										), -- 201
										"左键" -- 202
									), -- 202
									"点屏或「开火」" -- 202
								), -- 202
								"鼠标" -- 203
							), -- 203
							"触屏" -- 203
						), -- 203
						"按 E 再次启程" -- 204
					), -- 204
					"轻触屏幕再次启程" -- 204
				), -- 204
				"Esc 暂歇" -- 205
			), -- 205
			"轻触右上暂歇" -- 205
		) -- 205
	end -- 205
	local backBtn = layout == "nintendo" and "A" or "B" -- 207
	return table.concat( -- 208
		__TS__StringSplit( -- 208
			table.concat( -- 208
				__TS__StringSplit( -- 208
					table.concat( -- 208
						__TS__StringSplit( -- 208
							table.concat( -- 208
								__TS__StringSplit( -- 208
									table.concat( -- 208
										__TS__StringSplit( -- 208
											table.concat( -- 208
												__TS__StringSplit( -- 208
													table.concat( -- 208
														__TS__StringSplit( -- 208
															table.concat( -- 208
																__TS__StringSplit( -- 208
																	table.concat( -- 208
																		__TS__StringSplit( -- 208
																			table.concat( -- 208
																				__TS__StringSplit( -- 208
																					table.concat( -- 208
																						__TS__StringSplit( -- 208
																							table.concat( -- 208
																								__TS__StringSplit( -- 208
																									table.concat( -- 208
																										__TS__StringSplit( -- 208
																											table.concat( -- 208
																												__TS__StringSplit( -- 208
																													table.concat( -- 208
																														__TS__StringSplit( -- 208
																															table.concat( -- 208
																																__TS__StringSplit( -- 208
																																	table.concat( -- 208
																																		__TS__StringSplit( -- 208
																																			table.concat( -- 208
																																				__TS__StringSplit( -- 208
																																					table.concat( -- 208
																																						__TS__StringSplit( -- 208
																																							table.concat( -- 208
																																								__TS__StringSplit( -- 208
																																									table.concat( -- 208
																																										__TS__StringSplit(text, "[SHIFT]"), -- 208
																																										"[LT/LB]" -- 209
																																									), -- 209
																																									"[CTRL]" -- 210
																																								), -- 210
																																								"[B]" -- 210
																																							), -- 210
																																							"[E]+[D]" -- 211
																																						), -- 211
																																						"[Y]+右推" -- 211
																																					), -- 211
																																					"[E]" -- 212
																																				), -- 212
																																				"[Y]" -- 212
																																			), -- 212
																																			"[F]" -- 213
																																		), -- 213
																																		"[RT/X]" -- 213
																																	), -- 213
																																	"[SPACE]" -- 214
																																), -- 214
																																"[A]" -- 214
																															), -- 214
																															"[W/S]" -- 215
																														), -- 215
																														"左摇杆上下" -- 215
																													), -- 215
																													"[A/D]" -- 216
																												), -- 216
																												"左摇杆左右" -- 216
																											), -- 216
																											"[W]" -- 217
																										), -- 217
																										"左摇杆向上" -- 217
																									), -- 217
																									"[S]" -- 218
																								), -- 218
																								"左摇杆向下" -- 218
																							), -- 218
																							"[ESC]" -- 219
																						), -- 219
																						"[START]" -- 219
																					), -- 219
																					"[R]" -- 220
																				), -- 220
																				"长按 [BACK]" -- 220
																			), -- 220
																			"鼠标瞄准，左键发射火铳" -- 221
																		), -- 221
																		"右摇杆瞄准，按 [RT/X] 发射火铳" -- 221
																	), -- 221
																	"左键先手击倒" -- 222
																), -- 222
																"按 [RT/X] 先手击倒" -- 222
															), -- 222
															"左键发射火铳" -- 223
														), -- 223
														"按 [RT/X] 发射火铳" -- 223
													), -- 223
													"左键发铳" -- 224
												), -- 224
												"按 [RT/X] 发铳" -- 224
											), -- 224
											"按 E 再次启程" -- 225
										), -- 225
										"按 Y 再次启程" -- 225
									), -- 225
									"按住 E" -- 226
								), -- 226
								"按住 Y" -- 226
							), -- 226
							"方向键" -- 227
						), -- 227
						"左摇杆" -- 227
					), -- 227
					"Esc 暂歇" -- 228
				), -- 228
				"START 暂歇" -- 228
			), -- 228
			"返回" -- 229
		), -- 229
		("按 " .. backBtn) .. " 返回" or "," -- 229
	) -- 229
end -- 171
local HandheldInputDriver = __TS__Class() -- 232
HandheldInputDriver.name = "HandheldInputDriver" -- 232
function HandheldInputDriver.prototype.____constructor(self, settings) -- 239
	self.defaultMode = "gamepad" -- 233
	self.settings = settings -- 240
	if settings.modePref == "kbm" then -- 241
		settings.modePref = "auto" -- 242
	end -- 242
	self.touchRouter = __TS__New(TouchRouter, settings, {enableMouseCompat = false, enablePortrait = false}) -- 244
	self.gamepadRouter = __TS__New(GamepadRouter, settings) -- 248
end -- 239
function HandheldInputDriver.prototype.attach(self, parent, _hooks) -- 251
	self.touchRouter:attach(parent) -- 252
	self.gamepadRouter:attach(parent) -- 253
	if self.touchControls == nil then -- 254
		self.touchControls = __TS__New(TouchControls, parent) -- 255
	end -- 255
end -- 251
function HandheldInputDriver.prototype.syncFrame(self, ctx) -- 259
	local vp = ctx.viewport -- 260
	local p = ctx.play -- 261
	local isPlayMode = ctx.mode == 1 and ctx.screen == "play" and p ~= nil -- 262
	local isTrialMode = ctx.mode == 2 and p ~= nil -- 263
	local gameplayActive = isPlayMode or isTrialMode -- 264
	local ____opt_0 = ctx.run -- 266
	local trial = ____opt_0 and ____opt_0.trial -- 266
	local ____temp_5 = isTrialMode and trial ~= nil -- 267
	if ____temp_5 then -- 267
		local ____trial_lost_4 = trial.lost -- 267
		if not ____trial_lost_4 then -- 267
			local ____opt_2 = ctx.run -- 267
			____trial_lost_4 = (____opt_2 and ____opt_2.finished) == true -- 267
		end -- 267
		____temp_5 = ____trial_lost_4 -- 267
	end -- 267
	local trialEnded = ____temp_5 -- 267
	local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 268
	local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) or isTrialMode and p ~= nil and (p.paused or trialEnded) -- 269
	local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 272
	local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 273
	local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and #p:getStoryTalentOffers() or (trialHasOffers and trial ~= nil and #trial.offers or 0) -- 274
	local ____temp_6 -- 277
	if isPlayMode and p ~= nil then -- 277
		____temp_6 = isCutsceneBlockingPlay(p) -- 277
	else -- 277
		____temp_6 = false -- 277
	end -- 277
	local cutsceneBlocking = ____temp_6 -- 277
	local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 278
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 280
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and not trialHasOffers and p.escort.state ~= "calming" -- 281
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 283
	local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 285
	local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 288
	local enemyTargets = canShoot and self.settings.aimAssist and p ~= nil and (isPlayMode and ctx.cam ~= nil and collectPlayAimTargets(p, ctx.cam, vp.stageW, vp.stageH) or collectTrialAimTargets(p, vp.stageW, vp.stageH)) or ({}) -- 291
	if self.touchControls ~= nil then -- 297
		local pref = self.settings.modePref -- 298
		self.touchControls:syncContext({ -- 299
			viewport = vp, -- 300
			mode = ctx.mode, -- 301
			screen = ctx.screen, -- 302
			play = p, -- 303
			run = ctx.run, -- 304
			cam = ctx.cam, -- 305
			router = self.touchRouter, -- 306
			overlayActive = self:shouldShowTouchControls(ctx.input, vp), -- 307
			allowAutoGameplayTouch = pref == "auto" or pref == "touch", -- 308
			allowMouseOnOverlay = false, -- 309
			showWebTopPills = false, -- 310
			canToggleFullscreen = false, -- 311
			assistHintsEnabled = ctx.assistHintsEnabled, -- 312
			isMuted = ctx.isMuted, -- 313
			isFullscreen = false, -- 314
			storyTalentBoxes = ctx.storyTalentBoxes, -- 315
			enemyTargets = enemyTargets, -- 316
			dt = ctx.dt -- 317
		}) -- 317
	end -- 317
	local playerScreenX = vp.stageW * 0.5 -- 321
	local playerScreenY = vp.stageH * 0.38 -- 322
	if p ~= nil then -- 323
		if isPlayMode and ctx.cam ~= nil then -- 324
			playerScreenX = ctx.cam:sx(p.player.x + p.player.facing * 8) -- 325
			playerScreenY = ctx.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 326
		else -- 326
			local vz = p.view.zoom > 0 and p.view.zoom or 1 -- 328
			playerScreenX = vp.stageW * 0.5 + (p.player.x + p.player.facing * 8 - p.cam.x) * vz -- 329
			playerScreenY = vp.stageH * 0.5 + (p.player.y + p.player.h * 0.72 + p.player.depth * DEPTH_Y_SCALE - p.cam.y) * vz -- 330
		end -- 330
	end -- 330
	local gpCtx = { -- 334
		stageW = vp.stageW, -- 335
		stageH = vp.stageH, -- 336
		uiScale = vp.uiScale, -- 337
		modal = modal, -- 338
		gameplayActive = gameplayActive, -- 339
		reloadActive = reloadActive, -- 340
		craftActive = craftActive, -- 341
		talentOfferCount = talentOfferCount, -- 342
		childMode = p ~= nil and p.childMode, -- 343
		allowDepth = allowDepth, -- 344
		canShoot = canShoot, -- 345
		canBottleAim = canBottleAim, -- 346
		playerRolling = p ~= nil and p.player.rollT > 0, -- 347
		inLowArch = inLowArch, -- 348
		inTowerEnd = inTowerEnd, -- 349
		playerFacing = p ~= nil and p.player.facing or 1, -- 350
		playerScreenX = playerScreenX, -- 351
		playerScreenY = playerScreenY, -- 352
		enemyTargets = enemyTargets -- 353
	} -- 353
	self.gamepadRouter:setFrameContext(gpCtx, ctx.dt) -- 355
end -- 259
function HandheldInputDriver.prototype.renderOverlay(self) -- 358
	local ____opt_7 = self.touchControls -- 359
	if ____opt_7 ~= nil then -- 359
		____opt_7:render(self.touchRouter) -- 359
	end -- 359
end -- 358
function HandheldInputDriver.prototype.clearTransient(self, keepTouchToggles) -- 362
	self.touchRouter:releaseAll(keepTouchToggles) -- 363
	self.gamepadRouter:clearTransient() -- 364
end -- 362
function HandheldInputDriver.prototype.vibrate(self, seconds) -- 367
	self.touchRouter:vibrate(seconds) -- 368
end -- 367
function HandheldInputDriver.prototype.onInputModeChanged(self, mode) -- 371
	if mode ~= "touch" then -- 372
		self.touchRouter:releaseAll(false) -- 373
	end -- 373
end -- 371
function HandheldInputDriver.prototype.shouldShowTouchControls(self, input, _vp) -- 377
	if self.settings.modePref == "touch" then -- 378
		return true -- 378
	end -- 378
	if self.settings.modePref == "gamepad" then -- 379
		return false -- 379
	end -- 379
	return input.inputMode == "touch" -- 380
end -- 377
function HandheldInputDriver.prototype.getTouchRouter(self) -- 383
	return self.touchRouter -- 384
end -- 383
function HandheldInputDriver.prototype.getGamepadRouter(self) -- 387
	return self.gamepadRouter -- 388
end -- 387
function HandheldInputDriver.prototype.getTouchControls(self) -- 391
	return self.touchControls -- 392
end -- 391
function HandheldInputDriver.prototype.injectTouch(self, phase, id, x, y, fromMouse) -- 395
	self.touchRouter:injectTouch( -- 396
		phase, -- 396
		id, -- 396
		x, -- 396
		y, -- 396
		fromMouse == true -- 396
	) -- 396
end -- 395
function HandheldInputDriver.prototype.setGamepadSim(self, state) -- 399
	self.gamepadRouter:setSimulatedState(state) -- 400
end -- 399
function HandheldInputDriver.prototype.pollInto(self, input) -- 403
	input.gamepadLayout = self.settings.gamepadLayout -- 404
	local touch = self.touchRouter:consumeSnapshot() -- 405
	local gp = self.gamepadRouter:consumeSnapshot() -- 406
	if gp.hadGamepadInput or touch.hadRealTouch then -- 408
		input.userInteracted = true -- 409
	end -- 409
	local pref = self.settings.modePref -- 413
	if pref == "gamepad" or pref == "touch" then -- 414
		input:setInputMode(pref) -- 415
	elseif gp.hadGamepadInput then -- 416
		input:setInputMode("gamepad") -- 417
	elseif touch.hadGameplayTouch then -- 418
		input:setInputMode("touch") -- 419
	elseif input.inputMode == "kbm" then -- 420
		input:setInputMode("gamepad") -- 421
	end -- 421
	input.moveX = gp.moveX ~= 0 and gp.moveX or touch.moveX -- 424
	input.moveY = gp.moveY ~= 0 and gp.moveY or touch.moveY -- 425
	input:applyKeyHeld( -- 426
		gp.jumpHeld or touch.jumpHeld, -- 427
		gp.crouchHeld or touch.crouchHeld, -- 428
		gp.coverHeld or touch.coverHeld, -- 429
		gp.interactHeld or touch.interactHeld, -- 430
		gp.aimHeld or touch.aimHeld, -- 431
		gp.fireHeld or touch.fireHeld, -- 432
		gp.flareHeld, -- 433
		false, -- 434
		false, -- 435
		false, -- 436
		false -- 437
	) -- 437
	input:resetFrameSignals() -- 440
	if gp.jumpPressed then -- 442
		input.jump.pressed = true -- 442
	end -- 442
	if gp.crouchPressed then -- 443
		input.crouch.pressed = true -- 443
	end -- 443
	if gp.interactPressed then -- 444
		input.interact.pressed = true -- 444
	end -- 444
	if gp.aimPressed then -- 445
		input.aim.pressed = true -- 445
	end -- 445
	if gp.firePressed then -- 446
		input.fire.pressed = true -- 446
	end -- 446
	if gp.flarePressed then -- 447
		input.flare.pressed = true -- 447
	end -- 447
	if gp.pausePressed then -- 448
		input.pause.pressed = true -- 448
	end -- 448
	if gp.retryPressed then -- 449
		input.retry.pressed = true -- 449
	end -- 449
	if gp.artifactPressed then -- 450
		input.artifactTogglePressed = true -- 450
	end -- 450
	if gp.anyButtonPressed then -- 451
		input.splashSkipPressed = true -- 451
	end -- 451
	if gp.bottleCanceled then -- 452
		input.bottleCanceled = true -- 453
		input.aim.held = false -- 454
		input.aim.pressed = false -- 455
		input.aim.released = false -- 456
	end -- 456
	input.navUp = gp.navUp -- 458
	input.navDown = gp.navDown -- 459
	input.navLeft = gp.navLeft -- 460
	input.navRight = gp.navRight -- 461
	input.navConfirm = gp.navConfirm -- 462
	input.navBack = gp.navBack -- 463
	input.navPrevTab = gp.navPrevTab -- 464
	input.navNextTab = gp.navNextTab -- 465
	input.reloadDirCol = gp.reloadDirCol -- 466
	input.reloadDirRow = gp.reloadDirRow -- 467
	input.reloadStepEdge = gp.reloadStepEdge -- 468
	input.reloadAutoStep = gp.reloadAutoStep -- 469
	input.reloadConfirm = gp.reloadConfirm -- 470
	input.reloadReset = gp.reloadReset -- 471
	input.talentDelta = gp.talentDelta -- 472
	input.talentConfirm = gp.talentConfirm -- 473
	input.retryHoldProgress = gp.retryHoldProgress -- 474
	if touch.jumpPressed then -- 476
		input.jump.pressed = true -- 476
	end -- 476
	if touch.interactPressed then -- 477
		input.interact.pressed = true -- 477
	end -- 477
	if touch.firePressed then -- 478
		input.fire.pressed = true -- 478
	end -- 478
	if touch.pausePressed then -- 479
		input.pause.pressed = true -- 479
	end -- 479
	if touch.retryPressed then -- 480
		input.retry.pressed = true -- 480
	end -- 480
	if touch.artifactPressed then -- 481
		input.artifactTogglePressed = true -- 481
	end -- 481
	if touch.mutePressed then -- 482
		input.muteTogglePressed = true -- 482
	end -- 482
	if touch.anyTapBegan then -- 483
		input.splashSkipPressed = true -- 483
	end -- 483
	if touch.zoneTap ~= "" then -- 484
		input.touchZoneTap = touch.zoneTap -- 484
	end -- 484
	if touch.navUp then -- 485
		input.navUp = true -- 485
	end -- 485
	if touch.navDown then -- 486
		input.navDown = true -- 486
	end -- 486
	if touch.navLeft then -- 487
		input.navLeft = true -- 487
	end -- 487
	if touch.navRight then -- 488
		input.navRight = true -- 488
	end -- 488
	if touch.navConfirm then -- 489
		input.navConfirm = true -- 489
	end -- 489
	if touch.navBack then -- 490
		input.navBack = true -- 490
	end -- 490
	if touch.bottleCanceled then -- 491
		input.bottleCanceled = true -- 492
		input.aim.held = false -- 493
		input.aim.pressed = false -- 494
		input.aim.released = false -- 495
	end -- 495
	input.craftConfirm = input.navConfirm -- 498
	input.craftCancel = input.navBack -- 499
	input.frameInteractPressed = input.interact.pressed -- 500
	if touch.uiHeld or touch.uiPressed or touch.uiReleased or touch.uiInside then -- 502
		input.uiX = touch.uiX -- 503
		input.uiY = touch.uiY -- 504
		input.uiDx = touch.uiDx -- 505
		input.uiDy = touch.uiDy -- 506
		input.uiInside = touch.uiInside -- 507
		input.uiHeld = touch.uiHeld -- 508
		input.uiPressed = touch.uiPressed -- 509
		input.uiReleased = touch.uiReleased -- 510
		input.uiRightPressed = false -- 511
		if touch.uiHeld or touch.uiPressed then -- 512
			input.mdx = touch.uiDx -- 513
			input.mdy = touch.uiDy -- 514
			input.mx = touch.uiX -- 515
			input.my = touch.uiY -- 516
			input.inside = true -- 517
		elseif touch.hasAim then -- 518
			input.mdx = touch.aimX - input.mx -- 519
			input.mdy = touch.aimY - input.my -- 520
			input.mx = touch.aimX -- 521
			input.my = touch.aimY -- 522
			input.inside = true -- 523
		else -- 523
			input.mdx = 0 -- 525
			input.mdy = 0 -- 526
			input.inside = touch.uiInside -- 527
		end -- 527
		return -- 529
	end -- 529
	if input.inputMode == "gamepad" then -- 532
		if gp.hasAim then -- 533
			input.mdx = gp.aimX - input.mx -- 534
			input.mdy = gp.aimY - input.my -- 535
			input.mx = gp.aimX -- 536
			input.my = gp.aimY -- 537
			input.inside = true -- 538
		else -- 538
			input.mdx = 0 -- 540
			input.mdy = 0 -- 541
			input.inside = false -- 542
		end -- 542
		input.uiX = input.mx -- 544
		input.uiY = input.my -- 545
		input.uiDx = 0 -- 546
		input.uiDy = 0 -- 547
		input.uiInside = false -- 548
		input.uiHeld = false -- 549
		input.uiPressed = false -- 550
		input.uiReleased = false -- 551
		input.uiRightPressed = false -- 552
		return -- 553
	end -- 553
	if touch.hasAim then -- 556
		input.mdx = touch.aimX - input.mx -- 557
		input.mdy = touch.aimY - input.my -- 558
		input.mx = touch.aimX -- 559
		input.my = touch.aimY -- 560
		input.inside = true -- 561
	else -- 561
		input.mdx = 0 -- 563
		input.mdy = 0 -- 564
		input.inside = false -- 565
	end -- 565
	input.uiDx = 0 -- 567
	input.uiDy = 0 -- 568
	input.uiInside = false -- 569
	input.uiHeld = false -- 570
	input.uiPressed = false -- 571
	input.uiReleased = false -- 572
	input.uiRightPressed = false -- 573
end -- 403
____exports.TARGET = { -- 577
	id = "handheld", -- 578
	supportsKbm = false, -- 579
	supportsTouch = true, -- 580
	supportsGamepad = true, -- 581
	supportsPortrait = false, -- 582
	defaultInputMode = "gamepad", -- 583
	supportedModes = {"gamepad", "touch"}, -- 584
	modePrefOrder = HANDHELD_MODE_PREFS, -- 585
	controlsGuideTabs = {{mode = "gamepad", label = "手柄"}, {mode = "touch", label = "触屏"}}, -- 586
	getPlatformCaps = function(self) -- 591
		local standaloneApk = isStandaloneApk() -- 592
		local cfg = getReleaseConfig() -- 593
		return { -- 594
			kind = "android", -- 595
			target = "handheld", -- 596
			isDesktop = false, -- 597
			isMobile = true, -- 598
			isWeb = false, -- 599
			isStandaloneAndroidApk = standaloneApk, -- 600
			canToggleFullscreen = false, -- 601
			canQuit = standaloneApk, -- 602
			hasBackButton = true, -- 603
			supportsHaptics = type(App.vibrate) == "function", -- 604
			needsAudioUnlock = false, -- 605
			isRelease = cfg ~= nil and cfg.isRelease == true, -- 606
			defaultInputMode = "gamepad" -- 607
		} -- 607
	end, -- 591
	canToggleFullscreen = function(self) -- 611
		return false -- 612
	end, -- 611
	canQuitApp = function(self) -- 615
		return isStandaloneApk() -- 616
	end, -- 615
	isReleaseMode = function(self) -- 619
		local cfg = getReleaseConfig() -- 620
		return cfg ~= nil and cfg.isRelease == true -- 621
	end, -- 619
	computeStageViewport = function(self, fullW, fullH) -- 624
		return computeLandscapeSafeViewport(fullW, fullH) -- 625
	end, -- 624
	triggerHaptics = function(self, seconds, enabled) -- 628
		triggerMobileHaptics(seconds, enabled) -- 629
	end, -- 628
	keyTagFor = function(self, action, mode, layout) -- 632
		return keyTagHandheld(action, mode, layout) -- 633
	end, -- 632
	adaptWorldKeyTag = function(self, rawKeyTag, mode, _layout) -- 636
		return adaptWorldKeyTagHandheld(rawKeyTag, mode) -- 637
	end, -- 636
	adaptHintSentence = function(self, text, mode, layout) -- 640
		return adaptHintSentenceHandheld(text, mode, layout) -- 641
	end, -- 640
	controlsGuideRows = function(self, tab) -- 644
		return tab == "touch" and GUIDE_TOUCH or GUIDE_GAMEPAD -- 645
	end, -- 644
	splashSkipHint = function(self, mode, layout) -- 648
		if mode == "touch" then -- 649
			return "轻触跳过" -- 649
		end -- 649
		return keyTagHandheld("confirm", "gamepad", layout) .. " / START  跳过" -- 650
	end, -- 648
	titleFooterHint = function(self, mode, layout) -- 653
		if mode == "touch" then -- 654
			return isStandaloneApk() and "轻触择项启程   ·   双击返回键退出" or "轻触择项启程   ·   支持手柄与触屏" -- 655
		end -- 655
		return ("左摇杆 / 十字键择项   ·   " .. keyTagHandheld("confirm", "gamepad", layout)) .. " 或点选启程" -- 659
	end, -- 653
	chapterFooterHint = function(self, mode, confirmTag) -- 662
		if mode == "touch" then -- 663
			return "轻触驿站预览   ·   再点或轻触入此卷章" -- 663
		end -- 663
		return ("摇杆/十字键选择   ·   " .. confirmTag) .. " 或点选进入" -- 664
	end, -- 662
	pauseFooterHint = function(self, mode, layout) -- 667
		if mode == "touch" then -- 668
			return "轻触确认   ·   点「继续游戏」续行" -- 668
		end -- 668
		return ((keyTagHandheld("back", "gamepad", layout) .. " / START 续行   ·   ") .. keyTagHandheld("confirm", "gamepad", layout)) .. " 确认" -- 669
	end, -- 667
	settingsFooterHint = function(self, mode, layout) -- 672
		if mode == "touch" then -- 673
			return "轻触任意条目切换   ·   设置自动保存" -- 673
		end -- 673
		return ((("左右或 " .. keyTagHandheld("confirm", "gamepad", layout)) .. " 切换   ·   ") .. keyTagHandheld("back", "gamepad", layout)) .. " 返回暂停" -- 674
	end, -- 672
	controlsFooterRightHint = function(self, mode) -- 677
		if mode == "touch" then -- 678
			return "轻触右上页签切图 · 暂歇菜单可调操控设置" -- 678
		end -- 678
		return "LB / RB 或左右切换键位图" -- 679
	end, -- 677
	epilogueFooterHint = function(self, mode, layout) -- 682
		if mode == "touch" then -- 683
			return "轻触任一入口继续" -- 683
		end -- 683
		return ((keyTagHandheld("confirm", "gamepad", layout) .. " 确认   ·   ") .. keyTagHandheld("back", "gamepad", layout)) .. " 返回标题" -- 684
	end, -- 682
	trialSubHint = function(self, mode, ended, seed) -- 687
		if mode == "touch" then -- 688
			return ("种子 " .. tostring(seed)) .. (ended and " · 点下方按钮再开或返回标题" or " · 点下方按钮继续/重开/返回标题") -- 689
		end -- 689
		return ("种子 " .. tostring(seed)) .. (ended and " · A 再开一局 · START 返回标题" or " · START 继续 · 长按BACK 重开 · Y 返回标题") -- 691
	end, -- 687
	settingsRows = function(self) -- 694
		return HANDHELD_SETTINGS_ROWS -- 695
	end, -- 694
	settingsPauseLabel = function(self, settings) -- 698
		local pref = settings.modePref == "kbm" and "auto" or settings.modePref -- 699
		return "操控设置 · " .. modePrefLabelOf(pref) -- 700
	end, -- 698
	settingsHeaderTitle = function(self) -- 703
		return "操控与声音" -- 704
	end, -- 703
	settingsHeaderSummary = function(self, activeMode) -- 707
		return ("当前模式：" .. inputModeLabelOf(activeMode)) .. " · 操控与四通道音量实时生效" -- 708
	end, -- 707
	settingsValueText = function(self, rowId, settings, activeMode) -- 711
		if rowId == "modePref" then -- 712
			local pref = settings.modePref == "kbm" and "auto" or settings.modePref -- 713
			return pref == "auto" and ("自动切换（" .. inputModeLabelOf(activeMode)) .. "）" or "锁定 · " .. modePrefLabelOf(pref) -- 714
		end -- 714
		if rowId == "aimAssist" then -- 718
			return settings.aimAssist and "开（触屏与手柄共用）" or "关" -- 718
		end -- 718
		if rowId == "gpLayout" then -- 719
			return layoutLabelOf(settings.gamepadLayout) -- 719
		end -- 719
		if rowId == "crouchMode" then -- 720
			return settings.crouchToggle and "点按切换" or "持续按住" -- 720
		end -- 720
		if rowId == "touchOpacity" then -- 721
			return opacityLabelOf(settings.touchOpacity) -- 721
		end -- 721
		if rowId == "touchScale" then -- 722
			return scaleLabelOf(settings.touchScale) -- 722
		end -- 722
		if rowId == "haptics" then -- 723
			return settings.haptics and "开" or "关" -- 723
		end -- 723
		return volumeSettingText(rowId, settings) -- 724
	end, -- 711
	applySettingsDelta = function(self, rowId, delta, settings, input) -- 727
		if rowId == "back" then -- 728
			return "back" -- 728
		end -- 728
		if rowId == "modePref" then -- 729
			input:cycleModePref(delta) -- 730
			return "control" -- 731
		end -- 731
		if rowId == "aimAssist" then -- 733
			settings.aimAssist = not settings.aimAssist -- 734
			saveControlSettings(settings) -- 735
			return "control" -- 736
		end -- 736
		if rowId == "gpLayout" then -- 738
			settings.gamepadLayout = settings.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 739
			input.gamepadLayout = settings.gamepadLayout -- 740
			saveControlSettings(settings) -- 741
			return "control" -- 742
		end -- 742
		if rowId == "crouchMode" then -- 744
			settings.crouchToggle = not settings.crouchToggle -- 745
			saveControlSettings(settings) -- 746
			return "control" -- 747
		end -- 747
		if rowId == "touchOpacity" then -- 749
			settings.touchOpacity = nextStepValue(settings.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 750
			saveControlSettings(settings) -- 751
			return "control" -- 752
		end -- 752
		if rowId == "touchScale" then -- 754
			settings.touchScale = nextStepValue(settings.touchScale, TOUCH_SCALE_STEPS, delta) -- 755
			saveControlSettings(settings) -- 756
			return "control" -- 757
		end -- 757
		if rowId == "haptics" then -- 759
			settings.haptics = not settings.haptics -- 760
			saveControlSettings(settings) -- 761
			if settings.haptics then -- 762
				input:vibrate(0.018) -- 763
			end -- 763
			return "control" -- 765
		end -- 765
		if applyVolumeSetting(rowId, delta, settings) then -- 767
			return "audio" -- 767
		end -- 767
		return "none" -- 768
	end, -- 727
	createDriver = function(self, settings) -- 771
		return __TS__New(HandheldInputDriver, settings) -- 772
	end -- 771
} -- 771
return ____exports -- 771
