-- FosterFrames - Main Visual Frame Suite
-- Enhanced 1.12.1 Engine Stack (ClassicAPI, SuperWoW, NamPower, UnitXP SP3, DXVK)

-- Mandatory Engine Dependency Guard
if not (CLASSIC_API_VERSION and SUPERWOW_VERSION) then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff2020[Fatal Error]|r FosterFrames requires ClassicAPI.dll & SuperWoW! Please ensure ClassicAPI.dll and SuperWoW are loaded.", 1, 0.2, 0.2)
    return
end

local playerFaction
local insideBG = false
local enemyFactionColor = { r = 1, g = 0.1, b = 0.1 }

-- Timers & Refresh Intervals
local rtMenuInterval = 5
local rtMenuEndtime = 0
local refreshInterval = 1 / 60
local nextRefresh = 0

-- Unit Limits & Collections
local unitLimit = 15
local maxUnits = 15
local units = {}
local raidTargets = {}
local raidIcons, raidIconsN = { [1] = 'skull', [2] = 'moon', [3] = 'square', [4] = 'triangle', [5] = 'star', [6] = 'diamond', [7] = 'cross', [8] = 'circle' }, 8

local enabled = false
FOSTERFRAMES_DEBUG = false
MOUSEOVERUNINAME = nil

local BACKDROP = { bgFile = [[Interface\Tooltips\UI-Tooltip-Background]] }

-- Main Display Container
fosterFrameDisplay = CreateFrame('Frame', 'fosterFrameDisplay', UIParent)
fosterFrame = fosterFrameDisplay
fosterFrame:SetFrameStrata("LOW")
fosterFrame:SetPoint('CENTER', UIParent, 0, 100)
fosterFrame:SetHeight(20)
fosterFrame:SetMovable(true)
fosterFrame:SetClampedToScreen(true)

fosterFrame:SetScript('OnDragStart', function()
    local frame = this or self
    if (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['frameMovable']) or (fosterFramesSettings and fosterFramesSettings:IsShown()) then
        frame:StartMoving()
    end
end)

fosterFrame:SetScript('OnDragStop', function()
    local frame = this or self
    frame:StopMovingOrSizing()
end)

fosterFrame:RegisterForDrag('LeftButton')
fosterFrame:EnableMouse(true)

fosterFrame.bg = fosterFrame:CreateTexture(nil, 'BACKGROUND')
fosterFrame.bg:SetAllPoints()
fosterFrame.bg:SetTexture(0, 0, 0, 0.5)
fosterFrame.bg:Hide()

fosterFrame.Title = fosterFrame:CreateFontString(nil, 'OVERLAY')
fosterFrame.Title:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE')
fosterFrame.Title:SetPoint('CENTER', fosterFrame, 'CENTER', 0, 1)

fosterFrame.totalPlayers = fosterFrame:CreateFontString(nil, 'OVERLAY')
fosterFrame.totalPlayers:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE')
fosterFrame.totalPlayers:SetPoint('RIGHT', fosterFrame, 'RIGHT', -4, 1)
fosterFrame.totalPlayers:Hide()

fosterFrame.spawnText = fosterFrame:CreateFontString(nil, 'OVERLAY')
fosterFrame.spawnText:SetFont(STANDARD_TEXT_FONT, 16, 'OUTLINE')
fosterFrame.spawnText:SetPoint('LEFT', fosterFrame, 'LEFT', 8, 1)

fosterFrame.spawnText.Button = CreateFrame('Button', nil, fosterFrame)
fosterFrame.spawnText.Button:SetHeight(15)
fosterFrame.spawnText.Button:SetWidth(15)
fosterFrame.spawnText.Button:SetPoint('CENTER', fosterFrame.spawnText, 'CENTER')
fosterFrame.spawnText.Button:SetScript('OnEnter', function()
    fosterFrame.spawnText:SetTextColor(0.9, 0.9, 0.4)
    GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT", -30, -30)
    GameTooltip:SetText(fosterFrame.spawnText.Button.tt or "Lock/Unlock")
    GameTooltip:Show()
end)
fosterFrame.spawnText.Button:SetScript('OnLeave', function()
    fosterFrame.spawnText:SetTextColor(enemyFactionColor.r, enemyFactionColor.g, enemyFactionColor.b, 0.9)
    GameTooltip:Hide()
end)

