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
local MAX_GHOSTS = 7 -- 70
local SAMPLE_INTERVAL_SEC = 0.056 -- 71
local MIN_STEP_DIST_PX = 18 -- 72
local MIN_DRAW_SEPARATION_PX = 16 -- 73
local GHOST_MAX_LIFE_SEC = 0.42 -- 74
local MAX_GHOST_ALPHA = 0.34 -- 75
local function asRecord(v) -- 77
	if v ~= nil and type(v) == "table" then -- 77
		return v -- 79
	end -- 79
	return nil -- 81
end -- 77
local function readBool(rec, key) -- 84
	if rec == nil then -- 84
		return nil -- 86
	end -- 86
	local val = rec[key] -- 88
	local ____temp_0 -- 89
	if type(val) == "boolean" then -- 89
		____temp_0 = val -- 89
	else -- 89
		____temp_0 = nil -- 89
	end -- 89
	return ____temp_0 -- 89
end -- 84
local function readStr(rec, key) -- 92
	if rec == nil then -- 92
		return nil -- 94
	end -- 94
	local val = rec[key] -- 96
	return type(val) == "string" and val or nil -- 97
end -- 92
local function drawEllipseOutline(draw, cx, cy, rx, ry, fillCol, borderWidth, borderCol, segments) -- 100
	if segments == nil then -- 100
		segments = 18 -- 109
	end -- 109
	if rx <= 0.4 or ry <= 0.4 then -- 109
		return -- 112
	end -- 112
	local pts = {} -- 114
	local step = math.pi * 2 / segments -- 115
	local i = 0 -- 116
	do -- 116
		i = 0 -- 117
		while i < segments do -- 117
			local a = i * step -- 118
			pts[#pts + 1] = Vec2( -- 119
				cx + math.cos(a) * rx, -- 119
				cy + math.sin(a) * ry -- 119
			) -- 119
			i = i + 1 -- 117
		end -- 117
	end -- 117
	draw:drawPolygon(pts, fillCol, borderWidth, borderCol) -- 121
end -- 100
____exports.AfterimageArtifactPlugin = __TS__Class() -- 124
local AfterimageArtifactPlugin = ____exports.AfterimageArtifactPlugin -- 124
AfterimageArtifactPlugin.name = "AfterimageArtifactPlugin" -- 124
function AfterimageArtifactPlugin.prototype.____constructor(self) -- 124
	self.id = "fe-06-afterimage-artifact" -- 125
	self.ghosts = {} -- 127
	self.sampleTimer = 0 -- 128
	self.hasLastSample = false -- 129
	self.lastSampleX = 0 -- 130
	self.lastSampleY = 0 -- 131
	self.lastSampleDepth = 0 -- 132
	self.active = false -- 134
	self.lastOwned = false -- 135
	self.lastEquipped = false -- 136
	self.lastWeaponId = "" -- 137
	self.totalSpawned = 0 -- 138
	self.maxRenderedAlpha = 0 -- 139
	self.lastWorldDt = 0 -- 140
	self.slowedByTimeScale = false -- 141
end -- 124
function AfterimageArtifactPlugin.prototype.syncRuntimeHook(self) -- 144
	local g = _G -- 145
	local ____temp_1 -- 146
	if g.package ~= nil then -- 146
		____temp_1 = g.package.loaded -- 146
	else -- 146
		____temp_1 = nil -- 146
	end -- 146
	local loaded = ____temp_1 -- 146
	if loaded == nil then -- 146
		return -- 148
	end -- 148
	local rawFe = loaded["watch.fe"] -- 150
	if rawFe ~= nil and type(rawFe) == "table" then -- 150
		local watchFe = rawFe -- 152
		if watchFe.afterimageArtifact ~= self then -- 152
			watchFe.afterimageArtifact = self -- 154
		end -- 154
	end -- 154
end -- 144
function AfterimageArtifactPlugin.prototype.setEquippedOverride(self, equipped) -- 160
	self.equippedOverride = equipped -- 161
end -- 160
function AfterimageArtifactPlugin.prototype.getDebugState(self) -- 164
	return { -- 165
		active = self.active, -- 166
		artifactOwned = self.lastOwned, -- 167
		equipped = self.lastEquipped, -- 168
		equippedWeapon = self.lastWeaponId, -- 169
		ghostCount = #self.ghosts, -- 170
		maxGhosts = MAX_GHOSTS, -- 171
		totalSpawned = self.totalSpawned, -- 172
		maxRenderedAlpha = self.maxRenderedAlpha, -- 173
		lastWorldDt = self.lastWorldDt, -- 174
		slowedByTimeScale = self.slowedByTimeScale -- 175
	} -- 175
end -- 164
function AfterimageArtifactPlugin.prototype.onBindPlay(self, _p, _view) -- 179
	self:syncRuntimeHook() -- 180
	self:clearGhosts() -- 181
	self.active = false -- 182
	self.totalSpawned = 0 -- 183
	self.maxRenderedAlpha = 0 -- 184
	self.lastWorldDt = 0 -- 185
	self.slowedByTimeScale = false -- 186
