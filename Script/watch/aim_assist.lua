-- [ts]: aim_assist.ts
local ____exports = {} -- 1
local DEFAULT_CONE_HALF_ANGLE_RAD = 26 * math.pi / 180 -- 19
local function clamp(v, lo, hi) -- 21
	return v < lo and lo or (v > hi and hi or v) -- 22
end -- 21
local function hypot(dx, dy) -- 25
	return math.sqrt(dx * dx + dy * dy) -- 26
end -- 25
--- 从高清前端镜头采集当前房内可见活体敌兵的舞台坐标候选点。
function ____exports.collectPlayAimTargets(p, cam, stageW, stageH) -- 30
	local out = {} -- 36
	local i = 0 -- 37
	do -- 37
		i = 0 -- 38
		while i < #p.enemies do -- 38
			do -- 38
				local e = p.enemies[i + 1] -- 39
				if not e.alive then -- 40
					goto __continue6 -- 40
				end -- 40
				local isShield = e.kind == "shield" and (e.shieldHp or 0) > 0 -- 41
				local aimWorldY = e.y + e.h * (isShield and 0.88 or 0.6) -- 42
				local sx = cam:sx(e.x) -- 43
				local sy = cam:sy(aimWorldY, e.depth or 0) -- 44
				if sx >= -64 and sx <= stageW + 64 and sy >= -48 and sy <= stageH + 48 then -- 45
					out[#out + 1] = {sx = sx, sy = sy, shield = isShield} -- 46
				end -- 46
			end -- 46
			::__continue6:: -- 46
			i = i + 1 -- 38
		end -- 38
	end -- 38
	return out -- 49
end -- 30
--- 屏幕点选轻度磁吸（用于触屏直点 / 拖滑点射）：仅在指定像素半径内吸附最近目标。
function ____exports.snapPointAim(stageX, stageY, targets, maxSnapPx, enabled) -- 53
	if not enabled or #targets == 0 or maxSnapPx <= 0 then -- 60
		return {x = stageX, y = stageY} -- 61
	end -- 61
	local bestDist = maxSnapPx -- 63
	local bestX = stageX -- 64
	local bestY = stageY -- 65
	local i = 0 -- 66
	do -- 66
		i = 0 -- 67
		while i < #targets do -- 67
			local e = targets[i + 1] -- 68
			local d = hypot(e.sx - stageX, e.sy - stageY) -- 69
			if d < bestDist then -- 70
				bestDist = d -- 71
				bestX = e.sx -- 72
				bestY = e.sy -- 73
			end -- 73
			i = i + 1 -- 67
		end -- 67
	end -- 67
	return {x = bestX, y = bestY} -- 76
end -- 53
--- 方向锥轻度磁吸（用于手柄右摇杆 360° 瞄准与触屏开火摇杆精瞄）。
function ____exports.snapConeAim(originX, originY, dirX, dirY, reachPx, stageW, stageH, targets, enabled, halfAngleRad) -- 80
	if halfAngleRad == nil then -- 90
		halfAngleRad = DEFAULT_CONE_HALF_ANGLE_RAD -- 90
	end -- 90
	local baseX = clamp( -- 92
		originX + dirX * reachPx, -- 92
		12, -- 92
		math.max(24, stageW - 12) -- 92
	) -- 92
	local baseY = clamp( -- 93
		originY + dirY * reachPx, -- 93
		12, -- 93
		math.max(24, stageH - 12) -- 93
	) -- 93
	if not enabled or #targets == 0 then -- 95
		return {x = baseX, y = baseY} -- 96
	end -- 96
	local wantAngle = math.atan(dirY, dirX) -- 99
	local bestScore = 1000000000 -- 100
	local bestTarget -- 101
	local i = 0 -- 102
	do -- 102
		i = 0 -- 103
		while i < #targets do -- 103
			do -- 103
				local e = targets[i + 1] -- 104
				if e.sx < -24 or e.sx > stageW + 24 or e.sy < -24 or e.sy > stageH + 24 then -- 105
					goto __continue17 -- 106
				end -- 106
				local dx = e.sx - originX -- 108
				local dy = e.sy - originY -- 109
				local dist = hypot(dx, dy) -- 110
				if dist < 18 then -- 111
					goto __continue17 -- 111
				end -- 111
				local diff = math.atan(dy, dx) - wantAngle -- 112
				while diff > math.pi do -- 113
					diff = diff - math.pi * 2 -- 113
				end -- 113
				while diff < -math.pi do -- 114
					diff = diff + math.pi * 2 -- 114
				end -- 114
				local absDiff = math.abs(diff) -- 115
				if absDiff <= halfAngleRad then -- 116
					local score = absDiff * 420 + dist * 0.25 -- 117
					if score < bestScore then -- 118
						bestScore = score -- 119
						bestTarget = e -- 120
					end -- 120
				end -- 120
			end -- 120
			::__continue17:: -- 120
			i = i + 1 -- 103
		end -- 103
	end -- 103
	if bestTarget ~= nil then -- 125
		return { -- 126
			x = clamp( -- 127
				bestTarget.sx, -- 127
				12, -- 127
				math.max(24, stageW - 12) -- 127
			), -- 127
			y = clamp( -- 128
				bestTarget.sy, -- 128
				12, -- 128
				math.max(24, stageH - 12) -- 128
			) -- 128
		} -- 128
	end -- 128
	return {x = baseX, y = baseY} -- 131
end -- 80
--- 触屏点按「开火」大钮时的智能锁敌目标（未开启磁吸或无可见敌人时沿朝向平射）。
function ____exports.pickSmartFireTarget(originX, originY, facing, stageW, stageH, uiScale, targets, aimAssist, fallback) -- 135
	if aimAssist and #targets > 0 then -- 146
		local bestDist = 1000000000 -- 147
		local bestX = originX + facing * 220 -- 148
		local bestY = originY -- 149
		local i = 0 -- 150
		do -- 150
			i = 0 -- 151
			while i < #targets do -- 151
				do -- 151
					local e = targets[i + 1] -- 152
					if e.sx < -32 or e.sx > stageW + 32 or e.sy < -32 or e.sy > stageH + 32 then -- 153
						goto __continue28 -- 154
					end -- 154
					local d = hypot(e.sx - originX, e.sy - originY) -- 156
					if d < bestDist then -- 157
						bestDist = d -- 158
						bestX = e.sx -- 159
						bestY = e.sy -- 160
					end -- 160
				end -- 160
				::__continue28:: -- 160
				i = i + 1 -- 151
			end -- 151
		end -- 151
		if bestDist < 100000000 then -- 163
			return { -- 164
				x = clamp( -- 165
					bestX, -- 165
					12, -- 165
					math.max(24, stageW - 12) -- 165
				), -- 165
				y = clamp( -- 166
					bestY, -- 166
					12, -- 166
					math.max(24, stageH - 12) -- 166
				) -- 166
			} -- 166
		end -- 166
	end -- 166
	if fallback ~= nil then -- 170
		return fallback -- 171
	end -- 171
	local dir = facing < 0 and -1 or 1 -- 173
	local reach = 240 * math.max(0.25, uiScale) -- 174
	return { -- 175
		x = clamp( -- 176
			originX + dir * reach, -- 176
			16, -- 176
			math.max(32, stageW - 16) -- 176
		), -- 176
		y = clamp( -- 177
			originY, -- 177
			16, -- 177
			math.max(32, stageH - 16) -- 177
		) -- 177
	} -- 177
end -- 135
return ____exports -- 135