-- EFC Button
fosterFrame.efcButton = CreateFrame('Button', nil, fosterFrame)
fosterFrame.efcButton:SetHeight(15)
fosterFrame.efcButton:SetWidth(15)
fosterFrame.efcButton:SetPoint('LEFT', fosterFrame.Title, 'RIGHT', 2, 0)
fosterFrame.efcButton:SetScript('OnEnter', function()
    GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT", -30, -30)
    if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['efcDistanceTracking'] then
        local name, dist = FOSTERFRAMECOREGetEFCDistance()
        if name then
            GameTooltip:SetText('EFC: ' .. name .. ' (' .. dist .. ')')
        else
            GameTooltip:SetText('EFC: Unknown')
        end
    else
        GameTooltip:SetText('Toggle EFC Low Health Announcement')
    end
    GameTooltip:Show()
end)
fosterFrame.efcButton:SetScript('OnLeave', function() GameTooltip:Hide() end)

fosterFrame.efcButton.flagTexture = fosterFrame.efcButton:CreateTexture(nil, 'ARTWORK')
fosterFrame.efcButton.flagTexture:SetAllPoints()

fosterFrame.efcButton.distText = fosterFrame.efcButton:CreateFontString(nil, 'OVERLAY')
fosterFrame.efcButton.distText:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
fosterFrame.efcButton.distText:SetPoint('LEFT', fosterFrame.efcButton, 'RIGHT', 2, 0)
fosterFrame.efcButton.distText:SetTextColor(1, 1, 1)

-- Top / Bottom Header Frames
fosterFrame.top = CreateFrame('Frame', nil, fosterFrame)
fosterFrame.top:SetFrameLevel(0)
fosterFrame.top:ClearAllPoints()
fosterFrame.top:SetHeight(fosterFrame:GetHeight())
fosterFrame.top:SetBackdrop(BACKDROP)
fosterFrame.top:SetBackdropColor(0, 0, 0, 0.6)
fosterFrame.top.border = CreateBorder(nil, fosterFrame.top, 13)

fosterFrame.bottom = CreateFrame('Frame', nil, fosterFrame)
fosterFrame.bottom:SetFrameLevel(0)
fosterFrame.bottom:ClearAllPoints()
fosterFrame.bottom:SetHeight(fosterFrame:GetHeight())
fosterFrame.bottom:SetBackdrop(BACKDROP)
fosterFrame.bottom:SetBackdropColor(0, 0, 0, 0.6)
fosterFrame.bottom.border = CreateBorder(nil, fosterFrame.bottom, 13)

-- Raid Target Indicator Frame
fosterFrame.raidTargetFrame = CreateFrame('Frame', nil, fosterFrame)
fosterFrame.raidTargetFrame:SetFrameLevel(2)
fosterFrame.raidTargetFrame:SetHeight(36)
fosterFrame.raidTargetFrame:SetWidth(36)
fosterFrame.raidTargetFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, 160)
fosterFrame.raidTargetFrame:Hide()

fosterFrame.raidTargetFrame.text = fosterFrame.raidTargetFrame:CreateFontString(nil, 'OVERLAY')
fosterFrame.raidTargetFrame.text:SetFont(STANDARD_TEXT_FONT, 18, 'OUTLINE')
fosterFrame.raidTargetFrame.text:SetTextColor(0.8, 0.8, 0.8, 0.8)
fosterFrame.raidTargetFrame.text:SetPoint('CENTER', fosterFrame.raidTargetFrame, 'CENTER', 0, 0)
fosterFrame.raidTargetFrame.text:SetText('Player')

fosterFrame.raidTargetFrame.iconl = fosterFrame.raidTargetFrame:CreateTexture(nil, 'OVERLAY')
fosterFrame.raidTargetFrame.iconl:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
fosterFrame.raidTargetFrame.iconl:SetTexCoord(0.75, 1, 0.25, 0.5)
fosterFrame.raidTargetFrame.iconl:SetHeight(36)
fosterFrame.raidTargetFrame.iconl:SetWidth(36)
fosterFrame.raidTargetFrame.iconl:SetPoint('RIGHT', fosterFrame.raidTargetFrame.text, 'LEFT', -6, 0)

