-- [ts]: control_prompts.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local ____exports = {} -- 1
local ____depth = require("Script.watch.depth") -- 10
local inReachDepth = ____depth.inReachDepth -- 10
local ____play = require("Script.watch.play") -- 11
local GATE_COUNT_END = ____play.GATE_COUNT_END -- 11
--- 根据当前输入模式与手柄布局，返回统一按键微标文案。
function ____exports.keyTagFor(action, mode, layout) -- 37
	if layout == nil then -- 40
		layout = "xbox" -- 40
	end -- 40
	if mode == "gamepad" then -- 42
		local confirmBtn = layout == "nintendo" and "B" or "A" -- 43
		local backBtn = layout == "nintendo" and "A" or "B" -- 44
		if action == "interact" then -- 45
			return "Y / RB" -- 45
		end -- 45
		if action == "jump" then -- 46
			return "A" -- 46
		end -- 46
		if action == "crouch" then -- 47
			return "B" -- 47
		end -- 47
		if action == "cover" then -- 48
			return "LT / LB" -- 48
		end -- 48
		if action == "fire" then -- 49
			return "RT / X" -- 49
		end -- 49
		if action == "aim" then -- 50
			return "RT / X" -- 50
		end -- 50
		if action == "pause" then -- 51
			return "START" -- 51
		end -- 51
		if action == "retry" then -- 52
			return "长按 BACK" -- 52
		end -- 52
		if action == "confirm" then -- 53
			return confirmBtn -- 53
		end -- 53
		if action == "back" then -- 54
			return backBtn -- 54
		end -- 54
		return "L3" -- 55
	end -- 55
	if mode == "touch" then -- 57
		if action == "interact" then -- 58
			return "点按" -- 58
		end -- 58
		if action == "jump" then -- 59
			return "跳/滚" -- 59
		end -- 59
		if action == "crouch" then -- 60
			return "蹲伏" -- 60
		end -- 60
		if action == "cover" then -- 61
			return "掩体" -- 61
		end -- 61
		if action == "fire" then -- 62
			return "开火" -- 62
		end -- 62
		if action == "aim" then -- 63
			return "拖投瓶" -- 63
		end -- 63
		if action == "pause" then -- 64
			return "暂歇" -- 64
		end -- 64
		if action == "retry" then -- 65
			return "重试" -- 65
		end -- 65
		if action == "confirm" then -- 66
			return "点选" -- 66
		end -- 66
		if action == "back" then -- 67
			return "返回" -- 67
		end -- 67
		return "穿梭" -- 68
	end -- 68
	if action == "interact" then -- 70
		return "E" -- 70
	end -- 70
	if action == "jump" then -- 71
		return "SPACE" -- 71
	end -- 71
	if action == "crouch" then -- 72
		return "CTRL" -- 72
	end -- 72
	if action == "cover" then -- 73
		return "SHIFT" -- 73
	end -- 73
	if action == "fire" then -- 74
		return "左键" -- 74
	end -- 74
	if action == "aim" then -- 75
		return "F" -- 75
	end -- 75
	if action == "pause" then -- 76
		return "ESC" -- 76
	end -- 76
	if action == "retry" then -- 77
		return "R" -- 77
	end -- 77
	if action == "confirm" then -- 78
		return "ENTER" -- 78
	end -- 78
	if action == "back" then -- 79
		return "ESC" -- 79
	end -- 79
	return "T" -- 80
