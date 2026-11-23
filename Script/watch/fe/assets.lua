-- [ts]: assets.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 9
local Content = ____Dora.Content -- 9
local Node = ____Dora.Node -- 9
local Sprite = ____Dora.Sprite -- 9
local Vec2 = ____Dora.Vec2 -- 9
--- 留空表示使用本分支的程序化 ICEY 矢量绘制。
-- 完整前端分支在此填写相对路径（如 "assets/art/soldier_idle.png"）。
____exports.ASSET_SLOTS = {} -- 34
--- 轻量 Sprite 槽位宿主：每帧仅激活实际有外部贴图资源的槽位。
____exports.AssetSlotHost = __TS__Class() -- 43
local AssetSlotHost = ____exports.AssetSlotHost -- 43
AssetSlotHost.name = "AssetSlotHost" -- 43
function AssetSlotHost.prototype.____constructor(self, parent, order) -- 48
	self.cache = {} -- 45
	self.usedThisFrame = {} -- 46
	self.container = Node() -- 49
	self.container.order = order -- 50
	self.container:addTo(parent) -- 51
end -- 48
function AssetSlotHost.prototype.beginFrame(self) -- 55
	self.usedThisFrame = {} -- 56
end -- 55
function AssetSlotHost.prototype.tryPlace(self, slotKey, instanceKey, x, y, targetW, targetH, facing, opacity) -- 63
	if facing == nil then -- 63
		facing = 1 -- 70
	end -- 70
	if opacity == nil then -- 70
		opacity = 1 -- 71
	end -- 71
	local cfg = ____exports.ASSET_SLOTS[slotKey] -- 73
	if cfg == nil or cfg.path == nil or cfg.path == "" then -- 73
		return false -- 75
	end -- 75
	local entry = self.cache[instanceKey] -- 77
	if entry == nil then -- 77
		local exists = Content:exist(cfg.path) -- 79
		entry = {checked = true, exists = exists} -- 80
		if exists then -- 80
			local sp = Sprite(cfg.path) -- 82
			if sp ~= nil then -- 82
				sp.anchor = Vec2(cfg.anchorX ~= nil and cfg.anchorX or 0.5, cfg.anchorY ~= nil and cfg.anchorY or 0) -- 84
				sp:addTo(self.container) -- 85
				entry.sprite = sp -- 86
			else -- 86
				entry.exists = false -- 88
			end -- 88
		end -- 88
		self.cache[instanceKey] = entry -- 91
	end -- 91
	if not entry.exists or entry.sprite == nil then -- 91
		return false -- 94
	end -- 94
	local sp = entry.sprite -- 96
	local sw = sp.width > 0 and sp.width or 1 -- 97
	local sh = sp.height > 0 and sp.height or 1 -- 98
	local baseScale = cfg.scale ~= nil and cfg.scale or 1 -- 99
	local sx = targetW / sw * baseScale * (facing < 0 and -1 or 1) -- 100
	local sy = targetH / sh * baseScale -- 101
	sp.position = Vec2(x, y) -- 102
	sp.scaleX = sx -- 103
	sp.scaleY = sy -- 104
	sp.opacity = opacity -- 105
	sp.visible = true -- 106
	self.usedThisFrame[instanceKey] = true -- 107
	return true -- 108
end -- 63
function AssetSlotHost.prototype.endFrame(self) -- 112
	for key in pairs(self.cache) do -- 113
		if not self.usedThisFrame[key] then -- 113
			local sp = self.cache[key].sprite -- 115
			if sp ~= nil then -- 115
				sp.visible = false -- 117
			end -- 117
		end -- 117
	end -- 117
end -- 112
function AssetSlotHost.prototype.hasExternalAsset(self, slotKey) -- 124
	local cfg = ____exports.ASSET_SLOTS[slotKey] -- 125
	return cfg ~= nil and cfg.path ~= nil and cfg.path ~= "" and Content:exist(cfg.path) -- 126
end -- 124
return ____exports -- 124