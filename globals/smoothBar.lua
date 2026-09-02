-- FosterFrames - SmoothBar Engine
-- Enhanced 1.12.1 Engine Stack (High-Refresh Rate & DXVK 144Hz+ Smoothing)

local smoothing = {}
local min, max, abs = math.min, math.max, math.abs

local function Smooth(self, value)
    local _, maxVal = self:GetMinMaxValues()
    if value == self:GetValue() or (self._max and self._max ~= maxVal) then
        smoothing[self] = nil
        self:SetValue_(value)
    else
        smoothing[self] = value
    end
    self._max = maxVal
end

function SmoothBar(bar)
    if not bar or bar.SetValue_ then return end
    bar.SetValue_ = bar.SetValue
    bar.SetValue = Smooth
end

local f = CreateFrame('Frame')
f:SetScript('OnUpdate', function()
    local dt = arg1 or 0.016
    for bar, target in pairs(smoothing) do
        local cur = bar:GetValue()
        local diff = target - cur
        if abs(diff) < 0.5 then
            bar:SetValue_(target)
            smoothing[bar] = nil
        else
            -- Delta-time exponential smoothing (144Hz/240Hz+ smooth)
            local rate = min(1.0, dt * 15.0)
            local new = cur + (diff * rate)
            bar:SetValue_(new)
        end
    end
end)