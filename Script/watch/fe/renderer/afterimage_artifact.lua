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
			if ____exports.ARTIFACT_WEAPON_IDS[i + 1] == weaponId then -- 36
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
	if v ~= nil and type(v) == "table" then -- 77
		return v -- 78
	end -- 78
	return nil -- 80
end -- 76
local function readBool(rec, key) -- 83
	if rec == nil then -- 84
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
	if rec == nil then -- 92
		return nil -- 93
	end -- 93
	local val = rec[key] -- 95
	return type(val) == "string" and val or nil -- 96
end -- 91
local function drawEllipseOutline(draw, cx, cy, rx, ry, fillCol, borderWidth, borderCol, segments) -- 99
	if segments == nil then -- 108
		segments = 18 -- 108
	end -- 108
	if rx <= 0.4 or ry <= 0.4 then -- 110
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
	if loaded == nil then -- 146
		return -- 147
	end -- 147
	local rawFe = loaded["watch.fe"] -- 149
	if rawFe ~= nil and type(rawFe) == "table" then -- 150
		local watchFe = rawFe -- 151
		if watchFe.afterimageArtifact ~= self then -- 152
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
	if self.equippedOverride ~= nil then -- 201
		return {equipped = self.equippedOverride, weaponId = weaponId} -- 202
	end -- 202
	if readBool(pRec, "artifactEquipped") == true or readBool(runRec, "artifactEquipped") == true then -- 204
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
	if not self.active then -- 229
		if #self.ghosts > 0 then -- 230
			self:clearGhosts() -- 231
		end -- 231
		self.lastWorldDt = 0 -- 233
		self.maxRenderedAlpha = 0 -- 234
		return -- 235
	end -- 235
	if ctx.paused or ctx.worldDt <= 0 then -- 239
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
			if g.life > 0 then -- 253
				self.ghosts[write + 1] = g -- 254
				write = write + 1 -- 255
			end -- 255
			i = i + 1 -- 250
		end -- 250
	end -- 250
	__TS__ArraySetLength(self.ghosts, write) -- 258
	local a = p.player -- 261
	local speed = math.sqrt(a.vx * a.vx + a.vy * a.vy + a.depthSpeed * a.depthSpeed) -- 262
	if not self.hasLastSample then -- 263
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
	if dist >= MIN_STEP_DIST_PX and self.sampleTimer >= SAMPLE_INTERVAL_SEC * 0.65 or speed > 28 and dist >= 4.5 and self.sampleTimer >= SAMPLE_INTERVAL_SEC then -- 276
		local ____self_ghosts_2 = self.ghosts -- 278
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
		if #self.ghosts > MAX_GHOSTS then -- 290
			table.remove(self.ghosts, 1) -- 291
		end -- 291
		self.totalSpawned = self.totalSpawned + 1 -- 293
		self.sampleTimer = 0 -- 294
		self.lastSampleX = a.x -- 295
		self.lastSampleY = a.y -- 296
		self.lastSampleDepth = a.depth -- 297
	end -- 297
