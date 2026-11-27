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
____exports.ARTIFACT_WEAPON_IDS = { -- 24
	"time_shuttler", -- 25
	"time_shuttle", -- 26
	"shuttler", -- 27
	"time_artifact", -- 28
	"artifact", -- 29
	"时间穿梭器" -- 30
} -- 30
function ____exports.isArtifactWeaponId(weaponId) -- 33
	local i = 0 -- 34
	do -- 34
		i = 0 -- 35
		while i < #____exports.ARTIFACT_WEAPON_IDS do -- 35
			if ____exports.ARTIFACT_WEAPON_IDS[i + 1] == weaponId then -- 35
				return true -- 37
			end -- 37
			i = i + 1 -- 35
		end -- 35
	end -- 35
	return false -- 40
end -- 33
local MAX_GHOSTS = 7 -- 69
local SAMPLE_INTERVAL_SEC = 0.056 -- 70
local MIN_STEP_DIST_PX = 18 -- 71
local MIN_DRAW_SEPARATION_PX = 16 -- 72
local GHOST_MAX_LIFE_SEC = 0.42 -- 73
local MAX_GHOST_ALPHA = 0.34 -- 74
local function asRecord(v) -- 76
	if v ~= nil and type(v) == "table" then -- 76
		return v -- 78
	end -- 78
	return nil -- 80
end -- 76
local function readBool(rec, key) -- 83
	if rec == nil then -- 83
		return nil -- 85
	end -- 85
	local val = rec[key] -- 87
	local ____temp_0 -- 88
	if type(val) == "boolean" then -- 88
		____temp_0 = val -- 88
	else -- 88
		____temp_0 = nil -- 88
	end -- 88
	return ____temp_0 -- 88
end -- 83
local function readStr(rec, key) -- 91
	if rec == nil then -- 91
		return nil -- 93
	end -- 93
	local val = rec[key] -- 95
	return type(val) == "string" and val or nil -- 96
end -- 91
local function drawEllipseOutline(draw, cx, cy, rx, ry, fillCol, borderWidth, borderCol, segments) -- 99
	if segments == nil then -- 99
		segments = 18 -- 108
	end -- 108
	if rx <= 0.4 or ry <= 0.4 then -- 108
		return -- 111
	end -- 111
	local pts = {} -- 113
	local step = math.pi * 2 / segments -- 114
	local i = 0 -- 115
	do -- 115
		i = 0 -- 116
		while i < segments do -- 116
			local a = i * step -- 117
			pts[#pts + 1] = Vec2( -- 118
				cx + math.cos(a) * rx, -- 118
				cy + math.sin(a) * ry -- 118
			) -- 118
			i = i + 1 -- 116
		end -- 116
	end -- 116
	draw:drawPolygon(pts, fillCol, borderWidth, borderCol) -- 120
end -- 99
____exports.AfterimageArtifactPlugin = __TS__Class() -- 123
local AfterimageArtifactPlugin = ____exports.AfterimageArtifactPlugin -- 123
AfterimageArtifactPlugin.name = "AfterimageArtifactPlugin" -- 123
function AfterimageArtifactPlugin.prototype.____constructor(self) -- 123
	self.id = "fe-06-afterimage-artifact" -- 124
	self.ghosts = {} -- 126
	self.sampleTimer = 0 -- 127
	self.hasLastSample = false -- 128
	self.lastSampleX = 0 -- 129
	self.lastSampleY = 0 -- 130
	self.lastSampleDepth = 0 -- 131
	self.active = false -- 133
	self.lastOwned = false -- 134
	self.lastEquipped = false -- 135
	self.lastWeaponId = "" -- 136
	self.totalSpawned = 0 -- 137
	self.maxRenderedAlpha = 0 -- 138
	self.lastWorldDt = 0 -- 139
	self.slowedByTimeScale = false -- 140
end -- 123
function AfterimageArtifactPlugin.prototype.syncRuntimeHook(self) -- 143
	local g = _G -- 144
	local ____temp_1 -- 145
	if g.package ~= nil then -- 145
		____temp_1 = g.package.loaded -- 145
	else -- 145
		____temp_1 = nil -- 145
	end -- 145
	local loaded = ____temp_1 -- 145
	if loaded == nil then -- 145
		return -- 147
	end -- 147
	local rawFe = loaded["watch.fe"] -- 149
	if rawFe ~= nil and type(rawFe) == "table" then -- 149
		local watchFe = rawFe -- 151
		if watchFe.afterimageArtifact ~= self then -- 151
			watchFe.afterimageArtifact = self -- 153
		end -- 153
	end -- 153
