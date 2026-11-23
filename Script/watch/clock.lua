-- [ts]: clock.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local ____exports = {} -- 1
--- 模拟步长（秒）。说明文档里的「拍」等于这个步，60 拍 = 1 秒。
____exports.STEP = 1 / 60 -- 15
--- 单帧最多跑的模拟步数。
____exports.MAX_STEPS = 5 -- 18
--- 单帧时长上限（秒）。首帧或窗口拖动后可能给出很大的 dt，先截断。
local MAX_FRAME_DT = 0.25 -- 21
--- 浮点容差：1/120 + 1/120 与 1/60 只差 1e-18，不能让边界卡住。
local EPS = 1e-9 -- 24
____exports.StepClock = __TS__Class() -- 26
local StepClock = ____exports.StepClock -- 26
StepClock.name = "StepClock" -- 26
function StepClock.prototype.____constructor(self) -- 26
	self.acc = 0 -- 27
	self.dropped = 0 -- 28
end -- 26
function StepClock.prototype.advance(self, frameDt, maxSteps) -- 34
	if maxSteps == nil then -- 34
		maxSteps = ____exports.MAX_STEPS -- 34
	end -- 34
	if not (frameDt > 0) then -- 34
		return 0 -- 36
	end -- 36
	local dt = frameDt -- 38
	if dt > MAX_FRAME_DT then -- 38
		dt = MAX_FRAME_DT -- 40
	end -- 40
	self.acc = self.acc + dt -- 42
	local steps = 0 -- 43
	while self.acc + EPS >= ____exports.STEP and steps < maxSteps do -- 43
		self.acc = self.acc - ____exports.STEP -- 45
		steps = steps + 1 -- 46
	end -- 46
	if self.acc + EPS >= ____exports.STEP then -- 46
		self.acc = 0 -- 50
		self.dropped = self.dropped + 1 -- 51
	end -- 51
	return steps -- 53
end -- 34
function StepClock.prototype.reset(self) -- 57
	self.acc = 0 -- 58
end -- 57
__TS__SetDescriptor( -- 57
	StepClock.prototype, -- 57
	"pending", -- 57
	{get = function(self) -- 57
		return self.acc -- 63
	end}, -- 63
	true -- 63
) -- 63
__TS__SetDescriptor( -- 63
	StepClock.prototype, -- 63
	"dropCount", -- 63
	{get = function(self) -- 63
		return self.dropped -- 68
	end}, -- 68
	true -- 68
) -- 68
return ____exports -- 68