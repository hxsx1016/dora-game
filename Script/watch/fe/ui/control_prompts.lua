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
	if layout == nil then -- 37
		layout = "xbox" -- 40
	end -- 40
	if mode == "gamepad" then -- 40
		local confirmBtn = layout == "nintendo" and "B" or "A" -- 43
		local backBtn = layout == "nintendo" and "A" or "B" -- 44
		if action == "interact" then -- 44
			return "Y / RB" -- 45
		end -- 45
		if action == "jump" then -- 45
			return "A" -- 46
		end -- 46
		if action == "crouch" then -- 46
			return "B" -- 47
		end -- 47
		if action == "cover" then -- 47
			return "LT / LB" -- 48
		end -- 48
		if action == "fire" then -- 48
			return "RT / X" -- 49
		end -- 49
		if action == "aim" then -- 49
			return "RT / X" -- 50
		end -- 50
		if action == "pause" then -- 50
			return "START" -- 51
		end -- 51
		if action == "retry" then -- 51
			return "长按 BACK" -- 52
		end -- 52
		if action == "confirm" then -- 52
			return confirmBtn -- 53
		end -- 53
		if action == "back" then -- 53
			return backBtn -- 54
		end -- 54
		return "L3" -- 55
	end -- 55
	if mode == "touch" then -- 55
		if action == "interact" then -- 55
			return "点按" -- 58
		end -- 58
		if action == "jump" then -- 58
			return "跳/滚" -- 59
		end -- 59
		if action == "crouch" then -- 59
			return "蹲伏" -- 60
		end -- 60
		if action == "cover" then -- 60
			return "掩体" -- 61
		end -- 61
		if action == "fire" then -- 61
			return "开火" -- 62
		end -- 62
		if action == "aim" then -- 62
			return "拖投瓶" -- 63
		end -- 63
		if action == "pause" then -- 63
			return "暂歇" -- 64
		end -- 64
		if action == "retry" then -- 64
			return "重试" -- 65
		end -- 65
		if action == "confirm" then -- 65
			return "点选" -- 66
		end -- 66
		if action == "back" then -- 66
			return "返回" -- 67
		end -- 67
		return "穿梭" -- 68
	end -- 68
	if action == "interact" then -- 68
		return "E" -- 70
	end -- 70
	if action == "jump" then -- 70
		return "SPACE" -- 71
	end -- 71
	if action == "crouch" then -- 71
		return "CTRL" -- 72
	end -- 72
	if action == "cover" then -- 72
		return "SHIFT" -- 73
	end -- 73
	if action == "fire" then -- 73
		return "左键" -- 74
	end -- 74
	if action == "aim" then -- 74
		return "F" -- 75
	end -- 75
	if action == "pause" then -- 75
		return "ESC" -- 76
	end -- 76
	if action == "retry" then -- 76
		return "R" -- 77
	end -- 77
	if action == "confirm" then -- 77
		return "ENTER" -- 78
	end -- 78
	if action == "back" then -- 78
		return "ESC" -- 79
	end -- 79
	return "T" -- 80
end -- 37
--- 将世界提示的原始键鼠键帽文案转换为当前输入模式的对应键标。
function ____exports.adaptWorldKeyTag(rawKeyTag, mode, _layout) -- 84
	if _layout == nil then -- 84
		_layout = "xbox" -- 87
	end -- 87
	if mode == "kbm" then -- 87
		return rawKeyTag -- 89
	end -- 89
	if mode == "gamepad" then -- 89
		if rawKeyTag == "E" then -- 89
			return "Y" -- 91
		end -- 91
		if rawKeyTag == "按住 E" then -- 91
			return "按住 Y" -- 92
		end -- 92
		if rawKeyTag == "松开再按住 E" then -- 92
			return "松开再按 Y" -- 93
		end -- 93
		if rawKeyTag == "按住 E + D" then -- 93
			return "按住 Y + 右" -- 94
		end -- 94
		if rawKeyTag == "E 握柄 + D" then -- 94
			return "Y 握柄 + 右" -- 95
		end -- 95
		if rawKeyTag == "F" then -- 95
			return "RT / X" -- 96
		end -- 96
		if rawKeyTag == "按住 F" then -- 96
			return "按住 RT" -- 97
		end -- 97
		if rawKeyTag == "松开 F" then -- 97
			return "松开 RT" -- 98
		end -- 98
		if rawKeyTag == "按住 Ctrl" then -- 98
			return "按住 B" -- 99
		end -- 99
		if rawKeyTag == "按住 Shift" then -- 99
			return "按住 LT" -- 100
		end -- 100
		if rawKeyTag == "连线" then -- 100
			return "摇杆/触屏连线" -- 101
		end -- 101
		if rawKeyTag == "→" then -- 101
			return "右推摇杆" -- 102
		end -- 102
		return rawKeyTag -- 103
	end -- 103
	if rawKeyTag == "E" then -- 103
		return "轻触" -- 106
	end -- 106
	if rawKeyTag == "按住 E" then -- 106
		return "长按交互" -- 107
	end -- 107
	if rawKeyTag == "松开再按住 E" then -- 107
		return "松开再长按" -- 108
	end -- 108
	if rawKeyTag == "按住 E + D" or rawKeyTag == "E 握柄 + D" then -- 108
		return "点推车+摇杆" -- 109
	end -- 109
	if rawKeyTag == "F" then -- 109
		return "开火" -- 110
	end -- 110
	if rawKeyTag == "按住 F" then -- 110
		return "拖投瓶" -- 111
	end -- 111
	if rawKeyTag == "松开 F" then -- 111
		return "松手投" -- 112
	end -- 112
	if rawKeyTag == "按住 Ctrl" then -- 112
		return "点蹲伏" -- 113
	end -- 113
	if rawKeyTag == "按住 Shift" then -- 113
		return "点掩体" -- 114
	end -- 114
	if rawKeyTag == "连线" then -- 114
		return "一笔划连" -- 115
	end -- 115
	return rawKeyTag -- 116