end -- 37
--- 将世界提示的原始键鼠键帽文案转换为当前输入模式的对应键标。
function ____exports.adaptWorldKeyTag(rawKeyTag, mode, _layout) -- 84
	if _layout == nil then -- 87
		_layout = "xbox" -- 87
	end -- 87
	if mode == "kbm" then -- 89
		return rawKeyTag -- 89
	end -- 89
	if mode == "gamepad" then -- 90
		if rawKeyTag == "E" then -- 91
			return "Y" -- 91
		end -- 91
		if rawKeyTag == "按住 E" then -- 92
			return "按住 Y" -- 92
		end -- 92
		if rawKeyTag == "松开再按住 E" then -- 93
			return "松开再按 Y" -- 93
		end -- 93
		if rawKeyTag == "按住 E + D" then -- 94
			return "按住 Y + 右" -- 94
		end -- 94
		if rawKeyTag == "E 握柄 + D" then -- 95
			return "Y 握柄 + 右" -- 95
		end -- 95
		if rawKeyTag == "F" or rawKeyTag == "左键" then -- 96
			return "RT / X" -- 96
		end -- 96
		if rawKeyTag == "按住 F" then -- 97
			return "按住 RT" -- 97
		end -- 97
		if rawKeyTag == "松开 F" then -- 98
			return "松开 RT" -- 98
		end -- 98
		if rawKeyTag == "按住 Ctrl" then -- 99
			return "按住 B" -- 99
		end -- 99
		if rawKeyTag == "按住 Shift" then -- 100
			return "按住 LT" -- 100
		end -- 100
		if rawKeyTag == "连线" then -- 101
			return "摇杆/触屏连线" -- 101
		end -- 101
		if rawKeyTag == "→" then -- 102
			return "右推摇杆" -- 102
		end -- 102
		return rawKeyTag -- 103
	end -- 103
	if rawKeyTag == "E" then -- 106
		return "轻触" -- 106
	end -- 106
	if rawKeyTag == "按住 E" then -- 107
		return "长按交互" -- 107
	end -- 107
	if rawKeyTag == "松开再按住 E" then -- 108
		return "松开再长按" -- 108
	end -- 108
	if rawKeyTag == "按住 E + D" or rawKeyTag == "E 握柄 + D" then -- 109
		return "点推车+摇杆" -- 109
	end -- 109
	if rawKeyTag == "F" or rawKeyTag == "左键" then -- 110
		return "开火" -- 110
	end -- 110
	if rawKeyTag == "按住 F" then -- 111
		return "拖投瓶" -- 111
	end -- 111
	if rawKeyTag == "松开 F" then -- 112
		return "松手投" -- 112
	end -- 112
	if rawKeyTag == "按住 Ctrl" then -- 113
		return "点蹲伏" -- 113
	end -- 113
	if rawKeyTag == "按住 Shift" then -- 114
		return "点掩体" -- 114
	end -- 114
	if rawKeyTag == "连线" then -- 115
		return "一笔划连" -- 115
	end -- 115
	return rawKeyTag -- 116
