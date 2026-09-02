-- FosterFrames - Custom Cooldown Model Animation
-- Enhanced 1.12.1 Engine Stack

local function OnUpdateAnimation()
    if not this.timeEnd or this.timeEnd == 0 then return end
    local now = GetTime()
    if now < this.timeEnd then
        local total = this.timeEnd - this.timeStart
        if total > 0 then
            local finished = (now - this.timeStart) / total
            if finished < 1.0 then
                this:SetSequenceTime(0, finished * 1000)
                return
            end
        end
    end
    this:Hide()
end

local function OnUpdateAnimationReverse()
    if not this.timeEnd or this.timeEnd == 0 then return end
    local now = GetTime()
    if now < this.timeEnd then
        local total = this.timeEnd - this.timeStart
        if total > 0 then
            local finished = 1.0 - ((now - this.timeStart) / total)
            if finished > 0 then
                this:SetSequenceTime(0, finished * 1000)
                return
            end
        end
    end
    this:Hide()
end

function CreateCooldown(parentFrame, scale, rev)
    if not parentFrame then return nil end

    local name = parentFrame.GetName and parentFrame:GetName() or "FosterFramesCD"
    local cd = CreateFrame('Model', name .. 'Cooldown', parentFrame)
    cd:SetModel([[Interface\Cooldown\UI-Cooldown-Indicator.mdx]])
    cd:SetAllPoints()
    if scale then cd:SetScale(scale) end

    cd.timeStart = 0
    cd.timeEnd = 0

    function cd:SetTimers(s, e)
        self.timeStart = s or 0
        self.timeEnd = e or 0
    end

    cd.reverse = rev
    cd:SetScript('OnUpdateModel', function()
        if this.reverse then
            OnUpdateAnimationReverse()
        else
            OnUpdateAnimation()
        end
    end)
    return cd
end