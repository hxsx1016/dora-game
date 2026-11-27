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
	local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 269
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 271
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and p.escort.state ~= "calming" -- 272
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 274
	local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 276
	local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 279
	local enemyTargets = canShoot and self.settings.aimAssist and p ~= nil and collectAimTargets(p, ctx.cam, vp.stageW, vp.stageH) or ({}) -- 282
	if self.touchControls ~= nil then -- 282
		local pref = self.settings.modePref -- 287
		self.touchControls:syncContext({ -- 288
			viewport = vp, -- 289
			mode = ctx.mode, -- 290
			screen = ctx.screen, -- 291
			play = p, -- 292
			run = ctx.run, -- 293
			cam = ctx.cam, -- 294
			router = self.touchRouter, -- 295
			overlayActive = self:shouldShowTouchControls(ctx.input, vp), -- 296
			allowAutoGameplayTouch = pref == "auto" or pref == "touch", -- 297
			allowMouseOnOverlay = false, -- 298
			showWebTopPills = false, -- 299
			canToggleFullscreen = false, -- 300
			assistHintsEnabled = ctx.assistHintsEnabled, -- 301
			isMuted = ctx.isMuted, -- 302
			isFullscreen = false, -- 303
			storyTalentBoxes = ctx.storyTalentBoxes, -- 304
			escortDeathBoxes = ctx.escortDeathBoxes, -- 305
			ledgerOpen = ctx.ledgerOpen, -- 306
			ledgerBox = ctx.ledgerBox, -- 307
			enemyTargets = enemyTargets, -- 308
			dt = ctx.dt -- 309
		}) -- 309
	end -- 309
	local muzzle = p ~= nil and projectMuzzle(p, ctx.cam) or nil -- 313
	local playerScreenX = muzzle and muzzle.x or vp.stageW * 0.5 -- 314
	local playerScreenY = muzzle and muzzle.y or vp.stageH * 0.38 -- 315
	local gpCtx = { -- 317
		stageW = vp.stageW, -- 318
		stageH = vp.stageH, -- 319
		uiScale = vp.uiScale, -- 320
		modal = modal, -- 321
		gameplayActive = gameplayActive, -- 322
		reloadActive = reloadActive, -- 323
		craftActive = craftActive, -- 324
		talentOfferCount = talentOfferCount, -- 325
		childMode = p ~= nil and p.childMode, -- 326
		allowDepth = allowDepth, -- 327
		canShoot = canShoot, -- 328
		canBottleAim = canBottleAim, -- 329
		playerRolling = p ~= nil and p.player.rollT > 0, -- 330
		inLowArch = inLowArch, -- 331
		inTowerEnd = inTowerEnd, -- 332
		playerFacing = p ~= nil and p.player.facing or 1, -- 333
		playerScreenX = playerScreenX, -- 334
		playerScreenY = playerScreenY, -- 335
		enemyTargets = enemyTargets -- 336
	} -- 336
	self.gamepadRouter:setFrameContext(gpCtx, ctx.dt) -- 338
end -- 258
function HandheldInputDriver.prototype.renderOverlay(self) -- 341
	local ____opt_5 = self.touchControls -- 341
	if ____opt_5 ~= nil then -- 341
		____opt_5:render(self.touchRouter) -- 342
	end -- 342
end -- 341
function HandheldInputDriver.prototype.clearTransient(self, keepTouchToggles) -- 345
	self.touchRouter:releaseAll(keepTouchToggles) -- 346
	self.gamepadRouter:clearTransient() -- 347
end -- 345
function HandheldInputDriver.prototype.vibrate(self, seconds) -- 350
	self.touchRouter:vibrate(seconds) -- 351
end -- 350
function HandheldInputDriver.prototype.onInputModeChanged(self, mode) -- 354
	if mode ~= "touch" then -- 354
		self.touchRouter:releaseAll(false) -- 356
	end -- 356
end -- 354
function HandheldInputDriver.prototype.shouldShowTouchControls(self, input, _vp) -- 360
	if self.settings.modePref == "touch" then -- 360
		return true -- 361
	end -- 361
	if self.settings.modePref == "gamepad" then -- 361
		return false -- 362
	end -- 362
	return input.inputMode == "touch" -- 363
end -- 360
function HandheldInputDriver.prototype.getTouchRouter(self) -- 366
	return self.touchRouter -- 367
end -- 366
function HandheldInputDriver.prototype.getGamepadRouter(self) -- 370
	return self.gamepadRouter -- 371
