-- FosterFrames - TargetFrame Extensions (Castbar, Flag Carrier Indicator, Debuff Timers)
-- Enhanced 1.12.1 Engine Stack (ClassicAPI, SuperWoW, UnitXP SP3)

local refreshInterval = 1 / 60
local nextRefresh = 0
local flagCarriers = {}
local castbarmoveable = false

local TEXTURE = [[Interface\AddOns\FosterFrames\globals\resources\barTexture.tga]]
local BACKDROP = { bgFile = [[Interface\Tooltips\UI-Tooltip-Background]] }

-- Movable Target Castbar
TargetFrame.EFcast = CreateFrame('StatusBar', 'fosterFramesTargetFrameCastbar', TargetFrame)
TargetFrame.EFcast:SetStatusBarTexture(TEXTURE)
TargetFrame.EFcast:SetStatusBarColor(1, 0.4, 0)
TargetFrame.EFcast:SetBackdrop(BACKDROP)
TargetFrame.EFcast:SetBackdropColor(0, 0, 0, 0.8)
TargetFrame.EFcast:SetHeight(10)
TargetFrame.EFcast:SetWidth(160)
TargetFrame.EFcast:SetPoint('LEFT', TargetFrame, 'LEFT', 26, -45)
TargetFrame.EFcast:SetValue(0)
TargetFrame.EFcast:Hide()

TargetFrame.EFcast:SetMovable(true)
TargetFrame.EFcast:SetUserPlaced(true)
TargetFrame.EFcast:SetClampedToScreen(true)
TargetFrame.EFcast:RegisterForDrag('LeftButton')
TargetFrame.EFcast:EnableMouse(true)

TargetFrame.EFcast:SetScript('OnDragStart', function()
    if castbarmoveable then this:StartMoving() end
end)
TargetFrame.EFcast:SetScript('OnDragStop', function()
    if castbarmoveable then this:StopMovingOrSizing() end
end)

TargetFrame.EFcast.border = CreateBorder(nil, TargetFrame.EFcast, 6.5, 1 / 8.5)
TargetFrame.EFcast.border:SetPadding(2.5, 1.7)

TargetFrame.EFcast.spark = TargetFrame.EFcast:CreateTexture(nil, 'OVERLAY')
TargetFrame.EFcast.spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
TargetFrame.EFcast.spark:SetHeight(26)
TargetFrame.EFcast.spark:SetWidth(26)
TargetFrame.EFcast.spark:SetBlendMode('ADD')

TargetFrame.EFcast.text = TargetFrame.EFcast:CreateFontString(nil, 'OVERLAY')
TargetFrame.EFcast.text:SetTextColor(1, 1, 1)
TargetFrame.EFcast.text:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
TargetFrame.EFcast.text:SetShadowColor(0, 0, 0)
TargetFrame.EFcast.text:SetPoint('LEFT', TargetFrame.EFcast, 'LEFT', 2, 0.5)
TargetFrame.EFcast.text:SetText('Castbar')

TargetFrame.EFcast.timer = TargetFrame.EFcast:CreateFontString(nil, 'OVERLAY')
TargetFrame.EFcast.timer:SetTextColor(1, 1, 1)
TargetFrame.EFcast.timer:SetFont(STANDARD_TEXT_FONT, 9, 'OUTLINE')
TargetFrame.EFcast.timer:SetShadowColor(0, 0, 0)
TargetFrame.EFcast.timer:SetPoint('RIGHT', TargetFrame.EFcast, 'RIGHT', -1, 0.5)
TargetFrame.EFcast.timer:SetText('')

TargetFrame.EFcast.icon = TargetFrame.EFcast:CreateTexture(nil, 'OVERLAY', nil, 7)
TargetFrame.EFcast.icon:SetWidth(18)
TargetFrame.EFcast.icon:SetHeight(16)
TargetFrame.EFcast.icon:SetPoint('RIGHT', TargetFrame.EFcast, 'LEFT', -8, 0)
TargetFrame.EFcast.icon:SetTexCoord(0.1, 0.9, 0.15, 0.85)
TargetFrame.EFcast.icon:SetTexture([[Interface\Icons\Inv_misc_gem_sapphire_01]])

local ic = CreateFrame('Frame', nil, TargetFrame.EFcast)
ic:SetAllPoints(TargetFrame.EFcast.icon)
TargetFrame.EFcast.icon.border = CreateBorder(nil, ic, 12.8)
TargetFrame.EFcast.icon.border:SetPadding(1)