fosterFrame.raidTargetFrame.iconr = fosterFrame.raidTargetFrame:CreateTexture(nil, 'OVERLAY')
fosterFrame.raidTargetFrame.iconr:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
fosterFrame.raidTargetFrame.iconr:SetTexCoord(0.75, 1, 0.25, 0.5)
fosterFrame.raidTargetFrame.iconr:SetHeight(36)
fosterFrame.raidTargetFrame.iconr:SetWidth(36)
fosterFrame.raidTargetFrame.iconr:SetPoint('LEFT', fosterFrame.raidTargetFrame.text, 'RIGHT', 6, 0)

-- Raid Target Popup Menu
local rtMenuIconsize = 26
fosterFrame.raidTargetMenu = CreateFrame('Frame', nil, fosterFrame)
fosterFrame.raidTargetMenu:SetFrameLevel(7)
fosterFrame.raidTargetMenu:SetHeight(rtMenuIconsize * 2 + 4)
fosterFrame.raidTargetMenu:SetWidth(rtMenuIconsize * 4 + 10)
fosterFrame.raidTargetMenu:SetBackdrop(BACKDROP)
fosterFrame.raidTargetMenu:SetBackdropColor(0, 0, 0, 0.6)
fosterFrame.raidTargetMenu:Hide()
fosterFrame.raidTargetMenu.border = CreateBorder(nil, fosterFrame.raidTargetMenu, 10)
fosterFrame.raidTargetMenu.icons = {}

for j = 1, raidIconsN do
    local btn = CreateFrame('Button', 'fosterFrameRaidTargetMenuIcon' .. j, fosterFrame.raidTargetMenu)
    btn:SetHeight(rtMenuIconsize)
    btn:SetWidth(rtMenuIconsize)
    if j == 1 then
        btn:SetPoint('TOPLEFT', fosterFrame.raidTargetMenu, 'TOPLEFT', 1, -1)
    elseif j < 5 then
        btn:SetPoint('LEFT', fosterFrame.raidTargetMenu.icons[j - 1], 'RIGHT', 2, 0)
    else
        btn:SetPoint('TOP', fosterFrame.raidTargetMenu.icons[j - 4], 'BOTTOM', 0, -2)
    end
    btn.id = j
    btn.tex = btn:CreateTexture(nil, 'OVERLAY')
    btn.tex:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
    btn.tex:SetAlpha(0.6)
    local tCoords = RAID_TARGET_TCOORDS[raidIcons[j]]
    btn.tex:SetTexCoord(tCoords[1], tCoords[2], tCoords[3], tCoords[4])
    btn.tex:SetAllPoints()
    btn:SetScript('OnEnter', function() this.tex:SetAlpha(1) end)
    btn:SetScript('OnLeave', function() this.tex:SetAlpha(0.6) end)
    fosterFrame.raidTargetMenu.icons[j] = btn
end

local function spawnRTMenu(b, tar)
    fosterFrame.raidTargetMenu:SetPoint('TOP', b, 'BOTTOM', rtMenuIconsize / 2, 0)
    if fosterFrame.raidTargetMenu.target == tar and rtMenuEndtime > GetTime() then
        fosterFrame.raidTargetMenu:Hide()
        return
    end
    fosterFrame.raidTargetMenu.target = tar
    fosterFrame.raidTargetMenu:Show()
    rtMenuEndtime = GetTime() + rtMenuInterval
    for j = 1, raidIconsN do
        fosterFrame.raidTargetMenu.icons[j]:SetScript('OnClick', function()
            FOSTERFRAMECORESendRaidTarget(raidIcons[this.id], tar)
            fosterFrame.raidTargetMenu:Hide()
            rtMenuEndtime = 0
        end)
    end
end

local unitWidth, unitHeight, castBarHeight, ccIconWidth, manaBarHeight = UIElementsGetDimensions()
local leftSpacing = 5