end -- 143
function AfterimageArtifactPlugin.prototype.setEquippedOverride(self, equipped) -- 159
	self.equippedOverride = equipped -- 160
end -- 159
function AfterimageArtifactPlugin.prototype.getDebugState(self) -- 163
	return { -- 164
		active = self.active, -- 165
		artifactOwned = self.lastOwned, -- 166
		equipped = self.lastEquipped, -- 167
		equippedWeapon = self.lastWeaponId, -- 168
		ghostCount = #self.ghosts, -- 169
		maxGhosts = MAX_GHOSTS, -- 170
		totalSpawned = self.totalSpawned, -- 171
		maxRenderedAlpha = self.maxRenderedAlpha, -- 172
		lastWorldDt = self.lastWorldDt, -- 173
		slowedByTimeScale = self.slowedByTimeScale -- 174
	} -- 174
end -- 163
function AfterimageArtifactPlugin.prototype.onBindPlay(self, _p, _view) -- 178
	self:syncRuntimeHook() -- 179
	self:clearGhosts() -- 180
	self.active = false -- 181
	self.totalSpawned = 0 -- 182
	self.maxRenderedAlpha = 0 -- 183
	self.lastWorldDt = 0 -- 184
	self.slowedByTimeScale = false -- 185
end -- 178
function AfterimageArtifactPlugin.prototype.clearGhosts(self) -- 188
	self.ghosts = {} -- 189
	self.sampleTimer = 0 -- 190
	self.hasLastSample = false -- 191
end -- 188
function AfterimageArtifactPlugin.prototype.resolveEquipped(self, p, view) -- 194
	local pRec = asRecord(p) -- 195
	local runRec = asRecord(p.run) -- 196
	local weaponId = view.craftBench.equippedWeapon ~= "" and view.craftBench.equippedWeapon or (readStr(pRec, "equippedWeapon") or readStr(runRec, "equippedWeapon") or "") -- 197
	if self.equippedOverride ~= nil then -- 197
		return {equipped = self.equippedOverride, weaponId = weaponId} -- 202
	end -- 202
	if readBool(pRec, "artifactEquipped") == true or readBool(runRec, "artifactEquipped") == true then -- 202
		return {equipped = true, weaponId = weaponId} -- 205
	end -- 205
	return { -- 207
		equipped = ____exports.isArtifactWeaponId(weaponId), -- 207
		weaponId = weaponId -- 207
	} -- 207
