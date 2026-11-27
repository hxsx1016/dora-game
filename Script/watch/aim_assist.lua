-- [ts]: aim_assist.ts
local ____exports = {} -- 1
local ____depth = require("Script.watch.depth") -- 8
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 8
local ____play = require("Script.watch.play") -- 9
local worldToScreen = ____play.worldToScreen -- 9
local DEFAULT_CONE_HALF_ANGLE_RAD = 26 * math.pi / 180 -- 20
local function clamp(v, lo, hi) -- 22
	return v < lo and lo or (v > hi and hi or v) -- 23
end -- 22
local function hypot(dx, dy) -- 26
	return math.sqrt(dx * dx + dy * dy) -- 27
end -- 26
--- 从高清前端镜头采集当前房内可见活体敌兵的舞台坐标候选点。
function ____exports.collectPlayAimTargets(p, cam, stageW, stageH) -- 31
	local out = {} -- 37
	local i = 0 -- 38
	do -- 38
		i = 0 -- 39
		while i < #p.enemies do -- 39
			do -- 39
				local e = p.enemies[i + 1] -- 40
				if not e.alive then -- 40
					goto __continue6 -- 41
				end -- 41
				local isShield = e.kind == "shield" and (e.shieldHp or 0) > 0 -- 42
				local aimWorldY = e.y + e.h * (isShield and 0.88 or 0.6) -- 43
				local sx = cam:sx(e.x) -- 44
				local sy = cam:sy(aimWorldY, e.depth or 0) -- 45
				if sx >= -64 and sx <= stageW + 64 and sy >= -48 and sy <= stageH + 48 then -- 45
					out[#out + 1] = {sx = sx, sy = sy, shield = isShield} -- 47
				end -- 47
			end -- 47
			::__continue6:: -- 47
			i = i + 1 -- 39
		end -- 39
	end -- 39
	return out -- 50
end -- 31
--- 从护送试炼（mode === 2）采集敌兵舞台坐标候选点。
function ____exports.collectTrialAimTargets(p, stageW, stageH) -- 54
	local out = {} -- 59
	local i = 0 -- 60
	do -- 60
		i = 0 -- 61
		while i < #p.enemies do -- 61
			do -- 61
				local e = p.enemies[i + 1] -- 62
				if not e.alive then -- 62
					goto __continue11 -- 63
				end -- 63
				local isShield = e.kind == "shield" and (e.shieldHp or 0) > 0 -- 64
				local aimWorldY = e.y + e.h * (isShield and 0.88 or 0.6) -- 65
				local pt = worldToScreen(e.x, aimWorldY + (e.depth or 0) * DEPTH_Y_SCALE, p.cam, p.view) -- 66
				if pt.x >= -64 and pt.x <= stageW + 64 and pt.y >= -48 and pt.y <= stageH + 48 then -- 66
					out[#out + 1] = {sx = pt.x, sy = pt.y, shield = isShield} -- 68
				end -- 68
			end -- 68
			::__continue11:: -- 68
			i = i + 1 -- 61
		end -- 61
	end -- 61
	return out -- 71
end -- 54
--- 屏幕点选轻度磁吸（用于触屏直点 / 拖滑点射）：仅在指定像素半径内吸附最近目标。
function ____exports.snapPointAim(stageX, stageY, targets, maxSnapPx, enabled) -- 75
	if not enabled or #targets == 0 or maxSnapPx <= 0 then -- 75
		return {x = stageX, y = stageY} -- 83
	end -- 83
	local bestDist = maxSnapPx -- 85
	local bestX = stageX -- 86
	local bestY = stageY -- 87
	local i = 0 -- 88
	do -- 88
		i = 0 -- 89
		while i < #targets do -- 89
			local e = targets[i + 1] -- 90
			local d = hypot(e.sx - stageX, e.sy - stageY) -- 91
			if d < bestDist then -- 91
				bestDist = d -- 93
				bestX = e.sx -- 94
				bestY = e.sy -- 95
			end -- 95
			i = i + 1 -- 89
		end -- 89
	end -- 89
	return {x = bestX, y = bestY} -- 98
end -- 75
--- 方向锥轻度磁吸（用于手柄右摇杆 360° 瞄准与触屏开火摇杆精瞄）。
function ____exports.snapConeAim(originX, originY, dirX, dirY, reachPx, stageW, stageH, targets, enabled, halfAngleRad) -- 102
	if halfAngleRad == nil then -- 102
		halfAngleRad = DEFAULT_CONE_HALF_ANGLE_RAD -- 112
	end -- 112
	local baseX = clamp( -- 114
		originX + dirX * reachPx, -- 114
		12, -- 114
		math.max(24, stageW - 12) -- 114
	) -- 114
	local baseY = clamp( -- 115
		originY + dirY * reachPx, -- 115
		12, -- 115
		math.max(24, stageH - 12) -- 115
	) -- 115
	if not enabled or #targets == 0 then -- 115
		return {x = baseX, y = baseY} -- 118
	end -- 118
	local wantAngle = math.atan(dirY, dirX) -- 121
	local bestScore = 1000000000 -- 122
	local bestTarget -- 123
	local i = 0 -- 124
	do -- 124
		i = 0 -- 125
		while i < #targets do -- 125
			do -- 125
				local e = targets[i + 1] -- 126
				if e.sx < -24 or e.sx > stageW + 24 or e.sy < -24 or e.sy > stageH + 24 then -- 126
					goto __continue22 -- 128
				end -- 128
				local dx = e.sx - originX -- 130
				local dy = e.sy - originY -- 131
				local dist = hypot(dx, dy) -- 132
				if dist < 18 then -- 132
					goto __continue22 -- 133
				end -- 133
				local diff = math.atan(dy, dx) - wantAngle -- 134
				while diff > math.pi do -- 134
					diff = diff - math.pi * 2 -- 135
				end -- 135
				while diff < -math.pi do -- 135
					diff = diff + math.pi * 2 -- 136
				end -- 136
				local absDiff = math.abs(diff) -- 137
				if absDiff <= halfAngleRad then -- 137
					local score = absDiff * 420 + dist * 0.25 -- 139
					if score < bestScore then -- 139
						bestScore = score -- 141
						bestTarget = e -- 142
					end -- 142
				end -- 142
			end -- 142
			::__continue22:: -- 142
			i = i + 1 -- 125
		end -- 125
	end -- 125
	if bestTarget ~= nil then -- 125
		return { -- 148
			x = clamp( -- 149
				bestTarget.sx, -- 149
				12, -- 149
				math.max(24, stageW - 12) -- 149
			), -- 149
			y = clamp( -- 150
				bestTarget.sy, -- 150
				12, -- 150
				math.max(24, stageH - 12) -- 150
			) -- 150
		} -- 150
	end -- 150
	return {x = baseX, y = baseY} -- 153
end -- 102
--- 触屏点按「开火」大钮时的智能锁敌目标（未开启磁吸或无可见敌人时沿朝向平射）。
function ____exports.pickSmartFireTarget(originX, originY, facing, stageW, stageH, uiScale, targets, aimAssist, fallback) -- 157
	if aimAssist and #targets > 0 then -- 157
		local bestDist = 1000000000 -- 169
		local bestX = originX + facing * 220 -- 170
		local bestY = originY -- 171
		local i = 0 -- 172
		do -- 172
			i = 0 -- 173
			while i < #targets do -- 173
				do -- 173
					local e = targets[i + 1] -- 174
					if e.sx < -32 or e.sx > stageW + 32 or e.sy < -32 or e.sy > stageH + 32 then -- 174
						goto __continue33 -- 176
					end -- 176
					local d = hypot(e.sx - originX, e.sy - originY) -- 178
					if d < bestDist then -- 178
						bestDist = d -- 180
						bestX = e.sx -- 181
						bestY = e.sy -- 182
					end -- 182
				end -- 182
				::__continue33:: -- 182
				i = i + 1 -- 173
			end -- 173
		end -- 173
		if bestDist < 100000000 then -- 173
			return { -- 186
				x = clamp( -- 187
					bestX, -- 187
					12, -- 187
					math.max(24, stageW - 12) -- 187
				), -- 187
				y = clamp( -- 188
					bestY, -- 188
					12, -- 188
					math.max(24, stageH - 12) -- 188
				) -- 188
			} -- 188
		end -- 188
	end -- 188
	if fallback ~= nil then -- 188
		return fallback -- 193
	end -- 193
	local dir = facing < 0 and -1 or 1 -- 195
	local reach = 240 * math.max(0.25, uiScale) -- 196
	return { -- 197
		x = clamp( -- 198
			originX + dir * reach, -- 198
			16, -- 198
			math.max(32, stageW - 16) -- 198
		), -- 198
		y = clamp( -- 199
			originY, -- 199
			16, -- 199
			math.max(32, stageH - 16) -- 199
		) -- 199
	} -- 199
end -- 157
return ____exports -- 157