-- Create Unit Frames
for i = 1, unitLimit do
    units[i] = CreateEnemyUnitFrame('fosterFrameUnit' .. i, fosterFrame)
    units[i].index = i
    units[i].hoverEnabled = false

    units[i]:SetScript('OnClick', function(self, button)
        local b = button or arg1
        local frame = self or this
        if b == 'LeftButton' and frame.tar then
            TargetByName(frame.tar, true)
        elseif b == 'RightButton' and frame.tar then
            spawnRTMenu(frame, frame.tar)
        end
    end)

    units[i]:SetScript('OnEnter', function(self)
        local frame = self or this
        if frame.hoverEnabled then
            frame.name:SetTextColor(enemyFactionColor.r, enemyFactionColor.g, enemyFactionColor.b)
            frame.mo = true
            MOUSEOVERUNINAME = frame.tar
        end
    end)

    units[i]:SetScript('OnLeave', function(self)
        local frame = self or this
        local r, g, b = frame.hpbar:GetStatusBarColor()
        if frame.hoverEnabled then
            frame.name:SetTextColor(r, g, b)
        else
            frame.name:SetTextColor(r, g, b, 0.6)
        end
        frame.mo = false
        MOUSEOVERUNINAME = nil
    end)
end

local function defaultVisuals()
    for i = 1, unitLimit do
        units[i].ffCastbar.icon:SetTexture([[Interface\Icons\Inv_misc_gem_sapphire_01]])
        units[i].ffCastbar.text:SetText('Entangling Roots')
        units[i].name:SetText('Player' .. i)
        units[i].raidTarget.icon:SetTexCoord(0.75, 1, 0.25, 0.5)
        units[i].cc.icon:SetTexture([[Interface\characterframe\TEMPORARYPORTRAIT-MALE-ORC]])
        units[i].cc.duration:SetText('2.8')
        units[i]:Show()
    end
end

local function optionals()
    if not FOSTERFRAMESPLAYERDATA then return end
    for i = 1, unitLimit do
        if not FOSTERFRAMESPLAYERDATA['displayNames'] then
            units[i].name:Hide()
        else
            units[i].name:Show()
        end

        if not FOSTERFRAMESPLAYERDATA['displayManabar'] then
            units[i].hpbar:SetHeight(unitHeight)
            units[i].manabar:Hide()
        else
            units[i].hpbar:SetHeight(unitHeight - manaBarHeight)
            units[i].manabar:Show()
        end

        if not FOSTERFRAMESPLAYERDATA['castTimers'] then
            units[i].ffCastbar.timer:Hide()
        else
            units[i].ffCastbar.timer:Show()
        end

        if not FOSTERFRAMESPLAYERDATA['targetCounter'] then
            units[i].targetCount.text:Hide()
        else
            units[i].targetCount.text:Show()
        end
    end
end

local function arrangeUnits()
    if not FOSTERFRAMESPLAYERDATA then return end
    local unitGroup = FOSTERFRAMESPLAYERDATA['groupsize'] or 5
    local layout = FOSTERFRAMESPLAYERDATA['layout'] or 'block'

    if playerFaction == 'Alliance' then
        fosterFrameDisplay.Title:SetText(layout == 'vertical' and 'H ' or 'Horde')
    else
        fosterFrameDisplay.Title:SetText(layout == 'vertical' and 'A ' or 'Alliance')
    end

    for i = 1, unitLimit do
        units[i]:ClearAllPoints()
        if i == 1 then
            units[i]:SetPoint('TOPLEFT', fosterFrameDisplay, 'BOTTOMLEFT', 0, -4)
        else
            if i > unitGroup then
                if layout == 'hblock' or layout == 'vblock' then
                    units[i]:SetPoint('TOPLEFT', units[i - unitGroup].ffCastbar.iconborder, 'BOTTOMLEFT', 1, -5)
                else
                    units[i]:SetPoint('TOPLEFT', units[i - unitGroup].cc, 'TOPRIGHT', leftSpacing, 0)
                end
            else
                if layout == 'hblock' or layout == 'vblock' then
                    units[i]:SetPoint('TOPLEFT', units[i - 1].cc, 'TOPRIGHT', leftSpacing, 0)
                else
                    units[i]:SetPoint('TOPLEFT', units[i - 1].ffCastbar.iconborder, 'BOTTOMLEFT', 1, -5)
                end
            end
        end
    end
end

