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
}, childRows = { -- 77
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
}, childRows = { -- 97
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
	if mode == "touch" then -- 113
		if action == "interact" then -- 114
			return "点按" -- 114
		end -- 114
		if action == "jump" then -- 115
			return "跳/滚" -- 115
		end -- 115
		if action == "crouch" then -- 116
			return "蹲伏" -- 116
		end -- 116
		if action == "cover" then -- 117
			return "掩体" -- 117
		end -- 117
		if action == "fire" then -- 118
			return "开火" -- 118
		end -- 118
		if action == "aim" then -- 119
			return "拖投瓶" -- 119
		end -- 119
		if action == "pause" then -- 120
			return "暂歇" -- 120
		end -- 120
		if action == "retry" then -- 121
			return "重试" -- 121
		end -- 121
		if action == "confirm" then -- 122
			return "点选" -- 122
		end -- 122
		if action == "back" then -- 123
			return "返回" -- 123
		end -- 123
		return "穿梭" -- 124
	end -- 124
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
end -- 112
local function adaptWorldKeyTagHandheld(rawKeyTag, mode) -- 141
	if mode == "touch" then -- 142
		if rawKeyTag == "E" then -- 143
			return "轻触" -- 143
		end -- 143
		if rawKeyTag == "按住 E" then -- 144
			return "长按交互" -- 144
		end -- 144
		if rawKeyTag == "松开再按住 E" then -- 145
			return "松开再长按" -- 145
		end -- 145
		if rawKeyTag == "按住 E + D" or rawKeyTag == "E 握柄 + D" then -- 146
			return "点推车+摇杆" -- 146
		end -- 146
		if rawKeyTag == "F" or rawKeyTag == "左键" then -- 147
			return "开火" -- 147
		end -- 147
		if rawKeyTag == "按住 F" then -- 148
			return "拖投瓶" -- 148
		end -- 148
		if rawKeyTag == "松开 F" then -- 149
			return "松手投" -- 149
		end -- 149
		if rawKeyTag == "按住 Ctrl" then -- 150
			return "点蹲伏" -- 150
		end -- 150
		if rawKeyTag == "按住 Shift" then -- 151
			return "点掩体" -- 151
		end -- 151
		if rawKeyTag == "连线" then -- 152
			return "一笔划连" -- 152
		end -- 152
		return rawKeyTag -- 153
	end -- 153
	if rawKeyTag == "E" then -- 155
		return "Y" -- 155
	end -- 155
	if rawKeyTag == "按住 E" then -- 156
		return "按住 Y" -- 156
	end -- 156
	if rawKeyTag == "松开再按住 E" then -- 157
		return "松开再按 Y" -- 157
	end -- 157
	if rawKeyTag == "按住 E + D" then -- 158
		return "按住 Y + 右" -- 158
	end -- 158
	if rawKeyTag == "E 握柄 + D" then -- 159
		return "Y 握柄 + 右" -- 159
	end -- 159
	if rawKeyTag == "F" or rawKeyTag == "左键" then -- 160
		return "RT / X" -- 160
	end -- 160
	if rawKeyTag == "按住 F" then -- 161
		return "按住 RT" -- 161
	end -- 161
	if rawKeyTag == "松开 F" then -- 162
		return "松开 RT" -- 162
	end -- 162
	if rawKeyTag == "按住 Ctrl" then -- 163
		return "按住 B" -- 163
	end -- 163
	if rawKeyTag == "按住 Shift" then -- 164
		return "按住 LT" -- 164
	end -- 164
	if rawKeyTag == "连线" then -- 165
		return "摇杆/触屏连线" -- 165
	end -- 165
	if rawKeyTag == "→" then -- 166
		return "右推摇杆" -- 166
	end -- 166
	return rawKeyTag -- 167
end -- 141
local function adaptHintSentenceHandheld(text, mode, layout) -- 170
	if text == "" then -- 171
		return text -- 171
	end -- 171
	if mode == "touch" then -- 172
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
	if settings.modePref == "kbm" then -- 240
		settings.modePref = "auto" -- 241
	end -- 241
	self.touchRouter = __TS__New(TouchRouter, settings, {enableMouseCompat = false, enablePortrait = false}) -- 243
	self.gamepadRouter = __TS__New(GamepadRouter, settings) -- 247
end -- 238
function HandheldInputDriver.prototype.attach(self, parent, _hooks) -- 250
	self.touchRouter:attach(parent) -- 251
	self.gamepadRouter:attach(parent) -- 252
	if self.touchControls == nil then -- 253
		self.touchControls = __TS__New(TouchControls, parent) -- 254
	end -- 254
end -- 250
function HandheldInputDriver.prototype.syncFrame(self, ctx) -- 258
	local vp = ctx.viewport -- 259
	local p = ctx.play -- 260
	local isPlayMode = ctx.mode == 1 and ctx.screen == "play" and p ~= nil -- 261
	local gameplayActive = isPlayMode -- 262
	local talentModalOpen = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and p.talentModalActive and #p:getStoryTalentOffers() > 0 -- 263
	local escortSummaryOpen = isPlayMode and p ~= nil and not p.paused and p.escortFailed -- 265
	local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active or talentModalOpen or escortSummaryOpen) -- 267
	local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 269
	local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 270
	local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and (#ctx.storyTalentBoxes > 0 and #ctx.storyTalentBoxes or #p:getStoryTalentOffers()) or 0 -- 271
	local ____temp_0 -- 274
	if isPlayMode and p ~= nil then -- 274
		____temp_0 = isCutsceneBlockingPlay(p) -- 274
	else -- 274
		____temp_0 = false -- 274
	end -- 274
	local cutsceneBlocking = ____temp_0 -- 274
	local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 275
	local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 277
	local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and p.escort.state ~= "calming" -- 278
	local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 280
	local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 282
	local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 285
	local enemyTargets = canShoot and self.settings.aimAssist and p ~= nil and collectAimTargets(p, ctx.cam, vp.stageW, vp.stageH) or ({}) -- 288
	if self.touchControls ~= nil then -- 292
		local pref = self.settings.modePref -- 293
		self.touchControls:syncContext({ -- 294
			viewport = vp, -- 295
			mode = ctx.mode, -- 296
			screen = ctx.screen, -- 297
			play = p, -- 298
			run = ctx.run, -- 299
			cam = ctx.cam, -- 300
			router = self.touchRouter, -- 301
			overlayActive = self:shouldShowTouchControls(ctx.input, vp), -- 302
			allowAutoGameplayTouch = pref == "auto" or pref == "touch", -- 303
			allowMouseOnOverlay = false, -- 304
			showWebTopPills = false, -- 305
			canToggleFullscreen = false, -- 306
			assistHintsEnabled = ctx.assistHintsEnabled, -- 307
			isMuted = ctx.isMuted, -- 308
			isFullscreen = false, -- 309
			storyTalentBoxes = ctx.storyTalentBoxes, -- 310
			escortDeathBoxes = ctx.escortDeathBoxes, -- 311
			ledgerButtonBox = ctx.ledgerButtonBox, -- 312
			enemyTargets = enemyTargets, -- 313
			dt = ctx.dt -- 314
		}) -- 314
	end -- 314
	local muzzle = p ~= nil and projectMuzzle(p, ctx.cam) or nil -- 318
	local playerScreenX = muzzle and muzzle.x or vp.stageW * 0.5 -- 319
	local playerScreenY = muzzle and muzzle.y or vp.stageH * 0.38 -- 320
	local gpCtx = { -- 322
		stageW = vp.stageW, -- 323
		stageH = vp.stageH, -- 324
		uiScale = vp.uiScale, -- 325
		modal = modal, -- 326
		gameplayActive = gameplayActive, -- 327
		reloadActive = reloadActive, -- 328
		craftActive = craftActive, -- 329
		talentOfferCount = talentOfferCount, -- 330
		childMode = p ~= nil and p.childMode, -- 331
		allowDepth = allowDepth, -- 332
		canShoot = canShoot, -- 333
		canBottleAim = canBottleAim, -- 334
		playerRolling = p ~= nil and p.player.rollT > 0, -- 335
		inLowArch = inLowArch, -- 336
		inTowerEnd = inTowerEnd, -- 337
		playerFacing = p ~= nil and p.player.facing or 1, -- 338
		playerScreenX = playerScreenX, -- 339
		playerScreenY = playerScreenY, -- 340
		enemyTargets = enemyTargets -- 341
	} -- 341
	self.gamepadRouter:setFrameContext(gpCtx, ctx.dt) -- 343
end -- 258
function HandheldInputDriver.prototype.renderOverlay(self) -- 346
	local ____opt_5 = self.touchControls -- 347
	if ____opt_5 ~= nil then -- 347
		____opt_5:render(self.touchRouter) -- 347
	end -- 347
end -- 346
function HandheldInputDriver.prototype.clearTransient(self, keepTouchToggles) -- 350
	self.touchRouter:releaseAll(keepTouchToggles) -- 351
	self.gamepadRouter:clearTransient() -- 352
end -- 350
function HandheldInputDriver.prototype.vibrate(self, seconds) -- 355
	self.touchRouter:vibrate(seconds) -- 356
end -- 355
function HandheldInputDriver.prototype.onInputModeChanged(self, mode) -- 359
	if mode ~= "touch" then -- 360
		self.touchRouter:releaseAll(false) -- 361
	end -- 361
end -- 359
function HandheldInputDriver.prototype.shouldShowTouchControls(self, input, _vp) -- 365
	if self.settings.modePref == "touch" then -- 366
		return true -- 366
	end -- 366
	if self.settings.modePref == "gamepad" then -- 367
		return false -- 367
	end -- 367
	return input.inputMode == "touch" -- 368
end -- 365
function HandheldInputDriver.prototype.getTouchRouter(self) -- 371
	return self.touchRouter -- 372
end -- 371
function HandheldInputDriver.prototype.getGamepadRouter(self) -- 375
	return self.gamepadRouter -- 376
end -- 375
function HandheldInputDriver.prototype.getTouchControls(self) -- 379
	return self.touchControls -- 380
end -- 379
function HandheldInputDriver.prototype.injectTouch(self, phase, id, x, y, fromMouse) -- 383
	self.touchRouter:injectTouch( -- 384
		phase, -- 384
		id, -- 384
		x, -- 384
		y, -- 384
		fromMouse == true -- 384
	) -- 384
end -- 383
function HandheldInputDriver.prototype.setGamepadSim(self, state) -- 387
	self.gamepadRouter:setSimulatedState(state) -- 388
end -- 387
function HandheldInputDriver.prototype.pollInto(self, input) -- 391
	input.gamepadLayout = self.settings.gamepadLayout -- 392
	local touch = self.touchRouter:consumeSnapshot() -- 393
	local gp = self.gamepadRouter:consumeSnapshot() -- 394
	if gp.hadGamepadInput or touch.hadRealTouch then -- 396
		input.userInteracted = true -- 397
	end -- 397
	local pref = self.settings.modePref -- 401
	if pref == "gamepad" or pref == "touch" then -- 402
		input:setInputMode(pref) -- 403
	elseif gp.hadGamepadInput then -- 404
		input:setInputMode("gamepad") -- 405
	elseif touch.hadGameplayTouch then -- 406
		input:setInputMode("touch") -- 407
	elseif input.inputMode == "kbm" then -- 408
		input:setInputMode("gamepad") -- 409
	end -- 409
	input.moveX = gp.moveX ~= 0 and gp.moveX or touch.moveX -- 412
	input.moveY = gp.moveY ~= 0 and gp.moveY or touch.moveY -- 413
	input:applyKeyHeld( -- 414
		gp.jumpHeld or touch.jumpHeld, -- 415
		gp.crouchHeld or touch.crouchHeld, -- 416
		gp.coverHeld or touch.coverHeld, -- 417
		gp.interactHeld or touch.interactHeld, -- 418
		gp.aimHeld or touch.aimHeld, -- 419
		gp.fireHeld or touch.fireHeld, -- 420
		gp.flareHeld, -- 421
		false, -- 422
		false, -- 423
		false, -- 424
		false -- 425
	) -- 425
	input:resetFrameSignals() -- 428
	if gp.jumpPressed then -- 430
		input.jump.pressed = true -- 430
	end -- 430
	if gp.crouchPressed then -- 431
		input.crouch.pressed = true -- 431
	end -- 431
	if gp.interactPressed then -- 432
		input.interact.pressed = true -- 432
	end -- 432
	if gp.aimPressed then -- 433
		input.aim.pressed = true -- 433
	end -- 433
	if gp.firePressed then -- 434
		input.fire.pressed = true -- 434
	end -- 434
	if gp.flarePressed then -- 435
		input.flare.pressed = true -- 435
	end -- 435
	if gp.pausePressed then -- 436
		input.pause.pressed = true -- 436
	end -- 436
	if gp.retryPressed then -- 437
		input.retry.pressed = true -- 437
	end -- 437
	if gp.artifactPressed then -- 438
		input.artifactTogglePressed = true -- 438
	end -- 438
	if gp.anyButtonPressed then -- 439
		input.splashSkipPressed = true -- 439
	end -- 439
	if gp.bottleCanceled then -- 440
		input.bottleCanceled = true -- 441
		input.aim.held = false -- 442
		input.aim.pressed = false -- 443
		input.aim.released = false -- 444
	end -- 444
	input.navUp = gp.navUp -- 446
	input.navDown = gp.navDown -- 447
	input.navLeft = gp.navLeft -- 448
	input.navRight = gp.navRight -- 449
	input.navConfirm = gp.navConfirm -- 450
	input.navBack = gp.navBack -- 451
	input.navPrevTab = gp.navPrevTab -- 452
	input.navNextTab = gp.navNextTab -- 453
	input.reloadDirCol = gp.reloadDirCol -- 454
	input.reloadDirRow = gp.reloadDirRow -- 455
	input.reloadStepEdge = gp.reloadStepEdge -- 456
	input.reloadAutoStep = gp.reloadAutoStep -- 457
	input.reloadConfirm = gp.reloadConfirm -- 458
	input.reloadReset = gp.reloadReset -- 459
	input.talentDelta = gp.talentDelta -- 460
	input.talentConfirm = gp.talentConfirm -- 461
	input.retryHoldProgress = gp.retryHoldProgress -- 462
	if touch.jumpPressed then -- 464
		input.jump.pressed = true -- 464
	end -- 464
	if touch.interactPressed then -- 465
		input.interact.pressed = true -- 465
	end -- 465
	if touch.firePressed then -- 466
		input.fire.pressed = true -- 466
	end -- 466
	if touch.pausePressed then -- 467
		input.pause.pressed = true -- 467
	end -- 467
	if touch.retryPressed then -- 468
		input.retry.pressed = true -- 468
	end -- 468
	if touch.artifactPressed then -- 469
		input.artifactTogglePressed = true -- 469
	end -- 469
	if touch.mutePressed then -- 470
		input.muteTogglePressed = true -- 470
	end -- 470
	if touch.anyTapBegan then -- 471
		input.splashSkipPressed = true -- 471
	end -- 471
	if touch.zoneTap ~= "" then -- 472
		input.touchZoneTap = touch.zoneTap -- 472
	end -- 472
	if touch.navUp then -- 473
		input.navUp = true -- 473
	end -- 473
	if touch.navDown then -- 474
		input.navDown = true -- 474
	end -- 474
	if touch.navLeft then -- 475
		input.navLeft = true -- 475
	end -- 475
	if touch.navRight then -- 476
		input.navRight = true -- 476
	end -- 476
	if touch.navConfirm then -- 477
		input.navConfirm = true -- 477
	end -- 477
	if touch.navBack then -- 478
		input.navBack = true -- 478
	end -- 478
	if touch.bottleCanceled then -- 479
		input.bottleCanceled = true -- 480
		input.aim.held = false -- 481
		input.aim.pressed = false -- 482
		input.aim.released = false -- 483
	end -- 483
	input.craftConfirm = input.navConfirm -- 486
	input.craftCancel = input.navBack -- 487
	input.frameInteractPressed = input.interact.pressed -- 488
	if touch.uiHeld or touch.uiPressed or touch.uiReleased or touch.uiInside then -- 490
		input.uiX = touch.uiX -- 491
		input.uiY = touch.uiY -- 492
		input.uiDx = touch.uiDx -- 493
		input.uiDy = touch.uiDy -- 494
		input.uiInside = touch.uiInside -- 495
		input.uiHeld = touch.uiHeld -- 496
		input.uiPressed = touch.uiPressed -- 497
		input.uiReleased = touch.uiReleased -- 498
		input.uiRightPressed = false -- 499
		if touch.uiHeld or touch.uiPressed then -- 500
			input.mdx = touch.uiDx -- 501
			input.mdy = touch.uiDy -- 502
			input.mx = touch.uiX -- 503
			input.my = touch.uiY -- 504
			input.inside = true -- 505
		elseif touch.hasAim then -- 506
			input.mdx = touch.aimX - input.mx -- 507
			input.mdy = touch.aimY - input.my -- 508
			input.mx = touch.aimX -- 509
			input.my = touch.aimY -- 510
			input.inside = true -- 511
		else -- 511
			input.mdx = 0 -- 513
			input.mdy = 0 -- 514
			input.inside = touch.uiInside -- 515
		end -- 515
		return -- 517
	end -- 517
	if input.inputMode == "gamepad" then -- 520
		if gp.hasAim then -- 521
			input.mdx = gp.aimX - input.mx -- 522
			input.mdy = gp.aimY - input.my -- 523
			input.mx = gp.aimX -- 524
			input.my = gp.aimY -- 525
			input.inside = true -- 526
		else -- 526
			input.mdx = 0 -- 528
			input.mdy = 0 -- 529
			input.inside = false -- 530
		end -- 530
		input.uiX = input.mx -- 532
		input.uiY = input.my -- 533
		input.uiDx = 0 -- 534
		input.uiDy = 0 -- 535
		input.uiInside = false -- 536
		input.uiHeld = false -- 537
		input.uiPressed = false -- 538
		input.uiReleased = false -- 539
		input.uiRightPressed = false -- 540
		return -- 541
	end -- 541
	if touch.hasAim then -- 544
		input.mdx = touch.aimX - input.mx -- 545
		input.mdy = touch.aimY - input.my -- 546
		input.mx = touch.aimX -- 547
		input.my = touch.aimY -- 548
		input.inside = true -- 549
	else -- 549
		input.mdx = 0 -- 551
		input.mdy = 0 -- 552
		input.inside = false -- 553
	end -- 553
	input.uiDx = 0 -- 555
	input.uiDy = 0 -- 556
	input.uiInside = false -- 557
	input.uiHeld = false -- 558
	input.uiPressed = false -- 559
	input.uiReleased = false -- 560
	input.uiRightPressed = false -- 561
end -- 391
____exports.TARGET = { -- 565
	id = "handheld", -- 566
	supportsKbm = false, -- 567
	supportsTouch = true, -- 568
	supportsGamepad = true, -- 569
	supportsPortrait = false, -- 570
	defaultInputMode = "gamepad", -- 571
	supportedModes = {"gamepad", "touch"}, -- 572
	modePrefOrder = HANDHELD_MODE_PREFS, -- 573
	controlsGuideTabs = {{mode = "gamepad", label = "手柄"}, {mode = "touch", label = "触屏"}}, -- 574
	getPlatformCaps = function(self) -- 579
		local standaloneApk = isStandaloneApk() -- 580
		local cfg = getReleaseConfig() -- 581
		return { -- 582
			kind = "android", -- 583
			target = "handheld", -- 584
			isDesktop = false, -- 585
			isMobile = true, -- 586
			isWeb = false, -- 587
			isStandaloneAndroidApk = standaloneApk, -- 588
			canToggleFullscreen = false, -- 589
			canQuit = standaloneApk, -- 590
			hasBackButton = true, -- 591
			supportsHaptics = type(App.vibrate) == "function", -- 592
			needsAudioUnlock = false, -- 593
			isRelease = cfg ~= nil and cfg.isRelease == true, -- 594
			defaultInputMode = "gamepad" -- 595
		} -- 595
	end, -- 579
	canToggleFullscreen = function(self) -- 599
		return false -- 600
	end, -- 599
	canQuitApp = function(self) -- 603
		return isStandaloneApk() -- 604
	end, -- 603
	isReleaseMode = function(self) -- 607
		local cfg = getReleaseConfig() -- 608
		return cfg ~= nil and cfg.isRelease == true -- 609
	end, -- 607
	computeStageViewport = function(self, fullW, fullH) -- 612
		return computeLandscapeSafeViewport(fullW, fullH) -- 613
	end, -- 612
	triggerHaptics = function(self, seconds, enabled) -- 616
		triggerMobileHaptics(seconds, enabled) -- 617
	end, -- 616
	keyTagFor = function(self, action, mode, layout) -- 620
		return keyTagHandheld(action, mode, layout) -- 621
	end, -- 620
	adaptWorldKeyTag = function(self, rawKeyTag, mode, _layout) -- 624
		return adaptWorldKeyTagHandheld(rawKeyTag, mode) -- 625
	end, -- 624
	adaptHintSentence = function(self, text, mode, layout) -- 628
		return adaptHintSentenceHandheld(text, mode, layout) -- 629
	end, -- 628
	controlsGuideRows = function(self, tab) -- 632
		return tab == "touch" and GUIDE_TOUCH or GUIDE_GAMEPAD -- 633
	end, -- 632
	splashSkipHint = function(self, mode, layout) -- 636
		if mode == "touch" then -- 637
			return "轻触跳过" -- 637
		end -- 637
		return keyTagHandheld("confirm", "gamepad", layout) .. " / START  跳过" -- 638
	end, -- 636
	titleFooterHint = function(self, mode, layout) -- 641
		if mode == "touch" then -- 642
			return isStandaloneApk() and "轻触择项启程   ·   双击返回键退出" or "轻触择项启程   ·   支持手柄与触屏" -- 643
		end -- 643
		return ("左摇杆 / 十字键择项   ·   " .. keyTagHandheld("confirm", "gamepad", layout)) .. " 或点选启程" -- 647
	end, -- 641
	chapterFooterHint = function(self, mode, confirmTag) -- 650
		if mode == "touch" then -- 651
			return "轻触驿站预览   ·   再点或轻触入此卷章" -- 651
		end -- 651
		return ("摇杆/十字键选择   ·   " .. confirmTag) .. " 或点选进入" -- 652
	end, -- 650
	pauseFooterHint = function(self, mode, layout) -- 655
		if mode == "touch" then -- 656
			return "轻触确认   ·   点「继续游戏」续行" -- 656
		end -- 656
		return ((keyTagHandheld("back", "gamepad", layout) .. " / START 续行   ·   ") .. keyTagHandheld("confirm", "gamepad", layout)) .. " 确认" -- 657
	end, -- 655
	settingsFooterHint = function(self, mode, layout) -- 660
		if mode == "touch" then -- 661
			return "轻触任意条目切换   ·   设置自动保存" -- 661
		end -- 661
		return ((("左右或 " .. keyTagHandheld("confirm", "gamepad", layout)) .. " 切换   ·   ") .. keyTagHandheld("back", "gamepad", layout)) .. " 返回暂停" -- 662
	end, -- 660
	controlsFooterRightHint = function(self, mode) -- 665
		if mode == "touch" then -- 666
			return "轻触右上页签切图 · 暂歇菜单可调操控设置" -- 666
		end -- 666
		return "LB / RB 或左右切换键位图" -- 667
	end, -- 665
	epilogueFooterHint = function(self, mode, layout) -- 670
		if mode == "touch" then -- 671
			return "轻触任一入口继续" -- 671
		end -- 671
		return ((keyTagHandheld("confirm", "gamepad", layout) .. " 确认   ·   ") .. keyTagHandheld("back", "gamepad", layout)) .. " 返回标题" -- 672
	end, -- 670
	trialSubHint = function(self, mode, ended, seed) -- 675
		if mode == "touch" then -- 676
			return ("种子 " .. tostring(seed)) .. (ended and " · 点下方按钮再开或返回标题" or " · 点下方按钮继续/重开/返回标题") -- 677
		end -- 677
		return ("种子 " .. tostring(seed)) .. (ended and " · A 再开一局 · START 返回标题" or " · START 继续 · 长按BACK 重开 · Y 返回标题") -- 679
	end, -- 675
	settingsRows = function(self) -- 682
		return HANDHELD_SETTINGS_ROWS -- 683
	end, -- 682
	settingsPauseLabel = function(self, settings) -- 686
		local pref = settings.modePref -- 687
		return "操控设置 · " .. modePrefLabelOf(pref) -- 688
	end, -- 686
	settingsHeaderTitle = function(self) -- 691
		return "操控与声音" -- 692
	end, -- 691
	settingsHeaderSummary = function(self, activeMode) -- 695
		return ("当前模式：" .. inputModeLabelOf(activeMode)) .. " · 操控与四通道音量实时生效" -- 696
	end, -- 695
	settingsValueText = function(self, rowId, settings, activeMode) -- 699
		if rowId == "modePref" then -- 700
			local pref = settings.modePref -- 701
			return pref == "auto" and ("自动切换（" .. inputModeLabelOf(activeMode)) .. "）" or "锁定 · " .. modePrefLabelOf(pref) -- 702
		end -- 702
		if rowId == "aimAssist" then -- 706
			return settings.aimAssist and "开（触屏与手柄共用）" or "关" -- 706
		end -- 706
		if rowId == "gpLayout" then -- 707
			return layoutLabelOf(settings.gamepadLayout) -- 707
		end -- 707
		if rowId == "crouchMode" then -- 708
			return settings.crouchToggle and "点按切换" or "持续按住" -- 708
		end -- 708
		if rowId == "touchOpacity" then -- 709
			return opacityLabelOf(settings.touchOpacity) -- 709
		end -- 709
		if rowId == "touchScale" then -- 710
			return scaleLabelOf(settings.touchScale) -- 710
		end -- 710
		if rowId == "haptics" then -- 711
			return settings.haptics and "开" or "关" -- 711
		end -- 711
		return volumeSettingText(rowId, settings) -- 712
	end, -- 699
	applySettingsDelta = function(self, rowId, delta, settings, input) -- 715
		if rowId == "back" then -- 716
			return "back" -- 716
		end -- 716
		if rowId == "modePref" then -- 717
			input:cycleModePref(delta) -- 718
			return "control" -- 719
		end -- 719
		if rowId == "aimAssist" then -- 721
			settings.aimAssist = not settings.aimAssist -- 722
			saveControlSettings(settings) -- 723
			return "control" -- 724
		end -- 724
		if rowId == "gpLayout" then -- 726
			settings.gamepadLayout = settings.gamepadLayout == "xbox" and "nintendo" or "xbox" -- 727
			input.gamepadLayout = settings.gamepadLayout -- 728
			saveControlSettings(settings) -- 729
			return "control" -- 730
		end -- 730
		if rowId == "crouchMode" then -- 732
			settings.crouchToggle = not settings.crouchToggle -- 733
			saveControlSettings(settings) -- 734
			return "control" -- 735
		end -- 735
		if rowId == "touchOpacity" then -- 737
			settings.touchOpacity = nextStepValue(settings.touchOpacity, TOUCH_OPACITY_STEPS, delta) -- 738
			saveControlSettings(settings) -- 739
			return "control" -- 740
		end -- 740
		if rowId == "touchScale" then -- 742
			settings.touchScale = nextStepValue(settings.touchScale, TOUCH_SCALE_STEPS, delta) -- 743
			saveControlSettings(settings) -- 744
			return "control" -- 745
		end -- 745
		if rowId == "haptics" then -- 747
			settings.haptics = not settings.haptics -- 748
			saveControlSettings(settings) -- 749
			if settings.haptics then -- 750
				input:vibrate(0.018) -- 751
			end -- 751
			return "control" -- 753
		end -- 753
		if applyVolumeSetting(rowId, delta, settings) then -- 755
			return "audio" -- 755
		end -- 755
		return "none" -- 756
	end, -- 715
	createDriver = function(self, settings) -- 759
		return __TS__New(HandheldInputDriver, settings) -- 760
	end -- 759
} -- 759
return ____exports -- 759