end -- 194
function AfterimageArtifactPlugin.prototype.update(self, ctx) -- 210
	self:syncRuntimeHook() -- 211
	local p = ctx.p -- 212
	local view = ctx.view -- 213
	local owned = view.archive.artifactOwned -- 215
	local eq = self:resolveEquipped(p, view) -- 216
	self.lastOwned = owned -- 217
	self.lastEquipped = eq.equipped -- 218
	self.lastWeaponId = eq.weaponId -- 219
	self.slowedByTimeScale = view.timeScale > 0 and view.timeScale < 0.99 -- 220
	local allowedMode = view.visualMode == "pixel" and not p.childMode and p.player.alive and view.storyRoute ~= "child" -- 222
	self.active = owned and eq.equipped and allowedMode -- 227
	if not self.active then -- 227
		if #self.ghosts > 0 then -- 227
			self:clearGhosts() -- 231
		end -- 231
		self.lastWorldDt = 0 -- 233
		self.maxRenderedAlpha = 0 -- 234
		return -- 235
	end -- 235
	if ctx.paused or ctx.worldDt <= 0 then -- 235
		self.lastWorldDt = 0 -- 240
		return -- 241
	end -- 241
	local dt = ctx.worldDt -- 244
	self.lastWorldDt = dt -- 245
	local write = 0 -- 248
	local i = 0 -- 249
	do -- 249
		i = 0 -- 250
		while i < #self.ghosts do -- 250
			local g = self.ghosts[i + 1] -- 251
			g.life = g.life - dt -- 252
			if g.life > 0 then -- 252
				self.ghosts[write + 1] = g -- 254
				write = write + 1 -- 255
			end -- 255
			i = i + 1 -- 250
		end -- 250
	end -- 250
	__TS__ArraySetLength(self.ghosts, write) -- 250
	local a = p.player -- 261
	local speed = math.sqrt(a.vx * a.vx + a.vy * a.vy + a.depthSpeed * a.depthSpeed) -- 262
	if not self.hasLastSample then -- 262
		self.lastSampleX = a.x -- 264
		self.lastSampleY = a.y -- 265
		self.lastSampleDepth = a.depth -- 266
		self.hasLastSample = true -- 267
		return -- 268
	end -- 268
	self.sampleTimer = self.sampleTimer + dt -- 271
	local dx = a.x - self.lastSampleX -- 272
	local dy = a.y + a.depth * DEPTH_Y_SCALE - (self.lastSampleY + self.lastSampleDepth * DEPTH_Y_SCALE) -- 273
	local dist = math.sqrt(dx * dx + dy * dy) -- 274
	if dist >= MIN_STEP_DIST_PX and self.sampleTimer >= SAMPLE_INTERVAL_SEC * 0.65 or speed > 28 and dist >= 4.5 and self.sampleTimer >= SAMPLE_INTERVAL_SEC then -- 274
		local ____self_ghosts_2 = self.ghosts -- 274
		____self_ghosts_2[#____self_ghosts_2 + 1] = { -- 278
			x = self.lastSampleX, -- 279
			y = self.lastSampleY, -- 280
			depth = self.lastSampleDepth, -- 281
			h = a.h, -- 282
			facing = a.facing >= 0 and 1 or -1, -- 283
			crouched = a.covered or a.crouch, -- 284
			rolling = a.rollT > 0, -- 285
			carrying = view.backCarry.active, -- 286
			life = GHOST_MAX_LIFE_SEC, -- 287
			maxLife = GHOST_MAX_LIFE_SEC -- 288
		} -- 288
		if #self.ghosts > MAX_GHOSTS then -- 288
			table.remove(self.ghosts, 1) -- 291
		end -- 291
		self.totalSpawned = self.totalSpawned + 1 -- 293
		ctx.audio:playFoley( -- 294
			"afterimage:whoosh", -- 294
			"assets/audio/combat/afterimage_whoosh.wav", -- 294
			0.34, -- 294
			ctx.audio:panForWorldX(a.x), -- 294
			300 -- 294
		) -- 294
		self.sampleTimer = 0 -- 295
		self.lastSampleX = a.x -- 296
		self.lastSampleY = a.y -- 297
		self.lastSampleDepth = a.depth -- 298
	end -- 298