-- Integrated Nameplate Target Castbar
TargetFrame.IntegratedCastBar = CreateFrame('StatusBar', 'fosterFramesTargetFrameIntegratedCastbar', TargetFrame)
TargetFrame.IntegratedCastBar:SetStatusBarTexture(TEXTURE)
TargetFrame.IntegratedCastBar:SetStatusBarColor(1, 0.4, 0)
TargetFrame.IntegratedCastBar:SetBackdrop(BACKDROP)
TargetFrame.IntegratedCastBar:SetBackdropColor(0, 0, 0, 0.9)
TargetFrame.IntegratedCastBar:SetPoint('TOPLEFT', TargetFrameNameBackground, 'TOPLEFT', 0, 0)
TargetFrame.IntegratedCastBar:SetPoint('BOTTOMRIGHT', TargetFrameNameBackground, 'BOTTOMRIGHT', 0, 0)
TargetFrame.IntegratedCastBar:SetFrameLevel(1)
TargetFrame.IntegratedCastBar:SetMinMaxValues(0, 10)
TargetFrame.IntegratedCastBar:SetValue(0)
TargetFrame.IntegratedCastBar:Hide()

TargetFrame.IntegratedCastBar.spark = TargetFrame.IntegratedCastBar:CreateTexture(nil, 'OVERLAY')
TargetFrame.IntegratedCastBar.spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
TargetFrame.IntegratedCastBar.spark:SetHeight(34)
TargetFrame.IntegratedCastBar.spark:SetWidth(32)
TargetFrame.IntegratedCastBar.spark:SetBlendMode('ADD')

TargetFrame.IntegratedCastBar.spellText = TargetFrame.IntegratedCastBar:CreateFontString(nil, 'OVERLAY')
TargetFrame.IntegratedCastBar.spellText:SetTextColor(1, 1, 1)
TargetFrame.IntegratedCastBar.spellText:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
TargetFrame.IntegratedCastBar.spellText:SetShadowColor(0, 0, 0)
TargetFrame.IntegratedCastBar.spellText:SetPoint('LEFT', TargetFrame.IntegratedCastBar, 'LEFT', 1, 0.5)
TargetFrame.IntegratedCastBar.spellText:SetText('')

TargetFrame.IntegratedCastBar.timer = TargetFrame.IntegratedCastBar:CreateFontString(nil, 'OVERLAY')
TargetFrame.IntegratedCastBar.timer:SetTextColor(1, 1, 1)
TargetFrame.IntegratedCastBar.timer:SetFont(STANDARD_TEXT_FONT, 8, 'OUTLINE')
TargetFrame.IntegratedCastBar.timer:SetShadowColor(0, 0, 0)
TargetFrame.IntegratedCastBar.timer:SetPoint('RIGHT', TargetFrame.IntegratedCastBar, 'RIGHT', -2, 0.5)
TargetFrame.IntegratedCastBar.timer:SetText('')

