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
--- 从高清前端镜头采集当前房内可见活体敌兵的舞台坐标候选点（单帧仅算一次，供触屏与手柄复用）。
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
--- 从护送试炼（mode === 2）采集敌兵舞台坐标候选点。
function ____exports.collectTrialAimTargets(p, stageW, stageH) -- 53
	local out = {} -- 58
	local i = 0 -- 59
	do -- 59
		i = 0 -- 60
		while i < #p.enemies do -- 60
			do -- 60
				local e = p.enemies[i + 1] -- 61
				if not e.alive then -- 62
					goto __continue11 -- 62
				end -- 62
				local isShield = e.kind == "shield" and (e.shieldHp or 0) > 0 -- 63
				local aimWorldY = e.y + e.h * (isShield and 0.88 or 0.6) -- 64
				local pt = worldToScreen(e.x, aimWorldY + (e.depth or 0) * DEPTH_Y_SCALE, p.cam, p.view) -- 65
				if pt.x >= -64 and pt.x <= stageW + 64 and pt.y >= -48 and pt.y <= stageH + 48 then -- 66
					out[#out + 1] = {sx = pt.x, sy = pt.y, shield = isShield} -- 67
				end -- 67
			end -- 67
			::__continue11:: -- 67
			i = i + 1 -- 60
		end -- 60
	end -- 60
	return out -- 70
end -- 53
--- 屏幕点选轻度磁吸（用于触屏直点 / 拖滑点射）：仅在指定像素半径内吸附最近目标。
function ____exports.snapPointAim(stageX, stageY, targets, maxSnapPx, enabled) -- 74
	if not enabled or #targets == 0 or maxSnapPx <= 0 then -- 81
		return {x = stageX, y = stageY} -- 82
	end -- 82
	local bestDist = maxSnapPx -- 84
	local bestX = stageX -- 85
	local bestY = stageY -- 86
	local i = 0 -- 87
	do -- 87
		i = 0 -- 88
		while i < #targets do -- 88
			local e = targets[i + 1] -- 89
			local d = hypot(e.sx - stageX, e.sy - stageY) -- 90
			if d < bestDist then -- 91
				bestDist = d -- 92
				bestX = e.sx -- 93
				bestY = e.sy -- 94
			end -- 94
			i = i + 1 -- 88
		end -- 88
	end -- 88
	return {x = bestX, y = bestY} -- 97
end -- 74
--- 方向锥轻度磁吸（用于手柄右摇杆 360° 瞄准与触屏开火摇杆精瞄）。
function ____exports.snapConeAim(originX, originY, dirX, dirY, reachPx, stageW, stageH, targets, enabled, halfAngleRad) -- 101
	if halfAngleRad == nil then -- 111
		halfAngleRad = DEFAULT_CONE_HALF_ANGLE_RAD -- 111
	end -- 111
	local baseX = clamp( -- 113
		originX + dirX * reachPx, -- 113
		12, -- 113
		math.max(24, stageW - 12) -- 113
	) -- 113
	local baseY = clamp( -- 114
		originY + dirY * reachPx, -- 114
		12, -- 114
		math.max(24, stageH - 12) -- 114
	) -- 114
	if not enabled or #targets == 0 then -- 116
		return {x = baseX, y = baseY} -- 117
	end -- 117
	local wantAngle = math.atan(dirY, dirX) -- 120
	local bestScore = 1000000000 -- 121
	local bestTarget -- 122
	local i = 0 -- 123
	do -- 123
		i = 0 -- 124
		while i < #targets do -- 124
			do -- 124
				local e = targets[i + 1] -- 125
				if e.sx < -24 or e.sx > stageW + 24 or e.sy < -24 or e.sy > stageH + 24 then -- 126
					goto __continue22 -- 127
				end -- 127
				local dx = e.sx - originX -- 129
				local dy = e.sy - originY -- 130
				local dist = hypot(dx, dy) -- 131
				if dist < 18 then -- 132
					goto __continue22 -- 132
				end -- 132
				local diff = math.atan(dy, dx) - wantAngle -- 133
				while diff > math.pi do -- 134
					diff = diff - math.pi * 2 -- 134
				end -- 134
				while diff < -math.pi do -- 135
					diff = diff + math.pi * 2 -- 135
				end -- 135
				local absDiff = math.abs(diff) -- 136
				if absDiff <= halfAngleRad then -- 137
					local score = absDiff * 420 + dist * 0.25 -- 138
					if score < bestScore then -- 139
						bestScore = score -- 140
						bestTarget = e -- 141
					end -- 141
				end -- 141
			end -- 141
			::__continue22:: -- 141
			i = i + 1 -- 124
		end -- 124
	end -- 124
	if bestTarget ~= nil then -- 146
		return { -- 147
			x = clamp( -- 148
				bestTarget.sx, -- 148
				12, -- 148
				math.max(24, stageW - 12) -- 148
			), -- 148
			y = clamp( -- 149
				bestTarget.sy, -- 149
				12, -- 149
				math.max(24, stageH - 12) -- 149
			) -- 149
		} -- 149
	end -- 149
	return {x = baseX, y = baseY} -- 152
end -- 101
--- 触屏点按「开火」大钮时的智能锁敌目标（未开启磁吸或无可见敌人时沿朝向平射）。
function ____exports.pickSmartFireTarget(originX, originY, facing, stageW, stageH, uiScale, targets, aimAssist, fallback) -- 156
	if aimAssist and #targets > 0 then -- 167
		local bestDist = 1000000000 -- 168
		local bestX = originX + facing * 220 -- 169
		local bestY = originY -- 170
		local i = 0 -- 171
		do -- 171
			i = 0 -- 172
			while i < #targets do -- 172
				do -- 172
					local e = targets[i + 1] -- 173
					if e.sx < -32 or e.sx > stageW + 32 or e.sy < -32 or e.sy > stageH + 32 then -- 174
						goto __continue33 -- 175
					end -- 175
					local d = hypot(e.sx - originX, e.sy - originY) -- 177
					if d < bestDist then -- 178
						bestDist = d -- 179
						bestX = e.sx -- 180
						bestY = e.sy -- 181
					end -- 181
				end -- 181
				::__continue33:: -- 181
				i = i + 1 -- 172
			end -- 172
		end -- 172
		if bestDist < 100000000 then -- 184
			return { -- 185
				x = clamp( -- 186
					bestX, -- 186
					12, -- 186
					math.max(24, stageW - 12) -- 186
				), -- 186
				y = clamp( -- 187
					bestY, -- 187
					12, -- 187
					math.max(24, stageH - 12) -- 187
				) -- 187
			} -- 187
		end -- 187
	end -- 187
	if fallback ~= nil then -- 191
		return fallback -- 192
	end -- 192
	local dir = facing < 0 and -1 or 1 -- 194
	local reach = 240 * math.max(0.25, uiScale) -- 195
	return { -- 196
		x = clamp( -- 197
			originX + dir * reach, -- 197
			16, -- 197
			math.max(32, stageW - 16) -- 197
		), -- 197
		y = clamp( -- 198
			originY, -- 198
			16, -- 198
			math.max(32, stageH - 16) -- 198
		) -- 198
	} -- 198
end -- 156
return ____exports -- 156
