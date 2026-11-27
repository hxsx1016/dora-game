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
local WHITE = Color(255, 255, 255, 255) -- 96
local NORMAL_BLEND = BlendFunc("SrcAlpha", "InvSrcAlpha") -- 97
local ADDITIVE_BLEND = BlendFunc("SrcAlpha", "One") -- 98
local function fileOfClip(clipStr) -- 100
	local idx = (string.find(clipStr, "|", nil, true) or 0) - 1 -- 101
	return idx < 0 and clipStr or __TS__StringSlice(clipStr, 0, idx) -- 102
end -- 100
____exports.DioramaLayerHost = __TS__Class() -- 105
local DioramaLayerHost = ____exports.DioramaLayerHost -- 105
DioramaLayerHost.name = "DioramaLayerHost" -- 105
function DioramaLayerHost.prototype.____constructor(self, parent, order) -- 123
	self.unavailable = {} -- 107
	self.gridPools = {} -- 110
	self.gridCursor = {} -- 111
	self.spritePools = {} -- 114
	self.spriteCursor = {} -- 115
	self.drawPool = {} -- 118
	self.drawCursor = 0 -- 119
	self.orderCounter = 0 -- 121
	self.container = Node() -- 124
	self.container.order = order -- 125
	self.container:addTo(parent) -- 126
end -- 123
function DioramaLayerHost.prototype.beginFrame(self) -- 130
	self.gridCursor = {} -- 131
	self.spriteCursor = {} -- 132
	self.drawCursor = 0 -- 133
	self.orderCounter = 0 -- 134
end -- 130
function DioramaLayerHost.prototype.nextOrder(self) -- 138
	local cur = self.orderCounter -- 139
	self.orderCounter = self.orderCounter + 1 -- 140
	return cur -- 141
end -- 138
function DioramaLayerHost.prototype.acquireDrawRun(self, order) -- 145
	local node = self.drawPool[self.drawCursor + 1] -- 146
	if node == nil then -- 146
		node = DrawNode() -- 148
		node:addTo(self.container) -- 149
		self.drawPool[self.drawCursor + 1] = node -- 150
	end -- 150
	self.drawCursor = self.drawCursor + 1 -- 152
	node:clear() -- 153
	node.order = order -- 154
	node.visible = true -- 155
	return node -- 156
end -- 145
function DioramaLayerHost.prototype.placeTexturedQuad(self, params) -- 164
	if params.opacity <= 0.008 then -- 164
		return false -- 166
	end -- 166
	local segX = math.max( -- 168
		1, -- 168
		math.min( -- 168
			12, -- 168
			math.floor(params.segX) -- 168
		) -- 168
	) -- 168
	local segY = math.max( -- 169
		1, -- 169
		math.min( -- 169
			8, -- 169
			math.floor(params.segY) -- 169
		) -- 169
	) -- 169
	local add = params.additive == true -- 170
	local poolKey = ((((params.clipStr .. "#") .. tostring(segX)) .. "x") .. tostring(segY)) .. (add and ":add" or "") -- 171
	if self.unavailable[params.clipStr] == true then -- 171
		return false -- 174
	end -- 174
	local bucket = self.gridPools[poolKey] -- 177
	if bucket == nil then -- 177
		bucket = {} -- 179
		self.gridPools[poolKey] = bucket -- 180
	end -- 180
	local idx = self.gridCursor[poolKey] or 0 -- 182
	local entry = bucket[idx + 1] -- 183
	if entry == nil then -- 183
		local file = fileOfClip(params.clipStr) -- 185
		if not Content:exist(file) then -- 185
			self.unavailable[params.clipStr] = true -- 187
			return false -- 188
		end -- 188
		local grid = Grid(params.clipStr, segX, segY) -- 190
		if grid == nil then -- 190
			self.unavailable[params.clipStr] = true -- 192
			return false -- 193
		end -- 193
		grid.position = Vec2(0, 0) -- 195
		grid.blendFunc = add and ADDITIVE_BLEND or NORMAL_BLEND -- 196
		grid:addTo(self.container) -- 197
		entry = { -- 198
			node = grid, -- 198
			clipStr = params.clipStr, -- 198
			segX = segX, -- 198
			segY = segY, -- 198
			additive = add -- 198
		} -- 198
		bucket[idx + 1] = entry -- 199
	end -- 199
	self.gridCursor[poolKey] = idx + 1 -- 201
	local grid = entry.node -- 203
	local ____params_0 = params -- 204
	local v0 = ____params_0.v0 -- 204
	local v1 = ____params_0.v1 -- 204
	local v2 = ____params_0.v2 -- 204
	local v3 = ____params_0.v3 -- 204
	local projector = ____params_0.projector -- 204
	local wave = ____params_0.wave -- 204
	local iy = 1 -- 207
	do -- 207
		iy = 1 -- 208
		while iy <= segY + 1 do -- 208
			local vTop = (iy - 1) / segY -- 209
			local vBot = 1 - vTop -- 210
			local shade = math.floor(255 * (vBot + vTop * params.bottomShade) + 0.5) -- 211
			local rowColor = Color(shade, shade, shade, 255) -- 212
			local lx = v3.x * vBot + v0.x * vTop -- 214
			local ly = v3.y * vBot + v0.y * vTop -- 215
			local lz = v3.z * vBot + v0.z * vTop -- 216
			local rx = v2.x * vBot + v1.x * vTop -- 217
			local ry = v2.y * vBot + v1.y * vTop -- 218
			local rz = v2.z * vBot + v1.z * vTop -- 219
			local ix = 1 -- 221
			do -- 221
				ix = 1 -- 222
				while ix <= segX + 1 do -- 222
					local u = (ix - 1) / segX -- 223
					local wx = lx + (rx - lx) * u -- 224
					local wy = ly + (ry - ly) * u -- 225
					local wz = lz + (rz - lz) * u -- 226
					local pt = projector:project(wx, wy, wz) -- 227
					local sx = pt.x -- 228
					local sy = pt.y -- 229
					if wave ~= nil then -- 229
						local weight = 1 -- 231
						if wave.pin == "top" then -- 231
							weight = vTop * vTop -- 233
						elseif wave.pin == "left" then -- 233
							weight = u * u -- 235
						end -- 235
						local ang = wave.phase + u * wave.freqU + vTop * wave.freqV -- 237
						sx = sx + math.sin(ang) * wave.ampX * weight * pt.scale -- 238
						sy = sy + math.cos(ang * 0.85) * wave.ampY * weight * pt.scale -- 239
					end -- 239
					grid:setPos( -- 241
						ix, -- 241
						iy, -- 241
						Vec2(sx, sy) -- 241
					) -- 241
					grid:setColor(ix, iy, rowColor) -- 242
					ix = ix + 1 -- 222
				end -- 222
			end -- 222
			iy = iy + 1 -- 208
		end -- 208
	end -- 208
	grid.order = params.order -- 246
	grid.color = params.tintColor -- 247
	local baseA = params.tintColor.a / 255 -- 248
	grid.opacity = math.max( -- 249
		0, -- 249
		math.min(1, baseA * params.opacity) -- 249
	) -- 249
	grid.visible = true -- 250
	return true -- 251
