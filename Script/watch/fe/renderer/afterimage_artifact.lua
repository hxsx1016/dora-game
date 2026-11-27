-- [ts]: afterimage_artifact.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 17
local Color = ____Dora.Color -- 17
local Vec2 = ____Dora.Vec2 -- 17
local ____depth = require("Script.watch.depth") -- 18
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 18
local ____occlusion = require("Script.watch.fe.occlusion") -- 22
local depthOrder = ____occlusion.depthOrder -- 22
____exports.ARTIFACT_WEAPON_IDS = { -- 25
	"time_shuttler", -- 26
	"time_shuttle", -- 27
	"shuttler", -- 28
	"time_artifact", -- 29
	"artifact", -- 30
	"时间穿梭器" -- 31
} -- 31
function ____exports.isArtifactWeaponId(weaponId) -- 34
	local i = 0 -- 35
	do -- 35
		i = 0 -- 36
		while i < #____exports.ARTIFACT_WEAPON_IDS do -- 36
			if ____exports.ARTIFACT_WEAPON_IDS[i + 1] == weaponId then -- 36
				return true -- 38
			end -- 38
			i = i + 1 -- 36
		end -- 36
	end -- 36
	return false -- 41
end -- 34
local MAX_GHOSTS = 7 -- 74
local SAMPLE_INTERVAL_SEC = 0.056 -- 75
local MIN_STEP_DIST_PX = 18 -- 76
local MIN_DRAW_SEPARATION_PX = 16 -- 77
local GHOST_MAX_LIFE_SEC = 0.42 -- 78
local MAX_GHOST_ALPHA = 0.34 -- 79
local function asRecord(v) -- 81
	if v ~= nil and type(v) == "table" then -- 81
		return v -- 83
	end -- 83
	return nil -- 85
end -- 81
local function readBool(rec, key) -- 88
	if rec == nil then -- 88
		return nil -- 90
	end -- 90
	local val = rec[key] -- 92
	local ____temp_0 -- 93
	if type(val) == "boolean" then -- 93
		____temp_0 = val -- 93
	else -- 93
		____temp_0 = nil -- 93
	end -- 93
	return ____temp_0 -- 93
end -- 88
local function readStr(rec, key) -- 96
	if rec == nil then -- 96
		return nil -- 98
	end -- 98
	local val = rec[key] -- 100
	return type(val) == "string" and val or nil -- 101
end -- 96
local function drawEllipseOutline(draw, cx, cy, rx, ry, fillCol, borderWidth, borderCol, segments) -- 104
	if segments == nil then -- 104
		segments = 18 -- 113
	end -- 113
	if rx <= 0.4 or ry <= 0.4 then -- 113
		return -- 116
	end -- 116
	local pts = {} -- 118
	local step = math.pi * 2 / segments -- 119
	local i = 0 -- 120
	do -- 120
		i = 0 -- 121
		while i < segments do -- 121
			local a = i * step -- 122
			pts[#pts + 1] = Vec2( -- 123
				cx + math.cos(a) * rx, -- 123
				cy + math.sin(a) * ry -- 123
			) -- 123
			i = i + 1 -- 121
		end -- 121
	end -- 121
	draw:drawPolygon(pts, fillCol, borderWidth, borderCol) -- 125
end -- 104
____exports.AfterimageArtifactPlugin = __TS__Class() -- 128
local AfterimageArtifactPlugin = ____exports.AfterimageArtifactPlugin -- 128
AfterimageArtifactPlugin.name = "AfterimageArtifactPlugin" -- 128
function AfterimageArtifactPlugin.prototype.____constructor(self) -- 128
	self.id = "fe-06-afterimage-artifact" -- 129
	self.ghosts = {} -- 131
	self.sampleTimer = 0 -- 132
	self.animTime = 0 -- 133
	self.hasLastSample = false -- 134
	self.lastSampleX = 0 -- 135
	self.lastSampleY = 0 -- 136
	self.lastSampleDepth = 0 -- 137
	self.active = false -- 139
	self.lastOwned = false -- 140
	self.lastEquipped = false -- 141
	self.lastWeaponId = "" -- 142
	self.totalSpawned = 0 -- 143
	self.maxRenderedAlpha = 0 -- 144
	self.lastWorldDt = 0 -- 145
	self.slowedByTimeScale = false -- 146