local function showCast()
    local showEF = FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['targetFrameCastbar']
    local showIntegrated = FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['integratedTargetFrameCastbar']

    if castbarmoveable then
        if showEF then TargetFrame.EFcast:Show() else TargetFrame.EFcast:Hide() end
        if showIntegrated then
            TargetFrame.IntegratedCastBar:Show()
            TargetFrameNameBackground:SetAlpha(0.3)
            TargetName:Hide()
        else
            TargetFrame.IntegratedCastBar:Hide()
            TargetFrameNameBackground:SetAlpha(1)
            TargetName:Show()
        end
    else
        TargetFrame.EFcast:Hide()
        TargetFrame.IntegratedCastBar:Hide()
        TargetFrameNameBackground:SetAlpha(1)
        TargetName:Show()
    end

    if UnitExists('target') then
        local v = SPELLCASTINGCOREgetCast(UnitName('target'), 'target')
        if v then
            local now = GetTime()
            if now < v.timeEnd then
                local duration = v.timeEnd - v.timeStart
                TargetFrame.EFcast:SetMinMaxValues(0, duration)
                TargetFrame.IntegratedCastBar:SetMinMaxValues(0, duration)

                local sparkPosition
                if v.inverse then
                    local progress = (v.timeEnd - now) % duration
                    TargetFrame.EFcast:SetValue(progress)
                    TargetFrame.IntegratedCastBar:SetValue(progress)
                    sparkPosition = (v.timeEnd - now) / duration
                else
                    local progress = (now - v.timeStart) % duration
                    TargetFrame.EFcast:SetValue(progress)
                    TargetFrame.IntegratedCastBar:SetValue(progress)
                    sparkPosition = (now - v.timeStart) / duration
                end

                TargetFrame.EFcast.text:SetText((v.spell or ''):sub(1, 20))
                TargetFrame.IntegratedCastBar.spellText:SetText((v.spell or ''):sub(1, 15))
                local timeLeft = FosterFrames.Helpers.GetTimerLeft(v.timeEnd, 3) .. 's'
                TargetFrame.EFcast.timer:SetText(timeLeft)
                TargetFrame.IntegratedCastBar.timer:SetText(timeLeft)
                TargetFrame.EFcast.icon:SetTexture(v.icon)

                if v.borderClr then
                    TargetFrame.EFcast.icon.border:SetColor(v.borderClr[1], v.borderClr[2], v.borderClr[3])
                    TargetFrame.EFcast.border:SetColor(v.borderClr[1], v.borderClr[2], v.borderClr[3])
                end

                if not sparkPosition or sparkPosition < 0 then sparkPosition = 0 end
                TargetFrame.IntegratedCastBar.spark:SetPoint('CENTER', TargetFrame.IntegratedCastBar, 'LEFT', sparkPosition * TargetFrameNameBackground:GetWidth(), -1)
                TargetFrame.EFcast.spark:SetPoint('CENTER', TargetFrame.EFcast, 'LEFT', sparkPosition * TargetFrame.EFcast:GetWidth(), 0)

                if showEF then TargetFrame.EFcast:Show() end
                if showIntegrated then
                    TargetFrame.IntegratedCastBar:Show()
                    TargetFrameNameBackground:SetAlpha(0.3)
                    TargetName:Hide()
                end
            end
        end
    end
end

function TARGETFRAMEsetFC(fc)
    flagCarriers = fc or {}
end

-- Target Portrait Flag Carrier / Debuff Overlay
local portraitDebuff = CreateFrame('Frame', 'TargetPortraitDebuff', TargetFrame)
portraitDebuff:SetFrameLevel(0)
portraitDebuff:SetPoint('TOPLEFT', TargetPortrait, 'TOPLEFT', 7, -2)
portraitDebuff:SetPoint('BOTTOMRIGHT', TargetPortrait, 'BOTTOMRIGHT', -5.5, 4)

portraitDebuff.bgText = TargetFrame:CreateTexture(nil, 'OVERLAY')
portraitDebuff.bgText:SetPoint('TOPLEFT', TargetPortrait, 'TOPLEFT', 3, -4.5)
portraitDebuff.bgText:SetPoint('BOTTOMRIGHT', TargetPortrait, 'BOTTOMRIGHT', -4, 3)
portraitDebuff.bgText:SetVertexColor(0.3, 0.3, 0.3)
portraitDebuff.bgText:SetTexture([[Interface\AddOns\FosterFrames\globals\resources\portraitBg.tga]])

portraitDebuff.debuffText = TargetFrame:CreateTexture()
portraitDebuff.debuffText:SetPoint('TOPLEFT', TargetPortrait, 'TOPLEFT', 7.5, -8)
portraitDebuff.debuffText:SetPoint('BOTTOMRIGHT', TargetPortrait, 'BOTTOMRIGHT', -7.5, 4.5)
portraitDebuff.debuffText:SetTexCoord(0.12, 0.88, 0.12, 0.88)

local portraitDurationFrame = CreateFrame('Frame', nil, TargetFrame)
portraitDurationFrame:SetAllPoints()
portraitDurationFrame:SetFrameLevel(2)

portraitDebuff.duration = portraitDurationFrame:CreateFontString(nil, 'OVERLAY')
portraitDebuff.duration:SetFont(STANDARD_TEXT_FONT, 16, 'OUTLINE')
portraitDebuff.duration:SetTextColor(0.9, 0.9, 0.2, 1)
portraitDebuff.duration:SetShadowOffset(1, -1)
portraitDebuff.duration:SetShadowColor(0, 0, 0)
portraitDebuff.duration:SetPoint('CENTER', TargetPortrait, 'CENTER', 0, -5)

portraitDebuff.cd = CreateCooldown(portraitDebuff, 1.054, true)
portraitDebuff.cd:SetAlpha(1)