end -- 370
function HandheldInputDriver.prototype.getTouchControls(self) -- 374
	return self.touchControls -- 375
end -- 374
function HandheldInputDriver.prototype.injectTouch(self, phase, id, x, y, fromMouse) -- 378
	self.touchRouter:injectTouch( -- 379
		phase, -- 379
		id, -- 379
		x, -- 379
		y, -- 379
		fromMouse == true -- 379
	) -- 379
end -- 378
function HandheldInputDriver.prototype.setGamepadSim(self, state) -- 382
	self.gamepadRouter:setSimulatedState(state) -- 383
end -- 382
function HandheldInputDriver.prototype.pollInto(self, input) -- 386
	input.gamepadLayout = self.settings.gamepadLayout -- 387
	local touch = self.touchRouter:consumeSnapshot() -- 388
	local gp = self.gamepadRouter:consumeSnapshot() -- 389
	if gp.hadGamepadInput or touch.hadRealTouch then -- 389
		input.userInteracted = true -- 392
	end -- 392
	local pref = self.settings.modePref -- 396
	if pref == "gamepad" or pref == "touch" then -- 396
		input:setInputMode(pref) -- 398
	elseif gp.hadGamepadInput then -- 398
		input:setInputMode("gamepad") -- 400
	elseif touch.hadGameplayTouch then -- 400
		input:setInputMode("touch") -- 402
	elseif input.inputMode == "kbm" then -- 402
		input:setInputMode("gamepad") -- 404
	end -- 404
	input.moveX = gp.moveX ~= 0 and gp.moveX or touch.moveX -- 407
	input.moveY = gp.moveY ~= 0 and gp.moveY or touch.moveY -- 408
	input:applyKeyHeld( -- 409
		gp.jumpHeld or touch.jumpHeld, -- 410
		gp.crouchHeld or touch.crouchHeld, -- 411
		gp.coverHeld or touch.coverHeld, -- 412
		gp.interactHeld or touch.interactHeld, -- 413
		gp.aimHeld or touch.aimHeld, -- 414
		gp.fireHeld or touch.fireHeld, -- 415
		gp.flareHeld, -- 416
		false, -- 417
		false, -- 418
		false, -- 419
		false -- 420
	) -- 420
	input:resetFrameSignals() -- 423
	if gp.jumpPressed then -- 423
		input.jump.pressed = true -- 425
	end -- 425
	if gp.crouchPressed then -- 425
		input.crouch.pressed = true -- 426
	end -- 426
	if gp.interactPressed then -- 426
		input.interact.pressed = true -- 427
	end -- 427
	if gp.aimPressed then -- 427
		input.aim.pressed = true -- 428
	end -- 428
	if gp.firePressed then -- 428
		input.fire.pressed = true -- 429
	end -- 429
	if gp.flarePressed then -- 429
		input.flare.pressed = true -- 430
	end -- 430
	if gp.pausePressed then -- 430
		input.pause.pressed = true -- 431
	end -- 431
	if gp.retryPressed then -- 431
		input.retry.pressed = true -- 432
	end -- 432
	if gp.artifactPressed then -- 432
		input.artifactTogglePressed = true -- 433
	end -- 433
	if gp.anyButtonPressed then -- 433
		input.splashSkipPressed = true -- 434
	end -- 434
	if gp.bottleCanceled then -- 434
		input.bottleCanceled = true -- 436
		input.aim.held = false -- 437
		input.aim.pressed = false -- 438
		input.aim.released = false -- 439
	end -- 439
	input.navUp = gp.navUp -- 441
	input.navDown = gp.navDown -- 442
	input.navLeft = gp.navLeft -- 443
	input.navRight = gp.navRight -- 444
	input.navConfirm = gp.navConfirm -- 445
	input.navBack = gp.navBack -- 446
	input.navPrevTab = gp.navPrevTab -- 447
	input.navNextTab = gp.navNextTab -- 448
	input.reloadDirCol = gp.reloadDirCol -- 449
	input.reloadDirRow = gp.reloadDirRow -- 450
	input.reloadStepEdge = gp.reloadStepEdge -- 451
	input.reloadAutoStep = gp.reloadAutoStep -- 452
	input.reloadConfirm = gp.reloadConfirm -- 453
	input.reloadReset = gp.reloadReset -- 454
	input.talentDelta = gp.talentDelta -- 455
	input.talentConfirm = gp.talentConfirm -- 456
	input.retryHoldProgress = gp.retryHoldProgress -- 457
	if touch.jumpPressed then -- 457
		input.jump.pressed = true -- 459
	end -- 459
	if touch.interactPressed then -- 459
		input.interact.pressed = true -- 460
	end -- 460
	if touch.firePressed then -- 460
		input.fire.pressed = true -- 461
	end -- 461
	if touch.pausePressed then -- 461
		input.pause.pressed = true -- 462
	end -- 462
	if touch.retryPressed then -- 462
		input.retry.pressed = true -- 463
	end -- 463
	if touch.artifactPressed then -- 463
		input.artifactTogglePressed = true -- 464
	end -- 464
	if touch.mutePressed then -- 464
		input.muteTogglePressed = true -- 465
	end -- 465
	if touch.anyTapBegan then -- 465
		input.splashSkipPressed = true -- 466
	end -- 466
	if touch.zoneTap ~= "" then -- 466
		input.touchZoneTap = touch.zoneTap -- 467
	end -- 467
	if touch.navUp then -- 467
		input.navUp = true -- 468
	end -- 468
	if touch.navDown then -- 468
		input.navDown = true -- 469
	end -- 469
	if touch.navLeft then -- 469
		input.navLeft = true -- 470
	end -- 470
	if touch.navRight then -- 470
		input.navRight = true -- 471
	end -- 471
	if touch.navConfirm then -- 471
		input.navConfirm = true -- 472
	end -- 472
	if touch.navBack then -- 472
		input.navBack = true -- 473
	end -- 473
	if touch.bottleCanceled then -- 473
		input.bottleCanceled = true -- 475
		input.aim.held = false -- 476
		input.aim.pressed = false -- 477
		input.aim.released = false -- 478
	end -- 478
	input.craftConfirm = input.navConfirm -- 481
	input.craftCancel = input.navBack -- 482
	input.frameInteractPressed = input.interact.pressed -- 483
	if touch.uiHeld or touch.uiPressed or touch.uiReleased or touch.uiInside then -- 483
		input.uiX = touch.uiX -- 486
		input.uiY = touch.uiY -- 487
		input.uiDx = touch.uiDx -- 488
		input.uiDy = touch.uiDy -- 489
		input.uiInside = touch.uiInside -- 490
		input.uiHeld = touch.uiHeld -- 491
		input.uiPressed = touch.uiPressed -- 492
		input.uiReleased = touch.uiReleased -- 493
		input.uiRightPressed = false -- 494
		if touch.uiHeld or touch.uiPressed then -- 494
			input.mdx = touch.uiDx -- 496
			input.mdy = touch.uiDy -- 497
			input.mx = touch.uiX -- 498
			input.my = touch.uiY -- 499
			input.inside = true -- 500
		elseif touch.hasAim then -- 500
			input.mdx = touch.aimX - input.mx -- 502
			input.mdy = touch.aimY - input.my -- 503
			input.mx = touch.aimX -- 504
			input.my = touch.aimY -- 505
			input.inside = true -- 506
		else -- 506
			input.mdx = 0 -- 508
			input.mdy = 0 -- 509
			input.inside = touch.uiInside -- 510
		end -- 510
		return -- 512
	end -- 512
	if input.inputMode == "gamepad" then -- 512
		if gp.hasAim then -- 512
			input.mdx = gp.aimX - input.mx -- 517
			input.mdy = gp.aimY - input.my -- 518
			input.mx = gp.aimX -- 519
			input.my = gp.aimY -- 520
			input.inside = true -- 521
		else -- 521
			input.mdx = 0 -- 523
			input.mdy = 0 -- 524
			input.inside = false -- 525
		end -- 525
		input.uiX = input.mx -- 527
		input.uiY = input.my -- 528
		input.uiDx = 0 -- 529
		input.uiDy = 0 -- 530
		input.uiInside = false -- 531
		input.uiHeld = false -- 532
		input.uiPressed = false -- 533
		input.uiReleased = false -- 534
		input.uiRightPressed = false -- 535
		return -- 536
	end -- 536
	if touch.hasAim then -- 536
		input.mdx = touch.aimX - input.mx -- 540
		input.mdy = touch.aimY - input.my -- 541
		input.mx = touch.aimX -- 542
		input.my = touch.aimY -- 543
		input.inside = true -- 544
	else -- 544
		input.mdx = 0 -- 546
		input.mdy = 0 -- 547
		input.inside = false -- 548
	end -- 548
	input.uiDx = 0 -- 550
	input.uiDy = 0 -- 551
	input.uiInside = false -- 552
	input.uiHeld = false -- 553
	input.uiPressed = false -- 554
	input.uiReleased = false -- 555
	input.uiRightPressed = false -- 556
