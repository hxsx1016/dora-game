-- [ts]: aim_assist.ts
local ____exports = {} -- 1
local ____depth = require("Script.watch.depth") -- 7
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 7
local ____play = require("Script.watch.play") -- 8
local worldToScreen = ____play.worldToScreen -- 8
local DEFAULT_CONE_HALF_ANGLE_RAD = 26 * math.pi / 180 -- 19
local function clamp(v, lo, hi) -- 21
	return v < lo and lo or (v > hi and hi or v) -- 22
end -- 21
local function hypot(dx, dy) -- 25
	return math.sqrt(dx * dx + dy * dy) -- 26
end -- 25
--- Use the sprite camera when supplied by the renderer, otherwise project through Play.draw's viewport.
local function projectAimPoint(p, cam, x, y, depth) -- 30
	if cam ~= nil then -- 31
		return { -- 31
			x = cam:sx(x), -- 31
			y = cam:sy(y, depth) -- 31
		} -- 31
	end -- 31
	return worldToScreen(x, y + depth * DEPTH_Y_SCALE, p.cam, p.view) -- 32
end -- 30
function ____exports.projectMuzzle(p, cam) -- 35
	local a = p.player -- 36
	return projectAimPoint( -- 37
		p, -- 37
		cam, -- 37
		a.x + a.facing * 8, -- 37
		a.y + a.h * 0.72, -- 37
		a.depth -- 37
	) -- 37
