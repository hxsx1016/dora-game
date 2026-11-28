-- [ts]: index.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 12
local App = ____Dora.App -- 12
local ____aim_assist = require("Script.watch.input.aim_assist") -- 13
local collectAimTargets = ____aim_assist.collectAimTargets -- 13
local projectMuzzle = ____aim_assist.projectMuzzle -- 13
local ____gamepad_core = require("Script.watch.input.gamepad_core") -- 14
local GamepadRouter = ____gamepad_core.GamepadRouter -- 14
local ____touch_core = require("Script.watch.input.touch_core") -- 15
local TouchRouter = ____touch_core.TouchRouter -- 15
local ____touch_hud_landscape = require("Script.watch.input.touch_hud_landscape") -- 16
local TouchControls = ____touch_hud_landscape.TouchControls -- 16
local ____play_prompts = require("Script.watch.fe.ui.play_prompts") -- 17
local isCutsceneBlockingPlay = ____play_prompts.isCutsceneBlockingPlay -- 17
local ____platform_mobile = require("Script.watch.platform_mobile") -- 18
local computeLandscapeSafeViewport = ____platform_mobile.computeLandscapeSafeViewport -- 18
local triggerMobileHaptics = ____platform_mobile.triggerMobileHaptics -- 18
local ____controls_config = require("Script.watch.controls_config") -- 19
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
local getReleaseConfig = ____target_types.getReleaseConfig -- 47
local HANDHELD_MODE_PREFS = {"auto", "gamepad", "touch"} -- 50
local HANDHELD_SETTINGS_ROWS = { -- 52
	{id = "modePref", title = "操作模式"}, -- 53
	{id = "aimAssist", title = "瞄准磁吸"}, -- 54
	{id = "gpLayout", title = "手柄确认键"}, -- 55
	{id = "crouchMode", title = "手柄蹲伏方式"}, -- 56
	{id = "touchOpacity", title = "触控按键透度"}, -- 57
	{id = "touchScale", title = "触控按键大小"}, -- 58
	{id = "haptics", title = "触觉震动反馈"}, -- 59
	{id = "masterVol", title = "主音量"}, -- 60
	{id = "bgmVol", title = "音乐音量"}, -- 61
	{id = "sfxVol", title = "音效与环境"}, -- 62
	{id = "voiceVol", title = "人声音量"}, -- 63
	{id = "back", title = "返回暂歇菜单"} -- 64
} -- 64
local GUIDE_GAMEPAD = {subtitle = "手柄操作说明 · 掌机横屏", soldierRows = { -- 67
	{"左摇杆 / 十字键", "左右、前后纵深移动"}, -- 70
	{"右摇杆 + RT / X", "360° 瞄准与发射火铳（含轻磁吸）"}, -- 71
	{"按住 LT / LB", "贴靠柜台 / 街垒挡下铅丸"}, -- 72
	{"A 键", "平地翻滚 / 靠近矮柜翻越"}, -- 73
	{"Y / RB 键", "递物 / 轻敲安抚 / 按住推车"}, -- 74
	{"摇杆直推 / 触屏", "慢时连线换弹 · B 键清空重画"} -- 75
}, childRows = { -- 75
	{"左摇杆轻推", "内圈轻步慢走（LT/LB 亦可）"}, -- 78
	{"B 键", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 79
	{"A 键", "跳跃攀上石阶与矮台"}, -- 80
	{"Y / RB 键", "拾瓶 / 敲塔门 / 握柄拉车"}, -- 81
	{"RT/X 按住→松开", "右摇杆调落点投瓶 · B 取消"}, -- 82
	{"START / BACK", "暂歇 / 长按重试 · L3 切神器"} -- 83
}} -- 83
local GUIDE_TOUCH = {subtitle = "触屏操作说明 · 掌机横屏", soldierRows = { -- 87
	{"左水墨摇杆", "全向走位与里外道切线"}, -- 90
	{"点屏 / 开火钮", "直点射击或拖住开火钮 360° 精瞄"}, -- 91
	{"掩体开关", "轻点贴靠掩体，再点或翻滚离掩"}, -- 92
	{"翻滚 / 翻越", "平地翻滚，贴近矮柜自动翻越"}, -- 93
	{"交互 / 推车", "点推车自动锁握柄，长按牵手交物"}, -- 94
	{"换弹九宫格", "单指一笔滑连至右上，点重画清空"} -- 95
}, childRows = { -- 95
	{"摇杆内圈 / 轻步", "轻推内圈或点轻步压低脚步声"}, -- 98
	{"蹲伏开关", "点按蹲下钻桌穿拱，点跳顺滑起身"}, -- 99
	{"跳跃钮", "攀上石阶、红布车与矮台"}, -- 100
	{"投瓶拖瞄", "按住投瓶拖向砖地，拖回取消圈放弃"}, -- 101
	{"交互 / 拉车", "拾瓶、敲塔门、点拉车锁定握柄"}, -- 102
	{"右上暂歇", "顶栏随时暂歇，手柄与触屏可混用"} -- 103
}} -- 103
local function isStandaloneApk() -- 107
	local cfg = getReleaseConfig() -- 108
	return cfg ~= nil and cfg.platform == "Android" -- 109
end -- 107
local function keyTagHandheld(action, mode, layout) -- 112
	if mode == "touch" then -- 112
		if action == "interact" then -- 112
			return "点按" -- 114
		end -- 114
		if action == "jump" then -- 114
			return "跳/滚" -- 115
		end -- 115
		if action == "crouch" then -- 115
			return "蹲伏" -- 116
		end -- 116
		if action == "cover" then -- 116
			return "掩体" -- 117
		end -- 117
		if action == "fire" then -- 117
			return "开火" -- 118
		end -- 118
		if action == "aim" then -- 118
			return "拖投瓶" -- 119
		end -- 119
		if action == "pause" then -- 119
			return "暂歇" -- 120
		end -- 120
		if action == "retry" then -- 120
			return "重试" -- 121
		end -- 121
		if action == "confirm" then -- 121
			return "点选" -- 122
		end -- 122
		if action == "back" then -- 122
			return "返回" -- 123
		end -- 123
		return "穿梭" -- 124
	end -- 124
	local confirmBtn = layout == "nintendo" and "B" or "A" -- 126
	local backBtn = layout == "nintendo" and "A" or "B" -- 127
	if action == "interact" then -- 127
		return "Y / RB" -- 128
	end -- 128
	if action == "jump" then -- 128
		return "A" -- 129
	end -- 129
	if action == "crouch" then -- 129
		return "B" -- 130
	end -- 130
	if action == "cover" then -- 130
		return "LT / LB" -- 131
	end -- 131
	if action == "fire" then -- 131
		return "RT / X" -- 132
	end -- 132
	if action == "aim" then -- 132
		return "RT / X" -- 133
	end -- 133
	if action == "pause" then -- 133
		return "START" -- 134
	end -- 134
	if action == "retry" then -- 134
		return "长按 BACK" -- 135
	end -- 135
	if action == "confirm" then -- 135
		return confirmBtn -- 136
	end -- 136
	if action == "back" then -- 136
		return backBtn -- 137
	end -- 137
	return "L3" -- 138
end -- 112
local function adaptWorldKeyTagHandheld(rawKeyTag, mode) -- 141
	if mode == "touch" then -- 141
		if rawKeyTag == "E" then -- 141
			return "轻触" -- 143
		end -- 143
		if rawKeyTag == "按住 E" then -- 143
			return "长按交互" -- 144
		end -- 144
		if rawKeyTag == "松开再按住 E" then -- 144
			return "松开再长按" -- 145
		end -- 145
		if rawKeyTag == "按住 E + D" or rawKeyTag == "E 握柄 + D" then -- 145
			return "点推车+摇杆" -- 146
		end -- 146
		if rawKeyTag == "F" or rawKeyTag == "左键" then -- 146
			return "开火" -- 147
		end -- 147
		if rawKeyTag == "按住 F" then -- 147
			return "拖投瓶" -- 148
		end -- 148
		if rawKeyTag == "松开 F" then -- 148
			return "松手投" -- 149
		end -- 149
		if rawKeyTag == "按住 Ctrl" then -- 149
			return "点蹲伏" -- 150
		end -- 150
		if rawKeyTag == "按住 Shift" then -- 150
			return "点掩体" -- 151
		end -- 151
		if rawKeyTag == "连线" then -- 151
			return "一笔划连" -- 152
		end -- 152
		return rawKeyTag -- 153
	end -- 153
	if rawKeyTag == "E" then -- 153
		return "Y" -- 155
	end -- 155
	if rawKeyTag == "按住 E" then -- 155
		return "按住 Y" -- 156
	end -- 156
	if rawKeyTag == "松开再按住 E" then -- 156
		return "松开再按 Y" -- 157
	end -- 157
	if rawKeyTag == "按住 E + D" then -- 157
		return "按住 Y + 右" -- 158
	end -- 158
	if rawKeyTag == "E 握柄 + D" then -- 158
		return "Y 握柄 + 右" -- 159
	end -- 159
	if rawKeyTag == "F" or rawKeyTag == "左键" then -- 159
		return "RT / X" -- 160
	end -- 160
	if rawKeyTag == "按住 F" then -- 160
		return "按住 RT" -- 161
	end -- 161
	if rawKeyTag == "松开 F" then -- 161
		return "松开 RT" -- 162
	end -- 162
	if rawKeyTag == "按住 Ctrl" then -- 162
		return "按住 B" -- 163
	end -- 163
	if rawKeyTag == "按住 Shift" then -- 163
		return "按住 LT" -- 164
	end -- 164
	if rawKeyTag == "连线" then -- 164
		return "摇杆/触屏连线" -- 165
	end -- 165
	if rawKeyTag == "→" then -- 165
		return "右推摇杆" -- 166
	end -- 166
	return rawKeyTag -- 167
end -- 141
local function adaptHintSentenceHandheld(text, mode, layout) -- 170
	if text == "" then -- 170
		return text -- 171
	end -- 171
	if mode == "touch" then -- 171
		return table.concat( -- 173
			__TS__StringSplit( -- 173
				table.concat( -- 173
					__TS__StringSplit( -- 173
						table.concat( -- 173
							__TS__StringSplit( -- 173
								table.concat( -- 173
									__TS__StringSplit( -- 173
										table.concat( -- 173
											__TS__StringSplit( -- 173
												table.concat( -- 173
													__TS__StringSplit( -- 173
														table.concat( -- 173
															__TS__StringSplit( -- 173
																table.concat( -- 173
																	__TS__StringSplit( -- 173
																		table.concat( -- 173
																			__TS__StringSplit( -- 173
																				table.concat( -- 173
																					__TS__StringSplit( -- 173
																						table.concat( -- 173
																							__TS__StringSplit( -- 173
																								table.concat( -- 173
																									__TS__StringSplit( -- 173
																										table.concat( -- 173
																											__TS__StringSplit( -- 173
																												table.concat( -- 173
																													__TS__StringSplit( -- 173
																														table.concat( -- 173
																															__TS__StringSplit( -- 173
																																table.concat( -- 173
																																	__TS__StringSplit( -- 173
																																		table.concat( -- 173
																																			__TS__StringSplit( -- 173
																																				table.concat( -- 173
																																					__TS__StringSplit( -- 173
																																						table.concat( -- 173
																																							__TS__StringSplit( -- 173
																																								table.concat( -- 173
																																									__TS__StringSplit( -- 173
																																										table.concat( -- 173
																																											__TS__StringSplit( -- 173
																																												table.concat( -- 173
																																													__TS__StringSplit( -- 173
																																														table.concat( -- 173
																																															__TS__StringSplit( -- 173
																																																table.concat( -- 173
																																																	__TS__StringSplit( -- 173
																																																		table.concat( -- 173
																																																			__TS__StringSplit( -- 173
																																																				table.concat( -- 173
																																																					__TS__StringSplit( -- 173
																																																						table.concat( -- 173
																																																							__TS__StringSplit( -- 173
																																																								table.concat( -- 173
																																																									__TS__StringSplit( -- 173
																																																										table.concat( -- 173
																																																											__TS__StringSplit( -- 173
																																																												table.concat( -- 173
																																																													__TS__StringSplit( -- 173
																																																														table.concat( -- 173
																																																															__TS__StringSplit(text, "按住 [E]+[D]"), -- 173
																																																															"点按推/拉车并推摇杆" -- 174
																																																														), -- 174
																																																														"[E]+[D]" -- 175
																																																													), -- 175
																																																													"推/拉车并推摇杆" -- 175
																																																												), -- 175
																																																												"速按 [CTRL]" -- 176
																																																											), -- 176
																																																											"点按「蹲伏」" -- 176
																																																										), -- 176
																																																										"按住 [CTRL]" -- 177
																																																									), -- 177
																																																									"点按「蹲伏」" -- 177
																																																								), -- 177
																																																								"按 [CTRL]" -- 178
																																																							), -- 178
																																																							"点按「蹲伏」" -- 178
																																																						), -- 178
																																																						"[CTRL]" -- 179
																																																					), -- 179
																																																					"「蹲伏」" -- 179
																																																				), -- 179
																																																				"按住 [SHIFT]" -- 180
																																																			), -- 180
																																																			"点按「轻步/掩体」" -- 180
																																																		), -- 180
																																																		"[SHIFT]" -- 181
																																																	), -- 181
																																																	"「轻步/掩体」" -- 181
																																																), -- 181
																																																"按住 [F]" -- 182
																																															), -- 182
																																															"按住「投瓶」拖拽" -- 182
																																														), -- 182
																																														"[F]" -- 183
																																													), -- 183
																																													"「投瓶」" -- 183
																																												), -- 183
																																												"按住 E" -- 184
																																											), -- 184
																																											"长按「交互」" -- 184
																																										), -- 184
																																										"按 [E]" -- 185
																																									), -- 185
																																									"点按「交互」" -- 185
																																								), -- 185
																																								"[E]" -- 186
																																							), -- 186
																																							"「交互」" -- 186
																																						), -- 186
																																						"方向键" -- 187
																																					), -- 187
																																					"左下摇杆" -- 187
																																				), -- 187
																																				"按 [ESC]" -- 188
																																			), -- 188
																																			"轻触右上「暂歇」" -- 188
																																		), -- 188
																																		"[ESC]" -- 189
																																	), -- 189
																																	"右上「暂歇」" -- 189
																																), -- 189
																																"按 [SPACE]" -- 190
																															), -- 190
																															"点按「翻滚/跳跃」" -- 190
																														), -- 190
																														"[SPACE]" -- 191
																													), -- 191
																													"「翻滚/跳跃」" -- 191
																												), -- 191
																												"按 [R]" -- 192
																											), -- 192
																											"在暂歇菜单重试" -- 192
																										), -- 192
																										"[A/D]" -- 193
																									), -- 193
																									"左下摇杆" -- 193
																								), -- 193
																								"[W/S]" -- 194
																							), -- 194
																							"摇杆上下" -- 194
																						), -- 194
																						"[W]" -- 195
																					), -- 195
																					"摇杆向上" -- 195
																				), -- 195
																				"[S]" -- 196
																			), -- 196
																			"摇杆向下" -- 196
																		), -- 196
																		"鼠标瞄准，左键发射火铳" -- 197
																	), -- 197
																	"点屏或拖「开火」发射火铳" -- 197
																), -- 197
																"左键先手击倒" -- 198
															), -- 198
															"点屏或「开火」先手击倒" -- 198
														), -- 198
														"左键发射火铳" -- 199
													), -- 199
													"点屏或「开火」发射火铳" -- 199
												), -- 199
												"左键发铳" -- 200
											), -- 200
											"点屏或「开火」发铳" -- 200
										), -- 200
										"左键" -- 201
									), -- 201
									"点屏或「开火」" -- 201
								), -- 201
								"鼠标" -- 202
							), -- 202
							"触屏" -- 202
						), -- 202
						"按 E 再次启程" -- 203
					), -- 203
					"轻触屏幕再次启程" -- 203
				), -- 203
				"Esc 暂歇" -- 204
			), -- 204
			"轻触右上暂歇" -- 204
		) -- 204
	end -- 204
	local backBtn = layout == "nintendo" and "A" or "B" -- 206
	return table.concat( -- 207
		__TS__StringSplit( -- 207
			table.concat( -- 207
				__TS__StringSplit( -- 207
					table.concat( -- 207
						__TS__StringSplit( -- 207
							table.concat( -- 207
								__TS__StringSplit( -- 207
									table.concat( -- 207
										__TS__StringSplit( -- 207
											table.concat( -- 207
												__TS__StringSplit( -- 207
													table.concat( -- 207
														__TS__StringSplit( -- 207
															table.concat( -- 207
																__TS__StringSplit( -- 207
																	table.concat( -- 207
																		__TS__StringSplit( -- 207
																			table.concat( -- 207
																				__TS__StringSplit( -- 207
																					table.concat( -- 207
																						__TS__StringSplit( -- 207
																							table.concat( -- 207
																								__TS__StringSplit( -- 207
																									table.concat( -- 207
																										__TS__StringSplit( -- 207
																											table.concat( -- 207
																												__TS__StringSplit( -- 207
																													table.concat( -- 207
																														__TS__StringSplit( -- 207
																															table.concat( -- 207
																																__TS__StringSplit( -- 207
																																	table.concat( -- 207
																																		__TS__StringSplit( -- 207
																																			table.concat( -- 207
																																				__TS__StringSplit( -- 207
																																					table.concat( -- 207
																																						__TS__StringSplit( -- 207
																																							table.concat( -- 207
																																								__TS__StringSplit( -- 207
																																									table.concat( -- 207
																																										__TS__StringSplit(text, "[SHIFT]"), -- 207
																																										"[LT/LB]" -- 208
																																									), -- 208
																																									"[CTRL]" -- 209
																																								), -- 209
																																								"[B]" -- 209
																																							), -- 209
																																							"[E]+[D]" -- 210
																																						), -- 210
																																						"[Y]+右推" -- 210
																																					), -- 210
																																					"[E]" -- 211
																																				), -- 211
																																				"[Y]" -- 211
																																			), -- 211
																																			"[F]" -- 212
																																		), -- 212
																																		"[RT/X]" -- 212
																																	), -- 212
																																	"[SPACE]" -- 213
																																), -- 213
																																"[A]" -- 213
																															), -- 213
																															"[W/S]" -- 214
																														), -- 214
																														"左摇杆上下" -- 214
																													), -- 214
																													"[A/D]" -- 215
																												), -- 215
																												"左摇杆左右" -- 215
																											), -- 215
																											"[W]" -- 216
																										), -- 216
																										"左摇杆向上" -- 216
																									), -- 216
																									"[S]" -- 217
																								), -- 217
																								"左摇杆向下" -- 217
																							), -- 217
																							"[ESC]" -- 218
																						), -- 218
																						"[START]" -- 218
																					), -- 218
																					"[R]" -- 219
																				), -- 219
																				"长按 [BACK]" -- 219
																			), -- 219
																			"鼠标瞄准，左键发射火铳" -- 220
																		), -- 220
																		"右摇杆瞄准，按 [RT/X] 发射火铳" -- 220
																	), -- 220
																	"左键先手击倒" -- 221
																), -- 221
																"按 [RT/X] 先手击倒" -- 221
															), -- 221
															"左键发射火铳" -- 222
														), -- 222
														"按 [RT/X] 发射火铳" -- 222
													), -- 222
													"左键发铳" -- 223
												), -- 223
												"按 [RT/X] 发铳" -- 223
											), -- 223
											"按 E 再次启程" -- 224
										), -- 224
										"按 Y 再次启程" -- 224
									), -- 224
									"按住 E" -- 225
								), -- 225
								"按住 Y" -- 225
							), -- 225
							"方向键" -- 226
						), -- 226
						"左摇杆" -- 226
					), -- 226
					"Esc 暂歇" -- 227
				), -- 227
				"START 暂歇" -- 227
			), -- 227
			"返回" -- 228
		), -- 228
		("按 " .. backBtn) .. " 返回" or "," -- 228
	) -- 228
end -- 170
local HandheldInputDriver = __TS__Class() -- 231
HandheldInputDriver.name = "HandheldInputDriver" -- 231
function HandheldInputDriver.prototype.____constructor(self, settings) -- 238
	self.defaultMode = "gamepad" -- 232
	self.settings = settings -- 239
	if settings.modePref == "kbm" then -- 239
		settings.modePref = "auto" -- 241
	end -- 241
	self.touchRouter = __TS__New(TouchRouter, settings, {enableMouseCompat = false, enablePortrait = false}) -- 243
	self.gamepadRouter = __TS__New(GamepadRouter, settings) -- 247
end -- 238
function HandheldInputDriver.prototype.attach(self, parent, _hooks) -- 250
	self.touchRouter:attach(parent) -- 251
	self.gamepadRouter:attach(parent) -- 252
	if self.touchControls == nil then -- 252
		self.touchControls = __TS__New(TouchControls, parent) -- 254
	end -- 254
end -- 250
function HandheldInputDriver.prototype.syncFrame(self, ctx) -- 258
	local vp = ctx.viewport -- 259
	local p = ctx.play -- 260
	local isPlayMode = ctx.mode == 1 and ctx.screen == "play" and p ~= nil -- 261
	local gameplayActive = isPlayMode -- 262
	local modal = not gameplayActive or p == nil or p.paused or p.reloadOpen or p.craftBench.active or p.escortFailed or p.talentModalActive or ctx.ledgerOpen == true -- 263
	local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 265
	local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 266
	local talentOfferCount = #ctx.storyTalentBoxes -- 267
	local ____temp_0 -- 268
	if isPlayMode and p ~= nil then -- 268
		____temp_0 = isCutsceneBlockingPlay(p) -- 268
	else -- 268
		____temp_0 = false -- 268
	end -- 268
	local cutsceneBlocking = ____temp_0 -- 268
	local allowDepth = p ~= nil and p.room.depth ~= nil -- 269
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 270
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and p.escort.state ~= "calming" -- 271
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 273
	local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 275
	local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 278
	local enemyTargets = canShoot and self.settings.aimAssist and p ~= nil and collectAimTargets(p, ctx.cam, vp.stageW, vp.stageH) or ({}) -- 281
	if self.touchControls ~= nil then -- 281
		local pref = self.settings.modePref -- 286
		self.touchControls:syncContext({ -- 287
			viewport = vp, -- 288
			mode = ctx.mode, -- 289
			screen = ctx.screen, -- 290
			play = p, -- 291
			run = ctx.run, -- 292
			cam = ctx.cam, -- 293
			router = self.touchRouter, -- 294
			overlayActive = self:shouldShowTouchControls(ctx.input, vp), -- 295
			allowAutoGameplayTouch = pref == "auto" or pref == "touch", -- 296
			allowMouseOnOverlay = false, -- 297
			showWebTopPills = false, -- 298
			canToggleFullscreen = false, -- 299
			assistHintsEnabled = ctx.assistHintsEnabled, -- 300
			isMuted = ctx.isMuted, -- 301
			isFullscreen = false, -- 302
			storyTalentBoxes = ctx.storyTalentBoxes, -- 303
			escortDeathBoxes = ctx.escortDeathBoxes, -- 304
			ledgerOpen = ctx.ledgerOpen, -- 305
			ledgerBox = ctx.ledgerBox, -- 306
			enemyTargets = enemyTargets, -- 307
			dt = ctx.dt -- 308
		}) -- 308
	end -- 308
	local muzzle = p ~= nil and projectMuzzle(p, ctx.cam) or nil -- 312
	local playerScreenX = muzzle and muzzle.x or vp.stageW * 0.5 -- 313
	local playerScreenY = muzzle and muzzle.y or vp.stageH * 0.38 -- 314
	local gpCtx = { -- 316
		stageW = vp.stageW, -- 317
		stageH = vp.stageH, -- 318
		uiScale = vp.uiScale, -- 319
		modal = modal, -- 320
		gameplayActive = gameplayActive, -- 321
		reloadActive = reloadActive, -- 322
		craftActive = craftActive, -- 323
		talentOfferCount = talentOfferCount, -- 324
		childMode = p ~= nil and p.childMode, -- 325
		allowDepth = allowDepth, -- 326
		canShoot = canShoot, -- 327
		canBottleAim = canBottleAim, -- 328
		playerRolling = p ~= nil and p.player.rollT > 0, -- 329
		inLowArch = inLowArch, -- 330
		inTowerEnd = inTowerEnd, -- 331
		playerFacing = p ~= nil and p.player.facing or 1, -- 332
		playerScreenX = playerScreenX, -- 333
		playerScreenY = playerScreenY, -- 334
		enemyTargets = enemyTargets -- 335
	} -- 335
	self.gamepadRouter:setFrameContext(gpCtx, ctx.dt) -- 337
end -- 258
function HandheldInputDriver.prototype.renderOverlay(self) -- 340
	local ____opt_5 = self.touchControls -- 340
	if ____opt_5 ~= nil then -- 340
		____opt_5:render(self.touchRouter) -- 341
	end -- 341
end -- 340
function HandheldInputDriver.prototype.clearTransient(self, keepTouchToggles) -- 344
	self.touchRouter:releaseAll(keepTouchToggles) -- 345
	self.gamepadRouter:clearTransient() -- 346
end -- 344
function HandheldInputDriver.prototype.vibrate(self, seconds) -- 349
	self.touchRouter:vibrate(seconds) -- 350
end -- 349
function HandheldInputDriver.prototype.onInputModeChanged(self, mode) -- 353
	if mode ~= "touch" then -- 353
		self.touchRouter:releaseAll(false) -- 355
	end -- 355
end -- 353
function HandheldInputDriver.prototype.shouldShowTouchControls(self, input, _vp) -- 359
	if self.settings.modePref == "touch" then -- 359
		return true -- 360
	end -- 360
	if self.settings.modePref == "gamepad" then -- 360
		return false -- 361
	end -- 361
	return input.inputMode == "touch" -- 362
end -- 359
function HandheldInputDriver.prototype.getTouchRouter(self) -- 365
	return self.touchRouter -- 366
end -- 365
function HandheldInputDriver.prototype.getGamepadRouter(self) -- 369
	return self.gamepadRouter -- 370
end -- 369
function HandheldInputDriver.prototype.getTouchControls(self) -- 373
	return self.touchControls -- 374
end -- 373
function HandheldInputDriver.prototype.injectTouch(self, phase, id, x, y, fromMouse) -- 377
	self.touchRouter:injectTouch( -- 378
		phase, -- 378
		id, -- 378
		x, -- 378
		y, -- 378
		fromMouse == true -- 378
	) -- 378
end -- 377
function HandheldInputDriver.prototype.setGamepadSim(self, state) -- 381
	self.gamepadRouter:setSimulatedState(state) -- 382
end -- 381
function HandheldInputDriver.prototype.pollInto(self, input) -- 385
	input.gamepadLayout = self.settings.gamepadLayout -- 386
	local touch = self.touchRouter:consumeSnapshot() -- 387
	local gp = self.gamepadRouter:consumeSnapshot() -- 388
	if gp.hadGamepadInput or touch.hadRealTouch then -- 388
		input.userInteracted = true -- 391
	end -- 391
	local pref = self.settings.modePref -- 395
	if pref == "gamepad" or pref == "touch" then -- 395
		input:setInputMode(pref) -- 397
	elseif gp.hadGamepadInput then -- 397
		input:setInputMode("gamepad") -- 399
	elseif touch.hadGameplayTouch then -- 399
		input:setInputMode("touch") -- 401
	elseif input.inputMode == "kbm" then -- 401
		input:setInputMode("gamepad") -- 403
	end -- 403
	input.moveX = gp.moveX ~= 0 and gp.moveX or touch.moveX -- 406
	input.moveY = gp.moveY ~= 0 and gp.moveY or touch.moveY -- 407
	input:applyKeyHeld( -- 408
		gp.jumpHeld or touch.jumpHeld, -- 409
		gp.crouchHeld or touch.crouchHeld, -- 410
		gp.coverHeld or touch.coverHeld, -- 411
		gp.interactHeld or touch.interactHeld, -- 412
		gp.aimHeld or touch.aimHeld, -- 413
		gp.fireHeld or touch.fireHeld, -- 414
		gp.flareHeld, -- 415
		false, -- 416
		false, -- 417
		false, -- 418
		false -- 419
	) -- 419
	input:resetFrameSignals() -- 422
	if gp.jumpPressed then -- 422
		input.jump.pressed = true -- 424
	end -- 424
	if gp.crouchPressed then -- 424
		input.crouch.pressed = true -- 425
	end -- 425
	if gp.interactPressed then -- 425
		input.interact.pressed = true -- 426
	end -- 426
	if gp.aimPressed then -- 426
		input.aim.pressed = true -- 427
	end -- 427
	if gp.firePressed then -- 427
		input.fire.pressed = true -- 428
	end -- 428
	if gp.flarePressed then -- 428
		input.flare.pressed = true -- 429
	end -- 429
	if gp.pausePressed then -- 429
		input.pause.pressed = true -- 430
	end -- 430
	if gp.retryPressed then -- 430
		input.retry.pressed = true -- 431
	end -- 431
	if gp.artifactPressed then -- 431
		input.artifactTogglePressed = true -- 432
	end -- 432
	if gp.anyButtonPressed then -- 432
		input.splashSkipPressed = true -- 433
	end -- 433
	if gp.bottleCanceled then -- 433
		input.bottleCanceled = true -- 435
		input.aim.held = false -- 436
		input.aim.pressed = false -- 437
		input.aim.released = false -- 438
	end -- 438
	input.navUp = gp.navUp -- 440
	input.navDown = gp.navDown -- 441
	input.navLeft = gp.navLeft -- 442
	input.navRight = gp.navRight -- 443
	input.navConfirm = gp.navConfirm -- 444
	input.navBack = gp.navBack -- 445
	input.navPrevTab = gp.navPrevTab -- 446
	input.navNextTab = gp.navNextTab -- 447
	input.reloadDirCol = gp.reloadDirCol -- 448
	input.reloadDirRow = gp.reloadDirRow -- 449
	input.reloadStepEdge = gp.reloadStepEdge -- 450
	input.reloadAutoStep = gp.reloadAutoStep -- 451
	input.reloadConfirm = gp.reloadConfirm -- 452
	input.reloadReset = gp.reloadReset -- 453
	input.talentDelta = gp.talentDelta -- 454
	input.talentConfirm = gp.talentConfirm -- 455
	input.retryHoldProgress = gp.retryHoldProgress -- 456
	if touch.jumpPressed then -- 456
		input.jump.pressed = true -- 458
	end -- 458
	if touch.interactPressed then -- 458
		input.interact.pressed = true -- 459
	end -- 459
	if touch.firePressed then -- 459
		input.fire.pressed = true -- 460
	end -- 460
	if touch.pausePressed then -- 460
		input.pause.pressed = true -- 461
	end -- 461
	if touch.retryPressed then -- 461
		input.retry.pressed = true -- 462
	end -- 462
	if touch.artifactPressed then -- 462
		input.artifactTogglePressed = true -- 463
	end -- 463
	if touch.mutePressed then -- 463
		input.muteTogglePressed = true -- 464
	end -- 464
	if touch.anyTapBegan then -- 464
		input.splashSkipPressed = true -- 465
	end -- 465
	if touch.zoneTap ~= "" then -- 465
		input.touchZoneTap = touch.zoneTap -- 466
	end -- 466
	if touch.navUp then -- 466
		input.navUp = true -- 467
	end -- 467
	if touch.navDown then -- 467
		input.navDown = true -- 468
	end -- 468
	if touch.navLeft then -- 468
		input.navLeft = true -- 469
	end -- 469
	if touch.navRight then -- 469
		input.navRight = true -- 470
	end -- 470
	if touch.navConfirm then -- 470
		input.navConfirm = true -- 471
	end -- 471
	if touch.navBack then -- 471
		input.navBack = true -- 472
	end -- 472
	if touch.bottleCanceled then -- 472
		input.bottleCanceled = true -- 474
		input.aim.held = false -- 475
		input.aim.pressed = false -- 476
		input.aim.released = false -- 477
	end -- 477
	input.craftConfirm = input.navConfirm -- 480
	input.craftCancel = input.navBack -- 481
	input.frameInteractPressed = input.interact.pressed -- 482
	if touch.uiHeld or touch.uiPressed or touch.uiReleased or touch.uiInside then -- 482
		input.uiX = touch.uiX -- 485
		input.uiY = touch.uiY -- 486
		input.uiDx = touch.uiDx -- 487
		input.uiDy = touch.uiDy -- 488
		input.uiInside = touch.uiInside -- 489
		input.uiHeld = touch.uiHeld -- 490
		input.uiPressed = touch.uiPressed -- 491
		input.uiReleased = touch.uiReleased -- 492
		input.uiRightPressed = false -- 493
		if touch.uiHeld or touch.uiPressed then -- 493
			input.mdx = touch.uiDx -- 495
			input.mdy = touch.uiDy -- 496
			input.mx = touch.uiX -- 497
			input.my = touch.uiY -- 498
			input.inside = true -- 499
		elseif touch.hasAim then -- 499
			input.mdx = touch.aimX - input.mx -- 501
			input.mdy = touch.aimY - input.my -- 502
			input.mx = touch.aimX -- 503
			input.my = touch.aimY -- 504
			input.inside = true -- 505
		else -- 505
			input.mdx = 0 -- 507
			input.mdy = 0 -- 508
			input.inside = touch.uiInside -- 509
		end -- 509
		return -- 511
	end -- 511
	if input.inputMode == "gamepad" then -- 511
		if gp.hasAim then -- 511
			input.mdx = gp.aimX - input.mx -- 516
			input.mdy = gp.aimY - input.my -- 517
			input.mx = gp.aimX -- 518
			input.my = gp.aimY -- 519
			input.inside = true -- 520
		else -- 520
			input.mdx = 0 -- 522
			input.mdy = 0 -- 523
			input.inside = false -- 524
		end -- 524
		input.uiX = input.mx -- 526
		input.uiY = input.my -- 527
		input.uiDx = 0 -- 528
		input.uiDy = 0 -- 529
		input.uiInside = false -- 530
		input.uiHeld = false -- 531
		input.uiPressed = false -- 532
		input.uiReleased = false -- 533
		input.uiRightPressed = false -- 534
		return -- 535
	end -- 535
	if touch.hasAim then -- 535
		input.mdx = touch.aimX - input.mx -- 539
		input.mdy = touch.aimY - input.my -- 540
		input.mx = touch.aimX -- 541
		input.my = touch.aimY -- 542
		input.inside = true -- 543
	else -- 543
		input.mdx = 0 -- 545
		input.mdy = 0 -- 546
		input.inside = false -- 547
	end -- 547
	input.uiDx = 0 -- 549
	input.uiDy = 0 -- 550
	input.uiInside = false -- 551
	input.uiHeld = false -- 552
	input.uiPressed = false -- 553
	input.uiReleased = false -- 554
	input.uiRightPressed = false -- 555
end -- 385
____exports.TARGET = { -- 559
	id = "handheld", -- 560
	supportsKbm = false, -- 561
	supportsTouch = true, -- 562
	supportsGamepad = true, -- 563
	supportsPortrait = false, -- 564
	defaultInputMode = "gamepad", -- 565
	supportedModes = {"gamepad", "touch"}, -- 566
	modePrefOrder = HANDHELD_MODE_PREFS, -- 567
	controlsGuideTabs = {{mode = "gamepad", label = "手柄"}, {mode = "touch", label = "触屏"}}, -- 568
	getPlatformCaps = function(self) -- 573
		local standaloneApk = isStandaloneApk() -- 574
		local cfg = getReleaseConfig() -- 575
		return { -- 576
			kind = "android", -- 577
			target = "handheld", -- 578
			isDesktop = false, -- 579
			isMobile = true, -- 580
			isWeb = false, -- 581
			isStandaloneAndroidApk = standaloneApk, -- 582
			canToggleFullscreen = false, -- 583
			canQuit = standaloneApk, -- 584
			hasBackButton = true, -- 585
			supportsHaptics = type(App.vibrate) == "function", -- 586
			needsAudioUnlock = false, -- 587
			isRelease = cfg ~= nil and cfg.isRelease == true, -- 588
			defaultInputMode = "gamepad" -- 589
		} -- 589
	end, -- 573
	canToggleFullscreen = function(self) -- 593
		return false -- 594
	end, -- 593
	canQuitApp = function(self) -- 597
		return isStandaloneApk() -- 598
	end, -- 597
	isReleaseMode = function(self) -- 601
		local cfg = getReleaseConfig() -- 602
		return cfg ~= nil and cfg.isRelease == true -- 603
	end, -- 601
	computeStageViewport = function(self, fullW, fullH) -- 606
		return computeLandscapeSafeViewport(fullW, fullH) -- 607
	end, -- 606
	triggerHaptics = function(self, seconds, enabled) -- 610
		triggerMobileHaptics(seconds, enabled) -- 611
	end, -- 610
	keyTagFor = function(self, action, mode, layout) -- 614
		return keyTagHandheld(action, mode, layout) -- 615
	end, -- 614
	adaptWorldKeyTag = function(self, rawKeyTag, mode, _layout) -- 618
		return adaptWorldKeyTagHandheld(rawKeyTag, mode) -- 619
	end, -- 618
	adaptHintSentence = function(self, text, mode, layout) -- 622
		return adaptHintSentenceHandheld(text, mode, layout) -- 623
	end, -- 622
	controlsGuideRows = function(self, tab) -- 626
		return tab == "touch" and GUIDE_TOUCH or GUIDE_GAMEPAD -- 627
	end, -- 626
	splashSkipHint = function(self, mode, layout) -- 630
		if mode == "touch" then -- 630
			return "轻触跳过" -- 631
		end -- 631
		return keyTagHandheld("confirm", "gamepad", layout) .. " / START  跳过" -- 632
	end, -- 630
	titleFooterHint = function(self, mode, layout) -- 635
		if mode == "touch" then -- 635
			return isStandaloneApk() and "轻触择项启程   ·   双击返回键退出" or "轻触择项启程   ·   支持手柄与触屏" -- 637
		end -- 637
		return ("左摇杆 / 十字键择项   ·   " .. keyTagHandheld("confirm", "gamepad", layout)) .. " 或点选启程" -- 641
	end, -- 635
	chapterFooterHint = function(self, mode, confirmTag) -- 644
		if mode == "touch" then -- 644
			return "轻触驿站预览   ·   再点或轻触入此卷章" -- 645
		end -- 645
		return ("摇杆/十字键选择   ·   " .. confirmTag) .. " 或点选进入" -- 646
	end, -- 644
	pauseFooterHint = function(self, mode, layout) -- 649
		if mode == "touch" then -- 649
			return "轻触确认   ·   点「继续游戏」续行" -- 650
		end -- 650
		return ((keyTagHandheld("back", "gamepad", layout) .. " / START 续行   ·   ") .. keyTagHandheld("confirm", "gamepad", layout)) .. " 确认" -- 651
	end, -- 649
	settingsFooterHint = function(self, mode, layout) -- 654
		if mode == "touch" then -- 654
			return "轻触任意条目切换   ·   设置自动保存" -- 655
		end -- 655
		return ((("左右或 " .. keyTagHandheld("confirm", "gamepad", layout)) .. " 切换   ·   ") .. keyTagHandheld("back", "gamepad", layout)) .. " 返回暂停" -- 656
	end, -- 654
	controlsFooterRightHint = function(self, mode) -- 659
		if mode == "touch" then -- 659
			return "轻触右上页签切图 · 暂歇菜单可调操控设置" -- 660
		end -- 660
		return "LB / RB 或左右切换键位图" -- 661
	end, -- 659
	epilogueFooterHint = function(self, mode, layout) -- 664
		if mode == "touch" then -- 664
			return "轻触任一入口继续" -- 665
		end -- 665
		return ((keyTagHandheld("confirm", "gamepad", layout) .. " 确认   ·   ") .. keyTagHandheld("back", "gamepad", layout)) .. " 返回标题" -- 666
	end, -- 664
	settingsRows = function(self) -- 669
		return HANDHELD_SETTINGS_ROWS -- 670
	end, -- 669
	settingsPauseLabel = function(self, settings) -- 673
		local pref = settings.modePref -- 674
		return "操控设置 · " .. modePrefLabelOf(pref) -- 675
	end, -- 673
	settingsHeaderTitle = function(self) -- 678
		return "操控与声音" -- 679
	end, -- 678
	settingsHeaderSummary = function(self, activeMode) -- 682
		return ("当前模式：" .. inputModeLabelOf(activeMode)) .. " · 操控与四通道音量实时生效" -- 683
	end, -- 682
	settingsValueText = function(self, rowId, settings, activeMode) -- 686
		if rowId == "modePref" then -- 686
			local pref = settings.modePref -- 688
			return pref == "auto" and ("自动切换（" .. inputModeLabelOf(activeMode)) .. "）" or "锁定 · " .. modePrefLabelOf(pref) -- 689
		end -- 689
		if rowId == "aimAssist" then -- 689
			return settings.aimAssist and "开（触屏与手柄共用）" or "关" -- 693
		end -- 693
		if rowId == "gpLayout" then -- 693
			return layoutLabelOf(settings.gamepadLayout) -- 694
		end -- 694
		if rowId == "crouchMode" then -- 694
			return settings.crouchToggle and "点按切换" or "持续按住" -- 695
		end -- 695
		if rowId == "touchOpacity" then -- 695
			return opacityLabelOf(settings.touchOpacity) -- 696
		end -- 696
		if rowId == "touchScale" then -- 696
			return scaleLabelOf(settings.touchScale) -- 697
		end -- 697
		if rowId == "haptics" then -- 697
			return settings.haptics and "开" or "关" -- 698
		end -- 698
		return volumeSettingText(rowId, settings) -- 699
	end, -- 686
	applySettingsDelta = function(self, rowId, delta, settings, input) -- 702
		if rowId == "back" then -- 702
			return "back" -- 703
		end -- 703
		if rowId == "modePref" then -- 703
			input:cycleModePref(delta) -- 705
			return "control" -- 706
		end -- 706
		if rowId == "aimAssist" then -- 706
			settings.aimAssist = not settings.aimAssist -- 709
			saveControlSettings(settings) -- 710
			return "control" -- 711
		end -- 711
		if rowId == "gpLayout" then -- 711
			settings.gamepadLayout = settings.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 714
			input.gamepadLayout = settings.gamepadLayout -- 715
			saveControlSettings(settings) -- 716
			return "control" -- 717
		end -- 717
		if rowId == "crouchMode" then -- 717
			settings.crouchToggle = not settings.crouchToggle -- 720
			saveControlSettings(settings) -- 721
			return "control" -- 722
		end -- 722
		if rowId == "touchOpacity" then -- 722
			settings.touchOpacity = nextStepValue(settings.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 725
			saveControlSettings(settings) -- 726
			return "control" -- 727
		end -- 727
		if rowId == "touchScale" then -- 727
			settings.touchScale = nextStepValue(settings.touchScale, TOUCH_SCALE_STEPS, delta) -- 730
			saveControlSettings(settings) -- 731
			return "control" -- 732
		end -- 732
		if rowId == "haptics" then -- 732
			settings.haptics = not settings.haptics -- 735
			saveControlSettings(settings) -- 736
			if settings.haptics then -- 736
				input:vibrate(0.018) -- 738
			end -- 738
			return "control" -- 740
		end -- 740
		if applyVolumeSetting(rowId, delta, settings) then -- 740
			return "audio" -- 742
		end -- 742
		return "none" -- 743
	end, -- 702
	createDriver = function(self, settings) -- 746
		return __TS__New(HandheldInputDriver, settings) -- 747
	end -- 746
} -- 746
return ____exports -- 746