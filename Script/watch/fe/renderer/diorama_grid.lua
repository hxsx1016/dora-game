-- [ts]: diorama_grid.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 12
local BlendFunc = ____Dora.BlendFunc -- 12
local Color = ____Dora.Color -- 12
local Content = ____Dora.Content -- 12
local DrawNode = ____Dora.DrawNode -- 12
local Grid = ____Dora.Grid -- 12
local Node = ____Dora.Node -- 12
local Sprite = ____Dora.Sprite -- 12
local Vec2 = ____Dora.Vec2 -- 12
local WHITE = Color(255, 255, 255, 255) -- 95
local NORMAL_BLEND = BlendFunc("SrcAlpha", "InvSrcAlpha") -- 96
local ADDITIVE_BLEND = BlendFunc("SrcAlpha", "One") -- 97
local function fileOfClip(clipStr) -- 99
	local idx = (string.find(clipStr, "|", nil, true) or 0) - 1 -- 100
	return idx < 0 and clipStr or __TS__StringSlice(clipStr, 0, idx) -- 101
end -- 99
____exports.DioramaLayerHost = __TS__Class() -- 104
local DioramaLayerHost = ____exports.DioramaLayerHost -- 104
DioramaLayerHost.name = "DioramaLayerHost" -- 104
function DioramaLayerHost.prototype.____constructor(self, parent, order) -- 122
	self.unavailable = {} -- 106
	self.gridPools = {} -- 109
	self.gridCursor = {} -- 110
	self.spritePools = {} -- 113
	self.spriteCursor = {} -- 114
	self.drawPool = {} -- 117
	self.drawCursor = 0 -- 118
	self.orderCounter = 0 -- 120
	self.container = Node() -- 123
	self.container.order = order -- 124
	self.container:addTo(parent) -- 125
end -- 122
function DioramaLayerHost.prototype.beginFrame(self) -- 129
	self.gridCursor = {} -- 130
	self.spriteCursor = {} -- 131
	self.drawCursor = 0 -- 132
	self.orderCounter = 0 -- 133
end -- 129
function DioramaLayerHost.prototype.nextOrder(self) -- 137
	local cur = self.orderCounter -- 138
	self.orderCounter = self.orderCounter + 1 -- 139
	return cur -- 140
end -- 137
function DioramaLayerHost.prototype.acquireDrawRun(self, order) -- 144
	local node = self.drawPool[self.drawCursor + 1] -- 145
	if node == nil then -- 145
		node = DrawNode() -- 147
		node:addTo(self.container) -- 148
		self.drawPool[self.drawCursor + 1] = node -- 149
	end -- 149
	self.drawCursor = self.drawCursor + 1 -- 151
	node:clear() -- 152
	node.order = order -- 153
	node.visible = true -- 154
	return node -- 155
end -- 144
function DioramaLayerHost.prototype.placeTexturedQuad(self, params) -- 163
	if params.opacity <= 0.008 then -- 163
		return false -- 165
	end -- 165
	local segX = math.max( -- 167
		1, -- 167
		math.min( -- 167
			12, -- 167
			math.floor(params.segX) -- 167
		) -- 167
	) -- 167
	local segY = math.max( -- 168
		1, -- 168
		math.min( -- 168
			8, -- 168
			math.floor(params.segY) -- 168
		) -- 168
	) -- 168
	local add = params.additive == true -- 169
	local poolKey = ((((params.clipStr .. "#") .. tostring(segX)) .. "x") .. tostring(segY)) .. (add and ":add" or "") -- 170
	if self.unavailable[params.clipStr] == true then -- 170
		return false -- 173
	end -- 173
	local bucket = self.gridPools[poolKey] -- 176
	if bucket == nil then -- 176
		bucket = {} -- 178
		self.gridPools[poolKey] = bucket -- 179
	end -- 179
	local idx = self.gridCursor[poolKey] or 0 -- 181
	local entry = bucket[idx + 1] -- 182
	if entry == nil then -- 182
		local file = fileOfClip(params.clipStr) -- 184
		if not Content:exist(file) then -- 184
			self.unavailable[params.clipStr] = true -- 186
			return false -- 187
		end -- 187
		local grid = Grid(params.clipStr, segX, segY) -- 189
		if grid == nil then -- 189
			self.unavailable[params.clipStr] = true -- 191
			return false -- 192
		end -- 192
		grid.position = Vec2(0, 0) -- 194
		grid.blendFunc = add and ADDITIVE_BLEND or NORMAL_BLEND -- 195
		grid:addTo(self.container) -- 196
		entry = { -- 197
			node = grid, -- 197
			clipStr = params.clipStr, -- 197
			segX = segX, -- 197
			segY = segY, -- 197
			additive = add -- 197
		} -- 197
		bucket[idx + 1] = entry -- 198
	end -- 198
	self.gridCursor[poolKey] = idx + 1 -- 200
	local grid = entry.node -- 202
	local ____params_0 = params -- 203
	local v0 = ____params_0.v0 -- 203
	local v1 = ____params_0.v1 -- 203
	local v2 = ____params_0.v2 -- 203
	local v3 = ____params_0.v3 -- 203
	local projector = ____params_0.projector -- 203
	local wave = ____params_0.wave -- 203
	local iy = 1 -- 206
	do -- 206
		iy = 1 -- 207
		while iy <= segY + 1 do -- 207
			local vTop = (iy - 1) / segY -- 208
			local vBot = 1 - vTop -- 209
			local lx = v3.x * vBot + v0.x * vTop -- 211
			local ly = v3.y * vBot + v0.y * vTop -- 212
			local lz = v3.z * vBot + v0.z * vTop -- 213
			local rx = v2.x * vBot + v1.x * vTop -- 214
			local ry = v2.y * vBot + v1.y * vTop -- 215
			local rz = v2.z * vBot + v1.z * vTop -- 216
			local ix = 1 -- 218
			do -- 218
				ix = 1 -- 219
				while ix <= segX + 1 do -- 219
					local u = (ix - 1) / segX -- 220
					local wx = lx + (rx - lx) * u -- 221
					local wy = ly + (ry - ly) * u -- 222
					local wz = lz + (rz - lz) * u -- 223
					local pt = projector:project(wx, wy, wz) -- 224
					local sx = pt.x -- 225
					local sy = pt.y -- 226
					if wave ~= nil then -- 226
						local weight = 1 -- 228
						if wave.pin == "top" then -- 228
							weight = vTop * vTop -- 230
						elseif wave.pin == "left" then -- 230
							weight = u * u -- 232
						end -- 232
						local ang = wave.phase + u * wave.freqU + vTop * wave.freqV -- 234
						sx = sx + math.sin(ang) * wave.ampX * weight * pt.scale -- 235
						sy = sy + math.cos(ang * 0.85) * wave.ampY * weight * pt.scale -- 236
					end -- 236
					grid:setPos( -- 238
						ix, -- 238
						iy, -- 238
						Vec2(sx, sy) -- 238
					) -- 238
					ix = ix + 1 -- 219
				end -- 219
			end -- 219
			iy = iy + 1 -- 207
		end -- 207
	end -- 207
	grid.order = params.order -- 242
	grid.color = params.tintColor -- 243
	local baseA = params.tintColor.a / 255 -- 244
	grid.opacity = math.max( -- 245
		0, -- 245
		math.min(1, baseA * params.opacity) -- 245
	) -- 245
	grid.visible = true -- 246
	return true -- 247