end -- 386
____exports.TARGET = { -- 560
	id = "handheld", -- 561
	supportsKbm = false, -- 562
	supportsTouch = true, -- 563
	supportsGamepad = true, -- 564
	supportsPortrait = false, -- 565
	defaultInputMode = "gamepad", -- 566
	supportedModes = {"gamepad", "touch"}, -- 567
	modePrefOrder = HANDHELD_MODE_PREFS, -- 568
	controlsGuideTabs = {{mode = "gamepad", label = "手柄"}, {mode = "touch", label = "触屏"}}, -- 569
	getPlatformCaps = function(self) -- 574
		local standaloneApk = isStandaloneApk() -- 575
		local cfg = getReleaseConfig() -- 576
		return { -- 577
			kind = "android", -- 578
			target = "handheld", -- 579
			isDesktop = false, -- 580
			isMobile = true, -- 581
			isWeb = false, -- 582
			isStandaloneAndroidApk = standaloneApk, -- 583
			canToggleFullscreen = false, -- 584
			canQuit = standaloneApk, -- 585
			hasBackButton = true, -- 586
			supportsHaptics = type(App.vibrate) == "function", -- 587
			needsAudioUnlock = false, -- 588
			isRelease = cfg ~= nil and cfg.isRelease == true, -- 589
			defaultInputMode = "gamepad" -- 590
		} -- 590
	end, -- 574
	canToggleFullscreen = function(self) -- 594
		return false -- 595
	end, -- 594
	canQuitApp = function(self) -- 598
		return isStandaloneApk() -- 599
	end, -- 598
	isReleaseMode = function(self) -- 602
		local cfg = getReleaseConfig() -- 603
		return cfg ~= nil and cfg.isRelease == true -- 604
	end, -- 602
	computeStageViewport = function(self, fullW, fullH) -- 607
		return computeLandscapeSafeViewport(fullW, fullH) -- 608
	end, -- 607
	triggerHaptics = function(self, seconds, enabled) -- 611
		triggerMobileHaptics(seconds, enabled) -- 612
	end, -- 611
	keyTagFor = function(self, action, mode, layout) -- 615
		return keyTagHandheld(action, mode, layout) -- 616
	end, -- 615
	adaptWorldKeyTag = function(self, rawKeyTag, mode, _layout) -- 619
		return adaptWorldKeyTagHandheld(rawKeyTag, mode) -- 620
	end, -- 619
	adaptHintSentence = function(self, text, mode, layout) -- 623
		return adaptHintSentenceHandheld(text, mode, layout) -- 624
	end, -- 623
	controlsGuideRows = function(self, tab) -- 627
		return tab == "touch" and GUIDE_TOUCH or GUIDE_GAMEPAD -- 628
	end, -- 627
	splashSkipHint = function(self, mode, layout) -- 631
		if mode == "touch" then -- 631
			return "轻触跳过" -- 632
		end -- 632
		return keyTagHandheld("confirm", "gamepad", layout) .. " / START  跳过" -- 633
	end, -- 631
	titleFooterHint = function(self, mode, layout) -- 636
		if mode == "touch" then -- 636
			return isStandaloneApk() and "轻触择项启程   ·   双击返回键退出" or "轻触择项启程   ·   支持手柄与触屏" -- 638
		end -- 638
		return ("左摇杆 / 十字键择项   ·   " .. keyTagHandheld("confirm", "gamepad", layout)) .. " 或点选启程" -- 642
	end, -- 636
	chapterFooterHint = function(self, mode, confirmTag) -- 645
		if mode == "touch" then -- 645
			return "轻触驿站预览   ·   再点或轻触入此卷章" -- 646
		end -- 646
		return ("摇杆/十字键选择   ·   " .. confirmTag) .. " 或点选进入" -- 647
	end, -- 645
	pauseFooterHint = function(self, mode, layout) -- 650
		if mode == "touch" then -- 650
			return "轻触确认   ·   点「继续游戏」续行" -- 651
		end -- 651
		return ((keyTagHandheld("back", "gamepad", layout) .. " / START 续行   ·   ") .. keyTagHandheld("confirm", "gamepad", layout)) .. " 确认" -- 652
	end, -- 650
	settingsFooterHint = function(self, mode, layout) -- 655
		if mode == "touch" then -- 655
			return "轻触任意条目切换   ·   设置自动保存" -- 656
		end -- 656
		return ((("左右或 " .. keyTagHandheld("confirm", "gamepad", layout)) .. " 切换   ·   ") .. keyTagHandheld("back", "gamepad", layout)) .. " 返回暂停" -- 657
	end, -- 655
	controlsFooterRightHint = function(self, mode) -- 660
		if mode == "touch" then -- 660
			return "轻触右上页签切图 · 暂歇菜单可调操控设置" -- 661
		end -- 661
		return "LB / RB 或左右切换键位图" -- 662
	end, -- 660
	epilogueFooterHint = function(self, mode, layout) -- 665
		if mode == "touch" then -- 665
			return "轻触任一入口继续" -- 666
		end -- 666
		return ((keyTagHandheld("confirm", "gamepad", layout) .. " 确认   ·   ") .. keyTagHandheld("back", "gamepad", layout)) .. " 返回标题" -- 667
	end, -- 665
	settingsRows = function(self) -- 670
		return HANDHELD_SETTINGS_ROWS -- 671
	end, -- 670
	settingsPauseLabel = function(self, settings) -- 674
		local pref = settings.modePref -- 675
		return "操控设置 · " .. modePrefLabelOf(pref) -- 676
	end, -- 674
	settingsHeaderTitle = function(self) -- 679
		return "操控与声音" -- 680
	end, -- 679
	settingsHeaderSummary = function(self, activeMode) -- 683
		return ("当前模式：" .. inputModeLabelOf(activeMode)) .. " · 操控与四通道音量实时生效" -- 684
	end, -- 683
	settingsValueText = function(self, rowId, settings, activeMode) -- 687
		if rowId == "modePref" then -- 687
			local pref = settings.modePref -- 689
			return pref == "auto" and ("自动切换（" .. inputModeLabelOf(activeMode)) .. "）" or "锁定 · " .. modePrefLabelOf(pref) -- 690
		end -- 690
		if rowId == "aimAssist" then -- 690
			return settings.aimAssist and "开（触屏与手柄共用）" or "关" -- 694
		end -- 694
		if rowId == "gpLayout" then -- 694
			return layoutLabelOf(settings.gamepadLayout) -- 695
		end -- 695
		if rowId == "crouchMode" then -- 695
			return settings.crouchToggle and "点按切换" or "持续按住" -- 696
		end -- 696
		if rowId == "touchOpacity" then -- 696
			return opacityLabelOf(settings.touchOpacity) -- 697
		end -- 697
		if rowId == "touchScale" then -- 697
			return scaleLabelOf(settings.touchScale) -- 698
		end -- 698
		if rowId == "haptics" then -- 698
			return settings.haptics and "开" or "关" -- 699
		end -- 699
		return volumeSettingText(rowId, settings) -- 700
	end, -- 687
	applySettingsDelta = function(self, rowId, delta, settings, input) -- 703
		if rowId == "back" then -- 703
			return "back" -- 704
		end -- 704
		if rowId == "modePref" then -- 704
			input:cycleModePref(delta) -- 706
			return "control" -- 707
		end -- 707
		if rowId == "aimAssist" then -- 707
			settings.aimAssist = not settings.aimAssist -- 710
			saveControlSettings(settings) -- 711
			return "control" -- 712
		end -- 712
		if rowId == "gpLayout" then -- 712
			settings.gamepadLayout = settings.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 715
			input.gamepadLayout = settings.gamepadLayout -- 716
			saveControlSettings(settings) -- 717
			return "control" -- 718
		end -- 718
		if rowId == "crouchMode" then -- 718
			settings.crouchToggle = not settings.crouchToggle -- 721
			saveControlSettings(settings) -- 722
			return "control" -- 723
		end -- 723
		if rowId == "touchOpacity" then -- 723
			settings.touchOpacity = nextStepValue(settings.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 726
			saveControlSettings(settings) -- 727
			return "control" -- 728
		end -- 728
		if rowId == "touchScale" then -- 728
			settings.touchScale = nextStepValue(settings.touchScale, TOUCH_SCALE_STEPS, delta) -- 731
			saveControlSettings(settings) -- 732
			return "control" -- 733
		end -- 733
		if rowId == "haptics" then -- 733
			settings.haptics = not settings.haptics -- 736
			saveControlSettings(settings) -- 737
			if settings.haptics then -- 737
				input:vibrate(0.018) -- 739
			end -- 739
			return "control" -- 741
		end -- 741
		if applyVolumeSetting(rowId, delta, settings) then -- 741
			return "audio" -- 743
		end -- 743
		return "none" -- 744
	end, -- 703
	createDriver = function(self, settings) -- 747
		return __TS__New(HandheldInputDriver, settings) -- 748
	end -- 747
} -- 747
return ____exports -- 747