end -- 128
function AfterimageArtifactPlugin.prototype.syncRuntimeHook(self) -- 149
	local g = _G -- 150
	local ____temp_1 -- 151
	if g.package ~= nil then -- 151
		____temp_1 = g.package.loaded -- 151
	else -- 151
		____temp_1 = nil -- 151
	end -- 151
	local loaded = ____temp_1 -- 151
	if loaded == nil then -- 151
		return -- 153
	end -- 153
	local rawFe = loaded["watch.fe"] -- 155
	if rawFe ~= nil and type(rawFe) == "table" then -- 155
		local watchFe = rawFe -- 157
		if watchFe.afterimageArtifact ~= self then -- 157
			watchFe.afterimageArtifact = self -- 159
		end -- 159
	end -- 159
end -- 149
function AfterimageArtifactPlugin.prototype.setEquippedOverride(self, equipped) -- 165
	self.equippedOverride = equipped -- 166
end -- 165
function AfterimageArtifactPlugin.prototype.getDebugState(self) -- 169
	return { -- 170
		active = self.active, -- 171
		artifactOwned = self.lastOwned, -- 172
		equipped = self.lastEquipped, -- 173
		equippedWeapon = self.lastWeaponId, -- 174
		ghostCount = #self.ghosts, -- 175
		maxGhosts = MAX_GHOSTS, -- 176
		totalSpawned = self.totalSpawned, -- 177
		maxRenderedAlpha = self.maxRenderedAlpha, -- 178
		lastWorldDt = self.lastWorldDt, -- 179
		slowedByTimeScale = self.slowedByTimeScale -- 180
	} -- 180
end -- 169
function AfterimageArtifactPlugin.prototype.onBindPlay(self, _p, _view) -- 184
	self:syncRuntimeHook() -- 185
	self:clearGhosts() -- 186
	self.active = false -- 187
	self.totalSpawned = 0 -- 188
	self.maxRenderedAlpha = 0 -- 189
	self.lastWorldDt = 0 -- 190
	self.slowedByTimeScale = false -- 191
end -- 184
function AfterimageArtifactPlugin.prototype.clearGhosts(self) -- 194
	self.ghosts = {} -- 195
	self.sampleTimer = 0 -- 196
	self.hasLastSample = false -- 197
end -- 194
function AfterimageArtifactPlugin.prototype.resolveEquipped(self, p, view) -- 200
	local pRec = asRecord(p) -- 201
	local runRec = asRecord(p.run) -- 202
	local weaponId = view.craftBench.equippedWeapon ~= "" and view.craftBench.equippedWeapon or (readStr(pRec, "equippedWeapon") or readStr(runRec, "equippedWeapon") or "") -- 203
	if self.equippedOverride ~= nil then -- 203
		return {equipped = self.equippedOverride, weaponId = weaponId} -- 208
	end -- 208
	if readBool(pRec, "artifactEquipped") == true or readBool(runRec, "artifactEquipped") == true then -- 208
		return {equipped = true, weaponId = weaponId} -- 211
	end -- 211
	return { -- 213
		equipped = ____exports.isArtifactWeaponId(weaponId), -- 213
		weaponId = weaponId -- 213
	} -- 213