end -- 163
function DioramaLayerHost.prototype.placeCutoutCard(self, params) -- 251
	local op = params.opacity or 1 -- 252
	if op <= 0.008 or params.targetW <= 0.5 or params.targetH <= 0.5 then -- 252
		return false -- 254
	end -- 254
	if self.unavailable[params.clipStr] == true then -- 254
		return false -- 257
	end -- 257
	local smooth = params.smooth ~= false -- 259
	local add = params.additive == true -- 260
	local poolKey = (params.clipStr .. (smooth and ":s" or ":p")) .. (add and ":a" or "") -- 261
	local bucket = self.spritePools[poolKey] -- 263
	if bucket == nil then -- 263
		bucket = {} -- 265
		self.spritePools[poolKey] = bucket -- 266
	end -- 266
	local idx = self.spriteCursor[poolKey] or 0 -- 268
	local entry = bucket[idx + 1] -- 269
	if entry == nil then -- 269
		local file = fileOfClip(params.clipStr) -- 271
		if not Content:exist(file) then -- 271
			self.unavailable[params.clipStr] = true -- 273
			return false -- 274
		end -- 274
		local sp = Sprite(params.clipStr) -- 276
		if sp == nil then -- 276
			self.unavailable[params.clipStr] = true -- 278
			return false -- 279
		end -- 279
		sp.filter = smooth and "Anisotropic" or "Point" -- 281
		sp.blendFunc = add and ADDITIVE_BLEND or NORMAL_BLEND -- 282
		sp:addTo(self.container) -- 283
		entry = {node = sp, clipStr = params.clipStr, smooth = smooth, additive = add} -- 284
		bucket[idx + 1] = entry -- 285
	end -- 285
	self.spriteCursor[poolKey] = idx + 1 -- 287
	local sp = entry.node -- 289
	sp.anchor = Vec2(params.anchorX or 0.5, params.anchorY or 0) -- 290
	sp.position = Vec2(params.x, params.y) -- 291
	local sx = params.targetW / math.max(1, sp.width) -- 292
	local sy = params.targetH / math.max(1, sp.height) -- 293
	sp.scaleX = (params.facing or 1) < 0 and -sx or sx -- 294
	sp.scaleY = params.flipY == true and -sy or sy -- 295
	sp.angle = params.angle or 0 -- 296
	sp.order = params.order -- 297
	local col = params.color or WHITE -- 298
	sp.color = col -- 299
	sp.opacity = math.max( -- 300
		0, -- 300
		math.min(1, col.a / 255 * op) -- 300
	) -- 300
	sp.visible = true -- 301
	return true -- 302
end -- 251
function DioramaLayerHost.prototype.endFrame(self) -- 306
	for key in pairs(self.gridPools) do -- 307
		local bucket = self.gridPools[key] -- 308
		local used = self.gridCursor[key] or 0 -- 309
		local i = used -- 310
		do -- 310
			i = used -- 311
			while i < #bucket do -- 311
				if bucket[i + 1].node.visible then -- 311
					bucket[i + 1].node.visible = false -- 313
				end -- 313
				i = i + 1 -- 311
			end -- 311
		end -- 311
	end -- 311
	for key in pairs(self.spritePools) do -- 317
		local bucket = self.spritePools[key] -- 318
		local used = self.spriteCursor[key] or 0 -- 319
		local i = used -- 320
		do -- 320
			i = used -- 321
			while i < #bucket do -- 321
				if bucket[i + 1].node.visible then -- 321
					bucket[i + 1].node.visible = false -- 323
				end -- 323
				i = i + 1 -- 321
			end -- 321
		end -- 321
	end -- 321
	local d = self.drawCursor -- 327
	do -- 327
		d = self.drawCursor -- 328
		while d < #self.drawPool do -- 328
			local dn = self.drawPool[d + 1] -- 329
			if dn.visible then -- 329
				dn:clear() -- 331
				dn.visible = false -- 332
			end -- 332
			d = d + 1 -- 328
		end -- 328
	end -- 328
end -- 306
return ____exports -- 306