local function showPortraitDebuff()
    if UnitExists('target') then
        local targetFaction = (UnitFactionGroup('target') == 'Alliance') and 'Horde' or 'Alliance'
        if UnitName('target') == flagCarriers[targetFaction] then
            portraitDebuff.debuffText:SetTexture(SPELLINFO_WSG_FLAGS[targetFaction]['icon'])
            portraitDebuff.bgText:Show()
            portraitDebuff.duration:SetText('')
            portraitDebuff.cd:Hide()
            portraitDebuff.bgText:SetVertexColor(0.1, 0.1, 0.1)
        else
            portraitDebuff.cd:Hide()
            portraitDebuff.debuffText:SetTexture()
            portraitDebuff.duration:SetText('')
            portraitDebuff.bgText:Hide()
        end
    end
end

-- Buff / Debuff Overlay Initializer
local function addExtras(button)
    if not button or button.ft then return end
    button.ft = CreateFrame('Frame', button:GetName() .. 'TextFrame', button)
    button.ft:SetFrameLevel(4)
    button.ft:SetAllPoints()

    button.text = button.ft:CreateFontString(nil, 'OVERLAY')
    button.text:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
    button.text:SetTextColor(0.9, 0.9, 0.2)
    button.text:SetShadowColor(0, 0, 0)
    button.text:SetPoint('CENTER', button, 'BOTTOM', 0, 1)

    button.f = CreateFrame('Frame', button:GetName() .. 'CooldownFrame', button)
    button.f:SetAllPoints()
    button.cd = CreateCooldown(button.f, 0.4, true)

    local icon = _G[button:GetName() .. 'Icon']
    if icon then icon:SetTexCoord(0.05, 0.95, 0.05, 0.95) end

    local count = _G[button:GetName() .. 'Count']
    if count then count:SetPoint('TOP', button, 'TOP', 0, -1) end
end

for i = 1, MAX_TARGET_BUFFS do
    addExtras(_G['TargetFrameBuff' .. i])
end
for i = 1, MAX_TARGET_DEBUFFS do
    addExtras(_G['TargetFrameDebuff' .. i])
end

local function checkAddTimer(button, debuffTexture, buffList)
    if not buffList or not debuffTexture then return end
    for _, v in pairs(buffList) do
        if v.icon and v.timeEnd and string.upper(v.icon) == string.upper(debuffTexture) then
            button.text:SetText(FosterFrames.Helpers.GetTimerLeft(v.timeEnd, 0))
            button.text:Show()
            button.cd:SetTimers(v.timeStart or (v.timeEnd - (v.duration or 0)), v.timeEnd)
            button.cd:Show()
            return
        end
    end
end

local limits = { MAX_TARGET_BUFFS, MAX_TARGET_DEBUFFS }
local function displayTimers(buffList)
    if not buffList then return end

    for i = 1, 2 do
        for j = 1, limits[i] do
            local tex, button
            if i == 1 then
                tex = UnitBuff('target', j)
                button = _G['TargetFrameBuff' .. j]
            else
                tex = UnitDebuff('target', j)
                button = _G['TargetFrameDebuff' .. j]
            end

            if not tex or not button then break end

            if button.text then button.text:Hide() end
            if button.cd then button.cd:Hide() end

            if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['targetDebuffTimers'] then
                checkAddTimer(button, tex, buffList)
            end
        end
    end
end

local dummyFrame = CreateFrame('Frame')
dummyFrame:SetScript('OnUpdate', function()
    nextRefresh = nextRefresh - (arg1 or 0.016)
    if nextRefresh <= 0 then
        if (FOSTERFRAMESPLAYERDATA and (FOSTERFRAMESPLAYERDATA['targetFrameCastbar'] or FOSTERFRAMESPLAYERDATA['integratedTargetFrameCastbar'])) then
            showCast()
        else
            TargetFrame.EFcast:Hide()
            TargetFrame.IntegratedCastBar:Hide()
            TargetFrameNameBackground:SetAlpha(1)
            TargetName:Show()
        end
        showPortraitDebuff()

        if UnitExists('target') then
            displayTimers(SPELLCASTINGCOREgetBuffs(UnitName('target'), 'target'))
        end

        nextRefresh = refreshInterval
    end
end)

function TARGETFRAMECASTBARsettings(b)
    castbarmoveable = b
end

dummyFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
dummyFrame:RegisterEvent('ZONE_CHANGED_NEW_AREA')
dummyFrame:SetScript('OnEvent', function()
    table.wipe(flagCarriers)
end)