local function showHideBars()
    if not FOSTERFRAMESPLAYERDATA then return end
    if FOSTERFRAMESPLAYERDATA['frameMovable'] then
        fosterFrameDisplay.spawnText.Button.tt = 'Lock'
        fosterFrameDisplay.top:Show()
        fosterFrameDisplay.bottom:Show()
        fosterFrameDisplay.spawnText:SetText('-')
    else
        fosterFrameDisplay.spawnText.Button.tt = 'Unlock'
        fosterFrameDisplay.top:Hide()
        fosterFrameDisplay.bottom:Hide()
        fosterFrameDisplay.spawnText:SetText('+')
    end
    fosterFrameDisplay:EnableMouse(FOSTERFRAMESPLAYERDATA['frameMovable'])
end

local function SetupFrames(maxU)
    maxUnits = maxU or 15
    if maxUnits < 1 then maxUnits = 1 end
    playerFaction = UnitFactionGroup('player')

    if playerFaction == 'Alliance' then
        enemyFactionColor = RGB_FACTION_COLORS['Horde']
        fosterFrameDisplay.Title:SetText('Horde')
    else
        enemyFactionColor = RGB_FACTION_COLORS['Alliance']
        fosterFrameDisplay.Title:SetText('Alliance')
    end

    fosterFrameDisplay.Title:SetTextColor(enemyFactionColor.r, enemyFactionColor.g, enemyFactionColor.b, 0.9)
    fosterFrameDisplay.spawnText:SetTextColor(enemyFactionColor.r, enemyFactionColor.g, enemyFactionColor.b, 0.9)
    fosterFrameDisplay.totalPlayers:SetTextColor(enemyFactionColor.r, enemyFactionColor.g, enemyFactionColor.b, 0.9)

    local layout = FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['layout'] or 'block'
    local groupSize = FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['groupsize'] or 5
    if groupSize < 1 then groupSize = 5 end

    local col = (layout == 'hblock' and 5) or (layout == 'vblock' and 2) or (layout == 'vertical' and 1) or math.floor(maxUnits / groupSize)
    if col < 1 then col = 1 end

    fosterFrameDisplay:SetWidth((unitWidth + ccIconWidth + 5) * col + leftSpacing * (col - 1))
    fosterFrameDisplay.top:SetWidth(fosterFrameDisplay:GetWidth())
    fosterFrameDisplay.top:SetPoint('CENTER', fosterFrameDisplay, 'CENTER', 0, 0)

    fosterFrameDisplay.spawnText.Button:SetScript('OnClick', function()
        FOSTERFRAMESPLAYERDATA['frameMovable'] = not FOSTERFRAMESPLAYERDATA['frameMovable']
        showHideBars()
        GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT", -30, -60)
        GameTooltip:SetText(fosterFrameDisplay.spawnText.Button.tt)
        GameTooltip:Show()
    end)

    fosterFrameDisplay.efcButton.flagTexture:SetTexture('Interface\\WorldStateFrame\\' .. (playerFaction or 'Alliance') .. 'Flag')
    fosterFrameDisplay.efcButton:SetScript('OnClick', function()
        FOSTERFRAMESPLAYERDATA['efcBGannouncement'] = not FOSTERFRAMESPLAYERDATA['efcBGannouncement']
        local clr = FOSTERFRAMESPLAYERDATA['efcBGannouncement'] and 1 or 0.3
        fosterFrameDisplay.efcButton.flagTexture:SetVertexColor(clr, clr, clr)
    end)

    local clr = (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['efcBGannouncement']) and 1 or 0.3
    fosterFrameDisplay.efcButton.flagTexture:SetVertexColor(clr, clr, clr)

    showHideBars()

    fosterFrameDisplay.bottom:SetWidth(fosterFrameDisplay:GetWidth())
    local unitPointBottom = (layout == 'hblock' and maxUnits - 4)
        or (layout == 'vblock' and ((maxUnits % 2 == 0) and maxUnits - 1 or maxUnits))
        or (layout == 'vertical' and maxUnits)
        or (maxUnits < groupSize and maxUnits)
        or groupSize

    if unitPointBottom < 1 then unitPointBottom = 1 end
    if units[unitPointBottom] then
        fosterFrameDisplay.bottom:SetPoint('TOPLEFT', units[unitPointBottom].ffCastbar.iconborder, 'BOTTOMLEFT', 1, -6)
    end

    if FOSTERFRAMES_DEBUG then
        for i = 1, maxUnits do units[i]:Show() end
    end
