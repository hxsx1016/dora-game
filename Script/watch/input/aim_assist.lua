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
	if cam ~= nil then -- 30
		return cam:worldToScreen(x, y, depth) -- 31
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
				if not e.alive then -- 49
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
				if pt.x >= -64 and pt.x <= stageW + 64 and pt.y >= -48 and pt.y <= stageH + 48 then -- 53
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
function ____exports.snapPointAim(stageX, stageY, targets, maxSnapPx, enabled) -- 62
	if not enabled or #targets == 0 or maxSnapPx <= 0 then -- 62
		return {x = stageX, y = stageY} -- 70
	end -- 70
	local bestDist = maxSnapPx -- 72
	local bestX = stageX -- 73
	local bestY = stageY -- 74
	local i = 0 -- 75
	do -- 75
		i = 0 -- 76
		while i < #targets do -- 76
			local e = targets[i + 1] -- 77
			local d = hypot(e.sx - stageX, e.sy - stageY) -- 78
			if d < bestDist then -- 78
				bestDist = d -- 80
				bestX = e.sx -- 81
				bestY = e.sy -- 82
			end -- 82
			i = i + 1 -- 76
		end -- 76
	end -- 76
	return {x = bestX, y = bestY} -- 85
end -- 62
--- 方向锥轻度磁吸（用于手柄右摇杆 360° 瞄准与触屏开火摇杆精瞄）。
function ____exports.snapConeAim(originX, originY, dirX, dirY, reachPx, stageW, stageH, targets, enabled, halfAngleRad) -- 89
	if halfAngleRad == nil then -- 89
		halfAngleRad = DEFAULT_CONE_HALF_ANGLE_RAD -- 99
	end -- 99
	local baseX = clamp( -- 101
		originX + dirX * reachPx, -- 101
		12, -- 101
		math.max(24, stageW - 12) -- 101
	) -- 101
	local baseY = clamp( -- 102
		originY + dirY * reachPx, -- 102
		12, -- 102
		math.max(24, stageH - 12) -- 102
	) -- 102
	if not enabled or #targets == 0 then -- 102
		return {x = baseX, y = baseY} -- 105
	end -- 105
	local wantAngle = math.atan(dirY, dirX) -- 108
	local bestScore = 1000000000 -- 109
	local bestTarget -- 110
	local i = 0 -- 111
	do -- 111
		i = 0 -- 112
		while i < #targets do -- 112
			do -- 112
				local e = targets[i + 1] -- 113
				if e.sx < -24 or e.sx > stageW + 24 or e.sy < -24 or e.sy > stageH + 24 then -- 113
					goto __continue20 -- 115
				end -- 115
				local dx = e.sx - originX -- 117
				local dy = e.sy - originY -- 118
				local dist = hypot(dx, dy) -- 119
				if dist < 18 then -- 119
					goto __continue20 -- 120
				end -- 120
				local diff = math.atan(dy, dx) - wantAngle -- 121
				while diff > math.pi do -- 121
					diff = diff - math.pi * 2 -- 122
				end -- 122
				while diff < -math.pi do -- 122
					diff = diff + math.pi * 2 -- 123
				end -- 123
				local absDiff = math.abs(diff) -- 124
				if absDiff <= halfAngleRad then -- 124
					local score = absDiff * 420 + dist * 0.25 -- 126
					if score < bestScore then -- 126
						bestScore = score -- 128
						bestTarget = e -- 129
					end -- 129
				end -- 129
			end -- 129
			::__continue20:: -- 129
			i = i + 1 -- 112
		end -- 112
	end -- 112
	if bestTarget ~= nil then -- 112
		return { -- 135
			x = clamp( -- 136
				bestTarget.sx, -- 136
				12, -- 136
				math.max(24, stageW - 12) -- 136
			), -- 136
			y = clamp( -- 137
				bestTarget.sy, -- 137
				12, -- 137
				math.max(24, stageH - 12) -- 137
			) -- 137
		} -- 137
	end -- 137
	return {x = baseX, y = baseY} -- 140
end -- 89
--- 触屏点按「开火」大钮时的智能锁敌目标（未开启磁吸或无可见敌人时沿朝向平射）。
function ____exports.pickSmartFireTarget(originX, originY, facing, stageW, stageH, uiScale, targets, aimAssist, fallback) -- 144
	if aimAssist and #targets > 0 then -- 144
		local bestDist = 1000000000 -- 156
		local bestX = originX + facing * 220 -- 157
		local bestY = originY -- 158
		local i = 0 -- 159
		do -- 159
			i = 0 -- 160
			while i < #targets do -- 160
				do -- 160
					local e = targets[i + 1] -- 161
					if e.sx < -32 or e.sx > stageW + 32 or e.sy < -32 or e.sy > stageH + 32 then -- 161
						goto __continue31 -- 163
					end -- 163
					local d = hypot(e.sx - originX, e.sy - originY) -- 165
					if d < bestDist then -- 165
						bestDist = d -- 167
						bestX = e.sx -- 168
						bestY = e.sy -- 169
					end -- 169
				end -- 169
				::__continue31:: -- 169
				i = i + 1 -- 160
			end -- 160
		end -- 160
		if bestDist < 100000000 then -- 160
			return { -- 173
				x = clamp( -- 174
					bestX, -- 174
					12, -- 174
					math.max(24, stageW - 12) -- 174
				), -- 174
				y = clamp( -- 175
					bestY, -- 175
					12, -- 175
					math.max(24, stageH - 12) -- 175
				) -- 175
			} -- 175
		end -- 175
	end -- 175
	if fallback ~= nil then -- 175
		return fallback -- 180
	end -- 180
	local dir = facing < 0 and -1 or 1 -- 182
	local reach = 240 * math.max(0.25, uiScale) -- 183
	return { -- 184
		x = clamp( -- 185
			originX + dir * reach, -- 185
			16, -- 185
			math.max(32, stageW - 16) -- 185
		), -- 185
		y = clamp( -- 186
			originY, -- 186
			16, -- 186
			math.max(32, stageH - 16) -- 186
		) -- 186
	} -- 186
end -- 144
return ____exports -- 144