end -- 200
function AfterimageArtifactPlugin.prototype.update(self, ctx) -- 216
	self:syncRuntimeHook() -- 217
	local p = ctx.p -- 218
	local view = ctx.view -- 219
	local owned = view.archive.artifactOwned -- 221
	local eq = self:resolveEquipped(p, view) -- 222
	self.lastOwned = owned -- 223
	self.lastEquipped = eq.equipped -- 224
	self.lastWeaponId = eq.weaponId -- 225
	self.slowedByTimeScale = view.timeScale > 0 and view.timeScale < 0.99 -- 226
	local allowedMode = view.visualMode == "pixel" and not p.childMode and p.player.alive and view.storyRoute ~= "child" -- 228
	self.active = owned and eq.equipped and allowedMode -- 233
	if not self.active then -- 233
		if #self.ghosts > 0 then -- 233
			self:clearGhosts() -- 237
		end -- 237
		self.lastWorldDt = 0 -- 239
		self.maxRenderedAlpha = 0 -- 240
		return -- 241
	end -- 241
	if ctx.paused or ctx.worldDt <= 0 then -- 241
		self.lastWorldDt = 0 -- 246
		return -- 247
	end -- 247
	local dt = ctx.worldDt -- 250
	self.lastWorldDt = dt -- 251
	self.animTime = self.animTime + dt -- 252
	local write = 0 -- 255
	local i = 0 -- 256
	do -- 256
		i = 0 -- 257
		while i < #self.ghosts do -- 257
			local g = self.ghosts[i + 1] -- 258
			g.life = g.life - dt -- 259
			if g.life > 0 then -- 259
				self.ghosts[write + 1] = g -- 261
				write = write + 1 -- 262
			end -- 262
			i = i + 1 -- 257
		end -- 257
	end -- 257
	__TS__ArraySetLength(self.ghosts, write) -- 257
	local a = p.player -- 268
	local speed = math.sqrt(a.vx * a.vx + a.vy * a.vy + a.depthSpeed * a.depthSpeed) -- 269
	if not self.hasLastSample then -- 269
		self.lastSampleX = a.x -- 271
		self.lastSampleY = a.y -- 272
		self.lastSampleDepth = a.depth -- 273
		self.hasLastSample = true -- 274
		return -- 275
	end -- 275
	self.sampleTimer = self.sampleTimer + dt -- 278
	local dx = a.x - self.lastSampleX -- 279
	local dy = a.y + a.depth * DEPTH_Y_SCALE - (self.lastSampleY + self.lastSampleDepth * DEPTH_Y_SCALE) -- 280
	local dist = math.sqrt(dx * dx + dy * dy) -- 281
	if dist >= MIN_STEP_DIST_PX and self.sampleTimer >= SAMPLE_INTERVAL_SEC * 0.65 or speed > 28 and dist >= 4.5 and self.sampleTimer >= SAMPLE_INTERVAL_SEC then -- 281
		local step = math.floor(self.animTime * 10) -- 285
		local slot = "soldier_idle" -- 286
		local frame = 0 -- 287
		local heightScale = 1 -- 288
		if a.rollT > 0 then -- 288
			slot = "soldier_roll" -- 290
			heightScale = 0.6 -- 291
		elseif p.gripping then -- 291
			slot = "soldier_push" -- 293
			frame = speed > 6 and step or 0 -- 294
			heightScale = 0.91 -- 295
		elseif a.covered then -- 295
			slot = "soldier_cover" -- 297
			heightScale = 0.77 -- 298
		elseif speed > 8 then -- 298
			slot = "soldier_run" -- 300
			frame = step -- 301
		end -- 301
		local ____self_ghosts_2 = self.ghosts -- 301
		____self_ghosts_2[#____self_ghosts_2 + 1] = { -- 303
			x = self.lastSampleX, -- 304
			y = self.lastSampleY, -- 305
			depth = self.lastSampleDepth, -- 306
			w = a.w, -- 307
			h = a.h, -- 308
			facing = a.facing >= 0 and 1 or -1, -- 309
			crouched = a.covered or a.crouch, -- 310
			rolling = a.rollT > 0, -- 311
			carrying = view.backCarry.active, -- 312
			slot = slot, -- 313
			frame = frame, -- 314
			heightScale = heightScale, -- 315
			life = GHOST_MAX_LIFE_SEC, -- 316
			maxLife = GHOST_MAX_LIFE_SEC -- 317
		} -- 317
		if #self.ghosts > MAX_GHOSTS then -- 317
			table.remove(self.ghosts, 1) -- 320
		end -- 320
		self.totalSpawned = self.totalSpawned + 1 -- 322
		ctx.audio:playFoley( -- 323
			"afterimage:whoosh", -- 323
			"assets/audio/combat/afterimage_whoosh.wav", -- 323
			0.34, -- 323
			ctx.audio:panForWorldX(a.x), -- 323
			300 -- 323
		) -- 323
		self.sampleTimer = 0 -- 324
		self.lastSampleX = a.x -- 325
		self.lastSampleY = a.y -- 326
		self.lastSampleDepth = a.depth -- 327
	end -- 327