end -- 35
function ____exports.collectAimTargets(p, cam, stageW, stageH) -- 40
	local out = {} -- 46
	local i = 0 -- 47
	do -- 47
		i = 0 -- 48
		while i < #p.enemies do -- 48
			do -- 48
				local e = p.enemies[i + 1] -- 49
				if not e.alive then -- 50
					goto __continue9 -- 50
				end -- 50
				local isShield = e.kind == "shield" and (e.shieldHp or 0) > 0 -- 51
				local aimWorldY = e.y + e.h * (isShield and 0.88 or 0.6) -- 52
				local pt = projectAimPoint( -- 53
					p, -- 53
					cam, -- 53
					e.x, -- 53
					aimWorldY, -- 53
					e.depth or 0 -- 53
				) -- 53
				if pt.x >= -64 and pt.x <= stageW + 64 and pt.y >= -48 and pt.y <= stageH + 48 then -- 54
					out[#out + 1] = {sx = pt.x, sy = pt.y, shield = isShield} -- 55
				end -- 55
			end -- 55
			::__continue9:: -- 55
			i = i + 1 -- 48
		end -- 48
	end -- 48
	return out -- 58
end -- 40
--- 屏幕点选轻度磁吸（用于触屏直点 / 拖滑点射）：仅在指定像素半径内吸附最近目标。
function ____exports.snapPointAim(stageX, stageY, targets, maxSnapPx, enabled) -- 61
	if not enabled or #targets == 0 or maxSnapPx <= 0 then -- 68
		return {x = stageX, y = stageY} -- 69
	end -- 69
	local bestDist = maxSnapPx -- 71
	local bestX = stageX -- 72
	local bestY = stageY -- 73
	local i = 0 -- 74
	do -- 74
		i = 0 -- 75
		while i < #targets do -- 75
			local e = targets[i + 1] -- 76
			local d = hypot(e.sx - stageX, e.sy - stageY) -- 77
			if d < bestDist then -- 78
				bestDist = d -- 79
				bestX = e.sx -- 80
				bestY = e.sy -- 81
			end -- 81
			i = i + 1 -- 75
		end -- 75
	end -- 75
	return {x = bestX, y = bestY} -- 84
end -- 61
--- 方向锥轻度磁吸（用于手柄右摇杆 360° 瞄准与触屏开火摇杆精瞄）。
function ____exports.snapConeAim(originX, originY, dirX, dirY, reachPx, stageW, stageH, targets, enabled, halfAngleRad) -- 88
	if halfAngleRad == nil then -- 98
		halfAngleRad = DEFAULT_CONE_HALF_ANGLE_RAD -- 98
	end -- 98
	local baseX = clamp( -- 100
		originX + dirX * reachPx, -- 100
		12, -- 100
		math.max(24, stageW - 12) -- 100
	) -- 100
	local baseY = clamp( -- 101
		originY + dirY * reachPx, -- 101
		12, -- 101
		math.max(24, stageH - 12) -- 101
	) -- 101
	if not enabled or #targets == 0 then -- 103
		return {x = baseX, y = baseY} -- 104
	end -- 104
	local wantAngle = math.atan(dirY, dirX) -- 107
	local bestScore = 1000000000 -- 108
	local bestTarget -- 109
	local i = 0 -- 110
	do -- 110
		i = 0 -- 111
		while i < #targets do -- 111
			do -- 111
				local e = targets[i + 1] -- 112
				if e.sx < -24 or e.sx > stageW + 24 or e.sy < -24 or e.sy > stageH + 24 then -- 113
					goto __continue20 -- 114
				end -- 114
				local dx = e.sx - originX -- 116
				local dy = e.sy - originY -- 117
				local dist = hypot(dx, dy) -- 118
				if dist < 18 then -- 119
					goto __continue20 -- 119
				end -- 119
				local diff = math.atan(dy, dx) - wantAngle -- 120
				while diff > math.pi do -- 121
					diff = diff - math.pi * 2 -- 121
				end -- 121
				while diff < -math.pi do -- 122
					diff = diff + math.pi * 2 -- 122
				end -- 122
				local absDiff = math.abs(diff) -- 123
				if absDiff <= halfAngleRad then -- 124
					local score = absDiff * 420 + dist * 0.25 -- 125
					if score < bestScore then -- 126
						bestScore = score -- 127
						bestTarget = e -- 128
					end -- 128
				end -- 128
			end -- 128
			::__continue20:: -- 128
			i = i + 1 -- 111
		end -- 111
	end -- 111
	if bestTarget ~= nil then -- 133
		return { -- 134
			x = clamp( -- 135
				bestTarget.sx, -- 135
				12, -- 135
				math.max(24, stageW - 12) -- 135
			), -- 135
			y = clamp( -- 136
				bestTarget.sy, -- 136
				12, -- 136
				math.max(24, stageH - 12) -- 136
			) -- 136
		} -- 136
	end -- 136
	return {x = baseX, y = baseY} -- 139
end -- 88
--- 触屏点按「开火」大钮时的智能锁敌目标（未开启磁吸或无可见敌人时沿朝向平射）。
function ____exports.pickSmartFireTarget(originX, originY, facing, stageW, stageH, uiScale, targets, aimAssist, fallback) -- 143
	if aimAssist and #targets > 0 then -- 154
		local bestDist = 1000000000 -- 155
		local bestX = originX + facing * 220 -- 156
		local bestY = originY -- 157
		local i = 0 -- 158
		do -- 158
			i = 0 -- 159
			while i < #targets do -- 159
				do -- 159
					local e = targets[i + 1] -- 160
					if e.sx < -32 or e.sx > stageW + 32 or e.sy < -32 or e.sy > stageH + 32 then -- 161
						goto __continue31 -- 162
					end -- 162
					local d = hypot(e.sx - originX, e.sy - originY) -- 164
					if d < bestDist then -- 165
						bestDist = d -- 166
						bestX = e.sx -- 167
						bestY = e.sy -- 168
					end -- 168
				end -- 168
				::__continue31:: -- 168
				i = i + 1 -- 159
			end -- 159
		end -- 159
		if bestDist < 100000000 then -- 171
			return { -- 172
				x = clamp( -- 173
					bestX, -- 173
					12, -- 173
					math.max(24, stageW - 12) -- 173
				), -- 173
				y = clamp( -- 174
					bestY, -- 174
					12, -- 174
					math.max(24, stageH - 12) -- 174
				) -- 174
			} -- 174
		end -- 174
	end -- 174
	if fallback ~= nil then -- 178
		return fallback -- 179
	end -- 179
	local dir = facing < 0 and -1 or 1 -- 181
	local reach = 240 * math.max(0.25, uiScale) -- 182
	return { -- 183
		x = clamp( -- 184
			originX + dir * reach, -- 184
			16, -- 184
			math.max(32, stageW - 16) -- 184
		), -- 184
		y = clamp( -- 185
			originY, -- 185
			16, -- 185
			math.max(32, stageH - 16) -- 185
		) -- 185
	} -- 185
end -- 143
return ____exports -- 143
