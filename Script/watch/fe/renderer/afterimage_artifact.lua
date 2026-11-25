-- [ts]: afterimage_artifact.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 17
local Color = ____Dora.Color -- 17
local Vec2 = ____Dora.Vec2 -- 17
____exports.ARTIFACT_WEAPON_IDS = { -- 23
	"time_shuttler", -- 24
	"time_shuttle", -- 25
	"shuttler", -- 26
	"time_artifact", -- 27
	"artifact", -- 28
	"时间穿梭器" -- 29
} -- 29
function ____exports.isArtifactWeaponId(weaponId) -- 32
	local i = 0 -- 33
	do -- 33
		i = 0 -- 34
		while i < #____exports.ARTIFACT_WEAPON_IDS do -- 34
			if ____exports.ARTIFACT_WEAPON_IDS[i + 1] == weaponId then -- 34
				return true -- 36
			end -- 36
			i = i + 1 -- 34
		end -- 34
	end -- 34
	return false -- 39
end -- 32
local MAX_GHOSTS = 7 -- 68
local SAMPLE_INTERVAL_SEC = 0.056 -- 69
local MIN_STEP_DIST_PX = 18 -- 70
local MIN_DRAW_SEPARATION_PX = 16 -- 71
local GHOST_MAX_LIFE_SEC = 0.42 -- 72
local MAX_GHOST_ALPHA = 0.34 -- 73
local function asRecord(v) -- 75
	if v ~= nil and type(v) == "table" then -- 75
		return v -- 77
	end -- 77
	return nil -- 79
end -- 75
local function readBool(rec, key) -- 82
	if rec == nil then -- 82
		return nil -- 84
	end -- 84
	local val = rec[key] -- 86
	local ____temp_0 -- 87
	if type(val) == "boolean" then -- 87
		____temp_0 = val -- 87
	else -- 87
		____temp_0 = nil -- 87
	end -- 87
	return ____temp_0 -- 87
end -- 82
local function readStr(rec, key) -- 90
	if rec == nil then -- 90
		return nil -- 92
	end -- 92
	local val = rec[key] -- 94
	return type(val) == "string" and val or nil -- 95
end -- 90
local function drawEllipseOutline(draw, cx, cy, rx, ry, fillCol, borderWidth, borderCol, segments) -- 98
	if segments == nil then -- 98
		segments = 18 -- 107
	end -- 107
	if rx <= 0.4 or ry <= 0.4 then -- 107
		return -- 110
	end -- 110
	local pts = {} -- 112
	local step = math.pi * 2 / segments -- 113
	local i = 0 -- 114
	do -- 114
		i = 0 -- 115
		while i < segments do -- 115
			local a = i * step -- 116
			pts[#pts + 1] = Vec2( -- 117
				cx + math.cos(a) * rx, -- 117
				cy + math.sin(a) * ry -- 117
			) -- 117
			i = i + 1 -- 115
		end -- 115
	end -- 115
	draw:drawPolygon(pts, fillCol, borderWidth, borderCol) -- 119
end -- 98
____exports.AfterimageArtifactPlugin = __TS__Class() -- 122
local AfterimageArtifactPlugin = ____exports.AfterimageArtifactPlugin -- 122
AfterimageArtifactPlugin.name = "AfterimageArtifactPlugin" -- 122
function AfterimageArtifactPlugin.prototype.____constructor(self) -- 122
	self.id = "fe-06-afterimage-artifact" -- 123
	self.ghosts = {} -- 125
	self.sampleTimer = 0 -- 126
	self.hasLastSample = false -- 127
	self.lastSampleX = 0 -- 128
	self.lastSampleY = 0 -- 129
	self.lastSampleDepth = 0 -- 130
	self.active = false -- 132
	self.lastOwned = false -- 133
	self.lastEquipped = false -- 134
	self.lastWeaponId = "" -- 135
	self.totalSpawned = 0 -- 136
	self.maxRenderedAlpha = 0 -- 137
	self.lastWorldDt = 0 -- 138
	self.slowedByTimeScale = false -- 139