end -- 84
--- 将开启「按键辅助」时的叙事/HUD 提示句中的键鼠键名替换为当前输入模式键名。
function ____exports.adaptHintSentence(text, mode, layout) -- 120
	if layout == nil then -- 120
		layout = "xbox" -- 123
	end -- 123
	if mode == "kbm" or text == "" then -- 123
		return text -- 125
	end -- 125
	if mode == "gamepad" then -- 125
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
						"Esc 暂歇" -- 146
					), -- 146
					"START 暂歇" -- 146
				), -- 146
				"返回" -- 147
			), -- 147
			("按 " .. backBtn) .. " 返回" or "," -- 147
		) -- 147
	end -- 147
	return table.concat( -- 150
		__TS__StringSplit( -- 150
			table.concat( -- 150
				__TS__StringSplit( -- 150
					table.concat( -- 150
						__TS__StringSplit( -- 150
							table.concat( -- 150
								__TS__StringSplit( -- 150
									table.concat( -- 150
										__TS__StringSplit( -- 150
											table.concat( -- 150
												__TS__StringSplit( -- 150
													table.concat( -- 150
														__TS__StringSplit( -- 150
															table.concat( -- 150
																__TS__StringSplit( -- 150
																	table.concat( -- 150
																		__TS__StringSplit( -- 150
																			table.concat( -- 150
																				__TS__StringSplit( -- 150
																					table.concat( -- 150
																						__TS__StringSplit( -- 150
																							table.concat( -- 150
																								__TS__StringSplit( -- 150
																									table.concat( -- 150
																										__TS__StringSplit( -- 150
																											table.concat( -- 150
																												__TS__StringSplit( -- 150
																													table.concat( -- 150
																														__TS__StringSplit( -- 150
																															table.concat( -- 150
																																__TS__StringSplit( -- 150
																																	table.concat( -- 150
																																		__TS__StringSplit( -- 150
																																			table.concat( -- 150
																																				__TS__StringSplit( -- 150
																																					table.concat( -- 150
																																						__TS__StringSplit( -- 150
																																							table.concat( -- 150
																																								__TS__StringSplit( -- 150
																																									table.concat( -- 150
																																										__TS__StringSplit( -- 150
																																											table.concat( -- 150
																																												__TS__StringSplit( -- 150
																																													table.concat( -- 150
																																														__TS__StringSplit( -- 150
																																															table.concat( -- 150
																																																__TS__StringSplit( -- 150
																																																	table.concat( -- 150
																																																		__TS__StringSplit( -- 150
																																																			table.concat( -- 150
																																																				__TS__StringSplit( -- 150
																																																					table.concat( -- 150
																																																						__TS__StringSplit( -- 150
																																																							table.concat( -- 150
																																																								__TS__StringSplit( -- 150
																																																									table.concat( -- 150
																																																										__TS__StringSplit(text, "按住 [E]+[D]"), -- 150
																																																										"点按推/拉车并推摇杆" -- 151
																																																									), -- 151
																																																									"[E]+[D]" -- 152
																																																								), -- 152
																																																								"推/拉车并推摇杆" -- 152
																																																							), -- 152
																																																							"速按 [CTRL]" -- 153
																																																						), -- 153
																																																						"点按「蹲伏」" -- 153
																																																					), -- 153
																																																					"按住 [CTRL]" -- 154
																																																				), -- 154
																																																				"点按「蹲伏」" -- 154
																																																			), -- 154
																																																			"按 [CTRL]" -- 155
																																																		), -- 155
																																																		"点按「蹲伏」" -- 155
																																																	), -- 155
																																																	"[CTRL]" -- 156
																																																), -- 156
																																																"「蹲伏」" -- 156
																																															), -- 156
																																															"按住 [SHIFT]" -- 157
																																														), -- 157
																																														"点按「轻步/掩体」" -- 157
																																													), -- 157
																																													"[SHIFT]" -- 158
																																												), -- 158
																																												"「轻步/掩体」" -- 158
																																											), -- 158
																																											"按住 [F]" -- 159
																																										), -- 159
																																										"按住「投瓶」拖拽" -- 159
																																									), -- 159
																																									"[F]" -- 160
																																								), -- 160
																																								"「投瓶」" -- 160
																																							), -- 160
																																							"按 [E]" -- 161
																																						), -- 161
																																						"点按「交互」" -- 161
																																					), -- 161
																																					"[E]" -- 162
																																				), -- 162
																																				"「交互」" -- 162
																																			), -- 162
																																			"按 [ESC]" -- 163
																																		), -- 163
																																		"轻触右上「暂歇」" -- 163
																																	), -- 163
																																	"[ESC]" -- 164
																																), -- 164
																																"右上「暂歇」" -- 164
																															), -- 164
																															"按 [SPACE]" -- 165
																														), -- 165
																														"点按「翻滚/跳跃」" -- 165
																													), -- 165
																													"[SPACE]" -- 166
																												), -- 166
																												"「翻滚/跳跃」" -- 166
																											), -- 166
																											"按 [R]" -- 167
																										), -- 167
																										"在暂歇菜单重试" -- 167
																									), -- 167
																									"[A/D]" -- 168
																								), -- 168
																								"左下摇杆" -- 168
																							), -- 168
																							"[W/S]" -- 169
																						), -- 169
																						"摇杆上下" -- 169
																					), -- 169
																					"[W]" -- 170
																				), -- 170
																				"摇杆向上" -- 170
																			), -- 170
																			"[S]" -- 171
																		), -- 171
																		"摇杆向下" -- 171
																	), -- 171
																	"鼠标瞄准，左键发射火铳" -- 172
																), -- 172
																"点屏或拖「开火」发射火铳" -- 172
															), -- 172
															"左键先手击倒" -- 173
														), -- 173
														"点屏或「开火」先手击倒" -- 173
													), -- 173
													"左键发射火铳" -- 174
												), -- 174
												"点屏或「开火」发射火铳" -- 174
											), -- 174
											"左键发铳" -- 175
										), -- 175
										"点屏或「开火」发铳" -- 175
									), -- 175
									"左键" -- 176
								), -- 176
								"点屏或「开火」" -- 176
							), -- 176
							"鼠标" -- 177
						), -- 177
						"触屏" -- 177
					), -- 177
					"按 E 再次启程" -- 178
				), -- 178
				"轻触屏幕再次启程" -- 178
			), -- 178
			"Esc 暂歇" -- 179
		), -- 179
		"轻触右上暂歇" -- 179
	) -- 179