end -- 179
function AfterimageArtifactPlugin.prototype.clearGhosts(self) -- 189
	self.ghosts = {} -- 190
	self.sampleTimer = 0 -- 191
	self.hasLastSample = false -- 192
end -- 189
function AfterimageArtifactPlugin.prototype.resolveEquipped(self, p, view) -- 195
	local pRec = asRecord(p) -- 196
	local runRec = asRecord(p.run) -- 197
	local weaponId = view.craftBench.equippedWeapon ~= "" and view.craftBench.equippedWeapon or (readStr(pRec, "equippedWeapon") or readStr(runRec, "equippedWeapon") or "") -- 198
	if self.equippedOverride ~= nil then -- 198
		return {equipped = self.equippedOverride, weaponId = weaponId} -- 203
	end -- 203
	if readBool(pRec, "artifactEquipped") == true or readBool(runRec, "artifactEquipped") == true then -- 203
		return {equipped = true, weaponId = weaponId} -- 206
	end -- 206
	return { -- 208
		equipped = ____exports.isArtifactWeaponId(weaponId), -- 208
		weaponId = weaponId -- 208
	} -- 208
end -- 195
function AfterimageArtifactPlugin.prototype.update(self, ctx) -- 211
	self:syncRuntimeHook() -- 212
	local p = ctx.p -- 213
	local view = ctx.view -- 214
	local owned = view.archive.artifactOwned -- 216
	local eq = self:resolveEquipped(p, view) -- 217
	self.lastOwned = owned -- 218
	self.lastEquipped = eq.equipped -- 219
	self.lastWeaponId = eq.weaponId -- 220
	self.slowedByTimeScale = view.timeScale > 0 and view.timeScale < 0.99 -- 221
	local allowedMode = view.visualMode == "pixel" and not p.childMode and p.player.alive and view.storyRoute ~= "child" -- 223
	self.active = owned and eq.equipped and allowedMode -- 228
	if not self.active then -- 228
		if #self.ghosts > 0 then -- 228
			self:clearGhosts() -- 232
		end -- 232
		self.lastWorldDt = 0 -- 234
		self.maxRenderedAlpha = 0 -- 235
		return -- 236
	end -- 236
	if ctx.paused or ctx.worldDt <= 0 then -- 236
		self.lastWorldDt = 0 -- 241
		return -- 242
	end -- 242
	local dt = ctx.worldDt -- 245
	self.lastWorldDt = dt -- 246
	local write = 0 -- 249
	local i = 0 -- 250
	do -- 250
		i = 0 -- 251
		while i < #self.ghosts do -- 251
			local g = self.ghosts[i + 1] -- 252
			g.life = g.life - dt -- 253
			if g.life > 0 then -- 253
				self.ghosts[write + 1] = g -- 255
				write = write + 1 -- 256
			end -- 256
			i = i + 1 -- 251
		end -- 251
	end -- 251
	__TS__ArraySetLength(self.ghosts, write) -- 251
	local a = p.player -- 262
	local speed = math.sqrt(a.vx * a.vx + a.vy * a.vy + a.depthSpeed * a.depthSpeed) -- 263
	if not self.hasLastSample then -- 263
		self.lastSampleX = a.x -- 265
		self.lastSampleY = a.y -- 266
		self.lastSampleDepth = a.depth -- 267
		self.hasLastSample = true -- 268
		return -- 269
	end -- 269
	self.sampleTimer = self.sampleTimer + dt -- 272
	local dx = a.x - self.lastSampleX -- 273
	local dy = a.y + a.depth * DEPTH_Y_SCALE - (self.lastSampleY + self.lastSampleDepth * DEPTH_Y_SCALE) -- 274
	local dist = math.sqrt(dx * dx + dy * dy) -- 275
	if dist >= MIN_STEP_DIST_PX and self.sampleTimer >= SAMPLE_INTERVAL_SEC * 0.65 or speed > 28 and dist >= 4.5 and self.sampleTimer >= SAMPLE_INTERVAL_SEC then -- 275
		local ____self_ghosts_2 = self.ghosts -- 275
		____self_ghosts_2[#____self_ghosts_2 + 1] = { -- 279
			x = self.lastSampleX, -- 280
			y = self.lastSampleY, -- 281
			depth = self.lastSampleDepth, -- 282
			h = a.h, -- 283
			facing = a.facing >= 0 and 1 or -1, -- 284
			crouched = a.covered or a.crouch, -- 285
			rolling = a.rollT > 0, -- 286
			carrying = view.backCarry.active, -- 287
			life = GHOST_MAX_LIFE_SEC, -- 288
			maxLife = GHOST_MAX_LIFE_SEC -- 289
		} -- 289
		if #self.ghosts > MAX_GHOSTS then -- 289
			table.remove(self.ghosts, 1) -- 292
		end -- 292
		self.totalSpawned = self.totalSpawned + 1 -- 294
		ctx.audio:playFoley( -- 295
			"afterimage:whoosh", -- 295
			"assets/audio/combat/afterimage_whoosh.wav", -- 295
			0.34, -- 295
			ctx.audio:panForWorldX(a.x), -- 295
			300 -- 295
		) -- 295
		self.sampleTimer = 0 -- 296
		self.lastSampleX = a.x -- 297
		self.lastSampleY = a.y -- 298
		self.lastSampleDepth = a.depth -- 299
	end -- 299