end -- 210
function AfterimageArtifactPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 301
	if not self.active or #self.ghosts == 0 then -- 307
		self.maxRenderedAlpha = 0 -- 308
		return -- 309
	end -- 309
	local p = ctx.p -- 312
	local cam = ctx.cam -- 313
	local peakAlpha = 0 -- 314
	local prevTrailX = 0 -- 315
	local prevTrailY = 0 -- 316
	local hasPrevTrail = false -- 317
	local i = 0 -- 319
	do -- 319
		i = 0 -- 320
		while i < #self.ghosts do -- 320
			do -- 320
				local g = self.ghosts[i + 1] -- 321
				local sepX = g.x - p.player.x -- 322
				local sepY = g.y + g.depth * DEPTH_Y_SCALE - (p.player.y + p.player.depth * DEPTH_Y_SCALE) -- 323
				if math.sqrt(sepX * sepX + sepY * sepY) < MIN_DRAW_SEPARATION_PX then -- 324
					goto __continue41 -- 325
				end -- 325
				local ratio = math.max( -- 328
					0, -- 328
					math.min(1, g.life / g.maxLife) -- 328
				) -- 328
				local rollDamp = g.rolling and 0.55 or 1 -- 329
				local normAlpha = ratio ^ 1.8 * MAX_GHOST_ALPHA * rollDamp -- 330
				if normAlpha <= 0.015 then -- 331
					goto __continue41 -- 332
				end -- 332
				if normAlpha > peakAlpha then -- 334
					peakAlpha = normAlpha -- 335
				end -- 335
				local cx = cam:sx(g.x) -- 338
				local by = cam:sy(g.y, g.depth) -- 339
				local fullH = cam:len(g.h) -- 340
				local bodyH = g.rolling and fullH * 0.62 or (g.crouched and fullH * 0.8 or fullH) -- 341
				local halfW = fullH * 0.14 -- 342
				local f = g.facing -- 343
				local whiteAlpha = math.floor(normAlpha * 255 + 0.5) -- 345
				local goldAlpha = math.floor(normAlpha * 0.82 * 255 + 0.5) -- 346
				local coldWhite = Color(224, 232, 240, whiteAlpha) -- 347
				local coldFill = Color( -- 348
					210, -- 348
					222, -- 348
					236, -- 348
					math.floor(whiteAlpha * 0.28 + 0.5) -- 348
				) -- 348
				local paleGold = Color(218, 190, 128, goldAlpha) -- 349
				local hipY = by + bodyH * 0.44 -- 352
				local shY = by + bodyH * 0.78 -- 353
				local headY = by + bodyH * 0.9 -- 354
				local headR = fullH * 0.075 -- 355
				local lean = f * fullH * 0.05 -- 356
				fgDraw:drawPolygon( -- 359
					{ -- 359
						Vec2(cx - halfW * 1.15 - f * 4, hipY - bodyH * 0.1), -- 360
						Vec2(cx + halfW * 0.78 + lean, hipY + 2), -- 361
						Vec2(cx + halfW * 0.96 + lean, shY), -- 362
						Vec2(cx - halfW * 0.88 + lean * 0.5, shY) -- 363
					}, -- 363
					coldFill, -- 364
					1.05, -- 364
					coldWhite -- 364
				) -- 364
				fgDraw:drawSegment( -- 367
					Vec2(cx - halfW * 0.25, hipY), -- 367
					Vec2(cx - f * halfW * 1.05, by + 2), -- 367
					1.4, -- 367
					coldWhite -- 367
				) -- 367
				fgDraw:drawSegment( -- 368
					Vec2(cx + halfW * 0.25, hipY), -- 368
					Vec2(cx + f * halfW * 0.85, by + 2), -- 368
					1.4, -- 368
					coldWhite -- 368
				) -- 368
				fgDraw:drawPolygon( -- 371
					{ -- 371
						Vec2(cx + lean - headR * 1.55, headY + headR * 0.15), -- 372
						Vec2(cx + lean + headR * 1.55, headY + headR * 0.15), -- 373
						Vec2(cx + lean + f * 1.5, headY + headR * 1.25) -- 374
					}, -- 374
					coldFill, -- 375
					1, -- 375
					coldWhite -- 375
				) -- 375
				fgGlow:drawSegment( -- 378
					Vec2(cx - halfW * 0.55 + lean * 0.5, shY - 2), -- 379
					Vec2(cx + halfW * 0.48 + lean * 0.6, hipY + 4), -- 380
					1.3, -- 381
					paleGold -- 382
				) -- 382
				drawEllipseOutline( -- 386
					fgDraw, -- 386
					cx, -- 386
					by + 1, -- 386
					halfW * 1.05, -- 386
					2.4, -- 386
					Color(0, 0, 0, 0), -- 386
					0.9, -- 386
					paleGold, -- 386
					16 -- 386
				) -- 386
				local midY = by + bodyH * 0.56 -- 389
				if hasPrevTrail and math.abs(cx - prevTrailX) < cam:len(72) then -- 390
					fgGlow:drawSegment( -- 391
						Vec2(prevTrailX, prevTrailY), -- 392
						Vec2(cx, midY), -- 393
						1, -- 394
						Color( -- 395
							220, -- 395
							198, -- 395
							146, -- 395
							math.floor(goldAlpha * 0.55 + 0.5) -- 395
						) -- 395
					) -- 395
				end -- 395
				prevTrailX = cx -- 398
				prevTrailY = midY -- 399
				hasPrevTrail = true -- 400
			end -- 400
			::__continue41:: -- 400
			i = i + 1 -- 320
		end -- 320
	end -- 320
	self.maxRenderedAlpha = peakAlpha -- 403
end -- 301
function ____exports.createAfterimageArtifactPlugin() -- 407
	return __TS__New(____exports.AfterimageArtifactPlugin) -- 408
end -- 407
return ____exports -- 407