end

local function drawUnits(list)
    fosterFrame.uiList = list or {}
    local i = 1

    for _, v in pairs(fosterFrame.uiList) do
        if i > unitLimit then break end

        local class = v.class or 'WARRIOR'
        local powerType = v.powerType or 'mana'
        local colour = RAID_CLASS_COLORS[class] or RAID_CLASS_COLORS['WARRIOR']
        local powerColor = RGB_POWER_COLORS[powerType] or RGB_POWER_COLORS['mana']

        if v.nearby then
            units[i].hpbar:SetStatusBarColor(colour.r, colour.g, colour.b)
            units[i].hoverEnabled = true
            if not units[i].mo then units[i].name:SetTextColor(colour.r, colour.g, colour.b) end
            units[i].manabar:SetStatusBarColor(powerColor[1], powerColor[2], powerColor[3])
            units[i].cc.icon:SetVertexColor(1, 1, 1, 1)
        else
            units[i].hoverEnabled = false
            units[i].hpbar:SetStatusBarColor(colour.r / 2, colour.g / 2, colour.b / 2, 0.7)
            units[i].manabar:SetStatusBarColor(powerColor[1] / 2, powerColor[2] / 2, powerColor[3] / 2)
            if not units[i].mo then units[i].name:SetTextColor(colour.r / 2, colour.g / 2, colour.b / 2, 0.7) end
            if v.fc then
                units[i].cc.icon:SetVertexColor(1, 1, 1, 1)
            else
                units[i].cc.icon:SetVertexColor(0.4, 0.4, 0.4, 0.7)
            end
            units[i].cc.cd:Hide()
        end

        units[i].name:SetText((v.name or 'Unknown'):sub(1, 7))
        units[i].tar = v.name
        units[i].guid = v.guid

        -- CC / Spec icon
        local icon = v.fc and SPELLINFO_WSG_FLAGS[playerFaction]['icon'] or GET_DEFAULT_ICON('class', v.class)
        if not v.fc and FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['specSpecificIcons'] and v.spec then
            icon = GET_DEFAULT_ICON('spec', v.spec)
        end
        units[i].cc.icon:SetTexture(icon)

        -- Target count
        units[i].targetCount.text:SetText(v.targetcount and (v.targetcount > 0 and v.targetcount or '') or '')

        -- HP & Mana display (UnitXP SP3)
        local maxHP = v.maxhealth or 100
        local currHP = v.health or (not v.nearby and maxHP) or 100
        units[i].hpbar:SetMinMaxValues(0, maxHP)
        units[i].hpbar:SetValue(currHP)

        if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayHealthValues'] then
            units[i].hpText:SetText(currHP .. " / " .. maxHP)
            units[i].hpText:Show()
            units[i].name:Hide()
        else
            units[i].hpText:Hide()
            if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayNames'] then units[i].name:Show() end
        end

        local maxMana = v.maxmana or 100
        local currMana = v.mana or (not v.nearby and maxMana) or 100
        units[i].manabar:SetMinMaxValues(0, maxMana)
        units[i].manabar:SetValue(currMana)

        if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayManaValues'] then
            if v.class ~= 'WARRIOR' and v.class ~= 'ROGUE' then
                units[i].manaText:SetText(currMana .. " / " .. maxMana)
                units[i].manaText:Show()
            else
                units[i].manaText:SetText("")
                units[i].manaText:Hide()
            end
        else
            units[i].manaText:Hide()
        end

        if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayOnlyNearby'] and not v.nearby then
            units[i]:Hide()
        else
            units[i]:Show()
        end

        i = i + 1
    end

    for j = i, unitLimit do
        if units[j]:IsShown() then
            units[j]:Hide()
        end
    end
end

