-- [ts]: touch_hud_portrait.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 7
local Rect = ____Dora.Rect -- 7
local Vec2 = ____Dora.Vec2 -- 7
local ____theme = require("Script.watch.fe.theme") -- 12
local PALETTE = ____theme.PALETTE -- 12
local drawDiamond = ____theme.drawDiamond -- 12
local fillVGradRect = ____theme.fillVGradRect -- 12
local toColor = ____theme.toColor -- 12
local function clamp(v, lo, hi) -- 14
	return v < lo and lo or (v > hi and hi or v) -- 15
end -- 14
____exports.PORTRAIT_TOUCH_DELEGATE = { -- 75
	computeStickGeom = function(self, vp, ovW, safeL, safeB, sc) -- 76
		local unitPortrait = clamp( -- 77
			math.min( -- 77
				vp.fullW / 420, -- 77
				math.max(180, vp.deckH) / 340 -- 77
			), -- 77
			0.72, -- 77
			1.15 -- 77
		) -- 77
		local stickMaxR = math.floor(52 * unitPortrait * sc + 0.5) -- 78
		return { -- 79
			unitPortrait = unitPortrait, -- 80
			stickMaxR = stickMaxR, -- 81
			stickDefaultX = safeL + math.max( -- 82
				stickMaxR + 26, -- 82
				math.floor(ovW * 0.24 + 0.5) -- 82
			), -- 82
			stickDefaultY = math.max(safeB + stickMaxR + 24, vp.deckH * 0.44), -- 83
			stickZoneMaxX = ovW * 0.5, -- 84
			stickZoneMaxY = math.max(40, vp.deckH - 8) -- 85
		} -- 85
	end, -- 76
	pushTopButtons = function(self, buttons, vp, ovW, ovH, safeR, gameplayActive, p, isMuted, isFullscreen, allowFullscreen) -- 89
		local topY = ovH - vp.topBarH * 0.5 -- 90
		local pillH = 26 -- 91
		local rx = ovW - safeR - 10 -- 92
		if gameplayActive and p ~= nil and not p.paused then -- 92
			local pw = 58 -- 95
			rx = rx - pw -- 96
			buttons[#buttons + 1] = { -- 97
				id = "pause", -- 98
				x = rx + pw * 0.5, -- 99
				y = topY, -- 100
				r = 22, -- 101
				shape = "pill", -- 102
				rect = Rect(rx, topY - pillH * 0.5, pw, pillH), -- 103
				label = "暂歇", -- 104
				accent = "silk", -- 105
				active = false, -- 106
				highlighted = false, -- 107
				progress = 0, -- 108
				dimmed = false -- 109
			} -- 109
			rx = rx - 8 -- 111
			local inTowerEnd = p.room.key == "tower" and p.phase ~= "tower-wait" -- 113
			if not inTowerEnd then -- 113
				local rw = 58 -- 115
				rx = rx - rw -- 116
				buttons[#buttons + 1] = { -- 117
					id = "retry", -- 118
					x = rx + rw * 0.5, -- 119
					y = topY, -- 120
					r = 22, -- 121
					shape = "pill", -- 122
					rect = Rect(rx, topY - pillH * 0.5, rw, pillH), -- 123
					label = "重试", -- 124
					accent = "amber", -- 125
					active = false, -- 126
					highlighted = false, -- 127
					progress = 0, -- 128
					dimmed = false -- 129
				} -- 129
				rx = rx - 8 -- 131
			end -- 131
		end -- 131
		local mw = 54 -- 135
		rx = rx - mw -- 136
		buttons[#buttons + 1] = { -- 137
			id = "mute", -- 138
			x = rx + mw * 0.5, -- 139
			y = topY, -- 140
			r = 20, -- 141
			shape = "pill", -- 142
			rect = Rect(rx, topY - pillH * 0.5, mw, pillH), -- 143
			label = isMuted and "静音" or "有声", -- 144
			accent = isMuted and "rouge" or "cyan", -- 145
			active = isMuted, -- 146
			highlighted = false, -- 147
			progress = 0, -- 148
			dimmed = false -- 149
		} -- 149
		rx = rx - 8 -- 151
		if allowFullscreen then -- 151
			local fw = 54 -- 154
			rx = rx - fw -- 155
			buttons[#buttons + 1] = { -- 156
				id = "fullscreen", -- 157
				x = rx + fw * 0.5, -- 158
				y = topY, -- 159
				r = 20, -- 160
				shape = "pill", -- 161
				rect = Rect(rx, topY - pillH * 0.5, fw, pillH), -- 162
				label = isFullscreen and "窗口" or "全屏", -- 163
				accent = "silk", -- 164
				active = isFullscreen, -- 165
				highlighted = false, -- 166
				progress = 0, -- 167
				dimmed = false -- 168
			} -- 168
		end -- 168
	end, -- 89
	pushMenuNavButtons = function(self, buttons, vp, ovW, safeL, safeR, safeB) -- 173
		local cy = math.max(safeB + 84, vp.deckH * 0.5) -- 174
		local leftX = safeL + math.max(82, ovW * 0.25) -- 175
		local step = math.min( -- 176
			54, -- 176
			math.max(42, ovW * 0.12) -- 176
		) -- 176
		local nr = math.min( -- 177
			26, -- 177
			math.max(21, ovW * 0.06) -- 177
		) -- 177
		buttons[#buttons + 1] = { -- 178
			id = "nav_up", -- 178
			x = leftX, -- 178
			y = cy + step, -- 178
			r = nr, -- 178
			label = "上", -- 178
			accent = "silk", -- 178
			active = false, -- 178
			highlighted = false, -- 178
			progress = 0, -- 178
			dimmed = false -- 178
		} -- 178
		buttons[#buttons + 1] = { -- 179
			id = "nav_down", -- 179
			x = leftX, -- 179
			y = cy - step, -- 179
			r = nr, -- 179
			label = "下", -- 179
			accent = "silk", -- 179
			active = false, -- 179
			highlighted = false, -- 179
			progress = 0, -- 179
			dimmed = false -- 179
		} -- 179
		buttons[#buttons + 1] = { -- 180
			id = "nav_left", -- 180
			x = leftX - step, -- 180
			y = cy, -- 180
			r = nr, -- 180
			label = "左", -- 180
			accent = "silk", -- 180
			active = false, -- 180
			highlighted = false, -- 180
			progress = 0, -- 180
			dimmed = false -- 180
		} -- 180
		buttons[#buttons + 1] = { -- 181
			id = "nav_right", -- 181
			x = leftX + step, -- 181
			y = cy, -- 181
			r = nr, -- 181
			label = "右", -- 181
			accent = "silk", -- 181
			active = false, -- 181
			highlighted = false, -- 181
			progress = 0, -- 181
			dimmed = false -- 181
		} -- 181
		local rightX = ovW - safeR - math.max(76, ovW * 0.23) -- 183
		buttons[#buttons + 1] = { -- 184
			id = "nav_confirm", -- 185
			x = rightX, -- 186
			y = cy + 28, -- 187
			r = 28, -- 188
			shape = "pill", -- 189
			rect = Rect(rightX - 48, cy + 6, 96, 44), -- 190
			label = "确认", -- 191
			accent = "rouge", -- 192
			active = false, -- 193
			highlighted = true, -- 194
			progress = 0, -- 195
			dimmed = false -- 196
		} -- 196
		buttons[#buttons + 1] = { -- 198
			id = "nav_back", -- 199
			x = rightX, -- 200
			y = cy - 30, -- 201
			r = 26, -- 202
			shape = "pill", -- 203
			rect = Rect(rightX - 48, cy - 50, 96, 40), -- 204
			label = "返回", -- 205
			accent = "silk", -- 206
			active = false, -- 207
			highlighted = false, -- 208
			progress = 0, -- 209
			dimmed = false -- 210
		} -- 210
	end, -- 173
	pushActionButtons = function(self, buttons, vp, ovW, safeR, safeB, geom, sc, p, isPlayMode, canBottleAim, nearLedge, interactMeta, router) -- 214
		local u = geom.unitPortrait * sc -- 215
		local rightX = ovW - safeR - math.floor(68 * u + 0.5) -- 216
		local bottomY = math.max( -- 217
			safeB + math.floor(70 * u + 0.5), -- 217
			vp.deckH * 0.4 -- 217
		) -- 217
		local postY = math.min( -- 218
			vp.deckH - 26, -- 218
			geom.stickDefaultY + geom.stickMaxR + math.floor(42 * u + 0.5) -- 218
		) -- 218
		local bottleCancelCenter = { -- 219
			x = rightX - math.floor(14 * u + 0.5), -- 219
			y = bottomY + math.floor(10 * u + 0.5), -- 219
			r = math.floor(34 * u + 0.5) -- 219
		} -- 219
		if not p.childMode then -- 219
			local cw = math.floor(86 * u + 0.5) -- 222
			local ch = math.floor(32 * u + 0.5) -- 223
			buttons[#buttons + 1] = { -- 224
				id = "cover", -- 225
				x = geom.stickDefaultX, -- 226
				y = postY, -- 227
				r = 24 * u, -- 228
				shape = "pill", -- 229
				toggle = true, -- 230
				rect = Rect(geom.stickDefaultX - cw * 0.5, postY - ch * 0.5, cw, ch), -- 231
				label = router.coverToggled and "离掩体" or "贴掩体", -- 232
				accent = "cyan", -- 233
				active = router.coverToggled or p.coverHug, -- 234
				highlighted = p.coverNear and not router.coverToggled, -- 235
				progress = 0, -- 236
				dimmed = not p.coverNear and not router.coverToggled -- 237
			} -- 237
			buttons[#buttons + 1] = { -- 239
				id = "fire", -- 240
				x = rightX, -- 241
				y = bottomY + math.floor(8 * u + 0.5), -- 242
				r = math.floor(36 * u + 0.5), -- 243
				label = router:getFireStickVisual().dragging and "松手射" or "开火", -- 244
				subLabel = "拖瞄", -- 245
				accent = "rouge", -- 246
				active = router:isButtonHeld("fire"), -- 247
				highlighted = p.reloadPendingEffect ~= "", -- 248
				progress = 0, -- 249
				dimmed = p.gripping -- 250
			} -- 250
			buttons[#buttons + 1] = { -- 252
				id = "jump", -- 253
				x = rightX - math.floor(84 * u + 0.5), -- 254
				y = bottomY - math.floor(16 * u + 0.5), -- 255
				r = math.floor(28 * u + 0.5), -- 256
				label = nearLedge and "翻越" or "翻滚", -- 257
				accent = "cyan", -- 258
				active = router:isButtonHeld("jump"), -- 259
				highlighted = nearLedge, -- 260
				progress = 0, -- 261
				dimmed = p.gripping -- 262
			} -- 262
			buttons[#buttons + 1] = { -- 264
				id = "interact", -- 265
				x = rightX - math.floor(10 * u + 0.5), -- 266
				y = bottomY + math.floor(88 * u + 0.5), -- 267
				r = math.floor(30 * u + 0.5), -- 268
				label = interactMeta.label, -- 269
				subLabel = interactMeta.subLabel, -- 270
				accent = interactMeta.urgent and "rouge" or "amber", -- 271
				active = router:isButtonHeld("interact"), -- 272
				highlighted = interactMeta.available, -- 273
				progress = interactMeta.progress, -- 274
				dimmed = not interactMeta.available -- 275
			} -- 275
			if isPlayMode and p.archive.artifactOwned then -- 275
				local eq = p.equippedWeapon == "time_shuttler" -- 278
				buttons[#buttons + 1] = { -- 279
					id = "artifact", -- 280
					x = rightX - math.floor(90 * u + 0.5), -- 281
					y = bottomY + math.floor(68 * u + 0.5), -- 282
					r = math.floor(24 * u + 0.5), -- 283
					label = eq and "收器" or "穿梭", -- 284
					accent = "amber", -- 285
					active = eq, -- 286
					highlighted = eq, -- 287
					progress = 0, -- 288
					dimmed = false -- 289
				} -- 289
			end -- 289
		else -- 289
			local pw = math.floor(68 * u + 0.5) -- 293
			local ph = math.floor(32 * u + 0.5) -- 294
			buttons[#buttons + 1] = { -- 295
				id = "crouch", -- 296
				x = geom.stickDefaultX - math.floor(38 * u + 0.5), -- 297
				y = postY, -- 298
				r = 22 * u, -- 299
				shape = "pill", -- 300
				toggle = true, -- 301
				rect = Rect( -- 302
					geom.stickDefaultX - math.floor(38 * u + 0.5) - pw * 0.5, -- 302
					postY - ph * 0.5, -- 302
					pw, -- 302
					ph -- 302
				), -- 302
				label = router.crouchToggled and "起身" or "蹲伏", -- 303
				accent = "emerald", -- 304
				active = router.crouchToggled or p.player.crouch, -- 305
				highlighted = p.scavChase and not p.player.crouch, -- 306
				progress = 0, -- 307
				dimmed = false -- 308
			} -- 308
			buttons[#buttons + 1] = { -- 310
				id = "cover", -- 311
				x = geom.stickDefaultX + math.floor(38 * u + 0.5), -- 312
				y = postY, -- 313
				r = 22 * u, -- 314
				shape = "pill", -- 315
				toggle = true, -- 316
				rect = Rect( -- 317
					geom.stickDefaultX + math.floor(38 * u + 0.5) - pw * 0.5, -- 317
					postY - ph * 0.5, -- 317
					pw, -- 317
					ph -- 317
				), -- 317
				label = router.slowToggled and "常步" or "轻步", -- 318
				accent = "silk", -- 319
				active = router.slowToggled, -- 320
				highlighted = false, -- 321
				progress = 0, -- 322
				dimmed = false -- 323
			} -- 323
			buttons[#buttons + 1] = { -- 325
				id = "jump", -- 326
				x = rightX, -- 327
				y = bottomY + math.floor(8 * u + 0.5), -- 328
				r = math.floor(32 * u + 0.5), -- 329
				label = "跳跃", -- 330
				accent = "amber", -- 331
				active = router:isButtonHeld("jump"), -- 332
				highlighted = false, -- 333
				progress = 0, -- 334
				dimmed = p.gripping -- 335
			} -- 335
			buttons[#buttons + 1] = { -- 337
				id = "interact", -- 338
				x = rightX - math.floor(8 * u + 0.5), -- 339
				y = bottomY + math.floor(86 * u + 0.5), -- 340
				r = math.floor(31 * u + 0.5), -- 341
				label = interactMeta.label, -- 342
				subLabel = interactMeta.subLabel, -- 343
				accent = interactMeta.urgent and "rouge" or "amber", -- 344
				active = router:isButtonHeld("interact"), -- 345
				highlighted = interactMeta.available, -- 346
				progress = interactMeta.progress, -- 347
				dimmed = not interactMeta.available -- 348
			} -- 348
			if canBottleAim then -- 348
				buttons[#buttons + 1] = { -- 351
					id = "bottle", -- 352
					x = rightX - math.floor(86 * u + 0.5), -- 353
					y = bottomY + math.floor(46 * u + 0.5), -- 354
					r = math.floor(32 * u + 0.5), -- 355
					label = "投瓶", -- 356
					subLabel = "拖瞄", -- 357
					accent = "amber", -- 358
					active = router:isButtonHeld("bottle"), -- 359
					highlighted = true, -- 360
					progress = math.min(1, p.aimHold / 0.12), -- 361
					dimmed = false -- 362
				} -- 362
			end -- 362
		end -- 362
		return bottleCancelCenter -- 366
	end, -- 214
	drawFrame = function(self, deckDraw, padInkDraw, texts, ctx, lastPlay, w, h) -- 369
		local vp = ctx.viewport -- 370
		local topY = vp.stageY + vp.stageH -- 371
		if topY < h then -- 371
			deckDraw:drawRect( -- 374
				Rect(0, topY, w, h - topY), -- 374
				toColor(PALETTE.inkVoid, 252) -- 374
			) -- 374
			deckDraw:drawSegment( -- 375
				Vec2(0, topY), -- 375
				Vec2(w, topY), -- 375
				1, -- 375
				toColor(PALETTE.silkDim, 140) -- 375
			) -- 375
			local labelY = topY + (h - topY) * 0.5 -- 376
			texts:put( -- 377
				"xs", -- 377
				"向西守望 · 掌机竖屏", -- 377
				vp.safe.left + 12, -- 377
				labelY, -- 377
				toColor(PALETTE.amberCore), -- 377
				0, -- 377
				0.5, -- 377
				"Left", -- 377
				0.8, -- 377
				0.88, -- 377
				0.08 -- 377
			) -- 377
		end -- 377
		if vp.stageX > 0 then -- 377
			deckDraw:drawRect( -- 381
				Rect(0, vp.stageY, vp.stageX, vp.stageH), -- 381
				toColor(PALETTE.inkVoid, 255) -- 381
			) -- 381
			deckDraw:drawRect( -- 382
				Rect(vp.stageX + vp.stageW, vp.stageY, w - vp.stageX - vp.stageW, vp.stageH), -- 382
				toColor(PALETTE.inkVoid, 255) -- 382
			) -- 382
		end -- 382
		if vp.deckH > 0 then -- 382
			fillVGradRect( -- 386
				deckDraw, -- 386
				0, -- 386
				0, -- 386
				w, -- 386
				vp.deckH, -- 386
				toColor(PALETTE.voidDark, 255), -- 386
				toColor(PALETTE.inkWash, 255) -- 386
			) -- 386
			deckDraw:drawSegment( -- 387
				Vec2(0, vp.deckH), -- 387
				Vec2(w, vp.deckH), -- 387
				1.2, -- 387
				toColor(PALETTE.silkLine, 165) -- 387
			) -- 387
			deckDraw:drawSegment( -- 388
				Vec2(18, vp.deckH - 4), -- 388
				Vec2(w - 18, vp.deckH - 4), -- 388
				0.6, -- 388
				toColor(PALETTE.silkDim, 85) -- 388
			) -- 388
			drawDiamond( -- 389
				padInkDraw, -- 389
				w * 0.5, -- 389
				vp.deckH, -- 389
				5, -- 389
				5, -- 389
				toColor(PALETTE.rouge, 220), -- 389
				0.9, -- 389
				toColor(PALETTE.silkLine, 180) -- 389
			) -- 389
			local footY = math.max(vp.safe.bottom + 14, 16) -- 391
			local inOverlayModal = lastPlay ~= nil and (lastPlay.reloadOpen or lastPlay.craftBench.active) -- 392
			local hint = inOverlayModal and "直接在上屏点按或一笔划连" or ((not ctx.gameplayActive or lastPlay ~= nil and lastPlay.paused) and "可点上屏菜单或用下方导航键" or (ctx.childMode and "左摇杆内圈轻步 · 蹲伏/轻步点按切换" or "左摇杆走位 · 点上屏或拖「开火」瞄射")) -- 393
			texts:put( -- 400
				"xs", -- 400
				hint, -- 400
				w * 0.5, -- 400
				footY, -- 400
				toColor(PALETTE.textDim), -- 400
				0.5, -- 400
				0.5, -- 400
				"Center", -- 400
				0.8, -- 400
				0.78, -- 400
				0.06 -- 400
			) -- 400
		end -- 400
	end -- 369
} -- 369
return ____exports -- 369