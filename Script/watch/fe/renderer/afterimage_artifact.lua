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
		ctx.audio:playFoley( -- 293
			"afterimage:whoosh", -- 293
			"assets/audio/combat/afterimage_whoosh.wav", -- 293
			0.34, -- 293
			ctx.audio:panForWorldX(a.x), -- 293
			300 -- 293
		) -- 293
		self.sampleTimer = 0 -- 294
		self.lastSampleX = a.x -- 295
		self.lastSampleY = a.y -- 296
		self.lastSampleDepth = a.depth -- 297
	end -- 297
end -- 209
function AfterimageArtifactPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 301
	if not self.active or #self.ghosts == 0 then -- 301
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
				local sepY = g.y + g.depth - (p.player.y + p.player.depth) -- 323
				if math.sqrt(sepX * sepX + sepY * sepY) < MIN_DRAW_SEPARATION_PX then -- 323
					goto __continue41 -- 325
				end -- 325
				local ratio = math.max( -- 328
					0, -- 328
					math.min(1, g.life / g.maxLife) -- 328
				) -- 328
				local rollDamp = g.rolling and 0.55 or 1 -- 329
				local normAlpha = ratio ^ 1.8 * MAX_GHOST_ALPHA * rollDamp -- 330
				if normAlpha <= 0.015 then -- 330
					goto __continue41 -- 332
				end -- 332
				if normAlpha > peakAlpha then -- 332
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
				if hasPrevTrail and math.abs(cx - prevTrailX) < cam:len(72) then -- 389
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