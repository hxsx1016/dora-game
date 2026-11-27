-- [ts]: aim_assist.ts
local ____exports = {} -- 1
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
function ____exports.collectTrialAimTargets(p, cam, stageW, stageH) -- 54
	local out = {} -- 60
	local i = 0 -- 61
	do -- 61
		i = 0 -- 62
		while i < #p.enemies do -- 62
			do -- 62
				local e = p.enemies[i + 1] -- 63
				if not e.alive then -- 63
					goto __continue11 -- 64
				end -- 64
				local isShield = e.kind == "shield" and (e.shieldHp or 0) > 0 -- 65
				local aimWorldY = e.y + e.h * (isShield and 0.88 or 0.6) -- 66
				local sx = cam:sx(e.x) -- 67
				local sy = cam:sy(aimWorldY, e.depth or 0) -- 68
				if sx >= -64 and sx <= stageW + 64 and sy >= -48 and sy <= stageH + 48 then -- 68
					out[#out + 1] = {sx = sx, sy = sy, shield = isShield} -- 70
				end -- 70
			end -- 70
			::__continue11:: -- 70
			i = i + 1 -- 62
		end -- 62
	end -- 62
	return out -- 73
end -- 54
--- 屏幕点选轻度磁吸（用于触屏直点 / 拖滑点射）：仅在指定像素半径内吸附最近目标。
function ____exports.snapPointAim(stageX, stageY, targets, maxSnapPx, enabled) -- 77
	if not enabled or #targets == 0 or maxSnapPx <= 0 then -- 77
		return {x = stageX, y = stageY} -- 85
	end -- 85
	local bestDist = maxSnapPx -- 87
	local bestX = stageX -- 88
	local bestY = stageY -- 89
	local i = 0 -- 90
	do -- 90
		i = 0 -- 91
		while i < #targets do -- 91
			local e = targets[i + 1] -- 92
			local d = hypot(e.sx - stageX, e.sy - stageY) -- 93
			if d < bestDist then -- 93
				bestDist = d -- 95
				bestX = e.sx -- 96
				bestY = e.sy -- 97
			end -- 97
			i = i + 1 -- 91
		end -- 91
	end -- 91
	return {x = bestX, y = bestY} -- 100
end -- 77
--- 方向锥轻度磁吸（用于手柄右摇杆 360° 瞄准与触屏开火摇杆精瞄）。
function ____exports.snapConeAim(originX, originY, dirX, dirY, reachPx, stageW, stageH, targets, enabled, halfAngleRad) -- 104
	if halfAngleRad == nil then -- 104
		halfAngleRad = DEFAULT_CONE_HALF_ANGLE_RAD -- 114
	end -- 114
	local baseX = clamp( -- 116
		originX + dirX * reachPx, -- 116
		12, -- 116
		math.max(24, stageW - 12) -- 116
	) -- 116
	local baseY = clamp( -- 117
		originY + dirY * reachPx, -- 117
		12, -- 117
		math.max(24, stageH - 12) -- 117
	) -- 117
	if not enabled or #targets == 0 then -- 117
		return {x = baseX, y = baseY} -- 120
	end -- 120
	local wantAngle = math.atan(dirY, dirX) -- 123
	local bestScore = 1000000000 -- 124
	local bestTarget -- 125
	local i = 0 -- 126
	do -- 126
		i = 0 -- 127
		while i < #targets do -- 127
			do -- 127
				local e = targets[i + 1] -- 128
				if e.sx < -24 or e.sx > stageW + 24 or e.sy < -24 or e.sy > stageH + 24 then -- 128
					goto __continue22 -- 130
				end -- 130
				local dx = e.sx - originX -- 132
				local dy = e.sy - originY -- 133
				local dist = hypot(dx, dy) -- 134
				if dist < 18 then -- 134
					goto __continue22 -- 135
				end -- 135
				local diff = math.atan(dy, dx) - wantAngle -- 136
				while diff > math.pi do -- 136
					diff = diff - math.pi * 2 -- 137
				end -- 137
				while diff < -math.pi do -- 137
					diff = diff + math.pi * 2 -- 138
				end -- 138
				local absDiff = math.abs(diff) -- 139
				if absDiff <= halfAngleRad then -- 139
					local score = absDiff * 420 + dist * 0.25 -- 141
					if score < bestScore then -- 141
						bestScore = score -- 143
						bestTarget = e -- 144
					end -- 144
				end -- 144
			end -- 144
			::__continue22:: -- 144
			i = i + 1 -- 127
		end -- 127
	end -- 127
	if bestTarget ~= nil then -- 127
		return { -- 150
			x = clamp( -- 151
				bestTarget.sx, -- 151
				12, -- 151
				math.max(24, stageW - 12) -- 151
			), -- 151
			y = clamp( -- 152
				bestTarget.sy, -- 152
				12, -- 152
				math.max(24, stageH - 12) -- 152
			) -- 152
		} -- 152
	end -- 152
	return {x = baseX, y = baseY} -- 155
end -- 104
--- 触屏点按「开火」大钮时的智能锁敌目标（未开启磁吸或无可见敌人时沿朝向平射）。
function ____exports.pickSmartFireTarget(originX, originY, facing, stageW, stageH, uiScale, targets, aimAssist, fallback) -- 159
	if aimAssist and #targets > 0 then -- 159
		local bestDist = 1000000000 -- 171
		local bestX = originX + facing * 220 -- 172
		local bestY = originY -- 173
		local i = 0 -- 174
		do -- 174
			i = 0 -- 175
			while i < #targets do -- 175
				do -- 175
					local e = targets[i + 1] -- 176
					if e.sx < -32 or e.sx > stageW + 32 or e.sy < -32 or e.sy > stageH + 32 then -- 176
						goto __continue33 -- 178
					end -- 178
					local d = hypot(e.sx - originX, e.sy - originY) -- 180
					if d < bestDist then -- 180
						bestDist = d -- 182
						bestX = e.sx -- 183
						bestY = e.sy -- 184
					end -- 184
				end -- 184
				::__continue33:: -- 184
				i = i + 1 -- 175
			end -- 175
		end -- 175
		if bestDist < 100000000 then -- 175
			return { -- 188
				x = clamp( -- 189
					bestX, -- 189
					12, -- 189
					math.max(24, stageW - 12) -- 189
				), -- 189
				y = clamp( -- 190
					bestY, -- 190
					12, -- 190
					math.max(24, stageH - 12) -- 190
				) -- 190
			} -- 190
		end -- 190
	end -- 190
	if fallback ~= nil then -- 190
		return fallback -- 195
	end -- 195
	local dir = facing < 0 and -1 or 1 -- 197
	local reach = 240 * math.max(0.25, uiScale) -- 198
	return { -- 199
		x = clamp( -- 200
			originX + dir * reach, -- 200
			16, -- 200
			math.max(32, stageW - 16) -- 200
		), -- 200
		y = clamp( -- 201
			originY, -- 201
			16, -- 201
			math.max(32, stageH - 16) -- 201
		) -- 201
	} -- 201
end -- 159
return ____exports -- 159