end -- 122
function AfterimageArtifactPlugin.prototype.syncRuntimeHook(self) -- 142
	local g = _G -- 143
	local ____temp_1 -- 144
	if g.package ~= nil then -- 144
		____temp_1 = g.package.loaded -- 144
	else -- 144
		____temp_1 = nil -- 144
	end -- 144
	local loaded = ____temp_1 -- 144
	if loaded == nil then -- 144
		return -- 146
	end -- 146
	local rawFe = loaded["watch.fe"] -- 148
	if rawFe ~= nil and type(rawFe) == "table" then -- 148
		local watchFe = rawFe -- 150
		if watchFe.afterimageArtifact ~= self then -- 150
			watchFe.afterimageArtifact = self -- 152
		end -- 152
	end -- 152
end -- 142
function AfterimageArtifactPlugin.prototype.setEquippedOverride(self, equipped) -- 158
	self.equippedOverride = equipped -- 159
end -- 158
function AfterimageArtifactPlugin.prototype.getDebugState(self) -- 162
	return { -- 163
		active = self.active, -- 164
		artifactOwned = self.lastOwned, -- 165
		equipped = self.lastEquipped, -- 166
		equippedWeapon = self.lastWeaponId, -- 167
		ghostCount = #self.ghosts, -- 168
		maxGhosts = MAX_GHOSTS, -- 169
		totalSpawned = self.totalSpawned, -- 170
		maxRenderedAlpha = self.maxRenderedAlpha, -- 171
		lastWorldDt = self.lastWorldDt, -- 172
		slowedByTimeScale = self.slowedByTimeScale -- 173
	} -- 173
end -- 162
function AfterimageArtifactPlugin.prototype.onBindPlay(self, _p, _view) -- 177
	self:syncRuntimeHook() -- 178
	self:clearGhosts() -- 179
	self.active = false -- 180
	self.totalSpawned = 0 -- 181
	self.maxRenderedAlpha = 0 -- 182
	self.lastWorldDt = 0 -- 183
	self.slowedByTimeScale = false -- 184
end -- 177
function AfterimageArtifactPlugin.prototype.clearGhosts(self) -- 187
	self.ghosts = {} -- 188
	self.sampleTimer = 0 -- 189
	self.hasLastSample = false -- 190
end -- 187
function AfterimageArtifactPlugin.prototype.resolveEquipped(self, p, view) -- 193
	local pRec = asRecord(p) -- 194
	local runRec = asRecord(p.run) -- 195
	local weaponId = view.craftBench.equippedWeapon ~= "" and view.craftBench.equippedWeapon or (readStr(pRec, "equippedWeapon") or readStr(runRec, "equippedWeapon") or "") -- 196
	if self.equippedOverride ~= nil then -- 196
		return {equipped = self.equippedOverride, weaponId = weaponId} -- 201
	end -- 201
	if readBool(pRec, "artifactEquipped") == true or readBool(runRec, "artifactEquipped") == true then -- 201
		return {equipped = true, weaponId = weaponId} -- 204
	end -- 204
	return { -- 206
		equipped = ____exports.isArtifactWeaponId(weaponId), -- 206
		weaponId = weaponId -- 206
	} -- 206