end -- 211
function AfterimageArtifactPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 303
	if not self.active or #self.ghosts == 0 then -- 303
		self.maxRenderedAlpha = 0 -- 310
		return -- 311
	end -- 311
	local p = ctx.p -- 314
	local cam = ctx.cam -- 315
	local peakAlpha = 0 -- 316
	local prevTrailX = 0 -- 317
	local prevTrailY = 0 -- 318
	local hasPrevTrail = false -- 319
	local i = 0 -- 321
	do -- 321
		i = 0 -- 322
		while i < #self.ghosts do -- 322
			do -- 322
				local g = self.ghosts[i + 1] -- 323
				local sepX = g.x - p.player.x -- 324
				local sepY = g.y + g.depth * DEPTH_Y_SCALE - (p.player.y + p.player.depth * DEPTH_Y_SCALE) -- 325
				if math.sqrt(sepX * sepX + sepY * sepY) < MIN_DRAW_SEPARATION_PX then -- 325
					goto __continue41 -- 327
				end -- 327
				local ratio = math.max( -- 330
					0, -- 330
					math.min(1, g.life / g.maxLife) -- 330
				) -- 330
				local rollDamp = g.rolling and 0.55 or 1 -- 331
				local normAlpha = ratio ^ 1.8 * MAX_GHOST_ALPHA * rollDamp -- 332
				if normAlpha <= 0.015 then -- 332
					goto __continue41 -- 334
				end -- 334
				if normAlpha > peakAlpha then -- 334
					peakAlpha = normAlpha -- 337
				end -- 337
				local cx = cam:sx(g.x) -- 340
				local by = cam:sy(g.y, g.depth) -- 341
				local fullH = cam:len(g.h) -- 342
				local bodyH = g.rolling and fullH * 0.62 or (g.crouched and fullH * 0.8 or fullH) -- 343
				local halfW = fullH * 0.14 -- 344
				local f = g.facing -- 345
				local goldAlpha = math.floor(normAlpha * 0.82 * 255 + 0.5) -- 347
				local paleGold = Color(218, 190, 128, goldAlpha) -- 348
				local ghostSlot = g.rolling and "soldier_roll" or (g.crouched and "soldier_cover" or (g.carrying and "fe_carry_walk" or "soldier_run")) -- 351
				local ghostW = cam:len(g.carrying and 36 or 28) -- 354
				local ghostLayer = p.room.depth ~= nil and depthOrder(g.depth, 2) or 2 -- 355
				worldArt:tryPlace( -- 356
					ghostSlot, -- 356
					"fe06_ghost_" .. tostring(i), -- 356
					cx, -- 356
					by, -- 356
					ghostW, -- 356
					bodyH, -- 356
					{ -- 356
						facing = f, -- 357
						frame = i, -- 358
						color = Color(216, 228, 242, 255), -- 359
						opacity = normAlpha, -- 360
						layer = ghostLayer -- 361
					} -- 361
				) -- 361
				drawEllipseOutline( -- 365
					fgDraw, -- 365
					cx, -- 365
					by + 1, -- 365
					halfW * 1.05, -- 365
					2.4, -- 365
					Color(0, 0, 0, 0), -- 365
					0.9, -- 365
					paleGold, -- 365
					16 -- 365
				) -- 365
				local midY = by + bodyH * 0.56 -- 368
				if hasPrevTrail and math.abs(cx - prevTrailX) < cam:len(72) then -- 368
					fgGlow:drawSegment( -- 370
						Vec2(prevTrailX, prevTrailY), -- 371
						Vec2(cx, midY), -- 372
						1, -- 373
						Color( -- 374
							220, -- 374
							198, -- 374
							146, -- 374
							math.floor(goldAlpha * 0.55 + 0.5) -- 374
						) -- 374
					) -- 374
				end -- 374
				prevTrailX = cx -- 377
				prevTrailY = midY -- 378
				hasPrevTrail = true -- 379
			end -- 379
			::__continue41:: -- 379
			i = i + 1 -- 322
		end -- 322
	end -- 322
	self.maxRenderedAlpha = peakAlpha -- 382
end -- 303
function ____exports.createAfterimageArtifactPlugin() -- 386
	return __TS__New(____exports.AfterimageArtifactPlugin) -- 387
end -- 386
return ____exports -- 386