end -- 164
function DioramaLayerHost.prototype.placeCutoutCard(self, params) -- 255
	local op = params.opacity or 1 -- 256
	if op <= 0.008 or params.targetW <= 0.5 or params.targetH <= 0.5 then -- 256
		return false -- 258
	end -- 258
	if self.unavailable[params.clipStr] == true then -- 258
		return false -- 261
	end -- 261
	local smooth = params.smooth ~= false -- 263
	local add = params.additive == true -- 264
	local poolKey = (params.clipStr .. (smooth and ":s" or ":p")) .. (add and ":a" or "") -- 265
	local bucket = self.spritePools[poolKey] -- 267
	if bucket == nil then -- 267
		bucket = {} -- 269
		self.spritePools[poolKey] = bucket -- 270
	end -- 270
	local idx = self.spriteCursor[poolKey] or 0 -- 272
	local entry = bucket[idx + 1] -- 273
	if entry == nil then -- 273
		local file = fileOfClip(params.clipStr) -- 275
		if not Content:exist(file) then -- 275
			self.unavailable[params.clipStr] = true -- 277
			return false -- 278
		end -- 278
		local sp = Sprite(params.clipStr) -- 280
		if sp == nil then -- 280
			self.unavailable[params.clipStr] = true -- 282
			return false -- 283
		end -- 283
		sp.filter = smooth and "Anisotropic" or "Point" -- 285
		sp.blendFunc = add and ADDITIVE_BLEND or NORMAL_BLEND -- 286
		sp:addTo(self.container) -- 287
		entry = {node = sp, clipStr = params.clipStr, smooth = smooth, additive = add} -- 288
		bucket[idx + 1] = entry -- 289
	end -- 289
	self.spriteCursor[poolKey] = idx + 1 -- 291
	local sp = entry.node -- 293
	sp.anchor = Vec2(params.anchorX or 0.5, params.anchorY or 0) -- 294
	sp.position = Vec2(params.x, params.y) -- 295
	local sx = params.targetW / math.max(1, sp.width) -- 296
	local sy = params.targetH / math.max(1, sp.height) -- 297
	sp.scaleX = (params.facing or 1) < 0 and -sx or sx -- 298
	sp.scaleY = params.flipY == true and -sy or sy -- 299
	sp.angle = params.angle or 0 -- 300
	sp.order = params.order -- 301
	local col = params.color or WHITE -- 302
	sp.color = col -- 303
	sp.opacity = math.max( -- 304
		0, -- 304
		math.min(1, col.a / 255 * op) -- 304
	) -- 304
	sp.visible = true -- 305
	return true -- 306
end -- 255
function DioramaLayerHost.prototype.endFrame(self) -- 310
	for key in pairs(self.gridPools) do -- 311
		local bucket = self.gridPools[key] -- 312
		local used = self.gridCursor[key] or 0 -- 313
		local i = used -- 314
		do -- 314
			i = used -- 315
			while i < #bucket do -- 315
				if bucket[i + 1].node.visible then -- 315
					bucket[i + 1].node.visible = false -- 317
				end -- 317
				i = i + 1 -- 315
			end -- 315
		end -- 315
	end -- 315
	for key in pairs(self.spritePools) do -- 321
		local bucket = self.spritePools[key] -- 322
		local used = self.spriteCursor[key] or 0 -- 323
		local i = used -- 324
		do -- 324
			i = used -- 325
			while i < #bucket do -- 325
				if bucket[i + 1].node.visible then -- 325
					bucket[i + 1].node.visible = false -- 327
				end -- 327
				i = i + 1 -- 325
			end -- 325
		end -- 325
	end -- 325
	local d = self.drawCursor -- 331
	do -- 331
		d = self.drawCursor -- 332
		while d < #self.drawPool do -- 332
			local dn = self.drawPool[d + 1] -- 333
			if dn.visible then -- 333
				dn:clear() -- 335
				dn.visible = false -- 336
			end -- 336
			d = d + 1 -- 332
		end -- 332
	end -- 332
end -- 310
return ____exports -- 310