end -- 193
function AfterimageArtifactPlugin.prototype.update(self, ctx) -- 209
	self:syncRuntimeHook() -- 210
	local p = ctx.p -- 211
	local view = ctx.view -- 212
	local owned = view.archive.artifactOwned -- 214
	local eq = self:resolveEquipped(p, view) -- 215
	self.lastOwned = owned -- 216
	self.lastEquipped = eq.equipped -- 217
	self.lastWeaponId = eq.weaponId -- 218
	self.slowedByTimeScale = view.timeScale > 0 and view.timeScale < 0.99 -- 219
	local allowedMode = view.visualMode == "pixel" and not p.childMode and p.player.alive and view.storyRoute ~= "child" -- 221
	self.active = owned and eq.equipped and allowedMode -- 226
	if not self.active then -- 226
		if #self.ghosts > 0 then -- 226
			self:clearGhosts() -- 230
		end -- 230
		self.lastWorldDt = 0 -- 232
		self.maxRenderedAlpha = 0 -- 233
		return -- 234
	end -- 234
	if ctx.paused or ctx.worldDt <= 0 then -- 234
		self.lastWorldDt = 0 -- 239
		return -- 240
	end -- 240
	local dt = ctx.worldDt -- 243
	self.lastWorldDt = dt -- 244
	local write = 0 -- 247
	local i = 0 -- 248
	do -- 248
		i = 0 -- 249
		while i < #self.ghosts do -- 249
			local g = self.ghosts[i + 1] -- 250
			g.life = g.life - dt -- 251
			if g.life > 0 then -- 251
				self.ghosts[write + 1] = g -- 253
				write = write + 1 -- 254
			end -- 254
			i = i + 1 -- 249
		end -- 249
	end -- 249
	__TS__ArraySetLength(self.ghosts, write) -- 249
	local a = p.player -- 260
	local speed = math.sqrt(a.vx * a.vx + a.vy * a.vy + a.depthSpeed * a.depthSpeed) -- 261
	if not self.hasLastSample then -- 261
		self.lastSampleX = a.x -- 263
		self.lastSampleY = a.y -- 264
		self.lastSampleDepth = a.depth -- 265
		self.hasLastSample = true -- 266
		return -- 267
	end -- 267
	self.sampleTimer = self.sampleTimer + dt -- 270
	local dx = a.x - self.lastSampleX -- 271
	local dy = a.y + a.depth - (self.lastSampleY + self.lastSampleDepth) -- 272
	local dist = math.sqrt(dx * dx + dy * dy) -- 273
	if dist >= MIN_STEP_DIST_PX and self.sampleTimer >= SAMPLE_INTERVAL_SEC * 0.65 or speed > 28 and dist >= 4.5 and self.sampleTimer >= SAMPLE_INTERVAL_SEC then -- 273
		local ____self_ghosts_2 = self.ghosts -- 273
		____self_ghosts_2[#____self_ghosts_2 + 1] = { -- 277
			x = self.lastSampleX, -- 278
			y = self.lastSampleY, -- 279
			depth = self.lastSampleDepth, -- 280
			h = a.h, -- 281
			facing = a.facing >= 0 and 1 or -1, -- 282
			crouched = a.covered or a.crouch, -- 283
			rolling = a.rollT > 0, -- 284
			carrying = view.backCarry.active, -- 285
			life = GHOST_MAX_LIFE_SEC, -- 286
			maxLife = GHOST_MAX_LIFE_SEC -- 287
		} -- 287
		if #self.ghosts > MAX_GHOSTS then -- 287
			table.remove(self.ghosts, 1) -- 290
		end -- 290
		self.totalSpawned = self.totalSpawned + 1 -- 292
		self.sampleTimer = 0 -- 293
		self.lastSampleX = a.x -- 294
		self.lastSampleY = a.y -- 295
		self.lastSampleDepth = a.depth -- 296
	end -- 296