end -- 120
--- 「执器要诀」三页统一键位对照表（周戍 / 小满，覆盖键鼠、手柄、触屏全部主流操控）。
function ____exports.controlsGuideRows(tab) -- 183
	if tab == "gamepad" then -- 183
		return {subtitle = "手柄操作说明 · 全平台通用", soldierRows = { -- 189
			{"左摇杆 / 十字键", "左右、前后纵深移动"}, -- 192
			{"右摇杆 + RT / X", "360° 瞄准与发射火铳（含轻磁吸）"}, -- 193
			{"按住 LT / LB", "贴靠柜台 / 街垒挡下铅丸"}, -- 194
			{"A 键", "平地翻滚 / 靠近矮柜翻越"}, -- 195
			{"Y / RB 键", "递物 / 轻敲安抚 / 按住推车"}, -- 196
			{"摇杆直推 / 触屏", "慢时连线换弹 · B 键清空重画"} -- 197
		}, childRows = { -- 197
			{"左摇杆轻推", "内圈轻步慢走（LT/LB 亦可）"}, -- 200
			{"B 键", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 201
			{"A 键", "跳跃攀上石阶与矮台"}, -- 202
			{"Y / RB 键", "拾瓶 / 敲塔门 / 握柄拉车"}, -- 203
			{"RT/X 按住→松开", "右摇杆调落点投瓶 · B 取消"}, -- 204
			{"START / BACK", "暂歇 / 长按重试 · L3 切神器"} -- 205
		}} -- 205
	end -- 205
	if tab == "touch" then -- 205
		return {subtitle = "触屏操作说明 · 横屏全屏 / 竖屏掌机台", soldierRows = { -- 210
			{"左水墨摇杆", "全向走位与里外道切线"}, -- 213
			{"点屏 / 开火钮", "直点射击或拖住开火钮 360° 精瞄"}, -- 214
			{"掩体开关", "轻点贴靠掩体，再点或翻滚离掩"}, -- 215
			{"翻滚 / 翻越", "平地翻滚，贴近矮柜自动翻越"}, -- 216
			{"交互 / 推车", "点推车自动锁握柄，长按牵手交物"}, -- 217
			{"换弹九宫格", "单指一笔滑连至右上，点重画清空"} -- 218
		}, childRows = { -- 218
			{"摇杆内圈 / 轻步", "轻推内圈或点轻步压低脚步声"}, -- 221
			{"蹲伏开关", "点按蹲下钻桌穿拱，点跳顺滑起身"}, -- 222
			{"跳跃钮", "攀上石阶、红布车与矮台"}, -- 223
			{"投瓶拖瞄", "按住投瓶拖向砖地，拖回取消圈放弃"}, -- 224
			{"交互 / 拉车", "拾瓶、敲塔门、点拉车锁定握柄"}, -- 225
			{"右上暂歇 / 竖屏", "顶栏随时暂歇，竖屏自动展掌机台"} -- 226
		}} -- 226
	end -- 226
	return {subtitle = "键鼠操作说明 · 全平台通用", soldierRows = { -- 230
		{"WASD / 方向键", "左右、前后自由移动"}, -- 233
		{"鼠标 + 左键", "瞄准与发射火铳"}, -- 234
		{"按住 SHIFT", "贴靠柜台 / 街垒挡下铅丸"}, -- 235
		{"SPACE", "平地翻滚 / 靠近矮柜翻越"}, -- 236
		{"E", "递物 / 轻敲安抚 / 按住+D 推车"}, -- 237
		{"ESC / R / T", "暂歇菜单 / 重试检查点 / 切神器"} -- 238
	}, childRows = { -- 238
		{"A / D · ← / →", "左右潜行"}, -- 241
		{"按住 SHIFT", "轻步慢走（压低脚步声）"}, -- 242
		{"按住 S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"}, -- 243
		{"SPACE", "跳跃攀上石阶与矮台"}, -- 244
		{"E", "拾瓶 / 敲塔门 / 按住+D 拉车"}, -- 245
		{"F 按住→松开", "瞄准砖地，投瓶引开拾荒者"} -- 246
	}} -- 246
end -- 183
--- 判断当前房间阶段是否处于电影过场阻塞期（需隐藏战斗虚拟按钮）。
function ____exports.isCutsceneBlockingPlay(p) -- 252
	local rk = p.room.key -- 253
	local ph = p.phase -- 254
	if rk == "prologue" and (ph == "prologue-wake" or ph == "prologue-shadow" or ph == "prologue-hide" or ph == "prologue-give" or ph == "prologue-well") then -- 254
		return true -- 258
	end -- 258
	if rk == "gate" then -- 258
		if ph == "gate-hand" then -- 258
			return true -- 261
		end -- 261
		if ph == "gate-count" and p.countTick < GATE_COUNT_END then -- 261
			return true -- 262
		end -- 262
	end -- 262
	if rk == "tower" and (ph == "tower-knock" or ph == "tower-given" or ph == "tower-end") then -- 262
		return true -- 265
	end -- 265
	if rk == "museum" and ph == "museum-knock" then -- 265
		return true -- 268
	end -- 268
	return false -- 270
end -- 252
--- 推导情境交互按钮文案与长按进度（供触控大钮与引导共用）。
function ____exports.deriveInteractActionMeta(p, prompt, cartNearby, cartLatched) -- 274
	if cartNearby then -- 274
		if cartLatched or p.gripping then -- 274
			return { -- 282
				label = "松手", -- 282
				subLabel = "推车中", -- 282
				urgent = false, -- 282
				progress = 0, -- 282
				available = true -- 282
			} -- 282
		end -- 282
		return { -- 284
			label = p.room.key == "outside" and "拉车" or "推车", -- 285
			subLabel = "点按锁定", -- 286
			urgent = true, -- 287
			progress = 0, -- 288
			available = true -- 289
		} -- 289
	end -- 289
	if p.phase == "gate-wait" then -- 289
		local prog = math.max( -- 294
			0, -- 294
			math.min( -- 294
				1, -- 294
				p.handTicks / math.max(1, p.handNeedTicks) -- 294
			) -- 294
		) -- 294
		return { -- 295
			label = "牵手", -- 295
			subLabel = "长按", -- 295
			urgent = true, -- 295
			progress = prog, -- 295
			available = true -- 295
		} -- 295
	end -- 295
	if p.phase == "tower-desk" then -- 295
		local prog = math.max( -- 298
			0, -- 298
			math.min(1, p.deskHold / 36) -- 298
		) -- 298
		return { -- 299
			label = "交物", -- 299
			subLabel = "长按", -- 299
			urgent = true, -- 299
			progress = prog, -- 299
			available = true -- 299
		} -- 299
	end -- 299
	if p.craftT > 0 then -- 299
		return { -- 302
			label = "削楔", -- 302
			subLabel = "长按", -- 302
			urgent = true, -- 302
			progress = math.min(1, p.craftT / 30), -- 302
			available = true -- 302
		} -- 302
	end -- 302
	if prompt ~= nil then -- 302
		local kt = prompt.keyTag -- 306
		if (string.find(kt, "E", nil, true) or 0) - 1 >= 0 then -- 306
			local short = "交互" -- 308
			if (string.find(prompt.label, "指南针", nil, true) or 0) - 1 >= 0 or (string.find(prompt.label, "针套", nil, true) or 0) - 1 >= 0 then -- 308
				short = "递物" -- 309
			elseif (string.find(prompt.label, "安抚", nil, true) or 0) - 1 >= 0 then -- 309
				short = "安抚" -- 310
			elseif (string.find(prompt.label, "守门", nil, true) or 0) - 1 >= 0 then -- 310
				short = "守门" -- 311
			elseif (string.find(prompt.label, "送小满", nil, true) or 0) - 1 >= 0 then -- 311
				short = "送别" -- 312
			elseif (string.find(prompt.label, "工台", nil, true) or 0) - 1 >= 0 then -- 312
				short = "工台" -- 313
			elseif (string.find(prompt.label, "窗板", nil, true) or 0) - 1 >= 0 then -- 313
				short = "窗板" -- 314
			elseif (string.find(prompt.label, "木帘", nil, true) or 0) - 1 >= 0 then -- 314
				short = "木帘" -- 315
			elseif (string.find(prompt.label, "门锁", nil, true) or 0) - 1 >= 0 then -- 315
				short = "抬锁" -- 316
			elseif (string.find(prompt.label, "瓶", nil, true) or 0) - 1 >= 0 then -- 316
				short = "拾瓶" -- 317
			elseif (string.find(prompt.label, "收枪", nil, true) or 0) - 1 >= 0 then -- 317
				short = "收枪" -- 318
			elseif (string.find(prompt.label, "灯", nil, true) or 0) - 1 >= 0 then -- 318
				short = "转灯" -- 319
			elseif (string.find(prompt.label, "敲", nil, true) or 0) - 1 >= 0 then -- 319
				short = "轻敲" -- 320
			end -- 320
			return { -- 321
				label = short, -- 322
				subLabel = (string.find(kt, "按住", nil, true) or 0) - 1 >= 0 and "长按" or nil, -- 323
				urgent = prompt.urgent, -- 324
				progress = prompt.progress or 0, -- 325
				available = true -- 326
			} -- 326
		end -- 326
	end -- 326
	local nearWell = math.abs(p.player.x - (p.ox + p.wellX)) <= 44 and p.player.y < 20 and inReachDepth(p.player.depth, 0) -- 331
	if p.room.key == "prologue" and p.phase == "prologue-wait" and nearWell and (p.wellOpen or p.archive.artifactOwned and not p.archive.museumSeen) then -- 331
		return {label = p.wellOpen and "取器" or "入馆", urgent = true, progress = 0, available = true} -- 335
	end -- 335
	if not p.childMode and p.run.inventory.scrap > 0 and p.run.inventory.wedge < 3 and prompt == nil then -- 335
		return { -- 344
			label = "削楔", -- 344
			subLabel = "长按", -- 344
			urgent = false, -- 344
			progress = 0, -- 344
			available = true -- 344
		} -- 344
	end -- 344
	return {label = "交互", urgent = false, progress = 0, available = false} -- 347
end -- 274
return ____exports -- 274