local function updateUnits()
    local now = GetTime()
    if rtMenuEndtime < now then fosterFrame.raidTargetMenu:Hide() end
    if not fosterFrame.uiList then return end

    local currentTarget = UnitExists('target') and UnitName('target') or nil
    local currentMouseover = UnitExists('mouseover') and UnitName('mouseover') or nil

    local i = 1
    for _, v in pairs(fosterFrame.uiList) do
        if i > unitLimit then return end

        local unitID = (currentTarget == v.name and 'target') or (currentMouseover == v.name and 'mouseover') or nil

        -- Border highlights
        if currentTarget == v.name then
            units[i].border:SetColor(enemyFactionColor.r, enemyFactionColor.g, enemyFactionColor.b)
            units[i].hpbar:SetBackdropColor(enemyFactionColor.r - 0.6, enemyFactionColor.g - 0.6, enemyFactionColor.b - 0.6, 0.6)
            units[i].manabar:SetBackdropColor(enemyFactionColor.r - 0.6, enemyFactionColor.g - 0.6, enemyFactionColor.b - 0.6, 0.6)
        else
            units[i].border:SetColor(0.1, 0.1, 0.1)
            units[i].hpbar:SetBackdropColor(0, 0, 0, 0.6)
            units[i].manabar:SetBackdropColor(0, 0, 0, 0.6)
        end

        -- Cast bar (UnitCastingInfo / UnitChannelInfo)
        local castInfo = SPELLCASTINGCOREgetCast(v.name, unitID)
        units[i].ffCastbar:Hide()
        if castInfo then
            local duration = castInfo.timeEnd - castInfo.timeStart
            units[i].ffCastbar:SetMinMaxValues(0, duration)
            if castInfo.inverse then
                units[i].ffCastbar:SetValue((castInfo.timeEnd - now) % duration)
            else
                units[i].ffCastbar:SetValue((now - castInfo.timeStart) % duration)
            end
            local charLim = (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['castTimers']) and 14 or 15
            units[i].ffCastbar.text:SetText((castInfo.spell or ''):sub(1, charLim))
            units[i].ffCastbar.timer:SetText(FosterFrames.Helpers.GetTimerLeft(castInfo.timeEnd, 3))
            units[i].ffCastbar.icon:SetTexture(castInfo.icon)
            if castInfo.borderClr then
                units[i].ffCastbar.b:SetColor(castInfo.borderClr[1], castInfo.borderClr[2], castInfo.borderClr[3])
            else
                units[i].ffCastbar.b:SetColor(0.1, 0.1, 0.1)
            end
            units[i].ffCastbar:Show()
        end

        -- Trinket CD
        local trinket = FOSTERFRAMECOREGetTrinketCooldown(v.guid)
        if trinket then
            units[i].trinket.icon:SetTexture(trinket.icon or [[Interface\Icons\inv_jewelry_trinketpvp_01]])
            units[i].trinket.cd:SetTimers(trinket.start, trinket['end'])
            units[i].trinket.cd:Show()
            units[i].trinket:Show()
        else
            units[i].trinket:Hide()
        end

        -- Raid Target
        if v.name and raidTargets[v.name] then
            local tCoords = RAID_TARGET_TCOORDS[raidTargets[v.name].icon]
            if tCoords then
                units[i].raidTarget.icon:SetTexCoord(tCoords[1], tCoords[2], tCoords[3], tCoords[4])
                units[i].raidTarget:Show()
            else
                units[i].raidTarget:Hide()
            end
        else
            units[i].raidTarget:Hide()
        end

        if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayOnlyNearby'] and not v.nearby then
            units[i]:Hide()
        else
            units[i]:Show()
        end

        i = i + 1
    end
end

local function fosterFramesOnUpdate()
    nextRefresh = nextRefresh - (arg1 or 0.016)
    if nextRefresh <= 0 then
        raidTargets = FOSTERFRAMECOREGetRaidTarget() or {}
        updateUnits()

        if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['efcDistanceTracking'] and fosterFrame.efcButton:IsShown() then
            local name, dist = FOSTERFRAMECOREGetEFCDistance()
            if name and dist ~= 'unknown' then
                fosterFrame.efcButton.distText:SetText(dist)
            else
                fosterFrame.efcButton.distText:SetText('')
            end
        else
            fosterFrame.efcButton.distText:SetText('')
        end

        nextRefresh = refreshInterval
    end
end

--- Global Entry Points ---

function FOSTERFRAMESUpdatePlayers(list)
    drawUnits(list)
end