end -- 84
--- 将开启「按键辅助」时的叙事/HUD 提示句中的键鼠键名替换为当前输入模式键名。
function ____exports.adaptHintSentence(text, mode, layout) -- 120
	if layout == nil then -- 123
		layout = "xbox" -- 123
	end -- 123
	if mode == "kbm" or text == "" then -- 125
		return text -- 125
	end -- 125
	if mode == "gamepad" then -- 126
		local backBtn = layout == "nintendo" and "A" or "B" -- 127
		return table.concat( -- 128
			__TS__StringSplit( -- 128
				table.concat( -- 128
					__TS__StringSplit( -- 128
						table.concat( -- 128
							__TS__StringSplit( -- 128
								table.concat( -- 128
									__TS__StringSplit( -- 128
										table.concat( -- 128
											__TS__StringSplit( -- 128
												table.concat( -- 128
													__TS__StringSplit( -- 128
														table.concat( -- 128
															__TS__StringSplit( -- 128
																table.concat( -- 128
																	__TS__StringSplit( -- 128
																		table.concat( -- 128
																			__TS__StringSplit( -- 128
																				table.concat( -- 128
																					__TS__StringSplit( -- 128
																						table.concat( -- 128
																							__TS__StringSplit( -- 128
																								table.concat( -- 128
																									__TS__StringSplit( -- 128
																										table.concat( -- 128
																											__TS__StringSplit( -- 128
																												table.concat( -- 128
																													__TS__StringSplit( -- 128
																														table.concat( -- 128
																															__TS__StringSplit( -- 128
																																table.concat( -- 128
																																	__TS__StringSplit( -- 128
																																		table.concat( -- 128
																																			__TS__StringSplit( -- 128
																																				table.concat( -- 128
																																					__TS__StringSplit( -- 128
																																						table.concat( -- 128
																																							__TS__StringSplit( -- 128
																																								table.concat( -- 128
																																									__TS__StringSplit( -- 128
																																										table.concat( -- 128
																																											__TS__StringSplit(text, "[SHIFT]"), -- 128
																																											"[LT/LB]" -- 129
																																										), -- 129
																																										"[CTRL]" -- 130
																																									), -- 130
																																									"[B]" -- 130
																																								), -- 130
																																								"[E]+[D]" -- 131
																																							), -- 131
																																							"[Y]+右推" -- 131
																																						), -- 131
																																						"[E]" -- 132
																																					), -- 132
																																					"[Y]" -- 132
																																				), -- 132
																																				"[F]" -- 133
																																			), -- 133
																																			"[RT/X]" -- 133
																																		), -- 133
																																		"[SPACE]" -- 134
																																	), -- 134
																																	"[A]" -- 134
																																), -- 134
																																"[W/S]" -- 135
																															), -- 135
																															"左摇杆上下" -- 135
																														), -- 135
																														"[A/D]" -- 136
																													), -- 136
																													"左摇杆左右" -- 136
																												), -- 136
																												"[W]" -- 137
																											), -- 137
																											"左摇杆向上" -- 137
																										), -- 137
																										"[S]" -- 138
																									), -- 138
																									"左摇杆向下" -- 138
																								), -- 138
																								"[ESC]" -- 139
																							), -- 139
																							"[START]" -- 139
																						), -- 139
																						"[R]" -- 140
																					), -- 140
																					"长按 [BACK]" -- 140
																				), -- 140
																				"鼠标瞄准，左键发射火铳" -- 141
																			), -- 141
																			"右摇杆瞄准，按 [RT/X] 发射火铳" -- 141
																		), -- 141
																		"左键先手击倒" -- 142
																	), -- 142
																	"按 [RT/X] 先手击倒" -- 142
																), -- 142
																"左键发射火铳" -- 143
															), -- 143
															"按 [RT/X] 发射火铳" -- 143
														), -- 143
														"左键发铳" -- 144
													), -- 144
													"按 [RT/X] 发铳" -- 144
												), -- 144
												"按 E 再次启程" -- 145
											), -- 145
											"按 Y 再次启程" -- 145
										), -- 145
										"按住 E" -- 146
									), -- 146
									"按住 Y" -- 146
								), -- 146
								"方向键" -- 147
							), -- 147
							"左摇杆" -- 147
						), -- 147
						"Esc 暂歇" -- 148
					), -- 148
					"START 暂歇" -- 148
				), -- 148
				"返回" -- 149
			), -- 149
			("按 " .. backBtn) .. " 返回" or "," -- 149
		) -- 149
	end -- 149
	return table.concat( -- 152
		__TS__StringSplit( -- 152
			table.concat( -- 152
				__TS__StringSplit( -- 152
					table.concat( -- 152
						__TS__StringSplit( -- 152
							table.concat( -- 152
								__TS__StringSplit( -- 152
									table.concat( -- 152
										__TS__StringSplit( -- 152
											table.concat( -- 152
												__TS__StringSplit( -- 152
													table.concat( -- 152
														__TS__StringSplit( -- 152
															table.concat( -- 152
																__TS__StringSplit( -- 152
																	table.concat( -- 152
																		__TS__StringSplit( -- 152
																			table.concat( -- 152
																				__TS__StringSplit( -- 152
																					table.concat( -- 152
																						__TS__StringSplit( -- 152
																							table.concat( -- 152
																								__TS__StringSplit( -- 152
																									table.concat( -- 152
																										__TS__StringSplit( -- 152
																											table.concat( -- 152
																												__TS__StringSplit( -- 152
																													table.concat( -- 152
																														__TS__StringSplit( -- 152
																															table.concat( -- 152
																																__TS__StringSplit( -- 152
																																	table.concat( -- 152
																																		__TS__StringSplit( -- 152
																																			table.concat( -- 152
																																				__TS__StringSplit( -- 152
																																					table.concat( -- 152
																																						__TS__StringSplit( -- 152
																																							table.concat( -- 152
																																								__TS__StringSplit( -- 152
																																									table.concat( -- 152
																																										__TS__StringSplit( -- 152
																																											table.concat( -- 152
																																												__TS__StringSplit( -- 152
																																													table.concat( -- 152
																																														__TS__StringSplit( -- 152
																																															table.concat( -- 152
																																																__TS__StringSplit( -- 152
																																																	table.concat( -- 152
																																																		__TS__StringSplit( -- 152
																																																			table.concat( -- 152
																																																				__TS__StringSplit( -- 152
																																																					table.concat( -- 152
																																																						__TS__StringSplit( -- 152
																																																							table.concat( -- 152
																																																								__TS__StringSplit( -- 152
																																																									table.concat( -- 152
																																																										__TS__StringSplit( -- 152
																																																											table.concat( -- 152
																																																												__TS__StringSplit( -- 152
																																																													table.concat( -- 152
																																																														__TS__StringSplit(text, "按住 [E]+[D]"), -- 152
																																																														"点按推/拉车并推摇杆" -- 153
																																																													), -- 153
																																																													"[E]+[D]" -- 154
																																																												), -- 154
																																																												"推/拉车并推摇杆" -- 154
																																																											), -- 154
																																																											"速按 [CTRL]" -- 155
																																																										), -- 155
																																																										"点按「蹲伏」" -- 155
																																																									), -- 155
																																																									"按住 [CTRL]" -- 156
																																																								), -- 156
																																																								"点按「蹲伏」" -- 156
																																																							), -- 156
																																																							"按 [CTRL]" -- 157
																																																						), -- 157
																																																						"点按「蹲伏」" -- 157
																																																					), -- 157
																																																					"[CTRL]" -- 158
																																																				), -- 158
																																																				"「蹲伏」" -- 158
																																																			), -- 158
																																																			"按住 [SHIFT]" -- 159
																																																		), -- 159
																																																		"点按「轻步/掩体」" -- 159
																																																	), -- 159
																																																	"[SHIFT]" -- 160
																																																), -- 160
																																																"「轻步/掩体」" -- 160
																																															), -- 160
																																															"按住 [F]" -- 161
																																														), -- 161
																																														"按住「投瓶」拖拽" -- 161
																																													), -- 161
																																													"[F]" -- 162
																																												), -- 162
																																												"「投瓶」" -- 162
																																											), -- 162
																																											"按住 E" -- 163
																																										), -- 163
																																										"长按「交互」" -- 163
																																									), -- 163
																																									"按 [E]" -- 164
																																								), -- 164
																																								"点按「交互」" -- 164
																																							), -- 164
																																							"[E]" -- 165
																																						), -- 165
																																						"「交互」" -- 165
																																					), -- 165
																																					"方向键" -- 166
																																				), -- 166
																																				"左下摇杆" -- 166
																																			), -- 166
																																			"按 [ESC]" -- 167
																																		), -- 167
																																		"轻触右上「暂歇」" -- 167
																																	), -- 167
																																	"[ESC]" -- 168
																																), -- 168
																																"右上「暂歇」" -- 168
																															), -- 168
																															"按 [SPACE]" -- 169
																														), -- 169
																														"点按「翻滚/跳跃」" -- 169
																													), -- 169
																													"[SPACE]" -- 170
																												), -- 170
																												"「翻滚/跳跃」" -- 170
																											), -- 170
																											"按 [R]" -- 171
																										), -- 171
																										"在暂歇菜单重试" -- 171
																									), -- 171
																									"[A/D]" -- 172
																								), -- 172
																								"左下摇杆" -- 172
																							), -- 172
																							"[W/S]" -- 173
																						), -- 173
																						"摇杆上下" -- 173
																					), -- 173
																					"[W]" -- 174
																				), -- 174
																				"摇杆向上" -- 174
																			), -- 174
																			"[S]" -- 175
																		), -- 175
																		"摇杆向下" -- 175
																	), -- 175
																	"鼠标瞄准，左键发射火铳" -- 176
																), -- 176
																"点屏或拖「开火」发射火铳" -- 176
															), -- 176
															"左键先手击倒" -- 177
														), -- 177
														"点屏或「开火」先手击倒" -- 177
													), -- 177
													"左键发射火铳" -- 178
												), -- 178
												"点屏或「开火」发射火铳" -- 178
											), -- 178
											"左键发铳" -- 179
										), -- 179
										"点屏或「开火」发铳" -- 179
									), -- 179
									"左键" -- 180
								), -- 180
								"点屏或「开火」" -- 180
							), -- 180
							"鼠标" -- 181
						), -- 181
						"触屏" -- 181
					), -- 181
					"按 E 再次启程" -- 182
				), -- 182
				"轻触屏幕再次启程" -- 182
			), -- 182
			"Esc 暂歇" -- 183
		), -- 183
		"轻触右上暂歇" -- 183
	) -- 183