end -- 216
function AfterimageArtifactPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 331
	if not self.active or #self.ghosts == 0 then -- 331
		self.maxRenderedAlpha = 0 -- 338
		return -- 339
	end -- 339
	local p = ctx.p -- 342
	local cam = ctx.cam -- 343
	local depthEnabled = p.room.depth ~= nil -- 344
	local peakAlpha = 0 -- 345
	local prevTrailX = 0 -- 346
	local prevTrailY = 0 -- 347
	local hasPrevTrail = false -- 348
	local i = 0 -- 350
	do -- 350
		i = 0 -- 351
		while i < #self.ghosts do -- 351
			do -- 351
				local g = self.ghosts[i + 1] -- 352
				local sepX = g.x - p.player.x -- 353
				local sepY = g.y + g.depth * DEPTH_Y_SCALE - (p.player.y + p.player.depth * DEPTH_Y_SCALE) -- 354
				if math.sqrt(sepX * sepX + sepY * sepY) < MIN_DRAW_SEPARATION_PX then -- 354
					goto __continue45 -- 356
				end -- 356
				local ratio = math.max( -- 359
					0, -- 359
					math.min(1, g.life / g.maxLife) -- 359
				) -- 359
				local rollDamp = g.rolling and 0.55 or 1 -- 360
				local normAlpha = ratio ^ 1.8 * MAX_GHOST_ALPHA * rollDamp -- 361
				if normAlpha <= 0.015 then -- 361
					goto __continue45 -- 363
				end -- 363
				if normAlpha > peakAlpha then -- 363
					peakAlpha = normAlpha -- 366
				end -- 366
				local cx = cam:sx(g.x) -- 369
				local by = cam:sy(g.y, g.depth) -- 370
				local fullH = cam:len(g.h) -- 371
				local W = cam:len(g.w) -- 372
				local spriteH = fullH * g.heightScale -- 373
				local f = g.facing -- 374
				local baseLayer = depthEnabled and depthOrder(g.depth, 1) or 2 -- 375
				local goldAlpha = math.floor(normAlpha * 0.72 * 255 + 0.5) -- 377
				local paleGold = Color(224, 196, 134, goldAlpha) -- 378
				local goldRimPlaced = worldArt:tryPlace( -- 381
					g.slot, -- 382
					"artifact_ghost_rim_" .. tostring(i), -- 383
					cx - f * 2.2, -- 384
					by + 0.6, -- 385
					W, -- 386
					spriteH, -- 387
					{ -- 388
						facing = f, -- 389
						frame = g.frame, -- 390
						layer = baseLayer, -- 391
						color = Color(238, 206, 146, 255), -- 392
						opacity = normAlpha * 0.58 -- 393
					} -- 393
				) -- 393
				local spritePlaced = worldArt:tryPlace( -- 396
					g.slot, -- 397
					"artifact_ghost_main_" .. tostring(i), -- 398
					cx, -- 399
					by, -- 400
					W, -- 401
					spriteH, -- 402
					{ -- 403
						facing = f, -- 404
						frame = g.frame, -- 405
						layer = baseLayer + 1, -- 406
						color = Color(198, 224, 242, 255), -- 407
						opacity = normAlpha -- 408
					} -- 408
				) -- 408
				if not spritePlaced and not goldRimPlaced then -- 408
					local halfW = fullH * 0.14 -- 414
					fgDraw:drawEllipse( -- 415
						Vec2(cx, by + spriteH * 0.48), -- 416
						halfW, -- 417
						spriteH * 0.44, -- 418
						Color( -- 419
							210, -- 419
							226, -- 419
							240, -- 419
							math.floor(normAlpha * 140 + 0.5) -- 419
						) -- 419
					) -- 419
				end -- 419
				drawEllipseOutline( -- 424
					fgDraw, -- 425
					cx, -- 426
					by + 1, -- 427
					math.max(6, W * 0.52), -- 428
					2.4, -- 429
					Color( -- 430
						18, -- 430
						26, -- 430
						38, -- 430
						math.floor(normAlpha * 95 + 0.5) -- 430
					), -- 430
					0.85, -- 431
					paleGold, -- 432
					16 -- 433
				) -- 433
				local midY = by + spriteH * 0.52 -- 437
				if hasPrevTrail and math.abs(cx - prevTrailX) < cam:len(72) then -- 437
					fgGlow:drawSegment( -- 439
						Vec2(prevTrailX, prevTrailY), -- 440
						Vec2(cx, midY), -- 441
						0.95, -- 442
						Color( -- 443
							220, -- 443
							198, -- 443
							146, -- 443
							math.floor(goldAlpha * 0.48 + 0.5) -- 443
						) -- 443
					) -- 443
				end -- 443
				prevTrailX = cx -- 446
				prevTrailY = midY -- 447
				hasPrevTrail = true -- 448
			end -- 448
			::__continue45:: -- 448
			i = i + 1 -- 351
		end -- 351
	end -- 351
	self.maxRenderedAlpha = peakAlpha -- 451
end -- 331
function ____exports.createAfterimageArtifactPlugin() -- 455
	return __TS__New(____exports.AfterimageArtifactPlugin) -- 456
end -- 455
return ____exports -- 455