function FOSTERFRAMESInitialize(maxU, isBG)
    insideBG = isBG
    MOUSEOVERUNINAME = nil

    if maxU then
        SetupFrames(maxU)
        arrangeUnits()
        optionals()
        enabled = true

        if insideBG and GetZoneText() == 'Warsong Gulch' then
            fosterFrame.efcButton:Show()
        else
            fosterFrame.efcButton:Hide()
        end

        if (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['enableFrames']) or insideBG then
            fosterFrame:Show()
        else
            fosterFrame:Hide()
        end
        fosterFrame:SetScript('OnUpdate', fosterFramesOnUpdate)
    else
        fosterFrame:SetScript('OnUpdate', nil)
    end
end

function FOSTERFRAMESsettings()
    optionals()
    if not enabled or (not insideBG and (fosterFramesSettings and fosterFramesSettings:IsShown())) then
        SetupFrames(15)
        defaultVisuals()
        fosterFrame.efcButton:Show()
        fosterFrame.efcButton.distText:SetText((FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['efcDistanceTracking']) and '< 28yd' or '')
    else
        SetupFrames(maxUnits)
        if insideBG and GetZoneText() == 'Warsong Gulch' then
            fosterFrame.efcButton:Show()
        else
            fosterFrame.efcButton:Hide()
        end
    end
    arrangeUnits()
    if (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['enableFrames']) or insideBG then
        fosterFrame:Show()
    else
        fosterFrame:Hide()
    end

    if not enabled and not (fosterFramesSettings and fosterFramesSettings:IsShown()) then
        for i = 1, unitLimit do units[i]:Hide() end
    end
end

-- Debug Utilities
function FOSTERFRAMES_DebugDisplayPlayerData()
    local list = FOSTERFRAMECOREgetPlayerList and FOSTERFRAMECOREgetPlayerList() or {}
    DEFAULT_CHAT_FRAME:AddMessage("|cffae7cee[FosterFrames]|r Player Data Dump:")
    for k, v in pairs(list) do
        DEFAULT_CHAT_FRAME:AddMessage("  " .. tostring(k) .. ":")
        for i, j in pairs(v) do
            DEFAULT_CHAT_FRAME:AddMessage("    " .. tostring(i) .. " = " .. tostring(j))
        end
    end
end

function FOSTERFRAMES_DebugCooldownTest()
    FOSTERFRAMES_DEBUG = true
    local classes = { 'WARRIOR', 'PALADIN', 'HUNTER', 'ROGUE', 'PRIEST', 'SHAMAN', 'MAGE', 'WARLOCK', 'DRUID' }
    local powers = { 'rage', 'mana', 'mana', 'energy', 'mana', 'mana', 'mana', 'mana', 'mana' }

    for i = 1, unitLimit do
        local c = classes[((i - 1) % 9) + 1]
        local p = powers[((i - 1) % 9) + 1]

        units[i].name:SetText('Dummy' .. i)

        local colour = RAID_CLASS_COLORS[c] or RAID_CLASS_COLORS['WARRIOR']
        local powerColor = RGB_POWER_COLORS[p] or RGB_POWER_COLORS['mana']

        units[i].hpbar:SetStatusBarColor(colour.r, colour.g, colour.b)
        units[i].manabar:SetStatusBarColor(powerColor[1], powerColor[2], powerColor[3])
        units[i].hpbar:SetMinMaxValues(0, 100)
        units[i].hpbar:SetValue(math.random(20, 100))
        units[i].manabar:SetMinMaxValues(0, 100)
        units[i].manabar:SetValue(math.random(20, 100))

        units[i].cc.icon:SetTexture(GET_DEFAULT_ICON('class', c))
        units[i].cc.cd:SetTimers(GetTime(), GetTime() + 8)
        units[i].cc.cd:Show()
        units[i]:Show()
    end
    fosterFrameDisplay:Show()
    fosterFrameDisplay.Title:SetText('DEBUG MODE')
    fosterFrameDisplay.bg:Show()
end

function FOSTERFRAMES_HideFrames()
    FOSTERFRAMES_DEBUG = false
    for i = 1, unitLimit do units[i]:Hide() end
    if fosterFrameDisplay then fosterFrameDisplay:Hide() end
end