end -- 120
--- 「执器要诀」三页统一键位对照表（周戍 / 小满，覆盖键鼠、手柄、触屏全部主流操控）。
function ____exports.controlsGuideRows(tab) -- 187
	if tab == "gamepad" then -- 192
		return {subtitle = "手柄操作说明 · 全平台通用", soldierRows = { -- 193
			{"左摇杆 / 十字键", "左右、前后纵深移动"}, -- 196
			{"右摇杆 + RT / X", "360° 瞄准与发射火铳（含轻磁吸）"}, -- 197
			{"按住 LT / LB", "贴靠柜台 / 街垒挡下铅丸"}, -- 198
			{"A 键", "平地翻滚 / 靠近矮柜翻越"}, -- 199
			{"Y / RB 键", "递物 / 轻敲安抚 / 按住推车"}, -- 200
			{"摇杆直推 / 触屏", "慢时连线换弹 · B 键清空重画"} -- 201
		}, childRows = { -- 203
			{"左摇杆轻推", "内圈轻步慢走（LT/LB 亦可）"}, -- 204
			{"B 键", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 205
			{"A 键", "跳跃攀上石阶与矮台"}, -- 206
			{"Y / RB 键", "拾瓶 / 敲塔门 / 握柄拉车"}, -- 207
			{"RT/X 按住→松开", "右摇杆调落点投瓶 · B 取消"}, -- 208
			{"START / BACK", "暂歇 / 长按重试 · L3 切神器"} -- 209
		}} -- 209
	end -- 209
	if tab == "touch" then -- 213
		return {subtitle = "触屏操作说明 · 横屏全屏 / 竖屏掌机台", soldierRows = { -- 214
			{"左水墨摇杆", "全向走位与里外道切线"}, -- 217
			{"点屏 / 开火钮", "直点射击或拖住开火钮 360° 精瞄"}, -- 218
			{"掩体开关", "轻点贴靠掩体，再点或翻滚离掩"}, -- 219
			{"翻滚 / 翻越", "平地翻滚，贴近矮柜自动翻越"}, -- 220
			{"交互 / 推车", "点推车自动锁握柄，长按牵手交物"}, -- 221
			{"换弹九宫格", "单指一笔滑连至右上，点重画清空"} -- 222
		}, childRows = { -- 224
			{"摇杆内圈 / 轻步", "轻推内圈或点轻步压低脚步声"}, -- 225
			{"蹲伏开关", "点按蹲下钻桌穿拱，点跳顺滑起身"}, -- 226
			{"跳跃钮", "攀上石阶、红布车与矮台"}, -- 227
			{"投瓶拖瞄", "按住投瓶拖向砖地，拖回取消圈放弃"}, -- 228
			{"交互 / 拉车", "拾瓶、敲塔门、点拉车锁定握柄"}, -- 229
			{"右上暂歇 / 竖屏", "顶栏随时暂歇，竖屏自动展掌机台"} -- 230
		}} -- 230
	end -- 230
	return {subtitle = "键鼠操作说明 · 全平台通用", soldierRows = { -- 234
		{"WASD / 方向键", "左右、前后纵深自由移动"}, -- 237
		{"鼠标 + 左键 / Q", "瞄准发射火铳 · Q 随时开换弹盘"}, -- 238
		{"按住 SHIFT / SPACE", "贴靠掩体挡弹 · 平地翻滚或翻越"}, -- 239
		{"E / 1·2·3", "交互推车工台 · 数字键选护送本领"}, -- 240
		{"拖线 / 方向+回车", "慢时 3×3 换弹盘 · 右键/退格重画"}, -- 241
		{"ESC / R / T", "暂歇菜单 / 重试检查点 / 切神器"} -- 242
	}, childRows = { -- 244
		{"A / D · ← / →", "左右潜行"}, -- 245
		{"按住 SHIFT", "轻步慢走（压低脚步声）"}, -- 246
		{"按住 S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 247
		{"SPACE", "跳跃攀上石阶与矮台"}, -- 248
		{"E", "拾瓶 / 敲塔门 / 按住+D 拉车"}, -- 249
		{"F 按住→松开", "瞄准砖地/铁盆投瓶 · 右键取消"} -- 250
	}} -- 250
end -- 187
--- 判断当前房间阶段是否处于电影过场阻塞期（需隐藏战斗虚拟按钮）。
function ____exports.isCutsceneBlockingPlay(p) -- 256
	local rk = p.room.key -- 257
	local ph = p.phase -- 258
	if rk == "prologue" and (ph == "prologue-wake" or ph == "prologue-shadow" or ph == "prologue-hide" or ph == "prologue-give" or ph == "prologue-well") then -- 259
		return true -- 262
	end -- 262
	if rk == "gate" then -- 264
		if ph == "gate-hand" then -- 265
			return true -- 265
		end -- 265
		if ph == "gate-count" and p.countTick < GATE_COUNT_END then -- 266
			return true -- 266
		end -- 266
	end -- 266
	if rk == "tower" and (ph == "tower-knock" or ph == "tower-given" or ph == "tower-end") then -- 268
		return true -- 269
	end -- 269
	if rk == "museum" and ph == "museum-knock" then -- 271
		return true -- 272
	end -- 272
	return false -- 274
end -- 256
--- 推导情境交互按钮文案与长按进度（供触控大钮与引导共用）。
function ____exports.deriveInteractActionMeta(p, prompt, cartNearby, cartLatched) -- 278
	if cartNearby then -- 284
		if cartLatched or p.gripping then -- 285
			return { -- 286
				label = "松手", -- 286
				subLabel = "推车中", -- 286
				urgent = false, -- 286
				progress = 0, -- 286
				available = true -- 286
			} -- 286
		end -- 286
		return { -- 288
			label = p.room.key == "outside" and "拉车" or "推车", -- 289
			subLabel = "点按锁定", -- 290
			urgent = true, -- 291
			progress = 0, -- 292
			available = true -- 293
		} -- 293
	end -- 293
	if p.phase == "gate-wait" then -- 297
		local prog = math.max( -- 298
			0, -- 298
			math.min( -- 298
				1, -- 298
				p.handTicks / math.max(1, p.handNeedTicks) -- 298
			) -- 298
		) -- 298
		return { -- 299
			label = "牵手", -- 299
			subLabel = "长按", -- 299
			urgent = true, -- 299
			progress = prog, -- 299
			available = true -- 299
		} -- 299
	end -- 299
	if p.phase == "tower-desk" then -- 301
		local prog = math.max( -- 302
			0, -- 302
			math.min(1, p.deskHold / 36) -- 302
		) -- 302
		return { -- 303
			label = "交物", -- 303
			subLabel = "长按", -- 303
			urgent = true, -- 303
			progress = prog, -- 303
			available = true -- 303
		} -- 303
	end -- 303
	if p.craftT > 0 then -- 305
		return { -- 306
			label = "削楔", -- 306
			subLabel = "长按", -- 306
			urgent = true, -- 306
			progress = math.min(1, p.craftT / 30), -- 306
			available = true -- 306
		} -- 306
	end -- 306
	if prompt ~= nil then -- 309
		local kt = prompt.keyTag -- 310
		if (string.find(kt, "E", nil, true) or 0) - 1 >= 0 then -- 311
			local short = "交互" -- 312
			if (string.find(prompt.label, "指南针", nil, true) or 0) - 1 >= 0 or (string.find(prompt.label, "针套", nil, true) or 0) - 1 >= 0 then -- 313
				short = "递物" -- 313
			elseif (string.find(prompt.label, "安抚", nil, true) or 0) - 1 >= 0 then -- 314
				short = "安抚" -- 314
			elseif (string.find(prompt.label, "守门", nil, true) or 0) - 1 >= 0 then -- 315
				short = "守门" -- 315
			elseif (string.find(prompt.label, "送小满", nil, true) or 0) - 1 >= 0 then -- 316
				short = "送别" -- 316
			elseif (string.find(prompt.label, "工台", nil, true) or 0) - 1 >= 0 then -- 317
				short = "工台" -- 317
			elseif (string.find(prompt.label, "窗板", nil, true) or 0) - 1 >= 0 then -- 318
				short = "窗板" -- 318
			elseif (string.find(prompt.label, "木帘", nil, true) or 0) - 1 >= 0 then -- 319
				short = "木帘" -- 319
			elseif (string.find(prompt.label, "门锁", nil, true) or 0) - 1 >= 0 then -- 320
				short = "抬锁" -- 320
			elseif (string.find(prompt.label, "瓶", nil, true) or 0) - 1 >= 0 then -- 321
				short = "拾瓶" -- 321
			elseif (string.find(prompt.label, "收枪", nil, true) or 0) - 1 >= 0 then -- 322
				short = "收枪" -- 322
			elseif (string.find(prompt.label, "灯", nil, true) or 0) - 1 >= 0 then -- 323
				short = "转灯" -- 323
			elseif (string.find(prompt.label, "敲", nil, true) or 0) - 1 >= 0 then -- 324
				short = "轻敲" -- 324
			end -- 324
			return { -- 325
				label = short, -- 326
				subLabel = (string.find(kt, "按住", nil, true) or 0) - 1 >= 0 and "长按" or nil, -- 327
				urgent = prompt.urgent, -- 328
				progress = prompt.progress or 0, -- 329
				available = true -- 330
			} -- 330
		end -- 330
	end -- 330
	local nearWell = math.abs(p.player.x - (p.ox + p.wellX)) <= 44 and p.player.y < 20 and inReachDepth(p.player.depth, 0) -- 335
	if p.room.key == "prologue" and p.phase == "prologue-wait" and nearWell and (p.wellOpen or p.archive.artifactOwned and not p.archive.museumSeen) then -- 337
		return {label = p.wellOpen and "取器" or "入馆", urgent = true, progress = 0, available = true} -- 339
	end -- 339
	if not p.childMode and p.run.inventory.scrap > 0 and p.run.inventory.wedge < 3 and prompt == nil then -- 347
		return { -- 348
			label = "削楔", -- 348
			subLabel = "长按", -- 348
			urgent = false, -- 348
			progress = 0, -- 348
			available = true -- 348
		} -- 348
	end -- 348
	return {label = "交互", urgent = false, progress = 0, available = false} -- 351
end -- 278
return ____exports -- 278