end -- 210
function AfterimageArtifactPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 302
	if not self.active or #self.ghosts == 0 then -- 302
		self.maxRenderedAlpha = 0 -- 309
		return -- 310
	end -- 310
	local p = ctx.p -- 313
	local cam = ctx.cam -- 314
	local peakAlpha = 0 -- 315
	local prevTrailX = 0 -- 316
	local prevTrailY = 0 -- 317
	local hasPrevTrail = false -- 318
	local i = 0 -- 320
	do -- 320
		i = 0 -- 321
		while i < #self.ghosts do -- 321
			do -- 321
				local g = self.ghosts[i + 1] -- 322
				local sepX = g.x - p.player.x -- 323
				local sepY = g.y + g.depth * DEPTH_Y_SCALE - (p.player.y + p.player.depth * DEPTH_Y_SCALE) -- 324
				if math.sqrt(sepX * sepX + sepY * sepY) < MIN_DRAW_SEPARATION_PX then -- 324
					goto __continue41 -- 326
				end -- 326
				local ratio = math.max( -- 329
					0, -- 329
					math.min(1, g.life / g.maxLife) -- 329
				) -- 329
				local rollDamp = g.rolling and 0.55 or 1 -- 330
				local normAlpha = ratio ^ 1.8 * MAX_GHOST_ALPHA * rollDamp -- 331
				if normAlpha <= 0.015 then -- 331
					goto __continue41 -- 333
				end -- 333
				if normAlpha > peakAlpha then -- 333
					peakAlpha = normAlpha -- 336
				end -- 336
				local cx = cam:sx(g.x) -- 339
				local by = cam:sy(g.y, g.depth) -- 340
				local fullH = cam:len(g.h) -- 341
				local bodyH = g.rolling and fullH * 0.62 or (g.crouched and fullH * 0.8 or fullH) -- 342
				local halfW = fullH * 0.14 -- 343
				local f = g.facing -- 344
				local whiteAlpha = math.floor(normAlpha * 255 + 0.5) -- 346
				local goldAlpha = math.floor(normAlpha * 0.82 * 255 + 0.5) -- 347
				local coldWhite = Color(224, 232, 240, whiteAlpha) -- 348
				local coldFill = Color( -- 349
					210, -- 349
					222, -- 349
					236, -- 349
					math.floor(whiteAlpha * 0.28 + 0.5) -- 349
				) -- 349
				local paleGold = Color(218, 190, 128, goldAlpha) -- 350
				local hipY = by + bodyH * 0.44 -- 353
				local shY = by + bodyH * 0.78 -- 354
				local headY = by + bodyH * 0.9 -- 355
				local headR = fullH * 0.075 -- 356
				local lean = f * fullH * 0.05 -- 357
				fgDraw:drawPolygon( -- 360
					{ -- 360
						Vec2(cx - halfW * 1.15 - f * 4, hipY - bodyH * 0.1), -- 361
						Vec2(cx + halfW * 0.78 + lean, hipY + 2), -- 362
						Vec2(cx + halfW * 0.96 + lean, shY), -- 363
						Vec2(cx - halfW * 0.88 + lean * 0.5, shY) -- 364
					}, -- 364
					coldFill, -- 365
					1.05, -- 365
					coldWhite -- 365
				) -- 365
				fgDraw:drawSegment( -- 368
					Vec2(cx - halfW * 0.25, hipY), -- 368
					Vec2(cx - f * halfW * 1.05, by + 2), -- 368
					1.4, -- 368
					coldWhite -- 368
				) -- 368
				fgDraw:drawSegment( -- 369
					Vec2(cx + halfW * 0.25, hipY), -- 369
					Vec2(cx + f * halfW * 0.85, by + 2), -- 369
					1.4, -- 369
					coldWhite -- 369
				) -- 369
				fgDraw:drawPolygon( -- 372
					{ -- 372
						Vec2(cx + lean - headR * 1.55, headY + headR * 0.15), -- 373
						Vec2(cx + lean + headR * 1.55, headY + headR * 0.15), -- 374
						Vec2(cx + lean + f * 1.5, headY + headR * 1.25) -- 375
					}, -- 375
					coldFill, -- 376
					1, -- 376
					coldWhite -- 376
				) -- 376
				fgGlow:drawSegment( -- 379
					Vec2(cx - halfW * 0.55 + lean * 0.5, shY - 2), -- 380
					Vec2(cx + halfW * 0.48 + lean * 0.6, hipY + 4), -- 381
					1.3, -- 382
					paleGold -- 383
				) -- 383
				drawEllipseOutline( -- 387
					fgDraw, -- 387
					cx, -- 387
					by + 1, -- 387
					halfW * 1.05, -- 387
					2.4, -- 387
					Color(0, 0, 0, 0), -- 387
					0.9, -- 387
					paleGold, -- 387
					16 -- 387
				) -- 387
				local midY = by + bodyH * 0.56 -- 390
				if hasPrevTrail and math.abs(cx - prevTrailX) < cam:len(72) then -- 390
					fgGlow:drawSegment( -- 392
						Vec2(prevTrailX, prevTrailY), -- 393
						Vec2(cx, midY), -- 394
						1, -- 395
						Color( -- 396
							220, -- 396
							198, -- 396
							146, -- 396
							math.floor(goldAlpha * 0.55 + 0.5) -- 396
						) -- 396
					) -- 396
				end -- 396
				prevTrailX = cx -- 399
				prevTrailY = midY -- 400
				hasPrevTrail = true -- 401
			end -- 401
			::__continue41:: -- 401
			i = i + 1 -- 321
		end -- 321
	end -- 321
	self.maxRenderedAlpha = peakAlpha -- 404
end -- 302
function ____exports.createAfterimageArtifactPlugin() -- 408
	return __TS__New(____exports.AfterimageArtifactPlugin) -- 409
end -- 408
return ____exports -- 408