end -- 209
function AfterimageArtifactPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 300
	if not self.active or #self.ghosts == 0 then -- 300
		self.maxRenderedAlpha = 0 -- 307
		return -- 308
	end -- 308
	local p = ctx.p -- 311
	local cam = ctx.cam -- 312
	local peakAlpha = 0 -- 313
	local prevTrailX = 0 -- 314
	local prevTrailY = 0 -- 315
	local hasPrevTrail = false -- 316
	local i = 0 -- 318
	do -- 318
		i = 0 -- 319
		while i < #self.ghosts do -- 319
			do -- 319
				local g = self.ghosts[i + 1] -- 320
				local sepX = g.x - p.player.x -- 321
				local sepY = g.y + g.depth - (p.player.y + p.player.depth) -- 322
				if math.sqrt(sepX * sepX + sepY * sepY) < MIN_DRAW_SEPARATION_PX then -- 322
					goto __continue41 -- 324
				end -- 324
				local ratio = math.max( -- 327
					0, -- 327
					math.min(1, g.life / g.maxLife) -- 327
				) -- 327
				local rollDamp = g.rolling and 0.55 or 1 -- 328
				local normAlpha = ratio ^ 1.8 * MAX_GHOST_ALPHA * rollDamp -- 329
				if normAlpha <= 0.015 then -- 329
					goto __continue41 -- 331
				end -- 331
				if normAlpha > peakAlpha then -- 331
					peakAlpha = normAlpha -- 334
				end -- 334
				local cx = cam:sx(g.x) -- 337
				local by = cam:sy(g.y, g.depth) -- 338
				local fullH = cam:len(g.h) -- 339
				local bodyH = g.rolling and fullH * 0.62 or (g.crouched and fullH * 0.8 or fullH) -- 340
				local halfW = fullH * 0.14 -- 341
				local f = g.facing -- 342
				local whiteAlpha = math.floor(normAlpha * 255 + 0.5) -- 344
				local goldAlpha = math.floor(normAlpha * 0.82 * 255 + 0.5) -- 345
				local coldWhite = Color(224, 232, 240, whiteAlpha) -- 346
				local coldFill = Color( -- 347
					210, -- 347
					222, -- 347
					236, -- 347
					math.floor(whiteAlpha * 0.28 + 0.5) -- 347
				) -- 347
				local paleGold = Color(218, 190, 128, goldAlpha) -- 348
				local hipY = by + bodyH * 0.44 -- 351
				local shY = by + bodyH * 0.78 -- 352
				local headY = by + bodyH * 0.9 -- 353
				local headR = fullH * 0.075 -- 354
				local lean = f * fullH * 0.05 -- 355
				fgDraw:drawPolygon( -- 358
					{ -- 358
						Vec2(cx - halfW * 1.15 - f * 4, hipY - bodyH * 0.1), -- 359
						Vec2(cx + halfW * 0.78 + lean, hipY + 2), -- 360
						Vec2(cx + halfW * 0.96 + lean, shY), -- 361
						Vec2(cx - halfW * 0.88 + lean * 0.5, shY) -- 362
					}, -- 362
					coldFill, -- 363
					1.05, -- 363
					coldWhite -- 363
				) -- 363
				fgDraw:drawSegment( -- 366
					Vec2(cx - halfW * 0.25, hipY), -- 366
					Vec2(cx - f * halfW * 1.05, by + 2), -- 366
					1.4, -- 366
					coldWhite -- 366
				) -- 366
				fgDraw:drawSegment( -- 367
					Vec2(cx + halfW * 0.25, hipY), -- 367
					Vec2(cx + f * halfW * 0.85, by + 2), -- 367
					1.4, -- 367
					coldWhite -- 367
				) -- 367
				fgDraw:drawPolygon( -- 370
					{ -- 370
						Vec2(cx + lean - headR * 1.55, headY + headR * 0.15), -- 371
						Vec2(cx + lean + headR * 1.55, headY + headR * 0.15), -- 372
						Vec2(cx + lean + f * 1.5, headY + headR * 1.25) -- 373
					}, -- 373
					coldFill, -- 374
					1, -- 374
					coldWhite -- 374
				) -- 374
				fgGlow:drawSegment( -- 377
					Vec2(cx - halfW * 0.55 + lean * 0.5, shY - 2), -- 378
					Vec2(cx + halfW * 0.48 + lean * 0.6, hipY + 4), -- 379
					1.3, -- 380
					paleGold -- 381
				) -- 381
				drawEllipseOutline( -- 385
					fgDraw, -- 385
					cx, -- 385
					by + 1, -- 385
					halfW * 1.05, -- 385
					2.4, -- 385
					Color(0, 0, 0, 0), -- 385
					0.9, -- 385
					paleGold, -- 385
					16 -- 385
				) -- 385
				local midY = by + bodyH * 0.56 -- 388
				if hasPrevTrail and math.abs(cx - prevTrailX) < cam:len(72) then -- 388
					fgGlow:drawSegment( -- 390
						Vec2(prevTrailX, prevTrailY), -- 391
						Vec2(cx, midY), -- 392
						1, -- 393
						Color( -- 394
							220, -- 394
							198, -- 394
							146, -- 394
							math.floor(goldAlpha * 0.55 + 0.5) -- 394
						) -- 394
					) -- 394
				end -- 394
				prevTrailX = cx -- 397
				prevTrailY = midY -- 398
				hasPrevTrail = true -- 399
			end -- 399
			::__continue41:: -- 399
			i = i + 1 -- 319
		end -- 319
	end -- 319
	self.maxRenderedAlpha = peakAlpha -- 402
end -- 300
function ____exports.createAfterimageArtifactPlugin() -- 406
	return __TS__New(____exports.AfterimageArtifactPlugin) -- 407
end -- 406
return ____exports -- 406